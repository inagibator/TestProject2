unit K_SBuf;
// serialization methods and structures

// type TN_SerialBuf = class( TObject ) //***** SerialBuf class

interface
uses
  Windows, Graphics, Classes, Sysutils,
  K_SBuf0, K_CLib0,
  N_Types;

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_TestFileFlags
type TN_TestFileFlags = set of ( // Test File Function Flags Set
  K_tffSkipCloseStream, // Skip Close Stream after File Header testing
  K_tffProtectedDFile   // File is protected Data File (DFile)
);

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf
//************************************************************ TN_SerialBuf ***
// Binary Buffer for Data Serialization class
//
// Is used for IDB Data Binary Serialization
//
type TN_SerialBuf = class( TN_SerialBuf0 )
    public
//  Buf1: TN_BArray;    // bufer for storing serialized objects
//  Capacity: integer;  // size of buffer
//  OfsFree: integer;   // Offset to first free byte in Buffer (while data
                      // serialization)
//  CurOfs:  integer;   // current offset while parsing data from serial buffer
  SBUsedTypesList : TList; // list of serialized data SPL types objects


//  SBAddWideString : Boolean; // Add Wide Serialized strings (two bytes per char in AddRowString method)
//  SBGetWideString : Boolean; // Get from Wide Serialized strings (two bytes per char in GetRowString method)

//##/*
  SBDFile: TK_DFile; // Data file record
  SBMemDstStream : TStream;  //  Destination Stream for Data Segments Temporary Storing
  SBMemSrcStream : TStream;  //  Source Stream for Saving Data Segments Temporary Loading
  SBMemSrcFileName : string; //  Source Stream file name
  constructor Create;
  destructor  Destroy; override;
//##*/

  procedure Init0( ASkipCapacityChange : Boolean = false );
//  procedure SetCapacity( ANewCapacity : Integer );
//  procedure IncCapacity( AIncVal : Integer );
//  function  POffset( AOffset : Integer ) : Pointer;

  procedure AddTag( ATag: byte );
  procedure GetTag( out ATag: byte );
{
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
}
  procedure AddRowSDoubles( const AAccuracy, ACount, AStep: integer;
                                                   const APDouble: Pointer );
  procedure GetRowSDoubles( const AAccuracy, ACount, AStep: integer;
                                                   const APDouble: Pointer );

  procedure AddRowStrings ( ASL: TStrings );
  procedure GetRowStrings ( ASL: TStrings );

  procedure AddRowData ( const AData: TN_BArray; ACount: integer );
  procedure GetRowDataInfo ( var ADataInd, ACount: integer );

  procedure AddByteArray ( ABArray: TN_BArray );
  procedure GetByteArray ( var ABArray: TN_BArray );

  procedure AddIntegerArray ( AIArray: TN_IArray );
  procedure GetIntegerArray ( var AIArray: TN_IArray );

  procedure AddFloatArray ( AFArray: TN_FArray );
  procedure GetFloatArray ( var AFArray: TN_FArray );

  procedure AddStringArray ( ASArray: TN_SArray );
  procedure GetStringArray ( var ASArray: TN_SArray );

  procedure AddDoubleArray ( ADArray: TN_DArray; AAccuracy : Integer );
  procedure GetDoubleArray ( var ADArray: TN_DArray; var AAccuracy : Integer );

  procedure AddIPArray ( AIPArray: TN_IPArray );
  procedure GetIPArray ( var AIPArray: TN_IPArray );

  procedure AddFPArray ( FPArray: TN_FPArray; Accuracy : Integer );
  procedure GetFPArray ( var FPArray: TN_FPArray );

  procedure AddDPArray ( ADPArray: TN_DPArray; AAccuracy : Integer );
  procedure GetDPArray ( var ADPArray: TN_DPArray );

  procedure AddFRArray ( AFRArray: TN_FRArray; AAccuracy : Integer );
  procedure GetFRArray ( var AFRArray: TN_FRArray );

  procedure AddBitMap     ( ABMP: TBitMap );
  procedure GetBitMap ( var ABMP: TBitMap );

  procedure SetBufHeader;
  procedure SaveToFile( const AFileName: String;
                        const ADFCreateParams: TK_DFCreateParams );
  function  TestMem( APData : Pointer; ADataLength : Integer ): Integer;
  function  TestFile  ( const AFileName: String; ATestFileFlags : TN_TestFileFlags = []; ACloseFStream : Boolean = true ): Integer;
  function  LoadFromFile ( const AFileName: String;
                           ALoadFromProtectedDFile : Boolean = false ): Boolean;
  procedure LoadFromMem( var AMem; ACount : Integer );
  procedure AddBufCRC( );
  function  CheckBufCRC( ) : Boolean;
  procedure AddDataFormatInfo( );
  function  CheckUsedTypesInfo( var AFmtErrInfo : TStrings ) : Integer;
  procedure ShowProgress;
  procedure StartProgress;

end; //*** end of type TN_SerialBuf = class( TObject )

//****************** Global procedure **********************

var
  N_SerialBuf: TN_SerialBuf;
  K_SerialBufMaxCapacity : Integer = 100000000;

implementation
uses
  Math,
  K_UDT1, K_UDT2, K_UDC, K_Script1,
  N_Lib0;

const
  K_TagSignature = $12345600;
  K_TagMask      = $FFFFFF00;
  K_DataSignature  : AnsiString = 'Data_Tree';
  K_DataUSignature : AnsiString = 'DataUTree';

  //K_FileSignatureC  = 'Data_Code';
  //K_FileSignatureZ  = 'DataZTree';
  //K_FileSignatureCZ = 'DataZCode';

  K_DataSignatureLength = 9; // Length(K_DataSignature)=Length(K_DataUSignature)
//  K_MinInitCapacity = K_DataSignatureLength + SizeOf(Integer);
//  K_KeyCode      = $A53C6918;
  K_DataFmtVerInfoSign : AnsiString = '*S*P*L*';



//************************************************ TN_SerialBuf.Create ***
//
constructor TN_SerialBuf.Create;
begin
  Inherited;
  SBUsedTypesList := TList.Create();
  SBMinCapacity := K_DataSignatureLength + SizeOf(Integer);
  Init0();
end; //*** end of Constructor TN_SerialBuf.Create

//************************************************ TN_SerialBuf.Destroy ***
//
destructor TN_SerialBuf.Destroy;
begin
  K_ClearUsedTypesMarks( SBUsedTypesList );
  SBUsedTypesList.Free;
  Inherited;
end; //*** end of destructor TN_SerialBuf.Destroy

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\Init0
//****************************************************** TN_SerialBuf.Init0 ***
// Init buffer data before serialization
//
//     Parameters
// ASkipCapacityChange - if =TRUE then current buffer capacity will not be 
//                       changed
//
procedure TN_SerialBuf.Init0( ASkipCapacityChange : Boolean = false );
begin
{
  if not ASkipCapacityChange then begin
    if (Capacity > K_SerialBufMaxCapacity) then begin
      Buf1 := nil;      // Free Maximal Buffer
      SetCapacity( -1 );
    end;
  end;
  OfsFree := K_MinInitCapacity;
  CurOfs := K_MinInitCapacity;
}
  Init(ASkipCapacityChange);

  K_ClearUsedTypesMarks( SBUsedTypesList );

  if Assigned(N_PBCaller) then
//    N_PBCaller.Update( 0 );
    N_PBCaller.Finish();
end; //*** end of procedure TN_SerialBuf.Init0
{
//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\SetCapacity
//************************************************ TN_SerialBuf.SetCapacity ***
// Set buffer capacity new value (resize if neccessary)
//
//     Parameters
// ANewCapacity - buffer capacity new value
//
procedure TN_SerialBuf.SetCapacity( ANewCapacity : Integer );
var PrevCapacity : Integer;
begin
  if ANewCapacity < 0 then
  begin
    ANewCapacity := -ANewCapacity;
    Capacity := 0;
  end;
  if ANewCapacity < K_MinInitCapacity then ANewCapacity := K_MinInitCapacity;
  PrevCapacity := Capacity;
  if K_NewCapacity( ANewCapacity, Capacity ) then
  begin
    SetLength(Buf1, Capacity);
    FillChar(Buf1[PrevCapacity], Capacity - PrevCapacity, 0);
  end;
end; //*** end of procedure TN_SerialBuf.SetCapacity

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\IncCapacity
//************************************************ TN_SerialBuf.IncCapacity ***
// Increment buffer capacity
//
//     Parameters
// AIncVal - increment buffer capacity value
//
procedure TN_SerialBuf.IncCapacity( AIncVal : Integer );
begin
  SetCapacity( OfsFree + AIncVal );
end; //*** end of procedure TN_SerialBuf.IncCapacity

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\POffset
//**************************************************** TN_SerialBuf.POffset ***
// Get pointer to buffer position by buffer offset
//
//     Parameters
// AOffset - buffer offset in bytes
// Result  - Returns pointer to given buffer position
//
function  TN_SerialBuf.POffset( AOffset : Integer ) : Pointer;
begin
  Result := @Buf1[AOffset];
end; //*** end of procedure TN_SerialBuf.POffset

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddRowInt
//************************************************** TN_SerialBuf.AddRowInt ***
// Add given Integer value
//
//     Parameters
// AData - given Integer value
//
procedure TN_SerialBuf.AddRowInt( AData: Integer );
begin
  IncCapacity(SizeOf(Integer));
  PInteger(@Buf1[OfsFree])^ := AData;
  Inc(OfsFree, SizeOf(integer));
end; //*** end of procedure TN_SerialBuf.AddRowInt

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetRowInt
//************************************************** TN_SerialBuf.GetRowInt ***
// Get one Integer value
//
//     Parameters
// AData - resulting Integer value
//
procedure TN_SerialBuf.GetRowInt( out AData: integer );
begin
  AData := PInteger(POffset(CurOfs))^;
  Inc(CurOfs, SizeOf(integer));
end; //*** end of procedure TN_SerialBuf.GetRowInt

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddRowDouble
//*********************************************** TN_SerialBuf.AddRowDouble ***
// Add given Double value
//
//     Parameters
// AData - given Double value
//
procedure TN_SerialBuf.AddRowDouble( AData: Double );
begin
  IncCapacity(SizeOf(Double));
  PDouble(@Buf1[OfsFree])^ := AData;
  Inc(OfsFree, SizeOf(Double));
end; //*** end of procedure TN_SerialBuf.AddRowDouble

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetRowDouble
//*********************************************** TN_SerialBuf.GetRowDouble ***
// Get one Double value
//
//     Parameters
// AData - resulting Double value
//
procedure TN_SerialBuf.GetRowDouble( out AData: Double );
begin
  AData := PDouble(POffset(CurOfs))^;
  Inc(CurOfs, SizeOf(Double));
end; //*** end of procedure TN_SerialBuf.GetRowDouble

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddRowFloat
//************************************************ TN_SerialBuf.AddRowFloat ***
// Add given Float value
//
//     Parameters
// AData - given Float value
//
procedure TN_SerialBuf.AddRowFloat  ( AData: Float );
begin
  IncCapacity(SizeOf(Float));
  PFloat(@Buf1[OfsFree])^ := AData;
  Inc(OfsFree, SizeOf(Float));
end; //*** end of procedure TN_SerialBuf.AddRowFloat

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetRowFloat
//************************************************ TN_SerialBuf.GetRowFloat ***
// Get one Float value
//
//     Parameters
// AData - resulting Float value
//
procedure TN_SerialBuf.GetRowFloat  ( out AData: Float );
begin
  AData := PFloat(POffset(CurOfs))^;
  Inc(CurOfs, SizeOf(Float));
end; //*** end of procedure TN_SerialBuf.GetRowFloat

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddRowString
//*********************************************** TN_SerialBuf.AddRowString ***
// Add given String value
//
//     Parameters
// AData - given String value
//
procedure TN_SerialBuf.AddRowString( const AStr: string );
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
      Move( AStr[1], POffset(OfsFree)^, NumBytes );
    end
    else
    begin  // Ansi to Wide
//      WideBufStr := AStr;
      WideBufStr := N_StringToWide( AStr );
      Move( WideBufStr[1], POffset(OfsFree)^, NumBytes );
    end;
  end // if SBAddWideString then
  else
  begin // in SBuf should be Ansi Strings
    if SizeOf( Char ) = 2 then
    begin // Wide to Ansi
//      AnsiBufStr := AnsiString(AStr);
      AnsiBufStr := N_StringToAnsi( AStr );
      Move( AnsiBufStr[1], POffset(OfsFree)^, NumBytes );
    end
    else
    begin  // Ansi to Ansi
      Move( AStr[1], POffset(OfsFree)^, NumBytes );
    end;
  end; // // in SBuf should be Ansi Strings

  Inc( OfsFree, NumBytes );
end; //*** end of procedure TN_SerialBuf.AddRowString

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetRowString
//*********************************************** TN_SerialBuf.GetRowString ***
// Get one String value
//
//     Parameters
// AData - resulting String value
//
procedure TN_SerialBuf.GetRowString( var AStr: string );
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
      AStr := N_WideToString( WideBufStr );
    end;
  end else begin // SBuf contains Ansi Strings
    if SizeOf( Char ) = 2 then begin // Ansi to Wide
      SetLength( AnsiBufStr, NumBytes );
      Move( Buf1[CurOfs], AnsiBufStr[1], NumBytes );
//      AStr := string(AnsiBufStr);
      AStr := N_AnsiToString( AnsiBufStr );
    end else begin  // Ansi to Ansi
      SetLength( AStr, NumBytes );
      Move( Buf1[CurOfs], AStr[1], NumBytes );
    end;
  end;

  Inc( CurOfs, NumBytes );
end; //*** end of procedure TN_SerialBuf.GetRowString

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddRowBytes
//************************************************ TN_SerialBuf.AddRowBytes ***
// Add given number of Bytes
//
//     Parameters
// ACount  - number of bytes
// APBytes - pointer to first byte
//
procedure TN_SerialBuf.AddRowBytes( const ACount: integer; const APBytes: Pointer);
begin
  if ACount = 0 then Exit;
  IncCapacity( ACount );
  move( APBytes^, Buf1[OfsFree], ACount );
  Inc(OfsFree, ACount);
end; //*** end of procedure TN_SerialBuf.AddRowBytes

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetRowBytes
//************************************************ TN_SerialBuf.GetRowBytes ***
// Get given number of Bytes
//
//     Parameters
// ACount  - number of bytes
// APBytes - pointer to first byte
//
procedure TN_SerialBuf.GetRowBytes( const ACount: integer; const APBytes: Pointer);
begin
  if ACount = 0 then Exit;
  move( POffset(CurOfs)^, APBytes^, ACount );
  Inc(CurOfs, ACount);
end; //*** end of procedure TN_SerialBuf.GetRowBytes

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddRowSInts
//************************************************ TN_SerialBuf.AddRowSInts ***
// Add given number of Integers
//
//     Parameters
// ACount  - number of Integers
// AStep   - step between neighbour Integers in bytes
// APBytes - pointer to first Integer
//
procedure TN_SerialBuf.AddRowSInts( const ACount, AStep: integer;
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
end; //*** end of procedure TN_SerialBuf.AddRowSInts

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetRowSInts
//************************************************ TN_SerialBuf.GetRowSInts ***
// Get given number of Integers
//
//     Parameters
// ACount  - number of Integers
// AStep   - step between neighbour Integers in bytes
// APBytes - pointer to first Integer
//
procedure TN_SerialBuf.GetRowSInts( const ACount, AStep: integer;
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
end; //*** end of procedure TN_SerialBuf.GetRowSInts

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddRowSFloats
//********************************************** TN_SerialBuf.AddRowSFloats ***
// Add given number of Floats
//
//     Parameters
// ACount   - number of Floats
// AStep    - step between neighbour Floats in bytes
// APDouble - pointer to first Float
//
procedure TN_SerialBuf.AddRowSFloats( const ACount, AStep: integer;
                                                        const APFloat: Pointer );
begin
  AddRowSInts( ACount, AStep, APFloat );
end; //*** end of procedure TN_SerialBuf.AddRowSFloats

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetRowSFloats
//********************************************** TN_SerialBuf.GetRowSFloats ***
// Get given number of Floats
//
//     Parameters
// ACount   - number of Floats
// AStep    - step between neighbour Floats in bytes
// APDouble - pointer to first Float
//
procedure TN_SerialBuf.GetRowSFloats( const ACount, AStep: integer;
                                                        const APFloat: Pointer );
begin
  GetRowSInts( ACount, AStep, APFloat );
end; //*** end of procedure TN_SerialBuf.GetRowSFloats
}

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddTag
//***************************************************** TN_SerialBuf.AddTag ***
// Add binary Tag (one byte data)
//
//     Parameters
// ATag - binary Tag value
//
procedure TN_SerialBuf.AddTag( ATag: byte );
begin
  AddRowInt( K_TagSignature or ATag );
end; //*** end of procedure TN_SerialBuf.AddTag

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetTag
//***************************************************** TN_SerialBuf.GetTag ***
// Get Tag (one byte data) and check data integrity
//
//     Parameters
// ATag - resulting binary Tag value
//
procedure TN_SerialBuf.GetTag( out ATag: byte );
var
  IntTag: integer;
begin
  Move( Buf1[CurOfs], IntTag, SizeOf(integer) );
  if (IntTag and K_TagMask) <> K_TagSignature then begin
    raise TK_LoadUDDataError.Create( 'Bad Tag while loading Data at offset  $' +
                                                  IntToHex( CurOfs, 4 ) );
  end;
  Inc(CurOfs, SizeOf(integer));
  ATag := Byte( IntTag and $FF );
end; //*** end of procedure TN_SerialBuf.GetTag

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddRowSDoubles
//********************************************* TN_SerialBuf.AddRowSDoubles ***
// Add given number of Doubles
//
//     Parameters
// AAccuracy - number of meaningfull decimal digits after decimal point (for 
//             compression Doubles to Integers)
// ACount    - number of Doubles
// AStep     - step between neighbour Doubles in bytes
// APDouble  - pointer to first Double
//
procedure TN_SerialBuf.AddRowSDoubles( const AAccuracy, ACount, AStep: integer;
                                                     const APDouble: Pointer );
var
  TmpIA: TN_IArray;
  i, DataSize: integer;
  pinp, pbuf: PDouble;
begin
  if AAccuracy = 100 then
  begin
    DataSize := ACount*SizeOf(double);
    IncCapacity( DataSize );
    pinp := APDouble;
    pbuf := PDouble(Integer(POffset(0))+OfsFree);
    for i := 0 to ACount-1 do
    begin
      pbuf^ := pinp^; Inc(pbuf);
      pinp := PDouble( integer(pinp) + AStep );
    end;
    Inc(OfsFree, DataSize);
  end
  else
  begin
    SetLength( TmpIA, ACount );
    N_PackSDoublesToInt( AAccuracy, ACount, AStep, TmpIA, APDouble );
    AddRowSInts( ACount, Sizeof(integer), TmpIA );
    TmpIA := nil;
  end;
end; //*** end of procedure TN_SerialBuf.AddRowSDoubles

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetRowSDoubles
//********************************************* TN_SerialBuf.GetRowSDoubles ***
// Get given number of Doubles
//
//     Parameters
// AAccuracy - number of meaningfull decimal digits after decimal point (for 
//             compression Doubles to Integers)
// ACount    - number of Doubles
// AStep     - step between neighbour Doubles in bytes
// APDouble  - pointer to first Double
//
procedure TN_SerialBuf.GetRowSDoubles( const AAccuracy, ACount, AStep: integer;
                                                     const APDouble: Pointer );
var
  TmpIA: TN_IArray;
  i, DataSize: integer;
  pout, pbuf: PDouble;
begin
  if AAccuracy = 100 then
  begin
    DataSize := ACount*SizeOf(double);
    pout := APDouble;
    pbuf := PDouble(POffset(CurOfs));
    for i := 0 to ACount-1 do
    begin
      pout^ := pbuf^; Inc(pbuf);
      pout := PDouble( integer(pout) + AStep );
    end;
    Inc(CurOfs, DataSize);
  end else
  begin
    SetLength( TmpIA, ACount );
    GetRowSInts( ACount, Sizeof(integer), TmpIA );
    N_UnpackSDoublesFromInt( AAccuracy, ACount, AStep, TmpIA, APDouble );
    TmpIA := nil;
  end;
end; //*** end of procedure TN_SerialBuf.GetRowSDoubles

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddRowStrings
//********************************************** TN_SerialBuf.AddRowStrings ***
// Add strings from given TStrings object
//
//     Parameters
// ASL - given Strings
//
procedure TN_SerialBuf.AddRowStrings( ASL: TStrings );
begin
  AddRowString( ASL.Text );
end; //*** end of procedure TN_SerialBuf.AddRowStrings

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetRowStrings
//********************************************** TN_SerialBuf.GetRowStrings ***
// Get strings to given TStrings object
//
//     Parameters
// ASL - given Strings
//
procedure TN_SerialBuf.GetRowStrings( ASL: TStrings );
var
  Str: string;
begin
  ASL.Clear;
  GetRowString( Str );
  ASL.Text := Str;
end; //*** end of procedure TN_SerialBuf.GetRowStrings

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddRowData
//************************************************* TN_SerialBuf.AddRowData ***
// Add given number of bytes from given TN_BArray
//
//     Parameters
// AData  - given TN_BArray (array of byte)
// ACount - number of bytes
//
procedure TN_SerialBuf.AddRowData( const AData: TN_BArray; ACount: integer );
begin
  IncCapacity( ACount + sizeof(Integer) + 1 );

  if ACount < 255 then begin
    Buf1[OfsFree] := Byte( ACount );
    Inc(OfsFree);
  end else begin
    Buf1[OfsFree] := 255;
    Inc(OfsFree);
    AddRowInt( ACount );
  end;

  if ACount > 0 then Move( AData[0], POffset(OfsFree)^, ACount );
  Inc(OfsFree, ACount);
end; //*** end of procedure TN_SerialBuf.AddRowData

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetRowDataInfo
//********************************************* TN_SerialBuf.GetRowDataInfo ***
// Get buffer offset and size of data previously saved by AddRowData
//
//     Parameters
// ADataInd - buffer offset
// ACount   - data size in bytes
//
procedure TN_SerialBuf.GetRowDataInfo( var ADataInd, ACount: integer );
begin

  if TN_PByte(POffset(CurOfs))^ < 255 then
  begin
    ACount := TN_PByte(POffset(CurOfs))^;
    ADataInd  := CurOfs + 1;
  end
  else
  begin
    ACount := PInteger(POffset(CurOfs+1))^;
    ADataInd  := CurOfs + 1 + Sizeof(integer);
  end;
  CurOfs := ADataInd + ACount;
end; //*** end of procedure TN_SerialBuf.GetRowData


//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddByteArray
//*********************************************** TN_SerialBuf.AddByteArray ***
// Add given byte array (TN_BArray)
//
//     Parameters
// ABArray - given TN_BArray (array of byte)
//
procedure TN_SerialBuf.AddByteArray( ABArray: TN_BArray );
var
  Count: integer;
begin
  Count := Length( ABArray );
  AddRowInt( Count );
  if Count > 0 then AddRowBytes( Count, @ABArray[0] );
end; //*** end of procedure TN_SerialBuf.AddByteArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetByteArray
//*********************************************** TN_SerialBuf.GetByteArray ***
// Get data to given byte array (TN_BArray)
//
//     Parameters
// ABArray - given TN_BArray (array of byte)
//
procedure TN_SerialBuf.GetByteArray( var ABArray: TN_BArray );
var
  Count: integer;
begin
  GetRowInt( Count );
  SetLength( ABArray, Count );
  if Count > 0 then GetRowBytes( Count, @ABArray[0] );
end; //*** end of procedure TN_SerialBuf.GetByteArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddIntegerArray
//******************************************** TN_SerialBuf.AddIntegerArray ***
// Add given Integer array (TN_IArray)
//
//     Parameters
// AIArray - given TN_IArray (array of Integer)
//
procedure TN_SerialBuf.AddIntegerArray( AIArray: TN_IArray );
var
  Count: integer;
begin
  Count := Length( AIArray );
  AddRowInt( Count );
  AddRowSInts( Count, Sizeof(integer), AIArray );
end; //*** end of procedure TN_SerialBuf.AddIntegerArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetIntegerArray
//******************************************** TN_SerialBuf.GetIntegerArray ***
// Get data to given Integer array (TN_IArray)
//
//     Parameters
// AIArray - given TN_IArray (array of Integer)
//
procedure TN_SerialBuf.GetIntegerArray( var AIArray: TN_IArray );
var
  Count: integer;
begin
  GetRowInt( Count );
  SetLength( AIArray, Count );
  GetRowSInts( Count, Sizeof(integer), AIArray );
end; //*** end of procedure TN_SerialBuf.GetIntegerArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddFloatArray
//********************************************** TN_SerialBuf.AddFloatArray ***
// Add given Float array (TN_FArray)
//
//     Parameters
// AFArray - given TN_FArray (array of Float)
//
procedure TN_SerialBuf.AddFloatArray ( AFArray: TN_FArray );
var
  Count: integer;
begin
  Count := Length( AFArray );
  AddRowInt( Count );
  AddRowSFloats( Count, Sizeof(Float), AFArray );
end; //*** end of procedure TN_SerialBuf.AddFloatArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetFloatArray
//********************************************** TN_SerialBuf.GetFloatArray ***
// Get data to given Float array (TN_FArray)
//
//     Parameters
// AFArray - given TN_FArray (array of Float)
//
procedure TN_SerialBuf.GetFloatArray ( var AFArray: TN_FArray );
var
  Count: integer;
begin
  GetRowInt( Count );
  SetLength( AFArray, Count );
  GetRowSInts( Count, Sizeof(Float), AFArray );
end; //*** end of procedure TN_SerialBuf.GetFloatArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddStringArray
//********************************************* TN_SerialBuf.AddStringArray ***
// Add given String array (TN_SArray)
//
//     Parameters
// ASArray - given TN_SArray (array of String)
//
procedure TN_SerialBuf.AddStringArray( ASArray: TN_SArray );
var
  i, Count: integer;
begin
  Count := Length( ASArray );
  AddRowInt( Count );
  for i := 0 to Count-1 do AddRowString( ASArray[i] );
end; //*** end of procedure TN_SerialBuf.AddStringArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetStringArray
//********************************************* TN_SerialBuf.GetStringArray ***
// Get data to given String array (TN_SArray)
//
//     Parameters
// ASArray - given TN_SArray (array of String)
//
procedure TN_SerialBuf.GetStringArray( var ASArray: TN_SArray );
var
  i, Count: integer;
begin
  GetRowInt( Count );
  SetLength( ASArray, Count );
  for i := 0 to Count-1 do GetRowString( ASArray[i] );
end; //*** end of procedure TN_SerialBuf.GetStringArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddDoubleArray
//********************************************* TN_SerialBuf.AddDoubleArray ***
// Add given Double array (TN_DArray)
//
//     Parameters
// ADArray   - given TN_DArray (array of Double)
// AAccuracy - number of meaningfull decimal digits after decimal point (for 
//             compression Doubles to Integers)
//
procedure TN_SerialBuf.AddDoubleArray( ADArray: TN_DArray; AAccuracy : Integer );
var
  Count: integer;
begin
  AddRowInt( AAccuracy );
  Count := Length( ADArray );
  AddRowInt( Count );
  AddRowSDoubles( AAccuracy, Count, SizeOf(Double), ADArray );
end; //*** end of procedure TN_SerialBuf.AddDoubleArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetDoubleArray
//********************************************* TN_SerialBuf.GetDoubleArray ***
// Get data to given Double array (TN_DArray)
//
//     Parameters
// ADArray   - given TN_DArray (array of Double)
// AAccuracy - number of meaningfull decimal digits after decimal point (for 
//             compression Doubles to Integers)
//
procedure TN_SerialBuf.GetDoubleArray( var ADArray: TN_DArray; var AAccuracy : Integer );
var
  Count: integer;
begin
  GetRowInt( AAccuracy );
  GetRowInt( Count );
  SetLength( ADArray, Count );
  GetRowSDoubles( AAccuracy, Count, SizeOf(Double), ADArray );
end; //*** end of procedure TN_SerialBuf.GetDoubleArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddIPArray
//************************************************* TN_SerialBuf.AddIPArray ***
// Add given Integer Point array (TN_IPArray)
//
//     Parameters
// AIPArray - given TN_IPArray (array of Integer Point)
//
procedure TN_SerialBuf.AddIPArray( AIPArray: TN_IPArray );
var
  Count: integer;
begin
  Count := Length( AIPArray );
  AddRowInt( Count );
  if Count > 0 then AddRowBytes( Count*SizeOf(AIPArray[0]), @AIPArray[0] );
end; //*** end of procedure TN_SerialBuf.AddIPArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetIPArray
//************************************************* TN_SerialBuf.GetIPArray ***
// Get data to given Integer Point array (TN_IPArray)
//
//     Parameters
// AIPArray - given TN_IPArray (array of Integer Point)
//
procedure TN_SerialBuf.GetIPArray( var AIPArray: TN_IPArray );
var
  Count: integer;
begin
  GetRowInt( Count );
  SetLength( AIPArray, Count );
  if Count > 0 then GetRowBytes( Count*SizeOf(AIPArray[0]), @AIPArray[0] );
end; //*** end of procedure TN_SerialBuf.GetIPArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddFPArray
//************************************************* TN_SerialBuf.AddFPArray ***
// Add given Float Point array (TN_FPArray)
//
//     Parameters
// AFPArray - given TN_FPArray (array of Float Point)
//
procedure TN_SerialBuf.AddFPArray( FPArray: TN_FPArray; Accuracy : Integer );
var
  Count: integer;
begin
  Count := Length( FPArray );
  AddRowInt( Count );
  if Count > 0 then AddRowBytes( Count*SizeOf(FPArray[0]), @FPArray[0] );
end; //*** end of procedure TN_SerialBuf.AddFPArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetFPArray
//************************************************* TN_SerialBuf.GetFPArray ***
// Get data to given Float Point array (TN_FPArray)
//
//     Parameters
// AFPArray - given TN_FPArray (array of Float Point)
//
procedure TN_SerialBuf.GetFPArray( var FPArray: TN_FPArray );
var
  Count: integer;
begin
  GetRowInt( Count );
  SetLength( FPArray, Count );
  if Count > 0 then GetRowBytes( Count*SizeOf(FPArray[0]), @FPArray[0] );
end; //*** end of procedure TN_SerialBuf.GetFPArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddDPArray
//************************************************* TN_SerialBuf.AddDPArray ***
// Add given Double Point array (TN_DPArray)
//
//     Parameters
// ADPArray  - given TN_DPArray (array of Double Point)
// AAccuracy - number of meaningfull decimal digits after decimal point (for 
//             compression Doubles to Integers)
//
procedure TN_SerialBuf.AddDPArray( ADPArray: TN_DPArray; AAccuracy : Integer );
var
  Count: integer;
begin
  Count := Length( ADPArray );
  AddRowInt( Count );
  if Count > 0 then AddRowBytes( Count*SizeOf(ADPArray[0]), @ADPArray[0] );
end; //*** end of procedure TN_SerialBuf.AddDPArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetDPArray
//************************************************* TN_SerialBuf.GetDPArray ***
// Get data to given Double Point array (TN_DPArray)
//
//     Parameters
// ADPArray - given TN_DPArray (array of Double Point)
//
procedure TN_SerialBuf.GetDPArray( var ADPArray: TN_DPArray );
var
  Count: integer;
begin
  GetRowInt( Count );
  SetLength( ADPArray, Count );
  if Count > 0 then GetRowBytes( Count*SizeOf(ADPArray[0]), @ADPArray[0] );
end; //*** end of procedure TN_SerialBuf.GetDPArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddFRArray
//************************************************* TN_SerialBuf.AddFRArray ***
// Add given Float Rectangle array (TN_FRArray)
//
//     Parameters
// AFRArray  - given TN_FRArray (array of Float Rectangle)
// AAccuracy - number of meaningfull decimal digits after decimal point (for 
//             compression Doubles to Integers)
//
procedure TN_SerialBuf.AddFRArray( AFRArray: TN_FRArray; AAccuracy : Integer );
var
  Count: integer;
begin
  Count := Length( AFRArray );
  AddRowInt( Count );
  if Count > 0 then AddRowBytes( Count*SizeOf(AFRArray[0]), @AFRArray[0] );
end; //*** end of procedure TN_SerialBuf.AddFRArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetFRArray
//************************************************* TN_SerialBuf.GetFRArray ***
// Get data to given Float Rectangle array (TN_FRArray)
//
//     Parameters
// AFRArray - given TN_FRArray (array of Float Rectangle)
//
procedure TN_SerialBuf.GetFRArray( var AFRArray: TN_FRArray );
var
  Count: integer;
begin
  GetRowInt( Count );
  SetLength( AFRArray, Count );
  if Count > 0 then GetRowBytes( Count*SizeOf(AFRArray[0]), @AFRArray[0] );
end; //*** end of procedure TN_SerialBuf.GetFRArray

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddBitMap
//************************************************** TN_SerialBuf.AddBitMap ***
// Add given BitMap
//
//     Parameters
// ABMP - given BitMap
//
procedure TN_SerialBuf.AddBitMap( ABMP: TBitMap );
var
  i, ScanLineSize: integer;
begin
  AddRowInt( ABMP.Width );
  AddRowInt( ABMP.Height );
  AddRowInt( Ord(ABMP.PixelFormat) );
  case ABMP.PixelFormat of
  pf1Bit:  ScanLineSize := (ABMP.Width shr 3) + 1;
  pf8Bit:  ScanLineSize := ABMP.Width;
  pf15Bit: ScanLineSize := ABMP.Width shl 1;
  pf16Bit: ScanLineSize := ABMP.Width shl 1;
  pf24Bit: ScanLineSize := ABMP.Width * 3;
  pf32Bit: ScanLineSize := ABMP.Width shl 2;
  else  ScanLineSize := ABMP.Width shl 2;
  end;
  for i := 0 to ABMP.Height-1 do
    AddRowBytes( ScanLineSize, ABMP.Scanline[i] );
end; //*** end of procedure TN_SerialBuf.AddBitMap

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\GetBitMap
//************************************************** TN_SerialBuf.GetBitMap ***
// Get data to given BitMap
//
//     Parameters
// ABMP - given BitMap
//
procedure TN_SerialBuf.GetBitMap( var ABMP: TBitMap );
var
  i, ScanLineSize: integer;
begin
  if ABMP = nil then ABMP := TBitMap.Create();
  GetRowInt( i ); ABMP.Width  := i;
  GetRowInt( i ); ABMP.Height := i;
  GetRowInt( i ); ABMP.PixelFormat := TPixelFormat(i);

  case ABMP.PixelFormat of
  pf1Bit:  ScanLineSize := (ABMP.Width shr 3) + 1;
  pf8Bit:  ScanLineSize := ABMP.Width;
  pf15Bit: ScanLineSize := ABMP.Width shl 1;
  pf16Bit: ScanLineSize := ABMP.Width shl 1;
  pf24Bit: ScanLineSize := ABMP.Width * 3;
  pf32Bit: ScanLineSize := ABMP.Width shl 2;
  else  ScanLineSize := ABMP.Width shl 2;
  end;
  for i := 0 to ABMP.Height-1 do
    GetRowBytes( ScanLineSize, ABMP.Scanline[i] );
end; //*** end of procedure TN_SerialBuf.GetBitMap

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\SetBufHeader
//*********************************************** TN_SerialBuf.SetBufHeader ***
// Set buffer header
//
// Put signature and plane serialized data length to buffer header
//
procedure TN_SerialBuf.SetBufHeader;
begin
  PInteger(@Buf1[K_DataSignatureLength])^ := OfsFree; // copy Buf size in bytes to Buf
  Move( K_DataSignature[1], Buf1[0], K_DataSignatureLength ); // copy data  Signature to Buf
end; //*** end of procedure TN_SerialBuf.SaveToFile

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\SaveToFile
//************************************************* TN_SerialBuf.SaveToFile ***
// Save serialized data to given virtual file
//
//     Parameters
// AFileName       - virtual file name
// ADFCreateParams - virtual file create parameters
//
procedure TN_SerialBuf.SaveToFile( const AFileName: String;
                                   const ADFCreateParams: TK_DFCreateParams  );
var
  VFile: TK_VFile;
  DSTSize : Integer;
  RStream : TStream;
begin
//  PInteger(@Buf1[K_DataSignatureLength])^ := OfsFree; // copy Buf size in bytes to Buf
//  Move( K_DataSignature[1], Buf1[0], K_DataSignatureLength ); // copy data  Signature to Buf
  SetBufHeader();
  if SBMemDstStream <> nil then
  begin // Multi Segment Mode
    // Free Source Temporary Stream with Compound file Data Segments
    FreeAndNil( SBMemSrcStream );

    // Check Resulting File
    K_VFAssignByPath( VFile, AFileName, @K_DFCreatePlain );
    if VFile.VFType <> K_vftDFile then
      raise TK_LoadUDDataError.Create( 'MultiSegment Mode >> Not proper resulting File >> ' + AFileName );

    RStream := K_VFStreamGetToWrite( VFile );
    if RStream = nil then
      raise Exception.Create( 'FileStrem Create error File=' + AFileName );

    // Add Data from Destination Stream
    DSTSize := SBMemDstStream.Position;
    SBMemDstStream.Seek( 0, soBeginning );
    RStream.CopyFrom( SBMemDstStream, DSTSize );

    // Free Temporary Stream with Compound file Data Segments
    FreeAndNil( SBMemDstStream );

    // Add Serialized Data as Last Data Segment to Destination Stream
    K_DFStreamWriteAll( RStream, K_DFCreateEncryptedSrc,
                        @Buf1[0], OfsFree,
                        DSTSize );
    K_VFStreamFree( VFile );

  end
  else
  begin // Single Segment Mode
    K_VFAssignByPath( VFile, AFileName, @ADFCreateParams );
    K_VFWriteAll ( VFile, @Buf1[0], OfsFree );
  end;
end; //*** end of procedure TN_SerialBuf.SaveToFile

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\TestMem
//**************************************************** TN_SerialBuf.TestMem ***
// Check if given Memory Data has Correct Binary Content
//
//     Parameters
// APData      - pointer to data buffer
// ADataLength - data buffer length
// Result      - Returns test code:
//#F
//         =-1 if File not Exists,
//         = 0 if File has Binary format,
//         = 1 if File has not Binary format
//#/F
//
function  TN_SerialBuf.TestMem( APData : Pointer; ADataLength : Integer ): Integer;
var
  WTagStr: AnsiString;
begin
  Result := -1;
  if (APData = nil) or
     (ADataLength <= K_DataSignatureLength + SizeOf(Integer)) then Exit;
  SetLength( WTagStr, K_DataSignatureLength );
  Move( APData^, WTagStr[1], K_DataSignatureLength );
  Result := 0;

  if WTagStr = K_DataSignature then begin
    SBGetWideString := False;
    Exit;
  end;

  if WTagStr = K_DataUSignature then begin
    SBGetWideString := True;
    Exit;
  end;

  Result := 1;
end; //*** end of function  TN_SerialBuf.TestMem

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\TestFile
//*************************************************** TN_SerialBuf.TestFile ***
// Check if given File has Correct Binary Content
//
//     Parameters
// AFileName     - given file name
// ACloseFStream - if =TRUE then virtual file stream will be closed just after 
//                 file header test
// Result        - Returns test code:
//#F
//         <=-1 if File not Exists (-1 - ErrorCode ),
//         = 0 if File has Binary format,
//         = 1 if File has not Binary format
//#/F
//
function  TN_SerialBuf.TestFile( const AFileName: String; ATestFileFlags : TN_TestFileFlags = []; ACloseFStream : Boolean = true ): Integer;
var
  WTagStr: AnsiString;
  VFile: TK_VFile;
  DFOpenFlags: TK_DFOpenFlags;
  CheckInd : Integer;

label LExit;

begin
  Result := -1;

  K_VFAssignByPath( VFile, AFileName );
  DFOpenFlags := [];
  if K_tffProtectedDFile in ATestFileFlags then
    DFOpenFlags := [K_dfoProtected];
  if K_VFOpen(VFile, DFOpenFlags ) < 0 then
  begin
    Result := -1 - Ord(VFile.DFile.DFErrorCode);
    Exit;
  end;
  SetLength( WTagStr, K_DataSignatureLength );
  CheckInd := 0;
  repeat
  ///////////////////////////////
  // Check Binary Data Signature
  //
    if not K_VFRead( VFile, @WTagStr[1], K_DataSignatureLength, FALSE ) then goto LExit;

    Result := 0;

    if WTagStr = K_DataSignature then
    begin
      SBGetWideString := False;
      goto LExit; // Binary Data Signature is found break search loop
    end;

    if WTagStr = K_DataUSignature then
    begin
      SBGetWideString := True;
      goto LExit; // Binary Data Signature is found break search loop
    end;
  //
  ///////////////////////////////

  /////////////////////////////////////////////////
  // Try to Opened Data File Last Segment
  // it is possible if DataFile is Multi Segment:
  // is Compound File with Self Data written in first segments and Data Structure
  // in Last Segment in an UDBase Tree Form
  //
    if (VFile.VFType <> K_vftDFile) or
       not K_DFStreamOpenLastSegm( VFile.DFile.DFStream, VFile.DFile, DFOpenFlags ) then
    // Testing File is not DataFile or Stream Open Error
      Break;

    // Stream is opened on Data File Segment
    if VFile.DFile.DFCurSegmPos = 0 then
    // Data File is Single Segment: Last Segment is First Segment:
    // Testing File has Text Format
     Break;

    // Stream is opened on the last DataFile Segment - go to Data Signature Check   
  //
  /////////////////////////////////////////////////

    Inc(CheckInd);
  until CheckInd = 2;

  Result := 1; // File has not Binary format (Text Format)

LExit:
   SBDFile := VFile.DFile;
// For Ccompound Files dump value should be 'TN_SerialBuf.TestFile Res=0 SegPos=(number >0)'
   N_Dump2Str( format( 'TN_SerialBuf.TestFile Res=%d SegPos=%d',
                       [Result, SBDFile.DFCurSegmPos] ) );
   if not (K_tffSkipCloseStream in ATestFileFlags) then
     FreeAndNil( SBDFile.DFStream );
end; //*** end of function  TN_SerialBuf.TestFile

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\LoadFromFile
//*********************************************** TN_SerialBuf.LoadFromFile ***
// Load serialized data from given file to binary buffer
//
//     Parameters
// AFileName - given file name
//
function  TN_SerialBuf.LoadFromFile( const AFileName: string;
                                    ALoadFromProtectedDFile : Boolean = false ): Boolean;
var
  VFile: TK_VFile;
  TestFileFlags : TN_TestFileFlags;
begin

  Init0(TRUE);
  Result := False;
  TestFileFlags := [K_tffSkipCloseStream];
  if ALoadFromProtectedDFile then
    TestFileFlags := [K_tffProtectedDFile,K_tffSkipCloseStream];
  case TestFile( AFileName, TestFileFlags ) of
  0 : ;     // Correct Data Signature
  1 : begin // Wrong Data Signature
    FreeAndNil( SBDFile.DFStream );
    Exit;
  end;
  else
    Exit;
  end;

  OfsFree := SBDFile.DFPlainDataSize;
  SetCapacity( OfsFree );
  //*** Read File Data
  if SBDFile.DFStream <> nil then begin // DFile - External File
    if not K_DFReadAll( @Buf1[0], SBDFile, '' ) then Exit;
  end else
  begin                        // Virtual File - UDMem
    K_VFAssignByPath( VFile, AFileName );
    K_VFOpen( VFile );
    if not K_VFReadAll( VFile, @Buf1[0] ) then Exit;
  end;
  if PInteger(@Buf1[K_DataSignatureLength])^ <> OfsFree then Exit;
  Result := True;
  StartProgress;
end; //*** end of procedure TN_SerialBuf.LoadFromFile

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\LoadFromMem
//************************************************ TN_SerialBuf.LoadFromMem ***
// Load serialized data from given memory location to buffer
//
//     Parameters
// AMem   - given memory location
// ACount - data length
//
procedure TN_SerialBuf.LoadFromMem( var AMem; ACount : Integer );
begin
  SetDataFromMem(  AMem, ACount );
  StartProgress();
end; //*** end of procedure TN_SerialBuf.LoadFromMem

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddBufCRC
//************************************************** TN_SerialBuf.AddBufCRC ***
// Add CRC to buffer
//
procedure TN_SerialBuf.AddBufCRC( );
begin
  AddRowInt(  N_AdlerChecksum( @Buf1[0], OfsFree ) );
end; //*** end of procedure TN_SerialBuf.AddRowInt

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\CheckBufCRC
//************************************************ TN_SerialBuf.CheckBufCRC ***
// Check data CRC in buffer
//
function TN_SerialBuf.CheckBufCRC( ) : Boolean;
var
  CheckCount : Integer;
begin
  CheckCount := OfsFree - SizeOf(Integer);
  Result := PInteger(@Buf1[CheckCount])^ =
            N_AdlerChecksum( @Buf1[0], CheckCount );
end; //*** end of procedure TN_SerialBuf.CheckBufCRC

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\AddDataFormatInfo
//****************************************** TN_SerialBuf.AddDataFormatInfo ***
// Add Used Data Types Version Info
//
// Data Types Version Info is added to serialized data for future control 
// application and serialized data format versions accordance.
//
procedure TN_SerialBuf.AddDataFormatInfo( );
var
  FmtCurVers : TN_IArray;
  TypeNames : TStringList;
  i : Integer;
  TypesCount : Integer;
begin
  TypesCount := SBUsedTypesList.Count;
  TypeNames := TStringList.Create;
  // All Used SPL Types Table (TypesCount ints) + MaximalFmtVersion(1 int) + TableStartOffset(1 int) + TableSignature((2 int))
  SetLength( FmtCurVers, TypesCount + 4 );
  for i := 0 to TypesCount - 1 do
    with TK_UDFieldsDescr(SBUsedTypesList[i]) do begin
      TypeNames.Add( ObjName );
      FmtCurVers[i] := FDCurFVer;
    end;
  FmtCurVers[TypesCount] := MaxIntValue( FmtCurVers ); // 1 Common Cur Fmt Version (Maximal Version)
  FmtCurVers[TypesCount + 1] := OfsFree;               // 2 TypeInfo start Position
  // Add Types Names
  AddRowStrings( TypeNames );
  TypeNames.Free;

  // Add All used Types individual Versions,
  // All Types Maximal Version and Types Info Position
  // and Reserve space (4 bytes) for format data signature
  AddRowSInts( TypesCount + 4, SizeOf( Integer ), FmtCurVers );
  // Add TypeInfo Signature
  i := Length(K_DataFmtVerInfoSign) + 1;
  Move( K_DataFmtVerInfoSign[1], Buf1[OfsFree - i], i - 1 ); // (2 Ints)

end; //*** end of procedure TN_SerialBuf.AddDataFormatInfo

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\CheckUsedTypesInfo
//***************************************** TN_SerialBuf.CheckUsedTypesInfo ***
// Check Used Types Info
//
//     Parameters
// AFmtErrInfo - resulting List of Type Format Errors
//#F
//  AFmtErrInfo[i] - type error info: <TypeName> ...
//  AFmtErrInfo.Obects[i] - error code:
//    =0  - data type is absent
//    =1  - data format version is newer
//    =-1 - data format version is older
//#/F
// Result      - Returns format version comparision code
//#F
//  =2  - used types info is absent
//  =0  - resulting data format version is OK
//  =-1 - maximal data format version is older then application maximal format version
//  =1  - maximal data format version is newer then application maximal format version
//#/F
//
function TN_SerialBuf.CheckUsedTypesInfo( var AFmtErrInfo : TStrings ) : Integer;
var
  TypeNames : TStringList;
  i : Integer;
  TypesCount : Integer;
  WCurOfs: Integer;
  WOfsFree: Integer;
//!!  PCurBufPos : PChar;
  PCurBufPos : TN_BytesPtr;
  CurFD : TK_UDFieldsDescr;
  FmtVerCode : Integer;
  TypeName : string;
  FmtVerErrInfo : string;
begin
  Result := 2;
  // Check TypeInfo Signature;
  WCurOfs := Length(K_DataFmtVerInfoSign) + 1;
//!!  PCurBufPos := PChar(@Buf1[OfsFree - WCurOfs]);
  PCurBufPos := TN_BytesPtr(@Buf1[OfsFree - WCurOfs]);
  if not CompareMem( @K_DataFmtVerInfoSign[1],
                     PCurBufPos,
                     WCurOfs - 1 ) then Exit;
  Result := 0;
  Dec( PCurBufPos, SizeOf(Integer) );
  OfsFree := PInteger(PCurBufPos)^; // Get TypeInfo Start Position
  Dec( PCurBufPos, SizeOf(Integer) );
  if K_SPLDataCurFVer = PInteger(PCurBufPos)^ then
    Exit // Serialised Data and Application format Version is OK
  else if PInteger(PCurBufPos)^ < K_SPLDataCurFVer then
    Result := -1 // maximal Data Format Version is Older
  else
    Result := 1; // maximal Data Format Version is Newer


//*** Check Types Info
  // Save current Buffer Bounds
  WCurOfs := CurOfs;
  WOfsFree := OfsFree;
  // Set Buffer Bounds for Types Info Get
  CurOfs := WOfsFree;
//!!  OfsFree := PCurBufPos - PChar(@Buf1[0]);
  OfsFree := PCurBufPos - TN_BytesPtr(@Buf1[0]);
  // Get Type Names
  TypeNames := TStringList.Create;
  GetRowStrings( TypeNames );

  // Check Details
  TypesCount := TypeNames.Count;
  if AFmtErrInfo <> nil then AFmtErrInfo.Clear;
//!!  PCurBufPos := PChar(@Buf1[CurOfs]); // Type Versions Start Pointer
  PCurBufPos := TN_BytesPtr(@Buf1[CurOfs]); // Type Versions Start Pointer
  for i := 0 to TypesCount - 1 do begin
    TypeName := TypeNames[i];
    CurFD := K_GetTypeCode( TypeNames[i] ).FD;

    FmtVerCode := 2;
    if Integer(CurFD) = -1 then begin
      FmtVerCode := 0;  // Type is absent
      FmtVerErrInfo :=  'Type ' + TypeName + ' is absent in SPL';
    end else if PInteger(PCurBufPos)^ < CurFD.FDCurFVer then begin
      FmtVerCode := -1; // Data Format Version is Older
      FmtVerErrInfo :=  'Type ' + TypeName +
         ' Prev Data CurF=' + IntToStr(PInteger(PCurBufPos)^) +
         ' *** SPL CurF=' + IntToStr(CurFD.FDCurFVer);
    end else if PInteger(PCurBufPos)^ > CurFD.FDCurFVer then begin
      FmtVerCode := 1;  // Data Format Version is Newer
      FmtVerErrInfo :=  'Type ' + TypeName +
         ' New Data CurF=' + IntToStr(PInteger(PCurBufPos)^) +
         ' *** SPL CurF=' + IntToStr(CurFD.FDCurFVer);
    end;

    if FmtVerCode <> 2 then begin  // type version is wrong
      // Fix Type Format Error
      if AFmtErrInfo = nil then
        AFmtErrInfo := TStringList.Create;
      AFmtErrInfo.AddObject( FmtVerErrInfo, TObject(FmtVerCode) );
    end;

    Inc( PCurBufPos, SizeOf(Integer) );

  end;

  if (AFmtErrInfo = nil) or (AFmtErrInfo.Count = 0) then
    Result := 0; // Detail analysis is OK

  CurOfs := WCurOfs;
  OfsFree := WOfsFree;
  TypeNames.Free;
end; //*** end of procedure TN_SerialBuf.CheckUsedTypesInfo

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\ShowProgress
//*********************************************** TN_SerialBuf.ShowProgress ***
// Start progress info during parsing or adding data process
//
procedure TN_SerialBuf.ShowProgress;
begin
  N_PBCaller.Update( CurOfs );
end; //*** end of procedure TN_SerialBuf.ShowProgress

//##path K_Delphi\SF\K_clib\K_SBuf.pas\TN_SerialBuf\StartProgress
//********************************************** TN_SerialBuf.StartProgress ***
// Update progress info during parsing or adding data process
//
procedure TN_SerialBuf.StartProgress;
begin
  N_PBCaller.Start( OfsFree );
end; //*** end of procedure TN_SerialBuf.ShowProgress

initialization

  K_S2W := N_StringToWide;
  K_S2A := N_StringToAnsi;
  K_W2S := N_WideToString;
  K_A2S := N_AnsiToString;
  K_CalcNewCapacity := K_NewCapacity;

end.

