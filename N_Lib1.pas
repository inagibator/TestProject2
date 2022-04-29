unit N_Lib1;
// general purpose low level definitions and code
//
// Interface section uses only N_Types and Delphi units
// Implementation section uses 11 own and some Delphi units

interface
uses Windows, Graphics, Classes, Controls, Stdctrls, Comctrls, Forms,
     IniFiles, Contnrs, Menus, ZLib, CheckLst, Types,
     N_Types;


//##/*
//*******  Actions List Objects and procedures  *******

type TN_BaseActionObj = class( TObject ) // abstract class for any action
  Enabled: boolean;       // action can be executed (it's owner exists)
  ListsCounter: integer;  // number of Lists in which Self is included
  ActName: string;        // mainly for deb ug

  constructor Create();
  destructor  Destroy; override;
  function  ActToStr   (): string;
  procedure ExecAction (); virtual; abstract;
end; // type TN_BaseActionObj = class( TObject )
type TN_BaseActionObjType = Class of TN_BaseActionObj;

type TN_ClearVarActObj = class( TN_BaseActionObj ) // Clear Variable Action
  PVarToClear: Pointer; // Pointer to Valiable to be cleared in ExecAction
  constructor Create( APVar: Pointer );
  procedure ExecAction (); override;
end; // type TN_ClearVarActObj = class( TN_BaseActionObj )

type TN_CloseFormActObj = class( TN_BaseActionObj ) // Close Form Action
  FormToClose: TForm; // Form to be closed in ExecAction
  constructor Create( AFormToClose: TForm );
  procedure ExecAction (); override;
end; // type TN_CloseFormActObj = class( TN_BaseActionObj )

type TN_ProcOfObjActObj = class( TN_BaseActionObj ) // Call Procedure() of Object
  ProcObjToCall: TN_ProcObj; // Procedure of Object that should be called in ExecAction
  constructor Create( AProcObj: TN_ProcObj );
  procedure ExecAction (); override;
end; // type TN_ProcOfObjActObj = class( TN_BaseActionObj )

type TN_ActListObj = class( TList ) //***** arbitrary Actions List
  constructor Create();
  destructor  Destroy; override;
  function  ALOToStr       (): string;
  procedure ExecActions    ();
  procedure AddGivenAction ( AnActionObj: TN_BaseActionObj );
  function  AddNewAction   ( ActObjType: TN_BaseActionObjType ): TN_BaseActionObj;
  function  AddNewClearVarAction  ( APVar: Pointer ): TN_ClearVarActObj;
  function  AddNewCloseFormAction ( AForm: TForm ): TN_CloseFormActObj;
  function  AddNewProcOfObjAction ( AProcObj: TN_ProcObj ): TN_ProcOfObjActObj;

end; // type TN_ActListObj = class( TList )

procedure N_ExecAndDestroy( var AnActionList: TN_ActListObj );

type TN_UniqueId = class( TStringList ) //*** obj for creating Unique Identifiers
  constructor Create();
  function GetAnyId( MinLeng, MaxLeng: integer ): string;
  function GetUniqueId( Prefix: string; MinLeng, MaxLeng: integer ): string;
end; // type TN_UniqueId = class( TStringList )

type TN_CLBItemType = ( clbNormal, clbHeader );

type TN_CLBItem = record //************************* one CheckListBox Item
  CLBId:   string;
  CLBText: string;
  CLBType: TN_CLBItemType;
  CLBValue: boolean;
end; // type TN_CLBItem = record

type TN_ENumElem = record //***** One Emum element description
  ENEName: string;
  ENEInd: integer;
end; // type TN_ENumElem = record
type TN_ENumElems = Array of TN_ENumElem;
//##*/

//****************** Other Global procedures **********************

//##/*
procedure N_FillCheckListBox  ( const ACLBDescr: array of TN_CLBItem; ACLB: TCheckListBox );
procedure N_FillCLBDesrValues ( var ACLBDescr: array of TN_CLBItem; ACLB: TCheckListBox );
function  N_GetCLBValue       ( const ACLBDescr: array of TN_CLBItem; AnId: string ): Boolean;
//##*/

procedure N_CopyList      ( ADstList, ASrcList: TList );
function  N_FindPtrByType ( AList: Tlist; ANeededClass: TClass  ): integer;
function  N_ConvCellToCSV ( const AStr: string; ADelim: Char ): string;

procedure N_ConvTextToHex ( const ASrcStr: string; AHexStrings: TStrings; ASrcStrMaxSize: integer );
procedure N_ConvMemToHex  ( AMemPtr: Pointer; ANumBytes: integer; AStartAdr: DWORD; AResStrings: TStrings );

function  N_TimeDeltaInSeconds ( ASavedTime: double ): double;
procedure N_DelayInSeconds ( ASeconds: double; const ADelta: double = 1000.0 );

function  N_32ToR32BitColor ( ATrueColor: integer ): integer;
function  N_32To16BitColor  ( ATrueColor: integer ): integer;
function  N_16To32BitColor  ( AHighColor: integer ): integer;
function  N_32ToR16BitColor ( ATrueColor: integer ): integer;
function  N_16ToR32BitColor ( AHighColor: integer ): integer;
function  N_16ToR16BitColor ( AHighColor: integer ): integer;
function  N_RoundTo16bitColor ( ATrueColor: integer ): integer;

function  N_CompareIntegers ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
function  N_CompareDoubles  ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
function  N_Compare3Ints    ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
function  N_Compare4Ints    ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
function  N_Compare3IntsAndFloat  ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
function  N_Compare3IntsAndDouble ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;

procedure N_CreatePtrsArray ( PElemArray: TN_BytesPtr; ElemCount, ElemSize: integer;
                              out PtrsArray: TN_PArray );
procedure N_SortPointers ( APtrsArray: TN_PArray;
                         ACompareParam: integer; ACompareFunc: TN_CompareFunc ); overload
function  N_GetSortedPointers( APFirstElem: Pointer; AElemCount, AElemSize: integer;
                ACompareParam: integer; ACompareFunc: TN_CompareFunc ): TN_PArray;
function  N_GetSortedIndexes( APFirstElem: Pointer; AElemCount, AElemSize: integer;
                ACompareParam: integer; ACompareFunc: TN_CompareFunc ): TN_IArray;
procedure N_SortElements ( APElemArray: TN_BytesPtr; AElemCount, AElemSize: integer;
                           ACompareParam: integer; ACompareFunc: TN_CompareFunc );
function  N_BinSearch1 ( APElemArray: TN_BytesPtr; AElemCount, AElemSize, AIValue: integer ): Integer;
function  N_BinSearch2 ( APElemArray: TN_BytesPtr; AElemCount, AElemSize, AIValue: integer ): Integer;

procedure N_CreateTestColors ( AMode: TN_RAFillColorsType; AColor1, AColor2: integer;
                                        APColors: PInteger; ACount: Integer );
function  N_InterpolateTwoColors ( AColor1, AColor2: Integer; AAlpha: double ): integer;

function  N_ProcessMessages (): integer;

procedure N_RemoveSMatrRows ( var ASMatr: TN_ASArray; APat1: string = '';
                                        APat2: string = ''; APat3: string = '' );
procedure N_LoadDBFColumns ( var AStrMatr: TN_ASArray; APColNames: PString;
                                       ANumColumns: integer; AFileName: string );


procedure N_SaveSMatrToString0  ( AStrMatr: TN_ASArray; AStrings: TStrings;
                                                        ADelim: Char = ';' );
procedure N_SaveSMatrToStrings ( AStrMatr: TN_ASArray; AStrings: TStrings;
                                                 ASMFormat: TN_StrMatrFormat );
procedure N_SaveSMatrToFile ( AStrMatr: TN_ASArray; AFileName: string;
                                                 ASMFormat: TN_StrMatrFormat );
//##/*
function  N_LoadSMatrFromCSV ( var StrMatr: TN_ASArray; // temporary!
                               FName, BegPattern, EndPattern: string ): integer;
//##*/
procedure N_SaveSMatrToText ( AStrMatr: TN_ASArray; AStrings: TStrings;
                                                          ASpaceGap: integer );
function  N_SaveSMatrToString   ( AStrMatr: TN_ASArray ): string;
//procedure N_AdjustStrMatr       ( AStrMatr: TN_ASArray; AColCount: integer = 0 );
function  N_LoadSMatrFromTxt    ( var AStrMatr: TN_ASArray;
                              AFName, ABegPattern, AEndPattern: string ): integer;

{
procedure N_LoadStrMatrFromString ( var StrMatr: TN_ASArray; InpStr: string );
procedure N_SaveStrMatrToStrings ( AStrMatr: TN_ASArray; AStrings: TStrings;
                                           ASDF: TK_StringsDataFormat );
procedure N_SaveStringsToFile   ( AStrings: TStrings; AFileName: string );
procedure N_LoadStringsFromFile1 ( AStrings: TStrings; AFileName: string );

function  N_GetPatternIndex ( AStrings: TStrings;
                              APattern: string; ABegInd: integer ): integer;
procedure N_ReplaceSectionInStrings ( ASrcStrings, AResStrings, ASection: TStrings;
                                                         ASectionName: string );
function  N_GetSectionFromStrings ( AStrings, ASection: TStrings;
                          ASectionName: string; ABegInd: integer = 0 ): integer;
procedure N_ReplaceSectionInFile ( AFileName: string; ASection: TStrings;
                                                         ASectionName: string );
procedure N_GetSectionFromFile ( AFileName: string; ASection: TStrings;
                                                         ASectionName: string );
}
//function  N_GetFileExtentionType ( AFileName: string ): TN_FileExtType;
//##/*
procedure N_CreateFileCopy  ( ASrcFName, ADstFName: string );

function  N_DebugWait (): integer;
//##*/

function  N_DosToWin  ( ADosStr: AnsiString ): string;
function  N_WinToDos  ( AWinStr: string ): AnsiString;
//##/*
procedure N_CreateTextNums ( MaxNum: integer; FileName: string );
//##*/

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_CurMemIni
//************************************************************* N_CurMemIni ***
// Current Buffered Windows INI file
//
// Global variable N_CurMemIni points to Buffered Windows INI file which is used
// to store and retrieve application-specific information and settings.
//
//#### N_CurMemIni
// ************************************ end of N_CurMemIni

procedure N_BoolToGivenIni   ( AGivenIni: TMemIniFile; ASectionName, ABoolName: string; ABool: boolean );
function  N_GivenIniToBool   ( AGivenIni: TMemIniFile; ASectionName, ABoolName: string; ADefVal: boolean ): boolean;

procedure N_StringToGivenIni ( AGivenIni: TMemIniFile; ASectionName, AStringName, AString: string );
function  N_GivenIniToString ( AGivenIni: TMemIniFile; ASectionName, AStringName: string; ADefVal: string ): string;

procedure N_IntToGivenIni    ( AGivenIni: TMemIniFile; ASectionName, AIntName: string; AInt: integer );
function  N_GivenIniToInt    ( AGivenIni: TMemIniFile; ASectionName, AIntName: string; ADefVal: Integer ): integer;

procedure N_DblToGivenIni    ( AGivenIni: TMemIniFile; ASectionName, ADblName, AFmt: string; ADbl: double );
function  N_GivenIniToDbl    ( AGivenIni: TMemIniFile; ASectionName, ADblName: string; ADefVal: double ): double;


procedure N_WriteMemIniSection ( ASectionName: string; AStrings: TStrings );
procedure N_ReadMemIniSection  ( ASectionName: string; AStrings: TStrings );

procedure N_BoolToMemIni     ( ASectionName, ABoolName: string; ABool: boolean );
function  N_MemIniToBool     ( ASectionName, ABoolName: string;
                                           ADefVal: boolean = False ): boolean;
procedure N_StringToMemIni   ( ASectionName, AStringName, AString: string );
function  N_MemIniToString   ( ASectionName, AStringName: string;
                                             ADefVal: string = '' ): string;
procedure N_StringsToMemIni  ( ASectionName: string; AStrings: TStrings );
procedure N_MemIniToStrings  ( ASectionName: string; AStrings: TStrings );
procedure N_SetSectionTopString( ASectionName, ATopString: string; AMaxListSize: integer = 0 );
procedure N_ComboBoxToMemIni ( ASectionName: string; AComboBox: TComboBox );
procedure N_MemIniToComboBox ( ASectionName: string; AComboBox: TComboBox );
procedure N_IntToMemIni     ( ASectionName, AIntName: string; AInt: integer );
function  N_MemIniToInt     ( ASectionName, AIntName: string; ADefVal: integer = N_NotAnInteger ): integer;
procedure N_IntToMemIniAsHex   ( ASectionName, AIntName: string; AInt, AMinDigits: integer );
function  N_MemIniToIntFromHex ( ASectionName, AIntName: string; ADefVal: Integer ): integer;
//procedure N_HexToMemIni     ( ASectionName, AIntName: string; AInt, AMinDigits: integer );
//function  N_MemIniToHex     ( ASectionName, AIntName: string; ADefVal: Integer ): integer;
procedure N_BytesToMemIni   ( ASectionName, ABytesName: string; APBytes: Pointer; ANumBytes: integer );
procedure N_MemIniToBytes   ( ASectionName, ABytesName: string; APBytes: Pointer; ANumBytes: integer );
procedure N_DblToMemIni     ( ASectionName, ADblName, AFmt: string; ADbl: double );
function  N_MemIniToDbl     ( ASectionName, ADblName: string; ADefVal: double ): double;
procedure N_SPLValToMemIni  ( ASectionName, AValName: string; const AValue; ASPLSType: integer );
procedure N_MemIniToSPLVal  ( ASectionName, AValName: string; var AValue; ASPLSType: integer );
procedure N_ControlToMemIni ( ASectionName, AControlName: string; AControl: TControl; AModeStr: string = ''  );
function  N_MemIniToControl ( ASectionName, AControlName: string; AControl: TControl ): boolean;
procedure N_4IntToMemIni    ( ASectionName, AIntsName: string; AInt1, AInt2, AInt3, AInt4: integer );
function  N_MemIniTo4Int    ( ASectionName, AIntsName: string; var AInt1, AInt2, AInt3, AInt4: integer ): boolean;
procedure N_RectToMemIni    ( ASectionName, ARectName: string; const ARect: TRect );
function  N_MemIniToRect    ( ASectionName, ARectName: string; var ARect: TRect ): boolean;
function  N_MemIniToRect2   ( ASectionName, ARectName: string; var ATopLeft, ASize: TPoint ): boolean;
//##/*
procedure N_CLBToMemIni     ( ASectionName, ACLBName: string; ACLBDescr: array of TN_CLBItem );
procedure N_MemIniToCLB     ( ASectionName, ACLBName: string; var ACLBDescr: array of TN_CLBItem );

type TN_MemIniObj = class( TObject ) //***** MemIni Object
  MemIniFile: TMemIniFile; // Self is not the Owner of this field!

  constructor Create();
  destructor  Destroy; override;
  procedure WriteSection ( ASectionName: string; AStrings: TStrings );
  procedure ReadSection  ( ASectionName: string; AStrings: TStrings );

  procedure PutBool    ( ASectionName, ABoolName: string; ABool: boolean );
  function  GetBool    ( ASectionName, ABoolName: string; ADefVal: boolean = False ): boolean;
  procedure PutString  ( ASectionName, AStringName, AString: string );
  function  GetString  ( ASectionName, AStringName: string; ADefStr: string = '' ): string;
  procedure PutInt     ( ASectionName, AIntName: string; AInt: integer );
  function  GetInt     ( ASectionName, AIntName: string; ADefVal: Integer ): integer;
  procedure PutHex     ( ASectionName, AIntName: string; AInt, AMinDigits: integer );
  function  GetHex     ( ASectionName, AIntName: string; ADefVal: Integer ): integer;
  procedure PutDbl     ( ASectionName, ADblName, AFmt: string; ADbl: double );
  function  GetDbl     ( ASectionName, ADblName: string; ADefVal: double ): double;

  procedure PutBytes     ( ASectionName, ABytesName: string; APBytes: Pointer; ANumBytes: integer );
  procedure GetBytes     ( ASectionName, ABytesName: string; APBytes: Pointer; ANumBytes: integer );
  procedure PutStrings   ( ASectionName: string; AStrings: TStrings );
  procedure GetStrings   ( ASectionName: string; AStrings: TStrings );
  procedure SetTopString ( ASectionName, ATopString: string; AMaxListSize: integer );

  procedure PutControl  ( ASectionName, AControlName: string; AControl: TControl );
  procedure GetControl  ( ASectionName, AControlName: string; AControl: TControl );
  procedure PutComboBox ( ASectionName: string; AComboBox: TComboBox );
  procedure GetComboBox ( ASectionName: string; AComboBox: TComboBox );
  procedure PutCLB      ( ASectionName, ACLBName: string; ACLBDescr: array of TN_CLBItem );
  procedure GetCLB      ( ASectionName, ACLBName: string; var ACLBDescr: array of TN_CLBItem );
  procedure PutSPLVal   ( ASectionName, AValName: string; const AValue; ASPLSType: integer );
  procedure GetSPLVal   ( ASectionName, AValName: string; var AValue; ASPLSType: integer );
end; // type TN_MemIniObj = class( TObject )


function  N_GetGlobName ( AName: string ): string;
procedure N_EnumDescrToMemIni ( ASectionName: string; AEnumDescr: TN_ENumElems );
procedure N_MemIniToEnumDescr ( ASectionName: string; var AEnumDescr: TN_ENumElems );
procedure N_EnumDescrToComboBox ( AComboBox: TComboBox; AEnumDescr: TN_ENumElems );
function  N_GetItemIndex      ( AEnumInd: integer; AEnumDescr: TN_ENumElems ): integer;
function  N_GetENumDescrIndex ( AItemInd: integer; AEnumDescr: TN_ENumElems ): integer;

function  N_GetScreenPixelFormat    ( AForm: TForm ): TPixelFormat;
//##*/
procedure N_GetBitmapPixValues      ( ABitmap: TBitMap; var APixValues: TN_BArray );
function  N_CreateBitmapByPixValues ( ABegPtr: Pointer; AWidth,
                       AHeight: integer; APixelFormat: TPixelFormat ): TBitmap;

procedure N_AddList           ( ADstList, ASrcList: TList );
function  N_CreateFilesList   ( APattern: string ): TObjectList;
procedure N_DeleteFilesList   ( AFAObjList: TObjectList );
procedure N_DeleteFiles       ( APattern: string; ADelFlags: integer );
procedure N_AddFilesAttribs   ( APattern: string; ASFlags: integer;
                                              var AFAObjList: TObjectList );
procedure N_ClearReadOnlyAttr ( APattern: string; AFlags: integer );

procedure N_FillArray ( var AnArray: TN_BArray; ABegValue, AStep: integer;
                            ANumVals: integer; AFirstInd: integer = 0 ); overload;
procedure N_FillArray ( var AnArray: TN_IArray; ABegValue, AStep: integer;
                            ANumVals: integer; AFirstInd: integer = 0 ); overload;
procedure N_FillArray ( var AnArray: TN_FArray; ABegValue, AStep: float;
                            ANumVals: integer; AFirstInd: integer = 0 ); overload;
procedure N_FillArray ( var AnArray: TN_DArray; ABegValue, AStep: double;
                            ANumVals: integer; AFirstInd: integer = 0 ); overload;
procedure N_FillArray ( var AnArray: TN_SArray; APrefix: string;
            ABegValue, AStep, ANumVals: integer; AFirstInd: integer = 0 ); overload;

procedure N_DeleteArrayElems ( var AnArray: TN_BArray; ABegInd, ANumInds: integer ); overload;
procedure N_DeleteArrayElems ( var AnArray: TN_IArray; ABegInd, ANumInds: integer ); overload;
procedure N_DeleteArrayElems ( var AnArray: TN_FArray; ABegInd, ANumInds: integer ); overload;
procedure N_DeleteArrayElems ( var AnArray: TN_DArray; ABegInd, ANumInds: integer ); overload;

//procedure N_InsertArrayElems( var DstArray: TN_IArray; DstBegInd: integer;
//                  SrcArray: TN_IArray; SrcBegInd, ANumInds: integer ); overload;
//procedure N_InsertArrayElems ( var DstArray: TN_DArray; DstBegInd: integer;
//                  SrcArray: TN_DArray; SrcBegInd, ANumInds: integer ); overload;

procedure N_AddPackedInt ( var AMemPtr: TN_BytesPtr; AInt: integer; APLength: integer = 0 );
function  N_GetPackedInt ( var AMemPtr: TN_BytesPtr ): integer;
procedure N_AssignFile ( var AFH: File; AFileName: string;
                                                AMode: integer = -1 ); overload;
procedure N_AssignFile ( var AFH: TextFile; AFileName: string;
                                                AMode: integer = -1 ); overload;
procedure N_ROpenFile  ( var AFH: TextFile; AFileName: string ); overload;
procedure N_ROpenFile  ( var AFH: File; AFileName: string ); overload;

procedure N_ShowTextFragment ( AFileName, AFragmName: string;
                        AWidth, AHeight: integer; ABaseControl: TControl );
//##/*
function  N_CreateMenuItem ( AGSInd: integer; AShortCutKey: integer = -1): TMenuItem;
procedure N_SetMenuItems   ( AMenu: TMenu; ItemsFlags: array of integer );
//function  N_AddMenuItem  ( AMenu: TMenu; ACaption: string; AOnClick: TNotifyEvent ): integer;
procedure N_DeleteMenuItems ( AMenu: TMenu );

function  N_GetDebColor       ( AnyInt: integer; Mode: integer = 0 ): integer;
//##*/
procedure N_AddUniqStrToTop   ( AList: TStrings; AStr: string; AMaxListSize: integer = 0 );
procedure N_AddTextToTop      ( AComboBox: TObject; AMaxListSize: integer = 0 );
procedure N_mbKeyDownHandler1 ( ASender: TObject; AKey: Word;
                                AShift: TShiftState; AMaxListSize: integer = 0 );

procedure N_AddOrderedInts ( var AOutSInts: TN_IArray; var ANumOutSInts: integer;
                             APInpSInts: PInteger; ANumInpSInts, AMode: integer );
procedure N_SetFormPos ( AForm: TForm; APos: TRect );
function  N_UTF8       ( AStr: string ): string;
function  N_ReplaceStringTail ( ASrcName, ANewLC: string; ANumLC: integer ): string;
procedure N_ORToIArray ( var AIArray: TN_IArray; AInt: integer );
function  N_SearchInIArray ( AInt: integer; AIArray: TN_IArray;
                             ABegInd: integer = 0; AEndInd: integer = -1 ): integer;
function  N_SearchInteger  ( AInt: integer; APFirstInt: PInteger;
                                           ABegInd, AEndInd: integer ): integer;
procedure N_PushInt    ( var AIArray: TN_IArray; AInt: integer );
function  N_PopInt     ( var AIArray: TN_IArray ): integer;

//##/*
function  N_GES ( ErrorNumber: integer ): string;
//##*/
function  N_EditIniFileSection ( ASectionName: string ): integer;
procedure N_SetCursorType ( AFlags: integer );
procedure N_SetMBItems ( AComboBox: TComboBox; AStrings: array of string;
                                    AInpInd: integer; AMaxWidth: integer = -1 );
//##/*
procedure N_TStart ();
procedure N_TStop  ( ATimerName: string );
//##*/
procedure N_GetNormValues ( var ANormValues: TN_DArray; ASumValue: double;
                                    APSrcValue: PDouble; ANumValues: integer );
//##/*
function  N_GetMSPrecision ( ASizeUnit: TN_MSizeUnit ): integer;
function  N_MakeFullFName2 ( AFolder, AFile: string ): string;
//##*/

function  N_NewLength  ( AOldLength: integer; AMinLength: integer = 0 ): integer;
function  N_GetScreenRectOfControl ( AControl: TControl ): TRect;
function  N_GetClientRectOfControl ( AControl: TControl ): TRect;
procedure N_SetClientRectOfControl ( AControl: TControl; ARect: TRect );
procedure N_PlaceTControl   ( AControl, AFixedControl: TControl ); overload;
procedure N_PlaceTControl   ( AControl: TControl; AMode, AWidth, AHeight: integer ); overload;
procedure N_ChangeFormSize  ( AForm: TForm; ADX, ADY: integer );
procedure N_MakeFormVisible ( AForm: TForm; AFlags: TN_FormVisFlags );
procedure N_MakeFormVisible2( AForm: TForm; AFlags: TN_RectSizePosFlags );
procedure N_SetMouseCursorType ( AControl: TControl; ACursor: TCursor );
//procedure N_InitWorkAreaRect   ();
procedure N_InitWAR            ();
procedure N_AddToDumpDlg       ();

function  N_GetMonWARsAsString (): string;
function  N_GetMonWARByRect    ( ARect: TREct; APMonitorIndex: PInteger = nil ): TRect;
function  N_MonWARsChanged     (): Boolean;
procedure N_ClearSavedFormCoords ();

type TN_DumpGlobObj2 = class( TObject ) // Global Object2 for Dumping functions
  procedure GODump1Str  ( AString: string );
  procedure GODump2Str  ( AString: string );
  procedure GODump2TStr ( AType: integer; AString: string );
  procedure GODumpStr   ( ALCInd: integer; AString: string );
end; // type TN_DumpGlobObj2 = class( TObject )



//##/*
//##*/

var
  N_SaveAllToMemIni: TN_ActListObj;
  N_CurArchChanged: TN_ActListObj;

  N_GlobIni: TN_MemIniObj;   // Memory copy of Global Ini file
  N_UserIni: TN_MemIniObj;   // Memory copy of User Ini file


implementation
uses Math, SysUtils, StrUtils, Dialogs, Clipbrd,
     K_Script1, K_Arch, K_CLib0,
     N_Lib0, N_InfoF, N_PlainEdF, N_RichEdF, N_Gra0, N_Gra1, N_MemoF, //
     N_DBF, N_GS1; //

     
//********** TN_BaseActionObj class methods  **************

//*********************************************** TN_BaseActionObj.Create ***
//
constructor TN_BaseActionObj.Create();
begin
  Enabled := True;
end; // constructor TN_BaseActionObj.Create

//********************************************** TN_BaseActionObj.Destroy ***
//
destructor TN_BaseActionObj.Destroy();
begin
  inherited;
end; // destructor TN_BaseActionObj.Destroy

//********************************************** TN_BaseActionObj.ActToStr ***
// Convert Self filds to string (for debug)
//
function TN_BaseActionObj.ActToStr(): string;
begin
  Result := Format( 'Action: %s, e:%d, LC=%d, A=$%.8X ',
        [ActName, integer(Enabled), ListsCounter, integer(Self)] );
end; // function TN_BaseActionObj.ActToStr

//********** TN_ClearVarActObj class methods  **************

//********************************************** TN_ClearVarActObj.Create ***
//
constructor TN_ClearVarActObj.Create( APVar: Pointer );
begin
  inherited Create();
  ActName := ActName + 'ClearVar';
  PVarToClear := APVar;
end; // constructor TN_ClearVarActObj.Create

//****************************************** TN_ClearVarActObj.ExecAction ***
// Clear Pointer to some Form
//
procedure TN_ClearVarActObj.ExecAction();
begin
  if Enabled then
    PPointer(PVarToClear)^ := nil;
end; // end_of procedure TN_ClearVarActObj.ExecAction


//********** TN_CloseFormActObj class methods  **************

//******************************************** TN_CloseFormActObj.Create ***
//
constructor TN_CloseFormActObj.Create(  AFormToClose: TForm  );
begin
  inherited Create();
  ActName := ActName + 'CloseForm' + AFormToClose.Name;
  FormToClose := AFormToClose;
end; // constructor TN_CloseFormActObj.Create

//*************************************** TN_CloseFormActObj.ExecAction ***
// Close Form pointed to by POwner
//
procedure TN_CloseFormActObj.ExecAction();
begin
  if Enabled then FormToClose.Close;
  Enabled := False;
end; // end_of procedure TN_CloseFormActObj.ExecAction


//********** TN_ProcOfObjActObj class methods  **************

//******************************************** TN_ProcOfObjActObj.Create ***
//
constructor TN_ProcOfObjActObj.Create( AProcObj: TN_ProcObj );
begin
  inherited Create();
  ActName := ActName + 'ProcObj';
  ProcObjToCall := AProcObj;
end; // constructor TN_ProcOfObjActObj.Create

//*************************************** TN_ProcOfObjActObj.ExecAction ***
// Execute procedure of object ProcObj
//
procedure TN_ProcOfObjActObj.ExecAction();
begin
  if Enabled then ProcObjToCall();
end; // end_of procedure TN_ProcOfObjActObj.ExecAction


//********** TN_ActListObj class methods  **************

//******************************************** TN_ActListObj.Create ***
//
constructor TN_ActListObj.Create();
begin
  inherited Create();
end; // constructor TN_ActListObj.Create

//*************************************************** TN_ActListObj.Destroy ***
// Decrease ListsCounter by 1 for all Actions in Self and
// destroy Actions with ListsCounter = 0
//
destructor TN_ActListObj.Destroy();
var
  i, MaxI: integer;
begin
  MaxI := Count-1;

  for i := MaxI downto 0 do
  with TN_BaseActionObj(Items[i]) do
  begin
    Dec( ListsCounter, 1 );
    if ListsCounter = 0 then
    begin
      Free();
//      Delete( i ); // not needed?
    end;
  end; // with, for i := MaxI downto 0 do

  inherited;
end; // destructor TN_ActListObj.Destroy

//***************************************** function TN_ActListObj.ALOToStr ***
// Collect info about all Self Elements to resulting String (for Debug)
//
function TN_ActListObj.ALOToStr(): string;
var
  i, MaxI: integer;
begin
  MaxI := Count-1;
  Result := '';

  for i := 0 to MaxI do
  with TN_BaseActionObj(Items[i]) do
  begin
    Result := Result + ActToStr() + ''#$0D#$0A;
  end;
end; // end_of procedure function TN_ActListObj.ALOToStr

//*************************************** TN_ActListObj.ExecActions ***
// Execute all Self actions
//
procedure TN_ActListObj.ExecActions();
var
  i, MaxI: integer;
begin
  MaxI := Count-1;

  for i := 0 to MaxI do
  with TN_BaseActionObj(Items[i]) do
  begin
//    N_PCAdd( 7, 'ExecActions:' + ActToStr() ); // debug
    N_s := ActName; // to see ActionName in debugger
    N_b := Enabled;
    if Enabled then ExecAction();
  end;
end; // end_of procedure TN_ActListObj.ExecActions

//*************************************** TN_ActListObj.AddGivenAction ***
// Add to Self any Given Action
//
procedure TN_ActListObj.AddGivenAction( AnActionObj: TN_BaseActionObj );
begin
  Add( AnActionObj );
  Inc( AnActionObj.ListsCounter );
end; // end_of procedure TN_ActListObj.AddGivenAction

//*************************************** TN_ActListObj.AddNewAction ***
// Create, add to Self and return Action of given type
//
function TN_ActListObj.AddNewAction( ActObjType: TN_BaseActionObjType ): TN_BaseActionObj;
begin
  Result := ActObjType.Create();
  AddGivenAction( Result );
end; // end_of procedure TN_ActListObj.AddNewAction

//*************************************** TN_ActListObj.AddNewClearVarAction ***
// Create, add to Self and return TN_ClearPVarActObj Action
//
function TN_ActListObj.AddNewClearVarAction( APVar: Pointer ): TN_ClearVarActObj;
begin
  Result := TN_ClearVarActObj.Create( APVar );
  AddGivenAction( Result );
end; // end_of procedure TN_ActListObj.AddNewClearVarAction

//*************************************** TN_ActListObj.AddNewCloseFormAction ***
// Create, add to Self and return TN_CloseFormActObj Action
//
function TN_ActListObj.AddNewCloseFormAction( AForm: TForm ): TN_CloseFormActObj;
begin
  Result := TN_CloseFormActObj.Create( AForm );
  AddGivenAction( Result );
end; // end_of procedure TN_ActListObj.AddNewCloseFormAction

//*************************************** TN_ActListObj.AddNewProcOfObjAction ***
// Create, add to Self and return TN_ProcOfObjActObj Action
//
function TN_ActListObj.AddNewProcOfObjAction( AProcObj: TN_ProcObj ): TN_ProcOfObjActObj;
begin
  Result := TN_ProcOfObjActObj.Create( AProcObj );
  AddGivenAction( Result );
end; // end_of procedure TN_ActListObj.AddNewProcOfObjAction

//****************** One Global procedure **********************

//************************************************ N_ExecAndDestroy ***
// Execute Actions, Destroy Actions, destroy given AnActionList
// (used in FormClose handler)
//
procedure N_ExecAndDestroy( var AnActionList: TN_ActListObj );
begin
  if AnActionList = nil then Exit;
  AnActionList.ExecActions();
  FreeAndNil( AnActionList );
end; //*** end of procedure N_ExecAndDestroy

//********** TN_UniqueId class methods  **************

//******************************************** TN_UniqueId.Create ***
//
constructor TN_UniqueId.Create();
begin
  inherited Create();
  Sorted := True;
end; // constructor TN_UniqueId.Create

//*************************************** TN_UniqueId.GetAnyId ***
// Create and return any Identifier with given Length
//
function TN_UniqueId.GetAnyId( MinLeng, MaxLeng: integer ): string;
var
  i, n, IdLeng: integer;
begin
  IdLeng := RandomRange( MinLeng, MaxLeng );
  SetLength( Result, IdLeng );

  for i := 1 to IdLeng do
  begin
    if i = 1 then // first character, should not be a digit
    begin
      n := random( 26 );
      Result[1] := Char( integer('A') + n );
    end else // any alpha-numeric character is OK
    begin
      n := random( 36 );
      if n <= 9 then
        Result[i] := Char( integer('0') + n )
      else
        Result[i] := Char( integer('A') + n - 10 );
    end;
  end; // for i := 1 to IdLeng do
end; // end_of function TN_UniqueId.GetAnyId

//*************************************** TN_UniqueId.GetUniqueId ***
// Create and return Unique Identifier with given prefix and given Length (after Prefix)
//
function TN_UniqueId.GetUniqueId( Prefix: string; MinLeng, MaxLeng: integer ): string;
var
  Ind: integer;
begin
  while True do
  begin
    Result := Prefix + GetAnyId( MinLeng, MaxLeng );

    if not Find( Result, Ind ) then // Result is OK
    begin
      Insert( Ind, Result );
      Break;
    end;

  end; // while True do
end; // end_of function TN_UniqueId.GetUniqueId


//****************** Global procedures **********************

//************************************************ N_FillCheckListBox ***
// Fill given CheckListBox ACLB by given ACLBDescr
//
procedure N_FillCheckListBox( const ACLBDescr: array of TN_CLBItem; ACLB: TCheckListBox );
var i: integer;
begin
  ACLB.Items.Clear();

  for i := 0 to High(ACLBDescr) do
  with ACLBDescr[i] do
  begin
    ACLB.Items.Add( CLBText );
    ACLB.Checked[i] := CLBValue;
    ACLB.Header[i] := CLBType = clbHeader;
  end; // for i := 0 to High(ACLBDescr) do
end; //*** end of procedure N_FillCheckListBox

//************************************************ N_FillCheckListBox ***
// Fill given ACLBDescr values by given CheckListBox ACLB
//
procedure N_FillCLBDesrValues( var ACLBDescr: array of TN_CLBItem; ACLB: TCheckListBox );
var i: integer;
begin
  for i := 0 to High(ACLBDescr) do
    ACLBDescr[i].CLBValue := ACLB.Checked[i];
end; //*** end of procedure N_FillCLBDesrValues

//***************************************************** N_GetCLBValue ***
// Get CLBDescr Value by given Id
//
function N_GetCLBValue( const ACLBDescr: array of TN_CLBItem; AnId: string ): Boolean;
var
  i: integer;
begin
  Result := False;
  for i := 0 to High(ACLBDescr) do
  with ACLBDescr[i] do
  begin
    if CLBId = AnId then
    begin
      Result := CLBValue;
      Exit;
    end;
  end;
end; // function N_GetCLBValue

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_CopyList
//************************************************************** N_CopyList ***
// Copy all items from given sourse to destination Objects List
//
//     Parameters
// ADstList - destination list
// ASrcList - source list
//
procedure N_CopyList( ADstList, ASrcList: TList );
var i: integer;
begin
  ADstList.Count := ASrcList.Count;
  for i := 0 to ASrcList.Count-1 do
    ADstList.Items[i] := ASrcList.Items[i];
end; //*** end of procedure N_CopyList

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_FindPtrByType
//********************************************************* N_FindPtrByType ***
// Find index of Object in given List by given Class Type
//
//     Parameters
// AList        - given Objects List
// ANeededClass - given Class Type
// Result       - Returns index of found Object or -1 if no proper Object is 
//                found.
//
function N_FindPtrByType( AList: Tlist; ANeededClass: TClass  ): integer;
var
  i: integer;
begin
  for i := 0 to AList.Count-1 do
    if TObject(AList.Items[i]) is ANeededClass then
    begin
      Result := i;
      Exit;
    end;
  Result := -1; // not found
end; //*** end of function N_FindPtrByType

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ConvCellToCSV
//********************************************************* N_ConvCellToCSV ***
// Convert given string to CSV format
//
//     Parameters
// AStr   - source string
// ADelim - tokens delimiter
// Result - Returns source string AStr converted to CSV format and followed by 
//          delimiter ADelim.
//
// Source string is quoteed by '"' it contains ';', '"' or $0A characters.
//
function N_ConvCellToCSV( const AStr: string; ADelim: Char ): string;
var
  i, SLeng: integer;
  CurChar: Char;
begin
  SLeng := Length(AStr);

  for i := 1 to SLeng do
  begin
    CurChar := AStr[i];
    if (CurChar = ';') or (CurChar = '"') or (Ord(CurChar) = $0A) then
    begin
      Result := N_QuoteStr( AStr, '"' ) + ADelim;
      Exit;
    end;
  end; // for i := 1 to SLeng do

  Result := AStr + ADelim;
end; // end of function N_ConvCellToCSV

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ConvTextToHex
//********************************************************* N_ConvTextToHex ***
// Convert given string to HEX View (16 bytes in row)
//
//     Parameters
// ASrcStr        - source string
// AHexStrings    - StringsList for resulting HEX View strings
// ASrcStrMaxSize - ASrcStr maximal size
//
procedure N_ConvTextToHex( const ASrcStr: string; AHexStrings: TStrings;
                                                     ASrcStrMaxSize: integer );
var
  i, j, IMax, k, kMax, KBeg, m, n, Adr: integer;
  CurChar: Char;
  Row, Str: string;
begin
  IMax := (ASrcStrMaxSize + 15) div 16;
  kMax := Length(AsrcStr);
  k := 1;
  Adr := 0;

  for i := 0 to IMax do // along HEX View Rows
  begin
    Row := IntTohex( Adr, 8 ) + ' ';
    KBeg := k;

    for j := 0 to 15 do // along current Hex View Row
    begin
      if k > KMax then Break; // end of whole Text
      Row := Row + IntToHex( Ord(ASrcStr[k]), 2 ) + ' ';
      if ((j mod 4) = 3) and (j <> 15) then Row := Row + '| ';
      Inc(k);
    end; // for j := 0 to 15 do // along current Hex View Row

    if Length(Row) < 64 then // fill rest of Row by Spaces
    begin
      Str := DupeString( ' ', 64 - Length(Row) );
      Row := Row + Str;
    end;

    m := 1;
    SetLength( Str, k-KBeg ); // for last Row k-KBeg <> 16 !

    for n := KBeg to k-1 do // replace $0D  by $B6 (paragraph sign)
    begin                   // and $09(Tab) by $B0 (degree sign)
      CurChar := ASrcStr[n];
      if Ord(CurChar) = $0D then      Str[m] := Char( $B6 )
      else if Ord(CurChar) = $09 then Str[m] := Char( $B0 )
                                 else Str[m] := CurChar;
      Inc(m);
    end; // for n := KBeg to k-1 do // replace $0D by $B0 (degree sign)

    //***** set same delimiters as in Hex part of Row
    if Length(Str) > 13 then Insert( '|', Str, 13 );
    if Length(Str) >  9 then Insert( '|', Str, 9 );
    if Length(Str) >  5 then Insert( '|', Str, 5 );

    Row := Row + ' ' + Str;
    AHexStrings.Add( Row );
    Inc( Adr, 16 );

    if k > KMax then Break; // end of whole Text
  end; // for i := 0 to IMax do

end; // end of procedure N_ConvTextToHex

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ConvMemToHex
//********************************************************** N_ConvMemToHex ***
// Convert given Bytes to HEX View strings (16 bytes in row)
//
//     Parameters
// AMemPtr     - Pointer to Bytes to convert
// ANumBytes   - Number of Bytes to convert
// AStartAdr   - Addres of first Byte (beg of first HEX View string)
// AResStrings - given Strings obj to which resulting HEX View strings will be 
//               added
//
procedure N_ConvMemToHex( AMemPtr: Pointer; ANumBytes: integer; AStartAdr: DWORD;
                          AResStrings: TStrings );
var
  i, j, IMax, k, KBeg, m, n: integer;
  CurAdr: DWORD;
  CurByte: TN_Byte;
  Row, Str: string;
  BytePtr: TN_BytesPtr;
begin
  if ANumBytes <= 0 then Exit; // a precaution
  IMax := (ANumBytes + 15) div 16;
  k := 0;
  CurAdr := AStartAdr;
  BytePtr := TN_BytesPtr(AMemPtr);

  for i := 0 to IMax do // along HEX View Rows
  begin
    Row := IntTohex( CurAdr, 8 ) + ' ';
    KBeg := k;

    for j := 0 to 15 do // along current Hex View Row
    begin
      if k >= ANumBytes then Break; // end of Bytes
      Row := Row + IntToHex( Ord((BytePtr+k)^), 2 ) + ' ';
      if ((j mod 4) = 3) and (j <> 15) then Row := Row + '| ';
      Inc(k);
    end; // for j := 0 to 15 do // along current Hex View Row

    if Length(Row) < 64 then // fill rest of Row by Spaces
    begin
      Str := DupeString( ' ', 64 - Length(Row) );
      Row := Row + Str;
    end;

    m := 1;
    SetLength( Str, k-KBeg ); // for last Row k-KBeg <> 16 !

    for n := KBeg to k-1 do // replace $0D  by $B6 (paragraph sign)
    begin                   //     $09(Tab) by $B0 (degree sign)
                            //         $00  by 'Z'
      CurByte := (BytePtr+n)^;
      if Ord(CurByte) = $0D then      Str[m] := Char( $B6 )
      else if Ord(CurByte) = $09 then Str[m] := Char( $B0 )
      else if Ord(CurByte) = $00 then Str[m] := 'Z'
                                 else Str[m] := Char(CurByte);
      Inc(m);
    end; // for n := KBeg to k-1 do // replace $0D by $B0 (degree sign)

    //***** set same delimiters as in Hex part of Row
    if Length(Str) > 13 then Insert( '|', Str, 13 );
    if Length(Str) >  9 then Insert( '|', Str, 9 );
    if Length(Str) >  5 then Insert( '|', Str, 5 );

    Row := Row + ' ' + Str;
    AResStrings.Add( Row );
    Inc( CurAdr, 16 );

    if k >= ANumBytes then Break; // end of Bytes
  end; // for i := 0 to IMax do

end; // end of procedure N_ConvMemToHex

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_TimeDeltaInSeconds
//**************************************************** N_TimeDeltaInSeconds ***
// Get time interval size in seconds
//
//     Parameters
// ASavedTime - start time stamp
// Result     - Returns time interval size in seconds between given time stamp 
//              ASavedTime and current Time.
//
function N_TimeDeltaInSeconds( ASavedTime: double ): double;
begin
  Result := ( Time() - ASavedTime )*N_SecondsInDay;
end; // end of function N_TimeDeltaInSeconds

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_DelayInSeconds
//******************************************************** N_DelayInSeconds ***
// Wait given time interval for some event
//
//     Parameters
// ASeconds - whole time interval in seconds
// ADelta   - time interval for Ctrl key press event
//
// Wait for some event and return:
//#F
// - given number of Seconds passed
// - Ctrl key is down for ADelta seconds (default value = 1000 seconds)
// - Shift key is down
// - Escape key is down
// - Ctrl key was clicked (pressed and released)
//#/F
//
procedure N_DelayInSeconds( ASeconds: double; const ADelta: double = 1000.0 );
var
  T1, T2 : TDateTime;
  CtrlDown: boolean;
begin
  T1 := Time();
  T2 := T1; // to avoid warning
  CtrlDown := False;
  while True do
  begin
    if (GetAsyncKeyState( VK_ESCAPE ) and $8000) = $8000 then Break;
    if (GetAsyncKeyState( VK_CONTROL ) and $8000) = $8000 then
      if not CtrlDown then
      begin
        CtrlDown := True;
        T2 := Time();
      end else // CtrlDown is True
//        if (Time() - T2)*N_SecondsInDay > Delta then Break;
        if N_TimeDeltaInSeconds(T2) > ADelta then Break;

    if ((GetAsyncKeyState( VK_CONTROL ) and $8000)=0) and CtrlDown then Break;
    if (GetAsyncKeyState( VK_SHIFT ) and $8000) = $8000 then Break;
    if N_TimeDeltaInSeconds(T1) > ASeconds then Break;
  end;
end; // end of procedure N_DelayInSeconds

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_32ToR32BitColor
//******************************************************* N_32ToR32BitColor ***
// Swap Red and Blue bytes in given 32 bit True Color value
//
//     Parameters
// ATrueColor - source True Color
// Result     - Returns True Color with swaped Red and Blue bytes.
//
function N_32ToR32BitColor( ATrueColor: integer ): integer;
var
  Red, Blue: integer;
begin
  Red  := TN_UInt1(ATrueColor) shl 16;
  Blue := (ATrueColor shr 16) and $FF; // and $FF is a precaution
  Result := (ATrueColor and $00FF00) or Red or Blue;
end; // end of function N_32ToR32BitColor

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_32To16BitColor
//******************************************************** N_32To16BitColor ***
// Convert given True Color value to 16 bit High Color value
//
//     Parameters
// ATrueColor - source True Color
// Result     - Returns resulting 16 bit High Color.
//
function N_32To16BitColor( ATrueColor: integer ): integer;
var
  r, g, b: integer;
begin
  r := Byte(ATrueColor);
  if r > $04 then r := (r - $04) shr 3
             else r := 0;

  g := ATrueColor and $00FF00;
  if g > $0200 then g := ((g - $0200) and $FC00) shr 5
               else g := 0;

  b := ATrueColor and $FF0000;
  if b > $040000 then b := ((b - $040000) and $F80000) shr 8
                 else b := 0;

  Result := b or g or r; // 16 bit High Color value
end; // end of function N_32To16BitColor

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_16To32BitColor
//******************************************************** N_16To32BitColor ***
// Convert given 16 bit High Color value to 32 bit True Color value
//
//     Parameters
// AHighColor - source 16 bit High Color
// Result     - Returns resulting 32 bit True Color.
//
function N_16To32BitColor( AHighColor: integer ): integer;
var
  r, g, b: integer;
begin
  r := (AHighColor shl 3) and $F8;
  if r > $07 then Inc( r, $08 );
  if r > $FF then r := $FF;

  g := (AHighColor shl 5) and $FC00;
  if g > $0300 then Inc( g, $0400 );
  if g > $FF00 then g := $FF00;

  b := (AHighColor shl 8) and $F80000;
  if b > $070000 then Inc( b, $080000 );
  if b > $FF0000 then b := $FF0000;

  Result := b or g or r; // 32 bit True Color value
end; // end of function N_16To32BitColor

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_32ToR16BitColor
//******************************************************* N_32ToR16BitColor ***
// Convert given True Color value to reverse 16 bit High Color value
//
//     Parameters
// ATrueColor - source True Color
// Result     - Returns resulting reversed 16 bit High Color.
//
function N_32ToR16BitColor( ATrueColor: integer ): integer;
var
  r, g, b: integer;
begin
  r := Byte(ATrueColor);
  if r > $04 then r := ((r - $04) and $F8) shl 8
             else r := 0;

  g := ATrueColor and $00FF00;
  if g > $0200 then g := ((g - $0200) and $FC00) shr 5
               else g := 0;

  if ATrueColor > $040000 then b := (ATrueColor - $040000) shr 19
                         else b := 0;

  Result := r or g or b; // Reversed 16 bit High Color value
end; // end of function N_32ToR16BitColor

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_16ToR32BitColor
//******************************************************* N_16ToR32BitColor ***
// Convert given 16 bit High Color value to reverse 32 bit True Color value
//
//     Parameters
// AHighColor - source 16 bit High Color
// Result     - Returns resulting reversed 32 bit True Color.
//
function N_16ToR32BitColor( AHighColor: integer ): integer;
var
  r, g, b: integer;
begin
  r := (AHighColor shl 19) and $F80000;
  if r > $070000 then Inc( r, $080000 );
  if r > $FF0000 then r := $FF0000;

  g := (AHighColor shl 5) and $FC00;
  if g > $0300 then Inc( g, $0400 );
  if g > $FF00 then g := $FF00;

  b := (AHighColor shr 8) and $F8;
  if b > $07 then Inc( b, $08 );
  if b > $FF then b := $FF;

  Result := r or g or b; // Reversed 32 bit True Color value
end; // end of function N_16ToR32BitColor

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_16ToR16BitColor
//******************************************************* N_16ToR16BitColor ***
// Convert given 16 bit High Color value to reverse 16 bit High Color value
//
//     Parameters
// AHighColor - source 16 bit High Color
// Result     - Returns resulting reversed 16 bit High Color.
//
function N_16ToR16BitColor( AHighColor: integer ): integer;
var
  r, b: integer;
begin
  r := (AHighColor and $1F);          // 5 bit value
  b := ((AHighColor shr 11) and $1F); // 5 bit value
  Result := (r shl 11) or (AHighColor and $7E0) or b; // Reversed 16 bit
end; // end of function N_16ToR16BitColor

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_RoundTo16bitColor
//***************************************************** N_RoundTo16bitColor ***
// Round given True Color to 16 bit to High Color
//
//     Parameters
// ATrueColor - source True Color
// Result     - Returns resulting True Color rounded 16 bit High Color.
//
// Ñonvert given True Color value to True Color value, rounded to Colors, that 
// can be exactly represented in High Color (16 bit) mode.
//
function N_RoundTo16bitColor( ATrueColor: integer ): integer;
begin
  //**** later change by explicit algoritm
  Result := N_16To32BitColor( N_32To16BitColor( ATrueColor ) );
end; // end of function N_RoundTo16bitColor


//******* some obsolete code about sorting (newer functions are in N_Lib0) :

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_CompareIntegers
//******************************************************* N_CompareIntegers ***
// Compare two records corresponding Integer fields
//
//     Parameters
// AIParam - offset in bytes of Integer field in compared records
// APtr1   - pointer to first compared record
// APtr2   - pointer to second compared record
// Result  - Returns:
//#F
// -1 - if Integer1 < Integer2
//  0 - if Integer1 = Integer2
// +1 - if Integer1 > Integer2
//#/F
//
// Designed for use in N_SortPointers procedure.
//
function N_CompareIntegers( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  Integer1, Integer2: integer;
begin
  Integer1 := PInteger(APtr1+AIParam)^;
  Integer2 := PInteger(APtr2+AIParam)^;
  Result := 0; // as if Integer1 = Integer2

  if      Integer1 < Integer2 then  begin Result := -1; Exit; end
  else if Integer1 > Integer2 then  begin Result := +1; Exit; end

  //***** Here:  Double1 = Double2,  Result = 0
end; // end of function N_CompareIntegers

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_CompareDoubles
//******************************************************** N_CompareDoubles ***
// Compare two records corresponding Double fields
//
//     Parameters
// AIParam - offset in bytes of Double field in compared records
// APtr1   - pointer to first compared record
// APtr2   - pointer to second compared record
// Result  - Returns:
//#F
// -1 - if Double1 < Double2
//  0 - if Double1 = Double2
// +1 - if Double1 > Double2
//#/F
//
// Designed for use in N_SortPointers procedure.
//
function N_CompareDoubles( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  Double1, Double2: double;
begin
  Double1 := PDouble(APtr1+AIParam)^;
  Double2 := PDouble(APtr2+AIParam)^;
  Result := 0; // if Double1 = Double2

  if      Double1 < Double2 then  begin Result := -1; Exit; end
  else if Double1 > Double2 then  begin Result := +1; Exit; end

  //***** Here:  Double1 = Double2,  Result = 0
end; // end of function N_CompareDoubles

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_Compare3Ints
//********************************************************** N_Compare3Ints ***
// Compare two records with placed one after another three Integer fields
//
//     Parameters
// AIParam - offset in bytes of first Integer field in compared records
// APtr1   - pointer to first compared record
// APtr2   - pointer to second compared record
// Result  - Returns:
//#F
// -1 - if Field1 < Field2
//  0 - if Field1 = Field2
// +1 - if Field1 > Field2
//#/F
//
// Designed for use in N_SortPointers procedure.
//
function N_Compare3Ints( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  Int1, Int2: integer;
  P1, P2: TN_BytesPtr;
begin
  Result := 0; // as if field1 = field2
  P1 := APtr1+AIParam;
  P2 := APtr2+AIParam;

  Int1 := PInteger(P1)^;
  Int2 := PInteger(P2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end
  else if Int1 > Int2 then  begin Result := +1; Exit; end;

  //***** Here first Int in field1 = first Int in field2, check second Int

  Inc( P1, Sizeof(integer) );
  Inc( P2, Sizeof(integer) );

  Int1 := PInteger(P1)^;
  Int2 := PInteger(P2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end
  else if Int1 > Int2 then  begin Result := +1; Exit; end;

  //***** Here second Int in field1 = second Int in field2, check third Int

  Inc( P1, Sizeof(integer) );
  Inc( P2, Sizeof(integer) );

  Int1 := PInteger(P1)^;
  Int2 := PInteger(P2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end
  else if Int1 > Int2 then  begin Result := +1; Exit; end;

end; // end of function N_Compare3Ints

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_Compare4Ints
//********************************************************** N_Compare4Ints ***
// Compare two records with placed one after another four Integer fields
//
//     Parameters
// AIParam - offset in bytes of first Integer field in compared records
// APtr1   - pointer to first compared record
// APtr2   - pointer to second compared record
// Result  - Returns:
//#F
// -1 - if Field1 < Field2
//  0 - if Field1 = Field2
// +1 - if Field1 > Field2
//#/F
//
// Designed for use in N_SortPointers procedure.
//
function N_Compare4Ints( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  Int1, Int2: integer;
  P1, P2: TN_BytesPtr;
begin
  Result := 0; // as if field1 = field2
  P1 := APtr1+AIParam;
  P2 := APtr2+AIParam;

  Int1 := PInteger(P1)^;
  Int2 := PInteger(P2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end
  else if Int1 > Int2 then  begin Result := +1; Exit; end;

  //***** Here first Int in field1 = first Int in field2, check second Int

  Inc( P1, Sizeof(integer) );
  Inc( P2, Sizeof(integer) );

  Int1 := PInteger(P1)^;
  Int2 := PInteger(P2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end
  else if Int1 > Int2 then  begin Result := +1; Exit; end;

  //***** Here second Int in field1 = second Int in field2, check third Int

  Inc( P1, Sizeof(integer) );
  Inc( P2, Sizeof(integer) );

  Int1 := PInteger(P1)^;
  Int2 := PInteger(P2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end
  else if Int1 > Int2 then  begin Result := +1; Exit; end;

  //***** Here third Int in field1 = third Int in field2, check fourth Int

  Inc( P1, Sizeof(integer) );
  Inc( P2, Sizeof(integer) );

  Int1 := PInteger(P1)^;
  Int2 := PInteger(P2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end
  else if Int1 > Int2 then  begin Result := +1; Exit; end;

end; // end of function N_Compare4Ints

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_Compare3IntsAndFloat
//************************************************** N_Compare3IntsAndFloat ***
// Compare two records with placed one after another tree Integer and one Float 
// fields
//
//     Parameters
// AIParam - offset in bytes of first Integer field in compared records
// APtr1   - pointer to first compared record
// APtr2   - pointer to second compared record
// Result  - Returns:
//#F
// -1 - if Field1 < Field2
//  0 - if Field1 = Field2
// +1 - if Field1 > Field2
//#/F
//
// Designed for use in N_SortPointers procedure.
//
function N_Compare3IntsAndFloat( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  Int1, Int2: integer;
  Float1, Float2: float;
  P1, P2: TN_BytesPtr;
begin
  Result := 0; // as if field1 = field2
  P1 := APtr1+AIParam;
  P2 := APtr2+AIParam;

  Int1 := PInteger(P1)^;
  Int2 := PInteger(P2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end
  else if Int1 > Int2 then  begin Result := +1; Exit; end;

  //***** Here first Int in field1 = first Int in field2, check second Int

  Inc( P1, Sizeof(integer) );
  Inc( P2, Sizeof(integer) );

  Int1 := PInteger(P1)^;
  Int2 := PInteger(P2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end
  else if Int1 > Int2 then  begin Result := +1; Exit; end;

  //***** Here second Int in field1 = second Int in field2, check third Int

  Inc( P1, Sizeof(integer) );
  Inc( P2, Sizeof(integer) );

  Int1 := PInteger(P1)^;
  Int2 := PInteger(P2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end
  else if Int1 > Int2 then  begin Result := +1; Exit; end;

  //***** Here third Int in field1 = third Int in field2, check float

  Inc( P1, Sizeof(integer) );
  Inc( P2, Sizeof(integer) );

  Float1 := PFloat(P1)^;
  Float2 := PFloat(P2)^;

  if      Float1 < Float2 then  begin Result := -1; Exit; end
  else if Float1 > Float2 then  begin Result := +1; Exit; end;

end; // end of function N_Compare3IntsAndFloat

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_Compare3IntsAndDouble
//************************************************* N_Compare3IntsAndDouble ***
// Compare two records with placed one after another tree Integer and one Double
// fields
//
//     Parameters
// AIParam - offset in bytes of first Integer field in compared records
// APtr1   - pointer to first compared record
// APtr2   - pointer to second compared record
// Result  - Returns:
//#F
// -1 - if Field1 < Field2
//  0 - if Field1 = Field2
// +1 - if Field1 > Field2
//#/F
//
// Designed for use in N_SortPointers procedure.
//
function N_Compare3IntsAndDouble( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  Int1, Int2: integer;
  Double1, Double2: double;
  P1, P2: TN_BytesPtr;
begin
  Result := 0; // as if field1 = field2
  P1 := APtr1+AIParam;
  P2 := APtr2+AIParam;

  Int1 := PInteger(P1)^;
  Int2 := PInteger(P2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end
  else if Int1 > Int2 then  begin Result := +1; Exit; end;

  //***** Here first Int in field1 = first Int in field2, check second Int

  Inc( P1, Sizeof(integer) );
  Inc( P2, Sizeof(integer) );

  Int1 := PInteger(P1)^;
  Int2 := PInteger(P2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end
  else if Int1 > Int2 then  begin Result := +1; Exit; end;

  //***** Here second Int in field1 = second Int in field2, check third Int

  Inc( P1, Sizeof(integer) );
  Inc( P2, Sizeof(integer) );

  Int1 := PInteger(P1)^;
  Int2 := PInteger(P2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end
  else if Int1 > Int2 then  begin Result := +1; Exit; end;

  //***** Here third Int in field1 = third Int in field2, check float

  Inc( P1, Sizeof(integer) );
  Inc( P2, Sizeof(integer) );

  Double1 := PDouble(P1)^;
  Double2 := PDouble(P2)^;

  if      Double1 < Double2 then  begin Result := -1; Exit; end
  else if Double1 > Double2 then  begin Result := +1; Exit; end;

end; // end of function N_Compare3IntsAndDouble

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SortPointers(GlobFunc)
//************************************************ N_SortPointers(GlobFunc) ***
// Sort given array of pointers to compared data
//
//     Parameters
// APtrsArray    - array of pointers to compared data (on output array elements 
//                 will be reordered according to given ACompareFunc)
// ACompareParam - parameter of ACompareFunc (exept bit N_SortOrder):
//#F
//    bit N_SortOrder - =0 - increasing order, =1 - decreasing order
//#/F
// ACompareFunc  - function for comparing any two Elements:
//#F
//    function ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
//#/F
//
procedure N_SortPointers( APtrsArray: TN_PArray;
                          ACompareParam: integer; ACompareFunc: TN_CompareFunc ); overload;
var
  PA1, PA2, PAswap: array of TN_BytesPtr;
  IA1, IA2, IASwap: array of integer;
  i1, i2, j1, j2, k1, Endj1, Endk1, HighIA1, ElemCount, CompRes: integer;
  DecreasingOrder: boolean;
begin
  DecreasingOrder := False;
  PAswap := nil; // to avoid warnings
  IAswap := nil; // to avoid warnings
  if (ACompareParam and N_SortOrder) <> 0 then // sort in reverse order
  begin
    ACompareParam := ACompareParam xor N_SortOrder; // clear bit
    DecreasingOrder := True;
  end;

  ElemCount := Length( APtrsArray );
  if ElemCount <= 1 then Exit; // nothing to sort

  SetLength( PA1, ElemCount );
  SetLength( PA2, ElemCount );
  SetLength( IA1, ElemCount + 1 );
  SetLength( IA2, (ElemCount div 2) + 2 );

  for i1 := 0 to ElemCount-1 do // fill PA1 by pointers, IA1 by indexes
  begin
    PA1[i1] := TN_BytesPtr(APtrsArray[i1]);
    IA1[i1] := i1;
  end;
  IA1[ElemCount] := ElemCount; // just to calc last group size
  HighIA1 := ElemCount-1;

  while True do // main loop (decrease twice number of sorted groups)
  begin
{   // debug output
N_ADS( '  Left groups = ', HighIA1+1, ElemCount );
for i := 0 to HighIA1 do N_ADS( '  IA = ', i, IA1[i] );
for i := 0 to ElemCount-1 do
  N_ADS( Format( '    x = %4.5g', [TN_PDouble(PA1[i]+CompareParam)^+
        + 0.01*TN_PDouble(PA1[i]+CompareParam+8)^] ), i );
}
    if HighIA1 = 0 then // only one group in PA1,IA1 left,
    begin               // all pointers are sorted, copy them back to APtrsArray
      move( PA1[0], APtrsArray[0], ElemCount*Sizeof(Pointer) );
      PA1 := nil;
      PA2 := nil;
      IA1 := nil;
      IA2 := nil;
      Exit; // all done
    end;

    //***** merge PA1 group pairs into PA2

    i1 := 0; i2 := 0; // IA1 and IA2 indexes

    while i1 <= HighIA1 do // loop along all PA1,IA1 group pairs
    begin

      if i1 = HighIA1 then // last group without pair, just copy it to PA2
      begin
        IA2[i2]   := IA1[i1];
        IA2[i2+1] := IA1[i1+1];
        move( PA1[ IA1[i1] ], PA2[ IA2[i2] ], (IA1[i1+1]-IA1[i1])*Sizeof(Pointer) );
        Inc(i2);
        Break;
      end;

      //***** merge two (i1 and i1+1) groups

      j1 := IA1[i1];
      k1 := IA1[i1+1];
      IA2[i2] := j1; // beg of merged groups
      J2 := j1;
      Endj1 := IA1[i1+1]; // Endj1 = High(j1) + 1
      Endk1 := IA1[i1+2]; // Endk1 = High(k1) + 1

      while (j1 <= Endj1) and (k1 <= Endk1) do // loop along group elements
      begin

        if j1 = Endj1 then // no more elements in first (j) group
        begin              // just copy one element from second (k) group
          PA2[j2] := PA1[k1];
          Inc(j2); Inc(k1);
          if (k1 = Endk1) then Break; // second group was finished too
          Continue;
        end;

        if k1 = Endk1 then // no more elements in second (k) group
        begin              // just copy one element from first (j) group
          PA2[j2] := PA1[j1];
          Inc(j2); Inc(j1);
          if (j1 = Endj1) then Break; // first group was finished too
          Continue;
        end;

        //***** Here: both elements PA1[j1] and PA1[k1] exists
        //            ( j1 < Endj1 and k1 < Endk1 )

        CompRes := ACompareFunc( ACompareParam, PA1[j1], PA1[k1] );
        if ((not DecreasingOrder) and (CompRes < 0) ) or
               ( DecreasingOrder  and (CompRes > 0) )        then
        begin       // PA1[j1]^ < PA1[k1]^
          PA2[j2] := PA1[j1];
          Inc(j1);
        end  else   // PA1[j1]^ >= PA1[k1]^
        begin
          PA2[j2] := PA1[k1];
          Inc(k1);
        end;
        Inc(j2);
      end; // while (j1 < Endj1) and (k1 < Endk1) do // loop along group elements

      Inc( i1, 2 ); // two PA1,IA1 groups were processed
      Inc(i2);      // one new PA2,IA2 sorted group was created
    end; // while i <= HighIA1 do // loop along PA1 group pairs

    //***** Swap PA1, IA1 with PA2, IA2

    PAswap := PA1;
    PA1 := PA2;
    PA2 := PAswap;
    PASwap := nil;

    IAswap := IA1;
    IA1 := IA2;
    IA2 := IAswap;
    IASwap := nil;

    IA1[i2] := ElemCount;  // just to calc last group size
    HighIA1 := i2-1; // new number of groups in PA1,IA1 -1 (High Index)

  end; // while True do // main loop

end; // end of procedure N_SortPointers(GlobFunc)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_CreatePtrsArray
//******************************************************* N_CreatePtrsArray ***
// obsolete, N_GetPtrsArrayToElems should be used
//
// Create array of pointers to all elements of given array PElemArray (result 
// can be used in N_SortPointers procedure)
//
// PElemArray - Pointer to (beg of) first Element of array elements ElemCount  -
// Elements Count ( Length of array elements) ElemSize   - one Element size in 
// bytes (SizeOf  array element) PtrsArray  - resulting array of pointers 
// (PtrsArray[0] is @PElemArray[0], PtrsArray[1] is @PElemArray[ElemSize], ... )
//
procedure N_CreatePtrsArray( PElemArray: TN_BytesPtr; ElemCount, ElemSize: integer;
                             out PtrsArray: TN_PArray );
var
  i: integer;
begin
  SetLength( PtrsArray, ElemCount );

  for i := 0 to ElemCount-1 do // fill Ptrs array
    PtrsArray[i] := PElemArray + ElemSize*i;
end; // end of procedure N_CreatePtrsArray

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_GetSortedPointers
//***************************************************** N_GetSortedPointers ***
// Get array of sorted pointers to elements of given records array
//
//     Parameters
// APFirstElem   - pointer to first record of given records array
// AElemCount    - number of elements in given records array
// AElemSize     - one record size in bytes
// ACompareParam - parameter of ACompareFunc (except bit N_SortOrder):
//#F
//    bit N_SortOrder - =0 - increasing order, =1 - decreasing order
//#/F
// ACompareFunc  - function for comparing any two Elements:
//#F
//    function ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
//#/F
//
// Resulting Pointers are sorted by N_SortPointers procedure.
//
function N_GetSortedPointers( APFirstElem: Pointer; AElemCount, AElemSize: integer;
                ACompareParam: integer; ACompareFunc: TN_CompareFunc ): TN_PArray;
begin
//  N_CreatePtrsArray( TN_BytesPtr(PFirstElem), ElemCount, ElemSize, Result );
  Result := N_GetPtrsArrayToElems( APFirstElem, AElemCount, AElemSize );
  N_SortPointers( Result, ACompareParam, ACompareFunc );
end; // end of function N_GetSortedPointers

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_GetSortedIndexes
//****************************************************** N_GetSortedIndexes ***
// Get array of sorted indexes of elements of given records array
//
//     Parameters
// APFirstElem   - pointer to first record of given records array
// AElemCount    - number of elements in given records array
// AElemSize     - one record size in bytes
// ACompareParam - parameter of ACompareFunc (except bit N_SortOrder):
//#F
//    bit N_SortOrder - =0 - increasing order, =1 - decreasing order
//#/F
// ACompareFunc  - function for comparing any two Elements:
//#F
//    function ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
//#/F
//
// Resulting indexes are sorted by N_SortPointers procedure.
//
function N_GetSortedIndexes( APFirstElem: Pointer; AElemCount, AElemSize: integer;
                ACompareParam: integer; ACompareFunc: TN_CompareFunc ): TN_IArray;
var
  i: integer;
  PtrsArray: TN_PArray;
begin
//  N_CreatePtrsArray( TN_BytesPtr(PFirstElem), ElemCount, ElemSize, PtrsArray );
  PtrsArray := N_GetPtrsArrayToElems( APFirstElem, AElemCount, AElemSize );

  N_SortPointers( PtrsArray, ACompareParam, ACompareFunc );

  SetLength( Result, AElemCount );
  for i := 0 to AElemCount-1 do
    Result[i] := ( TN_BytesPtr(PtrsArray[i]) - TN_BytesPtr(APFirstElem) ) div AElemSize;
end; // end of function N_GetSortedIndexes

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SortElements
//********************************************************** N_SortElements ***
// Sort given array of records
//
//     Parameters
// APElemArray   - pointer to first record of given records array
// AElemCount    - number of elements in given records array
// AElemSize     - one record size in bytes
// ACompareParam - parameter of ACompareFunc (except bit N_SortOrder):
//#F
//    bit N_SortOrder - =0 - increasing order, =1 - decreasing order
//#/F
// ACompareFunc  - function for comparing any two Elements:
//#F
//    function ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
//#/F
//
// Resulting elments are sorted by N_SortPointers procedure.
//
procedure N_SortElements( APElemArray: TN_BytesPtr; AElemCount, AElemSize: integer;
                          ACompareParam: integer; ACompareFunc: TN_CompareFunc );
var
  Ptrs: TN_PArray;
  AllElements: TN_BArray;
  i, AllElementsSize: integer;
begin
  Ptrs := nil;
  if AElemCount <= 0 then Exit; // nothig to sort
{
  SetLength( Ptrs, ElemCount );

  for i := 0 to ElemCount-1 do // fill Ptrs array
    Ptrs[i] := PElemArray + ElemSize*i;
}
  Ptrs := N_GetPtrsArrayToElems( APElemArray, AElemCount, AElemSize );
  N_SortPointers( Ptrs, ACompareParam, ACompareFunc );

  AllElementsSize := AElemCount * AElemSize;
  SetLength( AllElements, AllElementsSize );
  for i := 0 to AElemCount-1 do // copy in needed order
    move( Ptrs[i]^, AllElements[i*AElemSize], AElemSize );

  move( AllElements[0], APElemArray^, AllElementsSize ); // copy back sorted elements
  Ptrs := nil;
  AllElements := nil;
end; // end of procedure N_SortElements

//*** end of  some obsolete code about sorting

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_BinSearch1
//************************************************************ N_BinSearch1 ***
// Dichotomic search for Index of Element with integer field equal to given 
// value in given ordered records array
//
//     Parameters
// APElemArray - pointer to Integer field of first record of given records array
// AElemCount  - number of elements in given records array
// AElemSize   - one record size in bytes
// AIValue     - given value to search to
// Result      - Returns records array element Index or -1
//#F
// Index - if AIValue = ElemArray[Index]
//    -1 - if records array element equal to AIValue was not found.
//#/F
//
function N_BinSearch1( APElemArray: TN_BytesPtr; AElemCount, AElemSize,
                                                 AIValue: integer ) : Integer;
var
  imin, imax, inext, itmp: Integer;
begin
  imin := 0;
  imax := AElemCount-1;

  while imin <= imax do
  begin
    inext := (imin + imax) shr 1;
    itmp := PInteger(@APElemArray[inext*AElemSize])^;

    if AIValue = itmp then
    begin
      Result := inext;
      Exit;
    end;

    if AIValue < itmp then
      imax := inext - 1
    else
      imin := inext + 1;
  end; // while imin <= imax do

  Result := -1; // not found
end; // function N_BinSearch1

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_BinSearch2
//************************************************************ N_BinSearch2 ***
// Dichotomic search for Index of Element interval including given Integer value
// in given ordered records array
//
//     Parameters
// APElemArray - pointer to Integer field of first record of given records array
// AElemCount  - number of elements in given records array
// AElemSize   - one record size in bytes
// AIValue     - given value to search to
// Result      - Returns records array element Index, -1 or AElemCount:
//#F
// Index      - if ElemArray[Index] <= AIValue < ElemArray[Index+1]
//    -1      - if AIValue < ElemArray[0]
// AElemCount - if AIValue >= ElemArray[ElemCount-1]
//#/F
//
function N_BinSearch2( APElemArray: TN_BytesPtr; AElemCount, AElemSize,
                                            AIValue: integer ) : Integer;
var
  imin, imax, inext, itmp: Integer;
begin
  inext := 0; // to avoid warning

  imin := 0;
  imax := AElemCount-1;

  itmp := PInteger(@APElemArray[0])^;
  if AIValue < itmp then
  begin
    Result := -1;
    Exit;
  end;

  itmp := PInteger(@APElemArray[imax*AElemSize])^;
  if AIValue >= itmp then
  begin
    Result := AElemCount;
    Exit;
  end;

  while imin <= imax do
  begin
    inext := (imin + imax) shr 1;
    itmp := PInteger(@APElemArray[inext*AElemSize])^;

    if AIValue = itmp then
    begin
      Result := inext;
      Exit;
    end;

    if AIValue < itmp then
      imax := inext - 1
    else
      imin := inext + 1;
  end; // while imin <= imax do

  if AIValue < itmp then
    Result := inext - 1
  else
    Result := inext;
end; // function N_BinSearch2

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_CreateTestColors
//****************************************************** N_CreateTestColors ***
// Fill Colors array by random Colors
//
//     Parameters
// AMode    - fill colors array mode:
//#F
// (0) fctAnyIndependant   - R,G,B components are random in range (0..255) and independant
// (1) fctRangeIndependant - R,G,B components are random in range (Color1..Color2) and independant
// (2) fctRandLinear       - R,G,B components are linear combination of Color1, Color2
//                             with random coef.
// (3) fctUniformLinear    - R,G,B components are linear combination of Color1, Color2
//                             with uniform coef.
// (4) fct3DigitNumbers    - each R,G,B component is incremented by 1 (as in 3 digit numbers),
//                             in (Color1, Color2) range
//#/F
// AColor1  - first fill parameter used in all modes except fctAnyIndependant
// AColor2  - second fill parameter used in all modes except fctAnyIndependant
// APColors - pointer to first element of Colors array to fill
// ACount   - number of elements of Colors array to fill
//
procedure N_CreateTestColors( AMode: TN_RAFillColorsType; AColor1, AColor2: integer;
                                            APColors: PInteger; ACount: Integer );
var
  i, c1, c2, rm, gm, bm, rd, gd, bd, r, g, b: integer;
  coef: double;
begin
  // rm, gm, bm - min R,G,B values
  // rd, gd, bd - abs delta R,G,B values

  c1 := AColor1 and $FF; // Red component
  c2 := AColor2 and $FF;
  if c1 > c2 then
  begin
    rm := c2;
    rd := c1 - c2;
  end else
  begin
    rm := c1;
    rd := c2 - c1;
  end;

  c1 := (AColor1 shr 8) and $FF; // Green component
  c2 := (AColor2 shr 8) and $FF;
  if c1 > c2 then
  begin
    gm := c2;
    gd := c1 - c2;
  end else
  begin
    gm := c1;
    gd := c2 - c1;
  end;

  c1 := (AColor1 shr 16) and $FF; // Blue component
  c2 := (AColor2 shr 16) and $FF;
  if c1 > c2 then
  begin
    bm := c2;
    bd := c1 - c2;
  end else
  begin
    bm := c1;
    bd := c2 - c1;
  end;

  case AMode of
  fctAnyIndependant: begin // R,G,B components are in range (0..255) and independant
    for i := 0 to ACount-1 do
    begin
      APColors^ := Random(255) or (Random(255) shl 8) or (Random(255) shl 16);
      Inc(APColors);
    end;
  end; // end case 0:

  fctRangeIndependant: begin // R,G,B components are in range (Color1..Color2) and independant
    for i := 0 to ACount-1 do
    begin
      APColors^ :=   rm+Random(rd)           or
                   ((gm+(Random(gd))) shl 8) or
                   ((bm+(Random(bd))) shl 16);
      Inc(APColors);
    end;
  end; // end case 1:

  fctRandLinear: begin // R,G,B components are linear combination of Color1, Color2
           //                     with same random coef.
    for i := 0 to ACount-1 do
    begin
      coef := Random;
      APColors^ :=    rm+Round(coef*rd)         or
                   ((gm+Round(coef*gd)) shl 8) or
                   ((bm+Round(coef*bd)) shl 16);
      Inc(APColors);
    end;
  end; // end case 2:

  fctUniformLinear: begin // R,G,B components are linear combination of Color1, Color2
                          //                     with uniform coef.
    for i := 0 to ACount-1 do
    begin
      if ACount = 1 then
        coef := 0.5
      else
        coef := i / (ACount-1);

      APColors^ :=    rm+Round(coef*rd)         or
                   ((gm+Round(coef*gd)) shl 8) or
                   ((bm+Round(coef*bd)) shl 16);
      Inc(APColors);
    end;
  end; // end case 3:

  fct3DigitNumbers: begin // each R,G,B component is incremented by 1
                          // (as in sequential 3 digit numbers),
                          //  all components are in (Color1, Color2) range
    r := rm;
    g := gm;
    b := bm;

    APColors^ := r or (g shl 8) or (b shl 16);
    Inc(APColors);

    for i := 1 to ACount-1 do
    begin
      Inc(r);

      if r > (rm + rd) then
      begin
        r := rm;
        Inc(g);

        if g > (gm + gd) then
        begin
          g := gm;
          Inc(b);

          if b > (bm + bd) then
            b := bm;

        end; // if g > (gm + gd) then
      end; // if r > (rm + rd) then

      APColors^ := r or (g shl 8) or (b shl 16);
      Inc(APColors);
    end;
  end; // end case 4:

//  5: begin // all colors are in (Color1..Color2) range and
//           // as different as possible
      // not implemented yet

//  end; // end case 5:

  end; // case Mode of
end; // end of procedure N_CreateTestColors

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_InterpolateTwoColors
//************************************************** N_InterpolateTwoColors ***
// Get linear interpolation of two given colors with given factor
//
//     Parameters
// AColor1 - first color
// AColor2 - second color
// AAlpha  - interpolation factor
// Result  - Returns interpolated color equals to
//#F
//   Result := (1 - AAlpha) * AColor1 + AAlpha * AColor2
//#/F
//
function N_InterpolateTwoColors( AColor1, AColor2: Integer; AAlpha: double ): integer;
var
  Beta: double;
begin
  Beta := 1.0 - AAlpha;
  Result := Round( (AColor1 and $FF)*Beta + (AColor2 and $FF)*AAlpha )      or
           (Round( ((AColor1 shr 8)  and $FF)*Beta  +
                              ((AColor2 shr 8)  and $FF)*AAlpha   ) shl 8) or
           (Round( ((AColor1 shr 16) and $FF)*Beta  +
                              ((AColor2 shr 16) and $FF)*AAlpha   ) shl 16);
end; // end of function N_InterpolateTwoColors

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ProcessMessages
//******************************************************* N_ProcessMessages ***
// Process Windows messages in infinite loop until some key events come
//
//     Parameters
// Result - Returns 0 if only loop was broken and 1 if application was 
//          terminated
//
// Infinite loop break events:
//#F
//       EVENT                     ACTION                    RESULT
// Escape key press              Infinite loop break           0
// Ctrl   key press and release  Infinite loop break           0
// Shift + Escape keys press     Application terminate         1
//#/F
//
function N_ProcessMessages(): integer;
var
  CtrlWasDown: boolean;
begin
  CtrlWasDown := False;
  Result := 0;
  while True do
  begin
    if (GetAsyncKeyState(VK_CONTROL) and $8000) = $8000 then CtrlWasDown := True;

    if ((GetAsyncKeyState(VK_ESCAPE) and $8000) = $8000) and
       ((GetAsyncKeyState(VK_SHIFT)  and $8000) = $8000)     then
    begin
      Application.Terminate;
      Result := 1;
      Exit;
    end;

    if ((GetAsyncKeyState(VK_CONTROL) and $8000) = 0) and CtrlWasDown then
      Break; // Ctrl key was released

    if ((GetAsyncKeyState(VK_ESCAPE) and $8000) = 0)
    then
      Application.ProcessMessages
    else
      Break;
  end; // while True do
end; // end of function N_ProcessMessages

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_RemoveSMatrRows
//******************************************************* N_RemoveSMatrRows ***
// Remove Strings Matrix rows which [0] element starts with one of given 
// patterns
//
//     Parameters
// ASMatr - given Strings Matrix
// APat1  - 1-st pattern (parameter default value is empty string)
// APat2  - 2-nd pattern (parameter default value is empty string)
// APat3  - 3-d  pattern (parameter default value is empty string)
//
procedure N_RemoveSMatrRows( var ASMatr: TN_ASArray; APat1: string = '';
                                        APat2: string = ''; APat3: string = '' );
var
  i, Ind, SMLeng, L1, L2, L3: integer;

  function RemoveRow( k: integer): boolean; // local
  // check if k-th SMatr Row should be removed
  Label Remove;
  begin
    Result := False;

    if L1 = 0 then
    begin
      if ASMatr[k,0] = '' then
        goto Remove
      else
        Exit; // empty Pattern should be the last one
    end else // L1 > 0
      if Copy(ASMatr[k,0], 1, L1) = APat1 then
        goto Remove;

    if L2 = 0 then
    begin
      if ASMatr[k,0] = '' then
        goto Remove
      else
        Exit; // empty Pattern should be the last one
    end else // L2 > 0
      if Copy(ASMatr[k,0], 1, L2) = APat2 then
        goto Remove;

    if L3 = 0 then
    begin
      if ASMatr[k,0] = '' then
        goto Remove
    end else // L3 > 0
      if Copy(ASMatr[k,0], 1, L3) = APat3 then
        goto Remove;

    Exit; // Row should not be removed

    Remove: Result := True; // Row should be removed
  end; // function RemoveRow // local

begin // body of procedure N_RemoveSMatrRows

  L1 := Length( APat1 );
  L2 := Length( APat2 );
  L3 := Length( APat3 );

  SMLeng := Length( ASMatr );
  Ind := 0;

  for i := 0 to SMLeng-1 do // along all ASMatr Rows
  begin
    if RemoveRow( i ) then
      Continue // to next Row
    else
    begin
      if Ind < i then
        ASMatr[Ind] := ASMatr[i];
      Inc(Ind);
    end;
  end; // for i := 0 to SMLeng-1 do // along all ASMatr Rows

  SetLength( ASMatr, Ind );

end; // procedure N_RemoveSMatrRows

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_LoadDBFColumns
//******************************************************** N_LoadDBFColumns ***
// Load given columns from file in DBF format to Strings Matrix
//
//     Parameters
// AStrMatr    - Strings Matrix (on output)
// APColNames  - pointer to first element of strings array with DBF Columns 
//               Names
// AFileName   - DBF File Name
// ANumColumns - number of elements in DBF Columns Names array
//
procedure N_LoadDBFColumns( var AStrMatr: TN_ASArray; APColNames: PString;
                                      ANumColumns: integer; AFileName: string );
var
  i, j: integer;
  Fh: File;
  DBFObj: TN_DBF;
  FieldInds: TN_IArray;
  Buf: string;
begin
  DBFObj := TN_DBF.Create;
  N_i := DBFObj.Records.Count;
  N_ROpenFile( Fh, AFileName );
  DBFObj.LoadHeader( Fh );
  SetLength( FieldInds, ANumColumns );
  SetLength( AStrMatr, DBFObj.Header[0].RecCount );
  SetLength( Buf, DBFObj.Header[0].RecSize ); // add 1 because of control character

  for i := 0 to ANumColumns-1 do // fill FieldInds array (Filed indexis)
  begin
    FieldInds[i] := DBFObj.FieldIndexOf( APColNames^ );
    Inc( APColNames );
  end;

  // each DBF row is preceeded by control charater ( space or * if row was deleted)
  // DBFObj.Header[0].RecPos is this control character position for first row

  seek( Fh, DBFObj.Header[0].RecPos );

  for i := 0 to DBFObj.Header[0].RecCount-1 do // loop along DBF rows
  begin
    SetLength( AStrMatr[i], ANumColumns );
    BlockRead( Fh, Buf[1], Length(Buf) ); // read whole row with control character

    for j := 0 to ANumColumns-1 do // loop along Fields list
    with DBFObj.Header[FieldInds[j]] do
    begin
      AStrMatr[i,j] := Copy( Buf, FieldPos+1, FieldSize ); // add 1 because of control character
    end; // with, for j := 0 to NumColumns-1 do // loop along Fields list

  end; // for i := 0 to DBFObj.Header[0].RecCount-1 do // loop along DBF rows

  CloseFile ( Fh );
//  N_i1 := DBFObj.Records.Count;
//  FreeAndNil( DBFObj.Records );
//  DBFObj.Records.Add( '' );

//  DBFObj.Free; // Strange error!!!!
end; // procedure N_LoadDBFColumns

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SaveSMatrToString0
//**************************************************** N_SaveSMatrToString0 ***
// Add Strings Matrix to given Strings List using given elements delimiter
//
//     Parameters
// AStrMatr - Strings Matrix (two dimensions array where first index - Row, 
//            second - Column)
// AStrings - resulting TStrings (each adding string is buit from corresponding 
//            AStrMatr row)
// ADelim   - matrix row elements delimiter
//
procedure N_SaveSMatrToString0( AStrMatr: TN_ASArray; AStrings: TStrings;
                                                      ADelim: Char = ';' );
var
  i, j: integer;
  CSVStr: string;
begin
  for i := 0 to High(AStrMatr) do // loop along matr rows
  begin
    CSVStr := '';
    for j := 0 to High(AStrMatr[i]) do // loop along strings in cur matr row
        CSVStr := CSVStr + N_ConvCellToCSV( AStrMatr[i,j], ADelim );

//    CSVStr := N_Remove0DChars( CSVStr ); // is needed?
    SetLength( CSVStr, Length(CSVStr)-1 ); // remove last delimiter
    AStrings.Add( CSVStr );
  end; // for i := 0 to High(StrMatr) do // loop along matr (and file) rows
end; // end of procedure N_SaveSMatrToString0

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SaveSMatrToStrings
//**************************************************** N_SaveSMatrToStrings ***
// Add Strings Matrix to given Strings List in given format
//
//     Parameters
// AStrMatr  - Strings Matrix (two dimensions array where first index - Row, 
//             second - Column)
// AStrings  - resulting TStrings (each adding string is buit from corresponding
//             AStrMatr row)
// ASMFormat - given Strings Format (CSV, Tab or Space delimited)
//
procedure N_SaveSMatrToStrings( AStrMatr: TN_ASArray; AStrings: TStrings;
                                                 ASMFormat: TN_StrMatrFormat );
var
  SpaceGap: integer;
begin
  case ASMFormat of
    smfCSV: N_SaveSMatrToString0( AStrMatr, AStrings, ';' );
    smfTab: N_SaveSMatrToString0( AStrMatr, AStrings, Char($09) );
  else
    SpaceGap := 1;
    if ASMFormat = smfSpace3 then SpaceGap := 3;
    N_SaveSMatrToText( AStrMatr, AStrings, SpaceGap );
  end; // case ASMFormat of
end; // end of function N_SaveSMatrToStrings

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SaveSMatrToFile
//******************************************************* N_SaveSMatrToFile ***
// Save Strings Matrix to given file in given format using N_SaveSMatrToStrings
//
//     Parameters
// AStrMatr  - Strings Matrix (two dimensions array where first index - Row, 
//             second - Column)
// AFileName - given File Name
// ASMFormat - given File Format (CSV, Tab or Space delimited)
//
// For saving to file K_SaveStringsToDFile procedure is used.
//
procedure N_SaveSMatrToFile( AStrMatr: TN_ASArray; AFileName: string;
                                                 ASMFormat: TN_StrMatrFormat );
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  N_SaveSMatrToStrings( AStrMatr, SL, ASMFormat );
  K_SaveStringsToDFile( SL, AFileName, K_DFCreatePlain );
  SL.Free;
end; // end of function N_SaveSMatrToFile

//*********************************************** N_LoadSMatrFromCSV ***
// load Strings Matrix  from given CSV file
// (Comma Separated Values format)
//
// StrMatr     - resulting string Matrics (first index - Row, second - Column)
// FName       - full file name,
// BegPattern  - Pattern for finding file row just before matrics
// EndPattern  - Pattern for finding file row just after matrics
//
function N_LoadSMatrFromCSV( var StrMatr: TN_ASArray;
                           FName, BegPattern, EndPattern: string ): integer;
var
  FData: TextFile;
  i, RowInd, ColInd, PatternSize, FileStrSize, BegInd: integer;
  FileStr, BegFragm, Token: string;
  SkipQuote: boolean;
begin
  Result := 0;
  if not FileExists(FName) then
  begin
    N_WarnByMessage( 'Error: File  "' + FName + '"  is absent.' );
    StrMatr := nil;
    Result := -1;
    Exit;
  end;
  AssignFile( FData, FName );
  Reset( FData );

  PatternSize := Length( BegPattern );
  if PatternSize >= 1 then // find Beg of needed rows
    while True do // find BegPattern loop
    begin
      if EOF(FData) then Exit; // BegPattern not found
      ReadLn( FData, FileStr );
      BegFragm := Copy( FileStr, 1, PatternSize );
      if BegFragm = BegPattern then Break; // BegPattern found OK
    end; // while True do // find BegPattern loop

  PatternSize := Length( EndPattern );
  RowInd := 0;

  while True do //***************** read file rows (matr rows) loop
  begin
    if High(StrMatr) < RowInd then
      SetLength( StrMatr, N_NewLength( Length(StrMatr), 20 ) );
    if EOF(FData) then Break; // end of file
    ReadLn( FData, FileStr );
    if Trim(FileStr) = '' then Continue; // skip empty rows
    FileStr := FileStr + ';';

    if PatternSize >= 1 then // check end of rows if needed
    begin
      BegFragm := Copy( FileStr, 1, PatternSize );
      if BegFragm = EndPattern then Break; // EndPattern found OK, end of rows
    end;

    FileStrSize := Length( FileStr );
    ColInd := 0;
    BegInd := 1;

    if RowInd > 0 then // set Length by previous row
      SetLength( StrMatr[RowInd], Length(StrMatr[RowInd-1]) );

    while True do //***** get tokens from current row (fill matr row) loop
    begin
      if BegInd > FileStrSize then Break; // ens of file row
      if High(StrMatr[RowInd]) < ColInd then
        SetLength( StrMatr[RowInd],
                    N_NewLength( Length(StrMatr[RowInd]), 20 ) );

      if FileStr[BegInd] = '"' then // quoted token
      begin
        Token := '';
        SkipQuote := False;

        for i:= BegInd+1 to FileStrSize do
        begin

          if (FileStr[i] = '"') and SkipQuote then
          begin
            SkipQuote := False;
            Continue;
          end;

          if (FileStr[i] = '"') and (FileStr[i+1] = '"') then
          begin
            SkipQuote := True;
            Token := Token + '"';
            Continue;
          end;

          if (FileStr[i] = '"') and (FileStr[i+1] = ';') then
          begin
            StrMatr[RowInd,ColInd] := Token;
            BegInd := i + 2;
            Break;
          end;

          if i = FileStrSize then // closing '"' is absent
          begin
            N_WarnByMessage( 'Error: Bad token in row ' +
                     IntToStr(RowInd+1) + ' in File  "' + FName + '" .' );
            Exit;
          end;

          Token := Token + FileStr[i]; // add next character

        end; // for i:= BegInd+1 to FileStrSize do
      end else // simple token
      begin
        for i:= BegInd to FileStrSize do
        if FileStr[i] = ';' then
        begin
          StrMatr[RowInd,ColInd] := Copy( FileStr, BegInd, i-BegInd );
          BegInd := i+1;
          Break; // end of simple token
        end;
      end; // end else // simple token
      Inc(ColInd);
    end; // while True do // tokens in current row (fill matr row) loop

    SetLength( StrMatr[RowInd], ColInd );
    Inc(RowInd);
  end; // while True do // read file rows (matr rows) loop

  SetLength( StrMatr, RowInd );
  N_AdjustStrMatr( StrMatr );
  Close( FData );
end; // end of function N_LoadSMatrFromCSV

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SaveSMatrToText
//******************************************************* N_SaveSMatrToText ***
// Add Strings Matrix to Strings List using given number of spaces as elements 
// delimiter
//
//     Parameters
// AStrMatr  - Strings Matrix (two dimensions array where first index - Row, 
//             second - Column)
// AStrings  - Resulting TStrings (each adding string is buit from corresponding
//             AStrMatr row)
// ASpaceGap - number of spaces between row elements (columns)
//
// Quote row elements if space inside.
//
procedure N_SaveSMatrToText( AStrMatr: TN_ASArray; AStrings: TStrings;
                                                          ASpaceGap: integer );
var
  i, j, k, ColSize, ElSize, NumRows, NumColumns, Sleng: integer;
  TmpStrMatr: TN_ASArray;
  ResStr, CellStr: string;
  ColInds: TN_IArray;
  CurChar: Char;
begin
  NumRows := Length(AStrMatr);
  if NumRows = 0 then Exit; // empty Matrics

  NumColumns := Length(AStrMatr[0]);
  SetLength( ColInds, NumColumns+1 );
  ColInds[0] := 1;

  SetLength( TmpStrMatr, NumRows );
  for i := 0 to NumRows-1 do
    SetLength( TmpStrMatr[i], NumColumns );

  for i := 0 to NumColumns-1 do // Calc max width for all columns
  begin
    ColSize := 0;
    for j := 0 to NumRows-1 do
    begin
      CellStr := AStrMatr[j,i];
      SLeng := Length(CellStr);

      for k := 1 to SLeng do
      begin
        CurChar := CellStr[k];
        if (CurChar = ' ') or (CurChar = '"') then
        begin
          CellStr := N_QuoteStr( CellStr, '"' );
          Break;
        end
      end; // for k := 1 to SLeng do

      TmpStrMatr[j,i] := CellStr;

      ElSize := Length(CellStr);
      if ColSize < ElSize then ColSize := ElSize;
    end; // for j := 0 to NumRows-1 do

    ColInds[i+1] := ColInds[i] + ColSize + ASpaceGap;
  end; // for i := 0 to NumColumns-1 do - Calc max width for all columns

  for i := 0 to NumRows-1 do // loop along matr (and file) rows
  begin
    ResStr := DupeString( ' ', ColInds[NumColumns] ); // all spaces
    for j := 0 to NumColumns-1 do // loop along strings in cur matr row
      Insert( TmpStrMatr[i,j], ResStr, ColInds[j] );

    SetLength( ResStr, ColInds[NumColumns] );
    ResStr := N_Remove0DChars( ResStr );
    AStrings.Add( ResStr );
  end; // for i := 0 to NumRows-1 do // loop along matr (and file) rows

end; // end of function N_SaveSMatrToText

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SaveSMatrToString
//***************************************************** N_SaveSMatrToString ***
// Save Strings Matrix to one string
//
//     Parameters
// AStrMatr - Strings Matrix (two dimensions array where first index - Row, 
//            second - Column)
// Result   - Returns string with concatenate Strings Matrix elements.
//
// Strings Matrix Row elements are separated by Tab char (#9). Strings Matrix 
// Rows are separarted by CR LF. Resulting string can be assigned to 
// StringList.Text or to Clipboard.AsText fields.
//
function N_SaveSMatrToString( AStrMatr: TN_ASArray ): string;
var
  i, j, MatrLeng, Ind, ElemLeng: integer;
begin
  MatrLeng := 0; // calc Resulting string Length
  for i := 0 to High(AStrMatr) do // loop along matr rows
  begin
    for j := 0 to High(AStrMatr[i]) do // calc MatrLeng
      MatrLeng := MatrLeng + Length(AStrMatr[i,j]) + 1;

    Inc( MatrLeng ); // + $0A$0D - 'Tab'
  end; // for i := 0 to High(StrMatr) do // loop along matr rows

  SetLength( Result, MatrLeng );
  Ind := 1;

  for i := 0 to High(AStrMatr) do // loop along matr rows
  begin
    for j := 0 to High(AStrMatr[i]) do // fill Result string
    begin
      ElemLeng := Length( AStrMatr[i,j] );
      move( AStrMatr[i,j][1], Result[Ind], ElemLeng );
      Inc( Ind, ElemLeng );
      Result[Ind] := #9;
      Inc( Ind );
    end;

    Result[Ind-1] := #$D;
    Result[Ind]   := #$A;
    Inc( Ind );
  end; // for i := 0 to High(StrMatr) do // loop along matr rows

//  Clipboard.AsText := SL.Text;
end; // end of function N_SaveSMatrToString

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_LoadSMatrFromTxt
//****************************************************** N_LoadSMatrFromTxt ***
// Load Strings Matrix from given TXT file
//
//     Parameters
// AStrMatr    - resulting Strings Matrix (two dimensions array where first 
//               index - Row, second - Column)
// AFName      - full file name,
// ABegPattern - Pattern for finding file row just before Matrix
// AEndPattern - Pattern for finding file row just after Matrix
//
// Strings Matrix row elements should be stored in given file as space separated
// Tokens (quoted if contained spaces inside).
//
function N_LoadSMatrFromTxt( var AStrMatr: TN_ASArray;
                           AFName, ABegPattern, AEndPattern: string ): integer;
var
  FData: TextFile;
  RowInd, ColInd, PatternSize: integer;
  FileStr, BegFragm: string;
begin
  Result := 0;
  AStrMatr := nil;
  if not FileExists(AFName) then
  begin
    N_WarnByMessage( 'Error: File  "' + AFName + '"  is absent.' );
    Result := -1;
    Exit;
  end;
  AssignFile( FData, AFName );
  Reset( FData );

  PatternSize := Length( ABegPattern );
  if PatternSize >= 1 then // find Beg of needed rows
    while True do // find BegPattern loop
    begin
      if EOF(FData) then Exit; // BegPattern not found
      ReadLn( FData, FileStr );
      BegFragm := Copy( FileStr, 1, PatternSize );
      if BegFragm = ABegPattern then Break; // BegPattern found OK
    end; // while True do // find BegPattern loop

  PatternSize := Length( AEndPattern );
  RowInd := 0;

  while True do //***************** read file rows (matr rows) loop
  begin
    if High(AStrMatr) < RowInd then
      SetLength( AStrMatr, N_NewLength( Length(AStrMatr), 20 ) );
    if EOF(FData) then Break; // end of file
    ReadLn( FData, FileStr );
    if Trim(FileStr) = '' then Continue; // skip empty rows

    if PatternSize >= 1 then // check end of rows if needed
    begin
      BegFragm := Copy( FileStr, 1, PatternSize );
      if BegFragm = AEndPattern then Break; // EndPattern found OK, end of rows
    end;

    ColInd := 0;
    if RowInd > 0 then // set Length by previous row
      SetLength( AStrMatr[RowInd], Length(AStrMatr[RowInd-1]) );

    while True do //***** get tokens from FileStr (fill matr row) loop
    begin
      if FileStr = '' then  Break; // end of cur file row

      if High(AStrMatr[RowInd]) < ColInd then
        SetLength( AStrMatr[RowInd], N_NewLength( Length(AStrMatr[RowInd]), 20 ));

      AStrMatr[RowInd,ColInd] := N_ScanToken( FileStr );
      Inc(ColInd);
    end; // while True do // tokens in current row (fill matr row) loop

    SetLength( AStrMatr[RowInd], ColInd );
    Inc(RowInd);
  end; // while True do // read file rows (matr rows) loop

  SetLength( AStrMatr, RowInd );
  N_AdjustStrMatr( AStrMatr );
  Close( FData );
end; // end of function N_LoadSMatrFromTxt

{

//*********************************************** N_LoadStrMatrFromString ***
// load Strings Matrics (table of strings) from Clipboard (in text format)
//
// StrMatr - string Matrics (first index - Row, second index - Column)
//
procedure N_LoadStrMatrFromString( var StrMatr: TN_ASArray; InpStr: string );
var
  i, RowInd, ColInd, BegInd, FileStrSize: integer;
  SL: TStringList;
  FileStr: string;
begin

//  if not Clipboard.HasFormat( CF_TEXT ) then // no text in clipboard
//  begin
//    StrMatr := nil;
//    Result := -1;
//    Exit;
//  end;

  SL := TStringList.Create;
//  SL.Text := Clipboard.AsText;
  SL.Text := InpStr;
  RowInd := 0;

  while True do //***************** read file rows (matr rows) loop
  begin
    if High(StrMatr) < RowInd then
      SetLength( StrMatr, N_NewLength( Length(StrMatr), 20 ) );

    if RowInd = SL.Count then Break; // end of rows

    FileStr := SL.Strings[RowInd] + #9;
    FileStrSize := Length( FileStr );
    ColInd := 0;
    BegInd := 1;

    while True do //***** get tokens from current row (fill matr row) loop
    begin
      if BegInd > FileStrSize then Break; // end of file row
      if RowInd > 0 then // set Length by previous row
        SetLength( StrMatr[RowInd], Length(StrMatr[RowInd-1]) );
      if High(StrMatr[RowInd]) < ColInd then
        SetLength( StrMatr[RowInd],
                    N_NewLength( Length(StrMatr[RowInd]), 20 ) );

      for i:= BegInd to FileStrSize do
      if FileStr[i] = #9 then
      begin
        StrMatr[RowInd,ColInd] := Copy( FileStr, BegInd, i-BegInd );
        BegInd := i+1;
        Break; // end of simple token
      end;

    Inc(ColInd);
    end; // while True do // tokens in current row (fill matr row) loop

    SetLength( StrMatr[RowInd], ColInd );
    Inc(RowInd);
  end; // while True do // read file rows (matr rows) loop

  SetLength( StrMatr, RowInd );
  SL.Free;
  N_AdjustStrMatr( StrMatr );
end; // end of procedure N_LoadStrMatrFromString

//*********************************************** N_SaveStrMatrToStrings ***
// Add given AStrMatr (table of strings) to given AStrings
// Space Separated Tokens (Token is in quotes if space inside Token)
//
// AStrMatr - Source string Matrics (first index - Row, second - Column)
// AStrings - resulting strings
// TMPMode - =0 - Tab, =1 - CSV, =2 Adjust by spaces, =3 - same but + spaces
//
procedure N_SaveStrMatrToStrings( AStrMatr: TN_ASArray; AStrings: TStrings;
                                                    ASDF: TK_StringsDataFormat );
var
  i, j, ColSize, ElSize, NumRows, NumColumns, Gap: integer;
  Str: string;
  ColInds: TN_IArray;
begin
  NumRows := Length(AStrMatr);
  if NumRows = 0 then Exit; // empty Matrics

  NumColumns := Length(AStrMatr[0]);

  if ASDF = K_sdfTab then // Tab delimitated
  begin
    for i := 0 to NumRows-1 do // loop along matr rows
    begin
      Str := '';
      for j := 0 to High(AStrMatr[i]) do // loop along strings in cur matr row
        Str := Str + AStrMatr[i,j] + #9;

      Delete( Str, Length(Str), 1 ); // remove last Tab
      AStrings.Add( Str );
    end; // for i := 0 to NumRows-1 do // loop along matr rows
  end else if ASDF = K_sdfCSV then // CSV format
  begin
    for i := 0 to NumRows-1 do // loop along matr rows
    begin
      Str := '';
      for j := 0 to High(AStrMatr[i]) do // loop along strings in cur matr row
        Str := Str + N_QuoteStr( AStrMatr[i,j], ';' );

      AStrings.Add( Str );
    end; // for i := 0 to NumRows-1 do // loop along matr (and file) rows

  end else // Space delimitated with elements width Adjustment
  begin
    if ASDF = K_sdfGap1 then Gap := 0
    else Gap := 2;

    SetLength( ColInds, NumColumns+1 ); // Colomns positions
    ColInds[0] := 1;

    for i := 0 to NumColumns-1 do // Calc max width for all columns
    begin
      ColSize := 0;

      for j := 0 to NumRows-1 do // calc i-th column size
      begin
        ElSize := Length(N_QS(AStrMatr[j,i]));
        if ColSize < ElSize then ColSize := ElSize;
      end; // for j := 0 to NumRows-1 do // calc i-th column size

      ColInds[i+1] := ColInds[i] + ColSize + Gap;
    end; // for i := 0 to NumColumns-1 do - Calc max width for all columns

    for i := 0 to NumRows-1 do // loop along matr rows
    begin
      Str := DupeString( ' ', ColInds[NumColumns] ); // all spaces
      for j := 0 to NumColumns-1 do // loop along strings in cur matr row
        Insert( N_QS(AStrMatr[i,j]), Str, ColInds[j] );

      AStrings.Add( Str );
    end; // for i := 0 to NumRows-1 do // loop along matr (and file) rows
  end; // else // Space delimitated with elements width Adjustment
end; // end of procedure N_SaveStrMatrToStrings

//********************************************** N_GetPatternIndex ***
// Seacrch in given AStrings for Given APattren string,
// beginning from given index ABegInd,
// return index of found Pattern or -1 if not found
//
function N_GetPatternIndex( AStrings: TStrings;
                            APattern: string; ABegInd: integer ): integer;
var
  i, IMax, PatLeng: integer;
begin
  PatLeng := Length(APattern);
  IMax := AStrings.Count -1;

  for i := ABegInd to IMax do
  begin
    if Length(AStrings[i]) <> Patleng then Continue;
    if PInteger(@AStrings[i][1])^ <> PInteger(@APattern[1])^ then Continue;
    if AStrings[i] <> APattern then Continue;

    //***** Here: AStrings[i] = APattern
    Result := i;
    Exit;
  end; // for i := ABegInd to IMax do

  Result := -1; // Pattern not found
end; // end of function N_GetPatternIndex

//********************************************* N_ReplaceSectionInStrings ***
// Replace section with ASectionName in ASrcStrings by given ASection,
// resulting Strings (with replaced section) are in AResStrings
//
procedure N_ReplaceSectionInStrings( ASrcStrings, AResStrings, ASection: TStrings;
                                                         ASectionName: string );
var
  i, IMax, JMax, PatLeng, IHeader, INext: integer;
  CurStr, Pattern: string;
  Found: boolean;
begin
  IHeader := 0; // to avoid warning
  AResStrings.Clear;
  Pattern := '[[' + ASectionName + ']]';
  PatLeng := Length(Pattern);
  IMax := ASrcStrings.Count -1;
  Found := False;

  for i := 0 to IMax do
  begin
    CurStr := ASrcStrings[i];
    AResStrings.Add( CurStr );

    if Length(CurStr) <> Patleng then Continue;
    if PInteger(@CurStr[1])^ <> PInteger(@Pattern[1])^ then Continue;
    if CurStr <> Pattern then Continue;

    //***** Here: ASrcStrings[i] = Pattern
    IHeader := i;
    Found := True;
    Break;
  end; // for i := ABegInd to IMax do

  JMax := ASection.Count-1;

  for i := 0 to JMax do
    AResStrings.Add( ASection[i] );

  if not Found then Exit;

  INext := N_GetPatternIndex( ASrcStrings, Pattern, IHeader+1 );

  for i := INext to IMax do
    AResStrings.Add( ASrcStrings[i] );

end; // procedure N_ReplaceSectionInStrings

//********************************************* N_GetSectionFromStrings ***
// Create ASection - section with ASectionName from AStrings,
// begin search from given ABegInd, return string index after ASectionName
//
function N_GetSectionFromStrings( AStrings, ASection: TStrings;
                             ASectionName: string; ABegInd: integer ): integer;
var
  i, IMax, IBeg, PatLeng: integer;
  CurStr, Pattern: string;
begin
  Result := -1; // not found flag

  Pattern := '[[' + ASectionName + ']]';
  IBeg := N_GetPatternIndex( AStrings, Pattern, ABegInd ) + 1;

  Pattern := '[[/' + ASectionName + ']]';
  PatLeng := Length(Pattern);
  IMax := AStrings.Count -1;

  ASection.Clear;

  for i := IBeg to IMax do
  begin
    CurStr := AStrings[i];
    ASection.Add( CurStr );

    if Length(CurStr) <> Patleng then Continue;
    if PInteger(@CurStr[1])^ <> PInteger(@Pattern[1])^ then Continue;
    if CurStr <> Pattern then Continue;

    //***** Here: ASrcStrings[i] = Pattern, all done
    Result := i + 1;
    ASection.Delete( ASection.Count-1 ); // delete end_of_section Pattern
    Break;
  end; // for i := IBeg to IMax do

end; // function N_GetSectionFromStrings

//********************************************* N_ReplaceSectionInFile ***
// Replace section with ASectionName in file AFileName by given ASection
//
procedure N_ReplaceSectionInFile( AFileName: string; ASection: TStrings;
                                                         ASectionName: string );
var
  SL1, SL2: TStringList;
begin
  SL1 := TStringList.Create;
  SL2 := TStringList.Create;
  N_LoadStringsFromFile1( SL1, AFileName );
  N_ReplaceSectionInStrings( SL1, SL2, ASection, ASectionName );
  N_SaveStringsToFile( SL2, AFileName );
  SL1.Free;
  SL2.Free;
end; // procedure N_ReplaceSectionInFile

//********************************************* N_GetSectionFromFile ***
// Return ASection - section with ASectionName from file AFileName
//
procedure N_GetSectionFromFile( AFileName: string; ASection: TStrings;
                                                         ASectionName: string );
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  N_LoadStringsFromFile1( SL, AFileName );
  N_GetSectionFromStrings( SL, ASection, ASectionName );
  SL.Free;
end; // procedure N_GetSectionFromFile
}

{
//**********************************************  N_GetFileExtentionType  ***
// Return extention type of given AFileName
//
function N_GetFileExtentionType( AFileName: string ): TN_FileExtType;
var
  Ext: string;
begin
  Result := fetNotDef; // Unknown
  Ext := UpperCase(ExtractFileExt( AFileName ));

  if (Ext = '.TXT') or (Ext = '.SDT') or (Ext = '.INI')  or (Ext = '.SPL') then
    Result := fetPlainText // Plain Text file
  else if (Ext = '.RTF') then
    Result := fetRichText // Rich Text file
  else if (Ext = '.BMP') or (Ext = '.BMPZ') or // (Ext = '.EMF') or  // EMF temporary not implemented!!!
          (Ext = '.JPG') or (Ext = '.JPE')  or (Ext = '.GIF') then
    Result := fetPicture // Picture file
  else if (Ext = '.HTM') or (Ext = '.HTML') or (Ext = '.SVG') then
    Result := fetHTML; // HTML file
end; // function N_GetFileExtentionType
}

//********************************************** N_CreateFileCopy ***
// Create a Copy of given ASrcFName with ADstFName name
//
procedure N_CreateFileCopy( ASrcFName, ADstFName: string );
var
  InpFStream, OutFStream: TFileStream;
begin
  InpFStream := TFileStream.Create( ASrcFName, fmOpenRead );
  OutFStream := TFileStream.Create( ADstFName, fmCreate );

  OutFStream.CopyFrom( InpFStream, 0 );

  InpFStream.Free;
  OutFStream.Free;
end; // end of procedure N_CreateFileCopy

//********************************************** N_DebugWait ***
// wait for releasing Shift key, Abort on Escape
//
function N_DebugWait(): integer;
begin
  Result := 0;
  while True do
  begin
    if N_KeyIsDown( VK_ESCAPE ) then Halt( 1 );
    if N_KeyIsDown( VK_SHIFT ) then Break;
    Application.ProcessMessages;
  end;

  while True do
  begin
    if not N_KeyIsDown( VK_SHIFT ) then Break;
    Application.ProcessMessages;
  end;

end; // end of function N_DebugWait

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_DosToWin
//************************************************************** N_DosToWin ***
// Convert string from DOS to ANSI chars coding
//
//     Parameters
// ADosStr - given string in DOS chars coding
// Result  - Returns converted string in ANSI chars coding
//
function N_DosToWin( ADosStr: AnsiString ): string;
{ old variant
var
  DosLeng: integer;
begin
  DosLeng := Length(DosStr);
  if Length(N_Str) < DosLeng+4 then
    SetLength( N_Str, DosLeng+100 );
  OemToChar( PChar(DosStr), PChar(N_Str) );
  SetLength( N_Str, DosLeng );
  Result := N_Str;
}
begin
  SetLength( Result, Length(ADosStr) );

  if Length(Result) = 0 then
    Exit;

  OemToChar( PAnsiChar(@ADosStr[1]), PChar(Result) );
end; // end of function N_DosToWin

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_WinToDos
//************************************************************** N_WinToDos ***
// Convert string from ANSI to DOS chars coding
//
//     Parameters
// AWinStr - given string in ANSI chars coding
// Result  - Returns converted string in DOS chars coding
//
function N_WinToDos( AWinStr: string ): AnsiString;
begin
  SetLength( Result, Length(AWinStr) );
  CharToOem( PChar(AWinStr), PAnsiChar(Result) );
end; // end of function N_WinToDos

//********************************************** N_CreateTextNums ***
// Create text file with column of numbers. Can be used as a pattern for
// manually creating recoding tables
//
procedure N_CreateTextNums( MaxNum: integer; FileName: string );
var
  Ft: TextFile;
  i: integer;
begin
  AssignFile( Ft, FileName ); // open output file
  Rewrite( Ft );

  for i := 1 to MaxNum do
  begin
    WriteLn( Ft, Format( '%.3d', [i] ) );
  end;

  CloseFile( Ft );
end; // end of procedure N_CreateTextNums


//****************  N_GienIni procedures  ******************************

//******************************************************** N_BoolToGivenIni ***
// Write given Boolean value to AGivenIni
//
//     Parameters
// ASectionName - INI file section name
// ABoolName    - INI file section key name
// ABool        - Boolean value to write
//
// Attempting to write a data value to a nonexistent section or attempting to
// write data to a nonexistent key are not errors. In these cases, new section
// and key element will be created.
//
procedure N_BoolToGivenIni( AGivenIni: TMemIniFile;
                            ASectionName, ABoolName: string; ABool: boolean );
var
  Str: string;
begin
  if AGivenIni = nil then Exit; // AGivenIni was already destroyed

  if ABool then Str := 'True'
           else Str := 'False';

  AGivenIni.WriteString( ASectionName, ABoolName, Str );
end; // end of procedure N_BoolToGivenIni

//******************************************************** N_GivenIniToBool ***
// Retrieve a Boolean value from AGivenIni
//
//     Parameters
// ASectionName - INI file section name
// ABoolName    - INI file section key name
// ADefVal      - INI file section key default value
// Result       - Returns INI file section key value as Boolean if section and
//                key exist, else ADefVal returns.
//
function N_GivenIniToBool( AGivenIni: TMemIniFile;
                           ASectionName, ABoolName: string; ADefVal: boolean ): boolean;
var
  Str: string;
begin
  Result := ADefVal;
  if AGivenIni = nil then Exit; // AGivenIni was not initialized

  Str := AGivenIni.ReadString( ASectionName, ABoolName, '!Absent!' );

  if (Str = '!Absent!') then
    Result := ADefVal
  else
    Result := N_StrToBool( Str );
end; // end of function N_GivenIniToBool

//****************************************************** N_StringToGivenIni ***
// Write given string value to AGivenIni
//
//     Parameters
// ASectionName - INI file section name
// AStringName  - INI file section key name
// AString      - string value to write
//
// Attempting to write a data value to a nonexistent section or attempting to
// write data to a nonexistent key are not errors. In these cases, new section
// and key element will be created.
//
procedure N_StringToGivenIni( AGivenIni: TMemIniFile;
                              ASectionName, AStringName, AString: string );
begin
  if AGivenIni = nil then Exit; // AGivenIni was already destroyed

  AGivenIni.WriteString( ASectionName, AStringName, AString );
end; // end of procedure N_StringToGivenIni

//****************************************************** N_GivenIniToString ***
// Retrieve a string value from AGivenIni
//
//     Parameters
// ASectionName - INI file section name
// AStringName  - INI file section key name
// ADefVal      - INI file section key default value
// Result       - Returns INI file section key value if section and key exist,
//                else ADefVal returns.
//
function N_GivenIniToString( AGivenIni: TMemIniFile;
                  ASectionName, AStringName: string; ADefVal: string ): string;
begin
  Result := ADefVal;
  if AGivenIni = nil then Exit; // AGivenIni was not initialized

  Result := AGivenIni.ReadString( ASectionName, AStringName, ADefVal );
end; // end of function N_GivenIniToString

//********************************************************* N_IntToGivenIni ***
// Write given Integer value to AGivenIni
//
//     Parameters
// ASectionName - INI file section name
// AIntName     - INI file section key name
// AInt         - Integer value to write
//
// Attempting to write a data value to a nonexistent section or attempting to
// write data to a nonexistent key are not errors. In these cases, new section
// and key element will be created.
//
procedure N_IntToGivenIni( AGivenIni: TMemIniFile;
                           ASectionName, AIntName: string; AInt: integer );
begin
  if AGivenIni = nil then Exit; // AGivenIni was already destroyed

  AGivenIni.WriteString( ASectionName, AIntName, IntToStr(AInt) );
end; // end of procedure N_IntToGivenIni

//********************************************************* N_GivenIniToInt ***
// Retrieve an Integer value from AGivenIni
//
//     Parameters
// ASectionName - INI file section name
// AIntName     - INI file section key name
// ADefVal      - INI file section key default value
// Result       - Returns INI file section key value as Integer if section and
//                key exist, else ADefVal returns.
//
function N_GivenIniToInt( AGivenIni: TMemIniFile;
                   ASectionName, AIntName: string; ADefVal: Integer ): integer;
begin
  if AGivenIni = nil then // AGivenIni was not initialized
    Result := ADefVal
  else
    Result := AGivenIni.ReadInteger( ASectionName, AIntName, ADefVal );
end; // end of function N_GivenIniToInt

//********************************************************* N_DblToGivenIni ***
// Write given Double value to AGivenIni
//
//     Parameters
// ASectionName - INI file section name
// ADblName     - INI file section key name
// AFmt         - double to string convertion format
// ADbl         - Double value to write
//
// Attempting to write a data value to a nonexistent section or attempting to
// write data to a nonexistent key are not errors. In these cases, new section
// and key element will be created.
//
procedure N_DblToGivenIni( AGivenIni: TMemIniFile;
                           ASectionName, ADblName, AFmt: string; ADbl: double );
begin
  if AGivenIni = nil then Exit; // AGivenIni was already destroyed

  AGivenIni.WriteString( ASectionName, ADblName, Format( AFmt, [ADbl] ) );
end; // end of procedure N_DblToGivenIni

//********************************************************* N_GivenIniToDbl ***
// Retrieve a Double value from AGivenIni
//
//     Parameters
// ASectionName - INI file section name
// ADblName     - INI file section key name
// ADefVal      - INI file section key default value
// Result       - Returns INI file section key value as Double if section and
//                key exist, else ADefVal returns.
//
function N_GivenIniToDbl( AGivenIni: TMemIniFile;
                     ASectionName, ADblName: string; ADefVal: double ): double;
begin
  if AGivenIni = nil then // AGivenIni was not initialized
    Result := ADefVal
  else begin
//    Result := AGivenIni.ReadFloat( ASectionName, ADblName, ADefVal );
    Result := StrToFloatDef( K_ReplaceCommaByPoint(
        AGivenIni.ReadString( ASectionName, ADblName, '' ) ), ADefVal );
  end;
end; // end of function N_GivenIniToDbl


//****************  N_MemIni procedures  ******************************

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_WriteMemIniSection
//**************************************************** N_WriteMemIniSection ***
// Save given Strings as Section content in N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// AStrings     - INI file section strings
//
// AStrings should have format Name=Value with unique Names!
//
procedure N_WriteMemIniSection( ASectionName: string; AStrings: TStrings );
var
  i, n: integer;
  Str, Name, Value: string;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  N_CurMemIni.EraseSection( ASectionName );

  for i := 0 to AStrings.Count-1 do
  begin
    Str := AStrings.Strings[i];

    //***** get Name and Value parts of Str
    n := Pos( '=', Str );
    if n < 2 then Continue; // Str is not of Name=Value format

    Name := Copy( Str, 1, n-1 );
    Value := Copy( Str, n+1, Length(Str) );

    N_CurMemIni.WriteString( ASectionName, Name, Value );
  end;
end; // end of procedure N_WriteMemIniSection

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ReadMemIniSection
//***************************************************** N_ReadMemIniSection ***
// Retrieve N_CurMemIni Section content to given Strings
//
//     Parameters
// ASectionName - INI file section name
// AStrings     - resulting Strings with INI file section content
//
// Given section values are added to the AStrings as strings of the form 
// KeyName=ValueName.
//
procedure N_ReadMemIniSection( ASectionName: string; AStrings: TStrings );
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  N_CurMemIni.ReadSectionValues( ASectionName, AStrings );
end; // end of procedure N_ReadMemIniSection

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_BoolToMemIni
//********************************************************** N_BoolToMemIni ***
// Write given Boolean value to N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// ABoolName    - INI file section key name
// ABool        - Boolean value to write
//
// Attempting to write a data value to a nonexistent section or attempting to 
// write data to a nonexistent key are not errors. In these cases, new section 
// and key element will be created.
//
procedure N_BoolToMemIni( ASectionName, ABoolName: string; ABool: boolean );
var
  Str: string;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  if ABool then Str := 'True'
           else Str := 'False';

  N_CurMemIni.WriteString( ASectionName, ABoolName, Str );
end; // end of procedure N_BoolToMemIni

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MemIniToBool
//********************************************************** N_MemIniToBool ***
// Retrieve a Boolean value from N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// ABoolName    - INI file section key name
// ADefVal      - INI file section key default value
// Result       - Returns INI file section key value as Boolean if section and 
//                key exist, else ADefVal returns.
//
function N_MemIniToBool( ASectionName, ABoolName: string; ADefVal: boolean ): boolean;
var
  Str: string;
begin
  Result := ADefVal;
  if N_CurMemIni = nil then Exit; // N_CurMemIni was not initialized

  Str := N_CurMemIni.ReadString( ASectionName, ABoolName, '!Absent!' );

  if (Str = '!Absent!') then
    Result := ADefVal
  else
    Result := N_StrToBool( Str );
end; // end of function N_MemIniToBool

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_StringToMemIni
//******************************************************** N_StringToMemIni ***
// Write given string value to N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// AStringName  - INI file section key name
// AString      - string value to write
//
// Attempting to write a data value to a nonexistent section or attempting to 
// write data to a nonexistent key are not errors. In these cases, new section 
// and key element will be created.
//
procedure N_StringToMemIni( ASectionName, AStringName, AString: string );
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  N_CurMemIni.WriteString( ASectionName, AStringName, AString );
end; // end of procedure N_StringToMemIni

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MemIniToString
//******************************************************** N_MemIniToString ***
// Retrieve a string value from N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// AStringName  - INI file section key name
// ADefVal      - INI file section key default value
// Result       - Returns INI file section key value if section and key exist, 
//                else ADefVal returns.
//
function N_MemIniToString( ASectionName, AStringName: string;
                                                   ADefVal: string ): string;
begin
  Result := ADefVal;
  if N_CurMemIni = nil then Exit; // N_CurMemIni was not initialized

  Result := N_CurMemIni.ReadString( ASectionName, AStringName, ADefVal );
end; // end of function N_MemIniToString

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_StringsToMemIni
//******************************************************* N_StringsToMemIni ***
// Write given Strings List to N_CurMemIni section
//
//     Parameters
// ASectionName - INI file section name
// AStrings     - section values Strings List
//
// Attempting to write a data value to a nonexistent section is not errors. In 
// these cases, new section will be created. Given strings are saved as 
// StringInd=Strings[StringInd].
//
procedure N_StringsToMemIni( ASectionName: string; AStrings: TStrings );
var
  i: integer;
  Str: string;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  N_CurMemIni.EraseSection( ASectionName );

  for i := 0 to AStrings.Count-1 do
  begin
    Str := AStrings.Strings[i];
    N_CurMemIni.WriteString( ASectionName, IntToStr(i), Str );
  end;
end; // end of procedure N_StringsToMemIni

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MemIniToStrings
//******************************************************* N_MemIniToStrings ***
// Retrieve section keys values from N_CurMemIni to given Strings List
//
//     Parameters
// ASectionName - INI file section name
// AStrings     - Strings List for resulting section keys values
//
// Key Name part of INI file section string is ignored.
//
procedure N_MemIniToStrings( ASectionName: string; AStrings: TStrings );
var
  i, n: integer;
  Str: string;
  WrkSL: TStringList;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  WrkSL := TStringList.Create();
  N_CurMemIni.ReadSectionValues( ASectionName, WrkSL );
  AStrings.Clear();

  for i := 0 to WrkSL.Count-1 do
  begin
    Str := WrkSL.Strings[i];
    n := Pos( '=', Str );
    Str := Copy( Str, n+1, Length(Str) );
      AStrings.Add( Str );
  end;

  WrkSL.Free;
end; // end of procedure N_MemIniToStrings

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SetSectionTopString
//*************************************************** N_SetSectionTopString ***
// Set given string as initial (Top) string in N_CurMemIni section
//
//     Parameters
// ASectionName - INI file section name
// ATopString   - new section top string value
// AMaxListSize - section maximal elements counter
//
procedure N_SetSectionTopString( ASectionName, ATopString: string; AMaxListSize: integer );
var
  TmpSL: TStringList;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  TmpSL := TStringList.Create();
  N_MemIniToStrings( ASectionName, TmpSL );
  N_AddUniqStrToTop( TmpSL, ATopString, AMaxListSize );
  N_StringsToMemIni( ASectionName, TmpSL );
  TmpSL.Free;
end; // end of procedure N_SetSectionTopString

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ComboBoxToMemIni
//****************************************************** N_ComboBoxToMemIni ***
// Save given ComboBox Items to given ASectionName in N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// AComboBox    - given ComboBox object
//
procedure N_ComboBoxToMemIni( ASectionName: string; AComboBox: TComboBox );
begin
  if ASectionName = 'N_ArchFilesHist' then
    N_i := 1;

  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  N_AddTextToTop( AComboBox );
  N_StringsToMemIni( ASectionName, AComboBox.Items );
end; // end of procedure N_ComboBoxToMemIni

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MemIniToComboBox
//****************************************************** N_MemIniToComboBox ***
// Retrieve section keys values from N_CurMemIni to given ComboBox Items
//
//     Parameters
// ASectionName - INI file section name
// AComboBox    - given ComboBox object
//
// Emty section name should be ignored. Empty values should be ignored because 
// ComboBox empty Items raise exception in Windows kernel!
//
procedure N_MemIniToComboBox( ASectionName: string; AComboBox: TComboBox );
var
  i: integer;
  Str: string;
  WrkSL: TStringList;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed
  if ASectionName = '' then Exit;  // ASectionName is not given

  WrkSL := TStringList.Create();
  N_MemIniToStrings( ASectionName, WrkSL );

  AComboBox.Items.Clear();

  for i := 0 to WrkSL.Count-1 do
  begin
    Str := WrkSL.Strings[i];
    if Str <> '' then
      AComboBox.Items.Add( Str );
  end;

  WrkSL.Free;
  if AComboBox.Items.Count >= 1 then
    AComboBox.ItemIndex := 0
  else
    AComboBox.Text := '';
end; // end of procedure N_MemIniToComboBox

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_IntToMemIni
//*********************************************************** N_IntToMemIni ***
// Write given Integer value to N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// AIntName     - INI file section key name
// AInt         - Integer value to write
//
// Attempting to write a data value to a nonexistent section or attempting to
// write data to a nonexistent key are not errors. In these cases, new section
// and key element will be created.
//
procedure N_IntToMemIni( ASectionName, AIntName: string; AInt: integer );
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  N_CurMemIni.WriteString( ASectionName, AIntName, IntToStr(AInt) );
end; // end of procedure N_IntToMemIni

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MemIniToInt
//*********************************************************** N_MemIniToInt ***
// Retrieve an Integer value from N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// AIntName     - INI file section key name
// ADefVal      - INI file section key default value
// Result       - Returns INI file section key value as Integer if section and
//                key exist, else ADefVal returns.
//
function N_MemIniToInt( ASectionName, AIntName: string; ADefVal: Integer ): integer;
begin
  if N_CurMemIni = nil then // N_CurMemIni was not initialized
    Result := ADefVal
  else
    Result := N_CurMemIni.ReadInteger( ASectionName, AIntName, ADefVal );
end; // end of function N_MemIniToInt

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_IntToMemIniAsHex
//****************************************************** N_IntToMemIniAsHex ***
// Write given Integer value to N_CurMemIni in 0XFF format
//
//     Parameters
// ASectionName - INI file section name
// AIntName     - INI file section key name
// AInt         - Integer value to write
// AMinDigits   - mininal needed number of Hexadecimal Digits
//
// Attempting to write a data value to a nonexistent section or attempting to 
// write data to a nonexistent key are not errors. In these cases, new section 
// and key element will be created.
//
procedure N_IntToMemIniAsHex( ASectionName, AIntName: string; AInt, AMinDigits: integer );
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  N_CurMemIni.WriteString( ASectionName, AIntName, '0X' + IntToHex( AInt, AMinDigits ) );
end; // end of procedure N_IntToMemIniAsHex

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MemIniToIntFromHex
//**************************************************** N_MemIniToIntFromHex ***
// Retrieve an Integer value from N_CurMemIni in any Hex format
//
//     Parameters
// ASectionName - INI file section name
// AIntName     - INI file section key name
// ADefVal      - INI file section key default value
// Result       - Returns INI file section key value as Integer if section and 
//                key exist, else ADefVal returns.
//
// Supported Hex formats: 0xF 0Xf $F F (empty string means 0)
//
function N_MemIniToIntFromHex( ASectionName, AIntName: string; ADefVal: Integer ): integer;
var
  Str: string;
begin
  if N_CurMemIni = nil then // N_CurMemIni was not initialized
    Result := ADefVal
  else
  begin
    Str := N_CurMemIni.ReadString( ASectionName, AIntName, N_NotAString );

    if Str = N_NotAString then
      Result := ADefVal
    else // needed Key esists
      Result := N_AnyHexToInt( Str );

  end;
end; // end of function N_MemIniToIntFromHex

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_HexToMemIni
//*********************************************************** N_HexToMemIni ***
// Obsolete N_IntToMemIniAsHex should be used
//
// Write given Integer value to N_CurMemIni in Hexadecimal format
//
//     Parameters
// ASectionName - INI file section name
// AIntName     - INI file section key name
// AInt         - Integer value to write
// AMinDigits   - mininal needed number of Hexadecimal Digits
//
// Section key value should contain Hexadecimal Integer with preceeding '$'
//
// Attempting to write a data value to a nonexistent section or attempting to
// write data to a nonexistent key are not errors. In these cases, new section
// and key element will be created.
//
procedure N_HexToMemIni( ASectionName, AIntName: string; AInt, AMinDigits: integer );
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  N_CurMemIni.WriteString( ASectionName, AIntName, '$' + IntToHex( AInt, AMinDigits) );
end; // end of procedure N_HexToMemIni

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MemIniToHex
//*********************************************************** N_MemIniToHex ***
// Obsolete N_MemIniToIntFromHex should be used
//
// Retrieve a Hexadecimal Integer value from N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// AIntName     - INI file section key name
// ADefVal      - INI file section key default value
// Result       - Returns INI file section key value as Integer if section and
//                key exist, else ADefVal returns.
//
function N_MemIniToHex( ASectionName, AIntName: string; ADefVal: Integer ): integer;
begin
  if N_CurMemIni = nil then // N_CurMemIni was not initialized
    Result := ADefVal
  else
    Result := N_CurMemIni.ReadInteger( ASectionName, AIntName, ADefVal );
end; // end of function N_MemIniToHex

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_BytesToMemIni
//********************************************************* N_BytesToMemIni ***
// Write given Bytes to N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// ABytesName   - INI file section key name
// APBytes      - pointer to byte array starting element
// ANumBytes    - number of byte array elements
//
// Section key value should contain given Bytes as even number of Hexadecimal 
// characters
//
// Attempting to write a data value to a nonexistent section or attempting to 
// write data to a nonexistent key are not errors. In these cases, new section 
// and key element will be created.
//
procedure N_BytesToMemIni( ASectionName, ABytesName: string; APBytes: Pointer; ANumBytes: integer );
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  N_CurMemIni.WriteString( ASectionName, ABytesName,
                                     N_BytesToHexString( APBytes, ANumBytes ) );
end; // end of procedure N_BytesToMemIni

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MemIniToBytes
//********************************************************* N_MemIniToBytes ***
// Retrieve given number of bytes from N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// ABytesName   - INI file section key name
// APBytes      - pointer to resulting byte array starting element
// ANumBytes    - number of byte array elements
//
// Section key value should contain given Bytes as even number of Hexadecimal 
// characters
//
procedure N_MemIniToBytes( ASectionName, ABytesName: string; APBytes: Pointer; ANumBytes: integer );
var
  AvailableBytes: integer;
  Str: string;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  Str := N_CurMemIni.ReadString( ASectionName, ABytesName, '' );
  AvailableBytes := Length(Str) div 2;

  if AvailableBytes < ANumBytes then
    FillChar( APBytes^, ANumBytes, 0 );

  N_HexCharsToBytes( @Str[1], APBytes, ANumBytes );
end; // end of procedure N_MemIniToBytes

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_DblToMemIni
//*********************************************************** N_DblToMemIni ***
// Write given Double value to N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// ADblName     - INI file section key name
// AFmt         - double to string convertion format
// ADbl         - Double value to write
//
// Attempting to write a data value to a nonexistent section or attempting to
// write data to a nonexistent key are not errors. In these cases, new section
// and key element will be created.
//
procedure N_DblToMemIni( ASectionName, ADblName, AFmt: string; ADbl: double );
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  N_CurMemIni.WriteString( ASectionName, ADblName, Format( AFmt, [ADbl] ) );
end; // end of procedure N_DblToMemIni

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MemIniToDbl
//*********************************************************** N_MemIniToDbl ***
// Retrieve a Double value from N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// ADblName     - INI file section key name
// ADefVal      - INI file section key default value
// Result       - Returns INI file section key value as Double if section and
//                key exist, else ADefVal returns.
//
function N_MemIniToDbl( ASectionName, ADblName: string; ADefVal: double ): double;
begin
  if N_CurMemIni = nil then // N_CurMemIni was not initialized
    Result := ADefVal
  else begin
//    Result := N_CurMemIni.ReadFloat( ASectionName, ADblName, ADefVal );
    Result := StrToFloatDef( K_ReplaceCommaByPoint(
        N_CurMemIni.ReadString( ASectionName, ADblName, '' ) ), ADefVal );
  end;
end; // end of function N_MemIniToDbl

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SPLValToMemIni
//******************************************************** N_SPLValToMemIni ***
// Write given record value to N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// AValName     - INI file section key name
// AValue       - record value to write
// ASPLSType    - SPL short (integer) type code of given data
//
// Attempting to write a data value to a nonexistent section or attempting to 
// write data to a nonexistent key are not errors. In these cases, new section 
// and key element will be created.
//
procedure N_SPLValToMemIni( ASectionName, AValName: string; const AValue; ASPLSType: integer );
var
  FullTypeCode: TK_ExprExtType;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  FullTypeCode.All := ASPLSType;
//  N_s := K_SPLValueToString( AValue, FullTypeCode, [] ); // debug

  N_CurMemIni.WriteString( ASectionName, AValName,
                              K_SPLValueToString( AValue, FullTypeCode, [] ) );
end; // end of procedure N_SPLValToMemIni

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MemIniToSPLVal
//******************************************************** N_MemIniToSPLVal ***
// Retrieve a record value from N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// AValName     - INI file section key name
// AValue       - resulting record
// ASPLSType    - SPL short (integer) type code of given data
//
// If given section or key are absent AValue remains unchanged.
//
procedure N_MemIniToSPLVal( ASectionName, AValName: string; var AValue; ASPLSType: integer );
var
  SrcStr, ErrInfo: string;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  SrcStr := N_CurMemIni.ReadString( ASectionName, AValName, '' );
  if SrcStr = '' then Exit;

  ErrInfo := K_SPLValueFromString( AValue, ASPLSType, SrcStr );
  if ErrInfo <> '' then
    raise Exception.Create( 'K_SPLValueFromString error'#13#10 +
                                              ErrInfo + #13#10 + SrcStr );
end; // end of procedure N_MemIniToSPLVal

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ControlToMemIni
//******************************************************* N_ControlToMemIni ***
// Write given Control screen Size and Position to N_CurMemIni
//
//     Parameters
// ASectionName - INI file section name
// AControlName - INI file section key name
// AControl     - Control to save
// AModeStr     - hex flags (starting with  '$') used in N_PlaceTControl
//
// Attempting to write a data value to a nonexistent section or attempting to 
// write data to a nonexistent key are not errors. In these cases, new section 
// and key element will be created.
//
procedure N_ControlToMemIni( ASectionName, AControlName: string; AControl: TControl; AModeStr: string = '' );
var
  Str: string;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  with AControl do
    Str := Format( '%d %d %d %d', [Left, Top, Width, Height] );

  if AModeStr <> '' then
    Str := Str + ' ' + AModeStr;

  N_CurMemIni.WriteString( ASectionName, AControlName, Str );
end; // end of procedure N_ControlToMemIni

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MemIniToControl
//******************************************************* N_MemIniToControl ***
// Retrieve Size and Position of given AControl from N_CurMemIni
//
//     Parameters
// ASectionName - Section Name in N_CurMemIni
// AControlName - INI file section key name
// AControl     - given AControl to set Size and Position
// Result       - Returns TRUE if given section and key exist
//
function N_MemIniToControl( ASectionName, AControlName: string; AControl: TControl ): boolean;
var
  Mode: integer;
  Origin, Size: TPoint;
  Str: string;
begin
  Result := False;
  if N_CurMemIni = nil then Exit; // N_CurMemIni was not initialized

  Str := N_CurMemIni.ReadString( ASectionName, AControlName, '!Absent!' );

  if Str <> '!Absent!' then
  begin
    Result := True;
    Origin := N_ScanIPoint( Str );
    Size   := N_ScanIPoint( Str );

    if Trim( Str ) = '' then // CRect is needed control coords
    begin
      with AControl do
      begin
        Left   := Origin.X;
        Top    := Origin.Y;
        Width  := Size.X;
        Height := Size.Y;
      end;
    end else // Position mode is given, use N_PlaceTControl
    begin
      Mode := StrToInt( Str );
      N_PlaceTControl( AControl, Mode, Size.X, Size.Y );
    end;
  end; // if Str <> '!Absent!' then

end; // function N_MemIniToControl

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_4IntToMemIni
//********************************************************** N_4IntToMemIni ***
// Write given four integers N_CurMemIni
//
//     Parameters
// ASectionName             - INI file section name
// AIntsName                - INI file section key name
// AInt1, AInt2,AInt3,AInt4 - Integers to save
//
// Attempting to write a data value to a nonexistent section or attempting to 
// write data to a nonexistent key are not errors. In these cases, new section 
// and key element will be created.
//
procedure N_4IntToMemIni( ASectionName, AIntsName: string; AInt1, AInt2, AInt3, AInt4: integer );
var
  Str: string;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  Str := Format( '%d %d %d %d', [AInt1,AInt2,AInt3,AInt4] );

  N_CurMemIni.WriteString( ASectionName, AIntsName, Str );
end; // end of procedure N_4IntToMemIni

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MemIniTo4Int
//********************************************************** N_MemIniTo4Int ***
// Retrieve four integers from N_CurMemIni
//
//     Parameters
// ASectionName             - Section Name in N_CurMemIni
// AIntsName                - INI file section key name
// AInt1, AInt2,AInt3,AInt4 - Integers to Retrieve
// Result                   - Returns TRUE if given section and key exist
//
function N_MemIniTo4Int( ASectionName, AIntsName: string; var AInt1, AInt2, AInt3, AInt4: integer ): boolean;
var
  Str: string;
begin
  Result := False;
  if N_CurMemIni = nil then Exit; // N_CurMemIni was not initialized

  Str := N_CurMemIni.ReadString( ASectionName, AIntsName, '!Absent!' );

  if Str <> '!Absent!' then
  begin
    Result := True;
    AInt1 := N_ScanInteger( Str );
    AInt2 := N_ScanInteger( Str );
    AInt3 := N_ScanInteger( Str );
    AInt4 := N_ScanInteger( Str );
  end; // if Str <> '!Absent!' then

end; // function N_MemIniTo4Int

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_RectToMemIni
//********************************************************** N_RectToMemIni ***
// Write given Rect to N_CurMemIni (in Left Top Width Height format)
//
//     Parameters
// ASectionName - INI file section name
// ARectName    - INI file section key name
// ARect        - Rect to save
//
// Attempting to write a data value to a nonexistent section or attempting to 
// write data to a nonexistent key are not errors. In these cases, new section 
// and key element will be created.
//
procedure N_RectToMemIni( ASectionName, ARectName: string; const ARect: TRect );
var
  Str: string;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  with ARect do
    Str := Format( '%d %d %d %d', [Left, Top, Right-Left+1, Bottom-Top+1] );

  N_CurMemIni.WriteString( ASectionName, ARectName, Str );
end; // end of procedure N_RectToMemIni

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MemIniToRect
//********************************************************** N_MemIniToRect ***
// Retrieve Rect (in Left Top Width Height format) from N_CurMemIni
//
//     Parameters
// ASectionName - Section Name in N_CurMemIni
// AIntsName    - INI file section key name
// ARect        - Rect to Retrieve
// Result       - Returns TRUE if given section and key exist
//
function N_MemIniToRect( ASectionName, ARectName: string; var ARect: TRect ): boolean;
var
  Str: string;
begin
  Result := False;
  if N_CurMemIni = nil then Exit; // N_CurMemIni was not initialized

  Str := N_CurMemIni.ReadString( ASectionName, ARectName, '!Absent!' );

  if Str <> '!Absent!' then
  with AREct do
  begin
    Result := True;
    Left   := N_ScanInteger( Str );
    Top    := N_ScanInteger( Str );
    Right  := N_ScanInteger( Str ); // it is Width!
    if Right <> N_NotAnInteger then
      Right := Left + Right - 1;
    Bottom := N_ScanInteger( Str ); // it is Height!
    if Bottom <> N_NotAnInteger then
      Bottom := Top + Bottom - 1;
  end; // if Str <> '!Absent!' then

end; // function N_MemIniToRect

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MemIniToRect2
//********************************************************* N_MemIniToRect2 ***
// Retrieve Rect (in Left Top Width Height format) from N_CurMemIni
//
//     Parameters
// ASectionName - Section Name in N_CurMemIni
// AIntsName    - INI file section key name
// ATopLeft     - Rect TopLeft coords
// ASize        - Rect Sizes
// Result       - Returns TRUE if given section and key exist
//
// if Result is False then all out values are set to N_NotAnInteger value
//
function N_MemIniToRect2( ASectionName, ARectName: string; var ATopLeft, ASize: TPoint ): boolean;
var
  Str: string;
Label Notgiven;
begin
  if N_CurMemIni = nil then goto Notgiven; // N_CurMemIni was not initialized

  Str := N_CurMemIni.ReadString( ASectionName, ARectName, '!Absent!' );
  if Str = '!Absent!' then goto Notgiven; // ARectName key is absent

  Result := True;
  ATopLeft := N_ScanIPoint( Str );
  ASize    := N_ScanIPoint( Str );
  Exit;

  Notgiven:
  Result   := False;
  ATopLeft := N_NotAnIntPoint;
  ASize    := N_NotAnIntPoint;
end; // function N_MemIniToRect2

//********************************************** N_CLBToMemIni ***
// Save Values of given CheckListBox Description as ttfttff ... string
//
procedure N_CLBToMemIni( ASectionName, ACLBName: string; ACLBDescr: array of TN_CLBItem );
var
  i: integer;
  Str: string;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  SetLength( Str, Length(ACLBDescr) );

  for i := 1 to Length(ACLBDescr) do
  with ACLBDescr[i-1] do
    if CLBValue then Str[i] := 't'
                else Str[i] := 'f';

  N_CurMemIni.WriteString( ASectionName, ACLBName, Str );
end; // end of procedure N_CLBToMemIni

//********************************************** N_MemIniToCLB ***
// Restore Values of given CheckListBox Description from string in MemIni file
//
procedure N_MemIniToCLB( ASectionName, ACLBName: string; var ACLBDescr: array of TN_CLBItem );
var
  i: integer;
  Str: string;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  Str := N_CurMemIni.ReadString( ASectionName, ACLBName, '' );

  for i := 1 to min( Length(ACLBDescr), Length(Str) ) do
  with ACLBDescr[i-1] do
    if Str[i] = 't' then CLBValue := True
                    else CLBValue := False;
end; // end of procedure N_MemIniToCLB


//******************************** TN_MemIniObj class methods ***

//***************************************************** TN_MemIniObj.Create ***
//
constructor TN_MemIniObj.Create();
begin

end; // constructor TN_MemIniObj.Create

//**************************************************** TN_MemIniObj.Destroy ***
// Decrease ListsCounter by 1 for all Actions in Self and
// destroy Actions with ListsCounter = 0
//
destructor TN_MemIniObj.Destroy();
begin

end; // destructor TN_MemIniObj.Destroy

//*********************************************** TN_MemIniObj.WriteSection ***
// Save given AStrings as ASectionName Section content in N_CurMemIni
// (AStrings should have format Name=Value with unique Names!)
//
procedure TN_MemIniObj.WriteSection( ASectionName: string; AStrings: TStrings );
var
  i, n: integer;
  Str, Name, Value: string;
begin
  MemIniFile.EraseSection( ASectionName );

  for i := 0 to AStrings.Count-1 do
  begin
    Str := AStrings.Strings[i];

    //***** get Name and Value parts of Str
    n := Pos( '=', Str );
    if n < 2 then Continue; // Str is not of Name=Value format

    Name := Copy( Str, 1, n-1 );
    Value := Copy( Str, n+1, Length(Str) );

    MemIniFile.WriteString( ASectionName, Name, Value );
  end;
end; // procedure TN_MemIniObj.WriteSection

//************************************************ TN_MemIniObj.ReadSection ***
// Retrieve Section, saved by WriteSection method, from ASectionName Section
// in MemIniFile to given AStrings
// ( copy to Astrings given Section content,
//   Astrings wil be in Name=Value form (as in Section) )
//
procedure TN_MemIniObj.ReadSection( ASectionName: string; AStrings: TStrings );
begin
  MemIniFile.ReadSectionValues( ASectionName, AStrings );
end; // procedure TN_MemIniObj.ReadSection

//**************************************************** TN_MemIniObj.PutBool ***
// Copy given Boolean value in ABoolName item of ASectionName in N_CurMemIni
//
procedure TN_MemIniObj.PutBool( ASectionName, ABoolName: string; ABool: boolean );
var
  Str: string;
begin
  if ABool then Str := 'True'
           else Str := 'False';

  MemIniFile.WriteString( ASectionName, ABoolName, Str );
end; // procedure TN_MemIniObj.PutBool

//**************************************************** TN_MemIniObj.GetBool ***
// return Boolean value from ABoolName item of ASectionName in MemIniFile
// using N_StrToBool (see comments there)
// if ABoolName item is absent in Section, return ADefVal
//
function TN_MemIniObj.GetBool( ASectionName, ABoolName: string;
                                           ADefVal: boolean = False ): boolean;
var
  Str: string;
begin
  Str := MemIniFile.ReadString( ASectionName, ABoolName, '!Absent!' );

  if (Str = '!Absent!') then
    Result := ADefVal
  else
    Result := N_StrToBool( Str );
end; // function TN_MemIniObj.GetBool

//************************************************** TN_MemIniObj.PutString ***
// Copy given string to AStringName item of ASectionName Section in MemIniFile
//
procedure TN_MemIniObj.PutString( ASectionName, AStringName, AString: string );
begin
  MemIniFile.WriteString( ASectionName, AStringName, AString );
end; // end of procedure TN_MemIniObj.PutString

//************************************************** TN_MemIniObj.GetString ***
// return AStringName item of ASectionName Section in MemIniFile
// if AStringName item is absent in Section, return given ADefStr
//
function TN_MemIniObj.GetString( ASectionName, AStringName: string;
                                                   ADefStr: string ): string;
begin
  Result := MemIniFile.ReadString( ASectionName, AStringName, ADefStr );
end; // end of function TN_MemIniObj.GetString

//***************************************************** TN_MemIniObj.PutInt ***
// Copy given AInt to AIntName item of ASectionName Section in MemIniFile
//
procedure TN_MemIniObj.PutInt( ASectionName, AIntName: string; AInt: integer );
begin
  MemIniFile.WriteString( ASectionName, AIntName, IntToStr(AInt) );
end; // end of procedure TN_MemIniObj.PutInt

//***************************************************** TN_MemIniObj.GetInt ***
// return integer AIntName item of ASectionName Section in MemIniFile
//
function TN_MemIniObj.GetInt( ASectionName, AIntName: string; ADefVal: Integer ): integer;
begin
  Result := MemIniFile.ReadInteger( ASectionName, AIntName, ADefVal );
end; // end of function TN_MemIniObj.GetInt

//***************************************************** TN_MemIniObj.PutHex ***
// Copy given AInt to AIntName item of ASectionName Section in MemIniFile
// in Hex format with preceeding '$'
// AMinDigits is mininal needed Number of Hexadecimal Digits
//
procedure TN_MemIniObj.PutHex( ASectionName, AIntName: string; AInt, AMinDigits: integer );
begin
  MemIniFile.WriteString( ASectionName, AIntName, '$' + IntToHex( AInt, AMinDigits) );
end; // end of procedure TN_MemIniObj.PutHex

//*********************************************************** TN_MemIniObj.GetHex ***
// return integer AIntName item of ASectionName Section in MemIniFile
//
function TN_MemIniObj.GetHex( ASectionName, AIntName: string; ADefVal: Integer ): integer;
begin
  Result := N_CurMemIni.ReadInteger( ASectionName, AIntName, ADefVal );
end; // end of function TN_MemIniObj.GetHex

//***************************************************** TN_MemIniObj.PutDbl ***
// Copy given ADbl to ADblName item of ASectionName Section in MemIniFile
// (use AFmt format for Double to string convertion)
//
procedure TN_MemIniObj.PutDbl( ASectionName, ADblName, AFmt: string; ADbl: double );
begin
  MemIniFile.WriteString( ASectionName, ADblName, Format( AFmt, [ADbl] ) );
end; // end of procedure TN_MemIniObj.PutDbl

//***************************************************** TN_MemIniObj.GetDbl ***
// return double AIntName item of ASectionName Section in MemIniFile
//
function TN_MemIniObj.GetDbl( ASectionName, ADblName: string; ADefVal: double ): double;
begin
  Result := MemIniFile.ReadFloat( ASectionName, ADblName, ADefVal );
end; // end of function TN_MemIniObj.GetDbl

//*************************************************** TN_MemIniObj.PutBytes ***
// Copy given number of Bytes to ABytesName item of ASectionName Section in MemIniFile
// as even number of Hex characters
//
procedure TN_MemIniObj.PutBytes( ASectionName, ABytesName: string; APBytes: Pointer; ANumBytes: integer );
begin
  MemIniFile.WriteString( ASectionName, ABytesName,
                                     N_BytesToHexString( APBytes, ANumBytes ) );
end; // end of procedure TN_MemIniObj.PutBytes

//*************************************************** TN_MemIniObj.GetBytes ***
// Set given number of Bytes from ABytesName item of ASectionName Section in MemIniFile
// (ABytesName should contain even number of Hex characters)
//
procedure TN_MemIniObj.GetBytes( ASectionName, ABytesName: string; APBytes: Pointer; ANumBytes: integer );
var
  AvailableBytes: integer;
  Str: string;
begin
  Str := MemIniFile.ReadString( ASectionName, ABytesName, '' );
  AvailableBytes := Length(Str) div 2;

  if AvailableBytes < ANumBytes then
    FillChar( APBytes^, ANumBytes, 0 );

  N_HexCharsToBytes( @Str[1], APBytes, ANumBytes );
end; // end of procedure TN_MemIniObj.GetBytes

//************************************************* TN_MemIniObj.PutStrings ***
// Save given AStrings to ASectionName Section in MemIniFile
// (strings are saved as StringInd=Strings[StringInd])
//
procedure TN_MemIniObj.PutStrings( ASectionName: string; AStrings: TStrings );
var
  i: integer;
  Str: string;
begin
  MemIniFile.EraseSection( ASectionName );

  for i := 0 to AStrings.Count-1 do
  begin
    Str := AStrings.Strings[i];
    MemIniFile.WriteString( ASectionName, IntToStr(i), Str );
  end;
end; // end of procedure TN_MemIniObj.PutStrings

//************************************************* TN_MemIniObj.GetStrings ***
// Retrieve strings, saved by N_StringsToMemIni, from ASectionName Section
// in MemIniFile to given AStrings
// (Name part of MemIni strings is ignored (removed))
//
procedure TN_MemIniObj.GetStrings( ASectionName: string; AStrings: TStrings );
var
  i, n: integer;
  Str: string;
  WrkSL: TStringList;
begin
  WrkSL := TStringList.Create();
  MemIniFile.ReadSectionValues( ASectionName, WrkSL );
  AStrings.Clear();

  for i := 0 to WrkSL.Count-1 do
  begin
    Str := WrkSL.Strings[i];
    n := Pos( '=', Str );
    Str := Copy( Str, n+1, Length(Str) );
      AStrings.Add( Str );
  end;

  WrkSL.Free;
end; // end of procedure TN_MemIniObj.GetStrings

//*********************************************** TN_MemIniObj.SetTopString ***
// Set given ATopString as initial (Top) String in ASectionName
//
procedure TN_MemIniObj.SetTopString( ASectionName, ATopString: string; AMaxListSize: integer );
var
  TmpSL: TStringList;
begin
  TmpSL := TStringList.Create();
  GetStrings( ASectionName, TmpSL );
  N_AddUniqStrToTop( TmpSL, ATopString, AMaxListSize );
  PutStrings( ASectionName, TmpSL );
  TmpSL.Free;
end; // end of procedure TN_MemIniObj.SetTopString

//************************************************* TN_MemIniObj.PutControl ***
// Save Size and Position of given AControl to MemIniFile
// in ASectionName section with AControlName ItemName
//
procedure TN_MemIniObj.PutControl( ASectionName, AControlName: string; AControl: TControl );
var
  Str: string;
begin
  with AControl do
    Str := Format( '%d %d %d %d', [Left, Top, Width, Height] );

  MemIniFile.WriteString( ASectionName, AControlName, Str );
end; // end of procedure TN_MemIniObj.PutControl

//************************************************* TN_MemIniObj.GetControl ***
// Set Size and Position of given AControl from MemIniFile
// (from ASectionName section, AControlName ItemName)
//
procedure TN_MemIniObj.GetControl( ASectionName, AControlName: string; AControl: TControl );
var
  Str: string;
begin
  Str := MemIniFile.ReadString( ASectionName, AControlName, '!Absent!' );

  if Str <> '!Absent!' then with AControl do
  begin
    Left   := N_ScanInteger( Str );
    Top    := N_ScanInteger( Str );
    Width  := N_ScanInteger( Str );
    Height := N_ScanInteger( Str );
  end;
end; // end of procedure TN_MemIniObj.GetControl

//************************************************ TN_MemIniObj.PutComboBox ***
// Save given ComboBox Items to given ASectionName in MemIniFile
//
procedure TN_MemIniObj.PutComboBox( ASectionName: string; AComboBox: TComboBox );
begin
  N_AddTextToTop( AComboBox );
  PutStrings( ASectionName, AComboBox.Items );
end; // end of procedure TN_MemIniObj.PutComboBox

//************************************************ TN_MemIniObj.GetComboBox ***
// Load given ComboBox Items from given ASectionName in MemIniFile,
// ignoring empty Items - they cause exception in Windows kernel !
//
procedure TN_MemIniObj.GetComboBox( ASectionName: string; AComboBox: TComboBox );
var
  i: integer;
  Str: string;
  WrkSL: TStringList;
begin
  WrkSL := TStringList.Create();
  GetStrings( ASectionName, WrkSL );

  AComboBox.Items.Clear();

  for i := 0 to WrkSL.Count-1 do
  begin
    Str := WrkSL.Strings[i];
    if Str <> '' then
      AComboBox.Items.Add( Str );
  end;

  WrkSL.Free;
  if AComboBox.Items.Count >= 1 then
    AComboBox.ItemIndex := 0
  else
    AComboBox.Text := '';
end; // end of procedure TN_MemIniObj.GetComboBox

//***************************************************** TN_MemIniObj.PutCLB ***
// Save Values of given CheckListBox Description as ttfttff ... string
//
procedure TN_MemIniObj.PutCLB( ASectionName, ACLBName: string; ACLBDescr: array of TN_CLBItem );
var
  i: integer;
  Str: string;
begin
  SetLength( Str, Length(ACLBDescr) );

  for i := 1 to Length(ACLBDescr) do
  with ACLBDescr[i-1] do
    if CLBValue then Str[i] := 't'
                else Str[i] := 'f';

  MemIniFile.WriteString( ASectionName, ACLBName, Str );
end; // end of procedure TN_MemIniObj.PutCLB

//***************************************************** TN_MemIniObj.GetCLB ***
// Restore Values of given CheckListBox Description from string in MemIni file
//
procedure TN_MemIniObj.GetCLB( ASectionName, ACLBName: string; var ACLBDescr: array of TN_CLBItem );
var
  i: integer;
  Str: string;
begin
  Str := MemIniFile.ReadString( ASectionName, ACLBName, '' );

  for i := 1 to min( Length(ACLBDescr), Length(Str) ) do
  with ACLBDescr[i-1] do
    if Str[i] = 't' then CLBValue := True
                    else CLBValue := False;
end; // end of procedure TN_MemIniObj.GetCLB

//************************************************** TN_MemIniObj.PutSPLVal ***
// Copy given AValue to AValName item of ASectionName Section in MemIniFile
// given ASPLSType is SPL short (integer) type of given AValue
//
procedure TN_MemIniObj.PutSPLVal( ASectionName, AValName: string; const AValue; ASPLSType: integer );
var
  FullTypeCode: TK_ExprExtType;
begin
  FullTypeCode.All := ASPLSType;
  N_s := K_SPLValueToString( AValue, FullTypeCode, [] ); // debug

  MemIniFile.WriteString( ASectionName, AValName,
                              K_SPLValueToString( AValue, FullTypeCode, [] ) );
end; // end of procedure TN_MemIniObj.PutSPLVal

//************************************************** TN_MemIniObj.GetSPLVal ***
// Set given AValue from AValName item of ASectionName Section in MemIniFile
// given ASPLSType is SPL short (integer) type of given AValue
// if AValName item is absent AValue remains unchanged
//
procedure TN_MemIniObj.GetSPLVal( ASectionName, AValName: string; var AValue; ASPLSType: integer );
var
  SrcStr, ErrInfo: string;
begin
  SrcStr := MemIniFile.ReadString( ASectionName, AValName, '' );
  if SrcStr = '' then Exit;

  ErrInfo := K_SPLValueFromString( AValue, ASPLSType, SrcStr );
  if ErrInfo <> '' then
    raise Exception.Create( 'K_SPLValueFromString error'#13#10 +
                                              ErrInfo + #13#10 + SrcStr );
end; // end of procedure TN_MemIniObj.GetSPLVal






//********************************************** N_GetGlobName ***
// Get Value part of a string in N_GlobNames section og Ini File
// with given AName string part
//
function N_GetGlobName( AName: string ): string;
begin
  Result := N_MemIniToString( 'N_GlobNames', AName );
end; // end of procedure N_GetGlobName

//********************************************** N_EnumDescrToMemIni ***
// Save Values of given EnumDescr as ElemInd=ElemName strings in given Section
//
procedure N_EnumDescrToMemIni( ASectionName: string; AEnumDescr: TN_ENumElems );
var
  i: integer;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  N_CurMemIni.EraseSection( ASectionName );
  N_CurMemIni.WriteString( ASectionName, 'Ind', IntToStr(AEnumDescr[0].ENEInd) );

  for i := 1 to High(AEnumDescr) do
  with AEnumDescr[i] do
    N_CurMemIni.WriteString( ASectionName, IntToStr(ENEInd), ENEName );

end; // end of procedure N_EnumDescrToMemIni

//********************************************** N_MemIniToEnumDescr ***
// Restore Values EnumDescr from given Section
//
procedure N_MemIniToEnumDescr( ASectionName: string; var AEnumDescr: TN_ENumElems );
var
  i, n: integer;
  Str: string;
  WrkSL: TStringList;
begin
  if N_CurMemIni = nil then Exit; // N_CurMemIni was already destroyed

  WrkSL := TStringList.Create();
  N_CurMemIni.ReadSectionValues( ASectionName, WrkSL );
  SetLength( AEnumDescr, WrkSL.Count );
  AEnumDescr[0].ENEInd := StrToInt(WrkSL.Values['Ind']);

  for i := 1 to WrkSL.Count-1 do
  with AEnumDescr[i] do
  begin
    Str := WrkSL.Strings[i];
    n := Pos( '=', Str );
    ENEInd  := StrToInt( Copy( Str, 1, n-1 ) );
    ENEName := Copy( Str, n+1, Length(Str) );
  end;

  WrkSL.Free;
end; // end of procedure N_MemIniToEnumDescr

//********************************************** N_EnumDescrToComboBox ***
// Fill given AComboBox by given EnumDescr
//
procedure N_EnumDescrToComboBox( AComboBox: TComboBox; AEnumDescr: TN_ENumElems );
var
  i, Ind: integer;
begin
  AComboBox.Items.Clear();

  for i := 0 to High(AEnumDescr) do
  with AEnumDescr[i] do
  begin
    if ENEName <> '' then
      AComboBox.Items.Add( ENEName );
  end; // with AEnumDescr[i] do for i := 0 to High(AEnumDescr) do

  Ind := AEnumDescr[0].ENEInd;

  if AComboBox.Items.Count > Ind then
    AComboBox.ItemIndex := Ind
  else if AComboBox.Items.Count >= 1 then
    AComboBox.ItemIndex := 0
  else
    AComboBox.Text := '';
end; // end of procedure N_EnumDescrToComboBox

//********************************************** N_GetItemIndex ***
// Get ComboBox ItemIndex by given AEnumInd
//
function N_GetItemIndex( AEnumInd: integer; AEnumDescr: TN_ENumElems ): integer;
var
  i: integer;
begin
  Result := -1;

  for i := 1 to High(AEnumDescr) do
  with AEnumDescr[i] do
  begin
    if AEnumInd = ENEInd then
    begin
      Result := i - 1;
      Exit;
    end;
  end; // with AEnumDescr[i] do for i := 0 to High(AEnumDescr) do
end; // end of procedure N_GetItemIndex

//********************************************** N_GetENumDescrIndex ***
// Get ENum Index by given ComboBox AItemInd
//
function N_GetENumDescrIndex( AItemInd: integer; AEnumDescr: TN_ENumElems ): integer;
begin
  Result := AEnumDescr[AItemInd+1].ENEInd;
end; // end of procedure N_GetENumDescrIndex

//**********************************************  N_GetScreenPixelFormat  ***
// Return Screen PixelFormat
// now does not work!!
//
function N_GetScreenPixelFormat( AForm: TForm ): TPixelFormat;
var
  i, PixColor: integer;
begin
  Result := pf32bit;
  PixColor := AForm.Canvas.Pixels[0,0]; // save
  AForm.Canvas.Pixels[0,0] := $FFFFFF;
  N_i := AForm.Canvas.Pixels[0,0];
//  if AForm.CVanvas.Pixels[0,0] = $
  AForm.Canvas.Pixels[0,0] := PixColor; // restore
  for i := 0 to 100 do
  begin
    AForm.Canvas.Pixels[i,0] := $FF;
    AForm.Canvas.Pixels[i,1] := $FF;
  end;

end; // function N_GetScreenPixelFormat

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_GetBitmapPixValues
//**************************************************** N_GetBitmapPixValues ***
// Get Pixel Values from given Bitmap
//
//     Parameters
// ABitmap    - given Bitmap (with pf1bit, pf16bit or pf32bit pixel format)
// APixValues - byte array to which Bitmap's pixel values should be added
//
procedure N_GetBitmapPixValues( ABitmap: TBitMap; var APixValues: TN_BArray );
var
  i, BytesInLine, BegInd: integer;
  TmpPtr: PByte;
begin
  BytesInLine := 0; // to avoid warning
  case ABitmap.PixelFormat of
  pf1bit:  BytesInLine := ABitmap.Width div 8 + 1;
  pf16bit: BytesInLine := ABitmap.Width * 2;
  pf32bit: BytesInLine := ABitmap.Width * 4;
  else
    Assert( False, 'not supported' );
  end; // case Bitmap.PixelFormat of

  BegInd := Length(APixValues);
  SetLength( APixValues, BegInd + BytesInLine*ABitmap.Height );

  for i := 0 to ABitmap.Height-1 do
    move( PByte(ABitmap.ScanLine[i])^, APixValues[BegInd+i*BytesInLine], BytesInLine );

  if ABitmap.PixelFormat = pf1bit then // reverse monchrome PixValues
  begin
    TmpPtr := PByte(@APixValues[BegInd]);
    for i := 0 to BytesInLine*ABitmap.Height-1 do
    begin
      TmpPtr^ := TmpPtr^ xor $FF;
      Inc(TmpPtr);
    end;
  end;

end; // end of procedure N_GetBitmapPixValues

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_CreateBitmapByPixValues
//*********************************************** N_CreateBitmapByPixValues ***
// Create Bitmap by given pixels values in memory
//
//     Parameters
// ABegPtr      - Pointer to initial (Upper Left) byte
// AWidth       - Bitmap Width in pixels
// AHeight      - Bitmap Height in pixels
// APixelFormat - Pixel Format (only pf1bit, pf16bit or pf32bit are supported)
//
function N_CreateBitmapByPixValues( ABegPtr: Pointer; AWidth,
                   AHeight: integer; APixelFormat: TPixelFormat ): TBitmap;
var
  i, BytesInLine: integer;
  TmpPtr: PByte;
begin
  Result := TBitmap.Create;
  Result.Width  := AWidth;
  Result.Height := AHeight;
  Result.PixelFormat := APixelFormat;

  BytesInLine := 0; // to avoid warning
  case APixelFormat of
  pf1bit:  BytesInLine := AWidth div 8 + 1;
  pf16bit: BytesInLine := AWidth * 2;
  pf32bit: BytesInLine := AWidth * 4;
  else
    Assert( False, 'not supported' );
  end; // case Bitmap.PixelFormat of

  if APixelFormat = pf1bit then // temporary reverse monchrome PixValues
  begin
    TmpPtr := PByte(ABegPtr);
    for i := 0 to BytesInLine*AHeight-1 do
    begin
      TmpPtr^ := TmpPtr^ xor $FF;
      Inc(TmpPtr);
    end;
  end;

  for i := 0 to AHeight-1 do
    move( (TN_BytesPtr(ABegPtr)+i*BytesInLine)^, Result.ScanLine[i]^, BytesInLine );

  if APixelFormat = pf1bit then // restore (reverse back)
  begin
    TmpPtr := PByte(ABegPtr);
    for i := 0 to BytesInLine*AHeight-1 do
    begin
      TmpPtr^ := TmpPtr^ xor $FF;
      Inc(TmpPtr);
    end;
  end;

end; // function N_CreateBitmapByPixValues

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_AddList
//*************************************************************** N_AddList ***
// Add all items of given List to reslting List
//
//     Parameters
// ADstList - source items List
// ASrcList - resulting items List
//
procedure N_AddList( ADstList, ASrcList: TList );
var
  i: integer;
begin
  for i := 0 to ASrcList.Count-1 do
  begin
    ADstList.Add( ASrcList.Items[i] );
  end;
end; // end of procedure N_AddList

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_CreateFilesList
//******************************************************* N_CreateFilesList ***
// Create List of TN_FileAttribs objects for one Windows Directory
//
//     Parameters
// APattern - retrieve files name pattern, may be with wildcards (C:\tmp\*.tmp)
// Result   - Returnes ObjectList (TObjectList) with Directory elements 
//            attributes.
//
// Use given folder files without subfolders recursion.
//
function N_CreateFilesList( APattern: string ): TObjectList;
var
  SearchFlags: integer;
  BaseDir: string;
  SearchRec: TSearchRec;
  FAObj: TN_FileAttribs;

  procedure AddFAObj(); // local
  begin
    FAObj := TN_FileAttribs.Create;
    with FAObj, SearchRec do
    begin
      if (Name = '.') or (Name = '..') then
      begin
        FAObj.Free;
        Exit;
      end;
      FullName  := BaseDir + Name;
      AttrFlags := Attr;
      BSize     := Size;
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
      DTime     := SearchRec.TimeStamp;
{$ELSE}         // Delphi 7 or Delphi 2010
      DTime     := FileDateToDateTime( SearchRec.Time );
{$IFEND CompilerVersion >= 26.0}
    end;

    N_d := Time;
    Result.Add( FAObj );
  end; // procedure AddFAObj(); // local

begin // body of N_CreateFileAttrList
  SearchFlags := faAnyFile;
  BaseDir := ExtractFilePath( APattern );

  if 0 <> FindFirst( APattern, SearchFlags, SearchRec ) then
  begin
    Result := nil; // not found
    Exit;
  end;

  Result := TObjectList.Create;
  AddFAObj();

  while 0 = FindNext( SearchRec ) do AddFAObj();

  FindClose( SearchRec );
end; // end of function N_CreateFilesList

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_DeleteFilesList
//******************************************************* N_DeleteFilesList ***
// Delete all files and folders, listed in given List
//
//     Parameters
// AFAObjList - List of TN_FileAttribs with file attributes to delete
//
// AFAObjList should be created by N_CreateFilesList function.
//
procedure N_DeleteFilesList( AFAObjList: TObjectList );
var
  i: integer;
begin
  for i := 0 to AFAObjList.Count-1 do
  with TN_FileAttribs( AFAObjList[i] ) do
  begin
    // later add processing for ReadOnly files
    if (AttrFlags and faDirectory) = 0 then
      DeleteFile( FullName )
    else
    begin
      N_DeleteFiles( FullName + '\*.*', 1 );
      RemoveDirectory( PChar(FullName) );
    end;
  end; // for, with
end; // end of procedure N_DeleteFilesList

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_DeleteFiles
//*********************************************************** N_DeleteFiles ***
// Delete files and folders, by given file name pattern and flags
//
//     Parameters
// APattern  - retrieve files name pattern, may be with wildcards (C:\tmp\*.tmp)
// ADelFlags - delete flags:
//#F
//      bit0($01) =1 - subfolders recursion flag
//#/F
//
procedure N_DeleteFiles( APattern: string; ADelFlags: integer );
var
  i: integer;
  BaseDir, BaseName: string;
  FAObjList: TObjectList;
begin
  FAObjList := N_CreateFilesList( APattern );
  if FAObjList <> nil then
  begin
    N_DeleteFilesList( FAObjList );
    FAObjList.Free;
  end;

  if (ADelFlags and $01) <> 0 then // recurse Directories
  begin
    // excluding trailing '\' is needed if dir do not contains needed files,
    // but it's subdirs do contain needed files

    BaseDir := ExcludeTrailingPathDelimiter( ExtractFilePath( APattern ) );
    BaseName := ExtractFileName( APattern );
    FAObjList := N_CreateFilesList( BaseDir + '\*.*' );

    if (FAObjList = nil) or (FAObjList.Count > 0) then
    begin

      for i := 0 to FAObjList.Count-1 do
      with TN_FileAttribs( FAObjList[i] ) do
      begin
        if (AttrFlags and faDirectory) = 0 then Continue; // not a dir
        N_DeleteFiles( FullName + '\' + BaseName, 1 );
      end; // for, with
      
    end; // if FAObjList.Count > 0 then

    FAObjList.Free;
  end; // if (DelFlags and $01) <> 0 then // recurse Directories
end; // end of procedure N_DeleteFiles

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_AddFilesAttribs
//******************************************************* N_AddFilesAttribs ***
// Add files given by name pattern and search flags info to attributes list
//
//     Parameters
// APattern   - retrieve files name pattern, may be with wildcards 
//              (C:\tmp\*.tmp)
// ASFlags    - search flags:
//#F
//      bit0($01) =1 - subfolders recursion flag
//#/F
// AFAObjList - List of TN_FileAttribs with file attributes, if =nil it will be 
//              created
//
// Recurse subfolders.
//
procedure N_AddFilesAttribs( APattern: string; ASFlags: integer;
                                              var AFAObjList: TObjectList );
var
  i: integer;
  BaseDir, BaseName: string;
  TmpObjList: TObjectList;
begin
  if AFAObjList = nil then AFAObjList := TObjectList.Create( True );

  TmpObjList := N_CreateFilesList( APattern );
  if TmpObjList <> nil then
  begin
    TmpObjList.OwnsObjects := False;
    N_AddList( AFAObjList, TmpObjList ); // add TmpObjList items to FAObjList
    TmpObjList.Free;
  end;

  if (ASFlags and $01) <> 0 then // recurse Directories
  begin
    // excluding trailing '\' is needed if dir do not contains needed files,
    // but it's subdirs do contain needed files

    BaseDir := ExcludeTrailingPathDelimiter( ExtractFilePath( APattern ) );
    BaseName := ExtractFileName( APattern );
    if BaseDir = '' then
      TmpObjList := N_CreateFilesList( '*.*' )
    else
      TmpObjList := N_CreateFilesList( BaseDir + '\*.*' );
    TmpObjList.OwnsObjects := False;

    for i := 0 to TmpObjList.Count-1 do
    with TN_FileAttribs( TmpObjList[i] ) do
    begin
      if (AttrFlags and faDirectory) = 0 then Continue; // not a dir
      N_AddFilesAttribs( FullName + '\' + BaseName, 1, AFAObjList );
    end; // for, with

    TmpObjList.Free;
  end; // if (SFlags and $01) <> 0 then // recurse Directories
end; // end of procedure N_AddFilesAttribs

{$WARN SYMBOL_PLATFORM OFF}
//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ClearReadOnlyAttr
//***************************************************** N_ClearReadOnlyAttr ***
// Clear ReadOnly attribute for all files by given name pattern
//
//     Parameters
// APattern - file Pattern with wildcards (e.g. C:\tmp\*.tmp)
// AFlags   - search flags:
//#F
//      bit0($01) =1 - subfolders recursion flag
//#/F
//
procedure N_ClearReadOnlyAttr( APattern: string; AFlags: integer );
var
  i: integer;
  BaseDir, BaseName: string;
  FAObjList: TObjectList;

  procedure ProcessFilesList(); // local
  var
    i: integer;
  begin
    for i := 0 to FAObjList.Count-1 do
    with TN_FileAttribs( FAObjList[i] ) do
    begin
      if (AttrFlags and faReadOnly) <> 0 then
        FileSetAttr( FullName, AttrFlags xor faReadOnly );
    end; // for, with
  end; // procedure ProcessFilesList(); // local

begin // body of procedure N_ClearReadOnlyAttr
  FAObjList := N_CreateFilesList( APattern );
  if FAObjList = nil then Exit; // no obj to delete
  ProcessFilesList();
  FAObjList.Free;

  if (AFlags and $01) <> 0 then // recurse Directories
  begin
    BaseDir  := ExtractFilePath( APattern );
    BaseName := ExtractFileName( APattern );
    FAObjList := N_CreateFilesList( BaseDir + '\*.*' );

    for i := 0 to FAObjList.Count-1 do
    with TN_FileAttribs( FAObjList[i] ) do
    begin
      if (AttrFlags and faDirectory) = 0 then Continue; // not a dir
      N_ClearReadOnlyAttr( FullName + '\' + BaseName, 1 );
    end; // for, with

    FAObjList.Free;
  end; // if (DelFlags and $01) <> 0 then // recurse Directories
end; // end of procedure N_ClearReadOnlyAttr
{$WARN SYMBOL_PLATFORM ON}

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_FillArray(Byte)
//******************************************************* N_FillArray(Byte) ***
// Fill Byte Array by values of geometric progression
//
//     Parameters
// AnArray   - given Byte Array to fill
// ABegValue - initial value (AnArray[AFirstInd] = ABegValue)
// AStep     - Step between values (AnArray[AFirstInd+1] = ABegValue + AStep)
// ANumVals  - Number of Values (AnArray size will be increased if needed)
// AFirstInd - first AnArray index to fill
//
procedure N_FillArray( var AnArray: TN_BArray; ABegValue, AStep: integer;
                                     ANumVals: integer; AFirstInd: integer = 0 );
var
  i, NeededSize: integer;
begin
  NeededSize := AFirstInd+ANumVals;
  if Length(AnArray) < NeededSize then SetLength( AnArray, NeededSize );

  for i := 0 to ANumVals-1 do
  begin
    AnArray[AFirstInd+i] := (ABegValue + i*AStep) and $FF;
  end;
end; // procedure N_FillArray(Byte)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_FillArray(Int)
//******************************************************** N_FillArray(Int) ***
// Fill Integer Array by values of geometric progression
//
//     Parameters
// AnArray   - given Integer Array to fill
// ABegValue - initial value (AnArray[AFirstInd] = ABegValue)
// AStep     - Step between values (AnArray[AFirstInd+1] = ABegValue + AStep)
// ANumVals  - Number of Values (AnArray size will be increased if needed)
// AFirstInd - first AnArray index to fill
//
procedure N_FillArray( var AnArray: TN_IArray; ABegValue, AStep: integer;
                                     ANumVals: integer; AFirstInd: integer = 0 );
var
  i, NeededSize: integer;
begin
  NeededSize := AFirstInd+ANumVals;
  if Length(AnArray) < NeededSize then SetLength( AnArray, NeededSize );

  for i := 0 to ANumVals-1 do
  begin
    AnArray[AFirstInd+i] := ABegValue + i*AStep;
  end;
end; // procedure N_FillArray(Int)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_FillArray(Float)
//****************************************************** N_FillArray(Float) ***
// Fill Float Array by values of geometric progression
//
//     Parameters
// AnArray   - given Float Array to fill
// ABegValue - initial value (AnArray[AFirstInd] = ABegValue)
// AStep     - Step between values (AnArray[AFirstInd+1] = ABegValue + AStep)
// ANumVals  - Number of Values (AnArray size will be increased if needed)
// AFirstInd - first AnArray index to fill
//
procedure N_FillArray( var AnArray: TN_FArray; ABegValue, AStep: float;
                                     ANumVals: integer; AFirstInd: integer = 0 );
var
  i, NeededSize: integer;
begin
  NeededSize := AFirstInd+ANumVals;
  if Length(AnArray) < NeededSize then SetLength( AnArray, NeededSize );

  for i := 0 to ANumVals-1 do
  begin
    AnArray[AFirstInd+i] := ABegValue + i*AStep;
  end;
end; // procedure N_FillArray(Float)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_FillArray(Double)
//***************************************************** N_FillArray(Double) ***
// Fill Double Array by values of geometric progression
//
//     Parameters
// AnArray   - given Double Array to fill
// ABegValue - initial value (AnArray[AFirstInd] = ABegValue)
// AStep     - Step between values (AnArray[AFirstInd+1] = ABegValue + AStep)
// ANumVals  - Number of Values (AnArray size will be increased if needed)
// AFirstInd - first AnArray index to fill
//
procedure N_FillArray( var AnArray: TN_DArray; ABegValue, AStep: double;
                                     ANumVals: integer; AFirstInd: integer = 0 );
var
  i, NeededSize: integer;
begin
  NeededSize := AFirstInd+ANumVals;
  if Length(AnArray) < NeededSize then SetLength( AnArray, NeededSize );

  for i := 0 to ANumVals-1 do
  begin
    AnArray[AFirstInd+i] := ABegValue + i*AStep;
  end;
end; // procedure N_FillArray(Double)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_FillArray(string)
//***************************************************** N_FillArray(string) ***
// Fill string Array by values of geometric progression with Prefix
//
//     Parameters
// AnArray   - given string Array to fill
// APrefix   - rezulting strings: APrefix + IntToStr(ABegValue + i*Step);
// ABegValue - initial value (AnArray[FirstInd] = ABegValue)
// AStep     - Step between values (AnArray[AFirstInd+1] = ABegValue + AStep)
// ANumVals  - Number of Values (AnArray size will be increased if needed)
// AFirstInd - first AnArray index to fill
//
procedure N_FillArray( var AnArray: TN_SArray; APrefix: string;
               ABegValue, AStep, ANumVals: integer; AFirstInd: integer = 0 );
var
  i, NeededSize: integer;
begin
  NeededSize := AFirstInd+ANumVals;
  if Length(AnArray) < NeededSize then SetLength( AnArray, NeededSize );

  for i := 0 to ANumVals-1 do
  begin
    AnArray[AFirstInd+i] := APrefix + IntToStr(ABegValue + i*AStep);
  end;
end; // procedure N_FillArray(string)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_DeleteArrayElems(Byte)
//************************************************ N_DeleteArrayElems(Byte) ***
// Delete Byte Array Elements
//
//     Parameters
// AnArray  - given Byte Array to delete
// ABegInd  - first deleted element
// ANumInds - number of deleted elements
//
procedure N_DeleteArrayElems( var AnArray: TN_BArray; ABegInd, ANumInds: integer );
var
  MoveSize: integer;
begin
  if AnArray = nil then Exit;
  Assert( (AbegInd >= 0 ) and (AbegInd <= High(AnArray)), 'Bad ABegInd!' );
  if (ABegInd + ANumInds - 1) > High(AnArray) then
    ANumInds := High(AnArray) - ABegInd + 1;

  MoveSize := (High(AnArray)-ABegInd-ANumInds+1)*Sizeof(AnArray[0]);
  if MoveSize > 0 then
    move( AnArray[ABegInd + ANumInds], AnArray[ABegInd], MoveSize );
  SetLength( AnArray, Length(AnArray)-ANumInds );
end; // procedure N_DeleteArrayElems(Byte)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_DeleteArrayElems(Integer)
//********************************************* N_DeleteArrayElems(Integer) ***
// Delete Integer Array Elements
//
//     Parameters
// AnArray  - given Byte Array to delete
// ABegInd  - first deleted element
// ANumInds - number of deleted elements
//
procedure N_DeleteArrayElems( var AnArray: TN_IArray; ABegInd, ANumInds: integer );
var
  MoveSize: integer;
begin
  if AnArray = nil then Exit;
  Assert( (AbegInd >= 0 ) and (AbegInd <= High(AnArray)), 'Bad ABegInd!' );
  if (ABegInd + ANumInds - 1) > High(AnArray) then
    ANumInds := High(AnArray) - ABegInd + 1;

  MoveSize := (High(AnArray)-ABegInd-ANumInds+1)*Sizeof(AnArray[0]);
  if MoveSize > 0 then
    move( AnArray[ABegInd + ANumInds], AnArray[ABegInd], MoveSize );
  SetLength( AnArray, Length(AnArray)-ANumInds );
end; // procedure N_DeleteArrayElems(Integer)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_DeleteArrayElems(Float)
//*********************************************** N_DeleteArrayElems(Float) ***
// Delete Float Array Elements
//
//     Parameters
// AnArray  - given Byte Array to delete
// ABegInd  - first deleted element
// ANumInds - number of deleted elements
//
procedure N_DeleteArrayElems( var AnArray: TN_FArray; ABegInd, ANumInds: integer );
var
  MoveSize: integer;
begin
  if AnArray = nil then Exit;
  Assert( (AbegInd >= 0 ) and (AbegInd <= High(AnArray)), 'Bad ABegInd!' );
  if (ABegInd + ANumInds - 1) > High(AnArray) then
    ANumInds := High(AnArray) - ABegInd + 1;

  MoveSize := (High(AnArray)-ABegInd-ANumInds+1)*Sizeof(AnArray[0]);
  if MoveSize > 0 then
    move( AnArray[ABegInd + ANumInds], AnArray[ABegInd], MoveSize );
  SetLength( AnArray, Length(AnArray)-ANumInds );
end; // procedure N_DeleteArrayElems(Float)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_DeleteArrayElems(Double)
//********************************************** N_DeleteArrayElems(Double) ***
// Delete Double Array Elements
//
//     Parameters
// AnArray  - given Byte Array to delete
// ABegInd  - first deleted element
// ANumInds - number of deleted elements
//
procedure N_DeleteArrayElems( var AnArray: TN_DArray; ABegInd, ANumInds: integer );
var
  MoveSize: integer;
begin
  if AnArray = nil then Exit;
  Assert( (AbegInd >= 0 ) and (AbegInd <= High(AnArray)), 'Bad ABegInd!' );
  if (ABegInd + ANumInds - 1) > High(AnArray) then
    ANumInds := High(AnArray) - ABegInd + 1;

  MoveSize := (High(AnArray)-ABegInd-ANumInds+1)*Sizeof(AnArray[0]);
  if MoveSize > 0 then
    move( AnArray[ABegInd + ANumInds], AnArray[ABegInd], MoveSize );
  SetLength( AnArray, Length(AnArray)-ANumInds );
end; // procedure N_DeleteArrayElems(Double)

{
//********************************************* N_InsertArrayElems(Integer) ***
// Insert Integer Array items
//
procedure N_InsertArrayElems( var DstArray: TN_IArray; DstBegInd: integer;
                           SrcArray: TN_IArray; SrcBegInd, ANumInds: integer );
begin
//
end; // procedure N_InsertArrayElems(Integer)

//********************************************* N_InsertArrayElems(Double) ***
// Insert Double Array items
//
procedure N_InsertArrayElems( var DstArray: TN_DArray; DstBegInd: integer;
                           SrcArray: TN_DArray; SrcBegInd, ANumInds: integer );
begin

end; // procedure N_InsertArrayElems(Double)
}

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_AddPackedInt
//********************************************************** N_AddPackedInt ***
// Write packed Integer to Memory
//
//     Parameters
// AMemPtr  - pointer to memory where to write packed integers
// AInt     - integer value for packing
// APLength - number of bytes occupied by packed integer value (on input!)
//
// Routine current version packed positive integer value less than 254 to one 
// byte and greater 254 to 5 bytes and increase memory pointer by 1 or by 5. if 
// APLength is equal to 5 then always use 5 bytes format
//
procedure N_AddPackedInt( var AMemPtr: TN_BytesPtr; AInt: integer; APLength: integer );
begin
  if (0 <= AInt) and (AInt < 255) and (APLength <> 5) then
  begin
    AMemPtr^ := TN_Byte(AInt); Inc(AMemPtr);
  end else
  begin
    AMemPtr^ := TN_Byte(255); Inc(AMemPtr);
    PInteger(AMemPtr)^ := AInt; Inc( AMemPtr, 4);
  end;
end; // procedure N_AddPackedInt

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_GetPackedInt
//********************************************************** N_GetPackedInt ***
// Pop packed Integer from Memory
//
//     Parameters
// AMemPtr - pointer to memory where packed integer is allocated
// Result  - Returns unpacked integer value and push memory pointer to next 
//           packed integer.
//
// Unpacked integer should be pushed to memory by N_AddPackedInt.
//
function N_GetPackedInt( var AMemPtr: TN_BytesPtr ): integer;
begin
  Result := integer(AMemPtr^); Inc(AMemPtr);
  if Result <> 255 then Exit;
  Result := PInteger(AMemPtr)^; Inc( AMemPtr, 4);
end; // function N_AddPackedInt

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_AssignFile(untyped)
//*************************************************** N_AssignFile(untyped) ***
// Assign untyped file in given mode, preserving global FileMode value.
//
//     Parameters
// AFH       - assigned untyped file
// AFileName - file name
// AMode     - file open mode:
//#F
//    fmCreate         = $FFFF;
//    fmOpenRead       = $0000;
//    fmOpenWrite      = $0001;
//    fmOpenReadWrite  = $0002;
//
//    fmShareCompat    = $0000;
//    fmShareExclusive = $0010;
//    fmShareDenyWrite = $0020;
//    fmShareDenyRead  = $0030;
//    fmShareDenyNone  = $0040;
//#/F
//
// AMode = -1 means skip global FileMode value preserving.
//
procedure N_AssignFile( var AFH: File; AFileName: string; AMode: integer = -1 );
var
  SavedFileMode: integer;
begin
  if (AMode = FileMode) or (AMode = -1) then
    AssignFile( AFH, AFileName )
  else
  begin
    SavedFileMode := FileMode;
    FileMode := AMode;
    AssignFile( AFH, AFileName );
    FileMode := byte(SavedFileMode);
  end;
end; // procedure N_AssignFile(untyped)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_AssignFile(text)
//****************************************************** N_AssignFile(text) ***
// Assign text file in given mode, preserving global FileMode value.
//
//     Parameters
// AFH       - assigned text file
// AFileName - file name
// AMode     - file open mode:
//#F
//    fmCreate         = $FFFF;
//    fmOpenRead       = $0000;
//    fmOpenWrite      = $0001;
//    fmOpenReadWrite  = $0002;
//
//    fmShareCompat    = $0000;
//    fmShareExclusive = $0010;
//    fmShareDenyWrite = $0020;
//    fmShareDenyRead  = $0030;
//    fmShareDenyNone  = $0040;
//#/F
//
// AMode = -1 means skip global FileMode value preserving.
//
procedure N_AssignFile( var AFH: TextFile; AFileName: string; AMode: integer = -1 );
var
  SavedFileMode: integer;
begin
  if (AMode = FileMode) or (AMode = -1) then
    AssignFile( AFH, AFileName )
  else
  begin
    SavedFileMode := FileMode;
    FileMode := AMode;
    AssignFile( AFH, AFileName );
    FileMode := byte(SavedFileMode);
  end;
end; // procedure N_AssignFile(text)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ROpenFile(untyped)
//**************************************************** N_ROpenFile(untyped) ***
// Open untyped file for reading
//
//     Parameters
// AFH       - opened untyped file
// AFileName - file name
//
procedure N_ROpenFile( var AFH: File; AFileName: string );
begin
  N_AssignFile( AFH, AFileName, fmOpenRead );
  Reset( AFH, 1 );
end; // procedure N_ROpenFile(untyped)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ROpenFile(text)
//******************************************************* N_ROpenFile(text) ***
// Open text file for reading
//
//     Parameters
// AFH       - opened text file
// AFileName - file name
//
procedure N_ROpenFile( var AFH: TextFile; AFileName: string );
begin
  N_AssignFile( AFH, AFileName, fmOpenRead );
  Reset( AFH );
end; // procedure N_ROpenFile(text)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ShowTextFragment
//****************************************************** N_ShowTextFragment ***
// Show text file tail fragment
//
//     Parameters
// AFileName    - text file name
// AFragmName   - text start marker ('##' + Trim(FragmName))
// AWidth       - text form width
// AHeight      - text form height
// ABaseControl - control near which text form should be shown
//
// Show text file tail fragment from start marker to end of file. Next line 
// after text start marker should contain text form caption.
//
procedure N_ShowTextFragment( AFileName, AFragmName: string;
                        AWidth, AHeight: integer; ABaseControl: TControl );
var
  FH: TextFile;
  Str, SearchPat: string;
begin
  with N_CreateMemoForm( '', nil ) do
  begin

  N_ROpenFile( FH, AFileName );
  SearchPat := '##' + Trim(AFragmName);

  while True do // locate needed fragment
  begin
    if EOF( FH ) then Break;
    ReadLn( FH, Str );
    if Length(Str) < 2 then Continue;

    if (Str[1] = '#') and (Str[2] = '#') then
    begin
      if Str = SearchPat then // needed fragment found
      begin
        ReadLn( FH, Str );
        Caption := Str;

        while True do // read needed fragment into Memo.Lines
        begin
          if EOF( FH ) then Break;
          ReadLn( FH, Str );
          Memo.Lines.Add( Str );
        end; // while True do // read needed fragment into Memo.Lines

        Break;

      end; // if Str = SearchPat then // needed fragment found
    end; // if (Str[1] = '#') and (Str[2] = '#') then

  end; // while True do // locate needed fragment

  ShowModal;
  Close;
  end; // with N_GetMemoForm( AWidth, AHeight, FixedControl ) do
end; // procedure N_ShowTextFragment

//************************************************* N_CreateMenuItem(2*Int) ***
// Create Menu Item in N_CurrentMenu with N_CurMIHandler OnClick handler
//
// AGSInd       - used as GSInd of MenuItem.Caption and as MenuItem Code
// AShortCutKey - ShortCut VirtualKey or -1 if not needed
//
function N_CreateMenuItem( AGSInd: integer; AShortCutKey: integer ): TMenuItem;
begin
  Result := TMenuItem.Create( N_CurrentMenu );
  N_CurrentMenu.Items.Add( Result );
  with Result do
  begin
    Assert( AGSInd < $FFFF, 'Bad AGSInd' );
    Tag     := AGSInd;
    Caption := N_GS( AGSInd );
    OnClick := N_CurMIHandler;
    if AShortCutKey <> -1  then
      ShortCut := Menus.ShortCut( AShortCutKey, [] );
  end;
end; // function N_CreateMenuItem(2*Int)

{
//********************************************** N_CreateMenuItem(Str,Func) ***
// Create new Menu Item with given ACaption and AOnClick - OnClick Handler
//
function N_CreateMenuItem( ACaption: string; AOnClick: TNotifyEvent ): TMenuItem;
begin
  Result := TMenuItem.Create( AMenu );
  with Result do
  begin
    Caption := ACaption;
    OnClick := AOnClick;
  end; // with Result do
end; // function N_CreateMenuItem(Str,Func)
}

//************************************************* N_SetMenuItems ***
// set Visible and Enaled properties for given MenuItems of given Menu
//
// AMenu      - TMainMenu or TPopupMenu with items to setup
// ItemsFlags - open array of Flags (one element per one MenuItem)
//
//  One MenuItem Flags:
//    bits0-15($00FFFF) - Tag value of MenuItem to set,
//                        (=$FFFF (ngsAllMenuItems) means all Menu Items
//    bits16-17($030000) - MenuItem appearence:
//      =$000000 - Visible, Enabled   (N_MIEnable)
//      =$010000 - Visible, Disabled  (N_MIDisable)
//      =$020000 - not Visible        (N_MIHide)
//
procedure N_SetMenuItems( AMenu: TMenu; ItemsFlags: array of integer );
var
  i, j: integer;
begin
  for i := 0 to High(ItemsFlags) do
  begin
    for j := 0 to AMenu.Items.Count-1 do
    begin
      if (AMenu.Items[j].Tag <> (ItemsFlags[i] and $0FFFF)) and
         (   ngsAllMenuItems <> (ItemsFlags[i] and $0FFFF)) then Continue;

      with AMenu.Items[j] do
      begin
        case (ItemsFlags[i] and $030000) shr 16 of
        0: begin Visible := True; Enabled := True; end;
        1: begin Visible := True; Enabled := False; end;
        2: begin Visible := False; end;
        end; // case ItemsFlags[i] and $0F of
      end; // with AMenu.Items[j] do

    end; // for j := 0 to High(AMenu.Items) do
  end; // for i := 0 to High(ItemsFlags) do
end; // procedure N_SetMenuItems

//******************************************************* N_DeleteMenuItems ***
// Delete all MenuItems from given AMenu
//
procedure N_DeleteMenuItems( AMenu: TMenu );
var
  i: integer;
begin
  for i := AMenu.Items.Count-1 downto 0 do
    AMenu.Items[i].Free;
end; // procedure N_DeleteMenuItems

//************************************************* N_GetDebColor ***
// Return some Color that depends upon given AnyInt value (mainly for debug)
// bit4 of Mode ($010) is first N_SysColors index
//
function N_GetDebColor( AnyInt, Mode: integer ): integer;
var
  i, j: integer;
begin
  i := ((Mode shr 4) and $01) mod Length( N_SysColors );
  j := AnyInt mod Length( N_SysColors[i] );
  Result := N_SysColors[i,j];
end; // function N_GetDebColor

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_AddUniqStrToTop
//******************************************************* N_AddUniqStrToTop ***
// Add given string as Top element of given Strings List,
//
//     Parameters
// AList        - given Strings List
// AStr         - adding string
// AMaxListSize - Strings List maximal elements counter
//
// Remove last element if Strings List elements counter is greater than 
// AMaxListSize. If AMaxListSize = 0 then N_MaxItemsCount is used.
//
procedure N_AddUniqStrToTop( AList: TStrings; AStr: string; AMaxListSize: integer );
var
  Ind: integer;
  TrimmedStr: string;
begin
  TrimmedStr := Trim( AStr );
  if Astr = '' then Exit; // is really needed!

  Ind := AList.IndexOf( TrimmedStr );
  if Ind = 0 then Exit; // already on Top
  if Ind > 0 then AList.Delete( Ind );
  AList.Insert( 0, TrimmedStr );

  if AMaxListSize = 0 then
    AMaxListSize := N_MaxItemsCount;

  if (AMaxListSize > 0) and (AList.Count > AMaxListSize) then
    AList.Delete( AList.Count-1 );
end; // procedure N_AddUniqStrToTop

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_AddTextToTop
//********************************************************** N_AddTextToTop ***
// Add ComboBox.Text as Top element of ComboBox.Items
//
//     Parameters
// AComboBox    - given ComboBox
// AMaxListSize - ComboBox.Items maximal elements counter
//
// AComboBox parameter should be of TComboBox type. If AMaxListSize = 0 then 
// N_MaxItemsCount is used (see N_AddUniqStrToTop).
//
procedure N_AddTextToTop( AComboBox: TObject; AMaxListSize: integer );
var
  SavedText: string;
begin
  if not (AComboBox is TComboBox) then Exit; // a precaution

  SavedText := TComboBox(AComboBox).Text; // is needed because changing Items List
                                          // clears AComboBox.Text !!

  if Trim(SavedText) = '' then Exit; // empty items in ComboBox
                                     // cause Windows kernel exception!

  N_AddUniqStrToTop( TComboBox(AComboBox).Items, SavedText, AMaxListSize );
//  TComboBox(AComboBox).Text := SavedText; // restore Text field
  TComboBox(AComboBox).ItemIndex := 0; // just another way to set needed AComboBox.Text
end; // procedure N_AddTextToTop

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_mbKeyDownHandler1
//***************************************************** N_mbKeyDownHandler1 ***
// Standard ComboBox OnKeyDown event Handler routine
//
//     Parameters
// ASender      - event sender, should always be TComboBox
// AKey         - pressed Key code
// AShift       - indicates the state of the Alt, Ctrl, and Shift keys and the 
//                mouse buttons
// AMaxListSize - ComboBox.Items maximal elements counter
//
// Add ComboBox.Text to ComboBox.Items on Enter key press, delete current 
// ComboBox.Text from ComboBox.Items on Ctrl+Delete key press.
//
procedure N_mbKeyDownHandler1( ASender: TObject; AKey: Word;
                               AShift: TShiftState; AMaxListSize: integer = 0 );
var
  Ind: integer;
begin
  if not (ASender is TComboBox) then Exit; // a precaution

  if AKey = VK_RETURN then // add ComboBox.Text to ComboBox.Items
    N_AddTextToTop( TComboBox(ASender), AMaxListSize )
  else if (AKey = VK_DELETE) and (ssCtrl in AShift) then // delete from Items
  with TComboBox(ASender) do
  begin
    Ind := Items.IndexOf( Text );
    if Ind = -1 then Exit; // no such an item
    Items.Delete( Ind );
  end;
end; // procedure N_mbKeyDownHandler1

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_AddOrderedInts
//******************************************************** N_AddOrderedInts ***
// ADD or XOR given ordered integers to given ordered integer array
//
//     Parameters
// AOutSInts    - array of ordered integeres on Input and on Output
// ANumOutSInts - number of elements in AOutSInts on Input and on Output
// APInpSInts   - pointer to first input integer
// ANumInpSInts - number of input integers
// AMode        - =0 - Add; =1 - XOR (add new, exclude existed)
//
// Resulting AOutSInts array remains to be ordered. Global integer array 
// N_Wrk1Ints is used.
//
procedure N_AddOrderedInts( var AOutSInts: TN_IArray; var ANumOutSInts: integer;
                            APInpSInts: PInteger; ANumInpSInts, AMode: integer );
var
  iWrk, iInp, iOut, MinInt, NewLength: integer;
begin
  if ANumInpSInts = 0 then Exit; // no ints to add

  NewLength := ANumOutSInts + ANumInpSInts;

  if Length(AOutSInts) < NewLength then
    SetLength( AOutSInts, N_NewLength(NewLength) );

  if Length(N_Wrk1Ints) < NewLength then
    SetLength( N_Wrk1Ints, N_NewLength(NewLength) );

  iWrk := 0;  iInp := 0;  iOut := 0;

  while (iInp < ANumInpSInts) or (iOut < ANumOutSInts) do
  begin

    if iInp = ANumInpSInts then //****************** no more inp integers
    begin
      MinInt := AOutSInts[iOut];
      Inc(iOut);
    end else if iOut = ANumOutSInts then //********* no more out integers
    begin
      MinInt := APInpSInts^;
      Inc(APInpSInts);
      Inc(iInp);
    end else if APInpSInts^ < AOutSInts[iOut] then // PInpSInts^ < OutSInts[iOut]
    begin
      MinInt := APInpSInts^;
      Inc(APInpSInts);
      Inc(iInp);
    end else //************************************ PInpSInts^ >= OutSInts[iOut]
    begin
      MinInt := AOutSInts[iOut];
      Inc(iOut);
    end;

    N_Wrk1Ints[iWrk] := MinInt;

    if iWrk = 0 then // skip checking N_Wrk1Ints[iWrk-1]
    begin
      Inc(iWrk);
      Continue;
    end; // if iWrk = 0 then

    if Amode = 0 then // Add mode
    begin
      if N_Wrk1Ints[iWrk-1] <> MinInt then
        Inc(iWrk);  // add new integer
    end
    else //************* XOR mode
    begin
      if N_Wrk1Ints[iWrk-1] <> MinInt then
        Inc(iWrk)  // add new integer
      else
        Dec(iWrk); // delete both same integers
    end;

  end; // while (iInp < NumInpSInts) or (iInp < NumInpSInts) do

  ANumOutSInts := iWrk;
  move( N_Wrk1Ints[0], AOutSInts[0], ANumOutSInts*Sizeof(integer) );

end; // procedure N_AddOrderedInts

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SetFormPos
//************************************************************ N_SetFormPos ***
// Set position of given Form
//
//     Parameters
// AForm - given Form
// APos  - given screen pixel coordinates rectangle
//
procedure N_SetFormPos( AForm: TForm; APos: TRect );
begin
  AForm.Left   := Apos.Left;
  AForm.Top    := Apos.Top;
  AForm.Width  := Apos.Right  - Apos.Left + 1;
  AForm.Height := Apos.Bottom - Apos.Top + 1;
end; // procedure N_SetFormPos

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_UTF8
//****************************************************************** N_UTF8 ***
// Convert given string to UTF8 format
//
//     Parameters
// AStr   - given string
// Result - Returns string to UTF8 format
//
function N_UTF8( AStr: string ): string;
var
  ws: WideString;
begin
  ws := AStr;
  Result := String( UTF8Encode( ws ) );
end; // function N_UTF8

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ReplaceStringTail
//***************************************************** N_ReplaceStringTail ***
// Relpace string tail characters by given string
//
//     Parameters
// ASrcName - source string
// ANewLC   - new tail substring
// ANumLC   - number of source string tail characters to replace
// Result   - Returns resulting string
//
function N_ReplaceStringTail( ASrcName, ANewLC: string; ANumLC: integer ): string;
begin
  SetLength( ASrcName, Length(ASrcName) - ANumLC );
  Result := ASrcName + ANewLC;
end; // function N_ReplaceStringTail

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ORToIArray
//************************************************************ N_ORToIArray ***
// Add given value to given Integer Array if not already
//
//     Parameters
// AIArray - Integer Array to add
// AInt    - adding integer value
//
// Integer value should be added to AIArray only if it is absent.
//
procedure N_ORToIArray( var AIArray: TN_IArray; AInt: integer );
var
  i, Leng: integer;
begin
  Leng := Length(AIArray);
  for i := 0 to Leng-1 do
    if AIArray[i] = AInt then Exit;

  SetLength( AIArray, Leng+1 );
  AIArray[Leng] := AInt;
end; // procedure N_ORToIArray

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SearchInIArray
//******************************************************** N_SearchInIArray ***
// Search for given value in given Integer Array
//
//     Parameters
// AInt    - given integer value to search
// AIArray - given integer array to search
// ABegInd - starting array element index to search
// AEndInd - final array element index to search (=-1 means last array element)
// Result  - Returns found array element index or -1 if not.
//
function N_SearchInIArray( AInt: integer; AIArray: TN_IArray;
                           ABegInd: integer = 0; AEndInd: integer = -1 ): integer;
var
  i: integer;
begin
  if AEndInd = -1 then AEndInd := Length(AIArray) - 1;

  for i := ABegInd to AEndInd do
    if AIArray[i] = AInt then
    begin
      Result := i;
      Exit;
    end;

  Result := -1; // not found
end; // function N_SearchInIArray

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SearchInteger
//********************************************************* N_SearchInteger ***
// Search for given value in given Integers
//
//     Parameters
// AInt       - given integer value to search
// APFirstInt - pointer integer array first element
// ABegInd    - starting array element index to search
// AEndInd    - final array element index to search
// Result     - Returns found array element index or -1 if not.
//
// ABegInd and AEndInd are zero based indexes.
//
function N_SearchInteger( AInt: integer; APFirstInt: PInteger;
                                          ABegInd, AEndInd: integer ): integer;
var
  i: integer;
  PCurInt: PInteger;
begin
  PCurInt := APFirstInt;
  Inc( PCurInt, ABegInd );

  for i := ABegInd to AEndInd do // loop along all given Integers
  begin
    if PCurInt^ = AInt then
    begin
      Result := i;
      Exit;
    end;
    Inc( PCurInt ); // to next Integer
  end; // for i := 0 to AEndInd-ABegInd do // loop along all given Integers

  Result := -1; // not found
end; // function N_SearchInteger

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_PushInt
//*************************************************************** N_PushInt ***
// Push given value to Integer Array
//
//     Parameters
// AIArray - given integer array to push
// AInt    - given integer value to push
//
procedure N_PushInt( var AIArray: TN_IArray; AInt: integer );
var
  Leng: integer;
begin
  Leng := Length(AIArray);
  SetLength( AIArray, Leng+1 );
  AIArray[Leng] := AInt;
end; // procedure N_PushInt

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_PopInt
//**************************************************************** N_PopInt ***
// Pop value from Integer Array
//
//     Parameters
// AIArray - given integer array to value pop
// Result  - Returns poped value
//
// Remove and return last AIArray element. If AIArray is empty then -1 should be
// returned.
//
function N_PopInt( var AIArray: TN_IArray ): integer;
var
  Leng: integer;
begin
  Result := -1;
  Leng := Length(AIArray) - 1;

  if Leng = -1 then Exit; // AIArray is empty

  Result := AIArray[Leng];
  SetLength( AIArray, Leng );
end; // function N_PopInt

//******************************************** N_GES ***
// Get Error string
//
function N_GES( ErrorNumber: integer ): string;
begin
  if (ErrorNumber < 0) or (ErrorNumber > High(N_ErrorStrings)) then
    ErrorNumber := 0;

  Result := N_ErrorStrings[ErrorNumber];
end; // function N_GES

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_EditIniFileSection
//**************************************************** N_EditIniFileSection ***
// Edit N_CurMemIni section in Modal mode
//
//     Parameters
// ASectionName - name of INI file section to edit
// Result       - modal result code
//
// If edit dialog modal result wiil be mrOK then N_CurMemIni section should be 
// replaced by new value.
//
function N_EditIniFileSection( ASectionName: string ): integer;
begin
  with N_CreatePlainEditorForm( nil ) do
  begin
    N_ReadMemIniSection( ASectionName, Memo.Lines );
    bnApply.Visible := False;
    Result := ShowModal();
    if Result = mrOK then
      N_WriteMemIniSection( ASectionName, Memo.Lines );
  end; //
end; // function N_EditIniFileSection

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SetCursorType
//********************************************************* N_SetCursorType ***
// Set Cursor Type for dragging Rectangle, it's Side or Corner
//
//     Parameters
// AFlags - dragging Rectangle mode flags (see N_IPointNearIRects for AFlags 
//          description)
//
procedure N_SetCursorType( AFlags: integer );
begin
  if AFlags = 0 then Screen.Cursor := crDefault
  else if (AFlags = $13) or (AFlags = $1C) then Screen.Cursor := crSizeNESW
  else if (AFlags = $16) or (AFlags = $19) then Screen.Cursor := crSizeNWSE
  else if (AFlags = $11) or (AFlags = $14) then Screen.Cursor := crSizeNS
  else if (AFlags = $12) or (AFlags = $18) then Screen.Cursor := crSizeWE
  else if AFlags = $10 then Screen.Cursor := crSizeAll;
end; // procedure N_SetCursorType

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SetMBItems
//************************************************************ N_SetMBItems ***
// Set given ComboBox.Items by given Strings, ItemIndex and Width
//
//     Parameters
// AComboBox - given ComboBox
// AStrings  - array of strings to initialised given ComboBox
// AInpInd   - given ComboBox resulting ItemIndex field
// AMaxWidth - given ComboBox maximal width in pixels
//#F
//  = 0  means that AMaxWidth = current ComboBox width,
//  = -1 means that ComboBox width should not be changed
//#/F
//
// AComboBox width should be defined by largest string, but no more then 
// AMaxWidth.
//
procedure N_SetMBItems( AComboBox: TComboBox; AStrings: array of string;
                                        AInpInd: integer; AMaxWidth: integer );
var
  i, MaxLeng: integer;
  StrSize: TSize;
begin
  MaxLeng := -1;
  AComboBox.Items.Clear();

  for i := 0 to High(AStrings) do
  begin
    AComboBox.Items.Add( AStrings[i] );
    if Length(AStrings[i]) >= 1 then // AStrings[i] may be empty!
    begin
      GetTextExtentPoint32( AComboBox.Canvas.Handle, @AStrings[i][1],
                                             Length(AStrings[i]), StrSize );
      if MaxLeng < StrSize.cx then MaxLeng := StrSize.cx;
    end;
  end; // for i := 0 to High(AStrings) do

  AComboBox.ItemIndex := AInpInd;
  if AMaxWidth = 0 then AMaxWidth := AComboBox.Width;

  if AMaxWidth > 0 then // update AComboBox.Width if needed
  begin
    MaxLeng := Min( AMaxWidth, MaxLeng+25 );
    AComboBox.Width := MaxLeng;
  end; // if AMaxWidth > 0 then
end; // procedure N_SetMBItems

//*********************************************** N_TStart ***
// Create New Timer, Push it to N_TimersStack and Start it
//
procedure N_TStart();
var
  NewTimer: TN_CPUTimer1;
begin
  NewTimer := TN_CPUTimer1.Create();
  N_TimersStack.Add( NewTimer );
  NewTimer.Start();
end; // procedure N_TStart

//*********************************************** N_TStop ***
// Stop last Timer in N_TimersStack, show it's value and remove it from Stack
//
procedure N_TStop( ATimerName: string );
var
  Ind: integer;
  NewTimer: TN_CPUTimer1;
begin
  Ind := N_TimersStack.Count - 1;
  if Ind = -1 then Exit; // a precaution

  NewTimer := TN_CPUTimer1(N_TimersStack.Items[Ind]);
  NewTimer.SS( ATimerName );
  NewTimer.Free();
  N_TimersStack.Delete( Ind );
end; // procedure N_TStop

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_GetNormValues
//********************************************************* N_GetNormValues ***
// Calculate normalized values from given source Double values
//
//     Parameters
// ANormValues - resulting array for normalized values (earch resulting value is
//               calculated as a part of ASumValue)
// ASumValue   - normalized parameter
// APSrcValue  - pointer to first source value
// ANumValues  - number of source values
//
procedure N_GetNormValues( var ANormValues: TN_DArray; ASumValue: double;
                                    APSrcValue: PDouble; ANumValues: integer );
var
  i: integer;
  Sum: double;
  PV: PDouble;
begin
  if ANumValues <= 0 then Exit; // a precaution

  if Length(ANormValues) < ANumValues then
    SetLength( ANormValues, ANumValues );

  Sum := 0;
  PV := APSrcValue;

  for i := 0 to ANumValues-1 do
  begin
    ANormValues[i] := abs( PV^ );
    Sum := Sum + ANormValues[i];
    Inc(PV);
  end; // for i := 0 to ANumValues-1 do

  if Sum = 0 then // a precaution
  begin
    for i := 0 to ANumValues-1 do
      ANormValues[i] := ASumValue / ANumValues;
  end else
  begin
    for i := 0 to ANumValues-1 do
      ANormValues[i] := ANormValues[i] * ASumValue / Sum;
  end;

end; // procedure N_GetNormValues

//*********************************************** N_GetMSPrecision ***
// Return Precision (number of decimal digits) for given ASizeUnit
//
function N_GetMSPrecision( ASizeUnit: TN_MSizeUnit ): integer;
begin
  case ASizeUnit of
    msuUser: Result := 4;
    msuPrc:  Result := 1;
  else
    Result := 0;
  end; // case ASizeUnit of
end; // function N_GetMSPrecision

//***************************************************** N_MakeFullFName2 ***
// Make Full File Name by given Folder Name and File Name
//
function N_MakeFullFName2( AFolder, AFile: string ): string;
begin
  Result := IncludeTrailingPathDelimiter( AFolder ) + AFile;
  Result := K_ExpandFileName( Result );
  K_ForceFilePath( Result );
end; // function N_MakeFullFName2

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_NewLength
//************************************************************* N_NewLength ***
// Calculate array new increased length in advance
//
//     Parameters
// AOldLength - array old length
// AMinLength - minimal resulting length
// Result     - Returns array increased length
//
// Resulting array length should not be less than given mimal value AMinLength.
//
function N_NewLength( AOldLength: integer; AMinLength: integer = 0 ): integer;
begin
  if AOldLength < 16 then
    Result := 20
  else
    Result := AOldLength + AOldLength div 2;

  if Result < AMinLength then Result := AMinLength;
end; // end of function N_NewLength

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_GetScreenRectOfControl
//************************************************ N_GetScreenRectOfControl ***
// Get screen position rectangle of given AControl
//
//     Parameters
// AControl - given Control
// Result   - Return given Control screen position rectangle
//
function N_GetScreenRectOfControl( AControl: TControl ): TRect;
begin
  Result := Rect( AControl.Left, AControl.Top,
             AControl.Left+AControl.Width-1, AControl.Top+AControl.Height-1 );

//  if (AControl.Owner is TForm) and (AControl.Parent <> nil) then
  if AControl.Parent <> nil then
  with AControl.Parent do
  begin
    Result.TopLeft := ClientToScreen( Result.TopLeft );
    Result.BottomRight := ClientToScreen( Result.BottomRight );
  end;

end; // end of function N_GetScreenRectOfControl

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_GetClientRectOfControl
//************************************************ N_GetClientRectOfControl ***
// Get Client position rectangle of given AControl
//
//     Parameters
// AControl - given Control
// Result   - Return given Control Client position rectangle
//
function N_GetClientRectOfControl( AControl: TControl ): TRect;
begin
  with AControl do
    Result := Rect( Left, Top, Left+Width-1, Top+Height-1 );
end; // end of function N_GetClientRectOfControl

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SetClientRectOfControl
//************************************************ N_SetClientRectOfControl ***
// Set Client position rectangle of given AControl by given ARect
//
//     Parameters
// AControl - given Control
// ARect    - given Rectangle
//
procedure N_SetClientRectOfControl( AControl: TControl; ARect: TRect );
begin
  AControl.Left   := ARect.Left;
  AControl.Top    := ARect.Top;
  AControl.Width  := ARect.Right  - ARect.Left + 1;
  AControl.Height := ARect.Bottom - ARect.Top  + 1;
end; // end of procedure N_SetClientRectOfControl

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_PlaceTControl(AFixedControl)
//****************************************** N_PlaceTControl(AFixedControl) ***
// Place given Control near given fixed Control
//
//     Parameters
// AControl      - given Control, that should be placed
// AFixedControl - another given Control, that is used for calculating 
//                 AControl's place
//
// Place given AControl near the given AFixedControl or in the middle of screen 
// if AFixedControl is not given ( =nil )
//
procedure N_PlaceTControl( AControl, AFixedControl: TControl );
var
  TmpRect: TRect;
begin
  if AFixedControl = nil then
//    TmpRect := N_RectSetPos( 4, Screen.WorkAreaRect,
//                              N_ZIRect, AControl.Width, AControl.Height )
    TmpRect := N_RectSetPos( 5, Screen.WorkAreaRect,
                                        N_GetScreenRectOfControl( AControl ), 0, 0 )
  else
    TmpRect := N_RectSetPos( 3, Screen.WorkAreaRect,
                                         N_GetScreenRectOfControl( AFixedControl ),
                                         AControl.Width, AControl.Height );

  AControl.Left := TmpRect.Left;
  AControl.Top  := TmpRect.Top;
  AControl.Width  := N_RectWidth( TmpRect );
  AControl.Height := N_RectHeight( TmpRect );
end; // procedure N_PlaceTControl(AFixedControl)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_PlaceTControl(AMode)
//************************************************** N_PlaceTControl(AMode) ***
// Place given Control (set Size and Position) according to given mode
//
//     Parameters
// AControl - given Control, that should be placed
// AMode    - placing mode (used in N_RectSetPos function)
// AWidth   - given needed AControl's width or 0 if current width is OK
// AHeight  - given needed AControl's height or 0 if current height is OK
//
// Place given AControl using N_RectSetPos function with AFixedRect as one pixel
// Rect in the middle of Screen.WorkAreaRect
//
procedure N_PlaceTControl( AControl: TControl; AMode, AWidth, AHeight: integer );
var
  TmpRect, FixedRect: TRect;
begin
  FixedRect.TopLeft := Point( N_AppWAR.Right div 2,
                                 N_AppWAR.Bottom div 2 );
  FixedRect.BottomRight := FixedRect.TopLeft;

  if AWidth  <= 0 then AWidth  := AControl.Width;
  if AHeight <= 0 then AHeight := AControl.Height;

  TmpRect := N_RectSetPos( AMode, N_AppWAR, FixedRect, AWidth, AHeight );

  AControl.Left := TmpRect.Left;
  AControl.Top  := TmpRect.Top;
  AControl.Width  := N_RectWidth( TmpRect );
  AControl.Height := N_RectHeight( TmpRect );
end; // procedure N_PlaceTControl(AMode)

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ChangeFormSize
//******************************************************** N_ChangeFormSize ***
// Change given Form size by given width and height delta
//
//     Parameters
// AForm - given Form
// ADX   - given Form width delta
// ADY   - given Form height delta
//
// Change size of AForm by ADX, ADY (may be negative) and move it inside Screen 
// (make AForm fully visible)
//
procedure N_ChangeFormSize( AForm: TForm; ADX, ADY: integer );
var
  MaxWidth, MaxHeight, NewWidth, NewHeight: integer;
begin
  MaxWidth  := N_RectWidth( N_AppWAR );
  MaxHeight := N_RectHeight( N_AppWAR );

  NewWidth := Min( MaxWidth, AForm.Width+ADX );
  if NewWidth <> AForm.Width then AForm.Width := NewWidth;
  if AForm.Left < 0 then AForm.Left := 0;

  if (AForm.Left+AForm.Width-1) > N_AppWAR.Right then
    AForm.Left := N_AppWAR.Right - AForm.Width + 1;

  NewHeight := Min( MaxHeight, AForm.Height+ADY );
  if NewHeight <> AForm.Height then AForm.Height := NewHeight;
  if AForm.Top < 0 then AForm.Top := 0;

  if (AForm.Top+AForm.Height-1) > N_AppWAR.Bottom then
    AForm.Top := N_AppWAR.Bottom - AForm.Height + 1;
end; // procedure N_ChangeFormSize

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MakeFormVisible
//******************************************************* N_MakeFormVisible ***
// Adjust given Form Position and Size to make it visible
//
//     Parameters
// AForm  - given Form to adjust
// AFlags - set of flags which controls Form's Position and Size adjust
//
//#F
// Used algorithm:
// - always decrease Form Size by N_AppWAR
// - if fvfCenter flag is set then center AForm and exit
// - if fvfWhole flag is set then shift AForm to make it fully visible,
//   otherwise shift AForm to make at least 48 pixels of AForm visible
//#/F
//
procedure N_MakeFormVisible( AForm: TForm; AFlags: TN_FormVisFlags );
var
  MaxWidth, MaxHeight: integer;
  MaxRect, NewRect: TRect;
begin
  MaxRect := N_AppWAR;

  MaxWidth  := N_RectWidth( MaxRect );
  MaxHeight := N_RectHeight( MaxRect );

  if AForm.Width  > MaxWidth  then AForm.Width  := MaxWidth;
  if AForm.Height > MaxHeight then AForm.Height := MaxHeight;

  if fvfCenter in AFlags then // center AForm in MaxRect
  begin
    AForm.Left := MaxRect.Left + (MaxWidth  - AForm.Width) div 2;
    AForm.Top  := MaxRect.Top  + (MaxHeight - AForm.Height) div 2;
    Exit; // all done
  end; // if fvfCenter in AFlags then


  if not (fvfWhole in AFlags) then // Form can be only partially (at least 48 pixels) visible
    MaxRect := N_RectIncr( MaxRect, AForm.Width-48, AForm.Height-48 );

  NewRect := N_RectAdjustByMaxRect( N_GetScreenRectOfControl( AForm ), MaxRect );

  if AForm.Left <> NewRect.Left then AForm.Left := NewRect.Left;
  if AForm.Top  <> NewRect.Top  then AForm.Top  := NewRect.Top;
end; // procedure N_MakeFormVisible

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MakeFormVisible2
//****************************************************** N_MakeFormVisible2 ***
// Adjust given Form Position and Size to make it visible
//
//     Parameters
// AForm  - given Form to adjust
// AFlags - set of flags which controls Form's Position and Size adjust
//
procedure N_MakeFormVisible2( AForm: TForm; AFlags: TN_RectSizePosFlags );
var
  NewSize, NewPos: TPoint;
  FormRect: TRect;
begin
  FormRect := N_GetScreenRectOfControl( AForm );
  N_CalcRectSizePos( N_RectSize(FormRect), FormRect.TopLeft, AFlags, NewSize, NewPos );

  if AForm.Width  <> NewSize.X then AForm.Width  := NewSize.X;
  if AForm.Height <> NewSize.Y then AForm.Height := NewSize.Y;

  if AForm.Left <> NewPos.X then AForm.Left := NewPos.X;
  if AForm.Top  <> NewPos.Y then AForm.Top  := NewPos.Y;
end; // procedure N_MakeFormVisible2

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_SetMouseCursorType
//**************************************************** N_SetMouseCursorType ***
// Set Mouse Cursor for a given Control
//
//     Parameters
// AControl - given Control for which Cursor should be changed
// ACursor  - given Delphi Cursor
//
procedure N_SetMouseCursorType( AControl: TControl; ACursor: TCursor );
begin
  AControl.Cursor := ACursor;
  Windows.SetCursor( Screen.Cursors[ACursor] ); // force windows to change cursor immediately
end; // procedure N_SetMouseCursorType

{
//****************************************************** N_InitWorkAreaRect ***
// Initialize N_WorkAreaRect from Ini file (obsolete)
//
//
procedure N_InitWorkAreaRect();
var
  i: integer;
  WrkAreaRect: TRect;
begin
  //***** Init N_WorkAreaRect by all monitors

  N_WorkAreaRect := Rect(0,0,0,0);
  for i := 0 to Screen.MonitorCount-1 do
    N_IRectOr( N_WorkAreaRect, Screen.Monitors[i].WorkareaRect );

  WrkAreaRect := N_WorkAreaRect;
  //*** ScreenWorkArea contains Left Top Width Height
  N_MemIniToSPLVal( 'Global', 'ScreenWorkArea', WrkAreaRect, Ord(nptIRect) );

  // Convert Width Height to Right Bootom
  WrkAreaRect.Bottom := WrkAreaRect.Top  + WrkAreaRect.Bottom - 1;
  WrkAreaRect.Right  := WrkAreaRect.Left + WrkAreaRect.Right  - 1;

  // Delphi error or "feature": Right=1280 on 1280x1024 screen (should be 1279 and 1023)
  Dec( N_WorkAreaRect.Bottom );
  Dec( N_WorkAreaRect.Right );

  N_WorkAreaRect := N_RectAdjustByMaxRect( WrkAreaRect, N_WorkAreaRect );
end; // procedure N_InitWorkAreaRect
}

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_InitWAR
//*************************************************************** N_InitWAR ***
// Initialize several Extern Rects
//
// Initialize N_WholeWAR, N_PrimMonWAR and N_AppWAR using Ini file key 
// [Global]ScreenWorkArea and preliminary set N_MainUserFormRect and N_CurMonWAR
// equal to N_PrimMonWAR
//
procedure N_InitWAR();
var
  i, HideMode: integer;
  WrkAreaRect: TRect;
begin
  HideMode := N_MemIniToInt( 'CMS_UserDeb', 'HideMode', -1 );

  //***** Calc N_WholeWAR variable (All Monitors Work Area Rect, Envelope Rect of all monitors)

  N_WholeWAR := N_ZIRect;

  for i := 0 to Screen.MonitorCount-1 do // along all Monitors
  with Screen.Monitors[i] do
  begin
    WrkAreaRect := WorkareaRect; // WorkareaRect is Monitors[i] field

    // Delphi error or "feature": Right and Bottom fields are increased by 1
    Dec( WrkAreaRect.Right );
    Dec( WrkAreaRect.Bottom );

    if Screen.MonitorCount > 1 then // multimonitor computer
    begin
      with WrkAreaRect do
        N_Dump1Str( Format( 'Monitor %d (Primary=%s) WorkareaRect=%d,%d,%d,%d',
                             [i, N_B2S(Primary), Left,Top,Right,Bottom] ) );
    end; // if Screen.MonitorCount > 1 then // multimonitor computer

    N_IRectOr( N_WholeWAR, WrkAreaRect ); // add i-th Monitor  Work Area Rect

    if Primary then
      N_PrimMonWAR := WrkAreaRect; // Primary Monitor Work Area Rect
  end; // for i := 0 to Screen.MonitorCount-1 do // along all Monitors

  //*** N_WholeWAR and are OK,
  //    Set N_AppWAR variable - Application Work Area Rect counting [Global]ScreenWorkArea in Ini file

  //*** [Global]ScreenWorkArea contains Left Top Width Height (not Left Top Bottom Right)
  WrkAreaRect := N_ZIRect;
  N_MemIniToSPLVal( 'Global', 'ScreenWorkArea', WrkAreaRect, Ord(nptIRect) );

  if WrkAreaRect.Right = 0 then // no [Global]ScreenWorkArea in Ini file, use N_WholeWAR
    N_AppWAR := N_WholeWAR
  else // [Global]ScreenWorkArea exists, Convert Width Height to Right Bootom
    N_AppWAR := N_RectMake( WrkAreaRect.TopLeft, WrkAreaRect.BottomRight, N_ZDPoint );

  N_IRectAnd( N_AppWAR, N_WholeWAR ); // Clip N_AppWAR by N_WholeWAR

  N_MainUserFormRect := N_PrimMonWAR; // preliminary value
  N_CurMonWAR        := N_PrimMonWAR; // preliminary value

  N_Dump1Str( Format( 'N_WholeWAR=%d,%d,%d,%d  N_AppWAR=%d,%d,%d,%d HideMode=%d',
             [N_WholeWAR.Left,N_WholeWAR.Top,N_WholeWAR.Right,N_WholeWAR.Bottom,
              N_AppWAR.Left,N_AppWAR.Top,N_AppWAR.Right,N_AppWAR.Bottom, HideMode] ) );

end; // procedure N_InitWAR

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_AddToDumpDlg
//********************************************************** N_AddToDumpDlg ***
// Enter any strings in Dialog and Dump entered strings
//
procedure N_AddToDumpDlg();
var
  NumStrings: integer;
begin
// TN_PlainEditorForm;
  with N_CreatePlainEditorForm( nil ) do
  begin
    Caption := 'Enter text to dump:';
    ShowModal;

    if ModalResult <> mrOK then Exit;
    
    NumStrings := Memo.Lines.Count;
    if NumStrings = 1 then
      N_Dump1Str( 'User Text> ' + Memo.Lines[0] )
    else if NumStrings > 1 then
    begin
      N_Dump1Str( '  User Text:' );
      N_Dump1Strings( Memo.Lines, 2 );
    end;

  end; // with N_CreatePlainEditorForm( nil ) do
end; // procedure N_AddToDumpDlg

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_GetMonWARsAsString
//**************************************************** N_GetMonWARsAsString ***
// Get all Monitors WARs As String
//
//     Parameters
// Result - Return all monitors WARs coords (comma delimited)
//
function N_GetMonWARsAsString(): string;
var
  i: integer;
begin
  Result := ''; // to awoid warning

  for i := 0 to Screen.MonitorCount-1 do // along all Monitors
  with Screen.Monitors[i], WorkareaRect do
    Result := Result + Format( '%d,%d,%d,%d,', [Left,Top,Right,Bottom] );
end; // function N_GetMonWARsAsString

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_GetMonWARByRect
//******************************************************* N_GetMonWARByRect ***
// Get Monitor WAR which has max intersection with given ARect
//
//     Parameters
// ARect          - given Rect (in Screen Pixels)
// APMonitorIndex - Pointer to integer variable for Monitor Index (on output)
// Result         - return found monitor WAR which hase max overlap with given 
//                  ARect
//
function N_GetMonWARByRect( ARect: TRect; APMonitorIndex: PInteger = nil ): TRect;
var
  i: integer;
  CurRect: TRect;
  S, SMax: double;
begin
  SMax := -1;
  Result := N_PrimMonWAR; // to avoid warning

  for i := 0 to Screen.MonitorCount-1 do // along all Monitors
  with Screen.Monitors[i] do
  begin
    CurRect := WorkareaRect;

    // Delphi error or "feature": WorkareaRect Right and Bottom fields are increased by 1
    Dec( CurRect.Right );
    Dec( CurRect.Bottom );

    S := N_IRectsCrossArea( CurRect, ARect );

    if S > SMax then // better monitor found
    begin
      SMax := S;

      if APMonitorIndex <> nil then // Pointer is given
        APMonitorIndex^ := i;

      Result := CurRect;
    end; // if S > SMax then // better monitor found

  end; // for i := 0 to Screen.MonitorCount-1 do // along all Monitors
end; // function N_GetMonWARByRect

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_MonWARsChanged
//******************************************************** N_MonWARsChanged ***
// Return True if current Monitor WARs are not the same as saved in ini file
// [N_Forms].AllMonWARs variable.
//
//     Parameters
// Result - return True if current Monitor WARs are not the same as saved in ini
//          file [N_Forms].AllMonWARs variable
//
function N_MonWARsChanged(): Boolean;
var
  CurMonWARs, SavedMonWARs: string;
begin
  CurMonWARs := N_GetMonWARsAsString();
  Result := True;
  if N_CurMemIni = nil then Exit; // N_CurMemIni was not initialized

  SavedMonWARs := N_CurMemIni.ReadString( 'N_Forms', 'AllMonWARs', '' );
  Result := CurMonWARs <> SavedMonWARs;

  if Result then
    N_Dump1Str( 'SavedMonWARs:' + SavedMonWARs + '  CurMonWARs:' + CurMonWARs );
end; // function N_MonWARsChanged

//##path N_Delphi\SF\N_Tree\N_Lib1.pas\N_ClearSavedFormCoords
//************************************************** N_ClearSavedFormCoords ***
// Clear Saved Form Coords (clear ini file [N_Forms] section)
//
procedure N_ClearSavedFormCoords();
var
  i: integer;
  Str: string;
  SL: TStringList;
begin
  N_CurMemIni.EraseSection( 'N_Forms' );

  if not N_CurMemIni.SectionExists( 'N_FormsInit' ) then Exit;

  //***** Init N_Forms by N_FormsInit section

  Str := N_GetMonWARsAsString();
  N_Dump1Str( 'N_Forms Cleared. AllMonWARs=' + Str );
  N_StringToMemIni( 'N_Forms', 'AllMonWARs', Str ); // save monitors WARs

  SL := TStringList.Create;
  N_CurMemIni.ReadSectionValues( 'N_FormsInit', SL );
  for i := 0 to SL.Count - 1 do
    N_CurMemIni.WriteString( 'N_Forms', SL.Names[i], SL.ValueFromIndex[i] );
  SL.Free;
end; // procedure N_ClearSavedFormCoords

//****************** TN_DumpGlobObj2 class methods  **********************

//*********************************************** TN_DumpGlobObj2.GODump1Str ***
// Save one given AString to Dump1 (to N_Dump1LCInd Logging Channel)
//
//     Parameters
// AString  - String to save
//
// Is used as N_Dump1Str (of TN_OneStrProcObj type)
//
procedure TN_DumpGlobObj2.GODump1Str( AString: string );
var
  LogLevel: Integer;
begin
  LogLevel := N_MemIniToInt( 'CMS_UserDeb', 'LogsLevel', 2 );
  if LogLevel >= 1 then
    N_LCAdd( N_Dump1LCInd, AString );
end; // procedure TN_DumpGlobObj2.GODump1Str

//*********************************************** TN_DumpGlobObj2.GODump2Str ***
// Save one given AString to Dump2 (to N_Dump2LCInd Logging Channel)
//
//     Parameters
// AString  - String to save
//
// Is used as N_Dump2Str (of TN_OneStrProcObj type)
//
procedure TN_DumpGlobObj2.GODump2Str( AString: string );
var
  LogLevel: Integer;
begin
  LogLevel := N_MemIniToInt( 'CMS_UserDeb', 'LogsLevel', 2 );
  if LogLevel >= 2 then
    N_LCAdd( N_Dump2LCInd, AString );
end; // procedure TN_DumpGlobObj2.GODump2Str

//********************************************** TN_DumpGlobObj2.GODump2TStr ***
// Save one given Typed AString to Dump2 (to N_Dump2LCInd Logging Channel)
//
//     Parameters
// AType    - AString Type
// AString  - String to save
//
// Is used as N_Dump2TStr (of TN_OneIOneSProcObj type)
//
procedure TN_DumpGlobObj2.GODump2TStr( AType: integer; AString: string );
begin
  N_LCAddTyped( N_Dump2LCInd, AType, AString );
end; // procedure TN_DumpGlobObj2.GODump2TStr

//************************************************ TN_DumpGlobObj2.GODumpStr ***
// Save one given AString to given ALCInd Logging Channel
//
//     Parameters
// ALCInd   - Logging Channel Index
// AString  - String to save
//
// Is used as N_DumpStr (of TN_OneIOneSProcObj type)
//
procedure TN_DumpGlobObj2.GODumpStr( ALCInd: integer; AString: string );
begin
  N_LCAdd( ALCInd, AString );
end; // procedure TN_DumpGlobObj2.GODumpStr



Initialization
  N_AddStrToFile( 'N_Lib1 Initialization' );

end.

