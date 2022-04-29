unit N_SPLF;
// Internal SPL N_... functions

interface
uses K_Script1;

procedure N_SPLFDeb1           ( AKGC: TK_CSPLCont );
procedure N_SPLFDeb2           ( AKGC: TK_CSPLCont );
procedure N_SPLFAddStrToFile   ( AKGC: TK_CSPLCont );
procedure N_SPLFAddPDCounter   ( AKGC: TK_CSPLCont );
procedure N_SPLFUDFPStat       ( AKGC: TK_CSPLCont );
procedure N_SPLFUDFPDyn        ( AKGC: TK_CSPLCont );
procedure N_SPLFSclon          ( AKGC: TK_CSPLCont );
procedure N_SPLFCSItemKeyPDyn  ( AKGC: TK_CSPLCont );
procedure N_SPLFExecComp       ( AKGC: TK_CSPLCont );
procedure N_SPLFSampleText     ( AKGC: TK_CSPLCont );
procedure N_SPLFDateTimeToStr  ( AKGC: TK_CSPLCont );
procedure N_SPLFGetGCVar       ( AKGC: TK_CSPLCont );
procedure N_SPLFSetGCVar       ( AKGC: TK_CSPLCont );

procedure N_SPLFGetDblRow      ( AKGC: TK_CSPLCont );
  // procedure N_SPLFGetDblCol      ( AKGC: TK_CSPLCont );
  // procedure N_SPLFGetStrRow      ( AKGC: TK_CSPLCont );
  // procedure N_SPLFGetStrCol      ( AKGC: TK_CSPLCont );
  // procedure N_SPLFGetDblMatr     ( AKGC: TK_CSPLCont );

  //************ Word documents procedures and functions
procedure N_SPLFWSInfoToStr       ( AKGC: TK_CSPLCont );
procedure N_SPLFSetGCMDBm         ( AKGC: TK_CSPLCont );
procedure N_SPLFGetWordVar        ( AKGC: TK_CSPLCont );
procedure N_SPLFCreateWordVar     ( AKGC: TK_CSPLCont );
procedure N_SPLFSetWordVar        ( AKGC: TK_CSPLCont );
procedure N_SPLFRunWMacro         ( AKGC: TK_CSPLCont );
procedure N_SPLFSetWMainDocIP     ( AKGC: TK_CSPLCont );
procedure N_SPLFSetCurWTable      ( AKGC: TK_CSPLCont );
procedure N_SPLFInsWTableRows     ( AKGC: TK_CSPLCont );
  // procedure N_SPLFInsWTableCols     ( AKGC: TK_CSPLCont );
procedure N_SPLFSetWTableStrCell  ( AKGC: TK_CSPLCont );
procedure N_SPLFSetWTableValCell  ( AKGC: TK_CSPLCont );
procedure N_SPLFSetWTableCompCell ( AKGC: TK_CSPLCont );
procedure N_SPLFSetWTableStrRow   ( AKGC: TK_CSPLCont );
  // procedure N_SPLFSetWTableValRow   ( AKGC: TK_CSPLCont );
  // procedure N_SPLFSetWTableCompRow  ( AKGC: TK_CSPLCont );
  // procedure N_SPLFSetWTableStrCol   ( AKGC: TK_CSPLCont );
  // procedure N_SPLFSetWTableValCol   ( AKGC: TK_CSPLCont );
  // procedure N_SPLFSetWTableCompCol  ( AKGC: TK_CSPLCont );
  // procedure N_SPLFSetWTableStrMatr  ( AKGC: TK_CSPLCont );
  // procedure N_SPLFSetWTableValMatr  ( AKGC: TK_CSPLCont );
  // procedure N_SPLFSetWTableCompMatr ( AKGC: TK_CSPLCont );
procedure N_SPLFSetFirstPageNum   ( AKGC: TK_CSPLCont );

  //************ ESheet procedures and functions
procedure N_SPLFECN               ( AKGC: TK_CSPLCont );
procedure N_SPLFSetCurESheet      ( AKGC: TK_CSPLCont );
procedure N_SPLFInsESheetRows     ( AKGC: TK_CSPLCont );
procedure N_SPLFSetESheetStrCell  ( AKGC: TK_CSPLCont );
procedure N_SPLFSetESheetDblCell  ( AKGC: TK_CSPLCont );
procedure N_SPLFSetESheetCompCell ( AKGC: TK_CSPLCont );
procedure N_SPLFSetESheetStrRow   ( AKGC: TK_CSPLCont );
procedure N_SPLFSetESheetStrCol   ( AKGC: TK_CSPLCont );
procedure N_SPLFSetESheetDblRow   ( AKGC: TK_CSPLCont );
procedure N_SPLFSetESheetDblCol   ( AKGC: TK_CSPLCont );
procedure N_SPLFSetESheetDblMatr  ( AKGC: TK_CSPLCont );


implementation
uses Classes, SysUtils, Variants, Clipbrd,
  K_CLib0, K_CLib, K_UDT1, K_DCSpace,
  N_Types, N_Lib0, N_Lib1, N_Lib2, N_CompCL, N_GCont, N_CompBase, N_ME1;

//************************************************************** N_SPLFDeb1 ***
// SPL function Deb1( AInt1: integer; AStr1: string ): string;
//
// Debug Function # 1 with Int and String params
//
procedure N_SPLFDeb1( AKGC: TK_CSPLCont );
type  Params = packed record
  AInt1:  integer;
  DType1: TK_ExprExtType;
  AStr1:  string;
  DType2: TK_ExprExtType;
end;
var
  PP: ^Params;
  ResStr: string;
  s, hf, bm: variant;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    ResStr := '';

    s := GCWSMainDoc.Sections.Item( 1 );
    hf := s.Headers.Item( wdHeaderFooterPrimary );
    N_s := hf.Range.Text;
    bm := GCWSMainDoc.Bookmarks.Item( 'P1' );
    bm.Range.Copy;
    hf.Range.Paste;
//    hf.Range.Text := 'LeftStr'#9'Center'#9'Right';
    N_s := hf.Range.Text;

    AStr1 := ''; // Free fields on SPL Stack
    AKGC.PutDataToExprStack( ResStr, Ord(nptString) );
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
end; //*** end of  procedure N_SPLFDeb1

//************************************************************** N_SPLFDeb2 ***
// SPL function Deb2( AInt1: integer; AStr1: string ): string;
//
// Debug Function # 2 with Int and String params
//
procedure N_SPLFDeb2( AKGC: TK_CSPLCont );
type  Params = packed record
  AInt1:  integer;
  DType1: TK_ExprExtType;
  AStr1:  string;
  DType2: TK_ExprExtType;
end;
var
  PP: ^Params;
  ResStr: string;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    ResStr := '';

    N_s1 := GCCurESheet.ChartObjects(1).Chart.Name;
    N_s2 := GCCurESheet.ChartObjects(2).Chart.Name;

    AStr1 := ''; // Free fields on SPL Stack
    AKGC.PutDataToExprStack( ResStr, Ord(nptString) );
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
end; //*** end of  procedure N_SPLFDeb2

//******************************************************* N_SPLAddStrToFile ***
// SPL procedure AddStrToFile( AFName: string; AStr: string );
//
// Add given AStr to File AFName
//
procedure N_SPLFAddStrToFile( AKGC: TK_CSPLCont );
type  Params = packed record
  AFName: string;
  DType1: TK_ExprExtType;
  AStr:   string;
  DType2: TK_ExprExtType;
end;
var
  PP: ^Params;
  FullFName: string;
  FStream: TFileStream;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );

  with PP^ do
  begin
    FullFName := K_ExpandFileName( AFName );

    if FileExists(FullFName) then
    begin
      FStream := TFileStream.Create( FullFName, fmOpenReadWrite );
      FStream.Seek( 0, soFromEnd);
    end else
      FStream := TFileStream.Create( FullFName, fmCreate );

    if Length(AStr) > 0 then FStream.Write( AStr[1], Length(AStr) );
    FStream.Write( N_IntCRLF, 2*SizeOf(Char) );
    FStream.Free;

    AFName := ''; // Free fields on SPL Stack
    AStr   := ''; // Free fields on SPL Stack
  end; // with PP^ do
end; //*** end of  procedure N_SPLFAddStrToFile

//****************************************************** N_SPLFAddPDCounter ***
// SPL function AddPDCounter( AStr: string ): string;
//
// Add to given AStr numerical postfix - IntToStr(GCPDCounter)
//
procedure N_SPLFAddPDCounter( AKGC: TK_CSPLCont );
type  Params = packed record
  AStr:  string;
  DType1: TK_ExprExtType;
end;
var
  PP: ^Params;
  ResStr: string;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    ResStr := AddPDCounter( AStr );
    AStr := ''; // Free fields on SPL Stack
    AKGC.PutDataToExprStack( ResStr, Ord(nptString) );
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
end; //*** end of  procedure N_SPLFAddPDCounter

//********************************************************** N_SPLFUDFPStat ***
// SPL function UDFPDyn( AUDComp: TN_UDBase; AFieldPath: string ): ^Undef;
//
// Get Pointer to Given Field in given Component Dynamic Params
//
procedure N_SPLFUDFPStat( AKGC: TK_CSPLCont );
type  Params = packed record
  AUDComp: TN_UDBase;
  DType1:  TK_ExprExtType;
  AFieldPath: string;
  DType2:     TK_ExprExtType;
end;
var
  PP: ^Params;
  PField: Pointer;
  FTCode: TK_ExprExtType;
  ErrPos: integer;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
  begin
//    N_s := AUDComp.ObjName; // for debug
    if not (AUDComp is TN_UDCompBase) then
      raise TK_SPLRunTimeError.Create( 'UDFPStat error: '+ AUDComp.ObjName +
                                       ' is not a Component!' );
    with TN_UDCompBase(AUDComp) do
    begin
      PField := nil;
      ErrPos := N_GetRAFieldInfo( R, AFieldPath, FTCode, PField );
    end; // with TN_UDCompBase(AUDComp) do

    if PField = nil then
      K_DataPathError( 'UDFPStat Path error: ', AFieldPath, ErrPos );

    AFieldPath := ''; // Free fields on SPL Stack

    Inc( FTCode.D.TFlags, K_ffPointer );
    AKGC.PutDataToExprStack( PField, FTCode.All );

  end; // with PP^ do
end; //*** end of  procedure N_SPLFUDFPStat

//*********************************************************** N_SPLFUDFPDyn ***
// SPL function UDFPDyn( AUDComp: TN_UDBase; AFieldPath: string ): ^Undef;
//
// Get Pointer to Given Field in given Component Dynamic Params
// if no Dynamic Params, Static Params are used
//
procedure N_SPLFUDFPDyn( AKGC: TK_CSPLCont );
type  Params = packed record
  AUDComp: TN_UDBase;
  DType1:  TK_ExprExtType;
  AFieldPath: string;
  DType2:     TK_ExprExtType;
end;
var
  PP: ^Params;
  PField: Pointer;
  FTCode: TK_ExprExtType;
  ErrPos: integer;
  CurPar: TK_RArray;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
  begin
//    N_s := AUDComp.ObjName; // for debug
    if not (AUDComp is TN_UDCompBase) then
      raise TK_SPLRunTimeError.Create( 'UDFPDyn error: '+ AUDComp.ObjName +
                                       ' is not a Component!' );
    with TN_UDCompBase(AUDComp) do
    begin
      CurPar := DynPar;
      if CurPar = nil then CurPar := R;
//        raise TK_SPLRunTimeError.Create( 'UDFPDyn error: DynPar is nil in '+ AUDComp.GetUName );

      PField := nil;
      ErrPos := N_GetRAFieldInfo( CurPar, AFieldPath, FTCode, PField );
    end; // with TN_UDCompBase(AUDComp) do

    if PField = nil then
      K_DataPathError( 'UDFPDyn Path error: ', AFieldPath, ErrPos );

    AFieldPath := ''; // Free fields on SPL Stack

    Inc( FTCode.D.TFlags, K_ffPointer );
    AKGC.PutDataToExprStack( PField, FTCode.All );

  end; // with PP^ do
end; //*** end of  procedure N_SPLFUDFPDyn

//************************************************************* N_SPLFSclon ***
// SPL function —ÍÎÓÌ( AKey12: string; ACaseStr: string ): string;
//
// Return Token variant (specified by ACaseStr) from Sclon Table row
// with AKey12 = AKey1+AKey2
// —ÍÀÓÌ
//
procedure N_SPLFSclon( AKGC: TK_CSPLCont );
type  Params = packed record
  AKey12:   string;
  DType1:    TK_ExprExtType;
  ACaseStr: string;
  DType3:    TK_ExprExtType;
end;
var
  PP : ^Params;
  CaseInd: Integer;
  ResStr: string;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
  begin
    CaseInd := -1;
         if ACaseStr = '–Ó‰' then CaseInd := 0
    else if ACaseStr = '»œ'  then CaseInd := 1
    else if ACaseStr = '–œ'  then CaseInd := 2
    else if ACaseStr = 'ƒœ'  then CaseInd := 3
    else if ACaseStr = '¬œ'  then CaseInd := 4
    else if ACaseStr = '“œ'  then CaseInd := 5
    else if ACaseStr = 'œœ'  then CaseInd := 6;

    ResStr := N_MEGlobObj.GetSclonedToken( AKey12, CaseInd );

    AKey12   := ''; // Free fields on SPL Stack
    ACaseStr := '';

    AKGC.PutDataToExprStack( ResStr, Ord(nptString) );

  end; // with PP^ do
end; //*** end of  procedure N_SPLFSclon

//***************************************************** N_SPLFCSItemKeyPDyn ***
// SPL function CSItemKeyPDyn( AUDComp: TN_UDBase; ACSItemPath: string ): ^String;
//
// Get Pointer to ItemKey string by Given path to CSItem Field in given Component Dynamic Params
//
procedure N_SPLFCSItemKeyPDyn( AKGC: TK_CSPLCont );
type  Params = packed record
  AUDComp: TN_UDBase;
  DType1:    TK_ExprExtType;
  ACSItemPath: string;
  DType2:    TK_ExprExtType;
end;
var
  PP : ^Params;
  PField: Pointer;
  FTCode: TK_ExprExtType;
  Ind, ErrPos: integer;
  PCSItemKey: PString;
  CurPar: TK_RArray;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
  begin
//    N_s := AUDComp.ObjName; // for debug
    if not (AUDComp is TN_UDCompBase) then
      raise TK_SPLRunTimeError.Create( 'CSItemKeyPDyn error: '+ AUDComp.ObjName +
                                       ' is not a Component!' );
    with TN_UDCompBase(AUDComp) do
    begin
      CurPar := DynPar;
      if CurPar = nil then CurPar := R;
//        raise TK_SPLRunTimeError.Create( 'CSItemKeyPDyn error: DynPar is nil in '+ AUDComp.GetUName );

      PField := nil;
      ErrPos := N_GetRAFieldInfo( CurPar, ACSItemPath, FTCode, PField );
    end; // with TN_UDCompBase(AUDComp) do

    if PField = nil then
      K_DataPathError( 'CSItemKeyPDyn Path error: ', ACSItemPath, ErrPos );

    if 'TN_CodeSpaceItem' <> K_GetExecTypeName( FTCode.All ) then
      K_DataPathError( 'CSItemKeyPDyn error: Not a CSItem!', ACSItemPath, ErrPos );

    ACSItemPath := ''; // Free fields on SPL Stack

    with TN_PCodeSpaceItem(PField)^ do
    begin
      Ind := ItemCS.IndexByCode( ItemCode );
      PCSItemKey := ItemCS.GetItemInfoPtr( K_csiSclonKey, Ind );
    end; // with TN_PCodeSpaceItem(PField)^ do

    FTCode := K_GetTypeCode( 'string' );
    Inc( FTCode.D.TFlags, K_ffPointer );
    AKGC.PutDataToExprStack( PCSItemKey, FTCode.All );

  end; // with PP^ do
end; //*** end of  procedure N_SPLFCSItemKeyPDyn

//********************************************************** N_SPLFExecComp ***
// SPL function ExecComp( AUDComp: TN_UDBase ): Integer;
//
// Execute given Component AUDComp and return integer ResultCode
//
procedure N_SPLFExecComp( AKGC: TK_CSPLCont );
type  Params = packed record
  AUDComp: TN_UDBase;
  DType1:  TK_ExprExtType;
end;
var
  PP: ^Params;
  ResultCode: integer;
  NewGCont: TN_GlobCont;
  CurSPLComp: TN_UDCompBase;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
  begin
    CurSPLComp := nil;
    if AKGC is TN_NKGlobCont then
    begin
      N_s := TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).ObjName; // for debug
      CurSPLComp := TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp);
    end;

    if not (AUDComp is TN_UDCompBase) then
      raise TK_SPLRunTimeError.Create( 'ExecComp error: '+ AUDComp.ObjName +
                                       ' is not a Component!' );
    N_s := AUDComp.ObjName; // for debug

    TN_UDCompBase(AUDComp).DynParent := CurSPLComp;

    NewGCont := TN_GlobCont.Create;
    NewGCont.ExecuteRootComp( AUDComp, [] );
    NewGCont.Free;

    ResultCode := 0; // temporary
    AKGC.PutDataToExprStack( ResultCode, Ord(nptInt) );

  end; // with PP^ do
end; //*** end of  procedure N_SPLFExecComp

//******************************************************** N_SPLFSampleText ***
// SPL function SampleText( APrefix: string; ANum: integer; ALeng: integer ): string;
//
// Generate and return sample Text by N_GetSampleRusText function with same params
//
procedure N_SPLFSampleText( AKGC: TK_CSPLCont );
type  Params = packed record
  APrefix: string;
  DType1:  TK_ExprExtType;
  ANum:   integer;
  DType2: TK_ExprExtType;
  ALeng:  integer;
  DType3: TK_ExprExtType;
end;
var
  PP : ^Params;
  ResultStr: string;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
  begin
    ResultStr := N_GetSampleRusText( APrefix, ANum, ALeng );
    APrefix := ''; // Free fields on SPL Stack
    AKGC.PutDataToExprStack( ResultStr, Ord(nptString) );
  end; // with PP^ do
end; //*** end of  procedure N_SPLFSampleText

//***************************************************** N_SPLFDateTimeToStr ***
// SPL function DateTimeToStr( ADateTime: Double; AFormat: string ): string;
//
// Convert given ADateTime (of TDateTime=double type) value to string using given AFormat
// ADateTime = 0 means current Date+Time
// AFormat = '' means full Date + Time
//
procedure N_SPLFDateTimeToStr( AKGC: TK_CSPLCont );
type  Params = packed record
  ADateTime: Double;
  DType1:    TK_ExprExtType;
  AFormat: string;
  DType2:  TK_ExprExtType;
end;
var
  PP: ^Params;
  ResultStr: string;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
  begin
    if Double(ADateTime) = 0 then ADateTime := Now();
    if AFormat = '' then AFormat := N_DefDTimeFmt;
    DateTimeToString( ResultStr, AFormat, ADateTime, N_WinFormatSettings );
    AFormat := ''; // Free fields on SPL Stack
    AKGC.PutDataToExprStack( ResultStr, Ord(nptString) );
  end; // with PP^ do
end; //*** end of  procedure N_SPLFDateTimeToStr

//********************************************************** N_SPLFSetGCVar ***
// SPL procedure SetGCVar( AVarName: string; AVarContent: string );
//
// Set GC String Variable with given AVarName by given string AVarContent
//
procedure N_SPLFSetGCVar( AKGC: TK_CSPLCont );
type  Params = packed record
  AVarName: string;
  DType1:   TK_ExprExtType;
  AVarContent: string;
  DType2:      TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    GCSetStrVar( AVarName, AVarContent );
    AVarName    := ''; // Free fields on SPL Stack
    AVarContent := ''; // Free fields on SPL Stack
  end; // with PP^ do
end; //*** end of  procedure N_SPLFSetGCVar

//********************************************************** N_SPLFGetGCVar ***
// SPL function GetGCVar( AVarName: string ): string;
//
// Return content of GC String Variable with given AVarName
//
procedure N_SPLFGetGCVar( AKGC: TK_CSPLCont );
type  Params = packed record
  AVarName: string;
  DType1:   TK_ExprExtType;
end;
var
  PP : ^Params;
  ResultStr: string;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    ResultStr := GCGetStrVar( AVarName );
    AVarName := ''; // Free fields on SPL Stack
    AKGC.PutDataToExprStack( ResultStr, Ord(nptString) );
  end; // with PP^ do
end; //*** end of  procedure N_SPLFGetGCVar

//********************************************************* N_SPLFGetDblRow ***
// SPL function GetDblRow( AMatr: arrayOf Undef; ARowInd: integer ): arrayOf Double;
//
// Convert one Row with given ARowInd index of numerical 2D RArray to
// vector of double ( ARowInd >= 0 )
//
procedure N_SPLFGetDblRow( AKGC: TK_CSPLCont );
type  Params = packed record
  AMatr:   TK_RArray;
  DType1:  TK_ExprExtType;
  ARowInd: integer;
  DType2:  TK_ExprExtType;
end;
var
  PP: ^Params;
  i, ind, NumCols, NumRows, MatrIntType: integer;
  Val: double;
  ResRArray: TK_RArray;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
  begin
    MatrIntType := AMatr.ElemSType;
    AMatr.ALength( NumCols, NumRows );
    ResRArray := K_RCreateByTypeCode( Ord(nptDouble), NumCols );

    for i := 0 to NumCols-1 do
    begin
      ind := ARowInd*NumCols + i;

      case MatrIntType of
        Ord(nptInt):    Val := PInteger(AMatr.P(ind))^;
        Ord(nptFloat):  Val := PFloat(AMatr.P(ind))^;
        Ord(nptDouble): Val := PDouble(AMatr.P(ind))^;
      else
        Val := 0;
      end; // case MatrIntType of

      PDouble(ResRArray.P(i))^ := Val;
    end; // for i := 0 to NumCols-1 do

    AMatr.ARelease; // Free fields on SPL Stack
    AKGC.PutDataToExprStack( ResRArray, ResRArray.ArrayType.All );
  end; // with PP^ do
end; //*** end of  procedure N_SPLFGetDblRow

{
//************************************************************ N_SPLFSetDim ***
// SPL procedure SetDim( AArray: ArrayOf Undef; ANumRows: integer; ANumCols: integer );
//
// Set Dimensions of given AArray
//
procedure N_SPLFSetDim( AKGC: TK_CSPLCont );
type  Params = packed record
  AArray: TK_RArray;
  DType1:  TK_ExprExtType;
  ANumRows: integer;
  DType2:  TK_ExprExtType;
  ANumCols: integer;
  DType3:  TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
  begin
    if AArray

  end; // with PP^ do
end; //*** end of  procedure N_SPLFSetDim
}

//******************************************************* N_SPLFWSInfoToStr ***
// SPL function WSInfoToStr( AMode: integer ): string; (Word Server Info)
//
// Return CurTime, Word version and two digits VBA Flags X2 X1:
//                                             X2=GCWSVBAFlags, X1=GCWSPSMode
// AMode temporary not used
//
procedure N_SPLFWSInfoToStr( AKGC: TK_CSPLCont );
type  Params = packed record
  AMode: integer;
  DType1:    TK_ExprExtType;
end;
var
  PP: ^Params;
  ResultStr: string;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont  do
  begin
    DateTimeToString( ResultStr, N_DefDTimeFmt, Date+Time, N_WinFormatSettings );
//    GetWSInfo( AMode );
    N_i := AMode; // to avoid warning
    GetWSInfo( 0 );
    ResultStr := ResultStr + N_InfoSL[0];
    AKGC.PutDataToExprStack( ResultStr, Ord(nptString) );
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont  do
end; //*** end of  procedure N_SPLFWSInfoToStr

//********************************************************* N_SPLFSetGCMDBm ***
// SPL procedure SetGCMDBm( ABookmarkName: string; AWhere: TN_WordInsBmkWhere;
//                                                 AWhat: TN_WordInsBmkWhat );
// Set GCBmName, GCBmWhere, GCBmWhat GlobCont variables by given values
//
procedure N_SPLFSetGCMDBm( AKGC: TK_CSPLCont );
type  Params = packed record
  ABookmarkName: string;
  DType1:   TK_ExprExtType;
//  AWhere: TN_WordInsBmkWhere;
//  DType2:   TK_ExprExtType;
//  AWhat:  TN_WordInsBmkWhat;
//  DType3:   TK_ExprExtType;
end;
var
  PP: ^Params;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  N_p := PP; // to avoid arning
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
//    GCBmName2  := ABookmarkName;
//    GCBmWhere := AWhere;
//    GCBmWhat  := AWhat;
//    GCBmWhere2 := wibwhereEnd1;
//    GCBmWhat2  := wibWhatClipboard;
//    ABookmarkName := ''; // Free fields on SPL Stack
  end; // with PP^ do
end; //*** end of  procedure N_SPLFSetGCMDBm

//******************************************************** N_SPLFGetWordVar ***
// SPL function GetWordVar( AVarName: string ): string;
//
// Return content of Word GCWSMainDoc Variable with given AVarName
//
procedure N_SPLFGetWordVar( AKGC: TK_CSPLCont );
type  Params = packed record
  AVarName: string;
  DType1:   TK_ExprExtType;
end;
var
  PP : ^Params;
  ResultStr: string;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    ResultStr := GCWSMainDoc.Variables( AVarName ).Value;
    AVarName := ''; // Free fields on SPL Stack
    AKGC.PutDataToExprStack( ResultStr, Ord(nptString) );
  end; // with PP^ do
end; //*** end of  procedure N_SPLFGetWordVar

//***************************************************** N_SPLFCreateWordVar ***
// SPL procedure CreateWordVar( AVarName: string; AVarContent: string );
//
// Create New Word GCWSMainDoc Variable with given AVarName and given content AVarContent
// (Variable with given AVarName should not exists before)
//
procedure N_SPLFCreateWordVar( AKGC: TK_CSPLCont );
type  Params = packed record
  AVarName: string;
  DType1:   TK_ExprExtType;
  AVarContent: string;
  DType2:      TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    GCWSMainDoc.Variables( AVarName ).Value := AVarContent;
    AVarName    := ''; // Free fields on SPL Stack
    AVarContent := ''; // Free fields on SPL Stack
  end; // with PP^ do
end; //*** end of  procedure N_SPLFCreateWordVar

//******************************************************** N_SPLFSetWordVar ***
// SPL procedure SetWordVar( AVarName: string; AVarContent: string );
//
// Set new content (AVarContent) to already existing Word GCWSMainDoc Variable with given AVarName
//
procedure N_SPLFSetWordVar( AKGC: TK_CSPLCont );
type  Params = packed record
  AVarName: string;
  DType1:   TK_ExprExtType;
  AVarContent: string;
  DType2:      TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    GCWSMainDoc.Variables( AVarName ).Value := AVarContent;
    AVarName    := ''; // Free fields on SPL Stack
    AVarContent := ''; // Free fields on SPL Stack
  end; // with PP^ do
end; //*** end of  procedure N_SPLFSetWordVar

//********************************************************* N_SPLFRunWMacro ***
// SPL procedure RunWMacro( AFullMacroName: string );
//
// Run Word Macro without params with given AFullMacroName
// AFullMacroName consists of TemplateName.ModuleName.MacroName ('Normal.Module1.TestMacro2')
//
procedure N_SPLFRunWMacro( AKGC: TK_CSPLCont );
type  Params = packed record
  AFullMacroName: string;
  DType1: TK_ExprExtType;
end;
var
  PP: ^Params;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    GCWordServer.Run( AFullMacroName );
    AFullMacroName := ''; // Free fields on SPL Stack
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFRunWMacro

//***************************************************** N_SPLFSetWMainDocIP ***
// SPL procedure SetWMainDocIP( ABookmarkName: string; AMode: integer );
//
// Set GCWSMainDocIP (GCWSMainDocType should be odtWord) by given ABookmarkName
// and given AMode:
//   AMode=0 - Set GCWSMainDocIP just before Bookmark
//   AMode=1 - Set GCWSMainDocIP to Bookmark.Range (paste will remove Bookmark)
//   AMode=0 - Set GCWSMainDocIP just after Bookmark
//
procedure N_SPLFSetWMainDocIP( AKGC: TK_CSPLCont );
type  Params = packed record
  ABookmarkName: string;
  DType1:        TK_ExprExtType;
  AMode:  integer;
  DType2: TK_ExprExtType;
end;
var
  PP: ^Params;
  BMRange: variant;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    BMRange := GCWSMainDoc.Bookmarks.Item( ABookmarkName ).Range;

    case AMode of

    0: begin // Set GCWSMainDocIP just before Bookmark
//      BMRange.Collapse( wdCollapseStart );
      BMRange.Move( wdCharacter, -1 );
      GCWSMainDocIP := BMRange;
    end; // 0: begin // Set GCWSMainDocIP just before Bookmark

    1: begin // Set GCWSMainDocIP to Bookmark.Range
      GCWSMainDocIP := BMRange;
    end; // 0: begin // Set GCWSMainDocIP to Bookmark.Range

    2: begin // Set GCWSMainDocIP just after Bookmark
//      BMRange.Collapse( wdCollapseEnd );
      BMRange.Move( wdCharacter, 1 );
      GCWSMainDocIP := BMRange;
    end; // 0: begin // Set GCWSMainDocIP just after Bookmark

    end; // case AMode of

    ABookmarkName := ''; // Free fields on SPL Stack
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetWMainDocIP

//****************************************************** N_SPLFSetCurWTable ***
// SPL procedure SetCurWTable( ATableId: string );
//
// Set Current Word Table by given ATableId
// ATableId[1] is 'M' for GCWSMainDoc and 'C' for GCWSCurDoc, rest characters means:
// ''        - Table, that contains current Bookmark,
// a number  - it is index in Document.Tables (>=1),
// otherwise - it is Bookmark Name, that contains needed Table
//
procedure N_SPLFSetCurWTable( AKGC: TK_CSPLCont );
type  Params = packed record
  ATableId: string;
  DType1:  TK_ExprExtType;
end;
var
  PP: ^Params;
  Str, RestChars: string;
  TableInd: integer;
  Doc: Variant;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    Str := UpperCase( Trim( ATableId ) );
    if Str[1] = 'M' then Doc := GCWSMainDoc
                    else Doc := GCWSCurDoc;
    RestChars := Copy( Str, 2, Length(Str)-1 );

    if ATableId = '' then // table with current Bookmark
    begin
      //...
    end else if (RestChars[1] >= '0') and (RestChars[1] <= '9') then // Table index in Documents.Tables
    begin
      TableInd := StrToIntDef( RestChars, -1 );
//      N_s := Doc.Name; // debug
      if TableInd >= 1 then
        GCCurWTable := Doc.Tables.Item( TableInd );
    end else // ATableId is Bookmark Name, that contains needed Table
    begin
      //...
    end;

    ATableId := ''; // Free fields on SPL Stack
    Doc := Unassigned();
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetCurWTable

//***************************************************** N_SPLFInsWTableRows ***
// SPL procedure InsWTableRows( ARowInd: integer; ANumRows: integer );
//
// Insert in current Word Table before Row with given ARowInd (>=1)
// given number of Rows
//
procedure N_SPLFInsWTableRows( AKGC: TK_CSPLCont );
type  Params = packed record
  ARowInd: integer;
  DType1:  TK_ExprExtType;
  ANumRows: integer;
  DType2:   TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    if VarIsEmpty( GCCurWTable ) then Exit; // a precaution
    GCCurWTable.Cell( ARowInd, 1 ).Select;
    GCWordServer.Selection.InsertRows( ANumRows );
  end; // with , TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFInsWTableRows

//************************************************** N_SPLFSetWTableStrCell ***
// SPL procedure SetWTableStrCell( ARowInd: integer; AColInd: integer; AStr: string );
//
// Insert given string AStr in current Word Table Cell( ARowInd, AColInd )
//
procedure N_SPLFSetWTableStrCell( AKGC: TK_CSPLCont );
type  Params = packed record
  ARowInd: integer;
  DType1:  TK_ExprExtType;
  AColInd: integer;
  DType2:  TK_ExprExtType;
  AStr:    string;
  DType3:  TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    if VarIsEmpty( GCCurWTable ) then Exit; // a precaution

    GCCurWTable.Cell( ARowInd, AColInd ).Range.Text := Astr;
    Astr := ''; // Free fields on SPL Stack
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetWTableStrCell

//************************************************** N_SPLFSetWTableValCell ***
// SPL procedure SetWTableValCell( ARowInd: integer; AColInd: integer;
//                                 AVal: double; AFmt: string );
//
// Convert given value AVal by given Pascal Format AFmt and insert resulting
// string in current Word Table Cell( ARowInd, AColInd )
//
procedure N_SPLFSetWTableValCell( AKGC: TK_CSPLCont );
type  Params = packed record
  ARowInd: integer;
  DType1:  TK_ExprExtType;
  AColInd: integer;
  DType2:  TK_ExprExtType;
  AVal:    double;
  DType3:  TK_ExprExtType;
  AFmt:    string;
  DType4:  TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    if VarIsEmpty( GCCurWTable ) then Exit; // a precaution

    GCCurWTable.Cell( ARowInd, AColInd ).Range.Text := Format( AFmt, [AVal] );
    AFmt := ''; // Free fields on SPL Stack
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetWTableValCell

//************************************************* N_SPLFSetWTableCompCell ***
// SPL procedure SetWTableCompCell( ARowInd: integer; AColInd: integer; AComp: TN_UDBase );
//
// Execute given component AComp and insert Windows Clipboard content
// in current Word Table Cell( ARowInd, AColInd )
//
procedure N_SPLFSetWTableCompCell( AKGC: TK_CSPLCont );
type  Params = packed record
  ARowInd: integer;
  DType1:  TK_ExprExtType;
  AColInd: integer;
  DType2:  TK_ExprExtType;
  AComp:   TN_UDBase;
  DType3:  TK_ExprExtType;
end;
var
  PP : ^Params;
  NewGCont: TN_GlobCont;
  CurSPLComp: TN_UDCompBase;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution
  CurSPLComp := TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp);

  with PP^, CurSPLComp.NGCont do
  begin
    if VarIsEmpty( GCCurWTable ) then Exit; // a precaution

    if not (AComp is TN_UDCompBase) then
      raise TK_SPLRunTimeError.Create( 'ExecComp error: '+ AComp.ObjName +
                                       ' is not a Component!' );
    N_s := AComp.ObjName; // for debug

    TN_UDCompBase(AComp).DynParent := CurSPLComp;

    NewGCont := TN_GlobCont.Create;
    NewGCont.ExecuteRootComp( AComp, [] );
    NewGCont.Free;

    GCCurWTable.Cell( ARowInd, AColInd ).Range.Paste;
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetWTableCompCell

//*************************************************** N_SPLFSetWTableStrRow ***
// SPL procedure SetWTableStrRow( ARowInd: integer; AColInd: integer; AStrArray: ArrayOf string );
//
// Insert given vector AStrArray in current Excel Sheet Row
// to Cells(ARowInd,AColInd) - Cells(ARowInd,AColInd+ArrayLeng-1)
// ( ARowInd, AColInd >= 1 )
//
procedure N_SPLFSetWTableStrRow( AKGC: TK_CSPLCont );
type  Params = packed record
  ARowInd: integer;
  DType1:  TK_ExprExtType;
  AColInd: integer;
  DType2:  TK_ExprExtType;
  AStrArray: TK_RArray;
  DType3:    TK_ExprExtType;
end;
var
  PP : ^Params;
  i, NumElemes: integer;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    if VarIsEmpty( GCCurWTable ) then Exit; // a precaution
    if AStrArray.ElemSType <> Ord(nptString) then Exit; // a precaution
    NumElemes := AStrArray.Alength();

    for i := 0 to NumElemes-1 do
      GCCurWTable.Cell( ARowInd, AColInd+i ).Range.Text := PString(AStrArray.P(i))^;

    AStrArray.ARelease; // Free fields on SPL Stack
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetWTableStrRow

//*************************************************** N_SPLFSetFirstPageNum ***
// SPL procedure SetWTableStrRow( ARowInd: integer; AColInd: integer; AStrArray: ArrayOf string );
//
// Insert given vector AStrArray in current Excel Sheet Row
// to Cells(ARowInd,AColInd) - Cells(ARowInd,AColInd+ArrayLeng-1)
// ( ARowInd, AColInd >= 1 )
//
procedure N_SPLFSetFirstPageNum( AKGC: TK_CSPLCont );
type  Params = packed record
  AFirstPageNum: integer;
  DType1:  TK_ExprExtType;
end;
var
  PP: ^Params;
  Sec, Header: variant;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
//    GCWSMainDoc.Sections(1).Headers(1).PageNumbers.StartingNumber := AFirstPageNum;
    Sec := GCWSMainDoc;
    Sec := GCWSMainDoc.Sections.Item(1);
    Header := Sec.Headers.Item(1); // is OK
//    Header := Sec.Headers; // is Error!
//    N_i := Header.PageNumbers.StartingNumber; // debug
    Header.PageNumbers.StartingNumber := AFirstPageNum; // is OK
//    N_i := Header.PageNumbers.StartingNumber; // debug
//    Header := Sec.Footers.Item(1); // is OK
//    N_i := Header.PageNumbers.StartingNumber; // debug
//    Header.PageNumbers.StartingNumber := AFirstPageNum; // is OK
//    N_i := Header.PageNumbers.StartingNumber; // debug

//    Header.PageNumbers.Item(1).StartingNumber := AFirstPageNum; // is Error!
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetFirstPageNum


  //************ ESheet procedures and functions

//*************************************************************** N_SPLFECN ***
// SPL function ECN( AColName: string ): integer;
//
// Get Excel Column Number by given Column Name ('A', 'B', ... , 'Z', 'AA', 'AB', ...)
//
procedure N_SPLFECN( AKGC: TK_CSPLCont );
type  Params = packed record
  AColName: string;
  DType1:   TK_ExprExtType;
end;
var
  PP: ^Params;
  ResInt: integer;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );

  with PP^ do
  begin
    ResInt := 1;

    if Length( AColName ) = 1 then
      ResInt := Integer(AColName[1]) - Integer('A') + 1
    else if Length( AColName ) = 2 then
      ResInt := (Integer(AColName[2]) - Integer('A'))*26 +
                 Integer(AColName[1]) - Integer('A') + 1;

    AColName := ''; // Free fields on SPL Stack
    AKGC.PutDataToExprStack( ResInt, Ord(nptInt) );
  end; // with PP^ do
end; //*** end of  procedure N_SPLFECN

//****************************************************** N_SPLFSetCurESheet ***
// SPL procedure SetCurESheet( ASheetId: string );
//
// Set Current Excel Sheet by given ASheetId:
// ASheetId = '' - Sheet, that contains current Macro,
// ASheetId[1] is 'M' for GCWSMainDoc and 'C' for GCESCurDoc, rest characters means:
//   ''        - Active Sheet of GCWSMainDoc or GCCurDoc (ASheetId = 'M' or 'C')
//   a number  - it is index in Workbook.Sheets (>=1), (e.g. ASheetId = 'C2')
//   otherwise - it is needed Sheet Name, (e.g. ASheetId = 'CÀËÒÚ2')
//
procedure N_SPLFSetCurESheet( AKGC: TK_CSPLCont );
type  Params = packed record
  ASheetId: string;
  DType1:  TK_ExprExtType;
end;
var
  PP: ^Params;
  Str, RestChars: string;
  PosInd, SheetInd: integer;
  Doc: Variant;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    Str := UpperCase( Trim( ASheetId ) );
    if (Str[1] = 'M') or (Str[1] = 'Ã') then Doc := GCESMainDoc // Lat or Cyr 'M'
                                        else Doc := GCESCurDoc;
    RestChars := Copy( Str, 2, Length(Str)-1 );
    N_s := Doc.Name; // debug

    if ASheetId = '' then // Sheet with current Macro
    begin
      PosInd := Pos( '!', GCCurMacroAdr );
      Str := Copy( GCCurMacroAdr, 2, PosInd - 3 ); // Sheet Name (GCCurMacroAdr = '=Sheet1!$A$1' )
      GCCurESheet := Doc.Sheets.Item[ Str ];
    end else if Length(RestChars) = 0 then // Doc ActiveSheet
      GCCurESheet := Doc.ActiveSheet
    else if (RestChars[1] >= '0') and (RestChars[1] <= '9') then // Sheet index in Workbook.Sheets
    begin
      SheetInd := StrToIntDef( RestChars, -1 );
      if SheetInd >= 1 then
        GCCurESheet := Doc.Sheets.Item[ SheetInd ];
    end else // ASheetId is needed Sheet Name
    begin
      GCCurESheet := Doc.Sheets.Item[ RestChars ];
    end;

    ASheetId := ''; // Free fields on SPL Stack
    Doc := Unassigned();
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetCurESheet

//***************************************************** N_SPLFInsESheetRows ***
// SPL procedure InsESheetRows( ARowInd: integer; ANumRows: integer );
//      me be not needed?
// Insert in current Excel Sheet before Row with given ARowInd (>=1)
// given number of Rows
//
procedure N_SPLFInsESheetRows( AKGC: TK_CSPLCont );
type  Params = packed record
  ARowInd: integer;
  DType1:  TK_ExprExtType;
  ANumRows: integer;
  DType2:   TK_ExprExtType;
end;
var
  PP: ^Params;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    if VarIsEmpty( GCCurESheet ) then Exit; // a precaution
    N_i := ARowInd;
//    GCCurESheet.Insert( ... ); not implemented
  end; // with , TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFInsESheetRows

//************************************************** N_SPLFSetESheetStrCell ***
// SPL procedure SetESheetStrCell( ARowInd: integer; AColInd: integer; AStr: string );
//
// Insert given string AStr in current Excel Sheet Cell( ARowInd, AColInd )
//
procedure N_SPLFSetESheetStrCell( AKGC: TK_CSPLCont );
type  Params = packed record
  ARowInd: integer;
  DType1:  TK_ExprExtType;
  AColInd: integer;
  DType2:  TK_ExprExtType;
  AStr:    string;
  DType3:  TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution


  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    if VarIsEmpty( GCCurESheet ) then Exit; // a precaution
    N_s := GCCurESheet.Name; // debug
    GCCurESheet.Cells[ ARowInd, AColInd ].Value := Astr;
    Astr := ''; // Free fields on SPL Stack
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetESheetStrCell

//************************************************** N_SPLFSetESheetDblCell ***
// SPL procedure SetESheetDblCell( ARowInd: integer; AColInd: integer; ADbl: double );
//
// Insert given double ADbl in current Excel Sheet Cell( ARowInd, AColInd )
//
procedure N_SPLFSetESheetDblCell( AKGC: TK_CSPLCont );
type  Params = packed record
  ARowInd: integer;
  DType1:  TK_ExprExtType;
  AColInd: integer;
  DType2:  TK_ExprExtType;
  ADbl:    double;
  DType3:  TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution


  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    if VarIsEmpty( GCCurESheet ) then Exit; // a precaution
    N_s := GCCurESheet.Name; // debug
    GCCurESheet.Cells[ ARowInd, AColInd ].Value := ADbl;
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetESheetDblCell

//************************************************* N_SPLFSetESheetCompCell ***
// SPL procedure SetESheetCompCell( ARowInd: integer; AColInd: integer; AComp: TN_UDBase );
//
// Insert given Component AComp in current Excel Sheet Cell( ARowInd, AColInd )
//
procedure N_SPLFSetESheetCompCell( AKGC: TK_CSPLCont );
type  Params = packed record
  ARowInd: integer;
  DType1:  TK_ExprExtType;
  AColInd: integer;
  DType2:  TK_ExprExtType;
  AComp:   TN_UDBase;
  DType3:  TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    if VarIsEmpty( GCCurESheet ) then Exit; // a precaution
    N_i := ARowInd;
    N_s := GCCurESheet.Name; // debug
//    GCCurESheet.Cells[ ARowInd, AColInd ].Value := Astr;
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetESheetCompCell

//*************************************************** N_SPLFSetESheetStrRow ***
// SPL procedure SetESheetStrRow( ARowInd: integer; AColInd: integer; AStrArray: ArrayOf String );
//
// Insert given vector AStrArray in current Excel Sheet Row
// to Cells(ARowInd,AColInd) - Cells(ARowInd,AColInd+ArrayLeng-1)
// ( ARowInd, AColInd >= 1 )
//
procedure N_SPLFSetESheetStrRow( AKGC: TK_CSPLCont );
type  Params = packed record
  ARowInd: integer;
  DType1:  TK_ExprExtType;
  AColInd: integer;
  DType2:  TK_ExprExtType;
  AStrArray: TK_RArray;
  DType3:    TK_ExprExtType;
end;
var
  PP: ^Params;
  i, NumElemes: integer;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    if VarIsEmpty( GCCurESheet ) then Exit; // a precaution
    if AStrArray.ElemSType <> Ord(nptString) then Exit; // a precaution
    NumElemes := AStrArray.Alength();

    for i := 0 to NumElemes-1 do
      GCCurESheet.Cells[ ARowInd, AColInd+i ].Value := PString(AStrArray.P(i))^;

    AStrArray.ARelease; // Free fields on SPL Stack
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetESheetStrRow

//*************************************************** N_SPLFSetESheetStrCol ***
// SPL procedure SetESheetStrCol( ARowInd: integer; AColInd: integer; AStrArray: ArrayOf String );
//
// Insert given vector AStrArray in current Excel Sheet Column
// to Cells(ARowInd,AColInd) - Cells(ARowInd,AColInd+ArrayLeng-1)
// ( ARowInd, AColInd >= 1 )
//
procedure N_SPLFSetESheetStrCol( AKGC: TK_CSPLCont );
type  Params = packed record
  ARowInd: integer;
  DType1:  TK_ExprExtType;
  AColInd: integer;
  DType2:  TK_ExprExtType;
  AStrArray: TK_RArray;
  DType3:    TK_ExprExtType;
end;
var
  PP: ^Params;
  i, NumElemes: integer;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    if VarIsEmpty( GCCurESheet ) then Exit; // a precaution
    if AStrArray.ElemSType <> Ord(nptString) then Exit; // a precaution
    NumElemes := AStrArray.Alength();

    for i := 0 to NumElemes-1 do
      GCCurESheet.Cells[ ARowInd+i, AColInd ].Value := PString(AStrArray.P(i))^;

    AStrArray.ARelease; // Free fields on SPL Stack
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetESheetStrCol

//*************************************************** N_SPLFSetESheetDblRow ***
// SPL procedure SetESheetDblRow( ARowInd: integer; AColInd: integer; ADblArray: ArrayOf String );
//
// Insert given vector ADblArray in current Excel Sheet Row
// to Cells(ARowInd,AColInd) - Cells(ARowInd,AColInd+ArrayLeng-1)
// ( ARowInd, AColInd >= 1 )
//
procedure N_SPLFSetESheetDblRow( AKGC: TK_CSPLCont );
type  Params = packed record
  ARowInd: integer;
  DType1:  TK_ExprExtType;
  AColInd: integer;
  DType2:  TK_ExprExtType;
  ADblArray: TK_RArray;
  DType3:    TK_ExprExtType;
end;
var
  PP: ^Params;
  i, NumElemes: integer;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    if VarIsEmpty( GCCurESheet ) then Exit; // a precaution
    if ADblArray.ElemSType <> Ord(nptDouble) then Exit; // a precaution
    NumElemes := ADblArray.Alength();

    for i := 0 to NumElemes-1 do
      GCCurESheet.Cells[ ARowInd, AColInd+i ].Value := PDouble(ADblArray.P(i))^;

    ADblArray.ARelease; // Free fields on SPL Stack
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetESheetDblRow

//*************************************************** N_SPLFSetESheetDblCol ***
// SPL procedure SetESheetDblCol( ARowInd: integer; AColInd: integer; ADblArray: ArrayOf double );
//
// Insert given vector ADblArray in current Excel Sheet Column
// to Cells(ARowInd,AColInd) - Cells(ARowInd,AColInd+ArrayLeng-1)
// ( ARowInd, AColInd >= 1 )
//
procedure N_SPLFSetESheetDblCol( AKGC: TK_CSPLCont );
type  Params = packed record
  ARowInd: integer;
  DType1:  TK_ExprExtType;
  AColInd: integer;
  DType2:  TK_ExprExtType;
  ADblArray: TK_RArray;
  DType3:    TK_ExprExtType;
end;
var
  PP: ^Params;
  i, NumElemes: integer;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    if VarIsEmpty( GCCurESheet ) then Exit; // a precaution
    if ADblArray.ElemSType <> Ord(nptDouble) then Exit; // a precaution
    NumElemes := ADblArray.Alength();

    for i := 0 to NumElemes-1 do
      GCCurESheet.Cells[ ARowInd+i, AColInd ].Value := PDouble(ADblArray.P(i))^;

    ADblArray.ARelease; // Free fields on SPL Stack
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetESheetDblCol

//************************************************** N_SPLFSetESheetDblMatr ***
// SPL procedure SetESheetDblMatr( ARowInd: integer; AColInd: integer; ADblMatr: ArrayOf double );
//
// Insert given Matrix ADblMatr in current Excel Sheet
// to Cells(ARowInd,AColInd) - Cells(ARowInd+NumRows-1,AColInd+NumCols-1)
// ( ARowInd, AColInd >= 1 )
//
procedure N_SPLFSetESheetDblMatr( AKGC: TK_CSPLCont );
type  Params = packed record
  ARowInd: integer;
  DType1:  TK_ExprExtType;
  AColInd: integer;
  DType2:  TK_ExprExtType;
  ADblMatr: TK_RArray;
  DType3:   TK_ExprExtType;
end;
var
  PP: ^Params;
  i, j, NumRows, NumCols: integer;
//  OneStr: string;
  SStr: ShortString;
  SMatr: TN_ASArray;
begin
  PP := AKGC.GetPointerToExprStackRecord( SizeOf(Params) );
  if not (AKGC is TN_NKGlobCont) then Exit; // a precaution

  with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp).NGCont do
  begin
    if VarIsEmpty( GCCurESheet ) then Exit; // a precaution
    if ADblMatr.ElemSType <> Ord(nptDouble) then Exit; // a precaution

    ADblMatr.ALength( NumCols, NumRows );
{
    for i := 0 to NumRows-1 do // too slow!
      for j := 0 to NumCols-1 do
        GCCurESheet.Cells[ ARowInd+i, AColInd+j ].Value :=
                                         PDouble(ADblMatr.P( i*NumCols + j ))^;
}
    SetLength( SMatr, NumRows );
    N_AdjustStrMatr( SMatr, NumCols );

    for i := 0 to NumRows-1 do
      for j := 0 to NumCols-1 do
      begin
        Str( PDouble(ADblMatr.P( i*NumCols + j ))^, SStr );
        SMatr[i,j] := String(SStr);
      end;

    K_PutTextToClipboard( N_SaveSMatrToString( SMatr ) );
    GCCurESheet.Paste( GCCurESheet.Cells[ ARowInd, AColInd ] );

    ADblMatr.ARelease; // Free fields on SPL Stack
  end; // with PP^, TN_UDCompBase(TN_NKGlobCont(AKGC).SPLComp) do
end; //*** end of  procedure N_SPLFSetESheetDblMatr

{
Initialization
//**************** My indexes are 200 - 299  **************************

  K_ExprNFuncNames[204] := 'Deb1';
  K_ExprNFuncRefs [204] := N_SPLFDeb1;

  K_ExprNFuncNames[205] := 'Deb2';
  K_ExprNFuncRefs [205] := N_SPLFDeb2;

  K_ExprNFuncNames[206] := 'AddStrToFile';
  K_ExprNFuncRefs [206] := N_SPLFAddStrToFile;

  K_ExprNFuncNames[207] := 'AddPDCounter';
  K_ExprNFuncRefs [207] := N_SPLFAddPDCounter;

  K_ExprNFuncNames[211] := '—ÍÎÓÌ';
  K_ExprNFuncRefs [211] := N_SPLFSclon;

  K_ExprNFuncNames[212] := 'UDFPStat';
  K_ExprNFuncRefs [212] := N_SPLFUDFPStat;

  K_ExprNFuncNames[213] := 'UDFPDyn';
  K_ExprNFuncRefs [213] := N_SPLFUDFPDyn;

  K_ExprNFuncNames[214] := 'CSItemKeyPDyn';
  K_ExprNFuncRefs [214] := N_SPLFCSItemKeyPDyn;

  K_ExprNFuncNames[215] := 'ExecComp';
  K_ExprNFuncRefs [215] := N_SPLFExecComp;

  K_ExprNFuncNames[216] := 'SampleText';
  K_ExprNFuncRefs [216] := N_SPLFSampleText;

  K_ExprNFuncNames[217] := 'DateTimeToStr';
  K_ExprNFuncRefs [217] := N_SPLFDateTimeToStr;

  K_ExprNFuncNames[218] := 'WSInfoToStr';
  K_ExprNFuncRefs [218] := N_SPLFWSInfoToStr;

  K_ExprNFuncNames[219] := 'GetGCVar';
  K_ExprNFuncRefs [219] := N_SPLFGetGCVar;

  K_ExprNFuncNames[220] := 'SetGCVar';
  K_ExprNFuncRefs [220] := N_SPLFSetGCVar;


  K_ExprNFuncNames[221] := 'GetDblRow';
  K_ExprNFuncRefs [221] := N_SPLFGetDblRow;


  //************ WTable procedures and functions
  K_ExprNFuncNames[225] := 'SetGCMDBm';
  K_ExprNFuncRefs [225] := N_SPLFSetGCMDBm;

  K_ExprNFuncNames[226] := 'GetWordVar';
  K_ExprNFuncRefs [226] := N_SPLFGetWordVar;

  K_ExprNFuncNames[227] := 'CreateWordVar';
  K_ExprNFuncRefs [227] := N_SPLFCreateWordVar;

  K_ExprNFuncNames[228] := 'SetWordVar';
  K_ExprNFuncRefs [228] := N_SPLFSetWordVar;

  K_ExprNFuncNames[229] := 'RunWMacro';
  K_ExprNFuncRefs [229] := N_SPLFRunWMacro;

  K_ExprNFuncNames[230] := 'SetWMainDocIP';
  K_ExprNFuncRefs [230] := N_SPLFSetWMainDocIP;

  K_ExprNFuncNames[231] := 'SetCurWTable';
  K_ExprNFuncRefs [231] := N_SPLFSetCurWTable;

  K_ExprNFuncNames[232] := 'InsWTableRows';
  K_ExprNFuncRefs [232] := N_SPLFInsWTableRows;


  K_ExprNFuncNames[235] := 'SetWTableStrCell';
  K_ExprNFuncRefs [235] := N_SPLFSetWTableStrCell;

  K_ExprNFuncNames[236] := 'SetWTableValCell';
  K_ExprNFuncRefs [236] := N_SPLFSetWTableValCell;

  K_ExprNFuncNames[237] := 'SetWTableCompCell';
  K_ExprNFuncRefs [237] := N_SPLFSetWTableCompCell;

  K_ExprNFuncNames[238] := 'SetWTableStrRow';
  K_ExprNFuncRefs [238] := N_SPLFSetWTableStrRow;

  // 239-246 reserved for WTable funcs

  K_ExprNFuncNames[247] := 'SetFirstPageNum';
  K_ExprNFuncRefs [247] := N_SPLFSetFirstPageNum;

  //************ ESheet procedures and functions

  K_ExprNFuncNames[249] := 'ECN';
  K_ExprNFuncRefs [249] := N_SPLFECN;

  K_ExprNFuncNames[250] := 'SetCurESheet';
  K_ExprNFuncRefs [250] := N_SPLFSetCurESheet;

  K_ExprNFuncNames[251] := 'InsESheetRows';
  K_ExprNFuncRefs [251] := N_SPLFInsESheetRows;


  K_ExprNFuncNames[253] := 'SetESheetStrCell';
  K_ExprNFuncRefs [253] := N_SPLFSetESheetStrCell;

  K_ExprNFuncNames[254] := 'SetESheetDblCell';
  K_ExprNFuncRefs [254] := N_SPLFSetESheetDblCell;

  K_ExprNFuncNames[255] := 'SetESheetCompCell';
  K_ExprNFuncRefs [255] := N_SPLFSetESheetCompCell;


  K_ExprNFuncNames[257] := 'SetESheetStrRow';
  K_ExprNFuncRefs [257] := N_SPLFSetESheetStrRow;

  K_ExprNFuncNames[258] := 'SetESheetStrCol';
  K_ExprNFuncRefs [258] := N_SPLFSetESheetStrCol;

  K_ExprNFuncNames[259] := 'SetESheetDblRow';
  K_ExprNFuncRefs [259] := N_SPLFSetESheetDblRow;

  K_ExprNFuncNames[260] := 'SetESheetDblCol';
  K_ExprNFuncRefs [260] := N_SPLFSetESheetDblCol;

  K_ExprNFuncNames[261] := 'SetESheetDblMatr';
  K_ExprNFuncRefs [261] := N_SPLFSetESheetDblMatr;
}
end.
