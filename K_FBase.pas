unit K_FBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ExtCtrls;

type TK_ClearParentRefProc = procedure ( Sender : Tobject; SelfClose : Boolean ) of object;
type
  TK_FormBase = class(TN_BaseForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
  private
    { Private declarations }
  public
    { Public declarations }
    DataSaveModalState : word;
    OnClearParentRef   : TK_ClearParentRefProc;
    function IfDataWasChanged : Boolean; virtual;
  end;

implementation

{$R *.dfm}

procedure TK_FormBase.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(OnClearParentRef) then OnClearParentRef( Self, true );
  inherited;
end;

function TK_FormBase.IfDataWasChanged: Boolean;
begin
  Result := false;
end;

end.
