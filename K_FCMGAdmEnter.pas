unit K_FCMGAdmEnter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls;

type
  TK_FormCMGAdmEnter = class(TN_BaseForm)
    LbConfirmation: TLabel;
    BtCancel: TButton;
    BtOK: TButton;
    EdUserName: TEdit;
    LbUserName: TLabel;
    Image: TImage;
    LbPassword: TLabel;
    EdPassword: TEdit;
    procedure FormShow(Sender: TObject);
    procedure EdUserNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EdPasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMGAdmEnter: TK_FormCMGAdmEnter;

  function  K_CMEnterConfirmDlg( const ALogin, APassword : string;
                                 AUncAccess : Boolean = FALSE;
                                 const ACaption : string = '';
                                 AWarning : string = '' ) : Boolean;

  function  K_CMGlobAdmConfirmDlg( const ACaption : string = '' ) : Boolean;

implementation

{$R *.dfm}

uses DateUtils,
  N_Types, N_Lib1,
  K_CM0, K_CML1F;


//******************************************** K_CMEnterConfirmDlg ***
// Global Admin Enter Confirmation Dialog with given Login and password
//
function  K_CMEnterConfirmDlg( const ALogin, APassword : string;
                               AUncAccess : Boolean = FALSE;
                               const ACaption : string = '';
                               AWarning : string = '' ) : Boolean;

begin

  with TK_FormCMGAdmEnter.Create(Application) do
  begin
//    BaseFormInit ( nil, '', [fvfCenter] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    if ACaption <> '' then
      Caption := ACaption;

    Image.Picture.Icon.Handle := LoadIcon(0, IDI_EXCLAMATION);

    Result := ShowModal = mrOK;

    if not Result then Exit;

    if (ALogin = '') or (APassword = '' ) then
      Result := FALSE // 1-st Enter - Only Master Password should be used
    else
      Result := SameText( EdUserName.Text, ALogin ) and
                SameText( EdPassword.Text, APassword );

    if not Result then
      Result := K_CMCheckMasterLP( EdUserName.Text, EdPassword.Text );

    Result := AUncAccess or Result;
//    Result := K_CMDesignModeFlag or Result;
    if not Result then
    begin
      if AWarning = '' then AWarning := K_CML1Form.LLLWrongNameOrPassword.Caption; // ' Wrong user name or password ';
      K_CMShowMessageDlg( AWarning, mtWarning );
    end;
  end;

end; // function  K_CMEnterConfirmDlg

//******************************************** K_CMGlobAdmConfirmDlg ***
// Global Admin Enter Confirmation Dialog w/o parameters
//
function  K_CMGlobAdmConfirmDlg( const ACaption : string = '' ) : Boolean;
var
  FLogin, FPassword : string;
begin
  FLogin := N_MemIniToString( 'CMS_Main', 'EGALogin', '' );
  if FLogin = '' then
    FLogin := N_MemIniToString( 'RegionTexts', 'EGALogin', '' );

  FPassword := N_MemIniToString( 'CMS_Main', 'EGAPassword', '' );
  if FPassword = '' then
    FPassword := N_MemIniToString( 'RegionTexts', 'EGAPassword', '' );

  Result := K_CMEnterConfirmDlg( FLogin, FPassword,
                                 K_CMDesignModeFlag or K_CMDemoModeFlag, ACaption );
end; // function  K_CMGlobAdmConfirmDlg

//******************************************** TK_FormCMGAdmEnter.FormShow ***
// Form Show
//
//     Parameters
// Sender    - Event Sender
//
// onFormShow Self handler
//
procedure TK_FormCMGAdmEnter.FormShow(Sender: TObject);
begin
  EdPassword.SelectAll;
  EdUserName.SetFocus;
end; // procedure TK_FormCMGAdmEnter.FormShow

//******************************************** TK_FormCMGAdmEnter.EdUserNameKeyDown ***
// TEdit.EdUserName Key Down
//
//     Parameters
// Sender    - Event Sender
//
// onEdUserNameKeyDown Self handler
//
procedure TK_FormCMGAdmEnter.EdUserNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;
  EdPassword.SelectAll;
  EdPassword.SetFocus;
end; // procedure TK_FormCMGAdmEnter.EdUserNameKeyDown

//******************************************** TK_FormCMGAdmEnter.EdPasswordKeyDown ***
// TEdit.EdPassword Key Down
//
//     Parameters
// Sender    - Event Sender
//
// onEdPasswordKeyDown Self handler
//
procedure TK_FormCMGAdmEnter.EdPasswordKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;
  ModalResult := mrOK;
end; // procedure TK_FormCMGAdmEnter.EdPasswordKeyDown

end.
