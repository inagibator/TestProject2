unit N_FNameFr;
// File Name Frame for choosing FileName

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, ComCtrls, ActnList, ExtDlgs, Menus,
  N_Types, N_BaseF;

type TN_FileNameFrame = class( TFrame )
    mbFileName: TComboBox;
    bnBrowse_1: TButton;
    Label1: TLabel;
    OpenDialog: TOpenDialog;
    OpenPictureDialog: TOpenPictureDialog;
    FilePopupMenu: TPopupMenu;
    FNameActList: TActionList;
    aViewByExtension: TAction;
    aRename: TAction;
    aDelete: TAction;
    ViewFileAsText1: TMenuItem;
    N1: TMenuItem;
    RenameFile1: TMenuItem;
    DeleteFile1: TMenuItem;
    aCreate: TAction;
    aCreateTXT1: TMenuItem;
    aCopy: TAction;
    CopyFile1: TMenuItem;
    aCompile: TAction;
    N2: TMenuItem;
    miCompileSPLFile: TMenuItem;
    aViewAsHex: TAction;
    ViewFileAsHex1: TMenuItem;
    aViewAsPict: TAction;
    aViewAsPlainText: TAction;
    aViewAsRichText: TAction;
    aViewAsWEB: TAction;
    ViewFileAsPlainText1: TMenuItem;
    ViewFileAsRichText1: TMenuItem;
    ViewFileAsPicture1: TMenuItem;
    ViewFileAsWEBDocument1: TMenuItem;
    aViewAVIInfo: TAction;
    aViewAVIInfo1: TMenuItem;

    constructor Create          ( AOwner: TComponent ); override;
    procedure bnBrowse_1Click     ( Sender: TObject );
    procedure mbFileNameKeyDown ( Sender: TObject; var Key: Word;
                                                       Shift: TShiftState );
    procedure mbFileNameChange  ( Sender: TObject );
    procedure mbFileNameCloseUp ( Sender: TObject );
    procedure mbFileNameContextPopup ( Sender: TObject; MousePos: TPoint;
                                                        var Handled: Boolean );

    //*********************** FNameActList Actions ****************************
    procedure aViewByExtensionExecute ( Sender: TObject );
    procedure aViewAsPlainTextExecute ( Sender: TObject );
    procedure aViewAsRichTextExecute  ( Sender: TObject );
    procedure aViewAsWEBExecute       ( Sender: TObject );
    procedure aViewAsHexExecute       ( Sender: TObject );
    procedure aViewAsPictExecute      ( Sender: TObject );
    procedure aViewAVIInfoExecute     ( Sender: TObject );

    procedure aCreateExecute     ( Sender: TObject );
    procedure aCopyExecute       ( Sender: TObject );
    procedure aRenameExecute     ( Sender: TObject );
    procedure aDeleteExecute     ( Sender: TObject );
    procedure aCompileExecute    ( Sender: TObject );

    procedure FilePopupMenuPopup ( Sender: TObject );

  public
    ParentForm: TN_BaseForm;
    MemIniFile: TMemIniFile;   // Mem Ini file object
    SectionName: string;       // Section Name in Mem Ini file
    MaxListSize: integer;      // Max List Size in mbFileName ComboBox
    SomeStatusBar: TStatusBar; // External StatusBar, used in ShowMessage method
    OnChange: TN_ProcObj;      // External ProcOfObj, called after FileName was changed
    PrevFileName : string;     // string to compare for detecting FIle Name changing

    procedure Change ();
    procedure ShowMessage( AStr1: string; AStr2: string = ''; AShowFirst: boolean = True );
    function  GetFileName (): string;
    procedure AddFileNameToTop ( AFileName: string = ''  );
//    procedure ViewFileInTextEditor ();
//    procedure ViewFileAsHex        ();
//    procedure ViewFileAsPicture    ();
//    procedure ViewFile             ();
end; // type TN_FileNameFrame = class( TFrame )


implementation
uses
  K_CLib0, K_SParse1, // K_Arch,
  N_Lib0, N_Lib1, N_PlainEdF, N_RichEdF, N_ME1,
  N_MsgDialF, N_WebBrF, N_Video, N_ButtonsF; // 

{$R *.DFM}

    //***************  TN_FileNameFrame class methods  *****************

constructor TN_FileNameFrame.Create( AOwner: TComponent );
begin
  Inherited;
  MaxListSize := 20;
  mbFileName.PopupMenu := nil;

end;

    //***************  TN_FileNameFrame handlers  **********************

procedure TN_FileNameFrame.bnBrowse_1Click( Sender: TObject );
// Execute FileOpen dialog and update mbFileName ComboBox fields
begin
  if N_KeyIsDown( N_VKShift ) then // use OpenPictureDialog
  begin

    if mbFileName.Text <> '' then
    begin
      OpenPictureDialog.InitialDir := ExtractFilePath( mbFileName.Text );
      OpenPictureDialog.FileName   := ExtractFileName( mbFileName.Text );
    end;

    if N_FindFileExt( N_OpenPictureExtensions, mbFileName.Text ) = -1 then
      OpenPictureDialog.FileName   := '*.*';

    if OpenPictureDialog.Execute then // file was choosen,
    begin // add new file to mbFileName.Items at Top position
      AddFileNameToTop( OpenPictureDialog.FileName ); // new File Name
    end; // if OpenPictureDialog.Execute then // file was choosen,

  end else //************************ use OpenDialog
  begin

    if mbFileName.Text <> '' then
    begin
      OpenDialog.InitialDir := ExtractFilePath( mbFileName.Text );
      OpenDialog.FileName   := ExtractFileName( mbFileName.Text );
    end;

    if OpenDialog.Execute then // file was choosen,
    begin // add new file to mbFileName.Items at Top position
      AddFileNameToTop( OpenDialog.FileName ); // new File Name
    end; // if OpenDialog.Execute then // file was choosen,

  end;
end; // end procedure TN_FileNameFrame.bnBrowseClick

procedure TN_FileNameFrame.mbFileNameKeyDown( Sender: TObject;
                                          var Key: Word; Shift: TShiftState );
// OnKeyDown event handler (add current file name to top)
begin
  if Key = VK_RETURN then
      AddFileNameToTop( mbFileName.Text );
end; // end of procedure TN_FileNameFrame.mbFileNameKeyDown

procedure TN_FileNameFrame.mbFileNameChange( Sender: TObject );
// Call Parent change routine in OnChange event
begin
//  Change();
end; // end of procedure TN_FileNameFrame.mbFileNameChange

procedure TN_FileNameFrame.mbFileNameCloseUp( Sender: TObject );
// just add choosen Items element to Top of Items list
begin
  with mbFileName do   AddFileNameToTop( Items[ItemIndex] );
//  Change();
end; // procedure TN_FileNameFrame.mbFileNameCloseUp
procedure TN_FileNameFrame.mbFileNameContextPopup( Sender: TObject;
                                      MousePos: TPoint; var Handled: Boolean );
// Show Popup Menu On Frame ContextPopup Event
//
// for both: ComboBox mb and Frame - PopupMenu property should be set!!
// (otherwise standard context menu is shown by Delphi on Right Mouse Button Click)
begin
{
  SetUObj(); // Set ParentUObj and UObj fields
  if UObj = nil then Exit;

  SetPopupMenuCaptionsByUObj();
  ShowStr( 'Choose Action for ' + UObj.ObjName );

  with Mouse.CursorPos do
    PopupMenu.Popup( X, Y );

  Handled := True;
}
end; // procedure TN_FileNameFrame.mbFileNameContextPopup


    //*********************** FNameActList Actions ****************************

procedure TN_FileNameFrame.aViewByExtensionExecute( Sender: TObject );
// View File according to it's extension
begin
  ShowMessage( '???' );
{
var
  AFName: string;
  FileFlags: TN_FileExtFlags;
begin
  AFName := GetFileName();

  if AFName <> N_NotAString then // File Name exists
  begin
    AddFileNameToTop();
    FileFlags := N_GetFileFlagsByExt( AFName );

    if
    case FileType of
      fetNotDef:    aViewAsHexExecute( nil );
      fetPlainText: aViewAsPlainTextExecute( nil );
      fetRichText:  aViewAsRichTextExecute( nil );
      fetHTML:      aViewAsWEBExecute( nil );
      fetPicture:   aViewAsPictExecute( nil );
//      fetHTML:      N_ViewHTMLFile( AFName, @N_MEGlobObj.WebBrForm, ParentForm );
//      fetPicture:   N_ViewPicture( AFName, @N_MEGlobObj.RastVCTForm, ParentForm );
    end; // case FileType of

    ShowMessage( '' );
  end; // if AFName <> N_NotAString then // File Name exists
}
end; // procedure TN_FileNameFrame.aViewByExtensionExecute

procedure TN_FileNameFrame.aViewAsPlainTextExecute( Sender: TObject );
// View Edit File As Plain Text
var
  AFName: string;
begin
  AFName := GetFileName();
  if AFName <> N_NotAString then // File Name exists
  begin
    AddFileNameToTop();
    with N_GetMEPlainEditorForm( ParentForm ) do
    begin
      OpenFileAsText( AFName );
      Show();
    end;
  end;
end; // procedure TN_FileNameFrame.aViewAsPlainTextExecute

procedure TN_FileNameFrame.aViewAsRichTextExecute( Sender: TObject );
// View Edit File As Rich Text
var
  AFName: string;
begin
  AFName := GetFileName();
  if AFName <> N_NotAString then // File Name exists
  begin
    AddFileNameToTop();
    with N_GetMERichEditorForm( ParentForm ) do
    begin
      OpenFile( AFName );
      Show();
    end;
  end;
end; // procedure TN_FileNameFrame.aViewAsRichTextExecute

procedure TN_FileNameFrame.aViewAsWEBExecute( Sender: TObject );
// View File in WEB Browser
var
  AFName: string;
begin
  AFName := GetFileName();
  if AFName <> N_NotAString then // File Name exists
  begin
    AddFileNameToTop();
    with N_GetMEWebBrForm( ParentForm ) do
    begin
      Show(); // Show should be called before Navigate !
      WebBr.Navigate( 'file://' + AFName );
    end;
  end;
end; // procedure TN_FileNameFrame.aViewAsWEBExecute

procedure TN_FileNameFrame.aViewAsHexExecute( Sender: TObject );
// View File As Hex
var
  AFName: string;
begin
  AFName := GetFileName();
  if AFName <> N_NotAString then // File Name exists
  begin
    AddFileNameToTop();
    with N_GetMEPlainEditorForm( ParentForm ) do
    begin
      OpenFileAsHex( AFName );
      Show();
    end;
  end;
end; // procedure TN_FileNameFrame.aViewAsHexExecute

procedure TN_FileNameFrame.aViewAsPictExecute( Sender: TObject );
// View File as Picture
var
  AFName: string;
begin
  N_s := Name; // debug
  AFName := GetFileName();
  if AFName <> N_NotAString then // File Name exists
  begin
    AddFileNameToTop();
    with N_GetMERastVCTForm( ParentForm ) do
    begin
      ShowPictFile( AFName );
      Show();
    end;
  end;
end; // procedure TN_FileNameFrame.aViewAsPictExecute

procedure TN_FileNameFrame.aViewAVIInfoExecute( Sender: TObject );
// View Info about AVI File
var
  FName: string;
begin
  FName := GetFileName();
  if FName <> N_NotAString then // File Name exists
  begin
    AddFileNameToTop();
    with N_GetMEPlainEditorForm( ParentForm ) do
    begin
      N_AddVideoFileDescr( FName, memo.Lines );
      Show();
    end;
  end;
end; // procedure TN_FileNameFrame.aViewAVIInfoExecute

procedure TN_FileNameFrame.aCreateExecute( Sender: TObject );
// Create New Empty File
var
  Res: boolean;
begin
  Res := N_CreateNewFileDlg( mbFileName.Text );
  ShowMessage( 'File  "' + ExtractFileName(mbFileName.Text) + '"  Created OK',
                                                                     '', Res );
end; // procedure TN_FileNameFrame.aCreateTXTExecute

procedure TN_FileNameFrame.aCopyExecute( Sender: TObject );
// Create a Copy of File
var
  NewFName: string;
  Res: boolean;
begin
  NewFName := N_CreateFileCopyDlg( mbFileName.Text );
  Res := (NewFName <> '');
  if Res then
    mbFileName.Text := NewFName;

  ShowMessage( 'File  "' + ExtractFileName(NewFName) + '"  Created OK',
                                                                    '', Res );
end; // procedure TN_FileNameFrame.aCopyExecute

procedure TN_FileNameFrame.aRenameExecute( Sender: TObject );
// Rename File
var
  NewFName: string;
  Res: boolean;
begin
  NewFName := N_RenameFileDlg( mbFileName.Text );
  Res := (NewFName <> '');
  if Res then
    mbFileName.Text := NewFName;

  ShowMessage( 'New File Name is  "' + ExtractFileName(NewFName), '', Res );
end; // procedure TN_FileNameFrame.aRenameExecute

procedure TN_FileNameFrame.aDeleteExecute( Sender: TObject );
// Delete File
var
  Res: boolean;
begin
  Res := N_DeleteFileDlg( mbFileName.Text );
  ShowMessage( 'File  "' + ExtractFileName(mbFileName.Text) + '"  Deleted OK',
                                                                     '', Res );
end; // procedure TN_FileNameFrame.aDeleteExecute

procedure TN_FileNameFrame.aCompileExecute( Sender: TObject );
// Compile or Recompile SPL File
var
  Res: boolean;
begin
  Res := K_CompileFileUnit( mbFileName.Text, True );
  ShowMessage( 'Compiled OK', 'Compile Failed', Res );
end; // procedure TN_FileNameFrame.aCompileExecute

procedure TN_FileNameFrame.FilePopupMenuPopup( Sender: TObject );
// Set some Popup Menu Item Visibility
var
  FileExt: string;
begin
  FileExt := UpperCase(ExtractFileExt( mbFileName.Text ));
  miCompileSPLFile.Visible := True;
  if FileExt <> '.SPL' then
    miCompileSPLFile.Visible := False;
end; // procedure TN_FileNameFrame.FilePopupMenuPopup


    //***************  TN_FileNameFrame Public nethods  ********************

procedure TN_FileNameFrame.Change();
// Call Parent change routine
begin
  if Assigned(OnChange) then OnChange;
end; // end of procedure TN_FileNameFrame.Change

procedure TN_FileNameFrame.ShowMessage( AStr1, AStr2: string; AShowFirst: boolean );
// Show Astr1 or AStr2 in SomeStatusBar
begin
  if SomeStatusBar <> nil then
  begin
    if AShowFirst then
      SomeStatusBar.SimpleText := AStr1
    else
      SomeStatusBar.SimpleText := AStr2;
  end;
end; // procedure TN_FileNameFrame.aCreateTXTExecute

function TN_FileNameFrame.GetFileName(): string;
// rise OpenDialog if mbFileName.Text is empty,
// return mbFileName.Text
begin
  Result := N_NotAString;
  if mbFileName.Text = '' then
  begin
    if not OpenDialog.Execute then Exit
    else mbFileName.Text := OpenDialog.FileName;
  end;

  AddFileNameToTop();
  Result := K_ExpandFileName( mbFileName.Text );
end; // end of procedure TN_FileNameFrame.mbFileNameChange

procedure TN_FileNameFrame.AddFileNameToTop( AFileName: string );
// if AFileName <> '' then set mbFileName.Text by given AFileName and
// add given AFileName to Top position of mbFileName ComboBox Items
// if AFileName = '' add current mbFileName.Text to Top position
var
  FNameChanged : Boolean;
begin
  if trim(AFileName) <> '' then // empty ComboBox Items cause Windows error!
  begin
    if PrevFileName = '' then
      PrevFileName := mbFileName.Text;
    FNameChanged := PrevFileName <> AFileName;
    mbFileName.Text := AFileName;
    N_AddTextToTop( mbFileName, MaxListSize );
    if FNameChanged then Change();
    PrevFileName := AFileName;
  end
  else
  if PrevFileName <> AFileName then Change();
end; // end of procedure TN_FileNameFrame.AddFileNameToTop

end.
