unit K_FRunSPLScript;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ActnList, ComCtrls,
  N_Lib0, N_Types, N_FNameFr, N_BaseF,
  K_Types, K_Script1, ExtCtrls;

type
  TK_FormRunSPLScript = class(TN_BaseForm)
    SPLFileFrame: TN_FileNameFrame;
    LbFunc: TLabel;
    CmBFunc: TComboBox;
    ActionList1: TActionList;
    RunSPL: TAction;
    BtPrep: TButton;
    PrepUnit: TAction;
    BtRun: TButton;
    StatusBar: TStatusBar;
    procedure RunSPLExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PrepUnitExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
  private
    { Private declarations }
    WUnit : TK_UDUnit;
    PBCParams: TN_PBCParams;

  public
    { Public declarations }
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
    procedure OnScriptFileChange(  );
    procedure ShowDump( const ADumpLine : string; MesStatus : TK_MesStatus = K_msError );
  end;

var
  K_FormRunSPLScript: TK_FormRunSPLScript;
function K_GetFormRunSPLScript( AOwner : TN_BaseForm = nil ) : TK_FormRunSPLScript;

implementation

uses N_Lib1, N_ClassRef,
  K_Sparse1, K_IWatch, K_CLib0;

{$R *.dfm}

function K_GetFormRunSPLScript( AOwner : TN_BaseForm = nil ) : TK_FormRunSPLScript;
begin
  Result := TK_FormRunSPLScript.Create(Application);
//  Result.BaseFormInit( AOwner );
  Result.BaseFormInit( AOwner, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
end;

//***********************************  TK_FormRunScript.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormRunSPLScript.CurStateToMemIni();
begin
  Inherited;
  N_ComboBoxToMemIni( 'RunSPLUnitHistory', SPLFileFrame.mbFileName );
  N_ComboBoxToMemIni( 'RunSPLFuncHistory', CmBFunc );
  N_IntToMemIni  ( Name, 'FuncInd', CmBFunc.ItemIndex );
end; // end of procedure TK_FormRunScript.CurStateToMemIni

//***********************************  TK_FormRunScript.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormRunSPLScript.MemIniToCurState();
begin
  Inherited;
  N_MemIniToComboBox( 'RunSPLUnitHistory', SPLFileFrame.mbFileName );
  N_MemIniToComboBox( 'RunSPLFuncHistory', CmBFunc );
  CmBFunc.ItemIndex := N_MemIniToInt  ( Name, 'FuncInd', -1 );
end; // end of procedure TK_FormRunScript.MemIniToCurState


procedure TK_FormRunSPLScript.FormCreate(Sender: TObject);
begin
  inherited;
  WUnit := nil;
  SPLFileFrame.OnChange := OnScriptFileChange;
  with N_PBCaller do begin
    SaveParams ( @PBCParams );
    RectProgressBarInit( Self, Rect(5,47,-6,50), $00AA00 );
    SBPBProgressBarInit( 'Выполнено ', StatusBar, nil );
    PBCProcOfObj := RectProgressBarDraw;
//    PBCProcOfObj := SBPBProgressBarDraw;
  end;

end;

procedure TK_FormRunSPLScript.RunSPLExecute(Sender: TObject);
var
  Warning : string;
  FuncName : string;
  FuncInd : Integer;
  UDPI : TK_UDProgramItem;
  GC : TK_CSPLCont;

Label  ExLabel, NoFuncLabel;
begin
  Warning := '';
  if CmBFunc.Items.Count = 0 then begin
    Warning := 'Нет функций для выполнения';
    goto ExLabel;
  end;
  if CmBFunc.ItemIndex = -1 then begin
    Warning := 'Не задано имя функции';
    goto ExLabel;
  end;
  FuncName := CmBFunc.Items[CmBFunc.ItemIndex];
  if WUnit = nil then begin
    PrepUnitExecute(Sender);
    CmBFunc.DroppedDown := false;
  end;
  if WUnit = nil then Exit;
  FuncInd := CmBFunc.Items.IndexOf(FuncName);
  if FuncInd = -1 then  goto NoFuncLabel;
  CmBFunc.ItemIndex := FuncInd;
  UDPI := TK_UDProgramItem(CmBFunc.Items.Objects[FuncInd]);

  if UDPI = nil then begin
NoFuncLabel:
    Warning := 'Функция "'+FuncName+'" отсутствует в модуле';
    goto ExLabel;
  end;
  StatusBar.SimpleText := 'Начато выполнение функции "'+FuncName+'"';

  GC := K_PrepSPLRunGCont( nil );
  GC.ScriptShowMessage := ShowDump;
  if K_RunScriptPI( UDPI, true, GC ) < 1 then
    Warning := 'Ошибка при выполнении функции "'+FuncName+'"';
  K_FreeSPLRunGCont( GC );

ExLabel:
  if Warning <> '' then begin
    beep;
    K_ShowMessage( Warning );
  end else
    Warning := 'Выполнена функция "'+FuncName+'"';
  StatusBar.SimpleText := Warning;
end;

procedure TK_FormRunSPLScript.PrepUnitExecute(Sender: TObject);
var
  FName, Warning : string;
  i : Integer;
  UDPI : TK_UDProgramItem;
begin
  FName := SPLFileFrame.mbFileName.Text;
  Warning := '';
  case K_CompileScriptFile( FName, WUnit ) of
  -1: Warning := 'Файл "'+FName+'" не существует';

   0: Warning := 'Ошибки в файле "'+FName+'"';
   1:
    begin
//*** Build Functions List
      CmBFunc.Items.Clear;
      with WUnit do
        for i := 0 to DirHigh do begin
          UDPI := TK_UDProgramItem( DirChild( i ) );
          if ((UDPI.ClassFlags and $FF) <> K_UDProgramItemCI) or
             (UDPI.ParamsCount <> 0) then continue;
          CmBFunc.Items.AddObject(UDPI.ObjName, UDPI);
        end;
      if CmBFunc.Items.Count > 0 then CmBFunc.ItemIndex := 0;
      CmBFunc.DroppedDown := true;
    end;
  end;
  if Warning <> '' then begin
    beep;
    K_ShowMessage( Warning );
    CmBFunc.Items.Clear;
    CmBFunc.Text := '';
  end else
    Warning := 'Файл "'+FName+'" подготовлен к выполнению';
  StatusBar.SimpleText := Warning;
end;

procedure TK_FormRunSPLScript.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (WUnit <> nil) and
     (WUnit.RefCounter = 0) then FreeAndNil(WUnit);
  N_PBCaller.RestoreParams ( @PBCParams );
  inherited;
end;

procedure TK_FormRunSPLScript.OnScriptFileChange();
begin
  PrepUnitExecute(nil);
end;

procedure TK_FormRunSPLScript.ShowDump( const ADumpLine : string; MesStatus : TK_MesStatus = K_msError );
begin
  if ADumpLine = '' then Exit;
  if MesStatus = K_msError then K_ShowMessage( ADumpLine );
  K_InfoWatch.AddInfoLine( ADumpLine, MesStatus );
end;

end.
