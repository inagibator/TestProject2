unit K_FUDRename;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  N_BaseF,
  K_UDT1, ExtCtrls;

type
  TK_FormUDRename = class(TN_BaseForm)
    LbAliase: TLabel;
    EdAliase: TEdit;
    LbName: TLabel;
    EdName: TEdit;
    BtCancel: TButton;
    BtOK: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
    function SetNameAndAliase( var AAliase : string; var AName : string ) : Boolean;
  end;

function K_GetFormUDRename : TK_FormUDRename;

function K_EditUDNameAndAliase( UD : TN_UDBase ) : Boolean;
function K_EditNameAndAliase( var AAliase : string; var AName : string ) : Boolean;

implementation

{$R *.dfm}
function TK_FormUDRename.SetNameAndAliase( var AAliase : string; var AName : string ) : Boolean;
begin
  Result := false;
  if AAliase <> EdAliase.Text then begin
    Result := true;
    AAliase := EdAliase.Text;
  end;
  if AName <> EdName.Text then begin
    Result := true;
    AName := EdName.Text;
  end;
end;

function K_GetFormUDRename : TK_FormUDRename;
begin
  Result := TK_FormUDRename.Create(Application);
  Result.BaseFormInit( nil );
end;

function K_EditUDNameAndAliase( UD : TN_UDBase ) : Boolean;
begin
  with K_GetFormUDRename do begin
    EdAliase.Text := UD.ObjAliase;
    EdName.Text := UD.ObjName;
    ShowModal;
    Result := false;
    if ModalResult = mrOK then
      Result := SetNameAndAliase(UD.ObjAliase, UD.ObjName);
  end;
end;

function K_EditNameAndAliase( var AAliase : string; var AName : string ) : Boolean;
begin
  with K_GetFormUDRename do begin
    EdAliase.Text := AAliase;
    EdName.Text := AName;
//    BtCancel.Visible := false;
    ShowModal;
    Result := (ModalResult = mrOK);
    if Result then SetNameAndAliase(AAliase, AName);
  end;
end;

end.
