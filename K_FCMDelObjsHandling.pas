unit K_FCMDelObjsHandling;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ComCtrls, ExtCtrls,
  N_Types;

type
  TK_FormCMDelObjsHandling = class(TN_BaseForm)
    LbKeepDelObjs: TLabel;
    RBForEver: TRadioButton;
    RBFor: TRadioButton;
    EdMonthCount: TEdit;
    UpDown: TUpDown;
    LbMonth: TLabel;
    BtCancel: TButton;
    BtOK: TButton;
    procedure RBForEverClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMDelObjsHandling: TK_FormCMDelObjsHandling;

function K_CMDelObjsHandlingDlg( ) : Integer;

implementation

{$R *.dfm}

uses K_CM0,
N_Lib1;

function K_CMDelObjsHandlingDlg( ) : Integer;
begin
  with TK_FormCMDelObjsHandling.Create(Application) do
  begin
//    BaseFormInit(nil);
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    Result := N_MemIniToInt( 'CMS_Main', 'DelObjsKeepMonths', 6 );
    if Result < 0 then
    begin
      RBForEver.Checked := TRUE;
      Result := -Result;
    end;
    UpDown.Position := Short(Result);
    RBForEverClick( nil );
    Result := 0;
    if ShowModal() = mrOK then
    begin
      Result := UpDown.Position;
      if RBForEver.Checked then
        Result := -Result;
      N_IntToMemIni( 'CMS_Main', 'DelObjsKeepMonths', Result );
{
      K_CMEDAccess.EDASaveContextsData(
         [K_cmssSkipSlides, K_cmssSkipInstanceBinInfo,
          K_cmssSkipInstanceInfo, K_cmssSkipPatientInfo,
          K_cmssSkipProviderInfo, K_cmssSkipLocationInfo,
          K_cmssSkipExtIniInfo,
          K_cmssSaveGlobal2Info] );
}
    end;
  end;
end;

procedure TK_FormCMDelObjsHandling.RBForEverClick(Sender: TObject);
begin
  UpDown.Enabled := not RBForEver.Checked;
  EdMonthCount.Enabled := not RBForEver.Checked;
end;

end.
