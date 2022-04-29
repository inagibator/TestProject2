unit K_FCMRegCode;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_BaseF;

type
  TK_FormCMRegCode = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    LbEdDBRegCode: TLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure LbEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtOKClick(Sender: TObject);
  private
    { Private declarations }
  public
  end;

var
  K_FormCMRegCode: TK_FormCMRegCode;

function K_CMGetRegCodeDlg( var ARegCode : string ) : Boolean;

implementation

uses N_Types;

{$R *.dfm}

function K_CMGetRegCodeDlg( var ARegCode : string ) : Boolean;
begin
  with TK_FormCMRegCode.Create(Application) do begin
//    BaseFormInit( nil, '', [fvfCenter] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    LbEdDBRegCode.Text := '';
    Result := ShowModal() = mrOK;
    if Result then
      ARegCode := LbEdDBRegCode.Text;
  end;
end;

procedure TK_FormCMRegCode.FormShow( Sender: TObject );
begin
//
end;

procedure TK_FormCMRegCode.LbEditKeyDown( Sender: TObject; var Key: Word;
                                          Shift: TShiftState );
begin
  if Key = VK_Return then BtOKClick(Sender);
end;


procedure TK_FormCMRegCode.BtOKClick( Sender: TObject );
begin
  ModalResult := mrOK
end;

end.
