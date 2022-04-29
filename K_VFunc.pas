unit K_VFunc;
{$ASSERTIONS ON}

interface
uses SysUtils, Math, classes, Grids,
     N_Types, N_lib1,
     K_Types;

type TK_DataBuf = packed record   //***** Data Array Element Buffer
    StrData : string;
    case Integer of
      0: ( IData         : Integer; );
      1: ( DData         : Double;  );
      2: ( U1Data        : Byte; );
      3: ( U2Data        : Word; );
      4: ( I1Data        : ShortInt; );
      5: ( I2Data        : SmallInt; );
      6: ( U4Data        : LongWord; );
      7: ( TData         : Boolean; );
      8: ( LData         : Int64; );
      9: ( FData         : Single; );
end; //*** end of type TK_DataBuf = record

type TK_ParamType =  // all possible types data params array converting to TStrings
//*** don't change enum elenments order
      ( K_isInteger,      // Integer element of data vector
        K_isString,       // String element of data vector
        K_isDouble,       // Double element of data vector
        K_isUInt1,        // Byte element of data vector
        K_isInt2,         // Short element of data vector
        K_isInt64,        // Int64 element of data vector
        K_isHex,          // Integer element of data vector
        K_isBoolean,      // Boolean element of data vector
        K_isInt1,         // SmallInt element of data vector
        K_isUInt2,        // Word element of data vector
        K_isUInt4,        // LongWord element of data vector
        K_isFloat,       // Single element of data vector
        K_isDate,         // Date    : value := K_DateTimeToSTr( TDateTime(AttrValue) );
        K_isDateTime,     // Date    : value := K_DateTimeToSTr( TDateTime(AttrValue) );
        K_isUDPointer,    // Pointer to TN_UDBase object
//*** don't change enum elenments order
        K_isIntegerArray, // Integer Array
        K_isStringArray,  // String Array
        K_isDoubleArray,  // Double Array
        K_isUInt1Array,   // Byte Array
        K_isInt2Array,    // Short Array
        K_isInt64Array,   // Int64 Array
        K_isHexArray,     // Integer Array
        K_isBoolArray,    // Boolean Array
        K_isInt1Array,    // SmallInt element of data vector
        K_isUInt2Array,   // Word element of data vector
        K_isUInt4Array,   // LongWord element of data vector
        K_isFloatArray,  // Single Array
        K_isDateArray,    // Date    : value := K_DateTimeToSTr( TDateTime(AttrValue) );
        K_isDateTimeArray,// Date    : value := K_DateTimeToSTr( TDateTime(AttrValue) );
        K_isUndefinedData,// Wrong Data type
// special values for K_ToString function
        K_isHex16          // Hex64   : value := '$'+IntToHex( Int64(AttrValue), 16 );
      ); //*** end of TK_ParDataType = enum

const TK_defConvFmt : array [0..Ord(K_isUndefinedData)-1] of string =
//*** don't change elenments order
  ('%d', '%s', '%g', '%u', '%d', '%d', '$%x', '%d', '%d', '%u', '%u', '%.6g', 'dd.mm.yyyy', 'dd.mm.yyyy hh:mm:ss', '%p',
   '%d', '%s', '%g', '%u', '%d', '%d', '$%x', '%d', '%d', '%u', '%u', '%.6g', 'dd.mm.yyyy', 'dd.mm.yyyy hh:mm:ss' );

//type TK_IndexUseType = // types of index use in index copy routines
//      ( K_inDest, K_inSrc );

//type TK_SortDir = // types of index use in index copy routines
//      ( K_inAscend, K_inDescend );

type TK_CompareStringsFlags = // types of string compare
      Set of (
      K_csfCaseSensitive,
      K_csfSubString,
      K_csfWCExpression );



function  K_SizeOf( vtype : TK_ParamType ) : Integer;
function  K_GetElementAddr( const DArray; vtype : TK_ParamType;
                Ind : Integer ) : Pointer;
function  K_ArrayHigh( const DArray; vtype : TK_ParamType ) : Integer;
procedure K_SetLength( var DArray; vtype : TK_ParamType; Leng : Integer );
function  K_DataBufToString( const DataBuf : TK_DataBuf; vtype : TK_ParamType;
                                fmt : string = '' ) : string;
procedure K_DataBufFromString( const Str : string; var DataBuf : TK_DataBuf; vtype : TK_ParamType;
                                fmt : string = '' );
//function  K_CompareWithDataBuf( const Value; const DataBuf : TK_DataBuf;
//                             vtype : TK_ParamType ) : boolean;
//procedure K_GetFromDataBuf( var Value; const DataBuf : TK_DataBuf;
//                             vtype : TK_ParamType );
//procedure K_PutToDataBuf  ( const Value; var DataBuf : TK_DataBuf;
//                             vtype : TK_ParamType );
//procedure K_GetElementValue( const DArray; Ind : Integer; var data : TK_DataBuf;
//                             vtype : TK_ParamType );
//procedure K_PutElementValue( const DArray; Ind : Integer; const data : TK_DataBuf;
//                             vtype : TK_ParamType );
function  K_SearchInSArray( SArray : TN_SArray; const value : string;
                startInd : Integer = 0; hind : Integer = -1 ) : Integer;
function  K_SearchInIArray( IArray : TN_IArray; value : Integer;
                startInd : Integer = 0; hind : Integer = -1 ) : Integer;
function  K_GetPIArray0( IArray : TN_IArray ) : Pointer;
function  K_IndexOfStringInKeyExprsArray( Str : string;
                              PKeys : PString; KeysCount : Integer ) : Integer;
function  K_IndexOfStringInRArray( const SValue : string;
                    PS : PString; Count : Integer; Step : Integer = 0;
                    CompFlags : TK_CompareStringsFlags = [] ) : Integer;
//function  K_IndexOfStringInRArrayByKeyExpr( const KeyExpr : string;
//                PS : PString; Count : Integer; Step : Integer = 0  ) : Integer;
function  K_IndexOfIntegerInRArray( value : Integer;  PI : PInteger;
                                   Count : Integer; Step : Integer = 0 ) : Integer;
function  K_IndexOfDoubleInRArray( value : Double; PD : PDouble;
                                   Count : Integer; Step : Integer = 0 ) : Integer;
function  K_IndexOfValueInSortedRArray( var SValue; PSData : Pointer;
             DCount : Integer; DStep : Integer; CompareFunc : TN_CompFuncOfObj ) : Integer;
function  K_IndexOfDoubleInScale( pscale : PDouble; imax : Integer; ScaleStep : Integer; value : Double ) : Integer;
{
function  K_MinValue( PData: PDouble; HInd : Integer; Step : Integer = SizeOf(Double) ): Double;
function  K_MaxValue( PData: PDouble; HInd : Integer; Step : Integer = SizeOf(Double) ): Double;
}
function  K_GetDVectorNotSpecValuesArray( APRValue : PDouble; ARCount : Integer;
                                          APIndex : PInteger ) : TN_DArray;
function  K_BuildEquidistantRanges( VMin, VMax : Double; NumRanges, IRound : Integer ) : TN_DArray;
function  K_BuildEqualNElemsRanges( Values : TN_DArray; NumRanges, IRound : Integer ) : TN_DArray;
function  K_BuildOptimalRanges( Values : TN_DArray; NumRanges, IRound : Integer ) : TN_DArray;
function  K_BuildOptimalRanges0( Values : TN_DArray; NumRanges, IRound : Integer;
                                 PASteps : TN_PPDArray; PMStep : PDouble ) : TN_DArray;
function  K_BuildOptimalRanges2( Values : TN_DArray; NumRanges, IRound : Integer ) : TN_DArray;
function  K_BuildOptimalRanges3( Values : TN_DArray; NumRanges, IRound : Integer ) : TN_DArray;
function  K_BuildOptimalRanges1( Values : TN_DArray; NumRanges, IRound : Integer ) : TN_DArray;
function  K_BuildWeightedAverageRanges( AValues : TN_DArray; AWeights : TN_DArray; ARangePower, AIRound : Integer ) : TN_DArray;
function  K_BuildBestWorstRanges( AValues : TN_DArray; ABestWorstCount, AIRound : Integer ) : TN_DArray;
function  K_BuildStandardDeviationRanges( APRValue : PDouble; ARCount : Integer;
                                          var AIRound : Integer; ASVal : Double ) : TN_DArray;
function  K_SearchDifValsInOrderedArray( Values : TN_DArray; VMin, VMax : Double;
                                         MaxClassCount : Integer = 0 ) : TN_DArray;
function  K_BuildDiscreteRanges( Values : TN_DArray; VMin, VMax : Double ) : TN_DArray;
//procedure K_ToASArray( SM : TN_ASArray; ACol,ARow : Integer; const convArr;
//                                vtype : TK_ParamType; const fmt : string = '' );
//function  K_ToSArray( const convArr;  vtype : TK_ParamType; fmt : string = '' ) : TN_SArray;
function  K_ToString( const Value;  vtype : TK_ParamType; fmt : string = '' ) : string;
procedure K_FromString( const Str : string; var Value;  vtype : TK_ParamType; fmt : string = '' );
//function  K_SArrayConcat( const op1 : TN_SArray; const op2; op2type : TK_ParamType = K_isStringArray ) : TN_SArray;
//procedure K_ArraySetByScale( const dest, src; vtype : TK_ParamType;  const values, scale : TN_DArray );
//procedure K_CalcScaleRangeNumbers( const numbers : TN_IArray; const values, scale : TN_DArray );
//procedure K_ArrayCopy( const dest, src; vtype : TK_ParamType;
//                Dind : Integer = 0; Sind : Integer = 0; Count : Integer = 0 );
//procedure K_ArrayCast( const dest; dtype : TK_ParamType;
//                                           const src; stype : TK_ParamType );
//function  K_NotIndexBuild( var index : TN_IArray; leng : Integer ) : TN_IArray;
//function  K_NArrayZoneIndexBuild( const values; vtype : TK_ParamType; var index : TN_IArray; vmin, vmax : DOuble ) : Integer;
//function  K_ArraySetByIndex( const dest, src; vtype : TK_ParamType;
//                const index : TN_IArray; useIndex : TK_IndexUseType;
//                indexHigh : Integer = -1; indexStart : Integer = 0 ) : Integer;
//procedure K_BuildIndexFromCodes( const scodes, ncodes : TN_IArray; var indexes : TN_IArray );
//procedure K_BuildIndexFromDCodes( const scodes, ncodes : TN_DArray; var indexes : TN_IArray );

//procedure K_BuildBackIndex( const indexes : TN_IArray; var bindexes : TN_IArray );

//function  K_BuildPointersFromIndices( PElemBase: Pointer; ElemCount : Integer;
//                                      ElemSize: Integer; PIndex : PInteger ) : TN_PArray;
//procedure K_BuildIndicesFromPointers( PIndex : PInteger; PP : TN_PArray;
//                                      PElemBase: Pointer; ElemSize: Integer );
//procedure K_BuildSortIndex( PSortedIndex : PInteger; PElemArray: Pointer;
//                            ElemCount, ElemSize: integer;
//                            CompareParam: integer; CompareFunc: TN_CompareFunc );
procedure K_BuildSortIndex0( PSortedIndex : PInteger; PP : TN_PArray;
    CompareParam: integer; CompareFunc: TN_CompareFunc; PElemBase : TN_BytesPtr = nil;
    ElemSize : Integer = 0 );
procedure K_BuildSortedDoublePointers( PtrsArray : TN_PArray;
                                      DescendingOrder : Boolean;
                                      Offset : Integer = 0 );
procedure K_BuildSortedDoubleInds( PIndices: PInteger; PBegElem: Pointer;
                                   ElemCount : Integer; DescendingOrder : Boolean;
                                   ElemSize : Integer = SizeOf(Double); Offset : Integer = 0 );
function  K_SCIndexFromICodes( PIndexes, PDCodes : PInteger; DCLeng : Integer;
                               PSCodes : PInteger; SCLeng : Integer ) : Integer;
function  K_SCIndexFromSCodes( PIndices : PInteger;
                               PDCodes : PString; DCLeng : Integer;
                               PSCodes : PString; SCLeng : Integer ) : Integer;
function  K_MoveVectorBySIndex( var   DData; DStep :Integer;
                             const SData; SStep :Integer; DSize : Integer;
                             DCount : Integer; PIndex : PInteger;
                             IStep : Integer = SizeOf(Integer) ) : Integer;
function  K_MoveVectorByDIndex( var   DData; DStep :Integer;
                             const SData; SStep :Integer; DSize : Integer;
                             DCount : Integer; PIndex : PInteger;
                             IStep : Integer = SizeOf(Integer) ) : Integer;
function  K_MoveVectorByBIndex( var   DData; DStep :Integer;
                             const SData; SStep :Integer; DSize : Integer;
                             DCount : Integer; PIndex : PInteger;
                             IStep : Integer = SizeOf(Integer) ) : Integer;
function  K_MoveMatrixBySIndex( var   DMData; DStep0 : Integer; DStep1 : Integer;
                                const SMData; SStep0 : Integer; SStep1 : Integer;
                                DSize : Integer;
                                DCount0, DCount1 : Integer;
                                PIndex0 : PInteger = nil; PIndex1 : PInteger = nil;
                                IStep0 : Integer = SizeOf(Integer);
                                IStep1 : Integer = SizeOf(Integer) ) : Integer;
procedure K_MoveVector( var DData; DStep :Integer; const SData; SStep :Integer;
                        DSize : Integer; DCount : Integer );
//procedure K_MoveStrings( PDStr : Pointer; DStep :Integer;
//                         PSStr : Pointer; SStep :Integer;
//                         DCount : Integer );
procedure K_MoveStrings( var DStr : string; DStep :Integer;
                         var SStr : string; SStep :Integer;
                         DCount : Integer );
procedure K_DataReverse( var Data; DSize : Integer; DCount : Integer; DStep : Integer = 0 );
procedure K_DArrayRound0( PValues : PDouble; DCount, DStep, Precision : Integer );
const K_BuildFullBackIndexes = true;
const K_BuildFullActualIndexes = false;
function  K_BuildFullIndex( PSInds : PInteger; SICount : Integer;
                            PFullInds : PInteger; FullICount : Integer;
                            BackIndexFlag : Boolean ) : Integer;
function  K_BuildBackIndex0( PSInds : PInteger; SICount : Integer;
                             PBInds : PInteger; BICount : Integer ) : Integer;
function  K_BuildActIndicesAndCompress( PFInds, PAInds, PRInds, PSInds : PInteger;
                                        ICount : Integer ) : Integer;
procedure K_BuildXORIndices( PRInds : PInteger; PSInds : PInteger;
                             SICount : Integer; FICount : Integer;
                             CompressFlag : Boolean );
procedure K_FillIntArrayByCounter( PInds : PInteger; ICount : Integer;
            IStep : Integer = SizeOf(Integer); SValue : Integer = 0; VStep : Integer = 1 );
function  K_FillIntArrayByOrderInds( PRInds, POrderInds : PInteger; ICount : Integer;
                      SFillValue : Integer = 1; VFillStep : Integer = 1 ) : Integer;
function  K_DVectorIndexAndWZone( PDVector : PDouble; DStep : Integer; PIndexes : PInteger;
                                  ICount : Integer; VMin, VMax : Double ) : Integer;

procedure K_SFAddVElems    ( APVRes: PDouble; ANumElems: integer;
                             APV1, APV2: PDouble; AC2, ACRes: double );
procedure K_SFMultVElems   ( APVRes: PDouble; ANumElems: integer;
                             APV1, APV2: PDouble; ACRes: double );
procedure K_SFDivideVElems ( APVRes: PDouble; ANumElems: integer;
                             APV1, APV2: PDouble; ACRes: double );
procedure K_SFCUSumVElems  ( APVRes: PDouble; ANumElems: integer;
                             APV1: PDouble; ACRes: double );
procedure K_SFAbsVElems    ( APVRes: PDouble; ANumElems: integer;
                             APV1: PDouble; ACRes: double );
function  K_SFGetSumElems  ( APV1: PDouble; ANumElems: integer; Step : Integer = 0 ): double;
function  K_SFGetIndOfMax  ( APV1: PDouble; ANumElems: integer; Step : Integer = 0 ): integer;
function  K_SFGetIndOfMin  ( APV1: PDouble; ANumElems: integer; Step : Integer = 0 ): integer;
function  K_SFGetVectorMode( APVXMin, APVXD, APVPlotn: PDouble; ANumElems: integer ): double;
function  K_SFGetPartValue ( APVXMin, APVXD, APVW, APVAW: PDouble;
                             ANumElems: integer; AvalPrc: double ): double;
function  K_IndexOfMaxInRArray( APRValue : PInteger;
                                ARCount : Integer; ARSize : Integer = 0 ) : Integer; overload;
function  K_IndexOfMaxInRArray( APRValue : PDouble;
                                ARCount : Integer; ARSize : Integer = 0 ) : Integer; overload;
function  K_IndexOfMinInRArray( APRValue : PInteger;
                                ARCount : Integer; ARSize : Integer = 0 ) : Integer; overload;
function  K_IndexOfMinInRArray( APRValue : PDouble;
                                ARCount : Integer; ARSize : Integer = 0 ) : Integer; overload;
function  K_SumOfRArray( APRValue : PInteger;
                         ARCount : Integer; ARSize : Integer = 0 ) : Integer; overload;
function  K_SumOfRArray( APRValue : PDouble;
                         ARCount : Integer; ARSize : Integer = 0 ) : Double; overload;

implementation

uses Clipbrd,
  K_Script1, K_CLib0,
  N_lib0;

//********************************************* K_DataBufToString ***
//  Get Data from Data Buf
//
function  K_DataBufToString( const DataBuf : TK_DataBuf; vtype : TK_ParamType;
                                fmt : string = '' ) : string;
begin
  case vtype of
  K_isString, K_isStringArray  :
    Result := K_ToString( DataBuf.StrData, vtype, fmt );
  else
    Result := K_ToString( DataBuf.IData, vtype, fmt );
  end;
end;

//********************************************* K_DataBufFromString ***
//  Get Data from Data Buf
//
procedure K_DataBufFromString( const Str : string; var DataBuf : TK_DataBuf; vtype : TK_ParamType;
                                fmt : string = '' );
begin
  case vtype of
  K_isString, K_isStringArray  :
    K_FromString( str, DataBuf.StrData, vtype, fmt );
  else
    K_FromString( str, DataBuf.IData, vtype, fmt );
  end;
end;

{
//********************************************* K_CompareWithDataBuf ***
//  Compare Data with Data Buf
//
function K_CompareWithDataBuf( const Value; const DataBuf : TK_DataBuf;
                             vtype : TK_ParamType ) : boolean;
begin
  Result := false;
  case vtype of
    K_isInteger, K_isHex, K_isUDPointer, K_isUInt4, K_isFloat :
      Result := (Integer(Value) = DataBuf.IData);
    K_isString  :
      Result := (string(Value) = DataBuf.StrData);
    K_isInt64, K_isDouble, K_isDate  :
      Result := (Double(Value) = DataBuf.DData);
    K_isUInt1, K_isInt1  :
      Result := (Byte(Value) = DataBuf.U1Data);
    K_isInt2, K_isUInt2    :
      Result := (SmallInt(Value) = DataBuf.I2Data);
    K_isBoolean :
      Result := (Boolean(Value) = DataBuf.TData);
  else
    assert( true, 'Wrong Data Buf type' );
  end;
end;

//********************************************* K_GetFromDataBuf ***
//  Get Data from Data Buf
//
procedure K_GetFromDataBuf( var Value; const DataBuf : TK_DataBuf;
                             vtype : TK_ParamType );
begin
  case vtype of
    K_isInteger, K_isHex, K_isUDPointer, K_isUInt4 :
      Integer(Value) := DataBuf.IData;
    K_isString  :
      string(Value) := DataBuf.StrData;
    K_isDouble, K_isDate  :
      Double(Value) := DataBuf.DData;
    K_isUInt1, K_isInt1  :
      Byte(Value) := DataBuf.U1Data;
    K_isInt2, K_isUInt2    :
      SmallInt(Value) := DataBuf.I2Data;
    K_isInt64   :
      Int64(Value) := DataBuf.LData;
    K_isBoolean :
      Boolean(Value) := DataBuf.TData;
    K_isFloat  :
      Single(Value) := DataBuf.FData;
  else
    assert( true, 'Wrong Data Buf type' );
  end;
end;

//********************************************* K_PutToDataBuf ***
//  Put Data to Data Buf
procedure K_PutToDataBuf( const Value; var DataBuf : TK_DataBuf;
                             vtype : TK_ParamType );
begin
  case vtype of
    K_isInteger, K_isHex, K_isUDPointer, K_isUInt4 :
      DataBuf.IData := Integer(Value);
    K_isString  :
      DataBuf.StrData := string(Value);
    K_isDouble, K_isDate  :
      DataBuf.DData := Double(Value);
    K_isUInt1, K_isInt1   :
      DataBuf.U1Data := Byte(Value);
    K_isInt2, K_isUInt2    :
      DataBuf.I2Data := SmallInt(Value);
    K_isInt64   :
      DataBuf.LData := Int64(Value);
    K_isBoolean :
      DataBuf.TData := Boolean(Value);
    K_isFloat  :
      DataBuf.FData := Single(Value);
  else
    assert( true, 'Wrong Data Buf type' );
  end;
end;
}

//********************************************* K_SizeOf ***
//  returns size of data
//
function  K_SizeOf( vtype : TK_ParamType ) : Integer;
begin
  Result := 0;
  case vtype of
    K_isInteger, K_isIntegerArray,
    K_isHex, K_isHexArray,
    K_isString, K_isStringArray,
    K_isFloat, K_isFloatArray  :
      Result := 4;
    K_isInt2, K_isInt2Array  :
      Result := 2;
    K_isDate, K_isDateArray,
    K_isDateTime, K_isDateTimeArray,
    K_isDouble, K_isDoubleArray,
    K_isInt64, K_isInt64Array, K_isHex16 :
      Result := 8;
    K_isBoolean, K_isBoolArray,
    K_isUInt1, K_isUInt1Array, K_isInt1, K_isInt1Array :
      Result := 1;
  else
    assert( true, 'Wrong Data Buf type' );
  end;
end;

//********************************************* K_GetElementPointer ***
//  Get Array High index
function  K_GetElementAddr( const DArray; vtype : TK_ParamType;
                Ind : Integer ) : Pointer;
begin
  Result := nil;
  if vtype >= K_isIntegerArray then
    case vtype of
      K_isIntegerArray, K_isHexArray :
        Result := Addr(TN_IArray(DArray)[Ind]);
      K_isStringArray  :
        Result := Addr(TN_SArray(DArray)[Ind]);
      K_isDoubleArray :
        Result := Addr(TN_DArray(DArray)[Ind]);
      K_isUInt1Array :
        Result := Addr(TN_BArray(DArray)[Ind]);
      K_isInt64Array :
        Result := Addr(TN_I64Array(DArray)[Ind]);
    else
      assert( true, 'Wrong Data Array type' );
    end;
end;

//********************************************* K_ArrayHigh ***
//  Get Array High index
function  K_ArrayHigh( const DArray; vtype : TK_ParamType ) : Integer;
begin
  Result := -1;
  if vtype >= K_isIntegerArray then
    case vtype of
      K_isIntegerArray, K_isHexArray :
        Result := High(TN_IArray(DArray));
      K_isStringArray  :
        Result := High(TN_SArray(DArray));
      K_isDoubleArray :
        Result := High(TN_DArray(DArray));
      K_isUInt1Array :
        Result := High(TN_BArray(DArray));
      K_isInt64Array :
        Result := High(TN_I64Array(DArray));
    else
      assert( true, 'Wrong Data Array type' );
    end;
end;

//********************************************* K_SetLength ***
//  Get Array High index
procedure K_SetLength( var DArray; vtype : TK_ParamType; Leng : Integer );
begin
  case vtype of
    K_isIntegerArray, K_isInteger,
    K_isHexArray, K_isHex :
      SetLength(TN_IArray(DArray), Leng);
    K_isStringArray, K_isString :
      SetLength(TN_SArray(DArray), Leng);
    K_isDoubleArray, K_isDouble :
      SetLength(TN_DArray(DArray), Leng);
    K_isUInt1Array, K_isUInt1 :
      SetLength(TN_BArray(DArray), Leng);
    K_isInt64Array, K_isInt64 :
      SetLength(TN_I64Array(DArray), Leng);
  else
    assert( true, 'Wrong Data Array type' );
  end;
end;

{
//********************************************* K_GetElementValue ***
//  Get Element Value from Data Array
//  returns -1 if not found
procedure K_GetElementValue( const DArray; Ind : Integer; var data : TK_DataBuf;
                             vtype : TK_ParamType );
begin
  case vtype of
    K_isInteger, K_isIntegerArray,
    K_isHex, K_isHexArray :
      data.IData := TN_IArray(DArray)[Ind];
    K_isString, K_isStringArray  :
      data.StrData := TN_SArray(DArray)[Ind];
    K_isDouble, K_isDoubleArray :
      data.DData := TN_DArray(DArray)[Ind];
    K_isUInt1, K_isUInt1Array,
    K_isInt1, K_isInt1Array :
      data.U1Data := TN_BArray(DArray)[Ind];
    K_isInt64, K_isInt64Array :
      data.LData := TN_I64Array(DArray)[Ind];
  else
    assert( true, 'Wrong Data Array type' );
  end;
end;

//********************************************* K_PutElementValue ***
//  Get Element Value from Data Array
//  returns -1 if not found
procedure K_PutElementValue( const DArray; Ind : Integer; const data : TK_DataBuf;
                             vtype : TK_ParamType );
begin
  case vtype of
    K_isIntegerArray, K_isInteger,
    K_isHexArray, K_isHex :
      TN_IArray(DArray)[Ind] := data.IData;
    K_isString, K_isStringArray  :
      TN_SArray(DArray)[Ind] := data.StrData;
    K_isDouble, K_isDoubleArray :
      TN_DArray(DArray)[Ind] := data.DData;
    K_isUInt1, K_isUInt1Array,
    K_isInt1, K_isInt1Array :
      TN_BArray(DArray)[Ind] := data.U2Data;
    K_isInt64, K_isInt64Array :
      TN_I64Array(DArray)[Ind] := data.LData;
  else
    assert( true, 'Wrong Data Array type' );
  end;
end;
}

//********************************************* K_SearchInSArray ***
//  search value in SArray
//  returns -1 if not found
function K_SearchInSArray( SArray : TN_SArray; const value : string;
                startInd : Integer = 0; hind : Integer = -1 ) : Integer;
//var i : Integer;
begin
  if hind = -1 then hind := Length(SArray) - startInd;
  Result := -1;
  if hind = -1 then Exit;
  Result :=  K_IndexOfStringInRArray( value, @SArray[startInd], hind + 1 );
  if Result <> -1 then Inc( Result, startInd );
end;

//********************************************* K_SearchInIArray ***
//  search value in IArray
//  returns -1 if not found
function K_SearchInIArray( IArray : TN_IArray; value : Integer;
                startInd : Integer = 0; hind : Integer = -1 ) : Integer;
begin
  if hind = -1 then hind := High(IArray);
  Result := -1;
  if hind = -1 then Exit;
  Result := K_IndexOfIntegerInRArray( value, @IArray[startInd], hind - startInd + 1 );
  if Result <> -1 then Inc( Result, startInd );
end;

//********************************************* K_GetPIArray0 ***
//  Get Pointer To TN_IArray 0-Item
//
function K_GetPIArray0( IArray : TN_IArray ) : Pointer;
begin
  Result := nil;
  if Length(IArray) > 0 then Result := @IArray[0];
end; // function K_GetPIArray0

//********************************************* K_IndexOfStringInKeyExprsArray
//  Index of Key In Key Expressions Array Corresponding to given String
//
//      Parameters
//  Str       - string for search
//  PKeys     - pointer to 0 element of keys expressions array
//  KeysCount - nuber of elements in keys expressions array
//  Result    - index of key expression array
function K_IndexOfStringInKeyExprsArray( Str : string; PKeys : PString; KeysCount : Integer ) : Integer;
var
  i : Integer;

begin

  Result := -1;
  for i := 0 to KeysCount - 1 do begin
    if K_CheckKeyExpr( Str, PKeys^  ) then begin
      Result := i;
      break;
    end;
    Inc(  TN_BytesPtr(PKeys), Sizeof(string) );
  end;

end; // end of K_IndexOfStringInKeyExprsArray

//********************************************* K_IndexOfStringInRArray
//  Search string in strings RArray which is corresponding to SValue
//
//       Parameters
//  SValue    - search string value (may be wildcard expression)
//  PS        - pointer to first string in array
//  Count     - strings counter
//  Step      - strings step
//  CompFlags - compare flags
//  Result    - 0-based index of proper string,
//              returns -1 if proper string is not found
//
function  K_IndexOfStringInRArray( const SValue : string;
                    PS : PString; Count : Integer; Step : Integer = 0;
                    CompFlags : TK_CompareStringsFlags = [] ) : Integer;
var
  i, SInd : Integer;
  R : Boolean;
  UValue : string;
begin
  Result := -1;
  if Step = 0 then Step := SizeOf(string);

  if (K_csfSubString in CompFlags) and
      not (K_csfCaseSensitive in CompFlags) then
    UValue := UpperCase(SValue);

  for i := 0 to Count - 1 do begin
    if K_csfWCExpression in CompFlags then
      R := K_CheckTextPattern( PS^, SValue, false )
    else if K_csfSubString in CompFlags then begin
       if K_csfCaseSensitive in CompFlags then
         SInd := Pos( SValue, PS^ )
       else
         SInd := Pos( UValue, UpperCase(PS^) );
       R := (SInd > 0);
    end else begin
       if K_csfCaseSensitive in CompFlags then
         R := (SValue = PS^)
       else
         R := SameText(SValue, PS^);
    end;
    if R then begin
      Result := i;
      break;
    end;
    Inc(TN_BytesPtr(PS), Step);
  end;
end;

{
//********************************************* K_IndexOfStringInRArrayByKeyExpr
//  Search string in strings RArray which is corresponding to given Keys Expression
//
//       Parameters
//  KeyExpr   - keys string expression
//  PS        - pointer to first string in array
//  Count     - strings counter
//  Step      - strings step
//  Result    - 0-based index of proper string,
//              returns -1 if proper string is not found
//
function  K_IndexOfStringInRArrayByKeyExpr( const KeyExpr : string;
                PS : PString; Count : Integer; Step : Integer = 0 ) : Integer;
var
  WRes, CRes, OpMode, ORMode, NOTMode, ANDMode : Boolean;
  Context : string;
  LRes : Integer;
  UCStr : string;
  CompFlags : TK_CompareStringsFlags;

begin
  K_CompareKeyAndStrTokenizer.setSource( KeyExpr );
  Result := -1;
  OpMode := false;
  LRes := -1;
  NOTMode := false;
  ORMode := true;
  ANDMode := false;
  CRes := false;
  UCStr := '';
  if Step = 0 then Step := SizeOf(string);
  while K_CompareKeyAndStrTokenizer.hasMoreTokens(true) do begin
    Context := K_CompareKeyAndStrTokenizer.nextToken;
    if SameText( Context, 'not' ) then begin
      NOTMode := true;
      continue;
    end;
    if OpMode then begin
    // Select operation mode
      ANDMode := false;
      ORMode := SameText( Context, 'or' );
      if not ORMode then
        ANDMode := SameText( Context, 'and' );
      OpMode := false;
    end else begin
      if LRes = -1 then begin
        if Context[1] = '#' then begin// Wild card pattern
          Context := Copy( Context, 2, Length(Context) );
          CompFlags := [K_csfWCExpression];
        end else if Context[1] = '.'  then begin
          Context := Copy( Context, 2, Length(Context) );
          CompFlags := [];
        end else                       // Substring
          CompFlags := [K_csfSubString];

        LRes := K_IndexOfStringInRArray( Context, PS, Count, Step,
                                         CompFlags );
        CRes := (LRes <> -1);
        if CRes then
          UCStr := UpperCase( PString((TN_BytesPtr(PS) + LRes * Step))^ );
      end else begin
        // Check expression current Context lexem
        if (not CRes and ORMode) or (not ORMode and CRes) then begin
          // Current result calc is needed
          if Context[1] = '#' then // Wild card pattern
            WRes := K_CheckTextPattern( UCStr, Copy( Context, 2, Length(Context) ), false)
          else if Context[1] = '.'  then
            WRes := StrIComp( @Context[2], @UCStr[1] ) = 0
          else                       // Substring
            WRes := Pos( UpperCase(Context), UCStr ) > 0;

          if NOTMode then
            WRes := WRes xor NOTMode;
          if ORMode then
            CRes := CRes or WRes
          else if ANDMode then
            CRes := CRes and WRes;
        end;
      end;
      OpMode := true;
    end;
    NOTMode := false;
  end;
  if CRes then Result := LRes;

end; // end of K_IndexOfStringInRArrayByKeyExpr
}

//********************************************* K_IndexOfIntegerInRArray
//  search value in Integer field of records array
//  returns -1 if not found
function  K_IndexOfIntegerInRArray( value : Integer;  PI : PInteger;
                                    Count : Integer; Step : Integer = 0 ) : Integer;
var
  i : Integer;
begin
  Result := -1;
  if Step = 0 then Step := SizeOf(Integer);
  for i := 0 to Count - 1 do begin
    if value = PI^ then begin
      Result := i;
      break;
    end;
    Inc(TN_BytesPtr(PI), Step);
  end;
end;

//********************************************* K_IndexOfDoubleInRArray
//  search value in Double field of records array
//  returns -1 if not found
function K_IndexOfDoubleInRArray( value : Double; PD : PDouble;
                                  Count : Integer; Step : Integer = 0 ) : Integer;
var
  i : Integer;
begin
  Result := -1;
  if PD = nil then Exit;
  if Step = 0 then Step := SizeOf(Double);
  for i := 0 to Count - 1 do begin
    if value = PD^ then begin
      Result := i;
      break;
    end;
    Inc(TN_BytesPtr(PD), Step);
  end;
end;

//********************************************* K_IndexOfValueInSortedRArray ***
//  search SValue place in sorteg array SData
//  returns =0      if SValue <  SData[0]
//          =DCount if SValue >= SData[DCount-1]
function K_IndexOfValueInSortedRArray( var SValue; PSData : Pointer;
   DCount : Integer; DStep : Integer; CompareFunc : TN_CompFuncOfObj ) : Integer;
var imax, inext : Integer;
begin
  Result := 0;
  imax := DCount - 1;
  if DStep = 0 then DStep := SizeOf(Double);
  while Result <= imax do
  begin
    inext := (Result + imax) shr 1;
    if CompareFunc( @SValue, TN_BytesPtr(PSData)+ DStep*inext ) < 0 then
      imax := inext - 1
    else
      Result := inext + 1;
  end;
end;

//********************************************* K_IndexOfDoubleInScale
//  search place in sorteg double array
//  returns 0 if value < scale[0] and Length(scale) if value >= scale[High(scale)]
function K_IndexOfDoubleInScale( pscale : PDouble; imax : Integer; ScaleStep : Integer; value : Double ) : Integer;
//var imin, inext : Integer;
begin
  N_CFuncs.Offset := 0;
  N_CFuncs.DescOrder := false;
  Result := K_IndexOfValueInSortedRArray( value, pscale, imax + 1, ScaleStep, N_CFuncs.CompOneDouble );
{
  imin := 0;
  while imin <= imax do
  begin
    inext := (imin + imax) shr 1;
    if  value < PDouble((TN_BytesPtr(pscale)+ ScaleStep*inext))^ then
      imax := inext - 1
    else
      imin := inext + 1;
  end;
  Result := imin;
}
end;

{
//********************************************* K_MinValue ***
//  search Min Double Value in double array
//
function K_MinValue( PData: PDouble; HInd : Integer; Step : Integer = SizeOf(Double) ): Double;
var
  i: Integer;
begin
  Result := PData^;
  for i := 1 to HInd do begin
    Inc(PData);
    if Result > PData^ then Result := PData^;
  end;
end;

//********************************************* K_MaxValue ***
//  search Max Double Value in double array
//
function K_MaxValue( PData: PDouble; HInd : Integer; Step : Integer = SizeOf(Double) ): Double;
var
  i: Integer;
begin
  Result := PData^;
  for i := 1 to HInd do begin
    Inc(PData);
    if Result < PData^ then Result := PData^;
  end;
end;
}

//***************************************** K_GetDVectorNotSpecValuesArray
// Return Array of not Special Values
//
//     Parameters
// APRValue - pointer to field in 1-st array record
// ARCount  - array records count
// APIndex  - in input pointer to first element in corresponding indexes array,
//            on output firts indexes array elements contain indexes corresponding
//            to vector elements put to resulting array
// Result   - Returns array of not special values
//
function K_GetDVectorNotSpecValuesArray( APRValue : PDouble; ARCount : Integer;
                                         APIndex : PInteger ) : TN_DArray;
var
  i, j : Integer;
  PCurIndex : PInteger;
begin
  SetLength( Result, ARCount );
  j := 0;
  PCurIndex := APIndex;
  for i := 0 to ARCount - 1 do
  begin
    if (APRValue^ < K_MVMaxVal) and (APRValue^ > K_MVMinVal) then begin
      if APIndex <> nil then
      begin
        PCurIndex^ := APIndex^;
        Inc(PCurIndex);
      end;
      Result[j] := APRValue^;
      Inc(j);
    end;
    Inc(APRValue);
    if APIndex <> nil then
      Inc(APIndex);
  end;
  SetLength( Result, j );
end; // end_of function K_GetDVectorNotSpecValuesArray

//************************************************ K_BuildEquidistantRanges
//  calculate scale using values and precision
//
function K_BuildEquidistantRanges( VMin, VMax : Double; NumRanges, IRound : Integer ) : TN_DArray;
//function K_BuildEquidistantRanges( Values : TN_DArray; NumRanges, IRound : Integer ) : TN_DArray;
var
  delta : Double;
  i : Integer;
begin
  if NumRanges = 0 then Exit;
//*** scale
  SetLength( Result, NumRanges - 1 );
  delta := (VMax - VMin)/NumRanges;
  for i := 0 to High(Result) do
  begin
    VMin := VMin + delta;
    Result[i] := VMin;
  end;
  K_DArrayRound0( @Result[0],  Length( Result), SizeOf(Double), IRound );
end;

//************************************************ K_BuildEqualNElemsRanges
//  calculate scale using values and precision
//
function K_BuildEqualNElemsRanges( Values : TN_DArray; NumRanges, IRound : Integer ) : TN_DArray;
var
  steps : TN_DArray;
  LSteps, i, Ind, num, RInd, DInd, SInd, BStep : Integer;
  CalcRangeStepFlag : Boolean;
  NumMax, CountMax : Integer;


  function CalcSteps( APrecision : Integer ) : Integer;
  var
//    FPrecision, WV : Double;
    FPrecision : Double;
    i : Integer;
  begin
    Result := 0;
    FPrecision := IntPower( 10.0, APrecision );
    for i := 0 to High(steps) do
    begin
{
      steps[i] :=
        Round( (values[i] + values[i+1]) * 0.5 * FPrecision )/FPrecision - values[i];
}
//      WV := (values[i] + values[i+1]) * 0.5;

{
      WV := values[i+1];
      if APrecision < 100 then
        WV := Floor( WV * FPrecision )/FPrecision;
      steps[i] := WV - values[i];
}
      steps[i] := values[i+1] - values[i];
      if APrecision < 100 then
        steps[i] := Floor( steps[i] * FPrecision )/FPrecision;

      if steps[i] > 0 then Inc(Result);
    end;
  end; // function CalcSteps

begin
  SetLength( Result, 0 );
  if NumRanges = 0 then Exit;
  if Length(values) = 0 then Exit;

  N_SortElements( TN_BytesPtr(@Values[0]), Length(Values), SizeOf(Double), 0, N_CompareDoubles);
//prep Round Params

//*** build steps scale
  LSteps := High(values);
  SetLength( steps, LSteps );
  Ind := CalcSteps( 100 );
  if Ind = 0 then Exit;

  Ind := CalcSteps( IRound );
  if IRound <> 100 then
  begin
//*** search available precision
    while Ind = 0 do
    begin
      Inc(IRound);
      Ind := CalcSteps( IRound );
    end;
  end; // if IRound <> 100 then

  if Ind <= (NumRanges - 1) then
  begin
  // number of different vector values is less then  ranges number
    SetLength( Result, Ind );
    if Ind = 0 then Exit;
    Ind := 0;
    for i := 0 to High(steps) do
      if steps[i] > 0 then
      begin
        Result[Ind] := values[i] + steps[i];
        Inc(Ind)
      end;
  end
  else
  begin
  // number of different vector values is greater or equal to ranges number
    SetLength( Result, NumRanges - 1 );
    num := Round(LSteps/NumRanges);
    Ind := Length(values);
    NumMax := Ceil( Ind/NumRanges );
    CountMax := NumRanges - (NumRanges * NumMax - Ind) - 1;
    Ind := num;
    RInd := 0;
    CalcRangeStepFlag := FALSE;
    for i := 0 to High(Result) do
    begin
      DInd := Floor( 0.5 * num );
      SInd := Ind;
      BStep := LSteps + 1;
      //*** backward search
      if DInd > 0 then
      begin
         DInd := Ind - DInd;
         while (Ind >= DInd) and (steps[Ind] = 0) do
         begin
           Dec(Ind);
           CalcRangeStepFlag := TRUE;
         end;
         if Ind >= DInd then
           BStep := SInd - Ind;
      end;

      //*** forward search
      Ind := SInd;
      while (Ind < LSteps) and (steps[Ind] = 0) do
      begin
        Inc(Ind);
        CalcRangeStepFlag := TRUE;
      end;
      if BStep < Ind - SInd then // short backward step
        Ind := SInd - BStep;
      if Ind >= LSteps then break;

      //*** set selected value
//      Result[i] := values[Ind] + steps[Ind];
      Result[i] := values[Ind-1] + steps[Ind-1] * 0.5;
      Inc(RInd);
      if CalcRangeStepFlag then
        num := Round( (LSteps - Ind)/(NumRanges - RInd) )
      else
      begin
        if CountMax = 0 then
          num := NumMax - 1
        else
        begin
          num := NumMax;
          Dec(CountMax);
        end;
      end;

      if num = 0 then break;
      Ind := Ind + num;
    end; // for i := 0 to High(Result) do
    SetLength( Result, RInd );
  end;
end; // end of K_BuildEqualNElemsRanges

//************************************************ K_BuildOptimalRanges
//  calculate scale using values and precision
//
function K_BuildOptimalRanges( Values : TN_DArray; NumRanges, IRound : Integer ) : TN_DArray;
var
  i, j, RInd, SInd, MinInd, MInd : Integer;
  FPrecision, MinWD, PWD, WD, SD :  Double;
  BIndexes : TN_IArray;
//  WWD : TN_DArray;

  function MValue( BI, LI : Integer ) : Double;
  var i : Integer;
  begin
    Result := 0;
    for i := BI to LI - 1 do
      Result := Result + Values[i];
    LI := LI - BI;
    if LI > 0 then
      Result := Result/LI
    else
      Result := Values[BI];
  end;

  function DValue( BI,LI : Integer ) : Double;
  var
    i : Integer;
    M,D : Double;
  begin
    M := MValue( BI, LI );
    Result := 0;
    for i := BI to LI - 1 do begin
      D := Values[i] - M;
      Result := D * D;
    end;
  end;

begin
  Result := K_BuildEqualNElemsRanges(Values, NumRanges, IRound);
  if Length(Result) = 0 then Exit;
  SetLength( BIndexes, Length(Result) + 2 );
  RInd := High(Values);
  BIndexes[0] := 0;
  BIndexes[High(BIndexes)] := RInd+1;
  SInd := 0;
// search Bound indexes
  for i := 0 to High(Result) do begin
    j := SInd;
    while (Values[j] < Result[i]) and ( j < RInd ) do Inc(j);
    BIndexes[i+1] := j;
    SInd := j + 1;
  end;

{
  SetLength( WWD, BIndexes[2] );
  for i := 1 to BIndexes[2] - 1 do
    WWD[i-1] := DValue( 0, i ) + DValue( i, BIndexes[2] );
}

// Seach Optimal Bound Place
  for i := 1 to High(BIndexes) - 1 do begin
    SInd := BIndexes[i];
    MInd := SInd;
    SD := DValue( BIndexes[i-1], SInd ) + DValue( SInd, BIndexes[i+1] );
   // back search
    WD := SD;
    repeat
      PWD := WD;
      Dec( SInd );
      if SInd >= 0 then
        WD := DValue( BIndexes[i-1], SInd ) + DValue( SInd, BIndexes[i+1] );
    until (WD > PWD) or (SInd <= BIndexes[i-1]+1);
    if (WD > PWD) or (SInd < 0) then begin
      MinInd := SInd + 1;
      MinWD := PWD;
    end else begin
      MinInd := SInd;
      MinWD := WD;
    end;
   // forward search
    WD := SD;
    SInd := MInd;
    repeat
      PWD := WD;
      Inc( SInd );
      if SInd <= High(Values) then
        WD := DValue( BIndexes[i-1], SInd ) + DValue( SInd, BIndexes[i+1] );
    until (WD > PWD) or (SInd >= BIndexes[i+1]-1);
   // compare forward and backward search
    if (WD > PWD) or (SInd > High(Values)) then
      SInd := SInd - 1
    else
      PWD := WD;
    if MinWD < PWD then SInd := MinInd;
    BIndexes[i] := SInd;
  end;

  if IRound >= 100 then Exit;
  FPrecision := IntPower( 10.0, IRound );
  for i := 0 to High(Result) do
    Result[i] := Floor( Values[BIndexes[i+1]]* FPrecision )/FPrecision;

end; // end of K_BuildOptimalRanges

//************************************************ K_BuildOptimalRanges0
//  calculate scale using values and precision
//
function  K_BuildOptimalRanges0( Values : TN_DArray; NumRanges, IRound : Integer;
                                 PASteps : TN_PPDArray; PMStep : PDouble ) : TN_DArray;
var
  steps : TN_DArray;
  LSteps, i, Ind  : Integer;
  UniteSmall : Boolean;
  MStep : Double;

  function CalcSteps( APrecision : Integer ) : Integer;
  var
    FPrecision, WV : Double;
    i : Integer;
  begin
    Result := 0;
    FPrecision := IntPower( 10.0, APrecision );
    for i := 0 to High(steps) do begin
      WV := values[i + 1];
      if APrecision < 100 then
        WV := Floor( WV * FPrecision )/FPrecision;
      steps[i] := WV - values[i];
      if steps[i] > 0 then Inc(Result);
    end;
  end;

begin
  if PASteps <> nil then PASteps^ := nil;
  SetLength( Result, 0 );
  if NumRanges = 0 then Exit;
  if Length(values) = 0 then Exit;
  MStep := 0;
  N_SortElements( TN_BytesPtr(@Values[0]), Length(Values), SizeOf(Double), 0, N_CompareDoubles);
//prep Round Params

//*** build steps scale
  LSteps := High(values);
  SetLength( steps, LSteps );
  Ind := CalcSteps( 100 );
  if Ind = 0 then Exit;

  Ind := CalcSteps( IRound );
  if IRound <> 100 then begin
//*** search available precision
    while Ind = 0 do begin
      Inc(IRound);
      Ind := CalcSteps( IRound );
    end;
  end;

  if Ind <= (NumRanges - 1) then begin
  // number of different vector values is less then  ranges number
    SetLength( Result, Ind );
    if Ind = 0 then Exit;
    Ind := 0;
    for i := 0 to High(steps) do
      if steps[i] > 0 then begin
        Result[Ind] := values[i] + steps[i];
        Inc(Ind)
      end;
  end else begin
  // number of vector elements different values is greater then needed ranges number
//    MStep := (values[LSteps] - values[0])/LSteps;
    MStep := 0.1 * (values[LSteps] - values[0])/NumRanges;
    SetLength( Result, Ind shr 1 );
    UniteSmall := Steps[0] < MStep;
    Ind := 0;
    for i := 1 to High(Steps) do begin
      if (UniteSmall and (Steps[i] < MStep)) or
         (not UniteSmall and (Steps[i] >= MStep))  then Continue; // Try next

      if UniteSmall then
        Result[Ind] := values[i] + steps[i] * 0.5
      else
        Result[Ind] := values[i] - steps[i-1] * 0.5;
      UniteSmall := not UniteSmall;
      if (Ind = 0) or (Result[Ind] <> Result[Ind - 1]) then
        Inc(Ind)
    end;
    SetLength( Result, Ind );
  end;
  if PASteps <> nil then PASteps^ := steps;
  if PMStep <> nil then PMStep^ := MStep;
end; // end of K_BuildOptimalRanges0

//************************************************ K_BuildOptimalRanges2
//  calculate scale using values and precision
//
function K_BuildOptimalRanges2( Values : TN_DArray; NumRanges, IRound : Integer ) : TN_DArray;
var
  i, j, RInd, SInd, MinInd, MInd : Integer;
  FPrecision, MinWD, PWD, WD, SD :  Double;
  BIndexes : TN_IArray;
//  WWD : TN_DArray;

  function MValue( BI, LI : Integer ) : Double;
  var i : Integer;
  begin
    Result := 0;
    for i := BI to LI - 1 do
      Result := Result + Values[i];
    LI := LI - BI;
    if LI > 0 then
      Result := Result/LI
    else
      Result := Values[BI];
  end;

  function DValue( BI,LI : Integer ) : Double;
  var
    i : Integer;
    M,D : Double;
  begin
    M := MValue( BI, LI );
    Result := 0;
    for i := BI to LI - 1 do begin
      D := Values[i] - M;
      Result := D * D;
    end;
  end;

  procedure RemoveBInd( RemvedInd : Integer );
  var
    H : Integer;
  begin
    H := High(BIndexes);
    Move( BIndexes[RemvedInd+1], BIndexes[RemvedInd], (H - RemvedInd) * SizeOf(Integer) );
    SetLength( BIndexes, H );
  end;

begin
  Result := K_BuildEqualNElemsRanges(Values, NumRanges, IRound);
  SInd := Length (Result);
  if (SInd = 0) or (SInd < NumRanges - 1) then Exit;
  RInd := High(Values);
  // Check if Number of Different values is Big
  MInd := Length(K_SearchDifValsInOrderedArray( Values, Values[0] - 1, Values[RInd] + 1 ));
  if MInd < 1.2 * SInd then Exit;
  if MInd > 3 * SInd then
    Result :=  K_BuildOptimalRanges0( Values, NumRanges, IRound, nil, nil );

  SetLength( BIndexes, Length(Result) + 2 );
  BIndexes[0] := 0;
  BIndexes[High(BIndexes)] := RInd+1;
// search Bound indexes
  j := 0;
  for i := 0 to High(Result) do begin
    while (Values[j] < Result[i]) and ( j < RInd ) do Inc(j);
    BIndexes[i+1] := j;
    Inc(j);
  end;

// Seach Optimal Bound Place
  for i := 1 to High(BIndexes) - 1 do begin
    SInd := BIndexes[i];
    MInd := SInd;
    SD := DValue( BIndexes[i-1], SInd ) + DValue( SInd, BIndexes[i+1] );
   // back search
    WD := SD;
    repeat
      PWD := WD;
      Dec( SInd );
      if SInd >= 0 then
        WD := DValue( BIndexes[i-1], SInd ) + DValue( SInd, BIndexes[i+1] );
    until (WD > PWD) or (SInd <= BIndexes[i-1]+1);
    if (WD > PWD) or (SInd < 0) then begin
      MinInd := SInd + 1;
      MinWD := PWD;
    end else begin
      MinInd := SInd;
      MinWD := WD;
    end;
   // forward search
    WD := SD;
    SInd := MInd;
    repeat
      PWD := WD;
      Inc( SInd );
      if SInd <= High(Values) then
        WD := DValue( BIndexes[i-1], SInd ) + DValue( SInd, BIndexes[i+1] );
    until (WD > PWD) or (SInd >= BIndexes[i+1]-1);
   // compare forward and backward search
    if (WD > PWD) or (SInd > High(Values)) then
      SInd := SInd - 1
    else
      PWD := WD;
    if MinWD < PWD then SInd := MinInd;
    BIndexes[i] := SInd;
  end;

  // Takeup N=1 Intervals Loop
  if BIndexes[1] = 1 then
    RemoveBInd( 1 );
  i := 1;
  while i < High(BIndexes) do begin
    if BIndexes[i+1] - BIndexes[i] = 1 then begin
      if ( High(BIndexes) = i + 1 ) or
         ( DValue( BIndexes[i-1], BIndexes[i+1] ) + DValue( BIndexes[i+1], BIndexes[i+2] ) <
           DValue( BIndexes[i-1], BIndexes[i]   ) + DValue( BIndexes[i], BIndexes[i+2] ) ) then
        RemoveBInd( i )
      else
        RemoveBInd( i + 1 );
    end;
    Inc(i);
  end;
  i := High(BIndexes);
  if BIndexes[i] - BIndexes[i - 1] = 1 then
    RemoveBInd( i - 1 );

  if IRound >= 100 then
    FPrecision := 1
  else
    FPrecision := IntPower( 10.0, IRound );
  SetLength( Result, Length(BIndexes) - 2 );
  for i := 0 to High(Result) do
    Result[i] := Floor( Values[BIndexes[i+1]]* FPrecision )/FPrecision;

end; // end of K_BuildOptimalRanges2

//************************************************ K_BuildOptimalRanges3
//  calculate scale using values and precision
//
function K_BuildOptimalRanges3( Values : TN_DArray; NumRanges, IRound : Integer ) : TN_DArray;
var
  i, j, RInd, SInd, MInd : Integer;
  FPrecision, PWD, WD :  Double;
  BIndexesP, BIndexes : TN_IArray;
  MoveBoundsCountP, MoveBoundsCount : Integer;
  NCID, NRID,
  LID, LIDP, LIDM, RID, RIDP, RIDM,
  CID, CIDLP, CIDLM, CIDRP, CIDRM, CIDPP, CIDMM, CIDMP, CIDPM  : Double;
  SLInd, SRInd, SLIndN, SRIndN, SRRInd  : Integer;
  SmallIntervalLength : Integer;

  function MValue( BI, LI : Integer ) : Double;
  var i : Integer;
  begin
    Result := 0;
    for i := BI to LI - 1 do
      Result := Result + Values[i];
    LI := LI - BI;
    if LI > 0 then
      Result := Result/LI
    else
      Result := Values[BI];
  end;

  function DValue( BI,LI : Integer ) : Double;
  var
    i : Integer;
    M,D : Double;
  begin
    M := MValue( BI, LI );
    Result := 0;
    for i := BI to LI - 1 do begin
      D := Values[i] - M;
      Result := D * D;
    end;
  end;

  procedure RemoveBInd( RemvedInd : Integer );
  var
    H : Integer;
  begin
    H := High(BIndexes);
    Move( BIndexes[RemvedInd+1], BIndexes[RemvedInd], (H - RemvedInd) * SizeOf(Integer) );
    SetLength( BIndexes,  H );
//    Inc(MoveBoundsCount);
  end;

  procedure RemoveSmallIntervals;
  begin
    // Takeup N=1 Intervals Loop
    if BIndexes[1] <= SmallIntervalLength then
      RemoveBInd( 1 );
    i := 1;
    while i < High(BIndexes) do begin
      if BIndexes[i+1] - BIndexes[i] <= SmallIntervalLength then begin
        if ( High(BIndexes) = i + 1 ) or
           ( DValue( BIndexes[i-1], BIndexes[i+1] ) + DValue( BIndexes[i+1], BIndexes[i+2] ) <
             DValue( BIndexes[i-1], BIndexes[i]   ) + DValue( BIndexes[i], BIndexes[i+2] ) ) then
          RemoveBInd( i )
        else
          RemoveBInd( i + 1 );
      end;
      Inc(i);
    end;
    i := High(BIndexes);
    if BIndexes[i] - BIndexes[i - 1] <= SmallIntervalLength then
      RemoveBInd( i - 1 );
  end;

begin
  Result := K_BuildEqualNElemsRanges(Values, NumRanges, IRound);
  SInd := Length (Result);
  if (SInd = 0) or (SInd < NumRanges - 1) then Exit;
  RInd := High(Values);
  // Check if Number of Different values is Big
  MInd := Length(K_SearchDifValsInOrderedArray( Values, Values[0] - 1, Values[RInd] + 1 ));
  if MInd < 1.2 * SInd then Exit;
//  if MInd > 3 * SInd then
//    Result :=  K_BuildOptimalRanges0( Values, NumRanges, IRound, nil, nil );

  SetLength( BIndexes, Length(Result) + 2 );
  BIndexes[0] := 0;
  BIndexes[High(BIndexes)] := RInd+1;
// search Bound indexes
  j := 0;
  for i := 0 to High(Result) do begin
    while (Values[j] < Result[i]) and ( j < RInd ) do Inc(j);
    BIndexes[i+1] := j;
    Inc(j);
  end;

// Seach Optimal Bound Place
  SmallIntervalLength := Max( 1, Floor((RInd/NumRanges)*0.2) );
  repeat
    RemoveSmallIntervals;

    MoveBoundsCount := 0;
    BIndexesP := Copy(BIndexes);

    SLInd := BIndexes[1];
    SRInd := BIndexes[2];
    LID := DValue( 0, SLInd );
    LIDP := DValue( 0, SLInd + 1 );
    LIDM := DValue( 0, SLInd - 1 );
    CID :=   DValue( SLInd, SRInd );
    CIDLP := DValue( SLInd + 1, SRInd );
    CIDLM := DValue( SLInd - 1, SRInd );
    for i := 1 to High(BIndexes) - 2 do begin
      CIDRP := DValue( SLInd, SRInd + 1 );
      CIDRM := DValue( SLInd, SRInd - 1 );
      CIDPP := DValue( SLInd + 1, SRInd + 1 );
      CIDPM := DValue( SLInd + 1, SRInd - 1 );
      CIDMM := DValue( SLInd - 1, SRInd - 1 );
      CIDMP := DValue( SLInd - 1, SRInd + 1 );
      SRRInd := BIndexes[i+2];
      RID := DValue( SRInd, SRRInd );
      RIDP := DValue( SRInd + 1, SRRInd );
      RIDM := DValue( SRInd - 1, SRRInd );

      NCID := CID;
      NRID := RID;
      SLIndN := SLInd;
      SRIndN := SRInd;
      PWD := LID + CID + RID;
      // Left Boud -
      WD := LIDM + CIDLM + RID;
      if WD < PWD then begin
        PWD := WD;
        SLIndN := SLInd - 1;
        NCID := CIDLM;
        Inc(MoveBoundsCount);
      end;

      // Left Boud +
      WD := LIDP + CIDLP + RID;
      if WD < PWD then begin
        PWD := WD;
        SLIndN := SLInd + 1;
        NCID := CIDLP;
        Inc(MoveBoundsCount);
      end;

      // Right Bound -
      WD := LID + CIDRM + RIDM;
      if WD < PWD then begin
        PWD := WD;
        SRIndN := SRInd - 1;
        NCID := CIDRM;
        NRID := RIDM;
        SLIndN := SLInd;
        Inc(MoveBoundsCount);
      end;

      // Right Bound +
      WD := LID + CIDRP + RIDP;
      if WD < PWD then begin
        PWD := WD;
        SRIndN := SRInd + 1;
        NCID := CIDRP;
        NRID := RIDP;
        SLIndN := SLInd;
        Inc(MoveBoundsCount);
      end;

      // Left Boud - Right Bound -
      WD := LIDP + CIDMM + RIDM;
      if WD < PWD then begin
        PWD := WD;
        SLIndN := SLInd - 1;
        SRIndN := SRInd - 1;
        NCID := CIDMM;
        NRID := RIDM;
        Inc(MoveBoundsCount);
      end;

      // Left Boud - Right Bound +
      WD := LIDM + CIDMP + RIDP;
      if WD < PWD then begin
        PWD := WD;
        SLIndN := SLInd - 1;
        SRIndN := SRInd + 1;
        NCID := CIDMP;
        NRID := RIDP;
        Inc(MoveBoundsCount);
      end;

      // Left Boud + Right Bound +
      WD := LIDP + CIDPP + RIDP;
      if WD < PWD then begin
        PWD := WD;
        SLIndN := SLInd + 1;
        SRIndN := SRInd + 1;
        NCID := CIDPP;
        NRID := RIDP;
        Inc(MoveBoundsCount);
      end;

      // Left Boud + Right Bound -
      WD := LIDP + CIDPM + RIDM;
      if WD < PWD then begin
        SLIndN := SLInd + 1;
        SRIndN := SRInd - 1;
        NCID := CIDPM;
        NRID := RIDM;
        Inc(MoveBoundsCount);
      end;

      BIndexes[i] := SLIndN;
      BIndexes[i+1] := SRIndN;

      SLInd := SLIndN;
      SRInd := SRIndN;
      LID := NCID;
      if NCID = CID then begin
        LIDP := CIDRP;
        LIDM := CIDRM;
      end else begin
        LIDP := DValue( SLInd, SRInd + 1 );
        LIDM := DValue( SLInd, SRInd - 1 );
      end;

      CID := NRID;
      if NRID = RID then begin
        CIDLP := RIDP;
        CIDLM := RIDM;
      end else begin
        CIDLP := DValue( SRInd, SInd + 1 );
        CIDLM := DValue( SRInd, SInd - 1 );
      end;
      SLInd := SRInd;
      SRInd := SRRInd;
    end;

  until (MoveBoundsCount = 0) or
        CompareMem( @BIndexes[0], @BIndexesP[0], Length(BIndexes) * SizeOf(Integer) );

  RemoveSmallIntervals;

  if IRound >= 100 then
    FPrecision := 1
  else
    FPrecision := IntPower( 10.0, IRound );
  SetLength( Result, Length(BIndexes) - 2 );
  for i := 0 to High(Result) do
    Result[i] := Floor( Values[BIndexes[i+1]]* FPrecision )/FPrecision;

end; // end of K_BuildOptimalRanges3

//************************************************ K_BuildOptimalRanges1
//  calculate scale using values and precision
//
function K_BuildOptimalRanges1( Values : TN_DArray; NumRanges, IRound : Integer ) : TN_DArray;
var
  i, j, RInd, SInd, MInd : Integer;
  FPrecision, PWD, WD, SD :  Double;
  BIndexes : TN_IArray;
  Steps : TN_DArray;
  MStep : Double;

const
  CTakeUp = 1.5;

  function MValue( BI, LI : Integer ) : Double;
  var i : Integer;
  begin
    Result := 0;
    for i := BI to LI - 1 do
      Result := Result + Values[i];
    LI := LI - BI;
    if LI > 0 then
      Result := Result/LI
    else
      Result := Values[BI];
  end;

  function DValue( BI,LI : Integer ) : Double;
  var
    i : Integer;
    M,D : Double;
  begin
    M := MValue( BI, LI );
    Result := 0;
    for i := BI to LI - 1 do begin
      D := Values[i] - M;
      Result := D * D;
    end;
  end;

  function SearchMin0( ABInd : Integer ) : Integer;
  var
    BInd : Integer;
    IndFound : Boolean;
  begin
    Result := ABInd;
    MInd := ABInd;
    SInd := BIndexes[ABInd];
    SD := DValue( BIndexes[ABInd-1], SInd ) + DValue( SInd, BIndexes[ABInd+1] );
    WD := SD;
    BInd := BIndexes[ABInd - 1] + 1;
    IndFound := false;
    while SInd = BInd do begin
      PWD := WD;
      SInd := SInd - 1;
      if SInd >= 0 then
        WD := DValue( BIndexes[ABInd-1], SInd ) + DValue( SInd, BIndexes[ABInd+1] );
      IndFound := WD > PWD;
      if IndFound then Break;
    end;
    if IndFound then begin
    // Min Value was found
      BIndexes[ABInd] := SInd + 1;
      MInd := Result;
      Inc( Result );
    end else if Steps[SInd-1] <= MStep * CTakeUp then  begin
     // Take Up Interval - first from i-1 to i
      Move( BIndexes[ABInd+1], BIndexes[ABInd], (High(BIndexes) - ABInd) * SizeOf(Integer) );
      SetLength( BIndexes, High(BIndexes) );
      MInd := Result - 1;
    end;
  end;

  function SearchMin1( ABInd : Integer ) : Integer;
  var
    BInd : Integer;
    IndFound : Boolean;
  begin
    Result := ABInd;
    MInd := ABInd - 1;
    SInd := BIndexes[ABInd];
    SD := DValue( BIndexes[ABInd-1], SInd ) + DValue( SInd, BIndexes[ABInd+1] );
    WD := SD;
    BInd := BIndexes[ABInd + 1] - 1;
    IndFound := false;
    while SInd = BInd do begin
      PWD := WD;
      SInd := SInd + 1;
      if SInd >= 0 then
        WD := DValue( BIndexes[ABInd-1], SInd ) + DValue( SInd, BIndexes[ABInd+1] );
      IndFound := WD > PWD;
      if IndFound then Break;
    end;
    if IndFound then begin
    // Min Value was found
      BIndexes[ABInd] := SInd - 1;
      Inc( Result );
    end else if Steps[SInd + 1] <= MStep * CTakeUp then  begin
     // Take Up Interval - first from i-1 to i
      Move( BIndexes[ABInd+1], BIndexes[ABInd], (High(BIndexes) - ABInd) * SizeOf(Integer) );
      SetLength( BIndexes, High(BIndexes) );
    end;
  end;

  function SearchMin( VStep : Integer ) : Boolean;
  var
    BInd : Integer;
  begin
    Result := false;
    BInd := BIndexes[i + VStep] - VStep;
    while SInd = BInd do begin
      PWD := WD;
      SInd := SInd + VStep;
      if SInd >= 0 then
        WD := DValue( BIndexes[i-1], SInd ) + DValue( SInd, BIndexes[i+1] );
      Result := WD > PWD;
      if Result then Break;
    end;
  end;

begin
  Result := K_BuildOptimalRanges0(Values, NumRanges, IRound, @Steps, @MStep );
  if Length(Result) <= 1 then Exit;
  SetLength( BIndexes, Length(Result) + 2 );
  RInd := High(Values);
  BIndexes[0] := 0;
  BIndexes[High(BIndexes)] := RInd+1;
// search Bound indexes
  j := 0;
  for i := 0 to High(Result) do begin
    while (Values[j] < Result[i]) and ( j < RInd ) do Inc(j);
    BIndexes[i+1] := j;
  end;

// Seach for Bound Place

// Seach Optimal Bound Place
  i := 1;
  MInd := -100;
  while i < High(BIndexes)  do begin

    if Steps[BIndexes[i]] < MStep then begin
      if MInd = i - 1 then begin
      // Try to take up Left Prev Interval
         SInd := BIndexes[i];
         if DValue( BIndexes[i-1], BIndexes[i+1] ) < DValue( BIndexes[i-1], SInd ) + DValue( SInd, BIndexes[i+1] ) then begin
            Move( BIndexes[i+1], BIndexes[i], (High(BIndexes) - i) * SizeOf(Integer) );
            SetLength( BIndexes, High(BIndexes) );
            MInd := i;
            Inc(i);
         end;
      end else
      // Try to take up Left Interval
        i := SearchMin0( i );
    end else
      i := SearchMin1( i );
  end;

  if IRound >= 100 then Exit;
  FPrecision := IntPower( 10.0, IRound );
  SetLength( Result, High(BIndexes) - 2 );
  for i := 0 to High(Result) do
    Result[i] := Floor( Values[BIndexes[i+1]]* FPrecision )/FPrecision;
end; // end of K_BuildOptimalRanges1

//************************************************ K_BuildWeightedAverageRanges
//  Сalculate Vector scale using values, weights and precision
//
//     Parameters
// AValues     - Matrix values
// AWeights    - Matrix Column Weights
// ARangePower - range count power:
//#F
//  1 - 1 range bound, 2 groups
//  2 - 3 range bounds, 4 groups
//  3 - 7 range bounds, 8 groups
//  e.t.c.
//#/F
// AIRound     - Range bounds precision
//
function K_BuildWeightedAverageRanges( AValues : TN_DArray; AWeights : TN_DArray; ARangePower, AIRound : Integer ) : TN_DArray;
var
  VColLegth : Integer; // Source Vector Weights Length
  i : Integer;
  SortedInds : TN_IArray;
  SortedVals : TN_DArray;
  SortedWeights : TN_DArray;
  V1 : Double;

  function CalcWeightedAverage( APVals, APWeight : PDouble; ABoundVal : Double;
                                ADCount : Integer; out ARCount : Integer ) : Double;
  var
    WSum : Double;
    j : Integer;
  begin
    Result := 0;
    WSum   := 0;
    ARCount := 0;
    for j := 1 to ADCount do
    begin
      if APVals^ > ABoundVal then Break;
      Result := Result + APVals^ * APWeight^;
      WSum := WSum + APWeight^;
      Inc(ARCount);
      Inc(APVals);
      Inc(APWeight);
    end;
    if WSum <> 0 then
      Result := Result / WSum;
  end;

  function AddWeightedAverageRanges( APVals, APWeight : PDouble;
                                     ASRanges : TN_DArray  ) : TN_DArray;
  var
    RL, SL : Integer;
    j : Integer;
    VMax : Double;
    CICountR, CICount : Integer;
    RInd : Integer;

  begin
    SL := Length(ASRanges);
    RL := (SL + 1) * 2 - 1;
    SetLength( Result, RL );
    CICount := VColLegth;
    RInd := 0;

    for j := 0 to SL do
    begin
      if SL = j then
        VMax := MaxDouble
      else
        VMax := ASRanges[j];

      Result[RInd] := CalcWeightedAverage( APVals, APWeight, VMax, CICount, CICountR );
      CICount := CICount - CICountR;
      if CICount <= 0 then Break;

      // Next Range Start Prepare
      Result[RInd + 1] := VMax;
      RInd := RInd + 2;
      TN_BytesPtr(APVals) := TN_BytesPtr(APVals) + SizeOf(Double) * CICountR;
      TN_BytesPtr(APWeight) := TN_BytesPtr(APWeight) + SizeOf(Double) * CICountR;
    end;
  end;

begin
  if ARangePower <= 0 then ARangePower := 1;
  Result := nil;
  VColLegth := Length(AWeights);
  if VColLegth = 0 then
    VColLegth := Length(AValues);
  SetLength( SortedInds, VColLegth );
  K_BuildSortedDoubleInds( @SortedInds[0], @AValues[0], VColLegth, FALSE );

  SetLength( SortedVals, VColLegth );
  SetLength( SortedWeights, VColLegth );
  K_MoveVectorBySIndex( SortedVals[0], SizeOf(Double),
                        AValues[0], SizeOf(Double), SizeOf(Double),
                        VColLegth, @SortedInds[0] );
  if Length(AWeights) > 0 then
    K_MoveVectorBySIndex( SortedWeights[0], SizeOf(Double),
                          AWeights[0], SizeOf(Double), SizeOf(Double),
                          VColLegth, @SortedInds[0] )
  else
  begin
    V1 := 1.0;
    K_MoveVector( SortedWeights[0], SizeOf(Double), V1, 0,
                  SizeOf(Double), VColLegth );
  end;

  for i := 1 to ARangePower do
    Result := AddWeightedAverageRanges( @SortedVals[0], @SortedWeights[0], Result );

//*** scale
  K_DArrayRound0( @Result[0],  Length( Result), SizeOf(Double), AIRound );

end; // function K_BuildWeightedAverageRanges

//************************************************ K_BuildBestWorstRanges
//  Сalculate Vector scale using values and precision
//
//     Parameters
// AValues     - Matrix values
// ABestWorstCount  - number of the best and the worst data elements
// AIRound     - Range bounds precision
//
function K_BuildBestWorstRanges( AValues : TN_DArray; ABestWorstCount, AIRound : Integer ) : TN_DArray;
var
  VColLegth : Integer; // Source Vector Weights Length
  i, IM1, IM2, IMin, IMax : Integer;
  SortedInds : TN_IArray;
  SortedVals : TN_DArray;
begin
  Result := nil;
  VColLegth := Length(AValues);
  SetLength( SortedInds, VColLegth );
  K_BuildSortedDoubleInds( @SortedInds[0], @AValues[0], VColLegth, FALSE );

  SetLength( SortedVals, VColLegth );
  K_MoveVectorBySIndex( SortedVals[0], SizeOf(Double),
                        AValues[0], SizeOf(Double), SizeOf(Double),
                        VColLegth, @SortedInds[0] );

  if VColLegth = 1 then
  begin
    SetLength( Result, 1 );
    Result[0] := SortedVals[0];
  end
  else
  begin
    if ABestWorstCount >= VColLegth  then
      ABestWorstCount := VColLegth div 2;
    SetLength( Result, 2 );
    IMin := ABestWorstCount;
    Result[0] := SortedVals[IMin];
    IM1 := IMin; // Precation
    IM2 := IMin; // Precation
    for i := IMin + 1 to VColLegth - 1 do
      if Result[0] < SortedVals[i] then
      begin
        IM1 := i;
        break;
      end;
    for i := IMin - 1 downto 0 do
      if Result[0] > SortedVals[i] then
      begin
        IM2 := i;
        break;
      end;
{
    if IM1 - IMin <= IMin - IM2 then
      IMin := IM1
    else
      IMin := IM2;
    Result[0] := (SortedVals[IMin] + SortedVals[IMin + 1]) / 2;
}
    if IM1 - IMin < IMin - IM2 then
      Result[0] := SortedVals[IM1];

    IMax := VColLegth - ABestWorstCount;
    Result[1] := SortedVals[IMax];
    for i := IMax - 1 downto 0 do
      if Result[1] > SortedVals[i] then
      begin
        IM1 := i;
        break;
      end;

    for i := IMax + 1 to VColLegth - 1 do
      if Result[1] < SortedVals[i] then
      begin
        IM2 := i;
        break;
      end;
{
    if IMax - IM1 <= IM2 - IMax then
      IMax := IM1
    else
      IMax := IM2 - 1;
    Result[1] := (SortedVals[IMax] + SortedVals[IMax + 1]) / 2;
}
    if IMax - IM1 > IM2 - IMax then
      Result[1] := SortedVals[IM2];
  end;
//*** scale
  K_DArrayRound0( @Result[0],  Length( Result), SizeOf(Double), AIRound );

end; // function K_BuildBestWorstRanges

//************************************************ K_BuildStandardDeviationRanges
//  Сalculate Vector scale using values, average deviation and precision
//
//     Parameters
// AValues     - Matrix values
// AIRound     - Range bounds precision
//
function  K_BuildStandardDeviationRanges( APRValue : PDouble; ARCount : Integer;
                                          var AIRound : Integer; ASVal : Double ) : TN_DArray;
var
  i, j, k : Integer;
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  AMean, ASigma : Double;
{$ELSE}         // Delphi 7 or Delphi 2010
  AMean, ASigma : Extended;
{$IFEND CompilerVersion >= 26.0}
  PureValues : TN_DArray;
  MDelta : Double;
  PCurValue : PDouble;
begin
  Result := nil;
  if ASVal = 0 then
    ASVal := K_MVMinVal - 100; // Special Value for "Bad" Values Marking
  for j := 0 to 2 do
  begin
    PureValues := K_GetDVectorNotSpecValuesArray( APRValue,  ARCount, nil );
    MeanAndStdDev(PureValues, AMean, ASigma );
    k := 0;
    MDelta := 3*ASigma;
    PCurValue := APRValue;
    // Replace "Bad" Values by Special Value
    for i := 0 to ARCount  - 1 do
    begin
      if (PCurValue^ < K_MVMaxVal) and
         (PCurValue^ > K_MVMinVal) and
         (Abs(PCurValue^ - AMean) > MDelta) then
      begin
        PCurValue^ := ASVal;
        Inc(k);
      end;
      Inc(PCurValue);
    end;
    if k = 0 then Break; // All Done
  end;

//*** scale
  if ASigma = 0 then
    ASigma := IntPower( 10.0, -AIRound );

  SetLength( Result, 4 );
  Result[0] := AMean - 2*ASigma;
  Result[1] := AMean -   ASigma;
  Result[2] := AMean +   ASigma;
  Result[3] := AMean + 2*ASigma;

  AIRound := Floor(Max(-Log10(ASigma), AIRound));
  K_DArrayRound0( @Result[0],  Length( Result), SizeOf(Double), AIRound );

end; // function K_BuildStandardDeviationRanges

//************************************************ K_SearchDifValsInOrderedArray
//  calculate discrete ranges
//
function K_SearchDifValsInOrderedArray( Values : TN_DArray; VMin, VMax : Double;
                                        MaxClassCount : Integer = 0 ) : TN_DArray;
var
  j, i : Integer;

begin
  SetLength( Result, Length(Values) );
  if Length(Values) = 0 then Exit;

  Result[0] := Values[0];
  j := 0;
  for i := 1 to High(Values) do begin
    if ( Values[i] > VMin ) and
       ( Values[i] < VMax ) and
       ( Values[i] <> Result[j] ) then begin
      Inc(j);
      Result[j] := Values[i];
      if (MaxClassCount > 0) and (j >= MaxClassCount) then break;
    end;
  end;
  SetLength( Result, j + 1 );
end; // end of K_SearchDifValsInOrderedArray

//************************************************ K_BuildDiscreteRanges
//  calculate discrete ranges
//
function K_BuildDiscreteRanges( Values : TN_DArray; VMin, VMax : Double ) : TN_DArray;
begin
  if Length(Values) > 0 then begin
    N_SortElements( TN_BytesPtr(@Values[0]), Length(Values), SizeOf(Double), 0, N_CompareDoubles);
    Result := K_SearchDifValsInOrderedArray( Values, VMin, VMax );
  end else
    SetLength( Result, 0 );
end; // end of K_BuildDiscreteRanges

{
//********************************************* K_ToASArray ***
//  convert specified data vector to column in string matrix
//
procedure K_ToASArray( SM : TN_ASArray; ACol,ARow : Integer; const convArr;
                                vtype : TK_ParamType; const fmt : string = '' );
var i, AHigh : Integer;
DD : TK_DataBuf;
begin
  AHigh := K_ArrayHigh( convArr, vtype );
  for i := 0 to AHigh do
  begin
    K_GetElementValue( convArr, i, DD, vtype );
    SM[ARow][ACol] := K_DataBufToString( DD, vtype );
    Inc(ARow);
  end;
end;

//********************************************* K_ToSArray ***
//  convert specified data vector to string vector
//  returns TN_SArray
function K_ToSArray( const convArr;  vtype : TK_ParamType; fmt : string = '' ) : TN_SArray;
var i : Integer;
DataBuf : TK_DataBuf;
begin
  SetLength( Result, K_ArrayHigh(convArr, vtype)+1 );
  if Length(fmt) = 0 then fmt := TK_defConvFmt[Ord(vtype)];
  for i := 0 to High(Result) do
  begin
    K_GetElementValue( convArr, i, DataBuf, vtype );
    Result[i] := K_DataBufToString( DataBuf, vtype, fmt );
  end;
end;
}

//********************************************* K_ToString ***
//  convert specified data to string
//  returns string
function K_ToString( const Value;  vtype : TK_ParamType; fmt : string = '' ) : string;
begin
  case vtype of
    K_isHex16: Result := '$'+IntToHex( Int64(Value), 16 );
  else
    if CompareStr( fmt, '' ) = 0 then fmt := TK_defConvFmt[Ord(vtype)];
    case vtype of
      K_isInteger, K_isIntegerArray,
      K_isUInt4, K_isUInt4Array,
      K_isHex, K_isHexArray :
        Result := format( fmt, [Integer(Value)] );
      K_isDouble, K_isDoubleArray :
        Result := K_ReplaceCommaByPoint( format( fmt, [Double(Value)] ) );
      K_isFloat, K_isFloatArray :
        Result := K_ReplaceCommaByPoint( format( fmt, [Single(Value)] ) );
      K_isString, K_isStringArray  :
        Result := format( fmt, [PString(@Value)^] );
      K_isInt2, K_isInt2Array : Result := format( fmt, [SmallInt(Value)] );
      K_isUInt2, K_isUInt2Array : Result := format( fmt, [Word(Value)] );
      K_isUInt1, K_isUInt1Array : Result := format( fmt, [Byte(Value)] );
      K_isInt1, K_isInt1Array : Result := format( fmt, [ShortInt(Value)] );
      K_isInt64, K_isInt64Array :
        Result := IntToStr( Int64(Value) );
      K_isDateTime, K_isDateTimeArray,
      K_isDate, K_isDateArray : Result := K_DateTimeToSTr( TDateTime(Value), fmt );
      K_isBoolean, K_isBoolArray :
        if Boolean(Value) then
          Result := 'true'
        else
          Result := 'false'
    else
      assert( true, 'Wrong Data Buf type' );
    end;
  end;
end;

//********************************************* K_FromString ***
//  scanf specified data from string
//
procedure K_FromString( const Str : string; var Value;  vtype : TK_ParamType; fmt : string = '' );
var IBuf, code : Integer;
Dval : Double;
Sval : Single;
LW : LongWord;
begin
  case vtype of
    K_isInteger, K_isIntegerArray:
      Integer(value) := StrToIntDef( str, 0 );
    K_isUInt4, K_isUInt4Array,
    K_isHex, K_isHexArray        :
    begin
      Val( Str, LW, code );
      if code = 0 then
        LongWord(Value) := LW;
    end;
    K_isDouble, K_isDoubleArray  :
    begin
      Val( Str, Dval, code );
      if code = 0 then
        Double(Value) := Dval;
    end;
    K_isString, K_isStringArray  : PString(@value)^ :=  Str;
    K_isInt2, K_isUInt2,
    K_isInt2Array, K_isUInt2Array :
    begin
      LongWord(IBuf) := LongWord(StrToIntDef( str, 0 ));
      Word(Value) := IBuf and $FFFF;
    end;
    K_isUInt1, K_isInt1,
    K_isUInt1Array, K_isInt1Array :
    begin
      LongWord(IBuf) := LongWord(StrToIntDef( str, 0 ));
      Byte(Value) := IBuf and $FF;
    end;
    K_isInt64, K_isInt64Array, K_isHex16 :
    begin
//      Int64(Value) := 0;
      Int64(Value) := StrToInt64Def( Str, 0 );
    end;
    K_isDateTime, K_isDateTimeArray,
    K_isDate, K_isDateArray      : TDateTime(Value) := K_StrToDateTime( Str );
    K_isBoolean, K_isBoolArray   : Boolean(Value) :=  ((Str[1] = 't') or (Str[1] = 'T'));
    K_isFloat, K_isFloatArray  :
    begin
      Val( Str, Sval, code );
      if code = 0 then
        Single(Value) := Sval;
    end;
  else
    assert( true, 'Wrong Data Buf type' );
  end;
end;

{
//********************************************* K_SArrayConcat ***
//  concatenate string vector with string vector or some scalar
//  returns TN_SArray
function K_SArrayConcat( const op1 : TN_SArray; const op2; op2type : TK_ParamType = K_isStringArray ) : TN_SArray;
var i, hind: Integer;
vp : string;
begin
  hind := High(op1);
  if op2type <> K_isStringArray
  then vp := k_toString( op2, op2type )
  else hind := min( hind, High(TN_SArray(op2)) );
  for i := 0 to hind do
  begin
    if op2type = K_isStringArray then vp := TN_SArray(op2)[i];
    op1[i] := op1[i] + vp;
  end;
  Result := op1;
end;

//********************************************* K_ArraySetByScale ***
//  set new values to string vector using source strings, scale and values
//
procedure K_ArraySetByScale( const dest, src; vtype : TK_ParamType;  const values, scale : TN_DArray );
var
  i, vind, si, hsi, imax: Integer;
  dd : TK_DataBuf;
  pscale : PDouble;
begin
  vind := K_ArrayHigh(dest, vtype);
  vind := Min( vind, High(values) );
  hsi := K_ArrayHigh(src, vtype);
  imax := High(scale);
  if imax >= 0 then
    pscale := @scale[0]
  else
    pscale := nil;

  for i := 0 to vind do
  begin
    si := K_SearchInScale( pscale, imax, sizeof(Double), values[i] );
    si := min( hsi, si );
    K_GetElementValue( src, si, dd, vtype );
    K_PutElementValue( dest, i, dd, vtype );
  end;
end;

//********************************************* K_CalcScaleRangeNumbers ***
//  calculate number of values in scale ranges
//
procedure K_CalcScaleRangeNumbers( const numbers : TN_IArray; const values, scale : TN_DArray );
var
  imax, i, si, hsi: Integer;
  pscale : PDouble;
begin
  hsi := High(numbers);
  for i := 0 to hsi do numbers[i] := 0;
  imax := High(scale);
  pscale := @scale[0];
  for i := 0 to High(values) do
  begin
    si := K_SearchInScale( pscale, imax, sizeof(Double), values[i] );
    si := Min( hsi, si );
    Inc(numbers[si])
  end;
end;


//********************************************* K_ArrayCopy ***
//  cast number vector to number vector
//
procedure K_ArrayCopy( const dest, src; vtype : TK_ParamType;
        Dind : Integer = 0; Sind : Integer = 0; Count : Integer = 0 );
var DCount, SCount : Integer;
PS, PD : pointer;
begin
  DCount := K_ArrayHigh( Dest, vtype ) - Dind;
  SCount := K_ArrayHigh( Src, vtype ) - Sind;
  DCount := Min(DCount, SCount) + 1;
  PS := nil;
  PD := nil;
  if Count > 0 then
    DCount := Min(DCount, Count);
  case vtype of
    K_isInteger, K_isIntegerArray,
    K_isHex, K_isHexArray :
    begin
      PS := @TN_IArray(src)[Sind];
      PD := @TN_IArray(dest)[Dind];
    end;
    K_isDouble, K_isDoubleArray :
    begin
      PS := @TN_DArray(src)[Sind];
      PD := @TN_DArray(dest)[Dind];
    end;
    K_isUInt1, K_isUInt1Array,
    K_isInt1, K_isInt1Array:
    begin
      PS := @TN_BArray(src)[Sind];
      PD := @TN_BArray(dest)[Dind];
    end;
    K_isString, K_isStringArray :
    begin
      PS := @TN_SArray(src)[Sind];
      PD := @TN_SArray(dest)[Dind];
    end;
  end;
  move( PS^, PD^, DCount * K_SizeOf( vtype ) );
end;

//********************************************* K_ArrayCast ***
//  cast number vector to number vector
//
procedure K_ArrayCast( const dest; dtype : TK_ParamType; const src; stype : TK_ParamType );
var i, hind, hs: Integer;
begin
  hind := K_arrayHigh( Dest, dtype );
  hs := K_arrayHigh( Src, stype );
  hind := Min(hind, hs);
  for i := 0 to hind do
  begin
    case dtype of
      K_isInteger, K_isIntegerArray,
      K_isHex, K_isHexArray :
      begin
        case stype of
          K_isDouble, K_isDoubleArray :
            TN_IArray(dest)[i] := Round(TN_DArray(src)[i]);
        end;
      end;
      K_isDouble, K_isDoubleArray :
      begin
        case stype of
          K_isInteger, K_isIntegerArray :
            TN_DArray(dest)[i] := TN_IArray(src)[i];
        end;
      end;
    end;
  end;
end;

//********************************************* K_NotIndexBuild ***
//  build vector elements inversed to specified
//  retuns vector of inversed
//
function  K_NotIndexBuild( var index : TN_IArray; leng : Integer ) : TN_IArray;
var i, j, nleng, uind, hind : Integer;
begin
  SetLength( Result, leng );
  nleng := 0;
  uind := 0;
  for i := 0 to High(index) do
  begin
    hind := index[i];
    for j := uind to hind - 1 do
    begin
      Result[nleng] := j;
      Inc(nleng);
    end;
    uind := hind + 1;
  end;
  for j := uind to High(Result) do
  begin
    Result[nleng] := j;
    Inc(nleng);
  end;
  SetLength( Result, nleng );
end;

{
//********************************************* K_NArrayZoneIndexBuild ***
//  build indexes of vector elements which are the members of zone
//  retuns number of used integer vector elements
//
function  K_NArrayZoneIndexBuild( const values; vtype : TK_ParamType; var index : TN_IArray; vmin, vmax : DOuble ) : Integer;
var i, hind : Integer;
v : Double;
begin
  hind := K_ArrayHigh(values, vtype);
  if High(index) < hind then SetLength(index, hind+1);
  Result := 0;
  v := vmin;
  for i := 0 to hind do
  begin
    case vtype of
      K_isDouble, K_isDoubleArray :
        v := TN_DArray(values)[i];
      K_isInteger, K_isIntegerArray,
      K_isHex, K_isHexArray :
        v := TN_IArray(values)[i];
    end;

    if ( v >= vmin ) and
       ( v < vmax ) then
    begin
      index[Result] := i;
      Inc(Result);
    end;
  end;
end;

//********************************************* K_ArraySetByIndex ***
//  set vector elements using index vector
//  retuns number of operating vector elemnts
//
function  K_ArraySetByIndex( const dest, src; vtype : TK_ParamType;
                const index : TN_IArray; useIndex : TK_IndexUseType;
                indexHigh : Integer = -1; indexStart : Integer = 0 ) : Integer;
var
  i, si, di, hind, hs, hd : Integer;
  dd : TK_DataBuf;
begin
  hs := K_ArrayHigh( src, vtype );
  hd := K_ArrayHigh( dest, vtype );

  hind := High(index);
  if indexHigh < 0 then
    indexHigh := hind;
  hind := Min(indexHigh, hind);

  if indexStart < 0 then indexStart := 0;
  Result := hind - indexStart + 1;
  for i := indexStart to hind do
  begin
    if index[i] < 0 then continue;
    if useIndex = K_inDest then
    begin //*** use indexes for dest array
//      si := Min(i, hs);
      si := i;
      di := index[i];
    end else
    begin //*** use indexes for src array
      si := index[i];
      di := i;
    end;
    if (si > hs) or (di > hd) then continue;
    K_GetElementValue( src, si, dd, vtype );
    K_PutElementValue( dest, di, dd, vtype );
  end;
end;

//************************************************ K_BuildIndexFromCodes ***
//
procedure K_BuildIndexFromCodes( const scodes, ncodes : TN_IArray; var indexes : TN_IArray );
var i, j : Integer;
begin
//*** clear indexes
  for i := 0 to High( indexes ) do indexes[i] := -1;
//*** link new exchange codes
  for i := 0 to High( ncodes ) do
//    searchExCode( i, ncodes[i], scodes, indexes);
    for j := 0 to High( scodes ) do
      if (indexes[j] = -1) and
         (ncodes[i] <> -1) and
         (scodes[j] = ncodes[i]) then
        indexes[j] := i;
end;

//************************************************ K_BuildIndexFromDCodes ***
//
procedure K_BuildIndexFromDCodes( const scodes, ncodes : TN_DArray; var indexes : TN_IArray );
var i, j : Integer;
begin
//*** clear indexes
  for i := 0 to High( indexes ) do indexes[i] := -1;
//*** link new exchange codes
  for i := 0 to High( ncodes ) do
//    searchExCode( i, ncodes[i], scodes, indexes);
    for j := 0 to High( scodes ) do
      if (indexes[j] = -1) and
         (ncodes[i] <> -1) and
         (scodes[j] = ncodes[i]) then
        indexes[j] := i;
end;

//************************************************ K_BuildBackIndex ***
//
procedure K_BuildBackIndex( const indexes : TN_IArray; var bindexes : TN_IArray );
var
//  i, j : Integer;
  bMax : Integer;
begin
//*** clear indexes
  bMax := MaxIntValue( indexes ) + 1;
  if bMax < 0 then bMax := 0;
//??  SetLength( bindexes, Max( bMax, Length(indexes) ) );
  SetLength( bindexes, Max( bMax, Length(bindexes) ) );

  K_BuildBackIndex0( @indexes[0], Length(indexes), @bindexes[0], Length(bindexes) );
end; // end of procedure K_BuildBackIndex

//************************************************ K_BuildSortIndex
//
procedure K_BuildSortIndex( PSortedIndex : PInteger; PElemArray: Pointer;
        ElemCount, ElemSize: integer;
        CompareParam: integer; CompareFunc: TN_CompareFunc );
var
  Ptrs: TN_PArray;
//  i : integer;
begin
  Ptrs := N_GetPtrsArrayToElems( PElemArray, ElemCount, ElemSize );
  N_SortPointers( Ptrs, CompareParam, CompareFunc );
  N_PtrsArrayToElemInds( PSortedIndex, Ptrs, PElemArray, ElemSize );
end; // end of procedure K_BuildSortIndex
}

//************************************************ K_BuildSortIndex0
//
procedure K_BuildSortIndex0( PSortedIndex : PInteger; PP : TN_PArray;
    CompareParam: integer; CompareFunc: TN_CompareFunc; PElemBase : TN_BytesPtr = nil;
    ElemSize : Integer = 0 );
begin
  if PElemBase = nil then
    PElemBase := PP[0];
  if ElemSize = 0 then
    ElemSize := TN_BytesPtr(PP[1]) - TN_BytesPtr(PP[0]);
  N_SortPointers( PP, CompareParam, CompareFunc );
  N_PtrsArrayToElemInds( PSortedIndex, PP, PElemBase, ElemSize );
end; // end of procedure K_BuildSortIndex

//************************************************ K_BuildSortedDoubleInds
//
procedure K_BuildSortedDoublePointers( PtrsArray : TN_PArray;
                                       DescendingOrder : Boolean;
                                       Offset : Integer = 0 );
begin
  N_CFuncs.Offset := Offset;
  N_CFuncs.DescOrder := DescendingOrder;
  N_SortPointers( PtrsArray, N_CFuncs.CompOneDouble );
end; // end of procedure K_BuildSortedDoublePointers

//************************************************ K_BuildSortedDoubleInds
//
procedure K_BuildSortedDoubleInds( PIndices: PInteger; PBegElem: Pointer;
                  ElemCount : Integer; DescendingOrder : Boolean;
                  ElemSize : Integer = SizeOf(Double); Offset : Integer = 0 );
var
  PtrsArray : TN_PArray;
begin
  PtrsArray := N_GetPtrsArrayToElems( PBegElem, ElemCount, ElemSize );
  K_BuildSortedDoublePointers( PtrsArray, DescendingOrder, Offset );
  N_PtrsArrayToElemInds( PIndices, PtrsArray, PBegElem, ElemSize );
//  N_BuildSortedElemInds( PIndices, PElemBase, ElemCount, ElemSize, N_CFuncs.CompOneDouble );
end; // end of procedure K_BuildSortedDoubleInds

//************************************************ K_SCIndexFromICodes ***
//  Build indexes -> projection from Dest Codes to Src Codes
//    DCodes[i] = SCode[Indexes[i]] (Codes - Integers)
//
function K_SCIndexFromICodes( PIndexes, PDCodes : PInteger; DCLeng : Integer;
                            PSCodes : PInteger; SCLeng : Integer ) : Integer;
var
  i, j : Integer;
  WPSCodes : PInteger;
begin
  Result := 0;
  for i := 1 to DCLeng do begin
    WPSCodes := PSCodes;
    PIndexes^ := -1;
    for j := 1 to SCLeng do begin
//??      if (PDCodes^ <> -1) and
      if (PDCodes^ >= 0) and
         (WPSCodes^ = PDCodes^) then begin
        PIndexes^ := j - 1;
        Inc( Result );
        break;
      end;
      Inc( TN_BytesPtr(WPSCodes), SizeOf(Integer) );
    end;
    Inc( TN_BytesPtr(PIndexes), SizeOf(Integer) );
    Inc( TN_BytesPtr(PDCodes), SizeOf(Integer) );
  end;
end; //*** procedure K_SCIndexFromICodes

//************************************************ K_SCIndexFromSCodes ***
//  Build indexes -> projection from Dest Codes to Src Codes
//    DCodes[i] = SCode[Indexes[i]] (Codes - Strings)
//
function K_SCIndexFromSCodes( PIndices : PInteger;
                    PDCodes : PString; DCLeng : Integer;
                    PSCodes : PString; SCLeng : Integer ) : Integer;
var
  i, j : Integer;
  WPSCodes : PString;
begin
  Result := 0;
  for i := 1 to DCLeng do begin
    WPSCodes := PSCodes;
    PIndices^ := -1;
    if (PDCodes^ <> '') then
      for j := 1 to SCLeng do begin
        if (WPSCodes^ = PDCodes^) then begin
          PIndices^ := j - 1;
          Inc( Result );
          break;
        end;
        Inc( WPSCodes );
      end;
    Inc( PIndices );
    Inc( PDCodes );
  end;
end; //*** procedure K_SCIndexFromSCodes

//************************************************ K_MoveVectorBySIndex
//  Copy data by source index using simple Move routine
//  DData[i] := SData[Ind[i]]
//
function  K_MoveVectorBySIndex( var   DData; DStep :Integer;
                             const SData; SStep :Integer; DSize : Integer;
                             DCount : Integer; PIndex : PInteger;
                             IStep : Integer = SizeOf(Integer) ) : Integer;
var
  i, ci : Integer;
  PSData, PDData : TN_BytesPtr;
begin
  PDData := @DData;
  PSData := @SData;
  if SStep = -1 then SStep := DSize;
  if DStep = -1 then DStep := DSize;
  if DStep = 0 then DStep := SStep;
  Result := 0;
  for i := 1 to DCount do begin
    ci := PIndex^;
    if ci >= 0 then begin
      Move( (PSData + ci * SStep)^, PDData^, DSize );
      Inc(Result);
    end;
    Inc(PDData, DStep);
    Inc(TN_BytesPtr(PIndex), IStep );
  end;
end; //*** end of function K_MoveVectorBySIndex

//************************************************ K_MoveVectorByDIndex
//  Copy data by dest index using simple Move routine
//  DData[Ind[i]] := SData[i]
//
function  K_MoveVectorByDIndex( var   DData; DStep :Integer;
                             const SData; SStep :Integer; DSize : Integer;
                             DCount : Integer; PIndex : PInteger;
                             IStep : Integer = SizeOf(Integer) ) : Integer;
var
  i, ci : Integer;
  PSData, PDData : TN_BytesPtr;
begin
  PDData := @DData;
  PSData := @SData;
  if SStep = -1 then SStep := DSize;
  if DStep = -1 then DStep := DSize;
  if DStep = 0  then DStep := SStep;
  Result := 0;
  for i := 1 to DCount do begin
    ci := PIndex^;
    if ci >= 0 then begin
      Move( (PSData)^, (PDData + ci * DStep)^, DSize );
      Inc(Result);
    end;
    Inc(PSData, SStep);
    Inc(TN_BytesPtr(PIndex), IStep );
  end;
end; //*** end of function K_MoveVectorByDIndex

//************************************************ K_MoveVectorByBIndex
//  Copy data by source and dest index using simple Move routine
//  DData[Ind[i]] := SData[Ind[i]]
//
function  K_MoveVectorByBIndex( var   DData; DStep :Integer;
                             const SData; SStep :Integer; DSize : Integer;
                             DCount : Integer; PIndex : PInteger;
                             IStep : Integer = SizeOf(Integer) ) : Integer;
var
  i, ci : Integer;
  PSData, PDData : TN_BytesPtr;
begin
  PDData := @DData;
  PSData := @SData;
  if SStep = -1 then SStep := DSize;
  if DStep = -1 then DStep := DSize;
  if DStep = 0 then DStep := SStep;
  Result := 0;
  for i := 1 to DCount do begin
    ci := PIndex^;
    if ci >= 0 then begin
      Move( (PSData + ci * SStep)^, (PDData + ci * DStep)^, DSize );
      Inc(Result);
    end;
    Inc(TN_BytesPtr(PIndex), IStep );
  end;
end; //*** end of function K_MoveVectorByBIndex

//************************************************ K_MoveMatrixBySIndex
//  Copy matrix data by source indices using simple Move routine
//  DData[i,j] := SData[CInd[i],RInd[j]]
//
function  K_MoveMatrixBySIndex( var   DMData; DStep0 : Integer; DStep1 : Integer;
                                    const SMData; SStep0 : Integer; SStep1 : Integer;
                                    DSize : Integer;
                                    DCount0, DCount1 : Integer;
                                    PIndex0 : PInteger = nil; PIndex1 : PInteger = nil;
                                    IStep0 : Integer = SizeOf(Integer);
                                    IStep1 : Integer = SizeOf(Integer) ) : Integer;
var
  i, ci : Integer;
  PSData, PDData : TN_BytesPtr;


begin

  PDData := @DMData;

  if SStep0 = -1 then SStep0 := DSize;
  if DStep0 = -1 then DStep0 := DSize;
  if DStep0 = 0 then DStep0 := SStep0;

  if SStep1 = -1 then SStep1 := DSize;
  if DStep1 = -1 then DStep1 := DSize;
  if DStep1 = 0 then DStep1 := SStep1;

  Result := 0;
  for i := 0 to DCount1 - 1 do begin
    ci := i;
    if PIndex1 <> nil then begin
      ci := PIndex1^;
      Inc(TN_BytesPtr(PIndex1), IStep1 );
    end;
    if ci >= 0 then begin
      PSData := TN_BytesPtr(@SMData) + ci * SStep1;
      if PIndex0 = nil then begin
        K_MoveVector( PDData^, DStep0, PSData^, SStep0, DSize, DCount0 );
        Result := Result + DCount0;
      end else
        Result := Result + K_MoveVectorBySIndex( PDData^, DStep0, PSData^, SStep0,
                               DSize, DCount0, PIndex0, IStep0 );
    end;
    Inc(PDData, DStep1);
  end;
end; //*** end of function K_MoveMatrixBySIndex

//********************************************* K_MoveVector ***
//  Copy data using simple Move routine
//  SStep = -1 -> SStep := DSize
//  DStep = -1 -> DStep := DSize
//  DStep = 0  -> DStep := SStep
//
procedure K_MoveVector( var DData; DStep :Integer; const SData; SStep :Integer;
                                  DSize : Integer; DCount : Integer );
var
  i : Integer;
  PSData, PDData : TN_BytesPtr;
begin
  PDData := @DData;
  PSData := @SData;
  if SStep = -1 then SStep := DSize;
  if DStep = -1 then DStep := DSize;
  if DStep = 0 then DStep := SStep;
  if (DStep = SStep) and (DStep = DSize) then
    Move( PSData^, PDData^, DSize * DCount )
  else
    for i := 1 to DCount do begin
      Move( PSData^, PDData^, DSize );
      Inc(PDData, DStep);
      Inc(PSData, SStep);
    end;
end; //*** end of procedure K_MoveVector

//********************************************* K_MoveStrings ***
//  Copy data using simple Move routine
//  SStep = -1 -> SStep := DSize
//  DStep = -1 -> DStep := DSize
//  DStep = 0  -> DStep := SStep
//
//procedure K_MoveStrings( PDStr : Pointer; DStep :Integer;
//                         PSStr : Pointer; SStep :Integer;
//                         DCount : Integer );
procedure K_MoveStrings( var DStr : string; DStep :Integer;
                         var SStr : string; SStep :Integer;
                         DCount : Integer );
var
  i : Integer;
  PSData, PDData : TN_BytesPtr;
begin
  PDData := TN_BytesPtr(@DStr);
  PSData := TN_BytesPtr(@SStr);
  if SStep = -1 then SStep := SizeOf(string);
  if DStep = -1 then DStep := SizeOf(string);
  if DStep = 0 then DStep := SStep;
  for i := 1 to DCount do begin
    PString(PDData)^ := PString(PSData)^;
    Inc(PDData, DStep);
    Inc(PSData, SStep);
//    PString(PDStr)^ := PString(PSStr)^;
//    Inc(PChar(PDStr), DStep);
//    Inc(PChar(PSStr), SStep);
  end;
end; //*** end of procedure K_MoveStrings

//********************************************* K_DataReverse ***
//  Reverse data in selected area
//
procedure K_DataReverse( var Data; DSize : Integer; DCount : Integer; DStep : Integer = 0 );
var
  i : Integer;
  PData1, PData2 : TN_BytesPtr;
  Buf : TN_BArray;
begin
  if DStep = 0 then DStep := DSize;
  PData1 := @Data;
  PData2 := PData1 + DStep * (DCount - 1);
  SetLength( Buf, DSize );
  DCount := DCount shr 1 - 1;
  for i := 0 to DCount do begin
    Move( PData2^, Buf[0], DSize );
    Move( PData1^, PData2^, DSize );
    Move( Buf[0], PData1^, DSize );
    Inc(PData1, DStep);
    Dec(PData2, DStep);
  end;
end; //*** end of procedure K_DataReverse

//********************************************* K_DArrayRound0 ***
//  round vector elements
//
procedure K_DArrayRound0( PValues : PDouble; DCount, DStep, Precision : Integer );
var
  i : Integer;
  FPrecision : Double;
begin
  if precision >= 100 then Exit;
  FPrecision := IntPower( 10.0, precision );
  for i := 0 to DCount - 1 do begin
    PValues^ := Round( PValues^ * FPrecision ) / FPrecision;
    Inc( TN_BytesPtr(PValues), DStep );
  end;
end; //*** end of procedure K_DArrayRound0

//************************************************ K_BuildFullIndex ***
//
function K_BuildFullIndex( PSInds : PInteger; SICount : Integer;
                           PFullInds : PInteger; FullICount : Integer;
                           BackIndexFlag : Boolean ) : Integer;
var
  i, j, k : Integer;
begin
//*** clear indexes
  FillChar(PFullInds^, FullICount * SizeOf(Integer), -1);
  Result := 0;
  for i := 0 to SICount - 1 do
  begin
    j := PSInds^;
    if (j >= 0) and (j < FullICount) then
    begin
      if BackIndexFlag then
        k := i
      else
        k := j;
      PInteger((TN_BytesPtr(PFullInds) + j * SizeOf(Integer)))^ := k;
      Inc(Result);
    end;
    Inc(PSInds);
  end;
end; // end of procedure K_BuildFullIndex

//************************************************ K_BuildBackIndex0 ***
//
function K_BuildBackIndex0( PSInds : PInteger; SICount : Integer;
                            PBInds : PInteger; BICount : Integer ) : Integer;
begin
  Result := K_BuildFullIndex( PSInds, SICount, PBInds, BICount, K_BuildFullBackIndexes );
end; // end of procedure K_BuildBackIndex0

//************************************************ K_BuildActIndicesAndCompress
//  Build Indexes of not negative (>=0) Source Indexes in Actual Indexes
//  Build Indexes of negative (<0) Source Indexes in Free Indexes
//  Copy not negative Source Indexes To Result Indexes
//   return number of not negative Source Indexes
//
function K_BuildActIndicesAndCompress( PFInds, PAInds, PRInds, PSInds : PInteger;
                                       ICount : Integer ) : Integer;
var
  i, N : Integer;
begin
  Result := 0;
  for i := 0 to ICount - 1 do
  begin
    N := PSInds^;
    if N >= 0 then
    begin
      if PAInds <> nil then
      begin
        PAInds^ := i;
        Inc(PAInds);
      end;
      if PRInds <> nil then
      begin
        PRInds^ := N;
        Inc(PRInds);
      end;
      Inc(Result);
    end
    else if PFInds <> nil then
    begin
      PFInds^ := i;
      Inc(PFInds);
    end;
    Inc(PSInds);
  end;
end; // end of K_BuildActIndicesAndCompress

//************************************************ K_BuildXORIndices
//  Build Indices XOR to Source Indices
// Full Number Elements FICount
// Value of Indices in PSInds must be less then FICount
//
procedure K_BuildXORIndices( PRInds : PInteger; PSInds : PInteger;
                             SICount : Integer; FICount : Integer;
                             CompressFlag : Boolean );
var
  i : Integer;
  IBuf : TN_IArray;
  PIBuf : PInteger;
begin
  if CompressFlag then begin
    SetLength( IBuf, FICount );
    PIBuf := @IBuf[0];
  end else
    PIBuf := PRInds;

  K_FillIntArrayByCounter( PIBuf, FICount );

  i := -1;
  K_MoveVectorByDIndex( PIBuf^, -1, i, 0, SizeOf(Integer ), SICount, PSInds );
{
  for i := 0 to SICount -1 do begin
    IBuf[PSInds^] := -1;
    Inc(PSInds);
  end;
}
  if CompressFlag then
    K_BuildActIndicesAndCompress( nil, nil, PRInds, @IBuf[0], FICount );
end; // end of K_BuildXORIndices

//************************************************* K_FillIntArrayByCounter ***
//  Fill Integer Array By Counter
//
//     Parameters
// PInds  - pointer to Integer Array start element
// ICount - number of elements to fill
// SValue - Start Value
// VStep  - Value Increment Step
//
procedure K_FillIntArrayByCounter( PInds : PInteger; ICount : Integer;
            IStep : Integer = SizeOf(Integer); SValue : Integer = 0; VStep : Integer = 1 );
var
  i : Integer;
begin
  for i := 0 to ICount - 1 do begin
    PInds^ := SValue;
    Inc( SValue, VStep );
    Inc( TN_BytesPtr(PInds), IStep );
  end;
end; // end of K_FillIntArrayByCounter

//************************************************ K_FillIntArrayByOrderInds
//  Fill Integer Array By Counter using Order Inds
//  SValue - Start Value
//  VStep  - Value Icrement Step
//
function K_FillIntArrayByOrderInds( PRInds, POrderInds : PInteger; ICount : Integer;
                      SFillValue : Integer = 1; VFillStep : Integer = 1 ) : Integer;
var
//  IA : TN_IArray;
  ci, i : Integer;
begin
//  SetLength( IA, ICount );
//  K_FillIntArrayByCounter( @IA[0], ICount, SFillValue, VFillStep );
  FillChar( PRInds^, ICount * SizeOf(Integer), -1 );
//  Result := K_MoveVectorByDIndex( PRInds^, SizeOf(Integer), IA[0], SizeOf(Integer),
//                               SizeOf(Integer), ICount, POrderInds );
  Result := 0;
  for i := 1 to ICount do
  begin
    ci := POrderInds^;
    if (ci >= 0) and (ci < ICount) then
    begin
      PInteger(TN_BytesPtr(PRInds) + ci * SizeOf(Integer))^ := SFillValue;
      Inc(Result);
    end;
    Inc( SFillValue, VFillStep );
    Inc(POrderInds);
  end;
end; // end of K_FillIntArrayByOrderInds

//************************************************ K_DVectorIndexAndWZone
//  Replace Index elements to -1 for which corresponding Vector values
//      VMin < V and V >= VMax
//
function K_DVectorIndexAndWZone( PDVector : PDouble; DStep : Integer; PIndexes : PInteger;
                           ICount : Integer; VMin, VMax : Double ) : Integer;
var
  i : Integer;
  DValue : Double;
begin
  Result := 0;
  for i := 0 to ICount - 1 do begin
    if PIndexes^ >= 0 then begin
      DValue := PDouble((TN_BytesPtr(PDVector) + PIndexes^ * DStep))^;
      if (DValue < VMin) and (DValue >= VMax) then
        PIndexes^ := -1
      else
        Inc(Result);
    end;
    Inc(PIndexes)
  end;
end; // end of procedure K_DVectorIndexAndWZone

//*********************************************************** K_SFAddVElems ***
// Add Vector Elems:
//
// VRes[i] := ( V1[i] + AC2*V2[i] ) * ACRes
//
// APV2 = nil means that all Vector elems = 1 ( V2[i] = 1 )
//
procedure K_SFAddVElems( APVRes: PDouble; ANumElems: integer;
                             APV1, APV2: PDouble; AC2, ACRes: double );
var
  i: integer;
  CurV2: double;
begin
  CurV2 := 1;

  for i := 1 to ANumElems do
  begin
    if APV2 <> nil then
    begin
      CurV2 := APV2^;
      Inc( APV2 );
    end; // if APV2 <> nil then

    APVRes^ := (APV1^ + AC2*CurV2) * ACRes;
    Inc( APV1 );
    Inc( APVRes );
  end; // for i := 1 to ANumElems do
end; // procedure K_SFAddVElems

//********************************************************** K_SFMultVElems ***
// Multiply Vector Elems:
//
// VRes[i] :=  V1[i] * V2[i] * ACRes
//
procedure K_SFMultVElems( APVRes: PDouble; ANumElems: integer;
                             APV1, APV2: PDouble; ACRes: double );
var
  i: integer;
begin
  for i := 1 to ANumElems do
  begin
    APVRes^ := APV1^ * APV2^ * ACRes;
    Inc( APV1 );
    Inc( APV2 );
    Inc( APVRes );
  end; // for i := 1 to ANumElems do
end; // procedure K_SFMultVElems

//******************************************************** K_SFDivideVElems ***
// Divide Vector Elems:
//
// VRes[i] :=  ACRes * V1[i] / V2[i]
//
procedure K_SFDivideVElems( APVRes: PDouble; ANumElems: integer;
                                    APV1, APV2: PDouble; ACRes: double );
var
  i: integer;
begin
  for i := 1 to ANumElems do
  begin
    if APV2^ = 0 then
      APVRes^ := 0
    else
      APVRes^ := ACRes * APV1^ / APV2^;

    Inc( APV1 );
    Inc( APV2 );
    Inc( APVRes );
  end; // for i := 1 to ANumElems do
end; // procedure K_SFDivideVElems

//******************************************************** K_SFCumSumVElems ***
// Calc Vector with Cumulative Sum of Vector Elems:
//
// VRes[i] :=  ACRes * ( Sum( j=0 to i ) V1[j] )
//
procedure K_SFCUSumVElems( APVRes: PDouble; ANumElems: integer;
                            APV1: PDouble; ACRes: double );
var
  i: integer;
  CumSum: double;
begin
  CumSum := 0;
  for i := 1 to ANumElems do
  begin
    CumSum := CumSum + APV1^;
    APVRes^ := ACRes * CumSum;

    Inc( APV1 );
    Inc( APVRes );
  end; // for i := 1 to ANumElems do
end; // procedure K_SFCumSumVElems

//*********************************************************** K_SFAbsVElems ***
// Calc Abs value of Vector Elems:
//
// VRes[i] :=  ACRes * Abs( V1[i] )
//
procedure K_SFAbsVElems( APVRes: PDouble; ANumElems: integer;
                             APV1: PDouble; ACRes: double );
var
  i: integer;
begin
  for i := 1 to ANumElems do
  begin
    APVRes^ := ACRes * Abs( APV1^ );

    Inc( APV1 );
    Inc( APVRes );
  end; // for i := 1 to ANumElems do
end; // procedure K_SFAbsVElems

//********************************************************* K_SFGetSumElems ***
// Return Sum of given Vector Elems
// Result := Sum( V1[i] )
//
function K_SFGetSumElems( APV1: PDouble; ANumElems: integer; Step : Integer = 0 ): double;
var
  i: integer;
begin
  Result := 0;
  if Step = 0 then Step := SizeOf(Double);
  for i := 1 to ANumElems do
  begin
    Result := Result + APV1^;
    Inc( TN_BytesPtr(APV1), Step );
  end; // for i := 1 to ANumElems do
end; // function K_SFGetSumElems

//********************************************************* K_SFGetIndOfMax ***
// Return Index of Maximal Vector Element
// V1[Result] >= V1[i]
//
function K_SFGetIndOfMax( APV1: PDouble; ANumElems: integer; Step : Integer = 0 ): integer;
var
  i: integer;
  CurMax: double;
begin
  Result := 0;
  CurMax := APV1^;
  if Step = 0 then Step := SizeOf(Double);
  Inc( TN_BytesPtr(APV1), Step );

  for i := 2 to ANumElems do
  begin
    if APV1^ > CurMax then
    begin
      CurMax := APV1^;
      Result := i - 1;
    end;

    Inc( TN_BytesPtr(APV1), Step );
  end; // for i := 1 to ANumElems do
end; // function K_SFGetIndOfMax

//********************************************************* K_SFGetIndOfMin ***
// Return Index of Maximal Vector Element
// V1[Result] >= V1[i]
//
function K_SFGetIndOfMin( APV1: PDouble; ANumElems: integer; Step : Integer = 0 ): integer;
var
  i: integer;
  CurMin: double;
begin
  Result := 0;
  CurMin := APV1^;
  if Step = 0 then Step := SizeOf(Double);
  Inc( TN_BytesPtr(APV1), Step );

  for i := 2 to ANumElems do
  begin
    if APV1^ < CurMin then
    begin
      CurMin := APV1^;
      Result := i - 1;
    end;

    Inc( TN_BytesPtr(APV1), Step );
  end; // for i := 1 to ANumElems do
end; // function K_SFGetIndOfMin

//******************************************************* K_SFGetVectorMode ***
// Return Vector Mode ( Value with max probabiliti (likehood) )
// (значение, при котором достигается максимум плотности распределения)
//
// APVXMin  - Min Interval Values
// APVXD    - Size of intervals
// APVPlotn - Plotnost' (плотность)
//
function K_SFGetVectorMode( APVXMin, APVXD, APVPlotn: PDouble; ANumElems: integer ): double;
var
  i: integer;
  mk, dmk: double;
begin
  i := K_SFGetIndOfMax( APVPlotn, ANumElems );

  if (i >= 1) and (i < ANumElems - 1) then
  begin
    Inc( APVXMin, i );
    Inc( APVXD, i );
    Inc( APVPlotn, i-1 );

    dmk := APVPlotn^;
    Inc( APVPlotn );
    mk := APVPlotn^;
    Inc( APVPlotn );
    dmk := mk - dmk;

    Result := APVXMin^ + APVXD^ * ( dmk / (dmk + mk - APVPlotn^) );
  end else if i = 0 then // first interval (Спросить у Олега)
  begin
    Result := APVXMin^;
    Inc( APVXMin );
    Result := 0.5*( Result + APVXMin^);
  end else // last interval, i = (ANumElems-1)
  begin
    Inc( APVXMin, ANumElems-2 );
    Result := APVXMin^;
    Inc( APVXMin );
    Result := 0.5*( Result + APVXMin^);
  end;
end; // function K_SFGetVectorMode

//********************************************************** K_SFGetPartValue ***
// Return Decil Coef by given AvalPrc in percents
// (децильный коэф. для заданного значения в процентах)
//
// ( for AvalPrc = 50 Result is a Median)
//
// APVXMin  - Min Interval Values
// APVXD    - Size of intervals
// APVW     - Chastost' (частость)
// APVAW    - Accumulated Chastost' (накопленные частости)
// AvalPrc  - Given Value in percents
//
function K_SFGetPartValue( APVXMin, APVXD, APVW, APVAW: PDouble;
                         ANumElems: integer; AvalPrc: double ): double;
var
  i: integer;
  w: double;
begin
  i := K_IndexOfDoubleInScale( APVAW, ANumElems - 1, SizeOf(Double), AvalPrc );
  if i = 0 then
    w := 0
  else // i >= 1
  begin
    Inc( APVAW, i-1 );
    w := APVAW^;
  end;

  Inc( APVXMin, i );
  Inc( APVXD, i );
  Inc( APVW, i );

  Result := APVXMin^ + APVXD^ * ( ( AvalPrc - w ) / APVW^ );
end; // function K_SFGetPartValue

//********************************************* K_IndexOfMaxInRArray
//  Search maximal value of Integer field of records array
//
//     Parameters
// APRValue - pointer to field in 1-st array record
// ARCount  - array records count
// ARSize   - record size in bytes
// Result   - Returns index of record with maximal value
//
function  K_IndexOfMaxInRArray( APRValue : PInteger;
                                ARCount : Integer; ARSize : Integer = 0 ) : Integer; overload;
var
  i : Integer;
  MaxVal : Integer;
begin
  if ARSize = 0 then ARSize := SizeOf(Integer);
  MaxVal := APRValue^;
  Result := 0;
  Inc(TN_BytesPtr(APRValue), ARSize);
  for i := 1 to ARCount - 1 do
  begin
    if MaxVal <= APRValue^ then
    begin
      MaxVal := APRValue^;
      Result := i;
    end;
    Inc(TN_BytesPtr(APRValue), ARSize);
  end;
end; // function  K_IndexOfMaxInRArray

//********************************************* K_IndexOfMaxInRArray
//  Search maximal value of Double field of records array
//
//     Parameters
// APRValue - pointer to field in 1-st array record
// ARCount  - array records count
// ARSize   - record size in bytes
// Result   - Returns index of record with maximal value
//
function  K_IndexOfMaxInRArray( APRValue : PDouble;
                                ARCount : Integer; ARSize : Integer = 0 ) : Integer; overload;
var
  i : Integer;
  MaxVal : Double;
begin
  if ARSize = 0 then ARSize := SizeOf(Double);
  MaxVal := APRValue^;
  Result := 0;
  Inc(TN_BytesPtr(APRValue), ARSize);
  for i := 1 to ARCount - 1 do
  begin
    if MaxVal <= APRValue^ then
    begin
      MaxVal := APRValue^;
      Result := i;
    end;
    Inc(TN_BytesPtr(APRValue), ARSize);
  end;
end; // function  K_IndexOfMaxInRArray

//********************************************* K_IndexOfMinInRArray
//  Search minimal value of Integer field of records array
//
//     Parameters
// APRValue - pointer to field in 1-st array record
// ARCount  - array records count
// ARSize   - record size in bytes
// Result   - Returns index of record with maximal value
//
function  K_IndexOfMinInRArray( APRValue : PInteger;
                                ARCount : Integer; ARSize : Integer = 0 ) : Integer; overload;
var
  i : Integer;
  MinVal : Integer;
begin
  if ARSize = 0 then ARSize := SizeOf(Integer);
  MinVal := APRValue^;
  Result := 0;
  Inc(TN_BytesPtr(APRValue), ARSize);
  for i := 1 to ARCount - 1 do
  begin
    if MinVal >= APRValue^ then
    begin
      MinVal := APRValue^;
      Result := i;
    end;
    Inc(TN_BytesPtr(APRValue), ARSize);
  end;
end; // function  K_IndexOfMinInRArray

//********************************************* K_IndexOfMinInRArray
//  Search minimal value of Double field of records array
//
//     Parameters
// APRValue - pointer to field in 1-st array record
// ARCount  - array records count
// ARSize   - record size in bytes
// Result   - Returns index of record with maximal value
//
function  K_IndexOfMinInRArray( APRValue : PDouble;
                                ARCount : Integer; ARSize : Integer = 0 ) : Integer; overload;
var
  i : Integer;
  MinVal : Double;
begin
  if ARSize = 0 then ARSize := SizeOf(Double);
  MinVal := APRValue^;
  Result := 0;
  Inc(TN_BytesPtr(APRValue), ARSize);
  for i := 1 to ARCount - 1 do
  begin
    if MinVal >= APRValue^ then
    begin
      MinVal := APRValue^;
      Result := i;
    end;
    Inc(TN_BytesPtr(APRValue), ARSize);
  end;
end; // function  K_IndexOfMinInRArray

//********************************************* K_SumOfRArray
//  Calculate Sum of Integer fields of records array
//
//     Parameters
// APRValue - pointer to field in array 1-st record
// ARCount  - array records count
// ARSize   - record size in bytes
// Result   - Returns sum of givem record fields
//
function  K_SumOfRArray( APRValue : PInteger;
                         ARCount : Integer; ARSize : Integer = 0 ) : Integer; overload;
var
  i : Integer;
begin
  if ARSize = 0 then ARSize := SizeOf(Integer);
  Result := 0;
  for i := 0 to ARCount - 1 do
  begin
    Result := Result + APRValue^;
    Inc(TN_BytesPtr(APRValue), ARSize);
  end;
end; // function  K_SumOfRArray

//********************************************* K_SumOfRArray
//  Calculate Sum of Double fields of records array
//
//     Parameters
// APRValue - pointer to field in array 1-st record
// ARCount  - array records count
// ARSize   - record size in bytes
// Result   - Returns sum of givem record fields
//
function  K_SumOfRArray( APRValue : PDouble;
                         ARCount : Integer; ARSize : Integer = 0 ) : Double; overload;
var
  i : Integer;
begin
  if ARSize = 0 then ARSize := SizeOf(Double);
  Result := 0;
  for i := 0 to ARCount - 1 do
  begin
    Result := Result + APRValue^;
    Inc(TN_BytesPtr(APRValue), ARSize);
  end;
end; // function  K_SumOfRArray

end.

