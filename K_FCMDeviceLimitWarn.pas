unit K_FCMDeviceLimitWarn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ExtCtrls, StdCtrls;

type
  TK_FormCMProfileLimitWarn = class(TN_BaseForm)
    DeviceList: TMemo;
    STTop: TStaticText;
    STBottom: TStaticText;
    PnCtrl: TPanel;
    BtOK: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMProfileLimitWarn: TK_FormCMProfileLimitWarn;

procedure K_FCMShowDeviceLimitWarning();

implementation

uses K_CM0, K_CM1, N_Types, N_Lib0;

{$R *.dfm}

procedure K_FCMShowDeviceLimitWarning();
begin
  with TK_FormCMProfileLimitWarn.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    K_CMLimitDevGetAllProfilesReport( DeviceList.Lines );
    N_Dump1Str( 'DB> DeviceLimitWarning:' );
    N_Dump1Strings( DeviceList.Lines, 5 );
    STTop.Caption := format( STTop.Caption, [K_CMSLiRegDevLimit] );
    ActiveControl := BtOK;
    ShowModal();
  end;
end;

end.
