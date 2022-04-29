unit K_FCSDBlock;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, Menus, StdCtrls, ToolWin, ComCtrls,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  N_BaseF, N_Types,
  K_Script1, K_UDT1, K_FrRaEdit, K_FrUDList, K_CSpace,
  K_FrCSDim1, K_FrCSDim2, K_FrCSDBlock, ExtCtrls;

type
  TK_FormCSDBlock = class(TN_BaseForm)

    BtCancel: TButton;
    BtOK    : TButton;
    Button1 : TButton;
    Button2: TButton;
    Button3: TButton;


    ActionList1: TActionList;
    ApplyBlockData  : TAction;
    CloseAction     : TAction;
    OK              : TAction;
    Cancel          : TAction;
    OKToAll         : TAction;
    CancelToAll     : TAction;
    CreateCSDBlock: TAction;

    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N4: TMenuItem;

    ToolBar1: TToolBar;
    ToolButton1 : TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6 : TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    FrameCSDBlockEdit: TK_FrameCSDBlockEdit;

    procedure FormCreate(Sender: TObject);
    procedure ApplyBlockDataExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CreateCSDBlockExecute(Sender: TObject);
    procedure CloseActionExecute(Sender: TObject);
    procedure OKExecute(Sender: TObject);
    procedure CancelExecute(Sender: TObject);
    procedure OKToAllExecute(Sender: TObject);
    procedure CancelToAllExecute(Sender: TObject);
  private
    { Private declarations }
    IniCaption : string;
    DataSaveModalState : word;
    GActionType : TK_RAFGlobalAction;
    SelfGAExecute : Boolean;

    procedure OnApplyBlockData;
    procedure ShowRACSDBlock0;
    procedure CancelToAllFunc;
    procedure OKToAllFunc;
  public
    { Public declarations }
    DataWasChanged : Boolean;
    ResultDataWasChanged : Boolean;

    CreateRAFlags : TK_CreateRAFlags;

    CurRACSDBlock : TK_RArray;
    PRACSDBlock : TK_PRArray;

    OnGlobalAction : TK_RAFGlobalActionProc;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
    procedure ShowRACSDBlock( var RACSDBlock : TK_RArray; ACaption : string = '' );
    function  SaveDataIfNeeded : Boolean;
    function  SaveDataToCurUDCSDBlock: Boolean;
    procedure AddChangeDataFlag;
    procedure ClearChangeDataFlag;
  end;

procedure K_RegCSDBlocksEditFunc;
function  K_GetFormCSDBlock( AOwner: TN_BaseForm ) : TK_FormCSDBlock;
function  K_EditCSDBlock( var ACSDBlock : TK_RArray; AOwner: TN_BaseForm = nil;
              AOnGlobalAction : TK_RAFGlobalActionProc = nil;
              ANotModalShow : Boolean = false; ACreateRAFlags : TK_CreateRAFlags = [] ) : Boolean;

var K_CSDBlockEditCont : TK_RAEditFuncCont;

implementation

uses
  K_CLib, K_UDT2, K_FUDRename, K_FSFCombo, K_VFunc,
  N_ClassRef, N_Lib1, N_ButtonsF;

{$R *.dfm}


//***********************************  K_EditCSDBlockFunc
// function which is registered as Code Dimentions Relation Editor
//
function K_EditCSDBlockFunc( var CSDBlock; PDContext: Pointer ) : Boolean;
var
 ACreateRAFlags : TK_CreateRAFlags;
begin
  with TK_PRAEditFuncCont(PDContext)^ do begin
    ACreateRAFlags := [];
    if (FDType.D.CFlags and K_ccCountUDRef) <> 0 then ACreateRAFlags := [K_crfCountUDRef];
    Result := K_EditCSDBlock( TK_RArray(CSDBlock), FOwner,
                                FOnGlobalAction, FNotModalShow, ACreateRAFlags );
  end;
end; // end of K_EditUDCSDBlockFunc

//***********************************  K_RegCSDBlocksEditFunc
// Registor All Reditor for All CSDBlock Types
//
procedure K_RegCSDBlocksEditFunc;
var
  i : Integer;
  SL : TStringList;
  WStr : string;
begin
  SL := TStringList.Create;
  K_BuildDBlockTypesList( SL );
  for i := 0 to SL.Count - 1 do begin
    WStr := TN_UDBase(SL.Objects[i]).ObjName;
      K_RegGEFunc( 'arrayof '+ WStr, K_EditCSDBlockFunc, @K_CSDBlockEditCont );
  end;
  SL.Free;
end; // end of K_RegCSDBlocksEditFunc

//***********************************  K_GetFormCSDBlock
// Get Edit Form
//
function  K_GetFormCSDBlock( AOwner: TN_BaseForm ) : TK_FormCSDBlock;
begin
  Result := TK_FormCSDBlock.Create(Application);
  Result.BaseFormInit( AOwner );
end; // end of K_GetFormCSDBlock

//***********************************  K_EditCSDBlock
// Edit CDims Relation Object
//
function  K_EditCSDBlock( var ACSDBlock : TK_RArray; AOwner: TN_BaseForm = nil;
              AOnGlobalAction : TK_RAFGlobalActionProc = nil;
              ANotModalShow : Boolean = false; ACreateRAFlags : TK_CreateRAFlags = [] ) : Boolean;
begin
  with K_GetFormCSDBlock( AOwner ) do begin
    ShowRACSDBlock( ACSDBlock );
    OnGlobalAction := AOnGlobalAction;
    CreateRAFlags := ACreateRAFlags;
    if ANotModalShow then
      Show
    else
      ShowModal;
    Result := ResultDataWasChanged;
  end;
end; // end of K_EditCSDBlock

//***********************************  TK_FormCSDBlock.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormCSDBlock.CurStateToMemIni();
begin
  inherited;
end; // end of TK_FormCSDBlock.CurStateToMemIni

//***********************************  TK_FormCSDBlock.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormCSDBlock.MemIniToCurState();
begin
  inherited;
end; // end of TK_FormCSDBlock.MemIniToCurState

//***********************************  TK_FormCSDBlock.SaveDataIfNeeded
// Test if Data Saveing is needed
//
function TK_FormCSDBlock.SaveDataIfNeeded : Boolean;
var
  res : Word;
begin
  res := DataSaveModalState;

  if DataWasChanged then begin
    if DataSaveModalState = mrNone then
      res := MessageDlg( 'Данные были изменены - запомнить?',
           mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if (res = mrYes) and
       not SaveDataToCurUDCSDBlock then
      res := mrCancel;
  end;

  Result := (res <> mrCancel);

end; // end of TK_FormCSDBlock.SaveDataIfNeeded

//***********************************  TK_FormCSDBlock.SaveDataToCurUDCSDBlock
// Save Data To Relation Object
//
function TK_FormCSDBlock.SaveDataToCurUDCSDBlock: Boolean;

begin
  FrameCSDBlockEdit.SaveDataToCRDBlock;
  PRACSDBlock^ := CurRACSDBlock;
  ClearChangeDataFlag;

//  if Assigned(OnGlobalAction) then OnGlobalAction( K_fgaOK );
//  GActionType := K_fgaOK;

  ResultDataWasChanged := true;
  Result := true;
end; // end of TK_FormCSDBlock.SaveDataToCurUDCSDBlock

//***********************************  TK_FormCSDBlock.AddChangeDataFlag
// Change COntrols after Data Change
//
procedure TK_FormCSDBlock.AddChangeDataFlag;
begin
//  inherited;
  OK.Caption := 'OK';
  OKToAll.Caption := 'OK (для всех)';
  Cancel.Enabled := true;
  CancelToAll.Enabled := true;
  ApplyBlockData.Enabled := true;
  DataWasChanged := true;
end; // end of TK_FormCSDBlock.AddChangeDataFlag

//***********************************  TK_FormCSDBlock.ClearChangeDataFlag
// Change Controls after Data Save
//
procedure TK_FormCSDBlock.ClearChangeDataFlag;
begin
//  inherited;
  OK.Caption := 'Выход';
  OKToAll.Caption := 'Выход (для всех)';
  Cancel.Enabled := false;
  CancelToAll.Enabled := false;
  ApplyBlockData.Enabled := false;
  DataWasChanged := false;
end; // end of TK_FormCSDBlock.ClearChangeDataFlag

//***********************************  TK_FormCSDBlock.FormCreate
// Form Create Handler
//
procedure TK_FormCSDBlock.FormCreate(Sender: TObject);
begin
  inherited;
  ClearChangeDataFlag;
  IniCaption := Caption;
  with FrameCSDBlockEdit, FrameCSDBDataEdit do begin
    InitFrame( Self.AddChangeDataFlag );
    OnCancelToAll := CancelToAllFunc;
    OnOKToAll := OKToAllFunc;
    OnDataApply := OnApplyBlockData;
  end;
  SelfGAExecute := false;

end; // end of TK_FormCSDBlock.FormCreate

//***********************************  TK_FormCSDBlock.ApplyBlockDataExecute
// Apply Block Data Action Handler
//
procedure TK_FormCSDBlock.ApplyBlockDataExecute(Sender: TObject);
begin
  OnApplyBlockData;
end; // end of TK_FormCSDBlock.ApplyBlockDataExecute

//***********************************  TK_FormCSDBlock.CurStateToMemIni  ******
// Form Show Handler
//
procedure TK_FormCSDBlock.FormShow(Sender: TObject);
begin
  CreateCSDBlock.Enabled := false;
  ApplyBlockData.Enabled := false;

  DataSaveModalState := mrNone;
  ResultDataWasChanged := false;
  GActionType := K_fgaNone;

  ShowRACSDBlock0;
end; // end of TK_FormCSDBlock.FormShow

//***********************************  TK_FormCSDBlock.OnApplyBlockData
// Apply Block Data Action Handler
//
procedure TK_FormCSDBlock.OnApplyBlockData;
begin
//  if not DataWasChanged then Exit;
  SaveDataToCurUDCSDBlock;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaApplyToAll );
  GActionType := K_fgaNone;
  FrameCSDBlockEdit.ShowCRDBlock( CurRACSDBlock );
  ResultDataWasChanged := false;
end; // end of TK_FormCSDBlock.OnApplyBlockData

//***********************************  TK_FormCSDBlock.ShowRACSDBlock
// Show new Code Space Data Block
//
procedure TK_FormCSDBlock.ShowRACSDBlock0;
begin
//  if not SaveDataIfNeeded then Exit;
  ClearChangeDataFlag;
  CreateCSDBlock.Enabled := CurRACSDBlock = nil;
  if not CreateCSDBlock.Enabled then
    FrameCSDBlockEdit.ShowCRDBlock( CurRACSDBlock )
  else
    CreateCSDBlockExecute(nil);
end; // end of TK_FormCSDBlock.ShowRACSDBlock

//***********************************  TK_FormCSDBlock.CancelToAllExecute
// Button Cancel Click Handler
//
procedure TK_FormCSDBlock.CancelToAllExecute(Sender: TObject);
begin
  SelfGAExecute := true;
  CancelToAllFunc;
  SelfGAExecute := false;
end; // end of TK_FormCSDBlock.CancelToAllExecute

//***********************************  TK_FormCSDBlock.CancelToAllFunc
// Button Cancel Click Handler
//
procedure TK_FormCSDBlock.CancelToAllFunc;
begin
  CancelExecute( nil );
  GActionType := K_fgaCancelToAll;
end; // end of TK_FormCSDBlock.CancelToAllFunc

//***********************************  TK_FormCSDBlock.CancelExecute
// Button Cancel Click Handler
//
procedure TK_FormCSDBlock.CancelExecute(Sender: TObject);
begin
  DataSaveModalState := mrNo;
  if not (fsModal in FormState)	then Close;
  GActionType := K_fgaNone;
  ModalResult := mrCancel;
end; // end of TK_FormCSDBlock.CancelExecute

//***********************************  TK_FormCSDBlock.OKToAllExecute
// Action OKToAll Handler
//
procedure TK_FormCSDBlock.OKToAllExecute(Sender: TObject);
begin
  SelfGAExecute := true;
  OKToAllFunc;
  SelfGAExecute := false;
end; // end of TK_FormCSDBlock.OKToAllExecute

//***********************************  TK_FormCSDBlock.OKToAllFunc
// Action OK  Handler
//
procedure TK_FormCSDBlock.OKToAllFunc;
begin
  if not SelfGAExecute then DataWasChanged := true;
  OKExecute( nil );
  if DataWasChanged then
    GActionType := K_fgaOKToAll
  else
   GActionType := K_fgaCancelToAll;
  ModalResult := mrNo;
end; // end of TK_FormCSDBlock.OKToAllFunc

//***********************************  TK_FormCSDBlock.OKExecute
// Action OK  Handler
//
procedure TK_FormCSDBlock.OKExecute(Sender: TObject);
begin
  DataSaveModalState := mrYes;
  if not (fsModal in FormState)	then Close;
//  GActionType := K_fgaOK;
  ModalResult := mrOK;
end; // end of TK_FormCSDBlock.OKExecute

//***********************************  TK_FormCSDBlock.FormCloseQuery
// Form CLose Query Handler
//
procedure TK_FormCSDBlock.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := SaveDataIfNeeded;
  if not CanClose then Exit;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, GActionType );
end; // end of TK_FormCSDBlock.FormCloseQuery

//***********************************  TK_FormCSDBlock.CreateCSDBlockExecute
//
procedure TK_FormCSDBlock.CreateCSDBlockExecute(Sender: TObject);
var
  WCSDBlockType : TK_ExprExtType;

begin
  WCSDBlockType.All := 0;
  if not K_SelectDBlockElemTypeCode( WCSDBlockType.DTCode,
                                        'Тип элемента блока данных' ) then Exit;
  CurRACSDBlock := K_CreateRADBlock( WCSDBlockType, nil, nil, CreateRAFlags );
  ShowRACSDBlock0;
  AddChangeDataFlag;
end; // end of TK_FormCSDBlock.CreateCSDBlockExecute

//***********************************  TK_FormCSDBlock.ShowRACSDBlock
//
procedure TK_FormCSDBlock.ShowRACSDBlock( var RACSDBlock: TK_RArray; ACaption : string = '' );
begin
  if ACaption <> '' then
    Caption := ACaption + ' - ' + IniCaption;
  PRACSDBlock := @RACSDBlock;
  CurRACSDBlock := RACSDBlock;
end; // end of TK_FormCSDBlock.ShowRACSDBlock

//***********************************  TK_FormCSDBlock.CloseActionExecute
// CLose Action Handler
//
procedure TK_FormCSDBlock.CloseActionExecute(Sender: TObject);
begin
  if not (fsModal in FormState)	then Close;
  ModalResult := mrOK;
end; // end of TK_FormCSDBlock.CloseActionExecute

end.
