unit N_RichEdF;
// Rich Text Editor Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdActns, ExtActns, ActnList, StdCtrls, ToolWin, ActnMan,
  ActnCtrls, ActnMenus, ComCtrls, XPStyleActnCtrls,
  N_Types, N_Lib1, N_BaseF;

type TN_RichEditorForm = class( TN_BaseForm )
    ActionManager1: TActionManager;
    ActionMainMenuBar1: TActionMainMenuBar;
    aFileOpen: TFileOpen;
    aFileSaveAs: TFileSaveAs;
    aFilePrintSetup: TFilePrintSetup;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    EditUndo1: TEditUndo;
    EditDelete1: TEditDelete;
    RichEdit: TRichEdit;
    RichEditBold1: TRichEditBold;
    RichEditItalic1: TRichEditItalic;
    RichEditUnderline1: TRichEditUnderline;
    RichEditStrikeOut1: TRichEditStrikeOut;
    RichEditBullets1: TRichEditBullets;
    RichEditAlignLeft1: TRichEditAlignLeft;
    RichEditAlignRight1: TRichEditAlignRight;
    RichEditAlignCenter1: TRichEditAlignCenter;
    SearchFind1: TSearchFind;
    SearchFindNext1: TSearchFindNext;
    SearchReplace1: TSearchReplace;
    SearchFindFirst1: TSearchFindFirst;
    FontEdit1: TFontEdit;
    aFilePrintDlg: TPrintDlg;
    aFileNew: TAction;
    aFileSave: TAction;
    StatusBar: TStatusBar;
    aOptionsWordWrap: TAction;
    aOptionsPlainText: TAction;
    aFileAppend: TAction;
    actDOS2WIN: TAction;

    //***** File actions
    procedure aFileNewExecute     ( Sender: TObject );
    procedure aFileOpenAccept     ( Sender: TObject );
    procedure aFileSaveExecute    ( Sender: TObject );
    procedure aFileSaveAsBeforeExecute ( Sender: TObject );
    procedure aFileSaveAsAccept   ( Sender: TObject );
    procedure aFileAppendExecute  ( Sender: TObject );
    procedure aFilePrintDlgAccept ( Sender: TObject );

    //***** Options actions
    procedure aOptionsPlainTextExecute ( Sender: TObject );
    procedure aOptionsWordWrapExecute  ( Sender: TObject );

    //**** On Event Handlers
    procedure RichEditMouseDown ( Sender: TObject; Button: TMouseButton;
                                          Shift: TShiftState; X, Y: Integer);
    procedure RichEditKeyDown   ( Sender: TObject; var Key: Word;
                                          Shift: TShiftState );
    procedure FormClose         ( Sender: TObject; var Action: TCloseAction ); override;
    procedure actDOS2WINExecute ( Sender: TObject );
  private
    AppendMode: boolean; // True if Append to file instead of save to file
    procedure ShowCaretPos ();
  public

    procedure OpenFile ( AFName: string );
end; // end of type TN_RichEditorForm = class(TForm)
type TN_PRichEditorForm = ^TN_RichEditorForm;

function  N_CreateRichEditorForm ( AOwner: TN_BaseForm = nil ): TN_RichEditorForm;
procedure N_ShowFileInRichEditor ( FileName: string );
procedure N_StrAdd ( Str: string );

var
  N_InfoRichEditor: TN_RichEditorForm;

implementation
uses
   N_Lib0;
{$R *.dfm}

    //***** File actions  *****************************

procedure TN_RichEditorForm.aFileNewExecute( Sender: TObject );
// Clear RichEdit.Lines and current file name
begin
  RichEdit.Lines.Clear();
  aFileOpen.Dialog.FileName := '';
  StatusBar.SimpleText := '';
end; // end of procedure TN_RichEditorForm.aFileNewExecute

procedure TN_RichEditorForm.aFileOpenAccept( Sender: TObject );
// Open File
begin
  OpenFile( aFileOpen.Dialog.FileName );
end; // end of procedure TN_RichEditorForm.aFileOpenAccept

procedure TN_RichEditorForm.aFileSaveExecute( Sender: TObject );
// Save RichEdit.Lines in last opened File
begin
  if aFileOpen.Dialog.FileName = '' then // first Save after New action
  begin
    if aFileSaveAs.Dialog.FileName = '' then
      aFileSaveAs.Dialog.FileName := '*.*';

    aFileSaveAs.ExecuteTarget( nil ); // choose File in Dialog and Save
  end else // Save after Open, Save, SaveAs, Append (not after New)
  begin
    RichEdit.Lines.SaveToFile( aFileOpen.Dialog.FileName );
    StatusBar.SimpleText := 'File was saved OK';
  end;
end; // end of procedure TN_RichEditorForm.aFileSaveExecute

procedure TN_RichEditorForm.aFileSaveAsBeforeExecute( Sender: TObject );
// set appropriate InitialDir and FileName in SaveAs Dialog
// if they are empty
begin
  if aFileSaveAs.Dialog.InitialDir = '' then
    aFileSaveAs.Dialog.InitialDir := aFileOpen.Dialog.InitialDir;
  if aFileSaveAs.Dialog.FileName = '' then
    aFileSaveAs.Dialog.FileName := aFileOpen.Dialog.FileName;
end; // end of procedure TN_RichEditorForm.aFileSaveAsBeforeExecute

procedure TN_RichEditorForm.aFileSaveAsAccept( Sender: TObject );
//  Save or Append RichEdit.Lines in chosen by SaveAs Dialog File
//  (or given manualy in aFileSaveAs.Dialog.FileName field)
begin
  if AppendMode then // Append (not Save)
  begin
    if not RichEdit.PlainText then
    begin
      N_WarnByMessage( 'Can not Append in not PlainText mode!' );
      Exit;
    end;
    if FileExists( aFileSaveAs.Dialog.FileName ) then
    begin                          // Apend to existisng file
      with TStringList.Create() do
      begin
        LoadFromFile( aFileSaveAs.Dialog.FileName );
        AddStrings( RichEdit.Lines );
        SaveToFile( aFileSaveAs.Dialog.FileName );
        Destroy;
      end;
    end else // Append to absent file (same as Save to file)
    begin
      RichEdit.Lines.SaveToFile( aFileSaveAs.Dialog.FileName );
    end;
    StatusBar.SimpleText := 'Text was Appended OK to file  "' +
                                  aFileSaveAs.Dialog.FileName + '"';
  end else //********** Save (not Append)
  begin
    Caption := 'Edit : ' + aFileSaveAs.Dialog.FileName;
    RichEdit.Lines.SaveToFile( aFileSaveAs.Dialog.FileName );
    aFileOpen.Dialog.FileName := aFileSaveAs.Dialog.FileName; // for next Save
    StatusBar.SimpleText := 'File was saved OK';
  end;
end; // end of procedure TN_RichEditorForm.aFileSaveAsAccept

procedure TN_RichEditorForm.aFileAppendExecute( Sender: TObject );
// Append RichEdit.Lines to chosen by SaveAs Dialog File
begin
  AppendMode := True;
  aFileSaveAs.ExecuteTarget( nil ); // choose File in Dialog and Append
  AppendMode := False;
end; // end of procedure TN_RichEditorForm.aFileAppendExecute

procedure TN_RichEditorForm.aFilePrintDlgAccept( Sender: TObject );
// Print RichEdit.Lines to Printer after Print Dialog
begin
  RichEdit.Print( 'Printing from RichEdit' );
end; // procedure TN_RichEditorForm.aFilePrintDlgAccept

    //***** Options actions  *****************************

procedure TN_RichEditorForm.aOptionsPlainTextExecute( Sender: TObject );
// Toggle PlainText RichEdit property
begin
  RichEdit.PlainText := not RichEdit.PlainText;
  aOptionsPlainText.Checked := RichEdit.PlainText;
end; // end of procedure TN_RichEditorForm.aOptionsPlainTextExecute

procedure TN_RichEditorForm.aOptionsWordWrapExecute( Sender: TObject );
// Toggle WordWrap RichEdit property
begin
  RichEdit.WordWrap := not RichEdit.WordWrap;
  aOptionsWordWrap.Checked := RichEdit.WordWrap;
end; // end of procedure TN_RichEditorForm.aOptionsWordWrapExecute

    //***** On Event Handlers  *****************************

procedure TN_RichEditorForm.RichEditMouseDown( Sender: TObject;
                     Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
// Update Caret Position in StatusBar in OnMouseDown event
begin
  ShowCaretPos();
end; // end of procedure TN_RichEditorForm.RichEditMouseDown

procedure TN_RichEditorForm.RichEditKeyDown( Sender: TObject; var Key: Word;
                                                          Shift: TShiftState);
// Update Caret Position in StatusBar in KeyDown event
begin
  ShowCaretPos();
end; // end of procedure TN_RichEditorForm.RichEditKeyDown

procedure TN_RichEditorForm.FormClose( Sender: TObject;
                                       var Action: TCloseAction );
// if Self is N_InfoRichEditor, then Set N_InfoRichEditor := nil
// to be able to create it again in N_StrAdd procedure
begin
  inherited;
end; // end of procedure TN_RichEditorForm.FormClose

    //***** Private methods  *****************************

procedure TN_RichEditorForm.ShowCaretPos();
// Show Caret Position in StatusBar (used in OnMoseDown and in OnKeyDown)
begin
  StatusBar.SimpleText := Format( 'Row : %3d,  Col : %2d',
                            [RichEdit.CaretPos.Y, RichEdit.CaretPos.X] );
end; // end of procedure TN_RichEditorForm.ShowCaretPos();

    //***** Public methods  *****************************

procedure TN_RichEditorForm.OpenFile( AFName: string );
// Open give File
begin
  Caption := 'Edit : ' + AFName;
  RichEdit.Lines.Clear();
  RichEdit.Lines.LoadFromFile( AFName );
  ShowCaretPos();
end; // end of procedure TN_RichEditorForm.OpenFile();


    //*********** Global Procedures  *****************************

//*******************************************  N_CreateRichEditorForm  ******
// Create new instance of N_RichEditorForm
//
function N_CreateRichEditorForm( AOwner: TN_BaseForm ): TN_RichEditorForm;
begin
  Result := TN_RichEditorForm.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );
    aFileOpen.Dialog.InitialDir := N_InitialFileDir;
    AppendMode := False; // set "Save Mode"
  end;
end; // end of function N_CreateRichEditorForm

//*******************************************  N_ShowFileInRichEditor  ******
// show given text file in RichEditor window
//
procedure N_ShowFileInRichEditor( FileName: string );
begin
  if not FileExists( FileName ) then
  begin
    N_WarnByMessage( 'File  "' + FileName + '"  not found!' );
    Exit;
  end;

  with N_CreateRichEditorForm() do
  begin
    aFileOpen.Dialog.InitialDir := ExtractFilePath( FileName );
    aFileOpen.Dialog.FileName   := FileName;
    aFileOpenAccept( nil ); // Open given File (FileName)
    Show();
  end;
end; // end of procedure N_ShowFileInRichEditor

//*****************************************************  N_StrAdd  ******
// create N_InfoRichEditor if not yet and add given string to it
// (show it, if it was not visible)
//
procedure N_StrAdd( Str: string );
begin
  if N_InfoRichEditor = nil then N_InfoRichEditor := N_CreateRichEditorForm();
  N_InfoRichEditor.RichEdit.Lines.Add( Str );
  if not N_InfoRichEditor.Visible then N_InfoRichEditor.Show;
end; // end of procedure N_StrAdd

procedure TN_RichEditorForm.actDOS2WINExecute( Sender: TObject );
var
  AnsiStr: AnsiString;
begin
//  RichEdit.Text := N_DosToWin( RichEdit.Text );
  AnsiStr := AnsiString(RichEdit.Text);
  RichEdit.Text := N_DosToWin( AnsiStr );
end; // procedure TN_RichEditorForm.actDOS2WINExecute

end.
