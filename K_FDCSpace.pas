unit K_FDCSpace;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ActnList, ComCtrls, ToolWin, ImgList,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  K_UDT1, K_FrRaEdit, K_Script1, K_DCSpace,
  N_BaseF, N_Types, N_Lib1, ExtCtrls{, K_FRADD};


type TK_DCSShowFlags = set of (K_cssNotReadOnly, K_cssSkipDCSChange);
type
  TK_FormDCSpace = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    Button1: TButton;

    MainMenu: TMainMenu;
    MnSpace: TMenuItem;
    MnEdit: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N12: TMenuItem;
    N11: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    MnView: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    Search1: TMenuItem;
    N1: TMenuItem;

    ActionList: TActionList;
    SaveCurDCSpace: TAction;
    OpenDCSPace   : TAction;
    CreateDCSpace : TAction;
    ImportDCSpace : TAction;
    ExportDCSpace : TAction;
    EditAliases   : TAction;
    Close         : TAction;

    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
//    ToolButton15: TToolButton;

    CmBSList: TComboBox;
    LbName: TLabel;

    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    K_FrameRAEdit: TK_FrameRAEdit;
    AddRow: TAction;
    LbID: TLabel;
    EdID: TEdit;
    RenameDCSpace: TAction;
    N2: TMenuItem;
    StatusBar: TStatusBar;
    ToolButton15: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure InitData;
//    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure OnAddDataRow( ACount : Integer = 1 );
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;

    procedure SaveCurDCSpaceExecute(Sender: TObject);
    procedure CreateDCSpaceExecute(Sender: TObject);
    procedure CmBSListSelect(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure OpenDCSPaceExecute(Sender: TObject);
    procedure CmBSListDropDown(Sender: TObject);
    procedure CmBSListChange(Sender: TObject);
    procedure ImportDCSpaceExecute(Sender: TObject);
    procedure ExportDCSpaceExecute(Sender: TObject);
    procedure EditAliasesExecute(Sender: TObject);
    procedure CloseExecute(Sender: TObject);
    procedure AddRowExecute(Sender: TObject);
    procedure RenameDCSpaceExecute(Sender: TObject);
  private
    { Private declarations }
    DCSShowFlags : TK_DCSShowFlags;
    DataSaveModalState : word;
    IniCaption : string;
    CurUDCSpace : TK_UDDCSpace;
    CurUDIndex : Integer;
    CurUDName : string;
    WData : TK_RArray;
  //  WPCodes, PCodes, PNames : PString;
    DDType : TK_ExprExtType;
    FormDescr : TK_UDRArray;
    RAFCArray : TK_RAFCArray;
    FrDescr : TK_RAFrDescr;
    AModeFlags : TK_RAModeFlagSet;
  public
    { Public declarations }
    OnGlobalAction : TK_RAFGlobalActionProc;
    DataWasChanged : Boolean;
    ResultDataWasChanged : Boolean;
    procedure ShowDCSpace( UDCSpace : TK_UDDCSpace );
    function  SaveDataToCurDCSpace : Boolean;
    procedure AddChangeDataFlag;
    procedure ClearChangeDataFlag;
    function  SaveDataIfNeeded : Word;
  end;


function  K_GetFormDCSpace( AOwner: TN_BaseForm ) : TK_FormDCSpace;
function  K_EditDCSpace( UDCSpace : TK_UDDCSpace; AOwner: TN_BaseForm = nil;
            AOnGlobalAction : TK_RAFGlobalActionProc = nil;
            ModalShow : Boolean = true ) : Boolean;

procedure  K_ShowDCSpace( UDCSpace : TK_UDDCSpace = nil;
            SelIndex : Integer = 0; SelLength : Integer = 0;
            ADCSShowFlags : TK_DCSShowFlags = [];
            AOwner: TN_BaseForm = nil );

procedure  K_GetDCSpaceSelection( out UDCSpace : TN_UDBase;
            out SelIndex, SelLength : Integer );

var
  K_FormDCSpace: TK_FormDCSpace;

var K_DCSpaceEditCont : TK_RAEditFuncCont;
function K_EditDCSpaceFunc( var UDCSpace; PDContext: Pointer ) : Boolean;

implementation
{$R *.dfm}

uses
  inifiles,
  K_RAEdit, K_CLib, K_CLib0,
  K_Arch, K_VFunc, K_FUDVTab, K_FUDRename,
  N_ME1, N_ClassRef, N_ButtonsF;





function K_EditDCSpaceFunc( var UDCSpace; PDContext: Pointer ) : Boolean;
begin
  Result := K_EditDCSpace( TK_UDDCSpace(UDCSpace),
     TK_PRAEditFuncCont(PDContext).FOwner,
     TK_PRAEditFuncCont(PDContext).FOnGlobalAction  );
end;

function K_GetFormDCSpace( AOwner: TN_BaseForm ) : TK_FormDCSpace;
begin
  if K_FormDCSpace = nil then begin
    K_FormDCSpace := TK_FormDCSpace.Create(Application);
    K_FormDCSpace.BaseFormInit( AOwner );
  end;
  Result := K_FormDCSpace;
end;

function K_EditDCSpace( UDCSpace : TK_UDDCSpace; AOwner: TN_BaseForm = nil;
            AOnGlobalAction : TK_RAFGlobalActionProc = nil;
            ModalShow : Boolean = true ) : Boolean;
begin
  with K_GetFormDCSpace( AOwner ) do begin
    CurUDCSpace := UDCSpace;
    OnGlobalAction := AOnGlobalAction;
    InitData;
    if ModalShow then begin
      ShowModal;
      Result := ResultDataWasChanged;
    end else begin
      Show;
      Result := false;
    end;
  end;
end;

procedure  K_ShowDCSpace( UDCSpace : TK_UDDCSpace = nil;
            SelIndex : Integer = 0; SelLength : Integer = 0;
            ADCSShowFlags : TK_DCSShowFlags = [];
            AOwner: TN_BaseForm = nil );
var
  SameCS, IsShown : Boolean;
begin
  IsShown := K_FormDCSpace <> nil;
  with K_GetFormDCSpace( AOwner ) do begin
    SameCS := ((CurUDCSpace = UDCSpace) and (UDCSpace <> nil)) or
              ((UDCSpace = nil) and (CurUDCSpace <> nil));
    if not SameCS then
      CurUDCSpace := UDCSpace;
    DCSShowFlags := ADCSShowFlags;
    if CurUDCSpace = nil then
      Exclude( DCSShowFlags, K_cssSkipDCSChange );
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
end;

procedure  K_GetDCSpaceSelection( out UDCSpace : TN_UDBase;
            out SelIndex, SelLength : Integer );
begin
  UDCSpace := nil;
  SelIndex := 0;
  SelLength := 0;
  if K_FormDCSpace = nil then Exit;
  with K_FormDCSpace.K_FrameRAEdit do begin
    UDCSpace := K_FormDCSpace.CurUDCSpace;
    GetSelectSection( true, SelIndex, SelLength );
    SelIndex := ToLogicRow( SelIndex );
  end;
end;

{*** TK_FormDCSpace ***}

procedure TK_FormDCSpace.InitData;
begin
//  K_FrameRAEdit.RebuildGridExecute(Sender);
  ResultDataWasChanged := false;
  DataSaveModalState := mrNone;
  K_CurSpacesRoot.BuildChildsList(CmBSlist.Items, K_ontObjUName);
  CurUDIndex := -1;
  CmBSlist.ItemIndex := -1;
  CmBSlist.Text := '';

  if not (K_cssNotReadOnly in DCSShowFlags) then
    Include( K_FrameRAEdit.CDescr.ModeFlags, K_ramReadOnly );
  K_FrameRAEdit.SetGridLRowsNumber(  0 );
  K_FrameRAEdit.SGrid.Invalidate;

  AddRow.Enabled := false;
  K_FrameRAEdit.AddRow.Enabled := false;
  K_FrameRAEdit.DelRow.Enabled := false;
  K_FrameRAEdit.CopyToClipBoard.Enabled := false;
  K_FrameRAEdit.PasteFromClipBoard.Enabled := false;
  K_FrameRAEdit.TranspGrid.Enabled := false;
  K_FrameRAEdit.RebuildGrid.Enabled := false;
  EditAliases.Enabled := false;
  RenameDCSpace.Enabled := false;

  if (CurUDCSpace = nil) then begin
//    MemIniToCurState;
    CurUDCSpace := TK_UDDCSpace( K_CurSpacesRoot.DirChild( CurUDIndex ) );
    if CurUDCSpace = nil then
      CurUDCSpace := TK_UDDCSpace( K_CurSpacesRoot.DirChild( 0 ) );
    CurUDIndex := -1;
  end;
  if (CurUDCSpace <> nil) then begin
    with K_CurSpacesRoot do
      CmBSlist.ItemIndex := IndexOfDEField(CurUDCSpace);
    if CmBSlist.ItemIndex <> -1 then
      CmBSListSelect(nil);
  end;
  if CurUDCSpace = nil then begin
    ImportDCSpace.Enabled := false;
    ExportDCSpace.Enabled := false;
    CmBSList.Enabled := false;
  end;
end; // end of procedure TK_FormDCSpace.InitData

{
procedure TK_FormDCSpace.FormShow(Sender: TObject);
begin
//  K_FrameRAEdit.RebuildGridExecute(Sender);
  ResultDataWasChanged := false;
  DataSaveModalState := mrNone;
  K_CurSpacesRoot.BuildChildsList(CmBSlist.Items, K_ontObjUName);
  CurUDIndex := -1;
  CmBSlist.ItemIndex := -1;
  CmBSlist.Text := '';

  K_FrameRAEdit.SetGridLRowsNumber(  0 );
  K_FrameRAEdit.SGrid.Invalidate;

  AddRow.Enabled := false;
  K_FrameRAEdit.AddRow.Enabled := false;
  K_FrameRAEdit.DeleteRow.Enabled := false;
  K_FrameRAEdit.CopyToClipBoard.Enabled := false;
  K_FrameRAEdit.PasteFromClipBoard.Enabled := false;
  K_FrameRAEdit.TranspGrid.Enabled := false;
  K_FrameRAEdit.RebuildGrid.Enabled := false;
  EditAliases.Enabled := false;
  RenameDCSpace.Enabled := false;

  if (CurUDCSpace = nil) then begin
//    MemIniToCurState;
    CurUDCSpace := TK_UDDCSpace( K_CurSpacesRoot.DirChild( CurUDIndex ) );
    if CurUDCSpace = nil then
      CurUDCSpace := TK_UDDCSpace( K_CurSpacesRoot.DirChild( 0 ) );
    CurUDIndex := -1;
  end;
  if (CurUDCSpace <> nil) then begin
    with K_CurSpacesRoot do
      CmBSlist.ItemIndex := IndexOfDEField(CurUDCSpace);
    if CmBSlist.ItemIndex <> -1 then
      CmBSListSelect(nil);
  end;
  if CurUDCSpace = nil then begin
    ImportDCSpace.Enabled := false;
    ExportDCSpace.Enabled := false;
    CmBSList.Enabled := false;
  end;
end; // end of procedure TK_FormDCSpace.FormShow
}

//***********************************  TK_FormDCSpace.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormDCSpace.CurStateToMemIni();
begin
  inherited;
  N_IntToMemIni( Name, 'DCSInd', CmBSlist.ItemIndex );
end; // end of procedure TK_FormDCSpace.CurStateToMemIni

//***********************************  TK_FormDCSpace.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormDCSpace.MemIniToCurState();
begin
  inherited;
  CurUDIndex := N_MemIniToInt( Name, 'DCSInd', -1 );
end; // end of procedure TK_FormDCSpace.MemIniToCurState

procedure TK_FormDCSpace.ShowDCSpace( UDCSpace: TK_UDDCSpace);
var
  i, h : Integer;
  PCodes : PString;
  PNames : PString;
  PKeys : PString;
  EnabledState : Boolean;
begin
  CmBSList.Enabled := true;
  CurUDCSpace := UDCSpace;
  Caption := UDCSpace.GetUName + ' - ' + IniCaption;
  EdID.Text := CurUDCSpace.ObjName;
  with TK_PDCSpace(CurUDCSpace.R.P)^ do begin
//*** prepare editing
    h := Codes.ALength;
//*** prepare Result Array
    PCodes := PString( Codes.P );
    PNames := PString( Names.P );
    PKeys := PString( Keys.P );
    WData.ASetLength( h );
    for i := 0 to h-1 do begin
      with TK_PDCEditSpace( WData.P(i) )^ do begin
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
  K_FrameRAEdit.RebuildGridInfo;
//  K_FrameRAEdit.SGrid.Invalidate;

  EnabledState := (K_cssNotReadOnly in DCSShowFlags);
  AddRow.Enabled := EnabledState;
  RenameDCSpace.Enabled := EnabledState;
  CreateDCSpace.Enabled := EnabledState;
  ImportDCSpace.Enabled := EnabledState;
  ExportDCSpace.Enabled := EnabledState;
  EditAliases.Enabled := EnabledState;
  K_FrameRAEdit.AddRow.Enabled := EnabledState;
  K_FrameRAEdit.DelRow.Enabled := EnabledState;
  K_FrameRAEdit.CopyToClipBoard.Enabled := EnabledState;
  K_FrameRAEdit.PasteFromClipBoard.Enabled := EnabledState;
  K_FrameRAEdit.TranspGrid.Enabled := true;
  K_FrameRAEdit.RebuildGrid.Enabled := true;

  CmBSList.Enabled := not (K_cssSkipDCSChange in DCSShowFlags);
  ClearChangeDataFlag;
end;

procedure TK_FormDCSpace.FormCreate(Sender: TObject);
begin
  ClearChangeDataFlag;
  IniCaption := Caption;
  DCSShowFlags := [K_cssNotReadOnly];
  FormDescr := K_CreateSPLClassByName( 'TK_FormDCSpace', [] );
  DDType := K_GetTypeCodeSafe('TK_DCEditSpace');
  Inc( DDType.D.TFlags, K_ffArray );
  AModeFlags := [K_ramColVertical, K_ramRowChangeNum,
                 K_ramRowAutoChangeNum, K_ramRowChangeOrder,
                 K_ramSkipResizeHeight, K_ramSkipResizeWidth,
                 K_ramOnlyEnlargeSize];
  K_RAFColsPrepByRADataFormDescr(
      RAFCArray, @FrDescr, AModeFlags, DDType, FormDescr );

  WData := K_RCreateByTypeName( 'TK_DCEditSpace', 0 );
  K_FrameRAEdit.SetGridInfo( AModeFlags, RAFCArray, FrDescr, 0, nil,
                                                  nil, nil );
  K_FrameRAEdit.OnDataChange := AddChangeDataFlag;
  K_FrameRAEdit.OnRowsAdd := OnAddDataRow;
  CurUDCSpace := nil;
end;

function TK_FormDCSpace.SaveDataIfNeeded : Word;
var res : Word;
begin
  res := DataSaveModalState;
  if  DataWasChanged  then begin
    if DataSaveModalState = mrNone then
      res := MessageDlg( 'Данные были изменены - запомнить?',
           mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if (res = mrYes) then begin
      if not SaveDataToCurDCSpace then res := mrCancel;
    end else begin
      if (res = mrNo) and
         (CurUDIndex = -1) then
        with K_CurSpacesRoot do
          DeleteDirEntry( DirHigh );
    end;
  end;
  Result := res;
end;

procedure TK_FormDCSpace.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := (SaveDataIfNeeded <> mrCancel);
  if not CanClose then Exit;
  CurUDCSpace := nil;
end;

procedure TK_FormDCSpace.SaveCurDCSpaceExecute(Sender: TObject);
begin
  if not DataWasChanged then Exit;
  if SaveDataToCurDCSpace() then
    ShowDCSpace( CurUDCSpace );
end;

function TK_FormDCSpace.SaveDataToCurDCSpace : Boolean;
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
  FullDCSS : TN_UDBase;
//  PInd : PInteger;

label Error;

begin

  with  K_FrameRAEdit do begin
    SetLength( FrameDataIndex, GetDataBufRow );
    k := High(FrameDataIndex);
    if k = -1 then begin
      ErrText := 'Создание пустого пространства недопустимо';
      goto Error;
    end;

    for i := 0 to k do
      FrameDataIndex[i] := GetDataBufRow(i);
  end;

//*** Check if Codes are correct
  StatusBar.SimpleText := '';
  for i := 0 to k - 1 do begin
    PCodes := @(TK_PDCEditSpace( WData.P(FrameDataIndex[i]) ).Code);
    for j := i + 1 to k do begin
      if PCodes^ = TK_PDCEditSpace( WData.P(FrameDataIndex[j]) ).Code then begin
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

  with TK_PDCSpace(CurUDCSpace.R.P)^ do begin
//*** save text fields
    FullDCSS := CurUDCSpace.GetSSpacesDir.DirChildByObjName( CurUDCSpace.ObjName );
    CurUDCSpace.ObjAliase := CmBSlist.Text;
    if CurUDIndex = -1 then begin
      CurUDIndex := CmBSlist.Items.Count;
      CmBSlist.AddItem(CurUDCSpace.GetUName, CurUDCSpace);
    end;
    K_CurSpacesRoot.SetUniqChildName( CurUDCSpace );
    K_CurSpacesRoot.SetUniqChildName( CurUDCSpace, K_ontObjAliase );
    if FullDCSS <> nil then begin
      FullDCSS.ObjName := CurUDCSpace.ObjName;
      FullDCSS.ObjAliase := CurUDCSpace.ObjAliase;
    end;
    CmBSlist.Items.Strings[CurUDIndex] := CurUDCSpace.GetUName;
    CmBSlist.ItemIndex := CurUDIndex;
    CmBSlist.Text := CurUDCSpace.GetUName;

//*** Check if added Codes have Old Code Values and calculate their previous indexes
    nd := k + 1;
    SetLength( PrevIndex, nd );
    PCodes := PString( Codes.P );
    h := Codes.AHigh;
//*** get previous indexes values
    if k >= 0 then begin
      K_MoveVectorBySIndex( PrevIndex[0], SizeOf(Integer), WData.P^,
                 SizeOf( TK_DCEditSpace ), SizeOf(Integer),
                 nd, @FrameDataIndex[0] );
//*** Get Codes From Buf Data
      SetLength( WCodes, nd );

      K_MoveSPLVectorBySIndex( WCodes[0], SizeOf(string),
                        TK_PDCEditSpace(WData.P).Code, SizeOf( TK_DCEditSpace ),
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

      CurUDCSpace.ChangeDCSSOrder( @PrevIndex[0], nd );
    end;

//*** Change Code Space
    Codes.ASetLength( nd );
    PCodes := PString( Codes.P );
    Names.ASetLength( nd );
    PNames := PString( Names.P );
    Keys.ASetLength( nd );
    PKeys := PString( Keys.P );
    Dec( nd );
    for i := 0 to nd do begin
      with TK_PDCEditSpace( WData.P(FrameDataIndex[i]) )^ do begin
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
  K_SetChangeSubTreeFlags( CurUDCSpace );
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaOK );

end;

procedure TK_FormDCSpace.CreateDCSpaceExecute(Sender: TObject);
var
  NName, NAliase : string;
begin
  if SaveDataIfNeeded <> mrCancel then begin
    NAliase := K_CurSpacesRoot.BuildUniqChildName( K_FDCSpaceNewAliase, nil, K_ontObjAliase );
    NName := K_CurSpacesRoot.BuildUniqChildName( K_FDCSpaceNewName );
    if not K_EditNameAndAliase(  NAliase, NName ) then Exit;
    CurUDCSpace := K_DCSpaceCreate( NName, NAliase );
    CurUDIndex := -1;
    CmBSlist.Text := CurUDCSpace.GetUName;
    ShowDCSpace( CurUDCSpace );
    AddChangeDataFlag;
    K_CurSpacesRoot.RebuildVNodes;
  end;
end;

{*** end of TK_FormDCSpace ***}

procedure TK_FormDCSpace.AddChangeDataFlag;
begin
  DataWasChanged := true;
  BtOK.Caption := 'OK';
  BtCancel.Enabled := true;
  SaveCurDCSpace.Enabled := true;
end;


procedure TK_FormDCSpace.ClearChangeDataFlag;
begin
  DataSaveModalState := mrNone;
  DataWasChanged := false;
  BtOK.Caption := 'Выход';
  BtCancel.Enabled := false;
  SaveCurDCSpace.Enabled := false;
end;


procedure TK_FormDCSpace.BtCancelClick(Sender: TObject);
begin
  DataSaveModalState := mrNo;
end;

procedure TK_FormDCSpace.BtOKClick(Sender: TObject);
begin
  DataSaveModalState := mrYes;
end;

procedure TK_FormDCSpace.OpenDCSPaceExecute(Sender: TObject);
begin
  CmBSlist.DroppedDown := true;
  CmBSlist.SetFocus;
end;

procedure TK_FormDCSpace.CmBSListSelect(Sender: TObject);
begin
  with CmBSList do begin
    if CurUDIndex = ItemIndex then Exit;
    Text := CurUDName;
    if SaveDataIfNeeded <> mrCancel then begin
      CurUDIndex := ItemIndex;
      if CurUDIndex = -1 then Exit;
      ShowDCSpace( TK_UDDCSpace(Items.Objects[CmBSlist.ItemIndex]) );
    end else begin
      ItemIndex := CurUDIndex;
    end;
    Text := Items[ItemIndex];
  end;
end;

procedure TK_FormDCSpace.CmBSListDropDown(Sender: TObject);
begin
  CurUDName := CmBSList.Text;
end;

procedure TK_FormDCSpace.CmBSListChange(Sender: TObject);
begin
  with CmBSList do
    if CurUDIndex <> -1 then begin
      Items[CurUDIndex] := Text;
      Text := Items[CurUDIndex];
    end;
  AddChangeDataFlag;
end;

procedure TK_FormDCSpace.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
  K_FrameRAEdit.FreeContext;
  FormDescr.Free;
  K_FreeColumnsDescr( RAFCArray );
  K_FormDCSpace := nil;
  K_CurSpacesRoot.RebuildVNodes();
end;

procedure TK_FormDCSpace.OnAddDataRow( ACount : Integer = 1 );
begin
  with WData do begin
    ASetLength( ALength + ACount );
    K_FrameRAEdit.SetDataPointersFromRArray( P^, ElemType, 0 );
    PInteger( P(AHigh) )^ := -1;
  end;
end;

procedure TK_FormDCSpace.ImportDCSpaceExecute(Sender: TObject);
begin
  if (CurUDCSpace <> nil) then begin
    with CurUDCSpace.GetSSpacesDir do
    if (DirLength > 1) or
       (DirChild(0).ObjName <> CurUDCSpace.ObjName) then begin
      K_ShowMessage( 'Пространство имеет подпространства - перезагрука невозжна' );
      Exit;
    end;
    if (OpenDialog1.Execute) then begin
      N_LoadCSFromTxtFile( CurUDCSpace, OpenDialog1.FileName );
      ShowDCSpace(CurUDCSpace);
      AddChangeDataFlag;
    end;
  end;
end;

procedure TK_FormDCSpace.ExportDCSpaceExecute(Sender: TObject);
begin
  if (CurUDCSpace <> nil) and (SaveDialog1.Execute) then
    N_SaveCSToTxtFile( CurUDCSpace, SaveDialog1.FileName );
end;

procedure TK_FormDCSpace.EditAliasesExecute(Sender: TObject);
var
  SaveResult : word;
begin
  SaveResult := SaveDataIfNeeded;
  if (SaveResult <> mrYes) and
     (SaveResult <> mrNone) then Exit;
  K_EditUDVectorsTab( CurUDCSpace.GetAliasesDir, '', [K_ramColVertical], 'nn',
    'TK_DSSVector', K_UDVectorCI, Self, OnGlobalAction );
end;

procedure TK_FormDCSpace.CloseExecute(Sender: TObject);
begin
  ModalResult := mrOK;
end;


procedure TK_FormDCSpace.AddRowExecute(Sender: TObject);
begin
  with K_FrameRAEdit do begin
    AddRowExecute(Sender);
    SelectLRect(-1, GetDataBufRow - 1 );
  end;
end;

procedure TK_FormDCSpace.RenameDCSpaceExecute(Sender: TObject);
var
  FullDCSS : TN_UDBase;

begin
  FullDCSS := CurUDCSpace.GetSSpacesDir.DirChildByObjName( CurUDCSpace.ObjName );
  if K_EditUDNameAndAliase(  CurUDCSpace ) then begin
    K_CurSpacesRoot.SetUniqChildName( CurUDCSpace );
    K_CurSpacesRoot.SetUniqChildName( CurUDCSpace, K_ontObjAliase );
    if FullDCSS <> nil then begin
      FullDCSS.ObjName := CurUDCSpace.ObjName;
      FullDCSS.ObjAliase := CurUDCSpace.ObjAliase;
    end;
    EdID.Text := CurUDCSpace.ObjName;
    CmBSlist.Text := CurUDCSpace.GetUName;
    if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaOK );
    K_SetChangeSubTreeFlags( CurUDCSpace );
  end;
end;

end.
