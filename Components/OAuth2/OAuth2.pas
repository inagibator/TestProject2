unit OAuth2;

interface

uses
  Classes,
  SysUtils,
  IdSASL,
  REST.Authenticator.OAuth,
  REST.Client,
  REST.Types,
  DateUtils,
  IdExplicitTLSClientServerBase,
  IdHTTP,
  IdSSLOpenSSL,
  IdMultipartFormData,
  Dialogs;

type
  TAuthType = class of TIdSASL;

  TProviderInfo = record
    AuthenticationType : TAuthType;
    AuthorizationEndpoint : string;
    AccessTokenEndpoint : string;
    ClientID : String;
    ClientSecret : string;
    //ClientAccount : string;
    Scopes : string;
    SmtpHost : string;
    SmtpPort : Integer;
    ImapHost: string;
    ImapPort: integer;
    PopHost : string;
    PopPort : Integer;
    AuthName : string;
    TLS : TIdUseTLS;
  end;

  TEnhancedOAuth2Authenticator = class (TOAuth2Authenticator)
  private
    procedure RequestAccessToken;
  public
    IDToken : string;
    procedure ChangeAuthCodeToAccesToken;
    procedure RefreshAccessTokenIfRequired;
  end;

  TIdSASLXOAuth = class(TIdSASL)
  private
    FToken: string;
    FUser: string;
  public
    property Token: string read FToken write FToken;
    property User: string read FUser write FUser;
    class function ServiceName: TIdSASLServiceName; override;
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    //function TryStartAuthenticate(const AHost, AProtocolName : String; var VInitialResponse: String): Boolean; override;
    function ContinueAuthenticate(const ALastResponse, AHost, AProtocolName : string): string; override;
    function StartAuthenticate(const AChallenge, AHost, AProtocolName: string): string; override;
    { For cleaning up after Authentication }
    procedure FinishAuthenticate; override;
  end;

  TIdOAuth2Bearer = class(TIdSASL)
  private
    FToken: string;
    FHost: string;
    FUser: string;
    FPort: Integer;
  public
    property Token: string read FToken write FToken;
    property Host: string read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property User: string read FUser write FUser;
    class function ServiceName: TIdSASLServiceName; override;
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
//    function TryStartAuthenticate(const AHost, AProtocolName : String; var VInitialResponse: String): Boolean; override;
    function ContinueAuthenticate(const ALastResponse, AHost, AProtocolName : string): string; override;
    function StartAuthenticate(const AChallenge, AHost, AProtocolName: string): string; override;
    { For cleaning up after Authentication }
    procedure FinishAuthenticate; override;
  end;

  const google_clientid = '348783703054-1nadnvkcrk4fhqvbvu6v99l3lei47fpb.apps.googleusercontent.com';
  const google_clientsecret = 'YdsNRvUmmbR-mk5QVIh9CTUA';

  const microsoft_clientid = '395bb7b7-4a3f-466e-97ff-1011c794529d';
  const microsoft_clientsecret = '_eTMF.1.uV-BwLSEK9Eg8_Y54DIX7-BiPk';

  const
    Providers : array[0..1] of TProviderInfo =
    (
      (  AuthenticationType : TIdOAuth2Bearer;
         AuthorizationEndpoint : 'https://accounts.google.com/o/oauth2/auth';
         AccessTokenEndpoint : 'https://accounts.google.com/o/oauth2/token';
         ClientID : google_clientid;
         ClientSecret : google_clientsecret;
         //ClientAccount : google_clientAccount;  // your @gmail.com email address
         Scopes : 'https://www.googleapis.com/auth/gmail.send openid';
         SmtpHost : 'smtp.gmail.com';
         SmtpPort : 587;
         ImapHost : 'imap.gmail.com';
         ImapPort : 993;
         PopHost : 'pop.gmail.com';
         PopPort : 995;
         AuthName : 'Google';
         TLS : utUseImplicitTLS
      ),
      (  AuthenticationType : TIdSASLXOAuth;
         //AuthorizationEndpoint : 'https://login.live.com/oauth20_authorize.srf';
         AuthorizationEndpoint: 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize';
         //AccessTokenEndpoint : 'https://login.live.com/oauth20_token.srf';

         AccessTokenEndpoint: 'https://login.microsoftonline.com/common/oauth2/v2.0/token';
         ClientID : microsoft_clientid;
         ClientSecret : microsoft_clientsecret;
         Scopes: 'https://outlook.office.com/mail.send https://outlook.office.com/SMTP.Send openid offline_access';
         SmtpHost: 'smtp.office365.com';
         SmtpPort : 587;
         ImapHost : 'outlook.office365.com';
         ImapPort : 993;
         PopHost : 'outlook.office365.com';
         PopPort : 995;
         AuthName : 'Microsoft';
         TLS : utUseExplicitTLS
      )
    );

var
  AccessTokens: array[0..1] of string;

const
  ClientRedirect = 'http://localhost:2132';
  SAuthorizationCodeNeeded = 'An authorization code is needed before it can be changed into an access token.';
  SClientIDNeeded = 'An ClientID is needed before a token can be requested';
  SRefreshTokenNeeded = 'An Refresh Token is needed before an Access Token can be requested';

implementation

procedure TEnhancedOAuth2Authenticator.RefreshAccessTokenIfRequired;
begin
  if AccessTokenExpiry < now then
  begin
    RequestAccessToken;
  end;
end;

procedure TEnhancedOAuth2Authenticator.RequestAccessToken;
var
  LClient: TRestClient;
  LRequest: TRESTRequest;
  LToken: string;
  LIntValue: int64;
begin

  // we do need an clientid here, because we want
  // to send it to the servce and exchange the code into an
  // access-token.
  if ClientID = '' then
    raise TOAuth2Exception.Create(SClientIDNeeded);

  if RefreshToken = '' then
    raise TOAuth2Exception.Create(SRefreshTokenNeeded);

  LClient := TRestClient.Create(AccessTokenEndpoint);
  try
    LRequest := TRESTRequest.Create(LClient); // The LClient now "owns" the Request and will free it.
    LRequest.Method := TRESTRequestMethod.rmPOST;

    LRequest.AddAuthParameter('refresh_token', RefreshToken, TRESTRequestParameterKind.pkGETorPOST);
    LRequest.AddAuthParameter('client_id', ClientID, TRESTRequestParameterKind.pkGETorPOST);
    LRequest.AddAuthParameter('client_secret', ClientSecret, TRESTRequestParameterKind.pkGETorPOST);
    LRequest.AddAuthParameter('grant_type', 'refresh_token', TRESTRequestParameterKind.pkGETorPOST);

    LRequest.Execute;


    if LRequest.Response.GetSimpleValue('access_token', LToken) then
      AccessToken := LToken;
    if LRequest.Response.GetSimpleValue('refresh_token', LToken) then
      RefreshToken := LToken;
    if LRequest.Response.GetSimpleValue('id_token', LToken) then
      IDToken := LToken;

    // detect token-type. this is important for how using it later
    if LRequest.Response.GetSimpleValue('token_type', LToken) then
      TokenType := OAuth2TokenTypeFromString(LToken);

    // if provided by the service, the field "expires_in" contains
    // the number of seconds an access-token will be valid
    if LRequest.Response.GetSimpleValue('expires_in', LToken) then
    begin
      LIntValue := StrToIntdef(LToken, -1);
      if (LIntValue > -1) then
        AccessTokenExpiry := IncSecond(Now, LIntValue)
      else
        AccessTokenExpiry := 0.0;
    end;

    // an authentication-code may only be used once.
    // if we succeeded here and got an access-token, then
    // we do clear the auth-code as is is not valid anymore
    // and also not needed anymore.
    if (AccessToken <> '') then
    begin
      AuthCode := '';
    end;
  finally
    LClient.DisposeOf;
  end;
end;


// This function is basically a copy of the ancestor... but is need so we can also get the id_token value.
procedure TEnhancedOAuth2Authenticator.ChangeAuthCodeToAccesToken;
var
  LClient: TRestClient;
  LRequest: TRESTRequest;
  LToken: string;
  LIntValue: int64;

  HTTP: TIdHTTP;
  FormData: TIdMultiPartFormDataStream;
  Stream: TStringStream;
begin

  // we do need an authorization-code here, because we want
  // to send it to the servce and exchange the code into an
  // access-token.
  if AuthCode = '' then
    raise TOAuth2Exception.Create(SAuthorizationCodeNeeded);

  LClient := TRestClient.Create(AccessTokenEndpoint);
  try
    LRequest := TRESTRequest.Create(LClient); // The LClient now "owns" the Request and will free it.

//    if Pos('microsoftonline', AccessTokenEndpoint) = 0 then
//    begin
//      FormData := TIdMultiPartFormDataStream.Create;
//      FormData.AddFormField('grant_type', 'authorization_code');
//      FormData.AddFormField('code', AuthCode);
//      FormData.AddFormField('client_id', ClientID);
//      FormData.AddFormField('client_secret', ClientSecret);
//      FormData.AddFormField('redirect_uri', RedirectionEndpoint);
//      FormData.AddFormField('scope', 'https://outlook.office.com/mail.send https://outlook.office.com/SMTP.Send openid offline_access');
//
//      HTTP := TIdHTTP.Create(nil);
//      HTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(HTTP);
//      HTTP.Request.ContentType := 'multipart/form-data';
//      HTTP.Request.URL := AccessTokenEndpoint;
//      HTTP.Request.Method := 'POST';
//
//      try
//        //ShowMessage(HTTP.Post(AccessTokenEndpoint, FormData));
//        Stream := TStringStream.Create(HTTP.Post(AccessTokenEndpoint, FormData));
//
//        LRequest.Response := TRESTResponse.Create(LRequest);
//        LRequest.Response.SetContent(Stream);
//        LRequest.Response.ContentType := 'application/json';
//        FreeAndNil(Stream);
//      except
//        on E: EIdHTTPProtocolException  do
//          if (http.ResponseCode = 400) then
//            ShowMessage(E.ErrorMessage)
//          else
//            ShowMessage(E.Message);
//      end;
//      FreeAndNil(HTTP);
//    end
//    else
//    begin
      LRequest.Method := TRESTRequestMethod.rmPOST;
      // LRequest.Client := LClient; // unnecessary since the client "owns" the request it will assign the client

      LRequest.AddAuthParameter('code', AuthCode, TRESTRequestParameterKind.pkGETorPOST);
      LRequest.AddAuthParameter('client_id', ClientID, TRESTRequestParameterKind.pkGETorPOST);
      LRequest.AddAuthParameter('client_secret', ClientSecret, TRESTRequestParameterKind.pkGETorPOST);
      LRequest.AddAuthParameter('redirect_uri', RedirectionEndpoint, TRESTRequestParameterKind.pkGETorPOST);
      LRequest.AddAuthParameter('grant_type', 'authorization_code', TRESTRequestParameterKind.pkGETorPOST);

      try
        LRequest.Execute;
      except
        ShowMessage(LRequest.Response.Content);
      end;
  //  end;



    if LRequest.Response.GetSimpleValue('access_token', LToken) then
      AccessToken := LToken;
    if LRequest.Response.GetSimpleValue('refresh_token', LToken) then
      RefreshToken := LToken;
    if LRequest.Response.GetSimpleValue('id_token', LToken) then
      IDToken := LToken;


    // detect token-type. this is important for how using it later
    if LRequest.Response.GetSimpleValue('token_type', LToken) then
      TokenType := OAuth2TokenTypeFromString(LToken);

    // if provided by the service, the field "expires_in" contains
    // the number of seconds an access-token will be valid
    if LRequest.Response.GetSimpleValue('expires_in', LToken) then
    begin
      LIntValue := StrToIntdef(LToken, -1);
      if (LIntValue > -1) then
        AccessTokenExpiry := IncSecond(Now, LIntValue)
      else
        AccessTokenExpiry := 0.0;
    end;

    // an authentication-code may only be used once.
    // if we succeeded here and got an access-token, then
    // we do clear the auth-code as is is not valid anymore
    // and also not needed anymore.
    if (AccessToken <> '') then
      AuthCode := '';
  finally
    LClient.DisposeOf;
  end;

end;

{ TIdSASLXOAuth }

class function TIdSASLXOAuth.ServiceName: TIdSASLServiceName;
begin
  Result := 'XOAUTH2';
end;

constructor TIdSASLXOAuth.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TIdSASLXOAuth.Destroy;
begin
  inherited;
end;

//function TIdSASLXOAuth.TryStartAuthenticate(const AHost, AProtocolName: String; var VInitialResponse: String): Boolean;
//begin
//  VInitialResponse := 'user=' + FUser + Chr($01) + 'auth=Bearer ' + FToken + Chr($01) + Chr($01);
//  Result := True;
//end;

function TIdSASLXOAuth.StartAuthenticate(const AChallenge, AHost, AProtocolName: string): string;
begin
  Result := 'user=' + FUser + Chr($01) + 'auth=Bearer ' + FToken + Chr($01) + Chr($01);
end;

function TIdSASLXOAuth.ContinueAuthenticate(const ALastResponse, AHost, AProtocolName: string): string;
begin
  // Nothing to do
end;

procedure TIdSASLXOAuth.FinishAuthenticate;
begin
  // Nothing to do
end;

{ TIdOAuth2Bearer }

constructor TIdOAuth2Bearer.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TIdOAuth2Bearer.Destroy;
begin
  inherited;
end;

class function TIdOAuth2Bearer.ServiceName: TIdSASLServiceName;
begin
  Result := 'OAUTHBEARER';
end;

//function TIdOAuth2Bearer.TryStartAuthenticate(const AHost, AProtocolName: String; var VInitialResponse: String): Boolean;
//begin
//  VInitialResponse := 'n,a=' + FUser + ',' + Chr($01) + 'host=' + FHost + Chr($01) + 'port=' + FPort.ToString + Chr($01) + 'auth=Bearer ' + FToken + Chr($01) + Chr($01);
//  Result := True;
//end;

function TIdOAuth2Bearer.StartAuthenticate(const AChallenge, AHost, AProtocolName: string): string;
begin
  Result := 'n,a=' + FUser + ',' + Chr($01) + 'host=' + FHost + Chr($01) + 'port=' + FPort.ToString + Chr($01) + 'auth=Bearer ' + FToken + Chr($01) + Chr($01);
end;

function TIdOAuth2Bearer.ContinueAuthenticate(const ALastResponse, AHost, AProtocolName: string): string;
begin
  // Nothing to do
end;

procedure TIdOAuth2Bearer.FinishAuthenticate;
begin
  // Nothing to do
end;

end.
