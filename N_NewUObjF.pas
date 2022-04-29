unit N_NewUObjF;
// Form for creating New UDObjects in modal mode

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls,
  K_UDT1;

type TN_NewUObjForm = class( TForm ) //***********************************
    edName: TLabeledEdit;
    edAliase: TLabeledEdit;
    bnCancel: TButton;
    bnOK: TButton;
    mbUObjType: TComboBox;
    Label1: TLabel;
    rgWhere: TRadioGroup;
    mbTGroup: TComboBox;
    Label2: TLabel;

    procedure edNameKeyDown ( Sender: TObject; var Key: Word;
                                                      Shift: TShiftState );
    procedure mbTGroupCloseUp   ( Sender: TObject );
    procedure mbUObjTypeCloseUp ( Sender: TObject );

      private
    GroupInd, TypeInd: integer; // to pass TypeInd from MemIni to mbTGroupCloseUp( nil )
    SomeStatusBar: TStatusBar;

    procedure ShowResponse( AStr: string );
end; // type TN_NewUObjForm = class( TForm )


    //*********** Global Procedures  *****************************

function N_CreateNewUObj( ASelParent, ASelected: TN_UDBase;
                                      AStatusBar: TStatusBar = nil ): TN_UDBase;


implementation
uses
  K_Script1, K_DCSpace, K_FSelectUDB, K_CSpace, K_FSFCombo, K_UDConst,
  N_Types, N_Gra0, N_Gra1, N_ClassRef, N_Lib0, N_Lib1, N_Lib2, N_UDat4, N_ME1, N_UDCMap,
  N_CompBase, N_CompCL, N_Comp1, N_Comp2, N_Comp3, N_EdParF, N_NVtreeFr;
{$R *.dfm}

//************************** New UOBjects Constants **********************

var
  GroupNames: array [0..4] of string = //***** Objects Groups Names
                    ( 'Visual Components', 'Other Components', 'Data Objects',
                      'Other Objects', 'Library Elements' );
type TGroups = ( gVComps, gOComps, gDataObj, gOtherObj, gLibElems );

var
  VCompNames: array [0..26] of string = //***** Visual Components Names
  ( 'Panel',     'Text Blocks', 'Legend',      'New Legend',     'Map Layer', 'Map with CObj',          '',
    '2D Func',   'Iso Lines',   'LinHist',     'LinHist Auto1',  'PieChart',  'Table',          'Grid', '',
    'Auto Axis', 'Axis Tics',   'Text Marks',  'Polyline',       'Arc',       'Straight Arrow',         '',
    '2D Space',  'Picture',     'DIB Picture', 'DIB Fragment',   'Text Box (obsolete)'  );
type TVComps = ( vcPanel,    vcParaBox,   vcLegend,    vcNLegend,  vcMapLayer, vcMapRoot, vcSep2,
     vc2DFunc,   vcIsoLines, vcLinHist,   vcLinHistA1, vcPieChart, vcTable,    vcGrid,    vcSep3,
     vcAutoAxis, vcAxisTics, vcTextMarks, vcPolyline,  vcArc,      vcSArrow,              vcSep4,
     vc2DSpace,  vcPicture,  vcDIB,       vcDIBRect,   vcTextBox  );

var
  OCompNames: array [0..15] of string = //***** Other Components Names
  ( 'BaseComponent', 'File', 'Action',  'Word Fragm',  'Excel Fragm', 'Export Comp', '',
    'Query1',        'Query2',          'Iterator',    'Creator',  '',
    'NonLin Conv',   'DynPict Creator', 'Calc UParams', 'Text Fragment' );
type TOComps = ( ocBaseComp, ocFile,   ocAction,   ocWordFragm,  ocExcelFragm, ocExpComp,  ocsep1,
                 ocQuery1,   ocQuery2, ocIterator, ocCreator,    ocsep2,
                 ocNonLinConv, ocDynPictCreator, ocCalcUParams, ocTextFragm );

var
  DataObjNames: array [0..14] of string = //***** Data Objects Names
  ( 'Points',                     'Lines',                'Contours',   '',
    'UDArray of some Base type',  'UDArray of Any type',  '',
    'UDVector of some Base type', 'UDVector of Any type', '',
    'Data Block',                 'Codes Dimension',      'Codes SubDimension',
    'CSubDimensions Relation',    'Binary Data' );
type TDataObj = ( dPoints,     dLines,      dConts, dSep1,
                  dUDRArrayBT, dUDRArrayAT, dSep2,
                  dUDVectorBT, dUDVectorAT, dSep3,
                  dDataBlock,  dCDim,       dCSDim, dCSDimRelation, dUDMem );

var
  OtherObjNames: array [0..7] of string = //***** Other Objects Names
                 ( 'Empty Dir',     'Archive Section', 'New Font',      'Text',
                   'CTParams Var1', 'Sklon Table',     'Sign Elements', 'Old Font' );
type TOtherObj = ( oEmptyDir,     oArchSection, oNFont,     oText,
                   oCTParamsVar1, oSklonTable,  oSignElems, oFont );

var
  LibElemsNames: array [0..1] of string = //***** Library Elements Names ???
                 ( 'Library_1', 'Archive' );
type TLibElems = (  lLib_1,     lArchive );


var N_CoordsTypeNames:    array [0..1] of string = ( ' Float ', ' Double ' );
var N_UDRArrayTypeNames1: array [0..6] of string = ( '  Boolean  ', '  Integer  ',
               '  Color  ', '  Float  ', '  Double  ', '  String  ', '  Float Point  ' );
var N_UDRArrayTypeNames2: array [0..6] of string = ( 'Bool1', 'Integer',
                         'Color', 'Float', 'Double', 'String', 'TFPoint' );
var N_MapLayerTypes:      array [0..3] of string = ( ' Points ', ' Lines ',
                                            ' Contours ', ' Hor Labels ' );


//****************  TN_NewUObjForm class handlers  ******************

procedure TN_NewUObjForm.edNameKeyDown( Sender: TObject; var Key: Word;
                                                       Shift: TShiftState );
// Close Form with ModalResult mrOK by Enter key
begin
  if Key = VK_RETURN then
    ModalResult := mrOK;
end; // procedure TN_NewUObjForm.edNameKeyDown

procedure TN_NewUObjForm.mbTGroupCloseUp( Sender: TObject );
// Fill mbUObjType.Items by mbTGroup.ItemIndex
begin
  GroupInd := mbTGroup.ItemIndex;
  if Sender <> nil then TypeInd := 0;

  case TGroups(GroupInd) of
    gVComps:   N_SetMBItems( mbUObjType, VCompNames,    TypeInd );
    gocomps:   N_SetMBItems( mbUObjType, ocompNames,    TypeInd );
    gDataObj:  N_SetMBItems( mbUObjType, DataObjNames,  TypeInd );
    gOtherObj: N_SetMBItems( mbUObjType, OtherObjNames, TypeInd );
    gLibElems: N_SetMBItems( mbUObjType, LibElemsNames, TypeInd );
    else
    begin
      N_WarnByMessage( 'Bad GroupInd!' );
      Release; // Release Self
      Close;
      Exit;
    end;
  end; // case TGroups(GroupInd) of

  edName.Text := mbUObjType.Items[TypeInd] + '1';
end; // procedure TN_NewUObjForm.mbTGroupCloseUp

procedure TN_NewUObjForm.mbUObjTypeCloseUp( Sender: TObject );
// Set edName.Text field
begin
  TypeInd := mbUObjType.ItemIndex;
  edName.Text := mbUObjType.Items[TypeInd] + '1';
end; // procedure TN_NewUObjForm.mbUObjTypeCloseUp

procedure TN_NewUObjForm.ShowResponse( AStr: string );
// Show given String in SomeStatusBar
begin
  if SomeStatusBar <> nil then
    SomeStatusBar.SimpleText := AStr;
end; // procedure TN_NewUObjForm.ShowResponse


    //*********** Global Procedures  *****************************

//********************************************  N_CreateNewUObj  ******
// Create and return new UDBase Object and add it to DTree
// using TN_NewUObjForm in modal mode
// ASelected and it's Parent(ASelParent) are used for adding new UObj
// in proper place of DTree (inside or before ASelected)
//
function N_CreateNewUObj( ASelParent, ASelected: TN_UDBase;
                                           AStatusBar: TStatusBar ): TN_UDBase;
var
  i, SelInd, ChildInd, Accuracy, IntDTCode: integer;
  PathToCDim, TypeName: string;
  UParent, NewUObj, LibRoot: TN_UDBase;
  PVCTParams: TN_PVCTreeParams;
  PVCTreeLayer: TN_PVCTreeLayer;
  PCTLVar1: TN_PCTLVar1;
  MLType: TN_MLType;
  NewMaplayer: TN_UDMapLayer;
  CSS: TK_UDDCSSpace;
  CDim: TK_UDCDim;
  DBTCode: TK_ExprExtType;
  ParamsForm: TN_EditParamsForm;
  NewUObjForm: TN_NewUObjForm;

  function SelectCDim(): TK_UDCDim; // local
  // Select and Return Codes Dimension Obj
  var
    UObj: TN_UDBase;
  begin
    UObj := K_SelectUDB( K_CurArchive, PathToCDim, nil, nil, 'Select Codes Dimension' );
    if not (UObj is TK_UDCDim) then // unproper Type or was not selected
    begin
      NewUObjForm.ShowResponse( 'Codes Dimension not Selected!' );
      Result := nil;
      Exit;
    end;

    Result := TK_UDCDim(UObj);
//    PathToCDim := K_CurArchive.GetRefPathToObj( UObj ); // update PathToCDim variable
    PathToCDim := K_GetPathToUObj( UObj, K_CurArchive ); // update PathToCDim variable
  end; // procedure SelectCDim(); // local

  function SelectCSS(): TK_UDDCSSpace; // local
  // Select and Return Codes SubSpace Obj
  var
    UObj: TN_UDBase;
  begin
    UObj := K_SelectUDB( K_CurSpacesRoot, '', nil, nil, 'Select CSS (Codes Sub Space)' );

    if not (UObj is TK_UDDCSSpace) then // unproper Type or was not selected
    begin
      NewUObjForm.ShowResponse( 'Codes Sub Space not Selected!' );
      Result := nil;
      Exit;
    end;

    Result := TK_UDDCSSpace(UObj);
  end; // procedure SelectCSS // local

begin //************************************** main Body of N_CreateNewUObj
  Result := nil;
  NewUObj := nil; // to avoid warning
  NewUObjForm := TN_NewUObjForm.Create( Application );

  with NewUObjForm do
  begin
  SomeStatusBar := AStatusBar;
  ShowResponse( '' ); // clear respone string

  GroupInd := N_MemIniToInt( 'N_NewUObjF', 'mbTGroup', 0 );
  N_SetMBItems( mbTGroup, GroupNames, GroupInd );

  TypeInd := N_MemIniToInt( 'N_NewUObjF', 'mbUObjType', 0 );
  mbTGroupCloseUp( nil ); // fill mbUObjType.Items by TypeInd
  rgWhere.ItemIndex := N_MemIniToInt( 'N_NewUObjF', 'rgWhere', 0 );
  PathToCDim := N_MemIniToString( 'N_NewUObjF', 'PathToCDim' ); // get Path To CDim

  ShowModal();

  if ModalResult <> mrOK then Exit;

  N_IntToMemIni   ( 'N_NewUObjF', 'mbTGroup',   mbTGroup.ItemIndex );   // save Group Index
  N_IntToMemIni   ( 'N_NewUObjF', 'mbUObjType', mbUObjType.ItemIndex ); // save Type Index
  N_IntToMemIni   ( 'N_NewUObjF', 'rgWhere',    rgWhere.ItemIndex );    // save rgWhere

  case TGroups(GroupInd) of

    gVComps: //********************************************* Visual Components

    case TVComps(TypeInd) of
    vcPanel:     NewUObj := K_CreateUDByRTypeName( 'TN_RPanel',     1, N_UDPanelCI );
    vcParaBox:   NewUObj := K_CreateUDByRTypeName( 'TN_RParaBox',   1, N_UDParaBoxCI );
    vcLegend:    NewUObj := K_CreateUDByRTypeName( 'TN_RLegend',    1, N_UDLegendCI );
    vcNLegend:   NewUObj := K_CreateUDByRTypeName( 'TN_RNLegend',   1, N_UDNLegendCI );

    vcMapLayer: begin // Create MapLayer and set some Coords fields
      ParamsForm := N_CreateEditParamsForm( 250 );
      with ParamsForm do
      begin
        AddFixComboBox( 'Map Layer Type:', N_MapLayerTypes, 0 );

        ShowSelfModal();

        if ModalResult <> mrOK then
        begin
          Release; // Release ParamsForm
          Exit;
        end;

        NewUObj := K_CreateUDByRTypeName( 'TN_RMapLayer', 1, N_UDMapLayerCI );
        MLType := mltNotDef; // to avoid warning
        case EPControls[0].CRInt of
          0: MLType := mltPoints1;
          1: MLType := mltLines1;
          2: MLType := mltConts1;
          3: MLType := mltHorLabels;
        end; // case EPControls[0].CRInt of

        TN_UDMapLayer(NewUObj).InitMLParams( MLType );
        Release; // Free ParamsForm
      end; // with ParamsForm do
    end; // vcMapLayer: begin

    vcMapRoot: begin // Create MapRoot (UDPanel) and child MapLayers with
                     // currently selected in N_NVtreeForm CObjects (if any)
       NewUObj := K_CreateUDByRTypeName( 'TN_RPanel', 1, N_UDPanelCI );

       with TN_UDPanel(NewUObj).PCCS()^ do // force automatic User Coords calculation
       begin
         CompUCoords.Left := N_NotAFloat;
         UCoordsType := cutGiven;
       end;

       if N_ActiveVTreeFrame <> nil then
       with N_ActiveVTreeFrame.VTree.MarkedVNodesList do // analize Marked CObjects
       begin
         for i := 0 to Count-1 do // along all Marked VNodes
         with TN_VNode(Items[i]) do
         begin
           if not (VNUDObj is TN_UCObjLayer) then Continue; // skip not CObjects

           NewMaplayer := N_CreateUDMapLayer( TN_UCObjLayer(VNUDObj) );
           N_AddUChild( NewUObj, NewMapLayer, 'ML' + VNUDObj.ObjName );
         end; // with TN_VNode(Items[i]) do, for i := Count-1 downto 0 do,
       end; // with N_ActiveVTreeFrame.VTree.MarkedVNodesList do, if N_ActiveVTreeFrame <> nil then

    end; // vcMapRoot: begin

    vc2DFunc:    NewUObj := K_CreateUDByRTypeName( 'TN_R2DFunc',       1, N_UD2DFuncCI );
    vcIsoLines:  NewUObj := K_CreateUDByRTypeName( 'TN_RIsoLines',     1, N_UDIsoLinesCI );
    vcLinHist:   NewUObj := K_CreateUDByRTypeName( 'TN_R2DLinHist',    1, N_UD2DLinHistCI );
    vcLinHistA1: NewUObj := K_CreateUDByRTypeName( 'TN_RLinHistAuto1', 1, N_UDLinHistAuto1CI );
    vcPieChart:  NewUObj := K_CreateUDByRTypeName( 'TN_RPieChart',     1, N_UDPieChartCI );
    vcTable:     NewUObj := K_CreateUDByRTypeName( 'TN_RTable',        1, N_UDTableCI );
    vcGrid:      NewUObj := K_CreateUDByRTypeName( 'TN_RCompsGrid',    1, N_UDCompsGridCI );

    vcAxisTics:  NewUObj := K_CreateUDByRTypeName( 'TN_RAxisTics',  1, N_UDAxisTicsCI );
    vcAutoAxis:  NewUObj := N_CreateAutoAxis(); // get params in Dialogue
    vcTextMarks: NewUObj := K_CreateUDByRTypeName( 'TN_RTextMarks', 1, N_UDTextMarksCI );
    vcPolyline:  NewUObj := K_CreateUDByRTypeName( 'TN_RPolyline',  1, N_UDPolylineCI );
    vcArc:       NewUObj := K_CreateUDByRTypeName( 'TN_RArc',       1, N_UDArcCI );
    vcSArrow:    NewUObj := K_CreateUDByRTypeName( 'TN_RSArrow',    1, N_UDSArrowCI );
    vc2DSpace:   NewUObj := K_CreateUDByRTypeName( 'TN_R2DSpace',   1, N_UD2DSpaceCI );

    //    vcTextRow:   NewUObj := K_CreateUDByRTypeName( 'TN_RTextRow',   1, N_UDTextRowCI );
    vcPicture:   NewUObj := K_CreateUDByRTypeName( 'TN_RPicture',   1, N_UDPictureCI );
    vcDIB:       NewUObj := K_CreateUDByRTypeName( 'TN_RDIB',       1, N_UDDIBCI );
    vcDIBRect:   NewUObj := K_CreateUDByRTypeName( 'TN_RDIBRect',   1, N_UDDIBRectCI );
    vcTextBox:   NewUObj := K_CreateUDByRTypeName( 'TN_RTextBox',   1, N_UDTextBoxCI );

    else Exit; // separartor was choosen
    end; // gVComps: case TComps(TypeInd) of


    gOComps: //***************************************** Other Components

    case TOComps(TypeInd) of

    ocBaseComp:   NewUObj := K_CreateUDByRTypeName( 'TN_RCompBase',   1, N_UDCompBaseCI );
    ocFile:       NewUObj := K_CreateUDByRTypeName( 'TN_RFile',       1, N_UDFileCI );
    ocAction:     NewUObj := K_CreateUDByRTypeName( 'TN_RAction',     1, N_UDActionCI );
    ocWordFragm:  NewUObj := K_CreateUDByRTypeName( 'TN_RWordFragm',  1, N_UDWordFragmCI );
    ocExcelFragm: NewUObj := K_CreateUDByRTypeName( 'TN_RExcelFragm', 1, N_UDExcelFragmCI );
    ocExpComp:    NewUObj := K_CreateUDByRTypeName( 'TN_RExpComp',    1, N_UDExpCompCI );

    ocQuery1:    NewUObj := K_CreateUDByRTypeName( 'TN_RQuery1',   1, N_UDQuery1CI );
    ocQuery2:    NewUObj := K_CreateUDByRTypeName( 'TN_RQuery2',   1, N_UDQuery2CI );
    ocIterator:  NewUObj := K_CreateUDByRTypeName( 'TN_RIterator', 1, N_UDIteratorCI );
    ocCreator:   NewUObj := K_CreateUDByRTypeName( 'TN_RCreator',  1, N_UDCreatorCI );

    ocNonLinConv:     NewUObj := K_CreateUDByRTypeName( 'TN_RNonLinConv',    1, N_UDNonLinConvCI );
    ocDynPictCreator: NewUObj := K_CreateUDByRTypeName( 'TN_RDynPictCreator',1, N_UDDynPictCreatorCI );
//    ocFileCodec:      NewUObj := K_CreateUDByRTypeName( 'TN_RFileCodec',     1, N_UDFileCodecCI );
    ocCalcUParams:    NewUObj := K_CreateUDByRTypeName( 'TN_RCalcUParams',   1, N_UDCalcUParamsCI );
    ocTextFragm:      NewUObj := K_CreateUDByRTypeName( 'TN_RTextFragm',     1, N_UDTextFragmCI );

    else Exit; // separartor was choosen
    end; // gocomps: case TComps(TypeInd) of


    gDataObj: //********************************************* Data Objects

    case TDataObj(TypeInd) of

    dPoints: begin // Points (always double coords)
      ParamsForm := N_CreateEditParamsForm( 150 );
      with ParamsForm do
      begin
        AddLEdit( 'Number of Digits:', 40, '5' );

        ShowSelfModal();

        if ModalResult <> mrOK then
        begin
          Release; // Release ParamsForm
          Exit;
        end;

        NewUObj := TN_UDPoints.Create();
        Accuracy := N_ScanInteger( EPControls[0].CRStr );
        if (Accuracy < 0) or (Accuracy > 18) then Accuracy := 5;
        TN_UDPoints(NewUObj).WAccuracy := Accuracy;
        Release; // Release ParamsForm
      end; // with ParamsForm do
    end; // dPoints: begin // Points (always double coords)

    dLines: begin // Lines
      ParamsForm := N_CreateEditParamsForm( 250 );
      with ParamsForm do
      begin
        AddLEdit( 'Number of Digits:', 40, '5' );
        AddFixComboBox( 'Coords Type:', N_CoordsTypeNames, 0 );

        ShowSelfModal();

        if ModalResult <> mrOK then
        begin
          Release; // Release ParamsForm
          Exit;
        end;

        NewUObj := TN_ULines.Create1( EPControls[1].CRInt );
        Accuracy := N_ScanInteger( EPControls[0].CRStr );
        if (Accuracy < 0) or (Accuracy > 18) then Accuracy := 5;
        TN_ULines(NewUObj).WAccuracy := Accuracy;
        Release; // Release ParamsForm
      end; // with ParamsForm do
    end; // dLines: begin // Lines

    dConts: begin // Contours
      NewUObj := TN_UContours.Create();
    end; // dConts: begin // Contours

    dUDRArrayBT: begin // UDRArray of some Base type
      ParamsForm := N_CreateEditParamsForm( 250 );
      with ParamsForm do
      begin
        AddFixComboBox( 'Element Type:', N_UDRArrayTypeNames1, 0 );
        ShowSelfModal();
        if ModalResult <> mrOK then
        begin
          Release; // Release ParamsForm
          Exit;
        end;

        NewUObj := K_CreateUDByRTypeName(
                               N_UDRArrayTypeNames2[EPControls[0].CRInt], 3 );
        Release; // Release ParamsForm
      end; // with ParamsForm do
    end; // dUDRArrayBT: begin // UDRArray of some Base type

    dUDRArrayAT: begin // UDRArray of any type
      if not K_SelectRecordTypeCode( IntDTCode, 'Select Array element Type:' ) then
      begin
        ShowResponse( 'Element Type not Selected!' );
        Exit;
      end;
      NewUObj := K_CreateUDByRTypeCode( IntDTCode, 1 );
    end; // dUDRArrayAT: begin // UDRArray of any type

    dUDVectorBT: begin // UDVector of some Base type
      ParamsForm := N_CreateEditParamsForm( 150 );
      with ParamsForm do
      begin
        AddFixComboBox( 'Element Type:', N_UDRArrayTypeNames1, 0 );
        ShowSelfModal();

        if ModalResult <> mrOK then
        begin
          Release; // Release ParamsForm
          Exit;
        end;

        CSS := SelectCSS();
        if CSS = nil then Exit;

        TypeName := N_UDRArrayTypeNames2[EPControls[0].CRInt];
        NewUObj := CSS.CreateDVector( 'Dummy', K_GetTypeCodeSafe(TypeName).All );
        Release; // Release ParamsForm
      end; // with ParamsForm do

    end; // dUDVectorBT: begin // UDVector of some Base type

    dUDVectorAT: begin // UDVector of any type
      if not K_SelectRecordTypeCode( IntDTCode, 'Select Array element Type:' ) then
      begin
        ShowResponse( 'Element Type not Selected!' );
        Exit;
      end;

      CSS := SelectCSS();
      if CSS = nil then Exit;

      NewUObj := CSS.CreateDVector( 'Dummy', IntDTCode );
    end; // dUDVectorAT: begin // UDVector of any type

    dDataBlock: begin // DataBlock (TK_UDCSDBlock)
      if not K_SelectDBlockElemTypeCode( IntDTCode, 'Select Data Block Element Type:' ) then
      begin
        ShowResponse( 'Element Type not Selected!' );
        Exit;
      end;
      DBTCode.All := 0;
      DBTCode.DTCode := IntDTCode;
      NewUObj := TK_UDCSDBlock.CreateAndInit( DBTCode, 'Dummy' );
    end; // dDataBlock: begin // DataBlock (TK_UDCSDBlock)

    dCDim: begin // Codes Dimension
      NewUObj := TK_UDCDim.CreateAndInit( 'Dummy' );
    end; // dCDim: begin // Codes Dimension

    dCSDim: begin // Codes SubDimension
      CDim := SelectCDim();
      if CDim = nil then Exit;
      NewUObj := CDim.CreateCSDim( 'Dummy' );
    end; // dCSDim: begin // Codes SubDimension

    dCSDimRelation: begin // Codes SubDimensions Relation
      CDim := SelectCDim();
      if CDim = nil then Exit;
      NewUObj := TK_UDCDCor.CreateAndInit( 'Dummy', CDim );
    end; // dCSDimRelation: begin // Codes SubDimensions Relation

    dUDMem: begin // Binary Data (TN_UDMem Object)
      NewUObj := TN_UDMem.Create();
    end; // dUDMem: begin // Binary Data (TN_UDMem Object)

    else Exit; // separartor was choosen
    end; // gCObjects: case TCObj(TypeInd) of


    gOtherObj: //********************************************** Other Objects

    case TOtherObj(TypeInd) of

    oEmptyDir:    NewUObj := TN_UDBase.Create(); // Empty Dir (TN_UDBase Obj)

    oArchSection: begin // Archive Section with Uses
        NewUObj := K_CreateUDByRTypeName( 'TK_SLSRoot', 1 );
        with NewUObj do
        begin
          ObjFlags := ObjFlags or K_fpObjSLSRFlag;
          ImgInd := 100; // Is a Section
        end;
      end; // oArchSection: begin

    oFont: begin
        NewUObj := TN_UDLogFont.Create();
        TN_UDLogFont(NewUObj).PascalInit();
      end; // oFont: begin

    oNFont: begin
        NewUObj := TN_UDNFont.Create2( 16, 'Arial' );
//        TN_UDNFont(NewUObj).PascalInit();
      end; // oNFont: begin

    oText: begin
//        NewUObj := TN_UDText.Create();
//        TN_UDText(NewUObj).PascalInit();
      end; // oText: begin

    oCTParamsVar1: begin // Component Tree Params Var1
        NewUObj := K_CreateUDByRTypeName( 'TN_VCTreeParams', 1 );
        PVCTParams := TN_PVCTreeParams(TK_UDRArray(NewUObj).R.P);
        PVCTParams^.VCTName := 'Dummy Tree Name';
        PVCTParams^.VCTHeaderText := 'Dummy Tree Header';
        PVCTParams^.VCTLayers.ARelease();
        PVCTParams^.VCTLayers := K_RCreateByTypeName( 'TN_VCTreeLayer', 1 );
        PVCTreeLayer := TN_PVCTreeLayer(PVCTParams^.VCTLayers.P);
        PVCTreeLayer^.VCTLName := 'Dummy Layer Name';
        PVCTreeLayer^.VCTLParams.ARelease();
        PVCTreeLayer^.VCTLParams := K_RCreateByTypeName( 'TN_CTLVar1', 1 );
        PCTLVar1 := TN_PCTLVar1(PVCTreeLayer^.VCTLParams.P);
        PCTLVar1^.V1LegendHeaderText := 'Dummy Legend Header';
        PCTLVar1^.V1LegElemTexts := K_RCreateByTypeName( 'String', 3 );
        PCTLVar1^.V1LegElemColors := K_RCreateByTypeName( 'Color', 3 );
    end; // clCTParamsVar1: begin // Component Tree Params Var1

    oSklonTable: NewUObj := K_CreateUDByRTypeName( 'TN_SclonOneToken', 5 );
    oSignElems:  NewUObj := K_CreateUDByRTypeName( 'TN_PointAttr2', 3 );

    else Exit; // separartor was choosen
    end; // case TOther(TypeInd) of  (Other Objects)


        gLibElems: //**************************************** Library Elements
    begin
      case TLibElems(TypeInd) of

      lLib_1: begin // Library_1 in ME dir
        LibRoot := N_MapEditorDir.DirChildByObjName( 'Library_1' );
//        LibRoot := N_GetUObjByName( N_MapEditorDir, 'Library_1' );
        if LibRoot = nil then // not found, choose from whole Archive
          LibRoot := K_CurArchive;
      end; // lLib_1: begin // Library_1 in ME dir

      lArchive: LibRoot := K_CurArchive; // choose any UObj from whole Archive

      else Exit; // separartor was choosen
      end; // case TLibElems(TypeInd) of - Library Elements

      NewUObj := N_CreateSubTreeClone( K_SelectUDB( LibRoot, '', nil, nil,
                                                    'Select Library Element' ));

      if NewUObj = nil then Exit; // Library Element was not choosen
    end; // gLibElems

  end; // case TGroups(GroupInd) of

  //***** choose Parent for NewUObj

  if rgWhere.ItemIndex = 1 then // Add NewUObj Inside Slected
    UParent := ASelected
  else //************************* Add NewUObj Before or After Slected
    UParent := ASelParent;

  NewUObj.ObjName   := edName.Text;
  NewUObj.ObjAliase := edAliase.Text;

  if UParent.DirLength > 0 then // because of error in BuildUniqChildName ?
  begin
    NewUObj.ObjName := N_CreateUniqueUObjName( UParent, edName.Text );

    if edAliase.Text <> '' then
      NewUObj.ObjAliase := UParent.BuildUniqChildName( edAliase.Text, nil,
                                                              K_ontObjAliase );
  end; // if UParent.DirLength > 0 then

  //***** NewUObj is OK, add it to DTree Before, Inside or After Selected UObj

  if rgWhere.ItemIndex = 0 then //************ Add NewUObj Before Slected (UParent=Parent of Selected)
  begin
    SelInd := UParent.IndexOfDEField( ASelected );
    UParent.InsOneChild( SelInd, NewUObj );
    UParent.AddChildVnodes( SelInd );
  end else if rgWhere.ItemIndex = 1 then //*** Add NewUObj Inside Slected (UParent=Selected)
  begin
    UParent.AddOneChildV( NewUObj )
  end else //********************************* Add NewUObj After Slected (UParent=Parent of Selected)
  begin
    SelInd := UParent.IndexOfDEField( ASelected );
    UParent.InsOneChild( SelInd+1, NewUObj );
    UParent.AddChildVnodes( SelInd+1 );
  end;

  if NewUObj is TN_UDCompVis then // initialize Visual Component (Coords, Panel, ...)
  with TN_UDCompVis(NewUObj).PSP()^.CCoords do
  begin
    ChildInd := UParent.IndexOfDEField( NewUObj );

    if ChildInd > 35 then ChildInd := 35;

    BPCoords.X := 5 + 12*(ChildInd div 6) +  2*(ChildInd mod 6);
    BPCoords.Y := 5 +  2*(ChildInd div 6) + 12*(ChildInd mod 6);

    BPXCoordsType := cbpPercent;
    BPYCoordsType := cbpPercent;

    SRSize := FPoint( 30, 30 );
    SRSizeXType := cstPercentP;
    SRSizeYType := cstPercentP;

    if NewUObj is TN_UDPanel then // check if CPanel RArray should be created
    begin
      if not (UParent is TN_UDPanel) // root Panel, create CPanel RArray
         or (NewUObj is TN_UDLegend) then // Legend should always has CPanel RArray
        TN_UDCompVis(NewUObj).PCPanelS();

    end; // if NewUObj is TN_UDPanel then // check if CPanel RArray should be created

  end; // with ... do, if NewUObj is TN_UDCompVis then // initialize Visual Component Coords

  if NewUObj is TN_UDWordFragm then // check if Export Params should be created
  begin
    if not (UParent is TN_UDWordFragm) then // root WordFragm, create Export Params
      N_CreateExpParams( TN_UDCompBase(NewUObj) );
  end; // if NewUObj is TN_UDWordFragm then // check if Export Params should be created

  Result := NewUObj;
//  NewUObj.SetChangedSubTreeFlag();
  K_SetChangeSubTreeFlags( NewUObj );
  N_StringToMemIni( 'N_NewUObjF', 'PathToCDim', PathToCDim );  // save Path To CDim
  Release; // Release Self
  end; // with TN_NewUObjForm.Create( Application ) do
end; // function N_CreateNewUObj

end.
