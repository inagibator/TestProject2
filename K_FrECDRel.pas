unit K_FrECDRel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ComCtrls, StdCtrls, ActnList,
  K_FrRaEdit, K_FrCDRel, K_FCDRelShow, K_CSpace, K_SCript1, K_UDT1, K_Types,
  N_Types, N_BaseF;

type
  TK_FrameECDRel = class(TFrame)
    FrRACDRel : TK_FrameCDRel;

    ActionList1: TActionList;
    SelectROperand : TAction;
    RUnion         : TAction;
    RIntersection  : TAction;
    RDifference    : TAction;
    RCProduction   : TAction;
    SetCorUDCSDim  : TAction;
    ClearCorUDCSdim: TAction;
    AddCDim        : TAction;

    LbIndsType: TLabel;

    CmBIndsType: TComboBox;

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
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButtonCorUDCSDim: TToolButton;
    ToolButton14: TToolButton;
    TBTranspGrid: TToolButton;
    TBRebuildGrid: TToolButton;

    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;
    procedure CmBIndsTypeChange(Sender: TObject);
    procedure SelectROperandExecute(Sender: TObject);
    procedure SetCorUDCSDimExecute(Sender: TObject);
    procedure ClearCorUDCSdimExecute(Sender: TObject);
    procedure RUnionExecute(Sender: TObject);
    procedure RCProductionExecute(Sender: TObject);
    procedure AddCDimExecute(Sender: TObject);
  private
    { Private declarations }
    CDFilter : TK_UDFilter;
    CSDFilter : TK_UDFilter;


    UseCurOrderInfo : Boolean;
    FormCDRel0 : TK_FormCDRelShow;

    FRACDRel : TK_RArray;

    OnRelDataChange : TK_NotifyProc;

    ROUDCSDim : TK_UDCSDim;
    procedure RelDataIsChanged;
    procedure ROActionsState;
//    procedure FormCDRelClose( Sender : TObject; ActionType : TK_RAFGlobalAction );
    function  FormCDRelClose( Sender : TObject; ActionType : TK_RAFGlobalAction ) : Boolean;

  public
    { Public declarations }
    SkipRelCorUDCSDimChange : Boolean;
    SkipRelTypeEdit         : Boolean;
    SkipRelEdit             : Boolean;
    SkipRelRowsEdit         : Boolean;

    SelectObjsUDRoot   : TN_UDBase;

    FCDRType : TK_CDRType;

    procedure ShowRACDRel( RACDRel : TK_RArray );
    procedure SetOnDataChangeProc( AOnDataChange: TK_NotifyProc );
    procedure GetReorderRowsInds( var RInds : TN_IArray; SkipOrderInfo : Boolean = false );
    procedure RemoveDuplicates;
    procedure SaveData;
  end;

implementation

uses
  K_CLib0, K_CLib, K_VFunc, K_UDT2,
  N_Lib0, N_ButtonsF, N_ClassRef;

{$R *.dfm}

{*** TK_FrameECDRel ***}

//*************************************** TK_FrameCDRel.Create
//
constructor TK_FrameECDRel.Create(AOwner: TComponent);
begin
  inherited;
  CDFilter := TK_UDFilter.Create;
  CDFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCDimCI ) );
  CDFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCSDimCI ) );
  CDFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCDRelCI ) );

  CSDFilter := TK_UDFilter.Create;
  CSDFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCDimCI ) );
  CSDFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCSDimCI ) );

  K_GetTypeCodeSafe( 'TK_CDRType' ).FD.GetFieldsDefValueList(
                          CmbIndsType.Items );
  CmbIndsType.Items.Delete(CmbIndsType.Items.Count - 1);
  FrRACDRel.SetOnDataChangeProc( RelDataIsChanged );


  ROActionsState;

  SetCorUDCSDim.Enabled := false;
  ClearCorUDCSDim.Enabled := false;
  SelectROperand.Enabled := false;
  AddCDim.Enabled := false;
  FrRACDRel.DelCol.Enabled := false;
  FrRACDRel.DelRow.Enabled := false;
  FrRACDRel.AddRow.Enabled := false;
  FrRACDRel.InsRow.Enabled := false;
end; //*** end of TK_FrameCDRel.Create

//*************************************** TK_FrameECDRel.Destroy
//
destructor TK_FrameECDRel.Destroy;
begin
  if FormCDRel0 <> nil then
    with FormCDRel0 do OnGlobalAction := nil;
  CDFilter.Free;
  CSDFilter.Free;
  inherited;
end; //*** end of TK_FrameECDRel.Destroy

//*************************************** TK_FrameECDRel.ShowRACDRel
//
procedure TK_FrameECDRel.ShowRACDRel( RACDRel: TK_RArray );
var
  PUDCDims : TN_PUDBase;
  UDCDimsCount : Integer;
  RelIsCSDim : Boolean;
begin
  SelectROperand.Enabled := not SkipRelEdit;
  AddCDim.Enabled := not SkipRelEdit;
  FrRACDRel.ReadOnlyMode := SkipRelEdit;
  FrRACDRel.SkipRelRowsEdit := SkipRelRowsEdit;

  UseCurOrderInfo := true;
//*** Set Relation Frame Info
  UDCDimsCount := K_GetRACDRelPUDCDims( RACDRel, PUDCDims );

  FRACDRel := RACDRel;
  CmBIndsType.ItemIndex := -1;

  FCDRType := K_cdrList;
  RelIsCSDim := false;

  with RACDRel do begin
    if RACDRel <> nil then begin
      FCDRType := TK_PCDRelAttrs(PA).CDRType;
      RelIsCSDim := AttrsSize < SizeOf(TK_CDRelAttrs);
      FrRACDRel.SkipUDCDimsCountChange := RelIsCSDim; // TK_CSDim (not TK_CDRel)
    end;
    FrRACDRel.ShowRACDRel( PUDCDims, UDCDimsCount, P, ARowCount, K_GetRACDRelUDCSDim(RACDRel) );
  end;
  if FrRACDRel.UDRelCSDim <> nil then
    ToolButtonCorUDCSDim.Action := ClearCorUDCSDim
  else
    ToolButtonCorUDCSDim.Action := SetCorUDCSDim;

  CmBIndsType.ItemIndex := Ord(FCDRType);
  CmBIndsType.Enabled := (FRACDRel <> nil)            and
                         not SkipRelTypeEdit          and
                         (FrRACDRel.UDRelCSDim = nil) and
                         not SkipRelEdit;

  SetCorUDCSDim.Enabled := not SkipRelCorUDCSDimChange and
                           FrRACDRel.AddRow.Enabled and
                           not RelIsCSDim;
  ClearCorUDCSDim.Enabled := not SkipRelCorUDCSDimChange and not RelIsCSDim;

  //*** Set Actions.Enabled false if Empty Relation is opend
  SelectROperand.Enabled := SelectROperand.Enabled and FrRACDRel.AddRow.Enabled;
  FrRACDRel.DelCDim.Enabled := FrRACDRel.AddRow.Enabled and not RelIsCSDim;
  SelectROperand.Enabled := SelectROperand.Enabled and not RelIsCSDim;
  AddCDim.Enabled := AddCDim.Enabled and not RelIsCSDim;

end; //*** end of TK_FrameECDRel.ShowRACDRel

//*************************************** TK_FrameECDRel.CmBIndsTypeChange
//
procedure TK_FrameECDRel.CmBIndsTypeChange(Sender: TObject);
var
  WCDRType : TK_CDRType;
begin
  if Ord(FCDRType) = CmBIndsType.ItemIndex then Exit;
  WCDRType := FCDRType;
  FCDRType := TK_CDRType(CmBIndsType.ItemIndex);
  if WCDRType <> K_cdrList then RemoveDuplicates;
  RelDataIsChanged;
end; //*** end of TK_FrameECDRel.CmBIndsTypeChange

//*************************************** TK_FrameECDRel.SelectROperandExecute
//
procedure TK_FrameECDRel.SelectROperandExecute(Sender: TObject);
var
  NewCDObj : TN_UDBase;

begin
  //*** Select New Relation Source
  NewCDObj := ROUDCSDim;
  if SelectObjsUDRoot = nil then SelectObjsUDRoot := K_CurArchive;
  if not K_SelectUDNode( NewCDObj, SelectObjsUDRoot, CDFilter.UDFTest,
    'Выбор источника отношения', true  ) or
    (NewCDObj = nil) then Exit;
  if NewCDObj is TK_UDCDim then
    NewCDObj := TK_UDCDim(NewCDObj).FullCSDim;

  //*** Prepare ShowForm
  if FormCDRel0 = nil then
    FormCDRel0 := K_GetFormCDRelShow( K_GetOwnerBaseForm( Self ) );

  //*** Show Relation operand
  if (NewCDObj <> ROUDCSDim) then
  with FormCDRel0 do begin
    OnGlobalAction := FormCDRelClose;
    FrameCDRel.ReadOnlyMode := true;
    ShowUDCDRel( TK_UDCSDim(NewCDObj), NewCDObj.GetUName );
    Show;
  end;
  ROUDCSDim := TK_UDCSDim(NewCDObj);
  ROActionsState;
end; //*** end of TK_FrameECDRel.SelectROperandExecute

//*************************************** TK_FrameECDRel.SetCorUDCSDimExecute
//
procedure TK_FrameECDRel.SetCorUDCSDimExecute(Sender: TObject);
var
  NewCDObj : TN_UDBase;
  NCount, CCount : Integer;
  AttrsCapts : TN_SArray;
begin
  //*** Select New Relation Corresponding CSDim
  NewCDObj := nil;
  if SelectObjsUDRoot = nil then SelectObjsUDRoot := K_CurArchive;
  if not K_SelectUDNode( NewCDObj, SelectObjsUDRoot, CSDFilter.UDFTest,
    'Выбор подизмерения для связки отношения', true  ) or
    (NewCDObj = nil) then Exit;
  if NewCDObj is TK_UDCDim then
    NewCDObj := TK_UDCDim(NewCDObj).FullCSDim;
  with FrRACDRel do begin
    UDRelCSDim := TK_UDCSDim(NewCDObj);

    //*** Change Relation Rows
    NCount := UDRelCSDim.ALength;
    CCount := GetDataBufRow;

    if NCount > CCount then
      FrInsertRows( 0, NCount - CCount )
    else if NCount < CCount then
      FrDeleteRows( NCount + 1, CCount - NCount )
    else
      RelDataIsChanged; // Only Set Change Flag if Relation Current RowCount Equal UDRelCSDim Count
    CDescr.ModeFlags := BuildFrameFlags;
    //*** Get Captions From CDim Attrs
    GetRelCSDimCapts( AttrsCapts );
    //*** Copy Captions From Buffer to Frame Captions Array
    SetLength( RowCaptions, RelIndsBuf.ARowCount );
    K_MoveSPLVectorByDIndex( RowCaptions[0], SizeOf(string),
       AttrsCapts[0], SizeOf(string),
       NCount, Ord(nptString), [], GetPRowIndex );
    RebuildGridInfo();
  end;
  ToolButtonCorUDCSDim.Action := ClearCorUDCSDim;
  CmBIndsType.ItemIndex := Ord(K_cdrBag);
  FCDRType := K_cdrBag;
  CmBIndsType.Enabled := false;
end; //*** end of TK_FrameECDRel.SetCorUDCSDimExecute

//*************************************** TK_FrameECDRel.ClearCorUDCSdimExecute
//
procedure TK_FrameECDRel.ClearCorUDCSdimExecute(Sender: TObject);
begin
  ToolButtonCorUDCSDim.Action := ClearCorUDCSDim;
  with FrRACDRel do begin
    UDRelCSDim := nil;
    CDescr.ModeFlags := FrRACDRel.BuildFrameFlags;
    RowCaptions := nil;
    SetLength( RowCaptions, RelIndsBuf.ARowCount );
    RebuildGridInfo();
  end;
  RelDataIsChanged;
  ToolButtonCorUDCSDim.Action := SetCorUDCSDim;
  CmBIndsType.Enabled := true;
end; //*** end of TK_FrameECDRel.ClearCorUDCSdimExecute

//*************************************** TK_FrameECDRel.RUnionExecute
//  Add Operand Relation Selection to CurRelation
//
procedure TK_FrameECDRel.RUnionExecute(Sender: TObject);
var
  PUDCDims, PROUDCDims : TN_PUDBase;
  UDCDimsCount : Integer;
  PInds : PInteger;
  ROUDCDimsInds : TN_IArray;
  CrossCount : Integer;
  SInd, SCount : Integer;
  SRInd, SRCount : Integer;
  i, SSInd : Integer;

  Label LExit;

begin
//*** Get CurCDRel UDCDims Info
  PUDCDims := FrRACDRel.RelCDimsBuf.P;
  UDCDimsCount := FrRACDRel.GetDataBufCol;
  PInds := FrRACDRel.GetPColIndex;

//*** Set CurCDRel UDCDims Info to Marker
  K_MarkRAUDCDims( PUDCDims, UDCDimsCount, PInds );

  with FormCDRel0.FrameCDRel do begin
//*** Get RO Selection Info
    GetSelectSection( false,  SInd, SCount );
    GetSelectSection( true,  SRInd, SRCount );
    if (SCount = 0) or (SCount = 0) then begin
      K_ShowMessage( 'Не выбрано подмножество отношения источника для объединения' );
      goto LExit;
    end;

//*** Build Cross Indices
    SetLength( ROUDCDimsInds, SCount );
    PROUDCDims := TN_PUDBase(RelCDimsBuf.P);
//    Inc(PROUDCDims, SCount);
    CrossCount := K_BuildCrossIndsRAUDCDims( @ROUDCDimsInds[0], PROUDCDims, SCount );
    if CrossCount = 0 then begin
      K_ShowMessage( 'Измерения выбранного подмножества не имеют пересечения с измерениями редактируемого отношения' );
      goto LExit;
    end;

//*** Build Union of CurCDRel and RO Selection
//  Add new Relation Elements
    SSInd := FrRACDRel.RelIndsBuf.ARowCount;
    FrRACDRel.FrInsertRows( 0, SRCount );

//  Move Indices Loop
    Dec(SRInd);
    for i := SRInd to SRCount + SRInd - 1 do begin
      K_MoveVectorByDIndex( FrRACDRel.RelIndsBuf.PME(0, SSInd)^, SizeOf(Integer),
                          RelIndsBuf.PME(0, i)^, SizeOf(Integer), SizeOf(Integer),
                          SCount, @ROUDCDimsInds[0] );
      Inc(SSInd);
    end;

  end;

  RemoveDuplicates;

LExit:
//*** Clear CurCDRel UDCDims Info from Marker
  K_UnMarkRAUDCDims( PUDCDims, UDCDimsCount, PInds );

end; //*** end of TK_FrameECDRel.RUnionExecute

//*************************************** TK_FrameECDRel.RCProductionExecute
//  Add Cartesian Production of Operand Relation Selection and CurRelation Selection
//
procedure TK_FrameECDRel.RCProductionExecute(Sender: TObject);
var
  SInd, SCount : Integer;
  SRInd, SRCount : Integer;
  i, j, SSInd, STCount, STInd, SSCInd, WSSInd : Integer;
  BCount, SBCount : Integer;

begin
  with FrRACDRel do
    GetSelectSection( true,  STInd, STCount );
  if STCount = 0 then begin
    K_ShowMessage( 'Не выбрано подмножество элементов отношения для произведения' );
    Exit;
  end;

  with FormCDRel0.FrameCDRel do begin
//*** Get RO Selection Info
    GetSelectSection( false,  SInd, SCount );
    GetSelectSection( true,  SRInd, SRCount );
    if (SCount = 0) or (SCount = 0) then begin
      K_ShowMessage( 'Не выбрано подмножество отношения источника для произведения' );
      Exit;
    end;


//*** Add Cartesian Production of CurCDRel and RO Selection
// Add New Relation Columns
    SSCInd := FrRACDRel.RelCDimsBuf.ALength;
    FrRACDRel.FrInsertCols( 0, SCount );
    BCount := SCount * SizeOf(TN_UDBase);
    Move( RelCDimsBuf.P(SInd - 1)^, FrRACDRel.RelCDimsBuf.P( SSCInd )^, BCount );
    FrRACDRel.InitNewCols( SSCInd );

//  Add new Relation Rows
    SSInd := FrRACDRel.RelIndsBuf.ARowCount;
    FrRACDRel.FrInsertRows( 0, SRCount * STCount );

//  Fill New Elems with Cartesian Production Loop
    Dec(SRInd);
    Dec(STInd);
    WSSInd := SSInd;
    SBCount := SSCInd * SizeOf(Integer);
    for i := SRInd to SRInd + SRCount - 1 do begin
      for j := STInd to STInd + STCount - 1 do begin
        Move( FrRACDRel.RelIndsBuf.PME(0, j)^, FrRACDRel.RelIndsBuf.PME( 0, WSSInd )^, SBCount );
        Move( RelIndsBuf.PME(SInd - 1,i)^, FrRACDRel.RelIndsBuf.PME( SSCInd, WSSInd )^, BCount );
        Inc(WSSInd);
      end;
//      Inc(SRInd);
    end;

  end;

//  Remove Duplicates if Needed
  RemoveDuplicates;

end; //*** end of TK_FrameECDRel.RCProductionExecute

//***********************************  TK_FrameECDRel.AddCDimExecute
// Change CDimInds Object State
//
procedure TK_FrameECDRel.AddCDimExecute(Sender: TObject);
begin
  FrRACDRel.AddCDimExecute( Sender );
  SetCorUDCSDim.Enabled := true;
  ClearCorUDCSDim.Enabled := true;
  SelectROperand.Enabled := true;
end; // end of procedure TK_FrameECDRel.AddCDimExecute

//*************************************** TK_FrameECDRel.ROActionsState
//
procedure TK_FrameECDRel.ROActionsState;
var
  State : Boolean;
begin
  State := FormCDRel0 <> nil;
  RUnion.Enabled := State;
  RIntersection.Enabled := State;
  RDifference.Enabled := State;
  RCProduction.Enabled := State;
end; //*** end of TK_FrameECDRel.ROActionsState

//*************************************** TK_FrameECDRel.FormCDRelClose
//
//procedure TK_FrameECDRel.FormCDRelClose( Sender : TObject; ActionType : TK_RAFGlobalAction );
function TK_FrameECDRel.FormCDRelClose( Sender : TObject; ActionType : TK_RAFGlobalAction ) : Boolean;
begin
  Result := true;
  FormCDRel0 := nil;
  ROActionsState;
end; //*** end of TK_FrameECDRel.FormCDRelClose

//*************************************** TK_FrameECDRel.RelDataIsChanged
//
procedure TK_FrameECDRel.RelDataIsChanged;
begin
  if Assigned(OnRelDataChange) then OnRelDataChange();
end; //*** end of TK_FrameECDRel.RelDataIsChanged

//*************************************** TK_FrameECDRel.SetOnDataChangeProc
//
procedure TK_FrameECDRel.SetOnDataChangeProc( AOnDataChange: TK_NotifyProc );
begin
  OnRelDataChange := AOnDataChange;
end; //*** end of TK_FrameECDRel.SetOnDataChangeProc

//*************************************** TK_FrameECDRel.GetReorderRowsIndis
//  Get Reorder Relation Rows Indices
//
procedure TK_FrameECDRel.GetReorderRowsInds( var RInds: TN_IArray; SkipOrderInfo : Boolean = false );
var
  NRows : Integer;

begin
  NRows := FrRACDRel.GetDataBufRow;
  SetLength( RInds, NRows );
  if NRows = 0 then Exit;
  if UseCurOrderInfo and not SkipOrderInfo then
    Move( FrRACDRel.GetPRowIndex^, RInds[0], NRows * SizeOf(Integer) )
  else
    K_FillIntArrayByCounter( @RInds[0], NRows, SizeOf(Integer) );
end; //*** end of TK_FrameECDRel.GetReorderRowsIndis

//*************************************** TK_FrameECDRel.RemoveDuplicates
//
procedure TK_FrameECDRel.RemoveDuplicates;
var
  CSortIndsBuf, DelIndsBuf : TN_IArray;
  CompareFunc: TN_CompFuncOfObj;
  PPArray : TN_PArray;
  NCol, NRow : Integer;
  PElem0, PInds : Pointer;
  IndsElemSize : Integer;
  i, j : Integer;

begin
//*** Build Orderd Index
  PPArray := nil;
  if FCDRType <> K_cdrList then Exit;

  N_CFuncs.Offset := 0;
  N_CFuncs.DescOrder := false;
  NCol := FrRACDRel.GetDataBufCol;
  N_CFuncs.NumFields := NCol;
  CompareFunc := N_CFuncs.CompNInts;
  if N_CFuncs.NumFields = 1 then
    CompareFunc := N_CFuncs.CompOneInt;

  PElem0 := FrRACDRel.RelIndsBuf.P;
  IndsElemSize := NCol * SizeOf(Integer);

  NRow := FrRACDRel.GetDataBufRow;
  if NRow = 0 then Exit;

  PInds := FrRACDRel.GetPRowIndex;
  PPArray := N_ElemIndsToPtrsArray( PElem0, IndsElemSize, PInds, NRow );
  N_SortPointers( PPArray, CompareFunc );
  SetLength( CSortIndsBuf, NRow );
  N_PtrsArrayToElemInds( @CSortIndsBuf[0], PPArray, PElem0, IndsElemSize );
  j := FrRACDRel.RelIndsBuf.ALength;
  SetLength( DelIndsBuf, j );
  K_BuildFullIndex( PInds, NRow, @DelIndsBuf[0], j, K_BuildFullBackIndexes );
  K_MoveVectorBySIndex( CSortIndsBuf[0], SizeOf(Integer),
                      DelIndsBuf[0], SizeOf(Integer), SizeOf(Integer),
                      NRow, @CSortIndsBuf[0] );

//*** Build List of Rows which must be Deleted
  SetLength( DelIndsBuf, NRow );
  FillChar( DelIndsBuf[0], NRow * SizeOf(Integer), -1 );
  for i := High(CSortIndsBuf) downto 1 do
    if CompareFunc(PPArray[i], PPArray[i-1]) = 0 then
      DelIndsBuf[CSortIndsBuf[i]] := 0;
//*** Remove Equal Relation Elements
  j := -1;
  for i := High(DelIndsBuf) downto 0 do
    if DelIndsBuf[i] = 0 then begin
      if j < 0 then j := i;
    end else begin
      if j >= 0 then
        FrRACDRel.FrDeleteRows( i + 2, j - i );
      j := -1;
    end;
  if j >= 0 then
    FrRACDRel.FrDeleteRows( 1, j + 1 );
end; //*** end of TK_FrameECDRel.RemoveDuplicates

//***********************************  TK_FrameECDRel.SaveData
// Change CDimInds Object State
//
procedure TK_FrameECDRel.SaveData;
var
  RCount, CCount : Integer;
  PUDCDims : TN_PUDBase;
  PRelInds : PInteger;
begin
  if FRACDRel = nil then Exit;
  with FRACDRel, TK_PCDRelAttrs(PA)^ do begin
  // Relation Type
    CDRType := FCDRType;
    K_FreeRACDRelCDims( FRACDRel, false );
    CCount := FrRACDRel.GetPUDCDims( PUDCDims );
    RCount := FrRACDRel.GetPRelInds( PRelInds );
    ASetLength( CCount, RCount );
  // Relation UDCDims
    K_AddUDCDimsToRACDRel( FRACDRel, PUDCDims, CCount, SizeOf(TN_UDBase) );
  // Relation Inds
    Move( PRelInds^, P^, CCount * RCount * SizeOf(Integer) );
    K_SetUDRefField( CUDCSDim, FrRACDRel.UDRelCSDim, (FEType.D.CFlags and K_ccCountUDRef) <> 0 );
  end;
end; // end of procedure TK_FrameECDRel.SaveData

{*** end of TK_FrameECDRel ***}

end.
