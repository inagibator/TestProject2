unit L_WEBSettingsF;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls;

type
  TL_WEBSettingsForm = class(TN_BaseForm)
    LbEdPortNumber: TLabeledEdit;
    BtRun: TButton;
    BtExit: TButton;
    BtDownloadScan: TButton;
    BtSetScan: TButton;
    Memo1: TMemo;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure LbEdPortNumberChange(Sender: TObject);
    procedure BtDownloadScanClick(Sender: TObject);
    procedure BtSetScanClick(Sender: TObject);
  private
    { Private declarations }
    PrevPortNumber : Integer;
  public
    { Public declarations }
  end;

var
  L_WEBSettingsForm: TL_WEBSettingsForm;

function L_WEBSettingsDlg( ) : Boolean;

implementation

{$R *.dfm}
uses DB,
  N_Types, N_Lib1, N_CM1, L_VirtUI,
  K_CLib0, K_CM0, K_Script1, K_CLib, K_FCMScan;

{ TK_FormCMReports }

function L_WEBSettingsDlg( ) : Boolean;
begin

  with TL_WEBSettingsForm.Create(Application) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    Result := ShowModal = mrOK;
    if not Result then Exit;
    K_CMVUIScanPortNumber := PrevPortNumber;
  end;

end; // function K_CMScanWEBSettingsDlg

//********************************************** TK_FormCMReports1.FormShow ***
// FormShow Handler
//
procedure TL_WEBSettingsForm.BtDownloadScanClick(Sender: TObject);
var
  LatestVersionFileURL: String;
begin
  inherited;
  LatestVersionFileURL := L_VirtUICMScanWebInstallURL + getLastScanVersion(N_CMSVersion);
  VirtUI_Obj.OpenLinkDlg(LatestVersionFileURL, 'Download Mediasuite Scanner');
end;

procedure TL_WEBSettingsForm.BtSetScanClick(Sender: TObject);
var
  Answer: String;
  Params, ParamsEnCode: String;
begin
  inherited;
  // TO-DO 20.01.2021: Read from MySQL WebDAV parametrs decode password and code all string for URL again

  Params := 'port=' + L_VirtUIWebDAVPort;
  Params := Params + '&drive=' + L_VirtUIWebDAVDrive;
  Params := Params + '&host=' + L_VirtUIWebDAVHost;
  Params := Params + '&user=' + L_VirtUIWebDAVUser;
  Params := Params + '&password=' + L_VirtUIWebDAVPassword;

  ParamsEnCode := '/?webdav=' + EnCodeParamURL(Params, 'cms');

  // two times pass !!!
  Answer := getScanCompName(K_CMVUIScanPortNumber, ParamsEnCode);
  //Memo1.Lines.Add(Answer);
  if Pos('ok', Answer) = 0 then
  begin
      Answer := getScanCompName(K_CMVUIScanPortNumber, ParamsEnCode);
  end;

  //Memo1.Lines.Add(Answer);

  if Pos('ok', Answer) > 0 then
      K_CMShowMessageDlg('The parameters were passed successfully.', mtInformation)
  else
      K_CMShowMessageDlg('Error transmitting parameters.', mtInformation);

end;

procedure TL_WEBSettingsForm.FormShow(Sender: TObject);
var
  LatestVersion: String;
  LatestVersionFile: String;
  ScanVersion: String;
begin
  PrevPortNumber := K_CMVUIScanPortNumber;
  if PrevPortNumber = 0 then PrevPortNumber := 81;
  LbEdPortNumber.Text := IntToStr(PrevPortNumber);
  if VirtUI_Info <> 'Windows' then                 //SIR#26380 SIR#26381
  begin
     BtDownloadScan.Enabled := false;
     BtSetScan.Enabled := false;
  end;

  LatestVersionFile := getLastScanVersion(N_CMSVersion);
  LatestVersion := Copy(LatestVersionFile, 24, 9);

  if VirtUI_ScanVersion = '' then
      ScanVersion := 'not running...'
  else
      ScanVersion := VirtUI_ScanVersion;

  Memo1.Lines.Clear;
  Memo1.Lines.Add('OS: ' + VirtUI_Info);
  Memo1.Lines.Add('Current version CMSuiteWEB: ' + N_CMSVersion);
  Memo1.Lines.Add('Current version CMScanWEB: ' + ScanVersion);
  Memo1.Lines.Add('Latest version CMScanWEB: ' + LatestVersion);

end; // TK_FormCMReports1.FormShow

//*************************** TK_FormCMScanWEBSettings.LbEdPortNumberChange ***
// LbEdPortNumber Change Handler
//
procedure TL_WEBSettingsForm.LbEdPortNumberChange(Sender: TObject);
begin
  PrevPortNumber := StrToIntDef( LbEdPortNumber.Text, PrevPortNumber ); // ObjName on output (changed or not)
  LbEdPortNumber.Text := IntToStr(PrevPortNumber);
end; // procedure TK_FormCMScanWEBSettings.LbEdPortNumberChange


end.
