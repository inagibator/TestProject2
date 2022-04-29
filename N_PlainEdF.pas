unit N_PlainEdF;
// Plain Text Editor Form (no more than 32K in Win9X)
// can be used for showing and editing (small, <32K in Win9X)) StringLists

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ComCtrls, ActnList, ToolWin,
  N_Types, N_Lib1, N_BaseF, ExtCtrls;

type TN_PlainEditorForm = class( TN_BaseForm )
    MainMenu1: TMainMenu;
    Memo: TMemo;
    File1: TMenuItem;
    bnCancel: TButton;
    bnApply: TButton;
    bnOK: TButton;
    Edit1: TMenuItem;
    Search1: TMenuItem;
    Options1: TMenuItem;
    ActionList: TActionList;
    ToolBar: TToolBar;
    actWordWrap: TAction;
    actToolBar: TAction;
    ShowToolBar1: TMenuItem;
    WordWrap1: TMenuItem;
    actVerticalScrollBar: TAction;
    actHorizontalScrollBar: TAction;
    VerticalScrollBar1: TMenuItem;
    HorizontalScrollBar1: TMenuItem;
    actButtons: TAction;
    Buttons1: TMenuItem;
    edRowCol: TEdit;
    actNew: TAction;
    actOpen: TAction;
    actSave: TAction;
    actSaveAs: TAction;
    actAppend: TAction;
    New1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Append1: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    actDosToWin: TAction;
    N1: TMenuItem;
    N2: TMenuItem;
    DosToWin1: TMenuItem;
    actSort: TAction;
    actSort1: TMenuItem;
    Customize1: TMenuItem;
    ControlApply: TAction;
    ControlOK: TAction;
    ControlCancel: TAction;
    actViewAsHex: TAction;
    actViewAsText: TAction;
    miViewMode: TMenuItem;
    actStayOnTop: TAction;
    StayOnTop1: TMenuItem;
    actOpenAsHex: TAction;
    actOpenAsHex1: TMenuItem;

    //***** File actions  *****************************
    procedure actNewExecute       ( Sender: TObject );
    procedure actOpenExecute      ( Sender: TObject );
    procedure actOpenAsHexExecute ( Sender: TObject );
    procedure actSaveExecute      ( Sender: TObject );
    procedure actSaveAsExecute    ( Sender: TObject );
    procedure actAppendExecute    ( Sender: TObject );

    //***** Options actions  *****************************
    procedure actWordWrapExecute            ( Sender: TObject );
    procedure actToolBarExecute             ( Sender: TObject );
    procedure actVerticalScrollBarExecute   ( Sender: TObject );
    procedure actHorizontalScrollBarExecute ( Sender: TObject );
    procedure actButtonsExecute             ( Sender: TObject );
    procedure actDosToWinExecute            ( Sender: TObject );
    procedure actSortExecute                ( Sender: TObject );
    procedure actViewAsHexExecute           ( Sender: TObject );
    procedure actViewAsTextExecute          ( Sender: TObject );
    procedure actStayOnTopExecute           ( Sender: TObject );

    //***** Control actions  *****************************
    procedure ControlApplyExecute  ( Sender: TObject );
    procedure ControlOKExecute     ( Sender: TObject );
    procedure ControlCancelExecute ( Sender: TObject );

    //***** On Event Handlers  *****************************
    procedure FormShow      ( Sender: TObject );
    procedure MemoMouseDown ( Sender: TObject;
                     Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MemoKeyDown   ( Sender: TObject; var Key: Word;
                                                          Shift: TShiftState);
    procedure miViewModeClick ( Sender: TObject );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  private
    ContentAsText: string;
    HexView: boolean;
    AppendMode: boolean; // True if Append to file instead of save to file
    procedure ShowCaretPos ();
    procedure InitTextView ();
  public
    ApplyProcObj: TN_OneStrProcObj;

    procedure OpenFileAsText ( AFileName: string );
    procedure OpenFileAsHex  ( AFileName: string );
end; // type TN_PlainEditorForm = class(TForm)
type TN_PPlainEditorForm = ^TN_PlainEditorForm;


    //*********** Global Procedures  *****************************

procedure N_ShowFileSection( AFName, ASName: string; AOwner: TN_BaseForm );

function N_CreatePlainEditorForm ( AOwner: TN_BaseForm ): TN_PlainEditorForm;
//function N_GetPlainEditorForm    (): TN_PlainEditorForm;

var
  N_PlainEditorForm: TN_PlainEditorForm;

implementation
{$R *.dfm}
uses
  K_CLib0,
  N_Lib0;

    //***** File actions  *****************************

procedure TN_PlainEditorForm.actNewExecute( Sender: TObject );
// Clear Memo.Lines and current file name
// (later add prompt for saving current content)
begin
  InitTextView();
  Memo.Lines.Clear();
  OpenDialog.FileName := 'Untitled';
  Caption := 'Edit - ' + OpenDialog.FileName;
  edRowCol.Text := 'Cleared';
end; // end of procedure TN_PlainEditorForm.actNewExecute

procedure TN_PlainEditorForm.actOpenExecute( Sender: TObject );
// Open File as Text
// (later add prompt for saving current content)
begin
  if OpenDialog.Execute then
    OpenFileAsText( OpenDialog.FileName );
end; // end of procedure TN_PlainEditorForm.actOpenExecute

procedure TN_PlainEditorForm.actOpenAsHexExecute( Sender: TObject );
// Open File as Hex
// (later add prompt for saving current content)
begin
  if OpenDialog.Execute then
    OpenFileAsHex( OpenDialog.FileName );
end; // procedure TN_PlainEditorForm.actOpenAsHexExecute

procedure TN_PlainEditorForm.actSaveExecute( Sender: TObject );
// Save Memo.Lines in last opened File
begin
  if OpenDialog.FileName = 'Untitled' then // first Save after New action
  begin
    SaveDialog.FileName := 'Untitled';
    actSaveAsExecute( nil ); // choose File in Dialog and Save it
  end else // Save after Open, Save, SaveAs, Append (not after New)
  begin
    Memo.Lines.SaveToFile( OpenDialog.FileName );
    edRowCol.Text := 'Saved OK';
  end;
end; // end of procedure TN_PlainEditorForm.actSaveExecute

procedure TN_PlainEditorForm.actSaveAsExecute( Sender: TObject );
//  Save or Append Memo.Lines in chosen by SaveDialog File
//  (or given manualy in SaveDialog.FileName field)
begin
  //*** set appropriate InitialDir and FileName in SaveDialog
  if SaveDialog.InitialDir = '' then
    SaveDialog.InitialDir := OpenDialog.InitialDir;
  if SaveDialog.FileName = '' then
    SaveDialog.FileName := OpenDialog.FileName;

  if SaveDialog.Execute then
  begin

  if AppendMode then // Append (not Save)
  begin
    if FileExists( SaveDialog.FileName ) then
    begin                          // Apend to existisng file
      with TStringList.Create() do
      begin
        LoadFromFile( SaveDialog.FileName );
        AddStrings( Memo.Lines );
        SaveToFile( SaveDialog.FileName );
        Destroy;
      end;
    end else // Append to absent file (same as Save to file)
    begin
      Memo.Lines.SaveToFile( SaveDialog.FileName );
    end;
    edRowCol.Text := 'App. OK';
  end else //********** Save (not Append)
  begin
    Caption := 'Edit : ' + SaveDialog.FileName;
    Memo.Lines.SaveToFile( SaveDialog.FileName );
    OpenDialog.FileName := SaveDialog.FileName; // for next Save
    edRowCol.Text := 'Saved OK';
  end;

  end; // if SaveDialog.Execute then
end; // end of procedure TN_PlainEditorForm.actSaveAsExecute

procedure TN_PlainEditorForm.actAppendExecute( Sender: TObject );
// Append Memo.Lines to chosen by SaveAs Dialog File
begin
  AppendMode := True;
  actSaveAsExecute( nil ); // choose File in Dialog and Append
  AppendMode := False;
end; // end of procedure TN_PlainEditorForm.actAppendExecute

    //***** Options actions  *****************************

procedure TN_PlainEditorForm.actWordWrapExecute( Sender: TObject );
// Toggle WordWrap Memo property
begin
  Memo.WordWrap := actWordWrap.Checked;
end; // end of procedure TN_PlainEditorForm.actWordWrapExecute

procedure TN_PlainEditorForm.actToolBarExecute( Sender: TObject );
// Toggle ToolBar visibility and Memo.Height
begin
  if ToolBar.Visible then Memo.Height := Memo.Height + 29
                     else Memo.Height := Memo.Height - 29;
  ToolBar.Visible := actToolBar.Checked;
end; // end of procedure TN_PlainEditorForm.actToolBarExecute

procedure TN_PlainEditorForm.actVerticalScrollBarExecute( Sender: TObject );
// Toggle ScrollBars visibility
// ( actVerticalScrollBar action OnExecute event handler)
begin
  if actVerticalScrollBar.Checked and
     actHorizontalScrollBar.Checked then
    Memo.ScrollBars := ssBoth
  else if not actVerticalScrollBar.Checked and
          actHorizontalScrollBar.Checked then
    Memo.ScrollBars := ssHorizontal
  else if actVerticalScrollBar.Checked and
          not actHorizontalScrollBar.Checked then
    Memo.ScrollBars := ssVertical
  else
    Memo.ScrollBars := ssNone;
end; // end of procedure TN_PlainEditorForm.actVerticalScrollBarExecute

procedure TN_PlainEditorForm.actHorizontalScrollBarExecute( Sender: TObject );
// Toggle ScrollBars visibility
// ( actHorizontalScrollBar action OnExecute event handler)
begin
  if actVerticalScrollBar.Checked and
     actHorizontalScrollBar.Checked then
    Memo.ScrollBars := ssBoth
  else if not actVerticalScrollBar.Checked and
          actHorizontalScrollBar.Checked then
    Memo.ScrollBars := ssHorizontal
  else if actVerticalScrollBar.Checked and
          not actHorizontalScrollBar.Checked then
    Memo.ScrollBars := ssVertical
  else
    Memo.ScrollBars := ssNone;
end; // end of procedure TN_PlainEditorForm.actHorizontalScrollBarExecute

procedure TN_PlainEditorForm.actButtonsExecute( Sender: TObject );
// Toggle Buttons visibility
// (hide ToolBar along with Buttons, but not restore them)
begin
  if bnOK.Visible then
  begin
    bnOK.Visible      := False;
    bnCancel.Visible  := False;
    bnApply.Visible   := False;
    if ToolBar.Visible then Memo.Height := Memo.Height + 29;
    ToolBar.Visible    := False;
    actToolBar.Checked := False;
    Memo.Align := alClient;
  end else
  begin
    bnOK.Visible     := True;
    bnCancel.Visible := True;
    bnApply.Visible  := True;
    Memo.Align := alTop;
    Memo.Height := Memo.Height - 32;
  end;
end; // end of procedure TN_PlainEditorForm.actButtonsExecute

procedure TN_PlainEditorForm.actDosToWinExecute( Sender: TObject );
// Convert Dos to Win (1251)
var
  AnsiStr: AnsiString;
begin
  AnsiStr := AnsiString(Memo.Text);
  Memo.Text := N_DosToWin( AnsiStr );
end; // procedure TN_PlainEditorForm.actDosToWinExecute

procedure TN_PlainEditorForm.actSortExecute( Sender: TObject );
// Sort all strings in Alphabetic order
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  SL.Text := Memo.Text;
  SL.Sort;
  Memo.Text := SL.Text;
  SL.Free;
end;

procedure TN_PlainEditorForm.actViewAsHexExecute( Sender: TObject );
// View Text in Memo As Hex
begin
  ContentAsText := Memo.Lines.Text;
  Memo.Lines.Clear;
  N_ConvTextToHex ( ContentAsText, Memo.Lines, 16000 );
end; // procedure TN_PlainEditorForm.actViewAsHexExecute

procedure TN_PlainEditorForm.actViewAsTextExecute( Sender: TObject );
// View Text in Memo As Text
begin
  if ContentAsText <> '' then
    Memo.Lines.Text := ContentAsText;
end; // procedure TN_PlainEditorForm.actViewAsTextExecute

procedure TN_PlainEditorForm.actStayOnTopExecute( Sender: TObject );
// toggle StayOnTop mode
begin
  if actStayOnTop.Checked then FormStyle := fsStayOnTop
                          else FormStyle := fsNormal;
end; // procedure TN_PlainEditorForm.actStayOnTopExecute


    //***** Control actions  *****************************

procedure TN_PlainEditorForm.ControlApplyExecute( Sender: TObject );
// Execute external action if any
begin
  if Assigned(ApplyProcObj) then ApplyProcObj( Memo.Lines.Text );
end;

procedure TN_PlainEditorForm.ControlOKExecute( Sender: TObject );
// Execute external action if any and close Self
begin
  ControlApplyExecute( Sender );
  Close;
  ModalResult := mrOK; // should be set AFTER Close, (Close set it to mrCancel)
end;

procedure TN_PlainEditorForm.ControlCancelExecute( Sender: TObject );
// Close Self
begin
  Close;
  ModalResult := mrCancel; // should be set AFTER Close, (Close set it to mrCancel)
end;


    //***** On Event Handlers  *****************************

procedure TN_PlainEditorForm.FormShow( Sender: TObject );
// Update Caret Position in edRowCol in FormShow event
begin
  ShowCaretPos();
end; // end of procedure TN_PlainEditorForm.FormShow

procedure TN_PlainEditorForm.MemoMouseDown( Sender: TObject;
                     Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
// Update Caret Position in edRowCol in OnMouseDown event
begin
  ShowCaretPos();
end; // end of procedure TN_PlainEditorForm.MemoMouseDown

procedure TN_PlainEditorForm.MemoKeyDown( Sender: TObject; var Key: Word;
                                                          Shift: TShiftState);
// Update Caret Position in edRowCol in KeyDown event
begin
  ShowCaretPos();

  if (Char(Key) = 'A') and (ssCtrl in Shift) then
    Memo.SelectAll();
    
end; // end of procedure TN_PlainEditorForm.MemoKeyDown

procedure TN_PlainEditorForm.miViewModeClick( Sender: TObject );
// toggle Hex / Text View mode
begin
  if HexView then
  begin
    actViewAsTextExecute( Sender );
    miViewMode.Caption := 'View As Hex';
    HexView := False;
  end else
  begin
    actViewAsHexExecute( Sender );
    miViewMode.Caption := 'View As Text';
    HexView := True;
  end;
end; // procedure TN_PlainEditorForm.miViewModeClick

procedure TN_PlainEditorForm.FormClose( Sender: TObject;
                                                   var Action: TCloseAction );
begin
  Inherited;
end; // end of procedure TN_PlainEditorForm.FormClose

    //***** Private Procedures  *****************************

procedure TN_PlainEditorForm.ShowCaretPos();
// Show Caret Position in EdRowCol.Text (used in OnMoseDown and in OnKeyDown)
begin
  EdRowCol.Text := Format( 'R:%4d, C:%3d',
                           [Memo.CaretPos.Y, Memo.CaretPos.X] );
end; // end of procedure TN_PlainEditorForm.ShowCaretPos();

procedure TN_PlainEditorForm.InitTextView();
// Initialize Text View (should be call before opening new file
begin
  miViewMode.Caption := 'View As Hex';
  HexView := False;
end; // end of procedure TN_PlainEditorForm.InitTextView

procedure TN_PlainEditorForm.OpenFileAsText( AFileName: string );
// Open given File As Text
begin
  InitTextView();
  Memo.Lines.Clear();
  Memo.Lines.LoadFromFile( AFileName );
  ShowCaretPos();
  Caption := 'Edit - ' + AFileName;
  edRowCol.Text := 'Opened';
end; // end of procedure TN_PlainEditorForm.OpenFileAsText

procedure TN_PlainEditorForm.OpenFileAsHex( AFileName: string );
// Open given File As Hex
var
  FileSize: Longint;
  Content: string;
  FS: TFileStream;
begin
  miViewMode.Visible := False;
  HexView := True;
  FS := TFileStream.Create( AFileName, fmOpenRead );
  FileSize := FS.Seek( 0, soFromEnd );
  if FileSize > 16000 then FileSize := 16000;
  SetLength( Content, FileSize );
  FS.Seek( 0, soBeginning );
  FS.Read( Content[1], FileSize );
  FS.Free;

  Memo.Lines.Clear();
  N_ConvTextToHex ( Content, Memo.Lines, 16000 );
  Caption := 'Hex View - ' + AFileName;
  edRowCol.Text := 'Opened';
end; // end of procedure TN_PlainEditorForm.OpenFileAsHex


    //*********** Global Procedures  *****************************

//*******************************************  N_ShowFileSection  ******
// Show Section ASName from File AFName in Plain Editor
//
procedure N_ShowFileSection( AFName, ASName: string; AOwner: TN_BaseForm );
begin
  with N_CreatePlainEditorForm( AOwner ) do
  begin
    N_GetSectionFromFile( K_ExpandFileName(AFName), Memo.Lines, ASName );
    Show();
  end;
end; // end of procedure N_ShowFileSection

//*******************************************  N_CreatePlainEditorForm  ******
// Create new instance of N_PlainEditorForm
//
function N_CreatePlainEditorForm( AOwner: TN_BaseForm ): TN_PlainEditorForm;
begin
  Result := TN_PlainEditorForm.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );
    OpenDialog.InitialDir := N_InitialFileDir;
    AppendMode := False; // set "Save Mode"
  end;
end; // end of function N_CreatePlainEditorForm

{
//*******************************************  N_GetPlainEditorForm  ******
// Create N_PlainEditorForm in N_PlainEditorForm if not already created
//
function N_GetPlainEditorForm(): TN_PlainEditorForm;
begin
  if N_PlainEditorForm = nil then
    N_PlainEditorForm := N_CreatePlainEditorForm();
  Result := N_PlainEditorForm;
end; // end of function N_GetPlainEditorForm
}

end.
