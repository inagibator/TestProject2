unit K_TSImport0;

interface

uses IniFiles, ComCtrls, Classes,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  N_Types,
  K_Types, K_Arch, K_IMVDar, K_IndGlobal, K_UDT1, K_CLib0;

function  K_MVImportTabStruct0( ImportTSFlags : TK_ImportTSFlags;
        MVFolder : TN_UDBase; MVWebFolder : TN_UDBase; StrMatr1 : TN_ASArray;
        TabImportIni : TMemIniFile; SourceName : string = ''; PNodesList : PTStrings = nil;
        ShowWarning : TK_MVShowMessageProc = nil ) : Boolean;

implementation

uses  Math, Dialogs, Controls, Forms, Clipbrd, SysUtils,
  N_ClassRef, N_Lib1, N_Lib0,
  K_VFunc, K_parse, K_DCSpace, K_MVObjs, K_MVMap0,
  K_UDT2, K_Script1, K_FMVBase, K_FMVTSImpUnRegs;

//**************************************** K_MVImportTabStruct0
// Import Table Structure (current version)
//
function  K_MVImportTabStruct0( ImportTSFlags : TK_ImportTSFlags;
        MVFolder : TN_UDBase; MVWebFolder : TN_UDBase; StrMatr1 : TN_ASArray;
        TabImportIni : TMemIniFile; SourceName : string = ''; PNodesList : PTStrings = nil;
        ShowWarning : TK_MVShowMessageProc = nil ) : Boolean;

label ContLevelLoop;

type TK_ITSLevelData = record
  WParent : TN_UDBase;
  SParent : TN_UDBase;
  VarsList : TStrings;
  VarsSetList : TStrings;
  NamesMacroList : TStrings;
  WasCreated : Boolean;
  SWasCreated : Boolean;
end;

var
  CSSBaseName : string;
  MDR : word;
  HDataDirection : Boolean;
  SFCreated : Boolean;
  FCreated : Boolean;
  ICreated : Boolean;
  i, h, CRegStartN, j, jh : Integer;
  CClist : THashedStringList;
  CMlist : THashedStringList;
  CMnds : TN_IArray;
  ArchiveNodesList : TStrings;
  SearchInd : Integer;
  DumpLine : string;
  IColSet, IColLevelType, IColID, IColCaption, IColLCaption : Integer;
  Regs : TN_SArray;
  RegColIndex : TN_IArray;
  DProj, WIndexes, MEIndexes, RegICodes, DRIndexes : TN_IArray;
  LSRegs, LRegs, WInd : Integer;
  WLine : string;
  WDI, DI : TN_UDBase;
  DCSpace : TK_UDDCSpace;
  MDCSSpace, ADCSSpace, DCSSpace : TK_UDDCSSpace;
  NotMappingCSS : TK_UDDCSSpace;
  MappingCSS : TK_UDDCSSpace;
  DCSLength : Integer;
  WUD1, WUD : TN_UDBase;
  ParLevelNum : Integer;
  WLevelNum : Integer;
  CLevelNum : Integer;
  CWlineLength : Integer;
  IncCLevelNum : Boolean;
  StructLevelType : Boolean;
//  NextStructLevelType : Boolean;
  CType : Char;
  ParseStack : array of TK_ITSLevelData;
  CFolder   : TN_UDBase;
  CSFolder  : TN_UDBase;
  CMVVector : TN_UDBase;
  CMVWeights : TN_UDBase;
  CurDE  : TN_DirEntryPar;
  CurVDE  : TN_DirEntryPar;
  CMVTab    : TN_UDBase;
  CMVTabVCount : Integer;
  CMVWTab   : TN_UDBase;
  CMVWCart  : TN_UDBase;
  CMVWinGroup  : TN_UDBase;
  CMVWinGroupLevel  : Integer;
  CMVWCartGroup : TN_UDBase;
  CMVWLDiagram  : TN_UDBase;
  TabElemCapts : TN_SArray;
  LDElemCapts : TN_SArray;
  PVV : PDouble;
  PMVVAttrs : TK_PMVVAttrs;
  PMVVector : TK_PMVVector;
  VUnits : string;
  CMVHTM : TN_UDBase;
  UDHTMCI : Integer;
  HTMSysTypeOrd : Integer;
  PHTMPars : Pointer;

//*******
  CMapDescr : TN_UDBase;
  MapDataAttribs : TK_UDVector;
  MapDataProj : TK_UDVector;
  MapDataProjName : string;
  DataDataProj : TK_UDVector;
  DataDataProjName : string;
  CFolderName : string;
  CFolderLName : string;
  CFolderObjName : string;
  CFolderListCapt : string;
  CFolderMenuCapt : string;
  CMacroList : THashedStringList;
  CVarsList : THashedStringList;
  CVarsSetList : THashedStringList;
  CID : string;
  CName : string;
  CLName : string;
//  WPatName : string;
  WStr1, WStr2 : string;
  WEBPath, DocPath : string;
  PrefName : string;
  SkipObjFLag : string;

  CurInd : Integer;
//  IndAddParams : array of TK_IndAddParams;
  CUDScalars : TN_UDBase;
  CLBStr : string;
  CLBID : string;
  StartLevelStruct : Boolean;

// Diagram and Theme and HTMPrompt work Vars
  WW1, WW2, WW3 :Integer;
  WBool : Boolean;
  WList : TStringList;

// HTMPrompt work Vars
//  HTMLType : Integer;
  UDV  : TN_UDBase;
  AbsRegSInd, UndefValSInd, StandardDeviationSInd : Integer;
  RSVAttrs : TK_RArray; // Special Values Structure
  UDRSVAttrs : TN_UDBase; // Special Values UDBase
  SVList : THashedStringList;
// Folder work Vars
  CUDSight : TN_UDBase;
  CMVWVTreeWin : TN_UDBase;
  CUDSightArr : array of TN_UDBase;
  LegFooterRegCode : string;
  LegFooterRegInd  : Integer;
  LegFooterRegCSSInd : Integer;

//*** Check United Regions
  RAURegs : TK_RArray;
  URegsCount : Integer;
  URegs1All : TN_IArray;
  URegsU : TN_IArray;
  URegsC : TN_IArray;
  URegM1 : Integer;
  URegM2 : Integer;
  URegError : Boolean;
  URegErrorStr : string;
  URegNames : TN_SArray;
  URegVisCSS  : TN_UDBase;

  RangeValsArr : TN_DArray;
  PureValsArr : TN_DArray;
  PureValsInds : TN_IArray;
  PureValsCount : Integer;
  PPureValsInds : PInteger;
  PPureValsVals : PDouble;

const

  K_itsNLevelType = '#LevelType';
  K_itsNID = '#ID';
  K_itsNCaption = '#Caption';
  K_itsNLCaption = '#LCaption';

//***
  K_itsNSet = '#Set';
  K_itsParams = '#Params';

  K_itsLevelWeights = 'W';
  K_itsLevelFolder = 'L';
  K_itsLevelGroup  = 'G';
  K_itsLevelTable  = 'T';
  K_itsLevelData   = 'D';
  K_itsLevelVHTM   = 'H';
  K_itsLevelHTM    = 'h';
  K_itsLevelComment = '*';

//***
  K_itsMCaption = 'Caption';
  K_itsMLCaption = 'LCaption';
  K_itsMPrevList = 'P';

  W1 : array [0..4] of string  = ( ' столбец ', ' столбца ', ' столбцы ', ' столбцах ', ' столбцe ' );
  W2 : array [0..4] of string  = ( ' строка ', ' строки ', ' строки ', ' строках ', ' строкe ' );


  function BuildObjAliase( Prefix, ObjID, Aliase : string ) : string;
  begin
    Result := Prefix;
    if K_itfAddIDtoObjAliase in ImportTSFlags then
      Result := Result + ObjID;
    Result := Result + ' ' + Aliase;
  end;

  function WarnColName( Variant : Integer ) : string;
  begin
    if HDataDirection then
      Result := W1[Variant]
    else
      Result := W2[Variant]
  end;

  function WarnRowName( Variant : Integer ) : string;
  begin
    if HDataDirection then
      Result := W2[Variant]
    else
      Result := W1[Variant]
  end;

  function StrMatr( Row, Col : Integer ) : string;
  begin
    if HDataDirection then
      Result := StrMatr1[Row, Col]
    else
      Result := StrMatr1[Col, Row];
  end;

  function HighStrMatrRow : Integer;
  begin
    Result := High(StrMatr1);
    if not HDataDirection and (Result >= 0) then
      Result := High(StrMatr1[0])
  end;

  function HighStrMatrCol : Integer;
  begin
    Result := High(StrMatr1);
    if HDataDirection and (Result >= 0) then
      Result := High(StrMatr1[0])
  end;

  procedure Dump( DLine : string; MesStatus : TK_MesStatus = K_msError );
  begin
    if Assigned(ShowWarning) then
      ShowWarning('ИСТОЧНИК "'+ SourceName + '"'+#$D+#$A+DLine, MesStatus );
  end;

  procedure NextParseLevel;
  begin
    SetLength( ParseStack, WLevelNum + 1 );
    with ParseStack[WLevelNum] do begin
      WParent := CFolder;
      SParent := CSFolder;
      VarsList := CVarsList;
      CVarsList := nil;
      VarsSetList := CVarsSetList;
      CVarsSetList := nil;
      WasCreated := FCreated;
      SWasCreated := SFCreated;
      if WLevelNum > 0 then begin
        NamesMacroList := THashedStringList.Create;
        with CMacroList do
          Objects[Count-3] := NamesMacroList;
        with NamesMacroList do begin
          AddObject(K_itsMPrevList+'=.', ParseStack[WLevelNum-1].NamesMacroList );
          AddObject(K_itsMCaption+'='+CFolderName, nil );
          AddObject(K_itsMLCaption+'='+CFolderLName, nil );
        end;
      end else
        NamesMacroList := nil;
    end;
//    CVarsList := nil; // Set "Create List" flag
  end;

  procedure FreeStackLevel;
  var i : Integer;
  begin
    if ParLevelNum <= WLevelNum then Exit;
    for i := ParLevelNum downto WLevelNum + 1 do begin
      with ParseStack[i] do begin
        FreeAndNil( VarsList );
        FreeAndNil( VarsSetList );
        FreeAndNil( NamesMacroList );
      end;
    end;
    with CMacroList do
      Objects[Count-3] := ParseStack[WLevelNum].NamesMacroList;
  end;

  procedure InitCurVarsSetList;
  begin
    TabImportIni.ReadSectionValues(
      CVarsList.Values['#Params'],
      CVarsSetList );
  end;

  procedure InitCurVarsContext;
  var
    i, ii : Integer;
    WStr : string;
  begin
    if CVarsList = nil then begin
      CVarsList := THashedStringList.Create;
      CVarsSetList := THashedStringList.Create;
    end else begin
      CVarsList.Clear;
      CVarsSetList.Clear;
    end;

    if IColSet <> -1 then
      CVarsList.CommaText := StrMatr(j,IColSet);
    for i := 0 to CClist.Count - 1 do begin
      ii := Integer(CClist.Objects[i]);
      WStr := CClist[i];
      if ( ii = IColLCaption ) or
         ( ii = IColCaption )  or
         ( ii = IColID )       or
         ( ii = IColLevelType )or
         ( ii = IColSet )      or
         ( CVarsList.IndexOf( WStr ) <> -1 ) then continue;
      CVarsList.Add( WStr+'='+StrMatr(j, ii ) );
    end;

    InitCurVarsSetList;

  end;

  function GetVarValue( VarName : string; SearchInParent : Boolean = true ) : string;
  var i : Integer;
  begin
    Result := '';
    if CVarsList = nil then Exit;
    Result := CVarsList.Values[VarName];
    if Result = '' then
      Result := CVarsSetList.Values[VarName];
    if (Result <> '') or not SearchInParent then Exit;
//*** Search in Parents Stack
    for i := WLevelNum downto 0 do
      with ParseStack[i] do begin
        Result := VarsList.Values[VarName];
        if Result = '' then
          Result := VarsSetList.Values[VarName];
        if Result <> '' then break;
      end;
  end;

  function MacroExpand( Pattern, DefValue : string ) : string;
  begin
    Result := TabImportIni.ReadString( 'Patterns', Pattern, DefValue );
    if Result = DefValue then begin
      if Pattern = '' then Exit;
      Result := Pattern;
    end;
    Result := K_StringMListReplace( Result, CMacroList, K_ummRemoveMacro );
{!!! Not Tested Change
    if Result <> DefValue then begin // MacroExpand
      Result := K_StringMListReplace( Result, CMacroList, K_ummRemoveMacro );
//      Result := K_StringMListReplace( ' '+Result, CMacroList, K_ummRemoveMacro );
//      Result := Copy( Result, 2, Length(Result) );
    end else if Pattern <> '' then // No Macros with name Pattern - may be Pattern is Macros
      Result := K_StringMListReplace( Pattern, CMacroList, K_ummRemoveMacro );
}
  end;

  procedure GetSelfDirEnry( Node : TN_UDBase; out DE : TN_DirEntryPar );
  begin
    with Node.Owner do
      GetDirEntry( IndexOfDEField(Node), CurDE );
  end;

  function GetSCurCellValue( Ind : Integer; DefValue : string = '' ) : string;
  begin
    if Ind = -1 then Result := ''
    else Result := Trim( StrMatr(j,Ind) );
//    else Result := Trim( StrMatr[j,Ind] );
  end;

  function GetObjFromNodesList( SName : string ) : TN_UDBase;
  begin
    Result := nil;
    if ArchiveNodesList <> nil then begin
        SearchInd := ArchiveNodesList.IndexOf( SName );
        if SearchInd <> -1 then begin
          Result := TN_UDBase( ArchiveNodesList.Objects[SearchInd] );
          with ParseStack[WLevelNum] do
            if SWasCreated then
              SParent.AddOneChildV(Result)
        end;
    end;
  end;

  function GetGroupObj( Name, Aliase  : string;
               ObjSysType : TK_MVDARSysType; UDInd : Integer ) : TN_UDBase;
  var
    LRoot : TN_UDBase;
  begin
{
    if (UDInd = K_UDMVTableCI) and
       (K_itfSkipWEBObjs in ImportTSFlags) then
      LRoot := ParseStack[WLevelNum].SParent
    else
}
      LRoot := CSFolder;
    Name := K_MVDARSysObjNames[Ord(ObjSysType)]+ Name;
    Result := GetObjFromNodesList( Name+':'+N_ClassTagArray[UDInd] );
    if Result = nil then begin
      Result := K_MVDarNewUserNodeAdd( ObjSysType, nil,
        LRoot, DumpLine, Aliase, Name );
//        CSFolder, DumpLine, Aliase, Name );
//        ParseStack[WLevelNum].SParent, DumpLine, Aliase, Name );
      if ArchiveNodesList <> nil then
        ArchiveNodesList.AddObject(
                    Result.ObjName+':'+N_ClassTagArray[UDInd], Result );
    end;
    with TK_PMVWebWinObj(TK_UDRArray(Result).R.P)^ do begin
      FullCapt := CFolderListCapt;
      BriefCapt := CFolderMenuCapt;
    end;
  end;

  function SearchWinGroup : Boolean;
  begin
    Result := false;
    if (K_itfSkipNotWEBObjs in ImportTSFlags)      and
       not (K_itfRebuildPublData in ImportTSFlags) and
       (K_itfUseExistedData in ImportTSFlags) then begin
      //*** Try to Link Existing Web Group Instead Of Its Creation
      SearchInd := ArchiveNodesList.IndexOf(
        K_MVDARSysObjNames[Ord(K_msdWebWinGroups)]+CID+':'+N_ClassTagArray[K_UDMVWWinGroupCI] );
      Result := (SearchInd <> -1) and (CFolder <> nil);
      if Result then begin
        CMVWinGroup := CFolder.AddOneChildV( TN_UDBase( ArchiveNodesList.Objects[SearchInd] ) );
        with TK_PMVWebWinGroup(TK_UDRArray(CMVWinGroup).R.P)^ do begin
          WStr1 := GetSCurCellValue( IColLCaption );
          if WStr1 <> '' then
            FullCapt := MacroExpand( GetVarValue( '#SCaption' ), WStr1 );
          WStr1 := GetSCurCellValue( IColCaption, CLName );
          if WStr1 <> '' then
            BriefCapt := MacroExpand( GetVarValue( '#MCaption' ), WStr1 );
        end;
      end;
      Result := Result  or (K_itfSkipNotWEBObjs in ImportTSFlags);
    end;
  end;

  procedure CreateWinGroup;
  var
    CObjName : string;
  begin
//******************************
//***    Build WebWinGroup - Theme
//******************************
    if CMVWinGroup = nil then begin
      CObjName := K_MVDARSysObjNames[Ord(K_msdWebWinGroups)]+CFolderObjName;
      if ArchiveNodesList <> nil then begin
        SearchInd := ArchiveNodesList.IndexOf(
          CObjName+':'+N_ClassTagArray[K_UDMVWWinGroupCI] );
        if SearchInd <> -1 then begin
          CMVWinGroup := TN_UDBase( ArchiveNodesList.Objects[SearchInd] );
          CMVWinGroupLevel := WLevelNum;
        end;
      end;
    end;
    if CMVWinGroup = nil then begin
      CMVWinGroup := TN_UDBase( K_MVDarNewUserNodeAdd( K_msdWebWinGroups,
        nil, CSFolder, DumpLine,
//        nil, ParseStack[ParLevelNum].SParent, DumpLine,
        BuildObjAliase( 'WEB группа:', CFolderObjName, CFolderName ), CObjName ) );
      ParseStack[ParLevelNum].WParent.AddOneChildV( CMVWinGroup );
      if ArchiveNodesList <> nil then
        ArchiveNodesList.AddObject(
          CMVWinGroup.ObjName+':'+N_ClassTagArray[K_UDMVWWinGroupCI], CMVWinGroup );
      CMVWinGroupLevel := WLevelNum;
    end;
    if (K_itfRebuildPublData in ImportTSFlags) or
       not (K_itfUseExistedData in ImportTSFlags) then begin
    //***    Set WebLDiagram Params
      if( CMVWinGroupLevel = WLevelNum ) then
        CMVWinGroup.SelfSubTreeRemove; // Remove previous Group Elements if needed
      with TK_PMVWebWinGroup(TK_UDRArray(CMVWinGroup).R.P)^ do begin
        FullCapt := CFolderListCapt;
        BriefCapt := CFolderMenuCapt;
      // Page Name
        Title := FullCapt;
      // Title WinID
        TVWinName :=  GetVarValue( '#HeaderWinID' );
      end;
    end;
//******************************
//*** end of WebWinGroup - Theme
//******************************

  end;

  procedure CreateTableGroupObjects;
  var
    i, h : Integer;
    CObjName : string;
    FixCSS : TK_UDDCSSpace;
    FixInd : Integer;
    PInd : PInteger;
    WVMin, WVMax : Double;
    MinMaxRecalc : Boolean;
{
    //************************************** SetFixRegion
    //  Set New Fix Region Value
    //
    procedure SetFixRegion( PFixRegInd : PInteger );
    begin
      FixCSS := DCSpace.IndexOfCSS( PFixRegInd, 1 );
      if FixCSS = nil then begin
        TN_UDBase(FixCSS) := DCSpace.GetSSpacesDir.DirChildByObjName( '***###???DFR' );
        if FixCSS = nil then
          TN_UDBase(FixCSS) := DCSpace.GetSSpacesDir.DirChildByObjName( '***$$$???DFR' );
        if FixCSS <> nil then begin
          DCSpace.GetItemsInfo( @WStr1, K_csiCSName, PInteger( FixCSS.DP(0) )^ );
          DCSpace.GetItemsInfo( @WStr2, K_csiCSName, FixInd );
          if mrYes <> MessageDlg( 'Текущий фиксированный регион "'+ WStr1 + '"'+#$D+#$A+
                                  ' заменить на "' + WStr2+ '"?',
                                  mtConfirmation, [mbYes, mbNo], 0) then Exit;
        end else
          FixCSS := DCSpace.CreateDCSSpace( '***###???DFR', 1, MVFolder.ObjAliase+' DFR' );
        Move( FixInd, FixCSS.DP^, SizeOf(Integer) );
      end;
    end;
}
  begin
    if (CSFolder = nil) then Exit;
    GetSelfDirEnry( CMVTab, CurDE );
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
    CMVWLDiagram := nil;
    SkipObjFLag := GetVarValue( '#SkipWEB-Diagram' );
    if (SkipObjFLag = '') or (SkipObjFLag = '0') then begin
      CObjName := K_MVDARSysObjNames[Ord(K_msdWebLDiagramWins)]+CFolderObjName;
      if ArchiveNodesList <> nil then begin
        SearchInd := ArchiveNodesList.IndexOf(
          CObjName+':'+N_ClassTagArray[K_UDMVWLDiagramWinCI] );
        if SearchInd <> -1 then
          CMVWLDiagram := TN_UDBase( ArchiveNodesList.Objects[SearchInd] );
      end;
      if CMVWLDiagram = nil then begin
        CMVWLDiagram := TN_UDBase( K_MVDarNewUserNodeAdd( K_msdWebLDiagramWins,
          nil, CSFolder, DumpLine,
//          nil, ParseStack[ParLevelNum].SParent, DumpLine,
          BuildObjAliase( 'WEB диаграмма:', CFolderObjName, CFolderName ), CObjName ) );
        if ArchiveNodesList <> nil then
          ArchiveNodesList.AddObject(
            CMVWLDiagram.ObjName+':'+N_ClassTagArray[K_UDMVWLDiagramWinCI], CMVWLDiagram );
      end;
      if (K_itfRebuildPublData in ImportTSFlags) or
         not (K_itfUseExistedData in ImportTSFlags) then begin
      //***    Set WebLDiagram Params
        CMVWLDiagram.SelfSubTreeRemove; // Remove previous section if needed
        with TK_PMVWebLDiagramWin(TK_UDRArray(CMVWLDiagram).R.P)^ do begin
          ASWENType.T := K_gecWEParent;
          FullCapt := MacroExpand( GetVarValue( '#DiagramCaption' ), CFolderListCapt );
          BriefCapt := FullCapt;
        // Page Name
          Title := FullCapt;
        // WinID
          VWinName := GetVarValue( '#DiagramWinID' );
        // Hist Data to Data Projection
          K_SetUDRefField( CSProj1, DataDataProj );
        // Skip ability to raise "change vector" event
          if K_itfSkipDataToMapBinding in ImportTSFlags then
            Include( ShowFlags.T, K_dsfSkipSelColCtrl );
        // Add New Diagram section
          CMVWLDiagram.AddChildToSubTree( @CurDE );
        // Set Section elements Captions
          h := High(LDElemCapts);
          with TK_PMVWebSection(Sections.P)^ do begin
            Caption := FullCapt;
            for i := 0 to h do
              if LDElemCapts[i] <> '' then  PString(WECapts.P(i))^ := LDElemCapts[i];
          end;
        // Fixed Region Code
          FixCSS := nil;
          WStr1 := GetVarValue( '#DFixDataCode' );
          if WStr1 = '' then
            WStr1 := GetVarValue( '#DFixRegCode' );
          if WStr1 <> '' then begin
            FixInd := DCSpace.IndexByCode(WStr1);
            if FixInd <> -1 then begin
//              SetFixRegion( @FixInd );

              FixCSS := DCSpace.IndexOfCSS( @FixInd, 1 );
              if FixCSS = nil then begin
                FixCSS := DCSpace.CreateDCSSpace( '***###???DFR', 1, MVFolder.ObjAliase+' DFR' );
                Move( FixInd, FixCSS.DP^, SizeOf(Integer) );
              end;
            end;
          end;
        // Fixed Region Number
          if FixCSS = nil then begin
            WStr1 := GetVarValue( '#DFixDataInd' );
            if WStr1 = '' then
              WStr1 := GetVarValue( '#DFixRegion' );
            if WStr1 <> '' then begin
              FixInd := StrToIntDef(WStr1, -1);
              if FixInd <> -1 then begin
                PInd := PInteger(ADCSSpace.DP(FixInd));
                if PInd <> nil then begin
//                  SetFixRegion( PInd );
                  FixCSS := DCSpace.IndexOfCSS( PInd, 1 );
                  if FixCSS = nil then begin
                    FixCSS := DCSpace.CreateDCSSpace( '***###???DFR', 1, MVFolder.ObjAliase+' DFR' );
                    Move( PInd^, FixCSS.DP^, SizeOf(Integer) );
                  end;
                end;
              end;
            end;
          end;

        // Fixed Region Number CSS
          K_SetUDRefField( PECSS, FixCSS );
        end;
      end;
    end;
//******************************
//*** end of  WebLDiagram
//******************************

//******************************
//***    Build WebTable
//******************************
    CMVWTab := nil;
    SkipObjFLag := GetVarValue( '#SkipWEB-Table' );
    if (SkipObjFLag = '') or (SkipObjFLag = '0') then begin
      CObjName := K_MVDARSysObjNames[Ord(K_msdWebTableWins)]+CFolderObjName;
      if ArchiveNodesList <> nil then begin
        SearchInd := ArchiveNodesList.IndexOf(
          CObjName+':'+N_ClassTagArray[K_UDMVWTableWinCI] );
        if SearchInd <> -1 then
          CMVWTab := TN_UDBase( ArchiveNodesList.Objects[SearchInd] );
      end;
      if CMVWTab = nil then begin
        CMVWTab := TN_UDBase( K_MVDarNewUserNodeAdd( K_msdWebTableWins,
          nil, CSFolder, DumpLine,
//          nil, ParseStack[ParLevelNum].SParent, DumpLine,
          BuildObjAliase( 'WEB таблица:', CFolderObjName, CFolderName ), CObjName ) );
        if ArchiveNodesList <> nil then
          ArchiveNodesList.AddObject(
            CMVWTab.ObjName+':'+N_ClassTagArray[K_UDMVWTableWinCI], CMVWTab );
      end;
      if (K_itfRebuildPublData in ImportTSFlags) or
         not (K_itfUseExistedData in ImportTSFlags) then begin
      //***    Set WebLDiagram Params
        CMVWTab.SelfSubTreeRemove; // Remove previous section if needed
        with TK_PMVWebTableWin(TK_UDRArray(CMVWTab).R.P)^ do begin
          ASWENType.T := K_gecWEParent;
          FullCapt := MacroExpand( GetVarValue( '#TableCaption' ), CFolderListCapt );
          BriefCapt := FullCapt;
        // Page Name
          Title := FullCapt;
        // WinID
          VWinName := GetVarValue( '#TableWinID' );
        // Not Mapping Table Elements CSS
          K_SetUDRefField( SCSS, NotMappingCSS );
        // Table Sidehead Caption
          SHCaption := GetVarValue( '#TabSideheadCaption' );
        // Skip ability to raise "change vector" event
          if K_itfSkipDataToMapBinding in ImportTSFlags then
            Include( ShowFlags.T, K_tsfSkipSelColCtrl );
        // Add New Diagram section
          CMVWTab.AddChildToSubTree( @CurDE );
        // Set Section elements Captions
          h := High(TabElemCapts);
          with TK_PMVWebSection(Sections.P)^ do begin
            Caption := FullCapt;
            for i := 0 to h do
              if TabElemCapts[i] <> '' then  PString(WECapts.P(i))^ := TabElemCapts[i];
          end;
        end;
      end;
    end;
//******************************
//*** end of  WebTable
//******************************
//******************************
//***    Build WebWinGroup - Theme
//******************************
    SkipObjFLag := GetVarValue( '#SkipWEB-Group' );
    if (SkipObjFLag = '') or (SkipObjFLag = '0') then
      CreateWinGroup;
    if CMVWinGroup <> nil then begin
      if (K_itfRebuildPublData in ImportTSFlags) or
         not (K_itfUseExistedData in ImportTSFlags) then begin
      //***    Set WebLDiagram Params
        with TK_PMVWebWinGroup(TK_UDRArray(CMVWinGroup).R.P)^ do begin
          GetSelfDirEnry( CMVWLDiagram, CurDE );
          CMVWinGroup.AddChildToSubTree( @CurDE );
        // Add Web Table To WinGroup
          GetSelfDirEnry( CMVWTab, CurDE );
          CMVWinGroup.AddChildToSubTree( @CurDE );
        // Add Cartogram Group To WinGroup
          if CMVWCartGroup <> nil then begin
            GetSelfDirEnry( CMVWCartGroup, CurDE );
            CMVWinGroup.AddChildToSubTree( @CurDE );
          end;
        // Add MS Word Document Additional Params
          AddMSWParsList := GetVarValue( '#AddMSWParsList' );
        end;
      end;
      //*** Add Start Theme To WebSite Objects
      if Length(CUDSightArr) > 0 then begin
        // Sight Page Name - Theme Page Name
        for i := High(CUDSightArr) downto 0 do begin
          with TK_PMVWebSite(TK_UDRArray(CUDSightArr[i]).R.P)^ do
            K_SetUDRefField( UDWWinObj, CMVWinGroup );
        end;
        CUDSightArr := nil;
      end;
    end;
//******************************
//*** end of WebWinGroup - Theme
//******************************
  end;

  function PrepareDIObjects : Boolean;
  var
    i : Integer;
    CSSAliase,CSSName,CSName : string;
    DataMapID : string;
  begin
//********************************
//***    Prepare Data Interface
//********************************
    Result := false;
  //*** Get DCSpace
    with K_CurSpacesRoot do begin
      DCSpace := nil;
      DataMapID := CClist.Values[ 'DataMapID' ];
      if DataMapID = '' then
        DataMapID := CClist.Values[ '#DataMapID' ];
      if DataMapID = '' then
        DataMapID := TabImportIni.ReadString('Common', '#DataMapID', '' );
      if DataMapID <> '' then
        CSName := TabImportIni.ReadString('DCSpaces', DataMapID, '' );
      if CSName = '' then
        CSName := TabImportIni.ReadString('Common', '#DCSpace', '' );
      if CSName = '' then
        Dump( 'ПРЕДУПРЕЖДЕНИЕ: не указано кодовое пространство')
      else begin
        DCSpace := TK_UDDCSpace( DirChildByObjName( CSName, K_ontObjUName ) );
        if DCSpace = nil then
          Dump( 'ПРЕДУПРЕЖДЕНИЕ: не найдено кодовое пространство "'+CSName+'"');
      end;
      if DCSpace = nil then begin
        DCSpace  := TK_UDDCSpace( DirChild(0) );
        if DCSpace <> nil then begin
          CSName := DCSpace.GetUName;
          Dump( 'ПРЕДУПРЕЖДЕНИЕ: выбрано кодовое пространство "'+CSName+'"');
        end;
      end;
      if DCSpace = nil then begin
        Dump( 'ОШИБКА: не найдено кодовое пространство -> загрузка прервана' );
        Exit;
      end;
      DCSLength := DCSpace.SelfCount;
    end;
    DCSSpace := nil;
    Dump( 'Выбрано кодовое пространство "'+DCSpace.GetUName+'"', K_msInfo );

  //*** Get Map Description
    if not (K_itfSkipDataToMapBinding in ImportTSFlags) then begin
      WStr1 := '';
      if DataMapID <> '' then
        WStr1 := TabImportIni.ReadString('Maps', DataMapID, '' );
      if WStr1 = '' then
        WStr1 := TabImportIni.ReadString('Common', '#MapDescription', '' );
      CMapDescr := K_GetMVDarSysFolder( K_msdMapDescrs ).DirChildByObjName( WStr1, K_ontObjUName );
      if (CMapDescr = nil) or not (CMapDescr is TK_UDMVMapDescr) then begin
        Dump( 'ОШИБКА: отсутствует описатель карты - "'+WStr1+'" -> загрузка прервана' );
        Exit;
      end;
      if TK_PMVMapDescr(TK_UDRArray(CMapDescr).R.P).UDMScreenComp = nil then begin
        Dump( 'ОШИБКА: отсутствует карта у описателя "'+WStr1+'" -> загрузка прервана' );
        Exit;
      end;
      MapDataAttribs := TK_UDVector(TK_PMVMLDColorFill(TK_UDRArray(CMapDescr.DirChild(0)).R.P).UDColors);
      if MapDataAttribs = nil then begin
        Dump( 'ОШИБКА: у карты отсутствует вектор атрибутов -> загрузка прервана' );
        Exit;
      end;
      Dump( 'Выбран описатель картограммы - "'+WStr1+'"', K_msInfo );
    end;

  //*** Parse Region Codes
    WInd := h + 1 - CRegStartN;
    SetLength( Regs, WInd);
    SetLength( RegColIndex, WInd );
    SetLength( RegICodes, WInd );
    LRegs := 0;

    for i := CRegStartN to h do begin
//      WLine := Trim( StrMatr[0][i] );
      WLine := Trim( StrMatr(0,i) );
      if (WLine <> '') and (WLine[1] = K_itsLevelComment) then continue;
      Val(WLine, jh, j);
      if j > 0 then break;
      RegColIndex[LRegs] := i;
      Regs[LRegs] := WLine;
      RegICodes[LRegs] := jh;
      Inc(LRegs);
    end;
    SetLength( RegColIndex, LRegs );
    SetLength( RegICodes, LRegs );
    SetLength( Regs, LRegs );

    for i := 0 to High(Regs) - 1 do begin
      CurInd := K_IndexOfStringInRArray( Regs[i], @Regs[i+1], High(Regs) - i );
      if CurInd <> - 1 then begin
        Dump( 'ОШИБКА: в'+WarnColName(3)+IntToStr( RegColIndex[i]+1 )+
              ' и '+IntToStr( RegColIndex[i+CurInd+1]+1 )+
              ' задан совпадающий код региона '+Regs[i]+' -> загрузка прервана' );
        Exit;
      end;
    end;

    if LRegs > DCSLength then begin
      Dump( 'ПРЕДУПРЕЖДЕНИЕ: количество регионов превышает количество элементов кодового пространства' );
  //    Exit;
    end;

    if LRegs = 0 then begin
      Dump( 'ОШИБКА: отсутствуют коды регионов в '+WarnRowName( 4 )+'1  -> загрузка прервана' );
      Exit;
    end;

  //*** Build DCSS
    SetLength( DProj, LRegs );
    with TK_PDCSpace(DCSpace.R.P).Codes do
      K_SCIndexFromSCodes( @DProj[0], @Regs[0], LRegs,
                    PString(P), DCSLength );
//                    PString(P), ALength );

//************************************************************************
//  United regions check
//
    with TK_PMVMapDescr(TK_UDRArray(CMapDescr).PDE(0))^ do
      if UDURegsCSS <> nil then begin
        URegsCount := TK_UDVector(UDURegsCSS).PDRA.ALength;
        RAURegs := K_RCreateByTypeCode( Ord(nptByte), URegsCount );

        SetLength( URegs1All, DCSLength );

      /////////////////////////////////////////////////
      // Build United Regions Vector by United Regions
      // -1 if region is absent in data
      //  0 if region is in data
      //
        SetLength( URegsU, URegsCount );

      // Set -1 to full space vector elements for United Regions
        URegM1 := -1;
        K_MoveVectorByDIndex( URegs1All[0], SizeOf(Integer),
                              URegM1, 0, SizeOf(Integer),
                              URegsCount, TK_UDVector(UDURegsCSS).DP );

      // Set 0 to full space vector elements for Data Vector Elements
        URegM1 := 0;
        K_MoveVectorByDIndex( URegs1All[0], SizeOf(Integer),
                              URegM1, 0, SizeOf(Integer),
                              LRegs, @DProj[0] );

      // Get elements from full space vector elements for United Regions Vector
        K_MoveVectorBySIndex( URegsU[0], SizeOf(Integer),
                              URegs1All[0], SizeOf(Integer), SizeOf(Integer),
                              URegsCount, TK_UDVector(UDURegsCSS).DP );
      //
      ////// end of Building United Regions Vector by United Regions


      /////////////////////////////////////////////////
      // Build United Regions Vector by Constituents Regions
      // -1 if Corresponding Constituent Region is absent in data
      //  1 if Corresponding Constituent Region is in data
      //
        SetLength( URegsC, URegsCount );
        // Set 1 to full space vector elements for United Regions Constituents
        URegM1 := 1;
        K_MoveVectorByDIndex( URegs1All[0], SizeOf(Integer),
                              URegM1, 0, SizeOf(Integer),
                              LRegs, @DProj[0] );
      // Set -1 to full space vector elements for United Regions
        URegM1 := -1;
        K_MoveVectorByDIndex( URegs1All[0], SizeOf(Integer),
                              URegM1, 0, SizeOf(Integer),
                              URegsCount, TK_UDVector(UDURegsCSS).DP );

      // Set -1 to full space vector elements for United Regions Constituents with same codes
        if UDURegsConstCSS <> nil then
          with TK_UDVector(UDURegsConstCSS) do
            K_MoveVectorByDIndex( URegs1All[0], SizeOf(Integer),
                                  URegM1, 0, SizeOf(Integer),
                                  PDRA.ALength, DP );
      // Copy elements in full space vector elements by United Regions to Constituents Projection
{
        with TK_UDVector(UDURegsProj) do
          K_MoveVectorByDIndex( URegs1All[0], SizeOf(Integer),
                                URegs1All[0], SizeOf(Integer), SizeOf(Integer),
                                PDRA.ALength, DP );
}
        with TK_UDVector(UDURegsProj) do
          for i := 0 to DCSLength - 1 do begin
            URegM1 := PInteger(DP(i))^;
            if (URegM1 >= 0) and
               (URegs1All[i] > URegs1All[URegM1]) then
              URegs1All[URegM1] := URegs1All[i];
          end;


      // Get elements from full space vector elements for United Regions Vector
        K_MoveVectorBySIndex( URegsC[0], SizeOf(Integer),
                              URegs1All[0], SizeOf(Integer), SizeOf(Integer),
                              URegsCount, TK_UDVector(UDURegsCSS).DP );
      //
      ////// end of Building United Regions Vector by Constituents Regions

      //////////////////////////////////////////////////////////////
      // Check data conflict United and Constituent Regions in Data
      //
        URegErrorStr := '';
        with TK_UDVector( DCSpace.GetAliasesDir.DirChild(0) ) do
        for i := 0 to URegsCount - 1 do begin
          URegM1 := 0;
          if (URegsU[i] = 0) then
            URegM1 := $F0 // F - to prevent change flag in dialog
          else if (URegsC[i] = 1) then
            URegM1 := $FF; // F - to prevent change flag in dialog
          PByte(RAURegs.P(i))^ := URegM1;

          if (URegsU[i] = 0) and (URegsC[i] = 1) then begin
            if URegErrorStr = '' then
              URegErrorStr := 'ОШИБКА: заданы и старые регионы, объединеные в новые'#13#10 +
              '                  регионы, и новые объединенные регионы:'#13#10;
            URegM1 := PInteger(TK_UDVector(UDURegsCSS).DP(i))^;
            URegErrorStr := URegErrorStr + '  ' + PString(DP(URegM1))^ + #13#10;
          end;
        end;
        if URegErrorStr <> '' then begin
          RAURegs.Free;
          Dump( URegErrorStr );
          Exit;
        end;
      //
      ////// end of data conflict сheck

      ///////////////////////////////////////////////////
      // Show Dialog with checkboxes for United Regions
      //
        with TK_FormMVTSImpUnRegs.Create( Application ) do begin
          PData := @RAURegs;
          ADType:= RAURegs.ArrayType;
          AFDTypeName := 'TK_MVUnRegsSetForm';

          SetLength( URegNames, URegsCount );
          with TK_UDVector( DCSpace.GetAliasesDir.DirChild(0) ) do
            for i := 0 to URegsCount - 1 do begin
              URegM1 := PInteger(TK_UDVector(UDURegsCSS).DP(i))^;
              URegNames[i] := PString(DP(URegM1))^
            end;

          FRAControl.PRowNames := @URegNames[0];

          ShowModal();
        end;
      //
      ///////////////////////////////////////////////////

      ///////////////////////////////////////////////////
      // Change Data CSS Constituent Regions to United Regions
      //
        if UDURegsConstCSS <> nil then begin
        // Set -1 to full space vector elements for United Regions
          URegM1 := -1;
          K_MoveVectorByDIndex( URegs1All[0], SizeOf(Integer),
                                URegM1, 0, SizeOf(Integer),
                                URegsCount, TK_UDVector(UDURegsCSS).DP );

        // Set Constituents CSIndexes to Corresponding United full space vector elements
          with TK_UDVector(UDURegsConstCSS).PDRA^ do
            for i := 0 to AHigh do begin
              URegM1 := PInteger(P(i))^;  // CRegIndex
              URegM2 := PInteger(TK_UDVector(UDURegsProj).DP(URegM1))^; // URegIndex
              URegs1All[URegM2] := URegM1;
            end;


        // Get elements from full space vector elements for United Regions Vector
          K_MoveVectorBySIndex( URegsC[0], SizeOf(Integer),
                                URegs1All[0], SizeOf(Integer), SizeOf(Integer),
                                URegsCount, TK_UDVector(UDURegsCSS).DP );

        // Copy Data CSS to full space vector elements
          K_MoveVectorByDIndex( URegs1All[0], SizeOf(Integer),
                                DProj[0], SizeOf(Integer), SizeOf(Integer),
                                LRegs, @DProj[0] );

          for i := 0 to URegsCount - 1 do begin
            if ((PByte(RAURegs.P(i))^ and $F) = 0) and (URegsC[i] >= 0) then begin
            //  Change Constituent Index to United Index in full space vector elements
              URegM1 := PInteger(TK_UDVector(UDURegsCSS).DP(i))^;
              URegs1All[URegsC[i]] := URegM1;
            end;
          end;

        // Back Copy Data CSS from full space vector elements
          K_MoveVectorBySIndex( DProj[0], SizeOf(Integer),
                                URegs1All[0], SizeOf(Integer), SizeOf(Integer),
                                LRegs, @DProj[0] );

        end;
      //
      ////// end of Data CSS Changing

      ///////////////////////////////////////////////////
      // Create Visible United Regions CSS Create
      //
        FillChar( URegs1All[0],  DCSLength * SizeOf(Integer), -1 );
        // Mark by (=0) to not Visible United Regions
        for i := 0 to URegsCount - 1 do begin
          if (PByte(RAURegs.P(i))^ and $F) <> 0 then begin
          //  Change Constituent Index to United Index in full space vector elements
            URegM1 := PInteger(TK_UDVector(UDURegsCSS).DP(i))^;
            URegs1All[URegM1] := 0;
          end;
        end;

      // Copy elements in full space vector elements by United Regions to Constituents Projection
        with TK_UDVector(UDURegsProj) do
          K_MoveVectorBySIndex( URegs1All[0], SizeOf(Integer),
                                URegs1All[0], SizeOf(Integer), SizeOf(Integer),
                                PDRA.ALength, DP );

        // Mark by (=0) to Visible United Regions
        for i := 0 to URegsCount - 1 do begin
          URegM1 := PInteger(TK_UDVector(UDURegsCSS).DP(i))^;

          URegM2 := 0;
          if (PByte(RAURegs.P(i))^ and $F) <> 0 then
          //  Change Constituent Index to United Index in full space vector elements
            URegM2 := -1;

          URegs1All[URegM1] := URegM2;
        end;

        SetLength( WIndexes, DCSLength );
        URegM1 := K_BuildActIndicesAndCompress( nil, @WIndexes[0], nil, @URegs1All[0], DCSLength );
        SetLength( WIndexes, URegM1 );
        URegVisCSS := nil;
        if not (K_itfSkipEQCSS in ImportTSFlags) then
          URegVisCSS := DCSpace.IndexOfCSS( @WIndexes[0], URegM1 );
        if URegVisCSS = nil then begin
        // Cretate New CSS with Visible United Regions
          CSSName := '***###???URV';
          CSSAliase := CSSName;
          URegVisCSS := DCSpace.CreateDCSSpace( CSSName, URegM1, '*' );
          if CSSAliase <> '' then begin // coorrect New CSS Name and ALiase
            URegVisCSS.PrepareObjName;
            if CSSAliase <> URegVisCSS.ObjName then
              with DCSpace.GetSSpacesDir do
                SetUniqChildName( URegVisCSS );
            URegVisCSS.ObjAliase := CSSAliase;
          end;
          Move( WIndexes[0], TK_UDDCSSpace(URegVisCSS).DP^, URegM1 * SizeOf(Integer) );
        end;

      //
      ////// end of Data CSS Changing
        RAURegs.Free;

      end;
//
//  end of united regions check
//************************************************************************

  //*** Search for compatible DCSS
    CSSName := CClist.Values[ '#DCSSpace' ];
    if CSSName = '' then
      CSSName := TabImportIni.ReadString( 'Common', '#DCSSpace', '' );
    ADCSSpace := nil;
    if CSSName <> '' then
      ADCSSpace := TK_UDDCSSpace(DCSpace.GetSSpacesDir.DirChildByObjName( CSSName, K_ontObjUName ));
    SetLength( DRIndexes, LRegs );
    if (ADCSSpace = nil) and not (K_itfSkipEQCSS in ImportTSFlags) then
      ADCSSpace := DCSpace.IndexOfCSS( @DProj[0], LRegs );
    if ADCSSpace = nil then begin // Cretate New DCSS
    // Create Sync Active Data DCSSpace
      CSSAliase := CSSName;
      if CSSName = '' then
        CSSName := '***###???';
      ADCSSpace := DCSpace.CreateDCSSpace( CSSName, LRegs, '*' );
      if CSSAliase <> '' then begin // coorrect New CSS Name and ALiase
        ADCSSpace.PrepareObjName;
        if CSSAliase <> ADCSSpace.ObjName then
          with DCSpace.GetSSpacesDir do
            SetUniqChildName( ADCSSpace );
        ADCSSpace.ObjAliase := CSSAliase;
      end;
      Move( DProj[0], ADCSSpace.DP^, LRegs * SizeOf(Integer) );
      K_FillIntArrayByCounter( @DRIndexes[0], Length(DRIndexes) );
//      for i := 0 to High(DRIndexes) do DRIndexes[i] := i;
    end else
      // Build Projection to specified CSS
      K_BuildCSSProjectionInds( @DRIndexes[0], @DProj[0], LRegs,
                    PInteger(ADCSSpace.DP), ADCSSpace.PDRA.ALength, DCSLength );

  //*** Search for Map Elements which have no Projection to Data Vector
    if not (K_itfSkipDataToMapBinding in ImportTSFlags) then begin
      MapDataProjName := '';
      if DataMapID <> '' then
        MapDataProjName := TabImportIni.ReadString('DataMapProjs', DataMapID, '' );
      if MapDataProjName = '' then
        MapDataProjName := TabImportIni.ReadString('Common', '#DataMapProj', '' );
      MDCSSpace := MapDataAttribs.GetDCSSpace;
      MapDataProj := K_DCSpaceProjectionGet( DCSpace, MDCSSpace.GetDCSpace,
                                          MapDataProjName );
      if (MapDataProjName <> '') and (MapDataProj = nil) then
      begin
        Dump( 'ОШИБКА: не удается построить проекцию данных на карту -> загрузка прервана' );
        Exit;
      end;
      jh := MapDataAttribs.PDRA.ALength;
      SetLength( WIndexes, jh );
      K_BuildDataProjectionByCSProj( ADCSSpace, MDCSSpace,
                    @WIndexes[0], MapDataProj );

    //
      LRegs := ADCSSpace.PDRA.ALength;
      SetLength( DProj, LRegs );
      FillChar( DProj[0], LRegs * SizeOf(Integer), $FF );
      WW2 := 0;
      SetLength( MEIndexes, Length(WIndexes) );
      for i := 0 to High(WIndexes) do
        if WIndexes[i] <> -1 then
        begin
          DProj[WIndexes[i]] := i;
          MEIndexes[WW2] := PInteger( ADCSSpace.DP( WIndexes[i] ) )^;
          Inc(WW2);
        end;

  //*** Create Data DCSSpace for Mapping Data Elements
      MappingCSS := DCSpace.IndexOfCSS( @MEIndexes[0], WW2 );
      if MappingCSS = nil then begin // Cretate New DCSS
        MappingCSS := DCSpace.CreateDCSSpace( '***###???ME', WW2, '*' );
        Move( MEIndexes[0], MappingCSS.DP^, WW2 * SizeOf(Integer) );
      end
      else if MappingCSS = ADCSSpace then // Clear Analyzing Elements CSS - it is equal to Data CSS
        MappingCSS := nil;

  //   SetLength(WIndexes, WW2);
      WW2 := 0;
      for i := 0 to High(DProj) do
        if DProj[i] = -1 then begin
          WIndexes[WW2] := PInteger( ADCSSpace.DP( i ) )^;
          Inc(WW2);
        end;

  //*** Create Data DCSSpace for not mapping Data Elements
      NotMappingCSS := DCSpace.IndexOfCSS( @WIndexes[0], WW2 );

      if NotMappingCSS = nil then begin // Cretate New DCSS
        NotMappingCSS := DCSpace.CreateDCSSpace( '***###???NME', WW2, '*' );
        Move( WIndexes[0], NotMappingCSS.DP^, WW2 * SizeOf(Integer) );
      end;
    end;

// Add DataData Projection by Name
{
    DataDataProjName := '';
    if DataMapID <> '' then
      DataDataProjName := TabImportIni.ReadString('DataDataProjs', DataMapID, '' );
    if DataDataProjName = '' then
      DataDataProjName := TabImportIni.ReadString('Common', '#DiagramDataProj', '' );
    DataDataProj := nil;
    if DataDataProjName <> '' then
      DataDataProj := K_DCSpaceProjectionGet( DCSpace, DCSpace,
                                      DataDataProjName );
}
    DataDataProjName := '';
    if DataMapID <> '' then
      DataDataProjName := TabImportIni.ReadString('DataDataProjs', DataMapID, '' );
    if DataDataProjName = '' then
      DataDataProjName := TabImportIni.ReadString('Common', '#DiagramDataProj', '' );
    DataDataProj := nil;
    if DataDataProjName <> '' then begin
      DataDataProj := DCSpace.SearchProjByCSS( ADCSSpace );
      if DataDataProj = nil then
        Dump( 'Не найдена проекция данных для диаграмм', K_msWarning );
    end;

//********************************
//*** end of Data Interface Preparation
//********************************
    Result := true;

  end;

  procedure PrepareSpecScale;
  var
    SpecName : string;
  begin
  //*** Prepare SpecValuesAttributes Reference
    UDRSVAttrs := nil;
    SpecName := TabImportIni.ReadString('Common', '#SpecValuesName', '' );
    if SpecName <> '' then
      UDRSVAttrs := K_GetMVDarSysFolder( K_msdSvalSets ).DirChildByObjName( SpecName, K_ontObjUName );
    if UDRSVAttrs = nil then
      UDRSVAttrs := K_CurArchSpecVals;
    RSVAttrs := TK_UDRArray(UDRSVAttrs).R;

  //*** Prepare SpecValues Src Texts List
    SVList := THashedStringList.Create;
    SpecName := TabImportIni.ReadString('Common', '#SpecValInfo', '' );
    SVList.DelimitedText := SpecName;

  //*** For Regions That are not Include in Data Vector
    AbsRegSInd := TabImportIni.ReadInteger('Common', '#AbsDataSpecInd', -1 );
    if AbsRegSInd = -1 then
      AbsRegSInd := TabImportIni.ReadInteger('Common', '#AbsRegSpecInd', -1 );
    if (AbsRegSInd < 0) or (AbsRegSInd > RSVAttrs.AHigh) then AbsRegSInd := Min( 1, RSVAttrs.AHigh );
  //***  For Data Vector Elements With Undefined Values
    UndefValSInd := TabImportIni.ReadInteger('Common', '#UndefValSpecInd', 2 );
    if (UndefValSInd < 0) or (UndefValSInd > RSVAttrs.AHigh) then UndefValSInd := Min( 2, RSVAttrs.AHigh );
  //***  For Data Vector Elements prepared by AverageDeviation Scale Builder
    StandardDeviationSInd := TabImportIni.ReadInteger('Common', '#StandardDeviationSpecInd', 3 );
    if (StandardDeviationSInd < 0) or (StandardDeviationSInd > RSVAttrs.AHigh) then StandardDeviationSInd := Min( 3, RSVAttrs.AHigh );


  end;

  procedure AddCIDoCLB;
  begin
    if K_itfSaveIDsList in ImportTSFlags then begin
      if CLBStr <> '' then  begin
        if K_itfVerticalData in ImportTSFlags then
          CLBStr := CLBStr + #9
        else
          CLBStr := CLBStr + #$D#$A;
      end;
      CLBStr := CLBStr + CLBID
    end;
  end;

  procedure BuildUniqCSSNames( ACSS : TN_UDBase; Suffix : string );
  begin
    ACSS.ObjAliase := CSFolder.ObjAliase+Suffix;
    ACSS.Owner.BuildUniqChildName( '', ACSS, K_ontObjAliase );
    ACSS.ObjName := '~CS' + CSSBaseName +Suffix;
    ACSS.Owner.BuildUniqChildName( '', ACSS, K_ontObjName );
  end;

  function ParseVectorValues( ALoadStringsFlag : Boolean ) : Boolean;
  var i2 : Integer;
  begin
    Result := TRUE;
    with PMVVector^ do
    begin
    //******************************
    //***  Set Vector Values and Attributes
    //******************************
      if PMVVector.CSS <> ADCSSpace then // Relink to New CSSpace
        ADCSSpace.LinkDVector( PMVVector );

      Units := VUnits;
      FullCapt := MacroExpand( GetVarValue( '#SCaption' ), CName );
      BriefCapt := MacroExpand( GetVarValue( '#MCaption' ), CName );

      if not ALoadStringsFlag then
      begin
      // Add Table Data for Main Vector (skip for Additional Dynamic Vector)
        LDElemCapts[CMVTabVCount] :=
          MacroExpand( GetVarValue( '#DCaption' ), BriefCapt );
        TabElemCapts[CMVTabVCount] :=
          MacroExpand( GetVarValue( '#TCaption' ), BriefCapt );
      end;

      WStr1 := GetVarValue( '#TimePeriodStart' );
      if WStr1 <> '' then
      begin
        TimePeriod.SDate := K_StrToDateTime( WStr1 );
        TimePeriod.PLength :=
          StrToIntDef(GetVarValue( '#TimePeriodLength' ), 1 );
        TimePeriod.IEnum :=
          StrToIntDef(GetVarValue( '#TimePeriodUnits' ), 0 );
      end; // if WStr1 <> '' then

        // Values
      DumpLine := '';
      WW2 := 0;
      for i2 := 0 to High(RegColIndex) do
      begin
        WStr1 := StrMatr(j, RegColIndex[i2]);
        WW1 := DRIndexes[i2];
        if WW1 < 0 then Continue;
//        PVV := TK_UDMVVector(CMVVector).DP(WW1);
        PVV := D.P(WW1);
        if ALoadStringsFlag then
          PString(PVV)^ := WStr1
        else
        begin
          Val( K_ReplaceCommaByPoint( WStr1 ), PVV^, WW1 );
          if WW1 > 0 then
          begin
            WW1 := SVList.IndexOfName( WStr1 );
            if WW1 >= 0 then
            begin // Special Value is found
              WW1 := StrToIntDef(SVList.ValueFromIndex[WW1], -1);
              if (WW1 < 0) or (WW1 > RSVAttrs.AHigh) then WW1 := UndefValSInd;
              PVV^ := TK_PMVDataSpecVal( RSVAttrs.P(WW1) )^.Value;
            end else
            begin
              Inc(WW2);
              PVV^ := TK_PMVDataSpecVal( RSVAttrs.P(UndefValSInd) )^.Value;
              if DumpLine <> '' then DumpLine := DumpLine + ',';
              DumpLine := DumpLine + IntToStr(RegColIndex[i2]+1);
            end; // if WW1 >= 0 then
          end; // if WW1 > 0 then
        end; // if ALoadStringsFlag then
      end; // for i := 0 to High(RegColIndex) do

      if (DumpLine <> '') then
      begin
      //*** Undefined Data Values
        if WW2 = Length(RegColIndex) then
        begin
          Dump( 'ОШИБКА: нарушена разметка - в ' + WarnRowName(4) + IntToStr(j+1)+
                ' отсутствуют данные, возможно здесь необходим структурный уровень L'+IntToStr(WLevelNum)+
                ' в'+WarnColName(4)+ K_itsNLevelType+
                ' -> загрузка прервана' );
//          Break;
          Result := TRUE;
          Exit;
        end;

        if WW2 = 1 then WW2 := 4 else WW2 := 3;
        DumpLine := 'ПРЕДУПРЕЖДЕНИЕ: возможна ошибка в'+WarnRowName(4)+IntToStr(j+1)+
            ' ('+K_itsNCaption+'="'+CName+'") -> неопределенное значение в' +
          WarnColName(WW2)+ DumpLine;
        if (MDR <> mrYesToAll) and
           not (K_itfIgnoreUndefWarning in ImportTSFlags) then
        begin

          MDR := MessageDlg( 'ИСТОЧНИК "'+ SourceName + '"'+#$D+#$A+DumpLine +'. '+
             #$D+#$A+#$D+#$A+'Ваши действия? (продолжить, прервать, продолжить до конца файла)',
                         mtConfirmation, [mbYes, mbAbort, mbYesToAll ], 0);
  //              if MDR = mrAbort then Exit;
          if MDR = mrAbort then
          begin
//            Break;
            Result := TRUE;
            Exit;
          end;
        end;

        if not (K_itfIgnoreUndefDump in ImportTSFlags) then
          Dump( DumpLine, K_msInfo );
      end; // if (DumpLine <> '') then
    //******************************
    //***  end of  Setting Vector Values and Attributes
    //******************************
    end; // with PMVVector^ do
  end;


begin

  ArchiveNodesList := nil;
  if K_itfSkipNotWEBObjs in ImportTSFlags then Include( ImportTSFlags, K_itfUseExistedData );
  if K_itfUseExistedData in ImportTSFlags then begin
    if (PNodesList = nil) or (PNodesList^ = nil) then begin
      ArchiveNodesList := THashedStringList.Create;
      with TK_ScanMVUDSubTree.Create do begin
        NodesSL := ArchiveNodesList;
        BuildNodeIDFlags := [K_bnfUseObjName,K_bnfUseObjType];
        MVUDSubTreeScan( K_CurUserRoot, BuildMVFoldersSubTreeChildsListFunc,
                         [K_udtsOwnerChildsOnlyScan] );
        Free;
      end;
{
      K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsOwnerChildsOnlyScan, K_udtsSkipListDupCheck];
      K_CurUserRoot.BuildSubTreeList( [K_bnfUseObjName,K_bnfUseObjType],
                                       ArchiveNodesList, K_IsMVdarUserFolder );
      K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsOwnerChildsOnlyScan, K_udtsSkipListDupCheck];
}
    end else
      ArchiveNodesList := PNodesList^;
  end;

  HDataDirection := not (K_itfVerticalData in ImportTSFlags);
  if K_itfRebuildVectors in ImportTSFlags then
    Include( ImportTSFlags, K_itfRebuildPublData );

  Result := false;
//*** Test Column Headers
//  h := High(StrMatr[0]);
  h := HighStrMatrCol;
  CClist := THashedStringList.Create;
  CRegStartN := 0;
  CMList := THashedStringList.Create;
  SetLength( CMnds, h + 1 );
  jh := 0;
  for i := 0 to h do begin
    WLine := StrMatr(0,i);
    if (Length(WLine) > 1) and (WLine[1] = '#') then begin
      if (WLine[2] <> '#') then // Current Macro Values
        CClist.AddObject( WLine, TObject(i) )
      else begin
        CMList.AddObject( Copy(WLine, 3, Length(WLine) ), TObject(i) );
        CMnds[jh] := i;
        Inc(jh);
      end;
    end else if (WLine = '') or (WLine[1] <> '*') then begin
      CRegStartN := i;
      break;
    end;
  end;
  SetLength( CMnds, jh );

  IColLevelType := CClist.IndexOf( K_itsNLevelType );
  if IColLevelType < 0 then begin
    Dump( 'ОШИБКА: отсутствует' + WarnColName(0) + K_itsNLevelType +' -> загрузка прервана' );
    Exit;
  end else
    IColLevelType := Integer(CClist.Objects[IColLevelType]);

  IColID := CClist.IndexOf( K_itsNID );
  if IColID >= 0 then
    IColID := Integer(CClist.Objects[IColID]);
  if (IColID < 0) and (ArchiveNodesList <> nil) then begin
    DumpLine := 'Отсутствует' + WarnColName(0) + K_itsNID + ' для реструктуризации';
    Dump( DumpLine, K_msInfo );
    if mrYes <> MessageDlg( 'ИСТОЧНИК "'+ SourceName + '"'+#$D+#$A+DumpLine + ' Продолжить?',
       mtConfirmation, [mbYes, mbNo], 0) then Exit;
  end;

  IColCaption := CClist.IndexOf( K_itsNCaption );
  if IColCaption >= 0 then
    IColCaption := Integer(CClist.Objects[IColCaption]);

  IColLCaption := CClist.IndexOf( K_itsNLCaption );
  if IColLCaption >= 0 then
    IColLCaption := Integer(CClist.Objects[IColLCaption]);

  if (IColCaption < 0) and (IColLCaption < 0) then begin
    Dump( 'ОШИБКА: отсутствуют' + WarnColName(2) + K_itsNCaption + ' и ' + K_itsNLCaption + ' -> загрузка прервана' );
    Exit;
  end;

  WList := TStringList.Create;
  // Search for #Set= Column Index
  IColSet := CClist.IndexOfName( K_itsNSet );
  if IColSet >= 0 then
    IColSet := Integer(CClist.Objects[IColSet]);
  if IColSet <> -1 then begin
  // #Set has Global Settings (#Set=) - Add Global Settings
    WList.CommaText := CClist.Values[K_itsNSet];
    CClist.AddStrings(WList);
  end else begin
  // Search for #Set Column Index
    IColSet := CClist.IndexOf( K_itsNSet );
    if IColSet >= 0 then
      IColSet := Integer(CClist.Objects[IColSet]);
  end;

  Result := true;

  URegVisCSS := nil;
  if (CRegStartN > 0) and (CRegStartN < h) then begin
    if not PrepareDIObjects then Exit;
    PrepareSpecScale;
  end;

//*********************************
//*** Start Structure Parsing Loop
//********************************
  CUDSightArr := nil;
  ParLevelNum := 0;
  WLevelNum := 0;
  CurInd := 0;
//  IndAddParams := nil;

  CVarsList := THashedStringList.Create;
  TabImportIni.ReadSectionValues('Common', CVarsList );
  CVarsSetList := THashedStringList.Create;
  InitCurVarsSetList;



  CSFolder := MVFolder;
  CFolder := MVWebFolder;
  CFolderName := '';
  CFolderLName := '';
  CMVWeights := nil;

  CMacroList := THashedStringList.Create;
  TabImportIni.ReadSectionValues('Macro', CMacroList );

  for i := CMList.Count - 1 downto 0 do
    CMacroList.Insert( 0, CMList[i]+'=' );

  with CMacroList do begin
    AddObject( K_itsMPrevList+'=.', nil );
    Add( K_itsMCaption+'= ' );
    Add( K_itsMLCaption+'= ' );
  end;
//  ICreated := false;
  FCreated := false;
  SFCreated := false;

  NextParseLevel();

  WLine := K_itsLevelFolder;
  jh := HighStrMatrRow;
  CType := #0;
  CLBStr := '';
  StartLevelStruct := true;
  MDR := mrOK;

  CMVTab := nil;
  CMVTabVCount := 0;

  CMVWCartGroup := nil;

  CMVWinGroup := nil;
  CMVWinGroupLevel := 0;

  // for Pasing Additinal Dynamic Vector
  PMVVAttrs := nil;
  CMVVector := nil;


  N_PBCaller.Start( jh );
  for j := 1 to jh do begin

    N_PBCaller.Update(j);

//*** Parse Current Level
    CType := WLine[1];
    CLBID := GetSCurCellValue( IColID );
    WLine := StrMatr(j,IColLevelType);
    if (StrMatr(j,0) = '')                  or
       (StrMatr(j,0)[1] = K_itsLevelComment)or
       (WLine = '')                         or
       (WLine[1] = K_itsLevelComment) then begin
      WLine := CType;
      AddCIDoCLB();
      Continue;
    end;

    CID := CLBID;
    StructLevelType := (WLine[1] = K_itsLevelFolder) or
                       (WLine[1] = K_itsLevelGroup)  or
                       (WLine[1] = K_itsLevelTable);

//*** Get Current SHort Name and Long Name
    CLName := GetSCurCellValue( IColLCaption );
    CName := GetSCurCellValue( IColCaption, CLName );
    if CLName = '' then CLName := CName;
    if CName = '' then CName := CLName;

    if WLine = K_itsLevelWeights then
    begin
    // Load Weights Data
      if CMVWinGroupLevel <> 0 then Continue; // Skip Weights
      WStr1 := CLBID;
      if WStr1 = '' then
        WStr1 := 'DataWeights';
      CMVWeights := ADCSSpace.CreateDVector( WStr1, Ord(nptDouble) );

      WStr1 := CName;
      if WStr1 = '' then
        WStr1 := 'Доли групп';
      CMVWeights.ObjAliase := WStr1;

      CFolder.AddOneChildV( CMVWeights );

      DumpLine := '';
      WW2 := 0;
      for i := 0 to High(RegColIndex) do
      begin
        WStr1 := StrMatr(j, RegColIndex[i]);
        WW1 := DRIndexes[i];
        if WW1 < 0 then Continue;
        PVV := TK_UDMVVector(CMVWeights).DP(WW1);
        Val( K_ReplaceCommaByPoint( WStr1 ), PVV^, WW1 );
        if WW1 > 0 then
        begin
          Inc(WW2);
          PVV^ := TK_PMVDataSpecVal( RSVAttrs.P(UndefValSInd) )^.Value;
          if DumpLine <> '' then DumpLine := DumpLine + ',';
          DumpLine := DumpLine + IntToStr(RegColIndex[i]+1);
        end;
      end;
      if (DumpLine <> '') then begin
      //*** Undefined Data Values
        if WW2 = Length(RegColIndex) then begin
          Dump( 'ОШИБКА: нарушена разметка - в ' + WarnRowName(4) + IntToStr(j+1)+
                ' -> загрузка прервана' );
          Break;
        end;

        if WW2 = 1 then WW2 := 4 else WW2 := 3;
        DumpLine := 'ПРЕДУПРЕЖДЕНИЕ: возможна ошибка в'+WarnRowName(4)+IntToStr(j+1)+
            ' ('+K_itsNCaption+'="'+CName+'") -> неопределенное значение в' +
          WarnColName(WW2)+ DumpLine;
        if (MDR <> mrYesToAll) and
           not (K_itfIgnoreUndefWarning in ImportTSFlags) then begin

          MDR := MessageDlg( 'ИСТОЧНИК "'+ SourceName + '"'+#$D+#$A+DumpLine +'. '+
             #$D+#$A+#$D+#$A+'Ваши действия? (продолжить, прервать, продолжить до конца файла)',
                         mtConfirmation, [mbYes, mbAbort, mbYesToAll ], 0);
//              if MDR = mrAbort then Exit;
          if MDR = mrAbort then Break;
        end;

        if not (K_itfIgnoreUndefDump in ImportTSFlags) then
          Dump( DumpLine, K_msInfo );
      end;
      Continue;
    end;

//*** Replace Current Macro Names
    with CMacroList do begin
      Strings[Count-2] := K_itsMCaption+'='+CName;
      Strings[Count-1] := K_itsMLCaption+'='+CLName;
    end;

//*** Replace Current Macro List
    for i := 0 to CMList.Count - 1 do
      CMacroList[i] := CMList[i]+'='+ GetSCurCellValue( Integer(CMList.Objects[i]), '' );


//*** Check for Old Format: Table Levele is Marked as Folder
    if (j < jh)                      and
       (WLine[1] = K_itsLevelFolder) then begin
      WStr1 := StrMatr(j+1,IColLevelType);
      if (WStr1 <> '') and
         (WStr1[1] = K_itsLevelData) then
        WLine[1] := K_itsLevelTable;
    end;

    if (WLine[1] <> K_itsLevelData) and
       (CType    =  K_itsLevelData) then
    begin
//*** End of Vectors Table
      if not (K_itfSkipWEBObjs in ImportTSFlags) then
        CreateTableGroupObjects
      else begin //??? Remove CSFolder if K_itfSkipWEBObjs in ImportTSFlags ???
        if (CSFolder <> nil) and
           (CSFolder.DirLength = 0)  then begin
          if ArchiveNodesList <> nil then
            SearchInd := ArchiveNodesList.IndexOf(
              CSFolder.ObjName+':'+N_ClassTagArray[K_UDMVFolderCI] )
          else
            SearchInd := -1;
          if SearchInd <> -1 then
            ArchiveNodesList.Delete( SearchInd );
          CSFolder.Owner.DeleteOneChild(CSFolder);
          CSFolder := nil;
        end;
      end;

      CMVTab := nil;
      CMVWTab := nil;
      CMVWLDiagram := nil;
      CMVWCartGroup := nil;
      CurInd := 0;


      if CMVWinGroupLevel = WLevelNum then
        CMVWinGroup := nil; // Clear Table WinGroup
//      Dec(WLevelNum,2);
//      FreeStackLevel();
//      Dec(ParLevelNum,2);
      Dec(WLevelNum,1);
      FreeStackLevel();
      Dec(ParLevelNum,1);
      with ParseStack[WLevelNum+1] do begin
        CSFolder := SParent;
       CFolder := WParent;
      end;

      // for Pasing Additinal Dynamic Vector
      PMVVAttrs := nil;
      CMVVector := nil;
    end;

    if WLine[1] <> K_itsLevelData then begin
//*** Calc Level Number
      if (WLine = K_itsLevelTable) and
         ((CType = K_itsLevelFolder) or (CType = K_itsLevelGroup)) then
        WLine := WLine + '+';
      if ((WLine = K_itsLevelFolder) or (WLine = K_itsLevelGroup)) and
         (CType = K_itsLevelTable) then
        WLine := WLine + '-';
      CWlineLength := Length(WLine);
      CLevelNum := 0;
      IncCLevelNum := true;
      if (CWlineLength >= 2) then begin
        CLevelNum := StrToIntDef( Copy( WLine, 2, CWlineLength ), CLevelNum );
        if (WLine[2] = '+') then
          CLevelNum := 1
        else if (WLine[2] = '-') then begin
          if CLevelNum = 0 then CLevelNum := -1
        end else
          IncCLevelNum := false;
      end;

      if IncCLevelNum then
        Inc(WLevelNum, CLevelNum)
      else
        WLevelNum := CLevelNum;

  //*** Check Level Number
      CLevelNum := ParLevelNum;
      if StructLevelType then
        Inc(CLevelNum);
      if ( WLevelNum < 0 )         or
         ( WLevelNum > CLevelNum )  then begin
        //*** Error in level
        Dump( 'ОШИБКА: нарушена разметка - номер уровня '+IntToStr(WLevelNum)+
              ' в'+WarnRowName(4)+IntToStr(j+1)+WarnColName(1)+ K_itsNLevelType+
              ', необходим номер уровня больше 0 и не больше '+IntToStr(CLevelNum)+
              ' -> загрузка прервана' );
//        Exit;
        Break;
      end;

      if StartLevelStruct and
         (WLevelNum <> 0) then begin
          Dump( 'ОШИБКА: нарушена разметка - отсутствует уровеь L0 в'+WarnRowName(4)+IntToStr(j+1)+
                      WarnColName(1)+ K_itsNLevelType+' -> загрузка прервана' );
//        Exit;
        Break;
      end;
      StartLevelStruct := false;

  //*** Clear CMVWinGroup
      if (CMVWinGroupLevel > WLevelNum) or
         ( (CMVWinGroupLevel = WLevelNum) and
           ( (WLine[1] = K_itsLevelFolder) or
             (WLine[1] = K_itsLevelGroup) ) ) then
        CMVWinGroup := nil;

      if StructLevelType then begin
      //*** Prepare Next Stack Level
        if (WLevelNum = ParLevelNum + 1) then
          NextParseLevel();

      //*** Clear Parse Stack and Level Macro Names
        FreeStackLevel();
{ //??  26.12.2007
        for i := ParLevelNum downto WLevelNum + 1 do begin
          with ParseStack[i] do begin
            FreeAndNil( VarsList );
            FreeAndNil( VarsSetList );
            FreeAndNil( NamesMacroList );
          end;
          with CMacroList do
            Objects[Count-3] := ParseStack[i-1].NamesMacroList;
        end;
}
      end;
      if WLevelNum + 1 <= ParLevelNum then
        with ParseStack[WLevelNum + 1] do begin
          CSFolder := SParent;
          CFolder := WParent;
        end;

    end else if CType = K_itsLevelTable then begin
      Inc(WLevelNum);
      NextParseLevel();
    end;

    InitCurVarsContext;

    if StructLevelType then begin
    //******************************
    //*** Prepare Current Structure Folder
    //******************************
      CSFolder := nil;
      if CID = '' then begin
        with ParseStack[WLevelNum] do begin
          if K_itfSkipNotWEBObjs in ImportTSFlags then
            CID := WParent.ObjName
          else
            CID := SParent.ObjName;
          SearchInd := 1;
          if CID[1] = K_MVDARSysObjNames[Ord(K_msdFolder)][1] then
            Inc( SearchInd, Length(K_MVDARSysObjNames[Ord(K_msdFolder)]) );
          CID := Copy( CID, SearchInd, Length(CID) )+'_(0)';
        end;
        CLBID := CID;
      end else if ArchiveNodesList <> nil then begin
          SearchInd := ArchiveNodesList.IndexOf(
            K_MVDARSysObjNames[Ord(K_msdFolder)]+CID+':'+N_ClassTagArray[K_UDMVFolderCI] );
          if SearchInd <> -1 then begin
            CSFolder := TN_UDBase( ArchiveNodesList.Objects[SearchInd] );
            SFCreated := false;
            with ParseStack[WLevelNum] do
              if SWasCreated then
                SParent.AddOneChildV(CSFolder)
          end;
      end;

      if (CSFolder = nil) and not (K_itfSkipNotWEBObjs in ImportTSFlags) then begin
      //******************************
      //***  Create Data Structure Folder
      //******************************
        CSFolder := K_MVDarNewUserNodeAdd( K_msdFolder, nil,
          ParseStack[WLevelNum].SParent, DumpLine,
          BuildObjAliase( '', '', CName ),
          K_MVDARSysObjNames[Ord(K_msdFolder)]+CID );
          if K_itfAddIDtoObjAliase in ImportTSFlags then begin
            CSFolder.ObjAliase := BuildObjAliase( '',
              Copy( CSFolder.ObjName,
                  Length(K_MVDARSysObjNames[Ord(K_msdFolder)])+1,
                  Length(CSFolder.ObjName) ), CName );
            CSFolder.RebuildVNodes(1);
          end;
        with CSFolder do
          CFolderObjName := Copy( ObjName,
                     Length(K_MVDARSysObjNames[Ord(K_msdFolder)]) + 1,
                     Length(ObjName) );
        CLBID := CFolderObjName;
        SFCreated := true;
        if ArchiveNodesList <> nil then
          ArchiveNodesList.AddObject(
            CSFolder.ObjName+':'+N_ClassTagArray[K_UDMVFolderCI], CSFolder );
      //******************************
      //***  end of Data Structure Creation
      //******************************
      end else
        CFolderObjName := CID;
      CFolderName := CName;
      CFolderLName := CLName;
    //*** Prepare Folder Attributes
      CFolderListCapt := MacroExpand( GetVarValue( '#SCaption' ), CFolderLName );
      CFolderMenuCapt := MacroExpand( GetVarValue( '#MCaption' ), CFolderName );
    //******************************
    //*** end of Preparing Current Structure Folder
    //******************************
    end;

    if WLine[1] = K_itsLevelFolder then begin
    //******************************
    //*** Prepare Current WEB Folder
    //******************************
      CFolder := nil;
//      if NextStructLevelType then begin
//*** Create WEB Folder for previous level
      if not (K_itfSkipWEBObjs in ImportTSFlags) then begin
        if ArchiveNodesList <> nil then begin
          SearchInd := ArchiveNodesList.IndexOf(
                              CFolderObjName+':'+N_ClassTagArray[K_UDMVWFolderCI] );
          if (SearchInd <> -1) and
             (CFolder <> TN_UDBase(ArchiveNodesList.Objects[SearchInd])) then begin
            CFolder := TN_UDBase(ArchiveNodesList.Objects[SearchInd]);
            FCreated := false;
            with TK_PMVWebFolder(TK_UDMVWFolder(CFolder).R.P)^ do begin
              CFolderListCapt := FullCapt;
              CFolderMenuCapt := BriefCapt;
            end;
            with ParseStack[WLevelNum] do
              if WasCreated then
                WParent.AddOneChildV(CFolder);
          end;
        end;

        if CFolder = nil then begin
        //******************************
        //***      Create WEB Folder
        //******************************
          CFolder := K_MVDarNewUserNodeAdd( K_msdWebFolder, nil,
            ParseStack[WLevelNum].WParent, DumpLine,
            BuildObjAliase( 'WEB папка:', CFolderObjName, CFolderName ),
            CFolderObjName );

          FCreated := true;
          with TK_PMVWebFolder(TK_UDMVWFolder(CFolder).R.P)^ do begin
            FullCapt := CFolderListCapt;
            BriefCapt := CFolderMenuCapt;
          end;
          if ArchiveNodesList <> nil then
            ArchiveNodesList.AddObject(
              CFolder.ObjName+':'+N_ClassTagArray[K_UDMVWFolderCI], CFolder );
        //******************************
        //***  end of WEB Folder Creation
        //******************************
        end;

       // Create Folder Publication
        WEBPath := GetVarValue( '#Publicate', false );
        if WEBPath = '' then
          WEBPath := GetVarValue( '#PublWEB', false );
        DocPath := GetVarValue( '#PublDOC', false );
        if (WEBPath <> '') or (DocPath <> '') then begin
          CMVWVTreeWin := nil;
          if ArchiveNodesList <> nil then begin
            SearchInd := ArchiveNodesList.IndexOf(
                 K_MVDARSysObjNames[Ord(K_msdWebVTreeWins)]+
                 CFolderObjName+':'+N_ClassTagArray[K_UDMVWVTreeWinCI] );
            if SearchInd <> -1 then
              CMVWVTreeWin := TN_UDBase( ArchiveNodesList.Objects[SearchInd] );
          end;

          if CMVWVTreeWin = nil then begin
          //******************************
          //*** Create Web VTree Win
          //******************************
            CMVWVTreeWin := TN_UDBase( K_MVDarNewUserNodeAdd( K_msdWebVTreeWins,
                 nil, nil, DumpLine,
                BuildObjAliase( 'WEB структура:', CFolderObjName, CFolderName ),
                K_MVDARSysObjNames[Ord(K_msdWebVTreeWins)]+CFolderObjName ) );

            if ArchiveNodesList <> nil then
              ArchiveNodesList.AddObject(
                CMVWVTreeWin.ObjName+':'+N_ClassTagArray[K_UDMVWVTreeWinCI], CMVWVTreeWin );

            GetSelfDirEnry( CFolder, CurDE );
            CMVWVTreeWin.AddChildToSubTree( @CurDE );
            with TK_PMVWebVTreeWin(TK_UDRArray(CMVWVTreeWin).R.P)^ do begin
              Title := FullCapt;
              VWinName :=  GetVarValue( '#VTreeWinID' );
              WStr2 := GetVarValue( '#WinLayout', false );
              if WStr2 <> '' then
                K_SetUDRefField( UDWLayout, K_UDCursorGetObj(WStr2) );
              if UDWLayout = nil then
                K_SetUDRefField( UDWLayout, K_GetMVDarSysFolder( K_msdWinDescrs ).DirChild(0) );
              if (UDWLayout = nil) or not (UDWLayout is TK_UDMVVWLayout) then begin// Wrong Layout Type - Clear Field
                UDWLayout := nil;
                Dump( 'ПРЕДУПРЕЖДЕНИЕ: Не определена раскладка окон для объекта "'+
                   CMVWVTreeWin.GetUName+'"', K_msWarning );
              end;
            end;
          //******************************
          //*** end of Web VTree Win Creation
          //******************************
          end;
          CUDSight := nil;
          if ArchiveNodesList <> nil then begin
            SearchInd := ArchiveNodesList.IndexOf(
              K_MVDARSysObjNames[Ord(K_msdWebSite)]+CFolderObjName+':'+N_ClassTagArray[K_UDMVWSiteCI] );
            if SearchInd <> -1 then
              CUDSight := TN_UDBase( ArchiveNodesList.Objects[SearchInd] );
          end;

          if CUDSight = nil then begin
          //******************************
          //*** Create Web Sight from Web Folder
          //******************************
            CUDSight := TN_UDBase( K_MVDarNewUserNodeAdd( K_msdWebSite,
              nil, MVFolder, DumpLine,
//                'Публикация: '+CFolderName, K_MVDARSysObjNames[Ord(K_msdWebSite)]+CFolderObjName ) );
              BuildObjAliase( 'Публикация:', CFolderObjName, CFolderName ),
              K_MVDARSysObjNames[Ord(K_msdWebSite)]+CFolderObjName ) );
            if ArchiveNodesList <> nil then
              ArchiveNodesList.AddObject(
                CUDSight.ObjName+':'+N_ClassTagArray[K_UDMVWSiteCI], CUDSight );

            with TK_PMVWebSite(TK_UDRArray(CUDSight).R.P)^ do begin
              Title := CFolderListCapt;
              VWinName :=  GetVarValue( '#VTreeWinID' );
              K_SetUDRefField( UDWLayout,
                TK_PMVWebVTreeWin(TK_UDRArray(CMVWVTreeWin).R.P)^.UDWLayout );
              RRootPath := WEBPath;
              ResDocFName := DocPath;
            end;
            CurDE.Child := CMVWVTreeWin;
            CUDSight.AddChildToSubTree( @CurDE );

            SetLength( CUDSightArr, Length(CUDSightArr) + 1 );
            CUDSightArr[High(CUDSightArr)] := CUDSight;
          //******************************
          //*** end of Web Sight Creation
          //******************************
          end;
        end;
//          Inc(WLevelNum);
      end;
//      end;

   //******************************
   //*** end of Preparing Current Structure Folder
   //******************************
    end else if WLine[1] = K_itsLevelGroup then begin
   //******************************
   //*** Prepare Current WEB Group
   //******************************
      if CMVWinGroup <> nil then begin
        Dump( 'ОШИБКА: нарушена разметка - объявление группы внутри группы в'+WarnRowName(4)+IntToStr(j+1)+WarnColName(1)+ K_itsNLevelType+
              ' -> загрузка прервана' );
//        Exit;
        Break;
      end;
      if SearchWinGroup then Continue;
      CreateWinGroup;
   //******************************
   //*** end of Preparing Current WEB Group
   //******************************
    end else if WLine[1] = K_itsLevelTable then begin
   //******************************
   //*** Prepare Current Vectors Table
   //******************************
      if SearchWinGroup then Continue;
      if CMVTab = nil then
        CMVTab := GetGroupObj( CFolderObjName,
                    'Таблица:'+CSFolder.ObjAliase, K_msdBTables, K_UDMVTableCI );

      TK_UDMVTable(CMVTab).Init(ADCSSpace);
      CMVTabVCount := 0;

    //******************************
    //***    Build WebCartGroup
    //******************************
      CMVWCartGroup := nil;
      SkipObjFLag := GetVarValue( '#SkipWEB-Cartograms' );
      if ((SkipObjFLag = '') or (SkipObjFLag = '0')) and
          not (K_itfSkipDataToMapBinding in ImportTSFlags) then begin
    //*** Prepare Group Cartogram for Cartograms
        CMVWCartGroup := GetGroupObj( CFolderObjName,
                      'Группа WEB картограмм:'+CSFolder.ObjAliase, K_msdWebCartGroupWins, K_UDMVWCartGroupWinCI );

        TK_PMVWebCartGroupWin(TK_UDRArray(CMVWCartGroup).R.P).VWinName :=
          GetVarValue( '#MapGroupWinID' );
        if K_itfRebuildPublData in ImportTSFlags then
          CMVWCartGroup.SelfSubTreeRemove; // Remove previous Group Elements if needed
      end;
    //******************************
    //*** end of  WebCartGroup
    //******************************

  //******************************
  //*** end of Preparing Current Vectors Table
  //******************************
    end else if (WLine[1] = K_itsLevelData) and (CSFolder <> nil) then begin
  //******************************
  //***  Data Vector Parsing
  //******************************
      if (CMVTabVCount = 0) and (CType <> K_itsLevelTable) then begin
          //*** Error in Data Structure
        Dump( 'ОШИБКА: нарушена разметка: "'+CType+'" в'+WarnRowName(4)+IntToStr(j+1)+
                    WarnColName(1)+ K_itsNLevelType+' -> загрузка прервана' );
//        Exit;
        Break;
      end;

      if (Length(WLine) > 1) and (WLine[2] = K_itsLevelData) then
      begin
      //////////////////////////////////
      // Additinal Dynamic Vector Data
      //
        if (CMVVector = nil) or (PMVVAttrs = nil) then begin
            //*** Error in Data Structure
          Dump( 'ОШИБКА: нарушена разметка: "'+CType+'" в'+WarnRowName(4)+IntToStr(j+1)+
                      WarnColName(1)+ K_itsNLevelType+ #13#10 +
                'Дополнительный вектор данных должен следовать за основным -> загрузка прервана' );
  //        Exit;
          Break;
        end;
        with PMVVAttrs^ do
        begin
          AddLHDataVector := K_RCreateByTypeName( 'TK_MVVector', 1 );
          PMVVector := TK_PMVVector(AddLHDataVector.P);
          PMVVector.D := K_RCreateByTypeCode (Ord(nptString), TK_UDMVVector(CMVVector).PDRA.ALength(), []);
          if not ParseVectorValues( TRUE ) then Break;
        end;
        goto ContLevelLoop;
      //
      // end of Additinal Dynamic Vector Data
      //////////////////////////////////
      end;

      ICreated := false;
      CMVVector := nil;
      if CID = '' then begin
        CID := Copy( CSFolder.ObjName,
                     Length(K_MVDARSysObjNames[Ord(K_msdFolder)]) + 1,
                     Length(CSFolder.ObjName) )+'_('+IntToStr(CMVTabVCount)+')';
//                     Length(CSFolder.ObjName) )+'_(0)';
        CLBID := CID;
      end else if ArchiveNodesList <> nil then begin
        SearchInd := ArchiveNodesList.IndexOf(
          CID+':'+N_ClassTagArray[K_UDMVVectorCI] );
        if SearchInd <> -1 then
          CMVVector := TN_UDBase( ArchiveNodesList.Objects[SearchInd] );
      end;

  //*** Set Correct DCSS Aliases
      if (ADCSSpace <> nil) and (ADCSSpace.ObjAliase = '*') then begin
        CSSBaseName := Copy( CSFolder.ObjName,
                     Length(K_MVDARSysObjNames[Ord(K_msdFolder)]) + 1,
                     Length(CSFolder.ObjName) );
        BuildUniqCSSNames( ADCSSpace, '' );
        if (NotMappingCSS <> nil) and (NotMappingCSS.ObjAliase = '*') then
          BuildUniqCSSNames( NotMappingCSS, 'NME' );
      end;

      if (CMVVector = nil) and
         not (K_itfSkipNotWEBObjs in ImportTSFlags) then
      begin
      //*** Create Vector in table
        ICreated := true;
        CurInd := TK_UDMVTable(CMVTab).CreateColumn( CName, CID );
        TK_UDMVTable(CMVTab).GetSubTreeChildDE( CurInd, CurVDE );
        CMVVector := CurVDE.Child;
        if ArchiveNodesList <> nil then
          ArchiveNodesList.AddObject(
            CLBID+':'+N_ClassTagArray[K_UDMVVectorCI], CMVVector );
      end else
      begin
        CurInd := TK_UDMVTable(CMVTab).IndexOfUDVector(CMVVector);
        if CurInd = -1 then
        begin
          with CMVVector.Owner.Owner do
            GetDirEntry( IndexOfDEField(CMVVector), CurVDE );
          TK_UDMVTable(CMVTab).AddChildToSubTree( @CurVDE );
          CurInd := TK_UDMVTable(CMVTab).GetSubTreeChildHigh;
        end else
          TK_UDMVTable(CMVTab).GetSubTreeChildDE( CurInd, CurVDE );
      end;

      VUnits := GetVarValue( '#Units' );
      if VUnits <> '' then //*** Add Units to Macro List
        CMacroList.Add( 'Units='+VUnits );

      SetLength(TabElemCapts, CMVTabVCount + 1);
      SetLength(LDElemCapts, CMVTabVCount + 1);

      PMVVAttrs := nil; // for skip warning in Delpi 2010
      if ICreated                               or
         (K_itfRebuildVectors in ImportTSFlags) or
         not (K_itfUseExistedData in ImportTSFlags) then
      begin

        PMVVector := TK_PMVVector(TK_UDMVVector(CMVVector).R.P);
        if not ParseVectorValues( FALSE ) then Break;

        // Такой способ получения на всякий случай - здесь достаточно было бы TK_UDMVTable(CMVTab).GetAttribs
        PMVVAttrs := TK_PMVVAttrs(TK_UDMVTable(CurVDE.Parent.Owner).GetUDAttribs(CurInd).R.P);
        with PMVVAttrs^ do
        begin
        //******************************
        //***  Set View Attributes
        //******************************
          ValueType.T := K_vdtContinuous;
          AutoRangeCapts.T := K_aumAuto;
          AutoRangeVals.T := K_aumAuto;
          AutoMinMax.T := K_aumAuto;

         // Spec Values
          K_SetUDRefField( UDSVAttrs, UDRSVAttrs );

         // Visible United Regions CSS
          K_SetUDRefField( UDURegVisCSS, URegVisCSS );

         // Abs Elem Spec Values
          AbsDCSESVIndex := AbsRegSInd;

         // Values format
          VFormat := GetVarValue( '#ValuesFormat' );

         // Values Precision
          WStr1 := GetVarValue( '#ValuesPrecision' );
          if WStr1 <> '' then
            Val( WStr1, VDPPos, WW1 );

         //*** Main Scale Attribs
         // Main Scale Limits Format
          RFormat := GetVarValue( '#ScaleLimitsFormat' );

         // Main Scale Limits Precision
          WStr1 := GetVarValue( '#ScalePrecision' );
          if WStr1 <> '' then
            Val( WStr1, RDPPos, WW1 );


         // Main Scale Precision
          PureValPatType.T := K_vttAuto;
          WStr1 := GetVarValue( '#ValuesVectorPatType' );
          if WStr1 <> '' then
            Val( WStr1, PureValPatType.R, WW1 );
          PureValToTextPat := GetVarValue( '#ValuesVectorPat' );


          NamedValPatType.T := K_vttAuto;
          WStr1 := GetVarValue( '#NamedValuesVectorPatType' );
          if WStr1 <> '' then
            Val( WStr1, NamedValPatType.R, WW1 );
          NamedValToTextPat := GetVarValue( '#NamedValuesVectorPat' );

           // Main Auto Scale Type
          WStr1 := GetVarValue( '#AutoScaleType' );
          WW1 := Ord(K_artOptimal);
          if WStr1 <> '' then
            WW1 := StrToIntDef(WStr1, WW1 );

          if WW1 = -1 then
            ValueType.T := K_vdtDiscrete;

          if (WW1 < Ord(K_artEqualNElems)) and (WW1 > Ord(K_artStdDev123)) then
            WW1 := Ord(K_artOptimal);

          AutoRangeType.R := WW1;

          if ValueType.T = K_vdtContinuous then
          begin
            WStr1 := GetVarValue( '#ScaleLength' );
            RangeCount := StrToIntDef(WStr1, 5 );
          end;
          // Main Scale Values
          WStr1 := GetVarValue( '#ScaleValues' );
          if WStr1 <> '' then
          begin
            WList.Delimiter := ';';
            WList.DelimitedText := WStr1;
            WW1 := 0;
            RangeValues.ASetLength( WList.Count );
            PVV := PDouble(RangeValues.P);
            for i := 0 to WList.Count - 1 do
            begin
              Val( K_ReplaceCommaByPoint( WList.Strings[i] ), PVV^, WW2);
              if WW2 > 0 then break;
              Inc(WW1);
              Inc(PVV);
            end;
            RangeValues.ASetLength( WW1 );
            AutoRangeVals.T := K_aumManual;
          end;

          // Main Auto Format
          AutoCaptsFormat.ASetLength(3);
          WStr1 := GetVarValue( '#AutoFormat1' );
          if WStr1 <> '' then
            PString(AutoCaptsFormat.P(0))^ := WStr1;
          WStr1 := GetVarValue( '#AutoFormat2' );
          if WStr1 <> '' then
            PString(AutoCaptsFormat.P(1))^ := WStr1;
          WStr1 := GetVarValue( '#AutoFormat3' );
          if WStr1 <> '' then
            PString(AutoCaptsFormat.P(2))^ := WStr1;

          WW1 := RangeValues.ALength;
          if (WW1 > 0) then
          begin
            if (ValueType.T = K_vdtContinuous) then Inc(WW1);
            RangeCaptions.ASetLength( WW1 );
          end;

          // Main Scale Texts
          WStr1 := GetVarValue( '#ScaleTexts' );
          if WStr1 <> '' then
          begin
            WList.CommaText := WStr1;
            WW1 := RangeCaptions.ALength;
            if WW1 = 0 then
              RangeCaptions.ASetLength(WList.Count);
            WW1 := Min( WList.Count - 1, RangeCaptions.AHigh );
            for i := 0 to WW1 do
              PString(RangeCaptions.P(i))^ := WList[i];
            AutoRangeCapts.T := K_aumManual;
            if ValueType.T = K_vdtDiscrete then
            begin
              NamedValPatType.T := K_vttNameRange;
              PureValPatType.T := K_vttNameRange;
            end;
          end;

          // Main Scale Colors
          WUD := K_GetMVDarSysFolder( K_msdColorPaths );
          WStr1 := GetVarValue( '#ScaleColors' );
          if WStr1 <> '' then
            K_InitMVVAttrsColorsSet( PMVVAttrs, WStr1, WUD,
                TabImportIni.ReadString( 'ColorSets', WStr1, '' ), WList );
          WStr1 := GetVarValue( '#ScaleColors1' );
          if WStr1 <> '' then
            K_InitMVVAttrsColorsSet( PMVVAttrs, WStr1, WUD,
                TabImportIni.ReadString( 'ColorSets', WStr1, '' ), WList );

          WStr1 := GetVarValue( '#UseColorsType' );
          if WStr1 <> '' then
            BuildColorsType.R := StrToIntDef(WStr1, 0 );

          WStr1 := GetVarValue( '#ColorsOrder' );
          ColorsSetOrder.T := K_cotDirect;
          if (WStr1 <> '') and (WStr1 <> '0') then
            ColorsSetOrder.T := K_cotIndirect;

          // Main Scale to Dimensionless Value convertion
          // Wrk Zone Min
          WStr1 := GetVarValue( '#VMin' );
          WW2 := 0;
          if WStr1 <> '' then
          begin
            Val( K_ReplaceCommaByPoint( WStr1 ), VMin, WW1 );
            if WW1 = 0 then
            begin
              VMax := K_MVMinVal;
              Inc(WW2);
            end;
          end;

          // Wrk Zone Max
          WStr1 := GetVarValue( '#VMax' );
          if WStr1 <> '' then
          begin
            Val( K_ReplaceCommaByPoint( WStr1 ), VMax, WW1 );
            if WW1 = 0 then
            begin
              if WW2 = 0 then VMin := K_MVMinVal;
              Inc(WW2);
            end;
          end;
          if WW2 >= 1 then // #VMin or #VMax are defined
            AutoMinMax.T := K_aumManual;

          WStr1 := GetVarValue( '#DBasePoint' );
          WW1 := 1;
          if WStr1 <> '' then
            Val( WStr1, VBase, WW1 );
          if WW1 <> 0 then VBase := VMin; // VBase is not defined

          WStr1 := GetVarValue( '#SkipLHistSvalMode' );
          WW1 := 1;
          if WStr1 <> '' then
            Val( WStr1, LHShowFlags.R, WW1 );
          if WW1 <> 0 then LHShowFlags.R := 1; // LinHist Show Flags are not defined

          WStr1 := GetVarValue( '#DICoeffs' );
          if WStr1 <> '' then
          begin
            WList.Delimiter := ';';
            WList.DelimitedText := WStr1;
            if VDConv = nil then
              VDConv := K_RCreateByTypeCode( Ord(nptDouble), WList.Count * 2 )
            else
              VDConv.ASetLength(WList.Count * 2);
            WW2 := 0;
            for i := 0 to WList.Count - 1 do
            begin
              Val( K_ReplaceCommaByPoint( WList.Names[i] ), PDouble(VDConv.P(WW2))^, WW1 );
              Val( K_ReplaceCommaByPoint( WList.ValueFromIndex[i] ), PDouble(VDConv.P(WW2+1))^, WW1 );
              Inc( WW2, 2);
            end;
          end;

         // Set Elements Captions
          with ADCSSpace.GetDCSpace.GetAliasesDir do
          begin
            WUD1 := nil;
            WStr1 := GetVarValue( '#ElemCapts' );
            if WStr1 <> '' then
              WUD1 := DirChildByObjName( WStr1, K_ontObjUName );
            if WUD1 = nil then WUD1 := DirChild(0);
            K_SetUDRefField( ElemCapts, WUD1 );
          end;

         // Diagram Axis Attributes
          AxisTickUnits := PMVVector^.Units;

         // Rebuild Vector Attributes
          K_SetUDRefField( ElemCapts, WUD1 );

         // Set Vector Mapping Elements SubSet
          K_SetUDRefField( AutoRangeCSS, MappingCSS );

         // Set Vector Weights Vector
          K_SetUDRefField( AutoRangeWData, CMVWeights );

//          K_RebuildMVAttribs( PMVVAttrs^, PMVVector^.D );
          if (ValueType.T = K_vdtContinuous) and
             (AutoRangeVals.T = K_aumAuto)   and
             (AutoRangeType.T = K_artStdDev123) then
          begin

            PureValsInds := nil; // warning precaution
            PureValsCount := PMVVector.D.ALength;
            PPureValsVals := PDouble(PMVVector.D.P);
            PPureValsInds := nil;
            if (AutoRangeCSS <> nil) then
            begin
              // Build
              PureValsCount := TK_UDDCSSpace(AutoRangeCSS).PDRA.ALength;
              SetLength( PureValsInds, PureValsCount );
              if K_BuildDataProjectionByCSProj( TK_UDDCSSpace(PMVVector.CSS),
                                                TK_UDDCSSpace(AutoRangeCSS),
                                                @PureValsInds[0], nil ) then
              begin
                PPureValsInds := @PureValsInds[0];
                SetLength(PureValsArr, PureValsCount);
                K_MoveVectorBySIndex( PureValsArr[0], SizeOf(Double),
                             PPureValsVals^, SizeOf(Double), SizeOf(Double),
                             PureValsCount, @PureValsInds[0] );
                PPureValsVals := @PureValsArr[0];
              end;
            end;

            RangeValsArr := K_BuildStandardDeviationRanges( PPureValsVals,
                                         PureValsCount, RDPPos,
                                         TK_PMVDataSpecVal(TK_UDRArray(UDSVAttrs).R.P(StandardDeviationSInd)).Value );
            if PureValsInds <> nil then
              K_MoveVectorByDIndex( PMVVector.D.P^, SizeOf(Double),
                             PPureValsVals^, SizeOf(Double), SizeOf(Double),
                             PureValsCount, @PureValsInds[0] );

//          RangeValsArr := K_BuildStandardDeviationRanges( PDouble(PMVVector.D.P),
//                                       PMVVector.D.ALength, RDPPos,
//                                       TK_PMVDataSpecVal(TK_UDRArray(UDSVAttrs).R.P(StandardDeviationSInd)).Value );

            AutoRangeVals.T := K_aumManual;
            RangeValues.ASetLength( 4 );
            Move( RangeValsArr[0], RangeValues.P()^, 4 * SizeOf(Double) );
          end;

          K_RebuildMVAttribs( PMVVAttrs^, PMVVector );

         // Try to Set Discrete Values Captions
          if ValueType.T = K_vdtDiscrete then
          begin
            WStr1 := GetVarValue( '#ScaleDTexts' );
            if WStr1 <> '' then
            begin
              WList.CommaText := WStr1;
              WW1 := RangeCaptions.ALength;
              if WW1 = 0 then
                RangeCaptions.ASetLength(WList.Count);
              WW1 := Min( WList.Count - 1, RangeCaptions.AHigh );
              for i := 0 to WW1 do
                PString(RangeCaptions.P(i))^ := WList.Values[PString(RangeCaptions.P(i))^];
              NamedValPatType.T := K_vttNameRange;
              PureValPatType.T := K_vttNameRange;
            end;
          end;
        //******************************
        //***  end of Setting View Attributes
        //******************************
        end; // with PMVVAttrs^ do begin
      end;
      Inc(CMVTabVCount);

      if (CMVWCartGroup <> nil)                  and
         not (K_itfSkipWEBObjs in ImportTSFlags) and
         not (K_itfSkipDataToMapBinding in ImportTSFlags) then begin
        //******************************
        //***  Set Vector Cartogram
        //******************************
        CMVWCart := nil;
        if ArchiveNodesList <> nil then begin
          SearchInd := ArchiveNodesList.IndexOf(
            CLBID+'WC:'+N_ClassTagArray[K_UDMVWCartWinCI] );
          if SearchInd <> -1 then
            CMVWCart := TN_UDBase( ArchiveNodesList.Objects[SearchInd] );
        end;

        if CMVWCart = nil then begin
        //*** Create WCart
          CMVWCart := TN_UDBase( K_MVDarNewUserNodeAdd( K_msdWebCartWins,
              nil, nil, DumpLine,
              BuildObjAliase( 'WC:', CID, CName ), CID+'WC', CMapDescr ) );
          if ArchiveNodesList <> nil then
            ArchiveNodesList.AddObject(
              CLBID+'WC:'+N_ClassTagArray[K_UDMVWCartWinCI], CMVWCart );
          // Add to CartogramGroup
          CurDE.Child := CMVWCart;
        end else
          CurDE.Child := nil; // not add to CartogramGroup flag

        // Set Cartogram Attributes
        CMVWCart.AddChildToSubTree( @CurVDE );

        // Input Values and correct attribs
        with TK_PMVWebCartWin(TK_UDMVWCartWin(CMVWCart).R.P)^ do begin
          VWinName := GetVarValue( '#MapWinID' );
          PageCaption := MacroExpand( GetVarValue( '#PCaption' ), PageCaption );
        end;

        // Set Cartogram Layer Attributes
        with TK_PMVCLCommon(TK_UDRArray(CMVWCart.DirChild(0)).R.P)^ do begin
            // Map Projection
          K_SetUDRefField( DCSP, MapDataProj );

            // Legend Header
          LegHeader := MacroExpand( GetVarValue( '#LegendHeader' ), LegHeader );

            // Legend Footer
          WStr1 := GetVarValue( '#LegFooterDataCode' );
          if (WStr1 <> '') and (WStr1 <> LegFooterRegCode)then begin
            LegFooterRegCode := WStr1;
            LegFooterRegCSSInd := DCSpace.IndexByCode(WStr1);
            LegFooterRegInd := ADCSSpace.IndexByCode(WStr1);
          end;
          if WStr1 <> '' then begin
            K_BuildMVVElemsVAttribs( TK_UDMVVector(CMVVector).DP(LegFooterRegInd), 1,
                  PMVVAttrs, @LegFooterRegCSSInd, @WStr2, nil, nil, nil, nil, VUnits );
            with CMacroList do Add( 'LegFooterDataVal=' + WStr2 );
          end;
          LegFooter := MacroExpand( GetVarValue( '#LegendFooter' ), LegFooter );
          if WStr1 <> '' then
            with CMacroList do Delete( Count - 1 );

           // Legend Columns Count
          WStr1 := GetVarValue( '#LegColCount' );
          if WStr1 <> '' then
             Val( WStr1, LEColNum, WW1 );
           // Legend Rows Count
          WStr1 := GetVarValue( '#LegRowCount' );
          if WStr1 <> '' then
             Val( WStr1, LERowNum, WW1 );
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
    end else if ( (WLine[1] = K_itsLevelVHTM) or
                  (WLine[1] = K_itsLevelHTM) )  and
                (CSFolder <> nil) then begin
  //******************************
  //***  HTM level Parsing
  //******************************
      InitCurVarsContext;
      UDHTMCI := K_UDMVWVHTMWinCI;
      HTMSysTypeOrd := Ord(K_msdWebVHTMRefWins);
      if WLine[1] = K_itsLevelHTM then begin
        UDHTMCI := K_UDMVWHTMWinCI;
        HTMSysTypeOrd := Ord(K_msdWebHTMRefWins);
      end;
{
      WStr1 := '';
      if (Length(WLine) >= 2) then begin
        case WLine[2] of
          ' ' : begin // K_msdWebVHTMRefWins
            WStr1 := Copy(WLine, 3, Length(WLine) );
          end;
          '1' : begin // K_msdWebHTMRefWins
            WStr1 := Copy(WLine, 4, Length(WLine) );
            UDHTMCI := K_UDMVWHTMWinCI;
            HTMSysTypeOrd := Ord(K_msdWebHTMRefWins);
          end;
          'T' : // K_msdWebVHTMWins
            HTMSysTypeOrd := Ord(K_msdWebVHTMWins);
        end;
      end;
}
      CMVHTM := nil;
      if CID = '' then begin
        CID := Copy( CSFolder.ObjName,
                     Length(K_MVDARSysObjNames[Ord(K_msdFolder)]) + 1,
                     Length(CSFolder.ObjName) )+'_(0)';
        CLBID := CID;
      end else if ArchiveNodesList <> nil then begin
        SearchInd := ArchiveNodesList.IndexOf(
          CID+':'+N_ClassTagArray[UDHTMCI] );
        if SearchInd <> -1 then
          CMVHTM := TN_UDBase( ArchiveNodesList.Objects[SearchInd] );
      end;

      ICreated := false;
      if (CMVHTM = nil)                             and
         not (K_itfSkipNotWEBObjs in ImportTSFlags) then begin
      //******************************
      //***    Create HPrompt
      //******************************
        ICreated := true;
//        WW1 := ParLevelNum - 1; ??? 26.12.2007
//        WW1 := WLevelNum;       ??? 26.12.2007

        CMVHTM := TN_UDBase( K_MVDarNewUserNodeAdd( TK_MVDARSysType(HTMSysTypeOrd),
            nil, CSFolder, DumpLine,
//            CName, CID ) );
            BuildObjAliase( '', CID, CName ), CID ) );
        if not StartLevelStruct then
        CLBID := CMVHTM.ObjName;
        if ArchiveNodesList <> nil then
          ArchiveNodesList.AddObject(
            CLBID+':'+N_ClassTagArray[UDHTMCI], CMVHTM );
      //******************************
      //***   end of Create HPrompt
      //******************************
      end;

      if ICreated                               or
         (K_itfRebuildVectors in ImportTSFlags) or
         not (K_itfUseExistedData in ImportTSFlags) then begin

        PHTMPars := TK_UDRArray(CMVHTM).R.P;
//        if WStr1 = '' then
          WStr1 := GetVarValue( '#HTMPath' );
        if HTMSysTypeOrd = Ord(K_msdWebHTMRefWins) then
          with TK_PMVWebHTMRefWin(PHTMPars)^ do begin
            // File Name
            if WStr1 = '' then
              Dump( 'ПРЕДУПРЕЖДЕНИЕ: не задано имя файла в'+WarnRowName(4)+IntToStr(j+1) );
            RHTMPath := WStr1;
          end
        else if (CMVHTM is TK_UDVector) then begin
          // Set vector values
          PHTMPars := @TK_PMVWebVHTMWin(PHTMPars).FullCapt;
          if ICreated then begin
            with TK_PDVector(TK_UDVector(CMVHTM).R.P)^ do
              D := K_RCreateByTypeCode (Ord(nptString));
            ADCSSpace.LinkDVector( TK_UDVector(CMVHTM).R.P );
            WW1 := 0;
            for i := 0 to High(RegColIndex) do begin
              WStr2 := StrMatr(j, RegColIndex[i]);
              PString(TK_UDVector(CMVHTM).DP(i))^ := WStr1+WStr2;
              if WStr2 = '' then Inc(WW1);
            end;
            if WW1 = Length(RegColIndex) then
              Dump( 'ПРЕДУПРЕЖДЕНИЕ: не заданы параметры HTML-документа в'+
                    WarnRowName(4)+IntToStr(j+1) );
          end;
        end;

        with TK_PMVWebWinObj(PHTMPars)^ do begin
          FullCapt := MacroExpand( GetVarValue( '#SCaption' ), FullCapt );
          BriefCapt := MacroExpand( GetVarValue( '#MCaption' ), FullCapt );
//          BriefCapt := FullCapt;
          Title := FullCapt;
          VWinName := GetVarValue( '#HTMWinID' );
        end;
      end;

      if CMVWinGroup <> nil then begin
        GetSelfDirEnry( CMVHTM, CurDE );
        CMVWinGroup.AddChildToSubTree( @CurDE );
      end;
  //******************************
  //***  end of HTM level Parsing
  //******************************
    end else if (CSFolder <> nil) then
    begin
      Dump( 'ОШИБКА: нарушена разметка - в '+WarnRowName(4)+ IntToStr(j+1)+ WarnColName(1)+K_itsNLevelType+' "'+WLine+'" -> загрузка прервана');
//      Exit;
      Break;
    end;

ContLevelLoop:
    ParLevelNum := WLevelNum;

    AddCIDoCLB;

  end; //*** end of for loop StrMat analisys


  if K_itfSaveIDsList in ImportTSFlags then
    Clipboard.AsText := CLBStr;

  if (CType = K_itsLevelData) or
     (WLine[1] = K_itsLevelData) then begin
    if not (K_itfSkipWEBObjs in ImportTSFlags) then
      CreateTableGroupObjects
    else begin // Remove CSFolder
      if (CSFolder <> nil) and
         (CSFolder.DirLength = 0)  then begin
        CSFolder.Owner.DeleteOneChild(CSFolder);
      end;
    end;
  end;

  for i := 0 to ParLevelNum do
    with ParseStack[i] do begin
      FreeAndNil( VarsList );
      FreeAndNil( VarsSetList );
      FreeAndNil( NamesMacroList );
    end;

//  IndAddParams := nil;
  ParseStack   := nil;
  CUDSightArr := nil;
  Regs := nil;
  RegColIndex := nil;
  DProj := nil;
  WIndexes := nil;
  RegICodes := nil;

  if PNodesList = nil then
    ArchiveNodesList.Free
  else if PNodesList^ = nil then
    PNodesList^ := ArchiveNodesList;

  CVarsList.Free;
  CVarsSetList.Free;
  CMacroList.Free;
  WList.Free;
  CClist.Free;
  CMlist.Free;
  SVList.Free;
  if (URegVisCSS <> nil) and (URegVisCSS.RefCounter = 0) then
    URegVisCSS.UDDelete();


  N_PBCaller.Finish();

end; // end of function  K_MVImportTabStruct0

end.
