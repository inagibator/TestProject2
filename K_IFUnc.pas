unit K_IFunc;

interface

uses Windows, SysUtils, Classes, Grids, Graphics,
  K_Script1;


procedure K_StringsSetFromMem( slist : TStrings; StartLInd : Integer;
        const MemValues; MemStep, Count : Integer;
        VType : TK_ExprExtType; PSortedIndex : PInteger = nil;
        fmt : string = '';
        ValueToStrFlags : TK_ValueToStrFlags = [] );
procedure K_StringsGetToMem( slist : TStrings; StartLInd : Integer;
        var MemValues; MemStep, Count : Integer;
        VType : TK_ExprExtType;
        const PDefVal : Pointer = nil; MDFlags : TK_MoveDataFlags = [];
        PSortedIndex : PInteger = nil );
procedure K_SetStringsFromRArray( SList : TStrings; LInd : Integer;
        const Values : TK_RArray; VInd : Integer; Count : Integer = -1;
        SortedIndex : TK_RArray = nil; FShift : Integer = 0; fmt : string = '' );
procedure K_GetStringsToRArray( SList : TStrings; LInd : Integer;
        const Values : TK_RArray; VInd : Integer; Count : Integer = -1;
        SortedIndex : TK_RArray = nil; FShift : Integer = 0 );
procedure K_StringGridCalcColWidth( SG : TStringGrid; Col : Integer;
                                    MaxWidth : Integer = 0; Delta : Integer = 16 );
//procedure K_MakePath( APath : string );

implementation

uses Clipbrd, Math,
     N_Types;

//********************************************* K_StringsSetFromMem
//  set TStrings elements from Memory
//
procedure K_StringsSetFromMem( slist : TStrings; StartLInd : Integer;
        const MemValues; MemStep, Count : Integer;
        VType : TK_ExprExtType; PSortedIndex : PInteger = nil;
        fmt : string = '';
        ValueToStrFlags : TK_ValueToStrFlags = [] );
var
  i : Integer;
  vp : string;
  PVal : TN_BytesPtr;
  PVal0 : TN_BytesPtr;
begin

  PVal0 := @MemValues;
  PVal := PVal0 - MemStep;
  for i := 1 to Count do  begin
    if PSortedIndex = nil then
      Inc( PVal , MemStep )
    else begin
      PVal := PVal0 + MemStep * PSortedIndex^;
      Inc( TN_BytesPtr(PSortedIndex), SizeOf(Integer) );
    end;
    vp := K_SPLValueToString( PVal^, VType, ValueToStrFlags, fmt  );
    if StartLInd >= slist.Count then
      slist.add( vp )
    else
      slist[StartLInd] := vp;
    Inc(StartLInd);
  end;
end;

//********************************************* K_StringsGetToMem
//  get TStrings elements values to  Memory
//
procedure K_StringsGetToMem( slist : TStrings; StartLInd : Integer;
        var MemValues; MemStep, Count : Integer;
        VType : TK_ExprExtType;
        const PDefVal : Pointer = nil; MDFlags : TK_MoveDataFlags = [];
        PSortedIndex : PInteger = nil );
var
 i : Integer;
 PVal : TN_BytesPtr;
 PVal0 : TN_BytesPtr;
begin

  PVal0 := @MemValues;
  PVal := PVal0 - MemStep;
  for i := 1 to Count do  begin
    if PSortedIndex = nil then
      Inc( PVal , MemStep )
    else begin
      PVal := PVal0 + MemStep * PSortedIndex^;
      Inc( TN_BytesPtr(PSortedIndex), SizeOf(Integer) );
    end;
    if PDefVal <> nil then
      K_MoveSPLData( PDefVal^, PVal^, VType, MDFlags )
    else if K_mdfFreeDest in MDFlags then
      K_FreeSPLData( PVal^, VType.All, K_mdfCountUDRef in MDFlags  );
    K_SPLValueFromString( PVal^, VType.All, Trim(slist[StartLInd]) );
//    K_SPLValueFromString( PVal^, VType, Trim(slist[StartLInd]) );
    Inc(StartLInd);
  end;
end;

//********************************************* K_SetStringsFromRArray ***
//  set TStrings elements from RArray
//
procedure K_SetStringsFromRArray( SList : TStrings; LInd : Integer;
        const Values : TK_RArray; VInd : Integer; Count : Integer = -1;
        SortedIndex : TK_RArray = nil; FShift : Integer = 0; fmt : string = '' );
var
  PData : TN_BytesPtr;
  PSortedIndex : PInteger;
  DInd, IInd : Integer;

  procedure CalcCount( RA : TK_RArray );
  begin
    if Count < 0 then Count := RA.ALength;
      Count := Min( Count,  RA.ALength - VInd );
  end;

begin
  if SortedIndex <> nil then begin
    DInd := 0;
    IInd := VInd;
    CalcCount( SortedIndex );
  end else begin
    DInd := VInd;
    IInd := 0;
    CalcCount( Values );
  end;
  PSortedIndex := SortedIndex.P(IInd);
  PData := TN_BytesPtr( Values.P(DInd) ) + FShift;

  K_StringsSetFromMem( SList, LInd, PData^, Values.ElemSize, Count,
        Values.ElemType, PSortedIndex, fmt );
end; //*** end of procedure K_SetStringsFromRArray

//********************************************* K_GetStringsToRArray ***
//  get RArray elemnets from TStrings elements
//
procedure K_GetStringsToRArray( SList : TStrings; LInd : Integer;
        const Values : TK_RArray; VInd : Integer; Count : Integer = -1;
        SortedIndex : TK_RArray = nil; FShift : Integer = 0 );
var
  PData : TN_BytesPtr;
  PSortedIndex : PInteger;
  DInd, IInd : Integer;

  procedure CalcCount( RA : TK_RArray );
  begin
    if Count < 0 then Count := RA.ALength;
      Count := Min( Count,  RA.ALength - VInd );
  end;

begin
  if Count < 0 then Count := SList.Count;
  if SortedIndex <> nil then begin
    DInd := 0;
    IInd := VInd;
    CalcCount( SortedIndex );
  end else begin
    DInd := VInd;
    IInd := 0;
    CalcCount( Values );
  end;

  PSortedIndex := SortedIndex.P(IInd);
  PData := TN_BytesPtr( Values.P(DInd) ) + FShift;

  K_StringsGetToMem( SList, LInd, PData^, Values.ElemSize, Count,
        Values.ElemType,  nil, [K_mdfFreeDest],
        PSortedIndex );

end; //*** end of procedure K_GetStringsToRArray

//********************************************* K_StringGridCalcColWidth ***
//  Calculate column Width
//
procedure K_StringGridCalcColWidth( SG : TStringGrid; Col : Integer;
                                    MaxWidth : Integer = 0; Delta : Integer = 16 );
var H, i : Integer;
begin
  H := SG.RowCount - 1;
  for i := 0 to H  do
    MaxWidth := Max( MaxWidth, SG.Canvas.TextWidth(SG.Cells[Col, i]) );
  SG.ColWidths[Col] := MaxWidth + Delta;
end;

end.
