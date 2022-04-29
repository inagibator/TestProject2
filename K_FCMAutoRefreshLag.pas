unit K_FCMAutoRefreshLag;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_BaseF, N_Types, ComCtrls;

type
  TK_FormCMAutoRefreshLag = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    LbSec: TLabel;
    LbTimer: TLabel;
    CmBAutoRefreshLag: TComboBox;
  private
    { Private declarations }
    procedure SetNewLag( ALag : Integer );
  public
  end;

var
  K_FormCMAutoRefreshLag: TK_FormCMAutoRefreshLag;

function K_CMGetAutoRefreshLagDlg( var AAutoRefreshLag : Integer ) : Boolean;

implementation

{$R *.dfm}

function K_CMGetAutoRefreshLagDlg( var AAutoRefreshLag : Integer ) : Boolean;
var
  NewAutoRefreshLag : Integer;
begin
  with TK_FormCMAutoRefreshLag.Create(Application) do begin
//    BaseFormInit( nil, '', [fvfCenter] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    SetNewLag( AAutoRefreshLag );
    Result := ShowModal() = mrOK;
    if not Result then Exit;
    with CmBAutoRefreshLag do
      NewAutoRefreshLag := Integer(Items.Objects[ItemIndex]);
    if AAutoRefreshLag <> NewAutoRefreshLag then
    begin
      AAutoRefreshLag := NewAutoRefreshLag;
      N_Dump1Str( 'DB >> New AutoRefresh Lag=' + IntToStr(NewAutoRefreshLag) );
    end;

  end;
end;


procedure TK_FormCMAutoRefreshLag.SetNewLag( ALag : Integer );
var
  i : Integer;
begin
  for i := 0 to CmBAutoRefreshLag.Items.Count - 1 do
    CmBAutoRefreshLag.Items.Objects[i] := TObject( StrToInt(Trim(CmBAutoRefreshLag.Items[i])) );

  with CmBAutoRefreshLag do
    ItemIndex := Items.IndexOfObject( TObject(ALag) );
end;



end.
