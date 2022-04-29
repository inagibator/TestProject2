unit K_SParse1;
//SPL compiler 

interface
uses Classes, SysUtils, inifiles,
  K_Parse, K_UDT1, K_UDConst, K_Script1, K_SBuf, K_STBuf;


type TK_CompilerError = class(Exception);
//type TK_ShowErrorInfo = procedure ( UDUnitRoot : TK_UDUnit;
//            UnitName, ErrMessage : string;
//            ErrPos, ErrLength, ErrRow, ErrRowPos : Integer  )  of object;

type TK_ParseDataQuality = ( K_vqLiteral, K_vqLVar, K_vqGVar, K_vqFunc, K_vqProc,
                             K_vqMeth, K_vqConstr, K_vqOther );
type TK_OneExprDataDescr = record //***** One parameter Description
  Data        : Integer;        // Data Pointer or Shift
  DataType    : TK_ExprExtType; // Data Type
  FieldInd    : Integer;        // Field Index
  FieldShift  : Integer;        // Field Shift
  FieldType   : TK_ExprType;    // Field Type
  GUDData     : TK_UDRArray;    // Global Data UDRArray {!!!##+ New Global Variable Code}
  DataQuality : TK_ParseDataQuality;  // Parse Data Quality
end; // TK_OneDataDescr = record

type TK_ExprDataDescr = array of TK_OneExprDataDescr; // Expression Data Description

function  K_GetGDataPointer( const VarName : String; out DType : TK_ExprExtType ) : Pointer;
function  K_GetUDProgramItem( const ProgramPath : string  ) : TK_UDProgramItem;
function  K_CompileGUnit( Text : string; Recompile : Boolean = false  ) : Boolean;
function  K_CompileFileUnit( const FileName : string;
                             Recompile : Boolean = false ) : Boolean;
function  K_CompileScriptFile( const FileName : string; var UDUnit : TK_UDUnit;
                               Recompile : Boolean = true; CheckScriptUnit : Boolean = true ) : Integer;
function  K_RunScript( const FileName, ScriptName : string; ShowDump : Boolean = false;
                       GC : TK_CSPLCont = nil  ) : Integer;
function  K_RunScriptPI( UDPI : TK_UDProgramItem; ShowDump : Boolean = false;
                         GC : TK_CSPLCont = nil ) : Integer;
function  K_CompileUnit( ModuleText : string; var UDUnitRoot : TK_UDUnit;
                         Recompile : Boolean = false;
                         SkipUDChangedFlagForNotCompiled : Boolean = false;
                         LocalUnitAliase : string = '' ) : Boolean;
function  K_GetRoutineType( FuncParDescr : TK_UDFieldsDescr ) : TK_ExprExtType;

function  K_ParseSubExpression( UDProgItem : TK_UDProgramItem;
  RoutineParDescr : TK_UDFieldsDescr;
  CurTypeAll, LiteralTypeAll : Int64; TermChars : string; ParseStart : Boolean;
  LiteralAllowed : Boolean; var QData : TK_ParseDataQuality;
  const ParseText : string = '' ) : TK_ExprExtType;
procedure K_CompileRoutineBody( RoutineRoot : TK_UDProgramItem  );

procedure K_AddFieldsTypeFlagSet( TypeCode : Integer; TypeFlags : TK_ExprTypeFlags;
                       var FieldsTypeFlagSet : TK_FFieldsTypeFlagSet );
function  K_ParseVarFieldNames(FullName : string; out FieldName : string) : string;

var
K_UnitsRoot    : string;              //*** Root Path for All Application Units
K_TypeDescrsList  : THashedStringList;//*** List of All Compiled Types Descriptions
K_SHBaseTypesList : THashedStringList;//*** Base Types List

const
K_sccStartCommentCond ='/';
K_sccStartComment ='{';
K_sccFinComment ='}';
K_sccStartListDelim = '(';
K_sccFinListDelim = ')';
K_sccLiteralStringDelim1 = '''';
K_sccLiteralStringDelim2 = '"';
K_sccStartIndex = '[';
K_sccFinIndex = ']';

K_sccSpecNamePref ='_';

K_sccTokenBrackets = K_sccLiteralStringDelim2+K_sccLiteralStringDelim2+
        K_sccLiteralStringDelim1+K_sccLiteralStringDelim1+
        K_sccStartComment+K_sccFinComment;
K_sccParDelimsBrackets = K_sccLiteralStringDelim2+K_sccLiteralStringDelim2+
        K_sccLiteralStringDelim1+K_sccLiteralStringDelim1+
        K_sccStartListDelim+K_sccFinListDelim+
        K_sccStartComment+K_sccFinComment;
K_sccExprDelimsBrackets = K_sccTokenBrackets;

K_sccRecFieldDelim = '.';
K_sccNumberDecPoint = '.';
K_sccFinDefDelim = ';';
K_sccTypeDelim = ':';

K_sccFinStatementDelim = ';';
K_sccParListDelim = ',';
K_sccParValueDelim = '=';
K_sccVarAdrTypePref = '^';
K_sccVarFieldDelim = '!';
K_sccUnitLocalNameChar = '#';
K_sccUnitFileNameChar = '%';

K_sccStartTypeAliaseChar = '%';
K_sccStartSysCommentChar = '$';


//*** unit definition sections names
K_sccModuleDef = 'unit';
K_sccUsesDef = 'uses';
K_sccDataDef = 'var';
K_sccDataInit = 'initialization';
K_sccImplementation = 'implementation';
K_sccDataType = 'type';

//*** type class names
K_sccPrivateQual = 'private';
K_sccVariantQual = 'variant';
K_sccPublishedQual = 'published';
K_sccRuntimeQual = 'runtime';
K_sccObsoleteQual = 'obsolete';
K_sccPackedQual = 'packed';
K_sccRecordDef = 'record';
K_sccVarRecordDef = 'vrecord';
K_sccProcedureDef = 'procedure';
K_sccFunctionDef = 'function';
K_sccClassDef = 'class';
K_sccSetDef = 'setof';
K_sccClassParentDef = 'parent';
K_sccClassUDDef = 'instance';
K_sccClassFieldsName = 'self';
K_sccClassConstructorDef = 'constructor';
K_sccClassDestructorDef = 'destructor';

K_sccFuncResultPar = 'Result';
K_sccLabel = 'label';
K_sccStartBlock = 'begin';
K_sccFinBlock = 'end';
K_sccArray = 'arrayof';
K_sccVArray = 'varrayof';
K_sccVarConvToAdr = 'adr';
K_sccEnumOrder = 'ord';
K_sccVarConvToValue = 'value';
K_sccSizeOfType = 'sizeof';

K_sccParDescrNode = 'PARAMS';
K_sccUnitDataNode = 'Data';
K_sccInitDataNamePref = 'Data';
K_sccInitDataProgName = '____Init';

K_sccExitOpName  = 'exit';
K_sccGotoOpName  = 'goto';
K_sccIfOpName    = 'if';
K_sccWhileOpName = 'while';
K_sccElseOpName  = 'else';
K_sccDebOpName   = 'deb';

K_sccDOKeyWord  = 'do';
K_sccTHENKeyWord  = 'then';

K_expSetOp = '=';
K_expSetOpInd = 0;

K_expAddOp  = '+';
K_expSubOp  = '-';
K_expMultOp = '*';
K_expDivOp  = '/';
K_expBooleanOpInd = 5;

K_expAndOp = 'and';
K_expOrOp  = 'or';
K_expXorOp = 'xor';
K_expNotOp = 'not';
K_expEQOp  = 'EQ';
K_expNEOp  = 'NE';
K_expLTOp  = 'LT';
K_expGTOp  = 'GT';
K_expLEOp  = 'LE';
K_expGEOp  = 'GE';


K_sccDelimsSet = ' '+#$A#$D#9+K_sccStartListDelim+K_sccFinListDelim+
  K_sccParListDelim+K_sccTypeDelim+K_sccParValueDelim+
  K_sccFinStatementDelim;

K_sccUnitDelimsSet = ' '+#$A#$D#9+K_sccStartListDelim+K_sccFinListDelim+
  K_sccParListDelim+K_sccFinStatementDelim;

K_sccParDefDelimsSet = ' '+#$A#$D#9+
  K_sccParListDelim+K_sccTypeDelim+K_sccParValueDelim+K_sccFinListDelim+
  K_sccFinStatementDelim;

K_sccParDelimsSet = ' '+#$A#$D#9+K_sccFinListDelim+
  K_sccParListDelim+K_sccParValueDelim+
  K_sccFinStatementDelim;

K_sccExprDelimsSet = ' '+#$A#$D#9+K_sccParValueDelim+
  K_sccStartListDelim+K_sccFinListDelim+
  K_sccStartIndex+K_sccFinIndex+
  K_sccParListDelim+K_sccTypeDelim+K_expSetOp+K_expAddOp+K_expSubOp+
  K_expMultOp+K_expDivOp + K_sccFinStatementDelim + K_sccVarFieldDelim;

var

  K_ST : TK_Tokenizer;        //*** Unit Text Tokenizer
  K_SPT : TK_Tokenizer;  //*** Array Init Text Tokenizer
  K_OpParseStack : TK_ExprCodes; //*** Expression Parser Operations Stack
  K_SHEnumMembersList : THashedStringList; //*** List of Enumerators Members
  K_SHDataTypesList : THashedStringList;   //*** Current Data Types List
  K_LGlobalData     : TList;               //*** Units Global Data Objects
  K_SHUsedRLData    : THashedStringList;   //*** Routine Used Local Data List
  K_SHRoutineLabels : THashedStringList;   //*** Routine Labels List
  K_SetEnumVariants : TStringList;         //*** Current Enums and Set Variant Members
  K_ExprNData       : TK_ExprDataDescr;    //*** Current Routine Expression Data Descriptions array
  K_ExprNDataCount  : Integer;             //*** Current Count of  Routine Expression Data
  K_SHTermTokens    : THashedStringList;   //*** Terminating Tokens List -
  K_SHOperators     : THashedStringList;   //*** Operators List - Includes Operators Names
  K_SHFunctions     : THashedStringList;   //*** Functions List - Includes Build In functions names
  K_SHProgItemsList : THashedStringList;   //*** Routines List

implementation

uses
  Forms, Dialogs, Windows, ComCtrls, Controls, StdCtrls, StrUtils,
  K_IWatch, K_UDT2, K_UDC, K_CLib0, K_FSDeb, K_VFunc,
  N_CLassRef, N_Types, N_Lib1, N_Gra0, N_Gra1;
{
const
//*** Program Item Parameter Value Quality

  K_vqLiteral    = 0;
  K_vqLVar       = 1;
  K_vqGVar       = 2;
  K_vqFunc       = 3;
  K_vqProc       = 4;
  K_vqMeth       = 5;
  K_vqConstr     = 6;
  K_vqOther      = $FF;
}
var

//  K_ST : TK_Tokenizer;        //*** Unit Text Tokenizer
//  K_SPT : TK_Tokenizer;  //*** Array Init Text Tokenizer

//  K_SHOperators     : THashedStringList;   //*** Operators List - Includes Operators Names
//  K_SHFunctions     : THashedStringList;   //*** Functions List - Includes BuilIn functions names
//  K_SHTermTokens    : THashedStringList;   //*** Terminating Tokens List -
//  K_SHEnumMembersList : THashedStringList; //*** List of Enumerators Members
//  K_SHDataTypesList : THashedStringList;   //*** Current Data Types List
//  K_SHProgItemsList : THashedStringList;   //*** Routines List
//  K_SHUsedRLData    : THashedStringList;   //*** Routine Used Local Data List
//  K_SHRoutineLabels : THashedStringList;   //*** Routine Labels List
//  K_SetEnumVariants : TStringList;         //*** Current Enums and Set Variant Members
//  K_LGlobalData     : TList;               //*** Units Global Data Objects
//  K_ExprNData       : TK_ExprDataDescr;    //*** Current Routine Expression Data Descriptions array
//  K_ExprNDataCount  : Integer;             //*** Current Count of  Routine Expression Data
  K_UDCurGlobalData : TK_UDRArray;         //*** Current Global Data Object
  K_ErrorPos : Integer;                    //*** Error Unit Text Start Pos
  K_ErrorLength : Integer;                 //*** Error Text Length

//  K_OpParseStack : TK_ExprCodes; //*** Expression Parser Operations Stack
  K_OPSLevel : Integer;          //*** Expression Parser Operations Stack level

  K_SysComment : string;  //*** System Comment Field
  K_TypeAliase : string;  //*** Type Aliase Field

//************************************************ K_CompilerError ***
//  Compiler Error
//
procedure K_CompilerError(const id: string; ErrTextLength : Integer = 0 );
begin
  if ErrTextLength = 0 then
    K_ErrorLength := K_ST.Cpos - K_ErrorPos
  else
    K_ErrorLength := ErrTextLength;
  raise TK_CompilerError.Create(id);
end;
//**** end of K_CompilerError ***

//************************************************ K_GetDelimiter ***
//  Parse
//             3
function K_GetDelimiter( out DelChar : Char; SkipDelimFind : Boolean = false; StopParseDelim : Char = #0 ) : Boolean;
var
wasSpecDelimiter : Boolean;
WDelChar : Char;

label FinParse;
begin
  DelChar := #0;
  Result := false;
  K_TypeAliase := '';
  with K_ST do
    while hasMoreTokens(SkipDelimFind) do begin
      SkipDelimFind := false;
      WDelChar := getDelimiter;
      wasSpecDelimiter := isNRDelimFindFlag;
      if wasSpecDelimiter then
        DelChar := WDelChar;
      if (StopParseDelim <> #0) and
         (StopParseDelim = DelChar) then
        goto FinParse;
      if WDelChar = K_sccStartComment then begin
        K_TypeAliase := nextToken;
        if K_TypeAliase <> '' then begin
           if K_TypeAliase[1] = K_sccStartSysCommentChar then
             K_SysComment := K_TypeAliase
           else if K_TypeAliase[1] <> K_sccStartTypeAliaseChar then
             K_TypeAliase := '';
        end;
      end else if (Text[Cpos]   = K_sccStartCommentCond) and
                  (Text[Cpos+1] = K_sccStartCommentCond) then
        Cpos := PosEx( #$A, Text, Cpos )
      else begin
FinParse:
        Result := true;
        break;
      end
    end;
end; //**** end of K_GetDelimiter ***

//************************************************ K_ParseParamTypeCode ***
//  Parse Param Type
//
function K_ParseParamTypeCode( const ParType : string; var TypeFlags : TK_ExprTypeFlags;
                                StopIfNotFound : Boolean = true ) : Integer;
var
  wstr : string;
//  ExtTypeCode : TK_ExprExtType;
begin
  wstr := ParType;
  if ParType[1] = K_sccVarAdrTypePref then begin
    TypeFlags.TFlags := TypeFlags.TFlags + K_ffPointer;
    wstr := Copy( wstr, 2, Length( ParType ) );
  end;
  Result := K_SHDataTypesList.IndexOf( wstr );
  if Result = -1 then begin
    if StopIfNotFound then
      K_CompilerError( 'Error - unknown type "'+ParType+'"' )
//      K_CompilerError( 'Error - unknown type "'+ParType+'"', Length(ParType) )
  end else begin
//    if Result > High(K_SPLTypeNames) then begin
    if Result > Ord(nptNoData) then begin
      Result := Integer(K_SHDataTypesList.Objects[Result]);
      assert( (TN_UDBase(Result).ClassFlags and $FF) = K_UDFieldsDescrCI,
                                       'Type code is not TK_UDFieldDescr' );
{
      ExtTypeCode.DTCode := Result;
      ExtTypeCode.EFlags := TypeFlags;
      ExtTypeCode := K_GetSynonymTypeCode( ExtTypeCode );
      if ExtTypeCode.DTCode = Result then
      // Same Type
}
        with TK_UDFieldsDescr(Result) do begin
          if FDObjType = K_fdtRoutine then
            TypeFlags.TFlags := TypeFlags.TFlags or K_ffRoutine
          else if FDObjType = K_fdtClass then
            TypeFlags.TFlags := TypeFlags.TFlags or K_ffUDRARef;
//          else if (ObjType = K_fdtEnum) or (ObjType = K_fdtSet) then
//            TypeFlags.TFlags := TypeFlags.TFlags or K_ffEnumSet;
        end
{
      else begin
        Result := ExtTypeCode.DTCode;
        TypeFlags := ExtTypeCode.EFlags;
      end;
}
    end;
  end;
end; //**** end of K_ParseParamTypeCode ***

//************************************************ K_ParseDataType ***
//  Parse Data Definition - :Type[=Value]
//
procedure K_ParseDataType( out TypeCode : Integer; out TypeFlags : TK_ExprTypeFlags; out ParValue : string; ParsedTypeName : string );
var
  DelChar : Char;
  ParTypeName : string;
begin

  TypeCode := -1;
  with K_ST do begin
    if ParsedTypeName = '' then begin
      if not K_GetDelimiter(DelChar) or
         (DelChar <> K_sccTypeDelim) then Exit;
      K_ErrorPos := Cpos;
      ParTypeName := nextToken( true );
    end else
      ParTypeName := ParsedTypeName;

    if ParTypeName[1] = K_sccVarAdrTypePref then begin
      TypeFlags.TFlags := K_ffPointer;
      ParTypeName := Copy( ParTypeName, 2, Length( ParTypeName ) );
    end else
      TypeFlags.TFlags := 0;
    if SameText( ParTypeName, K_sccArray) then begin
      if not K_GetDelimiter(DelChar) then
        K_CompilerError( 'Error in type definition', Length(ParTypeName) );
      ParTypeName := nextToken( true );
      TypeFlags.TFlags := TypeFlags.TFlags or K_ffArray;
    end;
    if SameText( ParTypeName, K_sccVArray) then begin
      if not K_GetDelimiter(DelChar) then
        K_CompilerError( 'Error in type definition', Length(ParTypeName) );
      ParTypeName := nextToken( true );
      TypeFlags.TFlags := TypeFlags.TFlags or K_ffVArray;
    end;
    //*** parse Param Type
    TypeCode := K_ParseParamTypeCode( ParTypeName, TypeFlags );

  //*** parse default value
    if K_GetDelimiter(DelChar, false, K_sccFinDefDelim) and
       (DelChar = K_sccParValueDelim) then
      ParValue := nextToken( true )
    else
      ParValue := '';
  end;

end; //**** end of K_ParseDataType ***

//************************************************ K_SearchGData ***
//  Search Global Data
//
function K_SearchGData( const VarName : String; var UDData : TK_UDRArray;
                                        var FDescr : TK_UDFieldsDescr ) : Integer;
var i, h : Integer;

  function Search : Integer;
  begin
    Result := -1;
    if K_UDCurGlobalData = nil then Exit;
//    FDescr := TK_UDFieldsDescr( K_UDCurGlobalData.GetLDataDescr );
//    if FDescr = nil then Exit;
    FDescr := K_UDCurGlobalData.R.ElemType.FD;
    if Integer(FDescr) <= Ord(nptNoData) then Exit;
    Result := FDescr.IndexOfFieldDescr( VarName );
    UDData := K_UDCurGlobalData;
  end;

begin
  FDescr := nil;
  Result := Search;
  if Result = -1 then begin
    if K_LGlobalData <> nil then
      h := K_LGlobalData.Count - 1
    else
      h := -1;
    for i := 0 to h do begin
      K_UDCurGlobalData := TK_UDRArray(K_LGlobalData.Items[i]);
      Result := Search();
      if Result <> -1 then break;
    end;
  end;
end; //**** end of K_SearchGData ***

//************************************************ K_GetGDataPointer ***
//  Get Global Data Pointer
//
function K_GetGDataPointer( const VarName : String; out DType : TK_ExprExtType ) : Pointer;
var
  Ind : Integer;
  UDData : TK_UDRArray;
  FDescr : TK_UDFieldsDescr;
begin

  Ind := K_SearchGData( VarName, UDData, FDescr );
  if Ind = -1 then
    Result := nil
  else begin
    with FDescr.GetFieldDescrByInd(Ind)^ do begin
      DType := K_GetExecTypeBaseCode(DataType);
//      Result := PChar( @UDData.R.V[0] ) + DataPos;
      Result := TN_BytesPtr(UDData.R.P) + DataPos;
    end;
  end;

end; //**** end of K_GetGDataPointer ***

//************************************************ K_AddToExprCode ***
//  Add Item To Exresion Code Buffer
//
procedure K_AddToExprCode( UDProgItem : TK_UDProgramItem;
    ExprCode : Integer; ExprIFlags, ExprTFlags : Byte; TCode, EFlags : Integer );
var NCapasity : Integer;
begin
  with UDProgItem do begin
    NCapasity := Length(ExprCodeBuf);
    if K_NewCapacity( ExprCodeBufUsed + 1, NCapasity ) then
      SetLength(ExprCodeBuf, NCapasity);
    with ExprCodeBuf[ExprCodeBufUsed] do begin
      Code := ExprCode;
      EType.DTCode := TCode;
      EType.EFlags.All := EFlags;
      if (ExprIFlags and (K_ectSpecial+K_ectDataDirect)) = 0 then
        EType := K_GetExecTypeBaseCode( EType );
      EType.IFlags := EType.IFlags or ExprIFlags;
      EType.D.TFlags := EType.D.TFlags + ExprTFlags;
    end;
    Inc(ExprCodeBufUsed);
  end;
end; //**** end of K_AddToExprCode ***

//************************************************ K_AddToFuncStack ***
//  Add Item To Functions Stack
//
procedure K_AddToFuncStack( FuncCode : Integer; NewType : Int64 );
var NCapasity : Integer;
begin
  Inc(K_OPSLevel);
  NCapasity := Length(K_OpParseStack);
  if K_NewCapacity( K_OPSLevel + 1, NCapasity ) then
    SetLength(K_OpParseStack, NCapasity);
  K_OpParseStack[K_OPSLevel].Code := FuncCode;
  K_OpParseStack[K_OPSLevel].EType.All := K_GetExecTypeBaseCode( TK_ExprExtType(NewType) ).All;
end; //**** end of K_AddToFuncStack ***

{
//************************************************ K_GetTypeName ***
//  Get Type Name Using Code
//
function K_GetTypeName( Code : Integer ) : string;
begin

//  if Code <= High(K_SPLTypeNames) then
  if Code <= Ord(nptNoData) then
    Result := K_SPLTypeNames[Code]
  else
    Result := TK_UDFieldsDescr(Code).ObjName;

end; //**** end of K_GetTypeName ***
}

//************************************************ K_AddToDynData ***
//  Add new Dynamic Data Variable
//
procedure K_AddToDynData( const Name : string; const CDescr : TK_OneExprDataDescr );
var
  NCapasity : Integer;
  wstr : string;
begin

  NCapasity := Length(K_ExprNData);
  if K_NewCapacity( K_ExprNDataCount + 1, NCapasity ) then
    SetLength(K_ExprNData, NCapasity);
  wstr := Name;
//??  if CDescr.DataQuality = K_vqLiteral then
//??    wstr := wstr + K_GetTypeName( CDescr.DataType.Code );
  K_SHUsedRLData.Add( wstr );
  K_ExprNData[K_ExprNDataCount] := CDescr;
  Inc( K_ExprNDataCount );

end; //**** end of K_AddToDynData ***

//************************************************ K_GetRoutineType ***
//  Get Routine Type
//
function  K_GetRoutineType( FuncParDescr : TK_UDFieldsDescr ) : TK_ExprExtType;
var Ind : Integer;
begin
  //*** Check Function Result Type
  with FuncParDescr do begin
    Ind := IndexOfFieldDescr( K_sccFuncResultPar );
    if Ind <> -1 then
      Result := (GetFieldDescrByInd(Ind)).DataType
    else begin
      Result.DTCode := -1;
      Result.EFlags.All := 0;
    end;
  end;
end; //**** end of K_GetRoutineType ***

//************************************************ K_ParseVariable ***
//  Add new Dynamic Data Variable
//
function K_ParseVariable( Name : string; RoutineParDescr : TK_UDFieldsDescr ) : TK_OneExprDataDescr;
var
  RParNum : Integer;
  GDescr : TK_UDFieldsDescr;
//!!##-  UDData : TK_UDRArray; //##!!New Global Variable Code
  PFDescr : TK_POneFieldExecDescr;

  procedure GetVarType( FDescr : TK_UDFieldsDescr );
  begin
    PFDescr := FDescr.GetFieldDescrByInd(RParNum);
    with Result do begin
      DataType := K_GetExecTypeBaseCode( PFDescr^.DataType );
      Data     := PFDescr^.DataPos;
    end;
  end;

begin
  with Result do begin
    DataType.IFlags := 0;
    DataType.DTCode := -1;

    if DataType.DTCode = -1 then begin
      RParNum := RoutineParDescr.IndexOfFieldDescr( Name );
      if RParNum <> -1 then begin  //*** Local reference to Routine Data
        GetVarType( RoutineParDescr );
        DataType.IFlags := K_ectDataShift;
        DataQuality := K_vqLVar;
      end else begin               //*** Test Reference to Global
        RParNum := K_SearchGData( Name, GUDData, GDescr );
        if RParNum = -1 then Exit;
        GetVarType( GDescr );
{!!##- New Global Variable Code
        if DataType.DTCode <> -1 then
          Data := Data + Integer( GUDData.R.P );
!!##}
        DataQuality := K_vqGVar;
      end;
    end;
  end;
  K_AddToDynData( Name, Result );

end; //**** end of K_ParseVariable ***

//************************************************ K_AddShiftToVarPtrCode ***
//  Add Shift to Variable Pointer if Field
//
procedure K_AddShiftToVarPtrCode( UDProgItem : TK_UDProgramItem;
                                  var CDescr : TK_OneExprDataDescr );
begin
  with CDescr do begin
  //*** Put Base Pointer to Stack
    if DataQuality = K_vqGVar then begin
      K_AddToExprCode( UDProgItem, Integer(GUDData), K_ectDataDirect, K_ffUDRARef,
                       Ord( nptUDRef ), 0 );
    //*** Call Function "_PInstance" - put GData Adress to Stack
      K_AddToExprCode( UDProgItem, K_ExprNGetInstanceFuncCI, K_ectRoutine, 0,
                       DataType.DTCode, DataType.EFlags.All );
      if Data <> 0 then begin
      //*** Put Data Shift to Stack
        K_AddToExprCode( UDProgItem, Data, K_ectDataDirect, 0, Ord(nptInt), 0 );
      //*** Call Function "SumInts"  - put (GData Pointer + Data Shift) to Stack
        DataType.IFlags := 0;
        Inc(DataType.D.TFlags, K_ffPointer);
        K_AddToExprCode( UDProgItem,
                         K_ExprNSumIntsFuncCI, K_ectRoutine, 0,
                         DataType.DTCode, DataType.EFlags.All );
        Dec(DataType.D.TFlags, K_ffPointer);
      end;
    //*** Call Function "Value"  - put GData Value to Stack
      K_AddToExprCode( UDProgItem, K_ExprNValFuncCI,
                       K_ectRoutine, 0, DataType.DTCode, DataType.EFlags.All );

    end else
      K_AddToExprCode( UDProgItem, Data, 0, 0, DataType.DTCode, DataType.EFlags.All );


  //*** Put Base Pointer to Stack
//2006-10-25    K_AddToExprCode( UDProgItem, Data, 0, 0, DataType.DTCode, DataType.EFlags.All );
//   if (DataType.D.TFlags and K_ffClassEx) <> 0 then
   if (DataType.D.TFlags = K_ffUDRARef)  and
      (DataType.FD.FDObjType = K_fdtClass) then
      //*** Convert Class Object Instance (UDBase) to Class Object Data Pointer
//      K_AddToExprCode( UDProgItem, K_ExprNGetInstanceFuncCI, K_ectRoutine, 0,
//                       DataType.DTCode, DataType.EFlags.All );
      K_AddToExprCode( UDProgItem, K_ExprNGetInstanceFuncCI, K_ectRoutine, 0,
                       Ord(nptInt), 0 );
  //*** Put FieldShift to Stack
    K_AddToExprCode( UDProgItem, FieldShift, K_ectDataDirect, 0, Ord(nptInt), 0 );
  //*** Put Function "SumInts" to Stack
    DataType.D := FieldType;
    Inc(DataType.D.TFlags, K_ffPointer);
    DataType.IFlags := 0;
    K_AddToExprCode( UDProgItem,
                     K_ExprNSumIntsFuncCI, K_ectRoutine, 0,
                     DataType.DTCode, DataType.EFlags.All );
  end;
end; //**** end of K_AddShiftToVarPtrCode ***

//************************************************ K_CompareTypes ***
//  Add Shift to Variable Pointer if Field
//
function K_CompareTypes( Type1, Type2 : Int64 ) : Boolean;
begin
  Result := true;
  with TK_ExprExtType(Type2) do
    if (D.TFlags and TK_ExprExtType(Type1).D.TFlags and K_ffRoutine) <> 0 then // compare routine variables
      Result := TK_UDFieldsDescr(DTCode).CompareFuncTypes( TK_ExprExtType(Type1).FD )
    else if (((All xor TK_ExprExtType(Type1).All) and K_ffCompareTypesMask1) <> 0 ) and
            (DTCode <> Ord(nptNotDef))                                              and
            (TK_ExprExtType(Type1).DTCode <> Ord(nptNotDef))                        and
            ( ((D.TFlags and K_ffPointerMask) = 0)            or
              ((TK_ExprExtType(Type1).D.TFlags and  K_ffPointerMask) = 0) )         and
            ( (TK_ExprExtType(Type1).DTCode <> Ord(nptUDRef)) or
//              ((D.TFlags and K_ffClassEx) = 0) )                                   and
//            ( (DTCode <> Ord(nptUDRef))                       or
//              ((TK_ExprExtType(Type1).D.TFlags and K_ffClassEx) = 0) ) then
              (((D.TFlags and K_ffUDRARef) = 0) or (TK_UDFieldsDescr(DTCode).FDObjType <> K_fdtClass)) )                                   and
            ( (DTCode <> Ord(nptUDRef))                       or
              (((TK_ExprExtType(Type1).D.TFlags and K_ffUDRARef) = 0) or (TK_UDFieldsDescr(TK_ExprExtType(Type1).DTCode).FDObjType <> K_fdtClass) )) then
      Result := false;
end; //**** end of K_CompareTypes ***

//************************************************ K_ParseRoutineParams ***
//  Parse Routine Parameters
//
function K_ParseRoutineParams( UDProgItem : TK_UDProgramItem;
  RoutineParDescr : TK_UDFieldsDescr;
  TermChars : string; FuncParDescr : TK_UDFieldsDescr;
  FuncProgItem : TK_UDProgramItem; MethParsCountShift : Integer ) : TK_ExprExtType;
var
  DelChar : Char;
  TermStr : string;
  PDescr : TK_POneFieldExecDescr;
  ParNum, BoundParNum : Integer;
  QData : TK_ParseDataQuality;
begin
  TermStr := K_sccFinListDelim + K_sccParListDelim;
  with FuncProgItem do begin
    BoundParNum := FuncProgItem.ParamsCount + MethParsCountShift;
    ParNum := FuncProgItem.StartParNum;
  end;
  with K_ST, UDProgItem do begin
    shiftPos(0);
    while K_GetDelimiter(DelChar) and
          ( ( DelChar = #0 ) or
            ( Pos(DelChar, TermChars) = 0 ) ) do begin
      if ParNum >= BoundParNum  then
        K_CompilerError( 'Too many actual parameters' );
      PDescr := FuncParDescr.GetFieldDescrByInd(ParNum);
      if DelChar = K_expSubOp then // UNar Minus
        shiftPos(-1)
      else
        shiftPos(0);
      Result := K_ParseSubExpression( UDProgItem, RoutineParDescr,
                Ord(nptNotDef), PDescr.DataType.All, TermStr, false, true,
                QData );

//      if not K_CompareTypes( PDescr.DataType.All, Result.All ) then
      if not K_CompareTypes( K_GetExecTypeBaseCode(PDescr.DataType).All, Result.All ) then
        K_CompilerError( 'Incompatible "'+PDescr.DataName+'" type "'+
                  K_GetExecTypeName(Result.All)+'" needed type is "'+
                  K_GetExecTypeName(PDescr.DataType.All)+'"' );

      Inc(ParNum);
    end;
    if ParNum < BoundParNum  then
      K_CompilerError( 'Not enough actual parameters' );
    shiftPos(0);
  end;

end; //**** end of K_ParseRoutineParams ***

//************************************************ K_ParseSubExpression ***
//  Parse SubExpression   Right
//
function K_ParseSubExpression( UDProgItem : TK_UDProgramItem;
  RoutineParDescr : TK_UDFieldsDescr;
  CurTypeAll, LiteralTypeAll : Int64; TermChars : string; ParseStart : Boolean;
  LiteralAllowed : Boolean;  var QData : TK_ParseDataQuality;
  const ParseText : string = '' ) : TK_ExprExtType;
var
  OpChar, ListChar : Char;
  OpName, Var1, Var2: string;
  CurType : TK_ExprExtType;
  LTypeCode : Integer;
  ExprIFlags : Integer;
  ExprTFlags : Integer;
  PrevDelims : string;
  PrevBrackets : string;
  PrevNonRecur : Integer;
  PrevNestedMin : Integer;
  PrevText : string;
  PrevPos : Integer;
  WCode : Integer;
  BoolOpFlag   : Boolean;
  ConvTypeCode : Integer;
  FuncParDescr : TK_UDFieldsDescr;
  UNarFuncName, TypeName, CTypeName : string;
  IniOPSLevel   : Integer;
  LiteralType   : TK_ExprExtType;
  LiteralFlag   : Boolean;
  LiteralQStr   : Boolean;
  LiteralNum    : Boolean;
  LiteralNumI   : Boolean;
  LiteralNumFD  : Boolean;
  CDescr : TK_OneExprDataDescr;
  ICDescr : TK_OneExprDataDescr;
  LiteralArrayLength : Integer;
  AddNotFunc : Boolean;
  UDClassDescr : TK_UDFieldsDescr;
  WQData : TK_ParseDataQuality;
  OpType   : TK_ExprExtType;
  ArrayElementType : TK_ExprExtType;

const
  HexChar = '$';
//  Digits = ['0','1','2','3','4','5','6','7','8','9'];

label FinParsing, ContParsing, AddOperandOrRoutine, AddFunctionAddress,
      ContParsingLoop;


//**********************
//*** Check Operand Types
//**********************
  procedure CheckTypeCode;
  begin
    if not K_CompareTypes( CurType.All, CDescr.DataType.All ) then
      K_CompilerError( 'Incompatible "'+Var2+'" type "'+
                   K_GetExecTypeName(CurType.All)+'" needed type is "'+
                   K_GetExecTypeName(CDescr.DataType.All)+'"');
  end;

//**********************
//*** Get Type Name
//**********************
  function GetTypeName( CTypeCode : Integer ) : string;
  begin

//    if CTypeCode <= High(K_SPLTypeNames) then
    if (CTypeCode < 0) then CTypeCode := Ord(nptNoData);
    if (CTypeCode >= 0) and (CTypeCode <= Ord(nptNoData)) then
      Result := K_SPLTypeNames[K_SPLFuncTypes[CTypeCode]]
    else
    if CTypeCode > Ord(nptNoData) then
      Result := TK_UDFieldsDescr(CTypeCode).ObjName
{    else
      Result := '*'};
  end;

//**********************
//*** Parse Expression Literal
//**********************
  procedure ParseLiteral;
  var
    DSize    : Integer;
    ErrorStr : string;
    ErrArrElemText : string;
    CDataPos : Integer;
    WType : TK_ExprExtType;
    WTypeFlags : TK_ExprTypeFlags;

    procedure ParseOneLiteral( SStr : string );
    begin
      with UDProgItem, CDescr do
      begin
        Inc( ExprDataBufUsed, DSize  );
        K_SetBArrayCapacity( ExprDataBuf, ExprDataBufUsed );
//        ErrorStr := K_SPLValueFromString( ExprDataBuf[CDataPos], WType, SStr );
        ErrorStr := K_SPLValueFromString( ExprDataBuf[CDataPos], WType.All, SStr );
        if ErrorStr <> '' then
        begin
          if LiteralArrayLength < 0 then
            ErrArrElemText := ''
          else
            ErrArrElemText := ' ['+IntToStr(LiteralArrayLength)+']';
          K_CompilerError( 'Wrong literal value "'+Var2+'" while parsing'+ErrArrElemText+' "'+SStr+'" - '+ErrorStr );
        end;
      end;
    end;

    procedure AddTypeInfo( DCount : Integer );
    var
      CTInfoPos : Integer;
    begin
      with UDProgItem do
      begin
        CTInfoPos := ExprDataBufUsed;
        Inc( ExprDataBufUsed, SizeOf(WType) + SizeOf(Integer) );
        K_SetBArrayCapacity( ExprDataBuf, ExprDataBufUsed );
        with TK_PExprExtType(@ExprDataBuf[CTInfoPos])^ do
        begin
          All := WType.All;
          D.TFlags := D.TFlags and not K_ffArray;
        end;
        PInteger(@ExprDataBuf[CTInfoPos + SizeOf(WType)])^ := DCount;
      end;
    end;

  begin
    with UDProgItem, CDescr do
    begin
//      WType := DataType;
//      WType.D.TFlags := WType.D.TFlags and not K_ffArray; // clear Array Flag
      WType := K_GetExecElemTypeBaseCode(DataType);
      DSize := K_GetExecTypeSize( WType.All );
      WTypeFlags := K_GetExecTypeBaseFlags( DataType );
//      assert( DSize > 0, 'Wrong literal data size' );
      if DSize < 0 then
        K_CompilerError( 'Wrong literal data type' );
      CDataPos := ExprDataBufUsed;
      Data := CDataPos;
      DataType.IFlags := K_ectDataShift or K_ectDataLiteral;
      DataQuality := K_vqLiteral;
//      if (DataType.D.TFlags and K_ffArray) = 0 then begin
      if (WTypeFlags.TFlags and K_ffArray) = 0 then
      begin
        LiteralArrayLength := -1;
        ParseOneLiteral( Var2 );
        LiteralArrayLength := 0;
        AddTypeInfo( 1 );
      end
      else
      begin
        LiteralArrayLength := 0;
        K_SPT.setSource(Var2);
        while K_SPT.hasMoreTokens do
        begin
          CDataPos := ExprDataBufUsed;
          ParseOneLiteral( K_SPT.nextToken(true) );
          Inc(LiteralArrayLength);
        end;
        AddTypeInfo( LiteralArrayLength );
      //*** Set Array Length
        K_AddToExprCode( UDProgItem, LiteralArrayLength, K_ectDataDirect, 0,
                                        Ord(nptInt), 0  );
//        K_AddToExprCode( UDProgItem, K_ExprNSetLengthFuncCI, K_ectRoutine, 0,
//                                        CurType.DTCode, CurType.EFlags.All  );
        WType := K_GetExecTypeBaseCode(CurType);
        K_AddToExprCode( UDProgItem, K_ExprNSetLengthFuncCI, K_ectRoutine, 0,
                                        WType.DTCode, WType.EFlags.All  );
        K_AddToExprCode( UDProgItem, 0, K_ectDataDirect, 0, Ord(nptInt), 0 );
        K_AddToExprCode( UDProgItem, -1, K_ectDataDirect, 0, Ord(nptInt), 0 );
        DataType.IFlags := DataType.IFlags or K_ectVarPtr;
//        DataType.D.TFlags := K_ffPointer; //??** New Literal Array Code
//        Inc( DataType.D.TFlags, K_ffPointer ); //??** New Literal Array Code
        Exit; // Skip Adding Array to Dyn Data Buffer
      end;
    end;
    K_AddToDynData( Var2, CDescr );
  end;


//**********************
//*** Switch Operator Function In Expression Function Stack
//**********************
  procedure SwitchFuncStack( FuncCode : Integer; CType : TK_ExprExtType );
  var
    ResFCode : Integer;
  begin
    if K_OPSLevel >= 0 then
      ResFCode := K_OpParseStack[K_OPSLevel].Code
    else
      ResFCode := -1;
    if (IniOPSLevel = K_OPSLevel) or
       (ResFCode < FuncCode) then
    begin
      K_AddToFuncStack( FuncCode, CType.All );
    end
    else
      while ResFCode >= FuncCode do
      begin
        K_OpParseStack[K_OPSLevel].Code := FuncCode;
      // Add Function code to Code Buffer
        K_AddToExprCode( UDProgItem, ResFCode, Integer(K_ectRoutine), 0,
              CType.DTCode, CType.EFlags.All  );
        if (K_OPSLevel = 0) or (ResFCode = FuncCode) then break;
        Dec(K_OPSLevel);
        ResFCode := K_OpParseStack[K_OPSLevel].Code;
      end;
  end;

//**********************
//*** Add Operator Function To Code Buffer
//**********************
  procedure AddOperatorFunc( FName : string; CType : Int64 );
  begin
    WCode := K_SHFunctions.IndexOf( FName );
    if WCode = -1 then
      K_CompilerError( 'Type "'+TypeName+
        '" is incompatible with operator "'+OpChar+'"' );
    SwitchFuncStack( WCode, TK_ExprExtType(CType) );
  end;

//**********************
//*** Parse Routine Call
//**********************
  procedure ParseRoutineCall( BuildInFuncCode : Integer;
                              FuncParDescr : TK_UDFieldsDescr;
                              MethParsCountShift : Integer );
  var
    LastParType : TK_ExprExtType;
  begin
    CDescr.DataType := K_GetExecTypeBaseCode( K_GetRoutineType( FuncParDescr ) );
    with CDescr do
    begin
      if CDescr.DataQuality <> K_vqConstr then
        if (DataType.DTCode <> -1) then
        begin
          CheckTypeCode;
          DataQuality := K_vqFunc;
        //*** add "Alloc Result" action for Spl Function
          if BuildInFuncCode = -1 then //*** SPL Call
            K_AddToExprCode( UDProgItem, K_saAllocResult,
                                K_ectRoutine or K_ectSpecial, 0,
                                DataType.DTCode, DataType.EFlags.All );
        end
        else
        begin
          if (Var1 <> '') or not ParseStart then
            K_CompilerError( '"'+Var2+'" is not function');
          DataQuality := K_vqProc;
        end;

  //*** Parse function Params List
      K_GetDelimiter(ListChar); // skip comments
      if ListChar = K_sccStartListDelim then
      begin// parse SubExpression
        LastParType := K_ParseRoutineParams( UDProgItem, RoutineParDescr,
                        K_sccFinListDelim, FuncParDescr,
                        TK_UDProgramItem(Data), MethParsCountShift );
        if (BuildInFuncCode = K_ExprNValFuncCI) and
           (LastParType.DTCode > Ord(nptNotDef) ) then
        begin
 // change Function Result DataType if Function is (Value)
          CDescr.DataType := K_GetExecTypeBaseCode( LastParType );
          Dec( CDescr.DataType.D.TFlags, K_ffPointer );
        end;
      end;
    end;
  end;


//**********************
//*** Test if Variable is Routine Call
//**********************
  function IfVariableIsRoutineThenCall(  ) : Boolean;
  var
    VarAddress, VarTypeFlags : Integer;
  begin
    if ((CDescr.DataType.D.TFlags and K_ffRoutine) <> 0) and
       K_GetDelimiter(ListChar)                          and
       (ListChar = K_sccStartListDelim) then
    begin
    //*** Variable is Pointer to SPL Routine - call is needed
      with CDescr do
      begin
        VarAddress := Data;        //*** Save Routine Addres
        VarTypeFlags := DataType.EFlags.All; //*** Save Variable Flags
        // Type Routine ProgItem to Data
        Data := Integer(DataType.FD.Owner); //
        ParseRoutineCall( -1, DataType.FD, 0 );
        K_AddToExprCode( UDProgItem, VarAddress, 0, 0,
                                                Ord( nptUDRef ), VarTypeFlags );
        WCode := K_ExprNCallRoutineFuncCI;
        Result := true;
      end;
    end
    else
      Result := false;
  end;

//**********************
//*** Test if Variable is Class Method Call
//**********************
  function IfVariableIsMethodThenCall(  ) : Boolean;
  var
    VarAddress, VarTypeFlags, VarTypeCode : Integer;
    CMInd : Integer;
  begin
    if ((CDescr.FieldType.TFlags and K_ffClassMethod) <> 0) and
       K_GetDelimiter(ListChar)                          and
       (ListChar = K_sccStartListDelim) then
    begin
      //*** Variable is Pointer to SPL Routine - call is needed
      with CDescr do
      begin
        DataType.D.CFlags := 0; // Clear Count UDRef
        VarAddress := Data;              //*** Save Variable with Method Addres
        VarTypeFlags := DataType.EFlags.All; //*** Save Variable Type Flags
        VarTypeCode := DataType.DTCode;   //*** Save Variable Type Code
        CMInd := CDescr.FieldInd;
        FuncParDescr := TK_UDFieldsDescr(FieldType.TCode);
        Data := Integer(FuncParDescr.Owner);

        if DataQuality = K_vqConstr then
        begin //*** Class Constructor - Add Create Instance
          K_AddToExprCode( UDProgItem, 0, K_ectDataDirect, 0,
                                                  VarTypeCode, VarTypeFlags );
          K_AddToExprCode( UDProgItem, K_ExprNCreateInstanceFuncCI,
            K_ectRoutine, 0, 0, 0 );
        end;

//        Dec(TK_UDProgramItem(Data).ParamsCount); // Because Self is absent in Params List
        ParseRoutineCall( -1, FuncParDescr, -1 );
//        Inc(TK_UDProgramItem(Data).ParamsCount);

        if DataQuality = K_vqConstr then
        begin //*** Class Constructor - Add Class Record Pointer

          //*** Add Last Created Class Object Instance
//          K_AddToExprCode( UDProgItem, K_saPutLastCreated,
//                              K_ectRoutine or K_ectSpecial, 0,
//                              VarTypeCode, VarTypeFlags );
          K_AddToExprCode( UDProgItem, K_saPutLastCreated,
                              K_ectRoutine or K_ectSpecial, 0,
                              Ord(nptUDRef), 0 );
          //*** Convert Class Object Instance (UDBase) to Class Object Data Pointer
          K_AddToExprCode( UDProgItem, K_ExprNGetInstanceFuncCI,
                              K_ectRoutine, 0,
                              VarTypeCode, VarTypeFlags );
          //*** Direct Add Class Constructor Method Address
          K_AddToExprCode( UDProgItem, Data, K_ectDataDirect, 0,
                                                  Ord( nptUDRef ), 0 );

          WCode := K_ExprNCallRoutineFuncCI;

        end
        else
        if TN_UDBase(UDProgItem).Owner = TN_UDBase(Data).Owner then
        begin //*** Static Call From Self Class Method
          //*** Add Class Record Pointer
          K_AddToExprCode( UDProgItem, VarAddress, 0, 0,
                                                  VarTypeCode, VarTypeFlags );
          //*** Direct Add Class Method Address
          K_AddToExprCode( UDProgItem, Data, K_ectDataDirect, 0,
                                                  Ord( nptUDRef ), 0 );
          WCode := K_ExprNCallRoutineFuncCI;

        end
        else
        begin                               //*** Dynamic Method Call
          //*** Add Class Object
{//2006-10-25
          K_AddToExprCode( UDProgItem, VarAddress, 0, 0,
                                                  VarTypeCode, VarTypeFlags );
}
//          K_AddToExprCode( UDProgItem, VarAddress, 0, 0,
//                                                  Ord( nptUDRef ), VarTypeFlags );

          if GUDData <> nil then
          begin
            K_AddToExprCode( UDProgItem, Integer(GUDData), K_ectDataDirect, K_ffUDRARef,
                             Ord( nptUDRef ), 0 );
          //*** Call Function "_PInstance" - put GData Adress to Stack
            K_AddToExprCode( UDProgItem, K_ExprNGetInstanceFuncCI, K_ectRoutine, 0,
                             VarTypeCode, VarTypeFlags );
            if VarAddress <> 0 then
            begin
            //*** Put Data Shift to Stack
              K_AddToExprCode( UDProgItem, VarAddress, K_ectDataDirect, 0, Ord(nptInt), 0 );
            //*** Call Function "SumInts"  - put (GData Pointer + Data Shift) to Stack
              DataType.IFlags := 0;
              Inc(DataType.D.TFlags, K_ffPointer);
              K_AddToExprCode( UDProgItem,
                               K_ExprNSumIntsFuncCI, K_ectRoutine, K_ffUDRARef,
                               Ord( nptUDRef ), DataType.EFlags.All );
              Dec(DataType.D.TFlags, K_ffPointer);
            end;
          //*** Call Function "Value"  - put GData Value to Stack
            K_AddToExprCode( UDProgItem, K_ExprNValFuncCI,
                             K_ectRoutine, 0, VarTypeCode, VarTypeFlags );

          end
          else
            K_AddToExprCode( UDProgItem, VarAddress, 0, 0,
                                                  VarTypeCode, VarTypeFlags );


          //*** Add Class Method Index
          K_AddToExprCode( UDProgItem, CMInd, K_ectDataDirect, 0,
                                                  Ord( nptInt ), 0 );
          WCode := K_ExprNCallMethodFuncCI;
        end;

        FieldType.TCode := -1;
        Result := true;
      end;
    end
    else
      Result := false;
  end;

//**********************
//*** Parse Field Type Params
//**********************
  function ParseFieldType( FieldName : string ) : Boolean;
  var
    PFDescr : TK_POneFieldExecDescr;
  begin
    Result := false;
    with CDescr do
    begin
      FieldType.TCode := -1;
      if (DataType.DTCode >= Ord(nptNoData)) and
         ((DataType.D.TFlags and
            (K_ffArray or K_ffRoutineMask)) = 0) then
      begin
        //*** simple field type
        FieldInd := DataType.FD.IndexOfFieldDescr( FieldName );
        if FieldInd = -1 then //exit;
          K_CompilerError( 'Wrong Field Name "'+FieldName+'"' );
        Result := true;
        PFDescr := DataType.FD.GetFieldDescrByInd(FieldInd);
        PFDescr.DataType := K_GetExecTypeBaseCode( PFDescr.DataType );
        FieldShift := PFDescr^.DataPos;
        FieldType := PFDescr^.DataType.D;
      end;
    end;
  end;

//**********************
//*** Check if Class Constructor Call
//**********************
  function CheckClassConstructor( VarName : string ) : Boolean;
  var
    CLassTypeFlags : TK_ExprTypeFlags;
  begin
    CLassTypeFlags.All := 0;
    with CDescr, DataType do
    begin
      DTCode := K_ParseParamTypeCode( VarName, CLassTypeFlags, false );
      Result := false;
//      if (DTCode <> -1) and
//       ((CLassTypeFlags.TFlags and K_ffClassEx) <> 0) then  begin
      if (CLassTypeFlags.TFlags = K_ffUDRARef) and
         (TK_UDFieldsDescr(DTCode).FDObjType = K_fdtClass) then
      begin
        D.TFlags := CLassTypeFlags.TFlags;
        if K_ST.getDelimiter = K_sccVarFieldDelim then
        begin
          ParseFieldType( K_ST.nextToken() );
//          if (FieldType.TFlags and K_ffClassConstructor) <> 0 then begin
          if ((FieldType.TFlags and K_ffClassMethod) <> 0) and
             (TK_UDFieldsDescr(FieldType.TCode).FDObjType = K_fdtClassConstructor) then
          begin
            DataQuality := K_vqConstr;
            Result := true;
            Exit;
          end;
        end;
        DTCode := -1;
      end;
    end;
  end;

//**********************
//*** Check if Variable Field
//**********************
  function CheckVarField : Boolean;
  begin
    Result := true;
    if CDescr.FieldType.TCode <> -1 then Exit;
    if K_ST.getDelimiter = K_sccVarFieldDelim then
    begin
      ParseFieldType( K_ST.nextToken() );
    end
    else
      Result := false;
  end;

//**********************
//*** Check if Expression Operand was already Parsed
//**********************
  procedure CheckExistedOperand;
  var
    ObjNum : Integer;
  begin
    Var2 := K_ST.nextToken(true); // Operand
    ObjNum := K_SHUsedRLData.IndexOf( Var2 );
    if (ObjNum <> -1) and (ObjNum < K_ExprNDataCount) then
    begin
      CDescr := K_ExprNData[ObjNum];
    end
    else
      CDescr.DataType.DTCode := -1;
  end;

begin

  PrevNonRecur := 0;
  PrevNestedMin := 0;
  IniOPSLevel := K_OPSLevel;
  CurType.All := K_GetExecTypeBaseCode( TK_ExprExtType(CurTypeAll) ).All;
  LiteralType.All := K_GetExecTypeBaseCode( TK_ExprExtType(LiteralTypeAll) ).All;
  with ICDescr do
  begin
    DataType.EFlags.All := 0;
    DataType.DTCode := -1;
    FieldType.TCode := -1;
    FieldInd := -1;
    DataQuality := K_vqOther;
  end;

  with K_ST, UDProgItem do
  begin

    if ParseStart then
    begin
      PrevDelims := Delimiters;
      PrevBrackets := Brackets;
      PrevNonRecur := NonRecurringDelimsInd;
      PrevNestedMin := NestedBracketsInd;
      K_ST.setBrackets( K_sccExprDelimsBrackets, 5 );
      K_ST.setDelimiters( K_sccExprDelimsSet, 5 );
    end;


    PrevPos := 1;
    if ParseText <> '' then
    begin
      PrevText := Text;
      PrevPos := CPos;
      setSource( ParseText );
    end;

    Var1 := '';
    while K_GetDelimiter(OpChar) do
    begin
      K_ErrorPos := CPos;
      UnarFuncName := '';
      BoolOpFlag := false;
      ExprIFlags := 0;
      ExprTFlags := 0;
      if (Var1   <> '')              and
         (OpChar <> K_sccStartIndex) and
         (OpChar <> K_sccVarFieldDelim) then
      begin
//*** parse Operator Name
        if OpChar = K_sccTypeDelim then
        begin
          OpChar := Text[CPos];
          CPos := CPos + 1;
        end;
        OpName := OpChar;
        AddNotFunc := false;
        WCode := K_SHOperators.IndexOf( OpName );
        if WCode = -1 then
        begin // operator is token
          OpName := nextToken(true);
          WCode := K_SHOperators.IndexOf( OpName );
          if WCode = -1 then
            K_CompilerError( 'Unknown operator "'+OpName+'"' )
          else
          begin
            OpName := UpperCase( OpName );
            if OpName = K_expNEOp then
            begin
              OpName := K_expEQOp;
              AddNotFunc := true;
            end else if OpName = K_expLEOp then
            begin
              OpName := K_expGTOp;
              AddNotFunc := true;
            end
            else if OpName = K_expGEOp then
            begin
              OpName := K_expLTOp;
              AddNotFunc := true;
            end;
          end;
        end;
        shiftPos(0);
        if WCode = K_expSetOpInd then
        begin //****** Set Operator
          //*** Correct Expression Code
          with ExprCodeBuf[ExprCodeBufUsed-1] do
          begin
            if (EType.IFlags and K_ectRoutine) <> 0 then
            begin
            //*** Last Code Action - function
              if ( (EType.IFlags and K_ectSpecial) = 0 ) and
                 ( Code = K_ExprNValFuncCI )  then
            //*** change free space occupied by "Value" function
                Dec(UDProgItem.ExprCodeBufUsed);
            end
            else
            begin
            //*** Last Code Action - variable
                EType.IFlags := EType.IFlags or K_ectVarPtr;
                Inc( EType.D.TFlags, K_ffPointer );
            end;
          end;

//          K_AddToFuncStack( K_ExprNSetFuncCI, Ord(nptNotDef) );
          CDescr.DataType := K_GetExecTypeBaseCode(
                        K_ParseSubExpression( UDProgItem, RoutineParDescr,
                            Ord(nptNotDef), CurType.All, K_sccFinStatementDelim, false,
                            true, WQData ) );

          CheckTypeCode;
          if (WQData <> K_vqLiteral) or
             ((CDescr.DataType.D.TFlags and K_ffArray) = 0) then //*** SetValue
            K_AddToExprCode( UDProgItem, K_ExprNSetFuncCI,
                                    K_ectRoutine, 0, Ord(nptNotDef), 0 )
          else
          begin                                             //*** Set Array Elements if Set from Literal Array
            //*** correct code operand type - array -> pointer
            with ExprCodeBuf[ExprCodeBufUsed-1] do EType.D.TFlags := K_ffPointer;
            K_AddToExprCode( UDProgItem, K_ExprNSetElemFuncCI,
                                    K_ectRoutine, 0, Ord(nptNotDef), 0 );
          end;
          goto FinParsing;
        end
        else
        begin          //****** Other Operators
          BoolOpFlag := WCode >= K_expBooleanOpInd;
          if BoolOpFlag then
            OpType.All := Ord(nptInt)
          else
            OpType := CurType;
          TypeName := GetTypeName(CurType.DTCode);
          if AddNotFunc then
            AddOperatorFunc(K_expNotOp+K_SPLTypeNames[Ord(nptInt)], Ord(nptInt));
          AddOperatorFunc(TypeName+OpName, OpType.All);
        end;
      end else
//*** Check Unar "Minus"
        if OpChar = K_expSubOp then UNarFuncName := K_expSubOp;
//************************************************
//***************** Parse Operand ****************
//************************************************
      CDescr := ICDescr;

//*** parse Operand
      ListChar := OpChar;
      if (ListChar <> K_sccVarFieldDelim)  and
         (ListChar <> K_sccStartListDelim) and
         (ListChar <> K_sccStartIndex) then
        K_GetDelimiter(ListChar, true); // skip comments

//*** Add Unar "Minus" after Boolean Operator Funcs if Needed
      if BoolOpFlag and
         (ListChar = K_expSubOp) then
        AddOperatorFunc(K_expSubOp+TypeName, CurType.All );

      K_ErrorPos := CPos;
//*** test Field Expression
      if ListChar = K_sccVarFieldDelim then
      begin// parse Complex Var Name
        //*** Correct Expression Code
        with ExprCodeBuf[ExprCodeBufUsed-1] do
        begin
          if (EType.IFlags and K_ectRoutine) <> 0 then
          begin
          //*** Last Code Action - function
            if ( (EType.IFlags and K_ectSpecial) = 0 ) and
               ( Code = K_ExprNValFuncCI )  then
          //*** change free space occupied by "Value" function
              Dec(UDProgItem.ExprCodeBufUsed);
          end
          else
          begin
          //*** Last Code Action - variable -> correct Code Flags
            EType.IFlags := EType.IFlags or K_ectVarPtr;
            Inc( EType.D.TFlags, K_ffPointer );
          end;
        end;
        CDescr.DataType := K_GetExecTypeBaseCode( ExprCodeBuf[ExprCodeBufUsed-1].EType );
        ParseFieldType( nextToken() );
        with CDescr do
        begin
        //*** Put FieldShift to Stack
          K_AddToExprCode( UDProgItem, FieldShift, K_ectDataDirect, 0, Ord(nptInt), 0 );
        //*** Put Function "SumInts" to Stack
          DataType.D := FieldType;
          Inc(DataType.D.TFlags, K_ffPointer);
          DataType.IFlags := 0;
          K_AddToExprCode( UDProgItem, K_ExprNSumIntsFuncCI,
                           K_ectRoutine, 0, DataType.DTCode,
                           DataType.EFlags.All );

          if (DataType.D.TFlags and K_ffPointerMask) <> 0  then
          begin // No Adr Convertion - Get Value
          //*** Add Value Function
            Dec(DataType.D.TFlags, K_ffPointer);
            K_AddToExprCode( UDProgItem, K_ExprNValFuncCI,
                             K_ectRoutine, 0, DataType.DTCode,
                             DataType.EFlags.All );
          end;
        end;
        if IfVariableIsRoutineThenCall then
          goto AddFunctionAddress;
      end
      else
      if ListChar = K_sccStartIndex then
      begin// parse Index SubExpression
        shiftPos(0);
        with ExprCodeBuf[ExprCodeBufUsed-1] do
        begin
          if (EType.D.TFlags and K_ffArray) = 0 then
            K_CompilerError( 'Variable is not array' );
          K_GetRArrayTypes( EType, ArrayElementType );
        end;

        with CDescr do
        begin
          DataType := K_ParseSubExpression( UDProgItem, RoutineParDescr,
                              Ord(nptInt), Ord(nptInt), K_sccFinIndex,
                              false, true, WQData );
          if DataType.All <> Ord(nptInt) then
            K_CompilerError( 'Wrong array index expression' );
          //*** Put "Array Element Pointer to Stack" function
          DataType.DTCode := ArrayElementType.DTCode;
          DataType.D.TFlags := (DataType.D.TFlags and not K_ffArray) + K_ffPointer;
          DataType.IFlags := 0;
          K_AddToExprCode( UDProgItem, K_ExprNArrayElementFuncCI,
            K_ectRoutine, 0, DataType.DTCode, DataType.EFlags.All );
        //*** Put "Value" function
          Dec(DataType.D.TFlags, K_ffPointer);
          K_AddToExprCode( UDProgItem, K_ExprNValFuncCI,
            K_ectRoutine, 0, DataType.DTCode, DataType.EFlags.All );
        end;
        if getDelimiter <> K_sccVarFieldDelim then shiftPos(0);
        Var2 := '*'; // operand flag
      end
      else
      if ListChar = K_sccStartListDelim then
      begin// parse SubExpression
        shiftPos(0);
        CDescr.DataType := K_GetExecTypeBaseCode( K_ParseSubExpression( UDProgItem, RoutineParDescr,
                            Ord(nptNotDef), LiteralType.All, K_sccFinListDelim, false, true,
                            WQData ) );
        if getDelimiter <> K_sccVarFieldDelim then shiftPos(0);
        Var2 := '*'; // operand flag
      end
      else
      begin // parse next expression Var

        while true do
        begin
          ListChar := getDelimiter;
          CheckExistedOperand;
          if Var2 <> K_expNotOp then break;
          //*** Unar "Not"
          UNarFuncName := K_expNotOp;
        end;

      //************************
      //*** Check if Literal ***
      //************************
        LiteralFlag := true;
        LiteralNum := true;
        LiteralNumI := false;
        LiteralNumFD := false;
        LiteralQStr := false;

//        if LongWord(LiteralType.DTCode) < High(K_SPLTypeNames) then
        if LiteralType.DTCode < Ord(nptNoData) then
          LTypeCode := K_SPLFuncTypes[LiteralType.DTCode]
        else
          LTypeCode := LiteralType.DTCode;
        if (ListChar = K_sccLiteralStringDelim1) or
           (ListChar = K_sccLiteralStringDelim2) then
        begin
          LiteralQStr := true;
          LiteralNum := false;
        end
        else
        if (Var2[1] >= '0') and (Var2[1] <= '9') then
        begin
          if Pos( K_sccNumberDecPoint, Var2 ) > 0 then
            LiteralNumFD := true;
        end
        else
        if (Var2[1] = K_sccNumberDecPoint) then
        begin
          LiteralNumFD := true;
        end
        else
        if (Var2[1] = HexChar) then
        begin
          LiteralNumI := true;
        end
        else
          LiteralFlag := false;

      //****************************
      //*** end of Literal Check ***
      //****************************

      //*****************************
      //*** Check if Used Operand ***
      //*****************************
        if (CDescr.DataType.DTCode <> -1) then begin // Equal Text Values were found

             // New Operand and Found Operand are not literals
          if (not LiteralFlag and (CDescr.DataQuality <> K_vqLiteral)) or
            // New Operand and Found Operand are literals with equal types
             ( LiteralFlag                        and
               (CDescr.DataQuality = K_vqLiteral) and
               (((CDescr.DataType.All xor CurType.All) and K_ectClearIFlags) = 0 ) ) then
          begin //*** Existed Operand Found
            if CheckVarField then
            begin
              if IfVariableIsMethodThenCall then
                goto AddFunctionAddress; //*** Class Method Call

              //*** Field Shift Based on Var Pointer
              K_AddShiftToVarPtrCode( UDProgItem, CDescr );
              if (ExprIFlags = 0) and
                 ((CDescr.DataType.D.TFlags and K_ffPointerMask) <> 0 ) then
              begin // No Adr Convertion - Get Value
              //*** Add Value Function
                Dec(CDescr.DataType.D.TFlags, K_ffPointer);
                K_AddToExprCode( UDProgItem, K_ExprNValFuncCI,
                  K_ectRoutine, 0, CDescr.DataType.DTCode,
                  CDescr.DataType.EFlags.All );
              end;
            end;
            if IfVariableIsRoutineThenCall then
              goto AddFunctionAddress
            else
            begin
              if getDelimiter <> K_sccStartIndex then CheckTypeCode;
              goto AddOperandOrRoutine;
            end;
          end else // Clear Existed Operand Found Description
            CDescr := ICDescr;
          goto ContParsing;
      //************************************
      //*** end of Check if Used Operand ***
      //************************************

        end else begin //**** New Literal or VarName or Function
ContParsing:
          //*********************
          //*** Parse Literal ***
          //*********************
          if LiteralFlag then begin
            if not LiteralAllowed and
               (Var1 = '')        and
               ParseStart         then // Left Side Error
              K_CompilerError( 'Wrong expression left side' );
          //*** Add new Literal Param
            if LiteralQStr then
            begin
              if ( LiteralType.DTCode <= Ord(nptString) ) and
                 ( (LiteralType.D.TFlags and (K_ffFlagsMask or K_ffArray)) = 0 ) then
                CDescr.DataType.DTCode := Ord(nptString)
              else if LiteralAllowed and (Var1 = '') then
                CDescr.DataType := K_GetExecTypeBaseCode( LiteralType )
              else
                CDescr.DataType.DTCode := Ord(nptNotDef);
            end
            else
            if LiteralNumFD then
            begin
              if (LTypeCode = Ord(nptDouble)) or
                 (LTypeCode = Ord(nptFloat))  then
                CDescr.DataType := K_GetExecTypeBaseCode( LiteralType )
              else
                CDescr.DataType.DTCode := Ord(nptDouble);
            end
            else
            if LiteralNumI then
            begin
              if (LTypeCode = Ord(nptInt))  or
                 (LTypeCode = Ord(nptByte)) or
                 (LTypeCode = Ord(nptInt1)) or
                 (LTypeCode = Ord(nptInt2)) or
                 (LTypeCode = Ord(nptUInt2))or
                 (LTypeCode = Ord(nptUInt4))
                   then
                CDescr.DataType := LiteralType
              else
                CDescr.DataType.DTCode := Ord(nptInt);
//            end else
//              CDescr.DataType := CurType;

            end
            else
            if ( CDescr.DataType.DTCode = Ord(nptNotDef) ) or
                        ( LiteralNum and
                          ( (LTypeCode = Ord(nptDouble)) or
                            (LTypeCode = Ord(nptFloat))  or
                            (LTypeCode = Ord(nptInt))    or
                            (LTypeCode = Ord(nptByte))   or
                            (LTypeCode = Ord(nptInt1))   or
                            (LTypeCode = Ord(nptInt2))   or
                            (LTypeCode = Ord(nptUInt2))  or
                            (LTypeCode = Ord(nptUInt4))
                           ) )then
            begin
              CDescr.DataType := LiteralType
            end;

            CheckTypeCode;
            ParseLiteral;
          end
          else
          begin
            //**********************
            //*** Check Variable ***
            //**********************
            if SameText(Var2, K_sccSizeOfType ) then begin
            //*** Size of Type
              Var2 := K_ST.nextToken(true); // Operand
              shiftPos(0);
              LiteralType.EFlags.All := 0;
              LiteralType.DTCode := K_ParseParamTypeCode( Var2, LiteralType.EFlags );
//              LiteralType.D.TFlags := WCode;
              CDescr.Data := K_GetExecTypeSize( LiteralType.All );
              CDescr.DataType.All := Ord(nptInt);
              ExprIFlags := K_ectDataDirect;
              goto AddOperandOrRoutine;
            end else if SameText(Var2, K_sccVarConvToAdr ) then begin
            //*** Convertion Variable to its Address
              shiftPos(0);
              CDescr.DataType := K_GetExecTypeBaseCode( K_ParseSubExpression( UDProgItem,
                           RoutineParDescr, Ord(nptNotDef), Ord(nptNotDef),
                           K_sccFinListDelim, false, true, WQData ) );
              shiftPos(0);

              with ExprCodeBuf[ExprCodeBufUsed-1] do begin
                if (EType.IFlags and K_ectRoutine) <> 0 then begin
                //*** Last Code Action - function
                  if ( (EType.IFlags and K_ectSpecial) = 0 ) and
                     ( Code = K_ExprNValFuncCI )  then
                //*** change free space occupied by "Value" function
                    Dec(UDProgItem.ExprCodeBufUsed);
                end else begin
                //*** Last Code Action - variable -> Convert to Var Address
                  EType.IFlags := EType.IFlags or K_ectVarPtr;
                  Inc( EType.D.TFlags, K_ffPointer );
                end;
              end;
              CDescr.DataType := K_GetExecTypeBaseCode( ExprCodeBuf[ExprCodeBufUsed-1].EType );
              CheckTypeCode;
              goto ContParsingLoop;
            end else if SameText(Var2, K_sccEnumOrder ) then begin
            //*** Conver Enum Member to It's Order
              shiftPos(0);
              CDescr.DataType := K_GetExecTypeBaseCode( K_ParseSubExpression( UDProgItem,
                           RoutineParDescr, Ord(nptNotDef), Ord(nptNotDef),
                           K_sccFinListDelim, false, true, WQData ) );
              shiftPos(0);
              with ExprCodeBuf[ExprCodeBufUsed-1].EType do
              begin
                if ( DTCode < Ord(nptNoData) )            or
                   ( (D.TFlags and K_ffFlagsMask) <> 0 )  or
                   ( Ord(FD.FDObjType) < Ord(K_fdtEnum) ) then
                  K_CompilerError( 'Not enum member "'+Var2+'"');
            //*** Last Code Action - variable -> Convert to Var Address
                DTCode := Ord( nptInt );
                D.TFlags := 0;
              end;
              CDescr.DataType.All := Ord( nptInt );
              CheckTypeCode;
              goto ContParsingLoop;
            end;

            WCode := K_SHEnumMembersList.IndexOf( Var2 );
            if WCode <> -1 then
            begin //*** Enum Member
              with CDescr do
              begin
                DataType.DTCode := Integer(K_SHEnumMembersList.Objects[WCode]);
//                DataType.D.TFlags := K_ffEnumSet;
                CheckTypeCode;
                Data := DataType.FD.IndexOfFieldDescr( Var2 );
              end;
              ExprIFlags := K_ectDataDirect;
              goto AddOperandOrRoutine;
            end
            else
            begin
            // Check if Literal Const Type Casting
              WCode := K_TypeDescrsList.IndexOf( Var2 );
              if (WCode <> -1)            and
                 K_GetDelimiter(ListChar) and
                 (ListChar = K_sccStartListDelim) then
              begin
                 shiftPos(0);
                 LiteralType.All := Integer(K_TypeDescrsList.Objects[WCode]);
                 CDescr.DataType := K_GetExecTypeBaseCode( K_ParseSubExpression( UDProgItem,
                                      RoutineParDescr, LiteralType.All, LiteralType.All,
                                      K_sccFinListDelim, false, true, WQData ) );
                 shiftPos(0);
                 goto ContParsingLoop;
//                 goto AddOperandOrRoutine;
              end;
            end;

            if CDescr.DataType.DTCode = -1 then
            begin// get New Var Type
          //*******************************
          //*** Check Class Constructor ***
          //*******************************
              if not CheckClassConstructor( Var2 ) then
                CDescr := K_ParseVariable( Var2, RoutineParDescr );
            end;

            WCode := K_SHEnumMembersList.IndexOf( Var2 );

            if CDescr.DataType.DTCode <> -1 then
            begin
            //**********************
            //*** Parse Variable ***
            //**********************
              if CheckVarField() then
              begin
                if IfVariableIsMethodThenCall() then
                  goto AddFunctionAddress; //*** Class Method Call
              //*** Field Shift Based on Var Pointer
                K_AddShiftToVarPtrCode( UDProgItem, CDescr );

                if (ExprIFlags = 0) and
                   ((CDescr.DataType.D.TFlags and K_ffPointerMask) <> 0 ) then
                begin // No Adr Convertion - Get Value
                //*** Add Value Function
                  CDescr.DataType.D.TFlags := CDescr.DataType.D.TFlags - K_ffPointer;
                  K_AddToExprCode( UDProgItem, K_ExprNValFuncCI,
                    K_ectRoutine, 0, CDescr.DataType.DTCode,
                    CDescr.DataType.EFlags.All );
                end;
              end
              else
              begin
                Inc(CDescr.DataType.D.TFlags, ExprTFlags); //*** add Pointer flags
              end;

              if IfVariableIsRoutineThenCall() then
                goto AddFunctionAddress
              else
                CheckTypeCode;
            end
            else
            begin
            //**********************
            //*** Check Routine ***
            //**********************
            //*** try Function Name - parse Params List
              WCode := K_SHProgItemsList.IndexOf( Var2 );
              if WCode = -1 then
                K_CompilerError( 'Undefined Name "'+Var2+'"');
              CDescr.Data := Integer(K_SHProgItemsList.Objects[WCode]);
              if not K_GetDelimiter(ListChar) or
                (ListChar <> K_sccStartListDelim) then
              begin //*** parse Routine Pointer Variable
                CDescr.DataType.EFlags.All := 0;
                CDescr.DataType.FD := TK_UDProgramItem(CDescr.Data).GetLDataDescr;
                CDescr.DataType.D.TFlags := K_ffRoutine;
                ExprIFlags := K_ectDataDirect;
              end
              else
              begin //*** parse Call to Routine
//                if WCode < High(K_SPLTypeNames) then begin
                if WCode < Ord(nptNoData) then
                begin
            //  *** Type type conv function
                  shiftPos(0);
                  CDescr.DataType := K_GetExecTypeBaseCode( K_ParseSubExpression( UDProgItem,
                               RoutineParDescr, Ord(nptNotDef), Ord(nptNotDef),
                               K_sccFinListDelim, false, true, WQData ) );
                  shiftPos(0);
                  if (Text[CPos] = K_sccFinListDelim) then shiftPos(1);
                  TypeName := GetTypeName( CDescr.DataType.DTCode );
                  CTypeName := Var2;
                  Var2 := TypeName + 'To' + CTypeName;
                  ConvTypeCode := CDescr.DataType.DTCode;
                  CDescr.DataType.All := WCode; // Conv function type
                  CheckTypeCode;
                  WCode := K_SHFunctions.IndexOf( Var2 );
                  if WCode = -1 then
                  begin
                    if K_GetExecTypeSize( CDescr.DataType.All ) <>  K_GetExecTypeSize( ConvTypeCode ) then
                      K_CompilerError( 'Could not convert "'+TypeName+'" to "'+CTypeName+'"')
                    else
                    begin
                      with ExprCodeBuf[ExprCodeBufUsed-1] do
                        EType.DTCode := CDescr.DataType.DTCode;
                      goto ContParsingLoop;
                    end;
                  end;
                end
                else
                begin
                //*** Other function
                  WCode := K_SHFunctions.IndexOf( Var2 ); // Build In Routine Code
                  ParseRoutineCall( WCode, TK_UDProgramItem(CDescr.Data).GetLDataDescr, 0 );

                  if WCode = -1 then
                  begin //*** SPL Call
                    //*** add Add Program UDBase to Code Buffer if SPL Call
                    with CDescr do
                    begin
                      K_AddToExprCode( UDProgItem, Data, K_ectDataDirect, 0, Ord( nptUDRef ), 0 );
                    end;
                    WCode := K_ExprNCallRoutineFuncCI;
                  end;
                end;
         //*** Add Function Address to Code Buffer
AddFunctionAddress:
                CDescr.Data := WCode;
                ExprIFlags := K_ectRoutine;
              end;
            end;
          end;
        end;
AddOperandOrRoutine:
        with CDescr do
        begin
          if FieldType.TCode = -1 then
          begin // Skip Code Addition - Everything is allready done
            if DataQuality = K_vqGVar then
            begin
              K_AddToExprCode( UDProgItem, Integer(GUDData), K_ectDataDirect, K_ffUDRARef,
                               Ord( nptUDRef ), 0 );
            //*** Call Function "_PInstance" - put GData Adress to Stack
              K_AddToExprCode( UDProgItem, K_ExprNGetInstanceFuncCI, K_ectRoutine, 0,
//                               Ord(nptInt), 0 );
                               DataType.DTCode, DataType.EFlags.All );
              if Data <> 0 then
              begin
              //*** Put Data Shift to Stack
                K_AddToExprCode( UDProgItem, Data, K_ectDataDirect, 0, Ord(nptInt), 0 );
              //*** Call Function "SumInts"  - put (GData Pointer + Data Shift) to Stack
                DataType.IFlags := 0;
                Inc(DataType.D.TFlags, K_ffPointer);
                K_AddToExprCode( UDProgItem,
                                 K_ExprNSumIntsFuncCI, K_ectRoutine, 0,
                                 DataType.DTCode, DataType.EFlags.All );
                Dec(DataType.D.TFlags, K_ffPointer);
              end;
            //*** Call Function "Value"  - put GData Value to Stack
              K_AddToExprCode( UDProgItem, K_ExprNValFuncCI,
                               K_ectRoutine, 0, DataType.DTCode, DataType.EFlags.All );

            end
            else
              K_AddToExprCode( UDProgItem, Data, ExprIFlags, 0,
                               DataType.DTCode, DataType.EFlags.All );
          end;
          CurType := K_GetExecTypeBaseCode( TK_ExprExtType(DataType.All and K_ectClearIFlags) );
          DataType.All := CurType.All or (DataType.All and not K_ectClearIFlags);
        end;
      end;

      if UNarFuncName <> '' then
        AddOperatorFunc( UNarFuncName + GetTypeName(CDescr.DataType.DTCode), CurType.All );

ContParsingLoop:
      if not K_GetDelimiter(ListChar) or
         ((ListChar <> #0) and (Pos( ListChar, TermChars ) > 0) ) then break;

      Var1 := Var2;
//      CurType.All := CDescr.DataType.All and K_ectClearIFlags;
      with CDescr.DataType do
      begin
        CurType := K_GetExecTypeBaseCode( TK_ExprExtType(All and K_ectClearIFlags) );
        All := CurType.All or (All and not K_ectClearIFlags);
      end;
      LiteralType := CurType;
    end;

//*** put functions from stack to Expression Code Buffer
    while K_OPSLevel > IniOPSLevel do
    begin
      with K_OpParseStack[K_OPSLevel] do
      begin
        K_AddToExprCode( UDProgItem, Code, K_ectRoutine, 0,
                                EType.DTCode, EType.EFlags.All );
        CDescr.DataType := K_GetExecTypeBaseCode( EType );
      end;
      Dec( K_OPSLevel, 1 );
    end;

FinParsing:
    if ParseText <> '' then
    begin
      setSource( PrevText );
      setPos( PrevPos );
    end;

    if ParseStart then
    begin
      K_ST.setBrackets( PrevBrackets, PrevNestedMin );
      K_ST.setDelimiters( PrevDelims, PrevNonRecur );
      if (Var1 = '') and
         ((CDescr.DataQuality = K_vqFunc) or
          (CDescr.DataQuality = K_vqConstr)) then //*** check if Clear Stack Action needed
        K_AddToExprCode( UDProgItem, K_ExprNCLSFuncCI,
                                          K_ectRoutine, 0, Ord(nptNotDef), 0 );
    end;

  end;
  Result.All := CDescr.DataType.All and K_ectClearIFlags;
  QData := CDescr.DataQuality;

end; //**** end of K_ParseSubExpression ***

//************************************************ K_CompileRoutineBody ***
//  Parse
//
procedure K_CompileRoutineBody( RoutineRoot : TK_UDProgramItem  );
type BlockInfo = record
 IfCodeAdr : Integer;
 WhileDebInfo : Integer;
 ElseDebInfo : Integer;
 BeginLevel : Boolean;
 SetIfCodeAdr : Integer;
end;

var
  DelChar : Char;
  ItemName: string;
  i, NCapacity, LabelIndex, ItemTextPos, EndTextPos  : Integer;
  RoutineParDescr : TK_UDFieldsDescr;
  CodeAdr : Integer;
  BlockStack : array of BlockInfo;
//  SetIfCodeAdr : Integer;
  WQData : TK_ParseDataQuality;
  BlockLevel : Integer;
  EndBlockFlag : boolean;
  IfDebInfoPos : Integer;
  TempCPos : Integer;
  SaveLabelInfoFlag : Boolean;

label FinAction;

//*** Init Stack Level Data
  procedure ClearBlockLevel;
  begin
    with BlockStack[BlockLevel] do
    begin
      IfCodeAdr := -1;
      WhileDebInfo := -1;
      ElseDebInfo :=  -1;
      BeginLevel := false;
      SetIfCodeAdr := 0;
    end;
  end;

//*** Put Stack Level
  procedure StartBlockLevel( ABegin : Boolean = false );
  begin
//    SetIfCodeAdr := 0;
    Inc(BlockLevel);
    if BlockLevel >= Length( BlockStack ) then SetLength( BlockStack, BlockLevel + 20 );
    ClearBlockLevel;
    BlockStack[BlockLevel].BeginLevel := ABegin;
  end;

//*** Get Stack Level
  procedure FinBlockLevel;
  begin
    Dec(BlockLevel);
//    if BlockStack[BlockLevel].IfCodeAdr <> -1 then SetIfCodeAdr := 1;
  end;

//*** Save Program Operator DebInfo
  procedure SaveOperatorDebInfo( ATextStart, ATextSize : Integer );
  begin
    with RoutineRoot, K_ST do
    begin
      NCapacity := Length(ExprDebInfo);
      if K_NewCapacity( ExprDebInfoUsed+1, NCapacity ) then
        SetLength( ExprDebInfo, NCapacity );
      ExprDebInfo[ExprDebInfoUsed].CodePos := CodeAdr;
      ExprDebInfo[ExprDebInfoUsed].TextStart := ATextStart;
      ExprDebInfo[ExprDebInfoUsed].TextSize := ATextSize;

      Inc( ExprDebInfoUsed, 1 );
    end;
  end;

//*** Save Jump Addresses in GOTO or IFGOTO CompiledCode
  procedure SaveIfWhileInfo;
  begin
    with RoutineRoot do
    begin
      if (BlockStack[BlockLevel].WhileDebInfo <> -1) and EndBlockFlag then
        SaveOperatorDebInfo( EndTextPos, 3 );
      IfDebInfoPos := ExprDebInfoUsed;
      ExprCodeBuf[BlockStack[BlockLevel].IfCodeAdr].EType.DTCode := IfDebInfoPos;
      if BlockStack[BlockLevel].WhileDebInfo <> -1 then
      begin
        K_AddToExprCode( RoutineRoot, K_saGoto, K_ectSpecial + K_ectRoutine, 0,
                                  BlockStack[BlockLevel].WhileDebInfo, 0 );
      end;
      FinBlockLevel;
      while BlockStack[BlockLevel].ElseDebInfo <> -1 do
      begin
        with BlockStack[BlockLevel] do
        begin
          if ElseDebInfo = -2 then
            ExprCodeBuf[IfCodeAdr].EType.DTCode := IfDebInfoPos
          else
            ExprCodeBuf[IfCodeAdr].EType.DTCode := ElseDebInfo
        end;
        FinBlockLevel;
      end;
    end;
  end;

begin
  K_ExprNDataCount := 0;

  K_SHUsedRLData.Clear;

  BlockLevel := 0;
//  SetIfCodeAdr := 0;
  EndBlockFlag := false;
  SetLength( BlockStack, 20 );
  ClearBlockLevel;

{
if RoutineRoot.ObjName = 'InitTaskTemplateVars' then
RoutineRoot.ObjName := 'InitTaskTemplateVars';
if RoutineRoot.ObjName = 'Test11_1' then
RoutineRoot.ObjName := 'Test11_1';
if RoutineRoot.ObjName = 'Test1' then
RoutineRoot.ObjName := 'Test1';
}
  LabelIndex := 0;
  with K_ST, RoutineRoot do
  begin
    ItemTextPos := CPos;
    CodeAdr := 0;
    RoutineParDescr := GetLDataDescr;
    while K_GetDelimiter(DelChar, true) do
    begin

      K_OPSLevel := -1;

      ItemTextPos := CPos;
      K_ErrorPos := ItemTextPos;
      ItemName := nextToken(true);

     //*** Check Label
      SaveLabelInfoFlag := K_GetDelimiter(DelChar)    and
                           (DelChar = K_sccTypeDelim) and
                           (Text[CPos] <> K_expSetOp);
      if SaveLabelInfoFlag then
      begin
        LabelIndex := K_SHRoutineLabels.IndexOf( ItemName );
        if LabelIndex = -1 then
          K_CompilerError( 'Undefined label "'+ItemName+'"' );
        K_ErrorPos := CPos;
        ItemTextPos := CPos;
        K_GetDelimiter(DelChar, true);
        ItemName := nextToken(true); //ProgramItem Type
      end;

      K_GetDelimiter(DelChar);

     //*** Check end of block - END or simple IF without ELSE or simple WHILE
      with BlockStack[BlockLevel] do
        if (IfCodeAdr <> -1)     and
           (EndBlockFlag or (SetIfCodeAdr = 2) ) and
           not SameText(ItemName, K_sccElseOpName) then
          SaveIfWhileInfo();

      if SaveLabelInfoFlag then
      begin
        ExprLabels[LabelIndex] := ExprCodeBufUsed;
        ExprLabelsDI[LabelIndex] := ExprDebInfoUsed;
      end;

      CodeAdr := ExprCodeBufUsed;
      EndBlockFlag := false;
     //*** Parse Program Operator: SubExpression,BEGIN,END,EXIT,IF,ELSE,WHILE,GOTO,DEB,
      if SameText(ItemName,K_sccStartBlock) then
      begin
        //*** BEGIN
        StartBlockLevel( true );
        Continue;
      end else if SameText(ItemName,K_sccFinBlock) then begin
        //*** END
        EndTextPos := ItemTextPos;
        if DelChar = K_sccFinStatementDelim then  shiftPos(1); //*** skip ';'
        if (BlockLevel > 0) and
           not BlockStack[BlockLevel].BeginLevel then
        begin
        // End of the previous level -> close this level
          if BlockStack[BlockLevel].IfCodeAdr <> -1 then
            SaveIfWhileInfo()
        end;

        if BlockLevel = 0 then
        begin
          goto FinAction
        end
        else
        begin
          FinBlockLevel;
          EndBlockFlag := true;
        end;
      end else if SameText(ItemName, K_sccExitOpName) then begin
        //*** EXIT
        K_AddToExprCode( RoutineRoot, K_saExit, K_ectSpecial + K_ectRoutine, 0,
                                        -1, 0 );
      end else if SameText(ItemName, K_sccGotoOpName) then begin
        //*** GOTO
        LabelIndex := K_SHRoutineLabels.IndexOf( nextToken(true) );
        if LabelIndex = -1 then
          K_CompilerError( 'Undefined label "'+ItemName+'"' );
        if ExprLabels[LabelIndex] = -1 then
          ExprLabels[LabelIndex] := -2; //*** use undefined flag
        K_AddToExprCode( RoutineRoot, K_saLGoto, K_ectSpecial + K_ectRoutine, 0,
                                        LabelIndex, 0 );
      end else if SameText(ItemName, K_sccIfOpName) then begin
        //*** IF
        StartBlockLevel;
        K_ParseSubExpression( RoutineRoot, RoutineParDescr,
                          Ord(nptNotDef), Ord(nptInt),
                          K_sccFinListDelim, true, true, WQData );
        BlockStack[BlockLevel].IfCodeAdr := ExprCodeBufUsed;
        K_AddToExprCode( RoutineRoot, K_saIfGoto, K_ectSpecial + K_ectRoutine, 0,
                                        1, 0 );
        TempCPos := CPos;
        ItemName := nextToken(true);
        if ItemName <> K_sccTHENKeyWord then
          setPos( TempCPos ); // no THEN KeyWord
      end else if SameText(ItemName, K_sccElseOpName) then begin
        //*** ELSE
        BlockStack[BlockLevel].ElseDebInfo := ExprDebInfoUsed;
        StartBlockLevel;
        BlockStack[BlockLevel].IfCodeAdr := ExprCodeBufUsed;
        BlockStack[BlockLevel].ElseDebInfo := -2; // Else Level Flag
        K_AddToExprCode( RoutineRoot, K_saGoto, K_ectSpecial + K_ectRoutine, 0,
                                        1, 0 );
        BlockStack[BlockLevel].SetIfCodeAdr := 1;
//        SetIfCodeAdr := 1;
        Continue;
      end else if SameText(ItemName, K_sccWhileOpName) then begin
        //*** WHILE
        StartBlockLevel;
        BlockStack[BlockLevel].WhileDebInfo := ExprDebInfoUsed;
        K_ParseSubExpression( RoutineRoot, RoutineParDescr,
                          Ord(nptNotDef), Ord(nptInt),
                          K_sccFinListDelim, true, true, WQData );
        BlockStack[BlockLevel].IfCodeAdr := ExprCodeBufUsed;
        K_AddToExprCode( RoutineRoot, K_saIfGoto, K_ectSpecial + K_ectRoutine, 0,
                                        1, 0 );
        TempCPos := CPos;
        ItemName := nextToken(true);
        if ItemName <> K_sccDOKeyWord then
          setPos( TempCPos ); // no DO KeyWord
      end else if SameText(ItemName, K_sccDebOpName) then begin
        //*** DEB
        K_ParseSubExpression( RoutineRoot, RoutineParDescr,
                          Ord(nptNotDef), Ord(nptInt),
                          K_sccFinListDelim + K_sccFinStatementDelim, true, true, WQData );
        K_AddToExprCode( RoutineRoot, K_saDeb, K_ectSpecial + K_ectRoutine, 0,
                                        1, 0 );
      end else begin
        //*** SubExpression - Call or Assignment
        setPos( ItemTextPos ); // step to function  name position
        if getDelimiter = K_sccStartListDelim then
          shiftPos(-1);
        K_ParseSubExpression( RoutineRoot, RoutineParDescr,
                          Ord(nptNotDef), Ord(nptNotDef),
                          K_sccFinStatementDelim, true, false, WQData );
      end;

  //*** End of Program Operator
      if BlockStack[BlockLevel].IfCodeAdr <> -1 then Inc(BlockStack[BlockLevel].SetIfCodeAdr);
      // for BEGIN-END-ELSE or no BEGIN-END after IF or WHILE
      if BlockStack[BlockLevel].SetIfCodeAdr > 2 then SaveIfWhileInfo();
      if EndBlockFlag then continue;

  //*** Save Program Operator DebInfo
      SaveOperatorDebInfo( ItemTextPos, Cpos - ItemTextPos );

      if hasMoreTokens and
        (Text[Cpos] = K_sccFinStatementDelim) then  shiftPos(1);

    end;

FinAction:
    if BlockStack[BlockLevel].IfCodeAdr <> -1 then
      SaveIfWhileInfo();
//*** Check Labels Using
    for i := 0 to High(ExprLabels) do
      if ExprLabels[i] = -2 then
        K_CompilerError( 'Use undefined label "'+K_SHRoutineLabels.Strings[i]+'"' );
//*** Resize Program Item Arrays
    SetLength( ExprDataBuf, ExprDataBufUsed );
    SetLength( ExprCodeBuf, ExprCodeBufUsed );
//*** add last DebInfo element
    NCapacity := Length(ExprDebInfo);
    if K_NewCapacity( ExprDebInfoUsed+1, NCapacity ) then
      SetLength( ExprDebInfo, NCapacity );
    ExprDebInfo[ExprDebInfoUsed].CodePos := CodeAdr;
    ExprDebInfo[ExprDebInfoUsed].TextStart := ItemTextPos;
    ExprDebInfo[ExprDebInfoUsed].TextSize := Cpos - ItemTextPos;
    Inc( ExprDebInfoUsed, 1 );
    SetLength( ExprDebInfo, ExprDebInfoUsed );
  end;
end;
//**** end of K_CompileRoutineBody ***

//************************************************ K_ParseUses ***
//  Parse Uses Statement
//
function K_ParseUses : Boolean;
var
DelChar : Char;
Token : string;
UnitFileName : string;
UDProgItem, CUDUses : TN_UDBase;
j, i, h : Integer;
CurResult : Boolean;

begin
  Result := true;
  repeat
    CurResult := true;
    K_ErrorPos := K_ST.CPos;
    Token := K_ST.nextToken( true );
    i := Pos( K_sccUnitFileNameChar, Token );
    UnitFileName := '';
    if i > 0 then begin // Parse Unit File Name
      UnitFileName := Copy( Token, i + 1, Length(Token) );
      Token := Copy ( Token, 0, i - 1 );
    end;
    if Pos( K_udpCursorDelim, Token ) = 0 then Token := K_UnitsRoot + Token;

    CUDUses := K_UDCursorGetObj( Token );

//    if (CUDUses = nil) or (UnitFileName <> '') then  // Try to Compile File
    if (UnitFileName <> '') then  // Try to Compile File
      CurResult := (K_CompileScriptFile( K_ExpandFileName( UnitFileName ), TK_UDUnit(CUDUses) ) <> 0);

    if CUDUses <> nil then begin
      if (CUDUses.ClassFlags and $FF) <> K_UDUnitCI then
        K_CompilerError( 'Used "'+Token+'" is not unit' );

      CurResult := CurResult and (TK_UDUnit(CUDUses).CompilerErrMessage = '');

      if CurResult and (CUDUses.DirLength = 0) then // not Compiled - Compile
        CurResult := K_CompileUnit( '', TK_UDUnit(CUDUses) );

  //*** add  Usese members to Global Types List
      if CurResult then begin
        h := CUDUses.DirHigh;
        for i := 0 to h do begin
          UDProgItem := CUDUses.DirChild(i);
          if (UDProgItem.ClassFlags and $FF) = K_UDProgramItemCI then
            K_SHProgItemsList.AddObject( UDProgItem.ObjName, UDProgItem )
          else if UDProgItem.ObjName = K_sccUnitDataNode then
            K_LGlobalData.Add( UDProgItem )
          else if (UDProgItem.ClassFlags and $FF) = K_UDFieldsDescrCI then begin
            K_SHDataTypesList.AddObject( UDProgItem.ObjName, UDProgItem );
            with TK_UDFieldsDescr(UDProgItem) do
              if FDObjType = K_fdtEnum then begin
  //?? Error while using variant Set elements because FieldsCount equals only main elements - not variants
  //              for j := 0 to FieldsCount - 1 do
                for j := 0 to High(FDV) do
                  K_SHEnumMembersList.AddObject( FDV[j].FieldName, UDProgItem );
              end;
          end;
        end;
      end;
      Result := CurResult and Result;
    end else
      K_CompilerError( 'Unit "'+Token+'" is absent' );
  until not K_GetDelimiter( DelChar ) or
       (DelChar <> K_sccParListDelim);
end;
//**** end of K_ParseUses ***

//************************************************ K_AddFieldsTypeFlagSet
// Add  Fields Reference type flags
//
procedure K_AddFieldsTypeFlagSet( TypeCode : Integer; TypeFlags : TK_ExprTypeFlags;
                       var FieldsTypeFlagSet : TK_FFieldsTypeFlagSet );
begin
  if (TK_ExprTypeFlags(TypeFlags).TFlags and K_ffFlagsMask) = 0 then begin
    if TypeCode > Ord(nptNoData) then
      FieldsTypeFlagSet := TK_UDFieldsDescr(TypeCode).FDFieldsTypesFlags
    else begin
      if (TypeCode = Ord(nptUDRef)) or (TypeFlags.TFlags = K_ffVArray) then
        FieldsTypeFlagSet := FieldsTypeFlagSet + [K_fftUDRefs];
      if TypeCode = Ord(nptString) then
        FieldsTypeFlagSet := FieldsTypeFlagSet + [K_fftStrings];
    end;
  end;
end; //**** end of K_AddFieldsTypeFlagSet

//************************************************ K_ParseVarFieldNames ***
//  Parse Variable and Field Name
//
function K_ParseVarFieldNames(FullName : string; out FieldName : string) : string;
var FNPos : Integer;
begin
  Result := '';
  FNPos := Pos( K_sccVarFieldDelim, FullName );
  if FNPos > 0 then begin //*** Local Param Data Base - prepare Field Name
    if FNPos > 1 then
      Result := Copy( FullName, 1, FNPos-1 );
    FieldName := Copy( FullName, FNPos + 1, Length(FullName) );
  end else begin
    Result := FullName;
    FieldName := '';
  end;
end; //**** end of K_ParseVarFieldNames ***

//************************************************ K_CompileUnitBody ***
//  Parse
//
procedure K_CompileUnitBody( UDUnitRoot : TN_UDBase; Recompile : Boolean );
var
  UDProgItem, WCUD : TN_UDBase;
  UDDataParDescr : TK_UDFieldsDescr;
  UDMethodDescr, UDClassDescr, UDParDescr : TK_UDFieldsDescr;
  DelChar : Char;
  Token, ItemClass, ItemName : string;
  ClassInd : Integer;
  ItemTextPos : Integer;
  NDefPars, j : Integer;
  TypeDefMode : Boolean;
  ClassDefMode : Boolean;
  UnitDataIndex : Integer;
  UDData : TK_UDRArray;
  ParTypeCode  : Integer;
  ElemTypeCode  : Integer;
  ClassMethFlags, ParTypeFlags, ElemTypeFlags : TK_ExprTypeFlags;
  WStr : string;
  GDataHList : THashedStringList;
  ParValue, FieldName : string;
  PMethodFieldDescr : TK_POneFieldExecDescr;
  ImplementationMode : Boolean;
  PrivateDescrMode : Boolean;
  EnumType : TK_ExprExtType;
  TypeAliase : string;
  SysComment : string;
// Data Version Info
  WDFVer : array [0..2] of Integer; // 0 - CurF, 1 - PDNT, 2 - NDPT
  SCh : Integer;

label LExit, ParseClassMenthods, ParseCont;

//*****************************
//*** Create Programm Item ****
//*****************************
  procedure CreateProgItem( Name : string; AddDescrToList, AddItemToUnitRoot : Boolean;
        out AUDParDescr : TK_UDFieldsDescr; out AUDProgItem : TN_UDBase;
        SHW : THashedStringList = nil );
  var
    GDIndex : Integer;
    ExUDProgItem : TN_UDBase;
  begin

    NDefPars := K_MaxParamInd;

//*** add  params descriptions node
    AUDParDescr := TK_UDFieldsDescr.Create;
    AUDParDescr.ObjName := Name;
    AUDParDescr.FDObjType := K_fdtRecord;
    if ClassInd <> K_UDFieldsDescrCI then begin
      AUDProgItem := N_ClassRefArray[ClassInd].Create;
      AUDProgItem.AddOneChild( AUDParDescr );
      if ClassInd = K_UDProgramItemCI then begin
        AUDParDescr.FDObjType := K_fdtRoutine;
        TK_UDProgramItem(AUDProgItem).SourceUnit := TK_UDUnit(UDUnitRoot);
      end;
      WCUD := AUDProgItem;
      WCUD.ObjName := Name;
      if AddItemToUnitRoot then
      begin // special Init Item - don't add to Items List
        GDIndex := K_SHProgItemsList.IndexOf( Name );
        if GDIndex <> -1 then
        begin
          ExUDProgItem := TN_UDBase(K_SHProgItemsList.Objects[GDIndex]);
          if (ExUDProgItem.Owner <> UDUnitRoot) or // Exist in Other Unit
             not Recompile then
            K_CompilerError( format( 'Redefine "%s" defined in unit "%s"',
                  [Name, ExUDProgItem.Owner.ObjName] ) )
        end;
        K_SHProgItemsList.AddObject( Name, WCUD );
        if not ImplementationMode and not PrivateDescrMode then
          UDUnitRoot.AddOneChild( WCUD );
      end;
    end;

    if AddDescrToList then begin// Record or Routine type Description case
      K_SHDataTypesList.AddObject( Name, AUDParDescr );
      if not ImplementationMode and not PrivateDescrMode then begin
        UDUnitRoot.AddOneChild( AUDParDescr );
        GDIndex := K_TypeDescrsList.IndexOf( Name );
        if GDIndex <> -1 then begin
          if not Recompile then
            K_CompilerError( 'Redefine record or class type "'+Name+'"' )
          else
            K_TypeDescrsList.Objects[GDIndex] := AUDParDescr;
        end else
          K_TypeDescrsList.AddObject( Name, AUDParDescr ); // Add to global descriptions list
      end;
    end;

    if SHW <> nil then SHW.Clear;

    if Length(K_ExprNData) < K_MaxParamInd then
      SetLength(K_ExprNData, K_MaxParamInd);

  end;


//*****************************
//**** Parse Enum and Set Size
//*****************************
  procedure ParseEnumAndSetSize( AUDParDescr : TK_UDFieldsDescr;
                                   AObjType : TK_DescrType );
  var
    ENumType : TK_ExprExtType;
    SizeTypeName : string;
  begin

    with AUDParDescr, K_ST do begin
      FDObjType := AObjType;
      if DelChar = K_sccTypeDelim then begin
        K_ErrorPos := CPos;
        SizeTypeName := nextToken( true );
        ENumType := K_GetTypeCode( SizeTypeName );
        if ENumType.DTCode <> -1 then
          FDRecSize := K_GetExecTypeSize( ENumType.All )
        else begin
          K_CompilerError( 'Wrong Size Definition Type Name "'+SizeTypeName+'"' );
        end;
      end else begin
        if FDObjType = K_fdtEnum then
          FDRecSize := ( FDFieldsCount + 255 )  shr 8 // real size of enum
        else begin
          FDRecSize := ( FDFieldsCount + 7 )  shr 3;  // real size of set
          if FDRecSize = 3 then FDRecSize := 4;
        end;
      end;
      if K_GetDelimiter(DelChar) and (DelChar = K_sccFinDefDelim) then
        shiftPos(1);
    end;
  end;

//*****************************
//**** Parse Enum Elements List
//*****************************
  procedure ParseEnumElementsList( AUDParDescr : TK_UDFieldsDescr;
                                   SHWParams : THashedStringList;
                                   AObjType : TK_DescrType = K_fdtEnum );
  var
    EnumName, EnumLegendName : string;
    VariantMember : Boolean;
    i : Integer;
  begin
    with AUDParDescr, K_ST do begin
      FDObjType := AObjType;
      K_SetEnumVariants.Clear;
      repeat

        if not K_GetDelimiter(DelChar) or
          (DelChar = K_sccFinListDelim) then begin
          break;
        end;

        K_ErrorPos := CPos;
        K_GetDelimiter(DelChar,true);

        EnumName := nextToken( true );
        if (EnumName = '') then break;


        VariantMember := false;
        if SameText(K_sccVariantQual, EnumName) then begin
//          CParTypeFlags.CFlags := K_ccVariant;
          EnumName := nextToken( true );
          VariantMember := true;
        end;

        if SHWParams.IndexOf( EnumName ) <> -1 then
          K_CompilerError( 'Redefine "'+EnumName+'"' );

        if K_SHEnumMembersList.IndexOf( EnumName ) <> -1 then
          K_CompilerError( 'Redefine "'+EnumName+'"' );

        EnumLegendName := '';
        K_GetDelimiter(DelChar);
        if DelChar = K_sccParValueDelim then begin
          EnumLegendName := nextToken( true );
        end;

        if not VariantMember then
          FDV[
          AddOneFieldDescr( EnumName, Ord(nptNotDef), 0, -1, 1 )
           ].FieldDefValue := EnumLegendName
        else
          K_SetEnumVariants.AddObject(EnumName, TObject(FDFieldsCount-1) );
        SHWParams.Add( EnumName );

        K_SHEnumMembersList.AddObject( EnumName, AUDParDescr );
      until false;
      K_GetDelimiter(DelChar, true);
   //*** Add Variant Members
      ParTypeFlags.All := 0;
      ParTypeFlags.CFlags := K_ccVariant;
      for i := 0  to K_SetEnumVariants.Count - 1 do
        AddOneFieldDescr( K_SetEnumVariants[i], Ord(nptNotDef), ParTypeFlags.All,
                              Integer(K_SetEnumVariants.Objects[i]), 1 );
      FDFieldsCount := FDFieldsCount - K_SetEnumVariants.Count;
      ParseEnumAndSetSize( AUDParDescr, FDObjType );
    end;
  end;

//*****************************
//**** Parse Routine Data *****
//*****************************
  function ParseTypedElementsList( ParseRoutineParams : Boolean;
    AUDParDescr : TK_UDFieldsDescr; SHTermTokens, SHWParams : THashedStringList ) : string;
  var
    ParSize : Integer;
    ParPos : Integer;
    CFlags : Integer;

  begin
    K_ST.setBrackets( K_sccParDelimsBrackets, 5 );
    K_ST.setDelimiters( K_sccParDefDelimsSet, 5 );
    with AUDParDescr, K_ST do begin

      CFlags := 0;
      while true do begin

        if not K_GetDelimiter(DelChar, true) or
          (DelChar = K_sccFinListDelim) then begin
          Result := '';
          Exit;
        end;

      //*** parse Param Name
        K_ErrorPos := CPos;
        K_GetDelimiter(DelChar,true);

        Result := nextToken( true );
        if (Result = '') or
           ((SHTermTokens <> nil) and
            (SHTermTokens.IndexOf( Result ) <> -1)) then Exit;

//*** parse field quality
{
        if SameText(K_sccPublishedQual, Result) then begin
          CFlags := CFlags and not K_ccPrivate;
          continue;
        end else
}
        if SameText(K_sccRuntimeQual, Result) then begin
          CFlags := CFlags or K_ccRuntime;
          continue;
        end else if SameText(K_sccObsoleteQual, Result) then begin
          CFlags := CFlags or K_ccObsolete;
          continue;
        end else if SameText(K_sccVariantQual, Result) then begin
          CFlags := CFlags or K_ccVariant;
          continue;
        end else if SameText(K_sccPrivateQual, Result) then begin
          CFlags := CFlags or K_ccPrivate;
          continue;
        end;


        if SHWParams.IndexOf( Result ) <> -1 then
          K_CompilerError( 'Redefine "'+Result+'"' );

        K_ErrorPos := CPos;
        K_ParseDataType( ParTypeCode, ParTypeFlags, ParValue, '' );

        if ParTypeCode = -1 then
          K_CompilerError('Type is absent' );
{ //30.10.2006
        if ParseRoutineParams and ( RecSize <> 0 ) then
          ParPos := RecSize + SizeOf(TK_ExprExtType)
        else if ItemClass = K_sccVarRecordDef then
          ParPos := 0
        else if (CFlags and K_ccVariant) <> 0 then
          ParPos := -2
        else
          ParPos := -1;
}

        if ItemClass = K_sccVarRecordDef then
          ParPos := 0
        else if (CFlags and K_ccVariant) <> 0 then
          ParPos := -2
        else
          ParPos := -1;

        if (CFlags and K_ccObsolete) <> 0 then
          ParSize := 0
        else
          ParSize := -1;

        TK_ExprTypeFlags( ParTypeFlags ).CFlags := CFlags;
{//30.10.2006
        V[
        AddOneFieldDescr( Result, ParTypeCode, ParTypeFlags.All, ParPos, ParSize )
         ].FieldDefValue := ParValue;
}
        with FDV[AddOneFieldDescr( Result, ParTypeCode, ParTypeFlags.All, ParPos, ParSize )] do begin
          FieldDefValue := ParValue;
          if ParseRoutineParams then
            FDRecSize := FDRecSize + SizeOf(TK_ExprExtType);
        end;
//*** Set Fields Reference type flags
        K_AddFieldsTypeFlagSet( ParTypeCode, ParTypeFlags, FDFieldsTypesFlags );

        SHWParams.Add( Result );

        Inc(j);
//*** Clear CFalgs
        CFlags := 0;

        if not K_GetDelimiter(DelChar) or (DelChar <> K_sccFinDefDelim)  then break;
      end;
    end;

    if (ItemClass <> K_sccFunctionDef) then begin
      K_ST.setBrackets( K_sccTokenBrackets, 5 );
      K_ST.setDelimiters( K_sccDelimsSet, 5 );
    end;

  end;

//*****************************
//******* Parse Routine *******
//*****************************
  procedure ParseRoutine( AItemName : string; AddDescrToList, AddToItemUnit  : Boolean;
        out AUDParDescr : TK_UDFieldsDescr; out AUDProgItem : TN_UDBase;
        UDClassParDescr : TK_UDFieldsDescr = nil  );
  var
    ResTypeCode{, ParPos} : Integer;
    ResTypeFlags : TK_ExprTypeFlags;
//    ResParName : string;
  begin

//    if FieldName <> '' then begin
//    end;

    ClassInd := K_UDProgramItemCI;
//*** create Program Item node
    CreateProgItem( AItemName, AddDescrToList, AddToItemUnit,
                                AUDParDescr, AUDProgItem, K_SHUsedRLData );

    DelChar := #0;

    with K_ST, TK_UDProgramItem(AUDProgItem) do begin
      StartParNum := 0;
      ResTypeFlags.All := 0;
      if ItemClass = K_sccFunctionDef then begin
        ResTypeCode := Ord(nptNotDef);
//        ResParName := K_sccFuncResultPar;
      end else if ItemClass = K_sccClassConstructorDef then begin
        ResTypeCode := Integer(UDClassParDescr);
        ResTypeFlags.TFlags := K_ffUDRARef;
//        ResParName := '_'+K_sccFuncResultPar; // special Result Param Name for Constructor
      end else
        ResTypeCode := -1;

      if ResTypeCode <> -1 then begin
        //*** Add Result Parameter
        AUDParDescr.AddOneFieldDescr ( K_sccFuncResultPar, ResTypeCode, ResTypeFlags.All, 0 );
        j := 1;
        StartParNum := 1;
        K_SHUsedRLData.Add( K_sccFuncResultPar );

        //*** Add place for Result Type //30.10.2006
        with AUDParDescr do
          FDRecSize := FDRecSize + SizeOf(TK_ExprExtType);
      end else
        j := 0;

      ParseTypedElementsList( true, AUDParDescr, nil, K_SHUsedRLData );

      if UDClassParDescr <> nil then begin //*** Add Class Method "Self" data structure Pointer
        with AUDParDescr do begin
{ //30.10.2006
          if RecSize <> 0 then
            ParPos := RecSize + SizeOf(TK_ExprExtType)
          else
            ParPos := -1;
          AUDParDescr.AddOneFieldDescr( K_sccClassFieldsName,
                                  Integer(UDClassParDescr), K_ffPointer, ParPos );
}
          AddOneFieldDescr( K_sccClassFieldsName,
                                  Integer(UDClassParDescr), K_ffPointer, -1 );
          FDRecSize := FDRecSize + SizeOf(TK_ExprExtType);
        end;
        Inc(j);
      end;

      ParamsCount := j;
      TextPos := ItemTextPos;

      if ItemClass = K_sccFunctionDef then begin
        shiftPos(0); //*** to skip ')'
        K_ParseDataType( ParTypeCode, ParTypeFlags, ParValue, '' );

//!!!!! Error in all procedure definitions in class definition -> was closed 23-03-2005
//         setBrackets( K_sccTokenBrackets, 5 );
//         setDelimiters( K_sccDelimsSet, 5 );

        if ParTypeCode = -1 then
          K_CompilerError( 'Function "'+AItemName+'" has no result type' );
        with AUDParDescr do
          ChangeFieldType ( 0, ParTypeCode, ParTypeFlags.All );
      end;

      if K_GetDelimiter(DelChar) and (DelChar = K_sccFinListDelim) then
        shiftPos(1); //*** skip ';'
    end;
  end;

//*****************************
//******* Parse Item Name *****
//*****************************
  procedure ParseItemName;
  begin
    with K_ST do begin
      K_GetDelimiter(DelChar);
      ItemTextPos := CPos;
      K_ErrorPos := CPos;
      ItemName := nextToken( true ); //ProgramItem Name

      if (ItemName = '') or
         not hasMoreTokens then
        K_CompilerError( 'Error in Program Item "'+ItemClass+'"  definition ' );
    end;
  end;

//*****************************
//******* Parse Class AddInfo
//*****************************
  procedure ParseClassAddInfo;
  var
    PropName, PropValue : string;
    ClassInd : Integer;
    WW : TN_UDBase;
  begin
    K_GetDelimiter(DelChar);
    with K_ST do begin
      DelChar := getDelimiter;
      if DelChar = K_sccStartListDelim then begin
        shiftPos(1);
        shiftPos(-1); //Clear Bracket Start Flag
        repeat
          K_ErrorPos := CPos;
          PropName := '';
          PropValue := nextToken( true );
          K_GetDelimiter(DelChar);
          if DelChar = K_sccParValueDelim then begin
            PropName := PropValue;
            PropValue := nextToken( true );
            K_GetDelimiter(DelChar);
          end;
          if (PropName = '') or
             ( SameText(PropName, K_sccClassParentDef) ) then begin //*** set parent Class Name
          end else if SameText(PropName, K_sccClassUDDef) then begin
            ClassInd := K_GetUObjCIByTagName( PropValue, false );
            if ClassInd = -1 then
              K_CompilerError( 'Wrong Class Instance Name "'+PropValue+'"' );
            WW := N_ClassRefArray[ClassInd].Create;
            if not K_IsUDRArray(WW) then
              K_CompilerError( 'Wrong Class Instance Name "'+PropValue+'"' );
            WW.UDDelete;
            UDClassDescr.FDUDClassInd := ClassInd;
          end;
        until DelChar = K_sccFinListDelim;
        shiftPos(0);
      end;
    end;
  end;

  function GetSysComVerValue0(  ) : Integer;
  var
    StartPos : Integer;
  begin
    StartPos := j;
    while (j <= SCh) and (SysComment[j] <> ' ' ) do Inc(j);
    Result := StrToIntDef( Copy( SysComment, StartPos, j - StartPos ), -1 );
  end;

  procedure GetSysComVerValue(  );
  var
    WWDFVer : Integer;
    StartPos : Integer;
  begin
    Inc(j);
    StartPos := j;
    while (j <= SCh) and (SysComment[j] <> '=' ) do Inc(j);
    if j < SCh then begin
      K_SysComment := Copy( SysComment, StartPos, j - StartPos );
      Inc(j);
      WWDFVer := GetSysComVerValue0();
      if K_SysComment = 'PDNT' then
        WDFVer[1] := WWDFVer
      else if K_SysComment = 'NDPT' then
        WDFVer[2] := WWDFVer;
    end;
  end;

  procedure SetTypeVerInfo( AUDType : TK_UDFieldsDescr );
  begin
    if WDFVer[0] = -1 then Exit;
    AUDType.FDCurFVer := WDFVer[0];
    if WDFVer[1] <> -1 then
      AUDType.FDPDNTVer := WDFVer[1];
    if WDFVer[2] <> -1 then
      AUDType.FDNDPTVer := WDFVer[2];
    WDFVer[0] := -1; // Clear Version Info Actual Flag
  end;

begin

//*** Create BuildIn Routines List if needed
  if K_SHFunctions.Count = 0 then
    for j := 0 to High(K_ExprNFuncRefs) do begin
      if K_ExprNFuncNames[j] = '' then
        WStr := IntToStr(j)
      else
        WStr := K_ExprNFuncNames[j];
      K_SHFunctions.Add(wstr);
    end;


//************ Create Unit Data Structure
//***  Var Section
  ClassInd := K_UDUnitDataCI;
  CreateProgItem( UDUnitRoot.ObjName, false, true, UDDataParDescr,
                                        TN_UDBase(UDData), K_SHUsedRLData );
  UDData.ObjName := K_sccUnitDataNode;
  UDData.R.FEType.DTCode := Integer(UDDataParDescr);
  K_LGlobalData.Add( UDData );
  K_UDCurGlobalData := UDData;
//*** Correct UDData Description Unit Position
  UDUnitRoot.InsOneChild( UDUnitRoot.DirHigh, UDDataParDescr );
//??  UDUnitRoot.AddOneChild( UDDataParDescr );
  UDDataParDescr.Owner := UDUnitRoot;

  GDataHList := THashedStringList.Create;
//*** Wrk Data Initialization
  UnitDataIndex := 0;
  ItemClass := '';
  TypeDefMode := false;
  ClassDefMode := false;
  ImplementationMode := false;
  WDFVer[0] := -1; // Clear Version Info Actual Flag
  with K_ST do
    while K_GetDelimiter(DelChar) do
    begin
  //*************************
  //*** Parse Module Loop ***
  //*************************
      K_GetDelimiter(DelChar, true);

      if K_SysComment <> '' then
      begin
      //***  Parse SysComment string
        SysComment := Trim( Copy( K_SysComment, 2, Length(K_SysComment) ) );
        if K_StrStartsWith( 'CurF=' , SysComment, true, 6 ) then
        begin
          //WDFVer : array [0..2] of Integer; // 0 - CurF, 1 - PDNT, 2 - NDPT
          FillChar( WDFVer[0], 3 * SizeOf(Integer), -1 );
          SCh := Length(SysComment);
          j := 6;
          WDFVer[0] := GetSysComVerValue0();
          GetSysComVerValue();
          GetSysComVerValue();
{
          if WDFVer[1] = -1 then
            WDFVer[1] := WDFVer[0];
          if WDFVer[2] = -1 then
            WDFVer[2] := WDFVer[0];
}
        end;
        K_SysComment := '';
      end;


      K_ErrorPos := CPos;
      ItemClass := LowerCase( nextToken( true ) ); //Procedure definition or Base ProgramItem
ParseCont:
      if ItemClass = '' then break;
      if ItemClass = K_sccDataInit then begin
        if UnitDataIndex > 0 then begin
//*** Create Init Program Item
          ClassInd := K_UDProgramItemCI;
          CreateProgItem( K_sccInitDataProgName, false, false, UDParDescr, UDProgItem );
          TK_UDProgramItem(UDProgItem).ParamsCount := 1;
          UDParDescr.AddOneFieldDescr ( K_sccInitDataNamePref, Integer(UDDataParDescr), K_ffPointer );
          Inc( UDParDescr.FDRecSize, SizeOf(TK_ExprExtType) );
          UDParDescr.AddOneFieldDescr ( '', 0 ); // close Description
          K_CompileRoutineBody( TK_UDProgramItem(UDProgItem) );
//*** Build GData Parameter Description
          UDDataParDescr.RefreshFieldsExecDescr;
          UDDataParDescr.AddOneFieldDescr ( K_sccInitDataProgName, Integer(UDProgItem),
                                                        K_ffClassMethod, 0, 0 );
          UDDataParDescr.AddOneFieldDescr ( '', 0 ); // close Description
          UDData.R.ElemSize := UDDataParDescr.FDRecSize;
          UDData.ASetLength(1);
        end;
        goto LExit;
      end;

      if ItemClass = K_sccPrivateQual then begin
        PrivateDescrMode := true;
        continue;
      end else
        PrivateDescrMode := false;

      if ItemClass = K_sccImplementation then begin
        ImplementationMode := true;
        continue;
      end;

//??      if ItemClass = K_sccUsesDef then
//??        K_ParseUses();

      //*** Select Curren Item Class
      if ItemClass = K_sccDataDef then begin
        if UnitDataIndex <> 0 then
          K_CompilerError( 'Unit data was already defined' );
//*** Data definition
        UDDataParDescr.RefreshFieldsExecDescr;
        NDefPars := K_MaxParamInd;
        j := 0;
        K_ErrorPos := CPos;
        ItemClass := LowerCase( ParseTypedElementsList( false, UDDataParDescr, K_SHTermTokens, GDataHList  ) );
        UnitDataIndex := j;
        if UnitDataIndex > 0 then begin
          UDData.R.ElemSize := UDDataParDescr.FDRecSize;
          UDData.ASetLength(1);
        end;
        TypeDefMode := false;
        ClassDefMode := false;
        goto ParseCont;
      end;

ParseClassMenthods:
      if ClassDefMode and
        (ItemClass = K_sccFinBlock) then begin
        UDClassDescr.AddOneFieldDescr ( '', 0 ); // close Description
        ClassDefMode := false;
        TypeDefMode := false;
        continue;
      end else
        ParseItemName();

      UDProgItem := nil; // skip warning statement
      NDefPars := 0;

      if ItemClass = K_sccDataType then begin
        K_ErrorPos := CPos;
        setDelimiters( K_sccDelimsSet, 5 );
        K_GetDelimiter( DelChar, true );

       if K_TypeAliase <> '' then
          TypeAliase := Trim( Copy( K_TypeAliase, 2, Length(K_TypeAliase) ) )
        else
          TypeAliase := '';

        if DelChar = K_sccStartListDelim then begin//*** parse enum declaration
//*** create FieldDescr
          ClassInd := K_UDFieldsDescrCI;
          CreateProgItem( ItemName, true, false, UDParDescr, UDProgItem,  K_SHUsedRLData );
          UDParDescr.ObjAliase := TypeAliase;
          ParseEnumElementsList( UDParDescr, K_SHUsedRLData );
          // Set Version Info
          SetTypeVerInfo( UDParDescr );
          continue;
        end;
        K_ErrorPos := CPos;
        ItemClass := LowerCase( nextToken( true ) );
        if ItemClass = K_sccPackedQual then
        begin
          K_ErrorPos := CPos;
          ItemClass := LowerCase( nextToken( true ) );
        end;
        TypeDefMode := true;
      end;

      if TypeDefMode then
      begin //*** New Type Definition
        if ItemClass = K_sccClassDef then
        begin  //*** Class
          ClassDefMode := true;
          ClassInd := K_UDFieldsDescrCI;
//*** create FieldDescr

{
if ItemName = 'TK_MVTAIntervalSeries' then
ItemName := 'TK_MVTAIntervalSeries';
if ItemName = 'TK_MVTARegNames' then
ItemName := 'TK_MVTARegNames';
}
          CreateProgItem( ItemName, true, false, UDClassDescr, UDProgItem,  K_SHUsedRLData );
          UDClassDescr.ObjAliase := TypeAliase;
          UDClassDescr.FDObjType := K_fdtClass;
//*** Parse Class Aditional Info
          ParseClassAddInfo;
//*** Parse Class Fields
          K_ErrorPos := CPos;
          ItemClass := ParseTypedElementsList( false, UDClassDescr,
                                               K_SHTermTokens, K_SHUsedRLData );
          goto ParseClassMenthods;
        end else if (ItemClass = K_sccRecordDef) or
                    (ItemClass = K_sccVarRecordDef) then begin  //*** Record and Var Record
          ClassInd := K_UDFieldsDescrCI;
//*** create FieldDescr
          CreateProgItem( ItemName, true, false, UDParDescr, UDProgItem,  K_SHUsedRLData );
          ParseTypedElementsList( false, UDParDescr, K_SHTermTokens, K_SHUsedRLData );
          UDParDescr.ObjAliase := TypeAliase;
          UDParDescr.AddOneFieldDescr ( '', 0 ); // close Description
          SetTypeVerInfo( UDParDescr );
          TypeDefMode := false;
        end else if (ItemClass = K_sccProcedureDef)        or
                    (ItemClass = K_sccFunctionDef)         or
                    (ItemClass = K_sccClassConstructorDef) or
                    (ItemClass = K_sccClassDestructorDef) then begin
          K_GetDelimiter(DelChar, true);
          if ClassDefMode then begin  //*** Class Method Definition
            ParseRoutine( ItemName, false, false, UDParDescr, UDProgItem, UDClassDescr );
            ClassMethFlags.TFlags := K_ffClassMethod;
            if ItemClass = K_sccClassConstructorDef then
              UDParDescr.FDObjType := K_fdtClassConstructor;
//              ClassMethFlags.TFlags := ClassMethFlags.TFlags or K_ffClassConstructor;
            UDClassDescr.AddOneFieldDescr ( ItemName,
                                    Integer(UDProgItem), ClassMethFlags.All, 0, 0 );
          end else begin              //*** Variable Type - Routine
            ParseRoutine( ItemName, true, false, UDParDescr, UDProgItem  );
            UDParDescr.Owner := UDUnitRoot;
            UDProgItem.UDDelete;
            TypeDefMode := false;
          end;
        end else if ItemClass = K_sccSetDef then begin
          setDelimiters( K_sccDelimsSet, 5 );
          K_GetDelimiter(DelChar, true );
    //*** create FieldDescr
          ClassInd := K_UDFieldsDescrCI;
          CreateProgItem( ItemName, true, false, UDParDescr, UDProgItem,  K_SHUsedRLData );
          UDParDescr.ObjAliase := TypeAliase;
          if DelChar = K_sccStartListDelim then //*** parse Set declaration
            ParseEnumElementsList( UDParDescr, K_SHUsedRLData, K_fdtSet )
          else begin
            K_ErrorPos := CPos;
            Token := nextToken;
            EnumType := K_getTypeCode( Token );
            if EnumType.DTCode = -1 then
              K_CompilerError( 'Wrong Enum Type Name "'+Token+'"' );
            with UDParDescr do begin
              CopyFields( TN_UDBase(EnumType.DTCode) );
              ObjName := ItemName;
              ObjAliase := TypeAliase;
              K_GetDelimiter(DelChar);
              ParseEnumAndSetSize( UDParDescr, K_fdtSet );
            end;
          end;
          SetTypeVerInfo( UDParDescr );
          TypeDefMode := false;
        end else begin
          K_ParseDataType( ParTypeCode, ParTypeFlags, ParValue, ItemClass );

          K_GetDelimiter(DelChar);
          if DelChar = K_sccTypeDelim then begin
          // Parse Complex Array Elements Type
            if (ParTypeCode <= 0) or (ParTypeFlags.TFlags <> 0) then
              K_CompilerError( 'Wrong Array Attributes Type Definition' );
            K_ErrorPos := CPos;
            K_ParseDataType( ElemTypeCode, ElemTypeFlags, ParValue, '' );
            if ElemTypeFlags.TFlags <> 0 then
              K_CompilerError( 'Wrong Array Elements Type Definition' );
          end else
            ElemTypeCode := -1;

          ClassInd := K_UDFieldsDescrCI;
//*** create FieldDescr
          CreateProgItem( ItemName, true, false, UDParDescr, UDProgItem,  K_SHUsedRLData );
          UDParDescr.ObjAliase := TypeAliase;
          UDParDescr.FDObjType := K_fdtTypeDef;
          UDParDescr.AddOneFieldDescr( '#', ParTypeCode, ParTypeFlags.All, 0, -1 );
          if ElemTypeCode <> -1 then begin //Add Complex Array Elements Type Description
            UDParDescr.AddOneFieldDescr( '##', ElemTypeCode, ElemTypeFlags.All, -1, -1 );
          end;
          UDParDescr.AddOneFieldDescr ( '', 0 ); // close Description
          SetTypeVerInfo( UDParDescr );
          TypeDefMode := false;
        end;
      end
      else
      begin
//*** parse Routine
        if (ItemClass <> K_sccProcedureDef) and
           (ItemClass <> K_sccFunctionDef) and
           (ItemClass <> K_sccClassConstructorDef) and
           (ItemClass <> K_sccClassDestructorDef) then
          K_CompilerError( 'Get "'+ItemClass+'" instead of routine definition' );
        ItemName := K_ParseVarFieldNames(ItemName, FieldName );
        if FieldName <> '' then
        begin //*** Class Method
          UDClassDescr := TK_UDFieldsDescr(
                               K_ParseParamTypeCode( ItemName, ParTypeFlags ) );
          if UDClassDescr.FDObjType <> K_fdtClass then
            K_CompilerError( '"'+ItemName+'" is not class name' );
//*** Get Class Method Description
          with UDClassDescr do
            PMethodFieldDescr := GetFieldDescrByInd( IndexOfFieldDescr(FieldName) );
          if PMethodFieldDescr = nil then
            K_CompilerError( 'Undefined class "'+ItemName+'" method "'+FieldName+'"' );
          UDMethodDescr := PMethodFieldDescr.DataType.FD;

          if (UDMethodDescr.FDObjType <> K_fdtRoutine) and
             (UDMethodDescr.FDObjType <> K_fdtClassConstructor) then
            K_CompilerError( '"'+FieldName+'" is not class method' );

          ParseRoutine( FieldName, false, false, UDParDescr, UDProgItem, UDClassDescr );

//*** Compare parsed method with class definition
          if not UDMethodDescr.CompareFuncTypes( UDParDescr ) then
            K_CompilerError( 'Wrong method definition' );
//*** Free Temp Objects
          UDProgItem.UDDelete;
//*** Use Objects From Class Description
          UDParDescr := UDMethodDescr;
          UDProgItem := TN_UDBase(PMethodFieldDescr.DataPos);
        end
        else
        begin                //*** Unit Routine
          ParseRoutine( ItemName, false, true, UDParDescr, UDProgItem  );
        end;

        if (FieldName <> '') or
           (K_SHFunctions.IndexOf( ItemName ) = -1) then begin //*** Not BuildIn Routine or Class Method
       //*** Not Build in Routine or Record
{ //30.10.2006
          if UDParDescr.RecSize > 0 then // Add place for Last Param Type in Routine Type Description
            Inc( UDParDescr.RecSize, SizeOf(TK_ExprExtType) );
}

// 09.04.2007 ???         K_GetDelimiter(DelChar);
          K_GetDelimiter(DelChar, true);
          Token := nextToken(true);

          if Token = K_sccDataDef then //*** parse local Routine Data section
            Token := ParseTypedElementsList( false, UDParDescr, K_SHTermTokens, K_SHUsedRLData );

          K_SHRoutineLabels.Clear;
          if SameText( Token, K_sccLabel) then begin //*** parse Routine Labels
            while K_GetDelimiter(DelChar) and (DelChar <> K_sccFinStatementDelim) do
              K_SHRoutineLabels.Add( nextToken(true) );
            shiftPos(0);

            //*** Init Labels
            with TK_UDProgramItem(UDProgItem) do begin
              SetLength( ExprLabels, K_SHRoutineLabels.Count );
              SetLength( ExprLabelsDI, K_SHRoutineLabels.Count );
              for j := 0 to High(ExprLabels) do
                ExprLabels[j] := -1;
            end;

            Token := nextToken(true);
          end; //*** end of label section

          if not SameText( Token, K_sccStartBlock ) then
            K_CompilerError( 'Error in procedure "'+ItemName+'" - "'+K_sccStartBlock+'" is absent' );

          UDParDescr.AddOneFieldDescr ( '', 0 ); // close Description

          K_CompileRoutineBody( TK_UDProgramItem(UDProgItem)  );
        end else //*** end of SPL Routine
          UDParDescr.AddOneFieldDescr ( '', 0 ); // close Description
      end; //*** end of Parse Routine Loop
//*** parse item params definition
    end; //*** Parse Module Body Loop

//*** Init Unit Global Data
LExit:
    if UnitDataIndex > 0 then
      UDData.SPLInit( TK_UDFieldsDescr( UDData.DirChild(0) ) );

    // Move UnitData to the End of Unit Dir
    with UDUnitRoot do
      MoveEntries( DirHigh - 1, 0, 2 );

end;
//*** end of K_CompileUnitBody ***

//************************************************ K_CompileUnit ***
//  Parse
//
function  K_CompileUnit( ModuleText : string; var UDUnitRoot : TK_UDUnit;
                         Recompile : Boolean = false;
                         SkipUDChangedFlagForNotCompiled : Boolean = false;
                         LocalUnitAliase : string = '' ) : Boolean;
var
  Token : string;
  PrevTokenizer : TK_Tokenizer;
  PrevRoutinesList : THashedStringList;
  PrevEnumList, PrevDataList : THashedStringList;
  PrevGlobalData : TList;
  DelChar : Char;
  UnitName : string;
  RowNum, RowSize, RowStart, ErrLength : Integer;
  CompiledUnitFlag : Boolean;
  ClearUDChangedFlag : Boolean;
  NewUnitTextFlag : Boolean;

  procedure RestoreContext;
  begin
    K_ST.Free;
    K_ST := PrevTokenizer;

    K_SHEnumMembersList.Free;
    K_SHEnumMembersList := PrevEnumList;

    K_SHDataTypesList.Free;
    K_SHDataTypesList := PrevDataList;

    K_SHProgItemsList.Free;
    K_SHProgItemsList := PrevRoutinesList;

    K_LGlobalData.free;
    K_LGlobalData := PrevGlobalData;
  end;

  procedure InitExistedUnit;
  begin
    CompiledUnitFlag := UDUnitRoot.DirLength <> 0;
    if CompiledUnitFlag and not Recompile then Exit; // already Compiled - return
    NewUnitTextFlag := ModuleText <> '';
    ClearUDChangedFlag := ((UDUnitRoot.ClassFlags and K_ChangedSubTreeBit) = 0)      and // UDUnit is not changed
                          (not NewUnitTextFlag or (ModuleText = UDUnitRoot.SL.Text)) and // New Unit text is Same
                          (CompiledUnitFlag or SkipUDChangedFlagForNotCompiled);       // Unit was already compiled
    if NewUnitTextFlag then
      UDUnitRoot.SL.Text := ModuleText
    else
      ModuleText := UDUnitRoot.SL.Text;
    if ClearUDChangedFlag then
      UDUnitRoot.ClassFlags := UDUnitRoot.ClassFlags or K_ChangedSubTreeBit;
  end;

begin
  Result := true;
  CompiledUnitFlag := UDUnitRoot.DirLength <> 0;
  ClearUDChangedFlag := false;
  if UDUnitRoot <> nil then InitExistedUnit;

//*** Save Compiler Unit Context
  PrevTokenizer := K_ST;
  K_ST := K_ST.Clone;
  K_ST.setSource( ModuleText );

  K_ST.setDelimiters( K_sccUnitDelimsSet, 5 );
  K_ST.setBrackets( K_sccTokenBrackets, 5 );

  PrevEnumList := K_SHEnumMembersList;
  K_SHEnumMembersList := THashedStringList.Create;
  K_SHEnumMembersList.CaseSensitive := false;

  PrevDataList := K_SHDataTypesList;
  K_SHDataTypesList := THashedStringList.Create;
  K_SHDataTypesList.CaseSensitive := false;
  K_SHDataTypesList.Assign(K_SHBaseTypesList);

  PrevRoutinesList := K_SHProgItemsList;
  K_SHProgItemsList := THashedStringList.Create;
  K_SHProgItemsList.CaseSensitive := false;
  K_SHProgItemsList.Assign(K_SHBaseTypesList);

  PrevGlobalData := K_LGlobalData;
  K_LGlobalData := TList.Create;
  K_TypeAliase := '';
  K_SysComment := '';

  try
  //*** parse "unit"
    K_GetDelimiter(DelChar);
    K_ErrorPos := K_ST.CPos;
    UnitName := 'Undefined';
    if LowerCase(K_ST.nextToken) <> K_sccModuleDef then // unit header error
      K_CompilerError( '"unit" statement is absent' );
    UnitName := K_ST.nextToken( true );

    if UDUnitRoot = nil then begin // create Modul Root
      if Pos( K_sccUnitLocalNameChar, UnitName ) = 0 then begin
        if Pos( K_udpObjTypeNameDelim, UnitName ) = 0 then
          Token := UnitName + K_udpObjTypeNameDelim+N_ClassTagArray[K_UDUnitCI];
        if Pos( K_udpCursorDelim, UnitName ) = 0 then Token := K_UnitsRoot + Token;
     // Check if UDUnitRoot Exists
        UDUnitRoot := TK_UDUnit( K_UDCursorGetObj(Token) );
        if UDUnitRoot <> nil then
          InitExistedUnit
        else
          UDUnitRoot := TK_UDUnit( K_UDCursorForceDir( Token ) );
      end else begin
        UDUnitRoot := TK_UDUnit( N_ClassRefArray[K_UDUnitCI].Create );
        UDUnitRoot.ObjName := Copy( UnitName, 2, Length(UnitName) );
        UDUnitRoot.ObjAliase := LocalUnitAliase;
      end;
      UDUnitRoot.SL.Text := ModuleText;
    end;

    if UDUnitRoot.ObjAliase = '' then
      UDUnitRoot.ObjAliase := UnitName;

    if CompiledUnitFlag then begin // Recompile Unit
      if Recompile then
        UDUnitRoot.ClearChilds
      else
        K_CompilerError( 'Unit "'+Token+'" already exists' );
    end;
    K_SetChangeSubTreeFlags( UDUnitRoot );

    K_GetDelimiter( DelChar, true );
    K_ErrorPos := K_ST.CPos;
    while SameText( K_ST.nextToken(true), K_sccUsesDef ) do  begin
  //*** parse "uses"
      if not K_ParseUses then
        K_CompilerError( 'Unit "'+Token+'" couldn''t be compiled because of errors in used units' );
      K_ErrorPos := K_ST.CPos;
    end;
    K_ST.setPos( K_ErrorPos );

//*** Start Unit Body Compilation
    K_ST.setDelimiters( K_sccDelimsSet, 5 );
    K_CompileUnitBody( UDUnitRoot, Recompile );
    UDUnitRoot.CompilerErrMessage := '';
  except
    On E: TK_CompilerError do
    begin
//      with K_GetFormMVDeb do begin
      if UDUnitRoot <> nil then begin
        RowNum := K_CalcTextLineNumberFromPos( RowStart, RowSize,
                                               UDUnitRoot.SL.Text, K_ErrorPos );
        UnitName := UDUnitRoot.ObjName;
      end else begin
        RowNum := 0;
        RowStart := 0;
        RowSize := 0;
      end;

      if K_ErrorLength < 0 then
        ErrLength := RowSize
      else
        ErrLength := K_ErrorLength;

      K_GetFormMVDeb.ShowErrorInfo( UDUnitRoot, UnitName, E.Message, K_ErrorPos,
                        ErrLength, RowNum, K_ErrorPos - RowStart );
      Result := false;
      UDUnitRoot.CompilerErrMessage := E.Message;
    end;
  end;
  //*** Restore Compiler previous Unit Context
  RestoreContext;
  if ClearUDChangedFlag then
    UDUnitRoot.ClassFlags := UDUnitRoot.ClassFlags and not K_ChangedSubTreeBit;

end;
//**** end of K_CompileUnit ***

//************************************************ K_CompileGUnit ***
//  Compile Unit Global Start
//
function K_CompileGUnit( Text : string; Recompile : Boolean = false  ) : Boolean;
var
  UDUnit : TK_UDUnit;
begin
  UDUnit := nil;
  Result := K_CompileUnit( Text, UDUnit, Recompile );
  if UDUnit.RefCounter = 0 then UDUnit.UDDelete;
end; //**** end of K_CompileGUnit ***

//************************************************ K_CompileFileUnit ***
//  Compile Unit from file
//
function K_CompileFileUnit( const FileName : string;
                            Recompile : Boolean = false ) : Boolean;
var
  UDUnit : TK_UDUnit;
begin
  Result := K_CompileScriptFile( FileName, UDUnit, Recompile, false ) = 1;
  if Result and (UDUnit.RefCounter = 0) then UDUnit.UDDelete;
end; //**** end of K_CompileFileUnit ***

//************************************************ K_CompileScriptFile ***
//  Compile Script file
//  returns -1 - file is absent, - 0 - compiler errors, 1 - unit was compiled, 2 - unit is ready
//
function K_CompileScriptFile( const FileName : string; var UDUnit : TK_UDUnit;
                              Recompile : Boolean = true; CheckScriptUnit : Boolean = true ) : Integer;
var
  TS : TStringList;
  VFile: TK_VFile;
  UnitText : string;
  FFileAge : TDateTime;
begin
  Result := -1;
  if FileName = '' then Exit;
  K_VFAssignByPath( VFile, FileName );
  if not K_VFileExists0( VFile ) then Exit;

  Result := 2;
  FFileAge := K_VFileAge0( VFile );
  if (UDUnit = nil)                 or
     (UDUnit.DirLength = 0)         or
     (UDUnit.ObjAliase <> FileName) or
     (UDUnit.ObjDateTime < FFileAge) then
  begin
    Result := 0;
    if not K_VFLoadText0( UnitText, VFile ) then Exit;
    TS := TStringList.Create;
    TS.Text := UnitText;
    if CheckScriptUnit and not K_StrStartsWith( 'unit', TS[0], true ) then
      TS.Insert(0, 'unit #');
    if (UDUnit <> nil) and (UDUnit.RefCounter = 0) then FreeAndNil(UDUnit);

    if not K_CompileUnit( TS.Text, UDUnit, Recompile ) then
    begin
      if (UDUnit.RefCounter = 0) then FreeAndNil(UDUnit);
    end
    else
    begin
      Result := 1;
      UDUnit.ObjAliase := FileName;
      UDUnit.ObjDateTime := FFileAge;
    end;
    TS.Free;
  end;

end; //**** end of K_CompileScriptFile

//************************************************ K_RunScript
//  Run Script
//  returns -3 - runtime error, -2 - script is absent, -1 - compile errors, 0 - file is absent, 1 - script is finished
//
function  K_RunScript( const FileName, ScriptName : string; ShowDump : Boolean = false;
                       GC : TK_CSPLCont = nil  ) : Integer;
var
  UDUnit : TK_UDUnit;
  UDPI : TK_UDProgramItem;
begin
  UDUnit := nil;
  Result := K_CompileScriptFile( FileName, UDUnit );
  if Result <= 0 then Exit;

  if ScriptName <> '' then
    UDPI := TK_UDProgramItem( UDUnit.DirChildByObjName(ScriptName) )
  else
    UDPI := TK_UDProgramItem( UDUnit.DirChild( UDUnit.DirHigh ) );
  Result := K_RunScriptPI( UDPI, ShowDump, GC );
  if Result <= 0 then
    Result := Result - 2;

  if UDUnit.RefCounter = 0 then UDUnit.UDDelete;

end; //**** end of K_RunScript

//************************************************ K_RunScriptPI
//  Run Script Program Item
//  returns -1 - runtime error, 0 - script is absent, 1 - script is done
//
function K_RunScriptPI( UDPI : TK_UDProgramItem; ShowDump : Boolean = false;
                        GC : TK_CSPLCont = nil ) : Integer;
var
  SaveCursor : TCursor;
  WatchBufferLength : Integer;
begin
  Result := 0;
  if (UDPI = nil)                                     or
     ((UDPI.ClassFlags and $FF) <> K_UDProgramItemCI) or
     (UDPI.ParamsCount <> 0) then Exit;

  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  if K_InfoWatch.WatchMax = 0 then begin
    WatchBufferLength := 200;
    K_InfoWatch.WatchMax := 200;
  end else
    WatchBufferLength := 0;

  Result := 1;

  try
    UDPI.CallSPLRoutine([], GC);
  except
    Result := -1;
  end;
  Screen.Cursor := SaveCursor;

  if WatchBufferLength > 0 then
    K_InfoWatch.WatchMax := 0;

end; //**** end of K_RunScriptPI

//************************************************ K_GetUDProgramItem ***
//  Parse
//
function  K_GetUDProgramItem( const ProgramPath : string  ) : TK_UDProgramItem;
var
  Cursor : TK_UDCursor;
  DE : TN_DirEntryPar;
  UDUnit : TK_UDUnit;
  Ind : Integer;

begin
  Cursor := K_UDCursorGet( ProgramPath );
  Result := TK_UDProgramItem( Cursor.GetObj );
  if Result <> nil then Exit; // ProgramItem exists
//*** create path new path object
  if Cursor.PathDoneLevel >= 0 then begin
    UDUnit := TK_UDUnit(Cursor.Stack[Cursor.PathDoneLevel].Child);
    if (UDUnit.ClassFlags and $FF) <> K_UDUnitCI then Exit;
    try
      K_CompileUnit( '',  UDUnit  );
      Ind := UDUnit.GetDEByRPath( Cursor.ErrPath, DE );
      if Ind < 0 then Exit;
      Result := TK_UDProgramItem( DE.Child );
    except
{
      On E: TK_CompilerError do
      begin
        K_SLErrors.Add( E.Message );
        Exit;
      end;
}
    end;
  end;
end; //**** end of K_GetUDProgramItem ***

end.

