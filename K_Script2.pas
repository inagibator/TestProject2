unit K_Script2;

interface

uses K_Script1;

//********************************
// Built-In SPL Funcs
//********************************
procedure K_ExprNStringsAdd( GC : TK_CSPLCont );
procedure K_ExprNStringsSet( GC : TK_CSPLCont );
procedure K_ExprNStringsDel( GC : TK_CSPLCont );
procedure K_ExprNStringsGet( GC : TK_CSPLCont );
procedure K_ExprNStringsLength( GC : TK_CSPLCont );
procedure K_ExprNStringsLoad( GC : TK_CSPLCont );
procedure K_ExprNStringsSave( GC : TK_CSPLCont );
procedure K_ExprNFree( GC : TK_CSPLCont );
procedure K_ExprNGetCMDLinePar( GC : TK_CSPLCont );
procedure K_ExprNDVAddExpr( GC : TK_CSPLCont );
procedure K_ExprNDVMultExpr( GC : TK_CSPLCont );
procedure K_ExprNDVDivExpr( GC : TK_CSPLCont );
procedure K_ExprNDVCUSumExpr( GC : TK_CSPLCont );
procedure K_ExprNDVAbsExpr( GC : TK_CSPLCont );
procedure K_ExprNDVSum( GC : TK_CSPLCont );
procedure K_ExprNDVIndOfMax( GC : TK_CSPLCont );
procedure K_ExprNDVMultExprE( GC : TK_CSPLCont );
procedure K_ExprNDVIndOfInterval( GC : TK_CSPLCont );
procedure K_ExprNSetOR( GC : TK_CSPLCont );
procedure K_ExprNSetAND( GC : TK_CSPLCont );
procedure K_ExprNSetClear( GC : TK_CSPLCont );
procedure K_ExprNSetEQ( GC : TK_CSPLCont );
procedure K_ExprNSetLE( GC : TK_CSPLCont );
procedure K_ExprNSetToInds( GC : TK_CSPLCont );
procedure K_ExprNCreateMVAtlasArchive( GC : TK_CSPLCont );
procedure K_ExprNRunDFPLStrings( GC : TK_CSPLCont );
procedure K_ExprNSetUDFields( GC : TK_CSPLCont );
procedure K_ExprNGetUDFields( GC : TK_CSPLCont );
procedure K_ExprNAppTerm( GC : TK_CSPLCont );
procedure K_ExprNSelectFilePath( GC : TK_CSPLCont );
procedure K_ExprNCreateIndIterator( GC : TK_CSPLCont );
procedure K_ExprNAddIIDim( GC : TK_CSPLCont );
procedure K_ExprNPrepIILoop( GC : TK_CSPLCont );
procedure K_ExprNGetNextIInds( GC : TK_CSPLCont );
procedure K_ExprNBuildCNKSets( GC : TK_CSPLCont );
procedure K_ExprNClearSetsBySets( GC : TK_CSPLCont );
procedure K_ExprNCreateMSDoc( GC : TK_CSPLCont );
procedure K_ExprNOpenCurArch1( GC : TK_CSPLCont );
procedure K_ExprNSaveCurArch1( GC : TK_CSPLCont );
procedure K_ExprNOpenCurArch( GC : TK_CSPLCont );
procedure K_ExprNSaveCurArch( GC : TK_CSPLCont );
procedure K_ExprNCreateWebSite( GC : TK_CSPLCont );
procedure K_ExprNMVImportTab( GC : TK_CSPLCont );
procedure K_ExprNSetArchUndoMode( GC : TK_CSPLCont );

implementation

uses SysUtils, Classes, Forms, Math,
  K_UDC, K_CLib0, K_CLib, K_UDT1, K_UDT2, K_DCSpace,
  K_Arch, K_STBuf, K_IndGlobal, K_UDConst,
  K_WSBuild1, K_MVObjs, K_RAEdit, K_VFunc,
  N_Types, N_Lib0, N_CompBase, N_StatFunc;

type  TK_DVFPars = packed record
  DVRes  : TK_RArray;
  DType1 : TK_ExprExtType;
  DVI1   : TK_RArray;
  DType2 : TK_ExprExtType;
  DVI2   : TK_RArray;
  DType3 : TK_ExprExtType;
  DVI3   : TK_RArray;
  DType4 : TK_ExprExtType;
end;
TK_PDVFPars = ^TK_DVFPars;

type  TK_DVFCont = record
  PRes, PV1, PV2, PV3 : PDouble;
  Count : Integer;
end;
TK_PDVFCont = ^TK_DVFCont;

//********************************************** K_ExprNDVFFin1 ***
//
procedure K_ExprNDVFFin1( PDVFPars : TK_PDVFPars; Num : Integer );
begin
  with PDVFPars^ do begin
    DVRes.ARelease;
    if Num = 0 then Exit;
    DVI1.ARelease;
    if Num = 1 then Exit;
    DVI2.ARelease;
    if Num = 2 then Exit;
    DVI3.ARelease;
  end;
end; //*** end of K_ExprNDVFFin1 ***

//********************************************** K_ExprNDVFStart1 ***
//
procedure K_ExprNDVFStart1( PDVFPars : TK_PDVFPars; PDVFCont : TK_PDVFCont; Num : Integer );
begin
  with PDVFPars^, PDVFCont^ do begin
    PRes := DVRes.P;
    Count := DVRes.ALength;
    if Num = 0 then Exit;
    PV1 := DVI1.P;
    Count := Min( Count, DVI1.ALength );
    if Num = 1 then Exit;
    PV2 := DVI2.P;
    if PV2 <> nil then
      Count := Min( Count, DVI2.ALength );
    if Num = 2 then Exit;
    PV3 := DVI3.P;
    Count := Min( Count, DVI3.ALength );
  end;
end; //*** end of K_ExprNDVFStart1 ***

//********************************************** K_ExprNDVAddExpr ***
// SPL: procedure DVAddExpr( DVRes : ArrrayOf Double; DVI1 : ArrrayOf Double;
//                           DVI2 : ArrrayOf Double; DSF3 : Double; DSF4 : Double );
//  if Alength(DVI2) <> 0 then
//    DVRes[i] = (DVI1[i] + DVI2[i] * DSF3) * DSF4
//  else
//    DVRes[i] = (DVI1[i] + DSF3) * DSF4
//
procedure K_ExprNDVAddExpr( GC : TK_CSPLCont );
type  Params = packed record
  DVRes  : TK_RArray;
  DType1 : TK_ExprExtType;
  DVI1   : TK_RArray;
  DType2 : TK_ExprExtType;
  DVI2   : TK_RArray;
  DType3 : TK_ExprExtType;
  DSF3   : Double;
  DType4 : TK_ExprExtType;
  DSF4   : Double;
  DType5 : TK_ExprExtType;
end;
var
  PP : ^Params;
  DVFCont : TK_DVFCont;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^, DVFCont do begin
    K_ExprNDVFStart1( TK_PDVFPars(PP), @DVFCont, 2 );

    K_SFAddVElems( PRes, Count, PV1, PV2, DSF3, DSF4 );

    K_ExprNDVFFin1( TK_PDVFPars(PP), 2 );
  end;
end; //*** end of K_ExprNDVAddExpr ***

//********************************************** K_ExprNDVMultExpr ***
// SPL: procedure DVMultExpr( DVRes : ArrrayOf Double; DVI1 : ArrrayOf Double;
//                            DVI2 : ArrrayOf Double; DSF3 : Double );
//  DVRes[i] = DVI1[i] * DVI2[i] * DSF3
//
procedure K_ExprNDVMultExpr( GC : TK_CSPLCont );
type  Params = packed record
  DVRes  : TK_RArray;
  DType1 : TK_ExprExtType;
  DVI1   : TK_RArray;
  DType2 : TK_ExprExtType;
  DVI2   : TK_RArray;
  DType3 : TK_ExprExtType;
  DSF3   : Double;
  DType4 : TK_ExprExtType;
end;
var
  PP : ^Params;
  DVFCont : TK_DVFCont;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^, DVFCont do begin
    K_ExprNDVFStart1( TK_PDVFPars(PP), @DVFCont, 2 );

    K_SFMultVElems( PRes, Count, PV1, PV2, DSF3 );

    K_ExprNDVFFin1( TK_PDVFPars(PP), 2 );
  end;
end; //*** end of K_ExprNDVMultExpr ***

//********************************************** K_ExprNDVMultExprE ***
// SPL: procedure DVMultExprE( DVRes : ArrrayOf Double; DVI1 : ArrrayOf Double; DVI2 : ArrrayOf Double;
//                           DSF3 : Double );
// SPL: procedure DVMultExprE( DVRes : ArrrayOf Double; DVF1 : ArrrayOf Double; Ind1 : Integer;
//                             DVF2 : ArrrayOf Double; Ind2 : Integer; DSF3 : Double );
//  DVRes[i] = DVI1[i + Ind1] * DVI2[i + Ind2] * DSF3
//
procedure K_ExprNDVMultExprE( GC : TK_CSPLCont );
type  Params = packed record
  DVRes  : TK_RArray;
  DType1 : TK_ExprExtType;
  DVI1   : TK_RArray;
  DType2 : TK_ExprExtType;
  Ind1   : Integer;
  DType3 : TK_ExprExtType;
  DVI2   : TK_RArray;
  DType4 : TK_ExprExtType;
  Ind2   : Integer;
  DType5 : TK_ExprExtType;
  DSF3   : Double;
  DType6 : TK_ExprExtType;
end;
var
  PP : ^Params;
  DVFCont : TK_DVFCont;
  DVFPars : TK_DVFPars;
type  TK_DVFPars = packed record
  DVRes  : TK_RArray;
  DType1 : TK_ExprExtType;
  DVI1   : TK_RArray;
  DType2 : TK_ExprExtType;
  DVI2   : TK_RArray;
  DType3 : TK_ExprExtType;
  DVI3   : TK_RArray;
  DType4 : TK_ExprExtType;
end;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^, DVFCont do begin
    DVFPars.DVRes := DVRes;
    DVFPars.DVI1 := DVI1;
    DVFPars.DVI2 := DVI2;
    K_ExprNDVFStart1( @DVFPars, @DVFCont, 2 );
    Inc( PV1, Ind1 );
    Inc( PV2, Ind2 );
    
    K_SFMultVElems( PRes, Count, PV1, PV2, DSF3 );

    K_ExprNDVFFin1( @DVFPars, 2 );
  end;
end; //*** end of K_ExprNDVMultExprE ***

//********************************************** K_ExprNDVDivExpr ***
// SPL: procedure DVDivExpr( DVRes : ArrrayOf Double; DVI1 : ArrrayOf Double; DVI2 : ArrrayOf Double;
//                           DSF3 : Double );
//  DVRes[i] = DVI1[i] / DVI2[i] * DSF3
//
procedure K_ExprNDVDivExpr( GC : TK_CSPLCont );
type  Params = packed record
  DVRes  : TK_RArray;
  DType1 : TK_ExprExtType;
  DVI1   : TK_RArray;
  DType2 : TK_ExprExtType;
  DVI2   : TK_RArray;
  DType3 : TK_ExprExtType;
  DSF3   : Double;
  DType4 : TK_ExprExtType;
end;
var
  PP : ^Params;
  DVFCont : TK_DVFCont;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^, DVFCont do begin
    K_ExprNDVFStart1( TK_PDVFPars(PP), @DVFCont, 2 );

    K_SFDivideVElems( PRes, Count, PV1, PV2, DSF3 );

    K_ExprNDVFFin1( TK_PDVFPars(PP), 2 );
  end;
end; //*** end of K_ExprNDVDivExpr ***

//********************************************** K_ExprNDVCUSumExpr ***
// SPL: procedure DVCUSumExpr( DVRes : ArrrayOf Double; DVI1 : ArrrayOf Double;
//                             DSF2 : Double );
//  DVRes[i] = DSF2 * ( Sum( j=0 to i ) DVI1[j] )
//
procedure K_ExprNDVCUSumExpr( GC : TK_CSPLCont );
type  Params = packed record
  DVRes  : TK_RArray;
  DType1 : TK_ExprExtType;
  DVI1   : TK_RArray;
  DType2 : TK_ExprExtType;
  DSF2   : Double;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
  DVFCont : TK_DVFCont;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^, DVFCont do begin
    K_ExprNDVFStart1( TK_PDVFPars(PP), @DVFCont, 1 );

    K_SFCUSumVElems( PRes, Count, PV1, DSF2 );

    K_ExprNDVFFin1( TK_PDVFPars(PP), 1 );
  end;
end; //*** end of K_ExprNDVCUSumExpr ***

//********************************************** K_ExprNDVAbsExpr ***
// SPL: procedure DVAbsExpr( DVRes : ArrrayOf Double; DVI1 : ArrrayOf Double;
//                           DSF2 : Double );
//  DVRes[i] = DSF2 * Abs( DVI1[i] )
//
procedure K_ExprNDVAbsExpr( GC : TK_CSPLCont );
type  Params = packed record
  DVRes  : TK_RArray;
  DType1 : TK_ExprExtType;
  DVI1   : TK_RArray;
  DType2 : TK_ExprExtType;
  DSF2   : Double;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
  DVFCont : TK_DVFCont;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^, DVFCont do begin
    K_ExprNDVFStart1( TK_PDVFPars(PP), @DVFCont, 1 );

    K_SFAbsVElems( PRes, Count, PV1, DSF2 );

    K_ExprNDVFFin1( TK_PDVFPars(PP), 1 );
  end;
end; //*** end of K_ExprNDVAbsExpr ***

//********************************************** K_ExprNDVSum ***
// SPL: function DVSum( DVI : ArrrayOf Double ) : Double;
//
procedure K_ExprNDVSum( GC : TK_CSPLCont );
type  Params = packed record
  DVI      : TK_RArray;
  DType1  : TK_ExprExtType;
end;
var
  PP : ^Params;
  DVFCont : TK_DVFCont;
  Res : Double;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^, DVFCont do begin
    K_ExprNDVFStart1( TK_PDVFPars(PP), @DVFCont, 0 );

    Res := K_SFGetSumElems( PRes, Count );

    K_ExprNDVFFin1( TK_PDVFPars(PP), 0 );

    GC.PutDataToExprStack( Res, Ord(nptDouble) );
  end;
end; //*** end of K_ExprNDVSum ***

//********************************************** K_ExprNDVIndOfMax ***
// SPL: function DVIndOfMax( DVI : ArrrayOf Double ) : Integer;
//
procedure K_ExprNDVIndOfMax( GC : TK_CSPLCont );
type  Params = packed record
  DVI      : TK_RArray;
  DType1  : TK_ExprExtType;
end;
var
  PP : ^Params;
  DVFCont : TK_DVFCont;
  Res : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^, DVFCont do begin
    K_ExprNDVFStart1( TK_PDVFPars(PP), @DVFCont, 0 );

    Res := K_SFGetIndOfMax( PRes, Count );

    K_ExprNDVFFin1( TK_PDVFPars(PP), 0 );

    GC.PutDataToExprStack( Res, Ord(nptInt) );
  end;
end; //*** end of K_ExprNDVIndOfMax ***

//********************************************** K_ExprNDVIndOfInterval ***
// SPL: function DVIndOfInterval( DVI : ArrrayOf Double; Val : Double ) : Integer;
//
procedure K_ExprNDVIndOfInterval( GC : TK_CSPLCont );
type  Params = packed record
  DVI      : TK_RArray;
  DType1   : TK_ExprExtType;
  Val      : Double;
  DType2   : TK_ExprExtType;
end;
var
  PP : ^Params;
  DVFCont : TK_DVFCont;
  Res : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^, DVFCont do begin
    K_ExprNDVFStart1( TK_PDVFPars(PP), @DVFCont, 0 );

    Res := K_IndexOfDoubleInScale( PRes, Count - 1, SizeOf(Double), Val );

    K_ExprNDVFFin1( TK_PDVFPars(PP), 0 );

    GC.PutDataToExprStack( Res, Ord(nptInt) );
  end;
end; //*** end of K_ExprNDVIndOfInterval ***

//********************************************** K_ExprNDVMode ***
// SPL: procedure DVMode( DVXIMin : ArrrayOf Double; DVXISize : ArrrayOf Double;
//                        DVFDistr : ArrrayOf Double );
//
procedure K_ExprNDVMode( GC : TK_CSPLCont );
type  Params = packed record
  DVXIMin : TK_RArray;
  DType1  : TK_ExprExtType;
  DVXISize: TK_RArray;
  DType2  : TK_ExprExtType;
  DVFDistr: TK_RArray;
  DType3  : TK_ExprExtType;
end;
var
  PP : ^Params;
  DVFCont : TK_DVFCont;
  Res : Double;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^, DVFCont do begin
    K_ExprNDVFStart1( TK_PDVFPars(PP), @DVFCont, 2 );

    Res := K_SFGetVectorMode( PRes, PV1, PV2, Count );

    K_ExprNDVFFin1( TK_PDVFPars(PP), 2 );

    GC.PutDataToExprStack( Res, Ord(nptDouble) );
  end;
end; //*** end of K_ExprNDVMode ***

//********************************************** K_ExprNDVPartValue ***
// SPL: function  DVPartValue( DVXIMin : ArrrayOf Double; DVXISize : ArrrayOf Double;
//                       DVFRatio : ArrrayOf Double; DVCSFRatio : ArrrayOf Double;
//                       DPPrc : Double ) : Double;
//
procedure K_ExprNDVPartValue( GC : TK_CSPLCont );
type  Params = packed record
  DVXIMin : TK_RArray;
  DType1  : TK_ExprExtType;
  DVXISize: TK_RArray;
  DType2  : TK_ExprExtType;
  DVFRatio: TK_RArray;
  DType3  : TK_ExprExtType;
  DVCSFRatio: TK_RArray;
  DType4  : TK_ExprExtType;
  DPPrc   : Double;
  DType5  : TK_ExprExtType;
end;
var
  PP : ^Params;
  DVFCont : TK_DVFCont;
  Res : Double;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^, DVFCont do begin
    K_ExprNDVFStart1( TK_PDVFPars(PP), @DVFCont, 3 );

    Res := K_SFGetPartValue( PRes, PV1, PV2, PV3, Count, DPPrc );

    K_ExprNDVFFin1( TK_PDVFPars(PP), 3 );

    GC.PutDataToExprStack( Res, Ord(nptDouble) );
  end;
end; //*** end of K_ExprNDVPartValue ***

//********************************************** K_ExprNFree ***
// SPL: procedure Free( Obj : ^TObject );
//
procedure K_ExprNFree( GC : TK_CSPLCont );
type  Params = packed record
  PPasObj  : PObject;
  DType1 : TK_ExprExtType;
end;

var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
    FreeAndNil( PPasObj^ );
end; //*** end of K_ExprNFree ***

//********************************************** K_ExprNGetCMDLinePar ***
// SPL: function GetCMDLinePar( ParName : string; ParInd : Integer  ) : string;
//
procedure K_ExprNGetCMDLinePar( GC : TK_CSPLCont );
type  Params = packed record
  ParName : string;
  DType1 : TK_ExprExtType;
  ParInd : Integer;
  DType2 : TK_ExprExtType;
end;

var
  PP : ^Params;
  ParVal : string;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if ParInd >= 0 then
      ParVal := K_CMDParams[ParInd]
    else
      ParVal := K_CMDParams.Values[ParName];
    ParName := '';
  end;
  GC.PutDataToExprStack( ParVal, Ord(nptString) );
end; //*** end of K_ExprNGetCMDLinePar ***

//********************************************** K_ExprNStringsPrepare ***
//
procedure K_ExprNStringsPrepare( var Strings : TStrings; ClearFlag : Boolean  );
begin
  if Strings = nil then
    Strings := TStringList.Create
  else if ClearFlag then
    Strings.Clear;
end; //*** end of K_ExprNStringsPrepare ***

//********************************************** K_ExprNStringsAdd ***
// SPL: function  StringsAdd( PStrings : ^TStrings; Str : String ) : Integer;
// Result >=0 - New List Length
//
procedure K_ExprNStringsAdd( GC : TK_CSPLCont );
type  Params = packed record
  PStrs  : PTStrings;
  DType2 : TK_ExprExtType;
  Str    : string;
  DType1 : TK_ExprExtType;
end;

var
  PP : ^Params;
  Res : Integer;

begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    K_ExprNStringsPrepare( PStrs^, false );
    PStrs^.Add( Str );
    Res := PStrs^.Count;
    Str := ''; // free
    GC.PutDataToExprStack( Res, Ord(nptInt) );
  end;
end; //*** end of K_ExprNStringsAdd ***

//********************************************** K_ExprNStringsSet ***
// SPL: function  StringsSet( Strings : TStrings; Ind : Integer; Str : String ) : Integer;
// if Ind = -1 Replace All By Text, Result >=0 - New List Length, =-1 Error (Ind >= List Length or List = nil)
//
procedure K_ExprNStringsSet( GC : TK_CSPLCont );
type  Params = packed record
  Strs  : TStrings;
  DType0 : TK_ExprExtType;
  Ind    : Integer;
  DType1 : TK_ExprExtType;
  Str    : string;
  DType2 : TK_ExprExtType;
end;

var
  PP : ^Params;
  Res : Integer;

begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Res := -1;
    if Strs <> nil then begin
      if Ind < 0 then
        Strs.Text := Str
      else if Ind < Strs.Count then
        Strs[Ind] := Str;
    end;
    Res := Strs.Count;
    GC.PutDataToExprStack( Res, Ord(nptInt) );
  end;
end; //*** end of K_ExprNStringsSet ***

//********************************************** K_ExprNStringsDel ***
// SPL: function  StringsDel( Strings : TStrings; Ind : Integer ) : Integer;
// if Ind = -1 Delete All, Result >=0 - New List Length, =-1 Error (Ind >= List Length)
//
procedure K_ExprNStringsDel( GC : TK_CSPLCont );
type  Params = packed record
  Strs  : TStrings;
  DType2 : TK_ExprExtType;
  Ind    : Integer;
  DType1 : TK_ExprExtType;
end;

var
  PP : ^Params;
  Res : Integer;

begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Res := -1;
    if Strs <> nil then begin
      if Ind < 0 then
        Strs.Clear()
      else if Ind < Strs.Count then
        Strs.Delete( Ind );
    end;
    Res := Strs.Count;
    GC.PutDataToExprStack( Res, Ord(nptInt) );
  end;
end; //*** end of K_ExprNStringsDel ***

//********************************************** K_ExprNStringsGet ***
// SPL: function  StringsGet( Strings : TStrings; Ind : Integer ) : String;
// if (List is out of bounds) or (List = nil) -  Result = ""
//
procedure K_ExprNStringsGet( GC : TK_CSPLCont );
type  Params = packed record
  Strs   : TStrings;
  DType2 : TK_ExprExtType;
  Ind    : Integer;
  DType1 : TK_ExprExtType;
end;

var
  PP : ^Params;
  Res : string;

begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Res := '';
    if (Strs <> nil) and
       (Ind >= 0)      and
       (Ind < Strs.Count) then
      Res := Strs[Ind];
    GC.PutDataToExprStack( Res, Ord(nptString) );
  end;
end; //*** end of K_ExprNStringsGet ***

//********************************************** K_ExprNStringsLength ***
// SPL: function  StringsLength( Strings : TStrings ) : Integer;
// Result - Current Strings Length, =-1 - Strings is nil
//
procedure K_ExprNStringsLength( GC : TK_CSPLCont );
type  Params = packed record
  Strs  : TStrings;
  DType2 : TK_ExprExtType;
end;

var
  PP : ^Params;
  Res : Integer;

begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Res := -1;
    if (Strs <> nil) then
      Res := Strs.Count;
    GC.PutDataToExprStack( Res, Ord(nptString) );
  end;
end; //*** end of K_ExprNStringsLength ***

//********************************************** K_ExprNStringsLoad ***
// SPL: function StringsLoad( PStringth : ^TStrings; FileName : String ) : Integer;
//
procedure K_ExprNStringsLoad( GC : TK_CSPLCont );
type  Params = packed record
  PStrs  : PTStrings;
  DType2 : TK_ExprExtType;
  FName  : string;
  DType1 : TK_ExprExtType;
end;

var
  PP : ^Params;
  FExt, EFName : string;
  Res : Integer;

begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    K_ExprNStringsPrepare( PStrs^, true );
    EFName := K_ExpandFileName(  FName );

//    if FileExists( EFName ) then begin
    if K_VFileExists( EFName ) then begin
// N_XLSToClipboard( AFileName: string; ASheetInd: integer = 1 )
      FExt := ExtractFileExt(EFName);
      if SameText( FExt, '.xls' ) then begin
        N_XLSToClipboard( EFName );
        PStrs^.Text := K_GetTextFromClipboard;
      end else
//        PStrs^.LoadFromFile( EFName );
        K_VFLoadStrings ( PStrs^, EFName );
      Res := PStrs^.Count;
    end else
      Res := -1;
    FName := ''; // free
    GC.PutDataToExprStack( Res, Ord(nptInt) );
 end;
end; //*** end of K_ExprNStringsLoad ***

//********************************************** K_ExprNStringsSave ***
// SPL: function  StringsSave( Strings  : TStrings; FileName: String; FileEncMode : TK_FileEncodeMode ) : Integer;
//
procedure K_ExprNStringsSave( GC : TK_CSPLCont );
type  Params = packed record
  Strings: TStrings;
  DType2 : TK_ExprExtType;
  FName  : string;
  DType1 : TK_ExprExtType;
  FileEncMode : TK_FileEncodeMode;
  DType3 : TK_ExprExtType;
end;

var
  PP : ^Params;
  EFName : string;
  Res : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    EFName := K_ExpandFileName(  FName );
    if K_StringsSaveToFile(EFName, Strings, FileEncMode) then
      Res := 0
    else
      Res := -1;
    FName := ''; // free
    GC.PutDataToExprStack( Res, Ord(nptInt) );
 end;
end; //*** end of K_ExprNStringsSave ***

//********************************************** K_ExprNCreateMVAtlasArchive
// SPL: procedure CreateMVAtlasArchive( FName : String; PUDB : ^TN_UDBase; UDCount : Integer );
//
procedure K_ExprNCreateMVAtlasArchive( GC : TK_CSPLCont );
type  Params = packed record
  FName  : string;
  DType0 : TK_ExprExtType;
  PUDB   : TN_PUDBase;
  DType1 : TK_ExprExtType;
  UDCount: Integer;
  DType2 : TK_ExprExtType;
end;

var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    K_BuildMVAFileFromCurArchUDObjs( FName, PUDB, UDCount );
    FName := '';
 end;
end; //*** end of K_ExprNCreateMVAtlasArchive

//********************************************** K_ExprNRunDFPLStrings
// SPL: function RunDFPLStrings( Commands : TStrings; Macros : TStrings;
//                               InstallPath : string; IniName : string;
//                               EncodeIniFile : Integer; SkipSaveIniFile : Integer ) : Integer;
// EncodeIniFile   <>0 true, =0 false
// SkipSaveIniFile <>0 true, =0 false
// Result - Warnings Count
//
procedure K_ExprNRunDFPLStrings( GC : TK_CSPLCont );
type  Params = packed record
  Commands : TStrings;
  DType0 : TK_ExprExtType;
  Macros : TStrings;
  DType1 : TK_ExprExtType;
  InstallPath : string;
  DType2 : TK_ExprExtType;
  IniName : string;
  DType3 : TK_ExprExtType;
  EncodeIniFile : Integer;
  DType4 : TK_ExprExtType;
  SkipSaveIniFile : Integer;
  DType5 : TK_ExprExtType;
end;

var
  PP : ^Params;
  Res : Integer;
  DFPLScriptExec : TK_DFPLScriptExec;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  DFPLScriptExec := TK_DFPLScriptExec.Create;
  DFPLScriptExec.OnShowInfo := GC.SelfShowDump;
  with PP^ do begin
    DFPLScriptExec.DFPLSetMacroList( Macros );
    DFPLScriptExec.CommandWarningsCount := 0;
    DFPLScriptExec.DFPLExecCommandsList( Commands, InstallPath, IniName,
                                     EncodeIniFile <> 0, SkipSaveIniFile <> 0 );
    InstallPath := ''; // free
    IniName := ''; // free
    Res := DFPLScriptExec.CommandWarningsCount;
    GC.PutDataToExprStack( Res, Ord(nptInt) );
  end;
  DFPLScriptExec.Free;
end; //*** end of K_ExprNRunDFPLStrings

//********************************************** K_ExprNSetUDFields ***
// SPL: function  SetUDFields( UD : TN_UDBase; Strings  : TStrings ) : Integer;
//
procedure K_ExprNSetUDFields( GC : TK_CSPLCont );
type  Params = packed record
  UDNode : TN_UDBase;
  DType1 : TK_ExprExtType;
  Strings: TStrings;
  DType2 : TK_ExprExtType;
end;

var
  PP : ^Params;
  Res : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    K_SerialTextBuf.TextStrings.Assign( Strings );
    Res := 0;
    try
      K_LoadFieldsFromText( UDNode,  K_SerialTextBuf );
    except
      Res := -1;
    end;
    UDNode.RebuildVNodes( 0 );
    GC.PutDataToExprStack( Res, Ord(nptInt) );
 end;
end; //*** end of K_ExprNSetUDFields ***

//********************************************** K_ExprNGetUDFields ***
// SPL: function  GetUDFields( UD : TN_UDBase; PStrings  : ^TStrings ) : Integer;
//
procedure K_ExprNGetUDFields( GC : TK_CSPLCont );
type  Params = packed record
  UDNode : TN_UDBase;
  DType1 : TK_ExprExtType;
  PStrs  : PTStrings;
  DType2 : TK_ExprExtType;
end;

var
  PP : ^Params;
  Res : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Res := 0;
    try
      K_SaveFieldsToText( UDNode,  K_SerialTextBuf );
      K_ExprNStringsPrepare( PStrs^, true );
      PStrs^.Assign( K_SerialTextBuf.TextStrings );
    except
      Res := -1;
    end;
    GC.PutDataToExprStack( Res, Ord(nptInt) );
 end;
end; //*** end of K_ExprNGetUDFields ***

//********************************************** K_ExprNMVImportTab ***
// SPL: function  MVImportTab( ITSFlags : TK_ImportTSFlags;
//        MVFolder : TN_UDBase; Strings : TStrings; SMF : TN_StrMatrFormat;
//        SourceFName : string; IniStrings : TStrings; PNodesList : ^TStrings ) : Integer;
//
procedure K_ExprNMVImportTab( GC : TK_CSPLCont );
type  Params = packed record
  ITSFlags : TK_ImportTSFlags;
  DType1 : TK_ExprExtType;
  MVFolder : TN_UDBase;
  DType2 : TK_ExprExtType;
  SL  : TStrings;
  DType3 : TK_ExprExtType;
  SMF : TN_StrMatrFormat;
  DType4 : TK_ExprExtType;
  SourceFName : string;
  DType5 : TK_ExprExtType;
  IniSL  : TStrings;
  DType6 : TK_ExprExtType;
  PNodesList : PTStrings;
  DType7 : TK_ExprExtType;
end;

var
  PP : ^Params;
  Res : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Res := -1;
    if K_MVImportTabByIniStrings( ITSFlags, MVFolder, SL, SMF, SourceFName, IniSL,
                      PNodesList, GC.ScriptShowMessage ) then
      Res := 0;
    SourceFName := '';
    GC.PutDataToExprStack( Res, Ord(nptInt) );
  end;
end; //*** end of K_ExprNMVImportTab ***

//********************************************** K_ExprNAppTerm ***
// SPL: procedure  ApplicationTerminate( );
//
procedure K_ExprNAppTerm( GC : TK_CSPLCont );

begin
  N_ApplicationTerminated := True; // is used in some OnFormDestroy handlers
  Application.Terminate;
end; //*** end of K_ExprNAppTerm ***

//********************************************** K_ExprNOpenCurArch ***
// SPL: function OpenCurArchive( FName : string ) : Integer;
//
procedure K_ExprNOpenCurArch( GC : TK_CSPLCont );
var
  FName : string;
  DType : TK_ExprExtType;
  Res : Integer;
begin
  GC.GetDataFromExprStack( FName, DType.All );
  if K_OpenCurArchive( K_ExpandFileName( FName ) ) then begin
    Res := 0;
    K_InitArchiveGCont( K_CurArchive );
  end else
    Res := -1;
  GC.PutDataToExprStack( Res, Ord(nptInt) );
end; //*** end of K_ExprNOpenCurArch ***

//********************************************** K_ExprNOpenCurArch1 ***
// SPL: function OpenCurArchive1( FName : string ) : Integer;
//
procedure K_ExprNOpenCurArch1( GC : TK_CSPLCont );
type  Params = packed record
  FName  : string;
  DType1 : TK_ExprExtType;
  Flags  : TK_UDTreeLSFlagSet;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  Res : Integer;

begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if K_OpenCurArchive( K_ExpandFileName( FName ), Flags ) then begin
      Res := 0;
      K_InitArchiveGCont( K_CurArchive );
    end else
      Res := -1;
    FName := '';
  end;
  GC.PutDataToExprStack( Res, Ord(nptInt) );
end; //*** end of K_ExprNOpenCurArch1 ***

//********************************************** K_ExprNSaveCurArch ***
// SPL: function SaveCurArchive( FName : string ) : Integer;
//
procedure K_ExprNSaveCurArch( GC : TK_CSPLCont );
var
  FName : string;
  DType : TK_ExprExtType;
  Res : Integer;
begin
  GC.GetDataFromExprStack( FName, DType.All );
  if FName <> '' then begin
    K_SetArchiveName( K_CurArchive, K_ExpandFileName( FName ) );
    K_GetPArchive(K_CurArchive).FNameIsNotDef := false;
  end;
  if not K_GetPArchive(K_CurArchive).FNameIsNotDef and
     K_SaveArchive( K_CurArchive, [K_lsfSkipJoinChangedSLSR,K_lsfDisjoinSLSR] ) then begin
    K_ClearArchiveChangeFlag;
//    K_SetArchiveChangeFlag( K_CurArchive, false );
    Res := 0;
  end else
    Res := -1;
  GC.PutDataToExprStack( Res, Ord(nptInt) );
end; //*** end of K_ExprNSaveCurArch ***

//********************************************** K_ExprNSaveCurArch1 ***
// SPL: function SaveCurArchive1( FName : string; Flags : TK_UDTreeLSFlagSet ) : Integer;
//
procedure K_ExprNSaveCurArch1( GC : TK_CSPLCont );
type  Params = packed record
  FName  : string;
  DType1 : TK_ExprExtType;
  Flags  : TK_UDTreeLSFlagSet;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  Res : Integer;

begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if FName <> '' then begin
      K_SetArchiveName( K_CurArchive, K_ExpandFileName( FName ) );
      K_GetPArchive(K_CurArchive).FNameIsNotDef := false;
    end;
    if not K_GetPArchive(K_CurArchive).FNameIsNotDef and
       K_SaveArchive( K_CurArchive, Flags ) then begin
      K_ClearArchiveChangeFlag;
      Res := 0;
    end else
      Res := -1;
    FName := '';
  end;
  GC.PutDataToExprStack( Res, Ord(nptInt) );
end; //*** end of K_ExprNSaveCurArch1 ***

//********************************************** K_ExprNCreateWebSite ***
// SPL: function CreateWebSite( WSite : TN_UDBase; FPath : string;
//   EncMode : TK_FileEncodeMode; WSPMode : TK_WebSitePackMode ) : Integer;
//
procedure K_ExprNCreateWebSite( GC : TK_CSPLCont );
type  Params = packed record
  WSite : TN_UDBase;
  DType1 : TK_ExprExtType;
  FPath : string;
  DType2 : TK_ExprExtType;
  EncMode : TK_FileEncodeMode;
  DType3 : TK_ExprExtType;
  WSPMode : TK_WebSitePackMode;
  DType4 : TK_ExprExtType;
end;

var
  PP : ^Params;
  Res : Integer;
  StartWObj : TN_UDBase;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  Res := -1;
  with PP^ do begin
    if WSite is TK_UDMVWSite then begin
      if WSite.DirHigh >= 0 then begin
        StartWObj := WSite.DirChild(0);
        with TK_WebSiteBuilder1.Create( EncMode ) do begin
          OnShowDump := GC.ScriptShowMessage;
          with TK_PMVWebSite(TK_UDRArray(WSite).R.P)^ do
            Res := BuildSite(FPath, StartWObj, UDWWinObj, UDWLayout, VWinName, Title, WSPMode );
          Free;
        end;
      end;
    end;
    FPath := '';
  end;
  GC.PutDataToExprStack( Res, Ord(nptInt) );
end; //*** end of K_ExprNCreateWebSite ***

//********************************************** K_ExprNCreateMSDoc ***
// SPL: function CreateMSDoc( WSite : TN_UDBase ) : Integer;
//  returns 0 if Document was created
//         -1 if some of WordfFragment Componenets are not specified
//         -2 if Command parameter is not TK_UDMVWSite
//         -3 if WSite child is not TK_UDMVWVTreeWin
//
procedure K_ExprNCreateMSDoc( GC : TK_CSPLCont );
type  Params = packed record
  WSite : TN_UDBase;
  DType1 : TK_ExprExtType;
end;

var
  PP : ^Params;
  Res : Integer;
  MSWDocBuilder : TK_MSWDocBuilder;
  UDMVWFolder : TN_UDBase;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    Res := -2;
    if WSite is TK_UDMVWSite then begin
      with TK_PMVWebSite(TK_UDMVWSite(WSite).R.P)^ do begin
        UDMVWFolder := WSite.DirChild(0).DirChild(0);
        Res := -3;
        if UDMVWFolder is TK_UDMVWFolder then begin
          MSWDocBuilder := TK_MSWDocBuilder.Create( );
          MSWDocBuilder.OnShowDump := GC.ScriptShowMessage;
          Res := MSWDocBuilder.CreateWSDocument1( UDMVWFolder, Title,
                            ResDocFName, TK_PMVMSWDVAttrs(K_GetPVRArray( MSWDVAttrs ).P),
                            STopicNumber  );
          MSWDocBuilder.Free;
        end;
      end;
    end;
  end;
  GC.PutDataToExprStack( Res, Ord(nptInt) );
end; //*** end of K_ExprNCreateMSDoc ***

//********************************************** K_ExprNSetArchUndoMode ***
// SPL: function  SetArchUndoMode( NewUndoState : Integer ) : Integer;
//
procedure K_ExprNSetArchUndoMode( GC : TK_CSPLCont );
type  Params = packed record
  UndoState : Integer;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
  Res : Integer;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  Res := 0;
  if K_SkipArchUndoMode then Res := 1;
  with PP^ do begin
    K_SkipArchUndoMode := UndoState <> 0;
    UndoState := Res;
    Inc( GC.ExprStackLevel, SizeOf(Params) );
  end;
end; //*** end of K_ExprNSetArchUndoMode ***

//********************************************** K_ExprNSelectFilePath ***
// SPL: function SelectFilePath( Pars : string; FilePath : string ) : string;
//
procedure K_ExprNSelectFilePath( GC : TK_CSPLCont );
type  Params = packed record
  Pars : string;
  DType1 : TK_ExprExtType;
  FilePath : string;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  FNE : TK_RAFFNameEditor1;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  FNE := TK_RAFFNameEditor1.Create;
  with PP^ do begin
    FNE.SetContext( Pars );
    Pars := FilePath;
    FilePath := ''; // free Stack string data
    FNE.Edit( Pars );
    Inc( GC.ExprStackLevel, SizeOf(string) + SizeOf(TK_ExprExtType) );
  end;
  FNE.Free;
end; //*** end of K_ExprNSelectFilePath ***

//********************************************** K_ExprNSetOpGetFromStack ***
// returns -1 if different Set Types, else Sets Type Power
//
function K_ExprNSetOpGetFromStack( GC : TK_CSPLCont; var PS1, PS2 : Pointer ) : Integer;
var
  DType1, DType2 : TK_ExprExtType;
begin
  GC.GetPointerToExprStackData( PS2, DType2.All );
  GC.GetPointerToExprStackData( PS1, DType1.All );
  if (((DType1.All xor DType2.All) and K_ffCompareTypesMask) <> 0) or
     (DType1.D.TFlags <> 0)                                        or
     (DType1.DTCode <= Ord(nptNoData))                             or
     (DType1.FD.FDObjType <> K_fdtSet) then   //*** Compare Sets
    Result := -1
  else
    Result := DType1.FD.FDFieldsCount;
end; //*** end of K_ExprNSetOpGetFromStack

//********************************************** K_ExprNSetOpGetFromStack1 ***
// returns -1 if different Set Types, else Sets Type Power
//
function K_ExprNSetOpGetFromStack1( GC : TK_CSPLCont; var PRS, PS1, PS2 : Pointer ) : Integer;
type  Params = packed record
  PRSet : Pointer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  Result := K_ExprNSetOpGetFromStack( GC, PS1, PS2 );
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
    if (Result >= 0) and
      (TK_PExprExtType(TN_BytesPtr(PS1) + ((Result + 7) shr 3)).DTCode = DType2.DTCode) then
        PRS := PRSet
      else
        Result := -1;
end; //*** end of K_ExprNSetOpGetFromStack1

//********************************************** K_ExprNSetOR ***
// SPL: function SetOR( PRSet : ^undef; Set1 : undef; Set2 : undef ) : Integer;
//  Returns -1 if wrong operands, else returns 0
//
procedure K_ExprNSetOR( GC : TK_CSPLCont );
var
  PRSet, PS1, PS2 : Pointer;
  DCount, Res : Integer;
begin
  DCount := K_ExprNSetOpGetFromStack1( GC, PRSet, PS1, PS2 );
  Res := -1;
  if DCount >= 0 then begin
    K_SetOp2( PRSet, PS1, PS2, DCount, K_sotOR );
    Res := 0;
  end;
  GC.PutDataToExprStack( Res, Ord(nptInt) );
end; //*** end of K_ExprNSetOR ***

//********************************************** K_ExprNSetAND ***
// SPL: function SetAND( PRSet : ^undef; Set1 : undef; Set2 : undef ) : Integer;
//  Returns -1 if wrong operands, else returns 0
//
procedure K_ExprNSetAND( GC : TK_CSPLCont );
var
  PRSet, PS1, PS2 : Pointer;
  DCount, Res : Integer;
begin
  DCount := K_ExprNSetOpGetFromStack1( GC, PRSet, PS1, PS2 );
  Res := -1;
  if DCount >= 0 then begin
    K_SetOp2( PRSet, PS1, PS2, DCount, K_sotAND );
    Res := 0;
  end;
  GC.PutDataToExprStack( Res, Ord(nptInt) );
end; //*** end of K_ExprNSetAND ***

//********************************************** K_ExprNSetClear ***
// SPL: function SetClear( PRSet : ^undef; Set1 : undef; Set2 : undef ) : Integer;
//  Returns -1 if wrong operands, else returns 0
//
procedure K_ExprNSetClear( GC : TK_CSPLCont );
var
  PRSet, PS1, PS2 : Pointer;
  DCount, Res : Integer;
begin
  DCount := K_ExprNSetOpGetFromStack1( GC, PRSet, PS1, PS2 );
  Res := -1;
  if DCount >= 0 then begin
    K_SetOp2( PRSet, PS1, PS2, DCount, K_sotCLEAR );
    Res := 0;
  end;
  GC.PutDataToExprStack( Res, Ord(nptInt) );
end; //*** end of K_ExprNSetClear ***

//********************************************** K_ExprNSetEQ ***
// SPL: function SetEQ( Set1 : undef; Set2 : undef ) : Integer;
//  Returns -1 if wrong operands or not equal Sets, else returns 0
//
procedure K_ExprNSetEQ( GC : TK_CSPLCont );
var
  PS1, PS2 : Pointer;
  DCount, Res : Integer;
begin
  DCount := K_ExprNSetOpGetFromStack( GC, PS1, PS2 );
  Res := -1;
  if (DCount >= 0) and
     CompareMem( PS1, PS2, (DCount + 7) shr 3 ) then   //*** Compare Sets
    Res := 0;
  GC.PutDataToExprStack( Res, Ord(nptInt) );
end; //*** end of K_ExprNSetEQ ***

//********************************************** K_ExprNSetLE ***
// SPL: function SetLE( Set1 : undef; Set2 : undef ) : Integer;
//  Returns -1 if wrong operands or Set1 is not Subset of Set2, else returns 0
//
procedure K_ExprNSetLE( GC : TK_CSPLCont );
var
  PS1, PS2 : Pointer;
  DCount, Res : Integer;
begin
  DCount := K_ExprNSetOpGetFromStack( GC, PS1, PS2 );
  Res := -1;
  if (DCount >= 0) and
     not K_SetOp2( nil, PS1, PS2, DCount, K_sotCLEAR ) then   //*** Compare Sets
//     K_SetSIsSubSet( PS1, PS2, DCount )  then   //*** Compare Sets
    Res := 0;
  GC.PutDataToExprStack( Res, Ord(nptInt) );
end; //*** end of K_ExprNSetLE ***

//********************************************** K_ExprNSetToInds ***
// SPL: function SetToInds( PArr:^ArrayOf Integer; Set:Undef ) : Integer;
//
procedure K_ExprNSetToInds( GC : TK_CSPLCont );
var
  PS : Pointer;
  PArr : TK_PRArray;
  Res : Integer;
  DType1, DType2 : TK_ExprExtType;
begin
  GC.GetPointerToExprStackData( PS, DType1.All );
  Res := -1;
  if (DType1.D.TFlags = 0)            and
     (DType1.DTCode > Ord(nptNoData)) and
     (DType1.FD.FDObjType = K_fdtSet) then  // Check Set Operand Type
    Res := DType1.FD.FDFieldsCount;
  GC.GetDataFromExprStack( PArr, DType2.All );
  if (Res >= 0) then begin
    if PArr^ = nil then // Create
      PArr^ := K_RCreateByTypeCode( Ord(nptInt), Res )
    else
      PArr^.ASetLength( Res );

    Res := K_SetToInds( PInteger(PArr^.P), PS, Res, 0 );
    PArr^.ASetLength( Res );
  end;
  GC.PutDataToExprStack( Res, Ord(nptInt) );
end; //*** end of K_ExprNSetToInds ***

var K_ExprNIndIteratorTypeCode : TK_ExprExtType;
//********************************************** K_ExprNCreateIndIterator ***
// SPL: function CreateIndIterator( ) : TK_IndIterator;
//
procedure K_ExprNCreateIndIterator( GC : TK_CSPLCont );
var
  II : TK_IndIterator;
begin
  if K_ExprNIndIteratorTypeCode.All = 0 then
    K_ExprNIndIteratorTypeCode := K_GetExecTypeCodeSafe( 'TK_IndIterator' );
  II := TK_IndIterator.Create;
  GC.PutDataToExprStack( II, K_ExprNIndIteratorTypeCode.All );
end; //*** end of K_ExprNCreateIndIterator ***

//********************************************** K_ExprNAddIIDim ***
// SPL: procedure AddIIDim( II : TK_IndIterator; PResInd : ^Integer; DimSize : Integer );
//
procedure K_ExprNAddIIDim( GC : TK_CSPLCont );
type  Params = packed record
  II : TK_IndIterator;
  DType1 : TK_ExprExtType;
  PResInd : Pointer;
  DType2 : TK_ExprExtType;
  DimSize : Integer;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
    II.AddIIDim( PResInd, DimSize );
end; //*** end of K_ExprNAddIIDim ***

//********************************************** K_ExprNPrepIILoop ***
// SPL: procedure PrepIILoop( II : TK_IndIterator; LCount : Integer; ISeed : Integer );
//
procedure K_ExprNPrepIILoop( GC : TK_CSPLCont );
type  Params = packed record
  II : TK_IndIterator;
  DType1 : TK_ExprExtType;
  LCount : Integer;
  DType2 : TK_ExprExtType;
  ISeed : Integer;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
    II.PrepIILoop( LCount, ISeed );
end; //*** end of K_ExprNPrepIILoop ***

//********************************************** K_ExprNGetNextIInds ***
// SPL: procedure GetNextIInds( II : TK_IndIterator );
//
procedure K_ExprNGetNextIInds( GC : TK_CSPLCont );
type  Params = packed record
  II : TK_IndIterator;
  DType1 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
    II.GetNextIInds;
end; //*** end of K_ExprNGetNextIInds ***

//********************************************** K_ExprNBuildCNKSets ***
// SPL: procedure BuildCNKSets( PSetsArr : ^ArrayOf undef; K : Integer );
//
procedure K_ExprNBuildCNKSets( GC : TK_CSPLCont );
type  Params = packed record
  PSetsArr: TK_PRArray;
  DType1  : TK_ExprExtType;
  K: Integer;
  DType2 : TK_ExprExtType;
end;
var
  PP : ^Params;
  SStep : Integer;
  CNK : Integer;
  N : Integer;
  EType : TK_ExprExtType;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    PSetsArr^.ASetLength( 0 );
    if (DType1.DTCode <= Ord(nptNoData))and
       (DType1.FD.FDObjType <> K_fdtSet) then  Exit; // Wrong Sets Array Type
    N := DType1.FD.FDFieldsCount;
    SStep := DType1.FD.FDRecSize;
    CNK := K_CalcCNK( N, K );
    EType := DType1;
    EType.D.TFlags := 0;
    if PSetsArr^ = nil then // Create Array
      PSetsArr^ := K_RCreateByTypeCode( EType.All, CNK )
    else
      PSetsArr^.ASetLength( CNK );
    K_BuildCNKSets( PSetsArr^.P, SStep, N, K );
  end;
end; //*** end of K_ExprNBuildCNKSets

type TK_SetsClearCondition = (
  K_sccNotSuperSet,   // = "Не является надмножеством"
  K_sccNoIntersection // = "Не содержит общих элементов"
  );

//********************************************** K_ExprNClearSetsBySets ***
// SPL: function ClearSetsBySets( SetsArr : ArrayOf undef; CondsArr : ArrayOf undef; ClearCondition : TK_SetsClearCondition  ) : Integer;
//
procedure K_ExprNClearSetsBySets( GC : TK_CSPLCont );
type  Params = packed record
  SetsArr  : TK_RArray;
  DType1   : TK_ExprExtType;
  CondsArr : TK_RArray;
  DType2   : TK_ExprExtType;
  ClearCondition : TK_SetsClearCondition;
  DType3 : TK_ExprExtType;
end;
var
  PP : ^Params;
  SStep, N : Integer;
  Inds : TN_IArray;
  Res : Integer;
  TestSetsFunc : TK_TestSetsFunc;
begin
  PP := GC.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do begin
    if (((DType1.All xor DType2.All) and K_ffCompareTypesMask) <> 0) or
       (DType1.DTCode <= Ord(nptNoData))                             or
       (DType1.FD.FDObjType <> K_fdtSet) then   //*** Compare Sets
      Res := -1
    else begin
      Res := SetsArr.ALength;
      SetLength( Inds, Res );
      N := DType1.FD.FDFieldsCount;
      SStep := DType1.FD.FDRecSize;

      case ClearCondition of
      K_sccNotSuperSet    : TestSetsFunc := K_TestIfSetIsNotSuperSet;
      K_sccNoIntersection : TestSetsFunc := K_TestIfSetHasNoIntersects;
      else
        TestSetsFunc := nil;
      end;

      if Assigned(TestSetsFunc) then begin
        Res := K_BuildProperSetsInds( @Inds[0], SetsArr.P, SStep, Res,
                                   CondsArr.P, SStep, CondsArr.ALength, N,
                                   TestSetsFunc );
        if Res < SetsArr.ALength then begin// Skip Unproper Sets
          K_MoveVectorBySIndex( SetsArr.P^, SStep, SetsArr.P^, SStep, SStep,
                                Res, @Inds[0] );
          SetsArr.ASetLength( Res );
        end;
      end;


    end;
    SetsArr.ARelease;
    CondsArr.ARelease;
    GC.PutDataToExprStack( Res, Ord(nptInt) );
  end;
end; //*** end of K_ExprNClearSetsBySets

end.
