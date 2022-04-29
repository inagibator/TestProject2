unit K_FCMNewDBAPSW;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls;

type
  TK_FormCMNewDBAPSW = class(TN_BaseForm)
    LbEdOldPSW: TLabeledEdit;
    BtRun: TButton;
    BtExit: TButton;
    BtForgotPSW: TButton;
    LbEdNewPSW: TLabeledEdit;
    LbEdVerifyPSW: TLabeledEdit;
    procedure LbEdOldPSWChange(Sender: TObject);
    procedure BtForgotPSWClick(Sender: TObject);
    procedure BtRunClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMNewDBAPSW: TK_FormCMNewDBAPSW;

function K_CMSetNewDBAPSWDlg( ASkipOldPSW : Boolean = FALSE ) : Boolean;

implementation

{$R *.dfm}

uses N_Types,
  K_CM0, K_FCMGAdmEnter;

function K_CMSetNewDBAPSWDlg( ASkipOldPSW : Boolean = FALSE ) : Boolean;
begin

  with TK_FormCMNewDBAPSW.Create(Application) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    LbEdOldPSW.Enabled := not ASkipOldPSW and not (K_CMDBAPSW = '');
    BtForgotPSW.Visible := LbEdOldPSW.Enabled;
    if not LbEdOldPSW.Enabled then
      LbEdNewPSW.SetFocus;
    Result := ShowModal = mrOK;
    if not Result then Exit;
    K_CMDBAPSW := LbEdNewPSW.Text;
  end;

end; // function K_CMSetNewDBAPSWDlg


//*************************** TK_FormCMScanWEBSettings.LbEdPortNumberChange ***
// LbEdPortNumber Change Handler
//
procedure TK_FormCMNewDBAPSW.LbEdOldPSWChange(Sender: TObject);
begin
//  PrevPortNumber := StrToIntDef( LbEdPortNumber.Text, PrevPortNumber ); // ObjName on output (changed or not)
//  LbEdPortNumber.Text := IntToStr(PrevPortNumber);
end; // procedure TK_FormCMScanWEBSettings.LbEdPortNumberChange


procedure TK_FormCMNewDBAPSW.BtForgotPSWClick(Sender: TObject);
begin
  LbEdOldPSW.Enabled :=
  not K_CMEnterConfirmDlg( '', '', K_CMDesignModeFlag,
//  not K_CMEnterConfirmDlg( '', '', FALSE,
                'Forgot old password',
                'Wrong user name or password. Press OK to return to change password dialog.' );
  BtForgotPSW.Visible := LbEdOldPSW.Enabled;
  if not LbEdOldPSW.Enabled then
    LbEdNewPSW.SetFocus;
end; // procedure TK_FormCMNewDBAPSW.BtForgotPSWClick

procedure TK_FormCMNewDBAPSW.BtRunClick(Sender: TObject);
var
  Res : Boolean;
begin
  Res := TRUE;
  if LbEdOldPSW.Enabled then
  begin
    Res := (LbEdOldPSW.Text = K_CMDBAPSW);
    if not RES then
      K_CMShowMessageDlg( 'Old password is incorrect', mtWarning );
  end;

  if not Res then Exit;
  if (LbEdNewPSW.Text = LbEdVerifyPSW.Text) then
  begin
    if LbEdOldPSW.Text = LbEdNewPSW.Text then
    begin
      K_CMShowMessageDlg(
       'The same password was entered. Nothing to do.',
      mtInformation );
      ModalResult := mrCancel;
    end
    else
      ModalResult := mrOK
  end
  else
    K_CMShowMessageDlg(
     'The entry in the Verify password doesn''t match the one in the New password.',
    mtWarning );

end; // procedure TK_FormCMNewDBAPSW.BtRunClick

end.
