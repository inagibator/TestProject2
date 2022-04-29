unit K_FrCSDBData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ActnList, StdCtrls, Grids, ExtCtrls,
  K_UDT1, K_FrRaEdit, K_CSpace, K_Script1, K_Types;

type
  TK_FrameCSDBDataEdit = class(TK_FrameRAEdit)
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;
  private
    { Private declarations }
  public
    { Public declarations }
    FRAData : TK_FRAData;
    CaptsCDIRef : TK_CDIRef;
    procedure SetOnDataChangeProc( AOnDataChange: TK_NotifyProc );
    procedure SaveData;
    procedure ShowBlockData( var RAData: TK_RArray;
                             RAColsCDRel: TK_RArray;
                             RARowsCDRel: TK_RArray;
                             AClearModeFlags : TK_RAModeFlagSet = [];
                             ASetModeFlags : TK_RAModeFlagSet = [];
                             FormDescrName: string = '' );
  end;


implementation

uses N_Types;

{$R *.dfm}

{*** TK_FrameCSDBDataEdit ***}
//*************************************** TK_FrameCSDBDataEdit.Create
//
constructor TK_FrameCSDBDataEdit.Create(AOwner: TComponent);
begin
  inherited;
  FRAData := TK_FRAData.Create( Self );
  FRAData.SkipDataBuf := true;
  FRAData.SkipClearEmptyRArrays := true;
  CaptsCDIRef.CDRItemInd := Ord(K_cdiName);

end; //*** end of TK_FrameCSDBDataEdit.Create

//*************************************** TK_FrameCSDBDataEdit.Destroy
//
destructor TK_FrameCSDBDataEdit.Destroy;
begin
  FRAData.Free;
  inherited;
end; //*** end of TK_FrameCSDBDataEdit.Destroy

//*************************************** TK_FrameCSDBDataEdit.SaveData
//  Save Frame Data to Buffer
//
procedure TK_FrameCSDBDataEdit.SaveData;
begin
  FRAData.StoreToMatrixSData;
end; //*** end of TK_FrameCSDBDataEdit.SaveData

//*************************************** TK_FrameCSDBDataEdit.SetOnDataChangeProc
//
procedure TK_FrameCSDBDataEdit.SetOnDataChangeProc( AOnDataChange: TK_NotifyProc );
begin
  OnDataChange := AOnDataChange;
end; //*** end of TK_FrameCSDBDataEdit.SetOnDataChangeProc

//*************************************** TK_FrameCSDBDataEdit.ShowBlockData
//
procedure TK_FrameCSDBDataEdit.ShowBlockData( var RAData: TK_RArray;
                                              RAColsCDRel: TK_RArray;
                                              RARowsCDRel: TK_RArray;
                                              AClearModeFlags : TK_RAModeFlagSet = [];
                                              ASetModeFlags : TK_RAModeFlagSet = [];
                                              FormDescrName: string = '' );
var
  WModeFlags : TK_RAModeFlagSet;
  ColCapts, RowCapts, WCapts : TN_SArray;
  RowCount, ColCount, RelIndsStep : Integer;
  CDimRAAttrs : TK_CDimRAAttrs;
  PUDCDims : TN_PUDBase; UDCDimsCount : Integer;
  PRelInds : PInteger;

  procedure GetDirInfo( RCDRel: TK_RArray );
  begin
    UDCDimsCount := K_GetRACDRelPUDCDims( RCDRel, PUDCDims );
    PRelInds := nil;
    if UDCDimsCount > 0 then
      PRelInds := RCDRel.P;
  end;

  procedure SetDirInfo( var Capts : TN_SArray; CLength : Integer;
                        RACDRel: TK_RArray );
  var i, j : Integer;
  begin
    SetLength( Capts, CLength );
    SetLength( WCapts, CLength );
    RelIndsStep := UDCDimsCount * SizeOf(Integer);
    for i := 0 to UDCDimsCount - 1 do begin
      TK_UDCDim(PUDCDims^).GetCDimRAAttrsInfoSafe( CDimRAAttrs,
                             CaptsCDIRef.CDRCDim, CaptsCDIRef.CDRItemInd );
      K_MoveSPLVectorBySIndex( WCapts[0], SizeOf(string),
         (CDimRAAttrs.PAData)^, SizeOf(string),
         CLength, Ord(nptString), [K_mdfFreeDest],
         PInteger(TN_BytesPtr(PRelInds) + i * SizeOf(Integer)), RelIndsStep  );
      for j := 0 to CLength - 1 do
        if i <> 0 then
          Capts[j] := Capts[j] + ', ' + WCapts[j]
        else
          Capts[j] := WCapts[j];
      Inc(PUDCDims);
    end;
  end;

begin
  WModeFlags := [K_ramColVertical, K_ramSkipResizeWidth, K_ramSkipResizeHeight, K_ramFillFrameWidth];
  RAData.ALength( ColCount, RowCount );
  FRAData.PColNames := nil;

  GetDirInfo( RAColsCDRel );
  if PUDCDims = nil then
    WModeFlags := WModeFlags + [K_ramColChangeOrder, K_ramColChangeNum, K_ramColAutoChangeNum, K_ramShowLColNumbers]
  else begin
    WModeFlags := WModeFlags + [K_ramSkipColMoving];
//    WModeFlags := WModeFlags + [K_ramSkipColMoving, K_ramShowLColNumbers];
    if PRelInds <> nil then begin
      SetDirInfo( ColCapts, ColCount, RAColsCDRel );
      FRAData.PColNames := @ColCapts[0];
    end;
  end;

  FRAData.PRowNames := nil;
  GetDirInfo( RARowsCDRel );
  if PUDCDims = nil then
    WModeFlags := WModeFlags + [K_ramRowChangeOrder, K_ramRowChangeNum, K_ramRowAutoChangeNum]
  else begin
    WModeFlags := WModeFlags + [K_ramSkipRowMoving];
    if (PRelInds <> nil) and (RowCount > 0) then begin
      SetDirInfo( RowCapts, RowCount, RARowsCDRel );
      FRAData.PRowNames := @RowCapts[0];
    end;
  end;
  FRAData.FreeContext;
  FRAData.PrepFrameMatrixByFDTypeName( AClearModeFlags, WModeFlags + ASetModeFlags,
                                       RAData, RAData.ArrayType,
                                       ' ', FormDescrName );
  SGrid.Invalidate;
end; //*** end of TK_FrameCSDBDataEdit.ShowBlockData

{*** end of TK_FrameCSDBDataEdit ***}

end.
