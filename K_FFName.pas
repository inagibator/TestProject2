unit K_FFName;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_FNameFr, StdCtrls;

type
  TK_FormFileName = class(TForm)
    FileNameFrame: TN_FileNameFrame;
    BtCancel: TButton;
    BtOK: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    DestoyOnExit : Boolean;
  end;

function K_SelectFileName( History : TStrings = nil;
      IniName : string = ''; ACaption : string = '';
      ADestoyOnExit : Boolean = true ) : string;

var
  K_FormFileName: TK_FormFileName;

implementation

{$R *.dfm}

function K_SelectFileName( History : TStrings = nil;
      IniName : string = ''; ACaption : string = '';
      ADestoyOnExit : Boolean = true ) : string;
begin
  if K_FormFileName = nil then begin
    K_FormFileName := TK_FormFileName.Create(Application);
  end;
  with K_FormFileName do begin
    if ACaption <> '' then Caption := ACaption;
    with FileNameFrame.mbFileName do begin
      if History <> nil then begin
        Items.Clear;
        Items.Assign( History );
      end;
      if IniName <> '' then
        Text := IniName
      else
        Text := Items[0];
      DestoyOnExit := ADestoyOnExit;
      ShowModal;
      if (ModalResult = mrOk) then begin
        Result := Text;
        if History <> nil then begin
          History.Insert( 0, Result );
        end;
      end else
        Result := '';
    end;
  end;
  if ADestoyOnExit then K_FormFileName := nil;
end;

procedure TK_FormFileName.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if DestoyOnExit then Action := caFree;
end;

end.
