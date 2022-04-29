unit N_EdParF;
// Form with dynamically created Controls for Editing Params in Modal mode
//
// Supported Control Types:
//   CheckBox       - Edit Boolean value
//   Labeled Edit   - Edit String value
//   Fixed ComboBox - Edit index of choosen item by DropDown ComboBox
//   Hist ComboBox  - Edit String by ComboBox using History in MemIni Section
//   RadioGroup     - Edit index of choosen item by Radio Group Control
//   FileNameFrame  - Edit FileName or Choose it from History or by OpenFile Dialog

// Add later:
//   Label          - to Show static text
//   Memo           - to Show or Edit text
//   Buttons        - to execute given procedures of object

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_Types, N_BaseF;

type TN_EPControlType = ( ctCheckBox, ctLEdit, ctFixCB, ctHistCB,
                          ctRadioGroup, ctFileNameFr, ctPathNameFr );
type TN_EPControlFlags =  Set Of ( ctfActiveControl, ctfExitOnEnter );

type TN_OneEPControl = record // Data for One Edit Params Form Control (Results and some info)
  CRContr: TComponent; // Control itself
  CRBool:  boolean;    // Boolean result (if needed)
  CRStr:   string;     // String  result (if needed)
  CRInt:   integer;    // Integer result (if needed)

  CRType:  TN_EPControlType;  // Control Type (set in creator procedure)
  CRFlags: TN_EPControlFlags; // Control Flags
  CRInfoStr: string;          // Control Info string (HistName fo Hist ComboBox)
end; // type TN_OneControl record
type TN_EPControls = Array of TN_OneEPControl;

type TN_EditParamsForm = class( TN_BaseForm )
    bnOk: TButton;
    bnCancel: TButton;

    procedure FormShow      ( Sender: TObject );
    procedure mbHistKeyDown ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure EdKeyDown     ( Sender: TObject; var Key: Word; Shift: TShiftState );

    procedure bnOkClick     ( Sender: TObject );
    procedure bnCancelClick ( Sender: TObject );
    procedure FormClose     ( Sender: TObject; var Action: TCloseAction ); override;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  public
    SelfRect:    TRect; // Self Coords, set in N_CreateEditParams Form and used just before Showing
    LeftMargin:  integer;
    RightMargin: integer;
    CurTop:      integer;
    ContrHeight: integer;
    ContrWidth:  integer;
    EPFUserInt1: integer;
    EPFUserInt2: integer;
    EPFUserPtr1: Pointer;
    EPFUserPtr2: Pointer;

    FreeCRInd:   integer;
    EPControls:  TN_EPControls;
    OkPressed:   boolean;
    OnCloseProcOfObj: procedure ( AForm: TForm ) of object;
    OnCloseQueryProcOfObj: function  ( AForm: TForm ) : Boolean of object;

  procedure WMUSER10         ( var m: TMessage ); message WM_USER+10;
  procedure WMUSER11         ( var m: TMessage ); message WM_USER+11;

  function  AddLabel         ( ACaption: string; AHeight: integer; AAlign: TAlignment = taCenter ): integer;
  procedure AddCheckBox      ( ACaption: string; AValue: boolean );
  procedure AddLEdit         ( ACaption: string; AWidth: integer; AStr: string );
  procedure AddLEdit1        ( ACaption: string; AWidth: integer; AStr: string;
                               ALabelPos : TLabelPosition; ALabelSpacing : Integer = 0 );
  procedure AddFixComboBox   ( ACaption: string; const AList: array of string; AInd: integer );
  procedure AddHistComboBox  ( ACaption: string; ASectionName: string );
  procedure AddRadioGroup    ( ACaption: string; const AList: array of string; AInd: integer );
  procedure AddFileNameFrame ( ACaption, ASectionName, AFilter: string );
  procedure AddPathNameFrame ( ACaption, ASectionName: string );

  procedure ShowSelfNotModal ();
  procedure ShowSelfModal    ();

  function  EPControlIndex   ( ASender: TObject ): integer;
  procedure SetActiveControl ();
  procedure CloseSelf        ();
end; // type TN_EditParamsForm = class( TN_BaseForm )

var
  N_EditParamsForm: TN_EditParamsForm;


    //*********** Global Procedures  *****************************

function  N_GetStrByTEdit    ( AFormCaption, AInpStr: string; AFormWidth: integer ): string;
function  N_GetStrByComboBox ( AFormCaption, ACBCaption, AHistSection: string ): string;
function  N_GetRadioIndex    ( AFormCaption, ARGCaption: string; ANumInd, AWidth: integer;
                               const ANames: array of string ): integer;
function  N_GetFNameFromHist ( AFormCaption, AFilesFilter, AHistSection: string;
                               AFormWidth: integer ): string;

function  N_CreateEditParamsForm ( AContrWidth: integer;
                                   AOwner: TN_BaseForm = nil ): TN_EditParamsForm;

implementation
uses
  K_CLib0, K_FPathNameFr,
  N_Gra0, N_Gra1, N_Lib1, N_Lib2, N_FNameFr, N_NLConvF;

{$R *.dfm}

    //*********** TN_EditParamsForm Hadlers  *****************************

procedure TN_EditParamsForm.FormShow( Sender: TObject );
// Set Self Coords in Modal and NotModal modes
begin
  if SelfRect.Left = N_NotAnInteger then // SelfRect was not defined, use Cursor Pos
  begin

  end else // SelfRect was defined, use it
  begin
//    Top  := SelfRect.Top;
//    Left := SelfRect.Left;
  end;
{ !!!
  Left := Mouse.CursorPos.X - 100;
  Top  := Mouse.CursorPos.Y - 50;

  Width  := ContrWidth + LeftMargin + RightMargin + 8;
  Height := CurTop + 67;

  N_ChangeFormSize( Self, 0, 0 ); // move Self into Desktop
}
  SetActiveControl();

end; // procedure TN_EditParamsForm.FormShow

procedure TN_EditParamsForm.mbHistKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
// Add Top String to Self List
begin
  if Key = VK_RETURN then
  begin
    N_AddTextToTop( TComboBox(Sender) );
    EdKeyDown( Sender, Key, Shift ); // Check if Form should be closed with OK Result
  end;
end; // procedure TN_EditParamsForm.mbHistKeyDown

procedure TN_EditParamsForm.EdKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
// Check if Form should be closed with OK Result
begin
  if Key = VK_RETURN then
  begin
    if ctfExitOnEnter in EPControls[EPControlIndex( Sender )].CRFlags then
      bnOkClick( Sender );
  end;
end; // procedure TN_EditParamsForm.EdKeyDown

procedure TN_EditParamsForm.bnOkClick( Sender: TObject );
// Save current Controls State to EPControls, set OkPressed to True
// and call Additional Proc of Obj if given
var
  i: integer;
begin
  for i := 0 to FreeCRInd-1 do // along all created controls
  with EPControls[i] do
  begin
    if CRContr is TCheckBox    then CRBool := TCheckBox(CRContr).Checked;
    if CRContr is TLabeledEdit then CRStr  := TLabeledEdit(CRContr).Text;
    if CRContr is TRadioGroup  then CRInt  := TRadioGroup(CRContr).ItemIndex;

    if CRContr is TComboBox then
    with TComboBox(CRContr) do
    begin
      CRStr := Text;
      CRInt := ItemIndex;
    end; // with TComboBox(CRContr) do, if CRContr is TComboBox then

    if (CRType = ctHistCB) and (CRInfoStr <> '') then // add TopString to ComboBox History and save it
    begin
      N_AddTextToTop( TComboBox(CRContr) );
      N_ComboBoxToMemIni( CRInfoStr, TComboBox(CRContr) );
    end;

    if CRType = ctFileNameFr then // add TopString to History and save it
    with TN_FileNameFrame(CRContr) do
    begin
      CRStr := mbFileName.Text;
      N_AddTextToTop( mbFileName );
      N_ComboBoxToMemIni( CRInfoStr, mbFileName );
    end;

    if CRType = ctPathNameFr then // add TopString to History and save it
    with TK_FPathNameFrame(CRContr) do
    begin
      CRStr := mbPathName.Text;
      N_AddTextToTop( mbPathName );
      N_ComboBoxToMemIni( CRInfoStr, mbPathName );
    end;

  end; // for i := 0 to FreeCRInd-1 do // along all created controls

  if Assigned(OnCloseProcOfObj) then OnCloseProcOfObj( Self );
  Close(); // in Close ModalResult is set to mrCancel and OkPressed to False!

  ModalResult := mrOK; // should be set AFTER Close, (Close set it to mrCancel)
  OkPressed   := True; // should be set AFTER Close, (Close set it to False)
end; // procedure TN_EditParamsForm.bnOkClick

procedure TN_EditParamsForm.bnCancelClick( Sender: TObject );
// Set OkPressed to False
// and call Additional Procedure of Objects if given
begin
  OkPressed := False;
  if Assigned(OnCloseProcOfObj) then OnCloseProcOfObj( Self );
  Close;
end; // procedure TN_EditParamsForm.bnCancelClick

procedure TN_EditParamsForm.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  Inherited;

//  if fsModal in FormState then Action := caHide  // Self should be released manually!
//                          else Action := caFree; // Self would be realeased by Delphi
  Action := caFree;
  OkPressed := False;
  if Assigned(OnCloseProcOfObj) then OnCloseProcOfObj( Self );
end; // procedure TN_EditParamsForm.FormClose

procedure TN_EditParamsForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if Assigned(OnCloseQueryProcOfObj) then CanClose := OnCloseQueryProcOfObj( Self );
end;

    //*********** TN_EditParamsForm methods  *****************************

procedure TN_EditParamsForm.WMUSER10( var m: TMessage );
// WM_USER+10 message handler
begin
  if m.LParam = 126 then
    windows.SendMessage( m.WParam, WM_User+11, 0, 127 )
  else
  begin
    TLabeledEdit(EPControls[1].CRContr).Text := IntToStr( m.LParam );
    windows.SendMessage( m.WParam, WM_User+11, 0, 124 );
  end;
end; // procedure TN_EditParamsForm.WMUSER10

procedure TN_EditParamsForm.WMUSER11( var m: TMessage );
// WM_USER+11 message handler
begin
  if m.LParam = 124 then
    TLabeledEdit(EPControls[1].CRContr).Text := IntToStr( m.LParam );
end; // procedure TN_EditParamsForm.WMUSER11

function TN_EditParamsForm.AddLabel( ACaption: string; AHeight: integer; AAlign: TAlignment = taCenter ): integer;
// Create Label Control
var
  lbl: TLabel;
begin
  if High(EPControls) < FreeCRInd then
    SetLength( EPControls, FreeCRInd + 5 );

  lbl := TLabel.Create( Self );
  with lbl do
  begin
    Left   := LeftMargin;
    Top    := CurTop;
    Width  := ContrWidth;
    Height := AHeight;
    Inc( CurTop, AHeight );
    Alignment := AAlign;
    AutoSize := FALSE;
    WordWrap := TRUE;

    Parent := Self;
    Caption := ACaption;
    EPControls[FreeCRInd].CRContr := lbl;

    Result := FreeCRInd;
    Inc(FreeCRInd);
  end; // with lbl do

end; // procedure TN_EditParamsForm.AddLabel

procedure TN_EditParamsForm.AddCheckBox( ACaption: string; AValue: boolean );
// Create CheckBox Control
var
  cb: TCheckBox;
begin
  if High(EPControls) < FreeCRInd then
    SetLength( EPControls, FreeCRInd + 5 );

  cb := TCheckBox.Create( Self );
  with cb do
  begin
    Left  := LeftMargin;
    Top   := CurTop;
    Width := ContrWidth;
    Inc( CurTop, ContrHeight );
    Checked := AValue;

    Parent := Self;
    Caption := ACaption;
    EPControls[FreeCRInd].CRContr := cb;
    EPControls[FreeCRInd].CRBool := AValue;

    Inc(FreeCRInd);
  end; // with cb do

end; // procedure TN_EditParamsForm.AddCheckBox

procedure TN_EditParamsForm.AddLEdit( ACaption: string; AWidth: integer; AStr: string );
// Create Labeled Edit Control
var
  ed: TLabeledEdit;
begin
  if High(EPControls) < FreeCRInd then
    SetLength( EPControls, FreeCRInd + 5 );


  ed := TLabeledEdit.Create( Self );
  with ed do
  begin
    OnkeyDown := EdKeyDown;
    Left := LeftMargin;
    if AWidth = 0 then Width := ContrWidth
                  else Width := AWidth;
    Top  := CurTop;
    Inc( CurTop, ContrHeight );
    if ACaption <> '' then
    begin
      Top  := CurTop;
      Inc( CurTop, ContrHeight + 6 )
    end;

    Text := AStr;

    Parent := Self;
    EditLabel.Caption := ACaption;
    EPControls[FreeCRInd].CRContr := ed;
    EPControls[FreeCRInd].CRStr   := AStr;
    EPControls[FreeCRInd].CRType  := ctLEdit;

    Inc(FreeCRInd);
  end; // with ed do

end; // procedure TN_EditParamsForm.AddLEdit

procedure TN_EditParamsForm.AddLEdit1( ACaption: string; AWidth: integer; AStr: string;
                                       ALabelPos : TLabelPosition; ALabelSpacing : Integer = 0 );
// Create Labeled Edit Control
var
  ed: TLabeledEdit;
begin
  if High(EPControls) < FreeCRInd then
    SetLength( EPControls, FreeCRInd + 5 );


  ed := TLabeledEdit.Create( Self );
  with ed do
  begin
    LabelPosition := ALabelPos;
    if ALabelSpacing <> 0 then
      LabelSpacing := ALabelSpacing;
    OnkeyDown := EdKeyDown;
    Left := LeftMargin;
    if AWidth = 0 then Width := ContrWidth
                  else Width := AWidth;
    Top  := CurTop;
    Inc( CurTop, ContrHeight );
    if (ACaption <> '') and
       ( (ALabelPos = lpBelow) or (ALabelPos = lpAbove) ) then
    begin
      Top  := CurTop;
      Inc( CurTop, ContrHeight + 6 ); // !!! need to define height increment by LabelSpacing
    end;

    Text := AStr;

    Parent := Self;
    EditLabel.Caption := ACaption;
    EPControls[FreeCRInd].CRContr := ed;
    EPControls[FreeCRInd].CRStr   := AStr;
    EPControls[FreeCRInd].CRType  := ctLEdit;

    Inc(FreeCRInd);
  end; // with ed do

end; // procedure TN_EditParamsForm.AddLEdit

procedure TN_EditParamsForm.AddFixComboBox( ACaption: string; const AList: array of string;
                                                               AInd: integer );
// Create ComboBox Control with Fixed DropDownList and AInd initial Index
// Return createted ComboBox.Items
var
  cb: TComboBox;
  lb: TLabel;
begin
  if High(EPControls) < FreeCRInd then
    SetLength( EPControls, FreeCRInd + 5 );

  if ACaption <> '' then
  begin
    lb := TLabel.Create( Self );
    with lb do
    begin
      Left := LeftMargin;
      Top  := CurTop;
      Inc( CurTop, ContrHeight-2 );
      Parent := Self;
      Caption := ACaption;
    end; // with lb do
  end; // if ACaption <> ''

  cb := TComboBox.Create( Self );
  with cb do
  begin
    Left := LeftMargin;
    Top  := CurTop;
    Width := ContrWidth;
    Inc( CurTop, ContrHeight + 6 );
    Parent := Self;
//    N_SetMBItems( cb, AList, AInd, ContrWidth );
    N_SetMBItems( cb, AList, AInd, -1 );

    EPControls[FreeCRInd].CRContr := cb;
    EPControls[FreeCRInd].CRInt   := ItemIndex;
    EPControls[FreeCRInd].CRType  := ctFixCB;

    Inc(FreeCRInd);
  end; // with cb do
end; // procedure TN_EditParamsForm.AddFixComboBox

procedure TN_EditParamsForm.AddHistComboBox( ACaption: string; ASectionName: string );
// Create ComboBox Control with given History, stored in ini file ASectionName
// (ASectionName may be empty string)
var
  cb: TComboBox;
  lb: TLabel;
begin
  if High(EPControls) < FreeCRInd then
    SetLength( EPControls, FreeCRInd + 5 );

  if ACaption <> '' then
  begin
    lb := TLabel.Create( Self );
    with lb do
    begin
      Left := LeftMargin;
      Top  := CurTop;
      Inc( CurTop, ContrHeight-2 );
      Parent := Self;
      Caption := ACaption;
    end; // with lb do
  end; // if ACaption <> ''

  cb := TComboBox.Create( Self );
  with cb do
  begin
    OnkeyDown := mbHistKeyDown;
    Left := LeftMargin;
    Top  := CurTop;
    Width := ContrWidth;
    Inc( CurTop, ContrHeight + 6 );
    Parent := Self;
    N_MemIniToComboBox( ASectionName, cb );
    if cb.Items.Count >= 1 then cb.ItemIndex := 0; // show top string

    EPControls[FreeCRInd].CRContr := cb;
    EPControls[FreeCRInd].CRInt   := ItemIndex;
    EPControls[FreeCRInd].CRType  := ctHistCB;
    EPControls[FreeCRInd].CRInfoStr := ASectionName;

    Inc(FreeCRInd);
  end; // with cb do

end; // procedure TN_EditParamsForm.AddHistComboBox

procedure TN_EditParamsForm.AddRadioGroup( ACaption: string; const AList: array of string;
                                                                AInd: integer );
// Create and return RadioGroup Control with given Item Names and AInd initial Index
var
  i: integer;
  rg: TRadioGroup;
begin
  if High(EPControls) < FreeCRInd then
    SetLength( EPControls, FreeCRInd + 5 );

  rg := TRadioGroup.Create( Self );
  with rg do
  begin
    rg.Left := LeftMargin;
    rg.Top  := CurTop;
    rg.Height := Length(AList)*20 + 8;
    Inc( CurTop, rg.Height + 4 );
    Parent := Self;
    Caption := ACaption;

    for i := 0 to High(AList) do
      Items.Add( AList[i] );

    ItemIndex := AInd;
    EPControls[FreeCRInd].CRContr := rg;
    EPControls[FreeCRInd].CRInt   := ItemIndex;
    EPControls[FreeCRInd].CRType  := ctRadioGroup;

    Inc(FreeCRInd);
  end; // with rg do
end; // procedure TN_EditParamsForm.AddRadioGroup

procedure TN_EditParamsForm.AddFileNameFrame( ACaption, ASectionName, AFilter: string );
// Create FileName Frame with History List in given IniFile ASectionName
// Filter examples:
// 'Text files (*.txt)|*.TXT' (one filter)
// 'Text files (*.txt)|*.TXT|Pascal files (*.pas)|*.PAS' (two filters)
var
  i: integer;
  fr: TN_FileNameFrame;
  lb: TLabel;
begin
  if High(EPControls) < FreeCRInd then
    SetLength( EPControls, FreeCRInd + 5 );

  if ACaption <> '' then // Label should be shown
  begin
    lb := TLabel.Create( Self );
    with lb do
    begin
      Left := LeftMargin;
      Top  := CurTop;
      Inc( CurTop, ContrHeight-2 );
      Parent := Self;
      Caption := ACaption;
    end; // with lb do
  end; // if ACaption <> '' then // Label should be shown

  fr := TN_FileNameFrame.Create( Self );
  with fr do
  begin
    Left := LeftMargin;
    Top  := CurTop;
    Width := ContrWidth - LeftMargin + 8;
    mbFileName.Left := 0;
    mbFileName.Width := Width - 28; // 28 is bnBrowse width + gap
    Inc( CurTop, Height );
    Parent := Self;
    OpenDialog.Filter := AFilter;
    N_MemIniToComboBox( ASectionName, mbFileName );

    for i := 0 to mbFileName.Items.Count-1 do
    begin
      mbFileName.Items[i] := K_ExpandFileName( mbFileName.Items[i] );
    end;

    if mbFileName.Items.Count >= 1 then // History Exists
    begin
      mbFileName.ItemIndex := 0; // show top string
      OpenDialog.InitialDir := ExtractFilePath( mbFileName.Text );
      OpenDialog.FileName := ExtractFileName( mbFileName.Text );
    end; // if mbFileName.Items.Count >= 1 then // History Exists

    EPControls[FreeCRInd].CRContr   := fr;
    EPControls[FreeCRInd].CRType    := ctFileNameFr;
    EPControls[FreeCRInd].CRInfoStr := ASectionName;

    Inc(FreeCRInd);
  end; // with fr do

end; // procedure TN_EditParamsForm.AddFileNameFrame

procedure TN_EditParamsForm.AddPathNameFrame( ACaption, ASectionName: string );
// Create FileName Frame with History List in given IniFile ASectionName
// Filter examples:
// 'Text files (*.txt)|*.TXT' (one filter)
// 'Text files (*.txt)|*.TXT|Pascal files (*.pas)|*.PAS' (two filters)
var
  i: integer;
  fr: TK_FPathNameFrame;
  lb: TLabel;
begin
  if High(EPControls) < FreeCRInd then
    SetLength( EPControls, FreeCRInd + 5 );

  if ACaption <> '' then // Label should be shown
  begin
    lb := TLabel.Create( Self );
    with lb do
    begin
      Left := LeftMargin;
      Top  := CurTop;
      Inc( CurTop, ContrHeight-2 );
      Parent := Self;
      Caption := ACaption;
    end; // with lb do
  end; // if ACaption <> '' then // Label should be shown

  fr := TK_FPathNameFrame.Create( Self );
  with fr do
  begin
    Left := LeftMargin;
    Top  := CurTop;
    Width := ContrWidth - LeftMargin + 8;
    mbPathName.Left := 0;
    mbPathName.Width := Width - 28; // 28 is bnBrowse width + gap
    Inc( CurTop, Height );
    Parent := Self;
    N_MemIniToComboBox( ASectionName, mbPathName );

    for i := 0 to mbPathName.Items.Count-1 do
    begin
      mbPathName.Items[i] := K_ExpandFileName( mbPathName.Items[i] );
    end;

    if mbPathName.Items.Count >= 1 then // History Exists
    begin
      mbPathName.ItemIndex := 0; // show top string
    end; // if mbFileName.Items.Count >= 1 then // History Exists

    EPControls[FreeCRInd].CRContr   := fr;
    EPControls[FreeCRInd].CRType    := ctPathNameFr;
    EPControls[FreeCRInd].CRInfoStr := ASectionName;

    Inc(FreeCRInd);
  end; // with fr do

end; // procedure TN_EditParamsForm.AddPathNameFrame

procedure TN_EditParamsForm.ShowSelfNotModal();
// Update Self Size and Position and Show Self in NOT Modal mode
begin
  Left := Mouse.CursorPos.X - 100;
  Top  := Mouse.CursorPos.Y - 50;

  Width  := ContrWidth + LeftMargin + RightMargin + 8;
  Height := CurTop + 67;

  N_ChangeFormSize( Self, 0, 0 ); // move Self into Desktop

  SetActiveControl();
  Show();
end; // procedure TN_EditParamsForm.ShowSelfNotModal

procedure TN_EditParamsForm.ShowSelfModal();
// Update Self Size and Position and Show Self in Modal mode
begin
  Left := Mouse.CursorPos.X - 100;
  Top  := Mouse.CursorPos.Y - 50;

  Width  := ContrWidth + LeftMargin + RightMargin + 8;
  Height := CurTop + 67;

  N_ChangeFormSize( Self, 0, 0 ); // move Self into Desktop

  SetActiveControl();
  ShowModal();
end; // procedure TN_EditParamsForm.ShowSelfModal

//**************************************** TN_EditParamsForm.EPControlIndex ***
// Search for given ASender in EPControls Array and return found Index or -1
//
function TN_EditParamsForm.EPControlIndex( ASender: TObject ): integer;
var
  i: integer;
begin
  Result := -1;

  for i := 0 to FreeCRInd-1 do // along all created controls
  begin
    if EPControls[i].CRContr = ASender then
    begin
      Result := i;
      Exit;
    end;
  end;
end; // end of function TN_EditParamsForm.EPControlIndex

//************************************** TN_EditParamsForm.SetActiveControl ***
// Set ActiveControl by CRFlags
//
procedure TN_EditParamsForm.SetActiveControl();
var
  i: integer;
begin
  for i := 0 to FreeCRInd-1 do // along all created controls
    with EPControls[i] do
    begin
      if ctfActiveControl in CRFlags then
      begin
        if CRContr is TWinControl then
          ActiveControl := TWinControl(CRContr);
      end;
    end;
end; // end of procedure TN_EditParamsForm.SetActiveControl

//********************************************* TN_EditParamsForm.CloseSelf ***
// Close Self ProcOfObj
// (used for closing Self in not modal mode as CloseForm handler)
//
procedure TN_EditParamsForm.CloseSelf();
begin
  Close();
end; // end of procedure TN_EditParamsForm.CloseSelf


    //*********** Global Procedures  *****************************

//****************************************************** N_GetStrByTEdit ***
// Create TN_EditParamsForm with TEdit control.
// Return entered string or N_NotAString if cancelled
//
// AFormCaption - Form Caption
// AInpStr      - initial value of String to Edit
// AFormWidth   - Form Width in Pixels
//
function N_GetStrByTEdit( AFormCaption, AInpStr: string; AFormWidth: integer ): string;
var
  ParamsForm: TN_EditParamsForm;
begin
  Result := N_NotAString;
  ParamsForm := N_CreateEditParamsForm( AFormWidth );

  with ParamsForm do
  begin
    Caption := AFormCaption;
    AddLEdit( '', 0, AInpStr );
    EPControls[0].CRFlags := [ctfActiveControl, ctfExitOnEnter];

    ShowSelfModal();

    if ModalResult = mrOK then
      Result := EPControls[0].CRStr;
  end; // with ParamsForm do
end; // function N_GetStrByTEdit

//****************************************************** N_GetStrByComboBox ***
// Create TN_EditParamsForm with ComboBox (with History) return choosen string
// or N_NotAString if cancelled
//
// AFormCaption - Form Caption
// ACBCaption   - ComboBox Caption
// AHistSection - IniFile Section Name for History
//
function N_GetStrByComboBox( AFormCaption, ACBCaption, AHistSection: string ): string;
var
  ParamsForm: TN_EditParamsForm;
begin
  Result := N_NotAString;
  ParamsForm := N_CreateEditParamsForm( 400 );

  with ParamsForm do
  begin
    Caption := AFormCaption;
    AddHistComboBox( ACBCaption, AHistSection );
    EPControls[0].CRFlags := [ctfActiveControl, ctfExitOnEnter];

    ShowSelfModal();

    if ModalResult = mrOK then
      Result := EPControls[0].CRStr;
  end; // with ParamsForm do
end; // function N_GetStrByComboBox

//********************************************************* N_GetRadioIndex ***
// Create TN_EditParamsForm with RadioGroup and return choosen ItemIndex
// or -1 if cancelled
//
// AFormCaption - Form Caption
// ARGCaption   - RadioGroup Caption
// ANumInd      - Radio Group Item Index to Check
// AWidth       - EditParams Form Width
// ANames       - RadioGroup's Items Names
//
function N_GetRadioIndex( AFormCaption, ARGCaption: string; ANumInd, AWidth: integer;
                                      const ANames: array of string ): integer;
var
  ParamsForm: TN_EditParamsForm;
begin
  Result := -1;
  ParamsForm := N_CreateEditParamsForm( AWidth );

  with ParamsForm do
  begin
    Caption := AFormCaption;
    AddRadioGroup( ARGCaption, ANames, ANumInd );

    ShowSelfModal();

    if ModalResult = mrOK then
      Result := EPControls[0].CRInt;
  end; // with ParamsForm do
end; // function N_GetRadioIndex

//****************************************************** N_GetFNameFromHist ***
// Get File Name using TN_FileNameFrame and Files History
// Create TN_EditParamsForm with TN_FileNameFrame (with History) and
// return choosen File Name or N_NotAString if cancelled
//
// AFormCaption - Form Caption
// AFilesFilter - Files Filter
// AHistSection - IniFile Section Name with File Names History
// AFormWidth   - EditParamsForm Width
//
function N_GetFNameFromHist( AFormCaption, AFilesFilter, AHistSection: string;
                             AFormWidth: integer ): string;
var
  ParamsForm: TN_EditParamsForm;
begin
  Result := N_NotAString;
  ParamsForm := N_CreateEditParamsForm( AFormWidth );

  with ParamsForm do
  begin
    Caption := AFormCaption;
    AddFileNameFrame( '', AHistSection, AFilesFilter );

    ShowSelfModal();

    if ModalResult = mrOK then
      Result := EPControls[0].CRStr;
  end; // with ParamsForm do
end; // function N_GetFNameFromHist

//************************************************** N_CreateEditParamsForm ***
// Create, initialize and Return new instance of TN_EditParamsForm
//
function N_CreateEditParamsForm( AContrWidth: integer; AOwner: TN_BaseForm ): TN_EditParamsForm;
begin
  Result := TN_EditParamsForm.Create( Application );
  N_EditParamsForm := Result;
  with Result do
  begin
//!!!  BaseFormInit( AOwner );
    BaseFormInit( AOwner, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    SelfRect.Left := N_NotAnInteger;
    Caption     := 'Enter Params:';
    LeftMargin  := 5;
    RightMargin := 5;
    CurTop      := 5;
    ContrHeight := 18;
    ContrWidth  := AContrWidth;

    //*** Avoid overlaping with some possibly StayOnTop Forms

    if N_NLConvForm <> nil then
    begin
      if N_NLConvForm.FormStyle = fsStayOnTop then
        SelfRect := N_RectSetPos( 3, N_AppWAR,
                      N_GetScreenRectOfControl( N_NLConvForm ), Width, Height );
    end; // if N_NLConvForm <> nil then

    Top := 10;
    Application.ProcessMessages();

  end; // with Result do
end; // procedure N_CreateEditParamsForm();

// asd
// 234

end.
