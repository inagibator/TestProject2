unit K_UDC;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  IniFiles, SysUtils, classes,
  K_UDconst, K_CLib0, K_UDT1, K_VFunc, K_STBuf, K_SBuf,
  N_Lib2, N_Types;

//##path K_Delphi\SF\K_clib\K_UDC.pas\TK_UDTypeNameError
type TK_UDTypeNameError = class(Exception);

//##path K_Delphi\SF\K_clib\K_UDC.pas\TK_VTreeInfo
//************************************************************ TK_VTreeInfo ***
// IDB Visual Tree state info
//
// Used for runtime saving/restoring all application IDB visual representations
//
type TK_VTreeInfo = record
  VTree : TN_VTree;           // Visual Tree which state was saved and must be 
                              // restored
  RootPath : string;          // path to IDB Subnet root object
  MarkedList  : TStringList;  // marked Visual Nodes paths list
  ExpandedList : TStringList; // expanded Visual Nodes paths list
end;
type TK_VTIArray = array of TK_VTreeInfo;


procedure K_CompileIniSPLFiles( AForceRecompileFlag : Boolean = false );
procedure K_SaveCompiledIniSPLFiles;
procedure K_GetCommandLineParams;
function  K_RunCMDScript( AScriptName : string; AShowDump : Boolean = false ) : Boolean;
function  K_LoadMemIniFromFile( var AMemIniFile : TMemIniFile; const AFName : string ) : Boolean;
procedure K_SaveMemIniToFile( AMemIniFile : TMemIniFile );
procedure K_ClearAppTmpFiles( AForceDirFlags : Boolean = FALSE;
                              ADelFlags : TK_DelFolderFilesFlags = [K_dffRecurseSubfolders,K_dffRemoveReadOnly];
                              const AFext : string = '*.*' );
function  K_TreeIniGlobals( ARootType : Integer = -1 ) : Boolean;
procedure K_TreeFinGlobals;
procedure K_TreeViewsUpdateModeSet;
procedure K_TreeViewsUpdateModeClear( AUseUpdateCounter : Boolean = true);
procedure K_TreeViewsInvalidate();
procedure K_TreeViewsRebuild();
procedure K_TreeViewsInfoGet( var ATI : TK_VTIArray );
procedure K_TreeViewsInfoRestore( const ATI : TK_VTIArray );
procedure K_TreeViewsInfoFree( var ATI : TK_VTIArray );
procedure K_SaveTreeToMem( ARootUObj : TN_UDBase; ASBuf : TN_SerialBuf;
                           AOnlyChilds : Boolean = false;
                           ASaveFlags : TK_UDTreeLSFlagSet = [K_lsfSkipAllSLSR] );
procedure K_LoadTreeFromMem0( var ARootUObj : TN_UDBase; ASBuf : TN_SerialBuf;
                             AOnlyChilds : Boolean = false;
                             ALoadFlags : TK_UDTreeLSFlagSet = [K_lsfSkipAllSLSR] );
function  K_LoadTreeFromMem( ASBuf : TN_SerialBuf; ALoadFlags : TK_UDTreeLSFlagSet =
                                              [K_lsfSkipAllSLSR] ) : TN_UDBase;
procedure K_SaveTreeToText( ARootUObj : TN_UDBase; ASBuf : TK_SerialTextBuf;
                            AOnlyChilds : Boolean = false;
                            ASaveFlags : TK_UDTreeLSFlagSet = [K_lsfSkipAllSLSR] );
procedure K_ParseXMLFromTextBuf( ARootUObj : TN_UDBase );
procedure K_ParseXMLFromFile( ARootUObj : TN_UDBase; AFileName: string );
procedure K_LoadTreeFromText0(  var ARootUObj : TN_UDBase; ASBuf : TK_SerialTextBuf;
                                   AOnlyChilds : Boolean = false;
                                   ALoadFlags : TK_UDTreeLSFlagSet = [K_lsfSkipAllSLSR] );
function  K_LoadTreeFromText( ASBuf : TK_SerialTextBuf;
                              ALoadFlags : TK_UDTreeLSFlagSet = [K_lsfSkipAllSLSR] ) : TN_UDBase;
procedure K_SaveFieldsToText( AUObj : TN_UDBase; ASBuf : TK_SerialTextBuf );
procedure K_LoadFieldsFromText( AUObj : TN_UDBase; ASBuf : TK_SerialTextBuf );
//##/*
procedure K_InitClassRefList;
//##*/
function  K_GetUObjCIByTagName( ATagName : string; AStopFlag : Boolean = true ) : Integer;
function  K_GetUObjCIByTagNameExt( ATagName : string; ASBuf : TK_SerialTextBuf ) : Integer;
function  K_GetUObjTagName( AUObj : TN_UDBase ) : string;
procedure K_DumpUDFilesStruct( const AFileName : string; AUDFile : TN_UDBase = nil );
//function  K_CheckFileNameExt( FileName : string; ExtList : TStringList;
//                                        DefaultIndex : Integer = -1 ) : Integer;


var
//  K_DefaultTreeMerge : TK_TreeMerge;
  K_CMDParams : TStringList;
  K_AppInfoList : TStringList;  // Application Info List
  K_LoadUDTreeErrorMessage : string;

var
  K_SPLDataCurFVer : Integer = 20071229; // Data Current Version
  K_SPLDataPDNTVer : Integer = 20071010; // Data Minimal Version for Forward  CurApplication/PrevData Compatibility
  K_SPLDataNDPTVer : Integer;            // Data Minimal Version for Backward PrevApplication/CurArchive Compatibility


const
  K_SPLBinModeFlagsAllDef      = 'K_sbmSkipFileLoad,K_sbmSkipFileSave,K_sbmSaveSPLSrc,K_sbmRecompileSPLSrc';

//##path K_Delphi\SF\K_clib\K_UDC.pas\TK_SPLBinModeFlags
type TK_SPLBinModeFlags = set of (K_sbmSkipFileLoad,K_sbmSkipFileSave,K_sbmSaveSPLSrc,K_sbmRecompileSPLSrc);
type TK_SPLBinModeIFlags = record
  case Integer of
  0 : (S : TK_SPLBinModeFlags;);
  1 : (I : Integer;);
end;
var
  K_SPLBinModeFlags : TK_SPLBinModeIFlags;

var
  K_CurLangData     : TN_MemTextFragms;
  K_CurLangTStrings : TStrings;

var
  K_IniFileCreateParams : TK_DFCreateParams;

implementation

uses Windows, Controls, Dialogs, Forms, StrUtils, Math,
     N_Lib0, N_Lib1, N_PBase, N_PWin, N_ClassRef,
     K_Script1, K_UDT2, K_SParse1,
     K_CLib, K_IWatch, K_Arch;

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_CompileIniSPLFiles
//**************************************************** K_CompileIniSPLFiles ***
// Compile SPL source files given in application ini-file
//
//     Parameters
// AForceRecompileFlag - controls source SPL files recompilation
//
// Is called during application global initialization. If 
// AForceRecompileFlag=TRUE, then unconditional recompilation of all source 
// files will be done. Else source SPL file will be compiled only if it is new 
// then compiled SPL resource file
//
procedure K_CompileIniSPLFiles( AForceRecompileFlag : Boolean = false );
var
  i, j : Integer;
  SectionList : TStringList;
  EFName, FName : string;
  UDFD, UDU : TN_UDBase;
  CompiledLoad : Boolean;
  AllowRecompileFlag : Boolean;
  UnitCompileResult : Integer;
  Ind : Integer;
  SavedCodePage: Integer;
begin
  SavedCodePage := N_NeededCodePage;
  N_NeededCodePage := 1251; // there are many rus chars in our SPL code!

  FName := N_CurMemIni.ReadString('Global', 'SPLBinFile', '' );
  CompiledLoad :=
    not AForceRecompileFlag and
    (FName <> '')           and
    not (K_sbmSkipFileLoad in K_SPLBinModeFlags.S);
  AForceRecompileFlag := AForceRecompileFlag or
            (K_sbmRecompileSPLSrc in K_SPLBinModeFlags.S);
  if CompiledLoad then
  begin
//*** Load Compiled SPL Units
    EFName := K_ExpandFileName( FName );
    CompiledLoad := K_VFileExists( EFName );

    if CompiledLoad then
    begin
      K_SPLRootObj.LoadTreeFromFile( EFName );
      K_UDCursorGet(K_udpLocalPathCursorName).SetRoot( K_SPLRootObj );
      //*** Resolved ProgramItems ByteCode UDReferences
      for i := 0 to K_PIURefCount - 1 do
        TN_PUDBase(K_PIURefPointers[i])^ := K_UDCursorGetObj( K_PIURefPaths[i] );
      K_PIURefPointers := nil;
      K_PIURefPaths := nil;
      K_PIURefCount := 0;
    end; // if CompiledLoad then

    //*** Build Global Defined Types List
    for i := 0 to K_SPLRootObj.DirHigh do
    begin
      UDU := K_SPLRootObj.DirChild( i );
      with UDU do
        for j := 0 to DirHigh - 2 do
        begin
          UDFD := DirChild(j);
          if (UDFD.CI = K_UDFieldsDescrCI) and (UDFD.Owner = UDU) then
          begin
            Ind := K_TypeDescrsList.IndexOf( UDFD.ObjName );
            if Ind = -1 then
              K_TypeDescrsList.AddObject( UDFD.ObjName, UDFD )  // Add to global descriptions list
            else
              K_TypeDescrsList.Objects[Ind] := UDFD;            // Replace Existing
          end; // if (UDFD.CI = K_UDFieldsDescrCI) and (UDFD.Owner = UDU) then
        end; // for j := 0 to DirHigh - 2 do
      UDU := TK_UDUnit(UDU).GetGlobalData;
      if UDU <> nil then TK_UDRArray(UDU).SPLInit; // Init Global Data
    end; // for i := 0 to K_SPLRootObj.DirHigh do
  end; // if CompiledLoad then

  AllowRecompileFlag := AForceRecompileFlag or CompiledLoad;

  SectionList := TStringList.Create;
  N_CurMemIni.ReadSectionValues('SPLSrcFiles',SectionList);
  for i := 0 to SectionList.Count - 1 do
  begin
    FName := SectionList.ValueFromIndex[i];
    EFName := K_ExpandFileName( FName );
    j := K_SPLRootObj.IndexOfChildObjName( EFName, K_ontObjAliase );
    if j = -1 then
      UDU := nil
    else
    begin
      UDU := K_SPLRootObj.DirChild( j );
      if AForceRecompileFlag then
        UDU.ObjDateTime := 0;
    end;
    UnitCompileResult := K_CompileScriptFile( EFName, TK_UDUnit(UDU), AllowRecompileFlag, false );
    case UnitCompileResult of
      -1 : K_ShowMessage( 'File '+FName+' -> '+EFName+' is absent.' );
       0 : K_ShowMessage( 'File '+FName+' -> '+EFName+' compile errors.' );
       1 : AForceRecompileFlag := true;  // Was Realy Recompile -> Set ForceRecompileMode
    end;
  end; // for i := 0 to SectionList.Count - 1 do

  if not CompiledLoad and (SectionList.Count = 0) then
    raise Exception.Create( 'SPL files are not specified' );

  SectionList.Free;
  N_NeededCodePage := SavedCodePage; // restore Code Page
end; // end of procedure K_CompileIniSPLFiles

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_SaveCompiledIniSPLFiles
//*********************************************** K_SaveCompiledIniSPLFiles ***
// Save compiled SPL source files given in application ini-file
//
// Usually used during application global finalization.
//
procedure K_SaveCompiledIniSPLFiles;
var
  FName : string;
  SavedCodePage: Integer;
begin
  FName := N_CurMemIni.ReadString('Global', 'SPLBinFile', '' );
  if (FName <> '')                                            and
     ((K_SPLRootObj.ClassFlags and K_ChangedSubTreeBit) <> 0) and
     not (K_sbmSkipFileSave in K_SPLBinModeFlags.S) then begin

    if not (K_sbmSaveSPLSrc in K_SPLBinModeFlags.S) then
      Include( K_UDGControlFlags, K_gcfSkipUDUnitSrcBinData );

    Include( K_UDGControlFlags, K_gcfSaveUDUnitCompileData );

    FName := K_ExpandFileName( FName );
    K_ForceFilePath( FName );

    SavedCodePage := N_NeededCodePage;
    N_NeededCodePage := 1251; // there are many rus chars in our SPL code!
    K_SPLRootObj.SaveTreeToFile( FName );
    N_NeededCodePage := SavedCodePage; // restore Code Page

    Exclude( K_UDGControlFlags, K_gcfSaveUDUnitCompileData );

    Exclude( K_UDGControlFlags, K_gcfSkipUDUnitSrcBinData );
  end;

end; // end of K_SaveCompiledIniSPLFiles

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_GetCommandLineParams
//************************************************** K_GetCommandLineParams ***
// Get application command line parameters
//
// Get command line parameters <Name>=<Value> to application runtime parameters 
// list for future use during application execution. Application runtime 
// parameters list is build both by application command line and ini-file.
//
procedure K_GetCommandLineParams();
var
 i : Integer;
begin
  if K_CMDParams <> nil then Exit;
  K_CMDParams := TStringList.Create;
  K_CMDParams.CaseSensitive := false;
  for i := 1 to ParamCount do
    K_CMDParams.Add(ParamStr(i));
end; // end of procedure K_GetCommandLineParams

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_RunCMDScript
//********************************************************** K_RunCMDScript ***
// Run SPL file script
//
//     Parameters
// AScriptName - script name contanes SPL file name and procedure name 
//               <FileName>|<ProcName>
// Result      - Returns TRUE if file was successfully comliled and given 
//               procedure was done without runtime errors
//
// If any errors are detected then error info is written to application dump 
// file. If AScriptName doesn't contain procedure name then last copmpiled unit 
// procedure  will be selected for exectution.
//
function  K_RunCMDScript( AScriptName : string; AShowDump : Boolean = false ) : Boolean;
var
  ScriptFileName : string;
  ScriptFuncName : string;
  Mes : string;
begin
  ScriptFileName := AScriptName;
  Result := false;
  if ScriptFileName <> '' then
  begin
//    K_TreeIniGlobals;
    ScriptFuncName := ExtractFileExt(ScriptFileName);
//    if AnsiStartsText( '.spl', ScriptFuncName ) and
    if K_StrStartsWith( '.spl', ScriptFuncName, true ) and
      (Length(ScriptFuncName) > 5) then
    begin
      ScriptFuncName := Copy( ScriptFuncName, 6, Length(ScriptFuncName) );
      ScriptFileName := ChangeFileExt( ScriptFileName, '.spl' );
    end
    else
      ScriptFuncName := '';
    Mes := AScriptName;
    case K_RunScript( K_ExpandFileName(ScriptFileName), ScriptFuncName, AShowDump ) of
     0: Mes := 'File '+Mes+' not found';
    -1: Mes := 'Compile ' + Mes + ' errors';
    -2: Mes := 'Script '+ScriptFuncName+' not found';
    -3: Mes := 'Runtime error in '+ ScriptFuncName;
    else
      Mes := '';
      Result := true;
    end;
    if not Result then
      K_InfoWatch.AddInfoLine( Mes );
  end;
end; //*** end of function K_RunCMDScript

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_LoadMemIniFromFile
//**************************************************** K_LoadMemIniFromFile ***
// Load MemoryIniFile state from given Data File
//
//     Parameters
// AMemIniFile - MemoryIniFile (pascal TMemIniFile object), (if not assigned on 
//               input, then is created)
// AFName      - Data file name, whch contains IniFile strings reperesentation
// Result      - Returns TRUE if given Data file is successfully read.
//
function K_LoadMemIniFromFile( var AMemIniFile : TMemIniFile; const AFName : string ) : Boolean;
var
  SL : TStringList;
begin
  if AMemIniFile = nil then
    AMemIniFile := TMemIniFile.Create( '' );
  SL := TStringList.Create;
//  Result := K_LoadStringsFromDFile( SL, AFName, @K_IniFileCreateParams );
  Result := K_VFLoadStrings( SL, AFName, @K_IniFileCreateParams );
  if Result then
  begin
    AMemIniFile.SetStrings( SL );
    AMemIniFile.Rename( AFName, false );
  end;
  SL.Free;

end; //*** end of K_LoadMemIniFromFile

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_SaveMemIniToFile
//****************************************************** K_SaveMemIniToFile ***
// Save MemoryIniFile state to Data File
//
//     Parameters
// AMemIniFile - MemoryIniFile (pascal TMemIniFile object)
//
// Used for saving application ini-file. Use Alt/Ctrl/Shift keys state for
// changing file current contetnts type. If left Alt/Ctrl/Shift keys are down
// then file encryption will be done. If right Alt/Ctrl/Shift keys are down then
// file contenets will be plane text. Else file current contetnts type doesn't
// change.
//
procedure K_SaveMemIniToFile( AMemIniFile : TMemIniFile );
var
  WSL : TStringList;

  function CanBeUpdate( FName : string ) : Boolean;
  var
    VFile: TK_VFile;
  begin
    K_VFAssignByPath( VFile, FName );
    Result := (VFile.VFType <> K_vftDFile) or
              not FileExists(FName)        or
             ((FileGetAttr( FName ) and faReadOnly) = 0);
  end;

begin
//*** Check if Preparing IniFile State for Saving to Decoded IniFile is needed
  if ( N_KeyIsDown(VK_RSHIFT)   and
       N_KeyIsDown(VK_RCONTROL) and
       N_KeyIsDown(VK_RMENU) ) then
    K_IniFileCreateParams := K_DFCreatePlain;

//*** Check if Preparing IniFile State for Saving to Encoded IniFile is needed
  if ( N_KeyIsDown(VK_LSHIFT)   and
       N_KeyIsDown(VK_LCONTROL) and
       N_KeyIsDown(VK_LMENU) ) then
    K_IniFileCreateParams := K_DFCreateEncrypted;

//*** Check if Saving to Decoded IniFile is enabled
  if (AMemIniFile.FileName <> '') and
     CanBeUpdate(AMemIniFile.FileName) then
  begin
    WSL := TStringList.Create;
    AMemIniFile.GetStrings( WSL );
//    K_SaveStringsToDFile( WSL, AMemIniFile.FileName, K_IniFileCreateParams );
    K_VFSaveStrings( WSL, AMemIniFile.FileName, K_IniFileCreateParams );
    WSL.Free;
  end;
end; //*** end of procedure K_SaveMemIniToFile

//****************************************************** K_SaveMemIniToFile ***
// Clear Application Temporary Files folder
//
//     Parameters
// AForceDirFlags - force folder flags
// ADelFlags - delete files flags
// AFext     - deleteed files extension
//
procedure K_ClearAppTmpFiles( AForceDirFlags : Boolean = FALSE;
                              ADelFlags : TK_DelFolderFilesFlags = [K_dffRecurseSubfolders,K_dffRemoveReadOnly];
                              const AFext : string = '*.*' );
var
  TmpPath : string;
begin
  TmpPath := K_AppFileGPathsList.Values['TmpFiles'];
  if TmpPath = '' then Exit;
  if AForceDirFlags then
    K_ForceDirPath( TmpPath );
  K_DeleteFolderFiles( TmpPath, AFext, ADelFlags );
end; // procedure K_ClearAppTmpFiles

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_TreeIniGlobals
//******************************************************** K_TreeIniGlobals ***
// Application global common initialization
//
//     Parameters
// Result - Returns TRUE if global initialization was done.
//
// Must be called once. If is repeatedly called then resulting value is FALSE
// and no initialization will be done.
//
function K_TreeIniGlobals( ARootType : Integer = -1 ) : Boolean;
var
  i : Integer;
  DWFlags : Byte;
  CMDParams : TStringList;
  FileName : string;
  FilePat  : string;
  UseDatFile : Boolean;
{
  F: TSearchRec;
  FilePath  : string;
  SearchPat  : string;
}
begin
  Result := K_MainRootObj = nil;
  if not Result then Exit;

//  N_InitWorkAreaRect(); // Init N_WorkAreaRect by Ini file - now is not needed any more
  N_InitWAR();

//*** UDTree Initialization
  N_EmptyObj := TN_UDBase.Create;
  Inc(N_EmptyObj.RefCounter); // set save from deletion flag
  N_EmptyObj.ObjName := 'Empty';

  // Global Root
  K_MainRootObj := TN_UDBase.Create;
  K_MainRootObj.ObjName := 'GRoot';
  K_MainRootObj.RefPath := K_udpAbsPathCursorName;
  K_UDAbsPathCursor := K_UDCursorGet(K_udpAbsPathCursorName);

  // SPL Root
  K_SPLRootObj := K_MainRootObj.AddOneChild( TN_UDBase.Create );
  K_SPLRootObj.ObjName := K_udpSPLRootName;

  // Archives Root
  if ARootType = -1 then ARootType := N_UDBaseCI;
  K_ArchsRootObj := K_MainRootObj.AddOneChild( N_ClassRefArray[ARootType].Create );
  K_ArchsRootObj.ObjName := K_udpArchivesRootName;

  // Compound Buffered Files Root
  K_FilesRootObj := K_MainRootObj.AddOneChild( TN_UDBase.Create );
  K_FilesRootObj.ObjName := K_udpFilesRootName;

  // UDClass References Init
  K_InitClassRefList();

  // UDBase Visual Trees Init
  N_VTrees := TList.Create;
  N_PWinList := TList.Create; // Obsolete
  N_PageList := TList.Create; // Obsolete

  // UDTree Clipboards (obsolete)
  SetLength( N_UObjAllClipboards, 3 );
  for i := 1 downto 0 do
  begin
    N_ActiveClipboard := TN_UDBase.Create;
    N_ActiveClipboard.ObjFlags := K_fpObjOwnerLinkNon;
    N_ActiveClipboard.ObjName := 'Clipboard'+IntToStr( i + 1 );
    N_UObjAllClipboards[i] := N_ActiveClipboard;
    K_MainRootObj.AddOneChild( N_ActiveClipboard );
  end;

//*** MemIni Initialization
  if N_CurMemIni = nil then begin
    FilePat := ChangeFileExt( Application.ExeName, '' );
    FileName := FilePat + '.dat';
//    FileName := ExtractFilePath(FilePat) + 'CMSuiteDemo.dat';
    K_ErrFName := FileName;
    if not K_LoadMemIniFromFile( N_CurMemIni, FileName + '|ini' ) then
    begin
      FileName := FilePat + '.ini';
      UseDatFile := FileExists( K_ErrFName );
      if not UseDatFile then
        K_ErrFName := FileName
      else
        K_ErrFName :=  K_ErrFName + '|ini';
      if not K_LoadMemIniFromFile( N_CurMemIni, FileName ) then
      begin
        if UseDatFile then
          K_DumpUDFilesStruct( FilePat + '!!!FilesState.txt' );
        raise Exception.Create( 'File "' + K_ErrFName + '" not found' );
      end;
    end;
  end;

//*** Command Line Params Initialization
  CMDParams := TStringList.Create;
  K_GetCommandLineParams;
  N_CurMemIni.ReadSectionValues('CMDParams', CMDParams );
  for i := 0 to CMDParams.Count - 1 do
    if K_CMDParams.IndexOfName( CMDParams.Names[i] ) = -1 then
      K_CMDParams.Add( CMDParams[i] );
  CMDParams.Free;

//*** Global Named File Paths Initialization
  if N_MemIniToBool( 'Global', 'UseWinEnvMacro', FALSE ) then
    K_GetWinEnvStrings( );

  K_InitAppDirsList();

  // Create|Clear Tmp Files Root Folder
  K_ClearAppTmpFiles( TRUE, [K_dffRemoveReadOnly] );
{
  FileName := K_AppFileGPathsList.Values['TmpFiles'];
  if FileName <> '' then
  begin
    K_ForceDirPath( FileName );
    K_DeleteFolderFiles( FileName, '*.*', [] ); // Remove Files in TmpFiles Root only
  end;
}
//*** Application Dump Watch Initialization
  FileName := N_CurMemIni.ReadString( 'Dump', 'DumpFile', '' );
  if FileName <> '' then
    FileName := K_ExpandFileName(FileName);
//    DumpFileName := ExtractFilePath( Application.ExeName ) + DumpFileName;

  K_InfoWatch := TK_InfoWatch.Create(
    N_CurMemIni.ReadInteger( 'Dump', 'Watch', 0 ),
    FileName, nil );
  K_InfoWatch.WatchMLevel := N_CurMemIni.ReadInteger( 'Dump', 'WatchLevel', 0 );
  K_InfoWatch.WatchMLevel := N_CurMemIni.ReadInteger( 'Dump', 'DumpLevel', 0 );

  K_InfoWatch.ConsoleMlevel := N_CurMemIni.ReadInteger( 'Dump', 'Console', -1 );
  K_InfoWatch.Console := (K_InfoWatch.ConsoleMlevel >= 0);


//*** SPL Initialization
  K_SPLBinModeFlags.I := K_BuildISetByIDs(
                  N_CurMemIni.ReadString( 'Global', 'SPLBinModeFlags', '' ),
                  K_SPLBinModeFlagsAllDef );

  K_CompileIniSPLFiles();

//*** Corret SPL Common Data Format Version Info
  K_SPLDataNDPTVer := K_SPLDataCurFVer;
  for i := 0 to K_TypeDescrsList.Count - 1 do
    with TK_UDFieldsDescr(K_TypeDescrsList.Objects[i]) do begin
// if FDCurFVer > 20081000 then
//   FDCurFVer := FDCurFVer + 0;
      K_SPLDataCurFVer := Max( K_SPLDataCurFVer, FDCurFVer );
      K_SPLDataNDPTVer := Max( K_SPLDataNDPTVer, FDNDPTVer );
      K_SPLDataPDNTVer := Max( K_SPLDataPDNTVer, FDPDNTVer );
    end;

  K_NewArchFilesEnvID := N_CurMemIni.ReadString( 'Global', 'NewArchFilesEnvID', '' );
  K_NewArchAppID := N_CurMemIni.ReadString( 'Global', 'NewArchAppID', '' );
  K_InitArchInfo( '', '', K_tbFEnvID + '=' + K_NewArchFilesEnvID+#13#10+
                          K_tbAppID + '=' + K_NewArchAppID+#13#10+
                          K_tbArchFmtMinVerID + '=' + IntToStr( K_SPLDataNDPTVer )+#13#10+
                          K_tbArchFmtCurVerID + '=' + IntToStr( K_SPLDataCurFVer ) );

//*** Application Dump Watch Flags Initialization
  DWFlags := 0;
  K_GetTypeCodeSafe('TK_IWFlagSet').FD.ValueFromString( DWFlags,
      N_CurMemIni.ReadString( 'Dump', 'DumpFlags', '' ) );
  K_InfoWatch.DumpFlags := TK_IWFlagSet(DWFlags);

//*** Global Named UDTree Paths Initialization
  N_CurMemIni.ReadSectionValues( K_UDGPathsIniSection, K_AppUDGPathsList );

//*** Application Common Macro from Ini-File
  N_CurMemIni.ReadSectionValues( 'AppMacro', K_AppInfoList );

//*** Set Application Language Context

  FileName := N_CurMemIni.ReadString( 'Global', 'CurLangDataFile', '' );
  FileName := K_FindFirstFileNameByPattern( FileName );
  if FileName <> '' then
  begin
    // Create Runtime Language Data
    K_CurLangData  := TN_MemTextFragms.CreateFromVFile( FileName );
    if K_CurLangData.MTFragmsList.Count = 0 then
      FreeAndNil(K_CurLangData)
    else
    begin
      K_PrepLangTexts( K_CurLangData );
      i := K_CurLangData.AddFragm( '$$File', '' );
      with TStrings(K_CurLangData.MTFragmsList.Objects[i]) do
      begin
        Add( 'FileName=' + FileName );
        Add( 'FileDate=' + K_DateTimeToStr( K_GetFileAge( FileName ), 'yyyy-mm-dd_hh":"nn":"ss.zzz' ) );
      end;
    end;
  end;
{
  FileName := N_CurMemIni.ReadString( 'Global', 'CurLangDataFile', '' );
  if FileName <> '' then
  begin
    // Search proper lang file
    FileName := K_ExpandFileName(FileName);
    FilePath := ExtractFilePath( FileName );
    FilePat  := ExtractFileName( FileName );

    SearchPat := FileName;
    if Pos( '?', FilePat ) > 0 then
      SearchPat := FilePath + '*.*';

    if FindFirst( SearchPat, faAnyFile, F ) = 0 then
      repeat
        if (F.Name[1] = '.') or
           ((F.Attr and faDirectory) <> 0) then continue;

        if not K_CheckTextPattern( F.Name, FilePat ) then continue;

        FileName := FilePath + F.Name;
        break;
      until FindNext( F ) <> 0;
    SysUtils.FindClose( F );

    // Create Runtime Language Data
    K_CurLangData  := TN_MemTextFragms.CreateFromVFile( FileName );
    if K_CurLangData.MTFragmsList.Count = 0 then
      FreeAndNil(K_CurLangData)
    else
    begin
      K_PrepLangTexts( K_CurLangData );
      i := K_CurLangData.AddFragm( '$$File', '' );
      with TStrings(K_CurLangData.MTFragmsList.Objects[i]) do
      begin
        Add( 'FileName=' + FileName );
        Add( 'FileDate=' + K_DateTimeToStr( K_GetFileAge( FileName ), 'yyyy-mm-dd_hh":"nn":"ss.zzz' ) );
      end;
    end;
  end;
}
end; // end of procedure K_TreeIniGlobals

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_TreeFinGlobals
//******************************************************** K_TreeFinGlobals ***
// Application global finalization
//
// Filnalize application data: save SPL compiled resource file and etc.
//
procedure K_TreeFinGlobals;
var
//  TMPFiles : string;
//  FName : string;
  WMainRoot : TN_UDBase;
begin
  if K_MainRootObj = nil then Exit;
  FreeAndNil( N_PBCaller ); // to avoid Error while closing All Compound Buffered Files

  K_SaveCompiledIniSPLFiles();
  K_MVCBFCloseAll(); // Close All Compound Buffered Files
  K_TreeViewsUpdateModeSet;
  N_DestroyAllPages();
  N_PageList.Free;
  N_DestroyAllPwin();
  N_PWinList.Free;

  WMainRoot := K_MainRootObj;
  K_MainRootObj := nil;
  WMainRoot.UDDelete;
  Dec(N_EmptyObj.RefCounter); // clear save deletion flag
  N_EmptyObj.UDDelete;

  K_TreeViewsUpdateModeClear();
  FreeAndNil( N_VTrees );
  K_ClearAppTmpFiles( );
{
  TMPFiles := K_AppFileGPathsList.Values[ 'TmpFiles' ];
  if TMPFiles <> '' then K_DeleteFolderFiles( TMPFiles );
}
end; // end of procedure K_TreeFinGlobals

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_TreeViewsUpdateModeSet
//************************************************ K_TreeViewsUpdateModeSet ***
// Set update mode to all IDB Visual representations objects
//
// Is useful for IDB structure changings acceleration.
//
procedure K_TreeViewsUpdateModeSet(  );
var i : Integer;
begin
  if N_VTrees = nil then Exit;
  for i := 0 to N_VTrees.Count - 1 do // prepare VTree to speed up its changing
    if TN_VTree(N_VTrees[i]) <> nil then TN_VTree(N_VTrees[i]).ChangeTreeViewUpdateMode(true);
//  Screen.Cursor := crHourGlass;
end; // end_of procedure K_TreeViewsUpdateModeSet

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_TreeViewsUpdateModeClear
//********************************************** K_TreeViewsUpdateModeClear ***
// Clear update mode in all IDB Visual representations objects
//
//     Parameters
// AUseUpdateCounter - check udate counter while clear update counter mode
//
procedure K_TreeViewsUpdateModeClear( AUseUpdateCounter : Boolean = true);
var i : Integer;
begin
  if N_VTrees = nil then Exit;
  for i := 0 to N_VTrees.Count - 1 do // prepare VTree to speed up its changing
    if TN_VTree(N_VTrees[i]) <> nil then TN_VTree(N_VTrees[i]).ChangeTreeViewUpdateMode(false, AUseUpdateCounter);
//  Screen.Cursor := crDefault;
end; // end_of procedure K_TreeViewsUpdateModeClear

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_TreeViewsInvalidate
//*************************************************** K_TreeViewsInvalidate ***
// Repainte view in all IDB Visual representations objects
//
procedure K_TreeViewsInvalidate();
var i : Integer;
begin
  for i := 0 to N_VTrees.Count - 1 do // prepare VTree to speed up its changing
    if TN_VTree(N_VTrees[i]) <> nil then TN_VTree(N_VTrees[i]).TreeView.Invalidate();
end; // end_of procedure K_TreeViewsInvalidate

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_TreeViewsRebuild
//****************************************************** K_TreeViewsRebuild ***
// Rebuild view in all IDB Visual representations objects
//
// Destroy all Visual Nodes in all Visual Trees and create only new root level 
// Visual Nodes
//
procedure K_TreeViewsRebuild();
var i : Integer;
begin
  K_TreeViewsUpdateModeSet(  );
  for i := 0 to N_VTrees.Count - 1 do // Rebuild VTree
    if TN_VTree(N_VTrees[i]) <> nil then TN_VTree(N_VTrees[i]).Delete([K_fNTPRebuildVTree]);
  K_TreeViewsUpdateModeClear(false);
end; // end_of procedure K_TreeViewsUpdateModeClear

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_TreeViewsInfoGet
//****************************************************** K_TreeViewsInfoGet ***
// Save current view state of all IDB Visual representation objects
//
//     Parameters
// ATI - array of IDB Visual Tree state info
//
procedure K_TreeViewsInfoGet( var ATI : TK_VTIArray );
var
  j, i : Integer;
begin
  SetLength( ATI, N_VTrees.Count );
  j := 0;
  for i := 0 to N_VTrees.Count - 1 do begin
    if TN_VTree(N_VTrees[i]) = nil then Continue;
    with ATI[j] do begin
      VTree := TN_VTree(N_VTrees[i]);
      MarkedList := TStringList.Create;
      ExpandedList := TStringList.Create;
      RootPath := VTree.GetCurState( MarkedList, ExpandedList );
    end;
    Inc(j);
  end;
  SetLength( ATI, j );
end; // end_of procedure K_TreeViewsInfoGet

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_TreeViewsInfoRestore
//************************************************** K_TreeViewsInfoRestore ***
// Restore view state of all IDB Visual representation objects using previous 
// state
//
//     Parameters
// ATI - array of IDB Visual Tree state info
//
procedure K_TreeViewsInfoRestore( const ATI : TK_VTIArray );
var
  i : Integer;
begin
  K_TreeViewsUpdateModeSet;
  for i := 0 to High(ATI) do
    with ATI[i] do begin
      if N_VTrees.IndexOf(VTree) = -1 then Continue;
      VTree.SetCurState( RootPath, MarkedList, ExpandedList );
    end;
  K_TreeViewsUpdateModeClear( false );
end; // end_of procedure K_TreeViewsInfoRestore

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_TreeViewsInfoFree
//***************************************************** K_TreeViewsInfoFree ***
// Free saved view state info
//
//     Parameters
// ATI - array of IDB Visual Tree state info
//
procedure K_TreeViewsInfoFree( var ATI : TK_VTIArray );
var
  i : Integer;
begin
  for i := 0 to High(ATI) do
    with ATI[i] do begin
     MarkedList.Free;
     ExpandedList.Free;
    end;
  ATI := nil;
end; // end_of procedure K_TreeViewsInfoFree

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_SaveTreeToMem
//********************************************************* K_SaveTreeToMem ***
// Serialize IDB Subnet to serial binary buffer
//
//     Parameters
// ARootUObj   - given IDB Subnet root object
// ASBuf       - serial binary buffer object
// AOnlyChilds - if =FALSE then root object is added
// ASaveFlags  - separately loaded IDB Subnets saving modes
//
// Use K_LoadTreeFromMem to restore IDB Subnet. Only [K_lsfSkipAllSLSR, 
// K_lsfJoinAllSLSR] from all separately loaded IDB Subnets modes are actual.
//
procedure K_SaveTreeToMem( ARootUObj : TN_UDBase; ASBuf : TN_SerialBuf;
                           AOnlyChilds : Boolean = false;
                           ASaveFlags : TK_UDTreeLSFlagSet = [K_lsfSkipAllSLSR] );
var
  DE : TN_DirEntryPar;
  AddChildTree: boolean;
  TmpUDGControlFlags : TK_UDGControlFlagSet;
  SavedRefPath : string;
begin
  if ARootUObj = nil then Exit;
  ASBuf.Init0(TRUE);


  TmpUDGControlFlags := K_AddSaveLoadFlagsToGlobalFlags( ASaveFlags );
  K_SetUDGControlFlags( 1, K_gcfSysDateUse );

  K_UDRefIndex1 := 0;
  K_SysDateTime := Now();

  with ARootUObj do begin
    SavedRefPath := RefPath;
    RefPath := K_udpLocalPathCursorName;
    if not AOnlyChilds then begin
      K_ClearDirEntry( DE );
      DE.Child := ARootUObj;
      DE.Parent := Owner;
      K_AddDEToSBuf( ASBuf, DE, AddChildTree );
    end else
      AddChildTree := true;

    if AddChildTree then
      AddChildTreeToSBuf( ASBuf );
  end;
  K_SetUDGControlFlags( -1, K_gcfSysDateUse );
  K_UDGControlFlags := TmpUDGControlFlags;

  K_ClearSubTreeRefInfo( ARootUObj, [K_criClearMarker] );
  ARootUObj.RefPath := SavedRefPath;

  ASBuf.AddDataFormatInfo();
  K_ClearUsedTypesMarks( ASBuf.SBUsedTypesList );
end; // end_of procedure K_SaveTreeToMem

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_LoadTreeFromMem0
//****************************************************** K_LoadTreeFromMem0 ***
// Restore IDB Subnet serialized by K_SaveTreeToMem
//
//     Parameters
// ARootUObj   - IDB Subnet root object
// ASBuf       - serial binary buffer object
// AOnlyChilds - if =FALSE then new root object will be created and returned in 
//               ARootUObj, if =TRUE then loaded objects will replace given root
//               object childs
// ALoadFlags  - separately loaded IDB Subnets loading modes
//
// Only [K_lsfSkipAllSLSR, K_lsfJoinAllSLSR] from all separately loaded IDB 
// Subnets modes are actual.
//
procedure K_LoadTreeFromMem0( var ARootUObj : TN_UDBase; ASBuf : TN_SerialBuf;
                                 AOnlyChilds : Boolean = false;
                                 ALoadFlags : TK_UDTreeLSFlagSet = [K_lsfSkipAllSLSR] );
var
  GetChildTree: boolean;
  DE: TN_DirEntryPar;
  TmpUDGControlFlags : TK_UDGControlFlagSet;
  URNum : Integer;
  FEL : TStringList;
  FEC : Integer;
begin
  FEL := nil;
  FEC := ASBuf.CheckUsedTypesInfo( TStrings(FEL) );
  if FEC <> 0 then begin
      if FEC = 2 then begin
        N_Dump1Str( 'Load from Memory Error: Used Types Info is absent' );
        if not (K_gcfSkipErrMessages in K_UDGControlFlags) then
          K_ShowMessage( 'Load from Memory Error: Used Types Info is absent' );
        Exit;
      end;
    //*** Show Format Version Errors
      K_ShowFmtVerErrorMessageDlg( FEC,  'Memory',  FEL );
      FEL.Free;
    Exit;
  end;

  TmpUDGControlFlags := K_AddSaveLoadFlagsToGlobalFlags( ALoadFlags );

  K_SysDateTime := Now();
  K_TreeLoadVersion := K_TreeCurVersion;

  K_UDRefTable := nil;
  K_SetUDGControlFlags( 1, K_gcfSysDateUse );
  K_SetUDGControlFlags( 1, K_gcfSkipRefReplace );
  ASBuf.StartProgress;
  K_LoadUDTreeErrorMessage := '';
  try
    if not AOnlyChilds then begin
      K_GetDEFromSBuf( ASBuf, DE, GetChildTree );
      ARootUObj := DE.Child;
    end else begin
      GetChildTree := true;
      ARootUObj.ClearChilds;
    end;
    K_UDCursorGet(K_udpLocalPathCursorName).SetRoot( ARootUObj );
    if GetChildTree then
      ARootUObj.GetChildTreeFromSBuf( ASBuf );
  except
    On E: Exception do
    begin
      K_LoadUDTreeErrorMessage := E.Message;
      if not (K_gcfSkipErrMessages in K_UDGControlFlags) then
        K_ShowMessage( K_LoadUDTreeErrorMessage );
    end;
  end;

  K_SetUDGControlFlags( -1, K_gcfSysDateUse );
  K_SetUDGControlFlags( -1, K_gcfSkipRefReplace );
  K_UDGControlFlags := TmpUDGControlFlags;

  URNum := K_BuildDirectReferences( ARootUObj, [K_bdrClearRefInfo, K_bdrClearURefCount] );
  if URNum > 0 then
    K_ShowUnresRefsInfo( ARootUObj, URNum );

  K_UDRefTable := nil;
  ASBuf.Init0();
end; // end_of function K_LoadTreeFromMem0

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_LoadTreeFromMem
//******************************************************* K_LoadTreeFromMem ***
// Restore IDB Subnet serialized by K_SaveTreeToMem including root object
//
//     Parameters
// ASBuf      - serial binary buffer object
// ALoadFlags - separately loaded IDB Subnets loading modes
// Result     - Returns new IDB Subnet root object
//
// Only [K_lsfSkipAllSLSR, K_lsfJoinAllSLSR] from all separately loaded IDB 
// Subnets modes are actual.
//
function K_LoadTreeFromMem( ASBuf : TN_SerialBuf; ALoadFlags : TK_UDTreeLSFlagSet =
                                              [K_lsfSkipAllSLSR] ) : TN_UDBase;
begin
  Result := nil;
  K_LoadTreeFromMem0( Result, ASBuf, false, ALoadFlags );
end; // end_of function K_LoadTreeFromMem

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_SaveTreeToText
//******************************************************** K_SaveTreeToText ***
// Serialize IDB Subnet to serial text buffer
//
//     Parameters
// ARootUObj   - given IDB Subnet root object
// ASBuf       - serial text buffer object
// AOnlyChilds - if =FALSE then root object is added
// ASaveFlags  - separately loaded IDB Subnets saving modes
//
// Use K_LoadTreeFromText to restore IDB Subnet. Only [K_lsfSkipAllSLSR, 
// K_lsfJoinAllSLSR] from all separately loaded IDB Subnets modes are actual.
//
procedure K_SaveTreeToText( ARootUObj : TN_UDBase; ASBuf : TK_SerialTextBuf;
                            AOnlyChilds : Boolean = false;
                            ASaveFlags : TK_UDTreeLSFlagSet = [K_lsfSkipAllSLSR] );
var
  STag : string;
  ClassInd : Integer;
  PrevOwnerMarker : Integer;
  SavedRefPath : string;
  TmpUDGControlFlags : TK_UDGControlFlagSet;
begin
  if ARootUObj = nil then Exit;
  ASBuf.InitSave();
  ClassInd := ARootUObj.CI;
  if not(ARootUObj is N_ClassRefArray[ClassInd]) then
  begin // error in obj Class Flags
    K_ShowMessage( 'Save to text -> Error in obj Class Flags  for ' + ARootUObj.ClassName );
    assert(false);
    Exit;
  end;
//  STag := N_ClassTagArray[ClassInd];
  STag := K_GetUObjTagName(ARootUObj);

  TmpUDGControlFlags := K_AddSaveLoadFlagsToGlobalFlags( ASaveFlags );
  K_SetUDGControlFlags( 1, K_gcfSkipRefReplace );
  K_UDRefIndex1 := 0;

  ASBuf.AddTag( STag );

  with ARootUObj do begin
    SavedRefPath := RefPath;
    RefPath := K_udpLocalPathCursorName;
    PrevOwnerMarker := 0;
    if Owner <> nil then begin
      PrevOwnerMarker := Owner.Marker;
      Owner.Marker := 1;
    end;
    if not AOnlyChilds then
      AOnlyChilds := AddToText( ASBuf, true );
    if AOnlyChilds then
      AddChildsToText( ASBuf );

    if Owner <> nil then
      Owner.Marker := PrevOwnerMarker;
  end;

  ASBuf.AddTag( STag, tgClose );

  K_SetUDGControlFlags( -1, K_gcfSkipRefReplace );
  K_UDGControlFlags := TmpUDGControlFlags;

  K_ClearSubTreeRefInfo( ARootUObj, [K_criClearMarker] );
  ARootUObj.RefPath := SavedRefPath;

  ASBuf.AddDataFormatInfo( K_txtSkipTypesInfo in K_TextModeFlags );
  K_ClearUsedTypesMarks( ASBuf.SBUsedTypesList );

end; // end_of procedure K_SaveTreeToText

//*************************************************** K_ParseXMLFromTextBuf ***
// Parse XML from K_SerialTextBuf
//
//     Parameters
// ARootUObj - Root Object for loading XML
//
// Each XML Node (Tag) is parsed to TK_UDStringList object with. All Tag
// Attributes are placed to it's Stringlist Field
//
procedure K_ParseXMLFromTextBuf( ARootUObj : TN_UDBase );
var
  XMLPos : Integer;
  WSTR : string;
begin
  with K_SerialTextBuf do
  begin
    XMLPos := Pos( K_TagOpenChar + '?', St.Text );
    if XMLPos > 0 then
    begin
    // Skip XML Description
      WSTR := Copy( St.Text, XMLPos + 2, 3 );
      if SameText( WSTR, 'xml' ) then
        St.setPos( PosEx( '?' + K_TagCloseChar, St.Text, XMLPos + 5 ) + 2 );
    end;
  end;
  Include( K_TextModeFlags, K_txtParseXMLTree );
  K_LoadTreeFromText0( ARootUObj, K_SerialTextBuf, TRUE );
  Exclude( K_TextModeFlags, K_txtParseXMLTree );
end; // procedure K_ParseXMLFromTextBuf

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_ParseXMLFromFile
//****************************************************** K_ParseXMLFromFile ***
// Parse XML from text file to UDBase Tree
//
//     Parameters
// ARootUObj - Root Object for loading XML
// AFileName - name of text file with XML data
//
// Each XML Node (Tag) is parsed to TK_UDStringList object with. All Tag
// Attributes are placed to it's Stringlist Field
//
procedure K_ParseXMLFromFile( ARootUObj : TN_UDBase; AFileName: string );
//var
//  XMLPos : Integer;
//  WSTR : string;
begin
  with K_SerialTextBuf do
  begin
    LoadFromFile( AFileName );
{
    XMLPos := Pos( K_TagOpenChar + '?', St.Text );
    if XMLPos > 0 then
    begin
    // Skip XML Description
      WSTR := Copy( St.Text, XMLPos + 2, 3 );
      if SameText( WSTR, 'xml' ) then
        St.setPos( PosEx( '?' + K_TagCloseChar, St.Text, XMLPos + 5 ) + 2 );
    end;
}
  end;
{
  Include( K_TextModeFlags, K_txtParseXMLTree );
  K_LoadTreeFromText0( ARootUObj, K_SerialTextBuf, TRUE );
  Exclude( K_TextModeFlags, K_txtParseXMLTree );
}
  K_ParseXMLFromTextBuf( ARootUObj );
end; // end of procedure K_ParseXMLFromFile

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_LoadTreeFromText0
//***************************************************** K_LoadTreeFromText0 ***
// Restore IDB Subnet serialized by K_SaveTreeToText
//
//     Parameters
// ARootUObj   - IDB Subnet root object
// ASBuf       - serial text buffer object
// AOnlyChilds - if =FALSE then new root object will be created and returned in
//               ARootUObj, if =TRUE then loaded objects will replace given root
//               object childs
// ALoadFlags  - separately loaded IDB Subnets loading modes
//
// Only [K_lsfSkipAllSLSR, K_lsfJoinAllSLSR] from all separately loaded IDB 
// Subnets modes are actual.
//
procedure K_LoadTreeFromText0( var ARootUObj : TN_UDBase; ASBuf : TK_SerialTextBuf;
                                  AOnlyChilds : Boolean = false;
                                  ALoadFlags : TK_UDTreeLSFlagSet = [K_lsfSkipAllSLSR] );
var
  STag : string;
  TagType : TK_STBufTagType;
  ClassRefInd, LoadChildNum : Integer;
  TmpUDGControlFlags : TK_UDGControlFlagSet;
  URNum : Integer;
  FEL : TStringList;
  FEC : Integer;
begin

  FEL := nil;

  if not (K_txtParseXMLTree in K_TextModeFlags) then
    ASBuf.InitLoad1(); // Skip InitLoad because <?xml ... ?> is already skiped

  if not (K_txtXMLMode      in K_TextModeFlags) and
     not (K_txtParseXMLTree in K_TextModeFlags) then
  begin
  // Skip Type Info Check in XML Mode
    FEC := ASBuf.CheckUsedTypesInfo( TStrings(FEL) );
    if FEC <> 0 then
    begin
      if FEC = 2 then
      begin
        K_ShowMessage( 'Info about SPL Types used in Archive is absent' );
        Exit;
      end;
    //*** Show Format Version Errors
      K_ShowFmtVerErrorMessageDlg( FEC,  'Memory',  FEL );
      FEL.Free;
      Exit;
    end;
  end;

  TmpUDGControlFlags := K_AddSaveLoadFlagsToGlobalFlags( ALoadFlags );
  K_SetUDGControlFlags( 1, K_gcfSysDateUse );
  K_SetUDGControlFlags( 1, K_gcfSkipRefReplace );

  K_LoadUDTreeErrorMessage := '';
  try
//    ASBuf.InitLoad1();
    ASBuf.GetTag( STag, TagType );
    if not AOnlyChilds then
    begin
      ClassRefInd := K_GetUObjCIByTagNameExt( STag, ASBuf );
      ARootUObj := N_ClassRefArray[ClassRefInd].Create
    end
    else
      ARootUObj.ClearChilds;
  //*** get UDBase fields (may be its subtree)

    K_UDCursorGet(K_udpLocalPathCursorName).SetRoot( ARootUObj );
    K_UDRefTable := nil;

    if (K_txtParseXMLTree in K_TextModeFlags) and
       (ARootUObj is TK_UDStringList) then
    begin
      ARootUObj.ObjName := STag;
      TK_UDStringList(ARootUObj).SL.Assign( ASBuf.AttrsList );
    end;

    if not AOnlyChilds then
      LoadChildNum := ARootUObj.GetFieldsFromText( ASBuf )
    else
      LoadChildNum := 0;

    if LoadChildNum >= 0 then
      ARootUObj.GetChildSubTreeFromText( ASBuf, STag, false, LoadChildNum )
    else
      ASBuf.GetSpecTag( STag, tgClose );
  except
    On E: Exception do
    begin
      K_LoadUDTreeErrorMessage := E.Message;
      K_ShowMessage( K_LoadUDTreeErrorMessage );
    end;
  end;

  K_SetUDGControlFlags( -1, K_gcfSysDateUse );
  K_SetUDGControlFlags( -1, K_gcfSkipRefReplace );
  K_UDGControlFlags := TmpUDGControlFlags;
  if not (K_txtParseXMLTree in K_TextModeFlags) then begin
  // XML Tree has no References
    URNum := K_BuildDirectReferences( ARootUObj, [K_bdrClearRefInfo, K_bdrClearURefCount] );
    if URNum > 0 then
      K_ShowUnresRefsInfo( ARootUObj, URNum );
  end;
  K_UDRefTable := nil;
  N_PBCaller.Finish();
end; // end_of function K_LoadTreeFromText0

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_LoadTreeFromText
//****************************************************** K_LoadTreeFromText ***
// Restore IDB Subnet serialized by K_SaveTreeToText including root object
//
//     Parameters
// ASBuf      - serial text buffer object
// ALoadFlags - separately loaded IDB Subnets loading modes
// Result     - Returns new IDB Subnet root object
//
// Only [K_lsfSkipAllSLSR, K_lsfJoinAllSLSR] from all separately loaded IDB 
// Subnets modes are actual.
//
function K_LoadTreeFromText( ASBuf : TK_SerialTextBuf; ALoadFlags : TK_UDTreeLSFlagSet =
                                              [K_lsfSkipAllSLSR] ) : TN_UDBase;
begin
  Result := nil;
  K_LoadTreeFromText0( Result, ASBuf, false, ALoadFlags );
end; // end_of function K_LoadTreeFromText

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_SaveFieldsToText
//****************************************************** K_SaveFieldsToText ***
// Serialize IDB object fields to serial text buffer
//
//     Parameters
// AUObj - given IDB  object
// ASBuf - serial text buffer object
//
// Use K_LoadFieldFromText to restore IDB object fields.
//
procedure K_SaveFieldsToText( AUObj : TN_UDBase; ASBuf : TK_SerialTextBuf );
var
  STag : string;
  ClassInd : Integer;
  ClearSysFormat : Boolean;
begin
  if AUObj = nil then Exit;
  ASBuf.InitSave();
  ClassInd := AUObj.CI;
  if not(AUObj is N_ClassRefArray[ClassInd]) then
  begin // error in obj Class Flags
    K_ShowMessage( 'Save to text -> Error in obj Class Flags  for ' + AUObj.ClassName );
    assert(false);
    Exit;
  end;
  STag := N_ClassTagArray[ClassInd];

  ASBuf.AddTag( STag );

  K_SetUDGControlFlags( 1, K_gcfSkipRefReplace );
  K_UDRefIndex1 := 0;

  if not (K_txtSysFormat in K_TextModeFlags) then begin
    ClearSysFormat := true;
    Include( K_TextModeFlags, K_txtSysFormat );
  end else
    ClearSysFormat := false;

  with AUObj do begin
    RefPath := K_udpLocalPathCursorName;
    AddFieldsToText( ASBuf ); // add node obj fields (not children!)
    if ClearSysFormat then
      Exclude( K_TextModeFlags, K_txtSysFormat );

    ASBuf.AddTag( STag, tgClose );
    K_SetUDGControlFlags( -1, K_gcfSkipRefReplace );
    K_ClearSubTreeRefInfo( AUObj, [K_criClearMarker] );
  end;
end; // end_of procedure K_SaveFieldsToText

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_LoadFieldsFromText
//**************************************************** K_LoadFieldsFromText ***
// Restore IDB object fields serialized by K_SaveFieldsToText
//
//     Parameters
// AUObj - given IDB  object
// ASBuf - serial text buffer object
//
procedure K_LoadFieldsFromText( AUObj : TN_UDBase; ASBuf : TK_SerialTextBuf );
var
  STag : string;
  TagType : TK_STBufTagType;
  ClassRefInd : Integer;
  ErrMessage : string;
  URNum : Integer;
begin
  K_LoadUDTreeErrorMessage := '';
  try
    ASBuf.InitLoad1();
    ASBuf.GetTag( STag, TagType );
    ClassRefInd := K_GetUObjCIByTagName( STag, false );
    ErrMessage := '';
    if ClassRefInd = -1 then // data error !!!
      ErrMessage := 'Open tag "'+STag+'" has no class reference -> Error in line 0'
    else  if ClassRefInd <> AUObj.CI then
      ErrMessage := 'Wrong tag "'+STag+'" -> Error in line 0';
    if ErrMessage <> '' then // data error !!!
    begin
      K_ShowMessage( ErrMessage );
//      assert(false);
      Exit;
    end;
  //*** get UDBase fields
    K_UDCursorGet(K_udpLocalPathCursorName).SetRoot( AUObj );
    K_UDRefTable := nil;
    with AUObj do begin
      if AUObj is TK_UDRArray then TK_UDRArray(AUObj).R.ASetLength( 0 );
      GetFieldsFromText( ASBuf );
      ASBuf.GetSpecTag( STag, tgClose );
    end;
  except
    On E: Exception do
    begin
      K_LoadUDTreeErrorMessage := E.Message;
      K_ShowMessage( K_LoadUDTreeErrorMessage );
    end;
  end;
  URNum := K_BuildDirectReferences( AUObj, [K_bdrClearRefInfo, K_bdrClearURefCount] );
  if URNum > 0 then
    K_ShowUnresRefsInfo( AUObj, URNum );
  K_UDRefTable := nil;
  N_PBCaller.Finish();
end; // end_of function K_LoadFieldsFromText

//************************************************* K_InitClassRefList ***
// initialization of N_ClassTagArray and N_ClassRefList
//
procedure  K_InitClassRefList;
var
  i: Integer;
begin
  if N_ClassRefList <> nil then Exit;
  N_ClassRefList := TStringList.Create;
  N_ClassRefList.CaseSensitive := false;
  for i := 0 to High(N_ClassRefArray) do
  begin
    if N_ClassRefArray[i] = nil then Continue;

    if Length(N_ClassTagArray[i]) = 0 then
      N_ClassTagArray[i] := N_ClassRefArray[i].ClassName;

    N_ClassRefList.AddObject( N_ClassTagArray[i], TObject(i) );
  end;
  N_ClassRefList.Sort;
  N_ClassRefList.Sorted := true;
end; //*** end of procedure K_InitClassRefList

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_GetUObjCIByTagName
//**************************************************** K_GetUObjCIByTagName ***
// Get IDB object class index using text tag name
//
//     Parameters
// ATagName  - IDB object text tag name
// AStopFlag - if =TRUE then raise exeption for wrong tag name
// Result    - Returns index of IDB object class in ClassReferences array
//
// Search only in list of IDB objects tag names
//
function K_GetUObjCIByTagName( ATagName : string; AStopFlag : Boolean = true ) : Integer;
var
  ClassRefInd: Integer;
begin
  Result := -1;
  if N_ClassRefList.Find( ATagName, ClassRefInd ) then
    Result := Integer( N_ClassRefList.Objects[ClassRefInd] )
  else if AStopFlag then
    raise TK_UDTypeNameError.Create( 'Name "'+ATagName+'" has no class reference' );
end; //*** end of procedure K_GetUObjCIByTagName

//##path K_Delphi\SF\K_clib\K_UDC.pas\K_GetUObjCIByTagNameExt
//************************************************* K_GetUObjCIByTagNameExt ***
// Get IDB object class index using text tag name (extended)
//
//     Parameters
// ATagName  - IDB object text tag name
// AStopFlag - if =TRUE then raise exeption for wrong tag name
// Result    - Returns index of IDB object class in ClassReferences array
//
// Try to search in list of IDB object tag names and in list of SPL type names. 
// SPL type name is used as tag name if serializing object is TK_UDRArray
//
function  K_GetUObjCIByTagNameExt( ATagName : string; ASBuf : TK_SerialTextBuf ) : Integer;
var
  DType : TK_ExprExtType;
  UDClassName : string;
begin
  Result := K_GetUObjCIByTagName( ATagName, false );
  if Result = -1 then begin
    DType := K_GetTypeCode( ATagName );
    if DType.DTCode = -1 then // data error !!!
      raise TK_LoadUDDataError.Create(
                 ASBuf.PrepErrorMessage( 'Open tag "'+ATagName+'" has no class reference -> Error in line ' ) )
    else begin
      Result := -1;
      UDClassName := '';
        ASBuf.GetTagAttr( 'UDClass', UDClassName ); // use UDClass if needed to use TagName=SPL TypeName
      if UDClassName <> '' then
        Result := K_GetUObjCIByTagName( UDClassName, false );
      if Result = -1 then
        Result := K_UDRArrayCI;

      if ASBuf.AttrsList.IndexOfName('TypeName') = -1 then
        ASBuf.AttrsList.Add( 'TypeName=' + ATagName )
    end;
  end;
end; //*** end of procedure K_GetUObjCIByTagNameExt


//##path K_Delphi\SF\K_clib\K_UDC.pas\K_GetUObjTagName
//******************************************************** K_GetUObjTagName ***
// Get IDB object text tag name for text serialization
//
//     Parameters
// AUObj  - given IDB object
// Result - Returns given IDB object tag name for text serialization
//
function  K_GetUObjTagName( AUObj : TN_UDBase ) : string;
begin
  if AUObj.CI <> K_UDRArrayCI then
    Result := N_ClassTagArray[AUObj.CI]
  else
//??    Result := K_GetExecTypeName( TK_UDRArray(AUObj).R.ElemType.All )
    Result := K_GetExecTypeName( TK_UDRArray(AUObj).R.GetComplexType.All )
end; //*** end of procedure K_GetUObjTagName

//******************************************************** K_GetUObjTagName ***
// Dump All Files Structure
//
//     Parameters
// AFileName - resulting dump file name
// AUDFile   - given file root node to dump, if nil then all files will be dump
//
procedure K_DumpUDFilesStruct( const AFileName : string; AUDFile : TN_UDBase = nil );
var
  UDRoot : TN_UDBase;
  UseGivenFile : Boolean;
begin
  Include(K_TextModeFlags, K_txtSkipUDMemData);
  UDRoot := K_FilesRootObj;
  UseGivenFile := AUDfile <> nil;
  if UseGivenFile then
    UDRoot := AUDfile;
  K_SaveTreeToText( UDRoot, K_SerialTextBuf, not UseGivenFile, [K_lsfJoinAllSLSR] );
  Exclude(K_TextModeFlags, K_txtSkipUDMemData);
  K_SerialTextBuf.TextStrings.SaveToFile( AFileName );
end; // procedure K_DumpUDFilesStruct

{
//********************************************* K_CheckFileNameExt ***
//  select file format using file name
//
function K_CheckFileNameExt( FileName : string; ExtList : TStringList;
                                        DefaultIndex : Integer = -1 ) : Integer;
var
ext : string;
begin
  Result := -1;
  ext := ExtractFileExt( FileName );
  if ext <> '' then // check if sdml save mode
  begin
    StrLower( PChar(ext) );
    Result := ExtList.IndexOf( ext );
  end;
  if Result = -1 then Result := DefaultIndex;
end; //*** end of procedure K_CheckFileNameExt
}
end.
