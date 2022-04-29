unit N_HelpF;
// ShowHelp Form and related procedures

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ActnList, ToolWin, ComCtrls, StdCtrls,
  K_UDT1,
  N_Types, N_BaseF;

type TN_HelpForm = class( TN_BaseForm )
    ToolBar1: TToolBar;
    ActionList1: TActionList;
    ContentMenu: TPopupMenu;
    SeeAlsoMenu: TPopupMenu;
    asdasd1: TMenuItem;
    tbContent: TToolButton;
    RichEdit: TRichEdit;
    tbSeeAlso: TToolButton;
    tbHistory: TToolButton;
    tbOther: TToolButton;
    ToolButton1: TToolButton;
    bnCopyToClipboard: TToolButton;
    HistoryMenu: TPopupMenu;
    OtherMenu: TPopupMenu;
    MenuItem2: TMenuItem;

    procedure bnCopyToClipboardClick ( Sender: TObject );
    procedure ShowTopic ( Sender: TObject );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  public
    ContentFileNames:  TStringList;
    ContentTopicNames: TStringList;
    SeeAlsoFileNames:  TStringList;
    SeeAlsoTopicNames: TStringList;
    HistoryFileNames:  TStringList;
    HistoryTopicNames: TStringList;

    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_HelpForm = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

function  N_GetHelpFileContent ( AFileName: string ): TStringList;
procedure N_GetUDBaseHelpTopic ( AUDBase: TN_UDBase;
                                         out AFileName, ATopicName: string );

procedure N_ShowHelp ( AHelpForm: TN_HelpForm; AFileName, ATopicName: string ); overload;
procedure N_ShowHelp ( AFileAndTopicName: string; AOwner: TN_BaseForm ); overload;
procedure N_ShowHelp ( AFileName, ATopicName: string; AOwner: TN_BaseForm = nil ); overload;

function  N_CreateHelpForm ( AOwner: TN_BaseForm ): TN_HelpForm;


implementation
uses
  K_CLib0,
  N_Lib0, N_Lib1, N_ClassRef, N_ME1, N_ButtonsF,
  N_CompBase, N_Comp1, N_Comp2, N_Comp3, N_UDCMap, N_Lib2;
{$R *.dfm}

//****************  TN_HelpForm class handlers  ******************

procedure TN_HelpForm.bnCopyToClipboardClick( Sender: TObject );
// Copy All RichEdit Lines to Clipboard
var
  SavedStart, SavedLeng: integer;
begin
  with RichEdit do
  begin
    SavedStart := SelStart;
    SavedLeng  := SelLength;

    SelectAll();
    CopyToClipboard();

    SelStart := SavedStart;
    SelLength := SavedLeng;
  end; // with RichEdit do
end; // procedure TN_HelpForm.bnCopyToClipboardClick

procedure TN_HelpForm.ShowTopic( Sender: TObject );
// Show needed Topic (ContentMenu, SeeAlsoMenu and HistoryMenu OnClick Handler)
var
  MenuName, NewFileName, NewTopicName: string;
begin
  if not (Sender is TMenuItem) then Exit;

  with TMenuItem(Sender) do
  begin
    NewFileName  := ''; // to avoid warning
    NewTopicName := '';

    MenuName := GetParentComponent.Name;

    if MenuName = 'ContentMenu' then
    begin
      NewFileName  := ContentFileNames[MenuIndex];
      NewTopicName := ContentTopicNames[MenuIndex];
    end else if MenuName = 'SeeAlsoMenu' then
    begin
      NewFileName  := SeeAlsoFileNames[MenuIndex];
      NewTopicName := SeeAlsoTopicNames[MenuIndex];
    end else if MenuName = 'HistoryMenu' then
    begin
      NewFileName  := HistoryFileNames[MenuIndex];
      NewTopicName := HistoryTopicNames[MenuIndex];
    end;

  end; // with TmenuItem(Sender) do

  //***** Show NewTopicName from NewFileName

  if N_KeyIsDown( VK_SHIFT ) then // Show new Help Topic in New HelpForm
    N_ShowHelp( NewFileName, NewTopicName, Self )
  else // Show new Help Topic in Self Window
    N_ShowHelp( Self, NewFileName, NewTopicName );

end; // procedure TN_HelpForm.ShowTopic

procedure TN_HelpForm.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  ContentFileNames.Free;
  ContentTopicNames.Free;
  SeeAlsoFileNames.Free;
  SeeAlsoTopicNames.Free;
  HistoryFileNames.Free;
  HistoryTopicNames.Free;

  Inherited;
end; // procedure TN_HelpForm.FormClose

//****************  TN_HelpForm class public methods  ************

//***********************************  TN_HelpForm.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_HelpForm.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_HelpForm.CurStateToMemIni

//***********************************  TN_HelpForm.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_HelpForm.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_HelpForm.MemIniToCurState


    //*********** Global Procedures  *****************************

//**************************************************** N_GetHelpFileContent ***
// Return TStringList with given AFileName Content
//
function N_GetHelpFileContent( AFileName: string ): TStringList;
var
  HelpFileInd: integer;
  FullFileName: string;
  Found: boolean;
begin
  with N_MEGlobObj do
  begin
    Found := MEHelpFiles.Find( AFileName, HelpFileInd );

    if Found then // needed Help File was already Loaded
    begin
      Result := TStringList(MEHelpFiles.Objects[HelpFileInd]);
    end else // Load needed Help File
    begin
      Result := TStringList.Create();

      if AFileName[2] = '#' then // Full FileName is given
        FullFileName := K_ExpandFileName( AFileName )
      else // add MVHelpFiles Path
        FullFileName := K_ExpandFileName( '(#MVHelpFiles#)' + AFileName );

      if FileExists( FullFileName ) then
      begin
        Result.LoadFromFile( FullFileName );
        MEHelpFiles.AddObject( AFileName, Result );
      end;
    end; // end else // Load needed Help File
  end; // with N_MEGlobObj do
end; // function N_GetHelpFileContent

//**************************************************** N_GetUDBaseHelpTopic ***
// Return AFileName and ATopicName with Help about given AUDBase,
// on output AFileName = '' means that appropriate Help Topic was not found
//
procedure N_GetUDBaseHelpTopic( AUDBase: TN_UDBase;
                                         out AFileName, ATopicName: string );
var
  Str: string;
begin
  AFileName  := '';
  ATopicName := '';

  if AUDBase is TN_UDCompBase then // a Component
  begin
    //***** at first check Components, which TopicName depends upon theirs fields

    if AUDBase is TN_UDMapLayer then //****************** UDMap Layer
    begin
      AFileName := 'MVHelpComps1.txt';
      case TN_UDMapLayer(AUDBase).PISP()^.MLType of
        mltPoints1: ATopicName   := 'mltPoints1';
        mltLines1: ATopicName    := 'mltLines1';
        mltConts1: ATopicName    := 'mltConts1';
        mltHorLabels: ATopicName := 'mltHorLabels';
      end;
    end else if AUDBase is TN_UDAction then //*********** UDAction
    with TN_UDAction(AUDBase).PIDP()^ do
    begin
      AFileName  := 'MVHelpUDActions.txt';
      Str := CAActNames;
      ATopicName := N_ScanToken( Str );

      if ATopicName = '' then
        ATopicName := 'UDActionsList'
      else
      begin // ATopicName <> ''
        if ATopicName = '-' then // Get ProcAfter Name in next token
          ATopicName := N_ScanToken( Str );

        if (ATopicName = '') or (ATopicName = '-') then
          ATopicName := 'UDActionsList'
      end;
    end else // Components, which TopicName is in N_ClassTagArray
    begin
      AFileName := 'MVHelpComps2.txt';
      ATopicName := N_ClassTagArray[AUDBase.CI()];
    end;

    if ATopicName = '' then AFileName  := ''; // Help about Component not Found
  end else // not a Component
  begin

  end;

end; // procedure N_GetUDBaseHelpTopic

//************************************************* N_ShowHelp(NewHelpForm) ***
// Show Help Topic with given Name from given File in New HelpForm
//
procedure N_ShowHelp( AFileName, ATopicName: string; AOwner: TN_BaseForm );
var
  NewHelpForm: TN_HelpForm;
begin
  NewHelpForm := N_CreateHelpForm( AOwner );
  N_ShowHelp( NewHelpForm, AFileName, ATopicName );
end; // procedure N_ShowHelp(NewHelpForm)

//*************************************************** N_ShowHelp(OneString) ***
// Show Help Topic with Topic and File Name from given AFileAndTopicName
//
procedure N_ShowHelp( AFileAndTopicName: string; AOwner: TN_BaseForm );
var
  FileName, TopicName: string;
begin
  FileName := N_ScanToken( AFileAndTopicName );
  TopicName := N_ScanToken( AFileAndTopicName );
  N_ShowHelp( FileName, TopicName, AOwner );
end; // procedure N_ShowHelp(OneString)

//*********************************************** N_ShowHelp(GivenHelpForm) ***
// Show Help: Show given ATopicName from given AFileName in given HelpForm
// (Full version, used by other overloaded N_ShowHelp procedures)
//
procedure N_ShowHelp( AHelpForm: TN_HelpForm; AFileName, ATopicName: string );
var
  i, NRes: integer;
  Str, Prefix, SeeAlsoUserName, TopicUserName: string;
  SkipEmptyStrings: boolean;
  FileSL, TopicSL: TStringList;
  WrkMenuItem: TMenuItem;
begin
  if AFileName = '' then Exit;

  TopicSL := TStringList.Create(); // where to load Topic Content
  FileSL := N_GetHelpFileContent( AFileName ); // temporary, only to load TopicSL

  NRes := N_GetSectionFromStrings( FileSL, TopicSL, ATopicName );
  if NRes = -1 then // ATopicName not found in FileSL
  begin
    TopicSL.Add( 'Topic ' + ATopicName + ' not found in ' + AFileName );
  end;

  with AHelpForm do
  begin
    RichEdit.Lines.Clear;

    //***** Cleare SeeAlsoMenu and it's StringLists
    N_DeleteMenuItems( SeeAlsoMenu );
    SeeAlsoFileNames.Clear;
    SeeAlsoTopicNames.Clear;

    //***** Process TopicSL strings:
    //      Add all Topic rows to RichEdit.Lines
    //      and add needed items to SeeAlsoMenu
    //      get TopicUserName if given

    SkipEmptyStrings := True; // skip all first empty lines (is needed?)
    TopicUserName := '';

    for i := 0 to TopicSL.Count-1 do // Process TopicSL strings
    with RichEdit do
    begin
      Str := TopicSL[i];
      if SkipEmptyStrings and (Str = '') then Continue; // Skip Empty string after #SeeAlso: string

      Prefix := N_ScanToken( Str );

      if Prefix = '#UserName:' then // Str is Topic User Name
      begin
        SkipEmptyStrings := True;
        TopicUserName := Str;
        Continue;
      end;

      if Prefix = '#SeeAlso:' then // Str is data for SeeAlso Menu Item
      begin
        SkipEmptyStrings := True;
        SeeAlsoFileNames.Add( N_ScanToken( Str ) );  // File Name
        SeeAlsoTopicNames.Add( N_ScanToken( Str ) ); // Topic Name
        SeeAlsoUserName := Str; // Rest of Str

        WrkMenuItem := TMenuItem.Create( ContentMenu );
        SeeAlsoMenu.Items.Add( WrkMenuItem );

        if SeeAlsoUserName = '' then // get SeeAlso User Name from topic (now not implemented)
        with SeeAlsoTopicNames do
            SeeAlsoUserName := Strings[Count-1]; // use TopisName as SeeAlsoUserName

        WrkMenuItem.Caption := SeeAlsoUserName;
        WrkMenuItem.OnClick := ShowTopic; // OnClick Handler
        Continue;
      end; // if Prefix = '#SeeAlso:' then // Str is data for SeeAlso Menu Item

      //***** Here: Current String (TopicSL[i]) is Topic content string

      SkipEmptyStrings := False;
      Lines.Add( TopicSL[i] );

    end; // for i := 0 to TopicSL.Count-1 do // Process TopicSL strings

    //***** Add new Item to HistoryMenu

    HistoryFileNames.Add( AFileName );   // File Name
    HistoryTopicNames.Add( ATopicName ); // Topic Name
    WrkMenuItem := TMenuItem.Create( HistoryMenu );
    HistoryMenu.Items.Insert( 0, WrkMenuItem );
    if TopicUserName = '' then TopicUserName := ATopicName;
    WrkMenuItem.Caption := TopicUserName;
    WrkMenuItem.OnClick := ShowTopic; // OnClick Handler

    with RichEdit do // Mark first Row by Bold and Center
    begin
      SelStart := 0;
      SelLength := Length( Lines[0] );
      SelAttributes.Style := [fsBold];
      Paragraph.Alignment := taCenter;

      SelStart := 0;
      SelLength := 0;
    end; // with RichEdit do // Mark first Row by Bold and Center

  end; // with AHelpForm do

  AHelpForm.Show;

  TopicSL.Free;
end; // procedure N_ShowHelp

//******************************************************** N_CreateHelpForm ***
// Create and return new instance of TN_HelpForm
// AOwner - Owner of created Form
//
function N_CreateHelpForm( AOwner: TN_BaseForm ): TN_HelpForm;
var
  i, NumItems, NRes: integer;
  Str: string;
  WrkMenuItem: TMenuItem;
  FileSL, TopicSL: TStringList;
begin
  Result := TN_HelpForm.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );

    ContentFileNames  := TStringList.Create;
    ContentTopicNames := TStringList.Create;

    SeeAlsoFileNames  := TStringList.Create;
    SeeAlsoTopicNames := TStringList.Create;

    HistoryFileNames  := TStringList.Create;
    HistoryTopicNames := TStringList.Create;

    //***** Prepare ContentMenu form HelpRoot section in MVHelpMain.txt file

    FileSL := N_GetHelpFileContent( 'MVHelpMain.txt' );
    TopicSL := TStringList.Create;

    NRes := N_GetSectionFromStrings( FileSL, TopicSL, 'HelpRoot' );
    if NRes = -1 then // 'HelpRoot' Topic not found
    begin
      TopicSL.Free;
      Exit;
    end;

    NumItems := TopicSL.Count; // Number of Items in ContentMenu

    for i := 0 to NumItems-1 do // Add ContentMenu Items from TopicSL
    begin
      Str := TopicSL[i];
      ContentFileNames.Add( N_ScanToken( Str ) );
      ContentTopicNames.Add( N_ScanToken( Str ) );

      WrkMenuItem := TMenuItem.Create( ContentMenu );
      ContentMenu.Items.Add( WrkMenuItem );
      WrkMenuItem.Caption := Str;
      WrkMenuItem.OnClick := ShowTopic;
    end; // for i := 0 to NumItems-1 do // Add ContentMenu Items from TopicSL

    TopicSL.Free;
  end; // with Result do
end; // function N_CreateHelpForm

end.
