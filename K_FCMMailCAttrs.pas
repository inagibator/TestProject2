unit K_FCMMailCAttrs;
// CMS mail attributes

// 12.04.16 - added tab order, formated

// 12.05.16 - new options for ssl/tls

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ExtCtrls, StdCtrls, Vcl.ComCtrls, OAuth2, NetUtils,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer,
  IdHTTPServer, IdContext, Winapi.ShellAPI, IPPeerClient;

type
  TK_FormMailCommonAttrs = class ( TN_BaseForm )
    ChBUseDefaultEmailClient:  TCheckBox;
    pcAuthType: TPageControl;
    tsBasicAuth: TTabSheet;
    OAuth2: TTabSheet;
    GBSelfEmailClientSettings: TGroupBox;
    LEdServer: TLabeledEdit;
    LEdPort: TLabeledEdit;
    LEdTimeout: TLabeledEdit;
    LEdSender: TLabeledEdit;
    LEdPassword: TLabeledEdit;
    LEdLogin: TLabeledEdit;
    rbSSL: TRadioButton;
    rbTLS: TRadioButton;
    pnlBottom: TPanel;
    BtCancel: TButton;
    BtOK: TButton;
    ChBUseCommonSettings: TCheckBox;
    cbProvider: TComboBox;
    lblProvider: TLabel;
    lblEmail: TLabel;
    edtEmail: TEdit;
    btnAuth: TButton;
    IdHTTPServer1: TIdHTTPServer;

    procedure ChBUseDefaultEmailClientClick ( Sender: TObject );
    procedure LEdPortChange                 ( Sender: TObject );
    procedure LEdTimeoutChange              ( Sender: TObject );
    procedure ChBUseCommonSettingsClick     ( Sender: TObject );
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure edtEmailChange(Sender: TObject);
    procedure cbProviderChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAuthClick(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  private
    { Private declarations }
    IPort:    Integer;
    DTimeout: Double;
    procedure InitControls       ( ASL: TStrings );
    procedure GetValuesToStrings ( ASL: TStrings );
  private
    OAuth2_Enhanced : TEnhancedOAuth2Authenticator;
    procedure SetupAuthenticator;
  private
    OAuth2Settings: TStrings;
    FMailSettings: TStrings;
  public
    { Public declarations }
end;

var
  K_FormMailCommonAttrs: TK_FormMailCommonAttrs;

procedure K_CMEmailSettingsCreateEditContext ( out ASL : TStrings;
                                                  out AUseCSettings : Boolean );
procedure K_CMEmailSettingsSaveContext       ( ASL : TStrings; AUseCSettings:
                                                                      Boolean );
function  K_CMEmailSettingsDlg1              ( ASL : TStrings; var
                                             AUseCSettings: Boolean ) : Boolean;
function  K_CMEmailSettingsDlg               (): Boolean;

implementation

{$R *.dfm}

uses N_Types, N_Lib0, N_Lib1,
K_CLib0, K_CM0;

//*************************************************** K_CMEmailSettingsDlg1 ***
//
//
//     Parameters
// ASL -
// AUseCSettings -
// Result -
//
function K_CMEmailSettingsDlg1( ASL : TStrings; var AUseCSettings : Boolean ):
                                                                        Boolean;
begin
  K_FormMailCommonAttrs := TK_FormMailCommonAttrs.Create( Application );
  with K_FormMailCommonAttrs do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
    // MemIni to Cur State
    InitControls( ASL );
    FMailSettings := ASL;

    ChBUseCommonSettings.Visible := not K_CMGAModeFlag;
    if not K_CMVUIMode then
    begin
      if ChBUseCommonSettings.Visible then
        ChBUseCommonSettings.Checked := AUseCSettings;                 ////Igor 08092019
    end
    else
    begin
      ChBUseCommonSettings.Enabled := FALSE;
      ChBUseDefaultEmailClient.Enabled := FALSE;
    end;

    Result := ShowModal() = mrOK;

    if Result then
    begin
    // Cur State to MemIni
      GetValuesToStrings( ASL );
      if ChBUseCommonSettings.Visible then  // Edit Local Settings
        AUseCSettings := ChBUseCommonSettings.Checked;
    end; // if Result then
  end; // with K_FormMailCommonAttrs do

end; // function K_CMEmailSettingsDlg1

//************************************** K_CMEmailSettingsCreateEditContext ***
//
//
//     Parameters
// ASL -
// AUseCSettings -
//
procedure K_CMEmailSettingsCreateEditContext( out ASL : TStrings;
                                                  out AUseCSettings : Boolean );
begin
  ASL := TStringList.Create;
  if K_CMGAModeFlag then
    N_CurMemIni.ReadSectionValues( 'GCMS_Email', ASL )
  else
    N_CurMemIni.ReadSectionValues( 'CMS_Email', ASL );

  AUseCSettings := not N_MemIniToBool( 'CMS_Main', 'UseEMailLocalSettings',
                                                                        FALSE );
end; // procedure K_CMEmailSettingsCreateEditContext

//******************************************** K_CMEmailSettingsSaveContext ***
//
//
//     Parameters
// ASL -
// AUseCSettings -
//
procedure K_CMEmailSettingsSaveContext( ASL : TStrings; AUseCSettings:
                                                                      Boolean );
var
  SectionName : string;
begin
  if not K_CMGAModeFlag then  // Edit Local Settings
  begin // Local Setting Edidting
    SectionName := 'CMS_Email';
    N_BoolToMemIni( 'CMS_Main', 'UseEMailLocalSettings', not AUseCSettings );
  end   // Local Setting Edidting
  else
  begin // Common Setting Edidting
    SectionName := 'GCMS_Email';
    if AUseCSettings then // Save Common Settings to Local
    begin
      N_CurMemIni.EraseSection( 'CMS_Email' );
      K_AddStringsToMemIniSection( N_CurMemIni, 'CMS_Email', ASL );
    end;
  end;  // Common Setting Edidting

  N_CurMemIni.EraseSection( SectionName );
  K_AddStringsToMemIniSection( N_CurMemIni, SectionName, ASL );
end; // procedure K_CMEmailSettingsSaveAndFreeContext

//**************************************************** K_CMEmailSettingsDlg ***
//
//     Parameters
// Result -
//
function K_CMEmailSettingsDlg(): Boolean;
var
  SL: TStrings;
  UseCommonSettings: Boolean;
begin
  K_CMEmailSettingsCreateEditContext( SL, UseCommonSettings );
  Result := K_CMEmailSettingsDlg1( SL, UseCommonSettings );

  if Result then
    K_CMEmailSettingsSaveContext( SL, UseCommonSettings );
  SL.Free;
end; // function K_CMEmailSettingsDlg()
{
function K_CMEmailSettingsDlg() : Boolean;
var
  SL : TStringList;
  SectionName : string;
begin
  K_FormMailCommonAttrs := TK_FormMailCommonAttrs.Create(Application);
  with K_FormMailCommonAttrs do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR, rspfShiftAll] );
    // MemIni to Cur State
    SL := TStringList.Create;

    if K_CMGAModeFlag then
      SectionName := 'GCMS_Email'
    else
      SectionName := 'CMS_Email';

    N_CurMemIni.ReadSectionValues( SectionName, SL );
    InitControls( SL );

    ChBUseCommonSettings.Visible := not K_CMGAModeFlag;
    if ChBUseCommonSettings.Visible then
      ChBUseCommonSettings.Checked := not N_MemIniToBool( 'CMS_Main', 'UseEMailLocalSettings', FALSE );

    Result := ShowModal() = mrOK;

    if Result then
    begin
    // Cur State to MemIni
      GetValuesToStrings( SL );
      N_CurMemIni.EraseSection( SectionName );
      K_AddStringsToMemIniSection( N_CurMemIni, SectionName, SL );
      if ChBUseCommonSettings.Visible then  // Edit Local Settings
        N_BoolToMemIni( 'CMS_Main', 'UseEMailLocalSettings', not ChBUseCommonSettings.Checked )
      else
      if N_MemIniToBool( 'CMS_Main', 'UseEMailLocalSettings', FALSE ) then // Save Common Settings to Local
        K_AddStringsToMemIniSection( N_CurMemIni, 'CMS_Email', SL );
    end; // if ShowModal() = mrOK then

    SL.Free;

  end;

end;
}

//******************** TK_FormMailCommonAttrs.ChBUseDefaultEmailClientClick ***
//
//
//     Parameters
// Sender - a sender object
//
procedure TK_FormMailCommonAttrs.ChBUseDefaultEmailClientClick( Sender:
                                                                      TObject );
begin
  if not K_CMVUIMode then
    GBSelfEmailClientSettings.Enabled := not ChBUseDefaultEmailClient.Checked and
                         ( K_CMGAModeFlag or not ChBUseCommonSettings.Checked );
  LEdServer.Enabled   := GBSelfEmailClientSettings.Enabled;
  LEdPort.Enabled     := GBSelfEmailClientSettings.Enabled;
  LEdTimeout.Enabled  := GBSelfEmailClientSettings.Enabled;
  LEdLogin.Enabled    := GBSelfEmailClientSettings.Enabled;
  LEdPassword.Enabled := GBSelfEmailClientSettings.Enabled;
  LEdSender.Enabled   := GBSelfEmailClientSettings.Enabled;
  rbSSL.Enabled       := GBSelfEmailClientSettings.Enabled;
  rbTLS.Enabled       := GBSelfEmailClientSettings.Enabled;
  pcAuthType.Enabled := GBSelfEmailClientSettings.Enabled;
end;

procedure TK_FormMailCommonAttrs.edtEmailChange(Sender: TObject);
var
  i: integer;
begin
  inherited;

  if not SameText(OAuth2Settings.Values[Providers[cbProvider.ItemIndex].AuthName + 'ClientID'], edtEmail.Text) then
    OAuth2Settings.Values[Providers[cbProvider.ItemIndex].AuthName + 'Token'] := '';

  i := OAuth2Settings.IndexOfName(Providers[cbProvider.ItemIndex].AuthName + 'ClientID');

  if i = -1 then
    OAuth2Settings.Add(Providers[cbProvider.ItemIndex].AuthName + 'ClientID=' + Trim(edtEmail.Text))
  else
    OAuth2Settings.ValueFromIndex[i] := Trim(edtEmail.Text);

  SetupAuthenticator;

  btnAuth.Enabled := Length(Trim(edtEmail.Text)) <> 0;
end;

procedure TK_FormMailCommonAttrs.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  i: integer;
  LCode: string;
  LURL : TURI;
  LTokenName : string;
begin
  inherited;

  if (ARequestInfo.QueryParams = '') OR
     (Pos('code=', ARequestInfo.QueryParams) = 0) then
  begin
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentText := 'Authentication failed';
    Exit;
  end;

  LURL := TURI.Create('https://localhost/?' + ARequestInfo.QueryParams);
  try
    LCode := LURL.ParameterByName['code'];
  except
    Exit;
  end;


  OAuth2_Enhanced.AuthCode := LCode;
  OAuth2_Enhanced.ChangeAuthCodeToAccesToken;
  LTokenName := Providers[cbProvider.ItemIndex].AuthName + 'Token';

  i := OAuth2Settings.IndexOfName(LTokenName);

  if i = -1 then
    OAuth2Settings.Add(LTokenName + '=' + OAuth2_Enhanced.RefreshToken)
  else
    OAuth2Settings.ValueFromIndex[i] := OAuth2_Enhanced.RefreshToken;

  SetupAuthenticator;

  AResponseInfo.ResponseNo := 200;
  AResponseInfo.ContentText := 'Please return to CMSuite';

  i := OAuth2Settings.IndexOfName(Providers[cbProvider.ItemIndex].AuthName + 'ClientID');

  if i = -1 then
    OAuth2Settings.Add(Providers[cbProvider.ItemIndex].AuthName + 'ClientID=' + Trim(edtEmail.Text))
  else
    OAuth2Settings.ValueFromIndex[i] := Trim(edtEmail.Text);
end;

procedure TK_FormMailCommonAttrs.InitControls( ASL: TStrings );
var
  i: integer;
  N : Integer;
begin
  pcAuthType.ActivePageIndex := StrToIntDef(ASL.Values['AuthType'], 0);
  cbProvider.ItemIndex := StrToIntDef(ASL.Values['Provider'], 0);

  for i := 0 to Length(Providers) - 1 do
  begin
    OAuth2Settings.Add(Providers[i].AuthName + 'ClientID=' +
                       ASL.Values[Providers[i].AuthName + 'ClientID']);
    OAuth2Settings.Add(Providers[i].AuthName + 'Token=' +
                       ASL.Values[Providers[i].AuthName + 'Token']);
  end;

  edtEmail.Text := OAuth2Settings.Values[Providers[cbProvider.ItemIndex].AuthName + 'ClientID'];

  SetupAuthenticator;

    // MemIni to Cur State
    LEdServer.Text := ASL.Values['Server'];
    LEdPort.Text   := ASL.Values['Port'];
    if LEdPort.Text <> '' then
      IPort := StrToIntDef( LEdPort.Text, 0 );
    N := StrToIntDef( ASL.Values['Timeout'], 60000 );
    LEdTimeout.Text := '';
    DTimeout := 0;

    if N > 0 then
    begin
      LEdTimeout.Text := FloatToStr( N / 1000 );
      DTimeout := StrToFloat( LEdTimeout.Text );
    end;

//    if LEdTimeout.Text <> '' then
//      DTimeout := StrToFloatDef( LEdTimeout.Text, 0 );
    LEdLogin.Text    := ASL.Values['Login'];
    LEdPassword.Text := ASL.Values['Password'];
    LEdSender.Text   := ASL.Values['Sender'];
    if not K_CMVUIMode then
      ChBUseDefaultEmailClient.Checked := not N_S2B( ASL.Values['SelfEmailClient'] );

    rbTLS.Checked    := N_S2B( ASL.Values['TLS'] );
end; // procedure TK_FormMailCommonAttrs.InitControls

//******************************* TK_FormMailCommonAttrs.GetValuesToStrings ***
//
//
//     Parameters
// ASL -
//
procedure TK_FormMailCommonAttrs.GetValuesToStrings( ASL: TStrings );
var
 i: integer;
begin
  ASL.Clear;
  if IPort    = 0 then LEdPort.Text    := '';
  if DTimeout = 0 then LEdTimeout.Text := '';

  if not ChBUseDefaultEmailClient.Checked then
    ASL.Add( 'SelfEmailClient=TRUE' );

  ASL.Add('AuthType=' + pcAuthType.ActivePageIndex.ToString);

  if pcAuthType.ActivePageIndex = 0 then
  begin
    if LEdServer.Text <> '' then
      ASL.Add( 'Server=' + Trim(LEdServer.Text) );
    if LEdPort.Text <> '' then
      ASL.Add( 'Port=' + LEdPort.Text );
    if LEdTimeout.Text <> '' then
      ASL.Add( 'Timeout=' + IntToStr( Round(DTimeout * 1000) ) )
    else
      ASL.Add( 'Timeout=' + IntToStr(0) );
    if LEdLogin.Text <> '' then
      ASL.Add( 'Login=' + Trim(LEdLogin.Text) );
    if LEdPassword.Text <> '' then
      ASL.Add( 'Password=' + Trim(LEdPassword.Text) );
    if LEdSender.Text <> '' then
      ASL.Add( 'Sender=' + Trim(LEdSender.Text) );
  end
  else
  begin
    ASL.Add('Provider=' + cbProvider.ItemIndex.ToString);
    ASL.AddStrings(OAuth2Settings);
    {for i := 0 to cbProvider.Items.Count - 1 do
    begin
      ASL.Add(Providers[i].AuthName + 'ClientID=' + edtEmail.Text);

      if not SameText(ASL.Values[Providers[i].AuthName + 'Token'], AccessTokens[i]) then
        ASL.Add(Providers[i].AuthName + 'Token=' + AccessTokens[cbProvider.ItemIndex]);
    end;}
  end;

  if rbTLS.Checked then
    ASL.Add( 'TLS=TRUE' )
  else
    ASL.Add( 'TLS=FALSE' );
end; // procedure TK_FormMailCommonAttrs.GetValuesToStrings

//************************************ TK_FormMailCommonAttrs.LEdPortChange ***
//
//
//     Parameters
// Sender - a sender object
//
procedure TK_FormMailCommonAttrs.LEdPortChange( Sender: TObject );
begin
  LEdPort.Text := K_ChangeIntValByStrVal( IPort, LEdPort.Text );
end; // procedure TK_FormMailCommonAttrs.LEdPortChange

//********************************* TK_FormMailCommonAttrs.LEdTimeoutChange ***
//
//
//     Parameters
// Sender - a sender object
//
procedure TK_FormMailCommonAttrs.LEdTimeoutChange( Sender: TObject );
begin
  LEdTimeout.Text := K_ChangeFloatValByStrVal( DTimeout, LEdTimeout.Text )
end;

procedure TK_FormMailCommonAttrs.SetupAuthenticator;
var
  LClientIDName: string;
  LTokenName: string;
begin
  OAuth2_Enhanced.ClientID := Providers[cbProvider.ItemIndex].ClientID;
  OAuth2_Enhanced.ClientSecret := Providers[cbProvider.ItemIndex].Clientsecret;
  OAuth2_Enhanced.Scope := Providers[cbProvider.ItemIndex].Scopes;
  OAuth2_Enhanced.RedirectionEndpoint := clientredirect;
  OAuth2_Enhanced.AuthorizationEndpoint := Providers[cbProvider.ItemIndex].AuthorizationEndpoint;
  OAuth2_Enhanced.AccessTokenEndpoint := Providers[cbProvider.ItemIndex].AccessTokenEndpoint;

  LClientIDName := Providers[cbProvider.ItemIndex].AuthName + 'ClientID';
  LTokenName := Providers[cbProvider.ItemIndex].AuthName + 'Token';

  OAuth2_Enhanced.RefreshToken :=  OAuth2Settings.Values[LTokenName];

  if OAuth2Settings.Values[LClientIDName].IsEmpty OR
     OAuth2Settings.Values[LTokenName].IsEmpty then
  begin
    edtEmail.Enabled := True;
    btnAuth.Caption := 'Authenticate';
    btnAuth.Tag := 0;
  end
  else
  begin
    edtEmail.Enabled := False;
    btnAuth.Caption := 'Clear auth';
    btnAuth.Tag := 1;
  end;
end;

// procedure TK_FormMailCommonAttrs.LEdTimeoutChange


procedure TK_FormMailCommonAttrs.btnAuthClick(Sender: TObject);
var
  URI: TURI;
begin
  inherited;

  if btnAuth.Tag = 0 then
  begin
    uri := TURI.Create(OAuth2_Enhanced.AuthorizationRequestURI);
    if cbProvider.ItemIndex = 0 then
      uri.AddParameter('access_type', 'offline');  // For Google to get refresh_token

    ShellExecute(Handle,
      'open',
      PChar(uri.ToString),
      nil,
      nil,
      0
    );
  end
  else
  begin
    OAuth2Settings.Values[Providers[cbProvider.ItemIndex].AuthName + 'Token'] := '';
    SetupAuthenticator;
  end;
end;

procedure TK_FormMailCommonAttrs.cbProviderChange(Sender: TObject);
begin
  inherited;

  if Assigned(OAuth2Settings) then
    if OAuth2Settings.IndexOfName(Providers[cbProvider.ItemIndex].AuthName + 'ClientID') <> -1 then
      edtEmail.Text := OAuth2Settings.Values[Providers[cbProvider.ItemIndex].AuthName + 'ClientID']
    else
      edtEmail.Text := '';

    edtEmailChange(edtEmail);
end;

//************************ TK_FormMailCommonAttrs.ChBUseCommonSettingsClick ***
//
//
//     Parameters
// Sender - a sender object
//
procedure TK_FormMailCommonAttrs.ChBUseCommonSettingsClick( Sender: TObject );
var
  SL : TStringList;
begin
  if not K_CMVUIMode then
    ChBUseDefaultEmailClient.Enabled := not ChBUseCommonSettings.Checked;          /////Igor 08092019

  if ChBUseCommonSettings.Checked then
  begin
    SL := TStringList.Create;
    N_CurMemIni.ReadSectionValues( 'GCMS_Email', SL );
    InitControls( SL );
    SL.Free;
  end;

  ChBUseDefaultEmailClientClick( ChBUseDefaultEmailClient );
end; // procedure TK_FormMailCommonAttrs.ChBUseCommonSettingsClick

//*********************************** TK_FormMailCommonAttrs.FormCloseQuery ***
//
//
//     Parameters
// Sender - a sender object
//
procedure TK_FormMailCommonAttrs.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := ChBUseDefaultEmailClient.Checked or
              ( (pcAuthType.ActivePageIndex = 0) AND
                (Trim(LEdServer.Text)   <> '') and
                (Trim(LEdLogin.Text)    <> '') and
                (Trim(LEdPassword.Text) <> '') and
                (Trim(LEdSender.Text)   <> '') ) OR
              ( (pcAuthType.ActivePageIndex = 1) AND
                (not edtEmail.Enabled));

  if not CanClose then
  begin
    CanClose := mrYes = K_CMShowMessageDlg(
         'The settings are not completed. The email won''t work. Would you like to close the Email settings anyway?',
                                         mtConfirmation );
    if not CanClose then Exit;
    N_Dump1Str( 'Mail Settings are not completed' );
  end;
end;

procedure TK_FormMailCommonAttrs.FormCreate(Sender: TObject);
begin
  inherited;

  OAuth2_Enhanced := TEnhancedOAuth2Authenticator.Create(Self);
  OAuth2Settings := TStringList.Create;
end;

procedure TK_FormMailCommonAttrs.FormDestroy(Sender: TObject);
begin
  inherited;
  FreeAndNil(OAuth2Settings);
end;

// procedure TK_FormMailCommonAttrs.FormCloseQuery

end.
