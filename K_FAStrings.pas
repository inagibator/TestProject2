unit K_FAStrings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls, ComCtrls;

type
  TK_FormAnalisesStrings = class(TN_BaseForm)
    PnText: TPanel;
    Close: TButton;
    LESearchPat: TLabeledEdit;
    LEOrderPat: TLabeledEdit;
    BtApply: TButton;
    Memo1: TMemo;
    Splitter1: TSplitter;
    Memo2: TMemo;
    procedure BtApplyClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    SL, SL1, SL2 : TStringList;
  public
    { Public declarations }
  end;

var
  K_FormAnalisesStrings: TK_FormAnalisesStrings;

implementation

{$R *.dfm}

uses K_Clib0;

procedure TK_FormAnalisesStrings.BtApplyClick(Sender: TObject);
var
  i, IndS, IndF, LP : Integer;
  SavedCursor: TCursor;

begin
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  Memo2.Lines.Clear;

  if SL = nil then
  begin
    SL := TStringList.Create;
    SL1 := TStringList.Create;
    SL2 := TStringList.Create;
  end;

  SL.Clear;
  SL1.Clear;
  SL1.Sorted := FALSE;
  if (LESearchPat.Text <> '') and (LESearchPat.Text <> '*') then
  begin
    for i := 0 to Memo1.Lines.Count -1 do
      if K_CheckPattern(Memo1.Lines[i],LESearchPat.Text) then
        SL.Add(Memo1.Lines[i]);
  end
  else
    SL.AddStrings(Memo1.Lines);

  if (LEOrderPat.Text <> '') and (LEOrderPat.Text <> '*') then
  begin
    LP := Length(LEOrderPat.Text);
    for i := 0 to SL.Count -1 do
    begin
      if (SL[i] <> '') and K_SearchTextPattern( @SL[i][1], Length(SL[i]),
                              @LEOrderPat.Text[1], LP,
                               IndS, IndF ) then
        SL1.AddObject( Copy(SL[i],IndS, IndF - IndS ), TObject(i) )
      else
        SL1.AddObject( SL[i], TObject(i) );
      SL2.Add( '' );
    end;
    SL1.Sort();

    SL2.BeginUpdate;
    for i := 0 to SL1.Count -1 do
      SL2[i] := SL[Integer(SL1.Objects[i])];
    SL2.EndUpdate;

    Memo2.Lines.AddStrings(SL2);

  end
  else
    Memo2.Lines.AddStrings(SL);

  Screen.Cursor := SavedCursor;
end;

procedure TK_FormAnalisesStrings.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  SL.Free;
  SL1.Free;
  SL2.Free;
end;

end.
