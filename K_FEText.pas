unit K_FEText;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls,
  K_UDT1, K_FBase, N_BaseF, N_Types;

type
//  TK_FormTextEdit = class(TN_BaseForm)
  TK_FormTextEdit = class(TK_FormBase)
    BtCancel: TButton;
    BtOK: TButton;
    Panel1: TPanel;
    MMemo: TMemo;
    REMemo: TRichEdit;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure BtFormCloselClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
  private
    { Private declarations }
    IniCapt : string;
  public
    { Public declarations }
    Memo : TCustomMemo;
    OnOKResult : procedure ( Sender : TObject ) of object;
    function  EditStrings( Strings : TStrings; Capt : string = '';
                           AReadOnly : Boolean = false;
                           AShowModalReadOnly : Boolean = false ) : Boolean;
    function  EditText( var Text : string; Capt : string = '';
                        AReadOnly : Boolean = false;
                        AShowModalReadOnly : Boolean = false ) : Boolean;
    procedure MemIniToCurState  (); override;
  end;

function K_GetFormTextEdit( AOwner : TN_BaseForm = nil; ASelfName : string = '';
AFlags1 : TN_RectSizePosFlags = []; AFlags2: TN_RectSizePosFlags = [] ) : TK_FormTextEdit;


implementation

uses
  K_CLib, K_UDC, K_STBuf;
{$R *.DFM}

//********************************************* K_GetFormTextEdit ***
//  get form - create if needed
//
function K_GetFormTextEdit( AOwner : TN_BaseForm = nil; ASelfName : string = '';
AFlags1 : TN_RectSizePosFlags = []; AFlags2: TN_RectSizePosFlags = [] ) : TK_FormTextEdit;
begin
  Result := TK_FormTextEdit.Create(Application);
  if (AFlags1 <> []) or (AFlags2 <> []) then
    Result.BaseFormInit( AOwner, ASelfName, AFlags1, AFlags2 )
  else
    Result.BaseFormInit( AOwner, ASelfName );
end; //*** end of K_GetFormTextEdit ***


//********************************************* TK_FormTextEdit.EditTextTree ***
//  Edit UDBase text representation
//
function TK_FormTextEdit.EditStrings( Strings : TStrings; Capt : string = '';
                                      AReadOnly : Boolean = false;
                                      AShowModalReadOnly : Boolean = false ) : Boolean;
var
//  IniCapt : string;
  TextBuf : string;
begin
  TextBuf := Strings.Text;
  Result := EditText( TextBuf, Capt, AReadOnly, AShowModalReadOnly );
  if not AReadOnly and Result then //****** put data from wrk structure to node
    Strings.Assign( Memo.Lines );
{
  if Length(strings.Text) > 20000 then begin
//  if Length(strings.Text) > 80 then begin
    Memo := REMemo as TCustomMemo;
    MMemo.Visible := false;
  end else begin
    Memo := MMemo as TCustomMemo;
    REMemo.Visible := false;
  end;

  Memo.Visible := true;
  Memo.Align := alClient;

//  Memo.Lines.Clear;
  Memo.Lines.Text := strings.Text;

  IniCapt := Caption;
  if Length(Capt) > 0 then Caption := Capt;

  ShowModal;
  Result := (ModalResult = mrOk);
  if Result then //****** put data from wrk structure to node
    strings.Text := Memo.Lines.Text;
  Caption := IniCapt;
  K_FormTextEdit := nil;
}
end; //*** end of TK_FormTextEdit.EditStrings

//********************************************* TK_FormTextEdit.EditTextTree ***
//  Edit UDBase text representation
//
function TK_FormTextEdit.EditText( var Text : string; Capt : string = '';
                  AReadOnly : Boolean = false;
                  AShowModalReadOnly : Boolean = false ) : Boolean;
begin
//  if Length(Text) > 20000 then begin
//    Memo := REMemo as TCustomMemo;
//    MMemo.Visible := false;
//  end else begin
    Memo := MMemo as TCustomMemo;
//    REMemo.Visible := false;
//  end;
//  Memo.Visible := true;
//++  Memo.Align := alClient;

//++  Memo.Lines.Text := Text;
  MMemo.Align := alClient;
  MMemo.Width := MMemo.Width - 10;
  MMemo.Lines.Text := Text;
  MMemo.ReadOnly := AReadOnly;
  IniCapt := Caption;
  if Length(Capt) > 0 then Caption := Capt;
  Result := false;
  if not AReadOnly or AShowModalReadOnly then begin
    ShowModal;
    Result := (ModalResult = mrOk);
    if Result and not AReadOnly then //****** put data from wrk structure to node
      Text := MMemo.Lines.Text;
  end else
    Show;
end; //*** end of TK_FormTextEdit.EditText

//************************************************ TK_FormTextEdit.FormShow
//
procedure TK_FormTextEdit.FormShow(Sender: TObject);
begin
  Memo.SetFocus;
end; //*** end of TK_FormTextEdit.FormShow

//************************************************ TK_FormTextEdit.BtFormCloselClick
//
procedure TK_FormTextEdit.BtFormCloselClick(Sender: TObject);
begin
//  if (MMemo.ReadOnly) then CLose();
  if fsModal in FormState then Exit;
  CLose();
end; //*** end of TK_FormTextEdit.BtFormCloselClick

//************************************************ TK_FormTextEdit.BtOKClick
//
procedure TK_FormTextEdit.BtOKClick(Sender: TObject);
begin
  ModalResult := mrOK;
  if fsModal in FormState then Exit;
  CLose();
end; //*** end of TK_FormTextEdit.BtOKClick

//************************************************ TK_FormTextEdit.MemIniToCurState
//
procedure TK_FormTextEdit.MemIniToCurState;
begin
  inherited;
  K_PosTwinForm( Self );
end; //*** end of TK_FormTextEdit.MemIniToCurState

//************************************************ TK_FormTextEdit.FormClose
//
procedure TK_FormTextEdit.FormClose( Sender: TObject;
                                     var Action: TCloseAction );
begin
  if Assigned( OnOKResult ) then OnOKResult( Self );
  Caption := IniCapt;
  inherited;
end; //*** end of TK_FormTextEdit.FormClose

end.

