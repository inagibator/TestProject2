unit K_FCMRemoveLogsHandling;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ComCtrls, ExtCtrls,
  N_Types;

type
  TK_FormCMRemoveLogsHandling = class(TN_BaseForm)
    LbKeepDelObjs: TLabel;
    EdMonthCount: TEdit;
    UpDown: TUpDown;
    LbMonth: TLabel;
    BtCancel: TButton;
    BtOK: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMRemoveLogsHandling: TK_FormCMRemoveLogsHandling;

function K_CMRemoveLogsHandlingDlg( ) : Integer;

implementation

{$R *.dfm}

uses K_CM0, K_CM1,
N_Lib1;

function K_CMRemoveLogsHandlingDlg( ) : Integer;
begin
  with TK_FormCMRemoveLogsHandling.Create(Application) do
  begin
//    BaseFormInit(nil);
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    Result := Round( K_CMRemoveOldDumpMonths() );
    if Result = 0 then Result := 1;
    UpDown.Position := Short(Result);
    N_Dump1Str( 'K_CMRemoveLogsHandlingDlg start = ' + IntToStr(Result) );
    Result := 0;
    if ShowModal() = mrOK then
    begin
      Result := UpDown.Position;
      N_IntToMemIni( 'CMS_Main', 'LogsKeepPeriodInMonths', Result );
      N_Dump1Str( 'K_CMRemoveLogsHandlingDlg set = ' + IntToStr(Result) );
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
end; // K_CMRemoveLogsHandlingDlg

end.
