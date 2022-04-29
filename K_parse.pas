unit K_Parse;
// parse string routines and classes
//
// Interface section uses only N_Types and Delphi units
// Implementation section uses K_CLib0 and Delphi units

{ ************* parse string routines and classes

*** TK_Tokenizer class (parse string to tokens class)

*** TK_GridTokenizer class (parsing grid cell tokens in string)

*** TK_NumberConstraints class (check text number representation class)

*** parse/convert routines
function K_parseIntArray( st : TK_Tokenizer; const values : TK_IArray;
        sind : Integer=0; size : Integer=0; default : Integer=0 ) : Integer;
function K_parseStringArray( st : TK_Tokenizer; const values : TK_SArray;
        sind : Integer=0; size : Integer=0 ) : Integer;
function K_parseDoubleArray( st : TK_Tokenizer; const values : TK_DArray;
        sind : Integer=0; size : Integer=0 ) : Integer;
function K_sformat( const fmt: string ) : TK_Tokenizer;
function K_sscanf( const Source, Format: string; const Args: array of Pointer ) : Integer; overload;
function K_sscanf( Source: TK_Tokenizer; const Format: string; const Args: array of Pointer ) : Integer;
function K_sscanf( Source, Format: TK_Tokenizer; const Args: array of Pointer ) : Integer; overload;
function K_numberToString( val : Extended; fmt : string = '%g' ) : String;
function K_NumStringPrep( str : string ) : String;
function K_DateTimeToStr( DateTime: TDateTime ) : string;
function K_StrToDateTime( StrDate: string ) : TDateTime;
}
interface
uses
  SysUtils, Classes, ComCtrls, Math,
  N_Types;

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_TokenizerError
type TK_TokenizerError = class(Exception);

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_TokenType
//************************************************************ TK_TokenType ***
// Type of text added to string buffer by TK_Tokenizer.AddToken
//
type TK_TokenType = ( K_ttToken, K_ttQToken, K_ttString );// string (no 
                                                          // separation needed)
//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer
//************************************************************ TK_Tokenizer ***
// String tokenizer Class
//
// Is used for parsing source strings to separate tokens
//
type TK_Tokenizer = class
    constructor Create( const ASrc : string ); overload;
    constructor Create( const ASrc, ADelimiters : string ); overload;
    constructor Create( const ASrc, ADelimiters, ABrackets : string ); overload;
    function  Clone : TK_Tokenizer;
    procedure ShiftPos( shift : Integer );
    procedure SetSource( const ASrc : string );
    procedure SetDelimiters( const ADelimiters : string; AInd : integer = 0 );
    procedure SetBrackets( const ABrackets : string;
                           AInd : Integer = 0 );
    procedure SetPos( ANewPos : Integer );
    procedure SetNonRecurringDelimsInd( AInd : Integer );
    procedure SetNestedBracketsInd( AInd : Integer );
    function  GetDelimiters(  ) : string;
    function  HasMoreTokens( ASkipNonRecurDelimMode : Boolean = false ) : Boolean;
    function  NextToken( ASkipNonRecurringMode : Boolean = false ): string; overload;
//    function  NextToken( const ADelimiters : string;
//                         ASkipNonRecurringMode : Boolean = false ): string; overload;
    function  CalcTokens(): Integer;
    function  GetDelimiter( AShowBracketsChar : Boolean = true ): Char;
    procedure IncCapacity( ANeededSpace : Integer );
    procedure AddToken( const AToken: string; ATokenType : TK_TokenType = K_ttToken;
                        ATokenDelimiter : Char = #0; AInd : Integer = -1 );
//##/*
  private
    fdelims : string;
    fNonRecurringDelimsInd : integer;
    fbracketsDelimsInd : Integer;

    fbrackets : string;
    fNestedBracketsInd : integer;

    DoubleBracketsMode0 : Boolean;

    // Current Parsing Context
    fbracketsStartFlag : Boolean;
    fNonRecurFind : Boolean;
    fbracketsCloseInd : Integer;

    procedure linkBracketsToDelims;
  protected
    flast : Integer;
    findex : Integer;
//##*/
  public
    Text : string; // parsing string
    property Delimiters : string read GetDelimiters; // string with not paired 
                                                     // token delimiters
    property Brackets : string read fbrackets;       // string with paired token
                                                     // delimiters
    property NonRecurringDelimsInd : Integer read fNonRecurringDelimsInd write SetNonRecurringDelimsInd; // index of first nonrecurring delimiter in delimiters string
                                     // index of first nonrecurring delimiter in
                                     // delimiters string index of first 
                                     // nonrecurring delimiter in delimiters 
                                     // string index of first nonrecurring 
                                     // delimiter in delimiters string index of 
                                     // first nonrecurring delimiter in 
                                     // delimiters string index of first 
                                     // nonrecurring delimiter in delimiters 
                                     // string index of first nonrecurring 
                                     // delimiter in delimiters string index of 
                                     // first nonrecurring delimiter in 
                                     // delimiters string index of first 
                                     // nonrecurring delimiter in delimiters 
                                     // string index of first nonrecurring 
                                     // delimiter in delimiters string index of 
                                     // first nonrecurring delimiter in 
                                     // delimiters string
    property NestedBracketsInd : Integer read fNestedBracketsInd write SetNestedBracketsInd; //
    property CPos : Integer read findex write SetPos; // current parsing string 
                                                      // position
    property TLength : Integer read flast;            // parsing string length
    property isBracketsStartFlag : Boolean read fbracketsStartFlag; // last 
                                                                    // parsed 
                                                                    // delimiter
                                                                    // is 
                                                                    // brackets 
                                                                    // start 
                                                                    // delimiter
    property isNRDelimFindFlag : Boolean read fNonRecurFind write fNonRecurFind ; // last parsed delimiter is nonrecurring delimiter
                                     // last parsed delimiter is nonrecurring 
                                     // delimiter last parsed delimiter is 
                                     // nonrecurring delimiter last parsed 
                                     // delimiter is nonrecurring delimiter last
                                     // parsed delimiter is nonrecurring 
                                     // delimiter last parsed delimiter is 
                                     // nonrecurring delimiter last parsed 
                                     // delimiter is nonrecurring delimiter last
                                     // parsed delimiter is nonrecurring 
                                     // delimiter last parsed delimiter is 
                                     // nonrecurring delimiter last parsed 
                                     // delimiter is nonrecurring delimiter last
                                     // parsed delimiter is nonrecurring 
                                     // delimiter
    property DoubleBrackets : Boolean read DoubleBracketsMode0 write DoubleBracketsMode0; // use paired token delimiters flag
                                     // use paired token delimiters flag use 
                                     // paired token delimiters flag use paired 
                                     // token delimiters flag use paired token 
                                     // delimiters flag use paired token 
                                     // delimiters flag use paired token 
                                     // delimiters flag use paired token 
                                     // delimiters flag use paired token 
                                     // delimiters flag use paired token 
                                     // delimiters flag use paired token 
                                     // delimiters flag
end;
//*****************************  end of TK_Tokenizer class description ***
{
//************************************* TK_GridTokenizer class description ***
// class for parsing grid cell tokens in string
  TK_GridTokenizer = class(TK_Tokenizer)
    constructor Create( const src : string = '';
                        scol : Integer = 0;
                        srow : Integer = 0;
                        mcol : Integer = 1;
                        mrow : Integer = 1 ); overload;
    procedure Init( const src : string; scol, srow, mcol, mrow : Integer );
    procedure setGridSource( const src : string );
    procedure setGrid( scol, srow, mcol, mrow : Integer );
    procedure nextCell();
    function countRows(): Integer;
    function countCols(): Integer;
  private
    tccol : Integer; // Current Column
    tcrow : Integer; // Current Row
    tscol : Integer; // Start Column
    tsrow : Integer; // Start Row
    tmcol : Integer; // Max Column
    tmrow : Integer; // Max Row
  protected
  public
    property column : Integer read tccol;
    property row : Integer read tcrow;
    property rowCount : Integer read countRows;
    property colCount : Integer read countCols;
end;
//*****************************  end of TK_Tokenizer class description ***
}
{
type TK_NumberConstraintsBound = ( ncBoundMin, ncBoundMax );

//************************************* TK_NumberConstraints class description ***
// class for checking text number representation
type TK_NumberConstraints = class
    constructor Create(  ); overload;
    constructor Create( btype : TK_NumberConstraintsBound; bound : Double ); overload;
    constructor Create( min, max : Double ); overload;
    function checkChars( const str : string ) : Boolean;
    function checkValue( const str : string ) : Boolean;
    function checkValueNum( val : Double ) : Boolean;
    procedure setRange( min, max : Double );
    function roundValue( val : Double ) : Double;
  private
    set_precision : Boolean;
    tprecision : Double;
    tmin : Double;
    tmax : Double;
    tvalue : Double;
    wstart : Integer;
    wlength : Integer;
    procedure setPrecision( precision : Integer );
    function getText( ): String;
    procedure setValue( val : Double );
  protected
  public
    property precision : Integer write setPrecision;
    property text : string read getText;
    property value : Double read tvalue write setValue;
    property min : Double read tmin;
    property max : Double read tmax;
    property wrongStart : Integer read wstart;
    property wrongLength : Integer read wlength;
end;
//*****************************  end of TK_NumberConstraints class description ***
}
//************************************* common routines ***
//function  K_SetStringCapacity( var StringBuf : string; NewCapacity : Integer ) : Integer;
//function  K_SetBArrayCapacity( var BArray : TN_BArray; NewSize : Integer ) : Integer;

//************************************* parse routines ***
{
function K_parseIntArray( st : TK_Tokenizer; const values : TN_IArray;
        sind : Integer=0; size : Integer=0; default : Integer=0 ) : Integer;
function K_parseStringArray( st : TK_Tokenizer; const values : TN_SArray;
        sind : Integer=0; size : Integer=0 ) : Integer;
function K_parseDoubleArray( st : TK_Tokenizer; const values : TN_DArray;
        sind : Integer=0; size : Integer=0 ) : Integer;
function K_sformat( const fmt: string ) : TK_Tokenizer;
function K_sscanf( const Source, Format: string; const Args: array of Pointer ) : Integer; overload;
function K_sscanf( Source: TK_Tokenizer; const Format: string; const Args: array of Pointer ) : Integer; overload;
function K_sscanf( Source, Format: TK_Tokenizer; const Args: array of Pointer ) : Integer; overload;
function K_numberToString( val : Extended; fmt : string = '%g'; PointToComma : Boolean = false ) : String;
}
function  K_NumStringPrep( AStr : String; APointToComma : Boolean = false ) : String;
function  K_StrTestChars( const AStr, AChars: string; AStartInd : Integer = 1;
                          AStep : Integer = 1; ABreakIfFound : Boolean = true ) : Integer;
function  K_CalcTextLineNumberFromPos( var ALineStartPos, ALineSize : Integer;
                          const AText : string; ATextCurPos : Integer = 0;
                          AStartSearchPos : Integer = 1 ): Integer;
function  K_IntToRomanStr( AINum : integer ) : string;


const K_TokenRChar : Char = '\';


implementation

uses StrUtils,
  K_CLib0;

//***************************************** TK_Tokenizer class methods ***

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\Create(Source)
//********************************************* TK_Tokenizer.Create(Source) ***
// String tokenizer Class Constructor
//
//     Parameters
// ASrc - parsing string
//
constructor TK_Tokenizer.Create( const ASrc : string );
begin
  Create( ASrc, ' ,', '""' );
end;

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\Create(Source,Delimiters)
//********************************** TK_Tokenizer.Create(Source,Delimiters) ***
// String tokenizer Class Constructor
//
//     Parameters
// ASrc        - parsing string
// ADelimiters - tokens delimiters
//
constructor TK_Tokenizer.Create( const ASrc, ADelimiters : string );
begin
  Create( ASrc, ADelimiters, '""' );
end;

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\Create(Source,Delimiters,Brackets)
//************************* TK_Tokenizer.Create(Source,Delimiters,Brackets) ***
// String tokenizer Class Constructor
//
//     Parameters
// ASrc        - parsing string
// ADelimiters - tokens delimiters
// ABrackets   - paired token delimiters
//
constructor TK_Tokenizer.Create( const ASrc, ADelimiters, ABrackets : string );
begin
  inherited Create;
  DoubleBracketsMode0 := false;
  SetSource( ASrc );
  SetDelimiters( ADelimiters );
  SetBrackets( ABrackets );
end;


//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\Clone
//****************************************************** TK_Tokenizer.Clone ***
// CLone Self
//
//     Parameters
// Result - Returns self copy.
//
// Creates Self copy with same source, delimiters and brackets.
//
function TK_Tokenizer.Clone : TK_Tokenizer;
begin
  Result := TK_Tokenizer.Create( text,
                    Copy(fdelims, 1, fbracketsDelimsInd - 1), fbrackets );
  Result.fNonRecurringDelimsInd := fNonRecurringDelimsInd;
  Result.fNestedBracketsInd := fNestedBracketsInd;
  Result.fBracketsDelimsInd := fBracketsDelimsInd;
end;

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\ShiftPos
//*************************************************** TK_Tokenizer.ShiftPos ***
// shift string source current position returns TK_Tokenizer
//
procedure TK_Tokenizer.ShiftPos( shift : Integer );
begin
  Inc ( findex, shift );
//??  if findex > flast then findex := flast;
  if findex < 1 then findex := 1;
  fNonRecurFind := false;
  if shift <> 0 then
    fbracketsStartFlag := false;
end;

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\SetSource
//************************************************** TK_Tokenizer.SetSource ***
// Set new source string for parsing
//
//     Parameters
// ASrc - new parsing string
//
procedure TK_Tokenizer.SetSource( const ASrc : string );
begin
  text := ASrc;
  findex := 1;
  flast := Length(text);
  fbracketsStartFlag := false;
  fNonRecurFind := false;
//  Result := self;
end;

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\SetDelimiters
//********************************************** TK_Tokenizer.SetDelimiters ***
// Set new delimiters string
//
//     Parameters
// ADelimiters - new delimiters string
// AInd        - index of first nonrecurring delimiter, if =0 then all 
//               delimiters in ADelimiters are recurring
//
procedure TK_Tokenizer.SetDelimiters( const ADelimiters : string; AInd : integer = 0 );
begin
  fdelims := ADelimiters;
  fbracketsDelimsInd := Length( ADelimiters ) + 1;
  if AInd <= 0 then AInd := fbracketsDelimsInd;
  SetNonRecurringDelimsInd( AInd );
  linkBracketsToDelims;
end;

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\SetBrackets
//************************************************ TK_Tokenizer.SetBrackets ***
// Set new brackets string
//
//     Parameters
// ABrackets - new brackets string
// AInd      - index of first delimiter of nestable brackets in ABrackets, if =0
//             then no nestable brackets in ABrackets
//
procedure TK_Tokenizer.SetBrackets( const ABrackets : string;
                                    AInd : Integer = 0 );
begin
  fbrackets := ABrackets;
  fbracketsStartFlag := false;
  fNonRecurFind := false;
  fbracketsCloseInd := 1;
  if AInd <= 0 then
    fNestedBracketsInd := Length(ABrackets)
  else
    fNestedBracketsInd := AInd;

  linkBracketsToDelims;
end;

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\SetPos
//***************************************************** TK_Tokenizer.SetPos ***
// Set string source current position
//
//     Parameters
// ANewPos - new parsing position
//
procedure TK_Tokenizer.SetPos( ANewPos : Integer );
begin
  ShiftPos( ANewPos - findex );
end;

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\SetNonRecurringDelimsInd
//*********************************** TK_Tokenizer.SetNonRecurringDelimsInd ***
// Set nonrecurring delimiters index in Self.Delimiters string
//
//     Parameters
// AInd - index of first nonrecurring delimiter in Self.Delimiters string
//
procedure TK_Tokenizer.SetNonRecurringDelimsInd( AInd : Integer );
begin
  Aind := Max( 0, Aind );
  fNonRecurringDelimsInd := Aind;
  fNonRecurFind := false;
end;

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\SetNestedBracketsInd
//*************************************** TK_Tokenizer.SetNestedBracketsInd ***
// Set nestable delimiters index in Self.Brackets string
//
//     Parameters
// AInd - index of first delimiter of nestable brackets in Self.Brackets string
//
procedure TK_Tokenizer.SetNestedBracketsInd( AInd : Integer );
begin
  Aind := Max( 1, Aind );
  fNestedBracketsInd := Aind;
end;

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\GetDelimiters
//********************************************** TK_Tokenizer.GetDelimiters ***
// Get current delimiters string
//
//     Parameters
// Result - Returns string with current delimiters
//
function TK_Tokenizer.GetDelimiters(  ) : string;
begin
  Result := Copy( fdelims, 1, fbracketsDelimsInd - 1 );
end;

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\HasMoreTokens
//********************************************** TK_Tokenizer.HasMoreTokens ***
// Check if some tokens are remained in the source string
//
//     Parameters
// ASkipNonRecurDelimMode - if =TRUE then try to search next token position even
//                          if last parsed delimiter was nonrecurring
// Result                 - Returns TRUE if next token is found
//
// Shifts source string current position to next token start position.
//
function TK_Tokenizer.HasMoreTokens( ASkipNonRecurDelimMode : Boolean = false ) : Boolean;
var
  DInd : Integer;
label End_search;

begin

  Result := false;
  if ASkipNonRecurDelimMode then fNonRecurFind := false;
  if fbracketsStartFlag or fNonRecurFind then goto End_search;

  //***** step to token start position
  while ( findex <= flast ) do
  begin
    DInd := Pos( text[findex], fdelims );
    if DInd = 0 then goto End_Search;
    Inc(findex);
    if DInd >= fbracketsDelimsInd then
    begin
      fbracketsCloseInd := (DInd - fbracketsDelimsInd + 1) * 2;
      fbracketsStartFlag := true;
      goto End_Search;
    end;
    if DInd >= fNonRecurringDelimsInd then
    begin
      fNonRecurFind := true;
      goto End_Search;
    end;
  end;
  Exit;

End_search:
  if findex <= flast then Result := true;

end;

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\NextToken
//************************************************** TK_Tokenizer.NextToken ***
// Get new token from the source string
//
//     Parameters
// ASkipNonRecurDelimMode - if =TRUE then try to search next token position even
//                          if last parsed delimiter was nonrecurring
// Result                 - Returns parsed token or empty string if next token 
//                          was not found
//
// Shifts source string current position to next char after parsed token
//
function TK_Tokenizer.NextToken( ASkipNonRecurringMode : Boolean = false ): string;
var
  tstart : Integer;
  AddPos, NewLeng, DInd : Integer;
  NestedBrackets, UseBracketsDelim : Boolean;
  NestedBracketsCount : Integer;
  PText : PChar;
  OpenChar, CloseChar : Char;

  procedure MoveParsedChars;
  begin
    AddPos := Length(Result);
    SetLength(Result, AddPos+NewLeng);
    Move(Text[tstart], Result[AddPos+1], NewLeng * SizeOf(Char));
  end;

begin

  Result := '';
  //***** check if  next token exists
  if not HasMoreTokens(ASkipNonRecurringMode) then  Exit;

  //***** search token last position
  tstart := findex;
  fNonRecurFind := false;
  NestedBracketsCount := 0;
  NestedBrackets := (fbracketsCloseInd  > fNestedBracketsInd);
  UseBracketsDelim := fbracketsStartFlag;
  fbracketsStartFlag := false;
  OpenChar := #0;
  CloseChar := #0;
  if UseBracketsDelim then
  begin
    if NestedBrackets then
      OpenChar := fbrackets[fbracketsCloseInd-1];
    CloseChar := fbrackets[fbracketsCloseInd];
  end;

  PText := @text[findex];
  while (findex <= flast) do
  begin
    if UseBracketsDelim then
    begin
      if NestedBrackets and (PText^ = OpenChar) then
        Inc(NestedBracketsCount);

      if PText^ = CloseChar then
      begin
        Dec(NestedBracketsCount);
        if NestedBracketsCount < 0 then
        begin //*** parse brackets close char
          if (PText - 1)^ = K_TokenRChar then
          begin
            NewLeng := findex - tstart;
            if (NewLeng > 1) and
               ((PText - 2)^ = K_TokenRChar) then
              Dec(NewLeng);
            MoveParsedChars;
            tstart := findex + 1;
            if (NewLeng > 0) and
               ((PText - 2)^ = K_TokenRChar) then break;
            Result[Length(Result)] := CloseChar;
          end
          else
          if DoubleBracketsMode0 and
             ((PText + 1)^ = CloseChar) then
          begin
            NewLeng := findex - tstart + 1;
            MoveParsedChars;
            Inc(findex);
            Inc(PText);
            tstart := findex + 1;
          end
          else
            break;
        end; // if NestedBracketsCount < 0 then
      end; // if PText^ = CloseChar then
    end  // if UseBracketsDelim then
    else
    begin // if not UseBracketsDelim then
      DInd := Pos( PText^, fdelims );
      if DInd <> 0 then
      begin
        if DInd >= fbracketsDelimsInd then
          fbracketsStartFlag := true
        else
        if DInd >= fNonRecurringDelimsInd then
          fNonRecurFind := true;
        break;
      end; // if DInd <> 0 then
    end; // if not UseBracketsDelim then
    Inc(findex);
    Inc(PText);
  end; //*** end of while loop
  NewLeng := findex - tstart;
  if NewLeng > 0 then MoveParsedChars;
  Inc(findex); // shift start position to next char
end; //*** end of procedure TK_Tokenizer.NextToken

{
//********************************************** TK_Tokenizer.NextToken ***
// get next token from tokenized string
//
function TK_Tokenizer.NextToken( const ADelimiters : string;
                                 ASkipNonRecurringMode : Boolean = false ): string;
begin
  self.fdelims := ADelimiters;
  Result := self.NextToken( ASkipNonRecurringMode );
end; //*** end of procedure TK_Tokenizer.NextToken
}

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\CalcTokens
//************************************************* TK_Tokenizer.CalcTokens ***
// Ñalculate number of tokens in not parsed source string tail
//
//     Parameters
// Result - Returns number of tokens
//
// Source string current position stays the same.
//
function TK_Tokenizer.CalcTokens(): Integer;
var ipos : Integer;
begin
  ipos := findex;
  Result := 0;
  while NextToken() <> '' do Inc( Result );
  findex := ipos;
end; //*** end of procedure TK_Tokenizer.CalcTokens

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\GetDelimiter
//*********************************************** TK_Tokenizer.GetDelimiter ***
// Get last parsed token delimiter
//
//     Parameters
// AShowBracketsChar - if =TRUE then token start bracket char will be get
// Result            - Returns number of tokens
//
// Must be called just after Self.HasMoreTokens (just before parsing next token)
//
function  TK_Tokenizer.GetDelimiter( AShowBracketsChar : Boolean = true ): Char;
var ipos : Integer;
begin
  ipos := findex - 1;
  if fbracketsStartFlag and not AShowBracketsChar then Dec(ipos);
  if (ipos < 1) or (ipos > flast) then
    Result := #0
  else
    Result := text[ipos];
end; //*** end of procedure TK_Tokenizer.GetDelimiter

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\IncCapacity
//************************************************ TK_Tokenizer.IncCapacity ***
// Add current string capacity
//
//     Parameters
// ANeededSpace - number of free space (in chars) needed to tokens addition
//
// Is used in build resulting string from tokens mode.
//
procedure TK_Tokenizer.IncCapacity( ANeededSpace : Integer );
begin
  flast := K_SetStringCapacity( text, findex + ANeededSpace );
end;

//##path K_Delphi\SF\K_clib\K_parse.pas\TK_Tokenizer\AddToken
//*************************************************** TK_Tokenizer.AddToken ***
// Add new token to resulting string
//
//     Parameters
// AToken          - adding token
// ATokenType      - type of text added to string buffer (TK_TokenType)
// ATokenDelimiter - delimiter char adding after token, if =#0 then 
//                   Self.Delimiters[1] is used.
// AInd            - index of last brackets char in Self.Brackets field
//
// if AInd = -1 then proper brackets chars will be automatically selected in 
// Self.Brackets
//
// Is used in build resulting string from tokens mode.
//
procedure TK_Tokenizer.AddToken( const AToken: string; ATokenType : TK_TokenType = K_ttToken;
                                 ATokenDelimiter : Char = #0; AInd : Integer = -1 );
var
  brackInd, Leng, WLeng : Integer;
  closeBrackets : boolean;
  spos, ppos, pflag : PChar;
  IsString : Boolean;
begin

  closeBrackets := false;
  IsString := ATokenType = K_ttString;
  if not IsString then
  begin
    IsString := true;
    if    //*** Quoted Token
      (ATokenType = K_ttQToken) or
          //*** string is empty
      (Length(AToken) = 0)      or
          //*** string starts with token open brackets char
      (( Pos( AToken[1], fbrackets ) and 1 ) <> 0) or
          //*** string contains token delimiters
      (K_StrTestChars( AToken, fdelims ) <= Length(fdelims)) then
    begin
      if Length(fbrackets) = 0 then
        raise TK_TokenizerError.Create( 'Brackets are absent' );
      if TLength < CPos + 1 then
        IncCapacity( 1 );
      brackInd := findex; // reserve space for open bracket
      Inc(findex);
      if AInd = -1 then
        AInd := K_StrTestChars( AToken, fbrackets, 2, 2, false );
      if AInd > Length(fbrackets) then
      begin
  //*** no proper brakets use register char
        IsString := false;
        spos := PChar(AToken);
        AInd := 2;
        repeat
          ppos := StrScan( spos, fbrackets[AInd] );
          pflag := ppos;
          if ppos = nil then
            ppos := PChar(AToken) + Length(AToken);
          Leng := ppos - spos;
          WLeng := Leng + 3;
          if TLength < CPos + WLeng then
            IncCapacity( WLeng );
          Move( spos[0], text[findex], Leng * SizeOf(Char) );
          Inc(findex, Leng );
          if pflag = nil then break;
        // put register char for hiding next char
          text[findex] := K_TokenRChar;
          Inc(findex);
        // put hiding char
          text[findex] := ppos[0];
          Inc(findex);
          spos := ppos + 1;
        until false;
      end // if AInd > Length(fbrackets) then
      else
      if AInd < 2 then
        AInd := 2;

  //*** put start selected brackets char
      closeBrackets := true;
      text[brackInd] := fbrackets[AInd-1];
    end;
  end // if not IsString then
  else
    AInd := 2;

  if IsString then
  begin // put hall str
    Leng := Length(AToken);
    if TLength < CPos + Leng then
      IncCapacity( Leng );
    if Leng > 0 then
    begin
      Move( AToken[1], text[findex], Leng  * SizeOf(Char) );
      Inc(findex, Leng );
    end;
  end;

  if closeBrackets then
  begin
    if text[findex-1] = K_TokenRChar then
    begin
      if TLength < CPos + 1 then
        IncCapacity( 1 );
      text[findex] := K_TokenRChar;
      Inc(findex);
    end;
    if TLength < CPos + 1 then
      IncCapacity( 1 );
    text[findex] := fbrackets[AInd];
    Inc(findex);
  end;

  if TLength < CPos + 1 then
    IncCapacity( 1 );

  if ATokenDelimiter = #0 then
    ATokenDelimiter := fdelims[1];

  text[findex] := ATokenDelimiter;
  Inc(findex);

end; //*** end of procedure TK_Tokenizer.AddToken

//******************************************** TK_Tokenizer.linkBrackets ***
//  set new brackets string to existing TK_Tokenizer
//  returns TK_Tokenizer
procedure TK_Tokenizer.linkBracketsToDelims;
var
  i, h, j, k : Integer;
begin
  h := Length(fbrackets) shr 1;
  fdelims := Copy( fdelims, 0, fbracketsDelimsInd - 1 );
  if h = 0 then Exit;
  SetLength( fdelims, Length(fdelims) + h );
  j := fbracketsDelimsInd;
  k := 1;
  for i := 1 to h do begin
    fdelims[j] := fbrackets[k];
    Inc(k, 2);
    Inc(j);
  end;
end;

//********************************** end of TK_Tokenizer class methods ***
{
//***************************************** TK_GridTokenizer class methods ***
//************************************************ TK_GridTokenizer.Create ***
//
constructor TK_GridTokenizer.Create( const src : string = '';
                                        scol : Integer = 0;
                                        srow : Integer = 0;
                                        mcol : Integer = 1;
                                        mrow : Integer = 1 );
begin
  Create( src, #$A#9#$D );
  SetNonRecurringDelimsInd( 2 );
  Init( src, scol, srow, mcol, mrow );
end;

//************************************************ TK_GridTokenizer.Init ***
//
procedure TK_GridTokenizer.Init( const src : string; scol, srow, mcol, mrow : Integer );
begin
  setGridSource( src );
  setGrid( scol, srow, mcol, mrow );
end;

//********************************************** TK_GridTokenizer.setGridSource ***
//  set new string source to existing TK_Tokenizer
//  returns TK_Tokenizer
procedure TK_GridTokenizer.setGridSource( const src : string );
begin
  SetSource( PChar(src) );
  if (findex <= flast) and (Text[findex] = #$9) then
    fNonRecurFind := true;
  tccol := tscol;
  tcrow := tsrow;
end;

//************************************************ TK_GridTokenizer.setGrid ***
//
procedure TK_GridTokenizer.setGrid( scol, srow, mcol, mrow : Integer );
begin
  tscol := scol;
  tsrow := srow;
  tmcol := mcol;
  tmrow := mrow;
  tccol := tscol;
  tcrow := tsrow;
end;

//************************************************ TK_GridTokenizer.nextCell ***
//
procedure TK_GridTokenizer.nextCell(  );
Label New_row;
begin
  if (findex <= flast) and (Text[findex - 1] = #$9) then begin
   Inc(tccol);
   if tccol >= tmcol then begin //*** switch to end of row
//??     findex := strScan( Text + findex, #$D ) - Text + 1;
     findex := StrScan( PChar(Text) + findex - 1, #$D ) - PChar(Text) + 2;
     if findex < 1 then findex := flast + 1;
     HasMoreTokens();
     goto New_row;
   end;
  end else begin
New_row:
   Inc(tcrow);
   tccol := tscol;
   if tcrow >= tmrow then //*** stop parsing flag
     findex := flast + 1;
  end;
end;

//************************************************ TK_GridTokenizer.countRows ***
//
function TK_GridTokenizer.countRows( ) : Integer;
var
  wInd, wpInd : Integer;
begin
  wInd := 0;
  Result := -1;
//  eInd := PosEx( Chr($0D), Text, 1);
  repeat
    wpInd := wInd + 1;
    wInd := PosEx( Chr($0D), Text, wpInd );
    Inc(Result);
  until (wInd = 0);
  if (Length(Text) > 1) and
     ( (Length(Text) < wpInd) or (wpInd = 1) ) then Inc(Result);
end;

//************************************************ TK_GridTokenizer.countCols ***
//
function TK_GridTokenizer.countCols( ) : Integer;
var
  eInd, wInd, wpInd : Integer;
begin
  wInd := 0;
  Result := -1;
  eInd := PosEx( Chr($0D), Text, 1);
  repeat
    wpInd := wInd + 1;
    wInd := PosEx( #$9, Text, wpInd );
    Inc(Result);
  until (wInd = 0) or (wInd >= eInd);
  if (Length(Text) > 1) and
     ( (Length(Text) < wpInd) or (wpInd = 1) ) then Inc(Result);
end;

//********************************** end of TK_GridTokenizer class methods ***
}

{
//***************************************** TK_NumberConstraints class methods ***

//************************************************ TK_NumberConstraints.Create ***
//
constructor TK_NumberConstraints.Create(  );
begin
  self.Create( -MaxDouble, MaxDouble );
end;

//************************************************ TK_NumberConstraints.Create ***
//
constructor TK_NumberConstraints.Create( btype : TK_NumberConstraintsBound; bound : Double );
var
min, max : Double;
begin
  min := -MaxDouble;
  max := MaxDouble;
  case btype of
    ncBoundMin: // min bound
      min := bound;
    ncBoundMax: // max bound
      max := bound;
  end;
  self.Create( min, max );
end;

//************************************************ TK_NumberConstraints.Create ***
//
constructor TK_NumberConstraints.Create( min, max : Double );
begin
  set_precision := false;
  tprecision := 0;
  tmin := min;
  tmax := max;
end;

//********************************************** TK_NumberConstraints.checkChars ***
// check number chars in the string
//   returns true if chars are correct
function TK_NumberConstraints.checkChars( const str : string ) : Boolean;
var
code : Integer;
begin
  Result := false;
  wlength := Length(str);
  wstart := 0;
  if (wlength = 1) and ((str[1] = '-') or (str[1] = '+')) then
   Result := true
  else if wlength > 0 then
  begin
    Result := true;
    Val( str, tvalue, code );
    if (str[1] = 'E')  or (str[1] = 'e') then  code := 1;
    if code <> 0 then
    begin //*** string contains non numeric character
      wstart := code-1;
      Result := false;
   end;
  end;
end;

//********************************************** TK_NumberConstraints.roundValue ***
// round value of number and build correct text number representation
function TK_NumberConstraints.roundValue( val : Double ) : Double;
begin
  Result := val;
  if Self = nil then Exit;
  tvalue := val;
  if set_precision then
    tvalue := Round( val * tprecision ) / tprecision;
  Result := tvalue;
end;

//********************************************** TK_NumberConstraints.setValue ***
// check value of number and build correct text number representation
procedure TK_NumberConstraints.setValue( val : Double );
begin
  checkValueNum( val );
end;

//********************************************** TK_NumberConstraints.checkValue ***
// check value of number and build correct text number representation
//   returns true if value is correct (lies in specified section)
function TK_NumberConstraints.checkValue( const str : string ) : Boolean;
begin
  Result := false;
  if checkChars(str) then
    Result := checkValueNum( tvalue );
end;

//********************************************** TK_NumberConstraints.checkValueNum ***
// check value of number and build correct text number representation
//   returns true if value is correct (lies in specified section)
function TK_NumberConstraints.checkValueNum( val : Double ) : Boolean;
var
str : string;

begin
  Result := true;
  roundValue( val );
  if (tvalue < tmin) or (tvalue >= tmax) then
  begin
    str := getText();
    wstart := 0;
    wlength := Length(str);
    Result := false;
  end;
end;

//********************************************** TK_NumberConstraints.getText ***
// returns new number text representation
function TK_NumberConstraints.getText(  ) : string;
begin
  Result := K_numberToString( tvalue );
end;

//********************************************** TK_NumberConstraints.setPrecision ***
// set number precision
procedure TK_NumberConstraints.setPrecision( precision : Integer );
begin
  if Self = nil then Exit;
  if precision < 100 then
  begin
    tprecision := IntPower( 10.0, precision );
    set_precision := true;
  end else
    set_precision := false;
end;

//********************************************** TK_NumberConstraints.setRange ***
// set new number range
procedure TK_NumberConstraints.setRange( min, max : Double );
begin
  if Self = nil then Exit;
  tmin := min;
  tmax := max;
end;

//********************************** end of TK_NumberConstraints class methods ***
}
//*************************************************** parse routines ***
{
//**************************************************** K_parseIntArray ***
// parse array of integer values from string
//   returns number of parsed array components
function K_parseIntArray( st : TK_Tokenizer; const values : TN_IArray;
        sind : Integer=0; size : Integer=0; default : Integer=0 ) : Integer;
var ind, num : Integer;
begin
  ind := sind;
  num := Length(values) - ind;
  if size <= 0 then size := num;
  size := Min( size, num );
  num := 0;
  while (st.HasMoreTokens()) and (num < size) do
  begin
    values[ind] := StrToIntDef( st.NextToken, default );
    Inc(ind);
    Inc(num);
  end;
  Result := num;
end;

//**************************************************** K_parseStringArray ***
// parse array of integer values from string
//   returns number of parsed array components
function K_parseStringArray( st : TK_Tokenizer; const values : TN_SArray;
        sind : Integer=0; size : Integer=0 ) : Integer;
var ind, num : Integer;
begin
  ind := sind;
  num := Length(values) - ind;
  if size <= 0 then size := num;
  size := Min( size, num );
  num := 0;
  while (st.HasMoreTokens()) and (num < size) do
  begin
    values[ind] := st.NextToken;
    Inc(ind);
    Inc(num);
  end;
  Result := num;
end;

//************************************************** K_parseDoubleArray ***
// parse array of float from string
//   returns number of parsed array components
function K_parseDoubleArray( st : TK_Tokenizer; const values : TN_DArray;
                  sind : Integer=0; size : Integer=0 ) : Integer;
var num, ind, control : Integer;
begin
  ind := sind;
  num := Length(values) - ind;
  if size <= 0 then size := num;
  size := Min( size, num );
  num := 0;
  while (st.HasMoreTokens()) and (num < size) do
  begin
    Val( st.NextToken, values[ind], control );
    Inc(ind);
    Inc(num);
  end;
  Result := num;
end;


//********************************************************* K_sformat ***
// make format tokenizer
//  returns created TK_Tokenizer
function K_sformat( const fmt: string ) : TK_Tokenizer;
begin
Result := TK_Tokenizer.Create( PChar(fmt), ' %' );
end;

//********************************************************** K_sscanf ***
// sscanf values from source string using string with format
//   returns number of parsed arguments
function K_sscanf(const Source, Format: string; const Args: array of Pointer ) : Integer;
var tsource, tformat : TK_Tokenizer;
begin
tsource := TK_Tokenizer.Create( PChar(Source) );
tformat := K_sformat( Format );
Result := K_sscanf( tsource, tformat, Args );
tsource.free;
tformat.free;
end;

//********************************************************** K_sscanf ***
// sscanf values from tokenized source using string with format
//   returns number of parsed arguments
function K_sscanf(Source: TK_Tokenizer; const Format: string; const Args: array of Pointer ) : Integer;
var tformat : TK_Tokenizer;
begin
tformat := K_sformat( Format );
Result := K_sscanf( Source, tformat, Args );
tformat.free;
end;

//********************************************************** K_sscanf ***
// sscanf values from tokenized source using tokenized format
//   returns number of parsed arguments
function K_sscanf( Source, Format: TK_Tokenizer; const Args: array of Pointer ) : Integer;

// format string specification:
// ... [Qualifier][Number]%Type ...
// Type is single letter identifier:
// b - byte	unsigned  8-bit unsigned data item
// s - small	signed	  8-bit signed integer
// d - short	signed	 16-bit signed integer
// w - word	unsigned 16-bit unsigned integer
// D - long	signed	 32-bit signed integer
// W - dword	unsigned 32-bit unsigned integer
// H - hyper	signed	 64-bit signed integer
// f - float	-	 32-bit floating-point number
// F - double	-	 64-bit floating-point number
// E - extended    -        80-bit floating-point number
// l - boolean	unsigned  8-bit data item
// c - char        unsigned  8-bit unsigned data item
// t - text string
// T - date/time   -        64-bit floating-point number
// * - skip token

type
adrShort = ^Shortint;
adrByte = ^Byte;
adrSmall = ^Smallint;
adrWord = ^Word;
adrInt = ^Integer;
adrCardinal = ^Cardinal;
adrInt64 = ^Int64;
adrSingle = ^Single;
adrDouble = ^Double;
adrExtended = ^Extended;
adrString = ^string;
adrChar = ^Char;
adrBoolean = ^Boolean;
adrDateTime = ^TDateTime;
var stoken, ftokenr, ftoken : string;
rep, rCode : Integer;
argNum : Integer;
intBuffer : Longint;
floatBuffer : Extended;
begin
  argNum := 0;
  while Source.HasMoreTokens() and Format.HasMoreTokens() do
  begin
    ftokenr := Format.NextToken();
    ftoken := ftokenr;
    rep := 1;
    if ( ftoken[1] <= '9' ) and (ftoken[1] >= '0')
    then
    begin
      rep := StrToInt( ftokenr );
      ftoken := Format.NextToken();
    end;
    while rep > 0 do
    begin
      if ftoken[1] = 'c' then
      begin
        adrChar(Args[argNum])^ := Source.Text[Source.cpos];
        Source.ShiftPos( 1 );
      end
      else
      begin
        stoken := Source.NextToken();
        case ftoken[1] of
          'b', 's', 'd', 'w', 'D', 'W': // integer
          begin
            intBuffer := StrToInt( stoken );
            case ftoken[1] of
              'b': // byte
                adrByte(Args[argNum])^ := Byte(intBuffer);
              's': // short
                adrShort(Args[argNum])^ := Shortint(intBuffer);
              'd': // smallint
                adrSmall(Args[argNum])^ := Smallint(intBuffer);
              'w': // word
                adrWord(Args[argNum])^ := Word(intBuffer);
              'D': // integer
                adrInt(Args[argNum])^ := intBuffer;
              'W': // cardinal
                adrCardinal(Args[argNum])^ := Cardinal(intBuffer);
            end;
          end;
          'H': // integer 64 bit
          begin
            adrInt64(Args[argNum])^ := StrToInt64( stoken );
          end;
          'f', 'F', 'E': // float
          begin
  //          floatBuffer := StrToFloat( stoken );
            Val( stoken, floatBuffer, rCode );
            if rcode = 0 then
              case ftoken[1] of
                'f': // single
                  adrSingle(Args[argNum])^ := floatBuffer;
                'F': // double
                  adrDouble(Args[argNum])^ := floatBuffer;
                'E': // extended
                  adrExtended(Args[argNum])^ := floatBuffer;
              end;
          end;
          't': // text string
            adrString(Args[argNum])^ := stoken;
          'l': // boolean (logic)
          begin
            if (stoken[1] = 't') or (stoken[1] = 'T')
            then adrBoolean(Args[argNum])^ := true
            else adrBoolean(Args[argNum])^ := false;
          end;
          'T': // DateTime
            adrDateTime(Args[argNum])^ := StrToDateTime( stoken );
          '*':; // skip data in input stream
        end;
      end;
      Dec(rep);
      Inc(argNum);
    end;
  end;
  Result := argNum;
end;

//********************************************************** K_numberToString ***
// convert number to string with changing ',' -> '.'
//   returns number string representation
function K_numberToString( val : Extended; fmt : string = '%g'; PointToComma : Boolean = false ) : String;
begin
  Result := K_NumStringPrep( Format(fmt,[val]), PointToComma );
end;
}

//##path K_Delphi\SF\K_clib\K_parse.pas\K_NumStringPrep
//********************************************************* K_NumStringPrep ***
// Prepare string for number parsing by replacing decimal point char
//
//     Parameters
// AStr          - source string
// APointToComma - if =TRUE then point will be replaced by comma, else comma 
//                 will be replaced by point
// Result        - Returns prepared string
//
function K_NumStringPrep( AStr : String; APointToComma : Boolean = false  ) : String;
var
tlength : Integer;
i : Integer;
C1, C2 : Char;
begin
  C1 := ',';
  C2 := '.';
  if APointToComma then begin
    C1 := '.';
    C2 := ',';
  end;
  tlength := Length( AStr );
  for i := 1 to tlength do
    if (AStr[i] = C1)     and
       (AStr[i+1] >= '0') and
       (AStr[i+1] <= '9') then AStr[i] := C2;
  Result := AStr;
end;

//##path K_Delphi\SF\K_clib\K_parse.pas\K_StrTestChars
//********************************************************** K_StrTestChars ***
// Test if given chars are existed in given string
//
//     Parameters
// AStr          - scanned string
// AChars        - testing chars string
// AStartInd     - chars string start index
// AStep         - chars string index step
// ABreakIfFound - if =TRUE then resulting value is index of first char existing
//                 in AStr, else index of first char not existing in AStr
// Result        - Returns found index of proper char in AChars
//
function K_StrTestChars( const AStr, AChars: string; AStartInd : Integer = 1;
                          AStep : Integer = 1; ABreakIfFound : Boolean = true ) : Integer;
var
Leng : Integer;
begin

  Leng := Length( AChars );
  Result := AStartInd;
  while Result <= Leng do
  begin
    if (Pos( AChars[Result], AStr ) = 0) xor ABreakIfFound then break;
    Inc(Result, AStep );
  end;
end; //*** end of procedure K_StrTestChars

//##path K_Delphi\SF\K_clib\K_parse.pas\K_CalcTextLineNumberFromPos
//********************************************* K_CalcTextLineNumberFromPos ***
// Search line number, position and length by char position in multiline text
//
//     Parameters
// ALineStartPos   - found line start position in AText
// ALineSize       - found line size
// AText           - multiline text
// ATextCurPos     - text current position (if <= 0, then text current is shift 
//                   from AText end)
// AStartSearchPos - start search position (usually =1)
// Result          - Returns found line number
//
function  K_CalcTextLineNumberFromPos( var ALineStartPos, ALineSize : Integer;
                          const AText : string; ATextCurPos : Integer = 0;
                          AStartSearchPos : Integer = 1 ): Integer;
var
  cind, wcind : Integer;
begin
//*** correct search position
  if AStartSearchPos < 1 then AStartSearchPos := 1;
  if ATextCurPos <= 0 then ATextCurPos := Length( AText ) - ATextCurPos;
  if ATextCurPos <= 0 then ATextCurPos := 1;
  wcind := AStartSearchPos;
//*** search start Current Line Pos
  while wcind > 1 do begin
    if AText[wcind] = Chr($0D) then break;
    Dec(wcind);
  end;
  if wcind > 1 then Inc(wcind);
  cind := PosEx( Chr($0D), AText, AStartSearchPos);
  Result := 1;
  while (cind < ATextCurPos) and (cind > 0) do begin
    wcind := cind + 1;
    cind := PosEx( Chr($0D), AText, wcind);
    Inc(Result);
  end;

  if cind = 0 then cind := ATextCurPos;

  ALineStartPos := wcind;
  ALineSize := cind - wcind + 1;

end; //*** end of function K_CalcTextLineNumberFromPos

//##path K_Delphi\SF\K_clib\K_parse.pas\K_IntToRomanStr
//********************************************************* K_IntToRomanStr ***
// Convert Integer Value to Roman Figures
//
//     Parameters
// AINum  - given Value to convert
// Result - Value converted to Roman Figures
//
function  K_IntToRomanStr( AINum : integer ) : string;

  function GetDigStr( AGig : Integer; C1,C2,C3 : char ) : string;
  begin
    Result := '';
    case AGig of
    1: Result := C1;
    2: Result := C1 + C1;
    3: Result := C1 + C1 + C1;
    4: Result := C1 + C2;
    5: Result := C2;
    6: Result := C2 + C1;
    7: Result := C2 + C1 + C1;
    8: Result := C2 + C1 + C1 + C1;
    9: Result := C1 + C3;
    end;
  end;

begin
  Result := GetDigStr( AINum mod 10, 'I', 'V', 'X' );
  AINum := AINum div 10;
  if AINum = 0 then Exit;
  Result := Result + GetDigStr( AINum mod 10, 'X', 'L', 'C' );
  AINum := AINum div 10;
  if AINum = 0 then Exit;
  Result := Result + GetDigStr( AINum mod 10, 'C', 'D', 'M' );
  AINum := AINum div 10;
  if AINum = 0 then Exit;
  Result := Result + GetDigStr( AINum mod 10, 'M', '?', '!' );
end; //*** end of function K_IntToRomanStr
end.
