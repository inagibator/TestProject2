unit L_WEBCheckVersionF;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls, ComCtrls;

type
  TL_WEBCheckVersionForm = class(TN_BaseForm)
    BtRun: TButton;
    BtExit: TButton;
    Memo1: TMemo;
    Button1: TButton;
    cbDateOut: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BtExitClick(Sender: TObject);
  private
    { Private declarations }
//    PrevPortNumber : Integer; // to remove compiler hint
  public
    { Public declarations }
  end;

var
  L_WEBCheckVersionForm: TL_WEBCheckVersionForm;

function L_WEBCheckVersionDlg( ) : Boolean;

implementation

{$R *.dfm}
uses DB,
  N_Types, N_Lib1, L_VirtUI, N_CM1,
  K_CLib0, K_CM0, K_Script1, K_CLib, K_FCMScan;

{ TK_FormCMReports }

function L_WEBCheckVersionDlg( ) : Boolean;
begin

  with TL_WEBCheckVersionForm.Create(Application) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    Result := ShowModal = mrOK;
    if not Result then Exit;
    //K_CMVUIScanPortNumber := PrevPortNumber;
  end;

end; // function K_CMScanWEBCheckVersionDlg

//********************************************** TK_FormCMReports1.FormShow ***
// FormShow Handler
//
procedure TL_WEBCheckVersionForm.BtExitClick(Sender: TObject);
var
   ParamsEnCode, Answer: String;
begin
  inherited;
  if cbDateOut.Checked then
  begin
    ParamsEnCode := '/?dateout=' + DateToStr(Now + 28);  // + 4 weeks  SIR#26380-26381
    // two times pass !!!
    Answer := getScanCompName(K_CMVUIScanPortNumber, ParamsEnCode);
    if Pos('ok', Answer) = 0 then
    begin
        Answer := getScanCompName(K_CMVUIScanPortNumber, ParamsEnCode);
    end;
  end;
end;

procedure TL_WEBCheckVersionForm.Button1Click(Sender: TObject);
var
  LatestVersionFileURL: String;
begin
  inherited;
  LatestVersionFileURL := L_VirtUICMScanWebInstallURL + getLastScanVersion(N_CMSVersion);
  VirtUI_Obj.OpenLinkDlg(LatestVersionFileURL, 'Download Mediasuite Scanner');
end;

procedure TL_WEBCheckVersionForm.FormShow(Sender: TObject);
begin

end; // TK_FormCMReports1.FormShow

end.
