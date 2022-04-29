unit K_FrCSDBlock;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, StdCtrls, ComCtrls, ToolWin, ExtCtrls,
  N_Types,  
  K_UDT1, K_CSpace, K_FrCSDim1, K_FrCSDim2, K_Script1, K_FrRaEdit,
  K_FrCSDBData, K_FrECDRel, K_Types;

type
  TK_FrameCSDBlockEdit = class(TFrame)
    PageControl: TPageControl;
    DataTSheet   : TTabSheet;
    RowsTSheet   : TTabSheet;
    ColsTSheet   : TTabSheet;
    CSItemsTSheet: TTabSheet;
    FrameCSDBDataEdit: TK_FrameCSDBDataEdit;
    FrameCDIRefs: TK_FrameRAEdit;

    ActionList: TActionList;
    AddCDItem      : TAction;
    RebuildCurFrame: TAction;
    TranspCurFrame : TAction;
    SetColCDRel: TAction;
    SetRowCDRel: TAction;
    ClearColCDRel: TAction;
    ClearRowCDRel: TAction;

    Panel1: TPanel;
    Panel2: TPanel;

    EdElemType: TEdit;
    Label3: TLabel;

    ToolBar2: TToolBar;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;

    Button2: TButton;
    Button3: TButton;
    FrameRowECDRel: TK_FrameECDRel;
    FrameColECDRel: TK_FrameECDRel;

    constructor Create( AOwner: TComponent ); override;
    destructor  Destroy; override;
    procedure PageControlChange(Sender: TObject);
    procedure AddCDItemExecute(Sender: TObject);
    procedure RebuildCurFrameExecute(Sender: TObject);
    procedure TranspCurFrameExecute(Sender: TObject);
    procedure SetColCDRelExecute(Sender: TObject);
    procedure SetRowCDRelExecute(Sender: TObject);
    procedure ClearColCDRelExecute(Sender: TObject);
    procedure ClearRowCDRelExecute(Sender: TObject);
  private
    { Private declarations }

    IniColsTSheetCapt, IniRowsTSheetCapt : string;

    RAData : TK_RArray;

    FRACDIRefs  : TK_FRAData;
    RACDIRefs   : TK_RArray;

    RACRDBlock : TK_RArray;

    CurColUDCDRel : TK_UDCDRel;
    CurRAColCDRel : TK_RArray;

    CurRowUDCDRel : TK_UDCDRel;
    CurRARowCDRel : TK_RArray;

    CDimFilter : TK_UDFilter;
    CDimAndIndsFilter : TK_UDFilter;

    CRDBlockType : TK_ExprExtType;
    PrevActivTabSheet : TTabSheet;

    procedure SwitchTabSheetCaptions;
    function  SetDBlockCSDim( SelCaption : string; var Count : Integer;
                              var UDCDRel : TK_UDCDRel;
                              var RACDRel : TK_RArray ) : TK_CDRType;
  public
    { Public declarations }
    SelectObjsUDRoot   : TN_UDBase;
    OnDataChange       : TK_NotifyProc;
    procedure InitFrame( AOnDataChange: TK_NotifyProc );
    procedure ShowCRDBlock( ARACRDBlock : TK_RArray );
    procedure SaveDataToCRDBlock;
  end;

implementation

{$R *.dfm}

uses Math,
     K_FrCDRel, K_CLib0, K_UDT2, K_VFunc, K_FSFCombo,
     N_ClassRef, N_ButtonsF;


//***********************************  TK_FrameCSDBLockEdit.Create
//
constructor TK_FrameCSDBlockEdit.Create(AOwner: TComponent);
begin
  inherited;
  IniColsTSheetCapt := ColsTSheet.Caption;
  IniRowsTSheetCapt := RowsTSheet.Caption;

  CDimFilter := TK_UDFilter.Create;
  CDimFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCDimCI ) );

  CDimAndIndsFilter := TK_UDFilter.Create;
  CDimAndIndsFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCDimCI ) );
  CDimAndIndsFilter.AddItem( TK_UDCSDimTypeFilterItem.Create( K_cdrAny ) );
  CDimAndIndsFilter.AddItem( TK_UDCDRelTypeFilterItem.Create( K_cdrAny ) );

  FRACDIRefs := TK_FRAData.Create( FrameCDIRefs );
  FRACDIRefs.SkipAddToEmpty := true;
  FRACDIRefs.PrepFrameByFDTypeName( [],
    [K_ramRowChangeNum, K_ramRowChangeOrder,
     K_ramSkipResizeWidth, K_ramSkipResizeHeight, K_ramFillFrameWidth],
    RAData, K_GetExecTypeCodeSafe('arrayof TK_CDIRef'), '', 'TK_FormCDIRef' );
//  FRACDIRefs.NotBufData := true;

  RACDIRefs := K_RCreateByTypeName( 'TK_CDIRef', 0, [] );

  SetColCDRel.Enabled := false;
  SetRowCDRel.Enabled := false;

  SelectObjsUDRoot := K_CurArchive;
end; // end of TK_FrameCSDBLockEdit.Create

//***********************************  TK_FrameCSDBLockEdit.Destroy
//
destructor TK_FrameCSDBlockEdit.Destroy;
begin
  CDimAndIndsFilter.Free;
  CDimFilter.Free;
  RAData.ARelease;
  RACDIRefs.ARelease;
  inherited;
end; // end of TK_FrameCSDBLockEdit.Destroy

//***********************************  TK_FrameCSDBLockEdit.InitFrame
//
procedure TK_FrameCSDBlockEdit.InitFrame( AOnDataChange: TK_NotifyProc );
begin
  OnDataChange := AOnDataChange;
  FrameCSDBDataEdit.OnDataChange := AOnDataChange;
  FrameRowECDRel.SetOnDataChangeProc( AOnDataChange );
  FrameColECDRel.SetOnDataChangeProc( AOnDataChange );
  FrameCDIRefs.OnDataChange := AOnDataChange;

end; // end of TK_FrameCSDBLockEdit.InitFrame

//***********************************  TK_FrameCSDBLockEdit.ShowCRDBlock
// Show Data Block RArray
//
procedure TK_FrameCSDBlockEdit.ShowCRDBlock( ARACRDBlock : TK_RArray );

var
  RAColCDRel : TK_RArray;
  RARowCDRel : TK_RArray;

  function InitDimInfo(  var UDCDRel : TK_UDCDRel; var RACDRel : TK_RArray;
     VARel : TObject ) : Boolean;
  begin
    RACDRel := K_GetPVRArray( VARel )^;
    Result := (TObject(RACDRel) = VARel) and
              (VARel <> nil)             and
              (K_GetRACDRelUDCSDim( RACDRel ) = nil);
    if VARel is TN_UDBase then
      TObject(UDCDRel) := VARel
    else
      UDCDRel := nil;
  end;

begin
  ColsTSheet.Caption := IniColsTSheetCapt;
  RowsTSheet.Caption := IniRowsTSheetCapt;
  PageControl.ActivePageIndex := 0;

  RACRDBlock := ARACRDBlock;
  if RACRDBlock = nil then Exit;

  with RACRDBlock, TK_PCSDBAttrs(PA)^ do begin
    CRDBlockType := GetComplexType;

    ColsTSheet.TabVisible := InitDimInfo( CurColUDCDRel, RAColCDRel, ColsRel );
    SetColCDRel.Enabled := ColsRel = nil;
    ClearColCDRel.Enabled := not SetColCDRel.Enabled;
    CurRAColCDRel := RAColCDRel;
    if ColsTSheet.TabVisible then begin
      CurRAColCDRel := K_RCopy( RAColCDRel, [K_mdfCopyRArray] );
      FrameColECDRel.ShowRACDRel( CurRAColCDRel );
    end;

    RowsTSheet.TabVisible := InitDimInfo( CurRowUDCDRel, RARowCDRel, RowsRel );
    SetRowCDRel.Enabled := RowsRel = nil;
    ClearRowCDRel.Enabled := not SetRowCDRel.Enabled;
    CurRARowCDRel := RARowCDRel;
    if RowsTSheet.TabVisible then begin
      CurRARowCDRel := K_RCopy( RARowCDRel, [K_mdfCopyRArray] );
      FrameRowECDRel.ShowRACDRel( CurRARowCDRel );
    end;

    RAData.ARelease;
    RAData := TK_RArray.CreateByType( ElemType.All, Alength );
    EdElemType.Text := K_GetExecTypeName(ElemSType);
    RAData.HCol := HCol;
    RAData.SetElems( P^, false );
    if (Alength = 0) and (RowsRel = nil) then begin
      RAData.ASetLength( HCol + 1, 1 );
      RAData.InitElems;
      if Assigned(OnDataChange) then OnDataChange;
    end;
    FrameCSDBDataEdit.ShowBlockData( RAData, CurRAColCDRel, CurRARowCDRel );

    if not (K_ramColVertical in FrameCSDBDataEdit.ModeFlags) then
      SwitchTabSheetCaptions;
    // Init CDim References Frame
    if CBRel <> nil then begin
      RACDIRefs.ASetLength( CBRel.AColCount );
      K_GetRACDRelToIRefs( CBRel, RACDIRefs.P );
    end;
    FRACDIRefs.SetNewData( RACDIRefs );
  end;

end; // end of TK_FrameCSDBLockEdit.ShowCRDBlock

//***********************************  TK_FrameCSDBLockEdit.SwitchTabSheetCaptions
// Switch TabSheet Captions
//
procedure TK_FrameCSDBlockEdit.SwitchTabSheetCaptions;
var
 WStr : string;
begin
  WStr := ColsTSheet.Caption;
  ColsTSheet.Caption := RowsTSheet.Caption;
  RowsTSheet.Caption := WStr;
end; // end of TK_FrameCSDBLockEdit.SwitchTabSheetCaptions

//***********************************  TK_FrameCSDBLockEdit.PageControlChange
// PageControl Change Handler
//
procedure TK_FrameCSDBlockEdit.PageControlChange(Sender: TObject);
var
  DataStructureWasChanged : Boolean;
  WInds : TN_IArray;
  NCount : Integer;
  Count : Integer;
  ConvDataInds, FreeDataInds, InitDataInds : TN_IArray;

  FrCCount, FrRCount : Integer;
  FrPUDCDims : TN_PUDBase;
  FrPRelInds : PInteger;
  BufCCount, BufRCount : Integer;
  BufPUDCDims : TN_PUDBase;
  BufPRelInds : PInteger;
  WPrevActivTabSheet : TTabSheet;

  function GetDirInfo( RCDRel: TK_RArray; FrCRDBData : TK_FrameCDRel ) : Boolean;
  begin
    FrCCount := FrCRDBData.GetPUDCDims( FrPUDCDims );
    FrRCount := FrCRDBData.GetPRelInds( FrPRelInds );
    BufCCount := K_GetRACDRelPUDCDims( RCDRel, BufPUDCDims );
    BufRCount := RCDRel.ARowCount;
    BufPRelInds := nil;
    if BufCCount > 0 then
      BufPRelInds := RCDRel.P;
    Result := (BufCCount <> FrCCount)                         or
              ( (FrCCount <> 0) and
                not CompareMem( FrPUDCDims,
                  BufPUDCDims, FrCCount * SizeOf(Integer) ) ) or
              (BufRCount <> FrRCount)                         or
              ( (FrCCount <> 0) and
                not CompareMem( FrPRelInds,
                  BufPRelInds, FrCCount * FrRCount * SizeOf(Integer) ) );
  end;

begin
  WPrevActivTabSheet := PrevActivTabSheet;
  PrevActivTabSheet := PageControl.ActivePage;
  DataStructureWasChanged := false;
  if PageControl.ActivePage <> DataTSheet then Exit;
  //*** Rebuild Data Structure
//  if RowsTSheet.TabVisible then begin
  if (WPrevActivTabSheet = RowsTSheet) and (CurRARowCDRel <> nil) then begin
    if GetDirInfo( CurRARowCDRel, FrameRowECDRel.FrRACDRel ) then begin
      if (FrCCount = 1) and (FrPUDCDims^ = nil) then
      // Empty Relation - Clear Rows CDRel
        ClearRowCDRelExecute( Sender )
      else begin
      // Rebuild Rows
        Count := CurRARowCDRel.ARowCount;
        FrameRowECDRel.SaveData;
        FrameRowECDRel.GetReorderRowsInds( WInds );
        NCount := Length(WInds);
        K_BuildConvFreeInitInds( Count, K_GetPIArray0(WInds), NCount, ConvDataInds,
                            FreeDataInds, InitDataInds );
        RAData.ReorderRows( K_GetPIArray0(ConvDataInds), Length(ConvDataInds),
                            K_GetPIArray0(FreeDataInds), Length(FreeDataInds),
                            K_GetPIArray0(InitDataInds), Length(InitDataInds) );
        DataStructureWasChanged := true;
        FrameRowECDRel.ShowRACDRel( CurRARowCDRel );
      end;
    end;
  end;

//  if ColsTSheet.TabVisible then begin
  if (WPrevActivTabSheet = ColsTSheet) and (CurRAColCDRel <> nil) then begin
    if GetDirInfo( CurRAColCDRel, FrameColECDRel.FrRACDRel ) then begin
      if ((FrCCount = 1) and (FrPUDCDims^ = nil)) or (FrRCount = 0) then
      // Empty Relation - Clear Cols CDRel
        ClearColCDRelExecute( Sender )
      else begin
      // Rebuild Cols
        Count := CurRAColCDRel.ARowCount;
        FrameColECDRel.SaveData;
        FrameColECDRel.GetReorderRowsInds( WInds );
        NCount := Length(WInds);
        K_BuildConvFreeInitInds( Count, K_GetPIArray0(WInds), NCount, ConvDataInds,
                            FreeDataInds, InitDataInds );
        RAData.ReorderCols( K_GetPIArray0(ConvDataInds), Length(ConvDataInds),
                            K_GetPIArray0(FreeDataInds), Length(FreeDataInds),
                            K_GetPIArray0(InitDataInds), Length(InitDataInds) );
        DataStructureWasChanged := true;
        FrameColECDRel.ShowRACDRel( CurRAColCDRel );
      end;
    end;
  end;

  if not DataStructureWasChanged then Exit;
  // Rebuild Data Frame View
  FrameCSDBDataEdit.ShowBlockData( RAData, CurRAColCDRel, CurRARowCDRel );

end; // end of TK_FrameCSDBLockEdit.PageControlChange

//***********************************  TK_FrameCSDBLockEdit.AddCDItemExecute
// Add Code Space Dimension Item Reference
//
procedure TK_FrameCSDBlockEdit.AddCDItemExecute(Sender: TObject);
var
  NewCDim : TN_UDBase;
  i : Integer;
label SelectCDim;
begin
SelectCDim:
  NewCDim := nil;
  if not K_SelectUDNode( NewCDim, SelectObjsUDRoot, CDimFilter.UDFTest,
    '¬ыбор измерени€', true  ) then Exit;
//*** Check if this CDim is Used
  if K_IndexOfRACDRelCDim( CurRAColCDRel, NewCDim ) <> -1 then begin
    K_ShowMessage( 'Ёто измерение используетс€ дл€ идентификации данных колонок' );
    goto SelectCDim;
  end;
  if K_IndexOfRACDRelCDim( CurRARowCDRel, NewCDim ) <> -1 then begin
    K_ShowMessage( 'Ёто измерение используетс€ дл€ идентификации данных р€дов' );
    goto SelectCDim;
  end;

  with FrameCDIRefs do begin
    for i := 0 to GetDataBufRow - 1 do begin
      if TK_PCDIRef( FRACDIRefs.BufData.P( GetDataBufRow(i) ) ).CDRCDim = NewCDim then begin
        SelectLRect( -1, i, -1, i );
        K_ShowMessage( '—в€зь с этим измерением уже существует' );
        goto SelectCDim;
      end;
    end;
    AddRowExecute( Sender );
    with FRACDIRefs.BufData, TK_PCDIRef(P(AHigh))^ do begin
      CDRCDim := NewCDim;
      CDRItemInd := -1
    end;
  end;
end; // end of TK_FrameCSDBLockEdit.AddCDItemExecute

//***********************************  TK_FrameCSDBLockEdit.SaveDataToCRDBlock
// Save Data RACRDBlock
//
procedure TK_FrameCSDBlockEdit.SaveDataToCRDBlock;
var
  Count : Integer;
  WCRFlags : TK_CreateRAFlags;

  procedure SaveInds(  UDCSDim : TK_UDCSDim; UDCDim : TK_UDCDim; Inds : TN_IArray; var RAInds : TK_RArray );
  begin
    if (UDCSDim = nil) and (UDCDim <> nil) then begin
    //*** Save Col CDim Indices
      if RAInds = nil then
        RAInds := K_CreateRACSDim( UDCDim, K_cdrList, WCRFlags );
      with RAInds do begin
        Count := Length(Inds);
        ASetLength( Count );
        if Count > 0 then
          Move( Inds[0], P^, Count * SizeOf(Integer) );
      end;
    end else if (UDCSDim <> nil) then
      K_SetUDRefField( TN_UDBase(RAInds), UDCSDim, true );
  end;

  procedure SaveRel( var ResRel : TObject; BufRARel : TK_RArray; UDRel : TN_UDBase );
  begin
    if ResRel = nil then begin
    // No Relation
      if UDRel <> nil then
        K_SetUDRefField( TN_UDBase(ResRel), UDRel, (RACRDBlock.FEType.D.CFlags and K_ccCountUDRef) <> 0 )
      else if BufRARel <> nil then
        TK_RArray(ResRel) := K_RCopy( BufRARel, [K_mdfCountUDRef,K_mdfCopyRArray] );
    end else if ResRel is TN_UDBase then begin
    // Reference to Commom Relation
      if UDRel <> nil then
        K_SetUDRefField( TN_UDBase(ResRel), UDRel, (RACRDBlock.FEType.D.CFlags and K_ccCountUDRef) <> 0 )
      else begin
        TN_UDBase(ResRel).UDDelete();
        if BufRARel <> nil then
          TK_RArray(ResRel) := K_RCopy( BufRARel, [K_mdfCountUDRef,K_mdfCopyRArray] );
      end;
    end else begin
    // Built-In Relation
      TK_RArray(ResRel).ARelease;
      ResRel := nil;
      if UDRel <> nil then
        K_SetUDRefField( TN_UDBase(ResRel), UDRel, (RACRDBlock.FEType.D.CFlags and K_ccCountUDRef) <> 0 )
      else if BufRARel <> nil then
        TK_RArray(ResRel) := K_RCopy( BufRARel, [K_mdfCountUDRef,K_mdfCopyRArray] );
    end;
  end;

begin
  if PageControl.ActivePage <> DataTSheet then begin
    PageControl.ActivePageIndex := 0;
    PageControlChange(nil);
  end;

  with RACRDBlock do begin
//***!!! Store Block CDIRefs before storing ColsRel, RowsRel and Data (before resize Block RArray)
    FRACDIRefs.StoreToSData();
    with TK_PCSDBAttrs(PA)^ do begin
      Count := RACDIRefs.ALength;
      if (CBRel = nil) and (Count > 0) then
        CBRel := K_CreateRACDRel( nil, 0, K_cdrList, [K_crfCountUDRef] );
      if (CBRel <> nil) and (Count = 0) then
        CBRel.ARelease
      else
        K_SetRACDRelFromIRefs( CBRel, RACDIRefs.P, Count );
    end;

    WCRFlags := [];
    if (FEType.D.CFlags and K_ccCountUDRef) <> 0 then WCRFlags  := WCRFlags + [K_crfCountUDRef];
    FrameCSDBDataEdit.SaveData;
    Count := RAData.ALength;
    ASetLength( Count );
    if Count > 0 then
      SetElems( RAData.P^, false );
    HCol := RAData.HCol;
    with TK_PCSDBAttrs(PA)^ do begin
      SaveRel( ColsRel, CurRAColCDRel, CurColUDCDRel );
      SaveRel( RowsRel, CurRARowCDRel, CurRowUDCDRel );
    end;
  end;
end; // end of TK_FrameCSDBLockEdit.SaveDataToCRDBlock

//***********************************  TK_FrameCSDBLockEdit.RebuildCurFrameExecute
// Cur Frame RebuildGrid Action Handler
//
procedure TK_FrameCSDBlockEdit.RebuildCurFrameExecute(Sender: TObject);
begin
  if PageControl.ActivePage = DataTSheet then
    FrameCSDBDataEdit.RebuildGridExecute( Sender )
  else if PageControl.ActivePage = CSItemsTSheet then
    FrameCDIRefs.RebuildGridExecute( Sender )
  else if PageControl.ActivePage = ColsTSheet then
    FrameColECDRel.FrRACDRel.RebuildGridExecute( Sender )
  else if PageControl.ActivePage = RowsTSheet then
    FrameRowECDRel.FrRACDRel.RebuildGridExecute( Sender );

end; // end of TK_FrameCSDBLockEdit.RebuildCurFrameExecute

//***********************************  TK_FrameCSDBLockEdit.TranspCurFrameExecute
// Cur Frame TranspGrid Action Handler
//
procedure TK_FrameCSDBlockEdit.TranspCurFrameExecute(Sender: TObject);
begin
  if PageControl.ActivePage = DataTSheet then begin
    FrameCSDBDataEdit.TranspGridExecute( Sender );
    K_InterchangeTActionsFields( SetRowCDRel, SetColCDRel );
    K_InterchangeTActionsFields( ClearRowCDRel, ClearColCDRel );
    SwitchTabSheetCaptions;
  end else if PageControl.ActivePage = CSItemsTSheet then
    FrameCDIRefs.TranspGridExecute( Sender )
  else if PageControl.ActivePage = ColsTSheet then
    FrameColECDRel.FrRACDRel.TranspGridExecute( Sender )
  else if PageControl.ActivePage = RowsTSheet then
    FrameRowECDRel.FrRACDRel.TranspGridExecute( Sender );
end; // end of TK_FrameCSDBLockEdit.TranspCurFrameExecute

//***********************************  TK_FrameCSDBLockEdit.SetDBlockCSDim
// Set Data Block CSDim
//
function TK_FrameCSDBlockEdit.SetDBlockCSDim( SelCaption : string; var Count : Integer;
                              var UDCDRel : TK_UDCDRel; var RACDRel : TK_RArray ) : TK_CDRType;
var
  UDCDimOrCSDim : TN_UDBase;

begin
//*** Select Columns CDim, CSDim or CDRel
  Result := K_cdrAny;
  UDCDimOrCSDim := nil;
  if not K_SelectUDNode( UDCDimOrCSDim,
        SelectObjsUDRoot, CDimAndIndsFilter.UDFTest, SelCaption, true  ) then Exit;

  if UDCDimOrCSDim is TK_UDCDim then begin
    Result := K_cdrList;
    UDCDRel := nil;
    RACDRel := K_CreateRACDRel( @UDCDimOrCSDim, 1, K_cdrList, [] );
    Count := Min(Count, TK_UDCDim(UDCDimOrCSDim).CDimCount);
    with RACDRel do begin
      ASetLength( Count );
      if Count > 0 then
        K_FillIntArrayByCounter( P, Count );
    end;
  end else begin // CSDim or CDRel
    TN_UDBase(UDCDRel) := UDCDimOrCSDim;
    RACDRel := TK_UDRArray(UDCDimOrCSDim).R;
    with RACDRel, TK_PCDRelAttrs(PA)^ do begin
      Count := ARowCount;
      Result := CDRType;
    end;
  end;
end; // end of TK_FrameCSDBLockEdit.SetDBlockCSDim

//***********************************  TK_FrameCSDBLockEdit.SetColCDRelExecute
// Change Columns CSDim Action Handler
//
procedure TK_FrameCSDBlockEdit.SetColCDRelExecute(Sender: TObject);
var
 ColCount, RowCount : Integer;
 CDIType : TK_CDRType;

begin
//*** Select Columns CDim or CDimInds
  RAData.ALength( ColCount, RowCount );
  CDIType := SetDBlockCSDim( '¬ыбор готового отношени€ или измерени€ дл€ создани€ встроенного отношени€ дл€ колонок',
                              ColCount, CurColUDCDRel, CurRAColCDRel );
  if CDIType = K_cdrAny then Exit;

  SetColCDRel.Enabled := false;
  ClearColCDRel.Enabled := true;
  ColsTSheet.TabVisible := CurColUDCDRel = nil;

  FrameColECDRel.ShowRACDRel( CurRAColCDRel );

  RAData.ASetLength(ColCount, RowCount);

  FrameCSDBDataEdit.ShowBlockData( RAData, CurRAColCDRel, CurRARowCDRel );

  if Assigned(OnDataChange) then OnDataChange;
end; // end of TK_FrameCSDBLockEdit.SetColCDRelExecute

//***********************************  TK_FrameCSDBLockEdit.SetRowCDRelExecute
// Change Columns CSDim Action Handler
//
procedure TK_FrameCSDBlockEdit.SetRowCDRelExecute(Sender: TObject);
var
 ColCount, RowCount : Integer;
 CDIType : TK_CDRType; // CDim Inds Type
begin
//*** Select Rows CDim or CDimInds
  RAData.ALength( ColCount, RowCount );
  CDIType := SetDBlockCSDim( '¬ыбор готового отношени€ или измерени€ дл€ создани€ встроенного отношени€ дл€ р€дов',
                              RowCount, CurRowUDCDRel, CurRARowCDRel );
  if CDIType = K_cdrAny then Exit;

  SetRowCDRel.Enabled := false;
  ClearRowCDRel.Enabled := true;
  RowsTSheet.TabVisible := CurRowUDCDRel = nil;

  FrameRowECDRel.ShowRACDRel( CurRARowCDRel );

  RAData.ASetLength(ColCount, RowCount);

  FrameCSDBDataEdit.ShowBlockData( RAData, CurRAColCDRel, CurRARowCDRel );

  if Assigned(OnDataChange) then OnDataChange;
end; // end of TK_FrameCSDBLockEdit.SetRowCDRelExecute

//***********************************  TK_FrameCSDBLockEdit.ClearColCDRelExecute
// Clear Columns CSDim Action Handler
//
procedure TK_FrameCSDBlockEdit.ClearColCDRelExecute(Sender: TObject);
begin
  if CurColUDCDRel <> nil then
    CurColUDCDRel := nil
  else
    CurRAColCDRel.ARelease;
  CurRAColCDRel := nil;
  FrameCSDBDataEdit.ShowBlockData( RAData, CurRAColCDRel, CurRARowCDRel );
  SetColCDRel.Enabled := true;
  ColsTSheet.TabVisible := false;
  ClearColCDRel.Enabled := false;
  if Assigned(OnDataChange) then OnDataChange;
end; // end of TK_FrameCSDBLockEdit.ClearColCSDimExecute

//***********************************  TK_FrameCSDBLockEdit.ClearRowCDRelExecute
// Clear Rows CSDim Action Handler
//
procedure TK_FrameCSDBlockEdit.ClearRowCDRelExecute(Sender: TObject);
begin
  if CurRowUDCDRel <> nil then
    CurRowUDCDRel := nil
  else
    CurRARowCDRel.ARelease;
  CurRARowCDRel := nil;
  FrameCSDBDataEdit.ShowBlockData( RAData, CurRAColCDRel, CurRARowCDRel );
  SetRowCDRel.Enabled := true;
  RowsTSheet.TabVisible := false;
  ClearRowCDRel.Enabled := false;
  if Assigned(OnDataChange) then OnDataChange;
end; // end of TK_FrameCSDBLockEdit.ClearRowCDRelExecute

end.
