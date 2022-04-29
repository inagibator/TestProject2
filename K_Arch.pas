unit K_Arch;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses Windows, Classes, IniFiles,
  {K_DCSpace,} K_UDConst, K_UDT1, K_Script1, K_Types,
  N_BaseF, N_Types, N_ClassRef;

type TK_Archive = packed record
  ArchWasChanged   : Boolean;   // Archive or it's Sections were changed
  SelfArchDataWasChanged : Boolean; // Archive (not Sections) was changed
  FNameIsNotDef    : Boolean;   // Archive File Name is not proper
  UndoLevChanged   : Boolean;   // Archive Undo Level Has Changes
  UndoState        : Integer;   // Archive Undo State Index
  UndoInd          : Integer;   // Archive Undo Index
  UndoFNames       : TK_RArray; // ArrayOf String - Archive Undo File Names
  ArchFileFormatBin: Boolean;   // Archive file format is binary
end;
type  TK_PArchive = ^TK_Archive;

type
  TK_ArchFileType = ( K_aftBin, K_aftTxt, K_aftAny );
  TK_RecompileGSPLFlags = set of ( K_rsfSaveToDisk, K_rsfTxtMode, K_rsfKeepSavedFiles );

  TK_SavedArchInfo = record
    ArchInd  : Integer;   // Archive Index in K_ArchsRootObj
    ArchText : string;    // Archive Temporary File Name or Text Representation
    ArchBody : TN_BArray; // Archive Binary Memory Representation
  end;
          
function  K_GetArchUserRoot( CurArchive : TN_UDBase ) : TN_UDBase;
procedure K_InitAppDirsList( CurArchPath : string = ''; CurArchName : string = '';
                             FilesEnvID : string = '' );
procedure K_InitArchDirsList;
procedure K_SetArchInfoAttr( const AttrName, AttrValue : string;
                             UDArchive : TN_UDBase = nil;
                             UseExistedContext : Boolean = false );
function  K_GetArchInfoAttr( const AttrName : string;
                             UDArchive : TN_UDBase = nil;
                             UseExistedContext : Boolean = false ) : string;
procedure K_UpdateArchInfo( UDArchive : TN_UDBase = nil );
procedure K_InitArchInfoByArch( UDArchive : TN_UDBase = nil );
function  K_InitArchInfo( CurArchPath : string; CurArchName : string;
                          ArchSavedContext : string ): string;
function  K_GetPArchive( UDArchive : TN_UDBase ) : TK_PArchive;
function  K_ArchFileFormat(FileName : string) : TK_ArchFileType;
procedure K_ClearArchUNDOFiles( PNames : PString; Count : Integer );
procedure K_AddArchUNDO( UDArchive : TN_UDBase = nil  );
procedure K_ArchReadUNDO( UDArchive : TN_UDBase; UFName : string  );
procedure K_ArchUNDO( UDArchive : TN_UDBase = nil  );
procedure K_ArchREDO( UDArchive : TN_UDBase = nil  );
function  K_TestArchiveNode( UDArch : TN_UDBase ) : Boolean;
function  K_CreateArchiveNode( ArchName : string ) : TN_UDBase;
procedure K_RemoveAllArchives;
procedure K_SetArchiveName( UDArch : TN_UDBase; FName : string );
function  K_ReadArchive( RootNode : TN_UDBase; FName : string;
                         LoadFlags : TK_UDTreeLSFlagSet = [] ) : Boolean;
function  K_OpenCurArchive( AFName : string;
                            ALoadFlags : TK_UDTreeLSFlagSet = [];
                            AOpenExisted : Boolean = false ) : Boolean;
//function  K_OpenCurMVDarArch( FName : string;
//                            LoadFlags : TK_UDTreeLSFlagSet = [] ) : Boolean;
function  K_IfTextCopyCreate( ) : Boolean;
function  K_SaveArchive( UDArchive : TN_UDBase;
                         SaveFlags : TK_UDTreeLSFlagSet = [] ) : Boolean;
procedure K_AddCurArchiveTmpState;
procedure K_SetArchiveChangeFlag( UDArchive : TN_UDBase = nil );
procedure K_ClearArchiveChangeFlag( UDArchive : TN_UDBase = nil );
procedure K_ClearArchiveRefInfo( UDArchive : TN_UDBase = nil );
procedure K_SetArchiveCursor( UDArchive : TN_UDBase = nil );
procedure K_InitArchiveGCont( UDArchive : TN_UDBase = nil );
function  K_AddArchiveSysDir( NewDirName : string; NewDirType : TK_UDSysFolderType;
                             UDRoot : TN_UDBase = nil;
                             SysFolderCI : Integer = K_UDMVFolderCI ) : TN_UDBase;
procedure K_SetSysObjFlags( UDSysObj : TN_UDBase; NewDirType : TK_UDSysFolderType );
procedure K_AddSysObjFlags( UDSysRoot, UDSysObj : TN_UDBase;
              NewDirType : TK_UDSysFolderType; Ind : Integer = -1 );
{
procedure K_MergeSysFolderChilds( SrcRoot, DestRoot : TN_UDBase;
                                  TempMerging : Boolean;
                                  FromSrcToDest : Boolean );
procedure K_MergeArchives( SrcRoot, DestRoot : TN_UDBase;
                           DEArray : TK_DEArray );
procedure K_CreateNewArchFromCurSelected( NewArchName : string;
                                          VList : TList = nil;
                                          DEArray : TK_DEArray = nil );
}
procedure K_RecompileGlobalSPL( Flags : TK_RecompileGSPLFlags );
function  K_ReplaceRefsInArchive( PrevSubTreeRoot, NewSubTreeRoot : TN_UDBase;
                                  ShowErrorMesFlag : Boolean = true ) : Integer;
procedure K_ScanArchOwnersSubTree( TestNodeFunc : TK_TestUDChildFunc );
function  K_LoadCurArchiveSection( SectionRootNode : TN_UDBase ) : Boolean;
function  K_SaveCurArchiveSection( SectionRootNode : TN_UDBase ) : Boolean;
procedure K_LoadAllCurArchSections( AOnlyEmptySectionsLoad : Boolean = false );
procedure K_SaveAllCurArchSections( SaveFlags : TK_UDTreeLSFlagSet =
                                   [K_lsfSkipJoinChangedSLSR,K_lsfSkipEmptySLSR] );
function  K_GetSelfArchive( Node : TN_UDBase ) : TN_UDBase;

var
  K_CurUserRoot    : TN_UDBase; // Arch User SubTree Root
  K_ArchUndoNamesInd : Integer;
  K_SkipArchUndoMode : Boolean;
  K_ChangedArchiveCount : Integer;
  K_AltArchive   : TN_UDBase;
//  K_AppDirsList  : THashedStringList;
  K_CurMainForm : TN_BaseForm;
  K_CurGAProc   : TK_RAFGlobalActionProc;
  K_InitAppArchProc  : procedure ( CurArchive : TN_UDBase = nil );
  K_ArchiveDTCode : TK_ExprExtType;
  K_AfterSetCurArchChanged : TK_NotifyProc;
  K_ArchInfoList : TStringList;  // Current Archive Saved Context List
  K_NewArchAppID : string; // Application ID for new Archives
//  K_ArchCurVer   : string; // Application Archive Current Version Number
//  K_ArchMinVer   : string; // Application Archive Min Version Number

const
//***
  K_UserRootName = 'UserRoot';

  K_MVAppDirExe  = '#Exe';
  K_MVAppDirArch = '#Arch';
  K_MVAppDirArchDFiles = '#ArchDFiles';

  K_afBinExt1 = '.sdb';
  K_afBinExt2 = '.sdb';
  K_afTxtExt1 = '.sdt';
  K_afTxtExt2 = '.txt';
  K_afNewName = 'Untitled';
  K_ArchiveCursor = 'CA:';
  K_FileGPathsIniSection = 'FileGPaths';
//  Archive Info Attributes
  K_tbAIAttr     = 'ArchInfo';     // ArchInfo name
  K_tbFEnvID     = 'FilesEnvID';   // FilesEnvID name
  K_tbAppID      = 'AppID';        // Application ID name
  K_tbArchFmtCurVerID   = 'ArchFmtCurVer';// Application Archive Current FMT Version Number Name
  K_tbArchFmtMinVerID   = 'ArchFmtMinVer';// Application Binary Archive Min FMT Version Number Name

  K_ArchFileExtArr : array [1..3] of string = (K_afBinExt1, K_afTxtExt1, K_afTxtExt2);

implementation

uses
  StrUtils, SysUtils, Controls, Forms, Dialogs,
  N_Lib1,
  K_CLib, K_CLib0, K_UDC, K_UDT2,
  {K_CSpace, K_MVObjs,} K_IWatch, K_SBuf, K_STBuf;

//var
//  MergingFolders : TK_RArray;


//***************************************** K_GetArchUserRoot
// Get Archive user Root
//
function K_GetArchUserRoot( CurArchive : TN_UDBase ) : TN_UDBase;
begin
  with CurArchive do begin
    Result := DirChild( IndexOfChildObjName( K_UserRootName ) );
  end;

end; // end_of procedure K_GetArchUserRoot

//********************************************* K_InitAppDirsList
//  Init Application Files Environment Dirs List
//
procedure K_InitAppDirsList( CurArchPath : string = ''; CurArchName : string = '';
                             FilesEnvID : string = '' );
var
  ExePath : string;
  SL : TStringList;
  CInd, i : Integer;
  CName : string;

begin
  i := K_AppFileGPathsList.IndexOfName( K_MVAppDirExe );
  if i >= 0 then
    ExePath := K_AppFileGPathsList.ValueFromIndex[i]
//  if K_AppFileGPathsList.Values[K_MVAppDirExe] <> '' then
//    ExePath := K_AppFileGPathsList.Values[K_MVAppDirExe]
  else
  begin
    ExePath := N_CurMemIni.ReadString( 'Application', K_MVAppDirExe, '' );
{
    if ExePath <> '' then
      K_AppFileGPathsList[0] := K_MVAppDirExe+'='+K_ExpandFileName( ExePath )
    else
      ExePath := ExtractFilePath( Application.ExeName );
}
    if ExePath = '' then
      ExePath := ExtractFilePath( Application.ExeName );
  end;
  N_CurMemIni.ReadSectionValues( K_FileGPathsIniSection, K_AppFileGPathsList );

//*** Insert GPathsBeforeList
  if K_AppFileGPathsBeforeList <> nil then
    K_ReplaceStringsInterval( K_AppFileGPathsList, 0, 0,
                              K_AppFileGPathsBeforeList, 0, -1 );

//*** Insert Exe Path
  K_AppFileGPathsList.Insert( 0, K_MVAppDirExe+'='+ExePath );

//*** Insert CurArchive Path
  if CurArchPath <> '' then
  begin
    K_AppFileGPathsList.Insert( 1, K_MVAppDirArch+'='+CurArchPath );

    if CurArchName <> '' then
      K_AppFileGPathsList.Insert( 2, K_MVAppDirArchDFiles+'='+CurArchPath +
           IncludeTrailingPathDelimiter( ChangeFileExt( CurArchName, '.files' ) ) );
  end;

//*** Add GPathsAfterList
  if K_AppFileGPathsAfterList <> nil then
    K_ReplaceStringsInterval( K_AppFileGPathsList, -1, 0,
                              K_AppFileGPathsAfterList, 0, -1 );

//*** Rebuild GPathsList by FileEnv Section
  if FilesEnvID <> '' then
  begin
    if N_CurMemIni.SectionExists( FilesEnvID ) then
    begin
      SL := TStringList.Create;
      N_CurMemIni.ReadSectionValues( FilesEnvID, SL );
      for i := 0 to SL.Count -1 do
      begin
        CName := SL.Names[i];
        CInd := K_AppFileGPathsList.IndexOfName( CName );
        if CInd >= 0 then
          K_AppFileGPathsList.ValueFromIndex[CInd] := SL.ValueFromIndex[i]
        else
          K_AppFileGPathsList.Add( SL[i] );
      end;
      SL.Free;
    end
    else if K_NewArchFilesEnvID <> '' then
      K_ShowMessage( 'Files Environment Section "'+FilesEnvID+'" is absent');
  end; // if FilesEnvID <> '' then

//*** Customize K_AppFileGPathsList by special application procedure before Macro Replace
  if Assigned(K_AppFileGPathsCustProc) then
    K_AppFileGPathsCustProc();

//*** Macro Replace GPaths by Windows evironment varaibles
  if K_WinEnvironmentStrings <> nil then
    K_SListWinEnvMListReplace( K_AppFileGPathsList );

//*** Self Macro Replace GPaths
  K_SListMListReplace( K_AppFileGPathsList, K_AppFileGPathsList, K_ummRemoveResult );

//*** Optimized File Paths
  for i := 0 to K_AppFileGPathsList.Count -1 do
//    K_AppFileGPathsList[i] := K_OptimizePath( K_AppFileGPathsList[i] );
    if K_AppFileGPathsList.ValueFromIndex[i] <> '' then
      K_AppFileGPathsList.ValueFromIndex[i] := K_OptimizePath( K_AppFileGPathsList.ValueFromIndex[i] );

end; //*** end of procedure K_InitAppDirsList

//********************************************* K_InitArchDirsList
//  Init Application Files Environment Dirs List by current Archive
//
procedure K_InitArchDirsList;
var
  CurArchPath, CurArchName : string;
  FilesEnvID : string;

begin
  if K_AppFileGPathsList = nil then
    K_AppFileGPathsList := THashedStringList.Create;

  FilesEnvID := '';
  if (K_CurArchive = nil) or
     K_GetPArchive(K_CurArchive).FNameIsNotDef then
  begin
    K_SListMListReplace( K_AppFileGPathsList, K_AppFileGPathsList, K_ummSaveMacro );
    CurArchPath := ExpandFileName( K_AppFileGPathsList.Values['Archives'] );
    CurArchName := '';
  end
  else
  begin
    CurArchPath := ExtractFilePath(K_CurArchive.ObjAliase);
    CurArchName := ExtractFileName(K_CurArchive.ObjAliase);
  end;
  if K_CurArchive <> nil then
    FilesEnvID := K_CurArchive.ObjInfo;
  K_InitAppDirsList( CurArchPath, CurArchName, FilesEnvID );
end; //*** end of procedure K_InitArchDirsList

//********************************************* K_SetArchInfoAttr
//  Set Cur Archive Info Attribute
//
procedure K_SetArchInfoAttr( const AttrName, AttrValue : string;
                                UDArchive : TN_UDBase = nil;
                                UseExistedContext : Boolean = false );

var
  Ind : Integer;
  NewStr : string;
begin
  if UDArchive = nil then UDArchive := K_CurArchive;
  if UDArchive = nil then Exit;
  if not UseExistedContext then
    K_ArchInfoList.Text := UDArchive.ObjInfo;

  Ind := K_ArchInfoList.IndexOfName( AttrName );
  NewStr := AttrName + '=' + AttrValue;
  if Ind < 0 then
    K_ArchInfoList.Add( NewStr )
  else
    K_ArchInfoList[Ind] := NewStr;
  UDArchive.ObjInfo := K_ArchInfoList.Text;
end; //*** end of procedure K_SetArchInfoAttr

//********************************************* K_GetArchInfoAttr
//  Get Cur Archive Info Attribute
//
function  K_GetArchInfoAttr( const AttrName : string;
                                UDArchive : TN_UDBase = nil;
                                UseExistedContext : Boolean = false ) : string;
begin
  Result := '';
  if UDArchive = nil then UDArchive := K_CurArchive;
  if UDArchive = nil then Exit;
  if not UseExistedContext then
    K_ArchInfoList.Text := UDArchive.ObjInfo;
//  Result := K_ArchInfoList.Values[AttrName];
  Result := K_GetStringsValueByName( K_ArchInfoList, AttrName );
end; //*** end of procedure K_GetArchInfoAttr

//********************************************* K_UpdateArchInfo
//  Update Archive Saved Info
//
procedure K_UpdateArchInfo( UDArchive : TN_UDBase = nil );
begin
  if UDArchive = nil then UDArchive := K_CurArchive;
  if UDArchive = nil then Exit;
  if (K_GetArchInfoAttr( K_tbFEnvID, UDArchive ) = '') and
     (K_NewArchFilesEnvID <> '') then
    K_SetArchInfoAttr( K_tbFEnvID, K_NewArchFilesEnvID, UDArchive, true );
  if K_GetArchInfoAttr( K_tbAppID, UDArchive, true ) = '' then
    K_SetArchInfoAttr( K_tbAppID, K_NewArchAppID, UDArchive, true );
//  K_SetArchInfoAttr( K_tbArchFmtMinVerID, K_ArchMinVer, UDArchive, true );
//  K_SetArchInfoAttr( K_tbArchFmtCurVerID, K_ArchCurVer, UDArchive, true );
  K_SetArchInfoAttr( K_tbArchFmtMinVerID, IntToStr( K_SPLDataNDPTVer ), UDArchive, true );
  K_SetArchInfoAttr( K_tbArchFmtCurVerID, IntToStr( K_SPLDataCurFVer ), UDArchive, true );

end; //*** end of procedure K_UpdateArchInfo

//********************************************* K_InitArchInfo
//  Init Application Files Environment Dirs List
//
function K_InitArchInfo( CurArchPath : string; CurArchName : string;
                         ArchSavedContext : string ) : string;

var
  FilesEnvID : string;
  RebuildResult : Boolean;
begin
  Result := ArchSavedContext;
  K_ArchInfoList.Text := ArchSavedContext;
  RebuildResult := false;
  if K_ArchInfoList.Count = 1 then begin
    FilesEnvID := K_ArchInfoList[0];
    if 0 = Pos( '=', FilesEnvID ) then begin
  // Old ArchInfo Format
      K_ArchInfoList[0] := K_tbFEnvID + '=' + FilesEnvID;
      RebuildResult := true;
    end;
  end;
//  FilesEnvID := K_ArchInfoList.Values[K_tbFEnvID];
  FilesEnvID := K_GetStringsValueByName( K_ArchInfoList, K_tbFEnvID );


//  if K_ArchInfoList.IndexOfName( K_tbAppID ) < 0 then begin
  if K_IndexOfStringsName( K_ArchInfoList, K_tbAppID ) < 0 then begin
    K_ArchInfoList.Add( K_tbAppID + '=' + K_NewArchAppID );
    RebuildResult := true;
  end;

//  if K_ArchInfoList.IndexOfName( K_tbArchFmtMinVer ) < 0 then begin
  if K_IndexOfStringsName( K_ArchInfoList, K_tbArchFmtMinVerID ) < 0 then begin
//    K_ArchInfoList.Add( K_tbArchFmtMinVerID + '=' + K_ArchMinVer );
//    K_ArchInfoList.Add( K_tbArchFmtCurVerID + '=' + K_ArchCurVer );
    K_ArchInfoList.Add( K_tbArchFmtMinVerID + '=' + IntToStr( K_SPLDataNDPTVer ) );
    K_ArchInfoList.Add( K_tbArchFmtCurVerID + '=' + IntToStr( K_SPLDataCurFVer ) );
    RebuildResult := true;
  end;

  if RebuildResult then
    Result := K_ArchInfoList.Text;

  K_InitAppDirsList( CurArchPath, CurArchName, FilesEnvID );
end; //*** end of procedure K_InitArchInfo

//********************************************* K_InitArchInfoByArch
//  Init Application Files Environment Dirs List
//
procedure K_InitArchInfoByArch( UDArchive : TN_UDBase = nil );
var
  CurArchPath : string;
  CurArchName : string;
  ArchInfo : string;
begin
  ArchInfo := '';
  if UDArchive = nil then
    UDArchive := K_CurArchive;
  if (UDArchive = nil) or
     K_GetPArchive(UDArchive).FNameIsNotDef then
  begin
    K_SListMListReplace( K_AppFileGPathsList, K_AppFileGPathsList, K_ummSaveMacro );
    CurArchPath := ExpandFileName( K_AppFileGPathsList.Values['Archives'] );

    if (UDArchive <> nil) and not K_IfExpandedFileName(UDArchive.ObjAliase) then
      UDArchive.ObjAliase := CurArchPath + UDArchive.ObjAliase;
    CurArchName := '';
  end
  else
  begin
    CurArchPath := ExtractFilePath(UDArchive.ObjAliase);
    CurArchName := ExtractFileName(UDArchive.ObjAliase);
  end;
  if UDArchive <> nil then
    ArchInfo := UDArchive.ObjInfo;
  K_InitArchInfo( CurArchPath, CurArchName, ArchInfo );
end; //*** end of procedure K_InitArchInfoByArch

//********************************************* K_GetPArchive
//  Get Pointer To Archive Runtime Data
//
function  K_GetPArchive( UDArchive : TN_UDBase ) : TK_PArchive;
begin
  Result :=  TK_PArchive( TK_UDRArray(UDArchive).R.P );
end; //*** end of procedure K_GetPArchive

//********************************************* K_ArchFileFormat ***
//  select file format using file name
//
function K_ArchFileFormat(FileName : string) : TK_ArchFileType;
var
  ext : string;
begin
  Result := K_aftBin;
  ext := ExtractFileExt( FileName );
  if ext <> '' then
  begin
    StrLower( PChar(ext) );
    if (ext = K_afTxtExt1) or
       (ext = K_afTxtExt2) then Result := K_aftTxt
    else if (ext <> K_afBinExt1) and
            (ext <> K_afBinExt2) then Result := K_aftAny;
  end;
end; //*** end of procedure K_ArchFileFormat

//************************************************ K_ClearArchUNDOFiles
//
procedure K_ClearArchUNDOFiles( PNames : PString; Count : Integer );
var i : Integer;
begin
  for i := 0 to Count - 1 do begin
    DeleteFile( PNames^ );
    Inc( PNames );
  end;
end; //*** end of procedure K_ClearArchUNDOFiles

//************************************************ K_AddArchUNDO
//
procedure K_AddArchUNDO( UDArchive : TN_UDBase = nil );
var
  UFName : string;
  UNDOFiles : string;
  UInd : Integer;
  PArchive : TK_PArchive;
begin
  if UDArchive = nil then UDArchive := K_CurArchive;
  UNDOFiles := K_AppFileGPathsList.Values[ 'UNDOFiles' ];
  if (UDArchive = nil) or (UNDOFiles = '') then Exit;
  PArchive := K_GetPArchive( UDArchive );
  with PArchive^ do begin
    if not UndoLevChanged then Exit; // previous UNDO State is Valid
    UndoLevChanged := false;
    if K_ArchUndoNamesInd = 0 then begin
  // Clear previous Application UNDO Files
      K_ForceDirPath( UNDOFiles );
      N_DeleteFiles( UNDOFiles + '*.*', 0 );
    end;

  // Add New Undo Step
    UFName := UNDOFiles + IntToStr( K_ArchUndoNamesInd );
    Inc( K_ArchUndoNamesInd );
    UInd := UndoFNames.AHigh;
    if UndoInd < UInd then // Clear previous UNDO Files
      K_ClearArchUNDOFiles( PString(UndoFNames.P(UndoInd + 1)), UInd - UndoInd );
    Inc(UndoInd);
    UndoFNames.ASetLength( UndoInd + 1 );
    UndoState := UndoInd;
    PString(UndoFNames.P(UndoInd))^ := UFName;
// Save Archive
    UDArchive.SaveTreeToFile( UFName );
  end;
end; //*** end of procedure K_AddArchUNDO

//************************************************ K_ArchReadUNDO
//
procedure K_ArchReadUNDO( UDArchive : TN_UDBase; UFName : string  );
var
  PArchive : TK_PArchive;
begin
  PArchive := K_GetPArchive( UDArchive );
  with PArchive^ do begin
    UndoLevChanged := false;
  // Read Prev Archive
    K_TreeViewsUpdateModeSet;
    K_ReadArchive( UDArchive, UFName );
    K_TreeViewsUpdateModeClear(false);
    K_InitArchiveGCont(UDArchive);
  end;
end; //*** end of procedure K_ArchReadUNDO

//************************************************ K_ArchUNDO
//
procedure K_ArchUNDO( UDArchive : TN_UDBase = nil  );
var
  UFName : String;
  PArchive : TK_PArchive;
  UInd : Integer;
begin
  if UDArchive = nil then UDArchive := K_CurArchive;
  if UDArchive = nil then Exit;
  PArchive := K_GetPArchive( UDArchive );
  with PArchive^ do begin
    if (UndoState < 0)  and
       ( not UndoLevChanged or FNameIsNotDef) then Exit;
    UInd := UndoInd;
    if UndoLevChanged then
      K_AddArchUNDO( UDArchive );
    if UInd = UndoFNames.AHigh then Dec(UInd);
    UndoInd := UInd;
    UndoState := UndoInd;
    if UndoInd < 0 then begin // Correct Global Archives Changing Context
      if ArchWasChanged then
        Dec(K_ChangedArchiveCount);
      ArchWasChanged := false;
      if Assigned(K_AfterSetCurArchChanged) then
        K_AfterSetCurArchChanged;
      UFName := UDArchive.ObjAliase;
    end else begin
      UFName := PString(UndoFNames.P(UndoInd))^;
      Dec(UndoInd);
    end;
    K_ArchReadUNDO( UDArchive, UFName );
  end;
end; //*** end of procedure K_ArchUNDO

//************************************************ K_ArchREDO
//
procedure K_ArchREDO( UDArchive : TN_UDBase = nil  );
var
  UInd : Integer;
  PArchive : TK_PArchive;
begin
  if UDArchive = nil then UDArchive := K_CurArchive;
  if UDArchive = nil then Exit;
  PArchive := K_GetPArchive( UDArchive );
  with PArchive^ do begin
    UInd := UndoFNames.AHigh;
    if UndoState >= UInd then Exit;
    Inc( UndoState );
    UndoInd := UndoState;
    if not ArchWasChanged and (UndoState = 0) then begin // Correct Global Archives Changing Context
      ArchWasChanged := true;
      Inc(K_ChangedArchiveCount);
      if Assigned(K_AfterSetCurArchChanged) then
        K_AfterSetCurArchChanged;
    end;
    K_ArchReadUNDO( UDArchive, PString(UndoFNames.P(UndoInd))^ );
  end;
end; //*** end of procedure K_ArchREDO

//************************************************ K_AddCurArchiveTmpState
//
procedure K_AddCurArchiveTmpState;
var
  UInd : Integer;
  PArchive : TK_PArchive;
  SaveUndoState : Boolean;
begin
  if (K_CurArchive = nil) or K_SkipArchUndoMode then Exit;
  PArchive := K_GetPArchive( K_CurArchive);
  with PArchive^ do begin
   // UNDO Buffer
    UndoLevChanged := true;
    SaveUndoState := true;
    if UndoFNames = nil then begin
      UndoFNames := K_RCreateByTypeCode( Ord(nptString) );
//      SaveUndoState := not FNameIsNotDef;
    end else begin
      UInd := UndoFNames.AHigh;
      if UInd > UndoInd then // Clear Undo Buffer Tail
        with UndoFNames do begin
          K_ClearArchUNDOFiles( PString(P(UndoInd + 1) ), UInd - UndoInd );
          ASetLength( UndoInd + 1 );
        end;
    end;
    if SaveUndoState then
      K_AddArchUNDO( K_CurArchive );
  end;
  if Assigned(K_AfterSetCurArchChanged) then
    K_AfterSetCurArchChanged;
end; //*** end of procedure K_AddCurArchiveTmpState

//************************************************ K_SetArchiveChangeFlag
//
procedure K_SetArchiveChangeFlag( UDArchive : TN_UDBase = nil );
var
  PArchive : TK_PArchive;
//  UInd : Integer;
//  SaveUndoState : Boolean;
begin
  if UDArchive = nil then UDArchive := K_CurArchive;
  if UDArchive <> nil then begin
    PArchive := K_GetPArchive( UDArchive );
    with PArchive^ do begin
      if not ArchWasChanged then
        Inc(K_ChangedArchiveCount);
      ArchWasChanged := true;
      UDArchive.SetDate;
    end;
  end;
  if Assigned(K_AfterSetCurArchChanged) then
    K_AfterSetCurArchChanged;
end; //*** end of procedure K_SetArchiveChangeFlag

//************************************************ K_ClearArchiveChangeFlag
//
procedure K_ClearArchiveChangeFlag( UDArchive : TN_UDBase = nil );
var
  PArchive : TK_PArchive;
begin
  if UDArchive = nil then UDArchive := K_CurArchive;
  if UDArchive <> nil then begin
    PArchive := K_GetPArchive( UDArchive );
    with PArchive^ do begin
      if ArchWasChanged then
        Dec(K_ChangedArchiveCount);
      ArchWasChanged := false;
      UndoInd := -1;
      UndoState := -1;
      UndoLevChanged := false;
      with UndoFNames do begin // Clear Undo Buffer
        K_ClearArchUNDOFiles( PString(P), ALength );
        ASetLength(0);
      end;
    end;
  end;
  if Assigned(K_AfterSetCurArchChanged) then
    K_AfterSetCurArchChanged;
end; //*** end of procedure K_ClearArchiveChangeFlag

//************************************************ K_SetCurArchiveName
//
procedure K_SetArchiveName( UDArch : TN_UDBase; FName : string );
begin
  UDArch.ObjName := ChangeFileExt( ExtractFileName(FName), '' );
  UDArch.PrepareObjName;
  with K_ArchsRootObj do
    SetUniqChildName( UDArch );
  UDArch.ObjAliase := FName;
end; //*** end of procedure K_SetCurArchiveName

//************************************************ K_TestArchiveNode
//
function K_TestArchiveNode( UDArch : TN_UDBase ) : Boolean;
begin
  if K_ArchiveDTCode.All = 0 then
    K_ArchiveDTCode := K_GetTypeCodeSafe( 'TK_Archive' );
  if (UDArch.CI = K_UDRArrayCI) and
     (TK_UDRArray(UDArch).R.ElemType.DTCode = K_ArchiveDTCode.All) then
    Result := true
  else
    Result := false;
end; //*** end of function K_TestArchiveNode

//************************************************ K_CreateArchiveNode
//
function K_CreateArchiveNode( ArchName  : string ) : TN_UDBase;
var
  PArchive : TK_PArchive;
begin
  with K_ArchsRootObj do begin
    if K_ArchiveDTCode.All = 0 then
      K_ArchiveDTCode := K_GetTypeCodeSafe( 'TK_Archive' );
    Result := AddOneChild( K_CreateUDByRTypeCode( K_ArchiveDTCode.All ) );
//    Result := AddOneChild( TN_UDBase.Create );
    Result.ObjFlags := Result.ObjFlags or K_fpObjSFolder or
                       LongWord(Ord(K_sftSkipAll) shl K_fpObjSFTypePos);
    K_SetArchiveName( Result, ArchName );
    K_UpdateArchInfo( Result);
    PArchive := K_GetPArchive( Result );
    with PArchive^ do begin
      UndoInd := -1;
      UndoState := -1;
      UndoLevChanged := false;
    end;
    AddChildVNodes( DirHigh );
  end;
end; //*** end of procedure K_CreateArchiveNode

//************************************************ K_RemoveAllArchives
//
procedure K_RemoveAllArchives;
var
  Ind, MInd : Integer;
begin
  K_TreeViewsUpdateModeSet;
  MInd := K_ArchsRootObj.DirHigh;
  for Ind := 0 to MInd do
    K_ArchsRootObj.RemoveDirEntry( 0 );
  K_CurArchive := nil;
  K_TreeViewsUpdateModeClear( false );
end; //*** end of procedure K_RemoveAllArchives

//************************************************ K_ReadArchive
//  LoadFlags use only [K_lsfSkipAllSLSR, K_lsfJoinAllSLSR]
//
function K_ReadArchive( RootNode : TN_UDBase; FName : string;
                        LoadFlags : TK_UDTreeLSFlagSet = [] ) : Boolean;
var
  SaveCursor : TCursor;
begin
//*** search in archives list
  Result := true;
  if FName = '' then Exit;
  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  K_SetUDGControlFlags( 1, K_gcfSkipVTreeDeletion );
  K_InfoWatch.AddInfoLine( '' );
  K_InfoWatch.AddInfoLine( 'Load Archive <- ' + FName );
  with K_GetPArchive( RootNode )^ do begin
    ArchFileFormatBin := true;
    try
      case N_SerialBuf.TestFile(FName) of
      0 : RootNode.LoadTreeFromFile( FName, LoadFlags );
      1 : begin
        ArchFileFormatBin := false;
        K_UDGControlFlags := K_UDGControlFlags + [K_gcfTrySLSRSDTFileLoad];
        RootNode.LoadTreeFromTextFile( FName, LoadFlags );
        K_UDGControlFlags := K_UDGControlFlags - [K_gcfTrySLSRSDTFileLoad];
      end;
      else
        Result := false;
      end;
    except
      Result := false;
    end;
  end;
  K_SetUDGControlFlags( -1, K_gcfSkipVTreeDeletion );
  Screen.Cursor := SaveCursor;
end; //*** end of procedure K_ReadArchive

//************************************************ K_OpenCurArchive
//
function K_OpenCurArchive( AFName : string;
                           ALoadFlags : TK_UDTreeLSFlagSet = [];
                           AOpenExisted : Boolean = false ) : Boolean;
var
  Ind : Integer;
  PrevCurArch : TN_UDBase;
begin
//*** search in archives list
  Result := true;
  if AFName = '' then Exit;
  PrevCurArch := K_CurArchive;
  with K_ArchsRootObj do begin
    Ind := IndexOfChildObjName( AFName, K_ontObjAliase );
    if Ind <> -1 then begin // Show Select Same Archive Dialog
      K_CurArchive := DirChild( Ind );
    end else if not AOpenExisted then begin
      // Add New Archive
      K_CurArchive := K_CreateArchiveNode( AFName );
      Result := K_ReadArchive( K_CurArchive, AFName, ALoadFlags );
      if not Result then begin
        DeleteOneChild( K_CurArchive );
        K_CurArchive := PrevCurArch;
      end;
    end else
      Result := false;
  end;
end; //*** end of procedure K_OpenCurArchive

{
//***************************************** K_OpenCurMVDarArch
// Open MVDar Archive, convert to new format if needed
//
function  K_OpenCurMVDarArch( FName : string;
                            LoadFlags : TK_UDTreeLSFlagSet = [] ) : Boolean;
var
  Ind : Integer;
  PrevCurArch, TmpRoot : TN_UDBase;
//  h : Integer;
//  WNode : TN_UDBase;
begin
//*** search in archives list
  Result := true;
  if FName = '' then Exit;
  PrevCurArch := K_CurArchive;
  with K_ArchsRootObj do begin
    Ind := IndexOfChildObjName( FName, K_ontObjAliase );
    if Ind <> -1 then // Show Select Same Archive Dialog
      K_CurArchive := DirChild( Ind )
    else begin
      // Add New Archive
      TmpRoot := K_CreateArchiveNode( FName );
      Result := K_ReadArchive( TmpRoot, FName, LoadFlags );
      if not Result then begin
        DeleteOneChild( TmpRoot );
        K_CurArchive := PrevCurArch;
      end else
      //*** New MVDar format - no conversion is needed
        K_CurArchive := TmpRoot;
    end;
  end;
  K_InitArchiveGCont(K_CurArchive);
end; // end_of procedure K_OpenCurMVDarArch
}

//************************************************ K_IfTextCopyCreate
//
function K_IfTextCopyCreate( ) : Boolean;
begin
  Result := N_MemIniToBool( 'Global', 'ArchSDTCopy', false );
end; // end of K_IfTextCopyCreate

//************************************************ K_SaveArchive
//
function K_SaveArchive( UDArchive : TN_UDBase;
                        SaveFlags : TK_UDTreeLSFlagSet = [] ) : Boolean;
var
  SaveCursor : TCursor;
//  FName : string;
  VFile: TK_VFile;
begin
  K_VFAssignByPath( VFile, UDArchive.ObjAliase );
  if (VFile.VFType = K_vftDFile)     and
     FileExists(UDArchive.ObjAliase) and
     ((FileGetAttr( UDArchive.ObjAliase ) and faReadOnly) <> 0) then
  begin
    K_ShowMessage( 'File "'+UDArchive.ObjAliase+'" has read only attribute.'+
                 Chr($0D)+Chr($0A)+Chr($09)+Chr($09)+'Saving is impossible.' );
    Result := false;
    Exit;
  end;
  Result := true;
  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  if K_IfTextCopyCreate() then
    K_UDGControlFlags := K_UDGControlFlags + [K_gcfArchSDTCopy];

  try
    K_SetArchiveCursor;
    K_UpdateArchInfo( UDArchive );
    K_InfoWatch.AddInfoLine( '' );
    with K_GetPArchive( UDArchive )^ do
    begin
      ArchFileFormatBin := K_ArchFileFormat( UDArchive.ObjAliase ) <> K_aftTxt;
      UDArchive.SaveTreeToAnyFile( UDArchive, UDArchive.ObjAliase, UDArchive.ObjInfo,
                                   SaveFlags, not ArchFileFormatBin );
    end;
  except
    on EFCreateError do begin
      Result := false;
    end;
  end;

  K_UDGControlFlags := K_UDGControlFlags - [K_gcfArchSDTCopy];

  Screen.Cursor := SaveCursor;
end; //*** end of procedure K_SaveArchive

//************************************************ K_ClearArchiveRefInfo
//
procedure K_ClearArchiveRefInfo( UDArchive : TN_UDBase = nil );
begin
  if UDArchive = nil then UDArchive := K_CurArchive;
  K_ClearSubTreeRefInfo( UDArchive );
  K_SetNodeCursorRefPath( UDArchive, K_ArchiveCursor );
end; //*** end of procedure K_ClearArchiveRefInfo

//************************************************ K_SetArchiveCursor
//
procedure K_SetArchiveCursor( UDArchive : TN_UDBase = nil );
begin
  if UDArchive = nil then UDArchive := K_CurArchive;
  K_SetNodeCursorRefPath( UDArchive, K_ArchiveCursor );
end; //*** end of procedure K_SetArchiveCursor

//************************************************ K_InitArchiveGCont
//
procedure K_InitArchiveGCont( UDArchive : TN_UDBase = nil );
begin
//*** create new archive if needed
  if UDArchive = nil then UDArchive := K_CurArchive;
//  N_Dump1Str( '***** TimeStamp: Inside EDAccessInit 01' ); // Deb time measuring
  K_InitArchInfoByArch( UDArchive );
//  N_Dump1Str( '***** TimeStamp: Inside EDAccessInit 02' ); // Deb time measuring
  K_SetArchiveCursor( UDArchive );
//  N_Dump1Str( '***** TimeStamp: Inside EDAccessInit 03' ); // Deb time measuring
{
//***B This Code Will Be Removed
  K_InitCSpaceGCont( UDArchive ); // New CSpace  Context
  K_InitDCodeGCont( UDArchive );  // Old DCSpace Context

  if UDArchive <> nil then begin
    K_CurUserRoot := K_GetArchUserRoot( UDArchive );
    if K_CurUserRoot = nil then
      K_CurUserRoot := K_AddArchiveSysDir( K_UserRootName, K_sftAddAll, UDArchive );
    if Assigned(N_InitAppArchProc) then
      N_InitAppArchProc( UDArchive );
  end;
//***E This Code Will Be Removed
}
//  N_Dump1Str( '***** TimeStamp: Inside EDAccessInit 04' ); // Deb time measuring
  if Assigned(K_InitAppArchProc) then
    K_InitAppArchProc( UDArchive );
  N_Dump1Str( '***** TimeStamp: Inside EDAccessInit 05' ); // Deb time measuring
end; //*** end of procedure K_InitArchiveGCont

//************************************************ K_AddArchiveSysDir
//
function K_AddArchiveSysDir( NewDirName : string; NewDirType : TK_UDSysFolderType;
                             UDRoot : TN_UDBase = nil;
                             SysFolderCI : Integer = K_UDMVFolderCI ) : TN_UDBase;
var
  Ind : Integer;
begin
//*** create new archive if needed
  if UDRoot = nil then UDRoot := K_CurArchive;
  with UDRoot do begin
    Ind := IndexOfChildObjName( NewDirName );
    if Ind <> -1 then begin
      Result := DirChild( Ind );
      Exit;
    end;
    Result := AddOneChild( N_ClassRefArray[SysFolderCI].Create );
    Result.ObjName := NewDirName;
    K_AddSysObjFlags( UDRoot, Result, NewDirType )
  end;
end; //*** end of procedure K_AddArchiveSysDir

//************************************************ K_SetSysObjFlags
//
procedure K_SetSysObjFlags( UDSysObj : TN_UDBase; NewDirType : TK_UDSysFolderType );
begin
  UDSysObj.ObjFlags := ( UDSysObj.ObjFlags and (not K_fpObjSFTypeMask) ) or
                             K_fpObjProtected or
                             K_fpObjSFolder   or
                             LongWord(Ord(NewDirType) shl K_fpObjSFTypePos);
end; //*** end of procedure K_SetSysObjFlags

//************************************************ K_AddSysObjFlags
//
procedure K_AddSysObjFlags( UDSysRoot, UDSysObj : TN_UDBase;
              NewDirType : TK_UDSysFolderType; Ind : Integer = -1 );
var
  EntryFlags : Integer;
begin
//*** create new archive if needed
  K_SetSysObjFlags( UDSysObj, NewDirType );
  with UDSysRoot do begin
    EntryFlags := K_fpDEProtected + K_fpDEObjProtected;
    if Ind = -1 then Ind := DirHigh;
    PutDEField( Ind, EntryFlags, K_DEFisFlags );
  end;
end; //*** end of procedure K_AddSysObjFlags
{
type TK_MergeFolders = record
  SrcFolder, DestFolder : TN_UDBase; // merging folders
  FSTD : Boolean                     // from src to dest flag
end;
type TK_PMergeFolders = ^TK_MergeFolders;

//************************************************ K_MergeSysFolderChilds
// Merge system folder childs
//
procedure K_MergeSysFolderChilds( SrcRoot, DestRoot : TN_UDBase;
                                  TempMerging : Boolean;
                                  FromSrcToDest : Boolean );
var
  i, j, h, js, ir : Integer;
  ifRemoveVnodes : boolean;
  DE : TN_DirEntryPar;
  FType : TK_UDSysFolderType;
  FDestRoot : TN_UDBase;
  UnconditionalAdd : Boolean;

begin
  if TempMerging then
    FType := K_sftAddAll
  else
    FType := TK_UDSysFolderType( (DestRoot.ObjFlags and K_fpObjSFTypeMask) shr K_fpObjSFTypePos );
  FDestRoot := DestRoot;
  if not FromSrcToDest then begin
  //*** Create temp Root for Result placing
    FDestRoot := TN_UDBase.Create;
    FDestRoot.CopyChilds( DestRoot );
  end;

  UnconditionalAdd := (FType = K_sftAddAll) or (FType = K_sftAddUniqRefs);

  js := FDestRoot.DirLength;
  FDestRoot.DirSetLength( js + SrcRoot.DirLength );
  j := js;
  h := SrcRoot.DirHigh;
  for i := 0 to h do
  begin
    SrcRoot.GetDirEntry(i, DE );
    if (DE.Child <> nil) and (DE.Child.Marker <> 0) then begin
      if not UnconditionalAdd and (js > 0) then
        ir := FDestRoot.IndexOfChildObjName( DE.Child.GetUName, K_ontObjUName, 0, js )
      else
        ir := -1;

      if ((ir = -1)  and
          ((FType = K_sftSkipOther) or
           (FType = K_sftSkipOtherObjName))) then continue;

      if not TempMerging then
        DE.Child.Owner := nil;  // for owner switching
      if UnconditionalAdd or (ir = -1) then begin
      //*** add Child to dest folder
        FDestRoot.PutDirEntry( j, DE, ifRemoveVnodes );
        Inc(j);
      end else begin
      //*** replace corresponding Child in dest folder if Child is not protected
        if FDestRoot.DirChild( ir ).Marker = 0 then
          FDestRoot.PutDirEntry( ir, DE, ifRemoveVnodes );
      end;
    end;
  end;
  FDestRoot.DirSetLength( j );
  if not FromSrcToDest then begin
  //*** Put Result Folder structure to Source Folder
    SrcRoot.CopyChilds( FDestRoot );
    FDestRoot.Delete;
  end;
end; //*** end of procedure K_MergeSysFolderChilds

//************************************************ K_NormChildNames
// Normalized SysFolders childs ObjNames
//
procedure K_NormChildNames( SrcRoot, DestRoot : TN_UDBase; FromSrcToDest : Boolean );
var
  i, h, js, ir : Integer;
  DE : TN_DirEntryPar;
  DestChild : TN_UDBase;
  FType : TK_UDSysFolderType;
  ChildFSTD : Boolean;
  SysFolderChild : Boolean;
  UDB : TN_UDBase;

begin

  FType := TK_UDSysFolderType( (DestRoot.ObjFlags and K_fpObjSFTypeMask) shr K_fpObjSFTypePos );
//*** Normalized folder childs names
  js := DestRoot.DirLength;

//1  2  3
//+  -  -   K_sftAddAll,           // add all childs
//-  -  +-  K_sftSkipAll,          // skip all childs
//+  -  +-  K_sftReplace,          // replace corresponding childs
//+  -  +-  K_sftSkipOther,        // skip not corresponding childs
//-  +- +-  K_sftReplaceObjName,   // replace corresponding childs
//-  +- +-  K_sftSkipOtherObjName, // skip not corresponding childs
//-  -  -   K_sftAddUniqRefs       // clear doubled references after archives merging
//1  Preliminary Add to Dest (Dest is not Empty) and set uniq ObjNames to Marked and Own for both folders
//2  Set uniq ObjNames to Marked and Own in Src Folder

  if (FType <> K_sftAddUniqRefs) then begin
    if (js > 0)                         and
       (FType <> K_sftSkipAll)          and
       (FType <> K_sftReplaceObjName)   and
       (FType <> K_sftSkipOtherObjName) then begin
  //*** add src and dest to folders list
      DestRoot.DirSetLength( js + SrcRoot.DirLength );
  //*** temporary add to dest folder
      K_MergeSysFolderChilds( SrcRoot, DestRoot, true, true );
  //*** make Uinc names in both folders
      DestRoot.SetChildsUniqNames( [K_sunUseMarked, K_sunUseOwnChilds] );
  //*** Clear added childs
      DestRoot.ClearChilds( js );
      DestRoot.DirSetLength( js );
    end else if (FType = K_sftReplaceObjName) or
                (FType = K_sftSkipOtherObjName) then
      SrcRoot.SetChildsUniqNames( [K_sunUseMarked, K_sunUseOwnChilds] );

    if (js > 0)                    and
       (FType <> K_sftAddAll) then begin
  //*** Synchronized Correnspondig Objects Names
      h := SrcRoot.DirHigh;
      for i := 0 to h do begin
        SrcRoot.GetDirEntry( i, DE );
        if DE.Child = nil then continue;
        SysFolderChild := (DE.Child.ObjFlags and K_fpObjSFolder) <> 0;
        if not SysFolderChild and (DE.Child.Marker = 0) then continue;
        ir := DestRoot.IndexOfChildObjName( DE.Child.GetUName, K_ontObjUName );
  //      ir := DestRoot.IndexOfChildObjName( DE.Child.ObjName );
        if ir <> -1 then begin
          DestChild := DestRoot.DirChild(ir);
          DestChild.ObjName := DE.Child.ObjName;
          if SysFolderChild then begin  // SysFolder
            if FType = K_sftSkipAll then
               ChildFSTD := FromSrcToDest
            else
               ChildFSTD := (DestChild.Marker <> 0); // prevent Dest marked nodes replacing
            K_NormChildNames( DE.Child, DestChild, ChildFSTD );
          end;
        end;
      end;
    end;
  end;

//*** Save Src/Dest Pair of folders lists
  if (FType = K_sftSkipAll) or (SrcRoot.DirLength = 0) then Exit;
  if MergingFolders = nil then
    MergingFolders := TK_RArray.Create( SizeOf(TK_MergeFolders) );
  i := MergingFolders.ALength;
  MergingFolders.ASetLength(i + 1);
  with TK_PMergeFolders(MergingFolders.P(i))^ do begin
    SrcFolder := SrcRoot;
    DestFolder := DestRoot;
    FSTD := FromSrcToDest;
  end;
//*** Inc Refcounter to skip folder deletion in K_fpObjSFAddUniqRefs case
  if FromSrcToDest then
    UDB := DestRoot
  else
    UDB := SrcRoot;
  if (UDB.ObjFlags and K_fpObjSFTypeMask) = K_fpObjSFAddUniqRefs then
    Inc(UDB.RefCounter);

end; //*** end of procedure K_NormChildNames

//************************************************ K_MergeArchives
// Merge archives
//
procedure K_MergeArchives( SrcRoot, DestRoot : TN_UDBase;
                           DEArray : TK_DEArray );
var
  UNR, i, h, j , k : Integer;
  UDB, UDSS, SpacesRoot : TN_UDBase;
  SaveCursor : TCursor;
  PMF : TK_PMergeFolders;

begin

  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  K_TreeViewsUpdateModeSet;
  try
    with SrcRoot do begin
      SpacesRoot := DirChild( IndexOfChildObjName( K_DCSpacesRootName ) );
      k := SpacesRoot.DirHigh;
  //*** Mark Code Spaces Using Code SubSpaces
      for j := 0 to k do begin
        UDB := SpacesRoot.DirChild( j );
        if UDB = nil then continue;
        with TK_UDDCSpace(UDB).GetSSpacesDir do begin
          for i := 0 to DirHigh do begin
            UDSS := DirChild(i);
            if UDSS = nil then continue;
            if UDSS.Marker <> 0 then
              TK_UDDCSSpace(UDSS).GetDCSpace.SetMarker( UDSS.Marker );
          end;
        end;
      end;
  //*** Mark projections for marked DCSpaces
      for j := 0 to k do begin
        UDB := SpacesRoot.DirChild( j );
        if (UDB = nil) or (UDB.Marker <> 0) then continue;
  //*** search for projections
        with TK_UDDCSpace(UDB).GetSSpacesDir do begin
          for i := 0 to DirHigh do begin
            UDSS := DirChild(i);
            if (UDSS = nil) or (UDSS.CI <> K_UDVectorCI) then continue;
  //*** projection is found
            if TK_UDVector(UDSS).GetDCSSpace.GetDCSpace.Marker <> 0 then
  //*** correspondig DCSpace is marked
              UDSS.SetMarker( UDB.Marker );
          end;
        end;
      end;
    end;

  //*** Normalized Object Names
    K_NormChildNames( SrcRoot, DestRoot, true );
  //*** Clear Deleted Data Vectors

  //*** Build Reference Objects instead of direct references in Source and New Tree

    K_UnlinkDirectReferences( SrcRoot, K_udpLocalPathCursor, true );
    K_UnlinkDirectReferences( DestRoot, K_udpLocalPathCursor, true );

  //*** Merge SysFolders
    h := MergingFolders.AHigh;
    for i := 0 to h do begin
      with TK_PMergeFolders(MergingFolders.P(i))^ do
        K_MergeSysFolderChilds( SrcFolder, DestFolder, false, FSTD );
    end;

  //*** Add New Childs to Dest User Root
    K_AddChildsFromDEArray( K_GetArchUserRoot( DestRoot ),
                                    DEArray, false );

  // Delete Archive
    K_SetUDGControlFlags( 1, K_gcfSkipVTreeDeletion );
    if SrcRoot.Owner = nil then
      SrcRoot.Delete
    else
      with SrcRoot.Owner do RemoveDirEntry( IndexOfDEField( SrcRoot ) );
    K_SetUDGControlFlags( -1, K_gcfSkipVTreeDeletion );

    K_UDCursorGet(K_udpLocalPathCursor).SetRoot( DestRoot );

//    K_UDOwnerChildsScan := true;
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsOwnerChildsOnlyScan];
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan];
    DestRoot.UnMarkSubTree;
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsOwnerChildsOnlyScan];
//    K_UDOwnerChildsScan := false;

    Exclude(K_UDGControlFlags, K_gcfSkipRefReplace);

  //*** Clear References Info
    UNR := K_BuildDirectReferences( DestRoot, [K_bdrClearRefInfo, K_bdrClearURefCount] );
    if UNR > 0 then begin
  //*** Clear References to deleted UDVectors from CSS Vectors Dir
      with DestRoot do begin
        with DirChild( IndexOfChildObjName( K_DCSpacesRootName ) ) do begin
          for j := 0 to DirHigh do begin
            UDB := DirChild( j );
            if UDB = nil then continue;
            with TK_UDDCSpace(UDB).GetSSpacesDir do begin
              for i := 0 to DirHigh do begin
                UDSS := DirChild(i);
                if UDSS = nil then continue;
                with TK_UDDCSSpace(UDSS).GetVectorsDir do begin
                  for k := DirHigh downto 0 do
                    if DirChild(k).CI = K_UDRefCI then begin
                      RemoveDirEntry( k );
                      Dec(UNR);
                    end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  // Save Unresolved References List to Dump
    if UNR > 0 then K_ShowUnresRefsInfo( DestRoot, UNR );
//    if UNR > 0 then K_BuildDirectReferences( DestRoot );

   //*** Remove doubled Child References in K_sftAddUniqRefs folders
    for i := 0 to h do begin
      PMF := TK_PMergeFolders(MergingFolders.P(i));
      with PMF^ do begin
        if FSTD then
          UDB := DestFolder
        else
          UDB := SrcFolder;
        if (UDB.ObjFlags and K_fpObjSFTypeMask) = K_fpObjSFAddUniqRefs then begin
          if UDB.RefCounter = 1 then
            UDB.Delete
          else
            UDB.LeaveUniqChilds;
        end;
      end;
    end;

    DestRoot.RebuildVnodes;

//    K_SetUDGControlFlags( -1, K_gcfSysDateUse );
    with MergingFolders do
      DeleteElems( 0, Alength );
  finally
    K_TreeViewsUpdateModeClear( false );
    Screen.Cursor := SaveCursor;
  end;
end; //*** end of procedure K_MergeArchives

//************************************************ K_CreateNewArchFromCurSelected
// Create New Archive from Current Selected
//
procedure K_CreateNewArchFromCurSelected( NewArchName : string;
                                          VList : TList = nil;
                                          DEArray : TK_DEArray = nil );
var
  tmpRoot : TN_UDBase;
  SaveCursor : TCursor;

begin
  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

//*** build new archive
  tmpRoot := K_CreateArchiveNode( NewArchName );
  K_InitArchiveGCont( tmpRoot );

//*** marked all nodes in selected SubTrees
  K_MarkVNodesListSubTrees( VList, 1 );

  K_MergeArchives( K_CurArchive, tmpRoot, DEArray );
  K_CurArchive := tmpRoot;

  with K_GetPArchive( K_CurArchive )^ do FNameIsNotDef := true;
  K_SetArchiveChangeFlag;

  Screen.Cursor := SaveCursor;
end; //*** end of procedure K_CreateNewArchFromCurSelected
}

//************************************************ K_RecompileGlobalSPL
//
procedure K_RecompileGlobalSPL( Flags : TK_RecompileGSPLFlags );
var
  i, h, j : Integer;
  CUD : TN_UDBase;
  SaveCursor : TCursor;
  Archs : array of TK_SavedArchInfo;
  TI : TK_VTIArray;
begin

  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

//*** Save VTree Roots
  K_TreeViewsInfoGet( TI );

  K_TreeViewsUpdateModeSet;

//*** Prevent VTree Deletion
  K_SetUDGControlFlags( 1, K_gcfSkipVTreeDeletion );

  CUD := K_CurArchive;
  with K_ArchsRootObj do begin
//*** Save Open Archives
    h := DirHigh;
    SetLength( Archs, h + 1 );
    j := 0;
    for i := 0 to h do begin
      K_CurArchive := DirChild( i );
      if K_TestArchiveNode( K_CurArchive ) then begin
        Archs[j].ArchInd := i;
        if K_rsfSaveToDisk in Flags then begin
          Archs[j].ArchText := K_ExpandFileNameByDirPath( K_MVAppDirExe,
            ChangeFileExt(K_CurArchive.ObjAliase, '') + '_RSPL_TMP_'+IntToStr(i) );
          if K_rsfTxtMode in Flags then begin
            Archs[j].ArchText := Archs[j].ArchText + K_afTxtExt1;
            K_CurArchive.SaveTreeToTextFile(  Archs[j].ArchText, K_TextModeFlags );
          end else begin
            Archs[j].ArchText := Archs[j].ArchText + K_afBinExt1;
            K_CurArchive.SaveTreeToFile(  Archs[j].ArchText )
          end;
        end else begin
          if K_rsfTxtMode in Flags then begin
            K_SaveTreeToText( K_CurArchive, K_SerialTextBuf, true );
            Archs[j].ArchText := K_SerialTextBuf.TextStrings.Text;
          end else begin
            K_SaveTreeToMem( K_CurArchive, N_SerialBuf, true );
//          Archs[j].ArchBody := Copy( TN_BArray(N_SerialBuf.Buf1), 0, N_SerialBuf.OfsFree );
            Archs[j].ArchBody := TN_BArray(N_SerialBuf.GetDataToBArray());
          end;
        end;
        Inc(j);
        K_CurArchive.ClearChilds;
      end;
    end;
    SetLength( Archs, j );

//*** Recompile Ini SPL
    K_CompileIniSPLFiles(true);

//*** Open Saved Archives
    K_ArchiveDTCode := K_GetTypeCodeSafe( 'TK_Archive' );
    for i := 0 to High(Archs) do begin
      K_CurArchive := DirChild( Archs[i].ArchInd );
      TK_UDRArray(K_CurArchive).R.SetComplexType(K_ArchiveDTCode);
//      TK_UDRArray(K_CurArchive).R.ElemType := K_ArchiveDTCode;
      if K_rsfSaveToDisk in Flags then begin
        K_CurArchive.LoadTreeFromAnyFile( Archs[i].ArchText );
        if not (K_rsfKeepSavedFiles in Flags) then
          DeleteFile(Archs[i].ArchText);
      end else begin
        if K_rsfTxtMode in Flags then begin
          K_SerialTextBuf.LoadFromText( Archs[i].ArchText );
          K_LoadTreeFromText0( K_CurArchive, K_SerialTextBuf, true );
        end else begin
          with Archs[i] do
          N_SerialBuf.LoadFromMem( ArchBody[0], Length(ArchBody) );
          K_LoadTreeFromMem0( K_CurArchive, N_SerialBuf, true );
        end;
      end;
    end;
  end;
  K_CurArchive := CUD;
  K_InitArchiveGCont( K_CurArchive );

//*** Restore VTree Global Flags
  K_SetUDGControlFlags( -1, K_gcfSkipVTreeDeletion );

//*** Restore VTree View
  K_TreeViewsInfoRestore( TI );
  K_TreeViewsInfoFree( TI );

  K_TreeViewsUpdateModeClear( false );

  Screen.Cursor := SaveCursor;
end; //*** end of procedure K_RecompileGlobalSPL

//************************************** K_ReplaceRefsInArchive
// Replace References From Nodes of Archive to Another SubTree
//
function K_ReplaceRefsInArchive( PrevSubTreeRoot, NewSubTreeRoot : TN_UDBase;
                                 ShowErrorMesFlag : Boolean = true ) : Integer;
begin
  Result := K_ReplaceRefsInSubTree( K_CurArchive, PrevSubTreeRoot, NewSubTreeRoot,
                                    ShowErrorMesFlag);
  K_SetArchiveCursor( K_CurArchive );
end; // end of procedure K_ReplaceRefsInArchive

//***********************************  K_ScanArchOwnersSubTree
// Start ScanSubTree Routine for Owners in Arch SubTree
//
procedure K_ScanArchOwnersSubTree( TestNodeFunc : TK_TestUDChildFunc );
begin
//  K_UDOwnerChildsScan := true;
//  K_UDRAFieldsScan := false;
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsOwnerChildsOnlyScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan];

  K_CurArchive.ScanSubTree( TestNodeFunc );

  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsOwnerChildsOnlyScan];
//  K_UDRAFieldsScan := true;
//  K_UDOwnerChildsScan := false;
end; // end of K_ScanArchOwnersSubTree

//************************************************ K_LoadSection
//
function K_LoadSection( SectionRootNode : TN_UDBase ) : Boolean;
var
  ErrMessage : string;
begin
  Result := true;
  with SectionRootNode do begin
    ClearChilds;
    try
      SectionRootNode.LoadSLSFromAnyFile;
//      LoadTreeFromAnyFile( K_ExpandFileName(ObjInfo) );
    except
      on E: Exception do begin
        Result := false;
        ErrMessage := K_ArchiveCursor +
//            K_CurArchive.GetRefPathToObj( SectionRootNode, true ) + ' --> ' +
            K_GetPathToUObj( SectionRootNode, K_CurArchive, K_ontObjName, [K_ptfTryAltRelPath] ) + ' --> ' +
            E.Message;
        K_InfoWatch.AddInfoLine( ErrMessage );
        K_ShowMessage(ErrMessage);
        if not (E is TK_LoadUDFileError) then
          raise E.Create( ErrMessage );
      end;
    end;
  end;
end; //*** end of function K_LoadSection

//************************************************ K_LoadCurArchiveSection
//
function K_LoadCurArchiveSection( SectionRootNode : TN_UDBase ) : Boolean;
var
  SaveCursor : TCursor;
  UDCursor : TK_UDCursor;
  URNum : Integer;
  SLSRUsesList : TList;
begin
  Result := (SectionRootNode.ObjFlags and K_fpObjSLSRFlag) <> 0;
  if not Result then Exit;
  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

//*** Unlink Current Archive  Direct References
//    K_CurArchive.RefPath := K_udpLocalPathCursor;
//    K_CurArchive.BuildSubTreeRefObjs( );
  if SectionRootNode.DirLength > 0 then
    K_UnlinkDirectReferences( K_CurArchive, K_udpLocalPathCursorName, false );
//  K_CurArchive.RefPath := K_udpLocalPathCursor;

//*** Clear previous Section SubTree and Load New Section SubTree From File


  with SectionRootNode do begin
    ClearChilds;
    Include( K_UDGControlFlags, K_gcfSkipUnResoledRefInfo );
    if not K_GetPArchive(K_CurArchive).ArchFileFormatBin then
      Include( K_UDGControlFlags, K_gcfTrySLSRSDTFileLoad );
    Result := K_LoadSection( SectionRootNode );
    Exclude( K_UDGControlFlags, K_gcfTrySLSRSDTFileLoad );
    Exclude( K_UDGControlFlags, K_gcfSkipUnResoledRefInfo );
    RebuildVNodes(0);
  end;
//*** Check for Uses Sections in Current loaded SLSRoots and Load Unloaded Sections
  SLSRUsesList := nil;
  // Create List Of Unloaded Uses Sections
  SectionRootNode.SLSRAddUses( SLSRUsesList );

//*** Build Current Archive  Direct References
  UDCursor := K_UDCursorGet(K_udpLocalPathCursorName);
  UDCursor.SetRoot( K_CurArchive );
  // Load List Of Unloaded Uses Sections
  if not K_CurArchive.SLSRUsesListLoad( SLSRUsesList ) then begin
  // Build Direct References if no Uses Sections Found
    URNum := K_BuildDirectReferences( K_CurArchive, [K_bdrClearRefInfo, K_bdrClearURefCount] );
    if URNum > 0 then
      K_ShowUnresRefsInfo( K_CurArchive, URNum );
  end;

  K_SetArchiveCursor( K_CurArchive );

  Screen.Cursor := SaveCursor;
end; //*** end of function K_LoadCurArchiveSection

//************************************************ K_SaveCurArchiveSection
//
function K_SaveCurArchiveSection( SectionRootNode : TN_UDBase ) : Boolean;
var
  SaveCursor : TCursor;
begin
  Result := (SectionRootNode.ObjFlags and K_fpObjSLSRFlag) <> 0;
  if not Result then Exit;

  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  K_CurArchive.RefPath := K_udpLocalPathCursorName;

//*** Save Archive Section to File
  if K_IfTextCopyCreate() then
    K_UDGControlFlags := K_UDGControlFlags + [K_gcfArchSDTCopy];

  K_SetUDGControlFlags( 1, K_gcfSaveSLSRMode );
  with SectionRootNode do begin
    SaveTreeToAnyFile( K_CurArchive, K_ExpandFileName(ObjInfo), '', [], (K_fpObjSLSRFText and ObjFlags) <> 0 );
//    ClassFlags := ClassFlags and not K_ChangedSLSRBit;
  end;

  K_UDGControlFlags := K_UDGControlFlags - [K_gcfArchSDTCopy];
  K_SetUDGControlFlags( -1, K_gcfSaveSLSRMode );

//*** Restore Archive Cursor
  K_SetArchiveCursor( K_CurArchive );

  Screen.Cursor := SaveCursor;
end; //*** end of function K_SaveCurArchiveSection

//************************************************ K_LoadAllCurArchSections;
//  Load All Archive Sections
//
procedure K_LoadAllCurArchSections( AOnlyEmptySectionsLoad : Boolean = false );
var
  List : TList;
  i : Integer;
  SaveCursor : TCursor;
  UDCursor : TK_UDCursor;
  SLSRoot : TN_UDBase;
  TI : TK_VTIArray;
begin



  List := TList.Create;
  K_BuildSLSRList( K_CurArchive, List );
  if List.Count = 0 then Exit;

  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

//*** Save VTree Roots
  K_TreeViewsInfoGet( TI );
  K_TreeViewsUpdateModeSet;

//*** Unlink Current Archive  Direct References
  K_UnlinkDirectReferences( K_CurArchive, K_udpLocalPathCursorName, false );
  Include(K_UDGControlFlags, K_gcfSkipUnResoledRefInfo);
  if not K_GetPArchive(K_CurArchive).ArchFileFormatBin then
    Include( K_UDGControlFlags, K_gcfTrySLSRSDTFileLoad );

  // Mark as Destroy protection
  for i := 0 to List.Count - 1 do
    with TN_UDBase(List[i]) do
      ClassFlags := ClassFlags or K_SkipDestructBit;

  // Update Roots
  for i := 0 to List.Count - 1 do begin
    SLSRoot := TN_UDBase(List[i]);
    if SLSRoot.RefCounter <= 0 then Continue; // not actual SLSRoot
    K_CurArchive.RefPath := K_udpLocalPathCursorName;
    if (SLSRoot.DirLength <> 0) and AOnlyEmptySectionsLoad then Continue;
    SLSRoot.ClearChilds;
    K_LoadSection( SLSRoot );
  end;

  // Prepare SLSRoots List
  for i := 0 to List.Count - 1 do
    with TN_UDBase(List[i]) do begin
      ClassFlags := ClassFlags and not K_SkipDestructBit;
      if RefCounter > 0 then Continue;
      UDDelete() // not actual SLSRoot
    end;

  Exclude( K_UDGControlFlags, K_gcfSkipUnResoledRefInfo );
  Exclude( K_UDGControlFlags, K_gcfTrySLSRSDTFileLoad );

//*** Build Current Archive  Direct References
  UDCursor := K_UDCursorGet(K_udpLocalPathCursorName);
  UDCursor.SetRoot( K_CurArchive );
  i := K_BuildDirectReferences( K_CurArchive, [K_bdrClearRefInfo, K_bdrClearURefCount] );
  if i > 0 then
    K_ShowUnresRefsInfo( K_CurArchive, i );

  K_SetArchiveCursor( K_CurArchive );

  Screen.Cursor := SaveCursor;
  List.Free;

//*** Restore VTree View
  K_TreeViewsInfoRestore( TI );
  K_TreeViewsInfoFree( TI );
  K_TreeViewsUpdateModeClear( false );

end; //*** end of K_LoadAllCurArchSections

//************************************************ K_SaveAllCurArchSections;
//  Save All Archive Sections
//
//  Parameters
//  SaveFlags - [K_lsfSkipAllSLSR, K_lsfJoinAllSLSR] are not used
//
procedure K_SaveAllCurArchSections( SaveFlags : TK_UDTreeLSFlagSet =
                                 [K_lsfSkipJoinChangedSLSR,K_lsfSkipEmptySLSR] );
var
  SaveCursor : TCursor;
  TmpUDGControlFlags : TK_UDGControlFlagSet;
begin
  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  TmpUDGControlFlags := K_AddSaveLoadFlagsToGlobalFlags( SaveFlags );

  K_CurArchive.RefPath := K_udpLocalPathCursorName;

  if K_IfTextCopyCreate() then
    K_UDGControlFlags := K_UDGControlFlags + [K_gcfArchSDTCopy];

  K_CurArchive.SaveSubTreeSLSRToFile;

  K_SetArchiveCursor( K_CurArchive );

  K_UDGControlFlags := TmpUDGControlFlags;

  Screen.Cursor := SaveCursor;

end; //*** end of K_SaveAllCurArchSections


//************************************************ K_GetSelfArchive
//  Get Node Archive Node
//
function K_GetSelfArchive( Node : TN_UDBase ) : TN_UDBase;
begin
  Result := Node;
  while ( Result <> nil ) and
        ( not K_IsUDRArray(Result) or
//           not (Result is TK_UDRArray) or
          (TK_UDRArray(Result).R.ElemSType <> K_ArchiveDTCode.DTCode) ) do
    Result := Result.Owner;
end; //*** end of function K_GetSelfArchive

end.
