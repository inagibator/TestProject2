unit K_FUDCSDBlock;

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
  TK_FormUDCSDBlock = class(TN_BaseForm)
    LbID: TLabel;
    Label1: TLabel;

    EdID: TEdit;

    BtCancel: TButton;
    BtOK    : TButton;
    Button1 : TButton;

    ActionList1: TActionList;
    ApplyBlockData  : TAction;
    CreateUDCSDBlock: TAction;
    RenameUDCSDBlock: TAction;
    CloseAction     : TAction;
    OK              : TAction;
    Cancel          : TAction;

    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;

    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton12: TToolButton;
    ToolButton11: TToolButton;

    FrUDList: TK_FrameUDList;
    FrameCSDBlockEdit: TK_FrameCSDBlockEdit;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CreateUDCSDBlockExecute(Sender: TObject);
    procedure ApplyBlockDataExecute(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure OKExecute(Sender: TObject);
    procedure CancelExecute(Sender: TObject);
  private
    { Private declarations }
    IniCaption : string;
    DataSaveModalState : word;

    GActionType : TK_RAFGlobalAction;

    procedure OnApplyBlockData;
    procedure OKToAllFunc;
    procedure CancelToAllFunc;
    procedure ShowUDCSDBlock( UDCSDBlock : TN_UDBase );
  public
    { Public declarations }
    DataWasChanged : Boolean;
    ResultDataWasChanged : Boolean;

    CurUDCSDBlock : TK_UDCSDBlock;
    CurUDCSDBRoot : TN_UDBase;

    OnGlobalAction : TK_RAFGlobalActionProc;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
    function  SaveDataIfNeeded : Boolean;
    function  SaveDataToCurUDCSDBlock: Boolean;
    procedure AddChangeDataFlag;
    procedure ClearChangeDataFlag;
    procedure SetSelectObjsUDRoot( ASelectObjsUDRoot : TN_UDBase );
  end;

function  K_GetFormUDCSDBlock( AOwner: TN_BaseForm ) : TK_FormUDCSDBlock;
function  K_EditUDCSDBlock( UDCSDBlock : TK_UDCSDBlock; AOwner: TN_BaseForm = nil;
              AOnGlobalAction : TK_RAFGlobalActionProc = nil;
              ANotModalShow : Boolean = false ) : Boolean;

var K_UDCSDBlockEditCont : TK_RAEditFuncCont;
function K_EditUDCSDBlockFunc( var UDCSDBlock; PDContext: Pointer ) : Boolean;

implementation

uses
  K_CLib, K_UDT2, K_FUDRename, K_FSFCombo, K_VFunc,
  N_ClassRef, N_Lib1, N_ButtonsF;

{$R *.dfm}



//***********************************  K_EditUDCSDBlockFunc
// function which is registered as Code Dimentions Relation Editor
//
function K_EditUDCSDBlockFunc( var UDCSDBlock; PDContext: Pointer ) : Boolean;
begin
  with TK_PRAEditFuncCont(PDContext)^ do
  Result := K_EditUDCSDBlock( TK_UDCSDBlock(UDCSDBlock), FOwner,
                                FOnGlobalAction, FNotModalShow );
end; // end of K_EditUDCSDBlockFunc

//***********************************  K_GetFormUDCSDBlock
// Get Edit Form
//
function  K_GetFormUDCSDBlock( AOwner: TN_BaseForm ) : TK_FormUDCSDBlock;
begin
  Result := TK_FormUDCSDBlock.Create(Application);
  Result.BaseFormInit( AOwner );
end; // end of K_GetFormUDCSDBlock

//***********************************  K_EditUDCSDBlock
// Edit UDCSDBlock Object
//
function  K_EditUDCSDBlock( UDCSDBlock : TK_UDCSDBlock; AOwner: TN_BaseForm = nil;
              AOnGlobalAction : TK_RAFGlobalActionProc = nil;
              ANotModalShow : Boolean = false ) : Boolean;
begin
  with K_GetFormUDCSDBlock( AOwner ) do begin
    CurUDCSDBlock := UDCSDBlock;
    OnGlobalAction := AOnGlobalAction;
    if ANotModalShow then
      Show
    else
      ShowModal;
    Result := ResultDataWasChanged;
  end;
end; // end of K_EditUDCSDBlock

//***********************************  TK_FormUDCSDBlock.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormUDCSDBlock.CurStateToMemIni();
begin
  inherited;
  N_StringsToMemIni ( Name+'CDB', FrUDList.PathList );
end; // end of TK_FormUDCSDBlock.CurStateToMemIni

//***********************************  TK_FormUDCSDBlock.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormUDCSDBlock.MemIniToCurState();
begin
  inherited;
  N_MemIniToStrings( Name+'CDB', FrUDList.PathList );
end; // end of TK_FormUDCSDBlock.MemIniToCurState

//***********************************  TK_FormUDCSDBlock.SaveDataIfNeeded
// Test if Data Saveing is needed
//
function TK_FormUDCSDBlock.SaveDataIfNeeded : Boolean;
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

end; // end of TK_FormUDCSDBlock.SaveDataIfNeeded

//***********************************  TK_FormUDCSDBlock.SaveDataToCurUDCSDBlock
// Save Data To Relation Object
//
function TK_FormUDCSDBlock.SaveDataToCurUDCSDBlock: Boolean;

begin
  FrameCSDBlockEdit.SaveDataToCRDBlock;

  ClearChangeDataFlag;

//  if Assigned(OnGlobalAction) then OnGlobalAction( K_fgaOK );
  GActionType := K_fgaOK;

  ResultDataWasChanged := true;
  Result := true;
end; // end of TK_FormUDCSDBlock.SaveDataToCurUDCSDBlock

//***********************************  TK_FormUDCSDBlock.AddChangeDataFlag
// Change COntrols after Data Change
//
procedure TK_FormUDCSDBlock.AddChangeDataFlag;
begin
  inherited;
  BtOK.Caption := 'OK';
  BtCancel.Enabled := true;
  ApplyBlockData.Enabled := true;
  DataWasChanged := true;
end; // end of TK_FormUDCSDBlock.AddChangeDataFlag

//***********************************  TK_FormUDCSDBlock.ClearChangeDataFlag
// Change Controls after Data Save
//
procedure TK_FormUDCSDBlock.ClearChangeDataFlag;
begin
//  inherited;
  BtOK.Caption := 'Выход';
  BtCancel.Enabled := false;
  ApplyBlockData.Enabled := false;
  DataWasChanged := false;
end; // end of TK_FormUDCSDBlock.ClearChangeDataFlag

//***********************************  TK_FormUDCSDBlock.FormCreate
// Form Create Handler
//
procedure TK_FormUDCSDBlock.FormCreate(Sender: TObject);
begin
  inherited;
  ClearChangeDataFlag;
  IniCaption := Caption;
  with FrUDList do begin
    SFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCSDBlockCI ) );
    SelCaption := 'Выбор блока данных';
    SelButtonHint := 'Выбор блока данных';
    SelShowToolBar := true;
    FRUDListRoot := K_CurArchive;
    UDObj := nil;
    OnUDObjSelect := ShowUDCSDBlock;
  end;

  CurUDCSDBlock := nil;

  with FrameCSDBlockEdit, FrameCSDBDataEdit do begin
    InitFrame( Self.AddChangeDataFlag );
    OnCancelToAll := CancelToAllFunc;
    OnOKToAll := OKToAllFunc;
    OnDataApply := OnApplyBlockData;
  end;
end; // end of TK_FormUDCSDBlock.FormCreate

//***********************************  TK_FormUDCSDBlock.CreateUDCSDBlockExecute
// Create Data Block Action Handler
//
procedure TK_FormUDCSDBlock.CreateUDCSDBlockExecute(Sender: TObject);
var
  NName, NAliase : string;
  RRoot : TN_UDBase;
//  ColUDCDimOrCSDim : TN_UDBase;
//  RowUDCDimOrCSDim : TN_UDBase;
  WCSDBlockType : TK_ExprExtType;
//  N : Integer;
begin
//*** Select Root Node
  RRoot := CurUDCSDBRoot;
  if not K_SelectUDNode( RRoot, FrameCSDBlockEdit.SelectObjsUDRoot, nil,
                            'Выбор каталога для сохранения объекта', false  ) then Exit;
//  Application.ProcessMessages;
//  if not FrameCSDBlockEdit.SelectNewCSDBlockParams( WCSDBlockType,
//                          ColUDCDimOrCSDim, RowUDCDimOrCSDim ) then Exit;
  WCSDBlockType.All := 0;
  if not K_SelectDBlockElemTypeCode( WCSDBlockType.DTCode,
                                       'Тип элемента блока данных' ) then Exit;

//*** Select New CSDim Root
  with RRoot do begin
    NAliase := BuildUniqChildName( 'Данные', nil, K_ontObjAliase );
    NName := BuildUniqChildName( 'DataBlock' );
  end;

//*** Edit ObjName and ObjAliases
  if not K_EditNameAndAliase(  NAliase, NName ) then Exit;

//*** Check if Saving previous Data Block Needed
  if not SaveDataIfNeeded  then Exit;

//*** Create New New Data Block
//  CurUDCSDBlock := TK_UDCSDBlock.CreateAndInit( WCSDBlockType, NName,
//                 ColUDCDimOrCSDim, RowUDCDimOrCSDim, NAliase, RRoot );
  CurUDCSDBlock := TK_UDCSDBlock.CreateAndInit( WCSDBlockType, NName,
                 nil, nil, NAliase, RRoot );
  FrUDList.AddUDObjToTop( CurUDCSDBlock, RRoot );

//  Application.ProcessMessages;

  RRoot.RebuildVNodes;
  AddChangeDataFlag;

end; // end of TK_FormUDCSDBlock.CreateUDCSDBlockExecute

//***********************************  TK_FormUDCSDBlock.ApplyBlockDataExecute
// Apply Block Data Action Handler
//
procedure TK_FormUDCSDBlock.ApplyBlockDataExecute(Sender: TObject);
begin
  OnApplyBlockData;
end; // end of TK_FormUDCSDBlock.ApplyBlockDataExecute

//***********************************  TK_FormUDCSDBlock.CurStateToMemIni  ******
// Form Show Handler
//
procedure TK_FormUDCSDBlock.FormShow(Sender: TObject);
begin
  RenameUDCSDBlock.Enabled := false;
  ApplyBlockData.Enabled := false;

  if CurUDCSDBlock = nil then
    FrUDList.InitByPathIndex
  else
    FrUDList.AddUDObjToTop( CurUDCSDBlock );

  ClearChangeDataFlag;
  DataSaveModalState := mrNone;
  ResultDataWasChanged := false;
  GActionType := K_fgaNone;
end; // end of TK_FormUDCSDBlock.FormShow

//***********************************  TK_FormUDCSDBlock.ShowUDCSDBlock
// Show new Code Space Data Block
//
procedure TK_FormUDCSDBlock.ShowUDCSDBlock( UDCSDBlock : TN_UDBase );
begin
  if not SaveDataIfNeeded then Exit;
  ClearChangeDataFlag;
  CurUDCSDBlock := TK_UDCSDBlock(UDCSDBlock);
  RenameUDCSDBlock.Enabled := true;
  Caption := CurUDCSDBlock.GetUName + ' - ' + IniCaption;
  EdID.Text := CurUDCSDBlock.ObjName;
  CurUDCSDBRoot := FrUDList.UDParent;
  if CurUDCSDBRoot = nil then CurUDCSDBRoot := CurUDCSDBlock.Owner;

  FrameCSDBlockEdit.ShowCRDBlock(CurUDCSDBlock.R);
//  DataTSheet.Invalidate;
end; // end of TK_FormUDCSDBlock.ShowUDCSDBlock

//***********************************  TK_FormUDCSDBlock.BtCancelClick
// Button Cancel Click Handler
//
procedure TK_FormUDCSDBlock.BtCancelClick(Sender: TObject);
begin
  DataSaveModalState := mrNo;
  if not (fsModal in FormState)	then Close;
  ModalResult := mrCancel;
  GActionType := K_fgaNone;
end; // end of TK_FormUDCDRelation.BtCancelClick

//***********************************  TK_FormUDCSDBlock.BtOKClick
// Button OK Click Handler
//
procedure TK_FormUDCSDBlock.BtOKClick(Sender: TObject);
begin
  DataSaveModalState := mrYes;
  if not (fsModal in FormState)	then Close;
  ModalResult := mrOK;
end; // end of TK_FormUDCSDBlock.BtOKClick

//***********************************  TK_FormUDCSDBlock.CancelExecute
// Cancel Action Handler
//
procedure TK_FormUDCSDBlock.CancelExecute(Sender: TObject);
begin
  DataSaveModalState := mrNo;
  if not (fsModal in FormState)	then Close;
  ModalResult := mrCancel;
  GActionType := K_fgaNone;
end; // end of TK_FormUDCSDBlock.CancelExecute

//***********************************  TK_FormUDCSDBlock.OKExecute
// OK Action Handler
//
procedure TK_FormUDCSDBlock.OKExecute(Sender: TObject);
begin
  DataSaveModalState := mrYes;
  if not (fsModal in FormState)	then Close;
  ModalResult := mrOK;
end; // end of TK_FormUDCSDBlock.OKExecute

//***********************************  TK_FormUDCSDBlock.OnApplyBlockData
// Apply Block Data Action Handler
//
procedure TK_FormUDCSDBlock.OnApplyBlockData;
begin
  SaveDataToCurUDCSDBlock;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaApplyToAll );
  GActionType := K_fgaNone;
  FrameCSDBlockEdit.ShowCRDBlock(CurUDCSDBlock.R);
  ResultDataWasChanged := false;
end; // end of TK_FormUDCSDBlock.OnApplyBlockData

//***********************************  TK_FormUDCSDBlock.OKToAllFunc
// Action OK  Handler
//
procedure TK_FormUDCSDBlock.OKToAllFunc;
begin
  DataWasChanged := true;
  OKExecute( nil );
  GActionType := K_fgaOKToAll;
  ModalResult := mrNo;
end; // end of TK_FormUDCSDBlock.OKToAllFunc

//***********************************  TK_FormUDCSDBlock.CancelToAllFunc
// Button Cancel Click Handler
//
procedure TK_FormUDCSDBlock.CancelToAllFunc;
begin
  GActionType := K_fgaCancelToAll;
  CancelExecute( nil );
end; // end of TK_FormUDCSDBlock.CancelToAllFunc

//***********************************  TK_FormUDCSDBlock.FormCloseQuery
// Form CLose Query Handler
//
procedure TK_FormUDCSDBlock.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := SaveDataIfNeeded;
  if not CanClose then Exit;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, GActionType );
//  if FormCSDim <> nil then
//    FormCSDim.ClearChangeDataFlag;
end; // end of TK_FormUDCSDBlock.FormCloseQuery

//***********************************  TK_FormUDCSDBlock.SetSelectObjsUDRoot
// Set Select Objs UDRoot
//
procedure TK_FormUDCSDBlock.SetSelectObjsUDRoot( ASelectObjsUDRoot: TN_UDBase );
begin
  FrameCSDBlockEdit.SelectObjsUDRoot := ASelectObjsUDRoot;
end; // end of TK_FormUDCSDBlock.SetSelectObjsUDRoot


end.
