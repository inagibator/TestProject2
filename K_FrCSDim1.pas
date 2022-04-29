unit K_FrCSDim1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ActnList,
  N_Types,
  K_FrRaEdit, K_Script1, K_CSpace, K_UDT1, K_Types;
type
  TK_FrameCSDim1 = class(TFrame)
    K_FrameRAEditS: TK_FrameRAEdit;
    ActionList2: TActionList;
    AddAll: TAction;
    DelAll: TAction;
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;
    procedure AddAllExecute(Sender: TObject);
    procedure DelAllExecute(Sender: TObject);
  protected
    { Private declarations }
    DDType : TK_ExprExtType;
    FormDescr : TK_UDRArray;
    RAFCArray : TK_RAFCArray;
    FrDescr : TK_RAFrDescr;
    AModeFlags : TK_RAModeFlagSet;
    SA : TK_CSDimAttrs;
    SDIndsBuf : TK_RArray;
    FPCDSrcInds : PInteger;
    FCDSrcIndsCount : Integer;
  public
    { Public declarations }
    ReadOnlyMode : Boolean;
    procedure SetOnDataChange ( AOnDataChange : TK_NotifyProc ); virtual;
    procedure ShowCDim( UDCDim : TK_UDRArray; PCDSrcInds : PInteger = nil;
                        CDSrcIndsCount : Integer = -1 ); virtual;
    procedure ShowCDimInds( ACDIType : TK_CDRType; PInds : PInteger;
                            IndsCount : Integer; UDCDim : TN_UDBase;
                            PCDSrcInds : PInteger = nil;
                            CDSrcIndsCount : Integer = -1  );virtual;
    procedure ShowRACDS( RACDS: TK_RArray; PCDSrcInds : PInteger = nil;
                         CDSrcIndsCount : Integer = -1 );
    procedure GetCSDim( var CDSInd : TN_IArray ); virtual;
  end;

implementation

uses Math, Grids,
  K_VFunc,
  N_ButtonsF;

{$R *.dfm}

{*** TK_FrameCSDim1 ***}

//***********************************  TK_FrameCSDim1.SetOnDataChange
//
procedure TK_FrameCSDim1.SetOnDataChange( AOnDataChange: TK_NotifyProc );
begin
  K_FrameRAEditS.OnDataChange := AOnDataChange;
end; // end of TK_FrameCSDim1.SetOnDataChange

//***********************************  TK_FrameCSDim1.Create  ******
//
constructor TK_FrameCSDim1.Create( AOwner: TComponent );
begin
  inherited;

  FormDescr := K_CreateSPLClassByName( 'TK_FormCDSetInds', [] );
  DDType := K_GetTypeCodeSafe( 'TK_CSDimSetEdit' );
  Inc( DDType.D.TFlags, K_ffArray );
  AModeFlags := [K_ramColVertical, K_ramSkipResizeWidth,
                 K_ramOnlyEnlargeSize, K_ramSkipRowMoving];
  K_RAFColsPrepByRADataFormDescr(
      RAFCArray, @FrDescr, AModeFlags, DDType, FormDescr );

//*** Prepare SubSpace Buffer
  SDIndsBuf := TK_RArray.CreateByType( Ord(nptInt) );

  K_FrameRAEditS.SetGridInfo( AModeFlags, RAFCArray, FrDescr, 0,  nil,
                                                  nil, nil );

end; // end of TK_FrameCSDim1.Create

//***********************************  TK_FrameCSDim1.Destroy
//
destructor TK_FrameCSDim1.Destroy;
begin
  K_FrameRAEditS.FreeContext;
  FormDescr.Free;
  SDIndsBuf.Free;
  K_FreeColumnsDescr( RAFCArray );
  inherited;
end; // end of TK_FrameCSDim1.Destroy

//***********************************  TK_FrameCSDim1.ShowCDim
//
procedure TK_FrameCSDim1.ShowCDim( UDCDim : TK_UDRArray; PCDSrcInds : PInteger = nil;
                                    CDSrcIndsCount : Integer = -1 );
var
  CDCount : Integer;
begin
  SA.CDim := UDCDim;
  FPCDSrcInds := PCDSrcInds;
  FCDSrcIndsCount := CDSrcIndsCount;
  with TK_PCDim( TK_UDRArray(SA.CDim).R.P )^ do begin
//*** prepare editing
    if PCDSrcInds = nil then
      CDCount := CDCodes.ALength
    else
      CDCount := CDSrcIndsCount;
    SDIndsBuf.ASetLength( CDCount );
    FillChar( SDIndsBuf.P^, CDCount * SizeOf(Integer), 0 );
    K_FrameRAEditS.SetGridLRowsNumber(  CDCount );

    K_FrameRAEditS.SetDataPointersFromColumnRArrays(
                          CDCodes, FPCDSrcInds, FCDSrcIndsCount, 0, 0, 2 );
  end;
  K_FrameRAEditS.SGrid.Invalidate;
end; // end of procedure TK_FrameCSDim1.ShowCDim

//***********************************  TK_FrameCSDim1.ShowCDimInds
//
procedure TK_FrameCSDim1.ShowCDimInds( ACDIType : TK_CDRType; PInds : PInteger;
                            IndsCount : Integer; UDCDim : TN_UDBase;
                            PCDSrcInds : PInteger = nil;
                            CDSrcIndsCount : Integer = -1 );
var
  BufInds : TN_IArray;
  I1 : Integer;
begin
  SA.CDim := UDCDim;
  SA.CDIType := ACDIType;
  BufInds := nil;
  ShowCDim( TK_UDRArray(SA.CDim), PCDSrcInds, CDSrcIndsCount );
  with TK_PCDim( TK_UDRArray(SA.CDim).R.P )^ do begin
//*** prepare editing
    I1 := 1;
    if CDSrcIndsCount > 0 then begin
      BufInds := TK_UDCdim(SA.CDim).FullIndsArray;
      K_MoveVectorByDIndex( BufInds[0], SizeOf(Integer),
                          I1, 0, SizeOf(Integer),
                          IndsCount, PInds );
      K_MoveVectorByDIndex( SDIndsBuf.P^, SizeOf(Integer),
                          BufInds[0], SizeOf(Integer), SizeOf(Integer),
                          CDSrcIndsCount, PCDSrcInds );
    end else
      K_MoveVectorByDIndex( SDIndsBuf.P^, SizeOf(Integer),
                          I1, 0, SizeOf(Integer),
                          IndsCount, PInds );

    K_FrameRAEditS.SetDataPointersFromColumnRArrays(
                          SDIndsBuf, nil, -1, 0, 2, 1 );
  end;
  AddAll.Enabled := not ReadOnlyMode;
  DelAll.Enabled := not ReadOnlyMode;
  with K_FrameRAEditS.RAFCArray[K_FrameRAEditS.IndexOfColumn( 'IndUse' )] do
    if ReadOnlyMode then
      ShowEditFlags := ShowEditFlags + [K_racReadOnly]
    else
      ShowEditFlags := ShowEditFlags - [K_racReadOnly];

  K_FrameRAEditS.SGrid.Invalidate;

end; // end of TK_FrameCSDim1.ShowCDimInds

//***********************************  TK_FrameCSDim1.ShowRACDS
//
procedure TK_FrameCSDim1.ShowRACDS( RACDS : TK_RArray; PCDSrcInds : PInteger = nil;
                        CDSrcIndsCount : Integer = -1 );
begin
  with RACDS, TK_PCSDimAttrs(PA)^ do
    ShowCDimInds( CDIType, P, ALength, CDim, PCDSrcInds, CDSrcIndsCount );
end; // end of procedure TK_FrameCSDim1.ShowRACDS

//***********************************  TK_FrameCSDim1.GetCSDim
// Get CSDim Inds
//
procedure TK_FrameCSDim1.GetCSDim( var CDSInd : TN_IArray );
var
  i, h, j, n : Integer;
begin
  h := SDIndsBuf.ALength;
  SetLength( CDSInd, h );
  j := 0;
  for i := 0 to h - 1 do
    if PInteger(SDIndsBuf.P(i))^ <> 0 then begin
      n := i;
      if FPCDSrcInds <> nil then
        n := PInteger(TN_BytesPtr(FPCDSrcInds) + i * SizeOf(Integer))^;
      CDSInd[j] := n;
      Inc(j);
    end;
  SetLength( CDSInd, j );
end; // end of procedure TK_FrameCSDim1.GetCSDim

//***********************************  TK_FrameCSDim1.AddAllExecute
// Add All Elems
//
procedure TK_FrameCSDim1.AddAllExecute(Sender: TObject);
var
  i : Integer;
begin
  with SDIndsBuf do
    for i := 0 to AHigh do PInteger(P(i))^ := 1;
  with K_FrameRAEditS do begin
    SGrid.Invalidate;
    if Assigned(OnDataChange) then OnDataChange;
  end;
end; // end of procedure TK_FrameCSDim1.AddAllExecute

//***********************************  TK_FrameCSDim1.DelAllExecute
// Del All Elems
//
procedure TK_FrameCSDim1.DelAllExecute(Sender: TObject);
begin
// SDIndsBuf.P^
  with SDIndsBuf do
    FillChar( P^, ALength * SizeOf(Integer), 0 );
  with K_FrameRAEditS do begin
    SGrid.Invalidate;
    if Assigned(OnDataChange) then OnDataChange;
  end;
end; // end of procedure TK_FrameCSDim1.DelAllExecute

end.
