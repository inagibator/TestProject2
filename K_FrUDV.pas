unit K_FrUDV;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, StdCtrls, Grids, inifiles, Menus, ExtCtrls,
  K_FrRaEdit, K_UDT1, K_DCSpace, K_SCript1, K_Types;

type
  TK_FrameRAVectorEdit = class(TK_FrameRAEdit)
  private
    { Private declarations }
//    UDVector : TK_UDVector;
    PDSSVector : TK_PDSSVector;
    BufData  : TK_RArray;
    VDType   : TK_ExprExtType;
    DLeng    : Integer;
  public
    { Public declarations }
    OnClearDataChange : TK_NotifyProc;
    procedure FreeContext; override;
    procedure InitFrame0( APDSSVector: TK_PDSSVector;
                         AModeFlags : TK_RAModeFlagSet = [];
                         ADataName : string = '';
                         FormClassName : string = 'TK_FormUDVTabUni';
                         UniTypesClassName : string = 'TK_TypeUDVTabUni';
                         APFrDescr : TK_RAPFrDescr = nil );
    procedure InitFrame( AUDVector: TK_UDVector;
                         AModeFlags : TK_RAModeFlagSet = [];
                         ADataName : string = '';
                         FormClassName : string = 'TK_FormUDVTabUni';
                         UniTypesClassName : string = 'TK_TypeUDVTabUni';
                         APFrDescr : TK_RAPFrDescr = nil );
    procedure SaveData();
  end;

var
  K_FrameRAVectorEdit: TK_FrameRAVectorEdit;

implementation

{$R *.dfm}

uses K_FSelectUDB, {K_IndGlobal,}
 N_ClassRef, N_Types;

{ TK_FrameRAVectorEdit }

//*************************************** TK_FrameRAVectorEdit.FreeContext
// Free Frame Control Context
//
procedure TK_FrameRAVectorEdit.FreeContext;
begin
  if RAFCArray = nil then Exit;
  inherited;
  K_FreeColumnsDescr( RAFCArray );
  RAFCArray := nil;
  BufData.Free;
//  if not FUseSelfCDescr then
  K_FreeSPLData( CDescr, K_GetFormCDescrDType.All );

end; //*** end of procedure TK_FrameRAVectorEdit.FreeContext

//*************************************** TK_FrameRAVectorEdit.InitFrame
// Free Frame Control Context
//
procedure TK_FrameRAVectorEdit.InitFrame( AUDVector: TK_UDVector;
                                          AModeFlags : TK_RAModeFlagSet = [];
                                          ADataName : string = '';
                                          FormClassName : string = 'TK_FormUDVTabUni';
                                          UniTypesClassName : string = 'TK_TypeUDVTabUni';
                                          APFrDescr : TK_RAPFrDescr = nil );
begin
  if AUDVector = nil then Exit;
  InitFrame0( AUDVector.R.P, AModeFlags, ADataName, FormClassName,
              UniTypesClassName, APFrDescr );
end; //*** end of procedure TK_FrameRAVectorEdit.InitFrame

//*************************************** TK_FrameRAVectorEdit.InitFrame0
// Prepare RAFrame for TabData View/Edit
//
procedure TK_FrameRAVectorEdit.InitFrame0( APDSSVector: TK_PDSSVector;
                                          AModeFlags : TK_RAModeFlagSet = [];
                                          ADataName : string = '';
                                          FormClassName : string = 'TK_FormUDVTabUni';
                                          UniTypesClassName : string = 'TK_TypeUDVTabUni';
                                          APFrDescr : TK_RAPFrDescr = nil );
var
  RowCapts   : TN_SArray;
  RowCodes   : TN_SArray;
  WRAFCArray  : TK_RAFCArray;
  FormDescr : TK_UDRArray;
  DDType : TK_ExprExtType;
  WData : TK_RArray;
  PNames : Pointer;
  i : Integer;
  UDCSSpace : TK_UDDCSSpace;

  procedure CorrectCDescr;
  begin
    if APFrDescr <> nil then
      K_MoveSPLData( APFrDescr^, CDescr, K_GetFormCDescrDType, [K_mdfFreeDest] );

    CDescr.ModeFlags := AModeFlags + CDescr.ModeFlags;
  end;
begin
  PDSSVector := APDSSVector;
  if (PDSSVector = nil) or
     (PDSSVector.D = nil) then Exit;

 if PDSSVector.CSS = nil then begin
    UDCSSpace := TK_UDDCSSpace( K_SelectUDB( K_CurSpacesRoot, '',
          K_PrepareUDFilterAllowed( K_UDFilter, [K_UDDCSSpaceCI]).UDFTest ) );
    if UDCSSpace = nil then Exit;
    UDCSSpace.LinkDVector( PDSSVector );
 end;
// prepare UniFormDescription
//  FormDescr := K_CreateSPLClassByName( FormClassName,  );
  DDType := K_GetTypeCode( FormClassName );

// prepare Buffer data SPLType
//  VDType := UDVector.PDRA^.DType;
  VDType := PDSSVector.D.ElemType;
  VDType.D.CFlags := VDType.D.CFlags and not K_ccCountUDRef;

  if DDType.DTCode <> -1 then begin
    FormDescr := K_CreateSPLClassByType( DDType.FD, [] );
    DDType := K_GetTypeCode( UniTypesClassName );
    if DDType.DTCode <> -1 then begin
    //*** Show All Vector Fields
      WRAFCArray := nil;
      K_RAFColsPrepByRADataFormDescr( WRAFCArray, @CDescr,
                            AModeFlags, DDType, FormDescr );
      CorrectCDescr;

    //*** prepare columns using UniFormDescription
      K_RAFLColsPrepByDataType( RAFCArray, 0, CDescr.ModeFlags,
                          VDType, WRAFCArray );
    end else begin
    //*** Show Vector Fields according to FormClassName
      K_RAFColsPrepByRADataFormDescr( RAFCArray, @CDescr,
                            AModeFlags, VDType, FormDescr );
      CorrectCDescr;
    end;
    FormDescr.Free;
  end else begin
    CorrectCDescr;
    if APFrDescr = nil then
      with CDescr do begin
//        ModeFlags.PasFlags := [K_ramColVertical, K_ramUseFillColor, K_ramShowNumbers];
        SelFillColor  := $808080;  // Fill Color in Selected Cells
        SelFontColor  := $FFFFFF;  // Font Color in Selected Cells
        DisFillColor  := -1;       // Fill Color in Disabled Cells
        DisFontColor  := -1;       // Font Color in Disabled Cells
        MinHColWidth := 150;
      end;
    K_RAFColsPrepByDataType( RAFCArray, 0, CDescr.ModeFlags, VDType );
  end;

//*** Prepare DCSpace names column

//  with UDVector.GetDCSSpace do begin
  with TK_UDDCSSpace(PDSSVector.CSS) do begin
    DLeng := PDRA^.ALength;
    SetLength( RowCapts, DLeng );
    SetLength( RowCodes, DLeng );
    if DLeng > 0 then begin
      K_MoveSPLVectorBySIndex( RowCapts[0], SizeOf(string),
         (TK_PDCSpace(GetDCSpace.R.P).Names.P)^, SizeOf(string),
         DLeng, Ord(nptString), [], PInteger(DP) );
      K_MoveSPLVectorBySIndex( RowCodes[0], SizeOf(string),
         (TK_PDCSpace(GetDCSpace.R.P).Codes.P)^, SizeOf(string),
         DLeng, Ord(nptString), [], PInteger(DP) );
      for i := 0 to High(RowCapts) do
        RowCapts[i] := format('%3s ', [RowCodes[i]]) + RowCapts[i];
      PNames := @RowCapts[0];
    end else
      PNames := nil;
  end;

//*** Prepare Buf Data
//  WData := UDVector.PDRA^;
  WData := PDSSVector.D;
  if not (K_ramReadOnly in CDescr.ModeFlags) then begin
    //*** Create Data Buffer Structure
    BufData := K_RCreateByTypeCode( VDType.All, DLeng );
    if DLeng > 0 then
//      BufData.SetElems( UDVector.DP^, false );
      BufData.SetElems( WData.P^, false );
    WData := BufData;
  end;

  if (ADataName <> '') and ( Length(RAFCArray) = 1 ) then
    RAFCArray[0].Caption := ADataName;
//*** Set Grid Info
  SetGridInfo( [K_ramSkipRowMoving],
            RAFCArray, CDescr, DLeng, PNames, nil, nil );
//*** Prepare Grid Data Pointers
  VDType.D.TFlags := VDType.D.TFlags + K_ffArray;
  SetDataPointersFromRArray( WData, VDType, 0 );
  RebuildGridInfo;
end; //*** end of procedure TK_FrameRAVectorEdit.InitFrame0

//*************************************** TK_FrameRAVectorEdit.SaveData
//  Save RAFrame TabData to UD Dir
//
procedure TK_FrameRAVectorEdit.SaveData();
//var
//  n, h, i, j : Integer;
begin
  if not (K_ramReadOnly in CDescr.ModeFlags) then begin
    VDType.D.CFlags := VDType.D.CFlags or K_ccCountUDRef;
    GetDataToRArray( PDSSVector.D, VDType );
  end;
  if Assigned(OnClearDataChange) then OnClearDataChange();
end; //*** end of procedure TK_FrameRAVectorEdit.SaveData

end.

