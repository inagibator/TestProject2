unit K_TSImport4;

interface
uses
  inifiles, Math, Classes,
  K_Script1, K_VFunc, K_IMVDar, K_UDT1, K_IndGlobal, K_CLib0, K_Types;

//**************************************** K_MVImportTabStruct4
// Import Table Structure from preparsed FGTable UDTree
//
function  K_MVImportTabStruct4( UDParent : TN_UDBase; SL : TStrings;
        TabImportIni : TMemIniFile; SourceName : string = '';
        ShowWarning : TK_MVShowMessageProc = nil ) : Boolean;

implementation

uses Controls, SysUtils, Dialogs,
  K_Arch, K_DCSpace, K_MVMap0, K_MVObjs, K_UDT2, K_UDC, K_STBuf,
  N_Lib1, N_Lib0, N_Types, N_ClassRef;

//**************************************** K_MVImportTabStruct4
// Import Table Structure from preparsed FGTable UDTree
//
function  K_MVImportTabStruct4( UDParent : TN_UDBase; SL : TStrings;
        TabImportIni : TMemIniFile; SourceName : string = '';
        ShowWarning : TK_MVShowMessageProc = nil ) : Boolean;
label LExit, LSExit, LSLExit, EndOfMapLinkObjs;
type TK_VarLevel = (vlIni, vlRoot, vlTab, vlVector);

var
  AbsRegSInd, UndefValSInd, StandardDeviationSInd : Integer;
  RSVAttrs : TK_RArray; // Special Values Structure
  UDRSVAttrs : TN_UDBase; // Special Values UDBase
  SVList : THashedStringList;
  TabElemCapts : TN_SArray;
  LDElemCapts : TN_SArray;
  CMVWGroup : TN_UDBase;
  PVV : PDouble;
  PMVVAttrs : TK_PMVVAttrs;
  PMVVector : TK_PMVVector;
  VUnits : string;
  CurDE  : TN_DirEntryPar;
  CurVDE  : TN_DirEntryPar;
  CMVVector :  TN_UDBase;
  CurParamsName : string;
  WUD : TN_UDBase;
  UColors : TN_UDBase;
  UDElemCapts : TN_UDBase;
  UDW : TN_UDBase;
  UDSrcTabSect : TN_UDBase;
  UDSrcVECapts : TN_UDBase;
  UDSrcSTabVector : TN_UDBase;
  UDMVWFRoot : TN_UDBase;
  CName, CCaption : string;
  DataMapID, CSName : string;
  i, j, k : Integer;
  UDDCSpace : TK_UDDCSpace;
  MUDDCSpace : TK_UDDCSpace;
  NMUDDCSSpace, MUDDCSSpace, AUDDCSSpace, UDDCSSpace : TK_UDDCSSpace;
  CMapDescr : TN_UDBase;
  MapDataAttribs : TK_UDVector;
  MapDataProj : TK_UDVector;
  MapDataProjName : string;
  DataDataProj : TK_UDVector;
  DataDataProjName : string;
  DCSCount : Integer;
  CLCount : Integer;
  VectorDataSize : Integer;
  CurInd : Integer;
  CSSIndexes : TN_IArray;
  DProj : TN_IArray;
  DumpLine : string;
  WStr1 : string;
  WStr2 : string;
  WInt1 : Integer;
  WInt2 : Integer;
  WList : TStringList;
  CMacroList : THashedStringList;
  CMListTabCount, CMListSectCount : Integer;
  CFolderAliase : string;
  CFolderName : string;
  CFolderCaption : string;
  CFolderSCaption : string;
  CMVTab : TN_UDBase;
  CMVWTab   : TN_UDBase;
  CMVWCart  : TN_UDBase;
  CMVWinGroup  : TN_UDBase;
  CMVWCartGroup : TN_UDBase;
  CMVWLDiagram  : TN_UDBase;
  TabMacroList : THashedStringList;
  ML : TStringList;
  UDSrcRoot : TN_UDBase;
const
  K_itsMCaption = 'Caption';
  K_itsMLCaption = 'LCaption';
  K_itsMPrevList = 'P';


  //************************************** GetVarValue
  //  Get Variable Value From given Vars Level
  //
  function GetVarValue( VarName : string; StartLevel : TK_VarLevel = vlRoot; DefVal : string = '' ) : string;
  var
    VInd : Integer;
    UDRAList : TK_UDRAList;

  label TestPrevLevel;
  begin
    UDRAList := nil;
    case StartLevel of
      vlIni    : begin
        Result := TabImportIni.ReadString( 'Common', VarName, DefVal );
        Exit;
      end;
      vlRoot   : UDRAList := TK_UDRAList(UDSrcRoot);
      vlTab    : UDRAList := TK_UDRAList(UDSrcTabSect);
      vlVector : UDRAList := TK_UDRAList(UDSrcSTabVector);
    end;
    if (UDRAList.CI <> K_UDRAListCI) or (UDRAList.RAAttrList = nil) then goto TestPrevLevel;
    VInd := UDRAList.RAAttrList.IndexOfName(VarName);
    if VInd < 0 then goto TestPrevLevel;
    Result := UDRAList.RAAttrList.ValueFromIndex[VInd];
    Exit;

TestPrevLevel:
    Dec(Byte(StartLevel));
    Result := GetVarValue( VarName, StartLevel, DefVal);

  end; //*** end of GetVarValue

  //************************************** MacroExpand
  //  Get String by Macro Pattern ID
  //
  function MacroExpand( PatternID, DefValue : string ) : string;
  begin
    Result := DefValue;
    Result := TabImportIni.ReadString( 'Patterns', PatternID, DefValue );
    if Result <> DefValue then begin // MacroExpand
      Result := K_StringMListReplace( ' '+Result, CMacroList, K_ummRemoveMacro );
      Result := Copy( Result, 2, Length(Result) );
    end;
  end; //*** end of MacroExpand

  //************************************** AShowWarning
  //  Show Warning
  //
  procedure AShowWarning( Line : string; MesStatus : TK_MesStatus = K_msError );
  begin
    if Assigned(ShowWarning) then ShowWarning( Line, MesStatus );
  end; //*** end of AShowWarning

  //************************************** AddMacroVarsToMList
  //  Add Macro Variables to List of Macro Definitions
  //
  procedure AddMacroVarsToMList( MList : TStrings; UDLevelRoot : TN_UDBase );
  var
    i : Integer;
  begin
    with TK_UDRAList(UDLevelRoot) do begin
      if (CI <> K_UDRAListCI) or (RAAttrList = nil) then Exit;
      for i := 0 to RAAttrList.Count - 1 do begin
        if RAAttrList[i][1] = '#' then Continue;
        MList.Add( RAAttrList[i] );
      end;
    end;
  end; //*** end of AddMacroVarsToMList

  //************************************** BuildRepresentationObj
  //  Build Data Representation Object
  //
  function BuildRepresentationObj( Name, Aliase  : string;
               ObjSysType : TK_MVDARSysType; UDParent : TN_UDBase ) : TN_UDBase;
  begin
    Name := K_MVDARSysObjNames[Ord(ObjSysType)]+ Name;
    Result := K_MVDarNewUserNodeAdd( ObjSysType, nil,
                                     UDParent, DumpLine, Aliase, Name );
    with TK_PMVWebWinObj(TK_UDRArray(Result).R.P)^ do begin
      FullCapt := CFolderCaption;
      BriefCapt := CFolderSCaption;
      Title := CFolderCaption;
    end;
  end; //*** end of BuildRepresentationObj

  //************************************** CreateGroupObjects
  //  Create WWGroup with WTable, WDiagram, WMGroup
  //
  procedure CreateGroupObjects;
  var
    i, h : Integer;
    CObjName : string;
    FixInd : Integer;
    FixCSS : TK_UDDCSSpace;
    PInd : PInteger;
    WPatName : string;
    WVMin, WVMax : Double;
    MinMaxRecalc : Boolean;
{
    //************************************** SetFixRegion
    //  Set New Fix Region Value
    //
    procedure SetFixRegion( PFixRegInd : PInteger );
    begin
      FixCSS := UDDCSpace.IndexOfCSS( PFixRegInd, 1 );
      if FixCSS = nil then begin
        TN_UDBase(FixCSS) := UDDCSpace.GetSSpacesDir.DirChildByObjName( '***###???DFR' );
        if FixCSS = nil then
          TN_UDBase(FixCSS) := UDDCSpace.GetSSpacesDir.DirChildByObjName( '***$$$???DFR' );
        if FixCSS <> nil then begin
          UDDCSpace.GetItemsInfo( @WStr1, K_csiCSName, PInteger( FixCSS.DP(0) )^ );
          UDDCSpace.GetItemsInfo( @WStr2, K_csiCSName, FixInd );
          if mrYes <> MessageDlg( 'Текущий фиксированный регион "'+ WStr1 + '"'+#$D+#$A+
                                  ' заменить на "' + WStr2+ '"?',
                                  mtConfirmation, [mbYes, mbNo], 0) then Exit;
        end else
          FixCSS := UDDCSpace.CreateDCSSpace( '***###???DFR', 1, CFolderAliase+' DFR' );
        Move( FixInd, FixCSS.DP^, SizeOf(Integer) );
      end;
    end;
}
  begin

    CurDE.Child := CMVTab;
//******************************
//***    Build Auto MiMax
//******************************
    with TK_UDMVTable(CMVTab) do begin
      h := GetSubTreeChildHigh;
      MinMaxRecalc := false;
      WVMax := -MaxDouble;
      WVMin := MaxDouble;
      for i := 0 to h do
        with TK_PMVVAttrs(TK_UDRArray(GetUDAttribs(i)).R.P)^ do begin
          MinMaxRecalc := AutoMinMax.T = K_aumAuto;
          if not MinMaxRecalc then Break;
          WVMin := Min( WVMin, VMin );
          WVMax := Max( WVMax, VMax );
        end;
      if MinMaxRecalc then
        for i := 0 to h do
          with TK_PMVVAttrs(TK_UDRArray(GetUDAttribs(i)).R.P)^ do begin
            AutoMinMax.T := K_aumManual;
            VBase := WVMin;
            VMin  := WVMin;
            VMax  := WVMax;
          end;
    end;
//******************************
//***   end of Build Auto MiMax
//******************************

//******************************
//***    Build WebLDiagram
//******************************
    CObjName := K_MVDARSysObjNames[Ord(K_msdWebLDiagramWins)]+CFolderName;

    CMVWLDiagram := TN_UDBase( K_MVDarNewUserNodeAdd( K_msdWebLDiagramWins,
                                 nil, nil, DumpLine,
                                'WEB диаграмма: '+CFolderAliase, CObjName ) );

    //***    Set WebLDiagram Params
    with TK_PMVWebLDiagramWin(TK_UDRArray(CMVWLDiagram).R.P)^ do begin
      ASWENType.T := K_gecWEParent;
      WPatName := GetVarValue( '#DiagramCaption', vlTab );
      FullCapt := MacroExpand( WPatName, CFolderCaption );
      N_ReplaceEQSSubstr( FullCapt, '''', '"' );
      BriefCapt := FullCapt;
    // Page Name
      Title := FullCapt;
    // WinID
      VWinName := GetVarValue( '#DiagramWinID', vlTab );
    // Hist Data to Data Projection
      K_SetUDRefField( CSProj1, DataDataProj );
    // Add New Diagram section
      CMVWLDiagram.AddChildToSubTree( @CurDE );
    // Set Section elements Captions
      h := CMVWLDiagram.DirHigh;
      for i := 0 to h do
        with Sections do
          if LDElemCapts[i] <> '' then  PString(P(i))^ := LDElemCapts[i];

    // Fixed Region Code
      FixCSS := nil;
      WStr1 := GetVarValue( '#DFixRegCode', vlTab );
      if WStr1 = '' then
        WStr1 := GetVarValue( '#DFixDataCode', vlTab );
      if WStr1 <> '' then begin
        FixInd := UDDCSpace.IndexByCode(WStr1);
        if FixInd <> -1 then begin
//          SetFixRegion( @FixInd );
          FixCSS := UDDCSpace.IndexOfCSS( @FixInd, 1 );
          if FixCSS = nil then begin
            FixCSS := UDDCSpace.CreateDCSSpace( '***###???DFR', 1, CFolderAliase+' DFR' );
            Move( FixInd, FixCSS.DP^, SizeOf(Integer) );
          end;
        end;
      end;

    // Fixed Region Number
      if FixCSS = nil then begin
        WStr1 := GetVarValue( '#DFixRegion', vlTab );
        if WStr1 = '' then
          WStr1 := GetVarValue( '#DFixDataInd', vlTab );
        if WStr1 <> '' then begin
          FixInd := StrToIntDef(WStr1, -1);
          if FixInd <> -1 then begin
            PInd := PInteger(AUDDCSSpace.DP(FixInd));
            if PInd <> nil then begin
//              SetFixRegion( PInd );
              FixCSS := UDDCSpace.IndexOfCSS( PInd, 1 );
              if FixCSS = nil then begin
                FixCSS := UDDCSpace.CreateDCSSpace( '***###???DFR', 1, CFolderAliase+' DFR' );
                Move( PInd^, FixCSS.DP^, SizeOf(Integer) );
              end;
            end;
          end;
        end;
      end;
    // Fixed Region Number CSS
      K_SetUDRefField( PECSS, FixCSS );
    end;
//******************************
//*** end of  WebLDiagram
//******************************

//******************************
//***    Build WebTable
//******************************
    CObjName := K_MVDARSysObjNames[Ord(K_msdWebTableWins)]+CFolderName;
    CMVWTab := TN_UDBase( K_MVDarNewUserNodeAdd( K_msdWebTableWins,
                               nil, nil, DumpLine,
                              'WEB таблица: '+CFolderAliase, CObjName ) );
    //***    Set WebLDiagram Params
    with TK_PMVWebTableWin(TK_UDRArray(CMVWTab).R.P)^ do begin
      ASWENType.T := K_gecWEParent;
      WPatName := GetVarValue( '#TableCaption', vlTab );
      FullCapt := MacroExpand( WPatName, CFolderCaption );
      N_ReplaceEQSSubstr( FullCapt, '''', '"' );
      BriefCapt := FullCapt;
    // Page Name
      Title := FullCapt;
    // WinID
      VWinName := GetVarValue( '#TableWinID', vlTab );
    // Not Mapping Table Elements CSS
      K_SetUDRefField( SCSS, NMUDDCSSpace );
    // Add New Diagram section
      CMVWTab.AddChildToSubTree( @CurDE );
    // Set Section elements Captions
      h := CMVWTab.DirHigh;
      for i := 0 to h do
        with Sections do
          if TabElemCapts[i] <> '' then  PString(P(i))^ := TabElemCapts[i];
    // Table Sidehead Caption
      SHCaption := GetVarValue( '#TabSideheadCaption', vlTab );
    end;
//******************************
//*** end of  WebTable
//******************************
//******************************
//***    Build WebWinGroup - Theme
//******************************
    CObjName := K_MVDARSysObjNames[Ord(K_msdWebWinGroups)]+CFolderName;
    CMVWinGroup := TN_UDBase( K_MVDarNewUserNodeAdd( K_msdWebWinGroups,
                              nil, UDMVWFRoot, DumpLine,
                              'WEB группа: '+CFolderAliase, CObjName ) );
    //***    Set WebLDiagram Params
    with TK_PMVWebWinGroup(TK_UDRArray(CMVWinGroup).R.P)^ do begin
      FullCapt := CFolderCaption;
      BriefCapt := CFolderSCaption;
    // Page Name
      Title := FullCapt;
    // Title WinID
      TVWinName :=  GetVarValue( '#HeaderWinID', vlTab );
    // Add Web LDiagram To WinGroup
      CurDE.Child := CMVWLDiagram;
      CMVWinGroup.AddChildToSubTree( @CurDE );
    // Add Web Table To WinGroup
      CurDE.Child := CMVWTab;
      CMVWinGroup.AddChildToSubTree( @CurDE );

    // Add CartoGram Group To WinGroup
      if CMapDescr <> nil  then begin
        if CMVWCartGroup <> nil then begin
          CurDE.Child := CMVWCartGroup;
          CMVWinGroup.AddChildToSubTree( @CurDE );
        end;
      end;
    end;
//******************************
//*** end of WebWinGroup - Theme
//******************************
  end; //*** end of CreateGroupObjects

  //************************************** BuildDataElemIndsUnLinkedToMap
  //  Build Data Elements Indexes by MapDataProjection UnLinked to Map
  //  Result - Returns number of not mapping vector elements
  //  On output first Result elements of CSSIndexes are not maping data CSS
  //
  function BuildDataElemIndsUnLinkedToMap( MDProj : TN_UDBase ) : Integer;
  var i : Integer;
  begin

    K_BuildDataProjectionByCSProj( AUDDCSSpace, MUDDCSSpace,
                  @CSSIndexes[0], TK_UDVector(MDProj) );


    //*** Mark Elements (by DProj) which have corresponding Elements in Map Linked Data
    FillChar( DProj[0], CLCount * SizeOf(Integer), $FF );
    for i := 0 to High(CSSIndexes) do
      if CSSIndexes[i] <> -1 then
        DProj[CSSIndexes[i]] := i;

    //*** Create Data DCSSpace for not mapping Data Elements
    Result := 0;
    for i := 0 to High(DProj) do
      if DProj[i] = -1 then begin
        CSSIndexes[Result] := PInteger( AUDDCSSpace.DP( i ) )^;
        Inc(Result);
      end;
  end; //*** end of BuildDataElemIndsUnLinkedToMap

  //************************************** SearchForBestMapDataProjection
  //  Search for Best MapData Projection
  //
  function SearchForBestMapDataProjection : Integer;
  var
    CurProj, SearchDir, OwnerDir : TN_UDBase;
    i,h : Integer;
    MaxElemProjCount, EPCount : Integer;
    RecalcDataElemInds : Boolean;
    NewMapDataProj : TN_UDBase;
  begin
    with MUDDCSpace do
      SearchDir := TK_UDDCSSpace(GetSSpacesDir.DirChildByObjName( ObjName )).GetVectorsDir; // No DCSpaces
//*** search main projection
    OwnerDir := UDDCSpace.GetSSpacesDir;
    MaxElemProjCount := 0;
    RecalcDataElemInds := false;
    NewMapDataProj := nil;
    with SearchDir do begin
      h := DirHigh;
      for i := 0 to h do begin
        CurProj := DirChild(i);
        if (CurProj = MapDataProj) or (CurProj.Owner <> OwnerDir) then Continue; // Not proper projection
        EPCount := CLCount - BuildDataElemIndsUnLinkedToMap( CurProj );
        RecalcDataElemInds := true;
        if EPCount <= MaxElemProjCount then Continue;
        NewMapDataProj := TK_UDVector(CurProj);
        MaxElemProjCount := EPCount;
        RecalcDataElemInds := false;
      end;
      Result := CLCount - MaxElemProjCount;
      if Result = CLCount then Exit;
      MapDataProj := TK_UDVector(NewMapDataProj);
      if RecalcDataElemInds then
        BuildDataElemIndsUnLinkedToMap( MapDataProj );
    end
  end; //*** end of SearchForBestMapDataProjection

begin

  ML := TStringList.Create;
  ML.Add('S=CompactArray=1 TypeName=string UDClass=RAList');
  ML.Add('D=CompactArray=1 TypeName=double UDClass=RAList');
  ML.Add('T=UDClass=RAList');
  K_SerialTextBuf.TextStrings.Assign( SL );
  K_SListMListReplace( K_SerialTextBuf.TextStrings, ML  );
  UDSrcRoot := nil;
  try
    UDSrcRoot := K_LoadTreeFromText( K_SerialTextBuf );
  except end;

  ML.Free;

  CMacroList := nil;
  TabMacroList := nil;
  WList := nil;
  SVList := nil;

  Result := false;
//*** Check Src Rooot
  if (UDSrcRoot = nil) or
     not (UDSrcRoot is TK_UDRArray) or
     (K_GetExecTypeName(TK_UDRArray(UDSrcRoot).R.ElemType.All) <> 'FGTable' ) then begin
    DumpLine := 'ИСТОЧНИК "'+SourceName+'" - отсутствует таблица для загрузки';
LSExit:
    AShowWarning( DumpLine );
    goto LExit;
  end;

//*** Check Src Elements Vector
  UDSrcVECapts := UDSrcRoot.DirChild(0);
  if (UDSrcVECapts = nil) or
     not (UDSrcVECapts is TK_UDRArray) or
//     (K_GetExecTypeName(TK_UDRArray(UDSrcVECapts).R.ElemType.All) <> 'FGVENames' ) then begin
     (TK_UDRArray(UDSrcVECapts).R.ElemType.DTCode <> Ord(nptString) ) then begin
    DumpLine := 'ИСТОЧНИК "'+SourceName+'" - отсутствует вектор названий элементов';
    goto LSExit;
  end;
  CLCount := TK_UDRArray(UDSrcVECapts).R.ALength;

//*** Check Src TabSections and Vectors
  for i := 1 to UDSrcRoot.DirHigh do begin
    UDSrcTabSect := UDSrcRoot.DirChild(i);
    if (UDSrcTabSect = nil) or
       not (UDSrcTabSect is TK_UDRArray) or
       (K_GetExecTypeName(TK_UDRArray(UDSrcTabSect).R.ElemType.All) <> 'FGTabSection' ) then begin
      DumpLine := 'ИСТОЧНИК "'+SourceName+'" - нарушена структура секций таблицы в объекте "'+
                  UDSrcTabSect.GetUName+'"';
      goto LSExit;
    end;
    for j := 0 to UDSrcTabSect.DirHigh do begin
      UDSrcSTabVector := UDSrcTabSect.DirChild(j);
      with TK_UDRArray(UDSrcSTabVector).R.ElemType do
        if (UDSrcSTabVector = nil)              or
           not (UDSrcSTabVector is TK_UDRArray) or
  //         (K_GetExecTypeName(All) <> 'FGTabVector' ) then begin
           ( (DTCode <> Ord(nptString)) and
             (DTCode <> Ord(nptDouble)) ) then begin
          DumpLine := 'нарушена структура векторов';
  LSLExit:
          DumpLine := 'ИСТОЧНИК "'+SourceName+'" - '+DumpLine+
                      ' в объекте "'+UDSrcSTabVector.GetUName+'" секции "'+
                       UDSrcTabSect.GetUName+'"';
          goto LSExit;
        end;
      if CLCount = TK_UDRArray(UDSrcSTabVector).R.ALength then Continue;
      DumpLine := 'неверное число элементов';
      goto LSLExit;
    end;
  end;

//*** Get DCSpace
  DataMapID := GetVarValue( '#DataMapID' );
  UDDCSpace := nil;
  if DataMapID <> '' then begin
    CSName := TabImportIni.ReadString('DCSpaces', DataMapID, '' );
    if CSName <> '' then
      UDDCSpace := TK_UDDCSpace( K_CurSpacesRoot.DirChildByObjName( CSName, K_ontObjUName ) );
  end;
  if UDDCSpace = nil then
    CSName := GetVarValue( '#DCSpace' );
  if CSName <> '' then
    UDDCSpace := TK_UDDCSpace( K_CurSpacesRoot.DirChildByObjName( CSName, K_ontObjUName ) );
  if UDDCSpace = nil then
    UDDCSpace := TK_UDDCSpace( K_CurSpacesRoot.DirChild(0) );
  if UDDCSpace = nil then begin
    DumpLine := 'ИСТОЧНИК "'+SourceName+'" - отсуствует кодовое пространство данных';
    goto LSExit;
  end;

//*** Build Data CSS
  SetLength( CSSIndexes, CLCount );
  DCSCount := UDDCSpace.SelfCount;
  k := DCSCount;
  j := -1;
  with UDDCSpace, TK_PDCSpace(R.P)^, TK_UDRArray(UDSrcVECapts).R do begin
    // Link Vectors Elements Names to CS Loop
    for i := 0 to CLCount - 1 do begin
      CCaption := PString(P(i))^;
      CSSIndexes[i] := K_IndexOfStringInKeyExprsArray( CCaption,
                                                       Keys.P, DCSCount );
      if CSSIndexes[i] = -1 then begin
      // Add New CS Element
        CSSIndexes[i] := DCSCount;
        j := DCSCount;
        Inc(DCSCount);

        Codes.ASetLength(DCSCount);
        Names.ASetLength(DCSCount);
        Keys.ASetLength(DCSCount);


        // Build Uniq  DCSpace Code
        WStr1 := IntToStr( DCSCount );
        WStr2 := WStr1;
        WInt1 := 0;
        while K_IndexOfStringInRArray( WStr2, Codes.P, j  ) >= 0 do begin
          WStr2 := WStr1 + '_' + IntToStr(WInt1);
          Inc( WInt1 );
        end;
        PString(Codes.P(j))^ := WStr2;

        // Build Name and Key
        PString(Names.P(j))^ := CCaption;
        with K_CompareKeyAndStrTokenizer do begin
          setSource( '' );
          addToken( '.' + CCaption );
          PString(Keys.P(j))^ := Copy( Text, 1, StrLen( PChar(Text) ) );
        end;
      end; // end of Add New CS Element
    end; // end of Link Vectors Elements Names to CS Loop

    if j >= 0 then begin
    // Rebuild Full CSS Vectors
      RebuildFullCSS( DCSCount ).ChangeDVectorsOrder( nil, DCSCount );
    // Set CS Aliases New Elements
      with GetAliasesDir do
        for i := k to DCSCount - 1 do begin
          CCaption := PString(Names.P(i))^;
          for j := 0 to DirHigh do
            PString(TK_UDVector(DirChild(j)).DP(i))^ := CCaption;
        end;
    end;
  end;

{
  j := 0;
  with TK_PDCSpace(UDDCSpace.R.P)^, TK_UDRArray(UDSrcVECapts).R do
    for i := 0 to CLCount - 1 do begin
      CSSIndexes[i] := K_IndexOfStringInKeyExprsArray( PString(P(i))^,
                                                       Keys.P, DCSCount );
      if CSSIndexes[i] = -1 then Inc(j);
    end;

  if j > 0 then begin
  //*** Add New Elements to Data Code Space
    j := DCSCount + j;
    K_CompareKeyAndStrTokenizer.setSource( '' );
    with TK_PDCSpace(UDDCSpace.R.P)^ do begin
      Codes.ASetLength(j);
      Names.ASetLength(j);
      Keys.ASetLength(j);
      UDDCSpace.RebuildFullCSS( j ).ChangeDVectorsOrder( nil, j );
      for i := 0 to CLCount - 1 do begin
        if CSSIndexes[i] <> -1 then Continue;

        CSSIndexes[i] := DCSCount;
        CCaption := PString(TK_UDRArray(UDSrcVECapts).R.P(i))^;

        // Set New CS Elements Attrs

        // Build Uniq  DCSpace Code
        WStr1 := IntToStr( DCSCount + 1 );
        WStr2 := WStr1;
        WInt1 := 0;
        while K_IndexOfStringInRArray( WStr2, Codes.P, DCSCount ) >= 0 do begin
          WStr2 := WStr1 + '_' + IntToStr(WInt1);
          Inc( WInt1 );
        end;

        PString(Codes.P(DCSCount))^ := WStr2;
        PString(Names.P(DCSCount))^ := CCaption;

        with K_CompareKeyAndStrTokenizer do begin
          FillChar( Text[1], Length(Text), 0 * SizeOf(Char) );
          addToken( '.' + CCaption );
          PString(Keys.P(DCSCount))^ := Copy( Text, 1, StrLen( PChar(Text) ) );
        end;

        // Set New CS Elements Aliases
        with UDDCSpace.GetAliasesDir do
          for j := 0 to DirHigh do
            PString(TK_UDVector(DirChild(j)).DP(DCSCount))^ := CCaption;
        Inc(DCSCount);
      end;
    end;
  end;
}
  //*** Create Root MVWFolder
  CCaption := UDSrcRoot.GetUName;
  if CCaption = '' then
    CCaption := ExtractFileName(SourceName);
  UDMVWFRoot := K_MVDarNewUserNodeAdd( K_msdWebFolder, nil,
                                       UDParent, DumpLine, CCaption, '' );
  UDMVWFRoot.ObjInfo := K_DateTimeToStr(Now) + ' <- ' + SourceName;
  CName := UDMVWFRoot.ObjName;
  with TK_PMVWebFolder(TK_UDMVWFolder(UDMVWFRoot).R.P)^ do begin
    FullCapt := CCaption;
    BriefCapt := CCaption;
  end;

  //*** Search for compatible DCSS
  AUDDCSSpace := UDDCSpace.IndexOfCSS( @CSSIndexes[0], CLCount );
  if AUDDCSSpace = nil then begin // Cretate New DCSS
  // Create Sync DCSSpace
    AUDDCSSpace := UDDCSpace.CreateDCSSpace( CName+'_CSS', CLCount, CCaption+'_CSS' );
    Move( CSSIndexes[0], AUDDCSSpace.DP^, CLCount * SizeOf(Integer) );
  end;

  DataDataProj := nil;
  MapDataProj := nil;
  CMapDescr := nil;
  NMUDDCSSpace := AUDDCSSpace;

  //*** Get Map Description
  if DataMapID <> '' then begin
//************************
//*** Create Map to Data Correspondence Objects
//************************

    WStr1 := TabImportIni.ReadString('Maps', DataMapID, '' );
    if WStr1 = '' then
      WStr1 := GetVarValue( '#MapDescription' );
    CMapDescr := K_GetMVDarSysFolder( K_msdMapDescrs ).DirChildByObjName( WStr1, K_ontObjUName );
    if (CMapDescr = nil) or not (CMapDescr is TK_UDMVMapDescr) then begin
//      AShowWarning( 'ОШИБКА: отсутствует описатель картограммы - "'+WStr1+'" -> загрузка прервана' );
//      goto LExit;
      CMapDescr := nil;
      goto EndOfMapLinkObjs;
    end;
    if TK_PMVMapDescr(TK_UDRArray(CMapDescr).R.P).UDMScreenComp = nil then begin
//      AShowWarning( 'ОШИБКА: не задана визуальная компонента в описателе "'+WStr1+'" -> загрузка прервана' );
//      goto LExit;
      CMapDescr := nil;
      goto EndOfMapLinkObjs;
    end;

    MapDataAttribs := TK_UDVector(TK_PMVMLDColorFill(TK_UDRArray(CMapDescr.DirChild(0)).R.P).UDColors);
    if MapDataAttribs = nil then begin
//      AShowWarning( 'ОШИБКА: у карты отсутствует вектор атрибутов -> загрузка прервана' );
//      goto LExit;
      CMapDescr := nil;
      goto EndOfMapLinkObjs;
    end;

    MapDataProjName := TabImportIni.ReadString('DataMapProjs', DataMapID, '' );
    if MapDataProjName = '' then
      MapDataProjName := GetVarValue( '#DataMapProj' );
    MUDDCSSpace := MapDataAttribs.GetDCSSpace;
    MUDDCSpace := MUDDCSSpace.GetDCSpace;

    MapDataProj := K_DCSpaceProjectionGet( UDDCSpace, MUDDCSpace,
                                        MapDataProjName );
    if (MapDataProjName <> '') and (MapDataProj = nil) then
    begin
//      AShowWarning( 'ОШИБКА: не удается построить проекцию данных на карту -> загрузка прервана' );
//      goto LExit;
      CMapDescr := nil;
      goto EndOfMapLinkObjs;
    end;

   //*** Create Data DCSSpace for not mapping Data Elements
    j := MapDataAttribs.PDRA.ALength;
    SetLength( CSSIndexes, j );
    SetLength( DProj, CLCount );
    WInt1 := CLCount;
    if MapDataProjName <> '' then // Test Predefind MapData projection
      WInt1 := BuildDataElemIndsUnLinkedToMap( MapDataProj );
    if WInt1 = CLCount then begin
    // Search for Best MapData Projection
      WInt1 := SearchForBestMapDataProjection();
      if WInt1 = CLCount then
        CMapDescr := nil; // All Data Elements are not mapping - skip Cartogram objects creation
    end;

    NMUDDCSSpace := UDDCSpace.IndexOfCSS( @CSSIndexes[0], WInt1 );

    if NMUDDCSSpace = nil then begin // Cretate New DCSS
      NMUDDCSSpace := UDDCSpace.CreateDCSSpace( CName+'_NMECSS', WInt1, CCaption+'_NMECSS' );
      Move( CSSIndexes[0], NMUDDCSSpace.DP^, WInt1 * SizeOf(Integer) );
    end;

EndOfMapLinkObjs:
    //*** Add DataData Projection
    DataDataProjName := TabImportIni.ReadString('DataDataProjs', DataMapID, '' );
    if DataDataProjName = '' then
      DataDataProjName := GetVarValue( '#DiagramDataProj' );
    if DataDataProjName <> '' then
//      DataDataProj := K_DCSpaceProjectionGet( UDDCSpace, UDDCSpace,
//                                      DataDataProjName );
      DataDataProj := UDDCSpace.SearchProjByCSS( AUDDCSSpace );
//************************
//*** End of Map to Data Correspondence Objects Creation
//************************
  end;

  //*** Prepare Colors Path
  WList := TStringList.Create;
  WStr1 := GetVarValue( '#ScaleColors' );
  UColors := nil;
  if WStr1 <> '' then begin
    WUD := K_GetMVDarSysFolder( K_msdColorPaths );
    UColors := WUD.DirChildByObjName( WStr1, K_ontObjUName );
    if UColors = nil then begin
    // Search For Ini ColorsSet
      WStr2 := TabImportIni.ReadString( 'ColorSets', WStr1, '' );
      if WStr2 <> '' then begin
      // create new colors set
        UColors := K_MVDarNewUserNodeAdd( K_msdColorPaths,
            WUD, UDParent, DumpLine, WStr1 );
        WList := TStringList.Create;
        WList.CommaText := WStr2;
        TK_UDRArray(UColors).ASetLength(WList.Count);
        for i := 0 to WList.Count - 1 do
          PInteger(TK_UDRArray(UColors).R.P)^ := N_StrToColor( WList[i] );
      end;
    end;
  end;

 //*** Prepare Elements Captions
  with AUDDCSSpace.GetDCSpace.GetAliasesDir do begin
    UDElemCapts := nil;
    WStr1 := GetVarValue( '#ElemCapts' );
    if WStr1 <> '' then
      UDElemCapts := DirChildByObjName( WStr1, K_ontObjUName );
    if UDElemCapts = nil then UDElemCapts := DirChild(0);
  end;

 //*** Prepare Macro Stack
  TabMacroList := THashedStringList.Create;
  with TabMacroList do begin
    AddObject( K_itsMPrevList+'='+K_mtMacroNameSep, nil );
    Add( K_itsMCaption+'=' );
    Add( K_itsMLCaption+'=' );
  end;

  CMacroList := THashedStringList.Create;
  TabImportIni.ReadSectionValues('Macro', CMacroList );
  AddMacroVarsToMList( CMacroList, UDSrcRoot );
  with CMacroList do begin
    AddObject( K_itsMPrevList+'='+K_mtMacroNameSep, TabMacroList );
    Add( K_itsMCaption+'=' );
    Add( K_itsMLCaption+'=' );
  end;
  CMListTabCount := CMacroList.Count;

  //*** Prepare SpecValuesAttributes Reference
  UDRSVAttrs := nil;
  WStr1 := GetVarValue( '#SpecValuesName' );
  if WStr1 <> '' then
    UDRSVAttrs := K_GetMVDarSysFolder( K_msdSvalSets ).DirChildByObjName( WStr1, K_ontObjUName );
  if UDRSVAttrs = nil then
    UDRSVAttrs := K_CurArchSpecVals;
  RSVAttrs := TK_UDRArray(UDRSVAttrs).R;

//*** Prepare SpecValues Src Texts List
  SVList := THashedStringList.Create;
  WStr1 := GetVarValue( '#SpecValInfo' );
  SVList.DelimitedText := WStr1;

//*** For Regions That are not Include in Data Vector
  AbsRegSInd := TabImportIni.ReadInteger( CurParamsName, '#AbsRegSpecInd', 1 );
  if (AbsRegSInd < 0) or (AbsRegSInd > RSVAttrs.AHigh) then AbsRegSInd := RSVAttrs.AHigh;
//***  For Data Vector Elements With Undefined Values
  UndefValSInd := TabImportIni.ReadInteger( CurParamsName, '#UndefValSpecInd', 2 );
  if (UndefValSInd < 0) or (UndefValSInd > K_IniMVSpecVals.AHigh) then UndefValSInd := RSVAttrs.AHigh;

//***  For Data Vector Elements prepared by AverageDeviation Scale Builder
  StandardDeviationSInd := TabImportIni.ReadInteger('Common', '#StandardDeviationSpecInd', 3 );
  if (StandardDeviationSInd < 0) or (StandardDeviationSInd > K_IniMVSpecVals.AHigh) then StandardDeviationSInd := RSVAttrs.AHigh;

//***************************************
//   Build Data Represantion Objects Loop
  VectorDataSize := CLCount * SizeOf(Double);

  N_PBCaller.Start( UDSrcRoot.DirLength );
  for i := 1 to UDSrcRoot.DirHigh do begin
    N_PBCaller.Update(i);
    UDSrcTabSect := TK_UDRArray(UDSrcRoot.DirChild(i));
    // Clear previous Macro Values
    while CMacroList.Count > CMListTabCount do CMacroList.Delete(CMListTabCount);

    // Set New Macro Names
    CFolderName := format( '%.3d', [i] );
    CFolderAliase := UDSrcTabSect.GetUName;

    with CMacroList do begin
      Strings[CMListTabCount-2] := K_itsMCaption+'='+CFolderAliase;
      Strings[CMListTabCount-1] := K_itsMLCaption+'='+CFolderAliase;
    end;
{
    with TabMacroList do begin
      Strings[Count-2] := K_itsMCaption+'='+CCaption;
      Strings[Count-1] := K_itsMLCaption+'='+CCaption;
    end;
}
    // Add Level Macro Values
    AddMacroVarsToMList( CMacroList, UDSrcTabSect );

    CMListSectCount := CMacroList.Count;

    //*** Create Vectors Table
    CFolderCaption := MacroExpand( GetVarValue( '#SCaption', vlTab ), CFolderAliase );
    N_ReplaceEQSSubstr( CFolderCaption, '''', '"' );
    CFolderSCaption := MacroExpand( GetVarValue( '#MCaption', vlTab ), CFolderAliase );
    N_ReplaceEQSSubstr( CFolderSCaption, '''', '"' );

    with TabMacroList do begin
      Strings[Count-2] := K_itsMCaption+'='+CFolderSCaption;
      Strings[Count-1] := K_itsMLCaption+'='+CFolderCaption;
    end;

    CMVTab := BuildRepresentationObj( CFolderName, CFolderCaption, K_msdBTables, nil );
    TK_UDMVTable(CMVTab).Init(AUDDCSSpace);

    if CMapDescr <> nil then begin
      //*** Create WCart Group
      CMVWCartGroup := BuildRepresentationObj(  CFolderName,
                  'Группа WEB картограмм: '+CFolderAliase, K_msdWebCartGroupWins, nil );
      TK_PMVWebCartGroupWin(TK_UDRArray(CMVWCartGroup).R.P).VWinName :=
        GetVarValue( '#MapGroupWinID', vlTab );
    end;

    //*** Tab Section Vectors Loop
    SetLength( TabElemCapts, UDSrcTabSect.DirLength );
    SetLength( LDElemCapts, UDSrcTabSect.DirLength );
    for j := 0 to UDSrcTabSect.DirHigh do begin
      UDSrcSTabVector := UDSrcTabSect.DirChild(j);
      // Create new Data Vector

      // Clear previous Macro Values
      while CMacroList.Count > CMListSectCount do CMacroList.Delete(CMListSectCount);

      // Set New Macro Names
      CName := CFolderName + '_' + format( '%.2d', [j] );
      CCaption := UDSrcSTabVector.GetUName;
      N_ReplaceEQSSubstr( CCaption, '''', '"' );

      with CMacroList do begin
        Strings[CMListTabCount-2] := K_itsMCaption+'='+CCaption;
        Strings[CMListTabCount-1] := K_itsMLCaption+'='+CCaption;
      end;

      // Add Level Macro Values
      AddMacroVarsToMList( CMacroList, UDSrcSTabVector );

      CurInd := TK_UDMVTable(CMVTab).CreateColumn( CCaption, CName );
      TK_UDMVTable(CMVTab).GetSubTreeChildDE( CurInd, CurVDE );
      CMVVector := CurVDE.Child;

      VUnits := GetVarValue( '#Units', vlVector );
      if VUnits <> '' then //*** Add Units to Macro List
        CMacroList.Add( 'Units='+VUnits );

      PVV := TK_UDMVVector(CMVVector).DP;
      PMVVector := TK_PMVVector(TK_UDMVVector(CMVVector).R.P);

      with PMVVector^ do begin
      //******************************
      //***  Set Vector Values and Attributes
      //******************************
        Units := VUnits;
        FullCapt := MacroExpand( GetVarValue( '#SCaption', vlVector ), CCaption );
        N_ReplaceEQSSubstr( FullCapt, '''', '"' );
        BriefCapt := MacroExpand( GetVarValue( '#TCaption', vlVector ), CCaption );
        N_ReplaceEQSSubstr( BriefCapt, '''', '"' );
        LDElemCapts[j] :=
          MacroExpand( GetVarValue( '#DCaption', vlVector ), BriefCapt );
        N_ReplaceEQSSubstr( LDElemCapts[j], '''', '"' );
        TabElemCapts[j] :=
          MacroExpand( GetVarValue( '#TCaption', vlVector ), BriefCapt );
        N_ReplaceEQSSubstr( TabElemCapts[j], '''', '"' );

          // Values
        DumpLine := '';
        WInt2 := 0;
        with TK_UDRArray(UDSrcSTabVector).R do begin
          if FEType.D.TCode = Ord(nptString) then
            for k := 0 to AHigh do begin
              WStr1 := PString(P(k))^;
              Val( K_ReplaceCommaByPoint( WStr1 ), PVV^, WInt1 );
              if WInt1 > 0 then begin
                WInt1 := SVList.IndexOfName( WStr1 );
                if WInt1 >= 0 then begin // Special Value is found
                  WInt1 := StrToIntDef(SVList.ValueFromIndex[WInt1], -1);
                  if (WInt1 < 0) or (WInt1 > RSVAttrs.AHigh) then WInt1 := UndefValSInd;
                  PVV^ := TK_PMVDataSpecVal( RSVAttrs.P(WInt1) )^.Value;
                end else begin
                  Inc(WInt2);
                  PVV^ := TK_PMVDataSpecVal( RSVAttrs.P(UndefValSInd) )^.Value;
                end;
              end;
              Inc(PVV);
            end
          else
            Move( P^, PVV^, VectorDataSize );
        end;
      //******************************
      //***  end of  Setting Vector Values and Attributes
      //******************************

      end;
      // Такой способ получения на всякий случай - здесь достаточно было бы TK_UDMVTable(CMVTab).GetAttribs
      PMVVAttrs := TK_PMVVAttrs(TK_UDMVTable(CurVDE.Parent.Owner).GetUDAttribs(CurInd).R.P);
      with PMVVAttrs^ do begin
      //******************************
      //***  Set View Attributes
      //******************************
        ValueType.T := K_vdtContinuous;
        AutoRangeCapts.T := K_aumAuto;
        AutoRangeVals.T := K_aumAuto;
        AutoMinMax.T := K_aumAuto;

       // Spec Values
        K_SetUDRefField( UDSVAttrs, UDRSVAttrs );

       // Abs Elem Spec Values
        AbsDCSESVIndex := AbsRegSInd;

       // Values Precision
        WStr1 := GetVarValue( '#ValuesPrecision', vlVector );
        if WStr1 <> '' then
          Val( WStr1, VDPPos, WInt1 );

       //*** Main Scale Attribs
       // Main Scale Precision
        WStr1 := GetVarValue( '#ScalePrecision', vlVector );
        if WStr1 <> '' then
          Val( WStr1, RDPPos, WInt1 );

       // Main Scale Precision
        PureValPatType.T := K_vttAuto;
        WStr1 := GetVarValue( '#ValuesVectorPatType', vlVector );
        if WStr1 <> '' then
          Val( WStr1, PureValPatType.R, WInt1 );
        PureValToTextPat := GetVarValue( '#ValuesVectorPat', vlVector );

        NamedValPatType.T := K_vttAuto;
        WStr1 := GetVarValue( '#NamedValuesVectorPatType', vlVector );
        if WStr1 <> '' then
          Val( WStr1, NamedValPatType.R, WInt1 );
        NamedValToTextPat := GetVarValue( '#NamedValuesVectorPat', vlVector );

         // Main Auto Scale Type
        WStr1 := GetVarValue( '#AutoScaleType', vlVector );
        WInt1 := Ord(K_artOptimal);
        if WStr1 <> '' then
          WInt1 := StrToIntDef(WStr1, WInt1 );

        if WInt1 = -1 then
          ValueType.T := K_vdtDiscrete;

        if (WInt1 < Ord(K_artEqualNElems)) and (WInt1 > Ord(K_artStdDev123)) then
          WInt1 := Ord(K_artOptimal);

        AutoRangeType.R := WInt1;

        if ValueType.T = K_vdtContinuous then begin
          WStr1 := GetVarValue( '#ScaleLength', vlVector );
          RangeCount := StrToIntDef(WStr1, 5 );
        end;
        // Main Scale Values
        WStr1 := GetVarValue( '#ScaleValues', vlVector );
        if WStr1 <> '' then begin
          WList.Delimiter := ';';
          WList.DelimitedText := WStr1;
          WInt1 := 0;
          RangeValues.ASetLength( WList.Count );
          PVV := PDouble(RangeValues.P);
          for k := 0 to WList.Count - 1 do begin
            Val( K_ReplaceCommaByPoint( WList.Strings[k] ), PVV^, WInt2);
            if WInt2 > 0 then break;
            Inc(WInt1);
            Inc(PVV);
          end;
          RangeValues.ASetLength( WInt1 );
          AutoRangeVals.T := K_aumAuto;
        end;

        // Main Auto Format
        AutoCaptsFormat.ASetLength(3);
        WStr1 := GetVarValue( '#AutoFormat1', vlVector );
        if WStr1 <> '' then
          PString(AutoCaptsFormat.P(0))^ := WStr1;
        WStr1 := GetVarValue( '#AutoFormat2', vlVector );
        if WStr1 <> '' then
          PString(AutoCaptsFormat.P(1))^ := WStr1;
        WStr1 := GetVarValue( '#AutoFormat3', vlVector );
        if WStr1 <> '' then
          PString(AutoCaptsFormat.P(2))^ := WStr1;

        WInt1 := RangeValues.ALength;
        if (WInt1 > 0) then begin
          if (ValueType.T = K_vdtContinuous) then Inc(WInt1);
          RangeCaptions.ASetLength( WInt1 );
        end;

        // Main Scale Texts
        WStr1 := GetVarValue( '#ScaleTexts', vlVector );
        if WStr1 <> '' then begin
          WList.CommaText := WStr1;
          WInt1 := RangeCaptions.ALength;
          if WInt1 = 0 then
            RangeCaptions.ASetLength(WList.Count);
          for k := 0 to WList.Count - 1 do
            PString(RangeCaptions.P(k))^ := WList[k];
          AutoRangeCapts.T := K_aumManual;
          if ValueType.T = K_vdtDiscrete then begin
            NamedValPatType.T := K_vttNameRange;
            PureValPatType.T := K_vttNameRange;
          end;
        end;

        // Main Scale Colors
        K_SetUDRefField( TN_UDBase(ColorsSet), UColors );
        WStr1 := GetVarValue( '#UseColorsType', vlVector );
        if WStr1 <> '' then
          BuildColorsType.R := StrToIntDef(WStr1, 0 );

        // Main Scale to Dimensionless Value convertion
        // Wrk Zone Min
        WStr1 := GetVarValue( '#VMin', vlVector );
        WInt2 := 0;
        if WStr1 <> '' then begin
          Val( K_ReplaceCommaByPoint( WStr1 ), VMin, WInt1 );
          if WInt1 = 0 then begin
            VMax := K_MVMinVal;
            Inc(WInt2);
          end;
        end;

        // Wrk Zone Max
        WStr1 := GetVarValue( '#VMax', vlVector );
        if WStr1 <> '' then begin
          Val( K_ReplaceCommaByPoint( WStr1 ), VMax, WInt1 );
//          if WInt1 <> 0 then Inc(WInt2)
//          else VMax := K_MVMinVal;
          if WInt1 = 0 then begin
            if WInt2 = 0 then VMin := K_MVMinVal;
            Inc(WInt2);
          end;
        end;
        if WInt2 >= 1 then // #VMin or #VMax are defined
          AutoMinMax.T := K_aumManual;

        WStr1 := GetVarValue( '#DBasePoint', vlVector );
        WInt1 := 1;
        if WStr1 <> '' then
          Val( WStr1, VBase, WInt1 );
        if WInt1 <> 0 then VBase := VMin;

        WStr1 := GetVarValue( '#SkipLHistSvalMode' );
        WInt1 := 1;
        if WStr1 <> '' then
          Val( WStr1, LHShowFlags.R, WInt1 );
        if WInt1 <> 0 then LHShowFlags.R := 1; // LinHist Show Flags are not defined

        WStr1 := GetVarValue( '#DICoeffs', vlVector );
        if WStr1 <> '' then begin
          WList.Delimiter := ';';
          WList.DelimitedText := WStr1;
          VDConv.ASetLength(WList.Count * 2);
          WInt2 := 0;
          for k := 0 to WList.Count - 1 do begin
            Val( K_ReplaceCommaByPoint( WList.Names[k] ), PDouble(VDConv.P(WInt2))^, WInt1 );
            Val( K_ReplaceCommaByPoint( WList.Values[WList.Names[k]] ), PDouble(VDConv.P(WInt2+1))^, WInt1 );
            Inc( WInt2, 2);
          end;
        end;

       // Set Elements Captions
        K_SetUDRefField( ElemCapts, UDElemCapts );

       // Diagram Axis Attributes
        AxisTickUnits := PMVVector^.Units;

       // Rebuild Vector Attributes
//        K_RebuildMVAttribs( PMVVAttrs^, PMVVector^.D );
        K_RebuildMVAttribs( PMVVAttrs^, PMVVector );

       // Try to Set Discrete Values Captions
        if ValueType.T = K_vdtDiscrete then begin
          WStr1 := GetVarValue( '#ScaleDTexts', vlVector );
          if WStr1 <> '' then begin
            WList.CommaText := WStr1;
            WInt1 := RangeCaptions.ALength;
            if WInt1 = 0 then
              RangeCaptions.ASetLength(WList.Count);
            for k := 0 to WList.Count - 1 do
              PString(RangeCaptions.P(k))^ := WList.Values[PString(RangeCaptions.P(k))^];
            NamedValPatType.T := K_vttNameRange;
            PureValPatType.T := K_vttNameRange;
          end;
        end;
      //******************************
      //***  end of Setting View Attributes
      //******************************
      end;

      if CMapDescr <> nil  then begin
        //******************************
        //***  Set Vector Cartogram
        //******************************

        //*** Create WCart
        CMVWCart := TN_UDBase( K_MVDarNewUserNodeAdd( K_msdWebCartWins,
            nil, nil, DumpLine,
            'WC: '+CCaption, CName+'WC', CMapDescr ) );
        // Add to CartogramGroup
        CurDE.Child := CMVWCart;

        // Set Cartogram Attributes
        CMVWCart.AddChildToSubTree( @CurVDE );

          // Input Values and correct attribs
        with TK_PMVWebCartWin(TK_UDMVWCartWin(CMVWCart).R.P)^ do begin
          VWinName := GetVarValue( '#MapWinID', vlVector );
          PageCaption := MacroExpand( GetVarValue( '#PCaption', vlVector ), PageCaption );
          N_ReplaceEQSSubstr( PageCaption, '''', '"' );
        end;

        // Set Cartogram Layer Attributes
        with TK_PMVCLCommon(TK_UDRArray(CMVWCart.DirChild(0)).R.P)^ do begin
            // Map Projection
          K_SetUDRefField( DCSP, MapDataProj );
            // Legend Header
          LegHeader := MacroExpand( GetVarValue( '#LegendHeader', vlVector ), LegHeader );
            // Legend Footer
          LegFooter := MacroExpand( GetVarValue( '#LegendFooter', vlVector ), LegFooter );
           // Legend Columns Count
          WStr1 := GetVarValue( '#LegColCount', vlVector );
          if WStr1 <> '' then
             Val( WStr1, LEColNum, WInt1 );
           // Legend Rows Count
          WStr1 := GetVarValue( '#LegRowCount', vlVector );
          if WStr1 <> '' then
             Val( WStr1, LERowNum, WInt1 );
        end;

        if CurDE.Child = CMVWCart  then // Add to CartogramGroup
          CMVWCartGroup.AddChildToSubTree( @CurDE );
        //******************************
        //***  end of Vector Cartogram Setting
        //******************************
      end;

      if VUnits <> '' then
        with CMacroList do Delete( Count - 1 );

  //******************************
  //***  end of Data Vector Parsing
  //******************************

    end; //*** end of Vectors Loop

    //*** Create WWGroup with WTable, WDiagram, WMGroup
    CreateGroupObjects();

  end;
  Result := true;
//  end of Data Represantion Objects Build Loop
//***************************************

LExit:
//  K_MacroListClearItems( CMacroList );
  UDSrcRoot.Free;
  CMacroList.Free;
  TabMacroList.Free;
  WList.Free;
  SVList.Free;
  N_PBCaller.Finish();
end;

end.
