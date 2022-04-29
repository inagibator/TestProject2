unit K_FUDCDim;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ActnList, ComCtrls, ToolWin, ImgList,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  K_UDT1, K_FrRaEdit, K_Script1, K_CSpace,
  N_BaseF, N_Types, N_Lib1, K_FrUDList, ExtCtrls{, K_FRADD};


type TK_CDimShowFlags = set of (K_cdsNotReadOnly, K_cdsSkipDCSChange);
type
  TK_FormUDCDim = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    Button1: TButton;

    MainMenu: TMainMenu;
    MnSpace: TMenuItem;
    MnEdit: TMenuItem;
    MnView: TMenuItem;
    MnSearch1: TMenuItem;
    N3 : TMenuItem;
    N4 : TMenuItem;
    N5 : TMenuItem;
    N9 : TMenuItem;
    N10: TMenuItem;
    N12: TMenuItem;
    N11: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;

    ActionList  : TActionList;
    ApplyCurCDim: TAction;
    CreateCDim  : TAction;
    CloseAction : TAction;
    RenameCDim  : TAction;

    ToolBar1: TToolBar;
    ToolButton1 : TToolButton;
    ToolButton2 : TToolButton;
    ToolButton4 : TToolButton;
    ToolButton5 : TToolButton;
    ToolButton6 : TToolButton;
    ToolButton7 : TToolButton;
    ToolButton8 : TToolButton;
    ToolButton9 : TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton14: TToolButton;

    StatusBar: TStatusBar;

    LbName: TLabel;
    LbID: TLabel;

    EdID: TEdit;

    FrameUDList: TK_FrameUDList;
    K_FrameRAEdit: TK_FrameRAEdit;

    procedure FormCreate(Sender: TObject);
    procedure InitData;
//    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure OnAddDataRow( ACount : Integer = 1 );
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;

    procedure ApplyCurCDimExecute(Sender: TObject);
    procedure CreateCDimExecute(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure EditAliasesExecute(Sender: TObject);
    procedure CloseActionExecute(Sender: TObject);
    procedure RenameCDimExecute(Sender: TObject);
    procedure K_FrameRAEditAddRowExecute(Sender: TObject);
    procedure K_FrameRAEditInsRowExecute(Sender: TObject);
  private
    { Private declarations }
    CDimShowFlags : TK_CDimShowFlags;
    DataSaveModalState : word;
    IniCaption : string;
    WData : TK_RArray;
  //  WPCodes, PCodes, PNames : PString;
    DDType : TK_ExprExtType;
    FormDescr : TK_UDRArray;
    RAFCArray : TK_RAFCArray;
    FrDescr : TK_RAFrDescr;
    AModeFlags : TK_RAModeFlagSet;
    GActionType : TK_RAFGlobalAction;
    procedure InitNewRow( NInd : Integer );
  public
    { Public declarations }
    OnGlobalAction : TK_RAFGlobalActionProc;
    DataWasChanged : Boolean;
    ResultDataWasChanged : Boolean;
    CDimsRoot : TN_UDBase;
    SelectObjsUDRoot : TN_UDBase;
    CurUDCDim : TK_UDCDim;

    procedure ShowCDim( UDCDim: TN_UDBase );
    function  SaveDataToCurCDim : Boolean;
    procedure AddChangeDataFlag;
    procedure ClearChangeDataFlag;
    function  SaveDataIfNeeded : Word;
  end;


function  K_GetFormUDCDim( AOwner: TN_BaseForm ) : TK_FormUDCDim;
function  K_EditUDCDim( UDCDim : TK_UDCDim; AOwner: TN_BaseForm = nil;
            AOnGlobalAction : TK_RAFGlobalActionProc = nil;
            ANotModalShow : Boolean = false ) : Boolean;

procedure K_ShowUDCDim( UDCDim : TK_UDCDim = nil;
            SelIndex : Integer = 0; SelLength : Integer = 0;
            ACDimShowFlags : TK_CDimShowFlags = [];
            AOwner: TN_BaseForm = nil );

procedure K_GetUDCDimSelection( out UDCDim : TN_UDBase;
            out SelIndex, SelLength : Integer );

var
  K_FormUDCDim: TK_FormUDCDim;

var K_CDimEditCont : TK_RAEditFuncCont;
function K_EditUDCDimFunc( var UDCDim; PDContext: Pointer ) : Boolean;

implementation
{$R *.dfm}

uses
  inifiles,
  K_RAEdit, K_CLib, K_CLib0, {K_FUDCSDBlock,}
  K_UDT2, K_Arch, K_VFunc, K_FUDVTab, K_FUDRename,
  N_ME1, N_ClassRef, N_ButtonsF;



//***********************************  K_EditUDCDimFunc
//
function K_EditUDCDimFunc( var UDCDim; PDContext: Pointer ) : Boolean;
begin
  with TK_PRAEditFuncCont(PDContext)^ do
    Result := K_EditUDCDim( TK_UDCDim(UDCDim), FOwner, FOnGlobalAction, FNotModalShow );
end; // end of function K_EditUDCDimFunc

//***********************************  K_GetFormUDCDim
//
function K_GetFormUDCDim( AOwner: TN_BaseForm ) : TK_FormUDCDim;
begin
  if K_FormUDCDim = nil then begin
    K_FormUDCDim := TK_FormUDCDim.Create(Application);
    K_FormUDCDim.BaseFormInit( AOwner );
  end;
  Result := K_FormUDCDim;
end; // end of function K_GetFormUDCDim

//***********************************  K_EditUDCDim
//
function K_EditUDCDim( UDCDim : TK_UDCDim; AOwner: TN_BaseForm = nil;
            AOnGlobalAction : TK_RAFGlobalActionProc = nil;
            ANotModalShow : Boolean = false ) : Boolean;
begin
  with K_GetFormUDCDim( AOwner ) do begin
    CurUDCDim := UDCDim;
    OnGlobalAction := AOnGlobalAction;
    InitData;
    if ANotModalShow then
      Show
    else
      ShowModal;
    Result := ResultDataWasChanged;
  end;
end; // end of function K_EditUDCDim

//***********************************  K_ShowUDCDim
//
procedure  K_ShowUDCDim( UDCDim : TK_UDCDim = nil;
            SelIndex : Integer = 0; SelLength : Integer = 0;
            ACDimShowFlags : TK_CDimShowFlags = [];
            AOwner: TN_BaseForm = nil );
var
  SameCS, IsShown : Boolean;
begin
  IsShown := K_FormUDCDim <> nil;
  with K_GetFormUDCDim( AOwner ) do begin
    SameCS := ((CurUDCDim = UDCDim) and (UDCDim <> nil)) or
              ((UDCDim = nil) and (CurUDCDim <> nil));
    if not SameCS then
      CurUDCDim := UDCDim;
    CDimShowFlags := ACDimShowFlags;
    if CurUDCDim = nil then
      Exclude( CDimShowFlags, K_cdsSkipDCSChange );
    if not IsShown or not SameCS then begin
      InitData;
      if SelLength <> 0 then
        K_FrameRAEdit.SelectLRect(-1,SelIndex,-1,SelIndex + SelLength -1 );
    end;
    if IsShown then
      SetFocus
    else
      Show;
  end;
end; // end of procedure K_ShowUDCDim

//***********************************  K_GetUDCDimSelection
//
procedure  K_GetUDCDimSelection( out UDCDim : TN_UDBase;
            out SelIndex, SelLength : Integer );
begin
  UDCDim := nil;
  SelIndex := 0;
  SelLength := 0;
  if K_FormUDCDim = nil then Exit;
  with K_FormUDCDim.K_FrameRAEdit do begin
    UDCDim := K_FormUDCDim.CurUDCDim;
    GetSelectSection( true, SelIndex, SelLength );
    SelIndex := ToLogicRow( SelIndex );
  end;
end; // end of procedure K_GetUDCDimSelection

{*** TK_FormUDCDim ***}

//***********************************  TK_FormUDCDim.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormUDCDim.CurStateToMemIni();
begin
  inherited;
  N_StringsToMemIni ( Name+'CDims', FrameUDList.PathList );
end; // end of procedure TK_FormUDCDim.CurStateToMemIni

//***********************************  TK_FormUDCDim.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormUDCDim.MemIniToCurState();
begin
  inherited;
  N_MemIniToStrings( Name+'CDims', FrameUDList.PathList );
end; // end of procedure TK_FormUDCDim.MemIniToCurState

//***********************************  TK_FormUDCDim.InitData
//
procedure TK_FormUDCDim.InitData;
begin
//  K_FrameRAEdit.RebuildGridExecute(Sender);
  ResultDataWasChanged := false;
  DataSaveModalState := mrNone;
  GActionType := K_fgaNone;
  if CDimsRoot = nil then CDimsRoot := K_CurCDimsRoot;

  if not (K_cdsNotReadOnly in CDimShowFlags) then
    Include( K_FrameRAEdit.CDescr.ModeFlags, K_ramReadOnly );
  K_FrameRAEdit.SetGridLRowsNumber(  0 );
  K_FrameRAEdit.SGrid.Invalidate;

  K_FrameRAEdit.InsRow.Enabled := false;
  K_FrameRAEdit.Search.Enabled := false;
  K_FrameRAEdit.AddRow.Enabled := false;
  K_FrameRAEdit.DelRow.Enabled := false;
  K_FrameRAEdit.CopyToClipBoard.Enabled := false;
  K_FrameRAEdit.PasteFromClipBoard.Enabled := false;
  K_FrameRAEdit.TranspGrid.Enabled := false;
  K_FrameRAEdit.RebuildGrid.Enabled := false;
  RenameCDim.Enabled := false;

  if CurUDCDim = nil then
    FrameUDList.InitByPathIndex
  else
    FrameUDList.AddUDObjToTop( CurUDCDim );
end; // end of procedure TK_FormUDCDim.InitData

//***********************************  TK_FormUDCDim.ShowCDim
//
procedure TK_FormUDCDim.ShowCDim( UDCDim: TN_UDBase );
var
  i, h : Integer;
  PCodes : PString;
  PNames : PString;
  PKeys : PString;
  EnabledState : Boolean;
  CDimRAAttrs : TK_CDimRAAttrs;
begin
  if SaveDataIfNeeded = mrCancel then Exit;
  CurUDCDim := TK_UDCDim(UDCDim);
  Caption := UDCDim.GetUName + ' - ' + IniCaption;
  EdID.Text := CurUDCDim.ObjName;
  CDimsRoot := FrameUDList.UDParent;
  if CDimsRoot = nil then CDimsRoot := CurUDCDim.Owner;

  with CurUDCDim do begin
//*** prepare editing
    h :=  CDimCount;
//    PCodes := GetItemInfoPtr( K_cdiCode, 0 );
    GetCDimRAAttrsInfo( CDimRAAttrs, nil, Ord(K_cdiCode) );
    PCodes := CDimRAAttrs.PAData;
//    PNames := GetItemInfoPtr( K_cdiName, 0 );
    GetCDimRAAttrsInfo( CDimRAAttrs, nil, Ord(K_cdiName) );
    PNames := CDimRAAttrs.PAData;
//    PKeys  := GetItemInfoPtr( K_cdiEntryKey, 0 );
    GetCDimRAAttrsInfo( CDimRAAttrs, nil, Ord(K_cdiEntryKey) );
    PKeys := CDimRAAttrs.PAData;

    WData.ASetLength( h );
    for i := 0 to h-1 do begin
      with TK_PCDimEdit( WData.P(i) )^ do begin
        PrevIndex := i;
        Code := PCodes^;  // Space Code
        Name := PNames^;  // Space Code Name
        Key  := PKeys^;  // Space Code Name Key
        Inc( TN_BytesPtr(PCodes), SizeOf(string) );
        Inc( TN_BytesPtr(PNames), SizeOf(string) );
        Inc( TN_BytesPtr(PKeys), SizeOf(string) );
      end;
    end;
    K_FrameRAEdit.SetGridLRowsNumber(  h );
    K_FrameRAEdit.SetDataPointersFromRArray( WData, DDType, 0 );
  end;
  K_FrameRAEdit.SGrid.Invalidate;

  EnabledState := (K_cdsNotReadOnly in CDimShowFlags);
  RenameCDim.Enabled := EnabledState;
  CreateCDim.Enabled := EnabledState;
  K_FrameRAEdit.Search.Enabled := true;
  K_FrameRAEdit.InsRow.Enabled := EnabledState;
  K_FrameRAEdit.Search.Enabled := EnabledState;
  K_FrameRAEdit.AddRow.Enabled := EnabledState;
  K_FrameRAEdit.DelRow.Enabled := EnabledState;
  K_FrameRAEdit.CopyToClipBoard.Enabled := EnabledState;
  K_FrameRAEdit.PasteFromClipBoard.Enabled := EnabledState;
  K_FrameRAEdit.TranspGrid.Enabled := true;
  K_FrameRAEdit.RebuildGrid.Enabled := true;

  ClearChangeDataFlag;
end; // end of procedure TK_FormUDCDim.ShowCDim

//***********************************  TK_FormUDCDim.FormCreate
//
procedure TK_FormUDCDim.FormCreate(Sender: TObject);
begin
  inherited;
  ClearChangeDataFlag;
  IniCaption := Caption;
  CDimShowFlags := [K_cdsNotReadOnly];
  FormDescr := K_CreateSPLClassByName( 'TK_FormCDim', [] );
  DDType := K_GetTypeCodeSafe('TK_CDimEdit');
  Inc( DDType.D.TFlags, K_ffArray );
  AModeFlags := [K_ramColVertical, K_ramRowChangeNum,
                 K_ramRowAutoChangeNum, K_ramRowChangeOrder, K_ramOnlyEnlargeSize];
  K_RAFColsPrepByRADataFormDescr(
      RAFCArray, @FrDescr, AModeFlags, DDType, FormDescr );

  WData := K_RCreateByTypeName( 'TK_CDimEdit', 0 );
  K_FrameRAEdit.SetGridInfo( AModeFlags, RAFCArray, FrDescr, 0, nil,
                                                  nil, nil );
  K_FrameRAEdit.OnDataChange := AddChangeDataFlag;
  K_FrameRAEdit.OnRowsAdd := OnAddDataRow;
  CurUDCDim := nil;
  FrameUDList.SFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCDimCI ) );
  FrameUDList.SelCaption := 'Выбор объекта';
  FrameUDList.SelButtonHint := 'Выбор объекта';
  FrameUDList.SelShowToolBar := true;
  FrameUDList.FRUDListRoot := K_CurArchive;
  FrameUDList.UDObj := nil;
  FrameUDList.OnUDObjSelect := ShowCDim;
  SelectObjsUDRoot := K_CurArchive;
end; // end of procedure TK_FormUDCDim.FormCreate

//***********************************  TK_FormUDCDim.SaveDataIfNeeded
//
function TK_FormUDCDim.SaveDataIfNeeded : Word;
var res : Word;
begin
  res := DataSaveModalState;
  if  DataWasChanged  then begin
    if DataSaveModalState = mrNone then
      res := MessageDlg( 'Данные были изменены - запомнить?',
           mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if (res = mrYes) then begin
      if not SaveDataToCurCDim then res := mrCancel;
    end else begin
{
      if (res = mrNo) and
         (CurUDIndex = -1) then
        with CDimsRoot do
          DeleteDirEntry( DirHigh );
}
    end;
  end;
  Result := res;
end; // end of procedure TK_FormUDCDim.SaveDataIfNeeded

//***********************************  TK_FormUDCDim.FormCloseQuery
//
procedure TK_FormUDCDim.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := (SaveDataIfNeeded <> mrCancel);
  if not CanClose then Exit;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, GActionType );
  CurUDCDim := nil;
end; // end of procedure TK_FormUDCDim.FormCloseQuery

//***********************************  TK_FormUDCDim.ApplyCurCDimExecute
//
procedure TK_FormUDCDim.ApplyCurCDimExecute(Sender: TObject);
begin
  if not DataWasChanged then Exit;
  if SaveDataToCurCDim() then begin
    if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaApplyToAll );
    GActionType := K_fgaNone;
    ShowCDim( CurUDCDim );
  end;
end; // end of procedure TK_FormUDCDim.ApplyCurCDimExecute

//***********************************  TK_FormUDCDim.SaveDataToCurCDim
//
function TK_FormUDCDim.SaveDataToCurCDim : Boolean;
var
  nd, j, k, i, h : Integer;
  PCodes, PNames, PKeys : PString;
  WDType : TK_ExprExtType;
//  WDCSSpace : TK_UDDCSSpace;
//  UDPI : TK_UDProgramItem;
  ErrText : string;
  GC : TK_CSPLCont;
  PrevIndex, FrameDataIndex : TN_IArray;
  WCodes : TN_SArray;
  RebuildData : Boolean;
  CDimRAAttrs : TK_CDimRAAttrs;

label Error;

begin

  with  K_FrameRAEdit do begin
    SetLength( FrameDataIndex, GetDataBufRow );
    k := High(FrameDataIndex);
    if k = -1 then begin
      ErrText := 'Создание пустого измерения недопустимо';
      goto Error;
    end;

    for i := 0 to k do
      FrameDataIndex[i] := GetDataBufRow(i);
  end;

//*** Check if Codes are correct
  StatusBar.SimpleText := '';
  for i := 0 to k - 1 do begin
    PCodes := @(TK_PCDimEdit( WData.P(FrameDataIndex[i]) ).Code);
    for j := i + 1 to k do begin
      if PCodes^ = TK_PCDimEdit( WData.P(FrameDataIndex[j]) ).Code then begin
      //*** not correct codes Edit again
// 1
//            UDPI := TK_UDProgramItem( K_CursorGetObj( '@:\SPL\DCSpace\ShowErrorMessage' ) );
//            assert( UDPI <> nil, 'Program Item "DCSpace\ShowErrorMessage" not found' );
//            UDPI.CallSPLRoutine( [PCodes^, i, j]);

//2
//            FormDescr.CallSPLClassMethod( 'ShowErrorMessage', [PCodes^, i, j]);

//3
        GC := K_PrepSPLRunGCont;
        FormDescr.CallSPLClassMethod( 'GetErrorMessage', [PCodes^, i, j], GC );
        GC.GetDataFromExprStack( ErrText, WDType.All );
        K_FreeSPLRunGCont( GC );
Error:
        K_ShowMessage( ErrText );
        StatusBar.SimpleText := ErrText;
        beep;
        Result := false;
        Exit;
      end;
    end;
  end;

  with CurUDCDim do begin

//*** Check if added Codes have Old Code Values and calculate their previous indexes
    nd := k + 1;
    SetLength( PrevIndex, nd );
//    PCodes := GetItemInfoPtr( K_cdiCode, 0 );
    GetCDimRAAttrsInfo( CDimRAAttrs, nil, Ord(K_cdiCode) );
    PCodes := CDimRAAttrs.PAData;
    h := CDimCount - 1;
//*** get previous indexes values
    if k >= 0 then begin
      K_MoveVectorBySIndex( PrevIndex[0], SizeOf(Integer), WData.P^,
                 SizeOf( TK_CDimEdit ), SizeOf(Integer),
                 nd, @FrameDataIndex[0] );
//*** Get Codes From Buf Data
      SetLength( WCodes, nd );

      K_MoveSPLVectorBySIndex( WCodes[0], SizeOf(string),
                        TK_PCDimEdit(WData.P).Code, SizeOf( TK_CDimEdit ),
                        nd, Ord(nptString), [], @FrameDataIndex[0] );
//*** check if new codes have same values as some deleted ones
      for i := 0 to k do
        WCodes[i] := Trim(WCodes[i]);
      for i := 0 to h do begin
        for j := 0 to k do begin
          if PCodes^ = WCodes[j] then
            PrevIndex[j] := i;
        end;
        Inc( TN_BytesPtr(PCodes), SizeOf(string) );
      end;

      i := K_BuildActIndicesAndCompress( nil, nil, nil,
                                                K_GetPIArray0(PrevIndex), nd );
      RebuildData := false;
      if i < h + 1 then
        RebuildData := mrYes = MessageDlg(
            'Исключать ли данные, соответствующие удаленным элементам измерения?',
            mtConfirmation, [mbYes, mbNo], 0 );

      CurUDCDim.ConvAllCSDims( @PrevIndex[0], nd, RebuildData );
    end;

//*** Change Code Space
    SetCDimCount( nd );
//    PCodes := GetItemInfoPtr( K_cdiCode, 0 );
    GetCDimRAAttrsInfo( CDimRAAttrs, nil, Ord(K_cdiCode) );
    PCodes := CDimRAAttrs.PAData;
//    PNames := GetItemInfoPtr( K_cdiName, 0 );
    GetCDimRAAttrsInfo( CDimRAAttrs, nil, Ord(K_cdiName) );
    PNames := CDimRAAttrs.PAData;
//    PKeys := GetItemInfoPtr( K_cdiEntryKey, 0 );
    GetCDimRAAttrsInfo( CDimRAAttrs, nil, Ord(K_cdiEntryKey) );
    PKeys := CDimRAAttrs.PAData;
    Dec( nd );
    for i := 0 to nd do begin
      with TK_PCDimEdit( WData.P(FrameDataIndex[i]) )^ do begin
//        PCodes^ := Trim(Code);  // Space Code
        PCodes^ := WCodes[i];  // Space Code
        PNames^ := Trim(Name); // Space Code Name
        PKeys^  := Trim(Key);  // Space Code Key
        Inc( TN_BytesPtr(PCodes), SizeOf(string) );
        Inc( TN_BytesPtr(PNames), SizeOf(string) );
        Inc( TN_BytesPtr(PKeys),  SizeOf(string) );
      end;
    end;
  end;

  PrevIndex := nil;
  WCodes := nil;
  FrameDataIndex := nil;
  Result := true;
  ResultDataWasChanged := true;
  ClearChangeDataFlag;
//  if Assigned(OnGlobalAction) then OnGlobalAction( K_fgaOK );
  GActionType := K_fgaOK;
end; // end of procedure TK_FormUDCDim.SaveDataToCurCDim

//***********************************  TK_FormUDCDim.CreateCDimExecute
//
procedure TK_FormUDCDim.CreateCDimExecute(Sender: TObject);
var
  NName, NAliase : string;
  UDCDRoot : TN_UDBase;
begin
  UDCDRoot := CDimsRoot;
  if not K_SelectUDNode( UDCDRoot, SelectObjsUDRoot, nil,
                            'Выбор каталога для сохранения объекта', false  ) then Exit;
//  Application.ProcessMessages; //?? is it realy needed 2010-04-14
  NAliase := UDCDRoot.BuildUniqChildName( K_FCDimNewAliase, nil, K_ontObjAliase );
  NName := UDCDRoot.BuildUniqChildName( K_FCDimNewName );
  if not K_EditNameAndAliase(  NAliase, NName ) then Exit;
  if SaveDataIfNeeded <> mrCancel then begin
    CDimsRoot := UDCDRoot;
    FrameUDList.AddUDObjToTop( TK_UDCDim.CreateAndInit( NName, NAliase, CDimsRoot ) );
    CDimsRoot.RebuildVNodes;
    AddChangeDataFlag;
  end;
end; // end of procedure TK_FormUDCDim.CreateCDimExecute

//***********************************  TK_FormUDCDim.AddChangeDataFlag
//
procedure TK_FormUDCDim.AddChangeDataFlag;
begin
  DataWasChanged := true;
  BtOK.Caption := 'OK';
  BtCancel.Enabled := true;
  ApplyCurCDim.Enabled := true;
end; // end of procedure TK_FormUDCDim.AddChangeDataFlag

//***********************************  TK_FormUDCDim.ClearChangeDataFlag
//
procedure TK_FormUDCDim.ClearChangeDataFlag;
begin
  DataSaveModalState := mrNone;
  DataWasChanged := false;
  BtOK.Caption := 'Выход';
  BtCancel.Enabled := false;
  ApplyCurCDim.Enabled := false;
end; // end of procedure TK_FormUDCDim.ClearChangeDataFlag

//***********************************  TK_FormUDCDim.BtCancelClick
//
procedure TK_FormUDCDim.BtCancelClick(Sender: TObject);
begin
  DataSaveModalState := mrNo;
  if not (fsModal in FormState)	then Close;
  ModalResult := mrCancel;
  GActionType := K_fgaNone;
end; // end of procedure TK_FormUDCDim.BtCancelClick

//***********************************  TK_FormUDCDim.BtOKClick
//
procedure TK_FormUDCDim.BtOKClick(Sender: TObject);
begin
  DataSaveModalState := mrYes;
  if not (fsModal in FormState)	then Close;
  ModalResult := mrOK;
end; // end of procedure TK_FormUDCDim.BtOKClick

//***********************************  TK_FormUDCDim.FormClose
//
procedure TK_FormUDCDim.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
  K_FrameRAEdit.FreeContext;
  FormDescr.Free;
  K_FreeColumnsDescr( RAFCArray );
  K_FormUDCDim := nil;
end; // end of procedure TK_FormUDCDim.FormClose

//***********************************  TK_FormUDCDim.OnAddDataRow
//
procedure TK_FormUDCDim.OnAddDataRow( ACount : Integer = 1 );
var
  i, InsInd : Integer;
begin
  with WData do begin
    InsInd := ALength;
    ASetLength( InsInd + ACount );
    K_FrameRAEdit.SetDataPointersFromRArray( P^, ElemType, 0 );
    for i := InsInd to InsInd + ACount -1 do PInteger(P(i))^ := -1;
  end;
end; // end of procedure TK_FormUDCDim.OnAddDataRow

//***********************************  TK_FormUDCDim.EditAliasesExecute
//
procedure TK_FormUDCDim.EditAliasesExecute(Sender: TObject);
var
  SaveResult : word;
begin
  SaveResult := SaveDataIfNeeded;
  if (SaveResult <> mrYes) and
     (SaveResult <> mrNone) then Exit;
//  K_EditUDCSDBlock( CurUDCDim.GetCDimAliases, Self, OnGlobalAction );
//  K_EditUDVectorsTab( CurUDCDim.GetCDAUDRoot, '', [K_ramColVertical], 'nn',
//    'TK_DSSVector', K_UDVectorCI, Self, OnGlobalAction );
end; // end of procedure TK_FormUDCDim.EditAliasesExecute

//***********************************  TK_FormUDCDim.CloseActionExecute
//
procedure TK_FormUDCDim.CloseActionExecute(Sender: TObject);
begin
  if not (fsModal in FormState)	then Close;
  ModalResult := mrOK;
end; // end of procedure TK_FormUDCDim.CloseActionExecute

//***********************************  TK_FormUDCDim.RenameCDimExecute
//
procedure TK_FormUDCDim.RenameCDimExecute(Sender: TObject);
var
  FullDCSS : TN_UDBase;

begin
  FullDCSS := CurUDCDim.DirChildByObjName( CurUDCDim.ObjName );
  if K_EditUDNameAndAliase(  CurUDCDim ) then begin
    CDimsRoot.SetUniqChildName( CurUDCDim );
    CDimsRoot.SetUniqChildName( CurUDCDim, K_ontObjAliase );
    if FullDCSS <> nil then begin
      FullDCSS.ObjName := CurUDCDim.ObjName;
      FullDCSS.ObjAliase := CurUDCDim.ObjAliase;
    end;
    EdID.Text := CurUDCDim.ObjName;
    FrameUDList.RebuildTopUDObjName;
    CurUDCDim.RebuildVNodes(1);
    if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaOK );
  end;
end; // end of procedure TK_FormUDCDim.RenameCDimExecute

//***********************************  TK_FormUDCDim.InitNewRow
//
procedure TK_FormUDCDim.InitNewRow( NInd : Integer );
var
  i, RowHigh, Num, CInd : Integer;
  KeyPref, NewKey : string;
  PPat : TK_PCDimEdit;
  NameOK : Boolean;
begin
  with  K_FrameRAEdit do begin
//*** Search for Pattern Ind
    RowHigh := GetDataBufRow - 1;
    for i := RowHigh downto 0 do begin
      PPat := TK_PCDimEdit(WData.P(GetDataBufRow(i)));
      KeyPref := PPat.Code;
      if PPat.Code <> '' then Break;
    end;

//*** Parse Key Prefix
    CInd := Length(KeyPref) + 1;
    for i := Length(KeyPref) downto 1 do begin
      if (KeyPref[i] >= '0') and (KeyPref[i] <= '9') then
        CInd := i
      else
        break;
    end;

    Num := StrToIntDef( Copy( KeyPref, CInd, Length(KeyPref) ), 0 );
    if Num < RowHigh then Num := RowHigh;
    Inc(Num);
    KeyPref := Copy( KeyPref, 1, CInd - 1 );
    NewKey := KeyPref + IntToStr( Num);
    repeat
      NameOK := true;
      for i := RowHigh downto 0 do begin
        PPat := TK_PCDimEdit(WData.P(GetDataBufRow(i)));
        if PPat.Code = NewKey then begin
          Inc(Num);
          NewKey := KeyPref + IntToStr( Num);
          NameOK := false;
          break;
        end
      end;
     until NameOK;
    with TK_PCDimEdit(WData.P(NInd))^ do begin
      Code := NewKey;
      Name := NewKey;
    end;

  end;

end; // end of procedure TK_FormUDCDim.K_FrameRAEditAddRowExecute

//***********************************  TK_FormUDCDim.K_FrameRAEditAddRowExecute
//
procedure TK_FormUDCDim.K_FrameRAEditAddRowExecute(Sender: TObject);
begin
  K_FrameRAEdit.AddRowExecute(Sender);
  InitNewRow( WData.AHigh );
  K_FrameRAEdit.SGrid.Invalidate;
end; // end of procedure TK_FormUDCDim.K_FrameRAEditAddRowExecute

//***********************************  TK_FormUDCDim.K_FrameRAEditInsRowExecute
//
procedure TK_FormUDCDim.K_FrameRAEditInsRowExecute(Sender: TObject);
begin
  K_FrameRAEdit.InsRowExecute(Sender);
  InitNewRow( WData.AHigh );
  K_FrameRAEdit.SGrid.Invalidate;
end; // end of procedure TK_FormUDCDim.K_FrameRAEditInsRowExecute

{*** end of TK_FormUDCDim ***}

end.

