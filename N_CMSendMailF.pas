unit N_CMSendMailF;
// CMS mail client

// 23.03.16 - new interface added, with image preview

// 12.04.16 - changed LSMTP.UseTLS

// 12.05.16 - new interface, new options for ssl/tls

// 01.10.18 - tls 1.2 update

interface
uses
  Windows, Messages, SysUtils, Variants, Classes,
  Controls, StdCtrls, ExtCtrls, Forms, Graphics, Types,
  N_Types, N_BaseF, N_Rast1Fr, K_CM0, N_CompBase, N_Gra2, Grids, N_Lib0, Dialogs,
  IdBaseComponent, IdComponent, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL
{$IF CompilerVersion >= 18.0} // Delphi >= Delphi 2006
  ,
  IdMessage, IdExplicitTLSClientServerBase,
  IdAttachmentFile, IdSMTP, OAuth2, IdSASLCollection, IdHTTP
{$IFEND CompilerVersion >= 18.0}
  ;

type TN_CMSendMailForm = class( TN_BaseForm )
    bnOK:        TButton;
    MemoBody:    TMemo;
    lbTo:        TLabel;
    lbBody:      TLabel;
    lbCopy:      TLabel;
    cbTo:        TComboBox;
    cbCopy:      TComboBox;
    NewPanel:    TPanel;
    NewRFrame:   TN_Rast1Frame;
    Label1:      TLabel;
    StringGrid1: TStringGrid;
    cbTotalSize: TLabel;
    lbSize:      TLabel;
    bnClose:     TButton;
    IdSSLIOHandlerSocketSMTP: TIdSSLIOHandlerSocketOpenSSL;
    procedure bnOKClick        ( Sender: TObject );
    procedure FormShow         ( Sender: TObject );
    procedure StringGrid1Click ( Sender: TObject );
    procedure FormClose        ( Sender: TObject; var Action: TCloseAction );
                                                                       override;
    procedure AutoSizeGrid     ();
    procedure FormResize       ( Sender: TObject ); override;
    function  GetVideoFileInfoFromSampleGrabber ( AFName: string ): TN_DIBObj;
    procedure bnCloseClick     ( Sender: TObject );
    procedure DrawPreview      ();
    procedure DebSendMail( Host, UserName, Password: string; ReadTimeout,
                                             Port, Method, Mode, TLS: Integer );
    procedure FormCreate(Sender: TObject);
    private
      OAuth2_Enhanced: TEnhancedOAuth2Authenticator;
      procedure SetupAuthenticator;
    public
      CMMFSubject:     string;
      CMMFAttachments: TStrings;
      CMMFRetCode :    Integer;

      //***** for preview
      CMMFNewSlide: TN_UDCMSlide;
      CMMFRootComp: TN_UDCompVis;
end;

// showing this form
function N_CMSendMail ( const ASubject : string; Attachments : TStrings ):
                                                                        Integer;

implementation

{$R *.dfm}

uses
  N_Lib1, N_Video, DirectShow9, ActiveX, N_Gra0, IdSSLOpenSSLHeaders;


procedure TN_CMSendMailForm.SetupAuthenticator;
var
  Provider: integer;
  Token: string;
begin
  Provider := N_MemIniToInt('CMS_Email', 'Provider', 0);
  Token := N_MemIniToString('CMS_Email', Providers[Provider].AuthName + 'Token', '');

  OAuth2_Enhanced.ClientID := Providers[Provider].ClientID;
  OAuth2_Enhanced.ClientSecret := Providers[Provider].Clientsecret;
  OAuth2_Enhanced.Scope := Providers[Provider].Scopes;
  OAuth2_Enhanced.RedirectionEndpoint := clientredirect;
  OAuth2_Enhanced.AuthorizationEndpoint := Providers[Provider].AuthorizationEndpoint;
  OAuth2_Enhanced.AccessTokenEndpoint := Providers[Provider].AccessTokenEndpoint;

  OAuth2_Enhanced.RefreshToken := Token;
end;

//************************************************************ N_CMSendMail ***
// Email given files
//
//     Parameters
// ASubject   - email subject
// AFilesList - files paths list to attach
// Result - Returns resulting code: 0 - if message is sent,
//                                  1 - user abort emailing, < 0 - if exception is raised
//
function N_CMSendMail( const ASubject : string; Attachments : TStrings ):
                                                                        Integer;
var
  Form: TN_CMSendMailForm;
begin

  Form := TN_CMSendMailForm.Create( Application );
  Form.CMMFRetCode := 1;
  Form.BaseFormInit( Nil, '', [ rspfMFRect, rspfCenter ], [ rspfAppWAR,
                                                               rspfShiftAll ] );
  Form.CMMFSubject     := ASubject;
  Form.CMMFAttachments := Attachments;

  // Get Info from Address Book to Form.cbTo.Items and Form.cbCopy.Items
  N_MemIniToStrings( 'CMS_EmABook', Form.cbTo.Items );
  Form.cbCopy.Items.AddStrings( Form.cbTo.Items );

  Form.ShowModal();
  Result := Form.CMMFRetCode;
end; // function N_CMSendMail

//********************************************* TN_CMSendMailForm.bnOKClick ***
// Button "OK" click event handle
//
//     Parameters
// Sender - sender object
//
// Sends an E-mail
//
procedure TN_CMSendMailForm.bnOKClick( Sender: TObject );
  procedure AddToAddressBook;
  begin
    // Add new Address to cbTo.Items
    if ( cbCopy.Text <> '' ) and ( cbTo.Items.IndexOf(cbCopy.Text) < 0 ) then
      cbTo.Items.Insert( 0, cbCopy.Text);

    if ( cbTo.Items.IndexOf(cbTo.Text) < 0 ) then
      cbTo.Items.Insert( 0, cbTo.Text);

    // Save cbTo.Items to Address Book
    N_StringsToMemIni( 'CMS_EmABook', cbTo.Items );
  end;

{$IF CompilerVersion >= 18.0} // Delphi >= Delphi 2006
var
  LSMTP:   TIdSMTP;
  LMsg:    TIdMessage;
  IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
  i:       Integer;

  AuthType, Provider: integer;
  Token, ClientAccount: string;
  xoauthSASL : TIdSASLListEntry;

  HTTP: TIdHTTP;
  Stream: TMemoryStream;
{$IFEND CompilerVersion >= 18.0}
begin

{$IF CompilerVersion >= 18.0} // Delphi >= Delphi 2006

if N_MemIniToString( 'CMS_UserDeb', 'DebEmail', '' ) = 'TRUE' then
begin
  N_Dump1Str('');
  N_Dump1Str('~~~~~~~~~ Start test ~~~~~~~~~~~~');
  N_Dump1Str('1');
  DebSendMail( 'smtp.gmail.com', 'testcmsuite@gmail.com', 'passwordpassword1',
                                                              0, 465, 3, 0, 1 );
  N_Dump1Str('2');
  DebSendMail( 'smtp.gmail.com', 'testcmsuite@gmail.com', 'passwordpassword1',
                                                              0, 465, 3, 0, 2 );
  N_Dump1Str('3');
  DebSendMail( 'smtp.gmail.com', 'testcmsuite@gmail.com', 'passwordpassword1',
                                                              0, 587, 3, 0, 1 );
  N_Dump1Str('4');
  DebSendMail( 'smtp.gmail.com', 'testcmsuite@gmail.com', 'passwordpassword1',
                                                              0, 587, 3, 0, 2 );
  N_Dump1Str('5');
  DebSendMail( 'smtp.gmail.com', 'testcmsuite@gmail.com', 'passwordpassword1',
                                                              0, 465, 1, 1, 0 );
  N_Dump1Str('6');
  DebSendMail( 'smtp.gmail.com', 'testcmsuite@gmail.com', 'passwordpassword1',
                                                              0, 587, 1, 1, 0 );
  N_Dump1Str('7');
  DebSendMail( 'smtp.gmail.com', 'testcmsuite@gmail.com', 'passwordpassword1',
                                                              0, 465, 1, 1, 1 );
  N_Dump1Str('8');
  DebSendMail( 'smtp.gmail.com', 'testcmsuite@gmail.com', 'passwordpassword1',
                                                              0, 587, 1, 1, 1 );
  N_Dump1Str('9');
  DebSendMail( 'smtp.gmail.com', 'testcmsuite@gmail.com', 'passwordpassword1',
                                                              0, 465, 1, 1, 2 );
  N_Dump1Str('10');
  DebSendMail( 'smtp.gmail.com', 'testcmsuite@gmail.com', 'passwordpassword1',
                                                              0, 587, 1, 1, 2 );

  N_Dump1Str('11');
  DebSendMail( N_MemIniToString( 'CMS_Email', 'Server', '' ),
                                N_MemIniToString( 'CMS_Email', 'Login', '' ),
                                N_MemIniToString( 'CMS_Email', 'Password', '' ),
                                                              0, 465, 3, 0, 1 );
  N_Dump1Str('12');
  DebSendMail( N_MemIniToString( 'CMS_Email', 'Server', '' ),
                                N_MemIniToString( 'CMS_Email', 'Login', '' ),
                                N_MemIniToString( 'CMS_Email', 'Password', '' ),
                                                              0, 465, 3, 0, 2 );
  N_Dump1Str('13');
  DebSendMail( N_MemIniToString( 'CMS_Email', 'Server', '' ),
                                N_MemIniToString( 'CMS_Email', 'Login', '' ),
                                N_MemIniToString( 'CMS_Email', 'Password', '' ),
                                                              0, 587, 3, 0, 1 );
  N_Dump1Str('14');
  DebSendMail( N_MemIniToString( 'CMS_Email', 'Server', '' ),
                                N_MemIniToString( 'CMS_Email', 'Login', '' ),
                                N_MemIniToString( 'CMS_Email', 'Password', '' ),
                                                              0, 587, 3, 0, 2 );
  N_Dump1Str('15');
  DebSendMail( N_MemIniToString( 'CMS_Email', 'Server', '' ),
                                N_MemIniToString( 'CMS_Email', 'Login', '' ),
                                N_MemIniToString( 'CMS_Email', 'Password', '' ),
                                                              0, 465, 1, 1, 0 );
  N_Dump1Str('16');
  DebSendMail( N_MemIniToString( 'CMS_Email', 'Server', '' ),
                                N_MemIniToString( 'CMS_Email', 'Login', '' ),
                                N_MemIniToString( 'CMS_Email', 'Password', '' ),
                                                              0, 587, 1, 1, 0 );
  N_Dump1Str('17');
  DebSendMail( N_MemIniToString( 'CMS_Email', 'Server', '' ),
                                N_MemIniToString( 'CMS_Email', 'Login', '' ),
                                N_MemIniToString( 'CMS_Email', 'Password', '' ),
                                                              0, 465, 1, 1, 1 );
  N_Dump1Str('18');
  DebSendMail( N_MemIniToString( 'CMS_Email', 'Server', '' ),
                                N_MemIniToString( 'CMS_Email', 'Login', '' ),
                                N_MemIniToString( 'CMS_Email', 'Password', '' ),
                                                              0, 587, 1, 1, 1 );
  N_Dump1Str('19');
  DebSendMail( N_MemIniToString( 'CMS_Email', 'Server', '' ),
                                N_MemIniToString( 'CMS_Email', 'Login', '' ),
                                N_MemIniToString( 'CMS_Email', 'Password', '' ),
                                                              0, 465, 1, 1, 2 );
  N_Dump1Str('20');
  DebSendMail( N_MemIniToString( 'CMS_Email', 'Server', '' ),
                                N_MemIniToString( 'CMS_Email', 'Login', '' ),
                                N_MemIniToString( 'CMS_Email', 'Password', '' ),
                                                              0, 587, 1, 1, 2 );
  N_Dump1Str('~~~~~~~~~~~~~ End test ~~~~~~~~~~~~~~');
end
else
begin
  AuthType := N_MemIniToInt('CMS_Email', 'AuthType', 0);

  if AuthType = 1 then
  begin
    Provider := N_MemIniToInt('CMS_Email', 'Provider', 0);

    Token := N_MemIniToString('CMS_Email', Providers[Provider].AuthName + 'Token', '');
    ClientAccount := N_MemIniToString('CMS_Email', Providers[Provider].AuthName + 'ClientID', '');

    if ClientAccount.IsEmpty OR
       Token.IsEmpty then
    begin
      MessageDlg('Setup OAuth2 in settings!', mtError, [mbOK], 0);
      Exit;
    end
    else
      SetupAuthenticator;
  end;

  IdOpenSSLSetLibPath(ExtractFilePath(ParamStr(0)));

  LSMTP := TIdSMTP.Create( nil );
  // ***** message
  LMsg := TIdMessage.Create( LSMTP );
  LMsg.CharSet := 'UTF-8';
  LMsg.Subject := CMMFSubject;
  LMsg.Recipients.EMailAddresses := cbTo.Text;
  N_Dump1Str( 'E-mail: To = ' + cbTo.Text );
  LMsg.CCList.EMailAddresses     := cbCopy.Text;
  N_Dump1Str( 'E-mail: Copy = ' + cbCopy.Text );

  if N_MemIniToInt('CMS_Email', 'AuthType', 0) = 0 then
    LMsg.From.Text := N_MemIniToString( 'CMS_Email', 'Sender', '' )
  else
  begin
    LMsg.From.Address := ClientAccount;
    LMsg.From.Name := ClientAccount;
    LMsg.ReplyTo.EMailAddresses := LMsg.From.Address;
  end;

  N_Dump1Str( 'E-mail parameters, begin' );
  N_Dump1Str( 'E-mail: Sender = ' + LMsg.From.Text );

  // type of a letter
  LMsg.ContentType := 'multipart/mixed; charset=UTF-8';
  LMsg.ContentTransferEncoding := '8bit';

  LMsg.Body      := MemoBody.Lines;
  LMsg.IsEncoded := True;

  for i := 0 to CMMFAttachments.Count - 1 do
  if FileExists( CMMFAttachments[i] ) then
  begin
    TIdAttachmentFile.Create( LMsg.MessageParts, CMMFAttachments[i] );
  end;

  if (AuthType = 1) AND
     (Provider = 0) then  //GOOGLE OAuth2 sending
  begin
    OAuth2_Enhanced.RefreshAccessTokenIfRequired;

    HTTP := TIdHTTP.Create(Self);
    HTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(http);

    HTTP.Request.CustomHeaders.FoldLines := False;
    HTTP.Request.CustomHeaders.Add('Authorization:Bearer ' + OAuth2_Enhanced.AccessToken);
    HTTP.Request.ContentType := 'message/rfc822';

    Stream := TMemoryStream.Create;
    LMsg.SaveToStream(Stream);

    try
      HTTP.Post('https://www.googleapis.com/upload/gmail/v1/users/me/messages/send?uploadType=media', Stream);
    except
      on E: EIdHTTPProtocolException  do
        if (http.ResponseCode = 400) OR
           (http.ResponseCode = 403) then
          ShowMessage(E.ErrorMessage)
        else
          ShowMessage(E.Message);
    end;

    FreeAndNil(Stream);

    CMMFRetCode := 0;
    AddToAddressBook;

    Exit;
  end;

  case AuthType of
    0: begin
         LSMTP.Host     := N_MemIniToString( 'CMS_Email', 'Server', '' );
         N_Dump1Str( 'E-mail: Server = ' + LSMTP.Host );

         LSMTP.Port     := StrToInt(N_MemIniToString( 'CMS_Email', 'Port', '25' ));
         N_Dump1Str( 'E-mail: Port = ' + IntToStr(LSMTP.Port) );

         LSMTP.UserName := N_MemIniToString( 'CMS_Email', 'Login', '' );
         N_Dump1Str( 'E-mail: Login = ' + LSMTP.UserName );

         LSMTP.Password := N_MemIniToString( 'CMS_Email', 'Password', '' );
         //N_Dump1Str( 'Email: Password = ' + LSMTP.Password );

         LSMTP.ReadTimeout := StrToIntDef(
                                  N_MemIniToString( 'CMS_Email', 'Timeout', '' ), 0 );
         N_Dump1Str( 'E-mail: Timeout = ' + IntToStr(LSMTP.ReadTimeout) );
         N_Dump1Str( 'E-mail parameters, end' );

         LSMTP.MailAgent := 'CMSuite';

         // ***** ssl socket
         IdSSLIOHandlerSocketOpenSSL1 := TIdSSLIOHandlerSocketOpenSSL.Create( nil );
         IdSSLIOHandlerSocketOpenSSL1.Destination := LSMTP.Host+':' +
                                                               IntToStr( LSMTP.Port );
         IdSSLIOHandlerSocketOpenSSL1.Host := LSMTP.Host;
         IdSSLIOHandlerSocketOpenSSL1.Port := LSMTP.Port;
         IdSSLIOHandlerSocketOpenSSL1.DefaultPort := 0;
         IdSSLIOHandlerSocketOpenSSL1.SSLOptions.SSLVersions := [sslvTLSv1_2];
         IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Method := sslvTLSv1_2;//sslvTLSv1;
         IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Mode   := sslmUnassigned;
         //IdSSLIOHandlerSocketOpenSSL1.SSLOptions.CipherList := 'RSA:!COMPLEMENTOFALL!DES!3DES!RC4';

         LSMTP.IOHandler := IdSSLIOHandlerSocketOpenSSL1;

         N_Dump1Str( 'E-mail: TLS = ' + N_MemIniToString( 'CMS_Email', 'TLS', '' ) );
         if N_MemIniToString( 'CMS_Email', 'TLS', '' ) = 'TRUE' then
           LSMTP.UseTLS := utUseRequireTLS // tls
         else
           LSMTP.UseTLS := utUseImplicitTLS; // ssl
       end;

    1: begin
         OAuth2_Enhanced.RefreshAccessTokenIfRequired;

         LSMTP.AuthType := satSASL;
         LSMTP.IOHandler := IdSSLIOHandlerSocketSMTP;

         LSMTP.Host := Providers[Provider].SmtpHost;
         LSMTP.Port := Providers[Provider].SmtpPort;
         LSMTP.UseTLS := utUseExplicitTLS;
         LSMTP.Username := ClientAccount;

         xoauthSASL := LSMTP.SASLMechanisms.Add;
         xoauthSASL.SASL := Providers[Provider].AuthenticationType.Create(nil);

         if xoauthSASL.SASL is TIdOAuth2Bearer then
         begin
           TIdOAuth2Bearer(xoauthSASL.SASL).Token := OAuth2_Enhanced.AccessToken;
           TIdOAuth2Bearer(xoauthSASL.SASL).Host := LSMTP.Host;
           TIdOAuth2Bearer(xoauthSASL.SASL).Port := LSMTP.Port;
           TIdOAuth2Bearer(xoauthSASL.SASL).User := ClientAccount;
         end
         else if xoauthSASL.SASL is TIdSASLXOAuth then
         begin
           TIdSASLXOAuth(xoauthSASL.SASL).Token := OAuth2_Enhanced.AccessToken;
           TIdSASLXOAuth(xoauthSASL.SASL).User := ClientAccount;
         end;
       end;
  end;
  // ***** server


  // connect
  try LSMTP.Connect;
  except on e: Exception do
  begin
    N_Dump1Str( Format( 'Connect Exception ClassName=%s Message=%s',
                                                     [E.ClassName,E.Message]) );

    if E.ClassName = 'EIdOSSLCouldNotLoadSSLLibrary' then
      K_CMShowMessageDlg( 'The secure connection cannot be established as Open SSL is not installed on your PC. Please install Open SSL and repeat the operation.',
                                                                      mtError );
    CMMFRetCode := -1;
    FreeAndNil( LMsg );
    FreeAndNil( LSMTP );
    FreeAndNil( IdSSLIOHandlerSocketOpenSSL1 );
    Exit;
  end;
  end;

  if AuthType = 1 then
    try
      LSMTP.Authenticate;
    except on e: Exception do
    begin
      N_Dump1Str( Format( 'Auth Exception ClassName=%s Message=%s',
                                                       [E.ClassName,E.Message]) );
      CMMFRetCode := -2;
      FreeAndNil( LMsg );
      FreeAndNil( LSMTP );
      FreeAndNil( IdSSLIOHandlerSocketOpenSSL1 );
      Exit;
    end;
    end;
{ // нет этих функций!
  N_Dump1Str( 'Is SSL 2 available? = ' + BoolToStr(IsOpenSSL_SSLv2_Available()));
  N_Dump1Str( 'Is SSL 3 available? = ' + BoolToStr(IsOpenSSL_SSLv3_Available()));
  N_Dump1Str( 'Is SSL 2/3 available? = ' + BoolToStr(IsOpenSSL_SSLv23_Available()));
  N_Dump1Str( 'Is TLS 1.0 available? = ' + BoolToStr(IsOpenSSL_TLSv1_0_Available()));
  N_Dump1Str( 'Is TLS 1.1 available? = ' + BoolToStr(IsOpenSSL_TLSv1_1_Available()));
  N_Dump1Str( 'Is TLS 1.2 available? = ' + BoolToStr(IsOpenSSL_TLSv1_2_Available()));
}
  // send
  try LSMTP.Send( LMsg );
  except on e: Exception do
  begin
    N_Dump1Str( Format( 'Send Exception ClassName=%s Message=%s',
                                                     [E.ClassName,E.Message]) );
    CMMFRetCode := -2;
    FreeAndNil( LMsg );
    FreeAndNil( LSMTP );
    FreeAndNil( IdSSLIOHandlerSocketOpenSSL1 );
    Exit;
  end;
  end;

  CMMFRetCode := 0;

  AddToAddressBook;


  case AuthType of
    0: N_Dump1Str( 'Used SSL/TSL Version = ' +
                          IdSSLIOHandlerSocketOpenSSL1.SSLSocket.Cipher.Version );
    1: N_Dump1Str( 'Used SSL/TSL Version = ' +
                          IdSSLIOHandlerSocketSMTP.SSLSocket.Cipher.Version );
  end;


  // disconnect
  try LSMTP.Disconnect;
  except on e: Exception do
  begin
    N_Dump1Str( Format( 'Disconnect Exception ClassName=%s Message=%s',
                                                     [E.ClassName,E.Message]) );
    FreeAndNil( LMsg );
    FreeAndNil( LSMTP );
    FreeAndNil( IdSSLIOHandlerSocketOpenSSL1 );
    Exit;
  end;
  end;

  // clean
  FreeAndNil( LMsg );
  FreeAndNil( LSMTP );
  FreeAndNil( IdSSLIOHandlerSocketOpenSSL1 );

  N_Dump1Str( 'End mail procedure' );
end;
{$IFEND CompilerVersion >= 18.0}
end; // procedure TN_CMSendMailForm.bnOKClick

//******************************************* TN_CMSendMailForm.DebSendMail ***
// Debug Procedure
//
//     Parameters
// Host - for server
// Port - for server
// UserName - for server
// Password - for server
// ReadTimeout - for server
// Method - for socket
// Mode - for socket
// TLS - for socket
//
// Sends an E-mail, for debug mode
//
procedure TN_CMSendMailForm.DebSendMail( Host, UserName, Password: string;
                                ReadTimeout, Port, Method, Mode, TLS: Integer );
{$IF CompilerVersion >= 18.0} // Delphi >= Delphi 2006
var
  LSMTP:   TIdSMTP;
  LMsg:    TIdMessage;
  IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
  i:       Integer;
{$IFEND CompilerVersion >= 18.0}
begin
{$IF CompilerVersion >= 18.0} // Delphi >= Delphi 2006

  LSMTP := TIdSMTP.Create( nil );
  // ***** message
  LMsg := TIdMessage.Create( LSMTP );
  LMsg.CharSet := 'UTF-8';
  LMsg.Subject := CMMFSubject;
  LMsg.Recipients.EMailAddresses := cbTo.Text;
  LMsg.CCList.EMailAddresses     := cbCopy.Text;
  LMsg.From.Text := UserName;

  N_Dump1Str( 'E-mail parameters, begin' );
  N_Dump1Str( 'E-mail: Sender = ' + LMsg.From.Text );

  // type of a letter
  LMsg.ContentType := 'multipart/mixed; charset=UTF-8';
  LMsg.ContentTransferEncoding := '8bit';

  LMsg.Body      := MemoBody.Lines;
  LMsg.IsEncoded := True;

  // ***** server
  LSMTP.Host     := Host;
  N_Dump1Str( 'E-mail: Server = ' + LSMTP.Host );

  LSMTP.Port     := Port;
  N_Dump1Str( 'E-mail: Port = ' + IntToStr(LSMTP.Port) );

  LSMTP.UserName := UserName;
  N_Dump1Str( 'E-mail: Login = ' + LSMTP.UserName );

  LSMTP.Password := Password;
  //N_Dump1Str( 'Email: Password = ' + LSMTP.Password );

  LSMTP.ReadTimeout := ReadTimeout;
  N_Dump1Str( 'E-mail: Timeout = ' + IntToStr(LSMTP.ReadTimeout) );
  N_Dump1Str( 'E-mail parameters, end' );

  LSMTP.MailAgent := 'CMSuite';

  // ***** ssl socket
  IdSSLIOHandlerSocketOpenSSL1 := TIdSSLIOHandlerSocketOpenSSL.Create( nil );
  IdSSLIOHandlerSocketOpenSSL1.Destination := LSMTP.Host+':' +
                                                         IntToStr( LSMTP.Port );
  IdSSLIOHandlerSocketOpenSSL1.Host := LSMTP.Host;
  IdSSLIOHandlerSocketOpenSSL1.Port := LSMTP.Port;
  IdSSLIOHandlerSocketOpenSSL1.DefaultPort := 0;
  N_Dump1Str( 'E-mail: Method = ' + IntToStr(Method) );
  IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Method := TIdSSLVersion(Method);
  N_Dump1Str( 'E-mail: Mode = ' + IntToStr(Mode) );
  IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Mode   := TIdSSLMode(Mode);

  LSMTP.IOHandler := IdSSLIOHandlerSocketOpenSSL1;

  N_Dump1Str( 'E-mail: TLS = ' + IntToStr(TLS) );
  //if N_MemIniToString( 'CMS_Email', 'TLS', '' ) = 'TRUE' then
    LSMTP.UseTLS := TIdUseTLS(TLS);//utUseImplicitTLS // ssl
  //else
  //  LSMTP.UseTLS := utUseRequireTLS; // tls

  // ***** attachements
  for i := 0 to CMMFAttachments.Count - 1 do
  if FileExists( CMMFAttachments[i] ) then
  begin
    TIdAttachmentFile.Create( LMsg.MessageParts, CMMFAttachments[i] );
  end;

  // connect
  try LSMTP.Connect;
  except on e: Exception do
  begin
    N_Dump1Str( Format( 'Connect Exception ClassName=%s Message=%s',
                                                     [E.ClassName,E.Message]) );
    CMMFRetCode := -1;
    FreeAndNil( LMsg );
    FreeAndNil( LSMTP );
    FreeAndNil( IdSSLIOHandlerSocketOpenSSL1 );
    Exit;
  end;
  end;

  // send
  try LSMTP.Send( LMsg );
  except on e: Exception do
  begin
    N_Dump1Str( Format( 'Send Exception ClassName=%s Message=%s',
                                                     [E.ClassName,E.Message]) );
    CMMFRetCode := -2;
    FreeAndNil( LMsg );
    FreeAndNil( LSMTP );
    FreeAndNil( IdSSLIOHandlerSocketOpenSSL1 );
    Exit;
  end;
  end;

  CMMFRetCode := 0;
  // Add new Address to cbTo.Items
  if ( cbCopy.Text <> '' ) and ( cbTo.Items.IndexOf(cbCopy.Text) < 0 ) then
    cbTo.Items.Insert( 0, cbCopy.Text);

  if ( cbTo.Items.IndexOf(cbTo.Text) < 0 ) then
    cbTo.Items.Insert( 0, cbTo.Text);

  // Save cbTo.Items to Address Book
  N_StringsToMemIni( 'CMS_EmABook', cbTo.Items );


  // disconnect
  try LSMTP.Disconnect;
  except on e: Exception do
  begin
    N_Dump1Str( Format( 'Disconnect Exception ClassName=%s Message=%s',
                                                     [E.ClassName,E.Message]) );
    FreeAndNil( LMsg );
    FreeAndNil( LSMTP );
    FreeAndNil( IdSSLIOHandlerSocketOpenSSL1 );
    Exit;
  end;
  end;

  // clean
  FreeAndNil( LMsg );
  FreeAndNil( LSMTP );
  FreeAndNil( IdSSLIOHandlerSocketOpenSSL1 );

{$IFEND CompilerVersion >= 18.0}
  N_Dump1Str( 'End mail procedure' );
end; // procedure TN_CMSendMailForm.DebSendMail

//****************************************** TN_CMSendMailForm.bnCloseClick ***
// Button "Close" click event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMSendMailForm.bnCloseClick( Sender: TObject );
begin
  inherited;
  Close;
end; // procedure TN_CMSendMailForm.bnCloseClick

//****************************************** TN_CMSendMailForm.AutoSizeGrid ***
// Procedure for autosizing an attachments grid
//
procedure TN_CMSendMailForm.AutoSizeGrid();
var
  x, y, w: integer;
  MaxWidth: integer;
begin
  with StringGrid1 do
    ClientHeight := DefaultRowHeight * RowCount + 5;
    with StringGrid1 do
    begin
      for x := 0 to ColCount - 1 do
      begin
        MaxWidth := 0;
        for y := 0 to RowCount - 1 do
        begin
          w := Canvas.TextWidth( Cells[x,y] );
          if w > MaxWidth then
            MaxWidth := w;
        end;
        ColWidths[x] := MaxWidth + 5;
      end;
    end;
end; // procedure TN_CMSendMailForm.AutoSizeGrid();

//********************************************* TN_CMSendMailForm.FormClose ***
// Close form event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMSendMailForm.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin
  inherited;

  //***** cleaning
  CMMFNewSlide.UDDelete;
  CMMFNewSlide := Nil;
end;

procedure TN_CMSendMailForm.FormCreate(Sender: TObject);
begin
  inherited;

  OAuth2_Enhanced := TEnhancedOAuth2Authenticator.Create(Self);
end;

// procedure TN_CMSendMailForm.FormClose

//********************************************* TN_CMSendMailForm.FormClose ***
// Resize form event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMSendMailForm.FormResize( Sender: TObject );
begin
  inherited;

  AutoSizeGrid();
  // max possible width for names cols
  StringGrid1.ColWidths[0] := StringGrid1.Width - StringGrid1.ColWidths[1] - 5;
  // calculating a grid height
  StringGrid1.Height := cbTotalSize.Top - 5 - StringGrid1.Top; //Height - 300;

  StringGrid1.ScrollBars := ssVertical;
  if ( GetWindowlong( Stringgrid1.Handle, GWL_STYLE ) and WS_VSCROLL ) <> 0 then
  // if there is a visible scrollbar
    StringGrid1.ColWidths[0] := StringGrid1.ColWidths[0] - 18; // resize a grid's width

  //bnOK.Left := BFMinBRPanel.Left div 2 - bnOK.Width div 2; // center a button
end; // procedure TN_CMSendMailForm.FormResize

//********************************************** TN_CMSendMailForm.FormShow ***
// Show form event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMSendMailForm.FormShow( Sender: TObject );
var
  i: Integer;
  TempSize, TotalSize: float;
function GetSize( FileName: string ): Int64; // local, file sizes
var F: TMemoryStream;
begin
  F := nil;
  try
    F := TMemoryStream.Create;
    F.LoadFromFile( FileName );
    Result := F.Size;
  finally
    F.Free;
  end;
end; // function GetSize
begin
  inherited;

  StringGrid1.Row := 1;

  StringGrid1.Cells[ 0, 0 ] := 'Name ';
  StringGrid1.Cells[ 1, 0 ] := 'Size, MB ';

  TotalSize := 0; // total files sizes

  for i := 0 to CMMFAttachments.Count - 1 do
  begin
    if i > 0 then
      StringGrid1.RowCount := StringGrid1.RowCount + 1; // adding a row for a new file
    StringGrid1.Cells[ 0, i+1 ] := ExtractFileName( CMMFAttachments[i] ); // fill a name

    TempSize := ( GetSize( CMMFAttachments[i] ) /1024) /1024; // calc a size in MB
    TotalSize := TempSize + TotalSize; // calc a total size
    StringGrid1.Cells[ 1, i+1 ] := Format( '%.2f', [TempSize] ); // fill a size in MB
  end;

  AutoSizeGrid();
  // max a possible col width
  StringGrid1.ColWidths[0] := StringGrid1.Width - StringGrid1.ColWidths[1] - 5;

  lbSize.Caption := Format( '%.2f', [TotalSize] ) + ' MB'; // fill a total size

  StringGrid1.ScrollBars := ssVertical;
  if ( GetWindowlong( Stringgrid1.Handle, GWL_STYLE ) and WS_VSCROLL ) <> 0 then
  // if scrollbar is visible
    StringGrid1.ColWidths[0] := StringGrid1.ColWidths[0] - 18;

  //bnOK.Left := BFMinBRPanel.Left div 2 - bnOK.Width div 2; // center a button

  DrawPreview();
end; // procedure TN_CMSendMailForm.FormShow

//********************* TN_CMSendMailForm.GetVideoFileInfoFromSampleGrabber ***
// Get an image from a video clip
//
//     Parameters
// AFName - filename
// TN_DIBObj - returned image
//
function TN_CMSendMailForm.GetVideoFileInfoFromSampleGrabber( AFName: string )
                                                                    : TN_DIBObj;
var
  MediaType:        _AMMediaType;
  BitsBufSize, Sec: integer;
  PDIB:             TN_PDIBInfo;
  SampleGrabFilter: IBaseFilter;
  SampleGrabber:    ISampleGrabber;
  Res:              HResult;
  CaptGraphBuilder: ICaptureGraphBuilder2;
  GraphBuilder:     IGraphBuilder;
  MediaControl:     IMediaControl;
  VideoWindow:      IVideoWindow;
  MediaPosition:    IMediaPosition;
  DIBObj:           TN_DIBObj;
  SError:           string;
  GrayColor:  Integer;
  MainBordWidth, BlackBordWidth, WhiteWholesWidth: Integer;
  TmpRect, WhiteRect, ImageRect: TRect;

  procedure DrawWhiteRects( AMode: integer ); // local
  // Draw Horizontal Row of small White Rects (film wholes) in TmpRect
  // AMode=0 - Upper Row, AMode=1 - Lower Row
  begin
    with Result do//, VFInfo, APVFThumbPar^ do
    begin

    if AMode = 0 then // Upper Row
      WhiteRect.Top := TmpRect.Top + MainBordWidth - WhiteWholesWidth - 1
    else //************* Lower Row
      WhiteRect.Top := TmpRect.Top + 1;

    WhiteRect.Bottom := WhiteRect.Top + WhiteWholesWidth - 1;
    WhiteRect.Left   := WhiteWholesWidth div 2;
    WhiteRect.Right  := WhiteRect.Left + WhiteWholesWidth - 1;

    //for i := 0 to TmpRect.Top do // along White Rects, much more then needed
    while WhiteRect.Left < TmpRect.Right do // 'til the end
    begin
      Result.DIBOCanv.DrawPixRoundRect ( WhiteRect, Point(2,2), $FFFFFF, $FFFFFF, 1 );

      Inc( WhiteRect.Left,  2*WhiteWholesWidth );
      Inc( WhiteRect.Right, 2*WhiteWholesWidth );
    end; // for i := 0 to ThumbSize.X do // along White Rects, much more then needed

    end; // with Result, VFInfo, APVFThumbPar^ do
  end; // procedure DrawWhiteRects(); // local

  Label Found;
begin
  Result := Nil; // APVFInfo not given
  Screen.Cursor:= crHourGlass;

  if not FileExists( AFName ) then
  begin
    Exit;
  end;

  CoInitialize( Nil );

   // ***** Create VCOIGraphBuilder - Object for constructing Filter Graph
  GraphBuilder := nil;
  Res := CoCreateInstance(CLSID_FilterGraph, nil, CLSCTX_INPROC_SERVER,
                                           IID_IGraphBuilder, GraphBuilder);
  SError := N_GetDSErrorDescr( Res );
   // if FAILED(Res) then goto Fin;

  // ***** Create VCOICaptGraphBuilder - Object for constructing Capturing Filter Graph
  CaptGraphBuilder := nil;
  Res := CoCreateInstance(CLSID_CaptureGraphBuilder2, nil,
         CLSCTX_INPROC_SERVER, IID_ICaptureGraphBuilder2, CaptGraphBuilder);

  N_Dump1Str('Creating CaptureGraphBuilder2 = '+IntToStr(Res));

  SError := N_GetDSErrorDescr( Res );
  //  if FAILED(Res) then goto Fin;

  Res := GraphBuilder.QueryInterface(IID_IMediaControl, MediaControl);

  N_Dump1Str( 'Creating MediaControl = '+IntToStr(Res) );
  SError := N_GetDSErrorDescr( Res );
   // if FAILED(Res) then goto Fin;

  // Create Sample Grabber Filter
  SampleGrabFilter  := Nil;
  Res := CoCreateInstance( CLSID_SampleGrabber, NIL, CLSCTX_INPROC_SERVER,
                                            IID_IBaseFilter, SampleGrabFilter );

  N_Dump1Str( 'Creating SampleGrabber = '+IntToStr(Res) );
  SError := N_GetDSErrorDescr( Res );
  //  if FAILED(Res) then goto Fin;

  // get ISampleGrabber Interface
  SampleGrabber := Nil;
  Res := SampleGrabFilter.QueryInterface( IID_ISampleGrabber, SampleGrabber );

  N_Dump1Str( 'Creating SampleGrabber parameters = '+IntToStr(Res) );
  SError := N_GetDSErrorDescr( Res );
  //  if FAILED(Res) then goto Fin;

  MediaType.majortype  := MEDIATYPE_Video;
  MediaType.subtype    := MEDIASUBTYPE_RGB24;
  MediaType.formattype := FORMAT_VideoInfo;
  SampleGrabber.SetMediaType( MediaType );

  SampleGrabber.SetOneShot      ( true );
  SampleGrabber.SetBufferSamples( true );

  // add VCOISampleGrabFilter to Filter Graph
  Res := GraphBuilder.AddFilter( SampleGrabFilter, 'Sample Grabber' );

  N_Dump1Str( 'Adding SampleGrabFilter = '+IntToStr(Res) );
  SError := N_GetDSErrorDescr( Res );
   // if FAILED(Res) then goto Fin;

  Res := MediaControl.RenderFile(AFName);

  N_Dump1Str('VCOIMediaControl.RenderFile = '+IntToStr(Res));
  SError := N_GetDSErrorDescr( Res );
  //  if FAILED(Res) then goto Fin;

  VideoWindow := Nil;
  GraphBuilder.QueryInterface( IID_IVideoWindow, VideoWindow );

  Res := VideoWindow.put_Visible( False );
  N_u := Res; // to avoid warnings
  VideoWindow.put_AutoShow      ( False );

  MediaControl.Run();

  // *** Get DIB Info and create empty DIB obj using it
  //ZeroMemory(@MediaType, SizeOf(TAMMediaType));

  Res := SampleGrabber.GetConnectedMediaType( MediaType );

  N_Dump1Str('VCOISampleGrabber.GetConnectedMediaType with no parameters = '
                                                               + IntToStr(Res));
  SError := N_GetDSErrorDescr( Res );

  PDIB := TN_PDIBInfo(@(PVideoInfoHeader(MediaType.pbFormat)^.bmiHeader));

  DIBObj := TN_DIBObj.Create();
  DIBObj.PrepEmptyDIBObj(PDIB);
  BitsBufSize := PDIB.bmi.biSizeImage; // buffer size

  // *** Get BufSize for Sample content for debug
  N_i := 0;

  Sec := 0; // seconds waiting = 0
  SampleGrabber.GetCurrentBuffer( N_i, nil );

  while (N_i = 0) and (Sec <> 50) do // trying to get image for 5 seconds
  begin
    SampleGrabber.GetCurrentBuffer( N_i, nil );
    Sleep( 100 );
    Inc( Sec );
  end;

  N_Dump1Str('GUID: ' + GUIDToString(MediaType.SubType));

  N_i := SampleGrabber.GetCurrentBuffer(BitsBufSize, DIBObj.PRasterBytes);
  N_Dump1Str('VCOISampleGrabber.GetCurrentBuffer actual = ' + IntToStr(N_i));

  MediaControl.Stop();

  GrayColor := $BBBBBB;
  MainBordWidth := Round( 0.01*DIBObj.DIBSize.X*12 );
  BlackBordWidth   := Round( 0.01*DIBObj.DIBSize.X*1 );
  WhiteWholesWidth := Round( 0.01*DIBObj.DIBSize.X*8 );

  Result := TN_DIBObj.Create( DIBObj.DIBSize.X,
                             DIBObj.DIBSize.Y + 2 * MainBordWidth, pf24bit, 0 );

  //***** Draw Upper Horizontal Gray border
  TmpRect := Result.DIBRect;
  TmpRect.Bottom := MainBordWidth - 1;
  Result.DIBOCanv.SetBrushAttribs( GrayColor );
  Result.DIBOCanv.DrawPixFilledRect( TmpRect );
  DrawWhiteRects( 0 );

  //***** Draw Lower Horizontal Gray border
  TmpRect := Result.DIBRect;
  TmpRect.Top  := Result.DIBRect.Bottom - MainBordWidth + 1;
  Result.DIBOCanv.SetBrushAttribs( GrayColor );
  Result.DIBOCanv.DrawPixFilledRect( TmpRect );
  DrawWhiteRects( 1 );

  ImageRect.Left   := BlackBordWidth;
  ImageRect.Top    := MainBordWidth + BlackBordWidth;
  ImageRect.Right  := Result.DIBRect.Right  - BlackBordWidth;
  ImageRect.Bottom := Result.DIBRect.Bottom - MainBordWidth - BlackBordWidth;

  Result.DIBOCanv.DrawPixDIB( DIBObj, ImageRect, Rect( 0, 0, -1, -1) );
  Screen.Cursor:= crDefault;

  if MediaControl <> Nil then
  begin
    MediaControl.Stop();
    N_Dump1Str('After MediaControl.Stop();');
  end;

  //***** cleaning
  SampleGrabber     := nil;
  SampleGrabFilter  := nil;
  VideoWindow       := nil;
  MediaControl      := nil;
  CaptGraphBuilder  := nil;
  GraphBuilder      := nil;
  MediaPosition     := Nil;
  CoUninitialize();
  N_Dump1Str( 'Ending of SampleGrabber usage' );
end; // N_GetVideoFileInfoFromSampleGrabber

//************************************** TN_CMSendMailForm.StringGrid1Click ***
// StringGrid click event
//
//     Parameters
// Sender - sender object
//
procedure TN_CMSendMailForm.StringGrid1Click( Sender: TObject );
var
  VFThumbPar:  TN_VFThumbParams;
begin
  inherited;

  CMMFNewSlide.UDDelete();
  CMMFNewSlide := Nil;

  VFThumbPar.VFTPThumbSize := K_CMSlideThumbSize;
    VFThumbPar.VFTPMainBordWidth    := 12;
    VFThumbPar.VFTPBlackBordWidth   := 1;
    VFThumbPar.VFTPWhiteWholesWidth := 8;

  DrawPreview();
end; // procedure TN_CMSendMailForm.StringGrid1Click

//************************************** TN_CMSendMailForm.StringGrid1Click ***
// Drawind a preview for a chosen image/video
//
procedure TN_CMSendMailForm.DrawPreview();
var
  DIB: TN_DIBObj;
begin
  CMMFNewSlide := Nil; // clean

  //***** create a slide to show a preview
  if ( ExtractFileExt( CMMFAttachments[StringGrid1.Row-1] ) = '.mp4' ) or
     ( ExtractFileExt( CMMFAttachments[StringGrid1.Row-1] ) = '.avi' ) then
  //***** if a video
    DIB := GetVideoFileInfoFromSampleGrabber( CMMFAttachments[StringGrid1.Row
                                                                          - 1] )
  else

  if N_GetFileFmtByExt( CMMFAttachments[StringGrid1.Row-1] ) <> imffUnknown then
  //***** if an image
    DIB := TN_DIBObj.Create( CMMFAttachments[StringGrid1.Row-1] )
  else
    DIB := TN_DIBObj.Create( 164, 124, pfCustom, ColorToRGB(clBtnFace),
                                                                     epfGray8 );
  CMMFNewSlide := K_CMSlideCreateFromDIBObj( DIB, Nil );
  CMMFRootComp := CMMFNewSlide.GetMapRoot();

  //***** show a preview
  with NewRFrame do
  begin
    RFCenterInDst := true;
    RVCTFrInit3( CMMFRootComp );
    RVCTreeRootOwner := false;
    aFitInWindowExecute( nil ); // already previewed
  end;
end;

end.
