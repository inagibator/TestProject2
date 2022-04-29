unit K_FrUDVTab;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, StdCtrls, Grids, inifiles, ImgList, Menus, ExtCtrls,
  N_ClassRef,
  K_FrRaEdit, K_UDT1, K_DCSpace, K_SCript1, K_Types;

type
  TK_FrameRATabEdit = class(TK_FrameRAEdit)
  private
    { Private declarations }
    DataRoot   : TK_UDSSTable;
    UDVObjNamePat : string;
    VDType     : TK_ExprExtType;
    VClassInd  : Integer;
    RAFCPat    : TK_RAFColumn;
//    RAFCArray  : TK_RAFCArray;
    DLeng : Integer;
  public
    { Public declarations }
    TabDataBuf : TK_RAArray;
    OnClearDataChange : TK_NotifyProc;
    procedure InitFrame( ADataRoot : TK_UDSSTable;
                    APFrDescr : TK_RAPFrDescr;
                    PRAFC : TK_PRAFColumn;
                    AUDVObjNamePat : string = '';
                    AVectorType : string = 'TK_DSSVector';
                    AVectorClassInd : Integer = K_UDVectorCI );
    procedure InitFrameByFormDescr( ADataRoot : TK_UDSSTable;
                    DTypeCode : Int64;
                    AModeFlags : TK_RAModeFlagSet;
                    FormDescr : TK_UDRArray;
                    AUDVObjNamePat : string = '';
                    AVectorType : string = 'TK_DSSVector';
                    AVectorClassInd : Integer = K_UDVectorCI );
    procedure InitFrameByUniForm( ADataRoot : TK_UDSSTable;
                    AModeFlags : TK_RAModeFlagSet = [K_ramColVertical];
                    AUDVObjNamePat : string = '';
                    AVectorType : string = 'TK_DSSVector';
                    AVectorClassInd : Integer = K_UDVectorCI;
                    UniFormClassName : string = 'TK_FormUDVTabUni' );
    function  NewColUDVector( Index : Integer ) : TN_UDBase;
    procedure SaveData();
    procedure FreeContext; override;
    procedure AddColumnData( ColumnCaption : string; ACount : Integer = 1 );
    function  GetColumnRAData( ACol : Integer ) : TK_RArray;
  end;

implementation

{$R *.dfm}

uses
  N_Types,
  K_CLib0;

{ TK_FrameRATabEdit }

//*************************************** TK_FrameRATabEdit.AddColumnData
// Add New Column to Table
//
procedure TK_FrameRATabEdit.AddColumnData( ColumnCaption : string; ACount : Integer = 1 );
var
  CNum, i : Integer;
begin
//  CNum := Length(RAFCArray);
  CNum := Length(TabDataBuf);
  SetLength( TabDataBuf, CNum + ACount );
//  Dec(CNum);
  for i := CNum to High(TabDataBuf) do begin
    TabDataBuf[i] := TK_RArray.CreateByType(
                                      RAFCPat.CDType.All, DLeng );
    RAFCArray[i] := RAFCPat;
    RAFCArray[i].Caption := ColumnCaption;
    PrepareColumnControls( i );
  end;
  SetDataPointersFromColumnRArrays( TabDataBuf[CNum], nil, -1, 0, CNum, ACount );
//  RebuildGridInfo;
//  SelectLRect( CNum, -1, CNum, -1 );
end; //*** end of procedure TK_FrameRATabEdit.AddColumnData

//*************************************** TK_FrameRATabEdit.GetColumnRAData
// Get Column Buffer Data RArray
//
function TK_FrameRATabEdit.GetColumnRAData( ACol : Integer ) : TK_RArray;
begin
  if ( ACol >= 0 ) and ( ACol < Length(TabDataBuf) ) then
    Result := TabDataBuf[ACol]
  else
    Result := nil;
end; //*** end of procedure TK_FrameRATabEdit.GetColumnRAData

//*************************************** TK_FrameRATabEdit.FreeContext
// Free Frame Control Context
//
procedure TK_FrameRATabEdit.FreeContext;
var i : Integer;
begin
  inherited;
  K_FreeColDescr( RAFCPat );
  RAFCArray := nil;
  for i := 0 to High(TabDataBuf) do
    TabDataBuf[i].Free;
  TabDataBuf := nil;
//  if not FUseSelfCDescr then
  K_FreeSPLData( CDescr, K_GetFormCDescrDType.All );

end; //*** end of procedure TK_FrameRATabEdit.FreeContext

//*************************************** TK_FrameRATabEdit.InitFrame
// Prepare RAFrame for TabData View/Edit
//
procedure TK_FrameRATabEdit.InitFrame( ADataRoot: TK_UDSSTable;
                    APFrDescr : TK_RAPFrDescr;
                    PRAFC : TK_PRAFColumn; AUDVObjNamePat : string = '';
                    AVectorType : string = 'TK_DSSVector';
                    AVectorClassInd : Integer = K_UDVectorCI );
var
  UDVector : TN_UDBase;
  h, i : Integer;
  RowCapts   : TN_SArray;
  PNames : Pointer;
begin
  DataRoot := ADataRoot;
  if DataRoot = nil then Exit;
  RAFCPat := PRAFC^;
  assert( (TK_PDSSTable(ADataRoot.R.P).DTCode = 0) or
          (TK_PDSSTable(ADataRoot.R.P).DTCode = RAFCPat.CDType.All),
          'Wrong column type code' );
  if APFrDescr <> nil then
    K_MoveSPLData( APFrDescr^, CDescr, K_GetFormCDescrDType, [K_mdfFreeDest] );
  UDVObjNamePat := AUDVObjNamePat;
  VClassInd  := AVectorClassInd;
  VDType     := K_GetTypeCodeSafe(AVectorType);

  with DataRoot do
  if (UDVObjNamePat = '') and (DirHigh >= 0) then begin
    with DirChild(0) do
      UDVObjNamePat := Copy( ObjName, 1, K_GetPureNameSize(ObjName) );
  end;
  if TK_PDSSTable(DataRoot.R.P).DTCode <> 0 then begin
    RAFCPat.CDType.All := TK_PDSSTable(DataRoot.R.P).DTCode;
  end;
  with RAFCPat.CDType do begin
    if ((D.TFlags and K_ffFlagsMask) <> 0) or
       ((D.TFlags and K_ffArray)     <> 0) then Exit;
  end;
//*** Init Data Buffer and RAFCArray
  with DataRoot do begin
    h := DirHigh;
    SetLength( TabDataBuf, h + 1 );
    SetLength( RAFCArray, h + 1 );
//    if h >= 0 then
      for i := 0 to h do begin
        UDVector := DirChild(i);
        if not (UDVector is TK_UDVector) then Continue;
        K_RFreeAndCopy( TabDataBuf[i], TK_UDVector(UDVector).PDRA^ );
        with RAFCArray[i] do begin
          RAFCArray[i] := RAFCPat;
          RAFCArray[i].Caption := UDVector.GetUName;
          if UDVector.Owner <> DataRoot then
            Include(RAFCArray[i].ShowEditFlags, K_racReadOnly);
//            RAFCArray[i].ShowEditFlags := RAFCArray[i].ShowEditFlags + [K_racReadOnly];
        end;
      end;
{
    else begin
      SetLength( RAFCArray, 1 );
      RAFCArray[0] := RAFCPat;
    end;
}
  end;

//*** Prepare DCSpace names column

  with DataRoot, TK_PDSSTable(R.P)^ do begin
    if DirLength > 0 then
        K_SetUDRefField( CSS, TK_PDSSVector(TK_UDRArray(DirChild(0)).R.P).CSS );
    with TK_UDDCSSpace(CSS) do begin
      DLeng := PDRA^.ALength;
      SetLength( RowCapts, DLeng );
      if Dleng > 0 then begin
        K_MoveSPLVectorBySIndex( RowCapts[0], SizeOf(string),
           (TK_PDCSpace(GetDCSpace.R.P).Names.P)^, SizeOf(string),
           DLeng, Ord(nptString), [], PInteger(DP) );
        PNames := @RowCapts[0];
      end else
        PNames := nil;
    end;

  end;

//*** Set Grid Info
  SetGridInfo( [K_ramSkipRowMoving, K_ramColChangeOrder, K_ramColChangeNum],
               RAFCArray, CDescr, DLeng, PNames, nil, nil );
  if h >= 0 then
    SetDataPointersFromColumnRArrays( TabDataBuf[0] );

  RebuildGridInfo; 

end; //*** end of procedure TK_FrameRATabEdit.InitFrame

//*************************************** TK_FrameRATabEdit.InitFrameByFormDescr
// Prepare RAFrame for TabData View/Edit
//
procedure TK_FrameRATabEdit.InitFrameByFormDescr( ADataRoot : TK_UDSSTable;
                    DTypeCode : Int64;
                    AModeFlags : TK_RAModeFlagSet;
                    FormDescr : TK_UDRArray;
                    AUDVObjNamePat : string = '';
                    AVectorType : string = 'TK_DSSVector';
                    AVectorClassInd : Integer = K_UDVectorCI );
var
  WRAFCArray  : TK_RAFCArray;
begin
  K_RAFColsPrepByRADataFormDescr( WRAFCArray, @CDescr,
                        AModeFlags +  [K_ramColVertical],
                        TK_ExprExtType(DTypeCode), FormDescr );
  CDescr.ModeFlags := AModeFlags + CDescr.ModeFlags;
  InitFrame( ADataRoot, nil, @WRAFCArray[0], AUDVObjNamePat, AVectorType, AVectorClassInd );
end; //*** end of procedure TK_FrameRATabEdit.InitFrameByFormDescr

//*************************************** TK_FrameRATabEdit.InitFrameByUniForm
// Prepare RAFrame for TabData View/Edit
//
procedure TK_FrameRATabEdit.InitFrameByUniForm( ADataRoot : TK_UDSSTable;
                    AModeFlags : TK_RAModeFlagSet = [K_ramColVertical];
                    AUDVObjNamePat : string = '';
                    AVectorType : string = 'TK_DSSVector';
                    AVectorClassInd : Integer = K_UDVectorCI;
                    UniFormClassName : string = 'TK_FormUDVTabUni' );
var
  WRAFCArray  : TK_RAFCArray;
  FormDescr : TK_UDRArray;
  DDType : TK_ExprExtType;
  i : Integer;
  FindTypeColumn : Boolean;
begin
  FormDescr := K_CreateSPLClassByName( UniFormClassName, [] );
  DDType := K_GetTypeCodeSafe( 'TK_TypeUDVTabUni' );
  K_RAFColsPrepByRADataFormDescr( WRAFCArray, @CDescr,
                        AModeFlags, DDType, FormDescr );
  CDescr.ModeFlags := AModeFlags + CDescr.ModeFlags;
  FindTypeColumn := false;
  for i := 0 to High(WRAFCArray) do begin
    if WRAFCArray[i].CDType.All <> TK_PDSSTable(ADataRoot.R.P).DTCode then continue;
    FindTypeColumn := true;
    break;
  end;
  if FindTypeColumn then
    InitFrame( ADataRoot, nil, @WRAFCArray[i], AUDVObjNamePat, AVectorType, AVectorClassInd );
  FormDescr.Free;
end; //*** end of procedure TK_FrameRATabEdit.InitFrameByUniForm

//*************************************** TK_FrameRATabEdit.NewColUDVector
//
//
function TK_FrameRATabEdit.NewColUDVector( Index : Integer ) : TN_UDBase;
begin
  Result := TK_UDSSTable(DataRoot).CreateDVector( UDVObjNamePat,
                    RAFCPat.CDType.All, nil, VDType.All, VClassInd );
end; //*** end of function TK_FrameRATabEdit.NewColUDVector

//*************************************** TK_FrameRATabEdit.SaveData
//  Save RAFrame TabData to UD Dir
//
procedure TK_FrameRATabEdit.SaveData();
var
  n, h, i, j : Integer;
begin
  with DataRoot do begin
  //*** Init Data Buffer
    n := GetDataBufCol;
    ReorderChilds( GetPColIndex, n, NewColUDVector );
    h := n - 1;
    for i := 0 to h do begin
      j := GetDataBufCol( i );
//*** Save Data from DataBuf to DVectors
      with TK_UDVector(DirChild( i )) do begin
        ObjAliase := RAFCArray[j].Caption;
        K_RFreeAndCopy( PDRA^, TabDataBuf[j] );
      end;
    end;
    RebuildVNodes(0);
  end;
  if Assigned(OnClearDataChange) then OnClearDataChange();
end; //*** end of procedure TK_FrameRATabEdit.SaveData

end.

