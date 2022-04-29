unit K_FCMSASetProvSec;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  N_Types, N_BaseF;

type
  TK_FormCMSASetProvSecurity = class(TN_BaseForm)
    BtOK: TButton;
    BtCancel: TButton;
    ChBStart: TCheckBox;
    ChBCapture: TCheckBox;
    ChBImport: TCheckBox;
    ChBDuplicate: TCheckBox;
    ChBModify: TCheckBox;
    ChBDelete: TCheckBox;
    ChBExport: TCheckBox;
    ChBPrint: TCheckBox;
    ChBEmail: TCheckBox;
    ChBPref: TCheckBox;
    ChBReports: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  K_FormCMSASetProvSecurity: TK_FormCMSASetProvSecurity;

function K_CMSASetPorviderSecurityDlg( var ASecFlags : Integer; AReadOnly : Boolean ) : Boolean;

implementation

uses K_CM0;

{$R *.dfm}

//******************************************** K_CMSASetPorviderSecurityDlg ***
// Set CMS Standalone Provider Security Settings
//
//     Parameters
// APatID    - Patient Code string
// ASecFlags - Security Settings flags
// Result - Returns FALSE if user do not click OK
//
function K_CMSASetPorviderSecurityDlg( var ASecFlags : Integer; AReadOnly : Boolean ) : Boolean;
var
  AccessRights : TK_CMUserAccessRights;
begin
  with TK_FormCMSASetProvSecurity.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

{
type TK_CMUserAccessRights = set of (
  K_uarStart,      // Start MediaSuite
  K_uarCapture,    // Capture Media Objects
  K_uarImport,     // Import Media Objects
  K_uarDuplicate,  // Duplicate Media Objects
  K_uarModify,     // Modify Media Objects
  K_uarDelete,     // Delete Media Objects
  K_uarExport,     // Export Media Objects
  K_uarPrint,      // Print Media Objects
  K_uarEmail,      // Email Media Objects
  K_uarPreferences,// Preferences
  K_uarReports     // Reports
);
    ChBPref: TCheckBox;
    ChBReports: TCheckBox;
}
    AccessRights := TK_CMUserAccessRights( Short(ASecFlags) );
    ChBStart.Checked     := K_uarStart in AccessRights;
    ChBStart.Enabled     := not AReadOnly;

    ChBCapture.Checked   := K_uarCapture in AccessRights;
    ChBCapture.Enabled   := not AReadOnly;

    ChBImport.Checked    := K_uarImport in AccessRights;
    ChBImport.Enabled    := not AReadOnly;

    ChBDuplicate.Checked := K_uarDuplicate in AccessRights;
    ChBDuplicate.Enabled := not AReadOnly;

    ChBModify.Checked    := K_uarModify in AccessRights;
    ChBModify.Enabled    := not AReadOnly;

    ChBDelete.Checked    := K_uarDelete in AccessRights;
    ChBDelete.Enabled    := not AReadOnly;

    ChBExport.Checked    := K_uarExport in AccessRights;
    ChBExport.Enabled    := not AReadOnly;

    ChBPrint.Checked     := K_uarPrint in AccessRights;
    ChBPrint.Enabled     := not AReadOnly;

    ChBEmail.Checked    := K_uarEmail in AccessRights;
    ChBEmail.Enabled    := not AReadOnly;

    ChBPref.Checked      := K_uarPreferences in AccessRights;
    ChBPref.Enabled      := not AReadOnly;

    ChBReports.Checked   := K_uarReports in AccessRights;
    ChBReports.Enabled   := not AReadOnly;

    if AReadOnly then
    begin
      BtCancel.Visible := FALSE;
      BtOK.ModalResult := mrCancel;
    end;

    Result := ShowModal() = mrOK;
    if not Result then Exit;
    AccessRights := [];

    if ChBStart.Checked then
      AccessRights := AccessRights + [K_uarStart];

    if ChBCapture.Checked then
      AccessRights := AccessRights + [K_uarCapture];

    if ChBImport.Checked then
      AccessRights := AccessRights + [K_uarImport];

    if ChBDuplicate.Checked then
      AccessRights := AccessRights + [K_uarDuplicate];

    if ChBModify.Checked then
      AccessRights := AccessRights + [K_uarModify];

    if ChBDelete.Checked then
      AccessRights := AccessRights + [K_uarDelete];

    if ChBExport.Checked then
      AccessRights := AccessRights + [K_uarExport];

    if ChBPrint.Checked then
      AccessRights := AccessRights + [K_uarPrint];

    if ChBEmail.Checked then
      AccessRights := AccessRights + [K_uarEmail];

    if ChBPref.Checked then
      AccessRights := AccessRights + [K_uarPreferences];

    if ChBReports.Checked then
      AccessRights := AccessRights + [K_uarReports];

    ASecFlags := Short(AccessRights);
  end;

end; // K_CMSASetPorviderSecurityDlg

end.
