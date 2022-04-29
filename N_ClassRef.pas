unit N_ClassRef;
// N_ClassRefArray with class references to all ancestors of TN_UDBase and
// Type Class Indexes - N(K)_UDxxxCI constants (indexes in N_ClassRefArray)

interface
uses classes,
     K_UDT1;

type TN_UDBaseClass = Class of TN_UDBase;

var N_ClassRefList: TStringList;

const N_ClassRefArrayMaxInd = $DB; // $DB = 219, N_ClassRefArray and N_ClassTagArray Sizes

var N_ClassRefArray: Array [0..N_ClassRefArrayMaxInd] of TN_UDBaseClass =
     ( nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 0
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 1
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 2
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 3
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 4
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 5
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 6
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 7
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 8
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 9
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 10
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 11
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 12
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 13
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 14
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 15
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 16
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 17
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 18
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 19
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  // 20
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil );// 21

var N_ClassTagArray: Array [0..N_ClassRefArrayMaxInd] of string;

const  //****** ClassFlags static flags value *********************************

K_ClassIndexBits     = $000000FF; // UDBase Class Index Bits (in N_ClassRefArray,N_ClassTagArray)
// K_ClassTypeMask   = $FFFFFF00; - defined in K_UDT1
//                     $00001F00  - not used
K_RArrayObjBit       = $00002000; // UDBase object is UDRArray
N_CompBaseBit        = $00004000; // TN_UDCompBase object
K_ChangedSubTreeBit  = $00008000; // UDBase SubTree Was Changed
K_ChangedSLSRBit     = $00010000; // SLS Root Was Changed
K_SkipDestructBit    = $00020000; // Skip UDNode Destruction Static Flag
K_SkipDestructBitD   = $00040000; // Skip UDNode Destruction Dynamic Flag
K_PermVizMarkBit     = $00080000; // Permanent Vizual Node Mark Flag
//                     $00F00000  - not used
//                     $0F000000  - not used
K_SkipSelfSaveBit    = $10000000; // Skip Obj from Binary and Text SubTree serialization
//K_SkipFromFileBit    = $10000000; // Skip Child from Binary and Text SubTree serialization
K_MarkerArrayBit     = $20000000; // UDObj Marker field is TN_IArray
K_MarkVizBitD        = $40000000; // Mark UDNodes while TN_VNodes creation Dynamic Flag
K_MarkScanNodeBitD   = $80000000; // Mark Scaned UDNodes in SubTree Iterators Dynamic Flag

const  //********************* Type Class Indexes *****************************

  // N_(1) ************************************* $000 - $01F
  N_UDBaseCI        = $01;
  N_UDMemCI         = $02;
  N_UDExtMemCI      = $03;

  K_UDStringListCI  = $06;

  N_UDCompBaseCI    = $10;
  N_UDCompVisCI     = $11;

  N_UCObjRefsCI     = $13;

  N_UDPointsCI      = $15;
  N_ULinesCI        = $16;

  N_UContoursCI     = $18;
  N_UDPolylineCI    = $19;
  N_UDArcCI         = $1A;
  N_UDBaseLibCI     = $1B;
  N_UDOwnFontCI     = $1C;

  // end of N_(1) ****************************** $000 - $01F


  // K_(1) ************************************* $020 - $04F
  K_UDCDimCI            = $20;
  K_UDCSDimCI           = $21;
  K_UDCDCorCI           = $22;
  K_UDCSDBlockCI        = $23;
  K_UDERDBlockCI        = $24;
  K_UDCDRelCI           = $25;
  K_UDRAListCI          = $26;
//  K_UDDirSubSectionsCI  = $25;  //**
//  K_UDDirSightsCI       = $26;  //**
//  K_UDDirBaseTypesCI    = $27;  //**

//  K_UDDataInterfaceCI   = $30;  //**
//  reserved     = $31;
//  K_UDIndValuesCI       = $32;  //**
//  K_UDIndMainScaleCI    = $33;  //**
//  K_UDIndAuxScaleCI     = $34;  //**
//  K_UDScaleValuesCI     = $35;  //**
//  K_UDScaleTextsCI      = $36;  //**
//  K_UDScaleColorsCI     = $37;  //**
//  K_UDSBuilder1MCI      = $38;  //**
//  K_UDSightCI           = $39;  //**
//  K_UDSectionCI         = $3A;  //**
//  K_UDSubSectionCI      = $3B;  //**
//  K_UDHistTableCI       = $3C;  //**
//  K_UDDirMapsCI         = $3D;  //**
//  K_UDDirSysCI          = $3E;  //**
//  K_UDMapInterfaceCI    = $3F;  //**
//  K_UDMapCI             = $40;  //**
//  K_UDDirHTMPromptsCI   = $41;  //**
//  K_UDIndicatorCI       = $42;  //**
//  K_UDHTMPromptCI       = $43;  //**
//  K_UDSBuilderEvenCI    = $44;  //**
//  K_UDSBuilderLogCI     = $45;  //**
  K_UDADSDocSectionCI     = $46;
  K_UDADSFileFolderCI     = $47;
  K_UDADSSrcFileCI        = $48;
  K_UDADSDocFragmCI       = $49;

  K_UDRefCI             = $4A;

//  K_UDFArrayCI          = $4B;   //**

//  K_UDBaseParamsDataCI  = $4C;   //**
  K_UDUnitCI            = $4D;
  K_UDUserRootCI        = $4E;   // ??
//  K_UDDirRepositoryCI   = $4F;   //**
  // end of K_(1) ************************************* $020 - $04F


  // N_(2) ************************************* $050 - $0AF
  N_UDLogFontCI       = $51;
//  N_UDDElemsCI        = $52;
//  N_UDTextCI          = $53;
  N_UDNFontCI         = $54;

  N_UDCMSlideCI       = $58;
  N_UDCMStudyCI       = $59;
//  N_UDCMPatientCI     = $59;
//  N_UDCSMProviderCI   = $5A;
//  N_UDCSMLocationCI   = $5B;

  N_UDQuery1CI        = $71;
  N_UDQuery2CI        = $72;
  N_UDIteratorCI      = $73;
  N_UDCreatorCI       = $74;

  N_UDNonLinConvCI    = $76;
  N_UDDynPictCreatorCI= $77;
//  N_UDFileCodecCI     = $78;
  N_UDCalcUParamsCI   = $79;

  N_UDNLegendCI       = $81;
//  N_UDTextRowCI       = $82;
  N_UDPanelCI         = $83;
  N_UDTextBoxCI       = $84;
  N_UDLegendCI        = $85;
  N_UDMapLayerCI      = $86;
  N_UDPictureCI       = $87;
  N_UDDIBCI           = $88;
  N_UDParaBoxCI       = $89;
  N_UDFileCI          = $8A;
  N_UDDIBRectCI       = $8B;

  N_UDSArrowCI        = $8D;
  N_UD2DSpaceCI       = $8E;
  N_UDAxisTicsCI      = $8F;
  N_UDTextMarksCI     = $90;
  N_UDAutoAxisCI      = $91;
  N_UD2DFuncCI        = $92;
  N_UDIsoLinesCI      = $93;
  N_UD2DLinHistCI     = $94;
  N_UDPieChartCI      = $95;
  N_UDTableCI         = $96;
  N_UDLinHistAuto1CI  = $97;
  N_UDCompsGridCI     = $98;

  N_UDActionCI        = $9A;
  N_UDTextFragmCI     = $9B;
  N_UDOLEServerCI     = $9C;

  N_UDWordFragmCI     = $A0;
  N_UDExcelFragmCI    = $A1;
  N_UDExpCompCI       = $A2;
  // end of N_(2) ************************************* $050 - $0AF


  // K_(2) ************************************* $0B0 - $0DB
  K_UDMVWVTreeWinCI    = $B0;
  K_UDMVVectorCI       = $B1;
  K_UDProgramItemCI    = $B2;
  K_UDFieldsDescrCI    = $B3;
  K_UDRArrayCI         = $B4;
  K_UDDCSpaceCI        = $B5;
  K_UDDCSSpaceCI       = $B6;
  K_UDVectorCI         = $B7;
  K_UDMVFolderCI       = $B8;
  K_UDUnitDataCI       = $B9;
  K_UDSSTableCI        = $BA;
  K_UDMVTableCI        = $BB;
  K_UDMVWFolderCI      = $BC;
  K_UDMVWLDiagramWinCI = $BD;
  K_UDMVWTableWinCI    = $BE;
  K_UDMVWWinGroupCI    = $BF;
  K_UDMVVWLayoutCI     = $C0;
  K_UDMVVWindowCI      = $C1;
  K_UDMVVWFrameCI      = $C2;
  K_UDMVVWFrameSetCI   = $C3;
  K_UDMVWHTMWinCI      = $C4;
  K_UDMVWVHTMWinCI     = $C5;
  K_UDMVMapDescrCI     = $C6;
  K_UDMVMLDColorFillCI = $C7;
  K_UDMVWCartWinCI     = $C8;
  K_UDMVWCartGroupWinCI= $C9;
  K_UDMVWCartLayerCI   = $CA;
  K_UDMVWSiteCI        = $CB;
  K_UDRPTabCI          = $CC;
  K_UDMVCorPictCI      = $CD;
  // end of K_(2) ************************************* $0B0 - $0DB

// N_ClassRefArrayMaxInd = $DB; // $DB = 219

implementation

end.
