unit K_CLib0;
// general purpose low level definitions and code
//
// Interface section uses K_Parse, K_Types, N_Types and Delphi units
// Implementation section uses only N_Lib0 and Delphi units

{$WARN SYMBOL_PLATFORM OFF}

interface

uses ActnList, ShellApi, Windows, Classes, IniFiles, SysUtils, Graphics, StdCtrls,
  Dialogs, Forms, Controls, ExtCtrls,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  K_Parse, K_Types,
  N_Types;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_PackJSTextError
type TK_PackJSTextError = class(Exception); // Class for raising Exceptions in K_PackJSText routine

//type TObjectArray = array of TObject;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_FileEncodeMode
type TK_FileEncodeMode  = (  // Text File Coding Mode
   K_femW1251,    // Windows 1251
   K_femUTF8,     // UTF8
   K_femUNICODE,  // UNICODE
   K_femKOI8      // KOI8R
     );

var K_FileEncodeNames : array [0..Ord(K_femKOI8)] of string =
    ( 'windows-1251', 'UTF-8', 'UTF-16', 'KOI8-R');

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_FileEncodeFlags
type TK_FileEncodeFlags  = Set of (  // Text File Coding Flags
   K_fefSkipCR   // Skip Carrige Return ($0D) in the end of Line
     );

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_UndefMacroMode
type TK_UndefMacroMode = ( // Macroprocessing behaviour if MacroName is absent in MacroList
  K_ummPutErrText,    // put special error string to resulting text
  K_ummRemoveMacro,   // remove MacroCall from resulting text
  K_ummSaveMacro,     // save MacroCall in resulting text
  K_ummSaveMacroName, // put MacroName to resulting text
  K_ummRemoveResult   // remove MacroCall from resulting text and remove
                      // resulting string from resulting list while using 
                      // K_SListMListReplace(...)
     );

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRFlags
type TK_MRFlags = Set of ( // Macro Processing Flags
  K_mrfSkipMacroResult,     // skip placing data to resulting text flag
  K_mrfUseInlineMacroValue, // use Macro Value placed directly in Macro Call 
                            // (default value)
  K_mfrSkipResultEmptyLines,// skip empty lines in resulting text
  K_mrfUseOldMacroSep       // enable using old Macro Separators
      );

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRResult
type TK_MRResult = ( // Result Code for TK_MRProcess MacroReplace Routine
  K_mrrUndef,       // given MacroName has no resulting value
  K_mrrOK,          // given MacroName has proper resulting value
  K_mrrSkipNextText // MacroExpression result demands to skip text after given 
                    // MacroExpression
     );

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_CellPos
type TK_CellPos = ( // StringGrid Cell text position flag
  K_ppUndef,    // use align mode according with data type
  K_ppUpLeft,   // align to LEFT or UP
  K_ppCenter,   // align to CENTER or MIDDLE
  K_ppDownRight // align to RIGHT or DOWN
      );

type TK_MRFunc   =  function( AMacroName : string; var AMacroResult : string ) : TK_MRResult of object;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess
//************************************************************ TK_MRProcess ***
// Text Macro Processor
//
// Used for different text processing: simple context replace, Name/Value macro
// replace, text conditional assembling
//
type TK_MRProcess = class;
{type} TK_MRUMFunc = function ( AUMName : string; AMRP : TK_MRProcess ) : string of object;
//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess
{type} TK_MRProcess = class
  CRValue : string;                   // constant MacroResult for 
                                      // ConstValueMRFunc
  MList  : TStrings;                  // strings with Macro Replace context for 
                                      // ValueFromStringsMRFunc
  MacroFlags : TK_MRFlags;            // macro Processing Flags (TK_MRFlags)
  UndefMacroMode : TK_UndefMacroMode; // enum for Undefined MacroResult Case
  MRUndefMacroFunc : TK_MRUMFunc;     // Undefined Macro Name Function of object
  FMRFunc : TK_MRFunc;                // MacroCall processing Routine

//##/*
  FMacroStart : string;               // current start MacroCall substring
  FMacroFin : string;                 // current final MacroCall substring

  constructor Create( AMRStart : string = ''; AMRFin : string = '';
                      AMRFunc : TK_MRFunc = nil );
  destructor  Destroy; override;
//##*/

  function  StringMacroReplace( var AResBuf : string; const ASrcBuf : string;
                                AUsedLength : Integer = 0;
                                APErrNum : PInteger = nil ) : Integer;
  procedure SetMacroStart( const AMRStart : string ); // Set New MacroStart SubString
  procedure SetMacroFin( const AMRFin : string );     // Set New MacroFin SubString
  procedure SetParsingContext( const AMRStart : string = ''; const AMRFin : string = '';
                               AMRFunc : TK_MRFunc = nil );

//*** Replacing Context to Const Values Function
  function  ConstValueMRFunc( MacroName : string; var MacroResult : string ) : TK_MRResult;

//*** Macro Replacing Processor Values from StringList Function
  function  ValueFromStringsMRFunc( MacroName : string; var MacroResult : string ) : TK_MRResult;

//*** Text Assembling Processor
// Assembling MacroExpressions
// MacroExpression ::= if CONDITION end|if CONDITION else end|if CONDITION elseif ...|var VarName = VarValue
// CONDITION ::= EXPRESSION|or and|EXPRESSION
// EXPRESSION ::= EXPRESSION|not EXPRESSION
// EXPRESSION ::= VARIABLE |EQ|NE| VARIABLE or CONSTANT
//
  function  TextAssemblingMRFunc( MacroInstr : string; var MacroResult : string ) : TK_MRResult;
  procedure AddTextAssemblingVar( NameAndValue : string );
  procedure InitTextAssemblingContext( VList: TStrings = nil );

  property  MacroStart: string read FMacroStart write SetMacroStart; // current 
                                                                     // start 
                                                                     // MacroCal
                                                                     // l 
                                                                     // substrin
                                                                     // g
  property  MacroFin  : string read FMacroFin   write SetMacroFin;   // current 
                                                                     // final 
                                                                     // MacroCal
                                                                     // l 
                                                                     // substrin
                                                                     // g

//##/*
    private
//*** TextProcessing Context
  MFinLeng : Integer;
  MStartLeng : Integer;
//*** TextAssembling Context
  TAT  : TK_Tokenizer;
  TAVL : THashedStringlist;
//  PrevIfResult : Boolean;
  IfLevelResults : array of Byte; //0 - Level IF true; 1 - Level IF false; 2 - Skip Level Text
  IfLevel : Integer;
//##*/
    public
  function GetTextAssemblingVars() : TStrings;
  function GetUMNameResult( AUMName : string ) : string;
end;

var
  K_MRProcess : TK_MRProcess;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StringMacroConsts
//***************************************************** K_StringMacroConsts ***
// String Macroprocessing constants for MacroCall markup terms
//
//##begin K_StringMacroConsts
const
//!  MacroCall Separators
  K_mtMacroStart0 = '(#'; // MacroCall start separator 1
  K_mtMacroFin0   = '#)'; // MacroCall fin separator for start separator 1
  K_mtMacroStart  = '{#'; // MacroCall start separator 2 (obsolete)
  K_mtMacroFin    = '#}'; // MacroCall fin separator for start separator 2 
                          // (obsolete)
//!  MacroName Syntax Separators
  K_mtMacroInd = '[';     // MacroName index char if use direct MacroIndex 
                          // instead of MacroName. ({#[N]#} - where N is index 
                          // in MacroReplace List)
  K_mtMacroNameSep = '.'; // MacroName separator for use MacroReplace Lists 
                          // Tree. (#MacroNameCur.MacroNameNext#)
                          //#F
                          //           MacroNameCur  - specifies current MacroReplace List Item which
                          //                           contains reference to next level MacroList
                          //           MacroNameNext - is used to access to Item in this MacroReplace List
                          //#/F
  K_mtMacroValueSep = '=';// MacroValue separator - used to separate MacroName
                          // and MacroValue in MacroReplace List 
                          // (MacroName=MacroValue)
//!  Macro Assembling Expression Operations
  K_mtMacroExprNOT = 'NOT'; // Macro Expression boolean NOT (operand inversion)
  K_mtMacroExprAND = 'AND'; // Macro Expression boolean AND
  K_mtMacroExprOR  = 'OR';  // Macro Expression boolean OR
  K_mtMacroExprEQ  = 'EQ';  // Macro Expression string operands equivalence 
                            // (=TRUE if operands are equal)
  K_mtMacroExprNEQ = 'NE';  // Macro Expression string operands not equivalence 
                            // (=TRUE if operands are not equal)
  K_mtMacroExprLT  = 'LT';  // Macro Expression string operands compare (=TRUE 
                            // if operand1 is less then operand2)
  K_mtMacroExprLE  = 'LE';  // Macro Expression string operands compare (=TRUE 
                            // if operand1 is less or equal then operand2)
  K_mtMacroExprGT  = 'GT';  // Macro Expression string operands compare (=TRUE 
                            // if operand1 is greater then operand2)
  K_mtMacroExprGE  = 'GE';  // Macro Expression string operands compare (=TRUE 
                            // if operand1 is greater or equal then operand2)
//!  Macro Assembling Operators
  K_mtMacroOpVAR    = 'VAR';   // Macro Assembling variable definition
  K_mtMacroOpIFL    = 'IFL';   // Macro Assembling IF operator for skip only 
                               // current level text
  K_mtMacroOpIF     = 'IF';    // Macro Assembling IF operator
  K_mtMacroOpEND    = 'END';   // Macro Assembling END operator
  K_mtMacroOpENDIF  = 'ENDIF'; // Macro Assembling ENDIF operator
  K_mtMacroOpELSE   = 'ELSE';  // Macro Assembling ELSE operator
  K_mtMacroOpELSEIF = 'ELSEIF';// Macro Assembling ELSEIF operator
//##end K_StringMacroConsts

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_TStringsList
//********************************************************* TK_TStringsList ***
// List of TStringList
//
// Used for creating dynamic collections of objects while scanning Internal Data
// Base Structures
//
type TK_TStringsList = class(TList)
  function  AddString(Ind: Integer; const Str: string) : Integer;
  function  AddObject( Ind : Integer; const Str : string; Obj : TObject ) : Integer;
  procedure Clear; override;
  function  TotalCount : Integer;
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_XMLTagParserError
//**************************************************** TK_XMLTagParserError ***
// Class for raising Exceptions in TK_XMLTagParser.ParseTag
//
type TK_XMLTagParserError = class(Exception);

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_XMLTagParser
//********************************************************* TK_XMLTagParser ***
// XML Tags parser
//
type TK_XMLTagParser = class( TObject ) //***** TK_XMLTagParser
    St : TK_Tokenizer;     // string tokenizer for parsing source text
    TagDelims    : string; // possible Tag delimiters (chars)
    DataDelims   : string; // possible data delimiters (chars)
    AttrDelims   : string; // possible  Tag attributes delimiters (chars)
    DataBrackets : string; // possible  Data Brackets (chars)
    constructor Create( ASourceStr : string );
    destructor  Destroy; override;
    function    ParseTag( var ACurPos : Integer; AttrsList : TStrings ) : string; virtual;
    procedure   SetSrc( ASourceStr : string );
end; //*** end of type TK_XMLTagParser = class( TObject )

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_IndIterator
//********************************************************** TK_IndIterator ***
// Random generator of points in Multidimensional Discrete Space
//
// Used for generating random sequences of points of given length in 
// Multidimensional Discrete Space
//
type TK_IndIterator = class( TObject )
//##/*
    private
  IIResPointers:  TN_PArray;  // pointers to resulting Inds Variables
  IIDimSizes:     TN_IArray;  // dimensions capacities (number of indexes in Dimension)
  IIDimWeights:   TN_I8Array; // dimensions Weights
  IIDimCurValues: TN_IArray;  // dimensions Current Values

  IIBoxUFlags:    array of Boolean; // box Used Flags
  IIBoxUCount:    Integer;          // number of Used Boxes
  IIBoxStep:      Double;           // box Step
  IIRandSeed:     LongInt;          // base for random number generator
  IINumDims: integer;               // number of Dimensions

//##*/
    public

  procedure AddIIDim   ( APResult : Pointer; ADimSize: integer );
  procedure PrepIILoop   ( ACount   : integer; AISeed: integer );
  procedure GetNextIInds;
end; // type TK_IndIterator = class( TObject )

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_LineSegmFunc
type TK_LineSegmFunc = class // Line-segment Function generator Object
  LSFArgVals : TN_DArray;  // Argumnet Values Array
  LSFFuncVals : TN_DArray;  // Function Values Array
  LSFLastSegmInd : Integer; // Segment Index for Search optimization
  constructor Create( AArgFuncPoints : array of Double );
  function Arg2Func( AArgVal  : Double ): Double;
  function Func2Arg( AFuncVal : Double ): Double;
end;

procedure K_PrepCharNumList( ANumCharTab : string );
procedure K_FreeTStringsObjects( SList : TStrings );
procedure K_FreeTListObjects( SList : TList );
procedure K_FreeArrayObjects( var Arr : TK_ObjectArray; NilArrayFlag : Boolean = true );
function  K_NewCapacity( NewLeng : Integer; var Capacity : Integer ) : Boolean;
function  K_SetBArrayCapacity( var BArray : TN_BArray; NewLength : Integer ) : Integer;
function  K_SetIArrayCapacity( var IArray : TN_IArray; NewLength : Integer ) : Integer;
function  K_SetStringCapacity( var StringBuf : string; NewLength : Integer ) : Integer;
procedure K_ReplaceStringChars( var Str: string; const RChars : string; const NChars : string );
function  K_CapitalizeWords( const AStr : string ) : string;
function  K_GetPureNameSize( const Name : string ) : Integer;
function  K_BuildUniqName ( const Name : string; MainSize,
                                        UniqIndex : Integer ) : string;
function  K_IfExpandedFileName( const FileName : string ) : Boolean;
function  K_IfURLReference( const FileName : string ) : Boolean;
function  K_LoadSMatrFromFile( var StrMatr: TN_ASArray;
                            const FName : string; SMF : TN_StrMatrFormat ): boolean;
procedure K_LoadSMatrFromText( var StrMatr: TN_ASArray;
                               const SrcText : string; SMF : TN_StrMatrFormat );
procedure K_SplitTDTextToStrings( SL : TStrings; const SrcText: string );
procedure K_LoadSMatrFromStrings( var StrMatr: TN_ASArray;
                                  SL : TStrings; SMF : TN_StrMatrFormat );
//*** from N_Tree\N_Lib1
procedure N_AdjustStrMatr( AStrMatr: TN_ASArray; AColCount: integer = 0 );
procedure K_AddMemIni( ASrcMemIni, ADstMemIni : TMemIniFile );
procedure K_AddStringsToMemIniSection( AMemIni : TMemIniFile; const ASectName : string; ASValues: TStrings );

{
procedure K_DateTimeToFileTime( DateTime : TDateTime; var AFileTime : TFileTime );
procedure K_FileTimeToDateTime( const AFileTime : TFileTime;
                                                out DateTime : TDateTime   );
}
//////////////////////////////////////////////////
//  File Processing Routins
//

//******************************************************* TK_TestFileFunc ***
// test file function type for K_ScanFilesTree iterator
//
type TK_TestFileFunc = function( const APathName, AFileName : string; AScanLevel : Integer ) : TK_ScanTreeResult of object;
var K_ScanFilesTreeMaxLevel : Integer;
function  K_ScanFilesTree( const ASPath : string;
                           ATestFunc : TK_TestFileFunc;
                           const AFNamePat : string = '*.*';
                           AScanFolders : Boolean = FALSE;
                           AScanLevel : Integer = 0 ) : Boolean;

function  K_ForceDirPath( const APath : string ) : Boolean;
function  K_ForceFilePath( const AFilePath : string ) : Boolean;
function  K_ForceDirPathDlg( const ADirPath : string ) : Boolean;
function  K_ForceDirPathDlgRus( const ADirPath : string ) : Boolean;
function  K_GetFileDOSAge( const AFName : string ) :  TDateTime;
function  K_GetFileAge( const AFName : string ) :  TDateTime;
function  K_GetFileAgeDAV(const AFName : string) :TDateTime;   ////Igor
function  L_GetFileAge( const AFName : string ) :  TDateTime;
function  K_SetFileAge( const AFName : string; ADT :  TDateTime ) : Boolean;
function  K_CompareFilesAge( const SrcFName, DestFName : string ) : Integer;

function  K_TryCreateFileStream( const AFName : string; AMode: Word ) : TFileStream;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_CopyFileFlags
type TK_CopyFileFlags = set of ( // Copy File Flags Set
  K_cffOverwriteNewer,    // overwrite Newer Files Flag
  K_cffOverwriteReadOnly  // overwrite Readonly Files Flag
);
var K_NotAddedStrings : TStrings;
procedure K_AddStringToTextFile( const AFileName, AStr : string );
///////////////////////////////////////////
// List of File Names which can't be Copied by
// K_CopyFolderFiles
//
// Uncopied files are collected if User Create K_UnCopiedFileNames.
// User should Free K_UnCopiedFileNames.
//
// var K_UnCopiedFileNames : TStrings;
function  K_CopyFile( const SrcFName, DestFName : string; CopyFileFlags : TK_CopyFileFlags = [] ) : Integer;
function  K_CopyFolderFiles( const SPath, DPath : string;
                             const CopyPat : string= '*.*';
                             CopyFileFlags : TK_CopyFileFlags = [] ) : Boolean;
procedure A_CopyAll(const SrcPath, DestPath: string);
///////////////////////////////////////////
// List of File Names which can't be deleted by
// K_DeleteFile
// K_DeleteFolderFiles
//
// Undeleted files are collected if User Create K_UnDeletedFileNames.
// User should Free K_UnDeletedFileNames.
//
var K_UnDeletedFileNames : TStrings;
//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_DelOneFileFlags
type TK_DelOneFileFlags = set of ( // Delete one File Flags Set
  K_dofDeleteReadOnly,     // Delete Readonly File Flag
  K_dofSkipStoreUndelNames // Skip Store Undeleted Files Names Flag
);
function  K_DeleteFile( const AFileName : string; ADeleteFileFlags : TK_DelOneFileFlags = [] ) : Boolean;
//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_DelFolderFilesFlags
type TK_DelFolderFilesFlags = set of ( // Delete Folder Files Flags Set
  K_dffRecurseSubfolders, // recurse Subfolders Flag
  K_dffRemoveReadOnly // remove Readonly Files Flag
);
procedure K_DeleteFolderFilesEx( const SPath : string; UndelList : TStrings;
                                const DeletePat : string= '*.*';
                                DelFileFlags : TK_DelFolderFilesFlags = [K_dffRecurseSubfolders] );
procedure K_DeleteFolderFiles( const SPath : string; const DeletePat : string= '*.*';
                               DelFileFlags : TK_DelFolderFilesFlags = [K_dffRecurseSubfolders] );
function  K_CountFolderFiles( const ASPath : string; const ACountPat : string= '*.*';
                              ACountFileFlags : TK_DelFolderFilesFlags = [K_dffRecurseSubfolders] ) : Integer;
function  K_RenameExistingFile( const FileName : string ) : string;
function  K_FileReplacingDlg( const FileName : string ) : Boolean;

function  K_CalcFileCRC( const AFName : string ): Integer;
function  K_FindFirstFileNameByPattern( const AFNamePat : string ): string;


//
//  End of File Processing Routins
//////////////////////////////////////////////////

//////////////////////////////////////////////////
//  Named Objects List Routines
//
function  K_ReplaceListNamedValue( SList : TStrings;
                               const Name : string; const Value : string = '' ) : Integer;
procedure K_ReplaceListValue( ASList : TStrings; AInd : Integer;
                              const AValue : string = '' );
function  K_DeleteListNamedValueAndObject( SList : TStrings; const Name : string ) : TObject;
function  K_RegListObject( var SList : TStrings;
                           const Name : string; Obj : TObject ) : Integer;
//
//  End of Named Objects List Routines
//////////////////////////////////////////////////

//##path K_Delphi\SF\K_clib\K_CLib0.pas\MacroReplaceDescr
//******************************************************* MacroReplaceDescr ***
// Macro replace description
//
// Macro replace context is list of strings - macroname=macrovalue. Macro call 
// is substring (#macroname#). Macro strings list can contain nested macro 
// strings lists.
//
// Nested strings lists are linked to corresponding Objects[i] property to one 
// macro strings list.
//
// For using nested macro strings list macroname in macro call can be compound. 
// Compound name elements are delimited by macro name separator '.'. For 
// example, macro call (#mname_lev1.mname_lev2#) will be replaced by value of 
// element "mname_lev2" from nested macro strings list which is linked to main 
// macro strings list element "mname_lev1".
//
//#### MacroReplaceDescr
// ************************************ end of MacroReplaceDescr

function  K_SwitchMacroBuffers( var ASrcBuf: string; ASrcULeng : Integer;
                                var ADstBuf: string; ADstULeng : Integer ) : Integer;
function  K_StrMacroReplaceBuf( const ASrcBuf : string; ASrcULeng : Integer;
                                const AComStart, AComFin, ANewVal : string;
                                var ADstBuf : string  ) : Integer;
function  K_StringMacroReplace( const ASrc, AComStart, AComFin, ANewVal : string ) : string;
function  K_StrSSReplaceBuf( const ASrcBuf : string; ASrcULeng : Integer;
                             const ARValue, ANValue : string;
                             var ADstBuf : string  ) : Integer;
function  K_StringSSReplace( const ASrc, ARValue, ANValue : string ) : string;
function  K_StrMListReplaceBuf( const ASrcBuf : string; ASrcULeng : Integer;
                                var ADstBuf : string; AMList : TStrings;
                                AUndefMacroMode : TK_UndefMacroMode = K_ummPutErrText;
                                APErrNum : PInteger = nil; const AMStart : string = '';
                                const AMFin : string = ''  ) : Integer;
function  K_StringMListReplace( const ASrc : string; AMList : TStrings;
                                AUndefMacroMode : TK_UndefMacroMode = K_ummPutErrText;
                                APErrNum : PInteger = nil; const AMStart : string = '';
                                const AMFin : string = '' ) : string;
procedure K_SListMListReplace( ASList, AMList : TStrings;
                               AUndefMacroMode : TK_UndefMacroMode = K_ummPutErrText;
                               const AMStart : string = ''; const AMFin : string = '' );
procedure K_MacroListClearItems( AMList : TStrings; ADeleteFlag : Boolean = false;
                                 ASInd : Integer = 0; AEInd : Integer = -1 );

//##path K_Delphi\SF\K_clib\K_CLib0.pas\MacroAssemblingDescr
//**************************************************** MacroAssemblingDescr ***
// Text macro assembling description
//
// Macro assembling context is list of strings - macroname=macrovalue. Macro 
// construction is substrings like (#EXPRESSION#) in given text, where substring
// '(#' is macro expression start chars and substring '#)' is final chars.
//
// Macro assembling constructions and expressions:
//#F
// MACROCONSTRUCTIONS ::= (#if CONDITION #) ... (#end#)|
//                        (#if CONDITION #) ... (#else#) ... (#end#)|
//                        (#if CONDITION #) ... (#elseif CONDITION #) ...(#end#)|
//                        (#var VarName = VarValue#)
// EXPRESSION ::= EXPRESSION or  EXPRESSION |
//                EXPRESSION and EXPRESSION |
//                not EXPRESSION |
//                VARIABLE EQ VARIABLE |
//                VARIABLE NE VARIABLE |
//                VARIABLE EQ CONSTANT |
//                VARIABLE NE CONSTANT |
//#/F
//
// Macro constructions allow to assemble different resulting texts from single 
// source text depending on value of macro variables
//
//#### MacroAssemblingDescr
// ************************************ end of MacroAssemblingDescr

function  K_StringMacroAssemblingBuf( const ASrcBuf : string; ASrcULeng : Integer;
                                const AComStart, AComFin : string;
                                AVList : TStrings; var ADstBuf : string ) : Integer;
function  K_StringMacroAssembling( const ASrc : string; const AMStart : string = '';
                                   const AMFin : string = ''; AVList : TStrings = nil ) : string;
function  K_StringsSaveToFile( const FName : string; SL : TStrings;
                               SaveMode : TK_FileEncodeMode ) : Boolean;
//function  N_KeyIsDown ( VKey: integer ): boolean;
procedure K_HTMGetBodySInds( AHTMStrings : TStrings; out ABegSInd, AFinSInd : Integer );
procedure K_HTMPrepForMacroReplace( AHTMStrings : TStrings;
                                    const AMStart : string = 'href="#$$';
                                    const AMFin : string = '"' );
function  K_ConvStringToMHT( const ASrcStr : string; var AResBuf : string ) : Integer;

procedure K_SetPackMode( PackModeCode : Boolean );
function  K_PackJSText( const Text : string; const InfoText : string = '' ) : string;
function  K_UnPackJSText( const Text : string ) : string;
function  K_GetJSCharNumString( ) : string;
function  K_PrepJSTextPack( const Text : string; PrepNewLine : Boolean = true;
                      PrepSingleQuoute : Boolean = false;
                      PrepBackSlash : Boolean = false ) : string;
function  K_GetJSValidCharString( ) : string;
function  K_SubString( const sstr : string; Ind, Count : Integer ) : string;
function  K_ShellExecute( const Operation, FileName : string; ShowWinMode : Integer = -1;
                          PErrMes : PString = nil; const Params : string = '';
                          const DefaultDir : string = '' ) : LongWord;
function  K_RunExeByCmdl( const CMDLine : string; CreateProcessFlags : Integer = -1;
                          PSTInfo : PStartupInfo = nil; const DefaultDir : string = '';
                          PProcInfo : PProcessInformation = nil ) : Boolean;
function  K_RunExe( const AFileName : string; const AParams : string = ''; const ADefaultDir : string = '';
                    AUseCreateProcess : Boolean = FALSE ) : string;
function  K_WaitForExecute( const CMDLine : string; CreateProcessFlags : Integer = -1;
                            PSTInfo : PStartupInfo = nil; PExecResultCode : PInteger = nil;
                            const DefaultDir : string = ''; ASkipProcessMessagesFlag : Boolean = FALSE ) : Boolean;
function  K_CheckProcess( const AExecName: string; ASkipProcID : DWORD = 0 ): Integer;
procedure K_SetForegroundWindow( AToForegroudHWND : HWND );
function  K_GetComputerName( ) : string;

//////////////////////////////////////////////
// Windows Terminal Service Data Types
//

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_WTS_INFO_CLASS
type TK_WTS_INFO_CLASS = ( // enumeration type contains values that indicate the type of session information to retrieve in a call to the WTSQuerySessionInformation function
  WTSInitialProgram, // A null-terminated string containing the name of the
                     // initial program that Terminal Services runs when the 
                     // user logs on.
  WTSApplicationName, // A null-terminated string containing the published name 
                      // of the application the session is running.
  WTSWorkingDirectory, // A null-terminated string containing the default 
                       // directory used when launching the initial program.
  WTSOEMIdWTSOEMId, // Not used.
  WTSSessionId, // A ULONG value containing the session identifier.
  WTSUserName, // A null-terminated string containing the name of the user
               // associated with the session.
  WTSWinStationName, // A null-terminated string containing the name of the 
                     // Terminal Services session. Note Despite its name, 
                     // specifying this type does not return the window station 
                     // name. Rather, it returns the name of the Terminal 
                     // Services session. Each Terminal Services session is 
                     // associated with an interactive window station. 
                     // Currently, since the only supported window station name 
                     // for an interactive window station is "WinSta0", each 
                     // session is associated with its own "WinSta0" window 
                     // station. For more information, see Window Stations.
  WTSDomainName, // A null-terminated string containing the name of the domain 
                 // to which the logged-on user belongs.
  WTSConnectState, // The session's current connection state. For more 
                   // information, see WTS_CONNECTSTATE_CLASS.
  WTSClientBuildNumber, // A ULONG value containing the build number of the 
                        // client.
  WTSClientName, // A null-terminated string containing the name of the client.
  WTSClientDirectory, // A null-terminated string containing the directory in 
                      // which the client is installed.
  WTSClientProductId, // A USHORT client-specific product identifier.
  WTSClientHardwareId, // A ULONG value containing a client-specific hardware 
                       // identifier.
  WTSClientAddress, // The network type and network address of the client. For
                    // more information, see WTS_CLIENT_ADDRESS.,
  WTSClientDisplay, // Information about the display resolution of the client. 
                    // For more information, see WTS_CLIENT_DISPLAY.
  WTSClientProtocolType, // A USHORT value specifying information about the 
                         // protocol type for the session. This is one of the 
                         // following values: WTS_PROTOCOL_TYPE_CONSOLE 
                         // WTS_PROTOCOL_TYPE_ICA WTS_PROTOCOL_TYPE_RDP
  WTSIdleTimeWTSIdleTime,
  WTSLogonTimeWTSLogonTime,
  WTSIncomingBytesWTSIncomingBytes,
  WTSOutgoingBytesWTSOutgoingBytes,
  WTSIncomingFramesWTSIncomingFrames,
  WTSOutgoingFramesWTSOutgoingFrames
);

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_WTS_CLIENT_ADDRESS
type TK_WTS_CLIENT_ADDRESS  = record
  AddressFamily : DWORD;
  Address : array [0..19] of Byte;
end;
type TK_PWTS_CLIENT_ADDRESS = ^TK_WTS_CLIENT_ADDRESS;

const
  WTS_PROTOCOL_TYPE_CONSOLE = 0; // console
  WTS_PROTOCOL_TYPE_ICA = 1;     // citrix??
  WTS_PROTOCOL_TYPE_RDP = 2;     // remote desktop
  WTS_CURRENT_SESSION = -1;      // Current Session ID
//
// end of Windows Terminal Service Data Types
//////////////////////////////////////////////

///////////////////////////////////////////////////
// Windows Terminal Service API definitions
//
{$IF SizeOf(Char) = 1}
function  WTSOpenServer( APCompName: PChar ): THandle; stdcall; external 'Wtsapi32.dll' name 'WTSOpenServerA';
function  WTSQuerySessionInformation( HServer : THandle; SessionId : Integer; WTSInfoClass : TK_WTS_INFO_CLASS; var PBuf : PChar; var BufDataLeng : DWORD ): BOOL; stdcall; external 'Wtsapi32.dll' name 'WTSQuerySessionInformationA';
{$ELSE}
function  WTSOpenServer( APCompName: PChar ): THandle; stdcall; external 'Wtsapi32.dll' name 'WTSOpenServerW';
function  WTSQuerySessionInformation( HServer : THandle; SessionId : Integer; WTSInfoClass : TK_WTS_INFO_CLASS; var PBuf : PChar; var BufDataLeng : DWORD ): BOOL; stdcall; external 'Wtsapi32.dll' name 'WTSQuerySessionInformationW';
{$IFEND}
procedure WTSFreeMemory( PMem : Pointer ); stdcall; external 'Wtsapi32.dll' name 'WTSFreeMemory';
procedure WTSCloseServer( AH : THandle ); stdcall; external 'Wtsapi32.dll' name 'WTSCloseServer';
//
// end of Windows Terminal Service API definitions
///////////////////////////////////////////////////

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_WTSSessionInfo
type TK_WTSSessionInfo = record
  WTSSessionID : Integer;     // Session ID
  WTSClientProtocolType : Integer; // 0 - Console, 1 - ICA (may be Citrix, 2 - 
                                   // RDP, Terminal Session)
  WTSServerCompName : string; // Application Server Computer Name
  WTSClientName     : string; // Remote Client (computer) Name
  WTSClientIPStr    : string; // Remote Client IP string
  WTSUserName       : string; // Session UserName
  WTSFillCode       : Integer;// Fill Structure Code
end;
type TK_PWTSSessionInfo = ^TK_WTSSessionInfo;

procedure K_WTSGetSessionInfo(  APWTSSessionInfo : TK_PWTSSessionInfo );

function  K_IsWin64Bit() : Boolean;

procedure K_ReplaceGPathAfterElement( const AGPName, AGPValue : string );
procedure K_ReplaceGPathBeforeElement( const AGPName, AGPValue : string );
function  K_ReplaceDirMacro( const FName : string; PErrNum : PInteger = nil ) : string;

var K_ExpandFileNameErrorIgnore : Boolean = false;
    K_ExpandFileNameAppTypeStr : string;
    K_ExpandFileNameDumpProc   : procedure ( AStr : string ) of object = nil;

function  K_ExpandFileName( const FName : string ) : string;
function  K_GetDirPath( const PathName : string ): string;
function  K_ExpandFileNameByDirPath( const PathName, FileName : string): string;
procedure K_ExpandComboBoxFileNames( AComboBox: TComboBox );
function  K_ReplaceUDPathMacro( const UDPath : string ) : string;
function  K_ExtractRelativePath( const BasePath, FilePath : string ) : string;
function  K_ExtractPathBase( const FilePath : string ) : string;
function  K_SetBasePathMacro( const BasePath, FilePath : string ) : string;
function  K_OptimizePath( const Path : string ) : string;
function  K_PrepFileName( const FName : string; ARChar : Char = '#' ) : string;
{
procedure K_EncodeStringsToFile( SS : TStrings; const AFName : string; PSW : string = '' );
function  K_DecodeStringsFromFile( SS : TStrings; const AFName : string; PSW : string = '' ) : Boolean;
}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\SetRoutinesCommon
//******************************************************* SetRoutinesCommon ***
// Set Routines Common Info
//
// Set occupies bytes array aligned on double-word. Set contains N bit members:
//#F
//  0-bit - for internal use
//  1-bit - Set member with index = 0
//  2-bit - Set member with index = 1
//     ...
//  N-bit - Set member with index = N-1
//#/F
//
// Set operations:
//#F
//   K_sotOR    - Set1 bits OR with Set2 bits
//   K_sotCLEAR - clear Set1 bits by Set2 bits
//   K_sotAND   - Set1 bits AND with Set2 bits
//#/F
//
//#### SetRoutinesCommon
// ************************************ end of SetRoutinesCommon

//*** Set Routines
function  K_SetLWLength ( Count : Integer ) : Integer;
function  K_SetByteLength ( Count : Integer ) : Integer;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_SetOp
type TK_SetOp = ( // Set operations enumeration
  K_sotOR,    // union
  K_sotCLEAR, // difference
  K_sotAND    // intersection
);
function  K_SetOp2( PRSet : Pointer; PSet1 : Pointer; PSet2 : Pointer; Count : Integer; OpType : TK_SetOp ) : Boolean;
function  K_SetFComplement ( PRSet : Pointer; PSet : Pointer; Count : Integer ) : Boolean;
function  K_SetSIsEqual ( PSet1 : Pointer; PSet2 : Pointer; Count : Integer ) : Boolean;
//function  K_SetSIsSubSet ( PSet1 : Pointer; PSet2 : Pointer; Count : Integer ) : Boolean;
function  K_SetByteMaskAndIndex( var Ind : Integer ) : Byte;
function  K_SetGetElementState ( Ind : Integer; PSet : Pointer ) : Boolean;
function  K_SetGetElementState0( Ind : Integer; PSet : Pointer ) : Boolean;
procedure K_SetInclude ( Ind : Integer; PSet : Pointer );
procedure K_SetInclude0( Ind : Integer; PSet : Pointer );
procedure K_SetExclude ( Ind : Integer; PSet : Pointer );
procedure K_SetExclude0( Ind : Integer; PSet : Pointer );
procedure K_SetFromInds ( PRSet : Pointer; PIndexes : PInteger; Count : Integer; IndsStep : Integer = SizeOf(Integer) );
procedure K_SetFromInds0( PRSet : Pointer; PIndexes : PInteger; Count : Integer; IndsStep : Integer = SizeOf(Integer) );
function  K_SetToInds ( PIndexes : PInteger; PSet : Pointer; Count : Integer; IndsShift : Integer = -1; IndsStep : Integer = SizeOf(Integer) ) : Integer;

procedure K_InterchangeTActionsFields( Act1, Act2 : TAction );

function  K_IntValueBitWidth ( val : LongWord ) : Integer;

function  K_StrStartsWith( const StartStr, TestStr  : string;
     IgnoreCase : Boolean = false; CompLength : Integer = 0 ) : Boolean;
function  K_StrScan( SChar : Char; const ScanStr  : string; ScanSInd : Integer = 1 ) : Integer;
function  K_StrEncodeToIniFileValue( const AEncodeStr  : string ) : string;
function  K_StrDecodeFromIniFileValue( const ADecodeStr  : string ) : string;

//**************************************
//*** DFiles Types and Procedures
//**************************************

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_DFCreateFlags
type TK_DFCreateFlags = set of ( // Create DataFile flags
  K_dfcEncryptSrc // if Encrypting is needed, it can be done on Source data 
                  // (Source data could be changed!)
  );

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_DFEncryptionType
type TK_DFEncryptionType = (  // DataFile Type
  K_dfeProtected, // include Data Protection Info
  K_dfePlain,     // no encryption and Data Protection Info
  K_dfeXOR,       // include Data Protection Info and Simple XOR Encryption that
                  // does not prevent good compression
  K_dfeEncr1      // include Data Protection Info Better Encryption that 
                  // prevents good compression
  );
// K_dfeProtected - include Data Protection Info
// K_dfePlain     - no ecryption and Data Protection Info
// K_dfeXOR       - include Data Protection Info and Simple XOR Encryption that does not prevent good compression
// K_dfeEncr1     - include Data Protection Info Better Encryption that prevents good compression


//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_DFOpenFlags
type TK_DFOpenFlags = set of ( // DataFile open flags
  K_dfoPlain,         // file should be Plain (without any meta info)
  K_dfoProtected,     // file should not be Plain (without any meta info) (if 
                      // both Flags K_dfoPlain and K_dfoProtected are not set, 
                      // any File is OK)
  K_dfoSkipExceptions // is used to skip stream destroy in K_DFOpen
  );
// K_dfPlain          - file should be Plain (without any meta info)
// K_dfNotPlain       - file should not be Plain (without any meta info)
//                     (if both Flags mvfPlain and mvfNotPlain are not set, any File is OK)
// K_dfSkipExceptions - not implemented (now no exceptions are raised)

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_DFErrorCode
type TK_DFErrorCode = ( // DataFile operate Error Code
  K_dfrOK,              // DataFile operation OK result
  K_dfrErrTooSmall,     // DataFile length is less then MetaInfo length
  K_dfrErrBadSignature, // DataFile signature is corrupted
  K_dfrErrBadDataSize,  // DataFile size is not equal to expected size
  K_dfrErrBadCRC,       // DataFile CRC failure
  K_dfrErrBadVersion,   // bad DataFile format version
  K_dfrErrBadEncrType,  // bad DataFile encryption type
  K_dfrErrBadMetaInfo,  // bad DataFile MetaInfo
  K_dfrErrFileNotExists,// DataFile is not found
  K_dfrErrStreamOpen    // DataFile stream open error
  );

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_DFCreateParams
//******************************************************* TK_DFCreateParams ***
// DataFile Create Parameters
//
// Is used in some DataFiles handling routines where DataFile creation is 
// needed.
//
type TK_DFCreateParams = packed record
  DFCreateFlags    : TK_DFCreateFlags;    // what File should be Created
  DFEncryptionType : TK_DFEncryptionType; // needed Encryption type
  DFFormatVersion  : Integer;             // needed Format Version (now =1)
  DFPassword       : AnsiString;          // password is used for file data 
                                          // encryption
end; // type TK_DFCreateParams = record
type TK_PDFCreateParams = ^TK_DFCreateParams;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_DFile
//**************************************************************** TK_DFile ***
// DataFile Operating Record
//
// Is used in all DataFiles handling routines.
//
type TK_DFile = record
  DFStream:         TStream; // FileStream used for read/write data from OS File
  DFIsPlain:        boolean; // DataFile is Plain OS File (without any meta 
                             // info)
  DFPlainDataSize:  integer; // DataFile Plain data size (not counting any meta 
                             // info)
  DFPlainDataCRC:   integer; // Plain Data CRC (not counting any meta info)
  DFFormatVersion:  integer; // DFile format Version Number
  DFEncryptionType: TK_DFEncryptionType; // Encryption Type
  DFErrorCode:      TK_DFErrorCode;      // DataFiles handling routines Error 
                                         // Code
  DFErrorAddInfo:   string;  // Additional Info
  DFSize:           integer; // DataFile size (not counting any meta
  DFFileAfterCRC:   integer; // Data CRC writen at the end of the protected file
  DFCurSegmPos:     integer; // Current Data Segmen Start Position
  DFNextSegmPos:    integer; // Next Data Segmen Start Position  = Start Segment
                             // Position + Meta Data size +  + Plain data size
  DFFileDate:       TDateTime;// DFile date
end; // type TK_DFile = record

//##path K_Delphi\SF\K_clib\K_CLib0.pas\DFileFormat
//************************************************************* DFileFormat ***
// Data File internal structure description
//
//#F
// DFSignature                (22 bytes)
// DFile Format version       (4 bytes)
//
// Mixed Data Size and CRC sum (16 bytes) (before Data)
// Encryption type             (1 byte)
//
// Data Bytes
//   ...
// Data Bytes
//
// Mixed Data Size and CRC sum (16 bytes) (after Data)
//#/F
//
//#### DFileFormat
// ************************************ end of DFile Format description

var K_DFStreamReadShareFlags  : word = 0; // Data File Stream Read Share Mode Flags
function  K_DFStreamWriteAll( const AStream : TStream; const AParams: TK_DFCreateParams;
                              APFirstByte: Pointer; ANumBytes: integer;
                              ASegmStartPos: Integer = 0;
                              AFileDate : TDateTime = 0 ): integer;
function  K_DFWriteAll    ( const AFileName: string; const AParams: TK_DFCreateParams;
                            APFirstByte: Pointer; ANumBytes: integer;
                            AFileStartPos: Integer = 0;
                            AFileDate : TDateTime = 0 ): integer;
function  K_DFStreamOpen  ( const AStream: TStream; var ADFile: TK_DFile;
                            AOpenFlags: TK_DFOpenFlags;
                            APCreateParams: TK_PDFCreateParams = nil;
                            ASegmStartPos: Integer = 0 ): boolean;
function  K_DFOpen        ( const AFileName: string; out ADFile: TK_DFile;
                            AOpenFlags: TK_DFOpenFlags;
                            APCreateParams: TK_PDFCreateParams = nil;
                            ASegmStartPos: Integer = 0 ): boolean;
function  K_DFOpenNextSegm( var ADFile: TK_DFile; AOpenFlags: TK_DFOpenFlags;
                            APCreateParams: TK_PDFCreateParams = nil ) : Boolean;
function  K_DFStreamOpenLastSegm( const AStream: TStream; var ADFile: TK_DFile;
                                  AOpenFlags: TK_DFOpenFlags;
                                  APCreateParams: TK_PDFCreateParams = nil ): boolean;
function  K_DFReadAll     ( APBuffer: Pointer; var ADFile: TK_DFile;
                            APasWord: AnsiString = '' ): boolean;
function  K_DFRead      ( APBuffer: Pointer; ANumBytes: Integer;
                          var ADFile: TK_DFile;
                          const APasWord: AnsiString = ''; CloseFStreamFlag : Boolean = FALSE ): boolean;
function  K_DFGetErrorString( ADFErrorCode: TK_DFErrorCode ): string;
procedure K_SaveStringsToDFile   ( AStrings: TStrings; AFileName: string;
                                          const ACreateParams: TK_DFCreateParams );
function  K_LoadStringsFromDFile( AStrings: TStrings; const AFileName: string;
                                   APCreateParams: TK_PDFCreateParams = nil;
                                   const APasWord: AnsiString = '';
                                   AOpenFlags: TK_DFOpenFlags = [] ): boolean;
procedure K_EncodeDFile ( const AInpFName, AOutFName: string;
                                            const AParams: TK_DFCreateParams );
function  K_DecodeDFile ( const AInpFName, AOutFName: string; APasWord: AnsiString = '' ): boolean;
//**************************************
//*** End of DFiles Types and Procedures
//**************************************

const
  K_DFFormatVersion1 = 1;
  K_DFFormatVersion2 = 2;
  K_DFCreatePlain       : TK_DFCreateParams = ( DFEncryptionType:K_dfePlain );
  K_DFCreateProtected   : TK_DFCreateParams = ( );
  K_DFCreateEncrypted   : TK_DFCreateParams = ( DFEncryptionType:K_dfeXOR );
  K_DFCreateEncrypted2  : TK_DFCreateParams = ( DFEncryptionType:K_dfeXOR; DFFormatVersion:K_DFFormatVersion2 );
  K_DFCreateEncryptedSrc: TK_DFCreateParams = ( DFCreateFlags:[K_dfcEncryptSrc]; DFEncryptionType:K_dfeXOR  );

//***************** Tmp Files Procedures
function K_GetNewTmpFileName( const AFileExt : string ) : string;
function K_BuildUniqFileName( const AFilesAllocPath, AFNamePrefix, AFNameSuffix : string;
                               var AFilesCount : Integer ) : string;

const
  K_TagOpenChar = '<';
  K_TagCloseChar = '>';
  K_TagCloseFlag = '/';

const
  K_UDGPathsIniSection = 'UDGPaths';

var
  K_NewArchFilesEnvID   : string; // Files Environment ID for new Archives
  K_AppFileGPathsList   : THashedStringList; // Resulting Global Paths List after macro processing
  K_AppFileGPathsBeforeList : TStringList; // Programmatically created Global Paths macrodefinitions to place before all Ini-file macrodefinitions
  K_AppFileGPathsAfterList  : TStringList; // Programmatically created Global Paths macrodefinitions to place after all Ini-file macrodefinitions
  K_AppFileGPathsCustProc   : procedure;   // Procedure for customizing Global Paths List before macro processing

  K_AppUDGPathsList     : THashedStringList;

procedure K_MoveBits24( const Src; SBit : Integer; var Dest; DBit, FSize : Integer );
procedure K_MoveBits( const Src; SBit : Integer; var Dest; DBit, FSize : Integer );
function  K_GetIntBitsCount( AIntBitSet : LongWord ) : Integer;

type TK_RegExprFlags = Set of (
  K_RESearch
);
type TK_RegExprCont = record
  REFlags : TK_RegExprFlags;
  RESPos : Integer;
  REFPos : Integer;
end;
TK_PRegExprCont = ^TK_RegExprCont;

function  K_CheckTextPatternEx( APSStr : PChar; ANumS : Integer;
                                APPat  : PChar; ANumP : Integer;
                                AWChars : string = '';
                                APRECont : TK_PRegExprCont = nil ) : Boolean;
//function  K_CheckTextPattern( const SStr, Pat : string; FilePattern : boolean = true;
//                               SStrSPos : Integer = 0 ) : Boolean;
function  K_CheckTextPattern( const SStr, Pat : string; FilePattern : boolean = true ) : Boolean;
function  K_CheckPattern( const ASStr, APat : string ) : Boolean;
function  K_SearchTextPattern( APSStr : PChar; ANumS : Integer;
                               APPat  : PChar; ANumP : Integer;
                               out ASPos, ANpos : Integer;
                               AWChars : string = '' ) : Boolean;


function  K_CheckKeyExpr( const SStr : string; const KeyExpr : string  ) : Boolean;

type TK_CheckStringProc = function ( const SStr : string; const SExpr : string  ) : Boolean;
function  K_SearchInStrings( AResSL, ASearchSL : TStrings; const ASeachCond : string;
                            ACheckProc : TK_CheckStringProc;
                            const AResFormat : string = ''; AMaxSNum : Integer = 0  ) : Integer; overload;
//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_SearchInFiles
type TK_SearchInFiles = class
  SIFResultStrings : TStrings; // Current Resulting Strings List
  SIFFilesPath : string;       // testing files base path
  SIFFNamePat  : string;       // testing files name pattern
  SIFSeachCond : string;       // search expression string
  SIFFileFoundMax : Integer;   // maximal number of found strings in file
  SIFFoundStrRFormat : string; // resulting info format string for found string
  SIFFoundFileRFormat: string; // resulting info format string for file with 
                               // found strings
  SIFNFoundFileRFormat: string;// resulting info format string for file without 
                               // found strings
  SIFCheckProc : TK_CheckStringProc; // function for strings checking
  constructor Create();
  function  SIFSearchResultsToStrings( const AResStrings : TStrings ) : TStrings;
  function  SIFSearchResultsToFile( const AResFName : string ) : TStrings;
    private
  FSL : TStringList;
  function  FileTestFunc( const APathName, AFileName : string; AScanLevel : Integer ) : TK_ScanTreeResult;
end;

const K_Masks32 : array [0..31] of TN_UInt4 = (
  $1, $3, $7, $F,
  $1F, $3F, $7F, $FF,
  $1FF, $3FF, $7FF, $FFF,
  $1FFF, $3FFF, $7FFF, $FFFF,
  $1FFFF, $3FFFF, $7FFFF, $FFFFF,
  $1FFFFF, $3FFFFF, $7FFFFF, $FFFFFF,
  $1FFFFFF, $3FFFFFF, $7FFFFFF, $FFFFFFF,
  $1FFFFFFF, $3FFFFFFF, $7FFFFFFF, $FFFFFFFF );

var
  K_MVMinVal  : Double;
  K_MVMaxVal  : Double;


function  K_MessageDlg( const ACaption, AMessageLine : string;
                        ADlgType: TMsgDlgType; ADlgButtons: TMsgDlgButtons;
                        AHelpCtxt: Integer = -1 ) : Word;

procedure K_ShowMessage( const MessageLine : string; const Caption : string = '';
                         MesStatus : TK_MesStatus = K_msWarning;
                         HelpCtxt : Longint = -1 );

function  K_BuildISetByIDs( const SetIDs, SetDescr : string  ) : Integer;
function  K_BuildIDsByISet( ISet : Integer; const SetDescr : string  ) : string;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_ColorPathPoint
//******************************************************* TK_ColorPathPoint ***
// Color Path Point in RGB Coordinates Space
//
// Array of Color Path Points is used for parametric representation of colors in
// K_BuildColorByColorPathWeight and K_BuildColorsByColorPathWeights routines
//
type TK_ColorPathPoint = record
  R, G, B : Integer;    // point RGB Coordinates
  DR, DG, DB : Integer; // RGB Coordinates step to next point
  W: Double;            // part of the path from start point of ColorPathPoints 
                        // Array to current point
end;
type TK_ColorPath = array of TK_ColorPathPoint;

function  K_CalcColorGrey8( AColor : Integer ) : Integer;
procedure K_PrepColorPathByColors( var ColorPath : TK_ColorPath;
                                   PPathColors : Pointer; PathColorsCount : Integer;
                                   PathColorsStep : Integer = SizeOf(Integer);
                                   UniformPathPointWeight : Boolean = false );
function  K_BuildColorByColorPathWeight( const ColorPath : TK_ColorPath;
                                        CWeight : Double ) : Integer;
procedure K_BuildColorsByColorPathWeights( const ColorPath : TK_ColorPath;
                                    PColors : Pointer; ColorsCount : Integer;
                                    ColorsStep : Integer = SizeOf(Integer);
                                    WMin : Double = 0; WMax : Double = 100;
                                    PWeights : PDouble = nil );
procedure K_BuildColorsByColorPath( PPathColors : PInteger; PathColorsCount : Integer;
                                 PColors : PInteger; ColorsCount : Integer;
                                 UniformPathPointWeight : Boolean = false );
procedure K_NumberToDigits( Number : Int64; PDigitWeights : PInt64;
                            PResults : PInteger; DCount : Integer );

function  K_CalcCNK( AN, AK: integer ): Integer;
procedure K_BuildCNKSets( PSets : Pointer; SStep, AN, AK : Integer );

type TK_TestSetsFunc =  function( PASet : Pointer; PCSet : Pointer; SPower : Integer ) : Boolean;
function  K_TestIfSetIsNotSuperSet( PSet1 : Pointer; PSet2 : Pointer; SPower : Integer ) : Boolean;
function  K_TestIfSetHasNoIntersects( PSet1 : Pointer; PSet2 : Pointer; SPower : Integer ) : Boolean;
function  K_BuildProperSetsInds( PInds : PInteger; PASets : Pointer; AStep, ACount : Integer;
                                 PCSets : Pointer; CStep, CCount : Integer; SPower : Integer;
                                 TestSetsFunc : TK_TestSetsFunc ) : Integer;

function  K_LeftStrLengthByWidth( CHandle : HDC; const Str : string;
                                  PixelWidth : Integer ) : Integer;
function  K_StrCutByWidth( CHandle : HDC; const SrcStr, TailStr : string;
                           PixelWidth : Integer; CutTailStr : Boolean = false ) : string;
procedure K_CellDrawString( Str : string; DrawRect: TRect; HPos : TK_CellPos; VPos : TK_CellPos;
            Canvas : TCanvas; Padding : Integer = 8; FontColor : TColor = -1;
            FontStyle : Byte = $FF );

function  K_GetStringsToBuf( var ASBuf : string; ASL : TStrings; ASInd : Integer;
                             ASCount : Integer = -1; ASkipLastLF : Boolean = true;
                             ADelims : string = '' ) : Integer;
function  K_GetStringsText( ASL : TStrings; ASInd : Integer; ASCount : Integer = -1;
                            ASkipLastLF : Boolean = false ) : string;
function  K_SearchInStrings( ASL : TStrings; const ASubStr : string;
                             ASInd : Integer = 0; ASCount : Integer = 0;
                             AFullStrCompare : Boolean = false;
                             AIgnoreCase : Boolean = false;
                             AAnyOccurrence : Boolean = false ) : Integer; overload;
function  K_IndexOfStringsName( ASL : TStrings; const AName : string ) : Integer;
function  K_GetStringsValueByName( ASL : TStrings; const AName : string;
                                   ADefValue : string = '' ) : string;
procedure K_ReplaceStringsInterval( DS : TStrings; DInd : Integer; DCount : Integer;
                            SS : TStrings; SInd : Integer; SCount : Integer );
procedure K_ExcludeCorrespondingStrings( ASL : TStrings; AESL : TStringList  );

procedure K_PutTextToClipboard( const AText : string; APutAnsiStr : Boolean = false );
function  K_GetTextFromClipboard( ) : string;
procedure K_AddTextToClipboard( const AText : string; APutAnsiStr : Boolean = false );

function  K_RoundDVectorBySum( APDstDVector : PDouble;
                               ACount : Integer;
                               APSrcDVector : PDouble;
                               APSplitVal : PDouble = nil ) : Double;
function  K_ReplaceCommaByPoint( AStr : String  ) : string;

procedure K_BCGBriMinMaxPrep( ABriMax : Integer; ANegateFlag : Boolean;
                              ABriMinFactor, ABriMaxFactor : Double;
                              out ABriConvMin, ABriConvMax : Integer );
{ Replace by N_BCGImageXlatBuild
procedure K_BCGImageXlatBuild( const AXLat : TN_IArray;
                               ACoFactor, ABriFactor, AGamFactor : Double;
                               ABriMinFactor, ABriMaxFactor : Double;
                               ANegateFlag : Boolean );
}
var
  K_SelectFolderNewStyle : Boolean = FALSE;
function  K_SelectFolder( const ACaption: string; const ARoot: WideString;
                          var AFolder: string ): Boolean;
function  K_SelectFolderNew( const ACaption: string; var AFolder: string ): Boolean;

function  K_GetColorsRGBDif( AColor1, AColor2 : TColor ) : Double;
function  K_GetContrastColor( ASrcColor : TColor ) : Integer;
function  K_SelectColorDlg( var AColor : TColor ) : Boolean;

procedure K_GetSysFontFaceNamesList( AFontFaceNames : TStrings );

function  K_DateTimeToStr( ADateTime: TDateTime; AFmt : string = '' ) : string;
function  K_StrToDateTime( const AStr: string; ATimeParseFlag : Boolean = false; APParseErrFlag : PBoolean = nil ) : TDateTime;

function  K_FreeSpaceBufCheck( ABufSize: Integer ) : Boolean;
function  K_FreeSpaceMemCheck( ABufSize: Integer ) : Boolean;
type TK_FreeSpaceCheckFunc = function ( ABufSize: Integer ) : Boolean;
function  K_FreeSpaceSearchMax( AMax : Integer; ACheckFunc : TK_FreeSpaceCheckFunc;
                                ADPercentage : Integer = 0  ): Integer;
var K_FreeSpaceProfile : array [0..9] of LongWord;
procedure K_GetFreeSpaceProfile( AProfileSize : Integer = 0;
                                    ADPercentage : Integer = 0 );
function  K_GetFreeSpaceProfileStr( ADelim : string = ''; AFormat : string = '' ) : string;
procedure K_GetFreeSpaceInfo( ASL : TStrings; AProfileSize : Integer = 0;
                              ADPercentage : Integer = 0 );
function  K_GetStringFromVarRec( APVarRec : PVarRec; const ADefVal : string ): string;
function  K_GetWinUserDocumentsPath( const ASubFolder : string = '' ) : string;
procedure K_GetWinEnvironmentStrings( AStrings : TStrings );
var
  K_WinEnvironmentStrings : TStrings;
procedure K_GetWinEnvStrings( );
procedure K_GetFileVersionInfo( AFilePath : string; APFieldName, APFieldValue: PString; AFieldCount : Integer );
procedure K_GetAppVersionInfo( APFieldName, APFieldValue: PString; AFieldCount : Integer );

function  K_StringWinEnvMListReplace( const ASrc : string;
                        AUndefMacroMode : TK_UndefMacroMode = K_ummSaveMacro;
                        APErrNum : PInteger = nil ) : string;
procedure K_SListWinEnvMListReplace( ASList : TStrings;
                        AUndefMacroMode : TK_UndefMacroMode = K_ummSaveMacro );

procedure K_SortMemIniSection( AMemIni : TMemIniFile; const ASectName : string;
                               ACaseSensitive : Boolean = FALSE );
function  K_EncodeXMLChars( const AStr : string  ) : string;
function  K_AnalizeStreamBOMBytes( const AStream: TStream ): TN_TextEncoding;
function  K_EncodeLoginPassword( const ALogin, APassword : string ) : string;
function  K_DecodeLogin( const AEncData : string ) : string;


var
  K_SelectCustomColors : array [0..15] of Integer;
  K_CharNumList : TStringList;
  K_CompareKeyAndStrTokenizer : TK_Tokenizer;

const
  K_NumCharTab0 : string =
    ' !#%&()*+,-./0123456789:;<=>?@ABCDEFGHIJ'+
    'KLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqr'+
    'stuvwxyz{|}~'+
    Chr($80)+Chr($81)+Chr($82)+Chr($83)+Chr($84)+Chr($85)+Chr($86)+Chr($87)+
    Chr($88)+Chr($89)+Chr($8A)+Chr($8B)+Chr($8C)+Chr($8D)+Chr($8E)+Chr($8F)+
    Chr($90)+Chr($91)+Chr($92)+Chr($93)+Chr($94)+Chr($95)+Chr($96)+Chr($97)+
             Chr($99)+Chr($9A)+Chr($9B)+Chr($9C)+Chr($9D)+Chr($9E)+Chr($9F)+
    Chr($A0)+Chr($A1)+Chr($A2)+Chr($A3)+Chr($A4)+Chr($A5)+Chr($A6)+Chr($A7)+
    Chr($A8)+Chr($A9)+Chr($AA)+Chr($AB)+Chr($AC)+Chr($AD)+Chr($AE)+Chr($AF)+
    Chr($B0)+Chr($B1)+Chr($B2)+Chr($B3)+Chr($B4)+Chr($B5)+Chr($B6)+Chr($B7)+
    Chr($B8)+Chr($B9)+Chr($BA)+Chr($BB)+Chr($BC)+Chr($BD)+Chr($BE)+Chr($BF)+
    'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ';
  K_NumCharTab1 : string =
    ' !#%&()*+,-./0123456789:;<=>?@ABCDEFGHIJ'+
    'KLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqr'+
    'stuvwxyz{|}~'+
    'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ';
  K_ValidCharTab0 : string =
    ' "!#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJ'+
    'KLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqr'+
    'stuvwxyz{|}~'+
    Chr($80)+Chr($81)+Chr($82)+Chr($83)+Chr($84)+Chr($85)+Chr($86)+Chr($87)+
    Chr($88)+Chr($89)+Chr($8A)+Chr($8B)+Chr($8C)+Chr($8D)+Chr($8E)+Chr($8F)+
    Chr($90)+Chr($91)+Chr($92)+Chr($93)+Chr($94)+Chr($95)+Chr($96)+Chr($97)+
             Chr($99)+Chr($9A)+Chr($9B)+Chr($9C)+Chr($9D)+Chr($9E)+Chr($9F)+
    Chr($A0)+Chr($A1)+Chr($A2)+Chr($A3)+Chr($A4)+Chr($A5)+Chr($A6)+Chr($A7)+
    Chr($A8)+Chr($A9)+Chr($AA)+Chr($AB)+Chr($AC)+Chr($AD)+Chr($AE)+Chr($AF)+
    Chr($B0)+Chr($B1)+Chr($B2)+Chr($B3)+Chr($B4)+Chr($B5)+Chr($B6)+Chr($B7)+
    Chr($B8)+Chr($B9)+Chr($BA)+Chr($BB)+Chr($BC)+Chr($BD)+Chr($BE)+Chr($BF)+
    'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ';

/////////////////////////////////////////////
// RasterFrame Actions Indexes (80 - 99):
//
  K_ActCorPict          = 80;
  K_ActCMEAddVObj1      = 81;
  K_ActCMEAddVObj2      = 82;
  K_ActCMEMoveVObj      = 83;
  K_ActCMEIsodensity    = 84;
  K_ActCMERubberRect    = 85;
  K_ActCMEFlashLightMode= 86;
//
// end of RasterFrame Actions Indexes:
/////////////////////////////////////////////

/////////////////////////////////////////////
//  Application Memory State Control Object
//

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_AMSCObj
type TK_AMSCObj = class // Application Memory State Control Object
  AMSCCheckLevel   : Integer; // Check Level Parameter
  AMSCObjsList     : TList;   // Checked Objects List
  AMSCObjExecProcs : array of TN_CheckObjExecProcObj; // Checked Objects 
                                                      // Routines
  constructor Create();
  destructor Destroy(); override;
  procedure AMSCheckObjAdd( APObj : Pointer; ACheckProcObj : TN_CheckObjExecProcObj );
  procedure AMSCheckObjRemove( APObj : Pointer );
  procedure AMSCheckExec( const ACheckID : string );
  procedure AMSCheckDump( const ADumpStr : string );
end;

var
  K_AMSCObj : TK_AMSCObj;

//
// end of Application Memory State Control Object
/////////////////////////////////////////////

/////////////////////////////////////////////
//  Self Memory Stream
//

type TK_MSBufResizeFunc   =  function( ASize: Longint ) : Pointer of object;
//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_SelfMemStream
type TK_SelfMemStream = class(TCustomMemoryStream) // Self Memory Stream
private
  MSBufResizeFuncObj : TK_MSBufResizeFunc;
protected

  MSPBArray : TN_PBArray;
  function MSBArraySetSize( ANewSize: Longint ) : Pointer;
public
  constructor CreateMemStream( APMem : Pointer; AMemSize : Integer;
                               ABufResizeFuncObj : TK_MSBufResizeFunc = nil;
                               APos : Longint = 0 );
  constructor CreateBArrrayStream( var ABArray : TN_BArray; APos: Longint = 0 );
  function  Write( const ABuffer; ACount: Longint ): Longint; override;
  procedure LoadFromStream( AStream: TStream );
  procedure LoadFromFile( const AFileName: string );
  procedure SetSize( ANewSize: Longint ); override;
end;

//
// end of Self Memory Stream
/////////////////////////////////////////////

///////////////////////////////////////////// 
//  Form Close Timer
//

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_FormCloseTimer
//******************************************************* TK_FormCloseTimer ***
// Needed to auto close Dialog Message Forms Possible Event Sequence 1)
// OnTimerProc, OnTimerFormCloseQuery, OnTimerFormDeactivate 2) 
// OnTimerFormDeactivate, OnTimerFormCloseQuery 3) OnTimerFormCloseQuery, 
// OnTimerFormDeactivate
//
type TK_FormCloseTimer = class(TTimer) //
  constructor CreateByForm( AFCTFormToClose : TForm; AInterval : Integer );
public
  FCTFormToClose : TForm;
  FCTOnFormCloseProc : TN_ProcObj;
  procedure OnTimerProc( Sender: TObject );
  procedure OnTimerFormDeactivate( Sender: TObject );
  procedure OnTimerFormCloseQuery(Sender: TObject; var CanClose: Boolean);

end;

//
// end of Form Close Timer
/////////////////////////////////////////////

function K_CompressStream( ASrcStream, ADstStream : TStream;
                           AComprLevel: Integer; ASrcDataSize : Integer = 0 ): Integer;
function K_GetUncompressedSize( ASrcStream : TStream ): integer;
function K_DecompressStream( ASrcStream, ADstStream : TStream ): integer;

function K_ScanInteger( var AStr: string ): integer;
function K_ScanFloat     ( var AStr: string ): float;
function K_ScanDouble    ( var AStr: string ): double;
function K_ScanToken     ( var AStr: string ): string;

function K_ChangeIntValByStrVal( var AIntVal : Integer; const AStrVal : string ) : string;
function K_ChangeFloatValByStrVal( var AFloatVal : Double; const AStrVal : string ) : string;

var
  K_SaveTextAsAnsi : Boolean = TRUE;
//  K_SaveTextAsAnsi : Boolean = FALSE;
function K_SaveTextToStreamWithBOM( const AText: string; AStream: TStream ) : Integer;
function K_LoadTextFromStreamWithBOM( var AText: string; AStream : TStream ): Boolean;

type TK_DumpObj = class
  DLogFname : string;
  DLogDInd  : Integer;
  DLogBufSL : TStringList;
  DLogPref  : string;
  constructor Create( const ADumpFName : string; const ADumpPref : string = '' );
  destructor  Destroy; override;
  procedure DumpStr0( ADumpStr: string);
  procedure DumpStr( ADumpStr: string);
end; // type TK_DumpObj

type TK_RedrawDelayObj = class
  OnRedrawProcObj : TK_NotifyProc;
  OnCheckDirectRedraw : TK_FuncObjBool;
  RedrawTimer : TTimer;
  RedrawRequestCount : Integer; // Redraw Request counter Inside Check Period delay
  RedrawRequestBound : Integer; // Minimal Redraw Request counter for check redraw delay consider mouse stop if RedrawRequestCount < RedrawRequestBound
  TimerInterval : Integer;
  WaitCountBound1 : Integer; // Check mouse speed delay in timer ticks
  WaitCountBound2 : Integer; // Initial Wait counter of Check mouse speed delay for not 1-st integration delay in timer ticks
  // WaitCountBound1 - WaitCountBound2 is real integration delay
  WaitCount : Integer; // Timer events counter inside the Check delay
  constructor Create( AOnRedrawProcObj : TK_NotifyProc = nil );
  destructor  Destroy; override;
  procedure InitCheckAttrsDef;
  procedure InitCheckAttrsByTime( ATimeSec : Double; ASpeedChangeFactor : Double = 0 );
  procedure InitRedraw( AOnRedrawProcObj : TK_NotifyProc;
                        ADirectlyRedrawCheckFuncObj : TK_FuncObjBool = nil );
  procedure Redraw();
  procedure OnTimer( Sender: TObject );
  function  MouseUpCheck() : Boolean;
  function  SkipDirectRedraw() : Boolean;
end; // type TK_RedrawDelayObj

implementation

uses Math, StrUtils, Clipbrd, ShlObj, ActiveX, TlHelp32, ZLib,
  N_Lib0;

const
  K_ValidCharTab1 : string =
//    #13#10+
    ' "!#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJ'+
    'KLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqr'+
    'stuvwxyz{|}~'+
    'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ';
var
  K_NumCharTab : string;
  K_ValidCharTab : string;
  K_CharNumBound : Integer;

var
  K_LastMacroName : string;
//  K_MRProcess : TK_MRProcess;


{*** TK_MRProcess ***}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess\Create
//***************************************************** TK_MRProcess.Create ***
// Object constructor
//
//     Parameters
// AMRStart - start MacroCall substring
// AMRFin   - final MacroCall substring
// AMRFunc  - MacroCall processing function of object (can be used
//   TK_MRProcess.ConstValueMRFunc, TK_MRProcess.ValueFromStringsMRFunc
//   TK_MRProcess.TextAssemblingMRFunc or some user function)
//
constructor TK_MRProcess.Create( AMRStart, AMRFin: string;
                                 AMRFunc: TK_MRFunc );
begin
  MacroStart := K_mtMacroStart0;
  MacroFin := K_mtMacroFin0;
  FMRFunc := ValueFromStringsMRFunc;
  TAVL := THashedStringlist.Create;
  TAVL.CaseSensitive := false;
  SetLength( IfLevelResults, 10 );
  IfLevel := 0;

  MacroFlags := [K_mrfUseOldMacroSep];
  SetParsingContext( AMRStart, AMRFin, AMRFunc );
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess\Destroy
//**************************************************** TK_MRProcess.Destroy ***
// Object destructor
//
destructor TK_MRProcess.Destroy;
begin
  TAT.Free;
  TAVL.Free;
  inherited;
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess\SetMacroStart
//********************************************** TK_MRProcess.SetMacroStart ***
// Set start MacroCall substring
//
//     Parameters
// AMRStart - start MacroCall substring
//
procedure TK_MRProcess.SetMacroStart( const AMRStart: string );
begin
  FMacroStart := AMRStart;
  MStartLeng := Length(FMacroStart);
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess\SetMacroFin
//************************************************ TK_MRProcess.SetMacroFin ***
// Set final MacroCall substring
//
//     Parameters
// AMRFin - final MacroCall substring
//
procedure TK_MRProcess.SetMacroFin( const AMRFin: string );
begin
  FMacroFin := AMRFin;
  MFinLeng := Length(FMacroFin);
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess\StringMacroReplace
//***************************************** TK_MRProcess.StringMacroReplace ***
// Process Text with built-in MacroCalls
//
//     Parameters
// AResBuf     - buffer string for resulting Value
// ASrcBuf     - source Text buffer with built-in MacroCalls
// AUsedLength - length of used part of sours text buffer
// APErrNum    - pointer to resulting Integer variable with Text processing 
//               errors counter, if =nil then errors counter not used
// Result      - Returns length of resulting Value in SBuf:
//#F
//    >0  - length of resulting Value in buffer string
//    =0  - resulting Value is absent in buffer string because no
//          MacroCalls in source Text were found (so real resulting Value is source Text)
//    =-1 - MacroCalls in source Text were found but resulting value is Empty String
//#/F
//
function TK_MRProcess.StringMacroReplace( var AResBuf: string; const ASrcBuf: string;
                                          AUsedLength : Integer = 0;
                                          APErrNum: PInteger = nil ): Integer;
var
  CSPos, CPos, MPos, BPos : Integer;
  MName, MValue : string;
  MRResult : TK_MRResult;
  FMFin : string;
  FMSLeng : Integer;
  FMFLeng : Integer;
  FoundMacroFlag : Boolean;
  MacroWasProcessed : Boolean;


  procedure CopyToSBuf( const Src; DLeng : Integer );
  var PSrc : PChar;
  begin
    PSrc := @Src;
    if (K_mfrSkipResultEmptyLines in MacroFlags) and
       (BPos >= 3)                                and
       (N_IntCRLF = TN_PTwoChars(@AResBuf[BPos-2])^) then
      while (DLeng >= 2) and (N_IntCRLF = TN_PTwoChars(PSrc)^) do begin
        Dec( DLeng, 2 );
        Inc( PSrc, 2 );
      end;
    if DLeng <= 0 then Exit;
    K_SetStringCapacity( AResBuf, BPos + DLeng );
    Move( PSrc^, AResBuf[BPos], DLeng * SizeOf(Char) );
    Inc( BPos, DLeng );
  end;

  function GetStartMacroPos( SPos : Integer ) : Integer;
  begin
    Result := N_PosEx( FMacroStart, ASrcBuf, SPos, AUsedLength );

    if (Result = 0) and
       (FMacroStart <> K_mtMacroStart) and
       (K_mrfUseOldMacroSep in MacroFlags) then
    begin
      Result := N_PosEx( K_mtMacroStart, ASrcBuf, SPos, AUsedLength );
      if Result = 0 then Exit;
      FMFin := K_mtMacroFin;
      FMSLeng := 2;
      FMFLeng := 2;
    end
    else
    begin
      FMFin := FMacroFin;
      FMSLeng := MStartLeng;
      FMFLeng := MFinLeng;
    end;
  end;

begin
//*** string list processing loop
  Result := 0;
  if APErrNum <> nil then APErrNum^ := 0;
  if AUsedLength <= 0 then AUsedLength := Length(ASrcBuf);

  if AUsedLength = 0 then Exit;
  CPos := GetStartMacroPos( 1 );
  if CPos = 0 then Exit;
  CSPos := 1;
  BPos := 1;
  MRResult := K_mrrOK;
  FoundMacroFlag := false;
  MacroWasProcessed := false;
  repeat
  //*** Copy Text Portion
    if not (K_mrfSkipMacroResult in MacroFlags) and
       (MRResult <> K_mrrSkipNextText) then
      CopyToSBuf( ASrcBuf[CSPos], CPos - CSPos );
    Inc( CPos, FMSLeng );

  //*** parse Macro name
    if FMFin = '' then
    begin //!!
      MPos := CPos;          //!!
    end else                 //!!
      MPos := N_PosEx( FMFin, ASrcBuf, CPos, AUsedLength );

    if MPos <> 0 then
    begin // found macro fin
      MacroWasProcessed := true;
      MName := Copy( ASrcBuf, CPos, MPos - CPos );
      CPos := MPos + FMFLeng;
      CSPos := CPos;
  //*** Get Macro Result
      MRResult := FMRFunc( MName, MValue );
      if MRResult = K_mrrUndef then
      begin
        if Assigned(MRUndefMacroFunc) then
          MValue := MRUndefMacroFunc( MName, Self )
        else
          MValue := GetUMNameResult( MName );
{
        case UndefMacroMode of
          K_ummPutErrText:
            MValue := ' <!-- Macro Error - name "'+MName+'" not found -->!!! ';
          K_ummRemoveResult, K_ummRemoveMacro:
            MValue := '';
          K_ummSaveMacro:
            MValue := MacroStart+MName+MacroFin;
          K_ummSaveMacroName:
            MValue := MName;
        else
          MValue := '';
        end;
}
        if APErrNum <> nil then Inc(APErrNum^);
      end;
  //*** Copy Macro Result
      if not (K_mrfSkipMacroResult in MacroFlags) then
      begin
        MPos := Length( MValue );
        if MPos > 0 then
          CopyToSBuf( MValue[1], MPos );
      end;
      FoundMacroFlag := true;
    end
    else
      CSPos := CPos - FMSLeng;
    CPos := GetStartMacroPos( CPos );
  until CPos = 0;

//*** move SrcText Tail to Buffer
  if not (K_mrfSkipMacroResult in MacroFlags) and
     (MRResult <> K_mrrSkipNextText) then begin
    MPos := Length(ASrcBuf) - CSPos + 1;
    if MPos > 0 then
      CopyToSBuf( ASrcBuf[CSPos], MPos );
  end;
  Result := BPos - 1;
  if (FoundMacroFlag and (Result = 0))
     or not MacroWasProcessed then Result := -1;
end; // end of TK_MRProcess.StringMacroReplace

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess\SetParsingContext
//****************************************** TK_MRProcess.SetParsingContext ***
// Set Text parsing context
//
//     Parameters
// AMRStart - start MacroCall substring
// AMRFin   - final MacroCall substring
// AMRFunc  - MacroCall processing function of object (can be used
//            TK_MRProcess.ConstValueMRFunc, TK_MRProcess.ValueFromStringsMRFunc
//            TK_MRProcess.TextAssemblingMRFunc or some user function)
//
procedure TK_MRProcess.SetParsingContext( const AMRStart : string = ''; const AMRFin : string = '';
                                          AMRFunc: TK_MRFunc = nil );
begin
  if Assigned(AMRFunc) then
    FMRFunc := AMRFunc;
  InitTextAssemblingContext;
  if AMRStart <> '' then
    MacroStart := AMRStart;
  if AMRFin <> '' then
    MacroFin := AMRFin;
end; // end of TK_MRProcess.SetParsingContext

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess\ConstValueMRFunc
//******************************************* TK_MRProcess.ConstValueMRFunc ***
// MacroCall processing routine, returns same MacroValue from 
// TK_MRProcess.CRValue
//
//     Parameters
// MacroName   - value of MacroCall
// MacroResult - resulting value instead of MacroName
// Result      - Returns K_mrrOK for each call
//
// Can be used by TK_MRProcess.StringMacroReplace for context replace all 
// occurrencies of some substring to given substring.
//
function TK_MRProcess.ConstValueMRFunc( MacroName : string; var MacroResult : string ) : TK_MRResult;

begin
  MacroResult := CRValue;
  Result := K_mrrOK;
end; // end of TK_MRProcess.ConstValueMRFunc

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess\ValueFromStringsMRFunc
//************************************* TK_MRProcess.ValueFromStringsMRFunc ***
// MacroCall processing routine, returns MacroValue retrieved from 
// TK_MRProcess.MList by given MacroName
//
//     Parameters
// MacroName   - MacroName value of MacroCall
// MacroResult - resulting value instead of MacroName
// Result      - Returns K_mrrOK if proper Value fore given MacroName was found
//
// Can be used by TK_MRProcess.StringMacroReplace for context replace MacroCalls
// to Values given by List of Name=Value substitutes.
//
function TK_MRProcess.ValueFromStringsMRFunc( MacroName: string;
  var MacroResult: string ): TK_MRResult;

  function GetMValue( CMList : TStrings; CMName : string; var ARes : TK_MRResult ) : string;
  var
    NMList : TStrings;
    NName : string;
    Ind, NInd  : Integer;
    CValue : string;
  label MacroError;
  begin
  // test if Strings Index Used
    Result := '';
    if CMName = '' then Exit;
    if CMList = nil then goto MacroError;

    ARes := K_mrrOK;
    NName := '';
    if CMName[1] = K_mtMacroInd then
    begin // CMName >> [IndexInList - value in CMList[Index] element
//*** Use List Index
      Ind := StrToIntDef( Copy( CMName, 2, Length(CMName) ), -1 );
      if (Ind > -1) and (Ind < CMList.Count ) then
        Result := CMList.Strings[Ind]
      else
        goto MacroError;
    end   // if CMName[1] = K_mtMacroInd then
    else
    begin // if CMName[1] <> K_mtMacroInd then
//*** Use List Name

      // Check MultiLevel Name
      NInd := Pos( K_mtMacroNameSep, CMName );
      if NInd > 1 then
      begin // use SubMacroList >> CMName >> NameLevel1.NameLevel2 ...
        NName := Copy( CMName, NInd + 1, Length(CMName) );
        CMName := Copy( CMName, 1, NInd - 1 );
        NInd := 0; // clear NInd to prevent use it as default value flag
      end;  // end of MultiLevel Name detection

      // Check default Macro Value
      if K_mrfUseInlineMacroValue in MacroFlags then
      begin
        NInd := Pos( K_mtMacroValueSep, CMName );
        if NInd > 1 then
        begin // CMName >> Name=Value
          CValue := CMName;
          CMName := Copy( CMName, 1, NInd - 1 );
        end;
      end;

      K_LastMacroName := CMName;

      // check if is defined parsed Macro Name
      Ind := CMList.IndexOfName( CMName );
      if Ind >= 0 then
      begin // Macro Name is defined
        if NName = '' then // Single Level Macro Name
          Result := CMList.ValueFromIndex[Ind];
//        Result := CMList.Strings[Ind];
//        Result := Copy( Result, Pos( '=', Result ) + 1, Length(Result) );
      end   // Macro Name is defined
      else
      begin // Macro Name is undefined
        if NInd > 1 then
        begin // Exists Default Macro Value
          Result := Copy( CValue, NInd + 1, Length(CValue) );
        end
        else
        begin // Macro Name is undefined
MacroError: // **********
          ARes := K_mrrUndef;
          Exit;
        end;
      end;  // Macro Name is undefined

      if NName <> '' then
      begin // try next level name
        NMList := TStrings(CMList.Objects[Ind]);
        if NMList <> nil then
          Result := GetMValue( NMList, NName, ARes );
      end; // if NName <> '' then - try next level name

    end; // if CMName[1] <> K_mtMacroInd then
  end; // function GetMValue

begin
  MacroResult := GetMValue( MList, MacroName, Result  );
end; // end of TK_MRProcess.ValueFromStringsMRFunc

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess\TextAssemblingMRFunc
//*************************************** TK_MRProcess.TextAssemblingMRFunc ***
// MacroCall processing routine, process given TextAssembling Instruction
//
//     Parameters
// MacroInstr  - Macro Instruction (value of MacroCall)
// MacroResult - resulting value instead of Macro Instruction (returns empty 
//               string if OK, or source Macro Instruction if it contains error)
// Result      - Returns
//#F
//    K_mrrSkipNextText - if next part of sorce processing string will not be copied to
//                        resulting Text
//    K_mrrOK           - if next part of sorce processing string will be copied to
//                        resulting Text
//#/F
//
// Can be used by TK_MRProcess.StringMacroReplace for conditional text 
// assembling. Macro Instruction rules are following:
//#F
// MacroInstr ::= if CONDITION|end|else|elseif CONDITION|var VarName = VarValue
// CONDITION  ::= EXPRESSION or/and EXPRESSION
// EXPRESSION ::= EXPRESSION|not EXPRESSION
// EXPRESSION ::= VARIABLE EQ/NE VARIABLE|VARIABLE EQ/NE CONSTANT
//#/F
//
function TK_MRProcess.TextAssemblingMRFunc( MacroInstr: string;
                           var MacroResult: string ): TK_MRResult;
var
  Command, Token1, Token2 : string;
  NInd : Integer;
  CurExprResult : Boolean;
const
//0 - Level IF true; 1 - Skip Level Text ; 2 - Level IF false; 3 - Skip Global Text Global
IF_Level_TRUE          = 0;
IF_Level_SkipTextLevel = 1;
IF_Level_FALSE         = 2;
IF_Level_SkipTextGlob  = 3;

  procedure CalcExpression;
  var
    Inverse1Operand{!!, OpFlag} : Boolean;
    OperandVInd : Integer;
    PrevExprResult : Boolean;
    ExprContCommand : Integer; // 0 - or; 1 - and
    VarVal : string;
    OpInd : Integer;
    OpRes : Integer;

  label ParseExprCont;

    procedure LinkToPrevResult;
    begin
      case ExprContCommand of
      0: CurExprResult := PrevExprResult or  CurExprResult;
      1: CurExprResult := PrevExprResult and CurExprResult;
      end;
    end;

  begin
    CurExprResult := true;
    ExprContCommand := -1;
    while TAT.hasMoreTokens(true) and                             // Expr continue
          ((ExprContCommand <> 0) or not CurExprResult) do begin  // Break if disjunction operand is TRUE
      PrevExprResult := CurExprResult;
   //*** Parse 1-st Operand
      Token1 := TAT.nextToken(true);
      Inverse1Operand := false;
      if SameText( Token1, K_mtMacroExprNOT ) then begin
   //*** Set Single Operand Inversion Mode and Parse 1-st Operand
        Token1 := TAT.nextToken(true);
        Inverse1Operand := true;
      end;

      NInd := TAVL.IndexOfName(Token1);

      CurExprResult := NInd >= 0;
      if CurExprResult then begin
        VarVal := TAVL.ValueFromIndex[NInd];
        CurExprResult := N_StrToBool( VarVal );
      end;

      if Inverse1Operand then
        CurExprResult := not CurExprResult;

      if not TAT.hasMoreTokens(true) then begin
        LinkToPrevResult();
        Exit;
      end;

   //*** Parse Operation
      Token2 := TAT.nextToken(true);

      OpInd := -1;
      if SameText( Token2, K_mtMacroExprEQ ) then
        OpInd := 0
      else if SameText( Token2, K_mtMacroExprNEQ ) then
        OpInd := 1
      else if SameText( Token2, K_mtMacroExprLT ) then
        OpInd := 2
      else if SameText( Token2, K_mtMacroExprLE ) then
        OpInd := 3
      else if SameText( Token2, K_mtMacroExprGT ) then
        OpInd := 4
      else if SameText( Token2, K_mtMacroExprGE ) then
        OpInd := 5;

      if OpInd = -1 then begin
        LinkToPrevResult();
        goto ParseExprCont;
      end;
{!!
      OpFlag := false;
      if SameText( Token2, K_mtMacroExprNEQ ) then
        OpFlag := true
      else if not SameText( Token2, K_mtMacroExprEQ ) then begin
        LinkToPrevResult();
        goto ParseExprCont;
      end;
}
      if not TAT.hasMoreTokens(true) then begin
        LinkToPrevResult();
        Exit;
      end;
   //*** Parse 2-nd Operand
      Token1 := TAT.nextToken(true);

      if NInd >= 0 then begin
   //*** Compare Operands
        OperandVInd := TAVL.IndexOfName(Token1);
        if OperandVInd >= 0 then
          Token1 := TAVL.ValueFromIndex[OperandVInd];

        OpRes := CompareText( VarVal, Token1 );
        case OpInd of
        0: CurExprResult := OpRes  = 0; // EQ
        1: CurExprResult := OpRes <> 0; // NE
        2: CurExprResult := OpRes  < 0; // LT
        3: CurExprResult := OpRes <= 0; // LE
        4: CurExprResult := OpRes  > 0; // GT
        5: CurExprResult := OpRes >= 0; // GE
        end;
{!!
        CurExprResult := OpFlag xor SameText( Token1, VarVal );
}
        if Inverse1Operand then
          CurExprResult := not CurExprResult;
      end;

   //*** Link to Prev Result
      LinkToPrevResult();
   //*** Parse Link Operation
      Token2 := TAT.nextToken(true);

ParseExprCont:
      if SameText( Token2, K_mtMacroExprOR ) then
        ExprContCommand := 0
      else if SameText( Token2, K_mtMacroExprAND ) then
        ExprContCommand := 1
      else Exit;
    end;
  end;

  procedure ExecIF;
  begin
    CalcExpression();
    if CurExprResult then
      IfLevelResults[IfLevel] := IF_Level_TRUE
    else
      IfLevelResults[IfLevel] := IF_Level_FALSE;
  end;

begin

  if TAT = nil then begin
    TAT := TK_Tokenizer.Create( '', ' ,=', '""''''' );
    TAT.setNonRecurringDelimsInd( 1 );
  end;
  TAT.setSource( MacroInstr );
  Command := TAT.nextToken(true);

  Result := K_mrrOK;
  MacroResult := '';

  if SameText(Command, K_mtMacroOpVAR) then begin
  //*** VAR
    if (IfLevelResults[IfLevel] = IF_Level_TRUE) and TAT.hasMoreTokens(true) then
    begin
      Token1 := TAT.nextToken(true);
      NInd := TAVL.IndexOfName(Token1);
      if NInd >= 0 then
        Token2 := TAVL.ValueFromIndex[NInd]
      else
        Token2 := '';
      if TAT.hasMoreTokens(true) then
        Token2 := TAT.nextToken(true);
      Token1 := Token1 + '=' + Token2;
      if NInd < 0 then
        TAVL.Add( Token1 )
      else
        TAVL.Strings[NInd] := Token1;
    end;
  end
  else
  if SameText(Command, K_mtMacroOpIFL) then
  begin
  //*** IFL
    Inc(IfLevel);
    if IfLevelResults[IfLevel - 1] <= IF_Level_SkipTextLevel then
    begin
      ExecIF();
      if IfLevelResults[IfLevel] = IF_Level_FALSE then
        IfLevelResults[IfLevel] := IF_Level_SkipTextLevel;
    end
    else
      IfLevelResults[IfLevel] := IF_Level_SkipTextGlob;
  end
  else
  if SameText(Command, K_mtMacroOpIF) then
  begin
  //*** IF
    Inc(IfLevel);
    if IfLevelResults[IfLevel - 1] <= IF_Level_SkipTextLevel then
      ExecIF()
    else
      IfLevelResults[IfLevel] := IF_Level_SkipTextGlob;
  end
  else
  if SameText(Command, K_mtMacroOpEND) then
  begin
  //*** END
    Dec(IfLevel);
  end
  else
  if SameText(Command, K_mtMacroOpENDIF) then
  begin
  //*** ENDIF
    if IfLevelResults[IfLevel - 1] <= IF_Level_SkipTextLevel then
      ExecIF()
    else
      IfLevelResults[IfLevel] := IF_Level_SkipTextGlob;
  end
  else
  if SameText(Command, K_mtMacroOpELSE) then
  begin
  //*** ELSE
    if (IfLevelResults[IfLevel] = IF_Level_FALSE) or
       (IfLevelResults[IfLevel] = IF_Level_SkipTextLevel) then
      IfLevelResults[IfLevel] := IF_Level_TRUE
    else
    if IfLevelResults[IfLevel] = IF_Level_TRUE then
      IfLevelResults[IfLevel] := IF_Level_SkipTextGlob;
  end
  else
  if SameText(Command, K_mtMacroOpELSEIF) then
  begin
  //*** ELSEIF
    if (IfLevelResults[IfLevel] = IF_Level_FALSE) or
       (IfLevelResults[IfLevel] = IF_Level_SkipTextLevel) then
      ExecIF()
    else
      IfLevelResults[IfLevel] := IF_Level_SkipTextGlob;
  end
  else
  begin
    MacroResult := MacroInstr;
    Result := K_mrrUndef;
  end;

  if (Result = K_mrrOK) and (IfLevelResults[IfLevel] <> IF_Level_TRUE) then
    Result := K_mrrSkipNextText;


end; // end of TK_MRProcess.TextAssemblingMRFunc

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess\AddTextAssemblingVar
//*************************************** TK_MRProcess.AddTextAssemblingVar ***
// Add new Variable and its Value to Text Assembling Variables List
//
//     Parameters
// NameAndValue - variable Name and Value (Name=Value)
//
// Used to add Variable to Text Assembling Variables List instead of adding 
// directly from assembling text by MacroExpression (var Name=Value).
//
procedure TK_MRProcess.AddTextAssemblingVar( NameAndValue: string );
begin
  if Pos( '=', NameAndValue ) = 0 then NameAndValue := NameAndValue+'=';
  TAVL.Add( NameAndValue );
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess\InitTextAssemblingContext
//********************************** TK_MRProcess.InitTextAssemblingContext ***
// Initialize TextAssembling Context by given Text Assembling Variables List
//
//     Parameters
// VList - new Text Assembling Variables List
//
// If VList is not assigned then current Text Assembling Variables List would be
// cleared
//
procedure TK_MRProcess.InitTextAssemblingContext( VList: TStrings = nil );
begin
  if VList = nil then
    TAVL.Clear
  else
    TAVL.Assign( VList );
  IfLevel := 0;
  IfLevelResults[IfLevel] := 0;
end; //end of procedure TK_MRProcess.InitTextAssemblingContext

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess\GetTextAssemblingVars
//************************************** TK_MRProcess.GetTextAssemblingVars ***
// Get Text Assembling Variables List
//
//     Parameters
// Result - Retuns Text Assembling Variables List Strings
//
function TK_MRProcess.GetTextAssemblingVars: TStrings;
begin
  Result := TAVL;
end; //end of TK_MRProcess.GetTextAssemblingVars

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_MRProcess\GetUMNameResult
//******************************************** TK_MRProcess.GetUMNameResult ***
// Get Resulting value for Undefined MacroName Case
//
//     Parameters
// AUMName - Undefined MacroName
// AUMMode - Undefined MacroName Result enumeration
// Result  - Retuns resulting value for Undefined MacroName
//
function TK_MRProcess.GetUMNameResult( AUMName: string ): string;
begin
  case UndefMacroMode of
    K_ummPutErrText:
      Result := ' <!-- Macro Error - name "'+AUMName+'" not found -->!!! ';
    K_ummRemoveResult, K_ummRemoveMacro:
      Result := '';
    K_ummSaveMacro:
      Result := MacroStart+AUMName+MacroFin;
    K_ummSaveMacroName:
      Result := AUMName;
  else
    Result := '';
  end;
end; //end of TK_MRProcess.GetUMNameResult

{*** end of TK_MRProcess ***}

{*** TK_TStringsList ***}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_TStringsList\AddString
//*********************************************** TK_TStringsList.AddString ***
// Add given String to TStringList by given index in TStringList List
//
//     Parameters
// Ind    - index of TStringList object in TStringList List (if =-1 then add new
//          TStringList to the end of the List and add given String to it)
// Str    - adding String
// Result - Returns index of TSrings Object to which new string was added
//
function TK_TStringsList.AddString(Ind: Integer; const Str: string) : Integer;
begin
  if Ind = -1 then begin
//*** Add New TStringList
    Ind := Count;
    Add( TStringList.Create );
  end;
  TStrings(Items[Ind]).Add( Str );
  Result := Ind;
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_TStringsList\AddObject
//*********************************************** TK_TStringsList.AddObject ***
// Add given String and Object to TStringList by given index in TStringList List
//
//     Parameters
// Ind    - index of TStringList object in TStringList List (if =-1 then add new
//          TStrings to the end of the List and add given String and Object to 
//          it)
// Str    - adding String
// Result - Returns index of TSrings Object to which new string was added
//
function TK_TStringsList.AddObject(Ind: Integer; const Str: string;
  Obj: TObject) : Integer;
begin
  Result := AddString(Ind, Str);
  with TStrings(Items[Result]) do Objects[Count - 1] := Obj;
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_TStringsList\Clear
//*************************************************** TK_TStringsList.Clear ***
// Clear TStringList List (free all TStringLists included in List)
//
procedure TK_TStringsList.Clear;
begin
  K_FreeTListObjects( Self );
  inherited;
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_TStringsList\TotalCount
//********************************************** TK_TStringsList.TotalCount ***
// Calculate resulting number of strings in all TStringLists included in List
//
function TK_TStringsList.TotalCount: Integer;
var i : Integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
    Result := Result + TStringList(Self[i]).Count;
end;

{*** end of TK_TStringsList ***}

{*** TK_XMLTagParser ***}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_XMLTagParser\Create
//************************************************** TK_XMLTagParser.Create ***
// XMLTagParser constructor
//
//     Parameters
// ASourceStr - source XML string which must be parsed
//
constructor TK_XMLTagParser.Create( ASourceStr : string );
begin
//  TagDelims  := ' =' +Chr($0D)+Chr($0A)+K_TagOpenChar+K_TagCloseFlag+K_TagCloseChar;
  TagDelims  := ' =' +Chr($0D)+Chr($0A)+K_TagOpenChar+K_TagCloseChar;
  DataDelims := ' ' +Chr($0D)+Chr($0A);
  AttrDelims := ' ='+Chr($0D)+Chr($0A)+K_TagCloseChar;
  DataBrackets := '""''''{}';
  St := TK_Tokenizer.Create( ASourceStr, dataDelims, dataBrackets );
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_XMLTagParser\Destroy
//************************************************* TK_XMLTagParser.Destroy ***
// XMLTagParser destructor
//
destructor TK_XMLTagParser.Destroy;
begin
  St.Free;
  inherited;
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_XMLTagParser\ParseTag
//************************************************ TK_XMLTagParser.ParseTag ***
// Parse next XML Tag  and its attributes
//
//     Parameters
// ACurPos   - text start parse position
// AttrsList - strings list for plasing Info about tag attributes and its values
// Result    - Returns parsed Tag Name
//
function TK_XMLTagParser.ParseTag( var ACurPos : Integer; AttrsList : TStrings ): string;
var
  i, tagTermIndex, LNum : Integer;
  AttrName : string;


label FinAttrList;
begin
  Result := '';
  St.CPos := ACurPos;
  if not St.hasMoreTokens or St.isBracketsStartFlag then Exit;
  St.setDelimiters(TagDelims);
  Result := St.nextToken;
  if Result[1] = K_TagCloseFlag then begin
    if St.Text[St.CPos -1] <> K_TagCloseChar then
      ACurPos := PosEx( K_TagCloseChar, St.Text, St.CPos ) + 1;
    St.setDelimiters(DataDelims);
    Exit;
  end else begin // get tag attributes
    LNum := 0;
    if St.Text[St.CPos -1] <> K_TagCloseChar then // check close tag
    begin
      St.setDelimiters(AttrDelims);

  //*** parse atributes
      while St.CPos <= St.TLength do begin
        tagTermIndex := St.CPos - 1;
        St.hasMoreTokens;
        for i := tagTermIndex to St.CPos - 1 do
          if St.Text[i] = K_TagCloseChar then
            goto FinAttrList;
        AttrName := St.nextToken;
        if AttrName = '' then break;
        AttrName := AttrName + '=' + St.nextToken;
        if LNum >= AttrsList.Count then // add new element
          AttrsList.Add( AttrName  )
        else                       // use existing
          AttrsList.Strings[LNum] := AttrName;
        Inc(LNum);
      end;

      raise TK_XMLTagParserError.Create(
        ( 'Tag terminator for tag "'+Result+'" is not found '+' - '+
                Copy( St.Text, ACurPos, St.TLength ) ) );

    end;

FinAttrList:
  //*** clear not used list elements
    while AttrsList.Count > LNum do
      AttrsList.Delete(LNum);

  end;
  St.setDelimiters(DataDelims);
  ACurPos := St.CPos;
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_XMLTagParser\SetSrc
//************************************************** TK_XMLTagParser.SetSrc ***
// Set given String as source string for tags parsing
//
//     Parameters
// ASourceStr - given new source string
//
procedure TK_XMLTagParser.SetSrc( ASourceStr: string );
begin
  St.setSource( ASourceStr );
end;

{*** end of TK_XMLTagParser ***}

{*** TK_IndIterator ***}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_IndIterator\AddIIDim
//************************************************* TK_IndIterator.AddIIDim ***
// Add next Dimension to Iterator
//
// APResult  - pointer to variable value with Resulting Index of ADimSize  - 
// Dimension capacity (number of indexes)
//
procedure TK_IndIterator.AddIIDim( APResult : Pointer; ADimSize: integer );
var
  Ind, NewSize: integer;
begin
  Ind := IINumDims;
  Inc( IINumDims );

  NewSize := Length(IIDimSizes);
  if K_NewCapacity( IINumDims, NewSize ) then begin
    SetLength( IIResPointers, NewSize );
    SetLength( IIDimSizes, NewSize );
    SetLength( IIDimCurValues, NewSize );
    SetLength( IIDimWeights, NewSize )
  end;
  IIResPointers[Ind] := APResult;
  IIDimSizes[Ind] := ADimSize;
  IIDimWeights[Ind] := 1;
  if Ind > 0 then
    IIDimWeights[Ind] := IIDimWeights[Ind - 1] * IIDimSizes[Ind - 1];
//  IIDimCurValues[Ind] := 0;

end; // end of procedure TK_IndIterator.AddIIDim

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_IndIterator\PrepIILoop
//*********************************************** TK_IndIterator.PrepIILoop ***
// Prepare Iterator Loop with current Iterator Digits
//
// ACount  - Loop Counter AISeed  - Random Generator Start value
//
procedure TK_IndIterator.PrepIILoop( ACount, AISeed: integer );
var
  IIPower : Integer;
begin
  SetLength( IIBoxUFlags, ACount );
  if ACount = 0 then Exit;
  FillChar( IIBoxUFlags[0], ACount, 0 );
  IIBoxUCount := 0;
  IIPower := IIDimWeights[IINumDims - 1] * IIDimSizes[IINumDims - 1];
  IIBoxStep := IIPower / ACount;
  IIRandSeed := AISeed; // initialize Random function
end; // end of procedure TK_IndIterator.PrepIILoop

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_IndIterator\GetNextIInds
//********************************************* TK_IndIterator.GetNextIInds ***
// Get next Iteration values of Digits
//
// Resulting values are returns to variables given for each digit by 
// TK_IndIterator.AddIIDim
//
procedure TK_IndIterator.GetNextIInds( );
var
  Ind, LCount, i, SCount : Integer;
  IMin, IMax, IInd : Int64;
  DInd : Double;

label StartSearch;

begin
  LCount := Length( IIBoxUFlags );
  if LCount = 0 then Exit;
  RandSeed := IIRandSeed;

StartSearch:
  SCount := Min( 10, LCount - IIBoxUCount);
//*** Random Search
  Ind := 0;
  for i := 1 to SCount do begin
    Ind := Random( LCount );
    if not IIBoxUFlags[Ind] then Break;
  end;

//*** Direct Search
  if IIBoxUFlags[Ind] then
    for i := 1 to LCount do begin
      Inc(Ind);
      if Ind >= LCount then Ind := 0;
      if not IIBoxUFlags[Ind] then Break;
    end;

  if not IIBoxUFlags[Ind] then begin
  //*** Set Indexes
    IIBoxUFlags[Ind] := true;
    Inc(IIBoxUCount);
  //*** Calc Full Index
    DInd := Ind * IIBoxStep;
    IMin := Ceil( DInd );
    IMax := Ceil( DInd + IIBoxStep ) - 1;
    IInd := RandomRange( IMin, IMax );
    K_NumberToDigits( IInd, @IIDimWeights[0], @IIDimCurValues[0], IINumDims );
  //*** Send Inds to Result Vars
    for i := 0 to IINumDims - 1 do
      PInteger(IIResPointers[i])^ := IIDimCurValues[i];
  end else begin
  //*** II Overflow - Clear and Try Again
    FillChar( IIBoxUFlags[0], LCount, 0 );
    IIBoxUCount := 0;
    goto StartSearch;
  end;
  IIRandSeed := RandSeed;
end; // end of procedure TK_IndIterator.GetNextIInds

{*** end of TK_IndIterator ***}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_PrepCharNumList
//******************************************************* K_PrepCharNumList ***
// Prepare data for future unpack packed JS texts
//
//     Parameters
// ANumCharTab - table of chars used to code numbers in pack algorithm
//
// Prepare Chars/Numbers List (K_CharNumList:TStrings) for unpack JS texts, 
// packed by SelfConstructed Pack Algorithm based on LZW/
//
// (unpacking JS texts is needed to test Pack Algorithm)
//
procedure K_PrepCharNumList( ANumCharTab : string );
var i : Integer;
begin
  if ANumCharTab = K_NumCharTab then Exit;
  K_NumCharTab := ANumCharTab;
  K_CharNumList.Sorted := false;
  K_CharNumBound := Length(K_NumCharTab) shr 1;
  for i := 1 to Length(K_NumCharTab) do
    K_CharNumList.AddObject( K_NumCharTab[i], TObject(i-1) );
  K_CharNumList.Sort;
end; // end of K_PrepCharNumList

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_FreeTStringsObjects
//*************************************************** K_FreeTStringsObjects ***
// Free objects in TStrings Objects property
//
//     Parameters
// SList - TStrings object
//
// Free only if value of Objects[i] is real object
//
procedure K_FreeTStringsObjects( SList : TStrings );
var i : Integer;
begin
  if SList <> nil then begin
    for i := 0 to SList.Count - 1 do
      if Integer(SList.Objects[i]) > 1000 then
        SList.Objects[i].Free
      else
        SList.Objects[i] := nil;
  end;
end; //*** end of K_FreeTStringsObjects

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_FreeTListObjects
//****************************************************** K_FreeTListObjects ***
// Free objects in TList elements
//
//     Parameters
// SList - TList object
//
// Free only if value of SList[i] is real object
//
procedure K_FreeTListObjects( SList : TList );
var i : Integer;
begin
  if SList <> nil then begin
    for i := 0 to SList.Count - 1 do
    if Integer(SList[i]) > 1000 then
      TObject(SList[i]).Free
    else
      SList[i] := nil;
  end;
end; //*** end of K_FreeTListObjects

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_FreeArrayObjects
//****************************************************** K_FreeArrayObjects ***
// Free objects in objects array
//
//     Parameters
// Arr          - objects array
// NilArrayFlag - if true then free memory occupied by array
//
// Free only if value of SList[i] is real object
//
procedure K_FreeArrayObjects( var Arr : TK_ObjectArray; NilArrayFlag : Boolean = true );
var i : Integer;
begin
  for i := 0 to High(Arr) do
    if Integer(Arr[i]) > 1000 then Arr[i].Free
    else
      Arr[i] := nil;
  if NilArrayFlag then Arr := nil;
end; //*** end of K_FreeArrayObjects

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_NewCapacity
//*********************************************************** K_NewCapacity ***
// Calculate new array capacity using realy needed array length
//
//     Parameters
// NewLeng  - needed array length
// Capacity - array length (capacity) needed to decrease memory reallocations
// Result   - Returns true if capacity is enlarged
//
function  K_NewCapacity( NewLeng : Integer; var Capacity : Integer ) : Boolean;
var Delta : Integer;
begin
  Result := true;
//  Capacity := 0;
  if NewLeng < 0 then Exit;
  if NewLeng > Capacity then begin
    if (NewLeng > 64) then begin
      if      NewLeng <  10000000 then
        Delta := NewLeng div 4
      else if NewLeng <  50000000 then
        Delta := 2000000 + NewLeng div 20
      else if NewLeng < 100000000 then
        Delta := 4000000 + NewLeng div 100
      else
        Delta := 5000000;
    end else if (NewLeng > 8) then
      Delta := 16
    else
      Delta := 4;
    Capacity := NewLeng + Delta;
  end else
    Result := false;
end; // end of K_NewCapacity

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetBArrayCapacity
//***************************************************** K_SetBArrayCapacity ***
// Set new length to given bytes array in consideration of array real capacity
//
//     Parameters
// BArray    - bytes array
// NewLength - needed array length
// Result    - Returns resulting bytes array capacity
//
// Resize given bytes array if necessary
//
function K_SetBArrayCapacity( var BArray : TN_BArray; NewLength : Integer ) : Integer;
var
  PrevCapacity : Integer;
  FillFlag : Boolean;
begin
  Result := Length(BArray);
  FillFlag := true;
  if NewLength < 0 then
  begin
    Result := 0;
    NewLength := -NewLength;
    FillFlag := False;
  end;
  PrevCapacity := Result;
  if K_NewCapacity( NewLength, Result ) then
  begin
    SetLength(BArray, Result);
    if FillFlag then
      FillChar(BArray[PrevCapacity], Result - PrevCapacity, 0);
  end;
end; //*** end of K_SetBArrayCapacity

//***************************************************** K_SetIArrayCapacity ***
// Set new length to given integers array in consideration of array real capacity
//
//     Parameters
// IArray    - integers array
// NewLength - needed array length
// Result    - Returns resulting integers array capacity
//
// Resize given integers array if necessary
//
function K_SetIArrayCapacity( var IArray : TN_IArray; NewLength : Integer ) : Integer;
var
  PrevCapacity : Integer;
  FillFlag : Boolean;
begin
  Result := Length(IArray);
  FillFlag := true;
  if NewLength < 0 then
  begin
    Result := 0;
    NewLength := -NewLength;
    FillFlag := False;
  end;
  PrevCapacity := Result;
  if K_NewCapacity( NewLength, Result ) then
  begin
    SetLength(IArray, Result);
    if FillFlag then
      FillChar(IArray[PrevCapacity], (Result - PrevCapacity) * SizeOf(Integer), 0);
  end;
end; //*** end of K_SetIArrayCapacity

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetStringCapacity
//***************************************************** K_SetStringCapacity ***
// Set new length to given string buffer in consideration of it's real capacity
//
//     Parameters
// StringBuf - string buffer
// NewLength - needed string buffer length
// Result    - Returns resulting string buffer capacity
//
// Resize given string buffer if necessary
//
function K_SetStringCapacity( var StringBuf : string; NewLength : Integer ) : Integer;
var
  PrevCapacity : Integer;
  FillFlag : Boolean;
begin
  Result := Length(StringBuf);
  FillFlag := true;
  if NewLength < 0 then begin
    Result := 0;
    NewLength := -NewLength;
    FillFlag := False;
  end;
  PrevCapacity := Result;
  if K_NewCapacity( NewLength, Result ) then begin
    SetLength(StringBuf, Result);
    if FillFlag then
      FillChar(StringBuf[PrevCapacity+1], (Result - PrevCapacity) * SizeOf(Char), 0);
  end;
end; //*** end of K_SetStringCapacity

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ReplaceStringChars
//**************************************************** K_ReplaceStringChars ***
// Replace string chars by given chars
//
//     Parameters
// Str    - source string
// RChars - string with replacing chars
// NChars - string with new chars, which must replace corresponding chars in Str
//
// If Str[i] = RChars[j] then Str[i] := NChars[ Min( j, Length(NChars) ) ]
//
procedure K_ReplaceStringChars( var Str: string; const RChars : string; const NChars : string );
var
  i, FInd, RCount : Integer;

begin
  RCount := Length(NChars);
  if RCount = 0 then Exit;
  for i := 1 to Length(Str) do begin
    FInd := Pos( Str[i], RChars );
    if FInd = 0 then continue;
    Str[i] := NChars[ Min( RCount, FInd ) ];
  end;

end; // end K_ReplaceStringChars

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CapitalizeWords
//******************************************************* K_CapitalizeWords ***
// Replace each Word Start Chars to upper case (Capitalize)
//
function K_CapitalizeWords( const AStr : string ) : string;
var
  i : Integer;
  ConvToUpperCase : Boolean;
begin
  Result := AStr;
  ConvToUpperCase := TRUE;
  for i := 1 to Length(Result) do
  begin
    if ConvToUpperCase and (Result[i] <> ' ') then
    begin
      ConvToUpperCase := FALSE;
      CharUpperBuff( @Result[i], 1 );
    end
    else
      ConvToUpperCase := not ConvToUpperCase and (Result[i] = ' ');
  end;
end; // K_CapitalizeWords

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetPureNameSize
//******************************************************* K_GetPureNameSize ***
// Get name pure size (without unique suffix)
//
//     Parameters
// Name   - string which contains constant part and unique suffix
// Result - Returns name constant part size (without unique suffix)
//
// Unique suffix has syntax - (UniqNumber). Is used while building unique IDB 
// object Name
//
function K_GetPureNameSize( const Name : string ) : Integer;
begin
  if (Length(Name) > 0) and ( Name[Length(Name)] = ')' ) then
    Result := Integer(StrRScan( PChar(Name), '(' )) -
                                      Integer(PChar(Name))
  else
    Result := -1;
  if Result < 0 then Result := Length( Name );
end; // end of K_GetPureNameSize

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_BuildUniqName
//********************************************************* K_BuildUniqName ***
// Build unique Name by replacing unique suffix
//
//     Parameters
// Name      - string which contains constant part and unique suffix
// MainSize  - constant name part size
// UniqIndex - new unique name suffix parameter
// Result    - Returns name with new unique suffix
//
function K_BuildUniqName ( const Name : string; MainSize,
                                        UniqIndex : Integer ) : string;
begin
  Result := '(' + IntToStr(UniqIndex) + ')';
  if MainSize > 0 then
    Result := Copy( Name, 1, MainSize ) + Result;
end; // end of K_BuildUniqName

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_IfExpandedFileName
//**************************************************** K_IfExpandedFileName ***
// Check if given FileName is expanded
//
//     Parameters
// FileName - check file name
// Result   - Returns true if file name was expanded to full Windows file path
//
function  K_IfExpandedFileName( const FileName : string ) : Boolean;
begin
  Result := (
     ( Length( FileName ) > 2 ) and
     ( ( FileName[2] = ':' )     or
       ( ( FileName[1] = '\' ) and
         ( FileName[2] = '\' ) ) )
  );
end; //*** end of K_IfExpandedFileName

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_IfURLReference
//******************************************************** K_IfURLReference ***
// Check if given FileName is Internet URL
//
//     Parameters
// FileName - check file name
// Result   - Returns true if file name is Internet URL
//
function  K_IfURLReference( const FileName : string ) : Boolean;
begin
  Result := ( Pos( 'http://', FileName ) = 1 );
end; //*** end of function K_IfExpandedFileName

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_LoadSMatrFromFile
//***************************************************** K_LoadSMatrFromFile ***
// Load Strings Matrix (Table) from given CSV or TXT file (Comma, Tab or Space 
// Separated Values format)
//
//     Parameters
// StrMatr - resulting String Matrix (first index - Row, second - Column)
// FName   - file name,
// SMF     - cells separator type in matrix text representation
// Result  - Returns true if given file exists
//
function K_LoadSMatrFromFile( var StrMatr: TN_ASArray;
                              const FName : string; SMF : TN_StrMatrFormat ): boolean;
var
  FL : TStringList;

begin
  Result := false;
  FL := TStringList.Create;
  if FileExists(FName) then begin
    FL.LoadFromFile(  FName );
    Result := true;
  end;
  K_LoadSMatrFromStrings( StrMatr, FL, SMF );
  FL.Free;
end; // end of K_LoadSMatrFromFile

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_LoadSMatrFromText
//***************************************************** K_LoadSMatrFromText ***
// Load Strings Matrix (Table) from given CSV or TXT Text (Comma, Tab or Space 
// Separated Values format)
//
//     Parameters
// StrMatr - resulting String Matrix (first index - Row, second - Column)
// SrcText - Source Text,
// SMF     - cells separator type in matrix text representation
//
procedure K_LoadSMatrFromText( var StrMatr: TN_ASArray;
                              const SrcText : string; SMF : TN_StrMatrFormat );
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  if (SMF = smfTab) or (SMF = smfClip) then
    K_SplitTDTextToStrings(SL, SrcText )
  else
    SL.Text := SrcText;
  K_LoadSMatrFromStrings( StrMatr, SL, SMF );
  SL.Free;
end; // end of K_LoadSMatrFromText

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SplitTDTextToStrings
//************************************************** K_SplitTDTextToStrings ***
// Split Tab delimited Text Matrix to strings, which contains matrix rows
//
//     Parameters
// SL      - resulting Strings
// SrcText - source Text string with matrix
//
procedure K_SplitTDTextToStrings( SL : TStrings; const SrcText: string );
var
  PF, P1, P2, P, Start: PChar;
  S, S1, S2: string;
  CellCotainsLF : Boolean;
  DLength : Integer;
begin
  SL.BeginUpdate;
  try
    SL.Clear;
    P := Pointer(SrcText);
    if P <> nil then
      while P^ <> #0 do begin
        Start := P;
        CellCotainsLF := false;
        repeat
//          while not (P^ in [#0, #10, #13]) do Inc(P);
          while (P^ <> #0) and (P^ <> #10) and (P^ <> #13) do Inc(P);
          if P^ = #10 then begin
            Inc(P);
            CellCotainsLF := true;
          end;
        until (P^ = #0) or (P^ = #13);
//        until P^ in [#0, #13];

        SetString(S, Start, P - Start);
        if P^ = #13 then Inc(P);
        if P^ = #10 then Inc(P);
        if CellCotainsLF and (Length(S) > 0) then begin
        // Remove Quotes from Cells with internal LF
          P1 := PChar(S);
          SetLength( S1, Length(S) );
          PF := PChar(S1);
          repeat
            Start := P1;
//            while not (P1^ in [#0, #10]) do Inc(P1);
            while (P1^ <> #0) and (P1^ <> #10) do Inc(P1);
            CellCotainsLF := P1^ = #10;
            // Search Cell Begin
            if not CellCotainsLF then begin
              DLength := P1 - Start;
              Move( Start^, PF^, DLength * SizeOf(Char) );
              Inc( PF, DLength );
            end else begin
              P2 := P1;
              while (P2 > Start) and (P2^ <> #9) do Dec(P2);
              if P2^ = #9 then Inc(P2);
              // Search Cell End
//              while not (P1^ in [#0, #9]) do Inc(P1);
              while (P1^ <> #0) and (P1^ <> #9) do Inc(P1);
              DLength := P2 - Start;
              // Move Prev Part of Line before Cell with LF
              Move( Start^, PF^, DLength * SizeOf(Char) );
              Inc( PF, DLength );
//              if CellCotainsLF then begin
              // Move Cell With LF to Str
                SetString( S2 , P2, P1 - P2 );
              // Dequote Str
                S2 := AnsiDequotedStr( S2, '"' );
              // Move Dequoted Str to Buffer
                DLength := Length(S2);
                Move( S2[1], PF^, DLength * SizeOf(Char) );
                Inc( PF, DLength );
//              end;
            end;
          until P1^ = #0;
          SetLength( S1, PF - PChar(S1) );
          S := S1;
        end;
        SL.Add(S);
      end;
  finally
    SL.EndUpdate;
  end;
end; // end of K_SplitTDTextToStrings

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_LoadSMatrFromStrings
//************************************************** K_LoadSMatrFromStrings ***
// Load Strings Matrix (Table) from given Strings (Comma or Tab or Space 
// Separated Values format)
//
//     Parameters
// StrMatr - resulting String Matrix (first index - Row, second - Column)
// SL      - source strings list,
// SMF     - cells separator type in matrix text representation
//
procedure K_LoadSMatrFromStrings( var StrMatr: TN_ASArray;
                                  SL : TStrings; SMF : TN_StrMatrFormat );
var
  BL : TStringList;
  i, RowInd, ColInd, j : integer;
  ST : TK_Tokenizer;
  isBracketsStart : Boolean;
  DChar : Char;
  Delim : Char;
  Delims : string;
  WW, UnrepDPos : Integer;
  CurToken : string;


  procedure StepNext1;
  begin
    ST.CPos := ST.CPos + 1;
    if (ST.Text[ST.CPos] = Delim) then
      ST.isNRDelimFindFlag := true;
  end;

begin
  StrMatr := nil;
  if SL.Count = 0 then Exit;

  SetLength( StrMatr, SL.Count );


  ST := TK_Tokenizer.Create( '', '', '""'  );
  if (SMF = smfCSV) or (SMF = smfTab) or (SMF = smfClip) then begin // CSV, Tab, or Clip
    if SMF = smfCSV then
      Delim := ';'
    else
      Delim := #$9;
    UnrepDPos := 1;
    Delims := Delim;
  end else begin
//    Delim := #$0; //??
    Delim := ' ';
    UnrepDPos := 2;
    Delims := ' ';
  end;
  ST.setDelimiters( Delims );
  ST.setNonRecurringDelimsInd( UnrepDPos );

  if SMF = smfClip then begin
    ST.DoubleBrackets := false;
    ST.setBrackets( '' );
  end else
    ST.DoubleBrackets := true;

  RowInd := 0;
  BL := TStringList.Create;
//***  Parsing Cell Values Loop
  for j := 0 to SL.Count - 1 do
  begin
    CurToken := SL[j];

    if CurToken = '' then Inc(RowInd)
    else
    begin
      ST.setSource( CurToken );
      ColInd := 0;
      if CurToken[1] = Delim then
        ST.isNRDelimFindFlag := true;
      while ST.hasMoreTokens(false) do
      begin
// Error while parsing tokens from string "1...";"2..." in CSV mode
// Token1 was finished on ';' char but because of isBracketsStart current position was shifted
// to Next Position to char '2' and Tokens Parsing was interrupted
//        isBracketsStart := ST.isBracketsStartFlag; // !!! old code
// so isBracketsStart flag was not block in CSV mode
        isBracketsStart := ST.isBracketsStartFlag and (SMF <> smfCSV); // !!! new code
        if (SMF = smfClip) and
           (ST.Text[ST.CPos] = '"') then
        begin
//*** Token Starts With Quote -> "
          ST.setBrackets( '""' );
          ST.DoubleBrackets := true;
          WW := ST.CPos;
          CurToken := ST.NextToken(false);
          ST.DoubleBrackets := false;
          ST.setBrackets( '' );
//??12.11.2006          if ST.CPos > ST.TLength then break;
          if ST.CPos > ST.TLength then
          begin
          //** Last Row Line Token starts with Quote but has no terminated Quote
            CurToken := '"'+CurToken;
          end
          else
          if (ST.Text[ST.CPos] <> #$9) then
          begin
          //** Quoted SubString in parsing Token - reparse token
            ST.CPos := WW;
            CurToken := ST.NextToken(false);
          end
          else
          begin
          //** Token is Quoted - add Quotes
            CurToken := '"'+CurToken+'"';
            isBracketsStart := true
          end;
//*** end of Token Starts With Quote -> "
        end
        else
          CurToken := ST.NextToken(false);

        if BL.Count = ColInd then
          BL.Add( CurToken )
        else
          BL[ColInd] := CurToken;
        Inc( ColInd );

    //*** if  Parsed Cell Value was Quoted  then  Inc(Parse Curent Pos)
    //    if isBracketsStart and
    //      (ST.Text[ST.CPos] <> #$D) then StepNext;
        if ST.CPos > ST.TLength then break;
        if isBracketsStart then StepNext1;
    //!!    if ST.CPos > ST.TLength then break; // Check was posed before >> if isBracketsStart then StepNext1

        ST.hasMoreTokens(false); // skip last spaces

        if ST.CPos > ST.TLength then break;
    //*** if  Next Cell Value is Quoted  then  CLear  Unrepeat Delim Flag
    // the case ...";"...
        if ST.Text[ST.CPos] = '"' then
          ST.isNRDelimFindFlag := false;

        DChar := ST.getDelimiter( true );
        if (DChar <> Delim) then break;
      end;
    //*** End of Row is find

    //*** if  End Of Row  then Put Cell Values To Matrix Current Row
      SetLength( StrMatr[RowInd], ColInd );
      for i := 0 to ColInd - 1 do
        StrMatr[RowInd, i] := BL[i];
      Inc(RowInd);
    end;
  //***  end of Parsing Cell Values Loop
  end;

  SetLength( StrMatr, RowInd );
  N_AdjustStrMatr( StrMatr );
  BL.Free;
end; // end of K_LoadSMatrFromStrings

{
//************************************************** K_LoadSMatrFromStrings ***
// load Strings Matrix (Table) from given strings list file
// (Comma or Tab Separated Values format)
//
// StrMatr     - resulting String Matrix (first index - Row, second - Column)
// SL          - strings list,
// SMF         - Strings data format
//
procedure K_LoadSMatrFromStrings( var StrMatr: TN_ASArray;
                                  SL : TStrings; SMF : TN_StrMatrFormat );
var
  BL : TStringList;
  i, RowInd, ColInd, j : integer;
  ST : TK_Tokenizer;
  isBracketsStart : Boolean;
  DChar : Char;
  Delim : Char;
  Delims : string;
  WW, UnrepDPos : Integer;
  CurToken : string;


  procedure StepNext1;
  begin
    ST.CPos := ST.CPos + 1;
    if (ST.Text[ST.CPos] = Delim) then
      ST.isNRDelimFindFlag := true;
  end;

begin
  StrMatr := nil;
  if SL.Count = 0 then Exit;

  SetLength( StrMatr, SL.Count );


  ST := TK_Tokenizer.Create( '', '', '""'  );
  if (SMF = smfCSV) or (SMF = smfTab) or (SMF = smfClip) then begin // CSV, Tab, or Clip
    if SMF = smfCSV then
      Delim := ';'
    else
      Delim := #$9;
    UnrepDPos := 1;
    Delims := Delim;
  end else begin
//    Delim := #$0; //??
    Delim := ' ';
    UnrepDPos := 2;
    Delims := ' ';
  end;
  ST.setDelimiters( Delims );
  ST.setNonRecurringDelimsInd( UnrepDPos );

  if SMF = smfClip then begin
    ST.DoubleBrackets := false;
    ST.setBrackets( '' );
  end else
    ST.DoubleBrackets := true;

  RowInd := 0;
  BL := TStringList.Create;
//***  Parsing Cell Values Loop
//  for j := 0 to SL.Count - 1 do begin
  j := 0;
  while ( j < SL.Count) do begin
    CurToken := SL[j];
    if CurToken = '' then //*** Empty Row Line
      Inc(RowInd)
    else begin            //*** Parse ROw Line
      ST.setSource( CurToken );
      ColInd := 0;
      if CurToken[1] = Delim then
        ST.isNRDelimFindFlag := true;
      while ST.hasMoreTokens(false) do begin
        isBracketsStart := ST.isBracketsStartFlag;
        if (SMF = smfClip) and
           (ST.Text[ST.CPos] = '"') then begin
//*** Token Starts With Quote -> "
          ST.setBrackets( '""' );
          ST.DoubleBrackets := true;
          WW := ST.CPos;
          CurToken := ST.NextToken(false);
          ST.DoubleBrackets := false;
          ST.setBrackets( '' );
          if ST.CPos > ST.TLength then begin
          //** Last Row Line Token starts with Quote but has no terminated Quote
            CurToken := '"'+CurToken;
          end else if (ST.Text[ST.CPos] <> #$9) then begin
          //** Quoted SubString in parsing Token - reparse token
            ST.CPos := WW;
            CurToken := ST.NextToken(false);
          end else begin
          //** Token is Quoted - add Quotes
            CurToken := '"'+CurToken+'"';
            isBracketsStart := true
          end;
//*** end of Token Starts With Quote -> "
        end else
          CurToken := ST.NextToken(false);

        if BL.Count = ColInd then
          BL.Add( CurToken )
        else
          BL[ColInd] := CurToken;
        Inc( ColInd );

    //*** if  Parsed Cell Value was Quoted  then  Inc(Parse Curent Pos)
    //    if isBracketsStart and
    //      (ST.Text[ST.CPos] <> #$D) then StepNext;
    //    if ST.CPos > ST.TLength then break;
        if isBracketsStart then StepNext1();
        if ST.CPos > ST.TLength then break;

        ST.hasMoreTokens(false); // skip last spaces

        if ST.CPos > ST.TLength then break;
    //*** if  Next Cell Value is Quoted  then  CLear  Unrepeat Delim Flag
    // the case ...";"...
        if ST.Text[ST.CPos] = '"' then
          ST.isNRDelimFindFlag := false;

        DChar := ST.getDelimiter( true );
        if (DChar <> Delim) then break;
      end; //*** End of Source StringList Row Parsing

    //*** if  End Of Row  then Put Cell Values To Matrix Current Row
      SetLength( StrMatr[RowInd], ColInd );
      for i := 0 to ColInd - 1 do
        StrMatr[RowInd, i] := BL[i];
      Inc(RowInd);
    end;
// End of Loop - Inc Loop Counter
    Inc(j);
  end; //***  end of Parsing Cell Values Loop

  SetLength( StrMatr, RowInd );
  N_AdjustStrMatr( StrMatr );
  BL.Free;
end; // end of function K_LoadSMatrFromStrings
}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\N_AdjustStrMatr
//********************************************************* N_AdjustStrMatr ***
// Adjust all matrix rows to have the same number of elements
//
//     Parameters
// AStrMatr  - String Matrix
// AColCount - given columns counter:
//#F
//   ColCount < 0 means that all rows lengths should be set by first row
//   ColCount = 0 means that all rows lengths should be set by max row
//   ColCount > 0 means that all rows lengths should be set by ColCount
//#/F
//
procedure N_AdjustStrMatr( AStrMatr: TN_ASArray; AColCount: integer = 0 );
var
  i: integer;
begin
  if AColCount < 0 then
    AColCount := Length( AStrMatr[0] )
  else if AColCount = 0 then
    for i := 0 to High(AStrMatr) do // calc MaxColInd
      AColCount := Max(AColCount, Length( AStrMatr[i] ) );
  for i := 0 to High(AStrMatr) do // make all rows to be same Length
    SetLength( AStrMatr[i], AColCount );

end; // end of N_AdjustStrMatr

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_AddMemIni
//************************************************************* K_AddMemIni ***
// Add given source TMemIniFile data to resulting TMemIniFile
//
//     Parameters
// ASrcMemIni - source TMemIniFile object data
// ADstMemIni - resulting TMemIniFile object data
//
// Data from source TMemIniFile replace corresponding data in resulting
// TMemIniFile object. Data absent in resulting TMemIniFile object will be added
// to it.
//
procedure K_AddMemIni( ASrcMemIni, ADstMemIni : TMemIniFile );
var
  i, j : Integer;
  WWSL : TStringList;
  WSL : TStrings;
  SectName : string;
begin
  WWSL := TStringList.Create;
//  WSL := TStringList.Create;
  ASrcMemIni.ReadSections( WWSL );

  for i := 0 to WWSL.Count - 1 do
  begin
    SectName := WWSL[i];
    WSL := TStrings( WWSL.Objects[i] );
//    ASrcMemIni.ReadSectionValues( SectName, WSL );
    for j := 0 to WSL.Count - 1 do
      ADstMemIni.WriteString( SectName, WSL.Names[j], WSL.ValueFromIndex[j] );
  end;
  WWSL.Free;
//  WSL.Free;

end; // end of K_AddMemIni

//********************************************* K_AddStringsToMemIniSection ***
// Set given MemIni file section by given strings
//
//     Parameters
// AMemIni   - TMemIniFile object
// ASectName - TMemIniFile section name
// ASValues  - Strings with section values
//
procedure K_AddStringsToMemIniSection( AMemIni : TMemIniFile; const ASectName : string; ASValues: TStrings );
var
  i : integer;
begin
  for i := 0 to ASValues.Count - 1 do
    AMemIni.WriteString( ASectName, ASValues.Names[i], ASValues.ValueFromIndex[i] );
end; // K_AddStringsToMemIniSection

{
//**************************************************** K_DateTimeToFileTime ***
// TDateTime to FILETIME
//
procedure K_DateTimeToFileTime( DateTime : TDateTime; var AFileTime : TFileTime );
var
F1SystemTime : TSystemTime;
begin
// DateTimeToFileDate
  DateTimeToSystemTime(DateTime, F1SystemTime);
  SystemTimeToFileTime(F1SystemTime, AFileTime);
end; // end of

//**************************************************** K_FileTimeToDateTime ***
// converts FILETIME to TDateTime
//
procedure K_FileTimeToDateTime( const AFileTime : TFileTime;
                                                out DateTime : TDateTime   );
var
F1SystemTime : TSystemTime;
begin
  FileTimeToSystemTime( AFileTime, F1SystemTime );
  DateTime := SystemTimeToDateTime( F1SystemTime );
end;
}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ForceDirPath
//********************************************************** K_ForceDirPath ***
// Create a new directory, creating all needed parent directories
//
//     Parameters
// APath   - needed path
// Result - Returns true if needed path exists or all directories were
//          successfully created, returns false if it could not create a needed
//          directory.
//
// Function is wrapper to Pascal ForceDirectories. Creates a new directory as
// specified in Path, which must be a fully-qualified path name. If the
// directories given in the path do not yet exist, attempts to create them.
//
function K_ForceDirPath( const APath : string ) : Boolean;
begin
  try
    Result := ForceDirectories( APath );
  except
    Result := false;
  end;
end; // end of K_ForceDirPath

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ForceFilePath
//********************************************************* K_ForceFilePath ***
// Create a new directory for given file path, creating all needed parent
// directories
//
//     Parameters
// AFilePath  - needed file path
// Result - Returns true if needed path exists or was successfully created
//
// Extracts path to directory which contains given file and then call
// K_ForceDirPath
//
function K_ForceFilePath( const AFilePath : string ) : Boolean;
begin
  Result := K_ForceDirPath( ExtractFilePath(AFilePath) );
end; // K_ForceFilePath

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ForceDirPathDlg
//******************************************************* K_ForceDirPathDlg ***
// Show dialogue for confirmation of new directories creation
//
//     Parameters
// ADirPath - needed directories path
// Result  - Returns true if needed path exists or was successfully created
//
// If needed path doesn't exist show dialogue to confirm directories creation
//
function  K_ForceDirPathDlg( const ADirPath : string ) : Boolean;
begin

  Result := DirectoryExists( ADirPath );
  if not Result and
     (MessageDlg('Path '+ADirPath+' not found. Create?', mtWarning, mbOKCancel, 0 ) = mrOk) then
    Result := K_ForceDirPath( ADirPath );

end; //*** end of K_ForceDirPathDlg

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ForceDirPathDlgRus
//**************************************************** K_ForceDirPathDlgRus ***
// Show dialogue for confirmation of new directories creation n Russian
//
//     Parameters
// ADirPath - needed directories path
// Result  - Returns true if needed path exists or was successfully created
//
// If needed path doesn't exist show dialogue to confirm directories creation
//
function  K_ForceDirPathDlgRus( const ADirPath : string ) : Boolean;
begin

  Result := DirectoryExists( ADirPath );
  if not Result and
     (MessageDlg('Ïóòü '+ADirPath+' íå íàéäåí. Ñîçäàòü?', mtWarning, mbOKCancel, 0 ) = mrOk) then
    Result := K_ForceDirPath( ADirPath );

end; //*** end of K_ForceDirPathDlgRus

{$WARN SYMBOL_DEPRECATED OFF} //???
{$WARN SYMBOL_DEPRECATED ON}  //???

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetFileDOSAge
//********************************************************* K_GetFileDOSAge ***
// Get given file age as TDateTime
//
//     Parameters
// AFName  - file name
// Result - Returns given file age as TDateTime or 0 if file doesn't exist
//
function  K_GetFileDOSAge( const AFName : string ) :  TDateTime;
begin
  Result := 0;
  if not FileExists( AFName ) then Exit;
{$IF SizeOf(Char) = 2} // Wide Chars (Delphi 2010) Types and constants
  FileAge( AFName, Result );
{$ELSE} //*************** Ansi Chars (Delphi 7) Types and constants
  Result := FileDateToDateTime(FileAge(AFName));
{$IFEND}
end; // function  K_GetFileDOSAge

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetFileAge
//************************************************************ K_GetFileAge ***
// Get given file age as TDateTime
//
//     Parameters
// AFName  - file name
// Result - Returns given file age as TDateTime or 0 if file doesn't exist
//
function  K_GetFileAge( const AFName : string ) :  TDateTime;
var
  Handle: THandle;
  FindData: TWin32FindData;
  LocalFileTime: TFileTime;
  SystemTime : TSystemTime;
begin
  Handle := FindFirstFile(PChar(AFName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
    begin
      FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
      FileTimeToSystemTime(LocalFileTime, SystemTime );
      Result := SystemTimeToDateTime( SystemTime );
      Exit;
    end;
  end;
  Result := 0;
end; // function  K_GetFileAge

//********************************************************* K_GetFileAgeDAV ***
// Get given file age as TDateTime for WEB DAV
//
//     Parameters
// AFName  - file name
// Result - Returns given file age as TDateTime or 0 if file doesn't exist
//
function K_GetFileAgeDAV(const AFName : string) :TDateTime;   ////Igor
var
  Handle: THandle;
  FindData: TWin32FindData;
  LocalFileTime: TFileTime;
  SystemTime : TSystemTime;
//  dtf: TDateTime;
  MyPath, MyFile: string;
begin
  Result := 0;
  MyPath := ExtractFilePath(AFName) + '*';
  MyFile := ExtractFileName(AFName);
  Handle := FindFirstFile(PChar(MyPath), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
     repeat
       if (FindData.cFileName = MyFile) then
       begin
         FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
         FileTimeToSystemTime(LocalFileTime, SystemTime );
         Result := SystemTimeToDateTime( SystemTime );
         break;
       end;
     until not Windows.FindNextFile(Handle, FindData);
     Windows.FindClose(Handle);
  end;
//  Result := dtf;
end; // function  K_GetFileAgeDAV

//************************************************************ L_GetFileAge ***
// Get given file age as TDateTime for WEB DAV Lomodurov
//
//     Parameters
// AFName  - file name
// Result - Returns given file age as TDateTime or 0 if file doesn't exist
//
function L_GetFileAge(const AFName : string) :TDateTime;   ////Igor
var
  Handle: THandle;
  FindData: TWin32FindData;
  LocalFileTime: TFileTime;
  SystemTime : TSystemTime;
  dtf: TDateTime;
  MyPath, MyFile: string;
begin
  dtf := 0;
  MyPath := ExtractFilePath(AFName) + '*';
  MyFile := ExtractFileName(AFName);
  Handle := FindFirstFile(PChar(MyPath), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
     repeat
       if (FindData.cFileName = MyFile) then
       begin
         FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
         FileTimeToSystemTime(LocalFileTime, SystemTime );
         dtf := SystemTimeToDateTime( SystemTime );
       end;
     until not Windows.FindNextFile(Handle, FindData);
     Windows.FindClose(Handle);
  end;
  Result := dtf;
end; // function  L_GetFileAge

//************************************************************ K_SetFileAge ***
// Set file contents age given as TDateTime
//
//     Parameters
// AFName - file name
// ADT    - file contents age
// Result - Returns TRUE if file contents age is set successfully
//
function  K_SetFileAge( const AFName : string; ADT : TDateTime ) : Boolean;
var
  Handle: THandle;
  LocalFileTime: TFileTime;
  FileTime, FileCreationTime, FileAccessTime : TFileTime;
  SystemTime : TSystemTime;

begin

  Handle := CreateFile( PChar(AFName), GENERIC_WRITE, FILE_SHARE_READ, nil,
                        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_WRITE_THROUGH,
                        0 );
  Result := GetFileTime( Handle, @FileCreationTime, @FileAccessTime, @FileTime );
  if Result then
  begin
    DateTimeToSystemTime( ADT, SystemTime );
    SystemTimeToFileTime( SystemTime, LocalFileTime );
    LocalFileTimeToFileTime( LocalFileTime, FileTime );
    Result := SetFileTime( Handle, @FileCreationTime, @FileAccessTime, @FileTime );
  end;
  Windows.CloseHandle(Handle);

end; // function  K_SetFileAge

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CompareFilesAge
//******************************************************* K_CompareFilesAge ***
// Compare Windows files age
//
//     Parameters
// SrcFName  - source file name
// DestFName - destination file name
// Result    - Returns =0 - 2, depends on source and destination files age
//#F
// 0 - destination file doesn't exist,
// 1 - destination file is older then source file,
// 2 - destination file is newer,
// 3 - source file doesn't exist
//#/F
//
function  K_CompareFilesAge( const SrcFName, DestFName : string ) : Integer;
var
  SFDT, DFDT : TDateTime;
begin
  SFDT := K_GetFileAge( SrcFName );
  Result := 3;
  if SFDT = 0 then Exit;
  DFDT := K_GetFileAge( DestFName );
  Result := 0;
  if DFDT = 0 then Exit;
  if DFDT < SFDT then
    Result := 1
  else
    Result := 2;
end; //*** end of K_CompareFilesAge

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_TryCreateFileStream
//*************************************************** K_TryCreateFileStream ***
// Try to create TFileStream
//
//     Parameters
// AFName - file name
// AMode  - indicates how the file is to be opened
//#F
//   The open mode must be one of the following values:
// fmCreate	Create a file with the given name. If a file with the given name exists, open the file in write mode.
// fmOpenRead	Open the file for reading only.
// fmOpenWrite	Open the file for writing only. Writing to the file completely replaces the current contents.
// fmOpenReadWrite	Open the file to modify the current contents rather than replace them.
//
//   The share mode must be one of the following values:
// fmShareCompat	Sharing is compatible with the way FCBs are opened.
// fmShareExclusive	Other applications can not open the file for any reason.
// fmShareDenyWrite	Other applications can open the file for reading but not for writing.
// fmShareDenyRead	Other applications can open the file for writing but not for reading.
// fmShareDenyNone	No attempt is made to prevent other applications from reading from or writing to the file.
//#/F
// Result - Returns created TFileStream or nil if attempt fails
//
// Try to create TFileStream and wait about 10 seconds if needed
//
function  K_TryCreateFileStream( const AFName : string; AMode: Word ) : TFileStream;
var
  i : Integer;
begin
  for i := 1 to 500 do
  begin
    Result := nil;
    try
      Result := TFileStream.Create( AFName, AMode );
      Exit;
    except
      sleep(20);
    end;
  end;
end; //*** end of K_TryCreateFileStream

//*************************************************** K_AddStringToTextFile ***
// Add given string to given file
//
//     Parameters
// AFileName - file name to store
// AStr      - string to add
//
procedure K_AddStringToTextFile( const AFileName, AStr : string );
var
  F: TextFile;
  WSTR : string;
begin
  if AFileName = '' then Exit;
  try
    WSTR := AStr;
    if (K_NotAddedStrings <> nil) and (K_NotAddedStrings.Count > 0) then
      WSTR := K_NotAddedStrings.Text + AStr;
    Assign( F, AFileName );
    if not FileExists( AFileName ) then
      Rewrite( F )
    else
      Append( F );
    WriteLn( F, WSTR );
    Flush( F );
    Close( F );
    if (K_NotAddedStrings <> nil) then
     K_NotAddedStrings.Clear;
  except
    if K_NotAddedStrings <> nil then
      K_NotAddedStrings.Add(WSTR);
  end;
end; // procedure K_AddStringToTextFile


//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CopyFile
//************************************************************** K_CopyFile ***
// Copy Windows file
//
//     Parameters
// SrcFName      - source file name
// DestFName     - destination file name
// CopyFileFlags - copy file flags set
// Result        - Returns 0 - 5, depends on source and destination files age 
//                 and existence
//#F
// 0 - OK
// 1 - not copy because destination file readonly (even for newer)
// 2 - not copy because destination file is newer
// 3 - source file doesn't exist
// 4 - couldn't copy
// 5 - couldn't create path for destination file
//#/F
//
function  K_CopyFile( const SrcFName, DestFName : string; CopyFileFlags : TK_CopyFileFlags = [] ) : Integer;
var
  Attrs : Integer;
  CRes : Integer;
begin
  CRes := K_CompareFilesAge( SrcFName, DestFName );
// 0 - destination file doesn't exist,
// 1 - destination file is older then source file,
// 2 - destination file is newer,
// 3 - source file doesn't exist
  Result := CRes;

  //*** Process Dest Newer State
  if (CRes = 2) and (K_cffOverwriteNewer in CopyFileFlags) then
    Result := 0;

  //*** Process Dest Readonly State
  if (CRes > 0) and (Result < 2) then
  begin
  // destination file exist and can be owerwrite - check readonly mode
    Result := 0;  // Change Result to OK (for Result = 1)
    Attrs := FileGetAttr(DestFName);
    if (Attrs and faReadOnly) <> 0 then
    begin
      if (K_cffOverwriteReadOnly in CopyFileFlags) then
      begin
        Attrs := (Attrs or faReadOnly) xor faReadOnly;
        FileSetAttr( DestFName, Attrs );
      end
      else
        Result := 1;  // Set Readonly result
    end; // if (Attrs and faReadOnly) <> 0 then
  end; // if (CRes > 0) and (Result < 2) then

  //*** Copy File if OK
  if Result = 0  then
  begin
    if K_ForceFilePath( DestFName ) then
    begin
      if not CopyFile( PChar(SrcFName), PChar( DestFName ), false ) then
        Result := 4
    end
    else
      Result := 5;
  end;
end; //*** end of K_CopyFile

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CopyFolderFiles
//******************************************************* K_CopyFolderFiles ***
// Copy Windows files from source to destination directory
//
//     Parameters
// SPath         - source directory path
// DPath         - destination directory path
// CopyPat       - copy files name pattern (default '*.*')
// CopyFileFlags - copy file flags set
// Result        - Returns TRUE if all specified files subtree is copied
//
function K_CopyFolderFiles( const SPath, DPath : string;
          const CopyPat : string= '*.*'; CopyFileFlags : TK_CopyFileFlags = [] ) : Boolean;
var
  F: TSearchRec;
  SName, DName : string;
begin
  Result := TRUE;

  if FindFirst( SPath + '*.*', faAnyFile, F ) = 0 then
    repeat
      if F.Name[1] = '.' then continue;
      SName := SPath+F.Name;
      DName := DPath+F.Name;
      if (F.Attr and faDirectory) <> 0 then
        Result := Result and K_CopyFolderFiles( IncludeTrailingPathDelimiter( SName ),
                                        IncludeTrailingPathDelimiter( DName ),
                                        CopyPat, CopyFileFlags )
      else
      if (CopyPat = '*.*') or
         K_CheckTextPattern( F.Name, CopyPat, TRUE ) then
        Result := Result and (K_CopyFile( SName, DName, CopyFileFlags ) = 0);
    until FindNext( F ) <> 0;
  FindClose( F );
end; //*** end of K_CopyFolderFiles

{$T-}
procedure A_CopyAll(const SrcPath, DestPath: string);
var
  OpStruc: TSHFileOpStruct;
  frombuf, tobuf: Array [0..128] of Char;
Begin
  FillChar( frombuf, Sizeof(frombuf), 0 );
  FillChar( tobuf, Sizeof(tobuf), 0 );

  StrPCopy(frombuf, IncludeTrailingPathDelimiter(SrcPath) + '*.*');
  StrPCopy(tobuf, DestPath);

  With OpStruc do
  begin
    wFunc:= FO_COPY;
    pFrom:= @frombuf;
    pTo:=@tobuf;
    fFlags:= FOF_NOCONFIRMATION or FOF_RENAMEONCOLLISION or FOF_SIMPLEPROGRESS or FOF_NOCONFIRMMKDIR;
    fAnyOperationsAborted:= False;
    hNameMappings:= Nil;
    lpszProgressTitle:= Nil;
  end;

  ShFileOperation( OpStruc );
end;
{$T+}

//************************************************* K_StoreUndeletedFileName ***
// Store file name to undeleted files list
//
//     Parameters
// AFileName  - file name to store
//
procedure K_StoreUndeletedFileName( const AFileName : string );
begin
  if (K_UnDeletedFileNames = nil) or
     not FileExists(AFileName) then Exit;
  K_UnDeletedFileNames.Add(AFileName);
end; //*** end of K_StoreUndeletedFileName

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DeleteFile
//************************************************************ K_DeleteFile ***
// Delete Windows file
//
//     Parameters
// AFileName        - source file name
// ADeleteFileFlags - delete file flags
// Result           - Returns TRUE if file is deleted or file doesn't exists
//
function K_DeleteFile( const AFileName : string; ADeleteFileFlags : TK_DelOneFileFlags = [] ) : Boolean;
begin
  Result := TRUE;
  if not FileExists( AFileName ) then Exit;
  if K_dofDeleteReadOnly in ADeleteFileFlags then
    FileSetAttr( AFileName, (FileGetAttr(AFileName) or faReadOnly) xor faReadOnly );
  Result := DeleteFile( AFileName );
  if not Result and not (K_dofSkipStoreUndelNames in ADeleteFileFlags) then
    K_StoreUndeletedFileName(AFileName);
end; //*** end of K_DeleteFile

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DeleteFolderFilesEx
//*************************************************** K_DeleteFolderFilesEx ***
// Delete Windows files from given directory
//
//     Parameters
// SPath        - directory path
// UndelList    - strings to save undeleted file names
// DeletePat    - delete files name pattern (default '*.*')
// DelFileFlags - delete files flags set
//
procedure K_DeleteFolderFilesEx( const SPath : string; UndelList : TStrings;
                                const DeletePat : string= '*.*';
                                DelFileFlags : TK_DelFolderFilesFlags = [K_dffRecurseSubfolders] );
var
  F: TSearchRec;
  FName : string;
  FPat : string;
begin
if SPath = '' then Exit; // Precaution to prevent wrong files deletion
  FPat := DeletePat;
  if K_dffRecurseSubfolders in DelFileFlags then
    FPat := '*.*';
  if FindFirst( SPath + FPat, faAnyFile, F ) = 0 then
    repeat
      if F.Name[1] = '.' then continue;
      FName := SPath + F.Name;
      if (F.Attr and faDirectory) <> 0 then
      begin
        if K_dffRecurseSubfolders in DelFileFlags then
        begin
          K_DeleteFolderFilesEx( IncludeTrailingPathDelimiter( FName ), UndelList,
                                 DeletePat, DelFileFlags );
          RemoveDir( FName );
        end;
      end
      else
      if (DeletePat = '*.*')                           or
          not (K_dffRecurseSubfolders in DelFileFlags) or
          K_CheckTextPattern( F.Name, DeletePat ) then
      begin
        if K_dffRemoveReadOnly in DelFileFlags then
        begin
          F.Attr := (F.Attr or faReadOnly) xor faReadOnly;
          FileSetAttr( FName, F.Attr );
        end;
        if not DeleteFile( FName ) then
        begin
          if UndelList <> nil then
            UndelList.Add( FName );
        end;
//          K_StoreUndeletedFileName(FName);
      end;

    until FindNext( F ) <> 0;
  FindClose( F );
end; //*** end of K_DeleteFolderFilesEx

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DeleteFolderFiles
//***************************************************** K_DeleteFolderFiles ***
// Delete Windows files from given directory
//
//     Parameters
// SPath        - directory path
// DeletePat    - delete files name pattern (default '*.*')
// DelFileFlags - delete files flags set
//
procedure K_DeleteFolderFiles( const SPath : string; const DeletePat : string= '*.*';
                               DelFileFlags : TK_DelFolderFilesFlags = [K_dffRecurseSubfolders] );
begin
  K_DeleteFolderFilesEx( SPath, K_UnDeletedFileNames, DeletePat, DelFileFlags );
end; //*** end of K_DeleteFolderFiles

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CountFolderFiles
//****************************************************** K_CountFolderFiles ***
// Count Windows files in given directory
//
//     Parameters
// ASPath          - directory path
// ACountPat       - count files name pattern (default '*.*')
// ACountFileFlags - Count files flags set (only K_dffRecurseSubfolders is 
//                   actual)
//
function K_CountFolderFiles( const ASPath : string; const ACountPat : string= '*.*';
                               ACountFileFlags : TK_DelFolderFilesFlags = [K_dffRecurseSubfolders] ) : Integer;
var
  F: TSearchRec;
  FName : string;
  FPat : string;
begin
  Result := 0;
  FPat := ACountPat;
  if K_dffRecurseSubfolders in ACountFileFlags then
    FPat := '*.*';
  if FindFirst( ASPath + FPat, faAnyFile, F ) = 0 then
    repeat
      if F.Name[1] = '.' then continue;
      FName := ASPath + F.Name;
      if (F.Attr and faDirectory) <> 0 then begin
        if K_dffRecurseSubfolders in ACountFileFlags then
          Result := Result + K_CountFolderFiles( IncludeTrailingPathDelimiter( FName ),
                                                 ACountPat, ACountFileFlags );
      end else if (ACountPat = '*.*')                              or
                   not (K_dffRecurseSubfolders in ACountFileFlags) or
                   K_CheckTextPattern( F.Name, ACountPat ) then
        Inc( Result );

    until FindNext( F ) <> 0;
  FindClose( F );
end; //*** end of K_CountFolderFiles

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ScanFilesTree
//********************************************************* K_ScanFilesTree ***
// Windows files Tree-Walk starting from given directory
//
//     Parameters
// ASPath    - start directory path
// ATestFunc - test file function
// AFNamePat - files name pattern (default '*.*')
// AScanFolders - check folders by files name pattern
// AScanLevel - current files tree level
// Result    - Returns TRUE if Tree-Walk was not broken (is needed for
//             recursive call)
//
function  K_ScanFilesTree( const ASPath : string;
                           ATestFunc : TK_TestFileFunc;
                           const AFNamePat : string = '*.*';
                           AScanFolders : Boolean = FALSE;
                           AScanLevel : Integer = 0 ) : Boolean;
var
  F: TSearchRec;
  FName : string;
  ScanResult : TK_ScanTreeResult;
  CurFNamePat, CurFName : string;
begin
  Result := true;
  Inc(AScanLevel);
  if (K_ScanFilesTreeMaxLevel <> 0) and (AScanLevel > K_ScanFilesTreeMaxLevel) then Exit; // Precaution

  CurFNamePat := UpperCase(AFNamePat);
  if CurFNamePat = '' then
    CurFNamePat := '*.*';

  ScanResult := K_tucOK;
  if FindFirst( ASPath + '*.*', faAnyFile, F ) = 0 then
    repeat
      if F.Name[1] = '.' then continue;
      FName := ASPath + F.Name;
      CurFName := UpperCase(F.Name);
      if (F.Attr and faDirectory) <> 0 then
      begin // Check Directory

        if AScanFolders or (K_ScanFilesTreeMaxLevel = AScanLevel) then
        begin
          ScanResult := K_tucOK;
          if (AFNamePat = '*.*') or K_CheckTextPattern( CurFName, CurFNamePat ) then
            ScanResult := ATestFunc( ASPath, IncludeTrailingPathDelimiter(F.Name), AScanLevel );
        end
        else
          ScanResult := ATestFunc( FName, '', AScanLevel );

        Result := ScanResult <> K_tucSkipScan;
        if Result                           and
           (ScanResult <> K_tucSkipSibling) and
           (ScanResult <> K_tucSkipSubTree) then
          Result := K_ScanFilesTree( IncludeTrailingPathDelimiter( FName ),
                                     ATestFunc, AFNamePat, AScanFolders,
                                     AScanLevel );
      end
      else // Check File
      if (AFNamePat = '*.*') or K_CheckTextPattern( CurFName, CurFNamePat ) then
        ScanResult := ATestFunc( ASPath, F.Name, AScanLevel );

    until (FindNext( F ) <> 0) or
          not Result           or
          (ScanResult = K_tucSkipSibling);
  FindClose( F );

end; //*** end of K_ScanFilesTree

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_RenameExistingFile
//**************************************************** K_RenameExistingFile ***
// Change existing Windows file name to previous version file name
//
//     Parameters
// FileName - renaming file name
// Result   - Returns renamed file full name or '' if given file does not exist
//
// Previous version file name is created by replacing file extension 1-st char
// to '~'
//
function K_RenameExistingFile( const FileName : string ) : string;
var Ext : string;
begin
  Result := '';
  if FileExists( FileName ) then
  begin
    Ext := ExtractFileExt( FileName );
    Ext[2] := '~';
    Result := ChangeFileExt( FileName, Ext );
    if FileExists( Result ) then
       DeleteFile( PChar(Result) );
    RenameFile( FileName, Result )
  end;
end; //*** end of K_RenameExistingFile

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_FileReplacingDlg
//****************************************************** K_FileReplacingDlg ***
// Show dialogue for confirmation Windows file replacing by another file
//
//     Parameters
// FileName - replacing file name
// Result   - Returns true if file replacing can be done
//
function  K_FileReplacingDlg( const FileName : string ) : Boolean;
begin
  Result := true;
  if FileExists(FileName) then
    if MessageDlg('Ôàéë '+FileName+' óæå ñóùåñòâóåò. Ïåðåçàïèñàòü?',
       mtWarning, mbOKCancel, 0 ) <> mrOk then Result := false;
end; //*** end of K_FileReplacingDlg


//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CalcFileCRC
//*********************************************************** K_CalcFileCRC ***
// Calculate given plain file checksum
//
//     Parameters
// AFName - given plain file name
// Result - Returns file data checksum
//
function K_CalcFileCRC( const AFName : string ): Integer;
var
  FileSize: integer;
  Buf: TN_BArray;
  FStream: TFileStream;
begin
//  FStream := TFileStream.Create( AFName, fmOpenRead + fmShareDenyNone );
  Result := -1;
  FStream := K_TryCreateFileStream( AFName, fmOpenRead + fmShareDenyNone );
  if FStream = nil then Exit;
  Result := 0;
  FileSize := FStream.Size;
  if FileSize = 0 then Exit;
  SetLength( Buf, FileSize );
  FStream.Read( Buf[0], FileSize );
  FStream.Free;
  Result := N_AdlerChecksum( @Buf[0], FileSize );
end; // function K_CalcFileCRC


//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_FindFirstFileNameByPattern
//******************************************** K_FindFirstFileNameByPattern ***
// Find folder first existing file name by pattern
//
//     Parameters
// AFNamePat - file name pattern (including path)
// Result    - Returns first existing file name or empty string if not found
//
function K_FindFirstFileNameByPattern( const AFNamePat : string ): string;
var
  F: TSearchRec;
  FilePath  : string;
  FileName : string;
  FilePat  : string;
  SearchPat  : string;
  SelfCheckFlag : Boolean;
begin
  Result := '';
  if AFNamePat = '' then Exit;
    // Search proper lang file
  FileName := K_ExpandFileName( AFNamePat );
  FilePath := ExtractFilePath( FileName );
  FilePat  := ExtractFileName( FileName );

  SearchPat := FileName;
  SelfCheckFlag := Pos( '?', FilePat ) > 0;
  if SelfCheckFlag then
    SearchPat := FilePath + '*.*';

  if FindFirst( SearchPat, faAnyFile, F ) = 0 then
    repeat
      if (F.Name[1] = '.') or
         ((F.Attr and faDirectory) <> 0) then continue;

      if SelfCheckFlag and not K_CheckTextPattern( F.Name, FilePat ) then continue;

      Result := FilePath + F.Name;
      break;
    until FindNext( F ) <> 0;
  SysUtils.FindClose( F );
end; //*** end of K_FindFirstFileNameByPattern

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ReplaceListNamedValue
//************************************************* K_ReplaceListNamedValue ***
// Replace named element value in strings list
//
//     Parameters
// SList  - strings list
// Name   - element name
// Value  - element value
// Result - Returns index of named value in strings list
//
// If Named value is absent then add new element to strings list, else replace 
// existing element value
//
function K_ReplaceListNamedValue( SList : TStrings;
            const Name : string; const Value : string = '' ) : Integer;
var
  ListVal : string;
begin
  ListVal := Name+'='+Value;
  Result := SList.IndexOfName( Name );
  if Result = -1 then
    Result := SList.Add( ListVal )
  else
    SList.Strings[Result] := ListVal;
end; //*** end of K_ReplaceListNamedValue

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ReplaceListValue
//****************************************************** K_ReplaceListValue ***
// Replace element value in named strings list
//
//     Parameters
// ASList - strings list
// AInd   - element index
// AValue - element value
//
// Should be used instead of Delphi ValueFromIndex because 
// Strings.ValueFromIndex[Ind] := '' leads to deleting Strings element with 
// index Ind
//
procedure K_ReplaceListValue( ASList : TStrings; AInd : Integer;
                              const AValue : string = '' );
begin
  ASList[AInd] := ASList.Names[AInd] + '=' + AValue;
end; //*** end of K_ReplaceListValue

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DeleteListNamedValueAndObject
//***************************************** K_DeleteListNamedValueAndObject ***
// Delete strings list named element
//
//     Parameters
// SList  - Strings list
// Name   - element name
// Result - Returns object linked to deleted list element
//
// If named element is absent, returns nil
//
function K_DeleteListNamedValueAndObject( SList : TStrings; const Name : string ) : TObject;
var
  Ind : Integer;
begin
  Ind := SList.IndexOf( Name );
  if Ind <> -1 then begin
    Result := SList.Objects[Ind];
    SList.Delete(Ind);
  end else
    Result := nil;
end; //*** end of K_DeleteListNamedValueAndObject

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_RegListObject
//********************************************************* K_RegListObject ***
// Register Object in given strings list
//
//     Parameters
// SList  - strings list
// Name   - element name
// Obj    - registered Object
// Result - Returns index of Object in strings list
//
function K_RegListObject( var SList : TStrings;
                          const Name : string; Obj : TObject ) : Integer;
begin
  if SList = nil then begin
    SList := THashedStringList.Create;
    THashedStringList(SList).CaseSensitive := false;
  end;
  Result := K_ReplaceListNamedValue( SList, Name );
  SList.Objects[Result] := Obj;
end; //*** end of K_RegListObject

//******************************************************** K_BuildResultStr ***
//  Build result string  for string macro replace routines
//
//      Parameters
// Buf  - result string buffer
// Leng - used result string buffer legth
// Src - source string
// Result - Returns needed result string
//
function  K_BuildResultStr( const Buf: string; Leng : Integer; const Src : string  ) : string;
begin

  if Leng > 0 then
    Result := Copy( Buf, 1, Leng ) // Copy Start Bytes to Result
  else if Leng = 0 then
    Result := Src                  // Result must be the same as Src
  else
    Result := '';                  // Result must be empty

end; //*** end of K_BuildResultStr

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SwitchMacroBuffers
//**************************************************** K_SwitchMacroBuffers ***
// Switch Source and Resulting Buffers after Macro Replace
//
//     Parameters
// ASrcBuf   - on input current source string buffer, on output new string 
//             buffer with data for next MacroReplace
// ASrcULeng - current source string buffer used length
// ADstBuf   - on input current destination string buffer, on output new string 
//             buffer, which can be used as resulting for next MacroReplace
// ADstULeng - current destination string buffer used length
// Result    - Returns new String Buffer with data for next MacroReplace used 
//             length
//
function K_SwitchMacroBuffers( var ASrcBuf: string; ASrcULeng : Integer;
                               var ADstBuf: string; ADstULeng : Integer ) : Integer;
var
  WBuf : string;

label Switch;

begin
  Result := ASrcULeng;
  if ADstULeng > 0 then begin
Switch:
    WBuf := ASrcBuf;
    ASrcBuf := ADstBuf;
    ADstBuf := WBuf;
    Result := ADstULeng;
  end else if ADstULeng < 0 then begin
    ADstULeng := 0;
    goto Switch;
  end;

end; //*** end of K_SwitchMacroBuffers

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StrMacroReplaceBuf
//**************************************************** K_StrMacroReplaceBuf ***
// Remove all comments from given string
//
//     Parameters
// ASrcBuf   - source string buffer
// ASrcULeng - source string buffer used length
// AComStart - macro start lexem
// AComFin   - macro final lexem
// ANewVal   - new value
// ADstBuf   - destination string buffer
// Result    - Returns destination string buffer used length
//
function  K_StrMacroReplaceBuf( const ASrcBuf : string; ASrcULeng : Integer;
                                const AComStart, AComFin, ANewVal : string;
                                var ADstBuf : string  ) : Integer;
var
  SavedFMRFunc : TK_MRFunc;
  SavedMStart, SavedMFin : string;
  SavedMacroFlags : TK_MRFlags;
begin
//*** Save K_MRProcess Parsing Context
  SavedMStart     := K_MRProcess.MacroStart;
  SavedMFin       := K_MRProcess.MacroFin;
  SavedFMRFunc    := K_MRProcess.FMRFunc;
  SavedMacroFlags := K_MRProcess.MacroFlags;

//*** Set K_MRProcess Parsing Context
  K_MRProcess.CRValue    := ANewVal;
  K_MRProcess.MacroStart := AComStart;
  K_MRProcess.MacroFin   := AComFin;
  K_MRProcess.MacroFlags := [];
  K_MRProcess.FMRFunc    := K_MRProcess.ConstValueMRFunc;

  Result := K_MRProcess.StringMacroReplace( ADstBuf, ASrcBuf, ASrcULeng );

//*** Restore K_MRProcess Parsing Context
  K_MRProcess.MacroStart := SavedMStart;
  K_MRProcess.MacroFin   := SavedMFin;
  K_MRProcess.FMRFunc    := SavedFMRFunc;
  K_MRProcess.MacroFlags := SavedMacroFlags;
end; //***end of function  K_StrMacroReplaceBuf

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StringMacroReplace
//**************************************************** K_StringMacroReplace ***
// Remove all comments from given string
//
//     Parameters
// ASrc      - source string
// AComStart - macro start lexem
// AComFin   - macro final lexem
// ANewVal   - new value
// Result    - Returns source string with replaced substrings
//
function  K_StringMacroReplace( const ASrc, AComStart, AComFin, ANewVal : string ) : string;
begin
  Result := ASrc;
  Result := K_BuildResultStr( Result,
                K_StrMacroReplaceBuf( ASrc, 0, AComStart, AComFin, ANewVal, Result ), ASrc );
end; //***end of function  K_StringMacroReplace

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StrSSReplaceBuf
//******************************************************* K_StrSSReplaceBuf ***
// Replace all occurrences of substring to given value
//
//     Parameters
// ASrcBuf   - source string
// ASrcULeng - source string buffer used length
// ARValue   - replacing substring
// ANValue   - new value
// ADstBuf   - destination string buffer
// Result    - Returns destination string buffer used length
//
function  K_StrSSReplaceBuf( const ASrcBuf : string; ASrcULeng : Integer;
                             const ARValue, ANValue : string;
                             var ADstBuf : string  ) : Integer;
var
  SavedFMRFunc : TK_MRFunc;
  SavedMStart, SavedMFin : string;
  SavedMacroFlags : TK_MRFlags;
begin
//*** Save K_MRProcess Parsing Context
  SavedMStart := K_MRProcess.MacroStart;
  SavedMFin   := K_MRProcess.MacroFin;
  SavedFMRFunc:= K_MRProcess.FMRFunc;
  SavedMacroFlags := K_MRProcess.MacroFlags;
//*** Set K_MRProcess Parsing Context
  K_MRProcess.CRValue := ANValue;
  K_MRProcess.MacroStart := ARValue;
  K_MRProcess.MacroFin := '';
  K_MRProcess.MacroFlags := [];
  K_MRProcess.FMRFunc := K_MRProcess.ConstValueMRFunc;

  Result := K_MRProcess.StringMacroReplace( ADstBuf, ASrcBuf, ASrcULeng );

//*** Restore K_MRProcess Parsing Context
  K_MRProcess.MacroStart := SavedMStart;
  K_MRProcess.MacroFin := SavedMFin;
  K_MRProcess.FMRFunc := SavedFMRFunc;
  K_MRProcess.MacroFlags := SavedMacroFlags;
end; //***end of function  K_StrSSReplaceBuf

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StringSSReplace
//******************************************************* K_StringSSReplace ***
// Replace all occurrences of substring to given value
//
//     Parameters
// ASrc    - source string
// ARValue - replacing substring
// ANValue - new value
// Result  - Returns source string with replaced substrings
//
function  K_StringSSReplace( const ASrc, ARValue, ANValue : string ) : string;
begin
  Result := ASrc;
  Result := K_BuildResultStr( Result,
                K_StrSSReplaceBuf( ASrc, 0, ARValue, ANValue, Result ), ASrc );
end; //***end of function  K_StringSSReplace

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StrMListReplaceBuf
//**************************************************** K_StrMListReplaceBuf ***
// String macro replace using strings list with replacing context
//
//     Parameters
// ASrcBuf         - source string
// ASrcULeng       - source string buffer used length
// ADstBuf         - string buffer with result string
// AMList          - strings list with replacing context
// AUndefMacroMode - undefined macro calls replacing mode (K_ummPutErrText, 
//                   K_ummRemoveMacro, K_ummSaveMacro, K_ummSaveMacroName, 
//                   K_ummRemoveResult)
// APErrNum        - pointer to variable with macro errors counter (undefined 
//                   macro calls) if =nil then macro errors is not used
// AMStart         - start macro expression substring
// AMFin           - fin macro expression substring
// Result          - Returns resulting string buffer used length
//
function  K_StrMListReplaceBuf( const ASrcBuf : string; ASrcULeng : Integer;
                                var ADstBuf : string; AMList : TStrings;
                                AUndefMacroMode : TK_UndefMacroMode = K_ummPutErrText;
                                APErrNum : PInteger = nil; const AMStart : string = '';
                                const AMFin : string = '' ) : Integer;
var
  SavedFMRFunc : TK_MRFunc;
  SavedMStart, SavedMFin : string;
  SavedMacroFlags : TK_MRFlags;
  SavedUndefMacroMode : TK_UndefMacroMode;
begin
//*** Save K_MRProcess Parsing Context
  SavedMStart := K_MRProcess.MacroStart;
  SavedMFin   := K_MRProcess.MacroFin;
  SavedFMRFunc:= K_MRProcess.FMRFunc;
  SavedMacroFlags := K_MRProcess.MacroFlags;
  SavedUndefMacroMode := K_MRProcess.UndefMacroMode;

  if AMStart <> '' then
    K_MRProcess.MacroStart := AMStart;
  if AMFin <> '' then
    K_MRProcess.MacroFin := AMFin;
  K_MRProcess.MList := AMList;
  K_MRProcess.FMRFunc := K_MRProcess.ValueFromStringsMRFunc;
  K_MRProcess.UndefMacroMode := AUndefMacroMode;
  Result := K_MRProcess.StringMacroReplace( ADstBuf, ASrcBuf, ASrcULeng, APErrNum );

//*** Restore K_MRProcess Parsing Context
  K_MRProcess.MacroStart := SavedMStart;
  K_MRProcess.MacroFin := SavedMFin;
  K_MRProcess.FMRFunc := SavedFMRFunc;
  K_MRProcess.MacroFlags := SavedMacroFlags;
  K_MRProcess.UndefMacroMode := SavedUndefMacroMode;
end; //***end of function  K_StrMListReplaceBuf

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StringMListReplace
//**************************************************** K_StringMListReplace ***
// String macro replace using strings list with replacing context
//
//     Parameters
// ASrc            - source string
// AMList          - strings list with replacing context
// AUndefMacroMode - undefined macro calls replacing mode (K_ummPutErrText, 
//                   K_ummRemoveMacro, K_ummSaveMacro, K_ummSaveMacroName, 
//                   K_ummRemoveResult)
// APErrNum        - pointer to variable with macro errors counter (undefined 
//                   macro calls) if =nil then macro errors is not used
// AMStart         - start macro expression substring
// AMFin           - fin macro expression substring
// Result          - Returns result string (after macroexpansion)
//
function  K_StringMListReplace( const ASrc : string; AMList : TStrings;
                        AUndefMacroMode : TK_UndefMacroMode = K_ummPutErrText;
                        APErrNum : PInteger = nil; const AMStart : string = '';
                        const AMFin : string = '' ) : string;
begin
  Result := K_BuildResultStr( Result,
               K_StrMListReplaceBuf( ASrc, 0, Result, AMList, AUndefMacroMode,
                                     APErrNum, AMStart, AMFin ), ASrc );
end; //***end of function  K_StringMListReplace

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SListMListReplace
//***************************************************** K_SListMListReplace ***
// Strings list elements macro replace using strings list with replacing context
//
//     Parameters
// ASList          - strings list with replacing strings
// AMList          - strings list with replacing context
// AUndefMacroMode - undefined macro calls replacing mode (K_ummPutErrText,
// AMStart         - start macro expression substring
// AMFin           - fin macro expression substring K_ummRemoveMacro, 
//                   K_ummSaveMacro, K_ummSaveMacroName, K_ummRemoveResult)
//
procedure K_SListMListReplace( ASList, AMList : TStrings;
                               AUndefMacroMode : TK_UndefMacroMode = K_ummPutErrText;
                               const AMStart : string = ''; const AMFin : string = '' );
var
  i, MLeng, ErrNum : Integer;
  SBuf : string;
  SavedMStart, SavedMFin : string;

begin
//*** string list processing loop
  SavedMStart := K_MRProcess.MacroStart;
  SavedMFin   := K_MRProcess.MacroFin;
  if AMStart <> '' then
    K_MRProcess.MacroStart := AMStart;
  if AMFin <> '' then
    K_MRProcess.MacroFin := AMFin;

  SBuf := '';
  ASList.BeginUpdate;
  i := 0;
  while i < ASList.Count do
  begin
    MLeng := K_StrMListReplaceBuf( ASList.Strings[i], 0, SBuf, AMList, AUndefMacroMode, @ErrNum );
    if (AUndefMacroMode = K_ummRemoveResult) and (ErrNum > 0) then
    begin
//*** remove Error strings
      ASList.Delete(i);
      Continue;
    end;
    if MLeng > 0 then
      ASList.Strings[i] := copy( SBuf, 1, Mleng );
    Inc(i);
  end; //*** end of string list processing loop
  ASList.EndUpdate;

  K_MRProcess.MacroStart := SavedMStart;
  K_MRProcess.MacroFin := SavedMFin;

end; //***end of procedure K_SListMListReplace

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_MacroListClearItems
//*************************************************** K_MacroListClearItems ***
// Clear macro strings list from nested macro strings lists
//
//     Parameters
// AMList      - strings list with replacing context
// ADeleteFlag - if true all strings list elements and nested strings lists will
//               be deleted
// ASInd       - start macro strings list element to clear
// AEInd       - fin macro strings list element to clear
//
procedure K_MacroListClearItems( AMList : TStrings; ADeleteFlag : Boolean = false;
                                 ASInd : Integer = 0; AEInd : Integer = -1 );
var i : Integer;
begin
  if AMList = nil then Exit;
  if AEInd < 0 then AEInd := AMList.Count + AEInd;
  if ASInd < 0 then ASInd := AMList.Count + ASInd;
  for i := AEInd downto ASInd do begin
    if (AMList.ValueFromIndex[i] = K_mtMacroNameSep) and
       (AMList.Objects[i] <> nil)                    and
       (AMList.Objects[i] is TStrings) then begin
      K_MacroListClearItems( TStrings(AMList.Objects[i]), ADeleteFlag );
      AMList.Objects[i].Free;
      AMList.Objects[i] := nil;
    end;
    if ADeleteFlag then AMList.Delete(i);
  end;
end; //***end of K_MacroListClearItems

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StringMacroAssemblingBuf
//********************************************** K_StringMacroAssemblingBuf ***
// Remove all comments from given string
//
//     Parameters
// ASrcBuf   - source string buffer
// ASrcULeng - source string buffer used length
// AComStart - macro start lexem
// AComFin   - macro final lexem
// AVList    - strings list with macro assembling context
// ADstBuf   - destination string buffer
// Result    - Returns destination string buffer used length
//
function  K_StringMacroAssemblingBuf( const ASrcBuf : string; ASrcULeng : Integer;
                                const AComStart, AComFin : string;
                                AVList : TStrings; var ADstBuf : string ) : Integer;
var
  SavedFMRFunc : TK_MRFunc;
  SavedUndefMacroMode : TK_UndefMacroMode;
  SavedMStart, SavedMFin : string;
begin
//*** Save K_MRProcess Parsing Context
  SavedMStart     := K_MRProcess.MacroStart;
  SavedMFin       := K_MRProcess.MacroFin;
  SavedFMRFunc    := K_MRProcess.FMRFunc;
  SavedUndefMacroMode := K_MRProcess.UndefMacroMode;

//*** Set K_MRProcess Parsing Context
  if AComStart <> '' then
    K_MRProcess.MacroStart := AComStart;
  if AComFin <> '' then
    K_MRProcess.MacroFin := AComFin;
  K_MRProcess.UndefMacroMode := K_ummSaveMacro;
  K_MRProcess.FMRFunc := K_MRProcess.TextAssemblingMRFunc;

  K_MRProcess.InitTextAssemblingContext( AVList );

  Result := K_MRProcess.StringMacroReplace( ADstBuf, ASrcBuf, ASrcULeng );

//*** Restore K_MRProcess Parsing Context
  K_MRProcess.MacroStart := SavedMStart;
  K_MRProcess.MacroFin   := SavedMFin;
  K_MRProcess.FMRFunc    := SavedFMRFunc;
  K_MRProcess.UndefMacroMode := SavedUndefMacroMode;
end; //***end of function  K_StringMacroAssemblingBuf

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StringMacroAssembling
//************************************************* K_StringMacroAssembling ***
// String macro assembling using strings list of assembling variables 
// (name=value)
//
//     Parameters
// ASrc    - source string
// AMStart - start macro expression substring
// AMFin   - fin macro expression substring
// AVList  - strings list with macro assembling context
// Result  - Returns result string (after text macro assembling)
//
function  K_StringMacroAssembling( const ASrc : string; const AMStart : string = '';
                                   const AMFin : string = ''; AVList : TStrings = nil ) : string;
begin
  Result := ASrc;
  Result := K_BuildResultStr( Result,
                K_StringMacroAssemblingBuf( ASrc, 0, AMStart, AMFin, AVList, Result ), ASrc );
end; //***end of function  K_StringMacroAssembling
{
function  K_StringMacroAssembling( const ASrc : string; AMStart : string = '';
                                   AMFin : string = ''; AVList : TStrings = nil ) : string;
var
  UndefMacroMode : TK_UndefMacroMode;
  SavedMStart, SavedMFin : string;
begin

  SavedMStart := K_MRProcess.MacroStart;
  SavedMFin   := K_MRProcess.MacroFin;
  if AMStart <> '' then
    K_MRProcess.MacroStart := AMStart;
  if AMFin <> '' then
    K_MRProcess.MacroFin := AMFin;

  K_MRProcess.FMRFunc := K_MRProcess.TextAssemblingMRFunc;
  K_MRProcess.InitTextAssemblingContext( AVList );
  UndefMacroMode := K_MRProcess.UndefMacroMode;
  K_MRProcess.UndefMacroMode := K_ummSaveMacro;

  Result := K_BuildResultStr( Result, K_MRProcess.StringMacroReplace( Result, ASrc ), ASrc );
  K_MRProcess.UndefMacroMode := UndefMacroMode;
  K_MRProcess.MacroStart := SavedMStart;
  K_MRProcess.MacroFin := SavedMFin;
end; //***end of function  K_StringMacroAssembling
}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StringsSaveToFile
//***************************************************** K_StringsSaveToFile ***
// Save strings to file in given coding mode (Windows 1251, UNICODE, UTF8, 
// KOI8R)
//
//     Parameters
// FName    - resulting file name
// SL       - strings list with saved text
// SaveMode - coding mode (K_femW1251, K_femUTF8, K_femUNICODE, K_femKOI8)
// Result   - Returns true if saving is successful
//
function K_StringsSaveToFile( const FName : string; SL : TStrings;
                              SaveMode : TK_FileEncodeMode ) : Boolean;
var
  UF: File;
  CCode : Integer;
  BS : string;
  BAS : AnsiString;
//  PS : string;
  WS : WideString;
  BLength, RLength : Integer;
  PBuf : Pointer;
  i, h : Integer;
const
  W1251ToKoi8 : array [0..127] of Byte = (
    $3F,$3F,$27,$3F,$27,$3A,$8A,$BC,$3F,$25,$3F,$27,$3F,$3F,$3F,$3F,
    $3F,$27,$27,$27,$27,$07,$2D,$2D,$3F,$54,$3F,$27,$3F,$3F,$3F,$3F,
    $9A,$3F,$3F,$3F,$3F,$3F,$81,$15,$B3,$BF,$3F,$27,$83,$2D,$52,$3F,
    $9C,$2B,$3F,$3F,$3F,$DE,$14,$9E,$A3,$3F,$3F,$27,$3F,$3F,$3F,$3F,
    $E1,$E2,$F7,$E7,$E4,$E5,$F6,$FA,$E9,$EA,$EB,$EC,$ED,$EE,$EF,$F0,
    $F2,$F3,$F4,$F5,$E6,$E8,$E3,$FE,$FB,$FD,$FF,$F9,$F8,$FC,$E0,$F1,
    $C1,$C2,$D7,$C7,$C4,$C5,$D6,$DA,$C9,$CA,$CB,$CC,$CD,$CE,$CF,$D0,
    $D2,$D3,$D4,$D5,$C6,$C8,$C3,$DE,$DB,$DD,$DF,$D9,$D8,$DC,$C0,$D1
    );
begin
  AssignFile(UF, FName);
  BS := SL.Text;
  BLength := Length( BS ) - 2;
  Result := false;
  if (SaveMode <> K_femW1251) and (SaveMode <> K_femKOI8) then WS := N_StringToWide( BS );
  try
    Rewrite(UF, 1);

    case SaveMode of
    K_femKOI8    : begin
      RLength := 0;
      h := Length(BS);
      BAS := N_StringToAnsi(BS);
      for i := 1 to h do
        if Byte(BAS[i]) < $80 then
          BAS[i] := BAS[i]
        else
          BAS[i] := AnsiChar(W1251ToKoi8[Byte(BS[i])-$80]);
      PBuf := PAnsiChar(BAS);
    end; // K_femKOI8

    K_femW1251    : begin
      RLength := 0;
//    BAS := AnsiString(BS);
      BAS := N_StringToAnsi(BS);
      PBuf := PAnsiChar(BAS);
    end; // K_femW1251

    K_femUTF8    : begin
      CCode := $BFBBEF;
      RLength := 3;
      BAS := UTF8Encode( WS );
      PBuf := PAnsiChar(BAS);
      BLength := Length( BAS );
    end; // K_femUTF8

    K_femUNICODE : begin
      CCode := $FEFF;
      RLength := 2;
      PBuf := PWideChar(WS);
      BLength := BLength * 2;
    end; // K_femUNICODE
    else
      PBuf := nil;
    end; // case SaveMode of

    if RLength > 0 then
      BlockWrite( UF, CCode, RLength );
    BlockWrite( UF,  PBuf^, BLength, RLength );
    if RLength <> BLength then
      K_ShowMessage( 'File ' + FName + ' write error' )
    else
      Result := true;
  finally
    CloseFile( UF );
  end;
end;

{
//************************************************************* N_KeyIsDown ***
// check asynchroniously if given Virtual VKey is Down now
//
function N_KeyIsDown( VKey: integer ): boolean;
begin
  Result := (GetAsyncKeyState(VKey) and $8000) <> 0;
end; // end of function N_KeyIsDown
}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_HTMGetBodySInds
//******************************************************* K_HTMGetBodySInds ***
// Search strings with HTML body staêt and final tags
//
//     Parameters
// AHTMStrings - Strings with *.HTML or *.MHT content
// ABegSInd    - resulting index of string with body start tag <body ...>
// ABegSInd    - resulting index of string with body final tag </body>
//
procedure K_HTMGetBodySInds( AHTMStrings : TStrings; out ABegSInd, AFinSInd : Integer );
//var
//  i : Integer;
begin
{
  ABegSInd := -1;
  AFinSInd := -1;

  for i := 0 to AHTMStrings.Count - 1 do begin
    if ABegSInd = -1 then begin
      if K_StrStartsWith( '<body', AHTMStrings[i], TRUE ) then
        ABegSInd := i;
    end else if K_StrStartsWith( '</body>', AHTMStrings[i], TRUE ) then begin
      AFinSInd := i;
      break;
    end;
  end;
}
  AFinSInd := -1;
  ABegSInd := K_SearchInStrings( AHTMStrings, '<body' );
  if ABegSInd = -1 then Exit;
  AFinSInd := K_SearchInStrings( AHTMStrings, '</body>' , ABegSInd + 1 );

end; // end of procedure K_HTMGetBodySInds

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_HTMPrepForMacroReplace
//************************************************ K_HTMPrepForMacroReplace ***
// Prepare HTML text for macro replace
//
//     Parameters
// AHTMStrings - Strings with *.HTML or *.MHT content
//
// Replace special hyperlinks by self macro calls
//
procedure K_HTMPrepForMacroReplace( AHTMStrings : TStrings;
                                    const AMStart : string = 'href="#$$';
                                    const AMFin : string = '"' );
var
  MBeg, MEnd, RBeg, REnd, LBeg, LEnd, LL, CPos : Integer;
  SStr : string;
  SSCount : Integer;

label ContMacroSearch;
begin
  SStr := AHTMStrings.Text;
  REnd := 1;
  CPos := 0;
  LBeg := Length(AMStart);
  LEnd := Length(AMFin);
  SSCount := Length(SStr);

 // Parse HTML Loop
  while REnd <= SSCount - LBeg do begin
    // search special Hyperlink HREF start position
    MBeg := N_PosEx( AMStart, SStr, REnd, SSCount ); // Start
    if MBeg = 0 then Break; // end of search loop

    // search Hyperlink open tag position
    RBeg := MBeg - 3;
    if (SStr[RBeg] <> '<') or (SStr[RBeg+1] <> 'a') then begin
    // search back for replace start position
      repeat
        Dec(RBeg);
      until (RBeg = 1) or ((SStr[RBeg] = '<') and (SStr[RBeg+1] = 'a'));

      if (SStr[RBeg] <> '<') or (SStr[RBeg+1] <> 'a') then begin
      // parse error
        assert( false, 'Parse HTML - Hyperlink open tag is not found' );
      end;
    end;

    // Move remaining Chars
    if CPos > 0 then begin
      LL := RBeg - REnd;
      Move( SStr[REnd], SStr[CPos], LL * SizeOf(Char) );
      CPos := CPos + LL;
    end;

   // Parse Macro Name
    MBeg := MBeg + LBeg;
    MEnd := N_PosEx( AMFin, SStr, MBeg, SSCount );
    if MEnd = 0 then begin
    // parse error
      assert( false, 'Parse HTML - Hyperlink HREF final pos is not found' );
    end;

    // search Hyperlink close tag position
    REnd := N_PosEx( '</a>', SStr, MEnd + LEnd, SSCount );
    if REnd = 0 then begin
    // parse error
      assert( false, 'Parse HTML - Hyperlink close tag is not found' );
    end;
    REnd := REnd + 4;

    /////////////////////////
    // Put parsed Macro Call to resulting string
    if CPos = 0 then
      CPos := RBeg;
    LL := Length(K_mtMacroStart0);
    // Put MacroStart
    Move( K_mtMacroStart0[1], SStr[CPos], LL );
    CPos := CPos + LL;

    // Put MacroName
    LL := MEnd - MBeg;
    Move( SStr[MBeg], SStr[CPos], LL * SizeOf(Char) );
    CPos := CPos + LL;

    // Put MacroFin
    LL := Length(K_mtMacroFin0);
    Move( K_mtMacroFin0[1], SStr[CPos], LL * SizeOf(Char) );
    CPos := CPos + LL;
    //
    /////////////////////////

  end;
  if CPos > 0 then begin
    // Move remaining Chars
    LL := SSCount - REnd + 1;
    Move( SStr[REnd], SStr[CPos], LL * SizeOf(Char) );
    CPos := CPos + LL;
    SStr[CPos] := Chr(0);
    AHTMStrings.Text := SStr;
  end;
end; // end of procedure K_HTMPrepForMacroReplace

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ConvStringToMHT
//******************************************************* K_ConvStringToMHT ***
// Convert ANSI string to string in MHT coding
//
//     Parameters
// ASrcStr - source string for covertion
// AResBuf - resulting string buffer
// Result  - Returns resulting string buffer fill length
//
function K_ConvStringToMHT( const ASrcStr : string; var AResBuf : string ) : Integer;
var
  i, RCount, SCount, LL, CCode : Integer;
  WStr : WideString;
  CBuf : string;
begin
  SCount := Length(ASrcStr);
  RCount := SCount * 7 + 1;
  if Length(AResBuf) < RCount then
    SetLength( AResBuf, RCount );
  WStr := ASrcStr;
  Result := 1;
  for i := 1 to SCount do begin
    CCode := Ord(WStr[i]);
    if CCode < 256 then begin
      AResBuf[Result] := Chr( Byte(CCode) );
      Inc(Result);
    end else begin
      CBuf := format( '&#%d;', [CCode] );
      LL := Length(CBuf);
      Move( CBuf[1], AResBuf[Result], LL * SizeOf(Char) );
      Inc( Result, LL );
    end;
  end;
  AResBuf[Result] := Chr(0);
  Dec(Result);
end; // end of procedure K_ConvStringToMHT

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetPackMode
//*********************************************************** K_SetPackMode ***
// Prepare context for future pack JS texts while building data files for 
// Internet client
//
//     Parameters
// PackModeCode - =true  Long  Chars/Numbers Table =false Short Chars/Numbers 
//                Table (for KOI8)
//
procedure K_SetPackMode( PackModeCode : Boolean );
begin
  if PackModeCode then begin
    K_PrepCharNumList( K_NumCharTab0 );
    K_ValidCharTab := K_ValidCharTab0;
  end else begin
    K_PrepCharNumList( K_NumCharTab1 );
    K_ValidCharTab := K_ValidCharTab1;
  end;

end; // end of function K_SetPackMode

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_PackJSText
//************************************************************ K_PackJSText ***
// Pack JS text while building data files for Internet client
//
//     Parameters
// Text     - source text
// InfoText - info text for dump while errors are detected
// Result   - Returns packed text
//
function K_PackJSText( const Text : string; const InfoText : string = '' ) : string;
var
  CLPos : Integer;
  CurVoc  : string;
  RLEng : Integer;
  VocPos, PVocPos, SVocPos : Integer;
  CharInd : Integer;

  procedure PackNumberToText( Num : Integer );
  var D : Integer;
  begin
    repeat
      if Num >= K_CharNumBound then D := K_CharNumBound + 1
      else D := 1;
      Result[RLEng] := K_NumCharTab[Num mod K_CharNumBound + D];
      Inc(RLEng);
      Num := Math.Floor(Num/K_CharNumBound);
    until Num = 0;
  end;

begin
  SetLength(Result, Length(Text) * 2 + 1 );
  RLEng := 1;
  CLPos := 1;
  PackNumberToText( Length(Text) );
  while CLPos <= Length(Text) do begin
    CurVoc := '';
    VocPos := CLPos;
    SVocPos := 1;
    PVocPos := 0;
    while CLPos <= Length(Text) do begin
      CurVoc := CurVoc + Text[CLPos];
      SVocPos := PosEx( CurVoc, Text, SVocPos );
      if SVocPos + Length(CurVoc) >= VocPos then break;
      Inc(CLPos);
      PVocPos := SVocPos;
    end;
    if CurVoc = '' then break;
    // Add New Chain
    PackNumberToText( PVocPos );
    if PVocPos = 0 then begin
      CharInd := Pos( Text[CLPos], K_ValidCharTab );
      if(CharInd = 0) then
        raise TK_PackJSTextError.Create( 'Invalid char in packed text -> "'+Text[CLPos]+
                                         '" code $'+IntToHex(Byte(Text[CLPos]),2)+
                                         ' position '+ IntToStr(CLPos)+ ' '+ InfoText );
      Inc(CLPos);
    end else
      CharInd := Length(CurVoc) - 1;
    PackNumberToText( CharInd );
  end;
  SetLength(Result, RLEng - 1);
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_UnPackJSText
//********************************************************** K_UnPackJSText ***
// Unpack JS text for test pack algorithm
//
//     Parameters
// Text   - packed text
// Result - Returns unpacked text
//
function K_UnPackJSText( const Text : string ) : string;
var
  i,CLPos, VocLeng : Integer;
  RLEng : Integer;
  VocPos : Integer;

  function UnPackNumberFromText : Integer;
  var
    CNum, N, K : Integer;
  begin
    Result := 0;
    K := 1;
    repeat
      K_CharNumList.Find(Text[CLPos],CNum);
      Inc(CLPos);
      CNum := Integer(K_CharNumList.Objects[CNum]);
      N := CNum;
      if N >= K_CharNumBound then N := N - K_CharNumBound;
      Result := Result + N * K;
      K := K * K_CharNumBound;
    until CNum < K_CharNumBound;
  end;

begin
  CLPos := 1;
  SetLength(Result, UnPackNumberFromText);
  RLeng := 1;
  while CLPos <= Length(Text) do begin
    VocPos := UnPackNumberFromText;
    VocLeng := UnPackNumberFromText;
    if VocPos > 0 then
      for i := 1 to VocLeng do begin
        Result[RLeng] := Result[VocPos];
        Inc(RLeng);
        Inc(VocPos);
      end
    else begin
      Result[RLeng] := K_ValidCharTab[VocLeng];
      Inc(RLeng);
    end;
  end;
  SetLength(Result, RLeng - 1);
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetJSCharNumString
//**************************************************** K_GetJSCharNumString ***
// Get JS Char/Number conversion string for put to sight data archive
//
function  K_GetJSCharNumString( ) : string;
begin
  Result := K_NumCharTab;
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_PrepJSTextPack
//******************************************************** K_PrepJSTextPack ***
// Prepare JS text for packing with K_PackJSText routine
//
//     Parameters
// Text             - source text: string;
// PrepNewLine      - put '\r' instead of $0D$0A
// PrepSingleQuoute - put "\'" instead of "'"
// PrepBackSlash    - put '\\' instead of '\'
// Result           - Returns prepared text
//
// Also replace $09 to ' '
//
function  K_PrepJSTextPack( const Text : string; PrepNewLine : Boolean = true;
                            PrepSingleQuoute : Boolean = false;
                            PrepBackSlash : Boolean = false ) : string;
var
  j,i, L : Integer;
  Buf : string;
begin
  Result := '';
  L := Length(Text);
  if L = 0 then Exit;
  i := 1;
  Buf := '';
  while PrepBackSlash do begin
//    j := PosEx( '\', Text, i );
    j := N_PosEx( '\', Text, i, L );
    if j = 0 then break;
    Buf := Buf + Copy( Text, i, j - i + 1 ) + '\' + Text[j+1];
    i := j + 2;
  end;
  Buf := Buf + Copy( Text, i, L );

  i := 1;
  L := Length(Buf);
  while PrepNewLine do begin
//    i := PosEx( Chr($0D), Buf, i );
    i := N_PosEx( Chr($0D), Buf, i, L );
    if i = 0 then break;
    Buf[i] := '\';
    Buf[i+1] := 'r';
    Inc(i,2);
  end;

  i := 1;
  while true do begin
//    i := PosEx( Chr($09), Buf, i );
    i := N_PosEx( Chr($09), Buf, i, L );
    if i = 0 then break;
    Buf[i] := ' ';
    Inc(i,1);
  end;

  i := 1;
  while PrepSingleQuoute do begin
//    j := PosEx( '''', Buf, i );
    j := N_PosEx( '''', Buf, i, L );
    if j = 0 then break;
    Result := Result + Copy( Buf, i, j - i  ) + '\''';
    i := j + 1;
  end;
  Result := Result + Copy( Buf, i, Length(Buf) );
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetJSValidCharString
//************************************************** K_GetJSValidCharString ***
// Get JS Char/Number conversion valid string for put to site data archive
//
function  K_GetJSValidCharString( ) : string;
begin
  Result := K_PrepJSTextPack( K_ValidCharTab, true, true, true );
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SubString
//************************************************************* K_SubString ***
// Substring from string
//
//     Parameters
// SStr   - source string
// Ind    - substring start char index in source string
// Count  - number of chars in substring
// Result - Returns resulting substring
//
// Works correct while Count <= 0 - resulting substring would be empty
//
function  K_SubString( const SStr : string; Ind, Count : Integer ) : string;
begin
  if Count <= 0 then
    Result := ''
  else
    Result := Copy( sstr, Ind, Count );
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ShellExecute
//********************************************************** K_ShellExecute ***
// Wrapper to ShellExecute
//
//     Parameters
// Operation   - :
//#F
//  "open"	- The function opens the file specified by FileName.
//            The file can be an executable file or a document file.
//            The file can be a folder to open.
//  "print"	- The function prints the file specified by FileName.
//            The file should be a document file. If the file is an
//            executable file, the function opens the file,
//            as if "open" had been specified.
//  "explore" - The function explores the folder specified by FileName.
//  "edit"	  - The function edits the file specified by FileName.
//#/F
// FileName    - name of file to operate
// ShowWinMode - par values:
//#F
// SW_HIDE            = 0  Hides the window and activates another window.
// SW_MINIMIZE	       = 6  Minimizes the specified window and activates the next top-level window in the Z order.
// SW_MAXIMIZE	       = 3  Maximizes the specified window.
// SW_RESTORE         = 9  Activates and displays the window. If the window is minimized or maximized, Windows restores it to its original size and position. An application should specify this flag when restoring a minimized window.
// SW_SHOW	           = 5  Activates the window and displays it in its current size and position.
// SW_SHOWDEFAULT     = 10	Sets the show state based on the SW_ flag specified in the STARTUPINFO structure passed to the CreateProcess function by the program that started the application.
// SW_SHOWMAXIMIZED   = 3	Activates the window and displays it as a maximized window.
// SW_SHOWMINIMIZED   = 2	Activates the window and displays it as a minimized window.
// SW_SHOWMINNOACTIVE = 7	Displays the window as a minimized window. The active window remains active.
// SW_SHOWNA	         = 8  Displays the window in its current state. The active window remains active.
// SW_SHOWNOACTIVATE	 = 4  Displays a window in its most recent size and position. The active window remains active.
// SW_SHOWNORMAL      = 1	Activates and displays a window. If the window is minimized or maximized, Windows restores it to its original size and position. An application should specify this flag when displaying the window for the first time.
// SW_NORMAL          = 1
// SW_MINIMIZE        = 6
// SW_MAX             = 10
//   Old ShowWindow() Commands
// HIDE_WINDOW = 0;
// SHOW_OPENWINDOW = 1;
// SHOW_ICONWINDOW = 2;
// SHOW_FULLSCREEN = 3;
// SHOW_OPENNOACTIVATE = 4;
//#/F
// PErrMes     - pointer to Error Message
// Params      - additional string with parameters (like in command line)
// DefaultDir  - Default File Folder
// Result      - Returns execute code - if error < 32
//
function K_ShellExecute( const Operation, FileName : string; ShowWinMode : Integer = -1;
  PErrMes : PString = nil; const Params : string = ''; const DefaultDir : string = '' ) : LongWord;
var
  PDefaultDir : PChar;
begin
  if ShowWinMode = -1 then ShowWinMode := SW_SHOW;
  if DefaultDir = '' then
    PDefaultDir := nil
  else
    PDefaultDir := PChar(DefaultDir);
  Result := ShellExecute( Application.Handle,
    PChar(Operation),
    PChar(FileName),
    PChar(Params),
    PDefaultDir, ShowWinMode );
  if (Result <= 32) and (PErrMes <> nil) then
    case Result of
      0 : PErrMes^ := 'The operating system is out of memory or resources';
      ERROR_FILE_NOT_FOUND : PErrMes^ := 'The specified file was not found';
      ERROR_PATH_NOT_FOUND : PErrMes^ := 'The specified path was not found';
      ERROR_BAD_FORMAT : PErrMes^ := 'The .EXE file is invalid (non-Win32 .EXE or error in .EXE image)';
      SE_ERR_ACCESSDENIED : PErrMes^ := 'The operating system denied access to the specified file';
      SE_ERR_ASSOCINCOMPLETE : PErrMes^ := 'The filename association is incomplete or invalid';
      SE_ERR_DDEBUSY : PErrMes^ := 'The DDE transaction could not be completed because other DDE transactions were being processed';
      SE_ERR_DDEFAIL : PErrMes^ := 'The DDE transaction failed';
      SE_ERR_DDETIMEOUT : PErrMes^ := 'The DDE transaction could not be completed because the request timed out.';
      SE_ERR_DLLNOTFOUND : PErrMes^ := 'The specified dynamic-link library was not found';
//      SE_ERR_FNF : PErrMes^ := 'The specified file was not found';
      SE_ERR_NOASSOC : PErrMes^ := 'There is no application associated with the given filename extension';
      SE_ERR_OOM : PErrMes^ := 'There was not enough memory to complete the operation';
//      SE_ERR_PNF : PErrMes^ := 'The specified path was not found';
      SE_ERR_SHARE : PErrMes^ := 'A sharing violation occurred';
    else
      Exit;
    end;
end; // function K_ShellExecute

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_RunExeByCmdl
//********************************************************** K_RunExeByCmdl ***
// Run *.exe file by given command line
//
//     Parameters
// CMDLine            - command line string
// CreateProcessFlags - create process flags, =-1 (default value means
//                      NORMAL_PRIORITY_CLASS), also controls the new process's
//                      priority class, which is used in determining the
//                      scheduling priorities of the process's threads. If none
//                      of the following priority class flags is specified, the
//                      priority class defaults to NORMAL_PRIORITY_CLASS unless
//                      the priority class of the creating process is
//                      IDLE_PRIORITY_CLASS. In this case the default priority
//                      class of the child process is IDLE_PRIORITY_CLASS. One
//                      of the following flags can be specified:
//#F
//     CREATE_DEFAULT_ERROR_MODE  = $04000000 The new process does not inherit the error mode of the calling process. Instead, CreateProcess gives the new process the current default error mode. An application sets the current default error mode by calling SetErrorMode.This flag is particularly useful for multi-threaded shell applications that run with hard errors disabled. The default behavior for CreateProcess is for the new process to inherit the error mode of the caller. Setting this flag changes that default behavior.
//     CREATE_NEW_CONSOLE         = $00000010 The new process has a new console, instead of inheriting the parent's console. This flag cannot be used with the DETACHED_PROCESS flag.
//     CREATE_NEW_PROCESS_GROUP   = $00000200 The new process is the root process of a new process group. The process group includes all processes that are descendants of this root process. The process identifier of the new process group is the same as the process identifier, which is returned in the lpProcessInformation parameter. Process groups are used by the GenerateConsoleCtrlEvent function to enable sending a CTRL+C or CTRL+BREAK signal to a group of console processes.
//     CREATE_SEPARATE_WOW_VDM    = $00000800 Windows NT only: This flag is valid only when starting a 16-bit Windows-based application. If set, the new process is run in a private Virtual DOS Machine (VDM). By default, all 16-bit Windows-based applications are run as threads in a single, shared VDM. The advantage of running separately is that a crash only kills the single VDM; any other programs running in distinct VDMs continue to function normally. Also, 16-bit Windows-based applications that are run in separate VDMs have separate input queues. That means that if one application hangs momentarily, applications in separate VDMs continue to receive input.
//     CREATE_SHARED_WOW_VDM      = $00001000 Windows NT only: The flag is valid only when starting a 16-bit Windows-based application. If the DefaultSeparateVDM switch in the Windows section of WIN.INI is TRUE, this flag causes the CreateProcess function to override the switch and run the new process in the shared Virtual DOS Machine.
//     CREATE_SUSPENDED           = $00000004 The primary thread of the new process is created in a suspended state, and does not run until the ResumeThread function is called.
//     CREATE_UNICODE_ENVIRONMENT = $00000400 If set, the environment block pointed to by lpEnvironment uses Unicode characters. If clear, the environment block uses ANSI characters.
//     DEBUG_PROCESS              = $00000001 If this flag is set, the calling process is treated as a debugger, and the new process is a process being debugged. The system notifies the debugger of all debug events that occur in the process being debugged.If you create a process with this flag set, only the calling thread (the thread that called CreateProcess) can call the WaitForDebugEvent function.
//     DEBUG_ONLY_THIS_PROCESS    = $00000002 If not set and the calling process is being debugged, the new process becomes another process being debugged by the calling process's debugger. If the calling process is not a process being debugged, no debugging-related actions occur.
//     DETACHED_PROCESS           = $00000008 For console processes, the new process does not have access to the console of the parent process. The new process can call the AllocConsole function at a later time to create a new console. This flag cannot be used with the CREATE_NEW_CONSOLE flag.
//     HIGH_PRIORITY_CLASS        = $00000080	Indicates a process that performs time-critical tasks that must be executed immediately for it to run correctly. The threads of a high-priority class process preempt the threads of normal-priority or idle-priority class processes. An example is Windows Task List, which must respond quickly when called by the user, regardless of the load on the operating system. Use extreme care when using the high-priority class, because a high-priority class CPU-bound application can use nearly all available cycles.
//     IDLE_PRIORITY_CLASS        = $00000040	Indicates a process whose threads run only when the system is idle and are preempted by the threads of any process running in a higher priority class. An example is a screen saver. The idle priority class is inherited by child processes.
//     NORMAL_PRIORITY_CLASS      = $00000020	Indicates a normal process with no special scheduling needs.
//     REALTIME_PRIORITY_CLASS    = $00000100	Indicates a process that has the highest possible priority. The threads of a real-time priority class process preempt the threads of all other processes, including operating system processes performing important tasks. For example, a real-time process that executes for more than a very brief interval can cause disk caches not to flush or cause the mouse to be unresponsive.
//     CREATE_FORCEDOS            = $00002000;
//     CREATE_NO_WINDOW           = $08000000;
//     PROFILE_USER               = $10000000;
//     PROFILE_KERNEL             = $20000000;
//     PROFILE_SERVER             = $40000000;
//#/F
// PSTInfo            - pointer to process startup info record, that specifies
//                      how the main window for the new process should appear;
//                      if =nil then default value will be used:
//#F
//           StartUpInfo.dwFlags := STARTF_USESHOWWINDOW;
//           StartUpInfo.wShowWindow := SW_SHOWDEFAULT;
//
//           Possible value of StartUpInfo.dwFlags:
//     STARTF_USESHOWWINDOW     = 1    If this value is not specified, the wShowWindow member is ignored.
//     STARTF_USESIZE           = 2    If this value is not specified, the dwXSize and dwYSize members are ignored.
//     STARTF_USEPOSITION       = 4    If this value is not specified, the dwX and dwY members are ignored.
//     STARTF_USECOUNTCHARS     = 8    If this value is not specified, the dwXCountChars and dwYCountChars members are ignored.
//     STARTF_USEFILLATTRIBUTE	= $10  If this value is not specified, the dwFillAttribute member is ignored.
//     STARTF_RUNFULLSCREEN     = $20 { ignored for non-x86 platforms }
//     STARTF_FORCEONFEEDBACK   = $40  If this value is specified, the cursor is in feedback mode for two seconds after CreateProcess is called. If during those two seconds the process makes the first GUI call, the system gives five more seconds to the process. If during those five seconds the process shows a window, the system gives five more seconds to the process to finish drawing the window.
//                                     The system turns the feedback cursor off after the first call to GetMessage, regardless of whether the process is drawing.
//                                     For more information on feedback, see the following Remarks section.
//     STARTF_FORCEOFFFEEDBACK  = $80  If specified, the feedback cursor is forced off while the process is starting. The normal cursor is displayed. For more information on feedback, see the following Remarks section.
//     STARTF_USESTDHANDLES     = $100 If this value is specified, sets the standard input of the process, standard output, and standard error handles to the handles specified in the hStdInput, hStdOutput, and hStdError members of the STARTUPINFO structure. The CreateProcess function's fInheritHandles parameter must be set to TRUE for this to work properly.
//                                   If this value is not specified, the hStdInput, hStdOutput, and hStdError members of the STARTUPINFO structure are ignored.
//     STARTF_USEHOTKEY         = $200
//
//           Possible value of StartUpInfo.wShowWindow:
//     SW_HIDE            = 0  Hides the window and activates another window.
//     SW_MINIMIZE        = 6  Minimizes the specified window and activates the next top-level window in the Z order.
//     SW_MAXIMIZE	      = 3  Maximizes the specified window.
//     SW_RESTORE         = 9  Activates and displays the window. If the window is minimized or maximized, Windows restores it to its original size and position. An application should specify this flag when restoring a minimized window.
//     SW_SHOW	          = 5  Activates the window and displays it in its current size and position.
//     SW_SHOWDEFAULT     = 10 Sets the show state based on the SW_ flag specified in the STARTUPINFO structure passed to the CreateProcess function by the program that started the application.
//     SW_SHOWMAXIMIZED   = 3	Activates the window and displays it as a maximized window.
//     SW_SHOWMINIMIZED   = 2	Activates the window and displays it as a minimized window.
//     SW_SHOWMINNOACTIVE = 7	Displays the window as a minimized window. The active window remains active.
//     SW_SHOWNA	        = 8  Displays the window in its current state. The active window remains active.
//     SW_SHOWNOACTIVATE	= 4  Displays a window in its most recent size and position. The active window remains active.
//     SW_SHOWNORMAL      = 1	Activates and displays a window. If the window is minimized or maximized, Windows restores it to its original size and position. An application should specify this flag when displaying the window for the first time.
//     SW_NORMAL          = 1
//     SW_MINIMIZE        = 6
//     SW_MAX             = 10
//       { Old ShowWindow() Commands }
//     HIDE_WINDOW         = 0;
//     SHOW_OPENWINDOW     = 1;
//     SHOW_ICONWINDOW     = 2;
//     SHOW_FULLSCREEN     = 3;
//     SHOW_OPENNOACTIVATE = 4;
//#/F
// DefaultDir         - string with the current drive and directory for the
//                      child process. The string must be a full path and
//                      filename that includes a drive letter. If this parameter
//                      is '', the new process is created with the same current
//                      drive and directory as the calling process. This option
//                      is provided primarily for shells that need to start an
//                      application and specify its initial drive and working
//                      directory (the default value is '')
// PProcInfo          - pointer to created process information
// Result             - Returns =true if the function succeeds; if the function
//                      fails, get extended error information by GetLastError
//                      call.
//
function K_RunExeByCmdl( const CMDLine : string; CreateProcessFlags : Integer = -1;
                         PSTInfo : PStartupInfo = nil; const DefaultDir : string = '';
                         PProcInfo : PProcessInformation = nil ) : Boolean;
var
  StartUpInfo : TStartUpInfo;
  ProcessInfo : TProcessInformation;
  PDefaultDir : PChar;
begin
  if PSTInfo = nil then
  begin
    FillChar(StartUpInfo, SizeOf(StartUpInfo), 0);
    StartUpInfo.dwFlags := STARTF_USESHOWWINDOW;
    StartUpInfo.wShowWindow := SW_SHOWDEFAULT;
    PSTInfo := @StartUpInfo;
  end;
  PSTInfo.cb := SizeOf(StartUpInfo);
  if CreateProcessFlags = -1 then
    CreateProcessFlags := NORMAL_PRIORITY_CLASS;
//    CreateProcessFlags := CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS;
  if DefaultDir = '' then
    PDefaultDir := nil
  else
    PDefaultDir := PChar(DefaultDir);
  Result := CreateProcess( nil, PChar(CMDLine), nil, nil, false,
                           CreateProcessFlags, nil, PDefaultDir, PSTInfo^,
                           ProcessInfo );
  if PProcInfo <> nil then
    PProcInfo^ := ProcessInfo
  else
    with ProcessInfo do
    begin
      WaitForInputIdle(hProcess, INFINITE); // wait for intialization
      CloseHandle(hThread);
      CloseHandle(hProcess);
    end
end; // function K_RunExeByCmdl

//**************************************************************** K_RunExe ***
// Wrapper to ShellExecute and K_RunExeByCmdl
//
//     Parameters
// AFileName    - name of EXE-file or bat BAT-file to run
// AParams      - additional string with parameters (like in command line)
// ADefaultDir  - Default Current Folder
// AUseCreateProcess - if TRUE then CreateProcess function will be used, ShellExecute will be used else
//
function K_RunExe( const AFileName : string; const AParams : string = ''; const ADefaultDir : string = '';
                   AUseCreateProcess : Boolean = FALSE ) : string;
var
  ErrCode : Integer;
begin
  Result := '';
  if not AUseCreateProcess or
     (UpperCase( ExtractFileExt(AFileName) ) = '.BAT') then
  begin
    K_ShellExecute('Open', AFileName, -1, @Result, AParams );
    if Result <> '' then
      Result := 'ShellExecute: ' + Result;
  end
  else
  begin
    if not K_RunExeByCmdl( '"' + AFileName + '" ' + AParams ) then
    begin
      ErrCode := GetLastError();
      Result := format( 'CreateProcess: ErrCode=%d >> %s', [ErrCode, SysErrorMessage( ErrCode )] );
    end;
  end;
end; // function K_RunExe

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_WaitForExecute
//******************************************************** K_WaitForExecute ***
// Run *.exe file and wait for result
//
//     Parameters
// CMDLine                  - command line string
// CreateProcessFlags       - create process flags, =-1 (default value means
//                            CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS), also
//                            controls the new process's priority class, which
//                            is used in determining the scheduling priorities
//                            of the process's threads. If none of the following
//                            priority class flags is specified, the priority
//                            class defaults to NORMAL_PRIORITY_CLASS unless the
//                            priority class of the creating process is
//                            IDLE_PRIORITY_CLASS. In this case the default
//                            priority class of the child process is 
//                            IDLE_PRIORITY_CLASS. One of the following flags 
//                            can be specified:
//#F
//     CREATE_DEFAULT_ERROR_MODE  = $04000000 The new process does not inherit the error mode of the calling process. Instead, CreateProcess gives the new process the current default error mode. An application sets the current default error mode by calling SetErrorMode.This flag is particularly useful for multi-threaded shell applications that run with hard errors disabled. The default behavior for CreateProcess is for the new process to inherit the error mode of the caller. Setting this flag changes that default behavior.
//     CREATE_NEW_CONSOLE         = $00000010 The new process has a new console, instead of inheriting the parent's console. This flag cannot be used with the DETACHED_PROCESS flag.
//     CREATE_NEW_PROCESS_GROUP   = $00000200 The new process is the root process of a new process group. The process group includes all processes that are descendants of this root process. The process identifier of the new process group is the same as the process identifier, which is returned in the lpProcessInformation parameter. Process groups are used by the GenerateConsoleCtrlEvent function to enable sending a CTRL+C or CTRL+BREAK signal to a group of console processes.
//     CREATE_SEPARATE_WOW_VDM    = $00000800 Windows NT only: This flag is valid only when starting a 16-bit Windows-based application. If set, the new process is run in a private Virtual DOS Machine (VDM). By default, all 16-bit Windows-based applications are run as threads in a single, shared VDM. The advantage of running separately is that a crash only kills the single VDM; any other programs running in distinct VDMs continue to function normally. Also, 16-bit Windows-based applications that are run in separate VDMs have separate input queues. That means that if one application hangs momentarily, applications in separate VDMs continue to receive input.
//     CREATE_SHARED_WOW_VDM      = $00001000 Windows NT only: The flag is valid only when starting a 16-bit Windows-based application. If the DefaultSeparateVDM switch in the Windows section of WIN.INI is TRUE, this flag causes the CreateProcess function to override the switch and run the new process in the shared Virtual DOS Machine.
//     CREATE_SUSPENDED           = $00000004 The primary thread of the new process is created in a suspended state, and does not run until the ResumeThread function is called.
//     CREATE_UNICODE_ENVIRONMENT = $00000400 If set, the environment block pointed to by lpEnvironment uses Unicode characters. If clear, the environment block uses ANSI characters.
//     DEBUG_PROCESS              = $00000001 If this flag is set, the calling process is treated as a debugger, and the new process is a process being debugged. The system notifies the debugger of all debug events that occur in the process being debugged.If you create a process with this flag set, only the calling thread (the thread that called CreateProcess) can call the WaitForDebugEvent function.
//     DEBUG_ONLY_THIS_PROCESS    = $00000002 If not set and the calling process is being debugged, the new process becomes another process being debugged by the calling process's debugger. If the calling process is not a process being debugged, no debugging-related actions occur.
//     DETACHED_PROCESS           = $00000008 For console processes, the new process does not have access to the console of the parent process. The new process can call the AllocConsole function at a later time to create a new console. This flag cannot be used with the CREATE_NEW_CONSOLE flag.
//     HIGH_PRIORITY_CLASS        = $00000080	Indicates a process that performs time-critical tasks that must be executed immediately for it to run correctly. The threads of a high-priority class process preempt the threads of normal-priority or idle-priority class processes. An example is Windows Task List, which must respond quickly when called by the user, regardless of the load on the operating system. Use extreme care when using the high-priority class, because a high-priority class CPU-bound application can use nearly all available cycles.
//     IDLE_PRIORITY_CLASS        = $00000040	Indicates a process whose threads run only when the system is idle and are preempted by the threads of any process running in a higher priority class. An example is a screen saver. The idle priority class is inherited by child processes.
//     NORMAL_PRIORITY_CLASS      = $00000020	Indicates a normal process with no special scheduling needs.
//     REALTIME_PRIORITY_CLASS    = $00000100	Indicates a process that has the highest possible priority. The threads of a real-time priority class process preempt the threads of all other processes, including operating system processes performing important tasks. For example, a real-time process that executes for more than a very brief interval can cause disk caches not to flush or cause the mouse to be unresponsive.
//     CREATE_FORCEDOS            = $00002000;
//     CREATE_NO_WINDOW           = $08000000;
//     PROFILE_USER               = $10000000;
//     PROFILE_KERNEL             = $20000000;
//     PROFILE_SERVER             = $40000000;
//#/F
// PSTInfo                  - pointer to process startup info record, that 
//                            specifies how the main window for the new process 
//                            should appear; if =nil then default value will be 
//                            used:
//#F
//           StartUpInfo.dwFlags := STARTF_USESHOWWINDOW;
//           StartUpInfo.wShowWindow := SW_SHOWDEFAULT;
//
//           Possible value of StartUpInfo.dwFlags:
//     STARTF_USESHOWWINDOW     = 1    If this value is not specified, the wShowWindow member is ignored.
//     STARTF_USESIZE           = 2    If this value is not specified, the dwXSize and dwYSize members are ignored.
//     STARTF_USEPOSITION       = 4    If this value is not specified, the dwX and dwY members are ignored.
//     STARTF_USECOUNTCHARS     = 8    If this value is not specified, the dwXCountChars and dwYCountChars members are ignored.
//     STARTF_USEFILLATTRIBUTE	= $10  If this value is not specified, the dwFillAttribute member is ignored.
//     STARTF_RUNFULLSCREEN     = $20 { ignored for non-x86 platforms }
//     STARTF_FORCEONFEEDBACK   = $40  If this value is specified, the cursor is in feedback mode for two seconds after CreateProcess is called. If during those two seconds the process makes the first GUI call, the system gives five more seconds to the process. If during those five seconds the process shows a window, the system gives five more seconds to the process to finish drawing the window.
//                                     The system turns the feedback cursor off after the first call to GetMessage, regardless of whether the process is drawing.
//                                     For more information on feedback, see the following Remarks section.
//     STARTF_FORCEOFFFEEDBACK  = $80  If specified, the feedback cursor is forced off while the process is starting. The normal cursor is displayed. For more information on feedback, see the following Remarks section.
//     STARTF_USESTDHANDLES     = $100 If this value is specified, sets the standard input of the process, standard output, and standard error handles to the handles specified in the hStdInput, hStdOutput, and hStdError members of the STARTUPINFO structure. The CreateProcess function's fInheritHandles parameter must be set to TRUE for this to work properly.
//                                   If this value is not specified, the hStdInput, hStdOutput, and hStdError members of the STARTUPINFO structure are ignored.
//     STARTF_USEHOTKEY         = $200
//
//           Possible value of StartUpInfo.wShowWindow:
//     SW_HIDE            = 0  Hides the window and activates another window.
//     SW_MINIMIZE        = 6  Minimizes the specified window and activates the next top-level window in the Z order.
//     SW_MAXIMIZE	      = 3  Maximizes the specified window.
//     SW_RESTORE         = 9  Activates and displays the window. If the window is minimized or maximized, Windows restores it to its original size and position. An application should specify this flag when restoring a minimized window.
//     SW_SHOW	          = 5  Activates the window and displays it in its current size and position.
//     SW_SHOWDEFAULT     = 10 Sets the show state based on the SW_ flag specified in the STARTUPINFO structure passed to the CreateProcess function by the program that started the application.
//     SW_SHOWMAXIMIZED   = 3	Activates the window and displays it as a maximized window.
//     SW_SHOWMINIMIZED   = 2	Activates the window and displays it as a minimized window.
//     SW_SHOWMINNOACTIVE = 7	Displays the window as a minimized window. The active window remains active.
//     SW_SHOWNA	        = 8  Displays the window in its current state. The active window remains active.
//     SW_SHOWNOACTIVATE	= 4  Displays a window in its most recent size and position. The active window remains active.
//     SW_SHOWNORMAL      = 1	Activates and displays a window. If the window is minimized or maximized, Windows restores it to its original size and position. An application should specify this flag when displaying the window for the first time.
//     SW_NORMAL          = 1
//     SW_MINIMIZE        = 6
//     SW_MAX             = 10
//       { Old ShowWindow() Commands }
//     HIDE_WINDOW         = 0;
//     SHOW_OPENWINDOW     = 1;
//     SHOW_ICONWINDOW     = 2;
//     SHOW_FULLSCREEN     = 3;
//     SHOW_OPENNOACTIVATE = 4;
//#/F
// PExecResultCode          - pointer to variable for execute result code (the 
//                            default value is nil)
// DefaultDir               - string with the current drive and directory for 
//                            the child process. The string must be a full path 
//                            and filename that includes a drive letter. If this
//                            parameter is '', the new process is created with 
//                            the same current drive and directory as the 
//                            calling process. This option is provided primarily
//                            for shells that need to start an application and 
//                            specify its initial drive and working directory 
//                            (the default value is '')
// ASkipProcessMessagesFlag - if TRUE then Application.ProcessMessages will be 
//                            skiped while waiting
// Result                   - Returns =true if the function succeeds; if the 
//                            function fails, get extended error information by 
//                            GetLastError call.
//
function K_WaitForExecute( const CMDLine : string; CreateProcessFlags : Integer = -1;
  PSTInfo : PStartupInfo = nil; PExecResultCode : PInteger = nil;
  const DefaultDir : string = ''; ASkipProcessMessagesFlag : Boolean = FALSE ) : Boolean;
var
  ProcessInfo : TProcessInformation;
begin
  Result := K_RunExeByCmdl( CMDLine, CreateProcessFlags, PSTInfo, DefaultDir, @ProcessInfo );

  if not Result then Exit;

  // Wait for Process Finish
  with ProcessInfo do
  begin
    while WaitForSingleObject(hProcess, 200 ) = WAIT_TIMEOUT do
      if not ASkipProcessMessagesFlag then
        Application.ProcessMessages;
    if PExecResultCode <> nil then
      GetExitCodeProcess( hProcess, LongWord(PExecResultCode^) );
    CloseHandle(hThread);
    CloseHandle(hProcess);
  end; // with ProcessInfo do

end; // function K_WaitForExecute

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CheckProcess
//********************************************************** K_CheckProcess ***
// Check if given process exists
//
//     Parameters
// AExecName - executed process EXE file name
// Result    - Returns found Process ID, or -1 if Process is not found, or -2 if internal error
//
function K_CheckProcess( const AExecName: string; ASkipProcID : DWORD = 0 ): Integer;
var
  ProcessEntry: TProcessEntry32;
  HSnapshot: THandle;
begin
  Result := -2;
  // Get windows processes list snapshot
  HSnapshot := CreateToolHelp32Snapshot( TH32CS_SNAPPROCESS, 0 );

  if ( -1 = Integer( HSnapshot ) ) then Exit; // if error

  ProcessEntry.dwSize := sizeof( ProcessEntry ); // set ProcessEntry size

  Result := -1;
  if Process32First( HSnapshot, ProcessEntry ) then // first process
  repeat
    if ((ASkipProcID = 0) or
       (ASkipProcID <> ProcessEntry.th32ProcessID)) and
       SameText( AExecName, ProcessEntry.szExeFile ) then
    begin
      Result := Integer(ProcessEntry.th32ProcessID);
      break;
    end;
  until not Process32Next( HSnapshot, ProcessEntry ); // next process

  CloseHandle( HSnapshot );
end; // function K_CheckProcess

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetForegroundWindow
//*************************************************** K_SetForegroundWindow ***
// Set given window to Foreground
//
//     Parameters
// AToForegroudHWND - window needed to set to foreground HWND
//
procedure K_SetForegroundWindow( AToForegroudHWND : HWND );
var
  ActiveThreadID, CurrentThreadID : integer;
  ActiveHWND: HWND;

begin
  ActiveHWND := GetForegroundWindow();
  CurrentThreadID := GetCurrentThreadId();
  ActiveThreadID := GetWindowThreadProcessId( ActiveHWND, nil );

  AttachThreadInput(CurrentThreadID, ActiveThreadID, TRUE);

  SetForegroundWindow( AToForegroudHWND );

  AttachThreadInput( CurrentThreadID, ActiveThreadID, FALSE);

end; //*** end of K_SetForegroundWindow

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetComputerName
//******************************************************* K_GetComputerName ***
// Get Computer Name
//
//     Parameters
// Result - Returns Computer Name
//
function K_GetComputerName( ) : string;
var
  nSize: DWORD;
begin
  nSize := MAX_COMPUTERNAME_LENGTH + 1;
  SetLength( Result, nSize );
  if GetComputerName( PChar(Result), nSize ) then
    Result := Copy( Result, 1, nSize )
  else
    Result := '';
end; //*** end of K_GetComputerName

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_WTSGetSessionInfo
//***************************************************** K_WTSGetSessionInfo ***
// Get WTS Session Info
//
//     Parameters
// APWTSSessionInfo - Pointer to Windows Terminal Service Session Info structure
//
procedure K_WTSGetSessionInfo(  APWTSSessionInfo : TK_PWTSSessionInfo );
{$IF SizeOf(Char) = 1}
const
  SM_REMOTESESSION = 1000;
{$IFEND}
var
  HServer : THandle;
  BRes : BOOL;
  PSessionID : PDWORD;
  PClientProtocolType : PWord;
  PClientName : PChar;
  PUserName : PChar;
  PClientAddress : TK_PWTS_CLIENT_ADDRESS;
  BufDataSize : LongWord;
Label LExit;
begin
  APWTSSessionInfo.WTSFillCode := -1;
  APWTSSessionInfo.WTSServerCompName := K_GetComputerName();
  APWTSSessionInfo.WTSClientProtocolType := WTS_PROTOCOL_TYPE_CONSOLE;
  if Windows.GetSystemMetrics( SM_REMOTESESSION ) <> 0 then
    APWTSSessionInfo.WTSClientProtocolType := WTS_PROTOCOL_TYPE_RDP;
  APWTSSessionInfo.WTSSessionID := 0;

  APWTSSessionInfo.WTSClientName := GetEnvironmentVariable( 'CLIENTNAME' );
  APWTSSessionInfo.WTSUserName   := GetEnvironmentVariable( 'USERNAME' );
  HServer := WTSOpenServer( @APWTSSessionInfo.WTSServerCompName[1] );
  if HServer = 0 then Exit; // WTS API fails

  APWTSSessionInfo.WTSFillCode := 0;
  PSessionID          := nil;
  PClientProtocolType := nil;
  PClientName         := nil;
  PClientAddress      := nil;
  PUserName           := nil;

  BRes := WTSQuerySessionInformation( HServer,
                                      WTS_CURRENT_SESSION,
                                      WTSSessionId,
                                      PChar(PSessionID), BufDataSize );

  if not BRes then goto LExit;
  APWTSSessionInfo.WTSFillCode := 1;
  APWTSSessionInfo.WTSSessionID := PSessionID^;

  BRes := WTSQuerySessionInformation( HServer,
                                      APWTSSessionInfo.WTSSessionID,
                                      WTSClientProtocolType,
                                      PChar(PClientProtocolType), BufDataSize );
  if not BRes then goto LExit;
  APWTSSessionInfo.WTSFillCode := 2;
  APWTSSessionInfo.WTSClientProtocolType := PClientProtocolType^;

  if APWTSSessionInfo.WTSClientProtocolType > WTS_PROTOCOL_TYPE_CONSOLE then
  begin
    BRes := WTSQuerySessionInformation( HServer,
                                        APWTSSessionInfo.WTSSessionID,
                                        WTSClientName,
                                        PChar(PClientName), BufDataSize );
    if BRes then
    begin
      APWTSSessionInfo.WTSFillCode := 3;
      APWTSSessionInfo.WTSClientName := PClientName;
    end;

    BRes := WTSQuerySessionInformation( HServer,
                                        APWTSSessionInfo.WTSSessionID,
                                        WTSClientAddress,
                                        PChar(PClientAddress), BufDataSize );
    if BRes then
    begin
      APWTSSessionInfo.WTSFillCode := 4;
      with PClientAddress^ do
        APWTSSessionInfo.WTSClientIPStr := format( '%d.%d.%d.%d', [Address[2],
                                                                   Address[3],
                                                                   Address[4],
                                                                   Address[5]] );
    end;

    BRes := WTSQuerySessionInformation( HServer,
                                        APWTSSessionInfo.WTSSessionID,
                                        WTSUserName,
                                        PChar(PUserName), BufDataSize );
    if BRes then
    begin
      APWTSSessionInfo.WTSFillCode := 5;
      APWTSSessionInfo.WTSUserName := PUserName;
    end;
  end; // if APWTSSessionInfo.WTSClientProtocolType > WTS_PROTOCOL_TYPE_CONSOLE then

LExit:  //*****
  WTSFreeMemory( PSessionID );
  WTSFreeMemory( PClientProtocolType );
  WTSFreeMemory( PClientName );
  WTSFreeMemory( PClientAddress );
  WTSFreeMemory( PUserName );
  WTSCloseServer( HServer );

end; // procedure K_WTSGetSessionInfo

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_IsWin64Bit
//************************************************************ K_IsWin64Bit ***
// Get Windows 64 bit OS flag
//
//     Parameters
// Result - Returns TRUE if Windows is 64 bit OS
//
function  K_IsWin64Bit() : Boolean;
var
  K_IsWow64Process : function ( HP : THandle; var Is64Bit : BOOL ) : BOOL; stdcall;
  Is64Bit : BOOL;
begin
  Result := FALSE;
  K_IsWow64Process := GetProcAddress( GetModuleHandle( 'kernel32.dll' ), 'IsWow64Process' );
  Is64Bit := FALSE;
  if Assigned( K_IsWow64Process ) and K_IsWow64Process( GetCurrentProcess(), Is64Bit ) then
    Result := Is64Bit;
end; // function  K_IsWin64Bit()

//*********************************************** K_ReplaceGPathListElement ***
// Replace Progammaticaly Created Before Macro Global Path Item
//
//     Parameters
// AGPList  - Global Paths List  to replace
// AGPName  - item Path macro Name
// AGPValue - item Path macro Value
//
procedure K_ReplaceGPathListElement( var AGPList : TStringList; const AGPName, AGPValue : string );
var
  Ind : Integer;
begin
  if AGPList = nil then
    AGPList := TStringList.Create;

  Ind := AGPList.IndexOfName( AGPName );

  if Ind >= 0 then
    AGPList[Ind] := AGPName + '=' + AGPValue
  else
    AGPList.Add( AGPName + '=' + AGPValue );

end; //*** end of K_ReplaceGPathListElement

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ReplaceGPathBeforeElement
//********************************************* K_ReplaceGPathBeforeElement ***
// Replace Progammaticaly Created Before Macro Global Path Item
//
//     Parameters
// AGPName  - item Path macro Name
// AGPValue - item Path macro Value
//
// Replace existing or create new Macro Global Path Item which value can use 
// only #Exe, #Arch or #ArchDFiles Path Macro Names
//
procedure K_ReplaceGPathBeforeElement( const AGPName, AGPValue : string );
begin
  K_ReplaceGPathListElement( K_AppFileGPathsBeforeList, AGPName, AGPValue );
end; //*** end of K_ReplaceGPathBeforeElement

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ReplaceGPathAfterElement
//********************************************** K_ReplaceGPathAfterElement ***
// Replace Progammaticaly Created After Macro Global Path Item
//
//     Parameters
// AGPName  - item Path macro Name
// AGPValue - item Path macro Value
//
// Replace existing or create new Macro Global Path Item which value can use all
// existing Path Macro Names
//
procedure K_ReplaceGPathAfterElement( const AGPName, AGPValue : string );
begin
  K_ReplaceGPathListElement( K_AppFileGPathsAfterList, AGPName, AGPValue );
end; //*** end of K_ReplaceGPathAfterElement


//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ReplaceDirMacro
//******************************************************* K_ReplaceDirMacro ***
// Replace macro calls in file path
//
//     Parameters
// FName   - source file path and name
// PErrNum - pointer to integer varaible with absent macro names counter
// Result  - Returns resulting file path and name
//
// Replace macro calls by values of named paths in Files Global Paths List
//
function K_ReplaceDirMacro( const FName : string; PErrNum : PInteger = nil ) : string;
begin
  Result := K_StringMListReplace( FName, K_AppFileGPathsList, K_ummRemoveMacro,
                                  PErrNum );
end; //*** end of K_ReplaceDirMacro

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetDirPath
//************************************************************ K_GetDirPath ***
// Get path value from Files Global Paths List by Name
//
//     Parameters
// PathName - path name
// Result   - Returns directory path
//
// Resulting path includes terminated backslash
//
function  K_GetDirPath( const PathName : string ): string;
begin
  Result := ExpandFileName( K_AppFileGPathsList.Values[ PathName ] );
end; //*** end of K_GetDirPath

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ExpandFileName
//******************************************************** K_ExpandFileName ***
// Expand file name by replacing path macro calls
//
//     Parameters
// FName  - file path and name
// Result - Returns fully qualified file path
//
// If Path after macro replacing is not fully expanded it is expanded by 
// ExpandFileName. Function does not verify that the resulting fully qualified 
// path name refers to an existing file, or even that the resulting path exists.
//
function K_ExpandFileName( const FName : string ) : string;
var
  ErrCount : Integer;
  ErrMessage : string;
  res : word;
begin
  Result := K_ReplaceDirMacro( FName, @ErrCount );
  if ErrCount > 0 then
  begin
    if K_ExpandFileNameAppTypeStr <> '' then
      ErrMessage := 'File name ' + FName +  ' (in ' + K_ExpandFileNameAppTypeStr + ') could not be expanded'
    else
      ErrMessage := 'File name ' + FName +  ' could not be expanded';


    if Assigned(K_ExpandFileNameDumpProc) then
      K_ExpandFileNameDumpProc( ErrMessage + ' ShowDlg=' + N_B2S(not K_ExpandFileNameErrorIgnore) );

    res := mrYes;
    if not K_ExpandFileNameErrorIgnore then
      res := MessageDlg( ErrMessage + '. Ignore?',
                         mtWarning, [mbYes, mbYesToAll, mbAbort], 0);
    case res of
    Ord(mrYes)      :;
    Ord(mrYesToAll) : K_ExpandFileNameErrorIgnore :=  true;
    Ord(mrAbort)    :
      begin
        N_ApplicationTerminated := True; // is used in some OnFormDestroy handlers
        Application.Terminate; // close Self (Self is in Modal mode)
      end;
    end;
  end;
  if not K_IfExpandedFileName( Result ) then
    Result := ExpandFileName( Result );
end; //*** end of K_ExpandFileName

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ExpandFileNameByDirPath
//*********************************************** K_ExpandFileNameByDirPath ***
// Build fully qualified file name using path value from Files Global Paths List
//
//     Parameters
// PathName - path name in Files Global Paths List
// FileName - file path and name
// Result   - Returns fully qualified file name
//
// Function replace macro calls in FileName and if result FileName is not fully 
// qualified build fully qualified file name as PathValue + FileName
//
function  K_ExpandFileNameByDirPath( const PathName, FileName : string ): string;
begin
  Result := K_ReplaceDirMacro( FileName );
  if not K_IfExpandedFileName( Result ) then
    Result := K_GetDirPath( PathName )+ Result;
end; // end of K_ExpandFileNameByDirPath

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ExpandComboBoxFileNames
//*********************************************** K_ExpandComboBoxFileNames ***
// Expand ComboBox text fields as File Names
//
procedure K_ExpandComboBoxFileNames( AComboBox: TComboBox );
var
  i : Integer;
begin

  for i := 0 to AComboBox.Items.Count - 1 do
    AComboBox.Items[i] := K_ExpandFileName( AComboBox.Items[i] );
  AComboBox.Text := K_ExpandFileName( AComboBox.Text );
end; //***end of K_ExpandComboBoxFileNames

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ReplaceUDPathMacro
//**************************************************** K_ReplaceUDPathMacro ***
// Replace macro calls in IDB Object path
//
//     Parameters
// UDPath - source IDB Object path
// Result - Returns resulting IDB Object path
//
// Replace macro calls by values of named paths in IDB Global Paths List
//
function K_ReplaceUDPathMacro( const UDPath : string ) : string;
begin
  Result := K_StringMListReplace( UDPath, K_AppUDGPathsList, K_ummRemoveMacro );
end; //*** end of K_ReplaceUDPathMacro

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ExtractRelativePath
//*************************************************** K_ExtractRelativePath ***
// Extract relative file path, relative to given base file path
//
//     Parameters
// BasePath - fully qualified base path
// FilePath - fully qualified file path and name
// Result   - Returns path relative to given base file path
//
// Call function to convert a fully qualified path into a relative path. The 
// FilePath parameter specifies file name (including path) to be converted. 
// BasePath is the fully qualified path to which the returned path should be 
// relative. BasePath must include the final path delimiter.
//
function K_ExtractRelativePath( const BasePath, FilePath : string ) : string;
begin
  Result := FilePath;
  if ExcludeTrailingPathDelimiter( BasePath ) = Result then
    Result := ''
  else
    Result := ExtractRelativePath( BasePath, Result );
end; //*** end of K_ExtractRelativePath

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ExtractPathBase
//******************************************************* K_ExtractPathBase ***
// Extract file path base macro call
//
//     Parameters
// FilePath - file path which contains base macro call
// Result   - Returns base macro call
//
function K_ExtractPathBase( const FilePath : string ) : string;
var
  TermChar : Char;
  TermInd : Integer;
begin
  Result := '';
  if FilePath[2] <> '#' then Exit;
  case FilePath[1] of
  '(' : TermChar := ')';
  '}' : TermChar := '}';
  else
    Exit;
  end;
  TermInd := Pos( TermChar, FilePath );
  if TermInd = 0 then Exit;
  Result := Copy( FilePath, 1, TermInd );
end; //*** end of K_ExtractPathBase

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetBasePathMacro
//****************************************************** K_SetBasePathMacro ***
// Set file path base macro call
//
//     Parameters
// BasePath - base path with macro call
// FilePath - fully qualified file path
// Result   - Returns file path with base macro call
//
function K_SetBasePathMacro( const BasePath, FilePath : string ) : string;
var
  IncPD : Boolean;
  BD : string;
begin
  Result := K_ExpandFileName(BasePath);
  IncPD := Result[Length(Result)] <> '\';
  Result := K_ExtractRelativePath( IncludeTrailingPathDelimiter( Result ),
     K_ExpandFileName(FilePath) );
  if not K_IfExpandedFileName( Result ) then begin
    BD := BasePath;
    if IncPD then BD := BasePath + '\';
    Result := BD + Result;
  end else
    Result := FilePath;
end; //*** end of K_SetBasePathMacro

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_OptimizePath
//********************************************************** K_OptimizePath ***
// Optimized path by excluding "step up" segment (\..\)
//
//     Parameters
// Path   - fully qualified path
// Result - Returns optimized path
//
function  K_OptimizePath( const Path : string ) : string;
var
  SL  : TStringList;
  ST  : TK_Tokenizer;
  i, RelPathFlag : Integer;
  PathSegm : string;
begin
  Result := Path;
  if Path = '' then Exit;
  SL  := TStringList.Create;
  SL.Delimiter := '\';

  ST := TK_Tokenizer.Create( Path, '\', '' );

  RelPathFlag := 0;
  if K_IfExpandedFileName( Path ) then
    RelPathFlag := 1;

  while ST.hasMoreTokens do
  begin
    PathSegm := ST.nextToken;
    if (SL.Count <= RelPathFlag) or
       (PathSegm <> '..') then
      SL.Add( PathSegm )
    else
      SL.Delete( SL.Count - 1);
  end; // while ST.hasMoreTokens do

  // Restore Leading Backslashs
  Result := '';
  for i := 1 to 2 do
    if (Path[i] = '\') then
      Result := '\' + Result
    else
      Break;

  // Get Resulting Path
  i := K_GetStringsToBuf( PathSegm, SL, 0, -1, Path[Length(Path)] <> '\', '\' );
  Result := Result + Copy( PathSegm, 1 , i );

  SL.Free;
  ST.Free;
end; //*** end of K_OptimizePath

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_PrepFileName
//********************************************************** K_PrepFileName ***
// Prepare file name by replacing wrong chars by given char
//
//     Parameters
// FName  - file path and name
// ARChar - given char to replace wrong chars
// Result - Returns correct file name
//
function K_PrepFileName( const FName : string; ARChar : Char = '#' ) : string;
const WChars = ':<>/\|"*?';
var
  i : Integer;
begin
  SetLength( Result, Length(FName) );
  for i := 1 to Length(FName) do
  begin
    Result[i] := FName[i];
    if Pos( Result[i], WChars ) > 0 then
      Result[i] := ARChar;
  end;

end; //*** end of K_PrepFileName
{
//*************************************************** K_EncodeStringsToFile ***
//
procedure K_EncodeStringsToFile( SS : TStrings; const AFName : string; PSW : string = '' );
var
  SBuf : string;
  WSL : TStringList;
  FStream: TFileStream;
  FSize : Integer;
begin
  if PSW = '' then  PSW := ExtractFileName(Application.ExeName);
  SBuf := SS.Text;
  WSL := TStringList.Create;
  WSL.Assign( SS );
  WSL.Add( IntToStr( N_AdlerChecksum(PByte(@SBuf[1]), Length(SBuf)) ) );
  SBuf := WSL.Text;
  WSL.Free;

  FSize := Length(SBuf);
  N_EncryptBytes1( PByte(@SBuf[1]), FSize, PSW );

  FStream := TFileStream.Create( AFName, fmCreate );
  FStream.Write( SBuf[1], FSize );
  FStream.Free;
end;

//************************************************* K_DecodeStringsFromFile ***
//
function K_DecodeStringsFromFile( SS : TStrings; const AFName : string; PSW : string = '' ) : Boolean;
var
  SBuf : string;
  WSL : TStringList;
  FStream: TFileStream;
  CHSum, FSize, SLeng : Integer;
begin
  Result := false;
  if PSW = '' then  PSW := ExtractFileName(Application.ExeName);
  if not FileExists( AFName ) then Exit;
  FStream := TFileStream.Create( AFName, fmOpenRead );
  FSize := FStream.Seek( 0, soFromEnd );
  FStream.Seek( 0, soFromBeginning );
  SetLength( SBuf, FSize );
  FStream.Read( SBuf[1], FSize );
  FStream.Free;

  N_DecryptBytes1( PByte(@SBuf[1]), FSize, PSW );

  WSL := TStringList.Create;
  WSL.Text := SBuf;
  SLeng := WSL.Count-1;
  CHSum := StrToInt( WSL[SLeng] );
  WSL.Delete( SLeng );
  SBuf := WSL.Text;
  WSL.Free;

  FSize := Length(SBuf);
  if CHSum <> N_AdlerChecksum( PByte(@SBuf[1]), FSize ) then Exit;
  SS.Text := SBuf;
  Result := true;
end;
}

//**************************************** K_GetLastMask
//  get last set LongWord bitmask
//
//     Parameters
//  Count  - Set elements counter
//  Result - Bit Mask for Last Set LongWord Element
//
function  K_GetLastMask( Count : Integer ) : Integer;
var
  NumBits : Integer;
begin
  Result := 0;
  NumBits := Count and $1F;
  if NumBits = 0 then Exit;
  Result := $FFFFFFFF shr (NumBits xor $1F);
end; // end of K_GetLastMask

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetLWLength
//*********************************************************** K_SetLWLength ***
// Get length of memory occupied by set in LongWords
//
//     Parameters
// Count  - number of Set elements
// Result - Returns length of memory occupied by set in LongWords
//
function  K_SetLWLength( Count : Integer ) : Integer;
begin
  Result := (Count + $1F) shr 5;
end; // end of K_SetLWLength

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetByteLength
//********************************************************* K_SetByteLength ***
// Get length of memory occupied by Set in bytes
//
//     Parameters
// Count  - number of Set elements
// Result - Returns length of memory occupied by Set in bytes
//
function  K_SetByteLength( Count : Integer ) : Integer;
begin
  Result := K_SetLWLength( Count ) shl 2;
end; // end of K_SetByteLength

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetOp2
//**************************************************************** K_SetOp2 ***
// Build new Set result of operation with 2 operands Set1 and Set2
//
//     Parameters
// PRSet  - pointer to resulting Set
// PSet1  - pointer to first operand
// PSet2  - pointer to second operand
// Count  - number of Set elements
// OpType - operation type
// Result - Returns =true if resulting Set contains one or more true elements 
//          (is not empty)
//
function  K_SetOp2( PRSet : Pointer; PSet1 : Pointer; PSet2 : Pointer; Count : Integer; OpType : TK_SetOp ) : Boolean;
var
  i, h, ib : Integer;
  Buf : LongWord;
  DoByteOp : Boolean;
begin
  Result := false;
  ib := (Count + 7) shr 3;
  h := ((ib + 3) shr 2) - 1;
  DoByteOp := (ib and 3) <> 0;
  if DoByteOp then Dec(h);

  for i := 0 to h do begin
    Buf := 0;
    if PSet1 <> nil then begin
      Buf := PLongWord(PSet1)^;
      Inc( TN_BytesPtr(PSet1), SizeOf(Integer) );
    end;
    if PSet2 <> nil then begin
      case OpType of
      K_sotOR    : Buf := Buf or PLongWord(PSet2)^;
      K_sotCLEAR : Buf := Buf and not PLongWord(PSet2)^;
      K_sotAND   : Buf := Buf and PLongWord(PSet2)^;
      end;
      Inc( TN_BytesPtr(PSet2), SizeOf(Integer) );
    end;
    Result := Result or (Buf <> 0);
    if PRSet <> nil then begin
      PLongWord(PRSet)^ := Buf;
      Inc( TN_BytesPtr(PRSet), SizeOf(Integer) );
    end else if Result then Exit;
  end;
  if not DoByteOp then Exit;
  h := (ib  - 1) and 3;
  for i := 0 to h do begin
    Buf := 0;
    if PSet1 <> nil then begin
      Buf := PByte(PSet1)^;
      Inc( TN_BytesPtr(PSet1) );
    end;
    if PSet2 <> nil then begin
      case OpType of
      K_sotOR    : Buf := Buf or PByte(PSet2)^;
      K_sotCLEAR : Buf := Buf and not PByte(PSet2)^;
      K_sotAND   : Buf := Buf and PByte(PSet2)^;
      end;
      Inc( TN_BytesPtr(PSet2) );
    end;
    Result := Result or (Buf <> 0);
    if PRSet <> nil then begin
      PByte(PRSet)^ := Byte(Buf);
      Inc( TN_BytesPtr(PRSet) );
    end else if Result then Exit;
//    if not Result and (Buf <> 0) then Result := true;
  end;
end; // end of K_SetOp2

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetFComplement
//******************************************************** K_SetFComplement ***
// Build resulting Set which complete source Set to full Set
//
//     Parameters
// PRSet  - pointer to resulting Set
// PSet   - pointer source Set
// Count  - number of Set elements
// Result - Returns =true if resulting Set contains one or more true elements
//
function  K_SetFComplement ( PRSet : Pointer; PSet : Pointer; Count : Integer ) : Boolean;
var
 i, h : Integer;
 Buf : LongWord;
 Mask : LongWord;
begin
  Result := false;
  Mask := K_GetLastMask( Count );
  h := K_SetLWLength(Count) - 1;
  for i := 0 to h do begin
    Buf := $FFFFFFFF;
    if i = h then Buf := Buf and Mask;
    if PSet <> nil then begin
      Buf := not PLongWord(PSet)^;
      Inc( TN_BytesPtr(PSet), SizeOf(Integer) );
    end;
    if PRSet <> nil then begin
      PLongWord(PRSet)^ := Buf;
      Inc( TN_BytesPtr(PRSet), SizeOf(Integer) );
    end;
    if not Result and (Buf <> 0) then Result := true;
  end;
end; // end of K_SetFComplement

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetSIsEqual
//*********************************************************** K_SetSIsEqual ***
// Check if two Sets are equal
//
//     Parameters
// PSet1  - pointer to first compared Set
// PSet2  - pointer to second compared Set
// Count  - number of Set elements
// Result - Returns =true if Sets are equal
//
function  K_SetSIsEqual ( PSet1 : Pointer; PSet2 : Pointer; Count : Integer ) : Boolean;
begin
  Result := CompareMem( PSet1, PSet2, (Count + 7) shr 3 );
end; // end of K_SetSIsEqual

{
//**************************************** K_SetSIsSubSet
//  returns true if Set1 <= Set2 -> Set2 Includes Set1 (Set1 is SubSet of Set2)
//
function  K_SetSIsSubSet ( PSet1 : Pointer; PSet2 : Pointer; Count : Integer ) : Boolean;
var
  i, h, ib : Integer;
  Buf : LongWord;
  DoByteOp : Boolean;
begin
  Result := true;
  ib := (Count + 7) shr 3;
  h := ((ib + 3) shr 2) - 1;
  DoByteOp := (ib and 3) <> 0;
  if DoByteOp then Dec(h);
  for i := 0 to h do begin
    Buf := 0;
    if PSet1 <> nil then begin
      Buf := PLongWord(PSet1)^;
      Inc( TN_BytesPtr(PSet1), SizeOf(Integer) );
    end;
    if PSet2 <> nil then begin
      Buf := Buf and not  PLongWord(PSet2)^;
      Inc( TN_BytesPtr(PSet2), SizeOf(Integer) );
    end;
    if Buf <> 0 then Result := false;
    if not Result then Exit;
  end;
  if not DoByteOp then Exit;
  h := (ib  - 1) and 3;
  for i := 0 to h do begin
    Buf := 0;
    if PSet1 <> nil then begin
      Buf := PByte(PSet1)^;
      Inc( TN_BytesPtr(PSet1) );
    end;
    if PSet2 <> nil then begin
      Buf := Buf and not PByte(PSet2)^;
      Inc( TN_BytesPtr(PSet2) );
    end;
    if Buf <> 0 then Result := false;
    if not Result then Exit;
  end;
end; // end of K_SetSIsSubSet
}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetByteMaskAndIndex
//*************************************************** K_SetByteMaskAndIndex ***
// Get byte mask and byte index by for Set element given by Index starting from -1
//
//     Parameters
// Ind    - in/out parameter: in - index of Set element, out - index of Set byte
// Result - Returns byte mask for given element
//
function  K_SetByteMaskAndIndex( var Ind : Integer ) : Byte;
var i : Integer;
begin
//  Inc(Ind);
  i := Ind and 7;
  Ind := Ind shr 3;
  Result := 1 shl i;
end; // end of K_SetByteMaskAndIndex

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetGetElementState
//**************************************************** K_SetGetElementState ***
// Get Set element state by element number starting from 0
//
//     Parameters
// Ind    - Set member index
// PSet   - Set pointer
// Result - Returns given Set element state
//
function  K_SetGetElementState ( Ind : Integer; PSet : Pointer ) : Boolean;
var Mask : Byte;
begin
  Result := false;
  if (PSet = nil) or (Ind < 0) then Exit;
  Mask := K_SetByteMaskAndIndex( Ind );
  Result := (PByte(TN_BytesPtr(PSet) + Ind)^ and Mask) <> 0;
end; // end of K_SetGetElementState

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetGetElementState0
//*************************************************** K_SetGetElementState0 ***
// Get Set element state by element number starting from 1
//
//     Parameters
// Ind    - Set member index
// PSet   - Set pointer
// Result - Returns given Set element state
//
function  K_SetGetElementState0 ( Ind : Integer; PSet : Pointer ) : Boolean;
var Mask : Byte;
begin
  Result := false;
  if (PSet = nil) or (Ind < 0) then Exit;
  Dec(Ind);
  Mask := K_SetByteMaskAndIndex( Ind );
  Result := (PByte(TN_BytesPtr(PSet) + Ind)^ and Mask) <> 0;
end; // end of K_SetGetElementState0

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetInclude
//************************************************************ K_SetInclude ***
// Set true value to given Set element by element number starting from 0
//
//     Parameters
// Ind  - Set member index
// PSet - Set pointer
//
procedure K_SetInclude ( Ind : Integer; PSet : Pointer );
var Mask : Byte;
begin
  if (PSet = nil) or (Ind < -1) then Exit;
  Mask := K_SetByteMaskAndIndex( Ind );
  PSet := TN_BytesPtr(PSet) + Ind;
  PByte(PSet)^ := PByte(PSet)^ or Mask;
end; // end of K_SetInclude

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetInclude0
//*********************************************************** K_SetInclude0 ***
// Set true value to given Set element by element number starting from 1
//
//     Parameters
// Ind  - Set member index
// PSet - Set pointer
//
procedure K_SetInclude0( Ind : Integer; PSet : Pointer );
var Mask : Byte;
begin
  if (PSet = nil) or (Ind < 0) then Exit;
  Dec(Ind);
  Mask := K_SetByteMaskAndIndex( Ind );
  PSet := TN_BytesPtr(PSet) + Ind;
  PByte(PSet)^ := PByte(PSet)^ or Mask;
end; // end of K_SetInclude0

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetExclude
//************************************************************ K_SetExclude ***
// Set false value to given Set element by element number starting from 0
//
//     Parameters
// Ind  - Set member index
// PSet - Set pointer
//
procedure K_SetExclude ( Ind : Integer; PSet : Pointer );
var Mask : Byte;
begin
  if (PSet = nil) or (Ind < -1) then Exit;
  Mask := K_SetByteMaskAndIndex( Ind );
  PSet := TN_BytesPtr(PSet) + Ind;
  PByte(PSet)^ := PByte(PSet)^ and not Mask;
end; // end of K_SetExclude

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetExclude0
//*********************************************************** K_SetExclude0 ***
// Set false value to given Set element by element number starting from 1
//
//     Parameters
// Ind  - Set member index
// PSet - Set pointer
//
procedure K_SetExclude0( Ind : Integer; PSet : Pointer );
var Mask : Byte;
begin
  if (PSet = nil) or (Ind < 0) then Exit;
  Dec(Ind);
  Mask := K_SetByteMaskAndIndex( Ind );
  PSet := TN_BytesPtr(PSet) + Ind;
  PByte(PSet)^ := PByte(PSet)^ and not Mask;
end; // end of K_SetExclude0

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetFromInds
//*********************************************************** K_SetFromInds ***
// Build Set from Set elements indexes starting from 0
//
//     Parameters
// PRSet    - pointer to resulting Set
// PIndexes - pointer to 0-element of Set elements indexes array
// Count    - number of indexes
// IndsStep - step in indexes array (default value is SizeOf(Integer))
//
procedure K_SetFromInds ( PRSet : Pointer; PIndexes : PInteger; Count : Integer; IndsStep : Integer = SizeOf(Integer) );
var i : Integer;
begin
  for i := 0 to Count - 1 do begin
    K_SetInclude( PIndexes^, PRSet );
    Inc(TN_BytesPtr(PIndexes), IndsStep );
  end;
end; // end of K_SetFromInds

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetFromInds0
//********************************************************** K_SetFromInds0 ***
// Build Set from Set elements indexes starting from 1
//
//     Parameters
// PRSet    - pointer to resulting Set
// PIndexes - pointer to 0-element of Set elements indexes array
// Count    - number of indexes
// IndsStep - step in indexes array (default value is SizeOf(Integer))
//
procedure K_SetFromInds0( PRSet : Pointer; PIndexes : PInteger; Count : Integer; IndsStep : Integer = SizeOf(Integer) );
var i : Integer;
begin
  for i := 0 to Count - 1 do begin
    K_SetInclude0( PIndexes^, PRSet );
    Inc(TN_BytesPtr(PIndexes), IndsStep );
  end;
end; // end of K_SetFromInds0

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SetToInds
//************************************************************* K_SetToInds ***
// Build indexes of set elements which value is true
//
//     Parameters
// PIndexes  - pointer to 0-element of Set elements indexes array
// PSet      - pointer to Set
// Count     - number of Set elements
// IndsShift - value of shift of index number (default value is -1 - for nonzero
//             based element indexes)
// IndsStep  - step in indexes array (default value is SizeOf(Integer))
// Result    - Returns number of elements in result indexes array
//
function  K_SetToInds ( PIndexes : PInteger; PSet : Pointer; Count : Integer; IndsShift : Integer = -1; IndsStep : Integer = SizeOf(Integer) ) : Integer;
var
  i, h, j, k, n : Integer;
  Buf : LongWord;
begin
  Result := 0;
  if PSet = nil then Exit;
  h := K_SetLWLength(Count) - 1;
  n := 0;
  for i := 0 to h do begin
    Buf := PLongWord(PSet)^;
    Inc( TN_BytesPtr(PSet), SizeOf(LongWord) );
    if Buf = 0 then Continue;
    k := (i shl 5) + IndsShift;
    for j := 0 to 31 do begin
      if (Buf and 1) <> 0 then begin
        if PIndexes <> nil then begin
          PIndexes^ := k + j;
          Inc(TN_BytesPtr(PIndexes), IndsStep );
        end;
        Inc(Result);          
      end;
      Buf := Buf shr 1;
      Inc(n);
      if n = Count then Exit;
    end;
  end;
end; // end of K_SetToInds

//****************************************
//  end of Set Routines
//****************************************

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_InterchangeTActionsFields
//********************************************* K_InterchangeTActionsFields ***
// Interchange fields in two given Pascal TAction objects
//
//     Parameters
// Act1 - 1-st TAction object
// Act2 - 2-nd TAction object
//
// Interchange Caption, Hint and Icon image index TAction fields. Used in 
// TK_RAFrame object while data matrix transpose
//
procedure K_InterchangeTActionsFields( Act1, Act2 : TAction );
var
 i : Integer;
 WStr1, WStr2 : string;
begin
  i := Act1.ImageIndex;
  WStr1 := Act1.Caption;
  WStr2 := Act1.Hint;

  Act1.ImageIndex := Act2.ImageIndex;
  Act1.Caption := Act2.Caption;
  Act1.Hint := Act2.Hint;

  Act2.ImageIndex := i;
  Act2.Caption := WStr1;
  Act2.Hint := WStr2;

end;//*** end of procedure K_InterchangeTActionsFields

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_IntValueBitWidth
//****************************************************** K_IntValueBitWidth ***
// Get field bit width for given integer value
//
//     Parameters
// val    - source integer value
// Result - Returns Field bit width
//
function K_IntValueBitWidth ( val : LongWord ) : Integer;
begin
  if Val = 0 then
    Result := 0
  else begin
    Inc(val);
    Result := Ceil( Log2( val + 1 ) );
  end;
end; //*** end of function K_IntValueBitWidth

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StrStartsWith
//********************************************************* K_StrStartsWith ***
// Test if string starts with given substring
//
//     Parameters
// StartStr   - start substring
// TestStr    - testing string
// IgnoreCase - ignore chars case flag
// CompLength - number of chars in substring
// Result     - Returns =true if TestStr string starts with StartStr
//
function K_StrStartsWith( const StartStr, TestStr  : string;
     IgnoreCase : Boolean = false; CompLength : Integer = 0 ) : Boolean;
var
  TLength : Integer;
  CC : DWord;
begin
  CC := 0;
  if IgnoreCase then CC := NORM_IGNORECASE;
  if CompLength <= 0 then
    CompLength := Length(StartStr)
  else
    CompLength := Min( CompLength, Length(StartStr) );
  TLength := Length(TestStr);
  Result := TLength >= CompLength;
  if not Result then Exit;
  Result := CompareString( LOCALE_USER_DEFAULT, CC, PChar(StartStr), CompLength,
                           PChar(TestStr), CompLength ) = 2;
end; //*** end of function K_StrStartsWith

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StrScan
//*************************************************************** K_StrScan ***
// Search given char position in given string
//
//     Parameters
// SChar    - searching char
// ScanStr  - scanning string
// ScanSInd - scanning start char Index
// Result   - Returns Char position in given string or 0 if char was not found
//
function K_StrScan( SChar : Char; const ScanStr  : string; ScanSInd : Integer = 1 ) : Integer;
var
  PCPos : PChar;
  PSPos : PChar;
begin
  Result := 0;
  PSPos := Pointer(ScanStr);
  if PSPos = nil then Exit;
  PSPos := PSPos + ScanSInd - 1;
  PCPos := StrScan( PSPos, SChar );
  if PCPos <> nil then
    Result := (PCPos - PSPos) + ScanSInd;
end; //*** end of function K_StrScan

//*********************************************** K_StrEncodeToIniFileValue ***
// Encode given string to use as IniFile field value
//
//     Parameters
// AEncodeStr - string for encoding
// Result   - Returns string avalaible to use as IniFile field value
//
function K_StrEncodeToIniFileValue( const AEncodeStr  : string ) : string;
var
  i : Integer;
begin
  SetLength( Result, Length(AEncodeStr) );
  for i := 1 to Length(AEncodeStr) do
    case AEncodeStr[i] of
//    '=': Result[i] := #29;
    #10: Result[i] := #30;
    #13: Result[i] := #31;
    else
    Result[i] := AEncodeStr[i];
    end;
end; //*** end of function K_StrEncodeToIniFileValue

//********************************************* K_StrDecodeFromIniFileValue ***
// Decode given encoded IniFile field value to source string
//
//     Parameters
// ADecodeStr - string for decoding
// Result   - Returns source string
//
function K_StrDecodeFromIniFileValue( const ADecodeStr  : string ) : string;
var
  i : Integer;
begin
  SetLength( Result, Length(ADecodeStr) );
  for i := 1 to Length(ADecodeStr) do
    case ADecodeStr[i] of
//    #29: Result[i] := '=';
    #30: Result[i] := #10;
    #31: Result[i] := #13;
    else
    Result[i] := ADecodeStr[i];
    end;
end; //*** end of function K_StrEncodeToIniFileValue

//***************** DFiles Types and Procedures

const DFPWPrefix  = AnsiString('362_A91F_Wan');
      DFPWPostfix = AnsiString('473_BA21_AW5');
      DFPWDefData = AnsiString('584_CD32_dat');
      DFSignSize  = 22;
      DFSizeAndCRCEncSize = 16; // record size for encrypted two ints (see N_EncryptTwoInts)
      DFMetaInfoSize = DFSignSize + SizeOf(Integer) + DFSizeAndCRCEncSize + 1;
//      DFMetaInfoSize2 = DFSignSize + SizeOf(Integer) + DFSizeAndCRCEncSize + 1;
var
  // DFile System Signature (16+6=22=DFSignSize bytes):
  DFSignature: array [0..DFSignSize-1] of Byte =
    ( $00, $00, $0F, $00,  $FF, $00, $00, $F0,
      $FF, $FF, $FF, $FF,  $FF, $FF, $55, $55,
      Byte('M'), Byte('V'), Byte('F'), Byte('i'), Byte('l'), Byte('e') );

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DFStreamWriteAll
//****************************************************** K_DFStreamWriteAll ***
// Write given Data to given Stream
//
//     Parameters
// AStream       - Stream to write
// AParams       - write parameters (encryption, version and so on)
// APFirstByte   - pointer to first byte of data to write
// ANumBytes     - number of data bytes
// ASegmStartPos - Data segment start position
// AFileDate     - File Date (is used if FormatVersion2)
// Result        - Returns resulting Stream Position
//
function K_DFStreamWriteAll( const AStream : TStream; const AParams: TK_DFCreateParams;
                             APFirstByte: Pointer; ANumBytes: integer;
                             ASegmStartPos: Integer = 0;
                             AFileDate : TDateTime = 0 ): integer;
var
  CRC, VersionNumber: integer;
  EncryptionTypeByte, PWByte: byte;
  PasWord: AnsiString;
  TmpPData: Pointer;
  SizeAndCRC: array [0..DFSizeAndCRCEncSize - 1] of byte; // 16 bytes record
  Buf: TN_BArray;
  FDate : TDateTime;
begin

  AStream.Seek( ASegmStartPos, soBeginning );
  with AParams do
  begin
    if DFEncryptionType = K_dfePlain then // Create Plain Instance without any meta info
      AStream.Write( APFirstByte^, ANumBytes )
    else
    begin // if DFEncryptionType <> K_dfePlain then // Create Instance with meta info
      AStream.Write( DFSignature, DFSignSize ); // DFile Signature (22 bytes)

      VersionNumber := DFFormatVersion;
      if VersionNumber = 0 then VersionNumber := K_DFFormatVersion1;
      AStream.Write( VersionNumber, SizeOf(Integer) ); // DFile Format Version (4 bytes)

      CRC := N_AdlerChecksum( APFirstByte, ANumBytes );
      N_EncryptTwoInts( ANumBytes, CRC, @SizeAndCRC[0], DFPWPrefix ); // encrypt ANumBytes and CRC into SizeAndCRC 16 bytes array
      AStream.Write( SizeAndCRC, DFSizeAndCRCEncSize ); // SizeAndCRC 16 bytes array (mixed and encrypted DataSize and CRC)

      EncryptionTypeByte := Byte(DFEncryptionType);
      // Last meta info byte before Data if K_DFFormatVersion1
      AStream.Write( EncryptionTypeByte, 1 );

      // DFile Date (8 bytes) Last meta info bytes before Data if K_DFFormatVersion2
      if VersionNumber = K_DFFormatVersion2 then
      begin
        FDate := AFileDate;
        if FDate = 0 then FDate := Now();
        AStream.Write( FDate, SizeOf(TDateTime) );
      end;

      if DFEncryptionType = K_dfeProtected then // No Encription
        AStream.Write( APFirstByte^, ANumBytes )  // Plain Data
      else // Encryption is needed
      begin

        if K_dfcEncryptSrc in DFCreateFlags then // Source data could be changed
          TmpPData := APFirstByte
        else // Source data should be preserved, copy them to Buf before Encrypting
        begin
          SetLength( Buf, ANumBytes );
          Move( APFirstByte^, Buf[0], ANumBytes );
          TmpPData := Pointer(Buf);
        end;

        PasWord := DFPassword;
        PWByte  := $FA;

        if PasWord = '' then
          PasWord := DFPWDefData
        else
          PWByte  := Byte(PasWord[1]);

        case DFEncryptionType of
          K_dfeXOR:   N_EncrDecrBytesXOR ( TmpPData, ANumBytes, PWByte );
          K_dfeEncr1: N_EncryptBytes1( TmpPData, ANumBytes, PasWord );
        end; // case DFEncryptionType of

        AStream.Write( TmpPData^, ANumBytes ) // Encrypted Data
      end; // else // Encryption is needed

      N_EncryptTwoInts( ANumBytes, CRC, @SizeAndCRC[0], DFPWPostfix ); // encrypt ANumBytes and CRC into SizeAndCRC 16 bytes array
      AStream.Write( SizeAndCRC, DFSizeAndCRCEncSize ); // SizeAndCRC 16 bytes array (second copy of mixed and encrypted DataSize and CRC)
    end; // // if DFEncryptionType <> K_dfePlain then // Create Instance with meta info
  end; // with AParams do

  Result := AStream.Position;
end; // procedure K_DFStreamWriteAll

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DFWriteAll
//************************************************************ K_DFWriteAll ***
// Write given Data to DFile with given AFileName
//
//     Parameters
// AFileName     - file name to create
// AParams       - create file parameters (encryption, version and so on)
// APFirstByte   - pointer to first byte of data to write to file
// ANumBytes     - number of data bytes
// AFileStartPos - Data segment start position
// AFileDate     - File Date (is used if FormatVersion2)
// Result        - Returns resulting file size including control data
//
// Create new DFile with given AFileName, write given Data to it and close DFile
// stream (free all resources).
//
function K_DFWriteAll( const AFileName: string; const AParams: TK_DFCreateParams;
                       APFirstByte: Pointer; ANumBytes: integer;
                       AFileStartPos: Integer = 0;
                       AFileDate : TDateTime = 0 ) : integer;
var
  FStream: TFileStream;
begin
  if (AFileStartPos = 0) and
     (AParams.DFFormatVersion < K_DFFormatVersion2)  then
    FStream := TFileStream.Create( AFileName, fmCreate )
  else
    FStream := TFileStream.Create( AFileName, fmOpenReadWrite );
  Result := K_DFStreamWriteAll( FStream, AParams, APFirstByte, ANumBytes,
                                AFileStartPos, AFileDate );
  if not FlushFileBuffers(FStream.Handle) then
    N_Dump1Str( format( '!!! File %s >> FlushFileBuffers Error >> %s', [AFileName,SysErrorMessage(GetLastError())] ) );
  FStream.Free;
end; // procedure K_DFWriteAll

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DFStreamOpen
//********************************************************** K_DFStreamOpen ***
// Open DFile with given Stream for Reading
//
//     Parameters
// AStream        - Stream to read
// ADFile         - output parameter with info about opened file (for 
//                  K_DFReadAll)
// AOpenFlags     - DataFiles open flags
// APCreateParams - pointer to CreateParams record (or nil), that can be passed 
//                  to K_DFWriteAll (except DFPassword) to create same DFile 
//                  type
// ASegmStartPos  - Data segment start position
// Result         - Returns =true if the function succeeds, =false if file is 
//                  absent or corrupted
//
function K_DFStreamOpen( const AStream: TStream; var ADFile: TK_DFile;
                   AOpenFlags: TK_DFOpenFlags;
                   APCreateParams: TK_PDFCreateParams = nil;
                   ASegmStartPos: Integer = 0 ): boolean;
var
  DecryptedOK: boolean;
  MetaInfoSize, ReadCount : Integer;
  MetaInfo: array [0..DFMetaInfoSize - 1] of Byte; // 22+4+16+1=43
  Label PlainFile, PlainFile1, FileCorrupted;

  procedure SetCreateParams(); // local
  // set CreateParams to create same DFile type
  begin
    if APCreateParams = nil then Exit;

    if ADFile.DFIsPlain then
      APCreateParams^ := K_DFCreatePlain
//                            else APCreateParams^ := K_DFCreateProtected;
    else
    begin
      APCreateParams^.DFFormatVersion  := ADFile.DFFormatVersion;
      APCreateParams^.DFEncryptionType  := ADFile.DFEncryptionType;
    end;

  end; // procedure SetCreateParams(); // local

begin //***************************************** body of K_DFOpen

  FillChar( ADFile, SizeOf(ADFile), 0 );
  with ADFile do
  begin

    DFErrorCode := K_dfrOK;
    DFPlainDataSize := -1; // "File is Corrupted" flag

    DFStream := AStream;
    DFSize := DFStream.Seek( 0, soEnd );
    DFCurSegmPos := ASegmStartPos;
    DFSize := DFSize - DFStream.Seek( DFCurSegmPos, soBeginning );
    DFNextSegmPos := DFSize;

    if K_dfoPlain in AOpenFlags then // Force Plain File format
    begin
PlainFile: //***********************
      DFIsPlain := True;
      DFPlainDataSize := DFSize;
      SetCreateParams();
      Result := True;
      Exit;
     end;
//      goto PlainFile;

    //***** Read Beg of Plain file or meta info before Data

    FillChar( MetaInfo, DFMetaInfoSize, 0 ); // file may be smaller than MetaInfo
    ReadCount := DFStream.Read( MetaInfo, DFMetaInfoSize ); // Beg of Plain file or meta info before Data
    if ReadCount <> DFMetaInfoSize then
    begin
      if K_dfoProtected in AOpenFlags then // Plain File format is not Alloweded
      begin
        DFErrorCode := K_dfrErrBadDataSize;
        goto FileCorrupted;
      end;

PlainFile1: //***********************
      DFStream.Seek( DFCurSegmPos, soBeginning );
      goto PlainFile; // Assume that file is Plain (without meta info)
    end;

    //***** Check if it is Plain File without meta info
    if not CompareMem( @MetaInfo[0], @DFSignature[0], DFSignSize ) then // not matched
    begin
      if K_dfoProtected in AOpenFlags then // Plain File format is not Alloweded
      begin
        DFErrorCode := K_dfrErrBadSignature;
        goto FileCorrupted;
      end;

      goto PlainFile1; // Assume that file is Plain (without meta info)
    end; // if not CompareMem ...

    //***** Here: File with meta info, Signature is OK,
    //            set needed ADFile fields

    DFIsPlain := False;
    DecryptedOK := N_DecryptTwoInts( DFPlainDataSize, DFPlainDataCRC,
                       @MetaInfo[DFSignSize + SizeOf(Integer)], DFPWPrefix );
    DFFormatVersion := PInteger( @MetaInfo[DFSignSize] )^;
    DFEncryptionType := TK_DFEncryptionType(MetaInfo[DFMetaInfoSize - 1]);
    MetaInfoSize := DFMetaInfoSize;

    // DFile Date (8 bytes) Last meta info bytes before Data if K_DFFormatVersion2
    if DFFormatVersion = K_DFFormatVersion2 then
    begin
      AStream.Read( DFFileDate, SizeOf(TDateTime) );
      Inc( MetaInfoSize, SizeOf(TDateTime) );
    end;

    //***** Check Data consistency
    DFNextSegmPos := DFCurSegmPos + MetaInfoSize + DFPlainDataSize + DFSizeAndCRCEncSize;

//    if DFSize < Sizeof(MetaInfo) then
    if DFSize < MetaInfoSize then
    begin
      DFErrorCode := K_dfrErrTooSmall;
      goto FileCorrupted;
    end; // if FileSize < (Sizeof(MetaInfo) + 16) then

//    if DFSize <> Sizeof(MetaInfo)+DFPlainDataSize+DFSizeAndCRCEncSize then
    if DFSize < DFNextSegmPos - DFCurSegmPos then
    begin
      DFErrorCode := K_dfrErrBadDataSize;
      goto FileCorrupted;
    end; // if DFSize < DFMetaSize then

    if (DFFormatVersion <> K_DFFormatVersion1) and
       (DFFormatVersion <> K_DFFormatVersion2) then
    begin
      DFErrorCode := K_dfrErrBadVersion;
      goto FileCorrupted;
    end; // if DFFormatVersion <> K_DFFormatVersion1 and K_DFFormatVersion2 then

    if MetaInfo[DFSignSize] > Byte(K_dfeEncr1) then
    begin
      DFErrorCode := K_dfrErrBadEncrType;
      goto FileCorrupted;
    end; // if MetaInfo[22] > Ord(mvfEncr1) then

    if not DecryptedOK then
    begin
      DFErrorCode := K_dfrErrBadMetaInfo;
      goto FileCorrupted;
    end; // if DFFormatVersion <> 1 then

    Result := True;
    SetCreateParams();
    Exit; // File Opened OK, K_DFReadAll can be used

FileCorrupted: //*******************
    Result := FALSE;
    SetCreateParams();
    Exit;

  end; // with ADFile do

end; // function K_DFStreamOpen

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DFOpen
//**************************************************************** K_DFOpen ***
// Open DFile with given AFileName for Reading
//
//     Parameters
// AFileName      - file name to open
// ADFile         - output parameter with info about opened file (for 
//                  K_DFReadAll)
// AOpenFlags     - DataFiles open flags
// APCreateParams - pointer to CreateParams record (or nil), that can be passed 
//                  to K_DFWriteAll (except DFPassword) to create same DFile 
//                  type
// ASegmStartPos  - Data segment start position
// Result         - Returns =true if the function succeeds, =false if file is 
//                  absent or corrupted
//
function K_DFOpen( const AFileName: string; out ADFile: TK_DFile;
                   AOpenFlags: TK_DFOpenFlags;
                   APCreateParams: TK_PDFCreateParams = nil;
                   ASegmStartPos: Integer = 0 ): boolean;
var
  FStream : TFileStream;
begin //***************************************** body of K_DFOpen
  ADFile.DFErrorAddInfo := '';
  FillChar( ADFile, SizeOf(ADFile), 0 );

  with ADFile do
  begin

    DFErrorCode := K_dfrOK;
    DFPlainDataSize := -1; // "File is Corrupted" flag
    DFSize := 0;
    Result := FALSE;

    if not FileExists( AFileName ) then
    begin
      DFErrorCode := K_dfrErrFileNotExists;
      Exit;
    end;

    try
      FStream := TFileStream.Create( AFileName,
                                     fmOpenRead or K_DFStreamReadShareFlags );
    except
      On E: Exception do
      begin
        DFErrorCode := K_dfrErrStreamOpen;
        DFErrorAddInfo := E.Message;
        Exit;
      end;
    end;

    Result := K_DFStreamOpen( FStream,
                              ADFile, AOpenFlags, APCreateParams,
                              ASegmStartPos );
    if not Result and not (K_dfoSkipExceptions in AOpenFlags) then
      FreeAndNil( DFStream );
  end;
end; // function K_DFOpen

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DFOpenNextSegm
//******************************************************** K_DFOpenNextSegm ***
// Open DFile next file Segment for already opened DFile
//
//     Parameters
// ADFile         - output parameter with info about opened file (for 
//                  K_DFReadAll)
// AOpenFlags     - DataFiles open flags
// APCreateParams - pointer to CreateParams record (or nil), that can be passed 
//                  to K_DFWriteAll (except DFPassword) to create same DFile 
//                  type
// Result         - Returns =TRUE if next File Segment is opened, =FALSE if next
//                  file Segment is absent
//
// Protected and/or encrypted Data File can occupy not all phisical file. 
// Phisical file can contain number of protected and/or encrypted Segments Last 
// Phisical file Segment can be Plain
//
function K_DFOpenNextSegm( var ADFile: TK_DFile; AOpenFlags: TK_DFOpenFlags;
                           APCreateParams: TK_PDFCreateParams = nil ) : Boolean;
begin
  with ADFile do
  begin
    Result := FALSE;

    if (DFStream = nil)       or
       (DFPlainDataSize <= 0) or
       (DFSize <= DFNextSegmPos) then Exit; // Data File is not opened


    Result := K_DFStreamOpen( DFStream, ADFile, AOpenFlags, APCreateParams,
                              DFNextSegmPos );
  end;
end; // function K_DFOpenNextSegm

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DFStreamOpenLastSegm
//************************************************** K_DFStreamOpenLastSegm ***
// Open DFile Last Segment with given Stream for Reading
//
//     Parameters
// AStream        - Stream to read
// ADFile         - output parameter with info about opened file (for 
//                  K_DFReadAll)
// AOpenFlags     - DataFiles open flags
// APCreateParams - pointer to CreateParams record (or nil), that can be passed 
//                  to K_DFWriteAll (except DFPassword) to create same DFile 
//                  type
// Result         - Returns =true if the function succeeds, =false if file is 
//                  absent or corrupted
//
function K_DFStreamOpenLastSegm( const AStream: TStream; var ADFile: TK_DFile;
                                 AOpenFlags: TK_DFOpenFlags;
                                 APCreateParams: TK_PDFCreateParams = nil ): boolean;
var
  DecryptedOK: boolean;
  AfterCRC, AfterSize, SegmStartPos: integer;
  SizeAndCRC: array [0..DFSizeAndCRCEncSize - 1] of byte;
  OpenFlags: TK_DFOpenFlags;

begin

  AStream.Seek( - SizeOf(SizeAndCRC), soEnd );
  AStream.Read( SizeAndCRC, SizeOf(SizeAndCRC) ); // meta info after Data
  DecryptedOK := N_DecryptTwoInts( AfterSize, AfterCRC, @SizeAndCRC[0],
                                                       DFPWPostfix );
  SegmStartPos := 0;
  OpenFlags := AOpenFlags;
  if DecryptedOK then
  begin
    SegmStartPos := AStream.Position - (DFMetaInfoSize + AfterSize + DFSizeAndCRCEncSize);
    OpenFlags := [K_dfoProtected];
  end;
  Result := K_DFStreamOpen( AStream, ADFile, OpenFlags,
                            APCreateParams, SegmStartPos );

end; // function K_DFStreamOpenLastSegm

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DFReadAll
//************************************************************* K_DFReadAll ***
// Read all Data from already opened DFile
//
//     Parameters
// APBuffer - pointer to first byte of buffer to read data
// ADFile   - info about opened file, created in K_DFOpen
// APasWord - password string for decrypting
// Result   - Returns =true if the function succeeds, =false if file is absent 
//            or corrupted
//
// Read all data from already opened DFile to given buffer (APBuffer^) and close
// DFile stream.
//
function K_DFReadAll( APBuffer: Pointer; var ADFile: TK_DFile;
                                                   APasWord: AnsiString = '' ): boolean;
var
  RealCRC, AfterSize, ReadCount: integer;
  PWByte: byte;
  PasWord: AnsiString;
  DecryptedOK: boolean;
  SizeAndCRC: array [0..DFSizeAndCRCEncSize - 1] of byte;

label Lexit;

begin
  with ADFile do
  begin

  Result := False;
  if DFPlainDataSize = -1 then Exit; // a precaution
  ReadCount := DFStream.Read( APBuffer^, DFPlainDataSize ); // Plain or Encrypted Data
  if ReadCount <> DFPlainDataSize then
  begin
    DFErrorCode := K_dfrErrBadDataSize;
    goto Lexit;
  end;

  if not DFIsPlain then // meta info exists, read and check it
  begin
    DFErrorCode := K_dfrOK;
    ReadCount := DFStream.Read( SizeAndCRC, SizeOf(SizeAndCRC) ); // meta info after Data
    if ReadCount <> SizeOf(SizeAndCRC) then
    begin
      DFErrorCode := K_dfrErrBadDataSize;
      goto Lexit;
    end;

    if DFEncryptionType <> K_dfePlain then // Decryption is needed
    begin
      PasWord := APasWord;
      PWByte  := $FA;

      if PasWord = '' then
        PasWord := DFPWDefData
      else
        PWByte  := Byte(PasWord[1]);

      case DFEncryptionType of
        K_dfeXOR:   N_EncrDecrBytesXOR( APBuffer, DFPlainDataSize, PWByte );
        K_dfeEncr1: N_DecryptBytes1( APBuffer, DFPlainDataSize, PasWord );
      end; // case DFEncryptionType of
    end; // Decryption is needed

    RealCRC := N_AdlerChecksum( APBuffer, DFPlainDataSize ); // Calc Data CRC
    DecryptedOK := N_DecryptTwoInts( AfterSize, DFFileAfterCRC, @SizeAndCRC[0],
                                                           DFPWPostfix );
    //***** Check Data consistency

    if not DecryptedOK or (AfterSize <> DFPlainDataSize) then
      DFErrorCode := K_dfrErrBadMetaInfo;

    if (RealCRC <> DFPlainDataCRC) or (RealCRC <> DFFileAfterCRC) then
      DFErrorCode := K_dfrErrBadCRC;

  end; // if not DFIsPlain then // meta info exists, read and check it
Lexit:

  Result := DFErrorCode = K_dfrOK;
  FreeAndNil( DFStream );
  end; // with ADFile do
end; // function K_DFReadAll

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DFRead
//**************************************************************** K_DFRead ***
// Read data fragment from already opened DFile
//
//     Parameters
// APBuffer         - pointer to first byte of buffer to read data
// ANumBytes        - number of bytes for reading
// ADFile           - info about opened file, created in K_DFOpen
// APasWord         - password string for decrypting
// CloseFStreamFlag - if =true then DFile stream will be closed after start data
//                    reading, else DFile stream is still open for rest data 
//                    reading
// Result           - Returns DFile position to PLainData start
//
function K_DFRead( APBuffer: Pointer; ANumBytes: Integer; var ADFile: TK_DFile;
                   const APasWord: AnsiString = ''; CloseFStreamFlag : Boolean = FALSE ): boolean;
var
  PWByte: byte;
  PasWord: AnsiString;
  FDataPos : Int64;

label CloseFStream;
begin
  with ADFile do
  begin

  Result := False;
  if (DFPlainDataSize = -1) then  Exit; // a precaution
  FDataPos := DFCurSegmPos;
  if (DFPlainDataSize < ANumBytes) then goto CloseFStream;
  FDataPos := DFStream.Position;
  DFStream.Read( APBuffer^, ANumBytes ); // Plain or Encrypted Data

  if not DFIsPlain then // meta info exists, read and check it
  begin
    if DFEncryptionType <> K_dfePlain then // Decryption is needed
    begin
      PasWord := APasWord;
      PWByte  := $FA;

      if PasWord = '' then
        PasWord := DFPWDefData
      else
        PWByte  := Byte(PasWord[1]);

      case DFEncryptionType of
        K_dfeXOR:   N_EncrDecrBytesXOR( APBuffer, ANumBytes, PWByte );
        K_dfeEncr1: N_DecryptBytes1( APBuffer, ANumBytes, PasWord );
      end; // case DFEncryptionType of
    end; // Decryption is needed

  end; // if not DFIsPlain then // meta info exists, read and check it

  Result := true;

CloseFStream:
  if Result and not CloseFStreamFlag then
    DFStream.Seek( FDataPos, soBeginning )
  else
    FreeAndNil(DFStream);
  end; // with ADFile do
end; // function K_DFRead

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DFGetErrorString
//****************************************************** K_DFGetErrorString ***
// Get DFile Read Error string
//
//     Parameters
// ADFErrorCode - Data File Error Code
// Result       - Returns string with error info
//
function K_DFGetErrorString( ADFErrorCode: TK_DFErrorCode ): string;
begin
  Result := '';
  case ADFErrorCode of
  K_dfrErrTooSmall     : Result := 'too small file length';
  K_dfrErrBadSignature : Result := 'bad file signature';
  K_dfrErrBadDataSize  : Result := 'bad file data size';
  K_dfrErrBadCRC       : Result := 'bad file CRC';
  K_dfrErrBadVersion   : Result := 'bad file encryption type';
  K_dfrErrBadEncrType  : Result := 'bad file signature';
  K_dfrErrBadMetaInfo  : Result := 'bad file meta info';
  K_dfrErrFileNotExists: Result := 'file not found';
  K_dfrErrStreamOpen   : Result := 'stream open error';
  end;
end; // function K_DFGetErrorString

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SaveStringsToDFile
//**************************************************** K_SaveStringsToDFile ***
// Save given AStrings to DFile
//
//     Parameters
// AStrings      - TStrings object with strings to save
// AFileName     - DFile file name
// ACreateParams - create file parameters (password, encryption, version and so 
//                 on)
//
procedure K_SaveStringsToDFile( AStrings: TStrings; AFileName: string;
                                         const ACreateParams: TK_DFCreateParams );
var
  BufStr: String;
  TextLength : Integer;
begin
  BufStr := AStrings.Text;
  TextLength := Length( BufStr );
  if SizeOf(Char) = 2 then
    TextLength := TextLength shl 1;
  K_DFWriteAll( AFileName, ACreateParams, Pointer(BufStr), TextLength );
end; // end of K_SaveStringsToDFile

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_LoadStringsFromDFile
//************************************************** K_LoadStringsFromDFile ***
// Load strings from file with given file name by DFile procedures
//
//     Parameters
// AStrings       - TStrings object for loading strings
// AFileName      - DFile file name
// APCreateParams - pointer to CreateParams record (or nil), that can be passed 
//                  to K_DFWriteAll (except DFPassword) to create same DFile 
//                  type
// APasWord       - password for file decryption
// AOpenFlags     - file open flags for control file type (default value is [])
// Result         - Returns =true if the function succeeds, =false if file is 
//                  absent or corrupted
//
function  K_LoadStringsFromDFile( AStrings: TStrings; const AFileName: string;
                                   APCreateParams: TK_PDFCreateParams = nil;
                                   const APasWord: AnsiString = '';
                                   AOpenFlags: TK_DFOpenFlags = [] ): boolean;
var
  BufStr: String;
  DFile: TK_DFile;
  TextLength : Integer;
begin
  Result := K_DFOpen( AFileName, DFile, AOpenFlags, APCreateParams );
  if not Result then Exit; // Error while opening

  TextLength := DFile.DFPlainDataSize;
  if SizeOf(Char) = 2 then
    TextLength := TextLength shr 1;
  SetString( BufStr, nil, TextLength );
  Result := K_DFReadAll( Pointer(BufStr), DFile, APasWord );
  if not Result then Exit; // Error while reading

  if APCreateParams <> nil then
    APCreateParams^.DFPassword := APasWord;

  AStrings.Text := BufStr;
end; // function K_LoadStringsFromDFile

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_EncodeDFile
//*********************************************************** K_EncodeDFile ***
// Encode plain AInpFName to AOutFName
//
//     Parameters
// AInpFName     - Source DFile file name
// AOutFName     - Resulting DFile file name
// ACreateParams - create resulting DFile parameters (password, encryption, 
//                 version and so on)
//
procedure K_EncodeDFile( const AInpFName, AOutFName: string;
                                     const AParams: TK_DFCreateParams );
var
  InpFileSize: integer;
  Buf: TN_BArray;
  FStream: TFileStream;
begin
  FStream := TFileStream.Create( AInpFName, fmOpenRead );
  InpFileSize := FStream.Size;

  SetLength( Buf, InpFileSize );
  FStream.Read( Buf[0], InpFileSize );
  FStream.Free;

  K_DFWriteAll( AOutFName, AParams, @Buf[0], InpFileSize );
end; // procedure K_EncodeDFile

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DecodeDFile
//*********************************************************** K_DecodeDFile ***
// Decode Data in AInpFName file (created by K_DFWriteAll procedure) to plain 
// AOutFName file using K_DFOpen and K_DFReadAll procedures
//
//     Parameters
// AInpFName - Source DFile file name
// AOutFName - Returns resulting DFile file name
// APasWord  - file encryption password
// Result    - Returns =true if the function succeeds, =false if file is absent 
//             or corrupted
//
function K_DecodeDFile( const AInpFName, AOutFName: string; APasWord: AnsiString ): boolean;
var
  Buf: TN_BArray;
  DFile: TK_DFile;
  FStream: TFileStream;
begin
  Result := K_DFOpen( AInpFName, DFile, [] );
  if not Result then Exit;
  SetLength( Buf, DFile.DFPlainDataSize );
  Result := K_DFReadAll( @Buf[0], DFile, APasWord );
  if not Result then Exit;

  FStream := TFileStream.Create( AOutFName, fmCreate );
  FStream.Write( Buf[0], DFile.DFPlainDataSize );
  FStream.Free;
end; // function K_DecodeDFile
//***************** end of DFile Procedures

//***************** Tmp Files Procedures
//******************************************************** K_NewTmpFilesVars ***
//  TMP files names creating parameters
//
//        Elements
//  K_NewTmpFilesCount - temporary file counter
//  K_NewTmpFilePrefix - temporary file names prefix
//  K_NewTmpFilesPath  - temporary file directory path
//##begin K_NewTmpFilesVars
var K_NewTmpFilesCount : Integer = 0;
var K_NewTmpFilePrefix : string = 'T';
var K_NewTmpFilesPath  : string = '(#TmpFiles#)';
//##end K_NewTmpFilesVars

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetNewTmpFileName
//***************************************************** K_GetNewTmpFileName ***
// Get new TMP File Name
//
//     Parameters
// FileExt - new unique TMP file name extension
// Result  - Returns new TMP file name
//
// Returns unique file name in directory specified by K_NewTmpFilesPath extern 
// variable
//
function K_GetNewTmpFileName( const AFileExt : string ) : string;
begin
  if K_NewTmpFilesCount = 0 then
    K_NewTmpFilesPath := K_ExpandFileName( K_NewTmpFilesPath );
  Result := K_BuildUniqFileName(
                  K_NewTmpFilesPath, K_NewTmpFilePrefix, AFileExt,
                                 K_NewTmpFilesCount );

  repeat
    Result := K_NewTmpFilesPath + K_NewTmpFilePrefix +
                                  IntToStr(K_NewTmpFilesCount) + AFileExt;
    Inc( K_NewTmpFilesCount );
  until not FileExists( Result );
end; // end of function K_GetNewTmpFileName

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_BuildUniqFileName
//***************************************************** K_BuildUniqFileName ***
// Build Uniq File Name in given Folder
//
//     Parameters
// AFilesAllocPath - path to folder for files allocation
// AFNamePrefix    - file name preffix
// AFNameSuffix    - file name suffix
// AFilesCount     - files cur counter
// Result          - Returns uniq file name in given folder
//
// Returns unique file name in directory specified by K_NewTmpFilesPath extern 
// variable
//
function K_BuildUniqFileName( const AFilesAllocPath, AFNamePrefix, AFNameSuffix : string;
                               var AFilesCount : Integer ) : string;
begin
  repeat
    Result := AFilesAllocPath + AFNamePrefix +
                      Format( '%.4d ', [ AFilesCount ] ) + AFNameSuffix;
    Inc( AFilesCount );
  until not FileExists( Result );
end; // end of function K_GetNewTmpFileName

//***************** end of Tmp Files Procedures

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_MoveBits24
//************************************************************ K_MoveBits24 ***
// Move field of bits (field width 1..24)
//
//     Parameters
// Src   - source variable
// SBit  - source field start bit (0..7)
// Dest  - destination variable
// Dbit  - destination field start bit (0..7)
// FSize - field size (1..24)
//
procedure K_MoveBits24( const Src; SBit : Integer; var Dest; DBit, FSize : Integer );
var
  Mask : TN_UInt4;
  Buf : TN_UInt4;
begin
 SBit := DBit - SBit;
 Mask := K_Masks32[FSize-1] shl DBit;
 if SBit < 0 then
   Buf := (TN_UInt4(Src) shr -SBit) and Mask
 else
   Buf := (TN_UInt4(Src) shl SBit) and Mask;
 TN_UInt4(Dest) := (($FFFFFFFF xor Mask) and TN_UInt4(Dest)) or Buf;
end; //*** end of procedure K_MoveBits24

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_MoveBits
//************************************************************** K_MoveBits ***
// Move field of bits (any field width)
//
//     Parameters
// Src   - source variable
// SBit  - source field start bit
// Dest  - destination variable
// Dbit  - destination field start bit
// FSize - field size
//
procedure K_MoveBits( const Src; SBit : Integer; var Dest; DBit, FSize : Integer );
var
  i, FS : Integer;
  WS, WD : TN_BytesPtr;
begin
 i := FSize;
 WS := TN_BytesPtr(@Src) + (SBit shr 3);
 WD := TN_BytesPtr(@Dest) + (DBit shr 3);
 SBit := SBit and 7;
 DBit := DBit and 7;
 while i > 0 do begin
   if i > 24 then
     FS := 24
   else
     FS := i;
   K_MoveBits24( WS^, SBit, WD^, DBit, FS );
   Dec( i, FS );
   Inc( WS, 3 );
   Inc( WD, 3 );
 end;
end; //*** end of procedure K_MoveBits

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetIntBitsCount
//******************************************************* K_GetIntBitsCount ***
// Calculate number of Bits in given Integer Bits Set
//
//     Parameters
// AIntBitSet - Integer Bits Set
// Result     - Returns number of bits in given Bits Set
//
function  K_GetIntBitsCount( AIntBitSet : LongWord ) : Integer;
begin
  Result := 0;
  while AIntBitSet <> 0 do
  begin
    case AIntBitSet and 7 of
    1,2,4: Inc(Result, 1);
    3,5,6: Inc(Result, 2);
    7    : Inc(Result, 3);
    end;
    AIntBitSet := AIntBitSet shr 3;
  end;
end; // function  K_GetIntBitsCount

//****************************************************** K_CheckTextPattern ***
// Check if string corresponds to wildcard characters pattern
//
//     Parameters
// APSStr     - pointer to testing string start char
// ANumS      - testing string length
// APPat      - pointer to testing pattern start char
// ANumP      - testing pattern length
// AWChars    - wildcard chars: AWChars[1] - analog '?', AWChars[2] - analog '*'
//              if AWChars = '' then AWChars[1]='?' and AWChars[2]='*'
// APPos      - pointer to resulting testing string next after last scaned char (if nil result is not needed)
// Result     - Returns =true if testing string corresponds to given wildcard
//               characters pattern
//
function K_CheckTextPatternEx( APSStr : PChar; ANumS : Integer;
                               APPat  : PChar; ANumP : Integer;
                               AWChars : string = '';
                               APRECont : TK_PRegExprCont = nil ) : Boolean;
var
  PPos : Integer;  // Current Pattren Pos
  SPPos : Integer; // Pattern Context Substring Start Pos
  SPos : Integer;  // Checking String Current Testing SubString Start Pos
  ResultState : Integer; // Global Result Finish 0 - continue search, 1 - finish TRUE, -1 - Finish FALSE
  PrevPatChar, CurPatChar : Char;
  PrevWildCharAsterix : Boolean;
  PPat : PChar;
  FRESPos, FREFPos : Integer;
  SearchPatFlag : Boolean;
  StartPosShiftFlag : Boolean;
  StartPosShift : Integer;

label RetFalse, RetPos;

  function SearchContext : boolean;
  var
    CPLeng : Integer;
    CSLeng : Integer;
    WPos : Integer;
    WSPos : Integer;
    WPPat : PChar;
    WPPatN : PChar;
    NumPatN : Integer;
  begin
    CPLeng := PPos - SPPos;
    WPPat := APPat + SPPos - 1;
    if PrevWildCharAsterix or StartPosShiftFlag then
      CSLeng := ANumS
    else
      CSLeng := CPLeng;
    WPos := N_PosExPtr( WPPat, APSStr,
                        CPLeng, SPos, SPos + CSLeng - 1 );
    if WPos = 0 then
    // Context is not found
      Result := FALSE
    else
    begin
    // Context is found
      Result := TRUE;
      if not PrevWildCharAsterix then
      begin
      // previouse pattern char is not '*' - Continue String Check
        if StartPosShiftFlag  then
          FRESPos := WPos - StartPosShift;
        StartPosShiftFlag := FALSE;
        SPos := WPos + CPLeng;
        FREFPos := SPos;
        SPPos := 0;
      end
      else
      begin
      // previouse pattern char is '*'

        if PPos = ANumP + 1 then
        begin
        // Context is Last pattern lexem - check last string chars
          if SearchPatFlag then
            FREFPos := WPos + CPLeng
          else
          begin
            FREFPos := ANumS + 1;
            SPos := FREFPos;
            WPos := N_PosExPtr( WPPat, APSStr,
                          CPLeng, ANumS - CPLeng + 1, ANumS );
            if WPos = 0 then
            begin
              Result := FALSE;
              Exit;
            end;

            SPPos := 0; // to prevent next call to SearchContext
          end;
        end  // if PPos = HPPos + 1 then
        else
        if PPos = ANumP then
        begin
        /////////////////////////////////////////////
        //!!! This Code needed only to speed check!!!
        // Context is PreLast pattern lexem - check prelast string chars
          SPos := ANumS + 1;
          FREFPos := SPos;

          if CurPatChar = AWChars[1] then
          begin
            if SearchPatFlag then
              FREFPos := WPos + CPLeng + 1
            else
            begin
            // Last Part Pattern is '?' - Check String Tail
              if 0 = N_PosExPtr( WPPat, APSStr,
                          CPLeng, ANumS - CPLeng, ANumS - 1 ) then
              begin
                Result := FALSE;
                Exit;
              end;
            end;
          end
          else
          begin
            // Last Part Pattern is Asterix or String Tail is OK - TRUE;
            ResultState := 1;
            Exit;
          end;
        //!!! This Code needed only to speed check!!!
        /////////////////////////////////////////////
        end  // if PPos = HPPos then
        else
        begin
        // Context is not Last or PreLast pattern lexem - check string tail with pattern tail
          WPPatN := APPat + SPPos + CPLeng - 1;
          NumPatN := ANumP - SPPos - CPLeng + 1;
          while WPos > 0 do
          begin
          // Try String tail with pattern tail
            SPos := WPos;
            WSPos := WPos + CPLeng - 1;
            Result := K_CheckTextPatternEx( APSStr + WSPos, ANumS - WSPos,
                                            WPPatN, NumPatN, AWChars, APRECont );
            if APRECont <> nil then
              FREFPos := APRECont.REFPos + WSPos;

            if Result then
            begin
              SPos := ANumS + 1;
              ResultState := 1;
              Exit;
            end;
            // it is case like K_CheckTextPatternEx( '123232344', 9, '*23?4', 5 );
            SPos := SPos + 1; // Increment start string position
            if SPos > ANumS then Exit; // End of String
            WPos := N_PosExPtr( WPPat, APSStr, CPLeng, SPos, ANumS );
          end; // while WPos > 0 do
        end; // recursive call to K_CheckTextPatternEx
      end; // previuse pattern char is '*'
    end; // // Context is found
  end;

begin
  Result := TRUE;
  SPos := 1;
  if ANumP <= 0 then
    goto RetFalse;

  if AWChars = '' then AWChars := '?*';

  PrevPatChar := ' ';
  SPPos := 0;
  PrevWildCharAsterix := FALSE;
  ResultState := 0;
  PPat := APPat;
  FRESPos := 1;
  FREFPos := 1;
  SearchPatFlag := (APRECont <> nil) and (K_RESearch in APRECont.REFlags);
  StartPosShiftFlag := SearchPatFlag;
  StartPosShift := 0;
  for PPos := 1 to ANumP do
  begin
    CurPatChar := PPat^;
    Inc(PPat);
    if CurPatChar = AWChars[2] then
    begin
      if (SPPos > 0) and not SearchContext() then
        goto RetFalse; // source is not equal to pattern
      if ResultState <> 0 then
      begin
        Result := ResultState > 0;
        goto RetPos;
      end;
      StartPosShiftFlag := FALSE;
      PrevWildCharAsterix := TRUE;
    end
    else
    if CurPatChar = AWChars[1] then
    begin
      if ((SPPos > 0) and not SearchContext()) or
         (SPos > ANumS + 1) then
        goto RetFalse; // source is not equal to pattern
      Inc(StartPosShift);
      Inc(SPos);
      FREFPos := SPos;
//    PrevWildCharAsterix := FALSE;

      if ResultState <> 0 then
      begin
        Result := ResultState > 0;
        goto RetPos;
      end;
    end
    else
    begin
// *** pattern current char is not '*' or '?'
      if SPos > ANumS then
        goto RetFalse; // source is finished

      if (PPos = 1)                 or
         (PrevPatChar = AWChars[2]) or
         (PrevPatChar = AWChars[1]) then
        SPPos := PPos;
    end;
    PrevPatChar := CurPatChar;
  end; // for PPos := 1 to ANumP do

//  if (PrevPatChar <> AWChars[1]) and (SPPos > 0) then Inc(SPos);

  if ((SPPos > 0) and not SearchContext())   or  // Analize pattern tail
//   ((PrevPatChar <> AWChars[2]) and
     (not PrevWildCharAsterix and
      (SPos <= ANumS) and not SearchPatFlag) or  // pattern finished but analized string is not
     (SPos > ANumS + 1) then // pattern finished but analized string range is over
  begin
RetFalse: //********
    Result := FALSE; // source is not correspond to pattern
  end;

RetPos: //********
  if APRECont <> nil then
    with APRECont^ do
    begin
      RESPos := FRESPos;
      REFPos := FREFPos;
    end;
// add Return results
end; //*** end of K_CheckTextPatternEx

{
//****************************************************** K_CheckTextPattern ***
// Check if string corresponds to wildcard characters pattern
//
//     Parameters
// SStr        - testing string
// Pat         - testing pattern string
// FilePattern - use filename rules (default value =true)
// Result      - Returns =true if testing string corresponds to given wildcard
//               characters pattern
//
function K_CheckTextPattern( const SStr, Pat : string; FilePattern : boolean = true ) : Boolean;
var
  PPos : Integer;  // Current Pattren Pos
  SPPos : Integer; // Pattern Context Substring Start Pos
  HPPos : Integer; // Pattern High Pos
  HPos : Integer;  // Testing String High Pos
  SPos : Integer;  // Checking String Current Testing SubString Start Pos
  PrevPatChar, CurPatChar : Char;
  PrevWildCharAsterix : Boolean;
  WSrc : string;

label RetFalse;

  function SearchContext : boolean;
  var
    WContext : string;
    Cleng : Integer;
    WPos : Integer;
  begin
    Cleng := PPos - SPPos;
    WContext := Copy( Pat, SPPos, Cleng);
//    WPos := PosEx( WContext, WSrc, SPos );
    WPos := N_PosEx( WContext, WSrc, SPos, HPos );
    if (WPos = 0) or
       (not PrevWildCharAsterix and (WPos <> SPos)) then
      Result := false
    else begin
      Result := true;
      SPPos := 0;
      SPos := WPos + Cleng;
      if PrevWildCharAsterix and (PPos = HPPos + 1) then
      // if '*' is Pat last char
      // then search for other WContext occurrences
        while true do begin
//          WPos := PosEx( WContext, WSrc, SPos );
          WPos := N_PosEx( WContext, WSrc, SPos, HPos );
          if SPos <> WPos then break; //??? may be it is wrong
          Inc( SPos, Cleng );
        end;
    end;
  end;

begin
  WSrc := SStr;
  if FilePattern          and
    (Pos('.', WSrc ) = 0) and
    (Pos('.', Pat ) <> 0) then
    WSrc := WSrc + '.'; // add '.' to source for correct analysis
  Result := true;
  HPos := Length(WSrc);
  SPos := 1;
  PrevPatChar := ' ';
  SPPos := 0;
  HPPos := Length(Pat);
  PrevWildCharAsterix := false;
  for PPos := 1 to HPPos do begin
    CurPatChar := Pat[PPos];
    case CurPatChar of
    '*': begin
        if (SPPos > 0) and not SearchContext() then
          goto RetFalse; // source is not equal to pattern
        PrevWildCharAsterix := true;
      end;

    '?': begin
        if ( (SPPos > 0) and not SearchContext() ) or
           ( SPos > HPos ) then
          goto RetFalse; // source is not equal to pattern
        PrevWildCharAsterix := false;
        Inc(SPos);
      end;
    else
// *** pattern current char is not '*' or '?'
      if SPos > HPos then goto RetFalse; // source is finished
      if (PPos = 1)          or
         (PrevPatChar = '*') or
         (PrevPatChar = '?') then
        SPPos := PPos;
    end;
    PrevPatChar := CurPatChar;
  end;

  if ((SPPos > 0) and not SearchContext) or
     ((PrevPatChar <> '*') and (SPos <= HPos)) then
RetFalse:
    Result := false; // source is not equal to pattern
end; //*** end of K_CheckTextPattern
}

{
//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CheckTextPattern
//****************************************************** K_CheckTextPattern ***
// Check if string corresponds to wildcard characters pattern
//
//     Parameters
// SStr        - testing string
// Pat         - testing pattern string
// FilePattern - use filename rules (default value =true)
// SStrSPos    - testing string start position (used in self recursive call)
// Result      - Returns =true if testing string corresponds to given wildcard
//               characters pattern
//
function K_CheckTextPattern( const SStr, Pat : string; FilePattern : boolean = true;
                             SStrSPos : Integer = 0 ) : Boolean;
var
  PPos : Integer;  // Current Pattren Pos
  SPPos : Integer; // Pattern Context Substring Start Pos
  HPPos : Integer; // Pattern High Pos
  HPos : Integer;  // Testing String High Pos
  SPos : Integer;  // Checking String Current Testing SubString Start Pos
  ResultState : Integer; // Global Result Finish 0 - continue search, 1 - finish TRUE, -1 - Finish FALSE
  PrevPatChar, CurPatChar : Char;
  PrevWildCharAsterix : Boolean;
  WSrc : string;

label RetFalse;

  function SearchContext : boolean;
  var
    WContext : string;
    Cleng : Integer;
    WPos : Integer;
    WSPos : Integer;
    Ind : Integer;
    WPat : string;
  begin
    Cleng := PPos - SPPos;
    WContext := Copy( Pat, SPPos, Cleng);
//    WPos := PosEx( WContext, WSrc, SPos );
    WPos := N_PosEx( WContext, WSrc, SPos, HPos );
    if (WPos = 0) or
       (not PrevWildCharAsterix and (WPos <> SPos)) then
    // Context is not found
      Result := FALSE
    else
    begin
    // Context is found
      Result := TRUE;
      if not PrevWildCharAsterix then
      begin
      // previuse pattern char is not '*' - Continue String Check
        SPos := WPos + Cleng;
        SPPos := 0;
      end else
      begin
      // previuse pattern char is '*'
        if PPos = HPPos + 1 then
        begin
        // Context is Last pattern lexem - check last string chars
          SPos := HPos + 1;
          for Ind := 1 to Cleng do
            if WContext[Ind] <> WSrc[HPos - Cleng + Ind] then
            begin
              Result := FALSE;
              Exit;
            end;
          SPPos := 0;
        end
        else if PPos = HPPos then
        begin
        /////////////////////////////////////////////
        //!!! This Code needed only to speed check!!!

        // Context is PreLast pattern lexem - check last string chars
          if CurPatChar = '?' then
          // Last Part Pattern is '?' - Check String Tail
            for Ind := 1 to Cleng do
              if WContext[Ind] <> WSrc[HPos - Cleng + Ind - 1] then
              begin
                Result := FALSE;
                Exit;
              end;
          // Last Part Pattern is Asterix or String Tail is OK - TRUE;
          ResultState := 1;
          Exit;
        //!!! This Code needed only to speed check!!!
        /////////////////////////////////////////////
        end else
        begin
        // Context is not Last or PreLast pattern lexem - check string tail with pattern tail
          WPat := Copy( Pat, SPPos + Cleng, HPPos );
          while WPos > 0 do
          begin
          // Try String tail with pattern tail
            WSPos := WPos + Cleng;
            Result := K_CheckTextPattern( WSrc, WPat, FilePattern, WSPos );
            if Result then
            begin
              SPos := WSPos;
              ResultState := 1;
              Exit;
            end;
            SPos := SPos + 1; // Increment start string position
            if SPos > HPos then Exit; // End of String
            WPos := N_PosEx( WContext, WSrc, SPos, HPos );
          end;
        end;
      end;
    end;
  end;

begin
  WSrc := SStr;
  if FilePattern          and
    (Pos('.', WSrc ) = 0) and
    (Pos('.', Pat ) <> 0) then
    WSrc := WSrc + '.'; // add '.' to source for correct analysis

  Result := TRUE;
  HPos := Length(WSrc);
  SPos := SStrSPos;
  if SPos < 1 then
    SPos := 1;
  if SPos > HPos then goto RetFalse;

  PrevPatChar := ' ';
  SPPos := 0;
  HPPos := Length(Pat);
  PrevWildCharAsterix := false;
  ResultState := 0;
  for PPos := 1 to HPPos do begin
    CurPatChar := Pat[PPos];
    case CurPatChar of
    '*': begin
        if (SPPos > 0) and not SearchContext() then
          goto RetFalse; // source is not equal to pattern
        if ResultState <> 0 then
        begin
          Result := ResultState > 0;
          Exit;
        end;
        PrevWildCharAsterix := true;
      end;

    '?': begin
        if ( (SPPos > 0) and not SearchContext() ) or
           ( SPos > HPos ) then
          goto RetFalse; // source is not equal to pattern
        if ResultState <> 0 then begin
          Result := ResultState > 0;
          Exit;
        end;
        PrevWildCharAsterix := false;
        Inc(SPos);
      end;
    else
// *** pattern current char is not '*' or '?'
      if SPos > HPos then goto RetFalse; // source is finished
      if (PPos = 1)          or
         (PrevPatChar = '*') or
         (PrevPatChar = '?') then
        SPPos := PPos;
    end;
    PrevPatChar := CurPatChar;
  end;

  if ((SPPos > 0) and not SearchContext()) or
     ((PrevPatChar <> '*') and (SPos <= HPos)) then
RetFalse:
    Result := false; // source is not equal to pattern
end; //*** end of K_CheckTextPattern
}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CheckTextPattern
//****************************************************** K_CheckTextPattern ***
// Check if string corresponds to wildcard characters pattern
//
//     Parameters
// SStr        - testing string
// Pat         - testing pattern string
// FilePattern - use filename rules (default value =true)
// Result      - Returns =true if testing string corresponds to given wildcard
//               characters pattern
//
function K_CheckTextPattern( const SStr, Pat : string; FilePattern : boolean = true ) : Boolean;
var
  WSrc : string;

begin
  WSrc := SStr;
  if FilePattern          and
    (Pos('.', WSrc ) = 0) and
    (Pos('.', Pat ) <> 0) then
    WSrc := WSrc + '.'; // add '.' to source for correct analysis
  Result := K_CheckTextPatternEx( @WSrc[1], Length(WSrc), @Pat[1], Length(Pat) );
end; //*** end of K_CheckTextPattern

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CheckPattern
//********************************************************** K_CheckPattern ***
// Check if string corresponds to wildcard characters conditions string
//
//     Parameters
// ASStr  - testing string
// APat   - wildcards conditions string
// Result - Returns =true if testing string corresponds to given wildcard
//          characters pattern
//
// This routine is K_CheckTextPattern wrapper for using in K_SearchInStrings
//
function  K_CheckPattern( const ASStr, APat : string ) : Boolean;
begin
  Result := K_CheckTextPattern( ASStr, APat, FALSE );
end; //*** end of K_CheckPattern

//***************************************************** K_SearchTextPattern ***
// Search wildcard characters pattern in given string
//
//     Parameters
// APSStr     - pointer to given string start char
// ANumS      - given string length
// APPat      - pointer to pattern start char
// ANumP      - pattern length
// ASPos      - resulting pattern start position in given string
// ANPos      - next after resulting pattern last position (next search position)
// AWChars    - wildcard chars: AWChars[1] - analog '?', AWChars[2] - analog '*'
//              if AWChars = '' then AWChars[1]='?' and AWChars[2]='*'
// Result     - Returns =true if given pattern is found in given string
//
function  K_SearchTextPattern( APSStr : PChar; ANumS : Integer;
                               APPat  : PChar; ANumP : Integer;
                               out ASPos, ANpos : Integer;
                               AWChars : string = '' ) : Boolean;
var
  Ind : Integer;
  RE : TK_RegExprCont;

begin
  Ind := 0;
  RE.REFlags := [K_RESearch];
  Result := FALSE;
  while true do
  begin
    Result := K_CheckTextPatternEx( APSStr + Ind, ANumS - Ind, APPat, ANumP, AWChars, @RE );
    if Result or (RE.REFPos > ANumS - Ind) then Break;
    Inc(Ind);
  end;
  if Result then
  begin
    ASPos := RE.RESPos + Ind;
    ANPos := RE.REFPos + Ind;
  end;
end; // function  K_SearchTextPattern

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CheckKeyExpr
//********************************************************** K_CheckKeyExpr ***
// Check if string corresponds to Keys Expression
//
//     Parameters
// SStr    - checked string
// KeyExpr - keys expression string
// Result  - Returns =true if testing string corresponds to given Keys 
//           Expression
//
//#F
//  KeyExpr string contains Operation Tokens and Context Tokens
//  Operation Token:
//    or
//    and
//    not
//  Context Token:
//    #WildCardPattern - string pattern which contains wildcard chars
//    Substring        - substring which occurs in a given string (the same as #*Substring*)
//    .String          - string which is equal to a given string (the same as #String)
//#/F
//
function K_CheckKeyExpr( const SStr : string; const KeyExpr : string  ) : Boolean;
var
  WRes, OpMode, ORMode, ANDMode, NOTMode : Boolean;
  KeyElem : string;
  UCStr : string;

begin
  K_CompareKeyAndStrTokenizer.setSource( KeyExpr );
  Result := false;
  OpMode := false;
  NOTMode := false;
  ANDMode := false;
  ORMode := true;
  UCStr := UpperCase(SStr);

  while K_CompareKeyAndStrTokenizer.hasMoreTokens(true) do begin
    KeyElem := K_CompareKeyAndStrTokenizer.nextToken;

    if SameText( KeyElem, 'not' ) then begin
      NOTMode := true xor NOTMode;
      continue;
    end;

    if OpMode then begin
    // Select operation mode
      OpMode := false;
      ANDMode := false;

      ORMode := SameText( KeyElem, 'or' );
      if not ORMode then
        ANDMode := SameText( KeyElem, 'and' );
      if ORMode or ANDMode then begin
        NOTMode := false;
        Continue;
      end;
    // wrong operation code compare lexem in OR mode
      ORMode := true;
    end;

    // Check expression current Context lexeme
    if (not Result and ORMode) or (not ORMode and Result) then begin

      // Calculate current element result
      if KeyElem[1] = '#' then // Wild card pattern
        WRes := K_CheckTextPattern( UCStr, Copy( KeyElem, 2, Length(KeyElem) ), false)
      else if KeyElem[1] = '.'  then
        WRes := StrIComp( PChar(KeyElem) + 1, PChar(UCStr) ) = 0
      else                       // Substring
        WRes := Pos( UpperCase(KeyElem), UCStr ) > 0;

      if NOTMode then
        WRes := WRes xor NOTMode;

      // Calculate current expression result
      if ORMode then
        Result := Result or WRes
      else if ANDMode then
        Result := Result and WRes;

    end;
    OpMode := true;
    NOTMode := false;
  end;
end; //*** end of K_CheckKeyExpr

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SearchInStrings(1)
//**************************************************** K_SearchInStrings(1) ***
// Search strings in given Strings List by given conditions
//
//     Parameters
// AResSL     - resulting Strings List
// ASearchSL  - Strings List to search
// ASeachCond - search conditions expression string
// AResFormat - resulting Strings List format string:
// AMaxSNum   - maximal number of proper strings
// Result     - Returns number of proper strings
//
function K_SearchInStrings( AResSL, ASearchSL : TStrings; const ASeachCond : string;
                            ACheckProc : TK_CheckStringProc;
                            const AResFormat : string = ''; AMaxSNum : Integer = 0  ) : Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to ASearchSL.Count - 1 do begin
    if not ACheckProc( ASearchSL[i], ASeachCond ) then Continue;
    Inc( Result );
    if (AMaxSNum > 0) and (Result >= AMaxSNum) then break;
    if (AResFormat = '') or (AResSL = nil) then Continue;
    AResSL.Add( format( AResFormat, [ i, ASearchSL[i] ] ) );
  end;
end; // function K_SearchInStrings

{*** TK_SearchInFiles ***}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_SearchInFiles\Create
//************************************************* TK_SearchInFiles.Create ***
// TK_SearchInFiles class constructor
//
constructor TK_SearchInFiles.Create;
begin
  SIFFNamePat          := '*.*';
  SIFFoundStrRFormat   := '%0.4d >> %s';
  SIFFoundFileRFormat  := '**** %s N=%d';
  SIFNFoundFileRFormat := '';
  SIFCheckProc := K_CheckKeyExpr;
end; // TK_SearchInFiles.Create

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_SearchInFiles\FileTestFunc
//******************************************* TK_SearchInFiles.FileTestFunc ***
// Single File Test Function
//
// Paramenters APathName - testing file path AFileName - testing file path 
// Result - Returns K_tucOK because test all files
//
function TK_SearchInFiles.FileTestFunc( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
var
  RCount, RSLInd : Integer;
  FName : string;
begin
  Result := K_tucOK;
  if AFileName = '' then Exit;
  FName := APathName + AFileName;
  FSL.LoadFromFile( FName );
  RSLInd := SIFResultStrings.Count;
  SIFResultStrings.Add( '' );
  RCount := K_SearchInStrings( SIFResultStrings, FSL, SIFSeachCond, SIFCheckProc, SIFFoundStrRFormat, SIFFileFoundMax );
  if RCount = 0 then begin
    if SIFNFoundFileRFormat <> '' then
      SIFResultStrings[RSLInd] := format( SIFNFoundFileRFormat, [FName] )
    else
      SIFResultStrings.Delete(RSLInd);
  end else begin
    if SIFFoundFileRFormat <> '' then
      SIFResultStrings[RSLInd] := format( SIFFoundFileRFormat, [FName, RCount] )
    else
      SIFResultStrings.Delete(RSLInd);
  end;
end; // TK_SearchInFiles.FileTestFunc

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_SearchInFiles\SIFSearchResultsToStrings
//****************************** TK_SearchInFiles.SIFSearchResultsToStrings ***
// Search info in given files set and put results to given Strings
//
// Paramenters AResStrings - resulting Strings Object
//
// If AResStrings = nil then Current Resulting Strings will be used or new 
// Current Resulting Strings will be created if Current Resulting Strings 
// doesn't exist
//
function TK_SearchInFiles.SIFSearchResultsToStrings( const AResStrings: TStrings ): TStrings;
begin
  FSL := TStringList.Create;
  if AResStrings <> nil then
    SIFResultStrings := AResStrings;
  if SIFResultStrings = nil then
    SIFResultStrings := TStringList.Create;
  K_ScanFilesTree( SIFFilesPath, FileTestFunc, SIFFNamePat );
  Result := SIFResultStrings;
  FSL.Free;
end; // TK_SearchInFiles.SIFSearchResultsToStrings

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_SearchInFiles\SIFSearchResultsToFile
//********************************* TK_SearchInFiles.SIFSearchResultsToFile ***
// Search info in given files set and put results to given file
//
// Paramenters AResFName - resulting file name
//
function TK_SearchInFiles.SIFSearchResultsToFile( const AResFName: string ): TStrings;
var
  FreeStringsFlag : Boolean;
begin
  FreeStringsFlag := SIFResultStrings = nil;
  SIFSearchResultsToStrings( nil );
  SIFResultStrings.SaveToFile( AResFName );
  if FreeStringsFlag then
    FreeAndNil( SIFResultStrings );
  Result := SIFResultStrings;
end; // TK_SearchInFiles.SIFSearchResultsToFile

{*** end of TK_SearchInFiles ***}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_MessageDlg
//************************************************************ K_MessageDlg ***
// Show Message Dialog in modal window
//
//     Parameters
// ACaption     - Dialog Form Caption
// AMessageLine - Dialog Form message text
// ADlgType     - Dialog Type enumeration
// ADlgButtons  - Dialog Form Buttons Set
// AHelpCtxt    - numeric ID for context-sensitive help topic, if > 0 then help 
//                button will be added to message window
//
function K_MessageDlg( const ACaption, AMessageLine : string;
                       ADlgType: TMsgDlgType; ADlgButtons: TMsgDlgButtons;
                       AHelpCtxt: Integer = -1 ) : Word;
var
  WCapt : string;
  DlgForm : TForm;
begin
  WCapt := ACaption;
  if WCapt = '' then
    WCapt := ChangeFileExt( ExtractFileName( Application.ExeName ), '' );
  if AHelpCtxt >= 0 then
    ADlgButtons := ADlgButtons + [mbHelp];
  DlgForm := CreateMessageDialog( AMessageLine, ADlgType, ADlgButtons );
//  N_MakeFormVisible( DlgForm, [fvfCenter] );
  with DlgForm do
    try
      Caption := WCapt;
      HelpType := htContext;
      HelpContext := AHelpCtxt;
      Result := ShowModal;
    finally
      Release;
    end;
end; //*** end of K_MessageDlg


//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ShowMessage
//*********************************************************** K_ShowMessage ***
// Show message in modal window
//
//     Parameters
// MessageLine - message text
// Caption     - message window caption
// MesStatus   - message status (K_msInfo, K_msWarning, K_msError, 
//               K_msDebugInfo) define Icon in message window
// HelpCtxt    - numeric ID for context-sensitive help topic, if > 0 then help 
//               button will be added to message window
//
procedure K_ShowMessage( const MessageLine : string; const Caption : string = '';
                         MesStatus : TK_MesStatus = K_msWarning;
                         HelpCtxt : Longint = -1 );
var
  WCapt : string;
  DlgType : TMsgDlgType;
  DlgButtons : TMsgDlgButtons;
  DlgForm : TForm;
begin
  WCapt := Caption;
  if WCapt = '' then
    WCapt := ChangeFileExt( ExtractFileName( Application.ExeName ), '' );
  DlgType := mtWarning;
  case MesStatus of
    K_msError   : DlgType := mtError;
    K_msInfo    : DlgType := mtInformation;
  end;
  DlgButtons := [mbOK];
  if HelpCtxt >= 0 then
    DlgButtons := DlgButtons + [mbHelp];
  DlgForm := CreateMessageDialog( MessageLine, DlgType, DlgButtons );
//  N_MakeFormVisible2( DlgForm, [rspfPrimMonWAR,rspfCenter] );

  N_Dump1Str(MessageLine);
  with DlgForm do
    try
//      Position := poDesktopCenter;
      Position := poScreenCenter;
      Caption := WCapt;
      HelpType := htContext;
      HelpContext := HelpCtxt;
      ShowModal;
    finally
      Release;
    end;
end; //*** end of K_ShowMessage


//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_BuildISetByIDs
//******************************************************** K_BuildISetByIDs ***
// Build set from string of elements IDs using string with all set elements IDs
//
//     Parameters
// SetIDs   - string with comma separated elements IDS
// SetDescr - string with comma separated all set elements IDS
// Result   - Returns integer bit scale which can contain 0-31 set elements
//
function K_BuildISetByIDs( const SetIDs, SetDescr : string  ) : Integer;
var
  SLS, SLI : TStringList;
  i, j : Integer;
begin
  SLS := TStringList.Create;
  SLS.CommaText := SetDescr;
  SLI := TStringList.Create;
  SLI.CommaText := SetIDs;
  Result := 0;
  for i := 0 to SLI.Count - 1 do begin
    j := SLS.IndexOf( SLI[i] );
    if j < 0 then Continue;
    Result := Result or (1 shl j);
  end;
  SLS.Free;
  SLI.Free;

end; //*** end of K_BuildISetByIDs

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_BuildIDsByISet
//******************************************************** K_BuildIDsByISet ***
// Build set string of elements IDs from set integer bit scale using string with
// all set elements IDs
//
//     Parameters
// SetIDs   - integer bit scale which can contain 0-31 set elements
// SetDescr - string with comma separated all set elements IDS
// Result   - Returns string with comma separated elements IDS
//
function K_BuildIDsByISet( ISet : Integer; const SetDescr : string  ) : string;
var
  SLS, SLI : TStringList;
  i : Integer;
begin
  SLS := TStringList.Create;
  SLS.CommaText := SetDescr;
  SLI := TStringList.Create;
  for i := 0 to SLS.Count - 1 do begin
    if ISet = 0 then break;
    if (ISet and 1) <> 0 then  SLI.Add(SLS[i]);
    ISet := ISet  shr 1;
  end;
  Result := SLI.CommaText;
  SLS.Free;
  SLI.Free;

end; //*** end of K_BuildIDsByISet

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CalcColorGrey8
//******************************************************** K_CalcColorGrey8 ***
// Calculate Color  Grey 8 RGB value
//
//     Parameters
// AColor - RGB color
// Result - Returns color Grey8 value
//
function K_CalcColorGrey8( AColor : Integer ) : Integer;
begin
  Result := Round( 0.114*(AColor and $FF) +           // Blue
                   0.587*((AColor shr 8) and $FF) +   // Green
                   0.299*((AColor shr 16) and $FF) ); // Red;
end; // function K_CalcColorGrey8

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_PrepColorPathByColors
//************************************************* K_PrepColorPathByColors ***
// Prepare Color path from source Colors array
//
//     Parameters
// ColorPath              - resulting array of TK_ColorPath elements - 
//                          parameters of piecewise linear Path
// PPathColors            - pointer to first element in source colors array
// PathColorsCount        - number of elements in source colors array
// PathColorsStep         - elements step in source colors array (default value 
//                          SizeOf(Integer))
// UniformPathPointWeight - uniform path points weight flag (default value 
//                          false); if =true
//
// Resulting piecewise linear Path can be used to calculate colors using weight 
// parameter (from 0 to 100)
//
procedure K_PrepColorPathByColors( var ColorPath : TK_ColorPath;
                                   PPathColors : Pointer; PathColorsCount : Integer;
                                   PathColorsStep : Integer = SizeOf(Integer);
                                   UniformPathPointWeight : Boolean = false );
var
  i : Integer;
  CColor : Integer;
  PathLeng : Double;
  RGB : array [0..2] of Integer;
begin
  SetLength( ColorPath, PathColorsCount );
  PathLeng := 0;
  CColor := PInteger(PPathColors)^;
  RGB[0] :=  CColor and $FF;
  RGB[1] := (CColor shr  8) and $FF;
  RGB[2] := (CColor shr 16) and $FF;
  for i := 0 to PathColorsCount - 2 do
    with ColorPath[i] do begin
      W := PathLeng * 100;
      R := RGB[0];
      G := RGB[1];
      B := RGB[2];
      Inc( TN_BytesPtr(PPathColors), PathColorsStep );
      CColor := PInteger(PPathColors)^;
      RGB[0] := CColor and $FF;
      RGB[1] := (CColor shr  8) and $FF;
      RGB[2] := (CColor shr 16) and $FF;
      DR := RGB[0] - R;
      DG := RGB[1] - G;
      DB := RGB[2] - B;
      if not UniformPathPointWeight then
        PathLeng := PathLeng + Sqrt( Sqr(DR) + Sqr(DG) + Sqr(DB) )
      else
        PathLeng := PathLeng + 1;
    end;

  with ColorPath[PathColorsCount - 1] do
    W := 100;

  for i := 1 to PathColorsCount - 2 do
    with ColorPath[i] do
      W := W / PathLeng;

end; // end of procedure K_PrepColorPathByColors

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_BuildColorByColorPathWeight
//******************************************* K_BuildColorByColorPathWeight ***
// Build Color by Color path
//
//     Parameters
// ColorPath - array of TK_ColorPath elements  - parameters of piecewise linear 
//             Path
// CWeight   - resulting Color weight (from 0 to 100)
// Result    - Returns needed color
//
function K_BuildColorByColorPathWeight( const ColorPath : TK_ColorPath;
                                        CWeight : Double ) : Integer;
var
  i : Integer;
  WC, WD : Double;

begin
  CWeight := Min( CWeight, 100 );
  CWeight := Max( CWeight, 0 );
  with ColorPath[0] do
    Result := R + (G shl  8) + (B shl 16);
  for i := 1 to High(ColorPath) do
  begin
    WC := ColorPath[i].W;
    if CWeight > WC then Continue;
    with ColorPath[i-1] do
    begin
      WD := (CWeight - W) / (WC - W);
      Result := (  Floor(R + DR * WD) and $FF )          or
                (( Floor(G + DG * WD) and $FF ) shl  8 ) or
                (( Floor(B + DB * WD) and $FF ) shl 16 );
      Break;
    end;
  end;


end; // end of K_BuildColorsByColorPath

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_BuildColorsByColorPathWeights
//***************************************** K_BuildColorsByColorPathWeights ***
// Build Colors By ColorPathPoints Array and Color Weights
//
//     Parameters
// ColorPath   - array of TK_ColorPath elements  - parameters of piecewise 
//               linear function
// PColors     - pointer to first element in result colors array
// ColorsCount - number of elements in result colors array
// ColorsStep  - elements step in result colors array (default value 
//               SizeOf(Integer))
// WMin        - weight of first Color (for uniform colors weights) (default 
//               value =0)
// WMax        - weight of last Color (for uniform colors weights) (default 
//               value =100)
// PWeights    - pointer to colors weights array (if not uniform colors weights 
//               needed) (default value =nil)
//
procedure K_BuildColorsByColorPathWeights( const ColorPath : TK_ColorPath;
                                    PColors : Pointer; ColorsCount : Integer;
                                    ColorsStep : Integer = SizeOf(Integer);
                                    WMin : Double = 0; WMax : Double = 100;
                                    PWeights : PDouble = nil );
var
  CWeight : Double;
  CWDelta : Double;
  i : Integer;
begin
  WMax := Min( WMax, 100 );
  WMin := Max( WMin, 0 );
  Dec( ColorsCount );
  CWDelta := (WMax - WMin);
  if ColorsCount > 0 then
    CWDelta := CWDelta / ColorsCount;
  for i := 0 to ColorsCount do begin
    if PWeights <> nil then begin
      CWeight := PWeights^;
      Inc( PWeights );
    end else
      CWeight := WMin + CWDelta * i;
    PInteger(PColors)^ := K_BuildColorByColorPathWeight( ColorPath, CWeight );
    Inc( TN_BytesPtr(PColors), ColorsStep );
  end;

end; // end of K_BuildColorsByColorPath

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_BuildColorsByColorPath
//************************************************ K_BuildColorsByColorPath ***
// Build uniform colors array from path colors array
//
//     Parameters
// PPathColors            - pointer to first element in source path colors array
// PathColorsCount        - source path colors array elements counter
// PColors                - pointer to first element in result colors array
// ColorsCount            - resulting colors array elements counter
// UniformPathPointWeight - uniform path points weight flag (default value 
//                          false); if =true
//
procedure K_BuildColorsByColorPath( PPathColors : PInteger; PathColorsCount : Integer;
                                 PColors : PInteger; ColorsCount : Integer;
                                 UniformPathPointWeight : Boolean = false );
var
  ColorPath : TK_ColorPath;
begin
  K_PrepColorPathByColors( ColorPath, PPathColors, PathColorsCount,
                           SizeOf(Integer), UniformPathPointWeight );
  K_BuildColorsByColorPathWeights( ColorPath, PColors, ColorsCount, SizeOf(Integer) );
end; // end of procedure K_BuildColorsByColorPath

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_NumberToDigits
//******************************************************** K_NumberToDigits ***
// Expand number to series of digits
//
//     Parameters
// Number        - expanded value
// PDigitWeights - pointer to 1-st element of digits weights array 
//                 DigitWeights[0] contains Digit with smallest Weight
// PResults      - pointer to 1-st element of result digits values array
// DCount        - digits counter
//
procedure K_NumberToDigits( Number : Int64; PDigitWeights : PInt64;
                            PResults : PInteger; DCount : Integer );
var
  i : Integer;
begin
  Inc( PDigitWeights, DCount - 1 );
  Inc( PResults, DCount - 1 );
  for i := 1 to DCount do begin
    PResults^ := Number Div PDigitWeights^;
    Number := Number mod PDigitWeights^;
    Dec(PResults);
    Dec(PDigitWeights);
  end;
end; // end of procedure K_NumberToDigits

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CalcCNK
//*************************************************************** K_CalcCNK ***
// Calculate number of combinations of N different elements from K elements set
//
//     Parameters
// AN     - number of elements in set
// AK     - number of different elements in combination
// Result - Returns = AN! / ((AN-AK)!*AK!)
//
function K_CalcCNK( AN, AK: integer ): Integer;
var
  N, i: integer;
  DRes : Double;
begin
  DRes := 1.0;
  N := Min( AK, AN - AK );
  for i := 0 to N - 1 do
    DRes := DRes * (AN - i) / (N - i);
  Result := Round( DRes );
end; // function K_CalcCNK

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_BuildCNKSets
//********************************************************** K_BuildCNKSets ***
// Create array of sets containing AK different members (each set power = AN)
//
//     Parameters
// PSets - pointer to 1-st element of Sets Array
// SStep - step between Sets Array elements
// AN    - number of elements in Set
// AK    - number of different elements in combination
//
procedure K_BuildCNKSets( PSets : Pointer; SStep, AN, AK : Integer );

  // Returns Number Of Sets Which Were build By Routine
  function SetBits( APSet : Pointer; SBitNum, SBitVal : Integer ) : Integer;
  var
    j, i, ck, n, BInd : Integer;
    CurByte : Byte;
    PSet : PByte;
    PSet0 : PByte;

  begin
    Result := 0;
    ck := SBitNum + 1;
    if ck = AK then begin // Last Set Member
      n := AN - SBitVal;
      PSet := APSet;
      for j := SBitVal to AN - 1 do begin
//        BInd := j - 1;
        BInd := j;
        CurByte := K_SetByteMaskAndIndex( BInd );
        PSet0 := PByte( TN_BytesPtr(PSet) + BInd );
        PSet0^ := PSet0^ or CurByte;
        PSet := PByte( TN_BytesPtr(PSet) + SStep );
      end;
      Result := n;
    end else begin
      for i := SBitVal to AN - 1 do begin
    //***  Set Other Bits
        n := SetBits( APSet, ck, i + 1 );
    //***  Set This Bit to Sets, which where set by prev SetBits(...)
//        BInd := i - 1;
        BInd := i;
        CurByte := K_SetByteMaskAndIndex( BInd );
        PSet := PByte( TN_BytesPtr(APSet) + BInd );
        for j := 0 to n - 1 do begin
          PSet^ := PSet^ or CurByte;
          PSet := PByte( TN_BytesPtr(PSet) + SStep );
        end;
        APSet := TN_BytesPtr(PSet) - BInd;
        Inc( Result, n );
      end;
    end;
  end;

begin
  SetBits( PSets, 0, 0 );
end; // end of K_BuildCNKSets

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_TestIfSetIsNotSuperSet
//************************************************ K_TestIfSetIsNotSuperSet ***
// Check if 1-st given Set is not superset on 2-nd given Set
//
//     Parameters
// PSet1  - pointer to 1-st Set bits
// PSet2  - pointer to 2-nd Set bits
// SPower - Sets power
// Result - Returns =true if 1-st Set is not superset on 2-nd Set
//
function K_TestIfSetIsNotSuperSet( PSet1 : Pointer; PSet2 : Pointer; SPower : Integer ) : Boolean;
begin
  Result := K_SetOp2( nil, PSet2, PSet1, SPower, K_sotCLEAR );
end; // end of K_TestIfSetIsNotSuperSet

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_TestIfSetHasNoIntersects
//********************************************** K_TestIfSetHasNoIntersects ***
// Check if intersection of 1-st given set and 2-nd given set is empty
//
//     Parameters
// PSet1  - pointer to 1-st Set bits
// PSet2  - pointer to 2-nd Set bits
// SPower - Sets power
// Result - Returns =true if 1-st Set has no intersections with 2-nd Set
//
function  K_TestIfSetHasNoIntersects( PSet1 : Pointer; PSet2 : Pointer; SPower : Integer ) : Boolean;
begin
  Result := not K_SetOp2( nil, PSet2, PSet1, SPower, K_sotAND );
end; // end of K_TestIfSetHasNoIntersects


//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_BuildProperSetsInds
//*************************************************** K_BuildProperSetsInds ***
// Build indexes of proper Sets array elements
//
//     Parameters
// PInds        - pointer to 1-st element of indexes array
// PASets       - pointer to 1-st element of analyzed Sets array
// AStep        - step between analyzed Sets elements
// ACount       - number of analyzed Sets elements
// PCSets       - pointer to 1-st element of condition Sets array
// CStep        - step between condition Sets elements
// CCount       - number of condition Sets elements
// SPower       - Sets power
// TestSetsFunc - test condition function K_TestIfSetIsNotSuperSet or 
//                K_TestIfSetHasNoIntersects
// Result       - Returns number of proper Sets array elements
//
function K_BuildProperSetsInds( PInds : PInteger; PASets : Pointer; AStep, ACount : Integer;
                                PCSets : Pointer; CStep, CCount : Integer; SPower : Integer;
                                TestSetsFunc : TK_TestSetsFunc ) : Integer;
var
  j, i : Integer;
  ProperSet : Boolean;
  PSCond : TN_BytesPtr;

begin
  Result := 0;
  for i := 0 to ACount - 1 do begin
    ProperSet := true;
    PSCond := PCSets;
    for j := 0 to CCount - 1 do begin
      ProperSet := ProperSet and TestSetsFunc( PASets, PSCond, SPower );
      if not ProperSet then break;
      Inc( PSCond, CStep );
    end;
    Inc (TN_BytesPtr(PASets), AStep );
    if not ProperSet then Continue;
    PInds^ := i;
    Inc( PInds );
    Inc( Result );
  end;
end; // end of K_BuildProperSetsInds

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_LeftStrLengthByWidth
//************************************************** K_LeftStrLengthByWidth ***
// Calculate left substring length in chars by pixel width in given Canvas
//
//     Parameters
// CHandle    - canvas Windows handle
// Str        - source string
// PixelWidth - needed width in pixels
// Result     - Returns the most long left substring length in chars which width
//              is <= PixelWidth
//
function K_LeftStrLengthByWidth( CHandle : HDC; const Str : string;
                                 PixelWidth : Integer ) : Integer;
var
  imax, inext : Integer;
  SSize : TSize;
begin
  Result := 0;
  imax := Length(Str);
  if imax = 0 then Exit;
  while Result <= imax do  begin
    inext := (Result + imax) shr 1;

    Windows.GetTextExtentPoint32( CHandle, PChar(Str), inext, SSize );

    if SSize.cx > PixelWidth then
      imax := inext - 1
    else if SSize.cx < PixelWidth then
      Result := inext + 1
    else begin
      Result := inext;
      break;
    end;
  end;
end; // end of K_LeftStrLengthByWidth

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StrCutByWidth
//********************************************************* K_StrCutByWidth ***
// Build string from given source string which has proper pixel width
//
//     Parameters
// CHandle    - canvas Windows handle
// SrcStr     - source string
// TailStr    - tail string ('...' for example)
// PixelWidth - needed width in pixels
// CutTailStr - cut tail string flag acts if TailStr width is less then 
//              PixelWidth (default value is false)
// Result     - Returns string with width <= PixelWidth
//
// If source string has proper pixel width then result string is equal to source
// string. If source string has too large width, then result string value 
// contains left substring of source string and given tail substring. If source 
// string has too large width and tail string has also too large width, then 
// result string value contains only tail string or its left substring if 
// CutTailStr flag =true/
//
function K_StrCutByWidth( CHandle : HDC; const SrcStr, TailStr : string;
                          PixelWidth : Integer; CutTailStr : Boolean = false ) : string;
var
  SSize : TSize;
  CutWidth : Integer;
  SkipTailStr : Boolean;
begin
  Result := SrcStr;
  Windows.GetTextExtentPoint32( CHandle, PChar(SrcStr), Length(SrcStr), SSize );
  if SSize.cx <= PixelWidth then Exit;
  Windows.GetTextExtentPoint32( CHandle, PChar(TailStr), Length(TailStr), SSize );
//  SSize.cy := PixelWidth  - SSize.cx;
//  SkipTailStr := (SSize.cy < 0) and CutTailStr;
  CutWidth := PixelWidth  - SSize.cx;
  SkipTailStr := (CutWidth < 0) and CutTailStr;
  if SkipTailStr then
  begin
    Result := TailStr;
    CutWidth := PixelWidth;
  end;
  Result := Copy( Result, 1,
                   K_LeftStrLengthByWidth( CHandle, Result, CutWidth ) );
  if not SkipTailStr then
    Result := Result + TailStr;
end; // end of K_StrCutByWidth

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CellDrawString
//******************************************************** K_CellDrawString ***
// Grid cell string draw handler
//
//     Parameters
// Str       - source string
// DrawRect  - draw string rectangle
// HPos      - text horizontal position enum (K_ppUpLeft, K_ppCenter, 
//             K_ppDownRight)
// VPos      - text vertical position enum (K_ppUpLeft, K_ppCenter, 
//             K_ppDownRight)
// Canvas    - Pascal canvas object
// Padding   - cell padding value
// FontColor - font color
// FontStyle - byte value equal to set of TFontStyle enum  (fsBold, fsItalic, 
//             fsUnderline, fsStrikeOut)
//
procedure K_CellDrawString( Str : string; DrawRect: TRect; HPos : TK_CellPos; VPos : TK_CellPos;
            Canvas : TCanvas; Padding : Integer = 8; FontColor : TColor = -1;
            FontStyle : Byte = $FF );
var
  TextSize : TSize;
  x, y : Integer;
  FontSave  : TFontRecall;
begin

  FontSave := nil;

  if FontColor <> - 1 then begin
    FontSave := TFontRecall.Create( Canvas.Font );
    Canvas.Font.Color := FontColor;
  end;

  if FontStyle <> $FF then begin
    if FontSave = nil then FontSave := TFontRecall.Create( Canvas.Font );
    Canvas.Font.Style := TFontStyles(FontStyle);
  end;

  Str := K_StrCutByWidth( Canvas.Handle, Str, '...', DrawRect.right - DrawRect.left - Padding - Padding );
  TextSize := Canvas.TextExtent(Str);

  x := 0;
  case HPos of
    K_ppCenter    : x := Round((DrawRect.right + DrawRect.left - TextSize.cx)/2);
    K_ppUpLeft    : x := DrawRect.left + Padding;
    K_ppDownRight : x := DrawRect.right - TextSize.cx - Padding;
  end;

  y := 0;
  case VPos of
    K_ppCenter    : y := Round((DrawRect.Bottom + DrawRect.Top - TextSize.cy)/2);
    K_ppUpLeft    : y := DrawRect.Top + Padding;
    K_ppDownRight : y := DrawRect.Bottom - TextSize.cy - Padding;
  end;
  Canvas.TextRect( DrawRect, x, y, Str );
//  Canvas.TextOut( x, y, WStr );
  if (FontColor <> - 1) or (FontStyle <> $FF) then begin
    FontSave.Free;
  end;

end; // end of K_CellDrawString

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetStringsToBuf
//******************************************************* K_GetStringsToBuf ***
// Get strings interval to string buffer
//
//     Parameters
// ASBuf       - resulting string buffer (resulting buffer length may be larger 
//               then resulting string)
// ASS         - strings list (TStrings object)
// ASInd       - start strings interval index
// ASCount     - interval strings counter
// ASkipLastLF - skip last string delimiter chars
// ADelims     - string delimires
// Result      - Returns resulting string length in bytes without terminating 
//               zero.
//
function  K_GetStringsToBuf( var ASBuf : string; ASL : TStrings; ASInd : Integer;
                             ASCount : Integer = -1; ASkipLastLF : Boolean = true;
                             ADelims : string = '' ) : Integer;
var
  i, L : Integer;
  S, LB : string;
  P : PChar;
  DL : Integer;
begin
  LB := #13#10;
  if ADelims <> '' then
    LB := ADelims;
  DL := Length( LB );
  Result := 0;
  if ASCount < 0 then ASCount := ASL.Count;
  for i := ASInd to ASInd + ASCount - 1 do Inc( Result, Length(ASL[i]) + DL );
  if ASkipLastLF then Dec( Result, DL );
  if Result < 0 then
    Result := 0;
  L := Length(ASBuf);
  if K_NewCapacity( Result + 1, L ) then
    SetLength( ASBuf, L );
//  if L > Result then
  ASBuf[Result+1] := Chr(0);

  P := Pointer(ASBuf);
  for i := ASInd to ASInd + ASCount - 1  do begin
    S := ASL[i];
    L := Length(S);
    if L <> 0 then begin
      Move( Pointer(S)^, P^, L * SizeOf(Char) );
      Inc( P, L );
    end;
    if ASkipLastLF and (i = ASInd + ASCount - 1) then Continue;
    // Add EndOfLine Chars
//    PWord(P)^ := PWord(Pointer(LB))^
    P^ := LB[1];
    if DL > 1 then begin
      (P + 1)^ := LB[2];
      if DL > 2 then
        Move( LB[3], (P + 2)^, (DL - 2) * SizeOf(Char) );
    end;
    Inc( P, DL );
  end;
end; // end of K_GetStringsToBuf
{
function  K_GetStringsToBuf( var ASBuf : string; ASL : TStrings; ASInd : Integer;
                             ASCount : Integer = -1; ASkipLastLF : Boolean = true ) : Integer;
var
  i, L : Integer;
  S, LB : string;
  P : PChar;
begin
  LB := #13#10;
  Result := 0;
  if ASCount < 0 then ASCount := ASL.Count;
  for i := ASInd to ASInd + ASCount - 1 do Inc( Result, Length(ASL[i]) + 2 );
  if ASkipLastLF then Dec( Result, 2 );
  L := Length(ASBuf);
  if K_NewCapacity( Result, L ) then
    SetLength( ASBuf, L );
  if L > Result then
    ASBuf[Result+1] := Chr(0);
  P := Pointer(ASBuf);
  for i := ASInd to ASInd + ASCount - 1  do begin
    S := ASL[i];
    L := Length(S);
    if L <> 0 then begin
      Move( Pointer(S)^, P^, L * SizeOf(Char) );
      Inc( P, L );
    end;
    if ASkipLastLF and (i = ASInd + ASCount - 1) then Continue;
    // Add EndOfLine Chars
    PWord(P)^ := PWord(Pointer(LB))^;
    Inc( P, 2 );
  end;
end; // end of K_GetStringsText
}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetStringsText
//******************************************************** K_GetStringsText ***
// Get strings interval as text
//
//     Parameters
// ASS         - strings list (TStrings object)
// ASInd       - start strings interval index
// ASCount     - interval strings counter
// ASkipLastLF - skip last string linefeed chars
// Result      - Returns text with all given strings
//
function  K_GetStringsText( ASL : TStrings; ASInd : Integer; ASCount : Integer = -1;
                            ASkipLastLF : Boolean = false ) : string;
begin
  SetLength( Result, K_GetStringsToBuf( Result, ASL, ASInd, ASCount, ASkipLastLF ) );
{
var
  i, L : Integer;
  S, LB : string;
  P : PChar;
begin
  LB := #13#10;
  L := 0;
  if ASCount < 0 then ASCount := ASL.Count;
  for i := ASInd to ASInd + ASCount - 1 do Inc( L, Length(ASL[i]) + 2 );
  if ASkipLastLF then Dec( L, 2 );
  SetString(Result, nil, L);
  P := Pointer(Result);
  for i := ASInd to ASInd + ASCount - 1  do begin
    S := ASL[i];
    L := Length(S);
    if L <> 0 then begin
      Move( Pointer(S)^, P^, L * SizeOf(Char) );
      Inc( P, L );
    end;
    if ASkipLastLF and (i = ASInd + ASCount - 1) then Continue;
    // Add EndOfLine Chars
    PWord(P)^ := PWord(Pointer(LB))^;
    Inc( P, 2 );
  end;
}
end; // end of K_GetStringsText

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SearchInStrings(2)
//**************************************************** K_SearchInStrings(2) ***
// Search proper string in strings list interval
//
//     Parameters
// ASL             - strings list (TStrings object)
// ASubStr         - compare substring
// ASInd           - strings list start interval index
// ASCount         - strings list interval counter
// AFullStrCompare - compare full string flag, if =false then search substring
// AIgnoreCase     - ignore case while compare strings flag
// AAnyOccurrence  - if TRUE then search any occurrence, else check only "left"
// Result          - Returns index of proper string in strings list, =-1 if 
//                   proper string not found
//
function  K_SearchInStrings( ASL : TStrings; const ASubStr : string;
                             ASInd : Integer = 0; ASCount : Integer = 0;
                             AFullStrCompare : Boolean = false;
                             AIgnoreCase : Boolean = false;
                             AAnyOccurrence : Boolean  = false ) : Integer;
var
  WSTR : string;
begin
  if ASCount <= 0 then ASCount := ASL.Count - ASInd;
  for Result := ASInd to ASInd + ASCount - 1  do
  begin
    WSTR := ASL[Result];
    if AFullStrCompare then
    begin
      if not AIgnoreCase then
      begin
        if WSTR = ASubStr then Exit;
      end
      else
      if SameText( WSTR, ASubStr ) then Exit;
    end
    else
    begin
      if AAnyOccurrence then
      begin
        if Pos( ASubStr, WSTR ) > 0 then Exit;
      end
      else
      if K_StrStartsWith( ASubStr, WSTR, AIgnoreCase ) then Exit;
    end;
  end;
  Result := -1;
end; // end of K_SearchInStrings

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_IndexOfStringsName
//**************************************************** K_IndexOfStringsName ***
// Get index of string with given Name in list of <Name>=<Value> strings
//
//     Parameters
// ASL    - strings list (TStrings object)
// AName  - seach string Name value
// Result - Returns index of proper string <Name>=<Value>, or -1 if string with 
//          given Name not found
//
// Own version of algorithm instead of Pascal TStrings.IndexOfName
//
function  K_IndexOfStringsName( ASL : TStrings; const AName : string ) : Integer;
begin
  Result := K_SearchInStrings( ASL, AName + '=' );
end; // end of K_IndexOfStringsName

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetStringsValueByName
//************************************************* K_GetStringsValueByName ***
// Get Value by given Name in list of <Name>=<Value> strings
//
//     Parameters
// ASL       - strings list (TStrings object)
// AName     - seach string Name value
// ADefValue - default resulting value
// Result    - Returns Value of proper string <Name>=<Value>, or ADefValue if 
//             string with given Name not found
//
// Own version of algorithm instead of Pascal TStrings.Values[] property
//
function  K_GetStringsValueByName( ASL : TStrings; const AName : string;
                                   ADefValue : string = '' ) : string;
var
  WSTR : string;
  i : Integer;
begin
  Result := ADefValue;
  i := K_SearchInStrings( ASL, AName + '=' );
  if i < 0 then Exit;
  WSTR := ASL[i];
  Result := Copy( WSTR, Length(AName) + 2, Length(WSTR) );
end; // end of K_GetStringsValueByName

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ReplaceStringsInterval
//************************************************ K_ReplaceStringsInterval ***
// Replace destination strings list interval by given source strings list 
// interval
//
//     Parameters
// DS     - destination strings list (TStrings object)
// DInd   - destination strings start interval index
// DCount - destination strings interval counter
// SS     - source strings list (TStrings object)
// SInd   - source strings start interval index
// SCount - source strings interval counter
//
procedure K_ReplaceStringsInterval( DS : TStrings; DInd : Integer; DCount : Integer;
                            SS : TStrings; SInd : Integer; SCount : Integer );
var
  i : Integer;
begin
  if DInd < 0 then DInd := DS.Count;
  if DCount < 0 then DCount := DS.Count;
  if DInd + DCount > DS.Count then DCount := DS.Count - DInd;
  if SInd < 0 then SInd := SS.Count;
  if SCount < 0 then SCount := SS.Count;
  if SInd + SCount > SS.Count then SCount := SS.Count - SInd;

  DS.BeginUpdate;
  if DCount > SCount then
    for i := 0 to DCount - SCount - 1 do DS.Delete( DInd )
  else
    for i := 0 to SCount - DCount - 1 do DS.Insert( DInd, '' );

  for i := 0 to SCount - 1 do
  begin
    DS[DInd] := SS[SInd];
    DS.Objects[DInd] := SS.Objects[SInd];
    Inc(DInd);
    Inc(SInd);
  end;
  DS.EndUpdate;
end; // end of K_ReplaceStringsInterval

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ExcludeCorrespondingStrings
//******************************************* K_ExcludeCorrespondingStrings ***
// Exclude Strings given as TStringList from Strings given as TStrings
//
//     Parameters
// ASL  - Strings where to exclude, as TStrings
// AESL - Strings to exclude, as TStringlist
//
procedure K_ExcludeCorrespondingStrings( ASL : TStrings; AESL : TStringList  );
var
  i, Ind : Integer;
begin
  if not AESL.Sorted then
    AESL.Sort();
  for i := ASL.Count - 1 downto 0 do
    if AESL.Find( ASL[i], Ind ) then
      ASL.Delete(i);
end; //*** end of K_ExcludeCorrespondingStrings

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_PutTextToClipboard
//**************************************************** K_PutTextToClipboard ***
// Put text to System Clipboard
//
//     Parameters
// AText       - source text for putting to clip board
// AAnsiCoding - put text to Clipboard without convertion to Unicode flag (if 
//               FALSE then text will be converted to Unicode)
//
procedure K_PutTextToClipboard( const AText : string; APutAnsiStr : Boolean = false );
var
  Data: THandle;
  DataPtr: Pointer;
  Size : Integer;
  Buffer : WideString;

begin
  if (AText <> '') and not APutAnsiStr then
  begin
    Buffer := N_Conv1251ToUnicode ( AText );
    size := ( Length(AText) + 1 ) * 2;
    try
      Data := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, Size);
      try
        DataPtr := GlobalLock(Data);
        try
          Move(Buffer[1], DataPtr^, Size);
          Clipboard.SetAsHandle( CF_UNICODETEXT, Data );
        finally
          GlobalUnlock(Data);
        end;
      except
        GlobalFree(Data);
        raise;
      end;
    finally
    end;
  end
  else
    Clipboard.AsText := AText;
end; // procedure K_PutTextToClipboard

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetTextFromClipboard
//************************************************** K_GetTextFromClipboard ***
// Get Text from System Clipboard
//
//     Parameters
// Result - Returns text from clipboard
//
function K_GetTextFromClipboard( ) : string;
var
  Data: THandle;

begin
  if Clipboard.HasFormat(CF_UNICODETEXT) then begin
    Data := Clipboard.GetAsHandle( CF_UNICODETEXT );
    try
      if Data <> 0 then
        Result := N_ConvUnicodeTo1251 ( PWideChar(GlobalLock(Data)) )
      else
        Result := '';
    finally
      if Data <> 0 then GlobalUnlock(Data);
    end;
  end else
    Result := Clipboard.AsText;
end; // function K_GetTextFromClipboard

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_AddTextToClipboard
//**************************************************** K_AddTextToClipboard ***
// Add given AText to System Clipboard
//
//     Parameters
// AText       - source text to add to clip board
// AAnsiCoding - put text to Clipboard without convertion to Unicode flag (if 
//               FALSE then text wil be converted to Unicode)
//
procedure K_AddTextToClipboard( const AText : string; APutAnsiStr : Boolean = false );
var
  Str: string;
begin
  Str := K_GetTextFromClipboard(); // current Clipboard content
  N_AddCRLFIfNotYet( Str );        // add CRLF if CRLF are not two last chars in Str
  Str := Str + AText;
  K_PutTextToClipboard( Str, APutAnsiStr );
end; // procedure K_AddTextToClipboard

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_RoundDVectorBySum
//***************************************************** K_RoundDVectorBySum ***
// Round Double Vector Elements using it's round sum
//
//     Parameters
// APSrcDVector - pointer to source Double Vector first element
// ACount       - number of elements in given vector
// APDstDVector - pointer to resulting Double Vector first element
// APSplitVal   - pointer to rounded value to split
// Result       - Returns vector sum
//
function K_RoundDVectorBySum( APDstDVector : PDouble;
                              ACount : Integer;
                              APSrcDVector : PDouble;
                              APSplitVal : PDouble = nil ) : Double;
var
  i, n : Integer;
  RSum, Sum : Double;
  PSV, PDV : PDouble;
  PSVE, PDVE : PDouble;
  ElemInc : Boolean;
  SplitVal : Double;
  SVals : TN_DArray;
begin

  // Calculate Round Values
  PSV := APSrcDVector;
  PDV := APDstDVector;
  Result := 0;
  RSum := 0;
  for i := 1 to ACount do begin
    PDV^ := Round(PSV^);
    Result  := Result  + PSV^;
    RSum := RSum + PDV^;
    Inc(PDV);
    Inc(PSV);
  end;
  Sum := Round(Result);

  // Get Round Sum
  if APSplitVal = nil then
    SplitVal := Sum
  else
    SplitVal := APSplitVal^;


  // Compare  Round Sum and Sum of Rounds
  n := Trunc(RSum - SplitVal);
  if n = 0 then Exit; // Correction is not needed

  if (APSplitVal <> nil) and (Abs(n) > ACount) then begin
  // Recalc Vector if given Sum of Rounds is far from Resulting Sum
    SetLength( SVals, ACount );
    PSV := APSrcDVector;
    PDV := APDstDVector;
    RSum := 0;
    for i := 0 to ACount - 1 do begin
      SVals[i] := PSV^ * SplitVal / Sum;
      PDV^ := Round( SVals[i] );
      RSum := RSum + PDV^;
      Inc(PDV);
      Inc(PSV);
    end;
    APSrcDVector := @SVals[0];
    n := Trunc(RSum - SplitVal);
    if n = 0 then Exit;
  end;

  // Correct Resulting Round Elements
  ElemInc := n < 0;
  PSV  := APSrcDVector;
  PDV  := APDstDVector;
  i := (ACount - 1) * SizeOf(Double);
  PSVE := PDouble(TN_BytesPtr(PSV) + i);
  PDVE := PDouble(TN_BytesPtr(PDV) + i);
  while LongWord(PSV) < LongWord(PSVE) do begin
    if ElemInc then begin
    // Elements Increment Needed
      if PDV^ < PSV^ then begin
        PDV^ := PDV^ + 1;
        Inc(n);
      end;
      if n = 0 then Break;
      if PDVE^ < PSVE^ then begin
        PDVE^ := PDVE^ + 1;
        Inc(n);
      end;
      if n = 0 then Break;
    end else begin
    // Elements Decrement Needed
      if PDV^ > PSV^ then begin
        PDV^ := PDV^ - 1;
        Dec(n);
      end;
      if n = 0 then Break;
      if PDVE^ > PSVE^ then begin
        PDVE^ := PDVE^ - 1;
        Dec(n);
      end;
      if n = 0 then Break;
    end;
    Inc(PDV);
    Inc(PSV);
    Dec(PDVE);
    Dec(PSVE);
  end;

end; // function K_RoundDVectorBySum

//***************************************************** K_RoundDVectorByRoundSum ***
// Round Double Vector Elements using it's round sum
//
//     Parameters
// APSrcDVector - pointer to source Double Vector first element
// ACount       - number of elements in given vector
// APDstDVector - pointer to resulting Double Vector first element
// APSplitVal   - pointer to rounded value to split
// Result       - Returns vector sum
//
function K_RoundDVectorByRoundSum( APDstDVector : PDouble;
                              ACount : Integer;
                              APSrcDVector : PDouble;
                              APSplitVal : PDouble = nil ) : Double;
var
  i, n : Integer;
  RSum : Double;
  PSV, PDV : PDouble;
  PSVE, PDVE : PDouble;
  ElemInc : Boolean;
  SplitVal : Double;
  SVals : TN_DArray;
begin

  PSV := APSrcDVector;
  if (APSplitVal <> nil) then begin
  // Calculate Round Values
    Result := 0;
    for i := 1 to ACount do begin
      Result  := Result  + PSV^;
      Inc(PSV);
    end;
    SetLength( SVals, ACount );
    PSV := APSrcDVector;
    PDV := APDstDVector;
    RSum := 0;
    SplitVal := APSplitVal^;
    for i := 0 to ACount - 1 do begin
      SVals[i] := PSV^ * APSplitVal^ / Result;
      PDV^ := Round( SVals[i] );
      RSum := RSum + PDV^;
      Inc(PDV);
      Inc(PSV);
    end;
    APSrcDVector := @SVals[0];
  end else begin
    PDV := APDstDVector;
    Result := 0;
    RSum := 0;
    for i := 1 to ACount do begin
      PDV^ := Round(PSV^);
      Result  := Result  + PSV^;
      RSum := RSum + PDV^;
      Inc(PDV);
      Inc(PSV);
    end;
    SplitVal := Round(Result);
//    PSV := APSrcDVector;
  end;

  n := Trunc(RSum - SplitVal);
  if n = 0 then Exit;

  // Correct Resulting Round Elements
  ElemInc := n < 0;
  PSV  := APSrcDVector;
  PDV  := APDstDVector;
  i := (ACount - 1) * SizeOf(Double);
  PSVE := PDouble(TN_BytesPtr(PSV) + i);
  PDVE := PDouble(TN_BytesPtr(PDV) + i);
  while LongWord(PSV) < LongWord(PSVE) do begin
    if ElemInc then begin
    // Elements Increment Needed
      if PDV^ < PSV^ then begin
        PDV^ := PDV^ + 1;
        Inc(n);
      end;
      if n = 0 then Break;
      if PDVE^ < PSVE^ then begin
        PDVE^ := PDVE^ + 1;
        Inc(n);
      end;
      if n = 0 then Break;
    end else begin
    // Elements Decrement Needed
      if PDV^ > PSV^ then begin
        PDV^ := PDV^ - 1;
        Dec(n);
      end;
      if n = 0 then Break;
      if PDVE^ > PSVE^ then begin
        PDVE^ := PDVE^ - 1;
        Dec(n);
      end;
      if n = 0 then Break;
    end;
    Inc(PDV);
    Inc(PSV);
    Dec(PDVE);
    Dec(PSVE);
  end;

end; // function K_RoundDVectorByRoundSum

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_ReplaceCommaByPoint
//*************************************************** K_ReplaceCommaByPoint ***
// Prepare string for number parsing by replacing decimal comma to point
//
//     Parameters
// AStr   - string to replace ',' to '.'
// Result - Returns prepared string
//
function K_ReplaceCommaByPoint( AStr : String  ) : string;
var
  tlength : Integer;
  i : Integer;
begin
  i := 1;
  tlength := Length( AStr );
  Result := AStr;
  while i <= tlength do begin
    if Result[i] = ',' then Result[i] := '.';
    Inc(i);
  end;
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_BCGBriMinMaxPrep
//****************************************************** K_BCGBriMinMaxPrep ***
// Prepare Brightness Convertion MinMax Values
//
//     Parameters
// ABriMax       - Image Brightness Maximal Value
// ANegateFlag   - Negate Convertion Flag
// ABriMinFactor - Image Brightness Convertion Minimal Factor Value
// ABriMaxFactor - Image Brightness Convertion Maximal Factor Value
// ABriConvMin   - resulting Brightness Convertion Minimal Value
// ABriConvMax   - resulting Brightness Convertion Maximal Value
//
procedure K_BCGBriMinMaxPrep( ABriMax : Integer; ANegateFlag : Boolean;
                              ABriMinFactor, ABriMaxFactor : Double;
                              out ABriConvMin, ABriConvMax : Integer );
var
  CurInt : Integer;
begin
// Prepare Convertion Min/Max
  if (ABriMinFactor = 0) and (ABriMaxFactor = 0) then
    ABriMaxFactor := 100;
  ABriConvMin := Round( ABriMax * ABriMinFactor / 100 );
  ABriConvMax := Round( ABriMax * ABriMaxFactor / 100 );

  if ABriConvMin = ABriConvMax then
  begin
    if ABriConvMin > 1 then
      Dec(ABriConvMin)
    else
      Inc(ABriConvMax);
  end;

  if ANegateFlag then
  begin
    CurInt := ABriConvMin;
    ABriConvMin := ABriMax - ABriConvMax;
    ABriConvMax := ABriMax - CurInt;
  end;

end; // procedure K_BCGBriMinMaxPrep

{
BriFactor and CoFactor control zone in Relative Intensity Space XR, YR
          0 <= XR <= XRMax and  0 <= YR <= YRMax
          -1 <= BriFactor <= 1 and -1 <= CoFactor <= 1
if CoFactor is 0 < CoFactor <= 1 then Convertion Line
           YRMax
           .          CCCC
           .         C
           .        C
           .       C
           .      C
           .     C
           .    C
           .   C
           CCCC.............
      (0,0)   XR1    XR2   XRMax
          XRMin
        DXR = XR2 - XR1 = 1 + (XRMax - 1) * (1 - CoFactor)
        XR1 = (XRMax - DXR) / 2;
if BriFactor -1 <= BriFactor <= 1
        XRMin := XR1 - (XRMax - XR1) * BriFactor;
Finally
        YR  = (XR-XRMin) * YRMax / DXR

if CoFactor is -1 <= CoFactor <= 0 then Convertion Line
           YRMax
           ..................
           .                .
       YR2 .               Ñ.
           .            C   .
           .         C      .
           .      C         .
           .   C            .
YRMin, YR1 .C               .
           .                .
           ..................
        (0,0)            XRMax

        DYR = YR2 - YR1 = 1 + (YRMax - 1) * (1 + CoFactor)
        YR1 = (YRMax - DYR) / 2;
if BriFactor -1 <= BriFactor <= 1
        YRMin := YR1 - (YRMax - YR1) * BriFactor;
Finally
        YR  = YRMin + XR * DYR / XRMax

BriFactor and CoFactor control zone in Absolute Intensity Space X, Y
          0 <= X <= VMax and  0 <= Y <= VMax
          -1 <= BriFactor <= 1 and -1 <= CoFactor <= 1

          0 <= XMin < XMax <= VMax
          XR = X - XMin,  XRMax = XMax - XMin,
          YR = Y,  YRMax = VMax

}
{ Replace by N_BCGImageXlatBuild
//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_BCGImageXlatBuild
//***************************************************** K_BCGImageXlatBuild ***
// Build Image correction XLat Table
//
//     Parameters
// AXLat       - Image XLat correction table
// ACoFactor   - Image Contrast factor (float from -100 to 100, 0 - no contarst
//               correction done)
// ABriFactor  - Image Brightness factor (float from -100 to 100, 0 - no
//               brightness correction done)
// AGamFactor  - Image Gamma factor (float from -100 to 100, 0 - no gamma
//               correction done)
// ABriMinFactor - Image Brightness Convertion Minimal Factor Value
// ABriMaxFactor - Image Brightness Convertion Maximal Factor Value
// ANegateFlag - Negate Convertion Flag
//
procedure K_BCGImageXlatBuild( const AXLat : TN_IArray;
                               ACoFactor, ABriFactor, AGamFactor : Double;
                               ABriMinFactor, ABriMaxFactor : Double;
                               ANegateFlag : Boolean );
var
  i, VMax : Integer;
  XMin0, XMin, YMin0, YMin, DX, DY : Integer;
  CVXLat : Integer;
  Delta : Double;
  CurInt : Integer;
  BriConvMin, BriConvMax : Integer;
  XMax : Integer;
  YMax : Integer;
begin
  VMax := High(AXLat);

// Prepare Convertion Min/Max
  K_BCGBriMinMaxPrep( VMax, ANegateFlag, ABriMinFactor, ABriMaxFactor, BriConvMin, BriConvMax );

  AGamFactor := AGamFactor / 100;
  ACoFactor  := ACoFactor  / 100;
  ABriFactor := ABriFactor / 100;

  Delta := Abs(AGamFactor);
  if AGamFactor >= 0 then  // 0 <= AGamFactor < 1
    Delta := 1.0 - 0.9 * Delta
  else                     // -1 <= AGamFactor < 0
    Delta := 1.0 + 9.0 * Delta;

  XMax := BriConvMax - BriConvMin;
  YMax := VMax;
  DX := 1;
  XMin := VMax;
  DY := 1;
  YMin := VMax;
  if ACoFactor > 0 then
  begin
    DX := 1 + Round( (XMax - 1) * (1.0 - ACoFactor) );
    XMin0 := Round( (XMax - DX) / 2 );
    XMin := XMin0 - Round( (XMax - XMin0) * ABriFactor );
  end
  else
  begin
    DY := 1 + Round( (YMax - 1) * (1.0 + ACoFactor) );
    YMin0 := Round( (YMax - DY) / 2 );
    YMin := YMin0 + Round( (YMax - YMin0) * ABriFactor );
  end;

  for i := 0 to VMax do begin
    CurInt := i;
    if ANegateFlag then
      CurInt := VMax - i;
    if CurInt < BriConvMin then
      CVXLat := 0
    else
    if CurInt > BriConvMax then
      CVXLat := VMax
    else
    begin
      CurInt := CurInt - BriConvMin;
      if ACoFactor > 0 then
        CVXLat := Round( 1.0 * (CurInt - XMin) * YMax / DX )
      else
        CVXLat := Round( 1.0 * CurInt * DY / XMax  +  YMin );
    end;

    CVXLat := Max( 0, CVXLat );
    CVXLat := Min( VMax, CVXLat );

    AXLat[i] := Round( VMax * Power( CVXLat/VMax, Delta ) );

  end;

end; // procedure K_BCGImageXlatBuild
}

{*** TK_LineSegmFunc ***}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_LineSegmFunc\Create
//************************************************** TK_LineSegmFunc.Create ***
// Calculate Line-Segment Function Object constructor
//
//     Parameters
// AArgFuncPoints - array of pair (ArgValue1, FuncValue1, ... ArgValueN, 
//                  FuncValueN)
//
constructor TK_LineSegmFunc.Create( AArgFuncPoints: array of Double);
var
  i, n, j : Integer;
begin
  n :=  Length(AArgFuncPoints) shr 1;

  SetLength( LSFArgVals, n );
  SetLength( LSFFuncVals, n );

  j := 0;
  for i := 0 to n - 1 do begin
    LSFArgVals[i] := AArgFuncPoints[j];
    Inc(j);
    LSFFuncVals[i] := AArgFuncPoints[j];
    Inc(j);
  end;

  LSFLastSegmInd := 0; // Segment Index for Search optimization
end; // constructor TK_LineSegmFunc.Create

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_LineSegmFunc\Arg2Func
//************************************************ TK_LineSegmFunc.Arg2Func ***
// Calculate Line-Segment Function value by given Argument value
//
//     Parameters
// AArgVal - Argument value
// Result  - Returns Function value coresponding to given Argument value
//
function TK_LineSegmFunc.Arg2Func( AArgVal: Double ): Double;
var
  i : Integer;
  FuncStartVal : Double;
  ArgStartVal : Double;

  procedure CalcFuncVal ();
  begin
    ArgStartVal := LSFArgVals[LSFLastSegmInd];
    FuncStartVal := LSFFuncVals[LSFLastSegmInd];
    Result := FuncStartVal + (LSFFuncVals[LSFLastSegmInd + 1] - FuncStartVal) *
              (AArgVal - ArgStartVal) / (LSFArgVals[LSFLastSegmInd + 1] - ArgStartVal);
  end;

begin
  if (AArgVal < LSFArgVals[LSFLastSegmInd]) then begin
    Result := LSFFuncVals[0];
    for i := LSFLastSegmInd - 1 downto 0 do
      if AArgVal >= LSFArgVals[i] then begin
        LSFLastSegmInd := i;
        CalcFuncVal ();
        Break;
      end;
    Exit;
  end;
  if (AArgVal >= LSFArgVals[LSFLastSegmInd + 1]) then begin
    Result := LSFFuncVals[High(LSFFuncVals)];
    for i := LSFLastSegmInd + 1 to High(LSFFuncVals) - 1 do
      if AArgVal < LSFArgVals[i + 1] then begin
        LSFLastSegmInd := i;
        CalcFuncVal ();
        Break;
      end;
    Exit;
  end;
  CalcFuncVal ();

end; // function TK_LineSegmFunc.Arg2Func

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_LineSegmFunc\Func2Arg
//************************************************ TK_LineSegmFunc.Func2Arg ***
// Calculate Line-Segment Function Argument value by given Function value
//
//     Parameters
// AFuncVal - Function value
// Result   - Returns Argument value coresponding to given Function value
//
function TK_LineSegmFunc.Func2Arg( AFuncVal: Double ): Double;
var
  i : Integer;
  FuncStartVal : Double;
  ArgStartVal : Double;

  procedure CalcArgVal ();
  begin
    FuncStartVal := LSFFuncVals[LSFLastSegmInd];
    ArgStartVal := LSFArgVals[LSFLastSegmInd];
    Result := ArgStartVal + (LSFArgVals[LSFLastSegmInd + 1] - ArgStartVal) *
              (AFuncVal - FuncStartVal) / (LSFFuncVals[LSFLastSegmInd + 1] - FuncStartVal);
  end;

begin
  if (AFuncVal < LSFFuncVals[LSFLastSegmInd]) then begin
    Result := LSFArgVals[0];
    for i := LSFLastSegmInd - 1 downto 0 do
      if AFuncVal >= LSFFuncVals[i] then begin
        LSFLastSegmInd := i;
        CalcArgVal ();
        Break;
      end;
    Exit;
  end;
  if (AFuncVal >= LSFFuncVals[LSFLastSegmInd + 1]) then begin
    Result := LSFArgVals[High(LSFFuncVals)];
    for i := LSFLastSegmInd + 1 to High(LSFFuncVals) - 1 do
      if AFuncVal < LSFFuncVals[i + 1] then begin
        LSFLastSegmInd := i;
        CalcArgVal ();
        Break;
      end;
    Exit;
  end;
  CalcArgVal ();

end; // function TK_LineSegmFunc.Func2Arg

{*** end of TK_LineSegmFunc ***}

//************************************************ SelectDirCB ***
// Callback function for K_SelectFolder
//
function SelectDirCB(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
begin
  if (uMsg = BFFM_INITIALIZED) and (lpData <> 0) then
    SendMessage(Wnd, BFFM_SETSELECTION, Integer(True), lpdata);
  result := 0;
end; // function SelectDirCB

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SelectFolder
//********************************************************** K_SelectFolder ***
// Call Windows Dialog to select Folder
//
//     Parameters
// ACaption - dialog window caption
// ARoot    - Root Folder
// AFolder  - on input folder selected in Folders TreeView, on output Folder 
//            selected by User
// Result   - Returns TRUE if User press OK button
//
function K_SelectFolder(const ACaption: string; const ARoot: WideString;
  var AFolder: string ): Boolean;
const
  BIF_NONEWFOLDERBUTTON=$200;

var
  WindowList: Pointer;
  BrowseInfo: TBrowseInfo;
  Buffer: PChar;
  OldErrorMode: Cardinal;
  RootItemIDList, ItemIDList: PItemIDList;
  IShellMalloc: IMalloc;
  IDesktopFolder: IShellFolder;
  Eaten, Flags: LongWord;
begin
  Result := False;
  if not DirectoryExists(AFolder) then
    AFolder := '';
  FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
  if (ShGetMalloc(IShellMalloc) = S_OK) and (IShellMalloc <> nil) then
  begin
    Buffer := IShellMalloc.Alloc(MAX_PATH);
    try
      RootItemIDList := nil;
      if ARoot <> '' then
      begin
        SHGetDesktopFolder(IDesktopFolder);
        IDesktopFolder.ParseDisplayName(Application.Handle, nil,
                          POleStr(ARoot), Eaten, RootItemIDList, Flags);
      end;

      with BrowseInfo do
      begin
        hwndOwner := GetActiveWindow();
//        hwndOwner := Application.Handle;
        pidlRoot := RootItemIDList;
        pszDisplayName := Buffer;
        lpszTitle := PChar(ACaption);
//        ulFlags := BIF_RETURNONLYFSDIRS + BIF_NEWDIALOGSTYLE;
//        ulFlags := BIF_RETURNONLYFSDIRS + BIF_USENEWUI;
        if K_SelectFolderNewStyle then
          ulFlags := BIF_RETURNONLYFSDIRS + BIF_USENEWUI
        else
          ulFlags := BIF_RETURNONLYFSDIRS + BIF_STATUSTEXT;

//        ulFlags := ulFlags + BIF_NONEWFOLDERBUTTON;
//        ulFlags := ulFlags xor BIF_NONEWFOLDERBUTTON;

        if AFolder <> '' then
        begin
          lpfn := SelectDirCB;
          lParam := Integer(PChar(AFolder));
        end;
      end; // with BrowseInfo do

      WindowList := DisableTaskWindows(0);
      OldErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
      try
        ItemIDList := ShBrowseForFolder(BrowseInfo);
      finally
        SetErrorMode(OldErrorMode);
        EnableTaskWindows(WindowList);
      end;

      Result :=  ItemIDList <> nil;
      if Result then
      begin
        ShGetPathFromIDList(ItemIDList, Buffer);
        IShellMalloc.Free(ItemIDList);
//        GlobalFreePtr(ItemIDList);
        AFolder := Buffer;
      end;

    finally // try
      IShellMalloc.Free(Buffer);
      IShellMalloc._Release();
    end;    // try
  end; // if (ShGetMalloc(IShellMalloc) = S_OK) and (IShellMalloc <> nil) then
end; // function K_SelectFolder

//******************************************************* K_SelectFolderNew ***
// Call Windows Dialog to select Folder (able to add new folder)
//
//     Parameters
// ACaption - dialog window caption
// AFolder  - on input folder selected in Folders View, on output Folder
//            selected by User
// Result   - Returns TRUE if User press OK button
//
function K_SelectFolderNew( const ACaption: string; var AFolder: string ): Boolean;
begin
{$IF CompilerVersion >= 26.0}
  if Win32MajorVersion >= 6 then
  begin
    with TFileOpenDialog.Create(nil) do
      try
        Result := FALSE;
        if ACaption <> '' then
          Title := ACaption;
        Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem]; // YMMV
  //      OkButtonLabel := 'Select';
        DefaultFolder := AFolder;
        FileName := AFolder;
        Result := Execute;
        if Result then
          AFolder := FileName;
      finally
        Free;
      end;
  end
  else
{$IFEND CompilerVersion >= 26.0}
  begin
    Result := K_SelectFolder( ACaption, '', AFolder );
  end;
end; // function K_SelectFolderNew

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetColorsRGBDif
//******************************************************* K_GetColorsRGBDif ***
// Get given Colors RGB Difference Sum
//
//     Parameters
// AColor1 - compared Color
// AColor2 - compared Color
// Result  - Returns given Colors RGB Difference
//
function K_GetColorsRGBDif( AColor1, AColor2 : TColor ) : Double;
begin
  AColor1 := ColorToRGB(AColor1);
  AColor2 := ColorToRGB(AColor2);
  Result := Power( Abs((Integer(AColor1) and $FF) - (Integer(AColor2) and $FF)), 2 );
  Result := Result + Power( Abs(((Integer(AColor1) shr 8) and $FF) - ((Integer(AColor2) shr 8) and $FF)), 2 );
  Result := Result + Power( Abs(((Integer(AColor1) shr 16) and $FF) - ((Integer(AColor2) shr 16) and $FF)), 2 );
  Result := sqrt( Result / 3 ) / 255;
end; // function K_GetContrastColor


//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetContrastColor
//****************************************************** K_GetContrastColor ***
// Get Color contrast to given Color
//
//     Parameters
// ASrcColor - source Color
// Result    - Returns RGB Color contrast togiven Color
//
function K_GetContrastColor( ASrcColor : TColor ) : Integer;
var
  RC : Double;
begin
  RC := K_GetColorsRGBDif( ASrcColor, 0 );
  if RC > 0.64 then
    Result := 0
  else
    Result := $FFFFFF;
end; // function K_GetContrastColor

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SelectColorDlg
//******************************************************** K_SelectColorDlg ***
// Select Color by Windows Color Select Dialog
//
//     Parameters
// AColor - on input start Color on output resulting Color
// Result - Returns TRUE if new color was selected and differs fromgiven
//
function  K_SelectColorDlg( var AColor : TColor ) : Boolean;
var
  ColorDialog : TColorDialog;
  i : Integer;
  CC : Char;
  FColor : Integer;
begin
  Result := FALSE;
  ColorDialog := TColorDialog.Create( Application );
  FColor := ColorToRGB(AColor);
  ColorDialog.Color := FColor;

//  Set Custom Colors
  CC := 'A';
  for i := 0 to 15 do begin
    ColorDialog.CustomColors.Add( 'Color'+CC+'='+IntToHex( K_SelectCustomColors[i], 6 ) );
    Inc(CC);
  end;

  if ColorDialog.Execute and
     (FColor <> ColorDialog.Color) then begin
    AColor := ColorDialog.Color;
    Result := TRUE;
  end;

//  Save Custom Colors
  for i := 0 to 15 do
    K_SelectCustomColors[i] := StrToIntDef( '$' + ColorDialog.CustomColors.ValueFromIndex[i], 0 );

  ColorDialog.Free;
end;

//************************************************  K_EnumFontsProc ***
// Callback function  for K_GetSysFontFaceNamesList enumeration
//
//     Parameters
// ALogFont - logical-font data
// ATextMetric - physical-font data
// AFontType -font type, parameter can be a combination of these values:
//#F
//     DEVICE_FONTTYPE
//     RASTER_FONTTYPE
//     TRUETYPE_FONTTYPE
//#/F
// AData - application-defined data passed by this function
// Result - Returns value should be non zero to continue enumeration and zero to
//          stop enumeration
//
//function K_EnumFontsProc( var ALogFont: TEnumLogFont; var ATextMetric: TTextMetric;
//                          AFontType: Integer; AData: Pointer ): Integer; stdcall;
function K_EnumFontsProc( APLogFont: PEnumLogFont; APTextMetric: PTextMetric;
                          AFontType: Integer; AData: Pointer ): Integer; stdcall;
var
  S: TStrings;
  Temp: string;
begin
  S := TStrings(AData);
  Temp := APLogFont^.elfLogFont.lfFaceName;
//  if (AFontType and DEVICE_FONTTYPE) <> 0 then temp := temp + ' DEVICE';
//  if (AFontType and RASTER_FONTTYPE) <> 0 then temp := temp + ' RASTER';
//  if (AFontType and TRUETYPE_FONTTYPE) <> 0 then temp := temp + ' TRUETYPE';
  if (S.Count = 0) or (AnsiCompareText(S[S.Count-1], Temp) <> 0) then
    S.Add(Temp);
  Result := 1;
end; // function K_EnumFontsProc

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetSysFontFaceNamesList
//*********************************************** K_GetSysFontFaceNamesList ***
// Fill List with System Fonts Face Names List
//
//     Parameters
// AFontFaceNames - string with resulting Fonts Face Names List
//
procedure K_GetSysFontFaceNamesList( AFontFaceNames : TStrings );
var
  DC: HDC;
  LFont: TLogFont;
begin
  DC := GetDC(0);
  FillChar(LFont, sizeof(LFont), 0);
  LFont.lfCharset := DEFAULT_CHARSET;
  EnumFontFamiliesEx(DC, LFont, @K_EnumFontsProc, LongInt(AFontFaceNames), 0);
end; // procedure K_GetSysFontFaceNamesList

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DateTimeToStr
//********************************************************* K_DateTimeToStr ***
// Ñonvert TDateTime to string
//
//     Parameters
// ADateTime - DateTime value
// AFmt      - convertion format as in pascal FormatDateTime(), if AFmt equals 
//             empty string then 'dd.mm.yyyy hh:nn:ss' format string will be 
//             used.
// Result    - Returns string with converted ADateTime
//
// Back convertion from string to TDateTime can be done by K_StrToDateTime
//
function K_DateTimeToStr( ADateTime: TDateTime; AFmt : string = '' ) : string;
begin
  if AFmt = '' then
    AFmt := 'dd.mm.yyyy hh:nn:ss';
  Result := FormatDateTime( AFmt, ADateTime );
end; // end_of procedure K_DateTimeToStr

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StrToDateTime
//********************************************************* K_StrToDateTime ***
// Ñonvert string to TDateTime value
//
//     Parameters
// AStr           - source string with DateTime text representation
// APParseErrFlag - pointer to parsing error flag
// Result         - Returns TDateTime value parsed from given string
//
function K_StrToDateTime( const AStr : string; ATimeParseFlag : Boolean = false; APParseErrFlag : PBoolean = nil ) : TDateTime;
var
  st : TK_Tokenizer;
  i, value : Integer;
  DateInt : array [0..6] of Integer;
  Delim : Char;
  DateMode : Boolean;

  procedure NormDate;
  var j, k : Integer;
  begin
    k := i - 1;
    for j := 2 downto i do begin
      if k >= 0 then begin
        DateInt[j] := DateInt[k];
        DateInt[k] := 1;
      end;
      Dec(k);
    end;
  end;

begin
  Result := 0;
  for i := 0 to 2 do DateInt[i] := 1;
  for i := 3 to High(DateInt) do DateInt[i] := 0;
  st := TK_Tokenizer.Create( PChar(AStr), './ :-' );
  DateMode := not ATimeParseFlag;
  i := 0;
  if not DateMode then
    i := 3;
  if APParseErrFlag <> nil then APParseErrFlag^ := FALSE;
  while ( st.HasMoreTokens ) and ( i <= High(DateInt) ) do  begin
    value := StrToIntDef( st.NextToken, 0 );
    Delim := st.GetDelimiter;
    if DateMode and (Delim = ':') then begin
      NormDate;
      DateMode := false;
      i := 3;
    end;
    DateInt[i] := value;
    Inc(i);
  end;
  NormDate;
  st.Free;
  if not ATimeParseFlag then begin
    if DateInt[0] > 100 then begin
      value := DateInt[2];
      DateInt[2] := DateInt[0];
      DateInt[0] := value;
    end else if DateInt[2] < 100 then
      Inc(DateInt[2], 2000);
  end;
  try
    if not ATimeParseFlag then
      Result := EncodeDate( DateInt[2], DateInt[1], DateInt[0] );
    Result := Result + EncodeTime( DateInt[3], DateInt[4], DateInt[5], DateInt[6] );
  except
    if APParseErrFlag <> nil then APParseErrFlag^ := TRUE;
  end;
end; // end_of procedure K_StrToDateTime

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_FreeSpaceBufCheck
//***************************************************** K_FreeSpaceBufCheck ***
// Check Memory Free Space for creating Buffer Array
//
//     Parameters
// ABufSize - given Buffer Size in bytes
// Result   - Returns TRUE if ABufSize Buffer Array can be created
//
function K_FreeSpaceBufCheck( ABufSize: Integer ) : Boolean;
var
  WBuf : TN_BArray;
begin
  Result := ABufSize <= 0;
  if Result then Exit;
  try
    SetLength( WBuf, ABufSize );
    WBuf := nil;
  except
    Exit; // not enough space
  end;

  Result := TRUE;
end; // function K_FreeSpaceBufCheck

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_FreeSpaceMemCheck
//***************************************************** K_FreeSpaceMemCheck ***
// Check Memory Free Space for GlobalAlloc
//
//     Parameters
// ABufSize - given Buffer Size in bytes
// Result   - Returns TRUE if ABufSize Memory was allocated
//
function K_FreeSpaceMemCheck( ABufSize: Integer ) : Boolean;
var
  HMem : THandle;
begin
  Result := ABufSize <= 0;
  if Result then Exit;
  HMem := Windows.GlobalAlloc( GMEM_MOVEABLE, ABufSize );
  if HMem = 0 then Exit;
  Windows.GlobalFree( HMem );
  Result := TRUE;
end; // function K_FreeSpaceMemCheck

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_FreeSpaceSearchMax
//**************************************************** K_FreeSpaceSearchMax ***
// Search for Free Space maximal value
//
//     Parameters
// AMax         - start maximal value to search
// ACheckFunc   - function to check free space
// ADPercentage - stop search delta percentage - 100 * (Max - Min) / Max
// Result       - Returns Maximal available memory size
//
function K_FreeSpaceSearchMax( AMax : Integer; ACheckFunc : TK_FreeSpaceCheckFunc;
                               ADPercentage : Integer = 0  ): Integer;
var
  AMin : Integer;
  ACur : Integer;
begin
  AMin := 0;
  if ADPercentage = 0 then ADPercentage := 5;
  if AMax > 0 then
  begin
    while (1.0*(AMax - AMin) / AMax) > (ADPercentage / 100.0) do
    begin
      ACur := Round(0.5*AMax + 0.5*AMin);
      if ACheckFunc( ACur ) then
        AMin := ACur
      else
        AMax := ACur;
    end;
  end;

  Result := AMin;
end; // function K_FreeSpaceSearchMax

//*************************************************** K_GetFreeSpaceProfile ***
// Build Memory Free Space profile
//
//     Parameters
// AProfileSize - number of free space memory blocks in profile
// ADPercentage - stop search delta percentage - 100 * (Max - Min) / Max
// Result       - Returns string with sizes of maximal memory blocks
//
procedure K_GetFreeSpaceProfile( AProfileSize : Integer = 0;
                                 ADPercentage : Integer = 0 );
var
  AH : array [0..9] of THandle;
  i : Integer;
begin
  if (AProfileSize <= 0) or (AProfileSize > Length(K_FreeSpaceProfile)) then
    AProfileSize := Length(K_FreeSpaceProfile);

  // Clear Profile
  ZeroMemory( @K_FreeSpaceProfile[0], SizeOf(LongWord) * Length(K_FreeSpaceProfile) );

  // Allocate Memory Blocks
  for i := 0 to AProfileSize - 1 do
  begin
    K_FreeSpaceProfile[i] := K_FreeSpaceSearchMax( 2000000000, K_FreeSpaceMemCheck, ADPercentage );
    AH[i] := Windows.GlobalAlloc( GMEM_MOVEABLE, K_FreeSpaceProfile[i] );
  end;

  // Free allocated Memory Blocks
//  for i := 0 to AProfileSize - 1 do
//    Windows.GlobalFree( AH[i] );
  for i := AProfileSize - 1 downto 0 do
    Windows.GlobalFree( AH[i] );

end; // procedure K_GetFreeSpaceProfile

//************************************************ K_GetFreeSpaceProfileStr ***
// Prepare string with sizes of blocks in Memory Free Space profile
//
//     Parameters
// Result       - Returns string with sizes of maximal free memory blocks
//
function  K_GetFreeSpaceProfileStr( ADelim : string = ''; AFormat : string = '' ) : string;
var
  i, j : Integer;
  WStr : string;
  ProfileSum : double;
begin
  if ADelim = '' then ADelim := ' ';
  Result := '';
  ProfileSum := 0;
  j := 0;
  for i := 0 to High(K_FreeSpaceProfile) do
  begin
    if K_FreeSpaceProfile[i] = 0 then Break;
    Inc(j);
    ProfileSum := ProfileSum + K_FreeSpaceProfile[i];
    if i > 0 then Result := Result + ADelim;
    if AFormat = '' then
      WStr := IntToStr(K_FreeSpaceProfile[i])
    else
      WStr := format( AFormat, [1.0*K_FreeSpaceProfile[i]] );
    Result := Result + WStr;
  end;
  Result := Result + format( ' : N=%d S=%.0n', [j,1.0*ProfileSum]);

end; // function  K_GetFreeSpaceProfileStr

//************************************************ K_GetFreeSpaceProfileStr ***
// Get Free Memory Space Info
//
//     Parameters
// ASL - resulting strings
// AProfileSize - number of free space memory blocks in profile
// ADPercentage - stop search delta percentage - 100 * (Max - Min) / Max
//
procedure K_GetFreeSpaceInfo( ASL : TStrings; AProfileSize : Integer = 0;
                              ADPercentage : Integer = 0 );
begin
  K_GetFreeSpaceProfile( AProfileSize, ADPercentage);
  ASL.Add( ' ' + K_GetFreeSpaceProfileStr('; ', '%.0n') );
  N_DelphiHeapInfo( ASL, $0080 );
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetStringFromVarRec
//*************************************************** K_GetStringFromVarRec ***
// Get string value from given TVarRec structure
//
//     Parameters
// APVarRec - pointer to TVarRec structure
// ADefVal  - default value, is used if given structure is not string data
// Result   - Returns String extracted from give TVarRec structure
//
function K_GetStringFromVarRec( APVarRec : PVarRec; const ADefVal : string ): string;
begin
  Result := ADefVal;
  with APVarRec^ do
    case VType of
//      vtString     : Result := string( PShortString(VString)^ );
//      vtAnsiString : Result := string(AnsiString(VAnsiString));
//      vtWideString : Result := string(WideString(VWideString));
//{$IF SizeOf(Char) = 2}
//      vtUnicodeString : Result := string(VUnicodeString);
//{$IFEND}
      vtString     : Result := N_AnsiToString( PShortString(VString)^ );
      vtAnsiString : Result := N_AnsiToString( AnsiString(VAnsiString) );
      vtWideString : Result := N_WideToString( WideString(VWideString) );
{$IF SizeOf(Char) = 2}
      vtUnicodeString : Result := string(VUnicodeString);
{$IFEND}
    end;
end; // function K_GetStringFromVarRec


//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetWinUserDocumentsPath
//*********************************************** K_GetWinUserDocumentsPath ***
// Get Windows User Documents Path ('My Documents')
//
//     Parameters
// ASubFolder - internal path to concatenate to base User Documents Path
//
function K_GetWinUserDocumentsPath( const ASubFolder : string = '' ) : string;
begin
  SetLength(Result, MAX_PATH);
  if not SHGetSpecialFolderPath(0, PChar(Result), CSIDL_PERSONAL, TRUE ) then
    Result := GetEnvironmentVariable( 'USERPROFILE' ) + '\My documents\'
  else
    Result := PChar(Result) + '\';
  Result := Result + ASubFolder;

end; // function K_GetWinUserDocumentsPath()

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetWinEnvironmentStrings
//********************************************** K_GetWinEnvironmentStrings ***
// Get Windows Environment Variables to given Strings
//
//     Parameters
// AStrings - Strings to Environment Variables place
//
procedure K_GetWinEnvironmentStrings( AStrings : TStrings );
var
  PC2, PC1, PC0 : PWideChar;
  WStr : string;
begin
  PC0 :=  GetEnvironmentStringsW();
  PC2 := PC0;
  while PC2^ <> WideChar(0) do
  begin
    PC1 := PC2;
    while PC2^ <> WideChar(0) do
      Inc(PC2);

    if SizeOf(Char) = 2 then
    begin
      AStrings.Add( PC1 );
      N_i := Length( WStr ); // to avoid warning in Delphi 2010
    end else
    begin
      WideCharToStrVar( PC1, WStr );
      AStrings.Add( WStr );
    end;

    Inc(PC2);
  end;
  FreeEnvironmentStrings( PChar(PC0) );

end; // procedure K_GetWinEnvironmentStrings

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetWinEnvStrings
//****************************************************** K_GetWinEnvStrings ***
// Get Windows Environment Variables to K_WinEnvironmentStrings
//
procedure K_GetWinEnvStrings( );
begin
  if K_WinEnvironmentStrings = nil then
    K_WinEnvironmentStrings := THashedStringList.Create();
  K_WinEnvironmentStrings.Clear;
  K_GetWinEnvironmentStrings( K_WinEnvironmentStrings );
end; // procedure K_GetWinEnvStrings

//**************************************************** K_GetFileVersionInfo ***
// Get Application Version Information
//
//     Parameters
// APFieldName  - pointer to strings array start element with file info field names
//                names
// APFieldValue - pointer to strings array start element with resulting file info field values
// AFieldCount  - number of fields to get
//
procedure K_GetFileVersionInfo( AFilePath : string; APFieldName, APFieldValue: PString; AFieldCount : Integer );
var
  i: Integer;
  Len, n : LongWord;
  Value: PChar;
  Buf : Pointer;
  FLanguageInfo : string;

begin
  n := GetFileVersionInfoSize(PChar(AFilePath), Len);

  if n = 0 then
    Exit;

  Buf := AllocMem(n);

  GetFileVersionInfo(PChar(AFilePath), 0, n, Buf);

  // Get Language Info
  VerQueryValue( Buf,  '\VarFileInfo\Translation', Pointer(Value), Len );
  FLanguageInfo := 'StringFileInfo\040904E4\'; // default  English USA
  if Len = 4 then
    FLanguageInfo := 'StringFileInfo\' + IntToHex(TN_PUInt2(Value)^, 4) +
                                         IntToHex(TN_PUInt2(TN_BytesPtr(Value)+2)^, 4) + '\';

  // Get Fields Values
  for i := 1 to AFieldCount do
  begin
    VerQueryValue( Buf, PChar(FLanguageInfo + APFieldName^), Pointer(Value), Len);
    if Len > 0 then
      APFieldValue^ := String(Value);
    Inc(APFieldName);
    Inc(APFieldValue);
  end; // for i := 1 to AFieldCount do

  FreeMem(Buf, n);
end; // procedure K_GetFileVersionInfo

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_GetAppVersionInfo
//***************************************************** K_GetAppVersionInfo ***
// Get Application Version Information
//
//     Parameters
// APFieldName  - pointer to strings array start element with file info field names
//                names
// APFieldValue - pointer to strings array start element with resulting file info field values
// AFieldCount  - number of fields to get
//
procedure K_GetAppVersionInfo( APFieldName, APFieldValue: PString; AFieldCount : Integer );
begin
  K_GetFileVersionInfo( Application.ExeName, APFieldName, APFieldValue, AFieldCount );
{
var
  S: string;
  i: Integer;
  Len, n : LongWord;
  Value: PChar;
  Buf : Pointer;
  FLanguageInfo : string;

begin
  S := Application.ExeName;
  n := GetFileVersionInfoSize(PChar(S), Len);

  if n = 0 then
    Exit;

  Buf := AllocMem(n);

  GetFileVersionInfo(PChar(S), 0, n, Buf);

  // Get Language Info
  VerQueryValue( Buf,  '\VarFileInfo\Translation', Pointer(Value), Len );
  FLanguageInfo := 'StringFileInfo\040904E4\'; // default  English USA
  if Len = 4 then
    FLanguageInfo := 'StringFileInfo\' + IntToHex(TN_PUInt2(Value)^, 4) +
                                         IntToHex(TN_PUInt2(TN_BytesPtr(Value)+2)^, 4) + '\';

  // Get Fields Values
  for i := 1 to AFieldCount do
  begin
    VerQueryValue( Buf, PChar(FLanguageInfo + APFieldName^), Pointer(Value), Len);
    if Len > 0 then
      APFieldValue^ := String(Value);
    Inc(APFieldName);
    Inc(APFieldValue);
  end; // for i := 1 to AFieldCount do

  FreeMem(Buf, n);
}
end; // procedure K_GetAppVersionInfo

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_StringWinEnvMListReplace
//********************************************** K_StringWinEnvMListReplace ***
// String macro replace using Windows Environment Variables
//
//     Parameters
// ASrc            - source string
// AUndefMacroMode - undefined macro calls replacing mode (K_ummPutErrText,
//                   K_ummRemoveMacro, K_ummSaveMacro, K_ummSaveMacroName,
//                   K_ummRemoveResult)
// APErrNum        - pointer to variable with macro errors counter (undefined
//                   macro calls) if =nil then macro errors is not used
// Result          - Returns result string (after macroexpansion)
//
// Current Windows Environment Variables are stored in K_WinEnvironmentStrings 
// object
//
function  K_StringWinEnvMListReplace( const ASrc : string;
                        AUndefMacroMode : TK_UndefMacroMode = K_ummSaveMacro;
                        APErrNum : PInteger = nil ) : string;
begin
  Result := K_StringMListReplace( ASrc, K_WinEnvironmentStrings, AUndefMacroMode,
                        APErrNum, '%', '%' );
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SListWinEnvMListReplace
//*********************************************** K_SListWinEnvMListReplace ***
// Strings macro replace using Windows Environment Variables
//
//     Parameters
// ASList          - strings list with replacing strings
// AUndefMacroMode - undefined macro calls replacing mode (K_ummPutErrText,
//
// Current Windows Environment Variables are stored in K_WinEnvironmentStrings 
// object
//
procedure K_SListWinEnvMListReplace( ASList : TStrings;
                        AUndefMacroMode : TK_UndefMacroMode = K_ummSaveMacro );
begin

  K_SListMListReplace( ASList, K_WinEnvironmentStrings, AUndefMacroMode,
                                 '%', '%' );
end;

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_SortMemIniSection
//***************************************************** K_SortMemIniSection ***
// Sort MemIniFile section items
//
//     Parameters
// AMemIni        - TMemIniFile object
// ASectName      - AMemIni section name
// ACaseSensitive - if = TRUE then section items would be sorted in 
//                  CaseSensitive order
//
procedure K_SortMemIniSection( AMemIni : TMemIniFile; const ASectName : string;
                               ACaseSensitive : Boolean = FALSE );
var
  SL : TStringList;
  i : Integer;
begin
  SL := TStringList.Create();
  SL.CaseSensitive := ACaseSensitive;
  AMemIni.ReadSectionValues( ASectName, SL );
  SL.Sort();

  AMemIni.EraseSection( ASectName );
  for i := 0 to SL.Count - 1 do
    AMemIni.WriteString( ASectName, SL.Names[i], SL.ValueFromIndex[i] );

end; // procedure K_SortMemIniSection


//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_EncodeXMLChars
//******************************************************** K_EncodeXMLChars ***
// Encode given string Chars for XML use
//
//     Parameters
// AStr   - given string to encode Quote Chars
// Result - Returns resulting string with Quote Chars replaced by &quote;
//
function K_EncodeXMLChars( const AStr : string  ) : string;
var
  RInd, Ind, L, AL1, Al2, i : Integer;
  XMLStr : string;
const
  QuoteStr = '&quot;';
  AmpStr = '&amp;';
  LTStr = '&lt;';
  GTStr = '&gt;';

begin
  Result := '';
  L := Length( AStr );
  if L = 0 then Exit;
  Ind := 1;
  AL1 := 0;
  for i := 1 to L do
  begin

    case AStr[i] of
    '"' : begin
      XMLStr := QuoteStr;
      end;
    '&' : begin
      XMLStr := AmpStr;
      end;
    '<' : begin
      XMLStr := LTStr;
      end;
    '>' : begin
      XMLStr := GTStr;
      end;
    else
      Continue;
    end;

    RInd := AL1 + 1;
    AL2 := i - Ind;
    AL1 := AL1 + AL2 + Length(XMLStr);
    K_SetStringCapacity( Result, AL1 );
    if AL2 > 0 then
    begin
      Move( AStr[Ind], Result[RInd], AL2 * SizeOf(Char) );
      RInd := RInd + AL2;
    end;
    Move( XMLStr[1], Result[RInd], Length(XMLStr) * SizeOf(Char) );
    Ind := i + 1;
  end;
  L := L - Ind + 1;
  AL2 := AL1 + L;
  SetLength(Result, AL2);
  if L = 0 then Exit;
  RInd := AL1 + 1;
  Move( AStr[Ind], Result[RInd], L * SizeOf(Char) );
end; // function K_EncodeXMLChars

//******************************************************* N_AnalizeBOMBytes ***
// Analize Stream BOM (Byte Order Mark) Bytes and return recognised encoding mode
//
//     Parameters
// AStream  - given Straem to analize
// Result     - Returns recognized Encode Mode
//
//#F
// Possble BOM (Byte Order Mark) bytes:
// 0000 FEFF - teUTF32BE - UTF-32 big-endian    - not implemented
// FFFE 0000 - teUTF32LE - UTF-32 little-endian - not implemented
// FEFF      - teUTF16BE - UTF-16 big-endian    - not implemented
// FFFE      - teUTF16LE - UTF-16 little-endian (Delphi)
// EF BB BF  - teUTF8    - UTF-8
//#/F
//
// Returns teANSI if none of Unicode cases was recognized
//

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_AnalizeStreamBOMBytes
//************************************************* K_AnalizeStreamBOMBytes ***
//
//
function K_AnalizeStreamBOMBytes( const AStream: TStream ): TN_TextEncoding;
var
  W21 : Word; // UnicodeSignature
  W22 : Word; // UnicodeSignature
  TextLength : Integer;
begin

  Result := teANSI;
  TextLength := AStream.Size;
  if TextLength >= 2 then
  begin
    AStream.Read( W21, 2 );
    if W21 = $FEFF then
      Result := teUTF16LE
    else
    if W21 = $FFFE then
      Result := teUTF16BE;

    if TextLength >= 3 then
    begin
      if W21 = $BBEF then
      begin
        AStream.Read( W21, 1 );
        if Byte(W21) = $BF then
          Result := teUTF8
      end
      else
      if TextLength >= 4 then
      begin
        AStream.Read( W22, 2 );
        if (W21 = $0000) and (W22 = $FFFE) then
          Result := teUTF32BE
        else
        if (W21 = $FEFF) and (W22 = $0000) then
          Result := teUTF32BE
        else
        if Result <> teANSI then  // teUTF16LE or teUTF16BE
          AStream.Seek( 2, soFromBeginning	 );
      end;
    end;
    if Result = teANSI then
      AStream.Seek( 0, soFromBeginning	);
  end;
end; //*** function K_AnalizeStreamBOMBytes

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_EncodeLoginPassword
//*************************************************** K_EncodeLoginPassword ***
// Encode given login and password to single AnsiString
//
//     Parameters
// ALogin    - given Login
// APassword - given Password
// Result    - Returns encoded String
//
function K_EncodeLoginPassword( const ALogin, APassword : string ) : string;
var
  ResStr : WideString;
  Buf : TN_BArray;
  L, LF : Integer;
begin
  Result := '';
  if (ALogin = '') and (APassword = '') then Exit;

  ResStr := N_StringToWide(ALogin + #13#10 + APassword);
  L := Length(ResStr) * SizeOf(WideChar);
  LF := L + SizeOf(Integer) + 1;
  SetLength( Buf, LF );
  Move( ResStr[1], Buf[0], L );
  Buf[High(Buf)] := 1; // Last Byte - Encode Version

  PInteger(@Buf[L])^ := N_AdlerChecksum( @Buf[0], L );

  N_EncryptBytes1( @Buf[0], LF, AnsiString('584_CD32_dat') );

  // Prepare Resultig string
  Result := N_BytesToHexString ( @Buf[0], LF );

end; // function K_EncodeLoginPassword

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_DecodeLogin
//*********************************************************** K_DecodeLogin ***
// Decode login from given encoded login and password single string
//
//     Parameters
// AEncData - given encoded Login and Password string
// Result   - Returns decoded Login string
//
function K_DecodeLogin( const AEncData : string ) : string;
var
  ResStr : WideString;
  Buf : TN_BArray;
  L, LF, CRC : Integer;
begin
  Result := '';
  LF := Length( AEncData ) shr 1;
  if LF = 0 then Exit;
  SetLength( Buf, LF );
  N_HexCharsToBytes( @AEncData[1], @Buf[0], LF );
  N_DecryptBytes1 ( @Buf[0], LF, AnsiString('584_CD32_dat') );
  if Buf[High(Buf)] <> 1 then Exit; // Wrong Encoded Data Format
  L := LF - SizeOf(Integer) - 1;
  CRC := N_AdlerChecksum( @Buf[0], L );
  if PInteger(@Buf[L])^ <> CRC then Exit; // Wrong Encoded Data CRC
  SetLength( ResStr, L shr 1 );
  Move( Buf[0], ResStr[1], L );
  Result := N_WideToString( ResStr );
//  LF := Pos( #13#10, Result );
//  if LF > 0 then
//    SetLength( Result, LF );
end; // function K_DecodeLoginPassword


{*** TK_AMSCObj ***}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_AMSCObj\Create
//******************************************************* TK_AMSCObj.Create ***
// Application Memory State Control Object Constructor
//
constructor TK_AMSCObj.Create;
begin
  N_CheckAllAdd    := AMSCheckObjAdd;    // Add Element to Objects Control List
  N_CheckAllRemove := AMSCheckObjRemove; // Remove Element from Objects Control List
  N_CheckAllExec   := AMSCheckExec;      // Execute all List Elements Check
  N_CheckAllDump   := AMSCheckDump;      // Elements Check Dump
  AMSCObjsList     := TList.Create;
end; // constructor TK_AMSCObj.Create

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_AMSCObj\Destroy
//****************************************************** TK_AMSCObj.Destroy ***
// Application Memory State Control Object Destructor
//
destructor TK_AMSCObj.Destroy;
begin
  N_CheckAllAdd    := nil; // Add Element to Objects Control List
  N_CheckAllRemove := nil; // Remove Element from Objects Control List
  N_CheckAllExec   := nil; // Execute all List Elements Check
  N_CheckAllDump   := nil; // Elements Check Dump
  AMSCObjsList.Free;
  inherited;
end; // destructor TK_AMSCObj.Destroy

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_AMSCObj\AMSCheckDump
//************************************************* TK_AMSCObj.AMSCheckDump ***
// Application Memory State Control Dump
//
//     Parameters
// ADumpStr - dump string
//
procedure TK_AMSCObj.AMSCheckDump( const ADumpStr: string );
begin
  N_LCAdd( 0, ADumpStr );
end; // procedure TK_AMSCObj.AMSCheckDump

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_AMSCObj\AMSCheckExec
//************************************************* TK_AMSCObj.AMSCheckExec ***
// Application Memory State Control Execute
//
//     Parameters
// ACheckID - current check ID
//
procedure TK_AMSCObj.AMSCheckExec( const ACheckID: string );
var
  i : Integer;
  RStr : string;
  ErrFlag : Boolean;
begin
  ErrFlag := FALSE;
  for i := 0 to AMSCObjsList.Count - 1 do begin
    RStr := AMSCObjExecProcs[i]( AMSCObjsList[i], AMSCCheckLevel );
    if RStr = '' then Continue;
    AMSCheckDump( 'AMSC=' + ACheckID + ' Error >> ' + RStr );
    ErrFlag := TRUE;
  end;
  if ErrFlag then
    raise Exception.Create( 'AMSC=' + ACheckID + ' Error was detected' );
end; // procedure TK_AMSCObj.AMSCheckExec

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_AMSCObj\AMSCheckObjAdd
//*********************************************** TK_AMSCObj.AMSCheckObjAdd ***
// Add Object to Application Memory State Control List
//
//     Parameters
// APObj         - pointer to Object which state should be control
// ACheckProcObj - pointer to function of object which should be called for
//                 given object check
//
procedure TK_AMSCObj.AMSCheckObjAdd( APObj: Pointer;
                                     ACheckProcObj: TN_CheckObjExecProcObj );
var
  Ind, Capacity : Integer;
begin
  Ind := AMSCObjsList.Count;
  AMSCObjsList.Add( APObj );
  Capacity := Length( AMSCObjExecProcs );
  if K_NewCapacity( AMSCObjsList.Count, Capacity ) then
    SetLength( AMSCObjExecProcs, Capacity );
//  if Length( AMSCObjExecProcs ) < AMSCObjsList.Count then
//    SetLength( AMSCObjExecProcs, AMSCObjsList.Count );
  AMSCObjExecProcs[Ind] := ACheckProcObj;
end; // procedure TK_AMSCObj.AMSCheckObjAdd

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_AMSCObj\AMSCheckObjRemove
//******************************************** TK_AMSCObj.AMSCheckObjRemove ***
// Remove Object from Application Memory State Control List
//
//     Parameters
// APObj - pointer to Object which state should be control
//
procedure TK_AMSCObj.AMSCheckObjRemove( APObj: Pointer );
var
  Ind : Integer;
begin
  Ind := AMSCObjsList.IndexOf( APObj );
  if Ind < 0 then Exit;
  AMSCObjsList.Delete(Ind);
  if Ind = AMSCObjsList.Count then Exit;
  Move( AMSCObjExecProcs[Ind + 1], AMSCObjExecProcs[Ind],
        (AMSCObjsList.Count - Ind) * SizeOf(TN_CheckObjExecProcObj) );
end;

{*** end of TK_AMSCObj ***}

{*** TK_SelfMemStream ***}


const
  MSMemoryDelta = $2000; { Must be a power of 2 }

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_SelfMemStream\CreateMemStream
//**************************************** TK_SelfMemStream.CreateMemStream ***
// MemoryStream class constructor
//
//     Parameters
// APMem             - pointer to Stream Memory Buffer
// AMemSize          - Stream Memory Buffer size in bytes
// ABufResizeFuncObj - Stream Memory Buffer resize function of object
// APos              - new Stream current position
//
constructor TK_SelfMemStream.CreateMemStream( APMem: Pointer; AMemSize: Integer;
                              ABufResizeFuncObj : TK_MSBufResizeFunc = nil;
                              APos: Longint = 0 );
begin
  inherited Create();
  MSBufResizeFuncObj := ABufResizeFuncObj;
  SetPointer( APMem, AMemSize );
  Seek( APos, soBeginning ); // set Stream Position
end; // constructor TK_SelfMemStream.CreateMemStream

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_SelfMemStream\CreateBArrrayStream
//************************************ TK_SelfMemStream.CreateBArrrayStream ***
// MemoryStream class constructor for external bytes array buffer
//
//     Parameters
// ABArray - external bytes array as Stream Buffer
// APos    - new Stream current position
//
constructor TK_SelfMemStream.CreateBArrrayStream( var ABArray : TN_BArray;
                                                  APos: Longint = 0 );
var
  CSize : Longint;
  PMem : Pointer;
begin

  MSPBArray := @ABArray;
  PMem := nil;

  CSize := Length(MSPBArray^);

  if CSize > 0 then PMem := @MSPBArray^[0];

  if APos > CSize then APos := CSize;

  CreateMemStream( PMem, CSize, MSBArraySetSize, APos );
end; // constructor TK_SelfMemStream.CreateBArrrayStream

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_SelfMemStream\LoadFromStream
//***************************************** TK_SelfMemStream.LoadFromStream ***
// Load the entire contents of a given stream into the stream memory buffer
//
//     Parameters
// AStream - given stream to load
//
// Use LoadFromStream to fill the memory stream with the contents of the stream 
// specified by the Stream parameter. LoadFromStream always sets the Position of
// the source stream to 0, before streaming in the number of bytes indicated by 
// the source stream’s Size property.
//
// LoadFromStream reallocates the memory buffer so that the contents of the 
// source stream will exactly fit. It sets the Size property accordingly, and 
// then reads the entire contents of the source stream into the memory buffer. 
// Thus, LoadFromStream will discard any pre-existing data stored in the memory 
// stream.
//
// If the source stream is a TFileStream object, LoadFromStream does the same 
// thing as LoadFromFile, except that the application must create and free the 
// TFileStream object. LoadFromStream also allows applications to fill a memory 
// stream object from other types of stream objects.
//
procedure TK_SelfMemStream.LoadFromStream( AStream: TStream );
var
  Count: Longint;
begin
  AStream.Position := 0;
  Count := AStream.Size;
  SetSize(Count);
  if Count <> 0 then AStream.ReadBuffer( Memory^, Count );
end; // procedure TK_SelfMemStream.LoadFromStream

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_SelfMemStream\LoadFromFile
//******************************************* TK_SelfMemStream.LoadFromFile ***
// Load the entire contents of a given file into the Stream memory buffer
//
//     Parameters
// AFileName - given file name
//
// Use LoadFromFile to fill the memory stream with the contents of a file. Pass 
// the name of the file as the FileName parameter. LoadFromFile allows an 
// application to read the contents of a file into the memory stream without 
// having to explicitly create and free a file stream object.
//
// LoadFromFile reallocates the memory buffer so that the contents of the file 
// will exactly fit. It sets the Size property accordingly, and then reads the 
// entire contents of the file into the memory buffer. Thus, LoadFromFile will 
// discard any pre-existing data stored in the memory stream.
//
procedure TK_SelfMemStream.LoadFromFile( const AFileName: string );
var
  Stream: TStream;
begin
  Stream := TFileStream.Create( AFileName, fmOpenRead or fmShareDenyWrite );
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end; // procedure TK_SelfMemStream.LoadFromFile

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_SelfMemStream\MSBArraySetSize
//**************************************** TK_SelfMemStream.MSBArraySetSize ***
// Set Bytes Array Stream needed size Routine
//
//     Parameters
// ANewSize - Bytes Array Stream needed size
// Result   - Returns pointer to Stream memory buffer start byte
//
function TK_SelfMemStream.MSBArraySetSize( ANewSize: Longint ): Pointer;
var
  NewCapacity : Longint;
begin

  if (MSPBArray) = nil then raise EStreamError.Create( 'TK_SelfMemStream set size for absent BArray' );
  NewCapacity := ANewSize;
  if (NewCapacity > 0) and (NewCapacity <> Size) then
    NewCapacity:= (NewCapacity + (MSMemoryDelta - 1)) and not (MSMemoryDelta - 1);
  if NewCapacity > Length(MSPBArray^) then SetLength( MSPBArray^, NewCapacity );
  Result := nil;
  if Length(MSPBArray^) > 0 then Result := @MSPBArray^[0];
end; // function TK_SelfMemStream.MSBArraySetSize

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_SelfMemStream\SetSize
//************************************************ TK_SelfMemStream.SetSize ***
// Set MemoryStream needed size
//
//     Parameters
// ANewSize - Bytes Array Stream needed size
//
procedure TK_SelfMemStream.SetSize( ANewSize: Longint );
var
  OldPos : Longint;
  PNewMem : Pointer;
begin
  OldPos := Longint(Position);
  if ANewSize <= Size then
    PNewMem := Memory
  else if Assigned(MSBufResizeFuncObj) then
    PNewMem := MSBufResizeFuncObj( ANewSize )
  else
    raise EStreamError.Create( 'TK_SelfMemStream buffer could not be resized' );
  SetPointer( PNewMem, ANewSize );
  if OldPos <= ANewSize then Exit;
  Seek( ANewSize, soBeginning );
end; // procedure TK_SelfMemStream.SetSize

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_SelfMemStream\Write
//************************************************** TK_SelfMemStream.Write ***
// Write bytes from Buffer to the current stream position
//
//     Parameters
// ABuffer - writing data
// ACount  - writing data count
// Result  - Returns actually writen bytes count.
//
// Writes Count bytes from Buffer to the current position in the memory buffer 
// and updates the current position by Count bytes.
//
// Use Write to insert Count bytes into the memory buffer of the memory stream, 
// starting at the current position. Write will increase the size of the memory 
// buffer, if necessary, to accommodate the data being written in. If the 
// current position is not the end of the memory buffer, Write will overwrite 
// the data following the current position.
//
// Write updates the Size property to Position + Count, and sets the Position 
// property to the new value of Size. Thus, any data that was stored in the 
// memory stream in the Count bytes after the current position is lost when 
// calling Write.
//
// Write always writes the Count bytes in the Buffer, unless there is a memory 
// failure. Thus, for TK_SelfMemStream, Write is equivalent to the WriteBuffer 
// method. All other data-writing methods of a memory stream (WriteBuffer, 
// WriteComponent) call Write to do the actual writing.
//
function TK_SelfMemStream.Write( const ABuffer; ACount: Longint ): Longint;
var
  NewPos, PrevPos: Longint;
begin
  PrevPos := Position;
  if (PrevPos >= 0) and (ACount >= 0) then begin
    NewPos := PrevPos + ACount;
    if NewPos > 0 then  begin
      if NewPos > Size then
        SetSize( NewPos );
      Move( ABuffer, Pointer(Longint(Memory) + PrevPos)^, ACount );
      Seek( NewPos, soBeginning);
      Result := ACount;
      Exit;
    end;
  end;
  Result := 0;
end; // function TK_SelfMemStream.Write

{*** end of TK_SelfMemStream ***}

{*** TK_FormCloseTimer ***}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_FormCloseTimer\CreateByForm
//****************************************** TK_FormCloseTimer.CreateByForm ***
// Form Close Timer Constructor
//
//     Parameters
// AFCTFormToClose - form to close
// AInterval       - form show interval
// Result          - Form Close Timer Object
//
constructor TK_FormCloseTimer.CreateByForm( AFCTFormToClose : TForm; AInterval : Integer );
begin
//111  Inherited Create( nil );
  Inherited Create( AFCTFormToClose );

  Enabled := TRUE;
  Interval := AInterval;
  FCTFormToClose := AFCTFormToClose;
  OnTimer := OnTimerProc;
end; // end of constructor TK_FormCloseTimer.CreateByForm

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_FormCloseTimer\OnTimerProc
//******************************************* TK_FormCloseTimer.OnTimerProc ***
// Form Close Timer OnTimer event handler
//
//     Parameters
// Sender - Self object
//
procedure TK_FormCloseTimer.OnTimerProc(Sender: TObject);
begin
  Enabled := FALSE;
  if FCTFormToClose <> nil then
    FCTFormToClose.Close;
end; // procedure TK_FormCloseTimer.OnTimerProc

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_FormCloseTimer\OnTimerFormDeactivate
//********************************* TK_FormCloseTimer.OnTimerFormDeactivate ***
// Form Deactivate event handler
//
//     Parameters
// Sender - Self object
//
procedure TK_FormCloseTimer.OnTimerFormDeactivate(Sender: TObject);
begin
  Enabled := FALSE;
  if FCTFormToClose = nil then Exit; // precaution
  if Sender is TButton then
    FCTFormToClose.ModalResult := TButton(Sender).ModalResult;
  FCTFormToClose.Close;
end; // procedure TK_FormCloseTimer.OnTimerFormDeactivate

//##path K_Delphi\SF\K_clib\K_CLib0.pas\TK_FormCloseTimer\OnTimerFormCloseQuery
//********************************* TK_FormCloseTimer.OnTimerFormCloseQuery ***
// Form Close Query event handler
//
//     Parameters
// Sender - Self object
//
procedure TK_FormCloseTimer.OnTimerFormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Enabled := FALSE;
  if Assigned( FCTOnFormCloseProc ) then FCTOnFormCloseProc();
  FCTFormToClose.OnDeactivate := nil; // precaution
//111  Self.Free();
  FCTFormToClose.Release;
  FCTFormToClose := nil;
end; // procedure TK_FormCloseTimer.OnTimerFormCloseQuery

{*** end of TK_FormCloseTimer ***}


var K_ComprPrefix: Array [0..4] of DWORD = ($FFFFFFFF, $00000000, $FFFFFFFF,
                                            $5A4C6962, 0 ); // 'ZLib', Size
const K_ComprPrefixSize = SizeOf(K_ComprPrefix);

//******************************************************** K_CompressStream ***
// Compress given Stream
//
//     Parameters
// ASrcStream  - source stream with uncompressed data
// ADstStream  - destination stream for compressed data
// AComprLevel - compression level:
//#F
//     0 - no compression,
//     1 - fast compression,
//     2 - middle compression,
//     3 - maximal compression
//#/F
// ASrcDataSize - source stream data size
// Result      - Returns resulting Compressed Data length in bytes or -1 on
//               compression error
//
function K_CompressStream( ASrcStream, ADstStream : TStream;
                           AComprLevel: Integer; ASrcDataSize : Integer = 0 ): Integer;
var
  ZStream: TCompressionStream;
begin
  Result := -1;
  ZStream := nil;
  try
    if ASrcDataSize = 0 then
      ASrcDataSize := ASrcStream.Size;
    ADstStream.Position := 0;
    ADstStream.Write( K_ComprPrefix[0], K_ComprPrefixSize-4 );
    ADstStream.Write( ASrcDataSize, 4 );
    ZStream := TCompressionStream.Create( TCompressionLevel(AComprLevel), ADstStream );
    ZStream.CopyFrom( ASrcStream, ASrcDataSize );
    Result := ADstStream.Size;
  except
  end;
  ZStream.Free;

end; // function K_CompressStream

//*************************************************** K_GetUncompressedSize ***
// Get Compressed Data uncompressed size
//
//     Parameters
// ASrcStream - source stream with compressed data
// Result     - Returns uncompressed data size or -1 if given stream does not
//              contain data compressed by K_CompressStream
//
function K_GetUncompressedSize( ASrcStream : TStream ): integer;
var
  PrefixSize : Integer;
  Buffer : array [0..K_ComprPrefixSize-1] of byte;
begin
  Result := -1;
  ASrcStream.Seek(0,soFromBeginning);
  PrefixSize := ASrcStream.Read( Buffer[0], K_ComprPrefixSize );
  if PrefixSize < K_ComprPrefixSize then Exit;
  if not CompareMem( @Buffer[0], @K_ComprPrefix[0], K_ComprPrefixSize-4 ) then Exit;
  Result := PInteger(TN_BytesPtr(@Buffer[0]) + K_ComprPrefixSize - 4)^;
end; // function K_GetUncompressedSize

//****************************************************** K_DecompressStream ***
// Decompress given Stream Data and return Data Size of resulting Decompressed Data
//
//     Parameters
// ASrcStream  - source stream with compressed data
// ADstStream  - destination stream for uncompressed data
// Result      - Returns uncompressed data size, -1 if given data was not
//               compressed by K_CompressStream, -2 if Decompress error
//
function K_DecompressStream( ASrcStream, ADstStream : TStream ): integer;
var
  ZStream: TDecompressionStream;

begin
  Result := K_GetUncompressedSize( ASrcStream  );
  if (Result = -1)  then Exit; // Error
  ZStream := nil;
  try
    ASrcStream.Position := K_ComprPrefixSize;
    ZStream := TDecompressionStream.Create( ASrcStream );
    ADstStream.CopyFrom( ZStream, Result );
  except
    Result := -2;
  end;
  ZStream.Free;
end; // function K_DecompressStream

//*********************************************************** K_ScanInteger ***
// Scan one integer value from given string
//
//     Parameters
// AStr   - on input - source string with integer, on output - rest of the input
//          string without scaned integer
// Result - Return scaned integer value or -1234567890 if no integer value was 
//          found.
//
function K_ScanInteger( var AStr: string ): integer;
var
  SpacePos: integer;
  Code: integer;
begin
  Result := N_NotAnInteger;
//  AStr := TrimLeft( AStr );
  SpacePos := 1;
  while (SpacePos <= Length(AStr)) and (AStr[SpacePos] = ' ') do Inc( SpacePos );
  if SpacePos >= Length(AStr) then Exit;

  Code := integer(Char(AStr[SpacePos]));
  if Code > $39 then Exit;
  if Code < $30 then
    if (Code <> $24) and (Code <> $2b) and (Code <> $2d) then Exit;

  SpacePos := PosEx( ' ', AStr, SpacePos );
  if SpacePos = 0 then
  begin
    Result := StrToInt( AStr );
    AStr := '';
  end
  else
  begin
    AStr[SpacePos] := #0;
    Result := StrToInt( AStr );
    Move( AStr[SpacePos+1], AStr[1], Length(AStr) - SpacePos );
    SetLength(AStr, Length(AStr) - SpacePos );
  end;

end; // end of function K_ScanInteger

//************************************************************* K_ScanFloat ***
// Scan one float value from given string
//
//     Parameters
// AStr   - on input - source string with float, on output - rest of the input 
//          string without scaned float
// Result - Return scaned float value or -144115188075855872 if no float value 
//          was found.
//
// Trim left spaces.
//
function K_ScanFloat( var AStr: string ): Float;
var
  SpacePos, CommaPos, RetCode: integer;
begin
  Result := N_NotAFloat;
  SpacePos := 1;
  while (SpacePos <= Length(AStr)) and (AStr[SpacePos] = ' ') do Inc( SpacePos );
  if SpacePos >= Length(AStr) then Exit;

  CommaPos := Pos( ',', AStr );
  if CommaPos > 0 then AStr[CommaPos] := '.';

  SpacePos := PosEx( ' ', AStr, SpacePos );
  if SpacePos = 0 then
  begin
    Val( AStr, Result, RetCode );
    AStr := '';
  end else
  begin
    AStr[SpacePos] := #0;
    Val( AStr, Result, RetCode );
    Move( AStr[SpacePos+1], AStr[1], Length(AStr) - SpacePos );
    SetLength(AStr, Length(AStr) - SpacePos );
  end;
end; // end of function K_ScanFloat

//************************************************************ K_ScanDouble ***
// Scan one double value from given string
//
//     Parameters
// AStr   - on input - source string with double, on output - rest of the input 
//          string without scaned double
// Result - Return scaned double value or -12345678901234e+4 if no double value 
//          was found.
//
// Trim left spaces.
//
function K_ScanDouble( var AStr: string ): double;
var
  SpacePos, CommaPos, RetCode: integer;
begin
  Result := N_NotADouble;
  SpacePos := 1;
  while (SpacePos <= Length(AStr)) and (AStr[SpacePos] = ' ') do Inc( SpacePos );
  if SpacePos >= Length(AStr) then Exit;

  CommaPos := Pos( ',', AStr );
  if CommaPos > 0 then AStr[CommaPos] := '.';

  SpacePos := PosEx( ' ', AStr, SpacePos );
  if SpacePos = 0 then
  begin
    Val( AStr, Result, RetCode );
    AStr := '';
  end else
  begin
    AStr[SpacePos] := #0;
    Val( AStr, Result, RetCode );
    Move( AStr[SpacePos+1], AStr[1], Length(AStr) - SpacePos );
    SetLength(AStr, Length(AStr) - SpacePos );
  end;
end; // end of function K_ScanDouble

//************************************************************* K_ScanToken ***
// Scan one token from given string
//
//     Parameters
// AStr   - on input - source string with token, on output - rest of the input 
//          string without scaned token
// Result - Return scaned token or empty string if no token was found.
//
// Trim left spaces. Token should be separated with space chars or double quote 
// char.
//
function K_ScanToken( var AStr: string ): string;
var
  DelimPos,StartPos: integer;
begin
  StartPos := Pos( ' ', AStr );
  if StartPos = Length(AStr) then
  begin
    Result := '';
    Exit;
  end;

  if AStr[StartPos] = '"' then // quoted string
  begin
    Inc(StartPos);
    DelimPos := PosEx( '"', AStr, StartPos );
  end else // space delimited string
    DelimPos := Pos( ' ', AStr );

  if DelimPos = 0 then // no final delimiter
  begin
    Result := AStr;
    AStr := '';
  end else
  begin
    Result := Copy( AStr, StartPos, DelimPos - StartPos );
    StartPos := Length(AStr) - DelimPos;
    if StartPos > 0 then
      Move( AStr[DelimPos + 1], AStr[1], StartPos );
    SetLength(AStr, StartPos );
  end;
end; // end of function K_ScanToken

//************************************************** K_ChangeIntValByStrVal ***
// Change Integer Value by String Value
//
//     Parameters
// AIntVal - Integer Value to change
// AStrVal - new Integer Value in string format
// Result  - Returns String Value corresponding with new Integer Value
//
function K_ChangeIntValByStrVal( var AIntVal : Integer; const AStrVal : string ) : string;
var
  WInt : Integer;
begin
  if Trim(AStrVal) = '' then
  begin // String Value was changed to empty value
    AIntVal := 0;
    Result := '';
  end
  else
  begin // String Value was changed to not empty value
    WInt := StrToIntDef( Trim(AStrVal), -1 );
    if WInt >= 0 then
      AIntVal := WInt;   // set new value

//    if AIntVal = 0 then
//      Result := ''
//    else
      Result := IntToStr(AIntVal);
  end;
end; // function K_ChangeIntValByStrVal

//************************************************ K_ChangeFloatValByStrVal ***
// Change Float Value by String Value
//
//     Parameters
// AFloatVal - Float Value to change
// AStrVal   - new Float Value in string format
// Result    - Returns String Value corresponding with new Float Value
//
function K_ChangeFloatValByStrVal( var AFloatVal : Double; const AStrVal : string ) : string;
var
  WD : Double;
begin
  if Trim(AStrVal) = '' then
  begin // String Value was changed to empty value
    AFloatVal := 0;
    Result := '';
  end
  else
  begin // String Value was changed to not empty value
    WD := StrToFloatDef( Trim(AStrVal), NAN );
    if not IsNan(WD) then
      AFloatVal := WD;   // set new value

//    if AFloatVal = 0 then
//      Result := ''
//    else
      Result := format( '%g', [AFloatVal] );
  end;
end; // function K_ChangeFloatValByStrVal

//*********************************************** K_SaveTextToStreamWithBOM ***
// Save text to stream with BOM
//
//     Parameters
// Text    - saving text
// AStream - stream
// Result - Returns TRUE if success
//
function K_SaveTextToStreamWithBOM( const AText: string; AStream: TStream ) : Integer;
var
  TextLength : Integer;
  W2 : word; // UnicodeSignature
  WideBufStr : WideString;
  AnsiBufStr : AnsiString;
  DataSize : Integer;
begin
  AnsiBufStr := ''; // to avoid warning in Delhi 7
  WideBufStr := ''; // to avoid warning in Delhi 2010

  TextLength := Length(AText);
  DataSize := TextLength;
  if DataSize > 0 then
  begin
    W2 := $FEFF; // UnicodeSignature
    if SizeOf( Char ) = 2 then
    begin // String is Wide
      if not K_SaveTextAsAnsi then
      begin // Wide to Wide
        AStream.Write( W2, 2 );
        AStream.Write( AText[1], TextLength * 2 );
        DataSize := 2 + DataSize * 2;
      end
      else
      begin                     // Wide to Ansi
  //      AnsiBufStr := AnsiString(Text);
        AnsiBufStr := N_StringToAnsi(AText);
        AStream.Write( AnsiBufStr[1], TextLength )
      end;
    end // if SizeOf( Char ) = 2 then
    else
    begin // String is Ansi
      if not K_SaveTextAsAnsi then
      begin // Ansi to Wide
  //      WideBufStr := Text;
        AStream.Write( W2, 2 );
        WideBufStr := N_StringToWide( AText );
        AStream.Write( WideBufStr[1], TextLength * 2 );
        DataSize := 2 + DataSize * 2;
      end
      else
      begin                     // Ansi to Ansi
        AStream.Write( AText[1], TextLength )
      end;
    end; // String is Ansi
  end; // if DataSize > 0 then
  Result := DataSize;
end; //*** end of K_SaveTextToStreamWithBOM

//********************************************* K_LoadTextFromStreamWithBOM ***
// Load text from stream skip BOM
//
//     Parameters
// AText   - loading text
// AStream - stream
// Result  - Returns true if text is successfully read
//
function  K_LoadTextFromStreamWithBOM( var AText: string; AStream : TStream ): Boolean;
var
  TextLength : Integer;
  TextLength1 : Integer;
//  UnicodeText : Boolean;
//  UTF8Text : Boolean;
  W4 : LongWord; // UnicodeSignature
  WideBufStr : WideString;
  AnsiBufStr : AnsiString;
  TextEncoding : TN_TextEncoding;

Label LEmpty;

  procedure UTF16BE_To_UTF16LE( PB : TN_BytesPtr );
  var
    i : Integer;
  begin
    for i := 0 to (TextLength shr 1) - 1 do
    begin
      W4 := Byte(PB^);
      PB^ := (PB + 1)^;
      Byte((PB + 1)^) := W4;
      Inc(PB,2);
    end;
  end;

begin
  Result := TRUE;
  AnsiBufStr := ''; // to avoid warning in Delhi 7
  WideBufStr := ''; // to avoid warning in Delhi 2010
  TextLength := AStream.Size;

  if TextLength = 0 then
  begin
LEmpty:
    AText := '';
    Exit;
  end;

  TextEncoding := K_AnalizeStreamBOMBytes( AStream );
  if TextEncoding = teANSI then
  begin
    if SizeOf( Char ) = 2 then
    begin // Ansi to Wide
      SetLength( AnsiBufStr, TextLength );
      AStream.Read( AnsiBufStr[1], TextLength );
      AText := N_AnsiToString( AnsiBufStr );
    end
    else
    begin  // Ansi to Ansi
      SetLength( AText, TextLength );
      AStream.Read( AText[1], TextLength );
    end;
  end
  else
  if TextEncoding = teUTF8 then
  begin
    TextLength := TextLength - 3;
    if TextLength = 0 then goto LEmpty;
    SetLength( AnsiBufStr, TextLength );
    AStream.Read( AnsiBufStr[1], TextLength );
    if SizeOf( Char ) = 2 then
    begin // UTF8 to Wide
      SetLength( AText, TextLength );
      TextLength1 := Utf8ToUnicode( PWideChar(@AText[1]), TextLength, @AnsiBufStr[1], TextLength );
      SetLength( AText, TextLength1 );
    end
    else
    begin  // UTF8 to Ansi
      SetLength( WideBufStr, TextLength );
      TextLength1 := Utf8ToUnicode( @WideBufStr[1], TextLength, @AnsiBufStr[1], TextLength );
      SetLength( WideBufStr, TextLength1 );
      AText := N_WideToString( WideBufStr );
    end;
  end
  else
  if TextEncoding = teUTF16LE then
  begin
  // File contains Wide Chars
    TextLength := TextLength - 2;
    if TextLength = 0 then goto LEmpty;
    if SizeOf( Char ) = 2 then
    begin // Wide to Wide
      SetLength( AText, TextLength shr 1 ); // NumChars = NumBytes div 2
      AStream.Read( AText[1], TextLength );
    end
    else
    begin  // Wide to Ansi
      SetLength( WideBufStr, TextLength shr 1 );
      AStream.Read( WideBufStr[1], TextLength );
      AText := N_WideToString( WideBufStr );
    end;
  end
  else
  if TextEncoding = teUTF16BE then
  begin
    TextLength := TextLength - 2;
    if SizeOf( Char ) = 2 then
    begin // Wide to Wide
      SetLength( AText, TextLength shr 1 ); // NumChars = NumBytes div 2
      AStream.Read( AText[1], TextLength );
      UTF16BE_To_UTF16LE( TN_BytesPtr(@AText[1]) );
    end
    else
    begin  // Wide to Ansi
      SetLength( WideBufStr, TextLength shr 1 );
      AStream.Read( WideBufStr[1], TextLength );
      UTF16BE_To_UTF16LE( TN_BytesPtr(@WideBufStr[1]) );
      AText := N_WideToString( WideBufStr );
    end;
  end
  else
    Result := FALSE;
end; //*** end of K_LoadTextFromStreamWithBOM

{ TK_DumpObj }

//******************************************************* TK_DumpObj.Create ***
// Dump object constructor
//
constructor TK_DumpObj.Create( const ADumpFName: string; const ADumpPref : string = '' );
begin
  DLogPref  := ADumpPref;
  DLogFname := ADumpFName;
  DLogBufSL := TStringList.Create;
end; // constructor TK_DumpObj.Create

//******************************************************* TK_DumpObj.Create ***
// Dump object destructor
//
destructor TK_DumpObj.Destroy;
begin
  DLogBufSL.Free;
  inherited;
end; // destructor TK_DumpObj.Destroy

//***************************************************** TK_DumpObj.DumpStr0 ***
// Dump string to file without timestamp and line index
//
//     Parameters
// ADumpStr - dump info
//
procedure TK_DumpObj.DumpStr0( ADumpStr: string );
var
  F: TextFile;
  BufStr : string;
begin
  if DLogFname = '' then Exit;
  try
    DLogBufSL.Add( DlogPref + ADumpStr );
    Assign( F, DLogFname );
    if not FileExists( DLogFname ) then
      Rewrite( F )
    else
      Append( F );

    Inc(DLogDInd);
    BufStr := DLogBufSL.Text;
    WriteLn( F, Copy( BufStr, 1, Length(BufStr) - 2 ) );
    DLogBufSL.Clear;
    Flush( F );
  finally
    Close( F );
  end;
end; // procedure TK_DumpObj.DumpStr0

//****************************************************** TK_DumpObj.DumpStr ***
// Dump string to file with timestamp and line index
//
//     Parameters
// ADumpStr - dump info
//
procedure TK_DumpObj.DumpStr( ADumpStr: string );
begin
  DumpStr0( format( '%.3d> %s %s', [DLogDInd,
                        FormatDateTime( 'dd-hh":"nn":"ss.zzz', Now() ), ADumpStr] ) );
end; // procedure TK_DumpObj.DumpStr

{ end of TK_DumpObj }

{ TK_RedrawDelayObj }

//************************************************ TK_RedrawDelayObj.Create ***
// Redraw object constructor
//
constructor TK_RedrawDelayObj.Create(AOnRedrawProcObj: TK_NotifyProc = nil);
begin
  OnRedrawProcObj := AOnRedrawProcObj;
  RedrawTimer := TTimer.Create(nil);
  InitCheckAttrsDef();
  RedrawTimer.Interval := TimerInterval;
  RedrawTimer.OnTimer  := OnTimer;
  RedrawTimer.Enabled  := FALSE;
  OnCheckDirectRedraw := MouseUpCheck;
end; // constructor TK_RedrawDelayObj.Create

//******************************************** TK_RedrawDelayObj.destructor ***
// Redraw object constructor
//
destructor TK_RedrawDelayObj.Destroy;
begin
  RedrawTimer.Free();
  inherited;
end; // destructor TK_RedrawDelayObj.Destroy

//************************************* TK_RedrawDelayObj.InitCheckAttrsDef ***
// Initiate default Redraw time attibutes
//
procedure TK_RedrawDelayObj.InitCheckAttrsDef;
begin
  RedrawRequestBound := 3;
  TimerInterval := 100;
  WaitCountBound1 := 5;
  WaitCountBound2 := 3;
end; // procedure TK_RedrawDelayObj.InitCheckAttrsDef


//********************************** TK_RedrawDelayObj.InitCheckAttrsByTime ***
// Initiate Redraw time attibutes
//
//     Parameters
// ATimeSec - check mouse move delay in seconds
// ASpeedChangeFactor - mouse speed change factor
//
procedure TK_RedrawDelayObj.InitCheckAttrsByTime( ATimeSec : Double; ASpeedChangeFactor : Double = 0 );
var
  IMSCount : Integer;
begin
  InitCheckAttrsDef();

  IMSCount := Round( ATimeSec * 1000 / (WaitCountBound1 - WaitCountBound2) );

  if IMSCount < TimerInterval then Exit;

  if (ASpeedChangeFactor = 0) or
     (IMSCount = TimerInterval) then
    ASpeedChangeFactor := 1;

  RedrawRequestBound := Round( ASpeedChangeFactor * RedrawRequestBound * IMSCount / TimerInterval );
  TimerInterval := IMSCount;

end; // procedure TK_RedrawDelayObj.InitCheckAttrsByTime

//******************************************** TK_RedrawDelayObj.InitRedraw ***
// Initiate Redraw object
//
//     Parameters
// AOnRedrawProcObj - Redraw procedure of object
//
procedure TK_RedrawDelayObj.InitRedraw( AOnRedrawProcObj: TK_NotifyProc;
                                   ADirectlyRedrawCheckFuncObj : TK_FuncObjBool = nil );
begin
  OnRedrawProcObj := AOnRedrawProcObj;
  if Assigned(ADirectlyRedrawCheckFuncObj) then
    OnCheckDirectRedraw := ADirectlyRedrawCheckFuncObj;
  RedrawRequestCount := 0;
  WaitCount := 0;
  RedrawTimer.Enabled  := FALSE;
  RedrawTimer.Interval := TimerInterval;
end; // procedure TK_RedrawDelayObj.InitRedraw

//*********************************************** TK_RedrawDelayObj.OnTimer ***
// Timer event handler
//
//     Parameters
// Sender - event sending object
//
procedure TK_RedrawDelayObj.OnTimer(Sender: TObject);
begin
  RedrawTimer.Enabled  := FALSE;
  RedrawTimer.Interval := TimerInterval;
  if not Assigned(OnRedrawProcObj) then Exit; // precation

  Inc(WaitCount);
  if (RedrawRequestCount = 0) or // direct redraw is detected early in Redraw method
      OnCheckDirectRedraw()   or // direct redraw is detected now in OnCheckDirectRedraw
      // if mouse move check speed delay expired and
      //    number of Redraw calls is small enough
      ((WaitCount >= WaitCountBound1) and (RedrawRequestCount < RedrawRequestBound)) then
  begin
////////////////
// Redraw case
    OnRedrawProcObj();       // Redraw
    // new mouse move check speed delay start
    RedrawRequestCount := 0; // Clear RedrawReqest counter
    WaitCount := 0;          // Clear Wait counter - set Wait counter to initial state
    Exit;
// Redraw case
////////////////
  end
  else
///////////////////
// Skip Redraw case
  begin
    // Stop Redraw Timer if mouse is not mooved during the 1-st tick (no RedrawRequests in the 1-st tick from the begin of Check mouse speed delay)
    RedrawTimer.Enabled := RedrawRequestCount > 0;
    if not RedrawTimer.Enabled then
    begin
      WaitCount := 0; // Clear Wait counter - set Wait counter to initial state
      Exit;
    end;

    // if check speed delay is not fin then Exit
    if WaitCount < WaitCountBound1 then Exit;

    // Check mouse speed delay is finished and mouse is continue mooving:
    // Set Integration params for not 1-st integration delay
    // WaitCount := WaitCountBound2 - initial state for not 1-st integration delay
    // RedrawRequestCount := intial value for previouse WaitCountBound2 ticks. Set average mouse RedrawRequest counter for WaitCountBound2 ticks of whole delay (WaitCountBound1 ticks) but not more then 2 minimal RedrawRequest counters.
    RedrawRequestCount := Min( Round( WaitCountBound2 * RedrawRequestCount/WaitCount ), 2*RedrawRequestBound );
    WaitCount := WaitCountBound2;
// Skip Redraw case
///////////////////
  end;

end; // procedure TK_RedrawDelayObj.OnTimer

//************************************************ TK_RedrawDelayObj.Redraw ***
// Redraw request routine
//
procedure TK_RedrawDelayObj.Redraw;
begin
  Inc(RedrawRequestCount);
  if OnCheckDirectRedraw()  then
  begin
    RedrawRequestCount := 0;    // Unconditional Redraw Flag
    RedrawTimer.Interval := 1;
    RedrawTimer.Enabled  := TRUE;
  end
  else
  begin
    if RedrawRequestCount = 1 then
      RedrawTimer.Enabled  := FALSE; // Enabled := FALSE is needed to restart Timer if it is already started

    RedrawTimer.Enabled := TRUE;
  end;
end; // procedure TK_RedrawDelayObj.Redraw

//****************************************** TK_RedrawDelayObj.MouseUpCheck ***
// OnMouseUp unconditional Redraw routine
//
function TK_RedrawDelayObj.MouseUpCheck: Boolean;
begin
  Result := not N_KeyIsDown( VK_LBUTTON );
end; // function TK_RedrawDelayObj.MouseUpCheck

//************************************** TK_RedrawDelayObj.SkipDirectRedraw ***
// Skip unconditional Redraw routine
//
function TK_RedrawDelayObj.SkipDirectRedraw: Boolean;
begin
  Result := FALSE;
end; // function TK_RedrawDelayObj.SkipDirectRedraw

{ end of TK_RedrawDelayObj }


Initialization

  K_AMSCObj := TK_AMSCObj.Create;

Finalization
  K_AMSCObj.Free;;

end.
