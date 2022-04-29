unit K_FCMSpecSettingsSetup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, StdCtrls, ActnList, Buttons,
  N_BaseF, N_Types;

type
  TK_FormCMSpecSettings = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    ChBDICOM1: TCheckBox;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMSpecSettings: TK_FormCMSpecSettings;

function  K_CMSpecSettingsSetup( ) : Boolean;

implementation

{$R *.dfm}
uses
K_CM0;

//***************************************************** K_CMSpecSettingsSetup ***
// Set CMS Special Settings Setup
//
function  K_CMSpecSettingsSetup( ) : Boolean;
begin
  with TK_FormCMSpecSettings.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    Result :=  mrOK = ShowModal();
    if Result then
      K_CMGUIDICOMMenuVisFlag := ChBDICOM1.Checked;
  end;
end; // function K_CMSASelectProviderDlg

procedure TK_FormCMSpecSettings.FormShow(Sender: TObject);
begin
  ChBDICOM1.Checked := K_CMGUIDICOMMenuVisFlag;
end;

end.
