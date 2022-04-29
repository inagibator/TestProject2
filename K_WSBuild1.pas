unit K_WSBuild1;

interface
uses SysUtils, Classes, inifiles, Contnrs,
  K_Script1, K_IMVDAR, K_DCSpace, K_MVObjs, K_MVMap0, K_UDT1, K_UDT2,
  K_CLib0, K_CLib, K_Types,
  N_GCont, N_CompBase, N_Types, N_UDCMap, N_Rast1Fr, N_SGComp;

type TK_MVDataOrderFlags = set of ( K_dofDescendingOrder, K_dofAscendingOrder );

type TK_MVLDiagramAndTableBuilder0 = class //*** MV Line Diagram Builder Base (Super) Class
  OrderFlags  : TK_MVDataOrderFlags;
  OrderColInd : Integer;
  UDVNames : TK_UDVector;
  RAAttrs   : TList;
  destructor Destroy; override;
  procedure Init;
  procedure AddVectorAndAttributes( BriefCapt : string; AUDVector: TN_UDBase;
                                    AUDAttrs: TN_UDBase ); overload;
  procedure AddVectorAndAttributes( BriefCapt : string; AUDVector: TN_UDBase;
                                    ARAAttrs: TK_RArray ); overload;
  procedure SetUDComponentParams( ColorSchemeInd : Integer = -1;
                                  ColorSchemes : TK_RArray = nil;
                                  SkipRebuildFlag : Boolean = false;
                                  PVInds : PInteger = nil; AVCount : Integer = 0;
                                  PRInds : PInteger = nil; ARCount : Integer = 0 ); virtual; abstract;
    private

  UDVectors : TStringList;
end; //*** end of type TK_MVLDiagramAndTableBuilder0  = class


type TK_MVLDiagramAndTableBuilder1  = class (TK_MVLDiagramAndTableBuilder0) //*** MV Line MultiColumn Diagram Builder
// CS Context
  TicksCSS : TK_UDDCSSpace; // Rows with StyleInd=1, TicksCSS[0] - row ind which value use for FunckTicks[0]
  CRefCSS : TK_UDDCSSpace; // Rows with StyleInd=2
  Sel2CSS : TK_UDDCSSpace; // Rows with StyleInd=3
  Sel3CSS : TK_UDDCSSpace;
  procedure SetCSContext(  Selected1CSS, Selected2CSS, Selected3CSS : TK_UDDCSSpace;
              CSCaptions : TK_UDVector; CrossRefCSS : TK_UDDCSSpace );
  procedure PrepUDComponentContext( AUDComp : TN_UDCompBase;
                           const ACompCaption, ACompLegCaption : string );
  procedure SetUDComponentParams( ColorSchemeInd : Integer = -1;
                                  AColorSchemes : TK_RArray = nil;
                                  SkipRebuildFlag : Boolean = false;
                                  PVInds : PInteger = nil; AVCount : Integer = 0;
                                  PRInds : PInteger = nil; ARCount : Integer = 0 ); override;

    private

// Component UserParams RArrays
  UDCompParams : TN_UDCompBase;
  TabValues, ValTexts, Colors,
  LHColNames, LHRowNames, LHRowNums, LHRowDVals, CRRowNames, CRRowNums,
  FuncsTicks, FuncsBase, FuncsMin, FuncsMax,
  ValStyleInds, RowStyleInds,
  UseColors, AxisTickSteps10, AxisTickSteps5, AxisTickSteps1, AxisMarkTexts,
  AxisTickFormats, SkipCrosRefs : TK_RArray;

end; //*** end of type TK_MVLDiagramAndTableBuilder1  = class

type TK_MVDataChartFlags = Set of (
         K_dcfGroupByRows,    // = "Группировка по строкам",
         K_dcfNormGroups,     // = "Нормирование данных групп",
         K_dcfViewAllCols,    // = "Отображение всех столбцов",
         K_dcfGroupOrder,     // = "Упорядочение элементов групп",   (Для не матричного расположения столбиков)
         K_dcfUseTabColors,   // = "Использовать цветов таблицы",    // если стоит этот флаг, то следующие флаги не используются
         K_dcfDifColorsForGroups// = "Различные цвета для групп"
//         K_dcfDifColorsForGElems // = "Различные цвета для элементов"
          );

type TK_MVLDiagramBuilder2  = class (TK_MVLDiagramAndTableBuilder0) //*** MV Line Diagram Builder For SubMatrix Diagram
// CS Context
  DataChartFlags : TK_MVDataChartFlags;
  FuncTickCSInd : Integer;
  BarColors : TN_IArray;
  constructor Create;
  procedure SetBarColors( PColors : PInteger; Count : Integer );
  procedure PrepUDComponentContext( AUDComp : TN_UDCompBase; CompCaption : string );
  procedure SetUDComponentParams( ColorSchemeInd : Integer = -1;
                                  ColorSchemes : TK_RArray = nil;
                                  SkipRebuildFlag : Boolean = false;
                                  PVInds : PInteger = nil; AVCount : Integer = 0;
                                  PRInds : PInteger = nil; ARCount : Integer = 0 ); override;

    private

// Component UserParams RArrays
  TabValues, ValTexts, Colors,
  LHColNames, LHRowNames, LHRowNums,
  ValStyleInds, FuncsBase, FuncsMin, FuncsMax : TK_RArray;
  FuncsTicks, LegNames, LegColors : TK_RArray;
end; //*** end of type TK_MVLDiagramBuilder2  = class

//************************************************ TK_PrepMCHistCompContext
// Prepare MultiColumn Histogram Component Context
type TK_PrepMCHistCompContext = class(TK_PrepCompContext)
  CCPColorSchemes : TK_RArray;
  CCPUDComp : TN_UDCompBase;
  CCPUDCompPars : TN_UDCompBase;
  CCPCompCaption : string;
  CCPCompLegend : string;
  CCPLDTBuilder : TK_MVLDiagramAndTableBuilder0;
  constructor Create;
  destructor Destroy; override;
  procedure SetContext(); override;
  procedure BuildSelfAttrs(); override;
end;

type TK_MVBarChartFlags = Set of (
         K_bcfBarVertical,   // = "Вертикальная ориентация столбиков",
         K_bcfOrtBarGroupDir,// = "Расположение групп ортогонально столбикам",
         K_bcfC2Chart,       // = "Сравнительная диаграмма", (Для случая двух групп)
         K_bcfStackedChart,  // = "Составная диаграмма"
         K_bcfSkipHeader,    // = "Скрыть заголовок",
         K_bcfSkipGroupCapts,// = "Скрыть названия групп",
         K_bcfSkipElemmCapts,// = "Скрыть названия элементов",
         K_bcfSkipLegend,    // = "Скрыть легенду",
         K_bcfSkipFuncTicks  // = "Скрыть метки"
          );

//************************************************ TK_PrepSMCHistCompContext
// Prepare Selected MultiColumn (SubMatrix) Histogram Component Context
type TK_PrepSMCHistCompContext = class(TK_PrepMCHistCompContext)
  CCPColInds : TN_IArray;
  CCPRowInds : TN_IArray;
  CCPBarChartFlags : TK_MVBarChartFlags;
  CCPElemCaptsWidth : Float;
  CCPElemValsWidth : Float;
  constructor Create;
  procedure SetContext(); override;
end;


//************************************************ TK_CorPictRFA
// CorPict Show Hint Action
//
type TK_CorPictRFA = class( TN_RFrameAction ) // Edit 3 Rects RFrame Action
  CLObj: TN_UDBase; // Current Layer Object
  CIInd: Integer;   // Current Layer Item Index

  procedure SetActParams (); override;
  procedure Execute      (); override;
  procedure RedrawAction (); override;
end; // type TK_CorPictRFA = class( TN_RFrameAction )

//************************************************ TK_PrepCorPictCompContext
// Prepare CorPict Component Context
//
type TK_PrepCorPictCompContext = class(TK_PrepCompContext)
  CCPUDComp    : TN_UDCompBase; // CorPict Root Component
  CCPUDGComp   : TN_UDBase;     // CorPict Graphic Component
  CCPUD2DComp   : TN_UDBase;    // CorPict 2DSpace Component
  CCPUDMComp   : TN_UDBase;     // CorPict Map Root Component
  CCPUDGCompLP : string;        // CorPict Graphic Component Local Path
  CCPUDCurHComp: TN_UDCompBase; // CorPict Current Header Component
  CCPUDHComp   : TN_UDBase;     // CorPict Header Component
  CCPUDAHComp  : TN_UDBase;     // CorPict Above Header Component
  CCPUDCompPat : TN_UDCompBase; // CorPict Pattern Root Component
  CCPUDGCompPat: TN_UDBase;     // CorPict Pattern Graphic Component
  CCPUDParams  : TN_UDCompBase; // CorPict Params Object
  CCPUDSPTBPat : TN_UDBase;     // CorPict Single Point Caption Pattern Component
  CCPUDMPTBPat : TN_UDBase;     // CorPict Multi Points Caption Pattern Component
  CCPUDDiagCComp : TN_UDBase;   // CorPict Diag CObj Comp
// obsolete
//  CCPUDMHAComp : TN_UDBase;     // CorPict Map Root Hoisontal Axis Component
//  CCPUDMRCompLP: string;        // CorPict Map Root Component Local Path
//  CCPUDDiag0Comp: TN_UDBase;     // CorPict Main Diagonal Line
//  CCPGraphTop   : Double;        // Graph component top position
//  CCPPatHeaderHeight : Double;   // Pattern Header Height - Graph Additional Gap
// end of obsolete

  CCPUDSigns    : TN_UDBase;     // Folder with signs layers patterns
  CCPUDLabels   : TN_UDBase;     // Folder with labels layers patterns
  CCPCorPictRA  : TK_RArray;     // Reference to CorPict RArray or self copy of it
  CCPHeaderHeight : Double;      // Header component Height
  CCPHeaderWidth  : Double;      // Header component Width
  CCPMaxSizeMin : Double;        // Component MaxSize mm Min
  CCPMaxSizeMax : Double;        // Component MaxSize mm Max
  CCSpreadPointStep : Double;    // Spread Point step
  CCSGMLP : TN_SGMLayers;        // Search Points objects Context
  CCSGMLL : TN_SGMLayers;        // Search TextBox objects Context
  CCEdRFA : TN_EditCompsRFA;     // Edit TextBox Actions
  OnSetContext : TK_NotifyProc;  // Call after picture context was rebuild
  CCRecalFlagGraphPos : Boolean; // Recalc Graph Component position
  destructor Destroy; override;
  procedure SetContext(); override;
  procedure BuildSelfAttrs(); override;
  procedure CCEdRFADblClickProcObj( ARFAction: TObject );

    private
  DX, DY : TN_DArray; // Current Layers Coordinates Array
  SA : TN_ASArray; // Array of Hint Texts Arrays for Picture Layers
//procedure SpreadCoincidentPoints();
  function  CompPointCoords( Ptr1, Ptr2: Pointer ): Integer;

end;

//************************************************
// Prepare CorPict Representation Legend Component Context
type TK_PrepCorPictLegCompContext = class(TK_PrepCompContext)
  CCPUDLegComp     : TN_UDCompBase; // CorPict Leg Root Component
  CCPUDLegMCompPat : TN_UDBase;     // CorPict Leg Map Root Pattern Component
//  CCPUDLegHCompPat  : TN_UDBase;     // CorPict Leg Header Pattern Component
  CCPUDSigns  : TN_UDBase;     // folder with signs layers patterns
  CCPUDLabels : TN_UDBase;     // folder with labels layers patterns
  CCPUDPlaneComp    : TN_UDBase; // CorPict Leg Plane Root Component
  CCPUDPlaneXANCompLP : string; // CorPict Leg Plane XAxis Name Component Local Path
  CCPUDPlaneYANCompLP : string; // CorPict Leg Plane YAxis Name Component Local Path
  CCPUDPlaneMRCompLP  : string; // CorPict Leg Plane Map Root Component Local Path

  CCPLegEStep  : Double;        // Legend Step
  CCPLegFontHeight: Double;     // Legend Font Size
  CCPCorPictRA : TK_RArray;       // Reference to MVCorPict RArray or self copy of it

  destructor Destroy; override;
  procedure SetContext(); override;
  procedure BuildSelfAttrs(); override;
end;

type TK_WebSitePackMode = ( //*** Web Site File Pack Mode Type
         K_wspNoPack,  // No Pack Archives and Libraries
         K_wspAllPack, // Pack All Files
         K_wspIfNeeded // Pack if packed file size is smaller then unpacked
         );

type TK_JSObj = record
  JSID : string;      // Self JS Identifier
  ADN : string;       // Self Descriptor Archive Identifier
  AVN : string;       // Self Border Archive Identifier
  ASN : TStringList;  // Self String Archives List
  NOL : TList;        // Needed Objects List
end; //*** end of type TK_JSObj = record
TK_PJSObj = ^TK_JSObj;

type TK_MVJSObj = record
  UDB   : TN_UDBase;
  JSBID : string; // JS Base ID - for all linked objects
//  ACI : string;   // Self Caption Index in AC
  Rebuild : Boolean; // rebuild
  JSO : array [0..3] of TK_JSObj;
end; //*** end of type TK_JSObj = record
TK_PMVJSObj = ^TK_MVJSObj;

type TK_JSArchsGroup = record
  ArchsList : TStrings;
  ArchPref : string;
  CArchJSID : string;
  CArchInd : Integer;
  CArch : TStringList;
end; //*** end of type TK_JSArchsGroup = record
TK_PJSArchsGroup = ^TK_JSArchsGroup;


type TK_WebSiteBuilder1  = class //*** Web Site Builder
//*** Ini Build Context
  JSPatDir   : string;
  JSLibDir   : string;
  JSImgDir   : string;
  SrcMapsDir : string;
  SiteArchsPath : string;
  UnixSiteArchsPath : string;
  SiteTextsPath : string;
  SiteImgPath   : string;
  SiteRPath     : string;
  SiteCurRPath  : string;
  RootPath      : string;
  VTreeVWin     : string;


  FEncodeMode   : TK_FileEncodeMode;
  FSkipSiteLoadProgress : Boolean;
  FSetCharsetInfo : Boolean;

  FSaveDCSCodes : Boolean;

  SiteBase  : string;
  ImgBase   : string;
  ArchsBase : string;
  MapBase   : string;
  HTMBase   : string;

  PatMacro, PML, PL, WL, SL, ML, AllArchs, SArchs : TStringList;
  ArchivesList : TStringList;
  HTMFilesList : TStringList;
  StartArchivesList : TStringList;

  ErrCount : Integer;

//  OnShowDump : procedure ( DumpLine : string; ShowMessage : Boolean = true ) of object;
  OnShowDump : TK_MVShowMessageProc;
  ShowDetails      : Boolean; // Show Details (Info Dump)
  RebuildLibraries : Boolean; // Unconditional Libraries Rebuild


  constructor Create( AEncodeMode : TK_FileEncodeMode = K_femW1251;
                      ASetCharsetInfo  : Boolean = false;
                      ASkipSiteLoadProgress : Boolean = false);
  destructor  Destroy; override;
  function  BuildSite(ARootPath: string;
              ARootUDObj, StartWWObj, UDWLayout : TN_UDBase;
              AVWinName : string = '';
              PageTitle : string = '';
              WSPMode : TK_WebSitePackMode = K_wspIfNeeded ) : Integer;
  function  BuildJSArchives( StartWWObj, UDWLayout : TN_UDBase;
                             AVWinName : string ) : string;
  procedure CopyMapFile( MapFName: string );
  function  BuildDestFileName( SrcFName: string  ) : string;
  procedure CopyExtHTMFile( SrcFName: string; DestFName: string; SiteLocalPath : string = '' );
  procedure BuildWObjJSID( WSObj : TN_UDBase;
               AObjDefID : string = '' );
  function  AddWObjToArchive( WSObj : TN_UDBase;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID : string = '';
               StartWWinObj : TN_UDBase = nil ) : Integer;
  function  AddWLDiagramToArchive( UDMVWLDiagram : TK_UDMVWLDiagramWin;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID : string = '' ) : Integer;
  function  AddWTableToArchive( UDMVWTable : TK_UDMVWTableWin;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID : string = '' ) : Integer;
  function  AddWCartToArchive( UDMVWCart : TK_UDMVWCartWin;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID : string = '' ) : Integer;
  function  AddWCartGroupToArchive( UDMVWCartGroup : TK_UDMVWCartGroupWin;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID : string = '' ) : Integer;
  function  AddWWinGroupToArchive( UDMVWWinGroup : TK_UDMVWWinGroup;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID : string = '' ) : Integer;
  function  AddWVTreeToArchive( UDMVWVTreeWin : TK_UDMVWVTreeWin;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID : string = '';
               StartWWinObj : TN_UDBase = nil ) : Integer;
  function  AddWHTMRefToArchive( WSObj : TN_UDBase;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID : string = '' ) : Integer;
  function  AddWVHTMRefToArchive(WSObj: TN_UDBase;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID: string): Integer;
  function  AddMVTVectorToArchive0( UDV : TN_UDBase;
                                    DefJSID : string ) : Integer;
  function  AddMVTVectorToArchive( UDMVTable : TK_UDMVTable;
                                   Ind : Integer; DefJSID : string ) : Integer;
  function  AddMVTVectorAttrsToArchive0( UDAttrs : TK_UDRArray;
                                         DefJSID : string ) : Integer;
  function  AddMVTVectorAttrsToArchive( UDMVTable : TK_UDMVTable; Ind : Integer;
                            DefJSID : string ) : Integer;
  function  AddDCSToArchive( UDCS : TK_UDDCSpace; AddAliase : Boolean  ) : Integer;
  function  AddDCSSToArchive( UDCSS : TK_UDDCSSpace; AddCSAliase : Boolean ) : Integer;
  function  AddProjToArchive( UDP : TK_UDVector  ) : Integer;
  function  AddDVSToArchive( UDV : TK_UDVector; UnConditionalAdd : boolean; Values : string = '' ) : Integer;
  function  AddUDColorsToArchive( UDColors : TN_UDBase ) : Integer;
  function  AddSValuesToArchive( UDSValues : TN_UDBase ) : Integer;
  function  AddMapToArchive( UDMVMapDescr :  TK_UDMVMapDescr ) : Integer;

  procedure ShowDump( ADumpLine : string; MesStatus : TK_MesStatus;
                      CountWarnings : Boolean= false );
  function  ArchStrKBSize( ArchSize : Integer ) : string;
  procedure DataArchDescr( ArcInd : Integer; NeededArchs : string = '' );
  procedure StringsPackedAndSave( WWL : TStrings; ArchPath : string;
                               WSPMode : TK_WebSitePackMode );
  function  AddArchive( PJSArchsGroup : TK_PJSArchsGroup ) : TStrings;
  function  SetCurArchive( PJSArchsGroup : TK_PJSArchsGroup; CID : string ) : TStringList;
  procedure AddStringsToArchive( DArchInd : Integer );
  function  AddComText( str : string; DefJSInd : Integer; var ASN : TStringList ) : string;
  procedure AddToNOL(  var ListJSObj, AddJSObj : TK_JSObj );
  function  AddVObject( CUD : TN_UDBase; ArchJSID : string; {DefStrArcInd : Integer;}
              var Ind : Integer; UnConditionalAdd : Boolean = false ) : Boolean;
  function  BuildArchivesList( PJSObj : TK_PJSObj ) : string;
  function  NewJSName( Name : string ) : string;
  function  BuildJSID( CUD : TN_UDBase; ObjDefID : string ) : string;
  procedure BuildWSLs( PWSL : Pointer = nil; PWSL1 : Pointer = nil; PWSL2 : Pointer = nil );
  function  CheckUDMVWObjVWName( UDMVWinObj : TK_UDMVWBase ) : Boolean;
  function  CheckVWName( VWinName, AddStr : string ) : Boolean;
  procedure GetDataArchive( var DArch : TStringList; var DArchID : string;
                            var DArchInd : Integer );
//  function  CreateWSDocument( RootNode  : TN_UDBase; Title : string;
//                           PMVMSWDIAttrs : TK_PMVMSWDIAttrs;
//                           CMSWDPars : TObject ) : Integer;

private
  DumpLine : string;
//  F: TSearchRec;
  VFS : TK_VFileSearchRec;
  RootUDObj : TN_UDBase;

//********************
// BuildJSArchives Context
//********************
  JSObjsFillInd : Integer;
  JSObjs : array of TK_MVJSObj;
  ListOfLists : TList;
  ComTextsList : TStringList;
//  UDPar : TN_UDBase;
  WSL : TStrings;
  WSL1 : TStrings;
  WSL2 : TStrings;
  JSObjNamesList : TStrings;
  VWList : TStrings;
  VWListF: TStrings;
  DArchs: TK_JSArchsGroup;
  CSArchs : TK_JSArchsGroup;
  MArchs : TK_JSArchsGroup;

//  WClasterFNamesList : TStringList;
  WSLWWGroup : TStringList;

  CurMapInd : Integer;      // Map Unique Name Index
  CurDCSInd : Integer;      // DCS Unique Name Index
  CurDCSSInd : Integer;     // DCSS Unique Name Index
  CurSVInd : Integer;       // Special Values Uniq Name Index
  CurColorsInd : Integer;   // ColorScale Unique Name Index
  CurDVInd : Integer;       // DataVectors (Colors,Prompts) Unique Name Index
//  CurWTInd : Integer;       // WebTable  Unique Name Index
//  CurWLDInd : Integer;      // WebLineDiagram  Unique Name Index
  CurHTMInd : Integer;      // HTM Info Data  Unique Name Index
//  IndHistAttrsList : THashedStringList;
//  IndHistAttrs : array of TK_IndHistAttrs;
//  HistAttrsInd : Integer;


public
  property EncodeMode: TK_FileEncodeMode read FEncodeMode write FEncodeMode;
  property SkipSiteLoadProgress  : Boolean read FSkipSiteLoadProgress write FSkipSiteLoadProgress;
  property SetCharsetInfo  : Boolean read FSetCharsetInfo write FSetCharsetInfo;

end; //*** end of type TK_WebSiteBuilder1  = class

type TK_MSWDocBuilder  = class //*** MS Word Document Builder
  OnShowDump : TK_MVShowMessageProc;
  BreakDocCreation : Boolean;
  CountWarnings : Boolean;
  ColorSchemeInd : Integer;
  ColorSchemes : TK_RArray;

//  constructor Create;
//  destructor  Destroy; override;

//*** MS Word Document Creation Routines
  function  CreateWSDocument1( RootNode  : TN_UDBase; Title : string;
                           const AResDocFName : string;
                           APMVMSWDVAttrs : TK_PMVMSWDVAttrs;
                           ASTopicNumber : Integer ) : Integer;

    private
  ErrCount : Integer;

  procedure ShowDump( ADumpLine : string; MesStatus : TK_MesStatus );

end; //*** end of type TK_WebSiteBuilder1  = class

implementation

uses
  Math, HTTPApp, Forms,
  K_VFunc, K_UDConst, K_Arch, K_IndGlobal, K_FEText, K_Parse,
  N_CompCL, N_ClassRef, N_Lib0, N_Lib1, N_Lib2, N_Comp2, N_Comp3, N_UDat4,
  N_Comp1, N_Gra0, N_Gra1;

const
  FolderCreationErr = 'Не удалоь создать ';
  WarnPrefix = 'ПРЕДУПРЕЖДЕНИЕ: ';

const
  TVTreeJSIDPref = 'TVTree_';
  TVGJSIDPref = 'TVG_';
  TVCJSIDPref = 'TVC_';
  TVTJSIDPref = 'TVT_';
  TVHJSIDPref = 'TVH_';
  TVHTMJSIDPref = 'TVHTM_';
  TVGMJSIDPref = 'TVGM_';
  TVMJSIDPref = 'TVM_';
  TVMAPJSIDPref = 'TMAP_';
  TVDJSIDPref = 'TVD_';
  TVAJSIDPref = 'TVA_';
  TSVAJSIDPref = 'TSVA_';
  TColorsJSPathPref = 'ASC.';
  TColorsJSIDPref = 'CC_';
  TVGComJSIDInd = Length(TVGJSIDPref)+1;
  TVGroupCaptWindow = 'FCapt';
  TVGroupGMapsWindow = 'FGMap';
  TVGroupMapWindow = 'FMap';
  TVGroupTabWindow = 'FTab';
  TVGroupHistWindow = 'FHist';
  DArchJSPref = 'AD';
  CArchJSPref = 'AC';
  MArchJSPref = 'AM';
  TCSJSPref = 'CS_';
  TCSSJSPref = 'CSS_';
  TVHTMStubName = TVCJSIDPref+'0';

{*** TK_MVLDiagramAndTableBuilder0 ***}

//**************************** TK_MVLDiagramAndTableBuilder0.PrepUDComponentContext
// Get Componenet Params
//
destructor TK_MVLDiagramAndTableBuilder0.Destroy;
var i : Integer;
begin
  UDVectors.Free;
  if RAAttrs <> nil then
    for i := 0 to RAAttrs.Count - 1 do
      TK_RArray(RAAttrs[i]).ARelease;
  RAAttrs.Free;
  inherited;

end; // end of procedure TK_MVLDiagramAndTableBuilder0.PrepUDComponentContext

//**************************** TK_MVLDiagramAndTableBuilder0.Init
// Get Componenet Params
//
procedure TK_MVLDiagramAndTableBuilder0.Init;
begin
  if UDVectors = nil then begin
    UDVectors := TStringList.Create;
    RAAttrs := TList.Create;
  end else begin
    UDVectors.Clear;
    RAAttrs.Clear;
  end;
end; // end of procedure TK_MVLDiagramAndTableBuilder0.Init

//**************************** TK_MVLDiagramAndTableBuilder0.AddVectorAndAttributes
// Add UDVector and UDVAttributes
//
procedure TK_MVLDiagramAndTableBuilder0.AddVectorAndAttributes( BriefCapt : string;
                             AUDVector: TN_UDBase; AUDAttrs: TN_UDBase);
begin
  AddVectorAndAttributes( BriefCapt, AUDVector, TK_UDRArray(AUDAttrs).R.AAddRef );
end; // end of procedure TK_MVLDiagramAndTableBuilder0.AddVectorAndAttributes

//**************************** TK_MVLDiagramAndTableBuilder0.AddVectorAndAttributes
// Add UDVector and UDVAttributes
//
procedure TK_MVLDiagramAndTableBuilder0.AddVectorAndAttributes( BriefCapt : string;
                             AUDVector: TN_UDBase; ARAAttrs: TK_RArray);
begin
  if UDVectors = nil then begin
    UDVectors := TStringList.Create;
    RAAttrs := TList.Create;
  end;
  UDVectors.AddObject( BriefCapt, AUDVector );
  RAAttrs.Add( ARAAttrs );
end; // end of procedure TK_MVLDiagramAndTableBuilder0.AddVectorAndAttributes

{*** end of TK_MVLDiagramAndTableBuilder0 ***}

{*** TK_MVLDiagramAndTableBuilder1 ***}

//**************************** TK_MVLDiagramAndTableBuilder1.SetCSContext
// Set Code Space Context
//
procedure TK_MVLDiagramAndTableBuilder1.SetCSContext(  Selected1CSS,
              Selected2CSS, Selected3CSS : TK_UDDCSSpace;
              CSCaptions : TK_UDVector; CrossRefCSS : TK_UDDCSSpace );
begin
  TicksCSS := Selected1CSS;
  CRefCSS := CrossRefCSS;
  Sel2CSS := Selected2CSS;
  Sel3CSS := Selected3CSS;
  UDVNames := CSCaptions;
end; // end of procedure TK_MVLDiagramAndTableBuilder1.SetCSContext

//**************************** TK_MVLDiagramAndTableBuilder1.PrepUDComponentContext
// Get Componenet Params
//
procedure TK_MVLDiagramAndTableBuilder1.PrepUDComponentContext(
                           AUDComp : TN_UDCompBase;
                           const ACompCaption, ACompLegCaption : string );
begin
    // Get WTable And WDiagram Params
  UDCompParams := AUDComp;
  with UDCompParams do begin
    LHColNames   := GetSUserParRArray( 'LHColNames' );
    TabValues    := GetSUserParRArray( 'Values' );
    Colors       := GetSUserParRArray( 'Colors' );
    LHRowNames   := GetSUserParRArray( 'RowNames' );
    if LHRowNames = nil then
      LHRowNames := GetSUserParRArray( 'LHRowNames' );
    LHRowNums    := GetSUserParRArray( 'LHRowNums' );
    LHRowDVals   := GetSUserParRArray( 'LHRowDVals' );
    CRRowNames   := GetSUserParRArray( 'CRRowNames' );
    CRRowNums    := GetSUserParRArray( 'CRRowNums' );
    FuncsMin     := GetSUserParRArray( 'FuncsMin' );
    FuncsMax     := GetSUserParRArray( 'FuncsMax' );
    FuncsBase    := GetSUserParRArray( 'FuncsBase' );
    FuncsTicks   := GetSUserParRArray( 'FuncsTicks' );
    ValTexts     := GetSUserParRArray( 'ValTexts' );
    ValStyleInds := GetSUserParRArray( 'ValStyleInds' );
    RowStyleInds := GetSUserParRArray( 'RowStyleInds' );
    UseColors    := GetSUserParRArray( 'UseColors' );
    AxisTickSteps10 := GetSUserParRArray( 'AxisTickStep10' );
    AxisTickSteps5  := GetSUserParRArray( 'AxisTickStep5' );
    AxisTickSteps1  := GetSUserParRArray( 'AxisTickStep1' );
    AxisMarkTexts   := GetSUserParRArray( 'AxisMarkText' );
    AxisTickFormats := GetSUserParRArray( 'AxisTickFormat' );
    SkipCrosRefs    := GetSUserParRArray( 'SkipCrosRefs' );
  end;
  AUDComp.SetSUserParStr( 'HeaderText',  ACompCaption );
  if ACompLegCaption <> '' then
    AUDComp.SetSUserParStr( 'Header1_3',  ACompLegCaption );
end; // end of procedure TK_MVLDiagramAndTableBuilder1.PrepUDComponentContext

//**************************** TK_MVLDiagramAndTableBuilder1.SetTableSubMatrixParams
// WSDocument Set WTable or WDiagram SubMatrix Params
//
procedure TK_MVLDiagramAndTableBuilder1.SetUDComponentParams(
                                  ColorSchemeInd : Integer = -1; AColorSchemes : TK_RArray = nil;
                                  SkipRebuildFlag : Boolean = false;
                                  PVInds : PInteger = nil; AVCount : Integer = 0;
                                  PRInds : PInteger = nil; ARCount : Integer = 0 );
var
  ri, ci  : Integer;
  CSCount : Integer;
  PMVVAttrs : TK_PMVVAttrs;
  PMVVector : TK_PMVVector;
  DPInds  : TN_IArray;
  CurVal : Double;
  CInd : Integer;
  CColor : Integer;
  ScaleHigh : Integer;
  ScaleInd : Integer;
  PScale : Pointer;
  nn, ik : Integer;
  SortInds : TN_IArray;  // Data Vector Sort Inds
  SortNInds : TN_IArray; // Row Names Vector Sort Inds
  FullNInds : TN_IArray;
  TicksVInds : TN_IArray;
  WRowStyleInds : TN_BArray;
  SortedData : TN_DArray;
  RatingFlags : TN_BArray;
  RatingI1, RatingI2 : Integer;
  RatingVal : string;

  TicksDataProjReady : Boolean;
  V2Const : Byte;
  SVA : TK_SpecValsAssistant;
  SVInd : Integer;
  ValStyleInd : Byte;
  ValText : String;
  VCSS : TK_UDDCSSpace;
  nc, nr, nt : Integer;
  CS : TK_UDDCSpace;
  VInd : Integer;
  TickSortInd : Integer;
  DynColHeader : string;
  WValStyleInds : TN_BArray;

  UsedRI : Integer;
  SkipSpecValBars : Boolean;

  GroupRegCSInds : TN_IArray;

begin

  SortInds := nil;
  SortNInds := nil;

  VInd := 0;
  if (PVInds = nil) or (AVCount = 0) then begin
    nc := RAAttrs.Count;
    PVInds := nil;
  end else begin
    nc := AVCount;
    if PVInds <> nil then VInd := PVInds^;
  end;

  if LHColNames <> nil then
    LHColNames.ASetLength( nc );
  if FuncsMin <> nil then
    FuncsMin.ASetLength( nc );
  if FuncsBase <> nil then
    FuncsBase.ASetLength( nc );
  if FuncsMax <> nil then
    FuncsMax.ASetLength( nc );
  if FuncsTicks <> nil then
    FuncsTicks.ASetLength( nc );

  if AxisTickSteps10 <> nil then
    AxisTickSteps10.ASetLength( nc );
  if AxisTickSteps5 <> nil then
    AxisTickSteps5.ASetLength( nc );
  if AxisTickSteps1 <> nil then
    AxisTickSteps1.ASetLength( nc );
  if AxisMarkTexts <> nil then
    AxisMarkTexts.ASetLength( nc );
  if AxisTickFormats <> nil then
    AxisTickFormats.ASetLength( nc );

  nr := 0;
  nt := 0;
  VCSS := nil;
  TicksVInds := nil;
  WRowStyleInds := nil;
  RatingFlags := nil;

  if nc > 0 then
    with TK_PMVVector(TK_UDVector(UDVectors.Objects[VInd]).R.P)^ do
    begin
      VCSS := TK_UDDCSSpace(CSS);
      CS := VCSS.GetDCSpace;
      CSCount := CS.SelfCount;

      if (PRInds = nil) or (ARCount = 0) then begin
        nr := D.ALength;
        PRInds := nil;
      end else
        nr := ARCount;

      SetLength( SortInds, nr ); // Sorted Indexes of Elements in CSS
      if PRInds = nil then begin
        PRInds := @SortInds[0];
        K_FillIntArrayByCounter( PRInds, nr );
      end;

   // Build Order Indices
      if (K_dofDescendingOrder in OrderFlags) or
         (K_dofAscendingOrder in OrderFlags) then
      begin
        SetLength( SortedData, nr );
        K_MoveVectorBySIndex( SortedData[0], SizeOf( Double ),
                D.P^, SizeOf( Double ), SizeOf( Double ), nr, PRInds );
        SetLength( SortNInds, nr );
        K_BuildSortedDoubleInds( @SortNInds[0], @SortedData[0], nr, not (K_dofAscendingOrder in OrderFlags) );
        if PRInds <> @SortInds[0] then
          K_MoveVectorBySIndex( SortInds[0], SizeOf(Integer),
                PRInds^, SizeOf(Integer), SizeOf(Integer), nr, @SortNInds[0] )
        else
          Move( SortNInds[0], SortInds[0], SizeOf( Integer ) * nr );
      end
      else
      if PRInds <> @SortInds[0] then
        Move( PRInds^, SortInds[0], SizeOf( Integer ) * nr );

      // Build Rating Flags

      PMVVAttrs := TK_PMVVAttrs(TK_RArray(RAAttrs[VInd]).P);
      with PMVVAttrs^ do
      begin
        // Build Additional Dynamic Vector Values
        if LHRowDVals  <> nil then
        begin
          LHRowDVals.ASetLength( nr );

          if AddLHDataVector <>  nil then
            with TK_PMVVector(AddLHDataVector.P)^ do
            begin
              K_MoveSPLVectorBySIndex( LHRowDVals.P^, SizeOf(string),
                             D.P^, SizeOf(string),
                             nr, Ord(nptString), [K_mdfFreeDest],
                             @SortNInds[0] );
              DynColHeader := BriefCapt;
              if DynColHeader = '' then
                DynColHeader := FullCapt;
              UDCompParams.SetSUserParStr( 'Header1_4',  DynColHeader );
            end;
        end;

        if AutoRangeCSS <> nil then
        begin
          SetLength( RatingFlags, CSCount );
          SetLength( WRowStyleInds, nr );
          // fill RatingFlags (corresponding to CodeSpace) by 1 to elements
          // corresponding to AutoRangeCSS - (только субъекты федерации для России)
          ri := 1;
          with TK_UDDCSSpace(AutoRangeCSS), PDRA^ do
            K_MoveVectorByDIndex( RatingFlags[0], SizeOf(Byte),
                  ri, 0, SizeOf(Byte), ALength(), P() );

          // Move RatingFlags 1 to WRowStyleInds corresponding with DataVector
          with TK_UDDCSSpace(VCSS), PDRA^ do
            K_MoveVectorBySIndex( WRowStyleInds[0], SizeOf(Byte),
                  RatingFlags[0], SizeOf(Byte), SizeOf(Byte), ALength(), P() );

          if SortInds <> nil then
          begin // Fill RatingFlags by Sorted WRowStyleInds
            K_MoveVectorBySIndex( RatingFlags[0], SizeOf(Byte),
                  WRowStyleInds[0], SizeOf(Byte), SizeOf(Byte), nr, @SortInds[0] );
            SetLength( RatingFlags, nr );
          end
          else
            RatingFlags := WRowStyleInds;
          WRowStyleInds := nil;
        end;
      end;
    end // with TK_PMVVector(TK_UDVector(UDVectors.Objects[VInd]).R.P)^ do
  else  // if nc > 0 then
  begin
    CS := nil;
    CSCount := 0;
  end;

// Build UserParams Vectors and Matrix
  if TabValues <> nil then
    TabValues.ASetLength( nc, nr );

  if ValStyleInds <> nil then
    ValStyleInds.ASetLength( nc, nr );
  SetLength( WValStyleInds, nr);

  if RowStyleInds <> nil then
    RowStyleInds.ASetLength( nr );

  if ValTexts <> nil then
    ValTexts.ASetLength( nc, nr );

  if Colors <> nil then
    Colors.ASetLength( nc, nr );

// Build Func Ticks and Set StyleIndex for TicksCSS[0] element
  TicksDataProjReady := false;
  if (TicksCSS <> nil) then begin
    nt := TicksCSS.PDRA.ALength;
    if nt > 0 then begin
      SetLength( TicksVInds, nt );
      TicksDataProjReady := K_BuildDataProjectionByCSProj( VCSS, TicksCSS, @TicksVInds[0], nil ) and
                           (TicksVInds[0] >= 0);
    end;
  end;

  if (FuncsTicks <> nil) then begin
    if not TicksDataProjReady then
      FuncsTicks.ASetLength(0);
  end;

//  CS := VCSS.GetDCSpace;
//  CSCount := CS.SelfCount;
  SetLength( WRowStyleInds, CSCount );
  if nt > 0 then
    WRowStyleInds[PInteger(TicksCSS.DP)^] := 1;

// Set StyleIndex for Selected Projection elements
  if Sel2CSS <> nil then begin
    V2Const := 2;
//    K_MoveVectorByDIndex( WRowStyleInds[0], 1,
//       V2Const, 0, 1, CSCount, PInteger(SelProj.DP) );
    K_MoveVectorByDIndex( WRowStyleInds[0], 1,
       V2Const, 0, 1, Sel2CSS.PDRA.ALength, PInteger(Sel2CSS.DP) );
  end;

  if Sel3CSS <> nil then begin
    V2Const := 3;
    K_MoveVectorByDIndex( WRowStyleInds[0], 1,
       V2Const, 0, 1, Sel3CSS.PDRA.ALength, PInteger(Sel3CSS.DP) );
  end;

  // Apply Group Colors Change Info
  if (K_GroupRegDCSInd >= 0) and
     (K_GroupRegDCSProj <> nil) and
     (K_GroupRegDCSpace = CS) then
  begin

    SetLength( GroupRegCSInds, nr );
    // Set CVIndexes by Proj Data
    K_MoveVectorBySIndex( GroupRegCSInds[0], SizeOf( Integer ),
                         TK_UDVector(K_GroupRegDCSProj).DP^, SizeOf( Integer ),
                         SizeOf( Integer ), nr, VCSS.DP );

  end;

  // Move Column Values, Texts, SVFlags

  SkipSpecValBars := FALSE;
  UsedRI := nr;
  for ci := 0 to nc - 1 do
  begin
    if PVInds <> nil then
    begin
      VInd := PVInds^;
      Inc(PVInds);
    end;

    PMVVAttrs := TK_PMVVAttrs(TK_RArray(RAAttrs[VInd]).P);
    PMVVector := TK_PMVVector(TK_UDRArray(UDVectors.Objects[VInd]).R.P);
//    with TK_PMVVector(TK_UDRArray(UDVectors.Objects[VInd]).R.P)^, PMVVAttrs^ do begin
    with PMVVector^, PMVVAttrs^ do
    begin
      if AxisTickUnits = '' then // for Init Early Loaded Data
        AxisTickUnits := Units;
      if not SkipRebuildFlag then
        K_RebuildMVAttribs( PMVVAttrs^, PMVVector, ColorSchemeInd, AColorSchemes );
//        K_RebuildMVAttribs( PMVVAttrs^, D, ColorSchemeInd, AColorSchemes );
    // Set FuncsMin FuncsMax
      if FuncsMin <> nil then
        PDouble(FuncsMin.P(ci))^ := VMin;
      if FuncsMax <> nil then
        PDouble(FuncsMax.P(ci))^ := VMax;
      if FuncsBase <> nil then
        PDouble(FuncsBase.P(ci))^ := VBase;
      if AxisTickSteps10 <> nil then
        PDouble(AxisTickSteps10.P(ci))^ := AxisTickStep;
      if AxisTickSteps5 <> nil then
        PDouble(AxisTickSteps5.P(ci))^ := AxisTickStep / 2;
      if AxisTickSteps1 <> nil then
        PDouble(AxisTickSteps1.P(ci))^ := AxisTickStep / 10;
      if AxisMarkTexts <> nil then
        PString(AxisMarkTexts.P(ci))^ := AxisMarkText;
      if AxisTickFormats <> nil then
        PString(AxisTickFormats.P(ci))^ := AxisTickFormat;
{
      if AxisTickSteps5 <> nil then
        AxisTickSteps5.ASetLength( nc );
      if AxisTickSteps1 <> nil then
        AxisTickSteps1.ASetLength( nc );
      if AxisMarkTexts <> nil then
        AxisMarkTexts.ASetLength( nc );
      if AxisTickFormats <> nil then
        AxisTickFormats.ASetLength( nc );
}
      if UDVNames = nil then
        UDVNames := TK_UDVector(ElemCapts);

    // Set Column Ticks

      if TicksDataProjReady then
        PDouble(FuncsTicks.P(ci))^ := PDouble(D.P( TicksVInds[0] ))^;

    // Set Column Caption
      if LHColNames <> nil then
        PString( LHColNames.P(ci) )^ := UDVectors[VInd];

     // Prep Data Projections
      DPInds := nil;
      if CSS <> VCSS then
      begin
        SetLength( DPInds, nr );
        if not K_BuildDataProjectionByCSProj( TK_UDDCSSpace(CSS), VCSS, @DPInds[0], nil ) then
          DPInds := nil;
      end;

   // Move Values, Colors, ValTexts and ValStyleInds
      SVA := TK_SpecValsAssistant.Create( TK_UDRArray(UDSVAttrs).R );
      ScaleHigh := RangeValues.AHigh;
      PScale := RangeValues.P;
      CurVal := 0;
      CColor := 0;
      SkipSpecValBars := (nc = 1) and
      ((K_lhsSVSkipBar in LHShowFlags.T) or (K_lhsSVSkipAll in LHShowFlags.T));
      UsedRI := 0;
      for ri := 0 to nr - 1 do
      begin
        // Get Cur Data Vector Element index ()
        if SortInds = nil then
          CInd := ri
        else
          CInd := SortInds[ri];

        // Get Data element Special Value Index
        SVInd := -1;
        if DPInds <> nil then
        begin // Try to get SPValInd as Absent in data projection
          CInd := DPInds[CInd];
          if DPInds[CInd] < 0 then
            SVInd := AbsDCSESVIndex;
        end;

        if SVInd < 0 then
        begin // Try to get SPValInd by Data Special Value
          CurVal := PDouble(D.P(CInd))^;
          SVInd := SVA.IndexOfSpecVal( CurVal );
        end;

        // Select Data Color
        if SVInd >= 0 then
        begin
        // Color by Special Value Index
          ValStyleInd := 1;
          with SVA.GetSpecValAttrs(SVInd)^ do
          begin
            ValText := Caption;
            CColor := Color;
          end;
        end
        else
        begin
        // Color by Data Value
          if Colors <> nil then
          begin
{}
//            N_i := PInteger(VCSS.DP(CInd))^;
//            N_i1 := WRowStyleInds[N_i];
            if WRowStyleInds[PInteger(VCSS.DP(CInd))^] <> 0 then
            // New LinHist - use transp. Color for elements corresponds to RF and Federal Okrugs
              CColor := -1
            else
{}            
            begin
            // Select color by Scale Colors for elements corresponds not to RF and Federal Okrugs
              ScaleInd := K_IndexOfDoubleInScale( PScale, ScaleHigh, sizeof(Double), CurVal );
              if (ScaleInd > 0) and (ValueType.T = K_vdtDiscrete) then Dec(ScaleInd);
              CColor := PInteger( RangeColors.P(ScaleInd) )^;
            end;
          end;
          ValStyleInd := 0;
          if VFormat <> '' then
            ValText := format( VFormat, [CurVal])
          else
            ValText := format('%.*f', [VDPPos, CurVal]);
        end;
        WValStyleInds[ri] := ValStyleInd;
        if SkipSpecValBars and (ValStyleInd <> 0) then Continue;

        if TabValues <> nil then
          PDouble( TabValues.PME(ci,UsedRI) )^ := CurVal;

        if Colors <> nil then
          PInteger( Colors.PME(ci,UsedRI) )^ := CColor;

        if ValStyleInds <> nil then
          PByte( ValStyleInds.PME(ci,UsedRI) )^ := ValStyleInd;

        if ValTexts <> nil then
          PString( ValTexts.PME(ci,UsedRI) )^ := ValText;
        Inc(UsedRI);
      end; // for ri := 0 to nr - 1 do

      SVA.Free;
      Inc(VInd);
    end; // with PMVVector^, PMVVAttrs^ do
  end; // for ci := 0 to nc - 1 do

  if SkipSpecValBars and (UsedRI < nr) then
  begin
    if TabValues <> nil then
      TabValues.AsetLength( nc,UsedRI );

    if Colors <> nil then
      Colors.AsetLength( nc,UsedRI );

    if ValStyleInds <> nil then
      ValStyleInds.AsetLength( nc,UsedRI );

    if ValTexts <> nil then
      ValTexts.AsetLength( nc,UsedRI );
  end;

  if (nr <= 0) or (VCSS = nil) then Exit;

  //*** Set LHRowNums, LHRowNames, CRRowNums, CRRowNames
  TickSortInd := -1;
  if TicksDataProjReady then // For Remove Ticks Data from Resulting Data
    TickSortInd := K_IndexOfIntegerInRArray( TicksVInds[0], @SortInds[0], nr );

  // Build Hist Ratings
  if LHRowNums <> nil then
  begin
    LHRowNums.ASetLength( nr );
    RatingI1 := 0;
    RatingI2 := 0;
    for ri := 0 to nr - 1 do
    begin
      if (ri = TickSortInd) or (WValStyleInds[ri] <> 0) then
        RatingVal := ''
      else
      if (RatingFlags = nil) or (RatingFlags[ri] <> 0) then
      begin
        Inc(RatingI1);
        RatingVal := IntToStr(RatingI1);
      end
      else
      begin
        Inc(RatingI2);
        RatingVal := K_IntToRomanStr( RatingI2 );
      end;
      PString( LHRowNums.P(ri) )^ := RatingVal;
    end;
  end;

  SetLength( SortNInds, nr ); // Sorted Indexes of Elements in CS
  K_MoveVectorBySIndex( SortNInds[0], SizeOf(Integer),
     VCSS.DP(0)^, SizeOf(Integer), SizeOf(Integer), nr, @SortInds[0] );

  // Build RowStyleInds
  if RowStyleInds <> nil then
    K_MoveVectorBySIndex( RowStyleInds.P(0)^, 1,
       WRowStyleInds[0], 1, 1, nr, @SortNInds[0] );

  if UDVNames <> nil then
  begin  // Build RowNames and CrossRefs

    if LHRowNames <> nil then
    begin
      LHRowNames.ASetLength( nr );
      K_MoveSPLVectorBySIndex( LHRowNames.P(0)^, SizeOf(string),
         UDVNames.DP(0)^, SizeOf(string),
         nr, Ord(nptString), [K_mdfFreeDest], @SortNInds[0] );
    end;

    if (CRRowNums <> nil) and (CRRowNames <> nil) then
    begin  // Build Cross References Table
      if CRefCSS = nil then
        CRefCSS := CS.CreateDCSSpace();
      nn := CRefCSS.PDRA.ALength;
      SetLength( FullNInds, nn );
      // Build Data Projection from VCSS to CRefCSS
      if K_BuildDataProjectionByCSProj( VCSS, CRefCSS, @FullNInds[0], nil ) then
      begin
        CRRowNums.ASetLength( nn );
        CRRowNames.ASetLength( nn );
        // Build Back Indices for SortInds in SortNInds
        K_BuildFullIndex( @SortInds[0], nr, @SortNInds[0], nr, K_BuildFullBackIndexes );
        ik := 0;
        for ri := 0 to nn - 1 do
        begin
          if (FullNInds[ri] >= 0) and
             ( not TicksDataProjReady or
              (FullNInds[ri] <> TicksVInds[0]) ) then
          begin
    //        PString( CRRowNums.P(ik) )^ := IntToStr(SortNInds[FullNInds[ri]] + 1);
            PString( CRRowNums.P(ik) )^  := PString( LHRowNums.P(SortNInds[FullNInds[ri]]) )^;
            PString( CRRowNames.P(ik) )^ :=
               PString( UDVNames.DP( PInteger(VCSS.DP(FullNInds[ri]))^ ) )^;
            Inc(ik);
          end;
        end;
        CRRowNums.ASetLength( ik );
        CRRowNames.ASetLength( ik );
      end else
      begin
        CRRowNums.ASetLength( 0 );
        CRRowNames.ASetLength( 0 );
      end;
    end; // if (CRRowNums <> nil) and (CRRowNames <> nil) then

    if Length(GroupRegCSInds) > 0 then
    begin
      for ri := 0 to High(SortInds) do
      begin
        VInd := SortInds[ri];
        if (GroupRegCSInds[VInd] < 0) or
           (GroupRegCSInds[VInd] = K_GroupRegDCSInd) then Continue;
        if LHRowNames <> nil then
          PString(LHRowNames.P(ri))^ := '';
        if ValTexts <> nil then
          PString(ValTexts.P(ri))^ := '';
      end;
    end;

    if SkipCrosRefs  <> nil then
    begin
      if Length(GroupRegCSInds) > 0 then
        PByte(SkipCrosRefs.P)^ := 255
      else
        PByte(SkipCrosRefs.P)^ := 0;
    end;
  end; // if UDVNames <> nil then
end; // end of procedure TK_MVLDiagramAndTableBuilder1.SetUDComponentParams


{*** end of TK_MVLDiagramAndTableBuilder1 ***}

{*** TK_MVLDiagramBuilder2 ***}

//**************************** TK_MVLDiagramBuilder2.Create
//
constructor TK_MVLDiagramBuilder2.Create;
begin
  inherited;
  FuncTickCSInd := -1;
end; // end of TK_MVLDiagramBuilder2.Create

//**************************** TK_MVLDiagramBuilder2.PrepUDComponentContext
// Get Componenet Params
//
procedure TK_MVLDiagramBuilder2.PrepUDComponentContext(
                           AUDComp : TN_UDCompBase; CompCaption : string );
var
  DType : TK_ExprExtType;
begin
    // Get WDiagram Params
  with AUDComp do begin
    LHColNames   := GetSUserParRArray( 'LHColNames' );
    TabValues    := GetSUserParRArray( 'Values' );
    Colors       := GetSUserParRArray( 'Colors' );
    if Colors = nil then begin
      DType.All := Ord(nptColor);
      Colors := N_AddNewUserPar( R, 'Colors', '', DType, 1 ).UPValue;
    end;
    LHRowNames   := GetSUserParRArray( 'LHRowNames' );
    LHRowNums    := GetSUserParRArray( 'LHRowNums' );
    FuncsMin     := GetSUserParRArray( 'FuncsMin' );
    FuncsMax     := GetSUserParRArray( 'FuncsMax' );
    FuncsBase    := GetSUserParRArray( 'FuncsBase' );
    ValTexts     := GetSUserParRArray( 'ValTexts' );
    ValStyleInds := GetSUserParRArray( 'ValStyleInds' );
    FuncsTicks   := GetSUserParRArray( 'FuncsTicks' );
    LegNames     := GetSUserParRArray( 'LegNames' );
    LegColors    := GetSUserParRArray( 'LegColors' );
  end;
  AUDComp.SetSUserParStr( 'HeaderText',  CompCaption );
end; // end of procedure TK_MVLDiagramBuilder2.PrepUDComponentContext

//**************************** TK_MVLDiagramBuilder2.SetBarColors
//
procedure TK_MVLDiagramBuilder2.SetBarColors( PColors: PInteger; Count: Integer );
begin
  SetLength( BarColors, Count );
  Move( PColors^, BarColors[0], SizeOf(Integer) * Count );
end; // end of procedure TK_MVLDiagramBuilder2.PrepUDComponentContext

//**************************** TK_MVLDiagramBuilder2.SetTableSubMatrixParams
// WSDocument Set WTable or WDiagram SubMatrix Params
//
procedure TK_MVLDiagramBuilder2.SetUDComponentParams(
                                  ColorSchemeInd : Integer = -1; ColorSchemes : TK_RArray = nil;
                                  SkipRebuildFlag : Boolean = false;
                                  PVInds : PInteger = nil; AVCount : Integer = 0;
                                  PRInds : PInteger = nil; ARCount : Integer = 0 );
var
  ri, ci  : Integer;
  PMVVAttrs : TK_PMVVAttrs;
  DPInds  : TN_IArray;
  DLInds  : TN_IArray;
  CurVal : Double;
  PCurVal : PDouble;
  CInd : Integer;
  CColor : Integer;
  ScaleHigh : Integer;
  ScaleInd : Integer;
  PScale : Pointer;
  UsedRowInds : TN_IArray;
  SortNInds : TN_IArray;
  WColors : TN_IArray;
  WTexts : TN_SArray;

  SVA : TK_SpecValsAssistant;
  SVInd : Integer;
  ValText : String;
  VCSS : TK_UDDCSSpace;
  nc, nr : Integer;
  VInd : Integer;
  SortedData : TN_DArray;
  PMVVector : TK_PMVVector;
  GroupCapts, GElemCapts : TN_SArray;
  PRowCapts : PString;
  RowLength : Integer;
  RowILength : Integer;
  GSums : TN_DArray;
  ValStyleInd : Byte;
  FuncTickInd : Integer;
  UseSColorsForRows, UseSColorsForCols : Boolean;
  PVInds0 : PInteger;
  PColorsSheme : TK_PRArray;

  procedure BuildSortedInds( CInd : Integer );
  begin
    with PMVVector^ do begin
      SetLength( SortedData, nr );
      K_MoveVector( SortedData[0], SizeOf( Double ),
            TabValues.PME(CInd, 0)^, RowLength, SizeOf( Double ), nr );
      SetLength( UsedRowInds, nr );
      K_BuildSortedDoubleInds( @UsedRowInds[0], @SortedData[0], nr, not (K_dofAscendingOrder in OrderFlags) );
    end;
  end;

  procedure SetLegendRArrays( Leng : Integer );
  var
    i, j : Integer;
    ClearLegArrays : Boolean;
  label EndLoop;
  begin
    ClearLegArrays := not (UseSColorsForRows or UseSColorsForCols);

    j := 0;
    if not ClearLegArrays then begin
    // Prepare Colors
      SetLength( WColors, Leng );
      if Length( BarColors ) = 0 then begin
      // Init Bar Different Colors
        SetLength( BarColors, 5 );
        BarColors[0] := $707070;
        BarColors[1] := $909090;
        BarColors[2] := $B0B0B0;
        BarColors[3] := $D0D0D0;
        BarColors[4] := $F0F0F0;
      end;
      while Leng > 0 do
        for i := 0 to High(BarColors) do begin
          if j < Leng then begin
            WColors[j] := BarColors[i];
            Inc( j );
          end else
            goto EndLoop;
        end;
    end;

  EndLoop:
    ClearLegArrays := ClearLegArrays or (j > Length(BarColors));
    if not ClearLegArrays then begin
      if LegNames <> nil then
        LegNames.ASetLength( Leng );
      if LegColors <> nil then begin
        LegColors.ASetLength( Leng );
        LegColors.SetElems( WColors[0], false );
      end;
    end else begin
    // Skip Legend
      if LegNames <> nil then
        LegNames.ASetLength( 0 );
      if LegColors <> nil then
        LegColors.ASetLength( 0 );
    end;
  end;

begin

  if TabValues = nil then  Exit;
  UsedRowInds := nil;
  SortNInds := nil;

// Select VInd Value - Start Vector Number
  VInd := 0;
  if (PVInds = nil) or
     (AVCount = 0)  or
     (K_dcfViewAllCols in DataChartFlags) then begin
    nc := RAAttrs.Count;
    PVInds := nil;
  end else begin
    nc := AVCount;
    if PVInds <> nil then VInd := PVInds^;
  end;
  PVInds0 := PVInds;

  if FuncsMin <> nil then
    FuncsMin.ASetLength( nc );
  if FuncsBase <> nil then
    FuncsBase.ASetLength( nc );
  if FuncsMax <> nil then
    FuncsMax.ASetLength( nc );

  nr := 0;
  VCSS := nil;
  FuncTickInd := -1;
  if nc > 0 then begin
  // Init View CSS from Start Vector Number
    PMVVector := TK_PMVVector(TK_UDVector(UDVectors.Objects[VInd]).R.P);
    with PMVVector^ do begin
      VCSS := TK_UDDCSSpace(CSS);

   //  Init Rows Inds in SortInds
      if (PRInds = nil) or (ARCount = 0) then begin
        nr := D.ALength;
        PRInds := nil;
      end else
        nr := ARCount;

      SetLength( UsedRowInds, nr );
      if PRInds = nil then
        K_FillIntArrayByCounter( @UsedRowInds[0], nr )
      else
        Move( PRInds^, UsedRowInds[0], SizeOf( Integer ) * nr );

    end;
    if FuncTickCSInd >= 0 then
      FuncTickInd := K_IndexOfIntegerInRArray( FuncTickCSInd, VCSS.DP, VCSS.PDRA.ALength );
  end;

  if (K_dcfGroupByRows in DataChartFlags) or
     (FuncTickInd < 0) then begin
    if FuncsTicks <> nil then
      FuncsTicks.ASetLength( 0 );
  end else if FuncsTicks <> nil then
    FuncsTicks.ASetLength( nc, 1 );

  UseSColorsForRows := not (K_dcfUseTabColors in DataChartFlags);
  UseSColorsForCols := false;
  if UseSColorsForRows then begin
    UseSColorsForRows := not (K_dcfDifColorsForGroups in DataChartFlags) xor
                         (K_dcfGroupByRows in DataChartFlags);
    UseSColorsForCols := not UseSColorsForRows;
    if (BarColors = nil) or not SkipRebuildFlag then begin
      PColorsSheme := K_GetPRAColorScheme( ColorSchemes, ColorSchemeInd );
      if PColorsSheme <> nil then begin
        if UseSColorsForCols then
          ci := nc
        else
          ci := nr;
          SetLength( BarColors, ci );
        K_BuildColorsByColorScheme( @BarColors[0], ci, PColorsSheme^ );
      end;
    end;

  end;

// Build UserParams Vectors and Matrix
  if UseSColorsForRows then
    SetLegendRArrays( nr )
  else if UseSColorsForCols then
    SetLegendRArrays( nc );

  TabValues.ASetLength( nc, nr );

  if ValTexts <> nil then
    ValTexts.ASetLength( nc, nr );

  if ValStyleInds <> nil then
    ValStyleInds.ASetLength( nc, nr );

  Colors.ASetLength( nc, nr );

 // Move Column Values, Texts SVFlags

  SetLength( GroupCapts, nc );
  if K_dcfGroupByRows in DataChartFlags then
    SetLength( GSums, nr )
  else
    SetLength( GSums, nc );

  for ci := 0 to nc - 1 do begin

    if PVInds <> nil then begin
      VInd := PVInds^;
      Inc(PVInds);
    end;

    PMVVAttrs := TK_PMVVAttrs(TK_RArray(RAAttrs[VInd]).P);
    PMVVector := TK_PMVVector(TK_UDVector(UDVectors.Objects[VInd]).R.P);
    with PMVVector^, PMVVAttrs^ do begin
      if not SkipRebuildFlag then
        K_RebuildMVAttribs( PMVVAttrs^, PMVVector, ColorSchemeInd, ColorSchemes );
//        K_RebuildMVAttribs( PMVVAttrs^, D, ColorSchemeInd, ColorSchemes );
    // Set FuncsMin FuncsMax
      if FuncsMin <> nil then
        PDouble(FuncsMin.P(ci))^ := VMin;
      if FuncsMax <> nil then
        PDouble(FuncsMax.P(ci))^ := VMax;
      if FuncsBase <> nil then
        PDouble(FuncsBase.P(ci))^ := VBase;

      if UDVNames = nil then
        UDVNames := TK_UDVector(ElemCapts);

    // Set Column Caption
      GroupCapts[ci] := UDVectors[VInd];

     // Prep Data Projections
      DPInds := nil;
      if CSS <> VCSS then begin
        SetLength( DPInds, nr );
        if not K_BuildDataProjectionByCSProj( TK_UDDCSSpace(CSS), VCSS, @DPInds[0], nil ) then
          DPInds := nil;
      end;

      if (FuncsTicks.ALength > 0) and (FuncTickInd >= 0) then begin
        CInd := FuncTickInd;
        if DPInds <> nil then
          CInd := DPInds[CInd];
        PDouble(FuncsTicks.PME(ci,0))^ := PDouble( D.P(CInd) )^;
      end;

   // Move Values, Colors, ValTexts and ValStyleInds
      SVA := TK_SpecValsAssistant.Create( TK_UDRArray(UDSVAttrs).R );
      ScaleHigh := RangeValues.AHigh;
      PScale := RangeValues.P;
      CurVal := 0;
      CColor := 0;
      for ri := 0 to nr - 1 do begin

        SVInd := -1;
{
        if SortInds = nil then
          CInd := ri
        else
}
          CInd := UsedRowInds[ri];

        if DPInds <> nil then begin
          CInd := DPInds[CInd];
          if DPInds[CInd] < 0 then
            SVInd := AbsDCSESVIndex;
        end;

        if SVInd < 0 then begin // Not Absent - Check Real Value
          CurVal := PDouble(D.P(CInd))^;
          SVInd := SVA.IndexOfSpecVal( CurVal );
        end;

        if SVInd >= 0 then begin
          ValStyleInd := 1;
          CurVal := 0;
          with SVA.GetSpecValAttrs(SVInd)^ do begin
            ValText := Caption;
            CColor := Color;
          end;
        end else begin
          ValStyleInd := 0;
          if Colors <> nil then begin
            ScaleInd := K_IndexOfDoubleInScale( PScale, ScaleHigh, sizeof(Double), CurVal );
            if (ScaleInd > 0) and (ValueType.T = K_vdtDiscrete) then Dec(ScaleInd);
            CColor := PInteger( RangeColors.P(ScaleInd) )^;
          end;

          if VFormat <> '' then
            ValText := format( VFormat, [CurVal])
          else
            ValText := format('%.*f', [VDPPos, CurVal]);
        end;

        if UseSColorsForRows then CColor := WColors[ri];
        if UseSColorsForCols then CColor := WColors[ci];

        if K_dcfGroupByRows in DataChartFlags then
          GSums[ri] := GSums[ri] + CurVal
        else
          GSums[ci] := GSums[ci] + CurVal;

        PDouble( TabValues.PME(ci,ri) )^ := CurVal;

        if Colors <> nil then
          PInteger( Colors.PME(ci,ri) )^ := CColor;

        if ValStyleInds <> nil then
          PByte( ValStyleInds.PME(ci,ri) )^ := ValStyleInd;

        if ValTexts <> nil then
          PString( ValTexts.PME(ci,ri) )^ := ValText;
      end;
      SVA.Free;
      Inc(VInd);
    end;
  end;

  if nr <= 0  then Exit;

  //*** Set LHRowNums, LHRowNames Sort

  if LHRowNums <> nil then begin
    LHRowNums.ASetLength( nr );
    for ri := 0 to nr - 1 do
      PString( LHRowNums.P(ri) )^ := IntToStr(ri + 1);
  end;

  SetLength( GElemCapts, nr );
  if (UDVNames <> nil) or (VCSS = nil) then begin
    SetLength( SortNInds, nr );
    K_MoveVectorBySIndex( SortNInds[0], SizeOf(Integer),
       VCSS.DP(0)^, SizeOf(Integer), SizeOf(Integer), nr, @UsedRowInds[0] );

    K_MoveSPLVectorBySIndex( GElemCapts[0], SizeOf(string),
       UDVNames.DP(0)^, SizeOf(string),
       nr, Ord(nptString), [K_mdfFreeDest], @SortNInds[0] );
  end;

  if LegNames.ALength > 0 then begin
    if  UseSColorsForCols then
      LegNames.SetElems( GroupCapts[0], false );
    if UseSColorsForRows  then
      LegNames.SetElems( GElemCapts[0], false );
  end;

  if K_dcfGroupByRows in DataChartFlags then begin
  //*** Grouped By Rows
    if ValTexts <> nil then
      ValTexts.TranspElems;

    if Colors <> nil then
      Colors.TranspElems;

    if ValStyleInds <> nil then
      ValStyleInds.TranspElems;

    TabValues.TranspElems;

    if FuncsMax <> nil then begin
      ci := K_SFGetIndOfMax( FuncsMax.P, nc );
      CurVal := PDouble(FuncsMax.P(ci))^;
      FuncsMax.ASetLength( nr );
      FuncsMax.SetElems(CurVal);
    end;

    if FuncsMin <> nil then begin
      ci := K_SFGetIndOfMin( FuncsMin.P, nc );
      CurVal := PDouble(FuncsMin.P(ci))^;
      FuncsMin.ASetLength( nr );
      FuncsMin.SetElems(CurVal);
    end;

    if FuncsBase <> nil then begin
      ci := K_SFGetIndOfMin( FuncsBase.P, nc );
      CurVal := PDouble(FuncsBase.P(ci))^;
      FuncsBase.ASetLength( nr );
      FuncsBase.SetElems(CurVal);
    end;

    if LHRowNames <> nil then begin
      LHRowNames.ASetLength(1, nc);
      LHRowNames.SetElems( GroupCapts[0], false );
      PRowCapts := @GroupCapts[0];
    end;

    if LHColNames <> nil then begin
      LHColNames.ASetLength(nr);
      LHColNames.SetElems( GElemCapts[0], false );
    end;

    ci := nr;
    nr := nc;
    nc := ci;

  //*** end of Grouped By Rows
  end else begin
  //*** Grouped By Columns
    if LHRowNames <> nil then begin
      LHRowNames.ASetLength(1, nr);
      LHRowNames.SetElems( GElemCapts[0], false );
      PRowCapts := @GElemCapts[0];
    end;

    if LHColNames <> nil then begin
      LHColNames.ASetLength(nc);
      LHColNames.SetElems( GroupCapts[0], false );
    end;

  //*** end of Grouped By Columns
  end;

  RowLength := nc * SizeOf( Double );
  if K_dcfNormGroups in DataChartFlags then
    for ci := 0 to nc - 1 do begin
      for ri := 0 to nr - 1 do begin
        PCurVal := TabValues.PME( ci, ri );
        if GSums[ci] <> 0 then
          PCurVal^ := PCurVal^ / GSums[ci] * 100;
      end;
      if FuncsMin <> nil then
        PDouble(FuncsMin.P(ci))^ := 0;

      if FuncsMax <> nil then
        PDouble(FuncsMax.P(ci))^ := 100;

      if FuncsBase <> nil then
        PDouble(FuncsBase.P(ci))^ := 0;

      if (FuncsTicks.ALength > 0) and (FuncTickInd >= 0) then begin
        PCurVal := FuncsTicks.PME(ci,0 );
        if GSums[ci] <> 0 then
          PCurVal^ := PCurVal^ / GSums[ci] * 100;
      end;

    end;

  if (K_dofDescendingOrder in OrderFlags) or
     (K_dofAscendingOrder in OrderFlags) then begin
    if K_dcfGroupOrder in DataChartFlags then begin

      RowILength := nc * SizeOf( Integer );

      if LHRowNames <> nil then begin
        LHRowNames.DeleteElems( 0, -1 );
        LHRowNames.ASetLength( nc, nr );
      end;

      for ci := 0 to nc - 1 do begin
        BuildSortedInds( ci );
        K_MoveVectorBySIndex( TabValues.PME( ci, 0 )^, RowLength,
          SortedData[0], SizeOf(Double), SizeOf(Double),
          nr, @UsedRowInds[0] );

        if ValTexts <> nil then begin
          SetLength( WTexts, nr );
          K_MoveSPLVector( WTexts[0], SizeOf(string),
             ValTexts.PME( ci, 0 )^, RowILength,
             nr, Ord(nptString), [K_mdfFreeDest] );
          K_MoveSPLVectorBySIndex( ValTexts.PME( ci, 0 )^, RowILength,
             WTexts[0], SizeOf(string),
             nr, Ord(nptString), [K_mdfFreeDest], @UsedRowInds[0] );
        end;

        if Colors <> nil then begin
          SetLength( SortNInds, nr );
          K_MoveVector( SortNInds[0], SizeOf(Integer),
            Colors.PME( ci, 0 )^, RowILength, SizeOf(Integer), nr );
          K_MoveVectorBySIndex( Colors.PME( ci, 0 )^, RowILength,
            SortNInds[0], SizeOf(Integer), SizeOf(Integer),
            nr, @UsedRowInds[0] );
        end;

        if ValStyleInds <> nil then begin
          SetLength( SortNInds, nr );
          K_MoveVector( SortNInds[0], SizeOf(Integer),
            ValStyleInds.PME( ci, 0 )^, RowILength, SizeOf(Integer), nr );
          K_MoveVectorBySIndex( ValStyleInds.PME( ci, 0 )^, RowILength,
            SortNInds[0], SizeOf(Integer), SizeOf(Integer),
            nr, @UsedRowInds[0] );
        end;

        if LHRowNames <> nil then begin
          K_MoveSPLVectorBySIndex( LHRowNames.PME( ci, 0 )^, RowILength,
             PRowCapts^, SizeOf(string),
             nr, Ord(nptString), [K_mdfFreeDest], @UsedRowInds[0] );
        end;

      end;
    end else begin
      ci := OrderColInd;
      if PVInds0 <> nil then
        ci := K_IndexOfIntegerInRArray( ci, PVInds0, nc );
      if ci < 0 then ci := 0;
      BuildSortedInds( ci );

      TabValues.ReorderRows( @UsedRowInds[0], nr, nil, 0, nil, 0 );

      if ValTexts <> nil then
        ValTexts.ReorderRows( @UsedRowInds[0], nr, nil, 0, nil, 0 );

      if Colors <> nil then
        Colors.ReorderRows( @UsedRowInds[0], nr, nil, 0, nil, 0 );

      if LHRowNames <> nil then
        LHRowNames.ReorderElems( @UsedRowInds[0], nr, nil, 0, nil, 0 );
    end;
  end;


end; // end of procedure TK_MVLDiagramBuilder2.SetTableSubMatrixParams


{*** end of TK_MVLDiagramBuilder2 ***}

{*** TK_WebSiteBuilder1 ***}

//********************************************** TK_WebSiteBuilder1.Create
//
constructor TK_WebSiteBuilder1.Create(AEncodeMode : TK_FileEncodeMode = K_femW1251;
                                      ASetCharsetInfo  : Boolean = false;
                                      ASkipSiteLoadProgress : Boolean = false);
begin
  inherited Create;
  PML := TStringList.Create;
  PL  := TStringList.Create;
  WL := TStringList.Create;
  SL := TStringList.Create;
  ML := TStringList.Create;
  AllArchs := TStringList.Create;
  SArchs := TStringList.Create;
  ArchivesList := TStringList.Create;
  HTMFilesList := TStringList.Create;
  StartArchivesList := TStringList.Create;
  WSLWWGroup := TStringList.Create;
  WSLWWGroup.QuoteChar := ' ';
  WSLWWGroup.Delimiter := ',';
  // Prepare patterns Macro Replace
  PatMacro := TStringList.Create;
  PatMacro.Add('Name=''+Name+''');
  PatMacro.Add('Value=''+Value+''');
  PatMacro.Add('Units=''+Units+''');
  PatMacro.Add('Range=''+Range+''');
  PatMacro.Add('RangeP=''+RangeP+''');
  PatMacro.Add('CLimit=''+Range+''');
  PatMacro.Add('PLimit=''+RangeP+''');

  JSPatDir := K_GetDirPath( 'JSPat' );
  JSLibDir := K_GetDirPath( 'JSLib' );
  JSImgDir := K_GetDirPath( 'JSImg' );
  SrcMapsDir := K_GetDirPath( 'Maps' );
  SiteTextsPath := K_IniHTMParGet( 'SightTextsDir' );
  SiteImgPath := K_IniHTMParGet( 'SightImgDir' );
  SiteRPath := K_IniHTMParGet( 'SightAtlasDir' );
  SiteArchsPath := K_IniHTMParGet( 'SightDataDir' );
  VTreeVWin := K_IniHTMParGet( 'VTreeVWin' );
  UnixSiteArchsPath := DosPathToUnixPath( SiteArchsPath );
  FEncodeMode := AEncodeMode;
  FSkipSiteLoadProgress := ASkipSiteLoadProgress;
  FSetCharsetInfo  := ASetCharsetInfo;
end;// end of constructor TK_WebSiteBuilder1.Create

//********************************************** TK_WebSiteBuilder1.Destroy
//
destructor TK_WebSiteBuilder1.Destroy;
begin
  PatMacro.Free;
  PML.Free;
  PL .Free;
  WL.Free;
  SL.Free;
  ML.Free;
  AllArchs.Free;
  SArchs.Free;
  ArchivesList.Free;
  HTMFilesList.Free;
  StartArchivesList.Free;
  WSLWWGroup.Free;

  inherited;
end;// end of destructor TK_WebSiteBuilder1.Destroy


//********************************************** TK_WebSiteBuilder1.ShowDump
//
procedure TK_WebSiteBuilder1.ShowDump( ADumpLine : string;
        MesStatus : TK_MesStatus; CountWarnings : Boolean= false );
var
 Pref : string;
begin
  if ADumpLine = '' then Exit;
  Pref := '';
  if MesStatus = K_msError then Pref := 'ОШИБКА: ';
  if Assigned(OnShowDump) then OnShowDump( Pref + ADumpLine, MesStatus );
  if (MesStatus = K_msError) or
     (CountWarnings and (MesStatus <> K_msInfo)) then
    Inc(ErrCount);
end; // end of procedure TK_WebSiteBuilder1.ShowDump

//********************************************** TK_WebSiteBuilder1.ArchStrKBSize
//
function TK_WebSiteBuilder1.ArchStrKBSize( ArchSize : Integer ) : string;
begin
  Result := FloatToStr( Round(ArchSize/100) / 10 );
end; // end of function TK_WebSiteBuilder1.ArchStrKBSize

//********************************************** TK_WebSiteBuilder1.TK_WebSiteBuilder1.DataArchDescr
//
procedure TK_WebSiteBuilder1.DataArchDescr( ArcInd : Integer; NeededArchs : string = '' );
begin
  if NeededArchs <> '' then NeededArchs := '['+NeededArchs+']';
  AllArchs.Add( ArchivesList[ArcInd]+
          ':["'+UnixSiteArchsPath+ArchivesList[ArcInd]+'.htm",['+NeededArchs+'],'+
          ArchStrKBSize( Integer(ArchivesList.Objects[ArcInd]) )+'],' );

end; // end of procedure TK_WebSiteBuilder1.TK_WebSiteBuilder1.DataArchDescr

//********************************************** TK_WebSiteBuilder1.StringsPackedAndSave
//
procedure TK_WebSiteBuilder1.StringsPackedAndSave( WWL : TStrings; ArchPath : string;
                           WSPMode : TK_WebSitePackMode );
var
//  WFEncodeMode   : TK_FileEncodeMode;
  Buf : string;
  i : Integer;
  RReplace : Boolean;
begin
// Replace $A0 to $20
  Buf := WWL.Text;
  RReplace := false;
  for i := 1 to Length(Buf) do
    if Byte(Buf[i]) = $A0 then begin
      Buf[i] := Char($20);
      RReplace := true;
    end;
  if RReplace then
    WWL.Text := Buf;
  if WSPMode <> K_wspNoPack then begin
//*** packed Archive
    RReplace := true;
    try
      PML[0] := 'PackedBody='+K_PackJSText( K_PrepJSTextPack(WWL.Text), ' file ' + ArchPath );
    except
      On E: Exception do begin
        ShowDump( E.Message, K_msWarning, true);
        RReplace := false;
      end;
    end;
    if RReplace and
       ( (WSPMode = K_wspAllPack) or
         ( (WSPMode = K_wspIfNeeded) and
           (Length(PML[0]) - 11 < Length(WWL.Text)) ) ) then begin
      WWL.Clear;
      WWL.AddStrings( PL );
    end;
  end;
  K_SListMListReplace( WWL, PML, K_ummRemoveMacro );
//  WWL.SaveToFile( ArchPath );
//  WFEncodeMode := FEncodeMode;
//  if WFEncodeMode <> K_femANSI then WFEncodeMode := K_femUTF8;
  K_StringsSaveToFile( ArchPath , WWL, FEncodeMode )
end; // end of procedure TK_WebSiteBuilder1.StringsPackedAndSave

//**************************** TK_WebSiteBuilder1.AddArchive
//
function TK_WebSiteBuilder1.AddArchive( PJSArchsGroup : TK_PJSArchsGroup ) : TStrings;
begin
  with PJSArchsGroup^ do begin
    CArchInd := ArchsList.Count;
    CArchJSID := ArchPref+IntToStr(CArchInd);
    CArch := TStringList.Create;
    ArchsList.AddObject( CArchJSID, CArch );
    Result := CArch;
  end;
end; // end of function TK_WebSiteBuilder1.AddArchive

//**************************** TK_WebSiteBuilder1.SetCurArchive
//
function TK_WebSiteBuilder1.SetCurArchive( PJSArchsGroup : TK_PJSArchsGroup; CID : string ) : TStringList;
begin
  with PJSArchsGroup^ do begin
    CArchJSID := CID;
    CArchInd := ArchsList.IndexOf( CArchJSID );
    assert( CArchInd <> -1, 'K_MVSDB no archive named "'+CID+'"' );
    CArch := TStringList(ArchsList.Objects[CArchInd]);
    Result := CArch;
  end;
end; // end of function TK_WebSiteBuilder1.SetCurArchive

//**************************** AddStringsToArchive
// add Strings Definitions to Archive
procedure TK_WebSiteBuilder1.AddStringsToArchive( DArchInd : Integer );
var
  StartInd, CInd, i : Integer;
  DCArch : TStringList;

  procedure CloseGroup;
  var
    wstr : string;
  begin
    if StartInd <> -1 then begin
      StartInd := -1;
      wstr := WSL[WSL.Count-1];
      WSL[WSL.Count-1] := Copy(wstr, 1, Length(wstr) - 1 );
      WSL.Add( ');' );
    end;
  end;

begin
  WSL.Clear;
  StartInd := -1;
  CInd := ComTextsList.IndexOfObject( TObject(DArchInd) );
  if CInd < 0 then Exit;
  for i := CInd to ComTextsList.Count - 1 do begin
    if Integer(ComTextsList.Objects[i]) <> DArchInd then begin
      CloseGroup;
      continue;
    end;
    if (StartInd = -1) then begin// Start Group
      WSL.Add( 'AddToCA('+IntToStr(i)+',' );
      StartInd := i;
    end;
    WSL.Add( ''''+ComTextsList[i]+''',');
  end;
  CloseGroup;
  DCArch := TStringList(DArchs.ArchsList.Objects[DArchInd]);
  WSL.AddStrings( DCArch );
  DCArch.Clear;
  DCArch.AddStrings( WSL );
end; // end of procedure TK_WebSiteBuilder1.AddStringsToArchive

//**************************** TK_WebSiteBuilder1.AddComText
// returns Real String Index ins Strings List
function TK_WebSiteBuilder1.AddComText( str : string; DefJSInd : Integer; var ASN : TStringList ) : string;
var
  ArchInd, Ind, i : Integer;
  ArchJS : string;
begin
  Ind := ComTextsList.IndexOf( str );
  if Ind = -1 then begin
    Ind := ComTextsList.Count;
    ComTextsList.AddObject( str, TOBject(DefJSInd) );
    ArchInd := DefJSInd;
  end else
    ArchInd := Integer( ComTextsList.Objects[Ind] );
  Result := IntToStr(Ind);
  ArchJS := DArchJSPref+IntToStr(ArchInd);
  if ASN = nil then begin
    ASN := TStringList.Create;
    ListOfLists.Add(ASN);
  end;
  for i := 0 to ASN.Count - 1 do
    if ASN.IndexOf(ArchJS) <> -1 then Exit;
  ASN.Add( ArchJS );
end; // end of function TK_WebSiteBuilder1.AddComText

//**************************** TK_WebSiteBuilder1.AddToNOL
// add JSObj to Needed Objects List (NOL)
procedure TK_WebSiteBuilder1.AddToNOL(  var ListJSObj, AddJSObj : TK_JSObj );
begin
  if AddJSObj.JSID = '' then Exit;
  if ListJSObj.NOL = nil then begin
    ListJSObj.NOL := TList.Create;
    ListOfLists.Add(ListJSObj.NOL);
  end;
    ListJSObj.NOL.Add( @AddJSObj );
end; // end of procedure TK_WebSiteBuilder1.AddToNOL

//**************************** TK_WebSiteBuilder1.AddVObject
//
function TK_WebSiteBuilder1.AddVObject( CUD : TN_UDBase; ArchJSID : string; {DefStrArcInd : Integer;}
              var Ind : Integer; UnConditionalAdd : Boolean = false ) : Boolean;
begin
  if (CUD.Marker = 0) or UnConditionalAdd then begin
    Result := true;
    Ind := JSObjsFillInd;
    Inc(JSObjsFillInd);
    assert( JSObjsFillInd <= Length(JSObjs), 'Out of Site Generator Tables');
    FillChar( JSObjs[Ind], SizeOf(TK_MVJSObj), 0 );
    with JSObjs[Ind] do begin
      JSBID := '';
      UDB := CUD;
      with JSO[0] do begin
        Rebuild := false;
        JSID := '';
        ADN := ArchJSID;
        AVN := ArchJSID;
//??        if DefStrArcInd >= 0 then
//??          ACI := AddComText( TK_UDSection(CUD).MenuName, DefStrArcInd, ASN );
      end;
    end;
    if CUD.Marker = 0 then
      CUD.SetMarker( Ind + 1 );
  end else begin
    Ind := CUD.Marker - 1;
    Result := JSObjs[Ind].Rebuild;
  end;
end; // end of function TK_WebSiteBuilder1.AddVObject

//********************************************** TK_WebSiteBuilder1.BuildArchivesList
// returns String with needed Archives
function TK_WebSiteBuilder1.BuildArchivesList( PJSObj : TK_PJSObj ) : string;
var
  i : Integer;
  SL : TStringList;
  PP : TK_PJSObj;

  procedure AddNew( List, AddList : TStrings );
  var j : Integer;
  begin
    for j := 0 to AddList.Count - 1 do
      if List.IndexOf(AddList[j]) = -1 then List.Add(AddList[j]);
  end;

begin
  SL := TStringList.Create;
  with PJSObj^ do begin
    SL.Add(ADN);
    if ADN <> AVN then SL.Add(AVN);

// add srtrings archives
    if ASN <> nil then AddNew( SL, ASN );

// add needed objects archives
    if NOL <> nil then
      for i := 0 to NOL.Count - 1 do begin
        PP := TK_PJSObj(NOL[i]);
        with PP^ do
          if SL.IndexOf(ADN) = -1 then SL.Add(ADN);
      end;
    SL.Delete(0);
    Result := '';
    if SL.Count > 0 then begin
         // Add archives list to Object Needed Archives List
      SL.Delimiter := ',';
      SL.QuoteChar := ' ';
      for i := 0 to SL.Count - 1 do
        SL[i] := '"'+SL[i]+'"';
      Result := '['+SL.DelimitedText+']';
    end;
  end;
  SL.Free;
end; // end of function TK_WebSiteBuilder1.BuildArchivesList

//**************************** TK_WebSiteBuilder1.NewJSName
//
function TK_WebSiteBuilder1.NewJSName( Name : string ) : string;
var
  Ind : Integer;
begin
  Result := Name;
  Ind := 0;
  while JSObjNamesList.IndexOf(Result) <> -1 do begin
    Result := Name + 'L' + IntToStr(Ind);
    Inc(Ind);
  end;
  JSObjNamesList.Add(Result);
end; // end of function TK_WebSiteBuilder1.NewJSName

//**************************** TK_WebSiteBuilder1.BuildJSID
//
function TK_WebSiteBuilder1.BuildJSID( CUD : TN_UDBase; ObjDefID : string ) : string;
var
  j, i : Integer;

begin
  if (CUD.ObjAliase = '') then Result := ObjDefID
  else begin
    Result := CUD.ObjName;
    j := 0;
    for i := 1 to Length(CUD.ObjName) do begin
      if (CUD.ObjName[i] = ' ') or
         (CUD.ObjName[i] = '~') or
         (CUD.ObjName[i] = '-') or
         (CUD.ObjName[i] = '(') or
         (CUD.ObjName[i] = ')') or
         (CUD.ObjName[i] = '*') or
         (CUD.ObjName[i] = '#') or
         (CUD.ObjName[i] = '?') or
         (CUD.ObjName[i] = '/') then Continue;
      Inc(j);
      Result[j] := CUD.ObjName[i];
    end;
    SetLength( Result, j );
  end;
end; // end of function TK_WebSiteBuilder1.BuildJSID

//**************************** TK_WebSiteBuilder1.BuildWSLs
//
procedure TK_WebSiteBuilder1.BuildWSLs( PWSL : Pointer = nil;
            PWSL1 : Pointer = nil; PWSL2 : Pointer = nil );
  procedure CreateWList( var SL : TStringList );
  begin
    if @SL = nil then Exit;
    SL := TStringList.Create;
    SL.Delimiter := ',';
    SL.QuoteChar := ' ';
  end;
begin
  CreateWList(TStringList(PWSL^));
  CreateWList(TStringList(PWSL1^));
  CreateWList(TStringList(PWSL2^));
end; // end of function TK_WebSiteBuilder1.BuildWSLs

//********************************************** TK_WebSiteBuilder1.BuildSite
//
function TK_WebSiteBuilder1.BuildSite( ARootPath: string;
              ARootUDObj, StartWWObj, UDWLayout : TN_UDBase;
              AVWinName : string = '';
              PageTitle : string = '';
              WSPMode : TK_WebSitePackMode = K_wspIfNeeded ) : Integer;

const CharSetAttrs : array [0..3] of string = (
  'windows-1251', 'utf-8', 'unicode', 'koi8-r' );
var
  i, WInd, k : Integer;
  LibArchsList : string;
  AppWinName: string;
  BasePath : string;
  RootHTMFile : string;

label Err;

begin
  ErrCount := -1;
  RootUDObj := ARootUDObj;
  if RootUDObj = nil then begin
    DumpLine := 'Не задан публикуемый объект';
    goto Err;
  end;

{
  if UDWLayout = nil then
    UDWLayout := K_GetMVDarSysFolder( K_msdWinDescrs ).DirChild(0);
  if (UDWLayout = nil) or not (UDWLayout is TK_UDMVVWLayout) then begin// Wrong Layout Type
    ShowDump( WarnPrefix + 'Не определена раскладка окон публикации' );
    Result := ErrCount;
    Exit;
  end;
}

//  RootPath  := K_ExpandFileNameByIniDir( 'OutFiles', IncludeTrailingPathDelimiter( ARootPath ) );
  RootPath := K_ExpandFileName( ARootPath );
  if K_StrStartsWith( '.htm', ExtractFileExt(RootPath), true ) then begin
  //*** Result File Name is specified
    ShowDump('Начато создание WEB-страницы '+RootPath, K_msInfo );
//    N_PBCaller.Update(0);
    RootHTMFile := ExtractFileName( RootPath );
    SiteCurRPath := IncludeTrailingPathDelimiter( ChangeFileExt(RootHTMFile, '.files' ) );
    RootPath := ExtractFilePath( RootPath );
  end else begin
  //*** Result File Path is specified
    RootHTMFile := 'index.htm';
    SiteCurRPath := SiteRPath;
//    N_PBCaller.Update(0);
    ShowDump('Начато создание WEB-сайта в каталоге '+RootPath, K_msInfo );
  end;

  if not K_ForceDirPathDlg( RootPath ) then begin
    DumpLine := FolderCreationErr+RootPath;
    goto Err;
  end;

  RootPath := IncludeTrailingPathDelimiter( RootPath );


  SiteBase  := RootPath + SiteCurRPath;
  MapBase   := SiteBase + SiteImgPath;
  if not K_ForceDirPath( MapBase ) then begin
    DumpLine := FolderCreationErr+MapBase;
    goto Err;
  end;

  HTMBase   := SiteBase + SiteTextsPath;
  if not K_ForceDirPath( HTMBase ) then begin
    DumpLine := FolderCreationErr+HTMBase;
    goto Err;
  end;

  ErrCount := 0;
  PML.CLear;
  PL.CLear;
  WL.CLear;
  SL.CLear;
  ML.CLear;
  AllArchs.CLear;
  SArchs.CLear;
  ArchivesList.CLear;
  HTMFilesList.CLear;
  StartArchivesList.CLear;
  WSLWWGroup.CLear;

  if UDWLayout <> nil then begin
    VWList := THashedStringList.Create;
    TK_UDMVVWLayout(UDWLayout).GetMVVWindowList( VWList, true );
    VWListF := THashedStringList.Create;
    TK_UDMVVWLayout(UDWLayout).GetMVVWindowList( VWListF, false );
    AppWinName := VWList[0];
  end else begin
    VWList := nil;
    AppWinName := 'MC';
  end;

  DumpLine := BuildJSArchives( StartWWObj, UDWLayout, AVWinName );
  if DumpLine <> '' then goto Err;

  if ShowDetails then begin
    ShowDump( 'Создание файлов архивов', K_msInfo );
  end;
//  N_PBCaller.Update( 0 );

  K_SetPackMode( FEncodeMode <> K_femKOI8 );

//***********************
// Macro Replace Prepare
//***********************
  ML.Values['PageName'] := PageTitle;
  ML.Values['ImgPath'] := DosPathToUnixPath( SiteImgPath );
  ML.Add( 'HTMPath='+DosPathToUnixPath( SiteTextsPath ) );
  if SetCharsetInfo then
    ML.Add('CharsetInfo=charset='+CharSetAttrs[Ord(FEncodeMode)]);

  ArchsBase := SiteBase + SiteArchsPath;
  if not K_ForceDirPath( ArchsBase ) then begin
    DumpLine := FolderCreationErr+ArchsBase;
    goto Err;
  end;

  K_VFLoadStrings( PL, JSPatDir+'PackedArchPat.htm' );

  PML.Add('');
  PML.Add('');
  if SetCharsetInfo then
    PML.Add('CharsetInfo=charset='+CharSetAttrs[Ord(FEncodeMode)]);
{
//***********************
// Build 0-archive file
//***********************
  SL.LoadFromFile( JSPatDir+'SArchPat.htm' );
  ML.Add( 'ArchName='+ArchivesList[0] );
  ML.Add( 'ArchBody='+ TStringList( ArchivesList.Objects[0] ).Text );
  K_SListMListReplace( SL, ML, K_ummRemoveMacro );
  PML[1] := 'ArchName='+ArchivesList[0];
  StringsPackedAndSave( SL, ArchsBase + ArchivesList[0]+'.htm', WSPMode );
}

//***********************
// Build All archive files
//***********************
  K_VFLoadStrings( WL, JSPatDir+'ArchPat.htm' );
  if WL.Count = 0 then begin
    DumpLine := 'Отсутствует шаблон архива ' + JSPatDir + 'ArchPat.htm';
    goto Err;
  end;

  k := ArchivesList.Count;
  N_PBCaller.Start( k );
  for i := 0 to k - 1 do begin
    SL.Clear;
    if (i = 0) and (VWList = nil)  then // use special 0-archive with build in WinLayout
      K_VFLoadStrings( SL, JSPatDir+'SArchPat.htm' )
    else
      SL.AddStrings( WL );
    ML.Values['ArchName'] := ArchivesList[i];
    ML.Values['ArchBody'] := TStringList(ArchivesList.Objects[i]).Text;
    K_SListMListReplace( SL, ML, K_ummRemoveMacro );
    PML[1] := 'ArchName='+ArchivesList[i];
    StringsPackedAndSave( SL, ArchsBase + ArchivesList[i]+'.htm', WSPMode );
    N_PBCaller.Update( i );
  end;

//***********************
//   Copy Images
//***********************
  if ShowDetails then
    ShowDump( 'Перепись служебных изображений', K_msInfo );

  ImgBase   := SiteBase + SiteImgPath;
  if not K_ForceDirPath( ImgBase ) then begin
    DumpLine := FolderCreationErr+ImgBase;
    goto Err;
  end;
  K_VFCopyDirFiles( JSImgDir, ImgBase, K_DFCreatePlain,
                    '*.*', [K_vfcRecurseSubfolders, K_vfcOverwriteNewer] );

//***********************
//   Copy Libraries
//***********************
  if ShowDetails then
    ShowDump( 'Перепись библиотек', K_msInfo );

  if WSPMode <> K_wspNoPack then begin
    //*** Copy Unpack Code
    K_VFLoadStrings( SL, JSPatDir+'u.js' );
    WL.Clear;
    WL.Add('CharNumString='+K_GetJSCharNumString);
    WL.Add('ValidCharString='+K_GetJSValidCharString);
    K_SListMListReplace( SL, WL, K_ummRemoveMacro );
    K_StringsSaveToFile( SiteBase+'u.js', SL, FEncodeMode );
  end;
  //*** copy libraries
  PML[1] := '';

  K_VFUDCursorPathDelimsPrep;
  if K_VFFindFirst( VFS, JSLibDir, [K_vfsVFile] ) then begin
    repeat
      WL.Clear;
      if RebuildLibraries or
         (K_VFCompareFilesAge( JSLibDir + VFS.VFName, SiteBase + VFS.VFName ) = K_vfcrOK) then begin
        K_VFLoadStrings( SL, JSLibDir + VFS.VFName );
        K_CompressJSStrings( WL, SL, ['', '//'],
          ['// ', 'N_AMP2('], ['/*', '*/', '//##Begin', '//##End'] );
        StringsPackedAndSave( WL, SiteBase + VFS.VFName, WSPMode );
      end;
    until not K_VFFindNext( VFS );
  end;
  K_VFFindClose( VFS );

//***********************
//   Prepare index.htm
//***********************
  if ShowDetails then
    ShowDump( 'Подготовка '+RootHTMFile, K_msInfo );

  AllArchs.Clear;
  SArchs.Clear;
  BasePath := DosPathToUnixPath( SiteCurRPath );
  if WSPMode <> K_wspNoPack then
    ML.Add( 'LinkUnpack=<script language="javaScript" src='+
             BasePath+'u.js></script>' );
  ML.Add( 'BasePath='+BasePath );
  ML.Add( 'AppWinName='+AppWinName );
  ML.Add( 'ShowProgress='+BoolToStr(SkipSiteLoadProgress) );
// Add Size to Archives List
  if K_VFFindFirst( VFS, ArchsBase, [K_vfsVFile] ) then
    repeat
      WInd := ArchivesList.IndexOf( Copy(VFS.VFName, 1, Length(VFS.VFName) - 4) );
      if WInd < 0 then Continue;
      ArchivesList.Objects[WInd].Free;
      ArchivesList.Objects[WInd] := TObject(VFS.VFSize);
    until not K_VFFindNext( VFS );
  K_VFFindClose( VFS );

// Create LibFiles List
  WL.Clear;
  WInd := 2;
  if K_VFFindFirst( VFS, SiteBase, [K_vfsVFile], '*.htm' ) then
    repeat
      if VFS.VFName = 'K_ALib1.htm' then begin
        ML.Add('StartLibSize=' + ArchStrKBSize( VFS.VFSize ) );
      end else begin
        WL.AddObject( VFS.VFName, TObject(VFS.VFSize) );
        SArchs.AddObject( '''AL'+IntToStr(WInd)+''',', TObject(VFS.VFSize) );
        Inc(WInd)
      end;
    until not K_VFFindNext( VFS );

  K_VFFindClose( VFS );
  K_VFUDCursorPathDelimsRestore;

// Skip Comma Separator in Last LibArchsList Element
  LibArchsList := SArchs.Text;
  LibArchsList := Copy(LibArchsList, 1, Length(LibArchsList) - 3 );
// Add Start Arhives

  WInd := StartArchivesList.Count - 2;
  for i := 0 to WInd do
    SArchs.Add( ''''+StartArchivesList[i]+''',' );
  SArchs.Add( ''''+StartArchivesList[WInd + 1]+'''' );
  ML.Add('StartArchsList='+SArchs.Text);

// Add First Archive Description
  DataArchDescr( 0, LibArchsList );

// Add All Other Archivs Descriptions
  for i := 1 to ArchivesList.Count - 1 do DataArchDescr( i );

  WInd := 2;
  for i := 0 to WL.Count - 1 do begin
    AllArchs.Add( 'AL'+IntToStr(WInd)+
            ':["'+WL[i]+'",[],'+
            ArchStrKBSize( Integer(SArchs.Objects[i]) )+'],' );
    Inc(WInd);
  end;
// Skip Comma Separator in Last Element
  WInd := AllArchs.Count-1;
  LibArchsList := AllArchs[WInd];
  AllArchs[WInd] := Copy(LibArchsList, 1, Length(LibArchsList) - 1 );

  ML.Add('ArchsDescriptions='+AllArchs.Text);
  K_VFLoadStrings( SL, JSPatDir + 'index.htm' );
  K_SListMListReplace( SL, ML, K_ummRemoveMacro );
  K_StringsSaveToFile( RootPath + RootHTMFile, SL, FEncodeMode );

  ShowDump( 'Создание сайта завершено', K_msInfo );
Err:
  ShowDump(DumpLine, K_msError);
  N_PBCaller.Finish();
  Result := ErrCount;
end; // end of procedure TK_WebSiteBuilder1.BuildSite

//********************************************** TK_WebSiteBuilder1.BuildJSArchives
//
function TK_WebSiteBuilder1.BuildJSArchives( StartWWObj,
                                UDWLayout : TN_UDBase; AVWinName : string ) : string;
var
  i : Integer;
  SL : TStrings;
  UDMVVWindow : TK_UDMVWBase;
  UDMVVWFrameSet : TK_UDMVWBase;
  WFlags : Integer;
  CVWName : string;
  FrameNames : string;
  SepStr : string;
  FrVName: string;
  FrSetName: string;
  FrSetCaption: string;
  ShowDocTitleData : string;
label FreeData;

  procedure AddWinClaster( );
  var
    i,j : Integer;
    str : string;
  begin
    if UDMVVWFrameSet = nil then Exit;
    SL.Add( 'TUC(TWClaster,"'+FrSetName+'",-1,['+FrameNames+']).MDoc=');
    SL.Add( 'function(UW){' );
    SL.Add( 'return '+'''<html><title>'+FrSetCaption+'</title>'''+'+"<script>"+GetSyncUWFuncs+GetGWScript+"</script>"+' );
    j := SL.Count;
    TK_UDMVVWFrameSet(UDMVVWFrameSet).AddHTMStrings( SL, false );
    str := SL[j];
    SL[j] := Copy( str, 1, Length(str) - 1 ) + ' ''+TVObjBodyEvents+''>';
    for i := j to SL.Count - 2 do
      SL[i] := '''' + SL[i] + '''+';
    j := SL.Count - 1;
    SL[j] := '"' + SL[j] + '<html>"}';
    FrameNames := '';
    SepStr := '';
    UDMVVWFrameSet := nil;
    FrSetName := '';
  end;

begin
  Result := '';
  SetLength( JSObjs, 15000);
  JSObjsFillInd := 0;
  ListOfLists := TList.Create;
  JSObjNamesList := THashedStringList.Create;

  ComTextsList := TStringList.Create;
  DArchs.ArchsList := TStringList.Create;
  DArchs.ArchPref := DArchJSPref;
  DArchs.CArchInd := -1;
  SL := AddArchive( @DArchs );

//*** Add Winlayout to 0-archive
  if VWList <> nil then begin
    CVWName := '';
    FrSetCaption := '';
    UDMVVWFrameSet := nil;
    FrSetName := '';
    SL.Add('GTVWM = new TVWLayout();');
    for i := 0 to VWList.Count - 1 do begin
      UDMVVWindow := TK_UDMVVWindow(VWList.Objects[i]);
      if UDMVVWindow is TK_UDMVVWindow then begin
    //*** add separate window data
        with TK_PMVVWindow(UDMVVWindow.R.P)^ do begin
          FrSetCaption := VWCaption;
          AddWinClaster();
          CVWName := VWName;
          WFlags := 0;
          if K_wofResizable  in ViewFlags.T then Inc(WFlags, 1);
          if K_wofScrollbars in ViewFlags.T then Inc(WFlags, 2);
          if K_wofMenubar    in ViewFlags.T then Inc(WFlags, 4);
          if K_wofToolbar    in ViewFlags.T then Inc(WFlags, 8);
          if K_wofLocation   in ViewFlags.T then Inc(WFlags, 16);
          if K_wofStatus     in ViewFlags.T then Inc(WFlags, 32);

          if K_wcfNewObjNewWin  in CreateFlags.T then Inc(WFlags, $100);
          if K_wcfAllObjNewWin  in CreateFlags.T then Inc(WFlags, $200);

          if K_wsfSkipFocusOnChange in ScriptFlags.T then Inc(WFlags, $1000);

          SL.Add( format( 'GTVWM.AddVWindow(0,"%s",%.2f,%.2f,%.2f,%.2f,0x%x);',
               [CVWName,Left,Top,Width,Height,WFlags] ));
        end;
      end;
      if UDMVVWindow is TK_UDMVVWFrameSet then begin
        if (UDMVVWFrameSet <> nil) and (UDMVVWFrameSet <> UDMVVWindow) then AddWinClaster( );
    //*** add frame window data
        UDMVVWFrameSet := TK_UDMVVWFrameSet(UDMVVWindow);
        FrVName := VWList[i];
        FrameNames := FrameNames + SepStr + '"'+FrVName+'"';
        if K_fmfShowDocTitle in TK_PMVVWFrame(TK_UDRArray(VWListF.Objects[i]).R.P).ModeFlags.T then
          ShowDocTitleData := ',1'
        else
          ShowDocTitleData := '';

        if FrSetName = '' then
          FrSetName := 'WC'+
             Copy( UDMVVWFrameSet.ObjName, 4, Length(UDMVVWFrameSet.ObjName) );
        SL.Add( 'GTVWM.AddVFrame(0,"'+FrVName+'","'+CVWName+'","'+FrSetName+'"'+
                ShowDocTitleData+');');
        SepStr := ',';
      end;
    end;
    AddWinClaster( );
  end;
//***

  CSArchs.ArchsList := TStringList.Create;
  CSArchs.ArchPref := CArchJSPref;
  CSArchs.CArchInd := -1;
  AddArchive( @CSArchs );

  MArchs.ArchsList := TStringList.Create;
  MArchs.ArchPref := MArchJSPref;
  MArchs.CArchInd := -1;

  WSL := TStringList.Create;
  WSL.Delimiter := ',';
  WSL.QuoteChar := ' ';
  WSL1 := TStringList.Create;
  WSL1.Delimiter := ',';
  WSL1.QuoteChar := ' ';
  WSL2 := TStringList.Create;
  WSL2.Delimiter := ',';
  WSL2.QuoteChar := ' ';

  //...
  CurMapInd  := 0;
  CurDCSInd  := 0;
  CurDCSSInd := 0;
  CurDVInd   := 0;
  CurHTMInd  := 0;
  CurColorsInd := 0;
  CurSVInd := 0;

  if AddWObjToArchive( RootUDObj, DArchs.CArch,
                       DArchs.CArchJSID, DArchs.CArchInd,
                       '', StartWWObj ) < 0 then begin
    Result := 'Не удалось опубликовать объект "'+RootUDObj.GetUName+'"';
    goto FreeData;
  end;

  with TStringList(DArchs.ArchsList.Objects[0]) do begin
//    Add('AU.'+JSObjs[RootUDObj.Marker - 1].JSO[0].JSID+'.Show(GTVWM)');
    if RootUDObj is TK_UDMVWWinGroup then
      SepStr := ''
    else
      SepStr := ',"'+AVWinName+'"';
    Add('AU.'+JSObjs[RootUDObj.Marker - 1].JSO[0].JSID+'.Show(GTVWM'+SepStr+')');
    if (StartWWObj <> nil)        and
       (StartWWObj <> RootUDObj)  and
       (StartWWObj.Marker <> 0) then begin
      if StartWWObj is TK_UDMVWWinGroup then
        SepStr := ''
      else
        SepStr := ',"'+AVWinName+'"';
      Add('AU.'+JSObjs[StartWWObj.Marker - 1].JSO[0].JSID+'.Show(GTVWM'+SepStr+')');
    end;
  end;

// Add Strings to Data Archives
  for i := 0 to DArchs.ArchsList.Count - 1 do
    AddStringsToArchive( i );

//  K_UDOwnerChildsScan := true;
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsOwnerChildsOnlyScan];
{//??}  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan];
  K_CurArchive.UnMarkSubTree;
{//??}  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsOwnerChildsOnlyScan];
//  K_UDOwnerChildsScan := false;

// Build All Archives List
  ArchivesList.AddStrings(DArchs.ArchsList);
  ArchivesList.AddStrings(CSArchs.ArchsList);
  ArchivesList.AddStrings(MArchs.ArchsList);

// Build Start Archives List
  StartArchivesList.Add(DArchs.ArchsList[0]);  // Add 1-st Data  Archive
  StartArchivesList.Add(CSArchs.ArchsList[0]); // Add 1-st CS/CSS  Archive
  if CSArchs.ArchsList.Count > 2 then
    StartArchivesList.Add(CSArchs.ArchsList[1]); // Add 2-nd CS/CSS  Archive with Map CS/CSS
  if MArchs.ArchsList.Count > 1 then
    StartArchivesList.Add(MArchs.ArchsList[0]);  // Add Small Map  Archive
  if MArchs.ArchsList.Count > 2 then
    StartArchivesList.Add(MArchs.ArchsList[1]);  // Add Zoomed Map Archive

FreeData:
  // Free Used Objects
  JSObjs := nil;
  K_FreeTListObjects(ListOfLists);
  ListOfLists.Free;
//  for i := 0 to ListOfLists.Count - 1 do
//    TObject(ListOfLists[i]).Free;
//  ListOfLists.Free;
  WSL.Free;
  WSL1.Free;
  WSL2.Free;
//  WWGroupPathList.Free;
  ComTextsList.Free;
  DArchs.ArchsList.Free;
  CSArchs.ArchsList.Free;
  MArchs.ArchsList.Free;
  JSObjNamesList.Free;
  VWList.Free;
  VWListF.Free;
//  WClasterFNamesList.Free;

end; // end of procedure TK_WebSiteBuilder1.BuildJSArchives

//********************************************** TK_WebSiteBuilder1.CopyMapFile
//
procedure TK_WebSiteBuilder1.CopyMapFile(MapFName: string);
begin
//  K_CopyFile( SrcMapsDir + MapFName, MapBase + MapFName );
  K_VFCopyFile( SrcMapsDir + MapFName, MapBase + MapFName, K_DFCreatePlain );
end; // end of procedure TK_WebSiteBuilder1.CopyMapFile

//********************************************** TK_WebSiteBuilder1.BuildDestFileName
//
function TK_WebSiteBuilder1.BuildDestFileName( SrcFName: string  ) : string;
begin
  Result := SrcFName;
  if K_IfURLReference( SrcFName ) or
     not K_IfExpandedFileName( SrcFName ) then Exit;
  Result := ExtractFileName(SrcFName);
end; // end of function TK_WebSiteBuilder1.BuildDestFileName

//********************************************** TK_WebSiteBuilder1.CopyExtHTMFile
//
procedure TK_WebSiteBuilder1.CopyExtHTMFile( SrcFName: string; DestFName: string; SiteLocalPath : string = '' );
var
//  CopyResult : Integer;
  MacroReplace : Boolean;
  DumpLine : string;
begin
  DumpLine := '';
  MacroReplace := false;
  if K_IfURLReference( SrcFName ) then Exit;
{
  if not K_IfExpandedFileName( SrcFName ) then begin// local file path ( for help )
    SrcFName := K_ExpandFileNameByIniDir( 'UserHTM', SrcFName );
    if not FileExists( SrcFName ) then begin
    //*** special text - help, ... etc. MacroReplace - old Specal Text - not used now
      SrcFName := K_ExpandFileNameByIniDir('HTMSTextsDir', DestFName );
      MacroReplace := true;
    end;
  end;
}
  SrcFName := K_VFExpandFileNameByDirPath( 'UserHTM', SrcFName );
  if not K_VFileExists( SrcFName ) then begin
  //*** special text - help, ... etc. MacroReplace - old Specal Text - not used now
    SrcFName := K_VFExpandFileNameByDirPath('HTMSTextsDir', DestFName );
    MacroReplace := true;
  end;

  DestFName := HTMBase + SiteLocalPath + DestFName;
//  CopyResult := K_CopyFile( SrcFName, DestFName );
{
  CopyResult := K_CopyFile( SrcFName, DestFName, true );
  // 2 - source not exists, 3 - couldn't copy, 4 - couldn'y create path
  case CopyResult of
  2 : DumpLine := 'Отсутствует файл '+SrcFName;
  3 : DumpLine := 'Невозможно переписать '+SrcFName+' в '+DestFName;
  4 : DumpLine := 'Невозможно создать путь для '+SrcFName;
}
  case K_VFCopyFile( SrcFName, DestFName, K_DFCreatePlain, [K_vfcOverwriteNewer] ) of
  K_vfcrSrcNotFound   : DumpLine := 'Отсутствует файл '+SrcFName;
  K_vfcrReadSrcError  : DumpLine := 'Невозможно переписать '+SrcFName+' в '+DestFName;
  K_vfcrDestPathError : DumpLine := 'Невозможно создать путь для '+SrcFName;
  else
    if MacroReplace then begin
//      SL.LoadFromFile( DestFName );
      K_VFLoadStrings( SL, DestFName );
      K_SListMListReplace( SL, ML, K_ummRemoveMacro );
      K_StringsSaveToFile( DestFName, SL, FEncodeMode );
    end;
//--    K_CopyHTMLinkedFiles( DestFName, HTMBase );
//    K_CopyHTMLinkedFiles( SrcFName, HTMBase );
//    K_CopyHTMLinkedVFiles( SrcFName, HTMBase );
    K_CopyHTMLinkedVFiles( SrcFName, ExtractFilePath(DestFName) );
  end;
  if DumpLine <> '' then DumpLine := WarnPrefix + DumpLine;
  ShowDump(DumpLine, K_msWarning, true);
end; // end of procedure TK_WebSiteBuilder1.CopyExtHTMFile

//********************************************** TK_WebSiteBuilder1.BuildWObjJSID
//
procedure TK_WebSiteBuilder1.BuildWObjJSID(WSObj: TN_UDBase;
  AObjDefID: string);
var
  ObjPref : string;
begin

  case K_MVDarGetUserNodeType( WSObj ) of
    K_msdWebLDiagramWins: ObjPref := TVHJSIDPref;
    K_msdWebTableWins   : ObjPref := TVTJSIDPref;
    K_msdWebWinGroups   : ObjPref := TVGJSIDPref;
    K_msdWebHTMWins     :;
    K_msdWebHTMRefWins  :;
    K_msdWebVHTMWins    :;
    K_msdWebVHTMRefWins : ObjPref := TVHTMJSIDPref;
    K_msdWebVTreeWins   : ObjPref := TVTreeJSIDPref;
    K_msdWebCartGroupWins: ObjPref := TVGMJSIDPref;
    K_msdWebCartWins: ObjPref := TVMJSIDPref;
  else
  end;
  with JSObjs[WSObj.Marker - 1] do begin
    JSBID := BuildJSID(WSObj, AObjDefID );
    JSO[0].JSID := NewJSName( ObjPref + JSBID );
  end;
end; // end of procedure TK_WebSiteBuilder1.BuildWObjJSID

//********************************************** TK_WebSiteBuilder1.AddWObjToArchive
//
function TK_WebSiteBuilder1.AddWObjToArchive( WSObj : TN_UDBase;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID : string = '';
               StartWWinObj : TN_UDBase = nil ) : Integer;
var
  SysType : TK_MVDARSysType;
begin
  SysType := K_MVDarGetUserNodeType( WSObj );
  Result := -1;

//  GetDataArchive( DArch, DArchID, DArchInd );
  case SysType of
    K_msdWebLDiagramWins: Result := AddWLDiagramToArchive(
      TK_UDMVWLDiagramWin(WSObj), DArch, DArchID, DArchInd, AObjDefID );
    K_msdWebTableWins   : Result := AddWTableToArchive( TK_UDMVWTableWin(WSObj), DArch, DArchID, DArchInd, AObjDefID );
    K_msdWebWinGroups: Result := AddWWinGroupToArchive(
      TK_UDMVWWinGroup(WSObj), DArch, DArchID, DArchInd, AObjDefID );
    K_msdWebHTMWins:;
    K_msdWebHTMRefWins: Result := AddWHTMRefToArchive(WSObj, DArch, DArchID, DArchInd, AObjDefID);
    K_msdWebVHTMWins:;
    K_msdWebVHTMRefWins: Result := AddWVHTMRefToArchive(WSObj, DArch, DArchID, DArchInd, AObjDefID);
    K_msdWebVTreeWins: Result := AddWVTreeToArchive(
      TK_UDMVWVTreeWin(WSObj), DArch, DArchID, DArchInd, AObjDefID, StartWWinObj );
    K_msdWebCartGroupWins: Result := AddWCartGroupToArchive(
      TK_UDMVWCartGroupWin(WSObj), DArch, DArchID, DArchInd, AObjDefID);
    K_msdWebCartWins: Result := AddWCartToArchive(
      TK_UDMVWCartWin(WSObj), DArch, DArchID, DArchInd, AObjDefID);
  else
  end;
end; // end of procedure TK_WebSiteBuilder1.AddWObjToArchive

//**************************** TK_WebSiteBuilder1.AddWLDiagramToArchive
//
function TK_WebSiteBuilder1.AddWLDiagramToArchive( UDMVWLDiagram : TK_UDMVWLDiagramWin;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID : string = '' ) : Integer;
var
  JSInd, CSPInd, h, i, n : Integer;
  StrPar : string;
  UDMVTable : TK_UDMVTable;
  PMVWebSection : TK_PMVWebSection;
  FixInds : TN_IArray;
  BCSS : TK_UDDCSSpace;
  CSPName : string;
  DefJSPref : string;
  ArchsList : string;
  WSL3 : TStringList;
begin
  h := UDMVWLDiagram.DirHigh;
  Result := -1;
  CheckUDMVWObjVWName( UDMVWLDiagram );
  if (h < 0) then Exit;
  UDMVTable := TK_UDMVTable(UDMVWLDiagram.DirChild(0));
  if not AddVObject( UDMVWLDiagram, DArchID, Result ) then Exit;
  BCSS := nil;
  with TK_PMVWebLDiagramWin(UDMVWLDiagram.R.P)^ do begin
    with JSObjs[Result] do begin
      if not Rebuild then BuildWObjJSID(UDMVWLDiagram, AObjDefID );
      Rebuild := false;
      BuildWSLs( @WSL3 );
      WSL.Clear;
      WSL1.Clear;
      n := UDMVTable.GetSubTreeChildHigh;
      PMVWebSection :=TK_PMVWebSection(Sections.P(0));
      for i := 0 to n do begin
        DefJSPref := JSBID+IntToStr(i);
        JSInd := AddMVTVectorToArchive( UDMVTable, i, DefJSPref );
        if i = 0 then
          BCSS := TK_UDDCSSpace(TK_PMVVector(TK_UDRArray(JSObjs[JSInd].UDB).R.P).CSS);
        WSL.Add( '"'+JSObjs[JSInd].JSO[0].JSID+'"' );
        AddToNOL(JSO[0], JSObjs[JSInd].JSO[0]);
        with TK_PMVVector(TK_UDRArray(JSObjs[JSInd].UDB).R.P)^ do
          case PMVWebSection.WENType.T of
            K_gecWEFull   : StrPar := FullCapt;
            K_gecWEBrief  : StrPar := BriefCapt;
            K_gecWEParent : StrPar := PString(PMVWebSection.WECapts.P(i))^;
          end;
        WSL3.Add( AddComText( StrPar, DArchInd, JSO[0].ASN ) );

        JSInd := AddMVTVectorAttrsToArchive( UDMVTable, i, DefJSPref );
        WSL1.Add( '"'+JSObjs[JSInd].JSO[0].JSID+'"' );
        AddToNOL(JSO[0], JSObjs[JSInd].JSO[0]);
      end;
// Data To Data projection
      CSPName := '';
      if CSProj1 <> nil then begin
        CSPInd := AddProjToArchive( TK_UDVector(CSProj1) );
        CSPName := JSObjs[CSPInd].JSO[0].JSID;
        AddToNOL(JSO[0], JSObjs[CSPInd].JSO[0]);
      end;
// add descriptor
      DArch.Add( 'TUC(TVH,"'+JSO[0].JSID+'",' );
      with TK_PMVTable(UDMVTable.R.P)^ do
        case SCType.T of
          K_gecWEFull   : StrPar := FullCapt;
          K_gecWEBrief  : StrPar := BriefCapt;
          K_gecWEParent : StrPar := PMVWebSection.Caption;
        end;
      DArch.Add( AddComText( StrPar, DArchInd, JSO[0].ASN ) + ',' );
      DArch.Add( '"'+VWinName+'",' );
      DArch.Add( '['+WSL.DelimitedText + '],' );
      DArch.Add( '['+WSL1.DelimitedText + '],' );
  // Captions  + aliase name
  //  + [archives]
      ArchsList := BuildArchivesList(@JSO[0]);
      DArch.Add( '['+WSL3.DelimitedText + '],"",['+
      ArchsList+'],"'+
  // Data To Data projection
      CSPName+'",' );
  // add FixNums
      WSL3.Clear;
      if PECSS <> nil then begin
        SetLength( FixInds, TK_UDDCSSpace(PECSS).PDRA.ALength );
        K_BuildDataProjectionByCSProj( BCSS, TK_UDDCSSpace(PECSS), @FixInds[0], nil );
        for i := 0 to High(FixInds)do
          WSL3.Add( IntToStr( FixInds[i] ) );
      end;
  // ShowFlags
      StrPar := ');';
      if ShowFlags.R <> 0 then
        StrPar := ','+IntToStr(ShowFlags.R)+StrPar;
      DArch.Add( '['+WSL3.DelimitedText+']'+StrPar );
    end;
  end;
  WSL3.Free;
end; // end of function TK_WebSiteBuilder1.AddWLDiagramToArchive

//**************************** TK_WebSiteBuilder1.AddWTableToArchive
//
function TK_WebSiteBuilder1.AddWTableToArchive( UDMVWTable : TK_UDMVWTableWin;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID : string = '' ) : Integer;
var
  JSInd, SCSSInd, h, i, n : Integer;
  StrPar : string;
  UDMVTable : TK_UDMVTable;
  PMVWebSection : TK_PMVWebSection;
  SCSSName : string;
  DefJSPref : string;
  WSL3 : TStringList;
  WSL4 : TStringList;
begin
  h := UDMVWTable.DirHigh;
  Result := -1;
  CheckUDMVWObjVWName( UDMVWTable );
  if (h < 0) then Exit;
  UDMVTable := TK_UDMVTable(UDMVWTable.DirChild(0));
//  if not AddVObject( UDMVWTable, DArchs.CArchJSID, -1, Result ) then Exit;
  if not AddVObject( UDMVWTable, DArchID, Result ) then Exit;
  with TK_PMVWebTableWin(UDMVWTable.R.P)^ do begin
    with JSObjs[Result] do begin
      if not Rebuild then BuildWObjJSID(UDMVWTable, AObjDefID );
      Rebuild := false;
// Data To Data projection
      SCSSName := '';
      if SCSS <> nil then begin
        SCSSInd := AddDCSSToArchive( TK_UDDCSSpace(SCSS), true );
        SCSSName := JSObjs[SCSSInd].JSO[0].JSID;
        AddToNOL(JSO[0], JSObjs[SCSSInd].JSO[0]);
      end;
      BuildWSLs( @WSL3 );
      WSL.Clear;
      WSL1.Clear;
      n := UDMVTable.GetSubTreeChildHigh;
      PMVWebSection :=TK_PMVWebSection(Sections.P(0));
      for i := 0 to n do begin
        DefJSPref := JSBID+IntToStr(i);
        JSInd := AddMVTVectorToArchive( UDMVTable, i, DefJSPref );
        WSL.Add( '"'+JSObjs[JSInd].JSO[0].JSID+'"' );
        AddToNOL(JSO[0], JSObjs[JSInd].JSO[0]);
        with TK_PMVVector(TK_UDRArray(JSObjs[JSInd].UDB).R.P)^ do
          case PMVWebSection.WENType.T of
            K_gecWEFull   : StrPar := FullCapt;
            K_gecWEBrief  : StrPar := BriefCapt;
            K_gecWEParent : StrPar := PString(PMVWebSection.WECapts.P(i))^;
          end;
        WSL3.Add( AddComText( StrPar, DArchInd, JSO[0].ASN ) );

        JSInd := AddMVTVectorAttrsToArchive( UDMVTable, i, DefJSPref );
        WSL1.Add( '"'+JSObjs[JSInd].JSO[0].JSID+'"' );
        AddToNOL(JSO[0], JSObjs[JSInd].JSO[0]);
      end;
// Data To Data projection

      BuildWSLs( @WSL4 );
      n := DCSProjs.AHigh;
      for i := 0 to n do begin
        SCSSInd := AddProjToArchive( TK_UDVector(TN_PUDBase(DCSProjs.P(i))^) );
        WSL4.Add( '"'+JSObjs[SCSSInd].JSO[0].JSID+'"' );
        AddToNOL(JSO[0], JSObjs[SCSSInd].JSO[0]);
      end;

// add descriptor
      DArch.Add( 'TUC(TVT,"'+JSO[0].JSID+'",' );
      with TK_PMVTable(UDMVTable.R.P)^ do
        case SCType.T of
          K_gecWEFull   : StrPar := FullCapt;
          K_gecWEBrief  : StrPar := BriefCapt;
          K_gecWEParent : StrPar := PMVWebSection.Caption;
        end;
    
      DArch.Add( AddComText( StrPar, DArchInd, JSO[0].ASN ) + ',' );
      DArch.Add( '"'+VWinName+'",' );
      DArch.Add( '['+WSL.DelimitedText + '],' );
      DArch.Add( '['+WSL1.DelimitedText + '],' );

      StrPar := ');';
      if ShowFlags.R <> 0 then
        StrPar := ','+IntToStr(ShowFlags.R)+StrPar;

  // Captions
      DArch.Add( '['+WSL3.DelimitedText + '],'+
  // RCaption  + aliase name
      AddComText( SHCaption, DArchInd, JSO[0].ASN )+',"",['+
  //  + [archives]
      BuildArchivesList(@JSO[0])+'],"'+
  // Special Rows CSS
      SCSSName+'",['+
  // CSS hierarchy + ShowFlags
      WSL4.DelimitedText+']'+ StrPar );
    end;
  end;
  WSL3.Free;
  WSL4.Free;
end; // end of function TK_WebSiteBuilder1.AddWTableToArchive

//**************************** TK_WebSiteBuilder1.AddWCartToArchive
//
function TK_WebSiteBuilder1.AddWCartToArchive(
               UDMVWCart: TK_UDMVWCartWin;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID : string = '' ): Integer;
var
  CMInd : Integer;
  CDMPInd : Integer;
  UDML : TN_UDBase;
  str : string;
begin

//  if not AddVObject( UDMVWCart, DArchs.CArchJSID, -1, Result ) then Exit;
  Result := -1;
  CheckUDMVWObjVWName( UDMVWCart );
  if not AddVObject( UDMVWCart, DArchID, Result ) then Exit;
  with TK_PMVWebCartWin(UDMVWCart.R.P)^ do begin
    UDML := UDMVWCart.DirChild(0);
    with TK_PMVCartLayer1(TK_UDRArray(UDML).R.P)^ do begin

      AddMVTVectorToArchive0( UDMVVector, '' );
      AddMVTVectorAttrsToArchive0( TK_UDRArray(UDMVVAttrs), '' );

      CMInd := AddMapToArchive( TK_UDMVMapDescr(WCWUDMapDescr) );
      if DCSPML <> nil then
        CDMPInd := AddProjToArchive( TK_UDVector(DCSPML) )
      else
        CDMPInd := -1;
      with JSObjs[Result] do begin
  // Add TVM1 descriptor
        if not Rebuild then BuildWObjJSID(UDMVWCart, AObjDefID );
        Rebuild := false;
        AddToNOL(JSO[0], JSObjs[CMInd].JSO[0]); // Add Small Map to TVM1 Object
        AddToNOL(JSO[0], JSObjs[CMInd].JSO[1]); // Add Big Map to TVM1 Object
        if CDMPInd >= 0 then
          AddToNOL(JSO[0], JSObjs[CDMPInd].JSO[0]);// Add Data to Map Projection to TVM1 Object
   // prepare tvms
        DArch.Add( 'var tvms = new TVMS();' );
        if LegHeader = '' then
          DArch.Add( 'tvms.LEHide=true;' )
        else begin
          if LEColNum <> 0 then
            DArch.Add( 'tvms.LEColNum='+IntToStr(LEColNum) );
          if LERowNum <> 0 then
            DArch.Add( 'tvms.LERowNum='+IntToStr(LERowNum) );
        end;

        DArch.Add( 'TUC(TVM1,"'+JSO[0].JSID+'",-1,' );
  // Virtual Window Name
        DArch.Add( '"'+VWinName+'",' );
  // Add String Fields
  // Page Name
        DArch.Add( AddComText( PageCaption, DArchInd, JSO[0].ASN ) + ',' );
  // Legend Header
        if LegHeader = '' then DArch.Add( '-1,' )
        else DArch.Add( AddComText( LegHeader, DArchInd, JSO[0].ASN ) + ',' );
  // Legend Footer
        if LegFooter = '' then DArch.Add( '-1,' )
        else DArch.Add( AddComText( LegFooter, DArchInd, JSO[0].ASN ) + ',' );
        DArch.Add( '"'+JSObjs[UDMVVector.Marker-1].JSO[0].JSID+'","'+
                              JSObjs[UDMVVAttrs.Marker-1].JSO[0].JSID+'",' );
        DArch.Add( '"",["'+JSObjs[CMInd].JSO[0].JSID+'","'+
                                 JSObjs[CMInd].JSO[1].JSID+'"],' );
        if CDMPInd >= 0 then
          str := JSObjs[CDMPInd].JSO[0].JSID
        else
          str := '';
        DArch.Add( '"'+str+'",' );
        DArch.Add( '['+ BuildArchivesList(@JSO[0])+']'+
        ',tvms);' );
      end;
    end;
  end;

end; // end of function TK_WebSiteBuilder1.AddWCartToArchive

//**************************** TK_WebSiteBuilder1.AddWCartGroupToArchive
//
function TK_WebSiteBuilder1.AddWCartGroupToArchive(
               UDMVWCartGroup: TK_UDMVWCartGroupWin;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID : string = '' ): Integer;
var
  i, h, JSInd : Integer;
  WSL3 : TStringList;
  SectRoot : TN_UDBase;
begin
// TVGMap
  Result := -1;
  CheckUDMVWObjVWName( UDMVWCartGroup );
  if not AddVObject( UDMVWCartGroup, DArchID, Result ) then Exit;
  with TK_PMVWebCartGroupWin(UDMVWCartGroup.R.P)^ do begin
    with JSObjs[Result] do begin
      if not Rebuild then BuildWObjJSID(UDMVWCartGroup, AObjDefID );
      Rebuild := false;
      BuildWSLs( @WSL3 );
      with UDMVWCartGroup do begin
        h := DirHigh;
        SectRoot := DirChild(0);
        if SectRoot is TK_UDMVWCartWin then
          SectRoot := UDMVWCartGroup;
        with SectRoot do
          for i := 0 to h do begin
            JSInd := AddWCartToArchive( TK_UDMVWCartWin( DirChild(i) ),
              DArch, DArchID, DArchInd );
            WSL3.Add( '"'+JSObjs[JSInd].JSO[0].JSID+'"' );
            AddToNOL(JSO[0], JSObjs[JSInd].JSO[0]);
          end;
      end;
      DArch.Add( 'TUC(TVGM,"'+JSO[0].JSID+'",-1,"'+VWinName+'",['+
           WSL3.DelimitedText+'],"'+MVWinName+'",['+
           BuildArchivesList( @JSO[0] )+']);' );
    end;
  end;
  WSL3.Free;
end; // end of function TK_WebSiteBuilder1.AddWCartGroupToArchive

//**************************** TK_WebSiteBuilder1.AddWWinGroupToArchive
//
function TK_WebSiteBuilder1.AddWWinGroupToArchive(
               UDMVWWinGroup: TK_UDMVWWinGroup;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID : string = '' ): Integer;
  var
    WJSID : string;
    JSInd, i : Integer;
    IndH : Integer;
    WrkVWName : string;
    ErrStr1 : string;
    GObj : TN_UDBase;
  begin
//    CDIInd := 0;
  if AddVObject( UDMVWWinGroup, DArchID, Result ) then begin
    ErrStr1 := ' группы '+UDMVWWinGroup.GetUName;
    with TK_PMVWebWinGroup(UDMVWWinGroup.R.P)^ do begin
      with JSObjs[Result] do begin
        if not Rebuild then BuildWObjJSID(UDMVWWinGroup, AObjDefID );
        Rebuild := false;
        AddArchive( @DArchs );
        JSO[0].AVN := DArchs.CArchJSID;
        WSLWWGroup.Clear;
    // Group TVC
        WrkVWName := TVWinName;
//        if WrkVWName = '' then WrkVWName := TVGroupCaptWindow;
        if WrkVWName <> '' then begin
          CheckVWName( WrkVWName, ' заголовка ' + ErrStr1 );
          WJSID := TVCJSIDPref+JSBID;
          WSLWWGroup.Add( WJSID+':"'+WrkVWName+'"' );
//??          JSO[0].AVN := DArchs.CArchJSID;
          DArchs.CArch.Add( 'TUC(TVC,"'+WJSID+'",'+AddComText( Title, DArchs.CArchInd, JSO[0].ASN )+');' );
        end;
        IndH := UDMVWWinGroup.DirHigh;
    // check if indicators can be shown as table-menu
        for i := 0 to IndH do begin
          GObj := UDMVWWinGroup.DirChild(i);
          JSInd := AddWObjToArchive( GObj,
            DArchs.CArch, DArchs.CArchJSID, DArchs.CArchInd, JSBID + IntToStr(i) );
          if JSInd = -1 then Continue;
          WrkVWName := TK_PMVWebWinGroupElem(WGEAttribs.P(i)).EVWinName;
          CheckVWName( WrkVWName, ' для объекта '+GObj.GetUName+ErrStr1 );
          WSLWWGroup.Add( JSObjs[JSInd].JSO[0].JSID+':"'+WrkVWName+'"' );
        end;
        // clear last
//        wstr := WSLWWGroup[WSLWWGroup.Count-1];
//        WSLWWGroup[WSLWWGroup.Count-1] := Copy(wstr,1, Length(wstr)-1);

      // TVGroup Description
        DArch.Add( 'TUC(TVGroup,"'+JSO[0].JSID+'",-1,"",['+
                 BuildArchivesList( @JSO[0] )+'],{' );
//        DArch.AddStrings( WSLWWGroup );
//        DArch.AddStrings( WSLWWGroup );
        DArch.Add( WSLWWGroup.DelimitedText+'});' );
      end;
    end;
  end;
end; // end of function TK_WebSiteBuilder1.AddWWinGroupToArchive

//**************************** TK_WebSiteBuilder1.AddWVTreeToArchive
//
function TK_WebSiteBuilder1.AddWVTreeToArchive(
            UDMVWVTreeWin: TK_UDMVWVTreeWin;
            DArch : TStringList; DArchID : string; DArchInd : Integer;
            AObjDefID : string = '';
            StartWWinObj : TN_UDBase = nil ): Integer;
var
  WWStartObjPathList : TStringList;
  WWStartObjPath : string;
  FUDRoot : TN_UDBase;
  k, n, sn : Integer;
  FVWinName : string;
  RootLevelWTree : Boolean;
  PMVWebWinObj : TK_PMVWebWinObj;

  procedure SightLevelBuild( LRoot : TN_UDBase; WWGroupPathInd : Integer; ObjDefID : string );
  var
    i,h,CInd : Integer;
    CUDChild : TN_UDBase;
    wstr1 : string;
    listSeparator : string;
    CObjDefID : string;
    ChildCapt : string;
    IconInd : string;

  begin
    h := LRoot.DirHigh;
    listSeparator := '';
    for i := 0 to h do begin
      CUDChild := LRoot.DirChild(i);
      CObjDefID := ObjDefID + IntToStr(i);
      with TK_PMVWebFolder(TK_UDRArray(LRoot).R.P)^ do begin
        if CUDChild is TK_UDMVWVHTMWin then
          PMVWebWinObj := TK_PMVWebWinObj(@TK_PMVWebVHTMWin(TK_UDRArray(CUDChild).R.P).FullCapt)
        else
          PMVWebWinObj := TK_PMVWebWinObj(TK_UDRArray(CUDChild).R.P);
        with PMVWebWinObj^ do
        case WENType.T of
          K_gecWEFull   : ChildCapt := FullCapt;
          K_gecWEBrief  : ChildCapt := BriefCapt;
          K_gecWEParent : ChildCapt := PString(WECapts.P(i))^;
        end;
      end;
      if CUDChild.CI = K_UDMVWFolderCI then begin
        AddVObject( CUDChild, DArchID, CInd );
        DArch.Add( listSeparator+'[[' );
        SightLevelBuild( CUDChild, WWGroupPathInd + 1, CObjDefID );
        wstr1 := '';
        if (WWStartObjPathList.Count > WWGroupPathInd) and
           (CUDChild.ObjName = WWStartObjPathList[WWGroupPathInd]) then wstr1 := ',1';
        DArch.Add( '],'+
          AddComText( ChildCapt, DArchInd, JSObjs[CInd].JSO[0].ASN )+
          ',0,""'+wstr1+']' );
      end else begin
        AddVObject( CUDChild, DArchID, CInd );
        with JSObjs[CInd] do begin
          if not Rebuild then BuildWObjJSID(CUDChild, CObjDefID );
          Rebuild := true;
          wstr1 := '';
          if CUDChild = StartWWinObj then wstr1 := ',0,1,1';
          case CUDChild.CI of
            K_UDMVWWinGroupCI    : IconInd := '1';
            K_UDMVWHTMWinCI, K_UDMVWVHTMWinCI
                                 : IconInd := '2';
            K_UDMVWTableWinCI    : IconInd := '3';
            K_UDMVWLDiagramWinCI : IconInd := '4';
            K_UDMVWCartGroupWinCI: IconInd := '5';
            K_UDMVWCartWinCI     : IconInd := '6';
          end;
          DArch.Add( listSeparator+'[[],'+
            AddComText( ChildCapt, DArchInd, JSO[0].ASN )+
            ','+IconInd+',"'+JSO[0].JSID+'"'+wstr1+']' );
        end;
      end;
      listSeparator := ',';
    end; // end of level loop
  end;

begin

  RootLevelWTree := RootUDObj = UDMVWVTreeWin;
  if not RootLevelWTree then begin
    AddArchive( @DArchs );
    DArch := DArchs.CArch;
    DArchID := DArchs.CArchJSID;
    DArchInd := DArchs.CArchInd;
  end;

  if not AddVObject( UDMVWVTreeWin, DArchID, Result ) then Exit;
  with TK_PMVWebVTreeWin(UDMVWVTreeWin.R.P)^ do begin
    sn := JSObjsFillInd;
    if StartWWinObj = nil then
      StartWWinObj := UDWWinObj;
    FUDRoot := UDMVWVTreeWin.DirChild(0);
    WWStartObjPath := '';
    if FUDRoot <> nil then
      WWStartObjPath := K_GetPathToUObj( StartWWinObj, FUDRoot );

    WWStartObjPathList := TStringList.Create;
    WWStartObjPathList.Delimiter := K_udpPathDelim;
    WWStartObjPathList.DelimitedText := WWStartObjPath;
    with JSObjs[Result] do begin
      if not Rebuild then BuildWObjJSID(UDMVWVTreeWin, AObjDefID );
      Rebuild := false;
      JSO[0].AVN := DArchs.CArchJSID;
// add TVTree description
      FVWinName := VWinName;
      if FVWinName = '' then FVWinName := VTreeVWin;
      CheckVWName( FVWinName, ' для объекта '+UDMVWVTreeWin.GetUName );

      DArch.Add( 'TUC(TVTree,"'+JSO[0].JSID+'",-1,"'+FVWinName+'",['+
        BuildArchivesList( @JSO[0] )+']).Set([' );
      SightLevelBuild( FUDRoot, 0, AObjDefID );
      DArch.Add( ']);' );
//      DArch.Add( ']).Show(GTVWM,"FTree");' );
    end;
    WWStartObjPathList.Free;
    AddWObjToArchive( StartWWinObj, DArch, DArchID, DArchInd );
    k := JSObjsFillInd - 1;
    N_PBCaller.Start( k );
    for n := sn to k do begin
      if JSObjs[n].UDB.CI <> K_UDMVWFolderCI then
        AddWObjToArchive( JSObjs[n].UDB, DArch, DArchID, DArchInd, '', StartWWinObj );
      if RootLevelWTree then
        N_PBCaller.Update( n );
    end;
  end;
//        CInd := AddWObjToArchive( CUDChild, DArch, DArchID, DArchInd, CObjDefID, StartWWinObj );
end; // end of function TK_WebSiteBuilder1.AddWVTreeToArchive

//**************************** TK_WebSiteBuilder1.AddWHTMRefToArchive
//
function TK_WebSiteBuilder1.AddWHTMRefToArchive(WSObj: TN_UDBase;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID: string): Integer;
var
  TitleInd,SrcFileName,DestFileName : string;
begin
  Result := -1;
  CheckUDMVWObjVWName( TK_UDMVWBase(WSObj) );

  if AddVObject( WSObj, DArchID, Result ) then begin
    with TK_PMVWebHTMRefWin(TK_UDRArray(WSObj).R.P)^ do begin
      SrcFileName := K_ReplaceDirMacro(RHTMPath);
      DestFileName := BuildDestFileName( SrcFileName  );
      with JSObjs[Result] do begin
        if not Rebuild then BuildWObjJSID(WSObj, AObjDefID );
        Rebuild := false;
        if Title = '' then
          TitleInd := '-1'
        else
          TitleInd := AddComText( Title, DArchs.CArchInd, JSO[0].ASN );
        DArch.Add( 'TUC(TVHTM,"'+JSO[0].JSID+'",'+TitleInd+',"'+VWinName+'","'+
          DosPathToUnixPath(DestFileName)+'","",['+BuildArchivesList( @JSO[0] )+']);' );
      end;
      CopyExtHTMFile( SrcFileName, DestFileName );
    end;
  end;
end; // end of function TK_WebSiteBuilder1.AddWHTMRefToArchive

//**************************** TK_WebSiteBuilder1.AddWVHTMRefToArchive
//
function TK_WebSiteBuilder1.AddWVHTMRefToArchive(WSObj: TN_UDBase;
               DArch : TStringList; DArchID : string; DArchInd : Integer;
               AObjDefID: string): Integer;
var
  i, CSSInd : Integer;
  TitleInd,SrcFileName,DestFileName : string;
begin
  Result := -1;
  with TK_PMVWebVHTMWin(TK_UDRArray(WSObj).R.P)^ do begin
    CheckVWName( VWinName, ' для объекта '+WSObj.GetUName );

    CSSInd := AddDCSSToArchive( TK_UDVector(WSObj).GetDCSSpace, false );

    if AddVObject( WSObj, DArchID, Result ) then begin
      with JSObjs[Result] do begin
        if not Rebuild then BuildWObjJSID(WSObj, AObjDefID );
        Rebuild := false;
        AddToNOL(JSO[0], JSObjs[CSSInd].JSO[0]);
        WSL2.Clear;
        for i := 0 to D.AHigh do begin
          SrcFileName := K_ReplaceDirMacro( PString( D.P(i) )^ );
          DestFileName := BuildDestFileName( SrcFileName  );
          CopyExtHTMFile( SrcFileName, DestFileName );
          WSL2.Add( ''''+DosPathToUnixPath(DestFileName)+''''  );
        end;
        if Title = '' then
          TitleInd := '-1'
        else
          TitleInd := AddComText( Title, DArchs.CArchInd, JSO[0].ASN );

        DArch.Add( 'TUC(TVHTMV,"'+JSO[0].JSID+'",'+TitleInd+',"'+VWinName+'",['+
          WSL2.CommaText+'],"'+JSObjs[CSSInd].JSO[0].JSID+
          '","",['+BuildArchivesList( @JSO[0] )+'],'+IntToStr(StartEInd)+');' );
      end;
    end;
  end;
end; // end of function TK_WebSiteBuilder1.AddWVHTMRefToArchive

//**************************** TK_WebSiteBuilder1.AddMVTVectorToArchive0
//
function TK_WebSiteBuilder1.AddMVTVectorToArchive0( UDV : TN_UDBase;
            DefJSID : string ) : Integer;
var
  CSSInd : Integer;
  i,h : Integer;
  StrFieldsInds : string;
begin
//  if AddVObject( DE.Child, DArchs.CArchJSID, DArchs.CArchInd, Result ) then begin
  if AddVObject( UDV, DArchs.CArchJSID, Result ) then begin
      JSObjs[Result].JSBID := BuildJSID( UDV, DefJSID );
    with TK_PMVVector(TK_UDMVVector(UDV).R.P)^ do begin
     CSSInd := AddDCSSToArchive( TK_UDDCSSpace(CSS), true );
  // Add TVD descriptor
      with JSObjs[Result] do begin
        JSO[0].JSID := NewJSName( TVDJSIDPref+JSBID );
        AddToNOL(JSO[0], JSObjs[CSSInd].JSO[0]); // add DCSS object
  // Add String Fields
        StrFieldsInds :=
          AddComText( FullCapt, DArchs.CArchInd, JSO[0].ASN ) + ','+
          AddComText( BriefCapt, DArchs.CArchInd, JSO[0].ASN ) + ','+
          AddComText( Units, DArchs.CArchInd, JSO[0].ASN );
        DArchs.CArch.Add('TUC(TVD,"'+JSO[0].JSID+'","'+
           JSObjs[CSSInd].JSO[0].JSID+'",['+
           BuildArchivesList(@JSO[0])+']).Set([');
        h := D.AHigh;
  // Add Values
        WSL2.Clear;
        for i := 0 to h do WSL2.Add( FloatToStr( PDouble(D.P(i))^ ) );
        DArchs.CArch.Add( WSL2.CommaText+'],'+StrFieldsInds+');' );
      end;
    end;
  end;
end; // end of function TK_WebSiteBuilder1.AddMVTVectorToArchive0

//**************************** TK_WebSiteBuilder1.AddMVTVectorToArchive
//
function TK_WebSiteBuilder1.AddMVTVectorToArchive( UDMVTable : TK_UDMVTable;
            Ind : Integer; DefJSID : string ) : Integer;
var
  DE : TN_DirEntryPar;
//  CSSInd : Integer;
//  i,h : Integer;
//  StrFieldsInds : string;
begin
  UDMVTable.GetSubTreeChildDE( Ind, DE );
  Result := AddMVTVectorToArchive0( DE.Child, DefJSID );
{
//  if AddVObject( DE.Child, DArchs.CArchJSID, DArchs.CArchInd, Result ) then begin
  if AddVObject( DE.Child, DArchs.CArchJSID, Result ) then begin
      JSObjs[Result].JSBID := BuildJSID( DE.Child, DefJSID );
    with TK_PMVVector(TK_UDMVVector(DE.Child).R.P)^ do begin
     CSSInd := AddDCSSToArchive( TK_UDDCSSpace(CSS), true );
  // Add TVD descriptor
      with JSObjs[Result] do begin
        JSO[0].JSID := NewJSName( TVDJSIDPref+JSBID );
        AddToNOL(JSO[0], JSObjs[CSSInd].JSO[0]); // add DCSS object
  // Add String Fields
        StrFieldsInds :=
          AddComText( FullCapt, DArchs.CArchInd, JSO[0].ASN ) + ','+
          AddComText( BriefCapt, DArchs.CArchInd, JSO[0].ASN ) + ','+
          AddComText( Units, DArchs.CArchInd, JSO[0].ASN );
        DArchs.CArch.Add('TUC(TVD,"'+JSO[0].JSID+'","'+
           JSObjs[CSSInd].JSO[0].JSID+'",['+
           BuildArchivesList(@JSO[0])+']).Set([');
        h := D.AHigh;
  // Add Values
        WSL2.Clear;
        for i := 0 to h do WSL2.Add( FloatToStr( PDouble(D.P(i))^ ) );
        DArchs.CArch.Add( WSL2.CommaText+'],'+StrFieldsInds+');' );
      end;
    end;
  end;
}
end; // end of function TK_WebSiteBuilder1.AddMVTVectorToArchive

//**************************** TK_WebSiteBuilder1.AddMVTVectorAttrsToArchive0
//
function TK_WebSiteBuilder1.AddMVTVectorAttrsToArchive0( UDAttrs : TK_UDRArray;
          DefJSID : string ) : Integer;
var
//  UDAttrs : TK_UDRArray;
  CSSInd : Integer;
  ColorsInd : Integer;
  ColorsSetID : string;
  SVInd : Integer;
  i : Integer;
  AnSECSSName : string;
  AutoRangeValsMode : Integer;
begin
//  UDAttrs := UDMVTable.GetUDAttribs( Ind );
//  if AddVObject( UDAttrs, DArchs.CArchJSID, DArchs.CArchInd, Result ) then begin
  if AddVObject( UDAttrs, DArchs.CArchJSID, Result ) then begin
     JSObjs[Result].JSBID := BuildJSID( UDAttrs, DefJSID );
     with TK_PMVVAttrs(UDAttrs.R.P)^ do begin
       with JSObjs[Result] do begin
         JSO[0].JSID := NewJSName( TVAJSIDPref+JSBID );
         AnSECSSName := '';
         if AnSECSS <> nil then begin
           CSSInd := AddDCSSToArchive( TK_UDDCSSpace(AnSECSS), true );
           AddToNOL(JSO[0], JSObjs[CSSInd].JSO[0]); // add AnSECSS object
           AnSECSSName := JSObjs[CSSInd].JSO[0].JSID;
         end;
         if Pointer(@ColorsSet) = K_GetPVRArray( ColorsSet ) then begin
           ColorsSetID := '';
           ShowDump('Цветовая траектория атрибутов ' + K_GetPathToUObj( UDAttrs ) +
                    ' не ссылка на объект', K_msWarning, true);
         end else begin
           ColorsInd := AddUDColorsToArchive( TN_UDBase(ColorsSet) );
           AddToNOL(JSO[0], JSObjs[ColorsInd].JSO[0]); // add Colors object
           ColorsSetID := JSObjs[ColorsInd].JSO[0].JSID;
         end;

         SVInd := AddSValuesToArchive( UDSVAttrs );
         AddToNOL(JSO[0], JSObjs[SVInd].JSO[0]); // add SValues object

         with TK_PMVVAttrs(UDAttrs.R.P)^ do begin
           AutoRangeValsMode := AutoRangeType.R;
           if AutoRangeVals.T <> K_aumAuto then AutoRangeValsMode := -1;
           DArchs.CArch.Add( 'TUC(TVA,"'+JSO[0].JSID+'","'+
           // Spec Values
             JSObjs[SVInd].JSO[0].JSID+'","'+
           // Colors Set
//             JSObjs[ColorsInd].JSO[0].JSID+'","'+
             ColorsSetID+'","'+
           // AnSECSS
             AnSECSSName+'",['+
             BuildArchivesList(@JSO[0])+']).Set('+
           // AAbsSVInd
             IntToStr(AbsDCSESVIndex)+','+
           // ARangeType + AAutoRangeType
             IntToStr(ValueType.R)+','+IntToStr(AutoRangeValsMode)+','+
           // AAutoRangeCount + ARDPPos
             IntToStr(RangeCount)+','+IntToStr(RDPPos)+',' );
         // Range Values
           if AutoRangeVals.T <> K_aumAuto then begin
             WSL2.Clear;
             for i := 0 to RangeValues.AHigh do
               WSL2.Add( FloatToStr( PDouble( RangeValues.P(i) )^ ) );
             DArchs.CArch.Add( '['+WSL2.CommaText+'],' );
           end else
             DArchs.CArch.Add( '[],' );
         // AutoCaptsFormat  **??**
           DArchs.CArch.Add( '["'''+
             K_StringMListReplace( PString(AutoCaptsFormat.P(0))^, PatMacro, K_ummSaveMacroName )+'''","'''+
             K_StringMListReplace( PString(AutoCaptsFormat.P(1))^, PatMacro, K_ummSaveMacroName )+'''","'''+
             K_StringMListReplace( PString(AutoCaptsFormat.P(2))^, PatMacro, K_ummSaveMacroName )+'''"],' );
         // Range Captions
           if AutoRangeCapts.T <> K_aumAuto then begin
             WSL2.Clear;
             for i := 0 to RangeCaptions.AHigh do
               WSL2.Add( ''''+PString( RangeCaptions.P(i) )^+''''  );
             DArchs.CArch.Add( '['+WSL2.DelimitedText+'],' );
           end else
             DArchs.CArch.Add( '[],' );
         // Colors Type
           DArchs.CArch.Add(
             IntToStr(BuildColorsType.R)+','+IntToStr(ColorsSetOrder.R)+','+
             IntToStr(VDPPos)+',' );

         // PureVal Type
         DArchs.CArch.Add( IntToStr(PureValPatType.R)+',' );
         if PureValPatType.T = K_vttManual then
            DArchs.CArch.Add( '"'+PureValToTextPat+'",' )
          else
            DArchs.CArch.Add( '"",' );

         // NamedVal Type
          DArchs.CArch.Add( IntToStr(NamedValPatType.R)+',' );
          if NamedValPatType.T = K_vttManual then
            DArchs.CArch.Add( '"'+NamedValToTextPat+'",' )
          else
            DArchs.CArch.Add( '"",' );

           DArchs.CArch.Add(
             IntToStr(AutoMinMax.R)+','+
             FloatToStr(VMin)+','+
             FloatToStr(VMax)+',' );

           WSL2.Clear;
           for i := 0 to VDConv.AHigh do
             WSL2.Add( FloatToStr( PDouble( VDConv.P(i) )^ ) );
           DArchs.CArch.Add(
             '['+WSL2.DelimitedText+'],'+
             FloatToStr(VBase) + ');' );
         end;
       end;
     end;
  end;
end; // end of function TK_WebSiteBuilder1.AddMVTVectorAttrsToArchive

//**************************** TK_WebSiteBuilder1.AddMVTVectorAttrsToArchive
//
function TK_WebSiteBuilder1.AddMVTVectorAttrsToArchive( UDMVTable : TK_UDMVTable;
          Ind : Integer; DefJSID : string ) : Integer;
//var
//  UDAttrs : TK_UDRArray;
//  CSSInd : Integer;
//  ColorsInd : Integer;
//  SVInd : Integer;
//  i : Integer;
//  AnSECSSName : string;
begin
  Result := AddMVTVectorAttrsToArchive0( UDMVTable.GetUDAttribs( Ind ), DefJSID );
{
  UDAttrs := UDMVTable.GetUDAttribs( Ind );
//  if AddVObject( UDAttrs, DArchs.CArchJSID, DArchs.CArchInd, Result ) then begin
  if AddVObject( UDAttrs, DArchs.CArchJSID, Result ) then begin
     JSObjs[Result].JSBID := BuildJSID( UDAttrs, DefJSID );
     with TK_PMVVAttrs(UDAttrs.R.P)^ do begin
       with JSObjs[Result] do begin
         JSO[0].JSID := NewJSName( TVAJSIDPref+JSBID );
         AnSECSSName := '';
         if AnSECSS <> nil then begin
           CSSInd := AddDCSSToArchive( TK_UDDCSSpace(AnSECSS), true );
           AddToNOL(JSO[0], JSObjs[CSSInd].JSO[0]); // add AnSECSS object
           AnSECSSName := JSObjs[CSSInd].JSO[0].JSID;
         end;

         ColorsInd := AddUDColorsToArchive( ColorsSet );
         AddToNOL(JSO[0], JSObjs[ColorsInd].JSO[0]); // add Colors object

         SVInd := AddSValuesToArchive( UDSVAttrs );
         AddToNOL(JSO[0], JSObjs[SVInd].JSO[0]); // add SValues object

         with TK_PMVVAttrs(UDAttrs.R.P)^ do begin
           DArchs.CArch.Add( 'TUC(TVA,"'+JSO[0].JSID+'","'+
           // Spec Values
             JSObjs[SVInd].JSO[0].JSID+'","'+
           // Colors Set
             JSObjs[ColorsInd].JSO[0].JSID+'","'+
           // AnSECSS
             AnSECSSName+'",['+
             BuildArchivesList(@JSO[0])+']).Set('+
             IntToStr(AbsDCSESVIndex)+','+
             IntToStr(ValueType.R)+','+IntToStr(AutoRangeType.R)+','+
             IntToStr(RangeCount)+','+IntToStr(RDPPos)+',' );
         // Range Values
           if AutoRangeVals.T <> K_aumAuto then begin
             WSL2.Clear;
             for i := 0 to RangeValues.AHigh do
               WSL2.Add( FloatToStr( PDouble( RangeValues.P(i) )^ ) );
             DArchs.CArch.Add( '['+WSL2.CommaText+'],' );
           end else
             DArchs.CArch.Add( '[],' );
         // AutoCaptsFormat  **??**
           DArchs.CArch.Add( '["'''+
             K_StringMListReplace( PString(AutoCaptsFormat.P(0))^, PatMacro, K_ummSaveMacroName )+'''","'''+
             K_StringMListReplace( PString(AutoCaptsFormat.P(1))^, PatMacro, K_ummSaveMacroName )+'''","'''+
             K_StringMListReplace( PString(AutoCaptsFormat.P(2))^, PatMacro, K_ummSaveMacroName )+'''"],' );
         // Range Captions
           if AutoRangeVals.T <> K_aumAuto then begin
             WSL2.Clear;
             for i := 0 to RangeValues.AHigh do
               WSL2.Add( ''''+PString( RangeCaptions.P(i) )^+''''  );
             DArchs.CArch.Add( '['+WSL2.DelimitedText+'],' );
           end else
             DArchs.CArch.Add( '[],' );
         // Colors Type
           DArchs.CArch.Add(
             IntToStr(BuildColorsType.R)+','+IntToStr(ColorsSetOrder.R)+','+
             IntToStr(VDPPos)+',' );

         // PureVal Type
         DArchs.CArch.Add( IntToStr(PureValPatType.R)+',' );
         if PureValPatType.T = K_vttManual then
            DArchs.CArch.Add( '"'+PureValToTextPat+'",' )
          else
            DArchs.CArch.Add( '"",' );

         // NamedVal Type
          DArchs.CArch.Add( IntToStr(NamedValPatType.R)+',' );
          if NamedValPatType.T = K_vttManual then
            DArchs.CArch.Add( '"'+NamedValToTextPat+'",' )
          else
            DArchs.CArch.Add( '"",' );

           DArchs.CArch.Add(
             IntToStr(AutoMinMax.R)+','+
             FloatToStr(VMin)+','+
             FloatToStr(VMax)+',' );

           WSL2.Clear;
           for i := 0 to VDConv.AHigh do
             WSL2.Add( FloatToStr( PDouble( VDConv.P(i) )^ ) );
           DArchs.CArch.Add(
             '['+WSL2.DelimitedText+'],'+
             FloatToStr(VBase) + ');' );
         end;
       end;
     end;
  end;
}
end; // end of function TK_WebSiteBuilder1.AddMVTVectorAttrsToArchive

//**************************** TK_WebSiteBuilder1.AddDCSToArchive
//
function TK_WebSiteBuilder1.AddDCSToArchive( UDCS : TK_UDDCSpace; AddAliase : Boolean  ) : Integer;
var
  i, h : Integer;
  UDAliases : TK_UDVector;
  VAliases : TK_RArray;
  WStr : string;
begin
//  if AddVObject( UDCS, CSArchs.CArchJSID, -1, Result ) then begin
  if AddVObject( UDCS, CSArchs.CArchJSID, Result ) then begin
    with JSObjs[Result] do begin
      JSO[0].JSID := NewJSName( BuildJSID( UDCS, TCSJSPref+IntToStr(CurDCSInd) ) );
      Inc(CurDCSInd);
// add descriptor
      h := UDCS.SelfCount;
      if FSaveDCSCodes then begin
        WSL2.Clear;
        with TK_PDCSpace(UDCS.R.P).Codes do
          for i := 0 to h - 1 do
            WSL2.Add( PString( P(i) )^ );
         WStr := ',['+WSL2.CommaText+']);'
       end else
         WStr := ');';
      CSArchs.CArch.Add( 'TUC(TCS,"'+JSO[0].JSID+'",'+IntToStr(h)+WStr );
//      CSArchs.CArch.Add( 'TUC(TCS,"'+JSO[0].JSID+'",'+IntToStr(h)+',['+
//                         WSL2.CommaText+']);' );
//      CSArchs.CArch.Add( 'TUC(TCS,"'+JSO[0].JSID+'",'+IntToStr(h)+');' );
      if not AddAliase then Exit;
      UDAliases := TK_UDVector( UDCS.GetAliasesDir.DirChild(0) );
      if UDAliases <> nil then
        VAliases := UDAliases.PDRA^
      else
        VAliases := TK_PDCSpace(UDCS.R.P).Names;
      CSArchs.CArch.Add( 'AU.'+JSO[0].JSID+'.AddAliase("0",[' );
      with VAliases do begin
        h := AHigh - 1;
        for i := 0 to h do
          CSArchs.CArch.Add( ''''+PString( P(i) )^+''',' );
        CSArchs.CArch.Add( ''''+PString( P(h+1) )^+''']);' );
      end;
    end;
  end;
end; // end of function TK_WebSiteBuilder1.AddDCSToArchive

//**************************** TK_WebSiteBuilder1.AddDCSSToArchive
//
function TK_WebSiteBuilder1.AddDCSSToArchive( UDCSS : TK_UDDCSSpace; AddCSAliase : Boolean ) : Integer;
var
  i, h, CSInd : Integer;
begin
  CSInd := AddDCSToArchive( UDCSS.GetDCSpace, AddCSAliase );
//  if AddVObject( UDCSS, CSArchs.CArchJSID, -1, Result ) then begin
  if AddVObject( UDCSS, CSArchs.CArchJSID, Result ) then begin
    with JSObjs[Result] do begin
      JSO[0].JSID := NewJSName( TCSSJSPref+BuildJSID( UDCSS, JSObjs[CSInd].JSO[0].JSID+'_'+IntToStr(CurDCSSInd) ) );
      Inc(CurDCSSInd);
      AddToNOL(JSO[0], JSObjs[CSInd].JSO[0]);
// add descriptor
      CSArchs.CArch.Add( 'TUC(TCSS,"'+JSO[0].JSID+'","'+
         JSObjs[CSInd].JSO[0].JSID+'",['+
         BuildArchivesList(@JSO[0])+'],[' );
      WSL2.Clear;
      h := UDCSS.PDRA.AHigh;
      for i := 0 to h do
        WSL2.Add( IntToStr( PInteger( UDCSS.DP(i) )^ ) );
      CSArchs.CArch.Add(  WSL2.CommaText+']).Notify();' );
    end;
  end;
end; // end of function TK_WebSiteBuilder1.AddDCSSToArchive

//**************************** TK_WebSiteBuilder1.AddProjToArchive
//
function TK_WebSiteBuilder1.AddProjToArchive( UDP : TK_UDVector  ) : Integer;
var
  CSSrcInd, CSDestInd, h, i : Integer;
begin
  CSDestInd := AddDCSToArchive( UDP.GetDCSSpace.GetDCSpace, false );
  CSSrcInd  := AddDCSToArchive( TK_UDDCSSpace(UDP).GetDCSpace, false );
//  if AddVObject( UDP, CSArchs.CArchJSID, -1, Result ) then begin
  if AddVObject( UDP, CSArchs.CArchJSID, Result ) then begin
    with JSObjs[Result] do begin
      JSBID := JSObjs[CSSrcInd].JSO[0].JSID+'_'+
                                      JSObjs[CSDestInd].JSO[0].JSID;
      JSO[0].JSID := NewJSName( JSObjs[CSSrcInd].JSO[0].JSID+'.S.'+JSBID );
      CSArchs.CArch.Add( 'TUC(TVS,"'+JSO[0].JSID+'","'+
        JSObjs[CSDestInd].JSO[0].JSID+'.$",[]).Set([' );
      WSL2.Clear;
      with TK_UDVector(UDP) do begin
        h := PDRA.AHigh;
        for i := 0 to h do
          WSL2.Add( IntToStr( PInteger( DP(i) )^ ) );
      end;
      CSArchs.CArch.Add( WSL2.CommaText+']).Notify();' );
    end;
  end;
end; // end of function TK_WebSiteBuilder1.AddProjToArchive

//**************************** TK_WebSiteBuilder1.AddDVSToArchive
//
function TK_WebSiteBuilder1.AddDVSToArchive( UDV : TK_UDVector; UnConditionalAdd : boolean; Values : string = '' ) : Integer;
var
  CSSInd : Integer;
begin
  CSSInd := AddDCSSToArchive( UDV.GetDCSSpace, false );
//  if AddVObject( UDV, CSArchs.CArchJSID, -1, Result, UnConditionalAdd ) then begin
  if AddVObject( UDV, CSArchs.CArchJSID, Result, UnConditionalAdd ) then begin
    with JSObjs[Result] do begin
      JSO[0].JSID := NewJSName( BuildJSID( UDV, JSObjs[CSSInd].JSO[0].JSID+'_'+IntToStr(CurDVInd) ) );
      Inc(CurDVInd);
      AddToNOL(JSO[0], JSObjs[CSSInd].JSO[0]);
// add descriptor
      if Values <> '' then Values := ',['+Values+']';
      CSArchs.CArch.Add('TUC(TVS,"'+JSO[0].JSID+'","'+
         JSObjs[CSSInd].JSO[0].JSID+'",['+
         BuildArchivesList(@JSO[0])+']'+Values+').Notify();');
    end;
  end;
end; // end of function TK_WebSiteBuilder1.AddDVSToArchive

//**************************** TK_WebSiteBuilder1.AddUDColorsToArchive
//
function TK_WebSiteBuilder1.AddUDColorsToArchive( UDColors : TN_UDBase ) : Integer;
var
  i : Integer;
begin
//  if AddVObject( UDColors, DArchs.CArchJSID, -1, Result ) then begin
  if AddVObject( UDColors, DArchs.CArchJSID, Result ) then begin
    with JSObjs[Result] do begin
      JSO[0].JSID := NewJSName( TColorsJSPathPref+BuildJSID( UDColors, TColorsJSIDPref+IntToStr(CurColorsInd) ) );
      Inc(CurColorsInd);
// add descriptor
      DArchs.CArch.Add( JSO[0].JSID+'=[' );
      WSL2.Clear;
      with TK_UDRArray(UDColors).R do
        for i := 0 to AHigh do
          WSL2.Add( ''''+N_ColorToHTMLHex( PInteger(P(i))^ )+'''' );
      DArchs.CArch.Add(  WSL2.DelimitedText+'];' );
    end;
  end;
end; // end of function TK_WebSiteBuilder1.AddUDColorsToArchive

//**************************** TK_WebSiteBuilder1.AddSValuesToArchive
//
function TK_WebSiteBuilder1.AddSValuesToArchive( UDSValues : TN_UDBase ) : Integer;
var
  i : Integer;
begin
//  if AddVObject( UDSValues, DArchs.CArchJSID, -1, Result ) then begin
  if AddVObject( UDSValues, DArchs.CArchJSID, Result ) then begin
    with JSObjs[Result] do begin
      JSO[0].JSID := NewJSName( BuildJSID( UDSValues, TSVAJSIDPref+IntToStr(CurSVInd) ) );
      Inc(CurSVInd);
      WSL2.Clear;
      with TK_UDRArray(UDSValues).R do
        for i := 0 to AHigh do
          with TK_PMVDataSpecVal(P(i))^ do
            WSL2.Add( '['+FloatToStr(Value)+',"'+
              Caption+'","'+N_ColorToHTMLHex( Color )+'",'+
              FloatToStr(DSValue)+','+IntToStr(LegShowFlags.R)+']' );
// add descriptor
      DArchs.CArch.Add( 'TUC(TSVA,"'+JSO[0].JSID+'",'+
        FloatToStr(K_MVMinVal)+','+FloatToStr(K_MVMaxVal)+',['+
        WSL2.DelimitedText+']);' );
    end;
  end;
end; // end of function TK_WebSiteBuilder1.AddSValuesToArchive

//**************************** TK_WebSiteBuilder1.AddMapToArchive
//
function TK_WebSiteBuilder1.AddMapToArchive( UDMVMapDescr :  TK_UDMVMapDescr ) : Integer;

var
  i,h,j : Integer;
  k : Integer;
  UDMVMLDColorFill : TK_UDMVMLDColorFill;
  ParVal : string;
  CColorInd, CPromptInd : Integer;
  AddPrompts : Boolean;
  SConvAttrs : TK_RArray;
  WSL3 : TStringList;

  procedure AddFramePos( PPos : TK_PMVMPageElemPos );
  begin
    with PPos^ do begin
      MArchs.CArch.Add(
        IntToStr(LeftType.R)+','+
        FloatToStr(Left)+','+
        IntToStr(TopType.R)+','+
        FloatToStr(Top)+','+
        IntToStr(RightType.R)+','+
        FloatToStr(Right)+','+
        IntToStr(BottomType.R)+','+
        FloatToStr(Bottom)+']' );
    end;
  end;

begin
  if UDMVMapDescr.Marker = 0 then begin
    AddArchive( @CSArchs );
    AddVObject( UDMVMapDescr, CSArchs.CArchJSID, Result );
    with JSObjs[Result] do begin
      JSBID := TVMAPJSIDPref+BuildJSID( UDMVMapDescr, IntToStr(CurMapInd) );
      Inc(CurMapInd);
      UDMVMLDColorFill := TK_UDMVMLDColorFill( UDMVMapDescr.DirChild(0) );
      with TK_PMVMLDColorFill(UDMVMLDColorFill.R.P)^ do begin
        AddPrompts := (UDColors.Marker = 0);
        CColorInd := AddDVSToArchive(TK_UDVector(UDColors), false);
        if AddPrompts then
          AddDVSToArchive(TK_UDVector(UDColors), true);
        CPromptInd := CColorInd + 1;
        with JSObjs[Result] do begin
          SConvAttrs := TK_PMVMapDescr(UDMVMapDescr.R.P).ScaleConvAttrs;
          h := SConvAttrs.AHigh;
          j := 0;
          WSL3 := TStringList.Create;
          for i := h downto 0 do begin
            JSO[j].JSID := NewJSName( JSBID+IntToStr(j) );
            AddArchive( @MArchs );
    // Set Map JSO
            JSO[j].ADN := CSArchs.CArchJSID;
            JSO[j].AVN := MArchs.CArchJSID;
            AddToNOL(JSO[j], JSObjs[CColorInd].JSO[0]);
            AddToNOL(JSO[j], JSObjs[CPromptInd].JSO[0]);
    // add Map archive data
            MArchs.CArch.Add('var lgs=new TLGS();');
            with TK_PMVMapConvAttrs(SConvAttrs.P(i))^ do begin
              with TK_PMVMLayerConvAttrs(LConvAttrs.P)^ do begin
      // add special legend styles
                if LegendStyle <> '' then begin
                  WSL3.Clear;
                  WSL3.CommaText := LegendStyle;
                  for k := 0 to WSL3.Count - 1 do begin
                    ParVal := WSL3.Names[k];
                    MArchs.CArch.Add('lgs.'+ParVal+'="'+WSL3.Values[ParVal]+'";');
                  end;
                end;
                MArchs.CArch.Add( 'AU.'+JSO[j].JSID+'.Set(' );
        // width, height
                MArchs.CArch.Add( IntToStr(Width)+','+IntToStr(Height) );
                MArchs.CArch.Add( ',new TPGL([' );
        // PageLayout
        // Header frame
                MArchs.CArch.Add( '["'+HeaderDOMName+'",' );
                AddFramePos( @HeaderPos );
        // Map frame
                MArchs.CArch.Add( ',["'+MapDOMName+'",' );
                AddFramePos( @MapPos );
        // Legend frame
                MArchs.CArch.Add( ',["'+LegendDOMName+'",' );
                AddFramePos( @LegendPos );
                MArchs.CArch.Add( ']),[[TMLP,"'+LName+'",' );
        // Add Map  Coords
                ParVal := K_ExpandFileNameByDirPath('Maps', CoordsFName);
//                WSL3.LoadFromFile( ParVal );
                K_VFLoadStrings( WSL3, ParVal );
                MArchs.CArch.AddStrings( WSL3 );
                MArchs.CArch.Add( ',"'+MapBGFName+'","'+JSObjs[CColorInd].JSO[0].JSID+
                                '",lgs,"'+LegendDOMName+'","'+JSObjs[CPromptInd].JSO[0].JSID+'"]]);' );
        // add map descriptor
                CSArchs.CArch.Add('TUC(TMap,"'+JSO[j].JSID+'",['+BuildArchivesList(@JSO[j])+']);');
                Inc(j);
        // Copy Map BG Image
                CopyMapFile( MapBGFName );
              end;
            end;
          end;
        end;
      end;
    end;
    WSL3.Free;
  end else begin
    Result := UDMVMapDescr.Marker - 1;
    SetCurArchive( @CSArchs, JSObjs[Result].JSO[0].ADN );
    SetCurArchive( @MArchs, JSObjs[Result].JSO[0].AVN );
  end;
end; // end of function TK_WebSiteBuilder1.AddMapToArchive

//**************************** TK_WebSiteBuilder1.CheckUDMVWObjVWName
//
function TK_WebSiteBuilder1.CheckUDMVWObjVWName( UDMVWinObj: TK_UDMVWBase ): Boolean;
begin
  with TK_PMVWebWinObj(UDMVWinObj.R.P)^ do
    Result := CheckVWName( VWinName, ' для объекта '+UDMVWinObj.GetUName );
end; // end of function TK_WebSiteBuilder1.CheckUDMVWObjVWName

//**************************** TK_WebSiteBuilder1.CheckVWName
//
function TK_WebSiteBuilder1.CheckVWName( VWinName, AddStr : string ): Boolean;
begin
  Result := true;
  if (VWList <> nil) and (VWList.IndexOf( VWinName ) = -1) then begin
    ShowDump( WarnPrefix + 'Отсутствует виртуальное окно "'+VWinName+'"' + AddStr, K_msWarning, true );
    Result := false;
  end;
end; // end of function TK_WebSiteBuilder1.CheckVWName

//**************************** TK_WebSiteBuilder1.GetDataArchive
//
procedure TK_WebSiteBuilder1.GetDataArchive( var DArch : TStringList;
                            var DArchID : string; var DArchInd : Integer );
begin
  if DArchInd = -1 then begin
  // VTree is start Object
    DArch := DArchs.CArch;
    DArchID := DArchs.CArchJSID;
    DArchInd := DArchs.CArchInd;
  end else begin
    AddArchive( @DArchs );
    DArch := DArchs.CArch;
    DArchID := DArchs.CArchJSID;
    DArchInd := DArchs.CArchInd;
  end;

end; // end of procedure TK_WebSiteBuilder1.GetDataArchive


{*** end of TK_WebSiteBuilder1 ***}

{*** TK_MSWDocBuilder ***}
{
//**************************** TK_MSWDocBuilder.Create
//
constructor TK_MSWDocBuilder.Create;
begin

end; // end of procedure TK_MSWDocBuilder.Create

//**************************** TK_MSWDocBuilder.Destroy
//
destructor TK_MSWDocBuilder.Destroy;
begin

  inherited;
end; // end of procedure TK_MSWDocBuilder.Destroy
}
//**************************** TK_MSWDocBuilder.CreateWSDocument1
//
function TK_MSWDocBuilder.CreateWSDocument1( RootNode  : TN_UDBase; Title : string;
                           const AResDocFName : string;
                           APMVMSWDVAttrs : TK_PMVMSWDVAttrs;
                           ASTopicNumber : Integer ) : Integer;
var
  WDTitle    : TN_UDCompBase; // Document Title TN_UDWordFragm
  WDTopics   : TN_UDArray;    // Array of Topics
  WDGroup    : TN_UDCompBase; // Document Level Question TN_UDWordFragm
  WDMapsGroup: TN_UDCompBase; // Document Level Maps Group TN_UDWordFragm
  WDMap      : TN_UDCompBase; // Document Level Map TN_UDWordFragm
  WDMapInd   : Integer;       // Document Level Map Component Index in DCSpace Show Attributes MapsCList
  WDHist     : TN_UDCompBase; // Document Level Histogram Params Component
  HistPars   : TN_UDCompBase; // Document Level Histogram TN_UDWordFragm
  WDTable    : TN_UDCompBase; // Document Level Table TN_UDWordFragm
  TablePars  : TN_UDCompBase; // Document Level Table Params Component
  WDMapHist  : TN_UDBase;     // Document Level Map and Histogram TN_UDWordFragm
  WDMapHistD : TN_UDBase;     // Document Level Map and Histogram Dynamic TN_UDWordFragm
  MapHistPars: TN_UDBase;     // Document Level Map and Histogram Params Component

  PUP: TN_POneUserParam;
  ElemsCount, BuildElemsCount : Integer;
  FCaptionsStack, CaptionsStack : array [0..10] of string;
  CurStackInd : Integer;
  AddParams : TStringList;
  CurComp: TN_UDCompBase;
  STTNum : Integer;
//  WResDocFName  : string;    // Document File Name
//  WResDocCreateFlags : TN_EPExecFlags; // Document Creation Flags
  CurChildHist : TN_UDBase;
  LDTBuilder : TK_MVLDiagramAndTableBuilder1;
//  CurGCont: TN_GlobCont;
  WordDoc : TN_WordDoc;

  procedure SetAdditionalPars;
  var
    i : Integer;
    VName : string;
  begin
  // Add Aditional Params To Component
    for i := 0 to AddParams.Count - 1 do begin
      VName := AddParams.Names[i];
      PUP := N_GetUserParPtr( CurComp.R, VName );
      if PUP <> nil then
        with PUP^.UPValue do
          K_SPLValueFromString( P^, ElemType.All, AddParams.Values[VName] );
    end;
  end;

  function GetLevelWDTopic( CurLevel : Integer ) : TN_UDCompBase;
  begin
    Result := nil;
    if Length(WDTopics) = 0 then Exit;
    CurLevel := Min( CurLevel, Length(WDTopics) - 1 );
    CurLevel := Max( CurLevel, 0 );
    Result := TN_UDCompBase(WDTopics[CurLevel]);
  end;

  function AddLevel( LRoot : TN_UDBase; CaptPrefix : string;
                     StartLevelTextNumber : Integer = 1 ) : Integer;
  var
    ParentSysType, SysType : TK_MVDARSysType;
    CUDChild : TN_UDBase;
    CMVTab : TK_UDMVTable;
    ChildCapt : string;
    ChildFCapt : string;
    CurInd : Integer;
    WPrefix, LCaptPrefix : string;
    CurChildWD : TN_UDCompBase;
    CurChildPars : TN_UDCompBase;
    ChildIsLevel : Boolean;
    ParentIsWFolder : Boolean;
    ChildsLength : Integer;
    DoMapHistFlag : Boolean;
    i, h : Integer;
    SkipLevelIndex : Integer;

    function GetChildCapts( Root, Child : TN_UDBase; Ind : Integer; RootIsWFolder : Boolean;
                             out Capt : string ) : string;
    begin
      with TK_PMVWebWinObj(TK_UDRArray(Child).R.P)^ do begin
        Result := FullCapt;
        Capt := BriefCapt;
      end;
      with TK_PMVWebFolder(TK_UDRArray(Root).R.P)^ do
        if RootIsWFolder and (WENType.T = K_gecWEParent) then
          Capt := PString(WECapts.P(Ind))^;
    end;

    function SetCurMSTabSectionContext1( MSTab : TN_UDBase; SetComPars : Boolean ) : Integer;
    var
      UDVNames, UDVector : TK_UDVector;
      TicksCSS, CRefCSS : TK_UDDCSSpace;
      SelCSS2 : TK_UDDCSSpace;
      PWRData : Pointer;
      ii : Integer;
      PMVWebSection : TK_PMVWebSection;
      ColCapt : string;
      UDMVTable : TK_UDMVTable;
      CSInd  : Integer;
    begin
      LDTBuilder.Init;

      PWRData := TK_UDRArray(MSTab).R.P;
      with TK_PMVWebTableWin(PWRData)^, TK_PMVWebLDiagramWin(PWRData)^ do begin
        CSInd := CurSInd;
        CSInd := Max( 0, CSInd );
        CSInd := Min( Sections.AHigh, CSInd );
        UDVNames := TK_UDVector(ElemCapts);
        PMVWebSection :=TK_PMVWebSection(Sections.P(CSInd));
        UDMVTable := TK_UDMVTable(MSTab.DirChild(CSInd));
        Result := UDMVTable.GetSubTreeChildHigh + 1;
        TicksCSS := nil;
        SelCSS2 := nil;
        CRefCSS := nil;
        if MSTab is TK_UDMVWLDiagramWin then begin
          TicksCSS := TK_UDDCSSpace(PECSS);
          SelCSS2 := TK_UDDCSSpace(CSProj1);
          CRefCSS := TK_UDDCSSpace(CRCSS);
        end;
        LDTBuilder.SetCSContext( TicksCSS, SelCSS2, nil, UDVNames, CRefCSS );
        for ii := 0 to Result - 1 do begin
          UDVector := UDMVTable.GetUDVector( ii );
          with TK_PMVVector(UDVector.R.P)^ do
            case PMVWebSection.WENType.T of
              K_gecWEFull   : ColCapt := FullCapt;
              K_gecWEBrief  : ColCapt := BriefCapt;
              K_gecWEParent : ColCapt := PString(PMVWebSection.WECapts.P(ii))^;
            end;
          LDTBuilder.AddVectorAndAttributes( ColCapt, UDVector, UDMVTable.GetUDAttribs( ii ) );
        end;
        if SetComPars then begin
          LDTBuilder.PrepUDComponentContext( CurChildPars, FullCapt, LegHeader );
          LDTBuilder.SetUDComponentParams;
        end;
      end;
    end;

    procedure SetCurWDCommonPars( ACurChildWD : TN_UDCompBase );
    var
      i : Integer;
      SL : TStringList;
      Capt : string;
    begin
      ACurChildWD.SetSUserParInt( 'TOCLevel', CurStackInd );
      ACurChildWD.SetSUserParStr( 'NumPref', LCaptPrefix + '.' );
//        ACurChildWD.SetSUserParStr( 'ShortName', LCaptPrefix + ' ' + ChildCapt );
//        ACurChildWD.SetSUserParStr( 'FullName',  LCaptPrefix + ' ' + ChildFCapt );
      ACurChildWD.SetSUserParStr( 'ShortName', ChildCapt );
      ACurChildWD.SetSUserParStr( 'FullName',  ChildFCapt );
      if ChildIsLevel then begin
        SL := TStringList.Create;
        for i := 0 to CUDChild.DirHigh  do begin
          GetChildCapts( CUDChild, CUDChild.DirChild(i), i,
                         (SysType = K_msdWebFolder), Capt );
          SL.Add( Capt );
        end;
        Capt := SL.Text;
        ACurChildWD.SetSUserParStr( 'List',  Copy( Capt, 1, Length(Capt) - 2 ) );
        SL.Free;
      end;
    end;

    procedure DoLevelChild;
    var
      PMVRNCList : TK_PMVRNCList;
      PMVRCSAttrs : TK_PMVRCSAttrs;
      PMVCartLayer1 : TK_PMVCartLayer1;
      CurWDMapHist : TN_UDCompBase;
    begin
      SysType := K_MVDarGetUserNodeType( CUDChild );
      //*** Select Child Component
      CurChildWD := nil;
      if SysType = K_msdWebFolder then
        CurChildWD := GetLevelWDTopic(CurStackInd - 1)
      else if SysType = K_msdWebWinGroups then
        CurChildWD := WDGroup
      else if (SysType = K_msdWebCartGroupWins) or (SysType = K_msdBTables) then
        CurChildWD := WDMapsGroup
      else if SysType = K_msdWebCartWins then begin
        CurChildWD := WDMap;
        if CurChildWD = nil then begin
          PMVRCSAttrs := TK_UDMVWCartWin(CUDChild).GetLayerPMVRCSAttrs( 0 );
          if PMVRCSAttrs <> nil then
            with PMVRCSAttrs^ do
            begin
              if RCSAMapCList.ALength > 0 then
              // New Data - 2 elements (Portrait/Landscape) List
                with TK_PMVRNCList2(RCSAMapCList.P(RCSAMapCListInd))^ do begin
                  if WDMapInd = 0 then
                    CurChildWD := TN_UDCompBase(UDCompPT)  // Portrait
                  else
                    CurChildWD := TN_UDCompBase(UDCompLS); // Landscape
                end
              else
              begin // Old Data
                PMVRNCList := TK_PMVRNCList(PMVRCSAttrs.MapCList.P( WDMapInd ));
                if PMVRNCList <> nil then
                  CurChildWD := TN_UDCompBase(PMVRNCList.UDComp);
              end;
            end;
        end;
      end else if SysType = K_msdWebTableWins then
        CurChildWD := WDTable
      else if SysType = K_msdWebLDiagramWins then begin
        CurChildWD := WDHist;
        if ParentSysType = K_msdWebWinGroups then CurChildHist := CUDChild;
      end;

      ChildIsLevel := (SysType = K_msdWebWinGroups) or
                      (SysType = K_msdWebFolder)    or
                      (SysType = K_msdWebCartGroupWins);
      //*** Skip Undefined Terminating Nodes
      if (CurChildWD = nil) and
          not ChildIsLevel  and
          not DoMapHistFlag  then Exit;


      if (CurChildWD <> nil) or DoMapHistFlag then begin
        ChildFCapt := GetChildCapts( LRoot, CUDChild, i, ParentIsWFolder, ChildCapt );

        LCaptPrefix := CaptPrefix + IntToStr(Result);

        if SysType = K_msdWebFolder then begin
          WordDoc.WDGCont.GCSetStrVar( 'LeftHeader', CaptionsStack[CurStackInd-1] );
          WordDoc.WDGCont.GCSetStrVar( 'RightHeader', ChildCapt );
        end;

        FCaptionsStack[CurStackInd] := ChildFCapt;
        CaptionsStack[CurStackInd] := ChildCapt;

      //*** Set Common Params
        SetAdditionalPars; //
        if CurChildWD <> nil then
          SetCurWDCommonPars( CurChildWD );

        if (SysType = K_msdWebLDiagramWins) or (SysType = K_msdWebTableWins) then begin
      //*** Set Histogram or Table Params
          if (SysType = K_msdWebLDiagramWins) then
            CurChildPars := HistPars
          else
            CurChildPars := TablePars;

          SetCurMSTabSectionContext1( CUDChild, true );
      //*** end of Histogram or Table Params
        end else if SysType = K_msdWebCartWins then
      //*** Set Map Params
          TK_UDMVWCartWin( CUDChild ).RebuildMapAttrs( nil, false, ColorSchemeInd );

        WordDoc.AddComponent( CurChildWD );

        if DoMapHistFlag then
        begin
          PMVCartLayer1 := TK_PMVCartLayer1(TK_UDMVWCartLayer(CUDChild.DirChild(0)).R.P);
          CurWDMapHist := TN_UDCompBase(WDMapHist);
          if TK_PMVVAttrs(TK_UDRArray(PMVCartLayer1.UDMVVAttrs).PDE(0)).AddLHDataVector <> nil then
            CurWDMapHist := TN_UDCompBase(WDMapHistD);
          SetCurWDCommonPars( CurWDMapHist );
          LDTBuilder.PrepUDComponentContext( TN_UDCompBase(MapHistPars),
                       TK_PMVWebCartWin(TK_UDMVWCartWin( CUDChild ).R.P)^.PageCaption,
                       PMVCartLayer1.LegHeader );
          LDTBuilder.SetUDComponentParams( ColorSchemeInd, nil, false, @i, 1 );
          WordDoc.AddComponent( CurWDMapHist );
        end;

        if not ChildIsLevel then Inc(Result);

  //*** Show Progress
        Inc(BuildElemsCount);
        N_PBCaller.Update( BuildElemsCount );
      end;

      if ChildIsLevel then begin
      //*** Child is Level Component
        if CurChildWD = nil then begin
        // Skip Childs Level Case
          WPrefix := CaptPrefix;
          CurInd := Result;
        end else begin
        // Done Childs Level Case
          Inc(CurStackInd);
          CurInd := 1;
          if SysType = K_msdWebWinGroups then
            with TK_PMVWebWinGroup(TK_UDRArray(CUDChild).R.P)^ do
              AddParams.CommaText := AddMSWParsList;
          WPrefix := LCaptPrefix + '.';
//          WPrefix := LCaptPrefix;
        end;

        CurInd := AddLevel( CUDChild, WPrefix, CurInd );

        if CurChildWD = nil then
        // Skip Childs Level Case
          Result := CurInd
        else begin
        // Done Childs Level Case
          Inc(Result);
          Dec(CurStackInd);
        end;
      end;
    end;

  begin

    ParentSysType := K_MVDarGetUserNodeType( LRoot );
    ParentIsWFolder := (ParentSysType = K_msdWebFolder);
    Result := StartLevelTextNumber;
    ChildsLength := LRoot.DirLength;
    DoMapHistFlag := ParentSysType = K_msdWebCartGroupWins;
    if not DoMapHistFlag then
      CurChildHist := nil
    else begin
      DoMapHistFlag := (CurChildHist <> nil) and
                       (WDMapHist    <> nil) and
                       (ChildsLength = SetCurMSTabSectionContext1( CurChildHist, false ));
//!!                       (ChildsLength = SetCurMSTabSectionContext( CurChildHist ));
{!!
      if DoMapHistFlag then
        SetWTableAndWDiagramPars( TN_UDCompBase(MapHistPars) );
}
    end;

    SkipLevelIndex := -1;
    if ParentSysType = K_msdWebWinGroups then begin
    //Search for WebHistogram and WebCartogramGroup in WebWinGroups
      CurChildHist := nil; //????
      for i := 0 to ChildsLength - 1 do begin
        CUDChild := LRoot.DirChild(i);
        SysType := K_MVDarGetUserNodeType( CUDChild );
        if SysType = K_msdWebLDiagramWins then
           CurChildHist := CUDChild;
        if SysType = K_msdWebCartGroupWins then begin
          DoLevelChild();
          SkipLevelIndex := i;
          break;
        end;
      end;

      // Add Vector Histograms if Cartograms (WebCartogramGroup) are absent
      if (SkipLevelIndex = -1)  and
         (CurChildHist <> nil ) and
         (WDMapHist <> nil) then begin
      // Add Vectors Table Level details
        CUDChild := CurChildHist.DirChild(0);
        DoLevelChild();
        h := SetCurMSTabSectionContext1( CurChildHist, false ) - 1;
      // Add Vector Histograms
        CMVTab := TK_UDMVTable(CUDChild);
        for i := 0 to h do begin
          SetCurWDCommonPars( TN_UDCompBase(WDMapHist) );
          LDTBuilder.PrepUDComponentContext( TN_UDCompBase(MapHistPars),
                                             CMVTab.GetUDVectorAllSufficientCaption(i), '' );
          LDTBuilder.SetUDComponentParams( ColorSchemeInd, nil, false, @i, 1 );
          WordDoc.AddComponent( TN_UDCompBase(WDMapHist) );
        end; // end of histograms loop
      end;
    end;

    for i := 0 to ChildsLength - 1 do begin
      if BreakDocCreation then Break;
      if SkipLevelIndex = i then Continue;
      CUDChild := LRoot.DirChild(i);
      DoLevelChild();
    end; // end of level loop

  end;

  procedure CalcElems( LRoot : TN_UDBase );
  var
    SysType : TK_MVDARSysType;
    CUDChild : TN_UDBase;
    i : Integer;

  begin
    for i := 0 to LRoot.DirHigh do begin
      CUDChild := LRoot.DirChild(i);
      SysType := K_MVDarGetUserNodeType( CUDChild );
      if (SysType = K_msdWebFolder)       or
         (SysType = K_msdWebTableWins)    or
         (SysType = K_msdWebLDiagramWins) or
         (SysType = K_msdWebCartWins)     or
         (SysType = K_msdWebCartGroupWins) then
        Inc(ElemsCount);
      if (SysType = K_msdWebWinGroups) or
         (SysType = K_msdWebFolder)    or
         (SysType = K_msdWebCartGroupWins) then
        CalcElems( CUDChild  );
    end; // end of level loop
  end;

begin
//
  Result := -1;
  if APMVMSWDVAttrs = nil then begin
    ShowDump( 'Не заданы параметры формирования документа', K_msWarning );
    Exit;
  end;
  with APMVMSWDVAttrs^ do begin
    WDTitle := TN_UDCompBase(UDWDTitle);
    if (WDTitle = nil) or (TN_PRCompBase(WDTitle.R.P).CCompBase.CBExpParams = nil) or
       ( ((UDWDTopics   = nil) or (UDWDTopics.ALength = 0)) and
         (UDWDGroup    = nil) and
         (UDWDMapsGroup = nil)and
//         (UDWDMap = nil)      and
         (UDWDHist = nil)     and
         (UDWDTable = nil)    and
         (UDWDMapHist = nil) ) then begin
      ShowDump( 'Неправильно заданы компоненты формирования документа', K_msWarning );
      Exit;
    end;

    SetLength(WDTopics, UDWDTopics.ALength );
    if Length(WDTopics) > 0 then
      Move( UDWDTopics.P^,  WDTopics[0], Length(WDTopics) * SizeOf(TN_UDBase) );
    WDGroup := TN_UDCompBase(UDWDGroup);
    WDMapsGroup := TN_UDCompBase(UDWDMapsGroup);
    WDMap := TN_UDCompBase(UDWDMap);
    WDMapInd := UDMapsListInd;
    WDHist := TN_UDCompBase(UDWDHist);
    if WDHist <> nil then begin
      HistPars := TN_UDCompBase(UDHistPars);
      if HistPars = nil then HistPars := WDHist;
    end;

    WDTable := TN_UDCompBase(UDWDTable);
    if WDTable <> nil then begin
      TablePars := TN_UDCompBase(UDTablePars);
      if TablePars = nil then TablePars := WDTable;
    end;

    WDMapHist := TN_UDCompBase(UDWDMapHist);
    if WDMapHist <> nil then begin
      MapHistPars := TN_UDCompBase(UDMapHistPars);
      if MapHistPars = nil then MapHistPars := WDMapHist;
      WDMapHistD := WDMapHist;
      if UDWDMapHistD <> nil then
        WDMapHistD := TN_UDCompBase(UDWDMapHistD)
    end;

    WDTitle.SetSUserParStr( 'Title',  Title );

    ShowDump( 'Начато создание документа ' + AResDocFName, K_msInfo );

//    WordDoc := TN_WordDoc.Create( WDTitle,
//                            K_ExpandFileNameByIniDir( 'OutFiles', AResDocFName ),
//                            ResDocCreateFlags );
    WordDoc := TN_WordDoc.Create;
    WordDoc.StartCreating( WDTitle,
                           K_ExpandFileNameByDirPath( 'OutFiles', AResDocFName ),
                           ResDocCreateFlags );
    ErrCount := -1;
    if WordDoc.WDGCont.GCProperWordIsAbsent then begin // Word97 or less
      ShowDump( 'Отсутствует нужная версия MS Word. Создание документа прервано.', K_msWarning );
      WordDoc.Free;
      Exit;
    end; // if WordDoc.WDGCont.GCWSMajorVersion <= 8 then // Word97 or less
    ErrCount := 0;
    ElemsCount := 0;
    CalcElems( RootNode );
    N_PBCaller.Start( ElemsCount );

    BuildElemsCount := 0;
    FCaptionsStack[0] := Title;
    CaptionsStack[0] := Title;
    CurStackInd := 1;
    AddParams := TStringList.Create;

    STTNum := 1;
    if ASTopicNumber <> 0 then
      STTNum := ASTopicNumber;
    CurChildHist := nil;
    LDTBuilder := TK_MVLDiagramAndTableBuilder1.Create;
    LDTBuilder.OrderFlags := [K_dofDescendingOrder];

    AddLevel( RootNode, '', STTNum );

    LDTBuilder.Free;

    N_PBCaller.Update( ElemsCount );
    ShowDump('Идет сборка оглавления в MS Word ...', K_msInfo );
    AddParams.Free;

    WordDoc.FinishCreating();
    WordDoc.Free;
    N_PBCaller.Finish();
    ShowDump('Cоздание документа завершено', K_msInfo );

  end;
  Result := ErrCount;
end; // end of procedure TK_MSWDocBuilder.CreateWSDocument

//********************************************** TK_MSWDocBuilder.ShowDump
//
procedure TK_MSWDocBuilder.ShowDump( ADumpLine : string;
                                     MesStatus : TK_MesStatus );
var
 Pref : string;
begin
  if ADumpLine = '' then Exit;
  Pref := '';
  if MesStatus = K_msError then Pref := 'ОШИБКА: ';
  if Assigned(OnShowDump) then OnShowDump( Pref + ADumpLine, MesStatus );
  if (MesStatus = K_msError) or
     (CountWarnings and (MesStatus <> K_msInfo)) then
    Inc(ErrCount);
end; // end of procedure TK_MSWDocBuilder.ShowDump

{*** end of TK_MSWDocBuilder ***}

{*** TK_PrepMCHistCompContext ***}

//********************************************** TK_PrepMCHistCompContext.Create
//
constructor TK_PrepMCHistCompContext.Create;
begin
  inherited;
  CCPLDTBuilder := TK_MVLDiagramAndTableBuilder1.Create;
end; // end of TK_PrepMCHistCompContext.Create

//********************************************** TK_PrepMCHistCompContext.Destroy
//
destructor TK_PrepMCHistCompContext.Destroy;
begin
  CCPLDTBuilder.Free;
  inherited;
end; // end of TK_PrepMCHistCompContext.Destroy

//********************************************** TK_PrepMCHistCompContext.SetContext
//
procedure TK_PrepMCHistCompContext.SetContext;
begin
  TK_MVLDiagramAndTableBuilder1(CCPLDTBuilder).PrepUDComponentContext( CCPUDCompPars, CCPCompCaption, CCPCompLegend );

  CCPLDTBuilder.SetUDComponentParams( CCPColorSchemeInd, CCPColorSchemes,
                                      CCPSkipRebuildAttrsFlag );
{
  CCPLDTBuilder.SetUDComponentParams( CCPColorSchemeInd, CCPColorSchemes,
                                   CCPSkipRebuildAttrsFlag, nil, 0,
                                   K_GetPIArray0(CCPLDTBuilder.OrderRowInds),
                                   Length(CCPLDTBuilder.OrderRowInds) );
}
end; // end of TK_PrepMCHistCompContext.SetContext

//********************************************** TK_PrepMCHistCompContext.BuildSelfAttrs
//
procedure TK_PrepMCHistCompContext.BuildSelfAttrs;
begin
  K_RFreeAndCopy( TK_RArray(CCPLDTBuilder.RAAttrs.List[0]),
                  TK_RArray(CCPLDTBuilder.RAAttrs.List[0]), [K_mdfCopyRArray] );
end; // end of TK_PrepMCHistCompContext.BuildSelfAttrs

{*** end of TK_PrepMCHistCompContext ***}

{*** TK_PrepSMCHistCompContext ***}

//********************************************** TK_PrepSMCHistCompContext.Create
//
constructor TK_PrepSMCHistCompContext.Create;
begin
  inherited;
  CCPLDTBuilder := TK_MVLDiagramBuilder2.Create;
end; // end of TK_PrepSMCHistCompContext.Create

//********************************************** TK_PrepSMCHistCompContext.SetContext
//
procedure TK_PrepSMCHistCompContext.SetContext;
var
  GroupsCount : Integer;
begin
  TK_MVLDiagramBuilder2(CCPLDTBuilder).PrepUDComponentContext( CCPUDCompPars, CCPCompCaption );
  CCPLDTBuilder.SetUDComponentParams( CCPColorSchemeInd, CCPColorSchemes,
                                   CCPSkipRebuildAttrsFlag,
                                   K_GetPIArray0(CCPColInds), Length(CCPColInds),
                                   K_GetPIArray0(CCPRowInds), Length(CCPRowInds) );

  with TK_MVLDiagramBuilder2(CCPLDTBuilder) do begin
    if K_dcfGroupByRows in DataChartFlags then
      GroupsCount := Length(CCPRowInds)
    else begin
      if (K_dcfViewAllCols in DataChartFlags) then
        GroupsCount := RAAttrs.Count
      else
        GroupsCount := Length(CCPColInds);
    end;
    if K_dcfUseTabColors in DataChartFlags then
      CCPBarChartFlags := CCPBarChartFlags + [K_bcfSkipLegend];
  end;

  with TN_PRLinHistAuto1(CCPUDComp.R.P).CLinHistAuto1 do begin
    LHAWholeMinSize.X := LHAWholeMaxSize.X;
    LHAPatLHSize.X := LHAWholeMinSize.X;
    LHAElemsNamesWidth := CCPElemCaptsWidth;
    TN_PRTextMarks(TK_UDRArray(LHAElemsNames).R.P).CTextMarks.TMMaxTextmmWidth :=
      0.85 * LHAElemsNamesWidth;
    LHAValTextsWidth := CCPElemValsWidth;
    TN_PRTextMarks(TK_UDRArray(LHAValTexts).R.P).CTextMarks.TMMaxTextmmWidth :=
      0.85 * LHAValTextsWidth;
    if K_bcfStackedChart in CCPBarChartFlags then begin
      LHAType := lhatStacked;
      LHABlocksHorAlign := hvaBeg;
    end else begin
      LHAType := lhatSimple;
      LHABlocksHorAlign := hvaCenter;

      if GroupsCount > 0 then begin
        LHAPatLHSize.X := (LHAWholeMinSize.X - LHAElemsNamesWidth)/ GroupsCount -
                          LHAIntGapSize.X - LHAValTextsWidth;
        if LHAPatLHSize.X < 20 then
          LHAPatLHSize.X := 30
        else if LHAPatLHSize.X > 50 then
          LHAPatLHSize.X := 50;
      end;
    end;

    if (K_bcfSkipLegend in CCPBarChartFlags) or
       (CCPUDCompPars.GetSUserParRArray( 'LegNames' ).ALength = 0) then begin
      LHAFlags := LHAFlags + [lhafSkipLegend];
      LHAMaxLegHeight := 0
    end else begin
      LHAFlags := LHAFlags - [lhafSkipLegend];
      LHAMaxLegHeight := 30;
    end;

    if (K_bcfSkipHeader in CCPBarChartFlags) then
      LHAFlags := LHAFlags + [lhafSkipMainHeader]
    else
      LHAFlags := LHAFlags - [lhafSkipMainHeader];

    if (K_bcfSkipGroupCapts in CCPBarChartFlags) then
      LHAFlags := LHAFlags + [lhafSkipBlockHeaders]
    else
      LHAFlags := LHAFlags - [lhafSkipBlockHeaders];

    if (K_bcfSkipElemmCapts in CCPBarChartFlags) then
      LHAFlags := LHAFlags + [lhafSkipElemsNames]
    else
      LHAFlags := LHAFlags - [lhafSkipElemsNames];

    if (K_bcfSkipFuncTicks in CCPBarChartFlags) or
       (K_bcfStackedChart in CCPBarChartFlags) then
      LHAFlags := LHAFlags + [lhafSkipFuncsTicks]
    else
      LHAFlags := LHAFlags - [lhafSkipFuncsTicks];

    if K_bcfOrtBarGroupDir in CCPBarChartFlags then
      LHAMaxBlocksInRow := 1
    else
      LHAMaxBlocksInRow := 0;
  end;
end; // end of TK_PrepSMCHistCompContext.SetContext

{*** end of TK_PrepSMCHistCompContext ***}

{*** TK_PrepCorPictCompContext ***}

//********************************************** TK_PrepCorPictCompContext.Destroy
//
destructor TK_PrepCorPictCompContext.Destroy;
begin
  CCPCorPictRA.ARelease;
  inherited;
end; // end of TK_PrepCorPictCompContext.Destroy

//********************************************** TK_PrepCorPictCompContext.BuildSelfAttrs
//
procedure TK_PrepCorPictCompContext.BuildSelfAttrs;
begin
  K_RFreeAndCopy( CCPCorPictRA, CCPCorPictRA, [K_mdfCopyRArray] );
end; // end of TK_PrepCorPictCompContext.BuildSelfAttrs

//***********************************  TK_PrepCorPictCompContext.CCEdRFADblClickProcObj
//
procedure TK_PrepCorPictCompContext.CCEdRFADblClickProcObj( ARFAction: TObject );
var
  CurComp: TN_UDCompVis;
begin
  with CCEdRFA, ActGroup do
  begin
    N_SetCursorType( 0 );

    if ECPosFlags = 0 then // finish Editing
    begin
      ActEnabled := False;

      with RFrame do
        RFrActionFlags := RFrActionFlags + [rfafScrollCoords];

      with RFrame.NGlobCont do
        GCDebFlags := GCDebFlags - [gcdfShowBorder]; // Skip Showing All Components Borders

    end else // ECFlags <> 0, Edit ECComps[ECRectInd] Component and continue Editing
    begin
      CurComp := ECComps[ECRectInd];
      if CurComp is TN_UDParaBox then
        with TN_UDParaBox(CurComp).PISP()^, TN_POneTextBlock(CPBTextBlocks.P())^ do
          K_GetFormTextEdit.EditText( OTBMText, 'Название точки графика' );
      RFrame.RedrawAllAndShow();
    end; // else // ECFlags <> 0

  end; // with EditCompsRFA do


end; // end of TK_PrepCorPictCompContext.CCEdRFADblClickProcObj

//********************************************** TK_PrepCorPictCompContext.SetContext
//
procedure TK_PrepCorPictCompContext.SetContext;
var
  MapGroup: TN_UDCompVis;            // Picture Layer Root Component
  PointsCObj: TN_UDPoints;           // Picture Layer Points Coordinates Object
  MLPoints, MLLabels: TN_UDMapLayer; // Picture Layer MapLayer Components (Signs and Labels)
  UColors{, ULabels}: TK_UDRArray;   // Picture Layer UDVectors (Labe Texts and Sign Colors)
  PLabel: PString;
  ECNInd, i, j, NPlanes, k, kb{, ki} : Integer;
  ECWComp : TN_UDCompVis;
  PAX, PAY, PAZ : TK_PMVVAttrs;      // Pointers to MVDataVectors View Attributes
  CSInd : Integer;
  CFInds : TN_IArray;                //
  FInds : TN_IArray;
  XInds : TN_IArray;      // Wrk Array of Inds
  CSInds : TN_IArray;
  CDInds : TN_IArray;
  CLInds : TN_IArray;
  VCSS : TK_UDDCSSpace;   // Vectro CSS
  VCS : TK_UDDCSpace;     // Vector CS
  VCSSCount : Integer;    // Vector CSS Count
  VCSCount : Integer;     // Vector CS Count
  DCSIndsBLeng : Integer; // Length of Vector CSS Indexes in Bytes
//  RCount : Integer;
  DZ : TN_DArray;         // Wrk array of
  DVal : Double;
  AbsValsSVInd : Integer;
  DCount : Integer;
  UDAliases : TK_UDVector;//
  VAliases : TK_RArray;
  PMVCorPictPlane : TK_PMVCorPictPlane;
  MMX, MMY : Double;
  XMax, XMin, YMax, YMin : Double;
  M1 : Integer;
  IA : TN_IArray;
  IC : TN_IArray;
  PlanesCommonMinMax : Boolean;
  VMin, VMax : double;
  GMinLeftGap, GMinTopGap, GMinBotGap : Double;
  CurSizeAspect, DAspect, DXPage, DYPage : Double;
  NewPageSizeFlag : Boolean;
//  XGraph, YGraph : Double;
  DXGraph, DYGraph : Double;
  GraphCurMaxWidth, GraphCurMaxHeight, GraphWidth, GraphHeight : Double;
//  PageWidth, PageHeight : Double;
  CorPictCFlags : TK_MVCorPictCFlags;
  PGCompCoords : TN_PCompCoords;
  PCompCoords : TN_PCompCoords;
  PCompPatCoords : TN_PCompCoords;
  PHCompCoords : TN_PCompCoords;
  PMVCorPict : TK_PMVCorPict;
  CPCoords : TDPoint;
  PtrsArray : TN_PArray;
  Inds : TN_IArray;
  CPInd1, CPInd2, EPCount : Integer;
  SPRadius, SPPhase, SPPhInd, SPPhCount : Integer;
  CurLText: string;
  CurLTexts : TN_SArray;   // Current Array of Graphic Points Hints
  WCPSize   : TFPoint;     //* CorPict Size in mm
  RAParams : TK_RArray;

  AxisTickStep : Double;
  AxisCharLength : Integer;
  AxisTickFormat : string;
  WDV, WDX, WDY : Double;

  TickLinesFlag : Byte;
  LbDefShift    : TFPoint;   // Point Label Default Shift
  GroupByValueFlag : Boolean; // Group By Values Flag
  GPX, GPY, CGPX, CGPY : Double;          // Group Point Cur Value
  GroupText : string;
  WPGroupStep : TFPoint;
  //***********************************************
  // And Current Vector CSS Indexes with Plane Common Indexes
  //
  procedure AndVCSSInds( AVCSS : TK_UDDCSSpace; AVCSSCount : Integer );
  begin
    if AVCSSCount = -1 then
      AVCSSCount := AVCSS.PDRA.ALength;
    K_BuildXORIndices( @XInds[0], AVCSS.DP,
                       AVCSSCount, VCSCount, false );
    K_MoveVectorByDIndex( FInds[0], -1, M1, 0, SizeOf(Integer),
                          VCSCount, @XInds[0] );
  end;

  //***********************************************
  // Skip Index of Vector Elements with Special Values
  //
  procedure SkipIndsByValues( FullInds : TN_IArray; UDMV : TN_UDBase );
  var
    i : Integer;
    PInds : PInteger;
    PData  : PDouble;
  begin
    with TK_UDMVVector(UDMV) do begin
      PInds := GetDCSSpace.DP();
      with TK_PDSSVector(TK_UDMVVector(UDMV).R.P)^.D do
        for i := 0 to AHigh() do begin
          PData := P(i);
          if (PData^ >= K_MVMaxVal) or (PData^ <= K_MVMinVal) then
            FullInds[PInds^] := -1;
          Inc( PInds );
        end;
    end;
  end;

  //***********************************************
  // Build Vector Data Projection
  //
  procedure BuildVectorDP();
  begin
    SetLength( CSInds, VCSSCount );
    FillChar( CSInds[0], DCSIndsBLeng, -1 );
    K_MoveVectorBySIndex( CSInds[0], -1, CFInds[0], -1, SizeOf(Integer),
                          VCSSCount, VCSS.DP );
  end;

  //***********************************************
  // Build Vector Values
  //
  procedure BuildVectorVals( var DV : TN_DArray; PA : TK_PMVVAttrs; UDMV : TN_UDBase; XFlag : Boolean );
  var j : Integer;
  begin
    SetLength( DV, DCount );
    DVal := TK_PMVDataSpecVal(TK_UDRArray(PA.UDSVAttrs).R.P(AbsValsSVInd)).Value;
    for j := 0 to DCount - 1 do DV[j] := DVal;
    if DCount <= 0 then Exit;
    with TK_UDMVVector(UDMV) do
      if not XFlag then
        K_MoveVectorByDIndex( DV[0], -1, DP^, -1,
                              SizeOf(Double), VCSSCount, K_GetPIArray0( CSInds ) )
      else
        K_MoveVectorBySIndex( DV[0], -1, DP^, -1,
                              SizeOf(Double), DCount, K_GetPIArray0( CSInds ) )
  end;

  //***********************************************
  // Correct Page Size
  //
  procedure CorrectPageSize( APageMax, APageMin : Double; SetMaxFlag : Boolean );
  begin
    with PMVCorPict^ do begin
      if SetMaxFlag then
       CPSize.X := APageMin
      else
       CPSize.X := Min( CPSize.X, APageMin );
      CPSize.Y := CPSize.X * CurSizeAspect;
      if CPSize.Y > APageMax then begin
        if SetMaxFlag then
          CPSize.Y := APageMax
        else
          CPSize.Y := Min( CPSize.Y, APageMax );
        CPSize.X := CPSize.Y / CurSizeAspect;
      end;
    end;
  end;
{
  //***********************************************
  // Correct Picture X size
  //
  procedure CorrectXSize( MaxSize : Double );
  begin
    if XGraph + DXPage > MaxSize then begin
      XGraph := MaxSize - DXPage;
      if K_drcSavePictAspect in CorPictCFlags then
        YGraph := XGraph * CurSizeAspect;
    end;
  end;

  //***********************************************
  // Correct Picture Y size
  //
  procedure CorrectYSize( MaxSize : Double );
  begin
    if YGraph + DYPage > MaxSize then begin
      YGraph := MaxSize - DYPage;
      if K_drcSavePictAspect in CorPictCFlags then
        XGraph := YGraph / CurSizeAspect;
    end;
  end;
}
  //***********************************************
  // Prepare Data structure for Plane Coincident Points Shift
  //
  procedure ClearSpreadPoint(  );
  begin
    SPRadius := 1;
    SPPhase := 0;
    SPPhInd := 0;
    SPPhCount := 2;
  end;

  //***********************************************
  // Shift Next Plane Coincident Point
  //
  procedure SpreadPoint(  );
  var
    XShift, YShift : Integer;
  begin
    XShift := 0;
    YShift := 0;
    case SPPhase of
      0 : begin
        XShift := SPRadius;
        YShift := -SPRadius + SPPhInd;
      end;
      1 : begin
        XShift := SPRadius - SPPhInd;
        YShift := SPRadius;
      end;
      2 : begin
        XShift := -SPRadius;
        YShift := SPRadius - SPPhInd;
      end;
      3 : begin
        XShift := -SPRadius + SPPhInd;
        YShift := -SPRadius;
      end;
    end;
    DX[CPInd1] := DX[CPInd1] + CCSpreadPointStep * XShift;
    DY[CPInd1] := DY[CPInd1] + CCSpreadPointStep * YShift;

  //*** Set Next
    Inc(SPPhInd);
    if SPPhInd >= SPPhCount then begin
    // Next Phase
      Inc(SPPhase);
      if SPPhase > 3 then begin
      // Next Radius
        Inc(SPRadius);
        SPPhase := 0;
        SPPhInd := 0;
        SPPhCount := 2 * SPRadius;
      end else
        SPPhInd := 0;
    end;
  end;

  //***********************************************
  // Prepare Graphic Size Attributes
  //
  procedure PrepGraphSize( PageSize : TFPoint );
  begin
    GraphCurMaxWidth := PageSize.X - DXGraph;
    GraphCurMaxHeight:= PageSize.Y - DYGraph;
    GraphHeight := GraphCurMaxHeight;
    GraphWidth := GraphCurMaxWidth;
  end;

  //***********************************************
  // Set XTicks Attributes
  //
  procedure SetXTicksAttrs( );
  begin
    with CCPUDParams do begin
      RAParams := GetSUserParRArray( 'XTickLinesStep' );
      if RAParams <> nil then
        PDouble(RAParams.P)^ := AxisTickStep;

      RAParams := GetSUserParRArray( 'XAxisTickStep10' );
      if RAParams <> nil then
        PDouble(RAParams.P)^ := AxisTickStep;

      RAParams := GetSUserParRArray( 'XAxisTickStep5' );
      if RAParams <> nil then
        PDouble(RAParams.P)^ := AxisTickStep / 2;

      RAParams := GetSUserParRArray( 'XAxisTickFormat' );
      if RAParams <> nil then
        PString(RAParams.P)^ := AxisTickFormat;
    end;
  end;

  //***********************************************
  // Set YTicks Attributes
  //
  procedure SetYTicksAttrs( );
  begin
    with CCPUDParams do begin
      RAParams := GetSUserParRArray( 'YTickLinesStep' );
      if RAParams <> nil then
        PDouble(RAParams.P)^ := AxisTickStep;

      RAParams := GetSUserParRArray( 'YAxisTickStep10' );
      if RAParams <> nil then
        PDouble(RAParams.P)^ := AxisTickStep;

      RAParams := GetSUserParRArray( 'YAxisTickStep5' );
      if RAParams <> nil then
        PDouble(RAParams.P)^ := AxisTickStep / 2;

      RAParams := GetSUserParRArray( 'YAxisTickFormat' );
      if RAParams <> nil then
        PString(RAParams.P)^ := AxisTickFormat;
    end;
  end;


  //***********************************************
  // Add Point Info
  //
  procedure AddPointInfo( AInd : Integer; AX, AY : Double; AText : string;
                          APatComp : TN_UDBase; ADefXShift, ADefYShift : Float );
  begin
    CPCoords := DPoint( (AX - XMin)* MMX, (YMax - AY)* MMY );
    PointsCObj.AddOnePointItem( CPCoords, -1 );
    CurLTexts[AInd] := AText;
    with PMVCorPictPlane^ do begin
      if (K_drpShowECaption in DRPFlags) then begin
        CCEdRFA.ECComps[ECNInd] := TN_UDCompvis(MapGroup.AddOneChild( N_CreateOneLevelClone( APatComp ) ));
        with TN_UDParaBox(CCEdRFA.ECComps[ECNInd]),
             PISP()^, PCCS()^  do begin
          Inc( ECNInd );
          ObjName := 'L' + IntToStr(AInd + 1);
          ObjAliase := AText;
          if K_drcSkipSignsScale in CorPictCFlags then
            CoordsScope := ccsDstImage;
          BPCoords := FPoint( CPCoords );
          if (DRPLHPoint.X <> 0) or (DRPLHPoint.Y <> 0) then
            BPPos := DRPLHPoint;
          if (DRPLShift.X <> 0) or (DRPLShift.Y <> 0) then
            BPShift := DRPLShift
          else begin
            BPShift.X := ADefXShift;
            BPShift.Y := ADefYShift;
          end;
          with TN_POneTextBlock(CPBTextBlocks.P)^ do begin
            OTBMText := AText;
            if DRPLFont <> nil then
              TK_RArray(OTBNFont) := DRPLFont.AAddRef
            else if CSInd <> -1 then
              TK_RArray(OTBNFont) :=
                  TK_RArray(TN_UDMapLayer( CCPUDLabels.DirChild(CSInd) ).PISP()^.MLVAux1).AAddRef;
          end;
        end;
      end;
    end;
  end;

begin

  inherited;

  if (CCPUDComp = nil) or (CCPUDMComp = nil) then Exit;

  CCPUDMComp.ClearChilds();
  PMVCorPict := CCPCorPictRA.P;
  with PMVCorPict^ do begin
    CorPictCFlags := CPCFlags;

    if CCPUDParams <> nil then
      with CCPUDParams do begin
      //*** Picture Texts
        RAParams := GetSUserParRArray( 'HeaderText' );
        if RAParams <> nil then
          PString(RAParams.P)^ := CPCaption;
        RAParams := GetSUserParRArray( 'XAxisText' );
        if RAParams <> nil then
          PString(RAParams.P)^ := CPXAxisCaption;
        RAParams := GetSUserParRArray( 'YAxisText' );
        if RAParams <> nil then
          PString(RAParams.P)^ := CPYAxisCaption;

      end;
{
  //*** Set Header Text
    if CCPUDHComp <> nil then
      with TN_POneTextBlock(TN_UDParaBox(CCPUDHComp).PISP()^.CPBTextBlocks.P(0))^ do begin
        //'HeaderText'
        OTBMText := CPCaption;
      end;
}

  //*** Calculate Planes Common MinMax
    PlanesCommonMinMax := false;
    if not (K_drcManualPlanesScale in CPCFlags) or
       (CPPlanesMinMax.Left = CPPlanesMinMax.Right) or
       (CPPlanesMinMax.Top = CPPlanesMinMax.Bottom) then begin
    // Planes Common Auto MinMax Calculation
      XMax := -MaxDouble;
      XMin := MaxDouble;
      YMax := -MaxDouble;
      YMin := MaxDouble;
      if K_drcPlanesScaleBalance in CPCFlags then begin
      // Balance Planes MinMax Calculation

        for i := 0 to CPPlanes.AHigh do begin
        // Planes MinMax Calculation Loop
          PMVCorPictPlane := CPPlanes.P(i);
          with PMVCorPictPlane^ do begin // Curent plane with
            // Skip invisible plane or plane without visible elements
            if not K_IfShowCorPictPlane( PMVCorPictPlane, true ) or
              ((DRVCSInds <> nil) and (DRVCSInds.ALength = 0)) then Continue;
           // Shift MinMax by X-DataVector
            with DRPVX, TK_UDVector(UDV) do
              K_RebuildVectorMinMax( VMin, VMax, true,
                    DP, SizeOf(Double), PDRA.ALength );
            XMin := Min( XMin, VMin );
            XMax := Max( XMax, VMax );
           // Shift MinMax by Y-DataVector
            with DRPVY, TK_UDVector(UDV) do
              K_RebuildVectorMinMax( VMin, VMax, true,
                    DP, SizeOf(Double), PDRA.ALength );
            YMin := Min( YMin, VMin );
            YMax := Max( YMax, VMax );
          end;
        // end of  Planes MinMax Calculation Loop
        end;

        MMX := (XMax - XMin) * 0.05;
        XMin := XMin - MMX;
        CPPlanesMinMax.Left := XMin;
        XMax := XMax + MMX;
        CPPlanesMinMax.Right := XMax;
        MMX := (YMax - YMin) * 0.05;
        YMin := YMin - MMX;
        CPPlanesMinMax.Top := YMin;
        YMax := YMax + MMX;
        CPPlanesMinMax.Bottom := YMax;
        PlanesCommonMinMax := true;
      end; // end of Planes balanced MinMax calculation
//      YMax := XMax;
//      YMin := XMin;
    end else begin
    // Planes Common Manual MinMax
      PlanesCommonMinMax := true;
      XMin := Min( CPPlanesMinMax.Left, CPPlanesMinMax.Right );
      XMax := Max( CPPlanesMinMax.Left, CPPlanesMinMax.Right );
      YMin := Min( CPPlanesMinMax.Top, CPPlanesMinMax.Bottom );
      YMax := Max( CPPlanesMinMax.Top, CPPlanesMinMax.Bottom );
    end;
    MMX := 100 / (XMax - XMin);
    MMY := 100 / (YMax - YMin);


  //*** Build Visual Tree Elements
    SetLength( SA, CPPlanes.ALength );    // Array of Hint Texts Arrays for Picture Layers
    SetLength( CCSGMLP.SComps, Length(SA) ); // Array of Picture Layers Search Attributes
//    SetLength( CCSGMLL.SComps, Length(SA) ); // Array of Picture Layers Search Attributes
    M1 := -1;
    NPlanes := 0;
    FillChar( LbDefShift, SizeOF(LbDefShift), 0 );
    WPGroupStep := CPGroupXYStep;
    GroupByValueFlag := (K_drcGroupByValue in CPCFlags);

    if GroupByValueFlag then begin
      if CPGroupXYStep.X = 0 then
        WPGroupStep.X := 0.00001;
      if CPGroupXYStep.Y = 0 then
        WPGroupStep.Y := 0.00001;
    end;

    ECNInd := 0;
    with CCEdRFA do  ECNumComps := 0;
    
    for i := 0 to High(SA) do begin
    // CorPict Planes Loop
      PMVCorPictPlane := CPPlanes.P(i);
      with PMVCorPictPlane^ do begin // Curent plane with

        // Skip invisible plane or plane without visible elements
        if not K_IfShowCorPictPlane( PMVCorPictPlane ) or
        // ElemInds array Exists  and  User remove all Elements
          ((DRVCSInds <> nil) and (DRVCSInds.ALength = 0)) then Continue;

        // Get X-vector CSS, CS and and neede counters
        VCSS := TK_UDMVVector(DRPVX.UDV).GetDCSSpace;
        VCS := VCSS.GetDCSpace;
        VCSCount := VCS.SelfCount;
        VCSSCount := VCSS.PDRA.ALength;
        DCSIndsBLeng := SizeOf(Integer)* VCSSCount;

        // Creeate ElemInds array if needed (if 1-st call - create and Set All Elems use value)
        if DRVCSInds.ALength = 0 then begin
          if DRVCSInds = nil then
            DRVCSInds := K_RCreateByTypeCode( Ord(nptInt), VCSSCount );
          Move( VCSS.DP^, DRVCSInds.P^, DCSIndsBLeng );
        end;

        // Build Vectors VCSS intresection in FInds (Full CS Indexes)
        SetLength( XInds, VCSCount ); // Wrk Array

        // Set all CS inds in FInds
        SetLength( FInds, VCSCount );
        K_FillIntArrayByCounter( @FInds[0], VCSCount );

        // FInds AND by X-Vector CSS
        AndVCSSInds( VCSS, VCSSCount );

        // FInds AND by Y-Vector CSS
        AndVCSSInds( TK_UDMVVector(DRPVY.UDV).GetDCSSpace, -1 );
        if (K_drpZColor in DRPFlags) and
           (DRPVZ.UDVA <> nil) then
        // FInds AND by Z-Vector CSS
          AndVCSSInds( TK_UDMVVector(DRPVZ.UDV).GetDCSSpace, -1 );

        // FInds AND by DRVCSInds (by selected vector elements)
        K_BuildXORIndices( @XInds[0], DRVCSInds.P,
                           DRVCSInds.ALength, VCSCount, false );
        K_MoveVectorByDIndex( FInds[0], -1, M1, 0, SizeOf(Integer),
                              VCSCount, @XInds[0] );

        // Skip Indexes By X-values
        SkipIndsByValues( FInds, DRPVX.UDV );
        // Skip Indexes By Y-values
        SkipIndsByValues( FInds, DRPVY.UDV );

        // Prepare Resulting Actual Indexes in CFinds (Full CS Indexes)
        SetLength( CFInds, VCSCount );
        // Use K_BuildFullIndex instead of simple copy for DCount calculation
        // DCount - actual Indexes Counter
        DCount := K_BuildFullIndex( @FInds[0], VCSCount,
                              K_GetPIArray0( CFInds ), VCSCount, K_BuildFullActualIndexes );
        if DCount = 0 then Continue; // No Actual Indexes Skip Plane

        // Continue Plane graphic data cretaion
        Inc(NPlanes);

        // Build Label Inds and DX Inds
        BuildVectorDP(); // Build X CSS Actual Indexes in CSInds from CFinds (Full CS Indexes)

        // Build Compressed CSS Indexes in CLInds
        SetLength( CLInds, VCSSCount );
        K_BuildActIndicesAndCompress( nil, nil, K_GetPIArray0( CLInds ),
                                            K_GetPIArray0( CSInds ), VCSSCount );

        // Build Full Back Indexes to Actual Vector Elements Indexes in CFInds
        SetLength( IC, DCount );
        K_FillIntArrayByCounter( @IC[0], DCount );
        FillChar( CFInds[0], VCSCount * SizeOf(Integer), -1 );
        K_MoveVectorByDIndex( CFInds[0], -1, IC[0], -1, SizeOf(Integer),
                              DCount, @CLInds[0] );

        // Build Compressed Indexses of Actual Vector Elements Indexes in CSInds
        K_BuildActIndicesAndCompress( nil, K_GetPIArray0( CSInds ), nil,
                                           K_GetPIArray0( CSInds ), VCSSCount );

        //  Prepare Pure DX Values using CSInds
        AbsValsSVInd := 1;
        PAX := TK_PMVVAttrs(TK_UDRArray(DRPVX.UDVA).R.P);
        BuildVectorVals( DX,  PAX, DRPVX.UDV, true ); // Get Pure DX Values using CSInds

        //  Prepare DY Values
        VCSS := TK_UDMVVector(DRPVY.UDV).GetDCSSpace;
        VCSSCount := VCSS.PDRA.ALength;
        DCSIndsBLeng := SizeOf(Integer)* VCSSCount;
        BuildVectorDP(); // Build Y CSS Actual Indexes in CSInds from CFinds (Full CS Indexes)
        PAY := TK_PMVVAttrs(TK_UDRArray(DRPVY.UDVA).R.P);
        BuildVectorVals( DY,  PAY, DRPVY.UDV, false ); // Get Pure DY Values using CSInds

        // Build MapGroup Component
        MapGroup := N_CreateUDPanel( 'Group1' );
        CCPUDMComp.AddOneChildV( MapGroup );

        with MapGroup.PCCS()^ do begin// Set Map Group Coords
//          CompUCoords := FRect( PAX.VMin, PAY.VMax, PAX.VMax, PAY.VMin ); // Group User Coords
//          CompUCoords := FRect( 0, 0, 30, 30 ); // Group User Coords
          UCoordsType := cutGiven;
        end;

        PointsCObj := TN_UDPoints.Create();
        PointsCObj.ObjName := 'PointsCObj';
        MapGroup.AddOneChildV( PointsCObj );
        MLPoints := nil;
        if CCPUDSigns <> nil then begin
        // Prepare sign attributes
{   Colors Vector for all planes for set individual colors by manual future Edit }
         //  Prepare Colors Vector
          UColors := K_CreateUDByRTypeName( 'color', DCount );
          UColors.ObjName := 'UDColors';
          MapGroup.AddOneChildV( UColors );
          K_MoveVector( UColors.PDE(0)^, -1, DRPSColor, 0,
                        SizeOf(Integer), DCount );
{}
//          UDColors := nil;
          if (K_drpZColor in DRPFlags) and
             (DRPVZ.UDVA <> nil) then begin
          // Prepare signs personal colors

            //  Prepare DZ Values
            VCSS := TK_UDMVVector(DRPVZ.UDV).GetDCSSpace;
            VCSSCount := VCSS.PDRA.ALength;
            DCSIndsBLeng := SizeOf(Integer)* VCSSCount;
            BuildVectorDP();
            PAZ := TK_PMVVAttrs(TK_UDRArray(DRPVZ.UDVA).R.P);
            BuildVectorVals( DZ, PAZ, DRPVZ.UDV, false );
{   Colors Vector only for individual colors
            //  Prepare DZ Colors
            UColors := K_CreateUDByRTypeName( 'color', DCount );
            UDColors.ObjName := 'UDColors';
            MapGroup.AddOneChildV( UDColors );
}
            K_BuildMVVElemsVAttribs( @DZ[0], DCount, PAZ,
                      {PCSSInds} nil, {PTextValues} nil,
                      {NamedTextValues} nil, {PColor} UColors.PDE( 0 ),
                      {SWInds} nil, {PSVA} nil, {Units} '' );
          end; // end of prepare signs personal colors if

          CSInd := Min( CCPUDSigns.DirHigh, DRPSignInd );
          CSInd := Max( 0, CSInd );
          MLPoints := TN_UDMapLayer( N_CreateOneLevelClone( CCPUDSigns.DirChild(CSInd) ) );
          MapGroup.AddOneChildV( MLPoints );
          with MLPoints.PISP()^, MLPoints.PCCS()^ do begin
            MLBrushColor := DRPSColor;
            if (DRPSSize.X <> 0) and (DRPSSize.Y <> 0) then
              MLSSizeXY := DRPSSize;
            LbDefShift := MLSSizeXY;
            if K_drcSkipSignsScale in CPCFlags then
              CoordsScope := ccsDstImage;
            K_SetUDRefField( TN_UDBase(MLCObj), PointsCObj );
            if UColors <> nil then
              K_SetUDRefField( TN_UDBase(MLDVect1), UColors );
          end;
        end; // end of prepare signs attributes if

        if not PlanesCommonMinMax then  begin
          XMax := PAX.VMax;
          XMin := PAX.VMin;
          YMax := PAY.VMax;
          YMin := PAY.VMin;
{
          if (K_drpAxisScaleBalance in DRPFlags) then begin
            XMax := Max( XMax, YMax );
            YMax := XMax;
            XMin := Min( XMin, YMin );
            YMin := XMin;
          end;
}
        end;
        MMX := 100 / (XMax - XMin);
        MMY := 100 / (YMax - YMin);

{ // Prepare Textboxes }
//        if (K_drpShowECaption in DRPFlags) then begin
          with VCS, GetAliasesDir  do begin
            if CPEAliasesName <> '' then
              UDAliases := TK_UDVector( DirChildByObjName( CPEAliasesName, K_ontObjUName ) )
            else
              UDAliases := TK_UDVector( DirChild(0) );

            if UDAliases <> nil then
              VAliases := UDAliases.PDRA^
            else
              VAliases := TK_PDCSpace(R.P).Names;
          end;
//        end;
{}
        if GroupByValueFlag then begin
        // Group Points by Value
          for j := 0 to DCount - 1 do begin
            DX[j] :=  WPGroupStep.X * ( Floor(DX[j] / WPGroupStep.X) + 0.5 );
            DY[j] :=  WPGroupStep.Y * ( Floor(DY[j] / WPGroupStep.Y) + 0.5 );
          end;
        end;

        if (K_drcSkipSignsScale in CPCFlags) or
           GroupByValueFlag then begin
        // Order Plane Points
          SetLength(PtrsArray, DCount);
          SetLength(Inds, DCount);
          K_FillIntArrayByCounter( PInteger(@PtrsArray[0]), DCount, SizeOf(Integer),
                                   Integer(@Inds[0]), SizeOf(Integer) );
          K_FillIntArrayByCounter( @Inds[0], DCount );
          N_SortPointers( PtrsArray, CompPointCoords );
          N_PtrsArrayToElemInds( @Inds[0], PtrsArray,
                                 @Inds[0], SizeOf(Integer) );
        end;

        if (K_drcSkipSignsScale in CPCFlags) and
           not GroupByValueFlag then begin
        // Spread coincident points
          CPInd1 := Inds[0];
          ClearSpreadPoint();
          if CCSpreadPointStep = 0 then CCSpreadPointStep := 0.1;
          for j := 1 to DCount - 1 do begin
            CPInd2 := Inds[j];
            if (DX[CPInd1]= DX[CPInd2]) and
               (DY[CPInd1]= DY[CPInd2]) then begin
              Inc(EPCount);
              SpreadPoint();
            end else
              ClearSpreadPoint();
            CPInd1 := CPInd2;
          end;
        end;


        SetLength( SA[NPlanes - 1], DCount );
        CurLTexts := SA[NPlanes - 1];
        with CCSGMLP.SComps[NPlanes - 1] do begin
          SComp := MLPoints;
          SFlags := $F;
          if K_drcSkipSignsScale in CPCFlags then SFlags := $1F;
          SCUserTag := Integer(CurLTexts);
        end;
{
        with CCSGMLL.SComps[NPlanes - 1] do begin
          SComp := MLPoints;
          SFlags := $F;
        end;
}

        CSInd := -1;
        // Calculate Sing Index to get some Label Attributs for TextBox
        if (CCPUDLabels <> nil) then begin
          CSInd := Min( CCPUDLabels.DirHigh, DRPSignInd );
          CSInd := Max( 0, CSInd );
        end;

        if K_drpShowECaption in DRPFlags then
          with CCEdRFA do begin
            ECNumComps := ECNumComps + DCount;
            SetLength( ECComps, ECNumComps );
            SetLength( ECCurRects,  ECNumComps );
            SetLength( ECBaseRects, ECNumComps );
            ECSavedSrcPRect.Left := N_NotAnInteger; // to force recalculating Pix Coords
          end;

        if GroupByValueFlag then begin
          k := 0;
          kb := 0;
//          ki := 0;
          CPInd1 := Inds[0];
          GPX := DX[CPInd1];
          GPY := DY[CPInd1];
          GroupText := PString(VAliases.P(CLInds[CPInd1]))^;
          for j := 1 to DCount - 1 do begin
            CPInd1 := Inds[j];
            CGPX := DX[CPInd1];
            CGPY := DY[CPInd1];
            CurLText := PString(VAliases.P(CLInds[CPInd1]))^;
            if (CGPX = GPX) and (CGPY = GPY) then begin
              GroupText := GroupText + #13#10 + CurLText;
            {
              if (ki and 1) = 1 then
                GroupText := GroupText + #13#10 + CurLText
              else
                GroupText := GroupText + ' ' + CurLText;
              Inc(ki);
            }
            end else begin
              AddPointInfo( k, GPX, GPY, GroupText, CCPUDMPTBPat,
                            LbDefShift.X / 2 + 1,
                            LbDefShift.Y / 2 + 1 - LbDefShift.Y * (j - kb - 1) / 2 );
              Inc( k );
              kb := j;
              GroupText := CurLText;
//              ki := 0;
            end;
            GPX := CGPX;
            GPY := CGPY;
          end;
          AddPointInfo( k, GPX, GPY, GroupText, CCPUDMPTBPat,
                        LbDefShift.X / 2 + 1,
                        LbDefShift.Y / 2 + 1  - LbDefShift.Y * (DCount - kb - 1) / 2 );
{//}          Inc( k );
{//}          SetLength( CurLTexts, k );
          with CCEdRFA do
            if ECNumComps > ECNInd then
              ECNumComps := ECNInd;
        end else
          for j := 0 to DCount - 1 do begin
            CPCoords := DPoint( (DX[j] - XMin)* MMX, (YMax - DY[j])* MMY );
            PointsCObj.AddOnePointItem( CPCoords, -1 );
            CurLText := PString(VAliases.P(CLInds[j]))^;
            CurLTexts[j] := CurLText;
  { // Prepare Textboxes }
            if (K_drpShowECaption in DRPFlags) then begin
              CCEdRFA.ECComps[ECNInd] := TN_UDCompvis(MapGroup.AddOneChild( N_CreateOneLevelClone( CCPUDSPTBPat ) ));
              with TN_UDParaBox(CCEdRFA.ECComps[ECNInd]),
                   PISP()^, PCCS()^  do begin
                Inc( ECNInd );
                ObjName := 'L' + IntToStr(j + 1);
                ObjAliase := CurLText;
                if K_drcSkipSignsScale in CPCFlags then
                  CoordsScope := ccsDstImage;
                BPCoords := FPoint( CPCoords );
//                BPPos.X := 0;
//                BPPos.Y := 0;
//                if (DRPLHPoint.X <> 0) or (DRPLHPoint.Y <> 0) then
//                  BPPos := DRPLHPoint;
                if (DRPLShift.X <> 0) or (DRPLShift.Y <> 0) then
                  BPShift := DRPLShift
                else begin
                  BPShift.X := LbDefShift.X / 2;
                  BPShift.Y := LbDefShift.Y / 2;
                end;
                CPBNewSrcHTML := CurLText;
                with TN_POneTextBlock(CPBTextBlocks.P)^ do
                  if DRPLFont <> nil then
                    TK_RArray(OTBNFont) := DRPLFont.AAddRef
                  else if CSInd <> -1 then
                      TK_RArray(OTBNFont) :=
                        TK_RArray(TN_UDMapLayer( CCPUDLabels.DirChild(CSInd) ).PISP()^.MLVAux1).AAddRef;
              end;
  {!!
              with TN_UDParaBox(MapGroup.AddOneChild( K_CreateUDByRTypeName( 'TN_RParaBox', 1, N_UDParaBoxCI ) )),
                   PISP()^, PCCS()^  do begin
                ObjName := 'L' + IntToStr(j + 1);
                ObjAliase := CurLText;
                BPXCoordsType := cbpUser;
                BPYCoordsType := cbpUser;
                CPBSRTLFlags := [srtlContWidth,srtlContHeight];
                if K_drcSkipSignsScale in CPCFlags then
                  CoordsScope := ccsDstImage;
                BPCoords := FPoint( CPCoords );
                if (DRPLHPoint.X <> 0) or (DRPLHPoint.Y <> 0) then
                  BPPos := DRPLHPoint;
                if (DRPLShift.X <> 0) or (DRPLShift.Y <> 0) then
                  BPShift := DRPLShift
                else begin
                  BPShift.X := LbDefShift.X / 2;
                  BPShift.Y := LbDefShift.Y / 2;
                end;
                CPBNewSrcHTML := CurLText;
                if CSInd <> -1 then begin
                  CPBTextBlocks := K_RCreateByTypeCode( N_SPLTC_OneTextBlock, 1, [K_crfCountUDRef] );
                  with TN_POneTextBlock(CPBTextBlocks.P)^ do begin
                    TK_RArray(OTBNFont) :=
                      TK_RArray(TN_UDMapLayer( CCPUDLabels.DirChild(CSInd) ).PISP()^.MLVAux1).AAddRef;
                    OTBBackColor := N_EmptyColor;
                  end;
                end;
              end;
  {}
            end;
  {}
          end;

{ // Prepare Labels
        if (CCPUDLabels <> nil) and
           (K_drpShowECaption in DRPFlags) then begin
        // Show labels
//          CSInd := Min( CCPUDLabels.DirHigh, DRPSignInd ); // Skip because it is already defind for TextBoxes
//          CSInd := Max( 0, CSInd );                        //

          UDLabels := K_CreateUDByRTypeName( 'string', DCount );
          UDLabels.ObjName := 'UDLabels';
          MapGroup.AddOneChildV( UDLabels );
          PLabel := PString(UDLabels.PDE( 0 ));

//          with VCS do begin
//            UDAliases := TK_UDVector( GetAliasesDir.DirChild(0) );
//            if UDAliases <> nil then
//              VAliases := UDAliases.PDRA^
//            else
//              VAliases := TK_PDCSpace(R.P).Names;
//          end;

          K_MoveSPLVectorBySIndex( UDLabels.PDE( 0 )^, -1, VAliases.P^, -1,
             DCount, Ord(nptString), [K_mdfFreeDest], K_GetPIArray0( CLInds )  );

          MLLabels := TN_UDMapLayer(N_CreateOneLevelClone( CCPUDLabels.DirChild(CSInd) ));
          MapGroup.AddOneChildV( MLLabels );
          with MLLabels.PISP()^, MLLabels.PCCS()^ do begin
            if K_drcSkipSignsScale in CPCFlags then
              CoordsScope := ccsDstImage;
             if (DRPLHPoint.X <> 0) or (DRPLHPoint.Y <> 0) then
               MLHotPoint := DRPLHPoint;
             if (DRPLShift.X <> 0) or (DRPLShift.Y <> 0) then
               MLShiftXY := DRPLShift;

            K_SetUDRefField( TN_UDBase(MLCObj),   PointsCObj );
            K_SetUDRefField( TN_UDBase(MLDVect1), UDLabels );
          end;
        end; // end of show labels if
{}
      end; // end of Current plane with
    end; // end of planes Loop

  //*** Corect Planes Hints Info
    SetLength( SA, NPlanes ); // Array of Hint Texts Arrays for Picture Layers
    SetLength( CCSGMLP.SComps, NPlanes ); // Array of Picture Layers Search Attributes
//    SetLength( CCSGMLL.SComps, NPlanes ); // Array of Picture Layers Search Attributes

  //*** Set Resulting Graph Space MinMax,Axis and Add Lines Attributes
    if NPlanes > 0 then begin

      with TN_UD2DSpace(CCPUD2DComp).PISP()^ do begin
        TDSArgMin  := XMin;
        TDSArgMax  := XMax;
        TDSFuncMin := YMin;
        TDSFuncMax := YMax;
      end;

  //*** Set Graph Diag Coords
      with TN_ULines(CCPUDDiagCComp) do begin
        for i := 0 to 5 do
          LDCoords[i] := DPoint( -200, -200 );

        if K_drcShowDiagonal in CorPictCFlags then begin
          WDX := Min( XMax, YMax );
          WDY := Max( XMin, YMin );
          if WDX > WDY then begin
            LDCoords[0] := DPoint( (WDY - XMin)* MMX, (YMax - WDY)* MMY );
            LDCoords[1] := DPoint( (WDX - XMin)* MMX, (YMax - WDX)* MMY );
          end;
        end;

        if K_drcShowQuadrants in CorPictCFlags then begin
          WDX := Max( XMax, YMax );
          WDY := Min( XMin, YMin );
          WDV := (WDX + WDY) / 2;
          if (WDV > XMin) and (WDV < XMax) then begin
            LDCoords[2].X := (WDV - XMin)* MMX;
            LDCoords[2].Y := 0;
            LDCoords[3].X := LDCoords[2].X;
            LDCoords[3].Y := 100;
          end;
          if (WDV > YMin) and (WDV < YMax) then begin
            LDCoords[4].X := 0;
            LDCoords[4].Y := (YMax - WDV)* MMY;
            LDCoords[5].X := 100;
            LDCoords[5].Y := LDCoords[4].Y;
          end;
        end;
      end;

  //*** Set Axis Ticks Attriutes
      if CCPUDParams <> nil then begin
        with CCPUDParams do begin
          WDX := XMax - XMin;
          WDY := YMax - YMin;
          if WDY > WDX then begin
            K_BuildAxisTicksAttrs( AxisTickStep, AxisCharLength,
                                  @AxisTickFormat, nil, YMin, YMax );
            SetYTicksAttrs( );

            if WDY/WDX > 2.25 then
              K_BuildAxisTicksAttrs( AxisTickStep, AxisCharLength,
                                    @AxisTickFormat, nil, XMin, XMax );
            SetXTicksAttrs( );
          end else begin
            K_BuildAxisTicksAttrs( AxisTickStep, AxisCharLength,
                                  @AxisTickFormat, nil, XMin, XMax );
            SetXTicksAttrs( );

            if WDX/WDY > 2.25 then
              K_BuildAxisTicksAttrs( AxisTickStep, AxisCharLength,
                                    @AxisTickFormat, nil, YMin, YMax );
            SetYTicksAttrs( );
          end;

          if GroupByValueFlag then begin
            RAParams := GetSUserParRArray( 'YTickLinesStep' );
            if RAParams <> nil then
              PDouble(RAParams.P)^ := WPGroupStep.Y;
            RAParams := GetSUserParRArray( 'XTickLinesStep' );
            if RAParams <> nil then
              PDouble(RAParams.P)^ := WPGroupStep.X;
          end;

        //*** Ticks Lines
          TickLinesFlag := 255;
          if K_drcShowTickLines in CorPictCFlags then
            TickLinesFlag := 0;
        // Skip too close tick lines in GroupByValue Mode
          if GroupByValueFlag and
             ( ((XMax - XMin) / WPGroupStep.X > 50) or
               ((YMax - YMin) / WPGroupStep.Y > 50) ) then
            TickLinesFlag := 255;

          RAParams := GetSUserParRArray( 'XTickLinesFlag' );
          if RAParams <> nil then
            PByte(RAParams.P)^ := TickLinesFlag;
          RAParams := GetSUserParRArray( 'YTickLinesFlag' );
          if RAParams <> nil then
            PByte(RAParams.P)^ := TickLinesFlag;

        end;
      end; // end of set Axis Ticks Attributes
    end; //

    with CCEdRFA do begin
      ActEnabled := ActEnabled and (ECNumComps > 0);
      if ActEnabled then
        K_DataReverse( ECComps[0], SizeOf(Integer), ECNumComps );
    end;

  //*********************************************************************
  // Recalc Root Component Size and Graph Component Size and Position
  //*********************************************************************
    WCPSize := CPSize; // Save Picture size for checking if picture size would be realy changed
    PCompCoords := TN_UDCompVis(CCPUDComp).PCCS();
    with PCompCoords.SRSize do
      if (CPSize.X = 0)  or (CPSize.Y = 0) then begin
      // Set CorPict component size if not given
        CPSize.X := X;
        CPSize.Y := Y;
      end;
//    if (CCPHeaderHeight > 0) then begin
    if true then begin
    //*** Recalc only if real Graph Component Top is definded

    //*** Get Graph Min Gaps
      PCompPatCoords := TN_UDCompVis(CCPUDCompPat).PCCS();
      PGCompCoords   := TN_UDCompVis(CCPUDGCompPat).PCCS();
      DXGraph := PCompPatCoords.SRSize.X - PGCompCoords.SRSize.X;
      DYGraph := PCompPatCoords.SRSize.Y - PGCompCoords.SRSize.Y;
      GMinLeftGap := PGCompCoords.BPCoords.X;
      GMinTopGap  := PGCompCoords.BPCoords.Y;
      GMinBotGap  := DYGraph - GMinTopGap;

      if K_drcHeaderAboveGraph in CPCFlags then begin
        DYGraph := DYGraph + CCPHeaderHeight - GMinTopGap + 0.2;
        GMinTopGap := CCPHeaderHeight + 0.2;
      end;

      with PCompCoords^ do begin
        PrepGraphSize( SRSize );
        NewPageSizeFlag := (SRSize.X <> CPSize.X) or
                           (SRSize.Y <> CPSize.Y);
      end;

      PGCompCoords := TN_UDCompVis(CCPUDGComp).PCCS();

      if CCRecalFlagGraphPos                    or
         NewPageSizeFlag                        or
         (K_drcAutoEnlargePictSize in CPCFlags) or
         (K_drcSavePictAspect      in CPCFlags) then begin

        // Recalc Page size
        DAspect := (YMax - YMin) / (XMax - XMin);
        if NewPageSizeFlag  or
          (K_drcAutoEnlargePictSize in CPCFlags) then begin
          if K_drcSavePictAspect in CPCFlags then begin
            GraphWidth := GraphCurMaxHeight / DAspect;
            CurSizeAspect := (GraphCurMaxHeight + DYGraph) /
                             (GraphWidth + DXGraph);
          end else
            CurSizeAspect := CPSize.Y / CPSize.X;

          if CurSizeAspect > 1 then
            CorrectPageSize( CCPMaxSizeMax, CCPMaxSizeMin,
                             (K_drcAutoEnlargePictSize in CPCFlags) )
          else
            CorrectPageSize( CCPMaxSizeMin, CCPMaxSizeMax,
                             (K_drcAutoEnlargePictSize in CPCFlags) );
          PCompCoords.SRSize := CPSize;

          GraphCurMaxWidth := CPSize.X - DXGraph;
          GraphCurMaxHeight:= CPSize.Y - DYGraph;
          GraphHeight := GraphCurMaxHeight;
          GraphWidth := GraphCurMaxWidth;
        end;

        // Recalc Graph Size
        if K_drcSavePictAspect in CPCFlags then begin
          GraphWidth := GraphCurMaxHeight / DAspect;
          GraphHeight := GraphCurMaxWidth * DAspect;
          if GraphWidth <= GraphCurMaxWidth then
            GraphHeight := GraphCurMaxHeight
          else
            GraphWidth := GraphCurMaxWidth;
        end;

        // Set New Graph Pos and Size
        with PGCompCoords^ do begin
          SRSize.X := GraphWidth;
          SRSize.Y := GraphHeight;
          BPCoords.X := GMinLeftGap + (GraphCurMaxWidth - GraphWidth) / 2;
          BPCoords.Y := GMinTopGap + (GraphCurMaxHeight - GraphHeight) / 2;
        end;

      end else
        with PGCompCoords^ do begin
          BPCoords.X := GMinLeftGap;
          SRSize.X := GraphCurMaxWidth;
          SRSize.Y := GraphCurMaxHeight;
        end;

      PHCompCoords := TN_UDCompVis(CCPUDCurHComp).PCCS();
      with PHCompCoords^ do
        if not (K_drcHeaderAboveGraph in CPCFlags) then begin
          BPCoords.Y := PGCompCoords.BPCoords.Y + CPHShift.Y;
          if CPHShift.X = -100 then
            BPCoords.X := PGCompCoords.BPCoords.X +
                                Max( 0, (PGCompCoords.SRSize.X - CCPHeaderWidth) / 2 )
          else
            BPCoords.X := PGCompCoords.BPCoords.X + CPHShift.X;
//          BPCoords.Y := PGCompCoords.BPCoords.Y + CPHShift.Y;
//          BPCoords.X := PGCompCoords.BPCoords.X + CPHShift.X +
//                                Max( 0, (PGCompCoords.SRSize.X - CCPHeaderWidth) / 2 );
        end;
//        end else begin
//          BPCoords.Y := 0;
//          BPCoords.X := (CPSize.X - CCPHeaderWidth) / 2;
//        end else begin
    end; // end of if Recalc is neded


    CCRecalFlagGraphPos := CCPHeaderHeight = 0;
    if Assigned( OnSetContext ) and
       not CompareMem( @WCPSize, @CPSize, SizeOf(CPSize) ) then
      OnSetContext();

  end; // end of CorPict with

end; // end of TK_PrepCorPictCompContext.SetContext
{
//********************************************** TK_PrepCorPictCompContext.SpreadCoincidentPoints
//
procedure TK_PrepCorPictCompContext.SpreadCoincidentPoints;
var
  PtrsArray : TN_PArray;
  RCount : Integer;
  Inds : TN_IArray;
begin
  RCount := Length(DX);
  SetLength(PtrsArray, RCount);
  SetLength(Inds, RCount);
  K_FillIntArrayByCounter( PInteger(@PtrsArray[0]), RCount, SizeOf(Integer),
                           Integer(@Inds[0]), SizeOf(Integer) );
  K_FillIntArrayByCounter( @Inds[0], RCount );
  N_SortPointers( PtrsArray, CompPointCoords );
  N_PtrsArrayToElemInds( @Inds[0], PtrsArray,
                         @Inds[0], SizeOf(Integer) );


end; // end of TK_PrepCorPictCompContext.SpreadCoincidentPoints
}
//********************************************** TK_PrepCorPictCompContext.CompPointCoords
//
function TK_PrepCorPictCompContext.CompPointCoords( Ptr1, Ptr2 : Pointer ): Integer;
var
  IndP1, IndP2 : Integer;
  PV1, PV2 : PDouble;
begin
  IndP1 := PInteger(Ptr1)^;
  IndP2 := PInteger(Ptr2)^;
  PV1 := @DX[IndP1];
  PV2 := @DX[IndP2];
  if PV1^ = PV2^ then begin
    PV1 := @DY[IndP1];
    PV2 := @DY[IndP2];
  end;
  if PV1^ = PV2^ then
    Result := 0
  else if PV1^ > PV2^ then
    Result := 1
  else
    Result := -1;
end; // end of TK_PrepCorPictCompContext.CompPointCoords

{*** end of TK_PrepCorPictCompContext ***}

{*** TK_PrepCorPictLegCompContext ***}

//********************************************** TK_PrepCorPictLegCompContext.Destroy
//
destructor TK_PrepCorPictLegCompContext.Destroy;
begin
  CCPCorPictRA.ARelease;
  inherited;
end; // end of TK_PrepCorPictLegCompContext.Destroy

//********************************************** TK_PrepCorPictLegCompContext.BuildSelfAttrs
//
procedure TK_PrepCorPictLegCompContext.BuildSelfAttrs;
begin
  K_RFreeAndCopy( CCPCorPictRA, CCPCorPictRA, [K_mdfCopyRArray] );
end; // end of TK_PrepCorPictLegCompContext.BuildSelfAttrs

//********************************************** TK_PrepCorPictLegCompContext.SetContext
//
procedure TK_PrepCorPictLegCompContext.SetContext;
var
  PointsCObj: TN_UDPoints;
  MLPoints, MLLabels: TN_UDMapLayer;
  MapRoot : TN_UDBase;
  PlaneRoot : TN_UDBase;
  PlaneMapRoot : TN_UDBase;
  PlaneAxisTB : TN_UDBase;
  UColors, ULabels: TK_UDRArray;
  i : Integer;
  CSInd : Integer;
  DCount : Integer;
  HCount : Integer;
  PMVCorPictPlane : TK_PMVCorPictPlane;
  BiuldColorsLeg : Boolean;
  PAZ : TK_PMVVAttrs;
  ACHeight : Double;
  BCHeight : Double;
  PlaneDY : Double;
  YShift : Double;
//  XShift : Double;

  function GetLegCaption : string;
  begin
    with PMVCorPictPlane^ do begin
      Result := DRPLegCapt;
      if Result = '' then
        Result := DRPCaption;
      if Result = '' then
        Result := DRPVZ.VCaption;
    end;
  end;

  procedure AddLegLayer( AddColorsLayer : Boolean; SignColor : Integer );
  var
    j : Integer;
    DS : Double;
    CHeight : Double;
  begin
    with PMVCorPictPlane^  do begin // Curent plane with

      MapRoot := PlaneMapRoot.AddOneChildV( N_CreateOneLevelClone( CCPUDLegMCompPat ) );
      MapRoot.ObjName := 'LegElems';
      PointsCObj := TN_UDPoints.Create();
      PointsCObj.ObjName := 'PointsCObj';
      MapRoot.AddOneChildV( PointsCObj );
      if BiuldColorsLeg and not AddColorsLayer then
        TN_UDCompVis(MapRoot).PCCS()^.BPCoords.X := 0;

      UColors := nil;
      YShift := 50;
      if AddColorsLayer then begin
        UColors := K_CreateUDByRTypeName( 'color', DCount );
        UColors.ObjName := 'UDColors';
        Move( PAZ.RangeColors.P^, UColors.PDE(0)^, DCount * SizeOf(Integer) );
        MapRoot.AddOneChildV( UColors );
        HCount := DCount;
        if HCount > 1 then Dec(HCount);
        DS := 100 / DCount;
        YShift := DS * 0.5;
        for j := 0 to DCount - 1 do
          PointsCObj.AddOnePointItem( DPoint( 1, YShift + j * DS ), -1 );
        CHeight := CCPLegEStep * (DCount);
      end else begin
        CHeight := CCPLegEStep;
        if not BiuldColorsLeg then
          YShift := 100;
//        XShift := 0;
//        if BiuldColorsLeg and not AddColorsLayer then
//          XShift := -CCLegEStep;
        PointsCObj.AddOnePointItem( DPoint( 0, YShift ), -1 );
      end;

      if (CCPUDSigns <> nil) and
         (not BiuldColorsLeg or AddColorsLayer) then begin
      // Prepare sign attributes
        CSInd := Min( CCPUDSigns.DirHigh, DRPSignInd );
        CSInd := Max( 0, CSInd );
        MLPoints := TN_UDMapLayer( N_CreateOneLevelClone( CCPUDSigns.DirChild(CSInd) ) );
        MapRoot.AddOneChildV( MLPoints );
        with MLPoints.PISP()^, MLPoints.PCCS()^ do begin
          MLBrushColor := SignColor;
          if (DRPSSize.X <> 0) and (DRPSSize.Y <> 0) then
            MLSSizeXY := DRPSSize;
          CoordsScope := ccsParent;
          K_SetUDRefField( TN_UDBase(MLCObj), PointsCObj );
          if UColors <> nil then
            K_SetUDRefField( TN_UDBase(MLDVect1), UColors );
        end;
      end; // end of prepare signs attributes if

      if (CCPUDLabels <> nil) then begin
      // Show labels
        CSInd := Min( CCPUDLabels.DirHigh, DRPSignInd );
        CSInd := Max( 0, CSInd );

        ULabels := K_CreateUDByRTypeName( 'string', DCount );
        ULabels.ObjName := 'UDLabels';
        MapRoot.AddOneChildV( ULabels );
        if AddColorsLayer then begin
          for j := 0 to DCount - 1 do begin
            PString(ULabels.PDE( j ))^ := PString(PAZ.RangeCaptions.P(j))^;
          end;
        end else
          PString(ULabels.PDE( 0 ))^ := GetLegCaption();

        MLLabels := TN_UDMapLayer(N_CreateOneLevelClone( CCPUDLabels.DirChild(CSInd) ));
        MapRoot.AddOneChildV( MLLabels );
        with MLLabels.PISP()^, MLLabels.PCCS()^ do begin
          MLHotPoint := FPoint( 0, 0.5 );
          MLShiftXY := FPoint( 10, 0 );
          with TN_PNFont(K_GetPVRArray( MLVAux1 )^.P)^ do begin
            NFLLWHeight := CCPLegFontHeight;
            NFWin.lfItalic := 0;
          end;
          CoordsScope := ccsParent;
          K_SetUDRefField( TN_UDBase(MLCObj),   PointsCObj );
          K_SetUDRefField( TN_UDBase(MLDVect1), ULabels );
        end;
      end; // end of show labels if

      with TN_UDCompVis(MapRoot).PCCS()^ do begin// Set Map Group Coords
        SRSize.Y := CHeight;
        UCoordsType := cutGiven;
        BCHeight := BCHeight + CHeight;
//        ACHeight := ACHeight + CHeight + BPCoords.Y;
      end;

    end; // end of Current plane with
  end;

begin
  inherited;

  if (CCPUDLegComp = nil) or (CCPUDLegMCompPat = nil) then Exit;

  CCPUDLegComp.ClearChilds();

//  CCLegEStep := 5;
  ACHeight := 0;
  with TK_PMVCorPict(CCPCorPictRA.P)^ do begin
    PAZ := nil;
    for i := 0 to CPPlanes.AHigh do begin
    // 2DR Planes Loop
      PMVCorPictPlane := CPPlanes.P(i);
      with PMVCorPictPlane^ do begin // Curent plane with

        if not K_IfShowCorPictPlane( PMVCorPictPlane ) or
          (DRVCSInds.ALength = 0) then Continue;
        BiuldColorsLeg := {(CCPUDLegHCompPat <> nil) and}
                          (DRPVZ.UDV <> nil)     and
                          (K_drpZColor in DRPFlags);
        DCount := 1;
        PlaneRoot := CCPUDLegComp.AddOneChildV( N_CreateSubTreeClone( CCPUDPlaneComp ) );
        PlaneMapRoot := PlaneRoot.GetObjByRPath(CCPUDPlaneMRCompLP);
        BCHeight := 0;
        if BiuldColorsLeg then begin
          PAZ := TK_PMVVAttrs(TK_UDRArray(DRPVZ.UDVA).R.P);
          DCount := PAZ.RangeCaptions.ALength;
          AddLegLayer( false, $FFFFFF );
          AddLegLayer( true, DRPSColor );
        end else
          AddLegLayer( false, DRPSColor );

      // Add Height to Plane Root
        with TN_UDCompVis(PlaneMapRoot).PCCS()^ do
           PlaneDY := BCHeight - SRSize.Y;
        with TN_UDCompVis(PlaneRoot).PCCS()^ do begin
          if PlaneDY > 0 then
            SRSize.Y := SRSize.Y + PlaneDY;
          ACHeight := ACHeight + SRSize.Y + BPCoords.Y;
        end;
        // X axis caption
        PlaneAxisTB := PlaneRoot.GetObjByRPath(CCPUDPlaneXANCompLP);
        TN_UDParaBox(PlaneAxisTB).PISP()^.CPBNewSrcHTML := DRPVX.VCaption;
        // Y axis caption
        PlaneAxisTB := PlaneRoot.GetObjByRPath(CCPUDPlaneYANCompLP);
        TN_UDParaBox(PlaneAxisTB).PISP()^.CPBNewSrcHTML := DRPVY.VCaption;
      end; // end of Current plane with
    end; // end of planes Loop
  end; // end of 2DR with
  if ACHeight > 0 then
    with TN_UDCompVis(CCPUDLegComp).PCCS()^ do
      SRSize.Y := ACHeight + 5;
end; // end of TK_PrepCorPictLegCompContext.SetContext

{*** end of TK_PrepCorPictLegCompContext ***}


{*** TK_CorPictRFA ***}

//****************************************************** TK_CorPictRFA.Execute ***
// Show Info about object
//
procedure TK_CorPictRFA.Execute;
var
  Str : string;
begin
//  inherited;
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
  begin

    if (SRType =  srtNone)     or
       (CHType <> htMouseMove) or
       (CurMLCObj = nil)       then begin
      ShowHint := false;
      Exit;
    end;

//    TN_SArray(SComps[CurSCompInd].SCUserTag)[ItemInd];
    Str := TN_SArray(SComps[CurSCompInd].SCUserTag)[ItemInd];
    if not ShowHint or
       ((CLObj = CurMLCObj) and (CIInd = ItemInd)) then begin
      Hint := Str;
      if not ShowHint then ShowHint := true;
    end else
      ShowHint := false;

    CLObj := CurMLCObj; // Current Layer Object
    CIInd := ItemInd;   // Current Layer Item Index
    ShowString( 1, Str );

    //    Str := Format( 'ObjName: %s, ItemInd=%d', [CurMLCObj.ObjName, ItemInd] );
  end; // with ActGroup, ActGroup.RFrame do

end; // end of TK_CorPictRFA.Execute;

//************************************************* TK_CorPictRFA.RedrawAction ***
// Redraw Temporary Action objects
// (should be called from RFrame.RedrawAll )
//
procedure TK_CorPictRFA.RedrawAction;
begin
//  inherited;

end; // end of TK_CorPictRFA.RedrawAction;

//************************************************* TK_CorPictRFA.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TK_CorPictRFA.SetActParams;
begin
// inherited;

end; // end of TK_CorPictRFA.SetActParams();

{*** end of  TK_CorPictRFA ***}

end.
