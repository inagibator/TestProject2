unit K_CSpace;

interface

uses
  IniFiles, SysUtils, Classes, Controls,
  K_CLib0, K_Script1, K_UDT1, K_FrRaEdit, K_RAEdit, K_Types,
  N_Types, N_ClassRef;

//********************************
//    Time Dimension Types
//********************************
type TK_TimeStampUnits = (    // Time Stamp Units Enum
  K_tduYear,    // = "год"
  K_tduHYear,   // = "полугодие"
  K_tduQuarter, // = "квартал"
  K_tduMonth,   // = "месяц"
  K_tdu10Days,  // = "декада"
  K_tduWeek,    // = "неделя"
  K_tduDay      // = "день"
);

type TK_OneTimeStamp = packed record // One Time Stamp
  SDate   : TDate;      // Time Stamps Array Start Date
  TISize  : Integer;    // Time Interval Size
  TIUnits : TK_TimeStampUnits; // Time Interval Units
end;
type TK_POneTimeStamp = ^TK_OneTimeStamp;

type TK_TimeStampsAttrs = packed record // Time Stamps Array Attributes
  SDate   : TDate;      // Time Stamps Array Start Date
  TISize  : Integer;    // Time Stamps Interval Size
  TIUnits : TK_TimeStampUnits; // Time Stamps Interval Units
// end of TK_OneTimeStamp
  TSUnits : TK_TimeStampUnits; // Time Stamps Shifts Units
end;
type TK_PTimeStampsAttrs = ^TK_TimeStampsAttrs;

//********************************
//*** Code Dimention Structures
//********************************
type TK_CDim = packed record // Code Dimention
  CDCodes   : TK_RArray; // (ArrayOf String) Dimension Codes Array
  CDNames   : TK_RArray; // (ArrayOf String) Dimension Names Array
  CDKeys    : TK_RArray; // (ArrayOf String) Dimension Keys Array
end; // type TK_CDim = record
type TK_PCDim = ^TK_CDim;

type TK_CDIRef = packed record // Code Dimention Item Reference
  CDRCDim    : TN_UDBase; // Code Dimension - TK_UDCDim
  CDRItemInd : Integer;   // Code Dimension Item Index
end; // type TK_CDIRef = packed record
type TK_PCDIRef = ^TK_CDIRef;
type TK_CDIRArray = array of TK_CDIRef;

type TK_CDimEdit = packed record // Data Code Space Edit Structure
  PrevIndex : Integer; // previous Index Value
  Code   : String;  // Dim Code
  Name   : String;  // Dim Code Name
  Key    : String;  // Dim Code Keys
end; // type TK_CDimEdit = record
type TK_PCDimEdit = ^TK_CDimEdit;

type   TK_CDInfoType = ( K_cdiCode, K_cdiName, K_cdiEntryKey, K_cdiSclonKey );
type   TK_CDimRAAttrs = record
  RAContainer : TK_RArray; // Attribute Data Container
  PAData  : Pointer;       // Pointer to Attribute Data Start Element
  ADStep  : Integer;       // Attribute Data Step
  ADCount : Integer;       // Attribute Data Count
end;

type TK_CDRType = (
  K_cdrList, // = 'Список'
  K_cdrBag,  // = 'Мультимножество'
  K_cdrSSet, // = 'Множество'
  K_cdrAny   // = 'Любой'
); // CDim Inds Flags
//{type} TK_CDRTypeSet = Set Of ( K_cdrSSetInds, K_cdrDuplicateInds ); // CDim Inds Flags

type   TK_UDCSDim = class;
{type} TK_UDCDIM = class( TK_UDRArray )

  FFullIndsArray : TN_IArray; // Wrk Inds Array

  constructor Create; override;
  constructor CreateAndInit( Name : string; Aliase : string = '';
                             UDCDimsRoot : TN_UDBase = nil );
  function  GetCDimRAAttrsInfo( out CDimRAAttrs : TK_CDimRAAttrs; UDCDim : TN_UDBase; ItemInd : Integer ) : Boolean;
  procedure GetCDimRAAttrsInfoSafe( out CDimRAAttrs : TK_CDimRAAttrs; UDCDim : TN_UDBase; ItemInd : Integer );
  function  GetCDimCount : Integer;
  procedure SetCDimCount( NCount : Integer );
  procedure PascalInit; override;
//  function  GetCDimAliases : TK_UDCSDBlock;
  procedure ConvAllDataLinks( PConvInds : PInteger; ConvIndsCount : Integer;
                               RemoveUndefInds : Boolean );
  procedure ConvAllCSDims( PConvInds : PInteger; ConvIndsCount : Integer;
                           RemoveUndefInds : Boolean );
  function  ConvUDCSDim ( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                          ChildInd : Integer; ChildLevel : Integer;
                          const FieldName : string = '' ) : TK_ScanTreeResult;
  function  IndexByCode( Code : string ) : Integer;
  function  AddItem( Code : string; Name : string = ''; Key : string = '' ) : Integer;
//  procedure GetItemsInfo( PResult : PString; AInfoType: TK_CDInfoType; Index: Integer;
//                          ILength : Integer = 1; IStep : Integer = SizeOf(string) );
//  function  GetItemInfoPtr( AInfoType: TK_CDInfoType; Index: Integer ): PString;

  procedure GetCSDList( var CSDList : TList; CSDType : TK_CDRType = K_cdrAny );
  function  SearchUDCSDim ( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                            ChildInd : Integer; ChildLevel : Integer;
                            const FieldName : string = '' ) : TK_ScanTreeResult;
  function  IndexOfCSDim( PData : Pointer; Count : Integer;
                          CSDType: TK_CDRType = K_cdrAny ) : TK_UDCSDim;
  function  ConvCDIndsType( CSDimType : TK_CDRType;
                            PInds : PInteger; IndsCount : Integer;
                            NCSDimType : TK_CDRType  ) : Integer;
  procedure BuildCDIndToIndsRInds( PRInds,
                              DestCSDInds : PInteger; DestCSDCount : Integer;
                              SrcCSDInds : PInteger; SrcCSDCount : Integer );
  procedure BuildConvDataIArrays( PNInds: PInteger; NCount: Integer;
                                  PInds: PInteger; Count: Integer;
                                  var ConvDataInds, FreeDataInds, InitDataInds : TN_IArray );

  function  CreateCSDim ( Name : string = ''; Count : Integer = -1;
                          Aliase : string = ''; UDCSDimRoot : TN_UDBase = nil ) : TK_UDCSDim;
  function  GetFullIndsArray: TN_IArray;
  function  GetFullCSDim: TK_UDCSDim;
  procedure ReorderFullCSDim;
  property  CDimCount : Integer read GetCDimCount;
  property  FullIndsArray : TN_IArray read GetFullIndsArray;
  property  FullCSDim  : TK_UDCSDim read GetFullCSDim;
//@New Func for Future Improvement
//  function  RAObjIsSelfCSDim( RACSDim : TK_RArray; IncludeCDRels : Boolean ): Boolean;
    private
  FCSDType: TK_CDRType;
  ListOfCSD : TList;
  FPConvInds : PInteger;
  FRemoveUndefInds : Boolean;
  procedure RebuildFullCSD( Count : Integer; FCSD : TK_UDCSDim = nil );
//  procedure StartScanSubTree( TestNodeFunc : TK_TestUDChild );
  function  UDObjIsSelfCSDim( UDObj : TN_UDBase; IncludeCDRels : Boolean ): Boolean;
  procedure PrepFullCSDimConvContext( PConvInds: PInteger; ConvIndsCount: Integer;
                                   PBConvInds : PInteger; FullCSD : TK_UDCSDim );

end;
{type} TK_UDCDims = Array of TK_UDCDim;

//********************************
//*** Code Dimention Inds Structures
//********************************
{type} TK_CSDimAttrs = packed record // CDim Inds Attributes
  CDim    : TN_UDBase;  // CDim Reference
  CDIType : TK_CDRType; // CDim Inds Type
end; // type TK_CSDimAttrs = packed record
{type} TK_PCSDimAttrs = ^TK_CSDimAttrs;

{type} TK_CSDimEdit = packed record // DCDim Inds and Relation Edit Structure
  Code   : String;  // Space Code
  Name   : String;  // Space Code Name
end; // type TK_CSDimEdit = packed record
{type} TK_PCSDimEdit = ^TK_CSDimEdit;

{type} TK_CSDimSetEdit = packed record // DCDim SubSet  Edit Structure
  IndUse : Byte;    // Index Use Flag
  Code   : String;  // Space Code
  Name   : String;  // Space Code Name
end; // type TK_CSDimSetEdit = packed record
{type} TK_PCSDimSetEdit = ^TK_CSDimSetEdit;


{type} TK_UDCSDim = class( TK_UDRArray )
  constructor Create; override;
  constructor CreateAndInit( Name : string; UDCDim : TK_UDCDim; Leng : Integer = 0;
                             Aliase : string = ''; UDCSDimRoot : TN_UDBase = nil );
  destructor  Destroy; override;
  procedure SetConvDataInds( POrderInds : PInteger; OrderCount : Integer;
                             PFreeInds : PInteger; FreeCount : Integer;
                             PInitInds : PInteger; InitCount : Integer ); virtual;
  procedure ClearConvDataInds; virtual;
  function  GetConvDataInds( out POrderInds : PInteger; out OrderCount : Integer;
                             out PFreeInds : PInteger; out FreeCount : Integer;
                             out PInitInds : PInteger; out InitCount : Integer ) : Boolean; virtual;
  function  CDimIndsConv( UDCD : TN_UDBase; PConvInds : PInteger;
                          RemoveUndefInds : Boolean ) : Boolean; override;
  function  ConvUDCDLinkedData ( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                                 ChildInd : Integer; ChildLevel : Integer;
                                 const FieldName : string = '' ) : TK_ScanTreeResult;
  procedure ChangeValue( PCSDInds : PInteger; Count : Integer; ChangeDataBlocks : Boolean = true );
//  function  IndexByCode( Code : string ) : Integer;
  function  GetPSSet : Pointer;
  procedure ClearAInfo;
    private
  FreeDataInds, OrderDataInds, InitDataInds : TN_IArray;
  IndsAllReadyConved : Boolean;
  ConvDataNeeded : Boolean;
//  CodesList : THashedStringList;
  SSet : TN_BArray;
end;

//********************************
//*** Code Dimentions Correnspodence Structure
//********************************
type TK_CDCorAttrs = packed record
  PrimCSDim : TObject;   // (VArrayOf TK_CSDim) Primary CDim Inds
  SecCSDim  : TK_RArray; // (ArrayOf TK_CSDim) Secondary CDim Inds
  CDCorID   : TK_CDIRef; // Reference to CDim Elem - CDim Correnspodence object ID
end; // type TK_CDCorAttrs = packed record
type TK_PCDCorAttrs = ^TK_CDCorAttrs;

type TK_CDCorEdit = packed record // CDim Correlation Edit Structure
  Code1   : String;  // Space Code
  Name1   : String;  // Space Code Name
  Code2   : String;  // Space Code
  Name2   : String;  // Space Code Name
end; // type TK_CDCorEdit = packed record

type TK_UDCDCor = class( TK_UDRArray ) // Code Dimensions Correlation
  constructor Create; override;
  constructor CreateAndInit( Name : string; APrimCDim : TN_UDBase;
                             ASecCDim : TK_UDCDim = nil; Aliase : string = '';
                             UDCSDRelationsRoot : TN_UDBase = nil );
  function  CDCorCount: Integer;
  function  GetPrimRACSDim : TK_RArray;
  function  GetSecRACSDim : TK_RArray;
  function  GetPrimCDim : TK_UDCDim;
  function  GetSecCDim : TK_UDCDim;
  function  CDimIndsConv( UDCD : TN_UDBase; PConvInds : PInteger;
                          RemoveUndefInds : Boolean ) : Boolean ; override;
  procedure CDimLinkedDataReorder; override;
  procedure ClearAInfo;
  function  GetPFCorInds : PInteger;
//  function  GetPRelSSet : Pointer;
//  procedure ClearRelSSet;
//  procedure SetIndepValue( IUDCSDim : TN_UDBase; DepUDCDim : TN_UDBase; PDepInds : PInteger );
//  procedure SetDepValue( IndepUDCDim : TN_UDBase; PIndepInds : PInteger
//                         DepUDCDim : TN_UDBase; PDepInds : PInteger; Count : Integer );
    private
//  SSet : TN_BArray;
  FCorInds : TN_IArray;
end; // type TK_UDCDCor = class

//********************************
//*** Code Dimentions Relation  Structures
//********************************
type TK_CDRQAHead = packed record // CDims Relation Single SubSet Query Acceleration Head
  SIDInd   : Integer; // Relation CDims SubSet ID Start Index. ID - array of pairs UDCDim/UDCDCor
  SDataInd : Integer; // Start Index for Group of Columns in QAData which contains
                    // QAData[SCInd][0] - 0-element in Vector of Relation CDims SubSet SorIndex
                    // QAData[SCInd+1][i] ... Cols[SCInd+k][i] - Relation i-tuple CDims SubSet Compact Indices
end; // type TK_CDRQAHead = packed record
type TK_PCDRQAHead = ^TK_CDRQAHead;

type TK_CDRQAInfo = packed record // Relation CDims Subsets Sort Info for Query Acceleration
  QAAttrs : TK_RArray; // Array of Relation CDims Subsets QAIDs and QAData (ArrayOf TK_CDRQAHead)
  QAIDs   : TK_RArray; // Array of Relation CDims Subsets IDs (ArrayOf Integer)
  QAData  : TK_RArray; // Array of Relation CDims Subsets Compact Indices (ArrayOf Integer)
end; // type TK_CDRelAttrs = packed record
type TK_PCDRQAInfo = ^TK_CDRQAInfo;

type TK_CDRelAttrs = packed record // CDims Relation Attributes
  CDims   : TObject;    // Relation CDims References (VArrayOf TN_UDBase)
  CDRType : TK_CDRType; // CDims Relation Elements Set Type
  CUDCSDim: TN_UDBase;  // Relation Corrensponding UDCSDim Reference
  CDRQAInfo : TK_CDRQAInfo; // Runtime Relation CDims Subsets Sort Info for Query Acceleration
end; // type TK_CDRelAttrs = packed record
type TK_PCDRelAttrs = ^TK_CDRelAttrs;

type TK_UDCDRel = class( TK_UDCSDim ) // Code Dimensions Relation
  constructor Create; override;
  constructor CreateAndInit( Name : string; PUDCDim : TN_PUDBase = nil;
                             UDCDimCount : Integer = 0; Aliase : string = '';
                             UDCDRelsRoot : TN_UDBase = nil );
//  function  IndexOfCDim( UDCD : TN_UDBase; SInd : Integer = 0 ) : Integer;
  function  CDRelElemsCount : Integer;
  function  CDRelCDimsCount : Integer;
//  function  GetCDRelPUDCDims( out PUDCDims : TN_PUDBase ) : Integer;
//  procedure CDimLinkedDataReorder; override;

  function  CDimIndsConv( UDCD : TN_UDBase; PConvInds : PInteger;
                          RemoveUndefInds : Boolean ) : Boolean; override;
  procedure CDimLinkedDataReorder; override;
//  function  ConvUDCDLinkedData ( UDParent : TN_UDBase; var UDChild : TN_UDBase;
//                                 ChildInd : Integer; ChildLevel : Integer;
//                                 FieldName : string = '' ) : TK_ScanTreeResult;
  procedure SelfLinkedDataReorder( PNInds: PInteger; NCount: Integer  );

    private
end;

//********************************
//*** Link to Code Space Data Blocks Structures
//********************************
type TK_CSDBAttrs = packed record
  ColsRel : TObject;   // (VArrayOf TK_CDRel)  Columns CDim Inds
  RowsRel : TObject;   // (VArrayOf TK_CDRel)  Rows CDim Inds
  CBRel   : TK_RArray; // (ArrayOf  TK_CDRel)  Common CDims Relation (Single Line Relation)
//  CCDR : TK_RArray; // (ArrayOf  TK_CDRel)  Common CDims Relation (Single Line Relation)

end; // type TK_CSDBAttrs = packed record
type TK_PCSDBAttrs = ^TK_CSDBAttrs;

type TK_UDCSDBlock = class(TK_UDRArray)
  constructor Create; override;
  constructor CreateAndInit( AEType : TK_ExprExtType; Name : string;
                             ColCDim : TObject = nil; RowCDim : TObject = nil;
                             Aliase : string = '';
                             UDCSDBRoot : TN_UDBase = nil; InitRCount : Integer = 0 );
  procedure LinkDBlockToCSDim( ColInds, RowInds : TK_UDCSDim );

  function  GetDRACDRel( DInd : Integer ) : TK_RArray;
  function  GetDPSSet( DInd : Integer ) : Pointer;
  procedure ClearDPSSet( DInd : Integer );

  function  GetColRACDRel : TK_RArray;
//  function  GetColPSSet : Pointer;
//  procedure ClearColPSSet;

  function  GetRowRACDRel : TK_RArray;
//  function  GetRowPSSet : Pointer;
//  procedure ClearRowPSSet;

  function  GetCBRACDRel : TK_RArray;
  function  GetCBRACDRelSafe: TK_RArray;
//  function  GetRACDIRef: TK_RArray;
//  function  GetRACDIRefSafe: TK_RArray;
  function  ChangeCDRelIRef( ACDim : TK_UDCDim; AItemInd : Integer;
                          CDimsDuplicate : Boolean = false) : Integer;
{
  procedure SetCDRelFromIRefs( PCDIRefs: TK_PCDIRef; CDIRefsCount: Integer );
  procedure GetCDRelToIRefs( PCDIRefs: TK_PCDIRef );
}
  function  CDimIndsConv( UDCD : TN_UDBase; PConvInds : PInteger;
                          RemoveUndefInds : Boolean ) : Boolean; override;
  procedure CDimLinkedDataReorder; override;

  function  BuildSortedInds( DescSortOrder : Boolean; DInd,
                             ElemInd: Integer; PSortCSDim: PInteger ) : Integer;
  function  BuildSortedCSDim( DescSortOrder : Boolean; DInd : Integer;
                               ElemInd : Integer; PSortCSDim : PInteger ) : Integer;

  function  GetDataType : TK_ExprExtType; virtual;
  function  GetDataPointer( ICol, IRow :Integer ) : Pointer; virtual;
  property  PData[ ICol, IRow :Integer ] : Pointer read GetDataPointer; default;
    private
  SSet : array [0..1] of TN_BArray;
end;

//{type} TK_ERDBDirAttrs = packed record // Data Block Direction Attributes
//  CDRel      : TObject;   // CDim Relation - VArrayOf TK_CDRel
//  TimeStamps : TObject;   // Time Stamps - VArrayOf TK_TimeStamps
//  RAList     : TK_RArray; // List of Attributes - ArrayOf TK_RAList
//end; // type TK_DBDirAttrs = packed record
//{type} TK_PERDBDirAttrs = ^TK_ERDBDirAttrs;

{type} {TK_ERDBAttrs = packed record // Data Block Relation Attributes
  // Cols Direction Attributes
  ColsRel   : TObject;   // Cols CDim Relation - VArrayOf TK_CDRel
  ColsTS    : TObject;   // Cols CTime Stamps - VArrayOf TK_TimeStamps
  ColsAttrs : TK_RArray; // List of Cols CAttributes - ArrayOf TK_RAList or Static Array
  // end of Cols TK_ERDBDirAttrs

  // Rows Direction Attributes
  RowsRel   : TObject;   // Rows CDim Relation - VArrayOf TK_CDRel
  RowsTS    : TObject;   // Rows CTime Stamps - VArrayOf TK_TimeStamps
  RowsAttrs : TK_RArray; // List of Rows CAttributes - ArrayOf TK_RAList or Static Array
  // end of Rows TK_ERDBDirAttrs

  // Block Common Attributes
  CBRel       : TK_RArray;       // Common Code Dimension Relation (Single Dimension)
  CBTimeStamp : TK_OneTimeStamp; // Common Time Stamp
  CBAList     : TK_RArray;       // Common Attributes List
end; // type TK_ERDBAttrs = packed record}

type TK_ERDBAttrs = packed record // Data Block Relation Attributes
  // Block CSDBAttrs
  ColsRel   : TObject;   // Cols CDim Relation - VArrayOf TK_CDRel
  RowsRel   : TObject;   // Rows CDim Relation - VArrayOf TK_CDRel
  CBRel  : TK_RArray; // Common Block Relation - ArrayOf TK_CDRel (Single Dimension)
  // end of TK_CSDBAttrs

  // Block TimeStamps
  ColsTS    : TObject;   // Cols CTime Stamps - VArrayOf TK_TimeStamps
  RowsTS    : TObject;   // Rows CTime Stamps - VArrayOf TK_TimeStamps
  CBTimeStamp : TK_OneTimeStamp; // Common Time Stamp
  // end of Block TimeStamps

  // Block Attributes
  ColsAttrs : TK_RArray; // List of Cols CAttributes - ArrayOf TK_RAList or Static Array
  RowsAttrs : TK_RArray; // List of Rows CAttributes - ArrayOf TK_RAList or Static Array
  CBAList   : TK_RArray; // Common Attributes List
  // end of Block Attributes
end; // type TK_ERDBAttrs = packed record
type TK_PERDBAttrs = ^TK_ERDBAttrs;

type TK_UDERDBlock = class(TK_UDCSDBlock)
  constructor Create; override;
end;

type  TK_UDCSDimTypeFilterItem = class( TK_UDFilterItem ) //
  CDIType : TK_CDRType; // CDim Inds Flags
  constructor Create( ACDIType : TK_CDRType;
                      AExprCode : TK_UDFilterItemExprCode = K_ifcOr);
  function    UDFITest( const DE : TN_DirEntryPar ) : Boolean;  override;
end; //*** end of type TK_UDCSDimTypeFilterItem = class( TK_UDFilterItem )

type  TK_UDCDRelTypeFilterItem = class( TK_UDFilterItem ) //
  CDIType : TK_CDRType; // CDim Inds Flags
  constructor Create( ACDIType : TK_CDRType;
                      AExprCode : TK_UDFilterItemExprCode = K_ifcOr);
  function    UDFITest( const DE : TN_DirEntryPar ) : Boolean;  override;
end; //*** end of type TK_UDCSDimTypeFilterItem = class( TK_UDFilterItem )

type TK_RAFCDItemEditor0 = class( TK_RAFExtCmBEditor ) // ***** UDBase Field  Viewer
  PCDimNames     : PString;
  CDimNamesCount : Integer;
  function  GetItemString( Ind : Integer ) : string;
  procedure PrepareCmBList;
  function  CanUseEditor( ACol, ARow : Integer; var RAFC : TK_RAFColumn ) : Boolean; override;
  function  GetText( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
                     PHTextPos : Pointer = nil ): string; override;
  procedure OnChangeH( Sender: TObject ); override;
  procedure SetUDCDimInfo( UDCDim : TK_UDCDim );
end; //*** type TK_RAFCDItemEditor0 = class( TK_RAFViewer )

type TK_RAFCDItemEditor = class( TK_RAFCDItemEditor0 ) // ***** UDBase Field  Viewer
  CDimColInd : Integer;
  procedure InitCDimNames( var RAFC: TK_RAFColumn; LRow: Integer );
  function  CanUseEditor( ACol, ARow : Integer; var RAFC : TK_RAFColumn ) : Boolean; override;
  function  GetText( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
                     PHTextPos : Pointer = nil ): string; override;
//  procedure OnChangeH( Sender: TObject ); override;
end; //*** type TK_RAFCDItemEditor = class( TK_RAFViewer )

type TK_CDRelCtrl = class
  RACDRel1 : TK_RArray; // 1-st CDim Relation RArray
  RACDRel2 : TK_RArray; // 2-nd CDim Relation RArray
  UDCDCors : TN_UDArray; // Array of CDims Correspondences wich are used for Correlation Indices Building

  function BuildCDimsIntersection : Integer;
  function BuildRACDRelsQAInds : Boolean;
  function BuildRACDRels1To2CInds( RInds : PInteger ) : Boolean;
  function BuildCDRels1To2CInds( CDRel1, CDRel2 : TObject; RInds : PInteger ) : Boolean;
//    private
    public
  PUDCDims1 : TN_PUDBase;
  PUDCDims2 : TN_PUDBase;
  UDCDims1Count : Integer;
  UDCDims2Count : Integer;

  JCDimsOrder1 : TN_IArray; // CDims Order Indices for Relation1
  JCDimsOrder2 : TN_IArray; // CDims Order Indices for Relation2
  JUDCDCors    : TN_UDArray;// UDCDCors for Relation2

  QAWidth, QAIndex1, QAIndex2 : Integer;

  AllUDCDims : TN_UDArray;
  AllUDCDMarkers  : TN_IArray;

  RACDRel1SIndex : Integer; // SortIndex in RACDRel1
  RACDRel2SIndex : Integer; // SortIndex in RACDRel2

  procedure ClearCDimsMarkers;
  procedure SaveCDimsMarkers;
  procedure RestoreCDimsMarkers;
    private
end; //*** type TK_CDRelCntrl = class

type TK_QCDim0 = record
  QCDAttrs  : TK_CSDimAttrs; // UDCDim Reference and Indices Type
  QCDCount  : Integer;       // CDim Self Counter needed for Query Acceleration - Length of Bit Scale
                             // CDCount - =-1 All CDim Elements are Allowable
                             //           =0  All CDim Elements are not Allowable
  QInds     : TN_IArray;     // CDim Query Indices
  QBInds    : TN_IArray;     // CDim Query Indices
  QCDSet    : TN_BArray;     // CDim Set Bit Scale
  QUDCSDim : TK_UDCSDim;     // CDim UDInds Reference
end;
type TK_PQCDim0 = ^TK_QCDim0;
type TK_QCDArray0 = array of TK_QCDim0;

type TK_QBDFlags0 = Set of (K_qbdCreateUDCSDim);

type TK_QueryBlockData0 = class
//*** Input Query Params
  SrcUDRoots  : TList;   // Source UDRoots List
//  SrcUDRoots  : TN_UDArray;   // Source UDRoots Array
  QCDims : TK_QCDArray0;       // Array of CDims Used in Query
  ResColCDimsInds : TN_IArray; // Result Columns Ordered CDims Indices in QCDims
  ResRowCDimsInds : TN_IArray; // Result Rows Ordered CDims Indices in QCDims
  ResColCDimInd : Integer;    // Result Columns Ordered CDim Index in QCDims
  ResRowCDimInd : Integer;    // Result Rows Ordered  CDim Index in QCDims
  QDataType : TK_ExprExtType; // Type Of Selecting Data Blocks
  QueryFlags : TK_QBDFlags0;   // Query Flags
  InitResultFunc : TK_RAInitFunc;
  ResultUDRoot: TN_UDBase;   // Query Data Blocks UDRoot
  OnQueryRACSDBlockData : procedure ( UDCSDBlock : TK_UDCSDBlock ) of object;
  OnGetNewResultBlockName : function  ( AQCDims : TK_QCDArray0; ADValCSDim : TN_IArray ) : string of object;

//*** Query RunTime Context
  SrcUDCSDBlocks : TList;    // Source UD Data Blocks TList
  QBElemType : TK_ExprExtType; // Type Of Selecting Data
  CurDValCDimsInds : TN_IArray;   // Current Scalar Data Value CDims Elems Indices
  CurRDBlockCDimsInds : TN_IArray; // Current Res Data Block CDims Elems Indices

  CurUDCSDBlockUseFlag : Boolean; // Use Current Result Data Block for Next Adding Scalar Value
  CurUDCSDBlock : TK_UDCSDBlock;  // Current Result Data Block
  DValCSDimSize : Integer;       //
  ResultBDValCDIHCodes : TN_IArray; // Result UD Data Blocks CDIRefsInds Array
  RVCDICapacity : Integer;
  QCDim : TK_QCDim0; // Used while AddQueryCSDim and AddQueryCDIRef

//*** Query Results
  ResultUDBlocks : TList;    // Result UD Data Blocks TList
  ResultRABlocksMatrix : TK_RArray; // Result RA Data Blocks RAMatrix

  constructor Create;
  destructor  Destroy; override;
  procedure Clear;
  procedure UnmarkQueryUDCDims;
  procedure SetCDimQInds;
  procedure AddUDRoot( UDRoot : TN_UDBase );
  procedure AddQueryCSDim( CDObject : TObject; Included : Boolean = true );
  procedure AddQueryCDIRef( ACDIRef : TK_CDIRef; Included : Boolean = true );
  procedure SetResBlocksCDims( UDColsCDim, UDRowsCDim : TN_UDBase );
  procedure AddResBlocksMatrixCDims( UDColsCDim, UDRowsCDim : TN_UDBase );
  procedure AddUDCSDBlockData( UDCSDBlock : TK_UDCSDBlock );
  function  GetNewResultBlockObjName( AQCDims : TK_QCDArray0; ADValCSDim : TN_IArray ) : string;
  procedure ScanSrcRoots( TypeName : string = '' ); // Scan Src UDRoots for Proper UDCSDBlocks
  procedure QuerySrcData;                           // Query Proper UDCSDBlocks for Data
  procedure AddResDataValue( var Value ); // Add New Result Data Value
//*** Search UDCSDBlock in Query Blocks List After Query Action
  function  GetResCSDBlockInds( PCDIRefs : TK_PCDIRef; Count : Integer = 1 ) : TN_IArray;
  function  GetResCSDBlock( DBInd : Integer ) : TK_UDCSDBlock;

    private
  NewBlockAdlerCode : Integer;
  procedure AddQueryCSDim0( IndsTypeFlag : Integer; Included : Boolean;
                             PInds : PInteger;  IndsCount : Integer );
  function  TestUDCSDBlock ( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                             ChildInd : Integer; ChildLevel : Integer;
                             const FieldName : string = '' ) : TK_ScanTreeResult;
  function  CheckCSDBlockAttrs( UDCSDBlock : TK_UDCSDBlock ) : Boolean;
  function  GetQCDimPSet( CDimInd : Integer ) : Pointer;
  function  GetQCDimCurDataIndex( ResCDimInd : Integer) : Integer;
  function  PrepResBlockCSDimObject( ResCDimInd : Integer) : TObject;
  function  ResCSDBlockByCDValInds : TK_UDCSDBlock;
end; //*** type TK_QueryBlockData0 = class

//************************************************************
//                   Query Block Data
//************************************************************

//*** Query Block Data Auxilliary types
type TK_QCSDim = record
  QUDCDim : TN_UDBase;   // CDim UDObj
  QCSDSet : TN_BArray;   // CSDim Set
  NCSDInd : Integer;     // Index of Next CSDim for Current CDim
end;
type TK_PQCSDim = ^TK_QCSDim;
type TK_QCSDimArray = array of TK_QCSDim;

type TK_QCDRel = record
  QRACDRel     : TK_RArray;   // Query CDim Relation RArray
  QSRACDRel    : TK_RArray;   // Relation Source RAObj (TK_CSDim, TK_CDRel, TK_CSDBlock (Block of Relations))
  QCSDInds   : TN_IArray;   // Array of Indices of QCDRelation CSDims in Current Scalar Relation
  QAIndex    : TN_IArray;   // Array of Relation QAIndex
  QAWidth    : Integer;     // QAIndex Width
  QACDIWidths: TN_IArray;   // Array of Relation Widths of CDims Inidices for QAIndex
  QUDCDRel   : TK_UDRArray; // Relation UDObj (TK_UDCSDim, TK_UDCDRel, TK_UDCSDBlock (Block of Relations))
  QLSRels    : TN_IArray;   // Array of Inds in AllQCDRels for Level SubRelations
  QRBlockRelFlag : Boolean; // Flag mark Relations used in Result MultuLevel Block
end;
type TK_PQCDRel = ^TK_QCDRel;
type TK_QCDRelArray = array of TK_QCDRel;

type TK_QBDLevelFlags = Set of (
  K_qbdlUDataColsAutoDelete, // Undefine Columns Data Auto Deletion
  K_qbdlUDataRowsAutoDelete  // Undefine Rows Data Auto Deletion
);
type TK_QBDLevel = record
  //    Ind >=0 - QCDRel Ind,
  //        =-1 - no Relation (Col or Row) in current level,
  //        =-100 - N - current SubRelation in the Columns direction in previous Level N steps UP
  //        =-200 - N - current SubRelation in the Rows direction in previous Level N steps UP
  ColQCDRInd   : Integer; // Query CDims Relations Index for Level Columns
  RowQCDRInd   : Integer; // Query CDims Relations Index for Level Rows
  LFlags     : TK_QBDLevelFlags; //
end;
type TK_PBDLevel = ^TK_QBDLevel;
type TK_QBDLevelArray = array of TK_QBDLevel;

type TK_QBDFlags = Set of (
  K_qbdVarTypeBlock,           // Allows variate Type of Scalar Blocks
  K_qbdSkipUDRBlockCreation,   // Prevents UDObj Container Creation for Result RACSDBlock
  K_qbdSkipAutoCreateUDCDRels  // Prevents UDObj Containers Creation for Result Block Directions RACDRels
);

type TK_QueryBlockData = class

//*** Input Query Params
  QFlags      : TK_QBDFlags;
  QSrcUDRoots : TList;        // Source UDRoots List
  AllQCSDims  : TK_QCSDimArray; // Array of all UDCDims (and CSDims) Used in Query Relations
  AllQCDRels  : TK_QCDRelArray; // Array of all Query CDRelations
  //    Ind >=0 - QCDRel Ind,
  //        =-1 - no Relation (Col or Row) in current level,
  //        =-100 - N - current SubRelation in the Columns direction in previous Level N steps UP
  //        =-200 - N - current SubRelation in the Rows direction in previous Level N steps UP
  RBLevels : TK_QBDLevelArray; // Array of Multidimensional Result Block Levels Struct


  ResultBlockName : string;
  ResultBlockAliase : string;
  ResultUDRoot : TN_UDBase;   // Query Data Blocks UDRoot

  InitResultValFunc : TK_RAInitValFunc;
  OnQueryRACSDBlockData : procedure ( RACSDBlock : TK_RArray ) of object;


//*** Query RunTime Context
  CSCSDimsCount  : Integer;    // Number of CSDims used in Query Conditions
  RBLevelsCount  : Integer;    // Result Block Levels Count

  FullCDIntInds  : TN_IArray;  // Array for Marking CDims while Query SrcBlocks
  CSCSDimsInds   : TN_IArray;  // Array for Current Scalar Relation Elements Inds
  CSUsedCSDims   : TN_BArray;  // Array with Current Query CSDims Used Property

  QSrcRACSDBlocks: TList;      // Query Source RACSDBlocks List

  RBSLevelRAType : TK_ExprExtType; // Type Of Scalars Container Result CSDBlock - Var
  QBSLevelRAType : TK_ExprExtType; // Type Of Scalars Container Query CSDBlock - Var
  CurRBColDInds  : TN_IArray;      // Array of Multidimensional Result Block Columns Inds for Current Scalar
                                   // Array has length equal the number of Levels in Result Block,
  CurRBColCDRelInds : TN_IArray; // Array of Multidimensional Result Block Columns CDRels Inds for Current Scalar
                                 // Array has length equal the number of Levels in Result Block,
  CurRBRowDInds     : TN_IArray; // Array of Multidimensional Result Block Rows Inds for Current Scalar
                                 // Array has length equal the number of Levels in Result Block,
  CurRBRowCDRelInds : TN_IArray; // Array of Multidimensional Result Block Rows CDRels Inds for Current Scalar
                                 // Array has length equal the number of Levels in Result Block,
//*** Query Results
  CurRDBlock    : TK_RArray;     // Current Result MultiLevel Root RACSDBlock
  CurUDRDBlock  : TK_UDCSDBlock; // Current Result Data Block UDObj
  DuplRBDInds   : TK_RArray; // Array Of Multidimensional Result Block Inds for Scalars which are Duplicate during data access
                             // Array of Groups, each group of Inds has length equal the number of Levels in Result Block,
                             // each Group element contain the pair of Inds(ICol and IRow) for each block level
  constructor Create;
  destructor  Destroy; override;
  procedure Clear;
  procedure AddUDRoot( UDRoot : TN_UDBase );
  procedure UnmarkQueryUDCDims;
  function  AddQCondition( CDObject : TObject ) : Integer;

  procedure ScanSrcRoots( TypeName : string = '' ); // Scan Src UDRoots for Proper UDCSDBlocks
  procedure QuerySrcBlocksData;                     // Query Proper UDCSDBlocks for Data
  procedure DelResultBlockUData;                    // Delete Result Block Elems with Undef Data
  procedure QueryRACSDBlockData( ARACSDBlock : TK_RArray );  // Query Source RACSDBlock Data
  procedure AddRACSDBlockToQueue( ARACSDBlock : TK_RArray ); // Add Source RACSDBlock to Queue
  procedure AddResDataValue( var Value ); // Add New Result Data Value
  procedure SetEmptyValue( var EValue; TypeCode : TK_ExprExtType );
  procedure InitScanSrcBlocksContext;
  procedure InitQueryDataContext;


    private

//************

  ReadyToScanSrcBlocks : Boolean;
  ReadyToQueryDataFromSrcBlocks : Boolean;
  CurQAIndexElem : TN_UI4Array; // Buffer for current Scalar QAIndex Data
  QBElemType : TK_ExprExtType;  // Type Of Selecting Data
  UserRBEEmptyVal: TK_RArray;   // User Result Block Element Empty Value
  CurRBEEmptyVal: TK_RArray;    // Current Result Block Element Empty Value

  procedure FillCDElemIndsByRACDRel( RACDRel : TK_RArray; RelElemInd : Integer;
                                     UsedCSDimInds : TN_IArray );
  function  CheckIndsArray( PIA : PInteger; Count, ErrBound : Integer ) : Boolean;
  function  CheckRACSDBlockCDims( ARACSDBlock : TK_RArray ) : Boolean;
  function  TestUDCSDBlock ( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                             ChildInd : Integer; ChildLevel : Integer;
                             const FieldName : string = '' ) : TK_ScanTreeResult;
  function  GetResRACSDBlock : TK_RArray;
  function  GetPEmptyValue( TypeCode: TK_ExprExtType ) : Pointer;
  procedure OptimizedAutoCreatedUDCDRels;

end; //*** type TK_QueryBlockData = class
//************************************************************
//                 end of  Query Block Data
//************************************************************

const
//*** CDim and CSDim  Childs Structure
//*** CDim and CSDim  Childs Names
  K_dcsCDIAliasesName   = 'Aliases';
  K_dcsCDIAliasesAliase = 'Названия';


//*** CDim and User Root  Names
  K_CDimsRootName = 'CDims';
  K_CDimsRootAliase = 'Измерения';


//*** New CDim Names
  K_FCDimNewName = 'CDim';
  K_FCDimNewAliase = 'Untitled';

//*** CDim Full CSDim Names
  K_FFulCSDimName = '@FullCSDim';
  K_FFulCSDimAliase = 'Полный набор элементов';

//*** New CSDim  Names
  K_FCSDimNewName = 'CSD';
  K_FCSDimNewAliase = 'Untitled';

//*** New Relation  Names
  K_FCSDRelNewName = 'CDR';
  K_FCSDRelNewAliase = 'Untitled';

var
  K_CurCDimsRoot   : TN_UDBase; // Code Dimentions Root
  K_TimeStampsRAType : TK_ExprExtType;
  K_BBLevelRAType  : TK_ExprExtType;
  K_BVBLevelRAType : TK_ExprExtType;
  K_CSDimRAType    : TK_ExprExtType;
  K_CDRelRAType    : TK_ExprExtType;
  K_CSDBAttrsRAType: TK_ExprExtType;
  K_ERDBAttrsRAType: TK_ExprExtType;


//*** Get TypeCode Funcs
function  K_GetOneTimeStampRAType : TK_ExprExtType;
function  K_GetTimeStampsRAType : TK_ExprExtType;
function  K_GetCSDimRAType      : TK_ExprExtType;
function  K_GetCDRelRAType      : TK_ExprExtType;
function  K_GetCSDBAttrsRAType  : TK_ExprExtType;
function  K_GetERDBAttrsRAType  : TK_ExprExtType;
function  K_GetCSBVBLevelRAType   : TK_ExprExtType;
function  K_GetCSBBLevelRAType    : TK_ExprExtType;
function  K_GetERBVBLevelRAType   : TK_ExprExtType;
function  K_GetERBBLevelRAType    : TK_ExprExtType;

//*** RATimeStamps
function  K_ShiftRATSDate( SDate : TDateTime; Delta : Integer;
                           DUnits : TK_TimeStampUnits ) : TDateTime; overload;
function  K_ShiftRATSDate( SDate : TDateTime; Delta : Double;
                           DUnits : TK_TimeStampUnits ) : TDateTime; overload;
procedure K_GetRATimeStampsDates( TS : TK_RArray; PDate : PDateTime );
procedure K_GetRATimeStampsStrings( TS : TK_RArray; PSDate : PString; Format : string = '' );


//*** RADBlocks
type TK_UseBlockType = (K_ubtNotDBlock, K_ubtCSDBlock, K_ubtERDBlock);
function  K_TestDBlockType( TypeDTCode : Integer; UseERDBlock : Boolean = false ) : TK_UseBlockType;
procedure K_BuildDBlockTypesList( TypesList : TStrings; UseERDBlock : Boolean = false );
function  K_GetDBlockTypeByElemTypeCode( ElemTypeDTCode : Integer; UseERDBlock : Boolean = false ) : TK_ExprExtType;
function  K_IfBBLevelRAType( BlockRAType : TK_ExprExtType ) : Boolean;
procedure K_InitRADBlockData( RADBlock : TK_RArray; Ind, Count: Integer );
procedure K_InitRADBlockDims( RADBlock : TK_RArray; ColCDim : TObject = nil;
                              RowCDim : TObject = nil; InitRCount : Integer= 0 );
function  K_CreateRADBlock( AEType : TK_ExprExtType;
                              ColCDim : TObject = nil;
                              RowCDim : TObject = nil;
                              CRFlags : TK_CreateRAFlags = [];
                              InitRCount : Integer = 0 ) : TK_RArray;
function  K_GetRADBlockRACBRelSafe( RA : TK_RArray ) : TK_RArray;
type TK_DBlockReorderSkip = (K_dbrAllDone, K_dbrSkipCDRel, K_dbrSkipTS, K_dbrSkipAttrs );
procedure K_ReorderDBlockRows( RA : TK_RArray; DBlockReorderSkip : TK_DBlockReorderSkip;
                               POrderInds: PInteger; OrderIndsCount : Integer;
                               PFreeInds: PInteger; FreeIndsCount : Integer;
                               PInitInds: PInteger; InitIndsCount : Integer );
procedure K_ReorderDBlockCols( RA : TK_RArray; DBlockReorderSkip : TK_DBlockReorderSkip;
                               POrderInds: PInteger; OrderIndsCount : Integer;
                               PFreeInds: PInteger; FreeIndsCount : Integer;
                               PInitInds: PInteger; InitIndsCount : Integer );
procedure K_RADBlockDelUndefElems( RA : TK_RArray; PUDataValue : Pointer;
                                     DelDir : Integer = 2 );
procedure K_RADBlockMLDelUndefElems( RA : TK_RArray; UDataFunc : TK_RAInitValFunc;
                                       PColLevelInds : PInteger; ColLevelIndsCount : Integer;
                                       PRowLevelInds : PInteger; RowLevelIndsCount : Integer;
                                       CurLevel : Integer );
function  K_RADBlockCDimIndsConv( RA : TK_RArray; UDCDim: TN_UDBase;
                                    PConvInds: PInteger;
                                    RemoveUndefInds: Boolean ) : Boolean;
procedure K_RADBlockCDLDataReorder( RA : TK_RArray );

//*** RACSDBlocks
function  K_IfRADBlock( RADBlock : TK_RArray ) : Boolean;

//*** RACSDims
function  K_CheckIfUDCSDimIsFull( UDCSDim : TN_UDBase ) : Boolean;
procedure K_SetRACSDimCDim( CSDRA : TK_RArray; UDCDim : TK_UDCDim );
function  K_CreateRACSDim( UDCDim : TK_UDCDim; CSDimType : TK_CDRType;
                           CRFlags : TK_CreateRAFlags ) : TK_RArray;
function  K_IndexOfRACSDimSelfInd( CSDRA : TK_RArray; CDInd : Integer ) : Integer;
function  K_GetRACSDimCDim( CSDRA : TK_RArray ) : TK_UDCDim;
function  K_BuildRACSDimSSet( CSDRA : TK_RArray; var SSet : TN_BArray  ) : Integer;
function  K_RebuildRACSDim( CSDRA : TK_RArray; UDCDim : TN_UDBase;
                            PConvInds : PInteger; RemoveUndefInds : Boolean;
                            POrderDataInds, PFreeDataInds : TN_PIArray ) : Boolean;
procedure K_BuildCrossIndsByRACSDims( PRInds,
                              DestCSDInds : PInteger; DestCSDCount : Integer;
                              SrcCSDInds : PInteger; SrcCSDCount : Integer;
                              PFullCDimInds : PInteger; FullCDimIndsCount : Integer );
procedure K_BuildConvDataIArraysByRACSDims( DestCSDInds : PInteger; DestCSDCount : Integer;
                                            SrcCSDInds : PInteger; SrcCSDCount : Integer;
                                            PFullCDimInds : PInteger; FullCDimIndsCount : Integer;
                                        var ConvDataInds, FreeDataInds, InitDataInds : TN_IArray );

//*** UDCDims
procedure K_MarkRAUDCDims( PUDCDims : TN_PUDBase; UDCDimsCount : Integer;
                           PInds : PInteger = nil );
procedure K_UnMarkRAUDCDims( PUDCDims : TN_PUDBase; UDCDimsCount : Integer;
                             PInds : PInteger = nil );
function  K_BuildCrossIndsRAUDCDims( PUDInds : PInteger; PUDCDims : TN_PUDBase;
                                     UDCDimsCount : Integer ) : Integer;

//*** RACDRels
function  K_GetRACDRelUDCDimsIndices( PCDInds : PInteger; CDRelRA : TK_RArray;
                     PUDCDim : TN_PUDBase; UDCDimCount : Integer;
                     UDCDimStep : Integer = SizeOf(Integer) ) : Integer;
function  K_AddUDCDimsToRACDRel( RACDRel : TK_RArray;
                     PUDCDim : TN_PUDBase; UDCDimCount : Integer;
                     UDCDimStep : Integer = SizeOf(Integer) ) : Integer;
procedure K_RemoveUDCDimsFromRACDRelByInds( CDRelRA : TK_RArray;
                                  PCDInds : PInteger; IndsCount : Integer );
function  K_RemoveUDCDimsFromRACDRel( CDRelRA : TK_RArray;
                     PUDCDim : TN_PUDBase; UDCDimCount : Integer;
                     UDCDimStep : Integer = SizeOf(Integer) ) : Integer;
procedure K_LeaveUDCDimsInRACDRelByInds( CDRelRA : TK_RArray;
                     PCDInds : PInteger; IndsCount : Integer );
function  K_LeaveUDCDimsInRACDRel( CDRelRA : TK_RArray;
                     PUDCDim : TN_PUDBase; UDCDimCount : Integer;
                     UDCDimStep : Integer = SizeOf(Integer) ) : Integer;
function  K_BuildRACDRelsCProduction( RCD1, RCD2 : TK_RArray; CRFlags : TK_CreateRAFlags ) : TK_RArray;
function  K_CreateRACDRel( PUDCDim : TN_PUDBase; UDCDimCount : Integer;
                           ACDRType : TK_CDRType;
                           CRFlags : TK_CreateRAFlags ) : TK_RArray;
procedure K_FreeRACDRelCDims( RACDRel : TK_RArray; FreeRACDims : Boolean );
procedure K_SetRACDRelFromIRefs( RACDRel : TK_RArray; PCDIRefs: TK_PCDIRef;
                                 CDIRefsCount: Integer );
procedure K_GetRACDRelToIRefs( RACDRel : TK_RArray; PCDIRefs: TK_PCDIRef );
function  K_GetRACDRelPUDCDims( CDRelRA : TK_RArray; out PUDCDims : TN_PUDBase ) : Integer; overload;
function  K_GetRACDRelPUDCDims( CDRelRA : TK_RArray; out UDimsCount : Integer ) : TN_PUDBase; overload;
function  K_GetRACDRelUDCSDim( RACDRel: TK_RArray ) : TK_UDCSDim;
function  K_IndexOfRACDRelCDim( CDRelRA : TK_RArray; UDCDim : TN_UDBase;
                                SCDInd : Integer = 0 ) : Integer;
procedure K_CheckRACDRelInds( CDRelRA : TK_RArray; PRowFlags, PColFlags : PInteger );
function  K_RebuildRACDRel( CDRelRA : TK_RArray; CDInd : Integer;
                            PConvInds : PInteger; RemoveUndefInds : Boolean;
                            POrderDataInds, PFreeDataInds : TN_PIArray ) : Boolean; overload;
function  K_RebuildRACDRel( CDRelRA : TK_RArray; UDCDim : TN_UDBase;
                            PConvInds : PInteger; RemoveUndefInds : Boolean;
                            POrderDataInds, PFreeDataInds : TN_PIArray ) : Boolean; overload;
procedure K_RACDRelLinkedDataReorder( RACDRel : TK_RArray );
function  K_BuildCSDBRelFromRACDRelByInds( CDRelRA : TK_RArray;
                                    PLevelCDInds : PInteger; LevelCount : Integer;
                                    CreateRAFlags : TK_CreateRAFlags = [];
                                    DescendingOrder : Boolean = false ) : TK_RArray;
function  K_BuildCSDBRelFromRACDRel( CDRelRA : TK_RArray; PLevelCDims : TN_PUDBase;
                                     LevelCount : Integer;
                                     CreateRAFlags : TK_CreateRAFlags = [];
                                     DescendingOrder : Boolean = false ) : TK_RArray;
procedure K_BuildRACDRelOrdInds( PInds : PInteger; CDRelRA : TK_RArray;
                                 CDInd : Integer; DescendingOrder : Boolean ); overload;
function  K_BuildRACDRelOrdInds( PInds : PInteger; CDRelRA : TK_RArray;
                                 UDCDim : TN_UDBase; DescendingOrder : Boolean ) : Boolean; overload;
procedure K_RemoveRACDRelEmptyElems( CDRelRA : TK_RArray; ClearAnyFlag : Boolean = false );

//*** RACDRel QAIndex
function  K_BuildQAIndexElemsWidth( var CIndsWidth : TN_IArray;
                                    QAIndexCDCount : Integer;
                                    PQAIndexCD    : TN_PUDBase;
                                    PQAIndexCDCor : TN_PUDBase = nil ) : Integer;
procedure K_PrepQAIndexElem( PQAIndex : PInteger; CIndsWidth : TN_IArray;
                             PQACDRInds : PInteger; PCDInds : PInteger = nil;
                             PQAIndexCDCor : TN_PUDBase = nil );
procedure K_BuildQAIndex( PQAInds : PInteger; QAIndsCount, QAIndsBStep : Integer;
                          PRelInds : PInteger; RelIndsElemCount : Integer; RelIndsBStep : Integer;
                          CIndsWidth : TN_IArray;
                          PCDInds : PInteger = nil;
                          PQAIndexCDCor : TN_PUDBase = nil );
procedure K_GetRACDRelQAIndexUDID( PQAIndexUDID : TN_PUDBase; RACDRel : TK_RArray;
                                   PCDInds : PInteger; Count : Integer;
                                   PUDCDCors : TN_PUDBase = nil  );
function  K_IndexOfRACDRelQAIndex( out QADataInd : Integer; RACDRel : TK_RArray;
                                   PQAIndexUDID : TN_PUDBase; Count : Integer  ) : Integer;
function  K_GetRACDRelQAIndex( out QADataInd : Integer; RACDRel : TK_RArray;
                               PCDInds : PInteger;
                               Count : Integer; PUDCDCors : TN_PUDBase = nil  ) : Integer;
procedure K_BuildRACDRelCorInds( PCorInds : PInteger; QAWidth : Integer;
                                 RACDRel1 : TK_RArray; QAIndex1 : Integer;
                                 RACDRel2 : TK_RArray; QAIndex2 : Integer );

//*** CDCors
function  K_BuildUDCDCorDefName( UDCDimPrimary, UDCDimSecondary : TN_UDBase ) : string;
function  K_BuildUDCDCorDefAliase( UDCDimPrimary, UDCDimSecondary : TN_UDBase ) : string;

//*** CDIRefs
function  K_ConvRACDIRefs( RACDIRefs : TK_RArray; UDCD : TN_UDBase;
                           PConvInds : PInteger; RemoveUndefInds : Boolean ) : Boolean;
function  K_IndexOfRACDIRefsCDim( RACDIRefs : TK_RArray; UDCD : TN_UDBase; SInd : Integer = 0 ) : Integer;
function  K_CompressCDIRefs( PRRefs : TK_PCDIRef; PSRefs : TK_PCDIRef;
                             RefsCount : Integer; ClearCDResTail : Boolean = true ) : Integer;

//*** Miscellaneous
procedure K_InitCSpaceGCont( CurArchive : TN_UDBase = nil );
procedure K_CastIndsToDouble( PDData : PDouble; DStep :Integer;
                              PInds : PInteger; IStep :Integer;
                              DCount : Integer; UndefValue : Double );
procedure K_BuildCDRelIndsOrdIndex( POrdInds : PInteger; PRelInds : PInteger;
                                    CCount, RCount : Integer;
                                    DescendingOrder : Boolean = false );
function  K_BuildCDRelOrdIndsBounds( PBounds, POrdInds, PRelInds : PInteger;
                                     CCount, RCount : Integer ) : Integer;
procedure K_MoveCDRelOrdIndsBoundsValues( PDInds, PBounds, POrdInds, PRelInds : PInteger;
                                          CCount, BCount : Integer );
function  K_ShiftTSDate( SDate : TDateTime; Delta : Integer;
                         DUnits : TK_TimeStampUnits ) : TDateTime; overload;
function  K_ShiftTSDate( SDate : TDateTime; Delta : Double;
                         DUnits : TK_TimeStampUnits ) : TDateTime; overload;
procedure K_GetTimeStampsDates( TS : TK_RArray; PDate : PDateTime );
procedure K_GetTimeStampsStrings( TS : TK_RArray; PSDate : PString; Format : string = '' );

implementation

uses Math, DateUtils,
  N_Lib0, N_Lib1,
  K_FSFCombo, K_SParse1, K_VFunc, K_Arch, K_UDConst;

//***************************
//       Local Routines
//**************************************** K_InitRADBlockData
// Init Test Node Function for ScanSubTree
// Adds proper UDCSDBlocks to SrcRABlocks Array
//
function CompareInts(Item1, Item2: Pointer): Integer;
begin
{
> 0 (positive)	Item1 is less than Item2
   0	Item1 is equal to Item2
< 0 (negative)	Item1 is greater than Item2
}
 Result := PInteger(Item1)^ - PInteger(Item2)^;
end;

//***************************
//       Global Routines

//************************************************ K_GetOneTimeStampRAType
//
function  K_GetOneTimeStampRAType() : TK_ExprExtType;
begin
  if K_TimeStampsRAType.All = 0 then
    K_TimeStampsRAType := K_GetExecTypeCodeSafe( 'TK_OneTimeStamp' );
  Result := K_TimeStampsRAType;
end; //*** end of K_GetOneTimeStampRAType

//************************************************ K_GetTimeStampsRAType
//
function K_GetTimeStampsRAType() : TK_ExprExtType;
begin
  if K_TimeStampsRAType.All = 0 then
    K_TimeStampsRAType := K_GetExecTypeCodeSafe( 'TK_TimeStamps' );
  Result := K_TimeStampsRAType;
end; //*** end of K_GetTimeStampsRAType

//***********************************  K_GetCSDimRAType
// returns TypeCode of TK_CSDim
//
function  K_GetCSDimRAType : TK_ExprExtType;
begin
  if K_CSDimRAType.All = 0 then
    K_CSDimRAType := K_GetExecTypeCodeSafe( 'TK_CSDim' );
  Result := K_CSDimRAType;
end; // end of K_GetCSDimRAType

//***********************************  K_GetCDRelRAType
// returns TypeCode of TK_CDRel
//
function  K_GetCDRelRAType : TK_ExprExtType;
begin
  if K_CDRelRAType.All = 0 then
    K_CDRelRAType := K_GetExecTypeCodeSafe( 'TK_CDRel' );
  Result := K_CDRelRAType;
end; // end of K_GetCDRelRAType

//***********************************  K_GetCSDBAttrsRAType
// returns TypeCode of TK_CSDBAttrs
//
function  K_GetCSDBAttrsRAType : TK_ExprExtType;
begin
  if K_CSDBAttrsRAType.All = 0 then
    K_CSDBAttrsRAType := K_GetExecTypeCodeSafe( 'TK_CSDBAttrs' );
  Result := K_CSDBAttrsRAType;
end; // end of K_GetCSDBAttrsRAType

//***********************************  K_GetERDBAttrsRAType
// returns TypeCode of TK_ERDBAttrs
//
function  K_GetERDBAttrsRAType : TK_ExprExtType;
begin
  if K_ERDBAttrsRAType.All = 0 then
    K_ERDBAttrsRAType := K_GetExecTypeCodeSafe( 'TK_ERDBAttrs' );
  Result := K_ERDBAttrsRAType;
end; // end of K_GetERDBAttrsRAType

//***********************************  K_GetCSBVBLevelRAType
// returns TypeCode of Block Variant Container Block
//
function  K_GetCSBVBLevelRAType : TK_ExprExtType;
begin
  if K_BVBLevelRAType.All = 0 then
    K_BVBLevelRAType := K_GetExecTypeCodeSafe( 'TK_CSDBVBlock' );
  Result := K_BVBLevelRAType;
end; // end of K_GetCSBVBLevelRAType

//***********************************  K_GetCSBBLevelRAType
// returns TypeCode of Block Container Block
//
function  K_GetCSBBLevelRAType : TK_ExprExtType;
begin
  if K_BBLevelRAType.All = 0 then
    K_BBLevelRAType := K_GetExecTypeCodeSafe( 'TK_CSDBBlock' );
  Result := K_BBLevelRAType;
end; // end of K_GetCSBBLevelRAType

//***********************************  K_GetERBVBLevelRAType
// returns TypeCode of Block Variant Container Block
//
function  K_GetERBVBLevelRAType : TK_ExprExtType;
begin
  if K_BVBLevelRAType.All = 0 then
    K_BVBLevelRAType := K_GetExecTypeCodeSafe( 'TK_ERDBVBlock' );
  Result := K_BVBLevelRAType;
end; // end of K_GetERBVBLevelRAType

//***********************************  K_GetERBBLevelRAType
// returns TypeCode of Block Container Block
//
function  K_GetERBBLevelRAType : TK_ExprExtType;
begin
  if K_BBLevelRAType.All = 0 then
    K_BBLevelRAType := K_GetExecTypeCodeSafe( 'TK_ERDBBlock' );
  Result := K_BBLevelRAType;
end; // end of K_GetERBBLevelRAType

//************************************************ K_ShiftRATSDate
// Shift Date by TimeStamps Date Integer Delta
//
function K_ShiftRATSDate( SDate : TDateTime; Delta : Integer;
                          DUnits : TK_TimeStampUnits ) : TDateTime;
var
  I10D, I10M : Integer;
begin
  Result := SDate;
  if Delta = 0 then Exit;
  case DUnits of
    K_tduYear   :  Result := IncYear( Result, Delta );
    K_tduHYear  :  Result := IncMonth( Result, Delta * 6 );
    K_tduQuarter:  Result := IncMonth( Result, Delta * 3 );
    K_tduMonth  :  Result := IncMonth( Result, Delta );
    K_tdu10Days :  begin
      I10M := (Delta div 3);
      I10D := Delta - I10M * 3;
      if I10M <> 0 then
        Result := IncMonth( Result, I10M );
      if I10D <> 0 then
        Result := IncDay( Result, I10D * 10 );
    end;
    K_tduWeek   :  Result := IncWeek( Result, Delta );
    K_tduDay    :  Result := IncDay( Result, Delta );
  end;
end; //*** end of function K_ShiftRATSDate

//************************************************ K_ShiftRATSDate
// Shift Date by TimeStamps Date Double Delta
//
function K_ShiftRATSDate( SDate : TDateTime; Delta : Double;
                          DUnits : TK_TimeStampUnits ) : TDateTime;
var
  IDelta : Integer;
begin
  IDelta := Floor(Delta);
  Result := K_ShiftRATSDate( SDate, IDelta, DUnits );
  Delta := Delta - IDelta;
  if Delta = 0 then Exit;
  IDelta := Round( Delta * SecondsBetween(Result, K_ShiftRATSDate( Result, 1, DUnits ) ) );
  Result := IncSecond(Result, IDelta);
end; //*** end of function K_ShiftRATSDate

//************************************************ K_GetRATimeStampsDates
// Get Dates from TimeStamps RArray
//  TS - ArrayOf TK_TimeStamps
//  PDate - pointer to start element of ArrayOf TDate
//
procedure K_GetRATimeStampsDates( TS : TK_RArray; PDate : PDateTime );
var
  i : Integer;
  PTSTAttrs : TK_PTimeStampsAttrs;
begin
  with TS do begin
    PTSTAttrs := TK_PTimeStampsAttrs( TS.PA );
    for i := 0 to TS.AHigh do begin
      with PTSTAttrs^ do
        PDate^ := K_ShiftRATSDate( SDate, PInteger(TS.P(i))^, TSUnits );
      Inc(PDate);
    end;
  end;
end; //*** end of procedure K_GetRATimeStampsDates

//**************************************** K_GetRATimeStampsStrings
//
procedure K_GetRATimeStampsStrings( TS : TK_RArray; PSDate : PString; Format : string = '' );
var
  n, i : Integer;
  Dates : TN_DArray;

begin
  n := TS.ALength;
  if n > 0 then begin
    SetLength( Dates, n );
    K_GetRATimeStampsDates( TS, PDateTime(@Dates[0]) );
    if Format = '' then
      Format := 'dd.mm.yyyy';
    for i := 0 to n - 1 do begin
      PSDate^ := K_DateTimeToStr( TDateTime(Dates[i]), Format );
//        FormatDateTime( Format, TDateTime(Dates[i]) );
      Inc(PSDate);
    end;
  end;
end; //*** procedure K_GetRATimeStampsStrings

//*************************************** K_TestDBlockType
//
function K_TestDBlockType( TypeDTCode : Integer; UseERDBlock : Boolean = false ) :  TK_UseBlockType;
begin
  Result := K_ubtNotDBlock;
  with TK_UDFieldsDescr(TypeDTCode) do begin
    if (TypeDTCode < Ord(nptNoData)) or
       (FDObjType <> K_fdtTypeDef)     or
       (FDFieldsCount <> 2) then Exit;
    with GetFieldDescrByInd(0)^ do begin
      if (DataName <> '#')                  or
         (DataType.DTCode < Ord(nptNoData)) then Exit;
      if (TN_UDBase(DataType.DTCode).ObjName = 'TK_CSDBAttrs') then
        Result := K_ubtCSDBlock
      else if (TN_UDBase(DataType.DTCode).ObjName = 'TK_ERDBAttrs') then
        Result := K_ubtERDBlock;
    end;
  end;
end; //*** end of function K_TestDBlockType

//*************************************** K_BuildDBlockTypesList
//
procedure K_BuildDBlockTypesList( TypesList : TStrings; UseERDBlock : Boolean = false );
var
  i : Integer;
  TypeDTCode : Integer;
  UseBlockType : TK_UseBlockType;
begin
  TypesList.Clear;
  for i := 0 to K_TypeDescrsList.Count - 1 do begin
    TypeDTCode := Integer(K_TypeDescrsList.Objects[i]);
    UseBlockType := K_TestDBlockType( TypeDTCode );
    if (UseBlockType = K_ubtNotDBlock)                  or
       (UseERDBlock and (UseBlockType = K_ubtCSDBlock)) or
       (not UseERDBlock and (UseBlockType = K_ubtERDBlock)) then Continue;
    with TK_UDFieldsDescr(TypeDTCode).GetFieldDescrByInd(1)^ do
      TypesList.AddObject( K_GetSTypeAliase(DataType.DTCode), TObject(TypeDTCode) );
  end;

end; //*** end of function K_BuildDBlockTypesList

//*************************************** K_GetCSDBlockTypeByElemTypeName
//
function K_GetDBlockTypeByElemTypeCode( ElemTypeDTCode : Integer; UseERDBlock : Boolean = false ) : TK_ExprExtType;
var
  i : Integer;
  TypeDTCode : Integer;
  UseBlockType : TK_UseBlockType;
begin
  Result.All := 0;
  Result.DTCode := -1;
  for i := 0 to K_TypeDescrsList.Count - 1 do begin
    TypeDTCode := Integer(K_TypeDescrsList.Objects[i]);
    UseBlockType := K_TestDBlockType( TypeDTCode );
    if (UseBlockType = K_ubtNotDBlock)                  or
       (UseERDBlock and (UseBlockType = K_ubtCSDBlock)) or
       (not UseERDBlock and (UseBlockType = K_ubtERDBlock)) then Continue;
    with TK_UDFieldsDescr(TypeDTCode).GetFieldDescrByInd(1)^ do
      if ElemTypeDTCode = DataType.DTCode then begin
        Result.DTCode := TypeDTCode;
        Break;
      end;
  end;

end; //*** end of function K_GetDBlockTypeByElemTypeCode

//***********************************  K_GetBBLevelRAType
// returns TypeCode of Block Container Block
//
function  K_IfBBLevelRAType( BlockRAType : TK_ExprExtType ) : Boolean;
begin
  Result := (BlockRAType.DTCode = K_GetCSBBLevelRAType.DTCode)  or
            (BlockRAType.DTCode = K_GetCSBVBLevelRAType.DTCode) or
            (BlockRAType.DTCode = K_GetERBBLevelRAType.DTCode)  or
            (BlockRAType.DTCode = K_GetERBVBLevelRAType.DTCode);
end; // end of K_GetBBLevelRAType

//**************************************** K_InitRADBlockData
// Init CSDBlock data
//
procedure K_InitRADBlockData( RADBlock : TK_RArray; Ind, Count: Integer);
var i : Integer;
begin
  for i := 0 to Count - 1 do
    if RADBlock.ElemSType = Ord(nptDouble) then
      PDouble( RADBlock.P(i) )^ := K_MVMinVal
    else if RADBlock.ElemSType = Ord(nptFloat) then
      PFloat( RADBlock.P(i) )^ := K_MVMinVal;
end; // end of K_InitRADBlockData

//********************************************** K_InitRADBlockDims
//
procedure K_InitRADBlockDims( RADBlock : TK_RArray; ColCDim : TObject = nil;
                                RowCDim : TObject = nil; InitRCount : Integer= 0 );
var
  RowCount : Integer;
  ColCount : Integer;
  WCountUDRef : Boolean;
  WCRFlags : TK_CreateRAFlags;
  RelTypeName : string;
  MDFlags : TK_MoveDataFlags;
  UseBlockType : TK_UseBlockType;


  function InitDataDim( var CDObj : TObject; CDim : TObject ) : Integer;
  begin
    Result := 0;
    if CDim <> nil then begin
      if (CDim is TK_UDCSDim) or (CDim is TK_UDCDRel) then begin
        Result := TK_UDCSDim(CDim).R.ARowCount;
        K_SetUDRefField( TN_UDBase(CDObj), TN_UDBase(CDim), WCountUDRef );
      end else if CDim is TK_UDCDim then
        CDObj := K_CreateRACSDim( TK_UDCDim(CDim), K_cdrList, WCRFlags )
      else if (CDim is TK_RArray) then begin
        RelTypeName := K_GetExecTypeName( TK_RArray(CDim).GetComplexType.All );
        if (RelTypeName = 'TK_CSDim') or
           (RelTypeName = 'TK_CDRel') then begin
          with TK_RArray(CDim) do begin
            if ((FEType.D.CFlags and K_ccCountUDRef) = 0) and
               not WCountUDRef then
              CDObj := AAddRef
            else begin
              MDFlags := [];
              if WCountUDRef then
                MDFlags := [K_mdfCountUDRef,K_mdfFreeAndFullCopy];
              CDObj := K_RCopy( TK_RArray(CDim), MDFlags );
            end;
            Result := ARowCount;
          end;
        end;
      end;
    end;
  end;

begin
  with RADBlock do begin
    UseBlockType := K_TestDBlockType( FCETCode );
    if UseBlockType = K_ubtNotDBlock then Exit;
    WCountUDRef := (FEType.D.CFlags and K_ccCountUDRef) <> 0;
    WCRFlags := [];
    if WCountUDRef then WCRFlags  := [K_crfCountUDRef];
    ColCount := InitDataDim( TK_PCSDBAttrs(PA).ColsRel, ColCDim );
    RowCount := InitDataDim( TK_PCSDBAttrs(PA).RowsRel, RowCDim );
    if (ColCount = 0) then ColCount := 1;
    HCol := ColCount - 1;
    if RowCount = 0 then RowCount := InitRCount;
    if RowCount > 0 then
      ASetLength( ColCount * RowCount );
  end;
end; // end of K_InitRADBlockDims

//********************************************** K_CreateRADBlock
//
function K_CreateRADBlock( AEType : TK_ExprExtType;
                             ColCDim : TObject = nil;
                             RowCDim : TObject = nil;
                             CRFlags : TK_CreateRAFlags = [];
                             InitRCount : Integer = 0 ) : TK_RArray;
begin
  Result := K_RCreateByTypeCode( AEType.All, 0, CRFlags );
  K_InitRADBlockDims( Result, ColCDim, RowCDim, InitRCount );
end; // end of K_CreateRADBlock

//********************************************* K_GetRADBlockRACBRelSafe
// Get Block CDim Items References RArray - Create if Needed
//
function K_GetRADBlockRACBRelSafe( RA : TK_RArray ) : TK_RArray;
var
  WCRFlags : TK_CreateRAFlags;
begin
  with RA, TK_PCSDBAttrs(PA)^ do begin
    WCRFlags := [];
    if (FEType.D.CFlags and K_ccCountUDRef) <> 0 then WCRFlags  := [K_crfCountUDRef];
    if CBRel = nil then
      CBRel := K_RCreateByTypeName( 'TK_CDRel', 0, WCRFlags );
    Result := CBRel;
  end;
end; // end of K_GetRADBlockRACBRelSafe

//********************************************* K_ReorderDBlockRows
// Reorder Data Block Rows
//
procedure K_ReorderDBlockRows( RA : TK_RArray; DBlockReorderSkip : TK_DBlockReorderSkip;
                               POrderInds: PInteger; OrderIndsCount : Integer;
                               PFreeInds: PInteger; FreeIndsCount : Integer;
                               PInitInds: PInteger; InitIndsCount : Integer );
var
  WRA : TK_RArray;


begin
  with RA, TK_PERDBAttrs(PA)^ do begin
    ReorderRows( POrderInds, OrderIndsCount, PFreeInds, FreeIndsCount,
                 PInitInds, InitIndsCount );

  // Reorder Block Rows Relation Rows
    if (DBlockReorderSkip <> K_dbrSkipCDRel) and (RowsRel <> nil) then begin
      WRA := K_VArrayCondRACopy( @RowsRel );
      WRA.ReorderRows( POrderInds, OrderIndsCount, PFreeInds, FreeIndsCount,
                       PInitInds, InitIndsCount );
    end;
    if AttrsType.DTCode <> K_GetERDBAttrsRAType.DTCode then Exit;
    if (DBlockReorderSkip <> K_dbrSkipTS) and (RowsTS <> nil) then begin
      WRA := K_VArrayCondRACopy( @RowsTS );
      WRA.ReorderRows( POrderInds, OrderIndsCount, PFreeInds, FreeIndsCount,
                       PInitInds, InitIndsCount );
    end;
    if (DBlockReorderSkip <> K_dbrSkipAttrs) and (RowsAttrs <> nil) then begin
      K_ReorderRAListItemsData( RowsAttrs, POrderInds, OrderIndsCount, PFreeInds, FreeIndsCount,
                                PInitInds, InitIndsCount );
    end;
  end;
end; // end of K_ReorderDBlockRows

//********************************************* K_ReorderDBlockCols
// Reorder Data Block Cols
//
procedure K_ReorderDBlockCols( RA : TK_RArray; DBlockReorderSkip : TK_DBlockReorderSkip;
                               POrderInds: PInteger; OrderIndsCount : Integer;
                               PFreeInds: PInteger; FreeIndsCount : Integer;
                               PInitInds: PInteger; InitIndsCount : Integer );
var
  WRA : TK_RArray;


begin
  with RA, TK_PERDBAttrs(PA)^ do begin
    ReorderCols( POrderInds, OrderIndsCount, PFreeInds, FreeIndsCount,
                 PInitInds, InitIndsCount );

  // Reorder Block Rows Relation Rows
    if (DBlockReorderSkip <> K_dbrSkipCDRel) and (ColsRel <> nil) then begin
      WRA := K_VArrayCondRACopy( @ColsRel );
      WRA.ReorderRows( POrderInds, OrderIndsCount, PFreeInds, FreeIndsCount,
                       PInitInds, InitIndsCount );
    end;
    if AttrsType.DTCode <> K_GetERDBAttrsRAType.DTCode then Exit;
    if (DBlockReorderSkip <> K_dbrSkipTS) and (ColsTS <> nil) then begin
      WRA := K_VArrayCondRACopy( @ColsTS );
      WRA.ReorderRows( POrderInds, OrderIndsCount, PFreeInds, FreeIndsCount,
                       PInitInds, InitIndsCount );
    end;
    if (DBlockReorderSkip <> K_dbrSkipAttrs) and (ColsAttrs <> nil) then begin
      K_ReorderRAListItemsData( ColsAttrs, POrderInds, OrderIndsCount, PFreeInds, FreeIndsCount,
                                PInitInds, InitIndsCount );
    end;
  end;
end; // end of K_ReorderDBlockCols

//********************************************* K_RADBlockDelUndefElems
// Compress Block by Deletion Undefined Data Elements
// DelDir - block data direction
//          <0 - no direction try
//          =0 - try only columns
//          =1 - try only rows
//          >1 - try both
//
procedure K_RADBlockDelUndefElems( RA : TK_RArray; PUDataValue : Pointer;
                                     DelDir : Integer = 2 );
var
  ColCount, RowCount : Integer;
//  PWRA : PObject;
//  WRA : TK_RArray;
  i, j, fi, ai, n : Integer;
  FreeInds : TN_IArray;
  ActInds : TN_IArray;
  EDSize : Integer;
  CountUDRef : Boolean;
  SetVArrayFlags : TK_SetVArrayFlags;

begin
  with RA, TK_PCSDBAttrs(PA)^ do begin
    EDSize := ElemSize;

    CountUDRef := (FEType.D.CFlags and K_ccCountUDRef) <> 0;
    SetVArrayFlags := [];
    if CountUDRef then
      SetVArrayFlags := [K_svrCountUDRef];

    ALength( ColCount, RowCount );
    if (DelDir >= 1) then begin
    //*** Delete Block Rows
//      PWRA := @RowsRel;
//      if ((PWRA^ <> nil) or (ColCount > 1)) and  //??? what means this Condition
//         (RowCount > 0) and
//         (ColCount > 0) then begin
      if (RowCount > 0) and
         (ColCount > 0) then begin
        // Build Free Inds
        SetLength( FreeInds, RowCount );
        SetLength( ActInds, RowCount );
        fi := 0;
        ai := 0;
        //*** Block Elems Loop
        for j := 0 to RowCount - 1 do begin
          n := 0;
          for i := 0 to ColCount - 1 do
            if CompareMem( PUDataValue, PME(i,j), EDSize ) then Inc(n)
            else break;
          //*** end of Block Cols Loop
          if n <> ColCount then begin
            ActInds[ai] := j;
            Inc(ai);
          end else begin
            FreeInds[fi] := j;
            Inc(fi);
          end;
        end; //*** end of Block Rows Loop
        //*** end of Block Elems Loop

        if fi > 0 then begin
        //*** Reorder Block Rows Relation and Data
          K_ReorderDBlockRows( RA, K_dbrAllDone, K_GetPIArray0(ActInds), ai,
                               @FreeInds[0], fi, nil, 0 );
{
        // Reorder Block Data Rows
          ReorderRows( K_GetPIArray0(ActInds), ai,
                       @FreeInds[0], fi, nil, 0 );

        // Reorder Block Rows Relation Rows
          PWRA := @RowsRel;
          if PWRA^ <> nil then begin
            WRA := K_VArrayCondRACopy( PWRA );
            WRA.ReorderRows( K_GetPIArray0(ActInds), ai,
                               @FreeInds[0], fi, nil, 0);
          end;
}
          RowCount := RowCount - fi;
        end; //*** end of Reorder Block Rows
      end;  //*** end of Delete Block Rows
    end;

    //*** Delete Block Cols
    if (DelDir = 0) or (DelDir > 1) then begin
//      PWRA := @ColsRel;
//      if ((PWRA^ <> nil) or (RowCount > 1)) and  //??? what means this Condition
//         (RowCount > 0) and
//         (ColCount > 0) then begin
      if (RowCount > 0) and
         (ColCount > 0) then begin

        // Build Free Inds
        SetLength( FreeInds, ColCount );
        SetLength( ActInds, ColCount );
        fi := 0;
        ai := 0;
        //*** Block Elems Loop
        for i := 0 to ColCount - 1 do begin
          n := 0;
          for j := 0 to RowCount - 1 do
            if CompareMem( PUDataValue, PME(i,j), EDSize ) then Inc(n)
            else break;
          //*** end of Block Rows Loop
          if n <> RowCount then begin
            ActInds[ai] := i;
            Inc(ai);
          end else begin
            FreeInds[fi] := i;
            Inc(fi);
          end;
        end; //*** end of Block Cols Loop
        //*** end of Block Elems Loop

        if fi > 0 then begin
          K_ReorderDBlockCols( RA, K_dbrAllDone, K_GetPIArray0(ActInds), ai,
                               @FreeInds[0], fi, nil, 0 );
{
        //*** Reorder Block Cols Relation and Data
        // Reorder Block Data Cols
          ReorderCols( K_GetPIArray0(ActInds), ai,
                       @FreeInds[0], fi, nil, 0 );

        // Reorder Block Cols Relation Rows
          PWRA := @ColsRel;
          if PWRA^ <> nil then begin
            WRA := K_VArrayCondRACopy( PWRA );
            WRA.ReorderCols( K_GetPIArray0(ActInds), ai,
                               @FreeInds[0], fi, nil, 0);
          end;
}
        end; //*** end of Reorder Block Cols
//        ColCount := ColCount - fi;
      end;  //*** end of Delete Block Cols
    end;
  end;
end; // end of K_RADBlockDelUndefElems

//********************************************* K_RADBlockMLDelUndefElems
// Compress MultiLevel Block by Delete Undefined Data Elements
//
procedure K_RADBlockMLDelUndefElems( RA : TK_RArray; UDataFunc : TK_RAInitValFunc;
                                       PColLevelInds : PInteger; ColLevelIndsCount : Integer;
                                       PRowLevelInds : PInteger; RowLevelIndsCount : Integer;
                                       CurLevel : Integer );
var
  i, j : Integer;
  ColCount, RowCount : Integer;
  PRA : Pointer;
  PUDataValue : Pointer;
begin
  if (RA = nil) or
     ((ColLevelIndsCount <= 0) and (RowLevelIndsCount <= 0)) then Exit;
  PUDataValue := UDataFunc(RA.ElemType);
  if (PColLevelInds <> nil) then begin
    while (ColLevelIndsCount > 1) and (PColLevelInds^ < CurLevel) do begin
      Inc(PColLevelInds);
      Dec(ColLevelIndsCount);
    end;
    if PColLevelInds^ = CurLevel then
      K_RADBlockDelUndefElems( RA, PUDataValue, 0 );

    Inc(PColLevelInds);
    Dec(ColLevelIndsCount);
  end else
    ColLevelIndsCount := 0;

  if (PRowLevelInds <> nil) then begin
    while (RowLevelIndsCount > 1) and (PRowLevelInds^ < CurLevel) do begin
      Inc(PRowLevelInds);
      Dec(RowLevelIndsCount);
    end;
    if PRowLevelInds^ = CurLevel then
      K_RADBlockDelUndefElems( RA, PUDataValue, 1 );

    Inc(PRowLevelInds);
    Dec(RowLevelIndsCount);
  end else
    RowLevelIndsCount := 0;

  with RA do begin
    if ((ColLevelIndsCount <= 0) and (RowLevelIndsCount <= 0)) or
       not K_IfBBLevelRAType( GetComplexType ) then Exit;
    Inc(CurLevel);
    ALength( ColCount, RowCount );
    //*** Block Elems Loop
    for j := 0 to RowCount - 1 do begin
      for i := 0 to ColCount - 1 do begin
//        PRA := PME(i,j);
        PRA := K_GetPVRArray( PME(i,j)^ );
        K_RADBlockMLDelUndefElems( TK_PRArray(PRA)^, UDataFunc,
                                     PColLevelInds, ColLevelIndsCount,
                                     PRowLevelInds, RowLevelIndsCount,
                                     CurLevel );
      end; //*** Block Columns Loop
    end; //*** Block Rows Loop
  end;

end; // end of K_RADBlockMLDelUndefElems

//********************************************* K_RADBlockCDimIndsConv
// Self Code Dimention Items Indexes Fields Conversion
// if i is old CDim Item Index then ConvInds[i] is new CDim Item Index
// if ConvInds[i] = -1 then CDim Item with Index i is now absent in CDim
//
function K_RADBlockCDimIndsConv( RA : TK_RArray; UDCDim: TN_UDBase;
                                   PConvInds: PInteger;
                                   RemoveUndefInds: Boolean ) : Boolean;
var
  ColCount, RowCount : Integer;
  CSD : TObject;
  ConvDataInds : TN_IArray;
  FreeDataInds : TN_IArray;
  i, j : Integer;
  PRA : Pointer;
  POrderInds, PFreeInds, PInitInds : PInteger;
  OrderIndsCount : Integer;
  FreeIndsCount : Integer;
  InitIndsCount : Integer;
begin
  Result := False;
  with RA, TK_PCSDBAttrs(PA)^ do begin
//*** Convert CDim Items Refs
    if K_RebuildRACDRel( CBRel, UDCDim, PConvInds, RemoveUndefInds,
                              nil, nil ) then
      Exit; // if CDim is found in Block CDim Items Refs then it couldn't be in Rows or Columns CDims

//*** Convert Row CDim Inds
    CSD := RowsRel;
    if CSD <> nil then begin
    //*** Try To Convert Rows
      if CSD is TN_UDBase then begin
        if TN_UDBase(CSD).CDimIndsConv( UDCDim, PConvInds, RemoveUndefInds ) then begin
//          K_RADBlockCDLDataReorder(RA)
    //*** Try To Convert Rows Data
          TK_UDCSDim(CSD).GetConvDataInds( POrderInds, OrderIndsCount,
                    PFreeInds, FreeIndsCount, PInitInds, InitIndsCount );
//          ReorderRows( POrderInds, OrderIndsCount, PFreeInds, FreeIndsCount,
//                       PInitInds, InitIndsCount );
          K_ReorderDBlockRows( RA, K_dbrSkipCDRel,
                       POrderInds, OrderIndsCount, PFreeInds, FreeIndsCount,
                       PInitInds, InitIndsCount );
        end;
      end else begin
      //*** Convert Rows CSDim Indexes
        if K_RebuildRACDRel( TK_RArray(CSD), UDCDim, PConvInds, RemoveUndefInds,
                             @ConvDataInds, @FreeDataInds ) and RemoveUndefInds  then
      //*** Rows Data Reorder
//          ReorderRows( K_GetPIArray0(ConvDataInds), Length(ConvDataInds),
//                       K_GetPIArray0(FreeDataInds), Length(FreeDataInds), nil, 0 );
          K_ReorderDBlockRows( RA, K_dbrSkipCDRel,
                       K_GetPIArray0(ConvDataInds), Length(ConvDataInds),
                       K_GetPIArray0(FreeDataInds), Length(FreeDataInds),
                       nil, 0 );
      end;
    end;

//*** Convert Col CDim Inds
    CSD := ColsRel;
    if CSD <> nil then begin
    //*** Try To Convert Cols
      if CSD is TN_UDBase then begin
        if TN_UDBase(CSD).CDimIndsConv( UDCDim, PConvInds, RemoveUndefInds ) then begin
//          K_RADBlockCDLDataReorder( RA )
    //*** Try To Convert Rows Data
          TK_UDCSDim(CSD).GetConvDataInds( POrderInds, OrderIndsCount,
                    PFreeInds, FreeIndsCount, PInitInds, InitIndsCount );
//          ReorderCols( POrderInds, OrderIndsCount, PFreeInds, FreeIndsCount,
//                       PInitInds, InitIndsCount );
          K_ReorderDBlockCols( RA, K_dbrSkipCDRel,
                       POrderInds, OrderIndsCount, PFreeInds, FreeIndsCount,
                       PInitInds, InitIndsCount );
        end;
      end else begin
      //*** Convert Cols CSDim Indexes
        if K_RebuildRACDRel( TK_RArray(CSD), UDCDim, PConvInds, RemoveUndefInds,
                             @ConvDataInds, @FreeDataInds ) and RemoveUndefInds then
      //*** Cols Data Reorder
//          ReorderCols( K_GetPIArray0(ConvDataInds), Length(ConvDataInds),
//                       K_GetPIArray0(FreeDataInds), Length(FreeDataInds), nil, 0 );
          K_ReorderDBlockCols( RA, K_dbrSkipCDRel,
                       K_GetPIArray0(ConvDataInds), Length(ConvDataInds),
                       K_GetPIArray0(FreeDataInds), Length(FreeDataInds),
                       nil, 0 );
      end;
    end;

    if not K_IfBBLevelRAType( GetComplexType ) then Exit;

    ALength( ColCount, RowCount );
    //*** Block Elems Loop
    for j := 0 to RowCount - 1 do begin
      for i := 0 to ColCount - 1 do begin
        PRA := K_GetPVRArray( PME(i,j)^ );
//        PRA := PME(i,j);
        if TK_PRArray(PRA)^ <> nil then
          K_RADBlockCDimIndsConv( TK_PRArray(PRA)^, UDCDim, PConvInds,
                                    RemoveUndefInds );
      end; //*** Block Columns Loop
    end; //*** Block Rows Loop
  end;

end; // end of K_RADBlockCDimIndsConv

//********************************************* K_RADBlockCDLDataReorder
// Self Linked to Code Dimention Data Reorder
//
procedure K_RADBlockCDLDataReorder( RA : TK_RArray );
var
  ColCount, RowCount : Integer;
  CSD : TObject;
  PConvInds, PFreeInds, PInitInds : PInteger;
  ConvIndsCount : Integer;
  FreeIndsCount : Integer;
  InitIndsCount : Integer;
  i, j : Integer;
  PRA : Pointer;

begin
  with RA, TK_PCSDBAttrs(PA)^ do begin
//    ALength( ColCount, RowCount );
    CSD := RowsRel;
//??    if ((CSD <> nil) or (ColCount > 1)) and (CSD is TN_UDBase) then begin
    if (CSD <> nil) and (CSD is TN_UDBase) then begin
    //*** Try To Convert Rows Data
      if TK_UDCSDim(CSD).GetConvDataInds( PConvInds, ConvIndsCount,
              PFreeInds, FreeIndsCount, PInitInds, InitIndsCount ) then
//        ReorderRows( PConvInds, ConvIndsCount, PFreeInds, FreeIndsCount,
//                     PInitInds, InitIndsCount );
        K_ReorderDBlockRows( RA, K_dbrSkipCDRel,
                     PConvInds, ConvIndsCount, PFreeInds, FreeIndsCount,
                     PInitInds, InitIndsCount );
    end;

    CSD := ColsRel;
//??    if ((CSD <> nil) or (RowCount > 1)) and (CSD is TN_UDBase) then begin
    if (CSD <> nil) and (CSD is TN_UDBase) then begin
    //*** Try To Convert Cols Data
      if TK_UDCSDim(CSD).GetConvDataInds( PConvInds, ConvIndsCount,
              PFreeInds, FreeIndsCount, PInitInds, InitIndsCount ) then
//        ReorderCols( PConvInds, ConvIndsCount, PFreeInds, FreeIndsCount,
//                     PInitInds, InitIndsCount );
        K_ReorderDBlockCols( RA, K_dbrSkipCDRel,
                     PConvInds, ConvIndsCount, PFreeInds, FreeIndsCount,
                     PInitInds, InitIndsCount );
    end;

    if not K_IfBBLevelRAType( GetComplexType ) then Exit;

    ALength( ColCount, RowCount );
    //*** Block Elems Loop
    for j := 0 to RowCount - 1 do begin
      for i := 0 to ColCount - 1 do begin
        PRA := K_GetPVRArray( PME(i,j)^ );
//        PRA := PME(i,j);
        if TK_PRArray(PRA)^ <> nil then
          K_RADBlockCDLDataReorder( TK_PRArray(PRA)^ );
      end; //*** Block Columns Loop
    end; //*** Block Rows Loop
  end;
end; // end of K_RADBlockCDLDataReorder

//***********************************  K_IfRADBlock
// returns True if RArray is RACSDBlock
//
function  K_IfRADBlock( RADBlock : TK_RArray ) : Boolean;
begin
  Result := (RADBlock <> nil) and (RADBlock.AttrsSize > 0);
  if Result then
    Result := (RADBlock.AttrsType.DTCode = K_GetCSDBAttrsRAType.DTCode) or
              (RADBlock.AttrsType.DTCode = K_GetERDBAttrsRAType.DTCode);
{
  if RACSDBlock.AttrsType.DTCode = K_GetCSDBAttrsRAType.DTCode then Exit;
  BAType := K_GetCSDBAttrsRAType.DTCode;
  AType := RACSDBlock.AttrsType.DTCode;
  if RACSDBlock.AttrsType.DTCode = K_GetCSDBAttrsRAType.DTCode then Exit;
  Result := AType > Ord(nptNoData);
  if Result then
    Result := TK_UDFieldsDescr(AType).GetFieldDescrByInd( 0 ).DataType.DTCode = BAType;
}
end; // end of K_IfRADBlock

//***********************************  K_CheckIfUDCSDimIsFull
// Check if UDBase is Full CSDim
//
function  K_CheckIfUDCSDimIsFull( UDCSDim : TN_UDBase ) : Boolean;
begin
  Result := (UDCSDim is TK_UDCSDim)                                   and
            (UDCSDim.Owner = K_GetRACSDimCDim(TK_UDCSDim(UDCSDim).R)) and
            (UDCSDim.ObjName = K_FFulCSDimName);
end; // end of K_CheckIfUDCSDimIsFull

//************************************************ K_SetRACSDimCDim
//
procedure K_SetRACSDimCDim( CSDRA : TK_RArray; UDCDim : TK_UDCDim );
begin
  if CSDRA <> nil then
    with CSDRA do
      K_SetUDRefField( TK_PCSDimAttrs(PA).CDim, UDCDim, (FEType.D.CFlags and K_ccCountUDRef) <> 0 )
end; //*** end of K_SetRACSDimCDim

//************************************************ K_CreateRACSDim
//
function K_CreateRACSDim( UDCDim : TK_UDCDim; CSDimType : TK_CDRType;
                           CRFlags : TK_CreateRAFlags ) : TK_RArray;
begin
  Result := K_RCreateByTypeName( 'TK_CSDim', 0, CRFlags );
  K_SetRACSDimCDim( Result, UDCDim );
  TK_PCSDimAttrs(Result.PA).CDIType := CSDimType;
end; //*** end of K_CreateRACSDim

//************************************************ K_IndexOfRACSDimSelfInd
//
function K_IndexOfRACSDimSelfInd( CSDRA : TK_RArray; CDInd : Integer ) : Integer;
begin
  Result := -1;
  if CSDRA = nil then Exit;
  Result := K_IndexOfIntegerInRArray( CDInd, CSDRA.P, CSDRA.ALength );
end; //*** end of K_IndexOfRACSDimSelfInd

//************************************************ K_GetRACSDimCDim
//
function K_GetRACSDimCDim( CSDRA : TK_RArray ) : TK_UDCDim;
begin
  Result := nil;
  if CSDRA = nil then Exit;
  Result := TK_UDCDim( TK_PCSDimAttrs(CSDRA.PA).CDim );
end; //*** end of K_GetRACSDimCDim

//************************************************ K_BuildRACSDimSSet
//
function K_BuildRACSDimSSet( CSDRA : TK_RArray; var SSet : TN_BArray  ) : Integer;
begin
  Result := 0;
  if CSDRA = nil then Exit;
  with CSDRA do begin
    Result := TK_UDCDim( TK_PCSDimAttrs(PA).CDim ).CDimCount;
    if SSet = nil then begin
      SetLength( SSet, K_SetByteLength( Result ) );
      K_SetFromInds ( @SSet[0], P, ALength );
    end;
  end;
end; //*** end of K_BuildRACSDimSSet

//************************************************ K_RebuildRACSDim
//
function K_RebuildRACSDim( CSDRA : TK_RArray; UDCDim : TN_UDBase;
                           PConvInds : PInteger; RemoveUndefInds : Boolean;
                           POrderDataInds, PFreeDataInds : TN_PIArray ) : Boolean;
var
  ConvLeng, CSDLeng : Integer;
  PData : Pointer;
  OrderDataInds, FreeDataInds : TN_IArray;
begin
  Result := K_GetRACSDimCDim( CSDRA ) = UDCDim;
  if not Result then Exit;
  with CSDRA do begin
    CSDLeng := ALength;
    PData := P;
    K_MoveVectorBySIndex( PData^, SizeOf(Integer),
                        PConvInds^, SizeOf(Integer), SizeOf(Integer),
                        CSDLeng, PInteger(PData) );

    if not RemoveUndefInds then Exit;

  // Prepare ConDataInds and Compress Self Indexes
    SetLength( OrderDataInds, CSDLeng );
    SetLength( FreeDataInds, CSDLeng );
    ConvLeng := K_BuildActIndicesAndCompress( @FreeDataInds[0], @OrderDataInds[0], PData, PData, CSDLeng );
    SetLength( OrderDataInds, ConvLeng );
    SetLength( FreeDataInds, CSDLeng - ConvLeng );
    ReorderElems( K_GetPIArray0(OrderDataInds), Length(OrderDataInds),
                  K_GetPIArray0(FreeDataInds), Length(FreeDataInds), nil, 0 );
    if POrderDataInds = nil then Exit;
    POrderDataInds^ := OrderDataInds;
    PFreeDataInds^  := FreeDataInds;
  end;
end; //*** end of K_RebuildRACSDim

//************************************************ K_BuildCrossIndsByRACSDims
//  Build RACSDims Cross Inds which Defined Relation between
//  Items of Data Vector Related to SrcCSDim Indices and Items of Data Vector
//  Related to DestCSDim Indices
//    SrcData[ResInds[i]] -> DestData[i]
//
procedure K_BuildCrossIndsByRACSDims( PRInds,
                              DestCSDInds : PInteger; DestCSDCount : Integer;
                              SrcCSDInds : PInteger; SrcCSDCount : Integer;
                              PFullCDimInds : PInteger; FullCDimIndsCount : Integer );
var
  i : Integer;
begin
  K_BuildBackIndex0( SrcCSDInds, SrcCSDCount, PFullCDimInds, FullCDimIndsCount );
  for i := 0 to DestCSDCount - 1 do begin
    if DestCSDInds^ >= 0 then
      PRInds^ := PInteger(TN_BytesPtr(PFullCDimInds) + DestCSDInds^ * Sizeof(Integer))^
    else
      PRInds^ := DestCSDInds^;
    Inc( DestCSDInds );
    Inc( PRInds );
  end;
end; //*** K_BuildCrossIndsByRACSDims

//********************************************* K_BuildConvDataIArraysByRACSDims
// Build IArrays Indices for Conv, Free and Init Related Data
//
procedure K_BuildConvDataIArraysByRACSDims( DestCSDInds : PInteger; DestCSDCount : Integer;
                                            SrcCSDInds : PInteger; SrcCSDCount : Integer;
                                            PFullCDimInds : PInteger; FullCDimIndsCount : Integer;
                                        var ConvDataInds, FreeDataInds, InitDataInds : TN_IArray );
var
  MinusOne : Integer;
begin
  SetLength( ConvDataInds, DestCSDCount );
  SetLength( InitDataInds, DestCSDCount );
//*** Prepare Relation Indexes for changing Linked Data Blocks
  if DestCSDCount > 0 then begin
    K_BuildCrossIndsByRACSDims( @ConvDataInds[0],
                              DestCSDInds, DestCSDCount,
                              SrcCSDInds, SrcCSDCount,
                              PFullCDimInds, FullCDimIndsCount );
//*** Build New CSDim Elements Indices which are must be Initialised in Data Blocks
    SetLength( InitDataInds, DestCSDCount - K_BuildActIndicesAndCompress(
               @InitDataInds[0], nil, nil, @ConvDataInds[0], DestCSDCount ) );
  end;
//*** Build Old CSDim Elements Indices which are not used in new Values
  SetLength( FreeDataInds, SrcCSDCount );
  if SrcCSDCount > 0 then begin
    K_FillIntArrayByCounter( @FreeDataInds[0], SrcCSDCount );
    if DestCSDCount > 0 then begin
      MinusOne := -1;
      K_MoveVectorByDIndex( FreeDataInds[0], SizeOf(Integer),
                        MinusOne, 0, SizeOf(Integer), DestCSDCount, @ConvDataInds[0] );
      SetLength( FreeDataInds, K_BuildActIndicesAndCompress(
          nil, nil, @FreeDataInds[0], @FreeDataInds[0], SrcCSDCount ) );
    end;
  end;
end; // end of K_BuildConvDataIArraysByRACSDims

//************************************************ K_MarkRAUDCDims
//
procedure K_MarkRAUDCDims( PUDCDims : TN_PUDBase; UDCDimsCount : Integer;
                           PInds : PInteger = nil );
var
  i, j : Integer;
begin
  for i := 0 to UDCDimsCount - 1 do begin
    if PInds <> nil then begin
      j := PInds^;
      Inc(PInds);
    end else
      j := i;
    TN_PUDBase(TN_BytesPtr(PUDCDims) +  j * SizeOf(TN_UDBase)).Marker := j + 1;
  end;
end; //*** end of K_MarkRAUDCDims

//************************************************ K_UnMarkRAUDCDims
//
procedure K_UnMarkRAUDCDims( PUDCDims : TN_PUDBase; UDCDimsCount : Integer;
                             PInds : PInteger = nil );
var
  i, j : Integer;
begin
  for i := 0 to UDCDimsCount - 1 do begin
    if PInds <> nil then begin
      j := PInds^;
      Inc(PInds);
    end else
      j := i;
    TN_PUDBase(TN_BytesPtr(PUDCDims) +  j * SizeOf(TN_UDBase)).Marker := 0;
  end;
end; //*** end of K_UnMarkRAUDCDims

//************************************************ K_BuildCrossIndsRAUDCDims
//
function K_BuildCrossIndsRAUDCDims( PUDInds : PInteger; PUDCDims : TN_PUDBase;
                                    UDCDimsCount : Integer ) : Integer;
var
  i : Integer;
  j : Integer;
begin
  FillChar( PUDInds^, UDCDimsCount * SizeOf(Integer), -1 );
  Result := 0;
  for i := 1 to UDCDimsCount do begin
    j := PUDCDims.Marker;
    if j > 0 then begin
      PUDInds^ := j - 1;
      Inc(Result);
    end;
    Inc(PUDCDims);
    Inc(PUDInds);
  end;
end; //*** end of K_BuildCrossIndsRAUDCDims

//************************************************ K_GetRACDRelUDCDimsIndices
// Get Indices of UDCDims in CDRelRA CDims
//  Returns number of found UDCDims
//
function K_GetRACDRelUDCDimsIndices( PCDInds : PInteger; CDRelRA : TK_RArray;
                     PUDCDim : TN_PUDBase; UDCDimCount : Integer;
                     UDCDimStep : Integer = SizeOf(Integer) ) : Integer;
var
  i : Integer;
  k, n : Integer;
  FindCDInd : Boolean;
begin
//*** Build CDims Inds
  Result := 0;
  for i := 0 to UDCDimCount - 1 do begin
    k := K_IndexOfRACDRelCDim( CDRelRA, PUDCDim^, 0 );
    if k < 0 then Continue;
    // check if find CDim is Single
    FindCDInd := true;
    repeat
      for n := Result - 1 downto 0 do begin
        FindCDInd := PInteger(TN_BytesPtr(PCDInds) + n * SizeOf(Integer))^ <> k;
        if not FindCDInd then begin
          k := K_IndexOfRACDRelCDim( CDRelRA, PUDCDim^, k + 1 );
          break;
        end;
      end;
    until FindCDInd or (k < 0);
    if k < 0 then Continue;

    PInteger(TN_BytesPtr(PCDInds) + Result * SizeOf(Integer))^ := k;
    Inc(Result);
    Inc(PUDCDim);
  end;
end; //*** end of K_GetRACDRelUDCDimsIndices

//************************************************ K_AddUDCDimsToRACDRel
//
function K_AddUDCDimsToRACDRel( RACDRel : TK_RArray;
                     PUDCDim : TN_PUDBase; UDCDimCount : Integer;
                     UDCDimStep : Integer = SizeOf(Integer) ) : Integer;
var
  FPUDCim : TN_PUDBase;
  SInd, i : Integer;
  RowCount : Integer;
  CRFlags : TK_CreateRAFlags;
  CreateRACDims : Boolean;
  CountUDRef : Boolean;
  UDCDim : TN_UDBase;
  Minus1 : Integer;

begin
  with RACDRel do begin
    with TK_PCDRelAttrs(PA)^ do begin
  //*** Analised Relation Current State
      CountUDRef := (FEType.D.CFlags and K_ccCountUDRef) <> 0;
      SInd := 0;
      CreateRACDims := true;
      if (CDims <> nil) then begin
        SInd := 1;
        if (CDims is TK_RArray) then begin
          SInd := TK_RArray(CDims).ALength;
          CreateRACDims := false;
        end;
      end;
      Result := SInd;
      if UDCDimCount <= 0 then Exit;

  //*** Prepare Relation for CDims Addition
      Result := SInd + UDCDimCount;
      if (Result > 1) then begin
      //*** Many UDCDims
        if CreateRACDims then begin
          CRFlags := [];
          if CountUDRef then CRFlags := [K_crfCountUDRef];
          UDCDim := nil;                                          //??
          if SInd = 1 then // Save Single CSDim Reference         //??
            UDCDim := TN_UDBase(CDims);                           //??
          CDims := K_RCreateByTypeName( 'TN_UDBase', Result, CRFlags );
          TN_PUDBase(TK_RArray(CDims).P)^ := UDCDim;              //??
        end else
          TK_RArray(CDims).ASetLength( Result );
        FPUDCim := TK_RArray(CDims).P( SInd );
      end else begin
      //*** Single UDCDim
        if not CreateRACDims then
          FreeAndNil( CDims);
{
          with TK_RArray(CDims) do begin
            ASetLength( 1 );
            FPUDCim := P;
          end
        else
}
          FPUDCim := TN_PUDBase(@CDims);
      end;
    end;

  //*** Add Refernces To UDCDims
    for i := SInd to Result - 1 do begin
      K_SetUDRefField( FPUDCim^, PUDCDim^, CountUDRef );
      Inc(FPUDCim);
      Inc(TN_BytesPtr(PUDCDim), UDCDimStep);
    end;

  //*** Add New UDCDims Indices
    RowCount := ARowCount;
    ASetLength( Result, RowCount );
    Minus1 := -1;
    for i := SInd to Result - 1 do
      K_MoveVector( PME(i, 0)^, SizeOf(Integer) * Result, Minus1, 0,
                                  SizeOf(Integer), RowCount );
  end;


end; //*** end of K_AddUDCDimsToRACDRel

//************************************************ K_RemoveUDCDimsFromRACDRelByInds
//  Returns number of realy removed UDCDims
//
procedure K_RemoveUDCDimsFromRACDRelByInds( CDRelRA : TK_RArray;
                                  PCDInds : PInteger; IndsCount : Integer );
var
  i : Integer;
  CountUDRef : Boolean;

  k, n : Integer;
  RACDimsCount : Integer;
  PRAUDCDims : TN_PUDBase;
  ElemIndsBuf : TN_IArray;
  XORInds : TN_IArray;
  UDBuf : TN_UDArray;
  RCount : Integer;
begin
  RACDimsCount := K_GetRACDRelPUDCDims( CDRelRA, PRAUDCDims );
  CountUDRef := (CDRelRA.FEType.D.CFlags and K_ccCountUDRef) <> 0;
  if IndsCount = RACDimsCount then begin
  // Clear All CDims
    K_FreeRACDRelCDims( CDRelRA, false );
    CDRelRA.ASetLength(0, 0);
  end else begin
  // Clear Selected CDims
    for i := 0 to IndsCount - 1 do
      if CountUDRef then
        TN_PUDBase(TN_BytesPtr(PRAUDCDims) +
            PInteger(TN_BytesPtr(PCDInds) + i * SizeOf(Integer))^ * SizeOf(TN_UDBase)).UDDelete;

  // Build XOR Indices
    k := RACDimsCount - IndsCount;
    SetLength( XORInds, k );
    K_BuildXORIndices( @XORInds[0], PCDInds, IndsCount, RACDimsCount, true );

  // Rebuild Relation CDims Content - Move Rest CDRelRA CDims to CDims heading
    // Copy Rest CDims to Buf
    SetLength( UDBuf, k );
    K_MoveVectorBySIndex( UDBuf[0], SizeOf(TN_UDBase),
                        PRAUDCDims^, SizeOf(TN_UDBase),
                        SizeOf(TN_UDBase), k, @XORInds[0] );
    // Copy Rest CDims from Buf to CDRelRA CDims heading
    Move( UDBuf[0], PRAUDCDims^, k * SizeOf(TN_UDBase) );

    // Cut CDims Tail
    with TK_RArray(TK_PCDRelAttrs(CDRelRA.PA).CDims) do
      SetElemsFreeFlag( k, -1, true );

  // Rebuild Relation Indices Content
    RCount := CDRelRA.ARowCount;
    n := RCount * k;
    // Copy Rest Inds to Buf
    SetLength( ElemIndsBuf, n );
    K_MoveMatrixBySIndex( ElemIndsBuf[0], k * SizeOf(Integer),  SizeOf(Integer),
                              CDRelRA.P^,  RACDimsCount * SizeOf(Integer), SizeOf(Integer),
                              SizeOf(Integer),
                              RCount, k, nil, @XORInds[0] );

    // Prepare Space in CDRelRA Inds
    CDRelRA.SetElemsFreeFlag( k * RCount, -1, true );
    CDRelRA.ASetLength( k, RCount );

    // Copy Inds from Buf to CDRelRA Inds
    Move( ElemIndsBuf[0], CDRelRA.P^, n * SizeOf(Integer) );
  end;
end; //*** end of K_RemoveUDCDimsFromRACDRelByInds

//************************************************ K_RemoveUDCDimsFromRACDRel
//  Returns number of realy removed UDCDims
//
function K_RemoveUDCDimsFromRACDRel( CDRelRA : TK_RArray;
                     PUDCDim : TN_PUDBase; UDCDimCount : Integer;
                     UDCDimStep : Integer = SizeOf(Integer) ) : Integer;
var
  CDInds : TN_IArray;
begin
  SetLength( CDInds, UDCDimCount );
  Result := K_GetRACDRelUDCDimsIndices( @CDInds[0], CDRelRA, PUDCDim, UDCDimCount );
  if Result = 0 then Exit;
  K_RemoveUDCDimsFromRACDRelByInds( CDRelRA, @CDInds[0], Result );
end; //*** end of K_RemoveUDCDimsFromRACDRel

//************************************************ K_LeaveUDCDimsInRACDRelByInds
//
procedure K_LeaveUDCDimsInRACDRelByInds( CDRelRA : TK_RArray;
                     PCDInds : PInteger; IndsCount : Integer );
var
  k, n : Integer;
  XORInds : TN_IArray;
begin
  n := CDRelRA.AColCount;
  k := n - IndsCount;
  if k = 0 then Exit;
  SetLength( XORInds, k );
  K_BuildXORIndices( @XORInds[0], PCDInds, IndsCount, n, true );
  K_RemoveUDCDimsFromRACDRelByInds( CDRelRA, @XORInds[0], k );
end; //*** end of K_LeaveUDCDimsInRACDRel

//************************************************ K_LeaveUDCDimsInRACDRel
//  returns number of leaved UDCDims
//
function K_LeaveUDCDimsInRACDRel( CDRelRA : TK_RArray;
                     PUDCDim : TN_PUDBase; UDCDimCount : Integer;
                     UDCDimStep : Integer = SizeOf(Integer) ) : Integer;
var
  CDInds : TN_IArray;
begin
  SetLength( CDInds, UDCDimCount );
  Result := K_GetRACDRelUDCDimsIndices( @CDInds[0], CDRelRA, PUDCDim, UDCDimCount );
  if Result = 0 then Exit;
  K_LeaveUDCDimsInRACDRelByInds( CDRelRA, @CDInds[0], Result );
end; //*** end of K_LeaveUDCDimsInRACDRel

//************************************************ K_BuildRACDRelsCProduction
//
function K_BuildRACDRelsCProduction( RCD1, RCD2 : TK_RArray; CRFlags : TK_CreateRAFlags ) : TK_RArray;
var
  PRCDims1, PRCDims2  : TN_PUDBase;
  ACDRType : TK_CDRType;
  n, i, nr1, nr2, ncb, nc1, nc2, ncb1, ncb2 : Integer;
begin
  nc1 := K_GetRACDRelPUDCDims( RCD1, PRCDims1 );
  nc2 := K_GetRACDRelPUDCDims( RCD2, PRCDims2 );
  ACDRType := K_cdrList;
  if (TK_PCDRelAttrs(RCD1.PA).CDRType = K_cdrBag) or
     (TK_PCDRelAttrs(RCD1.PA).CDRType = K_cdrBag) then
    ACDRType := K_cdrBag;
  Result := K_CreateRACDRel( PRCDims1, nc1, ACDRType, CRFlags );
  K_AddUDCDimsToRACDRel( Result, PRCDims2, nc2 );
  nr1 := RCD1.ARowCount;
  nr2 := RCD2.ARowCount;
  n := nr1 * nr2;
  ncb := nc1 + nc2;
  Result.ASetLength( ncb, n );
  ncb := ncb * SizeOf(Integer);
  ncb1 := nc1 * SizeOf(Integer);
  ncb2 := nc2 * SizeOf(Integer);
  for i := 0 to RCD1.AHigh do begin
    K_MoveVector( Result.PME(0, i * nr2)^, ncb,
                  RCD1.PME(0,i)^, 0, ncb1, nr2 );
    K_MoveVector( Result.PME(nc1, i * nr2)^, ncb,
                  RCD2.PME(0,0)^, ncb2, ncb2, nr2 );
  end;
end; //*** end of K_BuildRACDRelsCProduction

//************************************************ K_CreateRACDRel
//
function K_CreateRACDRel( PUDCDim : TN_PUDBase; UDCDimCount : Integer;
                          ACDRType : TK_CDRType;
                          CRFlags : TK_CreateRAFlags ) : TK_RArray;
begin
  Result := K_RCreateByTypeName( 'TK_CDRel', 0, CRFlags );
  TK_PCDRelAttrs(Result.PA).CDRType := ACDRType;
  if UDCDimCount > 0 then
    K_AddUDCDimsToRACDRel( Result, PUDCDim,  UDCDimCount );
end; //*** end of K_CreateRACDRel

//************************************************ K_FreeRACDRelCDims
//
procedure K_FreeRACDRelCDims( RACDRel : TK_RArray; FreeRACDims : Boolean );
begin
  with RACDRel do begin
    with TK_PCDRelAttrs(PA)^ do begin
  //*** Analised Relation Current State
      if (CDims = nil) then Exit;
      if (CDims is TK_RArray) then begin
        with TK_RArray(CDims) do
        if FreeRACDims then
          ARelease
        else
          ASetLength(0);
      end else
        K_SetUDRefField( TN_UDBase(CDims), nil, (FEType.D.CFlags and K_ccCountUDRef) <> 0 );
    end;
  end;
end; //*** end of K_FreeRACDRelCDims

//********************************************* K_SetRACDRelFromIRefs
// Set RACDRel From CDim Items References
//
procedure K_SetRACDRelFromIRefs( RACDRel : TK_RArray; PCDIRefs: TK_PCDIRef;
                                 CDIRefsCount: Integer );
begin
  if RACDRel = nil then Exit;
  K_FreeRACDRelCDims( RACDRel, false );
  with RACDRel do begin
    ASetLength( CDIRefsCount, 1 );
    K_AddUDCDimsToRACDRel( RACDRel, @PCDIRefs.CDRCDim, CDIRefsCount, SizeOf(TK_CDIRef) );
//    ASetLength( CDIRefsCount, 1 );
    K_MoveVector( PME(0, 0)^, SizeOf(Integer), PCDIRefs.CDRItemInd, SizeOf(TK_CDIRef),
                                  SizeOf(Integer), CDIRefsCount );
  end;
end; // end of K_SetRACDRelFromIRefs

//********************************************* K_GetRACDRelToIRefs
// Set Block CDim Items References
//
procedure K_GetRACDRelToIRefs( RACDRel : TK_RArray; PCDIRefs: TK_PCDIRef );
var
  CDIRefsCount: Integer;
  PUDCDims : TN_PUDBase;
begin
  if RACDRel = nil then Exit;
  CDIRefsCount := K_GetRACDRelPUDCDims( RACDRel, PUDCDims );
  K_MoveVector( PCDIRefs.CDRCDim, SizeOf(TK_CDIRef), PUDCDims^, SizeOf(Integer),
                                SizeOf(Integer), CDIRefsCount );
  with RACDRel do
    K_MoveVector( PCDIRefs.CDRItemInd, SizeOf(TK_CDIRef), PME(0, 0)^, SizeOf(Integer),
                                  SizeOf(Integer), CDIRefsCount );
end; // end of TK_UDCSDBlock.K_GetRACDRelToIRefs

//**************************************** K_GetRACDRelPUDCDims
//
function K_GetRACDRelPUDCDims( CDRelRA : TK_RArray; out PUDCDims : TN_PUDBase ) : Integer;
var
  VObj : TObject;
//  L : Integer;
begin
  PUDCDims := nil;
  Result := 0;
  if CDRelRA = nil then Exit;
  with CDRelRA do begin
    PUDCDims := @TK_PCDRelAttrs(PA).CDims;
    VObj := PUDCDims^;
    Result := HCol + 1;

    if VObj is TK_RArray then begin
      PUDCDims := TK_RArray(VObj).P;
{
      L := TK_RArray(VObj).ALength;
      if Result <> L then
        L := Result;
}
      assert((PUDCDims <> nil) and (Result = TK_RArray(VObj).ALength), 'TK_CDRelAttrs CDims Wrong Type' );
    end;
  end;
end; // end of K_GetRACDRelPUDCDims

//**************************************** K_GetRACDRelPUDCDims
//
function  K_GetRACDRelPUDCDims( CDRelRA : TK_RArray; out UDimsCount : Integer ) : TN_PUDBase; 
begin
  UDimsCount := K_GetRACDRelPUDCDims( CDRelRA, Result );
end; // end of K_GetRACDRelPUDCDims

//***********************************  K_GetRACDRelUDCSDim
// Show CDim Relation RArray
//
function K_GetRACDRelUDCSDim( RACDRel: TK_RArray ) : TK_UDCSDim;
begin
  Result := nil;
  if RACDRel = nil then Exit;
  with RACDRel do
    if AttrsSize >= SizeOf(TK_CDRelAttrs) then
      Result := TK_UDCSDim(TK_PCDRelAttrs(PA).CUDCSDim);
end; //*** end of K_GetRACDRelUDCSDim

//************************************************ K_IndexOfRACDRelCDim
//
function K_IndexOfRACDRelCDim( CDRelRA : TK_RArray; UDCDim : TN_UDBase;
                               SCDInd : Integer = 0 ) : Integer;
var
  Count : Integer;
  PUDCDim : TN_PUDBase;
begin
  Count := K_GetRACDRelPUDCDims( CDRelRA, PUDCDim );
  if SCDInd < Count then
    Result := K_IndexOfIntegerInRArray( Integer(UDCDim), PInteger(TN_BytesPtr(PUDCDim) + SCDInd * SizeOf(Integer)),
                                        Count - SCDInd  )
  else
    Result := -1;
end; //*** end of K_IndexOfRACDRelCDim

//************************************************ K_CheckRACDRelInds
//  Check RACDRel Indexes - Result in Arrays of Integer
//   PRowFlags - Pointer To Rows Result Info
//   PColFlags - Pointer To Cols Result Info
//     Each RowFlags[i] = ColCount - 1 - (Number of -1 Indexes in i-Row)
//     So RowFlags[i] < 0 if All i-Row Indexes = -1
//     Each ColFlags[i] = RowCount - 1 - (Number of -1 Indexes in i-Col)
//     So ColFlags[i] < 0 if All i-Col Indexes = -1
//
procedure K_CheckRACDRelInds( CDRelRA : TK_RArray; PRowFlags, PColFlags : PInteger );
var
  ColCount, RowCount : Integer;
  PData : PInteger;
  i, j : Integer;
  WPRowFlags, WPColFlags : PInteger;
begin
  with CDRelRA do begin
    ALength( ColCount, RowCount );
    if PRowFlags <> nil then begin
      WPRowFlags := PRowFlags;
      j := ColCount - 1;
      for i := 0 to RowCount - 1 do begin
        WPRowFlags^ := j;
        Inc(WPRowFlags);
      end;
    end;
    if PColFlags <> nil then begin
      WPColFlags := PColFlags;
      j := RowCount - 1;
      for i := 0 to ColCount - 1 do begin
        WPColFlags^ := j;
        Inc(WPColFlags);
      end;
    end;
    WPRowFlags := PRowFlags;
    for i := 0 to RowCount - 1 do begin
      PData := PME( 0, i );
      WPColFlags := PColFlags;
      for j := 0 to ColCount - 1 do begin
        if PData^ < 0 then begin
          if PColFlags <> nil then
            Dec(WPColFlags^);
          if PRowFlags <> nil then
            Dec(WPRowFlags^);
        end;
        Inc(PData);
        Inc( WPColFlags );
      end;
      Inc( WPRowFlags );
    end;
  end;
end; //*** end of K_CheckRACDRelInds

//************************************************ K_RebuildRACDRelAll
//
function K_RebuildRACDRel( CDRelRA : TK_RArray; CDInd : Integer;
                            PConvInds : PInteger; RemoveUndefInds : Boolean;
                            POrderDataInds, PFreeDataInds : TN_PIArray ) : Boolean;
var
  OrderLeng, UDCDCount, RowCount, RowLength : Integer;
  PData : PInteger;
  i : Integer;
  UDCDim : TN_UDBase;
  PUDCDim : TN_PUDBase;
  RowFlags : TN_IArray;
  ColFlags : TN_IArray;
  SetVArrayFlags : TK_SetVArrayFlags;
  OrderDataInds : TN_IArray;
  FreeDataInds : TN_IArray;
begin
  Result := false;
  if CDInd < 0 then Exit;

  with CDRelRA do begin
    ALength( UDCDCount, RowCount );
    K_GetRACDRelPUDCDims( CDRelRA, PUDCDim );
    Inc( TN_BytesPtr(PUDCDim), CDInd * SizeOf(TN_UDBase) );
    UDCDim := PUDCDim^;
  // Build Proper Indexes Array in RowFlags
    RowLength := ElemSize * UDCDCount;
    for i := CDInd to UDCDCount - 1 do begin
      if UDCDim = PUDCDim^ then begin
      // Replace Relation SDim Indexes -> NewInd := ConvInds[OldInd]
        PData := PME( i, 0 );
        K_MoveVectorBySIndex( PData^, RowLength,
                            PConvInds^, SizeOf(Integer), SizeOf(Integer),
                            RowCount, PInteger(PData) );
      end;
      Inc( PUDCDim );
    end;


    if not RemoveUndefInds then Exit;
  // Get Rows and Cols Info
    SetLength( RowFlags, RowCount );
    SetLength( ColFlags, UDCDCount );
    K_CheckRACDRelInds( CDRelRA, @RowFlags[0], @ColFlags[0] );

  // Prepare Order and Free Columns Inds
    SetLength( OrderDataInds, UDCDCount );
    SetLength( FreeDataInds, UDCDCount );
    OrderLeng := K_BuildActIndicesAndCompress( @FreeDataInds[0], @OrderDataInds[0], nil, @ColFlags[0], UDCDCount );
    if UDCDCount > OrderLeng then begin
      // Remove Undef Relation Columns
      SetLength( OrderDataInds, OrderLeng );
      SetLength( FreeDataInds, UDCDCount - OrderLeng );
      ReorderCols( K_GetPIArray0(OrderDataInds), Length(OrderDataInds),
                   K_GetPIArray0(FreeDataInds), Length(FreeDataInds), nil, 0 );
      // Remove CSDims with Undef Indexes from Relation Columns
      with TK_PCDRelAttrs(PA)^ do begin
        if CDims is TK_RArray then
          TK_RArray(CDims).ReorderCols( K_GetPIArray0(OrderDataInds), Length(OrderDataInds),
                                        K_GetPIArray0(FreeDataInds), Length(FreeDataInds), nil, 0 );
        if UDCDCount = 1 then begin // Free Array
          SetVArrayFlags := [];
          if (CDRelRA.ArrayType.D.CFlags and K_ccCountUDRef) <> 0 then
            SetVArrayFlags := [K_svrCountUDRef];
          K_SetVArrayField( CDims, nil, SetVArrayFlags );
        end;
      end;
    end;
    if POrderDataInds = nil then Exit;
  // Prepare Order and Free Rows Inds
    SetLength( OrderDataInds, RowCount );
    SetLength( FreeDataInds, RowCount );
    OrderLeng := K_BuildActIndicesAndCompress( @FreeDataInds[0], @OrderDataInds[0], nil, @RowFlags[0], RowCount );
    Result := RowCount > OrderLeng;
    if Result then begin
//      Build Reorder Info
      SetLength( OrderDataInds, OrderLeng );
      SetLength( FreeDataInds, RowCount - OrderLeng );
      ReorderRows( K_GetPIArray0(OrderDataInds), Length(OrderDataInds),
                   K_GetPIArray0(FreeDataInds), Length(FreeDataInds), nil, 0 );
      POrderDataInds^ := OrderDataInds;
      if PFreeDataInds <> nil then
        PFreeDataInds^ := FreeDataInds;
    end;
  end;
end; //*** end of K_RebuildRACDRelAll

//************************************************ K_RebuildRACDRel
//
function K_RebuildRACDRel( CDRelRA : TK_RArray; UDCDim : TN_UDBase;
                           PConvInds : PInteger; RemoveUndefInds : Boolean;
                           POrderDataInds, PFreeDataInds : TN_PIArray ) : Boolean;
var
  Ind : Integer;
begin
  Result := false;
  if CDRelRA = nil then Exit;
  Ind := K_IndexOfRACDRelCDim( CDRelRA, UDCDim, 0 );
  if Ind = -1 then Exit;
  Result := K_RebuildRACDRel( CDRelRA, Ind, PConvInds, RemoveUndefInds,
                                 POrderDataInds, PFreeDataInds );
end; //*** end of K_RebuildRACDRel

//********************************************* K_RACDRelLinkedDataReorder
// RACDRel Self Code Dimention Data Reorder
//
procedure K_RACDRelLinkedDataReorder( RACDRel : TK_RArray );
var
  POrderInds, PFreeInds, PInitInds : PInteger;
  OrderIndsCount : Integer;
  FreeIndsCount  : Integer;
  InitIndsCount  : Integer;
begin
  with RACDRel, TK_PCDRelAttrs(PA)^ do begin
    if (CUDCSDim <> nil) and
       TK_UDCSDim(CUDCSDim).GetConvDataInds( POrderInds, OrderIndsCount,
              PFreeInds, FreeIndsCount, PInitInds, InitIndsCount ) then
      ReorderRows( POrderInds, OrderIndsCount, PFreeInds, FreeIndsCount,
                   PInitInds, InitIndsCount );
  end;
end; // end of K_RACDRelLinkedDataReorder

//************************************************ K_BuildCSDBRelFromRACDRelByInds
//  Build 2-level CSBDlock of CDRels from RACSDRel
//
function K_BuildCSDBRelFromRACDRelByInds( CDRelRA : TK_RArray;
                                    PLevelCDInds : PInteger; LevelCount : Integer;
                                    CreateRAFlags : TK_CreateRAFlags = [];
                                    DescendingOrder : Boolean = false ) : TK_RArray;

var
  CDimsCount : Integer;
  NLevelCDims : TN_UDArray;
  PUDCDims : TN_PUDBase;
  BInds, SInds : TN_IArray;
  i, j, RCount, k, n{, m} : Integer;
  LevelCDRel : TK_RArray;
  LevelInds : TN_IArray;
  MoveInds : TN_IArray;

  procedure MoveData( var DData; const SData; Count : Integer; PMoveInds : PInteger; MoveCount : Integer );
  begin
    K_MoveMatrixBySIndex( DData, MoveCount * SizeOf(Integer),  SizeOf(Integer),
                              SData,  CDimsCount * SizeOf(Integer), SizeOf(Integer),
                              SizeOf(Integer),
                              Count, MoveCount, nil, PMoveInds );
  end;

begin
  Result := nil;
  if LevelCount = 0 then Exit;

  CDimsCount := K_GetRACDRelPUDCDims( CDRelRA, PUDCDims );
  if CDimsCount <= LevelCount then Exit;

  RCount := CDRelRA.ARowCount;
  if RCount < 1 then Exit;

  SetLength( NLevelCDims, LevelCount );
  MoveData( NLevelCDims[0], PUDCDims^, 1, PLevelCDInds, LevelCount );

//*** Biuld Indices Order Index
  // Copy Indices Corresponding to Level CDims to Buffer
  SetLength( LevelInds, RCount * LevelCount );
  MoveData( LevelInds[0], CDRelRA.P^, RCount, PLevelCDInds, LevelCount );

  // Build Indices Order Index
  SetLength( SInds, RCount );
  K_BuildCDRelIndsOrdIndex( @SInds[0], @LevelInds[0],
                                    LevelCount, RCount, DescendingOrder );
//*** Biuld Bounds Indices
  SetLength( BInds, RCount );
  j := K_BuildCDRelOrdIndsBounds( @BInds[0], @SInds[0], @LevelInds[0],
                                  LevelCount, RCount );

  SetLength( BInds, j + 1 );
  BInds[j] := RCount;

//*** Create Level CDRel which contains all different elements
  LevelCDRel := K_CreateRACDRel( @NLevelCDims[0], LevelCount, K_cdrList, CreateRAFlags );
  LevelCDRel.ASetLength( LevelCount, j );
  K_MoveCDRelOrdIndsBoundsValues( LevelCDRel.P, @BInds[0], @SInds[0], @LevelInds[0],
                                  LevelCount, j );

//*** Create Result Block
  Result := K_CreateRADBlock( K_GetExecTypeCodeSafe( 'TK_CSDBRel' ),
                                LevelCDRel, nil, CreateRAFlags, 1 );
  LevelCDRel.ARelease;

//*** Create Dependent Level CDRels
  // Build Indices XOR to HCDInds
  k := CDimsCount - LevelCount;
  SetLength( MoveInds, k );
  K_BuildXORIndices( @MoveInds[0], PLevelCDInds, LevelCount, CDimsCount, true );

  // Move XOR CDims to NLevelCDims
  SetLength( NLevelCDims, k );
  MoveData( NLevelCDims[0], PUDCDims^, 1, @MoveInds[0], k );

  for i := 0 to j - 1 do begin
    // Create CDRel
    LevelCDRel := K_CreateRACDRel( @NLevelCDims[0], k, K_cdrBag, CreateRAFlags );
    n := BInds[i+1] - BInds[i];
    LevelCDRel.ASetLength( k, n );
    // Set CDRel Inds
    K_MoveMatrixBySIndex( LevelCDRel.P^, k * SizeOf(Integer),  SizeOf(Integer),
                              CDRelRA.P^,  CDimsCount * SizeOf(Integer), SizeOf(Integer),
                              SizeOf(Integer),
                              n, k, @SInds[BInds[i]], @MoveInds[0] );
    // Put CDRel to Result Block
    TK_PRArray(Result.P(i))^ := LevelCDRel
  end;

end; //*** end of K_BuildCSDBRelFromRACDRelByInds

//************************************************ K_BuildCSDBRelFromRACDRel
//  Build 2-level CSBDlock of CDRels from RACSDRel
//
function K_BuildCSDBRelFromRACDRel( CDRelRA : TK_RArray; PLevelCDims : TN_PUDBase;
                                    LevelCount : Integer;
                                    CreateRAFlags : TK_CreateRAFlags = [];
                                    DescendingOrder : Boolean = false ) : TK_RArray;
var
  HCDInds : TN_IArray;
  i, HCDInd : Integer;
  PLevelCDims0 : TN_PUDBase;

begin
  Result := nil;
  if LevelCount = 0 then Exit;

  SetLength( HCDInds, LevelCount );
  PLevelCDims0 := PLevelCDims;
  for i := 0 to LevelCount - 1 do begin
    HCDInd := K_IndexOfRACDRelCDim( CDRelRA, PLevelCDims0^ );
    if HCDInd < 0 then Exit;
    HCDInds[i] := HCDInd;
    Inc(PLevelCDims0);
  end;
  Result := K_BuildCSDBRelFromRACDRelByInds( CDRelRA,
                                    @HCDInds[0], LevelCount,
                                    CreateRAFlags, DescendingOrder );
end; //*** end of K_BuildCSDBRelFromRACDRel

//************************************************ K_BuildRACDRelOrdInds
//  Build RACDRel Order Indices for specified number of Relation Column CDInd
//
procedure K_BuildRACDRelOrdInds( PInds : PInteger; CDRelRA : TK_RArray;
                                 CDInd : Integer; DescendingOrder : Boolean );
begin
  N_CFuncs.Offset := 0;
  N_CFuncs.DescOrder := DescendingOrder;
  with CDRelRA do
    N_BuildSortedElemInds ( PInds, PME(CDInd, 0), ARowCount,
                            AColCount * SizeOf(Integer), N_CFuncs.CompOneInt );
end; //*** end of K_BuildRACDRelOrdInds

//************************************************ K_BuildRACDRelOrdInds
//  Build RACDRel Order Indices for specified UDCDim
//
function K_BuildRACDRelOrdInds( PInds : PInteger; CDRelRA : TK_RArray;
                                UDCDim : TN_UDBase; DescendingOrder : Boolean ) : Boolean;
var
  CDInd : Integer;
begin
  CDInd := K_IndexOfRACDRelCDim( CDRelRA, UDCDim );
  Result := CDInd >= 0;
  if not Result then Exit;
  K_BuildRACDRelOrdInds( PInds, CDRelRA, CDInd, DescendingOrder );
end; //*** end of K_BuildRACDRelOrdInds

//************************************************ K_RemoveRACDRelEmptyElems
//  Remove RACDRel Empty Elements (Each Element SubElement Value = -1)
//
procedure K_RemoveRACDRelEmptyElems( CDRelRA : TK_RArray; ClearAnyFlag : Boolean = false );
var
  SavedInds : TN_IArray;
  i, j, RCount, CCount, SCount : Integer;
  EmptyElement : Boolean;
begin

// Build Saved Elems Indices
  CCount := CDRelRA.AColCount;
  RCount := CDRelRA.ARowCount;
  SetLength( SavedInds, RCount );
  SCount := 0;
  for i := 0 to RCount - 1 do begin
    EmptyElement := false;
    for j := 0 to CCount - 1 do begin
      EmptyElement :=  PInteger(CDRelRA.PME( j, i ))^ = -1;
      if (EmptyElement and ClearAnyFlag) or
         (not EmptyElement and not ClearAnyFlag) then break;
    end;
    if EmptyElement then Continue;
    SavedInds[SCount] := i;
    Inc(SCount);
  end;

// Remove Empty Elements from Relation
  CDRelRA.ReorderRows( @SavedInds[0], SCount, nil, 0, nil, 0 );
end; //*** end of K_RemoveRACDRelEmptyElems

//***********************************  K_BuildQAIndexElemsWidth
// Build Array if QAIndex Elements Bit Width
//
//#F
//          Relation QAIndex Routines
// QAIndex of Relation (or SubRelation)
// QAIndex - Matrix (NxM) of Integer stored in TN_IArray by Rows
// N number of columns, M - number of rows = number of Elements in Relation
// 0-column - sorted Indices of Relation Elements
// 1 - M-1 column - compressed Relation Elements Indices
//  (each row - all Indices of Relation Element)
// Compact Elements Indices are incremented - value=0 is used for undefined index =-1
//#/F
//
function K_BuildQAIndexElemsWidth( var CIndsWidth : TN_IArray;
                                   QAIndexCDCount : Integer;
                                   PQAIndexCD  : TN_PUDBase;
                                   PQAIndexCDCor : TN_PUDBase = nil ) : Integer;
var
  i  : Integer;
  BitWidth : Integer;
  UDCDCor : TK_UDCDCor;
  UDCDim : TK_UDCDim;
  CDimCount : Integer;
begin

  SetLength( CIndsWidth, QAIndexCDCount );
  BitWidth := 0;
  for i := 0 to QAIndexCDCount - 1 do begin
    UDCDim := TK_UDCDim(PQAIndexCD^);
    Inc(PQAIndexCD);
    CDimCount := UDCDim.CDimCount;
    if PQAIndexCDCor <> nil then begin
      UDCDCor := TK_UDCDCor(PQAIndexCDCor^);
      Inc(PQAIndexCDCor);
      if UDCDCor <> nil then
        CDimCount := UDCDCor.GetSecCDim.CDimCount;
    end;
//    CIndsWidth[i] := K_ValueBitWidth( CDimCount - 1 );
//    if CIndsWidth[i] = 0 then CIndsWidth[i] := 1;
    CIndsWidth[i] := K_IntValueBitWidth( CDimCount + 1 );
    BitWidth := BitWidth + CIndsWidth[i];
  end;
  Result := (BitWidth + 31) div 32;
end; // end of K_BuildQAIndexElemsWidth

//***********************************  K_PrepQAIndexElem
// Prepare QAIndex Elem Compact Inds
//
procedure K_PrepQAIndexElem( PQAIndex : PInteger; CIndsWidth : TN_IArray;
                             PQACDRInds : PInteger; PCDInds : PInteger = nil;
                             PQAIndexCDCor : TN_PUDBase = nil );
var
  i : Integer;
  BitWidth : Integer;
  UDCDCor : TK_UDCDCor;
  CWidth0, CWidth : Integer;
  CurInd : Integer;
begin

  BitWidth := 0;
  PQAIndex^ := 0;
  for i := 0 to High(CIndsWidth) do begin
    if PCDInds <> nil then begin
      CurInd := PInteger(TN_BytesPtr(PQACDRInds) + PCDInds^ * SizeOf(Integer))^;
      Inc( PCDInds );
    end else begin
      CurInd := PQACDRInds^;
      Inc( PQACDRInds );
    end;

    if (PQAIndexCDCor <> nil) and (Integer(CurInd) >= 0) then begin
      UDCDCor := TK_UDCDCor(PQAIndexCDCor^);
      Inc(PQAIndexCDCor);
      if UDCDCor <> nil then
         CurInd := PInteger(TN_BytesPtr(UDCDCor.GetPFCorInds) + CurInd * SizeOf(Integer))^;
    end;

    CWidth := CIndsWidth[i];
{
    if Integer(CurInd) < 0 then begin
    // Clip Negative Value
      CWidth0 := 32 - CWidth;
      CurInd := CurInd shl CWidth0;
      CurInd := CurInd shr CWidth0;
    end;
}
    // to avoid undefined index =-1
    Inc(CurInd);

    if BitWidth + CWidth > 32 then begin
    //*** Field Lies in Neighboring Cells
    //  Add Field Part to Current Cell
      if BitWidth < 32 then begin
        PQAIndex^ := PQAIndex^ + CurInd shl BitWidth;
    //  Scroll to Next Cell
        CWidth0 := 32 - BitWidth;
        CurInd := CurInd shr CWidth0;
        CWidth := CWidth - CWidth0;
      end;
      Inc(PQAIndex);
      PQAIndex^ := 0;
      BitWidth := 0;
    end;
    PQAIndex^ := PQAIndex^ or CurInd shl BitWidth;
    BitWidth := BitWidth + CWidth;
  end;
end; // end of K_PrepQAIndexElem

//***********************************  K_BuildQAIndex
// Build CDims Relation Query Acceleration Indices
// in QAIndex Matrix QAInds (QAInds row Length in Integers = QAIndsStep)
//
procedure K_BuildQAIndex( PQAInds : PInteger; QAIndsCount, QAIndsBStep : Integer;
                          PRelInds : PInteger; RelIndsElemCount : Integer; RelIndsBStep : Integer;
                          CIndsWidth : TN_IArray;
                          PCDInds : PInteger = nil;
                          PQAIndexCDCor : TN_PUDBase = nil );
var
  j : Integer;
  CPData : PLongWord;
  CSortBuf : TN_BArray;
  CSortIndsBuf : TN_IArray;
  CSortDataSize : Integer;
  CompareFunc: TN_CompFuncOfObj;
begin

//    Prepare Compact CDRel CDims Indices
  for j := 0 to RelIndsElemCount - 1 do
    K_PrepQAIndexElem(
      PInteger( TN_BytesPtr(PQAInds) + QAIndsBStep * j + SizeOf(Integer) ), CIndsWidth,
      PInteger(TN_BytesPtr(PRelInds) + RelIndsBStep * j), PCDInds, PQAIndexCDCor  );

//    Build QAIndex SortIndex
  SetLength( CSortIndsBuf, RelIndsElemCount );
  CPData := PLongWord( TN_BytesPtr(PQAInds) + SizeOf(Integer) );

  N_CFuncs.Offset := 0;
  N_CFuncs.DescOrder := false;
  N_CFuncs.NumFields := QAIndsCount - 1;
  CompareFunc := N_CFuncs.CompNInts;
  if N_CFuncs.NumFields = 1 then
    CompareFunc := N_CFuncs.CompOneInt;
  N_BuildSortedElemInds ( @CSortIndsBuf[0], CPData, RelIndsElemCount, QAIndsBStep,
                          CompareFunc );

//    Copy QAIndex to Buffer in Sort Order
  CSortDataSize := SizeOf(Integer) * (QAIndsCount - 1);
  SetLength( CSortBuf, CSortDataSize * RelIndsElemCount );
  K_MoveVectorBySIndex( CSortBuf[0], CSortDataSize,
                      CPData^, QAIndsBStep,
                      CSortDataSize, RelIndsElemCount, @CSortIndsBuf[0] );

//    Return Sorted QAIndex from Buffer
  K_MoveVector( CPData^, QAIndsBStep, CSortBuf[0], CSortDataSize,
              CSortDataSize, RelIndsElemCount );
  K_MoveVector( PQAInds^, QAIndsBStep, CSortIndsBuf[0], SizeOf(Integer),
              SizeOf(Integer), RelIndsElemCount );

end; // end of K_BuildQAIndex

//***********************************  K_GetRACDRelQAIndexUDID
// Get CDims Relation Query Acceleration Index ID
//  QAIndex ID - Array of TN_UDBase (PQAIndexUDID), that contains two lies sequentialy in memory
//  Arrays - Array of References to TK_UDCDims objects and simultaneous
//  Array of References to TK_UDCDCor objects each to each.
//  PCDInds show which UDCDims of Relation RACDRel are put to QAIndex ID
//
procedure K_GetRACDRelQAIndexUDID( PQAIndexUDID : TN_PUDBase; RACDRel : TK_RArray;
                                   PCDInds : PInteger; Count : Integer;
                                   PUDCDCors : TN_PUDBase = nil  );
var
  i : Integer;
  PUDCDims0 : TN_PUDBase;
  CDRCDCount : Integer;
  CDInd : Integer;

begin
  FillChar( PQAIndexUDID^, 2 * Count * SizeOf(TN_UDBase), 0 );
  with TK_PCDRelAttrs(RACDRel.PA)^, CDRQAInfo do begin
    CDRCDCount := K_GetRACDRelPUDCDims( RACDRel, PUDCDims0 );
    for i := 0 to Count - 1 do begin
      CDInd := PCDInds^;
      assert( (CDInd >= 0) and (CDInd < CDRCDCount), 'Build CDRel QAInds - CDims Range Check Error' );
      PQAIndexUDID^ := TN_PUDBase(TN_BytesPtr(PUDCDims0) + CDInd * SizeOf(TN_UDBase))^;
      Inc(PQAIndexUDID);
      Inc(PCDInds);
    end;
    if PUDCDCors <> nil then
      for i := 0 to Count - 1 do begin
        PQAIndexUDID^ := PUDCDCors^;
        Inc(PUDCDCors);
        Inc(PQAIndexUDID);
      end;
  end;
end; // end of K_GetRACDRelQAIndexUDID

//***********************************  K_IndexOfRACDRelQAIndex
// Search for CDims Relation Query Acceleration Index
//  returns QAData Column Index in QADataInd and QADataWidth in Result
//
function K_IndexOfRACDRelQAIndex( out QADataInd : Integer; RACDRel : TK_RArray;
                                  PQAIndexUDID : TN_PUDBase; Count : Integer  ) : Integer;
var
  L, LB, L2, i  : Integer;
  LI : Integer;
  QAIDsLength : Integer;
  QADataColCount : Integer;

begin

  with TK_PCDRelAttrs(RACDRel.PA)^, CDRQAInfo do begin
    LI := QAAttrs.AHigh;
    L2 := Count * 2;
    LB := L2 * SizeOf(Integer);
    QAIDsLength := QAIDs.ALength;
    QADataColCount := QAData.AColCount;
  //*** Search for proper QAIndex
    Result := -1;
    for i := 0 to LI do begin
      with TK_PCDRQAHead(QAAttrs.P(i))^ do begin
        if i < LI then
          L := TK_PCDRQAHead(QAAttrs.P(i+1)).SIDInd - SIDInd
        else
          L := QAIDsLength - SIDInd;
        if L2 <> L then Continue;
        if CompareMem( QAIDs.P( SIDInd ), PQAIndexUDID, LB ) then begin
          QADataInd := SDataInd;
          if i < LI then
            Result := TK_PCDRQAHead(QAAttrs.P(i+1)).SDataInd - SDataInd
          else
            Result := QADataColCount - SDataInd;
          Exit;
        end;
      end;
    end;
  end;
end; // end of K_IndexOfRACDRelQAIndex

//***********************************  K_GetRACDRelQAIndex
// Get CDims Relation Query Acceleration Indices (build if needed)
//  returns QAData Column Index in QADataInd and QADataWidth in Result
//
function K_GetRACDRelQAIndex( out QADataInd : Integer; RACDRel : TK_RArray; PCDInds : PInteger;
                              Count : Integer; PUDCDCors : TN_PUDBase = nil  ) : Integer;
var
  LB, L2 : Integer;
  LI : Integer;
  QAIDsLength : Integer;
  QADataColCount : Integer;
  QADataRowCount : Integer;
  QADataNCount : Integer;
  QAIndexUDID : TN_UDArray;
  CIndsWidth : TN_IArray;

begin

  with TK_PCDRelAttrs(RACDRel.PA)^, CDRQAInfo do begin
    LI := QAAttrs.AHigh;
    L2 := Count * 2;
    LB := L2 * SizeOf(Integer);

  //*** Build QAIndex ID
    SetLength( QAIndexUDID, L2 );
    K_GetRACDRelQAIndexUDID( @QAIndexUDID[0], RACDRel, PCDInds, Count, PUDCDCors );

  //*** Search QAIndex by ID
    Result := K_IndexOfRACDRelQAIndex( QADataInd, RACDRel, @QAIndexUDID[0], Count );
    if Result >= 0 then Exit;

  //*** Add New QAIndex
    QAIDsLength := QAIDs.ALength;
    QADataColCount := QAData.AColCount;
  //  Add QAIndex Attrs
    QADataInd := QADataColCount;
    QAAttrs.ASetLength( LI + 2 );
    with TK_PCDRQAHead(QAAttrs.P(LI + 1))^ do begin
      SIDInd := QAIDsLength;
      SDataInd := QADataColCount;
    end;

  //  Add QAIndex ID
    QAIDs.ASetLength( QAIDsLength + L2 );
    Move( QAIndexUDID[0], QAIDs.P(QAIDsLength)^, LB );

  //  Add QAIndex Data
  //    Calc QAIndex Compact Indices Width
    QADataNCount := 1 + K_BuildQAIndexElemsWidth( CIndsWidth, Count,
                                  @QAIndexUDID[0], @QAIndexUDID[Count] );

  //    Add QAIndex Data Columns
    Result := QADataNCount;
    QADataRowCount := RACDRel.ARowCount;
    QAData.ASetLength( QADataNCount + QADataColCount, QADataRowCount );

  //    Build QAIndex
    K_BuildQAIndex(
            QAData.PME(QADataColCount, 0), QADataNCount, QAData.ElemSize * QAData.AColCount,
            RACDRel.PME(0, 0), QADataRowCount, RACDRel.ElemSize * RACDRel.AColCount,
            CIndsWidth, PCDInds, @QAIndexUDID[Count] );
  end;
end; // end of K_GetRACDRelQAIndex

//***********************************  K_BuildRACDRelCorInds
// Build Correspondece Indices for Two CDim Relations
//
//  PCorInds - corrensponding indices
//  QAWidth  - number of integer fields in QAIndex including Relation Sort Index
//  RACDRel1 - 1-st CDims Relation
//  QAIndex1 - number of 1-st CDims Relation QAIndex
//  RACDRel2 - 2-nd CDims Relation
//  QAIndex2 - number of 2-nd CDims Relation QAIndex
procedure K_BuildRACDRelCorInds( PCorInds : PInteger;  QAWidth : Integer;
                                 RACDRel1 : TK_RArray; QAIndex1 : Integer;
                                 RACDRel2 : TK_RArray; QAIndex2 : Integer );
var
  i, j, Count1, Count2, CResult, I2 : Integer;
  P1, P2 : PInteger;
begin
  N_CFuncs.Offset := 0;
  N_CFuncs.DescOrder := false;
  N_CFuncs.NumFields := QAWidth - 1;
  Count2 := RACDRel2.ARowCount;
  Count1 := RACDRel1.ARowCount;
  FillChar( PCorInds^, Count2 * SizeOf(Integer), -1 );
  j := 0;
  QAIndex1 := QAIndex1 + 1; // Shift Column Ind to Compact QAIndex1
  for i := 0 to Count2 - 1 do begin
    with TK_PCDRelAttrs(RACDRel2.PA).CDRQAInfo.QAData do begin
      P2 := PME(QAIndex2, i);
      I2 := P2^; // Get CDRel2 Elem Index
      Inc(P2);   // Shift Pointer to Compact QAIndex2

      while j < Count1 do begin //*** CDRel1 QAIndex While Loop
        with TK_PCDRelAttrs(RACDRel1.PA).CDRQAInfo.QAData do
          P1 := PME(QAIndex1, j);
        CResult := N_CFuncs.CompNInts( P2, P1 ); // Compare Compact QAIndex2 and QAIndex1
        if CResult > 0 then
          Inc(j) //*** Step to Next CDRel1 Elem
        else if CResult <= 0 then begin
          if CResult = 0 then begin
            Dec(P1); // Shift Pointer to CDRel1 Elem Index
            PInteger( TN_BytesPtr(PCorInds) + I2 * SizeOf(Integer) )^ := P1^;
            Inc(PCorInds);
          end;
          break; //*** Step to Next CDRel2 Elem
        end;
      end; //*** end of CDRel1 QAIndex While Loop

    end;
  end;
end; // end of K_BuildRACDRelCorInds
//****************************************
// end of Relation QAIndex Routines
//****************************************

//***************************************** K_BuildUDCDCorDefName
// Build  CDims Relation default Name
//
function  K_BuildUDCDCorDefName( UDCDimPrimary, UDCDimSecondary : TN_UDBase ) : string;
begin
  Result := K_FCSDRelNewName+'_'+UDCDimSecondary.ObjName+'-'+UDCDimPrimary.ObjName;
end; // end of procedure K_BuildUDCDCorDefName

//***************************************** K_BuildUDCDCorDefAliase
// Build  CDims Relation default Name
//
function  K_BuildUDCDCorDefAliase( UDCDimPrimary, UDCDimSecondary : TN_UDBase ) : string;
begin
  Result := UDCDimSecondary.GetUName+' > '+UDCDimPrimary.GetUName;
end; // end of procedure K_BuildUDCDCorDefAliase

//********************************************* K_ConvRACDIRefs
// Code Dimention Items References RArray Conversion
//
function K_ConvRACDIRefs( RACDIRefs : TK_RArray; UDCD : TN_UDBase;
                          PConvInds : PInteger; RemoveUndefInds : Boolean ) : Boolean;
var
  i, h : Integer;
begin
  Result := False;
//*** Convert CDim Items Refs
  h := RACDIRefs.AHigh;
  for i := h downto 0 do
    with TK_PCDIRef(RACDIRefs.P(i))^ do
      if CDRCDim = UDCD then begin
      //*** CDim is Found - Conv Item Index and Exit
        CDRItemInd := PInteger( TN_BytesPtr(PConvInds) + CDRItemInd * SizeOf(Integer) )^;
        if (CDRItemInd = -1) and RemoveUndefInds then
          RACDIRefs.DeleteElems(i);
//        if not CDIRefsDuplicateFlag then Exit;
        Result := true;
      end;

end; // end of K_ConvRACDIRefs

//********************************************* K_IndexOfRACDIRefsCDim
// Code Dimention Items References RArray Conversion
//
function K_IndexOfRACDIRefsCDim( RACDIRefs : TK_RArray; UDCD : TN_UDBase; SInd : Integer = 0 ) : Integer;
var
  i : Integer;
begin
  Result := -1;
  for i := SInd downto RACDIRefs.AHigh do begin
    with TK_PCDIRef(RACDIRefs.P(i))^ do
      if CDRCDim <> UDCD then Continue;
    Result := i;
    Exit;
  end;

end; // end of K_IndexOfRACDIRefsCDim

//***************************************** K_CompressCDIRefs
// Compress CDim References
//
function  K_CompressCDIRefs( PRRefs : TK_PCDIRef; PSRefs : TK_PCDIRef;
                   RefsCount : Integer; ClearCDResTail : Boolean = true ) : Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to RefsCount - 1 do begin
    if (PSRefs.CDRCDim <> nil) then begin
      PRRefs^ := PSRefs^;
      Inc(Result);
      Inc(PRRefs);
    end;
    Inc(PSRefs);
  end;
  if ClearCDResTail and (Result < RefsCount) then
    FillChar( PRRefs^, (RefsCount - Result) * SizeOf(TK_CDIRef), 0 );
end; // end of K_CompressCDIRefs

//***************************************** K_InitCSpaceGCont ***
// Init Global Archive Code Space context
//
procedure K_InitCSpaceGCont( CurArchive : TN_UDBase = nil );
begin
  K_CurCDimsRoot := nil;
  K_CurUserRoot := nil;
  if CurArchive = nil then CurArchive := K_CurArchive;
  if CurArchive = nil then Exit;
  with CurArchive do begin
    K_CurCDimsRoot :=
            DirChild( IndexOfChildObjName( K_CDimsRootName ) );
    if K_CurCDimsRoot = nil then begin
      K_CurCDimsRoot := K_AddArchiveSysDir( K_CDimsRootName, K_sftReplace, CurArchive );
      K_CurCDimsRoot.ObjAliase := K_CDimsRootAliase;
    end;
  end;

end; // end of procedure K_InitDCodeGCont

//********************************************* K_CastIndsToDouble
//  Cast Array of Indices to Double
//
procedure K_CastIndsToDouble( PDData : PDouble; DStep :Integer;
                              PInds : PInteger; IStep :Integer;
                              DCount : Integer; UndefValue : Double );
var
  i : Integer;
  IV : Integer;
begin
  for i := 1 to DCount do begin
    IV := PInteger(PInds)^;
    if IV < 0 then
      PDouble(PDData)^ := UndefValue
    else
      PDouble(PDData)^ := IV;
    Inc(TN_BytesPtr(PDData), DStep);
    Inc(TN_BytesPtr(PInds), IStep);
  end;
end; //*** end of function K_CastIndsToDouble



//************************************************ K_BuildCDRelIndsOrdIndex
//  Build CDRel Indices Order Index
//  Size of memory wich must be reserved for Order Index - RCount * SizeOf(Integer)
//  returns number of different element in CDRel Indices
//
procedure K_BuildCDRelIndsOrdIndex( POrdInds, PRelInds : PInteger;
                                    CCount, RCount : Integer;
                                    DescendingOrder : Boolean = false );
begin

  // Build Indices Order Index
  N_CFuncs.Offset := 0;
  N_CFuncs.NumFields := CCount;
  N_CFuncs.DescOrder := DescendingOrder;
  N_BuildSortedElemInds ( POrdInds, PRelInds, RCount,
                          CCount * SizeOf(Integer), N_CFuncs.CompNInts ); //

end; //*** end of K_BuildCDRelIndsOrdIndex

//************************************************ K_BuildCDRelOrdIndsBounds
//  Build CDRel Ordered Indices Bounds
//  Size of memory wich must be reserved for Order Index Bounds - RCount * SizeOf(Integer)
//  returns number of different element in CDRel Indices
//
function K_BuildCDRelOrdIndsBounds( PBounds, POrdInds, PRelInds : PInteger;
                                    CCount, RCount : Integer ) : Integer;
var
  i, k : Integer;
  PCurInd : PInteger;
  DStep : Integer;
begin
  Result := 0;
  k := -100;
  N_CFuncs.Offset := 0;
  N_CFuncs.NumFields := CCount;
  DStep := CCount * SizeOf(Integer);
  for i := 0 to RCount - 1 do begin
    PCurInd := PInteger( TN_BytesPtr(PRelInds) + (POrdInds^ * DStep) );
    if N_CFuncs.CompNInts( @k, PCurInd ) <> 0 then begin
      k := PCurInd^;
      PBounds^ := i;
      Inc(PBounds);
      Inc(Result);
    end;
    Inc( POrdInds );
  end;

end; //*** end of K_BuildCDRelOrdIndsBounds

//************************************************ K_MoveCDRelOrdIndsBoundsValues
//  Build CDRel Ordered Indices Bounds
//  Size of memory wich must be reserved for Different Elements Values
//  is CCount * SizeOf(Integer) * Relation Elements Count
//  returns number of different element in CDRel Indices
//
procedure K_MoveCDRelOrdIndsBoundsValues( PDInds, PBounds, POrdInds, PRelInds : PInteger;
                                          CCount, BCount : Integer );
var
  i, k : Integer;
begin
  k := CCount * SizeOf(Integer);
  for i := 0 to BCount - 1 do begin
    Move( (TN_BytesPtr(PRelInds) + PInteger(TN_BytesPtr(POrdInds) + PBounds^*SizeOf(Integer))^ * k)^,
           PDInds^, k );
    Inc(PBounds);
    Inc(TN_BytesPtr(PDInds), k);
  end;
end; //*** end of K_MoveCDRelOrdIndsBoundsValues

//************************************************ K_ShiftTSDate
// Shift Date by TimeStamps Date Delta
//
function K_ShiftTSDate( SDate : TDateTime; Delta : Integer;
                        DUnits : TK_TimeStampUnits ) : TDateTime;
var
  I10D, I10M : Integer;
begin
  Result := SDate;
  if Delta = 0 then Exit;
  case DUnits of
    K_tduYear   :  Result := IncYear( Result, Delta );
    K_tduHYear  :  Result := IncMonth( Result, Delta * 6 );
    K_tduQuarter:  Result := IncMonth( Result, Delta * 3 );
    K_tduMonth  :  Result := IncMonth( Result, Delta );
    K_tdu10Days :  begin
      I10M := (Delta div 3);
      I10D := Delta - I10M * 3;
      if I10M <> 0 then
        Result := IncMonth( Result, I10M );
      if I10D <> 0 then
        Result := IncDay( Result, I10D * 10 );
    end;
    K_tduWeek   :  Result := IncWeek( Result, Delta );
    K_tduDay    :  Result := IncDay( Result, Delta );
  end;
end; //*** end of function K_ShiftTSDate

//************************************************ K_ShiftTSDate
// Shift Date by TimeStamps Date Delta
//
function K_ShiftTSDate( SDate : TDateTime; Delta : Double;
                        DUnits : TK_TimeStampUnits ) : TDateTime;
var
  IDelta : Integer;
begin
  IDelta := Floor(Delta);
  Result := K_ShiftTSDate( SDate, IDelta, DUnits );
  Delta := Delta - IDelta;
  if Delta = 0 then Exit;
  IDelta := Round( Delta * SecondsBetween(Result, K_ShiftTSDate( Result, 1, DUnits ) ) );
  Result := IncSecond(Result, IDelta);
end; //*** end of function K_ShiftTSDate

//************************************************ K_GetTimeStampsDates
// Get Dates from TimeStamps RArray
//  TS - ArrayOf TK_TimeStamps
//  PDate - pointer to start element of ArrayOf TDate
//
procedure K_GetTimeStampsDates( TS : TK_RArray; PDate : PDateTime );
var
  i : Integer;
  PTimeStampsAttrs : TK_PTimeStampsAttrs;
begin
  with TS do begin
    PTimeStampsAttrs := TK_PTimeStampsAttrs( TS.PA );
    for i := 0 to TS.AHigh do begin
      with PTimeStampsAttrs^ do
        PDate^ := K_ShiftTSDate( SDate, PInteger(TS.P(i))^, TSUnits );
      Inc(PDate);
    end;
  end;
end; //*** end of procedure K_GetTimeStampsDates

//**************************************** K_GetTimeStampsStrings
//
procedure K_GetTimeStampsStrings( TS : TK_RArray; PSDate : PString; Format : string = '' );
var
  n, i : Integer;
  Dates : TN_DArray;

begin
  n := TS.ALength;
  if n > 0 then begin
    SetLength( Dates, n );
    K_GetTimeStampsDates( TS, PDateTime(@Dates[0]) );
    if Format = '' then
      Format := 'dd.mm.yyyy';
    for i := 0 to n - 1 do begin
      PSDate^ := K_DateTimeToStr( TDateTime(Dates[i]), Format );
//      FormatDateTime( Format, TDateTime(Dates[i]) );
      Inc(PSDate);
    end;
  end;
end; //*** procedure K_GetTimeStampsStrings

{*** TK_UDCDim ***}
//********************************************* TK_UDCDim.RebuildFullCSD
// Rebuild Full CDim Inds
//
procedure TK_UDCDim.RebuildFullCSD( Count : Integer; FCSD : TK_UDCSDim = nil );
begin
  if FCSD = nil then
    FCSD := TK_UDCSDim( DirChildByObjName( K_FFulCSDimName ) );
  if FCSD = nil then Exit;
  with FCSD.R do begin
    ASetLength( Count );
    K_FillIntArrayByCounter( P, Count );
  end;
  FCSD.ClearAInfo;
end; // end of procedure TK_UDCDim.RebuildFullCSD

{
//********************************************* TK_UDCDim.StartScanSubTree
// Starts ScanSubtree
//
procedure TK_UDCDim.StartScanSubTree( TestNodeFunc : TK_TestUDChild );
begin
//??  K_UDScannedUObjsList := TList.Create;
  K_UDOwnerChildsScan := true;
  K_UDRAFieldsScan := false;
  K_CurArchive.ScanSubTree( TestNodeFunc );
  K_UDRAFieldsScan := true;
  K_UDOwnerChildsScan := false;
//??  K_ClearUObjsScannedFlag();
//??  FreeAndNil(K_UDScannedUObjsList);
end; // end of procedure TK_UDCDim.StartScanSubTree
}

//********************************************* TK_UDCDim.UDObjIsSelfCSDim
// Check if UDObj is Self Inds
//
function TK_UDCDim.UDObjIsSelfCSDim( UDObj : TN_UDBase; IncludeCDRels : Boolean  ): Boolean;
begin
{
  Result :=  // Object is TK_UDCSDim
     (UDObj is TK_UDCSDim)                             and
             // CSDim's UDCDim = Self
     (K_GetRACSDimCDim( TK_UDCSDim(UDObj).R ) = Self ) and
             // CSDim is not CDim's FUllCSDim
     ((UDObj.ObjName <> K_FFulCSDimName) or (UDObj.Owner <> Self));
}
  Result := (UDObj <> nil) and (UDObj is TK_UDCSDim);
  if not Result then Exit;
  if not (UDObj is TK_UDCDRel) then //*** UObj is CSDim
             // CSDim's UDCDim = Self
    Result := (K_GetRACSDimCDim( TK_UDCSDim(UDObj).R ) = Self ) and
             // CSDim is not CDim's FUllCSDim
              ((UDObj.ObjName <> K_FFulCSDimName) or (UDObj.Owner <> Self))
  else                              //*** UObj is CDRel
    with TK_UDRArray(UDObj) do
      Result := IncludeCDRels and
          // Linking Relation UDCSDim is CDim Self CSDim
        ( UDObjIsSelfCSDim( TK_PCDRelAttrs(R.PA).CUDCSDim, false ) or
          // Relation has proper CSDim
          (-1 <> K_IndexOfRACDRelCDim(R, Self)) );
end; // end of function TK_UDCDim.UDObjIsSelfCSDim
{
//********************************************* TK_UDCDim.RAObjIsSelfCSDim
// Check if RArray is Self Inds Object
//
function TK_UDCDim.RAObjIsSelfCSDim( RACSDim : TK_RArray; IncludeCDRels : Boolean ): Boolean;
begin
  Result := (RACSDim <> nil) and
  (
    (    // RAObj is CSDim
      (RACSDim.ArraySType = K_GetCSDimRAType.DTCode) and
        // CSDim's UDCDim = Self
      (K_GetRACSDimCDim( RACSDim ) = Self)
    )
                or
    (
      IncludeCDRels                                  and
        // RAObj is CDRel
      (RACSDim.ArraySType = K_GetCDRelRAType.DTCode) and
      (
        // Linking Relation UDCSDim is CDim Self CSDim
        UDObjIsSelfCSDim( TK_PCDRelAttrs(RACSDim.PA).CUDCSDim, false ) or
        // Relation has proper CSDim
        (-1 <> K_IndexOfRACDRelCDim(RACSDim, Self))
      )
    )
  );
end; // end of function TK_UDCDim.RAObjIsSelfCSDim
}
//********************************************* TK_UDCDim.PrepFullCSDimConvContext
// Prepare FullCSDim Converton Context
//
procedure TK_UDCDim.PrepFullCSDimConvContext( PConvInds: PInteger; ConvIndsCount: Integer;
                                             PBConvInds : PInteger; FullCSD : TK_UDCSDim );
var
  i, j, k : Integer;
  BConvIndex : TN_IArray;
  FreeFullCSDInds : TN_IArray;
  IniFullCSDInds : TN_IArray;
  SCount : Integer;
  BConvInds : TN_IArray;
  ConvInds : TN_IArray;
begin
  BConvInds := nil; // to avoid warning
//*** Prepare Self Full CDim Inds convertion
  if FullCSD = nil then
    FullCSD := GetFullCSDim;
  with FullCSD, R do begin
    SCount := ARowCount;
    if PConvInds = nil then begin
    // Create ConvInds if they are Absent
      SetLength( ConvInds, ConvIndsCount );
      PConvInds := K_GetPIArray0(ConvInds);
      if PConvInds <> nil then begin
        k := ConvIndsCount - Scount;
        if k > 0 then
          FillChar( ConvInds[Scount], k * SizeOf(Integer), -1 );
        K_FillIntArrayByCounter( PConvInds, Min(ConvIndsCount, SCount ) );
      end;
    end;

    //*** Build Free Old Items Indices
    SetLength( FreeFullCSDInds, SCount );
    if PBConvInds = nil then begin
      i := Max(ConvIndsCount, SCount);
      SetLength( BConvIndex, i );
      K_BuildBackIndex0( PConvInds, ConvIndsCount, @BConvIndex[0], i );
      PBConvInds := @BConvIndex[0];
    end;
    j := 0;
    for i := 0 to SCount - 1 do begin
      if PBConvInds^ < 0 then begin
        FreeFullCSDInds[j] := i;
        Inc(j);
      end;
      Inc(PBConvInds);
    end;
    //*** Build Init new Items Indexes
    SetLength( IniFullCSDInds, ConvIndsCount );
    k := ConvIndsCount - K_BuildActIndicesAndCompress(
                    @IniFullCSDInds[0], nil, nil, PConvInds, ConvIndsCount );
    SetLength( IniFullCSDInds, k );
    //*** Set Full CDim Inds Data Convertion Context
    SetConvDataInds( PConvInds, ConvIndsCount, K_GetPIArray0(FreeFullCSDInds), j,
       K_GetPIArray0(IniFullCSDInds), k );
    IndsAllReadyConved := true;
    ConvDataNeeded := true;

      //*** Rebuild Full CDim Inds Indexes
    RebuildFullCSD( ConvIndsCount, FullCSDim );
  end;
end; // end of procedure TK_UDCDim.PrepFullCSDimConvContext

//********************************************** TK_UDCDim.Create ***
//
constructor TK_UDCDim.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDCDimCI;
  ImgInd := 96;
end; // end of constructor TK_UDCDim.Create

//********************************************** TK_UDCDim.CreateAndInit
//
constructor TK_UDCDim.CreateAndInit( Name : string; Aliase : string = ''; UDCDimsRoot : TN_UDBase = nil );
begin
  Create;
  InitByRTypeCode( K_GetExecTypeCodeSafe('TK_CDim').All, 1 );
  ObjName := Name;
  if Aliase <> '' then ObjAliase := Aliase;
  if UDCDimsRoot = nil then Exit;
  with UDCDimsRoot do begin
    AddOneChild( Self );
    SetUniqChildName( Self );
  end;
  CreateCSDim; // Create CDim Full CSDim
//    K_AddSysObjFlags( K_CurCDimsRoot, Self, K_sftSkipAll );
end; // end of TK_UDCDim.CreateAndInit

//********************************************* TK_UDCDim.GetCDimRAAttrsInfo
// returns CDim Attributes RArray
//
function TK_UDCDim.GetCDimRAAttrsInfo( out CDimRAAttrs : TK_CDimRAAttrs; UDCDim : TN_UDBase; ItemInd : Integer ) : Boolean;
var
  i, j, RowCount, ColCount : Integer;
  UDAttrs : TN_UDBase;
  WRA : TK_RArray;
label RetRAVector;
begin
  Result := true;
  with CDimRAAttrs do
  if UDCDim = nil then begin
  //*** Get Pointer To Special Self Attributes
    case ItemInd of
      -1:
        RAContainer := CreateCSDim.R;
      Ord(K_cdiSclonKey), Ord(K_cdiName) :
        RAContainer := TK_PCDim(R.P).CDNames;
      Ord(K_cdiCode) :
        RAContainer := TK_PCDim(R.P).CDCodes;
      Ord(K_cdiEntryKey) :
        RAContainer := TK_PCDim(R.P).CDKeys;
    else
      Result := false;
    end;
    if not Result then Exit;
RetRAVector:
    PAData := RAContainer.P;
    ADStep := RAContainer.ElemSize;
    ADCount := RAContainer.Alength;
    Exit;
  end else begin
  //*** Search for Attributes - CDim UDChilds
    for i := 0 to DirHigh do begin
      UDAttrs := DirChild(i);
      if UDAttrs is TK_UDCDCor then
        //*** UDChild - Correspondence
        with TK_PCDCorAttrs(TK_UDCDCor(UDAttrs).R.PA)^, CDCorID do begin
          RAContainer := SecCSDim;
          Result :=
             ((ItemInd <> -1) and (UDCDim = CDRCDim) and (ItemInd = CDRItemInd)) or
             ((ItemInd = -1)  and (UDCDim = K_GetRACSDimCDim(SecCSDim)));
          if Result then goto RetRAVector;
        end
      else if UDAttrs is TK_UDCSDBlock then begin
        //*** UDChild - CSDBLock
        with TK_UDCSDBlock(UDAttrs) do begin
          WRA := GetCBRACDRel;
          RAContainer := R;
//          j := K_IndexOfRACDIRefsCDim( WRA, UDCDim );
          j := K_IndexOfRACDRelCDim( WRA, UDCDim );
          if (j <> -1) then begin
//            if (TK_PCDIRef( WRA.P(j) ).CDRItemInd = ItemInd) then
            if (PInteger( WRA.P(j) )^ = ItemInd) then
              goto RetRAVector;
          end else begin
            R.ALength( ColCount, RowCount );
            ADStep := RAContainer.ElemSize;
            WRA := GetColRACDRel;
            if (K_GetRACSDimCDim( WRA ) = UDCDim) then begin
              j := K_IndexOfRACSDimSelfInd( WRA, ItemInd);
              if j <> -1 then begin
                PAData := RAContainer.PME(j, 0);
                ADStep := ADStep * ColCount;
                ADCount := RowCount;
                Exit;
              end;
            end;
            WRA := GetRowRACDRel;
            if (K_GetRACSDimCDim( WRA ) = UDCDim) then begin
              j := K_IndexOfRACSDimSelfInd( WRA, ItemInd );
              if j <> -1 then begin
                PAData := RAContainer.PME(0, j);
                ADCount := ColCount;
                Exit;
              end;
            end;
          end;
        end;
      end;
    end;
    Result := false;
  end;
end; // end of TK_UDCDim.GetCDimRAAttrsInfo

//********************************************* TK_UDCDim.GetCDimRAAttrsInfoSafe
// returns CDim Attributes RArray
//
procedure TK_UDCDim.GetCDimRAAttrsInfoSafe( out CDimRAAttrs : TK_CDimRAAttrs; UDCDim : TN_UDBase; ItemInd : Integer );
begin
  if not GetCDimRAAttrsInfo( CDimRAAttrs, UDCDim, ItemInd ) then
      GetCDimRAAttrsInfo( CDimRAAttrs, nil, Ord(K_cdiName) )
end; // end of TK_UDCDim.GetCDimRAAttrsInfoSafe

//********************************************* TK_UDCDim.GetFullIndsArray
// returns CDim FullInds Array
//
function TK_UDCDim.GetFullIndsArray: TN_IArray;
begin
  if FFullIndsArray = nil then
    SetLength( FFullIndsArray, CDimCount );
  Result := FFullIndsArray;
end; // end of function TK_UDCDim.GetFullIndsArray

//********************************************* TK_UDCDim.GetFullCSDim
// returns CDim Full CSDim Object
//
function TK_UDCDim.GetFullCSDim: TK_UDCSDim;
begin
  Result := CreateCSDim;
end; // end of function TK_UDCDim.GetFullCSDim

//********************************************* TK_UDCDim.ReorderFullCSDim
// returns CDim Full CSDim Object
//
procedure TK_UDCDim.ReorderFullCSDim;
var
  FullCSD : TK_UDCSDim;
  WCount : Integer;
begin
  FullCSD := GetFullCSDim;
  WCount := GetCDimCount;
  if WCount = FullCSD.R.ARowCount then Exit;
  PrepFullCSDimConvContext( nil, WCount, nil, FullCSD );
  with FullCSD do begin
    K_ScanArchOwnersSubTree( ConvUDCDLinkedData );
    ClearConvDataInds;
  end;
end; // end of function TK_UDCDim.ReorderFullCSDim

//********************************************* TK_UDCDim.GetCDimCount
// returns Items Count
//
function TK_UDCDim.GetCDimCount: Integer;
begin
  Result := TK_PCDim(R.P).CDCodes.ALength;
end; // end of function TK_UDCDim.GetCDimCount

//********************************************* TK_UDCDim.SetCDimCount
// Set new CDim Count
//
procedure TK_UDCDim.SetCDimCount( NCount : Integer );
begin
  with TK_PCDim(R.P)^ do begin
    CDCodes.ASetLength( NCount );
    CDNames.ASetLength( NCount );
    CDKeys.ASetLength( NCount );
    FFullIndsArray := nil;
  end;
end; // end of function TK_UDCDim.SetCDimCount

//********************************************* TK_UDCDim.PascalInit
// Pascal R structure Initialization
//
procedure TK_UDCDim.PascalInit;
begin
  inherited;
  with TK_PCDim( R.P )^ do begin
    CDCodes := K_RCreateByTypeCode( Ord(nptString) );
    CDNames := K_RCreateByTypeCode( Ord(nptString) );
    CDKeys  := K_RCreateByTypeCode( Ord(nptString) );
  end;
end; // end of procedure TK_UDCDim.PascalInit

{
//********************************************* TK_UDCDim.GetCDimAliases
// Get CDim Aliases Block Node
//
function TK_UDCDim.GetCDimAliases: TK_UDCSDBlock;
begin
  Result := TK_UDCSDBlock( DirChildByObjName( K_dcsCDIAliasesName ) );
  if Result <> nil then Exit;
  Result := TK_UDCSDBlock.CreateAndInit( K_GetExecTypeCodeSafe('TK_SCSDBlock'),
                             K_dcsCDIAliasesName,
                             CreateCSDim, nil, K_dcsCDIAliasesAliase, Self );
  with Result.R do begin
    InsertRows;
    SetElems( TK_PCDim( R.P ).CDNames.P^, false );
  end;
end; // end of function TK_UDCDim.GetCDimAliases
}

//********************************************* TK_UDCDim.ConvAllDataLinks
// Starts Code Dimension Indexes Conversion
// This Method must work before Self CDim was realy converted
// (it use CDim.CDimCount before covertion)
// if i is new CDim Item Index then ConvInds[i] is old CDim Item Index
//
procedure TK_UDCDim.ConvAllDataLinks( PConvInds : PInteger; ConvIndsCount : Integer;
                                       RemoveUndefInds : Boolean );
var
  i : Integer;
  BConvIndex : TN_IArray;
  FullCSD : TK_UDCSDim;
  SCount : Integer;
begin
//*** Prepare Convertion Params for All Objects which use this CDim Items Indexes
  ListOfCSD := TList.Create;
  FRemoveUndefInds := RemoveUndefInds;
  SCount := CDimCount;
  i := Max(ConvIndsCount, SCount);
  SetLength( BConvIndex, i );
  K_BuildBackIndex0( PConvInds, ConvIndsCount, @BConvIndex[0], i );
  FPConvInds := @BConvIndex[0];

//*** Prepare Self Full CDim Inds convertion
  FullCSD := GetFullCSDim;
  ListOfCSD.Add( FullCSD );
  PrepFullCSDimConvContext( PConvInds, ConvIndsCount, FPConvInds, FullCSD );

//*** Scan Archive and Change All Objects which used this CDim Indexes
  K_ScanArchOwnersSubTree( ConvUDCSDim );
//  StartScanSubTree( ConvUDCSDim );

//*** Clear Indexes Temporary Info
  for i := 0 to ListOfCSD.Count - 1 do
    TK_UDCSDim( ListOfCSD[i] ).ClearConvDataInds;
  ListOfCSD.Free;
end; // end of procedure TK_UDCDim.ConvAllDataLinks

//********************************************* TK_UDCDim.ConvAllCSDims
// Starts Code Dimension Indexes Conversion
// This Method must work before Self CDim was realy converted
// (it use CDim.CDimCount before covertion)
// if i is new CDim Item Index then ConvInds[i] is old CDim Item Index
//
procedure TK_UDCDim.ConvAllCSDims( PConvInds: PInteger; ConvIndsCount: Integer;
                                   RemoveUndefInds: Boolean );
var
  i : Integer;
  BConvIndex : TN_IArray;
  FullCSD : TK_UDCSDim;
  SCount : Integer;
begin
//*** Prepare Convertion Params for All Objects which use this CDim Items Indexes
  ListOfCSD := TList.Create;
  FRemoveUndefInds := RemoveUndefInds;
  SCount := CDimCount;
  i := Max(ConvIndsCount, SCount);
  SetLength( BConvIndex, i );
  K_BuildBackIndex0( PConvInds, ConvIndsCount, @BConvIndex[0], i );
  FPConvInds := @BConvIndex[0];

//*** Prepare Self Full CDim Inds convertion
  FullCSD := GetFullCSDim;
  ListOfCSD.Add( FullCSD );
  PrepFullCSDimConvContext( PConvInds, ConvIndsCount, FPConvInds, FullCSD );

//*** Scan Archive and Change All Objects which used this CDim Indexes
  K_ScanArchOwnersSubTree( ConvUDCSDim );

//*** Clear Indexes Temporary Info
  for i := 0 to ListOfCSD.Count - 1 do
    TK_UDCSDim( ListOfCSD[i] ).ClearConvDataInds;
  ListOfCSD.Free;
end; // end of procedure TK_UDCDim.ConvAllCSDims

//********************************************* TK_UDCDim.ConvUDCSDim
// Test Node Function for ScanSubTree
//
function TK_UDCDim.ConvUDCSDim( UDParent: TN_UDBase;
  var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
  const FieldName: string ): TK_ScanTreeResult;
begin
  if UDObjIsSelfCSDim( UDChild, true ) then begin
    ListOfCSD.Add( UDChild );
  end;
  UDChild.CDimIndsConv( Self, FPConvInds, FRemoveUndefInds );
  Result := K_tucOK;
end; // end of function TK_UDCDim.ConvUDCSDim

//********************************************* TK_UDCDim.IndexByCode
// Search CDim Item by Code
//
function TK_UDCDim.IndexByCode(Code: string): Integer;
begin
  with TK_PCDim(R.P)^ do
    Result := K_IndexOfStringInRArray( Code, PString(CDCodes.P), CDimCount );
end; // end of function TK_UDCDim.IndexByCode

//********************************************* TK_UDCDim.AddItem
// Search CDim Item by Code
//
function TK_UDCDim.AddItem( Code : string; Name : string = ''; Key : string = '' ) : Integer;
begin
  with TK_PCDim(R.P)^ do begin
    Result := CDCodes.ALength;
    CDCodes.InsertElems;
    PString(CDCodes.P(Result))^ := Code;

    if Name = '' then Name := Code;
    CDNames.InsertElems;
    PString(CDNames.P(Result))^ := Name;

    CDKeys.InsertElems;
    PString(CDKeys.P(Result))^ := Key;
  end;
end; // end of function TK_UDCDim.AddItem

{
//********************************************* TK_UDCDim.GetItemsInfo
// Get CDim Items Info by Index
//
procedure TK_UDCDim.GetItemsInfo( PResult: PString;
  AInfoType: TK_CDInfoType; Index, ILength, IStep: Integer );
var
  i, h : Integer;
begin
  h := CDimCount;
  if (Index < 0) then Index := Index + h;
  if (Index < 0) or (Index >= h) then Exit;
  ILength := Index + ILength - 1;
  if ILength >= h then ILength := h - 1;
  for i := Index to ILength do begin
    PResult^ := GetItemInfoPtr( AInfoType, i )^;
    Inc( TN_BytesPtr(PResult), IStep );
  end;
end; // end of procedure TK_UDCDim.GetItemsInfo

//********************************************* TK_UDCDim.GetItemInfoPtr
// Get Items Info Ptr
//
function TK_UDCDim.GetItemInfoPtr(AInfoType: TK_CDInfoType;
  Index: Integer): PString;
var
  h : Integer;
begin
  Result := @N_NotDefStr;
  h := CDimCount;
  if (Index < 0) or (Index >= h) then Exit;
  with TK_PCDim(R.P)^ do
    case AInfoType of
    K_cdiCode:     Result := PString(CDCodes.P(Index));
    K_cdiName:     Result := PString(CDNames.P(Index));
    K_cdiEntryKey: Result := PString(CDKeys.P(Index));
    K_cdiSclonKey: Result := PString(CDNames.P(Index));
    end; // case AInfoType of
end; // end of function TK_UDCDim.GetItemInfoPtr
}

//********************************************* TK_UDCDim.GetCSDList
// Get CDim SubDimensions List
//
procedure TK_UDCDim.GetCSDList( var CSDList: TList; CSDType: TK_CDRType = K_cdrAny );
begin
  if CSDList = nil then
    CSDList := TList.Create
  else
    CSDList.Clear;
  ListOfCSD := CSDList;
  FCSDType := CSDType;
  K_ScanArchOwnersSubTree( SearchUDCSDim );
//  StartScanSubTree( SearchUDCSD );
end; // end of function TK_UDCDim.GetCSDList

//********************************************* TK_UDCDim.SearchUDCSDim
// ScanSubtre TestNode Routine - Search for Proper CSDim
//
function TK_UDCDim.SearchUDCSDim( UDParent: TN_UDBase; var UDChild: TN_UDBase;
                                  ChildInd, ChildLevel: Integer;
                                  const FieldName: string ): TK_ScanTreeResult;
begin
  with TK_UDCSDim(UDChild) do
    if UDObjIsSelfCSDim( UDChild, false ) and
     ((FCSDType = K_cdrAny) or (TK_PCSDimAttrs(R.PA).CDIType = FCSDType)) then
    ListOfCSD.Add( UDChild );
  Result := K_tucOK;
end; // end of function TK_UDCDim.SearchUDCSDim

//********************************************* TK_UDCDim.CreateCSDim
// Create CDim Inds
//
function TK_UDCDim.CreateCSDim( Name: string = ''; Count: Integer = -1;
                                 Aliase: string = ''; UDCSDimRoot : TN_UDBase = nil ): TK_UDCSDim;
var
  i, h : Integer;
//  FullCSD : Boolean;
begin
//  FullCSD := false;
  if (Name = '') and (UDCSDimRoot = nil) then begin
  //*** Search for special full DCSSpace
      i := IndexOfChildObjName( K_FFulCSDimName );
      if i <> -1 then begin
        Result := TK_UDCSDim( DirChild( i ) );
        Exit;
      end else begin
        Name :=K_FFulCSDimName;
        Aliase := K_FFulCSDimAliase;
//        FullCSD := true;
        UDCSDimRoot := self;
        Count := -1;
      end;
  end;
  if Count < 0 then
    h := CDimCount
  else
    h := Count;
//*** Create Full SubSpace
  if Aliase = '' then Aliase := Name;
  Result := TK_UDCSDim.CreateAndInit( Name, Self, h, Aliase, UDCSDimRoot );

  if Count < 0 then begin
//*** Build Full SubSpace Indexes
    RebuildFullCSD( h, Result );
    TK_PCSDimAttrs(Result.R.PA).CDIType := K_cdrSSet;
   end;

//*** Add New SubSpace to Code Space "SubSpaces"
//  if FullCSD then begin
//    AddOneChild( Result );
//    Result.ObjVFlags[0] := K_fvUseCurrent or K_fvSkipDE; // Hide Full CSS
//  end;
end; // end of function TK_UDCDim.CreateCSDim

//********************************************* TK_UDCDim.IndexOfCSDim
// Search for public CDim Inds
//
function TK_UDCDim.IndexOfCSDim( PData: Pointer; Count: Integer;
                            CSDType: TK_CDRType = K_cdrAny ): TK_UDCSDim;
var
  i : Integer;
  Leng : Integer;
begin
  if Count > 0 then begin
    Leng := Count * SizeOf(Integer);
    GetCSDList( ListOfCSD, CSDType );
    for i := 0 to ListOfCSD.Count - 1 do begin
      Result := TK_UDCSDim(ListOfCSD[i]);
      if (Count = Result.R.ALength) and // equal length
         CompareMem( Result.R.P, PData, Leng ) then
        Exit;
    end;
  end;
  Result := nil;
  ListOfCSD.Free;
end; // end of function TK_UDCDim.IndexOfCSDim

//************************************************ TK_UDCDim.ConvCDIndsType
//  Change Indices According to new Indices Type
//
function  TK_UDCDim.ConvCDIndsType( CSDimType : TK_CDRType;
                           PInds : PInteger; IndsCount : Integer;
                           NCSDimType : TK_CDRType  ) : Integer;
var
  BInds : TN_IArray;
  i, n, k : Integer;
  WSPInds : PInteger;
  WDPInds : PInteger;
begin
  Result := IndsCount;
  BInds := nil;
  if CSDimType = NCSDimType then Exit;
  BInds := FullIndsArray;
  k := CDimCount;
  if NCSDimType = K_cdrSSet then begin
  // *** Ordered Indices
  //  Old type     NewType
  //  K_cdrBag  -> K_cdrSSet
  //  K_cdrList -> K_cdrSSet
    FillChar( BInds[0], k * SizeOf(Integer), 0 );
    K_BuildBackIndex0( PInds, IndsCount, @BInds[0], k );
    Result := K_BuildActIndicesAndCompress( nil, PInds, nil, @BInds[0],
                                       k );
  end else if CSDimType = K_cdrBag then begin
  // *** Skip Duplicated Indices
  //  Old type     NewType
  //  K_cdrBag -> K_cdrList
    FillChar( BInds[0], k * SizeOf(Integer), 0 );
    Result := 0;
    WDPInds := PInds;
    WSPInds := PInds;
    for i := 0 to IndsCount - 1 do begin
      n := WSPInds^;
      Inc(WSPInds);
      if (n < 0) or (BInds[n] <> 0) then Continue;
      BInds[n] := 1;
      WDPInds^ := n;
      Inc(Result);
      Inc(WDPInds);
    end;
  end;
  // *** Nothing to DO
  //  Old type     NewType
  //  K_cdrList -> K_cdrBag
  //  K_cdrSSet -> K_cdrList
  //  K_cdrSSet -> K_cdrBag
end; // end of TK_UDCDim.ConvCDIndsType

//************************************************ TK_UDCDim.BuildCDIndToIndsRInds
//  Build IndsToInds Relation Indices (RInds) which Defined Relation between
//  Items of Data Vector Related to SrcCSDim Indices and Items of Data Vector
//  Related to DestCSDim Indices
//    SrcData[ResInds[i]] -> DestData[i]
//
procedure TK_UDCDim.BuildCDIndToIndsRInds( PRInds,
                              DestCSDInds : PInteger; DestCSDCount : Integer;
                              SrcCSDInds : PInteger; SrcCSDCount : Integer );
{
var
  FCDimInds : TN_IArray;
  i : Integer;
}
begin
  K_BuildCrossIndsByRACSDims( PRInds,
                              DestCSDInds, DestCSDCount,
                              SrcCSDInds, SrcCSDCount,
                              @FullIndsArray[0], CDimCount );
{
  FCDimInds := FullIndsArray;
  K_BuildBackIndex0( SrcCSDInds, SrcCSDCount, @FCDimInds[0], CDimCount );
  for i := 0 to DestCSDCount - 1 do begin
    if DestCSDInds^ >= 0 then
      PRInds^ := FCDimInds[DestCSDInds^]
    else
      PRInds^ := DestCSDInds^;
    Inc( DestCSDInds );
    Inc( PRInds );
  end;
}
end; //*** TK_UDCDim.BuildCDIndToIndsRInds

//********************************************* TK_UDCDim.BuildConvDataIArrays
// Build IArrays Indices for Conv, Free and Init Related Data
//
procedure TK_UDCDim.BuildConvDataIArrays( PNInds: PInteger; NCount: Integer;
                                          PInds: PInteger; Count: Integer;
                                          var ConvDataInds, FreeDataInds, InitDataInds : TN_IArray );
{
var
  MinusOne : Integer;
}
begin
  K_BuildConvDataIArraysByRACSDims( PNInds, NCount, PInds, Count,
                                    @FullIndsArray[0], CDimCount,
                                    ConvDataInds, FreeDataInds, InitDataInds );
{
  SetLength( ConvDataInds, NCount );
  SetLength( InitDataInds, NCount );
//*** Prepare Relation Indexes for changing Linked Data Blocks
  if NCount > 0 then begin
    BuildCDIndToIndsRInds( @ConvDataInds[0], PNInds, NCount,
                          PInds, Count );
//*** Build New CSDim Elements Indices which are must be Initialised in Data Blocks
    SetLength( InitDataInds, NCount - K_BuildActIndicesAndCompress(
               @InitDataInds[0], nil, nil, @ConvDataInds[0], NCount ) );
  end;
//*** Build Old CSDim Elements Indices which are not used in new Values
  SetLength( FreeDataInds, Count );
  if Count > 0 then begin
    K_FillIntArrayByCounter( @FreeDataInds[0], Count );
    if NCount > 0 then begin
      MinusOne := -1;
      K_MoveVectorByDIndex( FreeDataInds[0], SizeOf(Integer),
                        MinusOne, 0, SizeOf(Integer), NCount, @ConvDataInds[0] );
      SetLength( FreeDataInds, K_BuildActIndicesAndCompress(
          nil, nil, @FreeDataInds[0], @FreeDataInds[0], Count ) );
    end;
  end;
}
end; // end of K_BuildConvDataIArrays

{*** end of TK_UDCDim ***}


{*** TK_UDCSDim ***}
//********************************************** TK_UDCSDim.Create
//
constructor TK_UDCSDim.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDCSDimCI;
  ImgInd := 97;
end; // end of TK_UDCSDim.Create

//********************************************** TK_UDCSDim.CreateAndInit
//
constructor TK_UDCSDim.CreateAndInit( Name : string; UDCDim : TK_UDCDim; Leng : Integer = 0;
                                         Aliase : string = ''; UDCSDimRoot : TN_UDBase = nil );
begin
  Create;
  InitByRTypeCode( K_GetExecTypeCodeSafe('TK_CSDim').All, Leng );
  K_SetUDRefField( TK_PCSDimAttrs(Self.R.PA).CDim, UDCDim );
  ObjName := Name;
  if Aliase <> '' then ObjAliase := Aliase;
  if UDCSDimRoot = nil then Exit;
  with UDCSDimRoot do begin
    AddOneChild( Self );
    SetUniqChildName( Self );
  end;
end; // end of TK_UDCSDim.CreateAndInit

//********************************************** TK_UDCSDim.Destroy
//
destructor TK_UDCSDim.Destroy;
begin
//  CodesList.Free;
  inherited;
end; // end of TK_UDCSDim.Destroy

//********************************************* TK_UDCSDim.CDimIndsConv
// Self Code Dimention Items Indices Fields Conversion
// if i is old CDim Item Index then ConvInds[i] is new CDim Item Index
// if ConvInds[i] = -1 then CDim Item with Index i is now absent in CDim
//
function  TK_UDCSDim.CDimIndsConv( UDCD: TN_UDBase; PConvInds: PInteger;
                                      RemoveUndefInds: Boolean ) : Boolean;
begin
  Result := false;
  if K_GetRACSDimCDim( R ) <> UDCD then Exit;

  Result := ConvDataNeeded;
  if IndsAllReadyConved  then Exit;
//*** Convert CSDim Indexes, Prepare ConDataInds and Compress Self Indexes
  IndsAllReadyConved := true;
  ConvDataNeeded := K_RebuildRACSDim( R, UDCD, PConvInds,
    RemoveUndefInds, @OrderDataInds, @FreeDataInds ) and RemoveUndefInds;
  if not ConvDataNeeded then FreeDataInds := nil;
//  FreeAndNil( CodesList );
  SSet := nil;
  Result := true;
end; // end of procedure TK_UDCSDim.CDimIndsConv

//********************************************* TK_UDCSDim.ChangeValue
// Set New CDim Indices Value
//
procedure TK_UDCSDim.ChangeValue( PCSDInds: PInteger; Count: Integer;
                                  ChangeDataBlocks : Boolean = true );
begin
  if ChangeDataBlocks then begin
    K_GetRACSDimCDim( R ).BuildConvDataIArrays( PCSDInds, Count, R.P, R.ALength,
                                     OrderDataInds, FreeDataInds, InitDataInds );
    ConvDataNeeded := true;
//*** Scan Archive and Change All Objects which are linked to CDim Inds
    K_ScanArchOwnersSubTree( ConvUDCDLinkedData );
  end;

//*** Change Inds Value
  R.ASetLength( Count );
  Move( PCSDInds^, R.P^, SizeOf(Integer) * Count );
  ClearConvDataInds;
end; // end of procedure TK_UDCSDim.ChangeValue

//********************************************* TK_UDCSDim.ClearConvDataInds
// Clear Temporary Linked Data Convertion Info
//
procedure TK_UDCSDim.ClearConvDataInds;
begin
  OrderDataInds := nil;
  FreeDataInds := nil;
  InitDataInds := nil;
  ConvDataNeeded := false;
  IndsAllReadyConved := false;
end; // end of procedure TK_UDCSDim.ClearConvDataInds

//********************************************* TK_UDCSDim.ConvUDCDLinkedData
// Test Node Function for ScanSubTree
//
function TK_UDCSDim.ConvUDCDLinkedData( UDParent: TN_UDBase;
                      var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
                      const FieldName: string ): TK_ScanTreeResult;
begin
  UDChild.CDimLinkedDataReorder;
  Result := K_tucOK;
end; // end of function TK_UDCSDim.ConvUDCDLinkedData

//********************************************* TK_UDCSDim.GetConvDataInds
// Returns Pointer to Temporary Linked Data Convertion Info
//
function TK_UDCSDim.GetConvDataInds( out POrderInds: PInteger;
                    out OrderCount : Integer;
                    out PFreeInds : PInteger; out FreeCount : Integer;
                    out PInitInds : PInteger; out InitCount : Integer ) : Boolean;
begin
  Result := ConvDataNeeded;
  if not Result then Exit;
  OrderCount := Length(OrderDataInds);
  POrderInds := K_GetPIArray0(OrderDataInds);
  FreeCount := Length(FreeDataInds);
  PFreeInds := K_GetPIArray0(FreeDataInds);
  InitCount := Length(InitDataInds);
  PInitInds := K_GetPIArray0(InitDataInds);
end; // end of function TK_UDCSDim.GetConvDataInds

//********************************************* TK_UDCSDim.GetPSSet
// Returns Pointer to Bit SubSet Corresponding to Self CDim Indexes
//
function TK_UDCSDim.GetPSSet : Pointer;
var
  WCount : Integer;
begin
  Result := nil;
  if SSet = nil then
    WCount := K_BuildRACSDimSSet( R, SSet )
  else
    WCount := -1;
  if WCount <> 0 then Result := @SSet[0];
end; // end of function TK_UDCSDim.GetPSSet

//********************************************* TK_UDCSDim.ClearAInfo
// Clear previous Bit SubSet Value
//
procedure TK_UDCSDim.ClearAInfo;
begin
  SSet := nil;
end; // end of function TK_UDCSDim.ClearAInfo

{
//********************************************* TK_UDCSDim.IndexByCode
// Returns Self Index of CDim Item Code
//
function TK_UDCSDim.IndexByCode( Code: string ): Integer;
var
  i, h : Integer;
  WR : TK_RArray;
begin
  if CodesList = nil then begin
    CodesList := THashedStringList.Create;
    h := PDRA.AHigh;
    WR := TK_PCDim(K_GetRACSDimCDim( R ).R.P).CDCodes;
    for i := 0 to h do
      CodesList.Add( PString( WR.P( PInteger( R.P(i) )^ ) )^ );
  end;
  Result := CodesList.IndexOf(Code);
end; // end of function TK_UDCSDim.IndexByCode
}

//********************************************* TK_UDCSDim.SetConvDataInds
// Set New Temporary Linked Data Convertion Info
//
procedure TK_UDCSDim.SetConvDataInds( POrderInds : PInteger; OrderCount : Integer;
                                      PFreeInds : PInteger; FreeCount : Integer;
                                      PInitInds : PInteger; InitCount : Integer );
begin
  ConvDataNeeded := true;
  IndsAllReadyConved := true;
  SetLength( OrderDataInds, OrderCount );
  if OrderCount > 0 then
    Move( POrderInds^, OrderDataInds[0], OrderCount * SizeOf(Integer) );
  SetLength( FreeDataInds, FreeCount );
  if FreeCount > 0 then
    Move( PFreeInds^, FreeDataInds[0], FreeCount * SizeOf(Integer) );
  SetLength( InitDataInds, InitCount );
  if InitCount > 0 then
    Move( PInitInds^, InitDataInds[0], InitCount * SizeOf(Integer) );
end; // end of procedure TK_UDCSDim.SetConvDataInds
{*** end of TK_UDCSDim ***}

{*** TK_UDCDCor ***}
//********************************************** TK_UDCDCor.Create
//
constructor TK_UDCDCor.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDCDCorCI;
  ImgInd := 98;
end; // end of TK_UDCDCor.Create

//********************************************** TK_UDCDCor.CreateAndInit
//
constructor TK_UDCDCor.CreateAndInit( Name : string;
                             APrimCDim : TN_UDBase; ASecCDim : TK_UDCDim = nil;
                             Aliase : string = '';
                             UDCSDRelationsRoot : TN_UDBase = nil );
var
  N : Integer;
  BuildSelfPrimInds : Boolean;
begin
  Create;
  Self.InitByRTypeCode( K_GetExecTypeCodeSafe('TK_CDCor').All );
  with TK_PCDCorAttrs(Self.R.PA)^ do begin
    BuildSelfPrimInds := APrimCDim is TK_UDCDim;
    if ASecCDim = nil then begin
      if BuildSelfPrimInds then
        ASecCDim := TK_UDCDim(APrimCDim)
      else
        ASecCDim := K_GetRACSDimCDim( TK_UDCSDim(APrimCDim).R );
    end;
    SecCSDim := K_CreateRACSDim( ASecCDim, K_cdrBag, [K_crfCountUDRef] );
    if BuildSelfPrimInds then
      PrimCSDim := K_CreateRACSDim( TK_UDCDim(APrimCDim), K_cdrSSet, [K_crfCountUDRef] )
    else begin
      K_SetUDRefField( TN_UDBase(PrimCSDim), APrimCDim, true );
      N := TK_UDCSDim(APrimCDim).R.ALength;
      SecCSDim.ASetLength( N );
      K_FillIntArrayByCounter( SecCSDim.P, N );
    end;
  end;
  ObjName := Name;
  if Aliase <> '' then ObjAliase := Aliase;
  if UDCSDRelationsRoot = nil then Exit;
  with UDCSDRelationsRoot do begin
    AddOneChild( Self );
    SetUniqChildName( Self );
  end;
end; // end of TK_UDCDCor.CreateAndInit

//********************************************* TK_UDCDCor.CDimIndsConv
// Self Code Dimention Items Indexes Fields Conversion
// if i is old CDim Item Index then ConvInds[i] is new CDim Item Index
// if ConvInds[i] = -1 then CDim Item with Index i is now absent in CDim
//
function TK_UDCDCor.CDimIndsConv( UDCD: TN_UDBase; PConvInds: PInteger;
                                        RemoveUndefInds: Boolean ) : Boolean;
var
  CSDRA : TK_RArray;
  CSD : TObject;
  FreeDataInds, ConvDataInds : TN_IArray;
  Leng : Integer;
  PublicPrimCSD : Boolean;
  PData : Pointer;
begin
  Result := false;
  with TK_PCDCorAttrs(R.PA)^ do begin
    if CDCorID.CDRCDim = UDCD then begin
    // Convert CDCorID
      CDCorID.CDRItemInd := PInteger( TN_BytesPtr(PConvInds) + CDCorID.CDRItemInd * SizeOf(Integer) )^;
      Exit;
    end;
    CSD := PrimCSDim;
    CSDRA := SecCSDim;
  end;
//*** Convert Independent CDimInds
  PublicPrimCSD := CSD is TN_UDBase;
  if PublicPrimCSD then begin
    if TN_UDBase(CSD).CDimIndsConv( UDCD, PConvInds, RemoveUndefInds ) then
      CDimLinkedDataReorder
  end else if K_RebuildRACSDim( TK_RArray(CSD), UDCD, PConvInds, RemoveUndefInds, @ConvDataInds, @FreeDataInds ) and RemoveUndefInds then begin
  //*** Convert CSDim Indexes
    // Convert Secondary CSD CSDim Data
    with CSDRA do begin
      Leng := Length(ConvDataInds);
      PData := P;
      K_MoveVectorBySIndex( PData^, SizeOf(Integer),
                          PData^, SizeOf(Integer), SizeOf(Integer),
                          Leng, @ConvDataInds[0] );
      ASetLength(Leng);
    end;
  end;

//*** Convert Secondary CSDim Indices
  if K_RebuildRACSDim( CSDRA, UDCD, PConvInds, RemoveUndefInds, @ConvDataInds, @FreeDataInds ) and
     RemoveUndefInds and
     not PublicPrimCSD then begin
  //*** Convert Primary CSDim Data
    with TK_RArray(CSD) do begin
      Leng := Length(ConvDataInds);
      PData := P;
      K_MoveVectorBySIndex( PData^, SizeOf(Integer),
                          PData^, SizeOf(Integer), SizeOf(Integer),
                          Leng, @ConvDataInds[0] );
      ASetLength(Leng);
    end;
  end;
end; // end of TK_UDCDCor.CDimIndsConv

//********************************************* TK_UDCDCor.CDimLinkedDataReorder
// Self Linked to Code Dimention Data Reorder
//
procedure TK_UDCDCor.CDimLinkedDataReorder;
var
  CSD : TObject;
  PConvDataInds, PFreeDataInds, PInitDataInds : PInteger;
  ConvCount, FreeCount, InitCount : Integer;
  PData : Pointer;
  Buf : TN_IArray;
begin
  CSD := TK_PCDCorAttrs(R.PA).PrimCSDim;
  with TK_UDCSDim(CSD) do
    if (CSD is TN_UDBase) and
       ConvDataNeeded then begin
      GetConvDataInds( PConvDataInds, ConvCount, PFreeDataInds, FreeCount,
                       PInitDataInds, InitCount  );
      SetLength( Buf, ConvCount );
      FillChar( Buf[0], ConvCount * SizeOf(Integer), -1 );
      with TK_PCDCorAttrs(Self.R.PA).SecCSDim do begin
        PData := P;
        K_MoveVectorBySIndex( Buf[0], SizeOf(Integer),
                            PData^, SizeOf(Integer), SizeOf(Integer),
                            ConvCount, PConvDataInds );
        Move( Buf[0], PData^, ConvCount * SizeOf(Integer) );
        ASetLength(ConvCount);
      end;
    end;
end; // end of TK_UDCDCor.CDimLinkedDataReorder
{
//********************************************* TK_UDCDCor.GetPRelSSet
// Returns Pointer to Bit SubSet Corresponding to Self CDim Independent Indexes
//
function TK_UDCDCor.GetPRelSSet : Pointer;
var
  RA : TK_RArray;
  WCount : Integer;
begin
  Result := nil;
  if SSet <> nil then
    Result := @SSet[0]
  else begin
    RA := GetPrimRACSDim;
    with TK_PCDCorAttrs(R.PA)^ do
      if (RA = nil) or (PrimCSDim = RA) then begin
        WCount := K_BuildRACSDimSSet( RA, SSet );
        if WCount <> 0 then Result := @SSet[0];
      end else
        Result := TK_UDCSDim(PrimCSDim).GetPSSet;
  end;
end; // end of function TK_UDCDCor.GetPRelSSet

//********************************************* TK_UDCDCor.ClearRelSSet
// Clear previous Bit SubSet Value to Self CDim Independent Indexes
//
procedure TK_UDCDCor.ClearRelSSet;
begin
  SSet := nil;
end; // end of function TK_UDCDCor.ClearRelSSet
}
{
//********************************************* TK_UDCDCor.ChangeValue
// Set New CDim Inds Indexes Value
//
procedure TK_UDCDCor.ChangeValue( PCSDInds1, PCSDInds2: PInteger;
                                       Count: Integer );
begin

end; // end of TK_UDCDCor.ChangeValue
}
//********************************************* TK_UDCDCor.GetSecRACSDim
// Get Dependent CDim Inds RArray
//
function TK_UDCDCor.GetSecRACSDim : TK_RArray;
begin
  Result := TK_PCDCorAttrs(R.PA).SecCSDim;
end; // end of TK_UDCDCor.GetSecRACSDim

//********************************************* TK_UDCDCor.GetPrimRACSDim
// Get one of CDim Inds RArrays
//
function TK_UDCDCor.GetPrimRACSDim : TK_RArray;
begin
  Result := K_GetPVRArray( TK_PCDCorAttrs(R.PA).PrimCSDim )^;
end; // end of TK_UDCDCor.GetPrimRACSDim

//********************************************* TK_UDCDCor.GetSecCDim
// Get Dependent CDim
//
function TK_UDCDCor.GetSecCDim : TK_UDCDim;
begin
  Result := K_GetRACSDimCDim( GetSecRACSDim );
end; // end of TK_UDCDCor.GetSecCDim

//********************************************* TK_UDCDCor.GetPrimCDim
// Get one of CDim Inds RArrays
//
function TK_UDCDCor.GetPrimCDim : TK_UDCDim;
begin
  Result := K_GetRACSDimCDim(GetPrimRACSDim );
end; // end of TK_UDCDCor.GetPrimCDim

//********************************************* TK_UDCDCor.CDCorCount
// returns Items Count
//
function TK_UDCDCor.CDCorCount: Integer;
begin
  Result := GetSecRACSDim.ALength;
end; // end of function TK_UDCDCor.CDCorCount

//********************************************* TK_UDCDCor.ClearAInfo
// Clear Acceleration Info
//
procedure TK_UDCDCor.ClearAInfo;
begin
  FCorInds := nil;
end; // end of function TK_UDCDCor.ClearAInfo

//********************************************* TK_UDCDCor.GetPFCorInds
// Prepare Full Correspondece Indices Array
//
function  TK_UDCDCor.GetPFCorInds : PInteger;
begin
  if FCorInds = nil then begin
    SetLength( FCorInds, GetPrimCDim.CDimCount );
    FillChar( FCorInds[0], Length(FCorInds) * SizeOf(Integer), -1 );
    with GetSecRACSDim do
      K_MoveVectorByDIndex( FCorInds[0], SizeOf(Integer),
                          P^, SizeOf(Integer), SizeOf(Integer),
                          ALength, GetPrimRACSDim.P );
  end;
  Result := @FCorInds[0];
end; // end of function TK_UDCDCor.GetPFCorInds

{*** end of TK_UDCDCor ***}

{*** TK_UDCDRel ***}
//**************************************** TK_UDCDRel.Create
//
constructor TK_UDCDRel.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDCDRelCI;
  ImgInd := 98;
end; // end of TK_UDCDRel.Create

//**************************************** TK_UDCDRel.CreateAndInit
//
constructor TK_UDCDRel.CreateAndInit( Name: string; PUDCDim: TN_PUDBase;
                                      UDCDimCount: Integer; Aliase: string;
                                      UDCDRelsRoot: TN_UDBase);
begin
  Create;
  Self.InitByRTypeCode( K_GetExecTypeCodeSafe('TK_CDRel').All, 0 );
  K_AddUDCDimsToRACDRel( R, PUDCDim,  UDCDimCount );
  ObjName := Name;
  if Aliase <> '' then ObjAliase := Aliase;
  if UDCDRelsRoot = nil then Exit;
  with UDCDRelsRoot do begin
    AddOneChild( Self );
    SetUniqChildName( Self );
  end;
end; // end of TK_UDCDRel.CreateAndInit
{
//**************************************** TK_UDCDRel.CDimLinkedDataReorder
// Self Linked to Code Dimention Data Reorder
//
procedure TK_UDCDRel.CDimLinkedDataReorder;
begin

end; // end of TK_UDCDRel.CDimLinkedDataReorder

//**************************************** TK_UDCDRel.GetCDRelPUDCDims
//
function TK_UDCDRel.GetCDRelPUDCDims( out PUDCDims : TN_PUDBase ) : Integer;
var
  VObj : TObject;
begin
  Result := CDRelCDimsCount;
  PUDCDims := nil;
  if Result = 0 then Exit;
  VObj := TK_PCDRelAttrs(R.PA).CDims;
  if VObj is TN_UDBase then PUDCDims := @TK_PCDRelAttrs(R.PA).CDims
  else if VObj is TK_RArray then PUDCDims := TK_RArray(VObj).P;
  assert(PUDCDims <> nil, 'TK_CDRelAttrs CDims Wrong Type' );
end; // end of TK_UDCDRel.GetCDRelPUDCDims
}
//**************************************** TK_UDCDRel.CDRelCDimsCount
//
function TK_UDCDRel.CDRelCDimsCount: Integer;
begin
  Result := 0;
  if R.Alength > 0 then
    Result := R.AColCount;
end; // end of TK_UDCDRel.CDRelCDimsCount

//**************************************** TK_UDCDRel.CDRelElemsCount
//
function TK_UDCDRel.CDRelElemsCount: Integer;
begin
  Result := R.ARowCount;
end; // end of TK_UDCDRel.CDRelElemsCount
{
//**************************************** TK_UDCDRel.IndexOfCDim
//
function TK_UDCDRel.IndexOfCDim( UDCD: TN_UDBase; SInd : Integer = 0 ): Integer;
begin
  Result := K_IndexOfRACDRelCDim( R, UDCD, SInd ) : Integer;
end; // end of TK_UDCDRel.IndexOfCDim
}

//********************************************* TK_UDCDRel.CDimIndsConv
// Self Code Dimention Items Indices Fields Conversion
// if i is old CDim Item Index then ConvInds[i] is new CDim Item Index
// if ConvInds[i] = -1 then CDim Item with Index i is now absent in CDim
//
function  TK_UDCDRel.CDimIndsConv( UDCD: TN_UDBase; PConvInds: PInteger;
                                   RemoveUndefInds: Boolean ) : Boolean;
begin
  Result := ConvDataNeeded;
  if IndsAllReadyConved  then Exit;
  with R, TK_PCDRelAttrs(PA)^ do
    //*** Try To Convert
    if (CUDCSDim <> nil) and
       TN_UDBase(CUDCSDim).CDimIndsConv( UDCD, PConvInds, RemoveUndefInds ) then begin
      CDimLinkedDataReorder;
      K_RebuildRACDRel( R, UDCD, PConvInds, RemoveUndefInds, nil, nil );
      Result := true;
      Exit;
    end;

//*** Convert CSDim Indexes, Prepare ConvDataInds and Compress Self Indexes
  Result := K_RebuildRACDRel( R, UDCD, PConvInds, RemoveUndefInds,
                                      @OrderDataInds, @FreeDataInds );
  ConvDataNeeded := Result;
  IndsAllReadyConved := ConvDataNeeded;
  if not ConvDataNeeded then FreeDataInds := nil;
end; // end of procedure TK_UDCDRel.CDimIndsConv

{
//********************************************* TK_UDCDRel.ConvUDCDLinkedData
// Test Node Function for ScanSubTree
//
function TK_UDCDRel.ConvUDCDLinkedData( UDParent: TN_UDBase;
                      var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
                      FieldName: string ): TK_ScanTreeResult;
begin
  UDChild.CDimLinkedDataReorder;
  Result := K_tucOK;
end; // end of function TK_UDCDRel.ConvUDCDLinkedData
}
//********************************************* TK_UDCDRel.CDimLinkedDataReorder
// Self Linked to Code Dimention Data Reorder
//
procedure TK_UDCDRel.CDimLinkedDataReorder;
var
  POrderInds, PFreeInds, PInitInds : PInteger;
  OrderIndsCount : Integer;
  FreeIndsCount  : Integer;
  InitIndsCount  : Integer;
begin
  with R, TK_PCDRelAttrs(PA)^ do begin
    if CUDCSDim <> nil then begin
    //*** Try To Convert Rows Data
      if TK_UDCSDim(CUDCSDim).GetConvDataInds( POrderInds, OrderIndsCount,
              PFreeInds, FreeIndsCount, PInitInds, InitIndsCount ) then begin

        SetLength( OrderDataInds, OrderIndsCount );
        if OrderIndsCount > 0 then
          Move( POrderInds^, OrderDataInds[0], OrderIndsCount * SizeOf(Integer) );
        SetLength( FreeDataInds, FreeIndsCount );
        if FreeIndsCount > 0 then
          Move( PFreeInds^, FreeDataInds[0], FreeIndsCount * SizeOf(Integer) );
        SetLength( InitDataInds, InitIndsCount );
        if InitIndsCount > 0 then
          Move( PInitInds^, InitDataInds[0], InitIndsCount * SizeOf(Integer) );

        ConvDataNeeded := true;

        ReorderRows( POrderInds, OrderIndsCount,
              PFreeInds, FreeIndsCount, PInitInds, InitIndsCount );
        IndsAllReadyConved := true;
      end;
    end;
  end;
end; // end of TK_UDCDRel.CDimLinkedDataReorder

//********************************************* TK_UDCDRel.SelfLinkedDataReorder
// Linked Data Reorder
//
procedure TK_UDCDRel.SelfLinkedDataReorder( PNInds: PInteger; NCount: Integer  );
begin
  K_BuildConvFreeInitInds( R.ARowCount, PNInds, NCount, OrderDataInds,
                           FreeDataInds, InitDataInds );

  ConvDataNeeded := true;
//*** Scan Archive and Change All Objects which are linked to CDim Inds
  K_ScanArchOwnersSubTree( ConvUDCDLinkedData );
  ClearConvDataInds;
end; // end of procedure TK_UDCDRel.SelfLinkedDataReorder

{*** end fo TK_UDCDRel ***}

{*** TK_UDCSDBlock ***}
//********************************************** TK_UDCSDBlock.Create
//
constructor TK_UDCSDBlock.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDCSDBlockCI;
  ImgInd := 99;
end; // end of TK_UDCSDBlock.Create

//********************************************** TK_UDCSDBlock.CreateAndInit
//
constructor TK_UDCSDBlock.CreateAndInit( AEType : TK_ExprExtType; Name : string;
                             ColCDim : TObject = nil; RowCDim : TObject = nil;
                             Aliase : string = ''; UDCSDBRoot : TN_UDBase = nil;
                             InitRCount : Integer = 0 );
begin
  Create;
  InitByRTypeCode( AEType.All, 0 );
  K_InitRADBlockDims(R, ColCDim, RowCDim, InitRCount );
  ObjName := Name;
  if Aliase <> '' then ObjAliase := Aliase;
  if UDCSDBRoot = nil then Exit;
  with UDCSDBRoot do begin
    AddOneChild( Self );
    SetUniqChildName( Self );
  end;
end; // end of TK_UDCSDBlock.CreateAndInit

//********************************************* TK_UDCSDBlock.CDimIndsConv
// Self Code Dimention Items Indexes Fields Conversion
// if i is old CDim Item Index then ConvInds[i] is new CDim Item Index
// if ConvInds[i] = -1 then CDim Item with Index i is now absent in CDim
//
function TK_UDCSDBlock.CDimIndsConv( UDCD: TN_UDBase; PConvInds: PInteger;
                                     RemoveUndefInds: Boolean ) : Boolean;
begin
  Result := K_RADBlockCDimIndsConv( R, UDCD, PConvInds, RemoveUndefInds );
end; // end of TK_UDCSDBlock.CDimIndsConv

//********************************************* TK_UDCSDBlock.CDimLinkedDataReorder
// Self Linked to Code Dimention Data Reorder
//
procedure TK_UDCSDBlock.CDimLinkedDataReorder;
begin
  K_RADBlockCDLDataReorder( R );
end; // end of TK_UDCSDBlock.CDimLinkedDataReorder

//********************************************* TK_UDCSDBlock.BuildSortedInds
// Build Sorted CDim Inds
// DescSortOrder - Sort Order Mode - =true - Descending, =false - Ascending
// DInd - Block Sort Dimension Index - =0 - Columns Sort (Sort Row Elems)
//                                     =1 - Rows Sort    (Sort Column Elems)
// ElemInd - Element Index - DInd=0 - Row Index
//                           DInd=1 - Column Index
// PSortCSDim - Pointer to Result Indices
//
function TK_UDCSDBlock.BuildSortedInds( DescSortOrder : Boolean; DInd,
                                 ElemInd: Integer; PSortCSDim: PInteger ) : Integer;
var
  PData : Pointer;
  DCount, DStep : Integer;
//  SortFlag : Integer;
//  CompareFunc: TN_CompareFunc;
  CompareFunc: TN_CompFuncOfObj;
  ColCount, RowCount : Integer;
  PP : TN_PArray;
begin
  Result := 0;
  CompareFunc := nil;
  PP := nil;
  case R.ElemType.DTCode of
//    Ord(nptDouble) : CompareFunc := N_CompareDoubles;
    Ord(nptDouble) : CompareFunc := N_CFuncs.CompOneDouble;
//    Ord(nptInt) : CompareFunc := N_CompareIntegers;
    Ord(nptInt) : CompareFunc := N_CFuncs.CompOneInt;

  end;
  if Assigned(CompareFunc) then begin
//    if DescSortOrder then
//      SortFlag := N_SortOrder
//    else
//      SortFlag := 0;
    R.ALength( ColCount, RowCount );
    DStep := R.ElemSize;
    if DInd = 0 then begin
    //*** Sort Columns
      PData := R.PME( 0, ElemInd );
      DCount := ColCount;
    end else begin
    //*** Sort Rows
      PData := R.PME( ElemInd, 0 );
      DCount := RowCount;
      DStep := DStep * ColCount;
    end;
    Result := K_BuildVSegmentInds( PData^, DStep, DCount,
      R.ElemType.All and K_ffCompareTypesMask, K_MVMinVal, K_MVMaxVal, PSortCSDim );
    if Result > 0 then
//      PP := K_BuildPointersFromIndices( PStart, Result, DataStep, PSortCSDim )
      PP := N_ElemIndsToPtrsArray ( PData, DStep, PSortCSDim, Result )
    else begin
      Result := DCount;
      PP := N_GetPtrsArrayToElems( PData, Result, DStep );
    end;

//    K_BuildSortIndex0( PSortCSDim, PP, SortFlag, CompareFunc, PData, DStep );
    N_CFuncs.DescOrder := DescSortOrder;
    N_CFuncs.Offset := 0;
    N_SortPointers( PP, CompareFunc );
    N_PtrsArrayToElemInds( PSortCSDim, PP, PData, DStep );
  end;

end; // end of TK_UDCSDBlock.BuildSortedInds


//********************************************* TK_UDCSDBlock.BuildSortedCSDim
// Build Sorted CDim Inds
// DescSortOrder - Sort Order Mode - =true - Descending, =false - Ascending
// DInd - Block Sort Dimension Index - =0 - Columns Sort (Sort Row Elems)
//                                     =1 - Rows Sort    (Sort Column Elems)
// ElemInd - Element Index - DInd=0 - Row Index
//                           DInd=1 - Column Index
// PSortCSDim - Pointer to Result Indices
//
function TK_UDCSDBlock.BuildSortedCSDim( DescSortOrder : Boolean; DInd,
                                 ElemInd: Integer; PSortCSDim: PInteger ) : Integer;
var
  RACSDim : TK_RArray;
begin
  Result := 0;
  RACSDim := GetDRACDRel( DInd );
  if RACSDim = nil then Exit;
  Result := BuildSortedInds( DescSortOrder, DInd, ElemInd, PSortCSDim );
  with RACSDim do
    K_MoveVectorBySIndex( PSortCSDim^, SizeOf(Integer),
                        P^, SizeOf(Integer), SizeOf(Integer),
                        Result,  PSortCSDim );

end; // end of TK_UDCSDBlock.BuildSortedCSDim

//********************************************* TK_UDCSDBlock.ChangeCDRelIRef
// Self Code Dimention Items Change
// returns previous Item Index Value, if Add new ACDim then returns -1
//
function TK_UDCSDBlock.ChangeCDRelIRef( ACDim: TK_UDCDim;
                                     AItemInd: Integer;
                                     CDimsDuplicate : Boolean = false ): Integer;
var
  i : Integer;
  WCBRel : TK_RArray;
  PItemInd : PInteger;
begin
  WCBRel := GetCBRACDRelSafe;
  with WCBRel do begin
//*** Convert CDim Items Refs
    if not CDimsDuplicate then begin
      i := K_IndexOfRACDRelCDim( WCBRel, ACDim );
      if i <> -1 then begin
        PItemInd := P(i);
        Result := PItemInd^;
        PItemInd^ := AItemInd;
        Exit;
      end;
    end;
    K_AddUDCDimsToRACDRel( WCBRel, TN_PUDBase(@ACDim), 1 );

    Result := ALength;
    ASetLength( Result + 1 );
    PInteger(P(Result))^ := AItemInd;
  end;
end; // end of TK_UDCSDBlock.ChangeCDRelIRef
{
//********************************************* TK_UDCSDBlock.SetCDRelFromIRefs
// Set Block CDim Items References
//
procedure TK_UDCSDBlock.SetCDRelFromIRefs( PCDIRefs: TK_PCDIRef; CDIRefsCount: Integer );
var
  i : Integer;
begin
  with GetRACDIRefSafe do begin
    ASetLength( 0 );
    ASetLength( CDIRefsCount );
    for i := 0 to CDIRefsCount - 1 do begin
      with TK_PCDIRef(P(i))^ do begin
        K_SetUDRefField( CDRCDim, PCDIRefs.CDRCDim );
        CDRItemInd := PCDIRefs.CDRItemInd;
      end;
      Inc( PCDIRefs );
    end;
  end;
end; // end of TK_UDCSDBlock.SetCDRelFromIRefs

//********************************************* TK_UDCSDBlock.SetCDRelFromIRefs
// Set Block CDim Items References
//
procedure TK_UDCSDBlock.SetCDRelFromIRefs( PCDIRefs: TK_PCDIRef; CDIRefsCount: Integer );
var
  CCDR : TK_RArray;
begin
  CCDR := GetCBRACDRelSafe;
  with CCDR do begin
    ASetLength( 0, 0 );
    K_AddUDCDimsToRACDRel( CBRel, @PCDIRefs.CDRCDim, CDIRefsCount, SizeOf(TK_CDIRef) );
    ASetLength( AColCount, CDIRefsCount );
    K_MoveVector( PME(0, 0)^, SizeOf(Integer), PCDIRefs.CDRItemInd, SizeOf(TK_CDIRef),
                                  SizeOf(Integer), CDIRefsCount );
  end;
end; // end of TK_UDCSDBlock.SetCDRelFromIRefs

//********************************************* TK_UDCSDBlock.GetCDRelToIRefs
// Set Block CDim Items References
//
procedure TK_UDCSDBlock.GetCDRelToIRefs( PCDIRefs: TK_PCDIRef );
var
  CCDR : TK_RArray;
  CDIRefsCount: Integer;
  PUDCDims : TN_PUDBase;
begin
  CCDR := GetCBRACDRel;
  if CCDR = nil then Exit;
  CDIRefsCount := K_GetRACDRelPUDCDims( CCDR, PUDCDims );
  K_MoveVector( PCDIRefs.CDRCDim, SizeOf(TK_CDIRef), PUDCDims^, SizeOf(Integer),
                                SizeOf(Integer), CDIRefsCount );
  with CCDR do
    K_MoveVector( PCDIRefs.CDRItemInd, SizeOf(TK_CDIRef), PME(0, 0)^, SizeOf(Integer),
                                  SizeOf(Integer), CDIRefsCount );
end; // end of TK_UDCSDBlock.GetCDRelToIRefs
}

//********************************************* TK_UDCSDBlock.ClearDPSSet
// Get Column CDim Inds RArray
//  DInd - Block Dimension Index - =0 - Columns Dimension Set
//                                 =1 - Rows Dimension Set
//
procedure TK_UDCSDBlock.ClearDPSSet(DInd: Integer);
begin
  SSet[DInd] := nil;
end; // end of TK_UDCSDBlock.ClearDPSSet

//********************************************* TK_UDCSDBlock.GetDPSSet
// Get Column CDim Inds RArray
//  DInd - Block Dimension Index - =0 - Columns Dimension Set
//                                 =1 - Rows Dimension Set
//
function TK_UDCSDBlock.GetDPSSet( DInd: Integer ): Pointer;
var
  RA : TK_RArray;
  WCount : Integer;
  CSD : TObject;
begin
//  Result := nil;
  if SSet[DInd] <> nil then
    Result := @SSet[DInd][0]
  else begin
    RA := GetDRACDRel(DInd);
    with TK_PCSDBAttrs(R.PA)^ do begin
      if DInd = 0 then
        CSD := ColsRel
      else
        CSD := RowsRel;

      if (RA = nil) or (CSD = RA) then begin
        WCount := K_BuildRACSDimSSet( RA, SSet[DInd] );
        if WCount <> 0 then
          Result := @SSet[DInd][0]
        else
          Result := nil;
      end else
        Result := TK_UDCSDim(CSD).GetPSSet;
    end;
  end;
end; // end of TK_UDCSDBlock.GetDPSSet

//********************************************* TK_UDCSDBlock.GetDRACDRel
// Get CDim Inds RArray
//  DInd - Block Dimension Index - =0 - Columns Dimension RArray
//                                 =1 - Rows Dimension RArray
//
function TK_UDCSDBlock.GetDRACDRel( DInd: Integer ): TK_RArray;
begin
  if DInd = 0 then
    Result := GetColRACDRel
  else
    Result := GetRowRACDRel;
end; // end of TK_UDCSDBlock.GetDRACDRel

//********************************************* TK_UDCSDBlock.GetColRACDRel
// Get Column CDim Inds RArray
//
function TK_UDCSDBlock.GetColRACDRel: TK_RArray;
begin
  Result := K_GetPVRArray( TK_PCSDBAttrs(R.PA).ColsRel )^;
end; // end of TK_UDCSDBlock.GetColRACDRel

//********************************************* TK_UDCSDBlock.GetDataPointer
// Get Pointer to Data Block Element
//
function TK_UDCSDBlock.GetDataPointer(ICol, IRow: Integer): Pointer;
begin
  Result := R.PME( ICol, IRow );
end; // end of TK_UDCSDBlock.GetDataPointer

//********************************************* TK_UDCSDBlock.GetDataType
// Data Block Element Type Code
//
function TK_UDCSDBlock.GetDataType: TK_ExprExtType;
begin
  Result := R.GetComplexType;
end; // end of TK_UDCSDBlock.GetDataType


//********************************************* TK_UDCSDBlock.GetCBRACDRel
// Get Block CDim Items References RArray
//
function TK_UDCSDBlock.GetCBRACDRel: TK_RArray;
begin
  Result := TK_PCSDBAttrs(R.PA).CBRel;
end; // end of TK_UDCSDBlock.GetCBRACDRel

//********************************************* TK_UDCSDBlock.GetCBRACDRelSafe
// Get Block CDim Items References RArray - Create if Needed
//
function TK_UDCSDBlock.GetCBRACDRelSafe: TK_RArray;
begin
  Result := K_GetRADBlockRACBRelSafe( R );
end; // end of TK_UDCSDBlock.GetCBRACDRelSafe

{
//********************************************* TK_UDCSDBlock.GetRACDIRef
// Get Block CDim Items References RArray
//
function TK_UDCSDBlock.GetRACDIRef: TK_RArray;
begin
  Result := TK_PCSDBAttrs(R.PA).BCDR;
end; // end of TK_UDCSDBlock.GetRACDIRef

//********************************************* TK_UDCSDBlock.GetRACDIRefSafe
// Get Block CDim Items References RArray - Create if Needed
//
function TK_UDCSDBlock.GetRACDIRefSafe: TK_RArray;
begin
  with TK_PCSDBAttrs(R.PA)^ do begin
    if BCDR = nil then
      BCDR := K_RCreateByTypeName( 'TK_CDIRef', 0, [K_crfCountUDRef] );
    Result := BCDR;
  end;
end; // end of TK_UDCSDBlock.GetRACDIRef
}

//********************************************* TK_UDCSDBlock.GetRowRACDRel
// Get Row CDim Inds RArray
//
function TK_UDCSDBlock.GetRowRACDRel: TK_RArray;
begin
  Result := K_GetPVRArray( TK_PCSDBAttrs(R.PA).RowsRel )^;
end; // end of TK_UDCSDBlock.GetRowRACDRel

{
//********************************************* TK_UDCSDBlock.GetRowPSSet
// Returns Pointer to Bit SubSet Corresponding to Self CDim Row Indexes
//
function TK_UDCSDBlock.GetRowPSSet : Pointer;
var
  RA : TK_RArray;
  WCount : Integer;
begin
  Result := nil;
  if RSSet <> nil then
    Result := @RSSet[0]
  else begin
    RA := GetRowRACDRel;
    with TK_PCSDBAttrs(R.PA)^ do
      if (RA = nil) or (RowsRel = RA) then begin
        WCount := K_BuildRACSDimSSet( RA, RSSet );
        if WCount <> 0 then
          Result := @RSSet[0]
        else
          Result := nil;
      end else
        Result := TK_UDCSDim(RowsRel).GetPSSet;
  end;
end; // end of function TK_UDCSDBlock.GetRowPSSet

//********************************************* TK_UDCSDBlock.ClearRowPSSet
// Clear previous Bit SubSet Value to Self CDim Row Indexes
//
procedure TK_UDCSDBlock.ClearRowPSSet;
begin
  RSSet := nil;
end; // end of function TK_UDCSDBlock.ClearRowPSSet

//********************************************* TK_UDCSDBlock.GetColPSSet
// Returns Pointer to Bit SubSet Corresponding to Self CDim Row Indexes
//
function TK_UDCSDBlock.GetColPSSet : Pointer;
var
  RA : TK_RArray;
  WCount : Integer;
begin
  Result := nil;
  if CSSet <> nil then
    Result := @CSSet[0]
  else begin
    RA := GetColRACDRel;
    with TK_PCSDBAttrs(R.PA)^ do
      if (RA = nil) or (ColsRel = RA) then begin
        WCount := K_BuildRACSDimSSet( RA, CSSet );
        if WCount <> 0 then
          Result := @CSSet[0]
        else
          Result := nil;
      end else
        Result := TK_UDCSDim(ColsRel).GetPSSet;
  end;
end; // end of function TK_UDCSDBlock.GetColPSSet

//********************************************* TK_UDCSDBlock.ClearColPSSet
// Clear previous Bit SubSet Value to Self CDim Row Indexes
//
procedure TK_UDCSDBlock.ClearColPSSet;
begin
  CSSet := nil;
end; // end of function TK_UDCSDBlock.ClearColPSSet
}
//********************************************* TK_UDCSDBlock.LinkDBlockToCSDim
// Clear previous Bit SubSet Value to Self CDim Row Indexes
//
procedure TK_UDCSDBlock.LinkDBlockToCSDim( ColInds, RowInds: TK_UDCSDim );
begin

end; // end of function TK_UDCSDBlock.LinkDBlockToCSDim
{*** end of  TK_UDCSDBlock ***}

{*** TK_UDERDBlock ***}
//********************************************** TK_UDERDBlock.Create
//
constructor TK_UDERDBlock.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDERDBlockCI;
  ImgInd := 40;
end; // end of TK_UDERDBlock.Create

{*** end of  TK_UDERDBlock ***}

{*** TK_UDCSDimTypeFilterItem ***}
//********************************************* TK_UDCSDimTypeFilterItem.Create
//
constructor TK_UDCSDimTypeFilterItem.Create( ACDIType : TK_CDRType;
                            AExprCode: TK_UDFilterItemExprCode  = K_ifcOr );
begin
  inherited Create;
  CDIType := ACDIType;
  ExprCode := AExprCode;
end; // end of TK_UDCSDimTypeFilterItem.Create

//********************************************* TK_UDCSDimTypeFilterItem.UDFITest
//
function TK_UDCSDimTypeFilterItem.UDFITest(const DE: TN_DirEntryPar): Boolean;
begin
  Result := (DE.Child <> nil)         and
            (DE.Child is TK_UDCSDim)  and
            ( (CDIType = K_cdrAny) or
              (TK_PCSDimAttrs(TK_UDCSDim(DE.Child).R.PA).CDIType = CDIType) );
end; // end of TK_UDCSDimTypeFilterItem.UDFITest
{*** end of TK_UDCSDimTypeFilterItem ***}

{*** TK_UDCDRelTypeFilterItem ***}
//********************************************* TK_UDCDRelTypeFilterItem.Create
//
constructor TK_UDCDRelTypeFilterItem.Create( ACDIType : TK_CDRType;
                            AExprCode: TK_UDFilterItemExprCode  = K_ifcOr );
begin
  inherited Create;
  CDIType := ACDIType;
  ExprCode := AExprCode;
end; // end of TK_UDCDRelTypeFilterItem.Create

//********************************************* TK_UDCDRelTypeFilterItem.UDFITest
//
function TK_UDCDRelTypeFilterItem.UDFITest(const DE: TN_DirEntryPar): Boolean;
begin
  Result := (DE.Child <> nil)         and
            (DE.Child is TK_UDCDRel)  and
            ( (CDIType = K_cdrAny) or
              (TK_PCDRelAttrs(TK_UDCDRel(DE.Child).R.PA).CDRType = CDIType) );
end; // end of TK_UDCDRelTypeFilterItem.UDFITest
{*** end of TK_UDCDRelTypeFilterItem ***}

{*** TK_RAFCDItemEditor0 ***}
//********************************************* TK_RAFCDItemEditor0.GetItemString
//
function TK_RAFCDItemEditor0.GetItemString( Ind : Integer ) : string;
begin
  if PSEInds <> nil then
    Ind := PInteger(TN_BytesPtr(PSEInds) + Ind * SizeOf(Integer))^;
 if (Ind >= 0) and (PCDimNames <> nil) then
   Result := PString(TN_BytesPtr(PCDimNames) + Ind * SizeOf(string))^
 else
   Result := '';
end; // end of TK_RAFCDItemEditor0.GetItemString

//********************************************* TK_RAFCDItemEditor0.PrepareCmBList
//
procedure TK_RAFCDItemEditor0.PrepareCmBList;
var
  i, h : Integer;
begin
  if CmB.Items.Count <> 0 then Exit;
  h := CDimNamesCount - 1;
  if PSEInds <> nil then
    h := SEIndsCount - 1;
  for i := 0 to h do
    CmB.Items.Add( GetItemString(i) );
end; // end of TK_RAFCDItemEditor0.PrepareCmBList

//********************************************* TK_RAFCDItemEditor0.SetUDCDimInfo
//
procedure TK_RAFCDItemEditor0.SetUDCDimInfo(UDCDim: TK_UDCDim);
var
  PS : Pointer;
begin
  if UDCDim <> nil then
    with TK_PCDim(UDCDim.R.P)^ do begin
      PS := CDNames.P;
      if PCDimNames <> PS then begin
        PCDimNames := PS;
        CDimNamesCount := CDNames.ALength;
        if CmB <> nil then CmB.Items.Clear;
      end;
    end;
end; // end of TK_RAFCDItemEditor0.SetUDCDimInfo

//********************************************* TK_RAFCDItemEditor0.CanUseEditor
//
function TK_RAFCDItemEditor0.CanUseEditor( ACol, ARow: Integer;
                                       var RAFC: TK_RAFColumn ): Boolean;
//var
//  Ind, i, h : Integer;
begin
  Result := inherited CanUseEditor( ACol, ARow, RAFC );
  DataSize := 4;
  DropListDown := true;
  if not Result then Exit;
  PrepareCmBList;
end; // end of TK_RAFCDItemEditor0.CanUseEditor

//********************************************* TK_RAFCDItemEditor0.GetText
//
function TK_RAFCDItemEditor0.GetText(var Data; var RAFC: TK_RAFColumn;
                            ACol, ARow: Integer; PHTextPos: Pointer): string;
begin
  Result := '';
  if not CanUseEditor( ACol, ARow, RAFC ) then Exit;
  if (Integer(Data) >= 0) and (Integer(Data) < CmB.Items.Count) then
  Result := CmB.Items[Integer(Data)];
end; // end of TK_RAFCDItemEditor0.GetText

//**************************************** TK_RAFCDItemEditor0.OnChangeH
//  OnChange Handler
//
procedure TK_RAFCDItemEditor0.OnChangeH(Sender: TObject);
begin
  OnItemIndexChange;
end; // end of TK_RAFCDItemEditor0.OnChangeH
{*** end of TK_RAFCDItemEditor0 ***}

{*** TK_RAFCDItemEditor ***}
//********************************************* TK_RAFCDItemEditor.InitCDimNames
//
procedure TK_RAFCDItemEditor.InitCDimNames( var RAFC: TK_RAFColumn; LRow: Integer );
var
  CInd : Integer;
begin
  if LRow < 0 then Exit;
  with RAFrame, RAFC do begin
    if CDimColInd = 0 then begin
      CInd := IndexOfColumn(VEArray[CVEInd].EParams);
      CDimColInd := CInd + 1;
    end else
      CInd := CDimColInd - 1;
    if CInd = -1 then Exit;
    SetUDCDimInfo( TK_UDCDim(TN_PUDBase(DataPointers[LRow][CInd])^) );
  end;
end; // end of TK_RAFCDItemEditor.InitCDimNames

//********************************************* TK_RAFCDItemEditor.CanUseEditor
//
function TK_RAFCDItemEditor.CanUseEditor( ACol, ARow: Integer;
                                       var RAFC: TK_RAFColumn ): Boolean;
//var
//  i, h : Integer;
begin
  Result := inherited CanUseEditor( ACol, ARow, RAFC );
  DataSize := 4;
  DropListDown := true;
  if not Result then Exit;
  InitCDimNames( RAFC, ARow );
  PrepareCmBList;
end; // end of TK_RAFCDItemEditor.CanUseEditor

//********************************************* TK_RAFCDItemEditor.GetText
//
function TK_RAFCDItemEditor.GetText(var Data; var RAFC: TK_RAFColumn;
                            ACol, ARow: Integer; PHTextPos: Pointer): string;
begin
  InitCDimNames( RAFC, RAFrame.ToLogicPos( ACol, ARow ).Row );
  Result := GetItemString( Integer(Data) );
end; // end of TK_RAFCDItemEditor.GetText

{*** end of TK_RAFCDItemEditor ***}

{*** TK_QueryBlockData0 ***}
//**************************************** TK_QueryBlockData0.Create
//
constructor TK_QueryBlockData0.Create;
var
  SL : TStringList;
begin
  inherited;
  SrcUDRoots := TList.Create;
  SrcUDCSDBlocks := TList.Create;
  ResultUDBlocks := TList.Create;
  ResColCDimInd := -1;
  ResRowCDimInd := -1;
  OnQueryRACSDBlockData := AddUDCSDBlockData;
  OnGetNewResultBlockName := GetNewResultBlockObjName;
  InitResultFunc := K_InitRADBlockData;
  SrcUDRoots.Add( K_CurArchive );
  SL := TStringList.Create;
  K_BuildDBlockTypesList( SL );
  QDataType.All := Integer(SL.Objects[0]);
  SL.Free;
end; // end of TK_QueryBlockData0.Create

//**************************************** TK_QueryBlockData0.Destroy
//
destructor TK_QueryBlockData0.Destroy;
begin
  Clear;
  SrcUDRoots.Free;
  SrcUDCSDBlocks.Free;
  ResultUDBlocks.Free;
  ResultRABlocksMatrix.Free;
  inherited;
end; // end of TK_QueryBlockData0.Destroy

//**************************************** TK_QueryBlockData0.AddUDRoot
//
procedure TK_QueryBlockData0.AddUDRoot( UDRoot : TN_UDBase );
begin
  if (UDRoot <> nil) and (SrcUDRoots.IndexOf( UDRoot ) = -1) then
    SrcUDRoots.Add( UDRoot );
end; // end of TK_QueryBlockData0.AddUDRoot

//**************************************** TK_QueryBlockData0.AddQueryCSDim
//  Add New CDim Elems to Query
//  CDObject - TK_UDCDim                 - All Code Dimension Elements
//             TK_UDCSDim               - UD Code Dimension Elements Indices
//             TK_RArray (SPL TK_CSDim) - RA Code Dimension Elements Indices
//  Included - if true then Include Code Dimension Elements to Query else Exclude CDim Elems
//
procedure TK_QueryBlockData0.AddQueryCSDim( CDObject: TObject;
                            Included : Boolean = true );
var
//  ICount, NInd  : Integer;
  AddCSDimMode : Integer;
  RACDim : TK_RArray;
//  FInds : TN_IArray;
//  SkipClearSet : Boolean;
//  CDIType : TK_CDRType;
  PInds : PInteger;
  IndsCount : Integer;
{
  procedure SetRAInds; // Set QCDim By New RA CSDim
  begin
    QCDim.QCDCount := TK_UDCDim(QCDim.QCDAttrs.CDim).SelfCount;
//    QCDim.QCDAttrs.CDIType := TK_PCSDimAttrs(RACDim.PA).CDIType;
    ICount := RACDim.Alength;
    SetLength( QCDim.QInds, ICount );
    Move( RACDim.P^, QCDim.QInds[0], ICount * SizeOf(Integer) );
    if CaseState = 2 then begin
      with TK_UDCSDim(CDObject) do begin
        GetPSSet;
        QCDim.QCSDet := Copy( SSet, 0, Length(SSet) );
      end;
      SkipClearSet := true;
    end;
  end;

  procedure SetBuildInds; // Set QCDim By Build CSDim
  begin
    QCDim.QCDCount := TK_UDCDim(QCDim.QCDAttrs.CDim).SelfCount;
    ICount := K_BuildActIndicesAndCompress( nil, nil, @FInds[0],
                                            @FInds[0], QCDim.QCDCount );
    QCDim.QCDAttrs.CDIType := K_cdrSSet;
    SetLength( QCDim.QInds, ICount );
    Move( FInds[0], QCDim.QInds[0], ICount * SizeOf(Integer) );
  end;

  procedure BuildFullCurInds; // Build Full Inds By Existed CSDim
  begin
    SetLength( FInds, QCDim.QCDCount );
    K_BuildFullIndex( @QCDim.QInds[0], Length(QCDim.QInds),
                      @FInds[0], QCDim.QCDCount, false );
  end;
}
begin
//  RACDim := nil;
//  SkipClearSet := false;
  if CDObject = nil then Exit;
  FillChar( QCDim, SizeOf(TK_QCDim0), 0 );
  PInds := nil;
  IndsCount := 0;
  if CDObject is TK_UDCDim then begin
    AddCSDimMode := 0;
    QCDim.QCDAttrs.CDim := TK_UDCDim(CDObject);
  end else begin
    AddCSDimMode := 1;
    RACDim := K_GetPVRArray( CDObject )^;
    if RACDim <> CDObject then begin
      AddCSDimMode := 2;
      QCDim.QUDCSDim := TK_UDCSDim(CDObject);
    end;
    QCDim.QCDAttrs := TK_PCSDimAttrs(RACDim.PA)^;
    PInds := RACDim.P;
    IndsCount := RACDim.ALength;
  end;
  AddQueryCSDim0( AddCSDimMode, Included, PInds, IndsCount );
{
  NInd := TK_UDCDim(QCDim.QCDAttrs.CDim).Marker - 1;
  if NInd >= 0 then begin
  //*** Rebuild Existed QCDim
    if CaseState > 0 then begin
      QCDim := QCDims[NInd];
      if Included then begin
      //*** Add New Indices to Existed
        if QCDim.QCDCount = -1 then Exit            // All CDIm Inds are already Included
        else if QCDim.QCDCount = 0 then  SetRAInds  // No CDIm Inds are Included
        else begin                                 // Add New Inds to Existing Inds
          BuildFullCurInds;
          K_BuildFullIndex( RACDim.P, RACDim.ALength,
                            @FInds[0], QCDim.QCDCount, false );
          SetBuildInds;
        end;
      end else begin
      //*** Clear New Indices From Existed
        if QCDim.QCDCount = 0 then Exit         // No CDIm Inds are Included
        else if QCDim.QCDCount = -1 then  begin // All CDIm Inds are already Included
          SetLength( FInds, QCDim.QCDCount );
          K_FillIntArrayByCounter( @FInds[0], QCDim.QCDCount );
        end else                               // Clear New Inds from Existing Inds
          BuildFullCurInds;
        ICount := -1;
        K_MoveVectorByDIndex( FInds[0], SizeOf(Integer),
                      ICount, 0, SizeOf(Integer), RACDim.ALength, RACDim.P );
        SetBuildInds;
      end;
    end;
  end else begin
    if Included then begin
  //*** Add New QCDim
      if CaseState > 0 then  SetRAInds; // CDim Inds
    end else if CaseState > 0 then begin // CDim Inds - Build Inices of Elems which are not Included in New Indices
      SetLength( FInds, QCDim.QCDCount );
      K_FillIntArrayByCounter( @FInds[0], QCDim.QCDCount );
      ICount := -1;
      K_MoveVectorByDIndex( FInds[0], SizeOf(Integer),
                    ICount, 0, SizeOf(Integer), RACDim.ALength, RACDim.P );
      SetBuildInds;
    end;

    NInd := Length(QCDims); // Add New QCDim
    SetLength( QCDims, NInd + 1 );
  end;

  if CaseState = 0 then begin
  // All CDim Elems
    if Included then
      QCDim.QCDCount := -1
    else
      QCDim.QCDCount := 0;
  end;
  if not SkipClearSet then QCDim.QCDSet := nil;
  TK_UDCDim(QCDim.QCDAttrs.CDim).Marker := NInd + 1; // mark UDCDim by Query CDInd
  QCDims[NInd] := QCDim;
}
end; // end of TK_QueryBlockData0.AddQueryCSDim

//**************************************** TK_QueryBlockData0.AddQueryCDIRef
//  Add New CDim Elem Reference to Query
//  ACDIRef - TK_CDIRef - Code Dimension Element Reference
//  Included - if true then Include Code Dimension Elements to Query else Exclude CDim Elems
//
procedure TK_QueryBlockData0.AddQueryCDIRef( ACDIRef: TK_CDIRef; Included: Boolean );
begin
  if (ACDIRef.CDRCDim = nil) or (ACDIRef.CDRItemInd = -1) then Exit;
  FillChar( QCDim, SizeOf(TK_QCDim0), 0 );
  QCDim.QCDAttrs.CDim := ACDIRef.CDRCDim;
  AddQueryCSDim0( 1, Included, @ACDIRef.CDRItemInd, 1 );
end; // end of TK_QueryBlockData0.AddQueryCDIRef

//**************************************** TK_QueryBlockData0.SetResBlocksCDims
//  Set Result Blocks Columns and Rows Dimentions
//
procedure TK_QueryBlockData0.SetResBlocksCDims( UDColsCDim, UDRowsCDim : TN_UDBase );
begin
  if UDColsCDim <> nil then
    ResColCDimInd := UDColsCDim.Marker - 1
  else
    ResColCDimInd := -1;
  if UDRowsCDim <> nil then
    ResRowCDimInd := UDRowsCDim.Marker - 1
  else
    ResRowCDimInd := -1;
end; // end of TK_QueryBlockData0.SetResBlocksCDims

//**************************************** TK_QueryBlockData0.AddResBlocksMatrixCDims
//  Add new Level in Result Blocks Marices - Columns and Rows Dimentions
//
procedure TK_QueryBlockData0.AddResBlocksMatrixCDims( UDColsCDim, UDRowsCDim : TN_UDBase );
var
  Count : Integer;

begin
  Count := Length(ResColCDimsInds);
  SetLength( ResColCDimsInds, Count + 1 );
  SetLength( ResRowCDimsInds, Count + 1 );
  if UDColsCDim <> nil then
    ResColCDimsInds[Count] := UDColsCDim.Marker - 1
  else
    ResColCDimsInds[Count] := -1;
  if UDRowsCDim <> nil then
    ResRowCDimsInds[Count] := UDRowsCDim.Marker - 1
  else
    ResRowCDimsInds[Count] := -1;
end; // end of TK_QueryBlockData0.AddResBlocksMatrixCDims

//**************************************** TK_QueryBlockData0.AddQueryCSDim
//  Add New CDim Elems to Query
//  CDObject - TK_UDCDim                 - All Code Dimension Elements
//             TK_UDCSDim               - UD Code Dimension Elements Indices
//             TK_RArray (SPL TK_CSDim) - RA Code Dimension Elements Indices
//  Included - if true then Include Code Dimension Elements to Query else Exclude CDim Elems
//
procedure TK_QueryBlockData0.AddQueryCSDim0( IndsTypeFlag : Integer; Included : Boolean;
                                             PInds : PInteger; IndsCount : Integer );
var
  ICount, NInd  : Integer;
  FInds : TN_IArray;
  SkipClearSet : Boolean;

  procedure SetRAInds; // Set QCDim By New RA CSDim
  begin
    QCDim.QCDCount := TK_UDCDim(QCDim.QCDAttrs.CDim).CDimCount;
    SetLength( QCDim.QInds, IndsCount );
    Move( PInds^, QCDim.QInds[0], IndsCount * SizeOf(Integer) );
    if IndsTypeFlag = 2 then begin
      with QCDim.QUDCSDim do begin
        GetPSSet;
        QCDim.QCDSet := Copy( SSet, 0, Length(SSet) );
      end;
      SkipClearSet := true;
    end;
  end;

  procedure SetBuildInds; // Set QCDim By Build CSDim
  begin
    QCDim.QCDCount := TK_UDCDim(QCDim.QCDAttrs.CDim).CDimCount;
    ICount := K_BuildActIndicesAndCompress( nil, nil, @FInds[0],
                                            @FInds[0], QCDim.QCDCount );
    QCDim.QCDAttrs.CDIType := K_cdrSSet;
    SetLength( QCDim.QInds, ICount );
    Move( FInds[0], QCDim.QInds[0], ICount * SizeOf(Integer) );
  end;

  procedure BuildFullCurInds; // Build Full Inds By Existed CSDim
  begin
    SetLength( FInds, QCDim.QCDCount );
    K_BuildFullIndex( @QCDim.QInds[0], Length(QCDim.QInds),
                      @FInds[0], QCDim.QCDCount, K_BuildFullActualIndexes );
  end;

begin
  SkipClearSet := false;
  NInd := TK_UDCDim(QCDim.QCDAttrs.CDim).Marker - 1;
  if NInd >= 0 then begin
  //*** Rebuild Existed QCDim
    if IndsTypeFlag > 0 then begin
      QCDim := QCDims[NInd];
      if Included then begin
      //*** Add New Indices to Existed
        if QCDim.QCDCount = -1 then Exit            // All CDIm Inds are already Included
        else if QCDim.QCDCount = 0 then  SetRAInds  // No CDIm Inds are Included
        else begin                                  // Add New Inds to Existing Inds
          BuildFullCurInds;
          K_BuildFullIndex( PInds, IndsCount,
                            @FInds[0], QCDim.QCDCount, K_BuildFullActualIndexes );
          SetBuildInds;
        end;
      end else begin
      //*** Clear New Indices From Existed
        if QCDim.QCDCount = 0 then Exit         // No CDIm Inds are Included
        else if QCDim.QCDCount = -1 then  begin // All CDIm Inds are already Included
          SetLength( FInds, QCDim.QCDCount );
          K_FillIntArrayByCounter( @FInds[0], QCDim.QCDCount );
        end else                               // Clear New Inds from Existing Inds
          BuildFullCurInds;
        ICount := -1;
        K_MoveVectorByDIndex( FInds[0], SizeOf(Integer),
                      ICount, 0, SizeOf(Integer), IndsCount, PInds );
        SetBuildInds;
      end;
    end;
  end else begin
    if Included then begin
  //*** Add New QCDim
      if IndsTypeFlag > 0 then  SetRAInds; // CDim Inds
    end else if IndsTypeFlag > 0 then begin // CDim Inds - Build Inices of Elems which are not Included in New Indices
      SetLength( FInds, QCDim.QCDCount );
      K_FillIntArrayByCounter( @FInds[0], QCDim.QCDCount );
      ICount := -1;
      K_MoveVectorByDIndex( FInds[0], SizeOf(Integer),
                    ICount, 0, SizeOf(Integer), IndsCount, PInds );
      SetBuildInds;
    end;

    NInd := Length(QCDims); // Add New QCDim
    SetLength( QCDims, NInd + 1 );
  end;

  if IndsTypeFlag = 0 then begin
  // All CDim Elems
    if Included then
      QCDim.QCDCount := -1
    else
      QCDim.QCDCount := 0;
  end;
  if not SkipClearSet then QCDim.QCDSet := nil;
  TK_UDCDim(QCDim.QCDAttrs.CDim).Marker := NInd + 1; // mark UDCDim by Query CDInd
  QCDims[NInd] := QCDim;

end; // end of TK_QueryBlockData0.AddQueryCSDim

//**************************************** TK_QueryBlockData0.GetResCSDBlockInds
//  Find Index of CDim In Query
//
function TK_QueryBlockData0.GetResCSDBlockInds( PCDIRefs : TK_PCDIRef; Count : Integer = 1 ): TN_IArray;
var
  n, i, i1, j, m, k : Integer;
  WPCDIRefs : TK_PCDIRef;
  IncBlock : Boolean;
begin
  SetLength( Result, ResultUDBlocks.Count );
  n  := Length(CurRDBlockCDimsInds) + 1;
  k  := 0;
  i1 := 0;
  for i := 0 to High(Result) do begin
    IncBlock := true;
    WPCDIRefs := PCDIRefs;
    for j := 0 to Count - 1 do begin
      with WPCDIRefs^ do begin
        m := CDRCDim.Marker;
        if (m > 0) and
           (ResultBDValCDIHCodes[i1 + m] = CDRItemInd) then Continue;
        IncBlock := false;
        break;
      end;
      Inc(WPCDIRefs);
    end;
    if not IncBlock then Continue;
    Result[k] := i;
    Inc(k);
    Inc( i1, n );
  end;
  SetLength( Result, k );
end; // end of TK_QueryBlockData0.GetResCSDBlockInds

//**************************************** TK_QueryBlockData0.GetResCSDBlock
//  Clear Query Data
//
function TK_QueryBlockData0.GetResCSDBlock( DBInd: Integer ): TK_UDCSDBlock;
begin
  Result := nil;
  if (DBInd >= 0) and (DBInd < ResultUDBlocks.Count) then
    Result := TK_UDCSDBlock( ResultUDBlocks[DBInd] );
end; // end of TK_QueryBlockData0.GetResCSDBlock

//**************************************** TK_QueryBlockData0.Clear
//  Clear Query Data
//
procedure TK_QueryBlockData0.Clear;
var i : Integer;
begin
  SrcUDRoots.Clear;
  UnmarkQueryUDCDims;
  QCDims := nil;
  if ResultUDBlocks = nil then
    for i := 0 to ResultUDBlocks.Count - 1 do
      TN_UDBase(ResultUDBlocks[i]).UDDelete;
  ResultUDBlocks.Clear;
  SrcUDCSDBlocks.Clear;
  FreeAndNil( ResultRABlocksMatrix );
end; // end of TK_QueryBlockData0.Clear

//**************************************** TK_QueryBlockData0.UnmarkQueryUDCDims
//  Clear Query CDim QInds
//
procedure TK_QueryBlockData0.UnmarkQueryUDCDims;
var i : Integer;
begin
  for i := 0 to High(QCDims) do
    TK_UDCDim(QCDims[i].QCDAttrs.CDim).Marker := 0;
end; // end of TK_QueryBlockData0.UnmarkQueryUDCDims

//**************************************** TK_QueryBlockData0.SetCDimQInds
//  Set Query CDim QInds
//
procedure TK_QueryBlockData0.SetCDimQInds;
var i : Integer;
begin
  for i := 0 to High(QCDims) do
    TK_UDCDim(QCDims[i].QCDAttrs.CDim).Marker := i + 1;
end; // end of TK_QueryBlockData0.SetCDimQInds

//**************************************** TK_QueryBlockData0.AddUDCSDBlockData
//  Add UDCSDBlock Data
//
procedure TK_QueryBlockData0.AddUDCSDBlockData( UDCSDBlock : TK_UDCSDBlock );
var
//  i : Integer;
  CCount, RCount : Integer;
  QCDimsColInd : Integer;
  QCDimsRowInd : Integer;
  AddColTOIDCSDim : Boolean;
  AddRowTOIDCSDim : Boolean;
  CurInd : Integer;
  PColCSDim : PInteger;
  PRowCSDim : PInteger;
  UDCDim : TN_UDBase;
  RACSDim : TK_RArray;

  procedure AddValuesLoop( DataInds21 : Boolean;
    Count1, QCDimsInd1 : Integer; CSDim1 : PInteger; AddTOIDCSDim1 : Boolean;
    Count2, QCDimsInd2 : Integer; CSDim2 : PInteger; AddTOIDCSDim2 : Boolean );
  var
    WCSDim : PInteger;
    i1, i2 : Integer;
  begin
    CurUDCSDBlockUseFlag := false;
    for i1 := 0 to Count1 - 1 do begin
      //*** Fill CurDValCDimsInds By Row Inds
      if QCDimsInd1 >= 0 then
        with QCDims[QCDimsInd1] do begin
          CurInd := CSDim1^;
          if (QCDCount > 0) and (QBInds[CurInd] < 0) then Continue;
          CurDValCDimsInds[QCDimsInd1] := CurInd;
          if AddTOIDCSDim1 then
            CurRDBlockCDimsInds[QCDimsInd1] := CurInd;
        end;
      WCSDim := CSDim2;
      for i2 := 0 to Count2 - 1 do begin
        //*** Fill CurDValCDimsInds By Column Inds
        if QCDimsInd2 >= 0 then
          with QCDims[QCDimsInd2] do begin
            CurInd := WCSDim^;
            if (QCDCount > 0) and (QBInds[CurInd] < 0) then Continue;
            CurDValCDimsInds[QCDimsInd2] := CurInd;
            if AddTOIDCSDim2 then
              CurRDBlockCDimsInds[QCDimsInd2] := CurInd;
          end;
        if DataInds21 then
          AddResDataValue( UDCSDBlock.R.PME(i2, i1)^ )
        else
          AddResDataValue( UDCSDBlock.R.PME(i1, i2)^ );
        Inc(WCSDim);
        CurUDCSDBlockUseFlag := not AddTOIDCSDim2;
      end;
      Inc(PRowCSDim);
      CurUDCSDBlockUseFlag := CurUDCSDBlockUseFlag and not AddTOIDCSDim1;
    end;
    CurUDCSDBlockUseFlag := false;
  end;

begin

  UDCSDBlock.R.ALength( CCount, RCount );
  //*** Prepare Columns Add Context
  RACSDim := UDCSDBlock.GetColRACDRel;
  UDCDim := K_GetRACSDimCDim( RACSDim );
  AddColTOIDCSDim := false;
  PColCSDim := nil;
  if UDCDim = nil then
    QCDimsColInd := -1
  else begin
    QCDimsColInd := UDCDim.Marker - 1;
    PColCSDim := RACSDim.P;
    AddColTOIDCSDim := (QCDimsColInd <> ResColCDimInd) and (QCDimsColInd <> ResRowCDimInd);
  end;

  //*** Prepare Rows Add Context
  RACSDim := UDCSDBlock.GetRowRACDRel;
  UDCDim := K_GetRACSDimCDim( RACSDim );
  AddRowTOIDCSDim := false;
  PRowCSDim := nil;
  if UDCDim = nil then
    QCDimsRowInd := -1
  else begin
    QCDimsRowInd := UDCDim.Marker - 1;
    PRowCSDim := RACSDim.P;
    AddRowTOIDCSDim := (QCDimsRowInd <> ResColCDimInd) and (QCDimsRowInd <> ResRowCDimInd);
  end;
{ //!!
  with UDCSDBlock.GetCBRACDRel do begin
  //*** Fill CurDValCDimsInds By CDIRefs
    FillChar( CurDValCDimsInds[0], Length(CurDValCDimsInds) * SizeOf(Integer), -1 );
    for i := 0 to AHigh do
      with TK_PCDIRef(P(i))^ do
        CurDValCDimsInds[CDRCDim.Marker-1] := CDRItemInd;
  end;
}
  Move(CurDValCDimsInds[0], CurRDBlockCDimsInds[0], Length(CurRDBlockCDimsInds) * SizeOf(Integer) );

//*** Add Values
  if not AddColTOIDCSDim and AddRowTOIDCSDim then
    AddValuesLoop( false,
      CCount, QCDimsColInd, PColCSDim, AddColTOIDCSDim,
      RCount, QCDimsRowInd, PRowCSDim, AddRowTOIDCSDim )
  else
    AddValuesLoop( true,
      RCount, QCDimsRowInd, PRowCSDim, AddRowTOIDCSDim,
      CCount, QCDimsColInd, PColCSDim, AddColTOIDCSDim );

end; // end of TK_QueryBlockData0.AddUDCSDBlockData

//**************************************** TK_QueryBlockData0.GetNewResultBlockObjName
// Get New Query Result UDCSDBlock ObjName
//
//
function TK_QueryBlockData0.GetNewResultBlockObjName( AQCDims: TK_QCDArray0;
                                        ADValCSDim: TN_IArray ): string;
begin
  Result := 'QRB'+ IntToStr(ResultUDBlocks.Count);
end; // end of TK_QueryBlockData0.GetNewResultBlockObjName

//**************************************** TK_QueryBlockData0.ScanSrcRoots
// Scan All Source Roots for Proper Data Blocks
//
procedure TK_QueryBlockData0.ScanSrcRoots( TypeName : string = '' );
var
  i : Integer;
begin
  if TypeName <> '' then QDataType := K_GetTypeCodeSafe( TypeName );
  K_UDScannedUObjsList := Tlist.Create;
//  K_UDOwnerChildsScan := true;
//  K_UDRAFieldsScan := false;
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsOwnerChildsOnlyScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan];
  for i := 0 to SrcUDRoots.Count - 1 do
    TN_UDBase(SrcUDRoots[i]).ScanSubTree( TestUDCSDBlock );
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsOwnerChildsOnlyScan];
//  K_UDRAFieldsScan := true;
//  K_UDOwnerChildsScan := false;
  K_ClearUObjsScannedFlag;
  FreeAndNil(K_UDScannedUObjsList);
end; // end of TK_QueryBlockData0.ScanSrcRoots

//**************************************** TK_QueryBlockData0.TestUDCSDBlock
// Test Node Function for ScanSubTree
// Adds proper UDCSDBlocks to SrcRABlocks Array
//
function TK_QueryBlockData0.TestUDCSDBlock( UDParent: TN_UDBase;
                        var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
                        const FieldName: string ): TK_ScanTreeResult;
begin
  if (UDChild is TK_UDCSDBlock) and
     CheckCSDBlockAttrs( TK_UDCSDBlock(UDChild) ) then begin
// Add Proper RACSDBlock to SrcRABlocks
     SrcUDCSDBlocks.Add(TK_UDCSDBlock(UDChild))
  end;
  Result := K_tucOK;
end; // end of TK_QueryBlockData0.TestUDCSDBlock

//**************************************** TK_QueryBlockData0.CheckCSDBlockAttrs
// Check if CSDBlock Attrs are proper to Query Conditions
//
function TK_QueryBlockData0.CheckCSDBlockAttrs( UDCSDBlock : TK_UDCSDBlock ): Boolean;
type TCheckResult = (NoCDim, CDimIsNotInQuery, CDimIsOK, NoCDimIntersection);
var
  UDCDim : TK_UDCDim;
  PCSDimAttrs : TK_PCSDimAttrs;
  PSet1 : Pointer;
  QCDInd : Integer;
//  i : Integer;
  ColsRes, RowsRes : TCheckResult;
  UCDimCount : Integer;

  function CheckCSDim( DInd : Integer ) : TCheckResult;
  begin
    Result := NoCDim;
    PCSDimAttrs := TK_PCSDimAttrs(UDCSDBlock.GetDRACDRel(DInd).PA);
    if PCSDimAttrs <> nil then begin
      UDCDim := TK_UDCDim(PCSDimAttrs.CDim);
      if UDCDim.Marker > 0 then begin
        QCDInd := UDCDim.Marker - 1;
        PSet1 := GetQCDimPSet( QCDInd );
        Result := NoCDimIntersection; //*** Empty Intersection
        if PSet1 = nil then Exit; //*** QCDim is Empty
        if (Integer(PSet1) > 1) and
           not K_SetOp2( nil, PSet1, UDCSDBlock.GetDPSSet(DInd),
                                 QCDims[QCDInd].QCDCount, K_sotAND ) then
          Exit; //*** Empty Intersection

          Inc( UCDimCount );
          Result := CDimIsOK;
      end else
        Result := CDimIsNotInQuery; //*** Not Used in Query
    end;

  end;

  procedure AddCDim( DInd : Integer );
  begin
    AddQueryCSDim( TK_PCSDimAttrs(UDCSDBlock.GetDRACDRel(DInd).PA).CDim, true );
  end;

begin

  Result := false;
//*** Elems Type
  if ((UDCSDBlock.R.GetComplexType.All xor QDataType.All) and
                              K_ffCompareTypesMask) <> 0 then Exit;
//*** Check CDIRefs Intersection with Query CDims
  UCDimCount := 0;
{!!
  with UDCSDBlock.GetRACDIRef do
    for i := 0 to AHigh do
      with TK_PCDIRef(P(i))^ do  begin
        UDCDim := TK_UDCDim( CDRCDim );
        if UDCDim.Marker > 0 then begin
          PSet1 := GetQCDimPSet( QCDInd );
          if PSet1 = nil then Exit; //*** QCDim is Empty
          if (CDRItemInd <> -1)      and
             (Integer(PSet1) > 1) and
             not K_SetIsMember ( CDRItemInd, PSet1 ) then Exit; //*** Empty Intersection
          Inc(UCDimCount);
        end;
      end;
}
//*** Check Column CSDim
  ColsRes := CheckCSDim( 0 );
  if ColsRes = NoCDimIntersection then Exit;
//*** Check Row CSDim
  RowsRes := CheckCSDim( 1 );
  if RowsRes = NoCDimIntersection then Exit;

  if UCDimCount = 0 then Exit; //*** No Query CDims are used in Block

//*** Add Not Used in Query CDims to Query CDims
{!!
  with UDCSDBlock.GetRACDIRef do
    for i := 0 to AHigh do
      with TK_PCDIRef(P(i))^ do  begin
        UDCDim := TK_UDCDim( CDRCDim );
        if UDCDim.Marker = 0 then
          AddQueryCSDim( UDCDim, true );
      end;
}
  if ColsRes = CDimIsNotInQuery then AddCDim( 0 );
  if RowsRes = CDimIsNotInQuery then AddCDim( 1 );
  Result := true;
end; // end of TK_QueryBlockData0.CheckCSDBlockAttrs

//**************************************** TK_QueryBlockData0.GetQCDimPSet
// Get Pointer to Query CDim Set Bit Scale
// returns - nil if Set is Empty
//           $1  if Set is Full
//           > 1 Pointer to Set Bit Scale
//
function TK_QueryBlockData0.GetQCDimPSet( CDimInd: Integer ): Pointer;
begin
  with QCDims[CDimInd] do begin
    if QCDSet <> nil then Result := @QCDSet[0]
    else if QCDCount = 0  then Result := nil
    else if QCDCount = -1 then Integer(Result) := 1
    else begin
      if QUDCSDim <> nil then
        Result := QUDCSDim.GetPSSet
      else begin
        SetLength( QCDSet, K_SetByteLength( QCDCount ) );
        Result := @QCDSet[0];
        K_SetFromInds ( Result, @QInds[0], Length(QInds) );
      end;
    end;
  end;
end; // end of TK_QueryBlockData0.GetQCDimPSet

//**************************************** TK_QueryBlockData0.QuerySrcData;
// Query Source Data Blocks
//
procedure TK_QueryBlockData0.QuerySrcData;
var
  i  : Integer;
  LCount : Integer;
  CSDBType : TK_ExprExtType;

  function AddLevelMatrix( LInd : Integer ) : TK_RArray;
  var
    i, j : Integer;
    ColCount, RowCount : Integer;
    ColInds : TObject;
    RowInds : TObject;
  begin
    ColInds := PrepResBlockCSDimObject( ResColCDimsInds[LInd] );
    RowInds := PrepResBlockCSDimObject( ResRowCDimsInds[LInd] );

    Result := K_CreateRADBlock( CSDBType, ColInds, RowInds, [], 1 );
  //*** Free Temporary Created CSDim
    if ColInds is TK_RArray then TK_RArray(ColInds).ARelease;
    if RowInds is TK_RArray then TK_RArray(RowInds).ARelease;

  //*** Correct New CSDBlock Length
    Inc(LInd);
    if LInd >= LCount then Exit;
    Result.ALength( ColCount, RowCount );
    for j := 0 to RowCount - 1 do
      for i := 0 to ColCount - 1 do
        TK_PRArray(Result.PME(i,j))^ := AddLevelMatrix( LInd );
  end;

begin
//*** Prepare QCDims BInds
  for i := 0 to High(QCDIms) do begin
    with QCDIms[i] do begin
      if QCDCount > 0 then begin
        SetLength( QBInds, QCDCount ); // BackInds for Result Columns Ordered CDim
        K_BuildBackIndex0( @QInds[0], Length(QInds), @QBInds[0], QCDCount );
      end;
    end;
  end;

//*** Prepare Scalar Value of QCDims Inds Array
  SetLength( CurDValCDimsInds, Length(QCDIms) );
  SetLength( CurRDBlockCDimsInds, Length(QCDIms) );
//*** Byte Length of CurDValCDimsInds
  DValCSDimSize := Length(CurDValCDimsInds) * SizeOf(Integer);
//*** Store Always New Adler Checksum Code
  FillChar( CurRDBlockCDimsInds[0], DValCSDimSize, -1 );
  NewBlockAdlerCode := N_AdlerChecksum( PByte(@CurRDBlockCDimsInds[0]), DValCSDimSize );
//*** ResultBlocksList
  ResultUDBlocks.Clear;

  //*** Create Query Column and Row UDCSDim
  if (ResColCDimInd >= 0) then
    with QCDIms[ResColCDimInd] do
      if (QUDCSDim = nil) and (K_qbdCreateUDCSDim in QueryFlags) then begin
        QUDCSDim := TK_UDCDim(QCDAttrs.CDim).CreateCSDim( 'CInds', QCDCount, '', ResultUDRoot );
        if QCDCount > 0 then
          Move( QInds[0], QUDCSDim.R.P^, QCDCount * SizeOf(Integer) );
      end;

  if (ResRowCDimInd >= 0) then
    with QCDIms[ResRowCDimInd] do
      if (QUDCSDim = nil) and (K_qbdCreateUDCSDim in QueryFlags) then begin
        QUDCSDim := TK_UDCDim(QCDAttrs.CDim).CreateCSDim( 'RInds', QCDCount, '', ResultUDRoot );
        if QCDCount > 0 then
          Move( QInds[0], QUDCSDim.R.P^, QCDCount * SizeOf(Integer) );
      end;

  LCount := Length(ResColCDimsInds);
  if (ResultRABlocksMatrix = nil) and (LCount > 0) then begin
  //*** Create Data Blocks Container
     CSDBType := K_GetExecTypeCodeSafe( 'TK_CSDBBlock' );
     ResultRABlocksMatrix := AddLevelMatrix( 0 );
  end;

  if SrcUDCSDBlocks.Count = 0 then Exit; //*** Nothing to Do
  for i := 0 to SrcUDCSDBlocks.Count - 1 do
    OnQueryRACSDBlockData( TK_UDCSDBlock(SrcUDCSDBlocks[i]) );
  ResultUDRoot.RebuildVNodes();
end; // end of TK_QueryBlockData0.QuerySrcData;

//**************************************** TK_QueryBlockData0.AddResDataValue
// Add New Result Value
// Value of QCDims Indices are in the CurDValCDimsInds
//
procedure TK_QueryBlockData0.AddResDataValue( var Value );
var
  UDCSDBlock : TK_UDCSDBlock;
  ICol, IRow : Integer;
begin
  UDCSDBlock := ResCSDBlockByCDValInds;
  //*** Build Value Column Index
  ICol := GetQCDimCurDataIndex(ResColCDimInd);
  if ICol < 0 then Exit;

  //*** Build Value Row Index
  IRow := GetQCDimCurDataIndex(ResColCDimInd);
  if IRow < 0 then Exit;

  //*** Move Data
  K_MoveSPLData( Value, UDCSDBlock.R.PME(ICol, IRow)^, QBElemType );

end; // end of TK_QueryBlockData0.AddResDataValue

//**************************************** TK_QueryBlockData0.GetQCDimCurDataIndex
// Get Res Data Block Index for Current Data Value
//
function TK_QueryBlockData0.GetQCDimCurDataIndex( ResCDimInd : Integer ) : Integer;
begin
  Result := 0;
  if ResCDimInd >= 0 then
    with QCDIms[ResCDimInd] do begin
      Result := CurDValCDimsInds[ResCDimInd];
      if QCDCount > 0 then
        Result := QBInds[Result];
    end;
end; // end of TK_QueryBlockData0.GetQCDimCurDataIndex

//**************************************** TK_QueryBlockData0.PrepResBlockCSDimObject
// Prepare Result Block CSDim Object
//
function TK_QueryBlockData0.PrepResBlockCSDimObject( ResCDimInd : Integer) : TObject;
var
  WCount : Integer;
begin
  Result := nil;
  if (ResCDimInd >= 0) then
    with QCDIms[ResCDimInd] do begin
      Result := QUDCSDim;
      if Result = nil then begin
        Result := K_CreateRACSDim( TK_UDCDim(QCDAttrs.CDim), QCDAttrs.CDIType, [K_crfCountUDRef] );
        WCount := QCDCount;
        if QCDCount = -1 then WCount := TK_UDCDim(QCDAttrs.CDim).CDimCount;
        TK_RArray(Result).ASetLength( WCount );
        if QCDCount = -1 then
          K_FillIntArrayByCounter( TK_RArray(Result).P, WCount )
        else
          Move( QInds[0], TK_RArray(Result).P^, QCDCount * SizeOf(Integer) );
      end;
    end;
end; // end of TK_QueryBlockData0.PrepResBlockCSDimObject

//**************************************** TK_QueryBlockData0.ResCSDBlockByCDValInds
// Get Result UDCSDBlock for Value
// Value of QCDims Indices are in the CurDValCDimsInds
//
function TK_QueryBlockData0.ResCSDBlockByCDValInds : TK_UDCSDBlock;
var
  i, h, j, n, k : Integer;
  HCode : Integer;
  ColInds, RowInds : TObject;
  ICol, IRow : Integer;
  CRAMatrix : TK_RArray;

begin
  Result := CurUDCSDBlock;
  if CurUDCSDBlockUseFlag then Exit;
  n := Length(CurRDBlockCDimsInds) + 1;
//*** Search for Proper DBlock
  h := ResultUDBlocks.Count;
  HCode := N_AdlerChecksum( PByte(@CurRDBlockCDimsInds[0]), DValCSDimSize );

  i := 0;
  CurUDCSDBlock := nil;
    //  Some Result BLocks Exit
  if (h > 0) and
    //  Scalar CurRDBlockCDimsInds has some Dimensions Elements Actual References
     (HCode <> NewBlockAdlerCode) then
    repeat
      j := i * n;
      k := K_IndexOfIntegerInRArray( HCode, @ResultBDValCDIHCodes[j],
                                    h - i, DValCSDimSize + SizeOf(Integer) );
      if k >= 0 then begin
        i := i + k;
        if CompareMem( @ResultBDValCDIHCodes[j+k*n+1], @CurRDBlockCDimsInds[0], DValCSDimSize ) then
          CurUDCSDBlock := TK_UDCSDBlock( ResultUDBlocks[i] )
        else
          Inc(i);
      end;
    until (k < 0) or (CurUDCSDBlock <> nil);

  if CurUDCSDBlock = nil then begin
//*** Create New UDCSDBlock
    k := h + 1;
    if K_NewCapacity( k, RVCDICapacity ) then
      SetLength( ResultBDValCDIHCodes, RVCDICapacity * n );
    j := n * h;
    ResultBDValCDIHCodes[j] := HCode;
    Move( CurRDBlockCDimsInds[0], ResultBDValCDIHCodes[j + 1], DValCSDimSize );

    ColInds := PrepResBlockCSDimObject( ResColCDimInd );
    RowInds := PrepResBlockCSDimObject( ResRowCDimInd );

    CurUDCSDBlock := TK_UDCSDBlock.CreateAndInit( QDataType,
                             OnGetNewResultBlockName( QCDIms, CurDValCDimsInds ),
                             ColInds, RowInds, '', ResultUDRoot, 1 );

  //*** Add Block CDIRefs
{
    for i := 0 to High(CurRDBlockCDimsInds) do
      with QCDims[i] do
        if (QCDCount <> 0) and (CurRDBlockCDimsInds[i] >= 0) then
          CurUDCSDBlock.ChangeCDRelIRef( TK_UDCDim(QCDAttrs.CDim), CurRDBlockCDimsInds[i], true );
}
  //*** Free Temporary Created CSDim
    if ColInds is TK_RArray then TK_RArray(ColInds).ARelease;
    if RowInds is TK_RArray then TK_RArray(RowInds).ARelease;

  //*** Correct New UDCSDBlock Length
    with CurUDCSDBlock do
      if Assigned(InitResultFunc) then InitResultFunc(R, 0, R.ALength);
    ResultUDBlocks.Add( CurUDCSDBlock );
    if ResultRABlocksMatrix <> nil then begin
  //*** Add CSDBlock to Matrix Container
      CRAMatrix := ResultRABlocksMatrix;
      //*** Search Target Matrix Container
      for i := 0 to High(ResColCDimsInds) - 1 do begin
        ICol := GetQCDimCurDataIndex( ResColCDimsInds[i] );
        IRow := GetQCDimCurDataIndex( ResRowCDimsInds[i] );
        CRAMatrix := TK_PRArray( CRAMatrix.PME(ICol, IRow) )^;
      end;
      //*** Add Reference to RACSDBlock to Target Matrix Container
      i := High(ResColCDimsInds);
      ICol := GetQCDimCurDataIndex( ResColCDimsInds[i] );
      IRow := GetQCDimCurDataIndex( ResRowCDimsInds[i] );
      TK_PRArray( CRAMatrix.PME(ICol, IRow) )^ := CurUDCSDBlock.R.AAddRef;
    end;
  end;

  Result := CurUDCSDBlock;
end; // end of TK_QueryBlockData0.ResCSDBlockByCDValInds
{*** end of TK_QueryBlockData0 ***}

{*** TK_QueryBlockData ***}
//**************************************** TK_QueryBlockData.Create
//
constructor TK_QueryBlockData.Create;
//var
//  SL : TStringList;
begin
  inherited;
  QSrcUDRoots := TList.Create;
  QSrcRACSDBlocks := TList.Create;
  OnQueryRACSDBlockData := QueryRACSDBlockData;
  InitResultValFunc := GetPEmptyValue;
  QSrcUDRoots.Add( K_CurArchive );
  DuplRBDInds := K_RCreateByTypeCode( Ord(nptInt), 0 );
end; // end of TK_QueryBlockData.Create

//**************************************** TK_QueryBlockData.Destroy
//
destructor TK_QueryBlockData.Destroy;
begin
  Clear;
  QSrcUDRoots.Free;
  QSrcRACSDBlocks.Free;
  DuplRBDInds.ARelease;
  UserRBEEmptyVal.ARelease;
  CurRBEEmptyVal.ARelease;
  inherited;
end; // end of TK_QueryBlockData.Destroy

//**************************************** TK_QueryBlockData.Clear
//  Clear Query Data
//
procedure TK_QueryBlockData.Clear;
begin
  QSrcUDRoots.Clear;
  QSrcRACSDBlocks.Clear;
  UnmarkQueryUDCDims;
  AllQCSDims := nil;
  AllQCDRels := nil;
  RBSLevelRAType.All := 0;
  if CurUDRDBlock = nil then
    CurRDBlock.ARelease
  else
    CurUDRDBlock := nil;
  FullCDIntInds := nil;
  DuplRBDInds.ASetLength( 0 );
  ReadyToScanSrcBlocks := false;
  ReadyToQueryDataFromSrcBlocks := false;
end; // end of TK_QueryBlockData.Clear

//**************************************** TK_QueryBlockData.AddUDRoot
//
procedure TK_QueryBlockData.AddUDRoot( UDRoot : TN_UDBase );
begin
  if (UDRoot <> nil) and (QSrcUDRoots.IndexOf( UDRoot ) = -1) then
    QSrcUDRoots.Add( UDRoot );
end; // end of TK_QueryBlockData.AddUDRoot

//**************************************** TK_QueryBlockData.UnmarkQueryUDCDims
//  Clear Query CDim QInds
//
procedure TK_QueryBlockData.UnmarkQueryUDCDims;
var i : Integer;
begin
  for i := 0 to High(AllQCSDims) do
    with AllQCSDims[i].QUDCDim do Marker := 0;
end; // end of TK_QueryBlockData.UnmarkQueryUDCDims

//**************************************** TK_QueryBlockData.AddQСondition
//  Add New Condition Relation to Query
//  CDObject - TK_UDCDim                - UD Code Dimension
//             TK_UDCSDim               - UD Code SubDimension
//             TK_UDCDRel               - UD Code Dimensions Relation
//             TK_UDCSDBlock            - UD Block of Code Dimensions Relations
//             TK_RArray (SPL TK_CSDim)   - RA Code SubDimension
//             TK_RArray (SPL TK_CDRel)   - RA Code Relation
//             TK_RArray (SPL TK_CSDBRel) - RA Block of Code Relations
//
function  TK_QueryBlockData.AddQCondition( CDObject : TObject ) : Integer;
var
  RACDRel : TK_RArray;
  RelTypeName : string;
  UDCDRel : TK_UDRArray;
begin
  Result := -1;
  if CDObject = nil then Exit;
  RACDRel := nil;
  UDCDRel := nil;
  if CDObject is TK_UDCDim then begin
    UDCDRel := TK_UDCDim(CDObject).FullCSDim;
    RACDRel := UDCDRel.R;
  end else if CDObject is TK_UDCSDim then begin
    UDCDRel := TK_UDCSDim(CDObject);
    RACDRel := UDCDRel.R;
  end else if CDObject is TK_UDCDRel then begin
    UDCDRel := TK_UDCDRel(CDObject);
    RACDRel := UDCDRel.R;
  end else if CDObject is TK_UDCSDBlock then begin
    UDCDRel := TK_UDCDRel(CDObject);
    RACDRel := UDCDRel.R;
  end else if CDObject is TK_RArray then
    RACDRel := TK_RArray(CDObject);
  if RACDRel = nil then Exit;
  RelTypeName := K_GetExecTypeName( RACDRel.GetComplexType.All );
  if (RACDRel.ARowCount = 0) or
     ( (RelTypeName <> 'TK_CSDim') and
       (RelTypeName <> 'TK_CDRel') and
       (RelTypeName <> 'TK_CSDBRel') ) then Exit;
//*** Add New Condition Relation to Query
  Result := Length(AllQCDRels);
  SetLength( AllQCDRels, Result + 1 );
  with AllQCDRels[Result] do begin
    QRACDRel := RACDRel;
    QUDCDRel := UDCDRel;
    //*** Add SubCDRels Info
    if (RelTypeName = 'TK_CSDBRel') then begin
      QSRACDRel := QRACDRel;
      with TK_PCSDBAttrs(QSRACDRel.PA)^ do
        if ColsRel <> nil then
          QRACDRel := K_GetPVRArray( ColsRel )^
        else if RowsRel <> nil then
          QRACDRel := K_GetPVRArray( RowsRel )^
        else begin
          SetLength( AllQCDRels, Result );
          Result := -1;
        end;
    end;
  end;
end; // end of TK_QueryBlockData.AddQСondition

//**************************************** TK_QueryBlockData.ScanSrcRoots
// Scan All Source Roots for Proper Data Blocks
//
procedure TK_QueryBlockData.ScanSrcRoots( TypeName : string = '' );
var
  i  : Integer;

begin
  InitScanSrcBlocksContext;
//*** Set Block Type Query Condition
  if TypeName <> '' then RBSLevelRAType := K_GetTypeCodeSafe( TypeName );

//*** Prepare ScanSubtree Attribs
  K_UDScannedUObjsList := Tlist.Create;
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsOwnerChildsOnlyScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan];
//  K_UDOwnerChildsScan := true;
//  K_UDRAFieldsScan := false;

//*** UDRoots ScanSubtree Loop
  for i := 0 to QSrcUDRoots.Count - 1 do
    TN_UDBase(QSrcUDRoots[i]).ScanSubTree( TestUDCSDBlock );

//*** Clear ScanSubtree Attribs
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsOwnerChildsOnlyScan];
//  K_UDRAFieldsScan := true;
//  K_UDOwnerChildsScan := false;
  K_ClearUObjsScannedFlag;
  FreeAndNil(K_UDScannedUObjsList);
end; // end of TK_QueryBlockData.ScanSrcRoots

//**************************************** TK_QueryBlockData.AddRACSDBlockToQueue
// Add RACSDBlock to Blocks Queue
//
procedure TK_QueryBlockData.AddRACSDBlockToQueue( ARACSDBlock : TK_RArray );
begin
  if (ARACSDBlock <> nil) and CheckRACSDBlockCDims( ARACSDBlock ) then
    QSrcRACSDBlocks.Add( ARACSDBlock );
end; // end of TK_QueryBlockData.AddRACSDBlockToQueue

//**************************************** TK_QueryBlockData.QuerySrcBlocksData
// Query Source Data Blocks
//
procedure TK_QueryBlockData.QuerySrcBlocksData;
var
  i : Integer;
begin
  InitScanSrcBlocksContext;
  InitQueryDataContext;
  for i := 0 to QSrcRACSDBlocks.Count - 1 do
    OnQueryRACSDBlockData( TK_RArray(QSrcRACSDBlocks[i]) );
  ResultUDRoot.RebuildVNodes();
  UnmarkQueryUDCDims;
  DelResultBlockUData;
  OptimizedAutoCreatedUDCDRels;
  
end; // end of TK_QueryBlockData.QuerySrcBlocksData

//**************************************** TK_QueryBlockData.DelResultBlockUData
// Query Source Data Blocks
//
procedure TK_QueryBlockData.DelResultBlockUData;
var
  i, ci, ri : Integer;
  ColLevels, RowLevels : TN_IArray;
begin
  ci := 0;
  ri := 0;
  SetLength( ColLevels, RBLevelsCount );
  SetLength( RowLevels, RBLevelsCount );
  for i := 0 to RBLevelsCount - 1 do
    with RBLevels[i] do begin
      if K_qbdlUDataColsAutoDelete in LFlags then begin
        ColLevels[ci] := i;
        Inc(ci);
      end;
      if K_qbdlUDataRowsAutoDelete in LFlags then begin
        RowLevels[ri] := i;
        Inc(ri);
      end;
    end;

  K_RADBlockMLDelUndefElems( CurRDBlock, InitResultValFunc,
                               K_GetPIArray0( ColLevels ), ci,
                               K_GetPIArray0( RowLevels ), ri, 0 );
end; // end of TK_QueryBlockData.DelResultBlockUData

//**************************************** TK_QueryBlockData.OptimizedAutoCreatedUDCDRels
// Replace Auto Created UDCDRels which has single reference
//
procedure TK_QueryBlockData.OptimizedAutoCreatedUDCDRels;
var
  UDCDRel : TK_UDRArray;

  procedure TryToReplaceUDCDRel( var CDRel : TObject );
  begin
    if (CDRel <> nil)                           and
       (CDRel is TN_UDBase)                     and
       (TN_UDBase(CDRel).Owner = CurUDRDBlock ) and
       (TN_UDBase(CDRel).RefCounter = 2 ) then begin
      K_SetVArrayField( CDRel, TK_UDRArray(CDRel).R, [K_svrCountUDRef] );
{
!!      K_SetVArrayField( CDRel, TK_UDRArray(CDRel).R, true );
      UDCDRel := TK_UDRArray(CDRel);
      UDCDRel.Delete();
      TK_RArray(CDRel) := UDCDRel.R.AAddRef;
}
      CurUDRDBlock.DeleteOneChild( UDCDRel );
    end;
  end;

  procedure TestLevelCSDBlock( RACSDBlock : TK_RArray );
  var
    i, j, ColCount, RowCount : Integer;
    PData : Pointer;

  begin

    with RACSDBlock, TK_PCSDBAttrs(PA)^ do begin

      TryToReplaceUDCDRel( ColsRel );

      TryToReplaceUDCDRel( RowsRel );

      if not K_IfBBLevelRAType( GetComplexType ) then Exit;

      //*** Block Elems Loop
      ALength( ColCount, RowCount );
      for j := 0 to RowCount - 1 do begin
        for i := 0 to ColCount - 1 do begin
//          PData := RACSDBlock.PME( i, j );
          PData := K_GetPVRArray( PME( i, j )^ );
          if TK_PRArray(PData)^ <> nil then
            TestLevelCSDBlock( TK_PRArray(PData)^ );
        end; //*** Block Columns Loop
      end; //*** Block Rows Loop
    end;
  end;

begin
  if CurUDRDBlock = nil then Exit; // Nothing to do
  TestLevelCSDBlock( CurUDRDBlock.R );
end; // end of TK_QueryBlockData.OptimizedAutoCreatedUDCDRels

//**************************************** TK_QueryBlockData.QueryRACSDBlockData
//  Add UDCSDBlock Data
//
procedure TK_QueryBlockData.QueryRACSDBlockData( ARACSDBlock : TK_RArray );

  function CheckCDRel( CDRInd : Integer; var ElemInd : Integer ) : Boolean;
  var
    Ind : Integer;
    CompareFunc: TN_CompFuncOfObj;
  begin
    Result := true;
  //*** Check if Scalar is proper for all query conditions
    with AllQCDRels[CDRInd] do begin
  // Build Elem Compressed Index
      K_PrepQAIndexElem( @CurQAIndexElem[0], QACDIWidths,
                         @CSCSDimsInds[0], @QCSDInds[0] );
  // Search in QAIndex
      N_CFuncs.Offset := 0;
      N_CFuncs.NumFields := QAWidth - 1;
      CompareFunc := N_CFuncs.CompNInts;
      if N_CFuncs.NumFields = 1 then
        CompareFunc := N_CFuncs.CompOneInt;                         // ???? + 1
      Ind := -1 + K_IndexOfValueInSortedRArray( CurQAIndexElem[0], @QAIndex[1],
                QRACDRel.ARowCount, QAWidth*SizeOf(Integer), CompareFunc );
      if (Ind >= 0) and
         CompareMem( @CurQAIndexElem[0],
                     @QAIndex[Ind * QAWidth + 1], // ???? + 1
                     N_CFuncs.NumFields*SizeOf(Integer) ) then
        ElemInd := QAIndex[Ind * QAWidth]
//        ElemInd := Ind;
      else
        Result := false;
    end;
  end;

  procedure AddScalarValue( var Value );
  var
    i, n : Integer;
    CDRInd : Integer;

    procedure PrepareCDRind;
    begin
      n := 0;
      if CDRInd < 0 then
        n := -( CDRInd mod -100 );
      assert( (i >= n) or (CDRInd >= 0), 'Wrong CDRel Index at level ' + IntToStr(i) );
      if CDRInd < -200 then
        CDRInd := AllQCDRels[RBLevels[i-n].RowQCDRInd].QLSRels[CurRBRowDInds[i-n]]
      else if CDRInd < -100 then
        CDRInd := AllQCDRels[RBLevels[i-n].ColQCDRInd].QLSRels[CurRBColDInds[i-n]];
    end;

  begin
  //*** Check if Scalar is proper for all query conditions
    FillChar( CurRBColDInds[0], Length(CurRBColDInds) * SizeOf(Integer) , -1 );
    FillChar( CurRBColCDRelInds[0], Length(CurRBColDInds) * SizeOf(Integer) , -1 );
    FillChar( CurRBRowDInds[0], Length(CurRBRowDInds) * SizeOf(Integer) , -1 );
    FillChar( CurRBRowCDRelInds[0], Length(CurRBColDInds) * SizeOf(Integer) , -1 );
    for i := 0 to RBLevelsCount - 1 do begin
      CDRInd := RBLevels[i].ColQCDRInd;
      if CDRInd <> -1 then begin
        PrepareCDRind;
        if not CheckCDRel( CDRInd, CurRBColDInds[i] ) then Exit;
        CurRBColCDRelInds[i] := CDRInd;
      end;

      CDRInd := RBLevels[i].RowQCDRInd;
      if CDRInd <> -1 then begin
        PrepareCDRind;
        if not CheckCDRel( CDRInd, CurRBRowDInds[i] ) then Exit;
        CurRBRowCDRelInds[i] := CDRInd;
      end;
    end;

    for i := 0 to High( AllQCDRels ) do
      if not AllQCDRels[i].QRBlockRelFlag and not CheckCDRel( i, n ) then Exit;

    AddResDataValue( Value );

  end;

  procedure ClearUsedCSDims( UsedCSDimInds : TN_IArray );
  var i, j : Integer;
  begin
    for i := 0 to High(UsedCSDimInds) do begin
      j := UsedCSDimInds[i];
      if j < 0 then Continue;
      CSCSDimsInds[j] := -1;
      CSUsedCSDims[j] := 0;
    end;
  end;

  procedure AddLevelCSDBlock( RACSDBlock : TK_RArray );
  var
    RACDRelCols, RACDRelRows, RABlock : TK_RArray;
    i, j, ColCount, RowCount : Integer;
    BlockType : TK_ExprExtType;
    ScalarsBlock : Boolean;
    PData : Pointer;
    ColInds : TN_IArray;
    RowInds : TN_IArray;

  begin
    with TK_PCSDBAttrs(RACSDBlock.PA)^ do begin
      BlockType.All := RACSDBlock.GetComplexType.DTCode;
      ScalarsBlock := not K_IfBBLevelRAType( BlockType );
      if ScalarsBlock then begin
      //*** Block is Scalars Container
        QBSLevelRAType := BlockType;
        QBElemType := RACSDBlock.ElemType;
        if (RBSLevelRAType.All <> 0) and
           (((BlockType.All xor RBSLevelRAType.All) and
                                K_ffCompareTypesMask) <> 0) then Exit;
      end;

      //*** Add Level Block Data
      RACSDBlock.ALength( ColCount, RowCount );
      // Build Columns Relation Proper Inds
      RACDRelCols := K_GetPVRArray( ColsRel )^;
      if (RACDRelCols <> nil) then
        SetLength( ColInds, RACDRelCols.AColCount );

      // Build Rows Relation Proper Inds
      RACDRelRows := K_GetPVRArray( RowsRel )^;
      if (RACDRelRows <> nil) then
        SetLength( RowInds, RACDRelRows.AColCount );

      //*** Block Elems Loop
      for j := 0 to RowCount - 1 do begin
        if (RACDRelRows <> nil) then FillCDElemIndsByRACDRel( RACDRelRows, j, RowInds );
        for i := 0 to ColCount - 1 do begin
          if RACDRelCols <> nil then FillCDElemIndsByRACDRel( RACDRelCols, i, ColInds );
          PData := RACSDBlock.PME( i, j );
          if ScalarsBlock then
            AddScalarValue( PData^ )
          else begin
//            RABlock := TK_PRArray(PData)^;
            RABlock := K_GetPVRArray( PData^ )^;
            if RABlock <> nil then
              AddLevelCSDBlock( RABlock );
          end;
          if (RACDRelCols <> nil) then ClearUsedCSDims( ColInds );
        end; //*** Block Columns Loop
        if (RACDRelRows <> nil) then ClearUsedCSDims( RowInds );
      end; //*** Block Rows Loop
    end;
  end;

begin

  //*** Init Element Inds Array
  FillChar( CSCSDimsInds[0], CSCSDimsCount * SizeOf(Integer) , -1 );
  //*** Init Query CSDims Used Flags
  FillChar( CSUsedCSDims[0], CSCSDimsCount, 0 );

  with TK_PCSDBAttrs(ARACSDBlock.PA)^ do
  //*** Add Common Relation CDim Elements Inds
    if CBRel <> nil then
      FillCDElemIndsByRACDRel( CBRel, 0, nil );
  //*** Try Add All Block Data
  AddLevelCSDBlock( ARACSDBlock );

end; // end of TK_QueryBlockData.QueryRACSDBlockData

//**************************************** TK_QueryBlockData.AddResDataValue
// Add New Result Value
// Value of QCDims Indices are in the CurDValCDimsInds
//
procedure TK_QueryBlockData.AddResDataValue( var Value );
var
  RACSDBlock : TK_RArray;
  LInd, ICol, IRow : Integer;
  i, j : Integer;
  PData : Pointer;
  PInd : PInteger;
begin
  RACSDBlock := GetResRACSDBlock;
  if RACSDBlock = nil then Exit;

  LInd := RBLevelsCount - 1;
  //*** Build Value Column Index
  ICol := CurRBColDInds[LInd];
  if ICol < 0 then ICol := 0;

  //*** Build Value Row Index
  IRow := CurRBRowDInds[LInd];
  if IRow < 0 then IRow := 0;

  //*** Move Data
  with RACSDBlock do begin
    PData := RACSDBlock.PME(ICol, IRow);
    if not CompareMem( InitResultValFunc(ElemType), PData, ElemSize ) then begin
    //*** Store Duplicate value Info
      with DuplRBDInds do begin
        j := ARowCount;
        ASetLength( RBLevelsCount * 2, j + 1 );
        PInd := PInteger(DuplRBDInds.PME( 0, j ));
        for i := 0 to LInd do begin
          (PInd)^ := CurRBColDInds[i];
          Inc(PInd);
          (PInd)^ := CurRBRowDInds[i];
          Inc(PInd);
        end;
      end;
    end;
    //*** Store Scalar Value
    K_MoveSPLData( Value, RACSDBlock.PME(ICol, IRow)^, QBElemType );
  end;

end; // end of TK_QueryBlockData.AddResDataValue

//**************************************** TK_QueryBlockData.SetEmptyValue
// Set Value for Empty Block Element
//
procedure TK_QueryBlockData.SetEmptyValue( var EValue; TypeCode: TK_ExprExtType );
begin
  UserRBEEmptyVal.ARelease;
  UserRBEEmptyVal := K_RCreateByTypeCode( TypeCode.All, 1 );
  K_MoveSPLData( EValue, UserRBEEmptyVal.P^, TypeCode, [] );
end; // end of TK_QueryBlockData.SetEmptyValue

//**************************************** TK_QueryBlockData.InitScanSrcBlocksContext
// Init Query Context - CDims amd CDRels context
//
procedure TK_QueryBlockData.InitScanSrcBlocksContext;
var
  k : Integer;
  BlokLevelsRels : Boolean;

  procedure InitCDRelContext( CDRelInd : Integer );
  var
    j, k, n : Integer;
    LCount, LSCount : Integer;
    PUDCDims, PUDCDims0 : TN_PUDBase;
    UDCDimsCount : Integer;
  begin
  //*** Prepare QCDRels Data
    k := Length(AllQCSDims);

    with AllQCDRels[CDRelInd] do begin
      QRBlockRelFlag := BlokLevelsRels;
      LCount := QRACDRel.ARowCount;
      LSCount := K_SetByteLength(LCount);

      UDCDimsCount := K_GetRACDRelPUDCDims( QRACDRel, PUDCDims );
      SetLength( AllQCSDims, k + UDCDimsCount );

      //*** Init CDRel CDims Query Context
      SetLength( QCSDInds, UDCDimsCount );
      PUDCDims0 := PUDCDims;
      for j := 0 to UDCDimsCount - 1 do begin // CDRel CDims Loop
        with PUDCDims0^ do begin
          if Marker = 0 then // Not Marked UDCDim Mark it
            Marker := k + 1
          else begin         // Already Marked UDCDim - Link New CSDim to List of CDim CSDims
            n := Marker - 1;
            while AllQCSDims[n].NCSDInd > 0 do n := AllQCSDims[n].NCSDInd;
            AllQCSDims[n].NCSDInd := k;
          end;
        end;
        with AllQCSDims[k] do begin // Build CSDim BitSet
          QUDCDim := PUDCDims0^;
          SetLength(QCSDSet, LSCount);
          K_SetFromInds( @QCSDSet[0], QRACDRel.PME(j,0), LCount, SizeOf(Integer) * UDCDimsCount );
        end;
        QCSDInds[j] := k;
        Inc(PUDCDims0);
        Inc(k);
      end; // end of CDRel CDims Loop

      //*** Prepare Relation QAIndex
      QAWidth := 1 + K_BuildQAIndexElemsWidth( QACDIWidths, UDCDimsCount, PUDCDims );
      SetLength( QAIndex, QAWidth * LCount );
      K_BuildQAIndex( @QAIndex[0], QAWidth, QAWidth * SizeOf(Integer),
                      QRACDRel.P, LCount, UDCDimsCount * SizeOf(Integer), QACDIWidths );

      if QSRACDRel <> QRACDRel then begin
      //*** Add SubCDRels
        k := QSRACDRel.AHigh;
        SetLength( AllQCDRels[CDRelInd].QLSRels, k + 1 );
        for j := 0 to k do
          AllQCDRels[CDRelInd].QLSRels[j] := AddQCondition( TK_PRArray( QSRACDRel.P(j) )^ );
        with AllQCDRels[CDRelInd] do
          //*** Init CDims for Relation SubRelations
          for j := 0 to High(QLSRels) do
            InitCDRelContext( QLSRels[j] );
      end;
    end;
  end; // end of InitCDRelContext


begin
  if ReadyToScanSrcBlocks then Exit;

//*** Add CDims Used in Result Block to BlockCDimsList
  BlokLevelsRels := true;
  for k := 0 to High( RBLevels ) do
    with RBLevels[k] do begin
      if ColQCDRInd >= 0 then
        InitCDRelContext( ColQCDRInd );
      if RowQCDRInd >= 0 then
        InitCDRelContext( RowQCDRInd );
    end;

  BlokLevelsRels := false;
  for k := 0 to High( AllQCDRels ) do
    if not AllQCDRels[k].QRBlockRelFlag then
      InitCDRelContext( k );

  CSCSDimsCount := Length(AllQCSDims);
  SetLength( FullCDIntInds, CSCSDimsCount );
  ReadyToScanSrcBlocks := true;
end; // end of TK_QueryBlockData.InitScanSrcBlocksContext

//**************************************** TK_QueryBlockData.InitQueryDataContext
// Init Query Context - CDims amd CDRels context
//
procedure TK_QueryBlockData.InitQueryDataContext;
var
  WCount : Integer;
begin

  if ReadyToQueryDataFromSrcBlocks then Exit;
  //*** Init DuplRACDRel
  RBLevelsCount := Length(RBLevels);
  DuplRBDInds.ASetLength( RBLevelsCount * 2, 0 );

  //*** Prepare Scalar Value of QCDims Inds Array
  SetLength( CSCSDimsInds, CSCSDimsCount );
  SetLength( CSUsedCSDims, CSCSDimsCount );
  SetLength( CurRBColDInds, RBLevelsCount );
  SetLength( CurRBColCDRelInds, RBLevelsCount );
  SetLength( CurRBRowDInds, RBLevelsCount );
  SetLength( CurRBRowCDRelInds, RBLevelsCount );

  WCount := Length(AllQCDRels);
  SetLength( CurQAIndexElem, WCount );

  ReadyToQueryDataFromSrcBlocks := true;

end; // end of TK_QueryBlockData.InitQueryDataContext

//**************************************** TK_QueryBlockData.FillCDElemIndsByRACDRel
//  Fill Query CSDims Elemnts Indices By Relation Element
//
procedure TK_QueryBlockData.FillCDElemIndsByRACDRel( RACDRel : TK_RArray;
                                                     RelElemInd : Integer;
                                                     UsedCSDimInds : TN_IArray );
var
  PUDCDims : TN_PUDBase;
  i, CInd, n, CSDEInd, UDCDimsCount : Integer;
  PElemInds : PInteger;
//  ProperElem : Boolean;
begin
  UDCDimsCount := K_GetRACDRelPUDCDims( RACDRel, PUDCDims );
  PElemInds := RACDRel.PME( 0, RelElemInd );
//  Result := false;
  if UsedCSDimInds <> nil then
    FillChar( UsedCSDimInds[0], UDCDimsCount * SizeOf(Integer), -1 );
  for i := 0 to UDCDimsCount - 1 do begin
    with PUDCDims^ do
      if Marker <> 0 then begin
        n := Marker - 1;
        CSDEInd := PElemInds^;
        //*** Search Proper CDim CSDim
        repeat
          CInd := n;
          with AllQCSDims[CInd] do begin
            n := NCSDInd;
            if CSUsedCSDims[CInd] <> 0 then Continue;
            // Check Elem Index in CSDim Set
            if K_SetGetElementState( CSDEInd, @QCSDSet[0] ) then begin
            // Put Elem Index to Current Scalar Relation Inds
              CSCSDimsInds[CInd] := CSDEInd;
              CSUsedCSDims[CInd] := 1;
              if UsedCSDimInds <> nil then
                UsedCSDimInds[i] := CInd;
              break;
            end;
          end;
        until n = 0;
//        if not ProperElem then Exit; // Block relation element has index in CDim which is not used in Query Conditions (not used in any SubDimension)
      end;
    Inc(PUDCDims);
    Inc(PElemInds);
  end;
end; // end of TK_QueryBlockData.FillCDElemIndsByRACDRel

//**************************************** TK_QueryBlockData.CheckIndsArray
//  Init Indices Array with Undef Index Value = -2
//
function TK_QueryBlockData.CheckIndsArray( PIA : PInteger; Count, ErrBound : Integer ) : Boolean;
var
  i : Integer;
begin
  Result := false;
  for i := 0 to Count - 1 do begin
    if PIA^ < ErrBound then Exit;
    Inc(PIA);
  end;
  Result := true;
end; // end of TK_QueryBlockData.CheckIndsArray

//**************************************** TK_QueryBlockData.CheckRACSDBlockCDims
// Get UDCSDBlock CDims Inds
//
function TK_QueryBlockData.CheckRACSDBlockCDims( ARACSDBlock : TK_RArray ): Boolean;
var
  ProperType : Boolean;
  ScalarBlockLevel : Integer;
  i : Integer;

  procedure MarkCDimIndsByRACDRel( RACDRel : TK_RArray );
  var
    PUDCDims : TN_PUDBase;
    i, UDCDimsCount : Integer;
  begin
    UDCDimsCount := K_GetRACDRelPUDCDims( RACDRel, PUDCDims );
    for i := 0 to UDCDimsCount - 1 do begin
      if PUDCDims^.Marker <> 0 then
        FullCDIntInds[PUDCDims^.Marker-1] := 0;
      Inc(PUDCDims);
    end;
  end;

  procedure AddLevelCDimsInds( RACSDBlock : TK_RArray; CurBlockLevel : Integer );
  var
    RACDRel, RABlock : TK_RArray;
    i, j, ColCount, RowCount : Integer;
    BlockType : TK_ExprExtType;

  begin
    with TK_PCSDBAttrs(RACSDBlock.PA)^ do begin
      //*** Add Common Relation CDims
      if ScalarBlockLevel < CurBlockLevel then begin
        if CBRel <> nil then
          MarkCDimIndsByRACDRel( CBRel );

      //*** Add Columns Relation CDims
        RACDRel := K_GetPVRArray( ColsRel )^;
        if RACDRel <> nil then
          MarkCDimIndsByRACDRel( RACDRel );

      //*** Add Rows Relation CDims
        RACDRel := K_GetPVRArray( RowsRel )^;
        if RACDRel <> nil then
          MarkCDimIndsByRACDRel( RACDRel );
        ScalarBlockLevel := CurBlockLevel;
      end;
    //*** Check Block Type
      BlockType.All := RACSDBlock.GetComplexType.DTCode;
      if not K_IfBBLevelRAType( BlockType ) then begin
      //*** Blocks is Scalars Container
        QBSLevelRAType := BlockType;
        ProperType := (RBSLevelRAType.All = 0) or
           (((BlockType.All xor RBSLevelRAType.All) and
                                K_ffCompareTypesMask) = 0);
        if not ProperType then Exit;

      end else begin
      //*** Add  Blocks Container Elems
        RACSDBlock.ALength( ColCount, RowCount );
        Inc(CurBlockLevel);
        for j := 0 to RowCount - 1 do
          for i := 0 to ColCount - 1 do begin
//            RABlock := TK_PRArray(RACSDBlock.PME(i,j))^;
            RABlock := K_GetPVRArray( RACSDBlock.PME(i,j)^ )^;
            if RABlock <> nil then begin
              AddLevelCDimsInds( RABlock, CurBlockLevel );
              if not ProperType then Exit;
            end;
          end;
      end;
    end;
  end;

begin
  Result := false;
//*** Check CDims Intersection
  FillChar( FullCDIntInds[0], CSCSDimsCount * SizeOf(Integer), 0 );
  for i := 0 to CSCSDimsCount - 1 do
    FullCDIntInds[AllQCSDims[i].QUDCDim.Marker-1] := -1;

  ProperType := true;
  ScalarBlockLevel := -1;
  AddLevelCDimsInds( ARACSDBlock, 0 );
  if not ProperType then Exit;

//*** Checks CDims FullCDIntInds
  if CSCSDimsCount >= 0 then
    Result := CheckIndsArray( @FullCDIntInds[0], CSCSDimsCount, 0 );
end; // end of TK_QueryBlockData.CheckRACSDBlockCDims

//**************************************** TK_QueryBlockData.TestUDCSDBlock
// Test Node Function for ScanSubTree
// Adds proper UDCSDBlocks to SrcRABlocks Array
//
function TK_QueryBlockData.TestUDCSDBlock( UDParent: TN_UDBase;
                        var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
                        const FieldName: string ): TK_ScanTreeResult;
begin
  if (UDChild is TK_UDCSDBlock) then
    AddRACSDBlockToQueue( TK_UDCSDBlock(UDChild).R );
  Result := K_tucOK;
end; // end of TK_QueryBlockData.TestUDCSDBlock

//**************************************** TK_QueryBlockData.GetResRACSDBlock
// Get Result RACSDBlock
//
function TK_QueryBlockData.GetResRACSDBlock : TK_RArray;
var
  RAType : TK_ExprExtType;
  ColInds, RowInds : TObject;
  LCount, CurLevel : Integer;

  function GetBlockType : TK_ExprExtType;
  begin
    if (RBSLevelRAType.All <> 0) then
      Result := RBSLevelRAType
    else begin
      Result := QBSLevelRAType;
      if not (K_qbdVarTypeBlock in QFlags) then
        RBSLevelRAType := QBSLevelRAType;
    end;
  end;

  function PrepareRelationObj( var QCDRel : TK_QCDRel ) : TObject;
//  var
//    UDCDimsCount : Integer;
  begin
    with QCDRel do begin
      if QUDCDRel <> nil then
      //*** UDCDRel already exists
        Result := QUDCDRel
      else begin
        if (CurLevel = 0) or
           (K_qbdSkipAutoCreateUDCDRels in QFlags) or
           (CurUDRDBlock = nil) then
          Result := QRACDRel
        else begin
      //*** Create new UDCDRel Low Level Blocks
          QUDCDRel := TK_UDCDRel.CreateAndInit( 'CDRel', nil, 0, '', CurUDRDBlock );
          K_RFreeAndCopy( QUDCDRel.R, QRACDRel, [K_mdfFreeAndFullCopy] );
{
          QUDCDRel := TK_UDCDRel.CreateAndInit( 'CDRel',
            K_GetRACDRelPUDCDims( QRACDRel, UDCDimsCount) , UDCDimsCount, '', CurUDRDBlock );
          with QUDCDRel.R do begin
            ASetLength( QRACDRel.AColCount, QRACDRel.ARowCount );
            Move( QRACDRel.P^, P^, QRACDRel.ALength * ElemSize );
          end;
}
          Result := QUDCDRel;
        end;
      end;
    end;
  end;

  procedure BuildBlockDimRels;
  var
    RInd : Integer;
  begin
    //*** Columns Relation
    ColInds := nil;
    RInd := CurRBColCDRelInds[CurLevel];
    if RInd >= 0 then
      ColInds := PrepareRelationObj( AllQCDRels[RInd] );

    //*** Rows Relation
    RowInds := nil;
    RInd := CurRBRowCDRelInds[CurLevel];
    if RInd >= 0 then
      RowInds := PrepareRelationObj( AllQCDRels[RInd] );

  end;

  function GetRABlock( RABlock : TK_RArray ) : TK_RArray;
  var
    ICol, IRow : Integer;
    PData : Pointer;
  begin
  //*** Build Value Col Index
    ICol := CurRBColDInds[CurLevel];
    if ICol < 0 then ICol := 0;

  //*** Build Value Row Index
    IRow := CurRBRowDInds[CurLevel];
    if IRow < 0 then IRow := 0;

    Inc(CurLevel);

//    PData := RABlock.PME(ICol,IRow);
    PData := K_GetPVRArray( RABlock.PME(ICol,IRow)^ );
    Result := TK_PRArray(PData)^;
    if Result = nil then begin
    //*** Create Block
       if CurLevel = LCount then
         RAType := GetBlockType
//         RAType := RBSLevelRAType  // Block of Scalars
       else
         RAType := K_GetCSBBLevelRAType; // Block of Blocks
       BuildBlockDimRels;
       Result := K_CreateRADBlock( RAType, ColInds, RowInds,
                                                 [K_crfCountUDRef] );
       TK_PRArray(PData)^ := Result;
       with Result do
        SetElems( InitResultValFunc( ElemType )^ );
    end;
    if CurLevel = LCount then Exit;
    GetRABlock( Result );
  end;

begin
  //*** Create Result Multidimensional Data Block
  if CurUDRDBlock = nil then begin
    if RBLevelsCount > 1 then
      RAType := K_GetCSBBLevelRAType
    else
      RAType := GetBlockType;
    BuildBlockDimRels;
    if K_qbdSkipUDRBlockCreation in QFlags then
      CurRDBlock := K_CreateRADBlock( RAType, ColInds, RowInds, [] )
    else  begin
      CurUDRDBlock := TK_UDCSDBlock.CreateAndInit( RAType, ResultBlockName,
                                         ColInds, RowInds, ResultBlockAliase,
                                         ResultUDRoot, 1 );
      CurRDBlock := CurUDRDBlock.R;
    end;
  end;
  //*** Get Result RACSDBlock
  LCount := RBLevelsCount - 1;
  if LCount = 0 then
    Result := CurRDBlock
  else begin
//    Dec(LCount);
//    Inc(CurLevel);
    CurLevel := 0;
    Result := GetRABlock( CurRDBlock );
  end;
end; // end of TK_QueryBlockData.GetResRACSDBlock

//**************************************** TK_QueryBlockData.GetPEmptyValue
// Get Pointer to Value for Empty Block Element
//
function TK_QueryBlockData.GetPEmptyValue( TypeCode: TK_ExprExtType ) : Pointer;
begin

  if (CurRBEEmptyVal <> nil) and
     (((CurRBEEmptyVal.ElemType.All xor TypeCode.All) and K_ffCompareTypesMask) = 0) then begin
  //*** User Result Block Element Empty Value is actual
      Result := CurRBEEmptyVal.P;
      Exit;
    end;

  //*** Create Current Result Block Eelement Empty Value

  CurRBEEmptyVal.ARelease;
  // Create New Init Data Value Buffer
  CurRBEEmptyVal := K_RCreateByTypeCode( TypeCode.All, 1, [K_crfSaveElemTypeRAFlag] );
  with CurRBEEmptyVal do begin
    if (UserRBEEmptyVal <> nil) and
       (((UserRBEEmptyVal.ElemType.All xor TypeCode.All) and K_ffCompareTypesMask) = 0) then
    //*** Move User Result Block Element Empty Value to Currrent Buffer
      K_MoveSPLData( UserRBEEmptyVal.P^, P^, TypeCode )
    else
      with TypeCode do
        if (D.TFlags = 0) and (DTCode < Ord(nptNoData)) then
          case DTCode of
          Ord(nptInt),
          Ord(nptUInt4) : Integer(P^) := -1;
          Ord(nptDouble): Double(P^)  := NaN;
          Ord(nptFloat) : Float(P^)   := NaN;
          Ord(nptString): PString(P)^ := '????';
          end;
    Result := P;
  end;
end; // end of TK_QueryBlockData.GetPEmptyValue

{*** end of TK_QueryBlockData ***}

{*** TK_CDRelCtrl ***}

//**************************************** TK_CDRelCtrl.BuildCDimsIntersection
// Build CDims SubSet - Intersection of CDims in Relation1 and Relation2
//
function TK_CDRelCtrl.BuildCDimsIntersection: Integer;
var
  UDCDCorInd, i, SUDCDimsCount : Integer;
  PUDCDims : TN_PUDBase;
  WUDCD, WUDCDC : TN_UDBase;
  CDMarker : Integer;
  R1, R2, RC : TN_IArray;
  AllCount : Integer;
  SortBuf : TN_IArray;
  PP : TN_PArray;
  BufLength : Integer;
  UseCDCors : Boolean;
begin
  Result := 0;
  SaveCDimsMarkers;

  AllCount := Length(AllUDCDims);
  SetLength( R1, AllCount );
  SetLength( R2, AllCount );
  SetLength( RC, AllCount );

  //*** Mark RACDRel1 CDims
  PUDCDims := PUDCDims1;
  for i := 0 to UDCDims1Count - 1 do
    R1[PUDCDims^.Marker] := i + 1;

  //*** Select CDims Used in UDCDCors
  for i := 0 to High(UDCDCors) do begin
    WUDCDC := UDCDCors[i];
    WUDCD := TK_UDCDCor(WUDCDC).GetSecCDim;
    CDMarker := WUDCD.Marker;
    if (R1[CDMarker] = 0) or (RC[CDMarker] > 0) then Continue;
    RC[CDMarker] := i + 1;
    WUDCD := TK_UDCDCor(WUDCDC).GetPrimCDim;
    CDMarker := WUDCD.Marker;
    if RC[CDMarker] > 0 then Continue;
    //*** Mark as CDim from UDCDCor - Not Used CDim or CDim Already Used in RACDRel1
    //*** Set UDCDCor Index  To UDCDim Marker Code
    RC[CDMarker] := i + 1;
    R1[CDMarker] := 0;
  end;

  //*** Select CDims Used in RACDRel2
  //*** Mark RACDRel1 CDims
  PUDCDims := PUDCDims2;
  for i := 0 to UDCDims2Count - 1 do begin
    CDMarker := PUDCDims^.Marker;
      // Not Used CDim
    if (R1[CDMarker] = 0) or
      // CDim that has corresponding CDim from UDCDCor
       ( (RC[CDMarker] > 0) and
         (R1[CDMarker] <> 0) ) then Continue;
    R2[CDMarker] := i + 1; //*** Add RACDRel2 Index To UDCDim Marker Code
    Inc(Result);
  end;
  if Result = 0 then Exit;

//*** Build CDim Intersection Sort Index in RACDRel1
  SetLength( JCDimsOrder1, AllCount );
  SetLength( JCDimsOrder2, AllCount );
  SetLength( JUDCDCors, AllCount );
  SUDCDimsCount := 0;
  UseCDCors := false;
  for i := 0 to AllCount - 1 do begin
    CDMarker := i;
    if R2[CDMarker] = 0 then Continue; // Not Used CDim
    JCDimsOrder2[SUDCDimsCount] := CDMarker;
    UDCDCorInd := RC[CDMarker] - 1;
    if UDCDCorInd >= 0 then begin //*** UDCDCor is used
      CDMarker := TK_UDCDCor(UDCDCors[UDCDCorInd]).GetSecCDim.Marker;
      JUDCDCors[SUDCDimsCount] := UDCDCors[UDCDCorInd];
      UseCDCors := true;
    end;
    JCDimsOrder1[SUDCDimsCount] := CDMarker;
    Inc(SUDCDimsCount);
  end;
  SetLength( JCDimsOrder1, SUDCDimsCount );
  SetLength( JCDimsOrder2, SUDCDimsCount );
  SetLength( JUDCDCors, SUDCDimsCount );
//*** Sort Selected CDims
// ...
  SetLength( PP, SUDCDimsCount );
  for i := 0 to SUDCDimsCount - 1 do begin
    WUDCD := AllUDCDims[JCDimsOrder1[i]];
    WUDCD.Marker := i;
    PP[i] := WUDCD;
  end;

  N_CFuncs.Offset := 0;
  N_CFuncs.DescOrder := false;
  N_SortPointers( PP, N_CFuncs.CompOneInt );

  BufLength := SUDCDimsCount * SizeOf(Integer);
//***  Reorder JCDimsOrder1
  SetLength( SortBuf, SUDCDimsCount );
  for i := 0 to SUDCDimsCount - 1 do
    SortBuf[i] := JCDimsOrder1[TN_UDBase(PP[i]).Marker];
  Move( SortBuf[0], JCDimsOrder1[0], BufLength );
//***  Reorder JCDimsOrder2
  if (RACDRel2 <> RACDRel1) or UseCDCors then
    for i := 0 to SUDCDimsCount - 1 do
      SortBuf[i] := JCDimsOrder2[TN_UDBase(PP[i]).Marker];
  Move( SortBuf[0], JCDimsOrder2[0], BufLength );
  if UseCDCors then begin
//***  Reorder JUDCDCors
    for i := 0 to SUDCDimsCount - 1 do
      SortBuf[i] := Integer(JUDCDCors[TN_UDBase(PP[i]).Marker]);
    Move( SortBuf[0], JUDCDCors[0], BufLength );
  end;

  RestoreCDimsMarkers;
end; // end of TK_CDRelCtrl.BuildCDimsIntersection

//**************************************** TK_CDRelCtrl.BuildRACDRelsQAInds
// Build Qery Acceleration Indices
//
function TK_CDRelCtrl.BuildRACDRelsQAInds : Boolean;
var
  SUDCDimsCount : Integer;
begin
  Result := BuildCDimsIntersection() = 0;
  if not Result then Exit;
  SUDCDimsCount := Length(JCDimsOrder1);
  //*** Get RACDRel2 QUAIndex
  QAWidth := K_GetRACDRelQAIndex( QAIndex2, RACDRel2, @JCDimsOrder2[0], SUDCDimsCount, @JUDCDCors[0] );
  if RACDRel2 <> RACDRel1 then
  //*** Get RACDRel1 QUAIndex
    K_GetRACDRelQAIndex( QAIndex1, RACDRel1, @JCDimsOrder1[0], SUDCDimsCount );
end; // end of TK_CDRelCtrl.BuildRACDRelsQAInds

//**************************************** TK_CDRelCtrl.BuildRACDRels1To2CInds
// Build Correlation Indices from RACDims Relation1 to Relation2
// Correlation Indices RInds Count is Equal to Relation2 Tuples Count
//    j := RInds[i], Tuple Relation1[j] -> Tuple Relation2[i]
//
function TK_CDRelCtrl.BuildRACDRels1To2CInds( RInds: PInteger ): Boolean;
begin
  Result := BuildRACDRelsQAInds();
  if not Result or (RACDRel2 = RACDRel1) then Exit;
//*** Prepare RACDRel1 to RACDRel2 Correspondence Indices
  K_BuildRACDRelCorInds( RInds, QAWidth, RACDRel1, QAIndex1, RACDRel2, QAIndex2 );
end; // end of TK_CDRelCtrl.BuildRACDRels1To2CInds

//**************************************** TK_CDRelCtrl.BuildCDRels1To2CInds
// Build Correspondence Indices from CDims Relation1 to Relation2
// Correspondence Indices (RInds) Count is Equal to Relation2 Tuples Count
//    Relation1[RInds[i]] Tuple -> Relation2[i] Tuple
//
function TK_CDRelCtrl.BuildCDRels1To2CInds( CDRel1, CDRel2: TObject;
                                            RInds: PInteger ): Boolean;
  function GetRACDRel( Obj : TObject ) : TK_RArray;
  var
    TypeName : string;
  begin
    Result := nil;
    if Obj is TK_RArray then begin
      Result := TK_RArray(Obj);
      TypeName := K_GetElemTypeName( Result.ArraySType );
      if (TypeName <> 'TK_CDRel') and (TypeName <> 'TK_CSDim') then
        Result := nil;
    end else if (Obj is TK_UDCSDim) or (Obj is TK_UDCDRel) then
      RACDRel1 := TK_UDCSDim(Obj).R;
  end;

begin
  // Prepare RACDrel Fields
  Result := false;
  RACDRel1 := GetRACDRel( CDRel1 );
  if RACDRel1 = nil then Exit;
  UDCDims1Count := K_GetRACDRelPUDCDims( RACDRel1, PUDCDims1 );
  RACDRel2 := GetRACDRel( CDRel2 );
  if RACDRel2 = nil then Exit;
  UDCDims2Count := K_GetRACDRelPUDCDims( RACDRel2, PUDCDims2 );
  Result := BuildRACDRels1To2CInds( RInds );
end; // end of TK_CDRelCtrl.BuildCDRels1To2CInds

//**************************************** TK_CDRelCtrl.RestoreCDimsMarkers
//
procedure TK_CDRelCtrl.RestoreCDimsMarkers;
var
  i : Integer;
begin
  for i := 0 to High(AllUDCDims) do begin
    AllUDCDims[i].Marker := AllUDCDMarkers[i];
  end;
end; // end of TK_CDRelCtrl.RestoreCDimsMarkers

//**************************************** TK_CDRelCtrl.ClearCDimsMarkers
//
procedure TK_CDRelCtrl.ClearCDimsMarkers;
var
  i : Integer;
begin
  for i := 0 to High(AllUDCDims) do begin
    AllUDCDims[i].Marker := 0;
  end;
end; // end of TK_CDRelCtrl.ClearCDimsMarkers

//**************************************** TK_CDRelCtrl.SaveCDimsMarkers
//
procedure TK_CDRelCtrl.SaveCDimsMarkers;
var
  i, CMarker, j, AllCount : Integer;
  WUDCD : TN_UDBase;

  procedure AddUDCDims( PUDCDims : TN_PUDBase; Count : Integer );
  var
    i : Integer;
  begin
    for i := 0 to Count - 1 do begin
      CMarker := PUDCDims^.Marker;
      if (CMarker > 0)         and
         (CMarker <= AllCount) and
         (AllUDCDims[CMarker-1] = PUDCDims^) then Continue;
      AllUDCDims[j] := PUDCDims^;
      AllUDCDMarkers[j] := CMarker;
      PUDCDims^.Marker := j;
      Inc(PUDCDims);
      Inc(j);
    end;
  end;

begin
  AllCount := UDCDims1Count;
  if (RACDRel2 <> RACDRel1) then
    AllCount := AllCount + UDCDims2Count;
  AllCount := AllCount + 2 * Length(UDCDCors);

  SetLength( AllUDCDims, AllCount );
  SetLength( AllUDCDMarkers, AllCount );
  FillChar( AllUDCDims[0], AllCount * SizeOf(TN_UDBase), 0 );
  j := 0;
  AddUDCDims( PUDCDims1, UDCDims1Count );

  if (RACDRel2 <> RACDRel1) then
    AddUDCDims( PUDCDims2, UDCDims2Count );
  for i := 0 to High(UDCDCors) do begin
    WUDCD := TK_UDCDCor(UDCDCors[i]).GetPrimCDim;
    AddUDCDims( @WUDCD, 1 );
    WUDCD := TK_UDCDCor(UDCDCors[i]).GetSecCDim;
    AddUDCDims( @WUDCD, 1 );
  end;
  SetLength( AllUDCDims, j );
  SetLength( AllUDCDMarkers, j );
  ClearCDimsMarkers;
end; // end of TK_CDRelCtrl.SaveCDimsMarkers

{*** end of TK_CDRelCtrl ***}

end.
