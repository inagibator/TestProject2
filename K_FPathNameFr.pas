unit K_FPathNameFr;
// Frame that implements Label, FileName ComboBox and Browse button for
//                choosing FileName with OpenDialog

{$WARN UNIT_PLATFORM OFF}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles,
  N_Types;

type
  TK_FPathNameFrame = class(TFrame)
    mbPathName: TComboBox;
    bnBrowse_1: TButton;
    LbPathName: TLabel;
    procedure bnBrowse_1Click     ( Sender: TObject );
    procedure mbPathNameKeyDown ( Sender: TObject; var Key: Word;
                                                       Shift: TShiftState);
    procedure mbPathNameCloseUp(Sender: TObject);
  private
  public
    MemIniFile: TMemIniFile; // Mem Ini file object
    SectionName: string;     // Section Name in Mem Ini file
    SelectCaption : string;  // SelectFilePath Dialogue Саption
    Win31StyleFlag : Boolean;// Win3.1 style dialog show
    PrevPathName : string;     // string to compare for detecting FIle Name changing
    MaxListSize: integer;      // Max List Size in mbFileName ComboBox
    OnChange: TN_ProcObj;
    procedure Change   ( );
    procedure AddNameToTop   ( APathName: string );
    function TopName : string;
//    procedure InitFromMemIniFile ( AMemIniFile: TMemIniFile;
//                                                     ASectionName: string );
//    procedure UpdateMemIniFile();
    procedure SetEnabledAll( AEnabled : Boolean );

  end;

implementation

uses
  FileCtrl,
  N_Lib1,
  K_CLib0;

const K_MaxNamesInFrFName = 20; // max list size in ComboBox

{$R *.DFM}

procedure TK_FPathNameFrame.bnBrowse_1Click(Sender: TObject);
// Browse button:
// execute Path Select dialog and update mbPathName ComboBox fields
var
  APath : string;
  APath1 : string;
  SelResult : Boolean;
begin
//  APath := ExcludeTrailingPathDelimiter( mbPathName.Text );
  APath := mbPathName.Text;
//**** self Path select dialog
//  if K_SelectPathName( APath, APath ) then // file was choosen,
//**** Delfi Path select dialog in Win3.1 style
//  if SelectDirectory(APath, [sdAllowCreate, sdPerformCreate, sdPrompt], -1) then
//**** Delfi Path select dialog in Win9.x style
//0  if SelectDirectory( 'Выбор пути для сохранения копии сайта', APath, APath ) then
//1  if SelectDirectory( SelectCaption, APath, APath ) then
//2  if SelectDirectory( APath, [sdAllowCreate, sdPerformCreate, sdPrompt], -1) then
//3  if SelectDirectory( APath, [sdAllowCreate, sdPrompt], -1) then
   if APath <> '' then
  begin
    while not SysUtils.DirectoryExists(APath) do
    begin
      APath1 := APath;
      APath := ExtractFilePath( ExcludeTrailingPathDelimiter(APath) );
      if APath1 = APath then Break;
    end;
  end;

  if Win31StyleFlag then
    SelResult := SelectDirectory( APath, [sdAllowCreate, sdPrompt], -1 )
  else
    SelResult := K_SelectFolderNew( SelectCaption, APath );
//    SelResult := K_SelectFolder( SelectCaption, '', APath );
//    SelResult := K_SelectFolder( SelectCaption, '\', APath );
//    SelResult := K_SelectFolder( SelectCaption, ExtractFileDrive(APath), APath );
//    SelResult := SelectDirectory( SelectCaption,
//              IncludeTrailingPathDelimiter(ExtractFileDrive(APath)), APath );
  if SelResult then
  begin // add new file to mbPathName.Items at Top position
//    mbPathName.Text := APath; // new File Name
//    AddNameToTop( mbPathName.Text );
//    Change();
    AddNameToTop( IncludeTrailingPathDelimiter(APath) );
  end; // if OpenDialog.Execute then // file was choosen,
end; // end procedure TK_FPathNameFrame.bnBrowseClick

procedure TK_FPathNameFrame.mbPathNameKeyDown( Sender: TObject;
                                       var Key: Word; Shift: TShiftState);
// OnKeyDown event handler (add current file name to top)
begin
  if Key = VK_RETURN then
    AddNameToTop( mbPathName.Text );
end; // end of procedure TK_FPathNameFrame.mbPathNameKeyDown

procedure TK_FPathNameFrame.AddNameToTop( APathName: string );
// add given FileName to Top position of mbPathName ComboBox Items
var
//  Ind: integer;
//  SavedText: string;
  FNameChanged : Boolean;
begin
{
  if mbPathName.Items.Count > K_MaxNamesInFrFName then //  maintain
     mbPathName.Items.Delete( mbPathName.Items.Count-1 );  // Items size

  Ind := mbPathName.Items.IndexOf( PathName );
  SavedText := PathName;

  if Ind = 0 then Exit; // already on Top, nothing to do
  if Ind > 0 then // delete old instance of PathName
    mbPathName.Items.Delete( Ind );

  mbPathName.Items.Insert( 0, SavedText ); // add to Top
  mbPathName.Text := SavedText;
begin
}
  if MaxListSize = 0 then
    MaxListSize := 20;
  if trim(APathName) <> '' then // empty ComboBox Items cause Windows error!
  begin
//    if PrevPathName = '' then // 2021-03-03 skip this line because of wrong "changed" logic
    PrevPathName := mbPathName.Text;
    FNameChanged := PrevPathName <> APathName;
    mbPathName.Text := APathName;
    N_AddTextToTop( mbPathName, MaxListSize );
    if FNameChanged then Change();
    PrevPathName := APathName;
  end
  else
  if PrevPathName <> APathName then Change();
end; // end of procedure TK_FPathNameFrame.AddNameToTop

function TK_FPathNameFrame.TopName : string;
begin
  Result := mbPathName.Text;
end;
{
procedure TK_FPathNameFrame.InitFromMemIniFile( AMemIniFile: TMemIniFile;
                                               ASectionName: string);
// read mbPathName ComboBox fields from given Section in given MemIniFile object
begin
  MemIniFile  := AMemIniFile;  // save MemIniFile object
  SectionName := ASectionName; // save SectionName in MemIniFile object
  N_MemIniToComboBox( SectionName, mbPathName );
end; // end of procedure TK_FPathNameFrame.InitFromMemIniFile

procedure TK_FPathNameFrame.UpdateMemIniFile;
// update MemIniFile object by mbPathName ComboBox fields
begin
  if MemIniFile = nil then Exit; // Items were not initialized from MemIniFile
  if N_MemIniFile = nil then Exit; // N_MemIniFile was already destroyed
  N_ComboBoxToMemIni( SectionName, mbPathName );
end; // end of procedure TK_FPathNameFrame.UpdateMemIniFile
}

procedure TK_FPathNameFrame.mbPathNameCloseUp(Sender: TObject);
begin
//  Change();
//  AddNameToTop( mbPathName.Text );
  with mbPathName do
    AddNameToTop( Items[ItemIndex] );
end;

procedure TK_FPathNameFrame.Change();
begin
  if Assigned(OnChange) then OnChange;
end;

procedure TK_FPathNameFrame.SetEnabledAll(AEnabled: Boolean);
begin
  Self.Enabled := AEnabled;
  Self.bnBrowse_1.Enabled := AEnabled;
  Self.LbPathName.Enabled := AEnabled;
end;

end.
