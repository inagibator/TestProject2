unit K_FCMCaptButDelay;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_BaseF, N_Types, ComCtrls;

type
  TK_FormCMCaptButDelay = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    LbEdCaptButDelay: TLabeledEdit;
    UDCaptButDelay: TUpDown;
    LbSec: TLabel;
//    TimerMin: TTimer;
    procedure FormShow(Sender: TObject);
    procedure LbEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtOKClick(Sender: TObject);
//    procedure LbEdCaptButDelayChange(Sender: TObject);
//    procedure TimerMinTimer(Sender: TObject);
    procedure UDCaptButDelayClick(Sender: TObject; Button: TUDBtnType);
  private
    { Private declarations }
//    SPSkipFNumEvent : Boolean;
    procedure SetNewDelay( ASkipPosition : Boolean );
  public
    FDelay : Double;
    IDelay : Integer;
  end;

var
  K_FormCMCaptButDelay: TK_FormCMCaptButDelay;

function K_CMGetCaptButDelayDlg( var ACaptButDelay : Float ) : Boolean;

implementation

{$R *.dfm}

function K_CMGetCaptButDelayDlg( var ACaptButDelay : Float ) : Boolean;
begin
  with TK_FormCMCaptButDelay.Create(Application) do begin
//    BaseFormInit( nil, '', [fvfCenter] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    FDelay := ACaptButDelay;
    IDelay := Round(FDelay * 100);
    SetNewDelay( FALSE );
    Result := ShowModal() = mrOK;
    if not Result then Exit;
    ACaptButDelay := StrToFloatDef( LbEdCaptButDelay.Text, ACaptButDelay );
  end;
end;

procedure TK_FormCMCaptButDelay.FormShow( Sender: TObject );
begin
//
end;

procedure TK_FormCMCaptButDelay.SetNewDelay( ASkipPosition : Boolean );
begin
{
  if IDelay > UDCaptButDelay.Max then
    IDelay := UDCaptButDelay.Max
  else if IDelay < UDCaptButDelay.Min then
    IDelay := UDCaptButDelay.Min;
}
  if not ASkipPosition then
    UDCaptButDelay.Position := IDelay;

//  SPSkipFNumEvent := TRUE;
  FDelay := IDelay / 100;
  LbEdCaptButDelay.Text := format('%3.1f', [FDelay] );
end;

procedure TK_FormCMCaptButDelay.LbEditKeyDown( Sender: TObject; var Key: Word;
                                          Shift: TShiftState );
begin
  if Key = VK_Return then BtOKClick(Sender);
end;


procedure TK_FormCMCaptButDelay.BtOKClick( Sender: TObject );
begin
  ModalResult := mrOK
end;
{
procedure TK_FormCMCaptButDelay.LbEdCaptButDelayChange(Sender: TObject);
begin
  if not SPSkipFNumEvent then
    TimerMin.Enabled := true;
  SPSkipFNumEvent := FALSE;
end;

procedure TK_FormCMCaptButDelay.TimerMinTimer(Sender: TObject);
begin
  TimerMin.Enabled := FALSE;
  FDelay := StrToFloatDef( LbEdCaptButDelay.Text, FDelay );
  IDelay := Round( FDelay * 100 );
  SetNewDelay( FALSE );
end;
}

procedure TK_FormCMCaptButDelay.UDCaptButDelayClick(Sender: TObject;
  Button: TUDBtnType);
begin
{
  if Button = btPrev then
    IDelay := UDCaptButDelay.Position - UDCaptButDelay.Increment
  else
    IDelay := UDCaptButDelay.Position + UDCaptButDelay.Increment;

  if IDelay > UDCaptButDelay.Max then
    IDelay := UDCaptButDelay.Min
  else if IDelay < UDCaptButDelay.Min then
    IDelay := UDCaptButDelay.Max;
}
  IDelay := UDCaptButDelay.Position;
  SetNewDelay( TRUE );
end;

end.
