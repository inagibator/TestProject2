unit K_FCMImportReverseEnter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls;

type
  TK_FormCMImportReverseEnter = class(TN_BaseForm)
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
  K_FormCMImportReverseEnter: TK_FormCMImportReverseEnter;

  function  K_CMReverseImportConfirmDlg( ) : Boolean;

implementation

{$R *.dfm}

uses DateUtils,
  N_Types, K_CM0, K_CML1F;

function  K_CMReverseImportConfirmDlg( ) : Boolean;
begin

  with TK_FormCMImportReverseEnter.Create(Application) do
  begin
//    BaseFormInit ( nil, '', [fvfCenter] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );

    Image.Picture.Icon.Handle := LoadIcon(0, IDI_EXCLAMATION);

    Result := ShowModal = mrOK;

    if not Result then Exit;
    Result := K_CMDesignModeFlag or
              K_CMCheckMasterLP( EdUserName.Text, EdPassword.Text );
    if not Result then
      K_CMShowMessageDlg( K_CML1Form.LLLWrongNameOrPassword.Caption,
//           ' Wrong user name or password ',
                          mtWarning );

  end;


end;

procedure TK_FormCMImportReverseEnter.FormShow(Sender: TObject);
begin
  EdPassword.SelectAll;
  EdUserName.SetFocus;
end;

procedure TK_FormCMImportReverseEnter.EdUserNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;
  EdPassword.SelectAll;
  EdPassword.SetFocus;
end;

procedure TK_FormCMImportReverseEnter.EdPasswordKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;
  ModalResult := mrOK;
end;

end.
