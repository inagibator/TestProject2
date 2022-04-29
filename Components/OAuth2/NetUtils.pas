unit NetUtils;

{$T-}

interface

uses
  System.Classes, System.Generics.Defaults, System.Generics.Collections, System.SysUtils, System.Types,
  System.NetEncoding, System.NetConsts;

type
  /// <summary>Generic Exception class for System.Net exceptions</summary>
  ENetException = class(Exception);
  /// <summary>Exception class for Credentials related exceptions.</summary>
  ENetCredentialException = class(ENetException);
  /// <summary>Exception class for URI related exceptions.</summary>
  ENetURIException = class(ENetException);
  /// <summary>Exception class for URI related exceptions.</summary>
  ENetURIClientException = class(ENetException);
  /// <summary>Exception class for URI related exceptions.</summary>
  ENetURIRequestException = class(ENetException);
  /// <summary>Exception class for URI related exceptions.</summary>
  ENetURIResponseException = class(ENetException);

  TNameValuePair = record
    /// <summary>Name part of a Name-Value pair</summary>
    Name: string;
    /// <summary>Value part of a Name-Value pair</summary>
    Value: string;
    /// <summary>Initializes a Name-Value pair</summary>
    constructor Create(const AName, AValue: string);
  end;

  TNameValueArray = TArray<TNameValuePair>;
  //TNameValueArray = array of TNameValuePair;

  /// <summary>Alias for a URI Parameter</summary>
  TURIParameter = TNameValuePair;

  /// <summary> Array of URI Parameters. </summary>
  TURIParameters = TNameValueArray;

  TURI = record
  private
    FScheme: string;
    FUsername: string;
    FPassword: string;
    FHost: string;
    FPort: Integer;
    FPath: string;
    FQuery: string;
    FParams: TURIParameters;
    FFragment: string;
  private type
    TEncType = (URLEnc, FormEnc);
  private
    procedure ParseParams(Encode: Boolean = False);
    function FindParameterIndex(const AName: string): Integer;
    function GetParameter(const I: Integer): TURIParameter;
    function GetParameterByName(const AName: string): string;
    procedure SetParameter(const I: Integer; const Value: TURIParameter);
    procedure SetParameterByName(const AName: string; const Value: string);


    /// <summary>Decompose a string into its parts</summary>
    procedure DecomposeURI(const AURIStr: string);
    procedure SetUserName(const Value: string);
    procedure SetPassword(const Value: string);
    procedure SetHost(const Value: string);
    procedure SetPath(const Value: string);
    procedure SetQuery(const Value: string);
    procedure SetParams(const Value: TURIParameters);

  public
    /// <summary>Initializes a TURI from a string</summary>
    constructor Create(const AURIStr: string);

    /// <summary>Generate a urlencoded string from the URI parts</summary>
    /// <returns>A string representing the URI</returns>
    function ToString: string;
    /// <summary>Generate a URI from the string parts</summary>
    procedure ComposeURI(const AScheme, AUsername, APassword, AHostname: string; APort: Integer; const APath: string;
      const AParams: TURIParameters; const AFragment: string);
    /// <summary>Adds a Parameter to the URI</summary>
    procedure AddParameter(const AName, AValue: string); overload;
    procedure AddParameter(const AParameter: TURIParameter); overload; inline;
    /// <summary>Removes a Parameter from the URI</summary>
    procedure DeleteParameter(AIndex: Integer); overload;
    procedure DeleteParameter(const AName: string); overload;

    /// <summary>URL percent encoding of a text.</summary>
    /// <param name="AValue">The text to be encoded.</param>
    /// <param name="SpacesAsPlus">If true the spaces are translated as '+' instead %20.</param>
    class function URLEncode(const AValue: string; SpacesAsPlus: Boolean = False): string; static; deprecated 'Use TNetEncoding.URL.Encode';
    /// <summary>URL percent decoding of a text.</summary>
    /// <param name="AValue">The text to be decoded.</param>
    /// <param name="PlusAsSpaces">If true the character '+' is translated as space.</param>
    class function URLDecode(const AValue: string; PlusAsSpaces: Boolean = False): string; static; deprecated 'Use TNetEncoding.URL.URLDecode';

    /// <summary>Converts a Unicode hostname into it's ASCII equivalent using IDNA</summary>
    class function UnicodeToIDNA(const AHostName: string): string; static;
    /// <summary>Converts a IDNA encoded ASCII hostname into it's Unicode equivalent</summary>
    class function IDNAToUnicode(const AHostName: string): string; static;

    /// <summary>Normalize a relative path using a given URI as base.</summary>
    /// <remarks>This function will remove '.' and '..' from path and returns an absolute URL.</remarks>
    class function PathRelativeToAbs(const RelPath: string; const Base: TURI): string; static;
    /// <summary>Property to obtain/set a parameter by it's index</summary>
    property Parameter[const I: Integer]: TURIParameter read GetParameter write SetParameter;
    /// <summary>Property to obtain/set a parameter value by it's Name</summary>
    property ParameterByName[const AName: string]: string read GetParameterByName write SetParameterByName;

    /// <summary>Scheme part of the URI.</summary>
    property Scheme: string read FScheme write FScheme;
    /// <summary>Username part of the URI.</summary>
    property Username: string read FUsername write SetUserName;
    /// <summary>Password part of the URI.</summary>
    property Password: string read FPassword write SetPassword;
    /// <summary>Host part of the URI.</summary>
    property Host: string read FHost write SetHost;
    /// <summary>Port part of the URI.</summary>
    property Port: Integer read FPort write FPort;
    /// <summary>Path part of the URI.</summary>
    property Path: string read FPath write SetPath;
    /// <summary>Query part of the URI.</summary>
    property Query: string read FQuery write SetQuery;
    /// <summary>Params part of the URI.</summary>
    property Params: TURIParameters read FParams write SetParams;
    /// <summary>Fragment part of the URI.</summary>
    property Fragment: string read FFragment write FFragment;
  end;

  TPunyCode = class
  private
  const
    BASE: Cardinal = 36;
    TMIN: Cardinal =  1;
    TMAX: Cardinal = 26;
    SKEW: Cardinal = 38;
    DAMP: Cardinal = 700;
    INITIAL_BIAS: Cardinal = 72;
    INITIAL_N: Cardinal = 128;
    MAX_INT: Cardinal = 65535;
    Delimiter = '-';
  private
    class function GetMinCodePoint(const AMinLimit: Cardinal; const AString: string): Cardinal;
    class function IsBasic(AString: string; const AIndex, AMinLimit: Cardinal): Boolean; inline;
    class function Adapt(const ADelta, ANumPoints: Cardinal; const FirstTime: Boolean): Cardinal;
    class function Digit2Codepoint(const ADigit: Cardinal): Cardinal;
    class function Codepoint2Digit(const ACodePoint: Cardinal): Cardinal;
    class function DoEncode(const AString: string): string;
    class function DoDecode(const AString: string): string;
  public
    class function Encode(const AString: string): string;
    class function Decode(const AString: string): string;
  end;

implementation

{ TURI }

procedure TURI.AddParameter(const AParameter: TURIParameter);
begin
  AddParameter(AParameter.Name, AParameter.Value);
end;

function GetQuery(const AURI: TURI): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Length(AURI.Params) - 1 do
    Result := Result + AURI.Params[I].Name + '=' + AURI.Params[I].Value + '&';
  if Result <> '' then
    Result := Result.Substring(0, Result.Length - 1); //Remove last '&'
end;

procedure TURI.AddParameter(const AName, AValue: string);
var
  Len: Integer;
begin
  Len := Length(Params);
  SetLength(FParams, Len + 1);
  FParams[Len].Name := TNetEncoding.URL.EncodeQuery(AName);
  FParams[Len].Value := TNetEncoding.URL.EncodeQuery(AValue);
  FQuery := GetQuery(Self);
end;

procedure TURI.ComposeURI(const AScheme, AUsername, APassword, AHostname: string; APort: Integer; const APath: string;
  const AParams: TURIParameters; const AFragment: string);
begin
  FScheme := AScheme;
  FUsername := TNetEncoding.URL.EncodeQuery(AUsername);
  FPassword := TNetEncoding.URL.EncodeQuery(APassword);
  FHost := AHostname;
  FPort := APort;
  FPath := TNetEncoding.URL.EncodePath(APath);
  Params := AParams;
  FFragment := TNetEncoding.URL.EncodeQuery(AFragment);
end;

constructor TURI.Create(const AURIStr: string);
begin
  DecomposeURI(AURIStr);
end;

procedure TURI.DecomposeURI(const AURIStr: string);

  function SchemeDelimiterOffset(Pos, Limit: Integer): Integer;
  var
    I: Integer;
  begin
    if Limit - Pos > 0 then
      for I := Pos to Limit do
        case AURIStr.Chars[I] of
          '0'..'9', 'a'..'z', 'A'..'Z', '+', '-', '.': {continue};  // Scheme character. Keep going.
          ':' : Exit(I);
        else
          Exit(-1);   // Non-scheme character before the first ':'.
        end;

    Result := -1;  // No ':'; doesn't start with a scheme.
  end;

  function PortColonOffset(Pos, Limit: Integer): Integer;
  begin
    while Pos <= Limit do
    begin
      case AURIStr.Chars[Pos] of
        '[':
          repeat
            Inc(Pos);
          until (Pos >= Limit) or (AURIStr.Chars[Pos] = ']');

        ':':
          Exit(Pos);
      end;
      Inc(Pos);
    end;
    Result := Limit; // No colon
  end;

  function SlashCount(Pos, Limit: Integer): Integer;
  begin
    Result := 0;
    while Pos < Limit do
    begin
      if (AURIStr.Chars[Pos] = '\') or (AURIStr.Chars[Pos] = '/') then
      begin
        Inc(Result);
        Inc(Pos);
      end
      else
        Break;
    end;
  end;

  function ParsePort(Pos, Limit: Integer): Integer;
  begin
    Result := AURIStr.Substring(Pos, Limit - Pos).ToInteger;
  end;

  function DefaultPort(const AScheme: string): Integer;
  begin
    Result := -1;
    if SameText(AScheme, 'http') then
      Result := 80;
    if SameText(AScheme, 'https') then
      Result := 443;
  end;

var
  PosScheme: Integer;
  Pos: Integer;
  Limit: Integer;
  LSlashCount: Integer;
  LCompDelimiterOffset: Integer;
  LPasswordColonOffset: Integer;
  LPortColonOffset: Integer;
  LQueryDelimiterOffset: Integer;
  LPathDelimiterOffset: Integer;
  C: Char;
  LHasPassword: Boolean;
  LHasUsername: Boolean;
  LEncodedUsername: string;
begin
  Self := Default(TURI);

  // Skip leading white spaces
  Pos := 0;
  while (Pos < High(AURIStr)) and (
    (AURIStr.Chars[Pos] = ' ') or
    (AURIStr.Chars[Pos] = #9) or
    (AURIStr.Chars[Pos] = #10) or
    (AURIStr.Chars[Pos] = #13) or
    (AURIStr.Chars[Pos] = #12) ) do
    Inc(Pos);

  // Skip trailing white spaces
  //Limit := High(AURIStr);
  Limit := AURIStr.Length - 1;
  while (Limit > 0) and (
    (AURIStr.Chars[Limit] = ' ') or
    (AURIStr.Chars[Limit] = #9) or
    (AURIStr.Chars[Limit] = #10) or
    (AURIStr.Chars[Limit] = #13) or
    (AURIStr.Chars[Limit] = #12) ) do
    Dec(Limit);

  PosScheme := SchemeDelimiterOffset(Pos, Limit);

  if PosScheme = -1 then
    raise ENetURIException.CreateResFmt(@SNetUriInvalid, [AURIStr]);

  Scheme := AURIStr.Substring(Pos, PosScheme - Pos);
  Pos := Pos + Scheme.Length + 1;

  LSlashCount := SlashCount(Pos, Limit);

  if LSlashCount >= 2 then
  begin
    // Read an authority if either:
    //  * The input starts with 2 or more slashes. These follow the scheme if it exists.
    //  * The input scheme exists and is different from the base URL's scheme.
    //
    // The structure of an authority is:
    //   username:password@host:port
    //
    // Username, password and port are optional.
    //   [username[:password]@]host[:port]
    Inc(Pos, LSlashCount);

    LHasPassword := False;
    LHasUsername := False;

    while True do
    begin
      LCompDelimiterOffset := AURIStr.IndexOfAny(['@', '/', '\', '?', '#'], Pos, Limit + 1 - Pos);
      if LCompDelimiterOffset = -1 then
        LCompDelimiterOffset := Limit + 1;

      if LCompDelimiterOffset <> Limit + 1 then
        C := AURIStr.Chars[LCompDelimiterOffset]
      else
        C := Char(-1);

      case C of
        '@':
          begin
            if not LHasPassword then
            begin
              LPasswordColonOffset := AURIStr.IndexOf(':', Pos, LCompDelimiterOffset - Pos);
              if LPasswordColonOffset = -1 then
                LPasswordColonOffset := LCompDelimiterOffset;

              LEncodedUsername := TNetEncoding.URL.EncodeAuth(AURIStr.Substring(Pos, LPasswordColonOffset - Pos));
              if LHasUsername then
                Username := Username + '%40' + LEncodedUsername
              else
                Username := LEncodedUsername;

              if LPasswordColonOffset <> LCompDelimiterOffset then
              begin
                LHasPassword := True;
                Password := TNetEncoding.URL.Encode(AURIStr.Substring(LPasswordColonOffset + 1,
                  LCompDelimiterOffset - (LPasswordColonOffset + 1)));
              end;
              LHasUsername := True;
            end
            else
              Password := Password + '%40' + TNetEncoding.URL.Encode(AURIStr.Substring(Pos, LCompDelimiterOffset - Pos));

            Pos := LCompDelimiterOffset + 1;
          end;

        Char(-1), '/', '\', '?', '#':
          begin
            LPortColonOffset := PortColonOffset(Pos, LCompDelimiterOffset);
            Host := AURIStr.Substring(Pos, LPortColonOffset - Pos);
            if LPortColonOffset + 1 < LCompDelimiterOffset then
              try
                Port := ParsePort(LPortColonOffset + 1, LCompDelimiterOffset)
              except
                raise ENetURIException.CreateResFmt(@SNetUriInvalid, [AURIStr]);
              end
            else
              Port := DefaultPort(Scheme);

            if Host = '' then
              raise ENetURIException.CreateResFmt(@SNetUriInvalid, [AURIStr]);

            Pos := LCompDelimiterOffset;
            Break;
          end;
      end;

    end;

    LPathDelimiterOffset := AURIStr.IndexOfAny(['?', '#'], Pos, Limit); // PathDelimiterOffset
    if LPathDelimiterOffset = -1 then
      LPathDelimiterOffset := Limit + 1;
    Path := TNetEncoding.URL.EncodePath(AURIStr.Substring(Pos, LPathDelimiterOffset - Pos));
    Pos := LPathDelimiterOffset;

    // Query
    if (Pos < Limit) and (AURIStr.Chars[Pos] = '?') then
    begin
      LQueryDelimiterOffset := AURIStr.IndexOf('#', Pos, Limit + 1 - Pos);
      if LQueryDelimiterOffset = -1 then
        LQueryDelimiterOffset := Limit + 1;
      Query := TNetEncoding.URL.EncodeQuery(AURIStr.Substring(Pos + 1, LQueryDelimiterOffset - (Pos + 1)));
      Pos := LQueryDelimiterOffset;
    end;

    // Fragment
    if (Pos < Limit) and (AURIStr.Chars[Pos] = '#') then
      Fragment := TNetEncoding.URL.Encode(AURIStr.Substring(Pos + 1, Limit + 1 - (Pos + 1)), [], []);

    ParseParams(True);
  end
  else
    raise ENetURIException.CreateResFmt(@SNetUriInvalid, [AURIStr]);
end;

procedure TURI.DeleteParameter(const AName: string);
var
  LIndex: Integer;
begin
  LIndex := FindParameterIndex(AName);
  if LIndex >= 0 then
  begin
    repeat
      DeleteParameter(LIndex);
      LIndex := FindParameterIndex(AName);
    until LIndex = -1;
  end
  else
    raise ENetURIException.CreateResFmt(@SNetUriParamNotFound, [AName]);
end;

function TURI.FindParameterIndex(const AName: string): Integer;
var
  I: Integer;
  LName: string;
begin
  Result := -1;
  LName := TNetEncoding.URL.EncodeQuery(AName);
  for I := 0 to Length(Params) - 1 do
    if Params[I].Name = LName then
      Exit(I);
end;

procedure TURI.DeleteParameter(AIndex: Integer);
begin
  if (AIndex >= Low(Params)) and (AIndex <= High(Params)) then
  begin
    if AIndex < High(Params) then
    begin
      Finalize(Params[AIndex]);
      System.Move(Params[AIndex + 1], Params[AIndex], (Length(Params) - AIndex - 1) * SizeOf(TURIParameter));
      FillChar(Params[High(Params)], SizeOf(TURIParameter), 0);
    end;
    SetLength(FParams, Length(FParams) - 1);
    FQuery := GetQuery(Self);
  end
  else
    raise ENetURIException.CreateResFmt(@SNetUriIndexOutOfRange, [AIndex, Low(Params), High(Params)]);
end;

function TURI.GetParameter(const I: Integer): TURIParameter;
begin
  if (I >= Low(Params)) and (I <= High(Params)) then
    Result := Params[I]
  else
    raise ENetURIException.CreateResFmt(@SNetUriIndexOutOfRange, [I, Low(Params), High(Params)]);
end;

function TURI.GetParameterByName(const AName: string): string;
var
  LIndex: Integer;
begin
  LIndex := FindParameterIndex(AName);
  if LIndex >= 0 then
    Result := GetParameter(LIndex).Value
  else
    raise ENetURIException.CreateResFmt(@SNetUriParamNotFound, [AName]);
end;

class function TURI.IDNAToUnicode(const AHostName: string): string;
var
  I: Integer;
  LDecoded: string;
  LPart: string;
  LParts: TArray<string>;
  LIsEncoded: Boolean;
begin
  LIsEncoded := False;
  LParts := AHostName.Split(['.']);
  for I := Low(LParts) to High(LParts) do
    if LParts[I].StartsWith('xn--') then
    begin
      LPart := LParts[I].Substring('xn--'.Length);
      if LPart.IndexOf('-') = -1 then
        LPart := '-' + LPart;
      LDecoded := TPunyCode.Decode(LPart);
      if LDecoded <> LPart then
      begin
        LParts[I] := LDecoded;
        LIsEncoded := True;
      end;
    end;
  if LIsEncoded then
    Result := string.Join('.', LParts)
  else
    Result := AHostName;
end;

procedure TURI.ParseParams(Encode: Boolean);
var
  LParts: TArray<string>;
  I: Integer;
  Pos: Integer;
begin
  LParts := Query.Split([Char(';'), Char('&')]);
  SetLength(FParams, Length(LParts));
  for I := 0 to Length(LParts) - 1 do
  begin
    Pos := LParts[I].IndexOf(Char('='));
    if Pos > 0 then
    begin
      if Encode then
      begin
        FParams[I].Name := TNetEncoding.URL.EncodeQuery(LParts[I].Substring(0, Pos));
        FParams[I].Value := TNetEncoding.URL.EncodeQuery(LParts[I].Substring(Pos + 1));
      end
      else
      begin
        FParams[I].Name := LParts[I].Substring(0, Pos);
        FParams[I].Value := LParts[I].Substring(Pos + 1);
      end;
    end
    else
    begin
      if Encode then
        FParams[I].Name := TNetEncoding.URL.EncodeQuery(LParts[I])
      else
        FParams[I].Name := LParts[I];
      FParams[I].Value := '';
    end;
  end;
end;

class function TURI.PathRelativeToAbs(const RelPath: string; const Base: TURI): string;

  function GetURLBase(const AURI: TURI): string;
  begin
    if ((AURI.Scheme = 'http') and (AURI.Port = 80)) or ((AURI.Scheme = 'https') and (AURI.Port = 443)) then
      Result := AURI.Scheme + '://' + AURI.Host
    else
      Result := AURI.Scheme + '://' + AURI.Host + ':' + AURI.Port.ToString;
  end;

  function GetURLPath(const AURI: TURI): string;
  begin
    Result := AURI.Path;
    Result := Result.Substring(0, Result.LastIndexOf(Char('/')) + 1);
  end;

var
  List: TStringList;
  Path: string;
  I, K: Integer;
begin
  I := RelPath.IndexOf(':');
  K := RelPath.IndexOf('/');

  if (I = -1) or (K <= I) then // not found ':' before '/' so there is no scheme, it's a relative path
  begin

    if K = 0 then // Begins with '/'
      Result := GetURLBase(Base) + RelPath
    else
    begin
      Path := GetURLPath(Base) + RelPath;

      List := TStringList.Create;
      try
        List.LineBreak := '/';
        List.SetText(PChar(Path));
        I := 0;
        while I < List.Count do
        begin
          if (List[I] = '.') then
            List.Delete(I)
          else
          if (I > 0) and (List[I] = '..') then
          begin
            List.Delete(I);
            if I > 0 then
            begin
              Dec(I);
              List.Delete(I);
            end;
          end
          else Inc(I);
        end;
        Result := '';
        for I := 0 to List.Count - 1 do
        begin
          if List[I] = '' then
            Result := Result + '/'
          else
            Result := Result + List[I] + '/';
        end;
        if RelPath[High(RelPath)] <> '/' then
          Result := Result.Substring(0, Result.Length - 1); // remove last '/'
        Result := GetURLBase(Base) + Result;
      finally
        List.Free;
      end;
    end;
  end
  else
    Result := RelPath;
end;

procedure TURI.SetHost(const Value: string);
begin
  FHost := UnicodeToIDNA(Value);
end;

procedure TURI.SetParameter(const I: Integer; const Value: TURIParameter);
begin
  if (I >= Low(Params)) and (I <= High(Params)) then
  begin
    Params[I].Name := TNetEncoding.URL.EncodeQuery(Value.Name);
    Params[I].Value := TNetEncoding.URL.EncodeQuery(Value.Value);
  end
  else
    raise ENetURIException.CreateResFmt(@SNetUriIndexOutOfRange, [I, Low(Params), High(Params)]);
end;

procedure TURI.SetParameterByName(const AName: string; const Value: string);
var
  LIndex: Integer;
begin
  LIndex := FindParameterIndex(AName);
  if LIndex >= 0 then
    Params[LIndex].Value := TNetEncoding.URL.EncodeQuery(Value)
  else
    raise ENetURIException.CreateResFmt(@SNetUriParamNotFound, [AName]);
end;

procedure TURI.SetParams(const Value: TURIParameters);
var
  I: Integer;
begin
  FParams := Value;
  for I := Low(FParams) to High(FParams) do
  begin
    FParams[I].Name := TNetEncoding.URL.EncodeQuery(FParams[I].Name);
    FParams[I].Value := TNetEncoding.URL.EncodeQuery(FParams[I].Value);
  end;
  FQuery := GetQuery(Self);
end;

procedure TURI.SetPassword(const Value: string);
begin
  FPassword := TNetEncoding.URL.EncodeAuth(Value);
end;

procedure TURI.SetPath(const Value: string);
begin
  if Value = '' then
    FPath := '/'
  else
    FPath := TNetEncoding.URL.EncodePath(Value);
end;

procedure TURI.SetQuery(const Value: string);
begin
  FQuery := Value;
  ParseParams(True);
end;

procedure TURI.SetUserName(const Value: string);
begin
  FUsername := TNetEncoding.URL.EncodeAuth(Value);
end;

function TURI.ToString: string;
var
  Auth: string;
begin
  if Username <> '' then
    if Password <> '' then
      Auth := Username + ':' + Password + '@'
    else
      Auth := Username + '@'
  else
    Auth := '';
  if Scheme <> '' then
    Result := Scheme + '://'
  else
    Result := '';
  Result := Result + Auth + Host;
  if ((Port <> -1) and (Port <> 0)) and
     ((Scheme.Equals('http') and (Port <> 80)) or (Scheme.Equals('https') and (Port <> 443))) then
    Result := Result + ':' + Port.ToString;
  Result := Result + Path;
  if Length(Params) > 0 then
    Result := Result + '?' + Query;
  if Fragment <> '' then
    Result := Result + '#' + Fragment;
end;

class function TURI.UnicodeToIDNA(const AHostName: string): string;
  procedure FixHostNamePart(var APart: string); inline;
  begin
    // This function is for solving issues related to: Internationalized Domain Names (IDN) in .museum - Orthographic issues
    // See: http://about.museum/idn/issues.html
    APart := APart.Replace('ß', 'ss', [rfReplaceAll]);
    APart := APart.Replace('ς', 'σ', [rfReplaceAll]);
    // case 0x200c:  // Ignore/remove ZWNJ.
    APart := APart.Replace(#$200C, '', [rfReplaceAll]);
    // case 0x200d:  // Ignore/remove ZWJ.
    APart := APart.Replace(#$200D, '', [rfReplaceAll]);
  end;
var
  I: Integer;
  LNormalizedHostName: string;
  LEncoded: string;
  LParts: TArray<string>;
begin
  // Normalize HostName. We do a LowerCase conversion. This manages casing issues.
  LNormalizedHostName := AHostName.ToLower;

  LParts := LNormalizedHostName.Split(['.']);
  for I := Low(LParts) to High(LParts) do
  begin
    FixHostNamePart(LParts[I]);

    LEncoded := TPunyCode.Encode(LParts[I]);
    if LEncoded <> LParts[I] then
    begin
      if LEncoded.StartsWith('-') then
        LParts[I] := 'xn-' + LEncoded
      else
        LParts[I] := 'xn--' + LEncoded;
    end;
  end;
  Result := string.Join('.', LParts)
end;

class function TURI.URLDecode(const AValue: string; PlusAsSpaces: Boolean): string;

const
  H2BConvert: array[Ord('0')..Ord('f')] of SmallInt =
    ( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,-1,-1,-1,-1,-1,-1,
     -1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     -1,10,11,12,13,14,15);

  function IsHexChar(C: Byte): Boolean;
  begin
    case C of
      Ord('0')..Ord('9'), Ord('a')..Ord('f'), Ord('A')..Ord('F'):  Result := True;
    else
      Result := False;
    end;
  end;


var
  ValueBuff: TBytes;
  Buff: TBytes;
  Cnt: Integer;
  Pos: Integer;
  Len: Integer;
begin
  Cnt := 0;
  Pos := 0;
  ValueBuff := TEncoding.UTF8.GetBytes(AValue);
  Len := Length(ValueBuff);
  SetLength(Buff, Len);
  while Pos < Len do
  begin
    if (ValueBuff[Pos] = Ord('%')) and ((Pos + 2) < Len)  and IsHexChar(ValueBuff[Pos + 1]) and IsHexChar(ValueBuff[Pos + 2]) then
    begin
      Buff[Cnt] := (H2BConvert[ValueBuff[Pos + 1]]) shl 4 or H2BConvert[ValueBuff[Pos + 2]];
      Inc(Pos, 3);
    end
    else
    begin
      if (ValueBuff[Pos] = Ord('+')) and PlusAsSpaces then
        Buff[Cnt] := Ord(' ')
      else
        Buff[Cnt] := ValueBuff[Pos];
      Inc(Pos);
    end;
    Inc(Cnt);
  end;
  Result := TEncoding.UTF8.GetString(Buff, 0 , Cnt);

end;

class function TURI.URLEncode(const AValue: string; SpacesAsPlus: Boolean): string;

  function IsHexChar(C: Byte): Boolean;
  begin
    case Char(C) of
      '0'..'9', 'a'..'f', 'A'..'F':  Result := True;
    else
      Result := False;
    end;
  end;

//  from http://www.faqs.org/rfcs/rfc3986.html
//  URL safe chars = ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '-', '_', '.', '~'];
const
  URLSafeCharMatrix: array [33..127] of Boolean = (False, False, False, False, False, False, False, False, False, False, False,
    False, True, True, False, True, True, True, True, True, True, True, True, True, True, False, False, False, False,
    False, False, False, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True,
    True, True, True, True, True, True, True, True, True, True, False, False, False, False, True, False, True, True,
    True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True,
    True, True, True, True, True, False, False, False, True, False);

  XD: array[0..15] of char = ('0', '1', '2', '3', '4', '5', '6', '7',
                              '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
var
  Buff: TBytes;
  I: Integer;
begin
  Buff := TEncoding.UTF8.GetBytes(AValue);
  Result := '';
  I := 0;
  while I < Length(Buff) do
  begin
    if (I + 2 < Length(Buff)) and (Buff[I] = Ord('%')) then
      if IsHexChar(Buff[I + 1]) and IsHexChar(Buff[I + 2]) then
      begin
        Result := Result + '%' + Char(Buff[I + 1]) + Char(Buff[I + 2]);
        Inc(I, 3);
        Continue;
      end;

    if (Buff[I] = Ord(' ')) and SpacesAsPlus then
      Result := Result + '+'
    else
    begin
      if (Buff[I] >= 33) and (Buff[I] <= 127) then
      begin
        if URLSafeCharMatrix[Buff[I]] then
          Result := Result + Char(Buff[I])
        else
          Result := Result + '%' + XD[(Buff[I] shr 4) and $0F] + XD[Buff[I] and $0F];
      end
      else
        Result := Result + '%' + XD[(Buff[I] shr 4) and $0F] + XD[Buff[I] and $0F];
    end;
    Inc(I);
  end;
end;

{ TPunyCode }

class function TPunyCode.DoEncode(const AString: string): string;
var
  N, LDelta, LBias, b, q, m, k, t: Cardinal;
  I: Integer;
  h: Integer;

begin
  Result := '';
  if AString = ''  then
    Exit;
  try
    N := INITIAL_N;
    LBias := INITIAL_BIAS;
    for I := 0 to AString.Length - 1 do
      if IsBasic(AString, I, INITIAL_N) then
        Result := Result + AString.Chars[I];
    b := Result.Length;
    if (Result.Length < AString.Length) and (Result.Length >= 0) then
      Result := Result + Delimiter;
    h := b;
    LDelta := 0;
    while h < AString.Length do
    begin
      m := GetMinCodePoint(N, AString);
      LDelta := LDelta + (m - N) * Cardinal(h + 1);
      N := m;
      for I := 0 to AString.Length - 1 do
      begin
        if IsBasic(AString, I, N) then
          Inc(LDelta)
        else if Ord(AString.Chars[I]) = N then
        begin
          q := LDelta;
          k := BASE;
          while k <= MAX_INT do
          begin
            if k <= (LBias + TMIN) then
              t := TMIN
            else if k >= (LBias + TMAX) then
              t := TMAX
            else
              t := k - LBias;
            if q < t then
              break;
            Result := Result + Chr(Digit2Codepoint(t + ((q - t) mod (BASE - t))));
            q := (q - t) div (BASE - t);
            Inc(k, BASE);
          end;
          Result := Result + Chr(Digit2Codepoint(q));
          LBias := Adapt(LDelta, h + 1, Cardinal(h) = b);
          LDelta := 0;
          Inc(h);
        end;
      end;
      Inc(LDelta);
      Inc(n);
    end;
  except
    Result := AString;
  end;
end;

class function TPunyCode.DoDecode(const AString: string): string;
var
  J: Integer;
  I, OldI, N, LBias, w, k, t: Cardinal;
  LPos, textLen, LCurrentLen: Integer;
  LDigit: Cardinal;
  c: Char;
begin
  Result := '';
  if AString = '' then
    Exit;
  try
    N := INITIAL_N;
    LBias := INITIAL_BIAS;
    LPos := AString.LastIndexOf(Delimiter);
    if LPos < 0 then
      Exit(AString);
    for J := 0 to (LPos - 1) do
      if Ord(AString.Chars[J]) >= INITIAL_N then
        Exit;
    Result := AString.Substring(0, LPos);
    I := 0;
    Inc(LPos);
    textLen := AString.Length;
    while LPos < textLen do
    begin
      OldI := I;
      w := 1;
      k := BASE;
      while (k <= MAX_INT) and (LPos < textLen) do
      begin
        c := AString.Chars[LPos];
        Inc(LPos);
        LDigit := Codepoint2Digit(Ord(c));
        if ((LDigit >= BASE) or (LDigit > ((MAX_INT - i) / w))) then
          Exit('');
        I := I + LDigit * w;
        if k <= LBias then
          t := TMIN
        else
          if k >= (LBias + TMAX) then
            t := TMAX
          else
            t := k - LBias;
        if LDigit < t then
          break;
        if w > (MAX_INT / (base - t)) then
          Exit('');
        w := w * (BASE - t);
        Inc(k, BASE);
      end;
      LCurrentLen := Result.Length + 1;
      LBias := Adapt(I - OldI, LCurrentLen, OldI = 0);
      if (I / LCurrentLen) > (MAX_INT - N) then
        Exit('');
      N := N + I div Cardinal(LCurrentLen);
      I := I mod Cardinal(LCurrentLen);
      if IsBasic(Char(n), 0, INITIAL_N) then
        Exit('');
      Result := Result.Insert(I, Char(N));
      Inc(I);
    end;
  except
    Result := AString;
  end;
end;

class function TPunyCode.IsBasic(AString: string; const AIndex, AMinLimit: Cardinal): Boolean;
begin
  Result := Ord(AString.Chars[AIndex]) < AMinLimit;
end;

class function TPunyCode.Adapt(const ADelta, ANumPoints: Cardinal; const FirstTime: Boolean): Cardinal;
var
  k, dt: Cardinal;
begin
  if FirstTime = True then
    dt := ADelta div DAMP
  else
    dt := ADelta div 2;
  dt := dt + (dt div ANumPoints);
  k := 0;
  while dt > (((BASE - TMIN) * TMAX) div 2) do
  begin
    dt := dt div (BASE - TMIN);
    Inc(k, BASE);
  end;
  Result := k + (((BASE - TMIN + 1) * dt) div (dt + SKEW));
end;

class function TPunyCode.Encode(const AString: string): string;
var
  Aux: string;
begin
  Result := DoEncode(AString);
  Aux := DoDecode(Result);
  if Aux <> AString then
    Result := AString;
end;

class function TPunyCode.Decode(const AString: string): string;
var
  Aux: string;
begin
  Result := DoDecode(AString);
  Aux := DoEncode(Result);
  if Aux <> AString then
    Result := AString;
end;

class function TPunyCode.Digit2Codepoint(const ADigit: Cardinal): Cardinal;
begin
  Result := 0;
  if ADigit < 26 then
    Result := ADigit + 97
  else if ADigit < 36 then
    Result := ADigit - 26 + 48;
end;

class function TPunyCode.Codepoint2Digit(const ACodePoint: Cardinal): Cardinal;
begin
  Result := BASE;
  if (ACodePoint - 48) < 10 then
    Result := ACodePoint - 22
  else if (ACodePoint - 65) < 26 then
    Result := ACodePoint - 65
  else if (ACodePoint - 97) < 26 then
    Result := ACodePoint - 97;
end;

class function TPunyCode.GetMinCodePoint(const AMinLimit: Cardinal; const AString: string): Cardinal;
var
  I: Integer;
  LMinCandidate: Cardinal;
begin
  Result := Integer.MaxValue;
  for I := 0 to AString.Length - 1 do
  begin
    LMinCandidate := Ord(AString.Chars[I]);
    if (LMinCandidate >= AMinLimit) and (LMinCandidate < Result) then
      Result := LMinCandidate;
  end;
end;

constructor TNameValuePair.Create(const AName, AValue: string);
begin
  Name := AName;
  Value := AValue;
end;

end.
