unit K_FRADD;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ActnList, ComCtrls, ToolWin, Buttons,
  K_Types, K_FrRaEdit, K_UDT1,
  N_BaseF, N_Types, ExtCtrls;

type
  TK_FRADataDeliveryForm = class(TN_BaseForm)
    VTreeFrame: TN_VTreeFrame;
    ChBUseChilds: TCheckBox;
    SpBSendVals: TSpeedButton;
    ActionList1: TActionList;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    SendFieldValues: TAction;
    StatusBar: TStatusBar;
    ShowChangedObjs: TAction;
    ToolButton3: TToolButton;
    TBShowObjs: TToolButton;
    ChBUseObjType: TCheckBox;
    ChBSkipFieldsReplace: TCheckBox;
    ChBUseAllAvailableFields: TCheckBox;
    ShowFileds: TAction;
    SpeedButton1: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
    procedure FormCloseQuery( Sender: TObject; var CanClose: Boolean );
    procedure FormCreate(Sender: TObject);
    procedure SendFieldValuesExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ShowChangedObjsExecute(Sender: TObject);
    procedure ShowFiledsExecute(Sender: TObject);
  private
    { Private declarations }
    PFields : TN_PArray;
    FTypes  : TN_I8Array;
//    FPaths  : TN_SArray;
    FSLPaths  : TStringList;
    MarkedFieldsCount : Integer;
    MVNPList : TStrings;
    ETNPList : TStrings;
    CHPList : TStrings;
    ChangeFieldsCount : Integer;
    ChangeObjsList : TList;
    ChangeObjRootsList : TList;
    ChangeObjRootsInds : Boolean;
    ChangedObjsView : Boolean;
    CurMarkedUDRoot : TN_UDBase;
    procedure ReturnVTreeFrameView();
    procedure SendValuesToObj( UDObj: TN_UDBase );
    function  UDObjIsValid( UDObj: TN_UDBase ) : Boolean;
    function  ScanChildTree( UDParent : TN_UDBase; var UDChild : TN_UDBase;
      ChildInd : Integer; ChildLevel : Integer; const FieldName : string = '' ) : TK_ScanTreeResult;
    procedure PrepareFieldsList;
  public
    RAFrame : TK_FrameRAEdit;
    UDRoot  : TN_UDBase;
    UDRootPath : string;
    { Public declarations }
  end;

//var
//  K_FRASendFValsForm: TK_FRASendFValsForm;

implementation

{$R *.dfm}

uses
  K_FEText, K_DCSpace, K_UDT2, K_Script1, K_Arch, K_UDConst, K_CLib,
  N_ButtonsF, N_Lib1;

const
  GRootPath = '!!!';

procedure TK_FRADataDeliveryForm.FormShow(Sender: TObject);
var
  BF : TN_BaseForm;
begin
  BF := K_GetOwnerBaseForm( RAFrame );
  if (RAFrame = nil) or
     (BF = nil) or
     (Length(RAFrame.DataPointers) = 0) then Release;
  BaseFormInit( BF );
  inherited;
  ChBUseObjType.Enabled := (RAFrame.RLSData.RUDRArray <> nil);
  ChBUseObjType.Checked := ChBUseObjType.Enabled;
  if UDRoot = nil then
    VTreeFrame.FrSetCurState( UDRootPath, MVNPList, ETNPList, K_CurUserRoot )
  else
    VTreeFrame.RebuildVTree( UDRoot, MVNPList, ETNPList );
  UDRoot := VTreeFrame.VTree.RootUObj;
end;

procedure TK_FRADataDeliveryForm.MemIniToCurState;
begin
  inherited;
  ChBUseChilds.Checked := N_MemIniToBool( Name, 'UseChilds', true );
  ChBSkipFieldsReplace.Checked := N_MemIniToBool( Name, 'SkipReplace', true );
  ChBUseAllAvailableFields.Checked := N_MemIniToBool( Name, 'UseAllAvailableFields', true );
//  UDRootPath := VTreeFrame.MemIniToState( MVNPList, ETNPList );
  UDRootPath := K_GetVTreeStateFromMemIni( MVNPList, ETNPList, Name );
end;

procedure TK_FRADataDeliveryForm.CurStateToMemIni;
begin
  inherited;
  N_BoolToMemIni( Name, 'UseChilds', ChBUseChilds.Checked );
  N_BoolToMemIni( Name, 'SkipReplace', ChBSkipFieldsReplace.Checked );
  N_BoolToMemIni( Name, 'UseAllAvailableFields', ChBUseAllAvailableFields.Checked );
  ReturnVTreeFrameView;
  VTreeFrame.FrCurStateToMemIni( Owner.Name );
end;

procedure TK_FRADataDeliveryForm.FormCloseQuery( Sender: TObject;
                                              var CanClose: Boolean );
//var
//  RPRoot : TN_UDBase;
begin
  inherited;
{
  with VTreeFrame.VTree do begin
    GetMarkedPathStrings(MVNPList);
    GetExpandedPathStrings(ETNPList);
  end;
  UDRoot := VTreeFrame.VTree.RootUObj;
  RPRoot := UDRoot.GetRefPathRoot;
  if RPRoot <> nil then
    UDRootPath := RPRoot.RefPath + RPRoot.GetRefPathToObj( UDRoot )
  else if UDRoot = K_MainRootObj then
    UDRootPath := GRootPath
  else
    UDRootPath := UDRoot.RefPath;
}
  if RAFrame <> nil then RAFrame.DataDeliveryForm := nil;
end;

procedure TK_FRADataDeliveryForm.FormCreate(Sender: TObject);
begin
  inherited;
  MVNPList := TStringList.Create;
  ETNPList := TStringList.Create;
  CHPList := TStringList.Create;
  ChangeObjsList := TList.Create;
  ChangeObjRootsList := TList.Create;
  VTreeFrame.CreateVTree( nil, 0 );
  FSLPaths  := TStringList.Create;
end;

procedure TK_FRADataDeliveryForm.PrepareFieldsList;
var
  FLength, i, LRow : Integer;
begin
//*** Prepare Fields List
  FLength := Length(RAFrame.RAFCArray);
  SetLength( PFields,  FLength );
  SetLength( FTypes,   FLength );
//  SetLength( FPaths, FLength );
  FSLPaths.Clear;
  MarkedFieldsCount := 0;
  LRow := RAFrame.CurLRow;
  if LRow < 0 then LRow := 0;
  for i := 0 to FLength - 1 do begin
    with RAFrame, RAFrame.RAFCArray[i] do begin
      if not Marked then Continue;
      PFields[MarkedFieldsCount] := DataPointers[LRow][i];
      FTypes[MarkedFieldsCount]  := CDType.All;
//      FPaths[MarkedFieldsCount]  := GetCellDataPath(i, LRow);
      FSLPaths.Add( GetCellDataPath(i, LRow) );
    end;
    Inc(MarkedFieldsCount);
  end;
end;

procedure TK_FRADataDeliveryForm.SendFieldValuesExecute(Sender: TObject);
var
//  FLength, LRow : Integer;
  i : Integer;
  NoObjects : Boolean;
begin
  NoObjects := ChangedObjsView;
  if ChangedObjsView then ReturnVTreeFrameView;

  if NoObjects or
    (VTreeFrame.VTree.MarkedVNodesList.Count = 0) then begin
    StatusBar.SimpleText := 'Объекты для рассылки не выбраны';
    Exit;
  end;

  PrepareFieldsList;
{
//*** Prepare Fields List
  FLength := Length(RAFrame.RAFCArray);
  SetLength( PFields,  FLength );
  SetLength( FTypes,   FLength );
//  SetLength( FPaths, FLength );
  FSLPaths.Clear;
  MarkedFieldsCount := 0;
  LRow := RAFrame.CurLRow;
  if LRow < 0 then LRow := 0;
  for i := 0 to FLength - 1 do begin
    with RAFrame, RAFrame.RAFCArray[i] do begin
      if not Marked then Continue;
      PFields[MarkedFieldsCount] := DataPointers[LRow][i];
      FTypes[MarkedFieldsCount]  := CDType.All;
//      FPaths[MarkedFieldsCount]  := GetCellDataPath(i, LRow);
      FSLPaths.Add( GetCellDataPath(i, LRow) );
    end;
    Inc(MarkedFieldsCount);
  end;
}
  if MarkedFieldsCount = 0 then begin
    StatusBar.SimpleText := 'Отсутствуют поля для рассылки';
    Exit;
  end;
  Dec(MarkedFieldsCount);

//***  Save Root VNodes List
  VTreeFrame.VTree.GetMarkedPathStrings(MVNPList);
//*** Send Fields Loop
  ChangeFieldsCount := 0;
  ChangeObjsList.Clear;
  ChangeObjRootsList.Clear;
  ChangeObjRootsInds := false;
  with VTreeFrame.VTree do
    for i := 0 to MarkedVNodesList.Count - 1 do begin
      CurMarkedUDRoot := TN_VNode(MarkedVNodesList[i]).VNUDObj;
      SendValuesToObj( CurMarkedUDRoot );
      CurMarkedUDRoot.ScanSubTree( ScanChildTree );
    end;
  if ChBSkipFieldsReplace.Checked then
    StatusBar.SimpleText := 'Найдено'
  else begin
    StatusBar.SimpleText := 'Изменено';
    if ChangeFieldsCount > 0 then K_SetArchiveChangeFlag;
  end;
  StatusBar.SimpleText := StatusBar.SimpleText + ' объектов - '+IntToStr(ChangeObjsList.Count)+
       ', полей - '+IntToStr(ChangeFieldsCount);
end;

procedure TK_FRADataDeliveryForm.ReturnVTreeFrameView;
begin
  if ChangedObjsView then begin
    ShowChangedObjsExecute( nil );
    TBShowObjs.Down := false;
  end;
end;

procedure TK_FRADataDeliveryForm.SendValuesToObj( UDObj: TN_UDBase );
var
  i : Integer;
  DstRA: TK_RArray;
  DstFieldType: TK_ExprExtType;
  PDstField : Pointer;
  LFieldsCount : Integer;
begin
//  if not( UDObj is TK_UDRArray ) or (ChangeObjsList.IndexOf( UDObj ) <> -1) then Exit;
  if not UDObjIsValid( UDObj ) then Exit;
  LFieldsCount := ChangeFieldsCount;
  DstRA := TK_UDRArray(UDObj).R;

  for i := 0 to MarkedFieldsCount do begin
//    DstFieldType := K_GetFieldPointer( @DstRA, DstRA.ArrayType,
//                                               FPaths[i], Pointer(PDstField) );
    DstFieldType := K_GetFieldPointer( @DstRA, DstRA.ArrayType,
                                               FSLPaths[i], Pointer(PDstField) );

          // PDstField is Assigned
    if (DstFieldType.DTCode <> -1) and
          // PDstField points not to SrcField
       (PFields[i] <> PDstField)   and
          // Same Field Types
       ((DstFieldType.All xor FTypes[i]) and K_ectClearICFlags = 0) then begin
      if ChBUseAllAvailableFields.Checked or
        not K_CompareSPLData( PFields[i]^, PDstField^, DstFieldType, '', [] ) then begin
        if not ChBSkipFieldsReplace.Checked then
          K_MoveSPLData( PFields[i]^, PDstField^, DstFieldType, [K_mdfFreeAndFullCopy] );
        Inc(ChangeFieldsCount);
      end;
    end;
  end;

  if LFieldsCount < ChangeFieldsCount then begin
    if not ChBSkipFieldsReplace.Checked then
      K_SetChangeSubTreeFlags( UDObj );
//      UDObj.SetChangedSubTreeFlag;
    ChangeObjsList.Add( UDObj );
    ChangeObjRootsList.Add( CurMarkedUDRoot );
  end;

end;

function TK_FRADataDeliveryForm.UDObjIsValid( UDObj: TN_UDBase ) : Boolean;
begin
  with RAFrame.RLSData.RUDRArray do
    Result := ( UDObj is TK_UDRArray )                                  and
              ( ChangeObjsList.IndexOf( UDObj ) = -1 )                  and
              ( not ChBUseObjType.Enabled or
                not ChBUseObjType.Checked or
                ( (CI = UDObj.CI) and
                  (R.ElemType.All = TK_UDRArray(UDObj).R.ElemType.All) ) );
end;

function TK_FRADataDeliveryForm.ScanChildTree( UDParent: TN_UDBase;
    var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
    const FieldName: string ) : TK_ScanTreeResult;
begin
  if not ChBUseChilds.Checked then
//*** Skip Childs
    Result := K_tucSkipScan
  else if ChildInd = -1 then
//*** Skip References inside UDRArray
    Result := K_tucSkipSibling
  else begin
    Result := K_tucOK;
    SendValuesToObj( UDChild );
  end;
end;

procedure TK_FRADataDeliveryForm.FormDestroy(Sender: TObject);
begin
  inherited;
  MVNPList.Free;
  ETNPList.Free;
  CHPList.Free;
  ChangeObjsList.Free;
  ChangeObjRootsList.Free;
  FSLPaths.Free;
end;

procedure TK_FRADataDeliveryForm.ShowChangedObjsExecute(Sender: TObject);
var
  UDB : TN_UDBase;
  VNode : TN_VNode;
  i, j : Integer;
  LPath : string;
begin
  if ChangedObjsView then begin
    ChangedObjsView := false;
    VTreeFrame.RebuildVTree( UDRoot, MVNPList, ETNPList );
  end else begin
    ChangedObjsView := true;
    if ChangeObjsList.Count = 0 then begin
      StatusBar.SimpleText := 'Нет измененных объектов';
      Exit;
    end;

    VTreeFrame.VTree.GetExpandedPathStrings( ETNPList );


//*** Build Roots VNodes List
    if not ChangeObjRootsInds then begin
      ChangeObjRootsInds := true;
      UDB := nil;
      for i := 0 to ChangeObjRootsList.Count - 1 do begin
        if UDB = ChangeObjRootsList[i] then begin
          ChangeObjRootsList[i] := ChangeObjRootsList[i-1];
          Continue;
        end else begin
          UDB := ChangeObjRootsList[i];
          for j := 0 to MVNPList.Count - 2 do
            if TN_VNode(MVNPList.Objects[j]).VNUDObj = UDB then
              ChangeObjRootsList[i] := Pointer(j);
        end;
      end;
    end;

    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
//    K_UDRAFieldsScan := false;
    K_UDScannedUObjsList := Tlist.Create;

    CHPList.Clear;
    for i := 0 to ChangeObjsList.Count - 1 do begin
      j := Integer(ChangeObjRootsList[i]);
      VNode := TN_VNode( MVNPList.Objects[j] );
//      LPath := VNode.VNUDObj.GetPathToObj( TN_UDBase(ChangeObjsList[i] ) );
      LPath := K_GetPathToUObj( TN_UDBase(ChangeObjsList[i] ), VNode.VNUDObj );
      StatusBar.SimpleText := IntToStr(i);
      if LPath <> '' then LPath := K_udpPathDelim + LPath;
      CHPList.Add( MVNPList[j] + LPath );
      K_ClearUObjsScannedFlag();
    end;

    FreeAndNil(K_UDScannedUObjsList);
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
//    K_UDRAFieldsScan := true;

    with CHPList do Add( CHPList[Count-1] );
    VTreeFrame.RebuildVTree( UDRoot, CHPList );
    if ChBSkipFieldsReplace.Checked then
      StatusBar.SimpleText := 'Найдено'
    else
      StatusBar.SimpleText := 'Изменено';
    StatusBar.SimpleText := StatusBar.SimpleText + ' объектов - '+IntToStr(ChangeObjsList.Count)+
         ', полей - '+IntToStr(ChangeFieldsCount);
  end;
end;

procedure TK_FRADataDeliveryForm.ShowFiledsExecute(Sender: TObject);
begin
  PrepareFieldsList;
  K_GetFormTextEdit.EditStrings( FSLPaths, 'Список полей' );
end;

end.
