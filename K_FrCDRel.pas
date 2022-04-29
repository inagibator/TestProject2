unit K_FrCDRel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ActnList, StdCtrls, Grids, ExtCtrls, 
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  N_Types,
  K_FrRaEdit, K_CSpace, K_Script1, K_UDT1, K_Types;

type
  TK_FrameCDRel = class(TK_FrameRAEdit)
    AddCDim: TAction;
    DelCDim: TAction;
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;
    procedure AddCDimExecute(Sender: TObject);
    procedure DelCDimExecute(Sender: TObject);
  private
    { Private declarations }
    CDimFilter : TK_UDFilter;
    BufDataRebuildIsNeeded : Boolean;
    OnRelDataChange        : TK_NotifyProc;

    procedure RelColsAdd( ACount : Integer );
    procedure RelRowsAdd( ACount : Integer );
    procedure RelDataIsChanged;
    procedure SaveData;
  public
    { Public declarations }
    FRAData : TK_FRAData;
    CaptsCDIRef : TK_CDIRef;
    ReadOnlyMode : Boolean;
    SkipUDCDimsCountChange : Boolean;
    SkipRelRowsEdit : Boolean;

    SelectObjsUDRoot   : TN_UDBase;

    RelIndsBuf : TK_RArray;
    RelCDimsBuf : TK_RArray;
    UDRelCSDim: TK_UDCSDim;

    procedure ShowRACDRel( PUDCDims : TN_PUDBase; UDCDimsCount : Integer;
                           PRelInds : PInteger; RelRowCount : Integer;
                           AUDRelCSDim: TK_UDCSDim );
    function  BuildFrameFlags : TK_RAModeFlagSet;
    procedure GetRelCSDimCapts( var AttrsCapts : TN_SArray );
    procedure PrepFrameShow;
    procedure SetOnDataChangeProc( AOnDataChange: TK_NotifyProc );
    function  GetPUDCDims( out PUDCDims : TN_PUDBase ) : Integer;
    function  GetPRelInds( out PRelInds : PInteger ) : Integer;
    procedure InitNewCols( SInd : Integer );
  end;

var
  K_FrameCDRel: TK_FrameCDRel;

implementation

{$R *.dfm}

uses Math,
     K_UDT2, K_VFunc,
     N_ClassRef;
{*** TK_FrameCDRel ***}

//*************************************** TK_FrameCDRel.Create
//
constructor TK_FrameCDRel.Create(AOwner: TComponent);
begin
  inherited;
  CDimFilter := TK_UDFilter.Create;
  CDimFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCDimCI ) );


  FRAData := TK_FRAData.Create( Self );
  FRAData.SkipDataBuf := true;
  FRAData.SkipClearEmptyRArrays := true;
  FRAData.SkipAddToEmpty := true;
  RelIndsBuf := TK_RArray.CreateByType( Ord(nptInt) );
  RelCDimsBuf := TK_RArray.CreateByType( Ord(nptUDRef) );

  CaptsCDIRef.CDRItemInd := Ord(K_cdiName);

  OnColsAdd := RelColsAdd;
  OnRowsAdd := RelRowsAdd;
  OnDataChange := RelDataIsChanged;
  AddCDim.Enabled := false;
  DelCDim.Enabled := false;

end; //*** end of TK_FrameCDRel.Create

//*************************************** TK_FrameCDRel.Destroy
//
destructor TK_FrameCDRel.Destroy;
begin
  FRAData.Free;
  RelIndsBuf.ARelease;
  RelCDimsBuf.ARelease;
  CDimFilter.Free;
  inherited;
end; //*** end of TK_FrameCDRel.Destroy

//*************************************** TK_FrameCDRel.ShowRACDRel
//
procedure TK_FrameCDRel.ShowRACDRel( PUDCDims : TN_PUDBase; UDCDimsCount : Integer;
                           PRelInds : PInteger; RelRowCount : Integer;
                           AUDRelCSDim: TK_UDCSDim );

begin
  if UDCDimsCount <= 0 then  UDCDimsCount := 1;
  RelCDimsBuf.ASetLength( UDCDimsCount );
  if (UDCDimsCount > 0) and (PUDCDims <> nil) then
    Move( PUDCDims^, RelCDimsBuf.P^, UDCDimsCount * SizeOf(TN_UDBase) );
  if UDCDimsCount > 0 then
    RelIndsBuf.ASetLength( UDCDimsCount, RelRowCount);
  if RelRowCount > 0 then
    Move( PRelInds^, RelIndsBuf.P^, RelRowCount * UDCDimsCount * SizeOf(Integer) );
  UDRelCSDim := AUDRelCSDim;
  PrepFrameShow;
end; //*** end of TK_FrameCDRel.ShowRACDRel

//*************************************** TK_FrameCDRel.BuildFrameFlags
//
function TK_FrameCDRel.BuildFrameFlags : TK_RAModeFlagSet;
begin
  Result := [K_ramShowLRowNumbers, K_ramColVertical, K_ramFillFrameWidth,
             K_ramUseFillColor, K_ramSkipColsMark, K_ramSkipResizeWidth, K_ramSkipResizeHeight];
  if ReadOnlyMode then
    Result := Result + [K_ramReadOnly,K_ramSkipColMoving,K_ramSkipRowMoving]
  else begin
    if SkipUDCDimsCountChange then
      Result := Result + [K_ramSkipColMoving]
    else
      Result := Result + [K_ramColChangeOrder, K_ramColChangeNum];
    if UDRelCSDim = nil then begin
      if not SkipRelRowsEdit then
        Result := Result + [K_ramRowChangeOrder, K_ramRowChangeNum, K_ramRowAutoChangeNum];
    end else
      Result := Result + [K_ramSkipRowMoving];
  end;
end; //*** end of TK_FrameCDRel.BuildFrameFlags

//*************************************** TK_FrameCDRel.GetRelCSDimCapts
//
procedure TK_FrameCDRel.GetRelCSDimCapts( var AttrsCapts : TN_SArray );
var
  CDimRAAttrs : TK_CDimRAAttrs;
  AttrsCount : Integer;

begin
  K_GetRACSDimCDim( UDRelCSDim.R ).GetCDimRAAttrsInfoSafe(
       CDimRAAttrs, CaptsCDIRef.CDRCDim, CaptsCDIRef.CDRItemInd );
//*** Copy Captions From CDim Attrs Array To Buffer
  AttrsCount := UDRelCSDim.R.Alength;
  SetLength( AttrsCapts, UDRelCSDim.R.Alength );
  K_MoveSPLVectorBySIndex( AttrsCapts[0], SizeOf(string),
     (CDimRAAttrs.PAData)^, CDimRAAttrs.ADStep,
     AttrsCount, Ord(nptString), [], UDRelCSDim.R.P );
end; //*** end of TK_FrameCDRel.GetRelCSDimCapts

//*************************************** TK_FrameCDRel.PrepFrameShow
//
procedure TK_FrameCDRel.PrepFrameShow;
var
  WModeFlags : TK_RAModeFlagSet;
  AttrsCapts : TN_SArray;

begin
//*** Prepare Data Show
  AddCDim.Enabled := not ReadOnlyMode and not SkipUDCDimsCountChange;
  AttrsCapts := nil;
  with FRAData do begin
    WModeFlags := BuildFrameFlags;
    PRowNames := nil;
//    if (UDRelCSDim <> nil) and not ReadOnlyMode then begin
    if (UDRelCSDim <> nil) then begin
      GetRelCSDimCapts( AttrsCapts );
      PRowNames := @AttrsCapts[0];
    end;

    FreeContext;
    PrepMatrixFrame1( [], WModeFlags, RelIndsBuf, RelIndsBuf.ElemType, '' );
    OnColsAdd := RelColsAdd;
    OnRowsAdd := RelRowsAdd;
    InitNewCols( 0 );
    with RelCDimsBuf do
      AddRow.Enabled := AddRow.Enabled and (UDRelCSDim = nil);
//      AddRow.Enabled := (ALength <> 1) or (TN_PUDBase(P)^ <> nil);
      //*** Empty Relation
    InsRow.Enabled := AddRow.Enabled;
  end;

  SGrid.Invalidate;
end; //*** end of TK_FrameCDRel.PrepFrameShow

//*************************************** TK_FrameCDRel.SaveData
//  Save Frame Data to Buffer Use this Routine before GetPUDCDims and GetPRelInds
//
procedure TK_FrameCDRel.SaveData;
var
  NCol : Integer;
  Buf : TN_IArray;
begin
//*** Restore Relation UDCDims
  if not BufDataRebuildIsNeeded then Exit;
  NCol := GetDataBufCol;
  SetLength( Buf, NCol );
  if NCol > 0 then
    K_MoveVectorBySIndex( Buf[0], SizeOf(TN_UDBase),
                        RelCDimsBuf.P^, SizeOf(TN_UDBase), SizeOf(TN_UDBase),
                        NCol, GetPColIndex );
  RelCDimsBuf.ASetlength( NCol );
  if NCol > 0 then
    Move( Buf[0], RelCDimsBuf.P^, NCol * SizeOf(TN_UDBase) );
//*** Restore Relation Indices
  FRAData.StoreToMatrixSData;
  BufDataRebuildIsNeeded := false;
end; //*** end of TK_FrameCDRel.SaveData

//*************************************** TK_FrameCDRel.RelDataIsChanged
//
procedure TK_FrameCDRel.RelDataIsChanged;
begin
  if Assigned(OnRelDataChange) then OnRelDataChange();
  BufDataRebuildIsNeeded := true;
end; //*** end of TK_FrameCDRel.RelDataIsChanged

//*************************************** TK_FrameCDRel.SetOnDataChangeProc
//
procedure TK_FrameCDRel.SetOnDataChangeProc( AOnDataChange: TK_NotifyProc );
begin
  OnRelDataChange := AOnDataChange;
end; //*** end of TK_FrameCDRel.SetOnDataChangeProc

//*************************************** TK_FrameCDRel.GetPUDCDims
//
function TK_FrameCDRel.GetPUDCDims( out PUDCDims: TN_PUDBase ): Integer;
begin
  SaveData;
  Result := RelCDimsBuf.ALength;
  PUDCDims := RelCDimsBuf.P;
end; //*** end of TK_FrameCDRel.GetPUDCDims

//*************************************** TK_FrameCDRel.GetPRelInds
//
function TK_FrameCDRel.GetPRelInds( out PRelInds: PInteger ): Integer;
begin
  SaveData;
  Result := RelIndsBuf.ARowCount;
  PRelInds := RelIndsBuf.P;
end; //*** end of TK_FrameCDRel.GetPRelInds

//*************************************** TK_FrameCDRel.RelColsAdd
//
procedure TK_FrameCDRel.RelColsAdd( ACount : Integer );
var
  NInd, i, L : Integer;
begin
  NInd := RelIndsBuf.AColCount;
  FRAData.OnAddMatrixCol( ACount );
  //*** Prepare New Inds
  with RelIndsBuf do begin
    L := ACount * SizeOf(Integer);
    for i := 0 to ARowCount - 1 do
      FillChar( PME(NInd, i)^, L, -1 );
  //*** Prepare New CDims
    RelCDimsBuf.ASetLength( AColCount );
  end;
end; //*** end of TK_FrameCDRel.RelColsAdd

//*************************************** TK_FrameCDRel.RelRowsAdd
//
procedure TK_FrameCDRel.RelRowsAdd( ACount : Integer );
var
  NInd, NRow, NCol : Integer;
begin
  with RelIndsBuf do begin
    NInd := ARowCount;
    NRow := NInd + ACount;
    NCol := AColCount;
    ASetLength( NCol, NRow );
    FillChar( PME(0, NInd)^, ACount * NCol * SizeOf(Integer), -1 );
  end;
  SetDataPointersFromRAMatrix( RelIndsBuf );
end; //*** end of TK_FrameCDRel.ReRowsAdd

//*************************************** TK_FrameCDRel.InitNewCols
//
procedure TK_FrameCDRel.InitNewCols( SInd : Integer );
var
  i : Integer;
  UDCDim : TN_UDBase;
  Prefix : string;
  WEArray  : TK_RAFCVEArray;
begin
//*** Prepare Data Show
  WEArray := nil;
//*** Marked Old Columns UDCDims
  for i := 0 to SInd -1 do
    Inc( TN_PUDBase(RelCDimsBuf.P(i)).Marker );
//*** Prepare Columns Captions for New UDCDims
  for i := SInd to RelCDimsBuf.AHigh do begin
    UDCDim := TN_PUDBase(RelCDimsBuf.P(i))^;
    if UDCDim = nil then Continue;
    with RAFCArray[i] do begin
      Prefix := '';
      if UDCDim.Marker > 0 then
        Prefix := '('+IntToStr(UDCDim.Marker)+')';
      Inc(UDCDim.Marker);
      Caption := Prefix+UDCDim.GetUName();
      VEArray := Copy(VEArray, 0, 1);
      VEArray[0].EObj := TK_RAFCDItemEditor0.Create;
      VEArray[0].EObj.RAFrame := Self;
      TK_RAFCDItemEditor0(VEArray[0].EObj).SetUDCDimInfo( TK_UDCDim(UDCDim) );
      VEArray[0].VObj := VEArray[0].EObj;
{
      WEArray := Copy(VEArray);
      WEArray[0].EObj := TK_RAFCDItemEditor0.Create;
      WEArray[0].EObj.RAFrame := Self;
      TK_RAFCDItemEditor0(WEArray[0].EObj).SetUDCDimInfo( TK_UDCDim(UDCDim) );
      WEArray[0].VObj := WEArray[0].EObj;
      VEArray := WEArray;
}
    end;
  end;
//*** Clear Columns UDCDims Markers
  for i := 0 to RelCDimsBuf.AHigh do begin
    UDCDim := TN_PUDBase(RelCDimsBuf.P(i))^;
    if UDCDim = nil then Continue;
    UDCDim.Marker := 0;
  end;

  SGrid.Invalidate;
end; //*** end of TK_FrameCDRel.InitNewCols

//*************************************** TK_FrameCDRel.AddCDimExecute
//
procedure TK_FrameCDRel.AddCDimExecute(Sender: TObject);
var
  NewCDim : TN_UDBase;
  CDCount, i : Integer;
  res : word;
label SelectCDim;
begin
SelectCDim:
  NewCDim := nil;
  if SelectObjsUDRoot = nil then SelectObjsUDRoot := K_CurArchive;
  if not K_SelectUDNode( NewCDim, SelectObjsUDRoot, CDimFilter.UDFTest,
    'Выбор измерения', true  ) then Exit;
//***  Check if New CDim already used
  CDCount := RelCDimsBuf.ALength;
  for i := 0 to CDCount - 1 do begin
    if TN_PUDBase(RelCDimsBuf.P(i))^ = NewCDim then begin
      SelectLRect( i, -1, i, -1 );
      res := MessageDlg( 'Связь с этим измерением уже существует - добавить?',
                         mtConfirmation, [mbYes, mbNo, mbCancel], 0 );
      if res = mrNo then goto SelectCDim
      else if res = mrCancel then Exit;
    end;
  end;
  if (CDCount > 1) or (TN_PUDBase(RelCDimsBuf.P)^ <> nil) then
    AddColExecute( Sender ) // Not Empty Relation or No Data at All
  else
    Dec(CDCount);           // Empty Relation
  with RelCDimsBuf do
    TN_PUDBase(P(AHigh))^ := NewCDim;
  InitNewCols( CDCount );

  AddRow.Enabled := true;
  InsRow.Enabled := true;
  DelCDim.Enabled := true;

  SGrid.Invalidate;
end; //*** end of TK_FrameCDRel.AddCDimExecute

{*** end of TK_FrameCDRel ***}

procedure TK_FrameCDRel.DelCDimExecute(Sender: TObject);
var
  DelSect, DelStart : Integer;
  RDelSect : Integer;
begin
  GetSelectSection( false, DelStart, DelSect );
  RDelSect := Min( DelSect, GetDataBufCol - 1 );
  if RDelSect > 0  then
    FrDeleteCols( DelStart, RDelSect );
  RDelSect := DelSect - RDelSect;

  if RDelSect > 0 then begin
  //*** Clear Last CDim
    TN_PUDBase(RelCDimsBuf.P(GetDataBufCol(0)))^ := nil;
    with RAFCArray[0] do begin
      Caption := '';
      FreeAndNil( VEArray[0].EObj );
      VEArray[0].VObj := nil;
    end;
    FrDeleteRows( 1, GetDataBufRow );
  end;
end;

end.
