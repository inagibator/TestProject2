unit N_CObjVectEdF;
// CObj Vector Editor Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Contnrs,
  Dialogs, Menus, ActnList, ComCtrls, ToolWin, StdCtrls, ExtCtrls,
  N_Types, N_Lib0, N_Lib1, N_BaseF, N_UDat4, N_Rast1Fr, N_UDCMap, N_ACEdF,
  N_UObj2Fr, N_PixMesFr;

type TN_CObjVectEditorForm = class( TN_BaseForm ) // CObj Vector Editor Form
    MainMenu1: TMainMenu;
    ActionList1: TActionList;
    File1: TMenuItem;
    Notyet1: TMenuItem;
    ToolBar1: TToolBar;
    PageControl: TPageControl;
    StatusBar: TStatusBar;
    tsFlags1: TTabSheet;
    tsFlags2: TTabSheet;
    tsActs1: TTabSheet;
    tsActs2: TTabSheet;
    ToolButton1: TToolButton;
    rbMarkCObj: TRadioButton;
    rbEditItemCode: TRadioButton;
    rbAffConvLine: TRadioButton;
    rbSplitCombLine: TRadioButton;
    rbDeleteLine: TRadioButton;
    rbNewLine: TRadioButton;
    rbEnlargeLine: TRadioButton;
    rbDeleteVertex: TRadioButton;
    rbAddVertex: TRadioButton;
    rbMoveVertex: TRadioButton;
    rbEmptyAction1: TRadioButton;
    rgSnapMode: TRadioGroup;
    rgHighlightSV: TRadioGroup;
    rgHighlightL: TRadioGroup;
    rgSplitMode: TRadioGroup;
    rgMoveComVert: TRadioGroup;
    rbMoveLabel: TRadioButton;
    rbEditLabel: TRadioButton;
    rbEmptyAction2: TRadioButton;
    rbMovePoint: TRadioButton;
    rbAddPoint: TRadioButton;
    rbDeletePoint: TRadioButton;
    tsOther: TTabSheet;
    rbEditRegCodes: TRadioButton;
    rbSetItemCodes: TRadioButton;
    rbAddLabel: TRadioButton;
    rbDeleteLabel: TRadioButton;
    tsShape: TTabSheet;
    aOtherCreateShape: TAction;
    aEdSplitItem: TAction;
    aEdCombineParts: TAction;
    aEdAffConvMarked: TAction;
    aEdAffConvLayer: TAction;
    AffConvMarked1: TMenuItem;
    AffConvLayer1: TMenuItem;
    ShapePageControl: TPageControl;
    tsRoundRect: TTabSheet;
    tsOld: TTabSheet;
    rgShapeType: TRadioGroup;
    edShapeR2: TLabeledEdit;
    edShapeR1: TLabeledEdit;
    edShapeNumVerts: TLabeledEdit;
    edShapeCenter: TLabeledEdit;
    edShapeAngle: TLabeledEdit;
    bnCreateShape: TButton;
    tsRegPolyFragm: TTabSheet;
    bnCreateRPFragm: TButton;
    edRPFUpperLeft: TLabeledEdit;
    edRPFLowerRight: TLabeledEdit;
    edScaleCoef: TLabeledEdit;
    edAngleBeg: TLabeledEdit;
    edAngleSize: TLabeledEdit;
    edRPFNumSegments: TLabeledEdit;
    edRRUpperLeft: TLabeledEdit;
    edRadiusX: TLabeledEdit;
    edRRLowerRight: TLabeledEdit;
    edRadiusY: TLabeledEdit;
    edRRNumSegments: TLabeledEdit;
    bnCreateRR: TButton;
    aEdSetRCToMarked: TAction;
    aEdSetRCToLayer: TAction;
    SetRegionCodesToMarked1: TMenuItem;
    SetRegionCodesToLayer1: TMenuItem;
    aEdMoveMarked: TAction;
    aEdCopyMarked: TAction;
    CopyMarked1: TMenuItem;
    MoveMarked1: TMenuItem;
    PageControl1: TPageControl;
    tsGeneral: TTabSheet;
    tsStats: TTabSheet;
    edEdGFlags: TLabeledEdit;
    cbMultiSelect: TCheckBox;
    edRedrawLLWPixSize: TLabeledEdit;
    edSearchSize: TLabeledEdit;
    cbStayOnTop: TCheckBox;
    Label1: TLabel;
    frAuxCL: TN_UObj2Frame;
    aEdDeleteAll: TAction;
    N1: TMenuItem;
    ClearAllItems1: TMenuItem;
    aEdDeleteMarked: TAction;
    DeleteMarkedItemsParts1: TMenuItem;
    aEdUnSparseLayer: TAction;
    UnSparseLayer1: TMenuItem;
    aFileEditComment: TAction;
    Other1: TMenuItem;
    CreateShape1: TMenuItem;
    EditCObjComment1: TMenuItem;
    edOSMinSize: TLabeledEdit;
    edOSMaxSize: TLabeledEdit;
    edOSNumGroups: TLabeledEdit;
    View1: TMenuItem;
    aViewSegments: TAction;
    ViewSegments1: TMenuItem;
    edCDimInd: TLabeledEdit;
    aEdCopySavedStrings: TAction;
    CopySavedStrings1: TMenuItem;
    N2: TMenuItem;
    ToolButton2: TToolButton;
    PixMesFrame: TN_PixMesFrame;

    //********* File  Actions  ********************************
    procedure aFileEditCommentExecute ( Sender: TObject );

    //********* Edit  Actions  ********************************
    procedure aEdCopySavedStringsExecute ( Sender: TObject );
    procedure aEdSplitItemExecute     ( Sender: TObject );
    procedure aEdCombinePartsExecute  ( Sender: TObject );
    procedure aEdAffConvMarkedExecute ( Sender: TObject );
    procedure aEdAffConvLayerExecute  ( Sender: TObject );
    procedure aEdSetRCToMarkedExecute ( Sender: TObject );
    procedure aEdSetRCToLayerExecute  ( Sender: TObject );

    procedure aEdCopyMarkedExecute    ( Sender: TObject );
    procedure aEdMoveMarkedExecute    ( Sender: TObject );
    procedure aEdUnSparseLayerExecute ( Sender: TObject );

    procedure aEdDeleteMarkedExecute  ( Sender: TObject );
    procedure aEdDeleteAllExecute     ( Sender: TObject );

    procedure ConvMarked ( Mode: integer; AAffCoefs: TN_AffCoefs8 );
    procedure ConvLayer  ( Mode: integer; AAffCoefs: TN_AffCoefs8 );

    //********* View  Actions  ********************************
    procedure aViewSegmentsExecute ( Sender: TObject );

    //********* Other  Actions  ********************************
    procedure aOtherCreateShapeExecute ( Sender: TObject );

    //********* Flags1 TabSheet handlers  **************************
    procedure rgHighlightLClick  ( Sender: TObject );
    procedure rgHighlightSVClick ( Sender: TObject );
    procedure rgSnapModeClick    ( Sender: TObject );

    //********* Flags2 TabSheet handlers  **************************
    procedure rgMoveComVertClick ( Sender: TObject );
    procedure rgSplitModeClick   ( Sender: TObject );

    //********* Acts1 TabSheet handlers  ***************************
    procedure rbEmptyAction1Click ( Sender: TObject );

    procedure rbSnapToCObjClick   ( Sender: TObject );
    procedure rbMarkCObjClick     ( Sender: TObject );
    procedure rbSetItemCodesClick ( Sender: TObject );
    procedure rbEditItemCodeClick ( Sender: TObject );
    procedure rbEditRegCodesClick ( Sender: TObject );

    procedure rbMoveVertexClick   ( Sender: TObject );
    procedure rbAddVertexClick    ( Sender: TObject );
    procedure rbDeleteVertexClick ( Sender: TObject );

    procedure rbEnlargeLineClick   ( Sender: TObject );
    procedure rbNewLineClick       ( Sender: TObject );
    procedure rbDeleteLineClick    ( Sender: TObject );
    procedure rbSplitCombLineClick ( Sender: TObject );
    procedure rbAffConvLineClick   ( Sender: TObject );

    //********* Acts2 TabSheet handlers  ***************************
    procedure rbMovePointClick    ( Sender: TObject );
    procedure rbAddPointClick     ( Sender: TObject );
    procedure rbDeletePointClick  ( Sender: TObject );

    procedure rbMoveLabelClick    ( Sender: TObject );
    procedure rbAddLabelClick     ( Sender: TObject );
    procedure rbDeleteLabelClick  ( Sender: TObject );
    procedure rbEditLabelClick    ( Sender: TObject );

    //********* Shape TabSheet Handlers  ***************************
    procedure edShapeCenterDblClick ( Sender: TObject );
    procedure edShapeR1DblClick     ( Sender: TObject );
    procedure edShapeR2DblClick     ( Sender: TObject );

    procedure bnCreateRRClick      ( Sender: TObject );
    procedure bnCreateRPFragmClick ( Sender: TObject );

    //********* Other TabSheet handlers***************************
    procedure cbMultiSelectClick        ( Sender: TObject );
    procedure cbStayOnTopClick          ( Sender: TObject );
    procedure edRedrawLLWPixSizeKeyDown ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure edCDimIndKeyDown          ( Sender: TObject; var Key: Word; Shift: TShiftState );

    //********************* Other Handlers
    procedure PageControlChange ( Sender: TObject );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  public
    EdRFrame:     TN_Rast1Frame; // RastFrame used by Vector Editor
    EdMaplayer:   TN_UDMaplayer; // Map Layer Component beeing Edited
    EdPCMaplayer: TN_PCMaplayer; // Pointer to Map Layer Static Params
    EdCObjLayer:  TN_UCObjLayer; // MLCObj of Map Layer beeing Edited
    EditGroup:    TN_SGMLayers;  //
    PrevActivePage: TTabSheet;   //
    EdError:       boolean;      // Some Error (is used after calling Actions manualy)
    EdSavedStatusBar: TStatusBar; // used for saving and resoring N_GlobObj.GOStatusBar2

    //***** These vars are used for AffConvLayer and AffConvMarked
    AffCoefsEditorForm: TN_AffCoefsEditorForm;
    CurCObjLayer: TN_UCObjLayer;
    SavedCObjLayer: TN_UCObjLayer;
    SkipRedrawing: Pointer; // bool flag used in TN_RFAMarkCObjPart.RedrawAction

    procedure CVEdFInit ( ARFrame: TN_Rast1Frame; AMaplayer: TN_UDMaplayer );
    procedure CurArchiveChanged (); override;
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
end; // type TN_CObjVectEditorForm = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

function N_CreateCObjVectEditorForm ( AOwner: TN_BaseForm ): TN_CObjVectEditorForm;


implementation
uses Math,
  K_CLib, K_CLib0,
  N_Gra0, N_Gra1, N_ClassRef, N_GS1, N_Lib2, N_MsgDialF, N_VRE3, N_EdStrF,
  N_InfoF, N_ME1, N_ButtonsF;
{$R *.dfm}

//****************  TN_CObjVectEditorForm Actions and Handlers  ******************

    //*********  Actions  ********************************


    //********* File  Actions  ********************************

procedure TN_CObjVectEditorForm.aFileEditCommentExecute( Sender: TObject );
// Edit CObj Comment
begin
  N_EditText( EdCObjLayer.WComment, Self );
end; // procedure TN_CObjVectEditorForm.aFileEditCommentExecute


    //********* Edit  Actions  ********************************

procedure TN_CObjVectEditorForm.aEdCopySavedStringsExecute( Sender: TObject );
begin
  K_PutTextToClipboard( EditGroup.SavedStrings.Text );
  EditGroup.SavedStrings.Clear;
end; // procedure TN_CObjVectEditorForm.aEdCopySavedStringsExecute

procedure TN_CObjVectEditorForm.aEdSplitItemExecute( Sender: TObject );
// Split Item by Marked Part: all Parts including Marked one remain in
// current Item, all other Parts are moved to new Item
begin
// not implemented
end; // procedure TN_CObjVectEditorForm.aEdSplitItemExecute

procedure TN_CObjVectEditorForm.aEdCombinePartsExecute( Sender: TObject );
// move all marked Parts except first to Item with first marked Part
begin
// not implemented
end; // procedure TN_CObjVectEditorForm.aEdCombinePartsExecute

procedure TN_CObjVectEditorForm.aEdAffConvMarkedExecute( Sender: TObject );
// Aff Conv Marked objects in Dialog, using ConvAndShowMarked method
// TN_UCObjEditorForm should be opened, otherwise N_SVectEditGName
// with List of Marked CObjects would be destroyed
var
  SG: TN_SGMLayers;
begin
  if N_ActiveRFrame = nil then
  begin
    N_MessageDlg( 'RFrame not choosen!', mtInformation, [mbOK], 0 );
    Exit;
  end;

  if AffCoefsEditorForm <> nil then // already opened
  begin
    AffCoefsEditorForm.SetFocus;
    Exit;
  end;

  with N_ActiveRFrame do
    SG := TN_SGMLayers(RFSGroups[GetGroupInd( N_SVectEditGName )]);

  if Length(SG.MarkedCObjParts) = 0 then
  begin
    N_MessageDlg( 'No Marked Objects!', mtInformation, [mbOK], 0 );
    Exit;
  end;

  CurCObjLayer := SG.MarkedCObjParts[0].MCObj;
  SavedCObjLayer := N_CreateCObjCopy( CurCObjLayer );

  AffCoefsEditorForm := N_CreateAffCoefsEditorForm( N_ActiveRFrame, Self );
  SkipRedrawing := Pointer(1); // to prevent redrawing while AffCoefsEditorForm exists
  with AffCoefsEditorForm do
  begin
    BegAffCoefs      := N_DefAffCoefs8;
    CurBaseAffCoefs  := N_DefAffCoefs8;
    CurFinalAffCoefs := N_DefAffCoefs8;
    ApplyProc := ConvMarked;
    BFOnCloseActions.AddNewClearVarAction( @AffCoefsEditorForm );
    BFOnCloseActions.AddNewClearVarAction( @SkipRedrawing );
    Show();
  end;
end; // procedure TN_CObjVectEditorForm.aEdAffConvMarkedExecute

procedure TN_CObjVectEditorForm.aEdAffConvLayerExecute( Sender: TObject );
// Aff Conv whole CObjLayer in Dialog, using Self.ConvLayer method
var
  SG: TN_SGMLayers;
begin
  if N_ActiveRFrame = nil then
  begin
    N_MessageDlg( 'RFrame not choosen!', mtInformation, [mbOK], 0 );
    Exit;
  end;

  if AffCoefsEditorForm <> nil then // already opened
  begin
    AffCoefsEditorForm.SetFocus;
    Exit;
  end;

  SavedCObjLayer.Free;

  with N_ActiveRFrame do
  begin
    ShowCoordsType := cctUser;
    SG := TN_SGMLayers(RFSGroups[GetGroupInd( N_SVectEditGName )]);
  end;

  CurCObjLayer := TN_UDMapLayer(SG.SComps[0].SComp).PISP()^.MLCObj;
  SavedCObjLayer := N_CreateCObjCopy( CurCObjLayer );

  rgHighLightL.ItemIndex := 0;  // clear lines highlighting
  rgHighLightSV.ItemIndex := 0;

  AffCoefsEditorForm := N_CreateAffCoefsEditorForm( N_ActiveRFrame, Self );
  with AffCoefsEditorForm do
  begin
    BegAffCoefs      := N_DefAffCoefs8;
    CurBaseAffCoefs  := N_DefAffCoefs8;
    CurFinalAffCoefs := N_DefAffCoefs8;
    ApplyProc := ConvLayer; // see just bellow
    BFOnCloseActions.AddNewClearVarAction( @AffCoefsEditorForm );
    Show();
  end; // with AffCoefsEditorForm do

end; // procedure TN_CObjVectEditorForm.aEdAffConvLayerExecute

procedure TN_CObjVectEditorForm.aEdSetRCToMarkedExecute( Sender: TObject );
// Set same Region Codes to all Items with Marked Parts
var
  i, NumCodesInts: integer;
  WrkBCodes: TN_IArray;
  SG: TN_SGMLayers;
begin
  if N_ActiveRFrame = nil then
  begin
    N_MessageDlg( 'RFrame not choosen!', mtInformation, [mbOK], 0 );
    Exit;
  end;

  with N_ActiveRFrame do
    SG := TN_SGMLayers(RFSGroups[GetGroupInd( N_SVectEditGName )]);

  for i := 0 to High(SG.MarkedCObjParts) do
  with SG.MarkedCObjParts[i], MCObj do
  begin

    if i = 0 then // Set new Reg Codes to first Item
    begin
      N_EditItemsCodes( MCObj, MItem, 1, 'Edit Codes for Marked Items :' );
      MCObj.GetItemAllCodes( MItem, WrkBCodes, NumCodesInts );
    end else // set Reg Codes to all other Items
      MCObj.SetItemAllCodes( MItem, @WrkBCodes[0], NumCodesInts );

  end; // for i := 0 to High(MarkedCObjParts) do
end; // procedure TN_CObjVectEditorForm.aEdSetRCToMarkedExecute

procedure TN_CObjVectEditorForm.aEdSetRCToLayerExecute( Sender: TObject );
// Set same Region Codes to all Layer Items
var
  SG: TN_SGMLayers;
begin
  if N_ActiveRFrame = nil then
  begin
    N_MessageDlg( 'RFrame not choosen!', mtInformation, [mbOK], 0 );
    Exit;
  end;

  with N_ActiveRFrame do
    SG := TN_SGMLayers(RFSGroups[GetGroupInd( N_SVectEditGName )]);

  CurCObjLayer := TN_UDMapLayer(SG.SComps[0].SComp).PISP()^.MLCObj;

  N_s := CurCObjLayer.ObjName; // debug

  if CurCObjLayer.CI <> N_ULinesCI then
  begin
    N_MessageDlg( 'Is not ULines CObj!', mtInformation, [mbOK], 0 );
    Exit;
  end;

  with CurCObjLayer do
    N_EditItemsCodes( CurCObjLayer, 0, WNumItems,
                                         'Edit Region Codes for all Items :' );

end; // procedure TN_CObjVectEditorForm.aEdSetRCToLayerExecute

procedure TN_CObjVectEditorForm.aEdCopyMarkedExecute( Sender: TObject );
// Copy marked Elements (Items or Parts) to Aux CObjLayer
var
  i, ItemCode: integer;
  AuxCL: TN_UCObjLayer;
  SG: TN_SGMLayers;
begin
  EdError := False;
  if not (frAuxCL.UObj is TN_UCObjLayer) then
  begin
    N_MessageDlg( 'Aux CObj Layer not given!', mtInformation, [mbOK], 0 );
    EdError := True;
    Exit;
  end;
  AuxCL := TN_UCObjLayer(frAuxCL.UObj);

  with EdRFrame do
    SG := TN_SGMLayers(RFSGroups[GetGroupInd( N_SVectEditGName )]);

  for i := 0 to High(SG.MarkedCObjParts) do // along marked Elements (Items or Parts)
  with SG.MarkedCObjParts[i] do
  begin

    if AuxCL.CI <> MCObj.CI then Continue; // skip if not same type

//    ItemCode := MCObj.GetItemCode( MItem );
    ItemCode := 123456; // temporary

    if AuxCL.CI = N_UDPointsCI then //************* Add one Point as new Item
    begin
      TN_UDPoints(AuxCL).AddOnePointItem( TN_UDPoints(MCObj).GetPointCoords(
                                                     MItem, MPart ), ItemCode );
    end else if AuxCL.CI = N_ULinesCI then //****** Add one Line Part as new Item
    begin
      TN_ULines(AuxCL).AddULItem( TN_ULines(MCObj), MItem, MPart, 1 );
    end else if AuxCL.CI = N_UContoursCI then //*** Add one Contour as new Item
    begin
      TN_UContours(AuxCL).AddUCItem( TN_UContours(MCObj), MItem );
    end;

  end; // for i := 0 to High(MarkedCObjParts) do

end; // procedure TN_CObjVectEditorForm.aEdCopyMarkedExecute

procedure TN_CObjVectEditorForm.aEdMoveMarkedExecute( Sender: TObject );
// Move Marked Parts to Aux CObjLayer
begin
  aEdCopyMarkedExecute( nil );
  if EdError then Exit;
  aEdDeleteMarkedExecute( nil );
end; // procedure TN_CObjVectEditorForm.aEdMoveMarkedExecute

procedure TN_CObjVectEditorForm.aEdUnSparseLayerExecute( Sender: TObject );
// UnSparse Layer
var
  SG: TN_SGMLayers;
  CObjLayer: TN_UCObjLayer;
begin
  if N_ActiveRFrame = nil then
  begin
    N_MessageDlg( 'RFrame not choosen!', mtInformation, [mbOK], 0 );
    Exit;
  end;

  with N_ActiveRFrame do
    SG := TN_SGMLayers(RFSGroups[GetGroupInd( N_SVectEditGName )]);

  CObjLayer := TN_UDMapLayer(SG.SComps[0].SComp).PISP()^.MLCObj;
  N_s := CObjLayer.ObjName; // debug

  CObjLayer.UnSparseSelf();

end; // procedure TN_CObjVectEditorForm.aEdUnSparseLayerExecute

procedure TN_CObjVectEditorForm.aEdDeleteMarkedExecute( Sender: TObject );
// Delete Marked Elements (Items or Parts)
var
  i, NumItems: integer;
  SG: TN_SGMLayers;
begin
  with EdRFrame do
    SG := TN_SGMLayers(RFSGroups[GetGroupInd( N_SVectEditGName )]);

  NumItems := Length(SG.MarkedCObjParts);

  for i := 0 to NumItems-1 do // along marked Elements (Items or Parts)
  with SG.MarkedCObjParts[i] do
  begin

    if MCObj.CI = N_UDPointsCI then //***************** Delete one Point
      TN_UDPoints(MCObj).DeleteOnePoint( MItem, MPart )
    else if MCObj.CI = N_ULinesCI then //************** Delete one Line Part
      TN_ULines(MCObj).DeleteParts( MItem, MPart, 1 )
    else if MCObj.CI = N_UContoursCI then //*********** Delete one Contour
      MCObj.SetEmptyFlag( MItem, 1 );

  end; // for i := 0 to NumItems-1 do

  EdRFrame.ShowString( $01, IntToStr(NumItems) + '  Elems Deleted' );
  EdRFrame.RedrawAllAndShow();
end; // procedure TN_CObjVectEditorForm.aEdDeleteMarkedExecute

procedure TN_CObjVectEditorForm.aEdDeleteAllExecute( Sender: TObject );
// Delete All Items
begin
  EdRFrame.ShowString( $01, IntToStr(EdCObjLayer.WNumItems) + '  Items Deleted' );
  EdCObjLayer.InitItems( 0 );
  EdRFrame.RedrawAllAndShow();
end; // procedure TN_CObjVectEditorForm.aEdDeleteAllExecute

procedure TN_CObjVectEditorForm.ConvMarked( Mode: integer; AAffCoefs: TN_AffCoefs8 );
// Convert Marked Objects by given Coefs and Redraw Map in N_ActiveRFRame
// (used in aEdDAffConvMarkedExecute as AffCoefsEditorForm.ApplyProc)
// Restore original coords if Mode = 1
var
  i, FirstInd, NumInds: integer;
  DC: TN_DPArray;
  SG: TN_SGMLayers;
begin
  if N_ActiveRFrame = nil then Exit; // a precaution

  // AAffCoefs are coefs. for Saved --> Current convertion

  CurCObjLayer.CopyFields( SavedCObjLayer );

  if Mode <> 1 then // do aff. convertion
  begin
  with N_ActiveRFrame do
    SG := TN_SGMLayers(RFSGroups[GetGroupInd( N_SVectEditGName )]);

  for i := 0 to High(SG.MarkedCObjParts) do
  with SG.MarkedCObjParts[i] do
  begin

    if CurCObjLayer.CI = N_UDPointsCI then //**************** Conv Points
    with TN_UDPoints(CurCObjLayer) do
    begin
      GetItemInds( MItem, FirstInd, NumInds ); // NumInds - Points group size (usually=1)
      CCoords[FirstInd+MPart] :=
                     N_AffConv8D2DPoint( CCoords[FirstInd+MPart], AAffCoefs );
    end else if CurCObjLayer.CI = N_ULinesCI then //******** Conv Lines
    with TN_ULines(CurCObjLayer) do
    begin
      GetPartDCoords( MItem, MPart, DC );
      N_AffConvCoords( AAffCoefs, DC, DC );
      SetPartDCoords( MItem, MPart, DC );
    end;

  end; // for i := 0 to High(MarkedCObjParts) do
  end; // if Mode <> 1 then // do aff. convertion

  N_ActiveRFrame.RedrawAllAndShow();
end; // procedure TN_CObjVectEditorForm.ConvMarked

procedure TN_CObjVectEditorForm.ConvLayer( Mode: integer; AAffCoefs: TN_AffCoefs8 );
// Convert Layer by given Coefs and Redraw Map in N_ActiveRFRame
// (used in aEdDAffConvLayerExecute as AffCoefsEditorForm.ApplyProc)
// Restore original coords if Mode = 1
begin
  // AAffCoefs are coefs. for Saved --> Current convertion

  CurCObjLayer.CopyFields( SavedCObjLayer );

  if Mode <> 1 then
    CurCObjLayer.AffConvSelf( AAffCoefs );

  if N_ActiveRFrame = nil then Exit; // a precaution
  N_ActiveRFrame.RedrawAllAndShow();
end; // procedure TN_CObjVectEditorForm.ConvLayer


    //********* View  Actions  ********************************

procedure TN_CObjVectEditorForm.aViewSegmentsExecute( Sender: TObject );
// View Segments, temporary version - cleared while scaling
var
  i, j, k, NumParts, NumGroups, GroupInd, RetCode: integer;
  MinSize, MaxSize, SegmSize, GrMin, GrMax, Delta: double;
  NumSegms: TN_IArray;
  DCoords: TN_DPArray;
  CurCObj: TN_UCObjLayer;
begin
  NumGroups := StrToInt( edOSNumGroups.Text );
  Val( edOSMinSize.Text, MinSize, RetCode );
  Val( edOSMaxSize.Text, MaxSize, RetCode );

  CurCObj := EdMaplayer.PCMapLayer^.MLCObj;
  if not (CurCObj is TN_ULines) then
  begin
    StatusBar.SimpleText := 'Cur CObj is NOT Lines!';
    Exit;
  end;

  if NumGroups <= 0 then NumGroups := 1;
  SetLength( NumSegms, NumGroups+2 );

  for i := 0 to NumGroups+1 do // initialize NumSegms Array
    NumSegms[i] := 0;

  with TN_ULines(CurCObj) do
  for i := 0 to WNumItems-1 do
  begin
    NumParts := GetNumParts( i );

    for j := 0 to NumParts-1 do
    begin
      GetPartDCoords( i, j, DCoords );

      for k := 0 to High(DCoords)-1 do
      begin
        SegmSize := N_P2PDistance( DCoords[k], DCoords[k+1] );
        GroupInd := Round( Floor( NumGroups*(SegmSize - MinSize)/(MaxSize - MinSize) ));

        if GroupInd < 0 then Inc( NumSegms[0] )
        else if GroupInd >= NumGroups then Inc( NumSegms[NumGroups+1] )
        else Inc( NumSegms[GroupInd+1] );

      end; // for k := 0 to High(DCoords)-1 do
    end; // for j := 0 to NumParts-1 do
  end; // for i := 0 to WNumItems-1 do, with TN_ULines(CurCObj) do

  with N_GetInfoForm() do
  begin
    Memo.Lines.Add( Format( '  Number of segments in %d Groups:', [NumGroups+2] ));
    Memo.Lines.Add( '' );
    Memo.Lines.Add( Format( '%.3d  %6d  < %.3g', [0, NumSegms[0], MinSize] ));

    for i := 0 to NumGroups-1 do
    begin
      Delta := (MaxSize - MinSize) / NumGroups;
      GrMin := MinSize + i*Delta;
      GrMax := GrMin + Delta;
      Memo.Lines.Add( Format( '%.3d  %6d  from %.3g to %.3g',
                              [i+1, NumSegms[i+1], GrMin, GrMax] ));
    end; // for i := 0 to NumGroups-1 do

    Memo.Lines.Add( Format( '%.3d  %6d  >= %.3g',
                             [NumGroups+1, NumSegms[NumGroups+1], MaxSize] ));
    Show;
  end; // with N_GetInfoForm() do

end; // procedure TN_CObjVectEditorForm.aViewSegmentsExecute


    //********* Other  Actions  ********************************

procedure TN_CObjVectEditorForm.aOtherCreateShapeExecute( Sender: TObject );
// Create Shape using current Self Fields values
var
  NumVerts, NumPoints, ItemInd, PartInd: integer;
  Center: TDPoint;
  Angle, R1, R2: double;
  Str: string;
  EnvRect: TFRect;
  ShapeDC: TN_DPArray;
  CurCObj: TN_UCObjLayer;
  CurCLines: TN_ULines;
begin
  Str := edShapeCenter.Text;
  Center := N_ScanDPoint( Str );

  Str := edShapeNumVerts.Text;
  NumVerts := N_ScanInteger( Str );

  Str := edShapeAngle.Text;
  Angle := N_ScanDouble( Str );

  Str := edShapeR1.Text;
  R1 := N_ScanDouble( Str );

  Str := edShapeR2.Text;
  R2 := N_ScanDouble( Str );

  with Center do
    EnvRect := FRect( X-R1, Y-R1, X+R1, Y+R1 );

  CurCObj := EdMaplayer.PCMapLayer^.MLCObj;
  if not (CurCObj is TN_ULines) then
  begin
    StatusBar.SimpleText := 'Cur CObj is NOT Lines!';
    Exit;
  end;
  CurCLines := TN_ULines(CurCObj);

  ItemInd := -1;
  PartInd := -1;

  case rgShapeType.ItemIndex of

  0: begin // Circle with given Center and R1 Radius
       NumPoints := Round( 360 / EdRFrame.OCanv.MinAngleStep ) + 1;
       N_CalcSpiralDCoords( ShapeDC, EnvRect, Angle, Angle+360, 1, NumPoints );
       CurCLines.SetPartDCoords( ItemInd, PartInd, ShapeDC ); // Add new Item
     end; // 0: begin // Circle

  1: begin // Regular Polygon with given Center, R1 Radius and BegPoint Angle
       N_CalcRegPolyDCoords( ShapeDC, EnvRect, Angle, NumVerts );
       CurCLines.SetPartDCoords( ItemInd, PartInd, ShapeDC ); // Add new Item
     end; // 1: begin // Regular Polygon

  2: begin // Ring - between two Circles with given Center and R1, R2 Radiuses
       NumPoints := Round( 360 / EdRFrame.OCanv.MinAngleStep ) + 1;
       N_CalcSpiralDCoords( ShapeDC, EnvRect, Angle, Angle+360, 1, NumPoints );
       CurCLines.SetPartDCoords( ItemInd, PartInd, ShapeDC ); // outer circle

       with Center do // EnvRects for inner circle
         EnvRect := FRect( X-R2, Y-R2, X+R2, Y+R2 );

       N_CalcSpiralDCoords( ShapeDC, EnvRect, Angle, Angle+360, 1, NumPoints );
       PartInd := -1;
       CurCLines.SetPartDCoords( ItemInd, PartInd, ShapeDC ); // NewPart of same Item
     end; // 2: begin // Ring

  end; // case rgShapeType.ItemIndex of

  EdRFrame.RedrawAllAndShow();

end; // procedure TN_CObjVectEditorForm.aOtherCreateShapeExecute

    //********* Flags1 TabSheet handlers  ***************************

procedure TN_CObjVectEditorForm.rgHighlightLClick( Sender: TObject );
// change HighLight Lines Mode
begin
  N_TmpHighLineParams1.HLineMode := rgHighLightL.ItemIndex;
end;

procedure TN_CObjVectEditorForm.rgHighlightSVClick( Sender: TObject );
// change HighLight Segments-Vertexes Mode
begin
  N_TmpHighLineParams1.HSegmVertMode := rgHighLightSV.ItemIndex;
end;

procedure TN_CObjVectEditorForm.rgSnapModeClick( Sender: TObject );
// change Snap Mode
begin
  N_TmpEditVertexParams.EVSnapMode := rgSnapMode.ItemIndex;
end;

    //********* Flags2 TabSheet handlers  ***************************

procedure TN_CObjVectEditorForm.rgMoveComVertClick( Sender: TObject );
// change Move Common Vertex Mode
begin
  N_TmpEditVertexParams.EVComVertMode := rgMoveComVert.ItemIndex;
end;

procedure TN_CObjVectEditorForm.rgSplitModeClick( Sender: TObject );
// change Split Mode
begin
  N_TmpEditVertexParams.EVSplitMode := rgSplitMode.ItemIndex;
end;

    //********* Acts1 TabSheet handlers  *****************************

procedure TN_CObjVectEditorForm.rbEmptyAction1Click( Sender: TObject );
begin
  N_SetEditAction( N_ActEmpty, 0, 1 );
end;

procedure TN_CObjVectEditorForm.rbSnapToCObjClick( Sender: TObject );
begin
//  N_SetEditAction( N_ActSnapToCObj, 0, 1 );
end;

procedure TN_CObjVectEditorForm.rbMarkCObjClick( Sender: TObject );
begin
  N_SetEditAction( N_ActMarkCObjPart, 0, 1 );
end;

procedure TN_CObjVectEditorForm.rbSetItemCodesClick( Sender: TObject );
// Set sequential Items Codes (each Click sets next CCode), initial CCode
// is defined by first Clicked Item
begin
  N_SetEditAction( N_ActSetItemCodes, 0, 1 );
end; // procedure TN_CObjVectEditorForm.rbSetItemCodesClick

procedure TN_CObjVectEditorForm.rbEditItemCodeClick( Sender: TObject );
begin
  N_SetEditAction( N_ActEditItemCode, 0, 1 );
end;

procedure TN_CObjVectEditorForm.rbEditRegCodesClick( Sender: TObject );
begin
  N_SetEditAction( N_ActEditRegCodes, 0, 1 );
end;

procedure TN_CObjVectEditorForm.rbMoveVertexClick( Sender: TObject );
begin
  with N_SetEditAction( N_ActEditVertex, 0, 1 ) as TN_RFAEditVertex do
    SubAction := ngsEVMMoveCurVert;
end;

procedure TN_CObjVectEditorForm.rbAddVertexClick( Sender: TObject );
begin
  with N_SetEditAction( N_ActEditVertex, 0, 1 ) as TN_RFAEditVertex do
    SubAction := ngsEVMAddVertOnSegm;
end;

procedure TN_CObjVectEditorForm.rbDeleteVertexClick( Sender: TObject );
begin
  with N_SetEditAction( N_ActEditVertex, 0, 1 ) as TN_RFAEditVertex do
    SubAction := ngsEVMDelCurVert;
end;

procedure TN_CObjVectEditorForm.rbEnlargeLineClick( Sender: TObject );
begin
  with N_SetEditAction( N_ActEditVertex, 0, 1 ) as TN_RFAEditVertex do
    SubAction := ngsEVMEnlargeLine;
end;

procedure TN_CObjVectEditorForm.rbNewLineClick( Sender: TObject );
begin
  with N_SetEditAction( N_ActEditVertex, 0, 1 ) as TN_RFAEditVertex do
    SubAction := ngsEVMStartNewLine;
end;

procedure TN_CObjVectEditorForm.rbDeleteLineClick( Sender: TObject );
begin
  N_SetEditAction( N_ActDeleteLine, 0, 1 );
end;

procedure TN_CObjVectEditorForm.rbSplitCombLineClick( Sender: TObject );
begin
  N_SetEditAction( N_ActSplitCombLine, 0, 1 );
end;

procedure TN_CObjVectEditorForm.rbAffConvLineClick( Sender: TObject );
begin
  N_SetEditAction( N_ActAffConvLine, 0, 1 );
end;

    //********* Acts2 TabSheet handlers  *****************************

procedure TN_CObjVectEditorForm.rbMovePointClick( Sender: TObject );
begin
  N_SetEditAction( N_ActMovePoint, 0, 1 );
end;

procedure TN_CObjVectEditorForm.rbAddPointClick( Sender: TObject );
begin
  N_SetEditAction( N_ActAddPoint, 0, 1 );
end;

procedure TN_CObjVectEditorForm.rbDeletePointClick( Sender: TObject );
begin
  N_SetEditAction( N_ActDeletePoint, 0, 1 );
end;

procedure TN_CObjVectEditorForm.rbMoveLabelClick( Sender: TObject );
begin
  N_SetEditAction( N_ActMoveLabel, 0, 1 );
end;

procedure TN_CObjVectEditorForm.rbAddLabelClick( Sender: TObject );
begin
  N_SetEditAction( N_ActAddLabel, 0, 1 );
end;

procedure TN_CObjVectEditorForm.rbDeleteLabelClick( Sender: TObject );
begin
  N_SetEditAction( N_ActDeleteLabel, 0, 1 );
end;

procedure TN_CObjVectEditorForm.rbEditLabelClick( Sender: TObject );
begin
  N_SetEditAction( N_ActEditLabel, 0, 1 );
end;


    //********* Shape TabSheet Handlers  ***************************

procedure TN_CObjVectEditorForm.edShapeCenterDblClick( Sender: TObject );
// Create RFrame Action for setting Shape Center Coords
begin
  N_SetEditAction( N_ActSetShapeCoords, 0, 1 );
end; // procedure TN_CObjVectEditorForm.edShapeCenterDblClick

procedure TN_CObjVectEditorForm.edShapeR1DblClick( Sender: TObject );
// Create RFrame Action for setting Shape R1 value
begin
  N_SetEditAction( N_ActSetShapeCoords, 1, 1 );
end; // procedure TN_CObjVectEditorForm.edShapeR1DblClick

procedure TN_CObjVectEditorForm.edShapeR2DblClick( Sender: TObject );
// Create RFrame Action for setting Shape R2 value
begin
  N_SetEditAction( N_ActSetShapeCoords, 2, 1 );
end; // procedure TN_CObjVectEditorForm.edShapeR2DblClick

procedure TN_CObjVectEditorForm.bnCreateRRClick( Sender: TObject );
// Add to current Lines Layer new Round Rect Item
var
  NumSegments, ItemInd, PartInd: integer;
  Str: string;
  EnvRect: TFRect;
  ShapeDC: TN_DPArray;
  CurCObj: TN_UCObjLayer;
  CurCLines: TN_ULines;
  RadXY: TFPoint;
begin
  ShapeDC := nil; // to avoid warning

  Str := edRRUpperLeft.Text;
  EnvRect.TopLeft := N_ScanFPoint( Str );

  Str := edRRLowerRight.Text;
  EnvRect.BottomRight := N_ScanFPoint( Str );

  Str := edRadiusX.Text;
  RadXY.X := N_ScanFloat( Str );

  Str := edRadiusY.Text;
  if Str = '' then RadXY.Y := RadXY.X
              else RadXY.Y := N_ScanFloat( Str );

  Str := edRRNumSegments.Text;
  NumSegments := N_ScanInteger( Str );

  CurCObj := EdMaplayer.PCMapLayer^.MLCObj;
  if not (CurCObj is TN_ULines) then
  begin
    StatusBar.SimpleText := 'Cur CObj is NOT Lines!';
    Exit;
  end;
  CurCLines := TN_ULines(CurCObj);

  ItemInd := -1;
  PartInd := -1;
  ShapeDC := N_CalcRoundRectDCoords( EnvRect, RadXY, NumSegments+1 );
  CurCLines.SetPartDCoords( ItemInd, PartInd, ShapeDC ); // Add new Item

  EdRFrame.RedrawAllAndShow();
end; // procedure TN_CObjVectEditorForm.bnCreateRRClick

procedure TN_CObjVectEditorForm.bnCreateRPFragmClick( Sender: TObject );
// Create Regular Polygon Fragment(s)
//
// Angle Size = 0 means 360 degrees.
// If 0 < Scale Coef <> 1 then two Regular Polygon Fragments are created and
//   joined by straight line segments (if Angle Size <> 0).
// Scale Coef = 0 means Pie Segment (one Regular Polygon Fragment is created
//   and EnvRect Center is joined with ends of created Fragment)
//
begin
//  inherited;

end; // procedure TN_CObjVectEditorForm.bnCreateRPFragmClick


    //********* Other TabSheet handlers  *****************************

procedure TN_CObjVectEditorForm.cbMultiSelectClick( Sender: TObject );
// Set or clear bit0 of Edit Group SGFlags (allow or not multiple selection)
begin
  if cbMultiSelect.Checked then
    EditGroup.SGFlags := EditGroup.SGFlags or $01
  else
    EditGroup.SGFlags := EditGroup.SGFlags and $FFFFFFFE;
end; // procedure TN_CObjVectEditorForm.cbMultiSelectClick

procedure TN_CObjVectEditorForm.cbStayOnTopClick( Sender: TObject );
// Toggle StayOnTop property
begin
  if cbStayOnTop.Checked then FormStyle := fsStayOnTop
                         else FormStyle := fsNormal;
end; // procedure TN_CObjVectEditorForm.cbStayOnTopClick

procedure TN_CObjVectEditorForm.edRedrawLLWPixSizeKeyDown( Sender: TObject;
                                          var Key: Word; Shift: TShiftState );
// Set EditGroup.RedrawLLWPixSize by edRedrawLLWPixSize.Text
var
  Str: string;
begin
  Str := edRedrawLLWPixSize.Text;
  EditGroup.RedrawLLWPixSize := N_ScanFloat( Str );
end; // procedure TN_CObjVectEditorForm.edRedrawLLWPixSizeKeyDown

procedure TN_CObjVectEditorForm.edCDimIndKeyDown( Sender: TObject;
                                          var Key: Word; Shift: TShiftState );
// Set CDimInd in N_ActShowCObjInfo
var
  ActionInd: integer;
begin
  if Key <> VK_RETURN then Exit;

  ActionInd := EditGroup.GetActionByClass( N_ActShowCObjInfo );
  if ActionInd >= 0 then
    with TN_RFAShowCObjInfo(EditGroup.GroupActList.Items[ActionInd]) do
      CDimInd := StrToInt( edCDimInd.Text );

  ActionInd := EditGroup.GetActionByClass( N_ActSetItemCodes );
  if ActionInd >= 0 then
    with TN_RFASetItemCodes(EditGroup.GroupActList.Items[ActionInd]) do
      CDimInd := StrToInt( edCDimInd.Text );

end; // procedure TN_CObjVectEditorForm.edCDimIndKeyDown


    //*********************  Other Form Handlers  *******************

procedure TN_CObjVectEditorForm.PageControlChange( Sender: TObject );
// Remove currently selected action on Acts1 TabSheet after switched to Acts2
// (set rbEmptyAction1.Checked to True) and same for swithing from
// Acts2 to Acts1 TabSheets
begin
  if (PageControl.ActivePage = tsActs1) and (PrevActivePage = tsActs2) then
    rbEmptyAction2.Checked := True;

  if (PageControl.ActivePage = tsActs2) and (PrevActivePage = tsActs1) then
    rbEmptyAction1.Checked := True;

  if PageControl.ActivePage = tsActs1 then
    PrevActivePage := tsActs1;

  if PageControl.ActivePage = tsActs2 then
    PrevActivePage := tsActs2;

  if PageControl.ActivePage = tsShape then
  begin
    rbEmptyAction1.Checked := True;
    rbEmptyAction2.Checked := True;
  end;

end; // procedure TN_CObjVectEditorForm.PageControlChange

procedure TN_CObjVectEditorForm.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  K_PutTextToClipboard( EditGroup.SavedStrings.Text );
  EdRFrame.DeleteGroup( N_SVectEditGName );
  N_GlobObj.GOStatusBar2 := EdSavedStatusBar; // restore (was saved in N_CreateCObjVectEditorForm)

  Inherited;
end; // procedure TN_CObjVectEditorForm.FormClose


//****************  TN_CObjVectEditorForm class public methods  ************

//***********************************  TN_CObjVectEditorForm.CVEdFInit  ******
// Initialize Self for editing given AMaplayer in given ARFrame
//
procedure TN_CObjVectEditorForm.CVEdFInit( ARFrame: TN_Rast1Frame; AMaplayer: TN_UDMaplayer );
begin
  EdRFrame     := ARFrame;
  EdMaplayer   := AMaplayer;
  EdPCMaplayer := AMaplayer.PISP(); // Always Static
  EdCObjLayer  := EdPCMaplayer^.MLCObj;

  EditGroup := N_SetEditGroup( EdRFrame, EdMaplayer, 0 );
  edRedrawLLWPixSize.Text := Format( ' %.0f', [EditGroup.RedrawLLWPixSize] );

  rgHighLightL.ItemIndex  := N_TmpHighLineParams1.HLineMode;
  rgHighLightSV.ItemIndex := N_TmpHighLineParams1.HSegmVertMode;
//  edSearchSize.Text := IntToStr( SearchRectSizeInPix );

  rgSnapMode.ItemIndex    := N_TmpEditVertexParams.EVSnapMode;
  rgMoveComVert.ItemIndex := N_TmpEditVertexParams.EVComVertMode;
  rgSplitMode.ItemIndex   := N_TmpEditVertexParams.EVSplitMode;
end; // end of procedure TN_CObjVectEditorForm.CVEdFInit

//******************************  TN_CObjVectEditorForm.CurArchiveChanged  *****
// Update all needed Self fields after current Archive was changed
//
procedure TN_CObjVectEditorForm.CurArchiveChanged();
begin
  frAuxCL.InitByTopPath();
end; // end of procedure TN_CObjVectEditorForm.CurArchiveChanged

//*********************************  TN_CObjVectEditorForm.CurStateToMemIni  ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CObjVectEditorForm.CurStateToMemIni();
begin
  Inherited;
  N_IntToMemIni( 'N_CObjVectEdF', 'TSInd', PageControl.TabIndex );
  N_ComboBoxToMemIni( 'N_CObjVectEdF_frAuxCL', frAuxCL.mb );
  N_StringToMemIni( 'N_CObjVectEdF', 'NumGroups', edOSNumGroups.Text );
  N_StringToMemIni( 'N_CObjVectEdF', 'MinSize',   edOSMinSize.Text );
  N_StringToMemIni( 'N_CObjVectEdF', 'MaxSize',   edOSMaxSize.Text );
end; // end of procedure TN_CObjVectEditorForm.CurStateToMemIni

//*********************************  TN_CObjVectEditorForm.MemIniToCurState  ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CObjVectEditorForm.MemIniToCurState();
begin
  Inherited;
  PageControl.TabIndex := N_MemIniToInt( 'N_CObjVectEdF', 'TSInd', 2 );
  N_MemIniToComboBox( 'N_CObjVectEdF_frAuxCL', frAuxCL.mb );
  edOSNumGroups.Text := N_MemIniToString( 'N_CObjVectEdF', 'NumGroups', '1' );
  edOSMinSize.Text   := N_MemIniToString( 'N_CObjVectEdF', 'MinSize', '0' );
  edOSMaxSize.Text   := N_MemIniToString( 'N_CObjVectEdF', 'MaxSize', '10' );
end; // end of procedure TN_CObjVectEditorForm.MemIniToCurState


    //*********** Global Procedures  *****************************

//*****************************************  N_CreateCObjVectEditorForm  ******
// Create and return new instance of TN_CObjVectEditorForm
//
function N_CreateCObjVectEditorForm( AOwner: TN_BaseForm ): TN_CObjVectEditorForm;
begin
  Result := TN_CObjVectEditorForm.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );
    CurArchiveChanged(); // UObj2Frame initialization
    EdError := False;
    PixMesFrame.OnMouseUpProcObj := N_MEGlobObj.MECopyCoordsAndColor;

    EdSavedStatusBar := N_GlobObj.GOStatusBar2; // save for restoring in OnClose
    N_GlobObj.GOStatusBar2 := StatusBar;

    if N_ActiveRFrame <> nil then
      N_PlaceTControl( Result, K_GetOwnerForm( N_ActiveRFrame.Owner ) );
  end;
end; // function N_CreateCObjVectEditorForm


end.

