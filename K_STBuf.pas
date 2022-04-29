unit K_STBuf;
{$ASSERTIONS ON}

// serialization methods and structures

// type TK_SerialTextBuf = class( TObject ) //***** SerialBuf class

interface
uses
  Windows, Graphics, Classes, Sysutils, IniFiles,
  K_CLib0, K_parse, K_BArrays, K_VFunc,
  N_Types, N_Lib1, N_Gra0, N_Gra1;

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_STBufTagType
type TK_STBufTagType = ( // types of read/write tag
  tgOpen,  // open Tag is parsed
  tgClose, // close Tag is parsed
  tgNone,  // no Tag is parsed
  tgEOF    // end of file is found
);
{
type TK_STBufAttrType = // types of read/write tag
( ttString, ttInteger, ttInt64, ttDouble, ttDate, ttHex, ttHex2, ttHex4, ttHex6,
  ttHex8, ttHex16, ttBoolean );
}

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf
//******************************************************** TK_SerialTextBuf ***
// Text Buffer for Data Serialization class
//
// Is used for IDB Data Text Serialization
//
type TK_SerialTextBuf = class( TObject ) //*****
  public
    TextStrings : TStringList; // bufer for storing serialized data
    OfsFreeM: integer;   // free place position in Line Buffer while saving to 
                         // text and text data size while parsing from text
    St : TK_Tokenizer;  // string tokenizer for parsing from text
    LineMaxSize : Integer; // line maximal size while saving to text
    LineOffset : Integer;  // line first char current offset
    LineOffsetIncr : Integer; // line current offset increasing step
    AddAttrsLineOffset: Integer; // additional line offset for tag attributes if
                                 // <0 then current tag name length is used
    AttrsList : THashedStringLIst; // list of current TAg parsed attributes 
                                   // values
    LastAddedTag : string; // last saved  Tag (for correct TK_RArray fields 
                           // saving)
    LastParsedTag : string; // last parsed Tag (for correct TK_RArray fields 
                            // parsing)
    PrevParsedTag : string; // previous parsed Parsed Tag (for correct restoring
                            // of LastParsedTag)

    SBUsedTypesList : TList; // list of serialized data SPL types objects
//##/*
    constructor Create;
    destructor  Destroy; override;
//##*/
    procedure SetBrackets( const ABrackets : string );
    procedure InitLoad0;
    procedure InitLoad1;
    procedure InitSave;
//    procedure InitLineBuffer;
    procedure SetCapacity( ANewCapacity : Integer );
    procedure IncCapacity( AIncVal : Integer );

    procedure AddTag( ATag: string; ATagType : TK_STBufTagType = tgOpen );
    procedure GetTag( out ATag: string; out ATagType : TK_STBufTagType );
    function  CheckPrevParsedTagCloseFlag( ATag : string ) : Boolean;
    function  GetSpecTag( const ATag : string; ATagType : TK_STBufTagType;
                                         AStopErrorFlag : boolean = true ) : Boolean;
    procedure TestTokenType( out ATagType : TK_STBufTagType );
    procedure SetBufPos( APos : Integer );
    procedure GetBufPos( out APos : Integer );

    procedure AddEOL( ACheckTag : Boolean = true  );
    procedure AddChars( const AChars : string; ACheckTag : Boolean = false );
//    function  SkipChars( const Str : string ) : Boolean;
//    function  GetSubString( const TermString : string ) : string;

//    function  GetChar( PosShift : Integer = 0 ) : Char;
//    function  GetAttr( out Delim : Char ) : string;
    function  ShiftLineOffs( AShift : Integer ) : Integer;
    procedure SetLineSize( ALSize : Integer );
    function  ShiftLinePos( AShift : Integer ) : Integer;

    procedure AddTagAttr( AttrName : string; const AttrValue;
                AType : TK_ParamType = K_isString; AFmt : string = '' );
    function  GetTagAttr( AttrName : string;  out AttrValue;
                        AType : TK_ParamType = K_isString ) : Boolean;
    procedure AddToken ( const AStr: String; ATokenType : TK_TokenType = K_ttToken;
                                ATokenDelimeter : Char = #0 );
    procedure GetToken ( var AStr: String );

    procedure AddScalar( const AValue; AType : TK_ParamType = K_isString;
                                                AFmt : string = '' );
    procedure GetScalar( var AValue; AType : TK_ParamType = K_isString );

    procedure AddRowScalars( var AData; const ACount, AStep: integer;
                         AType : TK_ParamType = K_isString;
                         ALineCount : Integer = 10; AFmt : string = '' );
    function  GetRowScalars( var AData; const ACount, AStep: integer;
                         AType : TK_ParamType = K_isString ) : Integer;

    procedure AddArray( const ADArray; AType : TK_ParamType = K_isStringArray;
                         const ATag : string = '';
                         ALineCount : Integer = 10; AFmt : string = '' );
    procedure GetArray( var ADArray; AType : TK_ParamType = K_isStringArray;
                        const ATag : string = ''; ALength : Integer = -1 );
{
    procedure AddRowSDoubles( const Accuracy, Count, BStep: integer;
                              var PDouble;
                              lineCount : Integer = 10; fmt : string = '' );
    procedure AddDoubleArray ( const DArray: TN_DArray; Accuracy : Integer;
                               const Tag : string = ''; lineCount : Integer = 10;
                               fmt : string = '' );
    procedure GetDoubleArray ( var DArray: TN_DArray; var Accuracy : Integer;
                               const Tag : string = ''; ALength : Integer = -1 );
}
//##/*
    procedure AddRowBytes ( const ACount: integer; const APBytes: Pointer );
    procedure GetRowBytes ( const ACount: integer; const APBytes: Pointer );
//##*/
    procedure AddBytes     ( APByte: PByte; ANumBytes: integer );
    procedure GetBytes     ( APByte: PByte; ANumBytes: integer );

    procedure AddIntegers  ( APInteger: PInteger; ANumIntegers: integer );
    procedure AddHexInts   ( APInteger: PInteger; ANumIntegers: integer );
    procedure GetIntegers  ( APInteger: PInteger; ANumIntegers: integer );

    procedure AddFloats    ( APFloat: PFloat; ANumFloats: integer );
    procedure GetFloats    ( APFloat: PFloat; ANumFloats: integer );

    procedure AddDoubles   ( APDouble: PDouble; ANumDoubles: integer );
    procedure GetDoubles   ( APDouble: PDouble; ANumDoubles: integer );

    procedure AddStrings   ( APString: PString; ANumStrings: integer );
    procedure GetStrings   ( APString: PString; ANumStrings: integer );

    procedure AddFPoints ( AFPArray: TN_FPArray; AFirstInd, ANumPoints,
                                      ACoordsFmtMode, AMaxChars, AAccuracy: integer );
    function  GetFPoints ( var AFPArray: TN_FPArray; var AFreeInd: integer;
                           ANumPoints, ACoordsFmtMode, AAccuracy: integer ): integer;

    procedure AddDPoints ( ADPArray: TN_DPArray; AFirstInd, ANumPoints,
                                      ACoordsFmtMode, AMaxChars, AAccuracy: integer );

    function  GetDPoints ( var ADPArray: TN_DPArray; var AFreeInd: integer;
                           ANumPoints, ACoordsFmtMode, AAccuracy: integer ): integer;

    procedure AddBitMap     ( ABMP: TBitMap; const ATag : string = '' );
    procedure GetBitMap ( var ABMP: TBitMap; const ATag : string = '' );

    procedure AddRowStrings ( ASL: TStrings; const ATag : string = '' );
    procedure GetRowStrings ( ASL: TStrings; const ATag : string = '' );

    procedure SaveToFile( const AFileName: String );
    procedure LoadFromFile( const AFileName: String );
    procedure LoadFromText( const AText : String );
    function  GetRowNumber ( AShiftPos : Integer = 0 ): Integer;
    procedure ShowErrorMessage( const AMes : string );
    function  PrepErrorMessage( const AMes : string ) : string;
    procedure AddDataFormatInfo( ASkipFormatInfo : Boolean = FALSE );
    function  CheckUsedTypesInfo( var AFmtErrInfo : TStrings ) : Integer;
    procedure ShowProgress;
    property  Brackets : string write SetBrackets;
      private
//##/*
    RowStart, RowSize : Integer;
    tagDelims : string;
    dataDelims : string;
    attrDelims : string;
    dataBrackets : string; // string with pairs of brackets chars <OpenChar1><CloseChar1>...<OpenCharN><CloseCharN>
//##*/
end; //*** end of type TK_SerialTextBuf = class( TObject )

//****************** Global procedure **********************

var K_SerialTextBuf: TK_SerialTextBuf;

implementation

uses
  Math, Dialogs, Forms, StrUtils,
  K_UDT1, K_UDT2, N_ClassRef, K_UDConst, K_Script1, K_UDC,
  N_Lib0;

//************* Delphi 7 and Delphi 2010 specific Declarations

const
// Is used instead of ' 0' chars set, is needed for Optimal Float Text Serialization
//{$IF SizeOf(Char) = 2} // Wide Chars (Delphi 2010) Types and constants
//  N_IntWhiteSpaceZero = $00300020;
//{$ELSE} //*************** Ansi Chars (Delphi 7) Types and constants
//  N_IntWhiteSpaceZero = $3020; // Needed for Optimal Floats Text Serialization
//{$IFEND}
  K_StrWhiteSpaceZero = ' 0'; // Needed for Optimal Floats Text Serialization

const
K_CommentBracketsStartChar1 = '/';
K_CommentBracketsStartChar2 = '*';
K_CommentBracketsFinChar1 = '*';
K_CommentBracketsFinChar2 = '/';
K_DataFmtVerInfoSign = '*S*P*L*';
K_DataFmtVerTag = 'DFI';


//************************************************ TK_SerialTextBuf.Create ***
//
constructor TK_SerialTextBuf.Create;
begin
  Inherited;
  TextStrings :=  TStringList.Create;
//  SaveRefList := TList.Create;
//  LoadRefList := TK_BaseArray.Create( 5, SizeOf(TK_UDBuildID) );
//  LoadRefList.CompareProc := K_CmpInt1;
//  LoadRefList.Duplicates := dupIgnore;
//  LoadRefList.SortOrder := tsAscending;
  tagDelims  := ' ='+Chr($09)+Chr($0D)+Chr($0A)+K_TagOpenChar+K_TagCloseFlag+K_TagCloseChar;
  dataDelims := ' ' +Chr($09)+Chr($0D)+Chr($0A);
  attrDelims := ' ='+Chr($09)+Chr($0D)+Chr($0A)+K_TagCloseFlag+K_TagCloseChar;
  dataBrackets := '""''''{}';
  AttrsList := THashedStringList.Create;
//!!  st := TK_Tokenizer.Create( StringBuf, dataDelims, dataBrackets );
  St := TK_Tokenizer.Create( '', dataDelims, dataBrackets );
  SBUsedTypesList := TList.Create();
  LineMaxSize := 60;
  LineOffset := 0;
  LineOffsetIncr := 2;

  InitSave();
end; //*** end of Constructor TK_SerialTextBuf.Create

//************************************************ TK_SerialTextBuf.Destroy ***
//
destructor TK_SerialTextBuf.Destroy;
begin
//!!  SetLength( StringBuf, 0 );
//  K_ClearRefList( SaveRefList );
//  SaveRefList.Free;
//  LoadRefList.Free;
  SetLength( tagDelims, 0 );
  SetLength( dataDelims, 0 );
  SetLength( attrDelims, 0 );
  SetLength( dataBrackets, 0 );
  K_FreeTStringsObjects(AttrsList);
  AttrsList.Free;
  TextStrings.Free;
  St.Free;
  K_ClearUsedTypesMarks( SBUsedTypesList );
  SBUsedTypesList.Free;
  Inherited;
end; //*** end of destructor TK_SerialTextBuf.Destroy

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\SetBrackets
//******************************************** TK_SerialTextBuf.SetBrackets ***
// Set new Brackets chars set for tokens separation
//
//     Parameters
// ABrackets - new brackets chars set
//
procedure TK_SerialTextBuf.SetBrackets( const ABrackets : string );
begin
  St.SetBrackets( ABrackets );
end; //*** end of TK_SerialTextBuf.SetBrackets

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\InitLoad0
//********************************************** TK_SerialTextBuf.InitLoad0 ***
// Self initialization before parsing serialized data from text
//
procedure TK_SerialTextBuf.InitLoad0;
begin
  St.SetSource( TextStrings.Text );
  St.setDelimiters(dataDelims);
  OfsFreeM := Length(st.Text);
end; //*** end of TK_SerialTextBuf.InitLoad

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\InitLoad1
//********************************************** TK_SerialTextBuf.InitLoad1 ***
// Prepare parsing text by skiping comments and then do Self initialization 
// before parsing serialized data from text
//
procedure TK_SerialTextBuf.InitLoad1;
var i : Integer;
CommentMode : Integer;
LongStr : Boolean;
begin
//*** clear comments loop start
  CommentMode := 0;
  i := 0;
  while i < TextStrings.Count do begin
    LongStr := (Length(TextStrings[i]) > 1);
    if LongStr and
       ( TextStrings[i][1] = K_CommentBracketsStartChar1) and
       ( TextStrings[i][2] = K_CommentBracketsStartChar2 ) then  begin
      TextStrings.Delete(i);
      Inc(CommentMode);
    end else if CommentMode > 0 then begin
      if LongStr and
         (TextStrings[i][1] = K_CommentBracketsFinChar1) and
         (TextStrings[i][2] = K_CommentBracketsFinChar2) then
        Dec(CommentMode);
      TextStrings.Delete(i);
    end else
      Inc(i);
  end; //*** clear comments loop fin

  InitLoad0();
  N_PBCaller.Start(OfsFreeM)
//  LoadRefList.Count := 0;
end; //*** end of TK_SerialTextBuf.InitLoad

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\InitSave
//*********************************************** TK_SerialTextBuf.InitSave ***
// Self initialization before data serialization
//
procedure TK_SerialTextBuf.InitSave( );
begin
//  InitLineBuffer;
  OfsFreeM := 1;
  TextStrings.Clear;
//!!  St.SetSource( StringBuf );
  St.SetSource( '' );
  St.setDelimiters(tagDelims);
  K_ClearUsedTypesMarks( SBUsedTypesList );
end; //*** end of procedure TK_SerialTextBuf.InitSave

{
//************************************************ TK_SerialTextBuf.InitLineBuffer ***
// Self initialization before data serialization
//
procedure TK_SerialTextBuf.InitLineBuffer( );
begin
  OfsFreeM := 1;
  St.CPos := 1;
end; //*** end of procedure TK_SerialTextBuf.InitLineBuffer
}

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\SetCapacity
//******************************************** TK_SerialTextBuf.SetCapacity ***
// Init text buffer capacity after data serialization
//
//     Parameters
// ANewCapacity - new capacity value in bytes
//
procedure TK_SerialTextBuf.SetCapacity( ANewCapacity : Integer );
begin
  K_SetStringCapacity( St.Text, ANewCapacity );
  St.setSource( St.Text );
end; //*** end of procedure TK_SerialTextBuf.SetCapacity

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\IncCapacity
//******************************************** TK_SerialTextBuf.IncCapacity ***
// Increment Line Buffer capacity
//
//     Parameters
// AIncVal - increment Line Buffer capacity value
//
procedure TK_SerialTextBuf.IncCapacity( AIncVal : Integer );
begin
  St.cpos := OfsFreeM;
  St.IncCapacity( AIncVal );
end; //*** end of procedure TK_SerialTextBuf.IncCapacity

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddTag
//************************************************* TK_SerialTextBuf.AddTag ***
// Add Tag start chars to line buffer current position
//
//     Parameters
// ATag     - adding Tag name
// ATagType - adding Tag type (enumeration) value
//
procedure TK_SerialTextBuf.AddTag( ATag: string; ATagType : TK_STBufTagType = tgOpen );
var Leng : Integer;
begin
  if ATagType = tgClose then begin
    ShiftLineOffs( -LineOffsetIncr );
    //*** check if open/close tag available
    if (LastAddedTag <> '')  and
       (LastAddedTag = ATag) and
       (OfsFreeM > 1)        and
       (St.Text[OfsFreeM - 1] = K_TagCloseChar) then begin
    //*** add open/close tag flag "/>"
      St.Text[OfsFreeM - 1] := ' ';
      IncCapacity( 3 );
      St.Text[OfsFreeM] := K_TagCloseFlag;
      St.Text[OfsFreeM+1] := K_TagCloseChar;
      Inc(OfsFreeM, 2);
      LastAddedTag := '';
      AddEOL( false );
      Exit;
    end;
  end;

  LastAddedTag := ATag;
  Leng := Length(ATag);
  if (OfsFreeM + Leng + 2 > LineMaxSize) then
    AddEOL( false );
  IncCapacity( Leng + 3 );
  St.Text[OfsFreeM] := K_TagOpenChar;
  Inc(OfsFreeM);
  if ATagType = tgClose then
  begin
    LastAddedTag := '';
    St.Text[OfsFreeM] := K_TagCloseFlag;
    Inc(OfsFreeM);
  end;
  Move( ATag[1], St.Text[OfsFreeM], Leng * SizeOf(Char) );
  Inc(OfsFreeM, Leng );
  St.Text[OfsFreeM] := K_TagCloseChar;
  Inc(OfsFreeM);
  if ATagType = tgClose then
    AddEOL( false )
  else
    ShiftLineOffs( LineOffsetIncr );
end; //*** end of procedure TK_SerialTextBuf.AddTag

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetTag
//************************************************* TK_SerialTextBuf.GetTag ***
// Parse any Tag data from text (Tag markers and Tag body attributes)
//
//     Parameters
// ATag     - parsing Tag name
// ATagType - parsing Tag type (enumeration) value
//
procedure TK_SerialTextBuf.GetTag( out ATag: string; out ATagType : TK_STBufTagType );
var
  lnum, tagTermIndex, i : Integer;
  AttrName : string;
//AttrValue : string;
//CR : TK_PObject;
   XMLComment : Boolean;

label FinAttrList;

begin
  repeat
    TestTokenType( ATagType );
    ATag := ''; // return emty tag string if EOF found
    if ATagType = tgEOF then Exit;
    XMLComment := (ATagType = tgOpen)      and
                  (St.Text[St.cpos+1] = '!') and
                  (St.Text[St.cpos+2] = '-') and
                  (St.Text[St.cpos+3] = '-');
    if XMLComment then
      St.setPos( PosEx( '--' + K_TagCloseChar, St.Text, St.cpos + 4 ) + 1 );
  until not XMLComment;

  St.setDelimiters(tagDelims);
  ATag := St.nextToken;
  //*** parse tag
  if ATagType = tgNone then // wrong tag start char - error!!!
  begin
    raise TK_LoadUDDataError.Create( PrepErrorMessage( 'Found "'+ATag+'" instead of tag start while loading line ' ) );
//    ShowErrorMessage( 'Found "'+Tag+'" instead of tag start while loading line ' );
//    assert(false);
  end;
  LastParsedTag := ATag;
  if ATagType = tgClose then
  begin
    if St.Text[St.cpos -1] <> K_TagCloseChar then
    begin // step to end of Tag
      St.setPos( PosEx( K_TagCloseChar, St.Text, St.cpos )+1);
    end;
    LastParsedTag := '';
  end else begin // get tag attributes
    lnum := 0;
    if St.Text[St.cpos -1] <> K_TagCloseChar then // check close tag
    begin
      St.setDelimiters(attrDelims);
//if ATag = 'CMSSlide' then
//ATag := 'CMSSlide';
  //*** parse atributes
      while St.cpos <= OfsFreeM do
      begin
        tagTermIndex := St.cpos - 1;
        St.hasMoreTokens;
        for i := tagTermIndex to St.cpos - 1 do
          if (St.Text[i] = K_TagCloseChar) then
            goto FinAttrList;

        AttrName := St.nextToken;
        if AttrName = '' then break;
        AttrName := AttrName + '=' + St.nextToken;
        if lnum >= AttrsList.Count then // add new element
          AttrsList.Add( AttrName  )
        else                       // use existing
          AttrsList.Strings[lnum] := AttrName ;
        Inc(lnum);
      end;

      raise TK_LoadUDDataError.Create( PrepErrorMessage( 'Tag terminator for tag "'+ATag+'" not found while loading line ' ) );
    end;

FinAttrList:
  //*** clear not used list elements
    while AttrsList.Count > lnum do
      AttrsList.Delete(lnum);

  end;


  St.setDelimiters(dataDelims);
end; //*** end of procedure TK_SerialTextBuf.GetTag

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\TestTokenType
//****************************************** TK_SerialTextBuf.TestTokenType ***
// Test if next lexem is close Tag marker
//
//     Parameters
// ATagType - parsing Tag type (enumeration) value
//
procedure TK_SerialTextBuf.TestTokenType( out ATagType : TK_STBufTagType );
begin
  ATagType := tgEOF;
  if not St.hasMoreTokens then Exit;
  ATagType := tgNone;
  if St.isBracketsStartFlag then Exit;
  if St.Text[st.cpos] = K_TagOpenChar then
  begin
    ATagType := tgOpen;
    if St.Text[st.cpos+1] = K_TagCloseFlag then
      ATagType := tgClose;
  end;
end; //*** end of procedure TestTokenType

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\SetBufPos
//********************************************** TK_SerialTextBuf.SetBufPos ***
// Set parsed text current position
//
//     Parameters
// APos - parsed text current position (absolute value)
//
procedure TK_SerialTextBuf.SetBufPos( APos : Integer );
begin
  St.shiftPos( APos - St.CPos );
end; //*** end of procedure TK_SerialTextBuf.SetBufPos

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetBufPos
//********************************************** TK_SerialTextBuf.GetBufPos ***
// Get parsed text current position
//
//     Parameters
// APos - resulting parsed text current position (absolute value)
//
procedure TK_SerialTextBuf.GetBufPos( out APos : Integer );
begin
  APos := St.CPos;
end; //*** end of procedure TK_SerialTextBuf.GetBufPos

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\CheckPrevParsedTagCloseFlag
//**************************** TK_SerialTextBuf.CheckPrevParsedTagCloseFlag ***
// Check previous parsed Tag Close Flag
//
//     Parameters
// ATag   - Tag name for checking previous parsed Tag
// Result - Returns TRUE if previous parsed Tag name is ATag and it is closed
//
function TK_SerialTextBuf.CheckPrevParsedTagCloseFlag( ATag : string ) : Boolean;
var
  i : Integer;
begin
  Result := false;
  if (LastParsedTag = '') or (LastParsedTag <> ATag) then Exit;
  //*** check close open tag
  i := Min( St.TLength, St.Cpos );
  while (i > 1) and (St.Text[i] <> K_TagCloseChar) do Dec(i);
  if (i > 1) and (St.Text[i-1] = K_TagCloseFlag) then begin
    LastParsedTag := '';
    Result := true;
    Exit;
  end;
end; //*** end of function CheckPrevParsedTagCloseFlag

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetSpecTag
//********************************************* TK_SerialTextBuf.GetSpecTag ***
// Parse Tag data for Tag with given name
//
//     Parameters
// ATag           - parsing Tag name
// ATagType       - parsing Tag type (enumeration) value
// AStopErrorFlag - if =TRUE then exception will be raised while parsed Tag name
//                  and type are ot equal to given
// Result         - Returns TRUE if Tag is successfully parsed
//
function TK_SerialTextBuf.GetSpecTag( const ATag : string; ATagType : TK_STBufTagType;
                                         AStopErrorFlag : boolean = true ) : Boolean;
var
  CTag : string;
  TTag : TK_STBufTagType;
begin
  Result := true;
  PrevParsedTag := LastParsedTag;

  if (ATagType = tgClose) and CheckPrevParsedTagCloseFlag( ATag ) then Exit;

  GetTag( Ctag, TTag );
  if Ctag <> ATag then
  begin
    Result := false;
    if AStopErrorFlag then
      raise TK_LoadUDDataError.Create( PrepErrorMessage( 'Found "'+CTag+'" instead of "'+ATag+'" while loading line ' ) );
    LastParsedTag := PrevParsedTag;
    Exit;
  end;
  if ATagType <> TTag then
  begin
    Result := false;
    if AStopErrorFlag then
      raise TK_LoadUDDataError.Create( PrepErrorMessage( 'Wrong tag type for "'+CTag+'" while loading line ' ) );
  end;
end; //*** end of function GetSpecTag

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddEOL
//************************************************* TK_SerialTextBuf.AddEOL ***
// Add end of line chars to current position of Line buffer
//
//     Parameters
// ACheckTag - end of Tag body support flag:
//#F
//  TRUE  is needed when use AddEOL inside tag body <tag ..... >
//  FALSE is needed when use AddEOL outside tag body <tag> .... </tag>
//#/F
//
procedure TK_SerialTextBuf.AddEOL( ACheckTag : Boolean = true );
begin
  if ( (K_txtSkipDblNewLine in K_TextModeFlags) and
       (OfsFreeM = LineOffset+1) ) or
     ( K_txtSingleLineMode in K_TextModeFlags ) then Exit;
  ACheckTag := ACheckTag and (St.Text[OfsFreeM-1] = K_TagCloseChar);
  if ACheckTag then // last char is end of open tag
    Dec(OfsFreeM);
  TextStrings.Add( Copy(St.Text, 1, OfsFreeM-1) );
  OfsFreeM := 1;
  ShiftLinePos( LineOffset );
  if ACheckTag then // last char is end of open tag
  begin
     St.Text[OfsFreeM] := K_TagCloseChar;
     Inc(OfsFreeM);
  end;
end; //*** end of procedure TK_SerialTextBuf.AddEol

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddChars
//*********************************************** TK_SerialTextBuf.AddChars ***
// Add given chars line buffer
//
//     Parameters
// AChars    - given chars
// ACheckTag - end of Tag body support flag:
//#F
//  TRUE  is needed when use AddEOL inside tag body <tag ..... >
//  FALSE is needed when use AddEOL outside tag body <tag> .... </tag>
//#/F
//
procedure TK_SerialTextBuf.AddChars( const AChars : string; ACheckTag : Boolean = false );
var Leng : Integer;
begin
  ACheckTag := ACheckTag and (OfsFreeM > 1) and (St.Text[OfsFreeM-1] = K_TagCloseChar);
  if ACheckTag then // last char is end of open tag
    Dec(OfsFreeM);
  Leng := Length(AChars);
  if (OfsFreeM + Leng - 1> LineMaxSize) then
    AddEOL( false );
  AddToken( AChars, K_ttString );
  Dec(OfsFreeM);
  if ACheckTag then // last char is end of open tag
  begin
     St.Text[OfsFreeM] := K_TagCloseChar;
     Inc(OfsFreeM);
  end;
end; //*** end of procedure TK_SerialTextBuf.AddChars

{
//************************************************* TK_SerialTextBuf.SkipStr ***
// skip substring in buffer
//
function TK_SerialTextBuf.SkipChars( const Str : string ) : Boolean;
var
SPos : Integer;
begin
  SPos := PosEx( Str, St.Text, St.cpos );
  if SPos = 0 then
    Result := false
  else begin
    Result := true;
    St.shiftPos( SPos + Length(Str) - St.cpos  );
  end;
end; //*** end of procedure TK_SerialTextBuf.SkipStr

//************************************************* TK_SerialTextBuf.GetSubString ***
// get string from current position to specified substing
//
//   Parameters
//
function TK_SerialTextBuf.GetSubString( const ATermString : string ) : string;
var
SPos : Integer;
begin
  SPos := PosEx( ATermString, St.Text, St.cpos );
  if SPos = 0 then
    Result := ''
  else begin
    Result := Copy( St.Text, St.cpos, SPos );
    St.shiftPos( SPos - St.cpos );
  end;
end; //*** end of procedure TK_SerialTextBuf.GetSubString


//************************************************* TK_SerialTextBuf.GetChar ***
// get char from buffer
//
function TK_SerialTextBuf.GetChar( PosShift : Integer = 0 ) : Char;
begin
  Result := St.Text[St.cpos+PosShift];
end; //*** end of procedure TK_SerialTextBuf.GetChar

//************************************************* TK_SerialTextBuf.GetAttr ***
// get char from buffer
//
function TK_SerialTextBuf.GetAttr( out Delim : Char ) : string;
begin
  St.setDelimiters(attrDelims);
  St.HasMoreTokens();
//  Delim := GetChar(-1);
  Delim := St.Text[St.cpos - 1];
  Result := St.NextToken;
  St.setDelimiters(dataDelims);
end; //*** end of procedure TK_SerialTextBuf.GetAttr
}

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\ShiftLineOffs
//****************************************** TK_SerialTextBuf.ShiftLineOffs ***
// Shift line start text posotion
//
//     Parameters
// AShift - given shift to line start text posotion
//
function TK_SerialTextBuf.ShiftLineOffs( AShift : Integer ) : Integer;
var PrevOffs : Integer;
begin
  PrevOffs := LineOffset;
  Inc(LineOffset, AShift);
  if (LineOffset < 0) or
     (LineOffset > LineMaxSize) then
    LineOffset := 0;
  Result := LineOffset;
  if PrevOffs = OfsFreeM - 1 then
    ShiftLinePos( LineOffset - OfsFreeM+1 );
end; //*** end of procedure TK_SerialTextBuf.ShiftLineOffs

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\SetLineSize
//******************************************** TK_SerialTextBuf.SetLineSize ***
// Set line buffer maximal size
//
//     Parameters
// ALSize - given line buffer maximal size
//
procedure TK_SerialTextBuf.SetLineSize( ALSize : Integer );
begin
  LineMaxSize := ALSize;
  if LineMaxSize <= 0 then
    LineMaxSize := MaxInt;
end; //*** end of procedure TK_SerialTextBuf.SetLineSize

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\ShiftLinePos
//******************************************* TK_SerialTextBuf.ShiftLinePos ***
// Shift line buffer current position
//
//     Parameters
// AShift - given shift to line buffer current position
//
function TK_SerialTextBuf.ShiftLinePos( AShift : Integer ) : Integer;
var
  i : Integer;
begin
  if AShift > 0 then begin
    IncCapacity( AShift + 1 );
//!!    FillChar( St.Text[OfsFreeM], AShift + 1, ' ' );
    for i := OfsFreeM to AShift do
      St.Text[i] := ' ';
  end;
  Inc(OfsFreeM, AShift);
  if OfsFreeM < 1 then OfsFreeM := 1;
  Result := OfsFreeM;
end; //*** end of procedure TK_SerialTextBuf.ShiftLinePos

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddTagAttr
//********************************************* TK_SerialTextBuf.AddTagAttr ***
// Add attribute value to Tag body
//
//     Parameters
// AttrName  - attribute name
// AttrValue - attribute value
// AType     - attribute value type
// AFmt      - attribute value format string (defalt format value is emty 
//             string)
//
procedure TK_SerialTextBuf.AddTagAttr( AttrName : string; const AttrValue;
                        AType : TK_ParamType = K_isString; AFmt : string = '' );
var
  Leng : Integer;
  SAttrValue : string;
  TT : TK_TokenType;
  EOLFlag : Boolean;
  AddShift : Integer;
begin
  SAttrValue := K_ToString( AttrValue, AType, AFmt );
  Leng := Length(AttrName) + Length(SAttrValue) + 1 + 2;
  EOLFlag := ( OfsFreeM + Leng - 1> LineMaxSize ) or
             ( K_txtAttrNewLine in K_TextModeFlags );
  if EOLFlag then
    AddEOL;

  IncCapacity( Leng );
  St.Text[OfsFreeM - 1] := ' '; // clear tag close char K_TagCloseChar

  if EOLFlag then begin
    AddShift := AddAttrsLineOffset;
    if AddShift < 0 then AddShift := Length(LastAddedTag) - 1;
    if AddShift > 0 then
      ShiftLinePos( AddShift );
  end;

  AddChars(AttrName, false);
  AddChars( '=' , false);

  TT := K_ttToken;
  if K_txtXMLMode in K_TextModeFlags then
    TT := K_ttQToken;
  if not ( (Atype = K_isString)      or
           (Atype = K_isStringArray) or
           (Atype = K_isDate)        or
           (Atype = K_isDateTime) ) then TT := K_ttString;

  AddToken( SAttrValue, TT );

  St.Text[OfsFreeM-1] := K_TagCloseChar; // put tag close to last space

end; //*** end of procedure TK_SerialTextBuf.AddTagAttr

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetTagAttr
//********************************************* TK_SerialTextBuf.GetTagAttr ***
// Get attribute value parsed from Tag by attribute name and type
//
//     Parameters
// AttrName  - attribute name
// AttrValue - resulting attribute value
// AType     - attribute value type
// Result    - Returns TRUE if given attribute value was parsed from Tag body
//
function TK_SerialTextBuf.GetTagAttr( AttrName : string; out AttrValue;
                        AType : TK_ParamType = K_isString ) : Boolean;
var
  ind : Integer;
  value : string;
begin
  Result := false;
//  value := AttrList.Values[AttrName];
//  if value = '' then Exit;

  ind := AttrsList.IndexOfName(AttrName);
  if ind < 0 then Exit;
  AttrsList.Objects[ind] := TObject(1);
  value := AttrsList.ValueFromIndex[ind];
  if value = '' then Exit;
  K_FromString( value, AttrValue, AType );
  Result := true;
end; //*** end of procedure TK_SerialTextBuf.GetTagAttr

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddToken
//*********************************************** TK_SerialTextBuf.AddToken ***
// Add token to line buffer current position
//
//     Parameters
// AStr            - adding token value
// AisString       - adding token status, if =TRUE, then no brackets chars 
//                   needed to separate adding token
// ATokenDelimiter - delimiter char adding after token, if =#0 then 
//                   Self.Tokenizer.Delimiters[1] is used.
//
procedure TK_SerialTextBuf.AddToken( const AStr: string; ATokenType : TK_TokenType = K_ttToken;
                        ATokenDelimeter : Char = #0 );
begin
  if (OfsFreeM - 1 > LineMaxSize) then
    AddEOL( false );
  St.cpos := OfsFreeM;
  St.addToken( AStr, ATokenType, ATokenDelimeter );
  OfsFreeM := St.cpos;
end; //*** end of procedure TK_SerialTextBuf.AddToken

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetToken
//*********************************************** TK_SerialTextBuf.GetToken ***
// Get token from parsed text current position
//
//     Parameters
// AStr - resulting token value
//
procedure TK_SerialTextBuf.GetToken( var AStr: string );
begin
  AStr := St.nextToken;
end; //*** end of procedure TK_SerialTextBuf.GetToken

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddScalar
//********************************************** TK_SerialTextBuf.AddScalar ***
// Add given scalar text value to line buffer current position
//
//     Parameters
// AValue - given scalar value
// AType  - attribute value type
// AFmt   - format string (default value is empty string)
//
procedure TK_SerialTextBuf.AddScalar( const AValue;
                AType : TK_ParamType = K_isString; AFmt : string = '' );
var
  TT : TK_TokenType;
begin
  TT := K_ttToken;
  if not ( (Atype = K_isString)      or
           (Atype = K_isStringArray) or
           (Atype = K_isDate)        or
           (Atype = K_isDateTime) ) then TT := K_ttString;

  AddToken( K_ToString(AValue, AType, AFmt), TT );
end; //*** end of procedure TK_SerialTextBuf.AddScalar

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetScalar
//********************************************** TK_SerialTextBuf.GetScalar ***
// Get scalar value from parsed text current position
//
//     Parameters
// AValue - given scalar value
// AType  - given scalar type enumeration
//
procedure TK_SerialTextBuf.GetScalar( var AValue;
                        AType : TK_ParamType = K_isString );
begin
  K_FromString( St.nextToken, AValue, AType );
end; //*** end of procedure TK_SerialTextBuf.GetScalar

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddRowScalars
//****************************************** TK_SerialTextBuf.AddRowScalars ***
// Add given scalars to Serial Text Buffer
//
//     Parameters
// AData      - array of data
// ACount     - data elements counter
// AStep      - step in bytes between elements in array
// AType      - attribute value type
// ALineCount - number of values in line
// AFmt       - format string (default value is empty string)
//
procedure TK_SerialTextBuf.AddRowScalars( var AData; const ACount, AStep: integer;
                         AType : TK_ParamType = K_isString;
                         ALineCount : Integer = 10; AFmt : string = '' );
var
  i, lind : integer;
  pdata : TN_BytesPtr;
begin
  lind := ALineCount;
  pdata := @AData;
  for i := 0 to ACount-1 do
  begin
    Inc(lind);
    if Lind >= ALineCount then
    begin
      AddEoL(false);
      lind := 0;
    end;
    AddScalar( pdata^, AType, AFmt );
    Inc( pdata, AStep );
  end;
end; //*** end of procedure TK_SerialTextBuf.AddRowScalars

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetRowScalars
//****************************************** TK_SerialTextBuf.GetRowScalars ***
// Get given number of scalars from Serial Text Buffer
//
//     Parameters
// AData  - array of data
// ACount - data elements counter
// AStep  - step in bytes between elements in array
// AType  - attribute value type
// Result - Returns number of parsed scalars (<= ACount)
//
// Scalars parsing can be break by close Tag token
//
function  TK_SerialTextBuf.GetRowScalars( var AData; const ACount, AStep: integer;
                         AType : TK_ParamType = K_isString ) : Integer;
var
  i : integer;
  pdata : TN_BytesPtr;
  ETag : TK_STBufTagType;
begin
  pdata := @AData;
  Result := 0;
  for i := 0 to ACount-1 do
  begin
    TestTokenType( ETag );
    if (ETag = tgOpen) or (ETag = tgClose) then Exit;
    GetScalar( pdata^, AType );
    Inc( pdata, AStep );
    Inc(Result);
  end;
end; //*** end of procedure TK_SerialTextBuf.GetRowScalars

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddArray
//*********************************************** TK_SerialTextBuf.AddArray ***
// Add given data array (Pascal Array) to Serial Text Buffer with given Tag 
// markup
//
//     Parameters
// ADArray    - given data array (Pascal Array)
// AType      - attribute value type
// ATag       - Tag name for array data markup
// ALineCount - number of values in line
// AFmt       - format string (default value is empty string)
//
procedure TK_SerialTextBuf.AddArray( const ADArray; AType : TK_ParamType = K_isStringArray;
                         const ATag : string = '';
                         ALineCount : Integer = 10; AFmt : string = '' );
var
  Count : Integer;
  PD : Pointer;
begin
  if ATag <> '' then AddTag( ATag );
  Count := K_ArrayHigh(ADArray, AType)+1;
  AddTagAttr( K_tbArrLength, Count, K_isInteger );
  if Count > 0 then begin
    PD := K_GetElementAddr( ADArray, AType, 0 );
    AddRowScalars( PD^, Count, K_SizeOf(AType),
     AType, ALineCount, AFmt );
  end;
  AddEOL(false);
  if ATag <> '' then AddTag( ATag, tgClose );
end; //*** end of procedure TK_SerialTextBuf.AddArray

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetArray
//*********************************************** TK_SerialTextBuf.GetArray ***
// Get data array from Serial Text Buffer
//
//     Parameters
// ADArray - given data array (Pascal Array)
// AType   - attribute value type
// ATag    - Tag name for parsing array close Tag
// ALength - number of array alements (if =-1 then number of elemnts from 
//           parsing Tag attributes will be used)
//
procedure TK_SerialTextBuf.GetArray( var ADArray; AType : TK_ParamType = K_isStringArray;
                        const ATag : string = ''; ALength : Integer = -1 );
var
  Capacity : integer;
  pdata : TN_PByte;
  NewLeng, ParseNum, Count, BStep : Integer;
  IncFlag : Boolean;
  Leng : Integer;
begin
  Capacity := 0;
  NewLeng := ALength;
  if ALength = -1 then
    GetTagAttr( K_tbArrLength, NewLeng, K_isInteger );
  BStep := K_SizeOf(AType);
  IncFlag := false;
  Leng := 0;
  if NewLeng <= 0 then
  begin
    NewLeng := 10;
    IncFlag := true;
  end;
  repeat
    if K_NewCapacity( NewLeng, Capacity ) then
      K_SetLength( ADArray, AType, Capacity );
    pdata := TN_PByte( K_GetElementAddr( ADArray, AType, Leng ) );
    Count := Capacity - Leng;
    ParseNum := GetRowScalars( pdata^, Count, BStep, AType );
    Inc( Leng, ParseNum );
    if IncFlag then
      Inc(NewLeng, ParseNum);
  until ParseNum < Count;
  K_SetLength( ADArray, AType, Leng );
  if ATag <> '' then GetSpecTag( ATag, tgClose );
end; //*** end of procedure TK_SerialTextBuf.GetArray

{
//***************************************** TK_SerialTextBuf.AddRowSDoubles ***
// add given number of Sparse Doubles to SBuf (e.g. line vertexes X cooords)
// (only Doubles itself are saved, not theirs number)
// BStep - number of bytes between neighbour doubles (8 for Array of doubles)
//
procedure TK_SerialTextBuf.AddRowSDoubles( const Accuracy, Count, BStep: integer;
                                var PDouble;
                                lineCount : Integer = 10; fmt : string = '' );
begin
  if (Accuracy <> 100) and (fmt = '') then
    fmt := '%.'+IntToStr(Accuracy)+'g';
  AddRowScalars( PDouble, Count, BStep, K_isDouble, LineCount, fmt )
end; //*** end of procedure TK_SerialTextBuf.AddRowSDoubles

//***************************************** TK_SerialTextBuf.AddDoubleArray ***
// add dynamic array of double (with its Length)
//
procedure TK_SerialTextBuf.AddDoubleArray( const DArray: TN_DArray; Accuracy : Integer;
                             const Tag : string = ''; lineCount : Integer = 10;
                             fmt : string = '' );
var
  Count: integer;
  PD : Pointer;
begin
  if Tag <> '' then AddTag( Tag );
  Count := Length( DArray );
  AddTagAttr( K_tbArrLength, Count, K_isInteger );
  AddTagAttr( K_tbArrAccur, Accuracy, K_isInteger );
  if Count > 0 then begin
    PD := K_GetElementAddr( DArray, K_isDoubleArray, 0 );
    AddRowSDoubles( Accuracy, Count, SizeOf(Double), PD^, lineCount, fmt );
  end;
  AddEOL(false);
  if Tag <> '' then AddTag( Tag, tgClose );
end; //*** end of procedure TK_SerialTextBuf.AddDoubleArray

//***************************************** TK_SerialTextBuf.GetDoubleArray ***
// get dynamic array of double (with its Length)
//
procedure TK_SerialTextBuf.GetDoubleArray( var DArray: TN_DArray; var Accuracy : Integer;
                                                const Tag : string = '';
                                                ALength : Integer = -1 );
begin
  GetTagAttr( K_tbArrAccur, Accuracy, K_isInteger );
  GetArray( DArray, K_isDoubleArray, Tag, ALength );
end; //*** end of procedure TK_SerialTextBuf.GetDoubleArray
}

//******************************************** TK_SerialTextBuf.AddRowBytes ***
// Add given bytes to Serial Text Buffer as hexadecimal integers
//
//   Parameters
// ACount  - number of bytes
// APBytes - pointer to first byte
//
procedure TK_SerialTextBuf.AddRowBytes( const ACount: integer; const APBytes: Pointer );
var
  IntLeng, last, nbli : Integer;
  WP : Pointer;
begin
  if ACount = 0 then Exit;

  // for storing ACount Bytes IntLeng or IntLeng+1 integers is needed
  IntLeng := ACount shr 2; // ACount div SizeOf(Integer)
  WP := APBytes;
  AddRowScalars( WP^, IntLeng, Sizeof(integer), K_isHex );
//  last := PInteger( Integer(APBytes) + IntLeng )^; // error?
  last := PInteger( Integer(APBytes) + IntLeng*SizeOf(Integer) )^;
  nbli := ACount and 3; // Number of Bytes in Last Integer (0-3)
  case nbli of
    1: last := last and $FF;
    2: last := last and $FFFF;
    3: last := last and $FFFFFF;
  end;
  if nbli > 0 then AddScalar( last, K_isHex );
  AddEoL(false);
end; //*** end of procedure TK_SerialTextBuf.AddRowBytes

//******************************************** TK_SerialTextBuf.GetRowBytes ***
// Get given number of bytes from Serial Text Buffer stored as hexadecimal integers
//
//   Parameters
// ACount  - number of bytes
// APBytes - pointer to first byte
//
procedure TK_SerialTextBuf.GetRowBytes( const ACount: integer; const APBytes: Pointer );
var 
  IntLeng, last, plast, nbli : Integer;
begin
  if ACount = 0 then Exit;

  // for storing ACount Bytes IntLeng or IntLeng+1 integers is used
  IntLeng := ACount shr 2; // ACount div SizeOf(Integer)
  GetRowScalars( APBytes^, IntLeng, Sizeof(integer), K_isInteger );
  nbli := ACount and 3; // Number of Bytes in Last Integer (0-3)

  if nbli > 0 then begin // last integer exists with 1-3 bytes in it
    GetScalar( last, K_isInteger);
    plast := Integer(APBytes) + IntLeng*SizeOf(Integer);
    case nbli of
      1: TN_PByte(plast)^  := Byte(last); // one byte
      2: TN_PUInt2(plast)^ := WORD(last); // two bytes
      3: begin                            // three bytes
           TN_PByte(plast)^  := Byte(last);
           Inc( plast );
           TN_PUInt2(plast)^ := WORD( last shr 8 );
         end;  
    end; // case nbli of
  end; // if nbli > 0 then begin                           
end; //*** end of procedure TK_SerialTextBuf.GetRowBytes

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddBytes
//*********************************************** TK_SerialTextBuf.AddBytes ***
// Add given bytes to Serial Text Buffer in hexadecimal format
//
//     Parameters
// APByte    - pointer to first byte
// ANumBytes - number of bytes
//
procedure TK_SerialTextBuf.AddBytes( APByte: PByte; ANumBytes: integer );
var
  i, NumRows, RestBytes, BytesInRow: Integer;
  StrBuf: string;
  PBeg, PBuf: PChar;
  PCurRow: PByte;
begin
  if ANumBytes <= 0 then Exit;

  BytesInRow := LineMaxSize div 2;
  NumRows    := ANumBytes div BytesInRow;
  RestBytes  := ANumBytes - NumRows*BytesInRow;
  PCurRow    := APByte;
  SetLength( StrBuf, (4 + 2*BytesInRow)*(NumRows+1) ); // max possible Size
  PBuf := PChar(StrBuf);
  PBeg := PBuf;
  if (OfsFreeM+1) > LineOffset then AddEOL( False );

  for i := 0 to NumRows-1 do // add whole Rows (BytesInRow per row) to StrBuf
  begin
    PBuf^ := ' '; Inc( PBuf );
    N_BytesToHexChars( PCurRow, BytesInRow, PBuf );
    Inc( PBuf, 2*BytesInRow );
//    PWORD(PBuf)^ := N_IntCRLF; Inc( PBuf, 2 );
    TN_PTwoChars(PBuf)^ := N_IntCRLF; Inc( PBuf, 2 );
    Inc( PCurRow, BytesInRow );
  end; // for i := 0 to NumRows-1 do // add whole Rows (BytesInRow per row) to StrBuf

  if RestBytes > 0 then // add RestBytes to StrBuf
  begin
    PBuf^ := ' '; Inc( PBuf );
    N_BytesToHexChars( PCurRow, RestBytes, PBuf );
    Inc( PBuf, 2*RestBytes );
//    PWORD(PBuf)^ := N_IntCRLF; Inc( PBuf, 2 );
    TN_PTwoChars(PBuf)^ := N_IntCRLF; Inc( PBuf, 2 );
  end; // if RestIntegers > 0 then // add RestIntegers (1 - 9) to StrBuf

  SetLength( StrBuf, PBuf - PBeg ); // real Size
  TextStrings.Add( StrBuf );
end; //*** end of procedure TK_SerialTextBuf.AddBytes

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetBytes
//*********************************************** TK_SerialTextBuf.GetBytes ***
// Get given number of bytes from Serial Text Buffer
//
//     Parameters
// APByte    - pointer to first byte
// ANumBytes - number of bytes
//
procedure TK_SerialTextBuf.GetBytes( APByte: PByte; ANumBytes: integer );
var
  iBeg, CurNumChars, CurNumBytes, NumBytesRed: Integer;
  PCurByte: PByte;
  PBeg, PBegiBeg, PBuf: PChar;
begin
  iBeg := St.CPos;
  PBuf := PChar(St.Text) + iBeg - 1;
  PBegiBeg := PBuf; // save initial value
  PCurByte := APByte;
  NumBytesRed := 0;

  while True do // read HexChars untill ANumBytes wil be red
  begin
    while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces and CRLF before CurBytes
    PBeg := PBuf;
    while PBuf^ > Char($020) do Inc( PBuf ); // skip CurBytes till spaces or CRLF
    CurNumChars := PBuf - PBeg;
    Assert( (CurNumChars and 1) = 0, 'NumCharsNotEven!' );
    CurNumBytes := CurNumChars div 2;
    Assert( (NumBytesRed+CurNumBytes) <= ANumBytes, 'TooManyHexChars!' );
    N_HexCharsToBytes( PBeg, PCurByte, CurNumBytes );
    Inc( NumBytesRed, CurNumBytes );
    if NumBytesRed = ANumBytes then Break; // all Bytes red
    Inc( PCurByte, CurNumBytes );
  end; // while True do // read HexChars untill ANumBytes wil be red

  while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces and CRLF before next Tag
  
  // Note: difference of typed pointers is not in bytes but in number of elements of proper type!
  St.CPos := iBeg + integer(PBuf - PBegiBeg); // Update St.findex
end; //*** end of procedure TK_SerialTextBuf.GetBytes


type TN_10Integers = packed record
  I0,I1,I2,I3,I4,I5,I6,I7,I8,I9: integer;
end; // type TN_10Integers = packed record
type TN_P10Integers = ^TN_10Integers;

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddIntegers
//******************************************** TK_SerialTextBuf.AddIntegers ***
// Add given Integers to Serial Text Buffer
//
//     Parameters
// APInteger    - pointer to first Integer
// ANumIntegers - number of Integers
//
procedure TK_SerialTextBuf.AddIntegers( APInteger: PInteger; ANumIntegers: integer );
var
  i, i1, i2, StrSize, NumRows, RestIntegers: Integer;
  Str1, StrBuf: string;
  PBuf: PChar;
  PCur10I: TN_P10Integers;
begin
  if ANumIntegers <= 0 then Exit;

  NumRows := ANumIntegers div 10;
  RestIntegers := ANumIntegers - NumRows*10;
  PCur10I := TN_P10Integers(APInteger);
  SetLength( StrBuf, 14*ANumIntegers + 2 ); // max possible Size
  PBuf := PChar(StrBuf);
  i1 := 1; // BufStr index
  i2 := 1; // index in each row
  if (OfsFreeM+1) > LineOffset then AddEOL( False );

  for i := 0 to NumRows-1 do // add whole Rows (10 Integers per row) to StrBuf
  begin
    with PCur10I^ do
      Str1 := Format( ' %d %d %d %d %d %d %d %d %d %d', [I0,I1,I2,I3,I4,I5,I6,I7,I8,I9] );

    Inc( PCur10I );
    StrSize := Length( Str1 );
    Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
    Inc( i1, StrSize );
    Inc( i2, StrSize );
    Inc( PBuf, StrSize );

    if i2 > LineMaxSize then
    begin
//      PWORD(PBuf)^ := N_IntCRLF;
//      Inc( PBuf, 2 );
      TN_PTwoChars(PBuf)^ := N_IntCRLF; Inc( PBuf, 2 );
      Inc( i1, 2 );
      i2 := 1;
    end;
  end; // for i := 0 to NumRows-1 do // add whole Rows (10 Integers per row) to StrBuf

  if RestIntegers > 0 then // add RestIntegers (1 - 9) to StrBuf
  begin
    if RestIntegers >= 5 then // add 5 Integers to StrBuf
    begin
      with PCur10I^ do
        Str1 := Format( ' %d %d %d %d %d', [I0,I1,I2,I3,I4] );

      PCur10I := TN_P10Integers(PChar(PCur10I) + 5*SizeOf(Integer));
      StrSize := Length( Str1 );
      Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
      Inc( i1, StrSize );
      Dec( RestIntegers, 5 );
      Inc( PBuf, StrSize );
    end; // if RestIntegers >= 5 then // add 5 Integers to StrBuf

    if RestIntegers >= 1 then // Add rest 1 - 4 Integers
    begin
      with PCur10I^ do
      case RestIntegers of
      1: Str1 := Format( ' %d', [I0] );
      2: Str1 := Format( ' %d %d', [I0,I1] );
      3: Str1 := Format( ' %d %d %d', [I0,I1,I2] );
      4: Str1 := Format( ' %d %d %d %d', [I0,I1,I2,I3] );
      end; // case RestPoints of

      StrSize := Length( Str1 );
      Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
      Inc( i1, StrSize );
      Inc( PBuf, StrSize );
    end; // if RestIntegers >= 1 then // Add rest 1 - 4 Integers
  end; // if RestIntegers > 0 then // add RestIntegers (1 - 9) to StrBuf

//  PWORD(PBuf)^ := N_IntCRLF; Inc( i1, 2 );
  TN_PTwoChars(PBuf)^ := N_IntCRLF; Inc( i1, 2 );

  SetLength( StrBuf, i1-1 ); // real Size
  TextStrings.Add( StrBuf );
end; //*** end of procedure TK_SerialTextBuf.AddIntegers

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddHexInts
//********************************************* TK_SerialTextBuf.AddHexInts ***
// Add given Integers to Serial Text Buffer in hexadecimal format
//
//     Parameters
// APInteger    - pointer to first Integer
// ANumIntegers - number of Integers
//
procedure TK_SerialTextBuf.AddHexInts( APInteger: PInteger; ANumIntegers: integer );
var
  i, i1, i2, StrSize, NumRows, RestIntegers: Integer;
  PBuf: PChar;
  Str1, StrBuf: string;
  PCur10I: TN_P10Integers;
begin
  if ANumIntegers <= 0 then Exit;

  NumRows := ANumIntegers div 10;
  RestIntegers := ANumIntegers - NumRows*10;
  PCur10I := TN_P10Integers(APInteger);
  SetLength( StrBuf, 12*ANumIntegers + 2 ); // max possible Size
  PBuf := PChar(StrBuf);
  i1 := 1; // BufStr index
  i2 := 1; // index in each row
  if (OfsFreeM+1) > LineOffset then AddEOL( False );

  for i := 0 to NumRows-1 do // add whole Rows (10 Hex Integers per row) to StrBuf
  begin
    with PCur10I^ do
      Str1 := Format( ' $%X $%X $%X $%X $%X $%X $%X $%X $%X $%X', [I0,I1,I2,I3,I4,I5,I6,I7,I8,I9] );

    Inc( PCur10I );
    StrSize := Length( Str1 );
    Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
    Inc( i1, StrSize );
    Inc( i2, StrSize );
    Inc( PBuf, StrSize );

    if i2 > LineMaxSize then // Add CRLF to StrBuf
    begin
//      PWORD(PBuf)^ := N_IntCRLF;
//      Inc( PBuf, 2 );
      TN_PTwoChars(PBuf)^ := N_IntCRLF; Inc( PBuf, 2 );
      Inc( i1, 2 );
      i2 := 1;
    end;
  end; // for i := 0 to NumRows-1 do // add whole Rows (10 Hex Integers per row) to StrBuf

  if RestIntegers > 0 then // add RestIntegers (1 - 9) to StrBuf
  begin
    if RestIntegers >= 5 then // add 5 Hex Integers to StrBuf
    begin
      with PCur10I^ do
        Str1 := Format( ' $%X $%X $%X $%X $%X', [I0,I1,I2,I3,I4] );

      PCur10I := TN_P10Integers(PChar(PCur10I) + 5*SizeOf(Integer));
      StrSize := Length( Str1 );
      Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
      Inc( i1, StrSize );
      Dec( RestIntegers, 5 );
      Inc( PBuf, StrSize );
    end; // if RestIntegers >= 5 then // add 5 Hex Integers to StrBuf

    if RestIntegers >= 1 then // Add rest 1 - 4 Hex Integers
    begin
      with PCur10I^ do
      case RestIntegers of
      1: Str1 := Format( ' $%X', [I0] );
      2: Str1 := Format( ' $%X $%X', [I0,I1] );
      3: Str1 := Format( ' $%X $%X $%X', [I0,I1,I2] );
      4: Str1 := Format( ' $%X $%X $%X $%X', [I0,I1,I2,I3] );
      end; // case RestPoints of

      StrSize := Length( Str1 );
      Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
      Inc( i1, StrSize );
      Inc( PBuf, StrSize );
  end; // if RestIntegers >= 1 then // Add rest 1 - 4 Hex Integers

  end; // if RestIntegers > 0 then // add RestIntegers (1 - 9) to StrBuf

  TN_PTwoChars(PBuf)^ := N_IntCRLF;
  Inc( i1, 2 );

  SetLength( StrBuf, i1-1 ); // real Size
  TextStrings.Add( StrBuf );
end; //*** end of procedure TK_SerialTextBuf.AddHexInts

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetIntegers
//******************************************** TK_SerialTextBuf.GetIntegers ***
// Get given number of Integers from Serial Text Buffer
//
//     Parameters
// APInteger    - pointer to first Integer
// ANumIntegers - number of Integers
//
procedure TK_SerialTextBuf.GetIntegers( APInteger: PInteger; ANumIntegers: integer );
var
  i, iBeg, RetCode: Integer;
  PCurI: PInteger;
  PBeg, PBegiBeg, PBuf: PChar;
  WC : Char;
  ErrStr : string;
begin
  iBeg := St.CPos;
  PBuf := PChar(St.Text) + iBeg - 1;
  PBegiBeg := PBuf; // save initial value
  PCurI := APInteger;

  for i := 0 to ANumIntegers-1 do // Get ANumIntegers Integers from StrBuf
  begin
    while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces and CRLF before CurFloat
    PBeg := PBuf;
    while PBuf^ > Char($020) do Inc( PBuf ); // skip CurFloat
    WC := PBuf^;
    PBuf^ := Char( 0 ); // CurFloat terminating zero
    Val( PBeg, PCurI^, RetCode );
    if RetCode <> 0 then
    begin
      ErrStr := 'BadInteger='+ PBeg;
      PBuf^ := WC;
      N_Dump1Str( 'TK_SerialTextBuf ' + ErrStr );
      raise TK_LoadUDDataError.Create( ErrStr );
    end;
    PBuf^ := WC;
//    Assert( RetCode = 0, 'BadInteger='+ ErrStr );
    Inc( PCurI );
  end; // for i := 0 to ANumIntegers-1 do // Get ANumIntegers Integers from StrBuf

  while PBuf^ <= Char($020) do Inc( PBuf ); // skip 0(now is needed!), spaces and CRLF before next Tag

  // Note: difference of typed pointers is not in bytes but in number of elements of proper type!
  St.CPos := iBeg + integer(PBuf - PBegiBeg); // Update St.findex
end; //*** end of procedure TK_SerialTextBuf.GetIntegers

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddFloats
//********************************************** TK_SerialTextBuf.AddFloats ***
// Add given Floats to Serial Text Buffer
//
//     Parameters
// APFloat    - pointer to first Float
// ANumFloats - number of Floats
//
procedure TK_SerialTextBuf.AddFloats( APFloat: PFloat; ANumFloats: integer );
var
  i, i1, i2, StrSize: Integer;
  Str, StrBuf: string;
  ScaleCoef: Double;
  PBuf: PChar;
  PCurF: PFloat;
begin
  if ANumFloats <= 0 then Exit;
  SetLength( StrBuf, 18*ANumFloats + 2 ); // max possible Size
  PBuf := PChar(StrBuf);
  PCurF := APFloat;
  i1 := 1; // BufStr index
  i2 := 1; // index in each row
  if (OfsFreeM+1) > LineOffset then AddEOL( False );

  for i := 0 to ANumFloats-1 do // add all given Floats to StrBuf
  begin
    if PCurF^ = 0 then // special code for Zero values
    begin
      StrSize := 2;
//      PWORD(PBuf)^ := $3020; // same as string ' 0'
      TN_PTwoChars(PBuf)^ := TN_PTwoChars(@K_StrWhiteSpaceZero[1])^;
//      TN_PTwoChars(PBuf)^ := N_IntWhiteSpaceZero;
    end else // PCurF^ <> 0 (Log10 can be used)
    begin
      ScaleCoef := Power( 10, 6 - Floor(Log10(Abs(PCurF^))) );
      Str := Format( ' %g', [Round(PCurF^*ScaleCoef)/ScaleCoef] );
      StrSize := Length(Str);
      Move( Str[1], PBuf^, StrSize * SizeOf(Char) );
    end;

    Inc( i1, StrSize );
    Inc( i2, StrSize );
    Inc( PBuf, StrSize );
    Inc( PCurF );

    if i2 >= LineMaxSize then // Add CRLF to StrBuf
    begin
//      PWORD(PBuf)^ := N_IntCRLF;
//      Inc( PBuf, 2 );
      TN_PTwoChars(PBuf)^ := N_IntCRLF;
      Inc( PBuf, 2 );
      Inc( i1, 2 );
      i2 := 1;
    end;
  end; // for i := 0 to ANumFloats-1 do // add all given Floats to StrBuf

  SetLength( StrBuf, i1-1 ); // real Size
  TextStrings.Add( StrBuf );
end; //*** end of procedure TK_SerialTextBuf.AddFloats

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetFloats
//********************************************** TK_SerialTextBuf.GetFloats ***
// Get given number of Floats from Serial Text Buffer
//
//     Parameters
// APFloat    - pointer to first Float
// ANumFloats - number of Floats
//
procedure TK_SerialTextBuf.GetFloats( APFloat: PFloat; ANumFloats: integer );
var
  i, iBeg, RetCode: Integer;
  PCurF: PFloat;
  PBeg, PBegiBeg, PBuf, PComma: PChar;
  WC : Char;
  ErrStr : string;
  begin
  iBeg := St.CPos;
  PBuf := PChar(St.Text) + iBeg - 1;
  PBegiBeg := PBuf; // save initial value
  PCurF := APFloat;

  for i := 0 to ANumFloats-1 do // Get ANumFloats Floats from StrBuf
  begin
    while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces and CRLF before CurFloat
    PBeg := PBuf;
    PComma := nil;
    while PBuf^ > Char($020) do
    begin
      if PBuf^ = ',' then begin
        PComma := PBuf;
        PComma^ := '.';
      end;
      Inc( PBuf ); // skip CurFloat
    end;
    WC := PBuf^;
    PBuf^ := Char( 0 ); // CurFloat terminating zero
    Val( PBeg, PCurF^, RetCode );
    if RetCode <> 0 then
    begin
      ErrStr := 'BadFloat='+ PBeg;
      PBuf^ := WC;
      if PComma <> nil then PComma^ := ',';
      N_Dump1Str( 'TK_SerialTextBuf ' + ErrStr );
      raise TK_LoadUDDataError.Create( ErrStr );
    end;
    PBuf^ := WC;
    if PComma <> nil then PComma^ := ',';
//    Assert( RetCode = 0, 'BadFloat='+ ErrStr );
    Inc( PCurF );
  end; // for i := 0 to ANumFloats-1 do // Get ANumFloats Floats from StrBuf

  while PBuf^ <= Char($020) do Inc( PBuf ); // skip 0(now is needed!), spaces and CRLF before next Tag

  // Note: difference of typed pointers is not in bytes but in number of elements of proper type!
  St.CPos := iBeg + integer(PBuf - PBegiBeg); // Update St.findex
end; //*** end of procedure TK_SerialTextBuf.GetFloats

type TN_10Doubles = packed record
  D0,D1,D2,D3,D4,D5,D6,D7,D8,D9: double;
end; // type TN_10Doubles = packed record
type TN_P10Doubles = ^TN_10Doubles;

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddDoubles
//********************************************* TK_SerialTextBuf.AddDoubles ***
// Add given Doubles to Serial Text Buffer
//
//     Parameters
// APDouble    - pointer to first Double
// ANumDoubles - number of Doubles
//
procedure TK_SerialTextBuf.AddDoubles( APDouble: PDouble; ANumDoubles: integer );
var
  i, i1, i2, StrSize, NumRows, RestDoubles: Integer;
  Str1, StrBuf: string;
  PBuf: PChar;
  PCur10D: TN_P10Doubles;
begin
  if ANumDoubles <= 0 then Exit;

  NumRows := ANumDoubles div 10;
  RestDoubles := ANumDoubles - NumRows*10;
  PCur10D := TN_P10Doubles(APDouble);
  SetLength( StrBuf, 26*ANumDoubles + 2 ); // max possible Size
  PBuf := PChar(StrBuf);
  i1 := 1; // BufStr index
  i2 := 1; // index in each row
  if (OfsFreeM+1) > LineOffset then AddEOL( False );

  for i := 0 to NumRows-1 do // add whole Rows (10 doubles per row) to StrBuf
  begin
    with PCur10D^ do
      Str1 := Format( ' %g %g %g %g %g %g %g %g %g %g', [D0,D1,D2,D3,D4,D5,D6,D7,D8,D9] );

    Inc( PCur10D );
    StrSize := Length( Str1 );
    Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
    Inc( i1, StrSize );
    Inc( i2, StrSize );
    Inc( PBuf, StrSize );

    if i2 > LineMaxSize then // Add CRLF to StrBuf
    begin
//      PWORD(PBuf)^ := N_IntCRLF;
//      Inc( PBuf, 2 );
      TN_PTwoChars(PBuf)^ := N_IntCRLF; Inc( PBuf, 2 );
      Inc( i1, 2 );
      i2 := 1;
    end;
  end; // for i := 0 to NumRows-1 do // add whole Rows (10 doubles per row) to StrBuf

  if RestDoubles > 0 then // add RestDoubles (1 - 9) to StrBuf
  begin
    if RestDoubles >= 5 then // add 5 Doubles to StrBuf
    begin
      with PCur10D^ do
        Str1 := Format( ' %g %g %g %g %g', [D0,D1,D2,D3,D4] );

      PCur10D := TN_P10Doubles(PChar(PCur10D) + 5*SizeOf(Double));
      StrSize := Length( Str1 );
      Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
      Inc( i1, StrSize );
      Inc( PBuf, StrSize );
      Dec( RestDoubles, 5 );
    end; // if RestDoubles >= 5 then // add 5 Doubles to StrBuf

    if RestDoubles >= 1 then // Add rest 1 - 4 Doubles
    with PCur10D^ do
    begin
      case RestDoubles of
      1: Str1 := Format( ' %g', [D0] );
      2: Str1 := Format( ' %g %g', [D0,D1] );
      3: Str1 := Format( ' %g %g %g', [D0,D1,D2] );
      4: Str1 := Format( ' %g %g %g %g', [D0,D1,D2,D3] );
      end; // case RestPoints of

      StrSize := Length( Str1 );
      Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
      Inc( i1, StrSize );
      Inc( PBuf, StrSize );
  end; // if RestDoubles >= 1 then // Add rest 1 - 4 Doubles

  end; // if RestDoubles > 0 then // add RestDoubles (1 - 9) to StrBuf

  TN_PTwoChars(PBuf)^ := N_IntCRLF;
  Inc( i1, 2 );

  SetLength( StrBuf, i1-1 ); // real Size
  TextStrings.Add( StrBuf );
end; //*** end of procedure TK_SerialTextBuf.AddDoubles

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetDoubles
//********************************************* TK_SerialTextBuf.GetDoubles ***
// Get given number of Doubles from Serial Text Buffer
//
//     Parameters
// APDouble    - pointer to first Double
// ANumDoubles - number of Doubles
//
procedure TK_SerialTextBuf.GetDoubles( APDouble: PDouble; ANumDoubles: integer );
var
  i, iBeg, RetCode: Integer;
  PCurD: PDouble;
  PBeg, PBegiBeg, PBuf, PComma: PChar;
  WC : Char;
  ErrStr : string;
begin
  iBeg := St.CPos;
  PBuf := PChar(St.Text) + iBeg -1;
  PBegiBeg := PBuf; // save initial value
  PCurD := APDouble;

  for i := 0 to ANumDoubles-1 do // Get ANumDoubles Doubles from StrBuf
  begin
    while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces and CRLF before CurFloat
    PBeg := PBuf;
    PComma := nil;
    while PBuf^ > Char($020) do
    begin
      if PBuf^ = ',' then begin
        PComma := PBuf;
        PComma^ := '.';
      end;
      Inc( PBuf ); // skip CurFloat
    end;
    WC := PBuf^;
    PBuf^ := Char( 0 ); // CurFloat terminating zero
    Val( PBeg, PCurD^, RetCode );
    if RetCode <> 0 then
    begin
      ErrStr := 'BadDouble='+ PBeg;
      PBuf^ := WC;
      if PComma <> nil then PComma^ := ',';
      N_Dump1Str( 'TK_SerialTextBuf ' + ErrStr );
      raise TK_LoadUDDataError.Create( ErrStr );
    end;
    PBuf^ := WC;
    if PComma <> nil then PComma^ := ',';
//    Assert( RetCode = 0, 'BadDouble='+ ErrStr );
    Inc( PCurD );
  end; // for i := 0 to ANumDoubles-1 do // Get ANumDoubles Doubles from StrBuf

  while PBuf^ <= Char($020) do Inc( PBuf ); // skip 0(now is needed!), spaces and CRLF before next Tag

  // Note: difference of typed pointers is not in bytes but in number of elements of proper type!
  St.CPos := iBeg + integer(PBuf - PBegiBeg); // Update St.findex
end; //*** end of procedure TK_SerialTextBuf.GetDoubles

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddStrings
//********************************************* TK_SerialTextBuf.AddStrings ***
// Add given Strings to Serial Text Buffer
//
//     Parameters
// APString    - pointer to first String
// ANumDoubles - number of Strings
//
procedure TK_SerialTextBuf.AddStrings( APString: PString; ANumStrings: integer );
var
  i, i1, i2, StrSize, BufSize: Integer;
  Str, StrBuf: string;
  PBuf: PChar;
  PCurStr: PString;
begin
  if ANumStrings <= 0 then Exit;

  BufSize := 0;
  PCurStr := APString;
  for i := 0 to ANumStrings-1 do
  begin
    Inc( BufSize, Length(PCurStr^) );
    Inc( PCurStr );
  end;

{ Skip leeding '*' 21-04-2007
  SetLength( StrBuf, 2*BufSize + 4*ANumStrings + 3 ); // max possible Size
  PBuf := PChar(StrBuf);
  PBuf^ := '*'; // this char is needed because of tokenizer (it "eats" quote char after '>')
  Inc( PBuf );
}
{ return leeding '*' if first string starts with '*' 27-06-2007
  SetLength( StrBuf, 2*BufSize + 4*ANumStrings + 2 ); // max possible Size
  PBuf := PChar(StrBuf);
  PCurStr := APString;
}
  BufSize := 2*BufSize + 4*ANumStrings + 2;
  PCurStr := APString;
  i := BufSize; // Skip add '*' flag
  if (Length(PCurStr^) > 0) and
     (PCurStr^[1] = '*') then Inc(BufSize);
  SetLength( StrBuf, BufSize ); // max possible Size
  PBuf := PChar(StrBuf);
  if i <> BufSize then
  begin
    PBuf^ := '*'; // this char is needed because of tokenizer (it "eats" quote char after '>')
    Inc( PBuf );
  end;

  i1 := 1; // BufStr index
  i2 := 1; // index in each row
  if (OfsFreeM+1) > LineOffset then AddEOL( False );

  for i := 0 to ANumStrings-1 do // add all given Strings to StrBuf
  begin
//    Str := AnsiQuotedStr( PCurStr^, '"' );
    Str := N_QuoteString( PCurStr^, '"' );
    StrSize := Length(Str);
    Move( Str[1], PBuf^, StrSize * SizeOf(Char) );

    Inc( PBuf, StrSize );
    Inc( i1, StrSize );
    Inc( i2, StrSize );
    Inc( PCurStr );
    PBuf^ := ' '; // Strings delimeter
    Inc( PBuf );
    Inc( i1 );
    Inc( i2 );

    if i2 > LineMaxSize then // Add CRLF to StrBuf
    begin
//      PWORD(PBuf)^ := N_IntCRLF;
//      Inc( PBuf, 2 );
      TN_PTwoChars(PBuf)^ := N_IntCRLF; Inc( PBuf, 2 );
      Inc( i1, 2 );
      i2 := 1;
    end;
  end; // for i := 0 to ANumStrings-1 do // add all given Strings to StrBuf

  SetLength( StrBuf, i1-1 ); // real Size
  TextStrings.Add( StrBuf );
end; //*** end of procedure TK_SerialTextBuf.AddStrings

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetStrings
//********************************************* TK_SerialTextBuf.GetStrings ***
// Get given number of Strings from Serial Text Buffer
//
//     Parameters
// APString    - pointer to first String
// ANumStrings - number of Strings
//
procedure TK_SerialTextBuf.GetStrings( APString: PString; ANumStrings: integer );
var
  i, iBeg: Integer;
  PCurStr: PString;
  PBuf, PBegiBeg: PChar;
begin
  iBeg := St.CPos;
  PBuf := PChar(St.Text) + iBeg - 1;
  PBegiBeg := PBuf; // save initial value
  PCurStr := APString;
//  SetLength( N_s, 50 );
//  Move( PBuf^, N_s[1], 50 * SizeOf(Char)); // debug
  if PBuf^ = '*' then
    Inc( PBuf ) // Skip extra Char '*', for compatibility with previous files versions
  else
    Dec( PBuf ); // this is needed because of tokenizer
  for i := 0 to ANumStrings-1 do // Get ANumStrings Strings from StrBuf
  begin
//    while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces and CRLF before CurString
//    PCurStr^ := AnsiExtractQuotedStr( PBuf, '"' );
    PCurStr^ := N_DeQuoteChars( PBuf, 200 );
    Inc( PCurStr );
  end; // for i := 0 to ANumStrings-1 do // Get ANumStrings Strings from StrBuf

  while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces and CRLF before next Tag

  // Note: difference of typed pointers is not in bytes but in number of elements of proper type!
  St.CPos := iBeg + integer(PBuf - PBegiBeg); // Update St.findex
end; //*** end of procedure TK_SerialTextBuf.GetStrings


//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddFPoints
//********************************************* TK_SerialTextBuf.AddFPoints ***
// Add given Float Points Array to Serial Text Buffer and N_EmptyArray or 
// N_EndOfArray markup tokens
//
//     Parameters
// AFPArray       - Float Points Array
// AFirstInd      - fisrt point index
// ANumPoints     - number of points
// ACoordsFmtMode - cordinates format mode
//#F
//     =0 - One Point per Row (with index and N_EndOfArray delimeter)
//     =1 - Five Points per Row, Compact Float Coordinates format
//     >1 - Five Points per Row, Compact Integer Coordinates format
//#/F
// AMaxChars      - number of chars in resulting point coordinate value
// AAccuracy      - number of chars after decimal point
//
procedure TK_SerialTextBuf.AddFPoints( AFPArray: TN_FPArray; AFirstInd, ANumPoints,
                                ACoordsFmtMode, AMaxChars, AAccuracy: integer );
type TN_5FPoints = packed record
  X1,Y1, X2,Y2, X3,Y3, X4,Y4, X5,Y5: float;
end; // type TN_5FPoints = packed record
type TN_P5FPoints = ^TN_5FPoints;

var
  i, i1, StrSize, NumRows, RestPoints: Integer;
  Str1, StrBuf, FmtStr1, FmtStr: string;
  C: double;
  PBuf: PChar;
  PCurFP: PFPoint;
  PCur5FP: TN_P5FPoints;
begin
  if ACoordsFmtMode = 0 then // One Point per Row (with index and N_EndOfArray delimeter)
  begin
    if ANumPoints = 0 then // empty array
    begin
      AddToken( N_EmptyArray, K_ttString );
      AddEOL( False );
    end else // NumPoints >= 1
    begin
      SetLength( StrBuf, ((3+AMaxChars)*2 + 4)*ANumPoints ); // prelimenary Size
      FmtStr := Format( '%%.3d %%%d.%df %%%d.%df'#$D#$A, [AMaxChars,AAccuracy,AMaxChars,AAccuracy] );
      PCurFP := @AFPArray[AFirstInd];
      PBuf := PChar(StrBuf);
      i1 := 1;

      for i := 0 to ANumPoints-1 do // add to StrBuf point's indexes and Coords
      begin
        with PCurFP^ do
          Str1 := Format( FmtStr, [i,X,Y] );
        Inc( PCurFP );
        StrSize := Length( Str1 );
        Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
        Inc( i1, StrSize );
        Inc( PBuf, StrSize );
      end; // for i := 0 to NumPoints-1 do // add to StrBuf point's indexes and Coords

      SetLength( StrBuf, i1-1 ); // final Size
      TextStrings.Add( StrBuf );
    end; // else // NumPoints >= 1

    AddToken( N_EndOfArray, K_ttString );
    AddEOL( False );
  end else if ACoordsFmtMode = 1 then // 5 Points per Row, Compact Float Coords
  begin
    NumRows := ANumPoints div 5;
    RestPoints := ANumPoints - NumRows*5;
    FmtStr1 := Format( ' %%.%df', [AAccuracy] );
    FmtStr  := DupeString( FmtStr1, 10 ) + #$D#$A;
    SetLength( StrBuf, (3+AMaxChars)*2*ANumPoints + 2*NumRows + 4 ); // prelimenary Size
    PCur5FP := TN_P5FPoints(@AFPArray[AFirstInd]);
    PBuf := PChar(StrBuf);
    i1 := 1;

    for i := 0 to NumRows-1 do // add whole Rows (5 points per row) to StrBuf
    begin
      with PCur5FP^ do
        Str1 := Format( FmtStr, [X1,Y1, X2,Y2, X3,Y3, X4,Y4, X5,Y5] );
      Inc( PCur5FP );
      StrSize := Length( Str1 );
      Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
      Inc( i1, StrSize );
      Inc( PBuf, StrSize );
    end; // for i := 0 to NumRows-1 do // add whole Rows (5 points per row) to StrBuf

    if RestPoints > 0 then // add RestPoint (1 - 4) to StrBuf
    with PCur5FP^ do
    begin
      case RestPoints of
      1: begin
           FmtStr  := DupeString( FmtStr1, 2 ) + #$D#$A;
           Str1 := Format( FmtStr, [X1,Y1] );
         end;
      2: begin
           FmtStr  := DupeString( FmtStr1, 4 ) + #$D#$A;
           Str1 := Format( FmtStr, [X1,Y1, X2,Y2] );
         end;
      3: begin
           FmtStr  := DupeString( FmtStr1, 6 ) + #$D#$A;
           Str1 := Format( FmtStr, [X1,Y1, X2,Y2, X3,Y3] );
         end;
      4: begin
           FmtStr  := DupeString( FmtStr1, 8 ) + #$D#$A;
           Str1 := Format( FmtStr, [X1,Y1, X2,Y2, X3,Y3, X4,Y4] );
         end;
      end; // case RestPoints of

      StrSize := Length( Str1 );
      Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
      Inc( i1, StrSize );
    end; // if RestPoints > 0 then // add RestPoint (1 - 4) to StrBuf

    SetLength( StrBuf, i1-1 ); // final Size
    TextStrings.Add( StrBuf );
  end else // 5 Points per Row, Compact Integer Coords
  begin
    NumRows := ANumPoints div 5;
    RestPoints := ANumPoints - NumRows*5;
    C := Power( 10, AAccuracy ); // may be <0, =0, >0
    FmtStr1 := ' %d';
    FmtStr  := DupeString( FmtStr1, 10 ) + #$D#$A;
    SetLength( StrBuf, (3+AMaxChars)*2*ANumPoints + 2*NumRows + 4 ); // prelimenary Size
    PCur5FP := TN_P5FPoints(@AFPArray[AFirstInd]);
    PBuf := PChar(StrBuf);
    i1 := 1;

    for i := 0 to NumRows-1 do // add whole Rows (5 points per row) to StrBuf
    begin
      with PCur5FP^ do
        Str1 := Format( FmtStr, [Round(C*X1),Round(C*Y1), Round(C*X2),Round(C*Y2),
                                 Round(C*X3),Round(C*Y3), Round(C*X4),Round(C*Y4),
                                 Round(C*X5),Round(C*Y5)] );
      Inc( PCur5FP );
      StrSize := Length( Str1 );
      Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
      Inc( i1, StrSize );
      Inc( PBuf, StrSize );
    end; // for i := 0 to NumRows-1 do // add whole Rows (5 points per row) to StrBuf

    if RestPoints > 0 then // add RestPoint (1 - 4) to StrBuf
    with PCur5FP^ do
    begin
      case RestPoints of
      1: begin
           FmtStr  := DupeString( FmtStr1, 2 ) + #$D#$A;
           Str1 := Format( FmtStr, [Round(C*X1),Round(C*Y1)] );
         end;
      2: begin
           FmtStr  := DupeString( FmtStr1, 4 ) + #$D#$A;
           Str1 := Format( FmtStr, [Round(C*X1),Round(C*Y1), Round(C*X2),Round(C*Y2)] );
         end;
      3: begin
           FmtStr  := DupeString( FmtStr1, 6 ) + #$D#$A;
           Str1 := Format( FmtStr, [Round(C*X1),Round(C*Y1), Round(C*X2),Round(C*Y2),
                                    Round(C*X3),Round(C*Y3)] );
         end;
      4: begin
           FmtStr  := DupeString( FmtStr1, 8 ) + #$D#$A;
           Str1 := Format( FmtStr, [Round(C*X1),Round(C*Y1), Round(C*X2),Round(C*Y2),
                                    Round(C*X3),Round(C*Y3), Round(C*X4),Round(C*Y4)] );
         end;
      end; // case RestPoints of

      StrSize := Length( Str1 );
      Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
      Inc( i1, StrSize );
    end; // if RestPoints > 0 then // add RestPoint (1 - 4) to StrBuf

    SetLength( StrBuf, i1-1 ); // final Size
    TextStrings.Add( StrBuf );
  end; //else // 5 Points per Row, Compact Integer Coords
end; //*** end of procedure TK_SerialTextBuf.AddFPoints


//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetFPoints
//********************************************* TK_SerialTextBuf.GetFPoints ***
// Get Float Points to given Array starting from element with AFreeInd (till 
// N_EndOfArray token)
//
//     Parameters
// AÀPArray       - Float Points Array
// AFreeInd       - index of first array element for parsing point
// ANumPoints     - number of points
// ACoordsFmtMode - cordinates format mode
//#F
//     =0 - One Point per Row (with index and N_EndOfArray delimeter)
//     =1 - Five Points per Row, Compact Float Coordinates format
//     >1 - Five Points per Row, Compact Integer Coordinates format
//#/F
// AAccuracy      - coordinates factor in Compact Integer format
// Result         - Returns number of parsed points, 0 if empty array parsed, -1
//                  if no elements are parsed
//
function TK_SerialTextBuf.GetFPoints( var AFPArray: TN_FPArray; var AFreeInd: integer;
                             ANumPoints, ACoordsFmtMode, AAccuracy: integer ): integer;
var
  i, iBeg, IValue, RetCode: Integer;
  PBeg, PBuf, PComma, PBegiBeg: PChar;
  C: double;
  PCurFPoint: PFPoint;
  WC : Char;
  ErrStr : string;
begin
  iBeg := St.CPos;
  PBuf := PChar(St.Text) + iBeg - 1;
  PBegiBeg := PBuf; // save initial value
  Result := 0;
  N_i := GetRowNumber( 0 );
//  SetLength( N_s, 100 );      // debug
//  move( PBuf^, N_s[1], 100 * SizeOf(Char) );

  if ACoordsFmtMode = 0 then // One Point per Row (with index and N_EndOfArray delimeter)
  begin
    while True do
    begin
      Val( PBuf, N_i, RetCode ); // Get Point Index (not used) or stop on delimeter token
      Inc( PBuf, RetCode-1 );

      if High(AFPArray) < (AFreeInd+ANumPoints) then
        SetLength( AFPArray, N_NewLength( AFreeInd+ANumPoints ) );

      PCurFPoint := @AFPArray[AFreeInd];

      if Byte(PBuf^) = $020 then // it was Point Index, Get Point X,Y coords
      with PCurFPoint^ do
      begin
        while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces before X
        PBeg := PBuf;
        PComma := nil;
        while PBuf^ > Char($020) do
        begin
          if PBuf^ = ',' then begin
            PComma := PBuf;
            PComma^ := '.';
          end;
          Inc( PBuf ); // skip X
        end;
        WC := PBuf^;
        PBuf^ := Char( 0 ); // X terminating zero
        Val( PBeg, X, RetCode );
        PBuf^ := WC;
        if PComma <> nil then PComma^ := ',';

        while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces before Y
        PBeg := PBuf;
        PComma := nil;
        while PBuf^ > Char($020) do
        begin
          if PBuf^ = ',' then begin
            PComma := PBuf;
            PComma^ := '.';
          end;
          Inc( PBuf ); // skip Y
        end;
        WC := PBuf^;
        PBuf^ := Char( 0 ); // Y terminating zero instead of space or CR
        Val( PBeg, Y, RetCode );
        PBuf^ := WC;
        if PComma <> nil then PComma^ := ',';

        Inc( PBuf, 1 ); // skip Y terminating zero
//        N_s := ' ';
//        N_s[1] := PBuf^;
        Val( PBuf, N_i, RetCode ); // skip spaces till CRLF
        Inc( PBuf, RetCode-1 );

        if PBuf^ = Char( $0D ) then Inc( PBuf, 2 )
        else if PBuf^ = Char( $0A ) then Inc( PBuf, 1 )
        else Assert( False, 'Bad Coords Delimeter (1)!' );

        Inc( AFreeInd );
        Inc( Result );
        Continue;
      end; // if Byte(PBuf^) = $020 then // it was Point Index, Get Point X,Y coords

      if Byte(PBuf^) = $0D then // skip CRLF
      begin
        Inc( PBuf, 2 );
        Continue;
      end; // if Byte(PBuf^) = $0D then // skip CRLF

      if CompareMem( Pbuf, @N_EndOfArray[1], N_EndOfArraySize * SizeOf(Char) ) then
      begin
        Inc( Pbuf, N_EndOfArraySize ); // skip N_EndOfArray token
        if Result = 0 then Result := -1; // it was not an Array
        Break;
      end;

      if CompareMem( Pbuf, @N_EmptyArray[1], N_EmptyArraySize * SizeOf(Char) ) then
      begin
        Inc( PBuf, N_EmptyArraySize ); // skip N_EmptyArray token
        Break;
      end;

      N_i := GetRowNumber( 0 );
      Assert( False, 'Bad Coords Delimeter (2)!' );
    end; // while True do
  end else if ACoordsFmtMode = 1 then // 5 Points per Row, Compact Float Coords
  begin
    if High(AFPArray) < (AFreeInd+ANumPoints) then
      SetLength( AFPArray, N_NewLength( AFreeInd+ANumPoints ) );
    PCurFPoint := @AFPArray[AFreeInd];

    for i := 0 to ANumPoints-1 do // read given number of Points
    begin
      while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces and CRLF before X
      PBeg := PBuf;
      while PBuf^ > Char($020) do Inc( PBuf ); // skip X
      WC := PBuf^;
      PBuf^ := Char( 0 ); // X terminating zero

      with PCurFPoint^ do
      begin
        Val( PBeg, X, RetCode );
        if RetCode <> 0 then
        begin
          ErrStr := 'BadXCoord='+ PBeg;
          PBuf^ := WC;
          N_Dump1Str( 'TK_SerialTextBuf ' + ErrStr );
          raise TK_LoadUDDataError.Create( ErrStr );
        end;
        PBuf^ := WC;
//        Assert( RetCode = 0, 'BadXCoord!' );
        Inc( PBuf ); // skip X terminating zero
        while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces before Y
        PBeg := PBuf;
        while PBuf^ > Char($020) do Inc( PBuf ); // skip Y
        WC := PBuf^;
        PBuf^ := Char( 0 ); // Y terminating zero instead of space or CR
        Val( PBeg, Y, RetCode );
        if RetCode <> 0 then
        begin
          ErrStr := 'BadYCoord='+ PBeg;
          PBuf^ := WC;
          N_Dump1Str( 'TK_SerialTextBuf ' + ErrStr );
          raise TK_LoadUDDataError.Create( ErrStr );
        end;
        PBuf^ := WC;
//        Assert( RetCode = 0, 'BadYCoord!' );
        Inc( PBuf ); // skip Y terminating zero
      end; // with PCurFPoint^ do

      Inc( PCurFPoint );
      Inc( AFreeInd );
      Inc( Result );
    end; // for i := 0 to ANumPoints-1 do // read given number of Points
  end else if ACoordsFmtMode = 2 then // 5 Points per Row, Compact Integer Coords
  begin
    if High(AFPArray) < (AFreeInd+ANumPoints) then
      SetLength( AFPArray, N_NewLength( AFreeInd+ANumPoints ) );
    PCurFPoint := @AFPArray[AFreeInd];
    C := Power( 10, -AAccuracy );

    for i := 0 to ANumPoints-1 do // read given number of Points
    begin
      while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces and CRLF before X
      PBeg := PBuf;
      while PBuf^ > Char($020) do Inc( PBuf ); // skip X
      WC := PBuf^;
      PBuf^ := Char( 0 ); // X terminating zero

      with PCurFPoint^ do
      begin
        Val( PBeg, IValue, RetCode );
        if RetCode <> 0 then
        begin
          ErrStr := 'BadXCoord='+ PBeg;
          PBuf^ := WC;
          N_Dump1Str( 'TK_SerialTextBuf ' + ErrStr );
          raise TK_LoadUDDataError.Create( ErrStr );
        end;
        PBuf^ := WC;
        X := IValue*C;
//        Assert( RetCode = 0, 'BadXCoord!' );
        Inc( PBuf ); // skip X terminating zero
        while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces before Y
        PBeg := PBuf;
        while PBuf^ > Char($020) do Inc( PBuf ); // skip Y
        WC := PBuf^;
        PBuf^ := Char( 0 ); // Y terminating zero instead of space or CR
        Val( PBeg, IValue, RetCode );
        if RetCode <> 0 then
        begin
          ErrStr := 'BadYCoord='+ PBeg;
          PBuf^ := WC;
          N_Dump1Str( 'TK_SerialTextBuf ' + ErrStr );
          raise TK_LoadUDDataError.Create( ErrStr );
        end;
        PBuf^ := WC;
        Y := IValue*C;
//        Assert( RetCode = 0, 'BadYCoord!' );
        Inc( PBuf ); // skip Y terminating zero
      end; // with PCurFPoint^ do

      Inc( PCurFPoint );
      Inc( AFreeInd );
      Inc( Result );
    end; // for i := 0 to ANumPoints-1 do // read given number of Points
  end else // else // 5 Points per Row, Compact Integer Coords
    Assert( False, 'Bad ACoordsFmtMode!' );

  // Note: difference of typed pointers is not in bytes but in number of elements of proper type!
  St.CPos := iBeg + integer(PBuf - PBegiBeg); // Update St.findex
end; //*** end of procedure TK_SerialTextBuf.GetFPoints

type TN_5DPoints = packed record
  X1,Y1, X2,Y2, X3,Y3, X4,Y4, X5,Y5: double;
end; // type TN_5DPoints = packed record
type TN_P5DPoints = ^TN_5DPoints;

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddDPoints
//********************************************* TK_SerialTextBuf.AddDPoints ***
// Add given Double Points Array to Serial Text Buffer and N_EmptyArray or 
// N_EndOfArray markup tokens
//
//     Parameters
// ADPArray       - Double Points Array
// AFirstInd      - fisrt point index
// ANumPoints     - number of points
// ACoordsFmtMode - cordinates format mode
//#F
//     =0 - One Point per Row (with index and N_EndOfArray delimeter)
//     =1 - Five Points per Row, Compact Float Coordinates format
//     >1 - Five Points per Row, Compact Integer Coordinates format
//#/F
// AMaxChars      - number of chars in resulting point coordinate value
// AAccuracy      - number of chars after decimal point or coordinates in factor
//                  Compact Integer format
//
procedure TK_SerialTextBuf.AddDPoints( ADPArray: TN_DPArray;
                 AFirstInd, ANumPoints, ACoordsFmtMode, AMaxChars, AAccuracy: integer );
var
  i, i1, StrSize, NumRows, RestPoints: Integer;
  Str1, StrBuf, FmtStr1, FmtStr: string;
  C: double;
  PBuf: PChar;
  PCurDP: PDPoint;
  PCur5DP: TN_P5DPoints;
begin
  if ACoordsFmtMode = 0 then // One Point per Row (with index and N_EndOfArray delimeter)
  begin
    if ANumPoints = 0 then // empty array
    begin
      AddToken( N_EmptyArray, K_ttString );
      AddEOL( False );
    end else // NumPoints >= 1
    begin
      SetLength( StrBuf, ((3+AMaxChars)*2 + 4)*ANumPoints ); // prelimenary Size
      FmtStr := Format( '%%.3d %%%d.%df %%%d.%df'#$D#$A, [AMaxChars,AAccuracy,AMaxChars,AAccuracy] );
      PCurDP := @ADPArray[AFirstInd];
      PBuf := PChar(StrBuf);
      i1 := 1;

      for i := 0 to ANumPoints-1 do // add to StrBuf point's indexes and Coords
      begin
        with PCurDP^ do
          Str1 := Format( FmtStr, [i,X,Y] );
        Inc( PCurDP );
        StrSize := Length( Str1 );
        Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
        Inc( i1, StrSize );
        Inc( PBuf, StrSize );
      end; // for i := 0 to NumPoints-1 do // add to StrBuf point's indexes and Coords

      SetLength( StrBuf, i1-1 ); // final Size
      TextStrings.Add( StrBuf );
    end; // else // NumPoints >= 1

    AddToken( N_EndOfArray, K_ttString );
    AddEOL( False );
  end else if ACoordsFmtMode = 1 then // 5 Points per Row, Compact Float Coords
  begin
    NumRows := ANumPoints div 5;
    RestPoints := ANumPoints - NumRows*5;
    FmtStr1 := Format( ' %%.%df', [AAccuracy] );
    FmtStr  := DupeString( FmtStr1, 10 ) + #$D#$A;
    SetLength( StrBuf, (3+AMaxChars)*2*ANumPoints + 2*NumRows + 4 ); // prelimenary Size
    PCur5DP := TN_P5DPoints(@ADPArray[AFirstInd]);
    PBuf := PChar(StrBuf);
    i1 := 1;

    for i := 0 to NumRows-1 do // add whole Rows (5 points per row) to StrBuf
    begin
      with PCur5DP^ do
        Str1 := Format( FmtStr, [X1,Y1, X2,Y2, X3,Y3, X4,Y4, X5,Y5] );
      Inc( PCur5DP );
      StrSize := Length( Str1 );
      Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
      Inc( i1, StrSize );
      Inc( PBuf, StrSize );
    end; // for i := 0 to NumRows-1 do // add whole Rows (5 points per row) to StrBuf

    if RestPoints > 0 then // add RestPoint (1 - 4) to StrBuf
    with PCur5DP^ do
    begin
      case RestPoints of
      1: begin
           FmtStr  := DupeString( FmtStr1, 2 ) + #$D#$A;
           Str1 := Format( FmtStr, [X1,Y1] );
         end;
      2: begin
           FmtStr  := DupeString( FmtStr1, 4 ) + #$D#$A;
           Str1 := Format( FmtStr, [X1,Y1, X2,Y2] );
         end;
      3: begin
           FmtStr  := DupeString( FmtStr1, 6 ) + #$D#$A;
           Str1 := Format( FmtStr, [X1,Y1, X2,Y2, X3,Y3] );
         end;
      4: begin
           FmtStr  := DupeString( FmtStr1, 8 ) + #$D#$A;
           Str1 := Format( FmtStr, [X1,Y1, X2,Y2, X3,Y3, X4,Y4] );
         end;
      end; // case RestPoints of

      StrSize := Length( Str1 );
      Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
      Inc( i1, StrSize );
    end; // if RestPoints > 0 then // add RestPoint (1 - 4) to StrBuf

    SetLength( StrBuf, i1-1 ); // final Size
    TextStrings.Add( StrBuf );
  end else // 5 Points per Row, Compact Integer Coords
  begin
    NumRows := ANumPoints div 5;
    RestPoints := ANumPoints - NumRows*5;
    C := Power( 10, AAccuracy ); // may be <0, =0, >0
    FmtStr1 := ' %d';
    FmtStr  := DupeString( FmtStr1, 10 ) + #$D#$A;
    SetLength( StrBuf, (3+AMaxChars)*2*ANumPoints + 2*NumRows + 4 ); // prelimenary Size
    PCur5DP := TN_P5DPoints(@ADPArray[AFirstInd]);
    PBuf := PChar(StrBuf);
    i1 := 1;

    for i := 0 to NumRows-1 do // add whole Rows (5 points per row) to StrBuf
    begin
      with PCur5DP^ do
        Str1 := Format( FmtStr, [Round(C*X1),Round(C*Y1), Round(C*X2),Round(C*Y2),
                                 Round(C*X3),Round(C*Y3), Round(C*X4),Round(C*Y4),
                                 Round(C*X5),Round(C*Y5)] );
      Inc( PCur5DP );
      StrSize := Length( Str1 );
      Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
      Inc( i1, StrSize );
      Inc( PBuf, StrSize );
    end; // for i := 0 to NumRows-1 do // add whole Rows (5 points per row) to StrBuf

    if RestPoints > 0 then // add RestPoint (1 - 4) to StrBuf
    with PCur5DP^ do
    begin
      case RestPoints of
      1: begin
           FmtStr  := DupeString( FmtStr1, 2 ) + #$D#$A;
           Str1 := Format( FmtStr, [Round(C*X1),Round(C*Y1)] );
         end;
      2: begin
           FmtStr  := DupeString( FmtStr1, 4 ) + #$D#$A;
           Str1 := Format( FmtStr, [Round(C*X1),Round(C*Y1), Round(C*X2),Round(C*Y2)] );
         end;
      3: begin
           FmtStr  := DupeString( FmtStr1, 6 ) + #$D#$A;
           Str1 := Format( FmtStr, [Round(C*X1),Round(C*Y1), Round(C*X2),Round(C*Y2),
                                    Round(C*X3),Round(C*Y3)] );
         end;
      4: begin
           FmtStr  := DupeString( FmtStr1, 8 ) + #$D#$A;
           Str1 := Format( FmtStr, [Round(C*X1),Round(C*Y1), Round(C*X2),Round(C*Y2),
                                    Round(C*X3),Round(C*Y3), Round(C*X4),Round(C*Y4)] );
         end;
      end; // case RestPoints of

      StrSize := Length( Str1 );
      Move( Str1[1], PBuf^, StrSize * SizeOf(Char) );
      Inc( i1, StrSize );
    end; // if RestPoints > 0 then // add RestPoint (1 - 4) to StrBuf

    SetLength( StrBuf, i1-1 ); // final Size
    TextStrings.Add( StrBuf );
  end; //else // 5 Points per Row, Compact Integer Coords
end; //*** end of procedure TK_SerialTextBuf.AddDPoints

{
//******************************************** TK_SerialTextBuf.GetDPoints ***
// get some number of DPoints (till N_EndOfArray token) to given DPArray
// from FreeInd Index, add Number of red points to FreeInd,
// increase DPArray length if needed,
// return number of added points (0 for empty array) or -1 if not an Array
//
function TK_SerialTextBuf.GetDPoints( var DPArray: TN_DPArray;
                   var FreeInd: integer; ANumPoints, ACoordsFmtMode: integer ): integer;
var
  RetCode: Integer;
  Str: string;
begin
  Result := 0;
  while True do
  begin
    GetToken( Str );
    if Str = N_EndOfArray then
    begin
      if Result = 0 then Result := -1; // it was not an Array
      Break;
    end;

    if Str = N_EmptyArray then
    begin
      GetToken( Str ); // skip N_EndOfArray
      Break;
    end;

    if High(DPArray) < FreeInd then
      SetLength( DPArray, N_NewLength(FreeInd) );
    GetToken( Str );
    Val( Str, DPArray[FreeInd].X, RetCode );
    Assert( RetCode = 0, 'Bad Coord1' );
    GetToken( Str );
    Val( Str, DPArray[FreeInd].Y, RetCode );
    Assert( RetCode = 0, 'Bad Coord2' );
    Inc(FreeInd);
    Inc(Result);
  end; // while True do
end; //*** end of procedure TK_SerialTextBuf.GetDPoints
}

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetDPoints
//********************************************* TK_SerialTextBuf.GetDPoints ***
// Get Double Points to given Array starting from element with AFreeInd (till 
// N_EndOfArray token)
//
//     Parameters
// ADPArray       - Double Points Array
// AFreeInd       - index of first array element for parsing point
// ANumPoints     - number of points
// ACoordsFmtMode - cordinates format mode
//#F
//     =0 - One Point per Row (with index and N_EndOfArray delimeter)
//     =1 - Five Points per Row, Compact Float Coordinates format
//     >1 - Five Points per Row, Compact Integer Coordinates format
//#/F
// AAccuracy      - coordinates factor in Compact Integer format
// Result         - Returns number of parsed points, 0 if empty array parsed, -1
//                  if no elements are parsed
//
function TK_SerialTextBuf.GetDPoints( var ADPArray: TN_DPArray; var AFreeInd: integer;
                      ANumPoints, ACoordsFmtMode, AAccuracy: integer ): integer;
var
  i, iBeg, IValue, RetCode: Integer;
  PBeg, PBegiBeg, PBuf, PComma: PChar;
  C: double;
  PCurDPoint: PDPoint;
  WC : Char;
  ErrStr : string;
begin
  iBeg := St.CPos;
  PBuf := PChar(St.Text) + iBeg - 1;
  PBegiBeg := PBuf; // save initial value
  Result := 0;
  SetLength( N_s, 100 );      // debug
  move( PBuf^, N_s[1], 100 * SizeOf(Char) );

  if ACoordsFmtMode = 0 then // One Point per Row (with index and N_EndOfArray delimeter)
  begin
    while True do
    begin
      Val( PBuf, N_i, RetCode ); // Get Point Index (not used) or stop on delimeter token
      Inc( PBuf, RetCode-1 );

      if High(ADPArray) < (AFreeInd+ANumPoints) then
        SetLength( ADPArray, N_NewLength( AFreeInd+ANumPoints ) );

      PCurDPoint := @ADPArray[AFreeInd];

      if Byte(PBuf^) = $020 then // it was Point Index, Get Point X,Y coords
      with PCurDPoint^ do
      begin

        while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces before X
        PBeg := PBuf;
        PComma := nil;
        while PBuf^ > Char($020) do
        begin
          if PBuf^ = ',' then begin
            PComma := PBuf;
            PComma^ := '.';
          end;
          Inc( PBuf ); // skip X
        end;
        WC := PBuf^;
        PBuf^ := Char( 0 ); // X terminating zero
        Val( PBeg, X, RetCode );
        PBuf^ := WC;
        if PComma <> nil then PComma^ := ',';

        while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces before Y
        PBeg := PBuf;
        PComma := nil;
        while PBuf^ > Char($020) do
        begin
          if PBuf^ = ',' then begin
            PComma := PBuf;
            PComma^ := '.';
          end;
          Inc( PBuf ); // skip Y
        end;
        WC := PBuf^;
        PBuf^ := Char( 0 ); // Y terminating zero instead of space or CR
        Val( PBeg, Y, RetCode );
        PBuf^ := WC;
        if PComma <> nil then PComma^ := ',';

        Inc( PBuf, 1 ); // skip Y terminating zero
//        N_s := ' ';
//        N_s[1] := PBuf^;
        Val( PBuf, N_i, RetCode ); // skip spaces till CRLF
        Inc( PBuf, RetCode-1 );

        if PBuf^ = Char( $0D ) then Inc( PBuf, 2 )
        else if PBuf^ = Char( $0A ) then Inc( PBuf, 1 )
        else Assert( False, 'Bad Coords Delimeter (1)!' );

        Inc( AFreeInd );
        Inc( Result );

      move( PBuf^, N_s[1], 20 * SizeOf(Char) );
      N_s1 := LeftStr( N_s, 20 );
//      N_Dump1Str( Format( 'AAA X:=%3.4f Y:=%3.4f Buf=%s', [X,Y,N_s1] ));
      N_s1 := LeftStr( N_s, 4 );
      if N_s = '4958' then
        N_i := 1;

        Continue;
      end; // if Byte(PBuf^) = $020 then // it was Point Index, Get Point X,Y coords

      if PBuf^ = Char($0D) then // skip CRLF
      begin
        Inc( PBuf, 2 );
        Continue;
      end; // if PBuf^ = Char($0D) then // skip CRLF

      move( PBuf^, N_s[1], 100 * SizeOf(Char) );
      N_Dump1Str( Format( 'AAA AFreeInd=%x Buf=%s', [AFreeInd,N_s] ));

      if CompareMem( Pbuf, @N_EndOfArray[1], N_EndOfArraySize * SizeOf(Char) ) then
      begin
        Inc( Pbuf, N_EndOfArraySize ); // skip N_EndOfArray token
        if Result = 0 then Result := -1; // it was not an Array
        Break;
      end;

      if CompareMem( Pbuf, @N_EmptyArray[1], N_EmptyArraySize * SizeOf(Char) ) then
      begin
        Inc( PBuf, N_EmptyArraySize ); // skip N_EmptyArray token
        Break;
      end;

      Assert( False, 'Bad Coords Delimeter (2)!' );
    end; // while True do
  end else if ACoordsFmtMode = 1 then // 5 Points per Row, Compact Float Coords
  begin
    if High(ADPArray) < (AFreeInd+ANumPoints) then
      SetLength( ADPArray, N_NewLength( AFreeInd+ANumPoints ) );
    PCurDPoint := @ADPArray[AFreeInd];

    for i := 0 to ANumPoints-1 do // read given number of Points
    begin
      while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces and CRLF before X
      PBeg := PBuf;
      PComma := nil;
      while PBuf^ > Char($020) do
      begin
        if PBuf^ = ',' then begin
          PComma := PBuf;
          PComma^ := '.';
        end;
        Inc( PBuf ); // skip X
      end;
      WC := PBuf^;
      PBuf^ := Char( 0 ); // X terminating zero

      with PCurDPoint^ do
      begin
        Val( PBeg, X, RetCode );
        if RetCode <> 0 then
        begin
          ErrStr := 'BadXCoord='+ PBeg;
          PBuf^ := WC;
          if PComma <> nil then PComma^ := ',';
          N_Dump1Str( 'TK_SerialTextBuf ' + ErrStr );
          raise TK_LoadUDDataError.Create( ErrStr );
        end;
        PBuf^ := WC;
        if PComma <> nil then PComma^ := ',';
//        Assert( RetCode = 0, 'BadXCoord!' );
        Inc( PBuf ); // skip X terminating zero
        while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces before Y
        PBeg := PBuf;
        PComma := nil;
        while PBuf^ > Char($020) do
        begin
          if PBuf^ = ',' then begin
            PComma := PBuf;
            PComma^ := '.';
          end;
          Inc( PBuf ); // skip Y
        end;
        WC := PBuf^;
        PBuf^ := Char( 0 ); // Y terminating zero instead of space or CR
        N_s := String( PBeg );
        Val( PBeg, Y, RetCode );
        if RetCode <> 0 then
        begin
          ErrStr := 'BadYCoord='+ PBeg;
          PBuf^ := WC;
          if PComma <> nil then PComma^ := ',';
          N_Dump1Str( 'TK_SerialTextBuf ' + ErrStr );
          raise TK_LoadUDDataError.Create( ErrStr );
        end;
        PBuf^ := WC;
        if PComma <> nil then PComma^ := ',';
{ // debug code
        if RetCode <> 0 then
        begin
          N_i := GetRowNumber();
        end;
}
//        Assert( RetCode = 0, 'BadYCoord!' );
        Inc( PBuf ); // skip Y terminating zero
      end; // with PCurDPoint^ do

      Inc( PCurDPoint );
      Inc( AFreeInd );
      Inc( Result );
    end; // for i := 0 to ANumPoints-1 do // read given number of Points
  end else if ACoordsFmtMode = 2 then // 5 Points per Row, Compact Integer Coords
  begin
    if High(ADPArray) < (AFreeInd+ANumPoints) then
      SetLength( ADPArray, N_NewLength( AFreeInd+ANumPoints ) );
    PCurDPoint := @ADPArray[AFreeInd];
    C := Power( 10, -AAccuracy );

    for i := 0 to ANumPoints-1 do // read given number of Points
    begin
      while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces and CRLF before X
      PBeg := PBuf;
      PComma := nil;
      while PBuf^ > Char($020) do
      begin
        if PBuf^ = ',' then begin
          PComma := PBuf;
          PComma^ := '.';
        end;
        Inc( PBuf ); // skip Y
      end;
      WC := PBuf^;
      PBuf^ := Char( 0 ); // X terminating zero

      with PCurDPoint^ do
      begin
        Val( PBeg, IValue, RetCode );
        if RetCode <> 0 then
        begin
          ErrStr := 'BadXCoord='+ PBeg;
          PBuf^ := WC;
          if PComma <> nil then PComma^ := ',';
          N_Dump1Str( 'TK_SerialTextBuf ' + ErrStr );
          raise TK_LoadUDDataError.Create( ErrStr );
        end;
        PBuf^ := WC;
        if PComma <> nil then PComma^ := ',';
        X := IValue*C;
//        Assert( RetCode = 0, 'BadXCoord!' );
        Inc( PBuf ); // skip X terminating zero
        while PBuf^ <= Char($020) do Inc( PBuf ); // skip spaces before Y
        PBeg := PBuf;
        PComma := nil;
        while PBuf^ > Char($020) do
        begin
          if PBuf^ = ',' then begin
            PComma := PBuf;
            PComma^ := '.';
          end;
          Inc( PBuf ); // skip Y
        end;
        WC := PBuf^;
        PBuf^ := Char( 0 ); // Y terminating zero instead of space or CR
        Val( PBeg, IValue, RetCode );
        if RetCode <> 0 then
        begin
          ErrStr := 'BadYCoord='+ PBeg;
          PBuf^ := WC;
          if PComma <> nil then PComma^ := ',';
          N_Dump1Str( 'TK_SerialTextBuf ' + ErrStr );
          raise TK_LoadUDDataError.Create( ErrStr );
        end;
        PBuf^ := WC;
        if PComma <> nil then PComma^ := ',';
        Y := IValue*C;
//        Assert( RetCode = 0, 'BadYCoord!' );
        Inc( PBuf ); // skip Y terminating zero
      end; // with PCurDPoint^ do

      Inc( PCurDPoint );
      Inc( AFreeInd );
      Inc( Result );
    end; // for i := 0 to ANumPoints-1 do // read given number of Points
  end else // else // 5 Points per Row, Compact Integer Coords
    Assert( False, 'Bad ACoordsFmtMode!' );

  // Note: difference of typed pointers is not in bytes but in number of elements of proper type!
  St.CPos := iBeg + integer(PBuf - PBegiBeg); // Update St.findex
end; //*** end of procedure TK_SerialTextBuf.GetDPoints

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddBitMap
//********************************************** TK_SerialTextBuf.AddBitMap ***
// Add given BitMap to Serial Text Buffer
//
//     Parameters
// ABMP - given BitMap object
// ATag - markup Tag name (default value is empty string, if given then new Tag 
//        will be added before BitMap)
//
procedure TK_SerialTextBuf.AddBitMap( ABMP: TBitMap; const ATag : string = '' );
var
  i, ScanLineSize: integer;
begin
  if ATag <> '' then AddTag( ATag );
  i := ABMP.Width;
  AddTagAttr( 'BMPWidth', i, K_isInteger );
  i := ABMP.Height;
  AddTagAttr( 'BMPHeight', i, K_isInteger );
  i := Ord(ABMP.PixelFormat);
  AddTagAttr( 'BMPPixelFormat', i, K_isInteger );
  case ABMP.PixelFormat of
  pf1Bit:  ScanLineSize := (ABMP.Width shr 3) + 1;
  pf8Bit:  ScanLineSize := ABMP.Width;
  pf15Bit: ScanLineSize := ABMP.Width shl 1;
  pf16Bit: ScanLineSize := ABMP.Width shl 1;
  pf24Bit: ScanLineSize := ABMP.Width * 3;
  pf32Bit: ScanLineSize := ABMP.Width shl 2;
  else  ScanLineSize := ABMP.Width shl 2;
  end;
  AddTagAttr( 'BMPLineSize', ScanLineSize, K_isInteger );
  AddEoL(false);
  for i := 0 to ABMP.Height-1 do
    AddRowBytes( ScanLineSize, ABMP.Scanline[i] );
  if ATag <> '' then AddTag( ATag, tgClose );
end; //*** end of procedure TK_SerialTextBuf.AddBitMap

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetBitMap
//********************************************** TK_SerialTextBuf.GetBitMap ***
// Get BitMap from Serial Text Buffer
//
//     Parameters
// ABMP - given BitMap object
// ATag - markup Tag name (default value is empty string, if given the close Tag
//        will be parsed)
//
// Creates TBitMap object if not yet and fill it.
//
procedure TK_SerialTextBuf.GetBitMap( var ABMP: TBitMap; const ATag : string = '' );
var
  i, ScanLineSize: integer;
begin
  if ABMP = nil then ABMP := TBitMap.Create();
  GetTagAttr( 'BMPWidth', i, K_isInteger );
  ABMP.Width := i;
  GetTagAttr( 'BMPHeight', i, K_isInteger );
  ABMP.Height := i;
  GetTagAttr( 'BMPPixelFormat', i, K_isInteger );
  ABMP.PixelFormat := TPixelFormat(i);

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
  if ATag <> '' then GetSpecTag( ATag, tgClose );
end; //*** end of procedure TK_SerialTextBuf.GetBitMap

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddRowStrings
//****************************************** TK_SerialTextBuf.AddRowStrings ***
// Add given TStrings to Serial Text Buffer
//
//     Parameters
// ASL  - given TStrings object
// ATag - markup Tag name (default value is empty string, if given then new Tag 
//        will be added before given Strings)
//
procedure TK_SerialTextBuf.AddRowStrings( ASL: TStrings; const ATag : string = '' );
var
  NumStrings : integer;
begin
  if ATag <> '' then AddTag( ATag );
  NumStrings := ASL.Count;
  AddTagAttr( K_tbArrLength, NumStrings, K_isInteger );
  AddEOL( false );
  TextStrings.BeginUpdate;
  TextStrings.AddStrings( ASL );
  TextStrings.EndUpdate;
  AddEOL( false );
  if ATag <> '' then AddTag( ATag, tgClose );

end; //*** end of procedure TK_SerialTextBuf.AddRowStrings

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetRowStrings
//****************************************** TK_SerialTextBuf.GetRowStrings ***
// Get strings from Serial Text Buffer to given TStrings
//
//     Parameters
// ASL  - given TStrings object
// ATag - markup Tag name (default value is empty string, if given the close Tag
//        will be parsed)
//
procedure TK_SerialTextBuf.GetRowStrings( ASL: TStrings; const ATag : string = '' );
var
  i, ind, NumStrings: integer;
  WStr : string;
begin
  ASL.Clear;
  GetTagAttr( K_tbArrLength, NumStrings, K_isInteger );
  ind := GetRowNumber - 1;
  for i := 1 to NumStrings do
  begin
    WStr := TextStrings.Strings[ind];
    ASL.Add( WStr );
    St. shiftPos( Length(WStr) + 2 );
    Inc(ind);
  end;
  if ATag <> '' then GetSpecTag( ATag, tgClose );

end; //*** end of procedure TK_SerialTextBuf.GetRowStrings

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\SaveToFile
//********************************************* TK_SerialTextBuf.SaveToFile ***
// Save serialized data from Text Buffer to given file
//
//     Parameters
// AFileName - file name to save Text Buffer data
//
procedure  TK_SerialTextBuf.SaveToFile( const AFileName: String );
begin
  AddEOL( false );
  if Length(AFileName) > 0 then begin
     K_VFSaveStrings( TextStrings, AFileName,
                           K_DFCreatePlain )
{
    if N_PosEx( '|', AFileName, 1, Length(AFileName) ) > 0 then
      K_VFSaveStrings( TextStrings, AFileName,
                           K_DFCreatePlain )
    else
      TextStrings.SaveToFile( AFileName );
}
  end;
  SetCapacity( -1000 );
end; //*** end of procedure TK_SerialTextBuf.SaveToFile

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\LoadFromFile
//******************************************* TK_SerialTextBuf.LoadFromFile ***
// Load serialized data from given file to Text Buffer
//
//     Parameters
// AFileName - file name to load serialized data
//
procedure  TK_SerialTextBuf.LoadFromFile( const AFileName: String );
begin
  if Length(AFileName) > 0 then
  begin
    TextStrings.Clear;
//    TextStrings.LoadFromFile(  FileName );
    K_VFLoadStrings( TextStrings, AFileName );
  end;
  InitLoad1();
end; //*** end of procedure TK_SerialTextBuf.LoadFromFile

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\LoadFromText
//******************************************* TK_SerialTextBuf.LoadFromText ***
// Load serialized data from given text string to Text Buffer
//
//     Parameters
// AText - given text string
//
procedure  TK_SerialTextBuf.LoadFromText( const AText : String );
begin
  TextStrings.Text := AText;
  InitLoad1();
end; //*** end of procedure TK_SerialTextBuf.LoadFromText

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\GetRowNumber
//******************************************* TK_SerialTextBuf.GetRowNumber ***
// Get number of line (Text Row) in Seriral Text Buffer by current position
//
//     Parameters
// AShiftPos - shift to Seriral Text Buffer current position
// Result    - Returns line number
//
function  TK_SerialTextBuf.GetRowNumber ( AShiftPos : Integer = 0  ): Integer;
var CurPos : Integer;
begin
  CurPos := St.cpos + AShiftPos - 1;
  if CurPos <= 0 then CurPos := OfsFreeM; // calc all lines
  Result := K_CalcTextLineNumberFromPos( RowStart, RowSize, St.Text, Min(CurPos, OfsFreeM) );
end; //*** end of procedure TK_SerialTextBuf.GetRowNumber

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\ShowErrorMessage
//*************************************** TK_SerialTextBuf.ShowErrorMessage ***
// Show error message
//
//     Parameters
// AMes - error message text
//
// Is used automaticaly by Self methods while error should be detected
//
procedure TK_SerialTextBuf.ShowErrorMessage( const AMes : string );
begin
  K_ShowMessage( PrepErrorMessage( AMes ) );
end; //*** end of procedure TK_SerialTextBuf.ShowErrorMessage

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\PrepErrorMessage
//*************************************** TK_SerialTextBuf.PrepErrorMessage ***
// Prepare error message adding line number and Text Buffer fragment with error 
// data
//
//     Parameters
// AMes - start error message text
//
function TK_SerialTextBuf.PrepErrorMessage( const AMes : string ) : string;
begin
  Result := ( AMes+' '+IntToStr( GetRowNumber() )+' - '+
                Copy( St.Text, RowStart, Min( RowSize, 150 ) ) );
end; //*** end of procedure TK_SerialTextBuf.PrepErrorMessage

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\ShowProgress
//******************************************* TK_SerialTextBuf.ShowProgress ***
// Update progress info during parsing or adding data process
//
procedure TK_SerialTextBuf.ShowProgress;
begin
  N_PBCaller.Update( St.cpos );
end; //*** end of procedure TK_SerialTextBuf.ShowProgress

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\AddDataFormatInfo
//************************************** TK_SerialTextBuf.AddDataFormatInfo ***
// Add Used Data Types Version Info
//
//     Parameters
// ASkipFormatInfo - if =TRUE then SPL types info is skiped, data format tag 
//                   <DFI> is placed to resulting buffer only (is needed to 
//                   compact resulting serialized data size)
//
// Data Types Version Info is added to serialized data for future control 
// application and serialized data format versions accordance.
//
procedure TK_SerialTextBuf.AddDataFormatInfo( ASkipFormatInfo : Boolean = FALSE );
var
  TypeNames : TStringList;
  i : Integer;
  TypesCount : Integer;
  MFDCurFVer, MFDNDPTVer : Integer;
begin
  if K_txtXMLMode in K_TextModeFlags then Exit;
  TypesCount := SBUsedTypesList.Count;
  TypeNames := TStringList.Create;
  MFDCurFVer := 0;
  MFDNDPTVer := 0;
  for i := 0 to TypesCount - 1 do
    with TK_UDFieldsDescr(SBUsedTypesList[i]) do begin
      MFDCurFVer := Max( FDCurFVer, MFDCurFVer );
      MFDNDPTVer := Max( FDNDPTVer, MFDNDPTVer );
      TypeNames.Add( format( '%s %d %d', [ObjName, FDCurFVer, FDNDPTVer] ) );
    end;

  // Add Data Format Info
  AddTag( K_DataFmtVerTag + ' ' + format( 'CurF=%d NDPT=%d', [MFDCurFVer, MFDNDPTVer] ) );
  AddRowStrings( TypeNames );
  AddTag( K_DataFmtVerTag + ' ' + K_DataFmtVerInfoSign, tgClose );

  TypeNames.Free;

end; //*** end of procedure TK_SerialTextBuf.AddDataFormatInfo

//##path K_Delphi\SF\K_clib\K_STBuf.pas\TK_SerialTextBuf\CheckUsedTypesInfo
//************************************* TK_SerialTextBuf.CheckUsedTypesInfo ***
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
function TK_SerialTextBuf.CheckUsedTypesInfo( var AFmtErrInfo : TStrings ) : Integer;
var
  TypeNames : TStringList;
  i : Integer;
  TypesCount : Integer;
  PCurBufPos : PChar;
  PCurBufPos1 : PChar;
  PCurBufPos0 : PChar;
  CurFD : TK_UDFieldsDescr;
  FmtVerCode : Integer;
  TypeName : string;
  FmtVerErrInfo : string;
  WPos : Integer;
  FmtInfoTag : string;
  ETag : TK_STBufTagType;
  MFDCurFVer, MFDNDPTVer : Integer;
  OneTypeInfo : string;

label LExit;
begin

  Result := 2;
  with ST do begin
    PCurBufPos := @Text[TLength - 1];
    PCurBufPos0 := @Text[1];
  end;

  while (PCurBufPos > PCurBufPos0) and (PCurBufPos^ <> K_TagCloseChar) do Dec(PCurBufPos);
  i := Length(K_DataFmtVerInfoSign);
  Dec(PCurBufPos, i);
  if not CompareMem( @K_DataFmtVerInfoSign[1], PCurBufPos, i * SizeOf(Char) ) then Exit;
  Result := 0;
  //*** Step to Data Format Info tag
  while (PCurBufPos > PCurBufPos0) and (PCurBufPos^ <> K_TagCloseChar) do Dec(PCurBufPos);
  while (PCurBufPos > PCurBufPos0) and (PCurBufPos^ <> K_TagOpenChar) do Dec(PCurBufPos);
  WPos := ST.CPos;  // Save buffer current position
  ST.CPos := PCurBufPos - PCurBufPos0 + 1;
  GetTag( FmtInfoTag, ETag );
  if FmtInfoTag <> K_DataFmtVerTag then
    raise TK_LoadUDDataError.Create( PrepErrorMessage( 'Found "'+FmtInfoTag+'" instead of ' +
                                     K_DataFmtVerTag + ' while loading line ' ) );
  GetTagAttr( 'CurF', MFDCurFVer, K_isInteger );
  if MFDCurFVer = K_SPLDataCurFVer then goto LExit;      // Data Format Version is OK
  if MFDCurFVer < K_SPLDataCurFVer then begin
    if MFDCurFVer >= K_SPLDataPDNTVer then goto LExit; // Data Format Version is OK
    Result := -1; // Format Version is Older
  end else begin
    GetTagAttr( 'NDPT', MFDNDPTVer, K_isInteger );
    if K_SPLDataCurFVer >= MFDNDPTVer then goto LExit; // Data Format Version is OK
    Result := 1   // Format Version is Newer
  end;

//*** Check Data Types Format version
  TypeNames := TStringList.Create;
  GetRowStrings( TypeNames, FmtInfoTag );
  TypesCount := TypeNames.Count;
  if AFmtErrInfo <> nil then AFmtErrInfo.Clear;
  for i := 0 to TypesCount - 1 do begin
  //*** Types Info Loop

    OneTypeInfo := TypeNames[i];
    // Parse type name
    PCurBufPos := @OneTypeInfo[1];
    PCurBufPos1 := @OneTypeInfo[2];
    while (PCurBufPos1^ <> ' ') do Inc(PCurBufPos1);
    PCurBufPos1^ := #0;
    TypeName := PCurBufPos;

    CurFD := K_GetTypeCode( TypeName ).FD;
    FmtVerCode := 2;
    if Integer(CurFD) = -1 then begin
      FmtVerCode := 0;  // Type is absent
      FmtVerErrInfo :=  'Type ' + TypeName + ' is absent in SPL';
    end else begin
      // Parse current format version
      PCurBufPos := PCurBufPos1 + 1;
      PCurBufPos1 := PCurBufPos + 1;
      while (PCurBufPos1^ <> ' ') do Inc(PCurBufPos1);
      PCurBufPos1^ := #0;
      MFDCurFVer := StrToIntDef( PCurBufPos, -1 );

      if MFDCurFVer = -1 then begin
        TypeNames.Free;
        raise TK_LoadUDDataError.Create( 'Type format version error in "'+OneTypeInfo+'"' );
      end;
      if MFDCurFVer < CurFD.FDCurFVer then begin
        if MFDCurFVer < CurFD.FDPDNTVer then begin
          FmtVerCode := -1; // Data Format Version is Older
          FmtVerErrInfo :=  'Type ' + TypeName +
             ' Prev Data CurF=' + IntToStr(MFDCurFVer) +
             ' *** SPL CurF=' + IntToStr(CurFD.FDCurFVer) + ' PDNT=' + IntToStr(CurFD.FDPDNTVer);
        end;
      end else if MFDCurFVer > CurFD.FDCurFVer then begin
        MFDNDPTVer := StrToIntDef( PCurBufPos1 + 1, -1 );
        if MFDNDPTVer = -1 then
          raise TK_LoadUDDataError.Create( 'Type format version error in "'+OneTypeInfo+'"' );
        if CurFD.FDCurFVer < MFDNDPTVer then begin
          FmtVerCode := 1; // Data Format Version is Newer
          FmtVerErrInfo :=  'Type ' + TypeName +
             ' New Data CurF=' + IntToStr(MFDCurFVer) + ' NDPT=' + IntToStr(MFDNDPTVer) +
             ' *** SPL CurF=' + IntToStr(CurFD.FDCurFVer);
        end;
      end;
    end;


    if FmtVerCode <> 2 then begin  // Type Format Version is wrong
      // Fix Type Format Error
      if AFmtErrInfo = nil then
        AFmtErrInfo := TStringList.Create;
      AFmtErrInfo.AddObject( FmtVerErrInfo, TObject(FmtVerCode) );
    end;

  end; // end of Types Info loop

  if (AFmtErrInfo = nil) or (AFmtErrInfo.Count = 0) then
    Result := 0; // Detail analysis is OK
  TypeNames.Free;

LExit:
  ST.CPos := WPos;  // Restore buffer current position

end; //*** end of procedure TK_SerialTextBuf.CheckUsedTypesInfo

end.

