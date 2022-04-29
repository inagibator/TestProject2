unit K_FRASearch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids,
  N_BaseF, N_Lib1,
  K_FrRAEdit, ExtCtrls;

type
  TK_FormRASearchReplace = class(TN_BaseForm)
    EdiSearch: TEdit;
    LbSearch: TLabel;
    BtSearch: TButton;
    BtClose: TButton;
    BtToReplace: TButton;
    BtReplaceAll: TButton;
    BtReplace: TButton;
    EdReplace: TEdit;
    LbReplace: TLabel;
    ChBCase: TCheckBox;
    ChBCell: TCheckBox;
    ChBSearhInSelected: TCheckBox;
    LbSearchCaption: TLabel;
    LbReplaceCaption: TLabel;
    procedure BtToReplaceClick(Sender: TObject);
    procedure BtSearchClick(Sender: TObject);
    procedure BtReplaceClick(Sender: TObject);
    procedure BtReplaceAllClick(Sender: TObject);
    procedure SetStartModeClick(Sender: TObject);
  private
    { Private declarations }
    GR : TGridRect;
    FirstSearch : Boolean;
    FFrameRAEdit : TK_FrameRAEdit;
    FCol, FRow : Integer;
    SearchResult : Boolean;
    UseSelection : Boolean;
    SearchAfterReplace : Boolean;
    procedure ShowReplaceControls( Show : Boolean );
  public
    { Public declarations }
    FrameRAEdit : TK_FrameRAEdit;
  end;

var
  K_FormRASearchReplace: TK_FormRASearchReplace;

procedure K_RASearchReplace( AFrameRAEdit : TK_FrameRAEdit; AReplaceMode : Boolean );


implementation

uses K_CLib0;

{$R *.dfm}

procedure K_RASearchReplace( AFrameRAEdit : TK_FrameRAEdit; AReplaceMode : Boolean );
begin
  if K_FormRASearchReplace = nil then begin
    K_FormRASearchReplace := TK_FormRASearchReplace.Create(Application);
    K_FormRASearchReplace.BaseFormInit( nil );
  end;
  with K_FormRASearchReplace do begin
    ShowReplaceControls(AReplaceMode);
    FirstSearch := true;
    UseSelection := false;
    SearchAfterReplace := false;
    FFrameRAEdit := AFrameRAEdit;

    ShowModal;
  end;
  K_FormRASearchReplace := nil;
end;


{*** TK_FormRASearchReplace ***}

procedure TK_FormRASearchReplace.ShowReplaceControls(Show: Boolean);
begin
  BtReplaceAll.Visible := Show;
  BtReplace.Visible := Show;
  LbReplace.Visible := Show;
  EdReplace.Visible := Show;
  BtToReplace.Visible := not Show;
  if Show then
    Caption := LbReplaceCaption.Caption
  else
    Caption := LbSearchCaption.Caption;
end;

{*** end of TK_FormRASearchReplace ***}

procedure TK_FormRASearchReplace.BtToReplaceClick(Sender: TObject);
begin
  ShowReplaceControls(true);
end;

procedure TK_FormRASearchReplace.BtSearchClick(Sender: TObject);
var
  ASearchFlags : TK_RAFrameSearchFlags;
begin
  if FirstSearch then begin
    if EdiSearch.Text = '' then begin
      K_ShowMessage( 'Строка поиска не может быть пуста' );
      Exit;
    end;
    if ChBSearhInSelected.Checked then begin
      GR := FFrameRAEdit.SGrid.Selection;
      UseSelection := true;
    end else begin
      GR.Left := 1;
      GR.Top  := 1;
      GR.Right := -1;
      GR.Bottom := -1;
      UseSelection := false;
    end;
    ASearchFlags := [];
    if ChBCase.Checked then
      ASearchFlags := ASearchFlags + [K_sgfCaseSensitive];
    if ChBCell.Checked then
      ASearchFlags := ASearchFlags + [K_sgfUseCell];
    GR := FFrameRAEdit.SetSearchContext( ASearchFlags, EdiSearch.Text,
             GR.Left, GR.Top, GR.Right, GR.Bottom );
    FCol := GR.Left;
    FRow := GR.Top;
  end;
  SearchResult := FFrameRAEdit.NextSearch( FCol, FRow );
  if not SearchResult then begin
    if UseSelection then
      FFrameRAEdit.SelectRect( GR.Left, GR.Top, GR.Right, GR.Bottom );
    if FirstSearch then begin
      if not SearchAfterReplace then
        K_ShowMessage( 'Данные удовлетворяющие условию не обнаружены' );
    end else begin
      FirstSearch := true;
      BtSearchClick(Sender);
    end;
  end else begin
    FirstSearch := false;
    FFrameRAEdit.SelectRect( FCol, FRow, FCol, FRow );
//    FFrameRAEdit.SGrid.Col := FCol;
//    FFrameRAEdit.SGrid.Row := FRow;
  end

end;

procedure TK_FormRASearchReplace.BtReplaceClick(Sender: TObject);
begin
  if SearchResult then begin
    FFrameRAEdit.ReplaceSearchResult( EdReplace.Text );
    FFrameRAEdit.SGrid.Invalidate;
    SearchAfterReplace := true;
    BtSearchClick(Sender);
    SearchAfterReplace := false;
  end else
    K_ShowMessage( 'В текущей ячейке образец не найден' );
end;

procedure TK_FormRASearchReplace.BtReplaceAllClick(Sender: TObject);
var
  StartCol, StartRow : Integer;
  FirstReplace : Boolean;
begin
  if not FirstSearch then begin
    if UseSelection then
      FFrameRAEdit.SelectRect( GR.Left, GR.Top, GR.Right, GR.Bottom );
  end;
  FirstSearch := true;
  FirstReplace := true;
  StartCol := 0;
  StartRow := 0;
  while true do begin
    BtSearchClick(Sender);

    if not FirstReplace  and
       SearchResult      and
       (StartCol = FCol) and
       (StartRow = FRow) then
      SearchResult := false; // end of Replace Loop

    if SearchResult then begin
      if FirstReplace then begin
        StartCol := FCol;
        StartRow := FRow;
        FirstReplace := false;
      end;
      FFrameRAEdit.ReplaceSearchResult( EdReplace.Text );
    end else
      break;
  end;
  ModalResult := mrOK;
end;


procedure TK_FormRASearchReplace.SetStartModeClick(Sender: TObject);
begin
  FirstSearch := true;
  if UseSelection then
    FFrameRAEdit.SelectRect( GR.Left, GR.Top, GR.Right, GR.Bottom );
end;

end.
