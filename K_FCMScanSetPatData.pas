unit K_FCMScanSetPatData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_BaseF;

type
  TK_FormCMScanSetPatData = class(TN_BaseForm)
    BtOK: TButton;
    LbESurname: TLabeledEdit;
    LbEFirstname: TLabeledEdit;
    BtCancel: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMScanSetPatData: TK_FormCMScanSetPatData;

function K_CMScanPatientDataDlg( var ASurname, AFirstname : string ) : Boolean;

implementation

uses K_CM0, K_CML1F,
N_Types;

{$R *.dfm}

//************************************************ K_CMSASetProviderDataDlg ***
// Set CMS Standalone Location Data Dialog
//
//     Parameters
// ASurname   - Patient Surname
// AFirstname - Patient First name
// Result - Returns FALSE if user do not click OK
//
function  K_CMScanPatientDataDlg( var ASurname, AFirstname : string ) : Boolean;
begin

  with TK_FormCMScanSetPatData.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    LbESurname.Text   := ASurname;
    LbEFirstname.Text := AFirstname;

    Result := mrOK = ShowModal();

    if not Result then Exit;

    ASurname   := LbESurname.Text;
    AFirstname := LbEFirstname.Text;

  end; // with TK_FormCMSASetLocationData.Create( Application ) do
end; // function  K_CMSASetLocationDataDlg

procedure TK_FormCMScanSetPatData.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult <> mrOK then Exit;
  CanClose := (LbESurname.Text <> '') or (LbEFirstname.Text <> '');
  if CanClose then Exit;
  K_CMShowMessageDlg( 'You should specify patient details!', mtWarning );

end;

end.
