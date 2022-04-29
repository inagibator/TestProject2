unit K_FUDVTab;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ActnList, ComCtrls, ImgList, ToolWin, Menus,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  N_BaseF, N_Lib1, N_CLassRef, N_Types,
  K_UDT1, K_FrRaEdit, K_SCript1, K_DCSpace, K_FrUDVTab, K_FrUDV, ExtCtrls;

type
  TK_FormUDVectorsTab = class(TN_BaseForm)
    StatusBar: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    EdiColName: TEdit;
    BtOK: TButton;
    BtCancel: TButton;
    ToolButton3: TToolButton;
    MainMenu1: TMainMenu;
    ActionList1: TActionList;
    N1: TMenuItem;
    N2: TMenuItem;
    RebuildGrid1: TMenuItem;
    N3: TMenuItem;
    AddCol1: TMenuItem;
    DeleteCol1: TMenuItem;
    TabDataFrame: TK_FrameRATabEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure EdiColNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DataWasApplied : Boolean;
    DataSaveModalState : word;

    CurUDTab : TK_UDSSTable;
//    CurUDCSIndexS : Integer;
//    CurUDCSIndexD : Integer;
//    CurUDCPIndex, InitUDCPIndex  : Integer;
//    ShowFormMode : Boolean;

  public
    { Public declarations }
    ModeFlags : TK_RAModeFlagSet;
    UDVObjNamePat : string;
    VectorType : string;
    VectorClassInd : Integer;
    DataWasChanged : Boolean;
    ResultDataWasChanged : Boolean;
    OnGAction : TK_RAFGlobalActionProc;
    GActionType : TK_RAFGlobalAction;
    procedure AddChangeDataFlag;
    procedure ClearChangeDataFlag;
    function  SaveDataIfNeeded : Boolean;
    procedure OnAddColumn( ACount : Integer = 1 );
    procedure OnColumnChange;


  end;

var
  K_FormUDVectorsTab: TK_FormUDVectorsTab;

function K_GetFormUDVectorsTab( AOwner: TN_BaseForm ) : TK_FormUDVectorsTab;
function K_EditUDVectorsTab( AUDTab : TK_UDSSTable;
                      ACaption : string = '';
                      AModeFlags : TK_RAModeFlagSet = [K_ramShowLRowNumbers, K_ramColVertical];
                      AUDVObjNamePat : string = '';
                      AVectorType : string = 'TK_DSSVector';
                      AVectorClassInd : Integer = K_UDVectorCI;
                      AOwner: TN_BaseForm = nil;
                      AOnGAction : TK_RAFGlobalActionProc = nil ) : Boolean;

var K_UDSSTableEditCont : TK_RAEditFuncCont;
function K_EditUDSSTableFunc( var UDSSTable; PDContext: Pointer ) : Boolean;

implementation

uses
  inifiles,
  K_Arch, K_CLib,
  N_ButtonsF;

{$R *.dfm}

function K_EditUDSSTableFunc( var UDSSTable; PDContext: Pointer ) : Boolean;
begin
  Result := K_EditUDVectorsTab( TK_UDSSTable(UDSSTable), '',
                 [K_ramShowLRowNumbers, K_ramColVertical], '', 'TK_DSSVector',
                 K_UDVectorCI, TK_PRAEditFuncCont(PDContext).FOwner,
                 TK_PRAEditFuncCont(PDContext).FOnGlobalAction );
end;


function  K_GetFormUDVectorsTab( AOwner: TN_BaseForm ) : TK_FormUDVectorsTab;
begin
  if K_FormUDVectorsTab = nil then begin
    K_FormUDVectorsTab := TK_FormUDVectorsTab.Create(Application);
    K_FormUDVectorsTab.BaseFormInit( AOwner );
  end;
  Result := K_FormUDVectorsTab;
end;

function K_EditUDVectorsTab( AUDTab : TK_UDSSTable; ACaption : string = '';
                      AModeFlags : TK_RAModeFlagSet = [K_ramShowLRowNumbers, K_ramColVertical];
                      AUDVObjNamePat : string = '';
                      AVectorType : string = 'TK_DSSVector';
                      AVectorClassInd : Integer = K_UDVectorCI;
                      AOwner: TN_BaseForm = nil;
                      AOnGAction : TK_RAFGlobalActionProc = nil ) : Boolean;
begin
  with K_GetFormUDVectorsTab( AOwner ) do begin
    Result := false;
    if AUDTab = nil then Exit;
    CurUDTab := AUDTab;
    if ACaption = '' then ACaption := AUDTab.GetUName;
    Caption := ACaption;
    ModeFlags := AModeFlags;
    UDVObjNamePat := AUDVObjNamePat;
    VectorType := AVectorType;
    VectorClassInd := AVectorClassInd;
    OnGAction := AOnGAction;
    ShowModal;
    Result := ResultDataWasChanged;
    K_FormUDVectorsTab := nil;
  end;
end;

procedure TK_FormUDVectorsTab.FormCreate(Sender: TObject);
begin
  TabDataFrame.OnDataChange := AddChangeDataFlag;
  TabDataFrame.OnClearDataChange := ClearChangeDataFlag;
  TabDataFrame.OnColsAdd := OnAddColumn;
  TabDataFrame.OnLColChange := OnColumnChange;
  CurUDTab := nil;
  DataWasApplied := false;
end;

procedure TK_FormUDVectorsTab.FormShow(Sender: TObject);
begin

  MemIniToCurState;
  TabDataFrame.InitFrameByUniForm( CurUDTab,
        ModeFlags, UDVObjNamePat, VectorType, VectorClassInd );

  ClearChangeDataFlag;
  GActionType := K_fgaNone;
  DataSaveModalState := mrNone;
  ResultDataWasChanged := false;

end;

procedure TK_FormUDVectorsTab.AddChangeDataFlag;
begin
  DataWasChanged := true;
  BtCancel.Enabled := true;
  BtOK.Caption := 'OK';
  DataWasApplied := true;
end;

procedure TK_FormUDVectorsTab.ClearChangeDataFlag;
begin
  DataWasChanged := false;
  BtCancel.Enabled := false;
  if not DataWasApplied then
    BtOK.Caption := 'Выход';
end;

function TK_FormUDVectorsTab.SaveDataIfNeeded : Boolean;
var
  res : Word;
begin
  res := DataSaveModalState;
  if DataWasChanged then begin
    if DataSaveModalState = mrNone then
      res := MessageDlg( 'Данные были изменены - запомнить?',
           mtConfirmation, [mbYes, mbNo, mbCancel], 0 );
    if (res = mrYes) then begin
      TabDataFrame.SaveData;
      ResultDataWasChanged := true;
      GActionType := K_fgaOK;
    end;
  end;
  Result := (res <> mrCancel);
end;

procedure TK_FormUDVectorsTab.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := SaveDataIfNeeded;
end;


procedure TK_FormUDVectorsTab.BtOKClick(Sender: TObject);
begin
  DataSaveModalState := mrYes;
end;

procedure TK_FormUDVectorsTab.BtCancelClick(Sender: TObject);
begin
  DataSaveModalState := mrNo;
  GActionType := K_fgaCancelToAll;
end;

procedure TK_FormUDVectorsTab.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  if Assigned(OnGAction) then OnGAction( Self, GActionType );
  TabDataFrame.FreeContext;
end;

procedure TK_FormUDVectorsTab.OnAddColumn( ACount : Integer = 1 );
begin
  TabDataFrame.AddColumnData( EdiColName.Text, ACount );
end;

procedure TK_FormUDVectorsTab.OnColumnChange;
begin
  if TabDataFrame.CurLCol >= 0 then
    EdiColName.Text := TabDataFrame.RAFCArray[TabDataFrame.CurLCol].Caption;
end;

procedure TK_FormUDVectorsTab.EdiColNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key <> VK_RETURN) or (TabDataFrame.CurLCol < 0) then Exit;
  AddChangeDataFlag;
  TabDataFrame.RAFCArray[TabDataFrame.CurLCol].Caption := EdiColName.Text;
  TabDataFrame.SGrid.Invalidate;
end;

end.
