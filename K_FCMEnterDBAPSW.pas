unit K_FCMEnterDBAPSW;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls;

type
  TK_FormCMEnterDBAPSW = class(TN_BaseForm)
    LbConfirmation: TLabel;
    BtCancel: TButton;
    BtOK: TButton;
    Image: TImage;
    LbPassword: TLabel;
    EdPassword: TEdit;
    ChBViewPSW: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure EdUserNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EdPasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure EdPassword1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ChBViewPSWClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ShortUserName : string;
    ShortPassword : string;
    WrongPassword : string;
    procedure CommonInit();
  end;

var
  K_FormCMEnterDBAPSW: TK_FormCMEnterDBAPSW;

  function  K_CMEnterDBAPSWDlg( ) : Boolean;

implementation

{$R *.dfm}

uses DateUtils,
  N_Types, N_Lib1,
  K_CM0, K_CML1F;

//************************************************** K_CMGlobAdmSettingsDlg ***
// Global Admin Settings Dialog
//
function  K_CMEnterDBAPSWDlg( ) : Boolean;
begin

  with TK_FormCMEnterDBAPSW.Create(Application) do
  begin
//    BaseFormInit ( nil, '', [fvfCenter] );
    CommonInit();
//    ' User name length should not be less than 4 symbols. '
//    ShortUserName := K_CML1Form.LLLGASettings1.Caption;
//    ' Password length should not be less than 4 symbols. ',
//    ShortPassword := K_CML1Form.LLLGASettings2.Caption;
//    ' Entered password differs from repeated. ',
//    WrongPassword := K_CML1Form.LLLGASettings3.Caption;
    WrongPassword := 'Entered password is empty or contains not proper symbols.';
    EdPassword.Text := K_CMDBAPSW;
    Result := ShowModal = mrOK;

    if not Result then Exit;
    K_CMDBAPSW := EdPassword.Text;
  end;


end; // function  K_CMEnterDBAPSWDlg

//***************************************** TK_FormCMEnterDBAPSW.CommonInit ***
// Form Common intialization
//
procedure TK_FormCMEnterDBAPSW.CommonInit;
begin
  BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
  Image.Picture.Icon.Handle := LoadIcon(0, IDI_EXCLAMATION);
end;

//******************************************* TK_FormCMEnterDBAPSW.FormShow ***
// Form Show
//
//     Parameters
// Sender    - Event Sender
//
// onFormShow Self handler
//
procedure TK_FormCMEnterDBAPSW.FormShow(Sender: TObject);
begin
  EdPassword.SelectAll;
end;

//********************************** TK_FormCMEnterDBAPSW.EdUserNameKeyDown ***
// TEdit.EdUserName Key Down
//
//     Parameters
// Sender    - Event Sender
//
// onEdUserNameKeyDown Self handler
//
procedure TK_FormCMEnterDBAPSW.EdUserNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;
{
  if (Length(EdUserName.Text) < 4) then
    K_CMShowMessageDlg( ShortUserName, mtWarning )
  else
  begin
    EdPassword.SelectAll;
    EdPassword.SetFocus;
  end;
}
end; // procedure TK_FormCMEnterDBAPSW.EdUserNameKeyDown

//********************************** TK_FormCMEnterDBAPSW.EdPasswordKeyDown ***
// TEdit.EdPassword Key Down
//
//     Parameters
// Sender    - Event Sender
//
// onEdPasswordKeyDown Self handler
//
procedure TK_FormCMEnterDBAPSW.EdPasswordKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;
{
  if (Length(EdPassword.Text) < 4) then
    K_CMShowMessageDlg( ShortPassword, mtWarning )
  else
  begin
    EdPassword1.SelectAll;
    EdPassword1.SetFocus;
  end;
}
end; // procedure TK_FormCMEnterDBAPSW.EdPasswordKeyDown

//********************************* TK_FormCMEnterDBAPSW.EdPassword1KeyDown ***
// TEdit.EdPassword1 Key Down
//
//     Parameters
// Sender    - Event Sender
//
// onEdPassword1KeyDown Self handler
//
procedure TK_FormCMEnterDBAPSW.EdPassword1KeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;
{
  if EdPassword.Text <> EdPassword1.Text then
    K_CMShowMessageDlg( WrongPassword, mtWarning )
  else
    ModalResult := mrOK;
}
end; // procedure TK_FormCMEnterDBAPSW.EdPassword1KeyDown

//************************************* TK_FormCMEnterDBAPSW.FormCloseQuery ***
// Form Close Query
//
//     Parameters
// Sender    - Event Sender
//
// onFormCloseQuery Self handler
//
procedure TK_FormCMEnterDBAPSW.FormCloseQuery(Sender: TObject;
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
{
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
    K_CMShowMessageDlg( WrongPassword, mtWarning );
    CanClose := false;
  end;
}
  if (Length(EdPassword.Text) = 0) or
     (pos( ' ', EdPassword.Text) > 0) then
  begin
    K_CMShowMessageDlg( WrongPassword, mtWarning );
    CanClose := false;
  end;

end; // procedure TK_FormCMEnterDBAPSW.FormCloseQuery

procedure TK_FormCMEnterDBAPSW.ChBViewPSWClick(Sender: TObject);
begin
 if ChBViewPSW.Checked then
   EdPassword.PasswordChar := #0
 else
   EdPassword.PasswordChar := '#';
end; // procedure TK_FormCMEnterDBAPSW

end.
