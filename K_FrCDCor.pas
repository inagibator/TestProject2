unit K_FrCDCor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ActnList,
  N_Types,
  K_Script1, K_FrRaEdit, K_CSpace, K_UDT1, K_Types;

type
  TK_FrameCDCor = class(TFrame)
    BBtnAdd: TBitBtn;
    BBtnDel: TBitBtn;
    K_FrameRAEditSec: TK_FrameRAEdit;
    K_FrameRAEditPrim: TK_FrameRAEdit;

    ActionList1: TActionList;
    AddItems: TAction;
    DelItems: TAction;
    BBtAddAll: TBitBtn;
    BBtDelAll: TBitBtn;
    AddAllItems: TAction;
    DelAllItems: TAction;

    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;
    procedure AddItemsExecute(Sender: TObject);
    procedure DelItemsExecute(Sender: TObject);
    procedure AddAllItemsExecute(Sender: TObject);
    procedure DelAllItemsExecute(Sender: TObject);
  private
    { Private declarations }
    DDType : TK_ExprExtType;
    FormDescrPrim, FormDescrSec : TK_UDRArray;
    RAFCArrayPrim, RAFCArraySec : TK_RAFCArray;
    FrDescrPrim, FrDescrSec : TK_RAFrDescr;
    AModeFlags : TK_RAModeFlagSet;
    UDCDimSec : TK_UDCDim;
    UDCDimPrim : TK_UDCDim;
  public
    { Public declarations }
    procedure SetOnDataChange ( AOnDataChange : TK_NotifyProc ); virtual;
    procedure ShowCDCorInfo( PrimCDim : TN_UDBase; PPrimInds : PInteger;
                            SecCDim : TN_UDBase; PSecInds : PInteger; RelCount : Integer );
    procedure GetSecCSDim( var CDSInd : TN_IArray );
  end;

implementation

uses Math, Grids,
  K_VFunc;

{$R *.dfm}

//***********************************  TK_FrameCDCor.Create  ******
//
constructor TK_FrameCDCor.Create( AOwner: TComponent );
begin
  inherited;
//*** prepare editing
  FormDescrSec := K_CreateSPLClassByName( 'TK_FormCSDim', [] );
//*** Prepare Source Space Frame
  DDType := K_GetTypeCodeSafe( 'TK_CSDimEdit' );

  AModeFlags := [K_ramColVertical, K_ramReadOnly, K_ramSkipResizeWidth,
                 K_ramOnlyEnlargeSize, K_ramSkipRowMoving];
  K_RAFColsPrepByRADataFormDescr(
      RAFCArraySec, @FrDescrSec, AModeFlags, DDType, FormDescrSec );

  K_FrameRAEditSec.SetGridInfo( AModeFlags, RAFCArraySec, FrDescrSec, 0,  nil,
                                                  nil, nil );

//*** Prepare Dest Space Frame
  FormDescrPrim := K_CreateSPLClassByName( 'TK_FormCDCor', [] );

  DDType := K_GetTypeCodeSafe( 'TK_CDCorEdit' );
  K_RAFColsPrepByRADataFormDescr(
      RAFCArrayPrim, @FrDescrPrim, AModeFlags, DDType, FormDescrPrim );

  K_FrameRAEditPrim.SetGridInfo( AModeFlags, RAFCArrayPrim, FrDescrPrim, 0, nil,
                                                  nil, nil );

end; // end of TK_FrameCDCor.Create

//***********************************  TK_FrameCDCor.Destroy
//
destructor TK_FrameCDCor.Destroy;
begin
  K_FrameRAEditPrim.FreeContext;
  K_FrameRAEditSec.FreeContext;
  FormDescrPrim.Free;
  FormDescrSec.Free;
  K_FreeSPLData( FrDescrSec, K_GetFormCDescrDType.All );
  K_FreeSPLData( FrDescrPrim, K_GetFormCDescrDType.All );
  K_FreeColumnsDescr( RAFCArraySec );
  K_FreeColumnsDescr( RAFCArrayPrim );
  inherited;
end; // end of TK_FrameCDCor.Destroy

//***********************************  TK_FrameCDCor.AddItemsExecute
//
procedure TK_FrameCDCor.AddItemsExecute(Sender: TObject);
var
  GRS, GRD : TGridRect;
  IndS, IndD, Leng : Integer;
begin
 if not BBtnAdd.Enabled then Exit;
  GRS := K_FrameRAEditSec.SGrid.Selection;
  GRS.Top := Max( GRS.Top, 1 );
  GRD := K_FrameRAEditPrim.SGrid.Selection;
  GRD.Top := Max( GRD.Top, 1 );
  IndS := GRS.Top - 1;
  IndD := GRD.Top - 1;
  with K_FrameRAEditPrim do begin
    Leng := Length(DataPointers);
    while (IndS < GRS.Bottom) and (IndD < Leng) do begin // move data
        DataPointers[IndD][0] :=
          K_FrameRAEditSec.DataPointers[IndS][0];
        DataPointers[IndD][1] :=
          K_FrameRAEditSec.DataPointers[IndS][1];
      Inc(IndS);
      Inc(IndD);
      AddChangeDataFlag;
    end;
    SGrid.Invalidate;
  end;
end; // end of TK_FrameCDCor.AddItemsExecute

//***********************************  TK_FrameCDCor.DelItemsExecute
//
procedure TK_FrameCDCor.DelItemsExecute(Sender: TObject);
var
  GR : TGridRect;
  LPos1, LPos2 : TK_GridPos;
begin
  if not BBtnDel.Enabled then Exit;
  with K_FrameRAEditPrim do begin
    GR := SGrid.Selection;
    GR.Top := Max( GR.Top, 1 );
    GR.Left := Max( GR.Left, 1 );
    LPos1 := ToLogicPos(GR.Left, GR.Top);
    LPos2 := ToLogicPos(GR.Right, GR.Bottom);
    Dec( Lpos2.Row, LPos1.Row - 1 );
    if Lpos2.Row > 0 then begin
      ClearDataPointers( 0, LPos1.Row, 2, Lpos2.Row );
      AddChangeDataFlag;
      SGrid.Invalidate;
    end;
  end;
end; // end of TK_FrameCDCor.DelItemsExecute

//***********************************  TK_FrameCDCor.DelItemsExecute
//
procedure TK_FrameCDCor.SetOnDataChange( AOnDataChange: TK_NotifyProc );
begin
  K_FrameRAEditPrim.OnDataChange := AOnDataChange;
end; // end of TK_FrameCDCor.SetOnDataChange

//***********************************  TK_FrameCDCor.GetSecCSDim
// Get Current Secondary CSDim
//
procedure TK_FrameCDCor.GetSecCSDim( var CDSInd : TN_IArray );
var
  i, h : Integer;
  SArray : TN_SArray;
  CDimRAAttrs : TK_CDimRAAttrs;
begin
  with K_FrameRAEditPrim do begin
    h := Length(DataPointers);
    //*** Build Array of Secondary CSDim Codes
    SetLength( SArray, h );
    for i := 0 to h - 1 do
      if DataPointers[i][0] = nil then
        SArray[i] := ''
      else
        SArray[i] := PString(DataPointers[i][0])^;
    //*** Build Array of Secondary CSDim from Codes
    SetLength( CDSInd, h );
    if h = 0 then Exit;
{
    with TK_PCDim(UDCDimSec.R.P)^ do
      K_SCIndexFromSCodes( @CDSInd[0],
          @SArray[0], h,
          PString(CDCodes.P), CDCodes.ALength );
}
    with UDCDimSec do begin
      GetCDimRAAttrsInfo( CDimRAAttrs, nil, Ord(K_cdiCode) );
      K_SCIndexFromSCodes( @CDSInd[0],
          @SArray[0], h,
          CDimRAAttrs.PAData, CDimCount );
//          GetItemInfoPtr( K_cdiCode, 0 ), CDimCount );
    end;
  end;
end; // end of procedure TK_FrameCDCor.GetSecCSDim

//***********************************  TK_FrameCDCor.ShowCDCorInfo
// Add Row to BufData
//
procedure TK_FrameCDCor.ShowCDCorInfo( PrimCDim: TN_UDBase;
                                PPrimInds: PInteger; SecCDim: TN_UDBase;
                                PSecInds: PInteger; RelCount: Integer );
begin
  UDCDimSec := TK_UDCDim(SecCDim);
  UDCDimPrim := TK_UDCDim(PrimCDim);
  if UDCDimSec <> nil then
    with TK_PCDim(UDCDimSec.R.P)^ do begin
  //*** prepare Secondary CDim Frame
      K_FrameRAEditSec.SetGridLRowsNumber( CDCodes.ALength );

      K_FrameRAEditSec.SetDataPointersFromColumnRArrays(
                            CDCodes, nil, -1 );
      K_FrameRAEditSec.SGrid.Invalidate;

      K_FrameRAEditPrim.SetGridLRowsNumber( RelCount );
      K_FrameRAEditPrim.SetDataPointersFromColumnRArrays(
        CDCodes, PSecInds, RelCount, 0, 0, 2  );
    end;
  if UDCDimPrim <> nil then
    with TK_PCDim(UDCDimPrim.R.P)^ do begin
  //*** prepare Secondary CDim Frame
      K_FrameRAEditPrim.SetDataPointersFromColumnRArrays(
        CDCodes, PPrimInds, RelCount, 0, 2, 2  );
      K_FrameRAEditPrim.SGrid.Invalidate;
    end;

end; // end of procedure TK_FrameCDCor.ShowCDCorInfo

//***********************************  TK_FrameCDCor.AddAllItemsExecute
// Add All Elements
//
procedure TK_FrameCDCor.AddAllItemsExecute(Sender: TObject);
begin
  K_FrameRAEditSec.SelectLRect();
  AddItemsExecute(Sender);
end; // end of procedure TK_FrameCDCor.AddAllItemsExecute

//***********************************  TK_FrameCDCor.DelAllItemsExecute
// Delete All Elements
//
procedure TK_FrameCDCor.DelAllItemsExecute(Sender: TObject);
begin
  K_FrameRAEditPrim.SelectLRect();
  DelItemsExecute( Sender );
end; // end of procedure TK_FrameCDCor.DelAllItemsExecute

end.
