unit N_AVRInit;
// Initialization for VRE Project

interface

implementation

uses Dialogs, SysUtils, Forms, Graphics, Windows, Classes,
  K_CLib, K_FrRAEdit, K_Script1,
  N_Types, N_Lib1, N_Lib2, N_Gra0, N_Gra1, N_Gra2, N_Gra6, 
  N_ClassRef, N_Act1, N_RaEd2DF, N_SPLF, N_Comp3, N_VScalEd1F, N_VRectEd1F,
  N_VPointEd1F, N_Comp2, N_Comp1, N_CompBase, N_AlignF, N_Rast1Fr, N_UDCMap,
  N_CompCL, N_ME1, N_UDat4, N_ExpImp1, N_VRE3, N_Color1F,
  N_RAEditF, N_NLConvF, N_SGComp, N_DGrid;

Initialization

//*** Global variables initialization

//***** variables defined in N_Types
  N_WinNTGDI := True; // temporary
  N_DefImageFilePar.IFPImFileFmt := imffByFileExt;
  N_DefImageFilePar.IFPJPEGQuality := 80;

//***** variables defined in  N_NLConvF
  N_RFAClassRefs[N_ActEd3Rects] := TN_Ed3RectsRFA;

//***** variables defined in  N_SGComp
  N_RFAClassRefs[N_ActRubberRect] := TN_RubberRectRFA;
  N_RFAClassRefs[N_ActRubberSegm] := TN_RubberSegmRFA;
  N_RFAClassRefs[N_ActEditComps]  := TN_EditCompsRFA;

//***** variables defined in  N_DGrid
  N_RFAClassRefs[N_ActDGridRFA]   := TN_DGridBaseMatrRFA;

//***** variables defined in  N_RAEditF
  // External Editors:
  K_RegRAFEditor( 'NRAFRAEditEditor',    TN_RAFRAEditEditor );
//  K_RegRAFEditor( 'RAFVArrayEditor',     TN_RAFVArrayEditor );
  K_RegRAFEditor( 'NRAFUDRefEditor',     TN_RAFUDRefEditor );
  K_RegRAFEditor( 'NRAFUserParamEditor', TN_RAFUserParamEditor );
  K_RegRAFEditor( 'NRAFCharCodesEditor', TN_RAFCharCodesEditor );
  K_RegRAFEditor( 'NRAFValsInStrEditor', TN_RAFValsInStrEditor );
  K_RegRAFEditor( 'NRAFPA2SPEditor',     TN_RAFPA2SPEditor );
  K_RegRAFEditor( 'NRAFPenStyleEditor',  TN_RAFPenStyleEditor );
  K_RegRAFEditor( 'NRAFTableStrEditor',  TN_RAFTableStrEditor );
  K_RegRAFEditor( 'NRAFMSScalEditor',    TN_RAFMSScalEditor );
  K_RegRAFEditor( 'NRAFMSPointEditor',   TN_RAFMSPointEditor );
  K_RegRAFEditor( 'NRAFMSRectEditor',    TN_RAFMSRectEditor );

  // External Viewers:
  K_RegRAFViewer( 'NRAFRAEditEditor',    TN_RAFRAEditEditor );
  K_RegRAFViewer( 'NRAFUserParamEditor', TN_RAFUserParamEditor );
  K_RegRAFViewer( 'NRAFCharCodesEditor', TN_RAFCharCodesEditor );
  K_RegRAFViewer( 'NRAFValsInStrEditor', TN_RAFValsInStrEditor );
  K_RegRAFViewer( 'NRAFPA2SPEditor',     TN_RAFPA2SPEditor );
  K_RegRAFViewer( 'NRAFPenStyleEditor',  TN_RAFPenStyleEditor );
  K_RegRAFViewer( 'NRAFMSScalEditor',    TN_RAFMSScalEditor );
  K_RegRAFViewer( 'NRAFMSPointEditor',   TN_RAFMSPointEditor );
  K_RegRAFViewer( 'NRAFMSRectEditor',    TN_RAFMSRectEditor );

  K_RegGEFunc( 'N_RAEditForm', N_CallRAEditForm, @N_RAEditFuncCont );

//***** variables defined in  N_Color1F
  K_RegRAFEditor( 'NRAFColorVEditor', TN_RAFColorVEditor );

//***** variables defined in  N_VRE3
  N_RFAClassRefs[N_ActDebAction1]    := TN_RFDebAction1;

  N_RFAClassRefs[N_ActShowCObjInfo]  := TN_RFAShowCObjInfo;

  N_RFAClassRefs[N_ActHighPoint]     := TN_RFAHighPoint;
  N_RFAClassRefs[N_ActMovePoint]     := TN_RFAMovePoint;
  N_RFAClassRefs[N_ActAddPoint]      := TN_RFAAddPoint;
  N_RFAClassRefs[N_ActDeletePoint]   := TN_RFADeletePoint;

  N_RFAClassRefs[N_ActMoveLabel]     := TN_RFAMoveLabel;
  N_RFAClassRefs[N_ActAddLabel]      := TN_RFAAddLabel;
  N_RFAClassRefs[N_ActDeleteLabel]   := TN_RFADeleteLabel;
  N_RFAClassRefs[N_ActEditLabel]     := TN_RFAEditLabel;

  N_RFAClassRefs[N_ActHighLine]      := TN_RFAHighLine;
  N_RFAClassRefs[N_ActEditVertex]    := TN_RFAEditVertex;
  N_RFAClassRefs[N_ActDeleteLine]    := TN_RFADeleteLine;
  N_RFAClassRefs[N_ActSplitCombLine] := TN_RFASplitCombLine;
  N_RFAClassRefs[N_ActAffConvLine]   := TN_RFAAffConvLine;

  N_RFAClassRefs[N_ActMarkCObjPart]  := TN_RFAMarkCObjPart;
  N_RFAClassRefs[N_ActMarkPoints]    := TN_RFAMarkPoints;
  N_RFAClassRefs[N_ActSetItemCodes]  := TN_RFASetItemCodes;
  N_RFAClassRefs[N_ActEditItemCode]  := TN_RFAEditItemCode;
  N_RFAClassRefs[N_ActEditRegCodes]  := TN_RFAEditRegCodes;

  N_RFAClassRefs[N_ActSetShapeCoords] := TN_RFASetShapeCoords;

//***** variables defined in  N_ExpImp1
  N_RegActionProc( 'ImportMIF1', N_ActionImportMIF1 ); // MIF-MID files import

//***** variables defined in  N_Lib1
  N_GlobIni := TN_MemIniObj.Create();
  N_UserIni := TN_MemIniObj.Create();

  ForceCurrentDirectory := True;
  N_ApplicationTerminated := False;

//  N_InitialFileDir := ExtractFilePath( Application.ExeName ) + '\';
  N_InitialFileDir := 'c:\Delphi_Prj\AMap_Editor';
  N_ExeNameDir := ExtractFilePath( Application.ExeName );
  N_CurDateTime := Now();

//  N_OCanvDefPixFmt := pf16bit;
  N_OCanvDefPixFmt := pf32bit;
//  N_ScreenPixelFormat := pf16bit;
  N_ScreenPixelFormat := pf32bit;

  InitializeCriticalSection( N_OCanvCriticalSection ); // not used
  N_SaveAllToMemIni := TN_ActListObj.Create;
  N_CurArchChanged  := TN_ActListObj.Create;
  N_InfoSL := TStringList.Create;
  N_SL  := TStringList.Create;
  N_SL1 := TStringList.Create;
  N_SL2 := TStringList.Create;

//***** variables defined in  N_Lib2
  N_GlobObj2  := TN_GlobObj2.Create;

  N_ClassRefArray[N_UDLogFontCI] := TN_UDLogFont;
  N_ClassTagArray[N_UDLogFontCI] := 'LogFont';

  N_ClassRefArray[N_UDNFontCI]   := TN_UDNFont;
  N_ClassTagArray[N_UDNFontCI]   := 'NFont';
{
  N_ClassRefArray[N_UDTextCI]    := TN_UDText;
  N_ClassTagArray[N_UDTextCI]    := 'UDText';
}
  K_RegRAFrDescription( 'TN_PointAttr1',     'TN_PointAttr1FormDescr' );
  K_RegRAFrDescription( 'TN_PointAttr2',     'TN_PointAttr2FormDescr' );
  K_RegRAFrDescription( 'TN_PA2StrokeShape', 'TN_PA2StrokeShapeFormDescr' );
  K_RegRAFrDescription( 'TN_PA2RoundRect',   'TN_PA2RoundRectFormDescr' );
  K_RegRAFrDescription( 'TN_PA2EllipseFragm', 'TN_PA2EllipseFragmFormDescr' );
  K_RegRAFrDescription( 'TN_PA2RegPolyFragm', 'TN_PA2RegPolyFragmFormDescr' );
  K_RegRAFrDescription( 'TN_PA2TextRow',     'TN_PA2TextRowFormDescr' );
  K_RegRAFrDescription( 'TN_PA2Picture',     'TN_PA2PictureFormDescr' );
  K_RegRAFrDescription( 'TN_PA2Arrow',       'TN_PA2ArrowFormDescr' );
  K_RegRAFrDescription( 'TN_PA2PolyLine',    'TN_PA2PolyLineFormDescr' );

  K_RegRAFrDescription( 'TN_SysLineAttr',    'TN_SysLineAttrFormDescr' );
  K_RegRAFrDescription( 'TN_AuxLine',        'TN_AuxLineFormDescr' );
  K_RegRAFrDescription( 'TN_TimeSeriesUP',   'TN_TimeSeriesUPFormDescr' );
  K_RegRAFrDescription( 'TN_CodeSpaceItem',  'TN_CSItem1FormDescr' );

  K_RegRAInitFunc( 'TN_AuxLine',    N_InitAuxLine );
  K_RegRAInitFunc( 'TN_ExpParams',  N_InitExpParams );
  K_RegRAInitFunc( 'TN_ContAttr',   N_InitContAttr );
  K_RegRAInitFunc( 'TN_NFont',      N_InitNFont );

//***** variables defined in  N_Rast1Fr
  N_RFAClassRefs[N_ActShowAction]  := TN_RFAShowAction;
  N_RFAClassRefs[N_ActMouseAction] := TN_RFAMouseAction;
  N_RFAClassRefs[N_ActZoom]        := TN_RFAZoom;
  N_RFAClassRefs[N_ActGetUPoint]   := TN_RFAGetUPoint;

//***** variables defined in  N_Gra0, N_Gra1
  N_LineInfo := TN_LineInfo.Create;

  SetLength( N_WrkClipedLengths, 3 );
  SetLength( N_WrkClipedFLines,  3 );
  SetLength( N_WrkClipedDLines,  3 );
  SetLength( N_WrkFSegm1, 2 );
  SetLength( N_WrkDSegm1, 2 );
  SetLength( N_Wrk1Ints, 100 );

//***** variables defined in  N_Gra2
  SetLength( N_ZeroIntegers, 990 );
  FillChar( N_ZeroIntegers[0], Length(N_ZeroIntegers)*Sizeof(integer), 0 );

//***** variables defined in  N_Gra6
  N_PixOpObj := TN_PixOperationsObj.Create();
  with N_PixOpObj do
  begin
    PO_RGBDifCoefs[0] := 1.0;
    PO_RGBDifCoefs[1] := 0.5;
    PO_RGBDifCoefs[2] := 0.4;
    PO_RGBDifCoefs[3] := 0.3;
  end;

//***** variables defined in  N_UDat4
  N_ClassRefArray[N_UCObjRefsCI]  := TN_UCObjRefs;
  N_ClassTagArray[N_UCObjRefsCI]  := 'UCObjRefs';

  N_ClassRefArray[N_UDPointsCI]   := TN_UDPoints;
  N_ClassTagArray[N_UDPointsCI]   := 'UDPoints';

  N_ClassRefArray[N_ULinesCI]     := TN_ULines;
  N_ClassTagArray[N_ULinesCI]     := 'ULines';

  N_ClassRefArray[N_UContoursCI]  := TN_UContours;
  N_ClassTagArray[N_UContoursCI]  := 'UContours';

  N_ClassRefArray[N_UDBaseLibCI]  := TN_UDBaseLib;
  N_ClassTagArray[N_UDBaseLibCI]  := 'UDBaseLib';

  N_ClassRefArray[N_UDOwnFontCI]  := TN_UDOwnFont;
  N_ClassTagArray[N_UDOwnFontCI]  := 'UDOwnFont';


//***** variables defined in  N_ME1
  N_StateString := TN_StateString.Create; // Obj for Showing State and Progres
  N_MEGlobObj := TN_MEGlobObj.Create;     // ME Global Object

  K_RegRAFEditor( 'NRAFontEditor',   TN_RAFRAFontEditor );
  K_RegRAFEditor( 'NWinFontEditor',  TN_RAFWinFontEditor );
  K_RegRAFEditor( 'NWinNFontEditor', TN_RAFWinNFontEditor );
  K_RegRAFEditor( 'NMLCoordsEditor', TN_RAFMLCoordsEditor );

  K_RegRAFrDescription( 'TN_VCTreeParams',  'TN_VCTreeParamsFormDescr' );
  K_RegRAFrDescription( 'TN_VCTreeLayer',   'TN_VCTreeLayerFormDescr' );
  K_RegRAFrDescription( 'TN_CTLVar1',       'TN_CTLVar1FormDescr' );
  K_RegRAFrDescription( 'TN_SclonOneToken', 'TN_SclonOneTokenFormDescr' );

  K_RegRAFrDescription( 'TN_TaCell',  'TN_CellFormDescr' );

//***** variables defined in  N_CompCL
  K_RegRAInitFunc( 'TN_OneTextBlock', N_InitTextBlocks );

//***** variables defined in  N_UDCMap
  N_ClassRefArray[N_UDMapLayerCI]  := TN_UDMapLayer;
  N_ClassTagArray[N_UDMapLayerCI]  := 'MapLayer';

  N_RFAClassRefs[N_ActShowUserInfo] := TN_RFAShowUserInfo;

//***** variables defined in  N_AlignF
  N_RFAClassRefs[N_ActMoveComps]  := TN_RFAMoveComps;
  N_RFAClassRefs[N_ActMarkComps]  := TN_RFAMarkComps;

//***** variables defined in  N_CompBase
  N_DefExpParams.EPImageFPar := N_DefImageFilePar;

  N_ClassRefArray[N_UDCompBaseCI] := TN_UDCompBase;
  N_ClassTagArray[N_UDCompBaseCI] := 'BaseComp';

  N_ClassRefArray[N_UDCompVisCI]  := TN_UDCompVis;
  N_ClassTagArray[N_UDCompVisCI]  := 'VisualComp';

  N_RegSetParamsFunc( 'TestFunc1', N_SetParamsFunc1 );

//***** variables defined in  N_Comp1
  N_ClassRefArray[N_UDPanelCI]    := TN_UDPanel;
  N_ClassTagArray[N_UDPanelCI]    := 'Panel';

  N_ClassRefArray[N_UDTextBoxCI]  := TN_UDTextBox;
  N_ClassTagArray[N_UDTextBoxCI]  := 'TextBox';

  N_ClassRefArray[N_UDParaBoxCI]  := TN_UDParaBox;
  N_ClassTagArray[N_UDParaBoxCI]  := 'ParaBox';

  N_ClassRefArray[N_UDLegendCI]   := TN_UDLegend;
  N_ClassTagArray[N_UDLegendCI]   := 'Legend';

  N_ClassRefArray[N_UDNLegendCI]  := TN_UDNLegend;
  N_ClassTagArray[N_UDNLegendCI]  := 'NLegend';

  N_ClassRefArray[N_UDPictureCI]  := TN_UDPicture;
  N_ClassTagArray[N_UDPictureCI]  := 'Picture';

  N_ClassRefArray[N_UDDIBCI]      := TN_UDDIB;
  N_ClassTagArray[N_UDDIBCI]      := 'DIB';

  N_ClassRefArray[N_UDDIBRectCI]  := TN_UDDIBRect;
  N_ClassTagArray[N_UDDIBRectCI]  := 'DIBRect';

  N_ClassRefArray[N_UDFileCI]     := TN_UDFile;
  N_ClassTagArray[N_UDFileCI]     := 'File';

  N_ClassRefArray[N_UDActionCI]   := TN_UDAction;
  N_ClassTagArray[N_UDActionCI]   := 'Action';

  N_ClassRefArray[N_UDExpCompCI]  := TN_UDExpComp;
  N_ClassTagArray[N_UDExpCompCI]  := 'ExpComp';

{ //******* Class registration Pattern
  N_ClassRefArray[N_UDVCPatternCI] := TN_UDVCPattern;
  N_ClassTagArray[N_UDVCPatternCI] := 'VCPattern';
}

//***** variables defined in  N_Comp2
  N_ClassRefArray[N_UDPolylineCI]  := TN_UDPolyline;
  N_ClassTagArray[N_UDPolylineCI]  := 'UDPolyline';

  N_ClassRefArray[N_UDArcCI]       := TN_UDArc;
  N_ClassTagArray[N_UDArcCI]       := 'UDArc';

  N_ClassRefArray[N_UDSArrowCI]    := TN_UDSArrow;
  N_ClassTagArray[N_UDSArrowCI]    := 'SArrow';

  N_ClassRefArray[N_UD2DSpaceCI]   := TN_UD2DSpace;
  N_ClassTagArray[N_UD2DSpaceCI]   := '2DSpace';

  N_ClassRefArray[N_UDAxisTicsCI]  := TN_UDAxisTics;
  N_ClassTagArray[N_UDAxisTicsCI]  := 'AxisTics';

  N_ClassRefArray[N_UDTextMarksCI] := TN_UDTextMarks;
  N_ClassTagArray[N_UDTextMarksCI] := 'TextMarks';

  N_ClassRefArray[N_UDAutoAxisCI]  := TN_UDAutoAxis;
  N_ClassTagArray[N_UDAutoAxisCI]  := 'AutoAxis';

  N_ClassRefArray[N_UD2DFuncCI]    := TN_UD2DFunc;
  N_ClassTagArray[N_UD2DFuncCI]    := '2DFunc';

  N_ClassRefArray[N_UDIsoLinesCI]  := TN_UDIsoLines;
  N_ClassTagArray[N_UDIsoLinesCI]  := 'IsoLines';

  N_ClassRefArray[N_UD2DLinHistCI] := TN_UD2DLinHist;
  N_ClassTagArray[N_UD2DLinHistCI] := '2DLinHist';

  N_ClassRefArray[N_UDLinHistAuto1CI] := TN_UDLinHistAuto1;
  N_ClassTagArray[N_UDLinHistAuto1CI] := 'LinHistAuto1';

  N_ClassRefArray[N_UDPieChartCI]  := TN_UDPieChart;
  N_ClassTagArray[N_UDPieChartCI]  := 'PieChart';

  N_ClassRefArray[N_UDTableCI]     := TN_UDTable;
  N_ClassTagArray[N_UDTableCI]     := 'Table';

  N_ClassRefArray[N_UDCompsGridCI] := TN_UDCompsGrid;
  N_ClassTagArray[N_UDCompsGridCI] := 'CompsGrid';

  K_RegRAInitFunc ( 'TN_C2DLHStyle',      N_InitLHStyle );
  N_RegCreatorProc( 'LinHist_2Page', N_CrCreateLinHist_2Page ); // Create LinHist_2 Page

//***** variables defined in  N_Comp3
//  K_RegRAFEditor( 'NRAFANLCEditor', TN_RAFANLCEditor );

  N_ClassRefArray[N_UDQuery1CI]     := TN_UDQuery1;
  N_ClassTagArray[N_UDQuery1CI]     := 'Query1';

  N_ClassRefArray[N_UDIteratorCI]   := TN_UDIterator;
  N_ClassTagArray[N_UDIteratorCI]   := 'Iterator';

//  N_ClassRefArray[N_UDCreatorCI]    := TN_UDCreator;
//  N_ClassTagArray[N_UDCreatorCI]    := 'Creator';

  N_ClassRefArray[N_UDNonLinConvCI] := TN_UDNonLinConv;
  N_ClassTagArray[N_UDNonLinConvCI] := 'NonLinConv';

  N_ClassRefArray[N_UDDynPictCreatorCI] := TN_UDDynPictCreator;
  N_ClassTagArray[N_UDDynPictCreatorCI] := 'DynPictCreator';

  N_ClassRefArray[N_UDCalcUParamsCI] := TN_UDCalcUParams;
  N_ClassTagArray[N_UDCalcUParamsCI] := 'CalcUParams';

  N_ClassRefArray[N_UDTextFragmCI]   := TN_UDTextFragm;
  N_ClassTagArray[N_UDTextFragmCI]   := 'TextFragm';

  N_ClassRefArray[N_UDWordFragmCI]   := TN_UDWordFragm;
  N_ClassTagArray[N_UDWordFragmCI]   := 'WordFragm';

  N_ClassRefArray[N_UDExcelFragmCI]  := TN_UDExcelFragm;
  N_ClassTagArray[N_UDExcelFragmCI]  := 'ExcelFragm';

{ //******* Class registration Pattern
  N_ClassRefArray[N_UDBCPatternCI] := TN_UDBCPattern;
  N_ClassTagArray[N_UDBCPatternCI] := 'BCPattern';
}
  N_RegCreatorProc( 'JustCreate',  N_CreatorJustCreate ); // Just Create new UObj

//***** variables defined in  N_VPointEd1F
  K_RegRAFEditor( 'NPointVEditor', TN_RAFPointVEditor );

//***** variables defined in  N_VRectEd1F
  K_RegRAFEditor( 'NRectVEditor', TN_RAFRectVEditor );

//***** variables defined in  N_VScalEd1F
  K_RegRAFEditor( 'NScalVEditor', TN_RAFScalVEditor );


//***** variables defined in  N_SPLF
//**************** My indexes are 200 - 299  **************************

  K_ExprNFuncNames[204] := 'Deb1';
  K_ExprNFuncRefs [204] := N_SPLFDeb1;

  K_ExprNFuncNames[205] := 'Deb2';
  K_ExprNFuncRefs [205] := N_SPLFDeb2;

  K_ExprNFuncNames[206] := 'AddStrToFile';
  K_ExprNFuncRefs [206] := N_SPLFAddStrToFile;

  K_ExprNFuncNames[207] := 'AddPDCounter';
  K_ExprNFuncRefs [207] := N_SPLFAddPDCounter;

//  K_ExprNFuncNames[211] := 'Склон';
  K_ExprNFuncNames[211] := 'Sclon';
  K_ExprNFuncRefs [211] := N_SPLFSclon;

  K_ExprNFuncNames[212] := 'UDFPStat';
  K_ExprNFuncRefs [212] := N_SPLFUDFPStat;

  K_ExprNFuncNames[213] := 'UDFPDyn';
  K_ExprNFuncRefs [213] := N_SPLFUDFPDyn;

  K_ExprNFuncNames[214] := 'CSItemKeyPDyn';
  K_ExprNFuncRefs [214] := N_SPLFCSItemKeyPDyn;

  K_ExprNFuncNames[215] := 'ExecComp';
  K_ExprNFuncRefs [215] := N_SPLFExecComp;

  K_ExprNFuncNames[216] := 'SampleText';
  K_ExprNFuncRefs [216] := N_SPLFSampleText;

  K_ExprNFuncNames[217] := 'DateTimeToStr';
  K_ExprNFuncRefs [217] := N_SPLFDateTimeToStr;

  K_ExprNFuncNames[218] := 'WSInfoToStr';
  K_ExprNFuncRefs [218] := N_SPLFWSInfoToStr;

  K_ExprNFuncNames[219] := 'GetGCVar';
  K_ExprNFuncRefs [219] := N_SPLFGetGCVar;

  K_ExprNFuncNames[220] := 'SetGCVar';
  K_ExprNFuncRefs [220] := N_SPLFSetGCVar;


  K_ExprNFuncNames[221] := 'GetDblRow';
  K_ExprNFuncRefs [221] := N_SPLFGetDblRow;


  //************ WTable procedures and functions
  K_ExprNFuncNames[225] := 'SetGCMDBm';
  K_ExprNFuncRefs [225] := N_SPLFSetGCMDBm;

  K_ExprNFuncNames[226] := 'GetWordVar';
  K_ExprNFuncRefs [226] := N_SPLFGetWordVar;

  K_ExprNFuncNames[227] := 'CreateWordVar';
  K_ExprNFuncRefs [227] := N_SPLFCreateWordVar;

  K_ExprNFuncNames[228] := 'SetWordVar';
  K_ExprNFuncRefs [228] := N_SPLFSetWordVar;

  K_ExprNFuncNames[229] := 'RunWMacro';
  K_ExprNFuncRefs [229] := N_SPLFRunWMacro;

  K_ExprNFuncNames[230] := 'SetWMainDocIP';
  K_ExprNFuncRefs [230] := N_SPLFSetWMainDocIP;

  K_ExprNFuncNames[231] := 'SetCurWTable';
  K_ExprNFuncRefs [231] := N_SPLFSetCurWTable;

  K_ExprNFuncNames[232] := 'InsWTableRows';
  K_ExprNFuncRefs [232] := N_SPLFInsWTableRows;


  K_ExprNFuncNames[235] := 'SetWTableStrCell';
  K_ExprNFuncRefs [235] := N_SPLFSetWTableStrCell;

  K_ExprNFuncNames[236] := 'SetWTableValCell';
  K_ExprNFuncRefs [236] := N_SPLFSetWTableValCell;

  K_ExprNFuncNames[237] := 'SetWTableCompCell';
  K_ExprNFuncRefs [237] := N_SPLFSetWTableCompCell;

  K_ExprNFuncNames[238] := 'SetWTableStrRow';
  K_ExprNFuncRefs [238] := N_SPLFSetWTableStrRow;

  // 239-246 reserved for WTable funcs

  K_ExprNFuncNames[247] := 'SetFirstPageNum';
  K_ExprNFuncRefs [247] := N_SPLFSetFirstPageNum;

  //************ ESheet procedures and functions

  K_ExprNFuncNames[249] := 'ECN';
  K_ExprNFuncRefs [249] := N_SPLFECN;

  K_ExprNFuncNames[250] := 'SetCurESheet';
  K_ExprNFuncRefs [250] := N_SPLFSetCurESheet;

  K_ExprNFuncNames[251] := 'InsESheetRows';
  K_ExprNFuncRefs [251] := N_SPLFInsESheetRows;


  K_ExprNFuncNames[253] := 'SetESheetStrCell';
  K_ExprNFuncRefs [253] := N_SPLFSetESheetStrCell;

  K_ExprNFuncNames[254] := 'SetESheetDblCell';
  K_ExprNFuncRefs [254] := N_SPLFSetESheetDblCell;

  K_ExprNFuncNames[255] := 'SetESheetCompCell';
  K_ExprNFuncRefs [255] := N_SPLFSetESheetCompCell;


  K_ExprNFuncNames[257] := 'SetESheetStrRow';
  K_ExprNFuncRefs [257] := N_SPLFSetESheetStrRow;

  K_ExprNFuncNames[258] := 'SetESheetStrCol';
  K_ExprNFuncRefs [258] := N_SPLFSetESheetStrCol;

  K_ExprNFuncNames[259] := 'SetESheetDblRow';
  K_ExprNFuncRefs [259] := N_SPLFSetESheetDblRow;

  K_ExprNFuncNames[260] := 'SetESheetDblCol';
  K_ExprNFuncRefs [260] := N_SPLFSetESheetDblCol;

  K_ExprNFuncNames[261] := 'SetESheetDblMatr';
  K_ExprNFuncRefs [261] := N_SPLFSetESheetDblMatr;

// N_RaEd2DF
  K_RegRAFEditor( 'NRAFRAEd2DEditor',  TN_RAFRAEd2DEditor );
  K_RegGEFunc( 'N_RAEdit2DForm', N_CallRAEdit2DForm, @N_RAEdit2DFuncCont );

// N_Act1
  N_RegActionProc( 'ULinesAction1',    N_ActULinesAction1 ); // ULines Actions #1
  N_RegActionProc( 'ULinesAction2',    N_ActULinesAction2 ); // ULines Actions #2
  N_RegActionProc( 'CreateUDPoints',   N_ActCreateUDPoints );// Create UDPoints
  N_RegActionProc( 'CreateULines',     N_ActCreateULines );  // Create ULines
  N_RegActionProc( 'CObjAction1',      N_ActCObjAction1 );   // CObj Actions #1
  N_RegActionProc( 'CObjAction2',      N_ActCObjAction2 );   // CObj Actions #2
  N_RegActionProc( 'ExportCObj',       N_ActExportCObj );    // Export CObj
  N_RegActionProc( 'ChangeCObjCodes',  N_ActChangeCObjCodes ); // Change CObj Codes
  N_RegActionProc( 'ChangeMLUObj',     N_ActChangeMLUObj );  // Change MapLayer UObjects
  N_RegActionProc( 'FillVisVector',    N_ActFillVisVector ); // Fill Vis. Vector by CSProjection
  N_RegActionProc( 'ConvCoords1',      N_ActConvCoords1 );   // Convert CObj Coords #1
  N_RegActionProc( 'NonLinConv1',      N_ActNonLinConv1 );   // Non Linear Convertion #1
  N_RegActionProc( 'SnapULines',       N_ActSnapULines );    // Snap ULines (obsolete)
  N_RegActionProc( 'JavaToSVG1',       N_ActJavaToSVG1 );    // Convert Java map to SVG text file
  N_RegActionProc( 'JavaToULines',     N_ActJavaToULines );  // Convert Java map to ULines CObj
  N_RegActionProc( 'ContCenterPoints', N_ActContCenterPoints ); // Convert Java map to ULines CObj
  N_RegActionProc( 'CreateTextBlocks', N_ActCreateTextBlocks ); // Convert Java map to ULines CObj

  N_RegActionProc( 'SysActions1',      N_ActSysActions1 );   // Several Sys Actions #1
  N_RegActionProc( 'SysActions2',      N_ActSysActions2 );   // Several Sys Actions #2
  N_RegActionProc( 'ReplaceRefs',      N_ActReplaceRefs );   // Replace Refs in given SubTree
  N_RegActionProc( 'VFileCodec',       N_ActVFileCodec );    // Recode VFile
  N_RegActionProc( 'DebAction1',       N_ActDebAction_1 );   // Temporary Debug Action #1

  N_RegActionProc( 'LayoutComps',      N_ActLayoutComps );     // Layout Components
  N_RegActionProc( 'CreateLinHist_1',  N_ActCreateLinHist_1 ); // Create LinHist_1 Stacked LinHist with RowNames
  N_RegActionProc( 'CreateLinHist_2',  N_ActCreateLinHist_2 ); // Create LinHist_2 MultiColumn LinHist
  N_RegActionProc( 'SetMCLHUP',        N_ActSetMCLHUP );       // Set MultiColumn LinHist User Params

  N_RegActionProc( 'WordIcons',        N_ActGetWordIcons );     // порождение панели с иконками
  N_RegActionProc( 'WordDebActive1',   N_ActWordDebActive1 );   // работа с текущим активным документом
  N_RegActionProc( 'WordCreateTable1', N_ActWordCreateTable1 ); // Create Table1 for FOM Atlas
  N_RegActionProc( 'WordActions',      N_ActWordActions );      // several Word related Actions

  N_RegActionProc( 'ExcelIcons',       N_ActGetExcelIcons ); // порождение панели с иконками
  N_RegActionProc( 'ExcelDeb1',        N_ActExcelDeb1 );     // Excel Action Debug 1
  N_RegActionProc( 'ExcelDeb2',        N_ActExcelDeb2 );     // Excel Action Debug 2

  N_RegActionProc( 'CreateGif',        N_ActCreateGif );      // Create GIF file with Transp color
  N_RegActionProc( 'FileActions',      N_ActFileActions );    // File Actions
  N_RegActionProc( 'ListParaBoxes',    N_ActListParaBoxes );  // List ParaBoxes
  N_RegActionProc( 'CompsToPas1',      N_ActCompsToPas1 );    // Conv Comps to Pascal, var #1
  N_RegActionProc( 'ToggleSkipSelf',   N_ActToggleSkipSelf ); // ToggleSkipSelf
  N_RegActionProc( 'UpdateAttrs1',     N_ActUpdateAttrs1 );   // Update Attributes, var #1

Finalization
  //*** All created Objects will be released by Delphi
  
end.
