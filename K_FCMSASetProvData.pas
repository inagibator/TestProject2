unit K_FCMSASetProvData;

interface

uses
  SysUtils, Forms, ComCtrls, StdCtrls, ExtCtrls, Controls, Classes,
  K_CM0,
  N_BaseF, N_Types;

type
  TK_FormCMSASetProviderData = class(TN_BaseForm)
    BtOK: TButton;
    BtCancel: TButton;
    LbTitle: TLabel;
    CmBTitle: TComboBox;
    LbESurname: TLabeledEdit;
    LbEFirstname: TLabeledEdit;
    LbEMiddle: TLabeledEdit;
    BtWEBAccount: TButton;
    BtSecurity: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure LbESurnameExit(Sender: TObject);
    procedure LbESurnameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtWEBAccountClick(Sender: TObject);
    procedure BtSecurityClick(Sender: TObject);
  private
    { Private declarations }
    Login, Password, EncLP, PrevEncLP : string;
    ProvSID : string;
    SecurityFlags : Integer;
    ReadOnly : Boolean;
  public
    { Public declarations }
  end;

var
  K_FormCMSASetProviderData: TK_FormCMSASetProviderData;

function  K_CMSASetProviderDataDlg( const AProvID : string;
                    APCMSAProviderDBData : TK_PCMSAProviderDBData;
                    AWEBAccountOnly : Boolean = FALSE ) : Boolean;

implementation

{$R *.dfm}
uses Windows, DateUtils, Dialogs,
N_Lib0,
K_CLib0, K_CML1F, K_FCMGAdmSettings, K_FCMSASetProvSec;

//************************************************ K_CMSASetProviderDataDlg ***
// Set CMS Standalone Provider Data Dialog
//
//     Parameters
// AProvID - Provider Code string
// APCMSAProviderDBData - Provider Data
// Result - Returns FALSE if user do not click OK
//
function  K_CMSASetProviderDataDlg( const AProvID : string;
                    APCMSAProviderDBData : TK_PCMSAProviderDBData;
                    AWEBAccountOnly : Boolean = FALSE ) : Boolean;
var
  ShowWEB : Boolean;
  SL : TStringList;
begin

  with TK_FormCMSASetProviderData.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ProvSID := AProvID;
    if ProvSID = '' then
    begin
      Caption := K_CML1Form.LLLSelProv11.Caption; // 'New Dentist';
      ReadOnly := FALSE;
//      APCMSAProviderDBData.AUIsLocked := TRUE;
    end
    else
    begin
      Caption := K_CML1Form.LLLSelProv12.Caption; // 'Modify Dentist';
      if APCMSAProviderDBData.AUIsPMSSync then
        Caption := K_CML1Form.LLLSelProv13.Caption; // 'Dentist details';
      ReadOnly := not APCMSAProviderDBData.AUIsLocked or
                  (K_CMStandaloneMode = K_cmsaLink)   or
                  AWEBAccountOnly                     or
                  (APCMSAProviderDBData.AUIsPMSSync and
                   (K_CMStandaloneMode = K_cmsaHybrid))
    end;

    with CmBTitle do // 0
    begin
      if Items[Items.Count - 1] <> '' then
        Items.Add( '' );
      ItemIndex := Items.IndexOf( APCMSAProviderDBData.AUTitle );
    end;
    CmBTitle.Enabled := not ReadOnly;
    LbTitle.Enabled := not ReadOnly;

    LbESurname.Text := APCMSAProviderDBData.AUSurname;
    LbESurname.Enabled := not ReadOnly;

    LbEFirstname.Text := APCMSAProviderDBData.AUFirstname;
    LbEFirstname.Enabled := not ReadOnly;

    LbEMiddle.Text := APCMSAProviderDBData.AUMiddle;
    LbEMiddle.Enabled := not ReadOnly;



    ShowWEB :=  not (limdCMWEB in K_CMSLiRegModDisable) and
                K_CMGAModeFlag  and (K_CMEDDBVersion >= 31); //

    BtWEBAccount.Visible := ShowWEB and
                            (not ReadOnly or AWEBAccountOnly);
    BtWEBAccount.Enabled := BtWEBAccount.Visible and APCMSAProviderDBData.AUIsLocked;

    BtOK.Visible := not ReadOnly or BtWEBAccount.Enabled;
    if not BtOK.Visible then
      BtCancel.Caption := BtOk.Caption; //'&OK';


    if ShowWEB and (APCMSAProviderDBData.AUEncodeLP <> '') then
    begin
      SL := TStringList.Create;
      PrevEncLP := APCMSAProviderDBData.AUEncodeLP;
      SL.Text := K_DecodeLogin(APCMSAProviderDBData.AUEncodeLP);
      if SL.Count >= 1 then
        Login := SL[0];
      if SL.Count >= 2 then
        Password := SL[1];
      SL.Free;
    end;

    BtSecurity.Visible := K_CMGAModeFlag;
    BtSecurity.Enabled := not AWEBAccountOnly;
    
    SecurityFlags := StrToIntDef( APCMSAProviderDBData.AUAuthorities, 2047 );

    Result := ShowModal() = mrOK;
    if not Result then Exit;

    APCMSAProviderDBData.AUTitle       := CmBTitle.Text;
    APCMSAProviderDBData.AUSurname     := LbESurname.Text;
    APCMSAProviderDBData.AUFirstname   := LbEFirstname.Text;
    APCMSAProviderDBData.AUMiddle      := LbEMiddle.Text;
    APCMSAProviderDBData.AUAuthorities := IntToStr(SecurityFlags);

    // Login/Password
    if EncLP <> '' then // Set New EncLP
      APCMSAProviderDBData.AUEncodeLP := EncLP;

    if AProvID = IntToStr(K_CMEDAccess.CurProvID) then
      Short(K_CMCurUserAccessRights) := SecurityFlags;

  end; // with TK_FormCMSASetProviderData.Create( Application ) do

end; // function  K_CMSASetProviderDataDlg

//***************************************************** TK_FormCMSASetProviderData.FormCloseQuery ***
// FormCloseQuery Event Handler
//
procedure TK_FormCMSASetProviderData.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := (ModalResult <> mrOK) or
            (LbESurname.Text <> '') and
            (LbEFirstname.Text <> '');
  if CanClose then Exit;
  if LbESurname.Text = '' then
  begin
    K_CMShowMessageDlg1( K_CML1Form.LLLSetFIO1.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//      'Please enter Surname. Press OK to continue.',
                         mtWarning, [mbOK] );
    ActiveControl := LbESurname;
    Exit;
  end;
  K_CMShowMessageDlg1( K_CML1Form.LLLSetFIO2.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//  'Please enter First name. Press OK to continue.',
                       mtWarning, [mbOK] );
  ActiveControl := LbEFirstname;

end; // procedure TK_FormCMSASetProviderData.FormCloseQuery

//******************************** TK_FormCMSASetProviderData.LbESurnameExit ***
// LbESurname Exit Event Handler
//
procedure TK_FormCMSASetProviderData.LbESurnameExit(Sender: TObject);
begin
  TEdit(Sender).Text := K_CapitalizeWords( Trim( TEdit(Sender).Text ) );
end; // procedure TK_FormCMSASetProviderData.LbESurnameExit

//******************************** TK_FormCMSASetProviderData.LbESurnameKeyDown ***
// LbESurname KeyDown Event Handler
//
procedure TK_FormCMSASetProviderData.LbESurnameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_Return then Exit;
  TEdit(Sender).Text := K_CapitalizeWords( Trim( TEdit(Sender).Text ) );
end; // procedure TK_FormCMSASetProviderData.LbESurnameKeyDown

//**************************** TK_FormCMSASetProviderData.BtWEBAccountClick ***
// Buttomn BtWEBAccount Click Event Handler
//
procedure TK_FormCMSASetProviderData.BtWEBAccountClick(Sender: TObject);
label ContDlg;
begin
ContDlg: ////////////
  EncLP := '';
  if not K_CMWEBAccountSettingsDlg( Login, Password ) then Exit;
  EncLP := K_EncodeLoginPassword( Login, Password );
  // Check Login Password
  if (K_edFails = K_CMEDAccess.EDASACheckLoginPassword( ProvSID, EncLP )) then
  begin
//    K_CMShowMessageDlg( 'Change Login or Password.' + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'Login and Password are used by some other provider.'#13#10+
//    '   Press OK to change WEB account details.',
    K_CMShowMessageDlg( 'Login and Password are used by some other provider.'#13#10+
                        '   Press OK to change WEB account details.',
                         mtWarning, [mbOK] );
    goto ContDlg;
  end;
{
  if (K_edFails = K_CMEDAccess.EDASASetOneLoginPassword( ProvSID, EncLP )) then
  begin
//    K_CMShowMessageDlg( 'Change Login or Password.' + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'Login and Password are used by some other provider.'#13#10+
//    '   Press OK to change WEB account details.',
    K_CMShowMessageDlg( 'Login and Password are used by some other provider.'#13#10+
                        '   Press OK to change WEB account details.',
                         mtWarning, [mbOK] );
    goto ContDlg;
  end;
  if PrevEncLP <> EncLP then
    K_CMShowMessageDlg( 'New WEB account Login and Password are successfuly set. Press OK to continue.',
                         mtWarning, [mbOK] );
}
  PrevEncLP := EncLP;
end; // procedure TK_FormCMSASetProviderData.BtWEBAccountClick

procedure TK_FormCMSASetProviderData.BtSecurityClick(Sender: TObject);
begin
//  K_FCMSASetProvSec
  K_CMSASetPorviderSecurityDlg( SecurityFlags, ReadOnly );
end;

end.

