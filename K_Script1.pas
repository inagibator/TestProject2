unit K_Script1;
//SPL nterpreter 

// SPL base classes
// type TK_CSPLCont = class( TObject ) // ***** Base class for Global contexts
// type TK_RArray   = class;                   // SPL Records Array
// type TK_UDRArray = classclass( TN_UDBase ); // UDBase Cover for SPL Records Array (SPL Class)
// type TK_UDFieldsDescr = class( TN_UDBase )  // SPL Record Fields Description
// type TK_UDProgramItem = class( TN_UDBase )  // UDBase with Params
// type TK_UDStringList = class( TN_UDBase ) //*** StringList User Data
// type TK_UDUnit = class( TK_UDStringList ) //*** Program Unit User Data
// type TK_UDFilterExtType = class( TK_UDFilterItem ) //

interface
uses Windows, Classes, SysUtils, inifiles, ActiveX, Graphics,
     N_ClassRef, N_Types, N_Lib1, N_Gra0, N_Gra1, N_GRa2, N_BaseF,
     K_VFunc, K_UDT1, K_SBuf, K_STBuf, K_IWatch, K_CLib0,
     K_Types, K_parse, K_BArrays;



//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_ValueToStrFlags
//****************************************************** TK_ValueToStrFlags ***
// SPL value to string convertion flags
//
type TK_ValueToStrFlags = set of (
  K_svsShowName // show fields name flag
  );

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_SPLTypeNameError
type TK_SPLTypeNameError = class(Exception);
//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_SPLTypePathError
type TK_SPLTypePathError = class(Exception);
//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_SPLRunTimeError
type TK_SPLRunTimeError = class(Exception);

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RTEInfo
//************************************************************** TK_RTEInfo ***
// SPL Runtime Exception Info
//
type TK_RTEInfo = record
  RTEFlag: Integer;               // RunTime Exception Flag  <> 0
  RTEMessage: string;             // RunTime Exception Message
  RTEUnit: TN_UDBase;             // RunTime Exception Unit
  RTERoutineName: string;         // RunTime Exception Routine Name
  RTEOpNumber: Integer;           // RunTime Exception Runtime Operator number
  RTETextPos: Integer;            // RunTime Exception Program Text Position
  RTETextSize: Integer;           // RunTime Exception Program Text Size
end;

//*****************************************
//********  GLobal Execute Context  *******
//*****************************************

//********************************************************* TK_ExprTypeFlags ***
// SPL runtime Type Flags structure
//
type TK_ExprTypeFlags = packed record
    case Integer of
  0: ( TFlags : Byte; // Type Flags
       CFlags : Byte; // Class Flags
       Res    : Byte; // Reserved
       IFlags : Byte; // Interpreter Flags
     );
  1: ( All    : Integer; );// Class Flags + Type Flags + ExprCode Flags
end;

type TK_NotifyFunc = function( Params : Pointer = nil; ParamsType : Int64 = 0 ) : Integer;

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_MoveDataFlags
//******************************************************** TK_MoveDataFlags ***
// Move SPL data structure flags
//
type TK_MoveDataFlags  = set of (
  K_mdfCountUDRef,      // permit IDB objects references counting flag
  K_mdfCopyRAElems,     // copy embedded SPL arrays (TK_RArray) elements flag 
                        // (not replace array reference)
  K_mdfCopyRArray,      // replace destination SPL array object (TK_RArray) by 
                        // source array object copy flag
  K_mdfFreeDest,        // free destination SPL data structure before copy flag
  K_mdfFreeAndFullCopy  // full data copy flag (is equal to [K_mdfCountUDRef, 
                        // K_mdfCopyRArray, K_mdfFreeDest])
);

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_CompDataFlags
//******************************************************** TK_CompDataFlags ***
// Compare SPL data structure flags
//
type TK_CompDataFlags  = set of (
  K_cdfCompareUDTree, // compare corresponding IDB subnets flag
  K_cdfBuildErrList   // build data compare errors list flag
 );

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_CreateRAFlags
//******************************************************** TK_CreateRAFlags ***
// Create new SPL records array flags
//
type TK_CreateRAFlags  = set of (
  K_crfCountUDRef,        // create object which counts IDB objects references 
                          // flag
  K_crfNotCountUDRef,     // create object which skip IDB objects references 
                          // counting flag
  K_crfSaveElemTypeRAFlag // save array flag in given SPL type code in SPL 
                          // records array creating routines
);

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_SetVArrayFlags
//******************************************************* TK_SetVArrayFlags ***
// Set new value to SPL VArray field flags
//
type TK_SetVArrayFlags = set of (
  K_svrCountUDRef, // permit IDB objects references counting flag if VArray new 
                   // value is IDB object
  K_svrAddRARef    // permit SPL array references counting flag  if VArray new 
                   // value is SPL array (TK_RArray) object
);

const
K_ExprStackSize = 1000;

const //
K_gcDebMode      = $00000020;
K_gcTraceInto    = $00000001;
K_gcStepOver     = $00000002;
K_gcRunToReturn  = $00000004;
K_gcBreakExec    = $00000010;
K_gcRunFlags     = $0000000F;
K_gcDebFlags     = $0000003F;

//*****************************************
//********    SPL Base Types Info   *******
//*****************************************

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_SPLVarType
//*********************************************************** TK_SPLVarType ***
// SPL build in data types enumeration
//
type TK_SPLVarType = (
  nptNotDef,    // not define data type
  nptByte,      // one-byte unsigned integer
  nptInt2,      // two-byte signed integer
  nptInt,       // four-byte signed integer
  nptHex,       // four-byte unsigned integer (actual for data view/edidt)
  nptColor,     // four-byte unsigned integer (actual for data view/edidt)
  nptInt1,      // one-byte signed integer
  nptUInt2,     // two-byte unsigned integer
  nptUInt4,     // four-byte unsigned integer
  nptInt64,     // eight-byte signed integer
  nptDouble,    // eight-byte floating-point
  nptFloat,     // four-byte floating-point
  nptString,    // string (Pascal string)
  nptIPoint,    // two integers (X, Y)
  nptIRect,     // four integers (Left, Top, Right, Bottom)
  nptDPoint,    // two doubles (X, Y)
  nptDRect,     // four doubles (Left, Top, Right, Bottom)
  nptFPoint,    // two floats (X, Y)
  nptFRect,     // four floats (Left, Top, Right, Bottom)
  nptTDate,     // Pascal TDate (actual for data view/edidt)
  nptTDateTime, // Pascal TDateTime (actual for data view/edidt)
  nptType,      // SPL type code
  nptUDType,    // IDB object type code
  nptUDRef,     // IDB object reference
  nptNoData     // impossible SPL type (next after last possible)
);

const
  K_MaxParamInd = 100;
//K_MaxParValueSize: integer = 3500;
//************ Param Type Names
  K_SPLTypeNames: array [0..Ord(nptNoData)] of string =
    ( 'Undef', 'Byte', 'Short', 'Integer', 'Hex', 'Color',
      'Int1', 'UInt2', 'UInt4', 'Int64',
      'Double', 'Float', 'String',
      'TPoint', 'TRect',
      'TDPoint', 'TDRect',
      'TFPoint', 'TFRect',
      'TDate', 'TDateTime',
      'TypeCode', 'UDTypeCI',
      'TN_UDBase',
      'NoData' );

  K_SPLTypeAliases: array [0..Ord(nptNoData)] of string =
    ( 'Undef Type', 'Byte', 'Short', 'Integer', 'Hex', 'Color',
      'Int1', 'UInt2', 'UInt4', 'Int64',
      'Double', 'Float', 'String',
      'TPoint', 'TRect',
      'TDPoint', 'TDRect',
      'TFPoint', 'TFRect',
      'TDate', 'TDateTime',
      'SPL Type Code', 'UDBase Type Index',
      'UDRef',
      'No Data'
     );

  K_SPLFuncTypes: array [0..Ord(nptNoData)] of Integer =
    ( Ord(nptNotDef), Ord(nptByte), Ord(nptInt2), Ord(nptInt), Ord(nptInt), Ord(nptInt),
      Ord(nptInt1), Ord(nptUInt2), Ord(nptUInt4), Ord(nptInt64),
      Ord(nptDouble), Ord(nptFloat), Ord(nptString),
      Ord(nptIPoint), Ord(nptIRect),
      Ord(nptDPoint), Ord(nptDRect),
      Ord(nptFPoint), Ord(nptFRect),
      Ord(nptTDate),  Ord(nptTDateTime),
      Ord(nptType), Ord(nptUDType),
      Ord(nptUDRef),
      Ord(nptNoData)
    );

  K_DataParamTypesFromSPL: array [0..Ord(nptNoData)] of TK_ParamType =
    ( K_isUndefinedData, K_isUInt1, K_isInt2, K_isInteger, K_isHex, K_isHex,
      K_isInt1, K_isUInt2, K_isUInt4, K_isInt64,
      K_isDouble, K_isFloat, K_isString,
      K_isUndefinedData, K_isUndefinedData,
      K_isUndefinedData, K_isUndefinedData,
      K_isUndefinedData, K_isUndefinedData,
      K_isDate, K_isDateTime,
      K_isInt64, K_isInteger,
      K_isUDPointer,
      K_isUndefinedData
    );

  K_DataVariantTypesFromSPL: array [0..Ord(nptNoData)] of word =
    ( VT_VOID, VT_UI1, VT_I2, VT_I4, VT_I4, VT_I4,
      VT_I1, VT_UI2, VT_UI4, VT_I8,
      VT_R8, VT_R4, VT_BSTR,
      VT_ILLEGAL, VT_ILLEGAL,
      VT_ILLEGAL, VT_ILLEGAL,
      VT_ILLEGAL, VT_ILLEGAL,
      VT_DATE, VT_DATE,
      VT_I8, VT_UI4,
      VT_VOID,
      VT_ILLEGAL
    );


//************ Array Type UDBase Inds
//  K_DataArrayUDInds: array [0..(Ord(nptNoData)-1)] of Integer =
//    ( 0, K_UDBArrayCI, 0, K_UDIArrayCI, K_UDIArrayCI, K_UDIArrayCI,
//      K_UDBArrayCI, 0, K_UDIArrayCI, 0,
//      K_UDDArrayCI, K_UDFArrayCI, K_UDSArrayCI,
//      K_UDIPArrayCI, K_UDIRArrayCI,
//      K_UDDPArrayCI, K_UDDRArrayCI,
//      K_UDFPArrayCI, K_UDFRArrayCI,
//      K_UDDArrayCI, {UDRef} 0, {VarArray} 0,
//      {Type} 0, {UDType} 0  );

  K_DataElementSize: array [0..Ord(nptNoData)] of Integer =
    ( SizeOf(Pointer), SizeOf(Byte), SizeOf(Short), SizeOf(Integer), SizeOf(Integer), SizeOf(Integer),
      SizeOf(Byte), SizeOf(Short), SizeOf(Integer), SizeOf(Int64),
      SizeOf(Double), SizeOf(Float), SizeOf(string),
      SizeOf(TPoint), SizeOf(TRect),
      SizeOf(TDPoint), SizeOf(TDRect),
      SizeOf(TFPoint), SizeOf(TFRect),
      SizeOf(TDateTime), SizeOf(TDateTime),
      SizeOf(Int64), SizeOf(Integer),
      SizeOf(TN_UDBase),
      0
    );

  K_DataParamTypesToSPL: array [0..Ord(K_isHex16)] of TK_SPLVarType =
    (
      nptInt,    // K_isInteger,  // Integer element of data vector
      nptString, // K_isString,   // String element of data vector
      nptDouble, // K_isDouble,   // Double element of data vector
      nptByte,   // K_isUInt1,    // Byte element of data vector
      nptInt2,   // K_isInt2,     // Short element of data vector
      nptInt64,  // K_isInt64,    // Int64 element of data vector
      nptHex,    // K_isHex,      // Integer element of data vector Hex visualised
      nptInt,    // K_isBool,     // Boolean element of data vector
      nptInt1,   // K_isInt1,     // SmallInt element of data vector
      nptUInt2,  // K_isUInt2,    //  Word element of data vector
      nptUInt4,  // K_isUInt4,    //  LongWord element of data vector
      nptFloat,  // K_isFloat,    // Single element of data vector
      nptTDate,  // K_isDate,     // Date value
      nptTDateTime, // K_isDateTime,     // Date value
      nptUDRef,  // K_isUDPointer // Pointer to TN_UDBase object
      nptInt,    // K_isIntegerArray,  // Integer element of data vector
      nptString, // K_isStringArray,   // String element of data vector
      nptDouble, // K_isDoubleArray,   // Double element of data vector
      nptByte,   // K_isUInt1Array,    // Byte element of data vector
      nptInt2,   // K_isInt2Array,     // Short element of data vector
      nptInt64,  // K_isInt64Array,    // Int64 element of data vector
      nptHex,    // K_isHexArray,      // Integer element of data vector Hex visualised
      nptInt,    // K_isBoolArray,     // Boolean element of data vector
      nptInt1,   // K_isInt1Array,     // SmallInt element of data vector
      nptUInt2,  // K_isUInt2Array,    //  Word element of data vector
      nptUInt4,  // K_isUInt4Array,    //  LongWord element of data vector
      nptFloat,  // K_isFloatArray,    // Single element of data vector
      nptTDate,  // K_isDateArray,     // Date value
      nptTDateTime,  // K_isDateTimeArray, // DateTime value
      nptNotDef, // K_isUndef,   // Undefined data
      nptInt64   // K_isHex16    // Int64 element of data vector
    ); //*** end of TK_ParamType = enum

  K_VATypetoSPL : array [0..(VT_I8)] of TK_SPLVarType =
   (  nptNotDef, //VT_EMPTY           = 0;   { [V]   [P]  nothing                     }
      nptNotDef, //VT_NULL            = 1;   { [V]        SQL style Null              }
      nptInt2,   //VT_I2              = 2;   { [V][T][P]  2 byte signed int           }
      nptInt,    //VT_I4              = 3;   { [V][T][P]  4 byte signed int           }
      nptFloat,  //VT_R4              = 4;   { [V][T][P]  4 byte real                 }
      nptDouble, //VT_R8              = 5;   { [V][T][P]  8 byte real                 }
      nptNotDef, //VT_CY              = 6;   { [V][T][P]  currency                    }
      nptTDate,  //VT_DATE            = 7;   { [V][T][P]  date                        }
      nptString, //VT_BSTR            = 8;   { [V][T][P]  binary string               }
      nptNotDef, //VT_DISPATCH        = 9;   { [V][T]     IDispatch FAR*              }
      nptNotDef, //VT_ERROR           = 10;  { [V][T]     SCODE                       }
      nptInt,    //VT_BOOL            = 11;  { [V][T][P]  True=-1, False=0            }
      nptNotDef, //VT_VARIANT         = 12;  { [V][T][P]  VARIANT FAR*                }
      nptNotDef, //VT_UNKNOWN         = 13;  { [V][T]     IUnknown FAR*               }
      nptNotDef, //VT_DECIMAL         = 14;  { [V][T]   [S]  16 byte fixed point      }
      nptNotDef, //                   = 15;
      nptInt1,   //VT_I1              = 16;  {    [T]     signed char                 }
      nptByte,   //VT_UI1             = 17;  {    [T]     unsigned char               }
      nptUInt2,  //VT_UI2             = 18;  {    [T]     unsigned short              }
      nptUInt4,  //VT_UI4             = 19;  {    [T]     unsigned long               }
      nptInt64   //VT_I8              = 20;  {    [T][P]  signed 64-bit int           }
    );

//*********************************************
//************ Expressions Data ****************
//*********************************************
const
//*** SPL Processor Command Type Flags (IFlags)
  K_ectRoutine      = $80; // Code Element  - function
  K_ectSpecial      = $40; // Special Interpretor Actions
  K_ectDataShift    = $20; // Data Shift to Base address - flag
  K_ectDataLiteral  = $10; // Data Base Address - Stack or Literal Buffer
  K_ectDataDirect   = $08; // DataBuf External data - flag
  K_ectVarPtr       = $04; // Variable Pointer Flag
  K_ectClearIFlags  = $00FFFFFFFFFFFFFF;
  K_ectClearFIFlags = $00FFFFFF;
  K_ectClearICFlags = $000000FFFFFFFFFF;

//*** Special Action Codes
  K_saAllocResult    = 0;  // - Alloc Space for Result parameter in Expression Stack
  K_saExit           = 1;  // "Exit" - Exit from Routine Code Addres
  K_saGoto           = 2;  // "Goto"   Code Addres
  K_saLGoto          = 3;  // "Goto"   Label Index
  K_saIfGoto         = 4;  // "IfGoto" Code Addres
  K_saDeb            = 5;  // "Deb"    Code Addres
  K_saPutLastCreated = 6;  // - Put Last Created Instance to Stack

//*** Data Common Type Flags (TFlags)
  K_ffPPointer         = $80;
  K_ffPointer          = $40;
  K_ffRoutine          = $20;   // Routine Parameters Record Description Flag
  K_ffClassMethod      = $10;   // Class Method Parameters Record Description Flag
  K_ffUDRARef          = $08;   // Class Constructor Result Flag
//  K_ffClassConstructor = $04;
  K_ffVArray           = $02;
  K_ffArray            = $01;

  K_ffFlagsMask        = $FF and not (K_ffArray or K_ffVArray);
  K_ffPointerMask = K_ffPointer or K_ffPPointer;
  K_ffPointerArrayMask = K_ffArray or K_ffPointerMask;
//  K_ffRoutineMask = K_ffRoutine or K_ffClassMethod or K_ffClassEx or K_ffClassConstructor;
//  K_ffRoutineMask = K_ffRoutine or K_ffClassMethod or K_ffClassConstructor;
  K_ffRoutineMask = K_ffRoutine or K_ffClassMethod;
  K_ffCompareTypesMask1 = $00FF0000FFFFFFFF;
  K_ffCompareTypesMask  = $000000FFFFFFFFFF;

//*** Data Instance Type Flags (CFlags)
  K_ccFlagsShift        = 8;   // cc Flags Shift in AllFlags Field
  K_ccRuntime          = $80; // Class Field is actual only at runtime (Not Saved Field)
  K_ccObsolete          = $40; // Class Field is Obsolete
  K_ccVariant           = $20; // Class Field is Variant - old field version used for compatibiliti
  K_ccPrivate           = $10; // Class Field is Private
//  K_ccFlagsMask         = K_ccRuntime or K_ccObsolete or K_ccVariant or K_ccPrivate;
  K_ccFlagsMask         = K_ccObsolete or K_ccVariant or K_ccPrivate;
  K_efcFlagsMask0       = K_ccFlagsMask shl K_ccFlagsShift;
  K_ecfFlagsMask1       = K_ccObsolete  shl K_ccFlagsShift;
  K_ecfFlagsMask2       = K_ffFlagsMask or K_ecfFlagsMask1;

  K_ccStopCountUDRef    = $02; // Class Field - prevent Count UDRef for Type fields
  K_ccCountUDRef        = $01; // Class Field - Class Object is UDRArray Member - count UDReferences

//*** Special Expression Function Codes
  K_ExprNCLSFuncCI            = 0; // Clear Expression Stack
  K_ExprNSetFuncCI            = 1; // Set Variable Value from Stack
  K_ExprNValFuncCI            = 2; // Change Pointer to Value in Expression Stack
  K_ExprNSetLengthFuncCI      = 3; // Set Array Length
  K_ExprNSumIntsFuncCI        = 4; // Sum Integers
  K_ExprNCallRoutineFuncCI    = 5; // Call Routine
  K_ExprNArrayElementFuncCI   = 6; // Get Array Element Pointer
  K_ExprNCreateInstanceFuncCI = 7; // Create Object Instance
  K_ExprNCallMethodFuncCI     = 8; // Call Class Method
  K_ExprNGetInstanceFuncCI    = 9; // Get Class Object Pointer
  K_ExprNSubArrayFuncCI       =10; // Create SubArray
  K_ExprNUDCreateFuncCI       =11; // Create UDBase
  K_ExprNSetElemFuncCI        =12; // Set Array Elements
  K_ExprNMoveFuncCI           =13; // Move Bytes
//*****************************************
//************    SPL Common    ***********
//*****************************************

const
  K_ffChildNum = 1000;

type TK_RArray   = class; // forvard reference
{type} TK_UDRArray      = class; // forvard reference
{type} TK_UDProgramItem = class; // forvard reference
{type} TK_UDFieldsDescr = class; // forvard reference


//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_ExprType
//************************************************************* TK_ExprType ***
// SPL runtime Type code structure
//
{type} TK_ExprType = packed record
  TCode  : Integer;  // Type Code
  TFlags : Byte;     // Type Flags
  CFlags : Byte;     // Class Flags
  Res    : Byte;     // Reserv
end;
{type} TK_ExprExtType = packed record
    case Integer of
  0: ( D      : TK_ExprType;      // Type
       IFlags : Byte;             // Interpreter Flags
     );
  1: ( DTCode : Integer;          // Type Code
       EFlags : TK_ExprTypeFlags; // All Flags
      );
  2: ( All    : Int64; );         // Type Code + Type Flags + ExprCode Flags
  3: ( FD : TK_UDFieldsDescr; )   // Reference to Type Fields Description
end;
{type} TK_PExprExtType = ^TK_ExprExtType;
{type} TK_EETArray = array of TK_ExprExtType;

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RLSDataFlags
//********************************************************* TK_RLSDataFlags ***
// View/Edit objects root level source SPL data flags
//
{type} TK_RLSDataFlags = set of (
  K_rlsdSkipBuffering // skip data buffering in view/edit objects flag
);
//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RLSData
//************************************************************** TK_RLSData ***
// View/Edit objects root level source SPL data info
//
{type} TK_RLSData = record
   RDFlags    : TK_RLSDataFlags; // Root Level Source Data Flags
   RDType     : TK_ExprExtType;  // Root Level Source Data Type
   RPData     : Pointer;         // Root Level Source Data Pointer
   RUDRArray  : TK_UDRArray;     // Root Level Source Data UDRarray Container
   RUDParent  : TN_UDBase;       // Root Level Source Data UDRarray Container 
                                 // UDParent
   UAData     : LongWord;        // User Additional Data Edit Context
end;
{type} TK_PRLSData = ^TK_RLSData;


//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_OneFieldDescr
//******************************************************** TK_OneFieldDescr ***
// SPL complex type element (record field, enum element etc.) description 
// structure
//
{type} TK_OneFieldDescr = record
  FieldName    : string;         // Field Name
  FieldPos     : Integer;        // Field Position
  FieldSize    : Integer;        // Field Size
  FieldType    : TK_ExprExtType; // Field Type:
                                 //#F
                                 //  if field has simple (build in type)  - SPL base type code
                                 //  if field has copmplex (SPL defined type) - K_ffChildNum + Fields Description
                                 //     Child Object number (reference to SPL type description object)
                                 //#/F
  FieldDefValue: string;         // Field Default Value
end; // TK_OneFieldDescr = record
{type} TK_FDArray = array of TK_OneFieldDescr; // Record Fields Description


//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_OneFieldExecDescr
//**************************************************** TK_OneFieldExecDescr ***
// SPL runtime record field description structure
//
{type} TK_OneFieldExecDescr = record //***** One Program Data Item Description
  DataName    : string;        // Data Identifier
  DataPos     : Integer;       // Position in data structure
  DataSize    : Integer;       // Field Size
  DataType    : TK_ExprExtType;// SPL runtime Type code
//##/*
  DataTextPos : Integer;       // Unit Text Position
//##*/
end; // TK_OneFieldExecDescr = record
{type} TK_POneFieldExecDescr = ^TK_OneFieldExecDescr; // Pointer to One Field Exec Description

{type} TK_FDEArray = array of TK_OneFieldExecDescr; // Record Fields Exec Description

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_DescrType
//************************************************************ TK_DescrType ***
// SPL complex type category enumeration
//
{type} TK_DescrType = (
  K_fdtRecord,           // SPL record fields descrition
  K_fdtTypeDef,          // SPL type definition (type NewTypeName = OldTypeName)
  K_fdtRoutine,          // SPL routine parameters description
  K_fdtClassConstructor, // SPL class constructor parameters description
  K_fdtClass,            // SPL class fields and methods description
  K_fdtEnum,             // SPL enumeration elements description
  K_fdtSet               // SPL set elements description
);

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_FFieldsTypeFlagSet
//*************************************************** TK_FFieldsTypeFlagSet ***
// SPL complex type elements composition flags set
//
{type} TK_FFieldsTypeFlagSet = set of (
  K_fftUDRefs,  // type contains fields with IDB objects references
  K_fftStrings  // type contains fields with string values
);

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_ExprCallStackItem
//**************************************************** TK_ExprCallStackItem ***
// SPL program interpreter stack item structure
//
{type} TK_ExprCallStackItem = packed record
  ProgItem : TK_UDProgramItem;// Current Execute TK_UDProgramItem
  CallPos  : Integer;         // Current Exucute Position
end;


{type} TK_ExprCallStack = array of TK_ExprCallStackItem; // Call Stack Items Array


//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_CSPLCont
//************************************************************* TK_CSPLCont ***
// SPL program interpreter global context structure
//
{type} TK_CSPLCont = class( TObject )
  RefCount: Integer;                // context references conter
  FlagSet : Integer;                // SPL Execute Flags
  SPLGCDumpWatch : TK_InfoWatch;    // Dump Watch Object
  ScriptShowMessage : TK_MVShowMessageProc; // reference to external show info 
                                            // messages routine

//*** Current Execute Context
  ExprCallStackLevel : Integer;     // routines call stack current position
  ExprCallStack : TK_ExprCallStack; // routines call stack  (array of routines 
                                    // call stack elements)

//*** Exrpession stack
  ExprStackLevel   : Integer;     // expressions stack current position
  ExprStackCapacity: Integer;     // expressions stack capacity
  ExprStack        : TN_BArray;   // expressions stack (array of bytes)
  ExecFuncType     : TK_ExprExtType; // Type of Current Executed Routine
  LocalUDRoot   : TN_UDBase;         // Root for temporary created IDB objects
  RTE: TK_RTEInfo;                   // RunTime Exception Info
//##/*
  constructor Create;
  destructor  Destroy; override;
//##*/
  function  AAddRef : TK_CSPLCont;
  function  ARelease : Boolean;
  procedure PutDataToExprStack  ( const AData; ADType : Int64 );
  procedure GetDataFromExprStack( var AData; var ADType : Int64 );
  function  GetPointerToExprStackData( var APData : Pointer;
                                       var ADType : Int64 ) : Integer;
  function  GetPointerToExprStackRecord( ADSize : Integer ) : Pointer;
  procedure TimerEvent( ASender: TObject);
  procedure SelfShowDump( const ADumpLine: string; AMesStatus : TK_MesStatus = K_msInfo);

end; // type TK_CSPLCont = class( TObject )

{type} TK_ExprFunc = procedure( GC : TK_CSPLCont );

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr
//******************************************************** TK_UDFieldsDescr ***
// SPL complex type (record, enum, set etc.) description object (IDB object)
//
{type} TK_UDFieldsDescr = class( TN_UDBase )
      public
  FDFieldsTypesFlags : TK_FFieldsTypeFlagSet; // SPL type elements composition 
                                              // flags set
  FDObjType     : TK_DescrType; // SPL type category enumeration
  FDUDClassInd  : Integer;      // SPL class IDB object type code (Class Index)
  FDRecSize     : Integer;      // SPL data size in bytes
  FDFieldsCount : Integer;      // number of SPL complex type elements (fields 
                                // in record, elements in enum etc.)
  FDCurFVer     : Integer;      // ñurrent Data/Format ìersion
  FDNDPTVer     : Integer;      // minimal Data/Format version for backward 
                                // CurData/PrevFormat compatibility
  FDPDNTVer     : Integer;      // minimal Data Version for forward 
                                // PrevData/CurFormat compatibility
  FDV  : TK_FDArray;            // SPL type elements (root level elements) 
                                // descriptions array
  FDVDE: TK_FDEArray;           // SPL record tree leaf fields descriptions 
                                // array (Runtime)
  FDSHE: THashedStringList;     // SPL record fields names hashed list
  FDUDRefsIndsList : TList;     // list of indexes (in FVDE) of fields with IDB 
                                // object references (UDRef)
//##/*
  //
  FDFUTListInd  : Integer;      // Index of type object in Serial Buf UsedTypesList (Runtime field)
  //
  constructor Create; override;
  destructor  Destroy; override;
//##*/
  procedure AddFieldsToSBuf   ( SBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( SBuf: TN_SerialBuf ); override;
  function  AddFieldsToText   ( ASBuf: TK_SerialTextBuf;
                                AAddObjFlags : Boolean = true ) : Boolean; override;
  function  GetFieldsFromText ( ASBuf: TK_SerialTextBuf ) : Integer; override;
  function  CompareData( const AData1, AData2; ASPath : string;
                         ACompFlags : TK_CompDataFlags = [] ) : Boolean;
  procedure CopyFields ( ASrcObj: TN_UDBase ); override;
  function  GetFieldUName( AInd : Integer ): string;
//**********
  function  CompareFuncTypes( ASrcFD : TK_UDFieldsDescr ) : Boolean;
  procedure InitData( var AData; AGC : TK_CSPLCont = nil );
  procedure AddDataToSBuf( var AData; ASBuf: TN_SerialBuf );
  procedure GetDataFromSBuf( var AData; ASBuf: TN_SerialBuf );
  procedure AddDataToSTBuf( var AData; ASBuf: TK_SerialTextBuf );
  procedure GetDataFromSTBuf( var AData; ASBuf: TK_SerialTextBuf );
  function  CreateUDInstance( ACount : Integer = 1 ) : TK_UDRArray;
  function  ValueFromString( var AData; ACText : string ) : string;
  function  ValueToString( const AData; AValueToStrFlags : TK_ValueToStrFlags = [];
                        ASTK : TK_Tokenizer = nil; AStrLen : Integer=0;
                        AFFLags : Integer = 0; AFMask : Integer = 0 ) : string;
  function  FieldsListToString( const AData; AFieldsList : TN_SArray;
              AValueToStrFlags : TK_ValueToStrFlags = [];
              AFFLags : Integer = 0; AFMask : Integer = 0 ) : string;
  procedure MoveData( const ASData; var ADData; AMDFlags : TK_MoveDataFlags = [] );
  procedure FreeData( var AData; ASInd : Integer = 0; ACountUDRef : Boolean = false );
  procedure ChangeFieldType ( AInd : Integer; AElemTypeCode : Integer;
                                                  AElemTypeFlags: Integer = 0 );
  function  IndexOfFieldDescr( AFieldName : string ): Integer;
//  procedure GetFieldsDefValueList( SL : TStrings; Inds : TN_IArray = nil );
  procedure GetFieldsDefValueList( ASL : TStrings; APInds : PInteger = nil;
                                   AIndsCount : Integer = 0 );
  function  GetFieldsExecDescr : TK_FDEArray;
  function  GetFieldDescrByInd( AInd : Integer) : TK_POneFieldExecDescr;
  function  GetFieldFullNameByInd( AInd : Integer) : string;
  procedure RefreshFieldsExecDescr;
  function  AddOneFieldDescr ( AElemName : string; AElemTypeCode : Integer;
                  AElemTypeFlags: Integer = 0; AElemPos : Integer = -1;
                  AElemSize : Integer = -1 ) : Integer;
//##/*
  procedure SaveToStrings   ( Strings: TStrings; Mode: integer ); override;
  function  GetFieldTypeText( Ind : Integer ): string;
      private
  procedure BuildFieldsExecDescr;
  function  AddFieldsExecDescr( SInd : Integer; PName : string;
                TypeCFlags : Byte; SShift : Integer; var AVDE : TK_FDEArray;
                ASHE: THashedStringList; AUDRefsIndsList : TList ) : Integer;
  procedure LinkFieldDescrType( Ind : Integer );
//##*/
end; // type TK_UDFieldsDescr = class( TN_UDBase )


//******************************************************** TK_RATestFieldFunc ***
// RArray fields scan routine type for tree-walk along fields tree
//
{type} TK_RATestFieldFunc = function( UDRoot : TN_UDBase; RARoot : TK_RArray;
                    var Field; FieldType : TK_ExprExtType; FieldName : string;
                    FieldPath : string; RowInd : Integer ) : TK_ScanTreeResult of object;
// UDRoot     - Fields SubTree Root UDRArray
// RARoot     - Fields SubTree Level RArray Root
// Field      - Testing Field
// FieldType  - Testing Field Type
// FieldName  - Testing Field Name (Path Last Segment)
// FieldPath  - Testing Field Full DB Path
// RowInd     - =-2 UDRArray Root Level RArray
//              =-1 RArray Attributes Field
//              >=0 RArray Main Data Elements (Row) Index

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray
//*************************************************************** TK_RArray ***
// Records Array Object - IDB User Data Container
//
{type} TK_RArray = class( TObject )
      public
    ElemSize : Integer;      // Element Size
    AttrsSize: Integer;      // Attributes Size
    HCol     : Integer;      // High Column Number
    FEType : TK_ExprExtType; // Element Type = Type Code + Complex (Complex, 
                             // Element, Attributes) Type Flage
    FADTCode : Integer;      // Attributes Data Type Code
    FCETCode : Integer;      // Complex Type Code
      private
    ElemCount: Integer;      // Elements Counter
    RefCount : Integer;      // Self References Counter (Needed in SPL programs,
                             // not in IDB structures)
      public
    VBuf: TN_BArray;         // Data Buffer (Array of Byte) constructor Create(

//  constructor Create( ESize : Integer; ASize : Integer = 0 ); overload;

  constructor CreateByType( ADType : Int64; ACount : Integer = 0 );
//##/*
  destructor  Destroy; override;
//##*/
  procedure ReorderElems( APInds : PInteger; AIndsCount : Integer ); overload;
  procedure ReorderElems( APOrderInds: PInteger; AOrderIndsCount : Integer;
                          APFreeInds: PInteger; AFreeIndsCount : Integer;
                          APInitInds: PInteger; AInitIndsCount : Integer ); overload;
  procedure SetElemsFreeFlag( AInd : Integer = 0; ACount : Integer = -1;
                              AClearMem : Boolean = false );
  function  InitElems( AInd : Integer = 0; ACount : Integer = -1 ) : Boolean;
  procedure FreeElemsData( AInd : Integer; ACount : Integer = -1 );
  procedure DeleteElems( AInd : Integer; ACount : Integer = 1 );
  procedure InsertElems( AInd : Integer = -1; ACount : Integer = 1 );
  procedure MoveElems( AIndD, AIndS : Integer; ACount : Integer = 1 );

  procedure ReorderRows( APOrderInds: PInteger; AOrderIndsCount : Integer;
                         APFreeInds: PInteger; AFreeIndsCount : Integer;
                         APInitInds: PInteger; AInitIndsCount : Integer );
  function  InitRows( AInd, ACount : Integer ) : Boolean;
  procedure FreeRowsData( AInd : Integer; ACount : Integer = -1 );
  procedure DeleteRows( AInd : Integer; ACount : Integer = 1 );
  procedure InsertRows( AInd : Integer = -1; ACount : Integer = 1 );
  procedure MoveRows( AIndD, AIndS : Integer; ACount : Integer = 1 );

  procedure ReorderCols( APOrderInds: PInteger; AOrderIndsCount : Integer;
                         APFreeInds: PInteger; AFreeIndsCount : Integer;
                         APInitInds: PInteger; AInitIndsCount : Integer );
  function  InitCols( AInd, ACount : Integer ) : Boolean;
  procedure FreeColsData( AInd : Integer; ACount : Integer = -1 );
  procedure DeleteCols( AInd : Integer; ACount : Integer = 1 );
  procedure InsertCols( AInd : Integer = -1; ACount : Integer = 1 );
  procedure MoveCols( AIndD, AIndS : Integer; ACount : Integer = 1 );

  procedure SetElems( var AData; AFillFlag : Boolean = true;
                      AInd : Integer = 0; ACount : Integer = -1;
                      ACopyArrays : Boolean = false );
  procedure TranspElems( );
  function  CompareData( ARA : TK_RArray; ASPath : string = '';
                         ACompFlags : TK_CompDataFlags = [] ): Boolean;
  function  PA : Pointer;
  function  PV : Pointer;
  function  P : Pointer; overload;
  function  P( AInd : Integer ) : Pointer; overload;
  function  PS( AInd : Integer ) : Pointer;
  function  PME( AICol, AIRow : Integer ) : Pointer;
  procedure SetCountUDRef;
  function  AHigh   : Integer;
  function  ALength : Integer; overload;
//  procedure ADimensions( out ColCount, RowCount : Integer );
  procedure ALength( out AColCount, ARowCount : Integer ); overload;
  function  AColCount : Integer;
  function  ARowCount : Integer;
  function  GetArrayType : TK_ExprExtType;
  function  GetAttrsType : TK_ExprExtType;
  function  GetElemType : TK_ExprExtType;
  procedure SetElemType( ADType : TK_ExprExtType );
  procedure SetComplexType( ACType : TK_ExprExtType );
  function  GetComplexType : TK_ExprExtType;
  function  ASetLength( ALength: Integer ) : Integer; overload;
  procedure ASetLengthI( ALength: Integer );
//  procedure ASetDimensions( RowLength, ColLength : Integer );
  procedure ASetLength( AColCount, ARowCount : Integer; AInitElemsFlag : Boolean = false ); overload;
  function  AAddRef : TK_RArray;
  procedure ARelease;
//*** Serialization/Deserialization
  procedure AddToSBuf   ( ASBuf: TN_SerialBuf );
  procedure GetFromSBuf ( ASBuf: TN_SerialBuf );
//  procedure AddToSTBuf( ASBuf: TK_SerialTextBuf; ATag : string = ''; ShowTypeName : Boolean = true );
  procedure AddToSTBuf( ASBuf: TK_SerialTextBuf; ATag : string = '' );
  procedure GetFromSTBuf( ASBuf: TK_SerialTextBuf; ATag : string = '' );
  function  ValueFromString( AText : string ) : string;
  function  ValueToString( ASTK : TK_Tokenizer;
              AValueToStrFlags : TK_ValueToStrFlags = []; AMaxLength : Integer=0;
              AFFLags : Integer = 0; AFMask : Integer = 0 ) : string;
  procedure SearchUDRefObjs( AUDRArray : TN_UDBase; AFName : string );
  function  ScanRAFields( AUDRArray : TK_UDRArray; AFName : string;
                          ATestFieldFunc : TK_RATestFieldFunc;
                          AFieldTypeVal : Int64 = 0; AFieldTypeMask : Int64 = 0 ) : TK_ScanTreeResult;
  function  GetRAFieldPointer( const AFieldName : string ) : Pointer;
//##/*
  function  EditByGEFunc( out WasEdited : Boolean;
                    DataCaption : string = ''; GEPrefix : string = '';
                    AOwnerForm : TN_BaseForm = nil;
                    AOnGlobalAction : TK_RAFGlobalActionProc = nil;
                    APRLSData : TK_PRLSData = nil;
                    ANotModalShow : Boolean = false  ) : Boolean;
//##*/
//  property  DType : TK_ExprExtType read GetEType write SetEType;
  function  GetAllTypes( var ACType: TK_ExprExtType;
                         out AElemType : TK_ExprExtType ) : TK_ExprExtType;
  property  ElemType   : TK_ExprExtType read GetElemType write SetElemType; ///
  property  ElemSType  : Integer read FEType.DTCode;        // Element Short 
                                                            // Type Code
  property  AttrsType  : TK_ExprExtType read GetAttrsType;  // Attributes Full 
                                                            // Type Code
  property  AttrsSType : Integer read FADTCode;             // Attributes Short 
                                                            // Type Code
  property  ArrayType  : TK_ExprExtType read GetArrayType;  // Records Array 
                                                            // Full Type Code
  property  ArraySType : Integer read FCETCode; // Records Array Short Type Code
  property  ARefCounter : Integer read RefCount;// Records Array References 
                                                // Counter

    private
  procedure SetTypeInfo( ACType: TK_ExprExtType );
  function  SetAttrsType( AttrsType : TK_ExprExtType ) : Boolean;
  function  CalcCount( AInd : Integer; var ACount : Integer ) : Boolean;
  function  CalcRowsCount( ARowInd : Integer; var  ARowCount, AColCount  : Integer ) : Boolean;
  function  CalcColsCount( AColInd : Integer; var  AColCount, ARowCount  : Integer ) : Boolean;
  function  CalcMoveInds( AIndS, AIndD, ACount : Integer;
                          out ABufInd, ASSInd, ADDInd, ABufSize : Integer ): Integer;
  procedure MoveElemValues( AIndS, AIndD, ASSInd, ADDInd, ABufSize, AMoveSize : Integer;
                            APBuf : Pointer );
end; //*** end of type TK_RArray = class( TObject )
{type} TK_PRArray = ^TK_RArray;
{type} TK_RAArray = array of TK_RArray;

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray
//************************************************************* TK_UDRArray ***
// IDB Object - Records Array Object container. Is base Pascal class for SPL 
// Class objects implementation
//
{type} TK_UDRArray = class( TN_UDBase )
      R: TK_RArray; // Records Array Object
      public
//##/*
  constructor Create; override;
  destructor  Destroy; override;
  function  BuildID( BuildIDFlags : TK_BuildUDNodeIDFlags ) : string; override;
//##*/
  function  PDE( AInd : Integer ) : Pointer; virtual;
  function  PDRA : TK_PRArray; virtual;
  function  AHigh   : Integer;
  function  ALength : Integer;
  procedure ASetLength( ALength: Integer );
  procedure ChangeElemsType( ANewElemTypeCode : Int64 ); virtual;
  procedure SPLInit( AEFD : TK_UDFieldsDescr = nil );
  procedure PascalInit; virtual;
  procedure InitByRTypeCode( ATypeCode : Int64; ALength : Integer = 1;
                                        ACallInitRoutine : Boolean = true );
  procedure OnLoadError( AErrStr : string );
  procedure AddFieldsToSBuf   ( ASBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( ASBuf: TN_SerialBuf ); override;
  function  AddFieldsToText( ASBuf: TK_SerialTextBuf;
                             AAddObjFlags : Boolean = true ) : boolean; override;
  function  GetFieldsFromText( ASBuf: TK_SerialTextBuf ) : Integer; override;
//##/*
  procedure SaveToStrings   ( Strings: TStrings; Mode: integer ); override;
//##*/
  procedure CopyFields ( ASrcObj: TN_UDBase ); override;
  function  Clone      ( ACopyFields : boolean = true ) : TN_UDBase; override;
  function  SameType( ACompObj: TN_UDBase ): boolean; override;
  function  CompareFields( ACompObj: TN_UDBase; AFlags: integer;
                           ANPath : string ) : Boolean; override;
  function  GetFieldsTypeFlagSet : TK_FFieldsTypeFlagSet;
  function  ScanSubTree( ATestNodeFunc : TK_TestUDChildFunc; ALevel : Integer = 0 ) : Boolean; override;
  function  ScanRAFields( ATestFieldFunc : TK_RATestFieldFunc;
                          AFieldTypeVal : Int64 = 0;
                          AFieldTypeMask : Int64 = 0 ) : TK_ScanTreeResult;
  procedure ClearSubTreeRefInfo( ARoot : TN_UDBase = nil; AClearRefInfoFlags : TK_ClearRefInfoFlags = [] ); override;
  procedure ReplaceSubTreeRefObjs( ); override;
  procedure ReplaceSubTreeNodes( ARepChildsArray : TK_BaseArray ); override;
  procedure BuildSubTreeRefObjs(  ); override;
//  procedure ReplaceSubTreeRelPaths( CurPath : string = ''; SL : TStrings = nil;
//              ObjNameType : TK_UDObjNameType = K_ontObjName ); override;
  procedure MarkSubTree( AMarkType : Integer = 0; ADepth : Integer = -1;
                         AField : Integer = -1 ); override;
  procedure UnMarkSubTree( ADepth : Integer = -1; AField : Integer = -1 ); override;
  function  GetPathToUDObj( ASrchObj : TN_UDBase;
                AObjNameType : TK_UDObjNameType = K_ontObjName ) : string; override;
  function  GetFieldPointer( const AFieldName : string ) : Pointer; override;
  function  IsSPLType( ATypeName : string ) : Boolean; override;
  procedure CallSPLClassConstructor( AConstructorName : string;
                                     AParams : array of const );
  procedure CallSPLClassMethod( AClassMethodName : string;
                          AParams : array of const; AGC : TK_CSPLCont = nil  );
//##/*
  function  CDimIndsConv( UDCD : TN_UDBase; PConvInds : PInteger;
                          RemoveUndefInds : Boolean ) : Boolean; override;
  procedure CDimLinkedDataReorder; override;
  function  ScanRAFieldsForCDimIndsConv( UDRoot : TN_UDBase; RARoot : TK_RArray;
                    var Field; FieldType : TK_ExprExtType; FieldName : string;
                    FieldPath : string; RowInd : Integer ) : TK_ScanTreeResult;
  function  ScanRAFieldsForCDimLinkedDataReorder( UDRoot : TN_UDBase; RARoot : TK_RArray;
                    var Field; FieldType : TK_ExprExtType; FieldName : string;
                    FieldPath : string; RowInd : Integer ) : TK_ScanTreeResult;
    private
  UDCDim: TN_UDBase;
  PUDCDimConvInds: PInteger;
  UDCDimRemoveUndefInds: Boolean;
//##*/

end; //*** end of type TK_UDRArray = class( TK_UDBase )
{type} TK_PUDRArray = ^TK_UDRArray;

//##/*
{type} TK_UDRAList = class( TK_UDRArray ) //*** UD Records Array User Data + Attrs List
      RAAttrList : TStringList;
      public
  constructor Create; override;
  destructor  Destroy; override;
  procedure AddFieldsToSBuf   ( SBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( SBuf: TN_SerialBuf ); override;
  function  AddFieldsToText( SBuf: TK_SerialTextBuf;
                                 AShowFlags : Boolean = true ) : boolean; override;
  function  GetFieldsFromText( SBuf: TK_SerialTextBuf ) : Integer; override;
  procedure CopyFields ( SrcObj: TN_UDBase ); override;
  function  Clone      ( ACopyFields : boolean = true ) : TN_UDBase; override;
  function  CompareFields( SrcObj: TN_UDBase; AFlags: integer;
                           NPath : string ) : Boolean; override;
end; //*** end of type TK_UDRAList = class( TK_UDBase )
{type} TK_PUDRAList = ^TK_UDRAList;

{type} TK_UDUnitData = class( TK_UDRArray ) //*** Unit Data Object
  destructor  Destroy; override;
end; //*** end of type TK_UDRAList = class( TK_UDRArray )
//##*/

//*****************************************
//************    SPL Common    ***********
//*****************************************

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDStringList
//********************************************************* TK_UDStringList ***
// IDB Object - Strings (TStringList) container
//
// Used as base class for SPL Uint
//
{type} TK_UDStringList = class( TN_UDBase )
      public
    SL: TStringList;      // User Defined Strings
    SaveLoadFlag : Byte;  // Strings Save and Load flag, if =TRUE (<>0) then 
                          // Strings are serialized and deserialized, if =FALSE 
                          // (=0) then Strings are actual only at runtime
//##/*
  constructor Create; override;
  destructor  Destroy; override;
//##*/
  procedure AddFieldsToSBuf   ( ASBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( ASBuf: TN_SerialBuf ); override;
  function  AddFieldsToText( ASBuf: TK_SerialTextBuf;
                                 AShowFlags : Boolean = true ) : boolean; override;
  function  GetFieldsFromText( ASBuf: TK_SerialTextBuf ) : Integer; override;
  procedure CopyFields ( ASrcObj: TN_UDBase ); override;
//##/*
  procedure SaveToStrings   ( Strings: TStrings; Mode: integer ); override;
//##*/
end; //*** end of type TK_UDStringList = class( TN_UDBase )

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDUnit
//*************************************************************** TK_UDUnit ***
// IDB Object - SPL Unit
//
{type} TK_UDUnit = class( TK_UDStringList ) //*** Program Unit User Data
      public
  CompilerErrMessage : string; //
//##/*
  constructor Create; override;
  destructor  Destroy; override;
//##*/
  procedure AddFieldsToSBuf   ( SBuf: TN_SerialBuf ); override;
//  procedure GetFieldsFromSBuf ( SBuf: TN_SerialBuf ); override;
  function  AddFieldsToText( ASBuf: TK_SerialTextBuf;
                             AAddObjFlags : Boolean = true ) : boolean; override;
  function  GetFieldsFromText( SBuf: TK_SerialTextBuf ) : Integer; override;
  function  GetGlobalData : TK_UDRArray;
  function  GetGlobalDataFD : TK_UDFieldsDEscr;
  function  GetUDProgramItem( AUDPIName : string ) : TK_UDProgramItem;
end; //*** end of type TK_UDUnit = class( TK_UDUnit )
{type} TK_PUDUnit = ^TK_UDUnit;

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_OneExprCode
//********************************************************** TK_OneExprCode ***
// SPL compiled bytecode single instruction
//
{type} TK_OneExprCode = packed record
  Code : Integer;         // SPL bytecode instruction Code
  EType : TK_ExprExtType; // SPL bytecode instruction Type + Flags
end;
{type} TK_ExprCodes = array of TK_OneExprCode;

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_OneExprDeb
//*********************************************************** TK_OneExprDeb ***
// SPL single program statement runtime description for program debugging
//
{type} TK_OneExprDeb = packed record
  CodePos   : Integer;  // SPL statement bytecode start position
  TextStart : Integer;  // SPL statement start text position in Unit
  TextSize  : Integer;  // SPL statement text size in Unit
end;
{type} TK_ExprDebugs = array of TK_OneExprDeb;

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDProgramItem
//******************************************************** TK_UDProgramItem ***
// IDB Object with compiled bytecode of single SPL routine (porcedure or 
// function)
//
{type} TK_UDProgramItem = class( TN_UDBase )
    public
  ParamsCount : Integer;        // routine parameters counter
  SourceUnit  : TK_UDUnit;      // reference to SPL Unit with routine Source 
                                // Code
  StartParNum : Integer;        // start parameter index (0 - for procedure, 1 -
                                // for function, 0-parameter for function is 
                                // Result)
  TextPos     : Integer;        // routine source code start position in SPL 
                                // Unit
  ExprCodeBuf : TK_ExprCodes;   // routine bytecode (array TK_OneExprCode)
  ExprDataBuf : TN_BArray;      // routine Literals
  ExprDebInfo : TK_ExprDebugs;  // routine debug info (array of TK_OneExprDeb)
  ExprLabels  : TN_IArray;      // routine labels info (array of label Code 
                                // Addresse - position in bytecode)
  ExprLabelsDI: TN_IArray;      // routine labels debug info (array of Indexes 
                                // in ExprDebInfo array)
  ExprCodeBufUsed : Integer;    // used routine bytecode array elements counter
  ExprDataBufUsed : Integer;    // used routine Literals array elements counter
  ExprDebInfoUsed : Integer;    // used routine debug info array elements 
                                // counter (RunTime, is not serialized)
//!!  ExprLData : PChar;            // pointer to routine local variables area in
  ExprLData : TN_BytesPtr;      // pointer to routine local variables area in 
                                // SPL call stack (RunTime, is not serialized)
  ResultType : TK_ExprExtType;  // function result variable Type Code

//##/*
  constructor Create; override;
  destructor  Destroy; override;
  procedure SaveToStrings   ( Strings: TStrings; Mode: integer ); override;
//##*/
  procedure AddFieldsToSBuf   ( ASBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( ASBuf: TN_SerialBuf ); override;
  procedure CopyFields ( ASrcObj: TN_UDBase ); override;
//**********
  function  GetLDataDescr : TK_UDFieldsDescr;

  procedure SPLExecute( AGC: TK_CSPLCont );
  procedure SPLProgExecute ( AGC: TK_CSPLCont = nil );
//  procedure ExecChildren ( GlobCont: TK_CSPLCont );
  procedure ReserveResultSpaceInSPLStack( AGC : TK_CSPLCont );
  procedure PutParamsArrayToSPLStack( AParams : array of const; AGC : TK_CSPLCont );
  function  CallSPLRoutine( AParams : array of const; AGC : TK_CSPLCont = nil ) : Boolean;
  function  CallSPLFunction( AParams : array of const; APResult : Pointer = nil;
                             ARTypeCode : Int64 = 0; AGC : TK_CSPLCont = nil  ) : Boolean;
end; // type TK_UDProgramItem = class( TN_UDBase )
type TK_UDPIArray = array of TK_UDProgramItem;
type TK_PUDProgramItem = ^TK_UDProgramItem;

//##/*
type TK_RPTab = packed record //*** TK_UDRPTab RData
  RDTCode : TK_ExprExtType;     // Record Data Type Code
  RUDCI   : Integer;   // Record UDType CI
end; //*** end of type TK_RPTab
type TK_PRPTab = ^TK_RPTab;

type TK_UDRPTab = class( TK_UDRArray ) //*** UDParent of UDRecords (UDRecords Table)
  constructor Create; override;
  function AddUDRecord( RecObjName : string = '' ) : TN_UDBase;
end; //*** end of type TK_UDRRTab = class( TK_UDRArray )

type TK_TreeViewSelect = class // Select Data by TreeView
// Select Data From Local UDTree
// UDTree Each Node is TK_UDRArray with R type specified in ItemsDataType
// and is container for data, access to which can be received after UDNode is selected
// Complex UDTree May be Loaded from External File
// API permits to get pointer to Selected Node Data
  RootNode : TN_UDBase;
  SelNode  : TN_UDBase;
  ItemsDataType : TK_ExprExtType;
  ItemsDataCount : Integer;
  SFilter : TK_UDFilter;
  SCaption : string;
  MultiSelect : Boolean;
  VFlags : TK_VFlags;
  ItemsCount : Integer;
  constructor Create();
  destructor Destroy(); override;
  procedure Clear;
  procedure AddItem( PData : Pointer;
                     const ID, Caption, Hint : string; IconInd : Integer = 0 );
  procedure TVSLoadFromFile( AFileName : string );
  procedure SetItemsDataType( DTypeCodeAll : Int64; AItemsDataCount : Integer = 1 );
  function  SelectItem : string;
  function  GetSelectedPData : Pointer;
  function  GetItemsCount : Integer;
    private
  DE : TN_DirEntryPar;
  function  ScanUDNode( UDParent : TN_UDBase; var UDChild : TN_UDBase;
    ChildInd : Integer; ChildLevel : Integer; const FieldName : string = '' ) : TK_ScanTreeResult;

end; // type TK_TreeViewSelect = class
//##*/

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFilterExtType
//****************************************************** TK_UDFilterExtType ***
// IDB objects filter Item which used TK_UDRArray.R.ComplexType Value
//
type  TK_UDFilterExtType = class( TK_UDFilterItem ) //
      private
        DTypeAll: Int64;
      public
  constructor Create( ADTypeAll: Int64;
                AExprCode : TK_UDFilterItemExprCode = K_ifcOr);
  function    UDFITest( const DE : TN_DirEntryPar ) : Boolean;  override;
end; //*** end of type TK_UDFilterExtType = class( TK_UDFilterItem )

//##/*

type TK_RAListItem = packed record //*** Element of Named RArray List (ArrayOf TK_RAListItem)
  RAValue  : TK_RArray;
  RAName   : string;
end;
type TK_PRAListItem = ^TK_RAListItem;

type TK_RAListAttrs = packed record //*** Named RArray List Attributes (ArrayOf TK_RAList)
  FDTypeName : string;
end;
type TK_PRAListAttrs = ^TK_RAListAttrs;

var
  K_RAListRAType : TK_ExprExtType;
function  K_GetRAListRAType : TK_ExprExtType;
//##*/

type TK_RAInitFunc = procedure( RA : TK_RArray; Ind, Count : Integer ); // RArray Initialization procedure
type TK_RAInitValFunc = function( TypeCode: TK_ExprExtType ) : Pointer of object;
type TK_RAInitFieldsFunc = procedure( var RA : TK_RArray;
        ArrInd : Integer;    // Start Fill Index if RA <> nil, New Array Size if RA = nil (Array type is Undefined)
        FieldName : string; FullPath  : string;
        FieldPathLength : Integer ) of object; // RArray Fields Initialization procedure

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_SLSRoot
//************************************************************** TK_SLSRoot ***
// Separately Loaded SubTree Root with Uses - TK_RArray Record
//
type TK_SLSRoot = packed record
  UDUses : TK_RArray;// arrayof TN_UDBase;
end;
type TK_PSLSRoot = ^TK_SLSRoot;


//****************** Global procedures **********************
function  K_IsUDRArray( AUDB : TN_UDBase ) : Boolean;
function  K_GetSLSRootPAttrs( AUDSLSRoot : TN_UDBase ) : TK_PSLSRoot;
function  K_PrepSPLRunGCont( AGC  : TK_CSPLCont = nil ) : TK_CSPLCont;
procedure K_FreeSPLRunGCont( var AGC : TK_CSPLCont );

function  K_GetElemTypeName( ATypeCode : Int64 ) : string;
function  K_GetExecTypeName( ATypeCode : Int64 ) : string;
function  K_GetSTypeAliase( ATypeCode : Integer ) : string;
function  K_GetExecTypeSize( ATypeCode : Int64 ) : Integer;

function  K_GetPVRArray(  var AData  ) : TK_PRArray;
procedure K_PutVRArray(  var AData : TObject; ARArray : TK_RArray );
function  K_SetVArrayField( var AVArrayField : TObject; AVArrayNValue : TObject;
                            ASetVArrayFlags : TK_SetVArrayFlags = [K_svrCountUDRef] ) : Boolean;
function  K_VArrayCondRACopy( APVRA : PObject ) : TK_RArray;

//procedure K_PutVUDRArray(  var Data : TObject; UDRArray : TK_UDRArray; CountUDRef : Boolean );
//procedure K_PutVRAData(  var Data : TObject; NData : TObject; CountUDRef : Boolean );
function  K_GetRArrayTypes( ACType: TK_ExprExtType;
                            out AElemType : TK_ExprExtType ) : TK_ExprExtType;
function  K_GetExecDataTypeCode(  const AData; ATypeCode : TK_ExprExtType  ) : TK_ExprExtType;
function  K_GetExecTypeBaseCode( ATypeCode : TK_ExprExtType ) : TK_ExprExtType;
function  K_GetExecTypeBaseFlags( ATypeCode : TK_ExprExtType ) : TK_ExprTypeFlags;
function  K_GetExecElemTypeBaseCode( ATypeCode : TK_ExprExtType ) : TK_ExprExtType;
function  K_GetTypeCode( ATypeName : string ) : TK_ExprExtType;
function  K_GetTypeCodeSafe( ATypeName : string ) : TK_ExprExtType;
function  K_GetExecTypeCodeSafe( ATypeName : string ) : TK_ExprExtType;

function  K_SetUDRefField( var AUDRef : TN_UDBase; AUDNew : TN_UDBase;
                           ACountUDRef : Boolean = true ) : Boolean;

procedure K_MoveFieldsByList( AFieldsList : TStrings;
                        APSData : Pointer;  const ASDType : TK_ExprExtType;
                        APDData : Pointer; const ADDType : TK_ExprExtType;
                        AMDFlags : TK_MoveDataFlags = [] );
procedure K_MoveSPLData( const ASData; var ADData; const ADType : TK_ExprExtType;
                                      AMDFlags : TK_MoveDataFlags = [] );
procedure K_FreeSPLData( var AData; const ADType : Int64; ACountUDRef : Boolean = false );

function  K_FieldIsEmpty( APData : Pointer; AFieldSize : Integer ) : Boolean;
procedure K_AddSPLDataToSBuf( var AData; const ADType : TK_ExprExtType;
                                                        ASBuf: TN_SerialBuf );
procedure K_GetSPLDataFromSBuf( var AData; const ADType : TK_ExprExtType;
                                                        ASBuf: TN_SerialBuf );

procedure K_AddTypeDTCodeToSBuf( ADTCode : Integer; ASBuf: TN_SerialBuf );
procedure K_AddDataTypeToSBuf( const ADType : TK_ExprExtType;
                               ASBuf: TN_SerialBuf );
function  K_GetTypeDTCodeFromSBuf( ASBuf: TN_SerialBuf ) : Integer;
function  K_GetDataTypeFromSBuf( ASBuf: TN_SerialBuf ): TK_ExprExtType;
procedure K_AddSPLDataToSTBuf( var AData; const ADType : TK_ExprExtType;
                                ASBuf: TK_SerialTextBuf; AFieldName : string;
                                AUseCurTag : Boolean );
procedure K_GetSPLDataFromSTBuf( var AData; const ADType : TK_ExprExtType;
                              ASBuf: TK_SerialTextBuf; AFieldName : string;
                              AUseCurTag : Boolean );
procedure K_SaveSPLDataToSTBuf( var AData; const ADType : TK_ExprExtType;
                                ASBuf: TK_SerialTextBuf; ALRoot : TN_UDBase;
                                AFieldName : string );
function  K_SaveSPLDataToText( var AData; const ADTCode : Int64; AFieldName : string = '';
                               ASBuf: TK_SerialTextBuf = nil; ALRoot : TN_UDBase = nil ) : string;
procedure K_LoadSPLDataFromText( var AData; const ADTCode : Int64; const ASrcText : string;
                                 AFieldName : string = '';
                                 ASBuf: TK_SerialTextBuf = nil; ALRoot : TN_UDBase = nil );
function  K_CompareSPLData( const AData1, AData2; const ADType : TK_ExprExtType;
                            ASPath : string; ACompFlags : TK_CompDataFlags = [] ) : Boolean;
function  K_CompareSPLVectors( APData1 : Pointer; AStep1 : Integer;
                        APData2 : Pointer; AStep2 : Integer;
                        ACount : Integer; AElemDTCode : Int64 ) : Boolean;
function  K_SearchInSPLDataVactor( APSData : Pointer;
                        APVData : Pointer; AStep : Integer;
                        ACount : Integer; AElemDTCode : Int64 ) : Integer;
function  K_SPLValueFromString( var AData; const ADTCode : Int64;
                    AText : string; AClearDataFlag : Boolean = false  ) : string;
function  K_SPLValueToString( const AData; const ADType : TK_ExprExtType;
                        AValueToStrFlags : TK_ValueToStrFlags = [K_svsShowName];
                        AFmt : string = ''; ASTK : TK_Tokenizer = nil;
                        AStrLen : Integer=0; AFFLags : Integer = 0;
                        AFMask : Integer = 0   ) : string;
procedure K_SPLValueToMem  ( var AData; const ADType : TK_ExprExtType;
                             out AMemPtr : Pointer; out AMemSize : Integer );
procedure K_SPLValueFromMem( var AData; const ADType : TK_ExprExtType;
                             AMemPtr : Pointer; AMemSize : Integer );

//##/*
procedure K_GetNumberFromDouble( var Number; NumTypeCode : TK_SPLVarType; VSrc : Double );
procedure K_FreeRArrays( var RArray : TK_RArray; ANum : Integer;
                                                FreeDepth : Integer = 0  );
//##*/
function  K_RCopy( ARArray : TK_RArray; AMDFlags : TK_MoveDataFlags = [];
                   AInd : Integer = 0; ACount: Integer = -1 ) : TK_RArray;
procedure K_RFreeAndCopy( var ARArray : TK_RArray; const ASArray : TK_RArray;
                        AMDFlags : TK_MoveDataFlags = [];
                        AInd : Integer = 0; ACount: Integer = -1 );
function  K_RCreateByTypeCode ( ADTCode : Int64; ACount : Integer = 0;
                                ACRFlags : TK_CreateRAFlags = [] ) : TK_RArray;
function  K_RCreateByTypeName ( ATypeName : string; ACount : Integer = 0;
              ACRFlags : TK_CreateRAFlags = [K_crfCountUDRef] ) : TK_RArray;
function  K_CreateUDByRTypeCode( ADTCode : Int64; ACount : Integer = 1;
    AUDClassInd : Integer = K_UDRArrayCI; ACallInitRoutine : Boolean = true ) : TK_UDRArray;
function  K_CreateUDByRTypeName( ATypeName : string; ACount : Integer = 1;
    AUDClassInd : Integer = K_UDRArrayCI; ACallInitRoutine : Boolean = true ) : TK_UDRArray;
function  K_CreateSPLClassByType( AUDType : TK_UDFieldsDescr;
                        AParams : array of const;
                        AConstructorName : string = 'Create' ) : TK_UDRArray;
function  K_CreateSPLClassByName( AClassName : string;
                        AParams : array of const;
                        AConstructorName : string = 'Create' ) : TK_UDRArray;
procedure K_ConvSPLDataToOleVariant( ADTCode : Integer; const AData;
                                var AOV : OleVariant );
procedure K_ConvOleVariantToSPLData( ADTCode : Integer; var AData;
                                const AOV : OleVariant );
function  K_MoveSPLVectorBySIndex( var ADData; ADStep :Integer;
                             const ASData; ASStep :Integer;
                             ADCount : Integer; ADTCode : Int64;
                             AMDFlags : TK_MoveDataFlags = [];
                             APIndex : PInteger = nil; AIStep : Integer = SizeOf(Integer) ) : Integer;
function  K_MoveSPLVectorByDIndex( var ADData; ADStep :Integer;
                             const ASData; ASStep :Integer; ADCount : Integer;
                             ADTCode : Int64; AMDFlags : TK_MoveDataFlags = [];
                             APIndex : PInteger = nil; AIStep : Integer = SizeOf(Integer) ) : Integer;
procedure K_MoveSPLVector( var ADData; ADStep :Integer; const ASData; ASStep :Integer;
                                  ADCount : Integer; ADTCode : Int64;
                                  AMDFlags : TK_MoveDataFlags = [] );
function  K_MoveSPLMatrixBySIndex( var   ADMData; ADStep0 : Integer; ADStep1 : Integer;
                                    const ASMData; ASStep0 : Integer; ASStep1 : Integer;
                                    ADCount0, ADCount1 : Integer;
                                    ADTCode : Int64; AMDFlags : TK_MoveDataFlags = [];
                                    APIndex0 : PInteger = nil; APIndex1 : PInteger = nil;
                                    AIStep0 : Integer = SizeOf(Integer);
                                    AIStep1 : Integer = SizeOf(Integer) ) : Integer;
function  K_BuildVSegmentInds( var AData; ADStep, ADCount : Integer;
          ADTCode : Int64; AVSMin, AVSMax : Double; APInds : PInteger ) : Integer;
procedure K_BuildConvFreeInitInds( ACount : Integer; APNInds: PInteger; ANCount: Integer;
                                   var AConvDataInds, AFreeDataInds, AInitDataInds : TN_IArray );
//##/*
procedure K_DataCast( var DData; DStep :Integer; DType : Int64;
                      const SData; SStep :Integer; SType : Int64; DCount : Integer );
//##*/
function  K_GetFieldPointer( APData : Pointer; ADType : TK_ExprExtType;
                             AFieldPath : string; out APField : Pointer;
                             APErrPathPos : PInteger = nil;
                             ARACreateFlag : Boolean = false;
                             ACRFlags : TK_CreateRAFlags = [];
                             ARAInitFieldsFunc : TK_RAInitFieldsFunc = nil ) : TK_ExprExtType;
function  K_GetUDFieldPointerByRPath( AUDRoot : TN_UDBase;
                          APath : string; var APField : Pointer;
                          AObjNameType : TK_UDObjNameType = K_ontObjName;
                          APUDR : TN_PUDBase = nil;
                          APErrPathPos : PInteger = nil ) : TK_ExprExtType;
//##/*
function  K_GetGEFuncIndex( GEName : string; GEPrefix : string = ''  ) : Integer;
function  K_EditByGEFuncInd( Ind : Integer; var EData; out WasEdited : Boolean ) : Boolean;
function  K_EditByGEFuncName( Name : string; var EData; out WasEdited : Boolean;
               DataCaption : string = '';
               AOwnerForm : TN_BaseForm = nil;
               AOnGlobalAction : TK_RAFGlobalActionProc = nil;
               APRLSData : TK_PRLSData = nil;
               ANotModalShow : Boolean = false ) : Boolean;
function  K_EditSPLDataByGEFunc( var Data; ADType : TK_ExprExtType;
                out WasEdited : Boolean;
                DataCaption : string = ''; GEPrefix : string = '';
                AOwnerForm : TN_BaseForm = nil;
                AOnGlobalAction : TK_RAFGlobalActionProc = nil;
                APRLSData : TK_PRLSData = nil;
                ANotModalShow : Boolean = false ) : Boolean;
function  K_EditUDByGEFunc( UDNode, UDParent : TN_UDBase; out WasEdited : Boolean;
                AOwnerForm : TN_BaseForm = nil;
                AOnGlobalAction : TK_RAFGlobalActionProc = nil;
                ANotModalShow : Boolean = false ) : Boolean;
function  K_EditUDTreeDataByGEFunc( UDNode, UDParent : TN_UDBase;
                                    FormDescr : TK_UDRArray;
                                    out WasEdited : Boolean;
                                    AOwnerForm : TN_BaseForm = nil;
                                    AOnGlobalAction : TK_RAFGlobalActionProc = nil;
                                    ANotModalShow : Boolean = false ) : Boolean;
procedure K_DataPathError( ErrPrefix : string; DataPath : string; ErrPos : Integer );
function  K_GetRAListItemRAType : TK_ExprExtType;
function  K_IndexOfRAListItem( RAList : TK_RArray; AName : string ) : Integer;
function  K_GetRAListItemPValue( PRAListItem : TK_PRAListItem; out PData : Pointer;
                                 UseArray : Boolean = false ) : TK_ExprExtType;
//function  K_BuildRAListByFormDescr( RAList : TK_RArray; ElemsCount : Integer = 1;
//                                    FormDescr : TK_UDRArray = nil ) : Integer;
type TK_RAListRebuildFlagsSet = Set of (K_rrfRebuildAll, K_rrfDeleteOld, K_rrfSkipAddNew);
function  K_RebuildRAListByFormDescr( RebuildFlagsSet : TK_RAListRebuildFlagsSet;
                                      RAList : TK_RArray; ElemsCount : Integer = -1;
                                      PAddItemsCount : PInteger = nil;
                                      FormDescr : TK_UDRArray = nil ) : Boolean;
procedure K_ReorderRAListItemsData( RAList : TK_RArray;
                                    PConvInds : PInteger; ConvIndsCount : Integer;
                                    PFreeInds : PInteger; FreeIndsCount : Integer;
                                    PInitInds : PInteger; InitIndsCount : Integer );
function  K_FillRArrayFromSMatr( ASMAtr : TN_ASArray; var ARAMatr : TK_RArray;
                                 ACol : Integer = 0; ARow : Integer = 0 ) : Integer;
procedure K_SaveRASubMatrToStrings( AStrings: TStrings; ARAMatr : TK_RArray;
              ADelim: Char = #9; ACol : Integer = 0; ARow : Integer = 0;
              AColCount : Integer = 0; ARowCount : Integer = 0 );
{
        CurERDBlock.ReorderRows( K_GetPIArray0(ConvDataInds), Length(ConvDataInds),
                            K_GetPIArray0(FreeDataInds), Length(FreeDataInds),
                            K_GetPIArray0(InitDataInds), Length(InitDataInds) );
}
//*** Expression Function Pointers
const
K_ExprFuncRefArrayMaxInd = 299;

var
  K_ExprNFuncRefs: Array [0..K_ExprFuncRefArrayMaxInd] of TK_ExprFunc;
{
       =
      (nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //  0
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 10
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 20
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 30
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 40
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 50
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 60
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 70
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 80
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 90
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //100
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //110
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //120
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //130
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //140
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //150
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //160
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //170
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //130
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //140
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //150
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //160
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //170
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  //180
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil); //190
}
//*** Expression Function Names
  K_ExprNFuncNames: Array [0..K_ExprFuncRefArrayMaxInd] of string;
  K_PascalHandles : THashedStringList; //*** List of Named Pascal Objects Handles

const
  K_UDParamsExecBit: integer = $01; // used in TK_UDProgramItem.ExecBefore method
  K_RArraySimpleAttrsValueName = '##AttrsValue';

//*** Current Root for UDBase fields References during Data Serialization
var
  K_CurUDRefRoot : TN_UDBase;

var
  K_RAInitFuncs : THashedStringList;
  K_RTEInfo : TK_RTEInfo;
//  K_DebUnit : TN_UDBase;

var
  K_PIURefPointers : TN_PArray;
  K_PIURefPaths    : TN_SArray;
  K_PIURefCount    : Integer;

//***********************************
//       Global Routines
//***********************************
  function  K_RegisterHandle  ( ObjName : string; Obj : TObject ) : Integer;
  function  K_UnRegisterHandle( ObjName : string; Obj : TObject = nil ) : Integer;
  procedure K_InitGlobContByRFrame( AGlobCont: TK_CSPLCont; ARFrame: TObject );
  procedure K_RegRAInitFunc( TypeName : string; RAInitFunc : TK_RAInitFunc );

var
  K_ScriptLDDataTokenizer : TK_Tokenizer;  //*** Parameter Text Tokenizer

//**********************************
// SPL Build-In Funcs
//**********************************
procedure K_ExprNClearStack( GC : TK_CSPLCont );
procedure K_ExprNSetResultValue( GC : TK_CSPLCont );
procedure K_ExprNChangePointerToData( GC : TK_CSPLCont );
procedure K_ExprNSetLength( GC : TK_CSPLCont );
procedure K_ExprNSumInts( GC : TK_CSPLCont );
procedure K_ExprNCallRoutine( GC : TK_CSPLCont );
procedure K_ExprNArrayElement( GC : TK_CSPLCont );
procedure K_ExprNCreateInstance( GC : TK_CSPLCont );
procedure K_ExprNCallMethod( GC : TK_CSPLCont );
procedure K_ExprNGetInstance( GC : TK_CSPLCont );
procedure K_ExprNSubArray( GC : TK_CSPLCont );
procedure K_ExprNUDCreate( GC : TK_CSPLCont );
procedure K_ExprNSetElements( GC : TK_CSPLCont );
procedure K_ExprNMove( GC : TK_CSPLCont );
procedure K_ExprNGetVarTypeInfo( GC : TK_CSPLCont );
procedure K_ExprNSumDoubles( GC : TK_CSPLCont );
procedure K_ExprNSumFLoats( GC : TK_CSPLCont );
procedure K_ExprNSumBytes( GC : TK_CSPLCont );
procedure K_ExprNSumStrings( GC : TK_CSPLCont );
procedure K_ExprNSubInts( GC : TK_CSPLCont );
procedure K_ExprNSubDoubles( GC : TK_CSPLCont );
procedure K_ExprNSubFLoats( GC : TK_CSPLCont );
procedure K_ExprNMultInts( GC : TK_CSPLCont );
procedure K_ExprNMultDoubles( GC : TK_CSPLCont );
procedure K_ExprNMultFloats( GC : TK_CSPLCont );
procedure K_ExprNDivDoubles( GC : TK_CSPLCont );
procedure K_ExprNDivFloats( GC : TK_CSPLCont );
procedure K_ExprNIntToDouble( GC : TK_CSPLCont );
procedure K_ExprNDoubleToInt( GC : TK_CSPLCont );
procedure K_ExprNIntToByte( GC : TK_CSPLCont );
procedure K_ExprNByteToInt( GC : TK_CSPLCont );
procedure K_ExprNFloatToDouble( GC : TK_CSPLCont );
procedure K_ExprNDoubleToFloat( GC : TK_CSPLCont );
procedure K_ExprNIntToString( GC : TK_CSPLCont );
procedure K_ExprNDoubleToString( GC : TK_CSPLCont );
procedure K_ExprNFloatToString( GC : TK_CSPLCont );
procedure K_ExprNUDRefToInt( GC : TK_CSPLCont );
procedure K_ExprNIntToUDRef( GC : TK_CSPLCont );
procedure K_ExprNStringToUDRef( GC : TK_CSPLCont );
procedure K_ExprNIntToShort( GC : TK_CSPLCont );
procedure K_ExprNShortToInt( GC : TK_CSPLCont );
procedure K_ExprNBeep( GC : TK_CSPLCont );
procedure K_ExprNRandom( GC : TK_CSPLCont );
procedure K_ExprNDelElements( GC : TK_CSPLCont );
procedure K_ExprNInsElements( GC : TK_CSPLCont );
procedure K_ExprNFillElements( GC : TK_CSPLCont );
procedure K_ExprNSubString( GC : TK_CSPLCont );
procedure K_ExprNShowDump( GC : TK_CSPLCont );
procedure K_ExprNFormat( GC : TK_CSPLCont );
procedure K_ExprNUDRDataRef( GC : TK_CSPLCont );
procedure K_ExprNUDChildByInd( GC : TK_CSPLCont );
procedure K_ExprNUDDirHigh( GC : TK_CSPLCont );
procedure K_ExprNUDDirLength( GC : TK_CSPLCont );
procedure K_ExprNUDAddToParent( GC : TK_CSPLCont );
procedure K_ExprNUDAddToOwner( GC : TK_CSPLCont );
procedure K_ExprNUDComponentObject( GC : TK_CSPLCont );
procedure K_ExprNSetUDRefName( GC : TK_CSPLCont );
procedure K_ExprNUDPutToParent( GC : TK_CSPLCont );
procedure K_ExprNCopyData( GC : TK_CSPLCont );
procedure K_ExprNPutArrayToUD( GC : TK_CSPLCont );
procedure K_ExprNGetArrayFromUD( GC : TK_CSPLCont );
procedure K_ExprNSetUDRef( GC : TK_CSPLCont );
procedure K_ExprNToString( GC : TK_CSPLCont );
procedure K_ExprNShowEditData( GC : TK_CSPLCont );
procedure K_ExprNShowEditDataForm( GC : TK_CSPLCont );
procedure K_ExprNShowMessage( GC : TK_CSPLCont );
procedure K_ExprNGetPascalHandle( GC : TK_CSPLCont );
procedure K_ExprNPascalNotifyFunc( GC : TK_CSPLCont );
procedure K_ExprNStringToTDate( GC : TK_CSPLCont );
procedure K_ExprNTDateToString( GC : TK_CSPLCont );
procedure K_ExprNGetTime( GC : TK_CSPLCont );
procedure K_ExprNGetDate( GC : TK_CSPLCont );
procedure K_ExprNSLength( GC : TK_CSPLCont );
procedure K_ExprNALength( GC : TK_CSPLCont );
procedure K_ExprNSetTimeout( GC : TK_CSPLCont );
procedure K_ExprNClearTimeout( GC : TK_CSPLCont );
procedure K_ExprNBit( GC : TK_CSPLCont );
procedure K_ExprNAndInts( GC : TK_CSPLCont );
procedure K_ExprNOrInts( GC : TK_CSPLCont );
procedure K_ExprNXorInts( GC : TK_CSPLCont );
procedure K_ExprNNotInt( GC : TK_CSPLCont );
procedure K_ExprNEQStrings( GC : TK_CSPLCont );
procedure K_ExprNEQInts( GC : TK_CSPLCont );
procedure K_ExprNEQDoubles( GC : TK_CSPLCont );
procedure K_ExprNEQFloats( GC : TK_CSPLCont );
procedure K_ExprNLTInts( GC : TK_CSPLCont );
procedure K_ExprNLTDoubles( GC : TK_CSPLCont );
procedure K_ExprNLTFloats( GC : TK_CSPLCont );
procedure K_ExprNGTInts( GC : TK_CSPLCont );
procedure K_ExprNGTDoubles( GC : TK_CSPLCont );
procedure K_ExprNGTFloats( GC : TK_CSPLCont );
procedure K_ExprNMinusInt( GC : TK_CSPLCont );
procedure K_ExprNMinusDouble( GC : TK_CSPLCont );
procedure K_ExprNMinusFLoat( GC : TK_CSPLCont );
procedure K_ExprNTreeViewUpdate( GC : TK_CSPLCont );
procedure K_ExprNShowFDump( GC : TK_CSPLCont );
procedure K_ExprNARowLength( GC : TK_CSPLCont );
procedure K_ExprNSetRowLength( GC : TK_CSPLCont );
procedure K_ExprNNewArrayByTypeCode( GC : TK_CSPLCont );
procedure K_ExprNNewArrayByTypeName( GC : TK_CSPLCont );
procedure K_ExprNAElemTypeCode( GC : TK_CSPLCont );
procedure K_ExprNAElemTypeName( GC : TK_CSPLCont );
procedure K_ExprNPField( GC : TK_CSPLCont );
procedure K_ExprNPutVArray( GC : TK_CSPLCont );
procedure K_ExprNGetVArray( GC : TK_CSPLCont );
procedure K_ExprNStrToNumber( GC : TK_CSPLCont );
procedure K_ExprNATypeName( GC : TK_CSPLCont );
procedure K_ExprNTranspMatrix( GC : TK_CSPLCont );
procedure K_ExprNGetSubArray( GC : TK_CSPLCont );
procedure K_ExprNCopySubMatrix( GC : TK_CSPLCont );
procedure K_ExprNARowsRangeCount( GC : TK_CSPLCont );
procedure K_ExprNAColsRangeCount( GC : TK_CSPLCont );
procedure K_ExprNStrMatrixSearch( GC : TK_CSPLCont );
procedure K_ExprNCeil( GC : TK_CSPLCont );
procedure K_ExprNFloor( GC : TK_CSPLCont );
procedure K_ExprNRound( GC : TK_CSPLCont );
procedure K_ExprNSqrt( GC : TK_CSPLCont );
procedure K_ExprNAbs( GC : TK_CSPLCont );
procedure K_ExprNStrToIBool( GC : TK_CSPLCont );
procedure K_ExprNUpperCase( GC : TK_CSPLCont );
procedure K_ExprNLowerCase( GC : TK_CSPLCont );
procedure K_ExprNCompareData( GC : TK_CSPLCont );
procedure K_ExprNExecComponent( GC : TK_CSPLCont );
procedure K_ExprNInsComponent( GC : TK_CSPLCont );
procedure K_ExprNUDCursorInit( GC : TK_CSPLCont );
procedure K_ExprNBuildDPIndexes( GC : TK_CSPLCont );
procedure K_ExprNUDRFieldRef( GC : TK_CSPLCont );
procedure K_ExprNStringToType( GC : TK_CSPLCont );
procedure K_ExprNTypeToString( GC : TK_CSPLCont );
procedure K_ExprNTypeOfPointer0( GC : TK_CSPLCont );
procedure K_ExprNTypedPointer0( GC : TK_CSPLCont );
procedure K_ExprNTypeOfPointer( GC : TK_CSPLCont );
procedure K_ExprNTypedPointer( GC : TK_CSPLCont );

//##*/

implementation

uses StrUtils, Forms, Math, StdCtrls, Dialogs, ExtCtrls,
     N_Lib0, N_SGRA1, N_Rast1Fr,
     K_FSDeb, K_UDT2, K_UDConst, K_SParse1, K_UDC, K_FSelectUDB,
     K_FrRaEdit, K_FRaEdit, K_DCSpace, K_CLib, K_CSpace;


//***********************************************
//***************** Local Data ******************
//***********************************************
var
K_TimerEventPermition : Boolean = true;
K_UDRefSaveToFileDE : TN_DirEntryPar;
K_SLSRootTypeCode : Integer;  // SLSRoot RAType Code

//*************************************
// RArray UDRef Search Routines Context
//*************************************
K_UDRefSrchRoutine : procedure ( var UDRef : TN_UDBase; RArray : TK_RArray;
                                 UDRArray : TN_UDBase; ChildInd : Integer;
                                 FieldName: string );
//*** Mark/UnMark SubTree Context
K_UDRefSrchMarkLevel,
K_UDRefSrchMarkDepth,
K_UDRefSrchMarkField : Integer;

//*** ClearUDRefInfo Context
K_UDRefSrchClearFlags  : TK_ClearRefInfoFlags;
K_UDRefSrchClearRoot   : TN_UDBase;

//*** BuildSubTreeRefObjs Context

//*** ReplaceSubTreeRelPaths, GetPathToDE Context
//K_UDRefSrchCurPath  : string;
//K_UDRefSrchSL: TStrings;

//*** GetPathToDE and ReplaceSubTreeRelPaths Context
//K_UDRefSrchDE       : TN_DirEntryPar;
//K_UDRefSrchRes: Boolean;

//*** ReplaceSubTreeNodes Context
K_UDRefSrchRepArr: TK_BaseArray;

//*** ScanSubTree Context
K_UDRefSrchTestNodeFunc : TK_TestUDChildFunc;
K_UDRefSrchTestLevel : Integer;
K_UDRefSrchTestResult : TK_ScanTreeResult;

//*** GetPathToUDObj Context
K_UDRefSrchNameType : TK_UDObjNameType;
K_UDRefSrchFieldsList: TStrings;
K_UDRefSrchPath: string;
K_UDRefSrchSrchObj: TN_UDBase;

//*************************************
// RArray Search Routines
//*************************************
procedure K_UDRefSrchScan( var UDRef : TN_UDBase;  RArray : TK_RArray;
                                 UDRArray : TN_UDBase; ChildInd : Integer;
                                 FieldName: string );
begin
  if (UDRef = nil)                                 or
     (K_UDRefSrchTestResult = K_tucSkipScan)       or
     (K_UDRefSrchTestResult = K_tucSkipSibling) then Exit;
  K_UDRefSrchTestResult := K_UDRefSrchTestNodeFunc( UDRArray, UDRef, -1, K_UDRefSrchTestLevel, FieldName );
  if (K_UDRefSrchTestResult = K_tucOK)                              and
     (K_UDLoopProtectionList.IndexOf(UDRef) = -1)                   and
     (UDRef <> nil)                                                 and
     not (K_udtsSkipRAFieldsSubTreeScan in K_UDTreeChildsScanFlags) and
     not UDRef.ScanSubTree( K_UDRefSrchTestNodeFunc, K_UDRefSrchTestLevel ) then
//     UDRef.ScanSubTree( K_UDRefSrchTestNodeFunc, K_UDRefSrchTestLevel ) then
    K_UDRefSrchTestResult := K_tucSkipScan;
end;

procedure K_UDRefSrchUnMark( var UDRef : TN_UDBase;  RArray : TK_RArray;
                                 UDRArray : TN_UDBase; ChildInd : Integer;
                                 FieldName: string );
begin
  if (UDRef = nil)                                 or
     (K_UDLoopProtectionList.IndexOf(UDRef) <> -1) or
     (K_udtsSkipRAFieldsSubTreeScan in K_UDTreeChildsScanFlags) then Exit;
  UDRef.UnMarkSubTree( K_UDRefSrchMarkDepth, K_UDRefSrchMarkField );
end;

procedure K_UDRefSrchMark( var UDRef : TN_UDBase;  RArray : TK_RArray;
                                 UDRArray : TN_UDBase; ChildInd : Integer;
                                 FieldName: string );
begin
  if (UDRef = nil)                                 or
     (K_UDLoopProtectionList.IndexOf(UDRef) <> -1) or
     (K_udtsSkipRAFieldsSubTreeScan in K_UDTreeChildsScanFlags) then Exit;
  UDRef.MarkSubTree( K_UDRefSrchMarkLevel,
                        K_UDRefSrchMarkDepth, K_UDRefSrchMarkField );
end;

procedure K_UDRefSrchBuildRefObjs( var UDRef : TN_UDBase;  RArray : TK_RArray;
                                 UDRArray : TN_UDBase; ChildInd : Integer;
                                 FieldName: string );
begin
  if (UDRef = nil) or (UDRArray = UDRef) then Exit;
  with UDRef do begin
    BuildRefPath();
    if RefPath <> '' then
      K_SetUDRefField( UDRef, BuildRefObj, ((RArray.ElemType.EFlags.CFlags and K_ccStopCountUDRef)=0) );
  end;
end;

procedure K_UDRefSrchClearInfo( var UDRef : TN_UDBase;  RArray : TK_RArray;
                                 UDRArray : TN_UDBase; ChildInd : Integer;
                                 FieldName: string );
begin
  with UDRef do begin
    if (UDRef = nil)      or
       (UDRef = UDRArray) or
       ( (K_UDScannedUObjsList <> nil) and
         ((UDRef.ClassFlags and K_MarkScanNodeBitD) <> 0) ) then Exit;
    RefIndex := 0;
    if K_criClearMarker in K_UDRefSrchClearFlags then SetMarker( 0 );
    if K_criClearChangedInfoFlag in K_UDRefSrchClearFlags then
      ClassFlags := ClassFlags and not (K_ChangedSubTreeBit or K_ChangedSLSRBit) ;
    if ClassFlags = K_UDRefCI then Exit;
    if RefPath <> '' then ClearRefPath;
    if K_criClearFullSubTree in K_UDRefSrchClearFlags then
      ClearSubTreeRefInfo( K_UDRefSrchClearRoot, K_UDRefSrchClearFlags );
  end;
end;

procedure K_UDRefSrchReplaceRefObjs( var UDRef : TN_UDBase;  RArray : TK_RArray;
                                     UDRArray : TN_UDBase; ChildInd : Integer;
                                     FieldName: string );
var
  NUD : TN_UDBase;
begin
  if (UDRef = nil)                                   or
     (UDRef = UDRArray)                              or
     ((UDRef.ClassFlags and K_MarkScanNodeBitD) <> 0) or
     (K_UDLoopProtectionList.IndexOf(UDRef) <> -1) then Exit;
  with UDRef do begin
    if ClassFlags = K_UDRefCI then begin
      if K_ReplaceNodeRef( UDRef, NUD ) then begin
//        assert( NUD <> nil, 'Wrong node path:'+UDRArray.ObjName+'['+IntToStr(ChildInd)+'].'+
        assert( NUD <> nil, 'Wrong node path:' + UDRArray.GetUName +
                '['+IntToStr(ChildInd)+'].' + FieldName + ' ->' + RefPath );
        if NUD <> UDRef then begin // Reference was replaced
          UDRef := nil; //*** clear UDRef field - because WUD is already destroyed
          K_SetUDRefField( UDRef, NUD, ((RArray.ElemType.EFlags.CFlags and K_ccStopCountUDRef)=0) );
          Inc( K_UDTreeBuildRefControl.RRefCount );
        end else begin
          K_AddToPUDRefsTable( @UDRef );
        end;
      end;
    end else
      ReplaceSubTreeRefObjs(  );
  end;
end;

procedure K_UDRefSrchReplaceNodes( var UDRef : TN_UDBase;  RArray : TK_RArray;
                                 UDRArray : TN_UDBase; ChildInd : Integer;
                                 FieldName: string );
var
  refs : TK_UDRefsRep;
  ind : Integer;
begin
  if UDRef = UDRArray then Exit;
  if K_UDRefSrchRepArr.FindItem( ind, @UDRef ) then begin
    K_UDRefSrchRepArr.GetItem( ind, refs );
    K_SetUDRefField( UDRef, refs.NewChild, ((RArray.ElemType.EFlags.CFlags and K_ccStopCountUDRef)=0) );
  end else if (UDRef <> nil) then
    UDRef.ReplaceSubTreeNodes( K_UDRefSrchRepArr );
end;

procedure K_UDRefSrchGetPathToUDObj( var UDRef : TN_UDBase;  RArray : TK_RArray;
                                     UDRArray : TN_UDBase; ChildInd : Integer;
                                     FieldName: string );
begin
  if (K_UDRefSrchPath <>'') or (UDRef = UDRArray) then Exit;

  if (UDRef = K_UDRefSrchSrchObj) then
    K_UDRefSrchPath := FieldName
  else if UDRef <> nil then
    K_UDRefSrchFieldsList.AddObject( FieldName, UDRef );
end;

//*************************************
// end of RArray Search Routines
//*************************************

//***********************************
//       Global Routines
//***********************************

//********************************************** K_ValueToStringBuf ***
//
procedure K_ValueToStringBuf( const Data; DType : TK_ExprExtType;
                AgregateType : Boolean; STK : TK_Tokenizer;
                ValueToStrFlags : TK_ValueToStrFlags = [];
                AStrLen : Integer=0; FFLags : Integer = 0; FMask : Integer = 0 );

var
  WStr : string;
begin
  with STK do begin
    if AgregateType then
      addToken( K_sccStartListDelim, K_ttString );
    WStr := K_SPLValueToString( Data, DType, ValueToStrFlags, '', STK, AStrLen, FFLags, FMask );
//    if not AgregateType then
    if (WStr <> '') or (Ord(nptString) = (DType.All and K_ffCompareTypesMask)) then
      addToken( WStr, K_ttToken );
    if AgregateType then
      addToken( K_sccFinListDelim, K_ttString );
  end;
end; //*** end of procedure K_ValueToStringBuf

//********************************************** K_RegisterHandle ***
//
function K_RegisterHandle  ( ObjName : string; Obj : TObject ) : Integer;
begin
  Result := -1;
  if K_PascalHandles.IndexOf( ObjName ) <> -1 then Exit;
  Result := K_PascalHandles.AddObject( ObjName, Obj );
end; //*** end of K_RegisterHandle ***

//********************************************** K_UnregisterHandle ***
//
function K_UnregisterHandle  ( ObjName : string; Obj : TObject ) : Integer;
begin
  if ObjName <> '' then
    Result := K_PascalHandles.IndexOf( ObjName )
  else
    Result := K_PascalHandles.IndexOfObject( Obj );
  if Result <> -1 then
    K_PascalHandles.Delete( Result );
end; //*** end of K_UnregisterHandle ***

//***********************************************
//***                SPL Functions
//***********************************************

//********************************************** K_ExprNGetVarTypeInfo ***
//
// SPL: function GetVarTypeInfo( PVar: ^Undef ): String;
//
procedure K_ExprNGetVarTypeInfo( GC : TK_CSPLCont );
type  Params = packed record
  SP: Pointer;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
  StrBuf : string;
  StrFlags : string;

  procedure AddFlag( FlagName : string );
  begin
    if StrFlags <> '' then StrFlags := StrFlags + ',';
    StrFlags := StrFlags + FlagName;
  end;

begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Dec(DType1.D.TFlags, K_ffPointer);
    StrBuf := 'Type='+K_GetSTypeAliase( DType1.DTCode );

// Add Static Type Flags Info
    StrFlags := '';
    if (DType1.D.TFlags and K_ffPPointer) <> 0 then AddFlag( 'PP')
    else if (DType1.D.TFlags and K_ffPointer) <> 0 then AddFlag( 'P')
    else if (DType1.D.TFlags and K_ffPointer) <> 0 then AddFlag( 'P')
    else if (DType1.D.TFlags and K_ffClassMethod) <> 0 then AddFlag( 'CM' )
    else if (DType1.D.TFlags and K_ffUDRARef) <> 0 then AddFlag( 'UDR')
    else if (DType1.D.TFlags and K_ffVArray) <> 0 then AddFlag( 'V')
    else if (DType1.D.TFlags and K_ffArray) <> 0 then AddFlag( 'A');
    if StrFlags <> '' then StrBuf := StrBuf + ' FT=['+StrFlags+']';

// Add DB Type Flags Info
    StrFlags := '';
    if (DType1.D.CFlags and K_ccRuntime) <> 0 then AddFlag( 'NS')
    else if (DType1.D.CFlags and K_ccObsolete) <> 0 then AddFlag( 'OB')
    else if (DType1.D.CFlags and K_ccVariant) <> 0 then AddFlag( 'VA')
    else if (DType1.D.CFlags and K_ccPrivate) <> 0 then AddFlag( 'PR')
    else if (DType1.D.CFlags and K_ccStopCountUDRef) <> 0 then AddFlag( 'SCU')
    else if (DType1.D.CFlags and K_ccCountUDRef) <> 0 then AddFlag( 'CU');
    if StrFlags <> '' then StrBuf := StrBuf + ' FC=['+StrFlags+']';

    N_p := SP;

    SP := nil;
    string(SP) := StrBuf;
    DType1.All := Ord(nptString);
    Inc( GC.ExprStackLevel, SizeOf(Params) );
  end;
end; //*** end of K_ExprNGetVarTypeInfo ***

//********************************************** K_ExprNClearStack ***
//
procedure K_ExprNClearStack( GC : TK_CSPLCont );
var
  SP : Pointer;
  SType : TK_ExprExtType;
begin
  with GC do
//    while ExprStackLevel > 0 do begin
      GetPointerToExprStackData( SP, SType.All );
      K_FreeSPLData( SP^, SType.All );
//    end;
end; //*** end of K_ExprNClearStack ***

//********************************************** K_ExprNSetResultValue ***
//
procedure K_ExprNSetResultValue( GC : TK_CSPLCont );
var
  SP, DP : Pointer;
  SType, DType : TK_ExprExtType;
begin
  with GC do begin
    GetPointerToExprStackData( SP, SType.All );
    GetDataFromExprStack( DP, DType.All );
    assert( {((DType.D.TFlags and K_ffUDArray) <> 0) or}
            ((DType.D.CFlags and (K_ccObsolete)) = 0) or
            ((DType.D.TFlags and (K_ffFlagsMask)) <> 0) or
            (DType.DTCode = Ord(nptUDRef)), 'Expression stack error' );
//    assert( ((DType.D.CFlags and (K_ccObsolete)) = 0) and
//            (((DType.D.TFlags and (K_ffFlagsMask)) <> 0) or
//             (DType.DTCode = Ord(nptUDRef))), 'Expression stack error' );
{
    if ((DType.D.CFlags and (K_ccObsolete)) <> 0) or
       (((DType.D.TFlags and (K_ffFlagsMask)) = 0) and
        (DType.DTCode <> Ord(nptUDRef)) ) then begin
      K_FreeSPLData( SP^, SType.All ); //*** Clear Stack Data
      TK_SPLRunTimeError.Create( 'Expression stack error' );
    end else
      K_MoveSPLData( SP^, DP^, SType, [K_mdfFreeDest] );
}

{
!!! - error Compiler permit some different types avaluation Integer and Hex
    if (DType.DTCode <> Ord(nptNotDef)) and (SType.DTCode <> DType.DTCode) then
      raise TK_SPLRunTimeError.Create( 'Left side type "'+
         K_GetExecTypeName(DType.DTCode)+'" not equal to result type '+'"'+
         K_GetExecTypeName(SType.DTCode)+'"' );
}
    K_MoveSPLData( SP^, DP^, SType, [K_mdfFreeDest] );
    K_FreeSPLData( SP^, SType.All ); //*** Clear Stack Data
  end;
end; //*** end of K_ExprNSetResultValue ***

//********************************************** K_ExprNCallRoutine ***
//
procedure K_ExprNCallRoutine( GC : TK_CSPLCont );
var
  UDP : TK_UDProgramItem;
  DType : TK_ExprExtType;
  CFlags : Integer;
begin
  with GC do begin
    GetDataFromExprStack( UDP, DType.All );
//    assert( (UDP.ClassFLags and $FF) = K_UDProgramItemCI, 'Routine call error' );
    if UDP.CI  <> K_UDProgramItemCI then
      raise TK_SPLRunTimeError.Create( 'Routine call error' );

    CFlags := FlagSet;
    FlagSet := FlagSet and not K_gcDebFlags;
//??    FlagSet := FlagSet and not K_gcRunFlags;
    if (K_gcTraceInto and CFlags) <> 0 then begin //*** Set Step Over Mode
      FlagSet := FlagSet or K_gcStepOver or K_gcDebMode;
      CFlags := CFlags and not K_gcTraceInto;
    end;
    UDP.SPLExecute( GC );
    if RTE.RTEFlag <> 0 then raise TK_SPLRunTimeError.Create( '' );
//*** Restore previous Debug Flags
    FlagSet := (FlagSet  and K_gcRunFlags) or CFlags;
  end;
end; //*** end of K_ExprNCallRoutine ***

//********************************************** K_ExprNAndInts ***
//
procedure K_ExprNAndInts( GC : TK_CSPLCont );
type  Params = packed record
  V1: Integer;
  DType1 : TK_ExprExtType;
  V2: Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 and PP.V2;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNAndInts ***

//********************************************** K_ExprNSetTimeout ***
// SPL: function  SetTimeout( Interval : Integer; Proc : TNotifyProc ) : Integer;
//
procedure K_ExprNSetTimeout( GC : TK_CSPLCont );
type  Params = packed record
  V1: Integer;
  DType1  : TK_ExprExtType;
  PI: TK_UDProgramItem;
  DType2  : TK_ExprExtType;
end;
var
  PP : ^Params;
  WT : TTimer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    WT := TTimer.Create(Application);
    WT.Interval := V1;
    WT.OnTimer := GC.TimerEvent;
    WT.Tag := Integer(PI);
    V1 := Integer(WT);
    Inc( GC.ExprStackLevel, SizeOf(V1) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNSetTimeout ***

//********************************************** K_ExprNClearTimeout ***
// SPL: function  ClearTimeout( HTimeout : Integer ) : Integer;
//
procedure K_ExprNClearTimeout( GC : TK_CSPLCont );
type  Params = packed record
  V1: Integer;
  DType1  : TK_ExprExtType;
end;
var
  PP : ^Params;

begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if TObject(V1) is TTimer then begin
      TTimer(V1).Enabled := false;
      TTimer(V1).Free;
      V1 := 0;
    end else
      V1 := -1;
    Inc( GC.ExprStackLevel, SizeOf(V1) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNClearTimeout ***

//********************************************** K_ExprNBit ***
// SPL: function  Bit( BitNum : Integer ) : Integer;
//
procedure K_ExprNBit( GC : TK_CSPLCont );
type  Params = packed record
  V2: Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    V2 := 1 shl V2;
    Inc( GC.ExprStackLevel, SizeOf(V2) + SizeOf(DType2) );
  end;
end; //*** end of K_ExprNBit ***

//********************************************** K_ExprNOrInts ***
//
procedure K_ExprNOrInts( GC : TK_CSPLCont );
type  Params = packed record
  V1: Integer;
  DType1 : TK_ExprExtType;
  V2: Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 or PP.V2;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNOrInts ***

//********************************************** K_ExprNXorInts ***
//
procedure K_ExprNXorInts( GC : TK_CSPLCont );
type  Params = packed record
  V1: Integer;
  DType1 : TK_ExprExtType;
  V2: Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 xor PP.V2;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNXorInts ***

//********************************************** K_ExprNNotInt ***
//
procedure K_ExprNNotInt( GC : TK_CSPLCont );
type  Params = packed record
  V1: Integer;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 xor Integer($FFFFFFFF);
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNNotInt ***

//********************************************** K_ExprNMinusInt ***
//
procedure K_ExprNMinusInt( GC : TK_CSPLCont );
type  Params = packed record
  V1: Integer;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := -PP.V1;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNMinusInt ***

//********************************************** K_ExprNMinusDouble ***
//
procedure K_ExprNMinusDouble( GC : TK_CSPLCont );
type  Params = packed record
  V1: Double;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := -PP.V1;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNMinusDouble ***

//********************************************** K_ExprNMinusFloat ***
//
procedure K_ExprNMinusFloat( GC : TK_CSPLCont );
type  Params = packed record
  V1: Float;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := -PP.V1;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNMinusFloat ***

//********************************************** K_ExprNSumInts ***
//
procedure K_ExprNSumInts( GC : TK_CSPLCont );
type  Params = packed record
  V1: Integer;
  DType1 : TK_ExprExtType;
  V2: Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 + PP.V2;
  PP.DType1 := GC.ExecFuncType; // for the case when SumInts used in Address Calc
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNSumInts ***

//********************************************** K_ExprNSumDoubles ***
//
procedure K_ExprNSumDoubles( GC : TK_CSPLCont );
type  Params = packed record
  V1: Double;
  DType1 : TK_ExprExtType;
  V2: Double;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 + PP.V2;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNSumDoubles ***

//********************************************** K_ExprNSumFloats ***
//
procedure K_ExprNSumFloats( GC : TK_CSPLCont );
type  Params = packed record
  V1: Float;
  DType1 : TK_ExprExtType;
  V2: Float;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 + PP.V2;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNSumFloats ***

//********************************************** K_ExprNSumBytes ***
//
procedure K_ExprNSumBytes( GC : TK_CSPLCont );
type  Params = packed record
  V1: Byte;
  DType1 : TK_ExprExtType;
  V2: Byte;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 + PP.V2;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNSumFloats ***

//********************************************** K_ExprNSumStrings ***
//
procedure K_ExprNSumStrings( GC : TK_CSPLCont );
type  Params = packed record
  V1: string;
  DType1 : TK_ExprExtType;
  V2: string;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 + PP.V2;
  PP.V2 := '';
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNSumFloats ***

//********************************************** K_ExprNSubInts ***
//
procedure K_ExprNSubInts( GC : TK_CSPLCont );
type  Params = packed record
  V1: Integer;
  DType1 : TK_ExprExtType;
  V2: Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 - PP.V2;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNSubInts ***

//********************************************** K_ExprNSubDoubles ***
//
procedure K_ExprNSubDoubles( GC : TK_CSPLCont );
type  Params = packed record
  V1: Double;
  DType1 : TK_ExprExtType;
  V2: Double;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 - PP.V2;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNSubDoubles ***

//********************************************** K_ExprNSubFloats ***
//
procedure K_ExprNSubFloats( GC : TK_CSPLCont );
type  Params = packed record
  V1: Float;
  DType1 : TK_ExprExtType;
  V2: Float;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 - PP.V2;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNSubFloats ***

//********************************************** K_ExprNMultInts ***
//
procedure K_ExprNMultInts( GC : TK_CSPLCont );
type  Params = packed record
  V1: Integer;
  DType1 : TK_ExprExtType;
  V2: Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 * PP.V2;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNMultInts ***

//********************************************** K_ExprNMultDoubles ***
//
procedure K_ExprNMultDoubles( GC : TK_CSPLCont );
type  Params = packed record
  V1: Double;
  DType1 : TK_ExprExtType;
  V2: Double;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 * PP.V2;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNMultDoubles ***

//********************************************** K_ExprNMultFloats ***
//
procedure K_ExprNMultFloats( GC : TK_CSPLCont );
type  Params = packed record
  V1: Float;
  DType1 : TK_ExprExtType;
  V2: Float;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 * PP.V2;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNMultFloats ***

//********************************************** K_ExprNDivDoubles ***
//
procedure K_ExprNDivDoubles( GC : TK_CSPLCont );
type  Params = packed record
  V1: Double;
  DType1 : TK_ExprExtType;
  V2: Double;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  if PP.V2 = 0 then
    PP.V2 := 0;
  PP.V1 := PP.V1 / PP.V2;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNDivDoubles ***

//********************************************** K_ExprNDivFloats ***
//
procedure K_ExprNDivFloats( GC : TK_CSPLCont );
type  Params = packed record
  V1: Float;
  DType1 : TK_ExprExtType;
  V2: Float;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.V1 := PP.V1 / PP.V2;
  Inc( GC.ExprStackLevel, SizeOf(PP.V1) + SizeOf(PP.DType1) );
end; //*** end of K_ExprNDivFloats ***

//********************************************** K_ExprNByteToInt ***
//
procedure K_ExprNByteToInt( GC : TK_CSPLCont );
var
  B1 : Byte;
  I1 : Integer;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( B1, DType.All );
  I1 := B1;
  GC.PutDataToExprStack( I1, Ord(nptInt) );
end; //*** end of K_ExprNByteToInt ***

//********************************************** K_ExprNIntToByte ***
//
procedure K_ExprNIntToByte( GC : TK_CSPLCont );
var
  B1 : Byte;
  I1 : Integer;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( I1, DType.All );
  B1 := Byte(I1);
  GC.PutDataToExprStack( B1, Ord(nptByte) );
end; //*** end of K_ExprNIntToByte ***

//********************************************** K_ExprNShortToInt ***
//
procedure K_ExprNShortToInt( GC : TK_CSPLCont );
var
  S1 : Short;
  I1 : Integer;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( S1, DType.All );
  I1 := S1;
  GC.PutDataToExprStack( I1, Ord(nptInt) );
end; //*** end of K_ExprNShortToInt ***

//********************************************** K_ExprNIntToShort ***
//
procedure K_ExprNIntToShort( GC : TK_CSPLCont );
var
  S1 : Short;
  I1 : Integer;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( I1, DType.All );
  S1 := Short(I1);
  GC.PutDataToExprStack( S1, Ord(nptByte) );
end; //*** end of K_ExprNIntToShort ***

//********************************************** K_ExprNDoubleToInt ***
//
procedure K_ExprNDoubleToInt( GC : TK_CSPLCont );
var
  D1 : Double;
  I1 : Integer;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( D1, DType.All );
  I1 := Round(D1);
  GC.PutDataToExprStack( I1, Ord(nptInt) );
end; //*** end of K_ExprNDoubleToInt ***

//********************************************** K_ExprNIntToDouble ***
//
procedure K_ExprNIntToDouble( GC : TK_CSPLCont );
var
  D1 : Double;
  I1 : Integer;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( I1, DType.All );
  D1 := I1;
  GC.PutDataToExprStack( D1, Ord(nptDouble) );
end; //*** end of K_ExprNIntToDouble ***

//********************************************** K_ExprNDoubleToFloat ***
//
procedure K_ExprNDoubleToFloat( GC : TK_CSPLCont );
var
  D1 : Double;
  F1 : Float;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( D1, DType.All );
  F1 := D1;
  GC.PutDataToExprStack( F1, Ord(nptFloat) );
end; //*** end of K_ExprNDoubleToFloat ***

//********************************************** K_ExprNFloatToDouble ***
//
procedure K_ExprNFloatToDouble( GC : TK_CSPLCont );
var
  D1 : Double;
  F1 : Float;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( F1, DType.All );
  D1 := F1;
  GC.PutDataToExprStack( D1, Ord(nptDouble) );
end; //*** end of K_ExprNFloatToDouble ***

//********************************************** K_ExprNExtendedToString ***
//
procedure K_ExprNExtendedToString( GC : TK_CSPLCont; Data : Extended );
var
  S1 : string;
begin
  S1 := FloatToStr(Data);
  GC.PutDataToExprStack( S1, Ord(nptString) );
end; //*** end of K_ExprNExtendedToString ***

//********************************************** K_ExprNIntToString ***
//
procedure K_ExprNIntToString( GC : TK_CSPLCont );
var
  I1 : Integer;
  S1 : string;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( I1, DType.All );
  S1 := IntToStr(I1);
  GC.PutDataToExprStack( S1, Ord(nptString) );
end; //*** end of K_ExprNIntToString ***

//********************************************** K_ExprNDoubleToString ***
//
procedure K_ExprNDoubleToString( GC : TK_CSPLCont );
var
  D1 : Double;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( D1, DType.All );
  K_ExprNExtendedToString( GC, D1 );
end; //*** end of K_ExprNDoubleToString ***

//********************************************** K_ExprNFloatToString ***
//
procedure K_ExprNFloatToString( GC : TK_CSPLCont );
var
  F1 : Float;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( F1, DType.All );
  K_ExprNExtendedToString( GC, F1 );
end; //*** end of K_ExprNFloatToString ***

//********************************************** K_ExprNUDRefToInt ***
//
procedure K_ExprNUDRefToInt( GC : TK_CSPLCont );
//var
//  UDB : TN_UDBase;
begin
  with GC do begin
    PInt64(@ExprStack[ExprStackLevel - SizeOf( TK_ExprExtType )])^
                                                         := Ord(nptInt);
//    UDB := TN_PUDBase(@ExprStack[ExprStackLevel - SizeOf( TK_ExprExtType ) - SizeOf(TN_UDBase)])^;
  end;

//??!!Error 28.08.2006  if UDB <> nil then Dec(UDB.RefCounter);


end; //*** end of K_ExprNUDRefToInt ***

//********************************************** K_ExprNIntToUDRef ***
//
procedure K_ExprNIntToUDRef( GC : TK_CSPLCont );
//var
//  UDB : TN_UDBase;
begin
  with GC do begin
    PInt64(@ExprStack[ExprStackLevel - SizeOf( TK_ExprExtType )])^
                                                         := Ord(nptUDRef);
//    UDB := TN_PUDBase(@ExprStack[ExprStackLevel - SizeOf( TK_ExprExtType ) - SizeOf(TN_UDBase)])^;
  end;

//??!!Error 28.08.2006  if UDB <> nil then Inc(UDB.RefCounter);

end; //*** end of K_ExprNIntToUDRef ***

//********************************************** K_ExprNFormat ***
// SPL: function format( FString:String; FData : Undef ) : String;
//
procedure K_ExprNFormat( GC : TK_CSPLCont );
type  Params = packed record
  SF: string;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
  SP : Pointer;
  DType : TK_ExprExtType;
begin
  GC.GetPointerToExprStackData( SP, DType.All );
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
//  if (DType.D.TFlags and K_ffArray ) <> 0 then
//    DType.All := Ord(nptNotDef);
  PP.SF := K_SPLValueToString( SP^, DType, [K_svsShowName], PP.SF );
  K_FreeSPLData( SP^, DType.All );
  Inc( GC.ExprStackLevel, SizeOf(Params) );
end; //*** end of K_ExprNFormat ***

//********************************************** K_ExprNChangePointerToData ***
// SPL: function value( Op1:^Undef ) : Undef;
//
procedure K_ExprNChangePointerToData( GC : TK_CSPLCont );
var
  SP : Pointer;
  DType : TK_ExprExtType;
  UNDefVal : Integer;
begin
  GC.GetDataFromExprStack( SP, DType.All );
  Dec(DType.D.TFlags, K_ffPointer);
  if SP = nil then begin
    UNDefVal := 0;
    SP := @UNDefVal;
  end;
  GC.PutDataToExprStack( SP^, DType.All );
end; //*** end of K_ExprNChangePointerToData ***

//********************************************** K_ExprNSetLength ***
// SPL: function  SetLength( PArr:^ArrayOf Undef; Size:Integer ) : ArrayOf Undef;
//
procedure K_ExprNSetLength( GC : TK_CSPLCont );
type  Params = packed record
  V1: TK_PRArray;
  DType1 : TK_ExprExtType;
  V2: Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  WType : TK_ExprExtType;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if (V1^ = nil) or
       ((V1^.ALength <> V2) and (V1^.RefCount > 1)) then begin// Create Array
      WType := DType1;
      Dec( WType.D.TFlags, K_ffPointer );
      if V1^ <> nil then
        V1^.ARelease;
      if V2 > 0 then
        V1^ := K_RCreateByTypeCode( WType.All, V2 )
    end else if V2 = 0 then
      V1^.ARelease
    else
      V1^.ASetLength( V2 );
    if V2 = 0 then V1^ := nil;

    V1 := Pointer(V1^.AAddRef);

    Dec( DType1.D.TFlags, K_ffPointer );
    Inc( GC.ExprStackLevel, SizeOf(V1) + SizeOf(DType1) );

  end;
end; //*** end of K_ExprNSetLength ***

//********************************************** K_ExprNArrayElement ***
//  Get Array Element Pointer
// SPL: function _ElemPointer( Arr: ArrayOf Undef; Ind:Int ): Undef;
//
procedure K_ExprNArrayElement( GC : TK_CSPLCont );
type  Params = packed record
  VR1: TK_RArray;
  DRType1 : TK_ExprExtType;
  VR2: Integer;
  DRType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  EP : Pointer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
{
    assert(
      (VR1 <> nil) and
      ((DRType1.D.TFlags and K_ffArray ) <> 0),
      'Empty array  or wrong operand type' );
}
    if (VR1 = nil) or
       ((DRType1.D.TFlags and K_ffArray ) = 0) then
      raise TK_SPLRunTimeError.Create( 'Empty array or wrong operand type' );
    if VR2 < 0 then VR2 := VR1.ElemCount + VR2;
    EP := VR1.P( VR2 );
    DRType1 := K_GetExecTypeBaseCode(VR1.ElemType); // Get Array Real Element Type
    VR1.ARelease;
    Pointer(VR1) := EP;
    Inc( DRType1.D.TFlags, K_ffPointer );
    Inc( GC.ExprStackLevel, SizeOf(VR1) + SizeOf(DRType1) );
  end;
end; //*** end of K_ExprNArrayElement ***

//********************************************** K_ExprNCreateInstance ***
//  Create Object Instance
//
procedure K_ExprNCreateInstance( GC : TK_CSPLCont );
type  Params = packed record
  V1: TK_UDRArray;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^, DType1.FD do begin
//    assert( DType1.FD.ObjType = K_fdtClass, 'Wrong Class Instance Description' );
    if FDObjType <> K_fdtClass then
      raise TK_SPLRunTimeError.Create( 'Wrong Class Instance Description' );
    V1 := CreateUDInstance;
    V1.ObjName := ObjName + '_' + IntToStr( Integer(V1) );
    with GC do begin
      if LocalUDRoot = nil then
        LocalUDRoot := TN_UDBase.Create;
      LocalUDRoot.AddOneChild( V1 );
    end;
  end;
  Inc( GC.ExprStackLevel, SizeOf(Params) );
end; //*** end of K_ExprNCreateInstance ***

//********************************************** K_ExprNCallMethod ***
//  Call Class Method
//
procedure K_ExprNCallMethod( GC : TK_CSPLCont );
type  Params = packed record
  V1: TK_UDRArray;
  DType1 : TK_ExprExtType;
  V2: Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  PFD : TK_POneFieldExecDescr;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if (V1 = nil) or (V1.AHigh < 0) then
      raise TK_SPLRunTimeError.Create( 'Program item is absent or not compiled' );
//***  Convert UDClass to Pointer to Class Instance Record
    DType1.DTCode := V1.R.ElemType.DTCode;
//    DType1.FD := TK_UDFieldsDescr( V1.GetLDataDescr );
    Pointer(V1) := V1.R.P;
//    Pointer(V1) := @V1.R.V[0];
    DType1.D.TFlags := DType1.D.TFlags and not K_ffUDRARef;
    Inc( DType1.D.TFlags, K_ffPointer );
//***  Get Class Method Program Item Address by Class Method Index
    PFD := DType1.FD.GetFieldDescrByInd( V2 );
    V2 := PFD.DataPos; //***  In method case DataPos contains Method Pointer (UDBase)
    DType2.All := Ord( nptUDRef );
    Inc( GC.ExprStackLevel, SizeOf(Params) );
  end;
//*** Make Call to SPL Routine
  K_ExprNCallRoutine( GC );
end; //*** end of K_ExprNCallMethod ***

//********************************************** K_ExprNGetInstance ***
//  Get Pointer To Class Object
//
procedure K_ExprNGetInstance( GC : TK_CSPLCont );
type  Params = packed record
  V1: TK_UDRArray;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
//    assert( (V1 <> nil) and (V1.AHigh >= 0), 'No instance' );
    if (V1 = nil) or (V1.AHigh < 0) then
      raise TK_SPLRunTimeError.Create( 'No instance' );
    Pointer(V1) := V1.R.P;
    DType1 := GC.ExecFuncType;
    DType1.D.TFlags := DType1.D.TFlags and not K_ffUDRARef;
    Inc( DType1.D.TFlags, K_ffPointer );
    Inc( GC.ExprStackLevel, SizeOf(Params) );
  end;
end; //*** end of K_ExprNGetInstance ***

//********************************************** K_ExprNSubArray ***
//  Create Sub Array
// SPL: function  SubArray( Arr: ArrayOf Undef; Ind:Integer; Count:Integer; CFlags : Integer ) : ArrayOf Undef;
//
procedure K_ExprNSubArray( GC : TK_CSPLCont );
type  Params = packed record
  R: TK_RArray;
  DType1 : TK_ExprExtType;
  Ind: Integer;
  DType2 : TK_ExprExtType;
  Count: Integer;
  DType3 : TK_ExprExtType;
  CFlags : Integer;
  DType4 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
//    assert( R <> nil, 'Empty array' );
    if (R = nil) then
      raise TK_SPLRunTimeError.Create( 'Empty array' );
    K_RFreeAndCopy( R, R, TK_MoveDataFlags(Byte(CFlags)), Ind, Count );
    R.AAddRef; // Because is put to Stack
    Inc( GC.ExprStackLevel, SizeOf(R) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNSubArray ***

//********************************************** K_ExprNGetSubArray ***
//  Create Sub Array
// SPL: function  GetSubArray( Arr: ArrayOf Undef; Ind:Integer; Count:Integer; CFlags : TK_MoveDataFlags ) : ArrayOf Undef;
//
procedure K_ExprNGetSubArray( GC : TK_CSPLCont );
type  Params = packed record
  R: TK_RArray;
  DType1 : TK_ExprExtType;
  Ind: Integer;
  DType2 : TK_ExprExtType;
  Count: Integer;
  DType3 : TK_ExprExtType;
  CFlags : TK_MoveDataFlags;
  DType4 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
//    assert( R <> nil, 'Empty array' );
    if (R = nil) then
      raise TK_SPLRunTimeError.Create( 'Empty array' );
    K_RFreeAndCopy( R, R, CFlags, Ind, Count );
    R.AAddRef; // Because is put to Stack
    Inc( GC.ExprStackLevel, SizeOf(R) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNGetSubArray ***

//********************************************** K_ExprNSetElements ***
//  Set Array Elements
// SPL: procedure SetElements( Arr: ArrayOf Undef; Ind:Integer; Count:Integer; Src:^Undef );
//
procedure K_ExprNSetElements( GC : TK_CSPLCont );
type  Params = packed record
  R: TK_RArray;
  DType1 : TK_ExprExtType;
  Ind: Integer;
  DType2 : TK_ExprExtType;
  Count: Integer;
  DType3 : TK_ExprExtType;
  PData: Pointer;
  DType4 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
//    assert( R <> nil, 'Empty array' );
    if (R = nil) then
      raise TK_SPLRunTimeError.Create( 'Empty array' );
    R.SetElems( PData^, false, Ind, Count );
    R.ARelease;
  end;

end; //*** end of K_ExprNSetElements ***

//********************************************** K_ExprNNewArrayByTypeCode ***
//SPL: function NewArrayByTypeCode( Count : Integer; DType : TypeCode; CFlags : TK_CreateRAFlags ) : ArrayOf Undef
//
procedure K_ExprNNewArrayByTypeCode( GC : TK_CSPLCont );
type  Params = packed record
  Count : Integer;
  DType1 : TK_ExprExtType;
  DType : TK_ExprExtType;
  DType2 : TK_ExprExtType;
  CFlags : TK_CreateRAFlags;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    TK_RArray(Count) := K_RCreateByTypeCode( DType.All, Count, CFlags );
    TK_RArray(Count).AAddRef; // Because is put to Stack
    Inc( GC.ExprStackLevel, SizeOf(Count) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNNewArrayByTypeCode ***

//********************************************** K_ExprNNewArrayByTypeName ***
//SPL: function NewArrayByTypeName( Count : Integer; TypeName : string; CFlags : TK_CreateRAFlags ) : ArrayOf Undef
//
procedure K_ExprNNewArrayByTypeName( GC : TK_CSPLCont );
type  Params = packed record
  Count : Integer;
  DType1 : TK_ExprExtType;
  TypeName : string;
  DType2 : TK_ExprExtType;
  CFlags : TK_CreateRAFlags;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    TK_RArray(Count) := K_RCreateByTypeName( TypeName, Count, CFlags );
    TK_RArray(Count).AAddRef; // Because is put to Stack
    TypeName := ''; // Free String in SPL Stack
    Inc( GC.ExprStackLevel, SizeOf(Count) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNNewArrayByTypeName ***

//********************************************** K_ExprNAElemTypeCode ***
//SPL: function  AElemTypeCode( Arr: ArrayOf Undef ) : TypeCode;
//
procedure K_ExprNAElemTypeCode( GC : TK_CSPLCont );
var
  Arr : TK_RArray;
  DType1 : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( Arr, DType1.All );
  DType1 := K_GetExecTypeBaseCode(Arr.ElemType);
  Arr.ARelease;
  GC.PutDataToExprStack  ( DType1, Ord(nptType) );
end; //*** end of K_ExprNAElemTypeCode ***

//********************************************** K_ExprNAElemTypeName ***
//SPL: function  AElemTypeName( Arr: ArrayOf Undef ) : String;
//
procedure K_ExprNAElemTypeName( GC : TK_CSPLCont );
var
  Arr : TK_RArray;
  DType1 : TK_ExprExtType;
  TypeName :  string;
begin
  GC.GetDataFromExprStack( Arr, DType1.All );
  TypeName := K_GetExecTypeName(Arr.ElemType.All);
  Arr.ARelease;
  GC.PutDataToExprStack  ( TypeName, Ord(nptString) );
end; //*** end of K_ExprNAElemTypeName ***

//********************************************** K_ExprNATypeName ***
//SPL: function  ATypeName( Arr: ArrayOf Undef ) : String;
//
procedure K_ExprNATypeName( GC : TK_CSPLCont );
var
  Arr : TK_RArray;
  DType1 : TK_ExprExtType;
  TypeName :  string;
begin
  GC.GetDataFromExprStack( Arr, DType1.All );
  TypeName := K_GetExecTypeName(Arr.GetComplexType.All);
  Arr.ARelease;
  GC.PutDataToExprStack  ( TypeName, Ord(nptString) );
end; //*** end of K_ExprNATypeName ***

//********************************************** K_ExprNMove ***
//  Set Array Elements
// SPL: procedure Move( PSrc: ^Undef; PDest: ^Undef; Count:Integer );
//
procedure K_ExprNMove( GC : TK_CSPLCont );
type  Params = packed record
  PSrc: Pointer;
  DType1 : TK_ExprExtType;
  PDest: Pointer;
  DType2 : TK_ExprExtType;
  Count: Integer;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Move( PSrc^, PDest^, Count );
  end;
end; //*** end of K_ExprNMove ***

//********************************************** K_ExprNSLength ***
//  Get String Length
// SPL: function  SLength( Str: String ) : Integer;
//
procedure K_ExprNSLength( GC : TK_CSPLCont );
type  Params = packed record
  Str: string;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
  Leng : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Leng := Length( Str );
    Str := ''; // free String
    Integer(Str) := Leng;
    DType1.All := Ord( nptInt );
    Inc( GC.ExprStackLevel, SizeOf(Params) );
  end;
end; //*** end of K_ExprNSLength ***

//********************************************** K_ExprNALength ***
//  Get Array Length
// SPL: function  ALength( Arr: ArrayOf Undef ) : Integer;
//
procedure K_ExprNALength( GC : TK_CSPLCont );
type  Params = packed record
  RR : TK_RArray;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
  Leng : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if RR <> nil then begin
      Leng := RR.ALength;
      RR.ARelease;
    end else
      Leng := 0;
    Integer(RR) := Leng;
    DType1.All := Ord( nptInt );
    Inc( GC.ExprStackLevel, SizeOf(Params) );
  end;
end; //*** end of K_ExprNALength ***

//********************************************** K_ExprNFillElements ***
//  Set Array Elements
// SPL: procedure FillElements( Arr: ArrayOf Undef; Ind:Integer; Count:Integer; Src:^Undef );
//
procedure K_ExprNFillElements( GC : TK_CSPLCont );
type  Params = packed record
  R: TK_RArray;
  DType1 : TK_ExprExtType;
  Ind: Integer;
  DType2 : TK_ExprExtType;
  Count: Integer;
  DType3 : TK_ExprExtType;
  PData: Pointer;
  DType4 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
//    assert( R <> nil, 'Empty array' );
    if (R = nil) then
      raise TK_SPLRunTimeError.Create( 'Empty array' );
    R.SetElems( PData^, true, Ind, Count );
    R.ARelease;
  end;
end; //*** end of K_ExprNFillElements ***

//********************************************** K_ExprNInsElements ***
//  Insert Array Elements
// SPL: procedure InsElements( Arr: ArrayOf Undef; Ind:Integer; Count:Integer );
//
procedure K_ExprNInsElements( GC : TK_CSPLCont );
type  Params = packed record
  R: TK_RArray;
  DType1 : TK_ExprExtType;
  Ind: Integer;
  DType2 : TK_ExprExtType;
  Count: Integer;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
//    assert( R <> nil, 'Empty array' );
    if (R = nil) then
      raise TK_SPLRunTimeError.Create( 'Empty array' );
    R.InsertElems( Ind, Count );
    R.ARelease;
  end;
end; //*** end of K_ExprNInsElements ***

//********************************************** K_ExprNBeep ***
//
procedure K_ExprNBeep( GC : TK_CSPLCont );
begin
  Beep;
end; //*** end of K_ExprNBeep ***

//********************************************** K_ExprNRandom ***
//
procedure K_ExprNRandom( GC : TK_CSPLCont );
var
  Res : Double;
begin
  Res := Random;
  GC.PutDataToExprStack( Res, Ord( nptDouble ) );
end; //*** end of K_ExprNRandom ***

//********************************************** K_ExprNDelElements ***
//  Delete Array Elements
// SPL: procedure DelElements( Arr: ArrayOf Undef; Ind:Integer; Count:Integer );
//
procedure K_ExprNDelElements( GC : TK_CSPLCont );
type  Params = packed record
  R: TK_RArray;
  DType1 : TK_ExprExtType;
  Ind: Integer;
  DType2 : TK_ExprExtType;
  Count: Integer;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
//    assert( R <> nil, 'Empty array' );
    if (R = nil) then
      raise TK_SPLRunTimeError.Create( 'Empty array' );
    R.DeleteElems( Ind, Count );
    R.ARelease;
  end;
end; //*** end of K_ExprNDelElements ***

//********************************************** K_ExprNSubString ***
//  Create Sub String
// SPL: function  SubString( Str: String; Ind:Integer; Count:Integer ) : String;
//
procedure K_ExprNSubString( GC : TK_CSPLCont );
type  Params = packed record
  Str: string;
  DType1 : TK_ExprExtType;
  Ind: Integer;
  DType2 : TK_ExprExtType;
  Count: Integer;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Str := Copy( Str, Ind, Count );
    Inc( GC.ExprStackLevel, SizeOf(Str) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNSubString ***

//********************************************** K_ExprNStrToNumber ***
//  Converts the String value to its numeric representation
//  ( Like Delphi Val(S; var V; var Code: Integer); )
//  Result is -1 if PValue Type is Wrong,
//             0 if String is Valid
//            >0 Zero-based Error String Position + 1
// SPL: function StrToNumber( Str: String; PVal : ^Undef ) : Integer;
//
procedure K_ExprNStrToNumber( GC : TK_CSPLCont );
type  Params = packed record
  Str: string;
  DType1 : TK_ExprExtType;
  PVal: Pointer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  IBuf : Int64;
  EBuf : Extended;
  Res : Integer;
  OpType : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    DType2 := K_GetExecTypeBaseCode( DType2 );
    Res := -1;
    OpType := 0;
    if DType2.D.TFlags = K_ffPointer then begin
      case DType2.DTCode of
        Ord(nptByte), Ord(nptInt2), Ord(nptInt),
        Ord(nptHex), Ord(nptColor), Ord(nptInt1),
        Ord(nptUInt2), Ord(nptUInt4), Ord(nptInt64): OpType := 1;
        Ord(nptDouble), Ord(nptFloat): OpType := 2;
      end;

      case OpType of
        1 : begin
          Val( Str, IBuf, Res );
          if Res = 0 then
            Move( IBuf, PVal^, K_GetExecTypeSize( DType2.DTCode ) );
        end;
        2 : begin
          Str := K_ReplaceCommaByPoint( Str );
          Val( Str, EBuf, Res );
          if Res = 0 then begin
            if DType2.DTCode = Ord(nptDouble) then
              PDouble(PVal)^ := EBuf
            else
              PFloat(PVal)^ := EBuf;
          end;
        end;
      end;
    end;
    Str := '';  // Free Str Param
    PInteger(PP)^ := Res;
    DType1.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(Integer) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNStrToNumber ***

//********************************************** K_ExprNTranspMatrix ***
// SPL: procedure TranspMatrix( Arr: ArrayOf Undef );
//
procedure K_ExprNTranspMatrix( GC : TK_CSPLCont );
var
  RA : TK_RArray;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( RA, DType.All );
  RA.TranspElems;
end; //*** end of K_ExprNTranspMatrix ***

//********************************************** K_ExprNCopySubMatrix ***
// SPL: function CopySubMatrix( DArr: ArrayOf Undef; DCInd: Integer; DRInd: Integer;
//                              SArr: ArrayOf Undef; SCInd: Integer; SRInd: Integer;
//                              PCCount: ^Integer; PRCount: ^Integer; CFlags : TK_MoveDataFlags ) : Integer;
//
procedure K_ExprNCopySubMatrix( GC : TK_CSPLCont );
type  Params = packed record
  DArr: TK_RArray;
  DType1 : TK_ExprExtType;
  DCInd  : Integer;
  DType2 : TK_ExprExtType;
  DRInd  : Integer;
  DType3 : TK_ExprExtType;
  SArr: TK_RArray;
  DType4 : TK_ExprExtType;
  SCInd  : Integer;
  DType5 : TK_ExprExtType;
  SRInd  : Integer;
  DType6 : TK_ExprExtType;
  PCCount : PInteger;
  DType7 : TK_ExprExtType;
  PRCount : PInteger;
  DType8 : TK_ExprExtType;
  CFlags : TK_MoveDataFlags;
  DType9 : TK_ExprExtType;
end;
var
  PP : ^Params;
  DataSize, DestCCount, SrcCCount : Integer;
  SEDType : TK_ExprExtType;
  DEDType : TK_ExprExtType;
  RaiseExcept : Boolean;
  Res : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    RaiseExcept := false;
    Res := 0;
    if (SArr <> nil)                                    and
       (DArr <> nil)                                    and
       SArr.CalcColsCount( SCInd, PCCount^, SrcCCount ) and
       SArr.CalcRowsCount( SRInd, PRCount^, SrcCCount ) and
       DArr.CalcColsCount( DCInd, PCCount^, DestCCount )and
       DArr.CalcRowsCount( DRInd, PRCount^, DestCCount ) then begin
      SEDType := K_GetExecTypeBaseCode(SArr.ElemType);
      DEDType := K_GetExecTypeBaseCode(DArr.ElemType);
      RaiseExcept := ((SEDType.All xor DEDType.All) and K_ffCompareTypesMask) <> 0;
      if not RaiseExcept then begin
        DataSize := SArr.ElemSize;
        Res := K_MoveSPLMatrixBySIndex( DArr.PME(DCInd, DRInd)^, DataSize, DataSize * DestCCount,
                                  SArr.PME(SCInd, SRInd)^, DataSize, DataSize * SrcCCount,
                                  PCCount^, PRCount^, SEDType.All, CFlags );
//        Res := K_MoveSPLMatrixBySIndex( DArr.PME(DCInd, DRInd)^, DataSize, DataSize * DestCCount,
//                                  SArr.PME(SCInd, SRInd)^, DataSize, DataSize * SrcCCount,
//                                  PCCount^, PRCount^, SEDType.All, CFlags );
      end;
    end;
    SArr.ARelease;
    DArr.ARelease;
    if RaiseExcept then
      raise TK_SPLRunTimeError.Create( 'Not equal coping data types "'+
        K_GetExecTypeName(SEDType.All)+'" and '+'"'+
        K_GetExecTypeName(DEDType.All)+'"' );
    PInteger(PP)^ := Res;
    DType1.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(Integer) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNCopySubMatrix ***

//********************************************** K_ExprNARowsRangeCount ***
// SPL: function  ARowsRangeCount( Arr: ArrayOf Undef; Ind : Integer; Count : Integer ) : Integer;
//
procedure K_ExprNARowsRangeCount( GC : TK_CSPLCont );
type  Params = packed record
  Arr: TK_RArray;
  DType1 : TK_ExprExtType;
  Ind  : Integer;
  DType2 : TK_ExprExtType;
  Count : Integer;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
  Res : Integer;
  RowLength : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Res := -1;
    if (Arr <> nil) and
       Arr.CalcRowsCount( Ind, Count, RowLength ) then Res := Count;
    Arr.ARelease;
    PInteger(PP)^ := Res;
    DType1.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(Integer) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNARowsRangeCount ***

//********************************************** K_ExprNAColsRangeCount ***
// SPL: function  AColsRangeCount( Arr: ArrayOf Undef; Ind : Integer; Count : Integer ) : Integer;
//
procedure K_ExprNAColsRangeCount( GC : TK_CSPLCont );
type  Params = packed record
  Arr: TK_RArray;
  DType1 : TK_ExprExtType;
  Ind  : Integer;
  DType2 : TK_ExprExtType;
  Count : Integer;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
  SrcCCount : Integer;
  Res : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Res := -1;
    if (Arr <> nil) and
       Arr.CalcColsCount( Ind, Count, SrcCCount ) then Res := Count;
    Arr.ARelease;
    PInteger(PP)^ := Res;
    DType1.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(Integer) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNAColsRangeCount ***

//********************************************** K_ExprNStrMatrixSearch ***
// SPL: function  StrMatrixSearch( SStr : string; SArr: ArrayOf string;
//                                 PCInd : ^Integer; PRInd : ^Integer;
//                                 CCount : Integer; RCount : Integer;
//                                 CFlags : Integer  ) : Integer;
//
procedure K_ExprNStrMatrixSearch( GC : TK_CSPLCont );
type  Params = packed record
  SStr: string;
  DType1 : TK_ExprExtType;
  SArr: TK_RArray;
  DType2 : TK_ExprExtType;
  PCInd  : PInteger;
  DType3 : TK_ExprExtType;
  PRInd  : PInteger;
  DType4 : TK_ExprExtType;
  CCount : Integer;
  DType5 : TK_ExprExtType;
  RCount : Integer;
  DType6 : TK_ExprExtType;
  CFlags : Integer;
  DType7 : TK_ExprExtType;
end;
var
  PP : ^Params;
  PE : PString;
  PS : PString;
  CRLength : Integer;
  Res, i, j, CInd, RInd : Integer;
  EQFlag : Boolean;
label FinSearch, SetResVal;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Res := -1;
    CInd := PCInd^;
    RInd := PRInd^;
    if (SArr <> nil)                                and
        SArr.CalcColsCount( CInd, CCount, CRLength ) and
        SArr.CalcRowsCount( RInd, RCount, CRLength ) then begin
       PS := SArr.PME( CInd, RInd );
       EQFlag := CFlags >= 0;
       for j := RInd to RInd + RCount - 1 do begin
         PE := PS;
         PRInd^ := j;
         for i := CInd to CInd + CCount - 1 do begin
           PCInd^ := i;
           if not (EQFlag xor ((PE)^ = SStr)) then begin
             Res := 0;
             goto FinSearch;
           end;
           Inc( PE );
         end;
         Inc( PS, SArr.HCol + 1 );
       end;
       if not EQFlag or (CFlags > 0) then begin
         if RCount > 1 then
           PRInd^ := RInd + RCount;
         if CCount > 1 then
           PCInd^ := CInd + CCount;
         if not EQFlag then Res := 0;
       end;
    end;
FinSearch:
    SArr.ARelease;
    SStr := '';
    PInteger(PP)^ := Res;
    DType1.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(Integer) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNStrMatrixSearch ***

//********************************************** K_ExprNCeil ***
// SPL: function  Ceil( DVal : Double ) : Double;
//
procedure K_ExprNCeil( GC : TK_CSPLCont );
type  Params = packed record
  D1: Double;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
    D1 := Ceil(D1);
  Inc( GC.ExprStackLevel, SizeOf(Double) + SizeOf( TK_ExprExtType ) );
end; //*** end of K_ExprNCeil ***

//********************************************** K_ExprNFloor ***
// SPL: function  Floor( DVal : Double ) : Double;
//
procedure K_ExprNFloor( GC : TK_CSPLCont );
type  Params = packed record
  D1: Double;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
    D1 := Floor(D1);
  Inc( GC.ExprStackLevel, SizeOf(Double) + SizeOf( TK_ExprExtType ) );
end; //*** end of K_ExprNFloor ***

//********************************************** K_ExprNRound ***
// SPL: function  Round( DVal : Double ) : Double;
//
procedure K_ExprNRound( GC : TK_CSPLCont );
type  Params = packed record
  D1: Double;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
    D1 := Round(D1);
  Inc( GC.ExprStackLevel, SizeOf(Double) + SizeOf( TK_ExprExtType ) );
end; //*** end of K_ExprNRound ***

//********************************************** K_ExprNSqrt ***
// SPL: function sqrt(Val : Double ) : Double;
//
procedure K_ExprNSqrt( GC : TK_CSPLCont );
type  Params = packed record
  Val      : Double;
  DType1   : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Val := Sqrt( Val );
    Inc( GC.ExprStackLevel, SizeOf(Double) + SizeOf( TK_ExprExtType ) );
  end;
end; //*** end of K_ExprNSqrt ***

//********************************************** K_ExprNAbs ***
// SPL: function abs(Val : Double ) : Double;
//
procedure K_ExprNAbs( GC : TK_CSPLCont );
type  Params = packed record
  Val      : Double;
  DType1   : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Val := Abs( Val );
    Inc( GC.ExprStackLevel, SizeOf(Double) + SizeOf( TK_ExprExtType ) );
  end;
end; //*** end of K_ExprNSqrt ***

//********************************************** K_ExprNStrToIBool ***
// SPL: function  StrToIBool( SV : String ) : Integer;
// returns -1 if SV is '0', 'f', 'F', 'n', 'N', 'í', 'Í' (0, false, no, íåò)
//  else returns 0
//
procedure K_ExprNStrToIBool( GC : TK_CSPLCont );
var
  SV : String;
  Res : Integer;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( SV, DType.All );
  Res := 0;
  if not N_StrToBool( SV ) then Res := -1;
  GC.PutDataToExprStack( Res, Ord(nptInt) );
end; //*** end of K_ExprNStrToIBool ***

//********************************************** K_ExprNUpperCase ***
// SPL: function  UpperCase( DVal : String ) : String;
//
procedure K_ExprNUpperCase( GC : TK_CSPLCont );
type  Params = packed record
  S1: string;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
    S1 := UpperCase(S1);
  Inc( GC.ExprStackLevel, SizeOf(string) + SizeOf( TK_ExprExtType ) );
end; //*** end of K_ExprNUpperCase ***

//********************************************** K_ExprNLowerCase ***
// SPL: function  LowerCase( DVal : String ) : String;
//
procedure K_ExprNLowerCase( GC : TK_CSPLCont );
type  Params = packed record
  S1: string;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
    S1 := LowerCase(S1);
  Inc( GC.ExprStackLevel, SizeOf(string) + SizeOf( TK_ExprExtType ) );
end; //*** end of K_ExprNLowerCase ***

//********************************************** K_ExprNToString ***
//  Convert Data To String
// SPL: function  ToString( PObj : ^Undef ) : String;
//
procedure K_ExprNToString( GC : TK_CSPLCont );
type  Params = packed record
  SP: Pointer;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
  StrBuf : string;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Dec(DType1.D.TFlags, K_ffPointer);
    StrBuf := K_SPLValueToString( SP^, DType1 );
    SP := nil;
    string(SP) := StrBuf;
    DType1.All := Ord(nptString);
    Inc( GC.ExprStackLevel, SizeOf(Params) );
  end;
end; //*** end of K_ExprNToString ***

//********************************************** K_ExprNShowEditData ***
//  Create Sub Array
// SPL: function  ShowEditData( Data : ^Undef; DataName: String; EditFlag : Integer ) : Integer;
//
procedure K_ExprNShowEditData( GC : TK_CSPLCont );
type  Params = packed record
  DP: Pointer;
  DType1 : TK_ExprExtType;
  Name: string;
  DType2 : TK_ExprExtType;
  EdMode: Integer;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
  Res : Boolean;
  ModeFlags : TK_RAModeFlagSet;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Dec(DType1.D.TFlags, K_ffPointer);
    move( EdMode, ModeFlags, SizeOf(ModeFlags) );
    Res := K_RAShowEdit( [], ModeFlags, DP^, DType1, Name );
//*** prepare Result
    if Res then
      Integer(DP) := 1
    else
      Integer(DP) := 0;
    DType1.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(Integer) + SizeOf(DType1) );
  end;
  Application.ProcessMessages;
end; //*** end of K_ExprNShowEditData ***

//********************************************** K_ExprNShowEditDataForm ***
//  Create Sub Array
// SPL: function  ShowEditDataForm( Data : ^Undef; DataName: String; EditFlags : Integer; FormDescr : Undef ) : Integer;
//
procedure K_ExprNShowEditDataForm( GC : TK_CSPLCont );
type  Params = packed record
  DP: Pointer;
  DType1 : TK_ExprExtType;
  Name: string;
  DType2 : TK_ExprExtType;
  EdMode: Integer;
  DType3 : TK_ExprExtType;
  FormDescr: TK_UDRArray;
  DType4 : TK_ExprExtType;
end;
var
  PP : ^Params;
  Res : Boolean;
  ModeFlags : TK_RAModeFlagSet;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Dec(DType1.D.TFlags, K_ffPointer);
    move( EdMode, ModeFlags, SizeOf(ModeFlags) );
    Res := K_RAShowEditByFormDescr( [], ModeFlags, DP^, DType1, Name, FormDescr );
//*** prepare Result
    if Res then
      Integer(DP) := 1
    else
      Integer(DP) := 0;
    DType1.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(Integer) + SizeOf(DType1) );
  end;
  Application.ProcessMessages;
end; //*** end of K_ExprNShowEditDataForm ***

//********************************************** K_ExprNShowDump ***
//  Show Dump Line
// SPL: ShowDump( DumpLine: String; InfoTag:Int );
//
procedure K_ExprNShowDump( GC : TK_CSPLCont );
type  Params = packed record
  V1: string;
  DType1 : TK_ExprExtType;
  V2: Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    GC.SPLGCDumpWatch.AddInfoLine( V1, V2 );
  end;
//Application.ProcessMessages;
end; //*** end of K_ExprNShowDump ***

//********************************************** K_ExprNShowFDump
//  Show Formated Dump Line
// SPL: ShowFDump( Fmt: String; Value : Undef );
//
procedure K_ExprNShowFDump( GC : TK_CSPLCont );
type  Params = packed record
  SF: string;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
  SP : Pointer;
  DType : TK_ExprExtType;
begin
  GC.GetPointerToExprStackData( SP, DType.All );
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  if (DType.D.TFlags and K_ffArray ) <> 0 then
    DType.All := Ord(nptNotDef);
  GC.SPLGCDumpWatch.AddInfoLine( K_SPLValueToString( SP^, DType, [], PP.SF ), 0 );
  PP.SF := ''; // free string
  K_FreeSPLData( SP^, DType.All );
end; //*** end of K_ExprNShowFDump ***

//********************************************** K_ExprNARowLength
//  Get Array Row Length
// SPL: ARowLength( Arr: ArrayOf Undef ) : Integer;
//
procedure K_ExprNARowLength( GC : TK_CSPLCont );
type  Params = packed record
  R : TK_RArray;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
  HighNum : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if R <> nil then begin
      HighNum := R.HCol;
      R.ARelease;
    end else
      HighNum := 0;
    Integer(R) := HighNum + 1;
    DType1.All := Ord( nptInt );
    Inc( GC.ExprStackLevel, SizeOf(Params) );
  end;
end; //*** end of K_ExprNARowLength ***

//********************************************** K_ExprNSetRowLength
//  Set Array Row Length
// SPL: SetRowLength( Arr: ArrayOf Undef; Size: Integer );
//
procedure K_ExprNSetRowLength( GC : TK_CSPLCont );
type  Params = packed record
  R : TK_RArray;
  DType1 : TK_ExprExtType;
  RLEng : Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  NLeng : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if R <> nil then begin
      RLeng := Max( 1, RLeng );
      NLeng := (R.ElemCount Div RLeng) * RLeng;
      R.ASetLength( NLeng );
      R.HCol := RLeng - 1;
      R.ARelease;
    end;
  end;
end; //*** end of K_ExprNSetRowLength ***

//********************************************** K_ExprNUDCursorInit ***
// SPL: procedure UDCursorInit( CurSorName:String; UDRoot:TN_UDBase; NameType:TK_UDObjNameType );
//
procedure K_ExprNUDCursorInit( GC : TK_CSPLCont );
type  Params = packed record
  SS : string;
  DType2 : TK_ExprExtType;
  UDRoot : TN_UDBase;
  DType1 : TK_ExprExtType;
  NT : TK_UDObjNameType;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
  CInd  : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
  if not K_UDCursorsList.Find( SS, CInd ) then
    TK_UDCursor.Create( SS, UDRoot, NT )
  else begin
    with TK_UDCursor(K_UDCursorsList.Objects[CInd]) do begin
      SetRoot(UDRoot);
      ObjNameType := NT;
    end;
  end;
end; //*** end of K_ExprNUDCursorInit ***

//********************************************** K_ExprNStringToUDRef ***
// SPL: function UDP( DPath:String ) : Undef;
//
procedure K_ExprNStringToUDRef( GC : TK_CSPLCont );
var
  SS : string;
  DType : TK_ExprExtType;
  PData  : Pointer;
  Ind : Integer;
begin
  GC.GetDataFromExprStack( SS, DType.All );
  DType := K_UDCursorGetFieldPointer( SS, PData, nil, @Ind );
  if (DType.DTCode = -1) or (PData = nil) then
    K_DataPathError( 'Data path error:', SS, Ind );
  GC.PutDataToExprStack( PData, DType.All );
end; //*** end of K_ExprNStringToUDRef ***

//********************************************** K_ExprNUDRDataRef ***
// SPL: function UDRPath( UDRoot:TN_UDBase; DPath:String; NameType:TK_UDObjNameType ) : Undef;
// SPL: function UDRP( UDRoot:TN_UDBase; DPath:String; NameType:TK_UDObjNameType ) : Undef;
//
procedure K_ExprNUDRDataRef( GC : TK_CSPLCont );
type  Params = packed record
  UD : TN_UDBase;
  DType1 : TK_ExprExtType;
  SS : string;
  DType2 : TK_ExprExtType;
  NT : TK_UDObjNameType;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
  DType : TK_ExprExtType;
  PData  : Pointer;
  Path : string;
  Ind : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  DType := K_GetUDFieldPointerByRPath( PP.UD, PP.SS, PData, PP.NT, nil, @Ind );
  Path := PP.SS;
  PP.SS := '';
  if DType.DTCode = -1 then
    K_DataPathError( 'Data path error:', Path, Ind );
  GC.PutDataToExprStack( PData, DType.All );
end; //*** end of K_ExprNUDRDataRef ***

//********************************************** K_ExprNUDRFieldRef ***
// SPL: function UDFP( UDRoot:TN_UDBase; DPath:String ) : Undef;
//
procedure K_ExprNUDRFieldRef( GC : TK_CSPLCont );
type  Params = packed record
  UD : TN_UDBase;
  DType1 : TK_ExprExtType;
  SS : string;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  DType : TK_ExprExtType;
  PData  : Pointer;
  Path : string;
  Ind : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  Path := K_udpFieldDelim + PP.SS;
  PP.SS := '';
  DType := K_GetUDFieldPointerByRPath( PP.UD, Path, PData, K_ontObjName, nil, @Ind );
  if DType.DTCode = -1 then
    K_DataPathError( 'Data path error:', Path, Ind );
  GC.PutDataToExprStack( PData, DType.All );
end; //*** end of K_ExprNUDRFieldRef ***

//********************************************** K_ExprNUDChildByInd ***
// SPL: function UDChildByInd( UDParent:TN_UDBase; ChildInd:Integer ):TN_UDBase;
//
procedure K_ExprNUDChildByInd( GC : TK_CSPLCont );
type  Params = packed record
  UD : TN_UDBase;
  DType1 : TK_ExprExtType;
  II : Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
    UD := UD.DirChild( II );
  Inc( GC.ExprStackLevel, SizeOf(TN_UDBase) + SizeOf(TK_ExprExtType) );
end; //*** end of K_ExprNUDChildByInd ***

//********************************************** K_ExprNUDDirHigh ***
// SPL: function UDDirHigh( Op1:TN_UDBase ):Int;
//
procedure K_ExprNUDDirHigh( GC : TK_CSPLCont );
type  Params = packed record
  UD : TN_UDBase;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  H : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do H := UD.DirHigh;
  GC.PutDataToExprStack( H, Ord(nptInt) );
end; //*** end of K_ExprNUDDirHigh ***

//********************************************** K_ExprNUDDirLength ***
// SPL: function UDDirLength( Op1:TN_UDBase ):Int;
//
procedure K_ExprNUDDirLength( GC : TK_CSPLCont );
type  Params = packed record
  UD : TN_UDBase;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  H : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do H := UD.DirLength;
  GC.PutDataToExprStack( H, Ord(nptInt) );
end; //*** end of K_ExprNUDDirLength ***

//********************************************** K_ExprNUDPutToParent ***
// SPL: procedure UDPutToParent( Parent:TN_UDBase; Ind:Integer; Child:TN_UDBase );
//
procedure K_ExprNUDPutToParent( GC : TK_CSPLCont );
type  Params = packed record
  UDP : TN_UDBase;
  DType1 : TK_ExprExtType;
  Ind : Integer;
  DType2 : TK_ExprExtType;
  UDC : TN_UDBase;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin

  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do UDP.PutDirChild( Ind, UDC );
end; //*** end of K_ExprNUDPutToParent ***

//********************************************** K_ExprNUDAddToParent ***
// SPL: function  UDAddToParent( Parent:TN_UDBase; Child:TN_UDBase ) : Int;
//
procedure K_ExprNUDAddToParent( GC : TK_CSPLCont );
type  Params = packed record
  UDP : TN_UDBase;
  DType1 : TK_ExprExtType;
  UDC : TN_UDBase;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  Ind : Integer;
begin

  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do Ind := UDP.InsOneChild( -1, UDC );
  GC.PutDataToExprStack( Ind, Ord(nptInt) );
end; //*** end of K_ExprNUDAddToParent ***

//********************************************** K_ExprNUDAddToOwner ***
// SPL: function  UDAddToOwner( Parent:TN_UDBase; Child:TN_UDBase ) : Int;
//
procedure K_ExprNUDAddToOwner( GC : TK_CSPLCont );
type  Params = packed record
  UDP : TN_UDBase;
  DType1 : TK_ExprExtType;
  UDC : TN_UDBase;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  Ind : Integer;
begin

  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    UDC.Owner := nil;
    Ind := UDP.InsOneChild( -1, UDC );
  end;
  GC.PutDataToExprStack( Ind, Ord(nptInt) );
end; //*** end of K_ExprNUDAddToOwner ***

//********************************************** K_ExprNUDComponentObject ***
// get reference to component UDBase from Dynamic context method
// SPL: function  _UDComponentObject(  ) : TN_UDBase;
//
procedure K_ExprNUDComponentObject( GC : TK_CSPLCont );
begin
  with GC do
    PutDataToExprStack(
      ExprCallStack[ExprCallStackLevel-1].ProgItem.SourceUnit.Owner,
      Ord(nptUDRef) );
end; //*** end of K_ExprNUDComponentObject ***

//********************************************** K_ExprNSetUDRefName ***
// SPL: procedure SetUDRefName( UD : UDRef; Name : String );
//
procedure K_ExprNSetUDRefName( GC : TK_CSPLCont );
type  Params = packed record
  UD : TN_UDBase;
  DType1 : TK_ExprExtType;
  SS : string;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  PP.UD.ObjName := PP.SS;
  PP.SS := ''; // free name string;
end; //*** end of K_ExprNSetUDRefName ***

//********************************************** K_ExprNCopyData ***
// SPL: procedure CopyData( DData : ^Undef; SData : ^Undef; Count : Integer; CFlags : CFlags:TK_MoveDataFlags );
//
procedure K_ExprNCopyData( GC : TK_CSPLCont );
type  Params = packed record

//!!  PPD : PChar;
  PPD : TN_BytesPtr;
  DType1 : TK_ExprExtType;
//!!  PPS : PChar;
  PPS : TN_BytesPtr;
  DType2 : TK_ExprExtType;
  Count : Integer;
  DType3 : TK_ExprExtType;
  CFlags : TK_MoveDataFlags;
  DType4 : TK_ExprExtType;
end;
var
  PP : ^Params;
  i : Integer;
  Step : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if ((DType1.All xor DType2.All) and K_ffCompareTypesMask) <> 0 then
      raise TK_SPLRunTimeError.Create( 'Not equal coping data types "'+
         K_GetExecTypeName(DType1.All)+'" and '+'"'+
         K_GetExecTypeName(DType2.All)+'"' );
    Dec(DType1.D.TFlags, K_ffPointer);
    Step := K_GetExecTypeSize( DType1.All );
    for i := 1 to Count do begin
      K_MoveSPLData( PPS^, PPD^, DType1, CFlags );
      Inc( PPS, Step );
      Inc( PPD, Step );
    end;
  end;
end; //*** end of K_ExprNCopyData ***

//********************************************** K_ExprNCompareData ***
// SPL: function  CompareData( PData1: ^Undef; PData2: ^Undef; Count:Integer ) : Integer;
//
procedure K_ExprNCompareData( GC : TK_CSPLCont );
type  Params = packed record
  PData1 : Pointer;
  DType1 : TK_ExprExtType;
  PData2 : Pointer;
  DType2 : TK_ExprExtType;
  Count : Integer;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
  Step : Integer;
  R : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    R := 0;
    if ((DType1.All xor DType2.All) and K_ffCompareTypesMask) = 0 then begin
      Dec(DType1.D.TFlags, K_ffPointer);
      Step := K_GetExecTypeSize( DType1.All );
      if K_CompareSPLVectors( PData1, Step, PData2, Step, Count, DType1.All ) then
        R := -1;
    end;
    Integer(PData1) := R;
    DType1.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(Integer) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNCompareData ***

//********************************************** K_ExprNPutVArray ***
// SPL: procedure PutVArray( PVArr : ^VArrayOf Undef; Arr: ArrayOf Undef )
//
procedure K_ExprNPutVArray( GC : TK_CSPLCont );
type  Params = packed record
  PVArr : TK_PRArray;
  DType1 : TK_ExprExtType;
  RR : TK_RArray;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    K_PutVRArray(  TObject(PVArr^), RR );
    RR.ARelease;
  end;
end; //*** end of K_ExprNPutVArray ***

//********************************************** K_ExprNGetVArray ***
// SPL: function  GetVArray( VArr: VArrayOf Undef ) : ArrayOf Undef;
//
procedure K_ExprNGetVArray( GC : TK_CSPLCont );
type  Params = packed record
  VArr : TK_RArray;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
  RA : TK_RArray;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    RA := K_GetPVRArray( VArr )^;
    if RA <> VArr then
      VArr := RA.AAddRef; // VarArray is UDRArray -> Inc Counter because it is Put To Stack
    if RA <> nil then     // Correct RA Type
      DType1 := RA.ArrayType
    else
      DType1.D.TFlags := K_ffArray;
    Inc( GC.ExprStackLevel, SizeOf(Params) );
  end;
end; //*** end of K_ExprNGetVArray ***

//********************************************** K_ExprNPutArrayToUD ***
// SPL: procedure PutArrayToUD( UD : TN_UDBase; Arr: ArrayOf Undef );
//
procedure K_ExprNPutArrayToUD( GC : TK_CSPLCont );
type  Params = packed record
  UD : TK_UDRArray;
  DType1 : TK_ExprExtType;
  RR : TK_RArray;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
    if UD <> nil then begin
//      assert( (UD.ClassFlags and K_RArrayObjBit) <> 0, 'Target UDBase is not UDRArray' );
      if not K_IsUDRArray(UD) then
        raise TK_SPLRunTimeError.Create( 'Target UDBase is not UDRArray' );
      K_RFreeAndCopy( UD.R, RR, [K_mdfCountUDRef] );
      RR.ARelease;
    end;
end; //*** end of K_ExprNPutArrayToUD ***

//********************************************** K_ExprNGetArrayFromUD ***
// SPL: function  GetArrayFromUD( UD : TN_UDBase ) : ArrayOf Undef;
//
procedure K_ExprNGetArrayFromUD( GC : TK_CSPLCont );
type  Params = packed record
  UD : TK_UDRArray;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
  WType : TK_ExprExtType;
  RA : TK_RArray;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if UD <> nil then begin
      if not K_IsUDRArray(UD) then begin
//        raise TK_SPLRunTimeError.Create( 'Target UDBase is not UDRArray' );
        WType.All := Ord( nptNotDef );
        Inc( WType.D.TFlags, K_ffArray );
        RA := nil;
      end else begin
        WType := UD.R.ArrayType;
        RA := UD.R;
      end;
    end else begin
      WType.All := Ord( nptNotDef );
      Inc( WType.D.TFlags, K_ffArray );
      RA := nil;
    end;
    GC.PutDataToExprStack( RA, WType.All );
  end;
end; //*** end of K_ExprNGetArrayFromUD ***

//********************************************** K_ExprNSetUDRef ***
// SPL: procedure SetUDRef( PUD : ^TN_UDBase; NUD : TN_UDBase );
//
procedure K_ExprNSetUDRef( GC : TK_CSPLCont );
type  Params = packed record
  PUD : TN_PUDBase;
  DType1 : TK_ExprExtType;
  NUD : TN_UDBase;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    K_SetUDRefField( PUD^, NUD );
  end;
end; //*** end of K_ExprNSetUDRef ***

//********************************************** K_ExprNExecComponent ***
// SPL: procedure ExecComponent( UD : TN_UDBase );
//
procedure K_ExprNExecComponent( GC : TK_CSPLCont );
{
type  Params = packed record
  UDC : TK_UDComponent;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
}
begin
//  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
//  PP.UDC.ExecSubTree( GC );
end; //*** end of K_ExprNExecComponent ***

//********************************************** K_ExprNInsComponent ***
// SPL: function  procedure InsComponent(
//                UDParent : TN_UDBase; UDChild : TN_UDBase;
//                CInd : Integer; Flags : Integer );
//   Flags <> 0 - direct insertion
//   Flags =  0 - insert "Broker"
//
procedure K_ExprNInsComponent( GC : TK_CSPLCont );
{
type  Params = packed record
  UDP : TK_UDComponent;
  DType1 : TK_ExprExtType;
  UDC : TK_UDComponent;
  DType2 : TK_ExprExtType;
  CInd : Integer;
  DType3 : TK_ExprExtType;
  Flags : Integer;
  DType4 : TK_ExprExtType;
end;

var
  PP : ^Params;
}
begin
{
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    UDP.InsertChildComp( UDC, CInd, Flags <> 0 );
  end;
}
end; //*** end of K_ExprNInsComponent ***

//********************************************** K_ExprNUDCreate ***
// SPL: function  UDCreate( TypeName : String; ObjName : String ) : UDRef;
//
procedure K_ExprNUDCreate( GC : TK_CSPLCont );
type  Params = packed record
  TypeName : string;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
  ClassRefInd : Integer;
  UDBase : TN_UDBase;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^, GC do begin
    ClassRefInd := K_GetUObjCIByTagName( TypeName );
    TypeName := ''; // free string
    UDBase := N_ClassRefArray[ClassRefInd].Create;
    if LocalUDRoot = nil then
      LocalUDRoot := TN_UDBase.Create;
    LocalUDRoot.AddOneChild( UDBase );
    PutDataToExprStack( UDBase, Ord(nptUDRef) );
  end;

end; //*** end of K_ExprNUDCreate ***

//********************************************** K_ExprNBuildDPIndexes ***
// SPL: function BuildDPIndexes( Indexes : ArrayOf Integer;
//                UDCSSSrc : TN_UDBase; UDCSSDest : TN_UDBase;
//                UDProjName : string ) : Integer;
//
procedure K_ExprNBuildDPIndexes( GC : TK_CSPLCont );
type  Params = packed record
  RI : TK_RArray;
  DType1 : TK_ExprExtType;
  UDSCSS : TK_UDDCSSpace;
  DType2 : TK_ExprExtType;
  UDDCSS : TK_UDDCSSpace;
  DType3 : TK_ExprExtType;
  UDPN   : string;
  DType4 : TK_ExprExtType;
end;
var
  PP : ^Params;
  Res : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
//    assert( UDSCSS is TK_UDDCSSpace, 'Wrong Source CSS type' );
    if not (UDSCSS is TK_UDDCSSpace) then
      raise TK_SPLRunTimeError.Create( 'Wrong Source CSS type' );
//    assert( UDDCSS is TK_UDDCSSpace, 'Wrong Destination CSS type' );
    if not (UDDCSS is TK_UDDCSSpace) then
      raise TK_SPLRunTimeError.Create( 'Wrong Destination CSS type' );
    RI.ASetLength( UDDCSS.PDRA.ALength );
    if K_BuildDataProjection0( UDSCSS, UDDCSS, PInteger(RI.P), UDPN ) then
      Res := 0
    else
      Res := -1;
    GC.PutDataToExprStack( Res, Ord(nptInt) );
  end;
end; //*** end of K_ExprNBuildDPIndexes ***

//********************************************** K_ExprNStringToTDate ***
//
procedure K_ExprNStringToTDate( GC : TK_CSPLCont );
var
  D1 : TDateTime;
  S1 : string;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( S1, DType.All );
  D1 := K_StrToDateTime( S1);
  GC.PutDataToExprStack( D1,  Ord(nptTDate) );
end; //*** end of K_ExprNStringToTDate ***

//********************************************** K_ExprNTDateToString ***
//
procedure K_ExprNTDateToString( GC : TK_CSPLCont );
var
  D1 : TDateTime;
  S1 : string;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( D1, DType.All );
  S1 := K_DateTimeToSTr( D1 );
  GC.PutDataToExprStack( S1, Ord(nptString) );
end; //*** end of K_ExprNTDateToString ***

//********************************************** K_ExprNStringToType ***
//
procedure K_ExprNStringToType( GC : TK_CSPLCont );
var
  D1 : TK_ExprExtType;
  S1 : string;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( S1, DType.All );
  D1.DTCode := -1;
  try D1 := K_GetExecTypeCodeSafe( S1 ); except end;
  if D1.DTCode = -1 then D1.All := Ord(nptNotDef);
  GC.PutDataToExprStack( D1,  Ord(nptType) );
end; //*** end of K_ExprNStringToType ***

//********************************************** K_ExprNTypeToString ***
//
procedure K_ExprNTypeToString( GC : TK_CSPLCont );
var
  D1 : TK_ExprExtType;
  S1 : string;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( D1, DType.All );
  S1 := K_GetExecTypeName( D1.All );
  GC.PutDataToExprStack( S1, Ord(nptString) );
end; //*** end of K_ExprNTypeToString ***

//********************************************** K_ExprNTypeOfPointer0 ***
//SPL: function PType0( P : ^Undef; PType : ^TypeCode ) : Undef;
//
procedure K_ExprNTypeOfPointer0( GC : TK_CSPLCont );
type  Params = packed record
  P1 : Pointer;
  DType1 : TK_ExprExtType;
  P2 : Pointer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    DType2 := DType1;
    Dec(DType2.D.TFlags, K_ffPointer);
    TK_PExprExtType(P2)^ := DType2;
    Inc( GC.ExprStackLevel, SizeOf(P1)+SizeOf(DType1) );
  end;
end; //*** end of K_ExprNTypeOfPointer0 ***

//********************************************** K_ExprNTypedPointer0 ***
//SPL: function TypedP0( P : ^Undef; DType : TypeCode ) : Undef
//
procedure K_ExprNTypedPointer0( GC : TK_CSPLCont );
type  Params = packed record
  D1 : Pointer;
  DType1 : TK_ExprExtType;
  D2 : TK_ExprExtType;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    DType1 := D2;
    Inc(DType1.D.TFlags, K_ffPointer);
    Inc( GC.ExprStackLevel, SizeOf(D1)+SizeOf(DType1) );
  end;
end; //*** end of K_ExprNTypedPointer0 ***

//********************************************** K_ExprNTypeOfPointer ***
//SPL: function PType( P : ^Undef; PTypeName : ^String ) : Undef;
//
procedure K_ExprNTypeOfPointer( GC : TK_CSPLCont );
type  Params = packed record
  P1 : Pointer;
  DType1 : TK_ExprExtType;
  PTypeName : PString;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  DType : TK_ExprExtType;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    DType := DType1;
    Dec( DType.D.TFlags, K_ffPointer );
    (PTypeName)^ := K_GetExecTypeName(DType.All);
    Inc( GC.ExprStackLevel, SizeOf(P1)+SizeOf(DType1) );
  end;
end; //*** end of K_ExprNTypeOfPointer0 ***

//********************************************** K_ExprNTypedPointer ***
//SPL: function TypedP( P : ^Undef; TypeName : String ) : Undef
//
procedure K_ExprNTypedPointer( GC : TK_CSPLCont );
type  Params = packed record
  D1 : Pointer;
  DType1 : TK_ExprExtType;
  TypeName : string;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    DType1 := K_GetTypeCodeSafe(TypeName);
    TypeName := ''; // Free String in SPL Stack
    Inc( DType1.D.TFlags, K_ffPointer );
    Inc( GC.ExprStackLevel, SizeOf(D1)+SizeOf(DType1) );
  end;
end; //*** end of K_ExprNTypedPointer ***

//********************************************** K_ExprNPField ***
//SPL: function  PField( P : ^Undef; FieldPath : String ) : ^Undef;
//
procedure K_ExprNPField( GC : TK_CSPLCont );
type  Params = packed record
  P : Pointer;
  DType1 : TK_ExprExtType;
  FieldPath : string;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  Ind : Integer;
  DType : TK_ExprExtType;
  PField : Pointer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Dec( DType1.D.TFlags, K_ffPointer );
    DType := K_GetFieldPointer( P, DType1, FieldPath, PField, @Ind );
    if DType.DTCode = -1 then
      K_DataPathError( 'Data path error:', FieldPath, Ind - 1 );
    Inc( DType.D.TFlags, K_ffPointer );
    GC.PutDataToExprStack( PField, DType.All );
  end;
end; //*** end of K_ExprNPField ***

{
//********************************************** K_ExprNTDateToDouble ***
//
procedure K_ExprNTDateToDouble( GC : TK_CSPLCont );
begin
  with GC do
    PInt64(@ExprStack[ExprStackLevel-SizeOf(TK_ExprExtType)])^ := Ord(nptDouble);
end; //*** end of K_ExprNTDateToDouble ***

//********************************************** K_ExprNDoubleToTDate ***
//
procedure K_ExprNDoubleToTDate( GC : TK_CSPLCont );
begin
  with GC do
    PInt64(@ExprStack[ExprStackLevel-SizeOf(TK_ExprExtType)])^ := Ord(nptTDate);
end; //*** end of K_ExprNDoubleToTDate ***
}

//********************************************** K_ExprNShowMessage ***
// SPL: procedure ShowMessage( Mes : String );
//
procedure K_ExprNShowMessage( GC : TK_CSPLCont );
var
  S1 : string;
  DType : TK_ExprExtType;
begin
  GC.GetDataFromExprStack( S1, DType.All );
  K_ShowMessage( S1 );
end; //*** end of K_ExprNShowMessage ***


//********************************************** K_ExprNGetPascalHandle ***
// SPL: function  GetPascalHandle( ObjName: String ) : TPascalHandle; (Pointer)
//
procedure K_ExprNGetPascalHandle( GC : TK_CSPLCont );
type  Params = packed record
  Handle : Integer;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
  ObjInd : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    ObjInd := K_PascalHandles.IndexOf( string(Handle) );
    string(Handle) := ''; // clear string param
    if ObjInd <> -1 then
      Handle := Integer( K_PascalHandles.Objects[ObjInd] )
    else
      Handle := ObjInd;
    Inc( GC.ExprStackLevel, SizeOf(Params) );
  end;
end; //*** end of K_ExprNGetPascalHandle ***

//********************************************** K_ExprNPascalNotifyFunc ***
// SPL: PascalNotifyFunc( PascalHandle : TPascalHandle; FParams : ^Undef ) : Integer;
//
procedure K_ExprNPascalNotifyFunc( GC : TK_CSPLCont );
type  Params = packed record
  Handle : Integer;
  DType1 : TK_ExprExtType;
  FParams: Pointer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if Handle <> 0 then
      Handle := TK_NotifyFunc(Handle)( FParams, DType2.All );
    DType1.All := Ord( nptInt );
    Inc( GC.ExprStackLevel, SizeOf(Handle) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNPascalNotifyFunc ***

//********************************************** K_ExprNGetTime ***
//
procedure K_ExprNGetTime( GC : TK_CSPLCont );
var
  D1 : TDateTime;
begin
  D1 := Time;
  GC.PutDataToExprStack( D1,  Ord(nptTDateTime) );
end; //*** end of K_ExprNGetTime ***

//********************************************** K_ExprNGetDate ***
//
procedure K_ExprNGetDate( GC : TK_CSPLCont );
var
  D1 : TDateTime;
begin
  D1 := Date;
  GC.PutDataToExprStack( D1,  Ord(nptTDate) );
end; //*** end of K_ExprNGetDate ***

//********************************************** K_ExprNEQStrings ***
//
procedure K_ExprNEQStrings( GC : TK_CSPLCont );
type  Params = packed record
  V1: string;
  DType1 : TK_ExprExtType;
  V2: string;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  R: Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if V1 = V2 then
      R := -1
    else
      R := 0;
    V2 := '';
    V1 := '';
    Integer(V1) := R;
    DType1.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(V1) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNEQStrings ***

//********************************************** K_ExprNEQInts ***
//
procedure K_ExprNEQInts( GC : TK_CSPLCont );
type  Params = packed record
  V1: Integer;
  DType1 : TK_ExprExtType;
  V2: Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  R : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if V1 = V2 then
      R := -1
    else
      R := 0;
    V1 := R;
    Inc( GC.ExprStackLevel, SizeOf(V1) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNEQInts ***

//********************************************** K_ExprNEQDoubles ***
//
procedure K_ExprNEQDoubles( GC : TK_CSPLCont );
type  Params = packed record
    case Integer of
0:(
  V1: Double;
  DType1 : TK_ExprExtType;
  V2: Double;
  DType2 : TK_ExprExtType;);
1:(
  R: Integer;
  DTypeR : TK_ExprExtType;);
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if V1 = V2 then
      R := -1
    else
      R := 0;
    DTypeR.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(R) + SizeOf(DTypeR) );
  end;
end; //*** end of K_ExprNEQDoubles ***

//********************************************** K_ExprNEQFloats ***
//
procedure K_ExprNEQFloats( GC : TK_CSPLCont );
type  Params = packed record
    case Integer of
0:(
  V1: Float;
  DType1 : TK_ExprExtType;
  V2: Float;
  DType2 : TK_ExprExtType;);
1:(
  R: Integer;
  DTypeR : TK_ExprExtType;);
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if V1 = V2 then
      R := -1
    else
      R := 0;
    DTypeR.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(R) + SizeOf(DTypeR) );
  end;
end; //*** end of K_ExprNEQFloats ***

//********************************************** K_ExprNLTInts ***
//
procedure K_ExprNLTInts( GC : TK_CSPLCont );
type  Params = packed record
  V1: Integer;
  DType1 : TK_ExprExtType;
  V2: Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  R : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if V1 < V2 then
      R := -1
    else
      R := 0;
    V1 := R;
    Inc( GC.ExprStackLevel, SizeOf(V1) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNLTInts ***

//********************************************** K_ExprNLTDoubles ***
//
procedure K_ExprNLTDoubles( GC : TK_CSPLCont );
type  Params = packed record
    case Integer of
0:(
  V1: Double;
  DType1 : TK_ExprExtType;
  V2: Double;
  DType2 : TK_ExprExtType;);
1:(
  R: Integer;
  DTypeR : TK_ExprExtType;);
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if V1 < V2 then
      R := -1
    else
      R := 0;
    DTypeR.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(R) + SizeOf(DTypeR) );
  end;
end; //*** end of K_ExprNLTDoubles ***

//********************************************** K_ExprNLTFloats ***
//
procedure K_ExprNLTFloats( GC : TK_CSPLCont );
type  Params = packed record
    case Integer of
0:(
  V1: Float;
  DType1 : TK_ExprExtType;
  V2: Float;
  DType2 : TK_ExprExtType;);
1:(
  R: Integer;
  DTypeR : TK_ExprExtType;);
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if V1 < V2 then
      R := -1
    else
      R := 0;
    DTypeR.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(R) + SizeOf(DTypeR) );
  end;
end; //*** end of K_ExprNLTFloats ***

//********************************************** K_ExprNGTInts ***
//
procedure K_ExprNGTInts( GC : TK_CSPLCont );
type  Params = packed record
  V1: Integer;
  DType1 : TK_ExprExtType;
  V2: Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  R : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if V1 > V2 then
      R := -1
    else
      R := 0;
    V1 := R;
    Inc( GC.ExprStackLevel, SizeOf(V1) + SizeOf(DType1) );
  end;
end; //*** end of K_ExprNGTInts ***

//********************************************** K_ExprNGTDoubles ***
//
procedure K_ExprNGTDoubles( GC : TK_CSPLCont );
type  Params = packed record
    case Integer of
0:(
  V1: Double;
  DType1 : TK_ExprExtType;
  V2: Double;
  DType2 : TK_ExprExtType;);
1:(
  R: Integer;
  DTypeR : TK_ExprExtType;);
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if V1 > V2 then
      R := -1
    else
      R := 0;
    DTypeR.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(R) + SizeOf(DTypeR) );
  end;
end; //*** end of K_ExprNGTDoubles ***

//********************************************** K_ExprNGTFloats ***
//
procedure K_ExprNGTFloats( GC : TK_CSPLCont );
type  Params = packed record
    case Integer of
0:(
  V1: Float;
  DType1 : TK_ExprExtType;
  V2: Float;
  DType2 : TK_ExprExtType;);
1:(
  R: Integer;
  DTypeR : TK_ExprExtType;);
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if V1 > V2 then
      R := -1
    else
      R := 0;
    DTypeR.All := Ord(nptInt);
    Inc( GC.ExprStackLevel, SizeOf(R) + SizeOf(DTypeR) );
  end;
end; //*** end of K_ExprNGTFloats ***

//********************************************** K_ExprNTreeViewUpdate ***
// SPL: procedure TreeViewUpdate( Mode : Integer );
//
procedure K_ExprNTreeViewUpdate( GC : TK_CSPLCont );
type  Params = packed record
  Mode : Integer;
  DType1 : TK_ExprExtType;
end;

var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if Mode > 0 then
      K_TreeViewsUpdateModeSet
    else
      K_TreeViewsUpdateModeClear( Mode = 0 )
  end;
end; //*** end of K_ExprNTreeViewUpdate ***

//*** End of SPL functions

{*** TK_RArray ***}

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\CreateByType
//************************************************** TK_RArray.CreateByType ***
// Records Array special class constructor
//
//     Parameters
// ADType - elements Type Code
// ACount - elements counter
//
constructor TK_RArray.CreateByType( ADType : Int64; ACount : Integer = 0 );
begin
  SetTypeInfo( TK_ExprExtType(ADType) );
  if (ACount > 0) or (AttrsSize > 0) then
    ASetLength( ACount );
end; // end of function TK_RArray.CreateByType

{
//********************************************** TK_RArray.Create ***
//
constructor TK_RArray.Create( ESize : Integer; ASize : Integer = 0 );
begin
  ElemSize  := ESize;
  AttrsSize := ASize;
end; // end of function TK_RArray.Create
}

//********************************************** TK_RArray.Destroy ***
//
destructor TK_RArray.Destroy;
begin
  ASetLength( 0 );
  if (AttrsSize > 0) and (VBuf <> nil) then
    K_FreeSPLData( VBuf[0], AttrsType.All,
        ((FEType.D.CFLags and (K_ccCountUDRef or K_ccStopCountUDRef)) = K_ccCountUDRef ) );
end; // end of destructor  TK_RArray.Destroy

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\AHigh
//********************************************************* TK_RArray.AHigh ***
// Get last Records Array Element index
//
//     Parameters
// Result - Returns index of Records Array last Element
//
function TK_RArray.AHigh: Integer;
begin
  Result := - 1;
  if Self <> nil then
    Inc(Result, ElemCount);

end; // end of function TK_RArray.AHigh

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\ALength(1)
//**************************************************** TK_RArray.ALength(1) ***
// Get Records Array Elements counter
//
//     Parameters
// Result - Returns Records Array Elements counter
//
function TK_RArray.ALength: Integer;
begin
  if Self <> nil then
    Result := ElemCount
  else
    Result := 0;
end; // end of function TK_RArray.ALength

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\ALength(2)
//**************************************************** TK_RArray.ALength(2) ***
// Get Records Array Matrix dimensions size
//
//     Parameters
// AColCount - resulting Records Array Matrix columns counter
// ARowCount - resulting Records Array Matrix rows counter
//
procedure TK_RArray.ALength( out AColCount, ARowCount : Integer );
begin
  ARowCount := 0;
  AColCount := 1;
  if Self <> nil then begin
    AColCount := HCol + 1;
    ARowCount := ElemCount div AColCount;
  end;
end; // end of function TK_RArray.ALength

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\AColCount
//***************************************************** TK_RArray.AColCount ***
// Get Records Array Matrix columns counter
//
//     Parameters
// Result - Returns Records Array Matrix columns counter
//
function TK_RArray.AColCount : Integer;
begin
  Result := 1;
  if Self = nil then Exit;
  Result := HCol + 1;
end; // end of function TK_RArray.AColCount

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\ARowCount
//***************************************************** TK_RArray.ARowCount ***
// Get Records Array Matrix rows counter
//
//     Parameters
// Result - Returns Records Array Matrix rows counter
//
function TK_RArray.ARowCount : Integer;
begin
  Result := 0;
  if Self = nil then Exit;
  Result := ElemCount div (HCol + 1);
end; // end of function TK_RArray.ARowCount

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\GetArrayType
//************************************************** TK_RArray.GetArrayType ***
// Get Records Array Type Code
//
//     Parameters
// Result - Returns Records Array Type Code
//
function TK_RArray.GetArrayType : TK_ExprExtType;
begin
  Result := GetComplexType;
  if Self = nil then Exit;
  Result.D.TFlags := Result.D.TFlags or K_ffArray;
end; // end of function TK_RArray.GetArrayType

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\GetAttrsType
//************************************************** TK_RArray.GetAttrsType ***
// Get Records Array Attributes Type Code
//
//     Parameters
// Result - Returns Records Array Attributes Type Code
//
function TK_RArray.GetAttrsType : TK_ExprExtType;
begin
  Result.All := 0;
//  Result.DTCode := -1;
  if Self = nil then Exit;
  Result.EFlags := FEType.EFlags;
  if AttrsSize > 0 then
    Result.DTCode := FADTCode
  else if ElemCount = 1 then
    Result.DTCode := FEType.DTCode;
end; // end of function TK_RArray.GetAttrsType

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\SetAttrsType
//************************************************** TK_RArray.SetAttrsType ***
// Set Records Array Attributes new Type Code
//
//     Parameters
// AttrsType - given Records Array Attributes Type Code
// Result    - Returns TRUE if prevoiuse Records Array Attributes Data was free
//
function TK_RArray.SetAttrsType( AttrsType : TK_ExprExtType ): Boolean;
var
  WELeng, WASize, DataShift : Integer;
//!!  PE0, PNE0 : PChar;
  PE0, PNE0 : TN_BytesPtr;
begin
  Result := false;
  if (Self = nil) or (FADTCode = AttrsType.DTCode) then Exit;

  if (AttrsSize > 0) and
     (FADTCode <> AttrsType.DTCode) then begin
    K_FreeSPLData( PA^, FADTCode, (FEType.EFlags.CFlags and K_ccCountUDRef) <> 0 );
    Result := true;
  end;

  if (AttrsType.EFlags.CFlags and K_ccCountUDRef) <> 0 then
    SetCountUDRef;

  WASize := 0;
  DataShift := K_GetExecTypeSize( AttrsType.All );
  if DataShift > 0 then
    WASize := DataShift;
  DataShift := WASize - AttrsSize;
  if DataShift <> 0 then begin
    WELeng := ElemCount * ElemSize;
    if DataShift > 0 then // Add New Space
      K_SetBArrayCapacity( VBuf, WASize + WELeng );

    PE0 := PV;
    PNE0 := PE0 + DataShift;

    if WELeng > 0 then
      Move( PE0^, PNE0^, WELeng );

    // Clear Free Space
    if DataShift < 0 then begin
      PE0 := PE0 + WELeng + DataShift;
      DataShift := -DataShift;
    end;

    FillChar( PE0^, DataShift, 0 )
  end;

  if AttrsType.DTCode > 0 then begin
    FADTCode := AttrsType.DTCode;
    AttrsSize := K_GetExecTypeSize( AttrsType.DTCode );
  end;

end; // end of procedure TK_RArray.SetAttrsType

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\GetElemType
//*************************************************** TK_RArray.GetElemType ***
// Get Records Array Elements Type Code
//
//     Parameters
// Result - Returns Records Array Elements Type Code
//
function TK_RArray.GetElemType : TK_ExprExtType;
begin
  Result.All := 0;
//  Result.DTCode := - 1;
  if Self = nil then Exit;
  Result := FEType;
end; // end of function TK_RArray.GetElemType

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\SetElemType
//*************************************************** TK_RArray.SetElemType ***
// Set Records Array Elements new Type Code
//
//     Parameters
// ADType - given Records Array Elements Type Code
//
procedure TK_RArray.SetElemType( ADType : TK_ExprExtType );
begin
  if Self = nil then Exit;
  if (FEType.DTCode <> Ord(nptNotDef)) and
     (((FEType.All xor ADType.All) and K_ectClearICFlags) <> 0) then
    FreeElemsData( 0, -1 );
  if (ADType.EFlags.CFlags and K_ccCountUDRef) <> 0 then
    SetCountUDRef;
  FEType := ADType;
  ElemSize := K_GetExecTypeSize( FEType.All );
  ASetLength(ElemCount);
end; // end of function TK_RArray.SetElemType

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\SetTypeInfo
//*************************************************** TK_RArray.SetTypeInfo ***
// Set Records Array Data Type Codes (Elements and Attributes) by Complex Type 
// Code
//
//     Parameters
// ACType - given Records Array Complex Type Code
//
procedure TK_RArray.SetTypeInfo( ACType: TK_ExprExtType );
var
  AElemType, AAttrsType : TK_ExprExtType;
begin
//
  AAttrsType := K_GetRArrayTypes( ACType, AElemType );
  FEType.EFlags := ACType.EFlags;
  if AAttrsType.DTCode <= Ord(nptNotDef) then
    FCETCode := 0
  else
    FCETCode := ACType.DTCode;

  if (ACType.EFlags.CFlags and K_ccCountUDRef) <> 0 then
    SetCountUDRef;

  ElemSize := 0;
  if (AElemType.EFlags.CFlags and K_ccCountUDRef) <> 0 then
    SetCountUDRef;
  if AElemType.DTCode >=Ord(nptNotDef) then begin
    FEType.DTCode := AElemType.DTCode;
    ElemSize := K_GetExecTypeSize( AElemType.All );
    if ElemSize < 0 then
      raise TK_SPLTypeNameError.Create( 'Wrong SPL type size' );
  end;

  AttrsSize := 0;
  if (AAttrsType.EFlags.CFlags and K_ccCountUDRef) <> 0 then
    SetCountUDRef;
  if AAttrsType.DTCode > 0 then begin
    FADTCode := AAttrsType.DTCode;
    AttrsSize := K_GetExecTypeSize( AAttrsType.DTCode );
  end;
end; // end of function TK_RArray.SetTypeInfo

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\GetAllTypes
//*************************************************** TK_RArray.GetAllTypes ***
// Get Records Array Data Type Codes
//
//     Parameters
// ACType    - Records Array Data Complex Type Code
// AElemType - Records Array Elements Type Code
// Result    - Returns Records Array Attributes Type Code
//
function  TK_RArray.GetAllTypes( var ACType: TK_ExprExtType;
                                 out AElemType : TK_ExprExtType ) : TK_ExprExtType;
begin
  if Self <> nil then begin
    ACType := ArrayType;
    AElemType := ElemType;
    Result := AttrsType;
  end else
    Result := K_GetRArrayTypes( ACType, AElemType );
end; // end of function TK_RArray.GetAllTypes

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\GetComplexType
//************************************************ TK_RArray.GetComplexType ***
// Get Records Array Data Complex Type Code
//
//     Parameters
// Result - Returns Records Array Data Complex Type Code
//
function TK_RArray.GetComplexType : TK_ExprExtType;
begin
  Result.All := 0;
//  Result.DTCode := -1;
  if Self = nil then Exit;
  Result := FEType;
  if (AttrsSize > 0) and (FCETCode > 0) then
    Result.DTCode := FCETCode
end; // end of function TK_RArray.GetComplexType

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\SetComplexType
//************************************************ TK_RArray.SetComplexType ***
// Set Records Array Data Complex Type Code
//
//     Parameters
// ACType - Records Array Data Complex Type Code
//
procedure TK_RArray.SetComplexType( ACType: TK_ExprExtType );
var
  AElemType, AAttrsType : TK_ExprExtType;
begin
  AAttrsType := K_GetRArrayTypes( ACType, AElemType );
  SetAttrsType( AAttrsType );
  SetElemType(AElemType);
  if AAttrsType.DTCode <= Ord(nptNotDef) then
    FCETCode := 0
  else
    FCETCode := ACType.DTCode;
  if (ACType.EFlags.CFlags and K_ccCountUDRef) <> 0 then
    SetCountUDRef;
end; // end of function TK_RArray.SetComplexType

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\AAddRef
//******************************************************* TK_RArray.AAddRef ***
// Increment Self references counter
//
//     Parameters
// Result - Returns Self
//
function TK_RArray.AAddRef : TK_RArray;
begin
  Result := Self;
  if Self <> nil then Inc(RefCount);
end; // end of function TK_RArray.AAddRef

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\ARelease
//****************************************************** TK_RArray.ARelease ***
// Decrement Self references counter
//
// If Self references counter is equal to 0, then Self will be destructed
//
procedure TK_RArray.ARelease;
begin
  if (Self = nil) or (RefCount < 0) then Exit;
  Dec(RefCount);
  if RefCount < 0 then Destroy;
end; // end of function TK_RArray.ARelease

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\ASetLength(1)
//************************************************* TK_RArray.ASetLength(1) ***
// Set Records Array Elements Counter
//
//     Parameters
// ALength - given new Records Array Elements Counter
// Result  - Returns 0 or number aded Elements
//
// If given ALength is less than current Records Array Elements number the 
// memmory buffer will save it's size (Array Elements will not occupy all Data 
// Buffer). For real memory buffer size decrease given number of elements have 
// to be negative. (ALength = -5 means that resulting Records Array Elements 
// counter will be equal to 5 and Data bufffer size = 5 * ElementSize)
//
function TK_RArray.ASetLength( ALength: Integer ) : Integer;
var
  i : Integer;
  FreeTail : Boolean;
begin
  Result := 0;
  //                  Inside Destructor
//  if (Self = nil) or (RefCount < 0) then Exit;
  if (Self = nil) then Exit;
  FreeTail := ( ALength <= 0 );
  if FreeTail then ALength := -ALength;
  if ( FEType.DTCode <> Ord(nptNotDef) ) and
     ( ALength < ElemCount ) then begin
    DeleteElems( ALength, ElemCount - ALength );
  end;
//  if ElemSize > 0 then begin
    if ALength > ElemCount then
      Result := ALength - ElemCount;
    ElemCount := ALength;
//  end;
  i := AttrsSize + ElemCount * ElemSize;
  if FreeTail then begin
//    if VBuf <> nil then SetLength( VBuf, i )
    SetLength( VBuf, i )
  end else
    K_SetBArrayCapacity( VBuf, i );
end; // end of procedure TK_RArray.ASetLength

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\ASetLengthI
//*************************************************** TK_RArray.ASetLengthI ***
// Set Records Array Elements Counter with new Elements initialization
//
//     Parameters
// ALength - given new Records Array Elements Counter
//
// If given Array length is larger than current add elements will be initialized
//
procedure TK_RArray.ASetLengthI( ALength: Integer );
var
  ic : Integer;
begin
  ic := ASetLength( ALength );
  if ic > 0 then
    InitElems( ElemCount - ic, ic );
end; // end of procedure TK_RArray.ASetLengthI

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\ASetLength(2)
//************************************************* TK_RArray.ASetLength(2) ***
// Set Records Array Matrix dimensions
//
//     Parameters
// AColCount      - given Records Array Matrix columns Counter
// ARowCount      - given Records Array Matrix rows Counter
// AInitElemsFlag - added Elements initialization flag (default value is FALSE)
//
procedure TK_RArray.ASetLength( AColCount, ARowCount : Integer; AInitElemsFlag : Boolean = false );
var
  CC, RC, DR, DC : Integer;
  procedure ChangeCols;
  begin
    if DC < 0 then
      DeleteCols( CC + DC, -DC )
    else if DC > 0 then begin
      InsertCols( -1, DC );
      if AInitElemsFlag then
        InitCols( CC, DC );
    end;
  end;
begin
  ALength( CC, RC );
  if AColCount = 0 then begin
    ARowCount := 0;
    AColCount := 1;
  end;
  DR := ARowCount - RC;
  DC := AColCount - CC;
  if DR < 0 then begin
    DeleteRows( RC + DR, -DR );
    ChangeCols;
  end else begin
    ChangeCols;
    if DR = 0 then Exit;
    InsertRows( -1, DR );
    if AInitElemsFlag then
      InitRows( RC, DR );
  end;
end; // end of procedure TK_RArray.ASetLength

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\ReorderElems
//************************************************** TK_RArray.ReorderElems ***
// Reorder Records Array Elements
//
//     Parameters
// APInds     - pointer to first element of array of Records Array Elements 
//              indexes (before reordering)
// AIndsCount - length of indexes array
//
procedure TK_RArray.ReorderElems( APInds : PInteger; AIndsCount : Integer );
var
  MDFlags : TK_MoveDataFlags;
  Buf : TN_BArray;
  j, FuncInd, i, ci, MaxInd, BufSize : Integer;
//!!  PSData, PDData : PChar;
  PSData, PDData : TN_BytesPtr;
  InitInds : TN_IArray;
begin
  if AIndsCount > 0 then begin
    FuncInd := -1;
    if K_RAInitFuncs <> nil then
      FuncInd := K_RAInitFuncs.IndexOfName( K_GetExecTypeName(FEType.All) );
  //*** Reorder data if needed
    // Prep Buffer
    BufSize := AIndsCount*ElemSize;
    SetLength( Buf, BufSize );
    // Correct Copy to Buffer with Reordering
    MDFlags := [];
    if (FEType.D.CFlags and K_ccCountUDRef) <> 0 then
      MDFlags := MDFlags + [K_mdfCountUDRef];
    MaxInd := ElemCount;
    PSData := P;
    PDData := Pointer(@Buf[0]);
    SetLength( InitInds, AIndsCount );
    j := 0;
    for i := 0 to AIndsCount - 1 do begin
      ci := APInds^;
      if ci < MaxInd then
//!!        K_MoveSPLData(  (PChar(PSData) + ci * ElemSize)^, PDData^, FEType, MDFlags )
        K_MoveSPLData(  (PSData + ci * ElemSize)^, PDData^, FEType, MDFlags )
      else begin
        InitInds[j] := i;
        Inc(j);
      end;
//!!      Inc(PChar(PDData), ElemSize);
      Inc(PDData, ElemSize);
      Inc(APInds);
    end;
    // Prep RArray
    FreeElemsData( 0 );
    ASetLength( AIndsCount );
    // Simple Move from Buffer to RArray
    Move( Buf[0], P^, BufSize );
    if FuncInd = -1 then Exit;
    for i := 0 to j - 1 do
      TK_RAInitFunc(K_RAInitFuncs.Objects[FuncInd])( Self, InitInds[i], 1  );
  end else
    ASetLength( 0 );
end; //*** end of procedure TK_RArray.ReorderElems

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\ReorderElems_Ext
//********************************************** TK_RArray.ReorderElems_Ext ***
// Reorder, free and initialize Records Array Elements
//
//     Parameters
// APOrderInds     - pointer to first element of array of Records Array Elements
//                   indexes (before reordering)
// AOrderIndsCount - length of ordering indexes array
// APFreeInds      - pointer to first element of array of Records Array Elements
//                   indexes which have to be free
// AFreeIndsCount  - length of freeing indexes array
// APInitInds      - pointer to first element of array of Records Array Elements
//                   indexes which have to be initialized
// AInitIndsCount  - length of init indexes array
//
procedure TK_RArray.ReorderElems( APOrderInds: PInteger; AOrderIndsCount : Integer;
                                  APFreeInds: PInteger; AFreeIndsCount : Integer;
                                  APInitInds: PInteger; AInitIndsCount : Integer );
var
  WHCol : Integer;
begin
  WHCol := HCol;
  HCol := 0;
  ReorderRows( APOrderInds, AOrderIndsCount, APFreeInds, AFreeIndsCount,
               APInitInds, AInitIndsCount );
  HCol := WHCol;
end; //*** end of procedure TK_RArray.ReorderElems

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\SetElemsFreeFlag
//********************************************** TK_RArray.SetElemsFreeFlag ***
// Set Free Memory Flag to Record Array Elements range
//
//     Parameters
// AInd      - Elements range start index (default value is 0)
// ACount    - Elements range counter (default value is -1 - all element 
//             including last)
// AClearMem - clear memory flag (if =TRUE then memory will be filled by 0, 
//             default value is FALSE)
//
// This routine do not done real free Data buffer from objects (strings, Records
// Arrays and etc.) but only fill memory by 0 if needed;
//
// If freeing range is Records Array "tail" then elements will be deleted
//
procedure TK_RArray.SetElemsFreeFlag( AInd : Integer = 0; ACount : Integer = -1;
                                      AClearMem : Boolean = false );
var
  FreeTail : Boolean;
begin

  if not CalcCount( AInd, ACount ) then Exit;
  FreeTail := (AInd + ACount = ElemCount);
  if not FreeTail then AClearMem := true;
  if AClearMem then
    FillChar( P( AInd )^, ACount * ElemSize, 0 );
  if FreeTail then Dec( ElemCount, ACount );
end; // end of procedure TK_RArray.SetElemsFreeFlag

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\InitElems
//***************************************************** TK_RArray.InitElems ***
// Initialize given Record Array Elements range
//
//     Parameters
// AInd   - Elements range start index (default value is 0)
// ACount - Elements range counter (default value is -1 - all element including 
//          last)
// Result - Returns TRUE if Element are realy initialized
//
function TK_RArray.InitElems( AInd : Integer = 0; ACount : Integer = -1 ) : Boolean;
var
  FuncInd : Integer;
begin
  Result := true;
  if not CalcCount( AInd, ACount ) then Exit;
  FuncInd := -1;
  if K_RAInitFuncs <> nil then
    FuncInd := K_RAInitFuncs.IndexOfName( K_GetExecTypeName(FEType.All) );
  if FuncInd <> -1 then
    TK_RAInitFunc(K_RAInitFuncs.Objects[FuncInd])( Self, AInd, ACount  )
  else
    Result := false;
end; // end of procedure TK_RArray.InitElems

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\FreeElemsData
//************************************************* TK_RArray.FreeElemsData ***
// Free memory occupied by Records Array Elements range
//
//     Parameters
// AInd   - Elements range start index (default value is 0)
// ACount - Elements range counter (default value is -1 - all element including 
//          last)
//
// Free all objects (strings, Records Arry and etc.)
//
procedure TK_RArray.FreeElemsData( AInd : Integer; ACount : Integer = -1 );
var
  i : Integer;
//!!  PData : PChar;
  PData : TN_BytesPtr;

begin

  if not CalcCount( AInd, ACount ) then Exit;
  if TK_ExprExtType(FEType).DTCode <> Ord(nptNotDef) then begin
//!!    PData := PChar( P( AInd ) );
    PData := TN_BytesPtr( P( AInd ) );
    for i := 0 to ACount - 1 do begin
      K_FreeSPLData( PData^, FEType.All,
        ((FEType.D.CFLags and (K_ccCountUDRef or K_ccStopCountUDRef)) = K_ccCountUDRef ) );
      Inc(PData, ElemSize);
    end;
  end;
end; // end of procedure TK_RArray.FreeElemsData

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\DeleteElems
//*************************************************** TK_RArray.DeleteElems ***
// Delete Records Array Elements range
//
//     Parameters
// AInd   - Elements range start index (default value is 0)
// ACount - Elements range counter (default value is -1 - all element including 
//          last)
//
procedure TK_RArray.DeleteElems( AInd : Integer; ACount : Integer = 1 );
var
  i : Integer;
begin

  if not CalcCount( AInd, ACount ) then Exit;
  FreeElemsData( AInd, ACount );
  i := ElemCount - AInd - ACount;
  if i > 0 then
    Move( P( AInd + ACount )^, P( AInd )^, i * ElemSize );
//*** Clear Free Tail
  FillChar( P( ElemCount - ACount )^, ACount * ElemSize, 0 );
  Dec( ElemCount, ACount );
//  SetLength( V, ElemSize * ElemCount );
end; // end of procedure TK_RArray.DeleteElems

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\InsertElems
//*************************************************** TK_RArray.InsertElems ***
// Insert Records Array Elements range
//
//     Parameters
// AInd   - index of Element before which new elements will be placed (default 
//          value is -1 - place after last Element)
// ACount - number of inserting Elements (default value is 1)
//
procedure TK_RArray.InsertElems( AInd : Integer = -1; ACount : Integer = 1 );
var
  SCount, i : Integer;
begin
  if ACount = 0 then Exit;
  SCount := ElemCount;
  ASetLength( ElemCount + ACount );
  if AInd < 0 then AInd := SCount;
  i := SCount - AInd;
  if i > 0 then
    Move( P( AInd )^, P( AInd + ACount )^, i * ElemSize );
//??Err    Move( P( AInd )^, P( SCount )^, i * ElemSize );
//*** Clear Inserted Memory
  FillChar( P( AInd )^, ACount * ElemSize, 0 );
end; // end of procedure TK_RArray.InsertElems

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\MoveElems
//***************************************************** TK_RArray.MoveElems ***
// Move Records Array Elements
//
//     Parameters
// AIndD  - destination Element index
// AIndS  - source Element index
// ACount - number of mooving elements
//
procedure TK_RArray.MoveElems( AIndD, AIndS : Integer; ACount : Integer = 1 );
var
  SSInd, DDInd, MoveSize, FreeInd, SectSize : Integer;
  PFree : Pointer;
begin
{
  FreeInd := ALength;
  SSInd := IndS + Count;
  DDInd := IndD + Count;
//*** Check Moving Attribs
  if (Count <= 0)      or
     (IndD = IndS)     or
     (IndS < 0)        or
     (IndD < 0)        or
     (DDInd > FreeInd) or
     (SSInd > FreeInd) then Exit;

  MoveSize := IndD - IndS;
  if IndD < IndS then begin
    SSInd := IndD;
    MoveSize := -MoveSize;
  end else
    DDInd := IndS;
  SectSize := Count * ElemSize;
}

  MoveSize := CalcMoveInds( AIndS, AIndD, ACount, FreeInd, SSInd, DDInd, SectSize );
  if MoveSize = 0 then Exit;

//*** Reserve Space
  ASetLength( FreeInd + ACount );
  PFree := P( FreeInd );
  MoveElemValues( AIndS, AIndD, SSInd, DDInd, SectSize, MoveSize, PFree );
{
//*** Move Sect to Free Space
  Move( P( IndS )^, PFree^, SectSize );
//*** Move Other Elems - Free Dest Sect Pos
  Move( P( SSInd )^, P( DDInd )^, MoveSize * ElemSize);
//*** Move Sect Dest Pos
  Move( PFree^, P( IndD )^, SectSize );
}
//*** Clear Free Space
  FillChar( PFree^, SectSize, 0 );
  Dec( ElemCount, ACount );
end; // end of procedure TK_RArray.MoveElems

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\ReorderRows
//*************************************************** TK_RArray.ReorderRows ***
// Reorder, free and initialize Records Array Matrix Rows
//
//     Parameters
// APOrderInds     - pointer to first element of array of Records Array Matrix 
//                   rows indexes (before reordering)
// AOrderIndsCount - length of ordering indexes array
// APFreeInds      - pointer to first element of array of Records Array Matrix 
//                   rows indexes which have to be free
// AFreeIndsCount  - length of freeing indexes array
// APInitInds      - pointer to first element of array of Records Array Matrix 
//                   rows indexes which have to be initialized
// AInitIndsCount  - length of init indexes array
//
procedure TK_RArray.ReorderRows( APOrderInds: PInteger; AOrderIndsCount : Integer;
                                 APFreeInds: PInteger; AFreeIndsCount : Integer;
                                 APInitInds: PInteger; AInitIndsCount : Integer );
var
  Buf : TN_BArray;
  FuncInd, i, BufSize : Integer;
  PData : Pointer;
  RowLeng : Integer;
  ColCount, RowCount : Integer;
begin
  if AOrderIndsCount > 0 then begin
    //*** Free Elems
    for i := 0 to AFreeIndsCount - 1 do begin
      FreeRowsData( APFreeInds^, 1 );
      Inc(APFreeInds);
    end;

    ALength( ColCount, RowCount );

    //*** Prep Buffer
    RowLeng := ElemSize * ColCount;
    BufSize := AOrderIndsCount * RowLeng;
    SetLength( Buf, BufSize );

    //*** Copy Saved Elems to New Places to Buffer
    PData := P;
    K_MoveVectorBySIndex( Buf[0], RowLeng,
                        PData^, RowLeng, RowLeng,
                        AOrderIndsCount, APOrderInds );
    //*** Clear Elems
    FillChar( PData^, RowLeng * RowCount, 0 );

    //*** Copy Saved Data to New Elems
    ASetLength( ColCount, AOrderIndsCount );
    Move( Buf[0], P^, BufSize );

    //*** Init New Elems
    if (K_RAInitFuncs = nil) or (AInitIndsCount = 0) then Exit;
    FuncInd := K_RAInitFuncs.IndexOfName( K_GetExecTypeName(FEType.All) );
    if FuncInd = -1 then Exit;
    for i := 0 to AInitIndsCount - 1 do begin
      InitRows( APInitInds^, 1  );
      Inc(APInitInds);
    end;
  end else
    ASetLength( 0 );

end; //*** end of procedure TK_RArray.ReorderRows

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\InitRows
//****************************************************** TK_RArray.InitRows ***
// Initialize given Record Array Matix rows range
//
//     Parameters
// AInd   - Matix rows range start index (default value is 0)
// ACount - Matix rows range counter (default value is -1 - all element 
//          including last)
// Result - Returns TRUE if Element are realy initialized
//
function TK_RArray.InitRows( AInd, ACount: Integer ): Boolean;
var n : Integer;
begin
  Result := true;
  if not CalcRowsCount( AInd, ACount, n ) then Exit;
  Result := InitElems( AInd * n, ACount * n )
end; // end of procedure TK_RArray.InitRows

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\FreeRowsData
//************************************************** TK_RArray.FreeRowsData ***
// Free memory occupied by Records Array Matrix rows range
//
//     Parameters
// AInd   - Matix rows range start index (default value is 0)
// ACount - Matix rows range counter (default value is -1 - all element 
//          including last)
//
// Free all objects (strings, Records Arry and etc.)
//
procedure TK_RArray.FreeRowsData( AInd : Integer; ACount : Integer = -1 );
var n : Integer;
begin
  if not CalcRowsCount( AInd, ACount, n ) then Exit;
  FreeElemsData( AInd * n, ACount * n )
end; // end of procedure TK_RArray.FreeRowsData

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\DeleteRows
//**************************************************** TK_RArray.DeleteRows ***
// Delete Records Array Matrix rows range
//
//     Parameters
// AInd   - Matix rows range start index (default value is 0)
// ACount - Matix rows range counter (default value is -1 - all element 
//          including last)
//
procedure TK_RArray.DeleteRows( AInd : Integer; ACount : Integer = 1 );
var n : Integer;
begin
  if not CalcRowsCount( AInd, ACount, n ) then Exit;
  DeleteElems( AInd * n, ACount * n )
end; // end of procedure TK_RArray.DeleteRows

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\InsertRows
//**************************************************** TK_RArray.InsertRows ***
// Insert Records Array Matrix rows range
//
//     Parameters
// AInd   - index of Matix row before which new rows will be placed (default 
//          value is -1 - place after last Element)
// ACount - number of inserting Matix row (default value is 1)
//
procedure TK_RArray.InsertRows( AInd : Integer = -1; ACount : Integer = 1 );
var
  ColCount, RowCount, n : Integer;
begin
  ALength( ColCount, RowCount );
  if ColCount <= 0 then Exit;
  if AInd < 0 then AInd := RowCount;
  n := HCol + 1;
  InsertElems( AInd * n, ACount * n );
end; // end of procedure TK_RArray.InsertRows

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\MoveRows
//****************************************************** TK_RArray.MoveRows ***
// Move Records Array Matrix rows
//
//     Parameters
// AIndD  - destination Element index
// AIndS  - source Element index
// ACount - number of mooving elements
//
procedure TK_RArray.MoveRows( AIndD, AIndS : Integer; ACount : Integer = 1 );
var n : Integer;
begin
  if not CalcRowsCount( AIndS, ACount, n ) then Exit;
  MoveElems( AIndD * n, AIndS * n, ACount * n );
end; // end of procedure TK_RArray.MoveRows

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\ReorderCols
//*************************************************** TK_RArray.ReorderCols ***
// Reorder, free and initialize Records Array Matrix columns
//
//     Parameters
// APOrderInds     - pointer to first element of array of Records Array Matrix 
//                   columns indexes (before reordering)
// AOrderIndsCount - length of ordering indexes array
// APFreeInds      - pointer to first element of array of Records Array Matrix 
//                   columns indexes which have to be free
// AFreeIndsCount  - length of freeing indexes array
// APInitInds      - pointer to first element of array of Records Array Matrix 
//                   columns indexes which have to be initialized
// AInitIndsCount  - length of init indexes array
//
procedure TK_RArray.ReorderCols( APOrderInds: PInteger; AOrderIndsCount : Integer;
                                 APFreeInds: PInteger; AFreeIndsCount : Integer;
                                 APInitInds: PInteger; AInitIndsCount : Integer );
var
  Buf : TN_BArray;
  FuncInd, i, BufSize : Integer;
//  PBuf : PChar;
  NRowLeng : Integer;
  ColCount, RowCount : Integer;
begin
  if AOrderIndsCount > 0 then begin
    //*** Free Elems
    for i := 0 to AFreeIndsCount - 1 do begin
      FreeColsData( APFreeInds^, 1 );
      Inc(APFreeInds);
    end;

    ALength( ColCount, RowCount );

    //*** Prep Buffer
    NRowLeng := ElemSize * AOrderIndsCount;
    BufSize := NRowLeng * RowCount;
    SetLength( Buf, BufSize );

    //*** Copy Saved Elems to New Places to Buffer
{
    PBuf := Pointer(@Buf[0]);
    for i := 0 to RowCount - 1 do begin
      K_MoveVectorBySIndex( PBuf^, ElemSize,
                          PME(0,i)^, ElemSize, ElemSize,
                          ConvIndsCount, PConvInds );
      Inc( PBuf, NRowLeng );
    end;
}
    if BufSize > 0 then
      K_MoveMatrixBySIndex( Buf[0], ElemSize, NRowLeng,
                                P^, ElemSize, ElemSize * ColCount,
                                ElemSize,
                                AOrderIndsCount, RowCount,
                                APOrderInds, nil );

    //*** Clear Elems
    FillChar( P^, ElemSize * RowCount * ColCount, 0 );

    //*** Copy Saved Data to New Elems
    ASetLength( AOrderIndsCount, RowCount );
    if BufSize > 0 then
      Move( Buf[0], P^, BufSize );

    //*** Init New Elems
    if (K_RAInitFuncs = nil) or (AInitIndsCount = 0) then Exit;
    FuncInd := K_RAInitFuncs.IndexOfName( K_GetExecTypeName(FEType.All) );
    if FuncInd = -1 then Exit;
    for i := 0 to AInitIndsCount - 1 do begin
      InitCols( APInitInds^, 1  );
      Inc(APInitInds);
    end;
  end else
    ASetLength( 0 );

end; //*** end of procedure TK_RArray.ReorderCols

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\InitCols
//****************************************************** TK_RArray.InitCols ***
// Initialize given Record Array Matix columns range
//
//     Parameters
// AInd   - Matix columns range start index (default value is 0)
// ACount - Matix columns range counter (default value is -1 - all element 
//          including last)
// Result - Returns TRUE if Element are realy initialized
//
function TK_RArray.InitCols( AInd, ACount: Integer ): Boolean;
var
  i, n, ColLength : Integer;
  FuncInd : Integer;
begin
  Result := true;
  if not CalcColsCount( AInd, ACount, ColLength ) then Exit;
  FuncInd := -1;
  if K_RAInitFuncs <> nil then
    FuncInd := K_RAInitFuncs.IndexOfName( K_GetExecTypeName(FEType.All) );
  if FuncInd <> -1 then begin
    n := HCol + 1;
    for i := 0 to ColLength - 1 do begin
      TK_RAInitFunc(K_RAInitFuncs.Objects[FuncInd])( Self, AInd, ACount  );
      Inc(AInd, n);
    end;
  end else
    Result := false;

end; // end of procedure TK_RArray.InitCols

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\FreeColsData
//************************************************** TK_RArray.FreeColsData ***
// Free memory occupied by Records Array Matrix columns range
//
//     Parameters
// AInd   - Matix columns range start index (default value is 0)
// ACount - Matix columns range counter (default value is -1 - all element 
//          including last)
//
// Free all objects (strings, Records Arry and etc.)
//
procedure TK_RArray.FreeColsData( AInd : Integer; ACount : Integer = -1 );
var
  i, n, ColLength : Integer;
begin
  if not CalcColsCount( AInd, ACount, ColLength ) then Exit;
  n := HCol + 1;
  for i := 0 to ColLength - 1 do begin
    FreeElemsData( AInd, ACount );
    Inc(AInd, n);
  end;
end; // end of procedure TK_RArray.FreeColsData

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\DeleteCols
//**************************************************** TK_RArray.DeleteCols ***
// Delete Records Array Matrix columns range
//
//     Parameters
// AInd   - Matix columns range start index (default value is 0)
// ACount - Matix columns range counter (default value is -1 - all element 
//          including last)
//
procedure TK_RArray.DeleteCols( AInd : Integer; ACount : Integer = 1 );
var
  i, ColLength, DD, L0, L1, D0 : Integer;
//!!  PS0, PD : PChar;
  PS0, PD : TN_BytesPtr;

begin
  if not CalcColsCount( AInd, ACount, ColLength ) then Exit;
  //*** Free Data in  Deleted Columns
  FreeColsData( AInd, ACount );

  //*** Prepare Loop Params
  DD := (HCol + 1) * ElemSize;
  D0 := (AInd + ACount) * ElemSize;
  L0 := AInd * ElemSize;
  L1 := DD - D0;
  PS0 := P;
  PD := P(AInd);

  //*** Move Elems Loop
  for i := 0 to ColLength - 1 do begin
    if (i > 0) and (L0 > 0) then begin
      Move( PS0^, PD^, L0 );
      Inc( PD, L0 );
    end;
    if L1 > 0 then begin
      Move( (PS0 + D0)^, PD^, L1 );
      Inc( PD, L1 );
    end;
    Inc( PS0, DD );
  end;

  //*** Free Not Used RArray Space
  Dec( HCol, ACount );
  i := ColLength * ACount;
  SetElemsFreeFlag( ElemCount - i, i, true );

end; // end of procedure TK_RArray.DeleteCols

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\InsertCols
//**************************************************** TK_RArray.InsertCols ***
// Insert Records Array Matrix columns range
//
//     Parameters
// AInd   - index of Matix column before which new columns will be placed 
//          (default value is -1 - place after last Element)
// ACount - number of inserting Matix column (default value is 1)
//
procedure TK_RArray.InsertCols( AInd : Integer = -1; ACount : Integer = 1 );
var
  i, PrevElemCount, PrevRowLength, RowLength, ColLength, L0, L1, SD, DD, D0, LF : Integer;
//!!  PS0, PD0 : PChar;
  PS0, PD0 : TN_BytesPtr;

begin
  //*** Check RArray Params
  ALength( RowLength, ColLength );
  if RowLength <= 0 then Exit;
  if AInd < 0 then AInd := RowLength;

  //*** Enlarge RArray Space
  PrevElemCount := ElemCount;
  Inc( HCol, ACount );
  ASetLength( ElemCount + ColLength * ACount );

  //*** Prepare Move Loop Params
  PrevRowLength := RowLength;
  RowLength := PrevRowLength + ACount;
  SD := PrevRowLength * ElemSize;
  DD := RowLength * ElemSize;
  LF := ACount * ElemSize;
  L0 := AInd * ElemSize;
  D0 := L0 + LF;
  L1 := (PrevRowLength - AInd) * ElemSize;
  if L1 <= 0 then
    L0 := PrevRowLength * ElemSize;
  PS0 := P(PrevElemCount - PrevRowLength);
  PD0 := P(ElemCount - RowLength);

  //*** Move Loop
  for i := ColLength downto 1 do begin
    if L1 > 0 then
      Move( (PS0 + L0)^, (PD0 + D0)^, L1 );
    FillChar( (PD0 + L0)^, LF, 0 );
    if i = 1 then break;
    Move( PS0^, PD0^, L0 );
    Dec( PD0, DD );
    Dec( PS0, SD );
  end;
end; // end of procedure TK_RArray.InsertCols

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\MoveCols
//****************************************************** TK_RArray.MoveCols ***
// Move Records Array Matrix rows
//
//     Parameters
// AIndD  - destination Element index
// AIndS  - source Element index
// ACount - number of mooving elements
//
procedure TK_RArray.MoveCols( AIndD, AIndS : Integer; ACount : Integer = 1 );
var
  i, n, ColLength : Integer;
  SSInd, DDInd, MoveSize, FreeInd, SectSize : Integer;
  PFree : Pointer;
begin
  MoveSize := CalcMoveInds( AIndS, AIndD, ACount, FreeInd, SSInd, DDInd, SectSize );
  if MoveSize = 0 then Exit;
  if not CalcColsCount( AIndD, ACount, ColLength ) then Exit;
  //*** Reserved Buffer Space
  ASetLength( FreeInd + ACount );

  //*** Prepare Loop Params;
  PFree := P( FreeInd );
  n := HCol + 1;

  //*** Move Loop
  for i := 0 to ColLength - 1 do begin
    MoveElemValues( AIndS, AIndD, SSInd, DDInd, SectSize, MoveSize, PFree );
    Inc(AIndS, n);
    Inc(AIndD, n);
    Inc(SSInd, n);
    Inc(DDInd, n);
  end;

  //*** Clear Free Space
  FillChar( PFree^, SectSize, 0 );
  Dec( ElemCount, ACount );
end; // end of procedure TK_RArray.MoveCols

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\SetElems
//****************************************************** TK_RArray.SetElems ***
// Set Records Array Elements range by given Data
//
//     Parameters
// AData       - given data for Elemnts setting
// AFillFlag   - fill Elements flag (if =TRUE then each Element will be set by 
//               same value - AData, if =FALSE then Elements will be set by 
//               different values satrting from AData) (default value is TRUE)
// AInd        - Elements range start index (default value is 0)
// ACount      - Elements range counter (default value is -1 - all element 
//               including last)
// ACopyArrays - if =TRUE then copied Record Array fields will be copied, if 
//               =FALSE then references to Record Array fields will be copied
//
procedure TK_RArray.SetElems( var AData; AFillFlag : Boolean = true;
                              AInd : Integer = 0; ACount : Integer = -1;
                              ACopyArrays : Boolean = false );
var
  i : Integer;
//!!  PSData, PDData : PChar;
  PSData, PDData : TN_BytesPtr;

  MDFlags : TK_MoveDataFlags;
begin
  if (@AData = nil) or not CalcCount( AInd, ACount ) then Exit;

  if FEType.DTCode = Ord(nptNotDef) then begin
    i := ElemSize * ACount;
    if i > 0 then
      Move( AData, P( AInd )^, i * ElemSize );
  end else begin
//!!    PSData := PChar( @AData );
//!!    PDData := PChar( P( AInd ) );
    PSData := TN_BytesPtr( @AData );
    PDData := TN_BytesPtr( P( AInd ) );

    if ((FEType.EFlags.CFlags and K_ccCountUDRef) <> 0) and
       ((FEType.EFlags.CFlags and K_ccStopCountUDRef) = 0) then
      MDFlags := [K_mdfCountUDRef]
    else
      MDFlags := [];
    if ACopyArrays then Include( MDFlags, K_mdfCopyRArray );
    MDFlags := MDFlags + [K_mdfFreeDest];
    for i := 0 to ACount - 1 do begin
      K_MoveSPLData( PSData^, PDData^, FEType, MDFlags );
      Inc(PDData, ElemSize);
      if not AFillFlag then
        Inc(PSData, ElemSize);
    end;
  end;
end; // end of function TK_RArray.SetElems

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\TranspElems
//*************************************************** TK_RArray.TranspElems ***
// Transpose Records Array Matrix
//
procedure TK_RArray.TranspElems( );
var
  ColCount, RowCount : Integer;
  i, Leng : Integer;
  Buf : TN_BArray;
//!!  PBuf, PData : PChar;
  PBuf, PData : TN_BytesPtr;

  RowSize, ColSize : Integer;
begin
  ALength( ColCount, RowCount );
  if RowCount = 0 then Exit;
  if (ColCount <> 1) and (RowCount <> 1) then begin
  // Transpose is needed
  //*** Prep Transposition
    Leng := ElemCount * ElemSize;
    SetLength( Buf, Leng );
    Pointer(PBuf) := @Buf[0];
    PData := P;
    RowSize := ElemSize * ColCount;
    ColSize := ElemSize * RowCount;

  //*** Transp to Buffer
    for i := 0 to RowCount - 1 do begin
      K_MoveVector( PBuf^, ColSize,  PData^,  ElemSize,
                                    ElemSize,  ColCount );
      Inc( PData, RowSize );
      Inc( PBuf, ElemSize );
    end;

  //*** Move Back
    Move( Buf[0], P^, Leng );
  end;

  HCol := RowCount - 1; // New Row Length

end; // end of function TK_RArray.TranspElems

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\CompareData
//*************************************************** TK_RArray.CompareData ***
// Compare Records Array Data Tree
//
//     Parameters
// ARA        - compared copied
// ASPath     - Root Path string for Errors Messges
// ACompFlags - compare modes
// Result     - Returns TRUE if Records Arrays Data is equal
//
function TK_RArray.CompareData( ARA : TK_RArray; ASPath : string = '';
                                ACompFlags : TK_CompDataFlags = [] ): Boolean;
var
  i : Integer;
  NPath : string;
begin
  Result := (Self = nil) and (ARA = nil);
  if (Self = nil) or (ARA = nil) then Exit;
  if ((ARA.ElemType.All xor FEType.All) and K_ffCompareTypesMask) <> 0 then begin
    if (K_cdfBuildErrList in ACompFlags) then
      K_AddCompareErrInfo( ASPath + ' DataType' );
    Exit;
  end else if (ARA.ElemCount <> ElemCount) then begin
    if (K_cdfBuildErrList in ACompFlags) then
      K_AddCompareErrInfo( ASPath + ' ElemCount' );
    Exit;
  end;

  Result := true;
  if Self = ARA then Exit;
  for i := 0 to ElemCount - 1 do begin
    if not Result and K_CompareStopFlag then Exit;
    NPath := ASPath + format( '[%d]', [i] );
    Result := K_CompareSPLData( P(i)^, ARA.P(i)^, FEType, NPath, ACompFlags );
  end;
end; // end of function TK_RArray.CompareData

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\PA
//************************************************************ TK_RArray.PA ***
// Get pointer to Records Array Attributes
//
//     Parameters
// Result - Returns pointer to Records Array Attributes or NIL if no Data
//
function TK_RArray.PA : Pointer;
begin
  if (Self = nil) or (Length(VBuf) = 0) then
    Result := nil
  else
    Result := @VBuf[0];
end; // end of procedure TK_RArray.PA

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\PV
//************************************************************ TK_RArray.PV ***
// Get pointer to Records Array start Element
//
//     Parameters
// Result - Returns pointer to Records Array start Element or NIL if no Data
//
function TK_RArray.PV : Pointer;
begin
  Result := PA;
  if (Result <> nil) then
//!!    Result := PChar(Result) + AttrsSize;
    Result := TN_BytesPtr(Result) + AttrsSize;

end; // end of procedure TK_RArray.P

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\P
//************************************************************* TK_RArray.P ***
// Get pointer to Records Array start Element
//
//     Parameters
// Result - Returns pointer to Records Array start Element or NIL if no Data
//
function TK_RArray.P : Pointer;
begin
  if (Self = nil) or (Length(VBuf) = 0) or (ElemCount = 0) then
    Result := nil
  else
//!!    Result := PChar(@VBuf[0]) + AttrsSize;
    Result := TN_BytesPtr(@VBuf[0]) + AttrsSize;

end; // end of procedure TK_RArray.P

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\P_i
//*********************************************************** TK_RArray.P_i ***
// Get pointer to given Records Array Element
//
//     Parameters
// AInd   - given Element index
// Result - Returns pointer to Records Array Element or NIL if no Data
//
function TK_RArray.P( AInd: Integer ): Pointer;
begin
  Result := PA;
  if (Result <> nil) then begin
    if (AInd >= 0) and (AInd < ElemCount) then
//!!      Inc( PCHar(Result), AInd * ElemSize  + AttrsSize )
      Inc( TN_BytesPtr(Result), AInd * ElemSize  + AttrsSize )
    else if (AttrsSize = 0) or (AInd <> -1) then
      Result := nil;
  end;
end; // end of procedure TK_RArray.P

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\PS
//************************************************************ TK_RArray.PS ***
// Get pointer to given Records Array Element (safe)
//
//     Parameters
// AInd   - given Element index
// Result - Returns pointer to Records Array Element
//
// If given index is out of Records Array bounds then index is "moved" to 
// Elements range by MOD operation
//
function TK_RArray.PS( AInd: Integer ): Pointer;
var
  Count : Integer;
begin
  Count := ALength;
  if (AInd >= Count) and (Count > 0) then
    AInd := AInd mod Count;
  Result := P( AInd );
end; // end of procedure TK_RArray.PS

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\PME
//*********************************************************** TK_RArray.PME ***
// Get pointer to given Records Array Matrix Element
//
//     Parameters
// AICol  - given Element column index
// AIRow  - given Element row index
// Result - Returns pointer to Records Array Matrix Element or NIL if no Data
//
function TK_RArray.PME( AICol, AIRow : Integer ) : Pointer;
var
  Ind : Integer;
begin
  Result := PA;
  if (Result <> nil) and (AICol >= 0) and (AICol <= HCol) and (AIRow >= 0) then begin
    Ind := (HCol + 1) * AIRow + AICol;
    if Ind <= ElemCount then begin
//!!      Inc( PCHar(Result), Ind * ElemSize  + AttrsSize );
      Inc( TN_BytesPtr(Result), Ind * ElemSize  + AttrsSize );
      Exit;
    end;
  end;
  Result := nil;
end; // end of procedure TK_RArray.PME

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\SetCountUDRef
//************************************************* TK_RArray.SetCountUDRef ***
// Set Count IDB Objects references flag to Records Array Type Code
//
procedure TK_RArray.SetCountUDRef;
begin
  FEType.D.CFlags := FEType.D.CFlags or K_ccCountUDRef;
end; // end of procedure TK_RArray.SetCountUDRef

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\AddToSBuf
//***************************************************** TK_RArray.AddToSBuf ***
// Add Self Data to Serial Binary Buffer
//
//     Parameters
// ASBuf - Serial Binary Buffer object
//
procedure TK_RArray.AddToSBuf ( ASBuf: TN_SerialBuf );
var
  i : Integer;
begin
  if Self = nil then i := -1
  else               i := ElemCount;
  ASBuf.AddRowInt( i );
  if i = -1 then Exit;

  ASBuf.AddRowInt( HCol );


  K_AddDataTypeToSBuf( GetComplexType, ASBuf );
{
  with GetComplexType do
  if DTCode < Ord(nptNoData) then begin
    SBuf.AddRowString( '' );
    SBuf.AddRowInt( DTCode );
  end else
    SBuf.AddRowString( FD.BuildRefPath() );
  SBuf.AddRowInt( FEType.EFlags.All );
}

// Add Attributes
  if AttrsSize > 0 then
    K_AddSPLDataToSBuf( PA^, AttrsType, ASBuf );

// Add Elements
  if FEType.DTCode <> Ord(nptNotDef) then begin
    for i := 0 to ElemCount - 1 do
      K_AddSPLDataToSBuf( P( i )^, FEType, ASBuf );
  end;
end; // end_of procedure TK_RArray.AddToSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\GetFromSBuf
//*************************************************** TK_RArray.GetFromSBuf ***
// Get Self Data from Serial Binary Buffer
//
//     Parameters
// ASBuf - Serial Binary Buffer object
//
procedure TK_RArray.GetFromSBuf ( ASBuf: TN_SerialBuf );
var
  i : Integer;
  RPath : string;
  WType : TK_ExprExtType;

  procedure GetType( var ADTCode : Integer );
  begin
    ASBuf.GetRowString( RPath );
    if RPath = '' then
      ASBuf.GetRowInt( ADTCode )
    else begin
      ADTCode := Integer( TK_UDFieldsDescr( K_UDCursorGetObj( RPath ) ) );
      if ADTCode = 0 then
        raise TK_SPLTypePathError.Create( ' Unknown SPL type path -> '+ RPath );
    end;
  end;

begin
  ASBuf.GetRowInt( ElemCount );

  if ElemCount = -1 then Exit;

  ASBuf.GetRowInt( HCol );

  WType := K_GetDataTypeFromSBuf( ASBuf );
{
  SBuf.GetRowString( RPath );
  if RPath = '' then
    SBuf.GetRowInt( WType.DTCode )
  else begin
    WType.DTCode := Integer( TK_UDFieldsDescr( K_UDCursorGetObj( RPath ) ) );
    if WType.DTCode = 0 then
      raise TK_SPLTypePathError.Create( ' Unknown SPL type path -> '+ RPath );
  end;
  SBuf.GetRowInt( WType.EFlags.All );
}
  SetTypeInfo( WType );

  SetLength( VBuf, AttrsSize + ElemSize * ElemCount );

// Add Attributes
  if AttrsSize > 0 then
    try
      K_GetSPLDataFromSBuf( PA^, AttrsType, ASBuf );
    except
      On E: Exception do
        raise TK_LoadUDDataError.Create(
          K_sccRecFieldDelim + K_RArraySimpleAttrsValueName+E.Message );
    end;

  if FEType.DTCode <> Ord(nptNotDef) then begin
    for i := 0 to ElemCount - 1 do
      try
        K_GetSPLDataFromSBuf( P( i )^, FEType, ASBuf );
      except
        On E: Exception do
          raise TK_LoadUDDataError.Create( '['+IntToStr(i)+']'+E.Message );
      end;
  end;
end; // end_of procedure TK_RArray.GetFromSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\AddToSTBuf
//**************************************************** TK_RArray.AddToSTBuf ***
// Add Self Data to Serial Text Buffer
//
//     Parameters
// ASBuf - Serial Text Buffer object
// ATag  - Records Array Tag
//
procedure TK_RArray.AddToSTBuf( ASBuf: TK_SerialTextBuf; ATag : string = '' );
//procedure TK_RArray.AddToSTBuf( ASBuf: TK_SerialTextBuf; ATag : string = '' {; ShowTypeName : Boolean = true} );
var
  i : Integer;
  RPath, Tag : string;
  AddAttrsFlag : Boolean;
  CompactArray : Boolean;

label Finish;

begin
  if ATag <> '' then ASBuf.AddTag( ATag );

{
  if Self = nil then i := -1
  else               i := ElemCount;
}
  if Self = nil then begin
    i := -1;
    ASBuf.AddTagAttr( 'ElemCount', i, K_isInteger );
    goto Finish;
  end;

  RPath := K_GetExecTypeName( GetComplexType.All );
  if (ASBuf.LastAddedTag <> RPath) and
     not (K_txtXMLMode in K_TextModeFlags) then
    ASBuf.AddTagAttr( 'TypeName', RPath, K_isString );

  AddAttrsFlag := AttrsSize <> 0;

  if ( not AddAttrsFlag or
      (AddAttrsFlag and (ElemCount <> 0)) )
      // No Attributes OR Attributes + Elements
                            and
     ( not (K_txtXMLMode in K_TextModeFlags) or
       (ElemCount <> 1)                     ) then
      // not XML OR Elements <> 1 OR not SPL BuildIn Type
    ASBuf.AddTagAttr( 'ElemCount', ElemCount, K_isInteger );

  if HCol <> 0 then
    ASBuf.AddTagAttr( 'HighColumn', HCol, K_isInteger );

//  if (FEType.EFlags.All <> 0) and
//     not (K_txtXMLMode in K_TextModeFlags) then
  if ((FEType.EFlags.All and not (K_ccCountUDRef shl K_ccFlagsShift)) <> 0) then
    ASBuf.AddTagAttr( 'TypeFlags', FEType.EFlags, K_isHex );

//??  if AddAttrsFlag then
//??    K_AddSPLDataToSTBuf( PA^, AttrsType, SBuf, K_RArraySimpleAttrsValueName, false );

  CompactArray := (K_txtCompactArray in K_TextModeFlags) and
                  ((AttrsSize <> 0) or (ElemCount > 1))  and
            (  (FEType.DTCode = Ord(nptByte)) or
               (FEType.DTCode >= Ord(nptInt)) and (FEType.DTCode <= Ord(nptColor)) or
               (FEType.DTCode >= Ord(nptDouble)) and (FEType.DTCode <= Ord(nptFRect)) );

  if CompactArray then
    ASBuf.AddTagAttr( 'CompactArray', N_IntOne, K_isInteger );

  if (FEType.DTCode <> Ord(nptNotDef)) then begin
    if ElemCount > 0 then begin
      if (AttrsSize = 0) and (ElemCount = 1) then
        K_AddSPLDataToSTBuf( P^, FEType, ASBuf, 'Value', false )
      else begin // AttrsSize <> 0 or ElemCount > 1
        ASBuf.AddEOL( false );
        if CompactArray then // Add Array Elements in Compact format
        begin
          case FEType.DTCode of
            Ord(nptByte):   ASBuf.AddBytes   ( P(), ElemCount );
            Ord(nptHex),
            Ord(nptColor):  ASBuf.AddHexInts ( P(), ElemCount );
            Ord(nptInt):    ASBuf.AddIntegers( P(), ElemCount );
            Ord(nptFloat):  ASBuf.AddFloats  ( P(), ElemCount );
            Ord(nptDouble): ASBuf.AddDoubles ( P(), ElemCount );
            Ord(nptString): ASBuf.AddStrings ( P(), ElemCount );
            Ord(nptIPoint): ASBuf.AddIntegers( P(), 2*ElemCount );
            Ord(nptIRect):  ASBuf.AddIntegers( P(), 4*ElemCount );
            Ord(nptDPoint): ASBuf.AddDoubles ( P(), 2*ElemCount );
            Ord(nptDRect):  ASBuf.AddDoubles ( P(), 4*ElemCount );
            Ord(nptFPoint): ASBuf.AddFloats  ( P(), 2*ElemCount );
            Ord(nptFRect):  ASBuf.AddFloats  ( P(), 4*ElemCount );
          end; // case FEType.DTCode of
        end else // Add one Array Element per row
        begin
          for i := 0 to ElemCount - 1 do begin
            Tag := '['+IntToStr(i)+']';
            ASBuf.AddTag( Tag );
            K_AddSPLDataToSTBuf( P( i )^, FEType, ASBuf, 'Value', true );
            ASBuf.AddTag( Tag, tgClose );
          end;
        end; // else // Add one Array Element per row
      end;
    end;
  end; // if (FEType.DTCode <> Ord(nptNotDef)) then begin

  if AddAttrsFlag and
     ( not (K_txtRACompact in K_TextModeFlags) or
       not K_FieldIsEmpty( PA, AttrsSize ) ) then begin
    ASBuf.AddTag( K_RArraySimpleAttrsValueName );
    K_AddSPLDataToSTBuf( PA^, AttrsType, ASBuf, 'Value', true );
    ASBuf.AddTag( K_RArraySimpleAttrsValueName, tgClose );
  end;

Finish:
  if ATag <> '' then ASBuf.AddTag( ATag, tgClose );

end; // end_of procedure TK_RArray.AddToSTBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\GetFromSTBuf
//************************************************** TK_RArray.GetFromSTBuf ***
// Get Self Data from Serial Text Buffer
//
//     Parameters
// ASBuf - Serial Text Buffer object
// ATag  - Records Array Tag
//
procedure TK_RArray.GetFromSTBuf( ASBuf: TK_SerialTextBuf; ATag : string = '' );
var
  BPos, i, CompactArray : Integer;
  Tag, TypeName : string;
  WType : TK_ExprExtType;

label Finish, ErrPath;

begin
  if ATag <> '' then
  begin
    ASBuf.GetBufPos( BPos );
    if not ASBuf.GetSpecTag( ATag, tgOpen, false ) then
    begin
      ASBuf.LastParsedTag := ASBuf.PrevParsedTag;
      ASBuf.SetBufPos( BPos );
      Exit;
    end;
  end;
  ElemCount := -2;
  ASBuf.GetTagAttr( 'ElemCount', ElemCount, K_isInteger );
  if ElemCount = -1 then goto Finish;

  AttrsSize := 0;
  WType.All := 0;
  if ASBuf.GetTagAttr( 'TypeName', TypeName ) then
  begin
    WType := K_GetTypeCode( TypeName );
    if WType.DTCode > 0 then
      SetTypeInfo( WType );
  end;
  if WType.DTCode <= 0 then
  begin
    if ElemCount <> -2 then
      raise TK_LoadUDDataError.Create( ASBuf.PrepErrorMessage(
                   ' Type "'+TypeName+'" is absent while loading line ' ) )
    else
    begin
      ElemCount := -1;
      goto Finish;
    end;
  end;

  if AttrsSize <> 0 then
  begin
    if ElemCount = -2 then ElemCount := 0;
  end
  else
  if ElemCount = -2 then ElemCount := 1;

  HCol := 0;
  ASBuf.GetTagAttr( 'HighColumn', HCol, K_isInteger );

  FEType.EFlags.All := K_ccCountUDRef shl K_ccFlagsShift;
  ASBuf.GetTagAttr( 'TypeFlags', FEType.EFlags, K_isInteger );

  i := AttrsSize + ElemSize * ElemCount;
  SetLength( VBuf, i );

//??  if AttrsSize > 0 then
//??    K_GetSPLDataFromSTBuf( PA^, AttrsType, SBuf, K_RArraySimpleAttrsValueName, false );

  CompactArray := 0;
  ASBuf.GetTagAttr( 'CompactArray', CompactArray, K_isInteger );

  if ElemCount > 0 then
  begin
    if (AttrsSize = 0) and (ElemCount = 1) then
      K_GetSPLDataFromSTBuf( P^, FEType, ASBuf, 'Value', false )
    else // AttrsSize <> 0 or ElemCount > 1
      if CompactArray = 1 then // Compact Array format
      begin
        ASetLength( ElemCount );

        case FEType.DTCode of
          Ord(nptByte):   ASBuf.GetBytes   ( P(), ElemCount );
          Ord(nptInt),
          Ord(nptHex),
          Ord(nptColor):  ASBuf.GetIntegers( P(), ElemCount );
          Ord(nptFloat):  ASBuf.GetFloats  ( P(), ElemCount );
          Ord(nptDouble): ASBuf.GetDoubles ( P(), ElemCount );
          Ord(nptString): ASBuf.GetStrings ( P(), ElemCount );
          Ord(nptIPoint): ASBuf.GetIntegers( P(), 2*ElemCount );
          Ord(nptIRect):  ASBuf.GetIntegers( P(), 4*ElemCount );
          Ord(nptDPoint): ASBuf.GetDoubles ( P(), 2*ElemCount );
          Ord(nptDRect):  ASBuf.GetDoubles ( P(), 4*ElemCount );
          Ord(nptFPoint): ASBuf.GetFloats  ( P(), 2*ElemCount );
          Ord(nptFRect):  ASBuf.GetFloats  ( P(), 4*ElemCount );
        end; // case FEType.DTCode of
      end else // One Array Element per row
      begin
      for i := 0 to ElemCount - 1 do
        try
          Tag := '['+IntToStr(i)+']';
          ASBuf.GetBufPos( BPos );
          if ASBuf.GetSpecTag( Tag, tgOpen, false ) then begin
            K_GetSPLDataFromSTBuf( P( i )^, FEType, ASBuf, 'Value', true );
            ASBuf.GetSpecTag( Tag, tgClose );
          end else
            ASBuf.SetBufPos( BPos );
        except
          On E: Exception do
            raise TK_LoadUDDataError.Create( Tag+E.Message );
        end;
      end; // for i := 0 to ElemCount - 1 do
  end; // if ElemCount > 0 then begin

  if AttrsSize > 0 then begin
    K_GetSPLDataFromSTBuf( PA^, AttrsType, ASBuf, K_RArraySimpleAttrsValueName, false );
    try
      ASBuf.GetBufPos( BPos );
      if ASBuf.GetSpecTag( K_RArraySimpleAttrsValueName, tgOpen, false ) then begin
        K_GetSPLDataFromSTBuf( PA^, AttrsType, ASBuf, 'Value', true );
        ASBuf.GetSpecTag( K_RArraySimpleAttrsValueName, tgClose );
      end else
        ASBuf.SetBufPos( BPos );
    except
      On E: Exception do
        raise TK_LoadUDDataError.Create( K_RArraySimpleAttrsValueName+E.Message );
    end;
  end;

Finish:
  if ATag <> '' then ASBuf.GetSpecTag( ATag, tgClose );
end; // end_of procedure TK_RArray.GetFromSTBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\ValueFromString
//*********************************************** TK_RArray.ValueFromString ***
// Parse Records Array Elements Value from given String
//
//     Parameters
// AText  - source Text
// Result - Returns string with path to field with parsing error
//
function TK_RArray.ValueFromString( AText : string ) : string;
var
  i : Integer;
  PrevText : string;
  PrevPos  : Integer;

begin

  Result := '';
  with K_ScriptLDDataTokenizer do begin
    PrevText := Text;
    PrevPos := CPos;
    setSource( AText );

    i := 0;
    while hasMoreTokens do begin
      ASetLength( i + 1 );
      Result := K_SPLValueFromString( P(i)^, FEType.All, nextToken() );
      if Result <> '' then begin
        Result := 'in ['+IntToStr(i)+'] ' + Result;
        break;
      end;
      Inc( i );

    end;

    setSource( PrevText );
    setPos( PrevPos );
  end;

end; // procedure TK_RArray.ValueFromString

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\ValueToString
//************************************************* TK_RArray.ValueToString ***
// Encode Records Array Elements Value to text
//
//     Parameters
// ASTK             - string tokenizer object (used to accumulate resulting text
//                    in tokenizer text buffer, if <>NIL then text will be added
//                    to  tokenizer text buffer, not to resulting string!!!)
// AValueToStrFlags - SPL value to string convertion flags
// AStrLen          - resulting string maximal length (if =0 then no constraint 
//                    on resulting string length is used)
// AFFLags          - SPL type flags value for data fields filtering
// AFMask           - SPL type flags mask value for data fields filtering
// Result           - Returns string with Records Array Elements values text 
//                    representation (if ASTK = nil)
//
// If fields filtering is done then only fields which SPL type flags value are 
// satisfied to condition
//#F
//    ((TK_ExprExtType.EFLags xor AFFLags) and AFMask) <> 0
//#/F
//
// will be converted to text.
//
function TK_RArray.ValueToString( ASTK : TK_Tokenizer;
                        AValueToStrFlags : TK_ValueToStrFlags = []; AMaxLength : Integer=0;
                        AFFLags : Integer = 0; AFMask : Integer = 0 ) : string;
var
  i, k : Integer;
  WSTK : TK_Tokenizer;
  AgregateData : Boolean;

begin
  if ASTK = nil then begin
    WSTK := K_ScriptLDDataTokenizer;
    WSTK.setSource( '' );
  end else
    WSTK := ASTK;

  if Self = nil then begin
    WSTK.addToken( '' );
  end else begin
//    AgregateData := ( ( FEType.DTCode > Ord(nptNoData) ) and
//                      ( ((FEType.D.TFlags and K_ffEnumSet) = 0) or
//                        (FEType.FD.ObjType = K_fdtSet) ) );
    AgregateData := ( FEType.DTCode > Ord(nptNoData) ) and
                    ( ( FEType.FD.FDObjType < K_fdtEnum ) or (FEType.FD.FDObjType = K_fdtSet) );
    k := AHigh;
    for i := 0 to k do begin
      K_ValueToStringBuf( P(i)^, FEType, AgregateData, WSTK, AValueToStrFlags,
                            AMaxLength, AFFlags, AFMask );
      if (AMaxLength > 0) and (WSTK.Cpos > AMaxLength) then break;
    end;
  end;

  if ASTK = nil then
    with WSTK do
      Result := Copy( Text, 1, CPos - 1 )
  else
    Result := '';
end; // procedure TK_RArray.ValueToString

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\CalcCount
//***************************************************** TK_RArray.CalcCount ***
// Check and correct Records Array Elements range
//
//     Parameters
// AInd   - Elements range start index
// ACount - Elements range counter, on output given Counter may be replaced to 
//          actual size
// Result - Returns TRUE if given range is actual
//
function  TK_RArray.CalcCount( AInd : Integer; var  ACount : Integer ) : Boolean;
var WCount : Integer;
begin
  Result := false;
  if (self = nil) or (AInd < 0) then begin
    ACount := -1;
    Exit;
  end;
  WCount := ElemCount - AInd;
  if ACount < 0 then
    ACount := WCount
  else
    ACount := Min( ACount, WCount );
  Result := ACount > 0;
end; // end of function  TK_RArray.CalcCount

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\CalcRowsCount
//************************************************* TK_RArray.CalcRowsCount ***
// Check and correct Records Array Matrix rows range
//
//     Parameters
// ARowInd   - rows range start index
// ARowCount - rows range counter, on output given Counter may be replaced to 
//             actual size
// AColCount - columns counter (number of Elements in single row)
// Result    - Returns TRUE if given range is actual
//
function  TK_RArray.CalcRowsCount( ARowInd : Integer; var  ARowCount, AColCount  : Integer ) : Boolean;
var
  RC, CC : Integer;
begin
  Result := false;
  ALength( CC, RC );
//???  ALength( AColCount, RC );
  if (ARowInd < 0)          or
     (ARowCount = 0)        or
     (RC <= 0)      or
     (ARowInd >= RC) then Exit;
  if ARowCount < 0 then
    ARowCount := RC - ARowInd
  else
    ARowCount := Min( ARowCount, RC - ARowInd );
  AColCount := HCol + 1;
  if ARowCount <= 0 then Exit;
  Result := true;
end; // end of function  TK_RArray.CalcRowsCount

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\CalcColsCount
//************************************************* TK_RArray.CalcColsCount ***
// Check and correct Records Array Matrix columns range
//
//     Parameters
// AColInd   - columns range start index
// AColCount - columns range counter, on output given Counter may be replaced to
//             actual size
// ARowCount - rows counter (number of Elements in single column)
// Result    - Returns TRUE if given range is actual
//
function  TK_RArray.CalcColsCount( AColInd : Integer; var  AColCount, ARowCount  : Integer ) : Boolean;
var
  RowLength : Integer;
begin
  Result := false;
  ALength( RowLength, ARowCount );
  if (AColInd < 0)          or
     (AColCount = 0)        or
     (RowLength <= 0)      or
     (AColInd >= RowLength) then Exit;
  if AColCount < 0 then
    AColCount := RowLength - AColInd
  else
    AColCount := Min( AColCount, RowLength - AColInd );
  if AColCount <= 0 then Exit;
  Result := true;
end; // end of function  TK_RArray.CalcColsCount

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\CalcMoveInds
//************************************************** TK_RArray.CalcMoveInds ***
// Calculate Records Array Elements indexes and byte intervals for moving given 
// Elements range to new place
//
//     Parameters
// AIndS    - source range start position
// AIndD    - source range destination position
// ACount   - source range counter
// ABufInd  - buffer range start position (buffer will be reserved in Records 
//            Array for future Data moving)
// ASSInd   - directly moved range start position
// ADDInd   - directly moved range destination position
// ABufSize - buffer range size in bytes
// Result   - Returns directly moved range size in bytes
//
function TK_RArray.CalcMoveInds( AIndS, AIndD, ACount : Integer;
                       out ABufInd, ASSInd, ADDInd, ABufSize : Integer ): Integer;
begin
  ABufInd := ALength;
  ASSInd := AIndS + ACount;
  ADDInd := AIndD + ACount;
  Result := 0;
//*** Check Moving Attribs
  if (Self = nil)      or
     (ACount <= 0)      or
     (AIndD = AIndS)     or
     (AIndS < 0)        or
     (AIndD < 0)        or
     (ADDInd > ABufInd) or
     (ASSInd > ABufInd) then Exit;

  Result := AIndD - AIndS;
  if AIndD < AIndS then begin
    ASSInd := AIndD;
    Result := -Result;
  end else
    ADDInd := AIndS;
  Result := Result * ElemSize;
  ABufSize := ACount * ElemSize;

end; // end of function  TK_RArray.CalcMoveInds

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\MoveElemValues
//************************************************ TK_RArray.MoveElemValues ***
// Move Records Array Elements using parameters calculated by CalcMoveInds
//
//     Parameters
// AIndS     - source range start position
// AIndD     - source range destination position
// ASSInd    - directly moved range start position
// ADDInd    - directly moved range destination position
// ABufSize  - buffer range size in bytes
// AMoveSize - directly moved range size in bytes
// APBuf     - pointer to buffer
//
procedure TK_RArray.MoveElemValues( AIndS, AIndD, ASSInd, ADDInd,
                         ABufSize, AMoveSize : Integer; APBuf : Pointer );
begin
//*** Move Bufferd Elems to Buffer
  Move( P( AIndS )^, APBuf^, ABufSize );
//*** Move Directly Moved Elems
  Move( P( ASSInd )^, P( ADDInd )^, AMoveSize );
//*** Move Bufferd Elems to Resulting Position
  Move( APBuf^, P( AIndD )^, ABufSize );
end; // end of procedure TK_RArray.MoveElemValues

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\SearchUDRefObjs
//*********************************************** TK_RArray.SearchUDRefObjs ***
// Scan Records Array Data Tree for IDB objects references fields
//
//     Parameters
// AUDRArray - Records Array container IDB object
// AFName    - path to Self in from Root IDB object Records Array
//
procedure TK_RArray.SearchUDRefObjs( AUDRArray : TN_UDBase; AFName : string );
var
  h, si : Integer;
  PFD : TK_POneFieldExecDescr;
  FullName : string;

  function ElementName( Ind : Integer; BName : string ) : string;
  var
    WName : string;
  begin
    WName := '';

    if h > 0 then
      WName := '['+IntToStr(Ind)+']'+K_sccRecFieldDelim
    else
      WName := K_udpAttrFieldDelim;

    Result := AFName + WName + BName;
  end;


//!!  procedure VarElementsLoop( PD : PChar;  BName : string );
  procedure VarElementsLoop( PD : TN_BytesPtr;  BName : string );
  var
    k : Integer;
  begin
    for k := si to h do begin
      if PObject(PD)^ <> nil then begin
        if PObject(PD)^ is TN_UDBase then
          K_UDRefSrchRoutine( TN_PUDBase(PD)^, self, AUDRArray, k, ElementName( k, BName) )
        else
          TK_PRArray(PD)^.SearchUDRefObjs( AUDRArray, ElementName(k, BName) );
      end;
      Inc( PD, ElemSize );
    end;
  end;


//!!  procedure ElementsLoop( PUD : PChar;  BName : string );
  procedure ElementsLoop( PUD : TN_BytesPtr;  BName : string );
  var
    k : Integer;
  begin
    for k := si to h do begin
      K_UDRefSrchRoutine( TN_PUDBase(PUD)^, self, AUDRArray, k, ElementName( k, BName) );
      Inc( PUD, ElemSize );
    end;
  end;

  procedure SearchRAData( SDataType : TK_ExprExtType; SInd, HInd : Integer );
  var
    j, i, n : Integer;
//!!    PD : PChar;
    PD : TN_BytesPtr;

  begin
    si := SInd;
    h := HInd;
    if (SDataType.D.TFlags and K_ffVArray) = K_ffVArray then
      VarElementsLoop( P(SInd), '' )
    else if SDataType.DTCode = Ord( nptUDRef )then
      ElementsLoop( P(SInd), '' )
    else if SDataType.DTCode > Ord(nptNoData) then begin

  //*** fields loop
      with SDataType.FD do begin
        if FDVDE = nil then BuildFieldsExecDescr;
        for j := 0 to FDUDRefsIndsList.Count - 1 do begin
          n := Integer(FDUDRefsIndsList[j]);
          PFD := GetFieldDescrByInd(n);
          with PFD^ do begin
            if (DataType.D.CFlags and (K_ccObsolete or K_ccVariant)) = 0 then begin
              FullName := GetFieldFullNameByInd(n);
//!!              PD := PChar(P(SInd)) + DataPos;
              PD := TN_BytesPtr(P(SInd)) + DataPos;
              if (DataType.D.TFlags and K_ffArray) <> 0 then  // TK_RArray
                for i := si to h do //*** Elements Loop
//!!                  TK_PRArray( PChar(P(i)) + DataPos )^.SearchUDRefObjs( AUDRArray,
                  TK_PRArray( TN_BytesPtr(P(i)) + DataPos )^.SearchUDRefObjs( AUDRArray,
                                                             ElementName(i, FullName) )
              else if (DataType.D.TFlags and K_ffVArray) <> 0 then // VarArray
                VarElementsLoop( PD, FullName )
              else if DataType.DTCode = Ord(nptUDRef) then    // TN_UDBase
                ElementsLoop( PD, FullName )
            end;
          end;
        end;
      end;
    end;
  end;

begin
  if not Assigned( self )  then Exit;
//*** Scan Attributes
  if AttrsSize > 0 then
    SearchRAData( TK_ExprExtType(Int64(FADTCode)), -1, -1 );

//*** Scan Elements
  if ((FEType.EFlags.All and K_ecfFlagsMask2) <> 0) then Exit;
  SearchRAData( FEType, 0, AHigh );
end; // end_of procedure TK_RArray.SearchUDRefObjs

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\ScanRAFields
//************************************************** TK_RArray.ScanRAFields ***
// Scan Records Array Data Tree fields
//
//     Parameters
// AUDRArray      - Records Array container IDB object
// AFName         - path to Self in from Root IDB object Records Array
// ATestFieldFunc - Records Array Test function
// AFieldTypeVal  - field type value for fields filtering
// AFieldTypeMask - field type mask for fields filtering
// Result         - Returns Test Records Array function result
//
function TK_RArray.ScanRAFields( AUDRArray : TK_UDRArray; AFName : string;
                                 ATestFieldFunc : TK_RATestFieldFunc;
                                 AFieldTypeVal : Int64 = 0; AFieldTypeMask : Int64 = 0 ) : TK_ScanTreeResult;

type TK_DataTypeStatus = (K_dtsSimple, K_dtsStruct, K_dtsRArray);
var
  PFD : TK_POneFieldExecDescr;
  CElemPath : string;
  h, i : Integer;
//!!  PD : PChar;
  PD : TN_BytesPtr;
  ElemTypeStatus : TK_DataTypeStatus;
  WType : TK_ExprExtType;
  RebuildFieldType : Boolean;
  ProperElem : Boolean;

  function GetFieldTypeDataStatus( var DataStatus : TK_DataTypeStatus;
                            FType : TK_ExprExtType;  PData : Pointer ) : TK_ExprExtType;
  begin
    Result := FType;
    Result.EFlags := K_GetExecTypeBaseFlags( Result );
    if (PData <> nil) then begin
      if (Result.EFlags.TFlags = K_ffVArray) then
        Result := K_GetExecDataTypeCode( PData^, Result )
      else if (Result.EFlags.TFlags = K_ffArray) and (TK_PRArray(PData)^ <> nil ) then
        Result := TK_PRArray(PData)^.ArrayType;
    end;
    DataStatus := K_dtsSimple;
    with Result, FD do
      if EFlags.TFlags = K_ffArray then
        DataStatus := K_dtsRArray
      else if (DTCode > Ord(nptNoData)) and
              (FDObjType < K_fdtEnum)     then
        DataStatus := K_dtsStruct;
  end;

//!!  function FieldsLoop( APD : PChar; FType : TK_ExprExtType; BName : string;
  function FieldsLoop( APD : TN_BytesPtr; FType : TK_ExprExtType; BName : string;
                       ARowInd : Integer ) : TK_ScanTreeResult;
  var
    j, k : Integer;
//!!    CPD : PChar;
    CPD : TN_BytesPtr;
    WFType : TK_ExprExtType;
    FieldTypeStatus : TK_DataTypeStatus;
    CFieldPath : string;
    CFieldName : string;
    ProperField : Boolean;
  begin
  //*** Test Field
    Result := K_tucOK;
  //*** Test Field SubTree
    with FType.FD do begin
      k := Min( FDFieldsCount, Length(FDV) ) - 1;
      for j := 0 to k do begin
        PFD := GetFieldDescrByInd(j);
        if PFD = nil then Continue;
        with PFD^ do begin
          if (DataType.D.CFlags and (K_ccObsolete or K_ccVariant)) <> 0 then Continue;
          CFieldName := FDSHE.Strings[j];
          CFieldPath := BName + CFieldName;
          CPD := APD + DataPos;

          WFType := GetFieldTypeDataStatus( FieldTypeStatus, DataType, CPD );
          ProperField := ((WFType.All xor AFieldTypeVal) and AFieldTypeMask) = 0;

          Result := K_tucOK;
          if not ProperField and (FieldTypeStatus <> K_dtsStruct) then Continue;
          if ProperField then
            Result := ATestFieldFunc( AUDRArray, Self, CPD^, WFType,
                                     CFieldName, CFieldPath, ARowInd );

          if FieldTypeStatus <> K_dtsSimple then begin
            if Result = K_tucSkipFieldsSubTree then begin
              Result := K_tucOK;
              Continue;
            end else begin
              if Result <> K_tucOK then Break;
              if FieldTypeStatus = K_dtsStruct then
              // Struct
                Result := FieldsLoop( CPD, WFType, CFieldPath + K_sccRecFieldDelim, ARowInd )
              else
              // RArray
                Result := TK_PRArray(CPD)^.ScanRAFields( AUDRArray, CFieldPath,
                                   ATestFieldFunc, AFieldTypeVal, AFieldTypeMask );
            end;
          end;

          if Result <> K_tucOK then Break;
        end;
      end;

      if Result = K_tucSkipSiblingFields then
        Result := K_tucOK;
    end;
  end;

label LExit;

begin
  Result := K_tucOK;
  if not Assigned( self )  then Exit;
  WType := ArrayType;
  //*** Scan Self Root Level
  if (AUDRArray.R = Self) and
     (((WType.All xor AFieldTypeVal) and AFieldTypeMask) = 0) then begin
    Result := ATestFieldFunc( AUDRArray, Self, Self, WType, '', AFName, -2 );
    if Result <> K_tucOK then goto LExit;
  end;

  //*** Scan Attributes
  if AttrsSize > 0 then begin
    WType := AttrsType;
    if ((WType.All xor AFieldTypeVal) and AFieldTypeMask) = 0 then begin
      CElemPath := CElemPath + K_udpAttrFieldDelim;
      Result := ATestFieldFunc( AUDRArray, Self, PA^, WType, '', CElemPath, -1 );
      if Result = K_tucOK then
        Result := FieldsLoop( PA, WType, CElemPath, -1 );
      if Result = K_tucSkipFieldsSubTree then
        Result := K_tucOK
      else if Result <> K_tucOK then goto LExit;
    end;
  end;

  //*** Scan Elements
  if (FEType.EFlags.All and K_ecfFlagsMask2) <> 0 then Exit;
  h := AHigh;
  WType := GetFieldTypeDataStatus( ElemTypeStatus, FEType, nil );
  RebuildFieldType := WType.D.TFlags = K_ffVArray;
  if not RebuildFieldType then
    RebuildFieldType := (WType.D.TFlags = K_ffArray) and (WType.DTCode = Ord(nptNotDef));
  ProperElem := ((WType.All xor AFieldTypeVal) and AFieldTypeMask) = 0;
  if not ProperElem and (ElemTypeStatus <> K_dtsStruct) then Exit;

  //*** Proper Field Type
  PD := P(0);
  for i := 0 to h do begin

    Result := K_tucOK;
    if RebuildFieldType then begin
      WType := GetFieldTypeDataStatus( ElemTypeStatus, FEType, PD );
      ProperElem := ((WType.All xor AFieldTypeVal) and AFieldTypeMask) = 0;
      if not ProperElem and (ElemTypeStatus <> K_dtsStruct) then Continue;
    end;


    CElemPath := AFName + '['+IntToStr(i)+']';

    if ProperElem then
      Result := ATestFieldFunc( AUDRArray, Self, PD^, WType, '',
                               CElemPath, i );

    if ElemTypeStatus <> K_dtsSimple then begin
      if Result = K_tucSkipFieldsSubTree then
        Result := K_tucOK
      else begin
        if Result <> K_tucOK then Break;

        if ElemTypeStatus = K_dtsStruct then
        // Struct
          Result := FieldsLoop( PD, WType, CElemPath + K_sccRecFieldDelim, i )
        else
        // RArray
          Result := TK_PRArray(PD)^.ScanRAFields( AUDRArray, CElemPath,
                        ATestFieldFunc, AFieldTypeVal, AFieldTypeMask );
      end;
    end;

    if Result <> K_tucOK then Break;
    Inc( PD, ElemSize );

  end;
  if Result = K_tucSkipSiblingRows then Result := K_tucOK;

LExit:
  if Result = K_tucSkipFieldsSubTree then Result := K_tucOK;

end; // end_of function TK_RArray.ScanRAFields

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_RArray\GetRAFieldPointer
//********************************************* TK_RArray.GetRAFieldPointer ***
// Get Records Array Element Field Pointer
//
//     Parameters
// AFieldName - field name
// Result     - Returns pointer to given field in 0-element
//
function TK_RArray.GetRAFieldPointer( const AFieldName : string ) : Pointer;
var
 UDD : TK_UDFieldsDescr;
 PFD : TK_POneFieldExecDescr;
begin
  Result := nil;
//  UDD := TK_UDFieldsDescr( GetLDataDescr );
//  if UDD = nil then Exit;
  UDD := FEType.FD;
  if Integer(UDD) <= Ord( nptNoData) then Exit;
  with UDD do
    PFD := GetFieldDescrByInd( IndexOfFieldDescr( AFieldName ) );
  if PFD <> nil then
//!!    Result := PChar(P) + PFD.DataPos;
    Result := TN_BytesPtr(P) + PFD.DataPos;
end; // end of function TK_RArray.GetRAFieldPointer

//******************************************** TK_RArray.EditByGEFunc
// Edit By GE Function
//
function  TK_RArray.EditByGEFunc( out WasEdited : Boolean;
                    DataCaption : string = ''; GEPrefix : string = '';
                    AOwnerForm : TN_BaseForm = nil;
                    AOnGlobalAction : TK_RAFGlobalActionProc = nil;
                    APRLSData : TK_PRLSData = nil;
                    ANotModalShow : Boolean = false  ) : Boolean;
var
  GEInd : Integer;
  WDType : TK_ExprExtType;

begin

  WDType := ArrayType;
  GEInd := K_GetGEFuncIndex( K_GetExecTypeName(WDType.All), GEPrefix );
  if GEInd >= 0 then begin
    with TK_PRAEditFuncCont(K_GEFPConts.Items[GEInd])^ do begin
      FDataCapt := DataCaption;
      FOnGlobalAction := AOnGlobalAction;
      FNotModalShow := ANotModalShow;
      FOwner := AOwnerForm;
      if APRLSData <> nil then
        FRLSData := APRLSData^;
      FDType := WDType;
    end;
    Result := K_EditByGEFuncInd( GEInd, Self, WasEdited );
//    Result := true;
  end else
    Result := K_EditSPLDataByGEFunc( P^, FEType, WasEdited, GEPrefix, DataCaption,
       AOwnerForm, AOnGlobalAction, APRLSData, ANotModalShow );

end; // end_of function TK_RArray.EditByGEFunc

{*** end of TK_RArray ***}

//********** TK_UDRArray class methods  **************

//********************************************** TK_UDRArray.Create ***
//
constructor TK_UDRArray.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDRArrayCI or K_RArrayObjBit;
  ImgInd := 14;
  R := TK_RArray.Create;
end; // end_of constructor TK_UDRArray.Create

//********************************************* TK_UDRArray.Destroy ***
// destroy self
//
destructor TK_UDRArray.Destroy;
begin
{
  if (R <> nil) and
    ((R.ElemType.EFlags.CFlags and K_ccNotCountUDRef) = 0) then begin
//    R.ElemType.EFlags.CFlags :=
//                R.ElemType.EFlags.CFlags or K_ccCountUDRef;
    R.ARelease;
  end;
}
// may be this code contains Error may be correct code must be
{}
  if (R <> nil) and
    ((R.ElemType.EFlags.CFlags and K_ccStopCountUDRef) = 0) then begin
    R.SetCountUDRef;
    N_i := Self.R.RefCount;
  end;
  R.ARelease;
{
N_s := Self.ObjName;
}
  inherited Destroy;
end; // end_of destructor TK_UDRArray.Destroy

//************************************** TK_UDRArray.BuildID ***
// Build  List Name
//
function TK_UDRArray.BuildID( BuildIDFlags : TK_BuildUDNodeIDFlags ) : string;
begin
  Result := inherited BuildID( BuildIDFlags );
  if (K_bnfUseObjRType in BuildIDFlags) then
    Result := Result + ':' + K_GetExecTypeName( R.ElemType.All );
end; // end_of function TK_UDRArray.BuildID

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\OnLoadError
//************************************************* TK_UDRArray.OnLoadError ***
// Prepare resulting error message and raise LoadUDDataError exception while 
// error in Self Loading Data is detected
//
//     Parameters
// AErrStr - source error message
//
procedure TK_UDRArray.OnLoadError( AErrStr : string );
var
 DType : TK_ExprExtType;
begin
  DType.All := Ord(nptUDRef);
  raise TK_LoadUDDataError.Create( K_SPLValueToString( Self, DType )+' '+AErrStr );
end; // end_of procedure TK_UDRArray.OnLoadError

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\AddFieldsToSBuf
//********************************************* TK_UDRArray.AddFieldsToSBuf ***
// Add values of IDB object self fields and incapsulated Records Array Elements 
// to serial binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
procedure TK_UDRArray.AddFieldsToSBuf( ASBuf: TN_SerialBuf );
begin
  inherited;
  if CI <> K_UDUnitDataCI then
    R.AddToSBuf( ASBuf );
end; // end_of procedure TK_UDRArray.AddFieldsToSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\GetFieldsFromSBuf
//******************************************* TK_UDRArray.GetFieldsFromSBuf ***
// Get values of base IDB object self fields and incapsulated Records Array 
// Elements from serial binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
procedure TK_UDRArray.GetFieldsFromSBuf( ASBuf: TN_SerialBuf );
begin
  try
    inherited;
    if CI <> K_UDUnitDataCI then
      R.GetFromSBuf ( ASBuf );
  except
    On E: Exception do OnLoadError( E.Message );
  end;
end; // end_of procedure TK_UDRArray.GetFieldsFromSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\AddFieldsToText
//********************************************* TK_UDRArray.AddFieldsToText ***
// Add values of IDB object self fields and incapsulated Records Array Elements 
// to serial text buffer
//
//     Parameters
// ASBuf        - serial text buffer object
// AAddObjFlags - serialized self update (ObjUFlags) and view (ObjVFlags) fields
// Result       - Returns TRUE if child objects serialization is needed, if self
//                fields and childs are serialized then resulting value is 
//                FALSE.
//
function TK_UDRArray.AddFieldsToText( ASBuf: TK_SerialTextBuf;
                                 AAddObjFlags : Boolean = true ) : boolean;
begin
  inherited AddFieldsToText( ASBuf, AAddObjFlags );
  R.AddToSTBuf( ASBuf );
  Result := true;
end; // end_of procedure TK_UDRArray.AddFieldsToText

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\GetFieldsFromText
//******************************************* TK_UDRArray.GetFieldsFromText ***
// Get values of IDB object self fields and incapsulated Records Array Elements 
// from serial text buffer
//
//     Parameters
// ASBuf  - serial text buffer object
// Result - Returns 0 if child objects deserialization is needed, if self fields
//          and childs are deserialized then resulting value is not 0.
//
function TK_UDRArray.GetFieldsFromText( ASBuf: TK_SerialTextBuf ) : Integer;
begin
  try
    inherited GetFieldsFromText( ASBuf );
    R.GetFromSTBuf( ASBuf );
  except
    On E: Exception do OnLoadError( E.Message );
  end;
  Result := 0;
end; // end_of procedure TK_UDRArray.GetFieldsFromText

//*************************************** TK_UDRArray.SaveToStrings ***
// save self to TStrings obj
//
procedure TK_UDRArray.SaveToStrings( Strings: TStrings; Mode: integer );
//var FD : TK_UDFieldsDescr;
begin
  inherited SaveToStrings( Strings, Mode );
//  FD := GetLDataDescr;
//  if FD <> nil then
  if R <> nil then
    Strings.Add( 'TypeName = ' + K_GetExecTypeName( R.ElemType.All ) );
  Strings.Add( 'ElemSize = ' + IntToStr( R.ElemSize ) );
  Strings.Add( 'ElemCount = ' + IntToStr( R.ElemCount ) );
end; // end_of procedure TK_UDRArray.SaveToStrings

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\CopyFields
//************************************************** TK_UDRArray.CopyFields ***
// Copy self fields values and incapsulated Records Array Elements from given 
// IDB object
//
//     Parameters
// ASrcObj - source IDB base (TN_UDBase) object
//
procedure TK_UDRArray.CopyFields( ASrcObj: TN_UDBase );
var
  MDFlags : TK_MoveDataFlags;
begin
  if ASrcObj = nil then Exit; // a precaution
  inherited;
  MDFlags := [K_mdfCopyRArray];
  if (TK_UDRArray(ASrcObj).R.ElemType.EFlags.CFlags and K_ccCountUDRef) <> 0 then
    Include( MDFlags, K_mdfCountUDRef );
  K_RFreeAndCopy( R, TK_UDRArray(ASrcObj).R, MDFlags );
end; // end_of procedure TK_UDRArray.CopyFields

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\Clone
//******************************************************* TK_UDRArray.Clone ***
// Clone IDB object (self fields values and incapsulated Records Array Elements)
//
//     Parameters
// ACopyFields - copy source objet fields flag (if =FALSE only new instance is 
//               created)
// Result      - Returns self clone object
//
function TK_UDRArray.Clone( ACopyFields : boolean = true ) : TN_UDBase;
begin
  Result := inherited Clone( false );
  if not ACopyFields then Exit;
  Result.CopyMetaFields( Self );
  with R do begin
    TK_UDRArray(Result).InitByRTypeCode( GetComplexType.All, ElemCount );
    TK_UDRArray(Result).R.HCol := HCol;
    if AttrsSize > 0 then
      K_MoveSPLData( PA^, TK_UDRArray(Result).R.PA^, AttrsType, [K_mdfFreeAndFullCopy] );
    if (ElemSize > 0) and (ElemCount > 0) then
      TK_UDRArray(Result).R.SetElems( P^, false, 0, ElemCount, true );
  end;
end; // end_of procedure TK_UDRArray.CopyFields

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\SameType
//**************************************************** TK_UDRArray.SameType ***
// Compare IDB object self data and incapsulated Records Array Type with given 
// IDB object
//
//     Parameters
// ACompObj - comparing IDB object
// Result   - Returns TRUE if IDB object self data and incapsulated Records 
//            Array Type is equal to given IDB
//
function TK_UDRArray.SameType( ACompObj: TN_UDBase ): boolean;
begin
  Result := inherited SameType( ACompObj ); // not yet
  if Result then
    Result := R.ArrayType.DTCode = TK_UDRArray(ACompObj).R.ArrayType.DTCode;
end; // end_of procedure TK_UDRArray.SameType

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\CompareFields
//*********************************************** TK_UDRArray.CompareFields ***
// Compare IDB object self fields and incapsulated Records Array Elements with 
// given IDB object Data
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
function TK_UDRArray.CompareFields( ACompObj: TN_UDBase; AFlags: integer;
                                    ANPath : string ) : Boolean;
begin
  Result := inherited CompareFields( ACompObj, AFlags, ANPath ); // not yet
  if not Result then Exit;
  Result := R.CompareData( TK_UDRArray(ACompObj).R,
                      Copy( ANPath, 1, Length(ANPath) - 1 ) + K_udpFieldDelim );
end; // end_of function TK_UDRArray.CompareFields

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\GetFieldsTypeFlagSet__
//************************************** TK_UDRArray.GetFieldsTypeFlagSet : ***
// Build set of incapsulated Records Array Fields Type
//
//     Parameters
// Result - Returns incapsulated Records Array complex type elements composition
//          flags set
//
function TK_UDRArray.GetFieldsTypeFlagSet : TK_FFieldsTypeFlagSet;
begin
  Result := [];
  K_AddFieldsTypeFlagSet( R.ElemType.DTCode, R.ElemType.EFlags, Result );
end; // end_of procedure TK_UDRArray.GetFieldsTypeFlagSet :

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\ScanSubTree
//************************************************* TK_UDRArray.ScanSubTree ***
// Scan incapsulated Records Array Data Tree TN_UDBase fields and Child Subtree
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
function TK_UDRArray.ScanSubTree( ATestNodeFunc : TK_TestUDChildFunc; ALevel : Integer = 0 ) : Boolean;
begin
  Result := true;
  if (K_UDScannedUObjsList <> nil) and
     ((Self.ClassFlags and K_MarkScanNodeBitD) <> 0) then Exit;

//  if ( K_UDRAFieldsScan or not K_UDOwnerChildsScan ) and
//!!  if ( (K_udtsRAFieldsScan in  K_UDTreeChildsScanFlags) and
//!!       not (K_udtsOwnerChildsOnlyScan in  K_UDTreeChildsScanFlags) ) and
  if (K_udtsRAFieldsScan in  K_UDTreeChildsScanFlags) and
     ( ((R.ElemType.EFlags.CFlags and K_ccCountUDRef) <> 0) or
       (K_fftUDRefs in GetFieldsTypeFlagSet) ) then begin
    K_UDRefSrchTestNodeFunc := ATestNodeFunc;
    K_UDRefSrchTestLevel := ALevel;
    K_UDRefSrchTestResult := K_tucOK;
    K_UDRefSrchRoutine := K_UDRefSrchScan;

    K_UDLoopProtectionList.Add(Self);
    R.SearchUDRefObjs( Self, '' );
    with K_UDLoopProtectionList do Delete(Count - 1);

    Result := (K_UDRefSrchTestResult <> K_tucSkipScan);
    if not Result then Exit;
  end;

  Result := inherited ScanSubTree( ATestNodeFunc, ALevel );
end; // end_of procedure TK_UDRArray.ScanSubTree

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\ScanRAFields
//************************************************ TK_UDRArray.ScanRAFields ***
// Scan incapsulated Records Array Data Tree fields
//
//     Parameters
// ATestFieldFunc - Records Array Test function
// AFieldTypeVal  - field type value for fields filtering
// AFieldTypeMask - field type mask for fields filtering
// Result         - Returns Test Records Array function result
//
function TK_UDRArray.ScanRAFields( ATestFieldFunc: TK_RATestFieldFunc;
                                   AFieldTypeVal : Int64 = 0;
                                   AFieldTypeMask : Int64 = 0 ): TK_ScanTreeResult;
begin
  Result := R.ScanRAFields( Self, '', ATestFieldFunc,
                            AFieldTypeVal, AFieldTypeMask );
  if Result = K_tucSkipFieldsScan then Result := K_tucOK;
end; // end_of TK_UDRArray.ScanRAFields

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\BuildSubTreeRefObjs
//***************************************** TK_UDRArray.BuildSubTreeRefObjs ***
// Convert IDB Subnet to Tree due to replacing direct references to IDB Objects 
// to special reference objects
//
// Scan incapsulated Records Array Data Tree TN_UDBase fields and Child Subtree.
//
procedure TK_UDRArray.BuildSubTreeRefObjs(  );
begin
  if ((R.ElemType.EFlags.CFlags and K_ccCountUDRef) <> 0) or
     (K_fftUDRefs in GetFieldsTypeFlagSet) then begin
    K_UDRefSrchRoutine := K_UDRefSrchBuildRefObjs;

    R.SearchUDRefObjs( Self, '' );

  end;

  inherited;
end; // end_of procedure TK_UDRArray.BuildSubTreeRefObjs

{
//************************************** TK_UDRArray.ReplaceSubTreeRelPaths ***
// Build list of Ref Objects for RArray "TN_UDBase" fields
//
procedure TK_UDRArray.ReplaceSubTreeRelPaths( CurPath : string = ''; SL : TStrings = nil;
              ObjNameType : TK_UDObjNameType = K_ontObjName );
begin
  if ((R.ElemType.EFlags.CFlags and K_ccCountUDRef) <> 0) or
     (K_fftUDRefs in GetFieldsTypeFlagSet) then begin
    K_UDRefSrchSL := SL;
    K_UDRefSrchNameType := ObjNameType;
    K_UDRefSrchCurPath  := CurPath;
    K_UDRefSrchRoutine := K_UDRefSrchReplaceRelPaths;

    K_UDLoopProtectionList.Add(Self);
    R.SearchUDRefObjs( Self, '' );
    with K_UDLoopProtectionList do Delete(Count - 1);

  end;
  inherited;
end; // end_of procedure TK_UDRArray.ReplaceSubTreeRelPaths
}

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\ClearSubTreeRefInfo
//***************************************** TK_UDRArray.ClearSubTreeRefInfo ***
// Clear IDB Subnet Reference Info (RefPath, RefIndex, Marker) after Subnet data
// serialization
//
//     Parameters
// ARoot              - IDB Subnet Root object from which clear reference info 
//                      tree-walk starts
// AClearRefInfoFlags - clear serialization reference info flags set
//
// Scan incapsulated Records Array Data Tree TN_UDBase fields and Child Subtree.
//
procedure TK_UDRArray.ClearSubTreeRefInfo( ARoot : TN_UDBase = nil;
                           AClearRefInfoFlags : TK_ClearRefInfoFlags = [] );
begin
  if (K_UDScannedUObjsList <> nil) and
     ((Self.ClassFlags and K_MarkScanNodeBitD) <> 0) then Exit;

  if ((R.ElemType.EFlags.CFlags and K_ccCountUDRef) <> 0) or
     (K_fftUDRefs in GetFieldsTypeFlagSet) then begin
    K_UDRefSrchClearFlags := AClearRefInfoFlags;
    K_UDRefSrchClearRoot  := ARoot;
    K_UDRefSrchRoutine := K_UDRefSrchClearInfo;

    R.SearchUDRefObjs( Self, '' );

  end;

  inherited;

end; // end_of procedure TK_UDRArray.ClearSubTreeRefInfo

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\ReplaceSubTreeRefObjs
//*************************************** TK_UDRArray.ReplaceSubTreeRefObjs ***
// Convert IDB Tree created after deserialization to Subnet (replace special 
// reference objects to direct references)
//
// Scan incapsulated Records Array Data Tree TN_UDBase fields and Child Subtree.
//
procedure TK_UDRArray.ReplaceSubTreeRefObjs;
begin
  if ((Self.ClassFlags and K_MarkScanNodeBitD) <> 0) then Exit;

  if ((R.ElemType.EFlags.CFlags and K_ccCountUDRef) <> 0) or
     (K_fftUDRefs in GetFieldsTypeFlagSet) then begin
    K_UDRefSrchRoutine := K_UDRefSrchReplaceRefObjs;

    K_UDLoopProtectionList.Add(Self);
    R.SearchUDRefObjs( Self, '' );
    with K_UDLoopProtectionList do Delete(Count - 1);
  end;

  inherited;

end; // end_of procedure TK_UDRArray.ReplaceSubTreeRefObjs

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\ReplaceSubTreeNodes
//***************************************** TK_UDRArray.ReplaceSubTreeNodes ***
// Replace IDB Subnet Child nodes references
//
//     Parameters
// ARepChildsArray - array of pairs (OldReference,NewReference)
//
// Scan incapsulated Records Array Data Tree TN_UDBase fields and Child Subtree.
//
procedure TK_UDRArray.ReplaceSubTreeNodes( ARepChildsArray : TK_BaseArray );
begin

  if (Self = nil)                                   or
     (ARepChildsArray.Count = 0)                     or
     ((Self.ClassFlags and K_MarkScanNodeBitD) <> 0) or
     ( ((R.ElemType.EFlags.CFlags and K_ccCountUDRef) = 0) and
       not (K_fftUDRefs in GetFieldsTypeFlagSet) ) then Exit;

  K_UDRefSrchRepArr := ARepChildsArray;
  K_UDRefSrchRoutine := K_UDRefSrchReplaceNodes;

  R.SearchUDRefObjs( Self, '' );

  inherited;

end; // end of procedure TK_UDRArray.ReplaceSubTreeNodes

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\MarkSubTree
//************************************************* TK_UDRArray.MarkSubTree ***
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
// Scan incapsulated Records Array Data Tree TN_UDBase fields and Child Subtree.
//
// Global variable K_UDTreeChildsScanFlags contains flags set to control IDB 
// Subnet scanning.
//
procedure TK_UDRArray.MarkSubTree( AMarkType : Integer = 0; ADepth : Integer = -1;
                                   AField : Integer = -1 );
begin
  inherited;
  if ADepth = 0 then Exit;
  if ADepth > 0 then Dec(ADepth);

//  if (K_UDRAFieldsScan or not K_UDOwnerChildsScan) and
//!!  if ((K_udtsRAFieldsScan in K_UDTreeChildsScanFlags) and
//!!       not (K_udtsOwnerChildsOnlyScan in K_UDTreeChildsScanFlags)) and
  if (K_udtsRAFieldsScan in K_UDTreeChildsScanFlags) and
     ( ((R.ElemType.EFlags.CFlags and K_ccCountUDRef) <> 0) or
       (K_fftUDRefs in GetFieldsTypeFlagSet) ) then begin
    K_UDRefSrchMarkLevel := AMarkType;
    K_UDRefSrchMarkDepth := ADepth;
    K_UDRefSrchMarkField := AField;
    K_UDRefSrchRoutine := K_UDRefSrchMark;

    K_UDLoopProtectionList.Add(Self);
    R.SearchUDRefObjs( Self, '' );
    with K_UDLoopProtectionList do Delete(Count - 1);

  end;
end; // end_of procedure TK_UDRArray.MarkSubTree

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\UnMarkSubTree
//*********************************************** TK_UDRArray.UnMarkSubTree ***
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
// Scan incapsulated Records Array Data Tree TN_UDBase fields and Child Subtree.
//
// Global variable K_UDTreeChildsScanFlags contains flags set to control IDB 
// Subnet scanning.
//
procedure TK_UDRArray.UnMarkSubTree( ADepth, AField: Integer );
begin
  inherited;
//  if not K_UDRAFieldsScan or
//     K_UDOwnerChildsScan  or
//!!  if not (K_udtsRAFieldsScan in K_UDTreeChildsScanFlags) or
//!!     (K_udtsOwnerChildsOnlyScan in K_UDTreeChildsScanFlags)  or
  if ADepth = 0 then Exit;
  if ADepth > 0 then Dec(ADepth);

  if (K_udtsRAFieldsScan in K_UDTreeChildsScanFlags) and
     ( ((R.ElemType.EFlags.CFlags and K_ccCountUDRef) <> 0) or
       (K_fftUDRefs in GetFieldsTypeFlagSet) ) then begin
    K_UDRefSrchMarkDepth := ADepth;
    K_UDRefSrchMarkField := AField;
    K_UDRefSrchRoutine := K_UDRefSrchUnMark;

    K_UDLoopProtectionList.Add(Self);
    R.SearchUDRefObjs( Self, '' );
    with K_UDLoopProtectionList do Delete(Count - 1);

  end;
end; // end_of procedure TK_UDRArray.UnMarkSubTree

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\GetPathToUDObj
//********************************************** TK_UDRArray.GetPathToUDObj ***
// Build Path List to specified DirEntry from self Get relative path to given 
// object in IDB Subnet
//
//     Parameters
// ASrchObj     - IDB object for search
// AObjNameType - name type (ObjName,ObjAliase etc.) enumeration
// Result       - Returns IDB relative path
//
// Resulting value is empty string if given object is not found in given IDB 
// Subnet.
//
// Scan incapsulated Records Array Data Tree TN_UDBase fields and Child Subtree.
//
// Global variable K_UDTreeChildsScanFlags contains flags set to control IDB 
// Subnet scanning.
//
// Do not call GetPathToUDObj directly, it is used automatically in 
// K_GetPathToUObj.
//
function TK_UDRArray.GetPathToUDObj( ASrchObj : TN_UDBase;
                AObjNameType : TK_UDObjNameType = K_ontObjName ) : string;
var
  i : Integer;
begin
  Result := '';
  if (K_UDScannedUObjsList <> nil) and
     ((Self.ClassFlags and K_MarkScanNodeBitD) <> 0) then Exit;
  Result := inherited GetPathToUDObj( ASrchObj, AObjNameType );
  if Result <> '' then Exit;
  if (K_udtsRAFieldsScan in K_UDTreeChildsScanFlags) then begin

    K_UDRefSrchFieldsList := TStringList.Create;
    K_UDRefSrchPath := '';
    K_UDRefSrchSrchObj := ASrchObj;
    K_UDRefSrchNameType := AObjNameType;
    K_UDRefSrchRoutine := K_UDRefSrchGetPathToUDObj;

    R.SearchUDRefObjs( Self, '' );

    if K_UDRefSrchPath <> '' then begin
      Result := K_udpFieldDelim + K_UDRefSrchPath;
      Exit;
    end;

    if not (K_udtsSkipRAFieldsSubTreeScan in K_UDTreeChildsScanFlags) then
      for i := 0 to K_UDRefSrchFieldsList.Count - 1 do begin
        Result := TN_UDBase(K_UDRefSrchFieldsList.Objects[i]).GetPathToUDObj( ASrchObj, AObjNameType );
        if Result = '' then Continue;
        if //(K_udtsRAFieldsScan in K_UDTreeChildsScanFlags) and
           (Result[1] <> K_udpFieldDelim) then
          Result := K_udpPathDelim + Result;
        Result := K_udpFieldDelim + K_UDRefSrchFieldsList[i] + Result;
        Exit;
      end;

    K_UDRefSrchFieldsList.Free;
  end;
end; // end_of function TK_UDRArray.GetPathToUDObj


//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\PDRA
//******************************************************** TK_UDRArray.PDRA ***
// Get Pointer to RArray
//
function TK_UDRArray.PDRA : TK_PRArray;
begin
  Result := nil;
  if Self = nil then Exit;
  if ObjLiveMark <> N_ObjLiveMark then
    raise TK_UDBaseConsistency.Create( 'TK_UDRArray.PDRA Consistency Error' );
  Result := @R;
end; // end_of procedure TK_UDRArray.PDRA

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\PDE
//********************************************************* TK_UDRArray.PDE ***
// Get Pointer to incapsulated Records Array Element by index
//
//     Parameters
// AInd   - Element index
// Result - Returns pointer to given Element
//
function TK_UDRArray.PDE( AInd : Integer ) : Pointer;
begin
  Result := nil;
  if Self = nil then Exit;
  if ObjLiveMark <> N_ObjLiveMark then
    raise TK_UDBaseConsistency.Create( 'TK_UDRArray.PDE Consistency Error' );
  Result := R.P(AInd);
end; // end_of procedure TK_UDRArray.PDRA

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\AHigh
//******************************************************* TK_UDRArray.AHigh ***
// Get incapsulated Records Array last Element index
//
//     Parameters
// Result - Returns last Element index
//
function  TK_UDRArray.AHigh : Integer;
begin
  Result := -1;
  if Self = nil then Exit;
  if ObjLiveMark <> N_ObjLiveMark then
    raise TK_UDBaseConsistency.Create( 'TK_UDRArray.AHigh Consistency Error' );
  Result := R.AHigh
end; // end_of procedure TK_UDRArray.AHigh

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\ALength
//***************************************************** TK_UDRArray.ALength ***
// Get incapsulated Records Array Elements counter
//
//     Parameters
// Result - Returns Elements counter
//
function  TK_UDRArray.ALength : Integer;
begin
  Result := 0;
  if Self = nil then Exit;
  if ObjLiveMark <> N_ObjLiveMark then
    raise TK_UDBaseConsistency.Create( 'TK_UDRArray.ALength Consistency Error' );
  Result := R.ALength;
end; // end_of procedure TK_UDRArray.ALength

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\ASetLength
//************************************************** TK_UDRArray.ASetLength ***
// Set incapsulated Records Array Elements counter
//
//     Parameters
// ALength - given Elements counter
//
procedure TK_UDRArray.ASetLength( ALength : Integer);
begin
  R.ASetLength( ALength );
end; // end_of procedure TK_UDRArray.ASetLength

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\ChangeElemsType
//********************************************* TK_UDRArray.ChangeElemsType ***
// Set new Elements Type Code to incapsulated Records Array
//
//     Parameters
// ANewElemTypeCode - given Elements Type Code
//
procedure TK_UDRArray.ChangeElemsType( ANewElemTypeCode : Int64 );
var
  VLength : Integer;
begin
  with R do begin
   VLength := ALength;
   ARelease;
  end;
  R := K_RCreateByTypeCode( ANewElemTypeCode, VLength, [K_crfCountUDRef] );
end; // end_of procedure TK_UDRArray.ChangeElemsType

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\SPLInit
//***************************************************** TK_UDRArray.SPLInit ***
// Initialize incapsulated Records Array Elements Data
//
//     Parameters
// AEFD - SPL Data Type fields description IDB object ( parameter used only 
//        during SPL Unit compilation)
//
// Used automatically in SPL environment.
//
procedure TK_UDRArray.SPLInit( AEFD : TK_UDFieldsDescr = nil );
var
  i : Integer;
begin
  with R, ElemType do begin
    if AEFD = nil then AEFD := FD;
    if DTCode <= Ord( nptNoData) then Exit;
    for i := 0 to ElemCount - 1 do
      AEFD.InitData( P( i )^ );
  end;
end; // end_of procedure TK_UDRArray.SPLInit

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\PascalInit
//************************************************** TK_UDRArray.PascalInit ***
// Initialize incapsulated Records Array Elements Data
//
// Used automatically in Pascal environment. Override this method if needed in 
// successor Classes.
//
procedure TK_UDRArray.PascalInit;
begin
end; // end_of procedure TK_UDRArray.PascalInit


//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\InitByRTypeCode
//********************************************* TK_UDRArray.InitByRTypeCode ***
// Initialize incapsulated Records Array just after TK_UDRArray construction
//
//     Parameters
// ATypeCode        - Records Array complex Type Code
// ALength          - Records Array Elements counter
// ACallInitRoutine - call PascalInit method flag
//
procedure  TK_UDRArray.InitByRTypeCode( ATypeCode : Int64; ALength : Integer = 1;
                                        ACallInitRoutine : Boolean = true );

  function IfNeedCountUDRef( ATypeCode  : Int64 ) : Boolean;
  begin
    Result := ((TK_ExprExtType(ATypeCode).DTCode >= Ord(nptUDRef)) and
              ((TK_ExprExtType(ATypeCode).D.TFlags and K_ffFlagsMask) = 0));
  end;

begin
  R.SetComplexType( TK_ExprExtType(ATypeCode) );
//    R.ElemType := TK_ExprExtType(TypeCode);
{
  if (TK_ExprExtType(TypeCode).DTCode > Ord(nptNoData)) or
     ( (TK_ExprExtType(TypeCode).DTCode = Ord(nptUDRef)) and
       ((TK_ExprExtType(TypeCode).D.TFlags and K_ffFlagsMask) = 0) ) then
}
  // UDRef or VarArray or Record

  if IfNeedCountUDRef(ATypeCode) or
     IfNeedCountUDRef(R.AttrsType.All) then
    R.SetCountUDRef;

  R.ASetLength( ALength );
  if ACallInitRoutine then PascalInit;
end; // end of procedure TK_UDRArray.InitByRTypeCode

{
//************************************** TK_UDRArray.SetValues ***
// set Array Element Values From Data Pointer
//
procedure TK_UDRArray.SetValues( var PData );
begin
  R.SetElems( PData, true );
end; // end_of procedure TK_UDRArray.SetValues

//************************************** TK_UDRArray.GetLDataDescr ***
// Get Fields Description Object
//
function TK_UDRArray.GetLDataDescr : TK_UDFieldsDescr;
begin
//  if R <> nil then begin
//    Result := R.ElemType.FD;
//    Exit;
//  end else

  if DirHigh >= 0 then begin
    Result := TK_UDFieldsDescr( DirChild( 0 ) );
    if (Result <> nil) and
       ((Result.ClassFlags and $FF) = K_UDFieldsDescrCI) then Exit;
  end;
  Result := nil;
end; // end of function TK_UDRArray.GetLDataDescr
}

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\GetFieldPointer
//********************************************* TK_UDRArray.GetFieldPointer ***
// Get incapsulated Records Array Element Field Pointer
//
//     Parameters
// AFieldName - field name
// Result     - Returns pointer to given field in 0-element
//
function TK_UDRArray.GetFieldPointer( const AFieldName : string ) : Pointer;
var
 PFD : TK_POneFieldExecDescr;
begin
  Result := nil;
  with R.ElemType do begin
    if DTCode <= Ord( nptNoData) then Exit;
    with FD do
      PFD := GetFieldDescrByInd( IndexOfFieldDescr( AFieldName ) );
    if PFD <> nil then
//!!      Result := PChar(R.P) + PFD.DataPos;
      Result := TN_BytesPtr(R.P) + PFD.DataPos;

  end;
//    Result := PChar(@R.V[0]) + PFD.DataPos;
end; // end of function TK_UDRArray.GetFieldPointer

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\IsSPLType
//*************************************************** TK_UDRArray.IsSPLType ***
// Check if incapsulated Records Array Element has given Type
//
//     Parameters
// ATypeName - given Type Name
// Result    - Returns TRUE if Self is TK_UDRArray and incapsulated Records 
//             Array Element Type is equal to given
//
function TK_UDRArray.IsSPLType( ATypeName : string ) : Boolean;
begin
  Result := (K_GetExecTypeName( R.ElemType.All ) = ATypeName);
end; // end_of function TK_UDRArray.IsSPLType

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\CallSPLClassConstructor
//************************************* TK_UDRArray.CallSPLClassConstructor ***
// Call SPL Class Constructor
//
//     Parameters
// AConstructorName - name of SPL Class Constructor routine
// AParams          - array of given SPL Class Constructor parameters
//
// Is used to create SPL class object instance from Pascal
//
procedure TK_UDRArray.CallSPLClassConstructor( AConstructorName : string;
                                                    AParams : array of const );
var
  GC : TK_CSPLCont;
begin
  GC := K_PrepSPLRunGCont;
  CallSPLClassMethod( AConstructorName, AParams, GC );
//*** Replace StackLevel to Init Position
  Dec( GC.ExprStackLevel, SizeOf(Self) + SizeOf(TK_ExprExtType) );
  K_FreeSPLRunGCont( GC );

end; // end of function TK_UDRArray.CallSPLClassConstructor

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\CallSPLClassMethod
//****************************************** TK_UDRArray.CallSPLClassMethod ***
// Call SPL Class method (procedure and function)
//
//     Parameters
// AClassMethodName - name of SPL Class method
// AParams          - array of given SPL Class method parameters
// AGC              - SPL interpreter Global Context Object
//
// Is used to call SPL class method from Pascal
//
procedure TK_UDRArray.CallSPLClassMethod( AClassMethodName : string;
                          AParams : array of const; AGC : TK_CSPLCont = nil  );
var
  MSelfType : TK_ExprExtType;
  PFD : TK_POneFieldExecDescr;
  PSelfData : Pointer;
  UDType : TK_UDFieldsDescr;
begin
//  UDType := GetLDataDescr;
  UDType := R.ElemType.FD;

  with UDType do
    PFD := GetFieldDescrByInd( IndexOfFieldDescr( AClassMethodName ) );

  if (PFD = nil) or
     (
//       ((PFD.DataType.D.TFlags and K_ffClassConstructor) = 0) and
       ((PFD.DataType.D.TFlags and K_ffClassMethod) = 0)
     ) then Exit;

//*** call Class Contructor Create
  AGC := K_PrepSPLRunGCont( AGC );
//  if ((PFD.DataType.D.TFlags and K_ffClassConstructor) <> 0) then
  if PFD.DataType.FD.FDObjType = K_fdtClassConstructor then
//*** Put Class Object UDInstance to Stack
    AGC.PutDataToExprStack( Self, Ord(nptUDRef) )
  else
    TK_UDProgramItem(PFD.DataPos).ReserveResultSpaceInSPLStack( AGC );

//*** Put Params to Stack
  TK_UDProgramItem(PFD.DataPos).PutParamsArrayToSPLStack( AParams, AGC );
  MSelfType.All := 0;
  MSelfType.DTCode := Integer( UDType );
  MSelfType.D.TFlags := K_ffPointer;
//*** Put Class Object Data Pointer to Stack
  PSelfData := Self.R.P;
//  PSelfData := @Self.R.V[0];
  AGC.PutDataToExprStack( PSelfData, MSelfType.All );

  TK_UDProgramItem(PFD.DataPos).SPLExecute( AGC );
  K_FreeSPLRunGCont( AGC );

end; // end of function TK_UDRArray.CallSPLClassMethod

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\CDimIndsConv
//************************************************ TK_UDRArray.CDimIndsConv ***
// Self Code Dimention Items Indices Fields Conversion if i is old CDim Item 
// Index then ConvInds[i] is new CDim Item Index if ConvInds[i] = -1 then CDim 
// Item with Index i is now absent in CDim
//
function  TK_UDRArray.CDimIndsConv( UDCD: TN_UDBase; PConvInds: PInteger;
                                    RemoveUndefInds: Boolean ) : Boolean;
var
  FieldMask : Int64;
begin
  UDCDim := UDCD;
  PUDCDimConvInds := PConvInds;
  UDCDimRemoveUndefInds := RemoveUndefInds;
  FieldMask := Int64(K_ffArray) shl (SizeOf(Integer)*SizeOf(Byte));
  R.ScanRAFields( Self, '', ScanRAFieldsForCDimIndsConv, FieldMask, FieldMask );
  Result := true;
end; // end of procedure TK_UDRArray.CDimIndsConv

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\CDimLinkedDataReorder
//*************************************** TK_UDRArray.CDimLinkedDataReorder ***
// Self Linked to Code Dimention Data Reorder
//
procedure TK_UDRArray.CDimLinkedDataReorder;
var
  FieldMask : Int64;
begin
  FieldMask := (Int64(K_ffArray) shl (SizeOf(Integer)*8));
  R.ScanRAFields( Self, '', ScanRAFieldsForCDimLinkedDataReorder, FieldMask, FieldMask );
end; // end of TK_UDRArray.CDimLinkedDataReorder

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\ScanRAFieldsForCDimIndsConv
//********************************* TK_UDRArray.ScanRAFieldsForCDimIndsConv ***
// Self Code Dimention Items Indices Fields Conversion Scan Fields
//
function TK_UDRArray.ScanRAFieldsForCDimIndsConv( UDRoot : TN_UDBase; RARoot : TK_RArray;
                    var Field; FieldType : TK_ExprExtType; FieldName : string;
                    FieldPath : string; RowInd : Integer ) : TK_ScanTreeResult;
begin
  Result := K_tucSkipFieldsSubTree;
  if FieldType.DTCode <= Ord(nptNoData)  then Exit;
  Result := K_tucOK;
  if FieldType.D.TFlags <> K_ffArray then Exit;
  Result := K_tucSkipFieldsSubTree;
  if TK_RArray(Field) = nil then Exit;
  if FieldType.DTCode = K_GetCSDimRAType.DTCode then
    K_RebuildRACSDim( TK_RArray(Field), UDCDim, PUDCDimConvInds, UDCDimRemoveUndefInds, nil, nil )
  else if FieldType.DTCode = K_GetCDRelRAType.DTCode then
    K_RebuildRACDRel( TK_RArray(Field), UDCDim, PUDCDimConvInds, UDCDimRemoveUndefInds, nil, nil )
  else if K_IfRADBlock( TK_RArray(Field) ) then
    K_RADBlockCDimIndsConv( TK_RArray(Field), UDCDim, PUDCDimConvInds, UDCDimRemoveUndefInds )
  else
    Result := K_tucOK;
end; //*** end of function ScanRAFieldsForCDimIndsConv

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDRArray\ScanRAFieldsForCDimLinkedDataReorder
//************************ TK_UDRArray.ScanRAFieldsForCDimLinkedDataReorder ***
// Self Linked to Code Dimention Data Reorder Scan Fields
//
function TK_UDRArray.ScanRAFieldsForCDimLinkedDataReorder( UDRoot : TN_UDBase;
                    RARoot : TK_RArray; var Field; FieldType : TK_ExprExtType;
                    FieldName : string; FieldPath : string;
                    RowInd : Integer ) : TK_ScanTreeResult;
begin
  Result := K_tucSkipFieldsSubTree;
  if (FieldType.DTCode <= Ord(nptNoData)) then Exit;
  Result := K_tucOK;
  if FieldType.D.TFlags <> K_ffArray then Exit;
  Result := K_tucSkipFieldsSubTree;
  if FieldType.DTCode = K_GetCDRelRAType.DTCode then
    K_RACDRelLinkedDataReorder( TK_RArray(Field) )
  else if K_IfRADBlock( TK_RArray(Field) ) then
    K_RADBlockCDLDataReorder( TK_RArray(Field) )
  else
    Result := K_tucOK;
end; //*** end of function ScanRAFieldsForCDimLinkedDataReorder

//********** end of TK_UDRArray class methods  **************

{*** TK_UDUnitData ***}
//************************************** TK_UDUnitData.Destroy
//
destructor TK_UDUnitData.Destroy;
begin
  R.ARelease;
  R := nil;
  inherited;
end; // end of destructor TK_UDUnitData.Destroy
{*** end of TK_UDUnitData ***}

{*** TK_UDStringList ***}
//********************************************** TK_UDStringList.Create ***
//
constructor TK_UDStringList.Create;
begin
  inherited Create;
  ClassFlags := K_UDStringListCI;
  SL := TStringList.Create;
end; // end_of constructor TK_UDStringList.Create

//********************************************* TK_UDStringList.Destroy ***
//
destructor TK_UDStringList.Destroy;
begin
  SL.Free;
  inherited Destroy;
end; // end_of destructor TK_UDStringList.Destroy

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDStringList\AddFieldsToSBuf
//***************************************** TK_UDStringList.AddFieldsToSBuf ***
// Add values of IDB object self fields and user Strings Data to serial binary 
// buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
// Only self fields are serialized (without any childs data)
//
procedure TK_UDStringList.AddFieldsToSBuf( ASBuf: TN_SerialBuf );
begin
  inherited;
  ASBuf.AddRowBytes( 1, @SaveLoadFlag );
  if SaveLoadFlag = 1 then
    ASBuf.AddRowStrings( SL );
end; // end_of procedure TK_UDStringList.AddFieldsToSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDStringList\GetFieldsFromSBuf
//*************************************** TK_UDStringList.GetFieldsFromSBuf ***
// Get values of IDB object self fields and user Strings Data from serial binary
// buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
// Only self fields are deserialized (without any childs data)
//
procedure TK_UDStringList.GetFieldsFromSBuf( ASBuf: TN_SerialBuf );
//var
// LF : Byte;
begin
  inherited;
  ASBuf.GetRowBytes( 1, @SaveLoadFlag );
  if SaveLoadFlag = 1 then
    ASBuf.GetRowStrings ( SL );
end; // end_of procedure TK_UDStringList.GetFieldsFromSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDStringList\AddFieldsToText
//***************************************** TK_UDStringList.AddFieldsToText ***
// Add values of IDB object self fields and user Strings Data to serial text 
// buffer
//
//     Parameters
// ASBuf        - serial text buffer object
// AAddObjFlags - serialized self update (ObjUFlags) and view (ObjVFlags) fields
// Result       - Returns TRUE if child objects serialization is needed, if self
//                fields and childs are serialized then resulting value is 
//                FALSE.
//
function TK_UDStringList.AddFieldsToText( ASBuf: TK_SerialTextBuf;
                                 AShowFlags : Boolean = true ) : boolean;
begin
  inherited AddFieldsToText( ASBuf, AShowFlags );
  if SaveLoadFlag <> 0 then ASBuf.AddTagAttr( 'SaveStrings', SaveLoadFlag, K_isUInt1 );
  ASbuf.AddRowStrings(SL);
  Result := true;
end; // end_of procedure TK_UDStringList.AddFieldsToText

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDStringList\GetFieldsFromText
//*************************************** TK_UDStringList.GetFieldsFromText ***
// Get values of IDB object self fields and user Strings Data from serial text 
// buffer
//
//     Parameters
// ASBuf  - serial text buffer object
// Result - Returns 0 if child objects deserialization is needed, if self fields
//          and childs are deserialized then resulting value is not 0.
//
function TK_UDStringList.GetFieldsFromText( ASBuf: TK_SerialTextBuf ) : Integer;
begin
  inherited GetFieldsFromText( ASBuf );
  ASBuf.GetTagAttr( 'SaveStrings', SaveLoadFlag, K_isUInt1 );
  ASBuf.GetRowStrings(SL);
  Result := 0;
end; // end_of procedure TK_UDStringList.GetFieldsFromText

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDStringList\CopyFields
//********************************************** TK_UDStringList.CopyFields ***
// Copy self fields and user Strings Data values from given TK_UDStringList 
// object
//
//     Parameters
// ASrcObj - source IDB base (TN_UDBase) object
//
procedure TK_UDStringList.CopyFields( ASrcObj: TN_UDBase );
begin
  if ASrcObj = nil then Exit; // a precaution
  inherited;
  SL.Assign( TK_UDStringList(ASrcObj).SL );
end; // end_of procedure TK_UDStringList.CopyFields

//*************************************** TK_UDStringList.SaveToStrings ***
// save self to TStrings obj
//
procedure TK_UDStringList.SaveToStrings( Strings: TStrings; Mode: integer );
begin
  inherited SaveToStrings( Strings, Mode );
  Strings.BeginUpdate;
  Strings.Add( '   Number of strings: ' + IntToStr(SL.Count) );
  Strings.AddStrings( SL );
  Strings.Add( '<End_of_StringList>' );
  Strings.EndUpdate;
  if Mode = 0 then Strings.Add( '' );
end; // end_of procedure TK_UDStringList.SaveToStrings

{*** end_of TK_UDStringList ***}

{*** TK_UDUnit ***}
//************************************************ TK_UDUnit.Create ***
//
constructor TK_UDUnit.Create;
begin
  inherited;
//  ClassFlags := K_UDUnitCI;
  ClassFlags := K_UDUnitCI;
  ObjFlags := K_fpObjSkipChildsSave;
  ImgInd := 77;
end; //*** end of TK_UDUnit.Create ***

//************************************************ TK_UDUnit.Destroy ***
//
destructor TK_UDUnit.Destroy;
begin
  inherited;
end; //*** end of TK_UDUnit.Destroy ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDUnit\AddFieldsToSBuf
//*********************************************** TK_UDUnit.AddFieldsToSBuf ***
// Add values of IDB object self fields and SPL Unit Strings Data to serial 
// binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
// Global variable K_UDGControlFlags controls SPL Unit Strings serialization
//
// Only self fields are serialized (without any childs data)
//
procedure TK_UDUnit.AddFieldsToSBuf( SBuf: TN_SerialBuf );
begin
  SaveLoadFlag := 1;
  if K_gcfSkipUDUnitSrcBinData in K_UDGControlFlags then
    SaveLoadFlag := 0;
  inherited;
end; // end_of procedure TK_UDUnit.AddFieldsToSBuf
{
//**************************************** TK_UDUnit.GetFieldsFromSBuf ***
// load self from Serial Buf
//
procedure TK_UDUnit.GetFieldsFromSBuf( SBuf: TN_SerialBuf );
begin
  inherited;
  SBuf.GetRowStrings ( SL );
end; // end_of procedure TN_UDStringList.GetFieldsFromSBuf
}
//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDUnit\AddFieldsToText
//*********************************************** TK_UDUnit.AddFieldsToText ***
// Add values of IDB object self fields and SPL Unit Strings Data to serial text
// buffer
//
//     Parameters
// ASBuf        - serial text buffer object
// AAddObjFlags - serialized self update (ObjUFlags) and view (ObjVFlags) fields
// Result       - Returns TRUE if child objects serialization is needed, if self
//                fields and childs are serialized then resulting value is 
//                FALSE.
//
function TK_UDUnit.AddFieldsToText( ASBuf: TK_SerialTextBuf;
                                    AAddObjFlags : Boolean = true ) : boolean;
begin
  inherited AddFieldsToText( ASBuf, AAddObjFlags );
  Result := true;
end; // end_of procedure TK_UDUnit.AddFieldsToText

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDUnit\GetFieldsFromText
//********************************************* TK_UDUnit.GetFieldsFromText ***
// Get values of IDB object self fields and SPL Unit Data from serial text 
// buffer
//
//     Parameters
// ASBuf  - serial text buffer object
// Result - Returns 0 if child objects deserialization is needed, if self fields
//          and childs are deserialized then resulting value is not 0.
//
function TK_UDUnit.GetFieldsFromText( SBuf: TK_SerialTextBuf ) : Integer;
begin
  inherited GetFieldsFromText( SBuf );
  Result := 0;
end; // end_of procedure TK_UDUnit.GetFieldsFromText

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDUnit\GetGlobalData
//************************************************* TK_UDUnit.GetGlobalData ***
// Get SPL Unit Global Data object
//
//     Parameters
// Result - Returns IDB Object (TK_UDRArray) with SPL Unit Global Data
//
function TK_UDUnit.GetGlobalData: TK_UDRArray;
begin
{
  Result := TK_UDRArray( DirChild( 1 ) );
  if (Result = nil)                             or
     (Result.ClassFlags and K_RArrayObjBit = 0) or
     (Result.ObjName <> K_sccUnitDataNode) then
    Result := nil;
}
  Result := TK_UDRArray( DirChild( DirHigh ) );
  if (Result = nil)           or
     not K_IsUDRArray(Result) or
     (Result.ObjName <> K_sccUnitDataNode) then
    Result := nil;
end; // end_of procedure TK_UDUnit.GetGlobalData

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDUnit\GetGlobalDataFD
//*********************************************** TK_UDUnit.GetGlobalDataFD ***
// Get SPL Unit Global Data Type Description object
//
//     Parameters
// Result - Returns IDB Object (TK_UDFieldsDEscr) with SPL Unit Global Data 
//          Records Array Type Description
//
function TK_UDUnit.GetGlobalDataFD: TK_UDFieldsDEscr;
var
  GD : TK_UDRArray;
begin
{
  Result := TK_UDRArray( DirChild( 1 ) );
  if (Result = nil)                             or
     (Result.ClassFlags and K_RArrayObjBit = 0) or
     (Result.ObjName <> K_sccUnitDataNode) then
    Result := nil;
}
  Result := nil;
  GD := GetGlobalData;
  if GD <> nil then
    Result := GD.R.GetComplexType.FD;
end; // end_of procedure TK_UDUnit.GetGlobalDataFD

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDUnit\GetUDProgramItem
//********************************************** TK_UDUnit.GetUDProgramItem ***
// Get SPL Unit Program Item object (SPL Unit Procedure or Function) by given 
// name
//
//     Parameters
// AUDPIName - given Program Item name
// Result    - Returns IDB Object (TK_UDProgramItem) with compiled SPL program 
//             item
//
function TK_UDUnit.GetUDProgramItem( AUDPIName : string ) : TK_UDProgramItem;
begin
  Result := TK_UDProgramItem( DirChildByObjName(AUDPIName) );
  if (Result = nil) or (Result.CI <> K_UDProgramItemCI) then
    Result := nil;
end; // end_of TK_UDUnit.GetUDProgramItem
{*** end of TK_UDUnit ***}

{*** TK_UDProgramItem ***}

//********************************************** TK_UDProgramItem.Create ***
//
constructor TK_UDProgramItem.Create;
begin
  inherited Create;
  ImgInd := 76;
  ClassFlags := K_UDProgramItemCI;
end; // constructor TK_UDProgramItem.Create

//********************************************** TK_UDProgramItem.Destroy ***
//
destructor TK_UDProgramItem.Destroy;
var
  DType : TK_ExprExtType;
  i, DCount, DSize : Integer;
begin
//  ExprDataBufUsed := Length(ExprDataBuf);
{
N_s := ObjName;
if ObjName = 'PrepAllVarSets' then
N_s := ObjName;
}
  assert( ExprDataBufUsed <= Length(ExprDataBuf), 'Expression stack overflow' );
  while ExprDataBufUsed >= (SizeOf( Integer ) + SizeOf( DType )) do begin
//  while ExprDataBufUsed > 0 do begin
    Dec( ExprDataBufUsed, SizeOf( Integer ) );
    DCount := PInteger(@ExprDataBuf[ExprDataBufUsed])^;
    Dec( ExprDataBufUsed, SizeOf( DType ) );
    DType.All := PInt64(@ExprDataBuf[ExprDataBufUsed])^;
    DSize := K_GetExecTypeSize( DType.All );
  //*** Free Data Loop
    for i := 0 to DCount - 1 do begin
      Dec( ExprDataBufUsed, DSize );
      assert( ExprDataBufUsed >= 0, 'Expression stack underflow' );
      K_FreeSPLData( ExprDataBuf[ExprDataBufUsed], DType.All );
    end;
  end;

  inherited;
end; // destructor TK_UDProgramItem.destroy

//*************************************** TK_UDProgramItem.SaveToStrings ***
// save self to TStrings obj
//
procedure TK_UDProgramItem.SaveToStrings( Strings: TStrings; Mode: integer );
var
  Str: string;
begin
  inherited SaveToStrings( Strings, Mode );
  Str := Format(
  'Params=%d DBufSize=%d CodeSize=%d Operators=%d',
   [ParamsCount, Length(ExprDataBuf), Length(ExprCodeBuf), High(ExprDebInfo)] );
  Strings.Add( Str );

  Str := Format( 'Function=%d Unit="%s"',
    [StartParNum, SourceUnit.ObjAliase] );
  Strings.Add( Str );

  if Mode = 0 then Strings.Add( '' );

end; // procedure TK_UDProgramItem.SaveToStrings

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDProgramItem\AddFieldsToSBuf
//**************************************** TK_UDProgramItem.AddFieldsToSBuf ***
// Add values of SPL Program Item self fields to serial binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
procedure TK_UDProgramItem.AddFieldsToSBuf( ASBuf: TN_SerialBuf );
var
  WCount : Integer;
  DSize  : Integer;
  DType  : TK_ExprExtType;
  i : Integer;
  ExprDataBufPos : Integer;
begin
  inherited;

  ASBuf.AddRowString( SourceUnit.BuildRefPath );
  ASBuf.AddRowInt( ParamsCount );
  ASBuf.AddRowInt( StartParNum );
  ASBuf.AddRowInt( TextPos );
  WCount := Length(ExprDebInfo);
  ASBuf.AddRowInt( WCount );
  if WCount > 0 then
    ASBuf.AddRowSInts ( WCount * 3, SizeOf(Integer), @ExprDebInfo[0] );
  ASBuf.AddIntegerArray( ExprLabels );
  ASBuf.AddIntegerArray( ExprLabelsDI );

// Save Literals
//?? 20.10.2006  ExprDataBufUsed := Length(ExprDataBuf);
  ASBuf.AddRowInt( ExprDataBufUsed );
  ExprDataBufPos := ExprDataBufUsed;
  while ExprDataBufPos > 0 do begin
    Dec( ExprDataBufPos, SizeOf( Integer ) );
    WCount := PInteger(@ExprDataBuf[ExprDataBufPos])^;
    ASBuf.AddRowInt( WCount );

    Dec( ExprDataBufPos, SizeOf( DType ) );
    DType.All := PInt64(@ExprDataBuf[ExprDataBufPos])^;
    K_AddDataTypeToSBuf( DType, ASBuf );

    DSize := K_GetExecTypeSize( DType.All );
  //*** Free Data Loop
    for i := 0 to WCount - 1 do begin
      Dec( ExprDataBufPos, DSize );
      K_AddSPLDataToSBuf( ExprDataBuf[ExprDataBufPos], DType, ASBuf );
    end;
  end;

// Save ByteCode
  WCount := Length( ExprCodeBuf );
  ASBuf.AddRowInt( WCount );
  for i := 0 to WCount - 1 do
    with ExprCodeBuf[i], EType do begin
      ASBuf.AddRowInt( EFlags.All );
      if ( ((IFlags and K_ectRoutine) = 0)       or
           ((EType.IFlags and K_ectSpecial) = 0) or
           (Code = K_saAllocResult)              or
           (Code = K_saPutLastCreated) )
                     and
         ( DTCode > Ord(nptNoData) ) then
        ASBuf.AddRowString( FD.BuildRefPath() )
      else begin
        ASBuf.AddRowString( '' );
        ASBuf.AddRowInt( DTCode );
      end;
      if ((IFlags and K_ectDataDirect) <> 0) and
         (DTCode = Ord(nptUDRef)) then begin
        ASBuf.AddRowString( TN_UDBase(Code).BuildRefPath() )
      end else
        ASBuf.AddRowInt( Code );
    end;

end; // TK_UDProgramItem.AddFieldsToSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDProgramItem\GetFieldsFromSBuf
//************************************** TK_UDProgramItem.GetFieldsFromSBuf ***
// Get values of SPL Program Item self fields from serial binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
procedure TK_UDProgramItem.GetFieldsFromSBuf( ASBuf: TN_SerialBuf );
var
  WCount : Integer;
  WStr : string;
  DSize  : Integer;
  DType  : TK_ExprExtType;
  i : Integer;
  NCapacity : Integer;
  ExprDataBufPos : Integer;
begin
  inherited;
  ASBuf.GetRowString( WStr );
  TN_UDBase(SourceUnit) := K_UDCursorGetObj( WStr );
  ASBuf.GetRowInt( ParamsCount );
  ASBuf.GetRowInt( StartParNum );
  ASBuf.GetRowInt( TextPos );
  ASBuf.GetRowInt( WCount );
  SetLength( ExprDebInfo, WCount );
  if WCount > 0 then
    ASBuf.GetRowSInts ( WCount * 3, SizeOf(Integer), @ExprDebInfo[0] );
  ASBuf.GetIntegerArray( ExprLabels );
  ASBuf.GetIntegerArray( ExprLabelsDI );

// Load Literals
  ASBuf.GetRowInt( ExprDataBufUsed );
  SetLength( ExprDataBuf, ExprDataBufUsed );

  ExprDataBufPos := ExprDataBufUsed;
  while ExprDataBufPos > 0 do begin
    Dec( ExprDataBufPos, SizeOf( Integer ) );
    ASBuf.GetRowInt( WCount );
    PInteger(@ExprDataBuf[ExprDataBufPos])^ := WCount;

    Dec( ExprDataBufPos, SizeOf( DType ) );
    DType := K_GetDataTypeFromSBuf( ASBuf );
    PInt64(@ExprDataBuf[ExprDataBufPos])^ := DType.All;

    DSize := K_GetExecTypeSize( DType.All );
  //*** Free Data Loop
    for i := 0 to WCount - 1 do begin
      Dec( ExprDataBufPos, DSize );
      K_GetSPLDataFromSBuf( ExprDataBuf[ExprDataBufPos], DType, ASBuf );
    end;
  end;

// Save ByteCode
  ASBuf.GetRowInt( ExprCodeBufUsed );
  SetLength( ExprCodeBuf, ExprCodeBufUsed );
  for i := 0 to ExprCodeBufUsed - 1 do
    with ExprCodeBuf[i], EType do begin
      ASBuf.GetRowInt( EFlags.All );
      DTCode := K_GetTypeDTCodeFromSBuf( ASBuf );
      if ((IFlags and K_ectDataDirect) <> 0) and
         (DTCode = Ord(nptUDRef)) then begin
        ASBuf.GetRowString( WStr );
        TN_UDBase(Code) := K_UDCursorGetObj( WStr );
        if Code = 0 then begin // Add UNResolved Reference
          NCapacity := Length(K_PIURefPointers);
          if K_NewCapacity( K_PIURefCount + 1, NCapacity ) then begin
            SetLength(K_PIURefPointers, NCapacity);
            SetLength(K_PIURefPaths, NCapacity);
          end;
          K_PIURefPaths[K_PIURefCount] := WStr;
          K_PIURefPointers[K_PIURefCount] := @Code;
          Inc(K_PIURefCount);
        end;
      end else
        ASBuf.GetRowInt( Code );
    end;

end; // TK_UDProgramItem.GetFieldsFromSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDProgramItem\CopyFields
//********************************************* TK_UDProgramItem.CopyFields ***
// Copy SPL Program Item self fields values from given IDB object
//
//     Parameters
// ASrcObj - source Program Item object
//
procedure TK_UDProgramItem.CopyFields( ASrcObj: TN_UDBase );
begin
  if ASrcObj = nil then Exit; // a precaution
  inherited;

  with TK_UDProgramItem(ASrcObj) do begin
    Self.ExprCodeBuf := Copy( ExprCodeBuf, 0, ExprCodeBufUsed );
    Self.ExprCodeBufUsed := ExprCodeBufUsed;
    Self.ExprDataBuf := Copy( ExprDataBuf, 0, Length(ExprDataBuf) );
    Self.ExprDataBufUsed := ExprDataBufUsed;
    Self.ExprDebInfo := Copy( ExprDebInfo, 0, Length(ExprDebInfo) );
    Self.ExprDebInfoUsed := ExprDebInfoUsed;
    Self.ExprLabels   := ExprLabels;
    Self.ExprLabelsDI := ExprLabelsDI;
    Self.ParamsCount := ParamsCount;
    Self.SourceUnit  := SourceUnit;
    Self.StartParNum := StartParNum;
    Self.TextPos     := TextPos;

  end;
end; // end_of procedure TK_UDProgramItem.CopyFields

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDProgramItem\GetLDataDescr
//****************************************** TK_UDProgramItem.GetLDataDescr ***
// Get SPL routine local variables Data Type Description object
//
//     Parameters
// Result - Returns IDB Object (TK_UDFieldsDEscr) with SPL routine local 
//          variables Data Type Description
//
function TK_UDProgramItem.GetLDataDescr : TK_UDFieldsDescr;
begin
  if DirHigh >= 0 then begin
    Result := TK_UDFieldsDescr( DirChild( 0 ) );
    if (Result.ClassFlags and $FF) = K_UDFieldsDescrCI then Exit;
  end;
  Result := nil;
end; // end of function TK_UDProgramItem.GetLDataDescr


//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDProgramItem\SPLExecute
//********************************************* TK_UDProgramItem.SPLExecute ***
// Execute SPL routine bytecode
//
//     Parameters
// AGC - SPL interpreter Global Context Object
//
procedure TK_UDProgramItem.SPLExecute( AGC: TK_CSPLCont );
type Params = packed record
  R: Integer;
  DTypeR : TK_ExprExtType;
end;
var
  UDD : TK_UDFieldsDescr;
  LDataStackShift, LDataStackStart : Integer;

  NCapacity, i : Integer;
  ExprCode : TK_OneExprCode;
  PData  : Pointer;
  PPData : Pointer;
  IniStackLevel : Integer;
  SType : TK_ExprExtType;
  DSize : Integer;
  UDLastCreated, CLocalUDRoot : TN_UDBase;
  IfLocalUDRoot : Boolean;
  CStopAdr : Integer;
  DebInfoNum : Integer;
  CTextPos : Integer;
  CTextSize : Integer;

  procedure ShowUnitText( ModalShow : Boolean );
  var
    DebForm : TK_FormMVDeb;
  begin
    if ModalShow then
      DebForm := K_GetFormMVRun()
    else
      Exit;
//      DebForm := K_GetFormMVDeb();
    with DebForm do begin
//      if (Self.Owner.ClassFlags and $FF) <> K_UDUnitCI then Exit;
      //*** Clear Step Flags
      AGC.FlagSet := AGC.FlagSet and not K_gcDebFlags;
//      if GC.RFrame <> nil then
//        TN_Rast1Frame(GC.RFrame).ShowMainBuf;
//      RunState := ModalShow;
      ShowUnitMemo( SourceUnit, CTextPos, CTextSize );
    end;
//    Application.ProcessMessages;
  end;

begin
//*** Init Routine Local Data Context
  UDD := GetLDataDescr;
  if UDD.FDFieldsCount > ParamsCount then
    LDataStackStart := UDD.FDV[ParamsCount].FieldPos
  else
    LDataStackStart := UDD.FDRecSize;

  LDataStackShift := UDD.FDRecSize - LDataStackStart;
  with AGC do begin
    RTE.RTEFlag := 0;
//*** prepare Local Data Stack Space
    DSize := ExprStackLevel;
    Inc( ExprStackLevel, LDataStackShift );
    assert( ExprStackCapacity >= ExprStackLevel, 'Expression stack overflow' );
//*** Clear Local Data Space
    FillChar( ExprStack[DSize], LDataStackShift, 0 );
//!!    ExprLData := PChar( @ExprStack[DSize - LDataStackStart] );
    ExprLData := TN_BytesPtr( @ExprStack[DSize - LDataStackStart] );
    IniStackLevel := ExprStackLevel;
//*** Call Stack Info
    if Length(ExprCallStack) <= ExprCallStackLevel then begin
      NCapacity := Length(ExprCallStack);
      K_NewCapacity( ExprCallStackLevel + 1, NCapacity );
      SetLength( ExprCallStack, NCapacity );
    end;
    with ExprCallStack[ExprCallStackLevel] do begin
      ProgItem := Self;
      CallPos := -1;
    end;
    Inc(ExprCallStackLevel);
  end;
  IfLocalUDRoot := (AGC.LocalUDRoot = nil);
  CLocalUDRoot := AGC.LocalUDRoot;


  i := 0;
  CStopAdr := 0;
  DebInfoNum := 0;

//if ObjName = 'AAA' then
//ObjName := 'AAA';

  while i < ExprCodeBufUsed do begin //*** Main Loop
//****************************************
//*************  Debug Mode  *************
//****************************************
    if (CStopAdr = i) then begin  //*** Check Operator Start Code
      if (K_gcDebMode and AGC.FlagSet) <> 0 then begin
        if ((K_gcBreakExec  and AGC.FlagSet) <> 0) then  //*** Break Execution
          break
        else if ((K_gcStepOver  and AGC.FlagSet) <> 0) or
                ((K_gcTraceInto and AGC.FlagSet) <> 0) then begin  //*** show unit text
          CTextPos := ExprDebInfo[DebInfoNum].TextStart;
          CTextSize := ExprDebInfo[DebInfoNum].TextSize;
          ShowUnitText( true );
          if ((K_gcBreakExec  and AGC.FlagSet) <> 0) then  break;//*** Break Execution
        end;
      end;
      Inc( DebInfoNum );
      CStopAdr := ExprDebInfo[DebInfoNum].CodePos;
    end;
//****************************************
//*************  Do Command  *************
//****************************************
      try
        ExprCode := ExprCodeBuf[i];
        with ExprCode do begin
          SType := EType;
          SType.IFlags := 0;
          if (EType.IFlags and K_ectRoutine) <> 0 then begin //*** call function
            AGC.ExecFuncType := SType;
            if (EType.IFlags and K_ectSpecial) = 0  then begin //*** Build In Routine Call
              AGC.LocalUDRoot := CLocalUDRoot;
              if (Code = K_ExprNCallRoutineFuncCI) or
                 (Code = K_ExprNCallMethodFuncCI) then
                with AGC do
                  ExprCallStack[ExprCallStackLevel-1].CallPos := i;
              K_ExprNFuncRefs[Code](AGC);
              if (Code = K_ExprNCreateInstanceFuncCI) or
                 (Code = K_ExprNUDCreateFuncCI) then // Save Changed Current Local Arrays Root
                CLocalUDRoot := AGC.LocalUDRoot;
            end else begin                                     //*** Special Code Actions
              case Code of
                K_saAllocResult: begin               //*** Alloc Result in Stack
                  DSize := K_GetExecTypeSize( SType.All );
                  with AGC do begin//*** Clear Result Space
                    FillChar(ExprStack[ExprStackLevel], DSize, 0 );
                    PInt64( @ExprStack[ExprStackLevel + DSize] )^ := SType.All;
                    Inc( ExprStackLevel, DSize + SizeOf(SType) );
                  end;
                end;
                K_saIfGoto : begin //*** IfGoto
                  with AGC do begin
                    Dec( ExprStackLevel, SizeOf(Params) );
                    if PInteger(@ExprStack[ExprStackLevel])^ = 0 then begin
    //                  i := SType.DTCode;
    //                  Inc( DebInfoNum );
                      DebInfoNum := SType.DTCode;
                      i := ExprDebInfo[DebInfoNum].CodePos;
                      CStopAdr := i;
    //                  CStopAdr := ExprDebInfo[DebInfoNum+1].CodePos;
                      continue;
                    end;
                  end;
                end;
                K_saGoto : begin //*** Goto Code Address
                  DebInfoNum := SType.DTCode;
                  i := ExprDebInfo[DebInfoNum].CodePos;
                  CStopAdr := i;
                  continue;
                end;
                K_saLGoto : begin   //*** Goto Label Index
                  i := ExprLabels[SType.DTCode];
                  DebInfoNum := ExprLabelsDI[SType.DTCode];
                  CStopAdr := ExprDebInfo[DebInfoNum].CodePos;
                  continue;
                end;
                K_saDeb : begin    //*** Deb
                  with AGC do begin
                    Dec( ExprStackLevel, SizeOf(Params) );
                    FlagSet := (FlagSet and not K_gcDebFlags) or
                    (PInteger(@ExprStack[ExprStackLevel])^  and K_gcDebFlags);
                    if ((FlagSet and K_gcDebMode)  <> 0) and
                       ((FlagSet and K_gcRunFlags) <> 0) and
                       (K_DebugGC = nil) then
                      K_DebugGC := AGC;
//                      K_DebugGC := GC.AAddRef;
                  end;
                end;
                K_saExit : break;  //*** Exit
                K_saPutLastCreated : begin //*** Put Last Created Instance to Stack
                  UDLastCreated := CLocalUDRoot.DirChild(CLocalUDRoot.DirHigh);
                  AGC.PutDataToExprStack( UDLastCreated, SType.All );
                end;

              end;
            end;
          end else begin
            if (EType.IFlags and K_ectDataDirect) <> 0 then begin
              PPData := @Code;
            end else begin
              if (EType.IFlags and K_ectDataShift) = 0 then begin
                             //*** Literal and External data buffer
                PData := Pointer(Code);
              end else begin //*** Parameter, Local Variable or Literal
                if (EType.IFlags and K_ectDataLiteral) = 0 then
                  PData := ExprLData + Code
                else begin
//!!                  PData := PChar(@ExprDataBuf[0]) + Code;
                  PData := TN_BytesPtr(@ExprDataBuf[0]) + Code;
{ 27-04-2006 prevent ByteCode Correction for Binary Saving Compile results
                  //*** correct Code Buffer to Data Pointer
                  with ExprCodeBuf[i] do begin
                    Code := Integer(PData);
                    EType.IFlags := EType.IFlags xor K_ectDataShift;
                  end;
}
                end;
              end;

              if (EType.IFlags and K_ectVarPtr) <> 0 then //*** put Var Pointer to Stack
                PPData := @PData
              else
                PPData := PData;
            end;
            AGC.PutDataToExprStack( PPData^, SType.All );
          end;
        end;
        Inc(i);
      except
//        On E: TK_SPLRunTimeError do
        On E: Exception do
          with AGC, RTE do begin
            if RTEFlag = 0 then begin
              RTEMessage := E.Message + ' >> in '+SourceUnit.ObjName + '.'+ ObjName;
              RTEUnit := SourceUnit;
              RTERoutineName := ObjName;
              RTEOpNumber := DebInfoNum - 1;
              RTETextPos := ExprDebInfo[RTEOpNumber].TextStart; // RunTime Exception Program Text Position
              RTETextSize := ExprDebInfo[RTEOpNumber].TextSize; // RunTime Exception Program Text Size
            end;
            RTEFlag := 1;
            while ExprStackLevel > IniStackLevel do
              K_ExprNClearStack(AGC);
         end;
      end;
      if AGC.RTE.RTEFlag <> 0 then break;
    end; //*** end of Main Loop

//***  Routine Exit Code
  with AGC do begin
    assert( ExprStackLevel = IniStackLevel, 'Expression stack error' );
    if (K_gcDebMode and FlagSet) <> 0 then begin
      if ExprCallStackLevel = 1 then
        FlagSet := FlagSet and not K_gcBreakExec;
      if ((K_gcRunToReturn and FlagSet) <> 0 ) then
        FlagSet := (FlagSet and not K_gcRunFlags) or K_gcDebMode or K_gcStepOver
      else {if ((K_gcBreakExec  and GC.FlagSet) = 0) and
              ( ((K_gcStepOver  and GC.FlagSet) <> 0) or
                ((K_gcTraceInto and GC.FlagSet) <> 0) ) then }
           if Length(ExprDebInfo) > 0 then begin  //*** Show Last
        CTextPos := ExprDebInfo[High(ExprDebInfo)].TextStart;
        CTextSize := ExprDebInfo[High(ExprDebInfo)].TextSize;
        ShowUnitText(   (ExprCallStackLevel <> 1)             and
                        ((K_gcBreakExec   and FlagSet) = 0) and
                        ( ((K_gcStepOver  and FlagSet) <> 0) or
                          ((K_gcTraceInto and FlagSet) <> 0) )  );
      end;
    end;
    Dec(ExprCallStackLevel);
//***  Free Params and Local Data Stack Space
    Dec( ExprStackLevel, UDD.FDRecSize );
// Err   if UDD.FieldsCount > 0 then // Correct Stack Pos in Result Case
// Err     Inc( ExprStackLevel, UDD.V[StartParNum].FieldPos );
    if StartParNum = 1 then // Correct Stack Pos in Result Case
      Inc( ExprStackLevel, UDD.FDV[0].FieldSize + SizeOf(TK_ExprExtType));
    UDD.FreeData( ExprLData^, StartParNum );
    if IfLocalUDRoot then begin
      if CLocalUDRoot <> nil then
        CLocalUDRoot.UDDelete;
      AGC.LocalUDRoot := nil;
    end;
  end;
end; // procedure TK_UDProgramItem.SPLExecute

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDProgramItem\SPLProgExecute
//***************************************** TK_UDProgramItem.SPLProgExecute ***
// Execute SPL Main (Root) Program
//
//     Parameters
// AGC - SPL interpreter Global Context Object (default value is NIL)
//
// Initialize SPL interpreter stack and execute root SPL procedure without 
// parameters
//
procedure TK_UDProgramItem.SPLProgExecute ( AGC: TK_CSPLCont = nil );
begin
  if Self = nil then begin
   K_RTEInfo.RTEFlag := 1;
   K_RTEInfo.RTEMessage := 'ProgramItem is not assigned';
   K_RTEInfo.RTEUnit := nil;
   Exit;
  end;
//  assert( Self <> nil, 'ProgramItem is not assigned' );
  AGC := K_PrepSPLRunGCont( AGC );
  with AGC do begin
    ExprStackLevel := 0;
    ExprCallStackLevel := 0;
    LocalUDRoot := nil;
  end;
  SPLExecute( AGC );
  if AGC.RTE.RTEFlag <> 0 then
    K_RTEInfo := AGC.RTE
  else
    K_RTEInfo.RTEFlag := 0;
  K_FreeSPLRunGCont( AGC );
end; // procedure TK_UDProgramItem.SPLProgExecute

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDProgramItem\ReserveResultSpaceInSPLStack
//*************************** TK_UDProgramItem.ReserveResultSpaceInSPLStack ***
// Reserve Space for SPL function Result
//
//     Parameters
// AGC - SPL interpreter Global Context Object (default value is NIL)
//
// Reserve needed space in SPL interpreter stack for SPL function Result. Do not
// use this method directly, it is called automatically while SPL function call 
// is prepared.
//
procedure TK_UDProgramItem.ReserveResultSpaceInSPLStack( AGC : TK_CSPLCont );
var
  DSize : Integer;
begin
  ResultType := K_GetRoutineType( GetLDataDescr );
  if ResultType.DTCode = -1 then Exit;
//*** reserved space
  DSize := K_GetExecTypeSize( ResultType.All );
  with AGC do begin//*** Clear Result Space
    FillChar(ExprStack[ExprStackLevel], DSize, 0 );
    PInt64( @ExprStack[ExprStackLevel + DSize] )^ := ResultType.All;
    Inc( ExprStackLevel, DSize + SizeOf(ResultType) );
  end;
end; // end of function TK_UDProgramItem.ReserveResultSpaceInSPLStack

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDProgramItem\PutParamsArrayToSPLStack
//******************************* TK_UDProgramItem.PutParamsArrayToSPLStack ***
// Put given Parameters to SPL interpreter stack
//
//     Parameters
// AParams - array of pointers to Pascal data - future SPL routine parameters
// AGC     - SPL interpreter Global Context Object (default value is NIL)
//
// Put given Parameters to SPL interpreter stack for future SPL routine call. Do
// not use this method directly, it is called automatically while SPL function 
// call is prepared.
//
procedure TK_UDProgramItem.PutParamsArrayToSPLStack( AParams : array of const; AGC : TK_CSPLCont );
var
  ParType : TK_ExprExtType;
  i : Integer;
  BufStr : string;
  BufDouble : Double;
  PData : Pointer;
label Error;
begin
//*** Add params
  PData := nil;
  for i := 0 to High( AParams ) do
  with AParams[i] do begin
    case VType of
      vtString : begin
        ParType.All := Ord( nptString );
//      BufStr := string( PShortString(VString)^ );
        BufStr := N_AnsiToString( PShortString(VString)^ );
        PData := @BufStr;
      end;
      vtAnsiString : begin
        ParType.All := Ord( nptString );
        if SizeOf(Char) = 2 then begin
//          BufStr := string( PAnsiString(@VAnsiString)^ );
          BufStr := N_AnsiToString( PAnsiString(@VAnsiString)^ );
          PData := @BufStr;
        end else
          PData := @VAnsiString;
      end;
      vtInteger : begin
        ParType.All := Ord( nptInt );
        PData := @VInteger;
      end;
      vtChar : begin
        ParType.All := Ord( nptByte );
        if SizeOf(Char) = 2 then
          ParType.All := Ord( nptUInt2 );
        PData := @VChar;
      end;
      vtWideChar : begin
        ParType.All := Ord( nptUInt2 );
        PData := @VWideChar;
      end;
      vtPChar: begin
        ParType.All := Ord( nptByte );
        if SizeOf(Char) = 2 then
          ParType.All := Ord( nptUInt2 );
        ParType.D.TFlags := K_ffPointer;
        PData := Pointer(VPChar);
      end;
      vtObject: begin
        if VObject is TN_UDBase then
          ParType.All := Ord( nptUDRef )
        else if VObject is TK_RArray then begin
          ParType := TK_RArray(VObject).ArrayType;
        end else
          goto Error;
        PData := @VObject;
      end;
      vtBoolean : begin
        if VBoolean then
          VInteger := Integer($FFFFFFFF)
        else
          VInteger := 0;
        ParType.All := Ord( nptHex );
        PData := @VInteger;
      end;
      vtExtended : begin
        BufDouble := VExtended^;
        ParType.All := Ord( nptDouble );
        PData := @BufDouble;
      end;
      vtInt64 : begin
        ParType.All := Ord( nptInt64 );
        PData := Pointer(VInt64);
      end;
      vtPointer : begin
        ParType.All := Ord( nptNotDef );
        ParType.D.TFlags := K_ffPointer;
        PData := @VPointer;
      end;

    else
Error:
      assert( false, 'Wrong SPL routine parameter' );
    end;
    AGC.PutDataToExprStack( PData^, ParType.All );
  end; // end of with AParams[i]

end; // end of procedure TK_UDProgramItem.PutParamsArrayToSPLStack

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDProgramItem\CallSPLRoutine
//***************************************** TK_UDProgramItem.CallSPLRoutine ***
// Call SPL routine
//
//     Parameters
// AParams - array of pointers to Pascal data - future SPL routine parameters
// AGC     - SPL interpreter Global Context Object (default value is NIL)
// Result  - Returns TRUE if Self (SPL routine object) is assigned.
//
// Access to SPL function Result is not possible in this method. To get SPL 
// function Result use CallSPLFunction method instead.
//
function TK_UDProgramItem.CallSPLRoutine( AParams : array of const; AGC : TK_CSPLCont = nil  ) : Boolean;
begin
//*** Add params
  Result := false;
  if Self = nil then Exit;
  Result := true;
  AGC := K_PrepSPLRunGCont( AGC );
  if AGC.SPLGCDumpWatch = nil then
    AGC.SPLGCDumpWatch := K_InfoWatch;
  ReserveResultSpaceInSPLStack( AGC );
  PutParamsArrayToSPLStack( AParams, AGC );
//*** Execute SPL Routine
  SPLExecute( AGC );
  if AGC.RTE.RTEFlag <> 0 then
    K_RTEInfo := AGC.RTE
  else
    K_RTEInfo.RTEFlag := 0;
  K_FreeSPLRunGCont( AGC );
end; // end of function TK_UDProgramItem.CallSPLRoutine

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDProgramItem\CallSPLFunction
//**************************************** TK_UDProgramItem.CallSPLFunction ***
// Call SPL function
//
//     Parameters
// AParams    - array of pointers to Pascal data - future SPL routine parameters
// APResult   - given pointer for SPL function Result Data saving after it's 
//              call
// ARTypeCode - given SPL function Result Type Code for Result Data saving
// AGC        - SPL interpreter Global Context Object (default value is NIL)
// Result     - Returns TRUE if Self (SPL routine object) is assigned.
//
// If given SPL function Result Type Code is not equal to SPL function "real" 
// Result Type Code, then no Result Data will be moved to memory given by 
// APResult.
//
function TK_UDProgramItem.CallSPLFunction( AParams : array of const; APResult : Pointer = nil;
                                           ARTypeCode : Int64 = 0; AGC : TK_CSPLCont = nil  ) : Boolean;
var
  ResultTypeError : Boolean;
begin
  Result := false;
  if Self = nil then Exit;
  AGC := K_PrepSPLRunGCont( AGC );
  Result := CallSPLRoutine( AParams, AGC );
  ResultTypeError := (ARTypeCode <> 0) and
                     (((ARTypeCode and ResultType.All) and K_ffCompareTypesMask) <> 0);
  if ( ResultTypeError or
       (APResult = nil) )   and
     (ResultType.DTCode <> -1) then begin
  // Free Result
    AGC.GetPointerToExprStackData( APResult, ARTypeCode );
    K_FreeSPLData( APResult^, ARTypeCode );
  end;

  if APResult <> nil  then begin
    assert( not ResultTypeError,
            'SPL function '+ ObjName + ' Result type failure ' + K_GetExecTypeName(ARTypeCode) );
    if ResultType.DTCode <> -1 then
      AGC.GetDataFromExprStack( APResult^, ResultType.All );
  end;
  K_FreeSPLRunGCont( AGC );
end; // end of function TK_UDProgramItem.CallSPLFunction

{*** end of TK_UDProgramItem ***}

{*** TK_TreeViewSelect ***}

//******************************************** TK_TreeViewSelect.Create
//
constructor TK_TreeViewSelect.Create;
begin
  inherited;
  RootNode := TN_UDBase.Create;
  SFilter := TK_UDFilter.Create;
  VFlags := K_fvTreeViewSkipLines or K_fvTreeViewSkipSeparators;
  ItemsDataCount := 1;
end; // end of TK_TreeViewSelect.Create

//******************************************** TK_TreeViewSelect.Destroy
//
destructor TK_TreeViewSelect.Destroy;
begin
  RootNode.UDDelete;
  SFilter.Free;
  inherited;
end; // end of TK_TreeViewSelect.Destroy

//******************************************** TK_TreeViewSelect.Clear
//
procedure TK_TreeViewSelect.Clear;
begin
  RootNode.ClearChilds();
  SFilter.FreeItems;
  ItemsCount := 0;
end; // end of TK_TreeViewSelect.Clear

//******************************************** TK_TreeViewSelect.AddItem
//
procedure TK_TreeViewSelect.AddItem( PData : Pointer;
                        const ID, Caption, Hint: string; IconInd: Integer = 0 );
var
  i, ItemSize : Integer;
begin
  with TK_UDRArray(RootNode.AddOneChild( K_CreateUDByRTypeCode( ItemsDataType.All ) )) do begin
    ObjName := ID;
    ObjAliase := Caption;
    ObjInfo := Hint;
    ImgInd := IconInd;
    ItemSize := K_GetExecTypeSize( ItemsDataType.All );
    if PData <> nil then
      for i := 0 to ItemsDataCount - 1 do begin
        K_MoveSPLData( PData^, R.P(i)^, R.ElemType );
//!!        Inc( PChar(PData), ItemSize );
        Inc( TN_BytesPtr(PData), ItemSize );
      end;
  end;
  Inc(ItemsCount);
end; // end of TK_TreeViewSelect.AddItem

//******************************************** TK_TreeViewSelect.GetSelectedPData
//
function TK_TreeViewSelect.GetSelectedPData: Pointer;
begin
  Result := nil;
  if (SelNode = nil) or not (SelNode is TK_UDRArray) then Exit;
  with TK_UDRArray(SelNode).R do begin
    Result := P;
    ItemsDataCount := Alength;
  end;
end; // end of TK_TreeViewSelect.GetSelectedPData

//******************************************** TK_TreeViewSelect.TVSLoadFromFile
//
procedure TK_TreeViewSelect.TVSLoadFromFile( AFileName: string );
begin
  RootNode.ClearChilds();
  RootNode.LoadTreeFromAnyFile( K_ExpandFileName(AFileName) );
  ItemsCount := 0;
end; // end of TK_TreeViewSelect.TVSLoadFromFile

//******************************************** TK_TreeViewSelect.SelectItem
//
function TK_TreeViewSelect.SelectItem : string;
begin
  Result := '';
  SelNode := nil;
  if K_SelectUDNode( SelNode, RootNode, SFilter.UDFTest, SCaption, true, MultiSelect, VFlags  ) then begin
    Result := K_SelectedPath;
  end;
end; // end of TK_TreeViewSelect.SelectItem

//******************************************** TK_TreeViewSelect.SetItemsDataType
//
procedure TK_TreeViewSelect.SetItemsDataType( DTypeCodeAll : Int64; AItemsDataCount : Integer = 1 );
begin
  ItemsDataType.All := DTypeCodeAll;
  SFilter.AddItem( TK_UDFilterExtType.Create(ItemsDataType.All) );
  ItemsDataCount := AItemsDataCount;
end; // end of TK_TreeViewSelect.SetItemsDataType

//******************************************** TK_TreeViewSelect.ScanUDNode
//
function TK_TreeViewSelect.ScanUDNode( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
begin
  Result := K_tucOK;
  with DE do begin
    Parent := UDParent;
    Child  := UDChild;
    DirIndex := ChildInd;
  end;
  if not SFilter.UDFTest( DE ) then Exit;
  SelNode := UDChild;
  Inc( ItemsCount );
end; // end of TK_TreeViewSelect.ScanUDNode

//******************************************** TK_TreeViewSelect.GetItemsCount
//
function TK_TreeViewSelect.GetItemsCount : Integer;
begin
  FillChar( DE, SizeOf(TN_DirEntryPar), 0 );
  if ItemsCount <= 0 then begin
    ItemsCount := 0;
    SelNode := nil;
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsOwnerChildsOnlyScan];
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan];
    RootNode.ScanSubTree( ScanUDNode );
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsOwnerChildsOnlyScan];
  end;
  Result := ItemsCount;
end; // end of TK_TreeViewSelect.GetItemsCount

{*** end of TK_TreeViewSelect ***}

{*** TK_UDFilterExtType ***}

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFilterExtType\Create
//*********************************************** TK_UDFilterExtType.Create ***
// IDB objects Filter Item TK_UDFilterExtType Special Class Constructor
//
//     Parameters
// ADTypeAll - Records Array Complex Type Code
// AExprCode - logic operation which would be used by TK_UDFilter object to 
//             combine this Filter Item testing result with other Filter Items 
//             in general testing EXPRESSION
//
constructor TK_UDFilterExtType.Create( ADTypeAll: Int64;
              AExprCode: TK_UDFilterItemExprCode );
begin
  DTypeAll := ADTypeAll;
  ExprCode := AExprCode;
end; // end of TK_UDFilterExtType.Create

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFilterExtType\UDFITest
//********************************************* TK_UDFilterExtType.UDFITest ***
// IDB objects Filter Item testing function
//
//     Parameters
// DE     - IDB folder entry attributes
// Result - Returns TRUE if testing IDB object is satisfied Filter Item 
//          condition
//
function TK_UDFilterExtType.UDFITest(const DE: TN_DirEntryPar): Boolean;
begin
  Result := K_IsUDRArray(DE.Child) and
            (((TK_UDRArray(DE.Child).R.GetComplexType.All xor DTypeAll) and K_ffCompareTypesMask) = 0);
end; // end of TK_UDFilterExtType.UDFITest
{*** end of TK_UDFilterExtType ***}


//****************** Global procedures **********************

//************************************************ K_GetRAListRAType
//
function K_GetRAListRAType() : TK_ExprExtType;
begin
  if K_RAListRAType.All = 0 then
    K_RAListRAType := K_GetExecTypeCodeSafe( 'TK_RAList' );
  Result := K_RAListRAType;
end; //*** end of K_GetRAListRAType

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_IsUDRArray
//************************************************************ K_IsUDRArray ***
// Check if IDB object is Records Array Object container
//
//     Parameters
// AUDB   - testing IDB object
// Result - Returns TRUE if testing IDB object is Records Array Object container
//
function  K_IsUDRArray( AUDB : TN_UDBase ) : Boolean;
begin
  Result := (AUDB <> nil) and ((AUDB.ClassFlags and K_RArrayObjBit) <> 0);
end; //*** end of K_IsUDRArray

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetSLSRootPAttrs
//****************************************************** K_GetSLSRootPAttrs ***
// Get Pointer to Separately Loaded Subtree Root IDB object Attributes
//
//     Parameters
// AUDSLSRoot - testing IDB object
// Result     - Returns Pointer to Separately Loaded Subtree Root Attributes, or
//              NIL if given IDB object is not Records Array or if Records Array
//              Elements type is not proper.
//
function K_GetSLSRootPAttrs( AUDSLSRoot : TN_UDBase ) : TK_PSLSRoot;
begin
//*** Check for Uses Sections in Current loaded SLSRoots and Load Unloaded Sections
  if K_SLSRootTypeCode = 0 then K_SLSRootTypeCode := K_GetTypeCodeSafe( 'TK_SLSRoot' ).DTCode;
  Result := nil;
  with TK_UDRArray(AUDSLSRoot) do
  if K_IsUDRArray(AUDSLSRoot)  and                // Is UDRArray
     (R.ElemType.DTCode = K_SLSRootTypeCode) then // Is Section Root Type
    Result := TK_PSLSRoot(R.P);

end; // end_of procedure TN_UDBase.SLSRAddUses

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_PrepSPLRunGCont
//******************************************************* K_PrepSPLRunGCont ***
// Prepare SPL Run Context Object
//
//     Parameters
// AGC    - initial SPL Run Context Object (if =NIL then special always ready 
//          debug context will be returnd)
// Result - Returns ready to use SPL Run Context Object.
//
function K_PrepSPLRunGCont( AGC  : TK_CSPLCont = nil ) : TK_CSPLCont;
begin
  Result := AGC;
  if Result = nil then
    Result := K_DebugGC;
  Result := Result.AAddRef;
end; //*** end of K_PrepSPLRunGCont ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_FreeSPLRunGCont
//******************************************************* K_FreeSPLRunGCont ***
// Free earlier prepared SPL Run Context Object
//
//     Parameters
// AGC - given SPL Run Context Object, if earlier prepared context UseCounter is
//       0 then SPL Run Context Object will be freed and AGC variable will be 
//       set to 0
//
procedure K_FreeSPLRunGCont( var AGC : TK_CSPLCont );
begin
//  if GC = nil then Exit;
  if not AGC.ARelease then AGC := nil;
end; //*** end of K_FreeSPLRunGCont ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetElemTypeName
//******************************************************* K_GetElemTypeName ***
// Get SPL Array Element Type Name by given SPL Array Type Code
//
//     Parameters
// ATypeCode - SPL Array Type Code given as Int64 value
// Result    - Returns SPL Array Element Type Name.
//
function  K_GetElemTypeName( ATypeCode : Int64 ) : string;
begin
  TK_ExprExtType(ATypeCode).D.TFlags :=
    TK_ExprExtType(ATypeCode).D.TFlags and not K_ffArray;
  Result := K_GetExecTypeName( ATypeCode );
end; //*** end of K_GetElemTypeName ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetExecTypeName
//******************************************************* K_GetExecTypeName ***
// Get SPL Type Name by given SPL Type Full Code including flags
//
//     Parameters
// ATypeCode - SPL Type Full Code given as Int64 value
// Result    - Returns SPL Type Name including Pointer, Array and VArray SPL 
//             type
// text      - properties.
//
function  K_GetExecTypeName( ATypeCode : Int64 ) : string;
begin
  Result := '';
  with TK_ExprExtType(ATypeCode) do begin
    if ( D.TFlags and K_ffPointerMask ) <> 0 then
      Result := K_sccVarAdrTypePref
    else
      Result := '';
    if ( D.TFlags and K_ffArray ) <> 0 then
      Result := Result + K_sccArray+ ' '
    else if ( D.TFlags and K_ffVArray ) <> 0 then
      Result := Result + K_sccVArray+ ' ';
//    if DTCode <= Integer(High( K_SPLTypeNames )) then
    if DTCode <= Ord(nptNoData) then
      Result := Result + K_SPLTypeNames[DTCode]
    else
      if (TN_UDBase(DTCode).ClassFlags and $FF) = K_UDFieldsDescrCI then
        Result := Result + TK_UDFieldsDescr(DTCode).ObjName;
  end;
end; //*** end of K_GetExecTypeName ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetSTypeAliase
//******************************************************** K_GetSTypeAliase ***
// Get SPL Type Aliase by given SPL Type Main Code without flags
//
//     Parameters
// ATypeCode - SPL Type Main Code given as Integer value (without flags)
// Result    - Returns SPL Type Aliase (Type Aliase is needed for  Low Level 
//             User Interface)
//
function  K_GetSTypeAliase( ATypeCode : Integer ) : string;
begin
  if ATypeCode <= Ord(nptNoData) then
    Result := K_SPLTypeAliases[ATypeCode]
  else
    if (TN_UDBase(ATypeCode).ClassFlags and $FF) = K_UDFieldsDescrCI then
      Result := TK_UDFieldsDescr(ATypeCode).GetUName;
end; //*** end of K_GetSTypeAliase

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetExecTypeSize
//******************************************************* K_GetExecTypeSize ***
// Get SPL Data Size by given SPL Type Full Code including flags
//
//     Parameters
// ATypeCode - SPL Type Full Code given as Int64 value
// Result    - Returns SPL Data Size in bytes (=-1 if wrong type code).
//
function  K_GetExecTypeSize( ATypeCode : Int64 ) : Integer;
begin
  Result := -1;

  with TK_ExprExtType(ATypeCode) do begin
//if DTCode < 0 then
//  N_i := DTCode;
    if DTCode < 0 then Exit;
    if ( D.TFlags and (K_ffFlagsMask or K_ffArray or K_ffVArray) ) <> 0 then
      Result := SizeOf(Pointer)
    else if DTCode <= Integer(High( K_DataElementSize )) then begin
      Result := K_DataElementSize[DTCode]
    end else
      if (TN_UDBase(DTCode).ClassFlags and $FF) = K_UDFieldsDescrCI then
        Result := TK_UDFieldsDescr(DTCode).FDRecSize;
  end;
end; //*** end of K_GetExecTypeSize ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetPVRArray
//*********************************************************** K_GetPVRArray ***
// Get pointer to Records Array  by given SPL Virtual Array
//
//     Parameters
// AData  - given SPL Virtual Array
// Result - Returns pointer to Records Array Object (TK_RArray).
//
// Virtual Array may be directly Records Array or IDB Object - Records Array 
// container.
//
// Result value could be NIL if AData is NIL, or if AData is IDB Object, but not
// Records Array container.
//
function  K_GetPVRArray(  var AData  ) : TK_PRArray;
begin
  Result := TK_PRArray(@AData);
  if (TK_RArray(AData) = nil) or
     (TObject(AData) is TK_RArray) then Exit;
  if K_IsUDRArray(TN_UDBase(AData)) then
    Result := @TK_UDRArray(AData).R
  else
    Result := nil;
end; //*** end of K_GetPVRArray

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_PutVRArray
//************************************************************ K_PutVRArray ***
// Put new Records Array to given SPL Virtual Array
//
//     Parameters
// AData   - given SPL Virtual Array
// ARArray - Records Array for replacing in Virtual Array
//
// If given Virtual Array is Records Array then given Records Array is bound to 
// given field and accordingly change its UseCounter. If Virtual Array is IDB 
// Object then copy of Records Array is bound to given IDB Object Records Array
//
procedure K_PutVRArray(  var AData : TObject; ARArray : TK_RArray );
var
  PRArray : TK_PRArray;
begin
  PRArray := K_GetPVRArray(AData);
  if PRArray = Pointer(@AData) then begin   // Link To Direct RArray
    TK_RArray(AData).ARelease;
    TK_RArray(AData) := ARArray.AAddRef;
  end else                                 // Copy To UDRArray.R
    K_RFreeAndCopy( PRArray^, ARArray, [K_mdfCountUDRef] );
end; //*** end of K_PutVRArray

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_SetVArrayField
//******************************************************** K_SetVArrayField ***
// Set new value to given SPL Virtual Array
//
//     Parameters
// AVArrayField    - given Virtual Array field
// AVArrayNValue   - new Virtual Array value
// ASetVArrayFlags - set of bit flags that controls Virtual Array data replacing
//                   (freeing old value and marking new value as used)
// Result          - Returns TRUE if new Value is realy bound to given Virtual 
//                   Array field
//
function K_SetVArrayField( var AVArrayField : TObject; AVArrayNValue : TObject;
                           ASetVArrayFlags : TK_SetVArrayFlags = [K_svrCountUDRef] ) : Boolean;
begin
  Result := (AVArrayField <> AVArrayNValue);
  if not Result then Exit;

  //***** Clear OldVArray
  if AVArrayField is TK_RArray then
    TK_RArray(AVArrayField).ARelease
  else if AVArrayField is TN_UDBase then begin
    if K_svrCountUDRef  in ASetVArrayFlags then TN_UDBase(AVArrayField).UDDelete;
  end else
    assert( AVArrayField = nil, 'Bad OldVArray!' );

  //***** Set NewVArray
  AVArrayField := AVArrayNValue;
  if AVArrayNValue = nil then Exit;

  if AVArrayNValue is TK_RArray then begin
    if K_svrAddRARef in ASetVArrayFlags then Inc( TK_RArray(AVArrayNValue).RefCount );
  end else if AVArrayNValue is TN_UDBase then begin
    if K_svrCountUDRef  in ASetVArrayFlags then Inc( TN_UDBase(AVArrayNValue).RefCounter );
  end else
    assert( false, 'Bad NewVArray!' );

end; //*** end of K_SetVArrayField

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_VArrayCondRACopy
//****************************************************** K_VArrayCondRACopy ***
// Replace given SPL Virtual Array to its Records Array copy
//
//     Parameters
// APVRA  - pointer to SPL Virtual Array
// Result - Returns Virtual Array resulting Records Array
//
// If given SPL Virtual Array is IDB Object then Virtual Array resulting value 
// will be copy of IDB Object Records Array. If given Virtual Array is Records 
// Array and it is used only in this field (UseCounter <= 0) then Virtual Array 
// resulting value will be source Records Array. But if it is used in some other
// fileds (UseCounter > 0) then resulting value will be source Records Array 
// copy.
//
function K_VArrayCondRACopy( APVRA : PObject ) : TK_RArray;
var
  MDFlags : TK_MoveDataFlags;
  CountUDRef : Boolean;
  SetVArrayFlags : TK_SetVArrayFlags;
begin
  Result := K_GetPVRArray( APVRA^ )^;
  if (Result <> APVRA^) or (Result.ARefCounter > 0) then begin
  // Create Relation Copy
    with Result do
      CountUDRef := (FEType.D.CFlags and K_ccCountUDRef) <> 0;
    MDFlags := [K_mdfCopyRArray];
    SetVArrayFlags := [];
    if CountUDRef then begin
      MDFlags := MDFlags + [K_mdfCountUDRef];
      SetVArrayFlags := [K_svrCountUDRef];
    end;
    Result := K_RCopy( Result, MDFlags );
    K_SetVArrayField( APVRA^, Result, SetVArrayFlags );
  end;
end; //*** end of K_SetVArrayField
{
//********************************************** K_PutVUDRArray ***
//
procedure K_PutVUDRArray(  var Data : TObject; UDRArray : TK_UDRArray; CountUDRef : Boolean );
var
  PRArray : TK_PRArray;
begin
  PRArray := K_GetPVRArray(Data);
  if PRArray = Pointer(@Data) then begin   // Link To Direct RArray
    TK_RArray(Data).ARelease;
    TK_RArray(Data) := nil;
  end;
  K_SetUDRefField( TN_UDBase(Data), UDRArray, CountUDRef );
end; //*** end of K_PutVUDRArray

//********************************************** K_PutVRAData
//
procedure K_PutVRAData(  var Data : TObject; NData : TObject; CountUDRef : Boolean );
begin
  if (NData = nil) or (NData is TK_RArray) then
    K_PutVRArray( Data, TK_RArray(NData) )
  else
    K_PutVUDRArray( Data, TK_UDRArray(NData), CountUDRef );
end; //*** end of K_PutVRAData
}

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetRArrayTypes
//******************************************************** K_GetRArrayTypes ***
// Get Records Array Attributes and Elements Type Codes by given Complex Type 
// Code
//
//     Parameters
// ACType    - Records Array Complex Type Code
// AElemType - resulting Records Array Elements Type Code
// Result    - Returns Records Array Attributes Type Code
//
// Records Array object is data container which can contain nonrecurring and 
// recurring parts. Nonrecurring part is single record which type is differ from
// recurring array element records.
//
function K_GetRArrayTypes( ACType: TK_ExprExtType;
                           out AElemType : TK_ExprExtType ) : TK_ExprExtType;
begin
//
  with ACType do
    if (ACType.DTCode > Ord(nptNoData))   and
       (ACType.FD.FDObjType = K_fdtTypeDef) and
       (ACType.FD.FDFieldsCount = 2) then begin
      with ACType.FD.GetFieldDescrByInd( 1 )^ do AElemType := DataType;
      with ACType.FD.GetFieldDescrByInd( 0 )^ do Result := DataType;
    end else begin
      AElemType := ACType;
      Result.All := Ord(nptNotDef);
    end;
end; // end of function K_GetRArrayTypes

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetExecDataTypeCode
//*************************************************** K_GetExecDataTypeCode ***
// Get SPL Data Type Code by given Type Code and real Data
//
//     Parameters
// AData     - real Data
// ATypeCode - Data Type Code
// Result    - Returns Data Type Code exactly defined by real Data.
//
// Type Code is defined more exactly by real Data if it is Virtual Records 
// Array.
//
function  K_GetExecDataTypeCode(  const AData; ATypeCode : TK_ExprExtType  ) : TK_ExprExtType;
begin
  Result := ATypeCode;
  with ATypeCode do begin
    if D.TFlags = K_ffVArray then begin
      if TN_UDBase(AData) <> nil then begin
        if (TObject(AData) is TN_UDBase) then begin
//          assert( (TObject(Data) is TK_UDRArray) or
//                  (TObject(Data) is TK_UDRef) , 'Wrong Var Array UDReference:'+TN_UDBase(Data).GetUName );
//          assert( TObject(Data) is TK_UDRArray, 'Wrong Var Array UDReference:'+TN_UDBase(Data).GetUName );
          Result.D.TFlags := 0;
          Result.DTCode := ord(nptUDRef);
        end else begin
          assert( TObject(AData) is TK_RArray, 'Wrong Var Array Object' );
          Result := TK_RArray(AData).ArrayType;
          Result.EFlags.CFlags := ATypeCode.EFlags.CFlags;
        end;
      end else
        Result.D.TFlags := K_ffArray;
    end;
  end;
end; //*** end of K_GetExecDataTypeCode ***

//********************************************** K_GetExecTypeBaseCode0 ***
// Get SPL Type Main Base Code by given SPL Type Code
//
//     Parameters
// ATypeCode - given SPL Type Code
// Result - Returns SPL Type Main Base Code as Integer value (without flags)
//
// Base Type Code is intial Type Code from which given SPL Type was defind by tydef statement.
//
function  K_GetExecTypeBaseCode0( ATypeCode : TK_ExprExtType ) : Integer;
begin
  with ATypeCode do begin
    Result := ATypeCode.DTCode;
    if ((D.TFlags and K_ffRoutineMask) = 0) and
       (DTCode > Ord(nptNoData))            and
       (FD.FDObjType = K_fdtTypeDef)          and
       (FD.FDFieldsCount = 1) then
      with FD.GetFieldDescrByInd(0)^ do begin
        if D.TFlags = 0 then
          Result := K_GetExecTypeBaseCode0( DataType );
      end;
  end;
end; //*** end of K_GetExecTypeBaseCode0 ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetExecTypeBaseCode
//*************************************************** K_GetExecTypeBaseCode ***
// Get SPL Type Base Code by given SPL Type Code
//
//     Parameters
// ATypeCode - given SPL Type Code
// Result    - Returns SPL Type Base Code
//
// Base Type Code is intial Type Code from which given SPL Type was defined by 
// tydef statement.
//
function  K_GetExecTypeBaseCode( ATypeCode : TK_ExprExtType ) : TK_ExprExtType;
begin
  Result := ATypeCode;
  with ATypeCode do begin
    if (D.TFlags = 0)                and
       (DTCode > Ord(nptNoData))     and
       (FD.FDObjType = K_fdtTypeDef) and
       (FD.FDFieldsCount = 1) then
    Result := K_GetExecTypeBaseCode( FD.GetFieldDescrByInd(0).DataType );
  end;
  Result.DTCode := K_GetExecTypeBaseCode0( Result );
end; //*** end of K_GetExecTypeBaseCode ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetExecTypeBaseFlags
//************************************************** K_GetExecTypeBaseFlags ***
// Get SPL Base Type Code Flags by given SPL Type Code
//
//     Parameters
// ATypeCode - given SPL Type Code
// Result    - Returns SPL Type Base Code Flags
//
// Base Type Code is intial Type Code from which given SPL Type was defined by 
// tydef statement.
//
function  K_GetExecTypeBaseFlags( ATypeCode : TK_ExprExtType ) : TK_ExprTypeFlags;
begin
  with ATypeCode do begin
    Result := EFlags;
    if (D.TFlags <> 0)              or
       (DTCode < Ord(nptNoData))    or
       (FD.FDObjType <> K_fdtTypeDef) or
       (FD.FDFieldsCount <> 1) then Exit;
    Result.TFlags := K_GetExecTypeBaseFlags( FD.GetFieldDescrByInd(0).DataType ).TFlags;
  end;
end; //*** end of K_GetExecTypeBaseFlags ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetExecElemTypeBaseCode
//*********************************************** K_GetExecElemTypeBaseCode ***
// Get SPL Base Type Elements Code by given SPL Type Code
//
//     Parameters
// ATypeCode - given SPL Type Code
// Result    - Returns SPL Type Elements Base Code (without Array, VArray or 
//             Pointer Flags)
//
// Base Type Code is intial Type Code from which given SPL Type was defined by 
// tydef statement.
//
function  K_GetExecElemTypeBaseCode( ATypeCode : TK_ExprExtType ) : TK_ExprExtType;
begin
  Result := K_GetExecTypeBaseCode( ATypeCode );
  Result.D.TFlags := Result.D.TFlags and not K_ffPointerArrayMask;
end; //*** end of K_GetExecElemTypeBaseCode ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetTypeCode
//*********************************************************** K_GetTypeCode ***
// Get SPL Type Code by given SPL Type pure Name
//
//     Parameters
// ATypeName - given SPL Type pure Name (without Array, VArray or Pointer 
//             attributes)
// Result    - Returns SPL Type Code (without Flags).
//
// If Type with given Name is absent then resulting Type Main Code (without 
// Flags) is -1.
//
function  K_GetTypeCode( ATypeName : string ) : TK_ExprExtType;
var
  RecInd : Integer;
begin
  RecInd := K_SHBaseTypesList.IndexOf( ATypeName );
  if RecInd = -1 then begin
    RecInd := K_TypeDescrsList.IndexOf( ATypeName );
    Result.All := 0;
    if RecInd <> -1 then begin
      Result.All := Integer(K_TypeDescrsList.Objects[RecInd]);
    end else
      Result.DTCode := -1;
  end else
    Result.All := RecInd;
end; // end of function K_GetTypeCode

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetTypeCodeSafe
//******************************************************* K_GetTypeCodeSafe ***
// Get SPL Type Code safe by given SPL Type pure Name
//
//     Parameters
// ATypeName - given SPL Type pure Name (without Array, VArray or Pointer 
//             attributes)
// Result    - Returns SPL Type Code. (without Array, VArray or Pointer Flags)
//
// If Type with given Name is absent then TK_SPLTypeNameError exception will be 
// raised.
//
function  K_GetTypeCodeSafe( ATypeName : string ) : TK_ExprExtType;
begin
  Result := K_GetTypeCode( ATypeName );
  if Result.DTCode = -1 then
    raise TK_SPLTypeNameError.Create( 'Unknown SPL type name -> '+ ATypeName );
//  assert( Result.DTCode <> -1, 'Unknown type name -> '+ TypeName );
end; // end of function K_GetTypeCodeSafe

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetExecTypeCodeSafe
//*************************************************** K_GetExecTypeCodeSafe ***
// Get SPL Type Code safe by given SPL Type Name
//
//     Parameters
// ATypeName - given SPL Type Name (with Array, VArray or Pointer attributes)
// Result    - Returns SPL Type Code (with Array, VArray or Pointer Flags)
//
// If Type with given Name is absent then TK_SPLTypeNameError exception will be 
// raised.
//
function  K_GetExecTypeCodeSafe( ATypeName : string ) : TK_ExprExtType;
var
  s : string;
  ff : byte;
begin
  s := K_sccArray+ ' ';
  ff := 0;

//  if AnsiStartsText(s, TypeName) then begin
  if K_StrStartsWith(s, ATypeName, true) then begin
    ATypeName := Copy( ATypeName, Length(s) + 1, Length(ATypeName) );
    ff := K_ffArray;
  end else begin
    s := K_sccVArray+ ' ';
//    if AnsiStartsText(s, ATypeName) then begin
    if K_StrStartsWith(s, ATypeName, true) then begin
      ATypeName := Copy( ATypeName, Length(s) + 1, Length(ATypeName) );
      ff := K_ffVArray;
    end;
  end;
  Result := K_GetTypeCodeSafe( ATypeName );
  Inc(Result.D.TFlags, ff);
end; // end of function K_GetExecTypeCodeSafe

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_SetUDRefField
//********************************************************* K_SetUDRefField ***
// Set new value to IDB object reference field
//
//     Parameters
// AUDRef      - given IDB Object reference Field
// AUDNew      - new IDB Object reference value
// ACountUDRef - count IDB Object references flag (if =TRUE then IDB Object 
//               references are counted)
// Result      - Returns TRUE if new value differs from existing field value.
//
function K_SetUDRefField( var AUDRef : TN_UDBase; AUDNew : TN_UDBase;
                          ACountUDRef : Boolean = true ) : Boolean;
begin
  Result := (AUDRef <> AUDNew);
  if not Result then Exit;
//  assert( (AUDRef = nil) or (AUDRef.RefCounter > 1), 'Last UDReference' );
  if ACountUDRef then
    AUDRef.UDDelete;
  AUDRef := AUDNew;
  if ACountUDRef and (AUDNew <> nil) then
    Inc(AUDNew.RefCounter);
end; //*** end of K_SetUDRefField ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_MoveFieldsByList
//****************************************************** K_MoveFieldsByList ***
// Move Record Fields Values given by List of SPL Fields Names
//
//     Parameters
// AFieldsList - list of Record SPL Fields Names
// APSData     - pointer to source record
// ASDType     - source record SPL Type
// APDData     - pointer to destination record
// ADDType     - destination record SPL Type
// AMDFlags    - move data flags
//
procedure K_MoveFieldsByList( AFieldsList : TStrings;
                        APSData : Pointer;  const ASDType : TK_ExprExtType;
                        APDData : Pointer; const ADDType : TK_ExprExtType;
                        AMDFlags : TK_MoveDataFlags = [] );
var
  i, h : Integer;
  SPFD, DPFD : TK_POneFieldExecDescr;
  FieldName : string;
  WSDType, WDDType : TK_ExprExtType;
begin
  WSDType := K_GetExecTypeBaseCode( ASDType );
  WDDType := K_GetExecTypeBaseCode( ADDType );
  if (WSDType.DTCode < Ord(nptNoData)) and
     (WDDType.All = WSDType.All ) then
    K_MoveSPLData( APSData^, APDData^, WSDType, AMDFlags )
  else begin
    h := AFieldsList.Count - 1;
    for i := 0 to h do begin
      FieldName := AFieldsList.Strings[i];
      with WSDType.FD do
        SPFD := GetFieldDescrByInd( IndexOfFieldDescr( FieldName ) );
      if SPFD = nil then Continue;
      with WDDType.FD do
        DPFD := GetFieldDescrByInd( IndexOfFieldDescr( FieldName ) );
      if (DPFD = nil) or (SPFD.DataType.All <> DPFD.DataType.All) then Continue;

//!!      K_MoveSPLData( (PChar(APSData) + SPFD.DataPos)^,
//!!                  (PChar(APDData) + DPFD.DataPos)^,
      K_MoveSPLData( (TN_BytesPtr(APSData) + SPFD.DataPos)^,
                  (TN_BytesPtr(APDData) + DPFD.DataPos)^,
                  SPFD.DataType, AMDFlags );
    end;
  end;
end; //*** end of K_MoveFieldsByList ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_MoveSPLData
//*********************************************************** K_MoveSPLData ***
// Move given Record Data Values
//
//     Parameters
// ASData   - source record
// ADData   - destination record
// ADType   - source and destination records SPL Type
// AMDFlags - move data flags (count IDB Object References, copy Record Arrays 
//            etc.)
//
procedure K_MoveSPLData( const ASData; var ADData; const ADType : TK_ExprExtType;
                                      AMDFlags : TK_MoveDataFlags = [] );
var
  DTypeAll : Int64;
  WDDType : TK_ExprExtType;
begin

  with K_GetExecTypeBaseCode( ADType ) do begin
    DTypeAll := All and K_ectClearICFlags;
    assert( (DTypeAll <> Ord(nptNotDef)) and
            (DTypeAll <> Ord(nptNoData)),
            'Error in expression type code' );
    if (K_mdfFreeAndFullCopy in AMDFlags) then
      AMDFlags := [K_mdfCountUDRef, K_mdfCopyRArray, K_mdfFreeDest];

    if (D.TFlags and (K_ffFlagsMask or K_ffArray)) = K_ffArray then begin // array
      if @ADData = @ASData then Exit;
      if (K_mdfCopyRArray in AMDFlags) then
        K_RFreeAndCopy( TK_RArray(ADData), TK_RArray(ASData), AMDFlags )
      else if (K_mdfCopyRAElems in AMDFlags) then
        TK_RArray(ADData).SetElems( TK_RArray(ASData).P^, false )
      else begin
        if (K_mdfFreeDest in AMDFlags) then
          TK_RArray(ADData).ARelease;
        TK_RArray(ADData) := TK_RArray(ASData).AAddRef;
      end;
    end else if D.TFlags = K_ffVArray then begin
      if not (K_mdfFreeDest in AMDFlags) then Integer(ADData) := 0
      else K_FreeSPLData( ADData, DTypeAll, (K_mdfCountUDRef in AMDFlags) );
      WDDType := K_GetExecDataTypeCode(ASData, TK_ExprExtType(DTypeAll));
      if WDDType.D.TFlags <> K_ffVArray then
        K_MoveSPLData( ASData, ADData, WDDType, AMDFlags )
    end else if DTypeAll = Ord(nptString) then begin // String Type Param
      if not (K_mdfFreeDest in AMDFlags) then Integer(ADData) := 0;
      PString(@ADData)^ := PString(@ASData)^;      //SPL Class Obj - for SPL Interpretor
    end else if ((DTypeAll = Ord(nptUDRef)) or ((D.TFlags and K_ffUDRARef) <> 0))  and
                (K_mdfCountUDRef in AMDFlags) and
                ((EFlags.CFlags and K_ccStopCountUDRef) = 0) then begin// UDRef Type Param
//                (K_mdfCountUDRef in MDFlags) then begin// UDRef Type Param
      if not (K_mdfFreeDest in AMDFlags) then Integer(ADData) := 0;
//      K_SetUDRefField( TN_UDBase(DData), TN_UDBase(SData), ((EFlags.CFlags and K_ccStopCountUDRef) = 0) );
      K_SetUDRefField( TN_UDBase(ADData), TN_UDBase(ASData), true );
    end else begin
  //    if ( DTCode < Ord(nptNoData) )            or
  //       ( (D.TFlags and (K_ffFlagsMask or K_ffEnumSet)) <> 0 )  then
      if ( DTCode < Ord(nptNoData) )            or
         ( (D.TFlags and K_ffFlagsMask) <> 0 )  or
         ( Ord(FD.FDObjType) >= Ord(K_fdtEnum) ) then
        Move( ASData, ADData, K_GetExecTypeSize(All) )
      else //Record
        FD.MoveData( ASData, ADData, AMDFlags );
    end;
  end;
end; //*** end of K_MoveSPLData ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_FreeSPLData
//*********************************************************** K_FreeSPLData ***
// Free given Record Data Values
//
//     Parameters
// AData       - given data record
// ADType      - record SPL Type
// ACountUDRef - count IDB Object References flag, if =FALSE then for fields 
//               that contain IDB Objects references no RefCount changes will be
//               done
//
// Free routine free memory occupied by Pascal strings, SPL Records Arrays and 
// if ACountUDRef is TRUE, decrement corresponding IDB Objects RefCount.
//
procedure K_FreeSPLData( var AData; const ADType : Int64; ACountUDRef : Boolean = false );
var
  FillRecSpace : Boolean;
  DTypeAll : Int64;
  WType : TK_ExprExtType;
begin
  WType := K_GetExecTypeBaseCode( TK_ExprExtType(ADType) );
  with WType do begin
    DTypeAll := WType.All and K_ectClearICFlags;
    assert( (DTypeAll <> Ord(nptNotDef)) and
            (DTypeAll <> Ord(nptNoData)) and
            ((TK_ExprExtType(WType).D.CFlags and K_ccObsolete) = 0),
                                          'Error in expression type code' );
    if WType.D.TFlags  = K_ffVArray then
      DTypeAll := K_GetExecDataTypeCode( AData, WType ).All;
    FillRecSpace := true;
    with TK_ExprExtType(DTypeAll) do begin
      if (D.TFlags and (K_ffFlagsMask or K_ffArray)) = K_ffArray then begin
      //*** Field - TK_RArray
        if TK_RArray(AData) <> nil then begin
          if ACountUDRef and
             (TK_RArray(AData).RefCount = 0) then
            TK_RArray(AData).SetCountUDRef;
          TK_RArray(AData).ARelease
        end;
      end else if DTypeAll = Ord(nptString) then begin
      //*** Field - String
        string(AData) := '';
        FillRecSpace := false;
      end else if (DTypeAll = Ord(nptUDRef)) and
                  ACountUDRef then begin
      //*** Field - TN_UDBase
        K_SetUDRefField( TN_UDBase(AData), nil, ((EFlags.CFlags and K_ccStopCountUDRef) = 0) );
        FillRecSpace := false;
      end else if ( DTCode > Ord(nptNoData) )          and
                  ( (D.TFlags and K_ffFlagsMask) = 0 ) and
                  ( Ord(FD.FDObjType) < Ord(K_fdtEnum) ) then begin
      //*** Field - SPL Record
        FD.FreeData( AData, 0, ACountUDRef );
        FillRecSpace := false;
      end;
    end;
    if FillRecSpace then
      FillChar( AData, K_GetExecTypeSize( WType.All ), 0 );
  end;

end; //*** end of K_FreeSPLData ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_FieldIsEmpty
//********************************************************** K_FieldIsEmpty ***
// Check if given Field is Empty
//
//     Parameters
// APData     - pointer to Data Field
// AFieldSize - given Data Field Size
// Result     - Returns TRUE if all bytes of given field are $00
//
function K_FieldIsEmpty( APData : Pointer; AFieldSize : Integer ) : Boolean;
var
  i : Integer;
begin
  Result := true;
  for i := 0 to AFieldSize - 1 do begin
    Result := (PByte(APData)^ = 0);
    if not Result then break;
    Inc(PByte(APData));
  end;
end; //end of K_FieldIsEmpty

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_AddSPLDataToSBuf
//****************************************************** K_AddSPLDataToSBuf ***
// Add Data to serial binary buffer
//
//     Parameters
// AData  - given data
// ADType - data SPL Type
// ASBuf  - serial binary buffer object
//
// Do not call K_AddSPLDataToSBuf directly, it is used automatically during 
// Binary Serialization Loop
//
procedure K_AddSPLDataToSBuf( var AData; const ADType : TK_ExprExtType;
                                                        ASBuf: TN_SerialBuf );
var
  DTypeAll : Int64;
  VarArrayFlag : Integer;
begin
  with K_GetExecTypeBaseCode( ADType ) do begin
    DTypeAll := All and K_ectClearICFlags;
    assert( (DTypeAll <> Ord(nptNotDef)) and
            (DTypeAll <> Ord(nptNoData)),
            'Error in expression type code' );
    if D.TFlags  = K_ffVArray then begin
      VarArrayFlag := 0;
      DTypeAll := K_GetExecDataTypeCode( AData, TK_ExprExtType(DTypeAll) ).All and K_ectClearICFlags;
      if TK_ExprExtType(DTypeAll).D.TFlags  = K_ffArray then
        VarArrayFlag := 1;
      ASBuf.AddRowInt( VarArrayFlag );
    end;
  end;
  with TK_ExprExtType(DTypeAll) do
    if (D.TFlags and (K_ffArray or K_ffFlagsMask)) = K_ffArray then
      TK_RArray(AData).AddToSBuf( ASBuf )
    else if DTypeAll = Ord(nptString) then // String Type Param
      ASBuf.AddRowString( string(AData) )
    else if DTypeAll = Ord(nptUDRef) then begin // UDBase Type Param
      if TN_UDBase(AData) = nil then
        ASBuf.AddRowInt( -1 )
      else begin
        K_UDRefSaveToFileDE.Child := TN_UDBase(AData);
        K_BuildDEChildRef( K_UDRefSaveToFileDE, false );
        ASBuf.AddRowInt( K_UDRefSaveToFileDE.Child.RefIndex );
        ASBuf.AddRowString( K_UDRefSaveToFileDE.Child.RefPath );
      end;
    end else if DTypeAll = Ord(nptType) then
      ASBuf.AddRowString( K_GetExecTypeName( Int64(AData) ) )
    else if DTCode < Ord(nptNoData) then
      ASBuf.AddRowBytes( K_GetExecTypeSize(All), @AData )
    else begin
      if (D.TFlags and K_ffFlagsMask) = 0 then
        FD.AddDataToSbuf( AData, ASBuf );
    end;

end; //*** end of K_AddSPLDataToSBuf ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetSPLDataFromSBuf
//**************************************************** K_GetSPLDataFromSBuf ***
// Get Data from serial binary buffer
//
//     Parameters
// AData  - given data
// ADType - data SPL Type
// ASBuf  - serial binary buffer object
//
// Do not call K_GetSPLDataFromSBuf directly, it is used automatically during 
// Binary Serialization Loop
//
procedure K_GetSPLDataFromSBuf( var AData; const ADType : TK_ExprExtType;
                                                        ASBuf: TN_SerialBuf );
var
  RefInd : Integer;
  DTypeAll : Int64;
  DTName : string;
  VarArrayFlag : Integer;
  WType : TK_ExprExtType;
begin
  WType := K_GetExecTypeBaseCode( ADType );
  DTypeAll := WType.All and K_ectClearICFlags;
  assert( (DTypeAll <> Ord(nptNotDef)) and
          (DTypeAll <> Ord(nptNoData)),
            'Error in expression type code' );

  if WType.D.TFlags  = K_ffVArray then begin
    ASBuf.GetRowInt( VarArrayFlag );
    if VarArrayFlag = 0 then
      DTypeAll := ord(nptUDRef)
    else
      TK_ExprExtType(DTypeAll).D.TFlags := K_ffArray;
  end;

  with TK_ExprExtType(DTypeAll) do begin
    if (D.TFlags and (K_ffFlagsMask or K_ffArray)) = K_ffArray then begin// Load RArray
      TK_RArray(AData) := TK_RArray.Create;
      TK_RArray(AData).GetFromSbuf( ASBuf );
      if TK_RArray(AData).ElemCount = -1 then begin
        TK_RArray(AData).Free;
        TK_RArray(AData) := nil;
      end;
    end else if DTypeAll = Ord(nptString) then // String Type Param
      ASBuf.GetRowString( string(AData) )
    else if DTypeAll = Ord(nptUDRef) then begin // UDBase Type Param
      ASBuf.GetRowInt( RefInd );
      if RefInd <> -1 then begin
        TK_UDRef(AData) := TK_UDRef.Create;
        with TK_UDRef(AData) do begin
          Inc(RefCounter);
          RefIndex := RefInd;
          ASBuf.GetRowString( RefPath );
          ObjAliase := RefPath;
          ObjName := ExtractFileName(RefPath);
        end;
      end;
    end else if DTypeAll = Ord(nptType) then begin
      ASBuf.GetRowString( DTName );
      Int64(AData) := K_GetExecTypeCodeSafe( DTName ).All;
    end else if DTCode < Ord(nptNoData) then // Simple Type
      ASBuf.GetRowBytes( K_GetExecTypeSize(All), @AData )
    else begin
      if (D.TFlags and K_ffFlagsMask) = 0 then
        FD.GetDataFromSbuf( AData, ASBuf );
    end;
  end;

end; //*** end of K_GetSPLDataFromSBuf ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_AddTypeDTCodeToSBuf
//*************************************************** K_AddTypeDTCodeToSBuf ***
// Add SPL Type pure Code to serial binary buffer
//
//     Parameters
// ADTCode - given SPL Type pure Code (without flags)
// ASBuf   - serial binary buffer object
//
// Do not call K_AddTypeDTCodeToSBuf directly, it is used automatically during 
// Binary Serialization Loop
//
procedure K_AddTypeDTCodeToSBuf( ADTCode : Integer; ASBuf: TN_SerialBuf );
begin
  if ADTCode < Ord(nptNoData) then begin
    ASBuf.AddRowString( '' );
    ASBuf.AddRowInt( ADTCode );
  end else
    ASBuf.AddRowString( TN_UDBase(ADTCode).BuildRefPath() );
end; //*** end of K_AddTypeDTCodeToSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_AddDataTypeToSBuf
//***************************************************** K_AddDataTypeToSBuf ***
// Add SPL Type to serial binary buffer
//
//     Parameters
// ADType - given SPL Type
// ASBuf  - serial binary buffer object
//
// Do not call K_AddDataTypeToSBuf directly, it is used automatically during 
// Binary Serialization Loop
//
procedure K_AddDataTypeToSBuf( const ADType : TK_ExprExtType;
                                                        ASBuf: TN_SerialBuf );
begin
  with ADType do begin
    K_AddTypeDTCodeToSBuf( DTCode, ASBuf );
    ASBuf.AddRowInt( EFlags.All );
  end;
end; //*** end of K_AddDataTypeToSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetTypeDTCodeFromSBuf
//************************************************* K_GetTypeDTCodeFromSBuf ***
// Get SPL Type pure Code from serial binary buffer
//
//     Parameters
// ASBuf  - serial binary buffer object
// Result - Returns SPL Type pure code (without flags)
//
// Do not call K_GetTypeDTCodeFromSBuf directly, it is used automatically during
// Binary Serialization Loop
//
function K_GetTypeDTCodeFromSBuf( ASBuf: TN_SerialBuf ) : Integer;
var
  RPath : string;
begin
  ASBuf.GetRowString( RPath );
  if RPath = '' then
    ASBuf.GetRowInt( Result )
  else begin
    TN_UDBase(Result) := K_UDCursorGetObj( RPath );
    if Result = 0 then
      raise TK_SPLTypePathError.Create( ' Unknown SPL type path -> '+ RPath );
  end;
end; //*** end of K_GetTypeDTCodeFromSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetDataTypeFromSBuf
//*************************************************** K_GetDataTypeFromSBuf ***
// Get SPL Type from serial binary buffer
//
//     Parameters
// ASBuf  - serial binary buffer object
// Result - Returns SPL Type
//
// Do not call K_GetDataTypeFromSBuf directly, it is used automatically during 
// Binary Serialization Loop
//
function K_GetDataTypeFromSBuf( ASBuf: TN_SerialBuf ): TK_ExprExtType;
begin
  with Result do begin
    DTCode := K_GetTypeDTCodeFromSBuf( ASBuf );
    ASBuf.GetRowInt( EFlags.All );
  end;
end; //*** end of K_GetDataTypeFromSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_AddSPLDataToSTBuf
//***************************************************** K_AddSPLDataToSTBuf ***
// Add Data to serial text buffer
//
//     Parameters
// AData      - given Data
// ADType     - Data SPL Type
// ASBuf      - serial text buffer object
// AFieldName - given data SPL Field Name
// AUseCurTag - use current XML tag flag (if =FALSE then if given data is 
//              Records Array object then nested XML tag <FieldName> will be 
//              used)
//
// Do not call K_AddSPLDataToSTBuf directly, it is used automatically during 
// Text Serialization Loop
//
procedure K_AddSPLDataToSTBuf( var AData; const ADType : TK_ExprExtType;
                                ASBuf: TK_SerialTextBuf; AFieldName : string;
                                AUseCurTag : Boolean );
var
  AType : TK_ParamType;
  BufStr : string;
  PData : Pointer;
  PText : Pointer;
  DSize : Integer;
  CompactMode : Boolean;
  AFmt : string;
//  ShowAttr : Boolean;
//  i : Integer;
//  EnumBuf : Integer;

label AddAttribute, OutPutUDRefData, OutPutArrayData;

  function IfShowData() : Boolean;
  var
    i : Integer;
//    PTestData : PChar;
    PTestData : TN_BytesPtr;

  begin
    Result := not (K_txtRACompact in K_TextModeFlags);
    if not Result then begin
      PTestData := PData;
      for i := 0 to DSize - 1 do begin
        Result := (PByte(PTestData)^ <> 0);
        if Result then break;
        Inc(PTestData);
//        Inc(PByte(PTestData));
      end;
    end;
  end;

begin
  AType := K_isString;
  AFmt := '';
  PData := @AData;
  with K_GetExecTypeBaseCode( ADType ) do begin
    if (D.TFlags and (K_ffFlagsMask or K_ffArray)) = K_ffArray then begin
  //*** Add TK_RArray Data
OutPutArrayData:
      CompactMode := K_txtRACompact in K_TextModeFlags;
      if AUseCurTag then AFieldName := '';
      if (TK_PRArray(PData)^ <> nil) or
         not CompactMode then
        TK_PRArray(PData)^.AddToSTBuf( ASBuf, AFieldName{, not CompactMode} );
    end else if D.TFlags  = K_ffVArray then begin
      if (K_GetExecDataTypeCode(AData, TK_ExprExtType(All)).D.TFlags and K_ffArray) = K_ffArray then
        goto OutPutArrayData
      else
        goto OutPutUDRefData;
    end else if DTCode > Ord(nptNoData) then begin
  //*** Add Derived Data Type
      with FD do
  //      if (D.TFlags and K_ffEnumSet) <> 0 then begin
        if Ord(FDObjType) >= Ord(K_fdtEnum) then begin
        //*** Enum or Set Data
          DSize := FDRecSize;
          if not IfShowData() then Exit;
          BufStr := Trim(ValueToString( AData ));
          PText := @BufStr;
          if FDFUTListInd = 0 then begin
          // Add Self To UsedTypesList
            ASBuf.SBUsedTypesList.Add( FD );
            FDFUTListInd := ASBuf.SBUsedTypesList.Count;
          end;
          goto AddAttribute;
        end else if (D.TFlags and K_ffFlagsMask) = 0 then
        //*** Recod Data
          AddDataToSTBuf( AData, ASBuf );
    end else begin
    //*** Add Built-in Data Type
      DSize := K_DataElementSize[DTCode];
      if not IfShowData() then Exit;
      PText := PData;

      case DTCode of
        Ord(nptByte)   : AType := K_isUInt1;
        Ord(nptInt)    : AType := K_isInteger;
        Ord(nptHex), Ord(nptColor) : AType := K_isHex;
        Ord(nptDouble) : AType := K_isDouble;
        Ord(nptFloat)  : AType := K_isFloat;
        Ord(nptString) : ;
        Ord(nptInt1)   : AType := K_isInt1;
        Ord(nptInt2)   : AType := K_isInt2;
        Ord(nptUInt2)  : AType := K_isUInt2;
        Ord(nptUInt4)  : AType := K_isUInt4;
        Ord(nptTDate)  : AType := K_isDate;
        Ord(nptTDateTime)  : begin
          AType := K_isDateTime;
          AFmt := 'dd.mm.yyyy hh:nn:ss.zzz';
        end;
        Ord(nptInt64)  : AType := K_isInt64;
        Ord(nptIPoint) : begin
          BufStr := N_PointToStr( PIPoint(PData)^ );
          PText := @BufStr;
        end;
        Ord(nptFPoint) : begin
          BufStr := N_PointToStr( PFPoint(PData)^, '%g %g' );
          PText := @BufStr;
        end;
        Ord(nptDPoint) : begin
          BufStr := N_PointToStr( PDPoint(PData)^, '%g %g' );
          PText := @BufStr;
        end;
        Ord(nptIRect) : begin
          BufStr := N_RectToStr( PIRect(PData)^ );
          PText := @BufStr;
        end;
        Ord(nptFRect) : begin
          BufStr := N_RectToStr( PFRect(PData)^ );
          PText := @BufStr;
        end;
        Ord(nptDRect) : begin
          BufStr := N_RectToStr( PDRect(PData)^ );
          PText := @BufStr;
        end;
        Ord(nptUDRef) : begin
OutPutUDRefData:
          BufStr := '';
          if TN_UDBase(AData) <> nil then begin
            K_UDRefSaveToFileDE.Child := TN_UDBase(AData);
            if K_UDRefSaveToFileDE.Child.Owner = nil then
              K_UDRefSaveToFileDE.Child := TN_UDBase(AData);
            K_BuildDEChildRef( K_UDRefSaveToFileDE, false );
            with K_UDRefSaveToFileDE.Child do begin
              if RefIndex <> 0 then
                BufStr := format( ':%d:', [RefIndex] );
              BufStr := BufStr + RefPath;
            end;
          end;
          PText := @BufStr;
        end;
        Ord(nptType) : begin
          BufStr := K_GetExecTypeName( Int64(AData) );
          PText := @BufStr;
        end;
        Ord(nptUDType) : begin
          BufStr := N_ClassTagArray[Integer(AData)];
          PText := @BufStr;
        end;
      else
        assert( (DTCode <> Ord(nptNotDef)) and
                (DTCode <> Ord(nptNoData)),
                'Wrong type code' );
      end; // case PType of
  AddAttribute:
      ASBuf.AddTagAttr( AFieldName, PText^, AType, AFmt );
    end;
  end;
end; //*** end of K_AddSPLDataToSTBuf ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetSPLDataFromSTBuf
//*************************************************** K_GetSPLDataFromSTBuf ***
// Get Data data serial text buffer
//
//     Parameters
// AData      - given Data
// ADType     - Data SPL Type
// ASBuf      - serial text buffer object
// AFieldName - given data SPL Field Name
// AUseCurTag - use current XML tag flag (if =FALSE then if given data is 
//              Records Array object then nested XML tag <FieldName> will be 
//              used)
//
// Do not call K_GetSPLDataFromSTBuf directly, it is used automatically during 
// Text Serialization Loop
//
procedure K_GetSPLDataFromSTBuf( var AData; const ADType : TK_ExprExtType;
                              ASBuf: TK_SerialTextBuf; AFieldName : string;
                              AUseCurTag : Boolean );
var
  PScan : PChar;
  AType : TK_ParamType;
  BufStr : string;
  i, h : Integer;
  WRA : TK_RArray;
  SetEnumBuf : TN_BArray;
Label InputUDRefData, InputArrayData;
begin

  AType := K_isString;
  with K_GetExecTypeBaseCode( ADType ) do begin
    if (D.TFlags and (K_ffFlagsMask or K_ffArray)) = K_ffArray then begin
InputArrayData:
      WRA := TK_RArray.Create;
      with WRA do begin
        ElemCount := -1;
        FEType.DTCode := DTCode;
        if AUseCurTag then AFieldName := '';
        GetFromSTBuf( ASBuf, AFieldName );
        if ElemCount = -1 then begin
          Free;
          WRA := nil;
        end;
      end;
      TK_RArray(AData) := WRA;
    end else if D.TFlags  = K_ffVArray then begin
      if not ASBuf.GetTagAttr( 'TypeName', BufStr, K_isString ) then begin
//      if SBuf.GetTagAttr( FieldName, BufStr, K_isString ) then
   //!! IF is added because loading "variant" field value
   //!!  cleared previously loaded main field value
   //     ASBuf.GetTagAttr( AFieldName, BufStr, K_isString );
        if ASBuf.GetTagAttr( AFieldName, BufStr, K_isString ) then
          goto InputUDRefData
      end else
        goto InputArrayData;
    end else if DTCode > Ord(nptNoData) then begin
      with FD do
        if Ord(FDObjType) >= Ord(K_fdtEnum) then begin
          SetLength( SetEnumBuf, FDRecSize );
          if ASBuf.GetTagAttr( AFieldName, BufStr, K_isString ) then begin
            ValueFromString( SetEnumBuf[0], BufStr );
            Move( SetEnumBuf[0], AData, FDRecSize );
          end;
   //!! Code placed inside IF because loading "variant" field value
   //!!  cleared previously loaded main field value
   //       Move( SetEnumBuf[0], AData, FDRecSize );
        end else if (D.TFlags and K_ffFlagsMask) = 0 then
          GetDataFromSTBuf( AData, ASBuf );
    end else begin
      //*** Get Scalar Field
      PScan := @AData;
      case DTCode of
        Ord(nptByte)   : AType := K_isUInt1;
        Ord(nptInt)    : AType := K_isInteger;
        Ord(nptHex), Ord(nptColor) : AType := K_isHex;
        Ord(nptDouble) : AType := K_isDouble;
        Ord(nptFloat)  : AType := K_isFloat;
        Ord(nptTDate)  : AType := K_isDate;
        Ord(nptTDateTime)  : AType := K_isDateTime;
//        Ord(nptString) : Integer(Data) := 0;
        Ord(nptInt1)   : AType := K_isInt1;
        Ord(nptInt2)   : AType := K_isInt2;
        Ord(nptUInt2)  : AType := K_isUInt2;
        Ord(nptUInt4)  : AType := K_isUInt4;
        Ord(nptInt64)  : AType := K_isInt64;
        Ord(nptIPoint), Ord(nptFPoint), Ord(nptDPoint),
        Ord(nptIRect), Ord(nptFRect), Ord(nptDRect),
        Ord(nptUDRef), Ord(nptType), Ord(nptUDType) : PScan := PChar(@BufStr);
      else
        assert( (All <> Ord(nptNotDef)) and
                (All <> Ord(nptNoData)),
                'Wrong type code' );
      end; // case FieldType

      if ASBuf.GetTagAttr( AFieldName, PScan^, AType ) then
        case DTCode of
          Ord(nptIPoint) : TPoint(AData)  := N_ScanIPoint( BufStr );
          Ord(nptFPoint) : TFPoint(AData) := N_ScanFPoint( BufStr );
          Ord(nptDPoint) : TDPoint(AData) := N_ScanDPoint( BufStr );
          Ord(nptIRect)  : TRect(AData)   := N_ScanIRect( BufStr );
          Ord(nptFRect)  : TFRect(AData)  := N_ScanFRect( BufStr );
          Ord(nptDRect)  : TDRect(AData)  := N_ScanDRect( BufStr );
          Ord(nptUDRef) : begin
InputUDRefData:
            TN_UDBase(AData) := nil;
            if BufStr <> '' then begin
              TK_UDRef(AData) := TK_UDRef.Create;
              i := 0;
              h := Length(BufStr);
              with TK_UDRef(AData) do begin
                Inc(RefCounter);
                if BufStr[1] = ':' then begin
                  i := 2;
                  repeat
                    Inc(i);
                  until (i > h) or (BufStr[i] = ':');
                  RefIndex := StrToIntDef( Copy( BufStr, 2, i - 2 ), 0 );
                end;
                RefPath := Copy( BufStr, i + 1, h );
                ObjAliase := RefPath;
                ObjName := ExtractFileName(RefPath);
              end;
            end;
          end;
          Ord(nptType)   : Int64(AData) := K_GetTypeCodeSafe( BufStr ).All;
          Ord(nptUDType) : Integer(AData) := K_GetUObjCIByTagName( BufStr );
        end;
    end;
  end;

end; //*** end of K_GetSPLDataFromSTBuf ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_SaveSPLDataToSTBuf
//**************************************************** K_SaveSPLDataToSTBuf ***
// Save given Data to serial text buffer
//
//     Parameters
// AData      - given Data
// ADType     - Data SPL Type
// ASBuf      - serial text buffer object
// ALRoot     - local IDB Subnet root Object for IDB references garbage clear 
//              after data serialization
// AFieldName - given data SPL Field Name
//
procedure K_SaveSPLDataToSTBuf( var AData; const ADType : TK_ExprExtType;
                                ASBuf: TK_SerialTextBuf; ALRoot : TN_UDBase;
                                AFieldName : string );
var
  STag : string;
  ClearSysFormat : Boolean;
begin
  if @AData = nil then Exit;
  ASBuf.InitSave();
  STag := K_GetExecTypeName( ADType.All );

  ASBuf.AddTag( STag );

  K_SetUDGControlFlags( 1, K_gcfSkipRefReplace );
  K_UDRefIndex1 := 0;

  if not (K_txtSysFormat in K_TextModeFlags) then begin
    ClearSysFormat := true;
    Include( K_TextModeFlags, K_txtSysFormat );
  end else
    ClearSysFormat := false;
  if ALRoot <> nil then
    with ALRoot do
      RefPath := K_udpLocalPathCursorName;

  K_AddSPLDataToSTBuf( AData, ADType, ASBuf, AFieldName, false );
  if ClearSysFormat then
    Exclude( K_TextModeFlags, K_txtSysFormat );
  ASBuf.AddTag( STag, tgClose );
  K_SetUDGControlFlags( -1, K_gcfSkipRefReplace );
  if ALRoot <> nil then
    K_ClearSubTreeRefInfo( ALRoot, [K_criClearMarker] );

  K_ClearUsedTypesMarks( ASBuf.SBUsedTypesList );

end; // end_of procedure K_SaveSPLDataToSTBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_SaveSPLDataToText
//***************************************************** K_SaveSPLDataToText ***
// Save given Data to text (using serial text buffer object)
//
//     Parameters
// AData      - given Data
// ADTCode    - Data SPL Type Full Code
// AFieldName - given data SPL Field Name (if ="" then name "Value" will be 
//              used)
// ASBuf      - serial text buffer object (if =NIL then deafult object will be 
//              used)
// ALRoot     - local IDB Subnet root Object for IDB references garbage clear 
//              after data serialization (may be =NIL if given Data does not 
//              contain IDB object references)
// Result     - Returns Data text representation
//
function  K_SaveSPLDataToText( var AData; const ADTCode : Int64; AFieldName : string = '';
                               ASBuf: TK_SerialTextBuf = nil; ALRoot : TN_UDBase = nil ) : string;
begin
  Result := '';
  if @AData = nil then Exit;
  if ASBuf = nil then ASBuf := K_SerialTextBuf;
  if AFieldName = '' then AFieldName := 'Value';

  Include( K_TextModeFlags, K_txtSingleLineMode );

  K_SaveSPLDataToSTBuf( AData, TK_ExprExtType(ADTCode), ASBuf, ALRoot, AFieldName);

  Exclude( K_TextModeFlags, K_txtSingleLineMode );
//  Result := SBuf.St.Text;
  Result := Copy( ASBuf.St.Text, 1, ASBuf.OfsFreeM - 1);
end; // end_of procedure K_SaveSPLDataToText

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_LoadSPLDataFromText
//*************************************************** K_LoadSPLDataFromText ***
// Load given Data from text (using serial text buffer object)
//
//     Parameters
// AData      - given Data
// ADTCode    - Data SPL Type Full Code
// ASrcText   - source Data text representation
// AFieldName - given data SPL Field Name (if ="" then name "Value" will be 
//              used)
// ASBuf      - serial text buffer object (if =NIL then deafult object will be 
//              used)
// ALRoot     - local IDB Subnet root Object for IDB references garbage clear 
//              after data serialization (may be =NIL if given Data does not 
//              contain IDB object references)
//
procedure K_LoadSPLDataFromText( var AData; const ADTCode : Int64; const ASrcText : string;
                                 AFieldName : string = '';
                                 ASBuf: TK_SerialTextBuf = nil; ALRoot : TN_UDBase = nil );
var
  SRefPath : string;
  STag : string;
  TagType : TK_STBufTagType;

  TmpUDGControlFlags : TK_UDGControlFlagSet;
  URNum : Integer;

begin
  if (@AData = nil) or (ASrcText = '') then Exit;

  TmpUDGControlFlags := K_UDGControlFlags;
  K_SetUDGControlFlags( 1, K_gcfSysDateUse );
  K_SetUDGControlFlags( 1, K_gcfSkipRefReplace );

  if AFieldName = '' then AFieldName := 'Value';
  STag := K_GetExecTypeName( ADTCode );

  try
    if ASBuf = nil then ASBuf := K_SerialTextBuf;
    ASBuf.TextStrings.Text := ASrcText;
    ASBuf.InitLoad0();
    ASBuf.GetTag( STag, TagType );

    if ALRoot <> nil then begin
      SRefPath := ALRoot.RefPath;
      K_UDCursorGet(K_udpLocalPathCursorName).SetRoot( ALRoot );
    end;
    K_UDRefTable := nil;
    K_GetSPLDataFromSTBuf( AData, TK_ExprExtType(ADTCode), ASBuf, AFieldName, false );
    ASBuf.GetSpecTag( STag, tgClose );
  except
    On E: Exception do
      K_ShowMessage(E.Message);
  end;


  K_SetUDGControlFlags( -1, K_gcfSysDateUse );
  K_SetUDGControlFlags( -1, K_gcfSkipRefReplace );
  K_UDGControlFlags := TmpUDGControlFlags;

  if ALRoot <> nil then begin
    URNum := K_BuildDirectReferences( ALRoot, [K_bdrClearRefInfo, K_bdrClearURefCount] );
    if URNum > 0 then
      K_ShowUnresRefsInfo( ALRoot, URNum );
    K_UDRefTable := nil;

    ALRoot.RefPath := SRefPath;
  end;
end; // end_of procedure K_LoadSPLDataFromText

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_CompareSPLData
//******************************************************** K_CompareSPLData ***
// Compare data structures
//
//     Parameters
// AData1     - first compare data structure
// AData2     - second compare data structure
// ADType     - compare data SPL Type
// ASPath     - start SPL record path for unequal data fields messages
// ACompFlags - compare data structures  flags
//
function  K_CompareSPLData( const AData1, AData2; const ADType : TK_ExprExtType;
                            ASPath : string; ACompFlags : TK_CompDataFlags = [] ) : Boolean;
var
  DTypeAll : Int64;
  WSDType : TK_ExprExtType;
begin
  with K_GetExecTypeBaseCode( ADType ) do begin
    DTypeAll := All and K_ectClearICFlags;

    assert( (All <> Ord(nptNotDef)) and
            (All <> Ord(nptNoData)) and
            ((D.CFlags and K_ccObsolete) = 0),
            'Error in expression type code' );
    Result := true;
    if (DTypeAll = Ord(nptString)) then begin
    //*** Compare strings
      if (PString(@AData1)^ <> PString(@AData2)^) then // String Type Param
        Result := false;
    end else if D.TFlags  = K_ffVArray then begin
    //*** Compare VArrays
      WSDType := K_GetExecDataTypeCode(AData1, TK_ExprExtType(DTypeAll));
      Result := WSDType.All = K_GetExecDataTypeCode(AData2, TK_ExprExtType(DTypeAll)).All;
      if Result then
        Result := K_CompareSPLData( AData1, AData2, WSDType, ASPath, ACompFlags );
    end else if ((D.TFlags and K_ffArray) = 0) and
                ( (DTCode < Ord(nptNoData))           or
                  ((D.TFlags and K_ffFlagsMask) <> 0) or
                  (Ord(FD.FDObjType) >= Ord(K_fdtEnum)) ) then begin
      if (DTCode = Ord(nptUDRef)) and
         (K_cdfCompareUDTree in ACompFlags) then begin
        if (K_UDLoopProtectionList.IndexOf(TN_UDBase(AData1)) = -1) then
    //*** Compare UDbase SubTree
          Result := TN_UDBase(AData1).CompareTree( TN_UDBase(AData2),
                                                K_CompareTreeFlags, ASPath+K_udpFieldDelim );
        Exit;
      end else if not CompareMem( @AData1, @AData2, K_GetExecTypeSize(All) ) then
    //*** Compare Enums or Sets
        Result := false;
    end else if (D.TFlags and K_ffFlagsMask) = 0 then begin
      if (D.TFlags and K_ffArray) = 0 then
    //*** Compare Records
        Result := FD.CompareData( AData1, AData2, ASPath )
      else
    //*** Compare Records Arrays
        Result := TK_RArray(AData1).CompareData( TK_RArray(AData2), ASPath, ACompFlags );
      Exit;
    end;
    if not Result and (K_cdfBuildErrList in ACompFlags) then
      if K_AddCompareErrInfo( '"'+ASPath+'" not equal' ) then Exit;
  end;
end; //*** end of K_CompareSPLData ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_CompareSPLVectors
//***************************************************** K_CompareSPLVectors ***
// Compare data vectors
//
//     Parameters
// APData1     - pointer to first compare data vector
// AStep1      - first vector elements step
// APData2     - pointer to second compare data vector
// AStep2      - second vector elements step
// ACount      - vectors elements counter
// AElemDTCode - vectors elements SPL Type Full Code
//
function  K_CompareSPLVectors( APData1 : Pointer; AStep1 : Integer;
                        APData2 : Pointer; AStep2 : Integer;
                        ACount : Integer; AElemDTCode : Int64 ) : Boolean;
var
  i : Integer;
  WType : TK_ExprExtType;
begin
  Result := true;
  WType := K_GetExecTypeBaseCode( TK_ExprExtType(AElemDTCode) );
  for i := 1 to ACount do begin
    if not K_CompareSPLData(APData1^, APData2^, WType, '' ) then begin
      Result := false;
      Exit;
    end;

//    Inc( PChar(APData1), AStep1 );
//    Inc( PChar(APData2), AStep2 );
    Inc( TN_BytesPtr(APData1), AStep1 );
    Inc( TN_BytesPtr(APData2), AStep2 );
  end;
end; //*** end of K_CompareSPLVectors ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_SearchInSPLDataVactor
//************************************************* K_SearchInSPLDataVactor ***
// Search given data in vector
//
//     Parameters
// APSData     - pointer to search data
// APVData     - pointer to data vector
// AStep       - vector elements step
// ACount      - vectors elements counter
// AElemDTCode - vectors elements SPL Type Full Code
// Result      - Returns index of vector element equal to given data or -1 if no
//               equal data will be found
//
function  K_SearchInSPLDataVactor( APSData : Pointer;
                        APVData : Pointer; AStep : Integer;
                        ACount : Integer; AElemDTCode : Int64 ) : Integer;
var
  i : Integer;
  WType : TK_ExprExtType;
begin
  Result := -1;
  WType := K_GetExecTypeBaseCode( TK_ExprExtType(AElemDTCode) );
  for i := 0 to ACount - 1 do begin
    if K_CompareSPLData(APSData^, APVData^, WType, '' ) then begin
      Result := i;
      Exit;
    end;
//    Inc( PChar(APVData), AStep );
    Inc( TN_BytesPtr(APVData), AStep );

  end;
end; //*** end of K_SearchInSPLDataVactor ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_SPLValueFromString
//**************************************************** K_SPLValueFromString ***
// Decode data text representation to binary
//
//     Parameters
// AData          - binary data
// ADTCode        - data SPL Type Full Code
// AText          - source data text representation
// AClearDataFlag - free binary data before decoding from text flag
// Result         - Returns error message (if OK then resulting value is "")
//
// Source string can be encoded by K_SPLValueToString with ValueToStrFlags=[] 
// (skip K_svsShowName)
//
function K_SPLValueFromString( var AData; const ADTCode : Int64;
                    AText : string; AClearDataFlag : Boolean = false  ) : string;
var
  Code : Integer;
  DBuf : Double;
  FBuf : Float;
begin
  Result := '';
  with K_GetExecTypeBaseCode( TK_ExprExtType(ADTCode) ) do begin
    if AClearDataFlag then
      K_FreeSPLData( AData, All );
    if ((EFlags.All and K_ecfFlagsMask2) = 0) then begin// Not Pointer
      if D.TFlags  = K_ffVArray then
        Result := K_SPLValueFromString( AData,
              K_GetExecDataTypeCode(AData, TK_ExprExtType(All)).All, AText )
      else if (All and K_ectClearICFlags) > Ord(nptNoData) then begin
        if (D.TFlags and K_ffArray) <> 0 then begin
          if AText <> '' then begin
            if TK_RArray(AData) = nil then
              TK_RArray(AData) := K_RCreateByTypeCode( All, 0 );
            Result := TK_RArray(AData).ValueFromString( AText )
          end;
        end else
          Result := FD.ValueFromString( AData, AText );
      end else begin
        if DTCode <> Ord(nptString) then
          AText := Trim(AText);
        case DTCode of
        Ord(nptString): begin// String Type Param
          Integer(AData) := 0;
          string(AData) := AText;
        end;

        Ord(nptByte), Ord(nptInt1): begin // One byte  Param
          Code := StrToIntDef( AText, Byte(AData) );
          Byte(AData) := Code;
        end;

        Ord(nptInt2), Ord(nptUInt2): begin // Two byte  Param
          Code := StrToIntDef( AText, TN_UInt2(AData) );
          TN_UInt2(AData) := Code;
        end;

        Ord(nptInt), Ord(nptUInt4): // four byte decimal Param
          Integer(AData) := StrToIntDef( AText, Integer(AData) );

        Ord(nptInt64) :  // eight byte decimal Param
          Int64(AData) := StrToIntDef( AText, Int64(AData) );

        Ord(nptHex): begin// 4 byte unsigned
          Integer(AData) := StrToIntDef( AText, Integer(AData) );
        end; // nptHex: // 4 byte unsigned

        Ord(nptColor): begin// 4 byte unsigned
          Integer(AData) := N_StrToColor( AText );
        end; // nptColor: // 4 byte unsigned

        Ord(nptDouble): begin // 8 byte double Param
          DBuf := Double(AData);
          Val( K_ReplaceCommaByPoint( AText ), Double(AData), Code );
          if Code <> 0 then Double(AData) := DBuf;
        end; // nptDouble: // 8 byte float

        Ord(nptFloat): // 4 byte float Param
        begin
          FBuf := Float(AData);
          Val( K_ReplaceCommaByPoint( AText ), Float(AData), Code );
          if Code <> 0 then Float(AData) := FBuf;
        end; // nptFloat: // 4 byte float

        Ord(nptIPoint): // 8 byte Integer Point coords Param
        begin
          TPoint(AData) := N_ScanIPoint( AText );
        end; // nptDPoint: // 8 byte Integer Point coords Param

        Ord(nptDPoint): // 16 byte double Point coords Param
        begin
          TDPoint(AData) := N_ScanDPoint( AText );
        end; // nptDPoint: // 16 byte double Point coords Param

        Ord(nptFPoint): // 8 byte Float Point coords Param
        begin
          TFPoint(AData) := N_ScanFPoint( AText );
        end; // nptDPoint: // 16 byte double Point coords Param

        Ord(nptIRect): // 16 byte Integer Rect coords Param
        begin
          TRect(AData) := N_ScanIRect( AText );
        end; // nptIRect: // 16 byte Integer Rect coords Param

        Ord(nptDRect): // 32 byte double Rect coords Param
        begin
          TDRect(AData) := N_ScanDRect( AText );
        end; // nptDRect: // 32 byte double Rect coords Param

        Ord(nptFRect): // 16 byte Float Rect coords Param
        begin
          TFRect(AData) := N_ScanFRect( AText );
        end; // nptDRect: // 32 byte double Rect coords Param

        Ord(nptTDateTime),
        Ord(nptTDate):// 8 byte double Param
        begin
          if AText = '""' then
//          if (Text = '""') or (Text = '*') then
            Double(AData) := 0
          else
            TDateTime(AData) := K_StrToDateTime( AText );
        end; // nptDRect: // 32 byte double Rect coords Param

        Ord(nptUDRef)  : begin
          TN_UDBase(AData) := K_UDCursorGetObj( AText );
        end;
        Ord(nptType) :
          Int64(AData) := K_GetTypeCodeSafe( AText ).All;
        Ord(nptUDType) :
          Integer(AData) := K_GetUObjCIByTagName( AText );
        else
          Result := ' > "'+AText+'"'
        end; // case PType of
      end;
    end;
  end;
end; //*** end of K_SPLValueFromString ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_SPLValueToString
//****************************************************** K_SPLValueToString ***
// Encode binary data to text
//
//     Parameters
// AData            - binary data
// ADType           - data SPL Type
// AValueToStrFlags - SPL value to string encoding flags (default value is 
//                    [K_svsShowName])
// AFmt             - data encoding format (default value is "" - auto format 
//                    mode)
// ASTK             - string tokenizer object (used to accumulate resulting text
//                    in tokenizer text buffer, if <>NIL then text will be added
//                    to  tokenizer text buffer, not to resulting string!!!)
// AStrLen          - resulting string maximal length (if =0 then no constraint 
//                    on resulting string length is used)
// AFFLags          - SPL type flags value for data fields filtering
// AFMask           - SPL type flags mask value for data fields filtering
// Result           - Returns string with text representation (if ASTK = nil)
//
// If fields filtering is done then only fields which SPL type flags value are 
// satisfied to condition
//#F
//    ((TK_ExprExtType.EFLags xor AFFLags) and AFMask) <> 0
//#/F
//
// will be converted to text.
//
// AValueToStrFlags default value is [K_svsShowName]. Data structure info is 
// included into resulting string (<Name>=<Value>) in this mode. Data text 
// representation recieved in this mode couldn't be decorded by 
// K_SPLValueFromString.
//
function K_SPLValueToString( const AData; const ADType : TK_ExprExtType;
                        AValueToStrFlags : TK_ValueToStrFlags = [K_svsShowName];
                        AFmt : string = ''; ASTK : TK_Tokenizer = nil;
                        AStrLen : Integer=0; AFFLags : Integer = 0;
                        AFMask : Integer = 0  ) : string;
var
  AType : TK_ParamType;

  procedure PrepDate( WType : TK_ParamType );
  begin
    if Double(AData) = 0 then begin
      AType := K_isDouble;
      Result := '""';
//      Result := '*';
    end else
      AType := WType;
  end;

begin
  Result := '';

  //*** Add Scalar Field
  with K_GetExecTypeBaseCode( ADType ) do begin
    AType := K_isHex;
    if ((EFlags.All and K_ecfFlagsMask1) = 0) then begin// Not Obsolete
      if (D.TFlags and K_ffPointerMask) <> 0 then begin // Pointer
        if AFmt = '' then AFmt := '$%p';
        Result := format( AFmt, [Pointer(AData)] );
        Exit;
      end else if (D.TFlags and K_ffArray) <> 0 then begin // array
        Result := TK_RArray(AData).ValueToString( ASTK, AValueToStrFlags, AStrLen, AFFLags, AFMask );
        Exit;
      end else if D.TFlags  = K_ffVArray then begin
        Result := K_SPLValueToString( AData, K_GetExecDataTypeCode(AData, TK_ExprExtType(All)),
                                      AValueToStrFlags, AFmt, ASTK, AStrLen, AFFLags, AFMask );
        Exit;
      end;

      if (All and K_ectClearICFlags) > Ord(nptNoData) then begin
        Result := FD.ValueToString( AData, AValueToStrFlags, ASTK, AStrLen, AFFLags, AFMask );
        Exit;
      end else
        assert( (DTCode <> Ord(nptNotDef)) and
                (DTCode <> Ord(nptNoData)),
                'Wrong type code while convert to string' );

        case DTCode of
          Ord(nptByte)   : AType := K_isUInt1;
          Ord(nptInt)    : AType := K_isInteger;
          Ord(nptHex)    : ;
          Ord(nptColor)  : begin
            Result := N_ColorToHTMLHex( Integer(AData) );
            Exit;
          end;
          Ord(nptDouble) : AType := K_isDouble;
          Ord(nptFloat)  : AType := K_isFloat;
          Ord(nptString) : begin
            if AFmt = '' then
              AType := K_isString
            else begin
              Result := string(AData);
              Exit;
            end;
          end;
          Ord(nptType) : begin
            Result := K_GetExecTypeName( Int64(AData) );
            Exit;
          end;
          Ord(nptUDType) : begin
            Result := N_ClassTagArray[Integer(AData)];
            Exit;
          end;
          Ord(nptInt1)   : AType := K_isInt1;
          Ord(nptInt2)   : AType := K_isInt2;
          Ord(nptUInt2)  : AType := K_isUInt2;
          Ord(nptUInt4)  : AType := K_isUInt4;
          Ord(nptInt64)  : AType := K_isInt64;
          Ord(nptTDate)  : begin
            PrepDate( K_isDate );
            if AType <> K_isDate then Exit;
          end;
          Ord(nptTDateTime): begin
            PrepDate( K_isDateTime );
            if AType <> K_isDateTime then Exit;
          end;
          Ord(nptUDRef)  : begin

            if TN_UDBase(AData) = nil then
              Result := '""'
            else
//              Result := K_MainRootObj.GetRefPathToObj( TN_UDBase(AData), true );
              Result := K_GetPathToUObj( TN_UDBase(AData), K_MainRootObj,
                                         K_ontObjName, [K_ptfTryAltRelPath] );

//              Result := TN_UDBase(nil).GetRefPathToObj( TN_UDBase(AData), true );
{
            if TN_UDBase(AData) = nil then
              Result := 'nil'
            else
              Result := '<'+N_ClassTagArray[TN_UDBase(AData).ClassFlags and $FF]+' '+
              TN_UDBase(AData).GetUName+'>';
}
            Exit;
          end;
          Ord(nptIPoint) : begin
            Result := N_PointToStr( TPoint(AData), AFmt );
            Exit;
          end;
          Ord(nptFPoint) : begin
            Result := N_PointToStr( TFPoint(AData), AFmt );
            Exit;
          end;
          Ord(nptDPoint) : begin
            Result := N_PointToStr( TDPoint(AData), AFmt );
            Exit;
          end;
          Ord(nptIRect) : begin
            Result := N_RectToStr( TRect(AData), AFmt );
            Exit;
          end;
          Ord(nptFRect) : begin
            Result := N_RectToStr( TFRect(AData), AFmt );
            Exit;
          end;
          Ord(nptDRect) : begin
            Result := N_RectToStr( TDRect(AData), AFmt );
            Exit;
          end;
        end; // case PType of

    end;
  end;
  Result := K_ToString( AData, Atype, AFmt );
end; //*** end of K_SPLValueToString ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_SPLValueToMem
//********************************************************* K_SPLValueToMem ***
// Serialized SPL binary data to memory
//
//     Parameters
// AData    - source binary data
// ADType   - source data SPL Type
// AMemPtr  - pointer to resulting serialized data
// AMemSize - serialized data length in bytes
//
procedure K_SPLValueToMem( var AData; const ADType : TK_ExprExtType;
                           out AMemPtr : Pointer; out AMemSize : Integer );
begin
  N_SerialBuf.OfsFree := 0;
  N_SerialBuf.CurOfs  := 0;
  K_AddSPLDataToSBuf( AData, ADType, N_SerialBuf );
  AMemPtr := @N_SerialBuf.Buf1[0];
  AMemSize := N_SerialBuf.OfsFree;
end; //*** end of K_SPLValueToMem

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_SPLValueFromMem
//******************************************************* K_SPLValueFromMem ***
// Deserialized SPL binary data from memory
//
//     Parameters
// AData    - resulting binary data
// ADType   - resulting data SPL Type
// AMemPtr  - pointer to source serialized data
// AMemSize - source serialized data length in bytes
//
procedure K_SPLValueFromMem( var AData; const ADType : TK_ExprExtType;
                             AMemPtr : Pointer; AMemSize : Integer );
begin
  with N_SerialBuf do begin
    SetCapacity( AMemSize );
    Move( AMemPtr^, Buf1[0], AMemSize );
    OfsFree := AMemSize;
    CurOfs  := 0;
  end;
  K_GetSPLDataFromSBuf( AData, ADType, N_SerialBuf );
end; //*** end of K_SPLValueToMem

//******************************** K_GetNumberFromDouble
//
procedure K_GetNumberFromDouble( var Number; NumTypeCode : TK_SPLVarType; VSrc : Double );
begin
  case NumTypeCode of
  nptInt   : Integer(Number) := Round(VSrc);
  nptDouble: Double(Number) := VSrc;
  nptByte  : Byte(Number) := Round(VSrc);
  nptUInt2 : TN_UInt2(Number) := Round(VSrc);
  nptInt1  : TN_Int1(Number) := Round(VSrc);
  nptInt2  : TN_Int2(Number) := Round(VSrc);
  nptUInt4 : TN_UInt4(Number) := Round(VSrc);
  nptInt64 : Int64(Number) := Round(VSrc);
  nptFloat : Float(Number) := VSrc;
  end;
end; //*** end of K_GetNumberFromDouble

//********************************************** K_FreeRArrays ***
//
procedure K_FreeRArrays( var RArray : TK_RArray; ANum : Integer;
                                                FreeDepth : Integer = 0  );
var
  i : Integer;
  PRA : TK_PRArray;
  WPRA : TK_PRArray;
begin
  Dec(FreeDepth);
  PRA := @RArray;
  for i := 0 to ANum - 1 do begin
    with PRA^ do begin
      if FreeDepth >= 0 then begin
        WPRA := TK_PRArray(P);
        K_FreeRArrays( WPRA^, ALength, FreeDepth );
      end;
      ARelease;
    end;
//    Inc( PChar(PRA), SizeOf( TK_RArray ) );
    Inc( TN_BytesPtr(PRA), SizeOf( TK_RArray ) );

  end;

end; // end of procedure K_FreeRArrays

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_RCopy
//***************************************************************** K_RCopy ***
// Copy Records Array
//
//     Parameters
// ARArray  - source Records Array
// AMDFlags - copy control flags
// AInd     - start source Records Array index
// ACount   - number of elements
// Result   - Returns copy of source Records Array with given number of elements
//
function  K_RCopy( ARArray : TK_RArray; AMDFlags : TK_MoveDataFlags = [];
                   AInd : Integer = 0; ACount: Integer = -1 ) : TK_RArray;
begin
  Result := nil;
  if not ARArray.CalcCount( AInd, ACount ) and
    // Additional Check for Empty Array Copy Permission
    (ACount < 0) and
    ((ARArray = nil) or (ARArray.AttrsSize = 0)) then Exit;

  Result := K_RCreateByTypeCode( ARArray.GetComplexType.All, ACount );
  Result.HCol := ARArray.HCol;
  if ((K_mdfCountUDRef in AMDFlags) or (K_mdfFreeAndFullCopy in AMDFlags)) and
     ((Result.ElemType.D.CFlags and K_ccStopCountUDRef) = 0) then Result.SetCountUDRef;
  if ARArray.AttrsSize > 0 then
    K_MoveSPLData( ARArray.PA^, Result.PA^, Result.AttrsType, AMDFlags );
  if (ARArray.ElemSize > 0) and (ACount > 0) then
    Result.SetElems( ARArray.P( AInd )^, false, 0, -1,
      (K_mdfCopyRArray in AMDFlags) or (K_mdfFreeAndFullCopy in AMDFlags) );

end; // end of function K_RCopy

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_RFreeAndCopy
//********************************************************** K_RFreeAndCopy ***
// Copy Records Array
//
//     Parameters
// ARArray  - resulting Records Array
// ASArray  - source Records Array
// AMDFlags - copy control flags
// AInd     - start source Records Array index
// ACount   - number of elements
//
procedure K_RFreeAndCopy( var ARArray : TK_RArray; const ASArray : TK_RArray;
                          AMDFlags : TK_MoveDataFlags = [] ;
                          AInd : Integer = 0; ACount: Integer = -1 );
var
  WArray : TK_RArray;
begin
  WArray := K_RCopy( ASArray, AMDFlags, AInd, ACount );
//if Count <> -2 then
  ARArray.ARelease;
  ARArray := WArray;
end; // end of function K_RFreeAndCopy

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_RCreateByTypeCode
//***************************************************** K_RCreateByTypeCode ***
// Create Records Array Object by given Type Full Code
//
//     Parameters
// ADTCode  - resulting Records Array Type Full Code
// ACount   - number of elements in resulting Records Array
// ACRFlags - creation control flags
// Result   - Returns new Records Array with given number of elements
//
function  K_RCreateByTypeCode( ADTCode : Int64; ACount : Integer = 0; ACRFlags : TK_CreateRAFlags = [] ) : TK_RArray;
begin
  with TK_ExprExtType(ADTCode) do begin
    if (All <> Ord( nptNoData )) and (All <> Ord( nptNotDef )) then begin
      if not (K_crfSaveElemTypeRAFlag in ACRFlags) then
        D.TFlags := D.TFlags and not K_ffArray;
      if not (K_crfCountUDRef in ACRFlags) then
        D.CFlags := D.CFlags and not K_ccCountUDRef
      else
        D.CFlags := D.CFlags or K_ccCountUDRef;
      if K_crfNotCountUDRef in ACRFlags then
        D.CFlags := D.CFlags or K_ccStopCountUDRef;
      Result := TK_RArray.CreateByType( ADTCode, ACount );
    end else
      Result := nil;
  end;
end; // end of function K_RCreateByTypeCode

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_RCreateByTypeName
//***************************************************** K_RCreateByTypeName ***
// Create Records Array Object by given Type Name
//
//     Parameters
// ATypeName - resulting Records Array Type Name
// ACount    - number of elements in resulting Records Array
// ACRFlags  - creation control flags
// Result    - Returns new Records Array with given number of elements
//
function  K_RCreateByTypeName( ATypeName : string; ACount : Integer = 0;
                ACRFlags : TK_CreateRAFlags = [K_crfCountUDRef] ) : TK_RArray;
begin
  Result := K_RCreateByTypeCode( K_GetTypeCodeSafe(ATypeName).All, ACount, ACRFlags );
  Result.InitElems( 0, ACount );
end; // end of function K_RCreateByTypeName

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_CreateUDByRTypeCode
//*************************************************** K_CreateUDByRTypeCode ***
// Create IDB Object (Records Array container) by given Type Full Code
//
//     Parameters
// ADTÑode          - resulting Records Array Type Full Code
// ACount           - number of elements in creating Records Array
// AUDClassInd      - class index of Records Array IDB Object container
// ACallInitRoutine - Records Array Elements initialization routine call flag
//
function  K_CreateUDByRTypeCode( ADTCode : Int64; ACount : Integer = 1;
    AUDClassInd : Integer = K_UDRArrayCI; ACallInitRoutine : Boolean = true ) : TK_UDRArray;
begin
    Result := TK_UDRArray( N_ClassRefArray[AUDClassInd].Create );
    Result.InitByRTypeCode( ADTCode, ACount, ACallInitRoutine);
end; // end of function K_CreateUDByRTypeCode

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_CreateUDByRTypeName
//*************************************************** K_CreateUDByRTypeName ***
// Create IDB Object (Records Array container) by given Type Name
//
//     Parameters
// ATypeName        - resulting Records Array Type Name
// ACount           - number of elements in created Records Array
// AUDClassInd      - class index of Records Array IDB Object container
// ACallInitRoutine - Records Array Elements initialization routine call flag
// Result           - Returns new Records Array with given number of elements
//
function  K_CreateUDByRTypeName( ATypeName : string; ACount : Integer = 1;
    AUDClassInd : Integer = K_UDRArrayCI; ACallInitRoutine : Boolean = true ) : TK_UDRArray;
begin
  Result := K_CreateUDByRTypeCode( K_GetTypeCodeSafe(ATypeName).All, ACount, AUDClassInd, ACallInitRoutine );
  Result.R.InitElems( 0, ACount );
end; // end of function K_CreateUDByRTypeName

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_CreateSPLClassByType
//************************************************** K_CreateSPLClassByType ***
// SPL Class Constructor call
//
//     Parameters
// AUDType          - SPL Class Description IDB Object
// AParams          - array of pointers to Pascal parameters of SPL Class 
//                    Constructor
// AConstructorName - name of SPL Class Constructor (default value is "Create")
// Result           - Returns instance of SPL Class Object
//
// Array of pointers to corresponding Pascal parameters of SPL Class Constructor
// AParams is used to prepare SPL stack before Constructor call.
//
function K_CreateSPLClassByType( AUDType : TK_UDFieldsDescr;
                        AParams : array of const;
                        AConstructorName : string = 'Create' ) : TK_UDRArray;
begin
  Result := AUDType.CreateUDInstance( 1 );
  Result.CallSPLClassConstructor( AConstructorName, AParams );
end; // end_of procedure K_CreateSPLClassByType

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_CreateSPLClassByName
//************************************************** K_CreateSPLClassByName ***
// SPL Class Constructor call by given Class Name and Constructor Name
//
//     Parameters
// AClassName       - SPL Class Name
// AParams          - Pascal array of pointers to SPL Class Constructor
// AConstructorName - name of SPL Class Constructor (default value is "Create")
// Result           - Returns instance of SPL Class Object
//
// Array of pointers to corresponding Pascal parameters of SPL Class Constructor
// AParams is used to prepare SPL stack before Constructor call.
//
function K_CreateSPLClassByName( AClassName : string;
                        AParams : array of const;
                        AConstructorName : string = 'Create' ) : TK_UDRArray;
begin
  Result := K_CreateSPLClassByType( K_GetTypeCodeSafe( AClassName ).FD,
                                    AParams, AConstructorName );
end; // end_of procedure K_CreateSPLClassByName

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_ConvSPLDataToOleVariant
//*********************************************** K_ConvSPLDataToOleVariant ***
// Convert SPL Base Type Data to OleVariant Data
//
//     Parameters
// ADTCode - SPL Type pure Code (without flags)
// AData   - source SPL Data
// AOV     - resulting Ole Variant Data
//
procedure K_ConvSPLDataToOleVariant( ADTCode : Integer; const AData;
                                     var AOV : OleVariant );
begin
  case ADTCode of
    Ord(nptInt), Ord(nptHex), Ord(nptColor) :
      AOV := Integer(AData);
    Ord(nptString)  :
      AOV := string(AData);
    Ord(nptDouble)  :
      AOV := Double(AData);
    Ord(nptByte)   :
      AOV := Byte(AData);
    Ord(nptInt2)    :
      AOV := TN_Int2(AData);
    Ord(nptInt64)   :
      AOV := Int64(AData);
    Ord(nptInt1) :
      AOV := TN_Int1(AData);
    Ord(nptUInt2)   :
      AOV := TN_UInt2(AData);
    Ord(nptUInt4)   :
      AOV := TN_UInt4(AData);
    Ord(nptFloat)  :
      AOV := Float(AData);
    Ord(nptTDateTime),
    Ord(nptTDate)  :
      AOV := TDateTime(AData);
  else
    assert( true, 'Data type is incompatible to OleVariant' );
  end;
end; // end of function K_ConvSPLDataToOleVariant

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_ConvOleVariantToSPLData
//*********************************************** K_ConvOleVariantToSPLData ***
// Convert OleVariant Data to SPL Base Type Data
//
//     Parameters
// ADTCode - SPL Type pure Code (without flags)
// AData   - resulting SPL Data
// AOV     - source Ole Variant Data
//
procedure K_ConvOleVariantToSPLData( ADTCode : Integer; var AData;
                                const AOV : OleVariant );
begin
  case ADTCode of
    Ord(nptInt), Ord(nptHex), Ord(nptColor):
      Integer(AData) := AOV;
    Ord(nptString):
      string(AData)  := AOV;
    Ord(nptDouble):
      Double(AData) := AOV;
    Ord(nptByte):
      Byte(AData)   := AOV;
    Ord(nptInt2):
      TN_Int2(AData) := AOV;
    Ord(nptInt64):
      Int64(AData) := AOV;
    Ord(nptInt1):
      TN_Int1(AData) := AOV;
    Ord(nptUInt2):
      TN_UInt2(AData) := AOV;
    Ord(nptUInt4):
      TN_UInt4(AData) := AOV;
    Ord(nptFloat):
      Float(AData) := AOV;
    Ord(nptTDateTime),
    Ord(nptTDate):
      TDateTime(AData) := AOV;
  else
    assert( true, 'Data type is incompatible to OleVariant' );
  end;
end; // end of function K_ConvOleVariantToSPLData

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_MoveSPLVectorBySIndex
//************************************************* K_MoveSPLVectorBySIndex ***
// Move SPL Vector Data ordered by given source Vector indexes
//
//     Parameters
// ADData   - destination vector start element
// ADStep   - destination vector elements step in bytes (if step value is -1 
//            then it's real value will be size of SPL Type Data, if step value 
//            is 0 then it's real value will be size of source vector elements 
//            step)
// ASData   - source vector start element
// ASStep   - source vector elements step in bytes (if step value is -1 then its
//            real value will be size of SPL Type Data)
// ADCount  - number of indexes
// ADTCode  - vectors elements SPL Type Full Code
// AMDFlags - move data flags (count IDB Object References, copy Record Arrays 
//            etc.)
// APIndex  - pointer to indexes start element
// AIStep   - indexes step in bytes (default value is size of Integer)
// Result   - Retuns number of really moved elements.
//
// Each resulting vector element value is formed as
//#F
//  VDest[i] = VSrc[Inds[i]]
//#/F
//
// If index value Inds[i] = -1 then no data is moved. If pointer to start index 
// APIndex is NIL then all ADCount elements are moved in original order.
//
function  K_MoveSPLVectorBySIndex( var ADData; ADStep :Integer;
                             const ASData; ASStep :Integer;
                             ADCount : Integer; ADTCode : Int64;
                             AMDFlags : TK_MoveDataFlags = [];
                             APIndex : PInteger = nil; AIStep : Integer = SizeOf(Integer) ) : Integer;
var
  i, ci : Integer;
//!!  PSData, PDData : PChar;
  PSData, PDData : TN_BytesPtr;

  WType : TK_ExprExtType;
begin
  if APIndex = nil then begin
    Result := ADCount;
    K_MoveSPLVector( ADData, ADStep, ASData, ASStep, ADCount, ADTCode, AMDFlags );
    Exit;
  end;
  Result := 0;
  PDData := @ADData;
  PSData := @ASData;
  WType := K_GetExecTypeBaseCode( TK_ExprExtType(ADTCode) );
  i := K_GetExecTypeSize( WType.All );
  if ASStep = -1 then ASStep := i;
  if ADStep = -1 then ADStep := i;
  if ADStep = 0 then ADStep := ASStep;
  for i := 1 to ADCount do begin
    ci := APIndex^;
    if ci >= 0 then begin
//!!      K_MoveSPLData(  (PChar(PSData) + ci * ASStep)^, PDData^, WType, AMDFlags );
      K_MoveSPLData(  (PSData + ci * ASStep)^, PDData^, WType, AMDFlags );
      Inc(Result);
    end;
//!!    Inc(PChar(PDData), ADStep);
//!!    Inc(PChar(APIndex), AIStep );
    Inc(PDData, ADStep);
    Inc(TN_BytesPtr(APIndex), AIStep );
  end;
end; //*** end of function K_MoveSPLVectorBySIndex

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_MoveSPLVectorByDIndex
//************************************************* K_MoveSPLVectorByDIndex ***
// Move SPL Vector Data ordered by given destination Vector indexes
//
//     Parameters
// ADData   - destination vector start element
// ADStep   - destination vector elements step in bytes (if step value is -1 
//            then it's real value will be size of SPL Type Data, if step value 
//            is 0 then it's real value will be size of source vector elements 
//            step)
// ASData   - source vector start element
// ASStep   - source vector elements step in bytes (if step value is -1 then its
//            real value will be size of SPL Type Data)
// ADCount  - number of indexes
// ADTCode  - vectors elements SPL Type Full Code
// AMDFlags - move data flags (count IDB Object References, copy Record Arrays 
//            etc.)
// APIndex  - pointer to indexes start element
// AIStep   - indexes step in bytes (default value is size of Integer)
// Result   - Retuns number of really moved elements.
//
// Each resulting vector element value is formed as
//#F
//  VDest[Inds[i]] = VSrc[i]
//#/F
//
// If index value Inds[i] = -1 then no data is moved. If pointer to start index 
// APIndex is NIL then all ADCount elements are moved in original order.
//
function  K_MoveSPLVectorByDIndex( var ADData; ADStep :Integer;
                             const ASData; ASStep :Integer; ADCount : Integer;
                             ADTCode : Int64; AMDFlags : TK_MoveDataFlags = [];
                             APIndex : PInteger = nil; AIStep : Integer = SizeOf(Integer) ) : Integer;
var
  i, ci : Integer;
//!!  PSData, PDData : PChar;
  PSData, PDData : TN_BytesPtr;
  WType : TK_ExprExtType;
begin
  if APIndex = nil then begin
    Result := ADCount;
    K_MoveSPLVector( ADData, ADStep, ASData, ASStep, ADCount, ADTCode, AMDFlags );
    Exit;
  end;
  PDData := @ADData;
  PSData := @ASData;
  Result := 0;
  WType := K_GetExecTypeBaseCode( TK_ExprExtType(ADTCode) );
  i := K_GetExecTypeSize( WType.All );
  if ASStep = -1 then ASStep := i;
  if ADStep = -1 then ADStep := i;
  if ADStep =  0 then ADStep := ASStep;
  for i := 1 to ADCount do begin
    ci := APIndex^;
    if ci >= 0 then begin
//!!      K_MoveSPLData(  PSData^, (PChar(PDData) + ci * ADStep)^, WType, AMDFlags );
      K_MoveSPLData(  PSData^, (PDData + ci * ADStep)^, WType, AMDFlags );
      Inc(Result);
    end;

//!!    Inc(PChar(PSData), ASStep);
//!!    Inc(PChar(APIndex), AIStep );
    Inc(PSData, ASStep);
    Inc(TN_BytesPtr(APIndex), AIStep );
  end;
end; //*** end of function K_MoveSPLVectorByDIndex

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_MoveSPLVector
//********************************************************* K_MoveSPLVector ***
// Move SPL Vector Data
//
//     Parameters
// ADData   - destination vector start element
// ADStep   - destination vector elements step in bytes (if step value is -1 
//            then it's real value will be size of SPL Type Data, if step value 
//            is 0 then it's real value will be size of source vector elements 
//            step)
// ASData   - source vector start element
// ASStep   - source vector elements step in bytes (if step value is -1 then its
//            real value will be size of SPL Type Data)
// ADCount  - number of indexes
// ADTCode  - vectors elements SPL Type Full Code
// AMDFlags - move data flags (count IDB Object References, copy Record Arrays 
//            etc.)
//
procedure K_MoveSPLVector( var ADData; ADStep :Integer; const ASData; ASStep :Integer;
                                  ADCount : Integer; ADTCode : Int64;
                                  AMDFlags : TK_MoveDataFlags = [] );
var
  i : Integer;
//!!  PSData, PDData : PChar;
  PSData, PDData : TN_BytesPtr;
  WType : TK_ExprExtType;
begin
  PDData := @ADData;
  PSData := @ASData;
  WType := K_GetExecTypeBaseCode( TK_ExprExtType(ADTCode) );
  i := K_GetExecTypeSize( WType.All );
  if ASStep = -1 then ASStep := i;
  if ADStep = -1 then ADStep := i;
  if ADStep = 0 then ADStep := ASStep;
  for i := 1 to ADCount do begin
    K_MoveSPLData( PSData^, PDData^, TK_ExprExtType(ADTCode), AMDFlags );
    Inc(PDData, ADStep);
    Inc(PSData, ASStep);
  end;
end; //*** end of function K_MoveSPLVector

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_MoveSPLMatrixBySIndex
//************************************************* K_MoveSPLMatrixBySIndex ***
// Move SPL Matrix Data ordered by given source Matrix indexes
//
//     Parameters
// ADMData  - destination matrix start element
// ADStep0  - destination matrix elements step in bytes in first direction (if 
//            step value is 0 then it's real value will be size of source matrix
//            elements step in first direction)
// ADStep1  - destination matrix elements step in bytes in second direction (if 
//            step value is 0 then it's real value will be size of source matrix
//            elements step in second direction)
// ASMData  - source matrix start element
// ASStep0  - source matrix elements step in bytes  in first direction
// ASStep1  - source matrix elements step in bytes  in first direction
// ADCount0 - number of indexes in first direction
// ADCount1 - number of indexes in second direction
// ADTCode  - matrixes elements SPL Type Full Code
// AMDFlags - move data flags (count IDB Object References, copy Record Arrays 
//            etc.)
// APIndex0 - pointer to indexes start element in first direction
// APIndex1 - pointer to indexes start element in second direction
// AIStep0  - indexes step in bytes in first direction (default value is size of
//            Integer)
// AIStep01 - indexes step in bytes in second direction (default value is size 
//            of Integer)
// Result   - Retuns number of really moved elements.
//
// Each resulting vector element value is formed as
//#F
//  VDest[i,j] = VSrc[Inds0[i],Inds1[j]]
//#/F
//
// If index value Inds0[i] = -1 or Inds1[i] = -1 then no data is moved. If 
// pointer to start index APIndex0 is NIL or APIndex1 is NIL then all elements 
// in corresponding direction are moved in original order.
//
function  K_MoveSPLMatrixBySIndex( var ADMData; ADStep0 : Integer; ADStep1 : Integer;
                                    const ASMData; ASStep0 : Integer; ASStep1 : Integer;
                                    ADCount0, ADCount1 : Integer;
                                    ADTCode : Int64; AMDFlags : TK_MoveDataFlags = [];
                                    APIndex0 : PInteger = nil; APIndex1 : PInteger = nil;
                                    AIStep0 : Integer = SizeOf(Integer);
                                    AIStep1 : Integer = SizeOf(Integer) ) : Integer;
var
  i, ci : Integer;
//  PSData, PDData : PChar;
  PSData, PDData : TN_BytesPtr;

begin

  PDData := @ADMData;
  if ADStep0 = 0 then ADStep0 := ASStep0;
  if ADStep1 = 0 then ADStep1 := ASStep1;
  Result := 0;
  for i := 0 to ADCount1 - 1 do begin
    ci := i;
    if APIndex1 <> nil then begin
      ci := APIndex1^;
//!!      Inc(PChar(APIndex1), AIStep1 );
      Inc(TN_BytesPtr(APIndex1), AIStep1 );
    end;
    if ci >= 0 then begin
//!!      PSData := PChar(@ASMData) + ci * ASStep1;
      PSData := TN_BytesPtr(@ASMData) + ci * ASStep1;
      if APIndex0 = nil then begin
        K_MoveSPLVector( PDData^, ADStep0, PSData^, ASStep0, ADCount0, ADTCode, AMDFlags );
        Result := Result + ADCount0;
      end else
        Result := Result + K_MoveSPLVectorBySIndex( PDData^, ADStep0, PSData^, ASStep0,
                               ADCount0, ADTCode, AMDFlags, APIndex0, AIStep0 );
    end;
    Inc(PDData, ADStep1);
  end;
end; //*** end of function K_MoveSPLMatrixBySIndex

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_BuildVSegmentInds
//***************************************************** K_BuildVSegmentInds ***
// Build indexes of real (float or double) vector elements which values are 
// inside given segment
//
//     Parameters
// AData   - given vector start element
// ADStep  - elements step in bytes
// ADCount - number of elements
// ADTCode - elements SPL Type Full Code (float or doule)
// AVSMin  - given segmnet minimal value
// AVSMax  - given segmnet maximal value
// APInds  - pointer to resulting indexes start element (memory reserved for 
//           resulting indexes have to be not less then ADCount * 
//           SizeOf(Integer))
// Result  - Retuns number of proper indexes
//
function  K_BuildVSegmentInds( var AData; ADStep, ADCount : Integer;
     ADTCode : Int64; AVSMin, AVSMax : Double; APInds : PInteger ) : Integer;
var
  i : Integer;
  v : Double;
  ConvFloatToDouble : Boolean;
//!!  PData : PChar;
  PData : TN_BytesPtr;

begin

  Result := 0;
  ConvFloatToDouble := ADTCode = Ord(nptFloat);
  if not ConvFloatToDouble and (ADTCode <> Ord(nptDouble)) then Exit;
  PData := @AData;
  for i := 1 to ADCount do begin
    if ConvFloatToDouble then
      v := PFloat(PData)^
    else
      v := PDouble(PData)^;
    Inc( PData, ADStep );
    if ( v > AVSMin ) and ( v < AVSMax ) then begin
      APInds^ := i;
      Inc(APInds);
      Inc(Result);
    end;
  end;
end; //*** end of function K_BuildVSegmentInds

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_BuildConvFreeInitInds
//************************************************* K_BuildConvFreeInitInds ***
// Build reorder, free and initialize indexes of Records Array elements
//
//     Parameters
// ACount        - old Records Array elements counter
// APNInds       - pointer to start index of Records Array elements old indexes 
//                 (this indexes defines order of old elements in new Records 
//                 Array)
// APNInds       - new Records Array elements counter
// AConvDataInds - resulting array of old indexes for elements reordering
// AFreeDataInds - resulting array of old indexes for elements freeing
// AInitDataInds - resulting array of new indexes for its initializing
//
procedure K_BuildConvFreeInitInds( ACount : Integer; APNInds: PInteger; ANCount: Integer;
                                   var AConvDataInds, AFreeDataInds, AInitDataInds : TN_IArray );
var
  j, i, ci : Integer;
  MinusOne : Integer;
begin

//*** Prepare Conv and Init Indexes for changing Linked Data Blocks
  SetLength( AConvDataInds, ANCount );
  SetLength( AInitDataInds, ANCount );
  j := 0;
  for i := 0 to ANCount - 1 do begin
    ci := APNInds^;
    if ci < ACount then
      AConvDataInds[i] := ci
    else begin
      AConvDataInds[i] := -1;
      AInitDataInds[j] := i;
      Inc(j);
    end;
    Inc(APNInds);
  end;
  SetLength( AInitDataInds, j );

//*** Build Old CSDim Elements Indices which are not used now
  SetLength( AFreeDataInds, ACount );
  if ACount > 0 then begin
    K_FillIntArrayByCounter( @AFreeDataInds[0], ACount );
    if ANCount > 0 then begin
      MinusOne := -1;
      K_MoveVectorByDIndex( AFreeDataInds[0], SizeOf(Integer),
                          MinusOne, 0, SizeOf(Integer), ANCount, @AConvDataInds[0] );
      SetLength( AFreeDataInds, K_BuildActIndicesAndCompress(
          nil, nil, @AFreeDataInds[0], @AFreeDataInds[0], ACount ) );
    end;
  end;
end; //*** end of function K_BuildConvFreeInitInds

//********************************************* K_DataCast
//  Cast Array Data
//
procedure K_DataCast( var DData; DStep :Integer; DType : Int64;
                      const SData; SStep :Integer; SType : Int64; DCount : Integer );
type TConvMode = ( K_cdmDF, K_cdmFD, K_cdmDI, K_cdmID, K_cdmFI, K_cdmIF, K_cdmUU );
var
  i : Integer;
//  PSData, PDData : PChar;
  PSData, PDData : TN_BytesPtr;
  ConvMode : TConvMode;
begin
  PDData := @DData;
  PSData := @SData;
  ConvMode := K_cdmUU;
  if DType = Ord(nptDouble) then  begin
    if SType = Ord(nptFloat) then
      ConvMode := K_cdmFD
    else if SType = Ord(nptInt) then
      ConvMode := K_cdmID
  end else if DType = Ord(nptFloat) then  begin
    if SType = Ord(nptDouble) then
      ConvMode := K_cdmDF
    else if SType = Ord(nptInt) then
      ConvMode := K_cdmIF
  end else if DType = Ord(nptInt) then  begin
    if SType = Ord(nptDouble) then
      ConvMode := K_cdmDI
    else if SType = Ord(nptFloat) then
      ConvMode := K_cdmFI
  end;
  if ConvMode = K_cdmUU then Exit;
  for i := 1 to DCount do begin
    case ConvMode of
      K_cdmDF: PFloat(PDData)^ := PDouble(PSData)^;
      K_cdmFD: PDouble(PDData)^ := PFloat(PSData)^;
      K_cdmDI: PInteger(PDData)^ := Round(PDouble(PSData)^);
      K_cdmID: PDouble(PDData)^ := PInteger(PSData)^;
      K_cdmFI: PInteger(PDData)^ := Round(PFloat(PSData)^);
      K_cdmIF: PFloat(PDData)^ := PInteger(PSData)^;
    end;
//!!    Inc(PChar(PDData), DStep);
//!!    Inc(PChar(PSData), SStep);
    Inc(TN_BytesPtr(PDData), DStep);
    Inc(TN_BytesPtr(PSData), SStep);
  end;
end; //*** end of function K_DataCast

//******************************************* SPL Structure Fields Syntax
// Set path to Specified Field
// RArray Syntax
// ! - Pointer to Self Root level RArray object
// <FieldName>! - Pointer to not Root Level Self RArray object
// Root Level RArray Attributes Fields
// .! - Pointer to Attributes  (realy '.','!.','!!' are OK too)
// .!<AttrFieldName> - Pointer to Attributes Field (realy '!' is OK too)
// Not Root Level RArray Attributes Fields Syntax
// <FieldName>.! - Pointer to Attributes  (realy '!.','!!' are OK too)
// <FieldName>.!<AttrFieldName> - Pointer to Attributes Field (realy '.','!','!.','!!','..','.!.' is OK too)
// Root Level RArray with Single Element (Alength = 1) (like Attributes)
// .! - Pointer to Element  (realy '.','!.','!!' are OK too)
// .!<ElemFieldName> - Pointer to 0 Element Field (realy '!' is OK too)
// RArray Element Fields Syntax
// [i] - Pointer to Element  (realy + '.','!','.!','!.','!!' are OK too)
// [i].<ElemFieldName> - Pointer to Element Field
// <FieldName>[i] - Pointer to Element  (realy + '.','!','.!','!.','!!' are OK too)
// <FieldName>[i].<ElemFieldName> - Pointer to Element Field
//


//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetFieldPointer
//******************************************************* K_GetFieldPointer ***
// Get pointer to SPL Data Structure Field by given Path
//
//     Parameters
// APData            - root Data Structure
// ADType            - root Data Structure SPL Type
// AFieldPath        - needed Field Path
// APField           - resulrting pointer to given Field
// APErrPathPos      - pointer to Integer variable for resulting error Field 
//                     Path position (if <> NIL)
// ARACreateFlag     - if =TRUE then unexisted nested Records Arrays will be 
//                     created
// ACRFlags          - unexisted nested Records Arrays creation flags
// ARAInitFieldsFunc - created fields initialization procedure of object
// Result            - Returns resulting Field SPL Type.
//
function  K_GetFieldPointer( APData : Pointer; ADType : TK_ExprExtType;
                             AFieldPath : string; out APField : Pointer;
                             APErrPathPos : PInteger = nil;
                             ARACreateFlag : Boolean = false;
                             ACRFlags : TK_CreateRAFlags = [];
                             ARAInitFieldsFunc : TK_RAInitFieldsFunc = nil ) : TK_ExprExtType;
var
  WCPath, WCField : string;
  PFD : TK_POneFieldExecDescr;
  Ind : Integer;
  WDType : TK_ExprExtType;
  PFieldOK : Boolean;
  ParseResult : Integer;
  SearchFieldBuffer : TN_BArray;
  CurPathInd : Integer;
  CurFieldInd : Integer;
  ArrFieldName : string;
  ArrCurPathInd : Integer;
  PField0 : Pointer;

label  ErrPath;

  procedure CorrectRDType();
  begin
    if ((WDType.D.TFlags and K_ffArray) = 1) and
       (TK_RArray(PField0^) <> nil) then begin
      WDType := TK_RArray(PField0^).ArrayType;
    end;
  end;

  function PRecField : Boolean;
  var
    NilData : Boolean;
    RAData : Boolean;
    WWDType : TK_ExprExtType;
    L : Integer;
  begin
    Result := false;
    if (PField0 = nil) or
       (WDType.DTCode <= Ord( nptNoData)) then Exit;  // Break path loop - RArray is absent
    if (WDType.D.TFlags = K_ffUDRARef) then begin
      if (TN_PUDBase(PField0)^ = nil) then Exit;
      WDType.D.TFlags := K_ffVArray;
    end;
    RAData := (WDType.D.TFlags = K_ffVArray) or
              (WDType.D.TFlags = K_ffArray);
    if WDType.D.TFlags = K_ffVArray then
      PField0 := K_GetPVRArray( PField0^ );
    WDType := K_GetExecDataTypeCode( PField0^, WDType );
    if RAData then begin
      NilData := TK_PRArray(PField0)^ = nil;
      if not NilData then
        WDType := TK_PRArray(PField0)^.ArrayType;
      if NilData then begin
        if not ARACreateFlag then Exit; // Break path loop - RArray is absent
        TK_PRArray(PField0)^ := K_RCreateByTypeCode( WDType.All, 0, ACRFlags );
        if TK_PRArray(PField0)^.AttrsSize = 0 then
          TK_PRArray(PField0)^.ASetLength(1);
        if Assigned( ARAInitFieldsFunc ) then
          ARAInitFieldsFunc( TK_PRArray(PField0)^, 0, WCPath, AFieldPath, CurPathInd );
      end;
      WWDType := TK_PRArray(PField0)^.AttrsType;
      if WWDType.DTCode <= 0 then Exit;
      WDType := WWDType;
      PField0 := TK_PRArray(PField0)^.PA;
      if (WCPath = '')                 or
         (WCPath = K_sccRecFieldDelim) or
         (WCPath = K_sccVarFieldDelim) then begin
        // Access to Array Attributes
        Result := true;
        Exit;
      end;
    end;
    //*** Correct Field Path AFName. -> AFName
    L := Length(WCPath);
    if (L > 0) and (WCPath[L] = K_sccRecFieldDelim) then
      WCPath := Copy( WCPath, 1, L - 1 );
    //***
    with WDType.FD do
      PFD := GetFieldDescrByInd( IndexOfFieldDescr( WCPath ) );
    if PFD = nil then Exit;                           // Break path loop - Field Name is absent
//!!    PField0 := PChar(PField0) + PFD.DataPos;
    PField0 := TN_BytesPtr(PField0) + PFD.DataPos;
    WDType := K_GetExecTypeBaseCode( PFD.DataType );
    Result := true;
  end;

  function PArrayElem : Boolean;
  var
    FieldName : string;
    EPos : Integer;
    FieldType : TK_ExprExtType;
    FieldSize, FieldPos :  Integer;
    FillStartInd : Integer;
  begin
    Result := false;
    if (PField0 = nil) or
       ((WDType.D.TFlags and K_ffArray) = 0) then Exit;  // Break path loop - RArray is absent

    Ind := -1;
    if (WCPath[1] >= '0') and (WCPath[1] <= '9') then begin
  //*** Index = Literal Number
      Ind := StrToIntDef( WCPath, -1 );
      if Ind = -1 then Exit; //*** Index Value is not Number  // Break path loop - wrong Elem Index

      if (TK_RArray(PField0^) = nil) and ARACreateFlag then begin
        if WDType.DTCode <> Ord(nptNotDef) then   //*** Ñreate RArray with Defined Type
          TK_RArray(PField0^) := K_RCreateByTypeCode( WDType.All, 0, ACRFlags )
        else if Assigned( ARAInitFieldsFunc ) then //*** Ñreate RArray with Undefined Type
          ARAInitFieldsFunc( TK_RArray(PField0^), Ind + 1, ArrFieldName, AFieldPath, ArrCurPathInd );
      end;
      if TK_RArray(PField0^) = nil then Exit; //*** Break path loop - RArray is absent

      with TK_RArray(PField0^) do begin
        FillStartInd := ALength;
        if FillStartInd <= Ind then begin
          //*** Add New Elems if needed
          ASetLength( Ind + 1 );
          if Assigned( ARAInitFieldsFunc ) then //*** Fill New RArray Elems
            ARAInitFieldsFunc( TK_PRArray(PField0)^, FillStartInd, ArrFieldName, AFieldPath, ArrCurPathInd );
        end;
      end;
    end else if TK_RArray(PField0^) <> nil then begin
      with TK_RArray(PField0^) do begin
        WCPath := Trim(WCPath);
        if K_udpRANamePref = WCPath[1] then begin
          WCPath := Copy( WCPath, 2, Length(WCPath) );
          if FEType.DTCode = K_GetRAListItemRAType.DTCode then begin
      //*** Index = IndexOf RAList by Item Name
            Ind := K_IndexOfRAListItem( TK_RArray(PField0^), WCPath );
            if Ind = -1 then Exit; //*** Break path loop - RAList Item is absent
            WDType := K_GetExecTypeBaseCode(
               K_GetRAListItemPValue( TK_PRAListItem(P(Ind)), PField0 ) );
          end else begin
            Result := PRecField();
            Exit;
          end;
        end else begin
      //*** Index = Search Condition - <FieldName>=<FieldValue>
          EPos := Pos( K_sccParValueDelim, WCPath );
          if EPos > 0 then begin
            FieldName := Copy( WCPath, 1, EPos - 1 );
            if FieldName = '' then begin
              //*** =<FieldValue>
              FieldType := FEType;
              FieldSize := ElemSize;
              FieldPos := 0;
            end else begin
              //*** <FieldName>=<FieldValue>
              if WDType.DTCode < Ord(nptNoData) then Exit;
              with WDType.FD do
                PFD := GetFieldDescrByInd( IndexOfFieldDescr( FieldName ) );
              if PFD = nil then Exit;
              with PFD^ do begin
                FieldType := K_GetExecTypeBaseCode( DataType );
                FieldSize := DataSize;
                FieldPos := DataPos;
              end;
            end;
            //*** Prepare Search Context Buffer
            if Length(SearchFieldBuffer) < FieldSize then
              SetLength( SearchFieldBuffer, FieldSize );
            FillChar( SearchFieldBuffer[0], FieldSize, 0 );
            //*** Prepare Search Context Data from <Field Value>
            if K_SPLValueFromString( SearchFieldBuffer[0], FieldType.All,
                           Copy( WCPath, EPos + 1, Length(WCPath) ) ) = '' then
            //*** Search RArray Element
//!!              Ind := K_SearchInSPLDataVactor( @SearchFieldBuffer[0], PChar(P) + FieldPos,
              Ind := K_SearchInSPLDataVactor( @SearchFieldBuffer[0], TN_BytesPtr(P) + FieldPos,
                              ElemSize, ALength, FieldType.All );
            //*** Free Search Context Data
            K_FreeSPLData( SearchFieldBuffer[0], FieldType.All );
          end;
        end;
      end;
    end;
    if Ind = -1 then Exit; //*** Break path loop - RArray is absent or wrong search condition
    with TK_RArray(PField0^) do begin
      WDType := K_GetExecTypeBaseCode( FEType );
      PField0 := P( Ind );
    end;
    Result := true;
  end;

  function ParsePath : Integer;
// returns: -1 - Error in Array Index
//           0 - Field Name
//           1 - Array Index
  var
    S : string;
    SPos, FPos, FNPos, VFChPos, RFDChPos, SIChPos, PathLeng : Integer;
  begin
    S := '';
    RFDChPos := Pos( K_sccRecFieldDelim, WCPath );
    SIChPos := Pos( K_sccStartIndex, WCPath );
    VFChPos := Pos( K_sccVarFieldDelim, WCPath );
    FNPos := 0;
    if RFDChPos > 0 then FNPos := RFDChPos;
    if FNPos = 0 then FNPos := SIChPos
    else if SIChPos > 0 then FNPos := Min( SIChPos, FNPos );
    if FNPos = 0 then FNPos := VFChPos
    else if VFChPos > 0 then FNPos := Min( VFChPos, FNPos );

    Result := 0;
    if FNPos > 0 then begin //*** prepare Field Name
      SPos := 1;
      FPos := FNPos + 1;
      PathLeng := Length(WCPath);
      if WCPath[FNPos] = K_sccStartIndex then begin
      //*** Parse Index Value
        if FNPos = 1 then begin
          FNPos := Pos( K_sccFinIndex, WCPath );
          if FNPos = 0 then begin //*** Path Error
            Result := -1;
            Exit;
          end;
          SPos := 2;
          FPos := FNPos + 1;
          if (FPos<= PathLeng) and
             (WCPath[FPos] <> K_sccStartIndex) then Inc(FPos);
          Result := 1;
        end else
          FPos := FNPos;
      end;

      if FNPos > 1 then
        S := Copy( WCPath, SPos, FNPos - SPos )
      else
        S := '';

      WCField := Copy( WCPath, FPos, PathLeng );
      CurFieldInd := CurPathInd + FPos - 1;
      WCPath := S;
    end else
      WCField := '';
  end;

begin
  WCPath := AFieldPath;
  PField0 := APData;
//  WDType := ADType;
  WDType := K_GetExecTypeBaseCode( ADType );
  //*** Correct Field Path AFName.! -> AFName.!.
  CurPathInd := Length(WCPath);
  if (CurPathInd > 2) and
     (WCPath[CurPathInd] = K_sccVarFieldDelim) and
     (WCPath[CurPathInd-1] = K_sccRecFieldDelim) then
    WCPath := WCPath + K_sccRecFieldDelim;
  //***
  CurPathInd := 1;
  CurFieldInd := 1;
  WCPath := K_ParseVarFieldNames( WCPath, WCField );
  if WCPath = '' then begin
    WCPath := WCField;
    WCField := '';
    CurPathInd := 2;
    CurFieldInd := 2;
  end else
    CurFieldInd := CurPathInd + Length(WCPath) + 1;

  ArrFieldName := WCPath;
  ArrCurPathInd := CurPathInd;

  if WCPath <> '' then begin
    PFieldOK := (WCPath[1] <> K_sccStartIndex) and PRecField();
  end else
    PFieldOK := true;

  if (WCField <> '') or not PFieldOK then begin
    repeat
      if not PFieldOK then begin
        ParseResult := ParsePath();
        if ParseResult = -1 then goto ErrPath;
        CorrectRDType();
        if ParseResult = 1 then begin
          if not PArrayElem() then goto ErrPath;
        end else begin
          if not PRecField() then begin
    ErrPath:
            Result.DTCode := -1;
            APField := nil;
            if APErrPathPos <> nil then
              APErrPathPos^ := CurPathInd;
            Exit;
          end;
        end;
      end;
      ArrFieldName := WCPath;
      ArrCurPathInd := CurPathInd;
      WCPath := WCField;
      CurPathInd := CurFieldInd;
      PFieldOK := false;
    until (WCPath = '');
  end;
//*** Fin Path Parsing Loop
  CorrectRDType();
  Result := WDType;
  APField := PField0;
end; // end_of function K_GetFieldPointer

//##path K_Delphi\SF\K_clib\K_Script1.pas\K_GetUDFieldPointerByRPath
//********************************************** K_GetUDFieldPointerByRPath ***
// Get pointer to IDB Data Structure Field
//
//     Parameters
// AUDRoot      - given IDB Subnet root IDB Object
// APath        - Field Path starting from given root IDB Object
// APField      - resulting pointer to given Field
// AObjNameType - IDB Path Segment Name Value Type (ObjName. ObjAliase etc.)
// APUDR        - pointer to IDB Object variable for resulting IDB Field 
//                Ñontainer (if <> NIL)
// APErrPathPos - pointer to Integer variable for resulting error Field Path 
//                position (if <> NIL)
// Result       - Returns resulting Field SPL Type.
//
// Function gets pointer to SPL Data Structure Field placed in IDB Object 
// container by given relative Path from given IDB root Object. Field path 
// syntax is <IDBObjectRelPath>!<FieldPath>.
//
function  K_GetUDFieldPointerByRPath( AUDRoot : TN_UDBase;
                          APath : string; var APField : Pointer;
                          AObjNameType : TK_UDObjNameType = K_ontObjName;
                          APUDR : TN_PUDBase = nil;
                          APErrPathPos : PInteger = nil ) : TK_ExprExtType;
var
  FInd, Ind : Integer;
  DE : TN_DirEntryPar;
  WDType : TK_ExprExtType;
  PData : Pointer;

label ErrExit;
begin
  APField := nil;
  Result.All := 0;
  Result.DTCode := -1;
  Result.D.TFlags := K_ffPointer;
  if AUDRoot = nil then Exit;
  Ind := AUDRoot.GetDEByRPath( APath, DE, AObjNameType );
  Result.All := Ord(nptUDRef);
  if Ind < 0 then begin // Error in UDBase Path
ErrExit:
    if APErrPathPos <> nil then
      APErrPathPos^ := - Ind;
    Exit;
  end;
  APField := DE.Child;
  if (Ind > Length(APath)) and
     (APath <> K_udpFieldDelim) then Exit;
  APath := Copy( APath, Ind, Length(APath) );

  if APUDR <> nil then APUDR^ := DE.Child;

  if K_IsUDRArray(DE.Child) then begin
    with TK_UDRArray(DE.Child) do begin
      if (APath <> '') and
         (aPath[1] = K_sccVarAdrTypePref) then begin // path starts with '^'
//        WDType.D.TFlags := WDType.D.TFlags or K_ffArray;
        WDType := R.ArrayType;
        PData := @R;
        APath := Copy( APath, 2, Length(APath) );
      end else begin
        WDType := R.ElemType;
        PData := R.P;
      end;
    end;
    Result :=
    K_GetFieldPointer( PData, WDType, APath, APField, @FInd );
    if Result.DTCode = -1 then begin // Error in Field Path
      Ind := 1 - Ind - FInd;
      goto ErrExit;
//    if (Result.DTCode = -1) and (PErrPathPos <> nil) then // Error in Field Path
//      PErrPathPos^ := Ind + FInd - 1;
    end;
    Result.D.CFlags := WDType.D.CFlags;
  end;
  Inc( Result.D.TFlags, K_ffPointer );

end; // end_of function K_GetUDFieldPointerByRPath

//******************************************** K_GetGEFuncIndex
// Get GE Function index by Type Name and Prefix
//
function  K_GetGEFuncIndex( GEName : string; GEPrefix : string = ''  ) : Integer;
begin
  Result := -1;
  if GEPrefix <> '' then
    Result := K_GEFuncs.IndexOfName( GEPrefix + ':' + GEName );
//    Result := K_GEFuncs.IndexOf( GEPrefix + ':' + GEName );
  if Result = -1 then
    Result := K_GEFuncs.IndexOfName( GEName );
//??   Result := K_GEFuncs.IndexOf( GEName );
end; // end_of function K_GetGEFuncIndex

//****************************************** K_EditByGEFuncInd ***
// Edit Object By Global Edit Function Index
//
function  K_EditByGEFuncInd( Ind : Integer; var EData; out WasEdited : Boolean ) : Boolean;
begin
  if Ind <> -1 then begin
    WasEdited := TK_GEFunc(K_GEFuncs.Objects[Ind])( EData, K_GEFPConts.Items[Ind]  );
    Result := true;
  end else begin
    WasEdited := false;
    Result := false;
  end;
end; // end of procedure K_EditByGEFuncInd

//****************************************** K_EditByGEFuncName ***
// Edit Object By Global Edit Function
//
function  K_EditByGEFuncName( Name : string; var EData; out WasEdited : Boolean;
                           DataCaption : string = '';
                           AOwnerForm : TN_BaseForm = nil;
                           AOnGlobalAction : TK_RAFGlobalActionProc = nil;
                           APRLSData : TK_PRLSData = nil;
                           ANotModalShow : Boolean = false ) : Boolean;
var
  Ind : Integer;
begin
  Ind :=  K_GEFuncs.IndexOfName( Name );
  if Ind <> -1 then
    with TK_PRAEditFuncCont(K_GEFPConts.Items[Ind])^ do begin
      FDataCapt := DataCaption;
      FOwner := AOwnerForm;
      FNotModalShow := FNotModalShow or ANotModalShow;
      FOnGlobalAction := AOnGlobalAction;
      if APRLSData <> nil then
        FRLSData := APRLSData^;
    end;
  Result := K_EditByGEFuncInd( Ind, EData, WasEdited );
end; // end of procedure K_EditByGEFuncName

//******************************************** K_EditSPLDataByGEFunc
// Edit SPL Data
//
function  K_EditSPLDataByGEFunc( var Data; ADType : TK_ExprExtType;
                out WasEdited : Boolean;
                DataCaption : string = ''; GEPrefix : string = '';
                AOwnerForm : TN_BaseForm = nil;
                AOnGlobalAction : TK_RAFGlobalActionProc = nil;
                APRLSData : TK_PRLSData = nil;
                ANotModalShow : Boolean = false ) : Boolean;
var
  GEInd : Integer;

begin

  Result := false;
  WasEdited := false;
  if (ADType.D.TFlags and K_ffArray) <> 0 then
    Result := TK_RArray(Data).EditByGEFunc( WasEdited, DataCaption, GEPrefix, AOwnerForm,
                          AOnGlobalAction, APRLSData, ANotModalShow )
  else begin
    GEInd := K_GetGEFuncIndex( K_GetExecTypeName(ADType.All), GEPrefix );
    if GEInd >= 0 then begin
      with TK_PRAEditFuncCont(K_GEFPConts.Items[GEInd])^ do begin
        FDataCapt := DataCaption;
        FOwner := AOwnerForm;
        FNotModalShow := ANotModalShow;
        FOnGlobalAction := AOnGlobalAction;
        FRLSData := APRLSData^;
        FDType := ADType;
      end;
      Result := K_EditByGEFuncInd( GEInd, Data, WasEdited );
    end;
  end;
end; // end_of function K_EditSPLDataByGEFunc

//******************************************** K_EditUDByGEFunc
// Get pointer to Specified Field by Relative Path from specified UDBase
//
function  K_EditUDByGEFunc( UDNode, UDParent : TN_UDBase; out WasEdited : Boolean;
                AOwnerForm : TN_BaseForm = nil;
                AOnGlobalAction : TK_RAFGlobalActionProc = nil;
                ANotModalShow : Boolean = false ) : Boolean;
var
  UDID : string;
  RSLData : TK_RLSData;
  DataCaption : string;
  WTC : TClass;

  function TryEdit( ID : string ) : Boolean;
  begin
    Result := K_EditByGEFuncName( ID, UDNode, WasEdited, DataCaption, AOwnerForm,
         AOnGlobalAction, @RSLData, ANotModalShow );
  end;

begin
//  Result := false;
  with TK_UDRArray(UDNode) do begin
    DataCaption := GetUName;
    RSLData.RUDRArray := TK_UDRArray(UDNode);
    RSLData.RUDParent := UDParent;

    WTC := UDNode.ClassType;
    repeat
      UDID := WTC.ClassName;
      WTC := WTC.ClassParent;
      Result := TryEdit( UDID );
    until Result  or (WTC = TObject);

    if not Result then begin
      if K_IsUDRArray(UDNode) and
         ( R.ElemType.DTCode <> 0 )then begin
//*** by SPL Name : Class Name
        RSLData.RDType := R.ArrayType;
        RSLData.RPData := R;
        if TryEdit( K_GetExecTypeName(R.ElemType.All)+':'+UDNode.ClassName ) then
          Result := true
        else begin
          if R.EditByGEFunc( WasEdited, DataCaption, '', AOwnerForm, AOnGlobalAction,
                                       @RSLData, ANotModalShow ) then  Result :=true
        end;
      end;
    end;
  end;
end; // end_of function K_EditUDByGEFunc

//******************************************** K_EditUDTreeDataByGEFunc
// Get pointer to Specified Field by Relative Path from specified UDBase
//
function  K_EditUDTreeDataByGEFunc( UDNode, UDParent : TN_UDBase;
                                    FormDescr : TK_UDRArray;
                                    out WasEdited : Boolean;
                                    AOwnerForm : TN_BaseForm = nil;
                                    AOnGlobalAction : TK_RAFGlobalActionProc = nil;
                                    ANotModalShow : Boolean = false ) : Boolean;
var
  Ind : Integer;
begin
//  Result := false;
  Ind :=  K_GEFuncs.IndexOfName( FormDescr.ObjName );
  Result := (Ind <> -1);
  if not Result then Exit;

  with TK_PRAEditFuncCont(K_GEFPConts.Items[Ind])^ do begin
    FOwner := AOwnerForm;
    FillChar( FRLSData, SizeOf(FRLSData), 0 );
    FRLSData.RUDParent := UDParent;
    FDataCapt := K_GetFormDescrDataCaption( FormDescr );
    if FDataCapt = '' then UDNode.GetUName;
    FNotModalShow := ANotModalShow;
    FOnGlobalAction := AOnGlobalAction;
    FFormDescr := FormDescr;
  end;
//
  Result := K_EditByGEFuncInd( Ind, UDNode, WasEdited );
end; // end_of function K_EditUDByGEFunc

//********************************************** K_DataPathError ***
//
procedure K_DataPathError( ErrPrefix : string; DataPath : string; ErrPos : Integer );
var
  Leng : Integer;
  ErrPathPart, OKPathPart : string;
begin
  if ErrPos > 1 then
    OKPathPart := '"'+Copy(DataPath,1,ErrPos -1)+'"'
  else
    OKPathPart := '';
  Leng := Length(DataPath) - ErrPos + 1;
  if Leng > 0 then
    ErrPathPart := '"'+Copy(DataPath,ErrPos,Leng)+'"'
  else
    ErrPathPart := '';

  raise TK_SPLRunTimeError.Create( ErrPrefix+' OK->'+OKPathPart+
                                   ' ERR->'+ErrPathPart );
end; //*** end of K_DataPathError ***

var      K_RAListItemRAType    : TK_ExprExtType;
//***********************************  K_GetCSDimRAType
// returns TypeCode of RAList Item
//
function K_GetRAListItemRAType : TK_ExprExtType;
begin
  if K_RAListItemRAType.All = 0 then
    K_RAListItemRAType := K_GetExecTypeCodeSafe( 'TK_RAListItem' );
  Result := K_RAListItemRAType;
end; // end of K_GetRAListItemRAType

//***********************************  K_IndexOfRAListItem
// returns TypeCode of RAList Item
//
function  K_IndexOfRAListItem( RAList : TK_RArray; AName : string ) : Integer;
var
  i : Integer;
begin
  Result := -1;
  with RAList do begin
    if FEType.DTCode <> K_GetRAListItemRAType.DTCode then Exit;
    for i := 0 to AHigh do
      if SameText( AName, TK_PRAListItem(P(i)).RAName ) then begin
        Result := i;
        break;
      end;
  end;
end; // end of K_IndexOfRAListItem

//*************************************** K_GetRAListItemPValue
//
function  K_GetRAListItemPValue( PRAListItem : TK_PRAListItem; out PData : Pointer;
                                 UseArray : Boolean = false ) : TK_ExprExtType;
begin
  with PRAListItem^, RAValue do begin
    if (AttrsSize > 0) and (ElemCount = 0) then begin
      Result := AttrsType;
      PData := PA;
    end else if (ElemCount > 1) or UseArray then begin
      Result := ArrayType;
      PData := @RAValue;
    end else begin
      Result := ElemType;
      PData := P(0);
    end;
  end;
end; //*** end of procedure K_GetRAListItemPValue

{
//*************************************** K_BuildRAListByFormDescr
// Build Full RAList By FormDescr
//
function  K_BuildRAListByFormDescr( RAList : TK_RArray; ElemsCount : Integer = 1;
                                    FormDescr : TK_UDRArray = nil ) : Integer;
var
  i, RACount : Integer;
  Columns : TK_RArray;
  PFrDescr : TK_RAPFrDescr;
  PP : Pointer;
  PCD : TK_PRAFColumnDescr;
  ColsCount : Integer;
//  PRAListItem : TK_PRAListItem;
  FDInds : TN_IArray;
  MatrixMode : Boolean;
  ItemType, ElemsType, AttrsType : TK_ExprExtType;
  UDType : TK_UDFieldsDescr;
begin
  Result := 0;
  UDType := nil;
  if FormDescr = nil then begin

    UDType := K_GetTypeCode( PString(RAList.PA)^ ).FD;
    if Integer(UDType) = -1 then Exit;
    FormDescr := K_CreateSPLClassByType( UDType, [], 'Create' );
  end;

  PFrDescr := FormDescr.GetFieldPointer( 'Common' );
  if PFrDescr = nil then Exit;
  PP := FormDescr.GetFieldPointer( 'Columns' );
  if PP = nil then Exit;

  Columns := TK_RArray(PP^);
  ColsCount := Columns.ALength;
  PCD := Columns.P;
  MatrixMode := (K_ramRowChangeNum in PFrDescr.ModeFlags) or
                (K_ramRowAutoChangeNum in PFrDescr.ModeFlags);
  SetLength( FDInds, ColsCount );
  for i := 0 to ColsCount - 1 do begin
    with PCD^ do
      if not (K_racSeparator in TK_RAColumnFlagSet(CShowEditFlags)) then begin
        MatrixMode := MatrixMode and ((FType.D.TFlags and K_ffArray) <> 0);
        FDInds[Result] := i;
        Inc(Result)
      end;
    Inc( PCD );
  end;

  RAList.DeleteElems( 0, -1 );
  RAList.ASetLength( Result );

  for i := 0 to Result - 1 do begin
    with TK_PRAListItem(RAList.P(i))^, TK_PRAFColumnDescr(Columns.P( FDInds[i] ))^ do begin
      ItemType := K_GetExecTypeBaseCode( FType );
      ItemType.D.TFlags := ItemType.D.TFlags and not K_ffArray;
      AttrsType := K_GetRArrayTypes( ItemType, ElemsType );
      RACount := ElemsCount;
      if not MatrixMode                     and
        (AttrsType.DTCode > Ord(nptNotDef)) and
        (ElemsType.DTCode = Ord(nptNotDef)) then RACount := 0;
      RAValue := K_RCreateByTypeCode( ItemType.All, RACount, [] );
      RAValue.FEType.D.CFlags := RAList.FEType.D.CFlags;
      RAName := FName;
    end;
  end;

  if UDType <> nil then FormDescr.Delete();

end; //*** end of K_BuildRAListByFormDescr
}
//*************************************** K_RebuildRAListByFormDescr
// Rebuild RAList By FormDescr:
//  - Delete RAList Elements which are absent in FormDescr or
//           RAList Element Type is not Equal to FormDescr Columns Description
//  - Add RAList Elements which are absent in RAList
//
function  K_RebuildRAListByFormDescr( RebuildFlagsSet : TK_RAListRebuildFlagsSet;
                                      RAList : TK_RArray; ElemsCount : Integer = -1;
                                      PAddItemsCount : PInteger = nil;
                                      FormDescr : TK_UDRArray = nil  ) : Boolean;
var
  i, RACount : Integer;
  Columns : TK_RArray;
  PFrDescr : TK_RAPFrDescr;
  PP : Pointer;
  PCD : TK_PRAFColumnDescr;
  ColsCount : Integer;
//  PRAListItem : TK_PRAListItem;
  FDInds : TN_IArray;
  DelRAMarks : array of Boolean;
  MatrixMode : Boolean;
  ItemType, ElemsType, AttrsType : TK_ExprExtType;
  UDType : TK_UDFieldsDescr;
  Ind : Integer;
  PRAListItem : TK_PRAListItem;
  OldElemsCount : Integer;
  RAListCount : Integer;
  AddNewInd : Boolean;
  AddCount : Integer;

  function IndexOfColumn( AName : string ) : Integer;
  var
    j : Integer;
  begin
    PCD := Columns.P;
    Result := -1;
    for j := 0 to ColsCount - 1 do begin
      with PCD^ do
        if not (K_racSeparator in TK_RAColumnFlagSet(CShowEditFlags)) and
           (AName = FName) then begin
          Result := j;
          Exit;
        end;
      Inc( PCD );
    end;
  end;

begin
  Result := false;
  UDType := nil;
  if FormDescr = nil then begin
    UDType := K_GetTypeCode( PString(RAList.PA)^ ).FD;
    if Integer(UDType) = -1 then Exit;
    FormDescr := K_CreateSPLClassByType( UDType, [], 'Create' );
  end;

  PFrDescr := FormDescr.GetFieldPointer( 'Common' );
  if PFrDescr = nil then Exit;
  PP := FormDescr.GetFieldPointer( 'Columns' );
  if PP = nil then Exit;

  Columns := TK_RArray(PP^);
  ColsCount := Columns.ALength;
  PCD := Columns.P;
  MatrixMode := (K_ramRowChangeNum in PFrDescr.ModeFlags) or
                (K_ramRowAutoChangeNum in PFrDescr.ModeFlags);

  OldElemsCount := 1;
  RAListCount := RAList.ALength;
  if RAListCount > 0 then
    with TK_PRAListItem(RAList.P)^ do OldElemsCount := RAValue.Alength;

  if K_rrfRebuildAll in RebuildFlagsSet then begin
    RAList.DeleteElems( 0, -1 );
    RAListCount := 0;
  end;

  SetLength( DelRAMarks, RAListCount );

//*** Build New Column Inds List
  SetLength( FDInds, ColsCount );
  AddCount := 0;
  for i := 0 to ColsCount - 1 do begin
    with PCD^ do
      if not (K_racSeparator in TK_RAColumnFlagSet(CShowEditFlags)) then begin
        MatrixMode := MatrixMode and ((FType.D.TFlags and K_ffArray) <> 0);

        if not (K_rrfRebuildAll in RebuildFlagsSet) then
          Ind := K_IndexOfRAListItem( RAList, FName )
        else
          Ind := -1;

        AddNewInd := Ind < 0;
        if not AddNewInd                       and
           (K_rrfDeleteOld in RebuildFlagsSet) and
           (TK_PRAListItem(RAList.P(Ind)).RAValue.GetComplexType.DTCode <> FType.DTCode) then begin
          DelRAMarks[Ind] := true;
          AddNewInd := true;
        end;

        if AddNewInd then begin
          FDInds[AddCount] := i;
          Inc(AddCount);
        end;
      end;
    Inc( PCD );
  end;

//*** Delete Old RAList Items
  if K_rrfDeleteOld in RebuildFlagsSet then begin
    PRAListItem := RAList.P(RAListCount - 1);
    for i := RAListCount - 1 downto 0 do begin
      with PRAListItem^ do
        if DelRAMarks[i] or
           (IndexOfColumn( RAName ) = -1) then begin
          RAList.DeleteElems( i );
          Result := true;
        end;
      Dec( PRAListItem );
    end;
  end;

  Ind := RAList.ALength;

  if MatrixMode then begin
    if (ElemsCount = -1) or (Ind = 0) then
      ElemsCount := OldElemsCount;
  end else
    ElemsCount := Max( 1, ElemsCount );

  if not (K_rrfSkipAddNew in RebuildFlagsSet) then begin
//*** Add New RAList Items
    Result := Result or (AddCount > 0);
    RAList.InsertRows( -1, AddCount );
    PRAListItem := RAList.P(Ind);
    for i := 0 to AddCount - 1 do begin
      with PRAListItem^, TK_PRAFColumnDescr(Columns.P( FDInds[i] ))^ do begin
  //??      ItemType := K_GetExecTypeBaseCode( FType );
        ItemType := FType;
        ItemType.D.TFlags := ItemType.D.TFlags and not K_ffArray;
        AttrsType := K_GetRArrayTypes( ItemType, ElemsType );
        RACount := ElemsCount;
        if not MatrixMode                     and
          (AttrsType.DTCode > Ord(nptNotDef)) and
          (ElemsType.DTCode = Ord(nptNotDef)) then RACount := 0;
        RAValue := K_RCreateByTypeCode( ItemType.All, RACount, [] );
        RAValue.FEType.D.CFlags := RAList.FEType.D.CFlags;
        RAName := FName;
      end;
      Inc( PRAListItem );
    end;
  end else
    AddCount := 0;

  if PAddItemsCount <> nil then
    PAddItemsCount^ := AddCount;

  if UDType <> nil then FormDescr.UDDelete();

end; //*** end of K_RebuildRAListByFormDescr

//*************************************** K_ReorderRAListItemsData
//
procedure K_ReorderRAListItemsData( RAList : TK_RArray;
                                    PConvInds : PInteger; ConvIndsCount : Integer;
                                    PFreeInds : PInteger; FreeIndsCount : Integer;
                                    PInitInds : PInteger; InitIndsCount : Integer );
var
  i : Integer;
begin
  for i := 0 to RAList.AHigh do
    with TK_PRAListItem( RAList.P(i) )^ do
      RAValue.ReorderElems( PConvInds, ConvIndsCount, PFreeInds, FreeIndsCount, PInitInds, InitIndsCount );
end; //*** end of K_ReorderRAListItemsData

//*************************************** K_FillRArrayFromSMatr
// Fill strings RArray by given Strings Matrix
//
//   Parameters
// ASMAtr - source Strings Matrix
// ARAMatr - resulting RArray
// ACol - resulting RArray start column
// ARow - resulting RArray start row
// Result - Returns resulting RArray size elements counter
//
function K_FillRArrayFromSMatr( ASMAtr : TN_ASArray; var ARAMatr : TK_RArray;
                                ACol : Integer = 0; ARow : Integer = 0 ) : Integer;
var
  i, j : Integer;
  RowCount, ColCount : Integer;
  PS : PString;

begin
  Result := 0;
  RowCount := Length( ASMatr );
  if RowCount = 0 then Exit;
  ColCount := Length( ASMatr[0] );
  if ColCount = 0 then Exit;

  if ARAMatr = nil then begin
    Result := RowCount * ColCount;
    ARAMatr := K_RCreateByTypeCode( Ord(nptString), Result );
    ARAMatr.HCol := ColCount - 1;
  end else begin
    if ARAMatr.FEType.DTCode <> Ord(nptString) then begin
      Result := -1;
      Exit;
    end;
    ColCount := Min( ACol + ColCount, ARAMatr.AColCount );
    RowCount := Min( ARow + RowCount, ARAMatr.ARowCount );
    Result := RowCount * ColCount;
  end;

  for i := ARow to RowCount - 1 do begin
    PS := ARAMatr.PME( ACol, i );
    for j := ACol to ColCount - 1 do begin
      PS^ := ASMAtr[i][j];
      Inc(PS);
    end;
  end;
end; //*** end of K_FillRArrayFromSMatr

//**************************************************** K_SaveRASubMatrToStrings ***
// Add RArray Strings SubMatrix to given Strings List using given elements delimiter
//
//     Parameters
// AStrings - resulting TStrings (each adding string is buit from corresponding
//            RArray SubRow)
// ARAMatr - RArray with source String Matrix
// ADelim   - matrix row elements delimiter
// ACol - SubMatrix start column
// ARow - SubMatrix start row
// AColCount - SubMatrix columns counter
// ARowCount - SubMatrix rows counter
//
procedure K_SaveRASubMatrToStrings( AStrings: TStrings; ARAMatr : TK_RArray;
              ADelim: Char = #9; ACol : Integer = 0; ARow : Integer = 0;
              AColCount : Integer = 0; ARowCount : Integer = 0 );
var
  i, j : Integer;
  RowCount, ColCount : Integer;
  PS : PString;
  CSVStr: string;
begin
  ColCount := ARAMatr.AColCount;
  RowCount := ARAMatr.ARowCount;
  if (ColCount = 0) or (RowCount = 0) or
     (ACol >= ColCount) or (ARow >= RowCount) then Exit;
  ColCount := Min( ACol + AColCount, ColCount );
  RowCount := Min( ARow + ARowCount, RowCount );
  for i := ARow to RowCount - 1 do begin
    PS := ARAMatr.PME( ACol, i );
    CSVStr := '';
    for j := ACol to ColCount - 1 do begin
      CSVStr := CSVStr + PS^ + ADelim;
      Inc(PS);
    end;
    SetLength( CSVStr, Length(CSVStr)-1 ); // remove last delimiter
    AStrings.Add( CSVStr );
  end;

end; //*** end K_SaveRASubMatrToStrings

{*** TK_CSPLCont ***}

//********************************************** TK_CSPLCont.Create ***
//
constructor TK_CSPLCont.Create;
begin
  inherited;
  Inc( RefCount );
  ExprStackCapacity := K_ExprStackSize;
  SetLength( ExprStack, ExprStackCapacity );
  ScriptShowMessage := SelfShowDump;
end; //*** end of TK_CSPLCont.Create ***

//********************************************** TK_CSPLCont.Destroy ***
//
destructor TK_CSPLCont.Destroy;
begin
  inherited;
end; //*** end of TK_CSPLCont.Destroy ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_CSPLCont\AAddRef
//***************************************************** TK_CSPLCont.AAddRef ***
// Add new reference (increment self use counter) to SPL interpreter global 
// context object
//
function TK_CSPLCont.AAddRef : TK_CSPLCont;
begin
  if Self = nil then
    Result := TK_CSPLCont.Create
  else begin
    Result := Self;
    Inc( RefCount );
  end;
end; //*** end of TK_CSPLCont.AAddRef ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_CSPLCont\ARelease
//**************************************************** TK_CSPLCont.ARelease ***
// Clear reference (decrement self use counter) from SPL interpreter global 
// context object
//
function TK_CSPLCont.ARelease : Boolean;
begin
  Result := false;
  if (Self <> nil) and (RefCount > 1) then begin
    Dec( RefCount );
    Result := true;
    Exit;
  end;
  Free;
end; //*** end of TK_CSPLCont.ARelease ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_CSPLCont\GetDataFromExprStack
//**************************************** TK_CSPLCont.GetDataFromExprStack ***
// Get last data portion from expression stack
//
//     Parameters
// AData  - variable for resulting data
// ADType - last stack data portion resulting type code
//
procedure TK_CSPLCont.GetDataFromExprStack( var AData; var ADType : Int64 );
var
  PData : Pointer;
begin
  GetPointerToExprStackData( PData, ADType );
  K_MoveSPLData( PData^, AData, TK_ExprExtType(ADType) );
  K_FreeSPLData( PData^, ADType );
end; //*** end of TK_CSPLCont.GetDataFromExprStack ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_CSPLCont\GetPointerToExprStackData
//*********************************** TK_CSPLCont.GetPointerToExprStackData ***
// Get last data portion from expression stack
//
//     Parameters
// APData - pointer to stack last data portion
// ADType - last stack data portion resulting type code
//
function TK_CSPLCont.GetPointerToExprStackData( var APData : Pointer;
                                       var ADType : Int64 ) : Integer;
begin
  Dec( ExprStackLevel, SizeOf( ADType ) );
  assert( ExprStackLevel > 0, 'Expression stack underflow' );
  ADType := PInt64(@ExprStack[ExprStackLevel])^;
  Result := K_GetExecTypeSize( ADType );
//*** Get Data
  APData := GetPointerToExprStackRecord( Result );
{
  Dec( ExprStackLevel, Result );
  assert( ExprStackLevel >= 0, 'Expression stack underflow' );
  PData := @ExprStack[ExprStackLevel];
}
end; //*** end of TK_CSPLCont.GetPointerToExprStackData ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_CSPLCont\GetPointerToExprStackRecord
//********************************* TK_CSPLCont.GetPointerToExprStackRecord ***
// Get pointer to last data portions in expression stack given by size
//
//     Parameters
// ADSize - size of last stack data portions in bytes
// Result - Returns pointer to last data portions in expression stack
//
function TK_CSPLCont.GetPointerToExprStackRecord( ADSize : Integer ) : Pointer;
begin
  Dec( ExprStackLevel, ADSize );
  assert( ExprStackLevel >= 0, 'Expression stack underflow' );
  Result := @ExprStack[ExprStackLevel];
end; //*** end of TK_CSPLCont.GetPointerToExprStackRecord ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_CSPLCont\PutDataToExprStack
//****************************************** TK_CSPLCont.PutDataToExprStack ***
// Put new data portion to expression stack
//
//     Parameters
// AData  - new data portion value
// ADType - new data portion type code
//
procedure TK_CSPLCont.PutDataToExprStack  ( const AData; ADType : Int64 );
var
  CLevel, DSize : Integer;
begin
  assert( ADType <> Ord(nptNotDef), 'Error in expression type code' );
//*** Set new stack Capacity if needed
  DSize := K_GetExecTypeSize( ADType );
  CLevel := ExprStackLevel;
  Inc( ExprStackLevel, DSize + SizeOf( ADType ) );
  assert( ExprStackCapacity >= ExprStackLevel, 'Expression stack overflow' );
  K_MoveSPLData( AData, ExprStack[CLevel], TK_ExprExtType(ADType), [] );
  PInt64(@ExprStack[CLevel+DSize])^ := ADType;
end; //*** end of TK_CSPLCont.PutDataToExprStack ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_CSPLCont\TimerEvent
//************************************************** TK_CSPLCont.TimerEvent ***
// Global context method for timer using support
//
//     Parameters
// ASender - Pascal Timer object created in SPL SetTimeout command
//
procedure TK_CSPLCont.TimerEvent( ASender : TObject );
var
  PI: TK_UDProgramItem;
begin
  TTimer(ASender).Enabled := false;
  PI := TK_UDProgramItem(TTimer(ASender).Tag);
  TTimer(ASender).Free;
  if K_TimerEventPermition then PI.SPLProgExecute( );
end; //*** end of TK_CSPLCont.TimerEvent ***

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_CSPLCont\SelfShowDump
//************************************************ TK_CSPLCont.SelfShowDump ***
// Self show dump procedure of object
//
//     Parameters
// ADumpLine  - dump text value
// AMesStatus - dump message status (error, warning, info etc.)
//
// Used as initiial value for Self.ScriptShowMessage
//
procedure TK_CSPLCont.SelfShowDump( const ADumpLine: string; AMesStatus : TK_MesStatus);
begin
  if Assigned(SPLGCDumpWatch) then SPLGCDumpWatch.AddInfoLine( ADumpLine, AMesStatus );
end; //*** end of TK_CSPLCont.ShowDump ***

{***  end of TK_CSPLCont ***}

{*** TK_UDFieldsDescr ***}

//********************************************** TK_UDFieldsDescr.Create
//
constructor TK_UDFieldsDescr.Create;
begin
  inherited;
  ImgInd := 36;
  ClassFlags   := K_UDFieldsDescrCI;
  FDUDClassInd := K_UDRArrayCI;
  FDCurFVer    := K_SPLDataCurFVer;
  FDNDPTVer    := K_SPLDataCurFVer;
  FDPDNTVer    := K_SPLDataPDNTVer;
end; //*** end of TK_UDFieldsDescr.Create

//********************************************** TK_UDFieldsDescr.Destroy
//
destructor TK_UDFieldsDescr.Destroy;
begin
  FDSHE.Free;
  FDUDRefsIndsList.Free;
  inherited;
end; //*** end of TK_UDFieldsDescr.Destroy

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\AddFieldsToSBuf
//**************************************** TK_UDFieldsDescr.AddFieldsToSBuf ***
// Add values of IDB object self fields to serial binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
// Only self fields are serialized (without any childs data)
//
procedure TK_UDFieldsDescr.AddFieldsToSBuf(SBuf: TN_SerialBuf);
var
  i, NParams: integer;
begin
  inherited;

  SBuf.AddRowBytes( 1, @FDFieldsTypesFlags );
  SBuf.AddRowBytes( 1, @FDObjType );
  SBuf.AddRowInt( FDRecSize );
  SBuf.AddRowInt( FDUDClassInd );

  SBuf.AddRowInt( FDCurFVer );
  SBuf.AddRowInt( FDNDPTVer );
  SBuf.AddRowInt( FDPDNTVer );

  SBuf.AddRowInt( FDFieldsCount );
//  NParams := Min( FDFieldsCount, Length(FDV) );
  NParams := Length(FDV);
  SBuf.AddRowInt( NParams );
  for i := 0 to NParams-1 do begin
    SBuf.AddRowInt( FDV[i].FieldPos );
    SBuf.AddRowInt( FDV[i].FieldSize );
    SBuf.AddRowInt( FDV[i].FieldType.DTCode );
    SBuf.AddRowInt( FDV[i].FieldType.EFlags.All );
    SBuf.AddRowString( FDV[i].FieldName );
    SBuf.AddRowString( FDV[i].FieldDefValue );
  end;

end; //*** end of TK_UDFieldsDescr.AddFieldsToSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\GetFieldsFromSBuf
//************************************** TK_UDFieldsDescr.GetFieldsFromSBuf ***
// Get values of IDB object self fields from serial binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
// Only self fields are deserialized (without any childs data)
//
procedure TK_UDFieldsDescr.GetFieldsFromSBuf(SBuf: TN_SerialBuf);
var
  i, NParams : integer;
begin
  inherited;

  SBuf.GetRowBytes( 1, @FDFieldsTypesFlags );
  SBuf.GetRowBytes( 1, @FDObjType );
  SBuf.GetRowInt( FDRecSize );
  SBuf.GetRowInt( FDUDClassInd );

  SBuf.GetRowInt( FDCurFVer );
  SBuf.GetRowInt( FDNDPTVer );
  SBuf.GetRowInt( FDPDNTVer );

  SBuf.GetRowInt( FDFieldsCount );
  SBuf.GetRowInt( NParams );
  SetLength( FDV, NParams );
  for i := 0 to NParams - 1 do begin
    SBuf.GetRowInt( FDV[i].FieldPos );
    SBuf.GetRowInt( FDV[i].FieldSize );
    SBuf.GetRowInt( FDV[i].FieldType.DTCode );
    SBuf.GetRowInt( FDV[i].FieldType.EFlags.All );
    SBuf.GetRowString( FDV[i].FieldName );
    SBuf.GetRowString( FDV[i].FieldDefValue );
  end;

end; //*** end of TK_UDFieldsDescr.GetFieldsFromSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\CopyFields
//********************************************* TK_UDFieldsDescr.CopyFields ***
// Copy self fields values from given IDB  object
//
//     Parameters
// ASrcObj - source IDB base (TN_UDBase) object
//
procedure TK_UDFieldsDescr.CopyFields( ASrcObj: TN_UDBase );
begin
  if ASrcObj = nil then Exit; // a precaution
  inherited;
  with TK_UDFieldsDescr(ASrcObj) do begin
    self.FDFieldsTypesFlags := FDFieldsTypesFlags;
    self.FDObjType := FDObjType;
    self.FDRecSize := FDRecSize;
    self.FDUDClassInd := FDUDClassInd;

    self.FDCurFVer := FDCurFVer;
    self.FDNDPTVer := FDNDPTVer;
    self.FDPDNTVer := FDPDNTVer;

    self.FDFieldsCount := FDFieldsCount;
    self.FDV := Copy( FDV, 0, FDFieldsCount );
    self.RefreshFieldsExecDescr;
  end;
end; //*** end of TK_UDFieldsDescr.CopyFields

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\AddFieldsToText
//**************************************** TK_UDFieldsDescr.AddFieldsToText ***
// Add values of IDB object self fields to serial text buffer
//
//     Parameters
// ASBuf        - serial text buffer object
// AAddObjFlags - serialized self update (ObjUFlags) and view (ObjVFlags) fields
// Result       - Returns TRUE if child objects serialization is needed, if self
//                fields and childs are serialized then resulting value is 
//                FALSE.
//
function TK_UDFieldsDescr.AddFieldsToText( ASBuf: TK_SerialTextBuf;
                                           AAddObjFlags: Boolean ): Boolean;
var
  i, NParams: integer;
begin
  inherited AddFieldsToText( ASBuf, AAddObjFlags );

  ASBuf.AddTagAttr( 'FieldsType', FDFieldsTypesFlags, K_isUInt1 );
  ASBuf.AddTagAttr( 'DataType', FDObjType, K_isUInt1 );
  if FDUDClassInd <> K_UDRArrayCI then
//    SBuf.AddTagAttr( 'UDClassInd', UDClassInd, K_isHex );
  ASBuf.AddTagAttr( 'UDClass', N_ClassTagArray[FDUDClassInd] );
  ASBuf.AddTagAttr( 'RecSize', FDRecSize, K_isInteger );

  ASBuf.AddTagAttr( 'CurFVer', FDCurFVer, K_isInteger );
  ASBuf.AddTagAttr( 'NDPTVer', FDNDPTVer, K_isInteger );
  ASBuf.AddTagAttr( 'PDNTVer', FDPDNTVer, K_isInteger );

  ASBuf.AddTagAttr( 'NAFields', FDFieldsCount, K_isInteger );
//  NParams := Min( FDFieldsCount, Length(FDV) );
  NParams := Length(FDV);
  ASBuf.AddTagAttr( 'NFields', NParams, K_isInteger );
  for i := 0 to NParams-1 do
  begin
    ASbuf.AddEOL( False );
    ASBuf.AddScalar( FDV[i].FieldName, K_isString );
    ASBuf.AddScalar( FDV[i].FieldPos, K_isInteger );
    ASBuf.AddScalar( FDV[i].FieldSize, K_isInteger );
    ASBuf.AddScalar( FDV[i].FieldType.DTCode, K_isInteger );
    ASBuf.AddScalar( FDV[i].FieldType.EFlags, K_isHex );
    ASBuf.AddScalar( FDV[i].FieldDefValue, K_isString );
  end;
  Result := true;
end; // procedure TK_UDFieldsDescr.AddFieldsToText

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\GetFieldsFromText
//************************************** TK_UDFieldsDescr.GetFieldsFromText ***
// Get values of IDB object self fields from serial text buffer
//
//     Parameters
// ASBuf  - serial text buffer object
// Result - Returns 0 if child objects deserialization is needed, if self fields
//          and childs are deserialized then resulting value is not 0.
//
function TK_UDFieldsDescr.GetFieldsFromText( ASBuf: TK_SerialTextBuf): Integer;
var
  i, NParams: integer;
  UDClassName : string;
begin
  inherited GetFieldsFromText( ASBuf );
  ASBuf.GetTagAttr( 'FieldsType', FDFieldsTypesFlags, K_isUInt1 );
  ASBuf.GetTagAttr( 'DataType', FDObjType, K_isUInt1 );
  FDUDClassInd := K_UDRArrayCI;
//  SBuf.GetTagAttr( 'UDClassInd', UDClassInd, K_isInteger );
  UDClassName := '';
  ASBuf.GetTagAttr( 'UDClass', UDClassName );
  if UDClassName <> '' then
    FDUDClassInd := K_GetUObjCIByTagName( UDClassName, false );
  ASBuf.GetTagAttr( 'RecSize', FDRecSize, K_isInteger );

  ASBuf.GetTagAttr( 'CurFVer', FDCurFVer, K_isInteger );
  ASBuf.GetTagAttr( 'NDPTVer', FDNDPTVer, K_isInteger );
  ASBuf.GetTagAttr( 'PDNTVer', FDPDNTVer, K_isInteger );

  ASBuf.GetTagAttr( 'NAFields', FDFieldsCount, K_isInteger );
  ASBuf.GetTagAttr( 'NFields', NParams, K_isInteger );
  SetLength( FDV, NParams );

  for i := 0 to NParams-1 do
  begin
    ASBuf.GetScalar( FDV[i].FieldName, K_isString );
    ASBuf.GetScalar( FDV[i].FieldPos, K_isInteger );
    ASBuf.GetScalar( FDV[i].FieldSize, K_isInteger );
    ASBuf.GetScalar( FDV[i].FieldType.DTCode, K_isInteger );
    ASBuf.GetScalar( FDV[i].FieldType.EFlags, K_isInteger );
    ASBuf.GetScalar( FDV[i].FieldDefValue, K_isString );
  end;
  Result := 0;
end; // procedure TK_UDFieldsDescr.GetFieldsFromText

//***************************************** TK_UDFieldsDescr.GetFieldTypeText ***
// Get Field Type Name
//
function TK_UDFieldsDescr.GetFieldTypeText(Ind: Integer): string;
begin

end; // function TK_UDFieldsDescr.GetFieldTypeText

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\GetFieldUName
//****************************************** TK_UDFieldsDescr.GetFieldUName ***
// Get Field Name or Field Default Value by field index
//
//     Parameters
// AInd   - field index
// Result - Returns resulting text (name or default value)
//
// Is used for view/edit elements of Sets and Enumerations
//
function TK_UDFieldsDescr.GetFieldUName( AInd: Integer ): string;
begin
  with FDV[AInd] do
    if FieldDefValue = '' then
      Result := FieldName
    else
      Result := FieldDefValue;
end; // function TK_UDFieldsDescr.GetFieldUName

//*************************************** TK_UDFieldsDescr.SaveToStrings ***
// save self to TStrings obj
//
procedure TK_UDFieldsDescr.SaveToStrings(Strings: TStrings; Mode: integer);
var
  i, NParams: integer;
  Str: string;
  Str0 : string;
begin
  inherited SaveToStrings( Strings, Mode );
  if K_fftUDRefs in FDFieldsTypesFlags then
    Str0 := 'R';
  if K_fftStrings in FDFieldsTypesFlags then
    Str0 := ' S';
  Str := '';
  if Str0 <> '' then
    Str := 'FF=['+Str0+'] ';
  Str := Str + Format(
  'ObjType=%d RecSize=%d FieldsCount=%d CurF=%d NDPT=%d PDNT=%d',
   [Ord(FDObjType), FDRecSize, FDFieldsCount, FDCurFVer, FDNDPTVer, FDPDNTVer] );
  Strings.Add( Str );

  NParams := Min( FDFieldsCount, Length(FDV) );
  for i := 0 to NParams-1 do
  begin
    Str := Format( '%d %s %s =(%s)', [ i, GetFieldTypeText( i ),
                                      FDV[i].FieldName, FDV[i].FieldDefValue ] );
    Strings.Add( Str );
  end;
  if Mode = 0 then Strings.Add( '' );
end; // procedure TK_UDFieldsDescr.SaveToStrings

//*************************************** TK_UDFieldsDescr.BuildFieldsExecDescr ***
// Build Fields Execute Description Structures
//
procedure TK_UDFieldsDescr.BuildFieldsExecDescr;
var
  Count : Integer;
begin
  if FDSHE <> nil then FDSHE.Free;
  FDSHE := THashedStringList.Create;
  if FDUDRefsIndsList = nil then
    FDUDRefsIndsList := TList.Create
  else
    FDUDRefsIndsList.Clear;
  Count := AddFieldsExecDescr( 0, '', 0, 0, FDVDE, FDSHE, FDUDRefsIndsList );
  SetLength( FDVDE, Count );
end; // procedure TK_UDFieldsDescr.BuildFieldsExecDescr

//*************************************** TK_UDFieldsDescr.AddFieldsExecDescr ***
// Build Fields Execute Description Structures
//
function TK_UDFieldsDescr.AddFieldsExecDescr( SInd : Integer; PName : string;
                TypeCFlags : Byte; SShift : Integer; var AVDE : TK_FDEArray;
                ASHE : THashedStringList; AUDRefsIndsList : TList ) : Integer;
var
  NCapacity, i, j, k : Integer;
  NName : string;
begin

  Result := SInd;
  if (SInd > 0) and (FDObjType <> K_fdtRecord) then Exit;
  NCapacity := Length(AVDE);
  j := SInd;
  k := Length(FDV);

  if (FDObjType < K_fdtEnum) and (FDObjType <> K_fdtTypeDef) then
    k := Min( FDFieldsCount, k );
  Dec(k);
  if PName <> '' then PName := PName + K_sccRecFieldDelim;

//*** Current Level Fields Loop ***
  for i := 0 to k do begin
    if NCapacity <= SInd then begin
      K_NewCapacity( SInd + 1, NCapacity );
      SetLength( AVDE, NCapacity );
    end;

    with FDV[i], AVDE[SInd] do begin
      DataName := FieldName;
      DataPos  := SShift + FieldPos;
      DataSize := FieldSize;
      NName := PName + DataName;
      ASHE.Add( NName );
      if ((FieldType.D.TFlags and K_ffFlagsMask) = 0) and
         ( (FieldType.DTCode = Ord(nptUDRef))         or
           ((FieldType.D.TFlags and K_ffVArray) <> 0) or
           ( ((FieldType.D.TFlags and K_ffArray) <> 0) and
             ( (FieldType.DTCode >= K_ffChildNum) or
               (FieldType.DTCode = Ord(nptNotDef) ) ) ) ) then begin
        AUDRefsIndsList.Add( Pointer(SInd) );
      end;
      DataType := FieldType;
      DataType.D.CFlags := DataType.D.CFlags or TypeCFlags;
      if FieldType.DTCode >= K_ffChildNum then begin
        DataType.DTCode := Integer( DirChild( FieldType.DTCode - K_ffChildNum ) );
        //*** if Field - ClassMethod then
        // DataType.DTCode - Method FieldsDescr
        // DataPos        - Method Pointer
        if (DataType.D.TFlags and K_ffClassMethod) <> 0 then begin //*** Class Method
          DataPos := DataType.DTCode;
          DataType.DTCode := Integer( TK_UDProgramItem(DataType.DTCode).DirChild(0) );
        end;
      end;
    end;
    Inc(SInd);
  end;

//*** Next Level Fields Loop ***
  for i := 0 to k do begin
    with FDV[i], AVDE[j] do
      if ((FieldType.D.TFlags and (K_ffFlagsMask or K_ffArray or K_ffVArray)) = 0) and
         (FieldType.DTCode >= K_ffChildNum) then
        SInd := DataType.FD.AddFieldsExecDescr( SInd, PName + DataName,
                  (TypeCFlags + FieldType.D.CFlags) and K_ccFlagsMask,
                  DataPos, AVDE, ASHE, AUDRefsIndsList );
    Inc(j);
  end;
  Result := SInd;

end; // procedure TK_UDFieldsDescr.AddFieldsExecDescr

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\CompareFuncTypes
//*************************************** TK_UDFieldsDescr.CompareFuncTypes ***
// Compare Function types (parameters and result type)
//
//     Parameters
// ASrcFD - SPL function type description object to compare
// Result - Returns TRUE if types are equal
//
function  TK_UDFieldsDescr.CompareFuncTypes( ASrcFD : TK_UDFieldsDescr ) : Boolean;
var
  i, k : Integer;
begin
  Result := false;
//  if (ObjType <> K_fdtRoutine) or (SrcFD.ObjType <> K_fdtRoutine) then Exit;
  if ((FDObjType <> K_fdtRoutine) and (FDObjType <> K_fdtClassConstructor)) or
     ((ASrcFD.FDObjType <> K_fdtRoutine) and (ASrcFD.FDObjType <> K_fdtClassConstructor)) then Exit;
  k := TK_UDProgramItem(Owner).ParamsCount;
  if k <> TK_UDProgramItem(ASrcFD.Owner).ParamsCount then Exit;
  for i := 0 to k-1 do begin
    with FDV[i] do begin
      if FieldType.All <> ASrcFD.FDV[i].FieldType.All then Exit;
      if (FieldType.DTCode >= K_ffChildNum) and
         (DirChild( FieldType.DTCode - K_ffChildNum ) <>
          DirChild( ASrcFD.FDV[i].FieldType.DTCode - K_ffChildNum )) then Exit;
    end
  end;
  Result := true;
end; // function TK_UDFieldsDescr.CompareFuncTypes

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\InitData
//*********************************************** TK_UDFieldsDescr.InitData ***
// Data initialization
//
//     Parameters
// AData - initializing data
// AGC   - SPL interpreter Global context for initialization script execution
//
// Do not call InitData directly, it is used automatically for SPL unit global 
// data initialization
//
procedure TK_UDFieldsDescr.InitData( var AData; AGC : TK_CSPLCont = nil );
var
  i, k : Integer;
  UDInit : TK_UDProgramItem;
  DType : TK_ExprExtType;
  PData : Pointer;
  InitGC : Boolean;
begin
  InitGC := (AGC = nil);
  AGC := K_PrepSPLRunGCont( AGC );
  if InitGC then begin
//*** create Root for Global UDObjects
    AGC.LocalUDRoot := self.AddOneChild( TN_UDBase.Create );
    AGC.LocalUDRoot.ObjName := 'GlobalDataUDRoot';
  end;
  k := Min( FDFieldsCount, Length(FDV) ) - 1;
  for i := 0 to k do
    with FDV[i] do begin
      if ((FieldType.D.TFlags and K_ffRoutineMask) = 0) and
         (FieldType.DTCode >= K_ffChildNum) then
        TK_UDFieldsDescr( DirChild( FieldType.DTCode - K_ffChildNum ) ).InitData(
                                  Pointer( TN_BytesPtr(@AData) + FieldPos )^, AGC );
//!!                                  Pointer( PChar(@AData) + FieldPos )^, AGC );

    end;

  i := IndexOfFieldDescr( K_sccInitDataProgName );
  if i <> -1 then begin
    UDInit := TK_UDProgramItem( GetFieldDescrByInd(i).DataPos );
    if (UDInit.ClassFlags and $FF) <> K_UDProgramItemCI then Exit;

  //*** Put Data Pointer to Stack
    DType.All := LongWord( Self );
    DType.D.TFlags := K_ffPointer;
    PData := @AData;
    AGC.PutDataToExprStack( PData, DType.All );
  //*** Execute Init Routine
    UDInit.SPLExecute( AGC );
  end;
  K_FreeSPLRunGCont( AGC );
end; // procedure TK_UDFieldsDescr.InitData

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\AddDataToSBuf
//****************************************** TK_UDFieldsDescr.AddDataToSBuf ***
// Add given Data Fields to given binary Serial Buffer
//
//     Parameters
// AData - given data for serialization
// ASBuf - given binary Serial Buffer
//
procedure TK_UDFieldsDescr.AddDataToSBuf( var AData; ASBuf: TN_SerialBuf );
var
  i, k : Integer;
//!!  PData : PChar;
  PData : TN_BytesPtr;
  FType: TK_ExprExtType;

begin
  // Add Data
  k := Min( FDFieldsCount, Length(FDV) ) - 1;
  if (FDObjType >= K_fdtEnum) then
    ASBuf.AddRowBytes ( FDRecSize, @AData )
  else
    for i := 0 to k do begin
      with FDV[i] do
        if ((FieldType.D.CFlags and (K_ccRuntime or K_ccObsolete or K_ccVariant)) = 0) then begin
//!!          PData := PChar(@AData) + FieldPos;
          PData := TN_BytesPtr(@AData) + FieldPos;
          if (FieldType.D.TFlags and (K_ffArray or K_ffFlagsMask)) = K_ffArray then
            TK_PRArray(PData)^.AddToSBuf( ASBuf )
          else if (FieldType.DTCode >= K_ffChildNum) then begin
            FType := FieldType;
            FType.DTCode := Integer(DirChild( FieldType.DTCode - K_ffChildNum ));
            if FieldType.D.TFlags = K_ffVArray then
              K_AddSPLDataToSBuf( PData^, FType, ASbuf )
            else
              FType.FD.AddDataToSbuf( PData^, ASbuf );
          end else // base type field
            K_AddSPLDataToSBuf( PData^, FieldType, ASBuf );
        end;
    end;

  // Add Self To UsedTypesList
  if FDFUTListInd <> 0 then Exit; // Is already added
  ASBuf.SBUsedTypesList.Add( Self );
  FDFUTListInd := ASBuf.SBUsedTypesList.Count;
end; // procedure TK_UDFieldsDescr.AddDataToSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\GetDataFromSBuf
//**************************************** TK_UDFieldsDescr.GetDataFromSBuf ***
// Get data from given binary Serial Buffer to given Data Fields
//
//     Parameters
// AData - given data for deserialization
// ASBuf - given binary Serial Buffer
//
procedure TK_UDFieldsDescr.GetDataFromSBuf( var AData; ASBuf: TN_SerialBuf );
var
  i, k : Integer;
//!!  PData : PChar;
  PData : TN_BytesPtr;
  FType: TK_ExprExtType;
begin
  k := Min( FDFieldsCount, Length(FDV) ) - 1;
  if (FDObjType >= K_fdtEnum) then
    ASBuf.GetRowBytes ( FDRecSize, @AData)
  else
    for i := 0 to k do
      with FDV[i] do begin
        try
          if ((FieldType.D.CFlags and (K_ccRuntime or K_ccObsolete or K_ccVariant)) = 0) then begin
//!!            PData := PChar(@AData) + FieldPos;
            PData := TN_BytesPtr(@AData) + FieldPos;
            if (FieldType.D.TFlags and (K_ffArray or K_ffFlagsMask)) = K_ffArray then begin // array
                TK_PRArray(PData)^ := TK_RArray.Create;
                TK_PRArray(PData)^.GetFromSbuf( ASBuf );
                if TK_PRArray(PData)^.ElemCount = -1 then begin
                  TK_PRArray(PData)^.Free;
                  TK_PRArray(PData)^ := nil;
                end;
            end else if (FieldType.DTCode >= K_ffChildNum) then begin
              FType := FieldType;
              FType.DTCode := Integer(DirChild( FieldType.DTCode - K_ffChildNum ));
              if FType.FD.CI = K_UDRefCI then // Special case SPL Root Loading
                TN_UDBase(FType.FD) := K_UDRefTable[FType.FD.RefIndex];

              if FieldType.D.TFlags = K_ffVArray then
                K_GetSPLDataFromSBuf( PData^, FType, ASbuf )
              else
                FType.FD.GetDataFromSbuf( PData^, ASbuf );
            end else // base type field
               K_GetSPLDataFromSBuf( PData^, FieldType, ASbuf );
          end;
        except
          On E: Exception do
            raise TK_LoadUDDataError.Create( '.'+FieldName+E.Message );
        end;
      end;
end; // procedure TK_UDFieldsDescr.GetDataFromSBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\AddDataToSTBuf
//***************************************** TK_UDFieldsDescr.AddDataToSTBuf ***
// Add given Data Fields to given Serial text Buffer
//
//     Parameters
// AData - given data for serialization
// ASBuf - given Serial text Buffer
//
procedure TK_UDFieldsDescr.AddDataToSTBuf( var AData; ASBuf: TK_SerialTextBuf );
var
  i, k : Integer;
//!!  PData : PChar;
  PData : TN_BytesPtr;
  FType: TK_ExprExtType;
  CompactMode : Boolean;
  FF : TN_BArray;
  SaveField : Boolean;
begin
  CompactMode := K_txtRACompact in K_TextModeFlags;
  k := Min( FDFieldsCount, Length(FDV) );
  SetLength( FF, k );
  Dec( k );
//**************************
//*** simple fields Loop ***
//**************************
  for i := 0 to k do begin
    with FDV[i] do
      if ((FieldType.D.CFlags and (K_ccRuntime or K_ccObsolete or K_ccVariant)) = 0)           and
         (((FieldType.D.CFlags and K_ccPrivate) = 0) or not (K_txtXMLMode in K_TextModeFlags)) and
         ( (FieldType.D.TFlags and (K_ffArray or K_ffVArray)) = 0 ) then begin
//!!        PData := PChar(@AData) + FieldPos;
        PData := TN_BytesPtr(@AData) + FieldPos;
        FType := FieldType;
        if FType.DTCode >= K_ffChildNum  then begin
          FType.FD := TK_UDFieldsDescr( DirChild( FieldType.DTCode - K_ffChildNum ) );
          if FType.FD.FDObjType < K_fdtEnum then Continue; // Is already added
        end;
        K_AddSPLDataToSTBuf( PData^, FType, ASBuf, FieldName, false );
        FF[i] := 1;
      end;
  end;
//***************************
//*** complex fields Loop ***
//***************************
  for i := 0 to k do begin
    with FDV[i] do
      if (FF[i] = 0) and
         ((FieldType.D.CFlags and (K_ccRuntime or K_ccObsolete or K_ccVariant)) = 0) and
         (((FieldType.D.CFlags and K_ccPrivate) = 0) or not (K_txtXMLMode in K_TextModeFlags)) then begin
//!!        PData := PChar(@AData) + FieldPos;
        PData := TN_BytesPtr(@AData) + FieldPos;
        if ((FieldType.D.TFlags and (K_ffArray or K_ffFlagsMask)) = K_ffArray) then begin
           if (TK_PRArray(PData)^ <> nil) or
               not CompactMode then
             TK_PRArray(PData)^.AddToSTBuf( ASBuf, FieldName{, (FieldType.DTCode = Ord(nptNotDef)) or not CompactMode} )
        end else begin
          FType := FieldType;
          SaveField := (FType.D.TFlags = K_ffVArray);
          if (FType.DTCode >= K_ffChildNum) then begin
          //*** Complex Field Not Enum/Set and VArray
            FType.FD := TK_UDFieldsDescr( DirChild( FieldType.DTCode - K_ffChildNum ) );
            with FType.FD do
              SaveField := SaveField or (FDObjType < K_fdtEnum);
          end;

          if SaveField and
             ( not CompactMode or
               not K_FieldIsEmpty( PData, FieldSize ) ) then begin
            ASBuf.AddTag( FieldName );
            if (FType.D.TFlags = K_ffVArray) then
              K_AddSPLDataToSTBuf( PData^, FType, ASBuf, 'Value', true )
            else
              FType.FD.AddDataToSTBuf( PData^, ASbuf );
            ASBuf.AddTag( FieldName, tgClose );
          end;
        end;
      end;
  end;

  // Add Self To UsedTypesList
  if FDFUTListInd <> 0 then Exit; // Is already added
  ASBuf.SBUsedTypesList.Add( Self );
  FDFUTListInd := ASBuf.SBUsedTypesList.Count;

end; // procedure TK_UDFieldsDescr.AddDataToSTBuf

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\GetDataFromSTBuf
//*************************************** TK_UDFieldsDescr.GetDataFromSTBuf ***
// Get data from given Serial text Buffer to given Data Fields
//
//     Parameters
// AData - given data for deserialization
// ASBuf - given Serial text Buffer
//
procedure TK_UDFieldsDescr.GetDataFromSTBuf( var AData; ASBuf: TK_SerialTextBuf );
var
  FSize, BufSize, BPos, i, k : Integer;
//!!  PData : PChar;
//!!  PBufData : PChar;
  PData : TN_BytesPtr;
  PBufData : TN_BytesPtr;

//  FD : TK_UDFieldsDescr;
  isObsolete : Boolean;
  WDType : TK_ExprExtType;
  FF : TN_BArray;
  WRA : TK_RArray;
  LoadField : Boolean;

  procedure GetFieldAttrs;
  begin
    with FDV[i] do begin
      WDType := FieldType;
      isObsolete := ((WDType.D.CFlags and K_ccObsolete) <> 0);
//!!      PData := PChar(@AData) + FieldPos;
      PData := TN_BytesPtr(@AData) + FieldPos;
    end;
  end;

  procedure BuildTypeCode;
  begin
    WDType.DTCode := Integer( DirChild( WDType.DTCode - K_ffChildNum ) );
  end;

  procedure IniObsoleteBuffer;
  begin
    FSize := K_GetExecTypeSize( WDType.All );
    if FSize > BufSize then begin
      BufSize := FSize;
      ReallocMem( PBufData, BufSize );
    end;
    FillChar( PBufData^, FSize, 0 );
    WDType.D.CFlags := WDType.D.CFlags - K_ccObsolete;
    PData := PBufData;
  end;

  procedure OnException( FieldStr, ErrStr : string );
  begin
    ReallocMem( PBufData, 0 );
    if (ErrStr = '') or (ErrStr[1] <> '.') then ErrStr := ': ' + ErrStr;
    raise TK_LoadUDDataError.Create( '.'+FieldStr + ErrStr );
  end;

begin
  PBufData := nil;
  BufSize := 0;
  k := Min( FDFieldsCount, Length(FDV) );
  SetLength( FF, k );
  Dec( k );
//**************************
//*** simple fields Loop ***
//**************************
  for i := 0 to k do
    with FDV[i] do begin
      try
        if ((FieldType.D.CFlags and K_ccRuntime) = 0) and
           ( (FieldType.D.TFlags and (K_ffArray or K_ffVArray)) = 0 ) then begin
          GetFieldAttrs;

          if FieldType.DTCode >= K_ffChildNum then begin
            BuildTypeCode;
            with WDType.FD do
              if (FDObjType < K_fdtEnum) then Continue;
          end;
          if isObsolete then IniObsoleteBuffer;
          K_GetSPLDataFromSTBuf( PData^, WDType, ASBuf, FieldName, false );
          FF[i] := 1;
          if isObsolete then
            K_FreeSPLData( PData^, WDType.All, true );
        end;
      except
        On E: Exception do OnException( FieldName, E.Message );
      end;
    end;
//***************************
//*** complex fields Loop ***
//***************************
  for i := 0 to k do
    with FDV[i] do
    begin
      try
        if (FF[i] = 0) and ((FieldType.D.CFlags and K_ccRuntime) = 0) then
        begin
          GetFieldAttrs;
          if (FieldType.D.TFlags and (K_ffArray or K_ffFlagsMask)) = K_ffArray then begin
          //*** TK_RArray Field Load
            WRA := TK_RArray.Create;
            with WRA do
            begin
              ElemCount := -1;
              if (FieldType.DTCode >= K_ffChildNum) then BuildTypeCode;
              FEType.DTCode := WDType.DTCode;
              GetFromSTBuf( ASBuf, FieldName );
              if ElemCount = -1 then
                Free
              else if not isObsolete then
                TK_PRArray(PData)^ := WRA;
            end;
          //*** end of TK_RArray Load
          end else
          begin
          //*** VArray or Complex Type Field Load
            LoadField := (FieldType.D.TFlags = K_ffVArray);

            if (FieldType.DTCode >= K_ffChildNum) then
            begin
              BuildTypeCode;
              with WDType.FD do
                LoadField := LoadField or (FDObjType < K_fdtEnum);
            end;

            if LoadField then
            begin
              ASBuf.GetBufPos( BPos );
              if ASBuf.GetSpecTag( FieldName, tgOpen, false ) then
              begin
                if isObsolete then
                begin
                  IniObsoleteBuffer;
                  FF[i] := 2;
                end;
                if (FieldType.D.TFlags = K_ffVArray) then
                  K_GetSPLDataFromSTBuf( PData^, WDType, ASBuf, 'Value', true )
                else
                  WDType.FD.GetDataFromSTBuf( PData^, ASbuf );
                ASBuf.GetSpecTag( FieldName, tgClose );
              end else
                ASBuf.SetBufPos( BPos );
            end;
          //*** end of VArray or Complex Type Field Load
          end;
          if FF[i] = 2 then
          begin
            K_FreeSPLData( PData^, WDType.All, true );
          end;
        end;
      except
        On E: Exception do OnException( FieldName, E.Message );
      end;
    end;
  if PBufData <> nil then ReallocMem( PBufData, 0 );

end; // procedure TK_UDFieldsDescr.GetDataFromSTBuf

{ !!! 2011-09-14 version - couldn't read fields changed to
procedure TK_UDFieldsDescr.GetDataFromSTBuf( var AData; ASBuf: TK_SerialTextBuf );
var
  FSize, BufSize, BPos, i, k : Integer;
//!!  PData : PChar;
//!!  PBufData : PChar;
  PData : TN_BytesPtr;
  PBufData : TN_BytesPtr;

//  FD : TK_UDFieldsDescr;
  isObsolete : Boolean;
  WDType : TK_ExprExtType;
  FF : TN_BArray;
  WRA : TK_RArray;
  LoadField : Boolean;

  procedure GetFieldAttrs;
  begin
    with FDV[i] do begin
      WDType := FieldType;
      isObsolete := ((WDType.D.CFlags and K_ccObsolete) <> 0);
//!!      PData := PChar(@AData) + FieldPos;
      PData := TN_BytesPtr(@AData) + FieldPos;
    end;
  end;

  procedure BuildTypeCode;
  begin
    WDType.DTCode := Integer( DirChild( WDType.DTCode - K_ffChildNum ) );
  end;

  procedure IniObsoleteBuffer;
  begin
    FSize := K_GetExecTypeSize( WDType.All );
    if FSize > BufSize then begin
      BufSize := FSize;
      ReallocMem( PBufData, BufSize );
    end;
    FillChar( PBufData^, FSize, 0 );
    WDType.D.CFlags := WDType.D.CFlags - K_ccObsolete;
    PData := PBufData;
  end;

  procedure OnException( ErrStr : string );
  begin
    ReallocMem( PBufData, 0 );
    raise TK_LoadUDDataError.Create( ErrStr );
  end;

begin
  PBufData := nil;
  BufSize := 0;
  k := Min( FDFieldsCount, Length(FDV) );
  SetLength( FF, k );
  Dec( k );
//**************************
//*** simple fields Loop ***
//**************************
  for i := 0 to k do
    with FDV[i] do begin
      try
        if ((FieldType.D.CFlags and K_ccRuntime) = 0) and
           ( (FieldType.D.TFlags and (K_ffArray or K_ffVArray)) = 0 ) then begin
          GetFieldAttrs;

          if FieldType.DTCode >= K_ffChildNum then begin
            BuildTypeCode;
            with WDType.FD do
              if (FDObjType < K_fdtEnum) then Continue;
          end;
          if isObsolete then IniObsoleteBuffer;
          K_GetSPLDataFromSTBuf( PData^, WDType, ASBuf, FieldName, false );
          FF[i] := 1;
          if isObsolete then
            K_FreeSPLData( PData^, WDType.All, true );
        end;
      except
        On E: Exception do OnException( '.'+FieldName+E.Message );
      end;
    end;
//***************************
//*** complex fields Loop ***
//***************************
  for i := 0 to k do
    with FDV[i] do
    begin
      try
        if (FF[i] = 0) and ((FieldType.D.CFlags and K_ccRuntime) = 0) then
        begin
          GetFieldAttrs;
          if (FieldType.D.TFlags and (K_ffArray or K_ffFlagsMask)) = K_ffArray then begin
          //*** TK_RArray Field Load
            WRA := TK_RArray.Create;
            with WRA do
            begin
              ElemCount := -1;
              if (FieldType.DTCode >= K_ffChildNum) then BuildTypeCode;
              FEType.DTCode := WDType.DTCode;
              GetFromSTBuf( ASBuf, FieldName );
              if ElemCount = -1 then
                Free
              else if not isObsolete then
                TK_PRArray(PData)^ := WRA;
            end;
          //*** end of TK_RArray Load
          end else
          begin
          //*** VArray or Complex Type Field Load
            LoadField := (FieldType.D.TFlags = K_ffVArray);

            if (FieldType.DTCode >= K_ffChildNum) then
            begin
              BuildTypeCode;
              with WDType.FD do
                LoadField := LoadField or (FDObjType < K_fdtEnum);
            end;

            if LoadField then
            begin
              ASBuf.GetBufPos( BPos );
              if ASBuf.GetSpecTag( FieldName, tgOpen, false ) then
              begin
                if isObsolete then
                begin
                  IniObsoleteBuffer;
                  FF[i] := 2;
                end;
                if (FieldType.D.TFlags = K_ffVArray) then
                  K_GetSPLDataFromSTBuf( PData^, WDType, ASBuf, 'Value', true )
                else
                  WDType.FD.GetDataFromSTBuf( PData^, ASbuf );
                ASBuf.GetSpecTag( FieldName, tgClose );
              end else
                ASBuf.SetBufPos( BPos );
            end;
          //*** end of VArray or Complex Type Field Load
          end;
          if FF[i] = 2 then
          begin
            K_FreeSPLData( PData^, WDType.All, true );
          end;
        end;
      except
        On E: Exception do OnException( '.'+FieldName+E.Message );
      end;
    end;
  if PBufData <> nil then ReallocMem( PBufData, 0 );

end; // procedure TK_UDFieldsDescr.GetDataFromSTBuf
}
//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\CompareData
//******************************************** TK_UDFieldsDescr.CompareData ***
// Compare SPL data using Self type description
//
//     Parameters
// AData1     - first compared data field
// AData2     - second compared data field
// ASPath     - path to compared data in SPL complex type tree
// ACompFlags - compare flags set
//
function TK_UDFieldsDescr.CompareData( const AData1, AData2; ASPath : string;
                               ACompFlags : TK_CompDataFlags = [] ) : Boolean;
var
  i, k : Integer;
//!!  PSData, PDData : PChar;
  PSData, PDData : TN_BytesPtr;
  NPath : string;
begin
  Result := true;
  if FDObjType >= K_fdtEnum then begin
    if not CompareMem( @AData1, @AData2, FDRecSize ) then begin
      Result := false;
      if (K_cdfBuildErrList in ACompFlags) then
        K_AddCompareErrInfo( '"'+ASPath+'" not equal' );
    end;
  end else begin
    k := Min( FDFieldsCount, Length(FDV) ) - 1;
    for i := 0 to k do begin
      if not Result and K_CompareStopFlag then Exit;
      with FDV[i] do begin
//!!        PSData := PChar(@AData1) + FieldPos;
//!!        PDData := PChar(@AData2) + FieldPos;
        PSData := TN_BytesPtr(@AData1) + FieldPos;
        PDData := TN_BytesPtr(@AData2) + FieldPos;
        NPath := ASPath + K_sccRecFieldDelim + FieldName;
        if (FieldType.D.TFlags and (K_ffArray or K_ffFlagsMask)) = K_ffArray then
          Result := TK_PRArray(PSData)^.CompareData( TK_PRArray(PDData)^, NPath )
        else if (FieldType.DTCode >= K_ffChildNum) then
          Result := TK_UDFieldsDescr(
                DirChild( FieldType.DTCode - K_ffChildNum ) ).CompareData(
                                  PSData^ ,PDData^, NPath )
        else // base type field
          Result := K_CompareSPLData( PSData^, PDData^, FieldType, NPath, ACompFlags );
      end;
    end;
  end;
end; // procedure TK_UDFieldsDescr.CompareData

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\CreateUDInstance
//*************************************** TK_UDFieldsDescr.CreateUDInstance ***
// Create Instance of SPL class
//
//     Parameters
// ACount - number of elements in new records array
// Result - Returns Instance of SPL class
//
// Creates IDB object with build in array of records of Self type
//
function TK_UDFieldsDescr.CreateUDInstance( ACount : Integer = 1 ) : TK_UDRArray;
begin
  Result := K_CreateUDByRTypeCode( Integer(Self), ACount, FDUDClassInd );
end; // procedure TK_UDFieldsDescr.CreateUDInstance

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\ValueFromString
//**************************************** TK_UDFieldsDescr.ValueFromString ***
// Parse SPL data from given string according to self type data structure
//
//     Parameters
// AData  - resulting SPL data
// ACText - source text for parsing
// Result - Returns empty string if OK or parsing error info string.
//
function TK_UDFieldsDescr.ValueFromString( var AData; ACText : string ) : string;
var
  i, k : Integer;
//!!  PData : PChar;
  PData : TN_BytesPtr;
  PFD : TK_POneFieldExecDescr;
  PrevText : string;
  PrevPos  : Integer;
  EnumBuf  : Integer;
  SetMemberInd : Integer;
  SetMemberName : string;
  SetBuf : TN_BArray;
  SetBufInd : Integer;
begin
  Result := '';
  if FDObjType = K_fdtEnum then begin
    EnumBuf := IndexOfFieldDescr( ACText );
    if EnumBuf = -1 then begin
      if ACText <> '' then
        Result := ' while parsing "'+ACText+'"';
    end else
      Move( GetFieldDescrByInd(EnumBuf).DataPos, AData, FDRecSize );
  end else begin
    with K_ScriptLDDataTokenizer do begin
      PrevText := Text;
      PrevPos := CPos;
      if FDObjType = K_fdtSet then begin
        ACText := Trim(ACText);
        SetLength( SetBuf, FDRecSize );
        SetMemberInd := Length(ACText);
        if ACText <> '' then begin
          if (ACText[1] <> K_sccStartIndex) or
             (ACText[SetMemberInd] <> K_sccFinIndex) then begin
            Result := ' while parsing "'+ACText+'"';
          end else begin
            ACText := Copy( ACText, 2, SetMemberInd - 2 );
            setSource( ACText );
            while hasMoreTokens(true) do begin
              SetMemberName := nextToken(true);
              SetMemberInd := IndexOfFieldDescr( SetMemberName );
              if SetMemberInd = -1 then begin
                Result := ' while parsing "'+SetMemberName+'"';
                break;
              end else
                SetMemberInd := GetFieldDescrByInd(SetMemberInd).DataPos;
              SetBufInd := SetMemberInd shr 5;
              SetMemberInd := SetMemberInd and $1F;
              PInteger(@SetBuf[SetBufInd])^ := PInteger(@SetBuf[SetBufInd])^ + (1 shl SetMemberInd);
            end;
          end;
        end;
        Move( SetBuf[0], AData, FDRecSize );
      end else begin
        setSource( ACText );
        k := Min( FDFieldsCount, Length(FDV) ) - 1;
        for i := 0 to k do begin
          PFD := GetFieldDescrByInd( i );
          with PFD^, DataType do begin
            if (D.CFlags and (K_ccObsolete or K_ccVariant) ) <> 0 then continue;
//!!            PData := PChar(@AData) + DataPos;
            PData := TN_BytesPtr(@AData) + DataPos;
            Result := K_SPLValueFromString( Pointer(PData)^, All, nextToken() );
            if Result <> '' then begin
              Result := '.'+DataName+' '+Result;
              break;
            end;
{
            if (PFD.DataType.D.CFlags and K_ccObsolete) <> 0 then Continue;
            PData := PChar(@AData) + PFD.DataPos;
            Result := K_SPLValueFromString( Pointer(PData)^, PFD.DataType.All, nextToken() );
            if Result <> '' then begin
              Result := '.'+PFD.DataName+' '+Result;
              break;
            end;
}
          end;
        end;
      end;

      setSource( PrevText );
      setPos( PrevPos );
    end;
    if Result <> '' then Result := 'while parsing type ->' + ObjName + Result;
  end;
end; // procedure TK_UDFieldsDescr.ValueFromString

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\ValueToString
//****************************************** TK_UDFieldsDescr.ValueToString ***
// Convert SPL data to string according to self type data structure
//
//     Parameters
// AData            - converting SPL data
// AValueToStrFlags - SPL value to string convertion flags
// ASTK             - string tokenizer object (used to accumulate resulting text
//                    if <>NIL, else Text to resulting string ) data will be 
//                    added to tokenizer text buffer (not to resulting 
//                    string!!!)
// AStrLen          - resulting string maximal length (if =0 then no constraint 
//                    on resulting string length is used)
// AFFLags          - SPL type flags value for data fields filtering
// AFMask           - SPL type flags mask value for data fields filtering
// Result           - Returns string with Records Array Elements values text 
//                    representation if ASTK = nil, or add text values to ASTK 
//                    text buffer
//
// If fields filtering is done then only fields which SPL type flags value are 
// satisfied to condition
//#F
//    ((TK_ExprExtType.EFLags xor AFFLags) and AFMask) <> 0
//#/F
//
// will be converted to text.
//
function TK_UDFieldsDescr.ValueToString( const AData; AValueToStrFlags : TK_ValueToStrFlags = [];
                           ASTK : TK_Tokenizer = nil; AStrLen : Integer=0;
                           AFFLags : Integer = 0; AFMask : Integer = 0 ) : string;
var
  i, k, n, m : Integer;
//!!  PData : PChar;
  PData : TN_BytesPtr;
  PFD : TK_POneFieldExecDescr;
  WSTK : TK_Tokenizer;
  SetEnumBuf  : TN_BArray;
  BB : Byte;
  NotEmptySet : Boolean;
//  EnumBuf : Integer;
  label FinSet;
begin
  k := Min( FDFieldsCount, Length(FDV) ) - 1;
  if ASTK = nil then begin
    WSTK := K_ScriptLDDataTokenizer;
    WSTK.setSource( '' );
  end else
    WSTK := ASTK;

  if (FDObjType >= K_fdtEnum)  then begin
    SetLength( SetEnumBuf, Max( FDRecSize, SizeOf(Integer) ) );
    Move( AData, SetEnumBuf[0], FDRecSize );
    if FDObjType = K_fdtEnum then begin
      WSTK.addToken( FDV[PInteger(@SetEnumBuf[0])^].FieldName, K_ttToken )
    end else begin
      WSTK.addToken( '[', K_ttString );
      WSTK.shiftPos(-1);
      m := 0;
      NotEmptySet := false;
      for n := 0 to FDRecSize - 1 do begin
        BB := SetEnumBuf[n];
        for i := 0 to 7 do begin
          if m > k then goto FinSet;
          if BB = 0 then begin
            Inc( m, 8 - i);
            break;
          end else begin
            if (BB and 1) <> 0 then begin
              WSTK.addToken( FDV[m].FieldName, K_ttToken );
              NotEmptySet := true;
            end;
            BB := BB shr 1;
            Inc( m );
          end;
        end;
      end;
FinSet:
      if NotEmptySet then
        WSTK.shiftPos(-1);
      WSTK.addToken( ']', K_ttString );
    end;
  end else
    for i := 0 to k do begin
      PFD := GetFieldDescrByInd( i );
      with PFD^, DataType do begin

        if ((D.CFlags and (K_ccObsolete or K_ccVariant) ) <> 0) or
           (((EFLags.All xor AFFlags) and AFMask) <> 0) then continue;
        if K_svsShowName in AValueToStrFlags then begin
          WSTK.addToken(DataName+':');
          WSTK.shiftPos(-1);
        end;

//!!        PData := PChar(@AData) + DataPos;
        PData := TN_BytesPtr(@AData) + DataPos;

        K_ValueToStringBuf( PData^, DataType,
           ( ((D.TFlags and (K_ffArray or K_ffFlagsMask)) = K_ffArray) or
             ((DTCode > Ord(nptNoData)) and ((FD.FDObjType < K_fdtEnum) or (FD.FDObjType = K_fdtSet))) ),
           WSTK, AValueToStrFlags, AStrLen, AFFlags, AFMask );
      end;

      if K_svsShowName in AValueToStrFlags then begin
        WSTK.shiftPos(-1);
        WSTK.addToken(';');
      end;
      if (AStrLen > 0) and (WSTK.Cpos > AStrLen) then break;

    end;

  if ASTK = nil then
    with WSTK do
      Result := Copy( Text, 1, CPos - 2 )
//      Result := Copy( Text, 1, CPos - 1 )
  else
    Result := '';
end; // function TK_UDFieldsDescr.ValueToString

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\FieldsListToString
//************************************* TK_UDFieldsDescr.FieldsListToString ***
// Convert SPL data fields given by field names array to text
//
//     Parameters
// AData            - converting SPL data
// AFieldsList      - array of field names or text constants added to resulting 
//                    text
// AValueToStrFlags - SPL value to string convertion flags
// AFFLags          - SPL type flags value for data fields filtering
// AFMask           - SPL type flags mask value for data fields filtering
// Result           - Returns SPL data text representation
//
// If fields filtering is done then only fields which SPL type flags value are 
// satisfied to condition
//#F
//    ((TK_ExprExtType.EFLags xor AFFLags) and AFMask) <> 0
//#/F
//
// will be converted to text.
//
// AFieldsList item format:
//#F
//  if FieldsList[i][1] = '#' then next is FieldName #<FieldName>
//  if FieldsList[i][1] <> '#' then next is text that will be added to Result
//#/F
//
function TK_UDFieldsDescr.FieldsListToString( const AData; AFieldsList : TN_SArray;
              AValueToStrFlags : TK_ValueToStrFlags = [];
              AFFLags : Integer = 0; AFMask : Integer = 0 ) : string;
var
  i, k : Integer;
//!!  PData : PChar;
  PData : TN_BytesPtr;
  PFD : TK_POneFieldExecDescr;
  WSTK : TK_Tokenizer;
  FieldName : string;
begin
  if (FDObjType = K_fdtEnum) or (FDObjType = K_fdtSet) then
    Result := ValueToString( AData )
  else begin
    WSTK := K_ScriptLDDataTokenizer;
    WSTK.setSource( '' );
    k := High(AFieldsList);
    for i := 0 to k do begin
      FieldName := AFieldsList[i];
      if FieldName[1] <> '#' then begin
        WSTK.shiftPos(-1);
        WSTK.addToken( FieldName, K_ttString );
        WSTK.shiftPos(-1);
      end else begin
        PFD := GetFieldDescrByInd( IndexOfFieldDescr( Copy( FieldName, 2, Length(FieldName) ) ) );
        with PFD^, DataType do begin
          if ((EFLags.All xor AFFlags) and AFMask) <> 0 then continue;
//!!          PData := PChar(@AData) + DataPos;
          PData := TN_BytesPtr(@AData) + DataPos;
          K_ValueToStringBuf( PData^, DataType,
             ( ((D.TFlags and (K_ffArray or K_ffFlagsMask)) = K_ffArray) or
               ((DTCode > Ord(nptNoData)) and ((FD.FDObjType < K_fdtEnum) or (FD.FDObjType = K_fdtSet))) ),
             WSTK, AValueToStrFlags, 0, AFFlags, AFMask );
        end;
      end;
    end;
    with WSTK do
      Result := Copy( Text, 1, CPos - 1 )
  end;

end; // function TK_UDFieldsDescr.FieldsListToString

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\MoveData
//*********************************************** TK_UDFieldsDescr.MoveData ***
// Move SPL data according to self type data structure
//
//     Parameters
// ASData   - source SPL data value
// ADData   - destination SPL data value
// AMDFlags - move SPL data structure flags
//
procedure TK_UDFieldsDescr.MoveData( const ASData; var ADData; AMDFlags : TK_MoveDataFlags = [] );
var
  i, k : Integer;
//  WSData : PChar;
//  WDData : PChar;
  PFD : TK_POneFieldExecDescr;

begin

  k := Min( FDFieldsCount, Length(FDV) ) - 1;
  for i := 0 to k do begin
    PFD := GetFieldDescrByInd( i );
//    WSData := PChar(@SData) + PFD.DataPos;
//    WDData := PChar(@DData) + PFD.DataPos;
//    K_MoveSPLData( Pointer(WSData)^, Pointer(WDData)^, PFD.DataType, ClearDest );
    if ((PFD.DataType.D.CFlags and (K_ccObsolete or K_ccVariant)) = 0) and
       ((PFD.DataType.D.TFlags and K_ffClassMethod) = 0) then
//!!      K_MoveSPLData( (PChar(@ASData) + PFD.DataPos)^, (PChar(@ADData) + PFD.DataPos)^,
      K_MoveSPLData( (TN_BytesPtr(@ASData) + PFD.DataPos)^,
                     (TN_BytesPtr(@ADData) + PFD.DataPos)^,
                     PFD.DataType, AMDFlags );

 end;

end; // procedure TK_UDFieldsDescr.MoveData

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\FreeData
//*********************************************** TK_UDFieldsDescr.FreeData ***
// Free given SPL data according to self type data structure
//
//     Parameters
// AData       - SPL data value
// ASInd       - start field index in type description
// ACountUDRef - if =TRUE then IDB objects references counting is permited
//
procedure TK_UDFieldsDescr.FreeData( var AData; ASInd : Integer = 0; ACountUDRef : Boolean = false );
var
  i, k : Integer;
  PFD : TK_POneFieldExecDescr;

begin
  if (FDObjType = K_fdtEnum) or
     (FDObjType = K_fdtSet) then Exit;
  k := Min( FDFieldsCount, Length(FDV) ) - 1;
  for i := ASInd to k do begin
    PFD := GetFieldDescrByInd( i );
    with PFD.DataType do
{ // Replaced 18.07.2006
      if ((D.CFlags and (K_ccObsolete or K_ccVariant)) <> 0) or
         ((D.TFlags and  K_ffClassMethod) <> 0)              or
         ((DTCode > Ord(nptNoData)) and (Ord(FD.ObjType) >= Ord(K_fdtEnum))) then Continue;
}
      if ((D.CFlags and (K_ccObsolete or K_ccVariant)) <> 0) or
         ((D.TFlags and  K_ffRoutineMask) <> 0) then Continue;
//!!    K_FreeSPLData( (PChar(@AData) + PFD.DataPos)^, PFD.DataType.All, ACountUDRef );
    K_FreeSPLData( (TN_BytesPtr(@AData) + PFD.DataPos)^, PFD.DataType.All, ACountUDRef );

  end;

end; // procedure TK_UDFieldsDescr.FreeData

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\GetFieldsDefValueList
//********************************** TK_UDFieldsDescr.GetFieldsDefValueList ***
// Get Fields Names or Default Values by given fields indexes
//
//     Parameters
// ASL        - strings for resulting data
// APInds     - pointer to first element in fields indexes array (if =NIL, then 
//              all fields are used)
// AIndsCount - needed fields counter
//
// Is used for view/edit elements of Sets and Enumerations
//
procedure TK_UDFieldsDescr.GetFieldsDefValueList( ASL : TStrings; APInds : PInteger = nil;
                                                  AIndsCount : Integer = 0 );
var
  h, j, i : Integer;
begin
  if Integer(Self) < Ord(nptNoData) then Exit;
  if APInds = nil then
    h := FDFieldsCount - 1
  else
    h := AIndsCount - 1;

  for j := 0 to h do begin
    if APInds = nil then
      i := j
    else
//!!      i := PInteger(PChar(APInds) + j * SizeOf(Integer))^;
      i := PInteger(TN_BytesPtr(APInds) + j * SizeOf(Integer))^;

    ASL.Add( GetFieldUName(i) );
  end;
end; // procedure TK_UDFieldsDescr.GetFieldsDefValueList

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\GetFieldsExecDescr
//************************************* TK_UDFieldsDescr.GetFieldsExecDescr ***
// Get SPL record tree leaf fields descriptions array (Runtime)
//
//     Parameters
// Result - Returns array of fields descriptions
//
function TK_UDFieldsDescr.GetFieldsExecDescr: TK_FDEArray;
begin
  if FDVDE = nil then BuildFieldsExecDescr;
  Result := FDVDE;
end; // procedure TK_UDFieldsDescr.GetFieldsExecDescr

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\GetFieldDescrByInd
//************************************* TK_UDFieldsDescr.GetFieldDescrByInd ***
// Get SPL Type Field Description by given Field Index
//
//     Parameters
// AInd   - field index in type description
// Result - Returns pointer to SPL Type Field Description
//
function TK_UDFieldsDescr.GetFieldDescrByInd( AInd : Integer) : TK_POneFieldExecDescr;
begin
  if FDVDE = nil then BuildFieldsExecDescr();
  Result := nil;
  if (AInd >= 0) and (AInd < Length(FDVDE)) then
    Result := @FDVDE[AInd];
end; // function TK_UDFieldsDescr.GetFieldDescrByInd

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\GetFieldFullNameByInd
//********************************** TK_UDFieldsDescr.GetFieldFullNameByInd ***
// Get SPL Type Field full name by given Field Index
//
//     Parameters
// AInd   - field index in type description
// Result - Returns SPL Type Field full name
//
function TK_UDFieldsDescr.GetFieldFullNameByInd( AInd : Integer) : string;
begin
  if FDVDE = nil then BuildFieldsExecDescr;
  Result := '';
  if (AInd >= 0) and (AInd < Length(FDVDE)) then
    Result := FDSHE[AInd];
end; // function TK_UDFieldsDescr.GetFieldFullNameByInd

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\IndexOfFieldDescr
//************************************** TK_UDFieldsDescr.IndexOfFieldDescr ***
// Search SPL Type Field Index by Full Name
//
//     Parameters
// AFieldName - field full name
// Result     - Returns Field index in SPL Type description
//
function TK_UDFieldsDescr.IndexOfFieldDescr( AFieldName: string ): Integer;
begin
  if FDSHE = nil then BuildFieldsExecDescr;
  Result := FDSHE.IndexOf(AFieldName);
end; // procedure TK_UDFieldsDescr.IndexOfFieldDescr

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\RefreshFieldsExecDescr
//********************************* TK_UDFieldsDescr.RefreshFieldsExecDescr ***
// Clear Runtime structures for future rebuild if needed
//
procedure TK_UDFieldsDescr.RefreshFieldsExecDescr;
begin
  FreeAndNil( FDSHE );
  FDVDE := nil;
  FreeAndNil( FDUDRefsIndsList );
end; // procedure TK_UDFieldsDescr.RefreshFieldsExecDescr

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\AddOneFieldDescr
//*************************************** TK_UDFieldsDescr.AddOneFieldDescr ***
// Add new SPL Type Element Description
//
//     Parameters
// AElemName      - new element name
// AElemTypeCode  - new element type code
// AElemTypeFlags - new element type flags
// AElemPos       - element position in record (if =-1 then add exactly after 
//                  last element, if =-2 then new element will have same 
//                  position as previous field (variant))
// AElemSize      - element size in bytes
// Result         - Returns Field index in SPL Type description
//
// Do not call AddOneFieldDescr directly, it is used automatically by SPL 
// compiler
//
function TK_UDFieldsDescr.AddOneFieldDescr ( AElemName : string;
        AElemTypeCode : Integer; AElemTypeFlags: Integer = 0;
        AElemPos : Integer = -1; AElemSize : Integer = -1 ) : Integer;
var
  NCapacity : Integer;
begin
  Result := FDFieldsCount;
  if AElemName = '' then begin //*** Close Record Description
    FDRecSize := Max( AElemPos, FDRecSize );
    SetLength( FDV, FDFieldsCount );
  end else begin              //*** Add New Description
    NCapacity := Length(FDV);
    Inc(FDFieldsCount);
    if K_NewCapacity( FDFieldsCount, NCapacity ) then
      SetLength( FDV, NCapacity );
    with FDV[Result] do begin
      FieldName := AElemName;
      if AElemPos = -1 then AElemPos := FDRecSize
      else if AElemPos = -2 then begin
        if Result > 0 then
          AElemPos := FDRecSize - FDV[Result-1].FieldSize
        else
          AElemPos := 0;
      end;
      FieldPos := AElemPos;
      FieldType.DTCode := AElemTypeCode;
      FieldType.EFlags.All := AElemTypeFlags and K_ectClearFIFlags;
      if (TK_ExprTypeFlags(AElemTypeFlags).TFlags and K_ffFlagsMask) <> 0 then
        FieldType.D.CFlags := FieldType.D.CFlags or K_ccRuntime;
      if AElemSize = -1 then
        FieldSize := K_GetExecTypeSize( FieldType.All )
      else
        FieldSize := AElemSize;
      LinkFieldDescrType( Result );
      AElemPos := AElemPos + FieldSize;
      FDRecSize := Max( FDRecSize, AElemPos );
    end;
  end;

end; // function TK_UDFieldsDescr.AddOneFieldDescr

//##path K_Delphi\SF\K_clib\K_Script1.pas\TK_UDFieldsDescr\ChangeFieldType
//**************************************** TK_UDFieldsDescr.ChangeFieldType ***
// Change SPL type of element given by its index
//
//     Parameters
// AInd           - element index
// AElemTypeCode  - element new type code
// AElemTypeFlags - element new type flags
//
// Do not call ChangeFieldType directly, it is used automatically by SPL 
// compiler
//
procedure TK_UDFieldsDescr.ChangeFieldType ( AInd : Integer;
        AElemTypeCode : Integer; AElemTypeFlags: Integer = 0 );
var
  DSize : Integer;
  NSize : Integer;
  i, k : Integer;
begin

  with FDV[AInd] do begin
    FieldType.DTCode := AElemTypeCode;
    FieldType.EFlags.All := AElemTypeFlags and K_ectClearFIFlags;
    NSize := K_GetExecTypeSize( FieldType.All );
    DSize := NSize - FieldSize;
    FieldSize := NSize;
    LinkFieldDescrType( AInd );
  end;
  k := Min( FDFieldsCount, Length(FDV) ) - 1;
  for i := AInd + 1 to k do
    with FDV[i] do Inc( FieldPos, DSize );
  Inc( FDRecSize, DSize );
end; // function TK_UDFieldsDescr.ChangeFieldType


//*************************************** TK_UDFieldsDescr.LinkFieldDescrType ***
// Set Field Description Type
//
procedure TK_UDFieldsDescr.LinkFieldDescrType( Ind : Integer );
var
  DataTypeCode : Integer;
begin

  with FDV[Ind] do begin
    if FieldType.DTCode >= Ord(nptNoData) then begin //*** Build in Type
      DataTypeCode := FieldType.DTCode;
      FieldType.DTCode := IndexOfDEField( DataTypeCode );
      if FieldType.DTCode = -1 then
        FieldType.DTCode := InsOneChild( -1, TN_UDBase(DataTypeCode) );
      Inc(FieldType.DTCode,  K_ffChildNum);
    end;
  end;

end; // function TK_UDFieldsDescr.LinkFieldDescrType

{*** end of TK_UDFieldsDescr ***}

//*************************************** K_InitGlobContByRFrame ***
// Initialize given GlobCont by given RFrame (of TN_Rast1Frame type)
// (RFrame shoul alraedy been initialized)
//
procedure K_InitGlobContByRFrame( AGlobCont: TK_CSPLCont; ARFrame: TObject );
begin
{
  with TN_Rast1Frame(ARFrame) do
  begin
    AGlobCont.OCanvas := OCanv;
//    AGlobCont.RFrame := TN_Rast1Frame(ARFrame);
    DrawProcObj := AGlobCont.StartCompTree;
    OCanvBackColor := $FFFFFF;
    OCanv.SetIncCoefsAndUCRect( FRect(0,0,1,1), IRect(OCanv.RSize) );
    SkipOnResize := False;
  end;
}
end; // procedure K_InitGlobContByRFrame

//*************************************** K_RegRAInitFunc
// Register RAInitFunc
//
procedure K_RegRAInitFunc( TypeName : string; RAInitFunc : TK_RAInitFunc );
var
  WW : TObject;
begin
  TK_RAInitFunc(WW) := RAInitFunc;
  K_RegListObject( TStrings(K_RAInitFuncs), TypeName, WW );
end; //*** end of procedure K_RegRAInitFunc


{*** TK_UDRPTab ***}

constructor TK_UDRPTab.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDRPTabCI;
  ImgInd := 31;
end;

function TK_UDRPTab.AddUDRecord( RecObjName : string = '' ) : TN_UDBase;
begin
  with TK_PRPTab(R.P)^ do begin
    Result := AddOneChild( K_CreateUDByRTypeCode( RDTCode.All, 1, RUDCI ) );
    Result.ObjName := RecObjName;
    SetUniqChildName ( Result );
  end;
end;

{*** end of TK_UDRPTab ***}

{*** TK_UDRAList ***}

//************************************** TK_UDRAList.Create ***
//
constructor TK_UDRAList.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDRArrayCI;
end; // end of TK_UDRAList.Create

//************************************** TK_UDRAList.Destroy ***
//
destructor TK_UDRAList.Destroy;
begin
  RAAttrList.Free;
  inherited;
end; // end of TK_UDRAList.Destroy

//************************************** TK_UDRAList.AddFieldsToSBuf ***
//
procedure TK_UDRAList.AddFieldsToSBuf( SBuf: TN_SerialBuf );
var
  SLText : string;
begin
  inherited;
  SLText := '';
  if RAAttrList <> nil  then SLText := RAAttrList.Text;
  SBuf.AddRowString( SLText );
end; // end of TK_UDRAList.AddFieldsToSBuf

//************************************** TK_UDRAList.GetFieldsFromSBuf ***
//
procedure TK_UDRAList.GetFieldsFromSBuf( SBuf: TN_SerialBuf );
var
  SLText : string;
begin
  inherited;
  SBuf.GetRowString( SLText );
  if SLText = '' then Exit;
  if RAAttrList = nil then RAAttrList := TStringList.Create;
  RAAttrList.Text := SLText;
end; // end of TK_UDRAList.GetFieldsFromSBuf

//************************************** TK_UDRAList.AddFieldsToText ***
//
function TK_UDRAList.AddFieldsToText( SBuf: TK_SerialTextBuf;
                                      AShowFlags: Boolean ): boolean;
var
  i : Integer;
  SValue : string;
begin
  Result := inherited AddFieldsToText( SBuf, AShowFlags );
  if RAAttrList = nil then Exit;
  for i := 0 to RAAttrList.Count - 1 do begin
    SValue := RAAttrList.ValueFromIndex[i];
    Sbuf.AddTagAttr( RAAttrList.Names[i], SValue );
  end;

end; // end of TK_UDRAList.AddFieldsToText

//************************************** TK_UDRAList.GetFieldsFromText ***
//
function TK_UDRAList.GetFieldsFromText(SBuf: TK_SerialTextBuf): Integer;
var
  i : Integer;
begin
  Result := inherited GetFieldsFromText( SBuf );
  with SBuf.AttrsList do
    for i := 0 to Count - 1 do begin
      if Objects[i] <> nil then Continue;
      if RAAttrList = nil then RAAttrList := TStringList.Create;
      RAAttrList.Add( Strings[i] )
    end;
end; // end of TK_UDRAList.GetFieldsFromText

//************************************** TK_UDRAList.Clone ***
//
function TK_UDRAList.Clone( ACopyFields: boolean ): TN_UDBase;
begin
  Result := inherited Clone( ACopyFields );
  if not ACopyFields or (RAAttrList = nil) then Exit;
  with TK_UDRAList(Result) do begin
    RAAttrList := TStringList.Create;
    RAAttrList.Assign( Self.RAAttrList );
  end;
end; // end of TK_UDRAList.Clone

//************************************** TK_UDRAList.CompareFields ***
//
function TK_UDRAList.CompareFields( SrcObj: TN_UDBase; AFlags: integer;
                                    NPath: string ): Boolean;
var
  i, Ind : Integer;
begin
  Result := inherited CompareFields( SrcObj, AFlags, NPath ); // not yet
  if not Result then Exit;
  with TK_UDRAList(SrcObj) do begin
    if (RAAttrList = nil) and (Self.RAAttrList = nil) then Exit;
    Result := (RAAttrList <> nil) and (Self.RAAttrList <> nil);
    if  not Result then Exit;
    Result := RAAttrList.Count = Self.RAAttrList.Count;
    if  not Result then Exit;
    Result := false;
    for i := 0 to RAAttrList.Count - 1 do begin
      Ind := Self.RAAttrList.IndexOfName( RAAttrList.Names[i] );
      if (Ind < 0) or (RAAttrList[i] <> Self.RAAttrList[Ind]) then Exit;
    end;
  end;
  Result := true;
end; // end of TK_UDRAList.CompareFields

//************************************** TK_UDRAList.CopyFields ***
//
procedure TK_UDRAList.CopyFields( SrcObj: TN_UDBase );
begin
  inherited CopyFields( SrcObj );
  if TK_UDRAList(SrcObj).RAAttrList = nil then
    FreeAndNil( RAAttrList )
  else begin
    if RAAttrList = nil then RAAttrList := TStringList.Create;
    RAAttrList.Assign( TK_UDRAList(SrcObj).RAAttrList );
  end;
end; // end of TK_UDRAList.CopyFields

{*** end of TK_UDRAList ***}

Initialization
  FillChar(K_UDRefSaveToFileDE, SizeOf(TN_DirEntryPar), 0);

//Finalization
//  K_TimerEventPermition := false;
//  K_ScriptLDDataTokenizer.free;
//  K_PascalHandles.Free;
//  K_RAInitFuncs.Free;
end.
