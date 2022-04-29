unit K_FDCSSpace;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Menus, ActnList, ComCtrls, ToolWin, ImgList,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  K_Script1, K_FrRaEdit, K_DCSpace,
  N_BaseF, N_Lib1, N_Types, ExtCtrls;

type
  TK_FormDCSSpace = class(TN_BaseForm)
    LbSSpace: TLabel;
    LbSpace:  TLabel;
    LbID:     TLabel;

    BBtnAdd:  TBitBtn;
    BtCancel: TButton;
    BtOK:     TButton;
    Button1:  TButton;
    BBtnDel:  TButton;

    K_FrameRAEditS:  TK_FrameRAEdit;
    K_FrameRAEditSS: TK_FrameRAEdit;

    CmBSList:  TComboBox;
    CmBSSList: TComboBox;

    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;

    MainMenu1: TMainMenu;
    N1:  TMenuItem;
    N2:  TMenuItem;
    N3:  TMenuItem;
    N4:  TMenuItem;
    N5:  TMenuItem;
    N6:  TMenuItem;
    N7:  TMenuItem;
    N8:  TMenuItem;
    N9:  TMenuItem;
    N10: TMenuItem;

    ActionList1: TActionList;
    CreateDCSSpace:    TAction;
    OpenDCSSpace:      TAction;
    SaveCurDCSSpace:   TAction;
    ImportCurDCSSpace: TAction;
    ExportCurDCSSpace: TAction;
    RenameDCSSpace:    TAction;
    ReLinkCSSData:     TAction;
    Close:             TAction;
    AddSSItems:        TAction;

    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;


    EdID: TEdit;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure OnAddDataRow ( ACount : Integer = 1 );
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;

    procedure BBtnAddClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure CmBSListSelect(Sender: TObject);
    procedure CmBSSListSelect(Sender: TObject);
    procedure CmBSSListDropDown(Sender: TObject);
    procedure CreateDCSSpaceExecute(Sender: TObject);
    procedure CmBSSListChange(Sender: TObject);
    procedure OpenDCSSpaceExecute(Sender: TObject);
    procedure SaveCurDCSSpaceExecute(Sender: TObject);
    procedure ImportCurDCSSpaceExecute(Sender: TObject);
    procedure ExportCurDCSSpaceExecute(Sender: TObject);
    procedure CloseExecute(Sender: TObject);
    procedure AddSSItemsExecute(Sender: TObject);
    procedure RenameDCSSpaceExecute(Sender: TObject);
    procedure ReLinkCSSDataExecute(Sender: TObject);
  private
    { Private declarations }
    DataSaveModalState : word;

    DDType : TK_ExprExtType;
    FormDescr : TK_UDRArray;
    RAFCArray : TK_RAFCArray;
    FrDescr : TK_RAFrDescr;
    AModeFlags : TK_RAModeFlagSet;

    SSpaceBuf : TK_RArray;

    IniCaption : string;
    CurUDCSpace : TK_UDDCSpace;
    CurUDCSIndex : Integer;
    CurUDCSSpace : TK_UDDCSSpace;
    CurUDCSSIndex : Integer;
    CurUDCSSName : string;
    SpaceIndex : Integer;
    CSSUDVList : TK_BuildCSSUDVList;

  public
    { Public declarations }
    DataWasChanged : Boolean;
    ResultDataWasChanged : Boolean;
    OnGlobalAction : TK_RAFGlobalActionProc;
    procedure ShowCSSDCSpace( UDCSpace : TK_UDDCSpace );
    procedure ShowDCSSpace( UDCSSpace : TK_UDDCSSpace );
    function  SaveDataToCurDCSSpace : Boolean;
    procedure AddChangeDataFlag;
    procedure ClearChangeDataFlag;
    function  SaveDataIfNeeded : Boolean;
  end;

function  K_GetFormDCSSpace( AOwner: TN_BaseForm ) : TK_FormDCSSpace;
function  K_EditDCSSpace( UDCSSpace : TK_UDDCSSpace; AOwner: TN_BaseForm = nil;
              AOnGlobalAction : TK_RAFGlobalActionProc = nil ) : Boolean;

var
  K_FormDCSSpace: TK_FormDCSSpace;

var K_DCSSpaceEditCont : TK_RAEditFuncCont;
function K_EditDCSSpaceFunc( var UDCSSpace; PDContext: Pointer ) : Boolean;

implementation

uses Math, Grids, inifiles,
  K_VFunc, K_FSFCombo, K_Arch, K_UDT1, K_RaEdit, K_CLib0, K_CLib, K_FUDRename,
  N_ClassRef, N_ME1, N_ButtonsF;

{$R *.dfm}




function K_EditDCSSpaceFunc( var UDCSSpace; PDContext: Pointer ) : Boolean;
begin
  with TK_PRAEditFuncCont(PDContext)^ do
  Result := K_EditDCSSpace( TK_UDDCSSpace(UDCSSpace), FOwner, FOnGlobalAction );
end;

function K_GetFormDCSSpace( AOwner: TN_BaseForm ) : TK_FormDCSSpace;
begin
  if K_FormDCSSpace = nil then begin
    K_FormDCSSpace := TK_FormDCSSpace.Create(Application);
    K_FormDCSSpace.BaseFormInit( AOwner );
  end;
  Result := K_FormDCSSpace;
end;

function K_EditDCSSpace( UDCSSpace : TK_UDDCSSpace; AOwner: TN_BaseForm = nil;
              AOnGlobalAction : TK_RAFGlobalActionProc = nil ) : Boolean;
begin
  with K_GetFormDCSSpace( AOwner ) do begin
    CurUDCSSpace := UDCSSpace;
    CurUDCSpace := CurUDCSSpace.GetDCSpace;
    OnGlobalAction := AOnGlobalAction;
    ShowModal;
    Result := ResultDataWasChanged;
  end;
end;

procedure TK_FormDCSSpace.BBtnAddClick(Sender: TObject);
var
  GR : TGridRect;
begin
  GR := K_FrameRAEditS.SGrid.Selection;
  GR.Top := Max( GR.Top, 1 );
  SpaceIndex := GR.Top - 1;
  while SpaceIndex < GR.Bottom do begin // add new member
    with K_FrameRAEditSS do begin
      AddRowExecute(nil);
      DataPointers[High(DataPointers)][0] :=
        K_FrameRAEditS.DataPointers[SpaceIndex][0];
      DataPointers[High(DataPointers)][1] :=
        K_FrameRAEditS.DataPointers[SpaceIndex][1];
    end;
    Inc(SpaceIndex);
  end;
end;

procedure TK_FormDCSSpace.FormShow(Sender: TObject);
begin
//  K_FrameRAEdit.RebuildGridExecute(Sender);
//  ClearChangeDataFlag;
  DataSaveModalState := mrNone;
  ResultDataWasChanged := false;
  K_CurSpacesRoot.BuildChildsList(CmBSlist.Items, K_ontObjUName);
  CmBSlist.ItemIndex := -1;
  CmBSlist.Text := '';
  CurUDCSSIndex := -1;
  CurUDCSIndex := -1;

  CreateDCSSpace.Enabled := false;
  OpenDCSSpace.Enabled := false;
  SaveCurDCSSpace.Enabled := false;

  K_FrameRAEditS.SetGridLRowsNumber(  0 );
  K_FrameRAEditS.SGrid.Invalidate;

  AddSSItems.Enabled := false;
  K_FrameRAEditSS.DelRow.Enabled := false;

//*** Init Space/SubSpace case
  if (CurUDCSpace = nil) then begin
    MemIniToCurState;
    CurUDCSpace := TK_UDDCSpace( K_CurSpacesRoot.DirChild( CurUDCSIndex ) );
    CurUDCSIndex := -1;
    CurUDCSSpace := TK_UDDCSSpace( CurUDCSpace.GetSSpacesDir.DirChild( CurUDCSSIndex ) );
  end;
  if (CurUDCSpace <> nil) then begin
    with K_CurSpacesRoot do
      CmBSlist.ItemIndex := IndexOfDEField(CurUDCSpace);
    if CmBSlist.ItemIndex <> -1 then
      CmBSListSelect(nil);
  end;
  ClearChangeDataFlag;
  if CurUDCSSpace = nil then begin
    ImportCurDCSSpace.Enabled := false;
    ExportCurDCSSpace.Enabled := false
  end;
end;

procedure TK_FormDCSSpace.AddChangeDataFlag;
begin
  DataWasChanged := true;
  BtOK.Caption := 'OK';
  BtCancel.Enabled := true;
  SaveCurDCSSpace.Enabled := true;
end;

procedure TK_FormDCSSpace.ClearChangeDataFlag;
begin
  DataWasChanged := false;
  BtOK.Caption := 'Выход';
  BtCancel.Enabled := false;
  SaveCurDCSSpace.Enabled := false;
end;

procedure TK_FormDCSSpace.BtCancelClick(Sender: TObject);
begin
  DataSaveModalState := mrNo;
end;

procedure TK_FormDCSSpace.BtOKClick(Sender: TObject);
begin
  DataSaveModalState := mrYes;
end;

procedure TK_FormDCSSpace.FormCreate(Sender: TObject);
begin
  ClearChangeDataFlag;
  IniCaption := Caption;
  FormDescr := K_CreateSPLClassByName( 'TK_FormDCSSpace', [] );
  DDType := K_GetTypeCodeSafe( 'TK_DCEditSpace1' );
  Inc( DDType.D.TFlags, K_ffArray );
  AModeFlags := [K_ramColVertical, K_ramReadOnly, K_ramSkipResizeWidth,
                 K_ramSkipResizeHeight, K_ramOnlyEnlargeSize, K_ramSkipRowMoving];
  K_RAFColsPrepByRADataFormDescr(
      RAFCArray, @FrDescr, AModeFlags, DDType, FormDescr );

//*** Prepare SubSpace Buffer
  SSPaceBuf := TK_RArray.CreateByType( Ord(nptInt) );

  K_FrameRAEditS.SetGridInfo( AModeFlags, RAFCArray, FrDescr, 0,  nil,
                                                  nil, nil );
//  AModeFlags := [K_ramReadOnly, K_ramRowEditing, K_ramRowAdding, K_ramColVertical,
//                 K_ramSkipResizeWidth, K_ramEnlargeSize];
  AModeFlags := [K_ramRowChangeOrder, K_ramRowChangeNum, K_ramColVertical,
                 K_ramSkipResizeWidth, K_ramSkipResizeHeight, K_ramOnlyEnlargeSize];
  K_FrameRAEditSS.SetGridInfo( AModeFlags, RAFCArray, FrDescr, 0,  nil,
                                                  nil, nil );
  K_FrameRAEditSS.OnRowsAdd := OnAddDataRow;
  K_FrameRAEditSS.OnDataChange := AddChangeDataFlag;
  CurUDCSpace := nil;
  CurUDCSSpace := nil;
  CmBSSList.Enabled := false;
  CSSUDVList := TK_BuildCSSUDVList.Create;

end;

procedure TK_FormDCSSpace.ShowCSSDCSpace(UDCSpace: TK_UDDCSpace);
var
  Root : TN_UDBase;

begin
  CurUDCSpace := UDCSpace;
  Caption := IniCaption;
  with TK_PDCSpace(CurUDCSpace.R.P)^ do begin
//*** prepare editing
    K_FrameRAEditS.SetGridLRowsNumber(  Codes.ALength );

    K_FrameRAEditS.SetDataPointersFromColumnRArrays(
                          Codes, nil, -1 );
  end;
  K_FrameRAEditS.RebuildGridExecute(nil);
  K_FrameRAEditS.SGrid.Invalidate;

//*** Prepare SubSpace List
  DataSaveModalState := mrNone;
  Root := CurUDCSpace.GetSSpacesDir;

  Root.BuildChildsList(CmBSSlist.Items, K_ontObjUName);
  CmBSSlist.ItemIndex := -1;
  CmBSSlist.Text := '';

  K_FrameRAEditSS.SetGridLRowsNumber(  0 );
  K_FrameRAEditSS.SGrid.Invalidate;

  AddSSItems.Enabled := false;
  K_FrameRAEditSS.DelRow.Enabled := false;

//*** Init Space/SubSpace case
  if (CurUDCSSpace = nil) and (CmBSSlist.Items.Count > 0) then begin
    CurUDCSSpace := TK_UDDCSSpace( Root.DirChild(0) );
  end;

  if (CurUDCSSpace <> nil) then begin
    CmBSSList.Enabled := true;
    with Root do
      CmBSSlist.ItemIndex := IndexOfDEField(CurUDCSSpace);
    if CmBSSlist.ItemIndex <> -1 then
      CmBSSListSelect(nil);
  end else
    CmBSSList.Enabled := false;

  ClearChangeDataFlag;

  CreateDCSSpace.Enabled := true;
  OpenDCSSpace.Enabled := true;
end;

procedure TK_FormDCSSpace.ShowDCSSpace(UDCSSpace: TK_UDDCSSpace);
var
  ElemCount : Integer;
begin
  CurUDCSSpace := UDCSSpace;
  Caption := CurUDCSSpace.GetUName + ' - ' + IniCaption;
  EdID.Text := CurUDCSSpace.ObjName;

  RenameDCSSpace.Enabled := (CurUDCSSpace.ObjName <> CurUDCSpace.ObjName);
  if (CurUDCSSpace.ObjName = CurUDCSpace.ObjName) or
     (CurUDCSSpace.CI = K_UDVectorCI ) then begin
//*** Special SubSpace (Full or Projection)
    K_FrameRAEditSS.ModeFlags := K_FrameRAEditSS.ModeFlags
                    - [K_ramRowChangeOrder, K_ramRowChangeNum]
                    + [K_ramReadOnly, K_ramSkipRowMoving];
    AddSSItems.Enabled := false;
    K_FrameRAEditSS.DelRow.Enabled := false;
  end else begin
    K_FrameRAEditSS.ModeFlags := K_FrameRAEditSS.ModeFlags
                    + [K_ramRowChangeOrder, K_ramRowChangeNum]
                    - [K_ramReadOnly, K_ramSkipRowMoving];
    AddSSItems.Enabled := true;
    K_FrameRAEditSS.DelRow.Enabled := true;
  end;

//  K_FrameRAEditSS.RebuildGridInfo;

  with TK_PDCSpace( CurUDCSpace.R.P )^,
       CurUDCSSpace.PDRA^ do begin
//*** Prepare SubSpace Buffer
    ElemCount := Alength;
    SSPaceBuf.ASetLength( ElemCount );

    SSPaceBuf.SetElems( P^, false );
//*** Prepare SubSpace Frame
    K_FrameRAEditSS.SetGridLRowsNumber( ElemCount );
    K_FrameRAEditSS.SetDataPointersFromColumnRArrays(
                          Codes, PInteger(P), ElemCount );
  end;
//  K_FrameRAEditSS.SGrid.Invalidate;
  K_FrameRAEditSS.RebuildGridInfo;
  ClearChangeDataFlag;
  ImportCurDCSSpace.Enabled := true;
  ExportCurDCSSpace.Enabled := true;
end;

function TK_FormDCSSpace.SaveDataToCurDCSSpace: Boolean;
var
  i, h : Integer;
  NInds : TN_IArray;
begin
  with K_FrameRAEditSS,
       CurUDCSSpace.PDRA^,
       CurUDCSpace.GetSSpacesDir do begin
    CurUDCSSpace.ObjAliase := CmBSSlist.Text;
    if CurUDCSSIndex = -1 then begin
      CurUDCSSIndex := DirHigh;
      CmBSSlist.AddItem(CurUDCSSpace.GetUName, CurUDCSSpace);
    end;
    SetUniqChildName( CurUDCSSpace );
    SetUniqChildName( CurUDCSSpace, K_ontObjAliase );
    CmBSSlist.Items.Strings[CurUDCSSIndex] := CurUDCSSpace.GetUName;
    CmBSSlist.ItemIndex := CurUDCSSIndex;
    CmBSSlist.Text := CurUDCSSpace.GetUName;


    h := GetDataBufRow;
    SetLength( NInds, h );
    for i := 0 to h - 1 do
      NInds[i] :=
         PInteger(SSPaceBuf.P(GetDataBufRow(i)))^;
  end;

//  CurUDCSSpace.ChangeValue(  @NInds[0], h,
  CurUDCSSpace.ChangeValue( K_GetPIArray0(NInds), h, 
    mrYes = MessageDlg( 'Изменять ли согласовано связанные вектора?',
       mtConfirmation, [mbYes, mbNo], 0) );
  Result := true; // Like with DCSpace Edit
  ResultDataWasChanged := true;
  ClearChangeDataFlag;
  CurUDCSSpace.RebuildVNodes(1);
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaOK );
  K_SetChangeSubTreeFlags( CurUDCSSpace );
end;

function TK_FormDCSSpace.SaveDataIfNeeded : Boolean;
var res : Word;
begin
  res := DataSaveModalState;
  if DataWasChanged then begin
    if DataSaveModalState = mrNone then
      res := MessageDlg( 'Данные были изменены - запомнить?',
           mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if (res = mrYes) and
       not SaveDataToCurDCSSpace then res := mrCancel
    else begin
      if (res = mrNo) and
         (CurUDCSSIndex = -1) then
        with CurUDCSpace.GetSSpacesDir do
          DeleteDirEntry( DirHigh );
    end;
  end;
  Result := (res <> mrCancel);
end;

procedure TK_FormDCSSpace.CmBSListSelect(Sender: TObject);
begin
  if SaveDataIfNeeded then begin
    CurUDCSIndex := CmBSlist.ItemIndex;
    CurUDCSpace := TK_UDDCSpace( CmBSlist.Items.Objects[CmBSlist.ItemIndex] );
    if Sender <> nil then // clear current SubSpace if select new Space
      CurUDCSSpace := nil;
    CurUDCSSIndex := -1;
    ShowCSSDCSpace( CurUDCSpace );
  end else begin
    CmBSlist.ItemIndex := CurUDCSIndex;
  end;

end;

procedure TK_FormDCSSpace.CmBSSListSelect(Sender: TObject);
begin
  CmBSSList.Text := CurUDCSSName;
  if CurUDCSSIndex = CmBSSlist.ItemIndex then Exit;
  if SaveDataIfNeeded then begin
    CurUDCSSIndex := CmBSSlist.ItemIndex;
    ShowDCSSpace( TK_UDDCSSpace(CmBSSlist.Items.Objects[CmBSSlist.ItemIndex]) );
  end else begin
    CmBSlist.ItemIndex := CurUDCSSIndex;
  end;
  CmBSSList.Text := CmBSSList.Items[CmBSSlist.ItemIndex];

end;

procedure TK_FormDCSSpace.CmBSSListDropDown(Sender: TObject);
begin
  CurUDCSSName := CmBSSList.Text;
end;

procedure TK_FormDCSSpace.CreateDCSSpaceExecute(Sender: TObject);
var
  NName, NAliase : string;
begin
  if SaveDataIfNeeded then begin
    with CurUDCSpace.GetSSpacesDir do begin
      NAliase := BuildUniqChildName( CurUDCSpace.GetUName+' '+IntToStr(DirHigh), nil, K_ontObjAliase );
      NName := BuildUniqChildName( K_FDCSSpaceNewName );
    end;
    if not K_EditNameAndAliase(  NAliase, NName ) then Exit;
    CurUDCSSpace := CurUDCSpace.CreateDCSSpace( NName, -1, NAliase );

{
//    CurUDCSSpace := CurUDCSpace.CreateDCSSpace( K_FDCSSpaceNewName );
//    with CurUDCSSpace do begin
//      PDRA.ASetLength( 0 );
//      ObjAliase := '"'+CurUDCSpace.GetUName+'" SubSpace '+
//                                  IntToStr(CmBSSlist.Items.Count);
//    end;
}

    CmBSSList.Enabled := true;
    CurUDCSSIndex := -1;
    CmBSSlist.Text := CurUDCSSpace.GetUName;
    ShowDCSSpace( CurUDCSSpace );
    CurUDCSpace.GetSSpacesDir.RebuildVNodes;
    K_SetChangeSubTreeFlags( CurUDCSSpace );
    AddChangeDataFlag;
  end;

end;

procedure TK_FormDCSSpace.CmBSSListChange(Sender: TObject);
begin
  with CmBSSlist do
    if CurUDCSSIndex <> -1 then begin
      Items[CurUDCSSIndex] := Text;
      Text := Items[CurUDCSSIndex];
    end;
  AddChangeDataFlag;
end;

procedure TK_FormDCSSpace.OpenDCSSpaceExecute(Sender: TObject);
begin
  CmBSSlist.DroppedDown := true;
  CmBSSlist.SetFocus;
end;

procedure TK_FormDCSSpace.SaveCurDCSSpaceExecute(Sender: TObject);
begin
  if not DataWasChanged then Exit;
  SaveDataToCurDCSSpace;
end;

procedure TK_FormDCSSpace.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := SaveDataIfNeeded;
  if not CanClose then Exit;
  CurUDCSpace := nil;
  CurUDCSSpace := nil;
end;

procedure TK_FormDCSSpace.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
  K_FrameRAEditS.FreeContext;
  K_FrameRAEditSS.FreeContext;
  FormDescr.Free;
  SSpaceBuf.Free;
  K_FreeColumnsDescr( RAFCArray );
  K_FormDCSSpace := nil;
  CSSUDVList.Free;
end;

//***********************************  TK_FormDCSSpace.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormDCSSpace.CurStateToMemIni();
begin
  inherited;
  N_IntToMemIni( Name, 'DCSInd', CmBSlist.ItemIndex );
  N_IntToMemIni( Name, 'DCSSInd', CmBSSList.ItemIndex );

end; // end of procedure TK_FormDCSSpace.CurStateToMemIni

//***********************************  TK_FormDCSSpace.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormDCSSpace.MemIniToCurState();
begin
  inherited;
  CurUDCSIndex := N_MemIniToInt( Name, 'DCSInd', -1 );
  CurUDCSSIndex := N_MemIniToInt( Name, 'DCSSInd', -1 );
end; // end of procedure TK_FormDCSSpace.MemIniToCurState

//***********************************  TK_FormDCSSpace.OnAddDataRow
// Add Row to BufData
//
procedure TK_FormDCSSpace.OnAddDataRow( ACount : Integer = 1 );
var
  Ind : Integer;
begin
  with SSPaceBuf do begin
    Ind := ALength;
    ASetLength( Ind + ACount );
    PInteger( P( Ind ) )^ := SpaceIndex;
  end;
end; // end of procedure TK_FormDCSSpace.OnAddDataRow

procedure TK_FormDCSSpace.ImportCurDCSSpaceExecute(Sender: TObject);
begin
  if (CurUDCSSpace <> nil) then begin
    if CSSUDVList.Build( K_CurArchive, CurUDCSSpace ).Count  > 0 then begin
//??!!    if CurUDCSSpace.GetVectorsDir.DirLength > 0 then begin
      K_ShowMessage( 'Подпространство имеет связанные вектора - перезагрука невозжна' );
      Exit;
    end;
    if (OpenDialog1.Execute) then begin
      N_LoadCSSFromTxtFile( CurUDCSSpace, OpenDialog1.FileName );
      ShowDCSSpace(CurUDCSSpace);
      AddChangeDataFlag;
    end;
  end;
end;

procedure TK_FormDCSSpace.ExportCurDCSSpaceExecute(Sender: TObject);
begin
  if (CurUDCSSpace <> nil) and (SaveDialog1.Execute) then
    N_SaveCSSToTxtFile( CurUDCSSpace, SaveDialog1.FileName );
end;

procedure TK_FormDCSSpace.CloseExecute(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TK_FormDCSSpace.AddSSItemsExecute(Sender: TObject);
var
  GR : TGridRect;
  SInd, MInd : Integer;
begin
  GR := K_FrameRAEditS.SGrid.Selection;
  GR.Top := Max( GR.Top, 1 );
  SpaceIndex := GR.Top - 1;
  with K_FrameRAEditSS do begin
   SInd := Length(DataPointers);
   while SpaceIndex < GR.Bottom do begin // add new member
        AddRowExecute(nil);
        MInd := High(DataPointers);
        DataPointers[MInd][0] :=
          K_FrameRAEditS.DataPointers[SpaceIndex][0];
        DataPointers[MInd][1] :=
          K_FrameRAEditS.DataPointers[SpaceIndex][1];
      Inc(SpaceIndex);
    end;
    SelectLRect(-1, SInd );
  end;
end;

procedure TK_FormDCSSpace.RenameDCSSpaceExecute(Sender: TObject);
begin
  if K_EditUDNameAndAliase(  CurUDCSSpace ) then begin
    with CurUDCSpace.GetSSpacesDir do begin
      SetUniqChildName( CurUDCSSpace );
      SetUniqChildName( CurUDCSSpace, K_ontObjAliase );
    end;
    EdID.Text := CurUDCSSpace.ObjName;
    CmBSSlist.Text := CurUDCSSpace.GetUName;
    if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaOK );
    K_SetChangeSubTreeFlags( CurUDCSSpace );
  end;

end;

procedure TK_FormDCSSpace.ReLinkCSSDataExecute(Sender: TObject);
var
  Ind, i : Integer;
  CSSUDVList : TK_BuildCSSUDVList;
  UDVList : TList;
  ACSS : TK_UDDCSSpace;
begin
  Ind := CurUDCSSIndex;
  if not K_SelectFromTStrings( CmBSSList.Items, Ind, 'Подпространство для замены' ) then Exit;
  CSSUDVList := TK_BuildCSSUDVList.Create;
  UDVList := CSSUDVList.Build( K_CurArchive, CurUDCSSpace);
  ACSS := TK_UDDCSSpace( CmBSSlist.Items.Objects[Ind] );
  for i := 0 to UDVList.Count - 1 do
    TK_UDVector(UDVList[i]).ChangeCSS( ACSS );
  CSSUDVList.Free;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaOK );

end;

end.
