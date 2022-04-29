unit N_CMAboutF;
//***** CMS Application About Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, jpeg,
  N_BaseF;

type TN_CMAboutForm = class( TN_BaseForm )
    LbVersion: TLabel;
    BtClose: TButton;
    Image1: TImage;
    Label1: TLabel;
    BuildLabel: TLabel;
    LCopyRight: TLabel;
    ReleaseDateLabel: TLabel;
    GroupBox1: TGroupBox;
    EdPublisher: TEdit;
    GroupBox2: TGroupBox;
    EdFax: TEdit;
    EdEmail: TEdit;
    Label7: TLabel;
    EdInternet: TEdit;
    EdPhone: TEdit;
    GroupBox3: TGroupBox;
    LCredits1: TLabel;
    EdCredits1: TEdit;
    Edit8: TEdit;
    LCredits2: TLabel;
    Edit9: TEdit;
    LCredits4: TLabel;
    Edit10: TEdit;
    LCredits5: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Image2: TImage;
    Edit11: TEdit;
    LCredits3: TLabel;
    EdAddress: TEdit;
    Label15: TLabel;
    Label2: TLabel;
    EdCustomerRefNum: TEdit;
    CNLabel: TLabel;

    procedure FormShow ( Sender: TObject );
  private
    { Private declarations }
  public
    { Public declarations }
end; // type TN_CMAboutForm = class( TN_BaseForm )


implementation

{$R *.dfm}

uses
  K_UDC, K_CLib0, K_UDT2, K_CM0, K_FCMScan, K_CLib,
  N_Lib1, N_Lib2, N_CM1, L_VirtUI;

procedure TN_CMAboutForm.FormShow ( Sender: TObject );
var
  AboutPictFName: string;
  LCreditsFHeight: integer;
  ShowCopyrightFlag : Boolean;
begin
  if K_FormCMScan = nil then
  begin
    Caption := format( Caption, [N_MemIniToString( 'RegionTexts', 'CMSuiteProductName', 'MediaSiute' )] );
    LbVersion.Caption := N_MemIniToString( 'RegionTexts', 'CMSuiteCopyrightName', 'MediaSiute' );
    ShowCopyrightFlag := N_MemIniToBool( 'RegionTexts', 'CMSuiteCopyrightShow', TRUE );
  end
  else
  begin
    Caption := format( Caption, [N_MemIniToString( 'RegionTexts', 'CMScanProductName', 'MediaSiute Scanner' )] );
    LbVersion.Caption := N_MemIniToString( 'RegionTexts', 'CMScanCopyrightName', 'MediaSiute Scanner' );
    ShowCopyrightFlag := N_MemIniToBool( 'RegionTexts', 'CMScanCopyrightShow', TRUE );
  end;

  try
    AboutPictFName := N_MemIniToString( 'Application', 'AboutPictFName1', '' );
//    N_LoadTImage( Image1, AboutPictFName, true );
    K_LoadTImage( Image1, AboutPictFName );
    AboutPictFName := N_MemIniToString( 'Application', 'AboutPictFName2', '' );
//    N_LoadTImage( Image2, AboutPictFName, true );
    K_LoadTImage( Image2, AboutPictFName );
  except end;

  if ShowCopyrightFlag then
  begin
    LCopyRight.Caption := format( LCopyRight.Caption, [FormatDateTime( 'yyyy', Now() ),
                                  N_MemIniToString( 'RegionTexts', 'CompanyCopyrightName', 'Centaur Software' )] );
  end
  else
    LCopyRight.Visible := FALSE;


  BuildLabel.Caption := 'Build ' + N_CMSVersion;

  if K_CMDemoModeFlag then
    BuildLabel.Caption := BuildLabel.Caption  + ' Demo'
  else if not N_MemIniToBool( 'CMS_Main', 'UseExtDB', False ) then
    BuildLabel.Caption := BuildLabel.Caption  + ' NoDB'; // Design mode (without Database)

//  if K_FormCMScan <> nil then
//    BuildLabel.Caption := BuildLabel.Caption  + ' CMScan';

  if (K_FormCMScan = nil) and K_CMShowEnterprise() then
    BuildLabel.Caption := BuildLabel.Caption  + ' Enterprise';

  if K_CMVUIMode then
    BuildLabel.Caption := BuildLabel.Caption  + ' DB' + IntToStr(K_CMEDDBVersion);

  ReleaseDateLabel.Caption := 'Released ' +  N_CMSReleaseDate;

  // Manual Font settings is needed for 150% Large fonts
  LCreditsFHeight := (EdCredits1.Height - 4) div 2; // (28-4)/2 = 12 for normal (100%) DPI
  LCredits1.Font.Height := -LCreditsFHeight;
  LCredits2.Font.Height := -LCreditsFHeight;
  LCredits3.Font.Height := -LCreditsFHeight;
  LCredits4.Font.Height := -LCreditsFHeight;

  //***** Apply Regional Settings

//  EdPublisher.Text := N_CMRegSettingsForm.CompanyName.Caption;
//  EdAddress.Text   := N_CMRegSettingsForm.Address.Caption;
//  EdPhone.Text     := N_CMRegSettingsForm.Phone.Caption;
//  EdFax.Text       := N_CMRegSettingsForm.Fax.Caption;
//  EdEmail.Text     := N_CMRegSettingsForm.Email.Caption;
//  EdInternet.Text  := N_CMRegSettingsForm.Internet.Caption;

  EdPublisher.Text := N_MemIniToString( 'RegionTexts', 'CompanyPublName', 'Centaur Software Development Company' );
  EdAddress.Text   := N_MemIniToString( 'RegionTexts', 'Address', 'PO Box 2313 Strawberry Hills, NSW 2012, Australia' );
  EdPhone.Text     := N_MemIniToString( 'RegionTexts', 'Phone', '+61-2-9213-5000' );
  EdFax.Text       := N_MemIniToString( 'RegionTexts', 'Fax', '' );
  if EdFax.Text = '' then
  begin
    EdFax.Visible := FALSE;
    Label14.Visible := FALSE;
  end;
  EdEmail.Text     := N_MemIniToString( 'RegionTexts', 'Email', 'techsupport@centaursoftware.com' );
  EdInternet.Text  := N_MemIniToString( 'RegionTexts', 'Internet', 'www.centaursoftware.com' );

  EdCustomerRefNum.Text := K_CMGetCustomRefNumber();

  Color := N_MemIniToIntFromHex( 'RegionTexts', 'AboutBGColor', Color );

  if K_CMVUIMode then
    CNLabel.Caption := K_GetComputerName() + ', ScanCompName: ' + VirtUI_ScanName
  else
    CNLabel.Visible := FALSE;

end; // procedure TN_CMAboutForm.FormShow

end.
