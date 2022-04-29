unit K_FUDV;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ActnList, ComCtrls, ImgList, ToolWin, Menus,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  {N_BaseF, }N_Lib1, N_Types,
  K_FBase, K_UDT1, K_FrRaEdit, K_SCript1, K_DCSpace, K_FrUDV, N_BaseF,
  ExtCtrls;

type

  TK_FormUDVector = class(TK_FormBase)
    StatusBar: TStatusBar;
    ToolBar1: TToolBar;
    BtOK: TButton;
    BtCancel: TButton;
    ToolButton3: TToolButton;
    MainMenu1: TMainMenu;
    ActionList1: TActionList;
    N1: TMenuItem;
    N2: TMenuItem;
    RebuildGrid1: TMenuItem;
    N3: TMenuItem;
    DataFrame: TK_FrameRAVectorEdit;
    EdUName: TEdit;
    BtApply: TButton;
    Apply: TAction;
    OK: TAction;
    Cancel: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ShowUDVector;
    procedure CellDisable( var Disabled : TK_RAFDisabled; ACol, ARow : Integer );
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure EdUNameChange(Sender: TObject);
    procedure ApplyExecute(Sender: TObject);
    procedure OKExecute(Sender: TObject);
    procedure CancelExecute(Sender: TObject);

  private
    DataWasApplied : Boolean;
    DataSaveModalState : word;
    DataProj : TN_IArray;
    GActionType : TK_RAFGlobalAction;
    ModalShowFlag : Boolean;
//    CurUDCSIndexS : Integer;
//    CurUDCSIndexD : Integer;
//    CurUDCPIndex, InitUDCPIndex  : Integer;
//    ShowFormMode : Boolean;

  public
    { Public declarations }
    CurUDVector : TK_UDVector;
    PDSSVector: TK_PDSSVector;
    ModeFlags : TK_RAModeFlagSet;
    DataWasChanged : Boolean;
    ResultDataWasChanged : Boolean;
    DataName  : string;
    FormClassName : string;
    UniTypeClassName : string;
    TargetCSS : TK_UDDCSSpace;

    OnGlobalAction : TK_RAFGlobalActionProc;
    procedure ApplyDataAction;
    procedure CancelToAllAction;
    procedure OKToAllAction;

    procedure AddChangeDataFlag;
    procedure ClearChangeDataFlag;
    procedure SaveData;
    function  SaveDataIfNeeded : Boolean;

  end;

var
  K_FormUDVector: TK_FormUDVector;

function  K_GetFormUDVector( AOwner: TN_BaseForm ) : TK_FormUDVector;
function  K_EditDSSVector( var DSSVector: TK_DSSVector; ModalShow : Boolean = true;
                      ACaption : string = '';
                      ADataName : string = '';
                      AModeFlags : TK_RAModeFlagSet = [K_ramColVertical];
                      AFormClassName : string = 'TK_FormUDVTabUni';
                      AUniTypeClassName : string = 'TK_TypeUDVTabUni';
                      AOwner: TN_BaseForm = nil;
                      AOnGAction : TK_RAFGlobalActionProc = nil;
                      ATargetCSS : TK_UDDCSSpace = nil ) : Boolean;
function  K_EditUDVector( AUDVector : TK_UDVector; ModalShow : Boolean = true;
                      ACaption : string = '';
                      ADataName : string = '';
                      AModeFlags : TK_RAModeFlagSet = [K_ramColVertical];
                      AFormClassName : string = 'TK_FormUDVTabUni';
                      AUniTypeClassName : string = 'TK_TypeUDVTabUni';
                      AOwner: TN_BaseForm = nil;
                      AOnGAction : TK_RAFGlobalActionProc = nil;
                      ATargetCSS : TK_UDDCSSpace = nil ) : Boolean;


implementation

uses
  inifiles,
  K_Arch,
  N_ButtonsF;

{$R *.dfm}

//*************************************** K_GetFormUDVector
//
function  K_GetFormUDVector( AOwner: TN_BaseForm ) : TK_FormUDVector;
begin
  if K_FormUDVector = nil then begin
    K_FormUDVector := TK_FormUDVector.Create(Application);
    K_FormUDVector.DataFrame.SkipResizeFlag := TRUE;
    K_FormUDVector.BaseFormInit( AOwner );
    K_FormUDVector.DataFrame.SkipResizeFlag := FALSE;
  end;
  Result := K_FormUDVector;
end; //*** end of K_GetFormUDVector

//*************************************** K_EditDSSVector
//
function K_EditDSSVector( var DSSVector: TK_DSSVector; ModalShow : Boolean = true;
                      ACaption : string = '';
                      ADataName : string = '';
                      AModeFlags : TK_RAModeFlagSet = [K_ramColVertical];
                      AFormClassName : string = 'TK_FormUDVTabUni';
                      AUniTypeClassName : string = 'TK_TypeUDVTabUni';
                      AOwner: TN_BaseForm = nil;
                      AOnGAction : TK_RAFGlobalActionProc = nil;
                      ATargetCSS : TK_UDDCSSpace = nil ) : Boolean;
begin
  with K_GetFormUDVector( AOwner ) do begin
    Result := false;
    if @DSSVector = nil then Exit;
    PDSSVector := @DSSVector;
    if ACaption <> '' then Caption := ACaption;
    ModeFlags := AModeFlags;
    DataName := ADataName;
    FormClassName := AFormClassName;
    UniTypeClassName := AUniTypeClassName;
    OnGlobalAction := AOnGAction;
    TargetCSS := ATargetCSS;
    ModalShowFlag := ModalShow;
    if ModalShow then begin
      ShowModal;
      Result := ResultDataWasChanged;
    end else begin
      Show;
    end;
  end;
end; //*** end of K_EditDSSVector

//*************************************** K_EditUDVector
//
function K_EditUDVector( AUDVector : TK_UDVector; ModalShow : Boolean = true;
                      ACaption : string = '';
                      ADataName : string = '';
                      AModeFlags : TK_RAModeFlagSet = [K_ramColVertical];
                      AFormClassName : string = 'TK_FormUDVTabUni';
                      AUniTypeClassName : string = 'TK_TypeUDVTabUni';
                      AOwner: TN_BaseForm = nil;
                      AOnGAction : TK_RAFGlobalActionProc = nil;
                      ATargetCSS : TK_UDDCSSpace = nil ) : Boolean;
begin
  with K_GetFormUDVector( AOwner ) do begin
    Result := false;
    if AUDVector = nil then Exit;
    CurUDVector := AUDVector;
    Result := K_EditDSSVector( TK_PDSSVector(CurUDVector.R.P)^, ModalShow,
                      ACaption, ADataName, AModeFlags, AFormClassName,
                      AUniTypeClassName, AOwner, AOnGAction, ATargetCSS );
  end;
end; //*** end of K_EditUDVector

//*************************************** TK_FormUDVector.FormCreate
//
procedure TK_FormUDVector.FormCreate(Sender: TObject);
begin
  CurUDVector := nil;
  DataFrame.OnDataChange := AddChangeDataFlag;
  DataFrame.OnClearDataChange := ClearChangeDataFlag;
  DataFrame.OnDataApply := ApplyDataAction;
  DataFrame.OnCancelToAll := CancelToAllAction;
  DataFrame.OnOKToAll := OKToAllAction;
  DataWasApplied := false;
end; //*** end of TK_FormUDVector.FormCreate

//*************************************** TK_FormUDVector.FormShow
//
procedure TK_FormUDVector.FormShow(Sender: TObject);
begin
  DataFrame.SkipResizeFlag := TRUE;
  MemIniToCurState;
  DataFrame.SkipResizeFlag := FALSE;
  EdUName.Visible := (CurUDVector <> nil);
  ShowUDVector;
  ClearChangeDataFlag;
  ResultDataWasChanged := false;
  GActionType := K_fgaNone;
  DataFrame.SGrid.SetFocus();
end; //*** end of TK_FormUDVector.FormShow

//*************************************** TK_FormUDVector.ShowUDVector
//
procedure TK_FormUDVector.ShowUDVector;
//var
//  VectorCSS : TK_UDDCSSpace;
begin
  if CurUDVector <> nil then begin
    EDUName.Text := CurUDVector.GetUName;
    if Caption = '' then Caption := CurUDVector.GetUName;
  end;

//  DataFrame.InitFrame( CurUDVector,
//        ModeFlags, DataName, FormClassName, UniTypeClassName );

  DataFrame.InitFrame0( PDSSVector,
        ModeFlags, DataName, FormClassName, UniTypeClassName );

//  VectorCSS := CurUDVector.GetDCSSpace;
  with PDSSVector^ do begin
    SetLength( DataProj, TK_UDDCSSpace(CSS).PDRA.ALength );
    if TargetCSS <> nil then
      K_BuildDataProjection0( TargetCSS, TK_UDDCSSpace(CSS), @DataProj[0] );
  end;
end; //*** end of TK_FormUDVector.ShowUDVector

//*************************************** TK_FormUDVector.CellDisable
//
procedure TK_FormUDVector.CellDisable( var Disabled : TK_RAFDisabled;  ACol, ARow : Integer );
begin
  if (ARow >= 0) and (DataProj[ARow] < 0) then begin
    if Disabled <> K_rfdColDisabled then
      Disabled :=  K_rfdRowDisabled
    else
      Disabled :=  K_rfdAllDisabled;
  end;
end; //*** end of TK_FormUDVector.CellDisable

//*************************************** TK_FormUDVector.ApplyDataAction
//
procedure TK_FormUDVector.ApplyDataAction;
begin
  if not DataWasApplied then AddChangeDataFlag;
  DataWasApplied := true;
  SaveData;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaApplyToAll );
  GActionType := K_fgaNone;
end; //*** end of TK_FormUDVector.ApplyDataAction

//*************************************** TK_FormUDVector.CancelExecute
//
procedure TK_FormUDVector.CancelExecute(Sender: TObject);
begin
  DataSaveModalState := mrNo;
  CLose;
  ModalResult := mrCancel;
end; //*** end of TK_FormUDVector.CancelExecute

//*************************************** TK_FormUDVector.CancelToAllAction
//
procedure TK_FormUDVector.CancelToAllAction;
begin
  GActionType := K_fgaCancelToAll;
  CancelExecute( nil );
end; //*** end of TK_FormUDVector.CancelToAllAction

//*************************************** TK_FormUDVector.OKExecute
//
procedure TK_FormUDVector.OKExecute(Sender: TObject);
begin
  DataSaveModalState := mrYes;
  if not ModalShowFlag  then
    GActionType := K_fgaOK;
  CLose;
  ModalResult := mrOK;
end; //*** end of TK_FormUDVector.OKExecute

//*************************************** TK_FormUDVector.OKToAllAction
//
procedure TK_FormUDVector.OKToAllAction;
begin
  OKExecute( nil );
  GActionType := K_fgaOKToAll;
end; //*** end of TK_FormUDVector.OKToAllAction

//*************************************** TK_FormUDVector.AddChangeDataFlag
//
procedure TK_FormUDVector.AddChangeDataFlag;
begin
  DataWasChanged := true;
  BtOK.Caption := 'OK';
  BtCancel.Enabled := true;
  BtApply.Enabled := true;
end; //*** end of TK_FormUDVector.AddChangeDataFlag

//*************************************** TK_FormUDVector.ClearChangeDataFlag
//
procedure TK_FormUDVector.ClearChangeDataFlag;
begin
  DataSaveModalState := mrNone;
  DataWasChanged := false;
  BtApply.Enabled := false;
  BtCancel.Enabled := false;
  if not DataWasApplied then
    BtOK.Caption := 'Выход';
end; //*** end of TK_FormUDVector.ClearChangeDataFlag

//*************************************** TK_FormUDVector.SaveData
//
procedure TK_FormUDVector.SaveData;
begin
  if DataWasChanged then begin
    DataFrame.SaveData;
    if not ModalShowFlag and (GActionType = K_fgaNone) then GActionType := K_fgaOK;
    ResultDataWasChanged := true;
    if (CurUDVector <> nil) and (EDUName.Text <> CurUDVector.GetUName) then begin
      CurUDVector.ObjAliase := EDUName.Text;
      CurUDVector.RebuildVNodes(1);
    end;
    ClearChangeDataFlag;
  end;
end; //*** end of TK_FormUDVector.SaveData

//*************************************** TK_FormUDVector.SaveDataIfNeeded
//
function TK_FormUDVector.SaveDataIfNeeded : Boolean;
var
  res : Word;
begin
  res := DataSaveModalState;
  if DataWasChanged then begin
    if DataSaveModalState = mrNone then
      res := MessageDlg( 'Данные были изменены - запомнить?',
           mtConfirmation, [mbYes, mbNo, mbCancel], 0 );
    if (res = mrYes) then
      SaveData;
  end;
  Result := (res <> mrCancel);
end; //*** end of TK_FormUDVector.SaveDataIfNeeded

//*************************************** TK_FormUDVector.FormCloseQuery
//
procedure TK_FormUDVector.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := SaveDataIfNeeded;
end; //*** end of TK_FormUDVector.FormCloseQuery

//*************************************** TK_FormUDVector.BtOKClick
//
procedure TK_FormUDVector.BtOKClick(Sender: TObject);
begin
  DataSaveModalState := mrYes;
  Close;
end; //*** end of TK_FormUDVector.BtOKClick

//*************************************** TK_FormUDVector.BtCancelClick
//
procedure TK_FormUDVector.BtCancelClick(Sender: TObject);
begin
  DataSaveModalState := mrNo;
  Close;
end; //*** end of TK_FormUDVector.BtCancelClick

//*************************************** TK_FormUDVector.FormClose
//
procedure TK_FormUDVector.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  DataFrame.FreeContext;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, GActionType );
  K_FormUDVector := nil;
end; //*** end of TK_FormUDVector.FormClose

//*************************************** TK_FormUDVector.EdUNameChange
//
procedure TK_FormUDVector.EdUNameChange(Sender: TObject);
begin
  AddChangeDataFlag;
end; //*** end of TK_FormUDVector.EdUNameChange

//*************************************** TK_FormUDVector.ApplyExecute
//
procedure TK_FormUDVector.ApplyExecute(Sender: TObject);
begin
  ApplyDataAction;
end; //*** end of TK_FormUDVector.ApplyExecute

end.

