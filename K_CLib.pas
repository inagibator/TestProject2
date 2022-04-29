unit K_CLib;

interface

uses Controls, Menus, Forms, Classes, Windows, Graphics, inifiles, SysUtils,
     ExtCtrls, Types,
  K_parse, K_CLib0, K_Types, K_UDT2,
  N_BaseF, N_Types, N_Lib2, N_Gra2;


{
type TK_MacroFlags1 = (K_rmfPutErrText, K_rmfRemoveMacro, K_rmfSaveMacro, K_rmfSaveMacroName, K_rmfRemoveResult );
type TK_MRFunc1 = function( MacroName : string; var MacroResult : string ) : Boolean of object;
type TK_MRList1 = class //*** Macro Replace List Class
  MList : TStrings;
  function GetMacroValue( MacroName : string; var MacroResult : string ) : Boolean;
end;
}
//##/*
const     K_CheckFilesCRCNotFound = 1;
const     K_CheckFilesCRCError = 2;
function  K_CheckFilesCRC( AFilesCRCInfo : TStrings;
                           var ARetCode : Integer ) : string; overload;
function  K_CheckFilesCRC( AFilesCRCInfo, AResCRCInfo : TStrings ) : Boolean; overload;
function  K_CheckMemIniFilesCRC( const ACRCSectName : string;
                                 AResCRCInfo : TStrings ) : Boolean;

function  K_CheckDPRUses0( const ADPRFName : string; AReportStrings : TStrings;
                           ASysUnitsStrings : TStrings = nil;
                           AWarnStrings : TStrings = nil ) : string;
procedure K_CheckDPRUses(  );
function  K_SyncDPRUsesAndBody( const ASrcDPRFName, ADstDPRFName, ASkipUList : string ) : Integer;

procedure K_CopyHTMLinkedFiles( const ACFileName, ADestPath : string );

type TK_GEFunc = function( var EData; PDContext : Pointer ) : Boolean;
function  K_RegGEFunc( const Name : string; GEFunc : TK_GEFunc;
                       PDContext : Pointer = nil ) : Integer;
function  K_UNRegGEFunc( const Name : string ) : Integer;
//##*/

function  K_GetOwnerForm( TC : TComponent ) : TForm;
function  K_GetOwnerBaseForm( TC : TComponent ) : TN_BaseForm;
function  K_GetParentForm( TC : TControl ) : TForm;

////////////////////////////////////////////////
// TControl Alignment SaveRestore Routines
//

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_CtrlAlignAttrs
type TK_CtrlAlignAttrs = record // TControl Alignment SaveRestore Routines
  CParent: TWinControl;// Parent Comtrol
  CAlign : TAlign;// Control Align Type
  CAnchors : TAnchors;// Control Anchors Set
  CLeft : Integer;// Control Left coordinate
  CTop : Integer;// Control Top coordinate
  CWidth : Integer;// Control width
  CHeight : Integer;// Control height
  CConstraints : TSizeConstraints;// Control Constraints
end;
procedure K_GetCtrlAlignAttrs( ATC : TControl; var AAttrs : TK_CtrlAlignAttrs );
procedure K_SetCtrlAlignAttrs( ATC : TControl; const AAttrs : TK_CtrlAlignAttrs );
procedure K_ClearCtrlAlignAttrs( var AAttrs : TK_CtrlAlignAttrs );
//
// TControl Alignment SaveRestore Routines
////////////////////////////////////////////////

//##/*
procedure K_CompressJSStrings( DSL, SSL  : TStrings; StringCommentArr,
                  SingleCommentArr, BracketsCommentArr : array of string );
//##*/

type TK_TestFormFunc = function ( AForm : TForm ) : Boolean of object;
function  K_SearchOpenedForm( AClass : TClass = nil; ASelfName : string = '';
                              AOwner : TForm = nil; ASkipForm : TForm = nil;
                              AForwardSearch : Boolean = false; ATFFunc : TK_TestFormFunc = nil ) : TForm;
procedure K_PosTwinForm( AForm : TForm; ADXShift : Integer = 16; ADYShift : Integer = 16 );
procedure K_BuildMenuShortCutsList( AMItem : TMenuItem; ASL : TStrings;
                                    AShortcutsOnly : Boolean  );
procedure K_BuildAllShortCutsList( ASL : TStrings  );

////////////////////////////////////////////////
// GUI  laguage assistance Routines
//
var K_FFExcludeCompTypeNames : TStringList;
procedure K_GetFFCompTextsToStrings( ATexts : TStrings; AComp : TComponent );
procedure K_SetFFCompCurLangTexts0( ATexts : TStrings; AComp : TComponent );
procedure K_SetFFCompCurLangTexts  ( AComp : TComponent );
type TK_PrepLLLCompTextFunc = function( var AStr : string ) : Boolean;
function  K_PlaceNewLineChars( var ASValue : string ) : Boolean;
procedure K_PrepLLLCompTexts( AComp : TComponent; APrepFunc : TK_PrepLLLCompTextFunc = nil );
procedure K_GetFFCompTexts         ( ARLData : TN_MemTextFragms; AComp : TComponent );
procedure K_GetLangTextsCompareStrings( AOldLData, ANewLData, AULData : TN_MemTextFragms; AddEmptyFragm : Boolean );
procedure K_PrepLangTexts( ALData : TN_MemTextFragms; ASkipOrderFlags : Integer = 0 );
function  K_SetCurLangGroup  ( const AGroupName : string ) : Boolean;
function  K_GetCurLangText1  ( const ATextName : string;
                               const ADefValue : string = '' ) : string;
function  K_GetCurLangText2  ( const AGroupName, ATextName : string;
                               const ADefValue : string = '' ) : string;
//
// GUI  laguage assistance Routines
////////////////////////////////////////////////

procedure K_SetStringsByVaues( ARList : TStrings; ASList : TStrings );
procedure K_SetStringsByNames( ARList : TStrings; ASList : TStrings );
procedure K_SetStringsByIniSectionVaues( const AIniSName : string; ARList : TStrings );
procedure K_ReplaceStringsVaues( ARList : TStrings; ARInd : Integer; AVList : TStrings );
function  K_LoadDIBFromVFileByRI( ARI: TObject; const AVFileName: string; out ADIBObj : TN_DIBObj ) : Integer;
function  K_LoadTImage( AImage: TImage; const AVFileName: string ) : Integer;

var
  K_GEditors : THashedStringList;
  K_GEFuncs  : THashedStringList;
  K_GEFPConts: TList;

//************************************************************
//  DFPL Interpretor
//  Default MacroParams:
//    ResultIniName - name of Result IniFile (without Path and Extension)
//    AppBasePath   - Application which Execute DFPL-script Base Path
//************************************************************

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec
//******************************************************* TK_DFPLScriptExec ***
// Distribution Files Prepareing Scripts Interpretor class
//
// DFPL Interpretor set value to Macro Parameter 'ResultIniName' which contains
// name of Result IniFile (without Path and Extension)
//
type TK_DFPLScriptExec = class

  OnShowInfo : TK_MVShowMessageProc; // procedure of object for execution 
                                     // warnings

  DstBasePath : string;            // destination Base Path for Distribution 
                                   // Files
  SrcBasePath : string;            // Base Path for Source Files
  CallMemIniFile    : TMemIniFile; // current MemIniFile for Calling Commands 
                                   // from Ini-file section
  CallMemTextFragms : TStringList; // current MemTextFragms TStringList for 
                                   // Calling Commands from TextFragms Section
  CommandWarningsCount : Integer;  // commands Execution Warnings counter


//##/*
  constructor Create();
  destructor Destroy(); override;
//##*/
  procedure DFPLSetDestRootPath ( const ADstBasePath : string );
  procedure DFPLSetSrcContext( const ASrcIniFileName : string;
                           const ASrcBasePath : string = '' );
  procedure DFPLCreateDestMemIni( const AIniName : string;
                          AEncodeResultIniFile : Boolean;
                          ASkipSaveIniFile : Boolean = false;
                          const ASrcIniFileName : string = '' );
  procedure DFPLSetVFileDataSpace( AVFile: TK_VFile );
  procedure DFPLSaveMemIni( AIniFileName : string = '' );
  procedure DFPLFreeMemIni( AIniFileName : string = '' );
  procedure DFPLExecCommand( const ACommandName, AParam0  : string;
                         AParam1, AParam2, AParam3, AParam4 : string );
  procedure DFPLDoCommandsList0( ACommands : TStrings; AIniFlag : Boolean );
  procedure DFPLDoCommands0( ACommands : TStrings; AIniFlag : Boolean;
                         const ARootPath, AIniName : string;
                         AEncodeResultIniFile, ASkipSaveIniFile : Boolean );
  function  DFPLExecIniSection( const AExecSectionName, ARootPath : string;
                            AIniName : string = ''; AEncodeResultIniFile : Boolean = false;
                            ASkipSaveIniFile : Boolean = false ) : Boolean;
  function  DFPLExecTFSection( const AExecSectionName : string;
                            const ARootPath : string = '';
                            const AIniName : string = ''; AEncodeResultIniFile : Boolean = false;
                            ASkipSaveIniFile : Boolean = false ) : Boolean;
  procedure DFPLExecCommandsList( ACommands : TStrings; const ARootPath : string;
                            AIniName : string = ''; AEncodeResultIniFile : Boolean = false;
                            ASkipSaveIniFile : Boolean = false );
  function  DFPLExecVFile( const AVFileName : string ) : Boolean;
  procedure DFPLSetMacroList( ACMList : TStrings; AAssignFlag : Boolean = FALSE );
    public

  DstIniFile : TMemIniFile; // destination Memory IniFile
  SrcIniFile : TMemIniFile; // source Memory IniFile
  SkipSaveDstIniFile : Boolean;
  ShowCommandDumpStatus : Integer;
  LastCommandsStrings : TStrings; // Info Strings with commands that were just 
                                  // executed

  function  DFPLGetCMListItem( const AName : string ) : string;
    private
//##/*
  STK : TK_Tokenizer;
  ResultIniFileEncode : Boolean;
  SResultIniFileDataSize : string;
  WWSL : TStringList;
  WWSL1 : TStringList;
  SrcDirsList : TStrings;
  DstDirsList : TStrings;
  CurDstDirsList : TStrings;
  CurSrcDirsList : TStrings;
  CMListFreeFlag : Boolean;  // Free Curren MacroList Flag
  CMList : TStrings;         // Cur MacrosList
  CurCommandWarning : string;
  ScanFilesSubfolders : Boolean;

  procedure DFPLShowInfo( const Info: string; MesStatus : TK_MesStatus = K_msInfo );
  procedure DFPLInitCMList();
  function  DFPLSetCMListItem( const AName, AValue : string; AOnlyAdd : Boolean = false ) : Integer;
  procedure DFPLSetNamedPathsStrings( ANameedPathsContext : TStrings;
                                  AMemIniFile : TMemIniFile;
                                  AExePathValue : string; ASectName : string );
  function  DFPLExpandByDestDirs( const AFileName : string ) : string;
  function  DFPLExpandBySrcDirs( const AFileName : string ) : string;
  function  DFPLCollectDirFiles( const APathName, AFileName: string; AScanLevel : Integer ) : TK_ScanTreeResult;
//##*/
end;
{
//******************************************************* TK_MemIniContsProc ***
// MemIni Contexts Processing Object
//
type TK_MemIniContsProc = class
  MICPDFPLExec    : TK_DFPLScriptExec;
  MICPDFPLScripts : TN_MemTextFragms;
  MICPWrkMemIni   : TMemIniFile;
  MICPJoinedMemIni: TMemIniFile;
//##/*
  destructor Destroy(); override;
//##*/
  constructor Create( AJoinedMemIni : TMemIniFile; ADFPLScriptsFName : string ); overload;
  procedure AddIniStrings( AIniStrings : TStrings; AScriptName : string );
  procedure AddIniFile( AIniFName : string; AScriptName : string = '' );
  procedure GetIniStrings( AIniStrings : TStrings; AScriptName : string );
end;
}

//##/*
//************************************************************** TK_UNDOBuf ***
// UNDO Buffer Object
//
type TK_UNDOBuf = class

  constructor Create( AUndoFilePattern: string );
  destructor Destroy; override;
  procedure UBPushData( ACapt : string; APData : Pointer; ADataSize : Integer );
  procedure UBGetDataByInd( AInd : Integer; var ADataBuf : TN_BArray; out ADataSize : Integer );
  procedure UBPopData( var ADataBuf : TN_BArray; out ADataSize : Integer );
  procedure UBPrevPopedData( var ADataBuf: TN_BArray; out ADataSize: Integer);
  function  UBGetCount( ) : Integer;
  procedure UBGetCaptions( ACapts : TStrings );
  function  UBGetCaptionByInd( AInd : Integer ) : string;
  procedure UBSetCurInd( AInd : Integer );
  procedure UBSkipLast( );
  procedure UBInit( ); virtual;
    private
  FStream       : TFileStream; // File stream for UNDO records storing
  FUndoFilePath : string;      // Name of File for UNDO records storing
  FCaptions     : TN_SArray;   // UNDO records Captions
  FOffsets      : TN_IArray;   // UNDO records File offsets
  FCurInd       : Integer;     // current UNDO record index
  FCount        : Integer;     // UNDO records count
    public
  property  UBCount    : Integer read FCount;
  property  UBCurInd   : Integer read FCurInd write UBSetCurInd;
  property  UBCaptions[Index: Longint]: string read UBGetCaptionByInd;
end;
//*** end of Undo buffer
//##*/


//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1
//************************************************************* TK_UNDOBuf1 ***
// UNDO Buffer Object
//
// UNDO Data are stored in File Stream. Each UNDO state is stored in UNDO 
// Record. UNDO Records contents (array of File Stream offsets) is stored in 
// memory. Each UNDO Record can be consisted of several Subrecords. Subrecords 
// number is the same in each Record and is given to UNDO Buffer Constructor. 
// Each UNDO Record contains Subrecords contents (array of File Stream offsets) 
// which is saved to File Stream before Record Data. Elements of Subrecords 
// contents can be (if positive) File Stream offset of Subrecord Data (if it is
// placed in self Record) or (if negative) reference to "real" Data as number of
// some previous Record with corresponding Subrecord that contains "real" Data. 
// (All Subrecords contents can be stored in separate array in memory - not in 
// File Stream)
//
type TK_UNDOBuf1 = class

  constructor Create( AUndoFilePattern: string; ASRecNumber : Integer = 1 );
  constructor CreateByUNDOBuf( AUNDOBuf: TK_UNDOBuf1 );
//##/*
  destructor Destroy; override;
//##*/
  procedure UBPushData( ACapt : string; APData : Pointer; ADataSize : Integer );
  procedure UBGetDataByInd( AInd : Integer; var ADataBuf : TN_BArray; out ADataSize : Integer );
  function  UBDecCurInd( ) : Boolean;
  function  UBIncCurInd( ) : Boolean;
  procedure UBPopData( var ADataBuf : TN_BArray; out ADataSize : Integer );
  procedure UBPrevPopedData( var ADataBuf: TN_BArray; out ADataSize: Integer);
  function  UBGetCount( ) : Integer;
  procedure UBGetCaptions( ACapts : TStrings );
  function  UBGetCaptionByInd( AInd : Integer ) : string;
  procedure UBSetCurInd( AInd : Integer );
  procedure UBSetMinInd( AInd : Integer );
  procedure UBSkipLast( );
  procedure UBInit( ); virtual;
  procedure UBPushRecord( const ACapt : string );
  procedure UBPushSubRecordData( ASRInd : Integer; APData : Pointer; ADataSize : Integer );
  procedure UBGetSubRecordData ( ASRInd : Integer; var ADataBuf : TN_BArray; out ADataSize : Integer );
  procedure UBChangeSubRecordReference( ASRInd : Integer; ARefInd : Integer );

    private
    public
  FStream       : TFileStream; // File stream for UNDO records storing
  FUndoFilePattern: string;    // File Name pattern for UNDO buffer copy
  FUndoFilePath : string;      // Name of File for UNDO records storing
  FCaptions     : TN_SArray;   // UNDO records Captions
  FOffsets      : TN_IArray;   // UNDO records File offsets
  FCurInd       : Integer;     // current UNDO record index
  FMinInd       : Integer;     // Minimal UNDO record index
  FCount        : Integer;     // records count
  FSRecNumber   : Integer;     // subrecords count
  FSRecOffsets  : TN_IArray;   // subrecords File offsets Array
  FSRecCurInd   : Integer;     // last pushed subrecord index

  property  UBCount    : Integer read FCount;
  property  UBCurInd   : Integer read FCurInd write UBSetCurInd;
  property  UBMinInd   : Integer read FMinInd write UBSetMinInd;
  property  UBCaptions[Index: Longint]: string read UBGetCaptionByInd;
end;
//*** end of Undo buffer

//**************************************************** TK_TextsNGSimilarity ***
// Calculate Texts Similarity Value
//
// Calculate Texts Similarity Value based on n-grams
//
type TK_TextsNGSimilarity = class
  procedure SetText1A( ATextPtr : PAnsiChar; ATextLength : Integer ); overload;
  procedure SetText1A( const AText : AnsiString ); overload;
  procedure SetText1W( ATextPtr : PWideChar; ATextLength : Integer ); overload;
  procedure SetText1W( const AText : WideString ); overload;
  procedure SetText1( ATextPtr : PChar; ATextLength : Integer ); overload;
  procedure SetText1( const AText : string ); overload;
  procedure SetText2A( ATextPtr : PAnsiChar; ATextLength : Integer ); overload;
  procedure SetText2A( const AText : AnsiString ); overload;
  procedure SetText2W( ATextPtr : PWideChar; ATextLength : Integer ); overload;
  procedure SetText2W( const AText : WideString ); overload;
  procedure SetText2( ATextPtr : PChar; ATextLength : Integer ); overload;
  procedure SetText2( const AText : string ); overload;
  function  CalcSimilarityVal(  ) : Double;
    private
  FNGIntsBuf1 : TN_IArray; // 1-st Text N-grams integer representation Buffer
  FNGIntsBuf2 : TN_IArray; // 2-nd Text N-grams integer representation Buffer
  FNGIntsCount1 : Integer; // 1-st Text N-grams integer representation count
  FNGIntsCount2 : Integer; // 2-nd Text N-grams integer representation count
  FNGVectorCount1 : Integer; // 1-st Text N-grams vector elements count
  FNGVectorCount2 : Integer; // 2-nd Text N-grams vector elements count
  FNGVSQLength1 : Double; // 1-st Text N-grams vector N-length
  FNGVSQLength2 : Double; // 2-nd Text N-grams vector N-length

  function  BuildOneNGInts( var ANGIntsBuf : TN_IArray;
                            out ANGIntsCount, ANGVectorCount : Integer;
                            ATextPtr : TN_BytesPtr; ATextCharLength : Integer;
                            ACharSize : Integer ) : Double;
    public

  FGramLegth : Integer; // Gram Length in chars
  FGramShift : Integer; // Gram Shift in chars
end;
//*** end of TK_TextsNGSimilarity

function K_PrepFullScreenInfo( AControl : TControl; var AControlRect, AMonitorRect : TRect ) : TRect;

implementation

uses
  StrUtils, HTTPApp, StdCtrls, Buttons, ComCtrls,
  ActnList, Dialogs, Math,
  K_Arch, K_FrRAEdit, K_UDT1, K_UDC, K_FEText, K_Gra0, K_RImage, {K_STBuf,}
  N_Lib0, N_Lib1, N_Gra0;

//********************************************* K_CopyHTMLinkedFiles ***
//  Copy files linked to specified HTM file
//
//    Parameters
// ACFileName - copied file name
// ADestPath  - destination files path
//
procedure K_CopyHTMLinkedFiles( const ACFileName, ADestPath : string );
var
  FExt, LPath, LName, SBuf, FName : string;
  SList : TStringList;
  i, h{, SPos} : Integer;
//  pcstr0 : PChar;
//  psstr : PChar;
  St : TK_Tokenizer;
{
  procedure CopyFilesMarkedByAttr( const Attr : string );
  begin
    spos := Pos( Attr, SBuf );
    if spos <> 0 then
    begin
      Dec(spos);
      psstr := pcstr0 + spos;
      repeat
        spos := psstr - pcstr0;
        St.CPos := spos  + Length( Attr ) + 1;
        LName := St.nextToken;
        if not K_IfGlobalLink( LName ) then begin
          LName := UnixPathToDosPath( LName );
          FName := LPath + LName;
          if ( K_CopyFile( LPath + LName, DestPath + LName, true ) = 0 )  then // copy HREF file
            K_CopyHTMLinkedFiles( FName, DestPath );
        end;
        if St.CPos >= St.TLength then break;
        psstr := StrPos( pcstr0 + St.CPos - 1, PChar(Attr) );
      until psstr = nil;
    end;
  end;
}
  procedure CopyFilesMarkedByAttr0( const Attr : string );
  var
    SPos : Integer;
  begin
//    SPos := 1;
    while (St.CPos < St.TLength) do
    begin
      SPos := PosEx( Attr, SBuf, St.CPos );
      if SPos = 0 then break;
      St.CPos := SPos  + Length( Attr );
      LName := St.nextToken;
      if not K_IfURLReference( LName ) then
      begin
        LName := UnixPathToDosPath( LName );
        FName := LPath + LName;
        if ( K_CopyFile( FName, ADestPath + LName, [K_cffOverwriteNewer] ) = 0 )  then // copy HREFor SRC file
          K_CopyHTMLinkedFiles( FName, ADestPath );
      end;
    end;

  end;

begin

  FExt := LowerCase( ExtractFileExt( ACFileName ) );
  if (FExt[2] <> 'h') or (FExt[3] <> 't') then Exit;
  LPath := ExtractFilePath( ACFileName );
  SList := TStringList.Create;
  SList.LoadFromFile( ACFileName );
  St := TK_Tokenizer.Create( '', ' >', '""''''{}' );
//  St := TK_Tokenizer.RCreate( ' >', '""''''{}' );
  h := SList.Count - 1;
  for i := 0 to h do
  begin
//*** copy src files
    SBuf := LowerCase( SList.Strings[i] );
    St.setSource( SList.Strings[i] );
{
    pcstr0 := PChar(SBuf);
    CopyFilesMarkedByAttr( 'src=' );
    CopyFilesMarkedByAttr( 'href=' );
}
    CopyFilesMarkedByAttr0( 'src=' );
    CopyFilesMarkedByAttr0( 'href=' );
  end;
  St.Free;
  SList.Free;

end; // end of K_CopyHTMLinkedFiles

//********************************************* K_CheckFilesCRC ***
//  Check given files CRC
//
//     Parameters
// AFilesCRCInfo  - strings with Files CRC Info
// ARetCode - check resulting code: 0 - OK, 1 - file not found, 2 - wrong CRC
// Result - Returns error absent or wrong CRC file name or '' if all files are OK
//
// Each element in Files CRC Info strings list should contain following string:
// <File Name>=<FileDataCRC>
//
function  K_CheckFilesCRC( AFilesCRCInfo : TStrings; var ARetCode : Integer ) : string;
var
  i : Integer;
  ICRC : Integer;
  FCRC : Integer;
begin
  ARetCode := 0;
  for i := 0 to AFilesCRCInfo.Count - 1 do
  begin
    ICRC := StrToIntDef( AFilesCRCInfo.ValueFromIndex[i], -1 );
    if ICRC = -1 then raise Exception.Create( 'Wrong file CRC ' + AFilesCRCInfo[i] );
//    Result := AFilesCRCInfo.Names[i];
//    FName := K_ExpandFileName(Result);
//    if FileExists( FName ) and (ICRC <> K_CalcFileCRC(FName) ) then
//      Exit; // File with Wrong CRC is found
    Result := K_ExpandFileName(AFilesCRCInfo.Names[i]);

    if FileExists( Result ) then
    begin
      FCRC := K_CalcFileCRC(Result);
      if ICRC <> FCRC then
      begin
        ARetCode := K_CheckFilesCRCError; // open Error
        if FCRC = -1 then
          N_Dump2Str( 'CRC check "' + Result + '" stream open fails' )
        else
        if FCRC = 0 then
          N_Dump2Str( 'CRC check "' + Result + '" is empty' )
      end;
    end else
      ARetCode := K_CheckFilesCRCNotFound; // File not found
    N_Dump2Str( 'CRC check "' + Result + '" RetCode='+IntToStr(ARetCode) );
    if ARetCode <> 0 then Exit;
  end;
  Result := '';
end; // function K_CheckFilesCRC

//********************************************* K_CheckFilesCRC ***
//  Check given files CRC
//
//     Parameters
// AFilesCRCInfo  - strings with Files CRC Info
// AResCRCInfo - Strings for CRC errors result
// Result - Returns FALSE if some CRC errors were detected
//
// Each element in Files CRC Info strings list should contain following string:
// <File Name>=<FileDataCRC>
//
// Each element in resulting AResCRCInfo string contain error file name
// and check resulting code: 1 - file not found, 2 - wrong CRC in corresponding Objects[i]
//
function  K_CheckFilesCRC( AFilesCRCInfo, AResCRCInfo : TStrings ) : Boolean;
var
  i : Integer;
  ICRC : Integer;
  FName : string;
  RetCode : Integer;
begin
  AResCRCInfo.Clear;
  for i := 0 to AFilesCRCInfo.Count - 1 do
  begin
    ICRC := StrToIntDef( AFilesCRCInfo.ValueFromIndex[i], -1 );
    if ICRC = -1 then raise Exception.Create( 'Wrong file CRC Info -> ' + AFilesCRCInfo[i] );
    FName := K_ExpandFileName(AFilesCRCInfo.Names[i]);
    RetCode := 0;
    if FileExists( FName ) then
    begin
      if ICRC <> K_CalcFileCRC( FName ) then
        RetCode := 2; // open Error
    end else
      RetCode := 1; // File not found
    N_Dump2Str( 'CRC check "' + FName + '" RetCode='+IntToStr(RetCode) );
    if RetCode = 0 then Continue;
    AResCRCInfo.AddObject( FName, TObject(RetCode) );
  end;
  Result := AResCRCInfo.Count = 0;
end; // function K_CheckFilesCRC

//********************************************* K_CheckMemIniFilesCRC ***
//  Check CRC for files in N_CurMemIni given Section
//
//     Parameters
// ACRCSectName - Section Name with files CRC Info
// AResCRCInfo - Strings for CRC errors result
// Result - Returns FALSE if some CRC errors were detected
//
// Each element in FilesCRC MemIni section should contain following string:
// <File Name>=<FileDataCRC>
//
// Each element in resulting AResCRCInfo string contain error file name
// and check resulting code: 1 - file not found, 2 - wrong CRC in corresponding Objects[i]
//
function  K_CheckMemIniFilesCRC( const ACRCSectName : string;
                                 AResCRCInfo : TStrings ) : Boolean;
var
  FilesCRCInfo : TStringList;
begin
  FilesCRCInfo := TStringList.Create;
  N_ReadMemIniSection( 'FilesCRC', FilesCRCInfo );
  Result := K_CheckFilesCRC( FilesCRCInfo, AResCRCInfo );
  FilesCRCInfo.Free;
end; // function K_CheckMemIniFilesCRC`

//********************************************* K_CheckDPRUses0 ***
//  Check Delphi Project Uses
//
//     Parameters
// ADPRFName  - project file name
// AReportStrings  - project report strings
// ASysUnitsStrings - project system units strings if = NIL then no system results
// AWarnStrings  - project warnings strings if = NIL then no system results
// Result - Returns TRUE if show warning form returns Cancel
//
function  K_CheckDPRUses0( const ADPRFName : string; AReportStrings : TStrings;
                           ASysUnitsStrings : TStrings = nil;
                           AWarnStrings : TStrings = nil ) : string;
var
  PASName, SrcDPRName, SPRPath, WStr, EStr : string;
  i1, i2, j1, j2, j3, j4, L : Integer;
  WChar : Char;
  WSL, UList, PList, AList, EList, SList, FList : TStringList;
  ReportDone : Boolean;

label LExit, ContinueUses, EndUses, CommandEnd;

  procedure SkipComment1( JJ : Integer );
  begin
    repeat
      Inc(JJ);
    until WStr[JJ] = '}';
    j4 := JJ;
  end;

  procedure SkipComment2( JJ : Integer );
  begin
    repeat
      Inc(JJ);
    until WStr[JJ] = Chr($A);
    j4 := JJ;
  end;

  procedure ParseUsesFiles(  );
  var
   UName : string;
  begin
    j4 := j1;
    while true do begin
      // skip 0A 0D
      while (WStr[j4] = Chr($A)) or (WStr[j4] = Chr($D)) do Inc(j4);
      // parse unit name
      j3 := j4;
      repeat
        Inc(j4);
        WChar := WStr[j4];
      until (WChar = ',') or (WChar = ';') or (WChar = '{') or (WChar = '/');
      UName := Trim( Copy( WStr, j3, j4 - j3) );
      if UName <> '' then begin
        if UName[1] = '{' then
          SkipComment1( j3 )
        else if UName[1] = '/' then
          SkipComment2( j3 )
        else begin
          j2 := UList.IndexOf( UName );
          if j2 < 0 then begin
            if UName[2] = '_' then begin
              if AList.IndexOf(UName) < 0 then
                AList.Add(UName)
            end else begin
              if SList.IndexOf(UName) < 0 then
                SList.Add(UName);
            end
          end else
            with UList do
              Objects[j2] := TObject( Integer(Objects[j2]) + 1 );
        end;
      end;
      if WChar = ';' then Exit else
      if WChar = '{' then SkipComment1( j4 ) else
      if WChar = '/' then SkipComment2( j4 );
      Inc(j4);
      if WStr[j4] = ';' then Exit;
    end;
  end;

  procedure SearchUses( jj : Integer );
  begin
    j1 := jj;
    repeat
      j1 := N_PosEx( 'uses', WStr, j1, L );
      if j1 = 0 then Exit;
      j1 := j1 + 4;
    until ((WStr[j1-5] = Chr($A))) and ((WStr[j1] = ' ') or (WStr[j1] = Chr($D)));
  end;

begin
//  Select DPR file
  WSL := TStringList.Create;
  UList := TStringList.Create;
  AList := TStringList.Create;
  PList := TStringList.Create;
  EList := TStringList.Create;
  SList := TStringList.Create;
  FList := TStringList.Create;

  PList.Clear;
  EList.Clear;
  UList.Clear;
  FList.Clear;
  SrcDPRName := ADPRFName;
  SPRPath := ExtractFilePath(SrcDPRName);
  WSL.LoadFromFile( SrcDPRName );
  i2 := -1;
  for i1 := 0 to WSL.Count - 1 do
    if Pos( 'uses', WSL[i1] ) <> 0 then begin
      i2 := i1;
      break;
    end;

  if i2 = -1 then begin
    K_ShowMessage( 'Delphi project USES statement not found',
                   'Warning', K_msWarning );
    goto LExit;
  end;

  for i1 := i2 + 1 to WSL.Count - 1 do begin
  //*** Parse USES Loop
    WStr := WSL[i1];
    j1 := 1;
    while WStr[j1] = ' ' do Inc(j1);
    j2 := j1;
    while true do begin
    //*** Parse USES Element Loop
      Inc(j1);
      WChar := WStr[j1];
      case WChar of
        ',' : begin // Delphi unit
          goto ContinueUses;
        end;
        ';' : begin // last Delphi unit
          goto EndUses;
        end;
        ' ' : begin // Self PAS file
        //*** copy PAS file
          // parse UNIT name
          UList.Add( Copy( WStr, j2, j1 - j2 ) );
          Inc(j1);
          while WStr[j1] <> '''' do Inc(j1);

          // parse FILE name
          Inc(j1);
          j2 := j1;
          while WStr[j1] <> '''' do Inc(j1);
          PList.Add( Copy( WStr, j2, j1 - j2 ) );

          WChar := WStr[Length(WStr)];
          if WChar = ',' then goto ContinueUses
          else goto EndUses;
        end; // *** end of PAS file copy
      end; //*** end of case WChar
    end; //*** End of Parse USES Element Loop

ContinueUses:
  end; //*** End of Parse USES Loop

  K_ShowMessage( 'Delphi project end of USES list not found',
                 'Warning', K_msWarning );
  goto LExit;

EndUses:
// Check PAS files USES
  for i1 := 0 to PList.Count - 1 do begin
    PASName := SPRPath + PList[i1];

    if not FileExists(PASName) then begin
      FList.Add( PASName );
      Continue;
    end;

    WSL.LoadFromFile( PASName );
    WStr := WSL.Text;
    L := Length(WStr);

    SearchUses( 1 );
    if j1 = 0 then begin
      EStr := 'USES not found in ' + PASName;
      EList.Add( EStr );
//          K_ShowMessage( EStr, 'Warning', K_msWarning );
      Continue;
    end;

    //*** Parse Inteface Uses
    j2 := N_PosEx( ';', WStr, j1, L );
    if j2 = 0 then begin
      EStr := 'End USES not found in ' + PASName;
      EList.Add( EStr );
      K_ShowMessage( EStr, 'Warning', K_msWarning );
      Continue;
    end;
    ParseUsesFiles( );

    SearchUses( j4 + 1 );
    if j1 = 0 then Continue;

    //*** Parse Impllementation Uses
    j2 := N_PosEx( ';', WStr, j1, L );
    if j2 = 0 then begin
      EStr := 'End USES not found in ' + PASName;
      K_ShowMessage( EStr, 'Warning', K_msWarning );
      EList.Add( EStr );
      Continue;
    end;
    ParseUsesFiles( );

  end; //*** End of Check PAS files USES Loop

//*************************************************
//                    Report
//*************************************************
  Result := ChangeFileExt( ExtractFileName(SrcDPRName), '' );

  ReportDone := false;
  if AList.Count > 0 then begin
    AReportStrings.Add( '*** Add to ' + Result );
    AList.Sort();
    K_ReplaceStringsInterval( AReportStrings, -1, 0, AList, 0, -1 );
    AReportStrings.Add( '' );
    ReportDone := true;
  end;

  for i1 := UList.Count - 1 downto 0 do
    if UList.Objects[i1] <> nil then UList.Delete(i1);

  if UList.Count > 0 then begin
    AReportStrings.Add( '*** Can be removed from ' + Result );
    UList.Sort();
    K_ReplaceStringsInterval( AReportStrings, -1, 0, UList, 0, -1 );
    ReportDone := true;
  end;

  if FList.Count > 0 then begin
    AReportStrings.Add( '' );
    AReportStrings.Add( '*** Absent files in ' + Result );
    FList.Sort();
    K_ReplaceStringsInterval( AReportStrings, -1, 0, FList, 0, -1 );
    ReportDone := true;
  end;

  if ReportDone then begin
    AReportStrings.Add( '' );
    AReportStrings.Add( '' );
  end;

//*************************************************
//                    Warnings
//*************************************************

  if (ASysUnitsStrings <> nil) and (SList.Count > 0) then begin
    SList.Sort;
    ASysUnitsStrings.Assign(SList);
  end;

  if (AWarnStrings  <> nil) and (EList.Count > 0) then
    AWarnStrings.Assign(EList);

LExit:
  WSL.Free;
  UList.Free;
  AList.Free;
  PList.Free;
  EList.Free;
  SList.Free;
  FList.Free;

end; // end of K_CheckDPRUses0

//********************************************* K_CheckDPRUses ***
//  Check Delphi Project Uses
//
// Starts dialog for selecting Delphi Project file check its Uses declarations
// and then show report. Routine finish if DPR file selection  canceled
//
procedure K_CheckDPRUses(  );
var
  SrcDPRName : string;
  OpenDialog : TOpenDialog;
  WSL, EList, SList : TStringList;

label NewDPRSelect;
begin
  OpenDialog := TOpenDialog.Create( Application );
  WSL := TStringList.Create;
  EList := TStringList.Create;
  SList := TStringList.Create;

NewDPRSelect:

  with OpenDialog do begin
  //  Select DPR file
    Filter := 'Projects (*.dpr)|*.dpr';
    Options := Options + [ofEnableSizing];
    Title := 'Test Delphi Projec File';
    if Execute then begin
      WSL.Clear;
      SrcDPRName := K_CheckDPRUses0( FileName, WSL, SList, EList );

      if not K_GetFormTextEdit.EditStrings( WSL, SrcDPRName ) then
        goto NewDPRSelect;

      WSL.Clear;
      if SList.Count > 0 then begin
        SList.Sort;
        WSL.Add( '*** Not N_*/K_* units in uses in ' + SrcDPRName + ' files ' );
        K_ReplaceStringsInterval( WSL, -1, 0, SList, 0, -1 );
      end;

      if EList.Count > 0 then begin
        WSL.Add( '' );
        WSL.Add( '*** Other warnings for ' + SrcDPRName );
        K_ReplaceStringsInterval( WSL, -1, 0, EList, 0, -1 );
      end;
      if WSL.Count > 0 then
        K_GetFormTextEdit.EditStrings( WSL, SrcDPRName );

      goto NewDPRSelect;
    end;

    Free;
    WSL.Free;
    EList.Free;
    SList.Free;
  end;

end; // end of K_CheckDPRUses

//**************************************************** K_SyncDPRUsesAndBody ***
// Synchronize Delphi Project Uses from one given *.dpr file to another
//
//      Parameters
// ASrcDPRFName - source project file name
// ADstDPRFName - destination project file name
// ASkipUList   - comma separated string with Unit names which should be skiped from source project
// Result - Returns resulting operation code:
// -1 - source project body markers are exist (if destination project markers are not exist)
//  0 - all done
//  1 - source file doesn't exist
//  2 - destination file doesn't exist
//  3 - source file has not proper Delphi project structure
//  4 - source Delphi project Self Units are not found
//  5 - destination file has not proper Delphi project structure
//  6 - destination Delphi project Self Units are not found
//
function K_SyncDPRUsesAndBody( const ASrcDPRFName, ADstDPRFName, ASkipUList : string ) : Integer;
var
  SWSL, DWSL, USL : TStringList;
  SSInd, DSInd, SEInd, DEInd : Integer;

  // Returns
  // = > 0 if first Unit Name Index,
  // = -1 if uses start is not found,
  // = -2 if proper Unit Name is not found
  // = -3 if uses end is not found,
  function SearchDPRStartPos( AWSL : TStrings; out AEInd : Integer; ASL : TStrings ) : Integer;
  var
    i, j, n : Integer;
    SearchMode : Integer;
    WStr, UName : string;
  begin
    Result := -1;
    AEInd := -1;
    SearchMode := 0;
    i := 0;
    while i < AWSL.Count do
    begin
      WStr := Trim(AWSL[i]);
      n := Length(Wstr);
      case SearchMode of
      0 : begin
          if Pos( 'uses', WStr ) <> 0 then
            SearchMode := 1;
      end;
      1 : begin
        if n = 0 then break;
        if (n > 2) and
           (WStr[2] = '_')   and
           ((WStr[1] = 'N') or (WStr[1] = 'K')) then
        begin
          Result := i;
          SearchMode := 2;
        end;
      end;
      2 :
        if n = 0 then
        begin
          AEInd := i;
          break;
        end
        else if ASL <> nil then
        begin // Search for units to skip
        // Parse Unit Name
          j := 2;
          while (j <= n) and (WStr[j] <> ' ') do Inc(j);
          UName := Copy( WStr, 1, j - 1 );
          if ASL.IndexOf( UName ) >= 0 then
          begin
          // Remove Project Line
            AWSL.Delete(i);
            Continue;
          end;
        end;
      end; // case SearchMode of
      Inc(i);
    end; // while i < AWSL.Count do

    if (SearchMode = 2) and (AEInd >= 0) then Exit;
    if SearchMode = 1 then
      Result := -2
    else if SearchMode = 2 then
      Result := -3;
  end; // function SearchDPRStartPos

label LExit;

begin

  Result := 1;
  if not FileExists(ASrcDPRFName) then Exit;
  Result := 2;
  if not FileExists(ADstDPRFName) then Exit;
  SWSL := TStringList.Create;
  SWSL.LoadFromFile( ASrcDPRFName );

  USL := nil;
  if ASkipUList <> '' then
  begin
    USL := TStringList.Create;
    USL.CommaText := ASkipUList;
  end;
  SSInd := SearchDPRStartPos( SWSL, SEInd, USL );

// Replace Project Uses
  DWSL := nil;
  Result := 4;
  if SSInd = -2 then goto LExit;
  Result := 3;
  if SSInd < 0 then goto LExit;
  DWSL := TStringList.Create;
  DWSL.LoadFromFile( ADstDPRFName );
  DSInd := SearchDPRStartPos( DWSL, DEInd, nil );
  Result := 6;
  if DSInd = -2 then goto LExit;
  Result := 5;
  if DSInd < 0 then goto LExit;
  Result := 0;

  K_ReplaceStringsInterval( DWSL, DSInd, DEInd - DSInd, SWSL, SSInd, SEInd - SSInd );

// Replace Project Body
  DSInd := K_SearchInStrings( DWSL, '//$DPR_BODY_BEGIN', DSInd + SEInd - SSInd, 0, TRUE );
  if DSInd >= 0 then
  begin //
    DEInd := K_SearchInStrings( DWSL, '//$DPR_BODY_END', DSInd + 1, 0, TRUE );
    if DEInd >= 0 then
    begin
      Result := -1;
      SSInd := K_SearchInStrings( SWSL, '//$DPR_BODY_BEGIN', SEInd + 1, 0, TRUE );
      if SSInd >= 0 then
      begin //
        SEInd := K_SearchInStrings( SWSL, '//$DPR_BODY_END', SSInd + 1, 0, TRUE );
        if SEInd >= 0 then
        begin // Replace Project Body
          K_ReplaceStringsInterval( DWSL, DSInd + 1, DEInd - DSInd, SWSL,
                                    SSInd + 1, SEInd - SSInd );
          Result := 0;
        end; // if SEInd >= 0 then
      end; // if SSInd >= 0 then
    end; // if DEInd >= 0 then
  end; // if DSInd >= 0 then


  K_RenameExistingFile( ADstDPRFName );
  DWSL.SaveToFile( ADstDPRFName );

LExit:
  USL.Free;
  SWSL.Free;
  DWSL.Free;
end; // end of K_SyncDPRUsesAndBody

//****************************************** K_RegGEFunc ***
// Registor Global Edit Object Function
//
function K_RegGEFunc( const Name : string; GEFunc : TK_GEFunc;
                            PDContext : Pointer = nil ) : Integer;
var
  WW : TObject;
begin
  TK_GEFunc(WW) := GEFunc;
  if not Assigned(K_GEFuncs) then
    K_GEFPConts := TList.Create;

  Result := K_RegListObject( TStrings(K_GEFuncs), Name, WW );
  if K_GEFPConts.Count < K_GEFuncs.Count then
    K_GEFPConts.Add( PDContext )
  else
    K_GEFPConts.Items[Result] := PDContext;

end; // end of procedure K_RegGEFunc

//****************************************** K_UNRegGEFunc ***
// Unregistor Global Edit Object Function
//
function K_UNRegGEFunc( const Name : string ) : Integer;
begin
  Result := K_GEFuncs.IndexOfName( Name );
//  Result := K_GEFuncs.IndexOf( Name );
  if Result <> -1 then begin
    K_GEFuncs.Delete(Result);
    K_GEFPConts.Delete(Result);
  end;
end; // end of procedure K_UNRegGEFunc

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_GetOwnerForm
//********************************************************** K_GetOwnerForm ***
// Get TComponent Owner Form
//
//     Parameters
// TC     - Delphi Component (TComponent)
// Result - Returns Component's Owner Form object or nil if TC is nil
//
function  K_GetOwnerForm( TC : TComponent ) : TForm;
begin
  Result := nil;
  if TC = nil then Exit;
  while not (TC is TForm) do  TC := TC.Owner;
  Result := TForm(TC);
end; // end of K_GetOwnerForm

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_GetOwnerBaseForm
//****************************************************** K_GetOwnerBaseForm ***
// Get TComponent Owner TN_BaseForm
//
//     Parameters
// TC     - Delphi Component (TComponent)
// Result - Returns Component's Owner TN_BaseForm object or nil if TC is nil or 
//          Owner Form is not TN_BaseForm
//
function  K_GetOwnerBaseForm( TC : TComponent ) : TN_BaseForm;
begin
  TForm(Result) := K_GetOwnerForm( TC );
  if not (Result is TN_BaseForm) then Result := nil;
end; // end of K_GetOwnerBaseForm

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_GetParentForm
//********************************************************* K_GetParentForm ***
// Get TControl Parent Form
//
//     Parameters
// TC     - Delphi Control (TControl)
// Result - Returns Component's Parent Form object or nil if TC is nil
//
function  K_GetParentForm( TC : TControl ) : TForm;
begin
  Result := nil;
  if TC = nil then Exit;
  while not (TC is TForm) do  TC := TC.Parent;
  Result := TForm(TC);
end; // end of K_GetParentForm

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_GetCtrlAlignAttrs
//***************************************************** K_GetCtrlAlignAttrs ***
// Get given TControl Align Attributes
//
//     Parameters
// ATC    - given Delphi Control (TControl)
// AAttrs - Resulting Control Align Attributes
//
procedure K_GetCtrlAlignAttrs( ATC : TControl; var AAttrs : TK_CtrlAlignAttrs );
begin
  AAttrs.CParent      := ATC.Parent;
  AAttrs.CAlign       := ATC.Align;
  AAttrs.CAnchors     := ATC.Anchors;
  AAttrs.CConstraints := ATC.Constraints;
  AAttrs.CLeft        := ATC.Left;
  AAttrs.CTop         := ATC.Top;
  AAttrs.CWidth       := ATC.Width;
  AAttrs.CHeight      := ATC.Height;
end; // end of K_GetCtrlAlignAttrs

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_SetCtrlAlignAttrs
//***************************************************** K_SetCtrlAlignAttrs ***
// Set given TControl Align Attributes
//
//     Parameters
// ATC    - given Delphi Control (TControl)
// AAttrs - Resulting Control Align Attributes
//
procedure K_SetCtrlAlignAttrs( ATC : TControl; const AAttrs : TK_CtrlAlignAttrs );
begin
  ATC.Align       := alNone;
  ATC.Constraints := AAttrs.CConstraints;
  ATC.Left        := AAttrs.CLeft;
  ATC.Top         := AAttrs.CTop;
  ATC.Width       := AAttrs.CWidth;
  ATC.Height      := AAttrs.CHeight;
  ATC.Parent      := AAttrs.CParent;
  ATC.Anchors     := AAttrs.CAnchors;
  ATC.Align       := AAttrs.CAlign;
end; // end of K_SetCtrlAlignAttrs

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_ClearCtrlAlignAttrs
//*************************************************** K_ClearCtrlAlignAttrs ***
// Clear Control Align Attributes record
//
//     Parameters
// AAttrs - Control Align Attributes record to clear
//
procedure K_ClearCtrlAlignAttrs( var AAttrs : TK_CtrlAlignAttrs );
begin
  FillChar( AAttrs, SizeOf(TK_CtrlAlignAttrs), 0 )
end; // end of K_ClearCtrlAlignAttrs

//******************************************** K_CompressJSStrings ***
//  Compressed Text with JS program in SSL and put it to DSL
//
procedure K_CompressJSStrings( DSL, SSL  : TStrings; StringCommentArr,
                  SingleCommentArr, BracketsCommentArr : array of string );
var
  i,j,h1,h2,h3 : Integer;
  str : string;
  SkipMode : Boolean;
  BreaketComment : string;
label Cont;
begin
  SkipMode := false;
  h1 := High(SingleCommentArr);
  h2 := Length(BracketsCommentArr);
  h3 := High(StringCommentArr);
  for i := 0 to SSL.Count - 1 do begin
    str := Trim( SSL[i] );
    if SkipMode then  begin
      if BreaketComment = str then SkipMode := false;
      continue;
    end;
    for j := 0 to h3 do
      if StringCommentArr[j] = str then goto Cont;
    for j := 0 to h1 do
      if K_StrStartsWith( SingleCommentArr[j], str ) then goto Cont;
    j := 0;
    while j < h2 do begin
      if K_StrStartsWith( BracketsCommentArr[j], str ) then begin
        BreaketComment := BracketsCommentArr[j+1];
        SkipMode := true;
        goto Cont;
      end;
      Inc( j, 2 );
    end;
    DSL.Add(str);
  Cont:
    Continue;
  end;
end;

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_SearchOpenedForm
//****************************************************** K_SearchOpenedForm ***
// Search Form in all Application opened Forms List using given search criterion
//
//     Parameters
// AClass         - searching Form Delphi Class (if =NIL then condition is not 
//                  used)
// ASelfName      - searching TN_BaseForm.BFSelfName field value (if =NIL then 
//                  condition is not used)
// AOwner         - searching TN_BaseForm.BFSelfOwnerForm field value (if =NIL 
//                  then condition is not used)
// ASkipForm      - TForm which have to be skiped (if =NIL then condition is not
//                  used)
// AForwardSearch - search direction (if =TRUE then forward serach will be done,
//                  default value is FALSE)
// ATFFunc        - procedure of object for form testing (if is not assigned 
//                  then condition is not used)
// Result         - Returns opened Form or NIL if proper form is not found
//
function K_SearchOpenedForm( AClass : TClass = nil; ASelfName : string = '';
                             AOwner : TForm = nil; ASkipForm : TForm = nil;
                             AForwardSearch : Boolean = false; ATFFunc : TK_TestFormFunc = nil ) : TForm;
var
  i : Integer;
  WComp : TComponent;
  Step, Last : Integer;
begin
  Result := nil;
  if AForwardSearch then begin
    i := 0; Step := 1; Last := Application.ComponentCount;
  end else begin
    i := Application.ComponentCount - 1; Step := -1; Last := -1;
  end;
  while i <> Last do begin
    WComp := Application.Components[i];
    Inc( i, Step );
    if (WComp = ASkipForm)    or
       ((AClass <> nil) and not (WComp is AClass)) or
       ((ASelfName <> '') and (TN_BaseForm(WComp).BFSelfName <> ASelfName)) or
       ((AOwner <> nil) and (TN_BaseForm(WComp).BFSelfOwnerForm <> AOwner)) or
       ( Assigned(ATFFunc) and not ATFFunc( TForm(WComp) ) ) then Continue;
    Result := TForm(WComp);
    break;
  end;
end; //*** end of K_SearchOpenedForm

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_PosTwinForm
//*********************************************************** K_PosTwinForm ***
// Shift given Form upper left corner if other Forms of the same ClassType and 
// with the same BFSelfName are opened
//
//     Parameters
// AForm    - given form
// ADXShift - given Form position horizontal shift (default value is 16)
// ADYShift - given Form position vertical shift (default value is 16)
//
procedure K_PosTwinForm( AForm : TForm; ADXShift : Integer = 16; ADYShift : Integer = 16 );
var
//  i : Integer;
//  WComp : TComponent;
  SForm : TForm;
  ASelfName : string;
begin
  if AForm is TN_BaseForm then
    ASelfName := TN_BaseForm(AForm).BFSelfName
  else
    ASelfName := '';
  SForm := K_SearchOpenedForm( AForm.ClassType, ASelfName, nil, AForm, false );
  if SForm = nil then Exit;
  AForm.Left := SForm.Left + ADXShift;
  AForm.Top  := SForm.Top  + ADYShift;
end; //*** end of K_PosTwinForm;

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_BuildMenuShortCutsList
//************************************************ K_BuildMenuShortCutsList ***
// Build List of all Menu Items ShortCut Texts
//
//     Parameters
// AMItem         - Menu Item
// ASL            - Strings with resulting ShortCuts Texts
// AShortcutsOnly - if =TRUE then only ShortCut text are put to Strings, else 
//                  ShortCut text is appended by MenuItem Caption, Name and 
//                  Action Name
//
procedure K_BuildMenuShortCutsList( AMItem : TMenuItem; ASL : TStrings;
                                    AShortcutsOnly : Boolean  );
var
  i : Integer;
  CMItem : TMenuItem;
  ActionName : string;
  ShortCutText : string;
begin
  for i := 0 to AMItem.Count - 1 do
  begin
    CMItem := AMItem.Items[i];
    with CMItem do
      if ShortCut <> 0 then
      begin
        ShortCutText := ShortCutToText(ShortCut);
        if AShortcutsOnly then
          ASL.Add( ShortCutText )
        else
        begin
          ActionName := '';
          if Action <> nil then
            ActionName := ' A: ' +Action.Name;
          ASL.Add( ShortCutText + ' "' + Caption + '" ' + Name + ActionName  )
        end;
      end; // if ShortCut <> 0 then
    K_BuildMenuShortCutsList( CMItem, ASL, AShortcutsOnly );
  end;

end; //*** end of K_BuildMenuShortCutsList

const K_FK : array [1..12] of string = ('F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12' );

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_BuildAllShortCutsList
//************************************************* K_BuildAllShortCutsList ***
// Build All Possible ShortCuts List
//
//     Parameters
// ASL - Strings for resulting ShortCuts Texts
//
procedure K_BuildAllShortCutsList( ASL : TStrings  );
var
  i : Integer;
begin
  for i := Ord('A') to Ord('Z') do
    ASL.Add( 'CTRL+' + Chr(i) );
  for i := Ord('A') to Ord('Z') do
    ASL.Add( 'CTRL+Alt+' + Chr(i) );
  for i := 1 to High(K_FK) do
    ASL.Add( K_FK[i] );
  for i := 1 to High(K_FK) do
    ASL.Add( 'CTRL+' + K_FK[i] );
  for i := 1 to High(K_FK) do
    ASL.Add( 'Shift+' + K_FK[i] );
  for i := 1 to High(K_FK) do
    ASL.Add( 'Shift+CTRL+' + K_FK[i] );
  for i := Ord('A') to Ord('Z') do
    ASL.Add( 'Shift+CTRL+' + Chr(i) );
end; //*** end of K_BuildAllShortCutsList

//*********************************************** K_GetFFCompTextsToStrings0 ***
//  Get Frame or Form Component Self and Child Components texts to given Strings
//
//     Parameters
//  ATexts - Strings object to get Named Texts for given Frame or Form
//  AComp  - given Frame or Form
//
procedure K_GetFFCompTextsToStrings0( ATexts : TStrings; AComp : TComponent );
var
  WC : TComponent;
  Str : string;
  i : Integer;

begin

  //  Scan Child Components for Frames
  for i := 0 to AComp.ComponentCount - 1 do begin
    WC := AComp.Components[i];
    if WC is TFrame then Continue;
    if (WC is TControl) then
    begin
    // TControls
      if TControl(WC).Action <> nil then Continue;
      Str := TControl(WC).Hint;
      if Str <> '' then
        ATexts.Add( WC.Name + '_h=' + Str );

       if WC is TPanel then
      begin
        Str := TPanel(WC).Caption;
        if (Str <> '') and (Str <> WC.Name) then
          ATexts.Add( WC.Name + '_c=' + Str );
      end
      else
      if WC is TLabel then
      begin
        Str := TLabel(WC).Caption;
        if (Str <> '') and (Str <> WC.Name) then
        begin
          ATexts.Add( WC.Name + '_c=' + Str );
        end
      end
      else
      if WC is TLabeledEdit then
      begin
        Str := TLabeledEdit(WC).EditLabel.Caption;
        if (Str <> '') and (Str <> WC.Name) then
          ATexts.Add( WC.Name + '_c=' + Str );
      end
      else
      if WC is TButton then
      begin
        Str := TButton(WC).Caption;
        if (Str <> '') and (Str <> WC.Name) then
          ATexts.Add( WC.Name + '_c=' + Str );
      end
      else
      if WC is TBitBtn then
      begin
        Str := TBitBtn(WC).Caption;
        if (Str <> '') and (Str <> WC.Name) then
          ATexts.Add( WC.Name + '_c=' + Str );
      end
      else
      if WC is TCheckBox then
      begin
        Str := TCheckBox(WC).Caption;
        if (Str <> '') and (Str <> WC.Name) then
          ATexts.Add( WC.Name + '_c=' + Str );
      end
      else
      if WC is TRadioButton then
      begin
        Str := TRadioButton(WC).Caption;
        if (Str <> '') and (Str <> WC.Name) then
          ATexts.Add( WC.Name + '_c=' + Str );
      end
      else
      if WC is TToolButton then
      begin
        Str := TToolButton(WC).Caption;
        if (Str <> '') and (Str <> WC.Name) then
          ATexts.Add( WC.Name + '_c=' + Str );
      end
      else
      if WC is TSpeedButton then
      begin
        Str := TSpeedButton(WC).Caption;
        if (Str <> '') and (Str <> WC.Name) then
          ATexts.Add( WC.Name + '_c=' + Str );
      end
      else
      if WC is TGroupBox then
      begin
        Str := TGroupBox(WC).Caption;
        if (Str <> '') and (Str <> WC.Name) then
          ATexts.Add( WC.Name + '_c=' + Str );
      end
      else
      if WC is TStaticText then
      begin
        Str := TStaticText(WC).Caption;
        if (Str <> '') and (Str <> WC.Name) then
          ATexts.Add( WC.Name + '_c=' + Str );
      end
      else
      if WC is TMemo then
      begin
        if TMemo(WC).Lines.Count > 0 then
          ATexts.Add( WC.Name + '_i=' + TMemo(WC).Lines.CommaText );
      end
      else
      if WC is TComboBox then
      begin
        if (TComboBox(WC).Style <> csSimple) and
           (TComboBox(WC).Style <> csDropDownList) then Continue;
        if TComboBox(WC).Items.Count > 0 then
          ATexts.Add( WC.Name + '_i=' + TComboBox(WC).Items.CommaText );
      end
      else
      if WC is TRadioGroup then
      begin
        Str := TRadioGroup(WC).Caption;
        if Str <> WC.Name then
          ATexts.Add( WC.Name + '_c=' + Str );
        if TRadioGroup(WC).Items.Count > 0 then
          ATexts.Add( WC.Name + '_i=' + TRadioGroup(WC).Items.CommaText );
      end
      else
      if WC is TTabSheet then
      begin
        Str := TTabSheet(WC).Caption;
        if Str <> WC.Name then
          ATexts.Add( WC.Name + '_c=' + Str );
      end
    end
    else
    begin
    // Other Components
      if WC is TMenuItem then
      begin
        if TMenuItem(WC).Action <> nil then Continue;
        Str := TMenuItem(WC).Hint;
        if Str <> '' then
          ATexts.Add( WC.Name + '_h=' + Str );
        Str := TMenuItem(WC).Caption;
        if (Str <> WC.Name) and (Str <> '-') then
          ATexts.Add( WC.Name + '_c=' + Str );
      end
      else
      if WC is TAction then
      begin
        Str := TAction(WC).Hint;
        if Str <> '' then
          ATexts.Add( WC.Name + '_h=' + Str );
        Str := TAction(WC).Caption;
        if Str <> WC.Name then
          ATexts.Add( WC.Name + '_c=' + Str );
      end
      else
      if WC is TOpenDialog then
      begin
        Str := TOpenDialog(WC).Filter;
        if Str <> '' then
          ATexts.Add( WC.Name + '_f=' + Str );
      end
      else
      if WC is TSaveDialog then
      begin
        Str := TOpenDialog(WC).Filter;
        if Str <> '' then
          ATexts.Add( WC.Name + '_f=' + Str );
      end

    end;
  end;

end; //*** end of K_GetFFCompTextsToStrings0

//************************************************ K_GetFFCompTextsToStrings ***
//  Get Frame or Form Component Self and Child Components texts to given Strings
//
//     Parameters
//  ATexts - Strings object to get Named Texts for given Frame or Form
//  AComp  - given Frame or Form
//

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_GetFFCompTextsToStrings
//*********************************************** K_GetFFCompTextsToStrings ***
//
//
procedure K_GetFFCompTextsToStrings( ATexts : TStrings; AComp : TComponent );
var
  i : Integer;
  CComp : TComponent;
  SInd : Integer;
begin

  //  Scan Child Components for Frames
  for i := 0 to AComp.ComponentCount - 1 do begin
    CComp := AComp.Components[i];
    if not (CComp is TFrame) then Continue;
    SInd := ATexts.Count;
    K_GetFFCompTextsToStrings0( ATexts, CComp );
    if SInd < ATexts.Count then
    begin
      ATexts.Insert( SInd, '[[' + AComp.ClassName + '_' + CComp.Name + ']]' );
      ATexts.Insert( SInd, '' );
      ATexts.Insert( SInd, '' );
      ATexts.Add( '[[/' + AComp.ClassName + '_' + CComp.Name + ']]' );
    end;
  end;

  SInd := ATexts.Count;
  if AComp is TForm then
  begin
    if ('T' <> TForm(AComp).Caption[1]) or
       ('T' + TForm(AComp).Caption <> AComp.ClassName) then
      ATexts.Add( 'Caption=' + TForm(AComp).Caption );
  end;
  K_GetFFCompTextsToStrings0( ATexts, AComp );
  if SInd < ATexts.Count then
  begin
    ATexts.Insert( SInd, '[[' + AComp.ClassName + ']]' );
    ATexts.Insert( SInd, '' );
    ATexts.Insert( SInd, '' );
    ATexts.Add( '[[/' + AComp.ClassName + ']]' )
  end;
end; //*** end of K_GetFFCompTextsToStrings

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_SetFFCompCurLangTexts0
//************************************************ K_SetFFCompCurLangTexts0 ***
// Update Frame or Form Component Self and Child Components texts from Current 
// Language Data
//
//     Parameters
// ATexts - Group of Named Texts for update Frame or Form texts from Current 
//          Language Data
// AComp  - Form or Frame for texts update from Current Language Data
//
procedure K_SetFFCompCurLangTexts0( ATexts : TStrings; AComp : TComponent );
var
  i, j : Integer;
  WC : TComponent;
  FAName, FName : string;
  FCapt, FHint, FItems, FFilter : string;

  procedure SetControlTexts();
  var
    Selected : Boolean;

  begin
    if (WC is TControl) then
    begin
//      if TControl(WC).Action <> nil then Exit;

      if (FHint <> '') then
        TControl(WC).Hint := FHint;
    end;

    Selected := false;
    if FCapt <> '' then
    begin
      if WC is TPanel then
      begin
        Selected := true;
        TPanel(WC).Caption := FCapt;
      end
      else
      if WC is TLabel then
      begin
        Selected := true;
        if Pos( '\#', FCapt ) >= 1 then
          N_ReplaceEQSSubstr( FCapt, '\#', #13#10 );
        TLabel(WC).Caption := FCapt;
      end
      else
      if WC is TLabeledEdit then
      begin
        Selected := true;
        TLabeledEdit(WC).EditLabel.Caption := FCapt;
      end
      else
      if WC is TButton then
      begin
        Selected := true;
        TButton(WC).Caption := FCapt;
      end
      else
      if WC is TBitBtn then
      begin
        Selected := true;
        TBitBtn(WC).Caption := FCapt;
      end
      else
      if WC is TCheckBox then
      begin
        Selected := true;
        TCheckBox(WC).Caption := FCapt;
      end
      else
      if WC is TRadioButton then
      begin
        Selected := true;
        TRadioButton(WC).Caption := FCapt;
      end
      else
      if WC is TToolButton then
      begin
        Selected := true;
        TToolButton(WC).Caption := FCapt;
      end
      else
      if WC is TSpeedButton then
      begin
        Selected := true;
        TSpeedButton(WC).Caption := FCapt;
      end
      else
      if WC is TGroupBox then
      begin
        Selected := true;
        TGroupBox(WC).Caption := FCapt;
      end
      else
      if WC is TStaticText then
      begin
        Selected := true;
        if Pos( '\#', FCapt ) >= 1 then
          N_ReplaceEQSSubstr( FCapt, '\#', #13#10 );
        TStaticText(WC).Caption := FCapt;
      end
      else
      if WC is TTabSheet then
      begin
        Selected := true;
        TTabSheet(WC).Caption := FCapt;
      end
    end;

    if not Selected then
    begin
      if WC is TMemo then
      begin
        if FItems <> '' then
          TMemo(WC).Lines.CommaText := FItems;
      end
      else
      if WC is TComboBox then
      begin
        if FItems <> '' then
          TComboBox(WC).Items.CommaText := FItems;
      end
      else
      if WC is TRadioGroup then
      begin
        if FCapt <> '' then
          TRadioGroup(WC).Caption := FCapt;
        if FItems <> '' then
          TRadioGroup(WC).Items.CommaText := FItems;
      end
      else
      if WC is TMenuItem then
      begin
        if FCapt <> '' then
          TMenuItem(WC).Caption := FCapt;
        if FHint <> '' then
          TMenuItem(WC).Hint := FHint;
      end
      else
      if WC is TAction then
      begin
        if FCapt <> '' then
          TAction(WC).Caption := FCapt;
        if FHint <> '' then
          TAction(WC).Hint := FHint;
      end
      else
      if WC is TOpenDialog then
      begin
        if FFilter <> '' then
          TOpenDialog(WC).Filter := FFilter;
      end
      else
      if WC is TSaveDialog then
      begin
        if FFilter <> '' then
          TSaveDialog(WC).Filter := FFilter;
      end
    end;

  end;

  procedure ParseFieldValue;
  begin
    case FAName[j] of
    'c': FCapt   := ATexts.ValueFromIndex[i];
    'h': FHint   := ATexts.ValueFromIndex[i];
    'i': FItems  := ATexts.ValueFromIndex[i];
    'f': FFilter := ATexts.ValueFromIndex[i];
    end;
  end;

begin
  if AComp is TForm then
  begin
//    ACapt := ATexts.Values['Caption'];
    FCapt := K_GetStringsValueByName( ATexts, 'Caption' );
    if FCapt <> '' then
      TForm(AComp).Caption := FCapt;
  end;

// Scan Child Components
  // Texts to Update Loop
  i := 0;
  while i < ATexts.Count do
  begin
    // Skip lines which do not contain component texts (comments)
    if not (AnsiChar(ATexts[i][1]) in ['A'..'Z', 'a'..'z']) then
    begin
      Inc( i );
      Continue;
    end;

    //Skip "Caption" element
    FAName := ATexts.Names[i];
    if FAName = 'Caption' then
    begin
      Inc( i );
      Continue;
    end;

    // Prepare Caption, Hint, Filter, Items for single component
    FCapt := '';
    FHint := '';
    FItems := '';
    FFilter := '';
    j := Length(FAName);

    // Get First Text for single component
    ParseFieldValue();
    Inc(i);

    // Get Other Texts for single component Loop
    FName := Copy( FAName, 1, j - 1 );
    while i < ATexts.Count do
    begin
      FAName := ATexts.Names[i];
      if not K_StrStartsWith( FName, FAName ) then break;
//      if not AnsiStartsStr( FName, AName ) then break;
      ParseFieldValue();
      Inc(i);
    end; // Get Other Texts for single component Loop

    // Search Component with given Name
    FName := Copy( FName, 1, j - 2 );
    WC := AComp.FindComponent(FName);
    if WC = nil then Continue;

    // Set Caption, Hint, Filter, Items for selected component
    SetControlTexts();
  end; // Texts to Update Loop

end; //*** end of K_SetFFCompCurLangTexts0

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_SetFFCompCurLangTexts
//************************************************* K_SetFFCompCurLangTexts ***
// Update texts in given Child Components of Form or Frame and in all nested 
// Frames from Current Language Texts Data
//
//     Parameters
// AComp - given Form or Frame for texts update
//
procedure K_SetFFCompCurLangTexts( AComp : TComponent );
var
  i, j : Integer;
  RootClass : TClass;
  CComp : TComponent;

  procedure SetParent( FClass : TClass );
  begin
    if FClass.ClassParent <> RootClass then
      SetParent( FClass.ClassParent );
    with K_CurLangData.MTFragmsList do
      if Find( FClass.ClassName, j ) then
        K_SetFFCompCurLangTexts0( TStrings(Objects[j]), AComp );
  end;
begin
  if (K_CurLangData = nil) or (AComp = nil) then Exit;

  if AComp is TForm then
    RootClass := TForm
  else if AComp is TFrame then
    RootClass := TFrame;
  SetParent( AComp.ClassType );

  //  Scan Child Components for Frames
  for i := 0 to AComp.ComponentCount - 1 do
  begin
    CComp := AComp.Components[i];
    if not (CComp is TFrame) then Continue;
    K_SetFFCompCurLangTexts( CComp );
    // Redefined Child Frame Texts
    with K_CurLangData.MTFragmsList do
      if Find( AComp.ClassName + '_' + CComp.Name, j ) then
        K_SetFFCompCurLangTexts0( TStrings(Objects[j]), CComp );
  end;
end; //*** end of K_SetFFCompCurLangTexts

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_PlaceNewLineChars
//***************************************************** K_PlaceNewLineChars ***
// Replace '\#' by new line chars
//
//     Parameters
// ASValue - string value to replace '\#' by #13#10
// Result  - Returns TRUE if ASValue was changed
//
function K_PlaceNewLineChars( var ASValue : string ) : Boolean;
begin
  // Add Updates if needed
  Result := Pos( '\#', ASValue ) >= 1;
  if Result then
     N_ReplaceEQSSubstr( ASValue, '\#', #13#10 );
end;


//##path K_Delphi\SF\K_clib\K_CLib.pas\K_PrepLLLCompTexts
//****************************************************** K_PrepLLLCompTexts ***
// Prepare LLL Form Child Components texts
//
//     Parameters
// AComp     - given Frame or Form
// APrepFunc - text processing function
//
procedure K_PrepLLLCompTexts( AComp : TComponent; APrepFunc : TK_PrepLLLCompTextFunc = nil );
var
  WC : TComponent;
  Str : string;
  i, j : Integer;
  
begin
  if not Assigned(APrepFunc) then
    APrepFunc := K_PlaceNewLineChars;
  //  Scan Child Components for Frames
  for i := 0 to AComp.ComponentCount - 1 do begin
    WC := AComp.Components[i];
    if (WC is TControl) then
    begin
    // TControls
      if WC is TLabel then
      begin
        Str := TLabel(WC).Caption;
        if APrepFunc( Str ) then
          TLabel(WC).Caption := Str;
      end
      else
      if WC is TComboBox then
      begin
        if TComboBox(WC).Items.Count > 0 then
        begin
          for j := 0 to TComboBox(WC).Items.Count - 1 do
          begin
            Str := TComboBox(WC).Items[i];
            if (Length(Str) > 0) and APrepFunc( Str ) then
              TComboBox(WC).Items[i] := Str;
          end;
        end;
      end
    end
  end;

end; //*** end of K_PrepLLLCompTexts


//*********************************************** K_GetFFCompTextsToStrings1 ***
//  Get Frame or Form Component Self and Child Components texts to given Strings
//
//     Parameters
//  ASTexts - StringList object to check Named Texts previouse values
//  AUTexts - Strings object to add Named Texts Updates for given Frame or Form
//  AComp  - given Frame or Form
//
//  Each Component caption is used if it is not empty, it differes from default value and
//  it will not be set programmatically (caption 1-st char <> '_')
//
//  Each Component hint is used if it is not empty and
//  it will not be set programmatically (hint 1-st char <> '_')
//
//  Each TMemo text is used if it is not empty (Lines Count > 0) and it will not be set programmatically (Last Line <> '_')
//
procedure K_GetFFCompTextsToStrings1( ASTexts : TStringList; ARTexts : TStrings; AComp : TComponent );
var
  WC : TComponent;
  Str : string;
  i, L : Integer;
  UseAction : Boolean;
  UseSelSkipAll : Boolean;
  UseSelSkipCapt : Boolean;
  UseSelSkipHint : Boolean;
  UseSelSkipItems : Boolean;
  CAction : TAction;

  procedure AddStringUpdate( SValue : string );
  var
    j, Ind : Integer;

  begin
    // Add Updates if needed
    with ASTexts do
    begin
      if Sorted then
      begin
        Ind := -1;
        if Find( SValue, j ) then
          Ind := j;
      end
      else
        Ind := IndexOf( SValue );
      if Ind >= 0 then Exit;
      ARTexts.Add( SValue );
//      N_Dump1Str( SValue );
    end;
  end;

  procedure AddCaptionStringUpdate( AStr : string );
  begin
    if (not UseAction or (AStr <> CAction.Caption)) and // skip if cation equal to control action caption
       not UseSelSkipCapt and  // skip captions marked by component name
       (AStr <> WC.Name)  and  // skip not changed by user
       (Trim(AStr) <> '') and  // skip captions marked as changed programmatically
       (AStr[1] <> '_') then // skip empty
      AddStringUpdate( WC.Name + '_c=' + AStr );
  end;

  procedure AddHintStringUpdate( AStr : string );
  begin

    if ( (AStr <> '')       and     // skip empty
         (AStr[1] <> '_') ) and     // skip hints marked as changed programmatically
         not UseSelSkipHint then    // skip hints marked by component name
      AddStringUpdate( WC.Name + '_h=' + AStr );
  end;

begin

  if AComp is TForm then
  begin
    if ('T' + TForm(AComp).Caption <> AComp.ClassName) and
       (TForm(AComp).Caption <> '') and
       (TForm(AComp).Caption[1] <> '_') then
      AddStringUpdate( 'Caption=' + TForm(AComp).Caption );
  end;

  //  Scan Child Components for Frames
  for i := 0 to AComp.ComponentCount - 1 do begin
    WC := AComp.Components[i];
// Skip selected component texts by name last char:
// 1 - skip caption
// 2 - skip hint
// 3 - skip hint and caption
// 4 - skip items
// 5 - skip caption and items
// 6 - skip hint and items
// 7 - skip caption, hint and items
    L := Length(WC.Name);
    UseSelSkipAll := WC.Name[L] = '_';
    UseSelSkipCapt := FALSE;
    UseSelSkipHint := FALSE;
    UseSelSkipItems := FALSE;
    if (L > 1) and (WC.Name[L-1] = '_') then
    case WC.Name[L] of
    '1': UseSelSkipCapt := TRUE;
    '2': UseSelSkipHint := TRUE;
    '3': begin
      UseSelSkipCapt := TRUE;
      UseSelSkipHint := TRUE;
    end;
    '4': UseSelSkipItems := TRUE;
    '5': begin
      UseSelSkipCapt := TRUE;
      UseSelSkipItems := TRUE;
    end;
    '6': begin
      UseSelSkipHint := TRUE;
      UseSelSkipItems := TRUE;
    end;
    '0','7': begin
      UseSelSkipAll := TRUE;
    end;
    end;


    if (WC is TFrame) or UseSelSkipAll then Continue;
    UseAction := FALSE;
    if (WC is TControl) then
    begin
    // TControls
      CAction := TAction(TControl(WC).Action);
      UseAction := CAction <> nil;
      if not UseAction or (TControl(WC).Hint <> CAction.Hint) then
        AddHintStringUpdate( TControl(WC).Hint );

      if WC is TPanel then
      begin
        AddCaptionStringUpdate( TPanel(WC).Caption );
      end
      else
      if WC is TLabel then
      begin
        AddCaptionStringUpdate( TLabel(WC).Caption );
      end
      else
      if WC is TLabeledEdit then
      begin
        AddCaptionStringUpdate( TLabeledEdit(WC).EditLabel.Caption );
      end
      else
      if WC is TButton then
      begin
        AddCaptionStringUpdate( TButton(WC).Caption );
      end
      else
      if WC is TBitBtn then
      begin
        AddCaptionStringUpdate( TBitBtn(WC).Caption );
      end
      else
      if WC is TCheckBox then
      begin
        AddCaptionStringUpdate( TCheckBox(WC).Caption );
      end
      else
      if WC is TRadioButton then
      begin
        AddCaptionStringUpdate( TRadioButton(WC).Caption );
      end
      else
      if WC is TToolButton then
      begin
        AddCaptionStringUpdate( TToolButton(WC).Caption );
      end
      else
      if WC is TSpeedButton then
      begin
        AddCaptionStringUpdate( TSpeedButton(WC).Caption );
      end
      else
      if WC is TGroupBox then
      begin
        AddCaptionStringUpdate( TGroupBox(WC).Caption );
      end
      else
      if WC is TStaticText then
      begin
        AddCaptionStringUpdate( TStaticText(WC).Caption );
      end
      else
      if WC is TMemo then
      begin
        with TMemo(WC) do
          if (Lines.Count > 0) and (Lines[Lines.Count-1] <> '_') then
            AddStringUpdate( WC.Name + '_i=' + Lines.CommaText );
      end
      else
      if WC is TComboBox then
      begin
        if (TComboBox(WC).Style = csSimple) or
           (TComboBox(WC).Style = csDropDownList) and
           (TComboBox(WC).Items.Count > 0) and
           not UseSelSkipItems then // special skip by component name
          AddStringUpdate( WC.Name + '_i=' + TComboBox(WC).Items.CommaText );
      end
      else
      if WC is TRadioGroup then
      begin
        AddCaptionStringUpdate( TRadioGroup(WC).Caption );
        if (TRadioGroup(WC).Items.Count > 0) and
           not UseSelSkipItems then
          AddStringUpdate( WC.Name + '_i=' + TRadioGroup(WC).Items.CommaText );
      end
      else
      if WC is TTabSheet then
      begin
        AddCaptionStringUpdate( TTabSheet(WC).Caption );
      end
    end
    else
    begin
    // Other Components
      if WC is TMenuItem then
      begin
        CAction := TAction(TMenuItem(WC).Action);
        UseAction := CAction <> nil;
        if not UseAction or (TMenuItem(WC).Hint <> CAction.Hint ) then
          AddHintStringUpdate( TMenuItem(WC).Hint );
        if TMenuItem(WC).Caption <> '-' then
          AddCaptionStringUpdate( TMenuItem(WC).Caption );
      end
      else
      if WC is TAction then
      begin
        AddHintStringUpdate( TAction(WC).Hint );
        AddCaptionStringUpdate( TAction(WC).Caption );
      end
      else
      if WC is TOpenDialog then
      begin
        Str := TOpenDialog(WC).Filter;
        if Str <> '' then
          AddStringUpdate( WC.Name + '_f=' + Str );
      end
      else
      if WC is TSaveDialog then
      begin
        Str := TSaveDialog(WC).Filter;
        if Str <> ''  then
          AddStringUpdate( WC.Name + '_f=' + Str );
      end

    end;
  end;

end; //*** end of K_GetFFCompTextsToStrings1

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_GetFFCompTexts
//******************************************************** K_GetFFCompTexts ***
// Get texts in given Form and/or Frame Child Components and in all nested Forms
// and/or Frames
//
//     Parameters
// ARLData - TextFragms Object to store Resulting Texts Values
// AComp   - given Form or Frame for texts update
//
procedure K_GetFFCompTexts( ARLData : TN_MemTextFragms; AComp : TComponent );
var
  i, j : Integer;
  RootClass : TClass;
  CComp : TComponent;
  SSL, RSL : TStringList;
//  FrGName : string;


  procedure GetSrcStrings( FClass : TClass );
  var
    WC : TComponent;
  begin
    if FClass.ClassParent <> RootClass then
      GetSrcStrings( FClass.ClassParent );
    with ARLData.MTFragmsList do
    begin
      j := IndexOf( FClass.ClassName );
      if j >= 0 then
      // Add Resulting Strings
        SSL.AddStrings( TStrings(Objects[j]) )
      else
      begin
      // Create Texts if Strings are absent in Result Texts
        WC := TComponent(FClass.NewInstance);
        try
          WC.Create(nil);
          K_GetFFCompTexts( ARLData, WC );
          FreeAndNil(WC);
          // Add Component Texts to SSL
          //   Search is needed because not only this Component Texts may be added
          //   but some Child Frames Texts too
          j := IndexOf( FClass.ClassName );
          if j >= 0 then
            SSL.AddStrings( TStrings(Objects[Count-1]) )
        except
          N_Dump1Str( 'Error >> K_GetFFCompTexts in comp ' + WC.Name );
          WC.Free();
        end;
      end;
    end;
  end;

  procedure GetFrameSrcStrings( FClass : TClass; const AFrameName : string );
  var
    WC : TComponent;
    WChild : TComponent;
  begin
    if FClass = RootClass then Exit;
    // Create Form to Search Frame
    WC := TComponent(FClass.NewInstance);
    try
      WC.Create(nil);
      WChild := WC.FindComponent(AFrameName);
      if WChild <> nil then
      begin
      // Add Frame from Parent Form Strings
        with ARLData.MTFragmsList do
        begin
      // Use Resulting Strings (if Source Strings are Absent)
          j := IndexOf( WC.ClassName + '_' + AFrameName );
          if j >= 0 then
            SSL.AddStrings( TStrings(Objects[j]) );
        end;
        FreeAndNil(WC);
      // Try Parent Form
        GetFrameSrcStrings( FClass.ClassParent, AFrameName );
      end
      else
        FreeAndNil(WC);
    except
      N_Dump1Str( 'Error >> K_GetFFCompTexts in comp ' + WC.Name );
      WC.Free();
    end;
  end;

begin
  if (AComp = nil) or (ARLData = nil) or
     (ARLData.MTFragmsList.IndexOf( AComp.ClassName ) >= 0) or
     ( (K_FFExcludeCompTypeNames <> nil) and
       K_FFExcludeCompTypeNames.Find(AComp.ClassName, j) )then Exit;

  SSL := TStringList.Create();
  RSL := TStringList.Create();

  if AComp is TForm then
    RootClass := TForm
  else if AComp is TFrame then
    RootClass := TFrame;

  // Get Parent Components Childs Strings (add to Resulting Texts if Absent)
  if AComp.ClassType.ClassParent <> RootClass then
  begin
    GetSrcStrings( AComp.ClassType.ClassParent );
    SSL.Sort();
  end;

  // Add Component Self Childs Strings
  K_GetFFCompTextsToStrings1( SSL, RSL, AComp );

  // Add Component Self Childs Strings to Texts if not Empty
  if RSL.Count > 0 then
    ARLData.AddFragm( AComp.ClassName, RSL );

  //  Scan Child Components for Frames
  for i := 0 to AComp.ComponentCount - 1 do
  begin
    CComp := AComp.Components[i];
//    if not (CComp is TFrame) then Continue;
    if not (CComp is TFrame) or
      ( (K_FFExcludeCompTypeNames <> nil) and
       K_FFExcludeCompTypeNames.Find(CComp.ClassName, j) ) then Continue;

    // Proc Frame Component
    SSL.Clear();
    SSL.Sorted := FALSE;

    // Get Frame Parent Components Childs Strings (add to Resulting Texts if Absent)
    RootClass := TFrame;
    GetSrcStrings( CComp.ClassType );

    RootClass := TForm;

    // Get Frame Components Childs Strings from Parent Forms
    GetFrameSrcStrings( AComp.ClassType.ClassParent, CComp.Name );
    SSL.Sort();

    // Add Frame Self Childs Strings
    RSL.Clear();
    K_GetFFCompTextsToStrings1( SSL, RSL, CComp );

    // Add Frame Self Childs Strings to Texts if not Empty
    if RSL.Count > 0 then
      ARLData.AddFragm( AComp.ClassName + '_' + CComp.Name, RSL );

  end;
  RSL.Free;
  SSL.Free;
end; //*** end of K_GetFFCompTexts

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_GetLangTextsCompareStrings
//******************************************** K_GetLangTextsCompareStrings ***
// Get Language TextFragms Objects New and Updated Interface Texts and Text 
// Groups
//
//     Parameters
// AOldLData     - old TextFragms Object to compare
// ANewLData     - new TextFragms Object to compare
// AULData       - Resulting TextFragms Object with Updates
// AddEmptyFragm - if =TRUE then Empty TextGroup will be added to Resulting 
//                 TextFragms object if Group is absent in AOldLData TextFragms,
//                 Filled Group will be added else.
//
// Resulting TextFragms Object contains Text Groups with New and Updated 
// Interface Texts only.
//
procedure K_GetLangTextsCompareStrings( AOldLData, ANewLData, AULData : TN_MemTextFragms; AddEmptyFragm : Boolean );
var
  i, j, Ind : Integer;
  OldSL, NewSL, USL : TStringList;
  GroupName, IText : string;
begin
  AOldLData.MTFragmsList.Sort();
  for i := 0 to ANewLData.MTFragmsList.Count - 1 do
  begin
    GroupName := ANewLData.MTFragmsList[i];
    NewSL := TStringList(ANewLData.MTFragmsList.Objects[i]);
    if not AOldLData.MTFragmsList.Find( GroupName, Ind ) then
    begin
      if AddEmptyFragm then
        AULData.AddFragm( GroupName, '' )
      else
        AULData.AddFragm( GroupName, NewSL )
    end
    else
    begin
      OldSL := TStringList(AOldLData.MTFragmsList.Objects[Ind]);
      OldSL.Sort();
      USL := nil;
      for j := 0 to NewSL.Count - 1 do
      begin
        IText := NewSL[j];
        if OldSL.Find( IText, Ind ) then Continue;
        // Add New or Update String
          if USL = nil then
            USL := TStringList.Create();
          USL.Add( IText );
      end;
      if USL <> nil then
        AULData.AddFragm( GroupName, USL );
      USL.Free;
    end;
  end;
end; // procedure K_GetLangTextsCompareStrings

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_PrepLangTexts
//********************************************************* K_PrepLangTexts ***
// Set Current Language Texts Data Group for K_GetCurLangText1 routine
//
//     Parameters
// ALData          - given Language TextFragms Object to porepare
// ASkipOrderFlags - if Bit0 = 1 then skip groups order, if Bit1 = 1 then skip 
//                   group elements order
//
procedure K_PrepLangTexts( ALData : TN_MemTextFragms; ASkipOrderFlags : Integer = 0 );
var
  i : Integer;
begin
  with ALData.MTFragmsList do begin
    if (ASkipOrderFlags and 1) = 0 then
      Sort();
    if (ASkipOrderFlags and 2) = 0 then
      for i := 0 to Count - 1 do
        TStringList(Objects[i]).Sort();
  end;
end; //*** end of K_PrepLangTexts

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_SetCurLangGroup
//******************************************************* K_SetCurLangGroup ***
// Set Current Language Texts Data Group for K_GetCurLangText1 routine
//
//     Parameters
// AGroupName - name of Language Texts Data Group
// Result     - Returns TRUE if Language Texts Data Group is found.
//
function K_SetCurLangGroup( const AGroupName : string ) : Boolean;
var
  j : Integer;
begin
  Result := false;
  K_CurLangTStrings := nil;
  if K_CurLangData = nil then Exit;
  with K_CurLangData.MTFragmsList do begin
    Result := Find( AGroupName, j );
    if not Result then Exit;
    K_CurLangTStrings := TStrings(Objects[j]);
  end;
end; //*** end of K_SetCurLangGroup

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_GetCurLangText1
//******************************************************* K_GetCurLangText1 ***
// Get Text value from Current Language Texts Data Group by Text Name
//
//     Parameters
// ATextName - name of group element
// ADefValue - default resulting value
// Result    - Returns found Text value or ADefValue if Group Text is not found.
//
function  K_GetCurLangText1( const ATextName : string;
                             const ADefValue : string = '' ) : string;
begin
  Result := ADefValue;
  if K_CurLangTStrings = nil then Exit;
  Result := K_GetStringsValueByName( K_CurLangTStrings, ATextName, ADefValue );
//  Result := K_CurLangTStrings.Values[AElemName];
end; //*** end of K_GetCurLangText1

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_GetCurLangText2
//******************************************************* K_GetCurLangText2 ***
// Get Text value from Current Language Texts Data by Group Name and Text Name
//
//     Parameters
// AGroupName - name of group
// ATextName  - name of text in group
// ADefValue  - default resulting value
// Result     - Returns found Text value or ADefValue if Group or Text are not 
//              found.
//
function K_GetCurLangText2( const AGroupName, ATextName : string;
                            const ADefValue : string = '' ) : string;
var
  j : Integer;
begin
  Result := ADefValue;
  if K_CurLangData = nil then Exit;
  with K_CurLangData.MTFragmsList do
  begin
    if not Find( AGroupName, j ) then Exit;
    Result := K_GetStringsValueByName( TStrings(Objects[j]), ATextName, ADefValue );
//    Result := TStrings(Objects[j]).Values[AElemName];
  end;
end; //*** end of K_GetCurLangText2

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_SetStringsByVaues
//***************************************************** K_SetStringsByVaues ***
// Set Strings by given Strings.Values
//
//     Parameters
// ARList - Resulting Strings to set
// ASList - Strings with  source Values
//
procedure K_SetStringsByVaues( ARList : TStrings; ASList : TStrings );
var
  i : Integer;
begin
  ARList.Clear();
  ARList.BeginUpdate;
  for i := 0 to ASList.Count - 1 do
    ARList.Add( ASList.ValueFromIndex[i] );
  ARList.EndUpdate;
end; // procedure K_SetStringsByVaues

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_SetStringsByNames
//***************************************************** K_SetStringsByNames ***
// Set Strings by given Strings.Names
//
//     Parameters
// ASList - Resulting Strings to set
// ASList - Strings with  source Names
//
procedure K_SetStringsByNames( ARList : TStrings; ASList : TStrings );
var
  i : Integer;
begin
  ARList.Clear();
  ARList.BeginUpdate;
  for i := 0 to ASList.Count - 1 do
    ARList.Add( ASList.Names[i] );
  ARList.EndUpdate;
end; // procedure K_SetStringsByNames


//##path K_Delphi\SF\K_clib\K_CLib.pas\K_SetStringsByIniSectionVaues
//******************************************* K_SetStringsByIniSectionVaues ***
// Add IniFile Section Values to given strings
//
//     Parameters
// AIniSName - IniFile Section Name
// ARList    - Strings to set
//
procedure K_SetStringsByIniSectionVaues( const AIniSName : string; ARList : TStrings );
var
  WrkSL: TStringList;
begin
  WrkSL := TStringList.Create();
  N_CurMemIni.ReadSectionValues( AIniSName, WrkSL );
  K_SetStringsByVaues( ARList, WrkSL );
  WrkSL.Free;
end; // procedure K_SetStringsByIniSectionVaues

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_ReplaceStringsVaues
//*************************************************** K_ReplaceStringsVaues ***
// Replace Values in Strings by Given Values
//
//     Parameters
// ARList - list with <Name>=<Value> items
// ARInd  - start index to replace
// AVList - list with values
//
procedure K_ReplaceStringsVaues( ARList : TStrings; ARInd : Integer; AVList : TStrings );
var
  i, n : Integer;
begin
  n := Min( ARList.Count - ARInd, AVList.Count) - 1;
  ARList.BeginUpdate;
  for i := 0 to n do
    K_ReplaceListValue( ARList, i + ARInd, AVList[i] );
  ARList.EndUpdate;
end; // procedure K_ReplaceStringsVaues

//************************************************** K_LoadDIBFromVFileByRI ***
// Load Image content from given virtual file
//
//     Parameters
// AImage     - TImage Object to load
// AVFileName - virtual file name
// Result     - Returns 0 if file is OK (ADIBObj <> nil)
//              1 if file is absent or corrupted
//              2 if file has not proper format
//
function K_LoadDIBFromVFileByRI( ARI: TObject; const AVFileName: string; out ADIBObj : TN_DIBObj ) : Integer;
var
  VFile: TK_VFile;
  Stream: TStream;
begin
  ADIBObj := nil;
  Result := 1;
  K_VFAssignByPath( VFile, K_ExpandFileName( AVFileName ) );
  if K_VFOpen( VFile ) = -1 then Exit; // Open error

  Stream := K_VFStreamGetToRead( VFile );
  with TK_RasterImage(ARI) do
  begin
    RIOpenStream( Stream );
    RIGetDIB( 0, ADIBObj );
    RIClose();
  end;
  K_VFStreamFree(VFile);

  Result := 0;
  if ADIBObj = nil then
    Result := 2;
end; //*** end of function K_LoadDIBFromVFileByRI

//##path K_Delphi\SF\K_clib\K_CLib.pas\K_LoadTImage
//************************************************************ K_LoadTImage ***
// Load Image content from given virtual file
//
//     Parameters
// AImage     - TImage Object to load
// AVFileName - virtual file name
// Result     - Returns "Transparent" color value (Bottom Left pixel Value) or
//              -1 if AImage.Graphic was not set or
//              -2 Source image file is JPEG
//
function K_LoadTImage( AImage: TImage; const AVFileName: string ) : Integer;
var
  DataSize: integer;
  VFName: string;
  TmpBitmap: TBitmap;
  VFile: TK_VFile;
  Stream: TStream;
  DIBObj: TN_DIBObj;
  RI: TK_RasterImage;
begin
  Result := -2;

  // Prepare VFile
  VFName := K_ExpandFileName( AVFileName );
  K_VFAssignByPath( VFile, VFName );
  DataSize := K_VFOpen( VFile );
  if DataSize = -1 then Exit; // Open error

  // Get DIB Obj from File
  Stream := K_VFStreamGetToRead( VFile );
//  RI := nil;
//  if RI.RIEncTypeByFileExt(AVFileName) = rietPNG then
//    RI := TK_RIImLib.Create
//  else
  RI := TK_RIGDIP.Create;

  RI.RIOpenStream( Stream );
  DIBObj := nil;
  RI.RIGetDIB( 0, DIBObj );

  if DIBObj <> nil then
  begin // Set Image Graphic

    // Get "Transp" Color Value
    if RI.RICurEncType <> rietJPG then
      Result := DIBObj.GetPixColor( Point(0,DIBObj.DIBSize.Y-1) );

    // Set TImage.Picture.Graphic by TBitmap created from DIB
    TmpBitmap := DIBObj.CreateBitmap( DIBObj.DIBRect );
    AImage.Picture.Graphic := TmpBitmap;
    TmpBitmap.Free;

    DIBObj.Free;
  end; // end of Set Image Graphic

  // Free Created Objects
  RI.RIClose();
  RI.Free;
  K_VFStreamFree(VFile);

end; //*** end of procedure K_LoadTImage

{*** TK_DFPLScriptExec ***}
//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\Create
//************************************************* TK_DFPLScriptExec.Create ***
//
constructor TK_DFPLScriptExec.Create;
begin
  WWSL := TStringList.Create;
  WWSL1 := TStringList.Create;
  DstDirsList := TStringList.Create;
  SrcDirsList := TStringList.Create;
// Prepare SrcMemIni
//  SrcIniFile := TMemIniFile.Create( N_CurMemIni.FileName );
  SrcIniFile := TMemIniFile.Create( '' );
  N_CurMemIni.GetStrings(SrcDirsList);
  SrcIniFile.SetStrings( SrcDirsList );
  SrcIniFile.Rename( N_CurMemIni.FileName, FALSE );

// Prepare SrcPathsList
  SrcDirsList.Assign( K_AppFileGPathsList );
  SrcBasePath := K_AppFileGPathsList.Values[K_MVAppDirExe];
  CurSrcDirsList := SrcDirsList;

  STK := TK_Tokenizer.Create( '' );
  STK.setBrackets( '''''""' );
  CallMemIniFile := SrcIniFile;
  DFPLInitCMList();
end; //*** end of TK_DFPLScriptExec.Create

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\Destroy
//************************************************ TK_DFPLScriptExec.Destroy ***
//
//
destructor TK_DFPLScriptExec.Destroy;
begin
  WWSL.Free;
  WWSL1.Free;
  DstDirsList.Free;
  SrcDirsList.Free;
  DstIniFile.Free;
  SrcIniFile.Free;
  STK.Free;
  if CMListFreeFlag then CMList.Free;
  inherited;
end; //*** end of TK_DFPLScriptExec.Destroy

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLExecCommand
//*************************************** TK_DFPLScriptExec.DFPLExecCommand ***
// Execute DFPL parsed Command
//
//     Parameters
// ACommandName - command name
// AParam0      - command parameter
// AParam1      - command parameter
// AParam2      - command parameter
// AParam3      - command parameter
// AParam4      - command parameter
//
// DFPL Command line looks like
//
// AParam0 ACommandName AParam1 AParam2 AParam3 AParam4
//
procedure TK_DFPLScriptExec.DFPLExecCommand( const ACommandName, AParam0  : string;
                                          AParam1, AParam2, AParam3, AParam4 : string );
// CommandName AParam0 AParam1 AParam2 AParam3 AParam4
//   CommandName is Command:
// (-, --, BF>, BF>-, RP>, NP>D, NP>S, RI+, RI>, RI>-, WSE>, IFE>, TFE>, VFE>, =, =+,
//  F+>, F>, +>, >, >>, ->, ->>, -->>, TF>, >>TF,
//  =+>,  =+>-,  =>,  =>-, =>!,
//  =F+>, =F+>-, =F>, =F>-,
//  =>>,   =>>-, =TF>, =TF>-, =>>TF, =>>TF-,
//  >>DPR, DPRU>, =#, =#D, #=, #=#, #=#D, =CRC, !DUMP, M>, DUMP>, UF> )
// if CommandName = '-'  then DO:
//   if AParam0 = '*' then
//   - Clear All Section in New IniFile
//   if AParam0 <> '*' then
//   - Clear Section ([AParam0]) in New IniFile
// if CommandName = '--' then DO:
//   if AParam0 = '*' then
//   - Erase All Section in New IniFile
//   if AParam0 <> '*' then
//   - Erase Section ([AParam0]) in New IniFile
// if CommandName = 'BF>'  and AParam0 = '' then DO:
//   - Save CBFile with FileName = AParam1
// if CommandName = 'BF>-' and AParam0 = '' then DO:
//   - Close CBFile with FileName = AParam1 FileDate = AParam2
// if CommandName = 'RP>'  then DO:
//   - Set New RootPath=APfaram0
// if CommandName = 'NP>D'  then DO:
//   - Set New Dest NamedPaths Context from object specified by AParam0 and AParam1
//   if AParam0 = "SI" then NamedPaths Context would be got from Src IniFile
//   else if AParam0 = "RI" NamedPaths Context would be got from Result IniFile
//   AParam1 - Section Name, if AParam1 = "" then Section name is "FileGPaths"
// if CommandName = 'NP>S'  then DO:
//   - Set New Src NamedPaths Context from object specified by AParam0 and AParam1
//   if AParam0 = "SI" then NamedPaths Context would be got from Src IniFile
//   else if AParam0 = "RI" NamedPaths Context would be got from Result IniFile
//   AParam1 - Section Name, if AParam1 = "" then Section name is "FileGPaths"
// if CommandName = 'RI+'  then DO: Create MemIniFile -> AParam0 = IniName,
//   - Create new MemIniFile with FileName = AParam0 (without path and extension)
//     and Set MemIniFile Values from FileName = AParam1
//     AParam2 is Encode IniFile Flag, if AParam2 <> '' then Encode IniFile,
//     AParam3 is Save IniFile Flag,   if AParam3 <> '' then Skip Saving IniFile
// if CommandName = 'RI>' then DO:
//   - Save IniFile to FileName = AParam1
//   - Reserved Space  = AParam2 (Number Of Bytes)
// if CommandName = 'RI>-' then DO:
//   - Save IniFile to FileName = AParam1 and Close it
//   - Reserved Space  = AParam2 (Number Of Bytes)
// if CommandName = 'F+>' then DO: (native OS copy)
//   - Copy File with FileName = AParam0 to AParam1 new FileName
// if CommandName = 'F>' then DO: (native OS copy)
//   - Copy File with FileName = AParam0 to AParam1 RootFilesPath
// if CommandName = '+>' then DO:
//   - Copy File with FileName = AParam0 to AParam1 new FileName
//     AParam2 is compress flags,
//     if AParam2[2] = 'Z' then begin
//       start chars are compress flags
//       if AParam2[2] = '' or AParam2[2] = ' ' or AParam2[2] = '2' then High files compression
//       if AParam2[2] = '1' then Middle files compression
//       if AParam2[2] = '0' then Low files compression
//       if AParam2[2] = 'U' then files uncompression
//     end;
// if CommandName = '>' then DO:
//   - Copy File with FileName = AParam0 to AParam1 RootFilesPath
//     AParam2 is compress flags,
//     if AParam2[1] = 'Z' then begin
//       start chars are compress flags
//       if AParam2[2] = '' or AParam2[2] = ' ' or AParam2[2] = '2' then High files compression
//       if AParam2[2] = '1' then Middle files compression
//       if AParam2[2] = '0' then Low files compression
//       if AParam2[2] = 'U' then files uncompression mode
//     end;
//     AParam3 - Reserved Space (Number Of Bytes)
// if CommandName = '>>' then DO:
//   - Copy Files from RootFilesPath = AParam0 to new RootFilesPath = AParam1
//     AParam2 is copy pattern, if AParam2 = '' then file copy pattern = *.*
//     AParam3 is copy subfolders and compress flags,
//       if AParam3 = '' then SkipSubFoldersFlag is false
//       else begin
//         if AParam3[1] = 'Z' then begin
//           start chars are compress flags
//           if AParam3[2] = '' or AParam3[2] = ' ' or AParam3[2] = '2' then High files compression
//           if AParam3[2] = '1' then Middle files compression
//           if AParam3[2] = '0' then Low files compression
//           if AParam3[2] = 'U' then files uncompression mode
//         end;
//         if Other AParam3 chars are not whitespaces then SkipSubFoldersFlag is true
//       end;
// if CommandName = '->' then DO:
//   - Delete File with FileName = AParam0
// if CommandName = '->>' then DO:
//   - Delete all Files from RootFilesPath = AParam0
//     AParam1 must be "*"
//     AParam2 is delete pattern, if AParam2 = '' then file copy pattern = *.*
//     AParam3 delete subfolders flag, if AParam3 <> '' then SkipSubFoldersFlag is true
// if CommandName = '-->>' then DO:
//   - Remove Folder with RootFilesPath = AParam0
// if CommandName = 'TF>' then DO:
//   - Copy Text Fragms File with FileName = AParam0 to AParam1 new RootFilesPath
// if CommandName = '>>TF' then DO:
//   - Copy Files with RootFilesPath = AParam0 to AParam1 new Text Fragms FileName
//     AParam2 is copy pattern, if AParam2 = '' then file copy pattern = *.*
//     AParam3 copy subfolders flag, if AParam3 <> '' then SkipSubFoldersFlag is true
// if CommandName = 'WSE>' then DO:
//   - Call ShellExecute(FileOperation, FileName, ExecParams, DefFolder )
//       FileOperation = AParam1 (Edit, Explore, Open, Print, Properties)
//       FileName = AParam0
//       ExecParams = AParam2
//       DefFolder = AParam3
// if CommandName = 'IFE>' then DO:
//   - Execute Section [AParam0] from IniFile for Call DFPL Scripts (SrcIniFile)
// if CommandName = 'TFE>' then DO:
//   - Execute Section [AParam0] from Special TextFragms for Scripts Call
// if CommandName = 'VFE>' then DO:
//   - Execute List of Commands From File with FileName = AParam0
// if CommandName = 'BREAK>' then DO:
//   - Break Commands List Execution 
// if CommandName = '=' then DO:
//   if AParam1 =  * then Copy All Section Keys From Current IniFile to New IniFile
//      if AParam2 <> '' then Section Keys starts with AParam2 are not copied
//   if AParam1 <> * then
//   - [AParam0].AParam1 := AParam2 in New IniFile
// if CommandName = '=+' then DO:
//   if AParam1 =  * then Copy All Section Keys From Current IniFile to New IniFile
//   if AParam1 <> * then
//   - [AParam0].AParam1 := [AParam0].AParam1 from Current IniFile to New IniFile
// if CommandName = '=F>' then DO:
//   if AParam1 <> * then
//   - Copy File with FileName = [AParam0].AParam1 in Current IniFile to AParam2 RootFilesPath
//   - Set [AParam0].AParam1 in New IniFile with New FileName (AParam2)
//   if AParam1 = * then
//   - Copy All files specified by Current IniFile Section ([AParam0]) Idents to AParam1 new RootFilesPath
//   - Set New IniFile Section ([AParam0]) Idents with new FileNames
// if CommandName = '=F>-' then DO:
//   if AParam1 <> * then
//   - Copy File with FileName = [AParam0].AParam1 in Current IniFile to AParam2 RootFilesPath
//   if AParam1 = * then
//   - Copy All files specified by Current IniFile Section ([AParam0]) Idents to AParam1 new RootFilesPath
// if CommandName = '=F+>' then DO:
//   - Copy File with FileName = [AParam0].AParam1 in Current IniFile to AParam2 new FileName
//   - Set [AParam0].AParam1 in New IniFile with New FileName (AParam2)
// if CommandName = '=F+>-' then DO:
//   - Copy File with FileName = [AParam0].AParam1 in Current IniFile to AParam2 new FileName
// if CommandName = '=>' then DO:
//   if AParam1 <> * then
//   - Copy File with FileName = [AParam0].AParam1 in Current IniFile to AParam2 RootFilesPath
//   - Set [AParam0].AParam1 in New IniFile with New FileName (AParam2)
//   if AParam1 = * then
//   - Copy All files specified by Current IniFile Section ([AParam0]) Idents to AParam1 new RootFilesPath
//   - Set New IniFile Section ([AParam0]) Idents with new FileNames
//    AParam3 is compress flags,
//    if AParam3[1] = 'Z' then begin
//      start chars are compress flags
//      if AParam3[2] = '' or AParam3[2] = ' ' or AParam3[2] = '2' then High files compression
//      if AParam3[2] = '1' then Middle files compression
//      if AParam3[2] = '0' then Low files compression
//      if AParam3[2] = 'U' then files uncompression
//    end;
// if CommandName = '=>-' then DO:
//   if AParam1 <> * then
//   - Copy File with FileName = [AParam0].AParam1 in Current IniFile to AParam2 RootFilesPath
//   if AParam1 = * then
//   - Copy All files specified by Current IniFile Section ([AParam0]) Idents to AParam1 new RootFilesPath
//    AParam3 is compress flags,
//    if AParam3[1] = 'Z' then begin
//      start chars are compress flags
//      if AParam3[2] = '' or AParam3[2] = ' ' or AParam3[2] = '2' then High files compression
//      if AParam3[2] = '1' then Middle files compression
//      if AParam3[2] = '0' then Low files compression
//      if AParam3[2] = 'U' then files uncompression
//    end;
// if CommandName = '=>!' then DO:
//   if AParam1 <> * then
//   - Set [AParam0].AParam1 in New IniFile with New FileName (AParam2)
//   if AParam1 = * then
//   - Set New IniFile Section ([AParam0]) Idents with new FileNames
// if CommandName = '=+>' then DO:
//   - Copy File with FileName = [AParam0].AParam1 in Current IniFile to AParam2 new FileName
//   - Set [AParam0].AParam1 in New IniFile with New FileName (AParam2)
//    AParam3 is compress flags,
//    if AParam3[1] = 'Z' then begin
//      start chars are compress flags
//      if AParam3[2] = '' or AParam3[2] = ' ' or AParam3[2] = '2' then High files compression
//      if AParam3[2] = '1' then Middle files compression
//      if AParam3[2] = '0' then Low files compression
//      if AParam3[2] = 'U' then files uncompression
//    end;
// if CommandName = '=+>-' then DO:
//   - Copy File with FileName = [AParam0].AParam1 in Current IniFile to AParam2 new FileName
//    AParam3 is compress flags,
//    if AParam3[1] = 'Z' then begin
//      start chars are compress flags
//      if AParam3[2] = '' or AParam3[2] = ' ' or AParam3[2] = '2' then High files compression
//      if AParam3[2] = '1' then Middle files compression
//      if AParam3[2] = '0' then Low files compression
//      if AParam3[2] = 'U' then files uncompression
//    end;
// if CommandName = '=>>' then DO:
//   - Copy Files with RootFilesPath = [AParam0].AParam1 in Current IniFile to AParam2 new RootFilesPath
//     AParam3 is copy pattern, if AParam3 = '' then file copy pattern = *.*
//     AParam4 is copy subfolders and compress flags,
//       if AParam4 = '' then SkipSubFoldersFlag is false
//       else begin
//         if AParam4[1] = 'Z' then begin
//           start chars are compress flags
//           if AParam4[2] = '' or AParam4[2] = ' ' or AParam4[2] = '2' then High files compression
//           if AParam4[2] = '1' then Middle files compression
//           if AParam4[2] = '0' then Low files compression
//           if AParam4[2] = 'U' then files uncompression
//         end;
//         if Other AParam4 chars are not whitespaces then SkipSubFoldersFlag is true
//       end;
//   - Set [AParam0].AParam1 in New IniFile with New RootFilesPath (AParam2)
// if CommandName = '=>>-' then DO:
//   - Copy Files with RootFilesPath = [AParam0].AParam1 in Current IniFile to AParam2 new RootFilesPath
//     AParam3 is copy pattern, if AParam3 = '' then file copy pattern = *.*
//     AParam4 is copy subfolders and compress flags,
//       if AParam4 = '' then SkipSubFoldersFlag is false
//       else begin
//         if AParam4[1] = 'Z' then begin
//           start chars are compress flags
//           if AParam4[2] = '' or AParam4[2] = ' ' or AParam4[2] = '2' then High files compression
//           if AParam4[2] = '1' then Middle files compression
//           if AParam4[2] = '0' then Low files compression
//           if AParam4[2] = 'U' then files uncompression
//         end;
//         if Other AParam4 chars are not whitespaces then SkipSubFoldersFlag is true
//       end;
// if CommandName = '=TF>' then DO:
//   - Copy Text Fragms File with FileName = [AParam0].AParam1 in Current IniFile to AParam2 new RootFilesPath
//   - Set [AParam0].AParam1 in New IniFile with New RootFilesPath (AParam2)
// if CommandName = '=TF>-' then DO:
//   - Copy Text Fragms File with FileName = [AParam0].AParam1 in Current IniFile to AParam2 new RootFilesPath
// if CommandName = '=>>TF' then DO:
//   - Copy Files with RootFilesPath = [AParam0].AParam1 in Current IniFile to AParam2 new Text Fragms FileName
//     AParam3 is copy pattern, if AParam3 = '' then file copy pattern = *.*
//     AParam4 copy subfolders flag, if AParam4 <> '' then SkipSubFoldersFlag is true
//   - Set [AParam0].AParam1 in New IniFile with New TextFragms FilesName (AParam2)
// if CommandName = '=>>TF-' then DO:
//   - Copy Files with RootFilesPath = [AParam0].AParam1 in Current IniFile to AParam2 new Text Fragms FileName
//     AParam3 is copy pattern, if AParam3 = '' then file copy pattern = *.*
//     AParam4 copy subfolders flag, if AParam4 <> '' then SkipSubFoldersFlag is true
// if CommandName = >>DPR then DO:
//   - Copy all needed project files
//     AParam0 is source project file name
//     AParam1 is destination Project File Name
//     AParam2 is Skip Pascal Files Copy Flag
//     if AParam1 = '' then destination Project File Name is defined as <Resulting DFPL Name>.dpr
//     if AParam2 <> '' then only project *.dpr, *.dof and *.res files are copied
// if CommandName = DPRU> then DO:
//   - Copy section uses from given source project file to destination project files
//     AParam0 is source project file name
//     AParam1 is destination Project File Name
//     AParam2 is Skip Modules Names
//     if AParam1 = '' then destination Project File Name is defined as <Resulting DFPL Name>.dpr
//     if AParam2 = '' then all USES modules are copy else given modules are not copied
// if CommandName = '=#' then DO:
//   Set value from [AParam0].AParam1 from Curкent IniFile to MacroVar with AParam2 name
// if CommandName = '=#D' then DO:
//   Set value from [AParam0].AParam1 from Resulting IniFile to MacroVar with AParam2 name
// if CommandName = '#=' then DO:
//   Set value from AParam1 to MacroVar with AParam0 name
// if CommandName = '#=#' then DO:
//   Set value from [AParam1].AParam2 from Curкent IniFile to MacroVar with AParam0 name
// if CommandName = '#=#D' then DO:
//   Set value from [AParam1].AParam2 from Resulting IniFile to MacroVar with AParam0 name
// if CommandName = '=CRC' then DO:
//   if AParam1 <> * then
//   - Set New IniFile [AParam0].AParam1
//    if AParam2 <> '' then
//      CRC will be calculated for file with AParam2 name Expanded by SrcPaths Context
//    else
//      CRC will be calculated for file with AParam1 name Expanded by DestPaths Context
//    Resulting  value will be <AParam1>=<CRC>
//   if AParam1 = * then
//     if AParam2 = '' then
//      - Calculate CRC for all files specified by Current IniFile Section ([AParam0])
//      - Set New IniFile Section ([AParam0]) by strings:
//        <FILEi>=<CRCi>
//     else
//       if AParam2 <> '' then AParam2 = DestPath + files pattern
//         - Calculate CRC for all files specified by AParam2 files pattern
//         if AParam3 <> '' then
//           CRC will be calculated for each file with AParam3 + FileName Expanded by SrcPaths Context
//         else
//           CRC will be calculated for each file with ExtractPath(AParam2) + FileName Expanded by DestPaths Context
//      Resulting values will be <ExtractPath(AParam2)+FileName>=<CRC>
// if CommandName = '!DUMP' then DO:
//   if AParam0 = '+' then
//     Set all commands text Show Message in Info mode (usually status bar)
//     if AParam1 <> '' then
//       Set all commands text Show Message in Warning mode (usually modal dialog for each command line)
//   else
//     Drop all commands text Show Message Mode
// if CommandName = M> then DO:
//   - Processing text from given source pattern file to destination file using macro context
//     AParam0 is source pattern file name
//     AParam1 is destination file Name
//     AParam2 is macro context - string set of elements <name>=<value> separated by char given in AParam3
//     AParam3 is macro context elements separator char
//     AParam4 is macro pocessing commands set. Available Values:
//  A  - macroassebling
//  R  - macroreplacing
//  AR - macroassebling and macroreplacing
//  RA - macroreplacing and macroassebling 
//     if AParam3 = '' then char ',' separator will be used
//     if AParam4 = '' then pocessing commands set is 'A'
// if CommandName = 'DUMP>' then DO:
//  Dump Ini File Info to standart DUMP
//   if AParam0 = - then dump only comment from AParam3
//   if AParam0 = '*' then dump all IniFile Sections
//   if AParam0 <> * then dump one IniFile Section Name=AParam0
//   if AParam1 =  * then dump All Section Keys
//   if AParam1 <> * then dump given section Key
//   if AParam2 =  > then dump from Current IniFile
//   if AParam2 =  < then dump from New IniFile
//   AParam3 comment which is put to dump as prefix
// if CommandName = 'UF>'  then DO:
// Upadate from given resulting folders by newer files
//     AParam0 is source folder name
//     AParam1 is files pattern
//     AParam2 is string with resulting folders set for file update (divided by space)
//     AParam3 is resulting folder for new files
//
var
  UDCBF : TN_UDBase;
  AVFCFlags : TK_VFileCopyFlags;
  SkipSetResultIdent : Boolean;
  NativeOSCopy : Boolean;
  SkipFileCopy : Boolean;

type TK_CopyFileMode = (cfmNewFileName,cfmNewFilePath);

  procedure SetSectionFileCRC1( const Sect, SectIDent, SrcFName : string );
  var
    FName : string;
    UnExpName : string;
  begin
    if DstIniFile = nil then Exit;
    if SrcFName = '' then
    begin
      FName := DFPLExpandByDestDirs( SectIDent );
      UnExpName := SectIDent;
    end
    else
    begin
      FName := DFPLExpandBySrcDirs( SrcFName );
      UnExpName := SrcFName;
    end;

    if not FileExists(FName) then
    begin
      CurCommandWarning := Sect + ': file "' + UnExpName + '" not found';
      Exit;
    end;
    DstIniFile.WriteString( Sect, SectIDent, IntToStr(K_CalcFileCRC( FName )) );
  end; // procedure SetSectionFileCRC1

  procedure SetAllSectionFilesCRC( const Sect : string );
  var
    i : Integer;
  begin
    WWSL.Clear;
    SrcIniFile.ReadSection( Sect, WWSL );
    for i := 0 to WWSL.Count - 1 do
      SetSectionFileCRC1( Sect, WWSL[i], '' );
  end; // procedure SetAllSectionFilesCRC

  procedure SetAllDirFilesCRC( const Sect, DstPathPat, SrcPath : string  );
  var
    i : Integer;
    Path : string;
    DPath, SPath : string;
    Pat : string;
    DstFName, SrcFName : string;
  begin
    Path := DFPLExpandByDestDirs( DstPathPat );
    SPath := ExtractFilePath( Path );
    Pat := Copy( Path, Length(SPath) + 1, Length(Path) );
    if SrcPath <>  '' then
      SPath := DFPLExpandBySrcDirs( SrcPath );
    WWSL1.Clear;
    K_ScanFilesTree( SPath, DFPLCollectDirFiles, Pat );
    DPath := Copy( DstPathPat, 1, Length(DstPathPat) - Length(Pat) );
    SrcFName := '';
    for i := 0 to WWSL1.Count - 1 do
    begin
//      SetSectionFileCRC1( Sect, Path + WWSL1[i] );
      DstFName := DPath + WWSL1[i];
      if SrcPath <>  '' then
        SrcFName := SPath + WWSL1[i];
      SetSectionFileCRC1( Sect, DstFName, SrcFName );

    end;
  end; // procedure SetAllDirFilesCRC

  function ParseNativeCopyFileFlag( const ACommand : string ) : string;
  begin
    NativeOSCopy := false;
    Result := ACommand;
    if (Result <> '') and
       ((Result[1] = 'F') or (Result[1] = 'f')) then begin
      Result := Copy( Result, 2, Length(Result) );
      NativeOSCopy := true;
    end;
  end; // function ParseNativeCopyFileFlag

  function ParseSkipIniCopyFileFlags( ACommand : string ) : string;
  var
    LastCharInd : Integer;
    CutCommandFlag : Boolean;
  begin
    SkipSetResultIdent := false;
    SkipFileCopy := false;
    CutCommandFlag := false;
    Result := ACommand;
    if Result = '' then Exit;
    LastCharInd := Length(Result);
    if Result[LastCharInd] = '!' then
    begin
    // Is needed to skip file(s) copy - only section ident(s) set
      SkipFileCopy := true;
      CutCommandFlag := true;
    end
    else
    if Result[LastCharInd] = '-' then
    begin
    // Is needed to skip section ident(s) set - only file(s) copy
      SkipSetResultIdent := true;
      CutCommandFlag := true;
    end;

    if CutCommandFlag then
      Result := Copy( Result, 1, LastCharInd - 1 );
  end; // function ParseSkipIniCopyFileFlags

  procedure SetNamedPathsContext( var NPC : TStrings; const IniFID : string; SectName : string );
  var
    MIF : TMemIniFile;
    ExePathValue : string;
  begin
    if SectName = '' then SectName := K_FileGPathsIniSection;
    if SectName = K_FileGPathsIniSection then begin
      if IniFID = 'SI' then
        NPC := SrcDirsList
      else
        NPC := DstDirsList;
    end else begin
      MIF := nil;
      if IniFID = 'SI' then begin
        MIF := SrcIniFile;
        ExePathValue := SrcBasePath;
      end else if IniFID = 'RI' then begin
        MIF := DstIniFile;
        ExePathValue := DstBasePath;
      end;
      DFPLSetNamedPathsStrings( NPC, MIF, ExePathValue, SectName );
    end;
  end; // procedure SetNamedPathsContext

  function SafeForceDir( const DirName : string ) : Boolean;
  begin
    Result := K_VFForceDirPath( K_OptimizePath(DirName) );
    if not Result then
      CurCommandWarning := 'Не удалось создать каталог "'+DirName+'"';
//      K_ShowMessage( 'Не удалось создать каталог "'+DirName+'"' );
  end; // function SafeForceDir

  procedure CopyDirFiles( const SrcPath, DestPath, FilePat : string  );
  var
    ESrcPath, EDestPath : string;
  begin
    ESrcPath := IncludeTrailingPathDelimiter( DFPLExpandBySrcDirs( SrcPath ) );
    EDestPath := IncludeTrailingPathDelimiter( DFPLExpandByDestDirs( DestPath ) );
    if NativeOSCopy then
      K_CopyFolderFiles( ESrcPath, EDestPath, FilePat, [K_cffOverwriteNewer, K_cffOverwriteReadOnly] )
    else
      K_VFCopyDirFiles( ESrcPath, EDestPath, K_DFCreatePlain,
                        FilePat, AVFCFlags );
  end; // procedure CopyDirFiles

  function CopyFile1( const SrcFName, DestFName : string; CopyFileMode : TK_CopyFileMode;
                      AVFCFlags : TK_VFileCopyFlags ) : string;
  var
    DFPath, SFPath : string;
    VFile: TK_VFile;
//    EData : Byte;
  begin
    SFPath := DFPLExpandBySrcDirs( SrcFName );
    if CopyFileMode = cfmNewFilePath then
      Result := DestFName + ExtractFileName(SFPath)
    else
    begin // CopyFileMode = cfmNewFileName
      if DestFName[Length(DestFName)] = '*' then
        Result := ChangeFileExt(DestFName, ExtractFileExt(SFPath) )
      else
        Result := DestFName;
    end;


    if SkipFileCopy then Exit;
    DFPath := DFPLExpandByDestDirs( Result );
    if NativeOSCopy then
    begin
      case K_CopyFile( SFPath, DFPath, [K_cffOverwriteNewer, K_cffOverwriteReadOnly] ) of
        3: CurCommandWarning := 'File ' + SFPath + ' not found';
        4: CurCommandWarning := 'File ' + Result + ' could not be created';
        5: CurCommandWarning := 'Path ' + Result + ' could not be created';
      end;
    end else
    begin
{
      if SrcFName = '*' then
      begin // Create empty file
        K_VFAssignByPath( VFile, ExtractFilePath(DFPath) );
        if not K_VFForceDirPath0(VFile) then
          CurCommandWarning := 'File ' + Result + ' path error'
        else
        begin
          K_VFAssignByPath( VFile, DFPath );
          K_VFWriteAll ( VFile, @VFile, 1 );
          if SResultIniFileDataSize <> '' then
            DFPLSetVFileDataSpace( VFile );

        end;
      end
      else
}
      begin // Real Copy
        case K_VFCopyFile( SFPath, DFPath, K_DFCreatePlain, AVFCFlags ) of
        K_vfcrSrcNotFound : CurCommandWarning := 'File ' + SFPath + ' not found';
        K_vfcrReadSrcError: CurCommandWarning := 'File ' + SFPath + ' read error';
        K_vfcrDestPathError: CurCommandWarning := 'File ' + Result + ' path error';
        K_vfcrDecompressionError: CurCommandWarning := 'File ' + SFPath + ' decompression error';
        K_vfcrCompressionError: CurCommandWarning := 'File ' + Result + ' compression error';
        else
        if SResultIniFileDataSize <> '' then
        begin
          K_VFAssignByPath( VFile, DFPath );
          DFPLSetVFileDataSpace( VFile );
        end;
        end;
      end;
    end;
  end; // function CopyFile1

  procedure CopySectionFile1( const Sect, Ident, DestFName  : string);
  var
    FName : string;
    LWarningText, PrevCurCommandWarning : string;
  begin
    if DstIniFile = nil then Exit;
    FName := SrcIniFile.ReadString( Sect, Ident, '' );
    if FName = '' then Exit;
    PrevCurCommandWarning := CurCommandWarning;
    FName := CopyFile1( FName, DestFName, cfmNewFilePath, [K_vfcOverwriteNewer] );
    if (PrevCurCommandWarning <> '') and
       (CurCommandWarning <> PrevCurCommandWarning) then
    begin // Save Intenal Warning Info
      LWarningText := 'DFPL: Warning :  ' + PrevCurCommandWarning;
      DFPLShowInfo( LWarningText, K_msWarning );
      Inc(CommandWarningsCount);
    end;
    if not SkipSetResultIdent then
      DstIniFile.WriteString( Sect, Ident, FName );
  end; // procedure CopySectionFile1

  procedure CopyAllSectionFiles( const Sect, DestLPath  : string  );
  var
    i : Integer;
  begin
    WWSL.Clear;
    SrcIniFile.ReadSection( Sect, WWSL );
    for i := 0 to WWSL.Count - 1 do
      CopySectionFile1( Sect, WWSL[i], DestLPath );
  end; // procedure CopyAllSectionFiles

  procedure CopySection( const Sect, Skip : string; RSect : string );
  var
    i : Integer;
    Name : string;
  begin
    if DstIniFile = nil then Exit;
    WWSL.Clear;
    SrcIniFile.ReadSectionValues( Sect, WWSL );
    if RSect = '' then
      RSect := Sect;
    for i := 0 to WWSL.Count - 1 do
    begin
      Name := WWSL.Names[i];
      if (Skip <> '') and K_StrStartsWith( Skip, Name ) then Continue;
      DstIniFile.WriteString( RSect, Name, WWSL.ValueFromIndex[i] );
    end;
  end; // procedure CopySection

  procedure ClearSection( const Sect : string; const Ident : string = '' );
  var
    i : Integer;
  begin
    if DstIniFile = nil then Exit;
    if Ident <> '' then begin
      DstIniFile.DeleteKey( Sect, Ident );
      Exit;
    end;
    WWSL.Clear;
    SrcIniFile.ReadSectionValues( Sect, WWSL );
    for i := 0 to WWSL.Count - 1 do
      DstIniFile.DeleteKey( Sect, WWSL.Names[i] );
  end; // procedure ClearSection

  procedure ClearAllSections;
  var
    i : Integer;
  begin
    if DstIniFile = nil then Exit;
    WWSL.Clear;
    DstIniFile.ReadSections( WWSL );
    for i := 0 to WWSL.Count - 1 do
      ClearSection( WWSL[i] );
  end; // procedure ClearAllSections

//  function ExecuteCopyFilesCommands ( const CName, SrcName, DestName : string; var FPat, Flags : string ) : string;
  function ExecuteCopyFilesCommands ( const CName, SrcName, DestName : string; FPat, Flags : string ) : string;
  var
    RecurseSubFolders : Boolean;
    DelFileFlags : TK_DelFolderFilesFlags;
    WCName, WExtStr, WSrcPath: string;

    procedure ParseFlags( AFlags : string );
    begin
      Flags := AFlags;
      AVFCFlags := [K_vfcOverwriteNewer];
      if Flags <> '' then
      begin
        Flags := UpperCase(Flags);
        if Flags[1] = 'Z' then
        begin
          if Length( Flags ) >= 2 then
          begin
            if Flags[2] = 'U' then
              AVFCFlags := AVFCFlags + [K_vfcDecompressSrc]
            else if Flags[2] = '0' then
              AVFCFlags := AVFCFlags + [K_vfcCompressSrc0]
            else if Flags[2] = '1' then
              AVFCFlags := AVFCFlags + [K_vfcCompressSrc1]
            else
              AVFCFlags := AVFCFlags + [K_vfcCompressSrc2];
            Flags[1] := ' ';
            Flags[2] := ' ';
            Flags := TrimLeft( Flags );
          end
          else
          begin
            Flags := '';
            AVFCFlags := AVFCFlags + [K_vfcCompressSrc2];
          end;
        end;
      end;

      RecurseSubFolders := Flags = '';
      if RecurseSubFolders then
        AVFCFlags := AVFCFlags + [K_vfcRecurseSubfolders];
    end;

  begin
    Result := '';
    if SrcName = '' then Exit;

//    if (FPat = '') and K_StrStartsWith( '>>', CName ) then FPat := '*.*';
    if (FPat = '') and ( Pos( '>>', CName ) <> 0 ) then FPat := '*.*';
    Result := DestName;
    WCName := CName;
    if WCName = '>' then
    begin
      SResultIniFileDataSize := Flags;
      ParseFlags( FPat );
      Result := CopyFile1( SrcName, DestName, cfmNewFilePath, AVFCFlags );
    end
    else
    if WCName = '+>' then
    begin
      SResultIniFileDataSize := Flags;
      ParseFlags( FPat );
      Result := CopyFile1( SrcName, DestName, cfmNewFileName, AVFCFlags );
    end
    else
    if WCName = 'TF>' then
      K_VFCopyFromTextFragmsFile( DFPLExpandByDestDirs( DestName ), DFPLExpandBySrcDirs(SrcName) )
    else
    if WCName = '>>TF' then
    begin
      ParseFlags( Flags );
      K_VFCopyToTextFragmsFile( DFPLExpandByDestDirs( DestName ), DFPLExpandBySrcDirs(SrcName), FPat, AVFCFlags )
    end
    else
    if K_StrStartsWith( '>>', WCName ) then
    begin
      WSrcPath := SrcName;
      if Length(WCName) > 2 then
      begin
        if (WCName[3] = '.') then
        begin
          WExtStr := Copy( WCName, 3, Length(WCName) );
          if Length(WExtStr) = 1 then
            WExtStr := ''; // if '.' then Extension should be ''
          WSrcPath := ChangeFileExt(SrcName, WExtStr);
        end
      end;
      ParseFlags( Flags );
      CopyDirFiles( WSrcPath, DestName, FPat )
    end
    else
    if WCName = '->' then
      K_VFDeleteFile( DFPLExpandByDestDirs( SrcName ) )
    else
    if WCName = '-->>' then
      K_VFRemoveDir( DFPLExpandByDestDirs( SrcName ) )
    else
    if WCName = '->>' then
    begin
      ParseFlags( Flags );
      DelFileFlags := [K_dffRemoveReadOnly];
      if RecurseSubFolders then
        DelFileFlags := [K_dffRemoveReadOnly,K_dffRecurseSubFolders];
      K_VFDeleteDirFiles( DFPLExpandByDestDirs( SrcName ), FPat, DelFileFlags )
    end
    else
      Result := '';
  end; // function ExecuteCopyFilesCommands

  function TestProjFileName( const AFName : string ) : Integer;
  // =-1 if not DPR File Ext
  // =0  if DPR File Ext
  // =1  if No File Ext (File path)
  var AFext : string;

  begin
    AFext := ExtractFileExt( AFName );
    Result := 0;
    if AFExt <> '' then
    begin
      if UpperCase(AFext) <> '.DPR' then
        Result := -1;
    end else
      Result := 1;
  end;

  procedure CopyDPRFiles( SrcDPRName, DestDPRName : string; SkipPasCopy : Boolean = FALSE );
  var
    SPRPath, DPRName, DPRPath, WStr : string;
//    FExt : string;
    i1, i2, j1, j2 : Integer;
    WChar : Char;
    PASName : string;
  label ContinueUses, EndUses, CommandEnd;

  begin
  //*** check source DPR file name
    SrcDPRName := DFPLExpandBySrcDirs( SrcDPRName );
    if TestProjFileName( SrcDPRName ) <> 0 then begin
      CurCommandWarning := 'Wrong Delphi project source file name ' + SrcDPRName;
      Exit;
    end else
      DPRName := ChangeFileExt( ExtractFileName( SrcDPRName ), '' );

  //*** check destination DPR file name
    if (DestDPRName = '*') or (DestDPRName = '' ) then
      DestDPRName := ChangeFileExt( DstIniFile.FileName, '.dpr' )
    else
      DestDPRName := DFPLExpandByDestDirs( DestDPRName );

    case TestProjFileName( DestDPRName ) of
      1: begin // use source DPR name
        DestDPRName := IncludeTrailingPathDelimiter( DestDPRName ) + DPRName + '.dpr';
      end;
      0: begin // use new DPR name
        DPRName := ChangeFileExt( ExtractFileName( DestDPRName ), '' );
      end;
     -1: begin
        CurCommandWarning := 'Wrong Delphi project resulting file name ' + DestDPRName;
        Exit;
      end;
    end;

  //*** DPR file
    NativeOSCopy := true;
    DestDPRName := CopyFile1( SrcDPRName, DestDPRName, cfmNewFileName, [] );
    if CurCommandWarning <> '' then Exit;

    SPRPath := ExtractFilePath(SrcDPRName);
    DPRPath := ExtractFilePath(DestDPRName);

  //*** DPR Uses files copy and Project create

    WWSL.LoadFromFile( DestDPRName );
    WWSL1.Clear;
    i2 := -1;
    for i1 := 0 to WWSL.Count - 1 do begin
      WStr := WWSL[i1];
      if i1 = 0 then
      begin
        j1 := 1;
        while WStr[j1] = ' ' do Inc(j1);
        j2 := j1;
        while WStr[j2] <> ' ' do Inc(j2);
        WWSL1.Add( copy( WStr, j1, j2 - j1 + 1 ) + DPRName + ';' );
//        WWSL1.Add( 'program ' + DPRName + ';' );
      end
      else
      if Pos( 'uses', WStr ) <> 0 then begin
        i2 := i1;
        break;
      end
      else
        WWSL1.Add(WStr);
    end;
    if i2 = -1 then
    begin
      CurCommandWarning := 'Delphi project USES statement not found';
      Exit;
    end;

    WWSL1.Add('uses');
    for i1 := i2 + 1 to WWSL.Count - 1 do
    begin
    //*** Parse USES Loop
      WStr := WWSL[i1];
      if (WStr[1] = '{') or (WStr[1] = '/') then
      begin
        WWSL1.Add(WStr);
        Continue;
      end;
      j1 := 1;
      while WStr[j1] = ' ' do Inc(j1);
      while true do
      begin
      //*** Parse USES Element Loop
        Inc(j1);
        WChar := WStr[j1];
        case WChar of
          ',' : begin // Delphi unit
            WWSL1.Add(WStr);
            goto ContinueUses;
          end;
          ';' : begin // last Delphi unit
            i2 := i1;
            WWSL1.Add(WStr);
            goto EndUses;
          end;
          ' ' : begin // Self PAS file
          //*** copy PAS file
            // parse UNIT name
            Inc(j1);
            while WStr[j1] <> '''' do Inc(j1);

            // parse FILE name
            Inc(j1);
            j2 := j1;
            while WStr[j1] <> '''' do Inc(j1);
            PASName := Copy( WStr, j2, j1 - j2 );

            // Copy PAS file
            if not SkipPasCopy then
            begin
              CopyFile1( SPRPath + PASName, DPRPath, cfmNewFilePath, [] );
              if CurCommandWarning <> '' then Exit; // Copy File Error
            end;

            WChar := WStr[j1 + 1];
            if WChar = ' ' then
            begin
              // Copy DFM file
              if not SkipPasCopy and
                 (N_PosEx( ': CoClass}', WStr, j1 + 2, Length(WStr) ) = 0) then begin // check if DFM file
                CopyFile1( SPRPath + ChangeFileExt( PASName, '.dfm' ), DPRPath, cfmNewFilePath, [] );
                if CurCommandWarning <> '' then Exit; // Copy File Error
              end;
              WChar := WStr[Length(WStr)];
            end;

            WWSL1.Add( Copy( WStr, 1, j2 - 1 ) + ExtractFileName( PASName ) + Copy( WStr, j1, Length(WStr) ) );
            if WChar = ',' then goto ContinueUses
            else
            begin
              i2 := i1;
              goto EndUses;
            end;
          end; // *** end of PAS file copy
        end; //*** end of case WChar
      end; //*** End of Parse USES Element Loop

ContinueUses:
    end; //*** End of Parse USES Loop

    CurCommandWarning := 'Delphi project end of USES list not found';
    Exit;

EndUses:
    // Replace Resulting DPR File
    K_ReplaceStringsInterval( WWSL1,  -1, 0, WWSL, i2 + 1, -1 );
    WWSL1.SaveToFile( DestDPRName );

    // Copy other Project Files
    CopyFile1( ChangeFileExt( SrcDPRName, '.res' ),
               ChangeFileExt( DestDPRName, '.res' ), cfmNewFileName, [] );
    CopyFile1( ChangeFileExt( SrcDPRName, '.dof' ),
               ChangeFileExt( DestDPRName, '.dof' ), cfmNewFileName, [] );
  end; // procedure CopyDPRFiles

  procedure UpdateDPR( SrcDPRName, DestDPRName, ASkipUList : string );
  var
    DPRName : string;
  begin
  //*** check source DPR file name
    SrcDPRName := DFPLExpandBySrcDirs( SrcDPRName );
    if TestProjFileName( SrcDPRName ) <> 0 then
    begin
      CurCommandWarning := 'Wrong Delphi project source file name ' + SrcDPRName;
      Exit;
    end
    else
      DPRName := ChangeFileExt( ExtractFileName( SrcDPRName ), '' );

  //*** check destination DPR file name
    if (DestDPRName = '*') or (DestDPRName = '' ) then
      DestDPRName := ChangeFileExt( DstIniFile.FileName, '.dpr' )
    else
      DestDPRName := DFPLExpandByDestDirs( DestDPRName );

    case K_SyncDPRUsesAndBody( SrcDPRName, DestDPRName, ASkipUList ) of
   -1: CurCommandWarning := 'File ' + DestDPRName + ' needed body markers in sourc prj';
    1: CurCommandWarning := 'File ' + SrcDPRName  + ' not found ';
    2: CurCommandWarning := 'File ' + DestDPRName + ' not found ';
    3: CurCommandWarning := 'File ' + SrcDPRName  + ' has not proper Delphi project structure ';
    4: CurCommandWarning := 'File ' + SrcDPRName  + ' - "N_..." or "K_..." Units are not found ';
    5: CurCommandWarning := 'File ' + DestDPRName + ' has not proper Delphi project structure ';
    6: CurCommandWarning := 'File ' + DestDPRName + ' - "N_..." or "K_..." Units are not found ';
    end;

  end; // procedure UpdateDPR

  procedure FileMacroProcessing( SrcFName, DestFName, MacroContext, MCSeparator, MCommands : string );
  var
    SWSL, MSL : TStringList;
    ICom : Integer;
  begin
    SrcFName := DFPLExpandBySrcDirs( SrcFName );
    if not FileExists(SrcFName) then
    begin
      CurCommandWarning := 'File ' + SrcFName + ' not found ';
      Exit;
    end;

    if MacroContext = '' then
    begin
      CurCommandWarning := 'Macro context is empty';
      Exit;
    end;
    MCommands := UpperCase( MCommands );
    if MCommands = '' then
      MCommands := 'A';

    MSL := TStringList.Create;
    MSL.Delimiter := ',';
    if MCSeparator <> '' then
      MSL.Delimiter := MCSeparator[1];
    MSL.DelimitedText := MacroContext;

    SWSL := TStringList.Create;
    SWSL.LoadFromFile( SrcFName );

    for ICom := 1 to Length(MCommands) do
    begin
      if MCommands[ICom] = 'A' then
        SWSL.Text := K_StringMacroAssembling( SWSL.Text, #13#10'//%', '%', MSL )
      else
      if MCommands[ICom] = 'R' then
        SWSL.Text := K_StringMListReplace( SWSL.Text, MSL, K_ummSaveMacro )
      else
        CurCommandWarning := 'Wrong Macro Command "' + MCommands[ICom] + '" ';
      if ICom = 2 then break;
    end;

    DestFName := DFPLExpandByDestDirs( DestFName );

    if K_ForceFilePath( DestFName ) then
      SWSL.SaveToFile( DestFName )
    else
      CurCommandWarning := 'File path ' + DestFName + ' creation error';


    MSL.Free;
    SWSL.Free;
  end; // procedure FileMacroProcessing

  procedure DumpSectionKey( CIF : TMemIniFile; const Comment, Sect, Key : string );
  var
    i : Integer;
    SVal : string;
  begin
    if Key = '*' then
    begin
      WWSL1.Clear;
      CIF.ReadSectionValues( Sect, WWSL1 );
      N_Dump2Str( format( '%s [%s]', [Comment, Sect] ) );
      for i := 0 to WWSL1.Count - 1 do
        N_Dump2Str( WWSL1.Names[i] + '=' + WWSL1.ValueFromIndex[i] );
    end
    else
    begin
      SVal := CIF.ReadString( Sect, Key, '' );
      if SVal = '' then
      begin
        if CIF.ReadString( Sect, Key, '1' ) = '1' then // Value is absent
          SVal := ' is absent'
        else
          SVal := '=' + SVal;
      end
      else
        SVal := '=' + SVal;
      N_Dump2Str( format( '%s [%s].%s%s', [Comment, Sect, Key, SVal] ) );
    end;
  end; // procedure DumpSectionKey

  procedure DumpInfo( const Comment, Sect, Key, DumpFType : string );
  var
    i : Integer;
    CIF : TMemIniFile;
  begin
    if Sect = '-' then
    begin
      N_Dump2Str( Comment );
      Exit;
    end;

    CIF := DstIniFile;
    if DumpFType = '>' then
      CIF := SrcIniFile;

    if CIF = nil then
    begin
      N_Dump2Str( format( '%s Ini-file %s is absent', [Comment,DumpFType] ) );
      Exit;
    end;
    WWSL.Clear;
    if Sect = '*' then
    begin
      N_Dump2Str( Comment );
      CIF.ReadSections( WWSL );
      for i := 0 to WWSL.Count - 1 do
        DumpSectionKey( CIF, '', WWSL[i], Key );
    end
    else
      DumpSectionKey( CIF, Comment, Sect, Key );
  end; // procedure DumpInfo

  procedure UpdateFilesFromDistr( const ASrcPath, ASrcPat, AResFoldersSet, ANewFilesFolder : string );
  var
  //  FilePath : string;
    SL, SLS, SLP : TStringList;
    i : Integer;
    SrcFName, DstFName, SrcUFName, DstUFName, NewFPath, SrcPath : string;
    FoundFlag : Boolean;
    F: TSearchRec;
    PathInd : Integer;
    SFDT, DFDT : TDateTime;

    function CopySVNFile : Boolean;
    begin
      Result := CopyFile( PChar(SrcFName), PChar( DstFName ), false );
      if Result then Exit;
      N_Dump1Str( format( 'Copy %s >> %s fails', [SrcFName,DstFName] ) );

      if CurCommandWarning <> '' then Exit;
      CurCommandWarning := 'Some files copy fails';
    end; // function CopySVNFile : Boolean;

    function FileSizeGet( const AFName : string ) : Integer;
    var
      FStream: TFileStream;
    begin
      Result := 0;
      FStream := K_TryCreateFileStream( AFName, fmOpenRead + fmShareDenyNone );
      if FStream = nil then Exit;
      Result := FStream.Size;
      FStream.Free;
    end;

  label LExit;
  begin

    N_Dump2Str( format( 'Update files start: "%s" in "%s" from "%s" New="%s"',
                        [ASrcPat, AResFoldersSet, ASrcPath, ANewFilesFolder] ) );

    SL := TStringList.Create;
    SLS := TStringList.Create;
    SLP := TStringList.Create;

    SLS.CommaText := Trim(AResFoldersSet);
    if SLS.Count = 0 then
    begin
      CurCommandWarning := 'Resulting Paths are not specified';
      goto LExit;
    end;

    for i := 0 to SLS.Count - 1 do
    begin
      SLS[i] := Trim(SLS[i]);
      SL.Add(IncludeTrailingPathDelimiter(DFPLExpandBySrcDirs(SLS[i])));
    end;


    SLP.CommaText := Trim(ASrcPat);
    for i := 0 to SLP.Count - 1 do
    begin
      SLP[i] := Trim(SLP[i]);
      if SLP[i][1] = '.' then
        SLP[i] := '*' + SLP[i];
    end;

    NewFPath := Trim(ANewFilesFolder);
    if NewFPath <> '' then
    begin
      NewFPath := IncludeTrailingPathDelimiter(DFPLExpandBySrcDirs(NewFPath));
      if not K_ForceFilePath( NewFPath ) then
      begin
        CurCommandWarning := format( 'Path %s >> %s creation fails',
                                     [ANewFilesFolder,NewFPath] );
        goto LExit;
      end;
    end;

    SrcPath := IncludeTrailingPathDelimiter(DFPLExpandByDestDirs(ASrcPath));

    if FindFirst( SrcPath + '*.*', faAnyFile, F ) = 0 then
      repeat
        if (F.Name[1] = '.') or
           ((F.Attr and faDirectory) <> 0) then continue;

        if SLP.Count > 0 then
        begin
          FoundFlag := FALSE;
          for i := 0 to SLP.Count - 1 do
          begin
            FoundFlag := TRUE;
            if K_CheckTextPattern( F.Name, SLP[i] ) then break;
            FoundFlag := FALSE;
          end;
          if not FoundFlag then Continue;
        end; // if SLP.Count > 0 then

        FoundFlag := FALSE;
        PathInd := -1;
        for i := 0 to SL.Count - 1 do
        begin
          PathInd := i;
          DstFName := SL[i] + F.Name;
          FoundFlag := TRUE;
          if FileExists(DstFName) then Break;
          FoundFlag := FALSE;
        end; // for i := 0 to SL.Count - 1 do

        SrcFName := SrcPath + F.Name;
        if not FoundFlag then
        begin // New file Copy
          if NewFPath <> '' then
          begin
            DstFName := NewFPath + F.Name;
            if CopySVNFile then
              N_Dump2Str( format( '%s is new',[F.Name] ) );
            end
          else
            N_Dump2Str( format( '%s is new but new path is not set',[F.Name] ) );
        end
        else
        begin // if FoundFlag then
          SFDT := K_GetFileAge( SrcFName );
          DFDT := K_GetFileAge( DstFName );
          if SFDT > DFDT then // dest file is older
          begin
            DstUFName := DstFName;
            SrcUFName := SrcFName;
            SrcFName := DstUFName;
            DstFName := ChangeFileExt( DstFName, '.~~' + Copy( ExtractFileExt(SrcFName), 2, 10 ) );
            if CopySVNFile then
            begin
              DstFName := DstUFName;
              SrcFName := SrcUFName;
              if CopySVNFile then
                N_Dump2Str( format( '%s\%s is updated', [SLS[PathInd],F.Name] ) );
            end;
          end // if SFDT > DFDT then // dest file is older
          else
          if SFDT < DFDT then // dest file is newer
          begin // copying file may change it date
//            if ((DFDT - SFDT) > 0.00001) or
//               (FileSizeGet(SrcFName) <> FileSizeGet(DstFName)) then
              N_Dump2Str( format( '!!! %s is newer',[DstFName] ) );
          end
        end;
      until FindNext( F ) <> 0;
    SysUtils.FindClose( F );

LExit: //********
    SL.Free;
    SLS.Free;
    SLP.Free;
    N_Dump2Str( 'Update files fin' );
  end; // procedure UpdateFilesFromDistr

var
  LInd : Integer;
  SetByIdent : Boolean;
  IdentIsAbsent : Boolean;
  ShExOp : string;
  CurIniVal : string;
  WCommandName : string;
  WSEFileName : string;
  WSectName : string;
  WIdentName : string;
  WMacroName : string;

begin
  CurCommandWarning := '';
  SResultIniFileDataSize := '';
  if K_StrStartsWith( 'UF>', ACommandName ) then
  begin
    UpdateFilesFromDistr(AParam0, AParam1, AParam2, AParam3);
  end
  else
  if K_StrStartsWith( 'DUMP>', ACommandName ) then
  begin
    DumpInfo( AParam3, AParam0, AParam1, AParam2 );
{!!! DEBUG DUMP Compound Files State
    Include(K_TextModeFlags, K_txtSkipUDMemData);
    K_SaveTreeToText( K_FilesRootObj, K_SerialTextBuf, TRUE, [K_lsfJoinAllSLSR] );
    Exclude(K_TextModeFlags, K_txtSkipUDMemData);
    K_SerialTextBuf.TextStrings.SaveToFile( 'C:\Delphi_prj_new\Builds\CMS_Distr_3.085.10_Twain10N\!DistrFiles\files.txt' );
}
  end
  else
  if K_StrStartsWith( '!DUMP', ACommandName ) then
  begin
    ShowCommandDumpStatus := 0;
    if AParam0 = '+' then
    begin
      ShowCommandDumpStatus := 1;
      if AParam1 <> '' then
        ShowCommandDumpStatus := 2;
    end;
  end
  else
  if K_StrStartsWith( 'BF>', ACommandName ) then
  begin
    UDCBF := K_MVCBFileGetRoot( DFPLExpandByDestDirs( AParam1 ) );
    if ACommandName = 'BF>' then
      K_MVCBFileSave( UDCBF )
    else if ACommandName = 'BF>-' then
    begin
      WSEFileName := K_ExpandFileName(UDCBF.ObjInfo);
      K_MVCBFileClose( UDCBF );
      if AParam2 <> '' then
        K_SetFileAge( WSEFileName, K_StrToDateTime(  AParam2 ) );
    end;
  end
  else
  if K_StrStartsWith( 'RI>', ACommandName ) then
  begin
    WSEFileName := DFPLExpandByDestDirs( AParam1 );
    SResultIniFileDataSize := AParam2;
    if ACommandName = 'RI>' then
      DFPLSaveMemIni( WSEFileName )
    else if ACommandName = 'RI>-' then
      DFPLFreeMemIni( WSEFileName )
  end
  else if ACommandName = 'RI-' then
    FreeAndNil( DstIniFile )
  else
  if ACommandName = 'RP>' then
    DFPLSetDestRootPath( AParam0 )
  else
  if ACommandName = 'NP>S' then
    SetNamedPathsContext( CurSrcDirsList, AParam0, AParam1 )
  else
  if ACommandName = 'NP>D' then
    SetNamedPathsContext( CurDstDirsList, AParam0, AParam1 )
  else
  if ACommandName = 'RI+' then
    DFPLCreateDestMemIni( AParam0,
                  (AParam2 <> ''), (AParam3 <> ''), AParam1 )
  else
  if ACommandName = 'WSE>' then
  begin
  //*** ShellExecute
    ShExOp := AParam1;
    if ShExOp = '' then ShExOp := 'Open';
    WSEFileName := DFPLExpandBySrcDirs( AParam0 );
    if FileExists( WSEFileName ) then
      K_ShellExecute( ShExOp, WSEFileName, -1, nil,
                      DFPLExpandByDestDirs( AParam2 ), DFPLExpandByDestDirs( AParam3) )
    else
    begin
      CurCommandWarning := 'ShellExecute file ' + WSEFileName + ' not found';
      Exit
    end;
  end // if ACommandName = 'WSE>' then
  else
  if ACommandName = 'IFE>' then
  //*** Execute Commands from Ini Section
    DFPLExecIniSection( AParam0, '', '', false, false )
  else
  if ACommandName = 'TFE>' then
  //*** Execute Commands from Section in special Call TextFrags
    DFPLExecTFSection( AParam0, '', '', false, false )
  else
  if ACommandName = 'VFE>' then
  //*** Execute Commands from Virtual File
    DFPLExecVFile( DFPLExpandBySrcDirs( AParam0 ) )
  else
  if ACommandName = '-' then
  begin
    if AParam0 = '*' then
      ClearAllSections()
    else
      ClearSection( AParam0, AParam1 );
  end
  else
  if ACommandName = '--' then
  begin
    if DstIniFile <> nil then
    begin
      if AParam0 = '*' then
        DstIniFile.Clear
      else
        DstIniFile.EraseSection( AParam0 )
    end;
  end
  else
  if ACommandName = '>>DPR' then
    CopyDPRFiles( AParam0, AParam1, AParam2 <> '' )
  else
  if ACommandName = 'DPRU>' then
    UpdateDPR( AParam0, AParam1, AParam2 )
  else
  if ACommandName = 'M>' then
     FileMacroProcessing( AParam0, AParam1, AParam2, AParam3, AParam4 )
  else
  if ACommandName = '>SI<' then
    DFPLSetSrcContext( AParam0, AParam1 )
//  else if ACommandName = '=#' then begin
//  else if (ACommandName[2] = '#') and (ACommandName[1] = '=') then begin
//          K_StrStartsWith( '=#', ACommandName[1] ) then begin
  else
  if ((ACommandName[1] = '#') and (ACommandName[2] = '=')) or
     ((Length(ACommandName) > 2) and (ACommandName[1] = '=') and (ACommandName[2] = '#')) then
  begin
  // Set Macro Variable
    WCommandName := ACommandName;
    SetByIdent := TRUE;
    if (ACommandName[1] = '#') then
    begin
      WMacroName := AParam0;
      if (Length(ACommandName) = 2) then
      begin
        CurIniVal := AParam1;
        SetByIdent := FALSE;
      end
      else
      begin
        WSectName  := AParam1;
        WIdentName := AParam2;
        WCommandName := Copy( ACommandName, 2, 3 );
      end;
    end
    else
    begin
      WSectName  := AParam0;
      WIdentName := AParam1;
      WMacroName := AParam2;
    end;
    LInd := CMList.IndexOfName(WMacroName);

    if SetByIdent then
    begin
      // Set Macro From Ini
      if (Length(WCommandName) > 2) then
        CurIniVal := DstIniFile.ReadString( WSectName, WIdentName, '' )
      else
        CurIniVal := SrcIniFile.ReadString( WSectName, WIdentName, '' );
    end;
    if LInd < 0 then
      CMList.Add(WMacroName + '=' + CurIniVal)
    else
      K_ReplaceListValue( CMList, LInd, CurIniVal );
//      CMList.ValueFromIndex[LInd] := CurIniVal;
  end
  else
  if ACommandName = '=CRC' then
  begin
  // Set Files CRC Section
    if AParam1 = '*' then
    begin
      if AParam2 <> '' then
        SetAllDirFilesCRC( AParam0, AParam2, AParam3 )
      else
        SetAllSectionFilesCRC( AParam0 )
    end else
      SetSectionFileCRC1( AParam0, AParam1, AParam2 );
  end
  else
  begin // Set DesIniFile by SrcIniFile and copy files if needed commands
//deb if (AParam0 = 'GDRegionImages') and (AParam1 = 'SplashScreenImgEFName') then
//deb N_i := 0;
//if AParam0 = 'PMTImages' then
//N_s := 'PMTImages';
    WCommandName := ParseSkipIniCopyFileFlags( ParseNativeCopyFileFlag( ACommandName ) );
    if WCommandName[1] = '=' then
    begin
      WCommandName := ParseNativeCopyFileFlag( Copy( WCommandName, 2, Length(WCommandName) ) );
      //*** Add New Value to new IniFile FileGPaths Section
      if (AParam0 = K_FileGPathsIniSection) and
         (AParam2 <> '') then
      begin
        LInd := DstDirsList.Add( AParam1+'='+AParam2 );
        K_SListMListReplace( DstDirsList, DstDirsList, K_ummRemoveResult );
        with DstDirsList do
          if LInd < Count then
          begin
            if AParam2 <> '' then
            begin
              Strings[LInd] := IncludeTrailingPathDelimiter(Strings[LInd]);
              if (AParam3 <> '-F') and not SafeForceDir( ValueFromIndex[LInd]  ) then Exit;
            end;
          end;
      end; // if (AParam0 = K_FileGPathsIniSection) and (AParam2 <> '') then

      if AParam1 = '*' then
      begin
        if WCommandName = '>' then
          CopyAllSectionFiles( AParam0, AParam2 )
        else if (WCommandName = '') or (WCommandName = '+') then
          CopySection( AParam0, AParam2, AParam3 );
      end   // if AParam1 = '*' then
      else
      begin // if AParam1 <> '*' then
//0        SetByIdent := TRUE;
//0        CurIniVal := SrcIniFile.ReadString( AParam0, AParam1, '' );
        CurIniVal := SrcIniFile.ReadString( AParam0, AParam1, '*' );
        IdentIsAbsent := '*' = CurIniVal;
        if IdentIsAbsent then
          CurIniVal := ''; // Set source IniValue to '' if source IniName is absent
        SetByIdent := TRUE;
//1        SetByIdent := not IdentIsAbsent;
        if WCommandName = '+' then
        begin
          AParam2 := CurIniVal;
//0          if CurIniVal = '' then // SetByIdent = FALSE if IniName is absent
//0            SetByIdent := '*' <> SrcIniFile.ReadString( AParam0, AParam1, '*' );
          SetByIdent := not IdentIsAbsent;
        end  // if WCommandName = '+' then
        else if WCommandName <> '' then
        begin  // <> =
          AParam2 := ExecuteCopyFilesCommands( WCommandName, CurIniVal,
                                               AParam2, AParam3, AParam4 );
          SetByIdent := not SkipSetResultIdent and (AParam2 <> '');

          if IdentIsAbsent and not SkipSetResultIdent then // Warning if source IniName is absent
            CurCommandWarning := format('Source [%s].%s is absent ',[AParam0, AParam1] );
        end; // if WCommandName <> '' then

        if (DstIniFile <> nil) and SetByIdent then
          DstIniFile.WriteString( AParam0, AParam1, AParam2 );
      end; // if AParam1 <> '*' then
    end  // if WCommandName[1] = '=' then
    else
         // if WCommandName[1] <> '=' then
    if ExecuteCopyFilesCommands( WCommandName, AParam0,
                                 AParam1, AParam2, AParam3 ) <> '' then
      Exit;
  end; // Set DesIniFile by SrcIniFile and copy files if needed commands
end; //*** end of procedure TK_DFPLScriptExec.DFPLExecCommand

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLDoCommandsList0
//*********************************** TK_DFPLScriptExec.DFPLDoCommandsList0 ***
// Execute given Commands List using current context
//
//     Parameters
// ACommands - given Commands List
// AIniFlag  - if =TRUE then Commands List has section of Ini-file format, else
//             Commands in Commands List have no '=' separator
//
procedure TK_DFPLScriptExec.DFPLDoCommandsList0( ACommands : TStrings; AIniFlag : Boolean );
var
  i : Integer;
  SaveCursor : TCursor;
  WarningText, CMD : string;
  Par0, Par1, Par2, Par3, Par4, CMDName : string;
  SkipCommandsCond : Boolean;
  SkipCommand1 : Boolean;
  IfResult : Boolean;
  ShowDumpFlag : Boolean;
  ShowCommandMesState : TK_MesStatus;
  WCL : TStringList;
begin

  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;


  WCL := TStringList.Create;
  if CMList <> nil then
    WCL.Text := K_StringMacroAssembling( ACommands.Text, '(%', '%)', CMList )
  else
    WCL.Assign( ACommands );

  N_PBCaller.Start( WCL.Count );
  SkipCommandsCond := false;

  ShowDumpFlag := N_MemIniToBool( 'Dump', 'DumpDFPL', false );

  LastCommandsStrings := ACommands;
  for i := 0 to WCL.Count - 1 do
  begin

    SkipCommand1     := false;
    N_PBCaller.Update( i + 1, WCL.Count );

    if CMList <> nil then
      CMD := K_StringMListReplace( WCL[i], CMList, K_ummSaveMacro )
    else
      CMD := WCL[i];

    CMD := TrimLeft(CMD);

    if (CMD <> '') and not K_StrStartsWith( '//', CMD ) then
    begin
      if ShowDumpFlag or (ShowCommandDumpStatus <> 0) then
      begin
        ShowCommandMesState := K_msInfo;
        if ShowCommandDumpStatus > 1 then
          ShowCommandMesState := K_msWarning;
        DFPLShowInfo( 'DFPL: '+ WCL[i], ShowCommandMesState );
      end;

      if not AIniFlag then
      begin
        STK.setSource( CMD );
        Par0 := STK.nextToken(true);
        CMDName := STK.nextToken(true);
      end   // if not AIniFlag then
      else
      begin // if AIniFlag then
      // old version - script is Ini-file section
        Par0 := WCL.Names[i];
        STK.setSource( WCL.ValueFromIndex[i] );
        CMDName := STK.nextToken(true);
      end; // if AIniFlag then

      if Par0[1] = '#' then
      begin
      //*****************************************
      // Obsolete code for Script Macro Assembling
      // (for compatibility with old scripts, not used now)
      // Commands List MacroAssembling is done now K_StringMacroAssembling
      //
        SkipCommand1 := true;
        if K_StrStartsWith( '#END', Par0, true ) then  // #END
          SkipCommandsCond := false
        else
        if not SkipCommandsCond then
        begin
          if K_StrStartsWith( '#IF', Par0, true ) then
          begin
            Par0 := UpperCase( Par0 );
            if Pos( 'D', Par0 ) > 0 then                    // #IFDEF, #IFNDEF
              IfResult := CMList.IndexOfName(CMDName) <> -1
            else                                            // #IF, #IFNOT
              IfResult := N_StrToBool( CMDName );

            if (Length(Par0) >= 4) and (Par0[4] = 'N') then // #IFNOT or #IFNDEF
              IfResult := not IfResult;

            SkipCommandsCond := not IfResult;
          end
          else
          if K_StrStartsWith( '#DEF', Par0, true ) then // #DEF
            DFPLSetCMListItem( CMDName, STK.nextToken(true), true )
          else
            SkipCommand1 := false;
        end;
      end;

      if SkipCommand1 or SkipCommandsCond then Continue;
// end of Script Macro Assembling Code
//*****************************************
//      if CMDName = 'BREAK>' then Break;
     //*** Execute Script Command
      Par1 := STK.nextToken(true);
      Par2 := STK.nextToken(true);
      Par3 := STK.nextToken(true);
      Par4 := STK.nextToken(true);
      try
        DFPLExecCommand( CMDName, Par0, Par1, Par2, Par3, Par4 );
      except
        On E: Exception do
         DFPLShowInfo( 'DFPL: Error : '+ E.Message + #$D#$A+
                       ' in : ' + WCL[i] + #13#10 + CMD, K_msError );
      end;
      if CurCommandWarning <> '' then
      begin // Save Warning Info
        WarningText := 'DFPL: Warning :  ' + CurCommandWarning + ' in : ' + WCL[i];
        if WCL[i] <> CMD then
          WarningText := WarningText + #13#10 + 'Macro >> ' + CMD;
        DFPLShowInfo( WarningText, K_msWarning );
//        DFPLShowInfo( 'DFPL: Warning :  ' + CurCommandWarning + ' in : ' + WCL[i] +
//                      #13#10 + CMD, K_msWarning );
        Inc(CommandWarningsCount);
      end;

    end; // if (CMD <> '') and not K_StrStartsWith( '//', CMD ) then

  end; //   for i := 0 to ACommands.Count - 1 do

  WCL.Free;

  if Assigned(N_PBCaller.PBCProcOfObj) then
    Sleep(200); // just for visual effect in progress bar
  N_PBCaller.Finish();

  Screen.Cursor := SaveCursor;
end; //*** end of procedure TK_DFPLScriptExec.DFPLDoCommandsList

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLDoCommands0
//*************************************** TK_DFPLScriptExec.DFPLDoCommands0 ***
// Set new execution context and execute given Commands List
//
//     Parameters
// ACommands            - given Commands List
// AIniFlag             - if =TRUE then Commands List has section of Ini-file 
//                        format, else Commands in Commands List have no '=' 
//                        separator
// ARootPath            - Distribution Files destination path
// AIniName             - resulting Ini-file name
// AEncodeResultIniFile - if =TRUE then resulting Ini-file data will be encoded
// ASkipSaveIniFile     - if =TRUE then resulting file will be used only during 
//                        distribution files creation and real Ini-file will not
//                        be created
//
procedure TK_DFPLScriptExec.DFPLDoCommands0( ACommands : TStrings;
                            AIniFlag : Boolean;
                            const ARootPath, AIniName : string;
                            AEncodeResultIniFile, ASkipSaveIniFile : Boolean );
//var
//  CL : TStrings;
begin
//*** INI
  if ARootPath <> '' then
    DFPLSetDestRootPath( ARootPath );
  if AIniName <> '' then
    DFPLCreateDestMemIni( AIniName, AEncodeResultIniFile, ASkipSaveIniFile, '*' );

  DFPLDoCommandsList0( ACommands, AIniFlag );

  if AIniName <> '' then  DFPLFreeMemIni;
end; //*** end of procedure TK_DFPLScriptExec.DFPLDoCommands0

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLExecIniSection
//************************************ TK_DFPLScriptExec.DFPLExecIniSection ***
// Set new execution context and execute Commands List from given section in 
// current Ini-file
//
//     Parameters
// AExecSectionName     - name of section in current Ini-file with Commands List
// ARootPath            - Distribution Files destination path
// AIniName             - resulting Ini-file name
// AEncodeResultIniFile - if =TRUE then resulting Ini-file data will be encoded
// ASkipSaveIniFile     - if =TRUE then resulting file will be used only during 
//                        distribution files creation and real Ini-file will not
//                        be created
// Result               - Returns FALSE if needed section with commands list is 
//                        absent.
//
function TK_DFPLScriptExec.DFPLExecIniSection( const AExecSectionName, ARootPath : string;
                            AIniName : string = ''; AEncodeResultIniFile : Boolean = false;
                            ASkipSaveIniFile : Boolean = false ) : Boolean;
var
  WSList : TStringList;

begin
  if (CallMemIniFile = nil) or
     not CallMemIniFile.SectionExists( AExecSectionName ) then begin
    Result := false;
    DFPLShowInfo( 'Отсутствует секция IE> ' + AExecSectionName, K_msWarning );
    Exit;
  end;
  Result := true;

  WSList := TStringList.Create;

  CallMemIniFile.ReadSectionValues( AExecSectionName, WSList );

  DFPLShowInfo( 'DFPL: Start IniSection ' + AExecSectionName + ' in ' + CallMemIniFile.FileName, K_msInfo );

  DFPLDoCommands0( WSList, true, ARootPath, AIniName,
                    AEncodeResultIniFile, ASkipSaveIniFile );
  WSList.Free;

end; //*** end of procedure TK_DFPLScriptExec.DFPLExecIniSection

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLExecTFSection
//************************************* TK_DFPLScriptExec.DFPLExecTFSection ***
// Set new execution context and execute Commands List from given section in 
// current TextFragms List
//
//     Parameters
// AExecSectionName     - name of section in current TextFragms List with 
//                        Commands List
// ARootPath            - Distribution Files destination path
// AIniName             - resulting Ini-file name
// AEncodeResultIniFile - if =TRUE then resulting Ini-file data will be encoded
// ASkipSaveIniFile     - if =TRUE then resulting file will be used only during 
//                        distribution files creation and real Ini-file will not
//                        be created
// Result               - Returns FALSE if needed section with commands list is 
//                        absent.
//
function TK_DFPLScriptExec.DFPLExecTFSection( const AExecSectionName : string;
                            const ARootPath : string = '';
                            const AIniName : string = ''; AEncodeResultIniFile : Boolean = false;
                            ASkipSaveIniFile : Boolean = false ) : Boolean;
var
  SInd : Integer;
  CL : TStrings;
begin
  Result := false;
  SInd := -1;
  if CallMemTextFragms <> nil then
    SInd := CallMemTextFragms.IndexOf( AExecSectionName );

  if SInd = -1 then
  begin
    DFPLShowInfo( 'Section in absent TE> ' + AExecSectionName, K_msWarning );
    Exit;
  end;

  CL := TStrings(CallMemTextFragms.Objects[SInd]);
  if CL.Count = 0 then Exit;

  Result := true;

  DFPLShowInfo( 'DFPL: Start Section ' + AExecSectionName + ' in TF', K_msInfo );

  DFPLDoCommands0( CL, false, ARootPath, AIniName,
                    AEncodeResultIniFile, ASkipSaveIniFile );

end; //*** end of procedure TK_DFPLScriptExec.DFPLExecTFSection

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLExecCommandsList
//********************************** TK_DFPLScriptExec.DFPLExecCommandsList ***
// Set new execution context and execute Commands List of TextFragms Command 
// Format
//
//     Parameters
// ACommands            - given Commands List
// ARootPath            - Distribution Files destination path
// AIniName             - resulting Ini-file name
// AEncodeResultIniFile - if =TRUE then resulting Ini-file data will be encoded
// ASkipSaveIniFile     - if =TRUE then resulting file will be used only during 
//                        distribution files creation and real Ini-file will not
//                        be created
//
procedure TK_DFPLScriptExec.DFPLExecCommandsList( ACommands : TStrings; const ARootPath : string;
                            AIniName : string = ''; AEncodeResultIniFile : Boolean = false;
                            ASkipSaveIniFile : Boolean = false );
begin
  DFPLDoCommands0( ACommands, false, ARootPath, AIniName,
               AEncodeResultIniFile, ASkipSaveIniFile );
end; //*** end of procedure TK_DFPLScriptExec.DFPLExecCommandsList

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLExecVFile
//***************************************** TK_DFPLScriptExec.DFPLExecVFile ***
// Execute Commands List from given Virtual file in current execution context
//
//     Parameters
// AVFileName - Virtual file name with Commands List
// Result     - Returns TRUE if file AVFileName exists
//
function TK_DFPLScriptExec.DFPLExecVFile( const AVFileName : string ) : Boolean;
var
  WSList : TStringList;
  FName : string;
begin

  WSList := TStringList.Create;
  FName := K_ExpandFileName( AVFileName );
  if not K_VFLoadStrings ( WSList, FName ) then
  begin
    Result := false;
    DFPLShowInfo( 'Не удалось прочитать команды из файла ' + FName, K_msWarning );
    WSList.Free;
    Inc(CommandWarningsCount);
    Exit;
  end;
  Result := true;

  DFPLShowInfo( 'DFPL: Start file ' + AVFileName, K_msInfo );

  DFPLDoCommandsList0( WSList, false );

  WSList.Free;

end; //*** end of procedure TK_DFPLScriptExec.DFPLExecVFile

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLSetDestRootPath
//*********************************** TK_DFPLScriptExec.DFPLSetDestRootPath ***
// Set Distribution Files base destination path
//
//     Parameters
// ADstBasePath - Distribution Files base destination path
//
procedure TK_DFPLScriptExec.DFPLSetDestRootPath( const ADstBasePath : string );
begin
  DstBasePath := IncludeTrailingPathDelimiter( K_ExpandFileName( ADstBasePath ) );
  DstDirsList.Clear;
  DstDirsList.Add( K_MVAppDirExe+'='+DstBasePath );
  CurDstDirsList := DstDirsList;
end; //*** end of procedure TK_DFPLScriptExec.DFPLSetDestRootPath

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLSetMacroList
//************************************** TK_DFPLScriptExec.DFPLSetMacroList ***
// Set list of strings with Macro Replace Context
//
//     Parameters
// ACMList     - list of strings <Name>=<Value>
// AAssignFlag - if TRUE then given Macro List Values are assigned to Existing 
//               MacroList, else given Macro List object is used
//
procedure TK_DFPLScriptExec.DFPLSetMacroList( ACMList: TStrings; AAssignFlag : Boolean = FALSE );
begin
  if AAssignFlag then
  begin
    if CMList = nil then
    begin
      CMList := TStringList.Create;
      CMListFreeFlag := true;
    end;
    CMList.Assign(ACMList);
  end
  else
  begin
    if CMListFreeFlag then CMList.Free;
    CMList := ACMList;
    CMListFreeFlag := false;
  end;
  DFPLInitCMList();
end; //*** end of procedure TK_DFPLScriptExec.DFPLSetMacroList

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLSetSrcContext
//************************************* TK_DFPLScriptExec.DFPLSetSrcContext ***
// Set Script Source context
//
//     Parameters
// ASrcIniFileName - name of source ini file
// ASrcBasePath    - source base file path
//
procedure TK_DFPLScriptExec.DFPLSetSrcContext( const ASrcIniFileName : string;
                                           const ASrcBasePath : string = '' );
var
  WSrcFName : string;
  WSrcFPath  : string;
  RebuildSrcPathContext : Boolean;
begin
  WSrcFPath := '';
  RebuildSrcPathContext := false;
  if (ASrcBasePath <> '*') and
     (ASrcBasePath <> '') then begin
    WSrcFPath := DFPLExpandBySrcDirs( ASrcBasePath );
    RebuildSrcPathContext := true;
  end;
  DFPLExpandBySrcDirs( ASrcBasePath );

  if (ASrcIniFileName <> '*') and
     (ASrcIniFileName <> '') then begin
    WSrcFName := DFPLExpandBySrcDirs( ASrcIniFileName );
    K_LoadMemIniFromFile( SrcIniFile, WSrcFName );
    RebuildSrcPathContext := true;
    if (WSrcFPath = '') and (ASrcBasePath = '*') then
      WSrcFPath := ExtractFilePath(WSrcFName);
  end;

  if not RebuildSrcPathContext then Exit;
  if WSrcFPath <> '' then
    SrcBasePath := IncludeTrailingPathDelimiter(WSrcFPath);
  DFPLSetNamedPathsStrings( SrcDirsList, SrcIniFile, SrcBasePath, '' );
end; //*** end of procedure TK_DFPLScriptExec.DFPLSetSrcContext

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLCreateDestMemIni
//********************************** TK_DFPLScriptExec.DFPLCreateDestMemIni ***
// Create distributed application Ini-file in memory
//
//     Parameters
// AIniName             - resulting Ini-file name
// AEncodeResultIniFile - if =TRUE then resulting Ini-file data will be encoded
// ASkipSaveIniFile     - if =TRUE then resulting file will be used only during 
//                        distribution files creation and real Ini-file will not
//                        be created
// ASrcIniFileName      - name of source file for resulting Ini-file
//
procedure TK_DFPLScriptExec.DFPLCreateDestMemIni( const AIniName : string;
                                               AEncodeResultIniFile : Boolean;
                                               ASkipSaveIniFile : Boolean = false;
                                               const ASrcIniFileName : string = ''  );
var
  WSrcFName : string;
  WIniName : string;
begin
  WSrcFName := ASrcIniFileName;

  if ASrcIniFileName = '*' then WSrcFName := SrcIniFile.FileName
  else if ASrcIniFileName <> '' then WSrcFName := K_ExpandFileName( ASrcIniFileName );

  DFPLSetCMListItem( 'SrcIniName', ChangeFileExt( ExtractFileName( WSrcFName ), '' ), false );

  DstIniFile.Free;
  DstIniFile := TMemIniFile.Create( WSrcFName );

  WIniName := AIniName;
  if AIniName = '*' then begin
    WSrcFName := ExtractFileName( WSrcFName );
    WIniName := ChangeFileExt( WSrcFName, '' );
  end else
    WSrcFName := AIniName +'.ini';

// Set ResultIniName MacroPar
  DFPLSetCMListItem( 'ResultIniName', WIniName, false );
  DFPLSetCMListItem( 'DstIniName', WIniName, false );

  DstIniFile.Rename( K_ExpandFileName( DstBasePath + WSrcFName ), false );
  ResultIniFileEncode := AEncodeResultIniFile;
  SkipSaveDstIniFile := ASkipSaveIniFile;
end; //*** end of procedure TK_DFPLScriptExec.DFPLCreateDestMemIni

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLSetVFileDataSpace
//********************************* TK_DFPLScriptExec.DFPLSetVFileDataSpace ***
// Set given Virtual File Data Space
//
procedure TK_DFPLScriptExec.DFPLSetVFileDataSpace( AVFile: TK_VFile );
var
  ResultIniFileDataSize : Integer;
  ProcFlag : Boolean;
begin

  // Try to use Data Space attribute
  ProcFlag := FALSE;
  if Length(SResultIniFileDataSize) > 0 then
  begin
    ProcFlag := SResultIniFileDataSize[Length(SResultIniFileDataSize)] = '%';
    if ProcFlag then
      SResultIniFileDataSize := Copy( SResultIniFileDataSize, 1, Length(SResultIniFileDataSize) - 1 );
  end;

  if Length(SResultIniFileDataSize) > 0 then
  begin
    ResultIniFileDataSize := StrToIntDef( SResultIniFileDataSize, 0 );
    if ProcFlag then
      ResultIniFileDataSize := Round( AVFile.DFile.DFPlainDataSize * ResultIniFileDataSize / 100 );
    if SResultIniFileDataSize[1] = '+' then
      ResultIniFileDataSize := ResultIniFileDataSize + AVFile.DFile.DFPlainDataSize;
    K_VFSetDataSpace( AVFile, ResultIniFileDataSize  );
  end;
end; //*** end of procedure TK_DFPLScriptExec.DFPLSetVFileDataSpace

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLSaveMemIni
//**************************************** TK_DFPLScriptExec.DFPLSaveMemIni ***
// Save distributed application Ini-file from memory to resulting file
//
procedure TK_DFPLScriptExec.DFPLSaveMemIni( AIniFileName : string = '' );
var
  ACreateParams: TK_DFCreateParams;
  VFile: TK_VFile;
//  ResultIniFileDataSize : Integer;
//  ProcFlag : Boolean;
begin
  if SkipSaveDstIniFile or (DstIniFile = nil) then Exit;
  WWSL.Clear;
  DstIniFile.GetStrings( WWSL );

  if AIniFileName = '' then
    AIniFileName := DstIniFile.FileName;

  K_VFAssignByPath( VFile, AIniFileName );

  if ResultIniFileEncode then
    ACreateParams := K_DFCreateEncrypted
  else
    ACreateParams := K_DFCreatePlain;

  K_VFForceDirPath( ExtractFilePath(AIniFileName) );

  VFile.DFCreatePars := ACreateParams;

  K_VFSaveText0( WWSL.Text, VFile );

  DFPLSetVFileDataSpace( VFile );
{
  // Try to use Data Space attribute
  ProcFlag := FALSE;
  if Length(SResultIniFileDataSize) > 0 then
  begin
    ProcFlag := SResultIniFileDataSize[Length(SResultIniFileDataSize)] = '%';
    if ProcFlag then
      SResultIniFileDataSize := Copy( SResultIniFileDataSize, 1, Length(SResultIniFileDataSize) - 1 );
  end;

  if Length(SResultIniFileDataSize) > 0 then
  begin
    ResultIniFileDataSize := StrToIntDef( SResultIniFileDataSize, 0 );
    if ProcFlag then
      ResultIniFileDataSize := Round( VFile.DFile.DFPlainDataSize * ResultIniFileDataSize / 100 );
    if SResultIniFileDataSize[1] = '+' then
      ResultIniFileDataSize := ResultIniFileDataSize + VFile.DFile.DFPlainDataSize;
    K_VFSetDataSpace( VFile, ResultIniFileDataSize  );
  end;
}
end; //*** end of procedure TK_DFPLScriptExec.DFPLSaveMemIni

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLFreeMemIni
//**************************************** TK_DFPLScriptExec.DFPLFreeMemIni ***
// Free distributed application Ini-file from memory
//
procedure TK_DFPLScriptExec.DFPLFreeMemIni( AIniFileName : string = '' );
begin
  DFPLSaveMemIni( AIniFileName );
  FreeAndNil( DstIniFile );
end; //*** end of procedure TK_DFPLScriptExec.DFPLFreeMemIni

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_DFPLScriptExec\DFPLGetCMListItem
//************************************* TK_DFPLScriptExec.DFPLGetCMListItem ***
// Get Macro Value by Name
//
//     Parameters
// AName  - macro name
// Result - Returns macro value corresponding to given macro name
//
function TK_DFPLScriptExec.DFPLGetCMListItem(const AName: string): string;
begin
  Result := CMList.Values[AName]
end; //*** end of TK_DFPLScriptExec.DFPLGetCMListItem

//************************************************ TK_DFPLScriptExec.DFPLShowInfo
//
procedure TK_DFPLScriptExec.DFPLShowInfo( const Info: string; MesStatus : TK_MesStatus = K_msInfo );
begin
  if Assigned(OnShowInfo) then OnShowInfo( Info, MesStatus );
end; //*** end of procedure TK_DFPLScriptExec.DFPLShowInfo

//************************************************ TK_DFPLScriptExec.DFPLInitCMList ***
//
//
procedure TK_DFPLScriptExec.DFPLInitCMList();
var
  Ind : Integer;
begin
  Ind := DFPLSetCMListItem( 'DistrFileGPaths', '', true );
  CMList.Objects[Ind] := DstDirsList;
  Ind := DFPLSetCMListItem( 'DstFileGPaths', '', true );
  CMList.Objects[Ind] := DstDirsList;
  Ind := DFPLSetCMListItem( 'AppFileGPaths', '', true );
  CMList.Objects[Ind] := K_AppFileGPathsList;
  Ind := DFPLSetCMListItem( 'SrcFileGPaths', '', true );
  CMList.Objects[Ind] := SrcDirsList;
end; //*** end of TK_DFPLScriptExec.DFPLInitCMList

//************************************************ TK_DFPLScriptExec.DFPLSetCMListItem
//
function TK_DFPLScriptExec.DFPLSetCMListItem( const AName, AValue: string;
                                          AOnlyAdd: Boolean = false ) : Integer;
begin
  if CMList = nil then begin
    CMList := TStringList.Create;
    CMListFreeFlag := true;
  end;
  Result := CMList.IndexOfName( AName );
  if Result = -1 then begin
    Result := CMList.Count;
    CMList.Add( AName + '=' + AValue );
  end else if not AOnlyAdd then
    K_ReplaceListValue( CMList, Result, AValue );
//    CMList.ValueFromIndex[Result] := AValue;
end; //*** end of procedure TK_DFPLScriptExec.DFPLSetCMListItem

//************************************************ TK_DFPLScriptExec.DFPLSetNamedPathsStrings ***
//
procedure TK_DFPLScriptExec.DFPLSetNamedPathsStrings( ANameedPathsContext : TStrings;
                                AMemIniFile : TMemIniFile;
                                AExePathValue : string; ASectName : string );
var
  i : Integer;
begin
  if ASectName = '' then ASectName := K_FileGPathsIniSection;
  AExePathValue := K_MVAppDirExe+'='+AExePathValue;

  ANameedPathsContext.Clear;

  if AMemIniFile <> nil then
    AMemIniFile.ReadSectionValues( ASectName, ANameedPathsContext );

  ANameedPathsContext.Insert( 0, AExePathValue );
  K_SListMListReplace( ANameedPathsContext, ANameedPathsContext, K_ummRemoveResult );

  for i := 0 to ANameedPathsContext.Count - 1 do
    ANameedPathsContext[i] := IncludeTrailingPathDelimiter( ANameedPathsContext[i] );

end; //*** end of procedure TK_DFPLScriptExec.DFPLSetNamedPathsStrings

//************************************************ TK_DFPLScriptExec.DFPLExpandByDestDirs ***
//
function TK_DFPLScriptExec.DFPLExpandByDestDirs( const AFileName : string ) : string;
begin
  Result := K_StringMListReplace( AFileName, CurDstDirsList, K_ummRemoveMacro );
end; //*** end of procedure TK_DFPLScriptExec.DFPLExpandByDestDirs

//************************************************ TK_DFPLScriptExec.DFPLExpandBySrcDirs ***
//
function TK_DFPLScriptExec.DFPLExpandBySrcDirs( const AFileName : string ) : string;
begin
  Result := K_StringMListReplace( AFileName, CurSrcDirsList, K_ummRemoveMacro );
end; //*** end of procedure TK_DFPLScriptExec.DFPLExpandBySrcDirs

//********************************************* TK_CMEDDBAccess.DFPLCollectDirFiles ***
// Collect Files - scan files subtree function
//
//     Parameters
// APathName - testing path
// AFileName - testing file name
//
function TK_DFPLScriptExec.DFPLCollectDirFiles( const APathName, AFileName: string; AScanLevel : Integer ) : TK_ScanTreeResult;
begin
  Result := K_tucSkipSubTree;
  if ScanFilesSubfolders then
    Result := K_tucOK;
  if AFileName = '' then
    Exit;
  WWSL1.Add( AFileName );
end; // end of TK_CMEDDBAccess.DFPLCollectDirFiles

{*** end of TK_DFPLScriptExec ***}


{*** TK_MemIniContsProc ***}
{
//******************************************************* TK_MemIniContsProc.Create ***
// TK_MemIniContsProc constructor
//
//     Parameters
// AJoinedMemIni - Joined MemeIni context as TMemIniFile Object
// ADFPLScriptsFName - file name with text fragments which contains DFPL scripts
//                     for copying Ini context from/to Joined MemeIni Context
//
constructor TK_MemIniContsProc.Create( AJoinedMemIni: TMemIniFile;
  ADFPLScriptsFName: string );
begin
  MICPDFPLExec := TK_DFPLScriptExec.Create;
  MICPDFPLExec.DstIniFile.Free;
  MICPJoinedMemIni := AJoinedMemIni;
  MICPDFPLScripts := TN_MemTextFragms.CreateFromVFile( ADFPLScriptsFName );
  MICPDFPLExec.CallMemTextFragms := MICPDFPLScripts.MTFragmsList;

end; // end of TK_MemIniContsProc.Create

//******************************************************* TK_MemIniContsProc.Destroy ***
// TK_MemIniContsProc destructor
//
destructor TK_MemIniContsProc.Destroy;
begin
  MICPWrkMemIni.Free;
  MICPDFPLScripts.Free;
  MICPDFPLExec.DstIniFile := nil;
  MICPDFPLExec.SrcIniFile := nil;
  MICPDFPLExec.Free;
  inherited;
end; // end of TK_MemIniContsProc.Create

//******************************************************* TK_MemIniContsProc.Create ***
// Add Strings with Ini Context to Joined MemIni Context
//
//     Parameters
// AIniStrings - Strings with Ini Context to add
// AScriptName - name of Strings with DFPL script to copy given context
//
procedure TK_MemIniContsProc.AddIniStrings( AIniStrings : TStrings; AScriptName : string );
begin
  MICPWrkMemIni.SetStrings( AIniStrings );
  MICPDFPLExec.DstIniFile := MICPJoinedMemIni;
  MICPDFPLExec.SrcIniFile := MICPWrkMemIni;
  if not MICPDFPLExec.DFPLExecTFSection( AScriptName ) then
    K_AddMemIni( MICPWrkMemIni, MICPJoinedMemIni );
end;

//******************************************************* TK_MemIniContsProc.Create ***
// Add Ini-file with given Context to Joined MemIni Context
//
//     Parameters
// AIniFName - Ini-file name with given Context Context to add
// AScriptName - name of Strings with DFPL script to copy given context
//
procedure TK_MemIniContsProc.AddIniFile( AIniFName : string; AScriptName : string = '' );
begin

{
  AIniFName := K_ExpandFileName( AIniFName );
  if not FileExists(AIniFName) then begin
//    N_Dump2Str( 'Ini File ' + AIniFName + ' not found' );
    Exit;
  end;
//  N_Dump2Str( 'Add Ini Info from ' + AIniFName );
}
{
  MICPWrkMemIni.Rename( AIniFName, TRUE );
  MICPDFPLExec.DstIniFile := MICPJoinedMemIni;
  MICPDFPLExec.SrcIniFile := MICPWrkMemIni;
  if not MICPDFPLExec.DFPLExecTFSection( AScriptName ) then
    K_AddMemIni( MICPWrkMemIni, MICPJoinedMemIni );
end;

//******************************************************* TK_MemIniContsProc.Create ***
// Get Ini Context from Joined MemIni Context to given Strings
//
//     Parameters
// AIniStrings - Strings with resulting Ini Context
// AScriptName - name of Strings with DFPL script to copy given context
//
procedure TK_MemIniContsProc.GetIniStrings( AIniStrings : TStrings; AScriptName : string );
begin
  if not MICPDFPLExec.DFPLExecTFSection( AScriptName ) then Exit;
  MICPWrkMemIni.GetStrings( AIniStrings );
end;
}
{*** end of TK_MemIniContsProc ***}

{*** TK_UNDOBuf ***}

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf\Create
//******************************************************* TK_UNDOBuf.Create ***
// TK_UNDOBuf constructor
//
//     Parameters
// AUndoFilePathPref - source XML string which must be parsed
//
constructor TK_UNDOBuf.Create( AUndoFilePattern: string );
var
  Ind : Integer;
begin
  Ind := 0;
  FUndoFilePath := N_CreateUniqueFileName(
                  ChangeFileExt( K_ExpandFileName( AUndoFilePattern ), '' ),
                  Ind, ExtractFileExt(AUndoFilePattern) );
  FStream := TFileStream.Create( FUndoFilePath, fmCreate );
  FCurInd := -1;
  SetLength( FOffsets, 1 );

end; // end of TK_UNDOBuf.Create

//************************************************ TK_UNDOBuf.Destroy ***
// TK_UNDOBuf destructor
//
destructor TK_UNDOBuf.Destroy;
begin
  FStream.Free;
  K_DeleteFile( FUndoFilePath );
  inherited;
end; // end of TK_UNDOBuf.Destroy

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf\UBPushData
//*************************************************** TK_UNDOBuf.UBPushData ***
// Push data to UNDO buffer new record
//
//     Parameters
// ACapt     - UNDO data portion caption
// APData    - pointer to UNDO data portion
// ADataSize - UNDO data portion size in bytes
//
procedure TK_UNDOBuf.UBPushData( ACapt: string; APData: Pointer;
                                 ADataSize: Integer );
var
  Capacity : Integer;
begin

// Push Cur Record Index
  Inc( FCurInd );
  FCount := FCurInd;

// Write new Record to file
  FStream.Position := FOffsets[FCount];
  FStream.Write( APData^, ADataSize );


// Increase Buffer Controls Capacity
  Inc( FCount );
  Capacity := Length(FCaptions);
  if K_NewCapacity( FCount,  Capacity ) then begin
    SetLength( FCaptions, Capacity);
    SetLength( FOffsets, Capacity + 1 );
  end;

// Store new Record Caption and File position
  FOffsets[FCount] := FOffsets[FCurInd] + ADataSize;
  FCaptions[FCurInd] := ACapt;

end; // end of TK_UNDOBuf.UBPushData

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf\UBGetDataByInd(2)
//******************************************** TK_UNDOBuf.UBGetDataByInd ***
// Get data from UNDO buffer by given record index
//
//     Parameters
// AInd      - UNDO buffer record index
// ADataBuf  - byte array buffer for getting data
// ADataSize - getting UNDO data portion size in bytes
//
procedure TK_UNDOBuf.UBGetDataByInd( AInd: Integer; var ADataBuf: TN_BArray;
                                     out ADataSize: Integer );
var
//  UFile: file;
  Capacity : Integer;
begin
  if (AInd < 0) or (AInd >= FCount) then Exit;

  ADataSize := FOffsets[AInd + 1] - FOffsets[AInd];
  Capacity := Length( ADataBuf );
  if K_NewCapacity( ADataSize,  Capacity ) then
  begin
    ADataBuf := nil;
    SetLength( ADataBuf, Capacity);
  end;

  FStream.Position := FOffsets[AInd];
  FStream.Read( ADataBuf[0], ADataSize );
//  N_AssignFile( UFile, FUndoFilePath, 0 );
//  Seek( UFile, FOffsets[AInd] );
//  BlockRead( UFile, ADataBuf[0], ADataSize );
//  CloseFile( UFile );
end; // end of TK_UNDOBuf.UBGetDataByInd

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf\UBPopData
//**************************************************** TK_UNDOBuf.UBPopData ***
// Pop data from UNDO buffer
//
//     Parameters
// ADataBuf  - byte array buffer for getting data
// ADataSize - getting UNDO data portion size in bytes
//
procedure TK_UNDOBuf.UBPopData( var ADataBuf: TN_BArray; out ADataSize: Integer);
begin
  if FCurInd > 0 then
    Dec( FCurInd );
  if FCurInd < 0 then Exit;
  UBGetDataByInd( FCurInd, ADataBuf, ADataSize );
end; // end of TK_UNDOBuf.UBPopData

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf\UBPrevPopedData
//********************************************** TK_UNDOBuf.UBPrevPopedData ***
// Step to previous data from UNDO buffer
//
//     Parameters
// ADataBuf  - byte array buffer for getting data
// ADataSize - getting UNDO data portion size in bytes
//
procedure TK_UNDOBuf.UBPrevPopedData( var ADataBuf: TN_BArray; out ADataSize: Integer);
begin
  if FCurInd < FCount - 1 then
    Inc( FCurInd );
  if FCurInd >= FCount then Exit;
  UBGetDataByInd( FCurInd, ADataBuf, ADataSize );
end; // end of TK_UNDOBuf.UBPrevPopedData

{*** end of TK_UNDOBuf ***}

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf\UBGetCount
//*************************************************** TK_UNDOBuf.UBGetCount ***
// Get UNDO buffer records counter
//
//     Parameters
// Result - Returns buffer records counter
//
function TK_UNDOBuf.UBGetCount: Integer;
begin
  Result := FCount;
end; // end of TK_UNDOBuf.UBGetCount

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf\UBGetCaptions
//************************************************ TK_UNDOBuf.UBGetCaptions ***
// Get UNDO buffer captions list
//
//     Parameters
// ACapts - Strings with resulting UNDO buffer captions
//
procedure TK_UNDOBuf.UBGetCaptions( ACapts: TStrings );
var
  i : Integer;
begin
  ACapts.Clear;
  for i := FCount - 1 downto 0 do
    ACapts.Add( FCaptions[i] );
end; // end of TK_UNDOBuf.UBGetCaptions

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf\UBGetCaptionByInd
//******************************************** TK_UNDOBuf.UBGetCaptionByInd ***
// Get UNDO buffer record caption by given index
//
//     Parameters
// AInd   - UNDO buffer record index
// Result - Returns UNDO buffer record caption or '' if not proper index.
//
function TK_UNDOBuf.UBGetCaptionByInd( AInd : Integer ) : string;
begin
  Result := '';
  if (AInd >=0) and (AInd < FCount) then
    Result := FCaptions[AInd];
end; // end of TK_UNDOBuf.UBGetCaptionByInd

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf\UBSetCurInd
//************************************************** TK_UNDOBuf.UBSetCurInd ***
// Set UNDO buffer current record index
//
//     Parameters
// AInd - UNDO buffer record index
//
procedure TK_UNDOBuf.UBSetCurInd( AInd : Integer );
begin
  if (AInd >=0) and (AInd < FCount) then
    FCurInd := AInd;
end; // end of TK_UNDOBuf.UBGetCaptions

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf\UBSkipLast
//*************************************************** TK_UNDOBuf.UBSkipLast ***
// Skip last UNDO buffer record
//
procedure TK_UNDOBuf.UBSkipLast( );
begin
  if FCurInd < 0 then Exit;
  Dec(FCurInd);
end; // end of TK_UNDOBuf.UBSkipLast

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf\UBInit
//******************************************************* TK_UNDOBuf.UBInit ***
// Init UNDO buffer
//
procedure TK_UNDOBuf.UBInit( );
begin
  FCount := 0;
  FCurInd := -1;
end; // end of TK_UNDOBuf.UBInit
{*** end of TK_UNDOBuf ***}


{*** TK_UNDOBuf1 ***}

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\Create(2)
//*************************************************** TK_UNDOBuf1.Create(2) ***
// TK_UNDOBuf1 constructor
//
//     Parameters
// AUndoFilePattern - Undo Files Name Pattern
// ASRecNumber      - number of subrecords in UNDO record
//
constructor TK_UNDOBuf1.Create( AUndoFilePattern: string; ASRecNumber : Integer = 1 );
var
  Ind : Integer;
begin
  Ind := 0;
  FUndoFilePattern := AUndoFilePattern;
  FUndoFilePath := N_CreateUniqueFileName(
                  ChangeFileExt( K_ExpandFileName( AUndoFilePattern ), '' ),
                  Ind, ExtractFileExt(AUndoFilePattern) );
  FStream := TFileStream.Create( FUndoFilePath, fmCreate );
  FCurInd := -1;
  SetLength( FOffsets, 1 );
  FSRecNumber := Max( ASRecNumber, 1 );
end; // end of TK_UNDOBuf1.Create

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\CreateByUNDOBuf
//********************************************* TK_UNDOBuf1.CreateByUNDOBuf ***
// TK_UNDOBuf1 constructor
//
//     Parameters
// AUNDOBuf - source UNDO buffer object
//
constructor TK_UNDOBuf1.CreateByUNDOBuf( AUNDOBuf: TK_UNDOBuf1 );
begin
  Create( AUNDOBuf.FUndoFilePattern, AUNDOBuf.FSRecNumber );
  FStream.CopyFrom( AUNDOBuf.FStream, 0 );
  FCaptions    := Copy( AUNDOBuf.FCaptions );
  FOffsets     := Copy( AUNDOBuf.FOffsets );
  FSRecOffsets := Copy( AUNDOBuf.FSRecOffsets );
  FCurInd      := AUNDOBuf.FCurInd;
  FMinInd      := AUNDOBuf.FMinInd;
  FCount       := AUNDOBuf.FCount;
  FSRecCurInd  := AUNDOBuf.FSRecCurInd;
end; // end of TK_UNDOBuf1.CreateByUNDOBuf

//************************************************ TK_UNDOBuf1.Destroy ***
// TK_UNDOBuf1 destructor
//
destructor TK_UNDOBuf1.Destroy;
begin
  FStream.Free;
  K_DeleteFile( FUndoFilePath );

  inherited;
end; // end of TK_UNDOBuf1.Destroy

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBPushData
//************************************************** TK_UNDOBuf1.UBPushData ***
// Push data to UNDO buffer new record
//
//     Parameters
// ACapt     - UNDO data portion caption
// APData    - pointer to UNDO data portion
// ADataSize - UNDO data portion size in bytes
//
procedure TK_UNDOBuf1.UBPushData( ACapt: string; APData: Pointer;
                                 ADataSize: Integer );
begin
  UBPushRecord( ACapt );
  FStream.Position := FOffsets[FCurInd];
  FStream.Write( APData^, ADataSize );
  Inc( FOffsets[FCount], ADataSize ); // Increment Record Final Positon

end; // end of TK_UNDOBuf1.UBPushData

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBGetDataByInd
//********************************************** TK_UNDOBuf1.UBGetDataByInd ***
// Get data from UNDO buffer by given record index
//
//     Parameters
// AInd      - UNDO buffer record index
// ADataBuf  - byte array buffer for getting data
// ADataSize - getting UNDO data portion size in bytes
//
procedure TK_UNDOBuf1.UBGetDataByInd( AInd: Integer; var ADataBuf: TN_BArray;
                                     out ADataSize: Integer );
var
//  UFile: file;
  Capacity : Integer;
begin
  if (AInd < 0) or (AInd >= FCount) then Exit;

  ADataSize := FOffsets[AInd + 1] - FOffsets[AInd];
  Capacity := Length( ADataBuf );
  if K_NewCapacity( ADataSize,  Capacity ) then
  begin
    ADataBuf := nil;
    SetLength( ADataBuf, Capacity);
  end;

  FStream.Position := FOffsets[AInd];
  FStream.Read( ADataBuf[0], ADataSize );
end; // end of TK_UNDOBuf1.UBGetDataByInd

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBDecCurInd
//************************************************* TK_UNDOBuf1.UBDecCurInd ***
// Decrement UNDO buffer Current Index
//
//     Parameters
// Result - Returns TRUE if resulting Current Index has proper value
//
function TK_UNDOBuf1.UBDecCurInd( ) : Boolean;
begin
  if FCurInd > FMinInd then
    Dec( FCurInd );
  Result :=  FCurInd >= FMinInd;
end; // end of TK_UNDOBuf1.UBDecCurInd

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBIncCurInd
//************************************************* TK_UNDOBuf1.UBIncCurInd ***
// Increment UNDO buffer Current Index
//
//     Parameters
// Result - Returns TRUE if resulting Current Index has proper value
//
function TK_UNDOBuf1.UBIncCurInd( ) : Boolean;
begin
  if FCurInd < FCount - 1 then
    Inc( FCurInd );
  Result := FCurInd < FCount;
end; // end of TK_UNDOBuf1.UBIncCurInd

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBPopData
//*************************************************** TK_UNDOBuf1.UBPopData ***
// Pop data from UNDO buffer
//
//     Parameters
// ADataBuf  - byte array buffer for getting data
// ADataSize - getting UNDO data portion size in bytes
//
procedure TK_UNDOBuf1.UBPopData( var ADataBuf: TN_BArray; out ADataSize: Integer);
begin
  if not UBDecCurInd( ) then Exit;
  UBGetDataByInd( FCurInd, ADataBuf, ADataSize );
end; // end of TK_UNDOBuf1.UBPopData

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBPrevPopedData
//********************************************* TK_UNDOBuf1.UBPrevPopedData ***
// Step to previous data from UNDO buffer
//
//     Parameters
// ADataBuf  - byte array buffer for getting data
// ADataSize - getting UNDO data portion size in bytes
//
procedure TK_UNDOBuf1.UBPrevPopedData( var ADataBuf: TN_BArray; out ADataSize: Integer);
begin
  if not UBIncCurInd( ) then Exit;
  UBGetDataByInd( FCurInd, ADataBuf, ADataSize );
end; // end of TK_UNDOBuf1.UBPrevPopedData

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBGetCount
//************************************************** TK_UNDOBuf1.UBGetCount ***
// Get UNDO buffer records counter
//
//     Parameters
// Result - Returns buffer records counter
//
function TK_UNDOBuf1.UBGetCount: Integer;
begin
  Result := FCount;
end; // end of TK_UNDOBuf1.UBGetCount

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBGetCaptions
//*********************************************** TK_UNDOBuf1.UBGetCaptions ***
// Get UNDO buffer captions list
//
//     Parameters
// ACapts - Strings with resulting UNDO buffer captions
//
procedure TK_UNDOBuf1.UBGetCaptions( ACapts: TStrings );
var
  i : Integer;
begin
  ACapts.Clear;
  for i := FCount - 1 downto 0 do
    ACapts.Add( FCaptions[i] );
end; // end of TK_UNDOBuf1.UBGetCaptions

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBGetCaptionByInd
//******************************************* TK_UNDOBuf1.UBGetCaptionByInd ***
// Get UNDO buffer record caption by given index
//
//     Parameters
// AInd   - UNDO buffer record index
// Result - Returns UNDO buffer record caption or '' if not proper index.
//
function TK_UNDOBuf1.UBGetCaptionByInd( AInd : Integer ) : string;
begin
  Result := '';
  if (AInd >=0) and (AInd < FCount) then
    Result := FCaptions[AInd];
end; // end of TK_UNDOBuf1.UBGetCaptionByInd

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBSetCurInd
//************************************************* TK_UNDOBuf1.UBSetCurInd ***
// Set UNDO buffer current record index
//
//     Parameters
// AInd - UNDO buffer record index
//
procedure TK_UNDOBuf1.UBSetCurInd( AInd : Integer );
begin
  if (AInd >= FMinInd) and (AInd < FCount) then
    FCurInd := AInd;
end; // end of TK_UNDOBuf1.UBSetCurInd

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBSetMinInd
//************************************************* TK_UNDOBuf1.UBSetMinInd ***
// Set UNDO buffer minimal record index
//
//     Parameters
// AInd - UNDO buffer record index
//
procedure TK_UNDOBuf1.UBSetMinInd( AInd : Integer );
begin
  if (AInd >=0) and (AInd < FCount) then
    FMinInd := AInd;
end; // end of TK_UNDOBuf1.UBSetMinInd

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBSkipLast
//************************************************** TK_UNDOBuf1.UBSkipLast ***
// Skip last UNDO buffer record
//
procedure TK_UNDOBuf1.UBSkipLast( );
begin
  if FCurInd < 0 then Exit;
  Dec(FCurInd);
end; // end of TK_UNDOBuf1.UBSkipLast

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBInit
//****************************************************** TK_UNDOBuf1.UBInit ***
// Init UNDO buffer
//
procedure TK_UNDOBuf1.UBInit( );
begin
  FCount := 0;
  FMinInd := 0;
  FCurInd := -1;
end; // end of TK_UNDOBuf1.UBInit

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBPushRecord
//************************************************ TK_UNDOBuf1.UBPushRecord ***
// Start new UNDO buffer record
//
//     Parameters
// ACapt - UNDO data portion caption
//
procedure TK_UNDOBuf1.UBPushRecord( const ACapt: string );
var
  Capacity : Integer;
  SRInd, i : Integer;
  COffs : Integer;
begin

//*** Push Cur Record Index
  Inc( FCurInd );
  FCount := FCurInd;

//*** Increase Contents arrays Capacity
  Inc( FCount );
  Capacity := Length(FCaptions);
  if K_NewCapacity( FCount,  Capacity ) then begin
    SetLength( FCaptions, Capacity);
    SetLength( FOffsets, Capacity + 1 );
    SetLength( FSRecOffsets, FSRecNumber * Capacity );
  end;

//*** Store new Record Caption and File position
  FOffsets[FCount] := FOffsets[FCurInd];
  FCaptions[FCurInd] := ACapt;

//*** Clear new Record Subrecords Offsets
  SRInd := FCurInd * FSRecNumber;
  ZeroMemory( @FSRecOffsets[SRInd], SizeOf(Integer) * FSRecNumber );
  FSRecCurInd := -1;
  if SRInd = 0 then Exit; // Start Record

//*** Init new Record Subrecords Offsets by previous Record Subrecords Offsets
  for i := 1 to FSRecNumber do begin
  // Build Reference to previous Subrecord or use previous Reference
    COffs := FSRecOffsets[SRInd - FSRecNumber];
    if COffs >= 0 then // Build Reference to Subrecord
      COffs := - FCurInd;
    FSRecOffsets[SRInd] := COffs;
    Inc(SRInd);
  end;

end; // end of TK_UNDOBuf1.UBPushRecord

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBPushSubRecordData
//***************************************** TK_UNDOBuf1.UBPushSubRecordData ***
// Push subrecord data to UNDO buffer
//
//     Parameters
// APData    - pointer to UNDO subrecord data portion
// ADataSize - UNDO data portion size in bytes
//
procedure TK_UNDOBuf1.UBPushSubRecordData( ASRInd : Integer; APData: Pointer; ADataSize: Integer );
var
  COffs : Integer;
begin
  Assert( (ASRInd > FSRecCurInd) and (ASRInd < FSRecNumber), 'Wrong UNDO subrecord index' );

//*** Write new Subrecord to file
  COffs := FOffsets[FCount];
  FStream.Position := COffs;
  FStream.Write( APData^, ADataSize );

//*** Change Offsets
  ASRInd := ASRInd + FCurInd * FSRecNumber;
  FSRecOffsets[ASRInd] := COffs; // Save Subrecord Offset to Subrecords File offsets
  Inc( FOffsets[FCount], ADataSize ); // Increment Record Final Positon

end; // end of TK_UNDOBuf1.UBPushSubRecordData

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBGetSubRecordData
//****************************************** TK_UNDOBuf1.UBGetSubRecordData ***
// Get UNDO buffer current record data by subrecord index
//
//     Parameters
// ASRInd    - UNDO buffer subrecord index
// ADataBuf  - byte array buffer for getting UNDO buffer subrecord data
// ADataSize - getting UNDO data portion size in bytes
//
procedure TK_UNDOBuf1.UBGetSubRecordData( ASRInd : Integer;
                           var ADataBuf : TN_BArray; out ADataSize : Integer );
var
  Capacity, COffs, NOffs, RInd, SRInd, i : Integer;
begin

//*** Get Subrecord Offset
  SRInd := ASRInd + FCurInd * FSRecNumber;
  COffs := FSRecOffsets[SRInd];
  RInd := FCurInd;
  if COffs < 0 then begin
  // Reference - Build Offset context
    RInd := - COffs - 1;
    SRInd := ASRInd + RInd * FSRecNumber;
    COffs := FSRecOffsets[SRInd];
  end;

//*** Calculate Subrecord Data Size
  NOffs := -1;
  for i := SRInd + 1 to (RInd + 1) * FSRecNumber - 1 do begin
    NOffs := FSRecOffsets[i];
    if NOffs > 0 then Break;
  end;
  if NOffs < 0 then // use next record offset
    NOffs := FOffsets[RInd + 1];


//*** Prepapre Subrecord Data Buffer
  ADataSize := NOffs - COffs;
  Capacity := Length( ADataBuf );
  if K_NewCapacity( ADataSize,  Capacity ) then
  begin
    ADataBuf := nil;
    SetLength( ADataBuf, Capacity);
  end;

//*** Read Subrecord Data
  FStream.Position := COffs;
  FStream.Read( ADataBuf[0], ADataSize );

end; // end of TK_UNDOBuf1.UBGetSubRecordData

//##path K_Delphi\SF\K_clib\K_CLib.pas\TK_UNDOBuf1\UBChangeSubRecordReference
//********************************** TK_UNDOBuf1.UBChangeSubRecordReference ***
// Push subrecord data to UNDO buffer
//
//     Parameters
// ASRInd  - UNDO buffer subrecord index
// ARefInd - new reference value of UNDO buffer record index
//
procedure TK_UNDOBuf1.UBChangeSubRecordReference( ASRInd : Integer; ARefInd : Integer );
var
  COffs : Integer;
begin
  Assert( (ASRInd > FSRecCurInd) and (ASRInd < FSRecNumber), 'Wrong UNDO subrecord index' );
  Assert( (ARefInd >= 0) and (ARefInd < FCount), 'Wrong UNDO record reference index' );
  ASRInd := ASRInd + FCurInd * FSRecNumber;
  COffs := FSRecOffsets[ASRInd];
  Assert( COffs < 0,  'SubRecord value is not reference' );
  FSRecOffsets[ASRInd] := - ARefInd - 1;
end; // end of TK_UNDOBuf1.UBChangeSubRecordReference


{*** end of TK_UNDOBuf1 ***}


{*** TK_TextsNGSimilarity ***}

//************************************* TK_TextsNGSimilarity.BuildOneNGInts ***
// Prepare N-Grams Integers for given Text
//
//     Parameters
// ANGIntsBuf      - given N-Grams Integers buffer array
// ANGIntsCount    - resulting N-Grams Integers count
// ANGVectorCount  - resulting N-Grams Vector elements count
// ATextPtr        - source text ponter
// ATextCharLength - source text length in chars
// ACharSize       - char size in bytes
// Resulr          - Returns N-Grams vector length
//
function TK_TextsNGSimilarity.BuildOneNGInts( var ANGIntsBuf : TN_IArray;
                   out ANGIntsCount, ANGVectorCount : Integer;
                   ATextPtr : TN_BytesPtr; ATextCharLength : Integer;
                   ACharSize : Integer ) : Double;
var
  k, i, n : Integer;
  CurElem, CurDimVal : Integer;
  CurFragmShift, CurFragmLength : Integer;
begin
  if FGramLegth = 0 then FGramLegth := 3; // precaution
  if FGramShift = 0 then FGramShift := 1; // precaution
  k := (ATextCharLength - FGramLegth) div FGramShift;

  if ATextCharLength >= FGramLegth then Inc(k);
  ANGIntsCount := k;

  ANGVectorCount := 0;
  Result := 0;
  if k = 0 then Exit;

  // Create N_Grams Integers representation
  K_SetIArrayCapacity( ANGIntsBuf, 3 * k );
  CurFragmShift := FGramShift * ACharSize;
  CurFragmLength := FGramLegth * ACharSize;
  if CurFragmLength <= 4 then
    for i := 0 to k - 1 do
    begin
      ANGIntsBuf[i] := 0;
      move( ATextPtr^, ANGIntsBuf[i], CurFragmLength );
      ATextPtr := ATextPtr + CurFragmShift;
    end
  else
    for i := 0 to k - 1 do
    begin
      ANGIntsBuf[i] := N_AdlerCheckSum( ATextPtr, CurFragmLength );
      ATextPtr := ATextPtr + CurFragmShift;
    end;

  // Order N_Grams Integers representation
  N_SortElements( TN_BytesPtr(@ANGIntsBuf[0]), k, SizeOf(Integer), 0, N_CompareIntegers );

  // Calculate Vector Elements and Vector NG length
  n := k;
  CurElem := ANGIntsBuf[0];
  ANGIntsBuf[n] := CurElem;
  CurDimVal := 1;
  for i := 1 to k - 1 do
  begin
    if CurElem = ANGIntsBuf[i] then
      Inc(CurDimVal)
    else
    begin
      ANGIntsBuf[n + 1] := CurDimVal;
      Result := Result + CurDimVal * CurDimVal;
      CurElem := ANGIntsBuf[i];
      n := n + 2;
      ANGIntsBuf[n] := CurElem;
      CurDimVal := 1;
    end;
  end;
  ANGIntsBuf[n + 1] := CurDimVal;
  Result := Result + CurDimVal * CurDimVal;
  ANGVectorCount := (n + 2 - k) shr 1;
end; // procedure TK_TextsNGSimilarity.BuildOneNGInts

//********************************** TK_TextsNGSimilarity.CalcSimilarityVal ***
// Calculate two Texts Similarity Value as two vectors in N-grams dimensional space cosine square
//
//     Parameters
// Result - Returns Texts Similarity Value (float value from 0 to 1, 1 - equal, 0 - no Similarity at all)
//
function TK_TextsNGSimilarity.CalcSimilarityVal() : Double;
var
  ScalProd : Double;
  CalcContinue : Boolean;
  i1, i2, f1, f2 : Integer;

begin
  Result := 0;
  if (FNGVectorCount1 = 0) or (FNGVectorCount2 = 0) then Exit;
  ScalProd := 0;
  i1 := FNGIntsCount1;
  i2 := FNGIntsCount2;
  f1 := i1 + FNGVectorCount1 * 2;
  f2 := i2 + FNGVectorCount2 * 2;

  repeat
    if FNGIntsBuf1[i1] = FNGIntsBuf2[i2] then
    begin
      ScalProd := ScalProd + FNGIntsBuf1[i1+1] * FNGIntsBuf2[i2+1];
      i1 := i1 + 2;
      i2 := i2 + 2;
      CalcContinue := (i1 < f1) and (i2 < f2);
    end // if FNGIntsBuf1[i1] = FNGIntsBuf2[i2] then
    else
    if FNGIntsBuf1[i1] < FNGIntsBuf2[i2] then
    begin
      i1 := i1 + 2;
      CalcContinue := i1 < f1;
    end   // if FNGIntsBuf1[i1] < FNGIntsBuf2[i2] then
    else
    begin // if FNGIntsBuf1[i1] > FNGIntsBuf2[i2] then
      i2 := i2 + 2;
      CalcContinue := i2 < f2;
    end; // if FNGIntsBuf1[i1] > FNGIntsBuf2[i2] then
  until not CalcContinue;

  Result := ScalProd / SQRT( FNGVSQLength1 * FNGVSQLength2 );

end; // function TK_TextsNGSimilarity.CalcSimilarityVal


//****************************************** TK_TextsNGSimilarity.SetText1A ***
// Set 1-st ANSI Text to compare
//
//     Parameters
// ATextPtr    - given ANSI Text string
//
procedure TK_TextsNGSimilarity.SetText1A( const AText: AnsiString );
begin
  FNGIntsCount1 := 0;
  if Length(AText) = 0 then Exit;
  SetText1A( @AText[1], Length(AText) );
end; // procedure TK_TextsNGSimilarity.SetText1A

//****************************************** TK_TextsNGSimilarity.SetText1A ***
// Set 1-st ANSI Text to compare
//
//     Parameters
// ATextPtr    - given pointer to ANSI Text start char
// ATextLength - given Text length in ANSI chars
//
procedure TK_TextsNGSimilarity.SetText1A( ATextPtr: PAnsiChar; ATextLength: Integer );
begin
  FNGVSQLength1 := BuildOneNGInts( FNGIntsBuf1, FNGIntsCount1, FNGVectorCount1, TN_BytesPtr(ATextPtr), ATextLength, 1 );
end; // procedure TK_TextsNGSimilarity.SetText1A

//****************************************** TK_TextsNGSimilarity.SetText1W ***
// Set 1-st Wide Text to compare
//
//     Parameters
// ATextPtr    - given Wide Text string
//
procedure TK_TextsNGSimilarity.SetText1W( const AText: WideString );
begin
  FNGVectorCount1 := 0;
  if Length(AText) = 0 then Exit;
  SetText1W( @AText[1], Length(AText) );
end; // procedure TK_TextsNGSimilarity.SetText1W

//****************************************** TK_TextsNGSimilarity.SetText1W ***
// Set 1-st Wide Text to compare
//
//     Parameters
// ATextPtr    - given pointer to Wide Text start char
// ATextLength - given Wide Text length in wide chars
//
procedure TK_TextsNGSimilarity.SetText1W( ATextPtr: PWideChar; ATextLength: Integer);
begin
  FNGVSQLength1 := BuildOneNGInts( FNGIntsBuf1, FNGIntsCount1, FNGVectorCount1, TN_BytesPtr(ATextPtr), ATextLength, 2 );
end; // procedure TK_TextsNGSimilarity.SetText1W

//******************************************* TK_TextsNGSimilarity.SetText1 ***
// Set 1-st Text to compare
//
//     Parameters
// AText - given Text string to compare
//
procedure TK_TextsNGSimilarity.SetText1( const AText: string );
begin
  if SizeOf(char) = 2 then
    SetText1W( AText )
  else
    SetText1A( AnsiString(AText) );
end; // procedure TK_TextsNGSimilarity.SetText1

//******************************************* TK_TextsNGSimilarity.SetText1 ***
// Set 1-st Text to compare
//
//     Parameters
// ATextPtr    - given pointer to Text start char
// ATextLength - given Text length in chars
//
procedure TK_TextsNGSimilarity.SetText1( ATextPtr: PChar; ATextLength: Integer );
begin
  if SizeOf(char) = 2 then
    SetText1W( PWideChar(ATextPtr), ATextLength )
  else
    SetText1A( PAnsiChar(ATextPtr), ATextLength );
end; // procedure TK_TextsNGSimilarity.SetText1

//****************************************** TK_TextsNGSimilarity.SetText2A ***
// Set 2-nd ANSI Text to compare
//
//     Parameters
// ATextPtr    - given ANSI Text string
//
procedure TK_TextsNGSimilarity.SetText2A( const AText: AnsiString );
begin
  FNGVectorCount2 := 0;
  if Length(AText) = 0 then Exit;
  SetText2A( @AText[1], Length(AText) );
end; // procedure TK_TextsNGSimilarity.SetText2A

//****************************************** TK_TextsNGSimilarity.SetText2A ***
// Set 2-nd ANSI Text to compare
//
//     Parameters
// ATextPtr    - given pointer to ANSI Text start char
// ATextLength - given Text length in ANSI chars
//
procedure TK_TextsNGSimilarity.SetText2A( ATextPtr: PAnsiChar;
  ATextLength: Integer );
begin
  FNGVSQLength2 := BuildOneNGInts( FNGIntsBuf2, FNGIntsCount2, FNGVectorCount2, TN_BytesPtr(ATextPtr), ATextLength, 1 );
end; // procedure TK_TextsNGSimilarity.SetText2A

//****************************************** TK_TextsNGSimilarity.SetText2W ***
// Set 2-nd Wide Text to compare
//
//     Parameters
// ATextPtr    - given Wide Text string
//
procedure TK_TextsNGSimilarity.SetText2W( const AText: WideString );
begin
  FNGIntsCount1 := 0;
  if Length(AText) = 0 then Exit;
  SetText2W( @AText[1], Length(AText) );
end; // procedure TK_TextsNGSimilarity.SetText2W

//****************************************** TK_TextsNGSimilarity.SetText2W ***
// Set 2-nd Wide Text to compare
//
//     Parameters
// ATextPtr    - given pointer to Wide Text start char
// ATextLength - given Text length in wide chars
//
procedure TK_TextsNGSimilarity.SetText2W( ATextPtr: PWideChar; ATextLength: Integer);
begin
  FNGVSQLength2 := BuildOneNGInts( FNGIntsBuf2, FNGIntsCount2, FNGVectorCount2, TN_BytesPtr(ATextPtr), ATextLength, 2 );
end; // procedure TK_TextsNGSimilarity.SetText2W

//******************************************* TK_TextsNGSimilarity.SetText2 ***
// Set 2-nd Text to compare
//
//     Parameters
// AText - given Text string
//
procedure TK_TextsNGSimilarity.SetText2( const AText: string );
begin
  if SizeOf(char) = 2 then
    SetText2W( AText )
  else
    SetText2A( AnsiString(AText) );
end; // procedure TK_TextsNGSimilarity.SetText2

//******************************************* TK_TextsNGSimilarity.SetText2 ***
// Set 2-nd Text to compare
//
//     Parameters
// ATextPtr    - given pointer to Text start char
// ATextLength - given Text length in chars
//
procedure TK_TextsNGSimilarity.SetText2( ATextPtr: PChar; ATextLength: Integer );
begin
  if SizeOf(char) = 2 then
    SetText2W( PWideChar(ATextPtr), ATextLength )
  else
    SetText2A( PAnsiChar(ATextPtr), ATextLength );
end; // procedure TK_TextsNGSimilarity.SetText2

{*** end of TK_TextsNGSimilarity ***}

function K_PrepFullScreenInfo( AControl : TControl; var AControlRect, AMonitorRect : TRect ) : TRect;
var
  CurMonitor : TMonitor;
  MonitorIndex : Integer;

begin
  with AControl do
    AControlRect := IRect( Left, Top, Left + Width, Top + Height );
  N_GetMonWARByRect( AControlRect, @MonitorIndex );
  CurMonitor := Screen.Monitors[MonitorIndex];

  with CurMonitor do
  begin
    AMonitorRect := WorkareaRect;
    Result.Bottom := WorkareaRect.Bottom - WorkareaRect.Top;
    Result.Right  := WorkareaRect.Right - WorkareaRect.Left;
    Result.Left   := WorkareaRect.Left;
    Result.Top    := WorkareaRect.Top;
    if Primary then // Current Monitor is Primary
    begin
    // use whole Monitor Size instead of Work Area Size
    // (TaskBar is present only on Primary monitor)
      Result.Bottom := Height;
      Result.Right  := Width;
      Result.Left   := Left;
      Result.Top    := Top;
    end;
  end; //  with CurMonitor do
end; // function K_PrepFullScreenInfo

end.
