unit K_FrCSDim2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ActnList,
  N_Types,
  K_FrCSDim1, K_FrRaEdit, K_Script1, K_CSpace, K_UDT1, K_Types;

type
  TK_FrameCSDim2 = class(TK_FrameCSDim1)
    BBtnDel: TButton;
    BBtnAdd: TBitBtn;
    K_FrameRAEditSS: TK_FrameRAEdit;
    ActionList1: TActionList;
    AddCSDimItem: TAction;
    BBtnAddAll: TBitBtn;
    BBtnDelAll: TButton;
    AddAllCSDItems: TAction;
    DelAllCSDItems: TAction;
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;
    procedure BBtnAddClick(Sender: TObject);
    procedure AddCSDimItemExecute(Sender: TObject);
    procedure AddAllCSDItemsExecute(Sender: TObject);
    procedure DelAllCSDItemsExecute(Sender: TObject);
  private
    { Private declarations }
    CDSBackInds : TN_IArray;
    SpaceIndex : Integer;
    procedure OnAddDataRow( ACount : Integer = 1 );
    procedure OnSampleRowsDel( FromIndex, Number : Integer );
  public
    { Public declarations }
    procedure ShowCDim( UDCDim : TK_UDRArray; PCDSrcInds : PInteger = nil;
                        CDSrcIndsCount : Integer = -1 ); override;
    procedure ShowCDimInds( ACDIType : TK_CDRType; PInds : PInteger;
                            IndsCount : Integer; UDCDim : TN_UDBase;
                            PCDSrcInds : PInteger = nil;
                            CDSrcIndsCount : Integer = -1  );override;
    procedure SetOnDataChange ( AOnDataChange : TK_NotifyProc );override;
    procedure GetCSDim( var CDSInd : TN_IArray );override;
  end;

var
  K_FrameCSDim2: TK_FrameCSDim2;

implementation

uses Math, Grids,
  K_VFunc;
{$R *.dfm}

{*** TK_FrameCSDim2 ***}
//***********************************  TK_FrameCSDim2.Create  ******
//
constructor TK_FrameCSDim2.Create( AOwner: TComponent );
begin
  inherited;
  FormDescr := K_CreateSPLClassByName( 'TK_FormCSDim', [] );
  DDType := K_GetTypeCodeSafe( 'TK_CSDimEdit' );
  Inc( DDType.D.TFlags, K_ffArray );
  AModeFlags := [K_ramColVertical, K_ramReadOnly, K_ramSkipResizeWidth,
                 K_ramOnlyEnlargeSize, K_ramSkipRowMoving];
  K_RAFColsPrepByRADataFormDescr(
      RAFCArray, @FrDescr, AModeFlags, DDType, FormDescr );

//*** Prepare SubSpace Buffer
  SDIndsBuf := TK_RArray.CreateByType( Ord(nptInt) );

  K_FrameRAEditS.SetGridInfo( AModeFlags, RAFCArray, FrDescr, 0,  nil,
                                                  nil, nil );
  AModeFlags := [K_ramRowChangeOrder, K_ramRowChangeNum, K_ramColVertical,
                 K_ramSkipResizeWidth, K_ramOnlyEnlargeSize];
  K_FrameRAEditSS.SetGridInfo( AModeFlags, RAFCArray, FrDescr, 0,  nil,
                                                  nil, nil );
  K_FrameRAEditSS.OnRowsAdd := OnAddDataRow;
  K_FrameRAEditSS.OnRowsDel := OnSampleRowsDel;

end; // end of TK_FrameCSDim2.Create

//***********************************  TK_FrameCSDim2.Destroy
//
destructor TK_FrameCSDim2.Destroy;
begin
  K_FrameRAEditSS.FreeContext;
  inherited;
end; // end of TK_FrameCSDim2.Destroy

//***********************************  TK_FrameCSDim2.ShowCDim
//
procedure TK_FrameCSDim2.ShowCDim( UDCDim : TK_UDRArray; PCDSrcInds : PInteger = nil;
                        CDSrcIndsCount : Integer = -1 );
begin
  FPCDSrcInds := PCDSrcInds;
  FCDSrcIndsCount := CDSrcIndsCount;

  with TK_PCDim(UDCDim.R.P)^ do begin
//*** prepare editing
    if CDSrcIndsCount = -1 then CDSrcIndsCount := CDCodes.ALength;
    K_FrameRAEditS.SetGridLRowsNumber(  CDSrcIndsCount );

    K_FrameRAEditS.SetDataPointersFromColumnRArrays(
                          CDCodes, FPCDSrcInds, FCDSrcIndsCount );
  end;
  K_FrameRAEditS.SGrid.Invalidate;


  K_FrameRAEditSS.SetGridLRowsNumber(  0 );
  K_FrameRAEditSS.SGrid.Invalidate;
  K_FrameRAEditSS.DelRow.Enabled := false;
end; // end of procedure TK_FrameCSDim2.ShowCDim

//***********************************  TK_FrameCSDim2.SetOnDataChange
//
procedure TK_FrameCSDim2.SetOnDataChange( AOnDataChange: TK_NotifyProc );
begin
  K_FrameRAEditSS.OnDataChange := AOnDataChange;
end; // end of TK_FrameCSDim2.SetOnDataChange

//***********************************  TK_FrameCSDim2.ShowCDimInds
//
procedure TK_FrameCSDim2.ShowCDimInds( ACDIType : TK_CDRType; PInds : PInteger;
                            IndsCount : Integer; UDCDim : TN_UDBase;
                            PCDSrcInds : PInteger = nil;
                            CDSrcIndsCount : Integer = -1 );
var
  ElemCount : Integer;

begin
  SA.CDim := UDCDim;
  SA.CDIType := ACDIType;

  ShowCDim( TK_UDRArray(SA.CDim), PCDSrcInds, CDSrcIndsCount );

  K_FrameRAEditSS.ModeFlags := K_FrameRAEditSS.ModeFlags
                  + [K_ramRowChangeOrder, K_ramRowChangeNum]
                  - [K_ramReadOnly, K_ramSkipRowMoving];
  K_FrameRAEditSS.DelRow.Enabled := true;

  K_FrameRAEditSS.RebuildGridInfo;

  with TK_PCDim( TK_UDRArray(SA.CDim).R.P )^ do begin
//*** Prepare CDimSample Buffer
    ElemCount := IndsCount;
    SDIndsBuf.ASetLength( ElemCount );

    SDIndsBuf.SetElems( PInds^, false );
//*** Prepare CDimSample Frame
    K_FrameRAEditSS.SetGridLRowsNumber( ElemCount );
    K_FrameRAEditSS.SetDataPointersFromColumnRArrays( CDCodes, PInds, ElemCount );
    CDSBackInds := TK_UDCDim(SA.CDim).FullIndsArray;
    K_BuildBackIndex0( PInds, ElemCount, @CDSBackInds[0], Length(CDSBackInds) );
  end;
  K_FrameRAEditSS.SGrid.Invalidate;

end; // end of procedure TK_FrameCSDim2.ShowCDimInds

//***********************************  TK_FrameCSDim2.GetCSDim
// Add Row to BufData
//
procedure TK_FrameCSDim2.GetCSDim( var CDSInd : TN_IArray );
var
  i, h : Integer;
begin
  with K_FrameRAEditSS do begin
    h := GetDataBufRow;
    SetLength( CDSInd, h );
    for i := 0 to h - 1 do
      CDSInd[i] := PInteger(SDIndsBuf.P(GetDataBufRow(i)))^;
  end;
end; // end of procedure TK_FrameCSDim2.GetCSDim

//***********************************  TK_FrameCSDim2.OnSampleRowsDel
// Del Rows
//
procedure TK_FrameCSDim2.OnSampleRowsDel(FromIndex, Number: Integer);
var
  i, n : Integer;
begin
  Dec(FromIndex);
  for i := FromIndex to FromIndex + Number - 1 do begin
    n := PInteger(SDIndsBuf.P(K_FrameRAEditSS.GetDataBufRow(i)))^;
    CDSBackInds[n] := -1;
  end;
end; // end of procedure TK_FrameCSDim2.OnSampleRowsDel

//***********************************  TK_FrameCSDim2.OnAddDataRow
// Add Row to BufData
//
procedure TK_FrameCSDim2.OnAddDataRow( ACount : Integer = 1 );
var
  Ind : Integer;
begin
  with SDIndsBuf do begin
    Ind := ALength;
    ASetLength( Ind + 1 );
    PInteger( P( Ind ) )^ := SpaceIndex;
  end;
  DelAllCSDItems.Enabled := true;
end; // end of procedure TK_FrameCSDim2.OnAddDataRow

//***********************************  TK_FrameCSDim2.AddCSDimItemExecute
// Add Item to CSDim
//
procedure TK_FrameCSDim2.AddCSDimItemExecute(Sender: TObject);
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
      if (CDSBackInds[SpaceIndex] < 0) or
         (SA.CDIType = K_cdrBag) then begin
        CDSBackInds[SpaceIndex] := 0; // Set CDim Index is Busy flag
        AddRowExecute(nil);
        MInd := High(DataPointers);
        DataPointers[MInd][0] :=
          K_FrameRAEditS.DataPointers[SpaceIndex][0];
        DataPointers[MInd][1] :=
          K_FrameRAEditS.DataPointers[SpaceIndex][1];
      end;
      Inc(SpaceIndex);
    end;
    SelectLRect(-1, SInd );
  end;
end; // end of procedure TK_FrameCSDim2.AddCSDimItemExecute

//***********************************  TK_FrameCSDim2.BBtnAddClick
// Add Row to BufData
//
procedure TK_FrameCSDim2.BBtnAddClick(Sender: TObject);
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
      if (CDSBackInds[SpaceIndex] < -1) or
         (SA.CDIType = K_cdrBag) then begin
        CDSBackInds[SpaceIndex] := 0; // Set CDim Index is Busy flag
        AddRowExecute(nil);
        MInd := High(DataPointers);
        DataPointers[MInd][0] :=
          K_FrameRAEditS.DataPointers[SpaceIndex][0];
        DataPointers[MInd][1] :=
          K_FrameRAEditS.DataPointers[SpaceIndex][1];
      end;
      Inc(SpaceIndex);
    end;
    SelectLRect(-1, SInd );
  end;
end; // end of procedure TK_FrameCSDim2.BBtnAddClick

//***********************************  TK_FrameCSDim2.AddCSDimItemExecute
// Add All Items to CSDim
//
procedure TK_FrameCSDim2.AddAllCSDItemsExecute(Sender: TObject);
begin
  K_FrameRAEditS.SelectLRect();
  AddCSDimItemExecute(Sender)
end; // end of procedure TK_FrameCSDim2.BBtnAddClick

//***********************************  TK_FrameCSDim2.DelAllCSDItemsExecute
// Delete All Items from CSDim
//
procedure TK_FrameCSDim2.DelAllCSDItemsExecute(Sender: TObject);
begin
  K_FrameRAEditSS.SelectLRect();
  K_FrameRAEditSS.DelRowExecute( Sender );
  DelAllCSDItems.Enabled := false;
end; // end of procedure TK_FrameCSDim2.BBtnAddClick


end.
