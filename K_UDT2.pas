unit K_UDT2;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses Windows, SysUtils, Classes,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
     K_Types, K_CLib0, K_UDT1, K_SBuf, K_STBuf, K_Script1,
     N_Types, N_Lib1, N_Lib0;

{
//##/* obsolete types - skip from documentation
type TK_UDIterFunc = function( const DE : TN_DirEntryPar ) : Boolean;

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDIterFlags
type TK_UDIterFlags = (
  K_ifSkipRoot,
  K_ifSkipEmpty,
  K_ifSkipData,
  K_ifSkipDataRef,
  K_ifSkipDataRefObj,
  K_ifSkipDataRefElem,
  K_ifSkipChildRef,
  K_ifSkipDown
  );


type TK_UDIterFlagSet = Set of TK_UDIterFlags;

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDIter
//************************************************************ TK_UDIter ***
// Scan IDB Objects Tree Iterator class  (obsolete, not used now)
//
type TK_UDIter = class( TObject )
      public
  FFlags : TK_UDIterFlagSet;
  StackLevel: integer;           // current Stack level
  Stack: TK_DEArray;             // Stack Items
  FSelectFilter : TK_UDFilter;
  FStepDownFilter : TK_UDFilter;
  UsedNodesList : TList;

  constructor Create( RootDirObj: TN_UDBase;
                      AFlags : TK_UDIterFlagSet = [K_ifSkipEmpty];
                      ASelectFilter : TK_UDFilter = nil;
                      AStepDownFilter : TK_UDFilter = nil );
  destructor  Destroy; override;
  procedure   InitRoot( RootDirObj: TN_UDBase );
  function    GetNext( var DE : TN_DirEntryPar ) : Boolean;
  function    GetNext1( var DE : TN_DirEntryPar ) : Boolean;
  function    StepToParent( ) : Boolean;
end; //*** end of type TK_UDIter = class( TObject )
//##*/
{}

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDFilterClassFlags
//*************************************************** TK_UDFilterClassFlags ***
// IDB objects filter Item which used TN_UDBase.ClassFlags (ClassIndex) Value 
// and Mask
//
type  TK_UDFilterClassFlags = class( TK_UDFilterItem )
      private
        FFlagsValue  : LongWord; // IDB objects ClassIndex Value for compare
        FFlagsMask   : LongWord; // mask for selecting IDB objects ClassIndex 
                                 // bits to compare
      public
  constructor Create( FlagsValue : LongWord; FlagsMask : LongWord = 0;
                AExprCode : TK_UDFilterItemExprCode = K_ifcOr);
  function    UDFITest( const DE : TN_DirEntryPar ) : Boolean;  override;
end; //*** end of type TK_UDFilterClassSect = class( TK_UDFilterItem )

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDFilterClassSect
//**************************************************** TK_UDFilterClassSect ***
// IDB objects filter Item which used TN_UDBase.ClassFlags (ClassIndex) Values 
// Interval
//
type  TK_UDFilterClassSect = class( TK_UDFilterItem )
      private
        ClassStart  : LongWord; // ClassIndex start Value
        ClassFin    : LongWord; // ClassIndex final Value
      public
  constructor Create( AClassStart : LongWord; AClassFin : LongWord = 0;
                AExprCode : TK_UDFilterItemExprCode = K_ifcOr);
  function    UDFITest( const DE : TN_DirEntryPar ) : Boolean;  override;
end; //*** end of type TK_UDFilterClassSect = class( TK_UDFilterItem )

type TK_UDFilterTestFunc = function( const DE : TN_DirEntryPar ): Boolean;

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDFilterFuncTest
//***************************************************** TK_UDFilterFuncTest ***
// IDB objects filter Item which used given function
//
// User given function type for testing IDB objects is TK_UDFilterTestFunc
//
type  TK_UDFilterFuncTest = class( TK_UDFilterItem )
      private
        FTestFunc : TK_UDFilterTestFunc; // user defined test function
      public
  constructor Create( ATestFunc : TK_UDFilterTestFunc;
                      AExprCode : TK_UDFilterItemExprCode = K_ifcOr );
  function    UDFITest( const DE : TN_DirEntryPar ) : Boolean;  override;
end; //*** end of type TK_UDFilterFuncTest = class( TK_UDFilterItem )

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor
//************************************************************* TK_UDCursor ***
// IDB Cursor Class
//
// Is used to access to IDB Objects by converting IDB Objects Path to Objects 
// Reference.
//
type TK_UDCursor = class( TObject )
      public
  Stack : TK_DEArray;            // Cursor stack as array of TN_DirEntryPar
  PathDoneLevel : Integer;       // index of Cursor current used stack depth
  ErrPath : string;              // error Path after unsuccessful attempt to get
                                 // IDB Object using Cursor
  ObjNameType : TK_UDObjNameType;// Cursor current Path Segments contents type 
                                 // (TN_UDBase.Name or TN_UDBase.Aliase)

  constructor Create( const Name : string; RootDirObj: TN_UDBase;
                        AObjNameType : TK_UDObjNameType = K_ontObjName );
//##/*
  destructor Destroy(  ); override;
//##*/
  procedure  SetRoot( RootDirObj: TN_UDBase );
  function   GetRoot(  ) : TN_UDBase;
  function   SetRootPath( const RootPath : string = '' ) : boolean;
  function   GetRootPath(  ) : string;
  function   SetPath( const Path : string = '' ) : boolean;
  function   GetDE( out DE : TN_DirEntryPar; const Path : string = '';
                CurrentLevel : Boolean = false ) : boolean;
  function   GetObj( const Path : string = '';
                CurrentLevel : Boolean = false ) : TN_UDBase;
  function   GetPath( SLevel : Integer = -MaxInt; FLevel : Integer = 0 ) : string;
  function   IncludeCursorName( const Path : string ) : string;
  function   GetErrPath(  ) : string;
  function   GetName(  ) : string;
  function   GetObjPath( Obj : TN_UDBase ) : string;
//  function   GetDEPath( const DE : TN_DirEntryPar ) : string;
//##/*
    private
  StackLevel : integer;         // current Stack level
  PathDonePos : Integer;
  RootLevel : Integer;
  StepUp : Boolean;
//##*/
end; //*** end of type TK_UDCursor = class( TObject )

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDRef
//**************************************************************** TK_UDRef ***
// Special IDB Object Object-Reference Class
//
// This Objects are used as special "vice-Objects" instead of "real" Objects 
// while IDB Subtree is prepared to serialization. The references to 
// "vice-Objects" are replaced by references to "real" Objects during IDB 
// Subtree recovery after deserialization.
//
{type} TK_UDRef = class (TN_UDBase)
//##/*
  constructor Create( ); override;
  destructor Destroy(); override;
//##*/
//*** methods inherited from TN_UDBase
  procedure AddFieldsToSBuf   ( SBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( SBuf: TN_SerialBuf ); override;
  function  AddFieldsToText   ( SBuf: TK_SerialTextBuf;
                                AShowFlags : Boolean = true ) : Boolean; override;
  function  GetFieldsFromText ( SBuf: TK_SerialTextBuf ) : Integer; override;
  procedure CopyFields ( SrcObj: TN_UDBase ); override;
//***
  function  GetRefObject() : TN_UDBase;

  private
  protected
  public

end;
//*****************************  end of TK_UDRef = class (TN_UDBase) ***

{
//************************************* TK_UDUserRoot ***
// class indicator main scale dir (tree emplementation)
//
TK_UDUserRoot = class (TN_UDBase)
  constructor Create( ); override;
  private
  protected
  public

end;
}
//*****************************  end of TK_UDUserRoot = class (TN_UDBase) class ***

//##fmt PELSize=80,PELPos=2,PELShift=7

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree
//******************************************************** TK_ScanUDSubTree ***
// IDB Objects Subtrees special examination Class
//
// Is used for special examination of IDB Objects Subtrees such as following: 
// search all references in given Subtree to given Object, search all External 
// references from given Subtree (search all Objects that are not members of 
// given Subtree but references to which are from the Objects members of given 
// Subtree), search all Entries of given Subtree (Objects members of given 
// Subtree references to which are from the Objects that are not members of 
// given Subtree) and so on
//
type  TK_ScanUDSubTree = class( TObject ) //
//##/*
  constructor Create( );
  destructor  Destroy(); override;
//##*/
  procedure  IniLists();

//*** Build List of Subtree Entry Nodes and List of Subtree External Nodes (not constructional Nodes)
//  ParentNodes  - List of Subtree Parents to External Nodes
//  ParentLPaths - List of Local Paths from Subtree Parents to External Nodes
//  EntryNodes   - List of Subtree Entry Nodes
  procedure BuildEERefNodesLists( UDRoot : TN_UDBase; SkipEntryRefNodes : Boolean = false );
  function  BuildExtRefNodesListScan( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                                  ChildInd : Integer; ChildLevel : Integer;
                                  const FieldName : string = '' ) : TK_ScanTreeResult;
  function  BuildEntryRefNodesListScan( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                                  ChildInd : Integer; ChildLevel : Integer;
                                  const FieldName : string = '' ) : TK_ScanTreeResult;

//*** Build List of Subtree Nodes which are parents to Specified Child Node
//  ParentNodes  - List of Subtree Parents to Specified Child Node
//  ParentLPaths - List of Local Paths from Subtree Parents to Specified Child Node
  procedure BuildParentsList( UDRoot,  UDChild: TN_UDBase;
                              AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags );
  function  BuildParentsListScan( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                                  ChildInd : Integer; ChildLevel : Integer;
                                  const FieldName : string = '' ) : TK_ScanTreeResult;

//*** Build List of Node Childs References
//  RefNodes  - List of Node Childs
//  RefLPaths - List of Local Paths to Node Childs
  procedure BuildNodeRefsList( UDParent : TN_UDBase;
                           AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags );
  function  BuildNodeRefsListScan( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                                   ChildInd : Integer; ChildLevel : Integer;
                                   const FieldName : string = '' ) : TK_ScanTreeResult;

//*** Build List of Subtree Parents to TK_UDRef Nodes
//  ParentNodes  - List of Subtree Parents to TK_UDRef Nodes
//  ParentLPaths - List of Local Paths from Subtree Parents to TK_UDRef Nodes
//  UniqRefs     - List of TK_UDRef Nodes to UDTree Uniq Nodes
  procedure BuildUDRefParentsList( UDRoot : TN_UDBase;
                            AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags );
  function  BuildUDRefParentsListScan( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                                  ChildInd : Integer; ChildLevel : Integer;
                                  const FieldName : string = '' ) : TK_ScanTreeResult;

//*** Build List of Subtree Parents to Nodes which have Lost Owners
//  ParentNodes  - List of Subtree Parents to Nodes which have Lost Owners
//  ParentLPaths - List of Local Paths from Subtree Parents to Nodes which have Lost Owners
//  UniqRefs     - List of Nodes which have Lost Owners
  procedure BuildUDOwnerLostParentsList( UDRoot : TN_UDBase;
                            AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags );
  function  BuildUDOwnerLostParentsListScan( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                                  ChildInd : Integer; ChildLevel : Integer;
                                  const FieldName : string = '' ) : TK_ScanTreeResult;

//*** Build List of Subtree Nodes which have Specified Type
//  Nodes  - List of Found Nodes which have Specified Type
  procedure BuildUDNodesByTypeList( UDRoot : TN_UDBase; ANodesCIs, ANodesRASTypes : TList;
                                    AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags );
  function  BuildUDNodesByTypeListScan( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                                  ChildInd : Integer; ChildLevel : Integer;
                                  const FieldName : string = '' ) : TK_ScanTreeResult;
//*** Change Checked State
//  Nodes  - List of Nodes which have Checked State
  procedure ChangeNodesCheckedState( UDRoot : TN_UDBase; AChangeMode: Integer;
                                     AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags = [K_udtsOwnerChildsOnlyScan] );
  function  ChangeNodesCheckedStateScan( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                                  ChildInd : Integer; ChildLevel : Integer;
                                  const FieldName : string = '' ) : TK_ScanTreeResult;
  procedure ChangeNodesDisabledState( UDRoot : TN_UDBase; AChangeMode: Integer;
                                     AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags = [K_udtsOwnerChildsOnlyScan] );
  function  ChangeNodesDisabledStateScan( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                                  ChildInd : Integer; ChildLevel : Integer;
                                  const FieldName : string = '' ) : TK_ScanTreeResult;
//##/*
private
  RefNodes0     : TList;
  RefNodes1     : TList;
  RefLPaths0    : TK_TStringsList;
  SL            : TStringList;
  CurTestRoot   : TN_UDBase;
  CurTestChild  : TN_UDBase;
  NodesCIs      : TList;
  NodesRASTypes : TList;
  ScanMode      : Integer;
//##*/
public
  property EntryNodes : TList read RefNodes1 write RefNodes1; // List (TList) of
       // Objects references to which are found
  property ParentNodes   : TList read RefNodes0 write RefNodes0; // List (TList)
       // of Objects which are Parents of found Entry Objects
  property ParentLPaths  : TK_TStringsList read RefLPaths0 write RefLPaths0; //
       // List of StringsList (TK_TStringsList) for Parent Objects, each 
       // StringsList contains all Child Objects and relative Paths to them
  property UniqRefs      : TList read RefNodes1 write RefNodes1; // List (TList)
       // of Objects which has no duplicates
  property RefNodes      : TList read RefNodes0 write RefNodes0; // List (TList)
       // of Objects which are Childs of given Parent Object
  property RefLPaths     : TK_TStringsList read RefLPaths0 write RefLPaths0; //
       // List of StringsList (TK_TStringsList) for Child Objects, each 
       // StringsList contains all relative Paths to them
  property Nodes         : TList read RefNodes0 write RefNodes0; // List (TList)
       // of Objects which have given type;
end;

//##fmt
{
type  TK_BuildUDVCSSRefs = class( TObject ) //
  procedure BuildRefs( UDRoot : TN_UDBase  );
  function  BuildUDVCSSRefs( UDParent : TN_UDBase; var UDChild : TN_UDBase;
    ChildInd : Integer; ChildLevel : Integer; FieldName : string = '' ) : TK_ScanTreeResult;
end;
}

//****************************************************
//*** UDCursor Types, Variables and Procedures
//****************************************************
function   K_UDCursorGet( const Path : string ) : TK_UDCursor;
function   K_UDCurCursorSet( const Path : string ) : TK_UDCursor;
function   K_UDCursorSetRootPath( const Path : string ) : boolean;
function   K_UDCursorSetPath( const Path : string ) : boolean;
function   K_UDCursorGetDE( out DE : TN_DirEntryPar; const Path : string = '' ) : boolean;
function   K_UDCursorGetObj( const Path : string = ''; AObjNameType : TK_UDObjNameType = K_ontObjName ) : TN_UDBase;
procedure  K_SetNodeCursorRefPath( UDRoot : TN_UDBase; UDCursorName : string );
function   K_UDCursorForceDir( const Path : string = '';
                               AObjNameType : TK_UDObjNameType = K_ontObjName ) : TN_UDBase;
function   K_UDCursorGetFieldPointer( const Path : string;
                        var PField  : Pointer;
                        PUDR : TN_PUDBase = nil; PErrPathPos : PInteger = nil ) : TK_ExprExtType;
function   K_UDCurCursorGet(  ) : TK_UDCursor;

function   K_UDCurCursorGetRootPath(  ) : string;
function   K_UDCurCursorGetPath( SLevel : Integer = 0; FLevel : Integer = 0 ) : string;
function   K_UDCurCursorIncludeName( const Path : string ) : string;
procedure  K_UDCurCursorSetRoot( RootDirObj: TN_UDBase );
function   K_UDCurCursorGetRoot(  ) : TN_UDBase;
function   K_UDCurCursorGetObjPath( Obj : TN_UDBase ) : string;
//function   K_UDCurCursorGetDEPath( const DE : TN_DirEntryPar ) : string;
function   K_UDCurCursorGetErrPath(  ) : string;

var
  K_UDCursor : TK_UDCursor;
  K_UDAbsPathCursor : TK_UDCursor;
  K_UDCursorsList : TStringList;

//*************************************** K_ForcePathDefUDCI
//  Force UDTree Path Routine Default Folder Node CI
//
  K_UDCursorForcePathDefUDCI : Integer;

//****************************************************
//*** end of UDCursor Types, Variables and Procedures
//****************************************************

function  K_GetUDObjByGPath( const UDPath : string ) : TN_UDBase;

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ReadOnlyMemStream
type TK_ReadOnlyMemStream = class(TCustomMemoryStream)
public
  procedure SetMem( APMem : Pointer; AMemSize : Integer );
  function Write( const ABuffer; ACount: Longint ): Longint; override;
{
  procedure LoadFromStream(Stream: TStream);
  procedure LoadFromFile(const FileName: string);
  procedure SetSize(NewSize: Longint); override;
  function Write(const Buffer; Count: Longint): Longint; override;
}
end;


//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_VFileType
type TK_VFileType = ( // Virtual File Type enumeration
  K_vftDFile,      // Data File
  K_vftMVCMemFile, // Buffered Compound File Memory Item
  K_vftUDMemFile,  // Stand alone Memory Item
  K_vftMVCFile );  // Not Buffered Compound File Item

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_VFile
//**************************************************************** TK_VFile ***
// Virtual File Operating Record
//
// Is used in all Virtual Files handling routines.
//
type TK_VFile = record
  VFType     : TK_VFileType;  // Virtual file type
  VFStreamWriteMode : Boolean; // =TRUE if Virtual file stream is created in 
                               // write mode
  UDMemName : string;          // path to IDB Object if Virtual File is places 
                               // in Application IDB Object
  UDMem : TN_UDBase;           // reference to to IDB Object if Virtual File is 
                               // places in IDB Object SkipFieldCharFlag : 
                               // Boolean;
  UDCBFRoot : TN_UDBase;       // Root Object of Compound Buffered File Subtree
  DFName : string;             // DataFile Path and name if Virtual File is 
                               // placed in DataFile or Compound File
  DFile  : TK_DFile;           // DataFile Operating Record
  DFCreatePars: TK_DFCreateParams; // DataFile Create Parameters
  DFOpenFlags : TK_DFOpenFlags;    // DataFile open flags
end;

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_VFileCopyResultCode
type TK_VFileCopyResultCode = ( // Virtual Files Copy Result Codes enumeration
  K_vfcrOK,                 // Source File is successfully copied to Destination
  K_vfcrDestNewer,          // Source File is not copied because Destination 
                            // File exists and is newer than source
  K_vfcrSrcNotFound,        // Source File is not found
  K_vfcrReadSrcError,       // Source File read error
  K_vfcrDestPathError,      // Destination File Path creation error
  K_vfcrDecompressionError, // Source File Decompression error
  K_vfcrCompressionError,   // Destination File Compression error
  K_vfcrWriteError          // Destination File Write error
  );

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_VFileSearchType
type TK_VFileSearchType = ( // Virtual File FindNext resulting enumeration
  K_vfsVFile, // Virtual File
  K_vfsVDir,  // Virtual Files Folder
  K_vfsUndef  // Undefined Result (such as '.' or '..' in OS Files FindNext)
  );
type TK_VFileSearchFlags = set of TK_VFileSearchType;

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_VFileCopyFlags
type TK_VFileCopyFlags = set of ( // Virtual Files Copy flags set
  K_vfcRecurseSubfolders, // recurse Subfolders while copy Virtual Files Subtree
  K_vfcOverwriteNewer,    // overwrite newer Destination File
  K_vfcDecompressSrc,     // decompress Source File
  K_vfcCompressSrc0,      // compress Destination File (compression power 0)
  K_vfcCompressSrc1,      // compress Destination File (compression power 1)
  K_vfcCompressSrc2       // compress Destination File (compression power 2)
);

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_VFileSearchRec
type TK_VFileSearchRec = record // Virtual File FindNext search state record
// Source Search Context
  VFSFlags  : TK_VFileSearchFlags; // search Flags
  VFNamePat : string;              // search Name Pattern
  VFSType : TK_VFileSearchType;    // found File Type
  VFName  : string;                // found file Name
  VFSize  : Integer;               // found file Size Runtime Search Context
  VFFType   : TK_VFileType;        // VFile Folder Type
  CurUDMemInd : Integer;           // current Child Object index if search in 
                                   // IDB Subtree
  UDMemRoot   : TN_UDBase;         // current Root Object if search in IDB 
                                   // Subtree
  F: TSearchRec;                   // search state record for OS file if search 
                                   // in OS File Subtree
end;

const
  K_vfmMVCMemFileDelimeter = '>';
  K_vfmMVCFileDelimeter = '|';
  K_vfmTmpCBFNamePref = '*';
//  K_vfmDelimeter = '|';

{!!!
var
  K_SaveTextAsAnsi : Boolean = TRUE;
//  K_SaveTextAsAnsi : Boolean = FALSE;
}

function  K_MVCBFileGetRoot( const ADFileName: string ): TN_UDBase;
procedure K_MVCBSetFileName( CBFRoot: TN_UDBase; const ADFileName: string );
function  K_MVCBFileAssign( const ADFileName: string ): TN_UDBase;
procedure K_MVCBFileSave( CBFRoot: TN_UDBase );
procedure K_MVCBFileClose ( CBFRoot: TN_UDBase );
procedure K_MVCBFSaveAll( );
procedure K_MVCBFCloseAll( );
function  K_VFGetErrorString( var AVFile: TK_VFile ) : string;
function  K_VFAssignByPath( var VFile: TK_VFile; const AVFileName: string;
                            APDFCreatePars: TK_PDFCreateParams = nil ) : TK_VFileType;
function  K_VFOpen     ( var VFile: TK_VFile;
                         AOpenFlags: TK_DFOpenFlags = [] ): Integer;
procedure K_VFStreamFree( var VFile: TK_VFile );
function  K_VFStreamGetToRead( var VFile: TK_VFile ): TStream;
function  K_VFRead     ( var VFile: TK_VFile; APBuffer: Pointer;
                         ANumBytes: Integer; CloseFileFlag : Boolean ): Boolean;
function  K_VFReadAll  ( var VFile: TK_VFile; APBuffer: Pointer ): Boolean;
function  K_VFSetDataSpace( var VFile: TK_VFile; ADSpace: Integer  ): boolean;
function  K_VFStreamGetToWrite( var VFile: TK_VFile ): TStream;
procedure K_VFWriteAll ( var VFile: TK_VFile; APFirstByte: Pointer; ANumBytes: Integer );
function  K_VFileExists0( var VFile: TK_VFile ) : Boolean;
function  K_VFileExists( const AVFileName: string ) : Boolean;
function  K_VFDirExists0( var VFile: TK_VFile ) : Boolean;
function  K_VFDirExists( const AVDirPath: string ) : Boolean;
procedure K_VFSetFileAge( var VFile: TK_VFile; DT : TDateTime );
function  K_VFileAge0( var VFile: TK_VFile ) : TDateTime;
function  K_VFileAge( const AVFileName: string ) : TDateTime;
function  K_VFForceDirPath0( var VFile: TK_VFile ) : Boolean;
function  K_VFForceDirPath( const AVFileDirPath : string ) : Boolean;
function  K_VFForceDirPathDlg( const AVFileDirPath : string ) : Boolean;
function  K_VFFindFirst( var VFS : TK_VFileSearchRec;
                         const AVDirPath : string;
                         AVFSFlags : TK_VFileSearchFlags = [K_vfsVFile, K_vfsVDir];
                         NamePat : string = '*.*' ) : Boolean;
function  K_VFFindNext ( var VFS : TK_VFileSearchRec ) : Boolean;
procedure K_VFFindClose( var VFS : TK_VFileSearchRec );
function  K_VFCompareFilesAge0( var SVFile, DVFile: TK_VFile ) : TK_VFileCopyResultCode;
function  K_VFCompareFilesAge( const SrcFName, DestFName : string ) : TK_VFileCopyResultCode;
function  K_VFCopyFile( const SrcFName, DestFName : string;
                        const ACreatePars : TK_DFCreateParams;
                        AVFCFlags : TK_VFileCopyFlags = [] ) : TK_VFileCopyResultCode;
function  K_VFCopyFile1( const SrcFName, DestFName : string;
                         AVFCFlags : TK_VFileCopyFlags = [];
                         APFSize : PInteger = nil ) : TK_VFileCopyResultCode;
procedure K_VFCopyDirFiles( const SrcVPathName, DstVPathName : string;
                            const ACreatePars : TK_DFCreateParams;
                            const NamePat : string = '*.*';
                            AVFCFlags : TK_VFileCopyFlags = [K_vfcRecurseSubfolders] );
function  K_VFDeleteFile( const FileName : string; ADeleteFileFlags : TK_DelOneFileFlags = [] ) : Boolean;
procedure K_VFDeleteDirFiles( const DirName : string;
                              const NamePat : string = '*.*';
                              DelFileFlags : TK_DelFolderFilesFlags = [K_dffRecurseSubfolders] );
function  K_VFRemoveDir( const DirName : string ) : Boolean;
function  K_VFSaveText0( const Text: string; var VFile: TK_VFile ) : Boolean;
function  K_VFSaveText( const AText: string; AVFileName: string;
                        const ACreatePars: TK_DFCreateParams ) : Boolean;
function  K_VFLoadText0( var Text: string; var VFile: TK_VFile ): Boolean;
function  K_VFLoadText( var Text: string; const AVFileName: string;
                        APCreateParams: TK_PDFCreateParams = nil;
                        const APassword : AnsiString = '' ): Boolean;
function  K_VFLoadText1( const AFileName : string; var AText : string;
                         out AErrCode : Integer ) : string;
function  K_VFLoadStrings ( AStrings: TStrings; const AVFileName: string;
                            APCreateParams: TK_PDFCreateParams = nil;
                            const APassword : AnsiString = '' ): Boolean;
function  K_VFLoadStrings1( const AFileName : string;
                                     AStrings : TStrings; out AErrCode : Integer ) : string;
function  K_VFSaveStrings( AStrings: TStrings; AVFileName: string;
                           const ACreatePars: TK_DFCreateParams ) : Boolean;
procedure K_VFCopyToTextFragmsFile( const TextFragmsFFName, SrcVPathName : string;
                                    const NamePat : string = '*.*';
                    AVFCFlags : TK_VFileCopyFlags = [K_vfcRecurseSubfolders] );
procedure K_VFCopyFromTextFragmsFile( const DestVPathName,
                                            TextFragmsFFName : string );
procedure K_CopyHTMLinkedVFiles( const HTMFile, DestPath : string;
                                 AVFCFlags : TK_VFileCopyFlags = [] );
function  K_PrepFileFromVFile( const FName: string ): string;
function  K_VFIfExpandedName( const AVFileName : string ) : Boolean;
function  K_VFExpandFileNameByDirPath( const PathName, FileName : string) : string;
function  K_VFExpandFileName( const FName : string ) : string;
procedure K_VFUDCursorPathDelimsPrep;
procedure K_VFUDCursorPathDelimsRestore;
function  K_VFLoadIntDataFromTextFile( const AFName : string; ASL : TStrings; APData : array of const ) : Boolean;
function  K_VFSaveIntDataToTextFile( const AFName : string; ASL : TStrings; AData : array of const ) : Boolean;

{
VF Path Agreements
| - is the the delimiter between external Windows file path and
    internal CBF objects tree path
Example
1) (#SPL#)syslib1.spl
where (#SPL#) is file path macro variable which value may be
  SPL=C:\Delphi_prj_new\K_MVDar\SPL\
or
  SPL=C:\Delphi_prj_new\K_MVDar\Data\CompoundFile.sdb|SPL\

Expanded file path  is
  C:\Delphi_prj_new\K_MVDar\Data\CompoundFile.sdb|SPL\

2) (#SPLFiles#)SPL\syslib1.spl
where (#SPL#) is file path macro variable which value may be
  SPLFiles=C:\Delphi_prj_new\K_MVDar\
or
  SPLFiles=C:\Delphi_prj_new\K_MVDar\Data\CompoundFile.sdb|

3) Virtual file name which can be use to access to already loaded
CBF (which Windows file name is CompoundFile.sdb) Object (Pure Internal Virtual File Name)
  |@:\Files\CompoundFile_sdb\SPL\syslib1_spl
}

//****************************************************
//*** end of Virtual Files Types, Variables and Procedures
//****************************************************

//***************** Compound Files Types and Procedures
{
function  K_MVCFileCreate   ( ADFileName: string; ): Integer;
}

//##/*
//##*/

var
  K_UBFilesAllocPath : string  = '(#TmpFiles#)'; // Path to Undo Files folder
  K_UBFNamePrefix    : string  = 'u'; // Undo files name prefix
  K_UBFNameSuffix    : string  = '';  // Undo files name suffix
  K_UBFilesCount     : Integer = 0;   // Undo files runtime counter


implementation

uses
  StrUtils, Math, Dialogs, Controls, HTTPApp,
  K_SParse1, K_parse, K_UDConst, K_UDC, K_DCSpace, K_VFunc,
  N_Lib2, N_CLassRef;

{
//********** TK_UDIter class methods  **************

//##path K_Delphi\SF\K_clib\K_UDT2.pas\Create
//******************************************************** TK_UDIter.Create ***
//
//
constructor TK_UDIter.Create( RootDirObj: TN_UDBase;
                AFlags : TK_UDIterFlagSet = [K_ifSkipEmpty];
                ASelectFilter : TK_UDFilter = nil;
                AStepDownFilter : TK_UDFilter = nil );
begin
  FSelectFilter := ASelectFilter;
  FStepDownFilter := AStepDownFilter;
  FFlags := AFlags;
  SetLength( Stack, 5 );
  UsedNodesList := TList.Create;
  InitRoot( RootDirObj );
end; // end_of constructor TK_UDIter.Create

//##path K_Delphi\SF\K_clib\K_UDT2.pas\Destroy
//******************************************************* TK_UDIter.Destroy ***
//
//
destructor TK_UDIter.Destroy;
begin
  Stack := nil;
  UsedNodesList.Free;
end; // end_of constructor TK_UDIter.Destroy

//##path K_Delphi\SF\K_clib\K_UDT2.pas\InitRoot
//****************************************************** TK_UDIter.InitRoot ***
//
//
procedure TK_UDIter.InitRoot( RootDirObj: TN_UDBase );
begin
  StackLevel := 0;
  Stack[0].Parent := RootDirObj;
  Stack[0].DirIndex := -1;
  UsedNodesList.Clear;
  UsedNodesList.Add( Pointer(RootDirObj) );
end; // end_of procedure TK_UDIter.InitRoot

//##path K_Delphi\SF\K_clib\K_UDT2.pas\StepToParent
//************************************************** TK_UDIter.StepToParent ***
//
//
function TK_UDIter.StepToParent( ) : Boolean;
begin
  Result := false;
  UsedNodesList.Delete(StackLevel);
  if StackLevel <= 0 then Exit;
  Dec(StackLevel);
  Result := true;
end; // end_of procedure TK_UDIter.StepToParent

//##path K_Delphi\SF\K_clib\K_UDT2.pas\GetNext
//******************************************************* TK_UDIter.GetNext ***
// get next UDBase object,
//
function TK_UDIter.GetNext( var DE : TN_DirEntryPar ) : Boolean;
var
  Ind: integer;
  NLeng : Integer;
  WDE : TN_DirEntryPar;
label Return;

begin
  Result := false;
  while Stack[StackLevel].Parent <> nil do
  begin
    Ind := Stack[StackLevel].DirIndex + 1;
    if (Ind <= Stack[StackLevel].Parent.DirHigh) and (Ind >= 0) then // cur level OK
    begin
      while true do
      begin
        Stack[StackLevel].Parent.GetDirEntry( Ind, Stack[StackLevel] );
        WDE := Stack[StackLevel];
        if (WDE.Child <> nil)              and
           (WDE.Child.DirHigh >= 0)        and
           ( not (K_ifSkipDown in FFlags)) and
           ((FStepDownFilter = nil) or FStepDownFilter.UDFTest(WDE)) and
           (UsedNodesList.IndexOf( WDE.Child ) = -1) then // go to one level Down
        begin
          UsedNodesList.Add( Pointer(WDE.Child) );
          Inc(StackLevel);
          NLeng := Length(Stack);
          if K_NewCapacity( StackLevel+1, NLeng ) then
            SetLength( Stack, NLeng );
          Stack[StackLevel].Parent := WDE.Child;
          Ind := 0;
        end else
          break;
      end;

Return :
      if ((K_ifSkipEmpty in FFlags)     and
          (WDE.Child = nil))
               or
         ((K_ifSkipChildRef in FFlags))  then Continue;

      if ((FSelectFilter <> nil) and
          (not FSelectFilter.UDFTest(WDE)))then Continue;
      Result := true;
      DE := WDE;
      Exit;
    end;

    //***** Here: no more childs at current StackLevel
    if not StepToParent then break; // all tree is scaned
    WDE := Stack[StackLevel];
    goto Return;
  end; // while True do
  if K_ifSkipRoot in FFlags then Exit;
  DE := Stack[StackLevel];
  DE.Child := DE.Parent;
end; // end_of function TK_UDIter.GetNext

//##path K_Delphi\SF\K_clib\K_UDT2.pas\GetNext1
//****************************************************** TK_UDIter.GetNext1 ***
// get next UDBase object,
//
function TK_UDIter.GetNext1( var DE : TN_DirEntryPar ) : Boolean;
var
  Ind: integer;
  NLeng : Integer;

label Return;

begin
  Result := false;
  while True do
  begin
    Ind := Stack[StackLevel].DirIndex + 1;

    if Ind = -1 then // return DirObj itself
    begin
      Stack[StackLevel].DirIndex := -1;
      Stack[StackLevel].Child := Stack[StackLevel].Parent;
      DE := Stack[StackLevel];
      goto Return;
    end else
    if Ind <= Stack[StackLevel].Parent.DirHigh then // cur level OK
    begin
      Stack[StackLevel].Parent.GetDirEntry( Ind, Stack[StackLevel] );
      DE := Stack[StackLevel];
      if (DE.Child <> nil)               and
         (DE.Child.DirHigh >= 0)         and
         ( not (K_ifSkipDown in FFlags)) and
         ((FStepDownFilter = nil) or FStepDownFilter.UDFTest(DE)) then // go to one level Down
      begin
        Inc(StackLevel);
        NLeng := Length(Stack);
        if K_NewCapacity( StackLevel+1, NLeng ) then
          SetLength( Stack, NLeng );
        Stack[StackLevel].Parent := DE.Child;
        Stack[StackLevel].DirIndex := -1;
      end;

Return :
      if ((K_ifSkipEmpty in FFlags)     and
          (DE.Child = nil))
               or
         ((K_ifSkipChildRef in FFlags))
               or
         ((FSelectFilter <> nil) and
          (not FSelectFilter.UDFTest(DE)))then Continue;
      Result := true;
      Exit;
    end;

    //***** Here: no more childs at current StackLevel

    if not StepToParent then Exit; // no more objects, Result = nil
  end; // while True do
end; // end_of function TK_UDIter.GetNext1
{}

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDFilterClassFlags\Create
//******************************************** TK_UDFilterClassFlags.Create ***
// IDB objects Filter Item TK_UDFilterClassFlags Special Class Constructor
//
//     Parameters
// FlagsValue - IDB objects ClassIndex Value for compare
// FlagsMask  - mask for selecting IDB objects ClassIndex bits to compare
// AExprCode  - logic operation which would be used by TK_UDFilter object to 
//              combine this Filter Item testing result with other Filter Items 
//              in general testing EXPRESSION
//
constructor TK_UDFilterClassFlags.Create( FlagsValue : LongWord; FlagsMask : LongWord = 0;
                AExprCode : TK_UDFilterItemExprCode = K_ifcOr);
begin
  inherited Create;
  FFlagsValue := FlagsValue;
  if FlagsMask = 0 then FlagsMask := FlagsValue;
  FFlagsMask := FlagsMask;
  ExprCode := AExprCode;
end; // end_of constructor TK_UDFilterItem.Create

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDFilterClassFlags\UDFITest
//****************************************** TK_UDFilterClassFlags.UDFITest ***
// IDB objects Filter Item testing function
//
//     Parameters
// DE     - IDB folder entry attributes
// Result - Returns TRUE if testing IDB object is satisfied Filter Item 
//          condition
//
function TK_UDFilterClassFlags.UDFITest( const DE : TN_DirEntryPar ) : Boolean;
var testFlags : LongWord;
begin
  Result := true;
  if (DE.Child = nil) then
    testFlags := 0
  else
    testFlags := (DE.Child.ClassFlags) and not $FF;

  if ((testFlags xor FFlagsValue) and FFlagsMask) <> 0 then
    Result := false;
end; // end_of function TK_UDFilterClassFlags.UDFITest

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDFilterClassSect\Create
//********************************************* TK_UDFilterClassSect.Create ***
// IDB objects Filter Item TK_UDFilterClassSect Special Class Constructor
//
//     Parameters
// AClassStart - ClassIndex start Value
// AClassFin   - ClassIndex final Value
// AExprCode   - logic operation which would be used by TK_UDFilter object to 
//               combine this Filter Item testing result with other Filter Items
//               in general testing EXPRESSION
//
constructor TK_UDFilterClassSect.Create( AClassStart : LongWord;
                        AClassFin : LongWord = 0;
                        AExprCode : TK_UDFilterItemExprCode = K_ifcOr );
begin
  inherited Create;
  ClassStart := AClassStart;
  if AClassFin = 0 then AClassFin := ClassStart;
  ClassFin := AClassFin;
  ExprCode := AExprCode;
end; // end_of constructor TK_UDFilterItem.Create

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDFilterClassSect\UDFITest
//******************************************* TK_UDFilterClassSect.UDFITest ***
// IDB objects Filter Item testing function
//
//     Parameters
// DE     - IDB folder entry attributes
// Result - Returns TRUE if testing IDB object is satisfied Filter Item 
//          condition
//
function TK_UDFilterClassSect.UDFITest( const DE : TN_DirEntryPar ) : Boolean;
var testFlags : LongWord;
begin
  Result := true;
//  if (DE.DataType = K_isChildRef) and
//     (DE.Child = nil) then Exit;
//  testFlags := (DE.Child.ClassFlags) and $FF;
  if (DE.Child = nil) then
    testFlags := 0
  else
    testFlags := (DE.Child.ClassFlags) and $FF;
  if (testFlags < ClassStart) or (testFlags > ClassFin) then
    Result := false;
end; // end_of function TK_UDFilterClassSect.UDFITest

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDFilterFuncTest\Create
//********************************************** TK_UDFilterFuncTest.Create ***
// IDB objects Filter Item TK_UDFilterFuncTest Special Class Constructor
//
//     Parameters
// ATestFunc - user defined test function
// AExprCode - logic operation which would be used by TK_UDFilter object to 
//             combine this Filter Item testing result with other Filter Items 
//             in general testing EXPRESSION
//
constructor TK_UDFilterFuncTest.Create( ATestFunc : TK_UDFilterTestFunc;
                        AExprCode : TK_UDFilterItemExprCode = K_ifcOr );
begin
  inherited Create;
  FTestFunc := ATestFunc;
  ExprCode := AExprCode;
end; // end_of constructor TK_UDFilterFuncTest.Create

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDFilterFuncTest\UDFITest
//******************************************** TK_UDFilterFuncTest.UDFITest ***
// IDB objects Filter Item testing function
//
//     Parameters
// DE     - IDB folder entry attributes
// Result - Returns TRUE if testing IDB object is satisfied Filter Item 
//          condition
//
function TK_UDFilterFuncTest.UDFITest( const DE : TN_DirEntryPar ) : Boolean;
begin
  Result := FTestFunc( DE);
end; // end_of function TK_UDFilterFuncTest.UDFITest

//********** TK_UDCursor class methods  **************

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor\Create
//****************************************************** TK_UDCursor.Create ***
// IDB Objects Tree Cursor Special Class Constructor
//
//     Parameters
// Name         - IDB Cursor name (is used as BasePath prefix in IDB Objects 
//                Paths)
// RootDirObj   - Cursor Root IDB Object - Base Object for relative IDB Paths 
//                interpretation
// AObjNameType - IDB Objects Path Segments contents type: Object Name or Object
//                Aliase
//
constructor TK_UDCursor.Create( const Name : string; RootDirObj: TN_UDBase;
                    AObjNameType : TK_UDObjNameType = K_ontObjName );
var NName : string;
Ind, i : Integer;
begin
  SetLength( Stack, 5 );
  SetRoot( RootDirObj );
  NName := Name;
  ObjNameType := AObjNameType;

  i := 0;
  while K_UDCursorsList.Find( NName, Ind ) do
  begin
    NName := Name + IntToStr( i );
    Inc(i);
  end;
  K_UDCursorsList.AddObject( NName, self );
end; // end_of constructor TK_UDCursor.Create

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor\Destroy
//***************************************************** TK_UDCursor.Destroy ***
// IDB Objects Tree Cursor Class Destructor
//
destructor TK_UDCursor.Destroy( );
begin
  Stack := nil;
  K_UDCursorsList.Delete( K_UDCursorsList.IndexOfObject( self ) );
end; // end_of constructor TK_UDCursor.Create

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor\SetRoot
//***************************************************** TK_UDCursor.SetRoot ***
// Set given IDB Object as Cursor Root
//
//     Parameters
// RootDirObj - Cursor Root IDB Object - Base Object for relative IDB Paths 
//              interpretation
//
procedure TK_UDCursor.SetRoot( RootDirObj: TN_UDBase );
begin
  K_clearDirEntry( Stack[0] );
  Stack[0].Child := RootDirObj;
  RootLevel := -1;
  StackLevel := -1;
  StepUp := true;
end; // end_of procedure TK_UDCursor.SetRoot

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor\GetRoot
//***************************************************** TK_UDCursor.GetRoot ***
// Get IDB Cursor Root Objects
//
//     Parameters
// Result - Returns IDB Cursor Root Object
//
function TK_UDCursor.GetRoot(  ) : TN_UDBase;
begin
  if RootLevel = StackLevel then
    Result := Stack[RootLevel+1].Child
  else // RootLevel < StackLevel
    Result := Stack[RootLevel+1].Parent;

end; // end_of procedure TK_UDCursor.GetRoot

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor\SetRootPath
//************************************************* TK_UDCursor.SetRootPath ***
// Set IDB Cursor Root Object by given IDB path
//
//     Parameters
// RootPath - IDB Path to Object which must be Cursor Root Object
// Result   - Returns IDB Cursor Root Object
//
function TK_UDCursor.SetRootPath( const RootPath : string = '' ) : boolean;
begin
  RootLevel := -1;
  Result := SetPath( RootPath );
  if Result then RootLevel := StackLevel;
end; // end_of procedure TK_UDCursor.SetRootPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor\GetRootPath
//************************************************* TK_UDCursor.GetRootPath ***
// Get IDB Cursor Root Object path
//
//     Parameters
// Result - Returns IDB Cursor Root Object Path
//
function TK_UDCursor.GetRootPath(  ) : string;
Var Rlevel, SLevel : Integer;
begin
  Rlevel := Rootlevel;
  SLevel := StackLevel;
  Rootlevel := -1;
  StackLevel := Rlevel;
  Result := GetPath( -MaxInt, 0 );
  Rootlevel := Rlevel;
  StackLevel := SLevel;
end; // end_of function TK_UDCursor.GetRootPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor\SetPath
//***************************************************** TK_UDCursor.SetPath ***
// Shift IDB Cursor along IBD Objects Tree by given IDB Path
//
//     Parameters
// Path   - given IDB Path for Cusor Shift along IDB Tree
// Result - Returns TRUE if given Path is proper IDB path
//
function TK_UDCursor.SetPath( const Path : string = '' ) : boolean;
var CLevel, NLeng : Integer;
CParent : TN_UDBase;
CName : string;

label FinLoop, LErrPath, StepNext;

  procedure SetLRoot;
  begin
    if RootLevel < 0 then
      SetRoot( GetRoot() )
    else
    begin
      StackLevel := RootLevel;
      Stack[StackLevel+1] := Stack[RootLevel];
    end;
    StepUp := true;
  end;

begin
  if Path <> '' then
    K_UDPathTokenizer.SetSource( Path );

  StepUp := false;
  if (K_UDPathTokenizer.Text <> '') and
     (K_UDPathTokenizer.CPos <= K_UDPathTokenizer.TLength) and
     (K_UDPathTokenizer.Text[K_UDPathTokenizer.CPos] = K_udpPathDelim) then
    SetLRoot;

  CLevel := StackLevel + 1;
  if CLevel > 0 then begin
    if CLevel >= Length(Stack) then
      SetLength( Stack, CLevel + 1 );
    Stack[CLevel] := Stack[StackLevel];
  end;

  Result := true;
  while K_UDPathTokenizer.hasMoreTokens do begin
    PathDonePos := K_UDPathTokenizer.cpos;
    if (PathDonePos > 1) and
       (K_UDPathTokenizer.Text[PathDonePos-1] = K_udpFieldDelim) then begin
      ErrPath := GetErrPath;
      break;
    end;

    CParent := Stack[CLevel].Child;

    CName := K_UDPathTokenizer.nextToken;

    if CName = K_udpStepUp then begin // step up
      StepUp := true;
      Dec( Clevel );
      if Clevel <= RootLevel then begin
        Inc( Clevel );
        goto LErrPath;
      end;
      if Clevel = RootLevel + 1 then begin
        SetLRoot( );
        continue;
      end else
        goto FinLoop;
    end;

    if (Stack[CLevel].Child = nil) then
      goto LErrPath; // current level has no Child

    if not CParent.GetDEByPathSegment( CName, Stack[CLevel], ObjNameType ) then begin
LErrPath:
      Result := false;
      break;
    end;

StepNext:
    Inc(Clevel);
    NLeng := Length(Stack);
    if K_NewCapacity( Clevel+1, NLeng ) then
      SetLength( Stack, NLeng );

FinLoop:
    Stack[Clevel] := Stack[CLevel-1];
  end; // end of while path loop

  StackLevel := Clevel - 1;
end; // end_of procedure TK_UDCursor.SetPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor\GetDE
//******************************************************* TK_UDCursor.GetDE ***
// Get IDB Tree folder entry attributes  by given DB Path
//
//     Parameters
// DE           - IDB folder entry attributes for Object defined by given Path
// Path         - IDB path of needed Object
// CurrentLevel - allows to get current Cursor level IDB folder entry attributes
//                instead of using IDB path
//
function TK_UDCursor.GetDE( out DE : TN_DirEntryPar; const Path : string = '';
                CurrentLevel : Boolean = false ) : boolean;
var
CPath : string;
CLevel : Integer;
TailText : string;
begin
  if CurrentLevel and (StackLevel >= 0) then begin
    Result := true;
    DE := Stack[StackLevel];
    Exit;
  end;

  CPath := GetPath;
  CLevel := StackLevel;
  Result := false;
  with K_UDPathTokenizer do
    TailText := Copy( Text, CPos, TLength );
//  if K_UDPathTokenizer.Text = K_udpPathDelim then begin
  if (K_UDPathTokenizer.Text = K_udpPathDelim) or
     (TailText = K_udpPathDelim)               or
     (TailText = '') then begin
    DE := Stack[RootLevel+1];
    Result := True;
  end else if SetPath( Path ) and
              (StackLevel >= 0)  then begin
    DE := Stack[StackLevel];
    Result := True;
  end;

  if not Result then begin
    PathDoneLevel := StackLevel + 1;
    DE := Stack[PathDoneLevel];
    ErrPath := GetErrPath;
  end;

  if StepUp then
    SetPath( CPath )
  else begin
    StackLevel := CLevel;
//    if Clevel = -1 then
    if (Clevel = -1) and (Stack[0].Parent <> nil) then // error while get not root path, but current path is root
      Stack[0].Child := Stack[0].Parent;
  end;
end; // end_of procedure TK_UDCursor.GetDE

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor\GetObj
//****************************************************** TK_UDCursor.GetObj ***
// Get IDB Tree Object by given DB Path
//
//     Parameters
// Path         - IDB path of needed Object
// CurrentLevel - allows to get current Cursor level IDB Object instead of using
//                IDB path
// Result       - Returns IDB Object defined by given Path
//
function TK_UDCursor.GetObj( const Path : string = '';
                CurrentLevel : Boolean = false ) : TN_UDBase;
var
DE : TN_DirEntryPar;
begin
  Result := nil;
  if GetDE( DE, Path, CurrentLevel ) then
  begin
    if (DE.Child <> nil) then
      Result := DE.Child;
  end;
end; // end_of procedure TK_UDCursor.GetObj

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor\GetPath
//***************************************************** TK_UDCursor.GetPath ***
// Get IDB Tree Object relative Path using Cursor stack segment
//
//     Parameters
// SLevel - start Cursor Stack level
// FLevel - final Cursor Stack level
// Result - Returns IDB relative Path
//
// Do not call GetPath directly, it is used automatically in some TK_UDCursor 
// methods.
//
function TK_UDCursor.GetPath( SLevel : Integer = -MaxInt; FLevel : Integer = 0 ) : string;
var i, Sind, Find : Integer;
begin
  if SLevel > 0 then
    Sind := SLevel
  else
    Sind := StackLevel + SLevel;
  Sind := Min(StackLevel, Sind);
  Sind := Max(RootLevel, Sind);
  if Sind <= RootLevel then
  begin
    Sind := RootLevel+1;
    Result := K_udpPathDelim;
  end else
    Result := '';

  if FLevel > 0 then
    Find := Min(StackLevel, FLevel)
  else
    Find := StackLevel + FLevel;
  Find := Max(RootLevel, Find);

  for i := Sind to Find do
    Result := Result + K_BuildPathSegmentByDE( Stack[i], ObjNameType ) + K_udpPathDelim;
end; // end_of procedure TK_UDCursor.GetPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor\IncludeCursorName
//******************************************* TK_UDCursor.IncludeCursorName ***
// Include Cursor name to given IDB relative Path
//
//     Parameters
// Path   - IDB relative Path
// Result - Returns IDB absolute Path
//
// Given Path must be really relative. Method does not control given Path 
// relativity.
//
function TK_UDCursor.IncludeCursorName( const Path : string ) : string;
begin
  Result := GetName + K_udpCursorDelim + Path;
end; // end_of procedure TK_UDCursor.GetGPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor\GetErrPath
//************************************************** TK_UDCursor.GetErrPath ***
// Get error Path substring which couldn't be done by GetObj or GetDE methods
//
//     Parameters
// Result - Returns Cursor error Path substring, which contains path tail 
//          starting from the Segment in error was detected
//
function TK_UDCursor.GetErrPath(  ) : string;
begin
  Result := Copy( K_UDPathTokenizer.Text, PathDonePos,
                        K_UDPathTokenizer.TLength - PathDonePos + 1 );
end; // end_of procedure TK_UDCursor.GetErrPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor\GetName
//***************************************************** TK_UDCursor.GetName ***
// Get Cursor name
//
//     Parameters
// Result - Returns Cursor name
//
function TK_UDCursor.GetName(  ) : string;
begin
  Result := K_UDCursorsList.Strings[K_UDCursorsList.IndexOfObject(self)];
end; // end_of procedure TK_UDCursor.GetGPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDCursor\GetObjPath
//************************************************** TK_UDCursor.GetObjPath ***
// Get IDB relative path to Object using as base root Cursor current Object
//
//     Parameters
// Obj    - Object path to which is needed to calculate
// Result - Returns Cursor name
//
function TK_UDCursor.GetObjPath( Obj : TN_UDBase ) : string;
begin

//  if (Length(Stack) = 0) or (StackLevel < 0) or (Stack[StackLevel].Child = nil) then
  if (Length(Stack) = 0) or (StackLevel < 0) then
    Result := ''
  else
//    Result := Stack[StackLevel].Child.GetPathToObj( Obj, ObjNameType  );
    Result := K_GetPathToUObj( Obj, Stack[StackLevel].Child, ObjNameType );
end; // end_of procedure GetObjPath

{
//******************************************** GetDEPath ***
//
function TK_UDCursor.GetDEPath( const DE : TN_DirEntryPar ) : string;
begin
  Result := Stack[StackLevel].Child.GetPathToDE( DE, ObjNameType );
end; // end_of procedure GetDEPath
}

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDRef\Create
//********************************************************* TK_UDRef.Create ***
//
constructor TK_UDRef.Create(  );
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDRefCI;
  ImgInd := 49;
end;

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDRef\Destroy
//******************************************************** TK_UDRef.Destroy ***
//
//
destructor TK_UDRef.Destroy( );
begin
  inherited Destroy;
end;

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDRef\AddFieldsToSBuf
//************************************************ TK_UDRef.AddFieldsToSBuf ***
// Save self fields to given serial binary buffer (inherited from TN_UDBase)
//
//     Parameters
// SBuf - serial binary buffer
//
procedure TK_UDRef.AddFieldsToSBuf   ( SBuf: TN_SerialBuf );
begin
  inherited;
  SBuf.AddRowString( RefPath );
end;

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDRef\GetFieldsFromSBuf
//********************************************** TK_UDRef.GetFieldsFromSBuf ***
// Load self fields from given serial binary buffer (inherited from TN_UDBase)
//
//     Parameters
// SBuf - serial binary buffer
//
procedure TK_UDRef.GetFieldsFromSBuf ( SBuf: TN_SerialBuf );
begin
  inherited;
  SBuf.GetRowString( RefPath );
  ObjName := ExtractFileName( RefPath );
end;

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDRef\AddFieldsToText
//************************************************ TK_UDRef.AddFieldsToText ***
// Save self fields to given serial text buffer (inherited from TN_UDBase)
//
//     Parameters
// SBuf - serial text buffer
//
function  TK_UDRef.AddFieldsToText( SBuf: TK_SerialTextBuf;
                                 AShowFlags : Boolean = true ) : Boolean;
begin
  AddMetaFieldsToText(SBuf, false);
  if (K_txtSkipCloseTagName in K_TextModeFlags) then
    SBuf.AddTagAttr( K_tbObjRefChildPath, RefPath )
  else
    SBuf.AddScalar( RefPath );
//  SBuf.ShiftLinePos(-1);
  Result := false;
end;

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDRef\GetFieldsFromText
//********************************************** TK_UDRef.GetFieldsFromText ***
// Load self fields from given text binary buffer (inherited from TN_UDBase)
//
//     Parameters
// SBuf - serial text buffer
//
function  TK_UDRef.GetFieldsFromText ( SBuf: TK_SerialTextBuf ) : Integer;
begin
  GetMetaFieldsFromText(SBuf);
  SBuf.GetTagAttr( K_tbObjRefChildPath, RefPath );
  if RefPath = '' then
    SBuf.GetScalar( RefPath );
  ObjName := ExtractFileName( RefPath );
  Result := -1;
end;

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDRef\CopyFields
//***************************************************** TK_UDRef.CopyFields ***
// Copy fields from given source Object to self fields (inherited from 
// TN_UDBase)
//
//     Parameters
// SrcObj - source Object
//
procedure TK_UDRef.CopyFields ( SrcObj: TN_UDBase );
begin
  if SrcObj = nil then Exit; // a precaution
  inherited;
  RefPath := TK_UDRef(SrcObj).RefPath;
end;

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_UDRef\GetRefObject
//*************************************************** TK_UDRef.GetRefObject ***
// Get referenced Object
//
//     Parameters
// Result - Returns reference to Object using IDB path stored Self.RefPath 
//          field.
//
// If referenced Object exists then Self.Delete method would be call. Do not 
// call GetRefObject directly, it is called automatically in IDB Objects Tree 
// recovery routines.
//
function TK_UDRef.GetRefObject() : TN_UDBase;
begin
  Result := K_UDCursorGetObj( RefPath );
  if (Result = nil) or (Result = Self) then begin
    Result := Self;
    Self.RefIndex := 0;
  end else
    UDDelete;
end;

//********************************** end of TK_UDRef class methods ***

{*** TK_ScanUDSubTree ***}

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\Create
//************************************************* TK_ScanUDSubTree.Create ***
//
//
constructor TK_ScanUDSubTree.Create;
begin
  inherited;
  RefNodes0 := TList.Create;
  RefNodes1 := TList.Create;
  RefLPaths := TK_TStringsList.Create;
  SL        := TStringList.Create;
end; // end of TK_ScanUDSubTree.Create

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\Destroy
//************************************************ TK_ScanUDSubTree.Destroy ***
//
//
destructor TK_ScanUDSubTree.Destroy;
begin
  RefNodes0.Free;
  RefNodes1.Free;
  RefLPaths.Free;
  SL.Free;
  inherited;
end; // end of TK_ScanUDSubTree.Destroy

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\IniLists
//*********************************************** TK_ScanUDSubTree.IniLists ***
// Initialise data. Is called automatically while examination of IDB Objects 
// Subtrees is started
//
procedure TK_ScanUDSubTree.IniLists;
begin
  RefNodes0.Clear;
  RefNodes0.Clear;
  RefLPaths.Clear;
  SL.Clear;
end; // end of TK_ScanUDSubTree.IniLists

//************************************************
//*** Build List of Subtree Entry Nodes and List of Subtree External Nodes
//************************************************

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\BuildEERefNodesLists
//*********************************** TK_ScanUDSubTree.BuildEERefNodesLists ***
// Search for given IDB Subtree Entry Objects and External Objects
//
//     Parameters
// UDRoot            - given Subtree Root Object
// SkipEntryRefNodes - skip Entry Nodes processing flag
//
// Resulting data is placed in the following Self properties:
//#F
//  ParentNodes  - list of Subtree Parents to External Objects
//  ParentLPaths - list of relative Paths from Subtree Parent Objects to External Objects
//  EntryNodes   - list of Subtree Entry Objects
//
// External Objects - Objects that are not members of given Subtree (outside
//                    Objects) but references to which are from the Subtree
//                    Objects-members (inside Objects)
// Entry Objects    - Objects that are members of given Subtree (inside Objects)
//                    and references to which are from the External Objects
//#/F
//
procedure TK_ScanUDSubTree.BuildEERefNodesLists( UDRoot : TN_UDBase; SkipEntryRefNodes : Boolean = false );
begin
  IniLists;
  CurTestRoot := UDRoot;

  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsOwnerChildsOnlyScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan];
  UDRoot.MarkSubTree( -1 );
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsOwnerChildsOnlyScan];

  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsSkipOwnerChildsSubTreeScan];
  UDRoot.ScanSubTree( BuildExtRefNodesListScan );
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsSkipOwnerChildsSubTreeScan];

  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsOwnerChildsOnlyScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan];
  if not SkipEntryRefNodes then
    UDRoot.ScanSubTree( BuildEntryRefNodesListScan );

  UDRoot.UnMarkSubTree();
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsOwnerChildsOnlyScan];

end; // end of TK_ScanUDSubTree.BuildEERefNodesLists

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\BuildExtRefNodesListScan
//******************************* TK_ScanUDSubTree.BuildExtRefNodesListScan ***
// Scanning IBD Object routine
//
// Used in Self.BuildEERefNodesLists Subtree for External References search 
// during tree-walk
//
function TK_ScanUDSubTree.BuildExtRefNodesListScan(UDParent : TN_UDBase; var UDChild : TN_UDBase;
  ChildInd, ChildLevel: Integer; const FieldName: string): TK_ScanTreeResult;
var
  i : Integer;
  LPath : string;
begin
  Result := K_tucOK;
  if (UDChild.Marker > 0) then begin
//*** Internal Node
    if (ChildInd = -1) or (UDChild.Owner <> UDParent) then
      Inc(UDChild.Marker); // Inc Internal References Counter
{
    if (ChildInd = -1) or (UDChild.Owner <> UDParent) then begin
      Inc(UDChild.Marker); // Inc Internal References Counter
      Result := K_tucSkipSubTree;
    end else
      Result := K_tucOK;
}
  end else begin
//*** External Node
    i := ParentNodes.IndexOf(UDParent);
    if i = -1 then
      ParentNodes.Add(UDParent);
    if ChildInd = -1 then
      LPath := K_sccVarFieldDelim + FieldName
    else
      LPath := K_udpPathDelim + K_udpDEIndexDelim + IntToStr(ChildInd);
//    ExtRefLPaths.AddString(i, LPath);
    ParentLPaths.AddObject(i, LPath, UDChild);
//    Result := K_tucSkipSubTree;
  end;
end; // end of TK_ScanUDSubTree.BuildExtRefNodesListScan

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\BuildEntryRefNodesListScan
//***************************** TK_ScanUDSubTree.BuildEntryRefNodesListScan ***
// Scanning IBD Object routine
//
// Used in Self.BuildEERefNodesLists for Entries search during tree-walk
//
function TK_ScanUDSubTree.BuildEntryRefNodesListScan(UDParent : TN_UDBase; var UDChild : TN_UDBase;
  ChildInd, ChildLevel: Integer; const FieldName: string): TK_ScanTreeResult;
begin
//  Result := K_tucSkipSubTree;
//  if (UDChild = CurTestRoot) or
//     (UDChild.Marker <= 0 ) then Exit;
//*** Internal Node
  if (UDChild.Marker < UDChild.RefCounter) and
     (EntryNodes.IndexOf(UDChild) = -1) then
    EntryNodes.Add(UDChild);
  Result := K_tucOK;
end; // end of TK_ScanUDSubTree.BuildEntryRefNodesListScan

//*** end of Build List of SubTree Entry Nodes and List of SubTree External Nodes

//************************************************
//*** Build List of SubTree Nodes which are parents to specified child Node
//************************************************

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\BuildParentsList
//*************************************** TK_ScanUDSubTree.BuildParentsList ***
// Search for references to given Object in given IDB Subtree
//
//     Parameters
// UDRoot                 - IDB Subtree Root Object
// UDChild                - IDB Object references to which needed to find
// AUDTreeChildsScanFlags - control IDB tree-walk flags
//
// Resulting data is placed in the following Self properties:
//#F
//  ParentNodes  - list of Subtree Parents to Specified Child Object
//  ParentLPaths - list of Local Paths from Subtree Parents to Specified Child Object
//#/F
//
procedure TK_ScanUDSubTree.BuildParentsList( UDRoot,  UDChild: TN_UDBase;
                          AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags );
var
  WUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags;
begin
  IniLists;
  CurTestRoot := UDRoot;
  CurTestChild := UDChild;

  WUDTreeChildsScanFlags := K_UDTreeChildsScanFlags;
  K_UDTreeChildsScanFlags := AUDTreeChildsScanFlags;

  if not (K_udtsOwnerChildsOnlyScan in K_UDTreeChildsScanFlags) then
    K_UDScannedUObjsList := TList.Create;

  if UDChild = nil then
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsEmptyChildsScan]
  else
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsEmptyChildsScan];

  UDRoot.ScanSubTree( BuildParentsListScan );

  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsEmptyChildsScan];

  if K_UDScannedUObjsList <> nil then
    K_ClearUObjsScannedFlag();

  UDRoot.UnMarkSubTree();

  if K_UDScannedUObjsList <> nil then
    K_ClearUObjsScannedFlag();
  FreeAndNil(K_UDScannedUObjsList);

  K_UDTreeChildsScanFlags := WUDTreeChildsScanFlags;

end; // end of TK_ScanUDSubTree.BuildParentsList

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\BuildParentsListScan
//*********************************** TK_ScanUDSubTree.BuildParentsListScan ***
// Scanning IBD Object routine
//
// Used in Self.BuildParentsList for scanning IBD Objects during tree-walk
//
function TK_ScanUDSubTree.BuildParentsListScan( UDParent: TN_UDBase;
                 var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
                 const FieldName: string ): TK_ScanTreeResult;
var
  i : Integer;
  LPath : string;
begin
//*** Test Child
  Result := K_tucOK;
  if UDChild = CurTestChild then begin
    i := ParentNodes.IndexOf(UDParent);
    if i = -1 then
      ParentNodes.Add(UDParent);
    if ChildInd = -1 then
      LPath := K_sccVarFieldDelim + FieldName
    else
      LPath := K_udpPathDelim + K_udpDEIndexDelim + IntToStr(ChildInd);
    ParentLPaths.AddObject(i, LPath, UDChild);
  end;
//*** end of Child Testing
end; // end of TK_ScanUDSubTree.BuildParentsListScan

//*** end of Build List of Subtree Nodes which are parents to specified child Node

//************************************************
//*** Build List of Node Child References
//************************************************

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\BuildNodeRefsList
//************************************** TK_ScanUDSubTree.BuildNodeRefsList ***
// Search for Child Objects in given IDB Parent Object
//
//     Parameters
// UDParent               - IDB Parent Object
// AUDTreeChildsScanFlags - control IDB tree-walk flags
//
// Resulting data is placed in the following Self properties:
//#F
//  RefNodes  - list of Parent IDB Object Childs
//  RefLPaths - list of Local Paths to Parent IDB Object Childs
//#/F
//
procedure TK_ScanUDSubTree.BuildNodeRefsList( UDParent: TN_UDBase;
                             AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags );
var
  WUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags;
begin
  IniLists;
  CurTestRoot := UDParent;

  WUDTreeChildsScanFlags := K_UDTreeChildsScanFlags;
  K_UDTreeChildsScanFlags := AUDTreeChildsScanFlags;

  UDParent.ScanSubTree( BuildNodeRefsListScan );

  K_UDTreeChildsScanFlags := WUDTreeChildsScanFlags;
end; // end of TK_ScanUDSubTree.BuildNodeRefsList

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\BuildNodeRefsListScan
//********************************** TK_ScanUDSubTree.BuildNodeRefsListScan ***
// Scanning IBD Object routine
//
// Used in Self.BuildNodeRefsList for scanning IBD Objects during tree-walk
//
function TK_ScanUDSubTree.BuildNodeRefsListScan( UDParent: TN_UDBase;
  var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
  const FieldName: string): TK_ScanTreeResult;
var
  i : Integer;
  LPath : string;
begin
  Result := K_tucSkipSubTree;
  i := RefNodes.IndexOf(UDChild);
  if i = -1 then
    RefNodes.Add(UDChild);
  if ChildInd = -1 then
    LPath := K_sccVarFieldDelim + FieldName
  else
    LPath := K_udpPathDelim + K_udpDEIndexDelim + IntToStr(ChildInd);
  RefLPaths.AddString(i, LPath);
end; // end of TK_ScanUDSubTree.BuildNodeRefsListScan

//*** end of Build List of Node Child References

//************************************************
//*** Build List of Subtree Parents to TK_UDRef Nodes
//************************************************

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\BuildUDRefParentsList
//********************************** TK_ScanUDSubTree.BuildUDRefParentsList ***
// Search for IDB Objects which have Childs of TK_UDRef type
//
//     Parameters
// UDParent               - IDB Subtree Root Object
// AUDTreeChildsScanFlags - control IDB tree-walk flags
//
// Resulting data is placed in the following Self properties:
//#F
//  ParentNodes  - list of Subtree Parents to TK_UDRef Objects
//  ParentLPaths - list of relative Paths from Subtree Parents to TK_UDRef Objects
//  UniqRefs     - list of TK_UDRef Objects with uniq references to "real" IDB Objects
//#/F
//
// Objects of TK_UDRef type could remain in IDB Subtrees in some involved cases 
// if needed "real" Objects are not found during IDB Subtree recovery after 
// deserialization. BuildUDRefParentsList helps to found this "vice-Objects" 
// hidden in given IDB Subtree.
//
procedure TK_ScanUDSubTree.BuildUDRefParentsList( UDRoot : TN_UDBase;
                            AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags );
var
  WUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags;
begin
  IniLists;

  CurTestRoot := UDRoot;

  WUDTreeChildsScanFlags := K_UDTreeChildsScanFlags;
  K_UDTreeChildsScanFlags := AUDTreeChildsScanFlags;


  if not (K_udtsOwnerChildsOnlyScan in K_UDTreeChildsScanFlags) then
    K_UDScannedUObjsList := TList.Create;

  SL.Sorted := true;

  UDRoot.ScanSubTree( BuildUDRefParentsListScan );

  SL.Sorted := false;

  if K_UDScannedUObjsList <> nil then
    K_ClearUObjsScannedFlag();

  FreeAndNil(K_UDScannedUObjsList);

  K_UDTreeChildsScanFlags := WUDTreeChildsScanFlags;

end; // end of TK_ScanUDSubTree.BuildUDRefParentsList

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\BuildUDRefParentsListScan
//****************************** TK_ScanUDSubTree.BuildUDRefParentsListScan ***
// Scanning IBD Object routine
//
// Used in Self.BuildUDRefParentsList for scanning IBD Objects during tree-walk
//
function TK_ScanUDSubTree.BuildUDRefParentsListScan(UDParent: TN_UDBase;
  var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
  const FieldName: string): TK_ScanTreeResult;
var
  i : Integer;
  LPath : string;
begin
  Result := K_tucOK;
//*** Test Child
  if (UDChild.CI = K_UDRefCI) then begin
    i := ParentNodes.IndexOf(UDParent);
    if i = -1 then
      ParentNodes.Add(UDParent);
    if ChildInd = -1 then begin
      LPath := K_sccVarFieldDelim + FieldName;
      Result := K_tucSkipSubTree;
    end else
      LPath := K_udpPathDelim + K_udpDEIndexDelim + IntToStr(ChildInd);
    if SL.IndexOf( UDChild.RefPath ) = -1 then begin
      SL.Add( UDChild.RefPath );
      UniqRefs.Add( UDChild );
    end;
    ParentLPaths.AddObject(i, LPath, UDChild );
  end;
//*** end of Child Testing
end; // end of TK_ScanUDSubTree.BuildUDRefParentsListScan

//*** end of Build List of Subtree TK_UDRef Nodes

//************************************************
//*** Build List of Subtree Nodes which have Lost Owners
//************************************************

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\BuildUDOwnerLostParentsList
//**************************** TK_ScanUDSubTree.BuildUDOwnerLostParentsList ***
// Search for IDB Objects which have lost reference to its Owner Object
//
//     Parameters
// UDParent               - IDB Subtree Root Object
// AUDTreeChildsScanFlags - control IDB tree-walk flags
//
// Resulting data is placed in the following Self properties:
//#F
//  ParentNodes  - list of IDB Subtree Parents to Objects which have lost Owner reference
//  ParentLPaths - list of relative Paths from IDB Subtree Parents to Objects which have lost Owner reference
//  UniqRefs     - list of Objects which have lost Owner reference
//#/F
//
procedure TK_ScanUDSubTree.BuildUDOwnerLostParentsList(UDRoot: TN_UDBase;
                            AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags);
var
  WUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags;
begin
  IniLists;

  CurTestRoot := UDRoot;

  WUDTreeChildsScanFlags := K_UDTreeChildsScanFlags;
  K_UDTreeChildsScanFlags := AUDTreeChildsScanFlags;

  if not (K_udtsOwnerChildsOnlyScan in K_UDTreeChildsScanFlags) then
    K_UDScannedUObjsList := TList.Create;


  UDRoot.ScanSubTree( BuildUDOwnerLostParentsListScan );

  if K_UDScannedUObjsList <> nil then
    K_ClearUObjsScannedFlag();

  FreeAndNil(K_UDScannedUObjsList);

  K_UDTreeChildsScanFlags := WUDTreeChildsScanFlags;

end; // end of TK_ScanUDSubTree.BuildUDOwnerLostParentsList

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\BuildUDOwnerLostParentsListScan
//************************ TK_ScanUDSubTree.BuildUDOwnerLostParentsListScan ***
// Scanning IBD Object routine
//
// Used in Self.BuildUDOwnerLostParentsList for scanning IBD Objects during 
// tree-walk
//
function TK_ScanUDSubTree.BuildUDOwnerLostParentsListScan(UDParent: TN_UDBase;
  var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
  const FieldName: string): TK_ScanTreeResult;
var
  i : Integer;
begin
  Result := K_tucOK;
//*** Test Child
  if (ChildInd <> -1) or (UDChild.Owner <> nil) then Exit;
  Result := K_tucSkipSubTree;
  i := ParentNodes.IndexOf(UDParent);
  if i = -1 then
    ParentNodes.Add(UDParent);
  if UniqRefs.IndexOf( UDChild ) = -1 then
    UniqRefs.Add( UDChild );
  ParentLPaths.AddObject(i, K_sccVarFieldDelim + FieldName, UDChild);
//*** end of Child Testing
end; // end of TK_ScanUDSubTree.BuildUDOwnerLostParentsListScan

//*** end of Build List of SubTree Nodes which have Lost

//************************************************
//*** Build List of Subtree Nodes which have Specified Type
//************************************************

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\BuildUDNodesByTypeList
//********************************* TK_ScanUDSubTree.BuildUDNodesByTypeList ***
// Search for IDB Objects of given Pascal Type and User Data Type
//
//     Parameters
// UDParent               - IDB Subtree Root Object
// ANodesCIs              - list of TN_UDBase descendants Type Codes (Pascal 
//                          Types)
// ANodesRASTypes         - list of TK_UDRArray User Data Type Codes
// AUDTreeChildsScanFlags - control IDB tree-walk flags
//
// Resulting data is placed in the Self.Nodes property - list of Found Objects 
// which have given Pascal Type and User Data Type. If list of TN_UDBase 
// descendants Type Codes (Pascal Types) is not given then any Pascal type of 
// IDB Object is proper. If list of of TK_UDRArray User Data Type Codes is not 
// given then any IDB Object with proper Pascal type will be places to resulting
// list. So if ANodesCIs and ANodesRASTypes are not given then all IDB Subtre 
// objects will be places to resulting list.
//
procedure TK_ScanUDSubTree.BuildUDNodesByTypeList( UDRoot : TN_UDBase;
                               ANodesCIs, ANodesRASTypes : TList;
                               AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags );
var
  WUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags;
begin
  IniLists;

  CurTestRoot := UDRoot;
  NodesCIs := ANodesCIs;
  NodesRASTypes := ANodesRASTypes;

  WUDTreeChildsScanFlags := K_UDTreeChildsScanFlags;
  K_UDTreeChildsScanFlags := AUDTreeChildsScanFlags;


  if not (K_udtsOwnerChildsOnlyScan in K_UDTreeChildsScanFlags) then
    K_UDScannedUObjsList := TList.Create;

  UDRoot.ScanSubTree( BuildUDNodesByTypeListScan );

  if K_UDScannedUObjsList <> nil then
    K_ClearUObjsScannedFlag();
  FreeAndNil(K_UDScannedUObjsList);

  K_UDTreeChildsScanFlags := WUDTreeChildsScanFlags;

end; // end of TK_ScanUDSubTree.BuildUDNodesByTypeList

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\BuildUDNodesByTypeListScan
//***************************** TK_ScanUDSubTree.BuildUDNodesByTypeListScan ***
// Scanning IBD Object routine
//
// Used in Self.BuildUDNodesByTypeList for scanning IBD Objects during tree-walk
//
function TK_ScanUDSubTree.BuildUDNodesByTypeListScan(UDParent: TN_UDBase;
  var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
  const FieldName: string): TK_ScanTreeResult;
begin
  Result := K_tucOK;
  if (NodesCIs <> nil) and
     (NodesCIs.IndexOf( Pointer(UDChild.CI) ) = -1) then Exit;
  if K_IsUDRArray(UDChild) and
     (NodesRASTypes <> nil)                         and
     (NodesRASTypes.IndexOf( TK_UDRArray(UDChild).R.ArrayType.FD ) = -1) then Exit;
  if Nodes.IndexOf(UDChild) = -1 then Nodes.Add(UDChild);
end; // end of TK_ScanUDSubTree.BuildUDNodesByTypeListScan

//*** end of Build List of Subtree Nodes which have Specified Type

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\ChangeNodesCheckedState
//******************************** TK_ScanUDSubTree.ChangeNodesCheckedState ***
// Search for IDB Objects of given Pascal Type and User Data Type
//
//     Parameters
// UDParent               - IDB Subtree Root Object
// AChangeMode            - change checked state mode: =-1 clear, =1 set, =0 
//                          toggle
// AUDTreeChildsScanFlags - control IDB tree-walk flags
//
// Change IDB Objects checked state and put Nodes with checked state to 
// resulting Nodes List
//
procedure TK_ScanUDSubTree.ChangeNodesCheckedState(UDRoot: TN_UDBase; AChangeMode: Integer;
          AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags = [K_udtsOwnerChildsOnlyScan]);
var
  WUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags;
begin
  IniLists;

  ScanMode := AChangeMode;
  WUDTreeChildsScanFlags := K_UDTreeChildsScanFlags;
  K_UDTreeChildsScanFlags := AUDTreeChildsScanFlags;


  if not (K_udtsOwnerChildsOnlyScan in K_UDTreeChildsScanFlags) then
    K_UDScannedUObjsList := TList.Create;

  ChangeNodesCheckedStateScan( UDRoot.Owner, UDRoot, -1, -1, '' );
  UDRoot.ScanSubTree( ChangeNodesCheckedStateScan );

  if K_UDScannedUObjsList <> nil then
    K_ClearUObjsScannedFlag();
  FreeAndNil(K_UDScannedUObjsList);

  K_UDTreeChildsScanFlags := WUDTreeChildsScanFlags;

end; // procedure TK_ScanUDSubTree.ChangeNodesCheckedState

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\ChangeNodesCheckedStateScan
//**************************** TK_ScanUDSubTree.ChangeNodesCheckedStateScan ***
// Scanning IBD Object routine
//
// Used in Self.ChangeNodesCheckedState for scanning IBD Objects during 
// tree-walk
//
function TK_ScanUDSubTree.ChangeNodesCheckedStateScan(UDParent: TN_UDBase;
  var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
  const FieldName: string): TK_ScanTreeResult;
var
  ChangePrevState : Boolean;
begin
  Result := K_tucOK;
  ChangePrevState := (UDChild.ObjFlags and K_fpObjTVChecked) <> 0;
  if (UDChild.ObjFlags and K_fpObjTVAutoCheck) = 0 then Exit;
  case ScanMode of
  -1: begin
      if not ChangePrevState then ChangePrevState := TRUE;
      UDChild.ObjFlags := UDChild.ObjFlags and not K_fpObjTVChecked;
    end;
   0: begin
      ChangePrevState := TRUE;
      UDChild.ObjFlags := UDChild.ObjFlags xor K_fpObjTVChecked;
    end;
   1: begin
      if not ChangePrevState then ChangePrevState := TRUE;
      UDChild.ObjFlags := UDChild.ObjFlags or K_fpObjTVChecked;
    end;
  end;
  // RebuildVnodes
  if ChangePrevState then
    UDChild.RebuildVNodes();

  if (UDChild.ObjFlags and K_fpObjTVChecked) <> 0 then
    if Nodes.IndexOf(UDChild) = -1 then Nodes.Add(UDChild);
end; // function TK_ScanUDSubTree.ChangeNodesCheckedStateScan

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\ChangeNodesDisabledState
//******************************* TK_ScanUDSubTree.ChangeNodesDisabledState ***
// Search for IDB Objects of given Pascal Type and User Data Type
//
//     Parameters
// UDParent               - IDB Subtree Root Object
// AChangeMode            - change checked state mode: =-1 clear, =1 set, =0 
//                          toggle
// AUDTreeChildsScanFlags - control IDB tree-walk flags
//
// Change IDB Objects enabled state and put Nodes with enabled state to 
// resulting Nodes List
//
procedure TK_ScanUDSubTree.ChangeNodesDisabledState(UDRoot: TN_UDBase; AChangeMode: Integer;
          AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags = [K_udtsOwnerChildsOnlyScan]);
var
  WUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags;
begin
  IniLists;

  ScanMode := AChangeMode;
  WUDTreeChildsScanFlags := K_UDTreeChildsScanFlags;
  K_UDTreeChildsScanFlags := AUDTreeChildsScanFlags;


  if not (K_udtsOwnerChildsOnlyScan in K_UDTreeChildsScanFlags) then
    K_UDScannedUObjsList := TList.Create;

  ChangeNodesDisabledStateScan( UDRoot.Owner, UDRoot, -1, -1, '' );
  UDRoot.ScanSubTree( ChangeNodesDisabledStateScan );

  if K_UDScannedUObjsList <> nil then
    K_ClearUObjsScannedFlag();
  FreeAndNil(K_UDScannedUObjsList);

  K_UDTreeChildsScanFlags := WUDTreeChildsScanFlags;

end; // procedure TK_ScanUDSubTree.ChangeNodesDisabledState

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ScanUDSubTree\ChangeNodesDisabledStateScan
//*************************** TK_ScanUDSubTree.ChangeNodesDisabledStateScan ***
// Scanning IBD Object routine
//
// Used in Self.ChangeNodesDisabledState for scanning IBD Objects during 
// tree-walk
//
function TK_ScanUDSubTree.ChangeNodesDisabledStateScan(UDParent: TN_UDBase;
  var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
  const FieldName: string): TK_ScanTreeResult;
var
  ChangePrevState : Boolean;
begin
  Result := K_tucOK;
  ChangePrevState := (UDChild.ObjFlags and K_fpObjTVDisabled) <> 0;
  if (UDChild.ObjFlags and K_fpObjTVAutoCheck) = 0 then Exit;
  case ScanMode of
  -1: begin
      if ChangePrevState then ChangePrevState := TRUE;
      UDChild.ObjFlags := UDChild.ObjFlags and not K_fpObjTVDisabled;
    end;
   0: begin
      ChangePrevState := TRUE;
      UDChild.ObjFlags := UDChild.ObjFlags xor K_fpObjTVDisabled;
    end;
   1: begin
      if not ChangePrevState then ChangePrevState := TRUE;
      UDChild.ObjFlags := UDChild.ObjFlags or K_fpObjTVDisabled;
    end;
  end;
  // RebuildVnodes
  if ChangePrevState then
    UDChild.RebuildVNodes();

  if (UDChild.ObjFlags and K_fpObjTVDisabled) <> 0 then
    if Nodes.IndexOf(UDChild) = -1 then Nodes.Add(UDChild);
end; // function TK_ScanUDSubTree.ChangeNodesDisabledStateScan

{*** end of TK_ScanUDSubTree ***}

{*** TK_BuildUDVCSSRefs ***}
{
procedure TK_BuildUDVCSSRefs.BuildRefs(UDRoot: TN_UDBase);
begin
  BuildUDVCSSRefs(UDRoot.Owner, UDRoot, 0, 0, '' );
  UDRoot.ScanSubTree( BuildUDVCSSRefs );
end;

function TK_BuildUDVCSSRefs.BuildUDVCSSRefs(UDParent : TN_UDBase; var UDChild : TN_UDBase;
  ChildInd, ChildLevel: Integer; FieldName: string): TK_ScanTreeResult;
var
  CSS : TK_UDDCSSpace;
  PCSS : Pointer;
begin
  if ChildInd <> -1 then begin
    if UDChild.Owner = UDParent then begin
      Result := K_tucOK;
      if UDChild is TK_UDVector then begin
        PCSS := TK_UDRArray(UDChild).GetFieldPointer( 'CSS' );
        if PCSS <> nil then begin
          CSS := TK_UDDCSSpace(PCSS^);
          if CSS.CI <> K_UDRefCI then
            with CSS.GetVectorsDir do
              if IndexOfDEField(UDChild) = -1 then
                AddOneChild( UDChild );
        end;
      end;
    end else
//*** Not Owner Node (External or Internal)
      Result := K_tucSkipSubTree;
  end else
//*** Skip References inside UDRArray
    Result := K_tucSkipSibling;
end;
}
{*** end of TK_BuildUDVCSSRefs ***}

{
//********************************** start of TK_UDUserRoot class methods ***
//************************************************ TK_UDUserRoot.Create ***
//
constructor TK_UDUserRoot.Create(  );
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDUserRootCI;
  ImgInd := 30;
end;
//********************************** end of TK_UDUserRoot class methods ***
}

//********** Global Cursor Routines  **************

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCurCursorGet
//******************************************************** K_UDCurCursorGet ***
// Get current IDB cursor structure.
//
//     Parameters
// Result - Returns current IDB cursor
//
// If current IDB Cursor is not defined, function creates new current cursor 
// "URoot", which points to Archives Root UDObject
//
function K_UDCurCursorGet(  ) : TK_UDCursor;
begin
  if K_UDCursor = nil then
    K_UDCursor := TK_UDCursor.Create( 'URoot', K_ArchsRootObj );
  Result := K_UDCursor;
end; // end_of function K_UDCurCursorGet

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCurCursorSet
//******************************************************** K_UDCurCursorSet ***
// Set new current cursor by given IDB path
//
//     Parameters
// Path   - IDB absolute path (may be with another cursor)
// Result - Returns current IDB cursor
//
function K_UDCurCursorSet( const Path : string ) : TK_UDCursor;
begin
  K_UDCursor := K_UDCursorGet( Path );
  Result := K_UDCursor;
end; // end_of function K_UDCurCursorSet

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCurCursorSetRoot
//**************************************************** K_UDCurCursorSetRoot ***
// Set new IDB Object for current IDB cursor
//
//     Parameters
// RootDirObj - current IDB cursor Root UDObj
//
procedure K_UDCurCursorSetRoot( RootDirObj: TN_UDBase );
begin
  K_UDCurCursorGet.SetRoot( RootDirObj );
end; // end_of procedure K_UDCursorGetRoot

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCurCursorGetRoot
//**************************************************** K_UDCurCursorGetRoot ***
// Get Currrent Cursor Root UDObj
//
//     Parameters
// Result - Returns current IDB cursor Root UDObj
//
function K_UDCurCursorGetRoot(  ) : TN_UDBase;
begin
  Result := K_UDCurCursorGet.GetRoot;
end; // end_of function K_UDCursorGetRoot

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCurCursorGetRootPath
//************************************************ K_UDCurCursorGetRootPath ***
// Get current IDB Cursor Root path
//
//     Parameters
// Result - Returns current IDB cursor Root path (path to cursor Root UDObj)
//
function K_UDCurCursorGetRootPath(  ) : string;
begin
  Result := K_UDCurCursorGet.GetRootPath(  );
end; // end_of function K_UDCurCursorGetRootPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCurCursorGetPath
//**************************************************** K_UDCurCursorGetPath ***
// Get current IDB Cursor current path
//
//     Parameters
// Result - Returns current IDB cursor current path
//
function K_UDCurCursorGetPath( SLevel : Integer = 0; FLevel : Integer = 0 ) : string;
begin
  Result := K_UDCurCursorGet.GetPath( Slevel, FLevel );
end; // end_of function K_UDCurCursorGetPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCurCursorIncludeName
//************************************************ K_UDCurCursorIncludeName ***
// Add current IDB cursor name to relative path
//
//     Parameters
// Path   - relative IDB path
// Result - Returns absolute IDB path (with cursor)
//
function K_UDCurCursorIncludeName( const Path : string ) : string;
begin
  Result := K_UDCurCursorGet.IncludeCursorName( Path );
end; // end_of function K_UDCurCursorGetGPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCurCursorGetObjPath
//************************************************* K_UDCurCursorGetObjPath ***
// Get relative path to Obj by current IDB cursor
//
//     Parameters
// Obj    - IDB Object
// Result - Returns relative IDB path
//
function   K_UDCurCursorGetObjPath( Obj : TN_UDBase ) : string;
begin
  Result := K_UDCurCursorGet.GetObjPath( Obj );
end; // end_of function K_UDCurCursorGetObjPath
{
//******************************************** K_UDCurCursorGetDEPath ***
//
function   K_UDCurCursorGetDEPath( const DE : TN_DirEntryPar ) : string;
begin
  Result := K_UDCurCursorGet.GetDEPath( DE );
end; // end_of function K_UDCurCursorGetDEPath
}
//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCurCursorGetErrPath
//************************************************* K_UDCurCursorGetErrPath ***
// Get current IDB cursor error path
//
//     Parameters
// Result - Returns Error path to current IDB cursor after unsuccessful attempt 
//          to get IDB Object using current cursor
//
function K_UDCurCursorGetErrPath(  ) : string;
begin
  Result := K_UDCurCursorGet.ErrPath;
end; // end_of function K_UDCurCursorGetErrPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCursorGet
//*********************************************************** K_UDCursorGet ***
// Get IDB cursor by absolute IDB path
//
//     Parameters
// Path   - absolute IDB path
// Result - Returns resulting cursor
//
function K_UDCursorGet( const Path : string ) : TK_UDCursor;
var
CName : string;
CInd : Integer;
begin
  K_UDPathTokenizer.SetSource( Path );
  CName := K_UDPathTokenizer.nextToken;
  if (CName <> K_udpNoCursor) then begin
    if (CName <> '') and
       (K_UDPathTokenizer.CPos <= K_UDPathTokenizer.TLength+1) and
       (K_UDPathTokenizer.Text[K_UDPathTokenizer.CPos - 1] = K_udpCursorDelim) then begin
      if not K_UDCursorsList.Find( CName, CInd ) then
        Result := TK_UDCursor.Create( CName, K_MainRootObj )
      else
        Result := TK_UDCursor(K_UDCursorsList.Objects[CInd]);
    end else begin
      K_UDPathTokenizer.CPos := 1;
      Result := K_UDCurCursorGet;
    end;
  end else
    Result := nil;
end; // end_of function K_UDCursorGet

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCursorSetRootPath
//*************************************************** K_UDCursorSetRootPath ***
// Set given absolute IDB path as Root path to cursor specified by given path
//
//     Parameters
// Path   - absolute IDB path
// Result - Returns true if given path is correct
//
function K_UDCursorSetRootPath( const Path : string ) : boolean;
begin
  Result := K_UDCursorGet( Path ).SetRootPath( );
end; // end_of function K_SetRootPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCursorSetPath
//******************************************************* K_UDCursorSetPath ***
// Set given absolute IDB path as current path to cursor specified by given path
//
//     Parameters
// Path   - absolute IDB path
// Result - Returns true if given path is correct
//
function K_UDCursorSetPath( const Path : string ) : boolean;
begin
  Result := K_UDCursorGet( Path ).SetPath( );
end; // end_of function K_UDCursorSetPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCursorGetDE
//********************************************************* K_UDCursorGetDE ***
// Get DirEntry structure by IDB absolute path
//
//     Parameters
// DE     - resulting DirEntry structure (On output)
// Path   - absolute IDB path
// Result - Returns True if given path is correct
//
function K_UDCursorGetDE( out DE : TN_DirEntryPar; const Path : string = '' ) : boolean;
begin
  Result := K_UDCursorGet( Path ).GetDE( DE );
end; // end_of function K_UDCursorGetDE

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCursorGetObj
//******************************************************** K_UDCursorGetObj ***
// Get IDB object by IDB absolute path
//
//     Parameters
// Path         - absolute IDB path
// AObjNameType - path type (ObjNames or ObjAliases)
// Result       - Returns IDB object or nil if IDB path is not correct
//
function K_UDCursorGetObj( const Path : string = ''; AObjNameType : TK_UDObjNameType = K_ontObjName ) : TN_UDBase;
var
  Cursor : TK_UDCursor;
  CObjNameType : TK_UDObjNameType;
begin
  Cursor := K_UDCursorGet( Path );
  CObjNameType := Cursor.ObjNameType;
  Cursor.ObjNameType := AObjNameType;
//  Result := K_UDCursorGet( Path ).GetObj;
  Result := Cursor.GetObj;
  Cursor.ObjNameType := CObjNameType;
end; // end_of function K_UDCursorGetObj

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_SetNodeCursorRefPath
//************************************************** K_SetNodeCursorRefPath ***
// Set IDB object as Root to given cursor and change object RefPath
//
//     Parameters
// UDRoot       - IDB cursor Root Object
// UDCursorPath - path to UDRoot which contains only cursor name - <CursorName>:
//
procedure K_SetNodeCursorRefPath( UDRoot : TN_UDBase; UDCursorName : string );
var
  LastInd : Integer;
begin
  with K_UDCursorGet( UDCursorName ) do
    SetRoot( UDRoot );
  if UDRoot <> nil then begin
    UDRoot.RefPath := UDCursorName;
    LastInd := Length(UDCursorName);
    if UDRoot.RefPath[LastInd] <> K_udpCursorDelim then
      UDRoot.RefPath := UDRoot.RefPath + K_udpCursorDelim;
  end;
end; //*** end of procedure K_SetNodeCursorRefPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCursorForceDir
//****************************************************** K_UDCursorForceDir ***
// Force IDB path
//
//     Parameters
// Path         - absolute IDB path
// AObjNameType - path type (ObjNames or ObjAliases)
// Result       - Returns IDB object
//
function K_UDCursorForceDir( const Path : string = '';
                             AObjNameType : TK_UDObjNameType = K_ontObjName ) : TN_UDBase;
var
  Cursor : TK_UDCursor;
  CObjNameType : TK_UDObjNameType;
  NExt, NSegment : string;
  TypePos : Integer;
  ClassInd, ClassRefInd : Integer;
  Parent : TN_UDBase;
begin
  Cursor := K_UDCursorGet( ExcludeTrailingPathDelimiter(Path) );
  CObjNameType := Cursor.ObjNameType;
  Cursor.ObjNameType := AObjNameType;

  Result := Cursor.GetObj;
  if Result <> nil then Exit; // object exists
//*** create path new path object
  if Cursor.PathDoneLevel >= 0 then
    Result := Cursor.Stack[Cursor.PathDoneLevel].Child
  else
    Result := Cursor.GetRoot;

  K_UDPathTokenizer.SetSource( Cursor.ErrPath );

  K_TreeViewsUpdateModeSet;

  while K_UDPathTokenizer.hasMoreTokens do
  begin
    NSegment := K_UDPathTokenizer.nextToken;
    TypePos := Pos( K_udpObjTypeNameDelim, NSegment );
    ClassInd := K_UDCursorForcePathDefUDCI;
    if TypePos <> 0 then
    begin // get new node type
      NExt := Copy( NSegment, TypePos + 1, Length(NSegment) );
      SetLength( NSegment, TypePos - 1 );
      ClassRefInd := K_GetUObjCIByTagName( NExt, false );
      if ClassRefInd <> -1 then ClassInd := ClassRefInd;
    end;
    Parent := Result;
    Result := Parent.AddOneChildV( N_ClassRefArray[ClassInd].Create );
    Result.ObjName := NSegment;
    Result.PrepareObjName;
    Parent.SetUniqChildName( Result, K_ontObjName );
    if AObjNameType <> K_ontObjName then begin
      Result.ObjAliase := NSegment;
      Parent.SetUniqChildName( Result, K_ontObjAliase );
    end;
    Result.RebuildVNodes( 1 );
  end;
//  Result.SetChangedSubTreeFlag;
  K_SetChangeSubTreeFlags( Result );
  K_TreeViewsUpdateModeClear(false);

  Cursor.ObjNameType := CObjNameType;

end; // end_of function K_UDCursorForceDir

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_UDCursorGetFieldPointer
//*********************************************** K_UDCursorGetFieldPointer ***
// Get IDB object field pointer
//
//     Parameters
// Path        - absolute IDB path (Object path + ! + Field path)
// PUDR        - pointer for return IDB object, which contains needed Field
// PErrPathPos - pointer to return position in IDB path where search was break
// Result      - Returns Field SPL type
//
function   K_UDCursorGetFieldPointer( const Path : string;
                        var PField  : Pointer;
                        PUDR : TN_PUDBase = nil; PErrPathPos : PInteger = nil  ) : TK_ExprExtType;
var
  Cursor : TK_UDCursor;
  PathStartsWithField : Boolean;
  FInd, Ind : Integer;
begin
  Cursor := K_UDCursorGet( Path );
// It's done because Cursor.GetObj couldn't done empty UDBase Path
  if K_UDPathTokenizer.Text[K_UDPathTokenizer.CPos] = K_udpFieldDelim then begin
    PField := Pointer( Cursor.Stack[0].Child );
    Cursor.ErrPath := Copy( K_UDPathTokenizer.Text,
             K_UDPathTokenizer.CPos + 1, Length(K_UDPathTokenizer.Text) );
    PathStartsWithField := true;
  end else begin
    Cursor.ErrPath := '';
    PField := Cursor.GetObj;
    PathStartsWithField := false;
  end;
  Result.All := Ord(nptUDRef);
  Ind := Length(Path) - Length(Cursor.ErrPath);
  if (PField <> nil) and
     ( (Cursor.ErrPath <> '') or
       PathStartsWithField    or
       (Path[Length(Path)] = K_udpFieldDelim ) ) then begin
      Result := K_GetUDFieldPointerByRPath( TN_UDBase(PField), K_udpFieldDelim+Cursor.ErrPath,
                              PField, Cursor.ObjNameType, PUDR, @FInd );
    if Result.DTCode = -1 then
      Ind := Ind + FInd - 1;
  end;
  if PErrPathPos <> nil then PErrPathPos^ := Ind;

end; // end_of function K_UDCursorGetFieldPointer

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_GetUDObjByGPath
//******************************************************* K_GetUDObjByGPath ***
// Get IDB object by IDB path with possible Macro names
//
//     Parameters
// UDPath - absolute IDB path with possible Macro names
// Result - Returns IDB object
//
function K_GetUDObjByGPath( const UDPath : string ) : TN_UDBase;
begin
  Result := K_UDCursorGetObj( K_ReplaceUDPathMacro( UDPath ) );
end; //*** end of K_GetUDObjByGPath


{*** TK_ReadOnlyMemStream ***}

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ReadOnlyMemStream\SetMem
//********************************************* TK_ReadOnlyMemStream.SetMem ***
// Set Memory for Readonly memory stream
//
//     Parameters
// APMem    - pointer to memory buffer
// AMemSize - memory buffer size in bytes
//
procedure TK_ReadOnlyMemStream.SetMem(APMem: Pointer; AMemSize: Integer);
begin
  SetPointer( APMem, AMemSize );
end; // end of TK_ReadOnlyMemStream.SetMem

//##path K_Delphi\SF\K_clib\K_UDT2.pas\TK_ReadOnlyMemStream\Write
//********************************************** TK_ReadOnlyMemStream.Write ***
// Readonly memory stream Write method stub
//
function TK_ReadOnlyMemStream.Write( const ABuffer; ACount: Integer ): Longint;
begin
  Result := Position;
end; // end of TK_ReadOnlyMemStream.Write

{*** end of TK_ReadOnlyMemStream ***}

//***********************************************
//           Virtual Files Procedures
//***********************************************
var
K_VFUDCursorPathDelimsOK : Integer;

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFUDCursorPathDelimsPrep
//********************************************** K_VFUDCursorPathDelimsPrep ***
// Skip K_udpFieldChar from K_UDPathTokenizer Delims
//
// (for internal use only)
//
procedure K_VFUDCursorPathDelimsPrep;
begin
  Inc( K_VFUDCursorPathDelimsOK );
  if K_VFUDCursorPathDelimsOK > 1 then Exit;
  K_UDPathTokenizer.setDelimiters( K_udpDelims1 );
end; //*** end of K_VFUDCursorPathDelimsPrep

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFUDCursorPathDelimsRestore
//******************************************* K_VFUDCursorPathDelimsRestore ***
// Return K_udpFieldChar to K_UDPathTokenizer Delims
//
// (for internal use only)
//
procedure K_VFUDCursorPathDelimsRestore;
begin
  Dec( K_VFUDCursorPathDelimsOK );
  if K_VFUDCursorPathDelimsOK > 0 then Exit;
  K_UDPathTokenizer.setDelimiters( K_udpDelims2 );
end; //*** end of K_VFUDCursorPathDelimsRestore

//********************************************* K_VFLoadIntDataFromTextFile ***
// Load Integer data from text VF file
//
//     Parameters
// AFName - VF file name
// ASL    - wrk TStrings
// APData - Array of pointers to Integer values
// Result - Returns TRUE if all is OK, FALSE if file load error
//          N_S contains load error string
function K_VFLoadIntDataFromTextFile( const AFName : string; ASL : TStrings; APData : array of const ) : Boolean;
var
  i, iHigh : Integer;

begin
  Result := FALSE;
  N_s := K_VFLoadStrings1( AFName, ASL, N_i );
  if N_s <> '' then
    Exit;

  iHigh := High(APData);
  if iHigh > ASL.Count - 1 then
    iHigh := ASL.Count - 1;

  for i := 0 to iHigh do
    with APData[i] do
      if VType = vtPointer then
        PInteger(VPointer)^ := StrToIntDef( ASL[i], 0 );

  for i := iHigh + 1 to High(APData) do
    with APData[i] do
      if VType = vtPointer then
        PInteger(VPointer)^ := 0;

  Result := TRUE;
end; // function K_VFLoadIntDataFromTextFile

//*********************************************** K_VFSaveIntDataToTextFile ***
// Save Integer data to text VF file
//
//     Parameters
// AFName - VF file name
// ASL    - wrk TStrings
// APData - Array of Integer values
// Result - Returns TRUE if all is OK, FALSE if file save error
//
function K_VFSaveIntDataToTextFile( const AFName : string; ASL : TStrings; AData : array of const ) : Boolean;
var i : Integer;
begin
  ASL.Clear();
  for i := 0 to High(AData) do
    with AData[i] do
      if VType = vtInteger then
        ASL.Add( IntToStr(VInteger) );

  Result := K_VFSaveStrings( ASL, AFName, K_DFCreatePlain )
end; // function K_VFSaveIntDataToTextFile


//*** Compound Buffered Files Routines

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_MVCBFileGetRoot
//******************************************************* K_MVCBFileGetRoot ***
// Get Compound Buffered File Root
//
// (for internal use only)
//
function  K_MVCBFileGetRoot( const ADFileName: string ): TN_UDBase;
var
  i : Integer;
begin
  with K_FilesRootObj do
  for i := 0 to DirHigh do
  begin
    Result := DirChild(i);
    if Result.ObjInfo = ADFileName then Exit;
  end;
  Result := nil;
end; //*** end of K_MVCBFileGetRoot

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_MVCBSetFileName
//******************************************************* K_MVCBSetFileName ***
// Set Compound Buffered File Object Name by File Name
//
//     Parameters
// CBFRoot    - Compound Buffered File Root Object
// ADFileName - File Path + File Name
//
// (for internal use only)
//
procedure K_MVCBSetFileName( CBFRoot: TN_UDBase; const ADFileName: string );
begin
  CBFRoot.ObjName := ChangeFileExt( ExtractFileName(ADFileName), '' );
  CBFRoot.PrepareObjName;
  with K_FilesRootObj do
    SetUniqChildName( CBFRoot );
  CBFRoot.ObjInfo := ADFileName;
  CBFRoot.ObjFlags := (CBFRoot.ObjFlags or K_fpObjSLSRFlag) and not K_fpObjSLSRRead;
end; //*** end of K_MVCBSetFileName

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_MVCBFileAssign
//******************************************************** K_MVCBFileAssign ***
// Assign New Compound Buffered File
//
//     Parameters
// ADFileName - File Path + File Name
// Result     - Returns Compound Buffered File Root Object
//
// Create New CBF Root Node and Load File Sub Tree. If CBF Root exists Return 
// Existed Root.
//
function  K_MVCBFileAssign( const ADFileName: string ): TN_UDBase;
begin
  Result := K_MVCBFileGetRoot( ADFileName );
  if Result <> nil then Exit;
//*** Add File Root
  Result := K_FilesRootObj.AddOneChild( TN_UDBase.Create );
  K_MVCBSetFileName( Result, ADFileName );
  if FileExists(ADFileName) then
  begin
    Result.LoadTreeFromAnyFile( ADFileName, [], true );
    if ((FileGetAttr( ADFileName ) and faReadOnly) <> 0) then
      Result.ObjFlags := Result.ObjFlags or K_fpObjSLSRRead;
  end // if FileExists(ADFileName) then
  else
  if ExtractFileName(ADFileName)[1] = K_vfmTmpCBFNamePref then
    Result.ObjFlags := Result.ObjFlags or K_fpObjSLSRRead;
end; //*** end of K_MVCBFileAssign

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_MVCBFileSave
//********************************************************** K_MVCBFileSave ***
// Save Existed Compound Buffered File
//
//     Parameters
// CBFRoot - Compound Buffered File Root Object
//
// Save changes in Compound Buffered File Memory representation to Windows file
//
procedure K_MVCBFileSave( CBFRoot: TN_UDBase );
//var
//  PrevFileName : string;
begin
  if CBFRoot = nil then Exit; // No MVCBFile
  with CBFRoot do
  begin
    // Correct File Name
    if ((ClassFlags and K_ChangedSLSRBit) = 0) or        // No Changes in File Subtree
       ((ObjFlags and K_fpObjSLSRRead) <> 0 ) then Exit; // Read Only
    K_ForceFilePath( ObjInfo );
    if (K_fpObjSLSRFText and ObjFlags) <> 0 then
      SaveTreeToTextFile( ObjInfo, K_TextModeFlags )
    else
      SaveTreeToFile( ObjInfo );
  end; // with CBFRoot do
end; //*** end of K_MVCBFileSave

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_MVCBFileClose
//********************************************************* K_MVCBFileClose ***
// Close Existed Compound Buffered File
//
//     Parameters
// CBFRoot - Compound Buffered File Root Object
//
// Save changes in BLOBs (Compound Buffered File Memory representation) to 
// Windows file and destroy Compound Buffered File Sub Tree
//
procedure K_MVCBFileClose( CBFRoot: TN_UDBase );
begin
  if CBFRoot = nil then Exit; // No MVCBFile
  K_MVCBFileSave( CBFRoot );
  K_FilesRootObj.DeleteOneChild( CBFRoot );
end; //*** end of K_MVCBFileClose

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_MVCBFSaveAll
//********************************************************** K_MVCBFSaveAll ***
// Save All Compound Buffered Files
//
// Save changes in all Compound Buffered Files Memory representation to Windows 
// files
//
procedure K_MVCBFSaveAll( );
var
  i : Integer;
begin
  with K_FilesRootObj do
    for i := 0 to DirHigh do K_MVCBFileSave( DirChild(i) );
end; //*** end of K_MVCBFSaveAll

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_MVCBFCloseAll
//********************************************************* K_MVCBFCloseAll ***
// Close All Compound Buffered Files
//
// Save changes in all Compound Buffered Files Memory representation to Windows 
// files and destroy all Compound Buffered Files Sub Trees
//
procedure K_MVCBFCloseAll( );
begin
  K_MVCBFSaveAll( );
  K_FilesRootObj.ClearChilds();
end; //*** end of K_MVCBFCloseAll

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFGetErrorString
//****************************************************** K_VFGetErrorString ***
// Get VFile Error string
//
//     Parameters
// AVFile - virtual file structure
// Result - Returns string with error info
//
function K_VFGetErrorString( var AVFile: TK_VFile ) : string;
begin
  Result := '';
  with AVFile.DFile do
  begin
    if DFErrorCode = K_dfrOK then Exit;
    if DFErrorCode <> K_dfrErrStreamOpen then
      Result := K_DFGetErrorString( DFErrorCode )
    else
      Result := DFErrorAddInfo;
  end;
// K_DFGetErrorString(
end; // function K_VFGetErrorString

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFAssignByPath
//******************************************************** K_VFAssignByPath ***
// Assign virtual file VFile by file name and file create parameters
//
//     Parameters
// VFile          - virtual file structure
// AVFileName     - file name
// APDFCreatePars - pointer to create parameters structure
// Result         - Returns assigned virtual file type
//
// Virtual file may have different types:
//#L
// - Windows file
// - compound buffer file
// - IDB BLOB Objects (IDB Objects of TN_UDMem Pascal type)
//#/L
//
function K_VFAssignByPath( var VFile: TK_VFile; const AVFileName: string;
                           APDFCreatePars: TK_PDFCreateParams = nil ) : TK_VFileType;
var
  PathInd : Integer;
begin
  VFile.UDMemName := '';
  VFile.DFName := '';
  VFile.DFile.DFErrorAddInfo := '';
  FillChar( VFile, SizeOf(VFile), 0 );
  PathInd := Pos( K_vfmMVCFileDelimeter, AVFileName );
  if PathInd = 0 then
    PathInd := Pos( K_vfmMVCMemFileDelimeter, AVFileName );
  with VFile do
  begin
    VFType := K_vftDFile;
    UDMemName := '';
    UDMem := nil;
    DFName := AVFileName;
    if PathInd <> 0 then
    begin // Compound File Name case
      UDMemName := Copy( AVFileName, PathInd + 1, Length(AVFileName) );
      VFType := K_vftUDMemFile;
      if PathInd > 1 then // "FileName|Internal Virtual Path" or "FileName>Internal Virtual Path"
      begin
        DFName := Copy( AVFileName, 1, PathInd - 1 );
        // Define Virtual File Type by File Name
        VFType := K_vftMVCFile;
        if AVFileName[PathInd] <> K_vfmMVCFileDelimeter then
          VFType := K_vftMVCMemFile;
      end // if PathInd > 1 then
      else // PathInd = 1 - Pure Virtual File (in Memory only)
        DFName := '';
    end; // if PathInd <> 0 then

    if APDFCreatePars <> nil then
      DFCreatePars := APDFCreatePars^;

    Result := VFType;
  end; // with VFile do

end; //*** end of K_VFAssignByPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFOpen
//**************************************************************** K_VFOpen ***
// Open virtual file
//
//     Parameters
// VFile      - virtual file
// AOpenFlags - DataFile open flags
// Result     - Returns opened file size in bytes or -1 is some problems were 
//              detected
//
function  K_VFOpen( var VFile: TK_VFile;
                    AOpenFlags: TK_DFOpenFlags = [] ): Integer;
begin
  Result := -1;
  with VFile do
  case VFType of
    K_vftDFile    :
      if K_DFOpen( DFName, DFile, AOpenFlags, @DFCreatePars ) then
        Result := DFile.DFPlainDataSize;
    K_vftMVCFile,
    K_vftMVCMemFile,
    K_vftUDMemFile :
      if K_VFileExists0( VFile ) then
      begin
//        if VFType = K_vftMVCFile then
        if UDMem is TN_UDExtMem then
        begin
          Result := Length( TN_UDExtMem(UDMem).SelfMem );
          if Result = 0 then
          begin
            if K_DFOpen( DFName, DFile, [K_dfoProtected], nil, TN_UDExtMem(UDMem).FilePos ) then
            begin
              Result := DFile.DFPlainDataSize;
              UDMem.ObjDateTime := DFile.DFFileDate;
            end;
          end;
        end   // if UDMem is TN_UDExtMem then
        else
        begin // if UDMem is TN_UDMem then
          Result := Length( TN_UDMem(UDMem).SelfMem );
        end;
        DFile.DFPlainDataSize := Result;
      end
      else // if not K_VFileExists0( VFile ) then
        DFile.DFErrorCode := K_dfrErrFileNotExists;
  end;
end; //*** end of K_VFOpen

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFStreamFree
//********************************************************** K_VFStreamFree ***
// Free virtual file stream
//
//     Parameters
// VFile - virtual file
//
procedure K_VFStreamFree( var VFile: TK_VFile );
begin
  with VFile do
  begin
    if VFStreamWriteMode then
    begin
    // Free stream opened for writing
      if (VFType <> K_vftDFile) or
         (DFCreatePars.DFEncryptionType <> K_dfePlain) then
        with TMemoryStream(DFile.DFStream) do
          K_VFWriteAll( VFile, Memory, Size );
      VFStreamWriteMode := FALSE;
    end; // if VFStreamWriteMode then
    FreeAndNil( DFile.DFStream );
  end; // with VFile do
end; //*** end of K_VFStreamFree

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFStreamGetToRead
//***************************************************** K_VFStreamGetToRead ***
// Get virtual file stream to read
//
//     Parameters
// VFile  - virtual file
// Result - Returns opened file Stream to read data
//
// Resulting Stream should be freed by K_VFStreamFree
//
function  K_VFStreamGetToRead( var VFile: TK_VFile ): TStream;
//var
//  PData : Pointer;
  procedure GetDataFromDFileToMStream();
  begin
    Result := TMemoryStream.Create;
    with TMemoryStream(Result) do
    begin
    // Copy DFile Plain Data to Wrk Stream
      SetSize(VFile.DFile.DFPlainDataSize);
      if K_DFReadAll( Memory, VFile.DFile, VFile.DFCreatePars.DFPassword ) then
        VFile.DFile.DFStream := Result
      else
      // Free resulting Stream if Data Copy Fails
        FreeAndNil(Result);
    end; // with TMemoryStream(Result) do
  end; // procedure GetDataFromDFileToMStream

  procedure CreateMemoryStream( Mem : TN_BArray );
  begin
    Result := TK_ReadOnlyMemStream.Create;
    TK_ReadOnlyMemStream( Result ).SetMem( @Mem[0], VFile.DFile.DFPlainDataSize );
    VFile.DFile.DFStream := Result;
  end; // procedure CreateMemorySTream

begin
  Result := nil;
  with VFile do
  case VFType of
    K_vftDFile    :
    begin
      if DFile.DFIsPlain then
        Result := DFile.DFStream
      else
      // if not DFile.DFIsPlain then
      // DFile is not Plain Data - Create Wrk Stream
        GetDataFromDFileToMStream();

    end; // K_vftDFile :
    K_vftMVCFile,
    K_vftMVCMemFile,
    K_vftUDMemFile :
      if UDMem <> nil then
      begin
        if UDMem is TN_UDExtMem then
        begin
          if Length(TN_UDExtMem(UDMem).SelfMem) > 0 then
            CreateMemoryStream( TN_UDExtMem(UDMem).SelfMem )
          else
            GetDataFromDFileToMStream();
          VFile.DFCreatePars := K_DFCreatePlain; //!!! Needed for proper Ruturn Value
        end // if UDMem is TN_UDExtMem then
        else// if UDMem is TN_UDMem then
          CreateMemorySTream( TN_UDMem(UDMem).SelfMem );
      end; // if UDMem <> nil then
  end; // case VFType of
end; //*** end of K_VFStreamGetToRead

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFRead
//**************************************************************** K_VFRead ***
// Read specified number of bytes from the begin of the virtual file
//
//     Parameters
// VFile         - virtual file structure
// APBuffer      - pointer to buffer
// ANumBytes     - number of reading bytes
// CloseFileFlag - true if file must be closed after reading (used for physical 
//                 Windows files)
// Result        - Returns true if file size is greater then specified read 
//                 length for IDB BLOB files or if Windows file read operation 
//                 was successful
//
function  K_VFRead( var VFile: TK_VFile; APBuffer: Pointer;
                         ANumBytes: Integer; CloseFileFlag : Boolean ): Boolean;
  procedure ReadMemData( Mem : TN_BArray );
  begin
    Result := Length(Mem) >= ANumBytes;
    if Result then
      Move( Mem[0], APBuffer^, ANumBytes );
  end; // procedure ReadMemData

begin
  Result := false;
  with VFile do
  case VFType of
    K_vftDFile    : Result := K_DFRead( APBuffer, ANumBytes, DFile,
                                  DFCreatePars.DFPassword, CloseFileFlag );
    K_vftMVCFile,
    K_vftMVCMemFile,
    K_vftUDMemFile :
    begin
      if UDMem is TN_UDExtMem then
      begin
        if Length(TN_UDExtMem(UDMem).SelfMem) > 0 then
          ReadMemData( TN_UDExtMem(UDMem).SelfMem )
        else
          Result := K_DFRead( APBuffer, ANumBytes, DFile, '', CloseFileFlag );
      end // if UDMem is TN_UDExtMem then
      else// if UDMem is TN_UDMem then
        ReadMemData( TN_UDMem(UDMem).SelfMem );
    end; // // K_vftMVCFile, K_vftMVCMemFile, K_vftUDMemFile :
  end; // case VFType of
end; //*** end of K_VFRead

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFReadAll
//************************************************************* K_VFReadAll ***
// Read all bytes from virtual file
//
//     Parameters
// VFile    - virtual file
// APBuffer - pointer to buffer where to read
// Result   - Returns true if physical file read is successful
//
function  K_VFReadAll( var VFile: TK_VFile; APBuffer: Pointer ): boolean;
begin
  Result := true;
  with VFile do
  case VFType of
    K_vftDFile     : Result :=  K_DFReadAll( APBuffer, DFile,
                                              DFCreatePars.DFPassword );
    K_vftMVCFile,
    K_vftMVCMemFile,
    K_vftUDMemFile :
      if UDMem is TN_UDExtMem then
      begin
        if Length(TN_UDExtMem(UDMem).SelfMem) > 0 then
          Move( TN_UDExtMem(UDMem).SelfMem[0], APBuffer^,
               Length( TN_UDExtMem(UDMem).SelfMem ) )
        else
          Result := K_DFReadAll( APBuffer, DFile );
      end // if UDMem is TN_UDExtMem then
      else// if UDMem is TN_UDMem then
        Move( TN_UDMem(UDMem).SelfMem[0], APBuffer^,
              Length( TN_UDMem(UDMem).SelfMem ) );
  end; // case VFType of
end; //*** end of K_VFReadAll

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFSetDataSpace
//******************************************************** K_VFSetDataSpace ***
// Set virtual file Data Space
//
//     Parameters
// VFile   - virtual file
// ADSpace - needed data space
// Result  - Returns true if data space was successful changed
//
// Is needed only for not Buffered Compound File Item. Should be used before 
// Compound File saving.
//
function  K_VFSetDataSpace( var VFile: TK_VFile; ADSpace: Integer  ): boolean;
var
  CurDataSize : Integer;
begin
  Result := K_VFileExists0( VFile );
  if not Result or not (VFile.UDMem is TN_UDExtMem) then Exit;

// Get File Size
  CurDataSize := K_VFOpen( VFile );
  Result := CurDataSize >= 0;
  if not Result then Exit;
  
// Close opened stream if FileStream was opened
  FreeandNil(VFile.DFile.DFStream);

// Increase new FileDataSpace if new value is less then real Data space
  if ADSpace < CurDataSize then ADSpace := CurDataSize;

// Set Compound File Change Flag if FileDataSpace is really changed
  if (TN_UDExtMem(VFile.UDMem).FileDataSpace <> ADSpace) and
     ((VFile.UDMem.ClassFlags and K_ChangedSLSRBit) = 0) then
    K_SetChangeSubTreeFlags( VFile.UDMem );

  TN_UDExtMem(VFile.UDMem).FileDataSpace := ADSpace;
end; //*** end of K_VFSetDataSpace

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFStreamGetToWrite
//**************************************************** K_VFStreamGetToWrite ***
// Get virtual file stream to write
//
//     Parameters
// VFile  - virtual file
// Result - Returns opened file Stream to write data
//
// Resulting Stream should be freed by K_VFStreamFree
//
function  K_VFStreamGetToWrite( var VFile: TK_VFile ): TStream;
begin
  with VFile do
  begin
    try
      if (VFType = K_vftDFile) and
         (DFCreatePars.DFEncryptionType = K_dfePlain) then
        Result := TFileStream.Create( DFName, fmCreate )
      else
        Result := TMemoryStream.Create;
      DFile.DFStream := Result;
      VFStreamWriteMode := TRUE;
    except
      DFile.DFErrorCode := K_dfrErrStreamOpen;
      Result := nil;
    end;
  end; // with VFile do
end; //*** end of K_VFStreamGetToWrite

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFWriteAll
//************************************************************ K_VFWriteAll ***
// Write all bytes to virtual file
//
//     Parameters
// VFile       - virtual file structure
// APFirstByte - pointer to buffer
// ANumBytes   - number of red bytes
//
// Replace the content of virtual file by specified number of bytes and close
//
procedure K_VFWriteAll ( var VFile: TK_VFile; APFirstByte: Pointer; ANumBytes: Integer );

  procedure PrepNewUDMem( ClassInd : Integer );
  begin
    K_UDCursorForceDir( ExtractFilePath(VFile.UDMemName), K_ontObjUName );
    TN_UDBase(VFile.UDMem) := K_UDCursorForceDir(
             VFile.UDMemName + K_udpObjTypeNameDelim + N_ClassTagArray[ClassInd],
             K_ontObjUName );
    VFile.UDMem.ObjDateTime := Now();
  end; // procedure PrepNewUDMem

  procedure SetData( var Mem : TN_BArray );
  begin
    SetLength( Mem, ANumBytes );
    Move( APFirstByte^, Mem[0], ANumBytes );
  end; // procedure SetData

begin
  with VFile do
  case VFType of
    K_vftDFile     : K_DFWriteAll( DFName, DFCreatePars,
                                   APFirstByte, ANumBytes );
    K_vftMVCFile,
    K_vftMVCMemFile,
    K_vftUDMemFile :
    begin
      K_VFUDCursorPathDelimsPrep;
      if not K_VFileExists0( VFile ) then
      begin
        if VFType = K_vftMVCFile then
          PrepNewUDMem( N_UDExtMemCI )
        else
          PrepNewUDMem( N_UDMemCI );
      end;
      K_VFUDCursorPathDelimsRestore;

//      if VFType = K_vftMVCFile then
      if UDMem is TN_UDExtMem then
      begin
        if (Length(TN_UDExtMem(UDMem).SelfMem) > 0) or
          (TN_UDExtMem(UDMem).FileDataSpace < ANumBytes ) then
          SetData( TN_UDExtMem(UDMem).SelfMem )
        else
        begin
          K_DFWriteAll( DFName, K_DFCreateEncrypted2, APFirstByte, ANumBytes,
                        TN_UDExtMem(UDMem).FilePos, UDMem.ObjDateTime );
          Exit;
        end;
      end
      else
        SetData( TN_UDMem(UDMem).SelfMem );
      K_SetChangeSubTreeFlags( UDMem );
    end; // K_vftMVCFile, K_vftMVCMemFile, K_vftUDMemFile :
  end; // case VFType of
end; //*** end of K_VFWriteAll

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFileExists0
//********************************************************** K_VFileExists0 ***
// Check if virtual file exists
//
//     Parameters
// VFile  - virtual file structure
// Result - Returns true if file exists
//
function  K_VFileExists0( var VFile: TK_VFile ) : Boolean;
begin
  Result := true;
  with VFile do
  begin
    if VFType = K_vftDFile then
    begin
      Result := FileExists( DFName );
      Exit;
    end
    else
    if UDMem <> nil then Exit;

    //*** Init MVCFile, MVCMemFile or UDMem File
    if VFType <> K_vftUDMemFile then
    begin
      if UDCBFRoot = nil then
        UDCBFRoot := K_MVCBFileAssign( DFName );
{
      begin
        UDCBFRoot := K_MVCBFileAssign( DFName );
        // Redefine Virtual File Type by File Contetnt
        if (VFType = K_vftMVCFile) and
           (UDCBFRoot.Marker = 1) then // New Root or Existed is K_vftMVCMemFile
          VFType := K_vftMVCMemFile
        else
        if (VFType = K_vftMVCMemFile) and
           (UDCBFRoot.Marker = -1) then // New Root or Existed Root is K_vftMVCFile
          VFType := K_vftMVCFile;
        UDCBFRoot.Marker := 0;
      end;
}

      if not K_VFIfExpandedName(UDMemName) then
      begin
        if UDMemName <> '' then
          UDMemName := K_udpPathDelim + ExcludeTrailingPathDelimiter(UDMemName);
        UDMemName := K_MainRootObj.RefPath + K_udpPathDelim +
//                   UDCBFRoot.GetOwnersPath( K_MainRootObj ) +
                   K_GetPathToUObj( UDCBFRoot, K_MainRootObj ) +
                   UDMemName;
      end; // if not K_VFIfExpandedName(UDMemName) then
{
      if VFType = K_vftMVCFile then UDCBFRoot.Marker := -1
      else if VFType = K_vftMVCMemFile then UDCBFRoot.Marker := 1;
}
    end; // if VFType <> K_vftUDMemFile then
    K_VFUDCursorPathDelimsPrep;
    UDMem := K_UDCursorGetObj( UDMemName, K_ontObjUName );
    K_VFUDCursorPathDelimsRestore;
    Result := UDMem <> nil;
  end;
end; //*** end of K_VFileExists0

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFileExists
//*********************************************************** K_VFileExists ***
// Check if virtual file exists
//
//     Parameters
// AVFileName - virtual file name
// Result     - Returns true if file exists
//
function  K_VFileExists( const AVFileName: string ) : Boolean;
var
  VFile: TK_VFile;
begin
  K_VFAssignByPath( VFile, AVFileName );
  Result := K_VFileExists0( VFile );
end; //*** end of K_VFileExists

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFDirExists0
//********************************************************** K_VFDirExists0 ***
// Check if virtual file folder exists
//
//     Parameters
// VFile  - virtual file structure
// Result - Returns true if file exists
//
function  K_VFDirExists0( var VFile: TK_VFile ) : Boolean;
begin
  with VFile do
  if VFType = K_vftDFile then
    Result := DirectoryExists( DFName )
  else
    Result := K_VFileExists0( VFile );
end; //*** end of K_VFDirExists0

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFDirExists
//*********************************************************** K_VFDirExists ***
// Check if virtual file folder exists
//
//     Parameters
// AVFileName - virtual file name
// Result     - Returns true if file exists
//
function  K_VFDirExists( const AVDirPath: string ) : Boolean;
var
  VFile: TK_VFile;
begin
  K_VFAssignByPath( VFile, AVDirPath );
  Result := K_VFDirExists0( VFile );
end; //*** end of K_VFileExists

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFSetFileAge
//********************************************************** K_VFSetFileAge ***
// Set virtual file TimeStamp
//
//     Parameters
// VFile - virtual file structure
// DT    - virtual file TimeStamp
//
procedure K_VFSetFileAge( var VFile: TK_VFile; DT : TDateTime );
begin
  if not K_VFileExists0( VFile ) then Exit;
  with VFile do
  if (VFType = K_vftDFile) or
     ((UDMem is TN_UDExtMem) and (Length(TN_UDExtMem(UDMem).SelfMem) > 0)) then
//    FileSetDate( DFName, DateTimeToFileDate(DT) )
    K_SetFileAge( DFName, DT )
  else
    UDMem.ObjDateTime := DT;
end; //*** end of K_VFSetFileAge

//{$WARN SYMBOL_DEPRECATED OFF}

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFileAge0
//************************************************************* K_VFileAge0 ***
// Get virtual file folder TimeStamp
//
//     Parameters
// VFile  - virtual file structure
// Result - Returns virtual file TimeStamp
//
function  K_VFileAge0( var VFile: TK_VFile ) : TDateTime;
begin
  Result := 0;
  if not K_VFileExists0( VFile ) then Exit;
  with VFile do
  if VFType = K_vftDFile then
    Result := K_GetFileAge( DFName )
  else
    Result := UDMem.ObjDateTime;
end; //*** end of K_VFileAge0

//{$WARN SYMBOL_DEPRECATED ON}

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFileAge
//************************************************************** K_VFileAge ***
// Get virtual file folder TimeStamp
//
//     Parameters
// AVFileName - virtual file name
// Result     - Returns virtual file TimeStamp
//
function  K_VFileAge( const AVFileName: string ) : TDateTime;
var
  VFile: TK_VFile;
begin
  K_VFAssignByPath( VFile, AVFileName );
  Result := K_VFileAge0( VFile );
end; //*** end of K_VFileAge

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFForceDirPath0
//******************************************************* K_VFForceDirPath0 ***
// Create all path folders if needed
//
//     Parameters
// VFile  - virtual file structure
// Result - Returns true if all path folders are exist or are successfully 
//          created
//
function  K_VFForceDirPath0( var VFile: TK_VFile ) : Boolean;
begin
  Result := K_VFDirExists0( VFile );
  if Result then Exit;
  with VFile do
    case VFType of
      K_vftDFile    : Result := K_ForceDirPath( DFName );
      K_vftMVCFile,
      K_vftMVCMemFile,
      K_vftUDMemFile :
      begin
        K_UDCursorForceDir( UDMemName, K_ontObjUName );
        Result := true;
      end; // K_vftUDMemFile :
    end;
end; //*** end of K_VFForceDirPath0

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFForceDirPath
//******************************************************** K_VFForceDirPath ***
// Create all path folders if needed
//
//     Parameters
// AVFileDirPath - virtual folder name
// Result        - Returns true if all path folders are exist or are 
//                 successfully created
//
function  K_VFForceDirPath( const AVFileDirPath : string ) : Boolean;
var
  VFile: TK_VFile;
begin
  K_VFAssignByPath( VFile, AVFileDirPath );
  Result := K_VFForceDirPath0( VFile );
end; //*** end of K_VFForceDirPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFForceDirPathDlg
//***************************************************** K_VFForceDirPathDlg ***
// Create all path folders in Dialogue
//
//     Parameters
// AVFileDirPath - virtual folder path
// Result        - Returns true if all path folders are exist or are 
//                 successfully created
//
// If not all needed path folders exist ask if creation is needed
//
function  K_VFForceDirPathDlg( const AVFileDirPath : string ) : Boolean;
var
  VFile: TK_VFile;
begin
  K_VFAssignByPath( VFile, AVFileDirPath );
  Result := K_VFDirExists0( VFile );
  if not Result and
     (MessageDlg( 'Ïóòü '+ AVFileDirPath +' íå íàéäåí. Ñîçäàòü?',
                  mtWarning, mbOKCancel, 0 ) = mrOk ) then
    Result := K_VFForceDirPath0( VFile );

end; //*** end of function K_VFForceDirPathDlg

//************************************************ K_VFFindNextUDMem
//  Find next proper UDMem virtual file
//
//     Parameters
// VFS     - virtual file name search record
// Result  - returns true if proper object is found
//
// (for external use only)
//
function K_VFFindNextUDMem( var VFS : TK_VFileSearchRec ) : Boolean;
var
  CurUDMem : TN_UDBase;
//  CurUDMem : TObject;
begin
  with VFS do begin
    repeat
      Inc(CurUDMemInd);
      Result := UDMemRoot.DirLength > CurUDMemInd;
      if not Result then break;
      CurUDMem := UDMemRoot.DirChild( CurUDMemInd );
      if CurUDMem = nil then
      begin
        VFName := '';
        VFSType := K_vfsUndef;
      end
      else
      begin
        with CurUDMem do
          VFName := TN_UDBase(CurUDMem).GetUName;
        if CurUDMem is TN_UDMem then
        begin
          VFSType := K_vfsVFile;
          VFSize := Length( TN_UDMem(CurUDMem).SelfMem);
        end
        else
        if CurUDMem is TN_UDExtMem then
        begin
          VFSType := K_vfsVFile;
          VFSize := Length( TN_UDExtMem(CurUDMem).SelfMem);
          if VFSize = 0 then
          // it is not correct (FileDataSpace >= real data size)
          // but VFSize is obsolete and is needed for compatibility only
            VFSize := TN_UDExtMem(CurUDMem).FileDataSpace;
        end
        else
          VFSType := K_vfsVDir;
      end;
      if VFSFlags <> [K_vfsVFile,K_vfsVDir] then
        Result :=  VFSType in VFSFlags;
      if Result then
        Result := K_CheckTextPattern( VFName, VFNamePat );
    until Result;
  end;
end; //*** end of procedure K_VFFindNextUDMem

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFFindFirst
//*********************************************************** K_VFFindFirst ***
// Find first proper virtual file name in given folder
//
//     Parameters
// VFS       - virtual file name search record
// AVDirPath - virtual folder path
// AVFSFlags - search flags set of [K_vfsVFile, K_vfsVDir] allows to select 
//             files or/and folders search
// NamePat   - files name pattern (with wild card characters)
// Result    - Returns true if proper virtual file is found
//
function  K_VFFindFirst( var VFS : TK_VFileSearchRec;
                         const AVDirPath : string;
                         AVFSFlags : TK_VFileSearchFlags = [K_vfsVFile, K_vfsVDir];
                         NamePat : string = '*.*' ) : Boolean;
var
  VFile: TK_VFile;
  FAttr : Integer;
begin
  K_VFAssignByPath( VFile, AVDirPath );
  Result := K_VFDirExists0( VFile );
  if not Result then Exit;
  VFS.VFNamePat := '';
  VFS.VFName := '';
  FillChar( VFS, SizeOf(VFS), 0 );
  with VFS, VFile do begin
    VFSFlags  := AVFSFlags;
    VFFType := VFType;
    VFNamePat := NamePat;
    UDMemRoot := UDMem;
    case VFType of
      K_vftDFile    :
      begin
        FAttr := faAnyFile;
        if not (K_vfsVDir in VFSFlags) then
          FAttr := FAttr xor faDirectory;
        Result := FindFirst( DFName + '*.*', FAttr, F ) = 0;
        if Result then
        begin
          VFName := F.Name;
          if (F.Attr and faDirectory) <> 0 then
            VFSType := K_vfsVDir
          else begin
            if VFNamePat <> '*.*' then
            begin
              Result := K_CheckTextPattern( F.Name, VFNamePat );
              if not Result then
                Result := K_VFFindNext( VFS );
            end;
            VFSType := K_vfsVFile;
            VFSize := F.Size;
          end;
        end; // if Result then
      end; // K_vftDFile    :
      K_vftMVCFile,
      K_vftMVCMemFile,
      K_vftUDMemFile :
      begin
        CurUDMemInd := -1;
        Result := K_VFFindNextUDMem( VFS );
      end; // K_vftUDMemFile :
    end; // case VFType of
  end;

end; //*** end of procedure K_VFFindFirst

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFFindNext
//************************************************************ K_VFFindNext ***
// Find next proper virtual file name
//
//     Parameters
// VFS    - virtual file name search record
// Result - Returns true if proper virtual file is found
//
function K_VFFindNext( var VFS : TK_VFileSearchRec ) : Boolean;
begin
  Result := false;
  with VFS do begin
    case VFFType of
      K_vftDFile    : begin
        Result := false;
        while FindNext( F ) = 0 do begin
          VFName := F.Name;
          Result := true;
          if (F.Attr and faDirectory) <> 0 then
            VFSType := K_vfsVDir
          else begin
            VFSType := K_vfsVFile;
            VFSize := F.Size;
            if VFNamePat <> '*.*' then
              Result := K_CheckTextPattern( VFName, VFNamePat );
          end;
          if Result then break;
        end;
      end;
      K_vftMVCFile,
      K_vftMVCMemFile,
      K_vftUDMemFile : Result := K_VFFindNextUDMem( VFS );
    end;
  end;

end; //*** end of function K_VFFindNext

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFFindClose
//*********************************************************** K_VFFindClose ***
// Releases memory allocated by K_VFFindFirst
//
//     Parameters
// VFS - virtual file name search record
//
procedure K_VFFindClose( var VFS : TK_VFileSearchRec );
begin
  with VFS do
    if VFFType = K_vftDFile then FindClose( F );
end; //*** end of procedure K_VFFindClose

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFCompareFilesAge0
//**************************************************** K_VFCompareFilesAge0 ***
// Compare TimeStamps of Source and Destination files
//
//     Parameters
// SVFile - source virtual file structure
// DVFile - destination virtual file structure
// Result - Returns compare result:
//#F
//          K_vfcrOK          - DestFile is not exists or it's TimeStamp is less then SrcFile age
//          K_vfcrDestNewer   - DestFile is newer then SrcFile
//          K_vfcrSrcNotFound - SrcFile is not found
//#/F
//
function  K_VFCompareFilesAge0( var SVFile, DVFile: TK_VFile ) : TK_VFileCopyResultCode;
begin
  K_VFUDCursorPathDelimsPrep;
  if K_VFileExists0( SVFile ) then
  begin
    if not K_VFileExists0( DVFile ) or
       ( K_VFileAge0( DVFile ) < K_VFileAge0( SVFile ) ) then
      Result := K_vfcrOK
    else
      Result := K_vfcrDestNewer;
  end else
    Result := K_vfcrSrcNotFound;
  K_VFUDCursorPathDelimsRestore;
end; //*** end of K_VFCompareFilesAge0

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFCompareFilesAge
//***************************************************** K_VFCompareFilesAge ***
// Compare TimeStamps of Source and Destination files
//
//     Parameters
// SrcFName  - source virtual file name
// DestFName - destination virtual file name
// Result    - Returns compare result:
//#F
//          K_vfcrOK          - DestFile is not exists or it's TimeStamp is less then SrcFile age
//          K_vfcrDestNewer   - DestFile is newer then SrcFile
//          K_vfcrSrcNotFound - SrcFile is not found
//#/F
//
function  K_VFCompareFilesAge( const SrcFName, DestFName : string ) : TK_VFileCopyResultCode;
var
  SVFile, DVFile: TK_VFile;
begin
  K_VFAssignByPath( SVFile, SrcFName );
  K_VFAssignByPath( DVFile, DestFName );
  Result := K_VFCompareFilesAge0( SVFile, DVFile );
end; //*** end of K_VFCompareFilesAge

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFCopyFile
//************************************************************ K_VFCopyFile ***
// Copy virtual file
//
//     Parameters
// SrcFName    - source virtual file name
// DestFName   - destination virtual file name
// ACreatePars - file create parameters (for destination file creation)
// AVFCFlags   - set of copy options
// Result      - Returns compare result:
//#F
//          K_vfcrOK          - DestFile is not exists or it's TimeStamp is less then SrcFile age
//          K_vfcrDestNewer   - DestFile is newer then SrcFile
//          K_vfcrSrcNotFound - SrcFile is not found
//#/F
//
function  K_VFCopyFile( const SrcFName, DestFName : string;
                        const ACreatePars : TK_DFCreateParams;
                        AVFCFlags : TK_VFileCopyFlags = [] ) : TK_VFileCopyResultCode;
var
  SVFile, DVFile: TK_VFile;
  TMP_Buf : TN_BArray;
  TMP_CBuf : TN_BArray;
  CDP : Pointer;
  DCount : Integer;
  CompressedCount : Integer;
  CompressPower : Integer;

label LExit, VFRead;

  procedure ReadFromDFile();
  begin
    DCount := K_VFOpen( SVFile );
    SetLength( TMP_Buf, DCount );
    CDP := @TMP_Buf[0];
    if not K_VFReadAll( SVFile, CDP  ) then
      Result := K_vfcrReadSrcError;
  end;

begin
  K_VFAssignByPath( SVFile, SrcFName );
  K_VFAssignByPath( DVFile, DestFName );
  K_VFUDCursorPathDelimsPrep;
  Result := K_VFCompareFilesAge0( SVFile, DVFile );

  if (Result = K_vfcrOK) or
     ( (Result = K_vfcrDestNewer) and
       (K_vfcOverwriteNewer in AVFCflags)  ) then
  begin
    if K_VFForceDirPath( ExtractFilePath(DestFName) ) then
    begin
      Result := K_vfcrOK;
      DCount := 0;
      CDP := nil;
      with SVFile do
      case VFType of
        K_vftDFile    :
        begin
          ReadFromDFile();
          if Result <> K_vfcrOK then goto LExit;
        end;
        K_vftMVCMemFile,
        K_vftUDMemFile :
        begin
          CDP := @TN_UDMem(UDMem).SelfMem[0];
          DCount := Length(TN_UDMem(UDMem).SelfMem);
        end;
        K_vftMVCFile:
        if Length(TN_UDExtMem(UDMem).SelfMem) > 0 then
        begin
          CDP := @TN_UDExtMem(UDMem).SelfMem[0];
          DCount := Length(TN_UDExtMem(UDMem).SelfMem);
        end
        else
        begin
          ReadFromDFile();
          if Result <> K_vfcrOK then goto LExit;
        end;
      end; // case VFType of

      CompressedCount := N_GetUncompressedSize( CDP, DCount );
      if K_vfcDecompressSrc in AVFCFlags then
      begin
        if CompressedCount <> -1 then
        begin    //Uncompress Dest
          SetLength( TMP_CBuf, CompressedCount );
          DCount := N_DecompressMem( CDP, DCount, @TMP_CBuf[0], CompressedCount );
          CDP := @TMP_CBuf[0];
          if DCount = - 1 then
            Result := K_vfcrDecompressionError;
        end;
      end else if (AVFCFlags * [K_vfcCompressSrc0,K_vfcCompressSrc1,K_vfcCompressSrc2]) <> [] then
      begin
        if CompressedCount = -1 then
        begin //Ñompress Dest
          CompressPower := 1;
          if K_vfcCompressSrc2 in AVFCFlags then CompressPower := 3
          else if K_vfcCompressSrc1 in AVFCFlags then CompressPower := 2;

          CompressedCount := DCount + 10000;
          SetLength( TMP_CBuf, CompressedCount );
          DCount := N_CompressMem( CDP, DCount, @TMP_CBuf[0], CompressedCount, CompressPower );
          CDP := @TMP_CBuf[0];
          if DCount = - 1 then
            Result := K_vfcrCompressionError;
        end;
      end;

      if Result = K_vfcrOK then
      begin
        DVFile.DFCreatePars := ACreatePars;
        K_VFWriteAll( DVFile, CDP, DCount );
        K_VFSetFileAge( DVFile, K_VFileAge0( SVFile ) );
      end;
    end  // if K_VFForceDirPath( ExtractFilePath(DestFName) ) then
    else
      Result := K_vfcrDestPathError;
  end;
LExit:
  K_VFUDCursorPathDelimsRestore;
end; //*** end of K_VFCopyFile

//*********************************************************** K_VFCopyFile1 ***
// Copy virtual file using streams
//
//     Parameters
// SrcFName    - source virtual file name
// DestFName   - destination virtual file name
// AVFCFlags   - set of copy options
// APFSize     - pointer to 1-st of 2 iteger values file source and resulting files size
// Result      - Returns compare result:
//#F
//          K_vfcrOK          - DestFile is not exists or it's TimeStamp is less then SrcFile age
//          K_vfcrDestNewer   - DestFile is newer then SrcFile
//          K_vfcrSrcNotFound - SrcFile is not found
//#/F
//
function  K_VFCopyFile1( const SrcFName, DestFName : string;
                         AVFCFlags : TK_VFileCopyFlags = [];
                         APFSize : PInteger = nil ) : TK_VFileCopyResultCode;
var
  SVFile, DVFile: TK_VFile;

  CompressedCount : Integer;
  CompressPower : Integer;

  SrcStream, DstStream : TStream;

label LExit, LExit1;

begin
  K_VFAssignByPath( SVFile, SrcFName );
  K_VFAssignByPath( DVFile, DestFName );
  K_VFUDCursorPathDelimsPrep;
  Result := K_VFCompareFilesAge0( SVFile, DVFile );

  if (Result = K_vfcrOK) or
     ( (Result = K_vfcrDestNewer) and
       (K_vfcOverwriteNewer in AVFCflags)  ) then
  begin
    if K_VFForceDirPath( ExtractFilePath(DestFName) ) then
    begin
      Result := K_vfcrOK;
      K_VFOpen( SVFile );

      if SVFile.VFType = K_vftDFile then
        SrcStream := SVFile.DFile.DFStream
      else
        SrcStream := K_VFStreamGetToRead( SVFile );

      if SrcStream = nil then
      begin
        Result := K_vfcrSrcNotFound;
        goto LExit;
      end;

      if APFSize <> nil then
      begin
        APFSize^ := SrcStream.Size;
        Inc(APFSize);
      end;

      if DVFile.VFType = K_vftDFile then
         DVFile.DFCreatePars.DFEncryptionType := K_dfePlain;
      DstStream := K_VFStreamGetToWrite( DVFile );

      if K_vfcDecompressSrc in AVFCFlags then
      begin
        if DstStream is TMemoryStream then
        begin
          CompressedCount := K_GetUncompressedSize( SrcStream );
          if CompressedCount = -1 then
          begin
            Result := K_vfcrDecompressionError;
            goto LExit1;
          end
          else
            DstStream.Size := CompressedCount;
        end;

        if K_DecompressStream( SrcStream, DstStream ) < 0 then
          Result := K_vfcrDecompressionError;
      end  // if K_vfcDecompressSrc in AVFCFlags then
      else
      if (AVFCFlags * [K_vfcCompressSrc0,K_vfcCompressSrc1,K_vfcCompressSrc2]) <> [] then
      begin
        CompressPower := 1;
        if K_vfcCompressSrc2 in AVFCFlags then CompressPower := 3
        else
        if K_vfcCompressSrc1 in AVFCFlags then CompressPower := 2;

        SrcStream.Position := 0;
        if K_CompressStream( SrcStream, DstStream, CompressPower ) < 0 then
          Result := K_vfcrCompressionError;
      end // if (AVFCFlags * [K_vfcCompressSrc0,K_vfcCompressSrc1,K_vfcCompressSrc2]) <> [] then
      else
        try
          DstStream.CopyFrom( SrcStream, SrcStream.Size );
        except
          Result := K_vfcrWriteError;
        end;

LExit1: //**********
      K_VFStreamFree( SVFile );

      if (APFSize <> nil) and (Result = K_vfcrOK) then
        APFSize^ := DstStream.Size;
      K_VFStreamFree( DVFile );

      if Result = K_vfcrOK then
        K_VFSetFileAge( DVFile, K_VFileAge0( SVFile ) );
    end  // if K_VFForceDirPath( ExtractFilePath(DestFName) ) then
    else
      Result := K_vfcrDestPathError;
  end; // if (Result = K_vfcrOK) or ( (Result = K_vfcrDestNewer) and  (K_vfcOverwriteNewer in AVFCflags)  ) then

LExit: //**********
  K_VFUDCursorPathDelimsRestore();
end; //*** end of K_VFCopyFile1

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFCopyDirFiles
//******************************************************** K_VFCopyDirFiles ***
// Copy virtual folder files
//
//     Parameters
// SrcVPathName - source virtual folder name
// DstVPathName - destination virtual folder name
// ACreatePars  - file create parameters (for destination file creation)
// NamePat      - files name pattern (with wild card characters)
// AVFCFlags    - set of copy options
//
procedure K_VFCopyDirFiles( const SrcVPathName, DstVPathName : string;
                            const ACreatePars : TK_DFCreateParams;
                            const NamePat : string = '*.*';
                            AVFCFlags : TK_VFileCopyFlags = [K_vfcRecurseSubfolders] );
var
  VFS : TK_VFileSearchRec;
  SName, DName : string;
  DVFile: TK_VFile;
  AVFSFlags : TK_VFileSearchFlags;
begin
  K_VFUDCursorPathDelimsPrep;
  if K_vfcRecurseSubfolders in AVFCFlags then
    AVFSFlags := [K_vfsVFile, K_vfsVDir]
  else
    AVFSFlags := [K_vfsVFile];
  if K_VFFindFirst( VFS, SrcVPathName, AVFSFlags, NamePat ) then begin
    K_VFAssignByPath( DVFile, DstVPathName );
    if DVFile.VFType <> K_vftDFile then
      K_TreeViewsUpdateModeSet;
    repeat
      if (VFS.VFName[1] = '.') or (VFS.VFSType = K_vfsUndef) then continue;
      SName := SrcVPathName + VFS.VFName;
      DName := DstVPathName + VFS.VFName;
      if VFS.VFSType = K_vfsVDir then
        K_VFCopyDirFiles( IncludeTrailingPathDelimiter(SName),
                          IncludeTrailingPathDelimiter(DName),
                          ACreatePars, NamePat, AVFCFlags )
      else
        K_VFCopyFile( SName, DName, ACreatePars, AVFCFlags );
    until not K_VFFindNext( VFS );
    K_VFFindClose( VFS );
    if DVFile.VFType <> K_vftDFile then
      K_TreeViewsUpdateModeClear(false);
  end;
  K_VFUDCursorPathDelimsRestore;
end; //*** end of K_VFCopyDirFiles

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFDeleteFile
//********************************************************** K_VFDeleteFile ***
// Delete virtual file
//
//     Parameters
// FileName         - virtual file name
// ADeleteFileFlags - delete file flags
//
function  K_VFDeleteFile( const FileName : string; ADeleteFileFlags : TK_DelOneFileFlags = [] ) : Boolean;
var
  VFile: TK_VFile;
begin
  Result := false;
  case K_VFAssignByPath( VFile, FileName ) of
    K_vftDFile    : Result := K_DeleteFile( FileName, ADeleteFileFlags );
    K_vftMVCFile,
    K_vftMVCMemFile,
    K_vftUDMemFile :
    begin
      Result := K_VFileExists0( VFile );
      if not Result then Exit;
      with VFile do
        UDMem.Owner.DeleteOneChild( UDMem );
    end;
  end;
end; //*** end of K_VFDeleteFile

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFDeleteDirFiles
//****************************************************** K_VFDeleteDirFiles ***
// Delete virtual folder files
//
//     Parameters
// DirName           - source virtual folder name
// NamePat           - files name pattern (with wild card characters)
// RecurseSubfolders - subfolders recursion flag
//
procedure K_VFDeleteDirFiles( const DirName : string;
                              const NamePat : string = '*.*';
                              DelFileFlags : TK_DelFolderFilesFlags = [K_dffRecurseSubfolders] );
var
  VFile: TK_VFile;
  AVFSFlags : TK_VFileSearchFlags;
  VFS : TK_VFileSearchRec;
  VPathName, SName : string;
begin
  VPathName := IncludeTrailingPathDelimiter( DirName );
  case K_VFAssignByPath( VFile, DirName ) of
    K_vftDFile    : K_DeleteFolderFiles( VPathName, NamePat, DelFileFlags );
    K_vftMVCFile,
    K_vftMVCMemFile,
    K_vftUDMemFile : begin
      K_VFUDCursorPathDelimsPrep;
      if K_VFDirExists0( VFile ) then begin
        K_TreeViewsUpdateModeSet;
        if (K_dffRecurseSubfolders in DelFileFlags) and
           (NamePat = '*.*') then
          with VFile do
            UDMem.ClearChilds
        else begin
          if K_dffRecurseSubfolders in DelFileFlags then
            AVFSFlags := [K_vfsVFile, K_vfsVDir]
          else
            AVFSFlags := [K_vfsVFile];
          if K_VFFindFirst( VFS, VPathName, AVFSFlags, NamePat ) then begin
            repeat
              if (VFS.VFName[1] = '.') or (VFS.VFSType = K_vfsUndef) then continue;
              SName := VPathName + VFS.VFName;
              if VFS.VFSType = K_vfsVDir then
                K_VFDeleteDirFiles( SName, NamePat, DelFileFlags )
              else
                K_VFDeleteFile( SName );
            until not K_VFFindNext( VFS );
            K_VFFindClose( VFS );
          end;

        end;
        K_TreeViewsUpdateModeClear(false);
      end;
      K_VFUDCursorPathDelimsRestore;
    end;
  end;
end; //*** end of K_VFDeleteDirFiles

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFRemoveDir
//*********************************************************** K_VFRemoveDir ***
// Remove virtual folder
//
//     Parameters
// DirName - source virtual folder name
// Result  - Returns true if folder is removed
//
// Remove virtual folder and all put in files
//
function  K_VFRemoveDir( const DirName : string ) : Boolean;
var
  VFile: TK_VFile;
begin
  Result := false;
  case K_VFAssignByPath( VFile, DirName ) of
    K_vftDFile    : begin
      K_DeleteFolderFiles( IncludeTrailingPathDelimiter( DirName ) );
      Result := RemoveDir( DirName );
    end;
    K_vftMVCFile,
    K_vftMVCMemFile,
    K_vftUDMemFile : begin
      Result := K_VFileExists0( VFile );
      if not Result then Exit;
      with VFile do
        UDMem.Owner.DeleteOneChild( UDMem );
    end;
  end;
end; //*** end of K_VFRemoveDir

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFSaveText0
//*********************************************************** K_VFSaveText0 ***
// Save text to virtual file
//
//     Parameters
// Text   - saving text
// VFile  - virtual file structure
// Result - Returns TRUE if success
//
function K_VFSaveText0( const Text: string; var VFile: TK_VFile ) : Boolean;
var
{!!!
  TextLength : Integer;
  W2 : word; // UnicodeSignature
  WideBufStr : WideString;
  AnsiBufStr : AnsiString;
  DataSize : Integer;
}
  Stream : TStream;

begin
//  AnsiBufStr := ''; // to avoid warning in Delhi 7
//  WideBufStr := ''; // to avoid warning in Delhi 2010
  Stream := K_VFStreamGetToWrite( VFile );
  Result := Stream <> nil;
  if not Result then Exit;

  VFile.DFile.DFPlainDataSize := K_SaveTextToStreamWithBOM( Text, Stream );

  K_VFStreamFree( VFile );

{!!!
  TextLength := Length(Text);
  DataSize := TextLength;
  if DataSize > 0 then
  begin
    W2 := $FEFF; // UnicodeSignature
    if SizeOf( Char ) = 2 then
    begin // String is Wide
      if not K_SaveTextAsAnsi then
      begin // Wide to Wide
        Stream.Write( W2, 2 );
        Stream.Write( Text[1], TextLength * 2 );
        DataSize := 2 + DataSize * 2;
      end
      else
      begin                     // Wide to Ansi
  //      AnsiBufStr := AnsiString(Text);
        AnsiBufStr := N_StringToAnsi(Text);
        Stream.Write( AnsiBufStr[1], TextLength )
      end;
    end // if SizeOf( Char ) = 2 then
    else
    begin // String is Ansi
      if not K_SaveTextAsAnsi then
      begin // Ansi to Wide
  //      WideBufStr := Text;
        Stream.Write( W2, 2 );
        WideBufStr := N_StringToWide( Text );
        Stream.Write( WideBufStr[1], TextLength * 2 );
        DataSize := 2 + DataSize * 2;
      end
      else
      begin                     // Ansi to Ansi
        Stream.Write( Text[1], TextLength )
      end;
    end; // String is Ansi
  end; // if DataSize > 0 then
  VFile.DFile.DFPlainDataSize := DataSize;

  K_VFStreamFree( VFile );
}
{ Old Code
  K_VFWriteAll ( VFile, PChar(Text), Length(Text) );
}
end; //*** end of K_VFSaveText0

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFSaveText
//************************************************************ K_VFSaveText ***
// Save strings to virtual file
//
//     Parameters
// AText         - saving text
// AVFileName    - virtual file name
// ACreateParams - create file parameters
// Result        - Returns TRUE on success
//
function K_VFSaveText( const AText: string; AVFileName: string;
                       const ACreatePars: TK_DFCreateParams ) : Boolean;
var
  VFile: TK_VFile;
begin
  K_VFAssignByPath( VFile, AVFileName );
  VFile.DFCreatePars := ACreatePars;
  Result := K_VFSaveText0( AText, VFile );
end; // procedure K_VFSaveText

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFLoadText0
//*********************************************************** K_VFLoadText0 ***
// Load text from virtual file
//
//     Parameters
// Text   - loading text
// VFile  - virtual file structure
// Result - Returns true if text is successfully read
//
function  K_VFLoadText0( var Text: string; var VFile: TK_VFile ): Boolean;
var
  TextLength : Integer;
  TextLength1 : Integer;
//  UnicodeText : Boolean;
//  UTF8Text : Boolean;
  W4 : LongWord; // UnicodeSignature
  Stream : TStream;
  WideBufStr : WideString;
  AnsiBufStr : AnsiString;
  TextEncoding : TN_TextEncoding;

Label LExit, LEmpty;

  procedure UTF16BE_To_UTF16LE( PB : TN_BytesPtr );
  var
    i : Integer;
  begin
    for i := 0 to (TextLength shr 1) - 1 do
    begin
      W4 := Byte(PB^);
      PB^ := (PB + 1)^;
      Byte((PB + 1)^) := W4;
      Inc(PB,2);
    end;
  end;

begin
  AnsiBufStr := ''; // to avoid warning in Delhi 7
  WideBufStr := ''; // to avoid warning in Delhi 2010
  TextLength := K_VFOpen( VFile );
  Result := TextLength <> -1;
  if not Result then Exit; // Error while opening

  if TextLength = 0 then
  begin
LEmpty:
    Text := '';
    goto LExit;
  end;

  Stream := K_VFStreamGetToRead( VFile );
  TextEncoding := K_AnalizeStreamBOMBytes( Stream );
  if TextEncoding = teANSI then
  begin
    if SizeOf( Char ) = 2 then
    begin // Ansi to Wide
      SetLength( AnsiBufStr, TextLength );
      Stream.Read( AnsiBufStr[1], TextLength );
      Text := N_AnsiToString( AnsiBufStr );
    end
    else
    begin  // Ansi to Ansi
      SetLength( Text, TextLength );
      Stream.Read( Text[1], TextLength );
    end;
  end
  else
  if TextEncoding = teUTF8 then
  begin
    TextLength := TextLength - 3;
    if TextLength = 0 then goto LEmpty;
    SetLength( AnsiBufStr, TextLength );
    Stream.Read( AnsiBufStr[1], TextLength );
    if SizeOf( Char ) = 2 then
    begin // UTF8 to Wide
      SetLength( Text, TextLength );
      TextLength1 := Utf8ToUnicode( PWideChar(@Text[1]), TextLength, @AnsiBufStr[1], TextLength );
      SetLength( Text, TextLength1 );
    end
    else
    begin  // UTF8 to Ansi
      SetLength( WideBufStr, TextLength );
      TextLength1 := Utf8ToUnicode( @WideBufStr[1], TextLength, @AnsiBufStr[1], TextLength );
      SetLength( WideBufStr, TextLength1 );
      Text := N_WideToString( WideBufStr );
    end;
  end
  else
  if TextEncoding = teUTF16LE then
  begin
  // File contains Wide Chars
    TextLength := TextLength - 2;
    if TextLength = 0 then goto LEmpty;
    if SizeOf( Char ) = 2 then
    begin // Wide to Wide
      SetLength( Text, TextLength shr 1 ); // NumChars = NumBytes div 2
      Stream.Read( Text[1], TextLength );
    end
    else
    begin  // Wide to Ansi
      SetLength( WideBufStr, TextLength shr 1 );
      Stream.Read( WideBufStr[1], TextLength );
      Text := N_WideToString( WideBufStr );
    end;
  end
  else
  if TextEncoding = teUTF16BE then
  begin
    TextLength := TextLength - 2;
    if SizeOf( Char ) = 2 then
    begin // Wide to Wide
      SetLength( Text, TextLength shr 1 ); // NumChars = NumBytes div 2
      Stream.Read( Text[1], TextLength );
      UTF16BE_To_UTF16LE( TN_BytesPtr(@Text[1]) );
    end
    else
    begin  // Wide to Ansi
      SetLength( WideBufStr, TextLength shr 1 );
      Stream.Read( WideBufStr[1], TextLength );
      UTF16BE_To_UTF16LE( TN_BytesPtr(@WideBufStr[1]) );
      Text := N_WideToString( WideBufStr );
    end;
  end
  else
    Result := FALSE;

LExit:
  K_VFStreamFree( VFile );
end; //*** end of K_VFLoadText0

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFLoadText
//************************************************************ K_VFLoadText ***
// Load text from virtual file
//
//     Parameters
// Text           - loading text
// AVFileName     - virtual file name
// APCreateParams - pointer to create parameters, if not nil file create 
//                  parameters of virtual file AVFileName can be return
// APassword      - password if virtual file was encrypted
// Result         - Returns true if text is successfully read
//
function  K_VFLoadText( var Text: string; const AVFileName: string;
                        APCreateParams: TK_PDFCreateParams = nil;
                        const APassword : AnsiString = '' ): Boolean;
var
  VFile: TK_VFile;
begin
  K_VFAssignByPath( VFile, AVFileName );
  VFile.DFCreatePars.DFPassword := APassword;
  Result := K_VFLoadText0( Text, VFile );
  if Result and (APCreateParams <> nil) then
    APCreateParams^ := VFile.DFCreatePars;
end; //*** end of K_VFLoadText

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFLoadText1
//*********************************************************** K_VFLoadText1 ***
// Load Text File to Text
//
//     Parameters
// AFileName - file name to load
// AText     - Resulting String Buffer
// AErrCode  - Resulting Operation ErrCode (TK_DFErrorCode) (=0 if success)
// Result    - Returns error text, if '' then read is OK
//
function K_VFLoadText1( const AFileName : string; var AText : string;
                        out AErrCode : Integer ) : string;
var
  VFile: TK_VFile;
begin
  Result := '';
  K_VFAssignByPath( VFile, AFileName );
  if not K_VFLoadText0( AText, VFile ) then
    Result := K_VFGetErrorString(VFile);
  AErrCode := Ord(VFile.DFile.DFErrorCode);
end; // function K_VFLoadText1

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFLoadStrings
//********************************************************* K_VFLoadStrings ***
// Load strings from virtual file
//
//     Parameters
// AStrings       - loading strings
// AVFileName     - virtual file name
// APCreateParams - pointer to create parameters, if not nil file create 
//                  parameters of virtual file AVFileName can be return (out)
// APassword      - password if virtual file was encrypted (in)
// Result         - Returns true if strings are successfully read
//
function  K_VFLoadStrings ( AStrings: TStrings; const AVFileName: string;
                            APCreateParams: TK_PDFCreateParams = nil;
                            const APassword : AnsiString = '' ): Boolean;
var
  BufStr: String;
begin
  Result := K_VFLoadText( BufStr, AVFileName, APCreateParams, APassword );
  if not Result then Exit; // Error while reading
  AStrings.Text := BufStr;
end; //*** end of K_VFLoadStrings

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFLoadStrings1
//******************************************************** K_VFLoadStrings1 ***
// Load Text File to Strings
//
//     Parameters
// AFileName - file name to load
// AStrings  - TStrings object to load
// AErrCode  - Resulting Operation ErrCode (TK_DFErrorCode) (=0 if success)
// Result    - Returns error text, if '' then read is OK
//
function K_VFLoadStrings1( const AFileName : string;
                                    AStrings : TStrings; out AErrCode : Integer ) : string;
var
  BufStr : string;

begin
  Result := K_VFLoadText1( AFileName, BufStr, AErrCode );
  if Result = '' then
    AStrings.Text := BufStr
  else
    AStrings.Clear;
end; // function K_VFLoadStrings1

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFSaveStrings
//********************************************************* K_VFSaveStrings ***
// Save strings to virtual file
//
//     Parameters
// AStrings      - saving strings
// AVFileName    - virtual file name
// ACreateParams - create file parameters
// Result        - Returns TRUE on success
//
function K_VFSaveStrings( AStrings: TStrings; AVFileName: string;
                           const ACreatePars: TK_DFCreateParams ) : Boolean;
var
  VFile: TK_VFile;
begin
  K_VFAssignByPath( VFile, AVFileName );
  VFile.DFCreatePars := ACreatePars;
  Result := K_VFSaveText0( AStrings.Text, VFile );
end; // procedure K_VFSaveStrings

//*************************************************** K_VFCopyToMemTextFragms
// Copy virtual folder files to memory text fragms
//
//     Parameters
//  MemTextFragms - result memory text fragms object
//  MTFNamePrefix - new TextFragms name prefix (new TextFragmName = MTFNamePrefix + VName)
//  SrcVPathName  - virtual folder name
//  NamePat       - files name pattern (with wild card characters)
//  AVFCFlags     - set of copy options
//
procedure K_VFCopyToMemTextFragms( MemTextFragms : TN_MemTextFragms;
                    const MTFNamePrefix, SrcVPathName : string;
                    const NamePat : string = '*.*';
                    AVFCFlags : TK_VFileCopyFlags = [K_vfcRecurseSubfolders] );
var
  VFS : TK_VFileSearchRec;
  SName, DName : string;
  BufStr : string;
  AVFSFlags : TK_VFileSearchFlags;
begin
  K_VFUDCursorPathDelimsPrep;
  if K_vfcRecurseSubfolders in AVFCFlags then
    AVFSFlags := [K_vfsVFile, K_vfsVDir]
  else
    AVFSFlags := [K_vfsVFile];
  if K_VFFindFirst( VFS, SrcVPathName, AVFSFlags, NamePat ) then begin
    repeat
      if (VFS.VFName[1] = '.') or (VFS.VFSType = K_vfsUndef) then continue;
      SName := SrcVPathName + VFS.VFName;
      DName := MTFNamePrefix + VFS.VFName;
      if VFS.VFSType = K_vfsVDir then
        K_VFCopyToMemTextFragms( MemTextFragms,
                    IncludeTrailingPathDelimiter(DName),
                    IncludeTrailingPathDelimiter(SName),
                    NamePat, AVFCFlags )
      else if K_VFLoadText( BufStr, SName ) then
        MemTextFragms.AddFragm( DName, BufStr );
    until not K_VFFindNext( VFS );
    K_VFFindClose( VFS );

  end;
  K_VFUDCursorPathDelimsRestore;
end; // procedure K_VFCopyFromTextFragmsFile

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFCopyToTextFragmsFile
//************************************************ K_VFCopyToTextFragmsFile ***
// Copy virtual folder files to text file with memory text fragms structure
//
//     Parameters
// TextFragmsFFName - file name  with text fragms structure
// SrcVPathName     - virtual folder name
// NamePat          - files name pattern (with wild card characters)
// AVFCFlags        - set of copy options
//
procedure K_VFCopyToTextFragmsFile( const TextFragmsFFName, SrcVPathName : string;
                                    const NamePat : string = '*.*';
                    AVFCFlags : TK_VFileCopyFlags = [K_vfcRecurseSubfolders] );
var
  MemTextFragms : TN_MemTextFragms;
begin
  MemTextFragms := TN_MemTextFragms.Create;
  K_VFCopyToMemTextFragms( MemTextFragms, '',
                           K_ExpandFileName(SrcVPathName), NamePat, AVFCFlags );
  MemTextFragms.SaveToVFile( TextFragmsFFName, K_DFCreatePlain );
  MemTextFragms.Free;
end; // procedure K_VFCopyFromTextFragmsFile

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFCopyFromTextFragmsFile
//********************************************** K_VFCopyFromTextFragmsFile ***
// Copy Text Fragms From File to Separate VFiles
//
//     Parameters
// DestVPathName    - virtual folder name
// TextFragmsFFName - file name with text fragms structure
//
// Creating virtual files are plane (not encrypted, compressed, check integrity 
// code)
//
procedure K_VFCopyFromTextFragmsFile( const DestVPathName,
                                            TextFragmsFFName : string );
var
  MemTextFragms : TN_MemTextFragms;
  i : Integer;
  DestVPath : string;
begin
  MemTextFragms := TN_MemTextFragms.CreateFromVFile( K_ExpandFileName(TextFragmsFFName) );
  with MemTextFragms.MTFragmsList do begin
    if Count = 0 then Exit;
    DestVPath := K_ExpandFileName( DestVPathName );
    for i := 0 to Count - 1 do
      K_VFSaveStrings( TStrings(Objects[i]), DestVPath + Strings[i], K_DFCreatePlain )
  end;
  MemTextFragms.Free;
end; // procedure K_VFCopyFromTextFragmsFile

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_CopyHTMLinkedVFiles
//*************************************************** K_CopyHTMLinkedVFiles ***
// Copy files linked to given HTM file
//
//     Parameters
// HTMFile   - HTML file name each link file needed to copy
// DestPath  - virtual folder name
// AVFCFlags - set of copy options
//
// Copy files references to which are in given HTM-file (in SRC and HREF 
// HTM-tags attributes). Procedure copies files which references are relative to
// given HTM-file
//
procedure K_CopyHTMLinkedVFiles( const HTMFile, DestPath : string;
                                 AVFCFlags : TK_VFileCopyFlags = [] );
var
  FExt, LPath, LName, SBuf, FName, DFName : string;
  SList : TStringList;
  i, h{, SPos} : Integer;
  St : TK_Tokenizer;

  procedure CopyFilesMarkedByAttr0( const Attr : string );
  var
    AttrLeng : Integer;
    SPos : Integer;
    FExt : string;
  begin
    AttrLeng := Length( Attr );
    while (St.CPos < St.TLength) do begin
      SPos := PosEx( Attr, SBuf, St.CPos );
      if SPos = 0 then break;
      St.CPos := SPos  + AttrLeng;
      LName := St.nextToken;
      if not K_IfURLReference( LName ) then begin
        LName := UnixPathToDosPath( LName );
        FName := LPath + LName;
        DFName:= DestPath + LName;
        if K_VFCopyFile( FName, DFName,
                         K_DFCreatePlain, AVFCFlags ) <> K_vfcrOK then Continue;
        FExt := ExtractFileExt( FName );
        if K_StrStartsWith( '.htm', FExt, true ) then
          K_CopyHTMLinkedVFiles( FName, ExtractFilePath(DFName), AVFCFlags );
      end;
    end;
  end;

begin
  FExt := LowerCase( ExtractFileExt( HTMFile ) );
  if (FExt[2] <> 'h') or (FExt[3] <> 't') then Exit;
  LPath := ExtractFilePath( HTMFile );
  SList := TStringList.Create;
  K_VFLoadStrings ( SList, HTMFile );
  St := TK_Tokenizer.Create( '', ' >', '""''''{}' );
  h := SList.Count - 1;
  for i := 0 to h do
  begin
//*** copy src files
    SBuf := LowerCase( SList.Strings[i] );
    St.setSource( SList.Strings[i] );
//    pcstr0 := PChar(Sbuf);
//    CopyFilesMarkedByAttr( 'src=' );
//    CopyFilesMarkedByAttr( 'href=' );
    CopyFilesMarkedByAttr0( 'src=' );
    CopyFilesMarkedByAttr0( 'href=' );
  end;
  St.Free;
  SList.Free;
end; // procedure K_CopyHTMLinkedVFiles

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_PrepFileFromVFile
//***************************************************** K_PrepFileFromVFile ***
// Prepare physical file using virtual file name
//
//     Parameters
// FName  - virtual file name
// Result - Returns physical file name (virtual file or its's copy)
//
// Create copy of VFile in (#TmpFiles#) if VFile is Memory Object and return 
// file copy name if VFile is physical file then return it's name
//
function K_PrepFileFromVFile( const FName: string ): string;
var
  WFName : string;
  VFile: TK_VFile;
begin
  Result := K_ExpandFileName( FName );
  if K_VFAssignByPath( VFile, Result ) <> K_vftDFile then
  begin
    WFName := Result;
    Result := K_ExpandFileName( '(#TmpFiles#)'+ExtractFileName( WFName ) );
    K_VFCopyFile( WFName, Result, K_DFCreatePlain, [K_vfcOverwriteNewer] );
  end;
end; //*** end of procedure K_PrepFileFromVFile

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFIfExpandedName
//****************************************************** K_VFIfExpandedName ***
// check if Virtual File Name is Expanded
//
//     Parameters
// AVFileName - virtual file name
// Result     - Returns true if FileName is expanded (does not contain Macros)
//
function  K_VFIfExpandedName( const AVFileName : string ) : Boolean;
var
  ColonInd : Integer;
begin
  ColonInd := Pos( ':', AVFileName );
  Result := (ColonInd > 1)          and
            (ColonInd < Length(AVFileName)) and
            (AVFileName[ColonInd + 1] = K_udpPathDelim);
end; // procedure K_VFIfExpandedName

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFExpandFileNameByDirPath
//********************************************* K_VFExpandFileNameByDirPath ***
// Build fully qualified virtual file name using path value from Files Global 
// Paths List
//
//     Parameters
// PathName - Initial DirName (in K_AppFileGPathsList)
// FileName - virtual file name
// Result   - Returns fully qualified virtual file name
//
// Function replace macro calls in FileName and if resulting FileName is not 
// fully qualified build fully qualified file name as PathValue + FileName
//
function  K_VFExpandFileNameByDirPath( const PathName, FileName : string) : string;
begin
  Result := K_ReplaceDirMacro( FileName );
  if not K_VFIfExpandedName( Result ) then
    Result := K_GetDirPath( PathName )+ Result;
end; // procedure K_VFExpandFileNameByDirPath

//##path K_Delphi\SF\K_clib\K_UDT2.pas\K_VFExpandFileName
//****************************************************** K_VFExpandFileName ***
// Build Full File Path + Name using Files Global Paths List 
// (K_AppFileGPathsList)
//
//     Parameters
// FName  - virtual file name (may be not expanded)
// Result - Returns expanded file name
//
function K_VFExpandFileName( const FName : string ) : string;
begin
  Result := K_ReplaceDirMacro( FName );
  assert( K_VFIfExpandedName( Result ), 'Could not expand virtual file name ' + FName );
end; //*** end of procedure K_VFExpandFileName

//****************************************************
//*** end of Virtual Files Procedures
//****************************************************

end.
