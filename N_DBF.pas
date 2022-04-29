unit N_DBF;
// TN_DBF class for managing DBF files

interface

uses
  Classes,
  N_Types, N_Lib1, K_VFunc;

type
{type} TN_DBFConvFlags = ( K_dbfTrimString, K_dbfToOEM );
{type} TN_DBFConvFlagSet = Set of TN_DBFConvFlags;
{type} TN_DBFHField = record  //*** whole file or field header descriptor
    case Integer of
      0: ( //*** whole file header
           FType    : Byte;      // DBF file Type
           YY,MM,DD : Byte;      // date (YY=Year-1900, MM-Month, DD-Date)
           RecCount : TN_UInt4;  // Number of records in file
           RecPos   : TN_UInt2;  // initial record position (after file header,
                                 // on control character of first record)
           RecSize  : TN_UInt2;  // record size in bytes (including control character)
         );
      1: ( //*** field header
           FieldName : array[0..10] of Char; // zero terminated field name
           FieldType : Char;       // field (type C or N)
           FieldPos  : TN_UInt2;   // field pos (offset) inside record
                                   // (control character is not considered)
           R2        : TN_UInt2;   // reserved
           FieldSize : Byte;       // field size in bytes
           FieldPrec : Byte        // field precision (for N type fields only)
          );
      2: ( //*** just to set record size equal to 32 bytes
           RBuf      : array [0..31] of Byte )
end;  //*** end of type TN_DBFHField = record

//************************************* TN_DBF class description ***
// class for DBF file
{type} TN_DBF = class( TObject )
    Header  : array of TN_DBFHField; // file and all fields headers
    Records : TStringList;
    CurField: Integer; // current field (counting from 1)
    CurFmt : string;
    CurDataType : TK_ParamType;
    ConvFlagSet : TN_DBFConvFlagSet;
    constructor Create( ); overload;
    destructor  Destroy( ); override;
    procedure SaveToFile         ( const FName : string );
    procedure LoadFromFile       ( const FName : string );
    procedure LoadHeaderFromFile ( const FName : string );
    procedure LoadHeader         ( var Fh: File );
    function  FieldIndexOf       ( AFieldName: string ): integer;
    procedure AddField ( const AFieldName : string; AFieldType : char;
                                AFieldSize : Integer; AFieldPec : Integer = 0  );
    procedure InsField ( const AFieldName : string; AFieldType : char;
                               AFieldSize : Integer; AFieldPec : Integer = 0  );
    procedure DelField ( const AFieldName : string );
    procedure DelCurField ( );
    function  SetCurField ( const AFieldName : string ) : Integer;
    function  GetCurFieldValue ( RecNumber : Integer; var DataBuf : TK_DataBuf ) : Boolean;
    function  SetCurFieldValue ( RecNumber : Integer; var DataBuf : TK_DataBuf ) : Boolean;

    procedure AddRecords ( ARecCount : Integer = 0 );
    procedure InsRecords ( RecNumber, ARecCount: Integer );
    procedure DelRecords ( RecNumber, ARecCount: Integer; MarkDel : boolean = false );
    procedure CompressRecords ();
    procedure GetDescription ( SList: TStrings );
  private
    function FFieldName     ( FieldNum : Integer ) : string;
    function FFieldType     ( FieldNum : Integer ) : TK_ParamType;
    function FFieldSize     ( FieldNum : Integer ) : Integer;
    function FFieldPrecSize ( FieldNum : Integer ) : Integer;
    function FRecSize   (  ) : Integer;
    function FRecCount  (  ) : Integer;
    function FFieldCount(  ) : Integer;
  protected
  public
    property FieldName[i: Integer]: string read FFieldName;
    property FieldType[i: Integer]: TK_ParamType read FFieldType;
    property FieldSize[i: Integer]: Integer read FFieldSize;
    property FieldPrecision[i: Integer]: Integer read FFieldPrecSize;
    property RecCount: Integer read FRecCount;
    property RecSize : Integer read FRecSize;
    property FieldCount : Integer read FFieldCount;
end;
//*****************************  end of TN_DBF class description ***

implementation
uses SysUtils;

//************************************************ ParamTypeToDBF ***
// convert TK_ParamType to DBF letter field type (local function)
//
function ParamTypeToDBF( AFieldType : TK_ParamType ) : Char;
begin
  Result := 'C';
  case AFieldType of
    K_isInteger,
    K_isDouble : Result := 'N';
    K_isString : Result := 'C';
    K_isDate   : Result := 'D';
  else
    assert( true, 'Wrong DBF Data type' );
  end;
end; // function ParamTypeToDBF

//************************************************ TN_DBF.Create ***
//
constructor TN_DBF.Create(  );
var
  Year, Month, Day: Word;
begin
  inherited;
  SetLength( Header, 1 );
  FillChar( Header[0], SizeOf(TN_DBFHField), 0 );
  Header[0].FType := 3;
  Header[0].RecSize := 1;
  CurField := 1;
  Include( ConvFlagSet, K_dbfTrimString );
  Records := TStringList.Create;
  DecodeDate( Date, Year, Month, Day );
  Header[0].YY := Year - 1900;
  Header[0].MM := Month;
  Header[0].DD := Day;
end; // constructor TN_DBF.Create

//************************************************ TN_DBF.Destroy ***
//
destructor TN_DBF.Destroy;
begin
  Header := nil;
  Records.Free;
//  inherited;
end; // destructor TN_DBF.Destroy


//************************************************ TN_DBF.SaveToFile ***
// save self as DBF file with given File Name
//
procedure TN_DBF.SaveToFile( const FName : string );
var
  Fh: File;
  i, Count : Integer;
begin
  AssignFile( Fh, FName );
  Rewrite   ( Fh, 1 );
//*** load Header
  Header[0].RecPos := Length(Header)* Sizeof(TN_DBFHField) + 1;
  BlockWrite ( Fh, Header[0], Header[0].RecPos - 1 ); // Write Header
  Count := $0D;
  BlockWrite ( Fh, Count, 1 ); // Write End Marker
  Count := Header[0].RecSize;

  for i := 0 to Records.Count - 1 do
    BlockWrite ( Fh, Records.Strings[i][1], Count );
  Count := $1A;
  BlockWrite ( Fh, Count, 1 ); // Write End Marker
  CloseFile ( Fh );
end; // procedure TN_DBF.SaveToFile

//************************************************ TN_DBF.LoadFromFile ***
// load self from DBF file with given File Name
//
procedure TN_DBF.LoadFromFile( const FName : string );
var
  SBuf : string;
  Fh: File;
  i, Count : Integer;
begin
  AssignFile( Fh, FName );
  Reset     ( Fh, 1 );
//*** load Header
  BlockRead ( Fh, Header[0], Sizeof(TN_DBFHField) ); // read Header[0]
  SetLength( Header, Round( Header[0].RecPos / Sizeof(TN_DBFHField) ) );
  if Header[0].RecPos > Sizeof(TN_DBFHField) then
    BlockRead ( Fh, Header[1], Header[0].RecPos - Sizeof(TN_DBFHField) - 1 );
  seek( Fh, FilePos(Fh)+1 );
  Count := 1;
  for i := 1 to High(Header) do
  begin
    Header[i].FieldPos := TN_UInt2(Count);
    Count := Count + Header[i].FieldSize;
  end;
//*** load Records
  Records.Clear;
  Count := Header[0].RecSize;
  SetLength( SBuf, Count );
  for i := 1 to Header[0].RecCount do
  begin
    BlockRead ( Fh, SBuf[1], Count );
    Records.Add( SBuf );
  end;
  CloseFile ( Fh );
end; // procedure TN_DBF.LoadFromFile

//***************************************** TN_DBF.LoadHeaderFromFile ***
// load Header from DBF file with given File Name
//
procedure TN_DBF.LoadHeaderFromFile( const FName : string );
var
  Fh: File;
begin
  N_ROpenFile( Fh, FName );
  LoadHeader( Fh );
  CloseFile ( Fh );
end; // procedure TN_DBF.LoadHeaderFromFile

//***************************************** TN_DBF.LoadHeader ***
// load Header from DBF file with given File Handle
//
procedure TN_DBF.LoadHeader( var Fh: File );
var
  i, Count : Integer;
begin
  seek( Fh, 0 );
  BlockRead ( Fh, Header[0], Sizeof(TN_DBFHField) ); // read Header[0]
  SetLength( Header, Round( Header[0].RecPos / Sizeof(TN_DBFHField) ) );
  if Header[0].RecPos > Sizeof(TN_DBFHField) then
    BlockRead ( Fh, Header[1], Header[0].RecPos - Sizeof(TN_DBFHField) - 1 );
  seek( Fh, FilePos(Fh)+1 );
  Count := 1;

  for i := 1 to High(Header) do
  begin
    Header[i].FieldPos := TN_UInt2(Count);
    Count := Count + Header[i].FieldSize;
  end;
end; // procedure TN_DBF.LoadHeader

//***************************************** TN_DBF.LoadHeader ***
// Return Field Index by given Field Name
//
function TN_DBF.FieldIndexOf( AFieldName: string ): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 1 to High(Header) do
  begin
    if AFieldName = Header[i].FieldName then
    begin
      Result := i;
      Exit;
    end;
  end; // for i := 1 to High(Headers) do
end; // function TN_DBF.FieldIndexOf

//************************************************ TN_DBF.AddField ***
// add one more field (as last one)
//
procedure TN_DBF.AddField( const AFieldName : string; AFieldType : char;
                                AFieldSize : Integer; AFieldPec : Integer = 0  );
begin
  CurField := Length(Header);
  InsField( AFieldName, AFieldType, AFieldSize, AFieldPec );
end; // procedure TN_DBF.AddField

//************************************************ TN_DBF.InsField ***
// insert one more field at CurField position ( CurField=1 for initial field)
//
procedure TN_DBF.InsField( const AFieldName : string; AFieldType : char;
                                AFieldSize : Integer; AFieldPec : Integer = 0  );
var i, FPos : Integer;
sbuf : string;
begin
  SetLength( Header, Length(Header) + 1 );
  i := High(Header) - CurField;
  if i > 0 then
    Move( Header[CurField], Header[CurField + 1], i * SizeOf(TN_DBFHField) );
  if CurField = 1 then
    FPos := 1
  else if i > 0 then
    FPos := Header[CurField].FieldPos
  else
    FPos := Header[0].RecSize;
  FillChar( Header[CurField], SizeOf(TN_DBFHField), 0 );

  with Header[CurField] do
  begin
    StrLCopy( @FieldName[0], PChar(UpperCase(AFieldName)), 10 );
//!!    FieldType := ParamTypeToDBF( AFieldType );
    Assert( (AFieldType = 'C') or (AFieldType = 'N') or (AFieldType = 'D'),
                                    'Bad field type (' + AFieldType + ')'  );
    FieldType := AFieldType;
    FieldPos := FPos;
    FieldSize := TN_UInt1( AFieldSize );
    FieldPrec := TN_UInt1( AFieldPec );
  end;
  Inc( Header[0].RecSize, AFieldSize );

  for i := CurField + 1 to High(Header) do
    Inc( Header[i].FieldPos,  AFieldSize );

  for i := Records.Count - 1 downto 0 do
  begin
    sbuf := Records.Strings[i];
    Insert( StringOfChar( ' ', AFieldSize ), sbuf, FPos + 1 );
    Records.Strings[i] := sbuf;
  end;
end; // procedure TN_DBF.InsField

//************************************************ TN_DBF.DelField ***
// delete field with given name
//
procedure TN_DBF.DelField( const AFieldName : string );
begin
  SetCurField( AFieldName );
  DelCurField;
end; // procedure TN_DBF.DelField

//************************************************ TN_DBF.DelCurField ***
// delete field with CurField number (CurField=1 for initial field)
//
procedure TN_DBF.DelCurField(  );
var i, FPos, FSize, SPos, MLeng : Integer;
sbuf : string;
begin
  if (CurField < 1) or (CurField > High(Header)) then exit;
  FPos := Header[CurField].FieldPos;
  FSize := Header[CurField].FieldSize;
  SPos := FPos + FSize;
  MLeng := Header[0].RecSize - SPos;
  Dec( Header[0].RecSize, FSize );

  for i := Records.Count - 1 downto 0 do
  begin
    sbuf := Records.Strings[i];
    if MLeng <> 0 then
      Move( sbuf[SPos + 1], sbuf[FPos + 1], MLeng );
    SetLength( sbuf, Header[0].RecSize );
    Records.Strings[i] := sbuf;
  end;

  if MLeng <> 0 then
  begin
    i := High(Header) - CurField;
    Move( Header[CurField + 1], Header[CurField], i * SizeOf(TN_DBFHField) );
  end;

  SetLength( Header, High(Header) );

  for i := CurField to High(Header) do
    Dec( Header[i].FieldPos,  FSize );
end; // procedure TN_DBF.DelCurField

//************************************************ TN_DBF.SetCurField ***
// set self fields CurField and CurFmt by given field name
// (to increase speed)
//
function  TN_DBF.SetCurField( const AFieldName : string ) : Integer;
var i : Integer;
fsize : string;
begin
  Result := -1;
  fsize := UpperCase( AFieldName );

  for i := 1  to High(Header) do
  begin
    if StrComp( @Header[i].FieldName[0], PChar(fsize) ) = 0 then
    begin
      Result := i;
      CurField := i;
      break;
    end;
  end; // for i := 1  to High(Header) do

  if Result = -1 then Exit;
  CurFmt := '';

  with Header[CurField] do
  begin
    CurDataType := FFieldType(CurField);
    fsize := IntToStr(FieldSize);
    case CurDataType of
      K_isDouble : CurFmt := '%'+fsize+'.'+IntToStr(FieldPrec)+'f';
      K_isInteger: CurFmt := '%'+fsize+'d';
      K_isString : CurFmt := '%-'+fsize+'.'+fsize+'s';
    end;
  end; // with Header[CurField] do

end; // function  TN_DBF.SetCurField

//************************************************ TN_DBF.GetCurFieldValue ***
// get value of CurField in RecNumber record into DataBuf variable
// (string, integer or double)
// return True if OK or False if failed
//
function TN_DBF.GetCurFieldValue( RecNumber : Integer;
                                var DataBuf : TK_DataBuf ) : Boolean;
var
  sbuf: string;
  AnsiStr: AnsiString;
begin
  Result := false;
  if (RecNumber < 0) or (RecNumber >= Records.Count) then exit;
  with Header[CurField] do
  begin
    sbuf := Copy( Records.Strings[RecNumber], FieldPos + 1, FieldSize );
    if (K_dbfTrimString in ConvFlagSet) or
       (CurDataType <> K_isString) then
      sbuf := Trim( sbuf );
    if (CurDataType = K_isString) and (K_dbfToOEM in ConvFlagSet) then
    begin
      AnsiStr := AnsiString( sbuf );
      DataBuf.StrData := N_DosToWin( AnsiStr );
    end else
      DataBuf.StrData := sbuf;
    if (CurDataType <> K_isString) then
      K_DataBufFromString( sbuf, DataBuf, CurDataType );
  end;
  Result := true;
end; // function TN_DBF.GetCurFieldValue

//************************************************ TN_DBF.SetCurFieldValue ***
// set value of CurField in RecNumber record from given DataBuf variable
// (string, integer or double)
// return True if OK or False if failed
//
function TN_DBF.SetCurFieldValue( RecNumber : Integer;
                                        var DataBuf : TK_DataBuf ) : Boolean;
var sbuf, fbuf : AnsiString;
begin
  Result := false;
  if (RecNumber < 0) or (RecNumber >= Records.Count) then exit;
  fbuf := AnsiString(K_DataBufToString( DataBuf, CurDataType, CurFmt ));
  sbuf := AnsiString(Records.Strings[RecNumber]);
  if (CurDataType = K_isString) and (K_dbfToOEM in ConvFlagSet) then
    fbuf := N_WinToDos( String( fbuf ));
  with Header[CurField] do
    Move( fbuf[1], sbuf[FieldPos + 1], FieldSize );
  Records.Strings[RecNumber] := String( sbuf );
  Result := true;
end; // function TN_DBF.SetCurFieldValue

//************************************************ TN_DBF.AddRecords ***
// add given number of empty records
//
procedure TN_DBF.AddRecords( ARecCount: Integer );
var i : Integer;
sbuf : string;
begin
  sbuf := StringOfChar( ' ', Header[0].RecSize + 1 );
  for i := 1 to ARecCount do
    Records.Add( sbuf );
  Header[0].RecCount := Records.Count;
end; // procedure TN_DBF.AddRecords

//************************************************ TN_DBF.InsRecords ***
// insert given number of empty records before given RecNumber
//
procedure TN_DBF.InsRecords( RecNumber, ARecCount: Integer );
var i : Integer;
sbuf : string;
begin
  sbuf := StringOfChar( ' ', Header[0].RecSize + 1 );
  for i := 1 to ARecCount do
    Records.Insert( RecNumber, sbuf );
  Header[0].RecCount := Records.Count;
end; // procedure TN_DBF.InsRecords

//************************************************ TN_DBF.DelRecords ***
// delete (if MarkDel = False) or just mark as deleted (if MarkDel = True)
// given number of records beginning from given RecNumber
//
procedure TN_DBF.DelRecords( RecNumber, ARecCount: Integer;
                                                MarkDel: boolean = false );
var i : Integer;
sbuf : string;
begin
  Inc( ARecCount, RecNumber - 1 );
  for i := RecNumber to ARecCount do
    if MarkDel then
    begin
      sbuf := Records.Strings[i];
      sbuf[1] := '*';
      Records.Strings[i] := sbuf;
    end else
      Records.Delete( RecNumber );
  Header[0].RecCount := Records.Count;
end; // procedure TN_DBF.DelRecords

//************************************************ TN_DBF.CompressRecords ***
// compress records (delete records, marked as  deleted)
//
procedure TN_DBF.CompressRecords;
var i : Integer;
begin
  for i := Records.Count - 1 downto 0 do
    if Records.Strings[i][1] = '*' then
     Records.Delete( i );
  Header[0].RecCount := Records.Count;
end; // procedure TN_DBF.CompressRecords

//*************************************************** TN_DBF.GetDescription ***
// add file and fields description to given StringList
//
procedure TN_DBF.GetDescription( SList: TStrings );
var i : Integer;
sbuf : string;
begin
  with Header[0] do
  SList.Add( Format( 'DBF File - Type: %d, Date: %.2d.%.2d.%d, NumRecs: %d, RecSize: %d',
                    [ FType, DD, MM, YY+1900, RecCount, RecSize ] ) );

  for i := 1 to High(Header) do
    with Header[i] do
    begin
      if FieldPrec = 0 then sbuf := ''
                       else sbuf := '.' + IntToStr( FieldPrec );
      SList.Add( Format( '    %10s   %d%s%s',
                            [ FieldName, FieldSize, sbuf, FieldType ] ) );
    end;
end; // procedure TN_DBF.GetDescription

        //************** private functions ***************

//************************************************ TN_DBF.FFieldName ***
// return FieldName of given FieldNum (counting from 1)
//
function TN_DBF.FFieldName( FieldNum: Integer ): string;
begin
  if (FieldNum > 0) and (FieldNum <= High(Header)) then
    Result := copy( string( Header[FieldNum].FieldName ), 0, 10 )
  else
    Result := '';
end; // function TN_DBF.FFieldName

//************************************************ TN_DBF.FFieldPrecSize ***
// return FieldPrecision of given FieldNum (counting from 1)
//
function TN_DBF.FFieldPrecSize( FieldNum: Integer ): Integer;
begin
  if (FieldNum > 0) and (FieldNum <= High(Header)) then
    Result := Header[FieldNum].FieldPrec
  else
    Result := -1;
end; // function TN_DBF.FFieldPrecSize

//************************************************ TN_DBF.FFieldSize ***
// return FieldSize of given FieldNum (counting from 1)
//
function TN_DBF.FFieldSize( FieldNum: Integer ): Integer;
begin
  if (FieldNum > 0) and (FieldNum <= High(Header)) then
    Result := Header[FieldNum].FieldSize
  else
    Result := -1;
end; // function TN_DBF.FFieldSize

//************************************************ TN_DBF.FFieldType ***
// return FieldType (as TK_ParamType) of given FieldNum (counting from 1)
//
function TN_DBF.FFieldType( FieldNum: Integer ): TK_ParamType;
var
CType : Char;
begin
  if (FieldNum > 0) and (FieldNum <= High(Header)) then
    CType := Header[FieldNum].FieldType
  else
    CType := Chr($0);
  case CType of
    'C' : Result := K_isString;

    'N' :
    begin
      if (Header[FieldNum].FieldPrec <> 0) or
         (Header[FieldNum].FieldSize > 11) then
        Result := K_isDouble
      else
        Result := K_isInteger;
    end;
    'D' : Result := K_isDate;
  else
    Result := K_isUndefinedData;
  end;
end; // function TN_DBF.FFieldType

//************************************************ TN_DBF.FFieldCount ***
// return FieldCount property
//
function TN_DBF.FFieldCount: Integer;
begin
  Result := High(Header);
end; // function TN_DBF.FFieldCount

//************************************************ TN_DBF.FRecCount ***
// return RecordCount property
//
function TN_DBF.FRecCount: Integer;
begin
  Result := Header[0].RecCount;
end; // function TN_DBF.FRecCount

//************************************************ TN_DBF.FRecSize ***
// return RecordSize property
//
function TN_DBF.FRecSize: Integer;
begin
  Result := Header[0].RecSize;
end; // function TN_DBF.FRecSize

end.
