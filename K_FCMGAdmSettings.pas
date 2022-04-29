unit K_FCMGAdmSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls;

type
  TK_FormCMGAdmSettings = class(TN_BaseForm)
    LbConfirmation: TLabel;
    BtCancel: TButton;
    BtOK: TButton;
    EdUserName: TEdit;
    LbUserName: TLabel;
    Image: TImage;
    LbPassword: TLabel;
    EdPassword: TEdit;
    LbPassword1: TLabel;
    EdPassword1: TEdit;
    procedure FormShow(Sender: TObject);
    procedure EdUserNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EdPasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure EdPassword1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    ShortUserName : string;
    ShortPassword : string;
    WrongPaasword : string;
    procedure CommonInit();
  end;

var
  K_FormCMGAdmSettings: TK_FormCMGAdmSettings;

  function  K_CMGlobAdmSettingsDlg( ) : Boolean;
  function  K_CMWEBAccountSettingsDlg( var ALogin, APassword : string ) : Boolean;

implementation

{$R *.dfm}

uses DateUtils,
  N_Types, N_Lib1,
  K_CM0, K_CML1F;

//************************************************** K_CMGlobAdmSettingsDlg ***
// Global Admin Settings Dialog
//
function  K_CMGlobAdmSettingsDlg( ) : Boolean;
begin

  with TK_FormCMGAdmSettings.Create(Application) do
  begin
//    BaseFormInit ( nil, '', [fvfCenter] );
    CommonInit();
//    ' User name length should not be less than 4 symbols. '
    ShortUserName := K_CML1Form.LLLGASettings1.Caption;
//    ' Password length should not be less than 4 symbols. ',
    ShortPassword := K_CML1Form.LLLGASettings2.Caption;
//    ' Entered password differs from repeated. ',
    WrongPaasword := K_CML1Form.LLLGASettings3.Caption;

    Result := ShowModal = mrOK;

    if not Result then Exit;

    N_StringToMemIni( 'CMS_Main', 'EGALogin', EdUserName.Text );
    N_StringToMemIni( 'CMS_Main', 'EGAPassword', EdPassword.Text );
    // Save Global Context
    TK_CMEDDBAccess(K_CMEDAccess).EDASaveContextsData(
           [K_cmssSkipSlides, K_cmssSkipInstanceBinInfo,
            K_cmssSkipInstanceInfo, K_cmssSkipPatientInfo,
            K_cmssSkipProviderInfo, K_cmssSkipLocationInfo,
            K_cmssSkipExtIniInfo]);
  end;


end; // function  K_CMGlobAdmSettingsDlg

//*********************************************** K_CMWEBAccountSettingsDlg ***
// Global Admin Settings Dialog
//
function  K_CMWEBAccountSettingsDlg( var ALogin, APassword : string ) : Boolean;
begin

  with TK_FormCMGAdmSettings.Create(Application) do
  begin
    CommonInit();
    Caption := 'CMS: WEB account settings';
    ShortUserName := ' Login length should not be less than 4 symbols. ';
    ShortPassword := ' Password length should not be less than 4 symbols. ';
    WrongPaasword := ' Entered password differs from repeated. ';
    LbConfirmation.Caption :=
       'Please enter new login and password (4-16 symbols). Please note they are case sensitive.';
    LbUserName.Caption := 'Login';

    EdUserName.Text := ALogin;
    if APassword <> '' then
    begin
      EdPassword.Text := APassword;
      EdPassword1.Text := APassword;
    end;
    Result := ShowModal = mrOK;

    if not Result then Exit;

    ALogin := EdUserName.Text;
    APassword := EdPassword.Text;
  end;


end; // function  K_CMWEBAccountSettingsDlg

//***************************************** TK_FormCMGAdmSettings.CommonInit***
// Form Common intialization
//
procedure TK_FormCMGAdmSettings.CommonInit;
begin
  BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
  Image.Picture.Icon.Handle := LoadIcon(0, IDI_EXCLAMATION);
end;

//****************************************** TK_FormCMGAdmSettings.FormShow ***
// Form Show
//
//     Parameters
// Sender    - Event Sender
//
// onFormShow Self handler
//
procedure TK_FormCMGAdmSettings.FormShow(Sender: TObject);
begin
  EdPassword.SelectAll;
  EdUserName.SetFocus;
end;

//******************************************** TK_FormCMGAdmSettings.EdUserNameKeyDown ***
// TEdit.EdUserName Key Down
//
//     Parameters
// Sender    - Event Sender
//
// onEdUserNameKeyDown Self handler
//
procedure TK_FormCMGAdmSettings.EdUserNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;
  if (Length(EdUserName.Text) < 4) then
    K_CMShowMessageDlg( ShortUserName, mtWarning )
  else
  begin
    EdPassword.SelectAll;
    EdPassword.SetFocus;
  end;
end; // procedure TK_FormCMGAdmSettings.EdUserNameKeyDown

//******************************************** TK_FormCMGAdmSettings.EdPasswordKeyDown ***
// TEdit.EdPassword Key Down
//
//     Parameters
// Sender    - Event Sender
//
// onEdPasswordKeyDown Self handler
//
procedure TK_FormCMGAdmSettings.EdPasswordKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;
  if (Length(EdPassword.Text) < 4) then
    K_CMShowMessageDlg( ShortPassword, mtWarning )
  else
  begin
    EdPassword1.SelectAll;
    EdPassword1.SetFocus;
  end;
end; // procedure TK_FormCMGAdmSettings.EdPasswordKeyDown

//******************************************** TK_FormCMGAdmSettings.EdPassword1KeyDown ***
// TEdit.EdPassword1 Key Down
//
//     Parameters
// Sender    - Event Sender
//
// onEdPassword1KeyDown Self handler
//
procedure TK_FormCMGAdmSettings.EdPassword1KeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;
  if EdPassword.Text <> EdPassword1.Text then
    K_CMShowMessageDlg( WrongPaasword, mtWarning )
  else
    ModalResult := mrOK;
end; // procedure TK_FormCMGAdmSettings.EdPassword1KeyDown

//******************************************** TK_FormCMGAdmSettings.FormCloseQuery ***
// Form Close Query
//
//     Parameters
// Sender    - Event Sender
//
// onFormCloseQuery Self handler
//
procedure TK_FormCMGAdmSettings.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult <> mrOK then Exit;
{
  if (Length(EdUserName.Text) < 4) or
     (Length(EdPassword.Text) < 4) then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLGASettings4.Caption,
//      ' User name and password length should not be less than 4 symbols. ',
                        mtWarning );
    CanClose := false;
  end
}
  if (Length(EdUserName.Text) < 4) then
  begin
    K_CMShowMessageDlg( ShortUserName, mtWarning );
    CanClose := false;
  end
  else
  if (Length(EdPassword.Text) < 4) then
  begin
    K_CMShowMessageDlg( ShortPassword, mtWarning );
    CanClose := false;
  end
  else
  if EdPassword.Text <> EdPassword1.Text then
  begin
    K_CMShowMessageDlg( WrongPaasword, mtWarning );
    CanClose := false;
  end;
end; // procedure TK_FormCMGAdmSettings.FormCloseQuery

end.
