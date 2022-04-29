unit K_FRaEdit;

interface

uses
  Controls, Classes, Forms, StdCtrls, Inifiles,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  K_SCript1, K_FrRaEdit, K_UDT1,
  N_BaseF, N_Types, N_Lib1, ActnList, ToolWin, ComCtrls, ExtCtrls, Menus;

type

  TK_FormRAEdit = class(TN_BaseForm)
    FrameRAEdit: TK_FrameRAEdit;

    ActionList1: TActionList;
    Apply: TAction;
    OK: TAction;
    Cancel: TAction;
    OKToAll: TAction;
    CancelToAll: TAction;
    ViewAsMatrix: TAction;

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
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton10: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    Panel1: TPanel;
    BtApply: TButton;
    BtCancel: TButton;
    BtCancelToAll: TButton;
    BtOK: TButton;
    BtOKToAll: TButton;

    procedure InitState;
    procedure InitControls ( DataName : string );
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure ApplyExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure OKExecute(Sender: TObject);
    procedure CancelExecute(Sender: TObject);
    procedure OKToAllExecute(Sender: TObject);
    procedure CancelToAllExecute(Sender: TObject);
    procedure ViewAsMatrixExecute(Sender: TObject);
  private
    DataSaveModalState : word;
    DataWasApplied : Boolean;
    SelfGAExecute  : Boolean;
    GActionType : TK_RAFGlobalAction;
//    procedure OnSaveData;
    { Private declarations }
  public
    { Public declarations }
//    RootCall       : Boolean;
    DataWasChanged : Boolean;
    ResultDataWasChanged : Boolean;

    FRRAControl : TK_FRAData;
    OnGlobalAction : TK_RAFGlobalActionProc;
    procedure ApplyDataAction;
    procedure CancelToAllAction;
    procedure OKToAllAction;

    procedure SaveData;
    procedure AddChangeDataFlag;
    procedure ClearChangeDataFlag;
    function  SaveDataIfNeeded : Word;
  end;


//var
//  K_FormRAEdit : TK_FormRAEdit;

function K_GetFormRAEdit ( PDContext : TK_PRAEditFuncCont ) : TK_FormRAEdit;
function K_GetFormRAEditResult( FormRAEdit : TK_FormRAEdit ) : Boolean;
function K_FormRAEditPrepareByFormDescr( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
        var Data; ADDType : TK_ExprExtType; const DataName : string;
        FormDescr : TK_UDRArray; GrFlagsMask : LongWord ) : TK_FormRAEdit;
function K_FormRAEditPrepareByFDTypeName( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
        var Data; DDType : TK_ExprExtType; const DataName : string;
        FDTypeName : string; GrFlagsMask : LongWord ) : TK_FormRAEdit;
function K_RAShowEdit( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet; var Data;
        DDType : TK_ExprExtType; const DataName : string;
        const ADataPath : string = '';
        AOwner : TN_BaseForm = nil;
        GEDataID : string = ''; GEDataIDPrefix : string = '';
        PCDescr: TK_RAPFrDescr = nil; AOnGAction : TK_RAFGlobalActionProc = nil;
        APRLSData : TK_PRLSData = nil;
        GrFlagsMask : LongWord = 0;
        FFLags : Integer = 0; FMask : Integer = K_efcFlagsMask0 ) : Boolean;

function K_RAShowEditByFormDescr( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
        var Data; DDType : TK_ExprExtType; const DataName : string;
        FormDescr : TK_UDRArray; GrFlagsMask : LongWord = 0 ) : Boolean;

function K_RAShowEditByFDTypeName( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
        var Data; DDType : TK_ExprExtType; const DataName : string;
        FDTypeName : string; GrFlagsMask : LongWord = 0 ) : Boolean;

function  K_EditUDRAFunc( var UDR : TN_UDBase; AOwnerForm : TN_BaseForm = nil;
                AOnGlobalAction : TK_RAFGlobalActionProc = nil;
                ANotModalShow : Boolean = false ) : Boolean;
function  K_EditUDRAFunc0( var UDR; PDContext: Pointer ) : Boolean;
function  K_EditRADataFunc( var Data; PDContext : TK_PRAEditFuncCont ) : Boolean;
function  K_EditRAListFunc( var Data; PDContext : Pointer ) : Boolean;
function  K_EditUDTreeDataFunc( UDRoot : TN_UDBase; PDContext : TK_PRAEditFuncCont ) : Boolean;


var
  K_RAListEditCont : TK_RAEditFuncCont;

implementation

{$R *.dfm}

uses
  SysUtils, Dialogs, Windows,
  K_CLib, K_Sparse1, K_Arch, K_FSFList,
  N_ButtonsF;


//*************************************** K_BuildUDRAEditFuncCont
// Build RADdit Function Context Record
//
procedure K_BuildUDRAEditFuncCont( UDR : TK_UDRArray; PDContext : TK_PRAEditFuncCont;
                                  BuildModeFlags : Boolean );
begin
  with TK_UDRArray(UDR), TK_PRAEditFuncCont(PDContext)^ do begin
    if BuildModeFlags then
      if R.ALength > 1 then
        FSetModeFlags := [K_ramSkipResizeWidth,K_ramFillFrameWidth,K_ramShowLRowNumbers,K_ramRowChangeOrder,K_ramRowChangeNum]
      else
        FSetModeFlags := [K_ramSkipResizeWidth,K_ramFillFrameWidth,K_ramRowChangeNum];
    FDataCapt := GetUName;
    with FRLSData do begin
      RUDRArray := TK_UDRArray(UDR);
      RPData := R;
      RDType := R.ArrayType;
      FDType := RDType;
    end;
  end;
end; //*** end of K_BuildUDRAEditFuncCont

//*************************************** K_EditUDRAFunc
// Show/Edit UDRArray Without Context
//
function K_EditUDRAFunc( var UDR : TN_UDBase; AOwnerForm : TN_BaseForm = nil;
                AOnGlobalAction : TK_RAFGlobalActionProc = nil;
                ANotModalShow : Boolean = false ) : Boolean;
var
  RFC : TK_RAEditFuncCont;
begin
  Result := false;
  if TK_UDRArray(UDR) is TK_UDRArray then begin
    K_ClearRAEditFuncCont( @RFC );
    K_BuildUDRAEditFuncCont( TK_UDRArray(UDR), @RFC, true );
    with RFC do begin
      FOwner := AOwnerForm;
      FOnGlobalAction := AOnGlobalAction;
      FNotModalShow := ANotModalShow;
    end;
    Result := K_EditRADataFunc( TK_UDRArray(UDR).R, @RFC );
  end;
end; //*** end of K_EditUDRAFunc

//*************************************** K_EditUDRAFunc0
// Show/Edit UDRArray by Registered Function
//
function K_EditUDRAFunc0( var UDR; PDContext: Pointer ) : Boolean;
var
  RFC : TK_RAEditFuncCont;
  BuildModeFlags : Boolean;
begin
  Result := false;
  if TK_UDRArray(UDR) is TK_UDRArray then begin
    BuildModeFlags := false;
    if PDContext = nil then begin
      PDContext := @RFC;
      K_ClearRAEditFuncCont( PDContext );
      BuildModeFlags := true;
    end;
    K_BuildUDRAEditFuncCont( TK_UDRArray(UDR), TK_PRAEditFuncCont(PDContext),
                             BuildModeFlags );
    Result := K_EditRADataFunc( TK_UDRArray(UDR).R, PDContext );
  end;
end; //*** end of K_EditUDRAFunc0

//*************************************** K_EditRADataFunc
// Global Show/Edit Any by Default Registered Function
//
function K_EditRADataFunc( var Data; PDContext : TK_PRAEditFuncCont ) : Boolean;
var
  FormRAEdit : TK_FormRAEdit;
  FMDTypeName : string;
  FMDType : TK_ExprExtType;
  CCaption : string;

begin
  with PDContext^ do begin
    FMDTypeName := K_GetDefaultFDTypeName( FDType.All,
                                           FGEDataID, FGEDataIDPrefix, @FMDType );


    FormRAEdit := nil;
    if FUseOpenedChildForm then
      FormRAEdit :=  TK_FormRAEdit( K_SearchOpenedForm( TK_FormRAEdit, '', K_GetOwnerForm( FRAFrame ) ) );

    if FormRAEdit = nil then
      FormRAEdit := K_GetFormRAEdit( PDContext )
    else
      FormRAEdit.FRRAControl.FreeContext;
    with FormRAEdit do begin
      InitState;
//      FRRAControl.SkipDataBuf := FSkipDataBuf;
      FRRAControl.SkipDataBuf := K_rlsdSkipBuffering in FRLSData.RDFlags;
      CCaption := FDataCapt;
      if FMDType.DTCode <> -1 then begin
        FRRAControl.PrepFrameByFDTypeName( FClearModeFlags, FSetModeFlags, Data, FDType,
                                      '', FMDTypeName, FGrFlagsMask );
        if CCaption = '' then
          CCaption := FRRAControl.CDataCapt;
      end else
        FRRAControl.PrepFrame1( FClearModeFlags, FSetModeFlags, Data, FDType,
                                      '', CCaption, FPCDescr, FSEInds, FFFLags, FFMask );

      InitControls( CCaption );
      FrameRAEdit.RLSData := FRLSData;
      FrameRAEdit.DataPath := FDataPath;
      if FNotModalShow then begin
        Show;
        Result := false;
      end else begin
        ShowModal;
        Result := K_GetFormRAEditResult( FormRAEdit );
      end;
    end;
  end;

end; //*** end of K_EditRADataFunc

//*************************************** K_EditRAListFunc
// Global Show/Edit RAList RArray Registered Function
//
function K_EditRAListFunc( var Data; PDContext : Pointer ) : Boolean;
var
  FormRAEdit : TK_FormRAEdit;
  CCaption : string;
begin
  with TK_PRAEditFuncCont(PDContext)^ do begin
    FormRAEdit := K_GetFormRAEdit( PDContext );
    with FormRAEdit do begin
      InitState;
//      FRRAControl.SkipDataBuf := FSkipDataBuf;
      FRRAControl.SkipDataBuf := K_rlsdSkipBuffering in FRLSData.RDFlags;
      CCaption := FDataCapt;
      FRRAControl.PrepFrameByRAList( FClearModeFlags, FSetModeFlags, TK_RArray(Data), CCaption );
//??##      FRRAControl.PrepFrameByRAList( FModeFlags, TK_RArray(Data), CCaption );

      CCaption := FRRAControl.CDataCapt;
      InitControls( CCaption );

      FrameRAEdit.RLSData := FRLSData;
      FrameRAEdit.DataPath := FDataPath;
      if FNotModalShow then begin
        Show;
        Result := false;
      end else begin
        ShowModal;
        Result := K_GetFormRAEditResult( FormRAEdit );
      end;
    end;
  end;

end; //*** end of K_EditRAListFunc

//*************************************** K_EditUDTreeDataFunc
// Global Show/Edit UDTree Data Registered Function
//
function K_EditUDTreeDataFunc( UDRoot : TN_UDBase; PDContext : TK_PRAEditFuncCont ) : Boolean;
var
  FormRAEdit : TK_FormRAEdit;
begin
  with PDContext^ do begin
    FormRAEdit := K_GetFormRAEdit( PDContext );
    with FormRAEdit do begin
      InitState;
//      FRRAControl.SkipDataBuf := FSkipDataBuf;
//      FRRAControl.SkipDataBuf := K_rlsdSkipBuffering in FRLSData.RDFlags;
      FRRAControl.PrepFrameByUDTreeFormDescr( FClearModeFlags, FSetModeFlags, UDRoot, FDataCapt,
                                  FFormDescr, FGrFlagsMask );
      FrameRAEdit.RLSData := FRLSData;
      FrameRAEdit.DataPath := FDataPath;

      InitControls( FRRAControl.CDataCapt );
      if FNotModalShow then begin
        Show;
        Result := false;
      end else begin
        ShowModal;
        Result := K_GetFormRAEditResult( FormRAEdit );
      end;
    end;
  end;

end; //*** end of K_EditUDTreeDataFunc

//*************************************** K_GetFormRAEdit
// Get Default ShowEdir Form
//
function K_GetFormRAEdit ( PDContext : TK_PRAEditFuncCont ) : TK_FormRAEdit;
var
  AOwner : TN_BaseForm;

begin
  Result := TK_FormRAEdit.Create(Application);
  with Result do begin
    AOwner := nil;
    if PDContext <> nil then
      with PDContext^ do begin
        BFSelfName := FSelfName;
//??        if FNotModalShow then
          AOwner := FOwner;
        if Assigned(FOnGlobalAction) then
          OnGlobalAction := FOnGlobalAction;
        FrameRAEdit.RLSData := FRLSData;
      end;
//    BaseFormInit( AOwner );
    BaseFormInit( AOwner, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
  end;
end; //*** end of K_GetFormRAEdit

//*************************************** K_GetFormRAEditResult
// Get Default ShowEdit Form Edit Result
//
function K_GetFormRAEditResult( FormRAEdit : TK_FormRAEdit ) : Boolean;
begin
  with FormRAEdit do begin
//    if (ModalResult = mrOk) and
//       ResultDataWasChanged then begin
    if ResultDataWasChanged then begin
      Result := true;
    end else begin
      Result := false;
    end;
  end;
end; //*** end of K_GetFormRAEditResult

//*************************************** K_FormRAEditPrepareByFormDescr
// Prepare Default ShowEdit Form By FormDescr
//
function K_FormRAEditPrepareByFormDescr( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                     var Data; ADDType : TK_ExprExtType; const DataName : string;
                     FormDescr : TK_UDRArray; GrFlagsMask : LongWord ) : TK_FormRAEdit;
var
  CCaption : string;
begin
//  Result := K_GetFormRAEdit( nil, nil, @Data);
  Result := K_GetFormRAEdit( nil );
  with Result do begin
    InitState;
    CCaption := DataName;
    if (CCaption = '') and
       (FormDescr <> nil) then
      CCaption := K_GetFormDescrDataCaption( FormDescr );
    FRRAControl.PrepFrameByFormDescr( AClearModeFlags, ASetModeFlags, Data, ADDType,
                                  CCaption, FormDescr );
    InitControls( CCaption );
  end;
end; //*** end of K_FormRAEditPrepareByFormDescr

//*************************************** K_FormRAEditPrepareByFDTypeName
// Prepare Default ShowEdit Form By FormDescr Type Name
//
function K_FormRAEditPrepareByFDTypeName( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                     var Data; DDType : TK_ExprExtType; const DataName : string;
                     FDTypeName : string; GrFlagsMask : LongWord ) : TK_FormRAEdit;
var
  PFormDescr : ^TK_UDRArray;
  FormDescrType : TK_ExprExtType;
begin
  Pointer(PFormDescr) := K_GetGDataPointer( FDTypeName, FormDescrType );
  if (PFormDescr = nil)                      or
     (FormDescrType.DTCode < Ord(nptNoData)) or
     (FormDescrType.FD.FDObjType <> K_fdtClass) then
    Result := nil
  else
    Result := K_FormRAEditPrepareByFormDescr( AClearModeFlags, ASetModeFlags, Data, DDType, DataName, PFormDescr^, GrFlagsMask );
end; //*** end of K_FormRAEditPrepareByFDTypeName

//*************************************** K_RAShowEdit ***
// Show/Edit Data With Default Form
//
function K_RAShowEdit( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet; var Data;
                DDType : TK_ExprExtType; const DataName : string;
                const ADataPath : string = '';
                AOwner : TN_BaseForm = nil;
                GEDataID : string = ''; GEDataIDPrefix : string = '';
                PCDescr: TK_RAPFrDescr = nil; AOnGAction : TK_RAFGlobalActionProc = nil;
                APRLSData : TK_PRLSData = nil;
                GrFlagsMask : LongWord = 0;
                FFLags : Integer = 0; FMask : Integer = K_efcFlagsMask0 ) : Boolean;
var
  RFC : TK_RAEditFuncCont;
begin

  K_ClearRAEditFuncCont( @RFC );
  with RFC do begin
    if APRLSData <> nil then
      FRLSData   := APRLSData^;
    FDataPath  := ADataPath;
    FDType     := DDType;
    FDataCapt  := DataName;
    FSetModeFlags := ASetModeFlags;
    FClearModeFlags := AClearModeFlags;
    FPCDescr   := PCDescr;
    FOnGlobalAction := AOnGAction;
    FOwner := AOwner;
    FGEDataID := GEDataID;
    FGEDataIDPrefix := GEDataIDPrefix;
    FGrFlagsMask := GrFlagsMask;
    FFFlags := FFlags;
    FFMask  := FMask;
  end;
  Result := K_EditRADataFunc( Data, @RFC );
end; //*** end of function K_RAShowEdit

//*************************************** K_RAShowEditByFormDescr
// Show/Edit Data With Default Form By FormDescr
//

function K_RAShowEditByFormDescr( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                     var Data; DDType : TK_ExprExtType; const DataName : string;
                     FormDescr : TK_UDRArray; GrFlagsMask : LongWord = 0 ) : Boolean;
var
  FormRAEdit : TK_FormRAEdit;
begin
//*** Prepare Grid Data
  FormRAEdit := K_FormRAEditPrepareByFormDescr(AClearModeFlags, ASetModeFlags, Data, DDType,
    DataName, FormDescr, GrFlagsMask );
  FormRAEdit.ShowModal;

  Result := K_GetFormRAEditResult( FormRAEdit );
end; //*** end of function K_RAShowEditByFormDescr

//*************************************** K_RAShowEditByFDTypeName
// Show/Edit Data With Default Form By FormDescr Name
//
function K_RAShowEditByFDTypeName( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                     var Data; DDType : TK_ExprExtType; const DataName : string;
                     FDTypeName : string; GrFlagsMask : LongWord = 0 ) : Boolean;
var
  FormRAEdit : TK_FormRAEdit;
begin
  FormRAEdit := K_FormRAEditPrepareByFDTypeName( AClearModeFlags, ASetModeFlags, Data,
                       DDType, DataName, FDTypeName, GrFlagsMask );
  if  FormRAEdit <> nil then begin
    FormRAEdit.ShowModal;
    Result := K_GetFormRAEditResult( FormRAEdit );
  end else
    Result := false;
end; //*** end of function K_RAShowEditByFDTypeName

{*** TK_FormRAEdit ***}
//*************************************** TK_FormRAEdit.InitState
//
procedure TK_FormRAEdit.InitState();
begin
  ClearChangeDataFlag;
  DataSaveModalState := mrNone;
  ResultDataWasChanged := false;
  GActionType := K_fgaNone;
  FrameRAEdit.OnDataApply := ApplyDataAction;
  FrameRAEdit.OnCancelToAll := CancelToAllAction;
  FrameRAEdit.OnOKToAll := OKToAllAction;
end; //*** end of TK_FormRAEdit.InitState

//*************************************** TK_FormRAEdit.InitControls
//
procedure TK_FormRAEdit.InitControls ( DataName : string );
var
  ViewRowActions : Boolean;
  i, j : Integer;
  ViewChangeRowActions : Boolean;
begin
  ViewRowActions := (FRRAControl.BDType.D.TFlags and K_ffArray) <> 0;
  with FrameRAEdit do begin
    ScrollToNextRow.Visible   := ViewRowActions;
    ScrollToPrevRow.Visible   := ViewRowActions;
    ScrollToFirstRow.Visible  := ViewRowActions;
    ScrollToLastRow.Visible   := ViewRowActions;
    SwitchSRecordMode.Visible := ViewRowActions;

    ViewChangeRowActions := (K_ramColChangeNum in ModeFlags);
    DelCol.Visible := ViewChangeRowActions;
    AddCol.Visible := ViewChangeRowActions;
    InsCol.Visible := ViewChangeRowActions;

    ViewChangeRowActions := ViewRowActions and
                      (K_ramRowChangeNum in ModeFlags);


    DelRow.Visible := ViewChangeRowActions;
    AddRow.Visible := ViewChangeRowActions;
    InsRow.Visible := ViewChangeRowActions;

    SetLength( PopupActionGroups, 20 );

    i := 0; j := 0;
    if ViewChangeRowActions then begin
      SetLength( PopupActionGroups[i], 3 );
      PopupActionGroups[i][j] := AddRow;
      j := j + 1;
      PopupActionGroups[i][j] := InsRow;
      j := j + 1;
      PopupActionGroups[i][j] := DelRow;
      i := i + 1; j := 0;
    end;

    SetLength( PopupActionGroups[i], 3 );
    PopupActionGroups[i][j] := CopyToClipBoard;
    j := j + 1;
    PopupActionGroups[i][j] := PasteFromClipBoard;
    j := j + 1;
    PopupActionGroups[i][j] := SetPasteFromClipboardMode;
    i := i + 1; j := 0;

    SetLength( PopupActionGroups[i], 4 );
    PopupActionGroups[i][j] := TranspGrid;
    j := j + 1;
    PopupActionGroups[i][j] := RebuildGrid;
    j := j + 1;
//    PopupActionGroups[i][j] := CallEditor;
//    j := j + 1;
    PopupActionGroups[i][j] := ClearSelected;
    j := j + 1;
    PopupActionGroups[i][j] := SendFVals;
    i := i + 1; j := 0;
{
    SetLength( PopupActionGroups[i], 2 );
    PopupActionGroups[i][j] := Search;
    j := j + 1;
    PopupActionGroups[i][j] := Replace;
    i := i + 1; j := 0;
}
    SetLength( PopupActionGroups[i], 5 );
    PopupActionGroups[i][j] := ScrollToFirstRow;
    j := j + 1;
    PopupActionGroups[i][j] := ScrollToPrevRow;
    j := j + 1;
    PopupActionGroups[i][j] := ScrollToNextRow;
    j := j + 1;
    PopupActionGroups[i][j] := ScrollToLastRow;
    j := j + 1;
    PopupActionGroups[i][j] := SwitchSRecordMode;
    i := i + 1;

    SetLength( PopupActionGroups, i + 1 );
  end;

  if DataName <> '' then
    Caption := DataName;

end; //*** end of TK_FormRAEdit.InitControls

//*************************************** TK_FormRAEdit.FormShow
//
procedure TK_FormRAEdit.FormShow(Sender: TObject);
begin
{
  ClearChangeDataFlag;
  DataSaveModalState := mrNone;
  ResultDataWasChanged := false;
  GActionType := K_fgaNone;
  FrameRAEdit.OnDataApply := ApplyDataAction;
  FrameRAEdit.OnCancelToAll := CancelToAllAction;
  FrameRAEdit.OnOKToAll := OKToAllAction;
}
  FrameRAEdit.RebuildGridExecute(Sender);
end; //*** end of TK_FormRAEdit.FormShow

//*************************************** TK_FormRAEdit.FormCreate
//
procedure TK_FormRAEdit.FormCreate(Sender: TObject);
begin
  FRRAControl := TK_FRAData.Create( FrameRAEdit );
  FRRAControl.SetOnDataChange( AddChangeDataFlag );
  FRRAControl.SetOnClearDataChange( ClearChangeDataFlag );
  DataWasApplied := false;
  SelfGAExecute := false;
end; //*** end of TK_FormRAEdit.FormCreate

//*************************************** TK_FormRAEdit.AddChangeDataFlag
//
procedure TK_FormRAEdit.AddChangeDataFlag;
begin
  DataWasChanged := true;
  Apply.Enabled := true;
  Cancel.Enabled := true;
  BtOK.Caption := 'OK';
  CancelToAll.Enabled := true;
  BtOKToAll.Caption := 'OK to All';
end; //*** end of TK_FormRAEdit.AddChangeDataFlag

//*************************************** TK_FormRAEdit.ClearChangeDataFlag
//
procedure TK_FormRAEdit.ClearChangeDataFlag;
begin
  DataWasChanged := false;
  Apply.Enabled := false;
  Cancel.Enabled := false;
  CancelToAll.Enabled := false;
  if not DataWasApplied then begin
    BtOK.Caption := 'Exit';
    BtOKToAll.Caption := 'Exit to All';
  end;
end; //*** end of TK_FormRAEdit.ClearChangeDataFlag

//*************************************** TK_FormRAEdit.FormClose
//
procedure TK_FormRAEdit.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
end; //*** end of TK_FormRAEdit.FormClose

//*************************************** TK_FormRAEdit.SaveData
//
procedure TK_FormRAEdit.SaveData;
begin
  ResultDataWasChanged := FRRAControl.StoreToSData;
  ClearChangeDataFlag;
end; //*** end of TK_FormRAEdit.SaveData


//*************************************** TK_FormRAEdit.ApplyDataAction
//
procedure TK_FormRAEdit.ApplyDataAction;
begin
  if not DataWasApplied then AddChangeDataFlag;
  DataWasApplied := true;
  SaveData;
  ResultDataWasChanged := not Assigned(OnGlobalAction) or
                          not OnGlobalAction( Self, K_fgaApplyToAll);
//  if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaApplyToAll);
end; //*** end of TK_FormRAEdit.ApplyDataAction

//*************************************** TK_FormRAEdit.CancelToAllAction
//
procedure TK_FormRAEdit.CancelToAllAction;
begin
  GActionType := K_fgaCancelToAll;
  CancelExecute( nil );
end; //*** end of TK_FormRAEdit.CancelToAllAction

//*************************************** TK_FormRAEdit.OKToAllAction
//
procedure TK_FormRAEdit.OKToAllAction;
begin
  if not SelfGAExecute then DataWasChanged := true;
  OKExecute( nil );
  if DataWasChanged then
    GActionType := K_fgaOKToAll
  else
   GActionType := K_fgaCancelToAll;
  ModalResult := mrNo;
end; //*** end of TK_FormRAEdit.OKToAllAction

//*************************************** TK_FormRAEdit.ApplyExecute
//
procedure TK_FormRAEdit.ApplyExecute(Sender: TObject);
begin
  ApplyDataAction;
end; //*** end of TK_FormRAEdit.ApplyExecute

//*************************************** TK_FormRAEdit.SaveDataIfNeeded
//
function TK_FormRAEdit.SaveDataIfNeeded: Word;
var
  res : Word;
begin
  res := DataSaveModalState;
  if  DataWasChanged  then begin
    if DataSaveModalState = mrNone then
      res := MessageDlg( 'Данные были изменены - запомнить?',
           mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if (res = mrYes) then  SaveData;
  end;
  Result := res;

end; //*** end of TK_FormRAEdit.SaveDataIfNeeded

//*************************************** TK_FormRAEdit.FormCloseQuery
//
procedure TK_FormRAEdit.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := (SaveDataIfNeeded <> mrCancel);
  if not CanClose then Exit;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, GActionType );
  FRRAControl.Free;
end; //*** end of TK_FormRAEdit.FormCloseQuery

//*************************************** TK_FormRAEdit.OKExecute
//
procedure TK_FormRAEdit.OKExecute(Sender: TObject);
begin
  DataSaveModalState := mrYes;
  if DataWasChanged then
    GActionType := K_fgaOK;
  CLose;
  ModalResult := mrOK;
end; //*** end of TK_FormRAEdit.OKExecute

//*************************************** TK_FormRAEdit.CancelExecute
//
procedure TK_FormRAEdit.CancelExecute(Sender: TObject);
begin
  DataSaveModalState := mrNo;
  CLose;
  ModalResult := mrCancel;
end; //*** end of TK_FormRAEdit.CancelExecute

//*************************************** TK_FormRAEdit.OKToAllExecute
//
procedure TK_FormRAEdit.OKToAllExecute(Sender: TObject);
begin
  SelfGAExecute := true;
  OKToAllAction;
  SelfGAExecute := false;
end; //*** end of TK_FormRAEdit.OKToAllExecute

//*************************************** TK_FormRAEdit.CancelToAllExecute
//
procedure TK_FormRAEdit.CancelToAllExecute(Sender: TObject);
begin
  SelfGAExecute := true;
  CancelToAllAction;
  SelfGAExecute := false;
end; //*** end of TK_FormRAEdit.CancelToAllExecute

//*************************************** TK_FormRAEdit.ViewAsMatrixExecute
//
procedure TK_FormRAEdit.ViewAsMatrixExecute(Sender: TObject);
begin
  with FRRAControl do
    PrepMatrixFrame1( [],
            [K_ramColVertical,K_ramShowLRowNumbers,
             K_ramRowChangeOrder,K_ramRowChangeNum,K_ramRowAutoChangeNum,
             K_ramShowLColNumbers,K_ramColChangeOrder,K_ramColChangeNum,
             K_ramColAutoChangeNum], TK_PRArray(PSrcData)^, DDType,  CDataCapt, @CDescr );
end; //*** end of TK_FormRAEdit.ViewAsMatrixExecute

{*** end of TK_FormRAEdit ***}

end.

