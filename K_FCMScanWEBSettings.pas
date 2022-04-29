unit K_FCMScanWEBSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls, ComCtrls;

type
  TK_FormCMScanWEBSettings = class(TN_BaseForm)
    ChBWEBMode: TCheckBox;
    LbEdPortNumber: TLabeledEdit;
    BtRun: TButton;
    BtExit: TButton;
    LbEdWDDrive: TLabeledEdit;
    LbEdWDHost: TLabeledEdit;
    LbEdWDLogin: TLabeledEdit;
    LbEdWDPassword: TLabeledEdit;
    LbEdWDCompID: TLabeledEdit;
    LbEdWDDateOut: TLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure LbEdPortNumberChange(Sender: TObject);
    procedure ChBWEBModeClick(Sender: TObject);
    procedure LbEdWDDriveChange(Sender: TObject);
  private
    { Private declarations }
    PrevPortNumber : Integer;
    PrevWDDrive : string;
  public
    { Public declarations }
  end;

var
  K_FormCMScanWEBSettings: TK_FormCMScanWEBSettings;

function K_CMScanWEBSettingsDlg( ) : Boolean;

implementation

{$R *.dfm}
uses DB,
  N_Types, N_Lib1,
  K_CLib0, K_CM0, K_Script1, K_CLib, K_FCMScan;

{ TK_FormCMReports }

function K_CMScanWEBSettingsDlg( ) : Boolean;
begin


  with TK_FormCMScanWEBSettings.Create(Application) do
  begin
//    BaseFormInit ( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    Result := ShowModal = mrOK;
    if not Result then Exit;
    with K_FormCMScan do
    begin
      SCWEBMode := ChBWEBMode.Checked;
      SCWEBPortNumber := PrevPortNumber;
      SCWEBWDDriveChar := PrevWDDrive;
      SCWEBWDHost := LbEdWDHost.Text;
      SCWEBWDLogin := LbEdWDLogin.Text;
      SCWEBWDPassword := LbEdWDPassword.Text;
      if LbEdWDCompID.Text <> '' then
        SCWEBWDCompID := LbEdWDCompID.Text;
      SCWEBWDDateOut := LbEdWDDateOut.Text;
    end;
  end;

end; // function K_CMScanWEBSettingsDlg

//********************************************** TK_FormCMReports1.FormShow ***
// FormShow Handler
//
procedure TK_FormCMScanWEBSettings.FormShow(Sender: TObject);
begin
  with K_FormCMScan do
  begin
    PrevPortNumber := SCWEBPortNumber;
    if PrevPortNumber = 0 then PrevPortNumber := 81;
    LbEdPortNumber.Text := IntToStr(PrevPortNumber);

    PrevWDDrive         := SCWEBWDDriveChar;
    if PrevWDDrive = '' then PrevWDDrive := 'Z';
    LbEdWDDrive.Text    := PrevWDDrive;

    LbEdWDHost.Text     := SCWEBWDHost;
    LbEdWDLogin.Text    := SCWEBWDLogin;
    LbEdWDPassword.Text := SCWEBWDPassword;
    LbEdWDCompID.Text   := SCWEBWDCompID;
    LbEdWDDateOut.Text   := SCWEBWDDateOut;
    ChBWEBMode.Checked  := SCWEBMode;
    if not SCWEBMode then
      ChBWEBModeClick(Sender);
  end; // with K_FormCMScan do

end; // TK_FormCMReports1.FormShow

//*************************** TK_FormCMScanWEBSettings.LbEdPortNumberChange ***
// LbEdPortNumber Change Handler
//
procedure TK_FormCMScanWEBSettings.LbEdPortNumberChange(Sender: TObject);
//var
//  WInt : Integer;
begin
//  WInt := PrevPortNumber;
  PrevPortNumber := StrToIntDef( LbEdPortNumber.Text, PrevPortNumber ); // ObjName on output (changed or not)
//  if WInt <> PrevPortNumber then
  LbEdPortNumber.Text := IntToStr(PrevPortNumber);
end; // procedure TK_FormCMScanWEBSettings.LbEdPortNumberChange

//******************************** TK_FormCMScanWEBSettings.ChBWEBModeClick ***
// ChBWEBMode Click Handler
//
procedure TK_FormCMScanWEBSettings.ChBWEBModeClick(Sender: TObject);
begin
  LbEdPortNumber.Enabled := ChBWEBMode.Checked;
  LbEdWDDrive.Enabled    := ChBWEBMode.Checked;
  LbEdWDHost.Enabled     := ChBWEBMode.Checked;
  LbEdWDLogin.Enabled    := ChBWEBMode.Checked;
  LbEdWDPassword.Enabled := ChBWEBMode.Checked;
  LbEdWDCompID.Enabled := ChBWEBMode.Checked;
end; // procedure TK_FormCMScanWEBSettings.ChBWEBModeClick

//****************************** TK_FormCMScanWEBSettings.LbEdWDDriveChange ***
// LbEdWDDrive Change Handler
//
procedure TK_FormCMScanWEBSettings.LbEdWDDriveChange(Sender: TObject);
begin
  with LbEdWDDrive do
  begin
    if (Length(Text) > 0) and
       (((Text[1] >= 'a') and (Text[1] <= 'z')) or ((Text[1] >= 'A') and (Text[1] <= 'Z'))) then
      PrevWDDrive := UpperCase( Copy( LbEdWDDrive.Text, 1 ,1 ) );
    Text := PrevWDDrive;
  end;
end; // procedure TK_FormCMScanWEBSettings.LbEdWDDriveChange

end.
