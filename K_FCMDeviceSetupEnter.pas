unit K_FCMDeviceSetupEnter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls;

type
  TK_FormCMDeviceSetupEnter = class(TN_BaseForm)
    LbConfirmation: TLabel;
    BtCancel: TButton;
    BtOK: TButton;
    EdPassword: TEdit;
    LbPassword: TLabel;
    Image: TImage;
    procedure FormShow(Sender: TObject);
    procedure EdPasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMDeviceSetupEnter: TK_FormCMDeviceSetupEnter;
  function  K_CMDeviceSetupConfirmDlg( ) : Boolean;

implementation

{$R *.dfm}

uses N_Types, K_CLib0, K_CM0, K_CML1F;

function  K_CMDeviceSetupConfirmDlg( ) : Boolean;
begin

  with TK_FormCMDeviceSetupEnter.Create(Application) do
  begin
//    BaseFormInit ( nil, '', [fvfCenter] );
    N_Dump2Str( '!!! Start DeviceSetupConfirmDlg' );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );

    LbConfirmation.Caption := K_CML1Form.LLLDeviceSetup.Caption;
//      ' This area is for advanced users only.'#13#10 +
//      'If you wish to proceed, enter password.';

    Image.Picture.Icon.Handle := LoadIcon(0, IDI_EXCLAMATION);

    Result := ShowModal = mrOK;

    if not Result then Exit;

    Result := K_CMDesignModeFlag or
             ( EdPassword.Text = K_DateTimeToStr( Date(), 'ddmmyy' ) );
    if not Result then
    begin
      N_Dump1Str( '!!! Wrong DeviceSetupEnter password >> ' + EdPassword.Text );
      K_CMShowMessageDlg( K_CML1Form.LLLWrongPassword.Caption,
//          ' Wrong password ',
                          mtWarning, [], TRUE  );
    end;

  end;


end;

procedure TK_FormCMDeviceSetupEnter.FormShow(Sender: TObject);
begin
  EdPassword.SelectAll;
  EdPassword.SetFocus;
end;

procedure TK_FormCMDeviceSetupEnter.EdPasswordKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;
  ModalResult := mrOK;
end;

end.
