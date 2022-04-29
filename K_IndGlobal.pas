unit K_IndGlobal;

interface
uses
  IniFiles, SysUtils, Dialogs, Forms, Controls,  Classes, Grids, ComCtrls,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  K_MVObjs, K_DCSpace, K_UDT1, K_VFunc, K_IMVDar, K_FrRAEdit, K_CLib0, K_Types,
  N_BaseF, N_Types;

type TK_MenuObjsType = ( K_mtoIndMenus, K_mtoWinObjs );
type TK_ImportTSFlags = Set of ( K_itfUseExistedData, K_itfRebuildPublData,
                                 K_itfRebuildVectors, K_itfVerticalData,
                                 K_itfSaveIDsList, K_itfUseClipBoard,
                                 K_itfIgnoreUndefWarning, K_itfIgnoreUndefDump,
                                 K_itfBuildMSTables, K_itfSkipWEBObjs,
                                 K_itfSkipEQCSS, K_itfAddIDtoObjAliase,
                                 K_itfSkipNotWEBObjs, K_itfSkipDataToMapBinding,
                                 K_itfImportFromGSystemOnly   );

//**************************************
//***        Global Routines
//**************************************

procedure K_OnGlobalChange( VNode : TN_VNode = nil; RR : TN_VTreeNodeRenameResult = [] );
{
procedure K_VTFOnAction_Edit( AParent: TWinControl; Node: TTreeNode;
            EventType: integer; Button: TMouseButton; Shift: TShiftState );
}
procedure K_CheckEditResult( Form : TForm; wasChanged : Boolean );
//procedure K_DocumentNodeEditStart( vnd : TN_VNode );
function  K_GetMVDarObjSysFolder( ClassFlags : Integer ) : TN_UDBase;
function  K_IsMVDarFolderType( SysType : TK_MVDARSysType ): Boolean;
function  K_IsMVdarUserFolder( UDP : TN_UDBase ) : Boolean;
function  K_MVDarNewUserNodeAdd( ObjSysType : TK_MVDARSysType;
                                dir, parent : TN_UDBase;
                                var status : string;
                                NewObjAliase : string = '';
                                NewObjName : string = '';
                                SpecNode : TN_UDBase = nil ): TN_UDBase;
function  K_TestMVDarRelPathSubTree( TestNode : TN_UDBase ) : Boolean;
//procedure K_MVLinkNewDataToSubTree( OldDataRoot, NewDataRoot, RefRoot : TN_UDBase; UnRelinked : TStrings = nil );
function  K_MVDarNodeCopyAdd( AParent : TN_UDBase; const DE : TN_DirEntryPar;
            CopySubTreeFlags : TK_CopySubTreeFlags; var status : string ): TN_UDBase;
function  K_GetMVDarSysRoot : TN_UDBase;
function  K_GetDocumentDir( ClassType : Integer; Root : TN_UDBase = nil;
                                Index : Integer = -2 ) : TN_UDBase;
function  K_GetMVDarSysFolder( ObjSysType : TK_MVDARSysType; Root : TN_UDBase = nil ) : TN_UDBase;

procedure K_MVDArVListPrepareNew(VList : TList);
function  K_MVImportTab0( ImportTSFlags : TK_ImportTSFlags;
                MVFolder : TN_UDBase; SL : TStrings; SMF : TN_StrMatrFormat;
                TabImportIni : TMemIniFile; const SourceName : string;
                PNodesList : PTStrings = nil;
                ShowWarning : TK_MVShowMessageProc = nil ) : Boolean;
function  K_MVImportTab( ImportTSFlags : TK_ImportTSFlags;
        MVFolder : TN_UDBase; SL : TStrings; SMF : TN_StrMatrFormat;
        SourceName, TabImportIniFName : string; PNodesList : PTStrings = nil;
        ShowWarning : TK_MVShowMessageProc = nil ) : Boolean;
function  K_MVImportTabByIniStrings( ImportTSFlags : TK_ImportTSFlags;
        MVFolder : TN_UDBase; SL : TStrings; SMF : TN_StrMatrFormat;
        SourceName : string; IniStrings : TStrings; PNodesList : PTStrings = nil;
        ShowWarning : TK_MVShowMessageProc = nil ) : Boolean;
function  K_IniHTMParGet( const ParName : string; ParDef : string = '' ) : string;
procedure K_CallMVTEExecute( CurUDSel : TN_UDBase );
procedure K_InitMVVAttrsColorsSet( PMVVAttrs : TK_PMVVAttrs; ColorsSetLPath : string;
                                   ColorsSetsUDRoot : TN_UDBase;
                                   ColorsSetIniText : string; WList : TStringList );
procedure K_PrepMVASubTree( AUDRoot : TN_UDBase; AScanRootNode : Boolean );
procedure K_BuildMVAFileFromCurArchUDObjs( ArchFName : string;
                                     PUDObjs : TN_PUDBase; UDCount : Integer );
type TK_MSWDocCreateAttrsFlags = Set of (
  K_dcaShowStruct,
  K_dcaShowMaps,
  K_dcaShowHists,
  K_dcaShowTables,
  K_dcaPortraitPage );
function K_GetMSWDocCreateAttrs( var WDAttrs : TK_MVMSWDVAttrs;
                    MSWDocCreateAttrsFlags : TK_MSWDocCreateAttrsFlags ) : boolean;

type TK_UDVectorEditCont = record
  RAEDFC     : TK_RAEditFuncCont;
  FFDClassName : string;
  FFTClassName : string;
  FTargetCSS: TK_UDDCSSpace;
end;
type TK_PUDVectorEditCont = ^TK_UDVectorEditCont;

var
  K_wasChanged : Boolean;
  K_MVDARCurFileName : String;
  K_UDVectorEditCont : TK_UDVectorEditCont; // UDVector Edit Context
  K_UDVHTMFileRefEditCont : TK_UDVectorEditCont; // UDVector Edit Context
//  K_MVDarVTree : TN_VTree;

var
  K_UDRACPEditCont  : TK_RAEditFuncCont; // Color Path Edit Context
  K_UDRAWDEditCont  : TK_RAEditFuncCont; // Window Description Edit Context
  K_UDRAWSWEditCont : TK_RAEditFuncCont; // WEB Structure WindowEdit Context
function K_EditUDVectorFunc( var UDVector; PDContext: Pointer ) : Boolean;
function K_EditDSSVectorFunc( var DSSVector; PDContext: Pointer ) : Boolean;

implementation

uses
  Math, Clipbrd, Windows,
  N_ClassRef, N_Lib0, N_Lib1,
{$IFDEF K_MVDAR} // MVDar Project
  N_VRMain2F,
{$ENDIF}
  {K_DTE1,} K_UDConst, K_UDT2, K_UDC,
  K_FSelectUDB,
  K_IFunc, K_STBuf,
  K_Arch, K_TSImport4,
  {K_FDCSpace, K_FDCSSpace,}  K_FDCSProj, {K_FUDVTab,} K_FUDV,
  {K_FMVTabEd,} K_SCript1, K_FRAEdit, K_MVMap0, // K_FMVCart,
  K_IWatch, {K_FMVFolderCopy,} K_SBuf,
  {K_TSImport1,} K_TSImport0, K_CLib;


function K_EditUDVectorFunc( var UDVector; PDContext: Pointer ) : Boolean;
begin
  with TK_PUDVectorEditCont(PDContext)^ do
    if TK_UDVector(UDVector).IsDCSProjection then
      Result := K_EditDCSProj( TK_UDVector(UDVector), RAEDFC.FOwner, RAEDFC.FOnGlobalAction )
    else
      Result := K_EditUDVector( TK_UDVector(UDVector), false, '', 'Значение',
                                [K_ramColVertical,K_ramSkipResizeHeight,K_ramSkipResizeWidth], FFDClassName, FFTClassName,
                                RAEDFC.FOwner, RAEDFC.FOnGlobalAction, FTargetCSS );
end;

function K_EditDSSVectorFunc( var DSSVector; PDContext: Pointer ) : Boolean;
begin
  with TK_PUDVectorEditCont(PDContext)^ do
    Result := K_EditDSSVector( TK_DSSVector(DSSVector), true, '', 'Значение',
                                [K_ramColVertical], FFDClassName, FFTClassName,
                                RAEDFC.FOwner, RAEDFC.FOnGlobalAction, FTargetCSS );
end;


//**************************************** K_OnGlobalChange ***
// Set MVDAR DataChanged flag
//
procedure K_OnGlobalChange( VNode : TN_VNode = nil; RR : TN_VTreeNodeRenameResult = [] );
begin
//  ChangedNode.SetChangedSubTreeFlag;
  if (VNode <> nil) and (VNode.VNParent <> nil) then
    with VNode, VNParent.VNUDObj do begin
      if K_vrrObjName in RR then
        SetUniqChildName( VNUDObj );
      if K_vrrObjAliase in RR then
        SetUniqChildName( VNUDObj, K_ontObjAliase );
    end;
  K_SetArchiveChangeFlag;
end; // end of procedure K_OnGlobalChange

//**************************************** K_CheckEditResult ***
// empty cartogram tree build routine
//
procedure K_CheckEditResult( Form : TForm; wasChanged : Boolean );
var res : word;
begin
  if (Form.ModalResult <> mrOk) and wasChanged then
  begin
    res := MessageDlg( 'Данные были изменены - сохранить?',
         mtConfirmation, [mbYes, mbNo], 0);
    if res = mrYes then
      Form.ModalResult := mrOk;
  end;
end; // end of procedure K_CheckEditResult

{
//**************************************** K_DocumentNodeEditStart ***
// View/Edit start  for specified UD node
//
procedure K_DocumentNodeEditStart( vnd : TN_VNode );
var
  udn : TN_UDBase;
  wasNewEdited : Boolean;
  RebuildMode : Integer;
  NodePath : string;
  RFC : TK_RAEditFuncCont;

begin
  NodePath := vnd.GetPath();


  wasNewEdited := false;
  udn := vnd.VChild;

  RebuildMode := 0;
  if not K_EditUDByGEFunc( udn, wasNewEdited, K_CurMainForm, K_CurGAProc, false ) then begin
    if K_IsUDRArray(udn) then begin
      K_ClearRAEditFuncCont( @RFC );
      with RFC do begin
        FModeFlags := [K_ramFillFrameWidth];
        FOwner := K_CurMainForm;
        FOnGlobalAction := K_CurGAProc;
      end;
      wasNewEdited := K_EditUDRAFunc0( udn, @RFC );
    end;
  end;
  if wasNewEdited then begin //*** change visual representation
    K_TreeViewsUpdateModeSet;
    udn.RebuildVNodes( RebuildMode );
    K_MVDarVTree.SetPath( NodePath );
    K_TreeViewsUpdateModeClear;
//    udn.SetChangedSubTreeFlag;
    K_SetChangeSubTreeFlags( udn );
  end;
end; // end of procedure K_DocumentNodeEditStart
}

//**************************************** K_GetMVDarObjSysFolder ***
// cartogram tree new node add routine
// detected obj type by selected obj dir type
//
function K_GetMVDarObjSysFolder( ClassFlags : Integer ) : TN_UDBase;
var
  objDirType : Integer;
  DirCode : TK_MVDARSysType;

begin
  Result := nil;
  objDirType := -1;
  DirCode := TK_MVDARSysType(0);

  if ClassFlags = K_UDMVTableCI then // new Data Table
  begin
    Exit;
//    DirCode := K_msdTables;
//    objDirType := -2;
  end;

  if objDirType <> -1 then begin
    if K_CurMVDARRoot = nil then
      Result := K_GetDocumentDir( objDirType )  // Old Archive
    else
      Result := K_GetMVDarSysFolder( DirCode ); // New Archive
  end;
end; // end of function K_GetMVDarObjSysFolder


//**************************************** K_IsMVDarFolderType ***
// Test if MVObj type  is Folder
//
function K_IsMVDarFolderType( SysType : TK_MVDARSysType ): Boolean;
begin
  case SysType of
    K_msdWebFolder, K_msdFolder : Result := true;
  else
    Result := false;
  end;
end; // end of procedure K_IsMVDarFolderType

//**************************************** K_IsMVdarUserFolder
// Check if Node is user folder
//
function K_IsMVdarUserFolder( UDP : TN_UDBase ) : Boolean;
begin
  Result := (UDP <> nil) and                                // Node is assigned
    ( (K_CurUserRoot = UDP)                              or // Node is User Root
      K_IsMVDarFolderType( K_MVDarGetUserNodeType(UDP) ) or // Node is MVDar Folder
      (K_GetSLSRootPAttrs(UDP) <> nil) );                   // Node is SLSRoot with Uses
end; // end of function K_IsMVdarUserFolder

//**************************************** K_MVDarNewUserNodeAdd0 ***
//
procedure K_MVDarNewUserNodeAdd0( ObjSysType : TK_MVDARSysType; SysDirNode, ParentNode, NNode : TN_UDBase;
                                NewObjAliase : string = ''; NewObjName : string = '';
                                Suffix : string = ''; AddToSysFolder : Boolean = true );
var
  ObjTypeAliase : string;
  IndParent, IndServ : Integer;
  NoParent : Boolean;
begin

  ObjTypeAliase := K_MVDARSysObjALiases[Ord(ObjSysType)];
  if NewObjAliase = '' then
    NNode.ObjAliase := 'Нов'+suffix+' '+ObjTypeAliase
  else
    NNode.ObjAliase := NewObjAliase;
  if NewObjName = '' then
    NNode.ObjName := K_MVDARSysObjNames[Ord(ObjSysType)]+IntToStr(Integer(NNode))
  else
    NNode.ObjName := NewObjName;

//??? check if realy needed
{
  if not ParentIsUserFolder       and
     (ObjSysType <> K_msdFolder2) and       // not old MVDar folder
     (ObjSysType <> K_msdFolder) then begin // not new MVDar folder
}
  if (ParentNode <> SysDirNode) and
     (Ord(ObjSysType) <= Ord(K_msdFolder)) and
     not K_IsMVdarUserFolder( ParentNode )  then begin
// can add only to Section - if Parent is not section then add to SysFolder
    NoParent := (ParentNode = nil); // Special case - add only to system folder
    ParentNode := SysDirNode;
    if not NoParent then
      SysDirNode := nil;
  end;
//??? check if realy needed

  K_TreeViewsUpdateModeSet;

  if (SysDirNode <> nil) then begin
  //*** Add to Sys Folder - to object Owner
    if AddToSysFolder then // already added to SysFolder (Copy Mode)
      SysDirNode.AddOneChild( NNode );
    IndServ := SysDirNode.DirHigh;
    SysDirNode.SetUniqChildName( NNode );
//??    if SysDirNode = ParentNode then
//??      ParentNode.SetUniqChildName( NNode, K_ontObjAliase );

    if AddToSysFolder then // already added to SysFolder (Copy Mode)
      SysDirNode.AddChildVnodes( IndServ )
    else
      NNode.RebuildVNodes( 1 );
//    if not K_IsMVDarFolderType( ObjSysType ) then
//      SysDirNode.PutDEField( IndServ, K_fpDEObjOwner, K_DEFisFlags );
  end;
//*** Add to Parent User Folder
  if (ParentNode <> nil) and (SysDirNode <> ParentNode) then begin
    ParentNode.AddOneChild( NNode );
    IndParent := ParentNode.DirHigh;
    if SysDirNode = nil then
      ParentNode.SetUniqChildName( NNode );

    ParentNode.SetUniqChildName( NNode, K_ontObjAliase );

    ParentNode.AddChildVnodes( IndParent );
//    if ParentNode <> NNode.Owner then
//      ParentNode.SetChangedSubTreeFlag;

    if (ParentNode.LastVNode <> nil) and
       (ParentNode.LastVNode.VNTreeNode <> nil) then
      ParentNode.LastVNode.VNTreeNode.Expanded := true;
  end;
  K_TreeViewsUpdateModeClear(false);

  K_SetChangeSubTreeFlags( NNode );
  K_OnGlobalChange;

end; // end of procedure K_MVDarNewUserNodeAdd0

//**************************************** K_MVDarNewUserNodeAdd ***
//
function K_MVDarNewUserNodeAdd( ObjSysType : TK_MVDARSysType;
                                dir, parent : TN_UDBase;
                                var status : string;
                                NewObjAliase : string = '';
                                NewObjName : string = '';
                                SpecNode : TN_UDBase = nil ): TN_UDBase;
var
  UDDir : TN_UDBase;
  suffix : string;

  function GetObj( TypeName : string; Leng : Integer = 1;
    UDClassInd : Integer = K_UDRArrayCI; CallInitRoutine : Boolean = true ) : TN_UDBase;
  var
    Ind : Integer;
  begin
    with K_GetMVDarSysFolder( K_msdObjTemplates ) do begin
      Ind := IndexOfChildType( UDClassInd );
      if Ind >= 0 then
        Result := DirChild( Ind ).Clone
      else
        Result := K_CreateUDByRTypeName( TypeName, Leng, UDClassInd, CallInitRoutine );
    end;
  end;

begin
  Result := nil;

  if (dir <> parent)  and
     (parent <> nil)  and
     (   // New Node Type                     // New Node Can Be Added
       (parent.AddChildToSubTree( nil,[] ) and not parent.CanAddChildByPar( Ord(ObjSysType) )) or
         // Old NodeTypes
       (Ord(ObjSysType) <= Ord(K_msdFolder)) and
       not K_IsMVdarUserFolder( parent )
     ) then begin
    Status := 'Не удалось создать объект';
    Exit;
  end;
  suffix := 'ый';

{
  if ObjSysType = K_msdTables then begin // new Data Table
    Result := TK_UDMVTable.Create;
    suffix := 'ая';
  end else
}

  if ObjSysType = K_msdWebCartWins then begin // new Data Cartogram
    suffix := 'ая';
    UDDir := K_GetMVDarSysFolder(K_msdMapDescrs);
    if SpecNode = nil then begin
      if UDDir.DirLength = 1 then
        SpecNode := UDDir.DirChild(0)
      else if UDDir.DirLength() > 1 then begin
        SpecNode := K_SelectUDB( UDDir, '',
          nil, SpecNode, 'Выбор базовой карты' );
      end;
    end;
    if SpecNode <> nil then begin
      Result := K_MVMCartogramCreate( SpecNode );
    end else begin
      Status := 'Не задана базовая карта';
    end
  end else if ObjSysType = K_msdWebCartGroupWins then begin // new Data Cartogram
    Result := GetObj( 'TK_MVWebCartGroupWin', 1, K_UDMVWCartGroupWinCI );
    suffix := 'ая';
  end else if ObjSysType = K_msdMapDescrs then begin // new Map Description
    Result := GetObj( 'TK_MVMapDescr', 1, K_UDMVMapDescrCI );
    suffix := 'ый';
  end else if ObjSysType = K_msdMLDColorFills then begin // new Map Description
    Result := GetObj( 'TK_MVMLDColorFill', 1, K_UDMVMLDColorFillCI );
    suffix := 'ый';
  end else if ObjSysType = K_msdColorPaths then begin // new Data Color Path
    Result := K_CreateUDByRTypeCode( Ord(nptColor), 1, K_UDRArrayCI );
    Result.ImgInd := 23;
    suffix := 'ый';
  end else if ObjSysType = K_msdWebFolder then begin // new Web Folder
    Result := GetObj( 'TK_MVWebFolder', 1, K_UDMVWFolderCI );
    suffix := 'ая';
  end else if ObjSysType = K_msdWebVTreeWins then begin // new Web Struct Window
    Result := GetObj( 'TK_MVWebVTreeWin', 1, K_UDMVWVTreeWinCI );
    suffix := 'ый';
  end else if ObjSysType = K_msdWebLDiagramWins then begin // new Web Line Diagram Window
    Result := GetObj( 'TK_MVWebLDiagramWin', 1, K_UDMVWLDiagramWinCI );
    suffix := 'ая';
  end else if ObjSysType = K_msdWebTableWins then begin // new Web Table Window
    Result := GetObj( 'TK_MVWebTableWin', 1, K_UDMVWTableWinCI );
    suffix := 'ая';
  end else if ObjSysType = K_msdWebWinGroups then begin // new Web Windowed Objects Group
    Result := GetObj( 'TK_MVWebWinGroup', 1, K_UDMVWWinGroupCI );
    suffix := 'ая';
  end else if ObjSysType = K_msdWebHTMWins then begin // new Web HTM-text Window
    Result := GetObj( 'TK_MVWebHTMWin', 1, K_UDMVWHTMWinCI );
    suffix := 'ый';
  end else if ObjSysType = K_msdWebHTMRefWins then begin // new Web HTM-text Window
    Result := GetObj( 'TK_MVWebHTMRefWin', 1, K_UDMVWHTMWinCI );
    Inc(Result.ImgInd);
    suffix := 'ый';
  end else if ObjSysType = K_msdWebVHTMWins then begin // new Web HTM-text Window
    Result := GetObj( 'TK_MVWebVHTMWin', 1, K_UDMVWVHTMWinCI );
    with TK_PDVector(TK_UDVector(Result).R.P)^ do
      D := K_RCreateByTypeCode (Ord(nptString));
    suffix := 'ый';
  end else if ObjSysType = K_msdWebVHTMRefWins then begin // new Web HTM-text Window
    Result := GetObj( 'TK_MVWebVHTMRefWin', 1, K_UDMVWVHTMWinCI );
    Inc(Result.ImgInd);
    with TK_PDVector(TK_UDVector(Result).R.P)^ do
      D := K_RCreateByTypeCode (Ord(nptString));
    suffix := 'ый';
  end else if ObjSysType = K_msdFolder then begin // new User Folder
    Result := TK_UDMVFolder.Create;
    suffix := 'ая';
  end else if ObjSysType = K_msdVWLayouts then begin // MVVWLayout
    Result := TK_UDMVVWLayout.Create;
    suffix := 'ая';
  end else if ObjSysType = K_msdVWindows then begin // MVVWindow
    Result := GetObj( 'TK_MVVWindow', 1, K_UDMVVWindowCI );
    suffix := 'ое';
  end else if ObjSysType = K_msdVWFrames then begin // MVVWFrame
    Result := GetObj( 'TK_MVVWFrame', 1, K_UDMVVWFrameCI );
    suffix := 'ый';
  end else if ObjSysType = K_msdVWFrameSets then begin // MVVWFrameSet
    Result := GetObj( 'TK_MVVWFrameSet', 1, K_UDMVVWFrameSetCI );
    suffix := 'ый';
  end else if ObjSysType = K_msdWebSite then begin // WebSite
    Result := GetObj( 'TK_MVWebSite', 1, K_UDMVWSiteCI );
    suffix := 'ая';
  end else if ObjSysType = K_msdBTables then begin // new Data Vectors Table
    Result := K_CreateUDByRTypeCode( K_GetTypeCodeSafe('TK_MVTable').All, 1, K_UDMVTableCI );
    suffix := 'ая';
  end else if ObjSysType = K_msdSValSets then begin // new Data Vectors Table
    Result := K_CreateUDByRTypeCode( K_GetTypeCodeSafe('TK_MVDataSpecVal').All, 0, K_UDRArrayCI );
    suffix := 'ый';
  end else if ObjSysType = K_msdMSOParams then begin // new MS Word Document Generation Params
    Result := K_CreateUDByRTypeCode( K_GetTypeCodeSafe('TK_MVMSWDVAttrs').All, 0, K_UDRArrayCI );
    suffix := 'ый';
  end else if ObjSysType = K_msdMVRComAttrs then begin // new Common Data Representation Attrs
    Result := K_CreateUDByRTypeCode( K_GetTypeCodeSafe('TK_MVRComAttrs').All, 0, K_UDRArrayCI );
    suffix := 'ые';
  end else if ObjSysType = K_msdMVRCSAttrs then begin // new Common Data Representation for DCSpace Attrs
    Result := K_CreateUDByRTypeCode( K_GetTypeCodeSafe('TK_MVRCSAttrs').All, 0, K_UDRArrayCI );
    suffix := 'ые';
  end else if ObjSysType = K_msdMVCorPict then begin // new 2D Representation
    Result := K_CreateUDByRTypeCode( K_GetTypeCodeSafe('TK_MVCorPict').All, 1, K_UDMVCorPictCI );
    suffix := 'ый';
  end;

  if Result <> nil then begin

    K_MVDarNewUserNodeAdd0( ObjSysType, Dir, Parent, Result, NewObjAliase, NewObjName, Suffix );

    K_InitMVObjectCaptions( Result, ObjSysType );

    Status := 'Создан объект "'+Result.ObjName+':'+Result.ObjAliase+'" типа "' + K_MVDARSysObjALiases[Ord(ObjSysType)] + '"';
    K_InfoWatch.AddInfoLine( Status, K_msInfo );
  end;
end; // end of function K_MVDarNewUserNodeAdd

{
//**************************************** K_MVDarNodeCopyAdd0 ***
// cartogram tree copy node add routine
//
function K_MVDarNodeCopyAdd0( CopyFlags : TK_MVCopyObjsFlags; ParentNode, SourceNode : TN_UDBase; var status : string ): TN_UDBase;
var
  SysDir : TN_UDBase;
  treeMerge  : TK_TreeMerge;
  ObjSysType : TK_MVDARSysType;
  CopyAliase : string;
  DumpLine : string;
  i, h : Integer;
  AddToSysFolderFlag : Boolean;
  ChildsCopyFlags : TK_MVCopyObjsFlags;
  ChildIsFolder : Boolean;
  ref : TK_UDRefsRep;
// dnum : Integer;

begin
  Result := nil;
  ObjSysType := K_MVDarGetUserNodeType( SourceNode );

  if ObjSysType <> K_msdUndef then begin
    if K_IsMVDarFolderType( ObjSysType ) then begin
      SysDir := ParentNode;
      AddToSysFolderFlag := true;
      Result := SourceNode.Clone;
    end else begin
      SysDir := K_GetMVDarSysFolder( ObjSysType );
      AddToSysFolderFlag := false;
      treeMerge := TK_TreeMerge.Create;
      treeMerge.updateFlags.AllBits := 0;
      treeMerge.UpdateDir( SysDir, SysDir, 0, -1, SysDir.IndexOfDEField( SourceNode, K_isChild ),
                         1, K_fuUseCurrent, K_fuUseCurrent );
      treeMerge.Free;
      Result := SysDir.DirChild(SysDir.DirHigh());
    end;

    CopyAliase := SourceNode.GetUName;
    DumpLine := 'Создана копия объекта "' + CopyAliase +
                                '" типа "' + K_MVDARSysObjALiases[Ord(ObjSysType)] + '"';
    if not (K_mvcCopyChildsAction in CopyFlags) then begin
      CopyAliase := 'Копия '+ CopyAliase;
      Status := DumpLine;
    end;
    K_MVDarNewUserNodeAdd0( ObjSysType, SysDir, ParentNode, Result,
      CopyAliase, '', '', AddToSysFolderFlag );
    K_InfoWatch.AddInfoLine( DumpLine, K_msInfo );

    if AddToSysFolderFlag then begin
      CopyFlags := CopyFlags - [K_mvcCopyChildsAction];
      if CopyFlags = [] then begin
        CopyFlags := K_GetMVFolderCopyFLags( CopyFlags,
                'Параметры копирования каталога "'+SourceNode.ObjAliase+'"' );
      end;
      ChildsCopyFlags := [];
      if CopyFlags <> [] then begin
        if (K_mvcCopyFullSubTree in CopyFlags) then
          ChildsCopyFlags := [K_mvcCopyFolderChilds,K_mvcCopySubFolders,K_mvcCopyFullSubTree]
        else if (K_mvcCopySubFolders in CopyFlags) then
          ChildsCopyFlags := [K_mvcCopySubFolders];
      end;
      ChildsCopyFlags := ChildsCopyFlags + [K_mvcCopyChildsAction];
      h := SourceNode.DirHigh;
      for i := 0 to h do begin
        ref.OldChild := SourceNode.DirChild(i);
        ChildIsFolder := K_IsMVDarFolderType( K_MVDarGetUserNodeType( ref.OldChild ) );
        if (K_mvcCopyFolderChilds in CopyFlags) or
           ( ChildIsFolder and
             (K_mvcCopySubFolders in CopyFlags) ) then begin
          ref.NewChild := K_MVDarNodeCopyAdd0( ChildsCopyFlags, Result, ref.OldChild, DumpLine );
          if (K_mvcCopyFullSubTree in CopyFlags) and
             not ChildIsFolder then
            K_RSTNAddPair( ref.OldChild, ref.NewChild );
        end else
          Result.AddOneChildV(ref.OldChild);
      end;
    end;
  end else begin
    SysUtils.beep;
    K_ShowMessage( 'Этот объект не подлежит копированию ...' );
  end
end; // end of function K_MVDarNodeCopyAdd0
}

//**************************************** K_TestMVDarRelPathSubTree ***
// Link New Data SubTree to Reference SubTree Using Old Data SubTree
//
function K_TestMVDarRelPathSubTree( TestNode : TN_UDBase ) : Boolean;
begin
  Result := K_IsMVdarUserFolder( TestNode ) or
           (K_MVDarGetUserNodeType(TestNode) = K_msdUndef);

end; // end of function K_TestMVDarRelPathSubTree

{
//**************************************** K_MVLinkNewDataToSubTree ***
// Link New Data SubTree to Reference SubTree Using Old Data SubTree
//
procedure K_MVLinkNewDataToSubTree( OldDataRoot, NewDataRoot, RefRoot : TN_UDBase; UnRelinked : TStrings = nil );
var
 NameType : TK_UDObjNameType;
begin
//*** Store RelPathes to OldData SubTree in "RefPath" Nodes Field
  OldDataRoot.RefPath := K_udpLocalPathCursor;
  OldDataRoot.BuildSubTreeRelPaths(K_TestMVDarRelPathSubTree, K_ontObjUName);
//*** Replace Web SubTree References to Old Data SubTree Objects with References
//*** to corresponding New Data SubTree Objects, Build List Of Unrelaced Nodes
//*** if List Object (UnRelinked) is specified
  with K_UDCursorGet( K_udpLocalPathCursor ) do begin
    NameType := ObjNameType;
    ObjNameType := K_ontObjUName;
    SetRoot( NewDataRoot );
    ObjNameType := NameType;
  end;
  RefRoot.ReplaceSubTreeRelPaths( '', UnRelinked, K_ontObjUName );
//*** Clear Pathes stored in OldData SubTree in "RefPath" Nodes Field


  K_ClearSubTreeRefInfo( OldDataRoot, [K_criClearMarker,K_criClearAll] );
//  OldDataRoot.ClearSubTreeRefInfo( true, true );
  OldDataRoot.RebuildVnodes;
  NewDataRoot.RebuildVnodes;
end; // end of procedure K_MVLinkNewDataToSubTree
}

//**************************************** K_MVDarNodeCopyAdd ***
// cartogram tree copy node add routine
//
function K_MVDarNodeCopyAdd( AParent : TN_UDBase; const DE : TN_DirEntryPar;
           CopySubTreeFlags : TK_CopySubTreeFlags; var status : string ): TN_UDBase;
var
  WDE : TN_DirEntryPar;
//  CopySubTreeFlags : TK_CopySubTreeFlags;
begin
//  vnode.GetDirEntry( DE );
  if AParent.CanAddChildByPar( Ord(K_MVDarGetUserNodeType( DE.Child )) ) then begin
    // Parent - New Node Type - Implements Add/Remove Interface
//    CopySubTreeFlags := [K_mvcCopyChilds];
//    CopySubTreeFlags := [K_mvcCopySelf, K_mvcCopyOwnedChilds];
    Result := nil;
    WDE := DE;
    if AParent.AddChildToSubTree( @WDE, CopySubTreeFlags ) then
      Result := WDE.Child;
  end else begin
//    Result := K_MVDarNodeCopyAdd0( [], AParent, DE.Child, status );
//    if Result <> nil then
//      K_RSTNExecute( Result );
    Result := nil;
    K_ShowMessage( 'Этот объект не подлежит копированию ...' );
  end

end; // end of function K_MVDarNodeCopyAdd


//**************************************** K_GetMVDarSysRoot ***
// build sight members assignment to archives
//
function  K_GetMVDarSysRoot : TN_UDBase;
begin
  if K_CurMVDARRoot = nil then
     // old mode
    Result := K_ArchsRootObj.DirChild(0)
  else
    Result := K_CurMVDARRoot;
end; // end of function  K_GetMVDarSysRoot

//**************************************** K_GetDocumentDir ***
// build sight members assignment to archives
//
function  K_GetDocumentDir( ClassType : Integer; Root : TN_UDBase = nil;
                                Index : Integer = -2 ) : TN_UDBase;
var wudb : TN_UDBase;
begin
   if Root = nil then
     wudb := K_GetMVDarSysRoot
   else
     wudb := Root.DirChild(0);

   if Index = -2 then
     Index := wudb.IndexOfChildType(ClassType)
   else if Index = -1 then
     Index := wudb.DirHigh;
   Result := wudb.DirChild( Index );
end; // end of function  K_GetDocumentDir

//**************************************** K_GetMVDarSysFolder ***
// search for specified Sys Archive Folder
//
function  K_GetMVDarSysFolder( ObjSysType : TK_MVDARSysType; Root : TN_UDBase = nil ) : TN_UDBase;
begin
  if Root = nil then Root := K_GetMVDarSysRoot;
  if Ord(ObjSysType) <= High(K_MVDARSysDirNames) then
    Result := Root.DirChildByObjName( K_MVDARSysDirNames[Ord(ObjSysType)] )
  else
    Result := nil;
end; // end of function  K_GetMVDarSysFolder

//**************************************** K_MVDArVListPrepareNew ***
// Clear special node from VList and correct owner for "Sections"
//
procedure K_MVDArVListPrepareNew(VList : TList);
var
  i : Integer;
  DE : TN_DirEntryPar;

begin
  K_TreeViewsUpdateModeSet;
  for i := VList.Count - 1 downto 0  do
  begin
    TN_VNode(VList.Items[i]).GetDirEntry( DE );
    if ((DE.Child.ObjFlags and K_fpObjSFolder) = 0)     and
       (K_MVDarGetUserNodeType(DE.Child) <> K_msdUndef) and
       (DE.Child <> K_CurUserRoot) then begin //*** prepare List Node

//       ( K_IsMVdarUserFolder(DE.Child)      or
//         (K_IsMVdarUserFolder( DE.Parent )) or
//         (K_GetMVDarSysFolder(K_MVDarGetUserNodeType( DE.Child )) <> nil) ) then begin //*** prepare List Node

//??      if K_IsMVdarUserFolder(DE.Child) then
//??        DE.Child.Owner := nil; // clear owner for future insertion in new root
    end else                                               //*** UnMark wrong Node
      TN_VNode(VList.Items[i]).UnMark();
  end;
  K_TreeViewsUpdateModeClear;
end; // end of procedure K_MVDArVListPrepareNew

//**************************************** K_MVImportTab0
// Import Table Structure
//
function  K_MVImportTab0( ImportTSFlags : TK_ImportTSFlags;
        MVFolder : TN_UDBase; SL : TStrings; SMF : TN_StrMatrFormat;
        TabImportIni : TMemIniFile; const SourceName : string; PNodesList : PTStrings = nil;
        ShowWarning : TK_MVShowMessageProc = nil ) : Boolean;

var
  StrMatr: TN_ASArray;
  MessageString : string;
  PrevSkipUndoState : Boolean;

  procedure AShowWarning( MesStatus : TK_MesStatus );
  begin
    if Assigned(ShowWarning) then ShowWarning( MessageString, MesStatus );
  end;

begin
  Result := false;
  if MVFolder = nil then
    MVFolder := K_CurUserRoot;
  if (K_MVDarGetUserNodeType( MVFolder ) <> K_msdFolder) and
     ((MVFolder.ObjFlags and K_fpObjSLSRFlag) = 0) then begin
    MessageString := 'Объект '+MVFolder.GetUName+' не подходит для размещения загружамых данных';
    AShowWarning(K_msError);
  end else begin
    MessageString := 'ИСТОЧНИК "'+SourceName+'" - начат импорт табличной структуры';
    AShowWarning(K_msInfo);
    MessageString := '';
    PrevSkipUndoState := K_SkipArchUndoMode;
    K_SkipArchUndoMode := true;
    try
      K_TreeViewsUpdateModeSet;

      if (SL.Count > 0) and (K_StrStartsWith( '<FGTable', SL[0] )) then
        Result := K_MVImportTabStruct4( MVFolder, SL, TabImportIni, SourceName, ShowWarning )
      else if not (K_itfImportFromGSystemOnly in ImportTSFlags) then begin
        K_LoadSMatrFromStrings( StrMatr, SL, SMF );
    {
          Result := K_MVImportTabStruct1( ImportTSFlags, MVFolder, MVFolder, StrMatr,
                                          TabImportIni, SourceName, PNodesList,
                                          ShowWarning )
    }
          Result := K_MVImportTabStruct0( ImportTSFlags, MVFolder, MVFolder, StrMatr,
                                          TabImportIni, SourceName, PNodesList,
                                          ShowWarning )
      end else begin
        MessageString := 'ИСТОЧНИК "'+SourceName+'" - не формат G-System';
        AShowWarning(K_msWarning);
        K_TreeViewsUpdateModeClear(false);
        Exit;
      end;
    except
      Result := false;
    end;

    K_TreeViewsUpdateModeClear(false);
    K_SkipArchUndoMode := PrevSkipUndoState;
//      MVFolder.SetChangedSubTreeFlag;
//      K_SetChangeSubTreeFlags( MVFolder, [K_cstfSetDown, K_cstfSetSLSRChangeFlag] );
    K_SetArchiveChangeFlag;
    if Result then begin
      MessageString := 'ИСТОЧНИК "'+SourceName+'" - импорт завершен';
      AShowWarning(K_msInfo);
    end;
  end;
end; // end of function  K_MVImportTab0

//**************************************** K_MVImportTab
// Import Table Structure
//
function  K_MVImportTab( ImportTSFlags : TK_ImportTSFlags;
        MVFolder : TN_UDBase; SL : TStrings; SMF : TN_StrMatrFormat;
        SourceName, TabImportIniFName : string; PNodesList : PTStrings = nil;
        ShowWarning : TK_MVShowMessageProc = nil ) : Boolean;

var
  TabImportIni : TMemIniFile;
  MessageString : string;

  procedure AShowWarning( MesStatus : TK_MesStatus );
  begin
    if Assigned(ShowWarning) then ShowWarning( MessageString, MesStatus );
  end;

begin
  Result := false;

  TabImportIni := nil;
  if TabImportIniFName <> '' then begin
    TabImportIniFName := K_ExpandFileName( TabImportIniFName );
    if FileExists(TabImportIniFName) then
      TabImportIni := TMemIniFile.Create( TabImportIniFName );
  end;
  if TabImportIni = nil then begin
    MessageString := 'Файл настройки "'+TabImportIniFName+'" не удалось отрыть';
    AShowWarning(K_msError);
  end else begin
    Result := K_MVImportTab0( ImportTSFlags, MVFolder, SL, SMF,
                    TabImportIni, SourceName, PNodesList, ShowWarning );
    TabImportIni.Free;
  end;
end; // end of function  K_MVImportTab

//**************************************** K_MVImportTabByIniStrings
// Import Table Structure
//
function  K_MVImportTabByIniStrings( ImportTSFlags : TK_ImportTSFlags;
        MVFolder : TN_UDBase; SL : TStrings; SMF : TN_StrMatrFormat;
        SourceName : string; IniStrings : TStrings; PNodesList : PTStrings = nil;
        ShowWarning : TK_MVShowMessageProc = nil ) : Boolean;

var
  TabImportIni : TMemIniFile;
  MessageString : string;

  procedure AShowWarning( MesStatus : TK_MesStatus );
  begin
    if Assigned(ShowWarning) then ShowWarning( MessageString, MesStatus );
  end;

begin
  Result := false;

//  TabImportIni := nil;
  if IniStrings <> nil then begin
    TabImportIni := TMemIniFile.Create( '' );
    TabImportIni.SetStrings( IniStrings );
    Result := K_MVImportTab0( ImportTSFlags, MVFolder, SL, SMF,
                  TabImportIni, SourceName, PNodesList, ShowWarning );
    TabImportIni.Free;
  end else begin
    MessageString := 'Не заданы строки с параметрами загрузки';
    AShowWarning(K_msError);
    Exit;
  end;
end; // end of function  K_MVImportTabByIniStrings

//************************************************ K_IniHTMParGet ***
//
function  K_IniHTMParGet( const ParName : string; ParDef : string = '' ) : string;
begin
  Result := N_MemIniToString( 'HTM', ParName, ParDef );
end;

//************************************************ K_CallMVTEExecute
//
procedure K_CallMVTEExecute( CurUDSel : TN_UDBase );
var
  RPath : string;
  MarkedPathList, ExpandedPathList : TStrings;
  StateRoot : TN_UDBase;
  NPath : string;
begin
//*** Set VTE VTreeFrame State
  if K_CurArchive <> nil then begin
    MarkedPathList := TStringList.Create;
    ExpandedPathList := TStringList.Create;
    RPath := K_GetVTreeStateFromMemIni( MarkedPathList, ExpandedPathList, 'N_NVTreeForm' );
    if RPath = '' then
      StateRoot := K_MainRootObj
    else
      StateRoot := K_MainRootObj.GetObjByRPath( RPath );
//    NPath := CurUDSel.GetOwnersPath( StateRoot );
    NPath := K_GetPathToUObj( CurUDSel, StateRoot );
    MarkedPathList.Add( NPath );
    MarkedPathList.Add( NPath );
    MarkedPathList.Add( RPath );
    N_StringsToMemIni  ( 'N_NVTreeForm_MPList', MarkedPathList );

    MarkedPathList.Free;
    ExpandedPathList.Free;
  end;

{$IFDEF K_MVDAR} // MVDar Project
  with TN_VRMain2Form.Create( Application ) do
  begin
    MFFrame.IsMainAppForm := False;
//    IsMainForm := False;
    ShowModal();
  end;
{$ENDIF}
end; //*** end of procedure K_CallMVTEExecute


//************************************************ K_InitMVVAttrsColorsSet
// Init MVAttrs ColorsSets
//
procedure K_InitMVVAttrsColorsSet( PMVVAttrs : TK_PMVVAttrs; ColorsSetLPath : string;
                                   ColorsSetsUDRoot : TN_UDBase;
                                   ColorsSetIniText : string; WList : TStringList );
var
  WUD1 : TN_UDBase;
  DumpLine : string;
  i : Integer;
begin
  with PMVVAttrs^ do begin
  // Main Scale Colors
    WUD1 := ColorsSetsUDRoot.DirChildByObjName( ColorsSetLPath, K_ontObjUName );
    if WUD1 = nil then begin
   // Search For Ini ColorsSet
      if ColorsSetIniText <> '' then begin
     // create new colors set
        WUD1 := K_MVDarNewUserNodeAdd( K_msdColorPaths,
                                       ColorsSetsUDRoot, ColorsSetsUDRoot,
                                       DumpLine, ColorsSetLPath );
        WList.CommaText := ColorsSetIniText;
        TK_UDRArray(WUD1).ASetLength(WList.Count);
        with TK_UDRArray(WUD1).R do
          for i := 0 to WList.Count - 1 do
            PInteger(P(i))^ := N_StrToColor( WList[i] );
      end;
    end;
    if WUD1 <> nil then begin
      if ColorSchemes = nil then begin
        ColorSchemes := K_RCreateByTypeCode( Ord(nptUDRef) );
        K_SetUDRefField( TN_UDBase(ColorsSet), WUD1 );
      end;
      with ColorSchemes do begin
        ASetLength( ALength() + 1 );
        K_SetUDRefField( TN_PUDBase( P(AHigh()) )^, WUD1 );
      end;
    end;
  end;
end; //*** end of procedure K_InitMVVAttrsColorsSet

//************************************************ K_PrepMVASubTree
//  Prepapre given UDSubTree for MVAtlas use
//
procedure K_PrepMVASubTree( AUDRoot : TN_UDBase; AScanRootNode : Boolean );
var
  i : Integer;
  ScanMVUDSubTree : TK_ScanMVUDSubTree;
  AtlasNode : TN_UDBase;

begin

  //Set WinGroup Objects View Flags
  ScanMVUDSubTree := TK_ScanMVUDSubTree.Create;
  with ScanMVUDSubTree do begin
    ScanRootNode := AScanRootNode;
    //*** Set Scan Filter Sys Type
    SetLength( ScanSysTypeFilter, 2 );
    ScanSysTypeFilter[0] := K_msdWebFolder;
    ScanSysTypeFilter[1] := K_msdWebWinGroups;
    MVUDSubTreeScan( AUDRoot, BuildNodesFilteredListFunc, [] );
    for i := 0 to Nodes.Count - 1 do begin
      AtlasNode := TN_UDBase(Nodes[i]);
      AtlasNode.ObjAliase := TK_PMVWebFolder(TK_UDRArray(AtlasNode).R.P).FullCapt;
      if AtlasNode.CI = K_UDMVWWinGroupCI then begin
        AtlasNode.ObjVFlags[0] := K_fvUseCurrent + K_fvSkipChildDir;
        AtlasNode.ObjInfo := TK_PMVWebWinGroup(TK_UDRArray(AtlasNode).R.P).Title;
        N_ReplaceHTMLBR( AtlasNode.ObjInfo, '    ' );
        AtlasNode.ObjInfo := N_SplitString2( AtlasNode.ObjInfo, 80 );
        AtlasNode.ImgInd := 25;
      end else begin
        AtlasNode.ImgInd := 30;
        AtlasNode.ObjInfo := 'Раздел "' + AtlasNode.ObjAliase + '"';
      end;
    end;
  end;
  ScanMVUDSubTree.Free;

end; //*** end of procedure K_PrepMVASubTree

//************************************************ K_BuildMVAFileFromCurArchUDObjs
//  For SPL Script Use
//
procedure K_BuildMVAFileFromCurArchUDObjs( ArchFName : string;
                                     PUDObjs : TN_PUDBase; UDCount : Integer );
var
  SaveCursor : TCursor;
  ArchBuf : TN_BArray;
  i{, n} : Integer;
  TI : TK_VTIArray;
//  ScanMVUDSubTree : TK_ScanMVUDSubTree;
//  AtlasNode : TN_UDBase;

begin

  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

// Copy All Needed Files to Distribute Folder

// Save Cur Archive to Mem and Save Current View Attributes
  //*** Save VTree View
  K_TreeViewsUpdateModeSet;
  K_TreeViewsInfoGet( TI );

  //*** Prevent VTree Deletion
  K_SetUDGControlFlags( 1, K_gcfSkipVTreeDeletion );

  // Save Cur Archive to Mem
  K_SaveTreeToMem( K_CurArchive, N_SerialBuf, true, [K_lsfJoinAllSLSR] );
//  ArchBuf := Copy( TN_BArray(N_SerialBuf.Buf1), 0, N_SerialBuf.OfsFree );
  ArchBuf := TN_BArray(N_SerialBuf.GetDataToBArray());

// Prepare Atlas Archive
  // Add Selected Nodes to UserRoot
//  n := UDObjs.Count;
  K_CurUserRoot.InsertEmptyEntries( 0, UDCount );
  for i := 0 to UDCount - 1 do begin
    K_CurUserRoot.PutDirChild( i, PUDObjs^ );
    Inc(PUDObjs);
  end;
  // Remove All UserRoot Childs Except New Added
  K_CurUserRoot.ClearChilds( UDCount );

  //Set WinGroup Objects View Flags
  K_PrepMVASubTree( K_CurUserRoot,false );
{
  ScanMVUDSubTree := TK_ScanMVUDSubTree.Create;
  with ScanMVUDSubTree do begin
    //*** Set Scan Filter Sys Type
    SetLength( ScanSysTypeFilter, 2 );
    ScanSysTypeFilter[0] := K_msdWebFolder;
    ScanSysTypeFilter[1] := K_msdWebWinGroups;
    MVUDSubTreeScan( K_CurUserRoot, BuildNodesFilteredListFunc );
    for i := 0 to Nodes.Count - 1 do begin
      AtlasNode := TN_UDBase(Nodes[i]);
      AtlasNode.ObjAliase := TK_PMVWebFolder(TK_UDRArray(AtlasNode).R.P).FullCapt;
      if AtlasNode.CI = K_UDMVWWinGroupCI then begin
        AtlasNode.ObjVFlags[0] := K_fvUseCurrent + K_fvSkipChildDir;
        AtlasNode.ObjInfo := TK_PMVWebWinGroup(TK_UDRArray(AtlasNode).R.P).Title;
        N_ReplaceHTMLBR( AtlasNode.ObjInfo, '    ' );
        AtlasNode.ObjInfo := N_SplitString2( AtlasNode.ObjInfo, 80 );
        AtlasNode.ImgInd := 25;
      end else begin
        AtlasNode.ImgInd := 30;
        AtlasNode.ObjInfo := 'Раздел "' + AtlasNode.ObjAliase + '"';
      end;
    end;
  end;
  ScanMVUDSubTree.Free;
}
// Save Archive Joining All Sections to specified Atlas Archive File
//  K_CurArchive.SaveTreeToFile( K_ExpandFileName( ExpDBFName ), '', [K_lsfSetJoinToAllSLSR] );

//  Include( K_UDGControlFlags, K_gcfSkipFreeObjsDump );
  K_UDGControlFlags := K_UDGControlFlags + [K_gcfSkipFreeObjsDump,K_gcfArchSDTCopy];

  //  K_CurArchive.SaveTreeToTextFile( K_ExpandFileName( ArchFName ), K_TextModeFlags,
//     K_CurArchive.ObjInfo, [K_lsfSetJoinToAllSLSR] );
  K_CurArchive.SaveTreeToAnyFile( K_CurArchive, K_ExpandFileName( ArchFName ) + '.sdb',
       K_CurArchive.ObjInfo, [K_lsfSetJoinToAllSLSR], false );

  K_UDGControlFlags := K_UDGControlFlags - [K_gcfSkipFreeObjsDump,K_gcfArchSDTCopy];
//  Exclude( K_UDGControlFlags, K_gcfSkipFreeObjsDump );


// Restore Current Archive from Mem and Current View Attributes
  N_SerialBuf.LoadFromMem( ArchBuf[0], Length(ArchBuf) );
  K_LoadTreeFromMem0( K_CurArchive, N_SerialBuf, true, [K_lsfJoinAllSLSR] );
  K_InitArchiveGCont( K_CurArchive );

  K_SetUDGControlFlags( -1, K_gcfSkipVTreeDeletion );

//*** Restore VTree View
  K_TreeViewsInfoRestore( TI );
  K_TreeViewsInfoFree( TI );

  K_TreeViewsUpdateModeClear( false );

  Screen.Cursor := SaveCursor;

end; //*** end of procedure K_BuildMVAFileFromCurArchUDObjs

//************************************************ K_GetMSWDocCreateAttrs
//
function K_GetMSWDocCreateAttrs( var WDAttrs : TK_MVMSWDVAttrs;
                    MSWDocCreateAttrsFlags : TK_MSWDocCreateAttrsFlags ) : boolean;
var
  DocParsName : string;
  UDPars : TN_UDBase;
begin

  Result := false;

  if K_dcaShowStruct in MSWDocCreateAttrsFlags then begin
    if K_dcaPortraitPage in MSWDocCreateAttrsFlags then
      DocParsName := 'MVAStructP'
    else
      DocParsName := 'MVAStructL'
  end else begin
    if K_dcaPortraitPage in MSWDocCreateAttrsFlags then
      DocParsName := 'MVAPlainP'
    else
      DocParsName := 'MVAPlainL'
  end;
  UDPars := K_UDCursorGetObj( 'CA:\MVDar\MSOComps\'+DocParsName );
  if UDPars = nil then Exit;

  Result := true;
  with TK_UDRArray(UDPars).R do
    K_MoveSPLData( P^, WDAttrs, ElemType, [] );

  with WDAttrs do begin
    if not (K_dcaShowTables in MSWDocCreateAttrsFlags) then UDWDTable := nil;
    if not (K_dcaShowMaps in MSWDocCreateAttrsFlags)   then begin
      UDWDMap := nil;
      UDMapsListInd := -1;
    end;
    if not (K_dcaShowHists in MSWDocCreateAttrsFlags)  then UDWDMapHist := nil;
  end;

end; //*** end of K_GetMSWDocCreateAttrs

end.

