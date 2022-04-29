unit K_SBuf0;
// serialization methods and structures

// type TN_SerialBuf0 = class( TObject ) //***** SerialBuf class

interface

type
  TK_BArray = array of Byte;
  Float = Single;
  PFloat = ^Float;
//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0
//*********************************************************** TN_SerialBuf0 ***
// Binary Buffer for Data Serialization class
//
// Is used for IDB Data Binary Serialization
//
type TN_SerialBuf0 = class( TObject )
    public
  Buf1: TK_BArray;    // bufer for storing serialized objects
  Capacity: integer;  // size of buffer
  OfsFree: integer;   // Offset to first free byte in Buffer (while data 
                      // serialization)
  CurOfs:  integer;   // current offset while deserializing data from serial 
                      // buffer

  SBAddWideString : Boolean; // Add Wide Serialized strings (two bytes per char 
                             // in AddRowString method)
  SBGetWideString : Boolean; // Get from Wide Serialized strings (two bytes per 
                             // char in GetRowString method)
  SBMinCapacity   : Integer;
//##/*

  constructor Create;
  destructor  Destroy; override;
//##*/

  procedure Init( ASkipCapacityChange : Boolean = false );
  procedure SetCapacity( ANewCapacity : Integer );
  procedure IncCapacity( AIncVal : Integer );
  function  POffset( AOffset : Integer ) : Pointer;
  function  PFree() : Pointer;
  function  PCur() : Pointer;
  function  SetCurOffset( ACurOffset : Integer ) : Boolean;
  function  ShiftFreeOffset( AShift : Integer ) : Boolean;
  procedure SetDataFromMem( var AMem; ACount : Integer );
  function  GetDataToBArray( ) : TK_BArray;

  procedure AddRowInt  ( AData: Integer );
  procedure GetRowInt  ( out AData: integer );

  procedure AddRowDouble  ( AData: Double );
  procedure GetRowDouble  ( out AData: Double );

  procedure AddRowFloat  ( AData: Float );
  procedure GetRowFloat  ( out AData: Float );

  procedure AddRowString ( const AStr: String );
  procedure GetRowString ( var AStr: String );

  procedure AddRowBytes ( const ACount: integer; const APBytes: Pointer);
  procedure GetRowBytes ( const ACount: integer; const APBytes: Pointer);

  procedure AddRowSInts ( const ACount, AStep: integer; const APInt: Pointer );
  procedure GetRowSInts ( const ACount, AStep: integer; const APInt: Pointer );

  procedure AddRowSFloats( const ACount, AStep: integer;
                                                      const APFloat: Pointer );
  procedure GetRowSFloats( const ACount, AStep: integer;
                                                      const APFloat: Pointer );
end; //*** end of type TN_SerialBuf0 = class( TObject )

//****************** Global procedure **********************


type
  TN_StringToWide = function ( AString : string ) : WideString;
  TN_StringToAnsi = function ( AString : string ) : AnsiString;
  TN_WideToString = function ( AWString : WideString ) : string;
  TN_AnsiToString = function ( AString : AnsiString ) : string;
  TK_CalcCapacity = function  ( NLeng : Integer; var Capacity : Integer ) : Boolean;
var
  K_S2W : TN_StringToWide;
  K_S2A : TN_StringToAnsi;
  K_W2S : TN_WideToString;
  K_A2S : TN_AnsiToString;
  K_CalcNewCapacity : TK_CalcCapacity;
  K_SBufMaxCapacity : Integer = 100000000;

implementation
{
//*********************************************************** K_NewCapacity ***
// Calculate new array capacity using realy needed array length
//
//     Parameters
// NewLeng  - needed array length
// Capacity - array length (capacity) needed to decrease memory reallocations
// Result   - Returns true if capacity is enlarged
//
function  K_NewCapacity( NewLeng : Integer; var Capacity : Integer ) : Boolean;
var Delta : Integer;
begin
  Result := true;
//  Capacity := 0;
  if NewLeng < 0 then Exit;
  if NewLeng > Capacity then begin
    if (NewLeng > 64) then begin
      if      NewLeng <  10000000 then
        Delta := NewLeng div 4
      else if NewLeng <  50000000 then
        Delta := 2000000 + NewLeng div 20
      else if NewLeng < 100000000 then
        Delta := 4000000 + NewLeng div 100
      else
        Delta := 5000000;
    end else if (NewLeng > 8) then
      Delta := 16
    else
      Delta := 4;
    Capacity := NewLeng + Delta;
  end else
    Result := false;
end; // end of K_NewCapacity
}
//************************************************ TN_SerialBuf0.Create ***
//
constructor TN_SerialBuf0.Create;
begin
  Inherited;
  Init();
end; //*** end of Constructor TN_SerialBuf0.Create

//************************************************ TN_SerialBuf0.Destroy ***
//
destructor TN_SerialBuf0.Destroy;
begin
  Buf1 := nil;
  Inherited;
end; //*** end of destructor TN_SerialBuf0.Destroy

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\Init
//****************************************************** TN_SerialBuf0.Init ***
// Init buffer data before serialization
//
//     Parameters
// ASkipCapacityChange - if =TRUE then current buffer capacity will not be 
//                       changed
//
procedure TN_SerialBuf0.Init( ASkipCapacityChange : Boolean = false );
begin
  if not ASkipCapacityChange and (Capacity > K_SBufMaxCapacity) then
  begin
    Buf1 := nil;      // Free Maximal Buffer
    SetCapacity( -1 );
  end;
  OfsFree := SBMinCapacity;
  CurOfs := SBMinCapacity;

end; //*** end of procedure TN_SerialBuf0.Init

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\SetCapacity
//*********************************************** TN_SerialBuf0.SetCapacity ***
// Set buffer capacity new value (resize if neccessary)
//
//     Parameters
// ANewCapacity - buffer capacity new value
//
procedure TN_SerialBuf0.SetCapacity( ANewCapacity : Integer );
var PrevCapacity : Integer;
begin
  if ANewCapacity < 0 then
  begin
    ANewCapacity := -ANewCapacity;
    Capacity := 0;
  end;
  if ANewCapacity < SBMinCapacity then ANewCapacity := SBMinCapacity;
  PrevCapacity := Capacity;
//  if K_NewCapacity( ANewCapacity, Capacity ) then
  if K_CalcNewCapacity( ANewCapacity, Capacity ) then
  begin
    SetLength(Buf1, Capacity);
    FillChar(Buf1[PrevCapacity], Capacity - PrevCapacity, 0);
  end;
end; //*** end of procedure TN_SerialBuf0.SetCapacity

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\IncCapacity
//*********************************************** TN_SerialBuf0.IncCapacity ***
// Increment buffer capacity
//
//     Parameters
// AIncVal - increment buffer capacity value
//
procedure TN_SerialBuf0.IncCapacity( AIncVal : Integer );
begin
  SetCapacity( OfsFree + AIncVal );
end; //*** end of procedure TN_SerialBuf0.IncCapacity

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\POffset
//*************************************************** TN_SerialBuf0.POffset ***
// Get pointer to buffer position by buffer offset
//
//     Parameters
// AOffset - buffer offset in bytes
// Result  - Returns pointer to given buffer position
//
function  TN_SerialBuf0.POffset( AOffset : Integer ) : Pointer;
begin
  Result := @Buf1[AOffset];
end; //*** end of procedure TN_SerialBuf0.POffset

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\PFree
//***************************************************** TN_SerialBuf0.PFree ***
// Get pointer to free buffer position
//
//     Parameters
// Result - Returns pointer to free buffer position
//
function  TN_SerialBuf0.PFree() : Pointer;
begin
  Result := @Buf1[OfsFree];
end; //*** end of procedure TN_SerialBuf0.PFree

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\PCur
//****************************************************** TN_SerialBuf0.PCur ***
// Get pointer to current buffer position
//
//     Parameters
// Result - Returns pointer to current buffer position
//
function  TN_SerialBuf0.PCur() : Pointer;
begin
  Result := @Buf1[CurOfs];
end; //*** end of procedure TN_SerialBuf0.PCur

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\SetCurOffset
//********************************************** TN_SerialBuf0.SetCurOffset ***
// Set current buffer position
//
//     Parameters
// Result - Returns TRUE if new buffer position is set
//
function  TN_SerialBuf0.SetCurOffset( ACurOffset : Integer ) : Boolean;
begin

  Result := (ACurOffset >= SBMinCapacity) and (ACurOffset < OfsFree);
  if not Result then Exit;
  CurOfs := ACurOffset;
end; //*** end of procedure TN_SerialBuf0.SetCurOffset

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\ShiftFreeOffset
//******************************************* TN_SerialBuf0.ShiftFreeOffset ***
// Shift free buffer position
//
//     Parameters
// Result - Returns TRUE if new buffer position is set
//
function  TN_SerialBuf0.ShiftFreeOffset( AShift : Integer ) : Boolean;
var
  NewOffs : Integer;
begin
  NewOffs := OfsFree + AShift;
  Result := (NewOffs >= SBMinCapacity) and (NewOffs <= Capacity);
  if not Result then Exit;
  OfsFree := NewOffs;
end; //*** end of procedure TN_SerialBuf0.SetFreeOffset

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\SetDataFromMem
//******************************************** TN_SerialBuf0.SetDataFromMem ***
// Set serialized data from given memory location to buffer
//
//     Parameters
// AMem   - given memory location
// ACount - data length
//
procedure TN_SerialBuf0.SetDataFromMem( var AMem; ACount : Integer );
begin
  SetCapacity( ACount );
  Move( AMem, Buf1[0], ACount );
  CurOfs := SBMinCapacity;
  OfsFree := ACount;
end; //*** end of procedure TN_SerialBuf0.SetDataFromMem

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\GetDataToBArray
//******************************************* TN_SerialBuf0.GetDataToBArray ***
// Get serialized data from given memory to Resulting Bytes Array
//
//     Parameters
// AMem   - given memory location
// ACount - data length
//
function  TN_SerialBuf0.GetDataToBArray( ) : TK_BArray;
begin
  Result := Copy( Buf1, 0, OfsFree );
end; //*** end of procedure TN_SerialBuf0.GetDataToBArray

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\AddRowInt
//************************************************* TN_SerialBuf0.AddRowInt ***
// Add given Integer value
//
//     Parameters
// AData - given Integer value
//
procedure TN_SerialBuf0.AddRowInt( AData: Integer );
begin
  IncCapacity(SizeOf(Integer));
  PInteger(PFree())^ := AData;
  Inc(OfsFree, SizeOf(integer));
end; //*** end of procedure TN_SerialBuf0.AddRowInt

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\GetRowInt
//************************************************* TN_SerialBuf0.GetRowInt ***
// Get one Integer value
//
//     Parameters
// AData - resulting Integer value
//
procedure TN_SerialBuf0.GetRowInt( out AData: integer );
begin
  AData := PInteger(POffset(CurOfs))^;
  Inc(CurOfs, SizeOf(integer));
end; //*** end of procedure TN_SerialBuf0.GetRowInt

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\AddRowDouble
//********************************************** TN_SerialBuf0.AddRowDouble ***
// Add given Double value
//
//     Parameters
// AData - given Double value
//
procedure TN_SerialBuf0.AddRowDouble( AData: Double );
begin
  IncCapacity(SizeOf(Double));
  PDouble(PFree())^ := AData;
  Inc(OfsFree, SizeOf(Double));
end; //*** end of procedure TN_SerialBuf0.AddRowDouble

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\GetRowDouble
//********************************************** TN_SerialBuf0.GetRowDouble ***
// Get one Double value
//
//     Parameters
// AData - resulting Double value
//
procedure TN_SerialBuf0.GetRowDouble( out AData: Double );
begin
  AData := PDouble(POffset(CurOfs))^;
  Inc(CurOfs, SizeOf(Double));
end; //*** end of procedure TN_SerialBuf0.GetRowDouble

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\AddRowFloat
//*********************************************** TN_SerialBuf0.AddRowFloat ***
// Add given Float value
//
//     Parameters
// AData - given Float value
//
procedure TN_SerialBuf0.AddRowFloat  ( AData: Float );
begin
  IncCapacity(SizeOf(Float));
  PFloat(PFree())^ := AData;
  Inc(OfsFree, SizeOf(Float));
end; //*** end of procedure TN_SerialBuf0.AddRowFloat

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\GetRowFloat
//*********************************************** TN_SerialBuf0.GetRowFloat ***
// Get one Float value
//
//     Parameters
// AData - resulting Float value
//
procedure TN_SerialBuf0.GetRowFloat  ( out AData: Float );
begin
  AData := PFloat(POffset(CurOfs))^;
  Inc(CurOfs, SizeOf(Float));
end; //*** end of procedure TN_SerialBuf0.GetRowFloat

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\AddRowString
//********************************************** TN_SerialBuf0.AddRowString ***
// Add given String value
//
//     Parameters
// AData - given String value
//
procedure TN_SerialBuf0.AddRowString( const AStr: string );
var
  NumBytes: integer;
  AnsiBufStr : AnsiString;
  WideBufStr : WideString;
begin
  AnsiBufStr := ''; // to avoid warning in Delhi 7
  WideBufStr := ''; // to avoid warning in Delhi 2010
  NumBytes := Length(AStr);
  if SBAddWideString then
    NumBytes := NumBytes * SizeOf( Char );
  IncCapacity( NumBytes + sizeof(Integer) + 1 );

  if NumBytes < 255 then
  begin
    Buf1[OfsFree] := Byte( NumBytes );
    Inc(OfsFree);
    if NumBytes = 0 then Exit; // empty string
  end // if NumBytes < 255 then
  else
  begin // if NumBytes >= 255 then
    Buf1[OfsFree] := 255;
    Inc(OfsFree);
    AddRowInt( NumBytes );
  end;  // if NumBytes >= 255 then

  if SBAddWideString then
  begin // in SBuf should be Wide Strings
    if SizeOf( Char ) = 2 then
    begin // Wide to Wide
      Move( AStr[1], PFree()^, NumBytes );
    end
    else
    begin  // Ansi to Wide
//      WideBufStr := AStr;
//      WideBufStr := N_StringToWide( AStr );
      WideBufStr := K_S2W( AStr );
      Move( WideBufStr[1], PFree()^, NumBytes );
    end;
  end // if SBAddWideString then
  else
  begin // in SBuf should be Ansi Strings
    if SizeOf( Char ) = 2 then
    begin // Wide to Ansi
//      AnsiBufStr := AnsiString(AStr);
//      AnsiBufStr := N_StringToAnsi( AStr );
      AnsiBufStr := K_S2A( AStr );
      Move( AnsiBufStr[1], PFree()^, NumBytes );
    end
    else
    begin  // Ansi to Ansi
      Move( AStr[1], PFree()^, NumBytes );
    end;
  end; // // in SBuf should be Ansi Strings

  Inc( OfsFree, NumBytes );
end; //*** end of procedure TN_SerialBuf0.AddRowString

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\GetRowString
//********************************************** TN_SerialBuf0.GetRowString ***
// Get one String value
//
//     Parameters
// AData - resulting String value
//
procedure TN_SerialBuf0.GetRowString( var AStr: string );
var
  NumBytes: integer;
  AnsiBufStr : AnsiString;
  WideBufStr : WideString;
begin
  AnsiBufStr := ''; // to avoid warning in Delhi 7
  WideBufStr := ''; // to avoid warning in Delhi 2010
  NumBytes := Buf1[CurOfs];
  Inc( CurOfs );

  if NumBytes = 0 then begin // empty string
    SetLength( AStr, 0 );
    Exit;
  end else if NumBytes = 255 then begin
    NumBytes := PInteger(@Buf1[CurOfs])^;
    Inc( CurOfs, Sizeof(integer) );
  end;

  if SBGetWideString then begin // SBuf contains Wide Strings
    if SizeOf( Char ) = 2 then begin // Wide to Wide
      SetLength( AStr, NumBytes shr 1 ); // NumChars = NumBytes div 2
      Move( Buf1[CurOfs], AStr[1], NumBytes );
    end else begin  // Wide to Ansi
      SetLength( WideBufStr, NumBytes shr 1 );
      Move( Buf1[CurOfs], WideBufStr[1], NumBytes );
//      AStr := WideBufStr;
//      AStr := N_WideToString( WideBufStr );
      AStr := K_W2S( WideBufStr );
    end;
  end else begin // SBuf contains Ansi Strings
    if SizeOf( Char ) = 2 then begin // Ansi to Wide
      SetLength( AnsiBufStr, NumBytes );
      Move( Buf1[CurOfs], AnsiBufStr[1], NumBytes );
//      AStr := string(AnsiBufStr);
//      AStr := N_AnsiToString( AnsiBufStr );
      AStr := K_A2S( AnsiBufStr );
    end else begin  // Ansi to Ansi
      SetLength( AStr, NumBytes );
      Move( Buf1[CurOfs], AStr[1], NumBytes );
    end;
  end;

  Inc( CurOfs, NumBytes );
end; //*** end of procedure TN_SerialBuf0.GetRowString

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\AddRowBytes
//*********************************************** TN_SerialBuf0.AddRowBytes ***
// Add given number of Bytes
//
//     Parameters
// ACount  - number of bytes
// APBytes - pointer to first byte
//
procedure TN_SerialBuf0.AddRowBytes( const ACount: integer; const APBytes: Pointer);
begin
  if ACount = 0 then Exit;
  IncCapacity( ACount );
  move( APBytes^, Buf1[OfsFree], ACount );
  Inc(OfsFree, ACount);
end; //*** end of procedure TN_SerialBuf0.AddRowBytes

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\GetRowBytes
//*********************************************** TN_SerialBuf0.GetRowBytes ***
// Get given number of Bytes
//
//     Parameters
// ACount  - number of bytes
// APBytes - pointer to first byte
//
procedure TN_SerialBuf0.GetRowBytes( const ACount: integer; const APBytes: Pointer);
begin
  if ACount = 0 then Exit;
  move( POffset(CurOfs)^, APBytes^, ACount );
  Inc(CurOfs, ACount);
end; //*** end of procedure TN_SerialBuf0.GetRowBytes

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\AddRowSInts
//*********************************************** TN_SerialBuf0.AddRowSInts ***
// Add given number of Integers
//
//     Parameters
// ACount  - number of Integers
// AStep   - step between neighbour Integers in bytes
// APBytes - pointer to first Integer
//
procedure TN_SerialBuf0.AddRowSInts( const ACount, AStep: integer;
                                                        const APInt: Pointer );
var
  i, DataSize: integer;
  pinp, pbuf: PInteger;
begin
  DataSize := ACount * SizeOf(integer);
  IncCapacity( DataSize );
  pinp := APInt;
  pbuf := PInteger(Integer(POffset(0))+OfsFree);
  for i := 0 to ACount-1 do begin
    pbuf^ := pinp^; Inc(pbuf);
    pinp := PInteger( integer(pinp) + AStep );
  end;
  Inc(OfsFree, DataSize);
end; //*** end of procedure TN_SerialBuf0.AddRowSInts

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\GetRowSInts
//*********************************************** TN_SerialBuf0.GetRowSInts ***
// Get given number of Integers
//
//     Parameters
// ACount  - number of Integers
// AStep   - step between neighbour Integers in bytes
// APBytes - pointer to first Integer
//
procedure TN_SerialBuf0.GetRowSInts( const ACount, AStep: integer;
                                                        const APInt: Pointer );
var
  i, DataSize: integer;
  pout, pbuf: PInteger;
begin
  DataSize := ACount*SizeOf(Integer);
  pout := APInt;
  pbuf := PInteger(POffset(CurOfs));
  for i := 0 to ACount-1 do begin
    pout^ := pbuf^; Inc(pbuf);
    pout := PInteger( Integer(pout) + AStep );
  end;
  Inc(CurOfs, DataSize);
end; //*** end of procedure TN_SerialBuf0.GetRowSInts

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\AddRowSFloats
//********************************************* TN_SerialBuf0.AddRowSFloats ***
// Add given number of Floats
//
//     Parameters
// ACount   - number of Floats
// AStep    - step between neighbour Floats in bytes
// APDouble - pointer to first Float
//
procedure TN_SerialBuf0.AddRowSFloats( const ACount, AStep: integer;
                                                        const APFloat: Pointer );
begin
  AddRowSInts( ACount, AStep, APFloat );
end; //*** end of procedure TN_SerialBuf0.AddRowSFloats

//##path K_Delphi\SF\K_clib\K_SBuf0.pas\TN_SerialBuf0\GetRowSFloats
//********************************************* TN_SerialBuf0.GetRowSFloats ***
// Get given number of Floats
//
//     Parameters
// ACount   - number of Floats
// AStep    - step between neighbour Floats in bytes
// APDouble - pointer to first Float
//
procedure TN_SerialBuf0.GetRowSFloats( const ACount, AStep: integer;
                                                        const APFloat: Pointer );
begin
  GetRowSInts( ACount, AStep, APFloat );
end; //*** end of procedure TN_SerialBuf0.GetRowSFloats

end.

