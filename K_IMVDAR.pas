unit K_IMVDAR;


interface
uses
  Classes,
  K_Types, K_CLib0, K_UDConst, K_UDT1, K_UDT2, K_Script1, K_SParse1,
  N_BaseF, N_ClassRef, N_Types;

type TK_MVCopyObjsFlags = Set of (
  K_mvcCopyFolderChilds,
  K_mvcCopySubFolders,
  K_mvcCopyFullSubTree,
  K_mvcCopyChildsAction
);

type TK_MVDARSysType = (
//*** New Objects SysTypes
  K_msdSValSets,
  K_msdWinDescrs, K_msdMapDescrs,
  K_msdColorPaths,
//*** Spec Folders SysTypes
  K_msdObjTemplates, K_msdMVRCAFolder, K_msdMVRCSAFolder, K_msdMSOPFolder,
//*** Spec Objects SysTypes
  K_msdWebCartWins, K_msdWebCartGroupWins,
  K_msdWebFolder, K_msdFolder,
  K_msdWebVTreeWins, K_msdWebTableWins, K_msdWebLDiagramWins,
  K_msdWebWinGroups, K_msdVWFrameSets, K_msdWebSite,
  K_msdWebHTMWins, K_msdWebHTMRefWins, K_msdWebVHTMWins, K_msdWebVHTMRefWins,
  K_msdVWLayouts, K_msdVWindows, K_msdVWFrames,
  K_msdMLDColorFills, K_msdWCartLayers,
  K_msdBTables, K_msdMVVectors, K_msdMVVAtribs,
  K_msdMSOParams, K_msdMVRComAttrs, K_msdMVRCSAttrs,
  K_msdMVCorPict, K_msdMVRVisComp,
  K_msdUndef );
type TK_MVSysTypeArray = array of TK_MVDARSysType;

type TK_MVDARCommonSysType = (
  K_cstSpecValues );

//type TK_MesStatus = (K_msInfo, K_msWarning, K_msError);
//type TK_MVShowProgressProc = procedure ( MessageLine : string; ProgressStep : Integer = -1 ) of object;
//type TK_MVShowMessageProc = procedure ( MessageLine : string; MesStatus : TK_MesStatus = K_msInfo ) of object;
type TK_MVShowDumpProc = procedure ( DumpLine : string ) of object;


type  TK_ScanMVUDSubTree = class( TObject ) //
  constructor Create( );
  destructor  Destroy(); override;
  procedure   IniLists();

  procedure MVUDSubTreeScan( UDRoot : TN_UDBase;
         TestNodeFunc : TK_TestUDChildFunc;
         AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags );

//*** Build List of SubTree Nodes by Filter Scan Functions
//  Nodes  - List of SubTree Nodes of Specified Type
  function  BuildNodesFilteredListFunc( UDParent : TN_UDBase; var UDChild : TN_UDBase;
    ChildInd : Integer; ChildLevel : Integer; const FieldName : string = '' ) : TK_ScanTreeResult;
  function  BuildNodesFilteredListFunc1( UDParent : TN_UDBase; var UDChild : TN_UDBase;
    ChildInd : Integer; ChildLevel : Integer; const FieldName : string = '' ) : TK_ScanTreeResult;

//*** Build List of MVDar SubTree Nodes and Uniq IDs (Scan only MVFolders Parent Nodes
//  NodesSL  - Strings with SubTree Nodes and it's names
  function  BuildMVFoldersSubTreeChildsListFunc( UDParent : TN_UDBase; var UDChild : TN_UDBase;
    ChildInd : Integer; ChildLevel : Integer; const FieldName : string = '' ) : TK_ScanTreeResult;
private
  CurSysType : TK_MVDARSysType;
  CurNode : TN_UDBase;
  RefNodes0    : TList;
  function  CheckNode( Ind : Integer ) : Boolean;
public
//*** Build List of MVDar SubTree Nodes and Uniq IDs fields
  BuildNodeIDFlags : TK_BuildUDNodeIDFlags;
  NodesSL : TStrings;
//*** Build List of SubTree Nodes by Filter fields
  ScanSysTypeFilter : TK_MVSysTypeArray;
  NodeFilter1 : TN_UDBase;
  ScanRootNode : Boolean;
  property Nodes   : TList read RefNodes0;
end;

procedure K_InitMVDarGCont( UDArchive : TN_UDBase = nil );
procedure K_InitMVDarGCont0( UDArchive : TN_UDBase = nil );
procedure K_InitMVDarGCont1( CurArchive : TN_UDBase = nil );
function  K_MVDarGetUserNodeType( cnode : TN_UDBase ): TK_MVDARSysType;
procedure K_InitMVObjectCaptions( UDMVObj : TN_UDBase; ObjSysType : TK_MVDARSysType = K_msdUndef );


var
  K_CurMVDARRoot : TN_UDBase; // MVDAR Root
  K_CurArchSpecVals : TN_UDBase; // CurArchive Special Values - UDRArray
  K_CurArchDefColorsSet : TN_UDBase; // CurArchive Default Colors Set - UDRArray

const

  K_MVDARSysDirNames : array [0..Ord(K_msdWebCartWins)-1] of string = (
//*** New Objects SysFolders Names
     'Common',
     'WinDescrs', 'MapDescrs',
     'MVColorPaths',
     'ObjTemplates', 'MVRCompAttrs', 'MVRCSAttrs', 'MSOComps' );

  K_MVDARSysObjNames : array [0..Ord(K_msdUndef)-1] of string = (
//*** Name Prefixes of New Objects which are stored in SysFolders
     '~SVS',
     '~WD', '~MD',
     '~CP',
//*** Reserved for Spec Folders SysTypes
     '', '', '', '',
//*** Name Prefixes of Objects which are not stored in SysFolders
     '~CG', '~GCG',
     '~WF', '~F',
     '~WS', '~WWT', '~WLD',
     '~WG', '~WC', '~WST',
     '~HT', '~RH', '~GHT', '~GRH',
     '~WL', '~WW', '~FR',
     '~MLD', '~CGL',
     '~WT', '~VV', '~VA',
     '~MSOP', '~RCP', '~RCSP',
     '~CPT', '~RVC' );

  K_MVDARSysObjALiases : array [0..Ord(K_msdUndef)-1] of string = (
//*** Aliases of New Objects which are stored  in SysFolders
    'Набор спецзначений',
    'Дескриптор окна', 'Дескриптор картограммы',
    'Цветовая траектория',
//*** Reserved for Spec Folders SysTypes
     '', '', '', '',
//*** Aliases of Objects which are not stored SysFolders
    'WEB картограмма', 'Группа WEB картограм',
    'WEB папка', 'Папка',
    'WEB структура', 'WEB таблица', 'WEB диаграмма',
    'WEB группа', 'Набор фреймов', 'WEB публикация',
    'HTML текст', 'HTML файл', 'Вектор HTML текстов', 'Вектор HTML файлов',
    'Схема окон', 'Самостоятельное окно', 'Фрейм в окне',
    'Дескриптор слоя заливка', 'Тематический слой',
    'Таблица', 'Вектор', 'Атрибут',
    'Параметры офисного документа',
    'Атрибуты представлений', 'Атрибуты представлений CS',
    'Корреляционный портрет', 'Рисунок' );

  K_CurMVDARRootName = 'MVDAR';



implementation

uses
  Forms, SysUtils,
  N_Lib1, N_ME1, N_CompBase,
  K_VFunc, K_CSpace, {K_FDCSpace, K_FDCSSpace, K_FDCSProj,}
  K_Arch, K_UDC, K_DCSpace, K_IndGlobal, K_MVObjs, K_MVMap0;

{*** TK_ScanMVUDSubTree ***}

constructor TK_ScanMVUDSubTree.Create;
begin
  inherited;
  RefNodes0 := TList.Create;
end;

destructor TK_ScanMVUDSubTree.Destroy;
begin
  RefNodes0.Free;
  inherited;
end;

procedure TK_ScanMVUDSubTree.IniLists;
begin
  RefNodes0.Clear;
end;

//************************************************
//*** Build List of SubTree Entry Nodes and List of SubTree External Nodes (not constructional Nodes) Routines
//************************************************

function TK_ScanMVUDSubTree.CheckNode( Ind : Integer ) : Boolean;
var
  SelfNodeFilter : TN_UDBase;
begin
  Result := ScanSysTypeFilter[Ind] = CurSysType;
  if not Result then Exit;
  case CurSysType of
    K_msdWebCartWins: begin
      SelfNodeFilter := TK_UDVector(TK_UDMVWCartWin(CurNode).GetLayerUDVector(0)).GetDCSSpace.GetDCSpace;
      if Integer(NodeFilter1) = 1 then NodeFilter1 := SelfNodeFilter;
      if NodeFilter1 <> nil then
      //*** check CS
        Result := (NodeFilter1 = SelfNodeFilter );
    end;
    K_msdWebCartGroupWins:;
    K_msdWebFolder:;
    K_msdFolder:;
    K_msdWebVTreeWins:;
    K_msdWebTableWins:;
    K_msdWebLDiagramWins:;
    K_msdWebWinGroups:;
    K_msdVWFrameSets:;
    K_msdWebSite:;
    K_msdWebHTMRefWins:;
    K_msdWebVHTMRefWins:;
  end;
  if not Result then Exit;
  RefNodes0.Add( CurNode );
end;

procedure TK_ScanMVUDSubTree.MVUDSubTreeScan( UDRoot : TN_UDBase;
         TestNodeFunc : TK_TestUDChildFunc;
         AUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags );
var
  WUDTreeChildsScanFlags: TK_UDTreeChildsScanFlags;
begin
  IniLists;

  WUDTreeChildsScanFlags := K_UDTreeChildsScanFlags;
  K_UDTreeChildsScanFlags := AUDTreeChildsScanFlags;

  if not (K_udtsOwnerChildsOnlyScan in K_UDTreeChildsScanFlags) then
    K_UDScannedUObjsList := TList.Create;

  if ScanRootNode then
    TestNodeFunc( nil, UDRoot, 0, 0, '' );

  UDRoot.ScanSubTree( TestNodeFunc );


  if K_UDScannedUObjsList <> nil then
    K_ClearUObjsScannedFlag();
  FreeAndNil(K_UDScannedUObjsList);

  K_UDTreeChildsScanFlags := WUDTreeChildsScanFlags;

end;

function TK_ScanMVUDSubTree.BuildNodesFilteredListFunc(UDParent : TN_UDBase; var UDChild : TN_UDBase;
  ChildInd, ChildLevel: Integer; const FieldName: string): TK_ScanTreeResult;
var
  i : Integer;
begin
  Result := K_tucOK;
  CurNode := UDChild;
  CurSysType := K_MVDarGetUserNodeType( CurNode );
  if CurSysType = K_msdUndef then Exit;
  for i := 0 to High(ScanSysTypeFilter) do
    if CheckNode(i) then break;
end;

function TK_ScanMVUDSubTree.BuildNodesFilteredListFunc1(UDParent : TN_UDBase; var UDChild : TN_UDBase;
  ChildInd, ChildLevel: Integer; const FieldName: string): TK_ScanTreeResult;
var
  i : Integer;
begin
  Result := K_tucOK;
  CurNode := UDChild;
  CurSysType := K_MVDarGetUserNodeType( CurNode );
  if CurSysType = K_msdUndef then Exit;
  for i := 0 to High(ScanSysTypeFilter) do begin
    if not CheckNode(i) then Continue;
    Result := K_tucSkipScan;
    break;
  end;
end;

function TK_ScanMVUDSubTree.BuildMVFoldersSubTreeChildsListFunc(
  UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd,
  ChildLevel: Integer; const FieldName: string): TK_ScanTreeResult;
var
  SearchName : string;
  Ind : Integer;
begin

  SearchName := UDChild.BuildID( BuildNodeIDFlags );
  Ind := NodesSL.IndexOf( SearchName );
  if Ind = -1  then
    NodesSL.AddObject( SearchName, UDChild );
  Result := K_tucOK;
  if not K_IsMVdarUserFolder(UDChild) then
    Result := K_tucSkipSubTree;

end;

{*** end of TK_ScanMVUDSubTree ***}

//*******************
//*** Global Routines
//*******************

//************************************************ K_InitMVDarGCont
//
procedure K_InitMVDarGCont( UDArchive : TN_UDBase = nil );
begin
//*** create new archive if needed
  if UDArchive = nil then UDArchive := K_CurArchive;
  K_InitMVDarGCont0( UDArchive );

  if (UDArchive <> nil) then
    N_InitVREArchive( UDArchive );

  K_InitMVDarGCont1( UDArchive );
end; //*** end of procedure K_InitMVDarGCont

//************************************************ K_InitMVDarGCont0
//
procedure K_InitMVDarGCont0( UDArchive : TN_UDBase = nil );
begin
//*** create new archive if needed
  if UDArchive = nil then UDArchive := K_CurArchive;
  K_InitCSpaceGCont( UDArchive ); // New CSpace  Context
  K_InitDCodeGCont( UDArchive );  // Old DCSpace Context

  if UDArchive <> nil then begin
    K_CurUserRoot := K_GetArchUserRoot( UDArchive );
    if K_CurUserRoot = nil then
      K_CurUserRoot := K_AddArchiveSysDir( K_UserRootName, K_sftAddAll, UDArchive );
  end;
end; //*** end of procedure K_InitMVDarGCont0

//***************************************** K_InitMVDarGCont1
// Init Code Space context
//
procedure K_InitMVDarGCont1( CurArchive : TN_UDBase = nil );
var
  udb, SDir : TN_UDBase;
  i, h : Integer;
  IniName : string;
  AppID : string;
begin
  if K_IniMVSpecVals = nil then K_InitMVSpecValues;
  if CurArchive = nil then CurArchive := K_CurArchive;
  if CurArchive = nil then Exit;
//*** Check Archive App Type
  AppID := K_GetArchInfoAttr( K_tbAppID, CurArchive );
  if AppID <> 'MVDar' then Exit;

  with CurArchive do begin
    K_CurMVDARRoot :=
            DirChild( IndexOfChildObjName( K_CurMVDARRootName ) );
    if K_CurMVDARRoot = nil then begin
      K_CurMVDARRoot := K_AddArchiveSysDir( K_CurMVDARRootName, K_sftSkipAll, CurArchive );
  //*** Init DCSpaces
      IniName := N_MemIniToString( 'MVDar', 'IniDCSpaces', '' );
      if IniName <> '' then begin
        IniName := K_ExpandFileName(IniName);
        K_CurSpacesRoot.LoadTreeFromAnyFile(IniName);
      end;

  //*** Add New Sys Folders to MVDAR
      IniName := N_MemIniToString( 'MVDar', 'AddSysFolders', '' );
      if IniName <> '' then begin
        IniName := K_ExpandFileName(IniName);
        K_GetMVDarSysRoot.ClearChilds(  );
        K_GetMVDarSysRoot.LoadTreeFromAnyFile( IniName );
      end;
  //*** Init WinDescriptions
      IniName := N_MemIniToString( 'MVDar', 'WinDescriptions', '' );
      if IniName <> '' then begin
        IniName := K_ExpandFileName(IniName);
        K_GetMVDarSysFolder( K_msdWinDescrs ).LoadTreeFromAnyFile(IniName);
      end;
  //*** Init MapDescriptions
      IniName := N_MemIniToString( 'MVDar', 'MapDescriptions', '' );
      if IniName <> '' then begin
        IniName := K_ExpandFileName(IniName);
        K_GetMVDarSysFolder( K_msdMapDescrs ).LoadTreeFromAnyFile(IniName);
      end;
{
  //*** Init Line Diagram Syles
      IniName := N_MemIniToString( 'MVDar', 'WLDStyles', '' );
      if IniName <> '' then begin
        IniName := K_ExpandFileName(IniName);
        K_GetMVDarSysFolder( K_msdWLDStyles ).LoadTreeFromAnyFile(IniName);
      end;
  //*** Init WEB-table Syles
      IniName := N_MemIniToString( 'MVDar', 'WTStyles', '' );
      if IniName <> '' then begin
        IniName := K_ExpandFileName(IniName);
        K_GetMVDarSysFolder( K_msdWTStyles ).LoadTreeFromAnyFile(IniName);
      end;
  //*** Init MLGenerators
      IniName := N_MemIniToString( 'MVDar', 'MLGenerators', '' );
      if IniName <> '' then begin
        IniName := K_ExpandFileName(IniName);
        K_GetMVDarSysFolder( K_msdMLGens ).LoadTreeFromAnyFile(IniName);
      end;
}
    end;
  end;
  with K_CurMVDARRoot do begin // Remove BaseTypesDir
    h := DirHigh;
    if h < 0 then Exit;
// set Replace flag for System Prompts
    K_SetSysObjFlags( DirChild(h), K_sftReplaceObjName );
    for i := 0 to h do begin
      udb := DirChild(i);
      if TK_UDSysFolderType( (udb.ObjFlags and K_fpObjSFTypeMask) shr K_fpObjSFTypePos ) = K_sftReplace then
        K_SetSysObjFlags( udb, K_sftReplaceObjName );
    end;
  end;

  //*** Init WinDescriptions
  udb := K_GetMVDarSysFolder( K_msdWinDescrs );
  if not (udb.DirChild(0) is TK_UDMVVWLayout) then begin
    udb.ClearChilds();
    IniName := N_MemIniToString( 'MVDar', 'WinDescriptions', '' );
    if IniName <> '' then begin
      IniName := K_ExpandFileName(IniName);
      K_GetMVDarSysFolder( K_msdWinDescrs ).LoadTreeFromAnyFile(IniName);
    end;
  end;
//***  Create Special Values Object
  SDir := K_GetMVDarSysFolder( K_msdSValSets );
  if SDir <> nil then begin
    K_CurArchSpecVals := SDir.DirChildByObjName(K_MVDARSysObjNames[Ord(K_msdSValSets)]);
    if K_CurArchSpecVals = nil then begin// create MVSV bject
      K_CurArchSpecVals := SDir.AddOneChild( TK_UDRArray.Create );
      K_CurArchSpecVals.ObjName := K_MVDARSysObjNames[Ord(K_msdSValSets)];
      K_CurArchSpecVals.ObjAliase := K_MVDARSysObjALiases[Ord(K_msdSValSets)];
      K_RFreeAndCopy( TK_UDRArray(K_CurArchSpecVals).R, K_IniMVSpecVals );
    end;
  end;
//***  Create Default Colors Set
  SDir := K_GetMVDarSysFolder( K_msdColorPaths );
  if SDir <> nil then begin
    K_CurArchDefColorsSet := SDir.DirChildByObjName( 'Default' );
    if K_CurArchDefColorsSet = nil then begin// create Default Colors Set Object
      K_CurArchDefColorsSet := SDir.AddOneChild( K_CreateUDByRTypeCode( Ord(nptColor) ) );
      K_CurArchDefColorsSet.ObjName := 'Default';
      K_CurArchDefColorsSet.ObjAliase := 'Безымянный';
      K_CurArchDefColorsSet.ImgInd := 23;
      with TK_UDRArray(K_CurArchDefColorsSet).R do begin
        ASetLength( 2 );
        PInteger(P)^ := $F0F0FF;
        PInteger(P(1))^ := $0000FF;
      end;
    end;
  end;

end; // end_of procedure K_InitMVDarGCont1

//**************************************** K_MVDarGetNodeType ***
// Get Node Sys Type
//
function K_MVDarGetUserNodeType( cnode : TN_UDBase ): TK_MVDARSysType;
var
  ClassFlags : Integer;
begin
  Result := K_msdUndef;
  if cnode = nil then Exit;
  ClassFlags := cnode.CI;
  if ClassFlags = K_UDMVTableCI then     // MVTable
    Result := K_msdBTables
  else if ClassFlags = K_UDMVVectorCI then     // MVVector
    Result := K_msdMVVectors
  else if ClassFlags = K_UDMVMapDescrCI then // MVMapDescr
    Result := K_msdMapDescrs
  else if ClassFlags = K_UDMVMLDColorFillCI then // MVMLDColorFill
    Result := K_msdMLDColorFills
  else if ClassFlags = K_UDMVWCartWinCI then // MVWCartWin
    Result := K_msdWebCartWins
  else if ClassFlags = K_UDMVWCartGroupWinCI then // MVWCartGroupWin
    Result := K_msdWebCartGroupWins
  else if (ClassFlags = K_UDMVFolderCI) then // MVFolder
    Result := K_msdFolder
  else if (ClassFlags = K_UDMVVWLayoutCI) then // MVVWLayout
    Result := K_msdVWLayouts
  else if (ClassFlags = K_UDMVVWindowCI) then // MVVWindow
    Result := K_msdVWindows
  else if (ClassFlags = K_UDMVVWFrameCI) then // MVVWFrame
    Result := K_msdVWFrames
  else if (ClassFlags = K_UDMVVWFrameSetCI) then // MVVWFrameSet
    Result := K_msdVWFrameSets
  else if (ClassFlags = K_UDMVWFolderCI) then // MVWebFolder
    Result := K_msdWebFolder
  else if (ClassFlags = K_UDMVWVTreeWinCI) then // MVWebVTreeWin
    Result := K_msdWebVTreeWins
  else if (ClassFlags = K_UDMVWLDiagramWinCI) then // MVWebLDiagramWin
    Result := K_msdWebLDiagramWins
  else if (ClassFlags = K_UDMVWTableWinCI) then // MVWebTableWin
    Result := K_msdWebTableWins
  else if (ClassFlags = K_UDMVWWinGroupCI) then // MVWebWinGroup
    Result := K_msdWebWinGroups
  else if cnode.IsSPLType('TK_MVWebHTMWin') then // MVWebHTMWin
    Result := K_msdWebHTMWins
  else if cnode.IsSPLType('TK_MVWebHTMRefWin') then // MVWebHTMRefWin
    Result := K_msdWebHTMRefWins
  else if cnode.IsSPLType('TK_MVWebVHTMWin') then // MVWebVHTMWin
    Result := K_msdWebVHTMWins
  else if cnode.IsSPLType('TK_MVWebVHTMRefWin') then // MVWebVHTMRefWin
    Result := K_msdWebVHTMRefWins
  else if (ClassFlags = K_UDMVWSiteCI) then // MVWebSite
    Result := K_msdWebSite
  else if cnode.IsSPLType('Color') then // Color Path
    Result := K_msdColorPaths
  else if cnode.IsSPLType('TK_MVMSWDVAttrs') then // MSOFD Params
    Result := K_msdMSOParams
  else if cnode.IsSPLType('TK_MVRComAttrs') then // MV Representations Common Attributes
    Result := K_msdMVRComAttrs
  else if cnode.IsSPLType('TK_MVRCSAttrs') then // MV Representations Common Attributes Depended from CS
    Result := K_msdMVRCSAttrs
  else if cnode.IsSPLType('TK_MVCorPict') then // MV Correlation Picture
    Result := K_msdMVCorPict
  else if cnode is TN_UDCompVis then // MV Result Visual Component
    Result := K_msdMVRVisComp
  else if cnode.IsSPLType('TK_MVDataSpecVal') then // Special Values Set
    Result := K_msdSValSets

end; // end of function K_MVDarGetUserNodeType

//***************************************** K_InitMVObjectCaptions
// Init MVObjec Captions
//
procedure K_InitMVObjectCaptions( UDMVObj : TN_UDBase; ObjSysType : TK_MVDARSysType = K_msdUndef );
begin
  if ObjSysType = K_msdUndef then
    ObjSysType := K_MVDarGetUserNodeType( UDMVObj );
  case ObjSysType of
    K_msdWebCartGroupWins,
    K_msdWebCartWins,
    K_msdWebVTreeWins,
    K_msdWebTableWins,
    K_msdWebLDiagramWins,
    K_msdWebWinGroups,
    K_msdWebHTMWins,
    K_msdWebHTMRefWins,
    K_msdBTables,
    K_msdWebFolder :
      with TK_PMVWebFolder(TK_UDRArray(UDMVObj).R.P)^ do begin
        FullCapt := UDMVObj.ObjAliase;
        BriefCapt := UDMVObj.ObjAliase;
      end;
    K_msdWebVHTMWins,
    K_msdWebVHTMRefWins :
      with TK_PMVWebVHTMWin(TK_UDRArray(UDMVObj).R.P)^ do begin
        FullCapt := UDMVObj.ObjAliase;
        BriefCapt := UDMVObj.ObjAliase;
      end;
  end;
end; // end_of procedure K_InitMVObjectCaptions

end.
