unit K_FMVMSOExp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ComCtrls, Menus, ToolWin, ActnList, StdCtrls, Buttons, Dialogs, ExtCtrls,
  N_BaseF, N_GCont, N_Types, N_CompBase, N_Comp3,
  K_WSBuild1, K_DCSpace, K_UDT1, K_FrRaEdit, K_Script1, K_IMVDar, K_MVObjs;

type
  TK_FormMVMSOExport = class(TN_BaseForm)
    RAEditFrame: TK_FrameRAEdit;
    ActionList1: TActionList;
    ClearMVData       : TAction;
    StoreSelectedElems: TAction;
    ShowMap           : TAction;
    ShowHist1C        : TAction;
    ShowHistNC        : TAction;
    BuildWDoc         : TAction;
    PrintWDoc         : TAction;
    PrinterSetup      : TAction;
    DeleteElems       : TAction;
    EditComponent     : TAction;
    ShowMVTETree      : TAction;
    ShowAnyComp       : TAction;

    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;

    ToolBar1   : TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;

    CmBMaps  : TComboBox;
    CmBHist1C: TComboBox;
    CmBHistNC: TComboBox;
    CmBWFragm: TComboBox;

    BBShowMap   : TBitBtn;
    BBShowHist1C: TBitBtn;
    BBShowHistNC: TBitBtn;
    BBCreateDoc : TBitBtn;
    BBPrintDoc  : TBitBtn;
    BitBtn1     : TBitBtn;

    ChBUseMap   : TCheckBox;
    ChBUseHist1C: TCheckBox;
    ChBUseHistNC: TCheckBox;

    GroupBox1: TGroupBox;

    LbPageNum    : TLabel;
    LbCopyCount  : TLabel;
    LbWFragm     : TLabel;

    EdPageNum    : TEdit;
    EdCopyCount  : TEdit;
    EdPrinterType: TEdit;

    StatusBar: TStatusBar;

    PrinterSetupDialog: TPrinterSetupDialog;

    Timer: TTimer;

    UpDPageNum: TUpDown;
    UpDCopyNum: TUpDown;

    PopupMenuEditComponent: TPopupMenu;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    ChBColorScheme: TCheckBox;
    ToolButton4: TToolButton;
    CmBRusFO: TComboBox;

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;

    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;

    procedure ClearMVDataExecute(Sender: TObject);
    procedure CmBMapsChange(Sender: TObject);
    procedure CmBHist1CChange(Sender: TObject);
    procedure CmBHistNCChange(Sender: TObject);
    procedure CmBWFragmChange(Sender: TObject);
    procedure ShowMapExecute(Sender: TObject);
    procedure ShowHist1CExecute(Sender: TObject);
    procedure ShowHistNCExecute(Sender: TObject);
    procedure BuildWDocExecute(Sender: TObject);
    procedure PrintWDocExecute(Sender: TObject);
    procedure PrinterSetupDialogClose( Sender: TObject );
    procedure TimerTimer( Sender: TObject );
    procedure PrinterSetupExecute(Sender: TObject);
    procedure StoreSelectedElemsExecute(Sender: TObject);
    procedure DeleteElemsExecute(Sender: TObject);
    procedure UpDChangingEx( Sender: TObject;
                             var AllowChange: Boolean; NewValue: Smallint;
                             Direction: TUpDownDirection);
    procedure EditComponentExecute(Sender: TObject);
    procedure ShowAnyCompExecute(Sender: TObject);
    procedure PopupMenuEditComponentPopup(Sender: TObject);
    procedure CmBContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ShowMVTETreeExecute(Sender: TObject);
    procedure ChBColorSchemeClick(Sender: TObject);
    procedure CmBRusFOChange(Sender: TObject);
  private
    { Private declarations }
    PMVRComAttrs:  TK_PMVRComAttrs; // MVR CommonAttrs
    PMVRCSAttrs :  TK_PMVRCSAttrs; // MVR CS CommonAttrs
    CurDCSpace  :  TN_UDBase; // Current Data Code Space Object
    MapListInd : Integer; // Map Components List Index
    RWFListInd : Integer; // Root WFragments List Index
    H1CListInd : Integer; // 1Column Histograms List Index
    HNCListInd : Integer; // NColumns Histograms List Index
    TabListInd : Integer; // Tables List Index
    PageNum    : Integer; // Start Page Number
    CopyCount  : Integer; // Copies Count
    LDTBuilder : TK_MVLDiagramAndTableBuilder1;
    ScanMVUDSubTree : TK_ScanMVUDSubTree;
    ActivCmB : TComboBox; // Active ComboBox
    CurComp : TN_UDBase;  // Current Component from Active ComboBox
    FDL : TStringList;
//    UsePrevRFCoordsState : Boolean; // Calc by Current Form State
    InitRFCoordsState : Boolean;    // Used for Direct Command
    ColorSchemeInd : Integer;

    procedure SetMVRCSContext; // Set Context while changing CS
    function  SetComboBox( CmB : TComboBox; RA : TK_RArray; Ind : Integer ) : Boolean;
    procedure GetDataSection( var Ind, Count : Integer );
    function  BuildH1CCompParams( Ind : Integer; BuildParams : Boolean ) : Boolean;
    function  CreateDoc( AEPExecFlags : TN_EPExecFlags ): TN_WordDoc;
    function  PrepUDVTree : Boolean;
//    function  GetUDCompFromList( CompsList : TK_RArray; Ind : Integer ) : TN_UDBase;
//    procedure RedrawUDComAction( Sender : TObject; ActionType : TK_RAFGlobalAction );
    function  RedrawUDComAction( Sender : TObject; ActionType: TK_RAFGlobalAction) : Boolean;
    function  PrepCompViewForm( ASelfName : string; CreateFlag : Boolean ) : TForm;
    procedure ShowCompViewForm( CVForm : TForm; ACaption : string; UDComp : TN_UDCompVis );
    procedure DataIndChange();
    function  GetMapCorDiagram( AUDMVWCartWin : TN_UDBase ): TK_UDMVWLDiagramWin;
  public
    { Public declarations }
    UDVTree: TN_VTree;
    MVDataRArray:  TK_RArray;    // Array of TK_UDMVWCartWin Objects with image content
    FRAControl  : TK_FRAData;    // used with RAEditFrame
    ExpObjsList : TList;         // List Prepared by BuildExpObjsList
    CurMapCList : TK_RArray;   // Map Components List (ArrayOf TK_MVRNCList) (2 elements>: 0 - Portrait, 1 - Landscape)
    RusFO : TN_IArray;

    procedure SetMVObjects( const Objects; Count : Integer; ReplaceExisted : Boolean );
    procedure SetMVRAObjects( AMVDataRArray: TK_RArray; ReplaceExisted : Boolean );
    procedure SetMVListObjects( AMVList: TList; ReplaceExisted : Boolean = false );
    function  GetCurDCSpace : TN_UDBase;
    function  BuildExpObjsList( ScanRootsVNodesList : TList = nil ): Boolean;
  end;

var
  K_FormMVMSOExport: TK_FormMVMSOExport;

function K_GetFormMVMSOExport( AOwner : TN_BaseForm = nil ) : TK_FormMVMSOExport;

implementation

uses
  Math, Printers,
  K_FViewComp, K_UDC, K_Arch, {K_DTE1,} K_MVMap0, K_IndGlobal, K_Types, K_CLib,
  K_VFunc,
  N_UDCMap, N_Lib0, N_Rast1Fr, N_CompCL, N_ME1, N_RVCTF, N_Lib1, N_ButtonsF;

{$R *.dfm}

function K_GetFormMVMSOExport( AOwner : TN_BaseForm = nil ) : TK_FormMVMSOExport;
begin
  if K_FormMVMSOExport = nil then begin
    Result := TK_FormMVMSOExport.Create(Application);
    Result.BaseFormInit( AOwner );
    K_FormMVMSOExport := Result;
  end else
    Result := K_FormMVMSOExport;
end;


//*************************************** TK_FormMVMSOExport.FormShow
//
procedure TK_FormMVMSOExport.FormShow(Sender: TObject);
var
  UDCA : TK_UDRArray;
  EWF, EH1, EHN, E : Boolean;
  CRCSS : TK_UDDCSSpace;
  WInd, WCount, i, CSInd : Integer;
  PCRCSS : PInteger;
  WStr : string;
begin
  inherited;
  BBShowMap.Caption := '';
  BBShowHist1C.Caption := '';
  BBShowHistNC.Caption := '';
//*** Build Component Lists
  UDCA := TK_UDRArray( K_GetMVDarSysFolder( K_msdMVRCAFolder ).DirChild(0) );

  E := UDCA <> nil;
  EWF := E;
  EH1 := E;
  EHN := E;
  if E then
  begin
    PMVRComAttrs := TK_PMVRComAttrs(UDCA.R.P);
    EWF := SetComboBox( CmBWFragm, PMVRComAttrs^.EP.DWFCList, RWFListInd );
    RWFListInd := CmBWFragm.ItemIndex;
    EH1 := SetComboBox( CmBHist1C, PMVRComAttrs^.EP.H1CCList, H1CListInd );
    H1CListInd := CmBHist1C.ItemIndex;
    EHN := SetComboBox( CmBHistNC, PMVRComAttrs^.EP.HNCCList, HNCListInd );
    HNCListInd := CmBHistNC.ItemIndex;
    K_GroupRegDCSpace := K_CurSpacesRoot.DirChildByObjName( 'Россия', K_ontObjUName );
    CmBRusFO.Visible := K_GroupRegDCSpace <> nil;
    if CmBRusFO.Visible then
    begin
      CRCSS := TK_UDDCSSpace(TK_UDDCSpace(K_GroupRegDCSpace).GetSSpacesDir.DirChildByObjName('CRCSS'));
      WInd := CRCSS.IndexByCode( '300' ); // Get CSSpace Index
      PCRCSS := CRCSS.DP;
      WCount := CRCSS.PDRA.ALength;
      PCRCSS := PInteger(TN_BytesPtr(PCRCSS) + WInd * SizeOf(Integer));
      for i := WInd to WCount - 1 do
      begin
        CSInd := PCRCSS^;
        TK_UDDCSpace(K_GroupRegDCSpace).GetItemsInfo( @WStr, K_csiCSName, CSInd );
        if i = WInd then CSInd := -2;
        CmBRusFO.Items.AddObject( WStr, TObject(CSInd) );
        Inc(PCRCSS);
      end;
      CmBRusFO.ItemIndex := 0;
    end;
  end
  else
    PMVRComAttrs := nil;

  CmBWFragm.Enabled := EWF;
  BBCreateDoc.Enabled := EWF;
  BBPrintDoc.Enabled := EWF;

  ChBUseHist1C.Enabled := EH1;
  ShowHist1C.Enabled := EH1;
  CmBHist1C.Enabled := EH1;

  ChBUseHistNC.Enabled := EHN;
  ShowHistNC.Enabled := EHN;
  CmBHistNC.Enabled := EHN;

  EdPageNum.Text := IntToStr( PageNum );
  EdCopyCount.Text := IntToStr( CopyCount );
  EdPrinterType.Text := Printer.Printers[Printer.PrinterIndex];

  StoreSelectedElems.Enabled := PrepUDVTree;

end; //*** end of procedure TK_FormMVMSOExport.FormShow

//*************************************** TK_FormMVMSOExport.FormCreate
//
procedure TK_FormMVMSOExport.FormCreate(Sender: TObject);
begin
  inherited;
  MVDataRArray := K_RCreateByTypeCode( Ord(nptUDRef) );
  CurMapCList  := K_RCreateByTypeName( 'TK_MVRNCList', 0, [] );
  FRAControl := TK_FRAData.Create( RAEditFrame );
  FRAControl.SkipDataBuf := false;
  FRAControl.SkipAddToEmpty := true;
  FRAControl.SkipClearEmptyRArrays := true;
  FRAControl.PrepFrame1( [],
      [K_ramRowChangeOrder, K_ramRowChangeNum, K_ramColVertical,
      K_ramSkipResizeWidth, K_ramSkipResizeHeight,
      K_ramFillFrameWidth,K_ramSkipColsMark],
      MVDataRArray, MVDataRArray.GetArrayType, '  №  ', 'Данные' );
//  RAEditFrame.CDescr.ColResizeMode := K_crmHeaderBased;
  RAEditFrame.OnLRowChange := DataIndChange;

  LDTBuilder := TK_MVLDiagramAndTableBuilder1.Create;
  LDTBuilder.OrderFlags := [K_dofDescendingOrder];
  ScanMVUDSubTree := TK_ScanMVUDSubTree.Create;
  ExpObjsList := TList.Create;
  FDL := TStringList.Create;

end; //*** end of procedure TK_FormMVMSOExport.FormCreate

//*************************************** TK_FormMVMSOExport.FormClose
//
procedure TK_FormMVMSOExport.FormClose( Sender: TObject; var Action: TCloseAction);
var
  WForm : TForm;
begin
  WForm := PrepCompViewForm( 'MVDarMap', false );
  if WForm <> nil then WForm.Close;
  WForm := PrepCompViewForm( 'MVDarHist1', false );
  if WForm <> nil then WForm.Close;
  WForm := PrepCompViewForm( 'MVDarHistN', false );
  if WForm <> nil then WForm.Close;

  K_FormMVMSOExport := nil;
  FRAControl.Free();
  MVDataRArray.ARelease();
  CurMapCList.ARelease();
  LDTBuilder.Free;
  ScanMVUDSubTree.Free;
  ExpObjsList.Free;
  FDL.Free;

  Inherited;
end; //*** end of procedure TK_FormMVMSOExport.FormClose

//*************************************** TK_FormMVMSOExport.SetMVObjects
//
procedure TK_FormMVMSOExport.SetMVObjects( const Objects; Count : Integer; ReplaceExisted : Boolean );
var
  StartInd : Integer;
begin

  StartInd := 0;
  if not ReplaceExisted then begin
    FRAControl.StoreToSData();
    StartInd := MVDataRArray.ALength;
  end;
  MVDataRArray.ASetLength( StartInd + Count );
  if Count > 0 then
    Move( Objects, MVDataRArray.P(StartInd)^, Count * SizeOf(Integer) );
  FRAControl.SetNewData( MVDataRArray );
  RAEditFrame.RebuildGridExecute(nil);
  if Count <= 0 then begin
    CurStateToMemIni();
    Exit;
  end;

  if StartInd = 0 then SetMVRCSContext;
  RAEditFrame.SelectLRect( -1, StartInd, -1, MVDataRArray.ALength );

//*** Init Component Edit Controls

end; //*** end of procedure TK_FormMVMSOExport.SetMVObjects

//*************************************** TK_FormMVMSOExport.SetMVRAObjects
//
procedure TK_FormMVMSOExport.SetMVRAObjects( AMVDataRArray: TK_RArray; ReplaceExisted : Boolean );
begin
  SetMVObjects( AMVDataRArray.P^, AMVDataRArray.ALength, ReplaceExisted );
end; //*** end of procedure TK_FormMVMSOExport.SetMVRAObjects

//*************************************** TK_FormMVMSOExport.SetMVListObjects
//
procedure TK_FormMVMSOExport.SetMVListObjects( AMVList: TList; ReplaceExisted : Boolean = false );
begin
  SetMVObjects( AMVList.List[0], AMVList.Count, ReplaceExisted );
end; //*** end of procedure TK_FormMVMSOExport.SetMVListObjects

//*************************************** TK_FormMVMSOExport.ClearMVDataExecute
//
procedure TK_FormMVMSOExport.ClearMVDataExecute(Sender: TObject);
begin
  RAEditFrame.SelectLRect( 0, -1, 0, -1 );
  RAEditFrame.DelRowExecute( Sender );
end; //*** end of procedure TK_FormMVMSOExport.ClearMVDataExecute

//*************************************** TK_FormMVMSOExport.GetCurDCSpace
//
function TK_FormMVMSOExport.GetCurDCSpace : TN_UDBase;
begin
  Result := nil;
  FRAControl.StoreToSData();
  if MVDataRArray.ALength > 0 then
    Result := TK_UDVector(TK_UDMVWCartWin(TN_PUDBase(MVDataRArray.P)^).GetLayerUDVector(0)).GetDCSSpace.GetDCSpace;
end; //*** end of procedure TK_FormMVMSOExport.GetCurDCSpace

//*************************************** TK_FormMVMSOExport.PrepUDVTree
//
function TK_FormMVMSOExport.PrepUDVTree : Boolean;
begin
  if (UDVTree = nil) then begin
    if (N_VTrees.Count > 0) then
      UDVTree := TN_VTree(N_VTrees[0]);
  end;
  Result := (UDVTree <> nil);
  StoreSelectedElems.Enabled := Result;
end; //*** end of procedure TK_FormMVMSOExport.PrepVTree

//*************************************** TK_FormMVMSOExport.BuildExpObjsList
//
function TK_FormMVMSOExport.BuildExpObjsList( ScanRootsVNodesList : TList = nil ): Boolean;
var
  i : Integer;
  PrintObj : TN_UDBase;
begin
  Result := false;
  ExpObjsList.Clear;

  if (ScanRootsVNodesList = nil) then begin
    if not PrepUDVTree then Exit;
    ScanRootsVNodesList := UDVTree.MarkedVNodesList;
  end;

  if ScanRootsVNodesList.Count = 0 then Exit;
  with ScanMVUDSubTree do begin
    //*** Set Scan Filter Sys Type
    SetLength( ScanSysTypeFilter, 1 );
    ScanSysTypeFilter[0] := K_msdWebCartWins;
    //*** Set Scan Filter Code Space
    NodeFilter1 := K_FormMVMSOExport.GetCurDCSpace;
    if NodeFilter1 = nil then
    // Set Capture NodeFilter Flag
      Integer(NodeFilter1) := 1;
    for i := 0 to ScanRootsVNodesList.Count - 1  do begin
      //*** Check Root
      PrintObj := TN_VNode(ScanRootsVNodesList[i]).VNUDObj;
      IniLists();
      if BuildNodesFilteredListFunc1(PrintObj.Owner, PrintObj, 0, 0, '' ) = K_tucSkipScan then
        ExpObjsList.Assign( Nodes, laOr );
      //*** Check SubTree
      MVUDSubTreeScan( PrintObj, BuildNodesFilteredListFunc, [] );
      ExpObjsList.Assign( Nodes, laOr );
    end;
  end;
  Result := (ExpObjsList.Count > 0);

end; //*** end of procedure TK_FormMVMSOExport.BuildExpObjsList

//*************************************** TK_FormMVMSOExport.SetComboBox
//
function TK_FormMVMSOExport.SetComboBox( CmB : TComboBox; RA : TK_RArray; Ind : Integer ) : Boolean;
var
  i, Count : Integer;

begin
  Count := RA.ALength;
  Result := Count > 0;
  if not Result then Exit;
  CmB.Items.Clear;
  for i := 0 to Count - 1 do
    CmB.Items.Add( TK_PMVRNCList(RA.P(i)).ListCaption );

  if Ind >= Count then Ind := 0;
  CmB.ItemIndex := Ind;
end; //*** end of procedure TK_FormMVMSOExport.SetComboBox

//*************************************** TK_FormMVMSOExport.SetMVRCSContext
//
procedure TK_FormMVMSOExport.SetMVRCSContext;
var
  CS : TN_UDBase;
  E : Boolean;
  i, n, j : Integer;
  PMVRNCList : TK_PMVRNCList;
begin
  CS := GetCurDCSpace;
  if (MVDataRArray.ALength = 0) or (CS = CurDCSpace) or (CS = nil) then Exit;
  CurDCSpace := CS;
  MapListInd := N_MemIniToInt  ( Name+'State', CurDCSpace.ObjName+'MapListInd', 0 );
  PMVRCSAttrs := TK_UDMVWCartWin(TN_PUDBase(MVDataRArray.P)^).GetLayerPMVRCSAttrs( 0 );
  E := PMVRCSAttrs <> nil;
  if E then begin
    CurMapCList.ASetLength(0); // Clear Previous Data
    with PMVRCSAttrs^ do
    begin
      n := RCSAMapCList.ALength;
      if n = 0 then
      begin
      // Old Data - 2 components (Portrait/Landscape) List is not assigned
        K_RFreeAndCopy( CurMapCList, MapCList, [] );
      end
      else
      begin
      // New Data - 2 components (Portrait/Landscape) List
        CurMapCList.ASetLength( n * 2 );
        for i := 0 to n - 1 do
          with TK_PMVRNCList2(RCSAMapCList.P(i))^ do begin
             j := i * 2;
             PMVRNCList := TK_PMVRNCList(CurMapCList.P(j));
             PMVRNCList.ListCaption := ListCaption + ' (портрет)';
             PMVRNCList.UDComp := UDCompPT;
             PMVRNCList.SEHUDCList := SEHUDCListPT.AAddRef();

             PMVRNCList := TK_PMVRNCList(CurMapCList.P(j + 1));
             PMVRNCList.ListCaption := ListCaption + ' (альбом)';
             PMVRNCList.UDComp := UDCompLS;
             PMVRNCList.SEHUDCList := SEHUDCListLS.AAddRef();
          end;
      end;
      E := SetComboBox( CmbMaps, CurMapCList, MapListInd );
      LDTBuilder.SetCSContext( TK_UDDCSSpace(RCSAPECSS),
                               TK_UDDCSSpace(RCSACSProj),
                               TK_UDDCSSpace(RCSASCSS),
                               TK_UDVector(RCSAElemCapts),
                               TK_UDDCSSpace(RCSACRCSS) );
    end;
  end else
    PMVRCSAttrs := nil;

  ShowMap.Enabled := E;
  ChBUseMap.Enabled := E;
  CmbMaps.Enabled := E;
end; //*** end of procedure TK_FormMVMSOExport.SetMVRCSContext

//***********************************  TK_FormMVMSOExport.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormMVMSOExport.CurStateToMemIni();
begin
  inherited;
  N_BoolToMemIni ( Name+'State', 'UseMap',     ChBUseMap.Checked );
  N_BoolToMemIni ( Name+'State', 'UseHist1C',  ChBUseHist1C.Checked );
  N_BoolToMemIni ( Name+'State', 'UseHistNC',  ChBUseHistNC.Checked );
  N_BoolToMemIni ( Name+'State', 'ColorScheme',  ChBColorScheme.Checked );
  N_IntToMemIni  ( Name+'State', 'PageNum',    StrToIntDef( EdPageNum.Text, 1 ) );
  N_IntToMemIni  ( Name+'State', 'CopyCount',  StrToIntDef( EdCopyCount.Text, 1 ) );
  N_IntToMemIni  ( Name+'State', 'RWFListInd', RWFListInd );
  N_IntToMemIni  ( Name+'State', 'H1CListInd', H1CListInd );
  N_IntToMemIni  ( Name+'State', 'HNCListInd', HNCListInd );
  N_IntToMemIni  ( Name+'State', 'TabListInd', TabListInd );
  if CurDCSpace <> nil then
    N_IntToMemIni  ( Name+'State', CurDCSpace.ObjName+'MapListInd', MapListInd );
end; // end of procedure TK_FormMVMSOExport.CurStateToMemIni

//***********************************  TK_FormMVMSOExport.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormMVMSOExport.MemIniToCurState();
begin
  inherited;
  ChBUseMap.Checked    := N_MemIniToBool ( Name+'State', 'UseMap', ChBUseMap.Checked );
  ChBUseHist1C.Checked := N_MemIniToBool ( Name+'State', 'UseHist1C', ChBUseHist1C.Checked );
  ChBUseHistNC.Checked := N_MemIniToBool ( Name+'State', 'UseHistNC', ChBUseHistNC.Checked );
  ChBColorScheme.Checked := N_MemIniToBool ( Name+'State', 'ColorScheme',  ChBColorScheme.Checked );
  ColorSchemeInd := -1;
  if ChBColorScheme.Checked then ColorSchemeInd := 1;
  PageNum    := N_MemIniToInt  ( Name+'State', 'PageNum', 1 );
  CopyCount  := N_MemIniToInt  ( Name+'State', 'CopyCount', 1 );
  RWFListInd := N_MemIniToInt  ( Name+'State', 'RWFListInd', 0 );
  H1CListInd := N_MemIniToInt  ( Name+'State', 'H1CListInd', 0 );
  HNCListInd := N_MemIniToInt  ( Name+'State', 'HNCListInd', 0 );
  TabListInd := N_MemIniToInt  ( Name+'State', 'TabListInd', 0 );
end; // end of procedure TK_FormMVMSOExport.MemIniToCurState

//***********************************  TK_FormMVMSOExport.CmBMapsChange
//
procedure TK_FormMVMSOExport.CmBMapsChange(Sender: TObject);
begin
  MapListInd := CmBMaps.ItemIndex;
  InitRFCoordsState := true;
  ShowMapExecute(nil);
end; // end of procedure TK_FormMVMSOExport.CmBMapsChange

//***********************************  TK_FormMVMSOExport.CmBHist1CChange
//
procedure TK_FormMVMSOExport.CmBHist1CChange(Sender: TObject);
begin
  H1CListInd := CmBHist1C.ItemIndex;
  InitRFCoordsState := true;
  ShowHist1CExecute(nil);
end; // end of procedure TK_FormMVMSOExport.CmBHist1CChange

//***********************************  TK_FormMVMSOExport.CmBHistNCChange
//
procedure TK_FormMVMSOExport.CmBHistNCChange(Sender: TObject);
begin
  HNCListInd := CmBHistNC.ItemIndex;
  InitRFCoordsState := true;
  ShowHistNCExecute(nil);
end; // end of procedure TK_FormMVMSOExport.CmBHistNCChange

//***********************************  TK_FormMVMSOExport.CmBWFragmChange
//
procedure TK_FormMVMSOExport.CmBWFragmChange(Sender: TObject);
begin
  RWFListInd := CmBWFragm.ItemIndex;
end; // end of procedure TK_FormMVMSOExport.CmBWFragmChange

{
//***********************************  TK_FormMVMSOExport.CmBWFragmChange
//
function TK_FormMVMSOExport.GetUDCompFromList( CompsList : TK_RArray; Ind : Integer ) : TN_UDBase;
begin
  if (Ind < 0) or (Ind > CompsList.AHigh) then begin
    Ind := 0;
    if CompsList.AHigh < 0 then
      assert( false, 'Error in components list' );
  end;
  Result := TK_PMVRNCList(CompsList.P(Ind)).UDComp;
end; // end of procedure TK_FormMVMSOExport.CmBWFragmChange
}

//*************************************** TK_FormMVMSOExport.PrepCompViewForm
//
function TK_FormMVMSOExport.PrepCompViewForm( ASelfName : string; CreateFlag : Boolean ) : TForm;
begin
  Result := K_SearchOpenedForm( TK_FormViewComp, ASelfName, BFSelfOwnerForm );
  if (Result = nil) and CreateFlag then
    Result := K_CreateVCForm( BFSelfOwnerForm, ASelfName );
end; //*** end of procedure TK_FormMVMSOExport.PrepCompViewForm

//*************************************** TK_FormMVMSOExport.ShowCompViewForm
//
procedure TK_FormMVMSOExport.ShowCompViewForm( CVForm : TForm; ACaption : string;
                                               UDComp : TN_UDCompVis );
var
 FVCFlags : TK_ViewCompFlags;
begin
  FVCFlags := [];
  if InitRFCoordsState then
    Include( FVCFlags, K_vcfSetFrameState );
  TK_FormViewComp(CVForm).ShowComponent( FVCFlags, ACaption, UDComp );
end; //*** end of procedure TK_FormMVMSOExport.ShowCompViewForm

//*************************************** TK_FormMVMSOExport.DataIndChange
//
procedure TK_FormMVMSOExport.DataIndChange;
begin
  if PrepCompViewForm( 'MVDarMap', false ) <> nil then
    ShowMapExecute(nil);
  if PrepCompViewForm( 'MVDarHist1', false ) <> nil then begin
    InitRFCoordsState := true;
    ShowHist1CExecute(nil);
  end;
  if PrepCompViewForm( 'MVDarHistN', false ) <> nil then begin
    ShowHistNCExecute(nil);
  end;
end; //*** end of procedure TK_FormMVMSOExport.DataIndChange

//*************************************** TK_FormMVMSOExport.GetMapCorDiagram
//
function TK_FormMVMSOExport.GetMapCorDiagram( AUDMVWCartWin : TN_UDBase ): TK_UDMVWLDiagramWin;
var
  UDChild : TN_UDBase;
  UDRoot : TN_UDBase;
  i : Integer;
begin
    // Select Map correspondinfg Diagram Attributes
  Result := nil;
  UDRoot := AUDMVWCartWin.Owner.Owner;
  for i := 0 to UDRoot.DirHigh do
  begin
    UDChild := UDRoot.DirChild( i );
    if UDChild is TK_UDMVWLDiagramWin then
    begin
      Result := TK_UDMVWLDiagramWin(UDChild);
      Exit;
    end;
  end;
end; //*** end of procedure TK_FormMVMSOExport.GetMapCorDiagram

//*************************************** TK_FormMVMSOExport.ShowMapExecute
//
procedure TK_FormMVMSOExport.ShowMapExecute(Sender: TObject);
var
  i, Ind : Integer;
  MVCart : TN_UDBase;
  CVForm : TK_FormViewComp;


begin
//*** Prepare Component Params
  Ind := RAEditFrame.CurLRow;
  if Ind < 0 then Ind := 0;
  FRAControl.StoreToSData();
  MVCart := nil;
  if MVDataRArray.ALength > 0 then begin
    MVCart := TN_PUDBase(MVDataRArray.P(Ind))^;
//    with TK_UDMVWCartWin( MVCart ) do RebuildMapAttrs;
  end;

//*** View Component
  CVForm := TK_FormViewComp( PrepCompViewForm( 'MVDarMap', true ) );

//  with TK_PMVRNCList(PMVRCSAttrs.MapCList.P(MapListInd))^ do begin
  with TK_PMVRNCList(CurMapCList.P(MapListInd))^ do begin
    with CVForm do begin
      if PrepCompContextObj = nil then begin
        PrepCompContextObj := TK_PrepCartCompContext.Create;
        if PMVRComAttrs <> nil then
          TK_PrepCartCompContext(PrepCompContextObj).CCPColorSchemes := PMVRComAttrs.VA.ColorSchemes;
      end;
      PrepCompContextObj.CCPColorSchemeInd := ColorSchemeInd;
      with SEHUDCList do
      begin
      // Debug Code to Control Map Search Parameters for New FOM maps
        Ind := -1;
        for i := 0 to AHigh do
          if not (TN_PUDBase( P(i) )^ is TN_UDCompVis) then
          begin
            Ind := i;
            Break;
          end;
        if Ind = -1 then
      // end of Debug Code
          N_AddCompsToSearch( RFrame, TN_PUDCompVis(P), ALength );
      end;
      with TK_PrepCartCompContext(PrepCompContextObj) do
        CCPUDMVWCartWin := TK_UDMVWCartWin(MVCart);
    end;
    ShowCompViewForm( CVForm, ListCaption, TN_UDCompVis(UDComp) );
  end;

end; //*** end of procedure TK_FormMVMSOExport.ShowMapExecute

//*************************************** TK_FormMVMSOExport.ShowHist1CExecute
//
procedure TK_FormMVMSOExport.ShowHist1CExecute(Sender: TObject);
var
  Ind : Integer;
  CVForm : TK_FormViewComp;
  CVCompsList : TK_RArray;
begin
  Ind := RAEditFrame.CurLRow;
  CVCompsList := PMVRComAttrs.EP.H1CCList;
  if Ind >= 0 then begin
  //*** Build Component Params by Data Vector and attributes
    FRAControl.StoreToSData();
    LDTBuilder.Init;
    if BuildH1CCompParams( Ind, true ) and
      (PMVRComAttrs.EP.H1CCListD <> nil) and
      (H1CListInd <= PMVRComAttrs.EP.H1CCListD.AHigh) then
      CVCompsList := PMVRComAttrs.EP.H1CCListD;
  end;

  CVForm := TK_FormViewComp( PrepCompViewForm( 'MVDarHist1', true ) );
  with TK_PMVRNCList(CVCompsList.P(H1CListInd))^ do
    ShowCompViewForm( CVForm, ListCaption, TN_UDCompVis(UDComp) );

end; //*** end of procedure TK_FormMVMSOExport.ShowHist1CExecute

//*************************************** TK_FormMVMSOExport.ShowHistNCExecute
//
procedure TK_FormMVMSOExport.ShowHistNCExecute(Sender: TObject);
var
  i, Ind, Count : Integer;
  CVForm : TK_FormViewComp;
begin

//*** Build Component Params by Data Vector and attributes
  GetDataSection( Ind, Count );
  if Ind >= 0 then begin
    FRAControl.StoreToSData();
    LDTBuilder.Init;
    for i := Ind to Ind + Count - 1 do
      BuildH1CCompParams( i, false );
  end;

//*** View Component
  CVForm := TK_FormViewComp( PrepCompViewForm( 'MVDarHistN', true ) );
  with PMVRComAttrs.EP, TK_PMVRNCList(H1CCList.P(H1CListInd))^ do begin
    LDTBuilder.PrepUDComponentContext( TN_UDCompBase(UDCHNCAttrs), '', '' );
    LDTBuilder.SetUDComponentParams();
    ShowCompViewForm( CVForm, ListCaption, TN_UDCompVis(UDComp) );
  end;
end; //*** end of procedure TK_FormMVMSOExport.ShowHistNCExecute

//*************************************** TK_FormMVMSOExport.GetDataSection
//
procedure TK_FormMVMSOExport.GetDataSection( var Ind, Count : Integer );
begin
  RAEditFrame.GetSelectSection( true, Ind, Count );
  if (Count > 0) and (Ind > 0) then
    Dec( Ind )
  else begin
    Ind := RAEditFrame.CurLRow;
    Count := 1;
  end;
end; //*** end of procedure TK_FormMVMSOExport.GetDataSection

//*************************************** TK_FormMVMSOExport.BuildH1CCompParams
//
function TK_FormMVMSOExport.BuildH1CCompParams( Ind : Integer; BuildParams : Boolean ) : Boolean;
var
  UDMVWCartWin : TK_UDMVWCartWin;
  UDMVWLDiagramWin : TK_UDMVWLDiagramWin;
  CS : TK_RArray;
  LegendHText : string;
//  UDChild : TN_UDBase;
//  UDRoot : TN_UDBase;
//  i : Integer;
  UDMVAttrs : TK_UDRArray;
begin
  UDMVWCartWin := TK_UDMVWCartWin( TN_PUDBase(MVDataRArray.P(Ind))^ );
  with UDMVWCartWin, TK_PMVWebCartWin(R.P)^ do begin
    UDMVAttrs := TK_UDRArray(GetLayerUDVAttrs(0));
    Result := TK_PMVVAttrs(UDMVAttrs.PDE(0)).AddLHDataVector <> nil;
    LDTBuilder.AddVectorAndAttributes(BriefCapt, GetLayerUDVector(0), UDMVAttrs );
    if not BuildParams then Exit;
    CS := nil;
    if PMVRComAttrs <> nil then CS := PMVRComAttrs.VA.ColorSchemes;

    // Select Map correspondinfg Diagram Attributes
{
    UDMVWLDiagramWin := nil;
    UDRoot := UDMVWCartWin.Owner.Owner;
    for i := 0 to UDRoot.DirHigh do
    begin
      UDChild := UDRoot.DirChild( i );
      if UDChild is TK_UDMVWLDiagramWin then
      begin
        UDMVWLDiagramWin := TK_UDMVWLDiagramWin(UDChild);
        break;
      end;
    end;
}
    LegendHText := TK_PMVCartLayer1(TK_UDMVWCartLayer(UDMVWCartWin.DirChild(0)).R.P).LegHeader;
    UDMVWLDiagramWin := GetMapCorDiagram( UDMVWCartWin );
    if UDMVWLDiagramWin <> nil then // Change DiagramBuilder Context by Diagram Attributes
      with TK_PMVWebLDiagramWin(UDMVWLDiagramWin.R.P)^ do
      begin
        TN_UDBase(LDTBuilder.Sel2CSS) := CSProj1;
//        LegendHText := LegHeader;
      end;

    with PMVRComAttrs.EP do begin
      LDTBuilder.PrepUDComponentContext( TN_UDCompBase(UDCH1CAttrs), PageCaption, LegendHText );
      LDTBuilder.SetUDComponentParams( ColorSchemeInd, CS );
    end;
  end;
end; //*** end of procedure TK_FormMVMSOExport.BuildH1CCompParams

//*************************************** TK_FormMVMSOExport.CreateDoc
//  Create
function TK_FormMVMSOExport.CreateDoc( AEPExecFlags : TN_EPExecFlags ): TN_WordDoc;
var
  RootComp : TN_UDCompBase;
  Ind, Count : Integer;
  UseMap, UseH1C, UseHNC : Boolean;
  i, LInd : Integer;
  UDMVWCartWin : TK_UDMVWCartWin;
  UDMVWLDiagramWin : TK_UDMVWLDiagramWin;
  CS : TK_RArray;
  LegendHText : string;
  CVCompsList : TK_RArray;
  UDMVAttrs : TK_UDRArray;
//  ExpParams: TN_ExpParams;
begin
  Result := nil;
  UseMap := ChBUseMap.Enabled and ChBUseMap.Checked;
  UseH1C := ChBUseHist1C.Enabled and ChBUseHist1C.Checked;
  UseHNC := ChBUseHistNC.Enabled and ChBUseHistNC.Checked;
  if not UseMap and not UseH1C and not UseHNC then begin
    StatusBar.SimpleText := ' Не заданы визуальные компоненты. Создание документа прервано ';
    Exit;
  end;

  GetDataSection( Ind, Count );
  if Ind < 0 then begin
    StatusBar.SimpleText := ' Не заданы объекты для включения в документ. Создание документа прервано ';
    Exit;
  end;
  FRAControl.StoreToSData();

//  if N_MEGlobObj.RastVCTForm <> nil then begin
//    N_MEGlobObj.RastVCTForm.Close();
//    Application.ProcessMessages;
//  end;

  with TK_PMVRNCList(PMVRComAttrs.EP.DWFCList.P(RWFListInd))^ do
    RootComp  := TN_UDCompVis(UDComp);
    //*** Start creating document

  PageNum := StrToIntDef( EdPageNum.Text, 1 );
  EdPageNum.Text := IntToStr( PageNum );
  RootComp.SetSUserParInt( 'NumPage', PageNum );

//  Result := TN_GlobCont.Create();
  StatusBar.SimpleText := ' Начато создание документа ';

//  Result := TN_WordDoc.Create( RootComp, '(#OutFiles#)result.doc', AEPExecFlags );
  Result := TN_WordDoc.Create;
  Result.StartCreating( RootComp, '(#OutFiles#)result.doc', AEPExecFlags );
  if Result.WDGCont.GCProperWordIsAbsent then begin // Word97 or less
    Result.Free;
    Result := nil;
    StatusBar.SimpleText := ' Отсутствует нужная версия MS Word. Создание документа прервано ';
    Exit;
  end; // if Result.WDGCont.GCWSMajorVersion <= 8 then // Word97 or less
{
  RootComp.DynParent := nil; // root component

  FillChar( ExpParams, SizeOf(ExpParams), 0 );
  ExpParams.EPMainFName := '(#OutFiles#)result.doc';
  ExpParams.EPExecFlags := AEPExecFlags;

  Result.PrepForExport( RootComp, @ExpParams );
  Result.ExecuteComp( RootComp, [cifRootComp] );
}
  LDTBuilder.Init;
  LInd := 0;
  CS := nil;
  if PMVRComAttrs <> nil then CS := PMVRComAttrs.VA.ColorSchemes;
  for i := Ind to Ind + Count - 1 do begin
    UDMVWCartWin := TK_UDMVWCartWin( TN_PUDBase(MVDataRArray.P(i))^ );
    // Select Map correspondinfg Diagram Attributes
{
    UDMVWLDiagramWin := nil;
    UDRoot := UDMVWCartWin.Owner.Owner;
    for j := 0 to UDRoot.DirHigh do
    begin
      UDChild := UDRoot.DirChild( j );
      if UDChild is TK_UDMVWLDiagramWin then
      begin
        UDMVWLDiagramWin := TK_UDMVWLDiagramWin(UDChild);
        break;
      end;
    end;
    if UDMVWLDiagramWin <> nil then // Change DiagramBuilder Context by Diagram Attributes
      TN_UDBase(LDTBuilder.Sel2CSS) := TK_PMVWebLDiagramWin(UDMVWLDiagramWin.R.P)^.CSProj;
}
    if UseMap then begin
      UDMVWCartWin.RebuildMapAttrs( nil, false, ColorSchemeInd, CS );
//      with TK_PMVRNCList(PMVRCSAttrs.MapCList.P(MapListInd))^ do
      with TK_PMVRNCList(CurMapCList.P(MapListInd))^ do
        Result.AddComponent( TN_UDCompBase(UDComp) );
//        TN_UDCompBase(UDComp).ExecInNewGCont([cifSeparateGCont]);     // Create Clipboard content
//      Result.WordPasteClipBoard();
    end;

    with UDMVWCartWin, TK_PMVWebCartWin(R.P)^ do
    begin
      UDMVAttrs := TK_UDRArray(GetLayerUDVAttrs(0));
      LDTBuilder.AddVectorAndAttributes(BriefCapt, GetLayerUDVector(0), UDMVAttrs );
      if UseH1C then
      begin // One column Histogram
{
  CVCompsList := PMVRComAttrs.EP.H1CCList;
  if Ind >= 0 then begin
  //*** Build Component Params by Data Vector and attributes
    FRAControl.StoreToSData();
    LDTBuilder.Init;
    if BuildH1CCompParams( Ind, true ) and
      (PMVRComAttrs.EP.H1CCListD <> nil) and
      (H1CListInd <= PMVRComAttrs.EP.H1CCListD.AHigh) then
      CVCompsList := PMVRComAttrs.EP.H1CCListD;
  end;

  CVForm := TK_FormViewComp( PrepCompViewForm( 'MVDarHist1', true ) );
  with TK_PMVRNCList(CVCompsList.P(H1CListInd))^ do
    ShowCompViewForm( CVForm, ListCaption, TN_UDCompVis(UDComp) );
}


        LegendHText := TK_PMVCartLayer1(TK_UDMVWCartLayer(UDMVWCartWin.DirChild(0)).R.P).LegHeader;
        UDMVWLDiagramWin := GetMapCorDiagram( UDMVWCartWin );
        if UDMVWLDiagramWin <> nil then // Change DiagramBuilder Context by Diagram Attributes
          with TK_PMVWebLDiagramWin(UDMVWLDiagramWin.R.P)^ do
          begin
            TN_UDBase(LDTBuilder.Sel2CSS) := CSProj1;
          end;

        with PMVRComAttrs.EP do
        begin
          CVCompsList := PMVRComAttrs.EP.H1CCList;
          if (TK_PMVVAttrs(UDMVAttrs.PDE(0)).AddLHDataVector <> nil) and
             (H1CCListD <> nil) then
            CVCompsList := H1CCListD;
          with TK_PMVRNCList(CVCompsList.P(H1CListInd))^ do
          begin
            LDTBuilder.PrepUDComponentContext( TN_UDCompBase(UDCH1CAttrs), PageCaption, LegendHText );
            LDTBuilder.SetUDComponentParams( ColorSchemeInd, CS, false, @LInd, 1 );
            Result.AddComponent( TN_UDCompBase(UDComp) );
  //          TN_UDCompBase(UDComp).ExecInNewGCont([cifSeparateGCont]);     // Create Clipboard content
          end;
        end;
//        Result.WordPasteClipBoard();
        Inc(LInd);
      end;
    end;

  end; // end of loop Export Components to Document

  if UseHNC then
  begin  // N columns Histogram
    with PMVRComAttrs.EP, TK_PMVRNCList(HNCCList.P(HNCListInd))^ do begin
      LDTBuilder.PrepUDComponentContext( TN_UDCompBase(UDCHNCAttrs), '', '' );
      LDTBuilder.SetUDComponentParams( ColorSchemeInd, CS );
      Result.AddComponent( TN_UDCompBase(UDComp) );
//      TN_UDCompBase(UDComp).ExecInNewGCont([cifSeparateGCont]);     // Create Clipboard content
    end;
//    Result.WordPasteClipBoard();
  end;

  StatusBar.SimpleText := ' Завершено создание документа ';

end; //*** end of procedure TK_FormMVMSOExport.CreateDoc

//*************************************** TK_FormMVMSOExport.BuildWDocExecute
//
procedure TK_FormMVMSOExport.BuildWDocExecute(Sender: TObject);
var
//  CurGCont: TN_GlobCont;
  WordDoc : TN_WordDoc;
  SavedCursor : TCursor;
  SavedMEWordFlags: TN_MEWordFlags;
begin
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  SavedMEWordFlags := N_MEGlobObj.MEWordFlags; // a precaution
  N_MEGlobObj.MEWordFlags := [mewfUseVBA];

  //2006-10-25  WordDoc := CreateDoc( [epefNotCloseDoc,epefShowAfter] );
  WordDoc := CreateDoc( [] );
  if WordDoc <> nil then begin
    WordDoc.FinishCreating();
    WordDoc.Free;
  end;
  Screen.Cursor := SavedCursor;
  N_MEGlobObj.MEWordFlags := SavedMEWordFlags;
{
  CurGCont := CreateDoc( [epefNotCloseDoc,epefShowAfter] );
  if CurGCont = nil then Exit;
  CurGCont.FinishExport();
  CurGCont.GCMainDoc := Unassigned(); // Free reference to Created Document
  CurGCont.Free;
}
end; //*** end of procedure TK_FormMVMSOExport.BuildWDocExecute

//*************************************** TK_FormMVMSOExport.PrintDocExecute
//
procedure TK_FormMVMSOExport.PrintWDocExecute(Sender: TObject);
var
//  CurGCont: TN_GlobCont;
//  SavedMEWordFlags: TN_MEWordFlags;
//    if mewfCloseResDoc in N_MEGlobObj.MEWordFlags then

  WordDoc : TN_WordDoc;
  SavedCursor : TCursor;
begin
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
//2006-10-25  WordDoc := CreateDoc( [epefNotCloseDoc] );
  WordDoc := CreateDoc( [] );
  if WordDoc <> nil then begin
    StatusBar.SimpleText := ' Начата печать документа ';
//    N_b := WordDoc.WDGCont.GCWordServer.Visible;
//    WordDoc.WDGCont.GCWordServer.Visible := true;
    WordDoc.WDGCont.GCWordServer.ActivePrinter := EdPrinterType.Text;

    CopyCount := StrToIntDef( EdCopyCount.Text, 1 );
    EdCopyCount.Text := IntToStr( CopyCount );
    WordDoc.WDGCont.GCWordServer.PrintOut( Copies := CopyCount );
    WordDoc.WDGCont.GCWSVBAFlags := WordDoc.WDGCont.GCWSVBAFlags + [mewfCloseResDoc];
    WordDoc.FinishCreating();
    WordDoc.Free;
    StatusBar.SimpleText := ' Окончена печать документа ';
  end;
//  Exclude(N_MEGlobObj.MEWordFlags, mewfCloseResDoc);
  Screen.Cursor := SavedCursor;
//  N_MEGlobObj.MEWordFlags := SavedMEWordFlags;
end; //*** end of procedure TK_FormMVMSOExport.PrintDocExecute

//*************************************** TK_FormMVMSOExport.PrinterSetupDialogClose
//
procedure TK_FormMVMSOExport.PrinterSetupDialogClose( Sender: TObject );
// Setting Current Info about Printer is impossible inside this handler
// because Printer object was not yet changed by Delphi.
// Real setting will take place by Self.GetPrinterInfo() method, which
// would be called from OnTimer event handler (see just bellow)
begin
  Timer.Enabled := True;
  StatusBar.SimpleText := '';
end; //*** end of procedure TK_FormMVMSOExport.PrinterSetupDialogClose

//*************************************** TK_FormMVMSOExport.TimerTimer
//
procedure TK_FormMVMSOExport.TimerTimer( Sender: TObject );
// Update once Current Info about Printer by Self.ShowPrinterInfo() method
begin
  Timer.Enabled := False;
//  CopyCount := Printer.Copies;
//  EdCopyCount.Text := IntToStr( CopyCount );
  EdPrinterType.Text := Printer.Printers[Printer.PrinterIndex];
end; //*** end of procedure TK_FormMVMSOExport.TimerTimer

//*************************************** TK_FormMVMSOExport.PrinterSetupExecute
//
procedure TK_FormMVMSOExport.PrinterSetupExecute(Sender: TObject);
begin
//  Printer.Copies := CopyCount;
  PrinterSetupDialog.Execute();
end; //*** end of procedure TK_FormMVMSOExport.TimerTimer

//*************************************** TK_FormMVMSOExport.StoreSelectedElemsExecute
//
procedure TK_FormMVMSOExport.StoreSelectedElemsExecute(Sender: TObject);
var
  i, Ind, Count : Integer;
  UDParent : TN_UDBase;
  VNode : TN_VNode;
  NewFolder : TN_UDBase;
  ResStr : string;

  function TestParent : Boolean;
  begin
    Result := not UDParent.AddChildToSubTree(nil) or
             ( UDParent.CanAddOwnChildByPar( Ord(K_msdFolder) ) and
               UDParent.CanAddChildByPar( Ord(K_msdFolder) ) );
  end;

begin
  GetDataSection( Ind, Count );
  if Ind < 0 then begin
    StatusBar.SimpleText := ' Не заданы объекты для соxранения';
    Exit;
  end;

  if not PrepUDVTree then begin
    StatusBar.SimpleText := ' Не задано место для сохранения';
    Exit;
  end;

  VNode := UDVTree.GetSelectedVnode( );
  if VNode = nil then
    UDParent := K_CurUserRoot
  else begin
    UDParent := VNode.VNUDObj;
    if not TestParent then begin
      UDParent := VNode.GetParentUObj;
      if not TestParent then
        UDParent := K_CurUserRoot;
    end
  end;
  NewFolder := K_MVDarNewUserNodeAdd( K_msdFolder, nil, UDParent, ResStr,
                                      'Группа для экспорта' );
  K_SetChangeSubTreeFlags( NewFolder );
//  NewFolder.SetChangedSubTreeFlag;

  StatusBar.SimpleText := ResStr;

//*** Add Selected Objects
  FRAControl.StoreToSData();

  for i := Ind to Count - 1 do
    NewFolder.AddOneChild( TN_PUDBase( MVDataRArray.P(i) )^ );

  NewFolder.RebuildVNodes();

end; //*** end of procedure TK_FormMVMSOExport.StoreSelectedElemsExecute

//*************************************** TK_FormMVMSOExport.DeleteElemsExecute
//
procedure TK_FormMVMSOExport.DeleteElemsExecute(Sender: TObject);
begin
  RAEditFrame.DelRowExecute( Sender );
end; //*** end of procedure TK_FormMVMSOExport.DeleteElemsExecute

//*************************************** TK_FormMVMSOExport.UpDChangingEx
//
procedure TK_FormMVMSOExport.UpDChangingEx( Sender: TObject;
                                 var AllowChange: Boolean; NewValue: Smallint;
                                 Direction: TUpDownDirection);
var
  Step : Integer;
begin

  if updUp = Direction then
   Step := 1
  else if updDown = Direction then
   Step := -1
  else Exit;
  if Sender = UpDPageNum then begin
  // Change Start Page Number
    PageNum := StrToIntDef(EdPageNum.Text, PageNum);
    PageNum := PageNum + Step;
    EdPageNum.Text := IntToStr(PageNum);
  end else begin
  // Change Copies Number
    CopyCount := StrToIntDef(EdCopyCount.Text, CopyCount);
    CopyCount := CopyCount + Step;
    EdCopyCount.Text := IntToStr(CopyCount);
  end;
end; //*** end of procedure TK_FormMVMSOExport.UpDChangingEx

//*************************************** TK_FormMVMSOExport.EditComponentExecute
//
procedure TK_FormMVMSOExport.EditComponentExecute( Sender: TObject );
begin
  K_EditAppUDTreeData( CurComp, nil, TK_UDRArray(FDL.Objects[TComponent(Sender).Tag]),
                       Self, RedrawUDComAction, true );
end; //*** end of procedure TK_FormMVMSOExport.EditComponentExecute

//*************************************** TK_FormMVMSOExport.ShowAnyCompExecute
//
procedure TK_FormMVMSOExport.ShowAnyCompExecute(Sender: TObject);
begin
  if ActivCmB = CmBMaps then ShowMapExecute(Sender)
  else if ActivCmB = CmBHist1C then ShowHist1CExecute(Sender)
  else if ActivCmB = CmBHistNC then ShowHistNCExecute(Sender);
end; //*** end of procedure TK_FormMVMSOExport.ShowAnyCompExecute

//*************************************** TK_FormMVMSOExport.PopupMenuEditComponentPopup
//
procedure TK_FormMVMSOExport.PopupMenuEditComponentPopup(Sender: TObject);
var
  i, n : Integer;
begin
  FDL.Clear;
  ShowMVTETree.Enabled := CurComp <> nil;
  if ShowMVTETree.Enabled then
    K_GetUDTreeFormDescrsList( CurComp, FDL );

  n := Min( PopupMenuEditComponent.Items.Count - 2, FDL.Count );
  for i := 0 to n - 1 do
    with PopupMenuEditComponent.Items[i + 2] do begin
      Caption := FDL[i];
      Visible := true;
      Tag := i;
    end;
  for i := PopupMenuEditComponent.Items.Count - 1 downto n + 2 do
    PopupMenuEditComponent.Items[i].Visible := false;

end; //*** end of procedure TK_FormMVMSOExport.PopupMenuEditComponentPopup

//*************************************** TK_FormMVMSOExport.CmBContextPopup
//
procedure TK_FormMVMSOExport.CmBContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  ActivCmB := TComboBox(Sender);
  CurComp := nil;
  if ActivCmB = CmBMaps then
//    with TK_PMVRNCList(PMVRCSAttrs.MapCList.P(MapListInd))^ do CurComp := UDComp
    with TK_PMVRNCList(CurMapCList.P(MapListInd))^ do CurComp := UDComp
  else if ActivCmB = CmBHist1C then
    with PMVRComAttrs.EP, TK_PMVRNCList(H1CCList.P(H1CListInd))^ do CurComp := UDComp
  else if ActivCmB = CmBHistNC then
    with PMVRComAttrs.EP, TK_PMVRNCList(HNCCList.P(HNCListInd))^ do CurComp := UDComp;
end; //*** end of procedure TK_FormMVMSOExport.CmBContextPopup

//*************************************** TK_FormMVMSOExport.RedrawUDComAction
//
//procedure TK_FormMVMSOExport.RedrawUDComAction( Sender : TObject; ActionType: TK_RAFGlobalAction);
function TK_FormMVMSOExport.RedrawUDComAction( Sender : TObject; ActionType: TK_RAFGlobalAction) : Boolean;
begin
  Result := true;
  if ActionType <> K_fgaCancelToAll then
    N_ActiveRFrame.RedrawAllAndShow();

end; //*** end of procedure TK_FormMVMSOExport.RedrawUDComAction

//*************************************** TK_FormMVMSOExport.ShowMVTETreeExecute
//
procedure TK_FormMVMSOExport.ShowMVTETreeExecute(Sender: TObject);
begin
  K_CallMVTEExecute( CurComp );
end; //*** end of procedure TK_FormMVMSOExport.ShowMVTETreeExecute

//*************************************** TK_FormMVMSOExport.ChBColorSchemeClick
//
procedure TK_FormMVMSOExport.ChBColorSchemeClick(Sender: TObject);
begin
  ColorSchemeInd := -1;
  if ChBColorScheme.Checked then ColorSchemeInd := 1;
  DataIndChange();
end; //*** end of procedure TK_FormMVMSOExport.ChBColorSchemeClick

//*************************************** TK_FormMVMSOExport.CmBRusFOChange ***
//
procedure TK_FormMVMSOExport.CmBRusFOChange(Sender: TObject);
begin
  K_GroupRegDCSInd := Integer(CmBRusFO.Items.Objects[CmBRusFO.ItemIndex]);
  K_GroupRegDCSProj := nil;
  if K_GroupRegDCSInd < 0 then Exit;
  K_GroupRegDCSProj := TK_UDDCSpace(K_GroupRegDCSpace).SearchProjByElemIndex( K_GroupRegDCSInd );
end; // procedure TK_FormMVMSOExport.CmBRusFOChange

end.
