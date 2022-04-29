unit K_FSDeb;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ActnList, ComCtrls, ToolWin, Menus, ImgList,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  K_FBase, K_Sparse1, K_UDT1, K_Script1, K_IWatch,
  N_RVCTF, ExtCtrls;

type
  TK_FormMVDeb = class(TK_FormBase)
    PageControl1: TPageControl;

    ActionList1: TActionList;
      ActionRun: TAction;
      ActionOpen: TAction;
      ActionImport: TAction;
      ActionCompile: TAction;
      ActionExport: TAction;
      ActionSave: TAction;
      ActionNew: TAction;
      ActionClose: TAction;
      ActionBreak: TAction;
      ActionStepOver: TAction;
      ActionStepInto: TAction;
      ActionStepOut: TAction;
      ActionParams: TAction;

    ToolBar1: TToolBar;
      ToolButton1: TToolButton;
      ToolButton2: TToolButton;
      ToolButton3: TToolButton;
      ToolButton4: TToolButton;
      ToolButton5: TToolButton;
      ToolButton6: TToolButton;
      ToolButton7: TToolButton;
      ToolButton8: TToolButton;
      ToolButton9: TToolButton;
      ToolButton10: TToolButton;
      ToolButton11: TToolButton;
      ToolButton12: TToolButton;
      ToolButton13: TToolButton;

    MainMenu1: TMainMenu;
      File1: TMenuItem;
      Unit1: TMenuItem;
      Export1: TMenuItem;
      Run1: TMenuItem;
      StepOver1: TMenuItem;
      TraceInto1: TMenuItem;
      RunUntilReturn1: TMenuItem;
      TraceMode1: TMenuItem;
      Compile1: TMenuItem;
      Close1: TMenuItem;
      Open1: TMenuItem;
      New1: TMenuItem;
      ProgramReset1: TMenuItem;
      Save1: TMenuItem;
      Import1: TMenuItem;

    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    StatusBar1: TStatusBar;
    ProMemo: TMemo;
    InfoMemo: TMemo;

    Splitter1: TSplitter;

    procedure ActionRunExecute(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure ActionOpenExecute(Sender: TObject);
    procedure ActionImportExecute(Sender: TObject);
    procedure ActionCompileExecute(Sender: TObject);
    procedure ActionExportExecute(Sender: TObject);
    procedure ActionSaveExecute(Sender: TObject);
    procedure ActionNewExecute(Sender: TObject);
    procedure ActionCloseExecute(Sender: TObject);
    procedure EditKeyUpEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RunKeyUpEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionBreakExecute(Sender: TObject);
    procedure ActionStepOverExecute(Sender: TObject);
    procedure ActionStepIntoExecute(Sender: TObject);
    procedure ActionStepOutExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ActionParamsExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure OnSaveChangedUnitText( AUDUnit : TN_UDBase );
  public
    { Public declarations }
//*** Edit Windows State
    UnitsRoot  : TN_UDBase;
    MemoList   : TStringList;
    UnitList   : TStringList;
    ActiveUnit : TK_UDUnit;
    ActiveListIndex : Integer;
    CompiledUnitIndex : Integer;
//*** Import/Export
    LastImportFile : string;
//*** Run Context
    RunState : Boolean;
//*** Trace Context
    WatchLinesNum : Integer;
    WRect : TRect;
    DumpFileName  : string;
    ShowDumpInStatusBar : Boolean;
    DumpInitSection : Boolean;
//*** Drawing Context
    ShowDWindow : Boolean;
    DWinWidth : Integer;
    DWinHeight: Integer;
    R3Form: TN_RastVCTForm;
//*** ChangeUnitTextContext
    OnSaveChangedUnitTextProc : procedure ( AUDUnit : TN_UDBase ) of Object;

    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;

    function  AddUnitMemo( TabSheetCaption : string ) : Integer;
    function  GetUnitMemo( UDUnit : TK_UDUnit; AddNewMemoIfSameAliase : Boolean;
                           UnitAliase : string  ) : TMemo;
    procedure ShowUnitMemo( UDUnit : TK_UDUnit;
                      TextStart, TextSize : Integer;
                      CompileError: string = '';
                      SearchMemoByAliase : Boolean = false;
                      UnitAliase : string = '' );
    procedure SaveAllUnits;
    procedure ShowErrorInfo( UDModuleRoot : TK_UDUnit;
            UnitName, ErrMessage : string;
            ErrPos, ErrLength, ErrRow, ErrRowPos : Integer  );
    procedure ShowRuntimeErrInfo( const RTE : TK_RTEInfo );
    function IfDataWasChanged: Boolean; override;
  private
    SFilter : TK_UDFilter;
  end;

var
  K_FormMVDeb0: TK_FormMVDeb;
  K_DebugGC : TK_CSPLCont;

function  K_GetFormMVDeb( AUnitsRoot : TN_UDBase = nil ) : TK_FormMVDeb;
function  K_GetFormMVRun : TK_FormMVDeb;
procedure K_CreateDebugGC;

implementation

uses K_Arch, K_UDC, K_CLib0, K_UDT2, K_FSelectUDB, K_FSDebTM, K_Types,
     N_CLassRef, N_Types, N_Lib1, N_Lib2, N_ButtonsF;

{$R *.dfm}

//********************************************* K_CreateDebugGC ***
//  Create Debug GLobal Context
//
procedure K_CreateDebugGC;
begin
  if K_DebugGC <> nil then Exit;
  K_DebugGC := K_PrepSPLRunGCont;
end; //********************************** end of K_CreateDebugGC ***

//********************************************* K_GetFormMVDeb ***
//  get form - create if needed
//
function K_GetFormMVDeb( AUnitsRoot : TN_UDBase = nil ) : TK_FormMVDeb;
var
  SB : TStatusBar;
begin
  if K_FormMVDeb0 = nil then begin
    K_DebugGC := K_PrepSPLRunGCont( K_DebugGC );
//!!    K_CreateDebugGC;
    if Application.MainForm = nil then
      Application.CreateForm(TK_FormMVDeb, K_FormMVDeb0) // Errors while application start
    else
      K_FormMVDeb0 := TK_FormMVDeb.Create(Application);
    with K_FormMVDeb0 do begin
      BaseFormInit( nil, 'K_FormMVDeb' );
      CompiledUnitIndex := -1;
      if AUnitsRoot = nil then
        UnitsRoot := K_SPLRootObj
      else
        UnitsRoot := AUnitsRoot;
      MemoList := TStringList.Create;
      UnitList := TStringList.Create;
      ActiveUnit := nil;
      ActiveListIndex := -1;
      WatchLinesNum := 200;
      WRect := Rect(0,0,500,100);
      DumpFileName  := K_InfoWatch.DumpFileName;
      ShowDumpInStatusBar := true;
      ShowDumpInStatusBar := false;
      DumpInitSection := false;
      ShowDWindow := false;
      DWinWidth := 400;
      DWinHeight:= 400;
      SFilter := TK_UDFilter.Create;
      SFilter.AddItem( TK_UDFilterClassSect.Create( K_UDUnitCI ) );
      if ShowDumpInStatusBar then
        SB := StatusBar1
      else
        SB := nil;
      if K_DebugGC.SPLGCDumpWatch = nil then begin
        K_DebugGC.SPLGCDumpWatch := TK_InfoWatch.Create( WatchLinesNum, DumpFileName, SB );
        K_DebugGC.SPLGCDumpWatch.SetWatchRect( WRect );
      end else
        K_DebugGC.SPLGCDumpWatch.StatusBar := SB;
    end;
  end;
  Result := K_FormMVDeb0;
end; //********************************** end of K_GetFormMVDeb ***


//********************************************* K_GetFormMVRun ***
//  get form - create if needed
//
function K_GetFormMVRun : TK_FormMVDeb;
var
  SB : TStatusBar;
begin
  K_DebugGC := K_PrepSPLRunGCont( K_DebugGC );
  Result := TK_FormMVDeb.Create(Application);
  with Result do begin
    RunState := true;
//*** Hide not used controls
    ActionOpen.Visible := false;
    ActionImport.Visible := false;
    ActionCompile.Visible := false;
    ActionExport.Visible := false;
    ActionSave.Visible := false;
    ActionNew.Visible := false;
    ActionClose.Visible := false;
    ActionBreak.Visible := true;  // Program Reset
    ActionStepOut.Visible := true; // Run Until Return
    ActionBreak.Enabled := true;  // Program Reset
    ActionStepOut.Enabled := true; // Run Until Return
//*** Hide not used controls

    BaseFormInit( nil, 'K_FormMVDeb' );
    CompiledUnitIndex := -1;
    UnitsRoot := K_SPLRootObj;
    MemoList := TStringList.Create;
    UnitList := TStringList.Create;
    ActiveUnit := nil;
    ActiveListIndex := -1;
    WatchLinesNum := 200;
    WRect := Rect(0,0,500,100);
    DumpFileName  := K_InfoWatch.DumpFileName;
    ShowDumpInStatusBar := true;
    ShowDumpInStatusBar := false;
    DumpInitSection := false;
    ShowDWindow := false;
    DWinWidth := 400;
    DWinHeight:= 400;
//      SFilter := TK_UDFilter.Create;
//      SFilter.AddItem( TK_UDFilterClassSect.Create( K_UDUnitCI ) );
    if ShowDumpInStatusBar then
      SB := StatusBar1
    else
      SB := nil;
    if K_DebugGC.SPLGCDumpWatch = nil then begin
      K_DebugGC.SPLGCDumpWatch := TK_InfoWatch.Create( WatchLinesNum, DumpFileName, SB );
      K_DebugGC.SPLGCDumpWatch.SetWatchRect( WRect );
    end else
      K_DebugGC.SPLGCDumpWatch.StatusBar := SB;
  end;
end; //********************************** end of K_GetFormMVRun


//********************************************* TK_FormMVDeb.AddUnitMemo ***
//  Add Unit Memo
//
function TK_FormMVDeb.AddUnitMemo( TabSheetCaption : string ) : Integer;
var
  TabSheet : TTabSheet;
  Memo : TMemo;
begin
  TabSheet := TTabSheet.Create(PageControl1);
  TabSheet.PageControl := PageControl1;
  TabSheet.Caption := TabSheetCaption;

  Memo := TMemo.Create(PageControl1.Parent);
  Memo.Parent := TabSheet;
  Memo.Align := alClient;
  Memo.ScrollBars := ssBoth;
  Memo.OnKeyUp := RunKeyUpEvent;
  Memo.Font := ProMemo.Font;
  MemoList.AddObject( 'new', Memo );

  UnitList.AddObject( '', nil );
  Result := UnitList.Count - 1;

//*** Enabled Menu Items
  ActionRun.Enabled := true; // Run
  ActionCompile.Enabled := true; // Compile
  ActionExport.Enabled := true; // Export
  ActionSave.Enabled := true; // Save
  ActionClose.Enabled := true; // Close
  ActionStepOver.Enabled := true; // Run Over
  ActionStepInto.Enabled := true; // Run Into
end; //********************************** end of AddUnitMemo ***

//********************************************* TK_FormMVDeb.GetUnitMemo ***
//  get Unit Memo - create if needed
//
function TK_FormMVDeb.GetUnitMemo( UDUnit : TK_UDUnit; AddNewMemoIfSameAliase : Boolean;
                                   UnitAliase : string ) : TMemo;
var
  NameInd, i : Integer;

label EndSearch;

  procedure AddNew( Capt : string );
  begin
    ActiveListIndex := AddUnitMemo( Capt );
//    ActiveListIndex := AddUnitMemo( UnitAliase );

    Result := TMemo( MemoList.Objects[ActiveListIndex] );
    Result.Lines.Text := UDUnit.SL.Text;
    Result.Modified := false;
    Result.ReadOnly := RunState;
    Result.Parent.Hint := UnitAliase;
    Result.Parent.ShowHint := true;
    MemoList.Strings[ActiveListIndex] := UnitAliase;
    UnitList.Objects[ActiveListIndex] := UDUnit;
  end;

begin
  ActiveListIndex := UnitList.IndexOfObject(UDUnit);
  if ActiveListIndex >= 0 then begin
    Result := TMemo( MemoList.Objects[ActiveListIndex] );
    goto EndSearch;
  end;
  if UnitAliase = '' then
    UnitAliase := UDUnit.ObjAliase;
  ActiveListIndex := MemoList.IndexOf( UnitAliase );
  if ActiveListIndex = -1 then //*** add new
    AddNew( UDUnit.ObjName )
  else if AddNewMemoIfSameAliase then begin
    NameInd := 1;             //*** Add New Memo with Uniq ID
    for i := ActiveListIndex + 1 to MemoList.Count - 1 do
      if MemoList.Strings[i] = UnitAliase then Inc(NameInd);
    AddNew( UDUnit.ObjName + '('+ IntToStr(NameInd) + ')' )
  end else begin
    Result := TMemo( MemoList.Objects[ActiveListIndex] );
    UDUnit := TK_UDUnit(UnitList.Objects[ActiveListIndex]);
  end;
EndSearch:
  PageControl1.ActivePage := TTabSheet( Result.Parent );
  ActiveUnit := UDUnit;
//  Caption := ActiveUnit.ObjAliase;
  Caption := MemoList[ActiveListIndex];
  if RunState then
    Caption := Caption + ' - Run';
  visible := true;
end; //********************************** end of GetUnitMemo ***

//********************************************* TK_FormMVDeb.ShowUnitMemo ***
//  Show Unit Text Fragment
//
procedure TK_FormMVDeb.ShowUnitMemo( UDUnit : TK_UDUnit;
                      TextStart, TextSize : Integer;
                      CompileError: string = '';
                      SearchMemoByAliase : Boolean = false;
                      UnitAliase : string = '' );
var
  UnitMemo : TMemo;
begin
  if CompiledUnitIndex = -1 then
    UnitMemo := GetUnitMemo( UDUnit, not SearchMemoByAliase, UnitAliase )
  else
    UnitMemo := TMemo(MemoList.Objects[ActiveListIndex]);

  UnitList.Strings[ActiveListIndex] := CompileError;
  PageControl1Change( nil );

  UnitMemo.SelStart := TextStart - 1;
  UnitMemo.SelLength := TextSize;
  UnitMemo.SetFocus;

//  if RunState and not Visible then begin //*** show in modal mode
  if RunState then begin //*** show in modal mode
    K_DebugGC.SPLGCDumpWatch.AddInfoLine( '>>'+Copy( UnitMemo.Text, TextStart, TextSize), 0);
    Visible := false;
{
    ActionBreak.Enabled := true;  // Program Reset
    ActionStepOut.Enabled := true; // Run Until Return
}
    ShowModal;
  end else
    Show;
end; //********************************** end of ShowUnitMemo ***

//********************************************* TK_FormMVDeb.SaveAllUnits ***
//  Save All Units Texts
//
procedure TK_FormMVDeb.SaveAllUnits;
var
  i : Integer;
  UDUnit : TK_UDUnit;
begin
  for i := 0 to MemoList.Count - 1 do begin
    with TMemo( MemoList.Objects[i] ) do begin
      UDUnit := TK_UDUnit(UnitList.Objects[i]);
      if Modified then begin
        if UDUnit <> nil then begin
          UDUnit.SL.Assign( Lines );
          Modified := false;
          UDUnit.ClearChilds;
          if Assigned(OnSaveChangedUnitTextProc) then OnSaveChangedUnitTextProc( UDUnit );
        end;
      end;
    end;
  end;
end; //********************************** end of SaveAllUnits ***

//********************************************* TK_FormMVDeb.PageControl1Change ***
//  Change Active TabSheet
//
procedure TK_FormMVDeb.PageControl1Change(Sender: TObject);
{
  procedure PrepareDeletion;
  begin
    TMemo(MemoList.Objects[ActiveListIndex]).Modified := false;
    ActionCloseExecute(Sender);
  end;
}
begin
  ActiveListIndex := MemoList.IndexOfObject( PageControl1.ActivePage.Controls[0] );
  ActiveUnit := TK_UDUnit( UnitList.Objects[ActiveListIndex] );
  if ActiveUnit <> nil then begin
//    Caption := ActiveUnit.ObjAliase;
    Caption := MemoList[ActiveListIndex];
    if RunState then
      Caption := Caption + ' - Run';
  end;
{
  try
    if ActiveUnit <> nil then begin
      Caption := ActiveUnit.ObjAliase;
    end;
  except
    PrepareDeletion;
    Exit;
  end;
}
  InfoMemo.Lines.Clear;
  InfoMemo.Lines.Add( UnitList.Strings[ActiveListIndex] );
end;

//********************************************* TK_FormMVDeb.FormCloseQuery ***
//  Close Form Query handler
//
procedure TK_FormMVDeb.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  res : Word;
  AInd, i : Integer;
  UDUnit : TK_UDUnit;

label FreeControls;

begin
  if RunState then goto FreeControls;

  res := mrNone;
//*** test if saving is needed
  AInd := ActiveListIndex;
  UDUnit := ActiveUnit;
  for i := 0 to MemoList.Count - 1 do begin
    with TMemo( MemoList.Objects[i] ) do begin
      if not Modified then Continue;
      if DataSaveModalState = mrNone then
        res := MessageDlg( 'Text of ' + MemoList.Strings[i] + ' was modified - save?',
             mtConfirmation, [mbYesToAll, mbYes, mbNo, mbCancel], 0)
      else
        res := DataSaveModalState;
      if res = mrCancel then Break;
      if res = mrNo then Continue;
      ActiveListIndex := i;
      ActiveUnit := TK_UDUnit(UnitList.Objects[i]);
      if ActiveUnit <> nil then
        ActionSaveExecute(Sender)    //*** Unit
      else
        ActionExportExecute(Sender); //*** File
    end;
  end;

  ActiveListIndex := AInd;
  ActiveUnit := UDUnit;
  CanClose := (res <> mrCancel) ;

  if not CanClose then Exit;

  for i := 0 to UnitList.Count - 1 do begin
    ActiveUnit := TK_UDUnit(UnitList.Objects[i]);
    if (ActiveUnit <> nil)      and
       (ActiveUnit.Owner = nil)  then
      ActiveUnit.UDDelete();
  end;

FreeControls:
  MemoList.Free;
  UnitList.Free;
  SFilter.Free;

  K_FreeSPLRunGCont( K_DebugGC );
  if R3Form <> nil then R3Form.Close;
  if Self = K_FormMVDeb0 then
    K_FormMVDeb0 := nil;
end;

//********************************************* TK_FormMVDeb.ActionOpenExecute ***
//  Open Unit
//
procedure TK_FormMVDeb.ActionOpenExecute(Sender: TObject);
var
  UDUnit : TK_UDUnit;
begin
  UDUnit := TK_UDUnit( K_SelectUDB( UnitsRoot, '', SFilter.UDFTest,
                                                nil, 'Select Unit'  ) );
  if UDUnit <> nil then GetUnitMemo( UDUnit, true, '' );

end;

//********************************************* TK_FormMVDeb.ActionNewExecute ***
//  New Text Edit
//
procedure TK_FormMVDeb.ActionNewExecute(Sender: TObject);
var
  Memo : TMemo;
begin
  Caption := 'New';
  ActiveListIndex := AddUnitMemo( Caption );
  Memo := TMemo( MemoList.Objects[ActiveListIndex] );
  ActiveUnit := nil;
  PageControl1.ActivePage := TTabSheet( Memo.Parent );
end;

//********************************************* TK_FormMVDeb.ActionImportExecute ***
//  Import Text from File
//
procedure TK_FormMVDeb.ActionImportExecute(Sender: TObject);
var
  Memo : TMemo;
begin
  OpenDialog1.FileName := LastImportFile;
  if OpenDialog1.Execute then begin
    LastImportFile := OpenDialog1.FileName;
    Caption := LastImportFile;
    ActiveListIndex := MemoList.IndexOf( LastImportFile );
    if ActiveListIndex = -1 then begin
      ActiveListIndex := AddUnitMemo( ExtractFileName(LastImportFile) );
      MemoList.Strings[ActiveListIndex] := LastImportFile;
    end;
    Memo := TMemo( MemoList.Objects[ActiveListIndex] );
    Memo.Lines.LoadFromFile( LastImportFile );
    ActiveUnit := nil;
    PageControl1.ActivePage := TTabSheet( Memo.Parent );
    Memo.SetFocus;
  end;
end;

//********************************************* TK_FormMVDeb.ActionExportExecute ***
//  Export Text to File
//
procedure TK_FormMVDeb.ActionExportExecute(Sender: TObject);
begin
  SaveDialog1.FileName := LastImportFile;
  if SaveDialog1.Execute then begin
    LastImportFile := SaveDialog1.FileName;
    TMemo( MemoList.Objects[ActiveListIndex] ).Lines.SaveToFile( LastImportFile );
  end;
end;

//********************************************* TK_FormMVDeb.ActionSaveExecute ***
//  Save Text to Unit
//
procedure TK_FormMVDeb.ActionSaveExecute(Sender: TObject);
var
  Mes : string;
begin
  StatusBar1.SimpleText := '';
  Mes := 'Nothing to do.';
  with TMemo( MemoList.Objects[ActiveListIndex] ) do begin
    if Modified or
       ((ActiveUnit <> nil) and
        (ActiveUnit.SL.Text <> Lines.Text)) then begin
      if ActiveUnit <> nil then begin
        ActiveUnit.SL.Assign( Lines );
        Mes := 'Modified Text is saved to Unit.';
        Modified := false;
        ActiveUnit.ClearChilds;
        if Assigned(OnSaveChangedUnitTextProc) then OnSaveChangedUnitTextProc( ActiveUnit );
      end else begin
        Mes := 'Text is not Unit. Try to compile it before saving.';
        K_ShowMessage( Mes );
      end;
    end;
  end;
  StatusBar1.SimpleText := Mes;
end;

//********************************************* TK_FormMVDeb.ActionCompileExecute ***
//  Compile Unit
//
procedure TK_FormMVDeb.ActionCompileExecute(Sender: TObject);
var
  CompileNew : Boolean;
  WUnit : TK_UDUnit;
  TabSheet : TTabSheet;
  Memo : TMemo;
  Mes : string;
begin
  StatusBar1.SimpleText := '';
  CompileNew := (ActiveUnit = nil);
  WUnit := nil;
  InfoMemo.Lines.Clear;
  try
    if K_CompileUnit( TMemo( MemoList.Objects[ActiveListIndex] ).Lines.Text,
                      WUnit, true, false, MemoList[ActiveListIndex] ) then begin
      Mes := 'OK';
      CompiledUnitIndex := ActiveListIndex;
      UnitList.Strings[CompiledUnitIndex] := '';
      if K_DebugGC.RTE.RTEFlag <> 0 then ShowRuntimeErrInfo( K_DebugGC.RTE );
    end else begin
      Mes := 'errors';
      if WUnit <> nil then WUnit.ClearChilds;
    end;
  except
  end;

  CompiledUnitIndex := -1;

  if WUnit <> nil then WUnit.Owner.RebuildVNodes;

  Memo := TMemo( MemoList.Objects[ActiveListIndex] );
  TabSheet := TTabSheet( Memo.Parent );

  if CompileNew and
     (WUnit <> nil) then begin // Set Edit Context
    ActiveUnit := WUnit;
    Caption := ActiveUnit.ObjAliase;
    TabSheet.Caption := ActiveUnit.ObjName;
    MemoList.Strings[ActiveListIndex] := Caption;
    UnitList.Objects[ActiveListIndex] := ActiveUnit;
    Mes := Mes + '. Unit ' + ActiveUnit.ObjAliase + ' is created'
  end else
  if (WUnit <> ActiveUnit) and
     (WUnit.RefCounter = 0) and
     (UnitList.IndexOfObject(WUnit) = -1) then
    WUnit.UDDelete;

  StatusBar1.SimpleText := TabSheet.Caption + ' is compiled - ' + Mes + '.';

end; //*** end of TK_FormMVDeb.ActionCompileExecute

//********************************************* TK_FormMVDeb.ActionCloseExecute ***
//  Close Edit Text
//
procedure TK_FormMVDeb.ActionCloseExecute(Sender: TObject);
var
  res : word;
  WUnit : TN_UDBase;
begin
  StatusBar1.SimpleText := '';
  if ActiveListIndex = -1 then Exit;
  with TMemo( MemoList.Objects[ActiveListIndex] ) do begin
    if Modified then begin
      res := MessageDlg( 'Text was modified - save?',
        mtConfirmation, [mbYes, mbNo, mbCancel], 0);
      if res = mrYes then begin
        if ActiveUnit <> nil then  //*** Save to Unit
          ActionSaveExecute( nil )
        else
          ActionExportExecute( nil );   //*** Export to File
      end else if res = mrCancel then
        Exit;
    end;
  end;
  MemoList.Delete(ActiveListIndex);
  WUnit := TN_UDBase(UnitList.Objects[ActiveListIndex]);
  if (WUnit <> nil)      and
     (WUnit.Owner = nil)  then
    WUnit.UDDelete();
  UnitList.Delete(ActiveListIndex);
  TTabSheet(PageControl1.ActivePage).Free;
  if PageControl1.PageCount = 0 then begin // Clear Context
    ActiveListIndex := -1;
    ActiveUnit := nil;
//*** Disabled Menu Items
    ActionRun.Enabled := false; // Run
    ActionCompile.Enabled := false; // Compile
    ActionExport.Enabled := false; // Export
    ActionSave.Enabled := false; // Save
    ActionClose.Enabled := false; // Close
    ActionStepOver.Enabled := false; // Run Over
    ActionStepInto.Enabled := false; // Run Into
  end else
    PageControl1Change(Sender);
end;

//********************************************* TK_FormMVDeb.EditKeyUpEvent ***
//  Edit Key Up Event
//
procedure TK_FormMVDeb.EditKeyUpEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

  if (Key = 115)       and   //*** F4
     (ssCtrl in Shift) and   //*** Ctrl
     (ActiveListIndex >= 0 ) then
    ActionCloseExecute(Sender);

end;

//********************************************* TK_FormMVDeb.RunKeyUpEvent ***
//  Run Key Up Event
//
procedure TK_FormMVDeb.RunKeyUpEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
{
  case Key of
    113 : if ssCtrl in Shift then                //*** Ctrl/F2
            ActionBreakExecute( Sender );
    118 : ActionStepIntoExecute( Sender );       //*** F7
    119 : if ssCtrl in Shift then
            ActionStepOutExecute( Sender )       //*** Shift/F8
          else
            ActionStepOverExecute( Sender );     //*** F8

    120 : ActionRunExecute( Sender );            //*** F9
  end;
}
end;

//********************************************* TK_FormMVDeb.ActionRunExecute ***
//  Run while stop in deb mode
//
procedure TK_FormMVDeb.ActionRunExecute(Sender: TObject);
var
  i, FlagSet : Integer;
  RI, PI : TK_UDProgramItem;
  Mes : string;
  SB : TStatusBar;
begin
  K_DebugGC.FlagSet := K_DebugGC.FlagSet or K_gcDebMode;
  if RunState then begin
    Close;
  end else begin //Start Run
    StatusBar1.SimpleText := '';
    //*** Save All Open Units
    SaveAllUnits;
    FlagSet := K_DebugGC.FlagSet;

    //*** Compile Current
    ActionCompileExecute(Sender);

    //*** Select Run Item
    RI := nil;
    with ActiveUnit do
      for i := 0 to DirHigh do begin
        PI := TK_UDProgramItem( DirChild( i ) );
        if ((PI.ClassFlags and $FF) <> K_UDProgramItemCI) or
           (PI.ParamsCount <> 0) then continue;
        RI := PI;
      end;
    //*** Run
    if RI = nil then begin //*** Nothing to DO
      Mes := 'Nothing to Run in Unit '+ActiveUnit.ObjAliase;
      K_ShowMessage( Mes );
    end else begin         //*** Run Selected
{
      RunState := True;
      ActionBreak.Enabled := true;  // Program Reset
      ActionStepOut.Enabled := true; // Run Until Return
}
{}
      if K_DebugGC.SPLGCDumpWatch = nil then begin
        if ShowDumpInStatusBar then
          SB := StatusBar1
        else
          SB := nil;
        K_DebugGC.SPLGCDumpWatch := TK_InfoWatch.Create( WatchLinesNum, DumpFileName, SB );
        K_DebugGC.SPLGCDumpWatch.SetWatchRect( WRect );
      end;
{}
      K_DebugGC.SPLGCDumpWatch.AddInfoLine('Running '+ActiveUnit.ObjName+'\'+RI.ObjName, 0);

      K_DebugGC.FlagSet := FlagSet;
      Mes := '';
      try
        {
        if R3Form <> nil then begin
          K_DebugGC.MainProgramItem := RI;
          K_DebugGC.RFrame := R3Form.RFrame;
          with R3Form.RFrame do begin
            K_DebugGC.OCanvas := OCanv;
            DrawProcObj := K_DebugGC.RunSPL;
            SkipOnResize := True;
            RedrawAll();
            SkipOnResize := False;
          end;
          R3Form.Show;
        end else
        }
        RI.SPLProgExecute( K_DebugGC );
        if K_DebugGC.RTE.RTEFlag <> 0 then
          ShowRuntimeErrInfo( K_DebugGC.RTE );
      except
        K_DebugGC.SPLGCDumpWatch.AddInfoLine('Runtime Error in '+ActiveUnit.ObjName+'\'+RI.ObjName, 0);
      end;

      K_DebugGC.SPLGCDumpWatch.AddInfoLine('Finish '+ActiveUnit.ObjName+'\'+RI.ObjName, 0);
{
      RunState := False;
      ActionBreak.Enabled := false; // Program Reset
      ActionStepOut.Enabled := false; // Run Until Return
}
      StatusBar1.SimpleText := '';
      Beep;

      Show;
      Mes := 'Run complete';
    end;
    StatusBar1.SimpleText := Mes;
  end;
end;

//********************************************* TK_FormMVDeb.ActionBreakExecute ***
//  Program Reset
//
procedure TK_FormMVDeb.ActionBreakExecute(Sender: TObject);
begin
  K_DebugGC.FlagSet := (K_DebugGC.FlagSet and K_gcDebFlags) or K_gcDebMode or K_gcBreakExec;
  ActionRunExecute(Sender);
end;

//********************************************* TK_FormMVDeb.ActionStepOverExecute ***
//  Step Over
//
procedure TK_FormMVDeb.ActionStepOverExecute(Sender: TObject);
begin
//  K_DebugGC := K_PrepSPLRunGCont( K_DebugGC );
  K_DebugGC.FlagSet := (K_DebugGC.FlagSet and K_gcDebFlags) or K_gcDebMode or K_gcStepOver;
  ActionRunExecute(Sender);
end;

//********************************************* TK_FormMVDeb.ActionStepIntoExecute ***
//  Trace Into
//
procedure TK_FormMVDeb.ActionStepIntoExecute(Sender: TObject);
begin
//  K_DebugGC := K_PrepSPLRunGCont( K_DebugGC );
  K_DebugGC.FlagSet := (K_DebugGC.FlagSet and K_gcDebFlags) or K_gcDebMode or K_gcTraceInto;
  ActionRunExecute(Sender);
end;

//********************************************* TK_FormMVDeb.ActionStepOutExecute ***
//  Run Until Return
//
procedure TK_FormMVDeb.ActionStepOutExecute(Sender: TObject);
begin
  K_DebugGC.FlagSet := (K_DebugGC.FlagSet and K_gcDebFlags) or K_gcDebMode or K_gcRunToReturn;
  ActionRunExecute(Sender);
end;

//********************************************* TK_FormMVDeb.ActionParamsExecute ***
//  Run Until Return
//
procedure TK_FormMVDeb.ActionParamsExecute(Sender: TObject);
begin
  if K_FormDebParams = nil then
    K_FormDebParams := TK_FormDebParams.Create(Application);

  with K_FormDebParams do begin
    MEWWinCapacity.Text := IntToStr(WatchLinesNum);

    WRect := K_DebugGC.SPLGCDumpWatch.GetWatchRect;
    MEWWinLeft.Text := IntToStr(WRect.Left);
    MEWWinTop.Text := IntToStr(WRect.Top);
    MEWWinWidth.Text := IntToStr(WRect.Right);
    MEWWinHeight.Text := IntToStr(WRect.Bottom);

    EdFileName.Text := DumpFileName;
    ChBShowDumpInStatusBar.Checked := ShowDumpInStatusBar;
    ChBDumpInitSection.Checked := DumpInitSection;
    ChBShowDWindow.Checked := ShowDWindow;
    MaskEditDWinWidth.Text := IntToStr(DWinWidth);
    MaskEditDWinHeight.Text := IntToStr(DWinHeight);

    ShowModal;

    if ModalResult = mrOk then begin
      WatchLinesNum := StrToIntDef( Trim(MEWWinCapacity.Text), 0 );

      WRect.Left := StrToIntDef( Trim(MEWWinLeft.Text), WRect.Left );
      WRect.Top := StrToIntDef( Trim(MEWWinTop.Text), WRect.Top );
      WRect.Right := StrToIntDef( Trim(MEWWinWidth.Text), WRect.Right );
      WRect.Bottom := StrToIntDef( Trim(MEWWinHeight.Text), WRect.Bottom );

      if K_DebugGC.SPLGCDumpWatch = nil then begin
        K_DebugGC.SPLGCDumpWatch := TK_InfoWatch.Create( WatchLinesNum, DumpFileName );
      end;

      if ShowDumpInStatusBar then
        K_DebugGC.SPLGCDumpWatch.StatusBar := StatusBar1
      else
        K_DebugGC.SPLGCDumpWatch.StatusBar := nil;
      K_DebugGC.SPLGCDumpWatch.SetWatchRect( WRect );

      DumpFileName := EdFileName.Text;
      ShowDumpInStatusBar := ChBShowDWindow.Checked;
      DumpInitSection := ChBDumpInitSection.Checked;

      DWinWidth := StrToIntDef( Trim(MaskEditDWinWidth.Text), 0 );
      DWinHeight := StrToIntDef( Trim(MaskEditDWinHeight.Text), 0 );
      ShowDWindow := ChBShowDWindow.Checked;

      if R3Form <> nil then R3Form.Close;
      if ShowDWindow then begin
//        R3Form := N_CreateRast3FrForm( DWinWidth, DWinHeight );
//        R3Form := N_CreateRast3FrForm( nil );
        N_PlaceTControl( R3Form, Self );
      end;
{
      if K_DebugGC <> nil then begin
        K_DebugGC.DumpWatch.Free;
        K_DebugGC.DumpWatch := nil;
      end;
}
    end;
  end;
end;

//********************************************* TK_FormMVDeb.FormDestroy
//  On Form Destroy Handler
//
procedure TK_FormMVDeb.FormDestroy(Sender: TObject);
begin
//  K_DebugGC.Free;
//  K_DebugGC.ARelease;
//  K_DebugGC := nil;
//  if R3Form <> nil then R3Form.Close;
end;

//********************************************* TK_FormMVDeb.ShowErrorInfo
//  Show SPL Compile Error Info Routine
//
procedure TK_FormMVDeb.ShowErrorInfo( UDModuleRoot: TK_UDUnit; UnitName,
  ErrMessage: string; ErrPos, ErrLength, ErrRow, ErrRowPos: Integer );
var WErrStr : string;
begin
   WErrStr := 'Unit "'+UnitName+
              '" row '+IntToStr( ErrRow )+' pos '+IntToStr( ErrRowPos )+
              ' -> '+ ErrMessage;
   ShowUnitMemo( UDModuleRoot, ErrPos - 1, ErrLength, WErrStr, true );
   K_InfoWatch.AddInfoLine( WErrStr, K_msError );
end;

//********************************************* TK_FormMVDeb.ShowRuntimeErrInfo
//  Show SPL Compile Error Info Routine
//
procedure TK_FormMVDeb.ShowRuntimeErrInfo( const RTE : TK_RTEInfo );
var WErrStr : string;
begin
   WErrStr := 'Runtime Error: '+RTE.RTEMessage;
   K_InfoWatch.AddInfoLine( WErrStr, K_msError);
//   RunState := False;
   ShowUnitMemo( TK_UDUnit(RTE.RTEUnit), RTE.RTETextPos, RTE.RTETextSize, WErrStr, true );
end;

//**************************************** TK_FormMVDeb.IfDataWasChanged
function TK_FormMVDeb.IfDataWasChanged: Boolean;
var
  i : Integer;
begin
  Result := false;
  for i := 0 to MemoList.Count - 1 do begin
    Result := TMemo( MemoList.Objects[i] ).Modified;
    if Result then Break;
  end;
end; //*** end of TK_FormMVDeb.IfDataWasChanged

//********************************************* TK_FormMVDeb.OnSaveChangedUnitText
//  On Change Unit SPL Text Handler
//
procedure TK_FormMVDeb.OnSaveChangedUnitText( AUDUnit: TN_UDBase );
begin
//*** Rebuild UDUnit View
  K_TreeViewsUpdateModeSet;
  AUDUnit.RebuildVNodes( 0 );
  K_TreeViewsUpdateModeClear;
  K_SetChangeSubTreeFlags( AUDUnit );
//*** Set Change Archive Flag if needed
//  if (K_CurArchive = nil) or (K_CurArchive.GetRefPathToObj( AUDUnit ) = '') then Exit;
  if (K_CurArchive = nil) or
     (K_GetPathToUObj( AUDUnit, K_CurArchive, K_ontObjName, [K_ptfSkipOwnersAbsPath] ) = '') then Exit;
  K_SetArchiveChangeFlag;
end;

//********************************************* TK_FormMVDeb.OnSaveChangedUnitText
//  On Create Form Handler
//
procedure TK_FormMVDeb.FormCreate(Sender: TObject);
begin
 OnSaveChangedUnitTextProc := OnSaveChangedUnitText;
end;

//********************************************* TK_FormMVDeb.CurStateToMemIni
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormMVDeb.CurStateToMemIni;
begin
  inherited;
  N_IntToMemIni( BFSelfName, 'PageControl1.Height', PageControl1.Height );
//*** Trace Context
  N_IntToMemIni( BFSelfName, 'WatchLinesNum', WatchLinesNum );
  N_IntToMemIni( BFSelfName, 'WRect.Left', WRect.Left );
  N_IntToMemIni( BFSelfName, 'WRect.Top', WRect.Top );
  N_IntToMemIni( BFSelfName, 'WRect.Width', WRect.Right );
  N_IntToMemIni( BFSelfName, 'WRect.Height', WRect.Bottom );
  N_StringToMemIni( BFSelfName, 'DumpFileName', DumpFileName );
  N_BoolToMemIni( BFSelfName, 'ShowDumpInStatusBar', ShowDumpInStatusBar );
  N_BoolToMemIni( BFSelfName, 'DumpInitSection', DumpInitSection );

end;

//********************************************* TK_FormMVDeb.MemIniToCurState
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormMVDeb.MemIniToCurState;
begin
  inherited;
  PageControl1.Height := N_MemIniToInt( BFSelfName, 'PageControl1.Height', PageControl1.Height );
//*** Trace Context
  WatchLinesNum := N_MemIniToInt( BFSelfName, 'WatchLinesNum', WatchLinesNum );
  WRect.Left := N_MemIniToInt( BFSelfName, 'WRect.Left', WRect.Left );
  WRect.Top := N_MemIniToInt( BFSelfName, 'WRect.Top', WRect.Top );
  WRect.Right := N_MemIniToInt( BFSelfName, 'WRect.Width', WRect.Right );
  WRect.Bottom := N_MemIniToInt( BFSelfName, 'WRect.Height', WRect.Bottom );
  DumpFileName := N_MemIniToString( BFSelfName, 'DumpFileName', DumpFileName );
  ShowDumpInStatusBar := N_MemIniToBool( BFSelfName, 'ShowDumpInStatusBar', ShowDumpInStatusBar );
  DumpInitSection := N_MemIniToBool( BFSelfName, 'DumpInitSection', DumpInitSection );
end;

procedure TK_FormMVDeb.FormShow(Sender: TObject);
begin
  inherited;
//
end;

end.
