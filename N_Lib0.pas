unit N_Lib0;
// general purpose low level definitions and code
//
// Interface section uses only N_Types and Delphi units
// Implementation section uses only K_CLib0 and some Delphi units

interface
uses Windows, Classes, SysUtils, Graphics, ZLib, Forms, Types,
     ComCtrls, StdCtrls, ExtCtrls, Contnrs, Controls, Dialogs,
     N_Types;

//##/*

type TN_DumpGlobObj = class( TObject ) // Global Object for Dumping functions
  procedure GODump1Str  ( AString: string );
  procedure GODump2Str  ( AString: string );
  procedure GODump2TStr ( AType: integer; AString: string );
  procedure GODumpStr   ( ALCInd: integer; AString: string );
end; // type TN_DumpGlobObj = class( TObject )

type TN_MemBlocksInfo = record // Info about Windows Memory Blocks
  MBIMinBigSize:      DWORD; // Minimum Size in bytes of "Big" Memory Blocks
  MBISumFreeSize:     DWORD; // Sum of Sizes in bytes of all Free Memory Blocks
  MBISumBigSize:      DWORD; // Sum of Sizes in bytes of Big Free Memory Blocks
  MBINumFreeBlocks: integer; // Number of Free Memory Blocks
  MBINumBigBlocks:  integer; // Number of Big Free Memory Blocks (>= MBIMinBigSize)
end; // type TN_MemBlocksInfo
type TN_PMemBlocksInfo = ^TN_MemBlocksInfo;

type TN_GSSParams = record // Get sample string params
  GSSPMode:     integer; // bits 0-3 algorithm:
                         //   =0 - one dim index as number
                         //   =1 - one dim index as number and propisyu
                         //   =2 - two dim inds as numbers (ix:iy)
                         //   =3 - two dim inds as numbers and propisyu
                         // bit 4 - set exact random size
  GSSPColInd:   integer; // along X index (index of column)
  GSSPRowInd:   integer; // along Y index (index of row)
  GSSPNumCols:  integer; // number of Columns
  GSSPNumRows:  integer; // number of Rows
  GSSPMinChars: integer; // min number of chars in resulting string
  GSSPMaxChars: integer; // max number of chars in resulting string
end; // type TN_GSSParams
type TN_PGSSParams = ^TN_GSSParams;

function  N_B2S  ( ABoolVal: Boolean ): string;
function  N_S2B  ( AStr: string ): Boolean;
function  N_HexToInt    ( AHexStr: string ): integer ;
function  N_AnyHexToInt ( AHexStr: string ): integer ;

type TN_ObjList = class( TObjectList ) //***** Own Object List
  public
  function  GetIndex ( AClassType: TClass ): integer; virtual;
  function  AddNew   ( AClassType: TClass ): TObject; virtual;
end; // type TN_ObjList = class( TObjectList )

type TN_CPUTimer1 = class( TObject) //***** simple one interval Timer
  public
  BegCounter: Int64;    // start value of CPU Clock Counter
  DeltaCounter: Int64;  // number of CPU Clocks

  procedure Start ();
  procedure Stop  ();
  function  ToStr ( ANTimes: integer = 1 ): string;
  procedure Show  ( Prefix: string; out OutStr: string ); overload;
  procedure Show  ( Prefix: string ); overload;
  procedure SS    ( Prefix: string; out OutStr: string ); overload;
  procedure SS    ( Prefix: string ); overload;
  procedure SSS   ( Prefix: string ); overload;
  procedure SSS   ( Prefix: string; out OutStr: string ); overload;
  function  CurSeconds  (): double;
  function  StopSeconds (): double;
end; // type TN_CPUTimer1 = class( TObject)

type TN_CPUTimer2Data = record //***** Data for Timer with adding intervals
  TimerName: string;    // Timer Name
  NTimes: integer;      // Number of Times Timer was Started (and Stopped)
//  NTimesStart: integer; // Number of calls to Start method (including nexted calls)
  StartLevel: integer;  // Start method nesting Level (StartLevel>=1 means nested calls)
  BegCounter: Int64;    // start value of CPU Clock Counter
  DeltaCounter: Int64;  // number of CPU Clocks
end; // type TN_OneCPUTimer2 = record
type TN_CPUTimers2 = array of TN_CPUTimer2Data;

type TN_CPUTimer2 = class( TObject) //***** array of Timers with adding intervals
  public
  Items: TN_CPUTimers2;
  constructor Create  ( NumTimers: integer );
  destructor  Destroy (); override;
  procedure Clear  ( AMinNumTimers: integer );
  procedure Start  ( TimerInd: integer );
  procedure Start2 ( TimerInd: integer );
  procedure Stop   ( TimerInd: integer );
  procedure StopStart ( var TimerInd: integer );
  procedure Show      ( NumTimers: integer );
end; // type TN_CPUTimer2 = class( TObject)

type TN_CPUTimer3 = class( TObject) //***** complex one interval Timer for measuring
  public // interval using TN_CPUTimer1, GetTickCount, QueryPerformanceCounter and GetProcessTimes
    ShowTimeFmt: string;
    CPUTimer: TN_CPUTimer1;

    BegAbsTime: TDateTime;
    BegTicksCounter: integer;
    BegPerfCounter:    int64;
    BegProcUserTime:   int64;
    BegProcKernelTime: int64;

    AbsTimeInSeconds:        double;
    TicsTimeInSeconds:       double;
    PerfCounterInSeconds:    double;
    CPUClockTimeInSeconds:   double;
    ProcUserTimeInSeconds:   double;
    ProcKernelTimeInSeconds: double;

  constructor Create  ();
  destructor  Destroy (); override;
  procedure Start ();
  procedure Stop  ();
  procedure Show  ( Prefix: string; out OutStr: string ); overload;
  procedure Show  ( Prefix: string ); overload;
  procedure SS    ( Prefix: string; out OutStr: string ); overload;
  procedure SS    ( Prefix: string ); overload;
end; // type TN_CPUTimer3 = class( TObject)
//##*/

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_GivenMemStream
//******************************************************* TN_GivenMemStream ***
// Memory Stream with constant memory buffer size
//
type TN_GivenMemStream = class( TMemoryStream )
  PGivenMem: Pointer;       // pointer to given memory buffer
  GivenMemSize: integer;    // given memory buffer size in bytes

  constructor Create ( APGivenMem: Pointer; AGivenMemSize: integer );
  function Realloc (var ANewCapacity: Longint): Pointer; override;
  procedure SetSize ( ANewSize: Longint ); override;
end; // type TN_GivenMemStream = class( TMemoryStream )

//##/*
type TN_CurLanguage = ( clEnglish, clRussian );

type TN_AlignData = record // Parameters of N_GetAlignDelta function
  AlignMode: integer;
  FreeSpace: integer;
  NumGaps:   integer;
end; // type TN_AlignData = record
//##*/

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_DEQObj
//*************************************************************** TN_DEQObj ***
// Double-Ended Queue Object (DEQ)
//
type TN_DEQObj = class( TObject)
  public
    DEQElems:  TN_BArray; // Queue Elements (Size in bytes is 
                          // DEQNumElemes*DEQElemSize)
    DEQCapacity: integer; // maximal Queue Size in Elements
    DEQCounter:  integer; // current number of Elements in Queue
    DEQElemSize: integer; // one Queue Element Size in bytes
    DEQFirstInd: integer; // index of First Element in Queue (in
                          // 0-(DEQNumElemes-1) range
    DEQLastInd:  integer; // index of Last Element in Queue (in 
                          // 0-(DEQNumElemes-1) range

  constructor Create    ( ANumElemes, AElemSize: integer );
//##/*
  destructor  Destroy   (); override;
//##*/
  function  AddLastElem     (): TN_BytesPtr;
  function  GetFirstPtr     (): TN_BytesPtr;
  function  RemoveFirstElem (): TN_BytesPtr;
end; // type TN_DEQObj = class( TObject)

//##/*
function  N_GetAlignDelta( const AAlignData: TN_AlignData; AGapInd: integer ): integer;
function  N_NewLength ( OldLength: integer; MinLength: integer = 0 ): integer;

//##*/

procedure N_SplitMemToStrings ( AStrings: TStrings; APFirstByte: Pointer;
                                                       ANumBytes: integer );
function  N_AdlerCheckSum   ( APFirstByte: Pointer; ANumBytes: integer ): integer;
function  N_AdlerCheckSumStr       ( const AStr: String ): Integer;
function  N_AdlerCheckSumSubStr    ( const AStr: String; const AFirstInd, ALastInd: Integer ): Integer;
function  N_AdlerCheckSumSubStrLow ( const AStr: String; const AFirstInd, ALastInd: Integer ): Integer;
procedure N_EncryptBytes1 ( APFirstByte: Pointer; ANumBytes: integer; APasWord: AnsiString );
procedure N_DecryptBytes1 ( APFirstByte: Pointer; ANumBytes: integer; APasWord: AnsiString );
procedure N_EncrDecrBytesXOR ( APFirstByte: Pointer; ANumBytes: integer; APasWord: byte );
procedure N_EncryptTwoInts ( const AInpInt1, AInpInt2: integer;
                                        APResBytes: Pointer; APasWord: AnsiString );
function  N_DecryptTwoInts ( out AOutInt1, AOutInt2: integer;
                               APSrcBytes: Pointer; APasWord: AnsiString ): boolean;

function  N_GetPatternIndex ( AStrings: TStrings;
                              APattern: string; ABegInd: integer ): integer;
procedure N_ReplaceSectionInStrings ( ASrcStrings, AResStrings, ASection: TStrings;
                                                         ASectionName: string );
function  N_GetSectionFromStrings ( AStrings, ASection: TStrings;
                          ASectionName: string; ABegInd: integer = 0 ): integer;
procedure N_ReplaceSectionInFile ( AFName: string; ASection: TStrings;
                                   ASectionName: string; APasWord: AnsiString = '' );
procedure N_GetSectionFromFile ( AFName: string; ASection: TStrings;
                                 ASectionName: string; APasWord: AnsiString = '' );

function  N_ConvToGray  ( AColor: integer ): integer;
function  N_FindFileExt( AExtArray: array of string; AFName: string ): integer;
function  N_KeyIsDown   ( AVKey: integer ): boolean;
function  N_GetFileFmtByExt    ( AFName: string ): TN_ImageFileFormat;
function  N_GetFileFmtByHeader ( APHeader: Pointer ): TN_ImageFileFormat;
procedure N_UpdateRFResAndSize ( var ASizePix: TPoint; var ASizemm: TFPoint;
                                                       var AResDPI: TFPoint );
procedure N_PrepImageFilePar   ( APInpIFP, APOutIFP: TN_PImageFilePar );
procedure N_PrepTextFilePar ( APInpTFP, APOutTFP: TN_PTextFilePar );
//procedure N_PrepFile1Params ( APInpFP,  APOutFP:  TN_PFile1Params );

function  N_GetOLEServer   ( AServerName: string; APIsCreated: PBoolean = nil ): Variant;
function  N_CreateCFPArray ( ANumElemes: integer; AFmtFlags: TN_CellFmtFalgs ): TN_CFPArray;
//##/*
function  N_GetIntPropisyu   ( AInt: integer ): string;
function  N_GetSampleRusText ( APrefix: string; ATextInt, ANumChars: integer ): string;
function  N_GetSampleString  ( APParams: TN_PGSSParams ): string;
procedure N_CreateSampleStrMatr ( var AStrMatr: TN_ASArray; APParams: TN_PGSSParams );
procedure N_CreateStrMatrFromPointers ( var AStrMatr: TN_ASArray; APointers: TN_PArray );

function  N_PrepSPLCode      ( ASPLCode: string ): string;
function  N_UseClipboard     ( AFileName: string ): boolean;
//##*/

procedure N_SortPointers ( APtrsArray: TN_PArray; ACompareFunc: TN_CompFuncOfObj ); overload;
function  N_GetPtrsArrayToElems ( APBegElem: Pointer;
                                  AElemCount, AElemSize: integer ): TN_PArray;
procedure N_PtrsArrayToElemInds ( APIndices: PInteger; APtrsArray: TN_PArray;
                                        APBegElem: Pointer; AElemSize: Integer );
function  N_ElemIndsToPtrsArray ( APBegElem: Pointer; AElemSize: Integer;
                                  APIndices: PInteger; ANumInds: Integer ): TN_PArray;
procedure N_BuildSortedElemInds ( APIndices: PInteger; APBegElem: Pointer;
                  AElemCount, AElemSize: integer; ACompareFunc: TN_CompFuncOfObj ); // overload;
//procedure N_BuildSortedElemInds ( PIndices: PInteger; PtrsArray: TN_PArray; PBegElem: Pointer;
//                  ElemCount, ElemSize: integer; CompareFunc: TN_CompFuncOfObj ); overload
procedure N_SortArrayOfElems ( APBegElem: Pointer; AElemCount, AElemSize: integer;
                               ACompareFunc: TN_CompFuncOfObj );

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompFuncsObj
//********************************************************* TN_CompFuncsObj ***
// Compare Functions of Object and theirs params
//
// (for using in N_SortPointers)
//
type TN_CompFuncsObj = class( TObject )
  public
  DescOrder: boolean; // descending order flag (=TRUE if should be sorted in 
                      // descending order)
  Offset: integer;    // offset in bytes from given Pointer to compared field
  NumFields:integer;  // number of fields to compare
  CFOIArray: TN_IArray; // Array of integers (can be used as parameter for 
                        // sorting algorithm)

  function CompOneInt    ( APtr1, APtr2: Pointer ): integer;
  function CompOneUInt   ( APtr1, APtr2: Pointer ): integer;
  function CompOneDouble ( APtr1, APtr2: Pointer ): integer;
  function CompNInts     ( APtr1, APtr2: Pointer ): integer;
  function CompNUInts    ( APtr1, APtr2: Pointer ): integer;
  function CompOneByte   ( APtr1, APtr2: Pointer ): integer;
  function CompOneStr    ( APtr1, APtr2: Pointer ): integer;
  function CompSArray    ( APtr1, APtr2: Pointer ): integer;
end; // type TN_CompFuncsObj = class( TObject )

//************************************************************** TN_DIBInfo ***
// Device Independent Bitmap Info
//
// Used for DIB Sections and DIB Bitmaps
//
type TN_DIBInfo = packed record //***** used for DIB Sections and DIB Bitmaps
  bmi: TBitmapInfoHeader; // Pascal Bitmap Header Info
  case integer of
  0: (
    RedMask:   integer;    // $FF0000 or $00F800
    GreenMask: integer;    // $00FF00 or $0007E0
    BlueMask:  integer; ); // $0000FF or $00001F
  1: (
    PalEntry0: integer;    // Color for zero bits in monochrome raster
    PalEntry1: integer; ); // Color for nonzero bits in monochrome raster
  2: ( PalEntries: array [0..255] of integer; );
end; // type TN_DIBInfo = packed record
type TN_PDIBInfo = ^TN_DIBInfo;

//##/*
type TN_GlobObj = class( TObject ) // Global Object (with minimal needed Units)
  public
  GOGifTranspColor:    integer;  // set in N_CreateBMPObjFromFile
  GOGifTranspColorInd: integer;  // set in N_CreateBMPObjFromFile
  GOPathFlags: TN_UObjPathFlags; // Path Flags used for Showing Paths to UObjects
  GOStatusBar1:      TStatusBar; // used in GOShow1Str
  GOStatusBar2:      TStatusBar; // used in GOShow1Str
  GOSavedCPUCounter1:     Int64; // used in GOGetCurTimeStr
  GOUTCHourseShift:     Integer; // difference between UTS and local Time in Hourse, used in GOGetCurTimeStr
  GOSavedTime1:         Integer; //
  GOSavedTime1Str:       String; //

  constructor Create ();
  destructor  Destroy; override;
  procedure TerminateSelf   ();
  procedure GOEmptyDumpStr  ( AStr: string );
  procedure GOEmptyDumpTStr ( AType: integer; AStr: string );

  procedure GODump1Str ( AStr: string );
  procedure GODump2Str ( AStr: string );

  procedure GOShow1Str ( AStr: string );
  function  GOGetCurTimeStr (): string;

end; // type TN_GlobObj = class( TObject )

function  N_ConvIntsToStr ( APFirstInt: PInteger; ANumInts: integer; ADelimetr: string ): string;
function  N_ConvSmallIntsToStr( APFirstInt: TN_PInt2; ANumInts: integer; ADelimetr: string ): string;
procedure N_Dump1Strings ( AStrings: TStrings; AIndent: integer = 0 );
procedure N_Dump2Strings ( AStrings: TStrings; AIndent: integer = 0 );
procedure N_Dump1Integers( APrefix: String; APFirstInt: PInteger; ANumInts: Integer );
procedure N_Dump2Integers( APrefix: String; APFirstInt: PInteger; ANumInts: Integer );

procedure N_Dump1BufOnly ();
procedure N_Dump1Flash   ();
procedure N_Dump2BufOnly ();
procedure N_Dump2Flash   ();

type TN_RevSearchFlags = set of ( rsfRemoveLastSpace, rsfPreserve );
type TN_RevSearchObj = class( TObject ) // Object for Reverse Search in a String
  RSOFlags: TN_RevSearchFlags; // Search Flags
  RSOPatterns: TStringList;
  RSOResSL: TStringList;
end; // type TN_RevSearchObj = class( TObject )
//##*/

function  N_StrPos           ( const ASubStr, ASrcStr: string; ASrcBegPos: Integer ): Integer;
procedure N_ReplaceHTMLBR    ( var AStr: string; A4Chars: string );
function  N_ReplaceEQSSubstr ( var AStr: string; AOldSubstr, ANewSubstr: string ): integer;
procedure N_ReplaceEQSSubstrInSMatr ( AStrMatr: TN_ASArray; AOldSubstr, ANewSubstr: string );

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_SplitStringFlags
type TN_SplitStringFlags = set of ( // Split string Flags
  ssfPreserveCRLF,   // preserve carriage return and line feed characters
  ssfPreserveSpaces  // preserve spaces
);
//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_SplitStringParams
type TN_SplitStringParams = record // Split String Input and Output Parameters
  SSPFlags: TN_SplitStringFlags; // split string flags
  SSPMaxRowSize: integer;        // maximal size of string in resulting 
                                 // StringList
  SSPResSL: TStrings;            // resulting StringList, with all strings 
                                 // length <= SSPMaxRowSize
end; // TN_SplitStringParams = record

procedure N_SplitString1 ( AInpStr: string; var ASSParams: TN_SplitStringParams );
function  N_SplitString2 ( AInpStr: string; ARowSize: integer ): string;
procedure N_SplitSubStrings ( AInpStr, ADelimStr: string; AResSubStrings: TStrings );
function  N_RemoveGivenChar ( AStr: string; AChar: Char ): string;
procedure N_AddCRLFIfNotYet( var AStr: string );


{ just for info:
  tagLOGFONTA = packed record
    lfHeight: Longint;
    lfWidth: Longint;
    lfEscapement: Longint;
    lfOrientation: Longint;
    lfWeight: Longint;
    lfItalic: Byte;
    lfUnderline: Byte;
    lfStrikeOut: Byte;
    lfCharSet: Byte;
    lfOutPrecision: Byte;
    lfClipPrecision: Byte;
    lfQuality: Byte;
    lfPitchAndFamily: Byte;
    lfFaceName: array[0..LF_FACESIZE - 1] of AnsiChar;
  end;
}

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_OwnLogFont
type TN_OwnLogFont = packed record // Own version of Windows LogFont description (with 64 bytes FaceName)
    lfHeight: Longint;
    lfWidth: Longint;
    lfEscapement: Longint;
    lfOrientation: Longint;
    lfWeight: Longint;
    lfItalic: Byte;
    lfUnderline: Byte;
    lfStrikeOut: Byte;
    lfCharSet: Byte;
    lfOutPrecision: Byte;
    lfClipPrecision: Byte;
    lfQuality: Byte;
    lfPitchAndFamily: Byte;
    lfFaceName: array[0..LF_FACESIZE - 1] of WideChar;
end; // type TN_OwnLogFont = packed record // Own version of Windows LogFont

//***** Several lfCharSet values (how to interpret Ansi char values in (128..255)):
//  ANSI_CHARSET       = 0;   - do not convert Ansi chars, use them as is
//  DEFAULT_CHARSET    = 1;   - use current Windows Language CodePage for conversion?
//  RUSSIAN_CHARSET    = 204; - should be set for drawing cyrillic chars
//  OEM_CHARSET        = 255; - MS DOS CodePage?


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_NFont
type TN_NFont = packed record // New Font Params and Handle (Windows only)
  NFWin: TN_OwnLogFont; // Own version of Windows LogFont description
  NFFaceName: string; // Font Face Name as Pascal string (just for editing in 
                      // RAFrame)
  NFLLWHeight: float; // Font Character Height in LFH units (Cell Height if 
                      // NFLLWHeight<0)
  NFWeight:  integer; // Font Weight (0-1000), 0 - means set Weigth by NFBold 
                      // flag
  NFBold:       byte; // Bold flag, works only if NFWeight = 0
//##/*
  NFReserved1:  byte;
  NFReserved2:  byte;
  NFReserved3:  byte;
//##*/
  NFHandle:    HFont; // GDI Font Handle (RunTime field)
end; // type TN_NFont = packed record
type TN_PNFont = ^TN_NFont;
type TN_NFonts = array of TN_NFont;

procedure N_CreateFontHandle ( APFont: TN_PNFont; ALFHPixSize: float );

type TN_PBEventProcObj = procedure( AStr: string; APBValue: float ) of object;

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_PBCParams
type TN_PBCParams = record // Progress Bar Caller Parameters
  FmtStr: string;               // Format string for output one double value
  ProcOfObj: TN_PBEventProcObj; // procedure of object that shows progress info
  TimeStep:   float;            // time step in seconds

  Color:    integer;         // Progress Bar Color
  PixRect:    TRect;         // Progress Bar whole rectangle
  Form:       TForm;         // Form, on which Progress Bar rectangle should be 
                             // drawn

  Prefix:      string;       // prefix string show in StatusBar before percent 
                             // progress value
  StatusBar:   TStatusBar;   // TStatusBar Delphi Control to show progress text 
                             // value (may be nil)
  ProgressBar: TProgressBar; // TProgressBar Delphi Control to show (may be nil)
end; // type TN_PBCParams = record
type TN_PPBCParams = ^TN_PBCParams;

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_ProgressBarCaller
type TN_ProgressBarCaller = class( TObject ) // Progress Bar Caller Object
    private
  PBCBegCounter: int64;    // Saved Beg of current Time interval in CPU clocks
  PBCLastDrawnRect: TRect; // Last Drawn Rectangle (in positive coords)
  PBCFormSizeLocked: boolean; // True if PBCForm.Constraints was temporary 
                              // changed
  PBCSavedSize: TRect;     // Saved PBCForm.Constraints (4 numbers)
    public
  PBCFmtStr: string;     // Format string for output one double value
  PBCMaxPBValue: double; // Max Progress Bar Value (MinPBValue is 0)
  PBCProcOfObj: TN_PBEventProcObj; // Procedure Of Object that Shows Progress
  PBCTimeStep:   float;  // Time Step in seconds

  PBSUIniSpeed : float;  // Smooth Update initial speed in bar parts per second

  PBCColor:    integer;  // RectProgressbar Color
  PBCPixRect:    TRect;  // whole Progressbar Rectangle
  PBCForm:       TForm;  // Form, on which Progress Bar Rectangle should be 
                         // drawn

  PBCPrefix:      string;       // Prefix in StatusBar before Percent value
  PBCStatusBar:   TStatusBar;   // StatusBar to Show Prefix and Percent value 
                                // (may be nil)
  PBCProgressBar: TProgressBar; // Progress Bar to Show (may be nil)

//##/*
  constructor Create ();
//##*/
  procedure Start  ( AMaxPBValue: double; AProcOfObj: TN_PBEventProcObj = nil );
  function  Update ( ACurPBValue: double ): boolean; overload;
  function  Update ( ACurPBValue: double; AMaxPBValue: double ): boolean; overload;
  procedure Finish ();

  procedure SaveParams    ( APPBCParams: TN_PPBCParams );
  procedure RestoreParams ( APPBCParams: TN_PPBCParams );
  procedure ClearParams   ();

  procedure RectProgressBarInit ( AForm: TForm; APixRect: TRect; AColor: integer );
  procedure RectProgressBarDraw ( AStr: string; APBValue: float );

  procedure SBPBProgressBarInit ( APrefix: string; ASB: TStatusBar; APB: TProgressBar );
  procedure SBPBProgressBarDraw ( AStr: string; APBValue: float );
end; // type TN_ProgressBarCaller = class( TObject )

//##/*
type TN_IndIterator = class( TObject ) //***** Index Iterator Object
    private
  IIDigSizes:     TN_IArray; // Digit Sizes (number of indexes in Digit)
  IICurDigValues: TN_IArray; // Current Digits Values
  IIInds:         TN_IArray; // Index Values for All Digits (Array Size is summ of all IIDigSizes)
    public
  IINumDigits: integer;      // Number ot "Digits" (size of IIDigSizes and IICurDigValues arrays may be bigger)

  procedure AddIIDigit   ( ADigSize, ANumSwaps, AISeed: integer );
  procedure PrepIIDigits ( APDigSizes: PInteger;
                             ANumDigits, AISeed: integer; ANumSwapsCoef: float );
  procedure GetIInds     ( APResInds: PInteger );
end; // type TN_IndIterator = class( TObject )
//##*/

//********************* Compare Arrays Elems types and class

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CTAOOneInterval
type TN_CTAOOneInterval = packed record // One interval indexes (CTAOCompResult array elements type)
  CTAOA1FirstInd:  Integer; // First Index of A1 array interval
  CTAOA2FirstInd:  Integer; // First Index of A2 array interval
  CTAOA1NumElemes: Integer; // Number of elements in A1 array interval
  CTAOA2NumElemes: Integer; // Number of elements in A2 array interval ( 
                            // CTAOA1NumElemes=CTAOA2NumElemes if it is the 
                            // interval of same elements)
end; // type CTAOOneInterval = packed record // One interval indexes (CTAOCompResult array elements type)
type TN_CTAOIntervals = Array of TN_CTAOOneInterval;

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompTwoArraysObj
type TN_CompTwoArraysObj = class( TObject ) // Compare Two Arrays Object
    public
  CTAOFirstElemIsSame:     boolean; // first elements of A1 and A2 arrays are 
                                    // the same
  CTAOCompResult: TN_CTAOIntervals; // resulting intervals of same and not same 
                                    // elements
  CTAOCompResultCount:     Integer; // Number of elements (intervals) in 
                                    // CTAOCompResult
  CTAONumSameElems:        Integer; // Whole Number of same elements in A1 and 
                                    // A2 arrays
  CTAONumNotSameElemsA1:   Integer; // Whole Number of not same elements in A1 
                                    // array
  CTAONumNotSameElemsA2:   Integer; // Whole Number of not same elements in A2 
                                    // array
  CTAONumSameToShow:       Integer; // For same elements Intervals show only 
                                    // CTAONumSameToShow elements

  procedure CTAOCompare ( AA1Ptr, AA2Ptr: Pointer; AA1NumElems, AA2NumElems, AElemSize: Integer;
                                                     AFuncOfObj: TN_BoolFuncObj2Ptr );
  procedure CTAOShowResAsStrings1 ( AInpStrings1, AInpStrings2: TStrings; AColWidth, AFlags: Integer; AOutStrings: TStrings );
  procedure CTAOShowResAsStrings2 ( AOutStrings: TStrings );
  procedure CTAOShowResAsStrings3 ( AFunc1, AFunc2: TN_StrFuncObjInt; AColWidth, AFlags: Integer; AOutStrings: TStrings );
  procedure CTAOShowResAsStrings4 ( AFunc1, AFunc2: TN_StrFuncObjInt; AColWidth, AFlags: Integer; AOutStrings: TStrings );

  function  CTAOSameString      ( APtr1, APtr2: Pointer ): boolean;
  function  CTAOSameIntOrString ( APtr1, APtr2: Pointer ): boolean;
end; // type TN_CompTwoArraysObj = class( TObject ) // Compare Two Arrays Object

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_LogObjFlags
type TN_LogObjFlags = Set Of ( //
  lofCumLog  // Cumulative log (New strings are added to existed file)
    );

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_LogObj
type TN_LogObj = class( TObject ) // Using Log Object
    public
  LOFlags: TN_LogObjFlags; // Logging Flags
  LOReserved1:       Byte; // Reserved
  LOReserved2:       Byte; // Reserved
  LOReserved3:       Byte; // Reserved
  LOFileName:      String; // File Name to save Log
  LOSL:       TStringList; // for Collecting Log strings

  constructor CreateByLogName ( const ALogFName: String; AFlags: TN_LogObjFlags );
  destructor  Destroy(); override;

  procedure LOAdd        ( AStr: String );
  procedure LOSaveToFile ();
end; // type TN_LogObj = class( TObject ) // Using Log Object

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_RecordsBufObj
type TN_RecordsBufObj = class( TObject ) // Any Records Bufer Object
    public
  RBBuf:   TN_BArray; // Buf for storing Records
  RBBufSize: Integer; // RBBuf Size in Bytes
  RBFreeInd: Integer; // First Free Byte in RBBuf

  constructor CreateBySize ( ABufSize: Integer );
  destructor  Destroy(); override;

  function  RBAddRecord ( ARecPtr: Pointer; ArecSize: integer ): Integer;

end; // type TN_RecordsBufObj = class( TObject ) // Using Log Object


function  N_CPUCounter       (): Int64; assembler;
function  N_GetCPUFrequency  ( ADelayTime: integer ): double;
//##/*
procedure N_DelayByLoop ( AMilliSeconds: double );
//##*/
function  N_SecondsToString1  ( ASeconds: double; AFmt: string = '' ): string;
function  N_TimeToString     ( WholeTime: double; NTimes: integer ): string;

function  N_IsDecimalDigit     ( AChar: Char ): boolean;
function  N_IsLatinLetter      ( AChar: Char ): boolean;
function  N_IsWin1251CyrLetter ( AAnsiChar: AnsiChar ): boolean;
function  N_IsUNICODECyrLetter ( AWideChar: WideChar ): boolean;
function  N_IsCyrLetter        ( AChar: Char ): boolean;
function  N_ConvToProperName   ( AStr: string ): string;
function  N_ReplaceCRLFbySpace ( AStr: string ): string;
function  N_RemoveNonCyrChars  ( AStr: string ): string;
//procedure N_AddNotWhiteChars     ( AInpStr: string; var AOutStr: string; var AInpPos, AOutPos: Integer; AMaxOutPos: Integer );
procedure N_AddNotWhiteChars ( const AInpStr: string; var AInpFirstInd: Integer; AInpLastInd: Integer; var AOutStr: string; var AOutPos: Integer; AMaxOutPos: Integer );
function  N_RemoveSubsWhiteChars ( AStr: string ): string;
function  N_CalcNumNotSubsWhiteChars ( AStr: string; AFirstInd, ALastInd: Integer ): Integer;
procedure N_SplitSubStrToStrings ( const AInpStr: string; AInpFirstInd, AInpLastInd: Integer; AOutStrings: TStrings; AMinPos, AMaxPos: Integer );

function  N_DataSizeToString ( ADataSize: Int64; AFmt: string = '' ): string;
function  N_SecondsToString  ( ASeconds: double; AFmt: string = '' ): string;

function  N_CyrToLatChars  ( ACyrStr: string ): string;
function  N_CalcNumCyrChars( const AString: string; AFirstInd, ALastInd: Integer ): Integer;

function  N_XLSToClipboard ( AFileName: string; ASheetInd: integer = 1 ): boolean;
procedure N_ReplaceArrayElems ( var AArray: TN_BArray; ABegInd, ACurNumElems,
              ACurAllElems: integer; APNewElems: PByte; ANewNumElems: integer ); overload;
procedure N_ReplaceArrayElems ( var AArray: TN_IArray; ABegInd, ACurNumElems,
              ACurAllElems: integer; APNewElems: PInteger; ANewNumElems: integer ); overload;
function  N_SameBytes ( const APtr1: Pointer; ANumBytes1: integer;
                        const APtr2: Pointer; ANumBytes2: integer ): boolean; overload;
function  N_SameInts ( PInt1: PInteger; NumInts1: integer;
                       PInt2: PInteger; NumInts2: integer): boolean; overload;
//##/*
function  N_GetFileFlagsByExt ( AFileName: string ): TN_FileExtFlags;
//##*/
procedure N_FillStringsArray  ( APOutStrings: PString; ANumOutStrings: integer;
                                APInpStrings: PString = nil; ANumInpStrings: integer = 0 );
procedure N_FillRectOnWinDesktop ( ARect: TRect; AFillColor: integer );
procedure N_FillRectOnWinHandle  ( AWinHandle: HWND; ARect: TRect; AFillColor: integer );
function  N_CrIA  ( AA: Array of integer ): TN_IArray;
function  N_CrDA  ( AA: Array of double ): TN_DArray;
function  N_CrIPA ( AA: Array of integer ): TN_IPArray;
function  N_CrDPA ( AA: Array of double ): TN_DPArray;
function  N_BinSegmSearch ( APElemArray: TN_BytesPtr; AElemCount, AElemSize: integer;
                                                      AValue: double ): integer;
//##/*
procedure N_WarnByMessage ( AWarningMessage: string );
procedure N_Alert         ( AAlertStr: string );
//##*/

//##/*
function  N_TrimLastSpecialChars ( AStr: string ): string;
//##*/

function  N_NumWideChars     ( APWChar: PWideChar ): Integer;
function  N_CreateWideString ( APWChar: PWideChar ): WideString;

function  N_AnsiToWide   ( AAnsiString: AnsiString ): WideString;
function  N_AnsiToString ( AAnsiString: AnsiString ): String;
function  N_WideToAnsi   ( AWideString: WideString ): AnsiString;
function  N_WideToString ( AWideString: WideString ): String;
function  N_StringToAnsi ( AString: String ): AnsiString;
function  N_StringToWide ( AString: String ): WideString;

function  N_EncodeAnsiStringToBytes ( AAnsiString: AnsiString; var AResABytes: TN_BArray ): integer;
function  N_EncodeWideStringToBytes ( AWideString: WideString; var AResABytes: TN_BArray ): integer;
function  N_EncodeStringToBytes     ( AString: string;         var AResABytes: TN_BArray ): integer;

function  N_AnalizeBOMBytes ( const ASrcABytes: TN_BArray; ANumBytes: integer ): TN_TextEncoding;
function  N_Utf8ToUnicode   ( APDst: PWideChar; AMaxDstChars: Cardinal; APSrc: PChar; ANumSrcChars: Cardinal; AErrorChar: WideChar ): Cardinal;
function  N_Utf8Decode      ( AUTF8Str: String; AErrorChar: WideChar = '?' ): WideString;
function  N_DecodeAnsiStringFromBytes ( const ASrcABytes: TN_BArray; ANumBytes: integer ): AnsiString;
function  N_DecodeWideStringFromBytes ( const ASrcABytes: TN_BArray; ANumBytes: integer ): WideString;
function  N_DecodeStringFromBytes     ( const ASrcABytes: TN_BArray; ANumBytes: integer ): string;

function  N_GetFileSize           ( AFName: string ): int64;
function  N_SizeInBytesToStr      ( ASizeInBytes: int64 ): string;
procedure N_SaveStringToFile      ( AFName: string; AString: string );
procedure N_SaveStringsToFile     ( AFName: string; AStrings: TStrings );
function  N_CreateStringFromFile  ( AFName: string ): string;
function  N_CreateStringsFromFile ( AFName: string ): TStringList;

procedure N_WriteTextFile       ( const AFName, AContent: string );
function  N_ReadTextFile        ( AFName: string ): string;
function  N_ReadANSITextFile    ( AFName: string ): string;
function  N_BinFileToANSIString ( AFName: string; AMaxLeng: Integer ): string;
procedure N_AddToTextFile       ( AFName, AContent: string );
procedure N_AddStrToAnsiStream    ( AStream: TStream; AStr: string );
procedure N_SaveStringsToAnsiFile ( AFName: string; AStrings: TStrings );

procedure N_WriteBinFile ( AFName: string; APData: Pointer; ADataSize: integer );
function  N_ReadBinFile  ( AFName: string; var ABArray: TN_BArray ): integer;
procedure N_AddToBinFile ( AFName: string; APData: Pointer; ADataSize: integer );

function  N_CompressMem ( APSrcBuf: Pointer; ASrcBufSize: integer;
                          APDstBuf: Pointer; ADstBufSize, AComprLevel: integer ): integer;
function  N_GetUncompressedSize ( APBuf: Pointer; ABufSize: integer ): integer;
function  N_DecompressMem ( APSrcBuf: Pointer; ASrcBufSize: integer;
                            APDstBuf: Pointer; ADstBufSize: integer ): integer;
procedure N_BytesToHexChars  ( APBytes: Pointer; ANumBytes: integer; APChars: PChar );
procedure N_HexCharsToBytes  ( APChars: PChar; APBytes: Pointer; ANumBytes: integer );
function  N_BytesToHexString ( APBytes: Pointer; ANumBytes: integer ): string;

function  N_JoinStrings      ( AStrings: TStrings; ADelimStr: string ): string;
function  N_ReplacePointByDecSep ( AInpStr: string ): string;
function  N_ReplaceDecSepByPoint ( AInpStr: string ): string;

procedure N_QuoteChars   ( APSrcChars: PChar; ANumSrcChars: integer;
                           AQuoteChar: Char; var APDstChars: PChar );
function  N_DeQuoteChars ( var APSrcChars: PChar; AIniResSize: integer ): string;
function  N_QuoteString  ( ASrcStr: string; AQuoteChar: Char ): string;
function  N_CharInString ( AString, AChars: string ): boolean;
function  N_ConcatenateSArray ( AAStrings: TN_SArray; AFlags: TN_ConcatFlags;
                                ADelimStr, ASpecChars: string; AQuoteChar: Char;
                                var AResString: string ): integer;

procedure N_SaveSMatrToStrings2 ( AStrMatr: TN_ASArray; AStrings: TStrings; ASMFormat: TN_StrMatrFormat );
procedure N_SaveSMatrToFile2    ( AStrMatr: TN_ASArray; AFileName: string; ASMFormat: TN_StrMatrFormat );

function  N_CharsToBool  ( var APChar: PChar ): boolean;
function  N_StrToBool    ( AStr: string ): boolean;

procedure N_GetHTMLText    ( var APHTML: PChar; APPortion: TN_PHTMLPortion );
procedure N_GetHTMLTag     ( var APHTML: PChar; APPortion: TN_PHTMLPortion );
procedure N_GetHTMLPortion ( var APHTML: PChar; APPortion: TN_PHTMLPortion );
procedure N_AddSplittedStr ( AStrings: TStrings; AStr: String; AIndent, AMaxChars: integer );

//**************** Log procedures
procedure N_LCExecAction   ( ALCInd: integer; ALCAction: TN_LCActionType; AIntPar: integer = 0 );
procedure N_LCAdd          ( ALCInd: integer; AStr: string );
procedure N_LCAddTyped     ( ALCInd, AType: integer; AStr: string );
procedure N_LCAddErr       ( ALCInd: integer; AStr: string );
procedure N_LCClearErr     ( ALCInd: integer; AStr: string );
function  N_LCError        ( ALCInd: integer ): boolean;
procedure N_LCAddFinishedOKFlag   ( ALCInd: integer );
function  N_LCCheckFinishedOKFlag ( ALCInd: integer ): boolean;
procedure N_LCInit1 ( ABufSize: integer );

function  N_FToDbl         ( AFloat: float ): double;
function  N_StrToMSizeUnit ( AStr: string ): TN_MSizeUnit;

function  N_Conv1251ToUnicode ( AStr: string ): WideString;
function  N_ConvUnicodeTo1251 ( AWStr: WideString ): string;

procedure N_GetBracketsInfo ( ASrcStr: string; var AResInfo: TN_BracketsInfo );
function  N_CalcNumChars ( AStr: String; ABegInd, AEndInd: integer; AChar: Char ): integer;
function  N_ConvSpecCharsToHex ( ASrcStr: string; ARowSize: integer; AMode: string ): string;
procedure N_SwapTObjects ( var ATObj1, ATObj2: TObject );
procedure N_RoundVector  ( APSrcVal: PDouble; ANumVals: integer; APResVal: PInteger );
procedure N_SplitIntegerValue ( APSrcVal: PDouble; ANumVals, AIntValue: integer; APResVal: PInteger ); overload;
procedure N_SplitIntegerValue ( APSrcVal: PFloat;  ANumVals, AIntValue: integer; APResVal: PInteger ); overload;

//##/*
function  N_CalcCNK      ( AN, AK: integer ): double;
procedure N_CalcCNKInds  ( AN, AK, ASrcNum, ASrcInd: integer; APResInd: PInteger );
//##*/

procedure N_CopyStringsByPtrs ( APSrc, APDst: PString; ASrcStep, ANumStrings: integer );
procedure N_CopyDoubles  ( APSrc, APDst: PDouble; ASrcStep, ANumDoubles: integer );
procedure N_CopyIntegers ( APSrc, APDst: PInteger; ASrcStep, ANumIntegers: integer );

//##/*
function  N_FormatDouble ( Accuracy, Mode: integer; Value: double ): string;
//##*/

function  N_FileNameWithoutExt ( AFileName: string ): string;
function  N_ParseFileName ( AFileName: string;
                        out ABegFName, ANumFName, AEndFName: string ): integer;
function  N_ChangeFileName ( AFileName: string; ADelta: integer ): string;
function  N_CreateUniqueFileName ( APrefix: string; var ANumber: integer;
                                   APostfix: string ): string; overload;
function  N_CreateUniqueFileName ( FileName: string ): string; overload;
function  N_GetMaxValue          ( APFirstInt: PInteger; ANumInts: integer ): integer;
function  N_CalcNumDigits        ( AInt: integer ): integer;

procedure N_CalcEqualIntervals ( var AIntervals: TN_IPArray; ANumIntervals, AMaxInt: integer );
procedure N_CalcNIRsBySizes    ( var ANIRs: TN_IArray; ANumRanges, AMinVal: integer; ASizes: TN_IArray );
procedure N_CalcUniformNIRs    ( var ANIRs: TN_IArray; ANumRanges, AMinVal, AMaxVal: integer );
procedure N_GroupHistData      ( AHistData: TN_IArray; ANIRs: TN_IArray;
                                 ANumRanges: integer; var AResData:  TN_DArray );
procedure N_UpdateNIRsByWCoefs ( ASrcNIRs: TN_IArray; AWCoefs: TN_DArray;
                                 ANumRanges: integer; var ADstNIRs:  TN_IArray;
                                 ANewMinVal, ANewMaxVal: integer; AMaxCoef: double );
procedure N_SetXLATFragm      ( APXLAT: PInteger; AMinInd, AMaxInd, AMinVal, AMaxVal: integer );
procedure N_CalcUniformXLAT   ( var AXLAT: TN_IArray; ANumElems: integer );
procedure N_CalcXLATByTwoNIRs ( AXLAT: TN_IArray; ASrcNIRs, ADstNIRs: TN_IArray; ANumRanges: integer );

procedure N_ConvGrayToRGB8XLat    ( AXLat: TN_IArray; ANumBits: integer );
procedure N_CombineXLatTables      ( AXLat1, AXLat2: TN_IArray );

procedure N_CreateXLatTableBy2P    ( var AResTable: TN_BArray; AP1, AP2: TPoint );  overload;
procedure N_CreateXLatTableBy2P    ( var AResTable: TN_BArray; AP1, AP2: TFPoint ); overload;
procedure N_CreateXLatTableByGamma ( var AResTable: TN_BArray; AGamma: double );
procedure N_ConvRGBValues  ( ASrcRGBValues: TN_BArray;
                             var ADstRGBValues: TN_BArray; ANumTriples: integer;
                             ARValues, AGValues, ABValues: TN_BArray );


function  N_IntToStr     ( AInt, AFmtFlags: integer ): String;
procedure N_DumpIntegers ( APFirstInt: PInteger; ANumInts, AFmtFlags: integer; AStrings: TStrings ); overload;
procedure N_DumpIntegers ( APFirstInt: PInteger; ANumInts, AFmtFlags: integer; AFName: String ); overload;

procedure N_PackSDoublesToInt     ( const AAccuracy, ACount, ABStep: integer;
                                              const APtrInt, APtrDouble: Pointer );
procedure N_UnpackSDoublesFromInt ( const aAccuracy, ACount, ABStep: integer;
                                              const APtrInt, APtrDouble: Pointer );
//##/*
function  N_DTString ( DT: double  ): string;
//##*/

procedure N_ShiftCursor ( ADX, ADY: integer );
function  N_GetComboBoxIndex ( AComboBox: TComboBox ): integer;

//##/*
procedure N_Warn1  ( WarnAction: integer );
procedure N_TM            ( TestMessage: string );
procedure N_Error1 ( ErrorMessage: string );
//##*/

function  N_ScanInteger   ( var AStr: string ): integer;
function  N_ScanFloat     ( var AStr: string ): float;
function  N_ScanDouble    ( var AStr: string ): double;
function  N_ScanToken     ( var AStr: string ): string;

//##/*
function  N_ScanLastToken ( var AStr: string ): string;
//##*/

procedure N_ScanIntegers  ( var AStr: string; AA: Array of PInteger );
procedure N_ScanDoubles   ( var AStr: string; AA: Array of PDouble );

function  N_ScanIArray    ( var AStr: string; var AIArray: TN_IArray ): integer;
function  N_ScanFArray    ( var AStr: string; var AFArray: TN_FArray ): integer;
function  N_ScanDArray    ( var AStr: string; var ADArray: TN_DArray ): integer;
function  N_ScanSArray    ( var AStr: string; var ASArray: TN_SArray ): integer;
function  N_ScanColor     ( var AStr: string ): integer;

//##/*
function  N_QS            ( const AStr: string ): string;
//##*/

function  N_QuoteStr      ( const AStr: string; AQuote: char ): string;
function  N_Remove0DChars ( const AStr: string ): string;

function  N_SwapRedBlueBytes   ( ASrcColor: integer ): integer;
procedure N_SwapTwoInts        ( APInt1, APInt2: PInteger );
function  N_ReverseFourBytes      ( ASrcInt: DWORD ): DWORD;

function  N_StrToColor         ( AStr: string ): integer;
function  N_ColorToHTMLHex     ( AColor: integer ): string;
function  N_ColorToQHTMLHex    ( AColor: integer ): string;
function  N_ColorToRGBDecimals ( AColor: integer ): string;

function  N_RGB8ToGray8        ( ARGB8Color: Integer ): Integer;
function  N_GrayToRGB8         ( AGray: Integer; ANumBits: Integer = 8 ): Integer;
function  N_GrayToRGB16        ( AGray: Integer ): Int64;
function  N_LinCombRGB8        ( AColor1, AColor2: Integer; AAlfa: double ): Integer;

function  N_GetTabDelimToken   ( var APChar: PChar; var ANumChars: integer ): string;
function  N_GetStringsText     ( AStrings: TStrings; ADelimiter: integer = -1 ): string;
procedure N_AddTabDelimToken   ( var ABufStr: string; AToken: string; var ANumChars: integer );
function  N_PosExPtr ( APSubStr, APStr: Pointer; ASubstrLeng, AStrOffset, ANumCharsToSearch: Integer ): Integer;
function  N_PosEx    ( const ASubStr, AStr: string; AStrOffset, ANumCharsToSearch: Integer ): Integer;

procedure N_ReverseIntArray   ( AIntArray: TN_IArray; ANumElemes: integer );
function  N_MemBlocksStr      ( APMemBlocksInfo: TN_PMemBlocksInfo ): String;
procedure N_GetMemBlocksInfo1 ( APMemBlocksInfo: TN_PMemBlocksInfo );
procedure N_GetMemBlocksInfo2 ( AMinBigSize: DWORD; AResStrings: TStrings );
procedure N_AddDirToPATHVar   ( ADir: String );
function  N_ClipBy0255        ( AValue: double ): integer;
procedure N_AddColumnToSL  ( AMainSL, AColumnSL: TStrings; AGap, AMainInd: integer );

function  N_CreateWhiteChars ( ANumWhiteChars: Integer ): string;
function  N_FormatString ( ASrcStr, AEllipsisStr: string; ANeededLength: integer; AFmtFlags: Integer ): string;
function  N_AlignString  ( ASrcStr, AClipStr: string; ANeededLength: integer; AFmtFlags: TN_CellFmtFalgs ): string;
procedure N_AlignStrMatr ( AStrMatr: TN_ASArray; ACFPArray: TN_CFPArray );
procedure N_StrMatrToStrings ( AStrMatr: TN_ASArray; AStrings: TStrings; ADelimStr: string );
procedure N_StringsFromStrMatr  ( AStrings: TStrings; AStrMatr: TN_ASArray;
                                  ABegIndX, ABegIndY, ANumElemes: integer );
procedure N_IntsFromStrMatr ( var AIArray: TN_IArray; AStrMatr: TN_ASArray;
                                  ABegIndX, ABegIndY, ANumElemes: integer );
function  N_GetDateTimeStr1 ( ADateTime : TDateTime = 0 ): string;
function  N_B2Str           ( ABoolVal: boolean ): string;
procedure N_DumpTControl    ( AName: string; AControl: TControl );
function  N_GetComboBoxObjInt ( AComboBox: TComboBox ): integer;

procedure N_WinMemFullInfo       ( ASL: TStrings; AMode: integer );
procedure N_CollectFreeMemBlocks ( var AMemBlocks: TN_FreeMemBlocks );
procedure N_FreeMemBlocksInfo    ( ASL: TStrings; AMemBlocks: TN_FreeMemBlocks; AMode: integer );
procedure N_FreeMemBlocksDifInfo ( ASL: TStrings; AMemBlocks1, AMemBlocks2: TN_FreeMemBlocks; AMode: integer );
procedure N_DelphiHeapInfo       ( ASL: TStrings; AMode: integer );
procedure N_PlatformInfo         ( ASL: TStrings; AMode: integer );
procedure N_DumpDPIRelatedInfo   ( AMode: integer );
procedure N_AddStrToFile         ( AStr: AnsiString );
procedure N_AddStrToFile2        ( AStr, AFName: AnsiString );
procedure N_AddDateTimeToFile    ();

function  N_GetDNTLSSize       ( AStrings: TStrings ): integer;
procedure N_ConvStringsToDNTLS ( AStrings: TStrings; APDNTLS: Pointer );

function  N_GetClipboardFormats    (): string;
function  N_GetFNamesFromClipboard ( AFNames: TStrings ): integer;
function  N_CopyFNamesToClipboard  ( AFNames: TStrings ): integer;

function  N_IntInSet ( AInt: integer; APSetOfInts: TN_PSetOfIntegers ): boolean;

function  N_WideLatStrToString ( AWideLatStr: WideString ): String;
function  N_IndexOfWord    ( AWordArray: TN_WordArray; AVal: Word ): integer;
function  N_IndexOfInteger ( AIArray: TN_IArray; AVal: Integer ): integer;
function  N_DelphiVersion  (): String;



//procedure N_CopyGUID ( const ASrcGUID: TGUID; var ADstGUID: TGUID );
//##/*
//##*/


var
  N_T1:  TN_CPUTimer1; // Timer for measuring one time interval
  N_T1a: TN_CPUTimer1; // Timer for measuring one time interval
  N_T1b: TN_CPUTimer1; // Timer for measuring one time interval
  N_T1c: TN_CPUTimer1; // Timer for measuring one time interval
  N_T2:  TN_CPUTimer2; // array of timers with adding interval capability
  N_T2a: TN_CPUTimer2; // array of timers with adding interval capability
  N_T2b: TN_CPUTimer2; // array of timers with adding interval capability
  N_T2c: TN_CPUTimer2; // array of timers with adding interval capability
  N_PlatfInfoTimer: TN_CPUTimer3; // Timer used only in N_PlatformInfo
  N_TimersStack: TList;
  N_GlobCPUTimerCounter: integer;

  N_GlobObj: TN_GlobObj; // Global Object (with minimal needed Units)
  N_PBCaller: TN_ProgressBarCaller; // Global Object for updating ProgressBar
  N_EnablePlainFile: boolean;
  N_SkipShiftKeyIsDown: boolean;
  N_SkipCtrlKeyIsDown: boolean;
  N_OpenPictureExtensions: Array [0..5] of string =
                           ( 'WMF', 'EMF', 'ICO', 'BMP', 'JPG', 'JPEG' );
  N_CFuncs: TN_CompFuncsObj;
  N_WinFormatSettings: TFormatSettings;
  N_DefDTimeFmt: string = 'dd.mm.yyy hh":"nn":"ss.z';

  N_VREDump1LCInd: integer = 0; // Logical Chanel index used in N_Dump1Str
  N_VREDump2LCInd: integer = 1; // Logical Chanel index used in N_Dump2Str

  N_CurLang: TN_CurLanguage = clEnglish;

  N_Win98:    boolean; // True if Windows98 or WindowsMe
  N_Win2K:    boolean; // True if Windows 2000  or Later
  N_WinXP:    boolean; // True if Windows XP    or Later
  N_WinVista: boolean; // True if Windows Vista or Later
  N_WinWin7:  boolean; // True if Windows 7     or Later

  N_PathToWord: string; // Path to WinWord.exe file

  N_SPLIndIterators: TStringList;
  N_TmpRoot: string = 'C:\\Delphi_Prj\\DTmp\\';
  N_TerminateSelfProcObj: TN_ProcObj;

  N_MainModalForm: TForm;
  N_DumpGlobObj: TN_DumpGlobObj;

  function  N_Encript1( ASrcStr: AnsiString ): AnsiString;
  function  N_Decript1( ASrcStr: AnsiString ): AnsiString;

  function N_GetFlushCountersStr() : string;
  function N_OnAppTerminate () : Boolean;


implementation
uses Math, Variants, ActiveX, ComObj, JPeg, ClipBrd,
     StrUtils, DateUtils,
//     N_Lib1, // N_Lib1 is only temporary needed
     K_CLib0;

type TN_MONITORINFO = packed record // Own version of Windows MONITORINFO structure
  cbSize:    DWORD;
  rcMonitor: TRect;
  rcWork:    TRect;
  dwFlags:   DWORD;
end; // type TN_MONITORINFO = packed record // Own version of Windows MONITORINFO structure
type TN_PMONITORINFO = ^TN_MONITORINFO;

function GetMonitorInfoA( AHM: integer; APMonInfo: TN_PMONITORINFO ): integer; external user32 name 'GetMonitorInfoA';


procedure N_IAdd( AStr: string );
begin
//  N_Dump1Str( AStr );
end;

//****************** TN_DumpGlobObj class methods  **********************

//*********************************************** TN_DumpGlobObj.GODump1Str ***
// Save one given AString to Dump1 (to N_Dump1LCInd Logging Channel)
//
//     Parameters
// AString  - String to save
//
// Is used as N_Dump1Str (of TN_OneStrProcObj type)
//
procedure TN_DumpGlobObj.GODump1Str( AString: string );
begin
  N_LCAdd( N_Dump1LCInd, AString );
end; // procedure TN_DumpGlobObj.GODump1Str

//*********************************************** TN_DumpGlobObj.GODump2Str ***
// Save one given AString to Dump2 (to N_Dump2LCInd Logging Channel)
//
//     Parameters
// AString  - String to save
//
// Is used as N_Dump2Str (of TN_OneStrProcObj type)
//
procedure TN_DumpGlobObj.GODump2Str( AString: string );
begin
  N_LCAdd( N_Dump2LCInd, AString );
end; // procedure TN_DumpGlobObj.GODump2Str

//********************************************** TN_DumpGlobObj.GODump2TStr ***
// Save one given Typed AString to Dump2 (to N_Dump2LCInd Logging Channel)
//
//     Parameters
// AType    - AString Type
// AString  - String to save
//
// Is used as N_Dump2TStr (of TN_OneIOneSProcObj type)
//
procedure TN_DumpGlobObj.GODump2TStr( AType: integer; AString: string );
begin
  N_LCAddTyped( N_Dump2LCInd, AType, AString );
end; // procedure TN_DumpGlobObj.GODump2TStr

//************************************************ TN_DumpGlobObj.GODumpStr ***
// Save one given AString to given ALCInd Logging Channel
//
//     Parameters
// ALCInd   - Logging Channel Index
// AString  - String to save
//
// Is used as N_DumpStr (of TN_OneIOneSProcObj type)
//
procedure TN_DumpGlobObj.GODumpStr( ALCInd: integer; AString: string );
begin
  N_LCAdd( ALCInd, AString );
end; // procedure TN_DumpGlobObj.GODumpStr

//******************************************************************* N_B2S ***
// Convert given Boolean value to "T" of "F" resulting string
//
function N_B2S( ABoolVal: Boolean ): string;
begin
  if ABoolVal then Result := 'T'
              else Result := 'F';
end; // function N_B2S

//******************************************************************* N_S2B ***
// Convert given AStr to Boolean
//
function N_S2B( AStr: string ): Boolean;
var
  PCur: PChar;
begin
  if Length( AStr ) = 0 then
    Result := False
  else
  begin
    PCur := @AStr[1];
    Result := N_CharsToBool( PCur );
  end;
end; // function N_S2B

//************************************************************** N_HexToInt ***
// Convert given hex number (as string) to integer
//
//     Parameters
// AHexStr - given number in hex form without any preceeding chars (0f, 9, ...)
// Result  - Return resulting integer
//
// if AHexStr contains invalid chars then Delphi 7 return 0,
// Delphi 2010 returns converted value till first invalid char
//
function N_HexToInt( AHexStr: string ): integer ;
begin
  if not TryStrToInt( '$' + AHexStr, Result ) then // invalid format
    Result := 0;
end; // function N_HexToInt

//*********************************************************** N_AnyHexToInt ***
// Convert given hex number (as string) to integer in any Hex format
//
//     Parameters
// AHexStr - given number in hex form without any preceeding chars (0f, 9, ...)
// Result  - Return resulting integer
//
// Supported Hex formats: 0xF 0Xf $F F (empty or invalid strings means 0)
// if AHexStr contains invalid chars then Delphi 7 return 0,
// Delphi 2010 returns converted value till first invalid char
//
function N_AnyHexToInt( AHexStr: string ): integer ;
var
  Str: string;
begin
  if Length(AHexStr) = 0 then
  begin
    Result := 0;
    Exit;
  end else
  begin
    Str := Trim( AHexStr );

    if Length(Str) = 0 then
    begin
      Result := 0;
      Exit;
    end;

    //***** Here: Length(Str) >= 1

    if Str[1] = '$' then
      Result := N_HexToInt( MidStr( Str, 2, Length(Str)-1 ) )
    else if Length(Str) = 1 then
    begin
      Result := N_HexToInt( Str );
    end else // Length(Str) >= 2
    begin
      Str[2] := UpCase( Str[2] );

      if (Str[1] = '0') and (Str[2] = 'X') then
        Result := N_HexToInt( MidStr( Str, 3, Length(Str)-2 ) )
      else
        Result := N_HexToInt( Str );
    end;
  end;
end; // function N_AnyHexToInt

//****************** TN_ObjList class methods  **********************

//***************************************************** TN_ObjList.GetIndex ***
// Get Index of Obj of given Type or -1 if not found
//
function TN_ObjList.GetIndex( AClassType: TClass ): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to Count-1 do
    if Items[i] is AClassType then
    begin
      Result := i;
      Break;
    end;
end; // function TN_ObjList.GetIndex

//******************************************************* TN_ObjList.AddNew ***
// Create and Add to self Obj of given Type
//
function TN_ObjList.AddNew( AClassType: TClass ): TObject;
var
  Ind: integer;
begin
  Ind := GetIndex( AClassType );
  if Ind = -1 then
  begin
    Ind := Add( AClassType.Create );
  end;
  Result := Items[Ind];
end; // function TN_ObjList.AddNew


//****************** TN_CPUTimer1 class methods  **********************

//****************************************************** TN_CPUTimer1.Start ***
// Start Timer (save current CPU Clock Counter to BegCounter)
//
procedure TN_CPUTimer1.Start;
begin
  // get in Cash all needed data
  Stop();
  BegCounter := N_CPUCounter();
end; // procedure TN_CPUTimer1.Start

//******************************************************* TN_CPUTimer1.Stop ***
// Set DeltaCounter - number of CPU Clocks after last call of Start proc
//
procedure TN_CPUTimer1.Stop;
begin
  DeltaCounter := N_CPUCounter();
  DeltaCounter := DeltaCounter - BegCounter - N_EpsCPUTimer1;
end; // procedure TN_CPUTimer1.Stop

//****************************************************** TN_CPUTimer1.ToStr ***
// Return current DeltaCounter value (divided by ANTimes) as a string
// in proper time units
//
//     Parameters
// ANTimes - given divider (e.g. number of times the test was passed)
//
function TN_CPUTimer1.ToStr( ANTimes: integer = 1 ): string;
begin
  // N_TimeToString function requires time in days
  Result := N_TimeToString( (DeltaCounter/N_CPUFrequency)/N_SecondsInDay, ANTimes );
end; // function TN_CPUTimer1.ToStr

//********************************************* TN_CPUTimer1.Show(2,OutStr) ***
// Show time interval in DeltaCounter with given Prefix
//
procedure TN_CPUTimer1.Show( Prefix: string; out OutStr: string );
begin
  Inc(N_GlobCPUTimerCounter);
  OutStr := Format( '%d %s : %s', [N_GlobCPUTimerCounter, Prefix, ToStr( 1 )] );
end; // procedure TN_CPUTimer1.Show(2,OutStr)

//**************************************************** TN_CPUTimer1.Show(1) ***
// Show time interval in DeltaCounter with given Prefix
//
procedure TN_CPUTimer1.Show( Prefix: string );
var
  Str: string;
begin
  Show( Prefix, Str );
  N_IAdd( Str );
  N_Dump1Str( Str );
end; // procedure TN_CPUTimer1.Show(1)

//**************************************************** TN_CPUTimer1.SS(Str) ***
// Stop and Show time interval in DeltaCounter with given Prefix
//
procedure TN_CPUTimer1.SS( Prefix: string; out OutStr: string );
begin
  Stop();
  Show( Prefix, OutStr );
end; // procedure TN_CPUTimer1.SS(Str)

//****************************************************** TN_CPUTimer1.SS(1) ***
// Stop and Show time interval in DeltaCounter with given Prefix
//
procedure TN_CPUTimer1.SS( Prefix: string );
begin
  Stop();
  Show( Prefix );
end; // procedure TN_CPUTimer1.SS(1)

//***************************************************** TN_CPUTimer1.SSS(1) ***
// Stop, Show time interval in DeltaCounter with given Prefix
// and Start again
//
procedure TN_CPUTimer1.SSS( Prefix: string );
begin
  Stop();
  Show( Prefix );
  Start();
end; // procedure TN_CPUTimer1.SSS(1)

//***************************************************** TN_CPUTimer1.SSS(2) ***
// Stop, Show time interval in DeltaCounter with given Prefix
// and Start again
//
procedure TN_CPUTimer1.SSS( Prefix: string; out OutStr: string );
begin
  Stop();
  Show( Prefix, OutStr );
  Start();
end; // procedure TN_CPUTimer1.SSS(1)

//************************************************* TN_CPUTimer1.CurSeconds ***
// Return current Timer value in seconds (without stoping Timer)
//
function TN_CPUTimer1.CurSeconds(): double;
begin
  Result := (N_CPUCounter() - BegCounter - N_EpsCPUTimer1) / N_CPUFrequency;
end; // procedure TN_CPUTimer1.CurSeconds

//************************************************ TN_CPUTimer1.StopSeconds ***
// Stop Timer and Return Timer value in seconds
//
function TN_CPUTimer1.StopSeconds(): double;
begin
  Stop();
  Result := DeltaCounter / N_CPUFrequency;
end; // procedure TN_CPUTimer1.StopSeconds


//****************** TN_CPUTimer2 class methods  **********************

//***************************************************** TN_CPUTimer2.Create ***
//
constructor TN_CPUTimer2.Create( NumTimers: integer );
begin
  Clear( NumTimers );
end; // constructor TN_CPUTimer2.Create

//**************************************************** TN_CPUTimer2.Destroy ***
//
destructor TN_CPUTimer2.Destroy();
begin
  Items := nil;
end; // destructor TN_CPUTimer2.Destroy

//****************************************************** TN_CPUTimer2.Clear ***
// Increase Number of Timers if needed and Clear ALL timers
//
procedure TN_CPUTimer2.Clear( AMinNumTimers: integer );
var
  i: integer;
begin
  if Length(Items) < AMinNumTimers then // Update number of Timers if needed
    SetLength( Items, AMinNumTimers );

  for i := 0 to High(Items) do // Clear ALL timers (may be more than AMinNumTimers)
  with Items[i] do
  begin
    DeltaCounter := 0;
    NTimes := 0;
    StartLevel := 0;
  end;
end; // procedure TN_CPUTimer2.Clear

//****************************************************** TN_CPUTimer2.Start ***
// Start Timer with TimerInd index,
// Variant #1: no prefetch additional statements
// (save current CPU Clock Counter to Timers[TimerInd].BegCounter)
//
procedure TN_CPUTimer2.Start( TimerInd: integer );
begin
  with Items[TimerInd] do
  begin
    if StartLevel = 0 then // first call, Start Timer
    begin
      Inc( NTimes );
      StartLevel := 1;
      BegCounter := N_CPUCounter() + N_EpsCPUTimer2;
    end else // StartLevel > 0, nested call, just Inc StartLevel
      Inc( StartLevel );
  end;
end; // procedure TN_CPUTimer2.Start

//***************************************************** TN_CPUTimer2.Start2 ***
// Start Timer with TimerInd index,
// Variant #2: some additional statements (data prefetching) are executed
//             to minimize time between BegCounter and Exit from
// (save current CPU Clock Counter to Timers[TimerInd].BegCounter)
//
procedure TN_CPUTimer2.Start2( TimerInd: integer );
var
  ltmp: Int64;
begin
  with Items[TimerInd] do
  begin
    if StartLevel = 0 then // first call, Start Timer
    begin
      //***** get in Cash all needed data
      BegCounter := 0;
      ltmp := DeltaCounter;
      N_CPUCounter();
      Stop( TimerInd );
      DeltaCounter := ltmp; // restore initial value

      Inc( NTimes );
      StartLevel := 1;
      BegCounter := N_CPUCounter() + N_EpsCPUTimer2;
    end else // StartLevel > 0, nested call, just Inc StartLevel
      Inc( StartLevel );
  end;
end; // procedure TN_CPUTimer2.Start2

//******************************************************* TN_CPUTimer2.Stop ***
// Stop Timer with TimerInd index
// ( Add to Timers[TimerInd].DeltaCounter number of CPU Clocks after last
//   call of Start( TimerInd ) proc )
//
procedure TN_CPUTimer2.Stop( TimerInd: integer );
begin
  with Items[TimerInd] do
  begin
    if StartLevel <= 1 then
    begin
      StartLevel := 0;
      DeltaCounter := N_CPUCounter() + DeltaCounter - BegCounter;
    end else
      Dec( StartLevel);
  end;
end; // procedure TN_CPUTimer2.Stop

//************************************************** TN_CPUTimer2.StopStart ***
// Stop Timer with TimerInd index and start Timer with TimerInd+1 Index
// Inc TimerInd by 1
// (just for convinience)
//
procedure TN_CPUTimer2.StopStart( var TimerInd: integer );
begin
  Stop( TimerInd );
  Inc(TimerInd);
  Start(TimerInd );
end; // procedure TN_CPUTimer2.StopStart

//******************************************************* TN_CPUTimer2.Show ***
// Show Cuurent state for first NumTimers Timers
//
procedure TN_CPUTimer2.Show( NumTimers: integer );
var
  i, MaxCount, NDigCount: integer;
  Rel, MaxDC: double;
  Str: string;
begin
  MaxDC := 0;
  MaxCount := 1;
  for i := 0 to NumTimers-1 do with Items[i] do
  begin
    if NTimes = 0 then Continue;
    if MaxDC < DeltaCounter then MaxDC := DeltaCounter;
    if MaxCount < NTimes then MaxCount := NTimes;
    if TimerName = '' then TimerName := Format( 'Timer %d', [i] );
    if (Length(TimerName) < 15) and (Length(TimerName) > 0) then
    begin
      TimerName := TimerName + '               ';
      SetLength( TimerName, 15 );
    end
  end;
  NDigCount := integer(Ceil(Log10( MaxCount )));

  for i := 0 to NumTimers-1 do with Items[i] do
  begin
    if NTimes = 0 then Continue; // was not started

    if StartLevel > 0 then // was not stopped
    begin
//      Str := Format( 'Timer %.2d(NTimes=%d) is not stopped!', [i, NTimes] );
//      N_IAdd( Str );
      Continue;
    end;

    Rel := DeltaCounter / MaxDC;
    Str := Format( '%.2d (%3.0f%s %.*d) ', [i, 100*Rel, '%', NDigCount, NTimes] );
    if NTimes >= 1 then
      Str := Str + TimerName + ': ' +
        N_TimeToString( (DeltaCounter/N_CPUFrequency)/N_SecondsInDay, 1);

    if NTimes >= 2 then
      Str := Str + '('+
        N_TimeToString( (DeltaCounter/N_CPUFrequency)/N_SecondsInDay, NTimes)+')';

    Str := Str + N_TimeToString( (DeltaCounter/N_CPUFrequency)/N_SecondsInDay, -1);
    N_IAdd( Str );
  end;
  N_IAdd('');
end; // procedure TN_CPUTimer2.Show


//****************** TN_CPUTimer3 class methods  **********************

//***************************************************** TN_CPUTimer3.Create ***
//
constructor TN_CPUTimer3.Create();
begin
  CPUTimer := TN_CPUTimer1.Create;
end; // constructor TN_CPUTimer3.Create

//**************************************************** TN_CPUTimer3.Destroy ***
//
destructor TN_CPUTimer3.Destroy();
begin
  CPUTimer.Free;
end; // destructor TN_CPUTimer3.Destroy

//****************************************************** TN_CPUTimer3.Start ***
// Start Timer (save Beg value of all used Timers)
//
procedure TN_CPUTimer3.Start();
var
  CreationTime, ExitTime, UserTime, KernelTime: TFileTime;
begin
  BegAbsTime := Time();

  //*** GetTickCount causes Delphi Range error if Windows is working more than 49.7 days!

  //*** Number of milliseconds that have elapsed since Windows was started with accuracy about 15 msec.

//  BegTicksCounter := GetTickCount();
  BegTicksCounter := 1;

  //*** All Process Times are in 100-nanosecond intervals since January 1, 1601
  N_lb := GetProcessTimes( N_ProcHandle, CreationTime, ExitTime,
                                                       KernelTime, UserTime );
  BegProcUserTime   := PInt64(@UserTime)^;
  BegProcKernelTime := PInt64(@KernelTime)^;

  QueryPerformanceCounter( BegPerfCounter );
  CPUTimer.Start();
end; // procedure TN_CPUTimer3.Start

//******************************************************* TN_CPUTimer3.Stop ***
// Stop Timer and calculate all measured times in seconds
// CPUTimer has several nanoseconds abs. accuracy,
// PerformanceCounter - about 300 nanoseconds abs. accuracy, but better relative accuracy
// Tics and Process times - about 15 milliseconds abs. accuracy
//
procedure TN_CPUTimer3.Stop();
var
  EndTicsCounter: integer;
  EndPerfCounter: Int64;
  CreationTime, ExitTime, UserTime, KernelTime: TFileTime;
begin
  CPUTimer.Stop();

  //*** PerformanceCounter frequency is N_PerformanceFrequency
  QueryPerformanceCounter( EndPerfCounter );

  //*** All Process Times are in 100-nanosecond intervals since January 1, 1601
  N_lb := GetProcessTimes( N_ProcHandle, CreationTime, ExitTime,
                                                       KernelTime, UserTime );

  //*** Number of milliseconds that have elapsed since Windows was started with accuracy about 15 msec.
//  EndTicsCounter := GetTickCount();
  EndTicsCounter := 10;

  AbsTimeInSeconds := (Time() - BegAbsTime) * N_SecondsInDay;

  TicsTimeInSeconds := 1.0e-3 * (EndTicsCounter - BegTicksCounter);

  if N_PerformanceFrequency = -1 then
    PerfCounterInSeconds := -1.0
  else
    PerfCounterInSeconds := 1.0*( EndPerfCounter - BegPerfCounter - N_EpsPerfCounter ) /
                                                        N_PerformanceFrequency;
  CPUClockTimeInSeconds := CPUTimer.DeltaCounter / N_CPUFrequency;

  ProcUserTimeInSeconds   := 1.0e-7 * ( PInt64(@UserTime)^   - BegProcUserTime );
  ProcKernelTimeInSeconds := 1.0e-7 * ( PInt64(@KernelTime)^ - BegProcKernelTime );
end; // procedure TN_CPUTimer3.Stop

//************************************************** TN_CPUTimer3.Show(Str) ***
// Convert all measured time interval to OutStr with given Prefix
//   Example:
// Pref : Tics - 5.00 sec., Perf - 4.99 sec., CPUT - 4.99 sec., User - 0.00 nsec., Kern - 0.00 nsec.
// (Prefix : Tics, Performance, CPUClock, ProcessUserTics, ProcessKernelTics)
//
procedure TN_CPUTimer3.Show( Prefix: string; out OutStr: string );
begin
  OutStr := Format( '%s: Abs %s, Tick %s, Perf %s, CPU %s, User %s, Kern %s',
              [Prefix, Trim(N_SecondsToString( AbsTimeInSeconds,        ShowTimeFmt )),
                       Trim(N_SecondsToString( TicsTimeInSeconds,       ShowTimeFmt )),
                       Trim(N_SecondsToString( PerfCounterInSeconds,    ShowTimeFmt )),
                       Trim(N_SecondsToString( CPUClockTimeInSeconds,   ShowTimeFmt )),
                       Trim(N_SecondsToString( ProcUserTimeInSeconds,   ShowTimeFmt )),
                       Trim(N_SecondsToString( ProcKernelTimeInSeconds, ShowTimeFmt ))] );
end; // procedure TN_CPUTimer3.Show(Str)

//**************************************************** TN_CPUTimer3.Show(1) ***
// Show measured time interval with given Prefix
//
procedure TN_CPUTimer3.Show( Prefix: string );
var
  Str: string;
begin
  Show( Prefix, Str );
//  N_IAdd( Str );
end; // procedure TN_CPUTimer3.Show(1)

//**************************************************** TN_CPUTimer3.SS(Str) ***
// Stop and convert to string time interval with given Prefix
//
procedure TN_CPUTimer3.SS( Prefix: string; out OutStr: string );
begin
  Stop();
  Show( Prefix, OutStr );
end; // procedure TN_CPUTimer3.SS(Str)

//****************************************************** TN_CPUTimer3.SS(1) ***
// Stop and Show time interval with given Prefix
//
procedure TN_CPUTimer3.SS( Prefix: string );
begin
  Stop();
  Show( Prefix );
end; // procedure TN_CPUTimer3.SS(1)


    //*****************  TN_GivenMemStream class methods  ************

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_GivenMemStream\Create
//************************************************ TN_GivenMemStream.Create ***
// Memory Stream class constructor with given Memory Buffer
//
//     Parameters
// APGivenMem    - pointer to given memory buffer
// AGivenMemSize - given memory buffer size in bytes
//
constructor TN_GivenMemStream.Create( APGivenMem: Pointer; AGivenMemSize: integer );
begin
  Inherited Create;
  PGivenMem    := APGivenMem;
  GivenMemSize := AGivenMemSize;
  SetPointer( APGivenMem, AGivenMemSize );
end; // Constructor TN_GivenMemStream.Create

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_GivenMemStream\Realloc
//*********************************************** TN_GivenMemStream.Realloc ***
// Prevent from Memory Realloc in Parent class methods
//
//     Parameters
// ANewCapacity - new Stream capacity
// Result       - Returns pointer to memory buffer
//
function TN_GivenMemStream.Realloc( var ANewCapacity: Longint ): Pointer;
begin
  if ANewCapacity = 0 then // used in TMemoryStream.Clear
    Result := nil
  else
    Result := PGivenMem;

  Assert( ANewCapacity <= GivenMemSize, 'Cannot Realloc!' );
end; // function TN_GivenMemStream.Realloc

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_GivenMemStream\SetSize
//*********************************************** TN_GivenMemStream.SetSize ***
// Set Stream size
//
//     Parameters
// ANewSize - new Stream size
//
// Just check that needed ANewSize should not exceed Stream Capacity
//
procedure TN_GivenMemStream.SetSize( ANewSize: Longint );
begin
  Assert( ANewSize <= GivenMemSize, 'ANewSize too big!' );
end; // procedure TN_GivenMemStream.SetSize


//****************** TN_DEQObj class methods  **********************

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_DEQObj\Create
//******************************************************** TN_DEQObj.Create ***
// Double-Ended Queue class constructor
//
//     Parameters
// ANumElemes - Double-Ended Queue сapacity in elements
// AElemSize  - one Queue Element Size in bytes
//
constructor TN_DEQObj.Create( ANumElemes, AElemSize: integer );
begin
  DEQCapacity := ANumElemes;
  DEQElemSize := AElemSize;
  DEQCounter  := 0;  // no Elements in Queue
  DEQFirstInd := -1; // no Elements in Queue
  DEQLastInd  := -1; // no Elements in Queue

  SetLength( DEQElems, DEQCapacity*DEQElemSize );
end; // constructor TN_DEQObj.Create

//******************************************************* TN_DEQObj.Destroy ***
//
destructor TN_DEQObj.Destroy();
begin
  DEQElems := nil;
end; // destructor TN_DEQObj.Destroy

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_DEQObj\AddLastElem
//*************************************************** TN_DEQObj.AddLastElem ***
// Add new last Element
//
//     Parameters
// Result - Returns pointer to added Element (to it's first byte).
//
function TN_DEQObj.AddLastElem(): TN_BytesPtr;
begin
  if DEQLastInd = -1 then // no Elements in Queue
  begin
    DEQFirstInd := 0;
    DEQLastInd  := 0;
    DEQCounter  := 1;
    Result := TN_BytesPtr(@DEQElems[0]);
  end else // Queue is not Empty
  begin
    if DEQCapacity = DEQCounter then // no place for new Element
    begin
      Result := nil; // Error, Element was not Added
      Exit;
    end;

    if DEQLastInd = (DEQCapacity-1) then
      DEQLastInd  := 0
    else
      Inc( DEQLastInd );

    Result := TN_BytesPtr(@DEQElems[DEQLastInd*DEQElemSize]);
    Inc( DEQCounter );
  end;

  FillChar( Result^, DEQElemSize, 0 ); // clear Added Last Element
end; // function TN_DEQObj.AddLastElem

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_DEQObj\GetFirstPtr
//*************************************************** TN_DEQObj.GetFirstPtr ***
// Get pointer to first Element
//
//     Parameters
// Result - Returns pointer to first Element (to it's first byte).
//
function TN_DEQObj.GetFirstPtr(): TN_BytesPtr;
begin
  if DEQFirstInd = -1 then // no Elements in Queue
    Result := nil
  else
    Result := TN_BytesPtr(@DEQElems[DEQFirstInd*DEQElemSize]);
end; // function TN_DEQObj.GetFirstPtr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_DEQObj\RemoveFirstElem
//*********************************************** TN_DEQObj.RemoveFirstElem ***
// Remove first (current) Element
//
//     Parameters
// Result - Returns pointer to next Element (to it's first byte).
//
function TN_DEQObj.RemoveFirstElem(): TN_BytesPtr;
begin
  if DEQFirstInd = -1 then // no Elements in Queue
  begin
    Result := nil; // Error, no First Element to remove
    Exit;
  end else // Queue is not Empty
  begin
    if DEQCounter = 1 then // no place for new Element
    begin
      DEQCounter  := 0;  // no Elements in Queue
      DEQFirstInd := -1; // no Elements in Queue
      DEQLastInd  := -1; // no Elements in Queue
      Result := nil;     // no next First Element
      Exit;
    end;

    if DEQFirstInd = (DEQCapacity-1) then
      DEQFirstInd  := 0
    else
      Inc( DEQFirstInd );

    Result := TN_BytesPtr(@DEQElems[DEQFirstInd*DEQElemSize]);
    Dec( DEQCounter );
  end;
end; // function TN_DEQObj.RemoveFirstElem


//********************************************************* N_GetAlignDelta ***
// Calc and return AlignDelta - integer number
// (used in TN_SRTextLayout.LayoutTextBlocks)
//
function N_GetAlignDelta( const AAlignData: TN_AlignData; AGapInd: integer ): integer;
var
  k, m, Ind, WrkNumGaps: integer;
begin
  with AAlignData do
  begin
    Result := 0;
    if (FreeSpace <= 0) or (NumGaps <= 0) or (AGapInd >= NumGaps) then Exit; // a precaution

    if AGapInd = 0 then
    begin
      case AlignMode of
//      0: Result := 0;               // Align Left or Top
      1: Result := FreeSpace div 2; // Align Center
      2: Result := FreeSpace;       // Align Right or Bottom
//      3: Result := 0;               // Align Justify
      4: Result := FreeSpace div (NumGaps+1); // Align Uniform
      end; // case AlignMode of
      Exit; // all done
    end else // AGapInd > 0
    begin
      if AlignMode <= 2 then Exit; // Result = 0

      if AlignMode = 3 then WrkNumGaps := NumGaps - 1
                       else WrkNumGaps := NumGaps + 1;

      if WrkNumGaps <= 0 then Exit; // not applicable

      //***** Distribute FreeSpace evenly along WrkNumGaps

      Result := FreeSpace div WrkNumGaps;
      m := FreeSpace mod WrkNumGaps;
      if m = 0 then Exit; // Result is OK

      k := round( floor( m*(AGapInd + 0.99999)/WrkNumGaps ) );
      Ind := AGapInd - Round(floor(0.5*WrkNumGaps/m));

      if Ind = round(floor( k*WrkNumGaps/m )) then Inc( Result );

    end; // else // AGapInd > 0
  end; // with AAlignData do
end; // end of function N_GetAlignDelta

//************************************************************* N_NewLength ***
// calc new array Length in advance
//
function N_NewLength( OldLength: integer; MinLength: integer = 0 ): integer;
begin
  if OldLength < 16 then
    Result := 20
  else
    Result := OldLength + OldLength div 2;

  if Result < MinLength then Result := MinLength;
end; // end of function N_NewLength

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SplitMemToStrings
//***************************************************** N_SplitMemToStrings ***
// Split given bytes array to given Strings
//
//     Parameters
// AStrings    - resulting Strings
// APFirstByte - pointer to given array first byte
// ANumBytes   - number of array bytes
//
// Assign given AStrings object from given bufer in memory (APFirstByte, 
// ANumBytes)
//
// Conv to UNICODE!!! Not used now, probably there should be two versions for 
// Ansi and Wide chars
//
procedure N_SplitMemToStrings( AStrings: TStrings; APFirstByte: Pointer;
                                                      ANumBytes: integer );
var
  P, Start, Fin: PChar; // Conv to UNICODE!!!
  S: string;
begin
  Assert( False, 'Not converted to UNICODE!' );

// (Code get from Delphi implementation of Strings.Text property assignment)
  AStrings.BeginUpdate;
  try
    AStrings.Clear;
    P := APFirstByte;
    Fin := P + ANumBytes; // Pointer to first byte AFTER given Bufer

    if P <> nil then
      while P^ <> #0 do
      begin
        Start := P;
        while not (AnsiChar(P^) in [#0, #10, #13]) do
        begin
          Inc(P);
          if P = Fin then Break;
        end;
        SetString(S, Start, P - Start);
        AStrings.Add(S);

        if P = Fin then Break;

        if P^ = #13 then
        begin
          Inc(P);
          if P = Fin then Break;
        end;

        if P^ = #10 then
        begin
          Inc(P);
          if P = Fin then Break;
        end;

      end; // while P^ <> #0 do, if P <> nil then
  finally
    AStrings.EndUpdate;
  end;
end; // procedure N_SplitMemToStrings

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AdlerCheckSum
//****************************************************** N_AdlerCheckSum ***
// Calculate Adler32 CheckSum of given array of bytes
//
//     Parameters
// APFirstByte - pointer to given array first byte
// ANumBytes   - number of array bytes
// Result      - Returns Adler32 CheckSum of array of bytes.
//
// Adler32 is a CheckSum algorithm simular to CRC32, but faster
//
function N_AdlerCheckSum( APFirstByte: Pointer; ANumBytes: integer ): integer;
const
  BASE = 65521; // largest prime smaller than 65536
var
  i, s1, s2: integer;
  PBytes: PByte;
begin
  s1 := 1;
  s2 := 0;
  PBytes := PByte(APFirstByte);

  for i := 0 to ANumBytes-1 do
  begin
    s1 := (s1 + PBytes^) mod BASE;
    s2 := (s2 + s1) mod BASE;
    Inc( PBytes );
  end;

  Result := (s2 shl 16) + s1;
end; // function N_AdlerCheckSum

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AdlerCheckSumStr
//*************************************************** N_AdlerCheckSumStr ***
// Calculate Adler32 CheckSum of given String (Ansi or Unicode)
//
//     Parameters
// AStr   - given string (Ansi or Unicode)
// Result - Returns Adler32 CheckSum
//
// Adler32 is a CheckSum algorithm simular to CRC32, but faster
//
function N_AdlerCheckSumStr( const AStr: String ): Integer;
const
  BASE = 65521; // largest prime smaller than 65536
var
  i, s1, s2, Leng, NumBytes: Integer;
  PBytes: PByte;
begin
  Leng := Length( AStr );

  if Leng = 0 then
  begin
    Result := 0;
    Exit;
  end;

  PBytes := PByte(@AStr[1]);

{$IF SizeOf(Char) = 2} // Wide Chars (>= Delphi 2010)
  NumBytes := 2 * Leng;
{$ELSE} //*************** Ansi Chars (Delphi 7)
  NumBytes := Leng;
{$IFEND}

  s1 := 1;
  s2 := 0;

  for i := 0 to NumBytes-1 do
  begin
    s1 := (s1 + PBytes^) mod BASE;
    s2 := (s2 + s1) mod BASE;
    Inc( PBytes );
  end;

  Result := (s2 shl 16) + s1;
end; // function N_AdlerCheckSumStr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AdlerCheckSumSubStr
//************************************************ N_AdlerCheckSumSubStr ***
// Calculate Adler32 CheckSum of given SubString (Ansi or Unicode)
//
//     Parameters
// AStr      - given string (Ansi or Unicode)
// AFirstInd - Index needed SubString First char
// ALasttInd - Index needed SubString Last char
// Result    - Returns Adler32 CheckSum
//
// Adler32 is a CheckSum algorithm simular to CRC32, but faster
//
function N_AdlerCheckSumSubStr( const AStr: String; const AFirstInd, ALastInd: Integer ): Integer;
const
  BASE = 65521; // largest prime smaller than 65536
var
  i, s1, s2, Leng, NumBytes: Integer;
  PBytes: PByte;
begin
  Leng := Length( AStr );

  if Leng < ALastInd then
  begin
    Result := 0;
    Exit;
  end;

  N_s := Copy( AStr, AFirstInd, ALastInd-AFirstInd+1 );

  PBytes := PByte(@AStr[AFirstInd]);

{$IF SizeOf(Char) = 2} // Wide Chars (>= Delphi 2010)
  NumBytes := 2 * (ALastInd - AFirstInd + 1);
{$ELSE} //*************** Ansi Chars (Delphi 7)
  NumBytes := ALastInd - AFirstInd + 1;
{$IFEND}

  s1 := 1;
  s2 := 0;

  for i := 0 to NumBytes-1 do
  begin
    s1 := (s1 + PBytes^) mod BASE;
    s2 := (s2 + s1) mod BASE;
    Inc( PBytes );
  end;

  Result := (s2 shl 16) + s1;
end; // function N_AdlerCheckSumSubStr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AdlerCheckSumSubStrLow
//************************************************ N_AdlerCheckSumSubStrLow ***
// Calculate Adler32 CheckSum of given SubString (Ansi or Unicode), converted to
// Ansi Lower Case
//
//     Parameters
// AStr      - given string (Ansi or Unicode)
// AFirstInd - Index needed SubString First char
// ALasttInd - Index needed SubString Last char
// Result    - Returns Adler32 CheckSum
//
// Adler32 is a CheckSum algorithm simular to CRC32, but faster
//
function N_AdlerCheckSumSubStrLow( const AStr: String; const AFirstInd, ALastInd: Integer ): Integer;
const
  BASE = 65521; // largest prime smaller than 65536
var
  i, s1, s2, Leng, NumBytes: Integer;
  CurByte: Byte;
  PBytes: PByte;
begin
  Leng := Length( AStr );

  if Leng <= ALastInd then
  begin
    Result := 0;
    Exit;
  end;

  PBytes := PByte(@AStr[AFirstInd]);

{$IF SizeOf(Char) = 2} // Wide Chars (>= Delphi 2010)
  NumBytes := 2 * (ALastInd - AFirstInd + 1);
{$ELSE} //*************** Ansi Chars (Delphi 7)
  NumBytes := ALastInd - AFirstInd + 1;
{$IFEND}

  s1 := 1;
  s2 := 0;

  for i := 0 to NumBytes-1 do
  begin
    CurByte := PBytes^;
    if (CurByte >= Byte('A')) and (CurByte <= Byte('Z')) then Inc( CurByte, 32 ); // Conv to Lower Case

    s1 := (s1 + CurByte) mod BASE;
    s2 := (s2 + s1) mod BASE;
    Inc( PBytes );
  end;

  Result := (s2 shl 16) + s1;
end; // function N_AdlerCheckSumSubStrLow

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_EncryptBytes1
//********************************************************* N_EncryptBytes1 ***
// Encrypt given array of bytes
//
//     Parameters
// APFirstByte - pointer to given array first byte
// ANumBytes   - number of array bytes
// APasWord    - using password string
//
// Encrypt given array bytes by XOR them and given APasWord (encrypted bytes 
// depend on all previous plain bytes).
//
procedure N_EncryptBytes1( APFirstByte: Pointer; ANumBytes: integer; APasWord: AnsiString );
var
  i, j, PWLeng, PrevSum: integer;
  OriginalByte: Byte;
  PBytes: PByte;
  WrkPasWord: TN_BArray;
begin
  PWLeng := Length(APasWord);
  if PWLeng = 0 then Exit; // nothing todo

  // Prepare WrkPasWord Array of bytes it is used to xor bytes
  // and will be changed while encrypting

  SetLength( WrkPasWord, PWLeng );
  move( APasWord[1], WrkPasWord[0], PWLeng );
  PBytes := PByte(APFirstByte);
  PrevSum := 0;
  j := 0; // index in WrkPasWord array

  for i := 1 to ANumBytes do // Encrypt all bytes
  begin
    OriginalByte := PBytes^;
    PBytes^ := PBytes^ xor WrkPasWord[j]; // Encode APFirstByte^
    WrkPasWord[j] := (WrkPasWord[j] + PrevSum + 13) and $FF; // Update WrkPasWord[j]

    Inc( PrevSum, OriginalByte+19 );
    Inc( PBytes );
    Inc( j );
    if j >= PWLeng then j := 0;
  end; // for i := 1 to ANumBytes do // Encrypt all bytes
end; // procedure N_EncryptBytes1

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_DecryptBytes1
//********************************************************* N_DecryptBytes1 ***
// Decrypt given array of bytes
//
//     Parameters
// APFirstByte - pointer to given array first byte
// ANumBytes   - number of array bytes
// APasWord    - using password string
//
// Decrypts given bytes, encryped by N_EncryptBytes1 procedure.
//
procedure N_DecryptBytes1( APFirstByte: Pointer; ANumBytes: integer; APasWord: AnsiString );
var
  i, j, PWLeng, PrevSum: integer;
  OriginalByte: Byte;
  PBytes: PByte;
  WrkPasWord: TN_BArray;
begin
  PWLeng := Length(APasWord);
  if PWLeng = 0 then Exit; // nothing todo
  SetLength( WrkPasWord, PWLeng );
  move( APasWord[1], WrkPasWord[0], PWLeng );
  PBytes := PByte(APFirstByte);
  PrevSum := 0;
  j := 0; // index in WrkPasWord array

  for i := 1 to ANumBytes do // Decrypt all bytes
  begin
    PBytes^ := PBytes^ xor WrkPasWord[j]; // Decode APFirstByte^
    OriginalByte := PBytes^;
    WrkPasWord[j] := (WrkPasWord[j] + PrevSum + 13) and $FF; // Update WrkPasWord[j]

    Inc( PrevSum, OriginalByte+19 );
    Inc( PBytes );
    Inc( j );
    if j >= PWLeng then j := 0;
  end; // for i := 1 to ANumBytes do // Decrypt all bytes
end; // procedure N_DecryptBytes1

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_EncrDecrBytesXOR
//****************************************************** N_EncrDecrBytesXOR ***
// Encrypt or decrypt given array of bytes
//
//     Parameters
// APFirstByte - pointer to given array first byte
// ANumBytes   - number of array bytes
// APasWord    - using password byte
//
// Encrypt or Decrypt given bytes by only XOR them by given APasWord byte (same 
// source bytes are converted to same destination bytes).
//
procedure N_EncrDecrBytesXOR( APFirstByte: Pointer; ANumBytes: integer; APasWord: byte );
var
  i: integer;
  PBytes: PByte;
begin
  PBytes := PByte(APFirstByte);

  for i := 1 to ANumBytes do // Encrypt all bytes by XOR with APasWord
  begin
    PBytes^ := PBytes^ xor APasWord; // Encode byte
    Inc( PBytes );
  end; // for i := 1 to ANumBytes do // Encrypt all bytes by XOR with APasWord
end; // procedure N_EncrDecrBytesXOR

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_EncryptTwoInts
//******************************************************** N_EncryptTwoInts ***
// Encrypt two given integers into 16 bytes record
//
//     Parameters
// AInt1      - first integer to encrypt
// AInt2      - second integer to encrypt
// APResBytes - pointer to 16 bytes record where to put resulting data
// APasWord   - given pasword string
//
// Encrypt two given integers into 16 bytes record using given pasword string.
//
procedure N_EncryptTwoInts( const AInpInt1, AInpInt2: integer;
                                        APResBytes: Pointer; APasWord: AnsiString );
begin
  // first write to APResBytes plain 16 byte: AInt1, AInt2, AInt1, AItn2

  move( AInpInt1, APResBytes^, 4 );                     // AInt1
  move( AInpInt2, (TN_BytesPtr(APResBytes)+4)^, 4 );    // AInt2 after AInt1
  move( APResBytes^, (TN_BytesPtr(APResBytes)+8)^, 8 ); // Copy AInt1, AInt2

  N_EncryptBytes1( APResBytes, 16, APasWord ); // encrypt prpared record
end; // procedure N_EncryptTwoInts

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_DecryptTwoInts
//******************************************************** N_DecryptTwoInts ***
// Decrypt two integers
//
//     Parameters
// AInt1      - first integer to encrypt
// AInt2      - second integer to encrypt
// APResBytes - pointer to 16 bytes record where to put resulting data
// APasWord   - given pasword string
// Result     - Returns TRUE if consistency check is OK
//
// Decrypt two integers (encrypted by N_EncryptTwoInts) and perform consistency 
// check.
//
function N_DecryptTwoInts( out AOutInt1, AOutInt2: integer;
                               APSrcBytes: Pointer; APasWord: AnsiString ): boolean;
var
  IntBuf: Array [0..3] Of integer;
begin
  move( APSrcBytes^, IntBuf, 16 ); // to preserve Source bytes
  N_DecryptBytes1( @IntBuf[0], 16, APasWord );

  AOutInt1 := IntBuf[0];
  AOutInt2 := IntBuf[1];

  Result := True;
  if (AOutInt1 <> IntBuf[2]) or (AOutInt2 <> IntBuf[3]) then Result := False;
end; // function N_DecryptTwoInts

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetPatternIndex
//******************************************************* N_GetPatternIndex ***
// Search given string in Strings object
//
//     Parameters
// AStrings - given Strings Object
// APattern - given string for search
// ABegInd  - search starting index in Strings
// Result   - Returns index of found string or -1 if not found.
//
// Search in given AStrings for given APattren string, starting from given index
// ABegInd and using case sensitive strings comparison is be done.
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

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReplaceSectionInStrings
//*********************************************** N_ReplaceSectionInStrings ***
// Replace section with given name in Text Fragms Strings
//
//     Parameters
// ASrcStrings  - source Text Fragms Strings Object
// AResStrings  - resulting Text Fragms Strings Object
// ASection     - Strings Object with Text Fragms section new value
// ASectionName - Text Fragms section name
//
// Replace section with ASectionName in ASrcStrings by given ASection, resulting
// Strings (with replaced section) are in AResStrings
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

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetSectionFromStrings
//************************************************* N_GetSectionFromStrings ***
// Get section with given name from Text Fragms Strings
//
//     Parameters
// AStrings     - source Text Fragms Strings Object
// ASection     - resulting Strings Object with Text Fragms section
// ASectionName - Text Fragms section name
// ABegInd      - section search starting index in Text Fragms Strings
// Result       - Returns index of Text Fragms Strings element next to found 
//                section  or -1 if section not found.
//
// Fill ASection by section with ASectionName from AStrings, begin search from 
// given ABegInd, return string index after found section.
//
function N_GetSectionFromStrings( AStrings, ASection: TStrings;
                             ASectionName: string; ABegInd: integer ): integer;
var
  i, IMax, IBeg, PatLeng: integer;
  CurStr, Pattern: string;
begin
  Result := -1; // not found flag
  ASection.Clear;

  Pattern := '[[' + ASectionName + ']]';
  IBeg := N_GetPatternIndex( AStrings, Pattern, ABegInd ) + 1;

  if IBeg = 0 then Exit; // Pattern not found!

  Pattern := '[[/' + ASectionName + ']]';
  PatLeng := Length(Pattern);
  IMax := AStrings.Count -1;

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

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReplaceSectionInFile
//************************************************** N_ReplaceSectionInFile ***
// Replace section with given name in Text Fragms Data File
//
//     Parameters
// AFName       - Text Fragms data file path
// ASection     - Strings Object with Text Fragms section new value
// ASectionName - Text Fragms section name
// APasWord     - password for Data File decryption
//
// Replace section with ASectionName by given ASection in given plain or 
// encrypted Text Fragms Data File AFName
//
procedure N_ReplaceSectionInFile( AFName: string; ASection: TStrings;
                                  ASectionName: string;
                                  APasWord: AnsiString = '' );
var
  SL1, SL2: TStringList;
  CreateParams: TK_DFCreateParams;
begin
  SL1 := TStringList.Create;
  SL2 := TStringList.Create;

  K_LoadStringsFromDFile( SL1, AFName, @CreateParams, APasWord );

  N_ReplaceSectionInStrings( SL1, SL2, ASection, ASectionName );

  K_SaveStringsToDFile( SL2, AFName, CreateParams );

  SL1.Free;
  SL2.Free;
end; // procedure N_ReplaceSectionInFile

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetSectionFromFile
//**************************************************** N_GetSectionFromFile ***
// Get section with given name from Text Fragms Data File
//
//     Parameters
// AFName       - Text Fragms data file path
// ASection     - resulting Strings Object with Text Fragms section
// ASectionName - Text Fragms section name
// APasWord     - password for Data File decryption
//
// Fill ASection by section with ASectionName from given plain or encrypted Text
// Fragms Data File AFName
//
procedure N_GetSectionFromFile( AFName: string; ASection: TStrings;
                                ASectionName: string; APasWord: AnsiString = '' );
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  K_LoadStringsFromDFile( SL, AFName, nil, APasWord );
  N_GetSectionFromStrings( SL, ASection, ASectionName );
  SL.Free;
end; // procedure N_GetSectionFromFile

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ConvToGray
//************************************************************ N_ConvToGray ***
// Convert given RGB color to Gray value
//
//     Parameters
// AColor - RGB color
// Result - Returns integer value from 0 to 255 (Gray).
//
function N_ConvToGray( AColor: integer ): integer;
var
  r, g, b: byte;
begin
  r := AColor and $FF;
  g := (AColor shr 8)  and $FF;
  b := (AColor shr 16) and $FF;

  Result := Round( (r + g + b)/3.0 );
end; // function N_ConvToGray

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_FindFileExt
//*********************************************************** N_FindFileExt ***
// Find File name extension index
//
//     Parameters
// AExtArray - array of strings with possible file extensions
// AFName    - file name
// Result    - Returns index of given array element with extension equal to 
//             given file name extension or -1 if no found.
//
// Find given File Extension in given array of strings with possible extensions.
// Extensions in AExtArray shoud be without period and in Upper Case.
//
function N_FindFileExt( AExtArray: array of string; AFName: string ): integer;
var
  i: integer;
  FileExt: string;
begin
  FileExt := UpperCase( ExtractFileExt( AFName ) );
  Delete( FileExt, 1, 1 );

  Result := -1; // "not found" flag

  for i := 0 to High(AExtArray) do
  begin

    if FileExt = AExtArray[i] then
    begin
      Result := i;
      Exit;
    end;

  end; // for i := 0 to High(AExtArray) do
end; // function N_FindFileExt

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_KeyIsDown
//************************************************************* N_KeyIsDown ***
// Check if given Virtual Key is down now
//
//     Parameters
// AVKey  - Virtual Key Code
// Result - Returns TRUE if given Virtual Key is Down now.
//
// Checks asyncroniously if given Virtual VKey is Down now
//
function N_KeyIsDown( AVKey: integer ): boolean;
begin
  Result := (GetAsyncKeyState(AVKey) and $8000) <> 0;
  if (AVKey = VK_SHIFT)   and N_SkipShiftKeyIsDown then Result := False;
  if (AVKey = VK_CONTROL) and N_SkipCtrlKeyIsDown  then Result := False;
end; // end of function N_KeyIsDown

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetFileFmtByExt
//******************************************************* N_GetFileFmtByExt ***
// Get Image File Format by file name extention
//
//     Parameters
// AFName - given file name
// Result - Returns Image File Format enumeration element (if not proper file 
//          name then resulting value is imffUnknown).
//
// Get Image File Format enumeration element by File Name Extention
//
function N_GetFileFmtByExt( AFName: string ): TN_ImageFileFormat;
var
  Ext: string;
begin
  Ext := UpperCase( ExtractFileExt( AFName ) );

       if Ext = '.BMP'  then Result := imffBMP
  else if Ext = '.GIF'  then Result := imffGIF
  else if Ext = '.JPG'  then Result := imffJPEG
  else if Ext = '.JPEG' then Result := imffJPEG
  else if Ext = '.EMF'  then Result := imffEMF
  else if Ext = '.EMZ'  then Result := imffEMF
  else if Ext = '.SVG'  then Result := imffSVG
  else if Ext = '.SVGZ' then Result := imffSVG
  else if Ext = '.HTM'  then Result := imffVML
  else if Ext = '.HTML' then Result := imffVML
  else  Result := imffUnknown;
end; // end of function N_GetFileFmtByExt

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetFileFmtByHeader
//**************************************************** N_GetFileFmtByHeader ***
// Get Image File Format by file header data
//
//     Parameters
// APHeader - pointer to file header data
// Result   - Returns Image File Format enumeration element (if not proper file 
//            header then resulting value is imffUnknown).
//
// At least first 10 bytes of file header are used to detect Image File Format:
//#F
//  'JFIF' in bytes 7-10 for JPEG files
//  'GIF8' in bytes 0-3  for GIF Files
//  'BM'   in bytes 0-1  for BMP Files
//  Int(1), 100-200 in bytes 0-7  for EMF Files
//#/F
//
function N_GetFileFmtByHeader( APHeader: Pointer ): TN_ImageFileFormat;
var
  AnsiStr: Ansistring;
begin
  Result := imffUnknown;

  AnsiStr := 'GIF8';
  if PInteger(APHeader)^ = PInteger(@AnsiStr[1])^ then
  begin
    Result := imffGIF;
    Exit;
  end;

  AnsiStr := 'JFIF';
  if PInteger(PAnsiChar(APHeader)+6)^ = PInteger(@AnsiStr[1])^ then
  begin
    Result := imffJPEG;
    Exit;
  end;

  AnsiStr := 'BM';
  if PWord(APHeader)^ = PWord(@AnsiStr[1])^ then
  begin
    Result := imffBMP;
    Exit;
  end;

  if (PInteger(APHeader)^ = 1) and
     (PInteger(PAnsiChar(APHeader)+4)^ >= 100) and
     (PInteger(PAnsiChar(APHeader)+4)^  < 200)    then
  begin
    Result := imffEMF;
    Exit;
  end;

end; // end of function N_GetFileFmtByHeader

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_UpdateRFResAndSize
//**************************************************** N_UpdateRFResAndSize ***
// Prepare raster file resolution and size in pixels and millimeters
//
//     Parameters
// ASizePix - raster size (width,height) in pixels
// ASizemm  - raster size (width,height) in millimeters
// AResDPI  - resolution (along horizontal and vertical)
//
// Calculate zero fields of given Raster File Sizes and Resolution (non zero 
// fields remains the same)
//
procedure N_UpdateRFResAndSize( var ASizePix: TPoint; var ASizemm: TFPoint;
                                                      var AResDPI: TFPoint );
var
  WrkResDPI: TFPoint;
begin

  WrkResDPI := AResDPI;
  if WrkResDPI.X = 0 then WrkResDPI.X := 72;
  if WrkResDPI.Y = 0 then WrkResDPI.Y := 72;

  if ASizePix.X = 0 then //***************** Calc SizePix
  begin
    if ASizemm.X = 0 then ASizemm.X := 100; // a precaution
    if ASizemm.Y = 0 then ASizemm.Y := 100; // a precaution

    ASizePix.X := Round( ASizemm.X*WrkResDPI.X/25.4 );
    ASizePix.Y := Round( ASizemm.Y*WrkResDPI.Y/25.4 );
  end;

  if ASizemm.X = 0 then //***************** Calc Sizemm
  begin
    ASizemm.X := Round( 25.4*ASizePix.X/WrkResDPI.X );
    ASizemm.Y := Round( 25.4*ASizePix.Y/WrkResDPI.Y );
  end;

  if AResDPI.X = 0 then AResDPI.X := 25.4*ASizePix.X/ASizemm.X;
  if AResDPI.Y = 0 then AResDPI.Y := 25.4*ASizePix.Y/ASizemm.Y;

end; // end of procedure N_UpdateRFResAndSize

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_PrepImageFilePar
//****************************************************** N_PrepImageFilePar ***
// Prepare resulting Image (Raster or EMF) File Parameters by source Parameters
//
//     Parameters
// APInpIFP - pointer to source Image File Parameters
// APInpIFP - pointer to resulting Image File Parameters
//
// Prepare APOutIFP^ (on input and output) by given APInpIFP^: copy all defined 
// (non zero) in APInpIFP^ fields to APOutIFP^
//
procedure N_PrepImageFilePar( APInpIFP, APOutIFP: TN_PImageFilePar );
begin
  if APInpIFP^.IFPImFileFmt <> imffUnknown then APOutIFP^.IFPImFileFmt := APInpIFP^.IFPImFileFmt;
  if APInpIFP^.IFPPixFmt    <> pfDevice    then APOutIFP^.IFPPixFmt := APInpIFP^.IFPPixFmt;

  if APInpIFP^.IFPSizePix.X  <> 0 then
  begin
   APOutIFP^.IFPSizePix    := APInpIFP^.IFPSizePix;
   APOutIFP^.IFPVisPixRect := APInpIFP^.IFPVisPixRect;
  end;

  if APInpIFP^.IFPSizemm.X   <> 0 then APOutIFP^.IFPSizemm  := APInpIFP^.IFPSizemm;
  if APInpIFP^.IFPResDPI.X   <> 0 then APOutIFP^.IFPResDPI  := APInpIFP^.IFPResDPI;

  if APInpIFP^.IFPTranspColor <> N_EmptyColor then APOutIFP^.IFPTranspColor := APInpIFP^.IFPTranspColor;
  if APInpIFP^.IFPJPEGQuality <> 0 then APOutIFP^.IFPJPEGQuality := APInpIFP^.IFPJPEGQuality;
  if APInpIFP^.IFPComprLevel  <> 0 then APOutIFP^.IFPComprLevel  := APInpIFP^.IFPComprLevel;
end; // procedure N_PrepImageFilePar

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_PrepTextFilePar
//******************************************************* N_PrepTextFilePar ***
// Prepare resulting Text File Parameters by source Parameters
//
//     Parameters
// APInpIFP - pointer to source Text File Parameters
// APInpIFP - pointer to resulting Text File Parameters
//
// Prepare APOutTFP^ (on input and output) by given APInpTFP^: copy all defined 
// (non zero) in APInpTFP^ fields to APOutTFP^
//
procedure N_PrepTextFilePar( APInpTFP, APOutTFP: TN_PTextFilePar );
begin
  if APInpTFP^.TFPRowLength <> 0 then APOutTFP^.TFPRowLength := APInpTFP^.TFPRowLength;
  if APInpTFP^.TFPEncoding  <> tfeANSI then APOutTFP^.TFPEncoding := APInpTFP^.TFPEncoding;
  if APInpTFP^.TFPStr1      <> '' then APOutTFP^.TFPStr1     := APInpTFP^.TFPStr1;
  if APInpTFP^.TFPHeader    <> '' then APOutTFP^.TFPHeader   := APInpTFP^.TFPHeader;
  if APInpTFP^.TFPIntType   <> 0  then APOutTFP^.TFPIntType  := APInpTFP^.TFPIntType;
  if APInpTFP^.TFPPatFName  <> '' then APOutTFP^.TFPPatFName := APInpTFP^.TFPPatFName;
end; // procedure N_PrepTextFilePar

{
//*****************************************************  N_PrepFile1Params  ***
// Prepare APOutFP^ (on input and output) by given APInpFP^:
// copy all defined (non zero) in APInpFP^ fields to APOutFP^
//
procedure N_PrepFile1Params( APInpFP, APOutFP: TN_PFile1Params );
begin
  // not implemented yet
end; // procedure N_PrepFile1Params
}

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetOLEServer
//********************************************************** N_GetOLEServer ***
// Get OLE Server by given name
//
//     Parameters
// AServerName - server name
// APIsCreated - pointer to boolean variable which resulting value should be set
//               to TRUE if new Server was created
// Result      - Returns OLE Server (running or just created).
//
function N_GetOLEServer( AServerName: string; APIsCreated: PBoolean ): Variant;
var
  HR: HResult;
  Unknown: IUnknown;
begin
  HR := GetActiveObject( ProgIDToClassID( AServerName ), nil, Unknown );
  if HR = MK_E_UNAVAILABLE then
  begin
    Result := CreateOLEObject( AServerName );
    if APIsCreated <> nil then APIsCreated^ := True;
  end else
  begin
    Result := GetActiveOLEObject( AServerName );
    if APIsCreated <> nil then APIsCreated^ := False;
  end;
end; // function N_GetOLEServer

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CreateCFPArray
//***************************************************** N_CreateCFPArray ***
// Create and initialize Cell Formats Params Array
//
//     Parameters
// ANumElemes - Number of Arra Element
// AFmtFlags  - Format Flags (for all elems)
// Result     - Returns created Cell Formats Params Array
//
function N_CreateCFPArray( ANumElemes: integer; AFmtFlags: TN_CellFmtFalgs ): TN_CFPArray;
var
  i: integer;
begin
  SetLength( Result, ANumElemes );

  for i := 0 to High(Result) do
  with Result[i] do
  begin
    CFPFlags     := [];
    CFPWidthCoef := 0;
  end; // for i := 0 to High(Result) do

end; // function N_CreateCFPArray

//********************************** constants for N_GetIntPropisyu
var
  N_Edinm: array[0..20] of string = ( '','один','два','три','четыре','пять','шесть','семь','восемь','девять',
                                      'десять','одиннадцать','двенадцать','тринадцать','четырнадцать',
                                      'пятнадцать','шестнадцать','семнадцать','восемнадцать','девятнадцать',
                                      'двадцать' );
  N_Edinf: array[0..20] of string = ( '','одна','две','три','четыре','пять','шесть','семь','восемь','девять',
                                      'десять','одиннадцать','двенадцать','тринадцать','четырнадцать',
                                      'пятнадцать','шестнадцать','семнадцать','восемнадцать','девятнадцать',
                                      'двадцать' );
  N_Des: array[0..9] of string = ( '','десять','двадцать','тридцать','сорок','пятьдесят','шестьдесят',
                                   'семьдесят','восемьдесят','девяносто' );
  N_Sot: array[0..9] of string = ( '','сто','двести','триста','четыреста','пятьсот','шестьсот','семьсот',
                                   'восемьсот','девятьсот' );

  N_Tys:  array[0..2] of string = ( 'тысяча',   'тысячи',    'тысяч' );
  N_Mln:  array[0..2] of string = ( 'миллион',  'миллиона',  'миллионов' );
  N_Mlrd: array[0..2] of string = ( 'миллиард', 'миллиарда', 'миллиардов' );

//******************************************************** N_GetIntPropisyu ***
// Get given positive Integer numeral text in Russian
//
//     Parameters
// AInt - given Integer value
// Result - Returns given positive Integer numeral text in Russian
//
function N_GetIntPropisyu( AInt: integer ): string;
var
  CurNum, mlrd, mln, tys: integer;
  Res: string;
  Label Fin;

  function SclonInd( ANum: integer ): integer; // local
  // Get Sclon Index, 1 <= ANum <= 999
  var
    ed, eddes: integer;
  begin
    ed    := ANum mod 10;
    eddes := ANum mod 100;

    if (eddes >= 10) and (eddes <= 20) then Result := 2 // тысяч
    else if (ed = 1) then Result := 0 // тысяча
    else if (ed >= 2) and (ed <= 4) then Result := 1 // тысяча
    else Result := 2 // тысяч
  end; // function SclonInd - local

  function Prop1_999( ANum: integer; ATokens: array of string ): string; // local
  // Return given posistive integer number AInt 'propisju' in Russian as string
  // 1 <= ANum <= 999
  // ATokens - числа от 1 до 20 нужного рода ( N_Edinm или N_Edinf )
  var
    ed, des, eddes, sotni: integer;
  begin
    Result := '';
    if ANum = 0 then Exit;

    ed    := ANum mod 10;  // единицы (младший десятичный разряд)
    eddes := ANum mod 100; // единицы и десятки (два младших десятичных разряда)
    des   := eddes div 10; // количество десятков (второй десятичный разряд)
    sotni := ANum div 100; // количество сотен (третий десятичный разряд)

    if sotni >= 1 then Result := N_Sot[sotni] + ' ';

    if eddes <= 20 then Result := Result + ATokens[eddes]
    else Result := Result + N_Des[des] + ' ' + ATokens[ed];

  end; // function Prop1_999 - local

begin //****************************** main body of N_GetIntPropisyu
  Result := '';

  if AInt = 0 then
  begin
    Result := 'ноль';
    Exit;
  end;

  CurNum := AInt;

  if CurNum >= 1e9 then // миллиарды
  begin
    mlrd := CurNum div 1000000000; // количество миллиардов
    Res := Prop1_999( mlrd, N_Edinm );
    Res := Res + ' ' + N_Mlrd[SclonInd(mlrd)];
    CurNum := CurNum mod 1000000000;
  end;
  if CurNum = 0 then goto Fin;

  if CurNum >= 1e6 then // миллионы
  begin
    mln := CurNum div 1000000; // количество миллионов ( <= 999 )
    if Res <> '' then Res := Res + ' ';
    Res := Res + Prop1_999( mln, N_Edinm );
    Res := Res + ' ' + N_Mln[SclonInd(mln)];
    CurNum := CurNum mod 1000000;
  end;
  if CurNum = 0 then goto Fin;

  if CurNum >= 1e3 then // тысячи
  begin
    tys := CurNum div 1000; // количество тысяч ( <= 999 )
    if Res <> '' then Res := Res + ' ';
    Res := Res + Prop1_999( tys, N_Edinf );
    Res := Res + ' ' + N_Tys[SclonInd(tys)];
    CurNum := CurNum mod 1000;
  end;
  if CurNum = 0 then goto Fin;

  if Res <> '' then Res := Res + ' ';
  Res := Res + Prop1_999( CurNum, N_Edinm );

  Fin: //*****************
  Result := Res;
end; // function N_GetIntPropisyu

//****************************************************** N_GetSampleRusText ***
// Generate sample Russian Text, based on given number ANum,
// that contains given number of characters ANumChars and
// begins with given APrefix
//
function N_GetSampleRusText( APrefix: string; ATextInt, ANumChars: integer ): string;
begin
  Result := APrefix;
  if ANumChars > 1e7 then ANumChars := Round(1e7); // a precaution

  if ANumChars = 1 then // only ATextInt propis'ju
  begin
    Result := Result + N_GetIntPropisyu( ATextInt );
    Exit;
  end; // if ANumChars = 1 then // only ATextInt propis'ju

  while True do
  begin
    if Length(Result) > ANumChars then Break;
    Result := Result + ' Фрагмент номер ' + N_GetIntPropisyu( ATextInt ) + '.';
    if Length(Result) > ANumChars then Break;
    Result := Result + ' Содержание фрагмента (' + IntToStr( ATextInt ) + ').';
  end; // while True do
end; // function N_GetSampleRusText

//******************************************************* N_GetSampleString ***
// Get Sample string, created by given Params
//
//     Parameters
// APParams - Pointer to given Params
// Result - Returns created string
//
function N_GetSampleString( APParams: TN_PGSSParams ): string;
var
  NeededNumChars, OneDimInd: integer;
begin
  with APParams^ do
  begin
    OneDimInd := GSSPRowInd*GSSPNumCols + GSSPColInd;

    case GSSPMode and $0F of
      0: Result := Format( '%d',  [OneDimInd] );
      1: Result := Format( '%d ', [OneDimInd] ) + N_GetIntPropisyu( OneDimInd );
      2: Result := Format( '(%d:%d)',  [GSSPRowInd,GSSPColInd] );
      3: Result := Format( '(%d:%d) ', [GSSPRowInd,GSSPColInd] ) +
                                              N_GetIntPropisyu( GSSPRowInd ) + ' : ' +
                                              N_GetIntPropisyu( GSSPColInd );
    end; // case GSSPMode and $0F of

    if (GSSPMode and $010) <> 0 then // set exact Number of Chars
    begin
      NeededNumChars := RandomRange( GSSPMinChars, GSSPMaxChars );
      if Length(Result) < NeededNumChars then // repeat same text
        Result := DupeString( Result + '***', NeededNumChars div Length(Result) + 1 );

      Result := LeftStr( Result, NeededNumChars );
    end else // any size in (GSSPMinChars,GSSPMaxChars) interval is OK
    begin
      if Length(Result) < GSSPMinChars then // repeat same text
        Result := DupeString( Result + '***', GSSPMinChars div Length(Result) + 1 );

      Result := LeftStr( Result, GSSPMaxChars );
    end; // else // any size in (GSSPMinChars,GSSPMaxChars) interval is OK

  end; // with APParams^ do
end; // function N_GetSampleString

//*************************************************** N_CreateSampleStrMatr ***
// Create Sample AStrMatr by given Params
//
//     Parameters
// AStrMatr  - resulting AStrMatr (on iput and output, may be nil)
// ANX       - number of columns needed in AStrMatr
// ANY       - number of rows needed in AStrMatr
// AMinChars - min number of chars in each cell
// AMaxChars - max number of chars in each cell
//
procedure N_CreateSampleStrMatr( var AStrMatr: TN_ASArray; APParams: TN_PGSSParams );
var
  ix, iy: integer;
begin
  with APParams^ do
  begin
    SetLength( AStrMatr, GSSPNumRows );

    for iy := 0 to High(AStrMatr) do // along AstrMatr rows
    begin
      SetLength( AStrMatr[iy], GSSPNumCols );

      for ix := 0 to High(AStrMatr[iy]) do // along columns of iy-th row
      begin
        GSSPColInd := ix;
        GSSPRowInd := iy;
        AStrMatr[iy][ix] := N_GetSampleString( APParams );
      end; // for ix := 0 to High(AStrMatr[iy]) do // along columns of iy row

    end; // for iy := 0 to High(AStrMatr) do // along AstrMatr rows
  end; // with Params do
end; // procedure N_CreateSampleStrMatr

//********************************************* N_CreateStrMatrFromPointers ***
// Create StrMatr From given Array of Pointers to another SMatr Rows
//
//     Parameters
// AStrMatr  - resulting AStrMatr (on iput and output, may be nil)
// ANX       - number of columns needed in AStrMatr
// ANY       - number of rows needed in AStrMatr
// AMinChars - min number of chars in each cell
// AMaxChars - max number of chars in each cell
//
procedure N_CreateStrMatrFromPointers( var AStrMatr: TN_ASArray; APointers: TN_PArray );
var
  i: integer;
begin
  SetLength( AStrMatr, Length(APointers) );

  for i := 0 to High(APointers) do
    AStrMatr[i] := TN_PtrToSArray(APointers[i])^;
end; // procedure N_CreateStrMatrFromPointers

//*********************************************************  N_PrepSPLCode  ***
// Prepare and return given ASPLCode:
// - replace #$0D by #$0A0D
// - replace Word quotes to SPL Quotes
//
function N_PrepSPLCode( ASPLCode: string ): string;
var
  i, code: integer;
  SL: TStringList;
  ConvChar, LeadingSpaces: boolean;
begin
  SL := TStringList.Create;
  SL.Text := ASPLCode; // convert #$D by #$D#$A
  Result := SL.Text;
  ConvChar := True;
  LeadingSpaces := True;

  for i := 1 to Length(Result) do // convert quotes
  begin
    code := integer(Result[i]);

    if ConvChar then // convert cyrillic characters in first token to latin
    begin
      if code <> $20 then LeadingSpaces := False;

      // later implement recoding table (XLat table)

      if (code = integer(Char('А'))) or (code = integer(Char('а'))) then Result[i] := Char('A');
      if (code = integer(Char('В'))) or (code = integer(Char('в'))) then Result[i] := Char('B');
      if (code = integer(Char('С'))) or (code = integer(Char('с'))) then Result[i] := Char('C');
      if (code = integer(Char('Е'))) or (code = integer(Char('е'))) then Result[i] := Char('E');
      if (code = integer(Char('Н'))) or (code = integer(Char('н'))) then Result[i] := Char('H');
      if (code = integer(Char('К'))) or (code = integer(Char('к'))) then Result[i] := Char('K');
      if (code = integer(Char('М'))) or (code = integer(Char('м'))) then Result[i] := Char('M');
      if (code = integer(Char('Р'))) or (code = integer(Char('р'))) then Result[i] := Char('P');
      if (code = integer(Char('Т'))) or (code = integer(Char('т'))) then Result[i] := Char('T');
      if (code = integer(Char('Х'))) or (code = integer(Char('х'))) then Result[i] := Char('X');

      if (code = $20) and not LeadingSpaces then ConvChar := False;
    end; // if ConvChar then // convert cyrillic characters in first token to latin

    if (code = 147) or (code = 148) or (code = 171) or (code = 187) then
      Result[i] := Char( 34 ); // double quote character

    if (code = 145) or (code = 146) then
      Result[i] := Char( 39 ); // single quote character
  end; // for i := 1 to Length(Result) do // convert quotes

end; // function N_PrepSPLCode

//********************************************************** N_UseClipboard ***
// Return True if Windows Clipboard should be used instead of given AFileName
//
function N_UseClipboard( AFileName: string ): boolean;
var
  Str: string;
begin
  Str := ChangeFileExt( UpperCase(ExtractFileName( AFileName )), '' );
  Result := False;
  if Str = 'CLIPBOARD' then Result := True;
end; // function N_UseClipboard

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SortPointers(FuncOfObj)
//*********************************************** N_SortPointers(FuncOfObj) ***
// Sort given array of pointers to ordered data in ascending order
//
//     Parameters
// APtrsArray   - given array of pointers (unsorted on input and sorted on 
//                output)
// ACompareFunc - compare data function of object
//
// CompareFunc - Function( Ptr1, Ptr2 ) of Object for comparing any two 
// Elements: CompareFunc = -1 if Ptr1^ < Ptr2^ CompareFunc =  0 if Ptr1^ = Ptr2^
// CompareFunc = +1 if Ptr1^ > Ptr2^
//
procedure N_SortPointers( APtrsArray: TN_PArray; ACompareFunc: TN_CompFuncOfObj );
var
  PA1, PA2, PAswap: array of TN_BytesPtr;
  IA1, IA2, IASwap: array of integer;
  WrkPtr: Pointer;
  i1, i2, j1, j2, k1, Endj1, Endk1, HighIA1, ElemCount, CompRes: integer;
begin
  PAswap := nil; // to avoid warning
  IAswap := nil; // to avoid warning

  ElemCount := Length( APtrsArray );
  if ElemCount <= 1 then Exit; // nothing to sort

  if ElemCount = 2 then // just for speed
  begin
    if ACompareFunc( APtrsArray[0], APtrsArray[1] ) > 0 then // swap
    begin
      WrkPtr := APtrsArray[0];
      APtrsArray[0] := APtrsArray[1];
      APtrsArray[1] := WrkPtr;
    end;
    Exit;
  end; // if ElemCount = 2 then // just for speed

  PAswap := nil; // to avoid warnings
  IAswap := nil; // to avoid warnings

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

    if HighIA1 = 0 then // only one group in PA1,IA1 left,
    begin               // all pointers are sorted, copy them back to PtrsArray
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

        CompRes := ACompareFunc( PA1[j1], PA1[k1] );
        if CompRes < 0 then
        begin    // PA1[j1]^ < PA1[k1]^
          PA2[j2] := PA1[j1];
          Inc(j1);
        end else // PA1[j1]^ >= PA1[k1]^
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

end; // end of procedure N_SortPointers(FuncOfObj)

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetPtrsArrayToElems
//*************************************************** N_GetPtrsArrayToElems ***
// Get array of pointers to all elements of some data array
//
//     Parameters
// APBegElem  - pointer to initial Element of some data array
// AElemCount - Elements Count (length of array of elements and length of 
//              resulting pointers array)
// AElemSize  - one Element size in bytes - SizeOf(one array element)
//
// Create and return array of pointers to all elements of some array (result can
// be used in N_SortPointers procedure)
//
function N_GetPtrsArrayToElems( APBegElem: Pointer;
                                AElemCount, AElemSize: integer ): TN_PArray;
var
  i: integer;
begin
  SetLength( Result, AElemCount );

  for i := 0 to AElemCount-1 do // fill resulting Array
    Result[i] := TN_BytesPtr(APBegElem) + AElemSize*i;
end; // end of procedure function N_GetPtrsArrayToElems

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_PtrsArrayToElemInds
//*************************************************** N_PtrsArrayToElemInds ***
// Convert given array of pointers into Indices of some array elements
//
//     Parameters
// APIndices  - pointer to first resulting index, (Number of resulting indices 
//              equal to Length(PtrsArray)
// APtrsArray - given array of pointers to elements of some array
// APBegElem  - pointer to initial Element of some array elements
// AElemSize  - one Element size in bytes - SizeOf(one array element)
//
procedure N_PtrsArrayToElemInds( APIndices: PInteger; APtrsArray: TN_PArray;
                                        APBegElem: Pointer; AElemSize: Integer );
var
  i: Integer;
begin
  for i := 0 to High(APtrsArray) do // fill resulting indeces
  begin
    APIndices^ := ( Integer(APtrsArray[i]) - Integer(APBegElem) ) div AElemSize;
    Inc( APIndices );
  end;
end; // end of procedure N_PtrsArrayToElemInds

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ElemIndsToPtrsArray
//*************************************************** N_ElemIndsToPtrsArray ***
// Convert given Indices of some array elements into resulting array of pointers
// to same elements
//
//     Parameters
// APBegElem - Pointer to (beg of) initial Element of some array elements
// AElemSize - one Element size in bytes - SizeOf(one array element)
// APIndices - pointer to first source index
// ANumInds  - Number of source Indices (and resulting array length)
// Reslt     - Returns resulting array of pointers to some array of elements.
//
function N_ElemIndsToPtrsArray( APBegElem: Pointer; AElemSize: Integer;
                                APIndices: PInteger; ANumInds: Integer ): TN_PArray;
var
  i : Integer;
begin
  SetLength( Result, ANumInds );

  for i := 0 to ANumInds-1 do // fill reulting array of pointers
  begin
    Result[i] := TN_BytesPtr(APBegElem) + APIndices^ * AElemSize;
    Inc( APIndices );
  end;
end; // end of procedure N_ElemIndsToPtrsArray

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_BuildSortedElemInds(All)
//********************************************** N_BuildSortedElemInds(All) ***
// Build sorted Indices of ALL elements of some array
//
//     Parameters
// APIndices    - pointer to first resulting index, (Number of resulting indices
//                is ElemCount)
// APBegElem    - pointer to first Element of array
// AElemCount   - Elements Count (Length of array of elements and Number of 
//                resulting indices)
// AElemSize    - one Element size in bytes - SizeOf(one array element)
// ACompareFunc - Function( Ptr1, Ptr2 ) of Object for comparing any two 
//                Elements
//
procedure N_BuildSortedElemInds( APIndices: PInteger; APBegElem: Pointer;
                  AElemCount, AElemSize: integer; ACompareFunc: TN_CompFuncOfObj );
var
  PtrsArray: TN_PArray;
begin
  PtrsArray := N_GetPtrsArrayToElems( APBegElem, AElemCount, AElemSize );
  N_SortPointers( PtrsArray, ACompareFunc );
  N_PtrsArrayToElemInds( APIndices, PtrsArray, APBegElem, AElemSize );
end; // end of procedure N_BuildSortedElemInds(All)

{
//********************************************* N_BuildSortedElemInds(Some) ***
// Build sorted Indices of SOME elements of some Array
// ( former K_BuildSortIndex0 is it needed? )
//
// PIndices    - pointer to first resulting index,
//                 (Number of resulting indices is ElemCount)
// PBegElem    - Pointer to (beg of) first Element of Array
// ElemCount   - Elements Count (Length of array of elements and Number of resulting indices)
// ElemSize    - one Element size in bytes - SizeOf(one array element)
// CompareFunc - Function( Ptr1, Ptr2 ) of Object for comparing any two Elements
//
procedure N_BuildSortedElemInds( PIndices: PInteger; PtrsArray: TN_PArray; PBegElem: Pointer;
                  ElemCount, ElemSize: integer; CompareFunc: TN_CompFuncOfObj );
begin
  N_SortPointers( PtrsArray, CompareFunc );
  N_PtrsArrayToElemInds( PIndices, PtrsArray, PBegElem, ElemSize );
end; // end of procedure N_BuildSortedElemInds(Some)
}

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SortArrayOfElems
//****************************************************** N_SortArrayOfElems ***
// Sort given array of elements, using N_SortPointers procedure
//
//     Parameters
// APBegElem    - pointer to first Element of array
// AElemCount   - Elements Count ( Length of array elements)
// AElemSize    - one Element size in bytes - SizeOf(one array element)
// ACompareFunc - Function( Ptr1, Ptr2 ) of Object for comparing any two 
//                Elements
//
procedure N_SortArrayOfElems( APBegElem: Pointer; AElemCount, AElemSize: integer;
                              ACompareFunc: TN_CompFuncOfObj );
var
  PtrsArray: TN_PArray;
  AllElements: TN_BArray;
  i, AllElementsSize: integer;
begin
  PtrsArray := nil; // to avoid warning
  if AElemCount <= 1 then Exit; // nothig to sort

  PtrsArray := N_GetPtrsArrayToElems( APBegElem, AElemCount, AElemSize );
  N_SortPointers( PtrsArray, ACompareFunc );

  AllElementsSize := AElemCount * AElemSize;
  SetLength( AllElements, AllElementsSize );

  for i := 0 to AElemCount-1 do // copy in needed order
    move( PtrsArray[i]^, AllElements[i*AElemSize], AElemSize );

  move( AllElements[0], APBegElem^, AllElementsSize ); // copy back sorted elements

end; // end of procedure N_SortArrayOfElems


//******************** TN_CompFuncsObj class methods **************************

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompFuncsObj\CompOneInt
//********************************************** TN_CompFuncsObj.CompOneInt ***
// Compare two records using One Integer field
//
//     Parameters
// APtr1  - pointers to first record Integer field, to be compared
// APtr2  - pointers to second record Integer field, to be compared
// Result - Returns:
//#F
// <0 if Integer1 < Integer2
// =0 if Integer1 = Integer2
// >0 if Integer1 > Integer2
//#/F
//
// Function is used for N_SortPointers procedure.
//
function TN_CompFuncsObj.CompOneInt( APtr1, APtr2: Pointer ): integer;
begin
  Result := PInteger(APtr1)^ - PInteger(APtr2)^;
  if DescOrder then Result := -Result;
end; // end of function TN_CompFuncsObj.CompOneInt

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompFuncsObj\CompOneUInt
//********************************************* TN_CompFuncsObj.CompOneUInt ***
// Compare two records using One Unsigned Integer field
//
//     Parameters
// APtr1  - pointers to first record Unsigned Integer field, to be compared
// APtr2  - pointers to second record Unsigned Integer field, to be compared
// Result - Returns:
//#F
// <0 if UInteger1 < UInteger2
// =0 if UInteger1 = UInteger2
// >0 if UInteger1 > UInteger2
//#/F
//
// Function is used for N_SortPointers procedure.
//
function TN_CompFuncsObj.CompOneUInt( APtr1, APtr2: Pointer ): integer;
begin
  Result := PLongWord(APtr1)^ - PLongWord(APtr2)^;
  if DescOrder then Result := -Result;
end; // end of function TN_CompFuncsObj.CompOneUInt

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompFuncsObj\CompOneDouble
//******************************************* TN_CompFuncsObj.CompOneDouble ***
// Compare two records using One Double field
//
//     Parameters
// APtr1  - pointers to first record Double field, to be compared
// APtr2  - pointers to second record Double field, to be compared
// Result - Returns:
//#F
// =-1 if Double1 < Double2
// = 0 if Double1 = Double2
// =+1 if Double1 > Double2
//#/F
//
// Function is used for N_SortPointers procedure.
//
function TN_CompFuncsObj.CompOneDouble( APtr1, APtr2: Pointer ): integer;
var
//  Double1, Double2: Double;
  RDouble : Double;
begin
  Inc( TN_BytesPtr(APtr1), Offset );
  Inc( TN_BytesPtr(APtr2), Offset );
{
  Double1 := PDouble(Ptr1)^;
  Double2 := PDouble(Ptr2)^;
  Result := 0; // as if Double1 = Double2
  if      Double1 < Double2 then Result := -1
  else if Double1 > Double2 then Result := +1;
}
  RDouble := PDouble(APtr1)^ - PDouble(APtr2)^;
  if ((PInt64(@RDouble)^ and $7FFFFFFFFFFFFFFF) = $0000000000000000) then
    Result := 0
  else if ((PInt64(@RDouble)^ and $8000000000000000) = $8000000000000000) then
    Result := -1
  else
    Result := +1;

  if DescOrder then Result := -Result;
end; // end of function TN_CompFuncsObj.CompOneInt

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompFuncsObj\CompNInts
//*********************************************** TN_CompFuncsObj.CompNInts ***
// Compare two records using Several Integer field starting from given
//
//     Parameters
// APtr1  - pointers to first record Integer field, to be compared
// APtr2  - pointers to second record Integer field, to be compared
// Result - Returns:
//#F
// <0 if Integers1 < Integers2
// =0 if Integers1 = Integers2
// >0 if Integers1 > Integers2
//#/F
//
// Number of compared fields should be placed to Self.NumFields. Function is 
// used for N_SortPointers procedure.
//
function TN_CompFuncsObj.CompNInts( APtr1, APtr2: Pointer ): integer;
var
  i: integer;
begin
  Result := 0; // as if all Integers1 = Integers2

  for i := 0 to NumFields-1 do // along fields to be compared
  begin
    Result := PInteger(APtr1)^ - PInteger(APtr2)^;
    if Result <> 0 then Break;

    Inc( TN_BytesPtr(APtr1), SizeOf(integer) );
    Inc( TN_BytesPtr(APtr2), SizeOf(integer) );
  end; // for i := 0 to NumFields-1 do // along fields to be compared

  if DescOrder then Result := -Result;
end; // end of function TN_CompFuncsObj.CompNInts

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompFuncsObj\CompNUInts
//********************************************** TN_CompFuncsObj.CompNUInts ***
// Compare two records using Several Unsigned Integer field starting from given
//
//     Parameters
// APtr1  - pointers to first record Unsigned Integer field, to be compared
// APtr2  - pointers to second record Unsigned Integer field, to be compared
// Result - Returns:
//#F
// <0 if UIntegers1 < UIntegers2
// =0 if UIntegers1 = UIntegers2
// >0 if UIntegers1 > UIntegers2
//#/F
//
// Number of compared fields should be placed to Self.NumFields. Function is 
// used for N_SortPointers procedure.
//
function TN_CompFuncsObj.CompNUInts( APtr1, APtr2: Pointer ): integer;
var
  i: integer;
begin
  Result := 0; // as if all Integers1 = Integers2

  for i := 0 to NumFields-1 do // along fields to be compared
  begin
    Result := PLongWord(APtr1)^ - PLongWord(APtr2)^;
    if Result <> 0 then Break;

    Inc( TN_BytesPtr(APtr1), SizeOf(LongWord) );
    Inc( TN_BytesPtr(APtr2), SizeOf(LongWord) );
  end; // for i := 0 to NumFields-1 do // along fields to be compared

  if DescOrder then Result := -Result;
end; // end of function TN_CompFuncsObj.CompNUInts

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompFuncsObj\CompOneByte
//********************************************* TN_CompFuncsObj.CompOneByte ***
// Compare two records using One Byte field
//
//     Parameters
// APtr1  - pointers to first record Byte field, to be compared
// APtr2  - pointers to second record Byte field, to be compared
// Result - Returns:
//#F
// <0 if Byte1 < Byte2
// =0 if Byte1 = Byte2
// >0 if Byte1 > Byte2
//#/F
//
// Function is used for N_SortPointers procedure.
//
function TN_CompFuncsObj.CompOneByte( APtr1, APtr2: Pointer ): integer;
begin
  Result := PByte(APtr1)^ - PByte(APtr2)^;
  if DescOrder then Result := -Result;
end; // end of function TN_CompFuncsObj.CompOneByte

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompFuncsObj\CompOneStr
//********************************************** TN_CompFuncsObj.CompOneStr ***
// Compare two records using One String field
//
//     Parameters
// APtr1  - pointers to first record String field, to be compared
// APtr2  - pointers to second record String field, to be compared
// Result - Returns:
//#F
// <0 if String1 < String2
// =0 if String1 = String2
// >0 if String1 > String2
//#/F
//
// Function is used for N_SortPointers procedure.
//
function TN_CompFuncsObj.CompOneStr( APtr1, APtr2: Pointer ): integer;
begin
  Result :=  CompareStr( PString(APtr1)^, PString(APtr2)^ );
  if DescOrder then Result := -Result;
end; // end of function TN_CompFuncsObj.CompOneByte

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompFuncsObj\CompSArray
//******************************************* TN_CompFuncsObj.CompSArray ***
// Compare two Arrays of String (SArray1 and SArray2)
//
//     Parameters
// APtr1  - pointers to first Array of String, to be compared
// APtr2  - pointers to second Array of String, to be compared
// Result - Returns:
//#F
// <0 if SArray1 < SArray2
// =0 if SArray1 = SArray2
// >0 if SArray1 > SArray2
//#/F
//
// Function is used for N_SortPointers procedure.
//
// CFOIArray is priority indexes: first compare SArray1[CFOIArray[0]] and 
// SArray2[CFOIArray[0]], then compare SArray1[CFOIArray[1]] and 
// SArray2[CFOIArray[1]] and so on
//
// May be used for comparing StrMatr rows.
//
function TN_CompFuncsObj.CompSArray( APtr1, APtr2: Pointer ): integer;
var
  i, SInd: integer;
  SA1, SA2: TN_SArray;
begin
  SA1 := TN_PtrToSArray(APtr1)^;
  SA2 := TN_PtrToSArray(APtr2)^;
  Result := 0;

  for i := 0 to High(CFOIArray) do // along all CFOIArray elements
  begin
    SInd := CFOIArray[i];
    Result := CompareStr( SA1[SInd], SA2[SInd] );
    if Result <> 0 then
    begin
      if DescOrder then Result := -Result;
      Exit;
    end;
  end; // for i := 0 to High(CFOIArray) do // along all CFOIArray elements
end; // end of function TN_CompFuncsObj.CompSArray


//****************** TN_GlobObj class methods  **********************

//******************************************************* TN_GlobObj.Create ***
//
constructor TN_GlobObj.Create();
begin
end; //*** end of Constructor TN_GlobObj.Create

//****************************************************** TN_GlobObj.Destroy ***
destructor TN_GlobObj.Destroy;
begin
  Inherited;
end; //*** end of destructor TN_GlobObj.Destroy

//************************************************ TN_GlobObj.TerminateSelf ***
//
procedure TN_GlobObj.TerminateSelf();
begin
  N_MainModalForm.ModalResult := mrOK;
//  N_TerminateSelfProcObj
end; //*** end of procedure TN_GlobObj.TerminateSelf

//*********************************************** TN_GlobObj.GOEmptyDumpStr ***
// Do nothing. Can be used as N_Dump1Str or N_Dump2Str
//
procedure TN_GlobObj.GOEmptyDumpStr( AStr: string );
begin
  // do nothing
end; //*** end of procedure TN_GlobObj.GOEmptyDumpStr

//********************************************** TN_GlobObj.GOEmptyDumpTStr ***
// Do nothing. Can be used as N_Dump1TStr or N_Dump2TStr
//
procedure TN_GlobObj.GOEmptyDumpTStr( AType: integer; AStr: string );
begin
  // do nothing
end; //*** end of procedure TN_GlobObj.GOEmptyDumpTStr

//*************************************************** TN_GlobObj.GODump1Str ***
// Dump AStr to N_VREDump1LCInd Logical Channel. Can be used as N_Dump1Str
//
procedure TN_GlobObj.GODump1Str( AStr: string );
begin
  N_LCAdd( N_VREDump1LCInd, AStr );
end; //*** end of procedure TN_GlobObj.GODump1Str

//*************************************************** TN_GlobObj.GODump2Str ***
// Dump AStr to N_VREDump2LCInd Logical Channel. Can be used as N_Dump2Str
//
procedure TN_GlobObj.GODump2Str( AStr: string );
begin
  N_LCAdd( N_VREDump2LCInd, AStr );
end; //*** end of procedure TN_GlobObj.GODump2Str

//*************************************************** TN_GlobObj.GOShow1Str ***
// Show Astr in needed StatusBars. Can be used as N_Show1Str
//
procedure TN_GlobObj.GOShow1Str( AStr: string );
var
  Str: string;
begin
  Str := ' ' + AStr;

  if GOStatusBar1 <> nil then
      GOStatusBar1.SimpleText := Str;

  if GOStatusBar2 <> nil then
      GOStatusBar2.SimpleText := Str;
end; //*** end of procedure TN_GlobObj.GOShow1Str

//********************************************** TN_GlobObj.GOGetCurTimeStr ***
// Return current time as String in hh:mm:ss.sssss format
//
function TN_GlobObj.GOGetCurTimeStr(): string;
var
  Str1Size, Delta, NewTime1: Integer;
  Str1, Str2: string;
  CurCPUCounter, SysTimeCounter: Int64;
  T, Hours, Minutes, Seconds: Double;
begin
//  CurCPUCounter := N_CPUCounter();
//  N_AddStrToFile( '1) ' + IntToHex( CurCPUCounter, 16 ) );
  CurCPUCounter := N_CPUCounter();
//  N_AddStrToFile( '2) ' + IntToHex( CurCPUCounter, 16 ) );
//  N_AddStrToFile( '3) ' + IntToHex( GOSavedCPUCounter1, 16 ) );
  Delta := Round( ((CurCPUCounter - GOSavedCPUCounter1) / N_CPUFrequency)*100000.0 );
//  N_AddStrToFile( 'Delta = ' + IntToStr( Delta ) );
  NewTime1 := GOSavedTime1 + Delta; // all operands are in 10 mcsec units
//  Result := '??';
//  Exit;

  if (GOSavedCPUCounter1 <> 0) and (NewTime1 < 6000000) then // same minute, use GOSavedTime1Str
  begin
    Str1 := IntToStr( NewTime1 );
//    N_AddStrToFile( Str1 );

    Str1Size := Length( Str1 );

    if Str1Size < 7 then // add leading zeros
    begin
      Str2 := '0000000';
      move( Str1[1], Str2[8-Str1Size], Str1Size*SizeOf(Char) );
      Str1 := Str2;
    end; // if Str1Size < 7 then // add leading zeros

    SetLength( Result, 14 );
    move( GOSavedTime1Str[1], Result[1], 6*SizeOf(Char) );
    move( Str1[1], Result[7], 2*SizeOf(Char) );
    Result[9] := '.';
    move( Str1[3], Result[10], 5*SizeOf(Char) );
  end else // another minute, calc full time and set SavedTime1Str, GOSavedCPUCounter1, GOSavedTime1
  begin
    Windows.GetSystemTimeAsFileTime( PFileTime(@SysTimeCounter)^ ); // abs time in 100 nsec units
    GOSavedCPUCounter1 := N_CPUCounter();
    T := Frac( SysTimeCounter / (1.0*24*60*60*1000*1000*10) ); // in Days, 0 <= T < 1.0
    T := T * 24.0;
    Hours   := Floor( T );
    T := (T - Hours) * 60.0;
    Minutes := Floor( T );
    Seconds := (T - Minutes) * 60.0;
    GOSavedTime1 := Round( Seconds * 100000 ); // in 01.mcsec units
    GOSavedTime1Str := Format( '%2.0f:%2.0f:', [Hours, Minutes] );
    Result := GOSavedTime1Str + Format( '%8.5f', [Seconds] );
  end;
end; //*** end of procedure TN_GlobObj.GOGetCurTimeStr


//********************************************************* N_ConvIntsToStr ***
// Convert given integer array elements to string
//
//     Parameters
// APFirstInt - pointer to first element of integer array
// ANumInts   - number of elements in integer array
// ADelimetr  - resulting string tokens delimiter substring
// Result     - Returns string with given integers text representation
//
function N_ConvIntsToStr( APFirstInt: PInteger; ANumInts: integer;
                                                ADelimetr: string ): string;
var
  i: integer;
begin
  Result := '';

  for i := 0 to ANumInts-1 do
  begin
    Result := Result + IntToStr(APFirstInt^);
    Inc(APFirstInt);

    if i < ANumInts-1 then
      Result := Result + ADelimetr;

  end; // for i := 0 to NumInts-1 do

end; // function N_ConvIntsToStr

//********************************************************* N_ConvIntsToStr ***
// Convert given small integer array elements to string
//
//     Parameters
// APFirstInt - pointer to first element of small integer array
// ANumInts   - number of elements in integer array
// ADelimetr  - resulting string tokens delimiter substring
// Result     - Returns string with given integers text representation
//
function N_ConvSmallIntsToStr( APFirstInt: TN_PInt2; ANumInts: integer;
                                                ADelimetr: string ): string;
var
  i: integer;
begin
  Result := '';

  for i := 0 to ANumInts-1 do
  begin
    Result := Result + IntToStr(APFirstInt^);
    Inc(APFirstInt);

    if i < ANumInts-1 then
      Result := Result + ADelimetr;

  end; // for i := 0 to NumInts-1 do

end; // function N_ConvSmallIntsToStr

//********************************************************** N_Dump1Strings ***
// Dump given AStrings using N_Dump1Str
//
procedure N_Dump1Strings( AStrings: TStrings; AIndent: integer );
var
  i: integer;
  Prefix: string;
begin
  if AStrings = nil then Exit; // a precaution

  N_Dump1BufOnly();

  if AIndent = 0 then
  begin
    for i := 0 to AStrings.Count-1 do
      N_Dump1Str( AStrings[i] );
  end else // AIndent > 0
  begin
    Prefix := DupeString( ' ', AIndent );

    for i := 0 to AStrings.Count-1 do
      N_Dump1Str( Prefix + AStrings[i] );
  end;

  N_Dump1Flash();
end; //*** end of procedure N_Dump1Strings

//********************************************************** N_Dump2Strings ***
// Dump given AStrings using N_Dump2Str
//
procedure N_Dump2Strings( AStrings: TStrings; AIndent: integer );
var
  i: integer;
  Prefix: string;
begin
  if AStrings = nil then Exit; // a precaution

  N_Dump2BufOnly();

  if AIndent = 0 then
  begin
    for i := 0 to AStrings.Count-1 do
      N_Dump2Str( AStrings[i] );
  end else // AIndent > 0
  begin
    Prefix := DupeString( ' ', AIndent );

    for i := 0 to AStrings.Count-1 do
      N_Dump2Str( Prefix + AStrings[i] );
  end;

  N_Dump2Flash();
end; //*** end of procedure N_Dump2Strings

//********************************************************* N_Dump1Integers ***
// Dump given Integers using N_Dump1Str
//
procedure N_Dump1Integers( APrefix: String; APFirstInt: PInteger; ANumInts: Integer );
begin
  N_Dump1Str( APrefix + N_ConvIntsToStr( APFirstInt, ANumInts, ', ' ) );
end; //*** end of procedure N_Dump1Integers

//********************************************************* N_Dump2Integers ***
// Dump given Integers using N_Dump2Str
//
procedure N_Dump2Integers( APrefix: String; APFirstInt: PInteger; ANumInts: Integer );
begin
  N_Dump2Str( APrefix + N_ConvIntsToStr( APFirstInt, ANumInts, ', ' ) );
end; //*** end of procedure N_Dump2Integers


//********************************************************** N_Dump1BufOnly ***
// Set Dump1 to BufOnly mode (temporary skip writing to file)
//
procedure N_Dump1BufOnly();
begin
  with N_LogChannels[N_Dump1LCInd] do
  begin
    LCSavedBufSize := LCBufSize;
    LCBufSize := 100000;
  end;
end; //*** end of procedure N_Dump1BufOnly

//************************************************************ N_Dump1Flash ***
// Flash Dump1 and set it to normal mode (enable writing to file)
//
procedure N_Dump1Flash();
begin
  with N_LogChannels[N_Dump1LCInd] do
  begin
    LCBufSize := LCSavedBufSize;
    N_LCExecAction( N_Dump1LCInd, lcaFlush );
  end;
end; //*** end of procedure N_Dump1Flash

//********************************************************** N_Dump2BufOnly ***
// Set Dump2 to BufOnly mode (temporary skip writing to file)
//
procedure N_Dump2BufOnly();
begin
  with N_LogChannels[N_Dump2LCInd] do
  begin
    LCSavedBufSize := LCBufSize;
    LCBufSize := 100000;
  end;
end; //*** end of procedure N_Dump2BufOnly

//************************************************************ N_Dump2Flash ***
// Flash Dump2 and set it to normal mode (enable writing to file)
//
procedure N_Dump2Flash();
begin
  with N_LogChannels[N_Dump2LCInd] do
  begin
    LCBufSize := LCSavedBufSize;
    N_LCExecAction( N_Dump2LCInd, lcaFlush );
  end;
end; //*** end of procedure N_Dump2Flash


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CreateFontHandle
//****************************************************** N_CreateFontHandle ***
// Create GDI Font Handle for given Font description ( NFWin. fields lfHeight,
// lfWeight and lfFaceName are ignored )
//
//     Parameters
// APFont      - Pointer to Font description parameters
// ALFHPixSize - Font Height Unit Pixel Size
//
// Resulting font Handle is placed to APFont.NFHandle. APFont.NFWin fields 
// lfHeight, lfWeight and lfFaceName are ignored.
//
procedure N_CreateFontHandle( APFont: TN_PNFont; ALFHPixSize: float );
var
  NameSize: integer;
  WideFaceName: WideString;
begin
  Assert( APFont <> nil, 'Bad Font' ); // a precaution

  with APFont^, APFont^.NFWin do
  begin
    //***** NFLLWHeight > 0 means using Charater Height (not Cell height)

    lfHeight := - Round( NFLLWHeight * ALFHPixSize );

    if NFWeight = 0 then // set lfWeight by NFBold flag
    begin
      if NFBold = 0 then lfWeight := 400
                    else lfWeight := 700;
    end else //************ set lfWeight by NFWeight
    begin
      lfWeight := NFWeight;
    end;

    FillChar( lfFaceName[0], 64, 0 ); // clear lfFaceName field, always 64 bytes
    NameSize := Length( NFFaceName );
    if NameSize > 31 then NameSize := 31;
    if NameSize > 0 then
    begin
      WideFaceName := NFFaceName; // Always Wide!
      Move( WideFaceName[1], lfFaceName[0], NameSize*2 );
    end;

    // All fields of NFWin (Windows LogFontW) are OK

    if NFHandle <> 0 then DeleteObject( NFHandle );

    NFHandle := Windows.CreateFontIndirectW( tagLOGFONTW(NFWin) ); // ok for both Ansi and Wide Chars
  end; // with APFont^, APFont^.NFWin do
end; // procedure N_CreateFontHandle


//********** TN_ProgressBarCaller class methods  **************

//********************************************* TN_ProgressBarCaller.Create ***
//
constructor TN_ProgressBarCaller.Create();
begin
  PBCFmtStr   := '%2.1f %%';
  PBCTimeStep := 0.2;
  PBCLastDrawnRect.Left := N_NotAnInteger;
  PBCFormSizeLocked := False;
end; // constructor TN_ProgressBarCaller.Create

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_ProgressBarCaller\Start
//********************************************** TN_ProgressBarCaller.Start ***
// Start progress show
//
//     Parameters
// AMaxPBValue - maxiaml value of progress parameter
// AProcOfObj  - procedure of oblect for special progress show
//
// Start Time interval and save given Params (Call Finish method to clear 
// ProgressBar and restore PBCForm Resizing ability)
//
// Progress percentage is calculated as ACurValue / AMaxPBValue * 100.
//
procedure TN_ProgressBarCaller.Start( AMaxPBValue: double; AProcOfObj: TN_PBEventProcObj);
begin
  PBCMaxPBValue := AMaxPBValue; // Max ProgressBar Value (MinPBValue is 0)
  if Assigned(AProcOfObj) then PBCProcOfObj := AProcOfObj;  // ProcOfObj that Shows Progress
  PBCBegCounter := N_CPUCounter();
end; // procedure TN_ProgressBarCaller.Start

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_ProgressBarCaller\Update(2)
//****************************************** TN_ProgressBarCaller.Update(2) ***
// Update progress Info by given current progress Value
//
//     Parameters
// ACurPBValue - current value of progress parameter
// Result      - Returns TRUE if procedure of object PBCProcOfObj was really 
//               called
//
// Call Procedure Of Object that Shows Progres Bar if enough time (>PBCTimeStep)
// was passed ACurPBValue < 0 forces unconditional Procedure Of Object call
//
// Progress percentage is calculated as ACurValue / AMaxPBValue * 100.
//
function TN_ProgressBarCaller.Update( ACurPBValue: double ): boolean;
var
  CurCPUCounter: int64;
  CurPercents: float;
  Str: string;
begin
  Result := False;
  if ACurPBValue <= 0 then // unconditional call to PBCProcOfObj
  begin
    if Assigned(PBCProcOfObj) then PBCProcOfObj( '', ACurPBValue );
    Result := True;
    Exit;
  end; // if ACurPBValue <= 0 then // unconditional call to PBCProcOfObj

  CurCPUCounter := N_CPUCounter();

  if (CurCPUCounter-PBCBegCounter)/N_CPUFrequency >= PBCTimeStep then // call
  begin
    CurPercents := 100 * ACurPBValue / PBCMaxPBValue;
    Str := Format( PBCFmtStr, [CurPercents] ); // CurPercents as String
    if Assigned(PBCProcOfObj) then PBCProcOfObj( Str, CurPercents );
    PBCBegCounter := CurCPUCounter; // update beg of current interval
    Result := True; // PBCProcOfObj was called
  end; // if (CurCPUCounter-PBCBegCounter)/N_CPUFrequency >= PBCTimeStep then // call
end; // function TN_ProgressBarCaller.Update

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_ProgressBarCaller\Update(1)
//****************************************** TN_ProgressBarCaller.Update(1) ***
// Update progress Info by given current progress Value
//
//     Parameters
// ACurPBValue - current value of progress parameter
// AMaxPBValue - maxiaml value of progress parameter
// Result      - Returns TRUE if procedure of object PBCProcOfObj was really 
//               called
//
// Call ProcOfObj that Shows ProgressBar if enough time (>PBCTimeStep) was 
// passed ACurPBValue < 0 forces unconditional ProcOfObj call
//
// Progress percentage is calculated as ACurValue / AMaxPBValue * 100.
//
function TN_ProgressBarCaller.Update( ACurPBValue: double; AMaxPBValue: double ): boolean;
begin
  PBCMaxPBValue := AMaxPBValue; // Max ProgressBar Value (MinPBValue is 0)
  Result := Update( ACurPBValue );
end; // function TN_ProgressBarCaller.Update

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_ProgressBarCaller\Finish
//********************************************* TN_ProgressBarCaller.Finish ***
// Finish Showing Progress Bar
//
// Clear all drawn Progress Bars, Rectangles and StatusBars texts, restore 
// PBCForm properties if needed
//
procedure TN_ProgressBarCaller.Finish();
begin
  if Assigned(PBCProcOfObj) then PBCProcOfObj( '', -1 ); // clear ProgressBar
end; // procedure TN_ProgressBarCaller.Finish

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_ProgressBarCaller\SaveParams
//***************************************** TN_ProgressBarCaller.SaveParams ***
// Save current ProgressBarCaller Parameters
//
//     Parameters
// APPBCParams - pointer to Progress Bar Caller parameters record
//
// Saved Params can be restored by RestoreParams method
//
procedure TN_ProgressBarCaller.SaveParams( APPBCParams: TN_PPBCParams );
begin
  if APPBCParams = nil then Exit; // a precaution

  with APPBCParams^ do
  begin
    FmtStr    := PBCFmtStr;
    ProcOfObj := PBCProcOfObj;
    TimeStep  := PBCTimeStep;

    Color     := PBCColor;
    PixRect   := PBCPixRect;
    Form      := PBCForm;

    Prefix    := PBCPrefix;
    StatusBar := PBCStatusBar;
    ProgressBar := PBCProgressBar;
  end; // with APPBCParams^ do
end; // procedure TN_ProgressBarCaller.SaveParams

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_ProgressBarCaller\RestoreParams
//************************************** TN_ProgressBarCaller.RestoreParams ***
// Restore Progress Bar Caller Parameters
//
//     Parameters
// APPBCParams - pointer to Progress Bar Caller parameters record
//
// Progress Bar Caller parameters record can be saved by SaveParams method.
//
procedure TN_ProgressBarCaller.RestoreParams( APPBCParams: TN_PPBCParams );
begin
  if APPBCParams = nil then Exit; // a precaution

  with APPBCParams^ do
  begin
    PBCFmtStr    := FmtStr;
    PBCProcOfObj := ProcOfObj;
    PBCTimeStep  := TimeStep;

    PBCColor     := Color;
    PBCPixRect   := PixRect;
    PBCForm      := Form;

    PBCPrefix    := Prefix;
    PBCStatusBar := StatusBar;
    PBCProgressBar := ProgressBar;
  end; // with APPBCParams^ do
end; // procedure TN_ProgressBarCaller.RestoreParams

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_ProgressBarCaller\ClearParams
//**************************************** TN_ProgressBarCaller.ClearParams ***
// Clear pointers to ProcOfObj, StatusBar and ProgressBar
//
procedure TN_ProgressBarCaller.ClearParams();
begin
  PBCProcOfObj   := nil;
  PBCStatusBar   := nil;
  PBCProgressBar := nil;
end; // procedure TN_ProgressBarCaller.ClearParams

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_ProgressBarCaller\RectProgressBarInit
//******************************** TN_ProgressBarCaller.RectProgressBarInit ***
// Initialize Rect ProgressBar
//
//     Parameters
// AForm    - Form where Rects should be drawn
// APixRect - whole 100% ProgeressBar Rect in Pixel Coords relative to 
//            AForm.TopLeft (if positive) or to AForm.BottomRight (if negative)
// AColor   - Progress Bar Rectangle Color
//
// Just save given parameters and process negative Rectangle coordinates.
//
procedure TN_ProgressBarCaller.RectProgressBarInit( AForm: TForm;
                                             APixRect: TRect; AColor: integer );
begin
  PBCForm    := AForm;
  PBCColor   := AColor;
  PBCPixRect := APixRect;
  PBCProcOfObj := RectProgressBarDraw;
end; // procedure TN_ProgressBarCaller.RectProgressBarInit

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_ProgressBarCaller\RectProgressBarDraw
//******************************** TN_ProgressBarCaller.RectProgressBarDraw ***
// Draw Rect ProgressBar according to given APBValue
//
//     Parameters
// AStr     - not used
// APBValue - current progress parameter in percents (0 <= APBValue <= 100), 
//            APBValue < 0 means clearing
//
// One of possible show progress procedure of object that only progress 
// rectangle draw
//
procedure TN_ProgressBarCaller.RectProgressBarDraw( AStr: string; APBValue: float);
var
  CurRect: TRect;

  procedure ClearLastRect(); // local
  // Clear (Restore) PBCLastDrawnRect
  begin
    if PBCLastDrawnRect.Left = N_NotAnInteger then Exit; // PBCLastDrawnRect is not given

    Inc(PBCLastDrawnRect.Right);  // RedrawWindow excludes Right,Bottom edges in any mode
    Inc(PBCLastDrawnRect.Bottom);

    // Convert to absolute Screen Coords
    Inc(PBCLastDrawnRect.Left,   PBCForm.Left );
    Inc(PBCLastDrawnRect.Top,    PBCForm.Top  );
    Inc(PBCLastDrawnRect.Right,  PBCForm.Left );
    Inc(PBCLastDrawnRect.Bottom, PBCForm.Top  );

    // This call causes Delphi to repaint all controls on PBCForm
    Windows.RedrawWindow( 0, @PBCLastDrawnRect, 0, RDW_INVALIDATE or RDW_ALLCHILDREN );
//??!!    Application.ProcessMessages; // is needed
    PBCLastDrawnRect.Left := N_NotAnInteger; // set 'All is Clear' flag
  end; // procedure ClearLastRect(); // local

begin //**************** main body of TN_ProgressBarCaller.RectProgressBarDraw

  if (PBCStatusBar <> nil) or (PBCProgressBar <> nil) then
    SBPBProgressBarDraw( AStr, APBValue );

  if PBCForm = nil then Exit; // a precaution

  if not PBCFormSizeLocked then // Lock PBCForm Sizes
  begin
    // save original PBCForm.Constraints
    PBCSavedSize.Left   := PBCForm.Constraints.MinWidth;
    PBCSavedSize.Top    := PBCForm.Constraints.MinHeight;
    PBCSavedSize.Right  := PBCForm.Constraints.MaxWidth;
    PBCSavedSize.Bottom := PBCForm.Constraints.MaxHeight;

    // prohibit PBCForm resizing
    PBCForm.Constraints.MinWidth  := PBCForm.Width;
    PBCForm.Constraints.MaxWidth  := PBCForm.Width;
    PBCForm.Constraints.MinHeight := PBCForm.Height;
    PBCForm.Constraints.MaxHeight := PBCForm.Height;

    PBCFormSizeLocked := True; // set "PBCForm.Constraints was changed" Flag
  end; // if not PBCFormSizeLocked then // Lock PBCForm Sizes

  if APBValue < 0 then // clear All and Exit
  begin
    ClearLastRect();
    PBCForm.Refresh();

    if PBCFormSizeLocked then // restore original Form Constraints
    begin
      PBCForm.Constraints.MinWidth  := PBCSavedSize.Left;
      PBCForm.Constraints.MinHeight := PBCSavedSize.Top;
      PBCForm.Constraints.MaxWidth  := PBCSavedSize.Right;
      PBCForm.Constraints.MaxHeight := PBCSavedSize.Bottom;
    end;

    PBCFormSizeLocked := False;
    Exit;
  end; // clear All and Exit

  CurRect := PBCPixRect;

  with CurRect do // Process negative CurRect Coords and clip by PBCForm
  begin
    if Left   < 0 then Left   := PBCForm.Width  + Left;
    if Top    < 0 then Top    := PBCForm.Height + Top;
    if Right  < 0 then Right  := PBCForm.Width  + Right;
    if Bottom < 0 then Bottom := PBCForm.Height + Bottom;

    if Left   < 0 then Left   := 0;
    if Top    < 0 then Top    := 0;
    if Right  < 0 then Right  := PBCForm.Width  div 2;
    if Bottom < 0 then Bottom := PBCForm.Height div 2;

    if Left   >= PBCForm.Width  then Left   := PBCForm.Width  div 2;
    if Top    >= PBCForm.Height then Top    := PBCForm.Height div 2;
    if Right  >= PBCForm.Width  then Right  := PBCForm.Width  - 1;
    if Bottom >= PBCForm.Height then Bottom := PBCForm.Height - 1;

    // Calc Rect Width by APBValue, if APBValue=0, Right = Left-1
    Right := Left + Round( 0.01*(Right-Left+1)*APBValue) - 1;
  end; // with CurRect do // Process negative CurRect Coords and clip by PBCForm

  // Check if PBCForm Size changed, or APBValue decreased
  if (CurRect.Left  <> PBCLastDrawnRect.Left) or
     (CurRect.Top   <> PBCLastDrawnRect.Top)  or
     (CurRect.Right <  PBCLastDrawnRect.Right)  then
    ClearLastRect();

  if CurRect.Right >= CurRect.Left then // Rect is not empty
  begin
    N_FillRectOnWinHandle( PBCForm.Handle, CurRect, PBCColor );
//??!!    PBCForm.Update(); // without this call Rect may be invisible (not always!)
    PBCForm.Refresh();
//??!!    Application.ProcessMessages;
  end;

  PBCLastDrawnRect := CurRect;
end; // procedure TN_ProgressBarCaller.RectProgressBarDraw

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_ProgressBarCaller\SBPBProgressBarInit
//******************************** TN_ProgressBarCaller.SBPBProgressBarInit ***
// Initialize SBPB (StatusBar and/or Dellphi TProgressBar) Progress Bar
//
//     Parameters
// APrefix - Text that would be added before AStr in SBPBProgressBarDraw method
// ASB     - StatusBar control for showing APrefix + Astr (may be nil)
// APB     - ProgressBar control to use (may be nil)
//
// Just save given parameters
//
procedure TN_ProgressBarCaller.SBPBProgressBarInit( APrefix: string;
                                           ASB: TStatusBar; APB: TProgressBar );
begin
  PBCPrefix      := APrefix + '  ';
  PBCStatusBar   := ASB;
  PBCProgressBar := APB;
  PBCProcOfObj   := SBPBProgressBarDraw;
end; // procedure TN_ProgressBarCaller.SBPBProgressBarInit

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_ProgressBarCaller\SBPBProgressBarDraw
//******************************** TN_ProgressBarCaller.SBPBProgressBarDraw ***
// Draw StausBar Text and Delphi ProgressBar according to given APBValue
//
//     Parameters
// AStr     - string with current progeress percentage
// APBValue - current progress parameter in percents (0 <= APBValue <= 100), 
//            APBValue < 0 means clearing
//
// One of possible show progress procedure of object that show text in status 
// bar and progress state in Delphi ProgressBar
//
procedure TN_ProgressBarCaller.SBPBProgressBarDraw( AStr: string; APBValue: float );
begin
  if PBCStatusBar <> nil then
  begin
    if APBValue > 0 then
      PBCStatusBar.SimpleText := PBCPrefix + AStr
    else
      PBCStatusBar.SimpleText := '';
  end; // if PBCStatusBar <> nil then

  if PBCProgressBar <> nil then
  begin
    if APBValue > 0 then
      PBCProgressBar.Position := Round( APBValue )
    else
      PBCProgressBar.Position := 0;
  end; // if PBCProgressBar <> nil then
end; // procedure TN_ProgressBarCaller.SBPBProgressBarDraw


//********** TN_IndIterator class methods  **************

//*********************************************** TN_IndIterator.AddIIDigit ***
// Add Data for next one Didit
//
// ADigSize  - Digit Size (number of indexes)
// ANumSwaps - Number of Swaps for indexes randomizing
// AISeed    - Random Generator Start value (not used if ANumSwaps = 0)
//
procedure TN_IndIterator.AddIIDigit( ADigSize, ANumSwaps, AISeed: integer );
var
  i, i1, i2, iTmp, Ind, NewSize, TotalInds: integer;
begin
  Ind := IINumDigits;
  Inc( IINumDigits );

  if Length(IIDigSizes) < IINumDigits then
  begin
    NewSize := N_NewLength( IINumDigits );
    SetLength( IIDigSizes, NewSize );
    SetLength( IICurDigValues, NewSize );
  end;

  IIDigSizes[Ind] := ADigSize;
  IICurDigValues[Ind] := 0;

  TotalInds := 0;
  for i := 0 to Ind-1 do // calculate TotalInds for all previous digits
    Inc( TotalInds, IIDigSizes[i] );

  Ind := TotalInds; // index of first new digit index in IIInds

  NewSize := Ind + ADigSize; // needed IIInds size
  if Length(IIInds) < NewSize then
    SetLength( IIInds, N_NewLength( NewSize ) );

  for i := 0 to ADigSize-1 do // Create indexes for new Digit
    IIInds[Ind+i] := i;

  if ANumSwaps <= 0 then Exit; // randomization is not needed

  RandSeed := AISeed; // initialize Random function

  for i := 1 to ANumSwaps do // randomize Indexes
  begin
    i1 := Random( ADigSize );
    i2 := Random( ADigSize );

    //*** Swap i1 and i2 indexes

    iTmp := IIInds[Ind+i1];
    IIInds[Ind+i1] := IIInds[Ind+i2];
    IIInds[Ind+i2] := iTmp;
  end; // for i := 1 to ANumSwaps do // randomize Indexes
end; // end of procedure TN_IndIterator.AddIIDigit

//********************************************* TN_IndIterator.PrepIIDigits ***
// Prepare all Digits (prepare Data for given number of Digits)
//
// APDigSizes - Pointer to Digit Sizes for all Digits
// ANumDigits - Number of Digits
// AISeed     - Random Generator Start value (not used if ANumSwaps = 0)
// ANumSwapsCoef - Number of Swaps for i-th digit is APDigSizes[i]*ANumSwapsCoef
//
procedure TN_IndIterator.PrepIIDigits( APDigSizes: PInteger;
                           ANumDigits, AISeed: integer; ANumSwapsCoef: float );
var
  i, NumSwaps: integer;
begin
  IINumDigits := 0; // initialize IndIterator Data

  for i := 1 to ANumDigits do
  begin
    NumSwaps := Round( APDigSizes^ * ANumSwapsCoef );
    AddIIDigit( APDigSizes^, NumSwaps, AISeed );
    Inc( APDigSizes );
  end; // for i := 1 to ANumDigits do
end; // end of procedure TN_IndIterator.PrepIIDigits

//************************************************* TN_IndIterator.GetIInds ***
// Get next set of IINumDigits indexes
//
// APResInds - Pointer to resulting Indexes (where to write resulting indexes)
//
procedure TN_IndIterator.GetIInds( APResInds: PInteger );
var
  i, BegInd: integer;
begin
  //***** Write current index values to resulting array
  BegInd := 0;

  for i := 0 to IINumDigits-1 do // along all Digits
  begin
    APResInds^ := IIInds[ BegInd + IICurDigValues[i] ];

    Inc( APResInds );             // to next resulting index
    Inc( BegInd, IIDigSizes[i] ); // to Beg of next Digit Indexes
  end; // for i := 0 to IINumDigits-1 do // along all Digits

  //***** Update IICurDigValues (current digit values)

  for i := 0 to IINumDigits-1 do // along all Digits to change
  begin
    Inc( IICurDigValues[i] );

    if IICurDigValues[i] < IIDigSizes[i] then Exit; // all done

    IICurDigValues[i] := 0;
  end; // for i := 0 to IINumDigits-1 do // along all Digits to change
end; // end of procedure TN_IndIterator.GetIInds


//********** TN_CompTwoArraysObj class methods  **************

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompTwoArraysObj\CTAOCompare
//************************************** TN_CompTwoArraysObj.CTAOCompare ***
// Compare two given arrays of elements of same type
//
//     Parameters
// AA1Ptr      - Pointer to first element of A1 array
// AA2Ptr      - Pointer to first element of A2 array
// AA1NumElems - Number of elements in A1 array
// AA2NumElems - Number of elements in A2 array
// AElemSize   - Size in bytes of A1 and A2 arrays Elements
// AFuncOfObj  - given Function of Object for comparing two A1, A2 elements
//
// TN_CompTwoArraysObj fields are calculated
//
procedure TN_CompTwoArraysObj.CTAOCompare( AA1Ptr, AA2Ptr: Pointer;
                                AA1NumElems, AA2NumElems, AElemSize: Integer;
                                              AFuncOfObj: TN_BoolFuncObj2Ptr );
var
  i, j, iMax, ResInd, MaxSize, A1BegInd, A2BegInd, A1EndInd, A2EndInd: integer;
  A1NumLeft, A2NumLeft, A1Size, A2Size: integer;
  PA1, PA2: TN_BytesPtr;
  CurSame, CurRes: boolean;
  Label Loop, FoundSame;
begin
  A1Size := 0; // to avoid warning
  A2Size := 0; // to avoid warning

  MaxSize := max( AA1NumElems, AA2NumElems );
  if Length(CTAOCompResult) <= MaxSize then // set Max needed size
    SetLength( CTAOCompResult, MaxSize+1 );

  CTAONumSameElems      := 0; // Number of same elements in A1 and A2 arrays
  CTAONumNotSameElemsA1 := 0; // Number of not same elements in A1 array
  CTAONumNotSameElemsA2 := 0; // Number of not same elements in A2 array

  if AA1NumElems = 0 then // no elems in A1 array
  begin
    if AA2NumElems = 0 then // no elems in both A1, A2 arrays
    begin
      with CTAOCompResult[0] do // fill the only CTAOCompResult[ResInd] record
      begin
        CTAOA1FirstInd  := -1; // First Index of A1 array interval
        CTAOA2FirstInd  := -1; // First Index of A2 array interval
        CTAOA1NumElemes := 0;  // Number of (not same) elements in A1 array interval
        CTAOA2NumElemes := 0;  // Number of (not same) elements in A2 array interval
      end; // with CTAOCompResult[0] do // fill the only CTAOCompResult[ResInd] record
    end else // AA1NumElems = 0, AA2NumElems > 0, some elems only in A2 array
    begin
      with CTAOCompResult[0] do // fill the only CTAOCompResult[ResInd] record
      begin
        CTAOA1FirstInd  := -1;          // First Index of A1 array interval
        CTAOA2FirstInd  := 0;           // First Index of A2 array interval
        CTAOA1NumElemes := 0;           // Number of (not same) elements in A1 array interval
        CTAOA2NumElemes := AA2NumElems; // Number of (not same) elements in A2 array interval
      end; // with CTAOCompResult[0] do // fill the only CTAOCompResult[ResInd] record

      CTAONumNotSameElemsA2 := AA2NumElems; // Number of not same elements in A2 array
    end; // else // AA1NumElems = 0, AA2NumElems > 0, some elems only in A2 array

    //***** Here: AA1NumElems > 0, AA2NumElems > 0,  some elems in both A1, A2 arrays

    CTAOCompResultCount := 1;
    Exit; // all done
  end else // AA1NumElems > 0, some elems in A1 array
  begin
    if AA2NumElems = 0 then // some elems in A1 array, no elems in A2 array
    begin
      with CTAOCompResult[0] do // fill the only CTAOCompResult[ResInd] record
      begin
        CTAOA1FirstInd  := 0;           // First Index of A1 array interval
        CTAOA2FirstInd  := -1;          // First Index of A2 array interval
        CTAOA1NumElemes := AA1NumElems; // Number of (not same) elements in A1 array interval
        CTAOA2NumElemes := 0;           // Number of (not same) elements in A2 array interval
      end; // with CTAOCompResult[0] do // fill the only CTAOCompResult[ResInd] record

      CTAONumNotSameElemsA1 := AA1NumElems; // Number of not same elements in A1 array
      CTAOCompResultCount := 1;
      Exit; // all done
    end; // if AA2NumElems = 0 then // some elems in A1 array, no elems in A2 array
  end; // else // AA1NumElems > 0, some elems in A1 array

  //***** Here: AA1NumElems > 0, AA2NumElems > 0, some elems in both A1, A2 arrays

  CTAOFirstElemIsSame := AFuncOfObj( AA1Ptr, AA2Ptr ); // compare first elements
  CurSame  := CTAOFirstElemIsSame;

  ResInd   := 0;
  A1BegInd := 0;
  A2BegInd := 0;

  Loop: //*************************************

  PA1 := AA1Ptr; Inc( PA1, A1BegInd*AElemSize ); // Pointer to A1BegInd-th elem in A1 array
  PA2 := AA2Ptr; Inc( PA2, A2BegInd*AElemSize ); // Pointer to A2BegInd-th elem in A2 array

//  N_s1 := PString(PA1)^; // debug
//  N_s2 := PString(PA2)^; // debug
  N_i1 := PInteger(PA1)^;
  N_i2 := PInteger(PA2)^; // debug
  N_s1 := PString(TN_BytesPtr(PA1)+4)^; // debug
  N_s2 := PString(TN_BytesPtr(PA2)+4)^; // debug

  A1NumLeft := AA1NumElems - A1BegInd; // Number of elems left in A1 array
  A2NumLeft := AA2NumElems - A2BegInd; // Number of elems left in A1 array

  iMax := min( A1NumLeft, A2NumLeft ) - 1; // iMax+1 elems in both A1 and A2 arrays

  if CurSame then // A1BegInd and A2BegInd are the Same, calc number of subsequent same elements
  begin

    for i := 0 to iMax do // along not checked yet elems
    begin
      if i = 141 then
        N_i := 1;

      if i = 0 then CurRes := CurSame // to avoid comparing again 0-th elemets
               else CurRes := AFuncOfObj( PA1, PA2 );

//      N_s1 := PString(PA1)^; // debug
//      N_s2 := PString(PA2)^; // debug
  N_i1 := PInteger(PA1)^;
  N_i2 := PInteger(PA2)^; // debug
  N_s1 := PString(TN_BytesPtr(PA1)+4)^; // debug
  N_s2 := PString(TN_BytesPtr(PA2)+4)^; // debug

      if CurRes then // same i-th Element
      begin
        Inc( PA1, AElemSize );
        Inc( PA2, AElemSize );
        Continue; // to next Element
      end else // not same i-th Element
      begin
        with CTAOCompResult[ResInd] do // fill CTAOCompResult[ResInd] record
        begin
          CTAOA1FirstInd  := A1BegInd; // First Index of A1 array interval
          CTAOA2FirstInd  := A2BegInd; // First Index of A2 array interval
          CTAOA1NumElemes := i;        // Number of (same) elements in A1 array interval
          CTAOA2NumElemes := i;        // Number of (same) elements in A2 array interval
        end; // with CTAOCompResult[ResInd] do // fill CTAOCompResult[ResInd] record

        Inc( CTAONumSameElems, i ); // Number of same elements in A1 and A2 arrays
        Inc( ResInd ); // to next record (interval)
        CurSame := False;

        Inc( A1BegInd, i );
        Inc( A2BegInd, i );
        goto Loop;
      end; //  // not same Element
    end; // for i := 0 to iMax do // along not checked yet elems

    //***** Here: all iMax elements are the same

    with CTAOCompResult[ResInd] do // fill CTAOCompResult[ResInd] record
    begin
      CTAOA1FirstInd  := A1BegInd; // First Index of A1 array interval
      CTAOA2FirstInd  := A2BegInd; // First Index of A2 array interval
      CTAOA1NumElemes := iMax + 1; // Number of (same) elements in A1 array interval
      CTAOA2NumElemes := iMax + 1; // Number of (same) elements in A2 array interval
    end; // with CTAOCompResult[ResInd] do // fill CTAOCompResult[ResInd] record

    Inc( CTAONumSameElems, iMax + 1 ); // Number of same elements in A1 and A2 arrays

    A1NumLeft := AA1NumElems - (A1BegInd+iMax+1);
    A2NumLeft := AA2NumElems - (A2BegInd+iMax+1);

    if A1NumLeft = 0 then // no more elems in A1 array
    begin
      if A2NumLeft = 0 then // no more elems in both A1 and A2 arrays
      begin
        CTAOCompResultCount := ResInd + 1;
        Exit; // all done
      end else // A2NumLeft <> 0, no more elems in A1 array, A2NumLeft elems in A2
      begin
        Inc( ResInd );

        with CTAOCompResult[ResInd] do // fill last CTAOCompResult[ResInd] record
        begin
          CTAOA1FirstInd  := -1;              // First Index of A1 array interval
          CTAOA2FirstInd  := A2BegInd+iMax+1; // First Index of A2 array interval
          CTAOA1NumElemes := 0;               // Number of (not same) elements in A1 array interval
          CTAOA2NumElemes := A2NumLeft;       // Number of (not same) elements in A2 array interval
        end; // with CTAOCompResult[ResInd] do // fill last CTAOCompResult[ResInd] record

        Inc( CTAONumNotSameElemsA2, A2NumLeft ); // Number of not same elements in A2 array
        CTAOCompResultCount := ResInd + 1;
        Exit; // all done
      end; // else // A2NumLeft <> 0, no more elems in A1 array, A2NumLeft elems in A2

    end else // A1NumLeft <> 0,  then // A1NumLeft elems in A1 array, no more elems in A2 array
    begin
      Inc( ResInd );

      with CTAOCompResult[ResInd] do // fill last CTAOCompResult[ResInd] record
      begin
        CTAOA1FirstInd  := A1BegInd+iMax+1; // First Index of A1 array interval
        CTAOA2FirstInd  := -1;              // First Index of A2 array interval
        CTAOA1NumElemes := A1NumLeft;       // Number of (not same) elements in A1 array interval
        CTAOA2NumElemes := 0;               // Number of (not same) elements in A2 array interval
      end; // with CTAOCompResult[ResInd] do // fill last CTAOCompResult[ResInd] record

      Inc( CTAONumNotSameElemsA1, A1NumLeft ); // Number of not same elements in A1 array
      CTAOCompResultCount := ResInd + 1;
      Exit; // all done
    end; // else // A1NumLeft <> 0,  then // A1NumLeft elems in A1 array, no more elems in A2 array
  end else // A1BegInd and A2BegInd are not Same, find first same element (if any)
  begin
    //***** compare all ( A1[0,imax], A2[0,imax] ) pairs except (A1[0], A2[0]) (already done)

    PA1 := AA1Ptr; Inc( PA1, (A1BegInd+1)*AElemSize ); // Pointer to (A1BegInd+1)-th elem in A1 array

    for i := 1 to iMax do // along A1 elems, compare A1[i] elem with all elems in (A2[0] - A2[i])
    begin
      PA2 := AA2Ptr; Inc( PA2, A2BegInd*AElemSize ); // Pointer to A2BegInd-th elem in A2 array

      for j := 0 to i do // Along A2 elems, compare A1[i] elem with A2[j] elem
      begin
        CurRes := AFuncOfObj( PA1, PA2 );

//        N_s1 := PString(PA1)^; // debug
//        N_s2 := PString(PA2)^; // debug

        if not CurRes then // not same Element, A1[i] <> A2[j]
        begin
          Inc( PA2, AElemSize );
          Continue; // to next A2 Element (nj next j)
        end else // same Element found, A1[i] = A2[j]
        begin
          A1Size := i;
          A2Size := j;
          goto FoundSame;
        end; // else // same Element found, A1[i] = A2[j]

      end; // for j := 0 to i do // compare A1[i] elem with all elems in (A2[0] - A2[i])

      Inc( PA1, AElemSize ); // to next A1 Element (to next i)
    end; // for i := 1 to iMax do // along A1 elems, compare A1[i] elem with all elems in (A2[0] - A2[i])


    PA2 := AA2Ptr; Inc( PA2, (A2BegInd+1)*AElemSize ); // Pointer to (A2BegInd+1)-th elem in A2 array

    for i := 1 to iMax do // along A2 elems, compare A2[i] elem with all elems in (A1[0] - A1[i])
    begin
      PA1 := AA1Ptr; Inc( PA1, A1BegInd*AElemSize ); // Pointer to A1BegInd-th elem in A1 array

      for j := 0 to i do // Along A1 elems, compare A2[i] elem with A1[j] elem
      begin
        CurRes := AFuncOfObj( PA1, PA2 );

//        N_s1 := PString(PA1)^; // debug
//        N_s2 := PString(PA2)^; // debug

        if not CurRes then // not same Element, A2[i] <> A1[j]
        begin
          Inc( PA1, AElemSize );
          Continue; // to next A1 Element (to next j)
        end else // same Element found, A2[i] = A1[j]
        begin
          A1Size := j;
          A2Size := i;
          goto FoundSame;
        end; // else // same Element found, A2[i] = A1[j]

      end; // for j := 0 to i do // Along A1 elems, compare A2[i] elem with A1[j] elem

      Inc( PA2, AElemSize ); // to next A2 Element (to next i)
    end; // for i := 1 to iMax do // along A2 elems, compare A2[i] elem with all elems in (A1[0] - A1[i])

    //***** Here: all ( A1[0,iMax], A2[0,iMax] ) pairs are not the same

    A1NumLeft := AA1NumElems - (A1BegInd+iMax+1);
    A2NumLeft := AA2NumElems - (A2BegInd+iMax+1);

    //***** Here: either A1NumLeft=0 or A2NumLeft=0

    if A1NumLeft = 0 then // no more elems in A1 array
    begin
      if A2NumLeft = 0 then // no more elems in both A1 and A2 arrays
      begin                 // all iMax+1 elements are not the same with each other
        with CTAOCompResult[ResInd] do // fill last CTAOCompResult[ResInd] record
        begin
          CTAOA1FirstInd  := A1BegInd; // First Index of A1 array interval
          CTAOA2FirstInd  := A2BegInd; // First Index of A2 array interval
          CTAOA1NumElemes := iMax + 1; // Number of (same) elements in A1 array interval
          CTAOA2NumElemes := iMax + 1; // Number of (same) elements in A2 array interval
        end; // with CTAOCompResult[ResInd] do // fill last CTAOCompResult[ResInd] record

        Inc( CTAONumNotSameElemsA1, iMax + 1 ); // Number of not same elements in A1 array
        Inc( CTAONumNotSameElemsA2, iMax + 1 ); // Number of not same elements in A2 array

        CTAOCompResultCount := ResInd + 1;
        Exit; // all done
      end else // A2NumLeft <> 0, no more elems in A1 array, A2NumLeft elems in A2
      begin
        PA2 := AA2Ptr; Inc( PA2, (A2BegInd+iMax+1)*AElemSize ); // Pointer to first elem in A2 array to compare

        for i := iMax+1 to AA2NumElems-1 do // along A2 elems, compare all ( A2[iMax+1,AA2NumElems-1], A1[0,iMax] ) pairs
        begin
          PA1 := AA1Ptr; Inc( PA1, A1BegInd*AElemSize ); // Pointer to A1BegInd-th elem in A1 array

          for j := 0 to iMax do // Along A1 elems, compare A2[i] elem with A1[j] elem
          begin
            CurRes := AFuncOfObj( PA1, PA2 );

//            N_s1 := PString(PA1)^; // debug
//            N_s2 := PString(PA2)^; // debug

            if not CurRes then // not same Element, A2[i] <> A1[j]
            begin
              Inc( PA1, AElemSize );
              Continue; // to next A1 Element (to next j)
            end else // same Element found, A2[i] = A1[j]
            begin
              A1Size := j;
              A2Size := i;
              goto FoundSame;
            end; // else // same Element found, A2[i] = A1[j]

          end; // for j := 0 to i do // Along A1 elems, compare A2[i] elem with A1[j] elem

          Inc( PA2, AElemSize ); // to next A2 Element (to next i)
        end; // for i := 1 to iMax do // along A2 elems, compare A2[i] elem with all elems in (A1[0] - A1[i])
      end; // else // A2NumLeft <> 0, no more elems in A1 array, A2NumLeft elems in A2
    end else // A1NumLeft <> 0, no more elems in A2 array, A1NumLeft elems in A1
    begin
      PA1 := AA1Ptr; Inc( PA1, (A1BegInd+iMax+1)*AElemSize ); // Pointer to first elem in A1 array to compare

      for i := iMax+1 to AA1NumElems-1 do // along A1 elems, compare all ( A1[iMax+1,AA1NumElems-1], A2[0,iMax] ) pairs
      begin
        PA2 := AA2Ptr; Inc( PA2, A2BegInd*AElemSize ); // Pointer to A2BegInd-th elem in A2 array

        for j := 0 to iMax do // Along A2 elems, compare A1[i] elem with A2[j] elem
        begin
          CurRes := AFuncOfObj( PA1, PA2 );

//          N_s1 := PString(PA1)^; // debug
//          N_s2 := PString(PA2)^; // debug

          if not CurRes then // not same Element, A1[i] <> A2[j]
          begin
            Inc( PA2, AElemSize );
            Continue; // to next A1 Element (to next j)
          end else // same Element found, A1[i] = A2[j]
          begin
            A1Size := i;
            A2Size := j;
            goto FoundSame;
          end; // else // same Element found, A1[i] = A2[j]

        end; // for j := 0 to iMax do // Along A2 elems, compare A1[i] elem with A2[j] elem

        Inc( PA1, AElemSize ); // to next A1 Element (to next i)
      end; // for i := iMax+1 to AA1NumElems-1 do // along A1 elems, compare all ( A1[iMax+1,AA1NumElems-1], A2[0,iMax] ) pairs

    end; // else // A1NumLeft <> 0, no more elems in A2 array, A1NumLeft elems in A1

  end; // else // A1BegInd and A2BegInd are not Same, find first same element (if any)


  FoundSame: //***********************************

  with CTAOCompResult[ResInd] do // fill CTAOCompResult[ResInd] record
  begin
    if A1Size = 0 then CTAOA1FirstInd  := -1 // no elems in A1
                  else CTAOA1FirstInd  := A1BegInd; // First Index of A1 array interval

    if A2Size = 0 then CTAOA2FirstInd  := -1 // no elems in A2
                  else CTAOA2FirstInd  := A2BegInd; // First Index of A2 array interval

    CTAOA1NumElemes := A1Size;   // Number of (not same) elements in A1 array interval
    CTAOA2NumElemes := A2Size;   // Number of (not same) elements in A2 array interval
  end; // with CTAOCompResult[ResInd] do // fill CTAOCompResult[ResInd] record

  Inc( CTAONumNotSameElemsA1, A1Size ); // Number of not same elements in A1 array
  Inc( CTAONumNotSameElemsA2, A2Size ); // Number of not same elements in A2 array

  Inc( ResInd ); // to next record (interval)
  CurSame := True;

  Inc( A1BegInd, A1Size );
  Inc( A2BegInd, A2Size );
  
  goto Loop;

end; // procedure TN_CompTwoArraysObj.CTAOCompare

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompTwoArraysObj\CTAOShowResAsStrings1
//**************************** TN_CompTwoArraysObj.CTAOShowResAsStrings1 ***
// Show CTAOCompResult as Strings, varian #1
//
//     Parameters
// AInpStrings1 - given Strings 1
// AInpStrings2 - given Strings 2
// AColWidth    - one column width (not counting index and gaps sizes)
// AFlags       - format flags
// AOutStrings  - Resulting Strings
//
// AInpStrings1 and AInpStrings2 should represent some how two Arrays, that were
// compared Resulting Strings will be prepared as two columns with AInpStrings 
// 1, 2 in columns 1, 2 For Same intervals in CTAOCompResult appropriate 
// InpStrings will be in the same row
//
// One AOutStrings row format:
//
// Ind1 aaaa_left_column_bbbbbbbb  =  Ind2 aaaa_right_column_bbbbbbbb
//
procedure TN_CompTwoArraysObj.CTAOShowResAsStrings1( AInpStrings1, AInpStrings2: TStrings;
                            AColWidth, AFlags: Integer; AOutStrings: TStrings );
var
  i, j, IndA1, IndA2, jMax, IndLeng: Integer;
  Str1, Str2, DelimStr, EllStr: String;
  IsSame: Boolean;
begin
  EllStr := '....';

  AOutStrings.Clear();
  AOutStrings.Add( Format( 'First_Same=%s, Num_Intervals=%d,  Num_Same_Elements=%d,  Not_Same_in_A1=%d, Not_Same_in_A2=%d',
            [N_B2S(CTAOFirstElemIsSame),
                          CTAOCompResultCount, CTAONumSameElems,
                          CTAONumNotSameElemsA1, CTAONumNotSameElemsA2] ));
  AOutStrings.Add( '' );
  IsSame := CTAOFirstElemIsSame;

  jMax := max( AInpStrings1.Count, AInpStrings2.Count );
  IndLeng := Round( Ceil( Log10( jMax+1 )));

  for i := 0 to CTAOCompResultCount-1 do
  begin
    with CTAOCompResult[i] do
    begin
      if IsSame then // Interval of Same elements
      begin
        DelimStr := '  =  ';

        for j := 0 to CTAOA1NumElemes-1 do // along same elements, CTAOA1NumElemes = CTAOA2NumElemes
        begin
          IndA1 := CTAOA1FirstInd + j;
          Str1 := Format( '%*.d ', [IndLeng, IndA1+1] ) +
              N_FormatString( AInpStrings1[IndA1], EllStr, AColWidth, AFlags );

          IndA2 := CTAOA2FirstInd + j;
          Str2 := Format( '%*.d ', [IndLeng, IndA2+1] ) +
              N_FormatString( AInpStrings2[IndA2], EllStr, AColWidth, AFlags );

          AOutStrings.Add( Str1 + DelimStr + Str2 );
        end; // for j := 0 to CTAOA1NumElemes-1 do
      end else // IsSame=False, two Intervals of not Same elements
      begin
        jMax := max( CTAOA1NumElemes, CTAOA2NumElemes ) - 1;

        for j := 0 to jMax do // along not same elements
        begin
          DelimStr := '  !  ';

          if j < CTAOA1NumElemes then // A1 element exists
          begin
            IndA1 := CTAOA1FirstInd + j;
            Str1 := Format( '%*.d ', [IndLeng, IndA1+1] ) +
                N_FormatString( AInpStrings1[IndA1], EllStr, AColWidth, AFlags );
          end else // no A1 element
          begin
            Str1 := DupeString( ' ', IndLeng + 1 + AColWidth );
            DelimStr := '     ';
          end;

          if j < CTAOA2NumElemes then // A2 element exists
          begin
            IndA2 := CTAOA2FirstInd + j;
            Str2 := Format( '%*.d ', [IndLeng, IndA2+1] ) +
                N_FormatString( AInpStrings2[IndA2], EllStr, AColWidth, AFlags );
          end else // no A2 element
          begin
            Str2 := DupeString( ' ', IndLeng + 1 + AColWidth );
            DelimStr := '     ';
          end;

          AOutStrings.Add( Str1 + DelimStr + Str2 );
        end; // for j := 0 to jMax do // along not same elements
      end; // else // IsSame=False, two Intervals of not Same elements

      IsSame := not IsSame;
    end; // with CTAOCompResult[i] do
  end; // for i := 0 to CTAOCompResultCount-1 do

end; // procedure TN_CompTwoArraysObj.CTAOShowResAsStrings1

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompTwoArraysObj\CTAOShowResAsStrings2
//**************************** TN_CompTwoArraysObj.CTAOShowResAsStrings2 ***
// Show CTAOCompResult elements
//
//     Parameters
// AOutStrings - Resulting Strings
//
procedure TN_CompTwoArraysObj.CTAOShowResAsStrings2( AOutStrings: TStrings );
var
  i: Integer;
  IsSame: Boolean;
begin
  AOutStrings.Add( Format( 'First_Same=%s, Num_Intervals=%d,  Num_Same_Elements=%d,  Not_Same_in_A1=%d, Not_Same_in_A2=%d',
           [N_B2S(CTAOFirstElemIsSame), CTAOCompResultCount, CTAONumSameElems,
                                  CTAONumNotSameElemsA1, CTAONumNotSameElemsA2] ));
  AOutStrings.Add( '' );

  IsSame := CTAOFirstElemIsSame;

  for i := 0 to CTAOCompResultCount-1 do
  begin
    with CTAOCompResult[i] do
      AOutStrings.Add( Format( 'i=3.%d Same=%s, A1Ind=%d, A2Ind=%d, A1Num=%d, A2Num=%d',
                [i, N_B2S(IsSame), CTAOA1FirstInd, CTAOA2FirstInd, CTAOA1NumElemes, CTAOA2NumElemes] ));
    IsSame := not IsSame;
  end; // for i := 0 to CTAOCompResultCount-1 do
end; // procedure TN_CompTwoArraysObj.CTAOShowResAsStrings2

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompTwoArraysObj\CTAOShowResAsStrings3
//**************************** TN_CompTwoArraysObj.CTAOShowResAsStrings3 ***
// Show CTAOCompResult as Strings, varian #3
//
//     Parameters
// AFunc1      - Func of Obj for receiving a Strings, assosiated with A1 array
// AFunc2      - Func of Obj for receiving a Strings, assosiated with A2 array
// AColWidth   - one column width (not counting index and gaps sizes)
// AFlags      - format flags
// AOutStrings - Resulting Strings
//
// AInpStrings1 and AInpStrings2 should represent some how two Arrays, that were
// compared Resulting Strings will be prepared as two columns with AInpStrings 
// 1, 2 in columns 1, 2 For Same intervals in CTAOCompResult appropriate 
// InpStrings will be in the same row
//
// One AOutStrings row format:
//
// Ind1 aaaa_left_column_bbbbbbbb  =  Ind2 aaaa_right_column_bbbbbbbb
//
procedure TN_CompTwoArraysObj.CTAOShowResAsStrings3( AFunc1, AFunc2: TN_StrFuncObjInt;
                            AColWidth, AFlags: Integer; AOutStrings: TStrings );
var
  i, j, IndA1, IndA2, jMax, IndLeng: Integer;
  Str1, Str2, DelimStr, EllStr: String;
  IsSame: Boolean;
begin
  EllStr := '....';

  AOutStrings.Add( Format( 'First_Same=%s, Num_Intervals=%d,  Num_Same_Elements=%d,  Not_Same_in_A1=%d, Not_Same_in_A2=%d',
            [N_B2S(CTAOFirstElemIsSame),
                          CTAOCompResultCount, CTAONumSameElems,
                          CTAONumNotSameElemsA1, CTAONumNotSameElemsA2] ));
  AOutStrings.Add( '' );
//  Exit;

  IsSame := CTAOFirstElemIsSame;

//  jMax := max( AInpStrings1.Count, AInpStrings2.Count );
  jMax := 1000;

  IndLeng := Round( Ceil( Log10( jMax+1 )));

  for i := 0 to CTAOCompResultCount-1 do
  begin
    with CTAOCompResult[i] do
    begin
//      N_Dump2Str( Format( 'i=%d', [i] )); // debug
      if IsSame then // Interval of Same elements
      begin
        DelimStr := '  =  ';

        for j := 0 to CTAOA1NumElemes-1 do // along same elements, CTAOA1NumElemes = CTAOA2NumElemes
        begin
          IndA1 := CTAOA1FirstInd + j;

          if IndA1 = 141 then // debug
            N_i := 1;

          Str1 := Format( '%*.d ', [IndLeng, IndA1] ) +
              N_FormatString( AFunc1(IndA1), EllStr, AColWidth, AFlags );

          IndA2 := CTAOA2FirstInd + j;
          Str2 := Format( '%*.d ', [IndLeng, IndA2] ) +
              N_FormatString( AFunc2(IndA2), EllStr, AColWidth, AFlags );

          AOutStrings.Add( Str1 + DelimStr + Str2 );
        end; // for j := 0 to CTAOA1NumElemes-1 do
      end else // IsSame=False, two Intervals of not Same elements
      begin
        jMax := max( CTAOA1NumElemes, CTAOA2NumElemes ) - 1;

        for j := 0 to jMax do // along not same elements
        begin
          DelimStr := '  !  ';

          if j < CTAOA1NumElemes then // A1 element exists
          begin
            IndA1 := CTAOA1FirstInd + j;
            Str1 := Format( '%*.d ', [IndLeng, IndA1] ) +
                N_FormatString( AFunc1(IndA1), EllStr, AColWidth, AFlags );
          end else // no A1 element
          begin
            Str1 := DupeString( ' ', IndLeng + 1 + AColWidth );
            DelimStr := '     ';
          end;

          if j < CTAOA2NumElemes then // A2 element exists
          begin
            IndA2 := CTAOA2FirstInd + j;
            Str2 := Format( '%*.d ', [IndLeng, IndA2] ) +
                N_FormatString( AFunc2(IndA2), EllStr, AColWidth, AFlags );
          end else // no A2 element
          begin
            Str2 := DupeString( ' ', IndLeng + 1 + AColWidth );
            DelimStr := '     ';
          end;

          AOutStrings.Add( Str1 + DelimStr + Str2 );
        end; // for j := 0 to jMax do // along not same elements
      end; // else // IsSame=False, two Intervals of not Same elements

      IsSame := not IsSame;
    end; // with CTAOCompResult[i] do
  end; // for i := 0 to CTAOCompResultCount-1 do

end; // procedure TN_CompTwoArraysObj.CTAOShowResAsStrings3

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompTwoArraysObj\CTAOShowResAsStrings4
//**************************** TN_CompTwoArraysObj.CTAOShowResAsStrings4 ***
// Show CTAOCompResult as Strings, varian #4
//
//     Parameters
// AFunc1      - Func of Obj for receiving a Strings, assosiated with A1 array
// AFunc2      - Func of Obj for receiving a Strings, assosiated with A2 array
// AColWidth   - one column width (not counting index and gaps sizes)
// AFlags      - format flags
// AOutStrings - Resulting Strings
//
// AInpStrings1 and AInpStrings2 should represent some how two Arrays, that were
// compared Resulting Strings will be prepared as two columns with AInpStrings 
// 1, 2 in columns 1, 2 For Same intervals in CTAOCompResult appropriate 
// InpStrings will be in the same row
//
// One AOutStrings row format:
//
// Ind1 aaaa_left_column_bbbbbbbb  =  Ind2 aaaa_right_column_bbbbbbbb
//
procedure TN_CompTwoArraysObj.CTAOShowResAsStrings4( AFunc1, AFunc2: TN_StrFuncObjInt;
                            AColWidth, AFlags: Integer; AOutStrings: TStrings );
var
  i, j, IndA1, IndA2, jMax, IndLeng: Integer;
  Str1, Str2, DelimStr, EllStr: String;
  IsSame: Boolean;
begin
  EllStr := '....';

  AOutStrings.Add( Format( 'First_Same=%s, Num_Intervals=%d,  Num_Same_Elements=%d,  Not_Same_in_A1=%d, Not_Same_in_A2=%d',
            [N_B2S(CTAOFirstElemIsSame),
                          CTAOCompResultCount, CTAONumSameElems,
                          CTAONumNotSameElemsA1, CTAONumNotSameElemsA2] ));
  AOutStrings.Add( '' );
//  Exit;

  IsSame := CTAOFirstElemIsSame;

//  jMax := max( AInpStrings1.Count, AInpStrings2.Count );
  jMax := 1000;

  IndLeng := Round( Ceil( Log10( jMax+1 )));

  for i := 0 to CTAOCompResultCount-1 do
  begin
    with CTAOCompResult[i] do
    begin
//      N_Dump2Str( Format( 'i=%d', [i] )); // debug

      if IsSame then //**************************** Interval of Same elements
      begin
        AOutStrings.Add( '' );
        AOutStrings.Add( Format( '*** Interval %d with %d SAME elements:',
                                                       [i,CTAOA1NumElemes] ) );
        DelimStr := '  =  ';

        for j := 0 to CTAOA1NumElemes-1 do // along same elements, CTAOA1NumElemes = CTAOA2NumElemes
        begin
          if (j >= (CTAONumSameToShow-1)) and (j < (CTAOA1NumElemes-CTAONumSameToShow)) then
          begin
            if j = (CTAONumSameToShow-1) then
              AOutStrings.Add( '  ....  ' );

            Continue; // do not show elements in the middle of same elements
          end;

          IndA1 := CTAOA1FirstInd + j;

          if IndA1 = 141 then // debug
            N_i := 1;

          Str1 := Format( '%3.d %*.d ', [i, IndLeng, IndA1] ) +
              N_FormatString( AFunc1(IndA1), EllStr, AColWidth, AFlags );

          IndA2 := CTAOA2FirstInd + j;
          Str2 := Format( '%3.d %*.d ', [i, IndLeng, IndA2] ) +
              N_FormatString( AFunc2(IndA2), EllStr, AColWidth, AFlags );

          AOutStrings.Add( Str1 + DelimStr + Str2 );
        end; // for j := 0 to CTAOA1NumElemes-1 do
      end else //*********** IsSame=False, two Intervals of not Same elements
      begin
        AOutStrings.Add( '' );
        AOutStrings.Add( Format( '*** Interval %d with NOT same (%d, %d) elements:',
                                        [i,CTAOA1NumElemes,CTAOA2NumElemes] ) );

        jMax := max( CTAOA1NumElemes, CTAOA2NumElemes ) - 1;

        for j := 0 to jMax do // along not same elements
        begin
          DelimStr := '  !  ';

          if j < CTAOA1NumElemes then // A1 element exists
          begin
            IndA1 := CTAOA1FirstInd + j;
            Str1 := Format( '%3.d %*.d ', [i, IndLeng, IndA1] ) +
                N_FormatString( AFunc1(IndA1), EllStr, AColWidth, AFlags );
          end else // no A1 element
          begin
            Str1 := DupeString( ' ', IndLeng + 1 + AColWidth );
            DelimStr := '     ';
          end;

          if j < CTAOA2NumElemes then // A2 element exists
          begin
            IndA2 := CTAOA2FirstInd + j;
            Str2 := Format( '%3.d %*.d ', [i, IndLeng, IndA2] ) +
                N_FormatString( AFunc2(IndA2), EllStr, AColWidth, AFlags );
          end else // no A2 element
          begin
            Str2 := DupeString( ' ', IndLeng + 1 + AColWidth );
            DelimStr := '     ';
          end;

          AOutStrings.Add( Str1 + DelimStr + Str2 );
        end; // for j := 0 to jMax do // along not same elements
      end; // else // IsSame=False, two Intervals of not Same elements

      IsSame := not IsSame;
    end; // with CTAOCompResult[i] do
  end; // for i := 0 to CTAOCompResultCount-1 do

end; // procedure TN_CompTwoArraysObj.CTAOShowResAsStrings4

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompTwoArraysObj\CTAOSameString
//*********************************** TN_CompTwoArraysObj.CTAOSameString ***
// Compare two given Strings
//
//     Parameters
// APtr1  - Pointer to first char of first String to compare
// APtr2  - Pointer to first char of second String to compare
// Result - Return True if both Strings are the same
//
function TN_CompTwoArraysObj.CTAOSameString( APtr1, APtr2: Pointer ): boolean;
begin
  Result := PString(APtr1)^ = PString(APtr2)^;
end; // function TN_CompTwoArraysObj.CTAOSameString

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_CompTwoArraysObj\CTAOSameIntOrString
//****************************** TN_CompTwoArraysObj.CTAOSameIntOrString ***
// Compare two given records of Integer and String
//
//     Parameters
// APtr1  - Pointer to  first record to compare
// APtr2  - Pointer to second record to compare
// Result - Return True if both records are the same
//
// If Integer > 0 then records are the same if Integers are the same, otherwise 
// compare strings
//
function TN_CompTwoArraysObj.CTAOSameIntOrString( APtr1, APtr2: Pointer ): boolean;
var
  Integer1: Integer;
begin
  Integer1 := PInteger(APtr1)^;

  N_i2     := PInteger(APtr2)^; // debug
  N_s1     := PString(TN_BytesPtr(APtr1)+4)^; // debug
  N_s2     := PString(TN_BytesPtr(APtr2)+4)^; // debug

  if Integer1 > 0 then // ignore strings, just compare two integers
  begin
    Result := Integer1 = PInteger(APtr2)^;
  end else // Integer1 <= 0, ignore integers, just compare two strings
  begin
    Result := PString(TN_BytesPtr(APtr1)+4)^ = PString(TN_BytesPtr(APtr2)+4)^;
  end;

end; // function TN_CompTwoArraysObj.CTAOSameIntOrString


//********** TN_LogObj class methods  **************

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_LogObj\CreateByLogName
//*********************************************** TN_LogObj.CreateByLogName ***
// TN_LogObj constructor by given Log File Name
//
//     Parameters
// ALogFName - given File Name for saving Log
// AFlags    - given Flags
//
constructor TN_LogObj.CreateByLogName( const ALogFName: String; AFlags: TN_LogObjFlags );
var
  Str: String;
begin
  LOSL := nil; // clear previous strings if any
  LOFlags := AFlags;

  if ALogFName <> '' then
  begin
    LOFileName := ALogFName;    // File Name to save Log
    LOSL := TStringList.Create; // for Collecting Log strings
    LOSL.Add( '' );
    DateTimeToString( Str, 'yyyy/mm/dd hh:nn:ss.zzz', Now() );
    LOSL.Add( '************** New Log portion at ' + Str );
    LOSL.Add( '' );

    ForceDirectories( ExtractFilePath( LOFileName ) );
  end;
end; //*** end of Constructor TN_LogObj.CreateByLogName

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_LogObj\Destroy
//******************************************************* TN_LogObj.Destroy ***
//
//
destructor TN_LogObj.Destroy();
begin
//  if LOSL <> nil then
//    LOSL.SaveToFile( LOFileName );

  LOSL.Free;
end; // destructor TN_LogObj.Destroy

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_LogObj\LOAdd
//********************************************************* TN_LogObj.LOAdd ***
// Collect given Log String
//
procedure TN_LogObj.LOAdd( Astr: String );
begin
  if LOSL <> nil then
  begin
    LOSL.Add( AStr );
//    N_AddStrToFile2( AStr, LOFileName );
  end;
end; // procedure TN_LogObj.LOAdd

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_LogObj\LOSaveToFile
//************************************************** TN_LogObj.LOSaveToFile ***
// Save collected Log Strings to File
//
procedure TN_LogObj.LOSaveToFile();
begin
//  Exit;
  if LOSL <> nil then
  begin
    if lofCumLog in LOFlags then // cumulative log, add LOSL to existing file
    begin
      if Length( LOSL.Text ) >= 1 then
        N_AddToBinFile( LOFileName, @LOSL.Text[1], Length( LOSL.Text ) );
    end else // overwrite existing file
      LOSL.SaveToFile( LOFileName );
  end;
end; // procedure TN_LogObj.LOSaveToFile


//********** TN_RecordsBufObj class methods  **************

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_RecordsBufObj\CreateBySize
//**************************************** TN_RecordsBufObj.CreateBySize ***
// TN_RecordsBufObj constructor by given Buf Size
//
//     Parameters
// ALogFName - given File Name for saving Log
//
constructor TN_RecordsBufObj.CreateBySize( ABufSize: Integer );
begin
  RBBufSize := ABufSize;
  SetLength( RBBuf, RBBufSize );
end; //*** end of Constructor TN_RecordsBufObj.CreateBySize

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_RecordsBufObj\Destroy
//********************************************* TN_RecordsBufObj.Destroy ***
//
//
destructor TN_RecordsBufObj.Destroy();
begin
  RBBuf := nil;
end; // destructor TN_RecordsBufObj.Destroy

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\TN_RecordsBufObj\RBAddRecord
//***************************************** TN_RecordsBufObj.RBAddRecord ***
// Collect given Log String
//
//     Parameters
// ARecPtr  - Pointer to record to save in Self RBBuf
// ArecSize - Record Size in Bytes
// Result   - Return Pointer to saved record in RBBuf
//
function TN_RecordsBufObj.RBAddRecord( ARecPtr: Pointer; ArecSize: integer ): Integer;
var
  NeededSize: Integer;
begin
  Result := RBFreeInd;
  NeededSize := RBFreeInd + ArecSize;

  if NeededSize > RBBufSize then
  begin
    RBBufSize := 2 * NeededSize;
    SetLength( RBBuf, RBBufSize );
  end;

  move( ARecPtr^, RBBuf[RBFreeInd], ArecSize );
  RBFreeInd := NeededSize;
end; // function TN_RecordsBufObj.RBAddRecord


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CPUCounter
//************************************************************ N_CPUCounter ***
// Get CPU Clock counter
//
//     Parameters
// Result - Returns CPU Clock counter as Int64 (in EAX, EDX)
//
function N_CPUCounter(): Int64; assembler;
  asm  // (without begin - end brackets!)
    dw 310Fh // rdtsc
end; // function N_CPUCounter

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetCPUFrequency
//******************************************************* N_GetCPUFrequency ***
// Get CPU frequency
//
//     Parameters
// ADelayTime - measearing interval in milliseconds (accuracy is about 3.e-6 for
//              DelayTime=100 milliseconds)
// Result     - Returns CPU Frequency in HZ (not in MHZ!)
//
// Set several Time related constants:
//#F
//   N_EpsCPUTimer1,2       - Start/Stop Expenses for TN_CPUTimer1 and TN_CPUTimer2,
//   N_PerformanceFrequency - (for using QueryPerformanceCounter) or -1 if not available,
//   N_ProcHandle           - Self Process Handle,
//   N_EpsPerfCounter       - QueryPerformanceCounter expenses
//#/F
//
function N_GetCPUFrequency( ADelayTime: integer ): double;
var
  SumDelta1, PriorityClass, Priority: Integer;
  PerfFrec, PerfCounter1, PerfCounter2: Int64;
begin
  // QueryPerformanceCounter enables about 1 mcs accuracy

  N_ProcHandle := GetCurrentProcess();
  N_PerformanceFrequency := -1;
  PerfFrec := 0;
  N_EpsPerfCounter := 0;

  if QueryPerformanceFrequency( PerfFrec ) then
  begin
    N_PerformanceFrequency := PerfFrec; // F=3.579545 MHz or CPU frequency
    QueryPerformanceCounter( PerfCounter1 );     // Counts from PowerOn
    QueryPerformanceCounter( PerfCounter2 );
    N_EpsPerfCounter := PerfCounter2 - PerfCounter1; // QueryPerformanceCounter expense
  end;

  //**** for calculating N_EpsCPUTimer1, N_EpsCPUTimer2
  //     ( Start/Stop Expenses for TN_CPUTimer1 and TN_CPUTimer2 )
  //     measure 5 times and get average value

  N_EpsCPUTimer1 := 0;
  N_EpsCPUTimer2 := 0;
  SumDelta1 := 0;
  N_T2.Clear( 1 );

  //***************** Get Start/Stop expense #1
  N_T1.Start();
  N_T1.Stop();
  SumDelta1 := SumDelta1 + integer(N_T1.DeltaCounter);
  N_T2.Start(0);
  N_T2.Stop(0);

  //***************** Get Start/Stop expense #2
  N_T1.Start();
  N_T1.Stop();
  SumDelta1 := SumDelta1 + integer(N_T1.DeltaCounter); // #2
  N_T2.Start(0);
  N_T2.Stop(0);

  //***** set highest priority to process and Thread
  PriorityClass := GetPriorityClass( N_ProcHandle );
  Priority := GetThreadPriority( GetCurrentThread() );

  //***************** Get Start/Stop expense #3
  N_T1.Start();
  N_T1.Stop();
  SumDelta1 := SumDelta1 + integer(N_T1.DeltaCounter); // #3
  N_T2.Start(0);
  N_T2.Stop(0);

  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);

  //***** main delay, get N_T1.DeltaCounter

  QueryPerformanceCounter( PerfCounter1 );
  N_T1.Start();
  Sleep( ADelayTime ); //***** Main Delay (wait for DelayTime milliseconds)
  N_T1.Stop();
  QueryPerformanceCounter( PerfCounter2 );

  //***** restore original priority
  SetThreadPriority( GetCurrentThread(), Priority );
  SetPriorityClass( N_ProcHandle, PriorityClass );

  Result := N_T1.DeltaCounter; // convert to double

  //***************** Get Start/Stop expense #4
  N_T1.Start();
  N_T1.Stop();
  SumDelta1 := SumDelta1 + integer(N_T1.DeltaCounter);
  N_T2.Start(0);
  N_T2.Stop(0);

  //***************** Get Start/Stop expense #5
  N_T1.Start();
  N_T1.Stop();
  SumDelta1 := SumDelta1 + integer(N_T1.DeltaCounter);
  N_T2.Start(0);
  N_T2.Stop(0);

  N_EpsCPUTimer1 := Round( SumDelta1 / 5 );
  N_EpsCPUTimer2 := Round( N_T2.Items[0].DeltaCounter / 5 );

  if N_PerformanceFrequency = -1 then // QueryPerformanceCounter does not work
    Result := (Result-N_EpsCPUTimer1)*1000 / ADelayTime // CPU Frequency in HZ
  else // use PerfCounter1,2
    Result := (Result-N_EpsCPUTimer1)*PerfFrec /
              (PerfCounter2-PerfCounter1-N_EpsPerfCounter); // CPU Frequency in HZ
end; // function N_GetCPUFrequency

//*********************************************************** N_DelayByLoop ***
// Do something for given number of milliseconds
// (min value about 0.3 mcsec. on 2GHZ CPU)
//
procedure N_DelayByLoop( AMilliSeconds: double );
var
  i, imax: Int64;
  dtmp: double;
begin
  i := 0;
  dtmp := 1.0;
  imax := Round( ( AMilliSeconds*1.0e-3 - 0.2e-6 ) * N_CPUFrequency / 31.94 );

  while i < imax do
  begin
    dtmp := 0.1*dtmp + 1.0;
    Inc( i );
  end; // for i := 0 to imax do
end; // end of procedure N_DelayByLoop

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SecondsToString1
//****************************************************** N_SecondsToString1 ***
// Convert given value of seconds to text
//
//     Parameters
// ASeconds - given seconds value
// AFmt     - needed Pascal format (%5.2f is used if not given)
// Result   - Returns string in the following format:
//#F
//   xx.x units
//#/F
// where    - units is sec, msec, mcsec or nsec.
//
function N_SecondsToString1( ASeconds: double; AFmt: string ): string;
var
  TimeUnitsSign: integer;
  StrUnits: string;
  TimeUnits: double;

begin
  TimeUnitsSign := 1;
  if ASeconds <= 0 then
  begin
    ASeconds := -ASeconds;
    TimeUnitsSign := -1;
  end;

  StrUnits  := 'nsec. ';
  TimeUnits := ASeconds*1.0e9;

  if ASeconds > 100e-9 then
  begin
    StrUnits := 'mcsec.';
    TimeUnits := ASeconds*1.0e6;
  end;

  if ASeconds > 100e-6 then
  begin
    StrUnits := 'msec. ';
    TimeUnits := ASeconds*1.0e3;
  end;

  if ASeconds > 100e-3 then
  begin
    StrUnits := 'sec.  ';
    TimeUnits := ASeconds;
  end;

  if AFmt = '' then // AFmt is not given, use default value
  begin
    if TimeUnits < 10 then AFmt := '%5.3f'
                      else AFmt := '%5.2f';
  end;

  Result := Format( AFmt+' %s', [TimeUnitsSign*TimeUnits, StrUnits ] );
end; // procedure N_SecondsToString1

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_DataSizeToString
//****************************************************** N_DataSizeToString ***
// Convert given data size to text
//
//     Parameters
// ADataSize - given data size
// AFmt      - needed Pascal format (format with three digits is used if not 
//             given)
// Result    - Return string that represents Data size in appropriate units
//
// Here are some exapmles with default formatting: 999 bytes, 1 KB, 9.99 KB, 
// 99.9 KB, 999 KB, 1 MB, 1 GB.
//
function N_DataSizeToString( ADataSize: Int64; AFmt: string ): string;
var
  StrUnits, DefFmt: string;
  SizeInUnits: double;
begin
  // used if 0 <= ADataSize < 1024 (units are bytes)
  StrUnits    := 'bytes';
  SizeInUnits := ADataSize;
  DefFmt := '%3.0f';

  if ADataSize >= N_BytesInKB then // N_BytesInKB <= ADataSize < N_BytesInMB (units are Kilobytes)
  begin
    StrUnits    := 'KB';
    SizeInUnits := ADataSize/N_BytesInKB;
    DefFmt := '%4.2f'; // 9.99 KB

    if SizeInUnits >= 10  then DefFmt := '%4.1f'; // 99.9 KB
    if SizeInUnits >= 100 then DefFmt := '%3.0f'; //  999 KB
  end; // if ADataSize >= 1000 then // 1e3 <= ADataSize < 1e6 (units are Kilobytes)

  if ADataSize >= N_BytesInMB then // N_BytesInMB <= ADataSize < N_BytesInGB (units are Megabytes)
  begin
    StrUnits := 'MB';
    SizeInUnits := ADataSize/N_BytesInMB;
    DefFmt := '%4.2f'; // 9.99 MB

    if SizeInUnits >= 10  then DefFmt := '%4.1f'; // 99.9 MB
    if SizeInUnits >= 100 then DefFmt := '%3.0f'; //  999 MB
  end; // if ADataSize >= 1e6 then // 1e6 <= ADataSize < 1e9 (units are Megabytes)

  if ADataSize >= N_BytesInGB then // N_BytesInGB <= ADataSize (units are Gigabytes)
  begin
    StrUnits    := 'GB';
    SizeInUnits := ADataSize/N_BytesInGB;
    DefFmt := '%4.2f'; // 9.99 GB

    if SizeInUnits >= 10  then DefFmt := '%4.1f'; // 99.9 GB
    if SizeInUnits >= 100 then DefFmt := '%3.0f'; //  999 GB
  end; // if ADataSize >= 1e9 then // 1e9 <= ADataSize < 1e12 (units are Gigabytes)

  if AFmt <> '' then DefFmt := AFmt; // AFmt is given, use it
  Result := Format( DefFmt + ' %s', [SizeInUnits, StrUnits ] );
end; // procedure N_DataSizeToString

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SecondsToString
//******************************************************* N_SecondsToString ***
// Convert given value in seconds to text
//
//     Parameters
// ASeconds - value in seconds
// AFmt     - needed Pascal format (format with three digits is used if not 
//            given)
// Result   - Return string that represents Data size in appropriate units
//
// Here are some exapmles with default formatting: 0.999 nsec., 9.99 nsec., 99.9
// nsec., 999 nsec., 1 mcsec., 1 msec., 1 sec., 59.9 sec., 1 min., 59.9 min., 1 
// hr., 23.9 hr., 1 day, 999 day
//
function N_SecondsToString( ASeconds: double; AFmt: string ): string;
var
  StrUnits, DefFmt: string;
  SizeInUnits: double;
begin
  // used if ASeconds < 1.0e-6 (units are nanoseconds)
  StrUnits    := 'nsec.';
  SizeInUnits := ASeconds*1.0e9;
  DefFmt := '%4.2f'; // 9.99 nsec.

  if ASeconds >= 1.0e-8 then DefFmt := '%4.1f'; // 99.9 nsec.
  if ASeconds >= 1.0e-7 then DefFmt := '%3.0f'; //  999 nsec.

  if ASeconds >= 1.0e-6 then // 1.0e-6 <= ASeconds < 1.0e-3 (units are microseconds)
  begin
    StrUnits    := 'mcsec.';
    SizeInUnits := ASeconds*1.0e6;
    DefFmt := '%4.2f'; // 9.99 mcsec.

    if SizeInUnits >= 10  then DefFmt := '%4.1f'; // 99.9 mcsec.
    if SizeInUnits >= 100 then DefFmt := '%3.0f'; //  999 mcsec.
  end; // if ASeconds >= 1.0e-6 then // 1.0e-6 <= ASeconds < 1.0e-3 (units are microseconds)

  if ASeconds >= 1.0e-3 then // 1.0e-3 <= ASeconds < 1.0 (units are milliseconds)
  begin
    StrUnits    := 'msec.';
    SizeInUnits := ASeconds*1.0e3;
    DefFmt := '%4.2f'; // 9.99 msec.

    if SizeInUnits >= 10  then DefFmt := '%4.1f'; // 99.9 msec.
    if SizeInUnits >= 100 then DefFmt := '%3.0f'; //  999 msec.
  end; // if ASeconds >= 1.0e-3 then // 1.0e-3 <= ASeconds < 1.0 (units are milliseconds)

  if ASeconds >= 1.0 then // 1.0 <= ASeconds < 60 (units are seconds)
  begin
    StrUnits    := 'sec.';
    SizeInUnits := ASeconds;
    DefFmt := '%4.2f'; // 9.99 sec.

    if SizeInUnits >= 10 then DefFmt := '%4.1f'; // 59.9 sec.
  end; // if ASeconds >= 1.0 then // 1.0 <= ASeconds < 60 (units are seconds)

  if ASeconds >= 60 then // 60 <= ASeconds < 3600 (units are minutes)
  begin
    StrUnits    := 'min.';
    SizeInUnits := ASeconds/60;
    DefFmt := '%4.2f'; // 9.99 min.

    if SizeInUnits >= 10 then DefFmt := '%4.1f'; // 59.9 min.
  end; // if ASeconds >= 1.0 then // 1.0 <= ASeconds < 60 (units are seconds)

  if ASeconds >= 3600 then // 3600 <= ASeconds < 3600*24 (units are hours)
  begin
    StrUnits    := 'hr.';
    SizeInUnits := ASeconds/3600;
    DefFmt := '%4.2f'; // 9.99 hr.

    if SizeInUnits >= 10 then DefFmt := '%4.1f'; // 59.9 hr.
  end; // if ASeconds >= 3600 then // 3600 <= ASeconds < 3600*24 (units are hours)

  if ASeconds >= 3600*24 then // 360024 <= ASeconds (units are days)
  begin
    StrUnits    := 'days';
    SizeInUnits := (ASeconds/3600)/24;
    DefFmt := '%4.2f'; // 9.99 days

    if SizeInUnits >= 10  then DefFmt := '%4.1f'; // 99.9 days
    if SizeInUnits >= 100 then DefFmt := '%3.0f'; // 999 days
  end; // if ASeconds >= 3600*24 then // 360024 <= ASeconds (units are days)

  if AFmt <> '' then DefFmt := AFmt; // AFmt is given, use it
  Result := Format( DefFmt + ' %s', [SizeInUnits, StrUnits ] );
end; // procedure N_SecondsToString


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_TimeToString
//********************************************************** N_TimeToString ***
// convert given WholeTime in days divided by NTimes to string in the following 
// format: xx.x units (%acc), where units - sec, msec, mcsec, nsec, acc   - time
// interval accuracy in percents (if > 0.01%)
//
// NTimes = -1 means using TN_CPUTimer1 methods instead of Time function with 
// much better accuracy
//
function N_TimeToString( WholeTime: double; NTimes: integer ): string;
var
  StrUnits, Fmt: string;
  TimeUnits, Seconds, WholeSeconds, Percents: double;
begin
  if WholeTime < 0 then WholeTime := -WholeTime; // really may be
  if WholeTime = 0 then
  begin
    Result := '0.000 nsec ';
    Exit;
  end;

  WholeSeconds := WholeTime*N_SecondsInDay;

  if NTimes = -1 then // return only error
  begin
    // absolute error is about 5 - 10 CPU clock
    Percents := 100 * (10 / N_CPUFrequency) / WholeSeconds; // accuracy in percents

    if Percents > 99 then
      Result := '(>99%)'
    else if Percents > 0.1 then
      Result := Format( '(%.1f%s)', [Percents, '%'] )
    else
      Result := '';

    Exit;
  end; // if NTimes = -1 then // return only error

  if NTimes = 0 then
  begin
    Result := '(N=0!)';
    Exit;
  end;

  Seconds := WholeSeconds / NTimes;

  StrUnits  := 'nsec. ';
  TimeUnits := Seconds*1.0e9;

  if Seconds > 100e-9 then
  begin
    StrUnits := 'mcsec.';
    TimeUnits := Seconds*1.0e6;
  end;

  if Seconds > 100e-6 then
  begin
    StrUnits := 'msec. ';
    TimeUnits := Seconds*1.0e3;
  end;

  if Seconds > 100e-3 then
  begin
    StrUnits := 'sec.  ';
    TimeUnits := Seconds;
  end;

  if TimeUnits < 10 then Fmt := '%5.3f'
                    else Fmt := '%5.2f';

  Result := Format( Fmt+' %s', [TimeUnits, StrUnits ] );
end; // procedure N_TimeToString


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_IsDecimalDigit
//***************************************************** N_IsDecimalDigit ***
// Check if given AChar is a Decimal Digit (0,1,...,9)
//
//     Parameters
// AChar  - given Char to check
// Result - Return True if AChar is '0', '1', ... '8' or '9'
//
function N_IsDecimalDigit( AChar: Char ): boolean;
begin
  Result := ('0' <= AChar) and ('9' >= AChar);
end; // function N_IsDecimalDigit

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_IsLatinLetter
//****************************************************** N_IsLatinLetter ***
// Check if given AChar is a Latin Letter (a, ..., z, A, ..., Z)
//
//     Parameters
// AChar  - given Char to check
// Result - Return True if AChar is 'a', ..., 'z', 'A', ..., 'Z'
//
function N_IsLatinLetter( AChar: Char ): boolean;
begin
  Result := (('a' <= AChar) and ('z' >= AChar)) or (('A' <= AChar) and ('Z' >= AChar));
end; // function N_IsLatinLetter

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_IsWin1251CyrLetter
//************************************************* N_IsWin1251CyrLetter ***
// Check if given AChar is a Windows 1251 Cyrillic Letter (a, ..., я, A, ..., Я)
//
//     Parameters
// AChar  - given Char to check
// Result - Return True if AChar is a Cyrillic Letter
//
function N_IsWin1251CyrLetter( AAnsiChar: AnsiChar ): boolean;
var
  IntChar: integer;
begin
  IntChar := integer(AAnsiChar);

  Result := (168 = IntChar) or (184 = IntChar) or   // Ё=168=$A8 or ё=184=$B8 or
           ((192 <= IntChar) and (255 >= IntChar)); // in (А=192=$C0, я=255=$FF)
end; // function N_IsWin1251CyrLetter

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_IsUNICODECyrLetter
//************************************************* N_IsUNICODECyrLetter ***
// Check if given AChar is a UNICODE Cyrillic Letter (a, ..., я, A, ..., Я)
//
//     Parameters
// AChar  - given Char to check
// Result - Return True if AChar is a Cyrillic Letter
//
function N_IsUNICODECyrLetter( AWideChar: WideChar ): boolean;
var
  IntChar: integer;
begin
  IntChar := integer(AWideChar);

  Result := ($401 = IntChar) or ($451 = IntChar) or   // Ё=1025=$401  or ё=1105=$451 or
           (($410 <= IntChar) and ($44F >= IntChar)); // in (А=1040=$410, я=1103=$44F)  (Я=1071=$42F, a=1072=$430)
end; // function N_IsUNICODECyrLetter

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_IsCyrLetter
//*********************************************************** N_IsCyrLetter ***
// Check if given AChar is a Cyrillic Letter (a, ..., я, A, ..., Я)
//
//     Parameters
// AChar  - given Char to check
// Result - Return True if AChar is a Cyrillic Letter
//
// N_IsUNICODECyrLetter is used for Delphi 2010 and N_IsWin1251CyrLetter for 
// Delphi 7
//
function N_IsCyrLetter( AChar: Char ): boolean;
begin
{$IF SizeOf(Char) = 2} // Wide Chars (Delphi 2010) Types and constants
  Result := N_IsUNICODECyrLetter( WideChar(AChar) )
{$ELSE} //*************** Ansi Chars (Delphi 7) Types and constants
    Result := N_IsWin1251CyrLetter( AnsiChar(AChar) );
{$IFEND}
end; // function N_IsCyrLetter

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ConvToProperName
//*************************************************** N_ConvToProperName ***
// Convert given AStr To Proper Name
//
//     Parameters
// AStr   - given string to convert
// Result - Return converted AStr
//
// Function removes all chars except Alpha, Digit and '_' (underscore)
//
function N_ConvToProperName( AStr: string ): string;
var
  IndSrc, IndRes: integer;
  CurChar: Char;
begin
  SetLength( Result, Length(AStr) ); // max possible size
  IndRes := 1;

  for IndSrc := 1 to Length(AStr) do // along all Src chars
  begin
    CurChar := AStr[IndSrc];

    if N_IsDecimalDigit( CurChar ) or (CurChar = '_') or
       N_IsLatinLetter( CurChar )  or N_IsCyrLetter( CurChar ) then
    begin
      Result[IndRes] := CurChar;
      Inc( IndRes );
    end;

  end; // for IndSrc := 1 to Length(AStr) do // along all Src chars

  SetLength( Result, IndRes-1 ); // final size
end; // function N_ConvToProperName

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReplaceCRLFbySpace
//************************************************* N_ReplaceCRLFbySpace ***
// Replace CR and LF characters by Space and remove additional spaces
//
//     Parameters
// AStr   - given string to convert
// Result - Return converted AStr
//
function N_ReplaceCRLFbySpace( AStr: string ): string;
var
  i: integer;
  CurChar: Char;
begin
  Result := AStr;

  for i := 1 to Length(Result) do
  begin
    CurChar := Result[i];

    if (CurChar = Char($0D)) or (CurChar = Char($0A)) then
      Result[i] := ' ';

  end; // for i := 1 to Length(Result) do
end; // function N_ReplaceCRLFbySpace

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_RemoveNonCyrChars
//************************************************** N_RemoveNonCyrChars ***
// Remove all not Cyrillic characters and additional spaces
//
//     Parameters
// AStr   - given string to convert
// Result - Return converted AStr
//
function N_RemoveNonCyrChars( AStr: string ): string;
var
  i, j: integer;
  CurChar: Char;
  PrevCharWasSpace: Boolean;
begin
  SetLength( Result, Length(AStr) );
  j := 1;
  PrevCharWasSpace := True;

  for i := 1 to Length(Result) do
  begin
    CurChar := AStr[i];

    if CurChar <= Char(' ') then
    begin
      if PrevCharWasSpace then Continue; // skip subsequent spaces

      PrevCharWasSpace := True;
      Result[j] := ' ';  Inc( j );
    end else // CurChar <> ' '
    begin
      PrevCharWasSpace := False;

      if not N_IsCyrLetter( CurChar ) then Continue;

      Result[j] := CurChar;  Inc( j );
    end;
  end; // for i := 1 to Length(Result) do

  SetLength( Result, j-1 );
end; // function N_RemoveNonCyrChars

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AddNotWhiteChars
//*************************************************** N_AddNotWhiteChars ***
// Add characters from AInpStr SubString to AOutStr, removing subsequent White 
// characters (spaces and special chracters) until AMaxOutPos character in 
// AOutStr
//
//     Parameters
// AInpStr      - given Input string with SubString to process inside it
// AInpFirstInd - index of First char in AInpStr to process (on Input and 
//                Output)
// AInpLastInd  - index of Last char in AInpStr to process (on Input only)
// AOutStr      - given Output string (where to add characters)
// AOutPos      - Position in AOutStr (on Input and Output)
// AMaxOutPos   - Max Position in AOutStr to fill (if AInpStr is large enough)
//
// On Output, AInpFirstInd-1 and AOutPos-1 are last processed positions 
// (AInpFirstInd and AOutPos will not be changed if no one character was 
// pocessed)
//
procedure N_AddNotWhiteChars( const AInpStr: string; var AInpFirstInd: Integer;
                              AInpLastInd: Integer; var AOutStr: string;
                              var AOutPos: Integer; AMaxOutPos: Integer );
var
  i, j, PrevOutLeng: integer;
  CurChar: Char;
  PrevCharWasWhite: Boolean;
  Label CheckEndOfAOutStr;
begin
  if AOutPos > AMaxOutPos then Exit; // a precaution

  PrevOutLeng := Length( AOutStr );
  SetLength( AOutStr, AMaxOutPos ); // set max possible length

  if PrevOutLeng <= AOutPos then // very small AOutStr, fill all chars before (including) AOutPos
  begin // assignment to AOutStr[AOutPos] may be needed for empty AInpStr
    for i := PrevOutLeng+1 to AOutPos do
      AOutStr[i] := ' ';
  end;

  j := AOutPos;
  PrevCharWasWhite := True;

  AInpLastInd := min( AInpLastInd, Length(AInpStr) ); // a precaution

  for i := AInpFirstInd to AInpLastInd do // along all inp characters
  begin
    CurChar := AInpStr[i];

    if CurChar <= Char(' ') then // CurChar is White (Space or special char)
    begin
      if PrevCharWasWhite then Continue; // skip subsequent White chars

      //*** Here: first White char

      PrevCharWasWhite := True;
      AOutStr[j] := ' ';
    end else // CurChar <> ' '
    begin
      PrevCharWasWhite := False;
      AOutStr[j] := CurChar;
    end;

    //*** Here: AOutStr[j] is OK, chack if end of AOutStr

    if j = AMaxOutPos then // end of AOutStr, all done
    begin
      AInpFirstInd := i + 1;
      AOutPos      := j + 1;
      Exit;
    end else // j < AMaxOutPos, Inc j and Continue
      Inc( j );

  end; // for i := AInpFirstInd to AInpLastInd do // along all inp characters

  //*** Here: End of all characters to add

  AInpFirstInd := AInpLastInd + 1;
  AOutPos := j;

  SetLength( AOutStr, AOutPos-1 ); // real final length
end; // procedure N_AddNotWhiteChars

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_RemoveSubsWhiteChars
//************************************************** N_RemoveSubsWhiteChars ***
// Remove all subsequent White chars
//
//     Parameters
// AStr   - given string to convert
// Result - Return converted AStr
//
// Rreplace all intervals of subsequent White chars by one space
//
function N_RemoveSubsWhiteChars( AStr: string ): string;
var
  InpFirstInd, OutPos: Integer;
begin
  Result := '';
  InpFirstInd := 1;
  OutPos := 1;
  N_AddNotWhiteChars( AStr, InpFirstInd, Length(AStr), Result, OutPos, Length(AStr) );
end; // N_RemoveSubsWhiteChars

//********************************************** N_CalcNumNotSubsWhiteChars ***
// Remove all subsequent White chars
//
//     Parameters
// AStr      - given string
// AFirstInd - Index of First SubString char in AStr
// ALastInd  - Index of Last SubString char in AStr
// Result    - Return Number of chars in given substring, not counting subsequent White chars
//
function N_CalcNumNotSubsWhiteChars( AStr: string; AFirstInd, ALastInd: Integer ): Integer;
var
  i: Integer;
  PrevCharWasWhite: Boolean;
begin
  Result := 0;

  if (AFirstInd > ALastInd) or (ALastInd > Length(AStr)) or
           (AFirstInd <= 0) then // bad AFirstInd, ALastInd
    Exit;

  PrevCharWasWhite := False;

  for i := AFirstInd to ALastInd do // along all given substring chars
  begin

    if AStr[i] <= ' ' then // AStr[i] is White char
    begin
      if not PrevCharWasWhite then
      begin
        Inc( Result );
        PrevCharWasWhite := True;
      end;
    end else // AStr[i] is NOT White char
    begin
      Inc( Result );
      PrevCharWasWhite := False;
    end;

  end; // for i := AFirstInd to ALastInd do // along all given substring chars

end; // N_CalcNumNotSubsWhiteChars

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SplitSubStrToStrings
//************************************************** N_SplitSubStrToStrings ***
// Split given SubString to smaller fragments and add them to given AOutStrings
//
//     Parameters
// AInpStr      - given string with SubString to split inside it
// AInpFirstInd - Index of First SubString char in AInpStr
// AInpLastInd  - Index of Last SubString char in AInpStr
// AOutStrings  - where to add splitted AStr frgments
// AMinPos      - min positinion in AOutStrings to place AStr frgments
// AMaxPos      - max positinion in AOutStrings to place AStr frgments
//
// Subsequent white chars will be removed from resulting fragments First
// splitted fragment will bee addeded to last AOutStrings line (till AMaxPos)
// Other splitted frgments (except last one) will be placed in AMinPos-AMaxPos
// positions
//
procedure N_SplitSubStrToStrings( const AInpStr: string; AInpFirstInd, AInpLastInd: Integer;
                                  AOutStrings: TStrings; AMinPos, AMaxPos: Integer );
var
  LastLineInd, InpPos, OutPos: integer;
  CurLine: String;
  Label AddNewLines;
begin
  N_S := AInpStr;
  N_i := Length( N_S );
  AInpLastInd := min( AInpLastInd, Length(AInpStr) );
//  if Length(AInpStr) <= AInpLastInd then Exit; // nothing to do
  if AMinPos > AMaxPos then Exit; // a precaution

  InpPos := AInpFirstInd;

  //***** Add chars to last AOutStrings line if needed

  LastLineInd := AOutStrings.Count - 1;

  if LastLineInd >= 0 then // AOutStrings not empty
  begin
    CurLine := AOutStrings[LastLineInd];

    if Length(CurLine) <= (AMaxPos-2) then // add chars to CurLine
    begin
      OutPos := Length(CurLine) + 1;
      N_AddNotWhiteChars( AInpStr, InpPos, AInpLastInd, CurLine, OutPos, AMaxPos );
      AOutStrings[LastLineInd] := CurLine;
    end; // if Length(CurLine) < AMaxPos then // add chars to CurLine

  end; // if LastLineInd >= 0 then // AOutStrings not empty

  //***** Add chars to new AOutStrings lines if needed

  AddNewLines: //********************

  if InpPos > AInpLastInd then // all input characters are processed, all done
     Exit;

  CurLine := '';
  OutPos := AMinPos;
  N_AddNotWhiteChars( AInpStr, InpPos, AInpLastInd, CurLine, OutPos, AMaxPos );

  if OutPos > AMinPos then // some chars was added to CurLine
    AOutStrings.Add( CurLine );

  goto AddNewLines;
end; // procedure N_SplitSubStrToStrings


var // data for N_CyrToLatChars function
  N_LatTokens: Array [1..192] of Char = // 3 * 2 * 32
        'A  B  V  G  D  YE ZH Z  I  Y  K  L  M  N  O  P  '+
        'R  S  T  U  F  KH TS CH SH SCH   Y     E  YU YA '+
        'a  b  v  g  d  ye zh z  i  y  k  l  m  n  o  p  '+
        'r  s  t  u  f  kh ts ch sh sch   y     e  yu ya ';

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CyrToLatChars
//********************************************************* N_CyrToLatChars ***
// Conv to UNICODE (replace Win1251 codes by UNICODE codes) and add Ё letter 
// support !!!
//
// Convert Russian String in Cyrillic (WINDOWS 1251) to Latin Characters
//
// Parameters ACyrStr - string in Cyrillic (WINDOWS 1251) Result  - Returns 
// string in latin transcription
//#F
// *****************  WINDOWS 1251 Decimal Codes  **********************
// А-192, Б-193, В-194, Г-195 Д-196, Е-197, Ж-198, З-199
// И-200, Й-201, К-202, Л-203 М-204, Н-205, О-206, П-207
// Р-208, С-209, Т-210, У-211 Ф-212, Х-213, Ц-214, Ч-215
// Ш-216, Щ-217, Ъ-218, Ы-219 Ь-220, Э-221, Ю-222, Я-223
// а-224, б-225, в-226, г-227 д-228, е-229, ж-230, з-231
// и-232  й-233, к-234, л-235 м-236, н-237, о-238, п-239
// р-240, с-241, т-242, у-243 ф-244, х-245, ц-246, ч-247
// ш-248, щ-249, ъ-250, ы-251 ь-252, э-253, ю-254, я-255
//   (In Hex: А-192=$C0, Я-223=$DF, а-224=$C0, я-255=$FF)
//   (Ё-168=$A8 and ё-184=$B8 are not supported in N_CyrToLatChars)
//#/F
//
function N_CyrToLatChars( ACyrStr: string ): string;
var
  CyrInd, LatInd, LTokenInd, CyrChar, PrevCyrChar, CyrLeng: integer;
  SkipYinYE, ToLower: boolean;
begin
  Result := '';
  CyrChar := 0; // to avoid warning;
  LatInd := 1;
  CyrLeng := Length(ACyrStr);
  SetLength( Result, 3*CyrLeng ); // set max possible at first, decrease later

  for CyrInd := 1 to CyrLeng do // along all Cyr chars
  begin
    PrevCyrChar := CyrChar;
    CyrChar := integer(ACyrStr[CyrInd]);

    if  (CyrChar = 218) or (CyrChar = 220) or //***  skip Ъ, Ь, ъ, ь
        (CyrChar = 250) or (CyrChar = 252) then Continue;

    if CyrChar < 192 then  // not a Cyrillic character
    begin
      Result[LatInd] := Char(CyrChar); // just copy character
      Inc( LatInd );
      Continue;
    end;

    LTokenInd := 1 + (CyrChar-192)*3;
    SkipYinYE := ((CyrChar = 197) or (CyrChar = 229)) and (CyrInd > 1) and // not first Е or е
                 not ( (PrevCyrChar < 192) or // after not Cyrillic or after not:
          (PrevCyrChar = 224) or // А  
          (PrevCyrChar = 192) or // а
          (PrevCyrChar = 229) or // Е
          (PrevCyrChar = 197) or // е
          (PrevCyrChar = 232) or // И
          (PrevCyrChar = 200) or // и
          (PrevCyrChar = 238) or // О
          (PrevCyrChar = 206) or // о
          (PrevCyrChar = 243) or // У
          (PrevCyrChar = 211) ); // у

    if SkipYinYE then // copy two chars
      move( N_LatTokens[LTokenInd+1], Result[LatInd], 2 )
    else // copy three chars
      move( N_LatTokens[LTokenInd], Result[LatInd], 3 );

    ToLower := (CyrInd < CyrLeng) and (integer(ACyrStr[CyrInd+1]) > 223); // next Cyr char exists and is small
    Inc( LatInd );

    if Result[LatInd] = ' ' then Continue; // end of lat loken
    if ToLower and (Result[LatInd] >= 'A') and (Result[LatInd] <= 'Z') then Inc( Result[LatInd], $20 );
    Inc( LatInd );

    if Result[LatInd] = ' ' then Continue; // end of lat loken
    if ToLower and (Result[LatInd] >= 'A') and (Result[LatInd] <= 'Z') then Inc( Result[LatInd], $20 );
    Inc( LatInd );

  end; // for CyrInd := 1 to Length(ACyrStr) do // along all Cyr chars

  SetLength( Result, LatInd );
end; // function N_CyrToLatChars

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CalcNumCyrChars
//**************************************************** N_CalcNumCyrChars ***
// Calculate Number of Cyr Characters in given fragment of given AString
//
//     Parameters
// AString   - given string
// AFirstInd - Index of first char to check
// ALastInd  - Index of last char to check
// Result    - number of Cyr Characters in given AString
//
// in Windows1251: А-192=$C0, Я-223=$DF, а-224=$E0, я-255=$FF, Ё-168=$A8, ё-184=$B8
//
function N_CalcNumCyrChars( const AString: string; AFirstInd, ALastInd: Integer ): Integer;
var
  i: Integer;
  CurChar: Char;
begin
  Result := 0;
  AFirstInd := min( AFirstInd, Length(AString) );
  ALastInd  := min( ALastInd, Length(AString) );
  if ALastInd = 0 then Exit;

  for i := AFirstInd to ALastInd do // along all AString  characters
  begin
    CurChar := AString[i];

  //same code???
{$IF SizeOf(Char) = 2} // Wide Chars (>= Delphi 2010) Types and constants
    if (CurChar = 'Ё') or (CurChar = 'Ё') or
       ( (CurChar >= 'А') and (CurChar <= 'я') ) then Inc( Result );
{$ELSE} //*************** Ansi Chars (Delphi 7) Types and constants
    if (CurChar = 'Ё') or (CurChar = 'Ё') or
       ( (CurChar >= 'А') and (CurChar <= 'я') ) then Inc( Result );
{$IFEND}

  end; // for i := 1 to Length(AString) do // along all AString  characters
end; // function N_CalcNumCyrChars

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_XLSToClipboard
//******************************************************** N_XLSToClipboard ***
// Put given *.XLS file sheet to WINDOWS clipborad
//
//     Parameters
// AFileName - *.XLS file name
// ASheetInd - *.XLS file sheet index (>=1)
// Result    - Returns TRUE if new Excel Application was created.
//
// AFileName = 'CloseServer' means closing current Excel Application
//
function N_XLSToClipboard( AFileName: string; ASheetInd: integer = 1 ): boolean;
var
  ExcelServer, WorkBook, WorkSheet: Variant;
begin
  if not FileExists( AFileName ) then Exit; // a precaution
  ExcelServer := N_GetOLEServer( 'Excel.Application', @Result );

  WorkBook := ExcelServer.WorkBooks.Open( AFileName );
  WorkSheet := WorkBook.WorkSheets.Item[ASheetInd];
//  N_s := WorkSheet.Name;
  WorkSheet.Activate;
  ExcelServer.Cells.Select;
//  WorkSheet.Cells.Select; // error in Select method!
  ExcelServer.Selection.Copy;
  ExcelServer.DisplayAlerts := False;
  WorkBook.Close;
  WorkBook := Unassigned();
  WorkSheet := Unassigned();
  ExcelServer := Unassigned();
end; // end of procedure N_XLSToClipboard

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReplaceArrayElems(byte)
//*********************************************** N_ReplaceArrayElems(byte) ***
// Replace given Byte Array Elements
//
//     Parameters
// AArray       - Array of Byte, where to replace Elements
// ABegInd      - Index of Elements to replace
// ACurNumElems - number of Elements to replace,
// ACurAllElems - whole number of Elements in AArray
// APNewElems   - Pointer to New Elements
// ANewNumElems - Number of New Elements ( New Array Length is 
//                ACurAllElems+ANewNumElems-ACurNumElems )
//
// Replace given number of Byte Array Elements by any number of given New 
// Elements. All rest Array Elements are shifted and Array is resized if needed
//
procedure N_ReplaceArrayElems( var AArray: TN_BArray; ABegInd, ACurNumElems,
              ACurAllElems: integer; APNewElems: PByte; ANewNumElems: integer );
var
  NewLeng, Delta, RestSize: integer;
begin
  NewLeng := ACurAllElems + ANewNumElems - ACurNumElems;
  if Length( AArray ) < NewLeng then
    SetLength( AArray, N_NewLength( NewLeng ) );

  Delta := ANewNumElems - ACurNumElems;
  RestSize := ACurAllElems - ABegInd - ACurNumElems;

  if (Delta <> 0) and (RestSize > 0) then
    move( AArray[ABegInd+ACurNumElems],
          AArray[ABegInd+ACurNumElems+Delta], RestSize );

  if ANewNumElems > 0 then
    move( APNewElems^, AArray[ABegInd], ANewNumElems );
end; // procedure N_ReplaceArrayElems(byte)

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReplaceArrayElems(Int)
//************************************************ N_ReplaceArrayElems(Int) ***
// Replace given Integer Array Elements
//
//     Parameters
// AArray       - Array of Integer, where to replace Elements
// ABegInd      - Index of Elements to replace
// ACurNumElems - number of Elements to replace,
// ACurAllElems - whole number of Elements in AArray
// APNewElems   - Pointer to New Elements
// ANewNumElems - Number of New Elements ( New Array Length is 
//                ACurAllElems+ANewNumElems-ACurNumElems )
//
// Replace given number of Integer Array Elements by any number of given New 
// Elements. All rest Array Elements are shifted and Array is resized if needed
//
procedure N_ReplaceArrayElems( var AArray: TN_IArray; ABegInd, ACurNumElems,
              ACurAllElems: integer; APNewElems: PInteger; ANewNumElems: integer );
var
  NewLeng, Delta, RestSize: integer;
begin
  NewLeng := ACurAllElems + ANewNumElems - ACurNumElems;

  if Length( AArray ) < NewLeng then
    SetLength( AArray, N_NewLength( NewLeng ) );

  Delta := ANewNumElems - ACurNumElems;
  RestSize := ACurAllElems - ABegInd - ACurNumElems;

  if (Delta <> 0) and (RestSize > 0) then
    move( AArray[ABegInd+ACurNumElems],
          AArray[ABegInd+ACurNumElems+Delta], RestSize*Sizeof(Integer) );

  if ANewNumElems > 0 then
    move( APNewElems^, AArray[ABegInd], ANewNumElems*Sizeof(Integer) );
end; // procedure N_ReplaceArrayElems(Int)

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SameBytes
//************************************************************* N_SameBytes ***
// Compare two memory segments of bytes
//
//     Parameters
// APtr1      - ponter to first memory segment
// ANumBytes1 - first memory segment size in bytes
// APtr2      - ponter to second memory segment
// ANumBytes2 - second memory segment size in bytes
// Result     - Returns TRUE if all bytes, pointed to by given pointers are the 
//              same including zero number of bytes.
//
function N_SameBytes( const APtr1: Pointer; ANumBytes1: integer;
                      const APtr2: Pointer; ANumBytes2: integer ): boolean;
begin
  Result := False;
  if ANumBytes1 <> ANumBytes2 then Exit;

  if ANumBytes1 > 0 then
    Result := CompareMem( APtr1, APtr2, ANumBytes1 )
  else
    Result := True;
end; // end of function N_SameBytes

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SameInts
//************************************************************** N_SameInts ***
// Compare two memory segments of integers
//
//     Parameters
// APtr1      - ponter to first memory segment
// ANumBytes1 - first memory segment size in integers
// APtr2      - ponter to second memory segment
// ANumBytes2 - second memory segment size in integers
// Result     - Returns TRUE if all integers, pointed to by given pointers are 
//              the same including zero number of integers.
//
function N_SameInts( PInt1: PInteger; NumInts1: integer;
                     PInt2: PInteger; NumInts2: integer): boolean;
begin
  Result := False;
  If NumInts1 <> NumInts2 then Exit;

  if NumInts1 > 0 then
    Result := CompareMem( PInt1, PInt2, NumInts1*Sizeof(integer) )
  else
    Result := True;
end; // end of function N_SameInts

//**********************************************  N_GetFileFlagsByExt  ***
// Return File Flags by File extention of given AFileName
//
function N_GetFileFlagsByExt( AFileName: string ): TN_FileExtFlags;
var
  Ext: string;
begin
  Result := [];
  Ext := UpperCase(ExtractFileExt( AFileName ));

  if (Ext = '.TXT') or (Ext = '.SDT') or (Ext = '.INI')  or (Ext = '.SPL') or
     (Ext = '.SVG') or (Ext = '.HTM') or (Ext = '.HTML') or (Ext = '.CSV') or
     (Ext = '.RTF') or (Ext = '.XML') then  Result := Result + [fefText]; // Text file

  if (Ext = '.RTF') then Result := Result + [fefRichText,fefWord]; // Rich Text file

  if (Ext = '.BMP') or (Ext = '.BMZ') or (Ext = '.BMPZ') or
     (Ext = '.EMF') or (Ext = '.EMZ') or  (Ext = '.JPG') or
     (Ext = '.JPE') or (Ext = '.GIF') then  Result := Result + [fefGDIPict]; // GDI Picture file

  if (Ext = '.HTM')  or (Ext = '.HTML') or (Ext = '.SVG') or
     (Ext = '.SVGZ') or (Ext = '.GIF')  or (Ext = '.JPG') or
     (Ext = '.JPE') then Result := Result + [fefInet]; // Internet browser file

  if (Ext = '.DOC') or (Ext = '.DOT') then Result := Result + [fefWord]; // MS Word file

  if (Ext = '.XLS') or (Ext = '.CSV') then Result := Result + [fefExcel]; // MS Excel file

  if (Ext = '.SVG') or (Ext = '.SVGZ') then Result := Result + [fefSVG]; // SVG file

  if (Ext = '.SVGZ') or (Ext = '.BMZ') or (Ext = '.BMPZ') or
     (Ext = '.EMZ')  then Result := Result + [fefCompressed]; // Compressed file

end; // function N_GetFileFlagsByExt

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_FillStringsArray
//****************************************************** N_FillStringsArray ***
// Fill Strings by given Strings
//
//     Parameters
// APOutStrings   - pointer to first element of resulting strings array
// ANumOutStrings - number of elements in resulting strings array
// APInpStrings   - pointer to first element of source strings array
// ANumInpStrings - number of elements in source strings array
//
// If source strings are not given (ANumInpStrings <= 0, or APInpStrings = NIL) 
// then resulting strings shoud be fill by 'Not Given!' value
//
procedure N_FillStringsArray( APOutStrings: PString; ANumOutStrings: integer;
                              APInpStrings: PString; ANumInpStrings: integer );
var
  i: integer;
  DefStr: string;
  PInp: PString;
begin
  if APOutStrings = nil then Exit;
  DefStr := 'Not Given!';

  for i := 0 to ANumOutStrings-1 do // along output Strings
  begin
    PInp := APInpStrings;
    if (ANumInpStrings >= 1) and (PInp <> nil) then
    begin
      Inc( PInp, i mod ANumInpStrings );
      (APOutStrings)^ := PInp^;
    end else
      (APOutStrings)^ := DefStr;

    Inc( APOutStrings );
  end; // for i := 0 to ANumOutStrings-1 do // along output Strings

end; // end of procedure N_FillStringsArray

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_FillRectOnWinDesktop
//************************************************** N_FillRectOnWinDesktop ***
// Fill Rectangle on Windows Desktop
//
//     Parameters
// ARect      - rectangle in absolute Screen Coordinates
// AFillColor - fill color
//
procedure N_FillRectOnWinDesktop( ARect: TRect; AFillColor: integer );
var
  ScreenHDC: HDC;
  HBr: HBrush;
begin
  ScreenHDC := Windows.GetDC( 0 ); // Desktop (Display, Screen) DC
  HBr := CreateSolidBrush( AFillColor );
  Inc( ARect.Right );
  Inc( ARect.Bottom );
  // Windows.FillRect excludes Right Bottom Edge in any mapping mode
  Windows.FillRect( ScreenHDC, ARect, HBr );
  Windows.DeleteObject( HBr );
end; // end of procedure N_FillRectOnWinDesktop

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_FillRectOnWinHandle
//*************************************************** N_FillRectOnWinHandle ***
// Fill Rectangle in Window (including all Window system areas) given by Handle
//
//     Parameters
// AWinHandle - Window Handle
// ARect      - rectangle in relative Window Coordinates
// AFillColor - fill color
//
procedure N_FillRectOnWinHandle( AWinHandle: HWND; ARect: TRect; AFillColor: integer );
var
  WinHDC: HDC;
  HBr: HBrush;
begin
  WinHDC := Windows.GetWindowDC( AWinHandle ); // Window system DC
  if WinHDC = 0 then Exit; // some error

  HBr := CreateSolidBrush( AFillColor );
  // Remark: Windows.FillRect excludes Right Bottom Edge in any mapping mode
  Inc( ARect.Right );
  Inc( ARect.Bottom );
  Windows.FillRect( WinHDC, ARect, HBr );
  Windows.DeleteObject( HBr );
  Windows.ReleaseDC( AWinHandle, WinHDC );
end; // end of procedure N_FillRectOnWinHandle

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CrIA
//****************************************************************** N_CrIA ***
// Create dinamic Array of Integers by Open Parameters List
//
//     Parameters
// AA     - Open Parameters List
// Result - Returns Dinamic Array of Integers
//
function N_CrIA( AA: Array of Integer ): TN_IArray;
begin
  SetLength( Result, Length(AA) );
  move( AA[0], Result[0], Length(AA)*SizeOf(AA[0]) );
end; // function N_CrIA

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CrDA
//****************************************************************** N_CrDA ***
// Create Dinamic Array of Doubles by Open Parameters List
//
//     Parameters
// AA     - Open Parameters List
// Result - Returns Dinamic Array of Doubles
//
function N_CrDA( AA: Array of double ): TN_DArray;
begin
  SetLength( Result, Length(AA) );
  move( AA[0], Result[0], Length(AA)*SizeOf(AA[0]) );
end; // function N_CrDA

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CrIPA
//***************************************************************** N_CrIPA ***
// Create Dinamic Array of Integer Points by Open Parameters List
//
//     Parameters
// AA     - Open Parameters List
// Result - Returns Dinamic Array of Integer Points
//
// Open Parameters should contain Integers List (X1,Y1,X2,Y2,...)
//
function N_CrIPA( AA: Array of integer ): TN_IPArray;
begin
  SetLength( Result, Length(AA) div 2 );
  move( AA[0], Result[0], 2*Length(Result)*SizeOf(AA[0]) );
end; // function N_CrIPA

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CrDPA
//***************************************************************** N_CrDPA ***
// Create Dinamic Array of Double Points by Open Parameters List
//
//     Parameters
// AA     - Open Parameters List
// Result - Returns Dinamic Array of Double Points
//
// Open Parameters should contain Doubles List (X1,Y1,X2,Y2,...)
//
function N_CrDPA( AA: Array of double ): TN_DPArray;
begin
  SetLength( Result, Length(AA) div 2 );
  move( AA[0], Result[0], 2*Length(Result)*SizeOf(AA[0]) );
end; // function N_CrDPA

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_BinSegmSearch(Double)
//************************************************* N_BinSegmSearch(Double) ***
// Search index of element in records array sorted by given double field
//
//     Parameters
// APElemArray - Pointer to Double field of first Array Element
// AElemCount  - Elements Count (>= 2)
// AElemSize   - one Element size in bytes (SizeOf  array element)
// AValue      - given value to search to
// Result      - Returns Index of Array Element where Array[Index].DVal <= 
//               AValue <= Array[Index+1].DVal
//
// Array Elements are in increasing order and given AValue should be in 
// (Min,Max) interval, (Min=Array[0] <= AValue <= Array[ElemCount-1]=Max).
//
function N_BinSegmSearch( APElemArray: TN_BytesPtr; AElemCount, AElemSize: integer;
                                                    AValue: double ): integer;
var
  imin, imax, inext, idelta: Integer;
  PTmp: PDouble;
begin
  imin := 0;
  imax := AElemCount-1;

  //***** always is True: Value[imin] <= AValue <= Value[imax]

  while True do
  begin
    idelta := imax - imin;
    if idelta = 1 then
    begin
      Result := imin;
      Exit;
    end else if idelta = 2 then
    begin
      PTmp := PDouble(@APElemArray[(imin+1)*AElemSize]); // Ptr to Beg of segment to analize

      if AValue < PTmp^ then
        Result := imin
      else
        Result := imin+1;

      Exit;
    end else // idelta >= 3, imin < inext < imax
    begin
      inext := (imin + imax) shr 1; // always is true: imin < inext < imax
      PTmp := PDouble(@APElemArray[inext*AElemSize]);

      if AValue < PTmp^ then
        imax := inext
      else
        imin := inext;

    end; // else // idelta >= 3, imin < inext < imax

  end; // while True do

end; // function N_BinSegmSearch

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_StrPos
//**************************************************************** N_StrPos ***
// Search given substring in given string
//
//     Parameters
// ASubStr    - searched substring
// ASrcStr    - source string
// ASrcBegPos - seach start position
// Result     - Returns position of first char of searched substring or 0 if not
//              found.
//
function  N_StrPos( const ASubStr, ASrcStr: string; ASrcBegPos: Integer ): Integer;
var
  i, SrcLeng, SubstrLM1: Integer;
  PCur, PASubStr: PChar;
begin
  Result := 0;
  SrcLeng   := Length(ASrcStr);
  SubstrLM1 := Length(ASubStr) - 1;

  if (AsrcBegPos + SubstrLM1) > SrcLeng then Exit;

  PASubStr := @ASubStr[1];

  if SubstrLM1 = 0 then // one character Substring
  begin
    PCur := @ASrcStr[AsrcBegPos];
    for i := ASrcBegPos to SrcLeng-SubstrLM1 do // seach for first char
    begin
      if PCur^ <> PASubStr^ then
      begin
        Inc( PCur );
        Continue; // not same
      end;

      //***** Here: found
      Result := i;
      Exit;
    end; // for i := ASrcBegPos to SrcLeng-SubstrLM1 do // seach for first char
  end else // SubstrLM1 >= 1, more than one character Substring
  begin
    PCur := PChar(@ASrcStr[AsrcBegPos]) - 1;
    for i := ASrcBegPos to SrcLeng-SubstrLM1 do // seach for first char
    begin
      Inc( PCur );
      if PCur^ <> PASubStr^ then Continue; // not same
      if not CompareMem( PCur+1, PASubStr+1, SubstrLM1*SizeOf(Char) ) then Continue; // not same

      //***** Here: found
      Result := i;
      Exit;
    end; // for i := ASrcBegPos to SrcLeng-SubstrLM1 do // seach for first char
  end;

end; //*** end of function N_StrPos

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReplaceHTMLBR
//********************************************************* N_ReplaceHTMLBR ***
// Conv to UNICODE!!! Replace HTML <br> tag by given for chars string
//
//     Parameters
// AStr    - given string for chars replacing
// A4Chars - four chars string for <br> replacing
//
procedure N_ReplaceHTMLBR( var AStr: string; A4Chars: string );
var
  i, Size: integer;
  Int4AChars: integer;
  Int4WChars: Int64;
  PCur: PChar;
begin
  Int4WChars := 0; // to avoid warning in Delphi 7
  N_i := Integer(Int4WChars);
  Int4AChars := 0; // to avoid warning in Delphi 2010
  N_i := Integer(Int4AChars);

  Size := Length(AStr);
  if Size <= 3 then Exit;
  Assert( (Length(A4Chars) = 4), 'Bad A4Chars!' );

  if SizeOf(Char) = 2 then // Wide Chars
  begin
    Int4WChars := PInt64(@A4Chars[1])^;
  end else //**************** Ansi Chars
  begin
    Int4AChars := PInteger(@A4Chars[1])^;
  end;


  PCur := @AStr[1];
  for i := 1 to Size-3 do
  begin
    if PCur^ = '<' then
    begin
      //***** B-$42, b-$62, R-$52, r-$72, <-$3C, >-$3E

      if SizeOf(Char) = 2 then // Wide Chars
      begin
        // Convert to UNICODE!!!
        if (PInt64(PCur)^ or $00202000) = $3E72623C then // '<br>' found
          PInt64(PCur)^ := Int4WChars;
      end else //**************** Ansi Chars
      begin
        if (PInteger(PCur)^ or $00202000) = $3E72623C then // '<br>' found
          PInteger(PCur)^ := Int4AChars;
      end;

    end; // if PCur^ = '<' then

    Inc(PCur);
  end;
end; // procedure N_ReplaceHTMLBR

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReplaceEQSSubstr
//****************************************************** N_ReplaceEQSSubstr ***
// Replace one substring by given another substring of the same length in given 
// AStr
//
//     Parameters
// AStr       - on input given source string, on output - resulting string
// AOldSubstr - substring that should be replaces
// ANewSubstr - replacing substring new value (string of the same length)
// Result     - return number of replaced substrings (>=0)
//
// All occurences of AOldSubstr will be replaced by ANewSubstr. Lengths of 
// AOldSubstr and ANewSubstr should be the same!
//
function N_ReplaceEQSSubstr( var AStr: string; AOldSubstr, ANewSubstr: string ): integer;
var
  i, Size, SubstrSize: integer;
  PCur, PNew, POld: PChar;
begin
  Result := 0;
  SubstrSize := Length(AOldSubstr);
  if (SubstrSize = 0) or (SubstrSize <> Length(ANewSubstr)) then Exit; // a precaution

  Size := Length(AStr);
  if Size < SubstrSize then Exit;

  PCur := @AStr[1];
  POld := @AOldSubstr[1];
  PNew := @ANewSubstr[1];

  for i := 1 to Size-SubstrSize+1 do
  begin
    if PCur^ = POld^ then // first character is the same
    begin
      Inc( Result );

      if SubstrSize = 1 then
        PCur^ := PNew^
      else
        if CompareMem( PCur+1, POld+1, (SubstrSize-1)*SizeOf(Char) ) then // found
          move( PNew^, PCur^, SubstrSize*SizeOf(Char) ); // replace
    end; // if PCur^ = POld^ then

    Inc(PCur);
  end;
end; // function N_ReplaceEQSSubstr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReplaceEQSSubstrInSMatr
//******************************************** N_ReplaceEQSSubstrInSMatr ***
// Replace one substring by given another substring of the same length in all 
// elements of given ASMatr
//
//     Parameters
// AStrMatr   - on input given source ASMatr, on output - resulting ASMatr
// AOldSubstr - substring that should be replaces
// ANewSubstr - replacing substring new value (string of the same length)
//
// All occurences of AOldSubstr will be replaced by ANewSubstr. Lengths of 
// AOldSubstr and ANewSubstr should be the same!
//
procedure N_ReplaceEQSSubstrInSMatr( AStrMatr: TN_ASArray; AOldSubstr, ANewSubstr: string );
var
  i, j: integer;
begin
  for i := 0 to High(AStrMatr) do // along all AStrMatr rows
  begin
    for j := 0 to High(AStrMatr[i]) do // along all elems of AStrMatr i-th row
      N_ReplaceEQSSubstr( AStrMatr[i][j], AOldSubstr, ANewSubstr );
  end; // for i := 0 to High(AStrMatr) do // along all AStrMatr rows
end; // procedure N_ReplaceEQSSubstrInSMatr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SplitString1
//********************************************************** N_SplitString1 ***
// Conv to UNICODE!!! Split given string by given split parameters
//
//     Parameters
// AInpStr   - source string
// ASSParams - split parameters including resulting StringList
//
// Split given AInpStr by given Split String Params
//
procedure N_SplitString1( AInpStr: string; var ASSParams: TN_SplitStringParams );
var
  i, InpSize, BegSize, MoveSize: integer;
  LastInd, CurBufFreeInd, LastBufSpaceInd: integer;
  CurChar: Char;
  BufStr, BegStr: string;
  PrevSpace: boolean;
begin
  with ASSParams do
  begin

  //***** Skip leading white chars in AInpStr and
  //      Prepare BufStr by initial SSPResSl[SSPBegRowInd]

  InpSize := Length(AInpStr);
  i := 1;

  while (i <= InpSize) and (AInpStr[i] <= ' ') do Inc(i); // skip leading white chars

  BegStr := SSPResSL[SSPResSL.Count-1];
  BegSize := Length(BegStr);

  if i > InpSize then // AInpStr is empty or consists of white chars only
  begin               // SSPResSL remains the same
    Exit;
  end else // i <= InpSize
  begin
    if SSPMaxRowSize >= 1 then // a precaution
      SetLength( BufStr, SSPMaxRowSize + 10 ); // max possible size (+10 for debug, needed +1)

    if BegSize = 0 then //***** Empty initial string
    begin
      CurBufFreeInd := 1;
      LastBufSpaceInd := 0;
      SSPResSL.Delete( SSPResSL.Count-1 );
    end else //**************** BegSize >= 1
    begin
      if BegSize >= (SSPMaxRowSize-1) then // no more free space
      begin
        CurBufFreeInd := 1;
        LastBufSpaceInd := 0;
      end else //**************************** 1 <= BegSize <= (SSPMaxRowSize-2)
      begin
        move( BegStr[1], BufStr[1], BegSize );
        SSPResSL.Delete( SSPResSL.Count-1 );

        BufStr[BegSize+1] := ' '; // delimeter between initial and AInpStr string
        LastBufSpaceInd := BegSize + 1;
        CurBufFreeInd := BegSize + 2; // (BegSize+2) <= SSPMaxRowSize
      end; // else // 1 <= BegSize <= (SSPMaxRowSize-2)
    end; // else // BegSize >= 1
  end; // else // i <= InpSize

  //***** Here LastBufSpaceInd and CurBufFreeInd in it are OK

  if SSPMaxRowSize <= 0 then // a precaution
  begin
    SetLength( BufStr, CurBufFreeInd-1 );
    SSPResSl.Add( BufStr + AInpStr );
    Exit;
  end;

  //***** AInpStr[i] is first nonwhite char, LastBufSpaceInd is OK
  PrevSpace := False;

  while i <= InpSize do // along AInpStr
  begin
    if CurBufFreeInd = SSPMaxRowSize then
      N_i := 1;

//    N_IAdd( Format( 'i=%d, CurBufFreeInd=%d', [i,CurBufFreeInd] )); // debug
    CurChar := AInpStr[i];
    BufStr[CurBufFreeInd] := CurChar;
    BufStr[CurBufFreeInd+1] := '!';     // for debug

    if CurChar = ' ' then // Space (possible Row Break)
    begin
      if PrevSpace then // not first Space, skip it
      begin
        Inc( i );
        Continue;
      end else // first Space
      begin
        PrevSpace := True;
        LastBufSpaceInd := CurBufFreeInd;
      end;
    end else // CurChar <> ' '
    begin
      if CurChar <> Char($0D) then
        PrevSpace := False;
    end;

    if CurChar = Char($0D) then // Row break by CRLF
    begin
      if PrevSpace then LastInd := LastBufSpaceInd - 1
                   else LastInd := CurBufFreeInd - 1;

      SSPResSl.Add( Copy( BufStr, 1, LastInd ) );
      PrevSpace := False;
      CurBufFreeInd := 1;

      Inc( i, 1 ); // skip CRLF

      while (i <= InpSize) and (AInpStr[i] <= ' ') do Inc(i); // skip white chars after CRLF

      Continue;
    end;

    if CurBufFreeInd >= (SSPMaxRowSize+1) then // Row break by MaxRowSize
    begin
      if PrevSpace then //***** cur char(s) is Space(s), LastBufSpaceInd >= 2
      begin
        SSPResSl.Add( Copy( BufStr, 1, LastBufSpaceInd-1 ) ); // add chars before first space

        while (i <= InpSize) and (AInpStr[i] <= ' ') do // skip white chars after cur space
          Inc(i);

        CurBufFreeInd := 1; // BufStr is all free
      end else //************** CurChar is not Space
      begin
        if LastBufSpaceInd = 0 then // no space in BufStr, CurChar is not Space
        begin
          SSPResSl.Add( Copy( BufStr, 1, SSPMaxRowSize ) ); // copy all chars except last
          BufStr[1] := BufStr[SSPMaxRowSize+1];
          CurBufFreeInd := 2; // one (last) char in BufStr
        end else // LastBufSpaceInd >= 2 (space exists in BufStr), CurChar is not Space
        begin
          SSPResSl.Add( Copy( BufStr, 1, LastBufSpaceInd-1 ) ); // add chars before first space

          MoveSize := CurBufFreeInd - LastBufSpaceInd; // num chars after last space
          move( BufStr[LastBufSpaceInd+1], BufStr[1], MoveSize ); // copy them to beg of BufStr
          CurBufFreeInd := MoveSize+1; // MoveSize chars in BufStr
        end; //  else // LastBufSpaceInd >= 2

        Inc( i ); // to next char in AInpStr (only for CurChar is not Space case)
      end; //  else // CurChar is not Space

      LastBufSpaceInd := 0; // "no space in BufStr" flag
      Continue; // to skip increasing CurBufFreeInd and i
    end; // if CurBufFreeInd >= (SSPMaxRowSize+1) then // Row break by MaxRowSize

    Inc( CurBufFreeInd ); // to next char in BufStr
    Inc( i );             // to next char in AInpStr
  end; // while i <= InpSize do // along AInpStr

  //***** no more Chars in AInpStr

  if CurBufFreeInd > 1 then // BufStr is not Empty (CurBufFreeInd >=2) but may be white
  begin
    if BufStr[CurBufFreeInd-1] = ' ' then // remove trailing space
      Dec(CurBufFreeInd);

    if CurBufFreeInd = 1 then // Empty BufStr
      Exit
    else //********************* BufStr is not Empty (CurBufFreeInd >=2) and not white
      SSPResSl.Add( Copy( BufStr, 1, CurBufFreeInd-1 ) );
  end; // BufStr is not Empty (CurBufFreeInd >=2)


  end; // with ASSParams do
end; //*** end of procedure N_SplitString1

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SplitString2
//********************************************************** N_SplitString2 ***
// Split given string by given maximal substring size
//
//     Parameters
// AInpStr  - source string
// ARowSize - splitted strings maximal size
// Result   - Returns string with included carriage return and line feed 
//            characters
//
function N_SplitString2( AInpStr: string; ARowSize: integer ): string;
var
  SSParams: TN_SplitStringParams;
begin
  SSParams.SSPMaxRowSize := ARowSize;
  SSParams.SSPResSL := TStringList.Create;
  SSParams.SSPResSL.Add( '' );

  N_SplitString1( AInpStr, SSParams );

  Result := SSParams.SSPResSL.Text;
end; // function N_SplitString2

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SplitSubStrings
//******************************************************* N_SplitSubStrings ***
// Split given string by given delimiter characters
//
//     Parameters
// AInpStr        - source string
// ADelimStr      - string with delimiter characters
// AResSubStrings - resulting Strings
//
// Split SubStrings of given AInpStr, that are separated by given ADelimStr and 
// add resulting SubStrings to given AResSubStrings
//
procedure N_SplitSubStrings( AInpStr, ADelimStr: string; AResSubStrings: TStrings );
var
  BegPos, DelimPos, DelimSize: integer;
begin
  DelimSize := Length(ADelimStr);
  BegPos := 1;

  while True do
  begin
    DelimPos := PosEx( ADelimStr, AInpStr, BegPos );

    if DelimPos = 0 then // not found, add last substring
    begin
      AResSubStrings.Add( MidStr( AInpStr, BegPos, Length(AInpStr)-BegPos+1 ) );
      Exit; // all done
    end else // DelimPos > 0, found, add next substring
    begin
      AResSubStrings.Add( MidStr( AInpStr, BegPos, DelimPos-BegPos ) );
      BegPos := DelimPos + DelimSize;
    end;

  end; // while True do

end; // procedure N_SplitSubStrings

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_RemoveGivenChar
//******************************************************* N_RemoveGivenChar ***
// Remove given character from given string
//
//     Parameters
// AStr   - given string from which AChar should be removed
// AChar  - given character to remove from AStr
// Result - Returns given string AStr with removed AChar.
//
function N_RemoveGivenChar( AStr: string; AChar: Char ): string;
var
  i, j, AStrSize, FragmSize, ResSize: integer;
  Label Found;
begin
  Result := AStr;
  AStrSize := Length( AStr );
  if AStrSize = 0 then Exit;

  for i := 1 to AStrSize do
    if AStr[i] = AChar then goto Found;

  i := 0; // just to avoid warning
  Exit; //***** AChar not found in whole AStr, nothing to remove

  Found: //***** at least one AChar exists in AStr

  ResSize := i-1;
  Inc( i );

  while True do // search for next AChar instancies
  begin
    for j := i to AStrSize do
    begin
      if AStr[j] = AChar then // next AChar found
      begin
        FragmSize := j - i; // Next Fragment Size

        if FragmSize = 0 then // subsequent AChar
        begin
          Inc( i ); // just skip founded AChar
          Continue;
        end; // if FragmSize = 0 then // subsequent AChar

        move( AStr[i], Result[ResSize+1], FragmSize*SizeOf(Char) ); // copy next portion
        Inc( ResSize, FragmSize );
        i := j + 1;
      end; // if AStr[j] = AChar then // next AChar found
    end; // for j := i to AStrSize do

    //***** Here: no more AChar, copy rest of AStr and return

    FragmSize := AStrSize - i + 1; // Next Fragment Size

    if FragmSize > 0 then // add last fregment to Result
    begin
      move( AStr[i], Result[ResSize+1], FragmSize*SizeOf(Char) ); // copy last portion
      Inc( ResSize, FragmSize );
    end; // if FragmSize > 0 then // add last fregment to Result

    SetLength( Result, ResSize );
    Exit;
  end; // while True do // search for next AChar instancies
end; //*** end function N_RemoveGivenChar

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AddCRLFIfNotYet
//**************************************************** N_AddCRLFIfNotYet ***
// Add to given AStr CRLF chars if not yet already
//
//     Parameters
//
procedure N_AddCRLFIfNotYet( var AStr: string );
var
  Leng: integer;
begin
  Leng := Length( AStr );

  if Leng < 2 then
    AStr := AStr + N_StrCRLF
  else if not ( (AStr[Leng] = Char($0D)) and (AStr[Leng-1] = Char($0A)) ) then
    AStr := AStr + N_StrCRLF
end; // end of procedure N_AddCRLFIfNotYet


{
//************************************************************ N_StrPosRevN ***
// Reverse Search using TN_RevSearchParams record
//
procedure N_StrPosRevN( var ARevSearchPar: TN_RevSearchParams );
begin

end; //*** end of procedure N_StrPosRevN
}

//************************************************ N_WarnByMessage ***
// warn user by showing message
//
procedure N_WarnByMessage( AWarningMessage: string );
begin
  Beep;
  ShowMessage( 'Warning:  ' + AWarningMessage );
//  Application.Terminate; // temporary
end; // end of procedure N_WarnByMessage

//***************************************************************** N_Alert ***
// Show given String in Modal mode
//
procedure N_Alert( AAlertStr: string );
begin
  ShowMessage( AAlertStr );
end; // end of procedure N_Alert

//************************************************** N_TrimLastSpecialChars ***
// Trim Last special characters: $0, $A, $D
//
function N_TrimLastSpecialChars( AStr: string ): string;
var
  i, Leng, CurChar: integer;
begin
  Leng := Length( AStr );

  for i := Leng downto 1 do
  begin
    CurChar := integer(AStr[i]);
    if (CurChar <> 0) and (CurChar <> $A) and (CurChar <> $D) then
    begin
      Result := LeftStr( AStr, i );
      Exit;
    end;
  end; // for i := Leng downto 1 do

  Result := '';
end; //*** function N_TrimLastSpecialChars

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_NumWideChars
//******************************************************* N_NumWideChars ***
// Calc Number of Wide Characters before terminating zero
//
//     Parameters
// APWChar - given pointer to first char of null terminated Wide string
// Result  - Return Number of Wide Characters before terminating zero
//
function N_NumWideChars( APWChar: PWideChar ): Integer;
var
  PWCCur: PWideChar;
begin
  if APWChar = nil then
  begin
    Result := 0;
    Exit;
  end;

  PWCCur := APWChar;

  while Word(PWCCur^) <> 0 do Inc( PWCCur );

  Result := (DWORD(PWCCur) - DWORD(APWChar)) shr 1;
end; // function N_NumWideChars

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CreateWideString
//*************************************************** N_CreateWideString ***
// Create Wide String by given APWChar
//
//     Parameters
// APWChar - given pointer to first char of null terminated Wide string
// Result  - Return WideString with given content
//
function N_CreateWideString( APWChar: PWideChar ): WideString;
var
  NumChars: integer;
begin
  if APWChar = nil then
  begin
    Result := '';
    Exit;
  end;

  NumChars := N_NumWideChars( APWChar );
  SetLength( Result, NumChars );
  move( APWChar^, Result[1], 2*NumChars + 2 );
end; // function N_CreateWideString

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AnsiToWide
//********************************************************* N_AnsiToWide ***
// Convert given AAnsiString to Unicode WideString using N_NeededCodePage
//
//     Parameters
// AAnsiString - given ANSI String to convert
// Result      - Return converted Unicode WideString
//
function N_AnsiToWide( AAnsiString: AnsiString ): WideString;
var
  NumChars: integer;
  NRes: integer;
begin
  Result := '';
  NumChars := Length(AAnsiString);

  if NumChars = 0 then Exit; // all done

  SetLength( Result, NumChars );
  NRes := MultiByteToWideChar( N_NeededCodePage, 0, @AAnsiString[1], NumChars,
                                                    @Result[1], NumChars );
  Assert( NRes = NumChars, 'MultiByteToWideChar Error' );
end; // function N_AnsiToWide

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AnsiToString
//******************************************************* N_AnsiToString ***
// Convert given AAnsiString to String using N_NeededCodePage if needed
//
//     Parameters
// AAnsiString - given ANSI String to convert
// Result      - Return converted (if needed) String
//
function N_AnsiToString( AAnsiString: AnsiString ): String;
begin
  if SizeOf(Char) = 2 then
    Result := String(N_AnsiToWide( AAnsiString ))
  else
    Result := String(AAnsiString);
end; // function N_AnsiToString

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_WideToAnsi
//********************************************************* N_WideToAnsi ***
// Convert given Unicode AWideString to AnsiString using N_NeededCodePage
//
//     Parameters
// AWideString - given Unicode Wide String to convert
// Result      - Return converted ANSI String
//
function N_WideToAnsi( AWideString: WideString ): AnsiString;
var
  WideLeng: integer;
  NRes: integer;
  DefCharWasUsed: LongBool;
begin
  Result := '';
  WideLeng := Length(AWideString);

  if WideLeng = 0 then Exit; // all done

  SetLength( Result, WideLeng );
  NRes := WideCharToMultiByte( N_NeededCodePage, 0, @AWideString[1], WideLeng,
                               @Result[1], WideLeng, @N_DefAnsiCharStr[1], @DefCharWasUsed );
  Assert( NRes = WideLeng, 'WideCharToMultiByte Error' );
end; // function N_WideToAnsi

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_WideToString
//******************************************************* N_WideToString ***
// Convert given Unicode AWideString to String using N_NeededCodePage (if 
// needed)
//
//     Parameters
// AWideString - given Unicode Wide String to convert
// Result      - Return converted (if needed) String
//
function N_WideToString( AWideString: WideString ): String;
begin
  if SizeOf(Char) = 2 then
    Result := String(AWideString)
  else
    Result := String(N_WideToAnsi( AWideString ));
end; // function N_WideToString

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_StringToAnsi
//******************************************************* N_StringToAnsi ***
// Convert given AString to Ansi String using N_NeededCodePage (If needed)
//
//     Parameters
// AString - given String to convert if needed
// Result  - Return converted ANSI String
//
function N_StringToAnsi( AString: String ): AnsiString;
begin
  if SizeOf(Char) = 2 then
    Result := N_WideToAnsi( AString )
  else
    Result := AnsiString(AString);
end; // function N_StringToAnsi

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_StringToWide
//******************************************************* N_StringToWide ***
// Convert given AString to Wide String using N_NeededCodePage (If needed)
//
//     Parameters
// AString - given String to convert if needed
// Result  - Return converted Wide String
//
function N_StringToWide( AString: String ): WideString;
begin
  if SizeOf(Char) = 2 then
    Result := WideString(AString)
  else
    Result := N_AnsiToWide( AnsiString(AString) );
end; // function N_StringToWide


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_EncodeAnsiStringToBytes
//******************************************** N_EncodeAnsiStringToBytes ***
// Encode given AAnsiString To Array of Bytes using N_NeededCodePage, 
// N_NeededTextEncoding
//
//     Parameters
// AAnsiString - ANSI String to Encode
// AResABytes  - Resulting Array of Bytes with Encoded AString
// Result      - Return number of resulting bytes in AABytes Array
//
// Size of AABytes Array is never decreased.
//
function N_EncodeAnsiStringToBytes( AAnsiString: AnsiString; var AResABytes: TN_BArray ): integer;
var
  NumChars, UTF8CharsLeng, BegDataInd, NRes: integer;
  EncMode: TN_TextEncoding;
  WideStr: WideString;
  UTF8Str: AnsiString;
begin
  Result := 0;
  NumChars := Length(AAnsiString);

  if NumChars = 0 then Exit; // all done

  EncMode := TN_TextEncoding(N_NeededTextEncoding and $FF); // use lowest byte as Encoding mode

  if EncMode = teAuto then // set EncMode to teANSI for Delphi 7 or teUTF8 for Delphi 2010
  begin
    if SizeOf(Char) = 2 then EncMode := teUTF8  // Delphi 2010
                        else EncMode := teANSI; // Delphi 7
  end; // if EncMode = teAuto then // set EncMode to teANSI for Delphi 7 or teUTF8 for Delphi 2010

  case EncMode of

  teANSI: // ANSI, one byte per character
  begin
    if Length(AResABytes) < NumChars then
      SetLength( AResABytes, NumChars );

    move( AAnsiString[1], AResABytes[0], NumChars );
    Result := NumChars;
  end; // teANSI: // ANSI, one byte per character

  teUTF16LE: // Unicode UTF-16LE, two bytes per character
  begin
    if Length(AResABytes) < (2*NumChars+2) then
      SetLength( AResABytes, 2*NumChars+2 ); // Max possible size

    BegDataInd := 0;
    Result := 2*NumChars; // temporary without BOM

    if (N_NeededTextEncoding and N_UseBOMFlag) <> 0 then // use BOM - Byte Order Mark
    begin
      AResABytes[0] := $FF;
      AResABytes[1] := $FE;
      BegDataInd := 2;
      Result := Result + 2; // BOM Size
    end; // if (N_NeededTextEncoding and N_UseBOMFlag) <> 0 then // use BOM - Byte Order Mark

    NRes := MultiByteToWideChar( N_NeededCodePage, 0, @AAnsiString[1], NumChars,
                                   PWideChar(@AResABytes[BegDataInd]), NumChars );
    Assert( NRes = NumChars, 'N_EncodeAnsiStringToBytes Error1' );
  end; // teUTF16LE: // Unicode UTF-16LE, two bytes per character

  teUTF8: // Unicode UTF-8 (from one to three bytes per character)
  begin
    WideStr := N_AnsiToWide( AAnsiString );
    UTF8Str := UTF8Encode( WideStr );
    UTF8CharsLeng := Length(UTF8Str);

    if Length(AResABytes) < (UTF8CharsLeng+3) then
      SetLength( AResABytes, UTF8CharsLeng+3 ); // Max possible size

    BegDataInd := 0;

    if (N_NeededTextEncoding and N_UseBOMFlag) <> 0 then // use BOM - Byte Order Mark
    begin
      AResABytes[0] := $EF;
      AResABytes[1] := $BB;
      AResABytes[2] := $BF;
      BegDataInd := 3;
    end; // if (N_NeededTextEncoding and $0100) <> 0 then // use BOM - Byte Order Mark

    move( UTF8Str[1], AResABytes[BegDataInd], UTF8CharsLeng );
    Result := UTF8CharsLeng + BegDataInd;
  end; // teUTF8: // Unicode UTF-8 (from one to three bytes per character)

  else Assert( False, 'Bad Encoding mode in N_EncodeAnsiStringToBytes ' + IntToStr(integer(EncMode)) );

  end; // case TN_TextEncoding(N_NeededTextEncoding and $FF) of

end; // function N_EncodeAnsiStringToBytes

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_EncodeWideStringToBytes
//******************************************** N_EncodeWideStringToBytes ***
// Encode given AWideString To Array of Bytes using N_NeededCodePage, 
// N_NeededTextEncoding
//
//     Parameters
// AWideString - Wide String to Encode
// AResABytes  - Resulting Array of Bytes with Encoded AString
// Result      - Return number of resulting bytes in AABytes Array
//
// Size of AABytes Array is never decreased.
//
function N_EncodeWideStringToBytes( AWideString: WideString; var AResABytes: TN_BArray ): integer;
var
  NumChars, UTF8CharsLeng, BegDataInd: integer;
  EncMode: TN_TextEncoding;
  AnsiStr: AnsiString;
  UTF8Str: AnsiString;
begin
  Result := 0;
  NumChars := Length(AWideString);

  if NumChars = 0 then Exit; // all done

  EncMode := TN_TextEncoding(N_NeededTextEncoding and $FF); // use lowest byte as Encoding mode

  if EncMode = teAuto then // set EncMode to teANSI for Delphi 7 or teUTF8 for Delphi 2010
  begin
    if SizeOf(Char) = 2 then EncMode := teUTF8  // Delphi 2010
                        else EncMode := teANSI; // Delphi 7
  end; // if EncMode = teAuto then // set EncMode to teANSI for Delphi 7 or teUTF8 for Delphi 2010

  case EncMode of

  teANSI: // ANSI, one byte per character
  begin
    if Length(AResABytes) < NumChars then
      SetLength( AResABytes, NumChars ); // Final size

    AnsiStr := N_WideToAnsi( AWideString );
    move( AnsiStr[1], AResABytes[0], NumChars );
    Result := NumChars;
  end; // teANSI: // ANSI, one byte per character

  teUTF16LE: // Unicode UTF-16LE, two bytes per character
  begin
    if Length(AResABytes) < (2*NumChars+2) then
      SetLength( AResABytes, 2*NumChars+2 );

    BegDataInd := 0;
    Result := 2*NumChars; // temporary without BOM

    if (N_NeededTextEncoding and N_UseBOMFlag) <> 0 then // use BOM - Byte Order Mark
    begin
      AResABytes[0] := $FF;
      AResABytes[1] := $FE;
      BegDataInd := 2;
      Result := Result + 2; // BOM Size
    end; // if (N_NeededTextEncoding and N_UseBOMFlag) <> 0 then // use BOM - Byte Order Mark

    move( AWideString[1], AResABytes[BegDataInd], 2*NumChars );
  end; // teUTF16LE: // Unicode UTF-16LE, two bytes per character

  teUTF8: // Unicode UTF-8 (from one to three bytes per character)
  begin
    UTF8Str := UTF8Encode( AWideString );
    UTF8CharsLeng := Length(UTF8Str);

    if Length(AResABytes) < (UTF8CharsLeng+3) then
      SetLength( AResABytes, UTF8CharsLeng+3 ); // Max possible size

    BegDataInd := 0;

    if (N_NeededTextEncoding and N_UseBOMFlag) <> 0 then // use BOM - Byte Order Mark
    begin
      AResABytes[0] := $EF;
      AResABytes[1] := $BB;
      AResABytes[2] := $BF;
      BegDataInd := 3;
    end; // if (N_NeededTextEncoding and N_UseBOMFlag) <> 0 then // use BOM - Byte Order Mark

    move( UTF8Str[1], AResABytes[BegDataInd], UTF8CharsLeng );
    Result := UTF8CharsLeng + BegDataInd;
  end; // teUTF8: // Unicode UTF-8 (from one to three bytes per character)

  else Assert( False, 'Bad Encoding mode in N_EncodeWideStringToBytes ' + IntToStr(integer(EncMode)) );

  end; // case TN_TextEncoding(N_NeededTextEncoding and $FF) of

end; // function N_EncodeWideStringToBytes

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_EncodeStringToBytes
//************************************************ N_EncodeStringToBytes ***
// Encode given AString To Array of Bytes using N_NeededCodePage, 
// N_NeededTextEncoding
//
//     Parameters
// AString    - Unicode String to Encode
// AResABytes - Resulting Array of Bytes with Encoded AString
// Result     - Return number of resulting bytes in AABytes Array
//
// Size of AABytes Array is never decreased.
//
function N_EncodeStringToBytes( AString: string; var AResABytes: TN_BArray ): integer;
begin
  if SizeOf(Char) = 2 then // Delphi 2010
    Result := N_EncodeWideStringToBytes( WideString(AString), AResABytes )
  else // Delphi 7
    Result := N_EncodeAnsiStringToBytes( AnsiString(AString), AResABytes );
end; // function N_EncodeStringToBytes

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AnalizeBOMBytes
//**************************************************** N_AnalizeBOMBytes ***
// Analize BOM (Byte Order Mark) Bytes and return recognised encoding mode
//
//     Parameters
// ASrcABytes - given Source Array of Bytes to Decode
// ANumBytes  - given Number of Bytes in ASrcABytes Array
// Result     - Return recognized Encode Mode or teAuto if not recognized
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
function N_AnalizeBOMBytes( const ASrcABytes: TN_BArray; ANumBytes: integer ): TN_TextEncoding;
begin
  if ANumBytes <= 3 then
  begin
    Result := teANSI;
    Exit;
  end;

       if (ASrcABytes[0] = $00) and (ASrcABytes[1] = $00) and
          (ASrcABytes[2] = $FE) and (ASrcABytes[3] = $FF)    then Result := teUTF32BE
  else if (ASrcABytes[0] = $FF) and (ASrcABytes[1] = $FE) and
          (ASrcABytes[2] = $00) and (ASrcABytes[3] = $00)    then Result := teUTF32LE
  else if (ASrcABytes[0] = $FF) and (ASrcABytes[1] = $FE)    then Result := teUTF16LE
  else if (ASrcABytes[0] = $FE) and (ASrcABytes[1] = $FF)    then Result := teUTF16BE
  else if (ASrcABytes[0] = $EF) and (ASrcABytes[1] = $BB) and
          (ASrcABytes[2] = $BF)                              then Result := teUTF8
  else
    Result := teAuto; // format not recognized flag
end; //*** function N_AnalizeBOMBytes

//********************************************************* N_Utf8ToUnicode ***
// Conv UTF8 string to UNICODE string
//
//     Parameters
// APDst
// AMaxDstChars
// APSrc
// ANumSrcChars
// AErrorChar
//
function N_Utf8ToUnicode( APDst: PWideChar; AMaxDstChars: Cardinal; APSrc: PChar;
                      ANumSrcChars: Cardinal; AErrorChar: WideChar ): Cardinal;
var
  i, count: Cardinal;
  c: Byte;
  wc: Cardinal;
begin
  if APSrc = nil then // Source UTF8 string is not given or empty
  begin
    Result := 0;
    Exit;
  end;

//  Result := Cardinal(-1);
  count := 0;
  i := 0;

  if APDst <> nil then // Dst buf is given, Convert UTF8 to UNICODE
  begin
    while (i < ANumSrcChars) and (count < AMaxDstChars) do
    begin
      wc := Cardinal(APSrc[i]);
      Inc(i);

      if (wc and $80) = 0 then // ANSI char
        APDst[count] := WideChar(wc)
      else if (wc and $C0) = $80 then // error, trailing char, skip it
        Continue
      else if (wc and $C0) = $C0 then // first not ANSI char (two or more chars symbol)
      begin
        if i >= ANumSrcChars then // incomplete multibyte char
        begin
          APDst[count] := #0;
          Result := count;
          Exit;
        end; // if i >= ANumSrcChars then // incomplete multibyte char

        if (wc and $E0) = $C0 then // two chars symbol
        begin

          c := Cardinal(APSrc[i]);
          Inc(i);

          if (c and $C0) <> $80 then // error in second char
          begin
            APDst[count] := AErrorChar;
          end else // normal second char (10xxxxxx)
          begin
            APDst[count] := WideChar( ((wc and $1F) shl 6) or (c and $3F) );
          end;

        end else // three or more chars symbol
        begin
          APDst[count] := AErrorChar;
        end;

      end; // else if (wc and $C0) = $C0 then // first not ANSI char (two or more chars symbol)

      Inc(count);
    end; // while (i < ANumSrcChars) and (count < AMaxDstChars) do

    if count >= AMaxDstChars then
      count := AMaxDstChars-1;

    APDst[count] := #0;
  end;

  Result := count;
end; // function N_Utf8ToUnicode

//************************************************************ N_Utf8Decode ***
// Conv UTF8 string to UNICODE string
//
//     Parameters
// AErrorChar -
// AUTF8Str   -
// Result     -
//
function N_Utf8Decode( AUTF8Str: String; AErrorChar: WideChar = '?' ): WideString;
var
  SrcLeng, DstLeng: Integer;
begin
  Result := '';
  SrcLeng := Length( AUTF8Str );
  if SrcLeng = 0 then Exit;

  SetLength( Result, SrcLeng+5 ); // preliminary value, more than needed

  DstLeng := N_Utf8ToUnicode( @Result[1], SrcLeng, @AUTF8Str[1], SrcLeng, AErrorChar );
  SetLength( Result, DstLeng );
end; // function N_Utf8Decode


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_DecodeAnsiStringFromBytes
//****************************************** N_DecodeAnsiStringFromBytes ***
// Decode Resulting Ansi String from Array of Bytes using N_NeededCodePage,
// N_NeededTextEncoding
//
//     Parameters
// ASrcABytes - given Source Array of Bytes to Decode
// ANumBytes  - given Number of Bytes in ASrcABytes Array
// Result     - Return resulting Ansi String, Decoded from given ASrcABytes
//
// AsrcBytes are bytes of Text in ANSI, Unicode (UTF-16 LE) or UTF-8 format
//
function N_DecodeAnsiStringFromBytes( const ASrcABytes: TN_BArray; ANumBytes: integer ): AnsiString;
var
  NumChars, BegDataInd, NRes: integer;
  EncMode: TN_TextEncoding;
  WideStr: WideString;
  DefCharWasUsed: LongBool;
  BOMPresent: boolean;
begin
  Result := '';

  if ANumBytes = 0 then Exit; // all done

  EncMode    := TN_TextEncoding(N_NeededTextEncoding and $FF); // use lowest byte as Encoding mode
  BOMPresent := (N_NeededTextEncoding and N_UseBOMFlag) <> 0;
  BegDataInd := 0;

  if EncMode = teAuto then // recognize original Encoding mode by ASrcABytes
  begin
    EncMode := N_AnalizeBOMBytes( ASrcABytes, ANumBytes );

    if (EncMode = teUTF32BE) or (EncMode = teUTF32LE) or (EncMode = teUTF16BE) then
    begin
      Result := AnsiString('Format Not supported! ' + IntToStr(integer(EncMode)));
      Exit;
    end;

    if EncMode = teAuto then // ANSI or any mode without BOM, further analisys is not implemented
      EncMode := teANSI;
  end; // if EncMode = teAuto then // recognize original Encoding mode by ASrcABytes

  case EncMode of

  teANSI: // ANSI, just copy ASrcABytes to Result
  begin
    SetLength( Result, ANumBytes );
    move( ASrcABytes[0], Result[1], ANumBytes );
  end; // teANSI: // ANSI, just copy ASrcABytes to Result

  teUTF16LE: // Unicode UTF-16LE, convert to ANSI Result
  begin
    if BOMPresent then BegDataInd := 2;
    NumChars := (ANumBytes - BegDataInd) div 2;
    SetLength( Result, NumChars );
    NRes := WideCharToMultiByte( N_NeededCodePage, 0, PWideChar(@ASrcABytes[BegDataInd]), NumChars,
                               @Result[1], NumChars, @N_DefAnsiCharStr[1], @DefCharWasUsed );
    Assert( NRes = NumChars, 'N_DecodeAnsiStringFromBytes Error' );
  end; // teUTF16LE: // Unicode UTF-16LE, convert to ANSI Result

  teUTF8: // Unicode UTF-8, convert to Wide String Result
  begin
    if BOMPresent then BegDataInd := 3;
    SetLength( WideStr, ANumBytes ); // Max possible size
//    NumChars := Utf8ToUnicode( @WideStr[1], ANumBytes, TN_BytesPtr(@ASrcABytes[BegDataInd]), ANumBytes-BegDataInd );
    NumChars := Utf8ToUnicode( @WideStr[1], ANumBytes, PAnsiChar(@ASrcABytes[BegDataInd]), ANumBytes-BegDataInd );
    SetLength( WideStr, NumChars ); // Final size
    Result := N_WideToAnsi( WideStr );
  end; // Unicode UTF-8, convert to Wide String Result

  else Assert( False, 'Bad Encoding mode in N_DecodeAnsiStringFromBytes ' + IntToStr(integer(EncMode)) );

  end; // case EncMode of

end; // function N_DecodeAnsiStringFromBytes

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_DecodeWideStringFromBytes
//****************************************** N_DecodeWideStringFromBytes ***
// Decode Resulting Wide String from Array of Bytes using N_NeededCodePage, 
// N_NeededTextEncoding
//
//     Parameters
// ASrcABytes - given Source Array of Bytes to Decode
// ANumBytes  - given Number of Bytes in ASrcABytes Array
// Result     - Return resulting Wide String, Decoded from given ASrcABytes
//
// AsrcBytes are bytes of Text in ANSI, Unicode (UTF-16 LE) or UTF-8 format
//
function N_DecodeWideStringFromBytes( const ASrcABytes: TN_BArray; ANumBytes: integer ): WideString;
var
  NumChars, BegDataInd, NRes: integer;
  EncMode: TN_TextEncoding;
  BOMPresent: boolean;
begin
  Result := '';

  if ANumBytes = 0 then Exit; // all done

  EncMode    := TN_TextEncoding(N_NeededTextEncoding and $FF); // use lowest byte as Encoding mode
  BOMPresent := (N_NeededTextEncoding and N_UseBOMFlag) <> 0;
  BegDataInd := 0;

  if EncMode = teAuto then // recognize original Encoding mode by ASrcABytes
  begin
    EncMode := N_AnalizeBOMBytes( ASrcABytes, ANumBytes );

    if (EncMode = teUTF32BE) or (EncMode = teUTF32LE) or (EncMode = teUTF16BE) then
    begin
      Result := 'Format Not supported! ' + IntToStr(integer(EncMode));
      Exit;
    end;

    if EncMode = teAuto then // ANSI or any mode without BOM, further analisys is not implemented
      EncMode := teANSI;
  end; // if EncMode = teAuto then // recognize original Encoding mode by ASrcABytes

  case EncMode of

  teANSI: // ANSI, convert to Wide String Result
  begin
    NumChars := ANumBytes;
    SetLength( Result, NumChars );

//    NRes := MultiByteToWideChar( N_NeededCodePage, 0, TN_BytesPtr(@ASrcABytes[0]), NumChars,
    NRes := MultiByteToWideChar( N_NeededCodePage, 0, PAnsiChar(@ASrcABytes[0]), NumChars,
                                                      @Result[1], NumChars );
    Assert( NRes = NumChars, 'N_DecodeWideStringFromBytes Error' );
  end; // teANSI: // ANSI, convert to Wide String Result

  teUTF16LE: // Unicode UTF-16LE, just copy data ASrcABytes to Result
  begin
    if BOMPresent then BegDataInd := 2;

    SetLength( Result, (ANumBytes-BegDataInd) div 2 );
    move( ASrcABytes[BegDataInd], Result[1], ANumBytes-BegDataInd );
  end; // teUTF16LE: // Unicode UTF-16LE, just copy data ASrcABytes to Result

  teUTF8: // Unicode UTF-8, convert to Wide String Result
  begin
    if BOMPresent then BegDataInd := 3;
    SetLength( Result, ANumBytes ); // Max possible size
//    NumChars := Utf8ToUnicode( @Result[1], ANumBytes, TN_BytesPtr(@ASrcABytes[BegDataInd]), ANumBytes-BegDataInd );
    NumChars := Utf8ToUnicode( @Result[1], ANumBytes, PAnsiChar(@ASrcABytes[BegDataInd]), ANumBytes-BegDataInd );
    SetLength( Result, NumChars ); // Set Final size
  end; // Unicode UTF-8, convert to Wide String Result

  else Assert( False, 'Bad Encoding mode in N_DecodeWideStringFromBytes ' + IntToStr(integer(EncMode)) );

  end; // case EncMode of

end; // function N_DecodeWideStringFromBytes

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_DecodeStringFromBytes
//********************************************** N_DecodeStringFromBytes ***
// Decode Resulting String from Array of Bytes using N_NeededCodePage, 
// N_NeededTextEncoding
//
//     Parameters
// ASrcABytes - given Source Array of Bytes to Decode
// ANumBytes  - given Number of Bytes in ASrcABytes Array
// Result     - Return resulting String, Decoded from given ASrcABytes
//
// AsrcBytes are bytes of Text in ANSI, Unicode (UTF-16 LE) or UTF-8 format
//
function N_DecodeStringFromBytes( const ASrcABytes: TN_BArray; ANumBytes: integer ): string;
begin
  if SizeOf(Char) = 2 then // Delphi 2010
    Result := N_DecodeWideStringFromBytes( ASrcABytes, ANumBytes )
  else // Delphi 7
    Result := String(N_DecodeAnsiStringFromBytes( ASrcABytes, ANumBytes ));
end; // function N_DecodeStringFromBytes


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetFileSize
//*********************************************************** N_GetFileSize ***
// Get Size of given File
//
//     Parameters
// AFName - given File Name
// Result - Return Size of given File in bytes or -1 if File not exists
//
function N_GetFileSize( AFName: string ): int64;
var
  FStream: TFileStream;
begin
  Result := -1;
  if not FileExists( AFName ) then Exit;

  FStream := TFileStream.Create( AFName, fmOpenRead );
  Result := FStream.Size;
  FStream.Free;
end; //*** function N_GetFileSize

//****************************************************** N_SizeInBytesToStr ***
// Convert given file size in bytes to string with proper size units (B, KB, MB)
//
//     Parameters
// ASizeInBytes - given file size in bytes
// Result       - Return given ASizeInBytes as String in proper size units
//
function N_SizeInBytesToStr( ASizeInBytes: int64 ): string;
var
  DSize: Double;
begin
  if ASizeInBytes <= 1023 then // size in Bytes
  begin
    Result := Format( '%d B', [ASizeInBytes] );
    Exit;
  end; // if ASizeInBytes <= 1023 then // size in Bytes

  DSize := ASizeInBytes / 1024.0;

  if DSize < 1024.0 then // size in KBytes
  begin
    if DSize < 10.0 then
      Result := Format( '%.2f KB', [DSize] )
    else if DSize < 100.0 then
      Result := Format( '%.1f KB', [DSize] )
    else // 100 <= DSize < 1024
      Result := Format( '%d KB', [Round(DSize)] );

    Exit;
  end; // if DSize < 1024.0 then // size in KBytes

  DSize := DSize / 1024.0;

  if DSize < 10.0 then
    Result := Format( '%.2f MB', [DSize] )
  else if DSize < 100.0 then
    Result := Format( '%.1f MB', [DSize] )
  else // DSize >= 100
    Result := Format( '%d MB', [Round(DSize)] );

end; //*** function N_SizeInBytesToStr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SaveStringToFile
//*************************************************** N_SaveStringToFile ***
// Save given AString to file using N_EncodeStringToBytes
//
//     Parameters
// AFName  - file name
// AString - string to save
//
// Creates a new file with given string content. If file with given name already
// exists, it is deleted before saving.
//
procedure N_SaveStringToFile( AFName: string; AString: string );
var
  NumBytes: integer;
  PData: Pointer;
  BufBytes: TN_BArray;
begin
  NumBytes := N_EncodeStringToBytes( AString, BufBytes );

  if NumBytes = 0 then PData := nil
                  else PData := @BufBytes[0];

  N_WriteBinFile( AFName, PData, NumBytes );
end; //*** procedure N_SaveStringToFile

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CreateStringFromFile
//*********************************************** N_CreateStringFromFile ***
// Create new string from given file using N_DecodeStringFromBytes
//
//     Parameters
// AFName - file name
// Result - Return resulting string with file content
//
function N_CreateStringFromFile( AFName: string ): string;
var
  NumBytes: integer;
  BufBytes: TN_BArray;
  FStream: TFileStream;
begin
  Result := '';
  if not FileExists( AFName ) then Exit;

  FStream := TFileStream.Create( AFName, fmOpenRead );
  NumBytes := FStream.Size;

  if NumBytes > 0 then
  begin
    SetLength( BufBytes, NumBytes );
    Result := N_DecodeStringFromBytes( BufBytes, NumBytes );
  end;

  FStream.Free;
end; //*** function N_CreateStringFromFile

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CreateStringsFromFile
//********************************************** N_CreateStringsFromFile ***
// Create new StringList from given file using N_CreateStringFromFile
//
//     Parameters
// AFName - file name
// Result - Return resulting StringList with file content
//
function N_CreateStringsFromFile( AFName: string ): TStringList;
begin
  Result := TStringList.Create;
  Result.Text := N_CreateStringFromFile( AFName );
end; //*** function N_CreateStringsFromFile


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SaveStringsToFile
//************************************************** N_SaveStringsToFile ***
// Save given AStrings to file using N_NeededCodePage, N_NeededTextEncoding
//
//     Parameters
// AFName   - file name
// AStrings - strings to save
//
// Creates a new file with given strings content. If file with given name 
// already exists, it is deleted before saving.
//
procedure N_SaveStringsToFile( AFName: string; AStrings: TStrings );
var
  NumBytes: integer;
  PData: Pointer;
  BufBytes: TN_BArray;
begin
  NumBytes := N_EncodeStringToBytes( AStrings.Text, BufBytes );

  if NumBytes = 0 then PData := nil
                  else PData := @BufBytes[0];

  N_WriteBinFile( AFName, PData, NumBytes );
end; //*** procedure N_SaveStringsToFile


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_WriteTextFile
//********************************************************* N_WriteTextFile ***
// Conv to UNICODE!!! Write text file content
//
//     Parameters
// AFName   - file name
// AContent - text file content
//
// Creates a new file with given content. If file with given name already 
// exists, it is deleted.
//
procedure N_WriteTextFile( const AFName, AContent: string );
var
  Size: integer;
  FStream: TFileStream;
begin
  FStream := TFileStream.Create( AFName, fmCreate );
  Size := Length(AContent);
  if Size > 0 then FStream.Write( AContent[1], Size );
  FStream.Free;
end; //*** procedure N_WriteTextFile

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReadTextFile
//********************************************************** N_ReadTextFile ***
// Conv to UNICODE!!! Read text file content
//
//     Parameters
// AFName - file name
// Result - Returns string with file content
//
function N_ReadTextFile( AFName: string ): string;
var
  Leng: integer;
  FStream: TFileStream;
begin
  Result := 'OpenError';
  if not FileExists( AFName ) then Exit;
  
  FStream := TFileStream.Create( AFName, fmOpenRead );
  if FStream = nil then Exit;

  Leng := FStream.Size;
  SetLength( Result, Leng );
  if Leng > 0 then FStream.Read( Result[1], Leng );
  FStream.Free;

  Result := N_TrimLastSpecialChars( Result );
end; //*** function N_ReadTextFile

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReadANSITextFile
//*************************************************** N_ReadANSITextFile ***
// Read ANSI text file content
//
//     Parameters
// AFName - file name
// Result - Returns string with file content
//
function N_ReadANSITextFile( AFName: string ): string;
var
  Leng: integer;
  FStream: TFileStream;
  BufStr: AnsiString;
begin
  Result := 'OpenError';
  if not FileExists( AFName ) then Exit;

  FStream := TFileStream.Create( AFName, fmOpenRead );
  if FStream = nil then Exit;

  Leng := FStream.Size;
  SetLength( BufStr, Leng );
  if Leng > 0 then FStream.Read( BufStr[1], Leng );
  FStream.Free;

  Result := N_AnsiToString( BufStr );
end; //*** function N_ReadANSITextFile

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_BinFileToANSIString
//************************************************ N_BinFileToANSIString ***
// Read ANSI text file content
//
//     Parameters
// AFName   - given file name
// AMaxLeng - given max Length of resulting ANSI string (AMaxLeng <= 0 means any
//            Length is OK)
// Result   - Returns string with file content (AMaxLeng or less Length)
//
function N_BinFileToANSIString( AFName: string; AMaxLeng: Integer ): string;
var
  Leng: integer;
  FStream: TFileStream;
begin
  Result := 'OpenError';
  if not FileExists( AFName ) then Exit;

  FStream := TFileStream.Create( AFName, fmOpenRead );
  if FStream = nil then Exit;

  Leng := FStream.Size;
  if AMaxLeng > 0 then // AMaxLeng is given
    Leng := min( Leng, AMaxLeng );

  SetLength( Result, Leng );
  if Leng > 0 then FStream.Read( Result[1], Leng );
  FStream.Free;
end; //*** function N_BinFileToANSIString

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AddToTextFile
//********************************************************* N_AddToTextFile ***
// Add content to given text file
//
//     Parameters
// AFName   - file name
// AContent - adding file content
//
// Create new file with given content if it is absent.
//
procedure N_AddToTextFile( AFName, AContent: string );
var
  BufStr: string;
begin
  if FileExists( AFName ) then // add to existsing file
  begin
    BufStr := N_ReadTextFile( AFName );
    N_WriteTextFile( AFName, BufStr + AContent );
  end else // create new file
    N_WriteTextFile( AFName, AContent );
end; //*** function N_ReadTextFile

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AddStrToAnsiStream
//************************************************* N_AddStrToAnsiStream ***
// Add to given AStream given AStr, converted to Ansi String if needed
//
//     Parameters
// AStream - given Stream
// AStr    - given string
//
procedure N_AddStrToAnsiStream( AStream: TStream; AStr: string );
begin
  if Length(AStr) <= 0 then Exit;

  if SizeOf(Char) = 2 then  // Wide Chars (Delphi 2010)
  begin
    // presence of local var AnsiStr: AnsiString cause to warning in Delphi 7
    N_as := AnsiString(AStr);
    AStream.Write( N_as[1], Length(N_as) );
  end else //***************** Ansi Chars (Delphi 7)
    AStream.Write( AStr[1], Length(AStr) );
end; //*** procedure N_AddStrToAnsiStream

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SaveStringsToAnsiFile
//********************************************** N_SaveStringsToAnsiFile ***
// Save given Strings To File as Ansi Strings
//
//     Parameters
// AFName   - given file name
// AStrings - given AStrings to save
//
// Create new file with given content if it is absent.
//
procedure N_SaveStringsToAnsiFile( AFName: string; AStrings: TStrings );
begin
{$IF SizeOf(Char) = 2} // Wide Chars (Delphi 2010) Types and constants
  AStrings.SaveToFile( AFName, TEncoding.ASCII );
{$ELSE} //*************** Ansi Chars (Delphi 7) Types and constants
  AStrings.SaveToFile( AFName );
{$IFEND}
end; //*** function N_SaveStringsToAnsiFile

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_WriteBinFile
//********************************************************** N_WriteBinFile ***
// Write binary file content
//
//     Parameters
// AFName    - file name
// APData    - pointer to file data
// ADataSize - file data size in bytes
//
// Creates a new file with given content. If file with given name already 
// exists, it is deleted and a new file is created in its place.
//
procedure N_WriteBinFile( AFName: string; APData: Pointer; ADataSize: integer );
var
  FStream: TFileStream;
begin
  FStream := TFileStream.Create( AFName, fmCreate );
  if ADataSize > 0 then FStream.Write( APData^, ADataSize );
  FStream.Free;
end; //*** procedure N_WriteBinFile

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReadBinFile
//*********************************************************** N_ReadBinFile ***
// Read binary file content
//
//     Parameters
// AFName  - file name
// ABArray - bytes array for file content
// Result  - Returns file size in bytes
//
function N_ReadBinFile( AFName: string; var ABArray: TN_BArray ): integer;
var
  FStream: TFileStream;
begin
  FStream := TFileStream.Create( AFName, fmOpenRead );
  Result := FStream.Size;

  if Length(ABArray) < Result then
    SetLength( ABArray, Result );

  if Result > 0 then FStream.Read( ABArray[0], Result );
  FStream.Free;
end; //*** function N_ReadBinFile

//********************************************************** N_AddToBinFile ***
// Add given bytes to given binary file
//
//     Parameters
// AFName    - file name
// APData    - pointer to file data to add
// ADataSize - file data size in bytes
//
// Creates a new file with given content. If file with given name already
// exists, it is deleted and a new file is created in its place.
//
procedure N_AddToBinFile( AFName: string; APData: Pointer; ADataSize: integer );
var
  FStream: TFileStream;
begin
  if FileExists( AFName ) then
  begin
    FStream := TFileStream.Create( AFName, fmOpenReadWrite );
    FStream.Seek( 0, soFromEnd );
    if ADataSize > 0 then FStream.Write( APData^, ADataSize );
    FStream.Free;
  end else
    N_WriteBinFile( AFName, APData, ADataSize );

end; //*** procedure N_AddToBinFile


var N_ComprPrefix: Array [0..4] of DWORD = ($FFFFFFFF, $00000000, $FFFFFFFF,
                                            $5A4C6962, 0 ); // 'ZLib', Size
const N_ComprPrefixSize = SizeOf(N_ComprPrefix);

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CompressMem
//*********************************************************** N_CompressMem ***
// Compress given Data
//
//     Parameters
// APSrcBuf    - Pointer to Source Data to Compress
// ASrcBufSize - Number of Bytes in Source Data to Compress
// APDstBuf    - Pointer to Destination Buffer with resulting Compresed Data
// ADstBufSize - Size of Destination Buffer, should have place for all 
//               Compressed Data
// AComprLevel - compression level:
//#F
//     0 - no compression,
//     1 - fast compression,
//     2 - middle compression,
//     3 - maximal compression
//#/F
// Result      - Returns resulting Compressed Data length in bytes
//
function N_CompressMem( APSrcBuf: Pointer; ASrcBufSize: integer;
                        APDstBuf: Pointer; ADstBufSize, AComprLevel: integer ): integer;
var
  GMS: TN_GivenMemStream;
  ZStream: TCompressionStream;
begin
  GMS := TN_GivenMemStream.Create( APDstBuf, ADstBufSize );
  GMS.Write( N_ComprPrefix[0], N_ComprPrefixSize-4 );
  GMS.Write( ASrcBufSize, 4 );

  ZStream := TCompressionStream.Create( TCompressionLevel(AComprLevel), GMS );
  ZStream.Write( APSrcBuf^, ASrcBufSize );
  ZStream.Free;

  Result := GMS.Position;
  GMS.Free;
end; // function N_CompressMem

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetUncompressedSize
//*************************************************** N_GetUncompressedSize ***
// Get Compressed Data uncompressed size
//
//     Parameters
// APBuf    - pointer to Compressed Data
// ABufSize - size of Compressed Bytes in (ABufSize >= 20)
// Result   - Returns uncompressed data size or -1 if given data was not 
//            compressed by N_CompressMem
//
function N_GetUncompressedSize( APBuf: Pointer; ABufSize: integer ): integer;
begin
  Result := -1;
  if ABufSize < N_ComprPrefixSize then Exit;
  if not CompareMem( APBuf, @N_ComprPrefix[0], N_ComprPrefixSize-4 ) then Exit;
  Result := PInteger(TN_BytesPtr(APBuf) + N_ComprPrefixSize - 4)^;
end; // function N_GetUncompressedSize

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_DecompressMem
//********************************************************* N_DecompressMem ***
// Decompress given Mem and return Data Size of resulting Decompressed Data
//
//     Parameters
// APSrcBuf    - pointer to Source Data to Decompress
// ASrcBufSize - number of bytes in Source Data to Decompress
// APDstBuf    - pointer to Destination Buffer with resulting Decompresed Data
// ADstBufSize - size of Destination Buffer, should have place for all 
//               Decompressed Data
// Result      - Returns uncompressed data size or -1 if given data was not
// compressed  - by N_CompressMem
//
function N_DecompressMem( APSrcBuf: Pointer; ASrcBufSize: integer;
                          APDstBuf: Pointer; ADstBufSize: integer ): integer;
var
  ResSize: integer;
  GMS: TN_GivenMemStream;
  ZStream: TDecompressionStream;
begin
  Result := N_GetUncompressedSize( APSrcBuf, ASrcBufSize );
  if (Result = -1) or (Result > ADstBufSize) then Exit; // Error

  GMS := TN_GivenMemStream.Create( APSrcBuf, ASrcBufSize );
  GMS.Position := N_ComprPrefixSize;
  ZStream := TDecompressionStream.Create( GMS );
  ResSize := ZStream.Read( APDstBuf^, ADstBufSize );
  Assert( ResSize = Result, 'Decompr Error!' );
  ZStream.Free;
  GMS.Free;
end; // function N_DecompressMem

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_BytesToHexChars
//******************************************************* N_BytesToHexChars ***
// Convert given binary data to Hex Chars
//
//     Parameters
// APBytes   - pointer to source bytes
// ANumBytes - number of source bytes
// APChars   - pointer to resulting chars
//
// First two chars represent first byte(first char represent bits 4-7 of first 
// Byte, next char - bits 0-3), next two chars - next byte, APChars should 
// points to enough (2*ANumBytes*SizeOf(Char)) free memory, number of resulting 
// chars is always even, resulting chars are NOT a hexadecimal number!
//
procedure N_BytesToHexChars( APBytes: Pointer; ANumBytes: integer; APChars: PChar );
var
  i, CurByte, CurHalfByte: integer;
begin
  for i := 1 to ANumBytes do
  begin
    CurByte := PByte(APBytes)^;
    Inc( TN_BytesPtr(APBytes) );

    CurHalfByte := CurByte shr 4;
    if CurHalfByte <= 9 then APChars^ := Chr( integer('0') + CurHalfByte )
                        else APChars^ := Chr( integer('A') + CurHalfByte - 10 );
    Inc( APChars );

    CurHalfByte := CurByte and $0F;
    if CurHalfByte <= 9 then APChars^ := Chr( integer('0') + CurHalfByte )
                        else APChars^ := Chr( integer('A') + CurHalfByte - 10 );
    Inc( APChars );
  end; // for ByteInd := 1 to ANumBytes do
end; //*** procedure N_BytesToHexChars

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_HexCharsToBytes
//******************************************************* N_HexCharsToBytes ***
// Convert Hex Chars to binary data
//
//     Parameters
// APChars   - pointer to source Hex chars
// APBytes   - pointer to resulting bytes
// ANumBytes - number of resulting bytes
//
// First two chars represent first byte(first char represent bits 4-7 of first 
// Byte, next char - bits 0-3), next two chars - next byte, APBytes should 
// points to enough (ANumBytes) free memory, number of source chars should 
// always be even, source chars are NOT a hexadecimal number!
//
procedure N_HexCharsToBytes( APChars: PChar; APBytes: Pointer; ANumBytes: integer );
var
  i, LowByte, HighByte: integer;
begin
  for i := 1 to ANumBytes do
  begin
    HighByte := Byte(APChars^) - Byte('0');
    if HighByte >= 10 then
      HighByte := Byte(APChars^) - Byte('A') + 10;

    Inc( APChars );

    LowByte := Byte(APChars^) - Byte('0');
    if LowByte >= 10 then
      LowByte := Byte(APChars^) - Byte('A') + 10;

    Inc( APChars );

    PByte(APBytes)^ := LowByte + (HighByte shl 4);
    Inc( TN_BytesPtr(APBytes) );
  end; // for i := 1 to ANumBytes do
end; //*** procedure N_HexCharsToBytes

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_BytesToHexString
//****************************************************** N_BytesToHexString ***
// Convert given binary data to string of Hex Chars
//
//     Parameters
// APBytes   - pointer to source bytes
// ANumBytes - number of source bytes
// Result    - Returns string with resulting Hex Chars
//
// First two chars represent first byte(first char represent bits 4-7 of first 
// Byte, next char - bits 0-3), next two chars - next byte, APChars should 
// points to enough (2*ANumBytes) free memory, number of resulting chars is 
// always even, resulting string is NOT a hexadecimal number!
//
function N_BytesToHexString( APBytes: Pointer; ANumBytes: integer ): string;
begin
  SetLength( Result, 2*ANumBytes );
  if ANumBytes = 0 then Exit;
  N_BytesToHexChars( APBytes, ANumBytes, @Result[1] );
end; // function N_BytesToHexString

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_JoinStrings
//*********************************************************** N_JoinStrings ***
// Join strings with given delimiter
//
//     Parameters
// AStrings  - source strings list object
// ADelimStr - delimiter string
// Result    - Returns resulting joined string
//
// Is not the same as using TStringlist.DelimitedText property of because in 
// DelimitedText property QuoteChar can not be absent and only one char can be 
// used as delimiter.
//
function N_JoinStrings( AStrings: TStrings; ADelimStr: string ): string;
var
  i, ind, NumStrings, ResSize, DelimSize, StrSize: integer;
begin
  NumStrings := AStrings.Count;
  DelimSize := Length(ADelimStr);
  ResSize := 0;

  for i := 0 to NumStrings-1 do // Calc whole size of all strings in AStrings
    ResSize := ResSize + Length(AStrings[i]);

  SetLength( Result, ResSize + DelimSize*(NumStrings-1) );
  ind := 1;

  for i := 0 to NumStrings-1 do // Copy strings and Delimiters into Result
  begin
    StrSize := Length(AStrings[i]);
    if StrSize >= 1 then
      move( AStrings[i][1], Result[ind], StrSize*SizeOf(Char) );
    Inc( ind, StrSize );

    if (DelimSize >= 1) and (i < (NumStrings-1)) then
      move( ADelimStr[1], Result[ind], DelimSize*SizeOf(Char) );
    Inc( ind, DelimSize );
  end; // for i := 0 to NumStrings-1 do // Copy strings and Delimiters into Result
end; // function N_JoinStrings

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReplacePointByDecSep
//************************************************** N_ReplacePointByDecSep ***
// Replace '.' by Windows current Decimal Separator
//
//     Parameters
// AInpStr - source string
// Result  - Returns resulting string
//
// Replace '.' (Delphi Decimal Sepaprator) in given AInpStr by 
// N_WinFormatSettings.DecimalSeparator (Should be used before passing float 
// values to VBA in ParamsStr)
//
function N_ReplacePointByDecSep( AInpStr: string ): string;
var
  i: integer;
  NewDS: char;
begin
  Result := AInpStr;
  NewDS := N_WinFormatSettings.DecimalSeparator; // to reduce code size
  if NewDS = '.' then Exit; // nothing to do

  for i := 1 to Length(Result) do
    if Result[i] = '.' then Result[i] := NewDS;
end; // function N_ReplacePointByDecSep

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReplaceDecSepByPoint
//************************************************** N_ReplaceDecSepByPoint ***
// Replace Windows current Decimal Separator by '.'
//
//     Parameters
// AInpStr - source string
// Result  - Returns resulting string
//
// Replace N_WinFormatSettings.DecimalSeparator in given AInpStr by '.' (Delphi 
// Decimal Sepaprator) (Should be used after getting float values from VBA in 
// ParamsStr)
//
function N_ReplaceDecSepByPoint( AInpStr: string ): string;
var
  i: integer;
  CurDS: char;
begin
  Result := AInpStr;
  CurDS := N_WinFormatSettings.DecimalSeparator; // to reduce code size
  if CurDS = '.' then Exit; // nothing to do

  for i := 1 to Length(Result) do
    if Result[i] = CurDS then Result[i] := '.';
end; // function N_ReplaceDecSepByPoint

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_QuoteChars
//************************************************************ N_QuoteChars ***
// Quote given characters by given delimiter
//
//     Parameters
// APSrcChars   - pointer to source characters (to token to quote)
// ANumSrcChars - number of source characters
// AQuoteChar   - given Quote Character ( delimiter, usually (') or (") )
// APDstChars   - pointer to destination buffer where to write resulting quoted 
//                characters (Input and Output parameter)
//
// Write starting AQuoteChar, SrcChars (doubling AQuoteChar in SrcChars if any) 
// and final AQuoteChar. APDstChars should points to enough free memory (Max 
// needed is 2*ANumSrcChars+2). On output APDstChars points to next char after 
// final AQuoteChar Number of written Chars is (APDstChars(OnOutput) - 
// APDstChars(OnInput)) N_DeQuoteChars function can be used to get original 
// string
//
procedure N_QuoteChars( APSrcChars: PChar; ANumSrcChars: integer;
                                     AQuoteChar: Char; var APDstChars: PChar );
var
  i: integer;
begin
  APDstChars^ := AQuoteChar;
  Inc( APDstChars );

  for i := 1 to ANumSrcChars do // along all Source characters
  begin
    APDstChars^ := APSrcChars^;
    Inc( APDstChars );

    if APSrcChars^ = AQuoteChar then
    begin
      APDstChars^ := AQuoteChar;
      Inc( APDstChars );
    end;

    Inc( APSrcChars );
  end; // for i := 1 to ANumSrcChars do // along all Source characters

  APDstChars^ := AQuoteChar;
  Inc( APDstChars );
end; //*** procedure N_QuoteChars

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_DeQuoteChars
//********************************************************** N_DeQuoteChars ***
// Get token from given quoted characters witout quotes
//
//     Parameters
// APSrcChars  - pointer to source quoted characters with possible white 
//               characters prefix (Input and Output parameter)
// AIniResSize - initial resulting string size
// Result      - Returns string without leading whitespaces and quotes
//
// Skip initial white characters (all characters <= $020), remove starting and 
// final Quote character and convert pair of subsequent Quote characters to one 
// Quote character. Quote character is first character that is > $020 On output 
// APSrcChars points to next char after next char after final Quote character 
// (N_QuoteChars procedure can be used for creating Quoted Chars)
//
function N_DeQuoteChars( var APSrcChars: PChar; AIniResSize: integer ): string;
var
  CurSize, NewSize: integer;
  QuoteChar: Char;
  PCurRes, PEndRes: PChar;
begin
  NewSize := AIniResSize;
  SetLength( Result, NewSize );
  PCurRes := PChar( Result );
  PEndRes := PCurRes + NewSize;

  while APSrcChars^ <= Char( $020 ) do Inc( APSrcChars ); // Skip initial white chars
  QuoteChar := APSrcChars^; Inc( APSrcChars ); // Skip starting Quote char

  while True do // scan Source characters till final Quote char
  begin
    if PCurRes = PEndRes then // increase Resulting string
    begin
      CurSize := NewSize;
      NewSize := N_NewLength( CurSize );
      SetLength( Result, NewSize );
      PCurRes := PChar( Result ) + CurSize;
      PEndRes := PChar( Result ) + NewSize;
    end; // if PCurRes = PEndRes then // increase Resulting string

    PCurRes^ := APSrcChars^;
    Inc( APSrcChars );

    if PCurRes^ <> QuoteChar then // Not a Quote Character
    begin
      Inc( PCurRes );
      Continue;
    end else // Quote Character
    begin
      Inc( PCurRes );

      if APSrcChars^ = QuoteChar then // Next Char is a Quote too, skip it
      begin
        Inc( APSrcChars );
        Continue;
      end else // it was final Quote char
      begin
        Inc( APSrcChars );
        SetLength( Result, PCurRes - PChar(Result) - 1 );
        Exit; // all done
      end; // else // it was final Quote char

    end; // else // Quote Character
  end; // while True do // scan Source characters till final Quote char
end; //*** function N_DeQuoteChars

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_QuoteString
//*********************************************************** N_QuoteString ***
// Quote given string using N_QuoteChars procedure
//
//     Parameters
// ASrcStr    - source string
// AQuoteChar - given Quote Character (usually (') or ("))
// Result     - Returns quoted string
//
// Return quoted string using N_QuoteChars procedure
//
function N_QuoteString( ASrcStr: string; AQuoteChar: Char ): string;
var
  NumSrcChars: integer;
  PSrc, PRes: PChar;
begin
  NumSrcChars := Length(ASrcStr);
  PSrc := PChar(ASrcStr);
  SetLength( Result, 2*NumSrcChars + 2 );
  PRes := PChar(Result);
  N_QuoteChars( PSrc, NumSrcChars, AQuoteChar, PRes );
  SetLength( Result, PRes - PChar(Result) );
end; //*** function N_QuoteString

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CharInString
//******************************************************* N_CharInString ***
// Check if given AString contains at least one of given characters
//
//     Parameters
// AString - given String to check
// AChars  - string of given characters
// Result  - Return True if some character in AChars string contains in AString
//
function N_CharInString( AString, AChars: string ): boolean;
var
  i, j: integer;
  CurChar: Char;
begin
  Result := True;

  for i := 1 to Length(AString) do
  begin
    CurChar := AString[i];

    for j := 1 to Length(AChars) do
      if CurChar = AChars[j] then Exit; // found

  end; // for i := 1 to Length(AString) do

  Result := False; // not found
end; // function N_CharInString

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ConcatenateSArray
//************************************************** N_ConcatenateSArray ***
// Concatenate elements of given Array of String
//
//     Parameters
// AAStrings  - given Array of String to Concatenate
// AFlags     - Concatenation Flags
// ADelimStr  - Delimiter string (added between AStrings elements)
// ASpecChars - Special characters, if they are present in AStrings element it 
//              should be quoted
// AQuoteChar - Quote character, usually ' or ", AQuoteChar=0 means that quoting
//              is not needed
// AResString - Resulting string with Concatenated AStrings
// Result     - Return Number of resulting characters in AResString
//
// On output Length of AResString may be greater than Result, Length of 
// AResString is never decreased There is no terminating zero in resulting 
// AResString
//
function N_ConcatenateSArray( AAStrings: TN_SArray; AFlags: TN_ConcatFlags;
                                ADelimStr, ASpecChars: string; AQuoteChar: Char;
                                var AResString: string ): integer;
var
  i, ResSize, ElemLeng, DelimStrLeng, MaxLeng, CSize: integer;
  PRes, PResEnd: PChar;
begin
  ResSize := 200;
  for i := 0 to High(AAStrings) do // along all source strings
    ResSize := ResSize + Length(AAStrings[i]);

  ResSize := ResSize + Length(AAStrings)*Length(AdelimStr) + 200; // preliminary value

  if Length(AResString) < ResSize then
    SetLength( AResString, ResSize );

  if (cfUseExcelDelim in AFlags) then // ignore given AdelimStr and use ',' or ';'
  begin
    SetLength( ADelimStr, 1 );

    if N_WinFormatSettings.DecimalSeparator = '.' then // Enlish Excel version, use Comma
      AdelimStr[1] := ','
    else // Rusian Excel version, use Semicolumn
      AdelimStr[1] := ';';
  end; // if (cfUseExcelDelim in AFlags) then

  PRes    := @AResString[1];
  PResEnd := @AResString[Length(AResString)]; // to check if AResString should be increased
  DelimStrLeng := Length(ADelimStr);

  for i := 0 to High(AAStrings) do // along all source strings
  begin
    ElemLeng := Length(AAStrings[i]);
    MaxLeng  := 2*ElemLeng + 2 + DelimStrLeng; // max possible length

    if (PRes + MaxLeng) >= PResEnd then // increase AResString
    begin
      CSize := PRes - @AResString[1];
      SetLength( AResString, CSize + MaxLeng + 200 );
      PRes := PChar(@AResString[1]) + CSize;
      PResEnd := @AResString[Length(AResString)]; // to check if AResString should be increased
    end;

    if AQuoteChar = Char(0) then // Quoting is not needed use AAStrings[i] as is
    begin
      if ElemLeng > 0 then // AAStrings[i] is not empty, copy it to AResString
      begin
        move( AAStrings[i][1], PRes^, ElemLeng*SizeOf(Char) );
        Inc( PRes, ElemLeng );
      end;
    end else //******************** Quoting is needed
    begin
      if ElemLeng = 0 then // AAStrings[i] is empty
      begin
        if cfQuoteEmptyTokens in AFlags then // add double quote
        begin
          PRes^ := AQuoteChar; Inc( PRes );
          PRes^ := AQuoteChar; Inc( PRes );
        end;
      end else  // AAStrings[i] is not empty, quote it if needed
      begin
        if N_CharInString( AAStrings[i], ASpecChars ) then // Quoting is needed
        begin
          N_QuoteChars( @AAStrings[i][1], ElemLeng, AQuoteChar, PRes );
        end else //****************************************** Quoting is not needed
        begin
          move( AAStrings[i][1], PRes^, ElemLeng*SizeOf(Char) ); // copy AAStrings[i] to AResString
          Inc( PRes, ElemLeng );
        end; // else //****************************************** Quoting is not needed
      end; // else  // AAStrings[i] is not empty, quote it if needed
    end; // else //******************** Quoting is needed

    if (i < High(AAStrings)) and (DelimStrLeng > 0) then // add AdelimStr
    begin
      move( ADelimStr[1], PRes^, DelimStrLeng*SizeOf(Char) );
      Inc( PRes, DelimStrLeng );
    end; // if i < High(AAStrings) then // add AdelimStr

  end; // for i := 0 to High(AAStrings) do // along all source strings

  Result := PRes - @AResString[1]; // Number of resulting characters

end; // function N_ConcatenateSArray

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SaveSMatrToStrings2
//************************************************ N_SaveSMatrToStrings2 ***
// Add Strings Matrix to given Strings List in given format using 
// N_ConcatenateSArray
//
//     Parameters
// AStrMatr  - Strings Matrix (two dimensions array where first index - Row, 
//             second - Column)
// AStrings  - resulting TStrings (each adding string is buit from corresponding
//             AStrMatr row)
// ASMFormat - given Strings Format (CSV, Tab or Space delimited)
//
// If ASMFormat=smfCSV then same delimiter will be used as MS Excel does: Comma 
// "," for Enlish Excel version, Semicolumn ";" for Rus Excel version
//
procedure N_SaveSMatrToStrings2( AStrMatr: TN_ASArray; AStrings: TStrings;
                                                 ASMFormat: TN_StrMatrFormat );
var
  i, ResLeng: integer;
  BufStr, DelimStr, SpecChars: string;
  QuoteChar: Char;
begin
  QuoteChar := '"';
  SpecChars := Char('"')+Char($0D)+Char($0A);

  case ASMFormat of // prepare N_ConcatenateSArray params

  smfCSV: // Excel CSV format, use "," or ";"
  begin
    if N_WinFormatSettings.DecimalSeparator = '.' then // Enlish Excel version, use Comma
      DelimStr := ','
    else // Rusian Excel version, use Semicolumn
      DelimStr := ';';

    SpecChars := SpecChars + DelimStr;
  end; // smfCSV: // Excel CSV format, use "," or ";"

  smfTab: // Tab delimited tokens
  begin
    DelimStr := Char($09);
    SpecChars := SpecChars + DelimStr;
  end; // smfTab: // Tab delimited tokens

  smfClip: // format for copy Table to Windows Clipboard
  begin
    // Temporary not implemented

  end; // smfClip: // format for copy Table to Windows Clipboard

  smfSpace1: // One Space delimiter, quote only CR LF
  begin
    DelimStr := ' ';
  end; // smfSpace1: // One Space delimiter, quote only CR LF

  smfSpace3: // Three Space delimiter, quote only CR LF
  begin
    DelimStr := '   ';
  end; // smfSpace3: // Three Space delimiter, quote only CR LF

  end; // case ASMFormat do

  //***** Export AStrMatr to SL

  for i := 0 to High(AStrMatr) do // along all AStrMatr rows
  begin
    ResLeng := N_ConcatenateSArray( AStrMatr[i], [], DelimStr, SpecChars,
                                                     QuoteChar, BufStr );
    AStrings.Add( LeftStr( BufStr, ResLeng ) );
  end; // for i := 0 to High(AStrMatr) do // along all AStrMatr rows

end; // end of function N_SaveSMatrToStrings2

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SaveSMatrToFile2
//*************************************************** N_SaveSMatrToFile2 ***
// Save Strings Matrix to given file in given format using N_ConcatenateSArray
//
//     Parameters
// AStrMatr  - Strings Matrix (two dimensions array where first index - Row, 
//             second - Column)
// AFileName - given File Name
// ASMFormat - given File Format (CSV, Tab or Space delimited)
//
// For saving to file N_SaveStringsToFile procedure is used. If ASMFormat=smfCSV
// then same delimiter will be used as MS Excel does: Comma "," for Enlish Excel
// version, Semicolumn ";" for Rus Excel version
//
procedure N_SaveSMatrToFile2( AStrMatr: TN_ASArray; AFileName: string;
                                                 ASMFormat: TN_StrMatrFormat );
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  N_SaveSMatrToStrings2( AStrMatr, SL, ASMFormat );
  N_SaveStringsToFile( AFileName, SL );
  SL.Free;
end; // end of function N_SaveSMatrToFile2


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CharsToBool
//*********************************************************** N_CharsToBool ***
// Convert chars to boolean
//
//     Parameters
// APChar - pointer to chars - boolean value text representation
// Result - Returns FALSE if APChar points to '', '0', 'false', 'False', 'no', 
//          'No', 'нет', 'Нет' (only first char is analized), otherwise 
//          resulting value is TRUE.
//
// On output APChar points to first terminating delimeter (usually Space) or to 
// terminating zero
//
function N_CharsToBool( var APChar: PChar ): boolean;
begin
  Result := False;
  while Integer(APChar^) <= $20 do // skip possible white chars prefix
  begin
   if Integer(APChar^) = 0 then Exit; // Terminating zero
   Inc( APChar );
  end;

  case APChar^ of
    '0', 'f', 'F', 'n', 'N', 'н', 'Н':;
  else
    Result := True;
  end; // case APChar^ of

  while Integer(APChar^) > $20 do Inc( APChar ); // skip chars till terminating char
end; //*** function N_CharsToBool

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_StrToBool
//************************************************************* N_StrToBool ***
// Convert string to boolean
//
//     Parameters
// AStr   - source string with boolean value text representation
// Result - Returns FALSE if given AStr is empty or contains only white chars or
//          begins with '0', 'f', 'F', 'n', 'N', 'н', 'Н'  (0, false, no, нет) 
//          after possible white chars prefix (i.e. '  00', ' False', 'no', ' 
//          Нет'), otherwise resulting value is TRUE.
//
function N_StrToBool( AStr: string ): boolean;
var
  PCur: PChar;
begin
  PCur := PChar(AStr);
  Result := N_CharsToBool( PCur );
end; //*** function N_StrToBool


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetHTMLText
//*********************************************************** N_GetHTMLText ***
// Conv to UNICODE!!! Parse HTML text portion
//
//     Parameters
// APHTML    - on input - pointer to first Text char, on Output - points to next
//             char after last Text char ('<' or 0)
// APPortion - pointer to portion with parsed Text in HPText field and 
//             hsfLastSpace flag set if needed
//
// Get plain Text between or out of HTML Tags with:
//#L
// - ignoring all quotes
// - converting special characters (&nbsp; &amp; ...)
// - replacing CRLF by space chars
// - compressing several subsequent spaces to one space
//#/L
//
procedure N_GetHTMLText( var APHTML: PChar; APPortion: TN_PHTMLPortion );
var
  FreeInd: integer;
  ResStr: string;
  LastSpace: boolean;

  procedure AddChar( AChar: Char ); // local
  // Add given AChar to resulting ResStr and set LastSpace variable
  begin
    if Length(ResStr) < FreeInd then
      SetLength( ResStr, N_NewLength(FreeInd) );

    ResStr[FreeInd] := AChar;
    Inc(FreeInd);
  end; // procedure AddChar - local

  function CheckStr( AStr: string ): boolean; // local
  // Check if AStr is same with APHTML+1 substring without case sensitivity
  // and if same, advance APHTML by Length(AStr)+1
  var
    i: integer;
    PBeg, PStr: PChar;
    Label NotSame;
  begin
    PBeg := APHTML;
    Inc(APHTML); // skip '&'
    PStr := @AStr[1];

    for i := 1 to Length(AStr) do
    begin
      if ((byte(APHTML^) xor byte(PStr^)) and $DF) <> 0 then goto NotSame;
      Inc( APHTML );
      Inc( PStr );
    end; // for i := 0 to AStrSize-1 do

    //***** Same Substring

    if APHTML^ = ';' then Inc(APHTML); // skip terminating ';'
    Result := True;
    Exit;

    NotSame: //************
    APHTML := PBeg;
    Result := False;
  end; // function CheckStr - local

begin //*************************************** main body of N_GetHTMLText
  FreeInd := 1;

  with APPortion^ do
  begin

  LastSpace := hsfLastSpace in HPStateFlags;

  while True do // loop till terminating zero or '<'
  begin
  case APHTML^ of

    Char(0): // End of source Text
    begin
      SetLength( ResStr, FreeInd-1 );
      Break;
    end; // Char(0): // End of source Text

    '<': // Beg of Tag
    begin
      SetLength( ResStr, FreeInd-1 );
      Break;
    end; // '<': // Beg of Tag

    Char($0D): // Line break ($0D $0A)
    begin
      if not LastSpace then AddChar( ' ' );
      LastSpace := True;
      Inc( APHTML, 2 ); // skip CRLF
    end; // Char($0D): // Line break ($0D $0A)

    ' ': // Space
    begin
      if not LastSpace then AddChar( ' ' );
      LastSpace := True;
      Inc(APHTML);
    end; // ' ': // Space

    '&': // special character (&nbsp; &amp; ...)
    begin
           if CheckStr( 'nbsp' ) then AddChar( ' ' )
      else if CheckStr( 'amp' )  then AddChar( '&' )
      else if CheckStr( 'lt' )   then AddChar( '<' )
      else if CheckStr( 'gt' )   then AddChar( '>' )
      else // special character was not recognized, add it as is without converting
      begin
        AddChar( '&' );
        Inc(APHTML);
      end;
      LastSpace := False;
    end; // '&': // special character (&nbsp; &amp; ...)

    else // Other Char, add it to resulting ResStr
    begin
      AddChar( APHTML^ );
      Inc(APHTML);
      LastSpace := False;
    end; // else // ordinary Char

  end; // case APHTML^ of
  end; // while True do // loop till terminating zero or '<'

  HPPortionType := hptText;
  HPText := ResStr;

  if LastSpace then
    HPStateFlags := HPStateFlags + [hsfLastSpace]
  else
    HPStateFlags := HPStateFlags - [hsfLastSpace];

  if hsfDumpMode in HPStateFlags then // debug dump
    N_LCAdd( N_LCIHTMLParser, Format( 'TextPortion(%d):%s', [Length(ResStr),HPText] ));

  end; // with APPortion^ do
end; //*** procedure N_GetHTMLText

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetHTMLTag
//************************************************************ N_GetHTMLTag ***
// Parse HTML Tag Name and Attributes
//
//     Parameters
// APHTML    - on input points to '<', on Output points to next char after '>'
// APPortion - pointer to parsed Tag Name and Attributes
//
// Error Codes:
//#N
// 101 - No Attr Name before '=' Name - Value separator
// 102 - First char is not '<'
// 103 - No end of Comment string '-->'
// 104 - Terminating zero in Tag Attributes
// 105 - No Tag Attribute Value ('>' before '=')
// 106 - Name - Value separator is not '='
// 107 - No Tag Attribute Name (':' before Tag Name)
// 201 - No Style Attr Name before ':' Name - Value separator
// 205 - No Style Attribute Value (end of StyleValue before ':')
// 206 - Style Name - Value separator is not ':'
//#/N
//
procedure N_GetHTMLTag( var APHTML: PChar; APPortion: TN_PHTMLPortion );
var
  TokenSize, ResCode, ResStrSize: integer;
  QuoteChar, NextChar: Char;
  PToken, PBeg, PStyle: PChar;
  CommentDelim, TmpStr, ResStr, AttrName, StyleValue, OKStr: string;
  Label AddNextChar, Fin, Err, StyleErr, FinStyle;

  function GetToken(): string; // local
  begin
    // Note: difference of typed pointers is not in bytes but in number of elements of proper type!
    TokenSize := integer(APHTML - PToken);
    SetLength( Result, TokenSize );

    if TokenSize > 0 then
      move( PToken^, Result[1], TokenSize*SizeOf(Char) );
  end; // function GetToken(); - local

  function GetStyleToken(): string; // local
  begin
    // Note: difference of typed pointers is not in bytes but in number of elements of proper type!
    TokenSize := integer(PStyle - PToken);
    SetLength( Result, TokenSize );

    if TokenSize > 0 then
      move( PToken^, Result[1], TokenSize*SizeOf(Char) );
  end; // function GettyleToken(); - local

begin //************************* body of N_GetHTMLTag
  PStyle := nil;   // to avoid warning
  NextChar := '?'; // to avoid warning
  
  SetLength( ResStr, 100 );
  ResStrSize := 0;

  with APPortion^ do
  begin
    if HPAttribsSL = nil then
      HPAttribsSL := TStringList.Create()
    else
      HPAttribsSL.Clear();

    if HPStyleSL = nil then
      HPStyleSL := TStringList.Create()
    else
      HPStyleSL.Clear();

    CommentDelim := '-->'; // Comment Tag final delimiter
    PBeg := APHTML;
    HPResPos := 0;

    ResCode := 102; // First Tag char is not '<'
    if APHTML^ <> '<' then goto Err;

    Inc( APHTML ); // skip strting '<'
    HPPortionType := hptTagOpen;

    if APHTML^ = '/' then
    begin
      HPPortionType := hptTagClose;
      Inc( APHTML ); // skip '/'  before Tag Name
    end;

    PToken := APHTML;

    while APHTML^ >= 'A' do Inc(APHTML); // skip leading alfa chars (for speed)

    while True do // skip Tag Name chars till delimiter
    begin
      if APHTML^ = '>' then // End of Tag
      begin
        HPText := UpperCase( GetToken() ); // Tag Name
        Inc( APHTML ); // skip '>'
        goto Fin;
      end else if APHTML^ <= ' ' then // End of Tag Name
      begin
        HPText := UpperCase( GetToken() ); // Tag Name

        if APHTML^ = Char($0D) then
          Inc( APHTML, 2 ) // skip CR LF
        else
          Inc( APHTML ); // skip ' '

        Break;
      end;

      Inc(APHTML);
    end; // while True do // skip Tag Name chars till delimiter

    //***** Here: APHTML points to first char after Tag Name,
    //            Upper Case Tag Name is in HPText field

    if HPText = '!--' then // Comment Tag - special case
    begin
      PToken := StrPos( APHTML, @CommentDelim[1] );

      ResCode := 103; // No end of Comment string '-->'
      if PToken = nil then goto Err;

      APHTML := PToken;
      Inc( APHTML, SizeOf(CommentDelim) ); // skip '-->'
      HPPortionType := hptTagSingle;
      goto Fin;
    end; // if HPText = '!--' then // Comment Tag - special case

    while True do //****************** Parse Attributes Name=Value loop
    begin
      PToken := nil;
      TokenSize := 0;

      while True do // Parse Attr Name till terminating '=' (including spaces between Name and '=')
                    // and check for Tag terminating char '>'
      begin
        if APHTML^ = '=' then // end of Attr Name
        begin
          ResCode := 101; // No Attr Name before '=' Name - Value separator
          if PToken = nil then goto Err;

          if TokenSize = 0 then // TokenSize <> 0 means that there was spaces before '='
          begin
            TmpStr := UpperCase( GetToken() ) + '=';
            ResStrSize := Length( TmpStr );

            if Length( ResStr ) < ResStrSize then
              SetLength( ResStr, ResStrSize + 50 );

            move( TmpStr[1], ResStr[1], ResStrSize*SizeOf(Char) );
          end; // if TokenSize = 0 then // TokenSize <> 0 means that there was spaces before '='

          Break;
        end; // if APHTML^ > '=' then // end of Attr Name

        if APHTML^ = '>' then // Tag terminating '>'
        begin
          if PToken = nil then
          begin
            Inc(APHTML);
            goto Fin;
          end else // PToken <> nil some nonwhite chars were parsed
          begin
            ResCode := 105; // No Attribute Value ('>' before '=')
            goto Err;
          end;
        end; // if APHTML^ = '>' then // Tag terminating '>'

        if APHTML^ > ' ' then // nonwhite Char
        begin
          if PToken = nil then PToken := APHTML // first Name Char
          else if TokenSize <> 0 then Break; // nonwhite Char after white chars after Name (should be '=')
        end else // APHTML^ <= ' ' - white Char
        begin
          ResCode := 104; // Terminating zero in Attributes
          if APHTML^ = Char(0) then goto Err;

          if (PToken <> nil) and (TokenSize = 0) then  // end of Attr Name
          begin
            TmpStr := UpperCase( GetToken() ) + '=';
            ResStrSize := Length( TmpStr );

            if Length( ResStr ) < ResStrSize then
              SetLength( ResStr, ResStrSize + 50 );

            move( TmpStr[1], ResStr[1], ResStrSize*SizeOf(Char) );
          end; // if PToken <> nil then  // end of Attr Name

          if APHTML^ = Char($0D) then Inc(APHTML ); // skip CR
        end; // else // APHTML^ <= ' ' - white Char

        Inc(APHTML);
      end; // while True do // Parse Attr Name

      //***** Here: APHTML points to first nonwhite char after AttrName (should be '=')

      ResCode := 106; // Name - Value separator is not '='
      if APHTML^ <> '=' then goto Err;
      Inc(APHTML);

      PToken := nil;
      QuoteChar := Char(0);

      while True do // Parse Attr Value (after '=') till terminating Quote, '>' or ' '
      begin
        if APHTML^ >= 'A' then // for speed, check first for ordinary char
        begin
          NextChar := APHTML^;
          if PToken = nil then PToken := APHTML;
          goto AddNextChar;
        end; // if APHTML^ >= 'A' then // for speed, check first for ordinary char

        if APHTML^ = Char($0D) then // conv CR LF to one space
        begin
          NextChar := ' ';
          Inc( APHTML );
          goto AddNextChar;
        end; // if APHTML^ = Char($0D) then // conv CR LF to one space

        ResCode := 104; // Terminating zero in Attributes
        if APHTML^ = Char(0) then goto Err;

        if APHTML^ > ' ' then // nonwhite Char
        begin
          if APHTML^ = QuoteChar then // Value terminating Quote
          begin
            HPAttribsSL.Add( Copy( ResStr, 1, ResStrSize ) );
            Inc(APHTML);
            Break;
          end; // if APHTML^ = QuoteChar then // Value terminating Quote

          if APHTML^ = '>' then // Value and Tag terminating '>'
          begin
            ResCode := 107; // No Tag Attribute Name (':' before Tag Name)
            if PToken = nil then goto Err;

            HPAttribsSL.Add( Copy( ResStr, 1, ResStrSize ) );
            Inc(APHTML);
            goto Fin;
          end; // if APHTML^ = '>' then // Value and Tag terminating '>'

          if (QuoteChar = Char(0)) and
             ( (APHTML^ = Char($22)) or (APHTML^ = Char($27)) or   // ' or "  - Starting Quote
               (APHTML^ = Char($7B)) )  then // { - Starting Style Value delimiter
          begin
            QuoteChar := APHTML^;
            PToken := APHTML + 1; // first Name Char
            NextChar := (APHTML + 1)^;
            Inc(APHTML);
            Continue;
          end else // ordinary char
          begin
            if PToken = nil then
              PToken := APHTML; // first Name Char
            NextChar := APHTML^;
            goto AddNextChar;
          end; // else // ordinary char

        end else // APHTML^ <= ' ' - white Char
        begin
          NextChar := ' ';
          if PToken = nil then // white char before first Style Attr Name, skip it
          begin
            Inc(APHTML);
            Continue;
          end;

          if (PToken <> nil) and (QuoteChar = Char(0)) then // end of Value
          begin
            HPAttribsSL.Add( Copy( ResStr, 1, ResStrSize ) );

            if APHTML^ = Char($0D) then Inc(APHTML ); // skip CR
            Inc(APHTML); // skip ' ' or LF
            Break;
          end;
        end; // else // APHTML^ <= ' ' - white Char

        AddNextChar: // Add NextChar to ResStr and Inc APHTML

        if Length( ResStr ) < ResStrSize+1 then
          SetLength( ResStr, ResStrSize + 50 );

        Inc( ResStrSize );
        ResStr[ResStrSize] := NextChar;
        Inc( APHTML );
      end; // while True do // Parse Attr Value till terminating Quote or ' '

    end; // while True do //****************** Parse Attributes Name=Value loop


    Fin: //*** All Tag Attributes are parsed OK,
         //    Check if <br> Tag and parse Style if exists

    if HPText = 'BR' then // <br> Tag - special case
    begin
      HPPortionType := hptTagSingle;
    end; // if HPText = 'BR' then // <br> Tag - special case

    StyleValue := HPAttribsSL.Values['STYLE'];

    if StyleValue <> '' then // Style if exists, parse Style Name:Value; pairs
    begin
      PStyle := @StyleValue[1];

      while True do // Parse Style Name:Value; pairs loop
      begin
        PToken := nil;
        TokenSize := 0;

        while True do // Parse Style Attr Name till terminating ':'
                      // (including spaces before Name and between Name and ':')
                      // and check for terminating zero
        begin
          if PStyle^ = ':' then // end of Style Attr Name
          begin
            ResCode := 201; // No Style Attr Name before ':' Name - Value separator
            if PToken = nil then goto StyleErr;

            AttrName := UpperCase( Trim( GetStyleToken() ) );
            Break;
          end; // if PStyle^ = ':' then // end of Style Attr Name

          if PStyle^ = Char(0) then // Style terminating zero
          begin
            if PToken = nil then
            begin
              Inc(PStyle);
              goto FinStyle;
            end else // PToken <> nil some nonwhite chars were parsed
            begin
              ResCode := 205; // No Style Attribute Value (end of StyleStr before ':')
              goto StyleErr;
            end;
          end; // if PStyle^ = Char(0) then // Style terminating zero

          if PStyle^ > ' ' then // nonwhite Char
          begin
            if PToken = nil then PToken := PStyle // first Name Char
            else if TokenSize <> 0 then Break; // nonwhite Char after Name
          end else // PStyle^ <= ' ' - white Char
          begin
            if PToken <> nil then  // end of Style Attr Name
              AttrName := UpperCase( Trim( GetStyleToken() ) );
          end; // else // PStyle^ <= ' ' - white Char

          Inc(PStyle);
        end; // while True do // Parse Style Attr Name till terminating ':'

        //***** Here: PStyle points to first nonwhite char after Style AttrName (should be ':')

        ResCode := 206; // Name - Value separator is not '='
        if PStyle^ <> ':' then goto StyleErr;
        Inc(PStyle);

        PToken := nil;

        while True do // Parse Style Attr Value till terminating zero or ';' char
        begin
          if PStyle^ = ';' then // Style Attr Value till terminating ';' char
          begin
            if PToken <> nil then
              HPStyleSL.Add( AttrName + '=' + Trim(GetStyleToken()) )
            else
              HPStyleSL.Add( AttrName + '=' );

            Inc(PStyle);
            Break;
          end; // if PStyle^ = ';' then // Style Attr Value till terminating ';' char

          if PStyle^ = Char(0) then // Style Attr Value and StyleStr terminating zero
          begin
            if PToken <> nil then
              HPStyleSL.Add( AttrName + '=' + Trim(GetStyleToken()) )
            else
              HPStyleSL.Add( AttrName + '=' );

            goto FinStyle;
          end; // if APHTML^ = '>' then // Value and Tag terminating '>'

          if PStyle^ > ' ' then // nonwhite Char in Style Attr Value
          begin
            if PToken = nil then
              PToken := PStyle; // first Style Attr Value Char
          end; // if PStyle^ > ' ' then // nonwhite Char in Style Attr Value

          Inc(PStyle);
        end; // while True do // Parse Attr Value till terminating Quote or ' '

      end; // while True do // Parse Style Attr Name:Value; pairs loop

      FinStyle: //**********

    end; // if StyleValue <> '' then // Style if exists, parse Style Name:Value; pairs

    HPResPos := 0;
    if hsfDumpMode in HPStateFlags then // debug dump
    begin
      N_LCAdd( N_LCIHTMLParser, '' );
      N_LCAdd( N_LCIHTMLParser, Format( '*** HPPortionType:%d, HPText:%s', [integer(HPPortionType), HPText] ));
      Inc( N_LogChannels[N_LCIHTMLParser].LCIndent, 2 );

      if HPAttribsSL.Count >= 1 then
      begin
        N_LCAdd( N_LCIHTMLParser, 'HPAttribsSL:' );
        N_LCAdd( N_LCIHTMLParser, HPAttribsSL.Text );
      end;

      if HPStyleSL.Count >= 1 then
      begin
        N_LCAdd( N_LCIHTMLParser, 'HPStyleSL:' );
        N_LCAdd( N_LCIHTMLParser, HPStyleSL.Text );
      end;

      Dec( N_LogChannels[N_LCIHTMLParser].LCIndent, 2 );
      N_LCExecAction( N_LCIHTMLParser, lcaFlush );
    end; // if hsfDumpMode in HPStateFlags then // debug dump
    Exit;

    StyleErr: //******* Style Parsing Error
    // Note: difference of typed pointers is not in bytes but in number of elements of proper type!
    HPResPos  := integer(PStyle - PBeg) + 1;

    Err: //************
    if HPResPos = 0 then // not Style Error
      // Note: difference of typed pointers is not in bytes but in number of elements of proper type!
      HPResPos  := integer(APHTML - PBeg) + 1;

    HPPortionType := hptError;
    HPResCode := ResCode;

    // Write Error Info to HPErrInfoSL for Protocol

    if HPErrInfoSL = nil then HPErrInfoSL := TStringList.Create()
                         else HPErrInfoSL.Clear();
    with HPErrInfoSL do
    begin
      Add( '' );
      Add( Format( 'HTML Parser Error %d  at Pos=%d', [HPResCode, HPResPos] ) );
      Add( 'Last Src: ' + PBeg^ );
      OKStr := Copy( PBeg^, 1, HPResPos ); // Src text before Error
      Add( 'OK   Src: ' + OKStr );
    end; // with HPErrInfoSL do

  end; // with APPortion^ do
end; //*** procedure N_GetHTMLTag

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetHTMLPortion
//******************************************************** N_GetHTMLPortion ***
// Get HTML portion (Tag or Text before, between or after Tags)
//
//     Parameters
// APHTML    - pointer to first char of of HTML portion (on Output points to 
//             first char of next portion)
// APPortion - pointer to parsed portion data
//
procedure N_GetHTMLPortion( var APHTML: PChar; APPortion: TN_PHTMLPortion );
  Label ParseNextPortion;
begin
  with APPortion^ do
  begin

    ParseNextPortion: //**********************************

    case APHTML^ of // check first portion Char

      Char(0): // End of Source HTML
      begin
        HPPortionType := hptEnd;
        Exit;
      end; // Char(0): // End of Source HTML

      '<': // Tag
      begin
        N_GetHTMLTag( APHTML, APPortion );
      end; // '<': // Tag

      else // beg of Text
      begin
        N_GetHTMLText( APHTML, APPortion );
        if APPortion^.HPText = '' then // Empty Text, may appear after skipping spaces
          goto ParseNextPortion;
      end; // else // beg of Text

    end; // case APHTML^ of // check first portion Char

  end; // with APPortion^ do
end; //*** procedure N_GetHTMLPortion

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AddSplittedStr
//***************************************************** N_AddSplittedStr ***
// ?? Conv to UNICODE??? Split given AStr and add splitted substrings to given 
// AStrings
//
//     Parameters
// AStrings  - given TStrings object
// AStr      - given source String to split and add
// AMaxChars - if Length(AStr) <= AMaxChars then Astr should not be splitted
//
procedure N_AddSplittedStr( AStrings: TStrings; AStr: String; AIndent, AMaxChars: integer );
var
  i, j, ASBegInd, ASEndInd, FragmSize: integer;
  FullPrefix, BufStr: string;
  CurChar: Char;
  Label DelimFound;

  procedure AddFragm( AAStrings: TStrings ); // local
  // add AStr fragment to AAStrings
  begin
    FragmSize := ASEndInd-ASBegInd+1;

    SetLength( BufStr, Length(FullPrefix)+2+FragmSize );

    if Length(FullPrefix) > 0 then
      move( FullPrefix[1], BufStr[1], Length(FullPrefix) );

    j := Length(FullPrefix) + 1;
    BufStr[j]  := Char( Ord(Char('0')) + (i mod 10));
    BufStr[j+1] := ' ';

    move( AStr[ASBegInd], BufStr[j+2], FragmSize );
    ASBegInd := ASEndInd + 1;

    AAStrings.Add( BufStr );
  end; // procedure AddFragm() // local

begin
  if AMaxChars <= 30 then AMaxChars := 30;
  FullPrefix := DupeString( ' ', AIndent );

  if Length( AStr ) <= AMaxChars then // do not split AStr
  begin
    AStrings.Add( FullPrefix + AStr );
  end else //*************************** split AStr
  begin
    ASBegInd := 1;
    for i := 0 to 999 do // Split AStr loop
    begin
      if (Length(AStr)-ASBegInd) <= AMaxChars then // add last fragment (finish split AStr)
      begin
        ASEndInd := Length(AStr);
        AddFragm(  AStrings );
        Break;
      end else //************************************ add next fragment
      begin
        for j := ASBegInd+AMaxChars-20 to ASBegInd+AMaxChars do // find delimeter
        begin
          CurChar := AStr[j];
          if (CurChar = ' ') or (CurChar = ',') or (CurChar = '(') or
             (CurChar = ')') or (CurChar = ':') then // delimeter found
          begin
            ASEndInd := j;
            goto DelimFound;
          end;
        end; // for j := ASBegInd+AMaxChars-20 to ASBegInd+AMaxChars do // find delimeter

        ASEndInd := ASBegInd+AMaxChars;

        DelimFound: //*************
        AddFragm( AStrings );
      end; // end else //***************************** add next fragment
    end; // for i := 0 to 1000 do // Split AStr loop
  end; // end else //******************* split AStr
end; // procedure N_AddSplittedStr


//****************  Log procedures  ***********

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_LCExecAction
//********************************************************** N_LCExecAction ***
// Execute given ALCAction for given Log Channel ALCInd
//
//     Parameters
// ALCInd    - given Log Chanel Index
// ALCAction - given Action to execute (see TN_LCActionType)
// AIntPar   - some integer parameter (has different sense for differenet 
//             actions)
//
// ALCAction:
//#F
// lcaClearBuf    - Clear Buf (Write LCBuf to file)
// lcaSetBufSize  - Set (change) PCBuf Size in strings (PCBuf.Capacity)
// lcaFlush       - Flush PCBuf (Clear PCBuf and destroy PCFStream)
// lcaPrepFStream - Prepare PCFStream (Create FStream and position it to end of file if needed)
// lcaFree        - Clear Buf and Free Log Channel Resources
//#/F
//
procedure N_LCExecAction( ALCInd: integer; ALCAction: TN_LCActionType;
                                           AIntPar: integer = 0 );
var
  i: integer;
  FName: string;
begin
  if ALCInd = -1 then // ALCAction should be executed for all channels
  begin
    if ALCAction = lcaFree then // Free all channels resources
    begin
      for i := 0 to High(N_LogChannels) do
        N_LCExecAction( i, lcaFree );

      Exit;
    end; // if ALCAction = lcaFree then // Free all channels resources

    if ALCAction = lcaFlush then // Flush all channels
    begin
      for i := 0 to High(N_LogChannels) do
        N_LCExecAction( i, lcaFlush );

      Exit;
    end; // if ALCAction = lcaFlash then // Flash all channels
  end; // if ALCInd = -1 then // ALCAction should be executed for all channels

  if (ALCInd < 0) or (ALCInd > High(N_LogChannels)) then Exit; // a precaution

  with N_LogChannels[ALCInd] do // execute ALCAction for ALCInd Chanel
  begin

  case ALCAction of // lcaClearBuf, lcaSetBufSize, lcaFlush,
                    // lcaPrepFStream, lcaFree

  lcaClearBuf: //************************** Clear Buf (Write LCBuf to file)
  begin
    if LCBuf = nil then Exit;

    if LCBuf.Count >= 1 then // LCBuf is not Empty
    begin
        N_LCExecAction( ALCInd, lcaPrepFStream );

        if LCFStream <> nil then // Stream was prepared OK, write to it
        begin
          N_AddStrToAnsiStream( LCFStream, LCBuf.Text );
          LCBuf.Clear();
        end else // Stream was not prepared, do not clear LCBuf
        begin
          LCBuf.Add( 'Log File was busy!' );
        end;

    end; // if LCBuf.Count >= 1 then // PCBuf is not Empty

  end; // lcaClearBuf: // Clear Buf (Write PCBuf to file)

  lcaSetBufSize: //************************ Set (change) PCBuf Size (PCBuf.Capacity)
  begin
    LCBufSize := AIntPar;
    if LCBuf = nil then LCBuf := TStringList.Create();

    if LCBufSize < LCBuf.Count then
      N_LCExecAction( ALCInd, lcaClearBuf );

    if LCBuf.Capacity < LCBufSize then
      LCBuf.Capacity := LCBufSize;
  end; // lcaSetBufSize: // Set PCBuf Size

  lcaFlush: //**************************** Flush PCBuf (Clear PCBuf and destroy PCFStream)
  begin
    if LCBuf = nil then Exit;
    
    N_LCExecAction( ALCInd, lcaClearBuf );
    if LCBuf.Count = 0 then // LCBuf is Empty
      FreeAndNil( LCFStream );

    Inc( LCFlashCounter );
//    PCFstream := TFileStream.Create( PCFullFName, fmOpenReadWrite	);
//    PCFstream.Seek( 0, soFromEnd);
  end; // lcaFlash: // Flush PCBuf

  lcaPrepFStream: //********************** Prepare PCFStream
  begin
    if LCFStream <> nil then Exit; // already OK

    if LCFullFName = '' then // prepare Full File Name
    begin
      FName := LCFName;
      if FName = '' then // set default Log Channel File Name
        FName := '(##Exe)Log' + IntToStr(ALCInd) + '.txt';

      LCFullFName := K_ExpandFileName( FName );
      K_ForceFilePath( LCFullFName );
    end; // if LCFullFName = '' then // prepare Full File Name

    if FileExists(LCFullFName) and
       ((lcsfNotEmpty in LCStateFlags) or (lcfAppendMode in LCFlags)) then
    begin
      try
        LCFstream := TFileStream.Create( LCFullFName, fmOpenReadWrite ); //, fmShareDenyNone	);
        LCFstream.Seek( 0, soFromEnd);
//      N_s := LCFullFName;
//      N_i := LCFstream.Seek( 0, soFromCurrent);
      except
        LCFstream := nil;
      end;
    end else
      LCFstream := TFileStream.Create( LCFullFName, fmCreate );
  end; // lcaPrepFStream: // Prepare PCFStream

  lcaFree: //***************************** Free Log Channel Resources
  begin
    N_LCExecAction( ALCInd, lcaClearBuf );
    LCCounter := 0;
    FreeAndNil( LCBuf );
    FreeAndNil( LCFStream );
  end; // lcaFree: // Free Protocol Channel Resources

  end; // case ALCAction of

  end; // with N_LogChannels[ALCInd] do // execute ALCAction for ALCInd Chanel
end; // procedure N_LCExecAction

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_LCAdd
//***************************************************************** N_LCAdd ***
// Add given string to given Log Channel
//
//     Parameters
// ALCInd - given Log Chanel Index
// AStr   - given string Log message
//
procedure N_LCAdd( ALCInd: integer; AStr: string );
var
  i, j, ASBegInd, ASEndInd, FragmSize: integer;
  FullPrefix, BufStr: string;
  CurChar: Char;
  CurLocalTime: TDateTime;
  Label DelimFound;

  procedure AddFragm(); // local
  // add FullPrefix fragment
  begin
    with N_LogChannels[ALCInd] do
    begin
      FragmSize := ASEndInd-ASBegInd+1;

      SetLength( BufStr, FragmSize+2 ); // 2 is last i digit and space

      j := 1;
      BufStr[j]  := Char( Ord(Char('0')) + (i mod 10));
      BufStr[j+1] := ' ';

      move( FullPrefix[ASBegInd], BufStr[j+2], FragmSize*SizeOf(Char) );
      ASBegInd := ASEndInd + 1;

      LCBuf.Add( BufStr );

      if LCSecondCInd >= 1 then // LCSecondCInd <= 0 means nothing to do
        N_LCAdd( LCSecondCInd, BufStr );
    end; //with N_LogChannels[ALCInd] do
  end; // procedure AddFragm() // local

begin
  if (ALCInd < 0) or (ALCInd > High(N_LogChannels)) then Exit;

  with N_LogChannels[ALCInd] do
  begin
    if not(lcfEnable in LCFlags) then Exit;

    if LCBuf = nil then LCBuf := TStringList.Create();

    if LCCounter = 0 then // first writing
    begin
      N_LCExecAction( ALCInd, lcaPrepFStream );
      LCStateFlags := LCStateFlags + [lcsfNotEmpty];
      CurLocalTime := Now();

      if lcfShowHeader in LCFlags then // add header string
      begin
        LCBuf.Add( '' );
        LCBuf.Add( '*** New log portion at ' + DateTimeToStr( LCTimeShift+CurLocalTime ) +
                             '  Local time=' + DateTimeToStr( CurLocalTime )  );
        N_SL.Clear;
        N_PlatformInfo( N_SL, $01 );

        LCBuf.Add( '*** ' + N_SL[0] + ', Compiled by  ' + N_DelphiVersion() );
      end; // if lcfShowHeader in LCFlags then // add header string

      //***** Show immediately
      //        if LCShowForm is TN_MemoForm then
      //          TN_MemoForm(LCShowForm).Memo.Lines.AddStrings( LCBuf );

    end; // if PCCounter = 0 then // first writing

    Inc( LCCounter );

    FullPrefix := '';

    if (LCPrefix <> '') or (LCIndent > 0) then
      FullPrefix := DupeString( ' ', LCIndent ) + LCPrefix;

    if lcfShowCounter in LCFlags then
      FullPrefix := Format( '%s%4d> ', [FullPrefix, LCCounter] );

    if lcfShowTime in LCFlags then
      FullPrefix := FullPrefix + FormatDateTime( 'dd-hh":"nn":"ss.zzz ', LCTimeShift + Now() );

    FullPrefix := FullPrefix + AStr; // now FullPrefix is whole string

    if Length( FullPrefix ) < LCWrapSize then // do not split (FullPrefix is whole string)
    begin
      LCBuf.Add( FullPrefix );

      if LCSecondCInd >= 1 then // LCSecondCInd <= 0 means nothing to do
        N_LCAdd( LCSecondCInd, FullPrefix );
    end else //********************************* split (FullPrefix is whole string)
    begin
//      if StrPos( @FullPrefix[1], @N_StrCRLF[1] ) <> nil then // do not split if CRLF inside
      if Pos( N_StrCRLF, FullPrefix ) <> 0 then // do not split if CRLF inside
      begin
        LCBuf.Add( FullPrefix );

        if LCSecondCInd >= 1 then // LCSecondCInd <= 0 means nothing to do
          N_LCAdd( LCSecondCInd, FullPrefix );
      end else //********************************************* no CRLF inside, do split
      begin
        ASBegInd := 1;

        for i := 0 to 999 do // Split FullPrefix loop
        begin
          if (Length(FullPrefix)-ASBegInd) <= LCWrapSize then // add last fragment (finish split AStr)
          begin
            ASEndInd := Length(FullPrefix);
            AddFragm();
            Break;
          end else //***************************** add next fragment
          begin
            for j := ASBegInd+LCWrapSize-30 to ASBegInd+LCWrapSize-10 do // find delimeter
            begin
              CurChar := FullPrefix[j];
              if (CurChar = ' ') or (CurChar = ',') or (CurChar = '(') or
                 (CurChar = ')') or (CurChar = ':') then // found
              begin
                ASEndInd := j;
                goto DelimFound;
              end;
            end; // for j := ASBegInd+LCWrapSize-30 to ASBegInd+LCWrapSize-10 do // find delimeter

            ASEndInd := ASBegInd+80;

            DelimFound: //*************
            AddFragm();
          end; // else //***************************** add next fragment
        end; // for i := 0 to 999 do // Split FullPrefix loop
      end; // else //******************************** no CRLF inside, do split
    end; // else //********************************* split (FullPrefix is whole string)

    if (lcfFlushMode in LCFlags) or (LCBuf.Count > LCBufSize) then
      N_LCExecAction( ALCInd, lcaFlush );

  end; // with N_LogChannels[ALCInd] do
end; //*** procedure N_LCAdd

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_LCAddTyped
//********************************************************* N_LCAddTyped ***
// Add given Typed string to given Log Channel
//
//     Parameters
// ALCInd - given Log Chanel Index
// AType  - given string Type
// AStr   - given string Log message
//
// If several consequent strings with same AType are added, all strings except 
// last one will be skipped
//
procedure N_LCAddTyped( ALCInd, AType: integer; AStr: string );
begin
  if (ALCInd < 0) or (ALCInd > High(N_LogChannels)) then Exit;

  with N_LogChannels[ALCInd] do
  begin
    if LCPendingType > 0 then // LCPendingStr exists
    begin
      if AType = LCPendingType then // same AType, update LCPendingStr and LCPendingCount
      begin
        LCPendingStr := AStr;
        Inc( LCPendingCount );
      end else // LCPendingType <> AType, new Atype, add LCPendingStr and clear LCPendingCount
      begin
        if LCPendingCount > 1 then
          N_LCAdd( ALCInd, LCPendingStr + Format( ' [C=%d]', [LCPendingCount] ) )
        else
          N_LCAdd( ALCInd, LCPendingStr );

        LCPendingType  := AType; // AType may be 0 or not
        LCPendingStr   := AStr;
        LCPendingCount := 1;
      end; // else
    end else // LCPendingType = 0 (no LCPendingStr)
    begin
      LCPendingType  := AType; // AType may be 0 or not
      LCPendingStr   := AStr;  // if LCPendingType = 0, LCPendingStr will not be used
      LCPendingCount := 1;
    end; // else
  end; // with N_LogChannels[ALCInd] do
end; // procedure N_LCAddTyped

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_LCAddErr
//************************************************************** N_LCAddErr ***
// Add firt of the Error Messages series to given Log Channel
//
//     Parameters
// ALCInd - given Log Chanel Index
// AStr   - given string Log Error message
//
// Just call N_LCAdd and set Error flag lcsfErrInfo
//
procedure N_LCAddErr( ALCInd: integer; AStr: string );
begin
  if (ALCInd < 0) or (ALCInd > High(N_LogChannels)) then Exit;

  N_LCAdd( ALCInd, AStr );
  with N_LogChannels[ALCInd] do
    LCStateFlags := LCStateFlags + [lcsfErrInfo];
end; //*** procedure N_LCAddErr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_LCClearErr
//************************************************************ N_LCClearErr ***
// Add last of the Error Messages series to given Log Channel
//
//     Parameters
// ALCInd - given Log Chanel Index
// AStr   - given string Log Error message
//
// Just call N_LCAdd and clear Error flag lcsfErrInfo
//
procedure N_LCClearErr( ALCInd: integer; AStr: string );
begin
  if (ALCInd < 0) or (ALCInd > High(N_LogChannels)) then Exit;

  if AStr <> '' then
    N_LCAdd( ALCInd, AStr );

  with N_LogChannels[ALCInd] do
    LCStateFlags := LCStateFlags - [lcsfErrInfo];
end; //*** procedure N_LCClearErr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_LCError
//*************************************************************** N_LCError ***
// Check Log Chanel Error Info state
//
//     Parameters
// ALCInd - given Log Chanel Index
// Result - Returns TRUE if Log Channel has lcsfErrInfo flag
//
function N_LCError( ALCInd: integer ): boolean;
begin
  Result := True;
  if (ALCInd < 0) or (ALCInd > High(N_LogChannels)) then Exit;

  Result := lcsfErrInfo in N_LogChannels[ALCInd].LCStateFlags;
end; //*** function N_LCError

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_LCAddFinishedOKFlag
//************************************************ N_LCAddFinishedOKFlag ***
// Add to given Log Chanel "FinishedOK" Flag
//
//     Parameters
// ALCInd - given Log Chanel Index
//
procedure N_LCAddFinishedOKFlag( ALCInd: integer );
var
  FinishedOKStr: AnsiString;
begin
  if (ALCInd < 0) or (ALCInd > High(N_LogChannels)) then Exit;

  with N_LogChannels[ALCInd] do
  begin
    N_LCExecAction( ALCInd, lcaFlush );
    N_LCExecAction( ALCInd, lcaPrepFStream );

    if LCFStream <> nil then // Stream was prepared OK, write to it
    begin
      FinishedOKStr := 'Finished OK ##########'+ #13#10; // 10 final '#' chars are used as 'Finshed OK' Flag
      LCFstream.Seek( 0, soFromEnd);
      LCFStream.Write( FinishedOKStr[1], Length(FinishedOKStr) );
    end;

    N_LCExecAction( ALCInd, lcaFlush );
  end; // with N_LogChannels[ALCInd] do
end; //*** procedure N_LCAddFinishedOKFlag

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_LCCheckFinishedOKFlag
//********************************************** N_LCCheckFinishedOKFlag ***
// Check if given Log Chanel file has "FinishedOK" Flag
//
//     Parameters
// ALCInd - given Log Chanel Index
// Result - Returns TRUE if Log Channel file has "FinishedOK" Flag or is absent 
//          or is less then 10 bytes
//
function N_LCCheckFinishedOKFlag( ALCInd: integer ): boolean;
var
  WasAppendMode: Boolean;
  FromFileStr, FinishedOKStr: AnsiString;
begin
  Result := True;
  if (ALCInd < 0) or (ALCInd > High(N_LogChannels)) then Exit;

  with N_LogChannels[ALCInd] do
  begin
    WasAppendMode := lcfAppendMode in LCFlags;
    LCFlags := LCFlags + [lcfAppendMode]; // add temporary, otherwise file would be destroyed
    N_LCExecAction( ALCInd, lcaPrepFStream );

    if LCFStream <> nil then // Stream was prepared OK, check it
    begin
      N_i := LCFStream.Size;
      if LCFStream.Size <= 10 then
      begin
        N_LCExecAction( ALCInd, lcaFree ); // to be able to rename or deleete file
        Exit;
      end;

      //*** Last Symbols in file with inds from -10 to -7 should be '####'
      SetLength( FromFileStr, 4 );
      LCFstream.Seek( -12, soFromEnd);
      N_i1 := LCFStream.Read( FromFileStr[1], 4 );
      FinishedOKStr := '####';
      Result := (FinishedOKStr = FromFileStr);
    end; // if LCFStream <> nil then // Stream was prepared OK, check it

    N_LCExecAction( ALCInd, lcaFree );

    if not WasAppendMode then
      LCFlags := LCFlags - [lcfAppendMode]; // restore original state
  end; // with N_LogChannels[ALCInd] do
end; //*** function N_LCCheckFinishedOKFlag

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_LCInit1
//*************************************************************** N_LCInit1 ***
// Simple Initialization of two Log Chanels (for Dum1 and Dump2)
//
//     Parameters
// ABufSize - Buf Size in strings for both chanels
//
procedure N_LCInit1( ABufSize: integer );
var
  NumChanels: Integer;
  LogPath: String;
begin
  LogPath := ExtractFilePath( Application.ExeName ) + '\LogFiles\';
  ForceDirectories( LogPath );

  NumChanels := 2;
  SetLength( N_LogChannels, NumChanels );
  FillChar( N_LogChannels[0], NumChanels*SizeOf(TN_LogChannel), 0 );

  N_Dump1LCInd := 0; // for Dump1Str
  with N_LogChannels[N_Dump1LCInd] do
  begin
//    LCFlags    := [lcfEnable,lcfAppendMode,lcfShowCounter,lcfShowTime,lcfShowHeader];
    LCFlags    := [lcfEnable,lcfAppendMode,lcfShowCounter,lcfShowTime,lcfShowHeader];
    LCFName    := LogPath + 'Log.txt';
    LCWrapSize := 240;
  end;
  N_LCExecAction( N_Dump1LCInd, lcaSetBufSize, ABufSize );

  N_Dump2LCInd := 1; // for Dump2Str
  with N_LogChannels[N_Dump2LCInd] do
  begin
    LCFlags    := [lcfEnable,lcfShowHeader];
    LCFName    := LogPath + 'ErrLog.txt';
    LCWrapSize := 240;
  end;
  N_LCExecAction( N_Dump2LCInd, lcaSetBufSize, ABufSize );

end; // procedure N_LCInit1

//****************  End of Log procedures  ***********


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_FToDbl
//**************************************************************** N_FToDbl ***
// Convert given Float value to Double for future text formatting
//
//     Parameters
// AFloat - given Float value
// Result - Returns corresponding rounding Double value for nice formatting
//
// Resulting Double value coverted by Format( '%g', [Result] ) will always show 
// only needed number of digits.
//
function N_FToDbl( AFloat: float ): double;
var
  Coef: double;
begin
  if AFloat = 0 then
  begin
    Result := 0;
    Exit;
  end;

  Coef := Power( 10, 6 - Floor(Log10(Abs( AFloat ))) );
  Result := Round( AFloat*Coef ) / Coef;
end; // function N_FToDbl

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_StrToMSizeUnit
//******************************************************** N_StrToMSizeUnit ***
// Convert Size Units as String to TN_MSizeUnit value
//
//     Parameters
// AStr   - Size Units as String
// Result - Returns corresponding TN_MSizeUnit enumeration value
//
function N_StrToMSizeUnit( AStr: string ): TN_MSizeUnit;
begin
  AStr := UpperCase(TrimLeft( AStr ));

  if Length(AStr) = 0 then
    Result := msuLSU
  else // Length(AStr) >= 1
  begin
    if AStr[1] = 'L' then Result := msuLSU
    else if AStr[1] = 'M' then Result := msumm
    else if AStr[1] = 'U' then Result := msuUser
    else if AStr[1] = 'P' then
    begin
      if Length(AStr) =1  then Result := msuPix
      else if AStr[2] = 'I' then Result := msuPix
      else if AStr[2] = 'E' then Result := msuPrc
      else Result := msuNotGiven;
    end else
      Result := msuNotGiven;
  end;
end; // function N_StrToMSizeUnit

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_Conv1251ToUnicode
//***************************************************** N_Conv1251ToUnicode ***
// Conv to UNICODE!!! Convert given ASCII String to Unicode String
//
//     Parameters
// AStr   - given ASCII string in Win1251 Code Page
// Result - Returns coresponding Unicode WideString
//
function N_Conv1251ToUnicode( AStr: string ): WideString;
begin
  Result := AStr; // not really implemented!
end; // function N_Conv1251ToUnicode

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ConvUnicodeTo1251(2)
//************************************************** N_ConvUnicodeTo1251(2) ***
// Conv to UNICODE!!! Convert given Unicode WideString to ASCII string
//
//     Parameters
// AStr   - given Unicode WideString
// Result - Returns coresponding ASCII string in Win1251 Code Page
//
function N_ConvUnicodeTo1251( AWStr: WideString ): string;
begin
  Result := AWStr; // not really implemented!
end; // function N_ConvUnicodeTo1251

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetBracketsInfo
//******************************************************* N_GetBracketsInfo ***
// Process (#...#) brackets in given string
//
//     Parameters
// ASrcStr  - source string where to search for brackets
// AResInfo - resulting array with info about founded brackets
//
// Collects brackets position and Texts inside in rezulting AResInfo array.
//
procedure N_GetBracketsInfo ( ASrcStr: string; var AResInfo: TN_BracketsInfo );
var
  ResInd, SrcBegInd, SrcEndInd: integer;
begin
  ResInd := 0;
  SrcBegInd := 1;

  while True do // parse all Brackets
  begin
    SrcBegInd := PosEx( '(#', ASrcStr, SrcBegInd );
    if SrcBegInd = 0 then Break; // end of brackets

    SrcEndInd := PosEx( '#)', ASrcStr, SrcBegInd );

    if High(AResInfo) < ResInd then
      SetLength( AResInfo, N_NewLength(ResInd+1) );

    with AResInfo[ResInd] do
    begin
      if SrcEndInd = 0 then // closing bracket not found
        BIText := '???'
      else
        BIText := MidStr( ASrcStr, SrcBegInd+2, SrcEndInd-SrcBegInd-2 );

      BIBegInd := SrcBegInd;

      if SrcEndInd = 0 then // closing bracket not found
        BIEndInd := SrcBegInd + 1
      else
        BIEndInd := SrcEndInd + 1;


      if SrcEndInd = 0 then // closing bracket not found
        SrcBegInd := SrcBegInd + 2
      else
        SrcBegInd := SrcEndInd + 2;

      if Length(BIText) > 1 then
        if BIText[1] = '!' then Continue; // skip increasing ResInd

      Inc( ResInd );
    end; // with AResInfo[ResInd] do
  end; // while True do // parse all Brackets

  SetLength( AResInfo, ResInd );
end; // procedure N_GetBracketsInfo

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CalcNumChars
//********************************************************** N_CalcNumChars ***
// Calculate number of given Char in given String portion
//
//     Parameters
// AStr    - source string where to search given char
// ABegInd - start search position
// AEndInd - final search position
// AChar   - given character to search
//
// Start position ABegInd =0 means to start search from the string start char. 
// ABegInd should not exceed final position AEndInd. Final search position shoud
// not exceed string length - 1. Search interval ABegInd=0, AEndInd=-1 means 
// whole string search.
//
function N_CalcNumChars( AStr: String; ABegInd, AEndInd: integer; AChar: Char ): integer;
var
  i, SizeM1: integer;
begin
  Result := 0;
  SizeM1 := Length(AStr) - 1;

  ABegInd := max( 0, ABegInd ); // a precaution

  if AEndInd = -1 then AEndInd := SizeM1; // till last char

  AEndInd := min( SizeM1, AEndInd );

  if (ABegInd > SizeM1) or (ABegInd > AEndInd) then Exit;

  for i := ABegInd+1 to AEndInd+1 do
    if AStr[i] = AChar then Inc( Result );

end; // function N_ConvUnicodeTo1251

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ConvSpecCharsToHex
//**************************************************** N_ConvSpecCharsToHex ***
// Conv to UNICODE!!! Convert given large string to simplify it's analysis
//
//     Parameters
// ASrcStr  - source string
// ARowSize - resulting string maximal rows length
// AMode    - converting mode name:
//#F
// 'ANSIOnly' - Spec Chars range is $00-$1F, $80-$FF
// 'Win1251'  - Spec Chars range is $00-$1F, $80-$BF except $A8 and $B8 (Ё)
//#/F
// Result   - Returns converted string.
//
// String covertion do following: - Add Hex Codes after Spec Chars inside given 
// ASrcStr (i.e. Ё($B8) ) - add additional CRLF chars after Source CRLF chars or
// - add additional CRLF chars after given ARowSize (to avoid text files with 
// too large strings) - add decimal index (counting from 1) of first char in beg
// of each Row as Prefix
//
function N_ConvSpecCharsToHex( ASrcStr: string; ARowSize: integer; AMode: string ): string;
var
  iSrc, iFree, SrcSize, ResSize, SCSize, CurChar, CurRowSize: integer;
  IsWin1251, IsSpecChar: boolean;
  SpecCharStr, NoCRLFTag: string;

  procedure AddCharIndPrefix( AFirstCharInd: integer ); // local
  // add given decimal index (counting from 1) of first char in Row
  // and set CurRowSize := 1
  var
    PrefixSize: integer;
    CharIndPrefix: string;
  begin
    CharIndPrefix := Format( '(%.5d) ', [AFirstCharInd] );
    PrefixSize := Length(CharIndPrefix);
    move( CharIndPrefix[1], Result[iFree], PrefixSize );
    Inc( iFree, PrefixSize );

    CurRowSize := 1;
  end; // procedure AddCharIndPrefix();

begin
  Result := '';
  if ASrcStr = '' then Exit;

  IsWin1251 := (AMode = 'Win1251');
  NoCRLFTag := '(NoCRLF!)';

  SrcSize := Length(ASrcStr);
  ResSize := N_NewLength( SrcSize ) + 6;
  SetLength( Result, ResSize );

  iFree := 1;
  AddCharIndPrefix( 1 );

  for iSrc := 1 to SrcSize do // along Source String
  begin
    CurChar := integer(ASrcStr[iSrc]);

    IsSpecChar := False;
    if (CurChar < $20) or (CurChar > $7F) then IsSpecChar := True; // ANSI Only Spec Chars

    if IsWin1251 then // Win 1251 Spec Chars
    begin
      if (CurChar >= $C0) or (CurChar = $A8) or (CurChar = $B8) then
        IsSpecChar := False;
    end;

    if IsSpecChar then
    begin

      SpecCharStr := Format( '%s($%.2X)', [Char(CurChar), CurChar] );

      if CurChar = $0D then // Convert $0D without $0A to Paragraph sign (to avoid line break in viewers)
        if iSrc < SrcSize then
          if ASrcStr[iSrc+1] <> Char($0A) then
            SpecCharStr[1] := Char($86); // Paragraph sign

      SCSize := Length(SpecCharStr);

      if (iFree+SCSize-1) > ResSize then
        SetLength( Result, N_NewLength( iFree+SCSize-1 ) );

      move( SpecCharStr[1], Result[iFree], SCSize );
      Inc( iFree, SCSize );
      Inc( CurRowSize, SCSize );
    end else // not a Spec Char
    begin
      if iFree > ResSize then
        SetLength( Result, N_NewLength( iFree ) );

      Result[iFree] := Char(CurChar);
      Inc( iFree );
      Inc( CurRowSize );
    end;

    //***** Check if add additional CRLF chars should be added

    if (CurChar = $0A) and (iSrc > 1) then
    begin
      if  ASrcStr[iSrc-1] = #$0D then // CRLF chars in ASrcStr
      begin
        if (iFree+1) > ResSize then
          SetLength( Result, N_NewLength( iFree+1 ) );

        move( ASrcStr[iSrc-1], Result[iFree], 2 );
        Inc( iFree, 2 );
      end; // if  ASrcStr[iSrc-1] = #$0D then // CRLF chars in ASrcStr

      AddCharIndPrefix( iSrc+1 );
    end; // if (CurChar = $0A) and (iSrc > 1) then

    if CurRowSize >= ARowSize then // Split Resulting String
    begin
      SCSize := Length(NoCRLFTag) + 2;

      if (iFree+SCSize-1) > ResSize then
        SetLength( Result, N_NewLength( iFree+SCSize-1 ) );

      move( NoCRLFTag[1], Result[iFree], SCSize-2 );
      move( N_IntCRLF, Result[iFree+SCSize-2], 2*SizeOf(Char) );
      Inc( iFree, SCSize );

      AddCharIndPrefix( iSrc+1 );
    end; // if CurRowSize >= ARowSize then // Split Resulting String

  end; // for iSrc := 1 to SrcSize do // along Source String

  SetLength( Result, iFree-1 ); // final Size
end; // function N_ConvSpecCharsToHex

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SwapTObjects
//********************************************************** N_SwapTObjects ***
// Swap two given TObjects
//
//     Parameters
// ATObj1 - pointer to first object
// ATObj2 - pointer to second object
//
// Given objects should be of the same Type
//
procedure N_SwapTObjects( var ATObj1, ATObj2: TObject );
var
  TmpTObj: TObject;
begin
  TmpTObj := ATObj1;
  ATObj1  := ATObj2;
  ATObj2  := TmpTObj;
end; // procedure N_SwapTObjects

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_RoundVector
//*********************************************************** N_RoundVector ***
// Round given array of double so that, preserving round errors accumulation
//
//     Parameters
// APSrcVal - Pointer to first Source double Value
// ANumVals - Number of Values (both Source and Resulting)
// APResVal - Pointer to first Resulting integer Value
//
// Resulting array of corresponding integer values sum satisfies following 
// condition condition:  Round( Sum(SrcVals) ) = Sum(ResVals)
//
procedure N_RoundVector( APSrcVal: PDouble; ANumVals: integer; APResVal: PInteger );
var
  i, begi, deltai: integer;
  Frac{, Fl}: double;
  WPResVal: PInteger;

begin
  Frac := 0;
  begi := 1;
  for i := 1 to ANumVals do
  begin
{
    Fl := Floor(APSrcVal^);
    Frac := Frac + APSrcVal^ - Fl;
    APResVal^ := Round(Fl);

    if Frac > (1.0 - 1.0e-6) then // Increase some ResVal by 1
    begin
      deltai := Random( i - begi + 1 );
      Dec( APResVal, deltai ); // temporary decrease
      Inc( APResVal^ );
      Inc( APResVal, deltai ); // restore

      Frac := Frac - 1.0;
      begi := i + 1;
    end; // if Frac > (1.0 - 1.0e-6) then // Increase some ResVal by 1

}
    APResVal^ := Round(APSrcVal^);
    Frac := Frac + APSrcVal^ - APResVal^;

    if Frac > 0.6 then // Increase some ResVal by 1
    begin
      deltai := Random( i - begi + 1 );
      WPResVal := PInteger( TN_BytesPtr(APResVal) - deltai * SizeOf(Integer) );
      Inc( WPResVal^ );
      Frac := Frac - 1.0;
      begi := i + 1;
    end else
    if Frac < -0.6 then // Decrease some ResVal by 1
    begin
      deltai := Random( i - begi + 1 );
      WPResVal := PInteger( TN_BytesPtr(APResVal) - deltai * SizeOf(Integer) );
      Dec( WPResVal^ );
      Frac := Frac + 1.0;
      begi := i + 1;
    end;

    Inc( APResVal );
    Inc( APSrcVal );
  end; // for i := 1 to ANumVals do
end; // procedure N_RoundVector

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SplitIntegerValue(doubles)
//******************************************** N_SplitIntegerValue(doubles) ***
// Split given Integer Value by given Parts Array of Double
//
//     Parameters
// APSrcVal  - pointer to first Double Parts Array element
// ANumVals  - number of elments in Parts Array (both Source and Resulting)
// AIntValue - given Integer Value to Split
// APResVal  - pointer to first resulting integer part of given Value to Split
//
// APResVal should points on at least ANumVals*SizeOf(Integer) bytes free 
// memory. Resulting array of integer values satisfies the following conditions:
//#F
//1) Sum(ResVals) = AIntValue
//2) ResVals[i]/AIntValue approximatly equal to SrcVals[i]/Sum(SrcVals) for all i
//#/F
//
procedure N_SplitIntegerValue( APSrcVal: PDouble; ANumVals, AIntValue: integer; APResVal: PInteger );
var
  i: integer;
  SrcSum: double;
  PDbl, PScaled: PDouble;
  ScaledVals: TN_DArray;
begin
  SrcSum := 0;
  PDbl := APSrcVal;

  for i := 1 to ANumVals do
  begin
    SrcSum := SrcSum + PDbl^;
    Inc( PDbl );
  end;

  SetLength( ScaledVals, ANumVals );
  PScaled := @ScaledVals[0];
  PDbl    := APSrcVal;

  for i := 1 to ANumVals do
  begin
    PScaled^ := PDbl^*AIntValue / SrcSum;
    Inc( PScaled );
    Inc( PDbl );
  end;

  N_RoundVector( @ScaledVals[0], ANumVals, APResVal );
end; // procedure N_SplitIntegerValue

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SplitIntegerValue(Floats)
//********************************************* N_SplitIntegerValue(Floats) ***
// Split given Integer Value by given Parts Array of Float
//
//     Parameters
// APSrcVal  - pointer to first Float Parts Array element
// ANumVals  - number of elments in Parts Array (both Source and Resulting)
// AIntValue - given Integer Value to Split
// APResVal  - pointer to first resulting integer part of given Value to Split
//
// APResVal should points on at least ANumVals*SizeOf(Integer) bytes free 
// memory. Resulting array of integer values satisfies the following conditions:
//#F
//1) Sum(ResVals) = AIntValue
//2) ResVals[i]/AIntValue approximatly equal to SrcVals[i]/Sum(SrcVals) for all i
//#/F
//
procedure N_SplitIntegerValue( APSrcVal: PFloat; ANumVals, AIntValue: integer; APResVal: PInteger );
var
  i: integer;
  SrcSum: double;
  PFlt: PFloat;
  PScaled: PDouble;
  ScaledVals: TN_DArray;
begin
  SrcSum := 0;
  PFlt := APSrcVal;

  for i := 1 to ANumVals do
  begin
    SrcSum := SrcSum + PFlt^;
    Inc( PFlt );
  end;

  SetLength( ScaledVals, ANumVals );
  PScaled := @ScaledVals[0];
  PFlt    := APSrcVal;

  for i := 1 to ANumVals do
  begin
    PScaled^ := PFlt^*AIntValue / SrcSum;
    Inc( PScaled );
    Inc( PFlt );
  end;

  N_RoundVector( @ScaledVals[0], ANumVals, APResVal );
end; // procedure N_SplitIntegerValue

//*************************************************************** N_CalcCNK ***
// Calculate double "C is N po K": Result = AN! / ((AN-AK)!*AK!)
//
function N_CalcCNK( AN, AK: integer ): double;
var
  i: integer;
begin
  Result := 1.0;

  for i := 0 to AK-1 do
    Result := Result * (AN - i) / (i+1);

end; // function N_CalcCNK

//*********************************************************** N_CalcCNKInds ***
// Calculate AK number of indexes in AResInds array
//
// AN       - number of places
// AK       - number of places to fill (number of resulting Inds)
// ASrcNum  - whole number of needed sets of inds
// ASrcInd  - curent index of set of inds
// APResInd - Pointer to first resulting index
//
procedure N_CalcCNKInds( AN, AK, ASrcNum, ASrcInd: integer; APResInd: PInteger );
var
  i, j, CurN, CurK, CurSrcNum, CurSrcInd, CurResInd, CurNumPlaces: integer;
  SkipedNums, Savedj: integer;
  CNKSum: double;
  INums: TN_IArray;
  DNums: TN_DArray;

begin //***************************************** main body of N_CalcCNKInds
  // Check that ASrcNum, ASrcInd are correct (if not - correct them)

  CNKSum := N_CalcCNK( AN, AK );
  if ASrcNum > CNKSum then ASrcNum := Round(CNKSum);
  if ASrcInd >= ASrcNum then ASrcInd := ASrcInd mod ASrcNum;

  // Prepare DNums, INums by max needed size
  SetLength( DNums, AN ); // initial double number of inds for each place
  SetLength( INums, AN ); // final rounded integer number of inds for each place

  // Set CurXXX variables for initial pas (i=0)
  CurN      := AN;      // Current Number of Places
  CurK      := AK;      // Current (rest) Number of inds to calculate
  CurSrcNum := ASrcNum; // Current Number of needed sets of inds (for rest inds)
  CurSrcInd := ASrcInd; // Current set index (for rest inds)

  Dec( APResInd ); // APResInd will be incrementd before first use

  for i := 0 to AK-1 do // Calc Resulting Inds one by one
  begin
    //***** Calc CurResInd - i-th Resulting index

    CurNumPlaces := CurN - CurK + 1; // 0 <= CurResInd < CurNumPlaces
    CNKSum := 0;

    for j := 0 to CurNumPlaces-1 do // calc all needed CNK and theirs sum
    begin
      DNums[j] := N_CalcCNK( CurN-j-1, CurK-1 );
      CNKSum := CNKSum + DNums[j];
    end; // for j := 0 to CurNumPlaces-1 do // calc all needed CNK and theirs sum

    CNKSum := CurSrcNum / CNKSum;

    for j := 0 to CurNumPlaces-1 do // calc all DNums (number of inds for each place)
      DNums[j] := CNKSum * DNums[j];

    N_RoundVector( @DNums[0], CurNumPlaces, @INums[0] ); // Calc Inums by DNums

    SkipedNums := 0;
    CurResInd := CurNumPlaces-1; // a precaution, not really needed
    Savedj    := CurNumPlaces-1; // to avoid warning

    for j := 0 to CurNumPlaces-1 do
    begin
      if CurSrcInd < (INums[j] + SkipedNums) then
      begin
        Savedj := j;
        if i = 0 then
          CurResInd := j
        else // i >= 1
          CurResInd := APResInd^ + j + 1; // APResInd^ is (i-1)-th index
        Break;
      end else
        SkipedNums := SkipedNums + INums[j];
    end; // for j := 0 to CurNumPlaces-1 do

    Inc( APResInd ); // to next index
    APResInd^ := CurResInd; // calculated i-th Resulting index

    CurN      := AN - CurResInd - 1;
    CurK      := CurK - 1;
    CurSrcNum := INums[Savedj];
    CurSrcInd := CurSrcInd - SkipedNums;

  end; // for i := 0 to AK-1 do // Calc Res Inds one by one

end; // procedure N_CalcCNKInds

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CopyStringsByPtrs
//***************************************************** N_CopyStringsByPtrs ***
// Copy Strings
//
//     Parameters
// APSrc       - Pointer to first Source String value
// APDst       - Pointer to first Destination String value
// ASrcStep    - Source Step (in Pointers to Strings)
// ANumStrings - Number of Strings to copy
//
// Destination data shoud have needed size. Destination data step should be 
// equal to SizeOf(string).
//
procedure N_CopyStringsByPtrs( APSrc, APDst: PString; ASrcStep, ANumStrings: integer );
var
  i: integer;
begin
  for i := 0 to ANumStrings-1 do
  begin
    APDst^ := APSrc^;
    Inc( APSrc, ASrcStep );
    Inc( APDst, 1 );
  end;
end; // procedure N_CopyStringsByPtrs

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CopyDoubles
//*********************************************************** N_CopyDoubles ***
// Copy Doubles
//
//     Parameters
// APSrc       - Pointer to first Source double value
// APDst       - Pointer to first Destination double value
// ASrcStep    - Source Step (in Doubles)
// ANumDoubles - Number of doubles to copy
//
// Destination data shoud have needed size. Destination data step should be 
// equal to SizeOf(double).
//
procedure N_CopyDoubles( APSrc, APDst: PDouble; ASrcStep, ANumDoubles: integer );
var
  i: integer;
begin
  for i := 0 to ANumDoubles-1 do
  begin
    APDst^ := APSrc^;
    Inc( APSrc, ASrcStep );
    Inc( APDst, 1 );
  end;
end; // procedure N_CopyDoubles

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CopyIntegers
//********************************************************** N_CopyIntegers ***
// Copy Integers
//
//     Parameters
// APSrc        - Pointer to first Source Integer value
// APDst        - Pointer to first Destination Integer value
// ASrcStep     - Source Step (in Integers)
// ANumIntegers - Number of Integers to copy
//
// Destination data shoud have needed size. Destination data step should be 
// equal to SizeOf(integer).
//
procedure N_CopyIntegers( APSrc, APDst: PInteger; ASrcStep, ANumIntegers: integer );
var
  i: integer;
begin
  for i := 0 to ANumIntegers-1 do
  begin
    APDst^ := APSrc^;
    Inc( APSrc, ASrcStep );
    Inc( APDst, 1 );
  end;
end; // procedure N_CopyIntegers

//********************************************** N_FormatDouble ***
// convert given double Value to resulting string using given Accuracy
//
function N_FormatDouble( Accuracy, Mode: integer; Value: double ): string;
//var
//  Beta: double;
begin
  // not Yet
  Result := '';
end; // end of function N_FormatDouble

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_FileNameWithoutExt
//**************************************************** N_FileNameWithoutExt ***
// Extract file name without file extention and path
//
//     Parameters
// AFileName - source file name including path and extention
// Result    - Returns file name without extention and path
//
function N_FileNameWithoutExt( AFileName: string ): string;
begin
  Result := ExtractFileName( AFileName );
  Result := ChangeFileExt( Result, '' );
end; // end of function N_FileNameWithoutExt

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ParseFileName
//********************************************************* N_ParseFileName ***
// Split given file name to prefix, numeric part and extension
//
//     Parameters
// AFileName - source file name including path and extention
// ABegFName - resulting file name prefix (file name part just before numeric 
//             part)
// ANumFName - resulting numeric part of file name
// AEndFName - resulting file name extension ((file name part just after numeric
//             part))
// Result    - Returns numeric part of file name as integer value. If no numeric
//             part is found then -1 will be returned.
//
// Notes:
//#F
//  1) if Numeric Part exists, it should be just before extention
//  2) if Numeric Part is empty, '_' is added to ABegFName
//#/F
//
function N_ParseFileName( AFileName: string;
                        out ABegFName, ANumFName, AEndFName: string ): integer;
var
  i, LastNumInd, FirstNumInd: integer;
  label BegPart;
begin
  AEndFName := ExtractFileExt( AFileName );
  LastNumInd := Length(AFileName) - Length(AEndFName);

  if (AFileName[LastNumInd] < '0') or (AFileName[LastNumInd] > '9') then // No Num Part
  begin
    ANumFName := '';
    ABegFName := Copy( AFileName, 1, LastNumInd ) + '_';
    Result := -1;
    Exit;
  end; // No Num Part

  for i := LastNumInd downto 1 do
  begin
    if (AFileName[i] < '0') or (AFileName[i] > '9') then
    begin
      FirstNumInd := i + 1; // first character ind of Numeric part
      goto BegPart;
    end;
  end;
  FirstNumInd := 1; // all charactes are digits

  BegPart: //***** Process Beg part of AFileName

  ANumFName := Copy( AFileName, FirstNumInd, LastNumInd - FirstNumInd + 1 );
  ABegFName := Copy( AFileName, 1, Length(AFileName) -
                                   Length(AEndFName) - Length(ANumFName) );
  Result := StrToInt( ANumFName );
end; // end of function N_ParseFileName

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ChangeFileName
//******************************************************** N_ChangeFileName ***
// Change numeric part of given file name by increasing it on given value
//
//     Parameters
// AFileName - source file name
// ADelta    - change numeric file name part integer delta
// Result    - Returns modified file name.
//
// If given file name does not contain numeric part then resulting file name 
// will be equal to source file name.
//
function N_ChangeFileName( AFileName: string; ADelta: integer ): string;
var
  NewInd: integer;
  BegFName, NumFName, EndFName: string;
begin
  NewInd := N_ParseFileName( AFileName, BegFName, NumFName, EndFName ) + ADelta;

  if NewInd < 0 then // failed
    Result := AFileName
  else //************** NewInd >= 0 create needed FileName
    Result := Format( '%s%.2d%s', [BegFName, NewInd, EndFName] );
end; // end of function N_ChangeFileName

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CreateUniqueFileName
//*********************************************** N_CreateUniqueFileName ***
// Create unique file name by given prefix, number and postfix
//
//     Parameters
// APrefix  - file name prefix
// ANumber  - numeric file name part parameter:
//#F
//   on input  - initial number to try,
//   on output - final unique file name number + 1 (ready for next call)
//#/F
// APostfix - file name postfix
// Result   - Returns unique file name in form APrefix + ANumber + APostfix
//
function N_CreateUniqueFileName( APrefix: string; var ANumber: integer;
                                                     APostfix: string ): string;
begin
  while True do
  begin
    Result := APrefix + Format( '%.3d', [ANumber] ) + APostfix;
    Inc(ANumber);
    if not FileExists( Result ) then Exit;
  end; // while True do
  Assert( False, 'Cannot create unique file name!' );
end; // end of function N_CreateUniqueFileName

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CreateUniqueFileName(1)
//*********************************************** N_CreateUniqueFileName(1) ***
// Create unique file name based upon given
//
//     Parameters
// AFileName - source file name
// Result    - Returns unique file name in same directory by changing or adding 
//             numeric filename part.
//
function N_CreateUniqueFileName( FileName: string ): string;
var
  i, j, Num: integer;
  FNWithoutExt, Prefix: string;
begin
  FNWithoutExt := ChangeFileExt( FileName, '' ); // delete extension with dot
  i := Length( FNWithoutExt ); // string func
  while (Ord(FNWithoutExt[i]) >= Ord('0')) and
        (Ord(FNWithoutExt[i]) <= Ord('9')) and
        ( i >= 1 ) do Dec(i);

  j := Length( FNWithoutExt ) - i;
  if j = 0 then
    Num := 0
  else
    Num := StrToInt( Copy( FNWithoutExt, i+1, j ) );

  Prefix := Copy( FNWithoutExt, 1, i );
  Result := N_CreateUniqueFileName( Prefix, Num, ExtractFileExt( FileName ) );
end; // end of function N_CreateUniqueFileName(1)

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetMaxValue
//******************************************************** N_GetMaxValue ***
// Return Max Value in given integers
//
//     Parameters
// APFirstInt - given pointer to first integer
// ANumInts   - given number of integers to analize
// Result     - Return max integer in all analized integers
//
function N_GetMaxValue( APFirstInt: PInteger; ANumInts: integer ): integer;
var
  i: integer;
begin
  Result := N_NotAnInteger;

  if ANumInts <= 0 then Exit;

  Result := APFirstInt^;
  Inc( APFirstInt );

  for i := 0 to ANumInts-2 do // along all given Integers, beginning from second one
  begin
    Result := max( Result, APFirstInt^ );
    Inc( APFirstInt );
  end; // for i := 0 to ANumInts-2 do // along all given Integers, beginning from second one

end; // end of function N_GetMaxValue

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CalcNumDigits
//****************************************************** N_CalcNumDigits ***
// Calculate number of decimal digits needed to represent given AInt value
//
//     Parameters
// AInt   - given integer
// Result - Return number of decimal digits (+1 if given integer < 0)
//
function N_CalcNumDigits( AInt: integer ): integer;
begin
  if AInt < 0 then
    Result := Round( Ceil( Log10( -AInt + 0.1 ))) + 1
  else if AInt = 0 then
    Result := 1
  else // AInt > 0
    Result := Round( Ceil( Log10( AInt + 0.1 )));
end; // end of function N_CalcNumDigits

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CalcEqualIntervals
//**************************************************** N_CalcEqualIntervals ***
// Calculate Equal Integer Intervals, that covers given Range
//
//     Parameters
// AIntervals    - Resulting array fo Integer Points with needed intervals 
//                 (nearly Equal Integer Intervals (X,Y))
// ANumIntervals - number of needed intervals should be less or equal then 
//                 AMaxInt (ANumIntervals <= AMaxInt)
// AMaxInt       - given Range maximal value (Y value of last interval)
//
// Range minimal value is 0 (X value of first interval). All intervals has same 
// size >=1 with 1 accuracy. The following is TRUE:
//#F
//  1) AIntervals[0].X = 0
//  2) AIntervals[ANumIntervals-1].Y = AMaxInt
//  3) AIntervals[i+1].X = AIntervals[i].Y+1
//#/F
//
procedure N_CalcEqualIntervals( var AIntervals: TN_IPArray;
                                ANumIntervals, AMaxInt: integer );
var
  i: integer;
begin
  if (ANumIntervals > AMaxInt) or (ANumIntervals <= 0) then // error
  begin
    AIntervals := nil;
    Exit;
  end;

  if Length(AIntervals) < ANumIntervals then
    SetLength( AIntervals, ANumIntervals );

  AIntervals[0].X := 0;
  AIntervals[0].Y := Round(AMaxInt/ANumIntervals) - 1;

  for i := 1 to ANumIntervals-1 do
  begin
    AIntervals[i].X := AIntervals[i-1].Y + 1;
    AIntervals[i].Y := Round((i+1)*AMaxInt/ANumIntervals) - 1;
  end; // for i := 1 to ANumIntervals-1 do

end; // end procedure N_CalcEqualIntervals

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CalcNIRsBySizes
//**************************************************** N_CalcNIRsBySizes ***
// Calculate ANIRs (Neighbour Integer Ranges) by given Ranges Sizes
//
//     Parameters
// ANIRs      - Resulting calculated NIRs (Neighbour Integer Ranges) Array
// ANumRanges - Number of Ranges in ANIRs
// AMinVal    - First Range Min Value
// ASizes     - given Array of Range Sizes (with ANumRanges elements)
//
// NIRs structure description:
//#F
//   Number of elements in ANIRs Array is ANumRanges+1
//   i-th range is equal to (ANIRs[i]+1, ANIRs[i+1]), i=0,1,...,(ANumRanges-1)
//   (if ANumRanges = 1 then ANIRs[0]=MinValue-1, ANIRs[1]=MaxValue
//#/F
//
// Range Size =1 means that MinRangeValue=MaxRangeValue
//
procedure N_CalcNIRsBySizes( var ANIRs: TN_IArray; ANumRanges, AMinVal: integer; ASizes: TN_IArray );
var
  i: integer;
begin
  if ANumRanges < 1 then // error
  begin
    ANIRs := nil;
    Exit;
  end;

  if High(ANIRs) < ANumRanges then
    SetLength( ANIRs, ANumRanges+1 );

  ANIRs[0] := AMinVal - 1;

  for i := 1 to ANumRanges do
    ANIRs[i] := ANIRs[i-1] + ASizes[i-1];
end; // end procedure N_CalcNIRsBySizes

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CalcUniformNIRs
//**************************************************** N_CalcUniformNIRs ***
// Calculate Uniform Neighbour Integer Ranges (NIRs)
//
//     Parameters
// ANIRs      - Resulting calculated NIRs (Neighbour Integer Ranges) Array
// ANumRanges - Number of Ranges in ANIRs
// AMinVal    - Min Value of First Range in ANIRs
// AMaxVal    - Max Value of Last Range in ANIRs
//
// NIRs structure description:
//#F
//   Number of elements in ANIRs Array is ANumRanges+1
//   i-th range is equal to (ANIRs[i]+1, ANIRs[i+1]), i=0,1,...,(ANumRanges-1)
//   (if ANumRanges = 1 then ANIRs[0]=MinValue-1, ANIRs[1]=MaxValue
//#/F
//
procedure N_CalcUniformNIRs( var ANIRs: TN_IArray; ANumRanges, AMinVal, AMaxVal: integer );
var
  i: integer;
  Coefs: TN_DArray;
  Sizes: TN_IArray;
begin
  if ANumRanges < 1 then // error
  begin
    ANIRs := nil;
    Exit;
  end;

  SetLength( Coefs, ANumRanges );
  SetLength( Sizes, ANumRanges );

  for i := 0 to ANumRanges-1 do
    Coefs[i] := 1.0;

  N_SplitIntegerValue( PDouble(@Coefs[0]), ANumRanges, AMaxVal-AMinVal+1, @Sizes[0] );

  N_CalcNIRsBySizes( ANIRs, ANumRanges, AMinVal, Sizes );
end; // end procedure N_CalcUniformNIRs

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GroupHistData
//****************************************************** N_GroupHistData ***
// Group Hist Data by given ANIRs (Neighbour Integer Ranges)
//
//     Parameters
// AHistData  - given Histogramm data (8 or 16 bit)
// ANIRs      - given NIRs (Neighbour Integer Ranges) Array
// ANumRanges - Number of Ranges (number of elements in resulting AResData)
// AResData   - resulting Array with grouped histogramm data
//
// AResData[i] contains summ of AHistData elements with indexes in i-th range
//
procedure N_GroupHistData( AHistData: TN_IArray; ANIRs: TN_IArray;
                           ANumRanges: integer; var AResData: TN_DArray );
var
  i, j: integer;
begin
  if ANumRanges < 1 then // error
  begin
    AResData := nil;
    Exit;
  end;

  if Length(AResData) < ANumRanges then
    SetLength( AResData, ANumRanges );

  for i := 0 to ANumRanges-1 do // for all Ranges in ANIRs calc AResData elements
  begin
    AResData[i] := 0;

    for j := ANIRs[i]+1 to ANIRs[i+1] do
      AResData[i] := AResData[i] + AHistData[j];
  end; // for i := 0 to ANumRanges-1 do

end; // end procedure N_GroupHistData

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_UpdateNIRsByWCoefs
//************************************************* N_UpdateNIRsByWCoefs ***
// Update given ASrcNIRs by given Weight coefs and given new NIRs whole range
//
//     Parameters
// ASrcNIRs   - given NIRs (Neighbour Integer Ranges) Array to update
// AWCoefs    - array of Weight coefs (usually number of pixels in i-th 
//              brightness range)
// ANumRanges - number of Ranges (number of elements in AWCoefs Array and in 
//              ASrcNIRs, ADstNIRs)
// ANewMinVal - given Min Value of First Range in ADstNIRs
// ANewMaxVal - given Max Value of Last Range in ADstNIRs
// AMaxCoef   - given max Coef > 1, by which one Range can be changed (increased
//              or decreased)
//
procedure N_UpdateNIRsByWCoefs( ASrcNIRs: TN_IArray; AWCoefs: TN_DArray;
                           ANumRanges: integer; var ADstNIRs:  TN_IArray;
                           ANewMinVal, ANewMaxVal: integer; AMaxCoef: double );
var
  i, RangeWidth: integer;
  Coef, AverageHeight: double;
  Coefs, Heights: TN_DArray;
  Sizes: TN_IArray;
begin
  if ANumRanges < 1 then // error
  begin
    ADstNIRs := nil;
    Exit;
  end;

  SetLength( Coefs,   ANumRanges );
  SetLength( Heights, ANumRanges );
  SetLength( Sizes,   ANumRanges );

  AverageHeight := 0;

  for i := 0 to ANumRanges-1 do
  begin
    RangeWidth := ASrcNIRs[i+1] - ASrcNIRs[i]; // always >= 1
    Heights[i] := AWCoefs[i] / RangeWidth;
    AverageHeight := AverageHeight + Heights[i]; // AverageHeight is used for sum calculation
  end; // for i := 0 to ANumRanges-1 do

  AverageHeight := AverageHeight / ANumRanges;

  for i := 0 to ANumRanges-1 do
  begin
    Coef := Heights[i] / AverageHeight;
    if Coef > AMaxCoef then Coef := AMaxCoef
    else if Coef < (1.0/AMaxCoef) then Coef := 1.0/AMaxCoef;

    RangeWidth := ASrcNIRs[i+1] - ASrcNIRs[i];
    Coefs[i] := RangeWidth * Coef;
  end; // for i := 0 to ANumRanges-1 do

  N_SplitIntegerValue( PDouble(@Coefs[0]), ANumRanges, ANewMaxVal-ANewMinVal+1, @Sizes[0] );

  N_CalcNIRsBySizes( ADstNIRs, ANumRanges, ANewMinVal, Sizes );
end; // procedure N_UpdateNIRsByWCoefs

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SetXLATFragm
//******************************************************* N_SetXLATFragm ***
// Set One uniform Fragment (interval) of integer XLAT Table
//
//     Parameters
// APXLAT  - Pointer to first element of integer AXLAT Table
// AMinInd - Min XLAT Table index to set
// AMaxInd - Max XLAT Table index to set
// AMinVal - XLAT[AMinInd] value
// AMaxVal - XLAT[AMaxInd] value
//
procedure N_SetXLATFragm( APXLAT: PInteger; AMinInd, AMaxInd, AMinVal, AMaxVal: integer );
var
  i: integer;
  CurPInt: PInteger;
begin
  CurPInt := APXLAT;
  Inc( CurPInt, AMinInd );

  if AMinInd = AMaxInd then
  begin
    CurPInt^ := Round( 0.5*(AMinVal+AMaxVal) );
  end else
  begin
    for i := AMinInd to AMaxInd do
    begin
      CurPInt^ := AMinVal + Round( 1.0*(i-AMinInd)*(AMaxVal-AMinVal)/(AMaxInd-AMinInd) );
      Inc( CurPInt );
    end;
  end;
end; // end procedure N_SetXLATFragm

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CalcUniformXLAT
//**************************************************** N_CalcUniformXLAT ***
// Calculate Uniform XLAT Table of integers
//
//     Parameters
// AXLAT     - Calculated AXLAT Table with ANumElems (AXLAT[i]=i)
// ANumElems - Number of Elements in AXLAT
//
procedure N_CalcUniformXLAT( var AXLAT: TN_IArray; ANumElems: integer );
var
  i: integer;
begin
  if Length(AXLAT) < ANumElems then
    SetLength( AXLAT, ANumElems );

  for i := 0 to ANumElems-1 do
    AXLAT[i] := i;
end; // end procedure N_CalcUniformXLAT

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CalcXLATByTwoNIRs
//************************************************** N_CalcXLATByTwoNIRs ***
// Calculate XLAT Table of integers by two given NIRs
//
//     Parameters
// AXLAT      - Calculated AXLAT Table
// ASrcNIRs   - given Source NIRs (Neighbour Integer Ranges)
// ADstNIRs   - given Destination NIRs (Neighbour Integer Ranges)
// ANumRanges - number of Ranges in ASrcNIRs, ADstNIRs
//
procedure N_CalcXLATByTwoNIRs( AXLAT: TN_IArray;
                                  ASrcNIRs, ADstNIRs: TN_IArray; ANumRanges: integer );
var
  i, j, Deltaj: integer;
begin
  Assert( High(AXLAT) >= ASrcNIRs[ANumRanges], 'Bad XLAT (2NIRS)' );

  for i := 0 to ANumRanges-1 do // for all Ranges in ANIRs calc AResData elements
  begin
    Deltaj := ASrcNIRs[i+1] - ASrcNIRs[i] - 1;

    if Deltaj = 0 then
      AXLAT[ASrcNIRs[i]+1] := Round( 0.5*( ADstNIRs[i]+1+ADstNIRs[i+1] ) )
    else
      for j := 0 to Deltaj do
        AXLAT[ASrcNIRs[i]+1+j] := ADstNIRs[i] + 1 +
                                  Round( (1.0*ADstNIRs[i+1]-ADstNIRs[i]-1)*j/Deltaj );
  end; // for i := 0 to ANumRanges-1 do
end; // end procedure N_CalcXLATByTwoNIRs

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ConvGrayToRGB8XLat
//************************************************* N_ConvGrayToRGB8XLat ***
// Convert given Gray XLat to ARGB8 XLat
//
// AXLat    - given XLat (Gray on input, RGB8 on output) ANumBits - number of 
// bits in Input XLAT elements
//
procedure N_ConvGrayToRGB8XLat( AXLat: TN_IArray; ANumBits: integer );
var
  i: integer;
begin
  for i := 0 to High(AXLat) do
    AXLat[i] := N_GrayToRGB8( AXLat[i], ANumBits );
end; //*** procedure N_ConvGrayToRGB8XLat

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CombineXLatTables
//************************************************** N_CombineXLatTables ***
// Combine two given XLat Tables
//
// AXLat1 - on input given first XLat, on output - resulting (combined) XLat 
// AXLat2 - given second XLat table
//
// Converting any value by first AXLat1 and then by AXLat2 gives the same result
// as converting once by resulting combined XLat. AXLat1[i] := 
// AXLat2[AXLat1[i]];
//
procedure N_CombineXLatTables( AXLat1, AXLat2: TN_IArray );
var
  i, TmpVal: integer;
begin
  for i := 0 to High(AXLat1) do
  begin
    TmpVal := AXLat1[i];
    if (TmpVal >= 0) and (TmpVal <=High(AXLat2)) then
      AXLat1[i] := AXLat2[TmpVal];
  end; // for i := 0 to High(AXLat1) do
end; //*** procedure N_CombineXLatTables

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CreateXLatTableBy2P(int)
//********************************************** N_CreateXLatTableBy2P(int) ***
// Create piecewise lineal (max 3 segments) byte XLat AResTable by two given 
// points AP1, AP2 (0 <= AP1.X,AP1.Y,AP2.X,AP2.Y <= 255, AP1.X < AP2.X)
//
// AResTable - resulting XLat Table for byte values convertion AP1       - Left 
// Point  ( 0 <= AP1.X < AP2.X <= 255 ) AP2       - Right Point ( 0 <= AP1.X < 
// AP2.X <= 255 )
//
procedure N_CreateXLatTableBy2P( var AResTable: TN_BArray; AP1, AP2: TPoint );
var
  ix: integer;
begin
  if Length(AResTable) < 256 then SetLength( AResTable, 256 );

 if AP1.Y <= AP2.Y then // increasing lineal XLat Table values
 begin
   for ix := 0 to 255 do
   begin
     if ix < AP1.X then
       AResTable[ix] := Round( AP1.Y*ix/(AP1.X) )
     else if ix > AP2.X then
       AResTable[ix] := Round( AP2.Y + (255-AP2.Y)*(ix-AP2.X)/(255-AP2.X) )
     else // AP1.X <= ix <= AP2.X and AP1.X < AP2.X
       AResTable[ix] := Round( AP1.Y + (AP2.Y-AP1.Y)*(ix-AP1.X)/(AP2.X-AP1.X) );
   end; // for i := 0 to 255 do
 end else // AP1.Y > AP2.Y - decreasing lineal XLat Table values
 begin
   for ix := 0 to 255 do
   begin
     if ix < AP1.X then
       AResTable[ix] := 255 - Round( (255-AP1.Y)*ix/(AP1.X) )
     else if ix > AP2.X then
       AResTable[ix] := Round( AP2.Y - AP2.Y*(ix-AP2.X)/(255-AP2.X) )
     else // AP1.X <= ix <= AP2.X and AP1.X < AP2.X
       AResTable[ix] := Round( AP1.Y - (AP1.Y-AP2.Y)*(ix-AP1.X)/(AP2.X-AP1.X) );
   end; // for i := 0 to 255 do
 end;
end; //*** procedure N_CreateXLatTableBy2P(int)

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CreateXLatTableBy2P(float)
//******************************************** N_CreateXLatTableBy2P(float) ***
// Create piecewise lineal (max 3 segments) byte XLat AResTable by two given 
// points AP1, AP2 (0 <= AP1.X,AP1.Y,AP2.X,AP2.Y <= 1, AP1.X < AP2.X) using 
// above procedure with integer params
//
// AResTable - resulting XLat Table for byte values convertion AP1       - Left 
// Point  ( 0 <= AP1.X < AP2.X <= 1 ) AP2       - Right Point ( 0 <= AP1.X < 
// AP2.X <= 1 )
//
procedure N_CreateXLatTableBy2P( var AResTable: TN_BArray; AP1, AP2: TFPoint );
var
  IntP1, IntP2: TPoint;
begin
  IntP1 := Point( Round(255*AP1.X), Round(255*AP1.Y) );
  IntP2 := Point( Round(255*AP2.X), Round(255*AP2.Y) );

  if IntP1.X = IntP2.X then // Corret it, should be IntP1.X < IntP2.X
  begin
    if IntP2.X = 255 then IntP1.X := 254
                     else IntP2.X := IntP1.X + 1;
  end; // if IntP1.X = IntP2.X then // Corret it, should be IntP1.X < IntP2.X

  N_CreateXLatTableBy2P( AResTable, IntP1, IntP2 );
end; //*** procedure N_CreateXLatTableBy2P(float)

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CreateXLatTableByGamma
//********************************************* N_CreateXLatTableByGamma ***
// Create byte XLat AResTable for Gamma Correction
//
procedure N_CreateXLatTableByGamma( var AResTable: TN_BArray; AGamma: double );
var
  ind: integer;
begin
  if Length(AResTable) < 256 then SetLength( AResTable, 256 );

  for ind := 0 to 255 do
  begin
    AResTable[ind] := Round( 255*Power( ind/255.0, AGamma ) );
  end; // for ind := 0 to 255 do

end; //*** procedure N_CreateXLatTableByGamma

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ConvRGBValues
//****************************************************** N_ConvRGBValues ***
// Convert given ARGBValues by three given XLat Tables
//
// ASrcRGBValues - given byte Array with B,G,R,B,G,R, ... Values to convert 
// ADstRGBValues - resulting byte Array with B,G,R,B,G,R, ... converted Values 
// ANumTriples   - Number of triples to convert ARValues      - given XLat table
// to convert Red   Values AGValues      - given XLat table to convert Green 
// Values ABValues      - given XLat table to convert Blue  Values
//
procedure N_ConvRGBValues( ASrcRGBValues: TN_BArray;
                           var ADstRGBValues: TN_BArray; ANumTriples: integer;
                           ARValues, AGValues, ABValues: TN_BArray );
var
  i, NumBytes: integer;
begin
  NumBytes := ANumTriples * 3;
  if Length(ADstRGBValues) < NumBytes then
    SetLength( ADstRGBValues, NumBytes );

  for i := 0 to ANumTriples-1 do // along RGB Triples
  begin
    ADstRGBValues[i]   := ABValues[ASrcRGBValues[i]];
    ADstRGBValues[i+1] := AGValues[ASrcRGBValues[i+1]];
    ADstRGBValues[i+2] := ARValues[ASrcRGBValues[i+2]];
  end; // for i := 0 to ANumTriples-1 do // along RGB Triples
end; //*** end of function N_ConvRGBValues

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_IntToStr
//*********************************************************** N_IntToStr ***
// Represent given Integer Value as string
//
//     Parameters
// AInt      - given Integer Value
// AFmtFlags - Format flags bit0    - =0 - hex format, =1 - decimal format 
//             bits4-7 - =1 - 1 byte  AInt (one value), 2 char =2 - 2 bytes AInt
//             (one value) =3 - 3 bytes AInt (one value) =4 - 4 bytes AInt (one 
//             value) =5 - 3 bytes AInt RGB8 (three values) =6 - 6 bytes AInt^ 
//             RGB16 (three values), AInt is POINTER ! =7 - 4 bytes AInt ARGB8 
//             (four values)
//
// Is used for dumping Pixel values, XLAT tables, any other integer arrays
//
function N_IntToStr( AInt, AFmtFlags: integer ): String;
var
  Fmt2, r, g, b: integer;
  PCurWord: TN_PUInt2;
begin
  Fmt2 := AFmtFlags shr 4; // second AFmtFlags hex digit

  if (AFmtFlags and $01) = 0 then // hex format
  begin
    case Fmt2 of
    1: Result := Format( '%.2X', [AInt and $0000FF] ); // one byte (Gray8)
    2: Result := Format( '%.4X', [AInt and $00FFFF] ); // two bytes (Gray16)
    3: Result := Format( '%.6X', [AInt and $FFFFFF] ); // three bytes RGB8 as one integer
    4: Result := Format( '%.8X', [AInt] ); // integer (four bytes RGB8 as one integer)
    5: Result := Format( '%.2X %.2X %.2X', [(AInt shr 16) and $FF, (AInt shr 8) and $FF, AInt and $FF] ); // three bytes RGB8 as three values
    6: begin // six bytes RGB16 (three values), AInt is POINTER !
         PCurWord := TN_PUInt2(AInt);
         r := PCurWord^; Inc( PCurWord );
         g := PCurWord^; Inc( PCurWord );
         b := PCurWord^;
         Result := Format( '%.4X %.4X %.4X', [r, g, b] );
       end; // 6: begin // six bytes RGB16 (three values), AInt is POINTER !
    7: Result := Format( '%.2X %.2X %.2X %.2X', [(AInt shr 24) and $FF, (AInt shr 16) and $FF, (AInt shr 8) and $FF, AInt and $FF] ); // four bytes ARGB8 as four values
    end; // case Fmt2 of
  end else // (AFmtFlags and $01) <> 0 - decimal format
  begin
    case Fmt2 of
    1: Result := Format( '%.3d',  [AInt and $0000FF] ); // one byte (Gray8)
    2: Result := Format( '%.5d',  [AInt and $00FFFF] ); // two bytes (Gray16)
    3: Result := Format( '%.7d',  [AInt and $FFFFFF] ); // three bytes RGB8 as one integer
    4: Result := Format( '%.10d', [AInt] ); // integer (four bytes RGB8 as one integer)
    5: Result := Format( '%.3d %.3d %.3d', [(AInt shr 16) and $FF, (AInt shr 8) and $FF, AInt and $FF] ); // three bytes RGB8 as three values
    6: begin // six bytes RGB16 (three values), AInt is POINTER !
         PCurWord := TN_PUInt2(AInt);
         r := PCurWord^; Inc( PCurWord );
         g := PCurWord^; Inc( PCurWord );
         b := PCurWord^;
         Result := Format( '%.5d %.5d %.5d', [r, g, b] );
       end; // 6: begin // six bytes RGB16 (three values), AInt is POINTER !
    7: Result := Format( '%.3d %.3d %.3d %.3d', [(AInt shr 24) and $FF, (AInt shr 16) and $FF, (AInt shr 8) and $FF, AInt and $FF] ); // four bytes ARGB8 as four values
    end; // case Fmt2 of
  end;
end; // function N_IntToStr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_DumpIntegers
//********************************************************** N_DumpIntegers ***
// Dump given integers to given AStrings using N_IntToStr
//
//     Parameters
// APFirstInt - Pointer to first Integer
// ANumInts   - XLAT Length
// AFmtFlags  - Format flags (see N_IntToStr) bit0    - =0 - hex format, =1 - 
//              decimal format bits4-7 - =1 - 1 byte  AInt (one value), 2 char 
//              =2 - 2 bytes AInt (one value) =3 - 3 bytes AInt (one value) =4 -
//              4 bytes AInt (one value) =5 - 3 bytes AInt RGB8 (three values) 
//              =6 - 6 bytes AInt^ RGB16 (three values), AInt is POINTER ! =7 - 
//              4 bytes AInt ARGB8 (four values)
// AStrings   - given TStrings where to Dump integers
//
// Is used for dumping Pixel values, XLAT tables, any other integer arrays
//
procedure N_DumpIntegers( APFirstInt: PInteger; ANumInts, AFmtFlags: integer; AStrings: TStrings );
var
  ix, iy, ind, NumRows, CurVal: integer;
  CurStr: string;
begin
  AStrings.Add( '************ ' + IntToStr(ANumInts) + ' Integer values:' );
  NumRows := (ANumInts+7) div 8; // 8 is number of Columns

  for iy := 0 to NumRows-1 do // along all Rows
  begin
    CurStr := '';

    for ix := 0 to 7 do
    begin
      ind := ix*NumRows + iy;
      if ind < ANumInts then
      begin
        CurVal := PInteger(TN_BytesPtr(APFirstInt) + ind*4)^;
        CurStr := CurStr + Format( '%.5d ', [ind] ) + N_IntToStr( CurVal, AFmtFlags ) + '  ';
      end;
    end;

    AStrings.Add( CurStr );
  end; // for iy := 0 to NumRows do // along all Rows

  AStrings.Add( '************ end of Integer values' );
  AStrings.Add( '' );
end; // procedure N_DumpIntegers

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_DumpIntegers(1)
//******************************************************* N_DumpIntegers(1) ***
// Dump given integers to given text file using N_IntToStr
//
//     Parameters
// APFirstInt - Pointer to first XLAT element
// ANumInts   - XLAT Length
// AFmtFlags  - Format flags (see N_IntToStr) bit0    - =0 - hex format, =1 - 
//              decimal format bits4-7 - =1 - 1 byte  AInt (one value), 2 char 
//              =2 - 2 bytes AInt (one value) =3 - 3 bytes AInt (one value) =4 -
//              4 bytes AInt (one value) =5 - 3 bytes AInt RGB8 (three values) 
//              =6 - 6 bytes AInt^ RGB16 (three values), AInt is POINTER ! =7 - 
//              4 bytes AInt ARGB8 (four values)
// AFName     - given text file name  where to Dump XLAT
//
// Is used for dumping Pixel values, XLAT tables, any other integer arrays
//
procedure N_DumpIntegers( APFirstInt: PInteger; ANumInts, AFmtFlags: integer; AFName: String );
begin
  N_SL.Clear;
  N_DumpIntegers( APFirstInt, ANumInts, AFmtFlags, N_SL );
  N_SL.SaveToFile( AFName );
end; // procedure N_DumpIntegers

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_PackSDoublesToInt
//***************************************************** N_PackSDoublesToInt ***
// Pack given vector of doubles to integers with given accuracy
//
//     Parameters
// AAccuracy  - convertion accuracy - number of meaningfull decimal digits after
//              decimal point (negative accuracy means number of digits before 
//              decimal point)
// ACount     - number of vector elements
// ABStep     - step in bytes between neighbour double vector elements
// APtrInt    - pointer to resulting integers vector
// APtrDouble - pointer to source doules vector
//
// Use N_UnpackSDoublesFromInt procedure for unpacking. Resulting vector of 
// integers should be of needed size. Resulting data step should be equal to 
// SizeOf(integer).
//#F
// For example: if accuracy =  2 then  0.123 -> 12,  0.678 -> 68
//              if accuracy =  0 then  12.34 -> 12,   67.8 -> 68
//              if accuracy = -2 then  1234  -> 12,   6780 -> 68
//#/F
//
procedure N_PackSDoublesToInt( const AAccuracy, ACount, ABStep: integer;
                                              const APtrInt, APtrDouble: Pointer );
var
  i: integer;
  Coef: double;
  pi: PInteger;
  pd: PDouble;
begin
  Coef := IntPower( 10.0, AAccuracy );
  pi := APtrInt;
  pd := APtrDouble;
  for i := 0 to ACount-1 do
  begin
    pi^ := Round( pd^ * Coef ); Inc(pi);
    pd := PDouble(integer(pd) + ABStep);
  end;
end; //*** end of procedure N_PackSDoublesToInt

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_UnpackSDoublesFromInt
//************************************************* N_UnpackSDoublesFromInt ***
// Unpack vector of doubles with given accuracy from given integers
//
//     Parameters
// AAccuracy  - convertion accuracy - number of meaningfull decimal digits after
//              decimal point (negative accuracy means number of digits before 
//              decimal point)
// ACount     - number of vector elements
// ABStep     - step in bytes between neighbour double vector elements
// APtrInt    - pointer to source integers vector
// APtrDouble - pointer to resulting doules vector
//
// Source integres data vector should be produced by N_PackSDoublesToInt 
// procedure. Resulting vector of doubles should be of needed size. Source 
// integers data step should be equal to SizeOf(integer).
//#F
// For example: if accuracy =  2 then   0.120  <- 12,   0.680 <- 68
//              if accuracy =  0 then   12.00  <- 12,    68.0 <- 68
//              if accuracy = -2 then  1200.0  <- 12,  6800.0 <- 68
//#/F
//
procedure N_UnpackSDoublesFromInt( const AAccuracy, ACount, ABStep: integer;
                                             const APtrInt, APtrDouble: Pointer );
var
  i: integer;
  Coef: double;
  pi: PInteger;
  pd: PDouble;
begin
  Coef := IntPower( 10.0, -AAccuracy );
  pi := APtrInt;
  pd := APtrDouble;
  for i := 0 to ACount-1 do
  begin
    pd^ := pi^ * Coef; Inc(pi);
    pd := PDouble(integer(pd) + ABStep);
  end;
end; //*** end of procedure N_UnpackSDoublesFromInt

//************************************************ N_DTString ***
// converts (double) time interval in days to text strings in seconds
//
function N_DTString( DT: double  ): string;
begin
  Result := Format( '%3.2f', [DT*N_SecondsInDay] );
end; //*** end of function N_DTString

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ShiftCursor
//*********************************************************** N_ShiftCursor ***
// Shift Application Cursor against it's current position
//
//     Parameters
// ADX - horizontal shift in pixels
// ADY - vertical shift in pixels
//
procedure N_ShiftCursor( ADX, ADY: integer );
var
  NC: TPoint;
begin
  NC.X := Mouse.CursorPos.X + ADX;
  NC.Y := Mouse.CursorPos.Y + ADY;
  Mouse.CursorPos := NC; // only both Point coords could be set
end; // end of procedure N_ShiftCursor


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetComboBoxIndex
//****************************************************** N_GetComboBoxIndex ***
// Search current item index in given ComboBox
//
//     Parameters
// AComboBox - given ComboBox Delphi Control
// Result    - Returns Index of the Item with same string value as ComboBox.Text
//             field or -1 if no such an Item is found.
//
function N_GetComboBoxIndex( AComboBox: TComboBox ): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to AComboBox.Items.Count-1 do
  begin
    if AComboBox.Items[i] = AComboBox.Text then
    begin
      Result := i;
      Exit;
    end;
  end;
end; //*** end of procedure N_GetComboBoxIndex

//************************************************ N_Warn1 ***
// warn user by given action
//
procedure N_Warn1( WarnAction: integer );
begin
  Beep;
end; // end of procedure N_Warn1

//************************************************ N_TM ***
// warn user by showing message
// same as N_WarnByMessage, but with shorter name
//
procedure N_TM( TestMessage: string );
begin
  Beep;
  ShowMessage( 'Test Message:  ' + TestMessage );
end; // end of procedure N_TM

//**************************************************************** N_Error1 ***
// Fatal error action: show message and terminate application
//
procedure N_Error1( ErrorMessage: string );
begin
  Beep;
  ShowMessage( 'Fatal Error!   ' + ErrorMessage );
  Application.Terminate;
end; // end of procedure N_Error1

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ScanInteger
//*********************************************************** N_ScanInteger ***
// Scan one integer value from given string
//
//     Parameters
// AStr   - on input - source string with integer, on output - rest of the input
//          string without scaned integer
// Result - Return scaned integer value or -1234567890 if no integer value was 
//          found.
//
// Trim left spaces.
//
function N_ScanInteger( var AStr: string ): integer;
var
  SpacePos: integer;
  Code: integer;
begin
  Result := N_NotAnInteger;
  AStr := TrimLeft( AStr );
  if AStr = '' then Exit;
  Code := integer(Char(AStr[1]));
  if Code > $39 then Exit;
  if Code < $30 then
    if (Code <> $24) and (Code <> $2b) and (Code <> $2d) then Exit;

  SpacePos := Pos( ' ', AStr );
  if SpacePos = 0 then
  begin
    Result := StrToInt( AStr );
    AStr := '';
  end else
  begin
    Result := StrToInt( Copy( AStr, 1, SpacePos-1 ) );
    AStr := Copy( AStr, SpacePos+1, Length(AStr) );
  end;
end; // end of function N_ScanInteger

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ScanFloat
//************************************************************* N_ScanFloat ***
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
function N_ScanFloat( var AStr: string ): Float;
var
  SpacePos, RetCode: integer;
begin
  Result := N_NotAFloat;
  if AStr = '' then Exit;
  if AStr[1] = ' ' then
  begin
    AStr := TrimLeft( AStr );
    if AStr = '' then Exit;
  end;

  SpacePos := Pos( ',', AStr );
  if SpacePos > 0 then AStr[SpacePos] := '.';

  SpacePos := Pos( ' ', AStr );
  if SpacePos = 0 then
  begin
    Val( AStr, Result, RetCode );
    AStr := '';
  end else
  begin
    Val( Copy( AStr, 1, SpacePos-1 ), Result, RetCode );
    AStr := Copy( AStr, SpacePos+1, Length(AStr) );
  end;
end; // end of function N_ScanFloat

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ScanDouble
//************************************************************ N_ScanDouble ***
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
function N_ScanDouble( var AStr: string ): double;
var
  SpacePos, RetCode: integer;
begin
  Result := N_NotADouble;
  if AStr = '' then Exit;
  if AStr[1] = ' ' then
  begin
    AStr := TrimLeft( AStr );
    if AStr = '' then Exit;
  end;

  SpacePos := Pos( ',', AStr );
  if SpacePos > 0 then AStr[SpacePos] := '.';

  SpacePos := Pos( ' ', AStr );
  if SpacePos = 0 then
  begin
    Val( AStr, Result, RetCode );
    AStr := '';
  end else
  begin
    Val( Copy( AStr, 1, SpacePos-1 ), Result, RetCode );
    AStr := Copy( AStr, SpacePos+1, Length(AStr) );
  end;
end; // end of function N_ScanDouble

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ScanToken
//************************************************************* N_ScanToken ***
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
function N_ScanToken( var AStr: string ): string;
var
  DelimPos: integer;
begin
  AStr := Trim( AStr );
  if AStr = '' then
  begin
    Result := '';
    Exit;
  end;

  if AStr[1] = '"' then // quoted string
  begin
    AStr := Copy( AStr, 2, Length(AStr) );
    DelimPos := Pos( '"', AStr );
  end else // space delimited string
    DelimPos := Pos( ' ', AStr );

  if DelimPos = 0 then // no final delimiter
  begin
    Result := AStr;
    AStr := '';
  end else
  begin
    Result := Copy( AStr, 1, DelimPos-1 );
    AStr := Copy( AStr, DelimPos+1, Length(AStr) );
  end;
end; // end of function N_ScanToken

//********************************************************* N_ScanLastToken ***
// Return Last Token of given string
//
function N_ScanLastToken( var AStr: string ): string;
begin
  Result := AStr; // not yet
  Assert( False, 'Not yet!' );
end; // end of function N_ScanLastToken

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ScanIntegers
//******************************************************* N_ScanIntegers ***
// Scan any number of integer values from given string AStr
//
//     Parameters
// AStr - given string to parse
// AA   - Open Parameters List (Pointers to resulting Integer)
//
procedure N_ScanIntegers( var AStr: string; AA: Array of PInteger );
var
  i: integer;
begin
  for i := 0 to High(AA) do // along all given params
  begin
    AA[i]^ := N_ScanInteger( AStr );
  end; // for i := 0 to High(AA) do // along all given params
end; // end of procedure N_ScanIntegers

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ScanDoubles
//******************************************************** N_ScanDoubles ***
// Scan any number of Double values from given string AStr
//
//     Parameters
// AStr - given string to parse
// AA   - Open Parameters List (Pointers to resulting Doubles)
//
procedure N_ScanDoubles( var AStr: string; AA: Array of PDouble );
var
  i: integer;
begin
  for i := 0 to High(AA) do // along all given params
  begin
    AA[i]^ := N_ScanDouble( AStr );
  end; // for i := 0 to High(AA) do // along all given params
end; // end of procedure N_ScanDoubles

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ScanIArray
//************************************************************ N_ScanIArray ***
// Scan array of integers from given string
//
//     Parameters
// AStr    - on input - source string with integers, on output - rest of the 
//           input string without scaned integers
// AIArray - resulting array with scaned integers
// Result  - Return number of scanned integers
//
// Trim left spaces.
//
function N_ScanIArray( var AStr: string; var AIArray: TN_IArray ): integer;
var
  j, i1, i2, Ind, NeededLength: integer;
  t1: string;
begin
  i1 := N_ScanInteger( AStr );
  Ind := 0;

  while i1 <> N_NotAnInteger do
  begin
    t1 := N_ScanToken( AStr );
    if t1 = ',' then Continue; // skip comma delimiter

    if t1 = '-' then //*** add interval
    begin
      i2 := N_ScanInteger( AStr );
      NeededLength := Ind + i2 - i1 + 1;
      if Length(AIArray) < NeededLength then
        SetLength( AIArray, N_NewLength( Length(AIArray), NeededLength ));
      for j := i1 to i2 do
      begin
        AIArray[Ind] := j;
        Inc(Ind);
      end;
      i1 := N_ScanInteger( AStr );
    end else //*********** add one integer
    begin
      NeededLength := Ind + 1;
      if Length(AIArray) < NeededLength then
        SetLength( AIArray, N_NewLength( Length(AIArray), NeededLength ));
      AIArray[Ind] := i1;
      Inc(Ind);
      i1 := N_ScanInteger( t1 );
    end
  end; // while i1 <> N_NotAnInteger do

  Result := Ind;
end; // end of function N_ScanIArray

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ScanFArray
//************************************************************ N_ScanFArray ***
// Scan array of floats from given string
//
//     Parameters
// AStr    - on input - source string with floats, on output - rest of the input
//           string without scaned floats
// AFArray - resulting array with scaned floats
// Result  - Return number of scaned floats
//
// Trim left spaces.
//
function N_ScanFArray( var AStr: string; var AFArray: TN_FArray ): integer;
var
  Ind: integer;
  NextVal: float;
begin
  NextVal := N_ScanFloat( AStr );
  Ind := 0;

  while NextVal <> N_NotAFloat do
  begin
    if Length(AFArray) < Ind+1 then
      SetLength( AFArray, N_NewLength( Length(AFArray), Ind+1 ));

    AFArray[Ind] := NextVal;
    Inc( Ind );
    NextVal := N_ScanFloat( AStr );
  end; // while NextVal <> N_NotAFloat do

  Result := Ind;
end; // end of function N_ScanFArray

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ScanDArray
//********************************************************* N_ScanDArray ***
// Scan array of doubles from given string
//
//     Parameters
// AStr    - on input - source string with doubles, on output - rest of the 
//           input string without scaned doubles
// AFArray - resulting array with scaned doubles
// Result  - Return number of scaned doubles
//
// Trim left spaces.
//
function N_ScanDArray( var AStr: string; var ADArray: TN_DArray ): integer;
var
  Ind: integer;
  NextVal: Double;
begin
  NextVal := N_ScanDouble( AStr );
  Ind := 0;

  while NextVal <> N_NotADouble do
  begin
    if Length(ADArray) < Ind+1 then
      SetLength( ADArray, N_NewLength( Length(ADArray), Ind+1 ));

    ADArray[Ind] := NextVal;
    Inc( Ind );
    NextVal := N_ScanDouble( AStr );
  end; // while NextVal <> N_NotADouble do

  Result := Ind;
end; // end of function N_ScanDArray

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ScanSArray
//************************************************************ N_ScanSArray ***
// Scan array of strings from given string
//
//     Parameters
// AStr    - on input - source string with tokens, on output - rest of the input
//           string without scaned tokens
// ASArray - resulting array with scaned tokens
// Result  - Return number of scaned tokens
//
// Trim left spaces. Tokens should be separated with space chars or double quote
// chars.
//
function N_ScanSArray( var AStr: string; var ASArray: TN_SArray ): integer;
var
  Token: string;
begin
  Result := 0; // Result is used as first free index in ASArray

  while True do
  begin
    Token := N_ScanToken( AStr );

    if AStr <> '' then // Token <> '' and where are some more tokens
    begin
      if Length(ASArray) <= Result then
        SetLength( ASArray, N_NewLength( Result+1 ) );

      ASArray[Result] := Token;
      Inc( Result );
      Continue;
    end; // if AStr <> '' then // Token is OK and where are some more tokens

    Break;
  end; // while True do

  //*** Here: no more tokens left in AStr

  if Token <> '' then // add last Token
  begin
    if Length(ASArray) <= Result then
      SetLength( ASArray, N_NewLength( Result+1 ) );

    ASArray[Result] := Token;
    Inc( Result );
  end; // if Token <> '' then // add last Token

end; // end of function N_ScanSArray

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ScanColor
//************************************************************* N_ScanColor ***
// Scan color value from given string
//
//     Parameters
// AStr   - on input - source string with color, on output - rest of the input 
//          string without scaned color
// Result - Return scaned color integer value or -1234567890 if no color value 
//          was found.
//
// Trim left spaces. Possible color value examples:
//#F
//  "#FFAAAA", #FFAAAA, $AAAAFF, none, "none", -1
//#/F
//
function N_ScanColor( var AStr: string ): integer;
var
  Ind: integer;
  QuoteExists: boolean;
begin
  Result := N_NotAnInteger;
  AStr := TrimLeft( AStr );
  if AStr = '' then Exit;

  QuoteExists := False;
  Ind := 1;

  if AStr[1] = '"' then
  begin
    QuoteExists := True;
    Ind := 2;
  end;

  if AStr[Ind] = '#' then // HTML color (Red, Green, Blue)
  begin
    Result := StrToInt( '$' + Copy( AStr, Ind+1, 6 ) );
    Result := N_SwapRedBlueBytes( Result );
    Inc( Ind, 7 );
  end else if AStr[Ind] = '$' then // Delphi color (Blue, Green, Red)
  begin
    Result := StrToInt( Copy( AStr, Ind, 7 ) );
    Inc( Ind, 7 );
  end else // some form of Empty color or error
  begin
    if '-1' = Copy( AStr, Ind, 2 ) then
    begin
      Result := -1;
      Inc( Ind, 2 );
    end else if 'none' = Copy( AStr, Ind, 4 ) then
    begin
      Result := -1;
      Inc( Ind, 4 );
    end;
  end;

  //***** Here:  Result is OK, prepare Rest of AStr

  if QuoteExists then
    Inc(Ind);

  AStr := Copy( AStr, Ind, Length(AStr) );
end; // end of function N_ScanColor

//************************************************** N_QS ***
// return quoted ("..." ) input string with terminating space if it
// has spaces or just add terminating space
//
// Quotes in quoted string are not implemented yet!
//
function N_QS( const AStr: string ): string;
var
  SpacePos: integer;
begin
  if AStr = '' then
    Result := '"" '  // return empty string + terminating Space
  else
  begin
    SpacePos := Pos( ' ', AStr );
    if SpacePos = 0 then // no spaces in input string
      Result := AStr + ' '          // return original input string + Space
    else
    begin
        // implement later Quotes in quoted string !!
      Result := '"' + AStr + '" ';  // return quoted input string + Space
    end;
  end;
end; // end of function N_QS

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_QuoteStr
//************************************************************** N_QuoteStr ***
// Quote given string
//
//     Parameters
// AStr   - source string to quote
// AQuote - quote char
// Result - Returns quoted string (<AQuote>AStr<AQuote>).
//
// Quote chars inside source string are doubled.
//
function N_QuoteStr( const AStr: string; AQuote: char ): string;
var
  i, SLeng, ResLeng: integer;
  CurChar: Char;
  Pi, Pj: PChar;
begin
  SLeng := Length(AStr);
  ResLeng := SLeng + 2;
  Setlength( Result, SLeng + SLeng + 2 ); // max possible Length
  Result[1] := AQuote;
  Pi := @Astr[1];
  Pj := @Result[2];

  for i := 1 to SLeng do
  begin
    CurChar := Pi^;
    Pj^ := CurChar;
    Inc(Pi);
    Inc(Pj);

    if CurChar = AQuote then
    begin
      Pj^ := AQuote;
      Inc(Pj);
      Inc(ResLeng);
    end;

  end; // for i := 1 to SLeng do

  Pj^ := AQuote;
  Setlength( Result, ResLeng );
end; // end of function N_QuoteStr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_Remove0DChars
//********************************************************* N_Remove0DChars ***
// Remove $0D characters from given string
//
//     Parameters
// AStr   - source string
// Result - Returns string without $0D characters.
//
function N_Remove0DChars( const AStr: string ): string;
var
  i, j, SLeng: integer;
  CurChar: Char;
begin
  SLeng := Length(AStr);
  Setlength( Result, SLeng ); // max possible Length
  j := 1;

  for i := 1 to SLeng do
  begin
    CurChar := AStr[i];
    if Ord(CurChar) = $0D then Continue; // skip $0D character

    Result[j] := CurChar;
    Inc(j);
  end; // for i := 1 to SLeng do

  Setlength( Result, j-1 );
end; // end of function N_Remove0DChars

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SwapRedBlueBytes
//****************************************************** N_SwapRedBlueBytes ***
// Swap Red and Blue bytes in given color data
//
//     Parameters
// ASrcColor - source color
// Result    - Returns color with swaped Red and Blue bytes.
//
function N_SwapRedBlueBytes( ASrcColor: integer ): integer;
var
  RByte, GByte, BByte: integer;
begin
  RByte := ASrcColor and $0000FF;
  GByte := ASrcColor and $00FF00;
  BByte := ASrcColor and $FF0000;

  Result := (RByte shl 16) or GByte or (BByte shr 16);
end; // function N_SwapRedBlueBytes

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_SwapTwoInts
//*********************************************************** N_SwapTwoInts ***
// Swap two given Integers
//
//     Parameters
// APInt1 - pointer to first integer to swap
// APInt2 - pointer to second integer to swap
//
procedure N_SwapTwoInts( APInt1, APInt2: PInteger );
var
  iTmp: integer;
begin
  iTmp    := APInt1^;
  APInt1^ := APInt2^;
  APInt2^ := iTmp;
end; // procedure N_SwapTwoInts

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReverseFourBytes
//****************************************************** N_ReverseFourBytes ***
// Reverse all four bytes in given integer
//
//     Parameters
// ASrcInt - source integer
// Result  - Returns integer with Reversed bytes.
//
function N_ReverseFourBytes( ASrcInt: DWORD ): DWORD;
var
  RByte, GByte, BByte, AByte: DWORD;
begin
  RByte := ASrcInt and $000000FF;
  GByte := ASrcInt and $0000FF00;
  BByte := ASrcInt and $00FF0000;
  AByte := ASrcInt and $FF000000;

  Result := (RByte shl 24) or (GByte shl 8) or (BByte shr 8) or (AByte shr 24);
end; // function N_ReverseFourBytes

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_StrToColor
//************************************************************ N_StrToColor ***
// Convert given string to color
//
//     Parameters
// AStr   - source string with color text representation
// Result - Returns parsed color.
//
// The following formats are supported (chars case does not matter):
//#F
// <Empty string> - means black (zero) color
//   NONE     - N_EmptyColor
//   NONE(-1) - N_EmptyColor
//   TRANSP   - N_EmptyColor
//   CUR      - N_CurColor
//   CUR(-2)  - N_CurColor
//   CURRENT  - N_CurColor
//   $BBGGRR  - color in Delphi format
//   #RRGGBB  - color in HTML format
//   Decimal  - color as decimal number (no spaces inside), including -1, -2, ...
//   SPEC. Decimal - SPEC. followed by color as decimal number (no spaces inside), including -1, -2, ...
//   dr dg db - three decimal numbers in 0-255 range (red green blue, numbers only)
//   rN gN bN - three decimal numbers in 0-255 range with preceeding char (rgb or RGB)
//   Nr Ng Nb - three decimal numbers in 0-255 range followed by char (rgb or RGB)
//
// e.g. - #FF0102 = $0201FF = 131583 = 255 1 2 = r255 g1 b2 = 255r 1g 2r = 255R 1G 2B
//#/F
//
function N_StrToColor( AStr: string ): integer;
var
  SpacePos, Leng: integer;
  Str, Str2: string;
begin
  Result := 0;
  Str := UpperCase(Trim( AStr ));
  if (Str = '') then Exit;

  Result := N_EmptyColor;
  if 'NONE' = LeftStr( Str, 4 ) then Exit;
  if 'TRANSP' = LeftStr( Str, 6 ) then Exit;

  Result := N_CurColor;
  if 'CUR' = LeftStr( Str, 3 ) then Exit;

  if 'SPEC.' = LeftStr( Str, 5 ) then
    Str := Trim(MidStr( Str, 6, 1000 )); // remove 'SPEC.' prefix

  if Str[1] = '$' then // Hex Color in Delphi format
  begin
    Result := StrToInt( AStr );
  end else if Str[1] = '#' then // Hex Color in HTML format
  begin
    Result := N_SwapRedBlueBytes( StrToInt( '$'+Copy( Str, 2, 6 )));
  end else // one or three decimal numbers, may be with r,g,b characters
  begin
    SpacePos := Pos( ' ', Str );

    if SpacePos = 0 then // color as decimal number (no spaces inside)
    begin
      Result := StrToInt( Str );
      Exit;
    end;

    //***** Here:  R,G,B colors as three decimal numbers

    Str2 := UpperCase(N_ScanToken( Str ));
    Leng := Length( Str2 );

    if Str2[1] = 'R' then
      Str2 := Copy( Str2, 2, Leng-1 )
    else if Str2[Leng] = 'R' then
      Str2 := Copy( Str2, 1, Leng-1 );

    Result := StrToInt( Str2 ); // Red component

    Str2 := UpperCase(N_ScanToken( Str ));
    Leng := Length( Str2 );

    if Str2[1] = 'G' then
      Str2 := Copy( Str2, 2, Leng-1 )
    else if Str2[Leng] = 'G' then
      Str2 := Copy( Str2, 1, Leng-1 );

    Result := Result or (StrToInt( Str2 ) shl 8); // Green component

    Str2 := UpperCase(N_ScanToken( Str ));
    Leng := Length( Str2 );

    if Str2[1] = 'B' then
      Str2 := Copy( Str2, 2, Leng-1 )
    else if Str2[Leng] = 'B' then
      Str2 := Copy( Str2, 1, Leng-1 );

    Result := Result or (StrToInt( Str2 ) shl 16); // Blue component
  end;
end; // function N_StrToColor

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ColorToHTMLHex
//******************************************************** N_ColorToHTMLHex ***
// Convert given color to HTML Color format
//
//     Parameters
// AColor - source color
// Result - Returns color string representation in HTML Color format.
//
// Resulting value is 'none' for N_EmptyColor and 'Current' for N_CurColor
//
function N_ColorToHTMLHex( AColor: integer ): string;
begin
  if AColor = N_EmptyColor then
    Result := 'none'
  else if AColor = N_CurColor then
    Result := 'Current'
  else
    Result := Format( '#%.6X', [N_SwapRedBlueBytes( AColor )] );
end; // function N_ColorToHTMLHex

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ColorToQHTMLHex
//******************************************************* N_ColorToQHTMLHex ***
// Convert given color to quoted string in HTML Color format
//
//     Parameters
// AColor - source color
// Result - Returns color string representation in HTML Color format.
//
// Resulting value is "none" for N_EmptyColor and "Current" for N_CurColor
//
function N_ColorToQHTMLHex( AColor: integer ): string;
begin
  Result := '"' + N_ColorToHTMLHex( AColor ) + '"';
end; // function N_ColorToQHTMLHex

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ColorToRGBDecimals
//**************************************************** N_ColorToRGBDecimals ***
// Convert given AColor to string with three R,G,B components
//
//     Parameters
// AColor - source color
// Result - Returns color string representation with three R,G,B components.
//
// R,G,B components have 0-255 range followed by RGB characters (e.g. "0r 100g 
// 255b")
//
function N_ColorToRGBDecimals( AColor: integer ): string;
begin
  Result := Format( '%dr %dg %db', [AColor and $FF,
                                    (AColor shr 8) and $FF, AColor shr 16] );
end; // function N_ColorToRGBDecimals

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_RGB8ToGray8
//******************************************************** N_RGB8ToGray8 ***
// Convert given pf24bit RGB8 Color to Gray8
//
//     Parameters
// ARGB8Color - given pf24bit RGB8 Color to convert
// Result     - Returns Gray8 value
//
function N_RGB8ToGray8( ARGB8Color: Integer ): Integer;
var
  TmpPtr: TN_BytesPtr;
begin
  TmpPtr := TN_BytesPtr(ARGB8Color);
  Result := Round( 0.114*PByte(TmpPtr+2)^ +  // Blue
                   0.587*PByte(TmpPtr+1)^ +  // Green
                   0.299*PByte(TmpPtr)^   ); // Red
end; // function N_RGB8ToGray8

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GrayToRGB8
//********************************************************* N_GrayToRGB8 ***
// Convert given AGray value to pf24bit RGB Color
//
//     Parameters
// AGray    - given Gray value (0..2**16-1)
// ANumBits - number of bits in Gray16 value (8..16)
// Result   - Returns pf24bit RGB8 Color
//
// if ANumBits >= 9 highest 8 bit of AGray value are used
//
function N_GrayToRGB8( AGray: Integer; ANumBits: Integer = 8 ): Integer;
var
  Gray8: integer;
begin
  Gray8 := (AGray shr (ANumBits-8)) and $FF;
  Result := Gray8 or (Gray8 shl 8) or (Gray8 shl 16); // R=G=B
end; // function N_GrayToRGB8

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GrayToRGB16
//******************************************************** N_GrayToRGB16 ***
// Convert given AGray value to epfColor48 RGB Color
//
//     Parameters
// AGray  - given Gray value (0..2**16-1)
// Result - Returns epfColor48 RGB16 Color
//
function N_GrayToRGB16( AGray: Integer ): Int64;
begin
  Result := AGray or (AGray shl 16) or (AGray shl 32);
end; // function N_GrayToRGB16

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_LinCombRGB8
//******************************************************** N_LinCombRGB8 ***
// Calc Linear Combination of two given RGB8 Colors
//
//     Parameters
// AColor1, AColor2 - two given RGB8 Colors
// AAlfa            - given linear combination coef in [0,1] range
// Result           - linear combinations of given colors (also pf24bit RGB8 
//                    Color)
//
// Result = AAlfa*AColor1 + (1 - AAlfa)*AColor2
//
function N_LinCombRGB8( AColor1, AColor2: Integer; AAlfa: double ): Integer;
var
  P1, P2: PByte;
begin
  P1 := PByte(@AColor1);
  P2 := PByte(@AColor2);

  Result := Round( AAlfa*P1^ + (1.0-AAlfa)*P2^ ); Inc( P1 ); Inc( P2 );
  Result := Result or (Round( AAlfa*P1^ + (1.0-AAlfa)*P2^ ) shl 8); Inc( P1 ); Inc( P2 );
  Result := Result or (Round( AAlfa*P1^ + (1.0-AAlfa)*P2^ ) shl 16);
end; // function N_LinCombRGB8

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetTabDelimToken
//****************************************************** N_GetTabDelimToken ***
// Get Tab delimited Token from given Chars buffer
//
//     Parameters
// APChar    - pointer to current buffer position
// ANumChars - Chars number from current position to the end of buffer
// Result    - Returns parsed token or empty string if nothing to do.
//
// On output pointer to current buffer position APChar and remained chars 
// counter ANumChars will be updated according to retrieved Token Size.
//
function N_GetTabDelimToken( var APChar: PChar; var ANumChars: integer ): string;
var
  i: integer;
  PBegToken: PChar;
begin
  if (ANumChars = 0) or (APChar = nil) then
  begin
    Result := '';
    Exit;
  end;

  PBegToken := APChar;

  for i := 1 to ANumChars do
  begin
    if APChar^ = Char(9) then // Tab char, End of Token
    begin
      SetString( Result, PBegToken, i-1 );
      Dec( ANumChars, i );
      Inc( APChar );
      Exit;
    end; // if APChar^ = Char(9) then // Tab char, End of Token

    Inc( APChar );
  end; // for i := 1 to ANumChars do

  //*** needed Token is whole Bufer

  SetString( Result, PBegToken, ANumChars );
  ANumChars := 0;
end; // function N_GetTabDelimToken

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetStringsText
//******************************************************** N_GetStringsText ***
// CONV TO UNICODE!!! Get all strings from given Strings List as single 
// delimited string
//
//     Parameters
// AStrings   - given Strings List
// ADelimiter - delimiter char code
//
// If delimiter char code ADelimiter is equal to -1 then Space char is used as 
// delimiter and prefix with number of Tokens in brackets "(<Tokens Count>)" 
// will be added. If ADelimiter is equal to Tab or Space no additional 
// delimiters are added even if AStrings Items contain ADelimiter character.
//
function N_GetStringsText( AStrings: TStrings; ADelimiter: integer = -1 ): string;
var
  i, ResSize, ResInd, NumTokens, TokenSize: integer;
  Prefix: string;
begin
  Result := '';

  if AStrings = nil then
  begin
    if ADelimiter < 0 then Result := '()'
                      else Result := '';
    Exit;
  end; // if AStrings = nil then

  NumTokens := AStrings.Count;

  if NumTokens = 0 then
  begin
    if ADelimiter < 0 then Result := '(0)'
                      else Result := '';
    Exit;
  end; // if NumTokens = 0 then

  if ADelimiter < 0 then Prefix := Format( '(%d):', [NumTokens] )
                    else Prefix := '';

  if ADelimiter = -1 then ADelimiter := $20; // Space

  ResSize := Length(Prefix) + NumTokens - 1;

  for i := 0 to NumTokens-1 do
    Inc( ResSize, Length(AStrings[i]) );

  Result := Prefix;
  SetLength( Result, ResSize );
  ResInd := Length(Prefix) + 1;

  for i := 0 to NumTokens-1 do
  begin
    TokenSize := Length( AStrings[i] );

    if TokenSize > 0 then // copy Token Content from AStrings[i] to Result
    begin
      move( AStrings[i][1], Result[ResInd], TokenSize );
      Inc( ResInd, TokenSize );
    end;

    if i < (NumTokens-1) then // Add Delimiter
    begin
      Result[ResInd] := Char( ADelimiter );
      Inc( ResInd );
    end;
  end; // for i := 0 to NumTokens-1 do

end; // function N_GetStringsText

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AddTabDelimToken
//****************************************************** N_AddTabDelimToken ***
// CONV TO UNICODE!!! Add given token to given string buffer delimited by Tab 
// character
//
//     Parameters
// ABufStr   - given string buffer
// AToken    - given token
// ANumChars - current buffer position index
//
// Tab character will be added before token if string buffer is not empty 
// (ANumChars > 0). Сurrent buffer position index ANumChars on output will be 
// shifted to new buffer free space position. String buffer ABufStr length may 
// be incearsed if needed.
//
procedure N_AddTabDelimToken( var ABufStr: string; AToken: string; var ANumChars: integer );
var
  NeededSize, TokenSize: integer;
begin
  TokenSize := Length( AToken );
  NeededSize := ANumChars + TokenSize + 1;

  if Length(ABufStr) < NeededSize then
    SetLength( ABufStr, N_NewLength( NeededSize ) );

  if ANumChars > 0 then // not first token
  begin
    Inc(ANumChars);
    ABufStr[ANumChars] := Char(9); // Add Tab char before Token
  end; // if ANumChars > 1 then // not first token

  if TokenSize > 0 then
  begin
    move( Atoken[1], ABufStr[ANumChars+1], TokenSize );
    Inc( ANumChars, TokenSize );
  end; // if TokenSize > 0 then
end; // procedure N_AddTabDelimToken

{
//************************************************************ N_PosEx(Str) ***
//
function N_PosEx(const SubStr, S: string; Offset: Cardinal = 1; SLength: Integer = 1 ): Integer;
var
  I,X: Integer;
  Len, LenSubStr: Integer;
begin
  I := Offset;
  LenSubStr := Length(SubStr);
//  Len := Length(S) - LenSubStr + 1;
  Len := SLength - LenSubStr + 1;

  while I <= Len do // along all chars in S beginning from Offset
  begin
    if S[I] = SubStr[1] then // first char of SubStr found
    begin
      X := 1; // offset in SubStr

      while (X < LenSubStr) and (S[I + X] = SubStr[X + 1]) do // next char is OK
        Inc(X);

      if (X = LenSubStr) then // all chars are OK (SubStr found)
      begin
        Result := I;
        exit;
      end; // if (X = LenSubStr) then // all chars are OK (SubStr found)

    end; // if S[I] = SubStr[1] then // first char of SubStr found

    Inc(I); // to next char in S
  end; // while I <= Len do // along all chars in S beginning from Offset

  Result := 0;
end; // function N_PosEx
}

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_PosExPtr
//************************************************************** N_PosExPtr ***
// Search for given Substring in a String, given by Pointer
//
//     Parameters
// APSubStr          - Pointer to first char of Substring
// APStr             - Pointer to first char of String, where to search for 
//                     Substring
// ASubstrLeng       - Substring Length (should be >= 1)
// AStrOffset        - Offset in String (counting from 1) from where to search
// ANumCharsToSearch - String Length (should be >= 1)
// Result            - Returns index of first founded Substring (counting from 
//                     1) or 0 if not found
//
// N_PosExPtr is analog of Delphi PosEx function with other parameters
//
function N_PosExPtr( APSubStr, APStr: Pointer;
                     ASubstrLeng, AStrOffset, ANumCharsToSearch: Integer ): Integer;
var
  I,X: Integer;
  Len: Integer;
  PStr, PStr2, PSubstr: PChar;
begin
  I := AStrOffset;
  Len := ANumCharsToSearch - ASubstrLeng + 1;
  PStr    := PChar(APStr) + I - 1;
  PSubstr := PChar(APSubStr);
//  N_c1 := PSubstr^; // debug
//  N_c2 := PStr^;

  while I <= Len do // along all chars in Str beginning from AStrOffset
  begin
    if PStr^ = PSubstr^ then // first char of SubStr found
    begin
      PStr2 := PStr + 1;
      Inc(PSubstr);
      X := 1;

      while (X < ASubstrLeng) and (PStr2^ = PSubstr^) do // next char is OK
      begin
        Inc(X);
        Inc(PStr2);
        Inc(PsubStr);
      end;

      if (X = ASubstrLeng) then // all chars are OK (SubStr found)
      begin
        Result := I;
        Exit;
      end else // SubStr NOT found, set initial value of PSubstr
        PSubstr := PChar(APSubStr);

    end; // if S[I] = SubStr[1] then // first char of SubStr found

    Inc(I);    // to next char in S
    Inc(PStr); // to next char in S
  end; // while I <= Len do // along all chars in S beginning from Offset

  Result := 0; // "Substring not found" flag
end; // function N_PosExPtr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_PosEx
//***************************************************************** N_PosEx ***
// Search for given Substring in a given String
//
//     Parameters
// ASubStr           - Substring to search
// AStr              - String, where to search for Substring
// AStrOffset        - Offset in String (counting from 1) from where to search
// ANumCharsToSearch - String Length (should be >= 1)
// Result            - Returns index of first founded Substring (counting from 
//                     1) or 0 if not found
//
// N_PosEx is analog of Delphi PosEx function with given ANumCharsToSearch
//
function N_PosEx( const ASubStr, AStr: string; AStrOffset, ANumCharsToSearch: Integer ): Integer;
var
  I, X, ASubstrLeng: Integer;
  Len: Integer;
  PStr, PStr2, PSubstr: PChar;
begin
  I := AStrOffset;
  ASubstrLeng := Length(ASubStr); // should be >=1
  Len := ANumCharsToSearch - ASubstrLeng + 1;
  PStr    := PChar(@AStr[1]) + I - 1;
  PSubstr := @ASubStr[1];
//  N_c1 := PSubstr^; // debug
//  N_c2 := PStr^;

  while I <= Len do // along all chars in Str beginning from AStrOffset
  begin
    if PStr^ = PSubstr^ then // first char of SubStr found
    begin
      PStr2 := PStr + 1;
      Inc(PSubstr);
      X := 1;

      while (X < ASubstrLeng) and (PStr2^ = PSubstr^) do // next char is OK
      begin
        Inc(X);
        Inc(PStr2);
        Inc(PsubStr);
      end;

      if (X = ASubstrLeng) then // all chars are OK (SubStr found)
      begin
        Result := I;
        Exit;
      end else // SubStr NOT found, set initial value of PSubstr
        PSubstr := @ASubStr[1];

    end; // if S[I] = SubStr[1] then // first char of SubStr found

    Inc(I);    // to next char in S
    Inc(PStr); // to next char in S
  end; // while I <= Len do // along all chars in S beginning from Offset

  Result := 0; // "Substring not found" flag
end; // function N_PosEx(Str)

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ReverseIntArray
//******************************************************* N_ReverseIntArray ***
// Reverse given elements of given Array of Integer
//
//     Parameters
// AIntArray  - given Array of Integer
// ANumElemes - given Mumber of Elements to reverse
//
procedure N_ReverseIntArray( AIntArray: TN_IArray; ANumElemes: integer );
var
  i, TmpInt: integer;
begin
  for i := 0 to (ANumElemes div 2)-1 do // swap pairs of elements
  begin
    TmpInt := AIntArray[i];
    AIntArray[i] := AIntArray[ANumElemes-i-1];
    AIntArray[ANumElemes-i-1] := TmpInt;
  end; // for i := 0 to (ANumElemes div 2)-1 do // swap pairs of elements
end; // procedure N_ReverseIntArray


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CopyGUID
{
//************************************************************** N_CopyGUID ***
// Copy given ASrcGUID to ADstGUID
//
//     Parameters
// ASrcGUID - given GUID
// ADstGUID - on output, copy of given ASrcGUID
//
procedure N_CopyGUID( const ASrcGUID: TGUID; var ADstGUID: TGUID );
begin
  Move( ASrcGUID, ADstGUID, SizeOf(TGUID) );
end; // procedure N_CopyGUID
}

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_MemBlocksStr
//********************************************************** N_MemBlocksStr ***
// Get String with given Memory Blocks Info Record content
//
//     Parameters
// APMemBlocksInfo - given pointer to MemBlocksInfo with all fields set
// Result          - Return String with all MemBlocksInfo fields
//
function N_MemBlocksStr( APMemBlocksInfo: TN_PMemBlocksInfo ): String;
begin
  with APMemBlocksInfo^ do
  begin
    Result := Format( 'BigSize=%.1f, Num Blocks: Big=%d, Free=%d, All=%d;  Sum Size: Big=%.1f, Free=%.1f',
           [(1.0*MBIMinBigSize/1024)/1024, MBINumBigBlocks, MBINumFreeBlocks,
            (1.0*MBISumBigSize/1024)/1024, (1.0*MBISumFreeSize/1024)/1024] );
  end; // with APMemBlocksInfo^ do
end; // function N_MemBlocksStr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetMemBlocksInfo1
//***************************************************** N_GetMemBlocksInfo1 ***
// Get Info about Windows Memory Blocks in given Record
//
//     Parameters
// APMemBlocksInfo - given pointer to MemBlocksInfo with MBIMinBigSize field set
//
procedure N_GetMemBlocksInfo1( APMemBlocksInfo: TN_PMemBlocksInfo );
var
  iRes: integer;
  NextPtr: DWORD;
  IsFree: boolean;
  MemInfo: TMemoryBasicInformation;
begin
  with APMemBlocksInfo^ do
  begin
    ZeroMemory( @MBINumFreeBlocks, SizeOf(APMemBlocksInfo^) - 4 ); // Clear all except MBIMinBigSize
    NextPtr := 0;
    MemInfo.BaseAddress := nil;

    while True do // along all Memory Blocks
    begin
      iRes := Windows.VirtualQuery( Pointer(NextPtr), MemInfo, SizeOf(MemInfo) );
      if iRes = 0 then Break; // all done

      IsFree := (MemInfo.State and MEM_FREE) <> 0;

      if IsFree then // Free Memory Block
      begin
        Inc( MBINumFreeBlocks );
        MBISumFreeSize := MBISumFreeSize + MemInfo.RegionSize;

        if MemInfo.RegionSize >= MBIMinBigSize then
        begin
          Inc( MBINumBigBlocks );
          MBISumBigSize := MBISumBigSize + MemInfo.RegionSize;
        end; // if MemInfo.RegionSize >= MBIMinBigSize then
      end; // if IsFree then // Free Memory Block

      NextPtr := DWORD(MemInfo.BaseAddress) + MemInfo.RegionSize;
    end; // while True do // along all Memory Blocks
  end; // with APMemBlocksInfo^ do
end; // procedure N_GetMemBlocksInfo1

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetMemBlocksInfo2
//***************************************************** N_GetMemBlocksInfo2 ***
// Get Info about Windows Big Memory Blocks in given Strings
//
//     Parameters
// AMinBigSize - Minimum Size in bytes of "Big" Memory Blocks
// AResStrings - Resulting Strings to which info about all Big Memory Blocks 
//               (Addr and Size) and summury Sizes would be added
//
procedure N_GetMemBlocksInfo2( AMinBigSize: DWORD; AResStrings: TStrings );
var
  iRes: integer;
  NextPtr: DWORD;
  IsFree: boolean;
  Str: String;
  MemInfo: TMemoryBasicInformation;
  MemBlocksInfo: TN_MemBlocksInfo;
begin
  with MemBlocksInfo do
  begin
    ZeroMemory( @MBINumFreeBlocks, SizeOf(MemBlocksInfo) - 4 ); // Clear all except MBIMinBigSize
    NextPtr := 0;
    MemInfo.BaseAddress := nil;
    Str := '';

    while True do // along all Memory Blocks
    begin
      iRes := Windows.VirtualQuery( Pointer(NextPtr), MemInfo, SizeOf(MemInfo) );
      if iRes = 0 then Break; // all done

      IsFree := (MemInfo.State and MEM_FREE) <> 0;

      if IsFree then // Free Memory Block
      begin
        Inc( MBINumFreeBlocks );
        MBISumFreeSize := MBISumFreeSize + MemInfo.RegionSize;

        if MemInfo.RegionSize >= MBIMinBigSize then
        begin
          Inc( MBINumBigBlocks );
          MBISumBigSize := MBISumBigSize + MemInfo.RegionSize;

          if Length(Str) < 60 then
            Str := Str + Format( '%8X %3.0f ', [] )
          else
          begin
            AResStrings.Add( Str );
            Str := Format( '%8X %3.0f ', [] )
          end;

        end; // if MemInfo.RegionSize >= MBIMinBigSize then


      end; // if IsFree then // Free Memory Block

      NextPtr := DWORD(MemInfo.BaseAddress) + MemInfo.RegionSize;
    end; // while True do // along all Memory Blocks

    AResStrings.Add( Str );
    AResStrings.Add( N_MemBlocksStr( @MemBlocksInfo ) );
  end; // with APMemBlocksInfo^ do
end; // procedure N_GetMemBlocksInfo2

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AddDirToPATHVar
//**************************************************** N_AddDirToPATHVar ***
// Conv to UNICODE!!! Add given ADir To PATH Process Variable if not yet
//
//     Parameters
// ADir - given Directory to add
//
// ADir can contain or not terminating backslah
//
procedure N_AddDirToPATHVar( ADir: String );
var
  ResBufSize, DirNameSize, StartInd, ResInd, NextInd: integer;
  TmpDir, ResBufStr: string;
  WChar: char;

  Label SearchLoop;
begin
  TmpDir := UpperCase( ADir );
  DirNameSize := Length(TmpDir);

  if TmpDir[DirNameSize] = '\' then
  begin
    Dec( DirNameSize );
    TmpDir := LeftStr( TmpDir, DirNameSize );
  end;

  ResBufSize := Windows.ExpandEnvironmentStrings( PChar('%PATH%'), @WChar, 0 );
  ResBufSize := ResBufSize + DirNameSize + 1;
  SetLength( ResBufStr, ResBufSize );
  ResBufSize := Windows.ExpandEnvironmentStrings( PChar('%PATH%'), @ResBufStr[1], ResBufSize );

  StartInd := 1;
//  N_s := String( PChar(@ResBufStr[1]) ); // debug
//  N_i := Length( N_s );

  SearchLoop:
  ResInd := N_PosExPtr( @TmpDir[1], @ResBufStr[1], DirNameSize, StartInd, ResBufSize );

  if ResInd > 0 then // found, check that it is not a beg of nexted Dir name
  begin
    NextInd := ResInd + DirNameSize;

    if (ResBufStr[NextInd] = Char(0)) or (ResBufStr[NextInd] = ';') then // already OK, all done
      Exit
    else // continue search
    begin
      StartInd := NextInd;
      goto SearchLoop;
    end;
  end; // if ResInd > 0 then // found, check that it is not a beg of nexted Dir name

  //***** Here: ADir is not found in current PATH content, add it

  ResBufStr[ResBufSize] := ';';

  N_s := String( PChar(@ResBufStr[1]) ); // debug
  N_i := Length( N_s );

  move( TmpDir[1], ResBufStr[ResBufSize + 1], (DirNameSize+1)*SizeOf(Char) ); // add ADir and terminating zero

  N_s := String( PChar(@ResBufStr[1]) ); // debug
  N_i := Length( N_s );

  N_b := Windows.SetEnvironmentVariable( 'PATH', @ResBufStr[1] );
  N_i := 2;

end; // procedure N_AddDirToPATHVar

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ClipBy0255
//********************************************************* N_ClipBy0255 ***
// Clip given double AValue by (0,255) interval and round the result
//
//     Parameters
// AValue - given value to clip
// Result - Return clipped and rounded AValue
//
function N_ClipBy0255( AValue: double ): integer;
begin
  if AValue < 0   then AValue := 0;
  if AValue > 255 then AValue := 255;
  Result := Round( AValue );
end; // function N_ClipBy0255

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AddColumnToSL
//****************************************************** N_AddColumnToSL ***
// Conv to UNICODE!!! Add to given ALeftSL Strings given ARightSL Strings as 
// Column
//
//     Parameters
// AMainSL   - main strings where to add new Column
// AColumnSL - Column to add content
// AGap      - number of spaces before new Column
// AMainInd  - index of ALeftSL where to start new Column
//
procedure N_AddColumnToSL( AMainSL, AColumnSL: TStrings; AGap, AMainInd: integer );
var
  i, ibeg, iend, ci, Size, ColSize, MainSize: integer;
  NewStr: string;
begin
  // String handling routines
  ibeg := AMainInd;
  iend := max( AMainSL.Count-1, ibeg + AColumnSL.Count - 1 );

  MainSize := 0;

  for i := ibeg to AMainSL.Count-1 do // Calc Main max string size
  begin
    Size := Length( AMainSL[i] );
    if MainSize < Size then MainSize := Size;
  end;

  for i := ibeg to iend do // main loop
  begin
    ci      := i - ibeg; // Column index
    ColSize := Length( AColumnSL[ci] ); // Column Size
    SetLength( NewStr, MainSize+AGap+ColSize );

    if i >= AMainSL.Count then // no Main part, only Column
    begin
      FillChar( NewStr[1], MainSize+AGap, ' ' ); // needed left spaces
      move( AColumnSL[ci][1], NewStr[MainSize+AGap+1], ColSize );
      AMainSL.Add( NewStr );
    end else if (i-ibeg) < AColumnSL.Count then // both Main and Column parts are present
    begin
      Size := Length( AMainSL[i] );
      move( AMainSL[i][1], NewStr[1], Size );
      FillChar( NewStr[Size+1], AGap, ' ' ); // needed spaces before column
      move( AColumnSL[ci][1], NewStr[Size+AGap+1], ColSize );
      AMainSL[i] := NewStr;
    end;
  end; // for i := ibeg to iend do // main loop

end; // procedure N_AddColumnToSL

//****************************************************** N_CreateWhiteChars ***
// Create String with given number of Spaces
//
// ANumWhiteChars - given number of Spaces
//
function N_CreateWhiteChars( ANumWhiteChars: Integer ): string;
var
  i: integer;
begin
  SetLength( Result, ANumWhiteChars );

  for i := 1 to ANumWhiteChars do
    Result[i] := ' ';
end; // function N_CreateWhiteChars( ANumWhiteChars: Integer ): string;

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_FormatString
//********************************************************** N_FormatString ***
// Format given ASrcStr in field of given size
//
//     Parameters
// ASrcStr       - given string to format
// AEllipsisStr  - Ellipsis string, is used only if Length(ASrcStr) >
//                 ANeededLength
// ANeededLength - Needed Resulting string length (in characters)
// AFmtFlags     - Format Flags: bits 0-3 - =0 - align Left, =1 - align Center,
//                 =2 - align Right (for small ASrcStr) bits 4-7 - =0 - crop
//                 Right, =1 - crop Center,   =2 - crop Left (for big ASrcStr)
// Result        - Return String which have exactly ANeededLength with AsrcStr
//                 properly placed inside it
//
function N_FormatString( ASrcStr, AEllipsisStr: string; ANeededLength: integer;
                         AFmtFlags: Integer ): string;
var
  SrcLeng, EllipsisLeng, LeftGap, NumSpaces, Flags, LeftLeng: integer;
  ReadyStr: String;
begin
  ReadyStr := N_RemoveSubsWhiteChars( ASrcStr );
  SrcLeng := Length( ReadyStr );

  if SrcLeng < ANeededLength then // small ASrcStr, align it in ANeededLength place
  begin
    NumSpaces := ANeededLength - SrcLeng;
    Flags := AFmtFlags and $00F;

    if Flags = 1 then // align Center
    begin
      LeftGap := NumSpaces div 2;
      Result := DupeString( ' ', LeftGap ) + ReadyStr + DupeString( ' ', NumSpaces-LeftGap );
    end else if Flags = 2 then // align Right
    begin
      Result := DupeString( ' ', NumSpaces ) + ReadyStr;
    end else // Flags = 0, Align Left
    begin
      Result := ReadyStr + DupeString( ' ', NumSpaces );
    end;
  end else if SrcLeng = ANeededLength then // nothing todo
  begin
    Result := ReadyStr;
  end else // ASrcStrLeng > ANeededLength, big ASrcStr, crop it
  begin
    EllipsisLeng := Length( AEllipsisStr );
    Flags := AFmtFlags and $0F0;

    if Flags = $010 then // Crop Center (first and last chars in ASrcStr remain)
    begin
      LeftLeng := (ANeededLength - EllipsisLeng) div 2;
      Result := LeftStr( ReadyStr, LeftLeng ) + AEllipsisStr +
               RightStr( ReadyStr, ANeededLength - EllipsisLeng - LeftLeng );
    end else if Flags = $020 then // Crop Left (last chars in ASrcStr remain)
    begin
      Result := AEllipsisStr + RightStr( ReadyStr, ANeededLength - EllipsisLeng );
    end else // Flags = $000, Crop Right (first chars in ASrcStr remain)
    begin
      Result := LeftStr( ReadyStr, ANeededLength - EllipsisLeng ) + AEllipsisStr;
    end;
  end; // else // ASrcStrLeng > ANeededLength, big ASrcStr, crop it
end; // function N_FormatString

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AlignString
//******************************************************** N_AlignString ***
// Align given ASrcStr in field of given size
//
//     Parameters
// ASrcStr       - given string to align
// AClipStr      - Clipped string postfix ( is used only if Length(ASrcStr) > 
//                 ANeededLength )
// ANeededLength - Needed Resulting string length (in characters)
// AFmtFlags     - Format (horizontal alignment) flags
// Result        - Return String which have ANeededLength with AsrStr properly 
//                 aligned inside it
//
function N_AlignString( ASrcStr, AClipStr: string; ANeededLength: integer;
                        AFmtFlags: TN_CellFmtFalgs ): string;
var
  SrcLeng, ClipLeng, LeftGap, NumSpaces: integer;
begin
  SrcLeng := Length( ASrcStr );

  if SrcLeng < ANeededLength then // align
  begin
    NumSpaces := ANeededLength - SrcLeng;

    if cffHorAlignCenter in AFmtFlags then
    begin
      LeftGap := NumSpaces div 2;
      SetLength( Result, ANeededLength );
      Result := DupeString( ' ', LeftGap ) + ASrcStr + DupeString( ' ', NumSpaces-LeftGap );
    end else if cffHorAlignRight in AFmtFlags then
    begin
      Result := DupeString( ' ', NumSpaces ) + ASrcStr;
    end else // Align Left
    begin
      Result := ASrcStr + DupeString( ' ', NumSpaces );
    end;
  end else if SrcLeng = ANeededLength then // nothing todo
  begin
    Result := ASrcStr;
  end else // ASrcStrLeng > ANeededLength, clip ASrcStr
  begin
    ClipLeng := Length( AClipStr );
    Result := LeftStr( ASrcStr, ANeededLength-ClipLeng );
    Result := Result + AClipStr;
  end;
end; // function N_AlignString

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AlignStrMatr
//******************************************************* N_AlignStrMatr ***
// Align given Strings Matrix
//
//     Parameters
// AStrMatr  - given Strings Matrix to Align
// ACFPArray - Columns Format Params Array (one elem for each Column)
//
// Add spaces in AStrMatr cells so that all cells in same column have the same 
// length (same number of chars) and texts in cells are preperly aligned
//
procedure N_AlignStrMatr( AStrMatr: TN_ASArray; ACFPArray: TN_CFPArray );
var
  ix, iy, MaxLeng: integer;
begin
  for ix := 0 to High(AStrMatr[0]) do // along all Columns
  with ACFPArray[ix] do
  begin
    MaxLeng := CFPMinChars;

    for iy := 0 to High(AStrMatr) do // along all Cells in ix-th Column
      MaxLeng := Max( MaxLeng, Length(AStrMatr[iy][ix]) );

    for iy := 0 to High(AStrMatr) do // along all Cells in ix-th Column
      AStrMatr[iy][ix] := N_AlignString( AStrMatr[iy][ix], '...', MaxLeng, CFPFlags );

  end; // for ix := 0 to High(AStrMatr[0]) do // along all Columns
end; // procedure N_AlignStrMatr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_StrMatrToStrings
//*************************************************** N_StrMatrToStrings ***
// Save Strings Matrix Rows to given AStrings
//
//     Parameters
// AStrMatr  - given Strings Matrix with needed content
// AStrings  - resulting TStrings (one elem is concatenation of all Row elem)
// ADelimStr - given string, used as Delimiter between Cells
//
procedure N_StrMatrToStrings( AStrMatr: TN_ASArray; AStrings: TStrings; ADelimStr: string );
var
  ix, iy: integer;
  BufStr: string;
begin
  AStrings.Clear;

  for iy := 0 to High(AStrMatr) do // along all Rows
  begin
    BufStr := AStrMatr[iy][0];

    for ix := 1 to High(AStrMatr[iy]) do // along Cells in iy-th Row
      BufStr := BufStr + ADelimStr + AStrMatr[iy][ix];

    AStrings.Add( BufStr );
  end; // for iy := 0 to High(AStrMatr) do // along all Rows
end; // procedure N_StrMatrToStrings

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_StringsFromStrMatr
//************************************************* N_StringsFromStrMatr ***
// Load TStrings from given column in given Strings Matrix
//
//     Parameters
// AStrings   - given TStrings to load (to fill)
// AStrMatr   - given Strings Matrix with needed content
// ABegIndX   - Beg X (Column) Index,
// ABegIndY   - Beg Y (Row) Index,
// ANumElemes - number of elements to load (-1 means till the column end, -2 
//              till ###)
//
procedure N_StringsFromStrMatr( AStrings: TStrings; AStrMatr: TN_ASArray;
                                ABegIndX, ABegIndY, ANumElemes: integer );
var
  i, NumRows, LastInd: integer;
  NextStr: string;
begin
  AStrings.Clear;
  NumRows := Length(AStrMatr);

  if ANumElemes >= 0 then // Number of elems to load is given
    LastInd := ABegIndY + ANumElemes - 1
  else // load till the Column end or till ###
    LastInd := NumRows - 1; // all Column elements

  for i := ABegIndY to LastInd do
  begin
    NextStr := AStrMatr[i][ABegIndX];

    if ANumElemes = -2 then
    begin
      if NextStr = '###' then Break;
    end;

    AStrings.Add( NextStr );
  end; // for i := ABegIndY to LastInd do
end; // procedure N_StringsFromStrMatr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_IntsFromStrMatr
//**************************************************** N_IntsFromStrMatr ***
// Load integers from given column in given Strings Matrix
//
//     Parameters
// AIArray    - given TStrings to load (to fill)
// AStrMatr   - given Strings Matrix with needed content
// ABegIndX   - Beg X (Column) Index,
// ABegIndY   - Beg Y (Row) Index,
// ANumElemes - number of elements to load (-1 means till the column end)
//
procedure N_IntsFromStrMatr( var AIArray: TN_IArray; AStrMatr: TN_ASArray;
                                 ABegIndX, ABegIndY, ANumElemes: integer );
var
  i, NumRows, LastInd: integer;
begin
  NumRows := Length(AStrMatr);

  if ANumElemes >= 1 then
    LastInd := ABegIndY + ANumElemes - 1
  else
    LastInd := NumRows - 1;

  SetLength( AIArray, LastInd-ABegIndY+1 );

  for i := ABegIndY to LastInd do
    AIArray[i-ABegIndY] := StrToIntDef( AStrMatr[i][ABegIndX], 0 );

end; // procedure N_IntsFromStrMatr

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetDateTimeStr1
//**************************************************** N_GetDateTimeStr1 ***
// Return Current Date Time in YYYY_MM_DD-HH_MM_SS format
//
//     Parameters
// ADateTime - TimeStamp to create str, if not given then Now() is used
// Result - Return Current Date Time in YYYY_MM_DD-HH_MM_SS format
//
function N_GetDateTimeStr1( ADateTime : TDateTime = 0 ): string;
var
  Year, Month, Day, Hour, Minute, Second, MilliSecond: Word;
begin
  if ADateTime = 0 then
    ADateTime := Now();
  DecodeDateTime( ADateTime, Year, Month, Day, Hour, Minute, Second, MilliSecond );
  Result := Format( '%d_%0.2d_%0.2d-%0.2d_%0.2d_%0.2d', [Year, Month, Day, Hour, Minute, Second] );
end; // function N_GetDateTimeStr1

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_B2Str
//************************************************************** N_B2Str ***
// Convert given ABoolVal to one Char String 'F' or 'T'
//
//     Parameters
// ABoolVal - given boolean value
// Result   - Return 'F' if ABoolVal=False or 'T' if ABoolVal=True
//
function N_B2Str( ABoolVal: boolean ): string;
begin
  if ABoolVal then Result := 'T'
              else Result := 'F';
end; // function N_B2Str

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_DumpTControl
//******************************************************* N_DumpTControl ***
// Dump given TControl coords
//
//     Parameters
// AName    - given AControl Name
// AControl - given TControl to dump
//
procedure N_DumpTControl( AName: string; AControl: TControl );
begin
  if not (AControl is TControl) then Exit;

  with AControl do
    N_Dump1Str( Format( '  %s:(L=%d T=%d W=%d H=%d)',
                        [AName, Left, Top, Width, Height] ));
end; // procedure N_DumpTControl

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetComboBoxObjInt
//************************************************** N_GetComboBoxObjInt ***
// Get AComboBox.Items Obj as Integer for current AComboBox.ItemIndex
//
//     Parameters
// AComboBox - given ComboBox
// Result    - Return AComboBox.Items Obj as Integer for current 
//             AComboBox.ItemIndex
//
function N_GetComboBoxObjInt( AComboBox: TComboBox ): integer;
begin
  if AComboBox.ItemIndex = -1 then // Item is not Selected
    Result := -1 // No Current Item
  else
    Result := integer(AComboBox.Items.Objects[AComboBox.ItemIndex]);
end; // function N_GetComboBoxObjInt

{$WARN SYMBOL_DEPRECATED OFF}
{$WARN SYMBOL_PLATFORM OFF}

// Some TMemoryBasicInformation.State flags:
//  MEM_COMMIT   = $01000;
//  MEM_RESERVE  = $02000;
//  MEM_FREE     = $10000;

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_WinMemFullInfo
//***************************************************** N_WinMemFullInfo ***
// Get full info about all Windows memory blocks
//
//     Parameters
// ASL   - given TStrings where to add Info
// AMode - binary flags - what info is needed (now not used)
//
// Each Windows memory block is neighbour Windows Pages with exactly same status
//
procedure N_WinMemFullInfo( ASL: TStrings; AMode: integer );
var
  i, ResCode: integer;
  NextPtr: DWORD;
  Str: string;
  Total: int64;
  MemInfo: TMemoryBasicInformation;
begin
  Total   := 0;
  NextPtr := 0;

  for i := 0 to 5000 do // 5000 is a precaution, really much less
  begin
    ResCode := Windows.VirtualQuery( Pointer(NextPtr), MemInfo, SizeOf(MemInfo) );
    if ResCode = 0 then Break; // ResCode is number of bytes returned in MemInfo

    with MemInfo do
      Str := Format( 'BaseAdr=%.8x, AllocBase=%.8x, Size=%8.3fMb, State=%.2x, Protect=%.3x, Type=%.4x',
                  [DWORD(BaseAddress), DWORD(AllocationBase), 0.001*RegionSize/1024.0,
                  State shr 12, Protect, Type_9 shr 12] );
    ASL.Add( Str );
    NextPtr := DWORD(MemInfo.BaseAddress) + MemInfo.RegionSize;
    Total := Total + MemInfo.RegionSize;
  end; // for i := 0 to 5000 do // 5000 is a precaution, really much less
  ASL.Add( '' );
end; // procedure N_WinMemFullInfo


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CollectFreeMemBlocks
//*********************************************** N_CollectFreeMemBlocks ***
// Collect array of free Memory Blocks in whole Windows Virtaul address space
//
//     Parameters
// AMemBlocks - Array of collected Free Memory Blocks
//
procedure N_CollectFreeMemBlocks( var AMemBlocks: TN_FreeMemBlocks );
var
  i, ResCode, FreeInd: integer;
  NextPtr: DWORD;
  MemInfo: TMemoryBasicInformation;
begin
  NextPtr := 0;
  FreeInd := 0;
  if Length(AMemBlocks) < 200 then SetLength( AMemBlocks, 200 );

  for i := 0 to 5000 do // 5000 is a precaution, really much less
  begin
    ResCode := Windows.VirtualQuery( Pointer(NextPtr), MemInfo, SizeOf(MemInfo) );
    if ResCode = 0 then Break; // ResCode is number of bytes returned in MemInfo
    if DWORD(MemInfo.BaseAddress) >= $7FFE0000 then Break;

    if (MemInfo.State and MEM_FREE) <> 0 then // Free (not allocated) Memory Block
    begin
      AMemBlocks[FreeInd].FMBStart := DWORD(MemInfo.BaseAddress);
      AMemBlocks[FreeInd].FMBSize  := MemInfo.RegionSize;
      Inc( FreeInd );
    end; // if (MemInfo.State and MEM_FREE) <> 0 then // Free (not allocated) Memory Block

    NextPtr := DWORD(MemInfo.BaseAddress) + MemInfo.RegionSize;
  end; // for i := 0 to 5000 do // 5000 is a precaution, really much less

  SetLength( AMemBlocks, FreeInd );
end; // procedure N_CollectFreeMemBlocks

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_FreeMemBlocksInfo
//************************************************** N_FreeMemBlocksInfo ***
// Get info about given AMemBlocks
//
//     Parameters
// ASL        - given TStrings where to add Info
// AMemBlocks - given Array of Free Memory Blocks to show
// AMode      - binary flags - what info is needed (now not used)
//
// Each Windows memory block is neighbour Windows Pages with exactly same status
//
procedure N_FreeMemBlocksInfo( ASL: TStrings; AMemBlocks: TN_FreeMemBlocks; AMode: integer );
var
  i: integer;
  TotalSize, Size: double;
begin
  TotalSize := 0;
  ASL.Add( '  Free Memory Blocks:' );

  for i := 0 to High(AMemBlocks) do // along all Blocks
  with AMemBlocks[i] do
  begin
    Size := 0.001*FMBSize/1024; // in Kilobytes/1000 (0.001 is exactly one kilobyte)
    ASL.Add( Format( 'i=%03d Base=%8X Size=%8.3fMb', [i,FMBStart, Size] ));
    TotalSize := TotalSize + Size;
  end; // for i := 0 to High(AMemBlocks) do // along all Blocks

  ASL.Add( Format( '  NumBlocks=%3d TotalSize=%8.3fMb', [Length(AMemBlocks),TotalSize] ));
  ASL.Add( '' );
end; // procedure N_FreeMemBlocksInfo


//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_FreeMemBlocksDifInfo
//*********************************************** N_FreeMemBlocksDifInfo ***
// Get info about the difference of two given AMemBlocks
//
//     Parameters
// ASL         - given TStrings where to add Info
// AMemBlocks1 - given Array of Free Memory Blocks to compare and show
// AMemBlocks2 - given Array of Free Memory Blocks to compare and show
// AMode       - binary flags - what info is needed (now not used)
//
// Each Windows memory block is neighbour Windows Pages with exactly same status
//
procedure N_FreeMemBlocksDifInfo( ASL: TStrings; AMemBlocks1, AMemBlocks2: TN_FreeMemBlocks; AMode: integer );
var
  i, i1, i2, j1, j2: integer;
  TotalSize1, TotalSize2, Size: double;
  Buf1, Buf2: TStringList;
  Label ContMainLoop;

  function SameBlock( AP1, AP2: TN_PFreeMemBlock ): boolean; // local
  // compare to given Blocks, return True if they are the same
  begin
    Result := (AP1^.FMBStart = AP2^.FMBStart) and
              (AP1^.FMBStart = AP2^.FMBStart);
  end; // function SameBlock( AP1, AP2: TN_PFreeMemBlock ): boolean; // local

  procedure AddBlocks( ASL: TStrings; AMemBlocks: TN_FreeMemBlocks; APrefix: String; AIBeg, AIEnd: integer ); // local
  // add info about given blocks to ASL
  var
    i: integer;
  begin
    for i := AIBeg to AIEnd do
    with AMemBlocks[i] do
    begin
      Size := 0.001*FMBSize/1024; // in Kilobytes/1000 (0.001 is exactly one kilobyte)
      ASL.Add( Format( '%si=%03.3d Base=%8X Size=%08.3fMb', [APrefix,i,FMBStart, Size] ));
    end;
  end; // procedure AddBlocks - local

begin //********************** N_FreeMemBlocksDifInfo main body
  Buf1 := TStringList.Create;
  Buf2 := TStringList.Create;

  i1 := 0;
  i2 := 0;
  ASL.Add( '  Free Memory Blocks Difference:' );

  while True do // main Loop
  begin
    if i1 > High(AMemBlocks1) then // list the rest of AMemBlocks2 and finish
    begin
      AddBlocks( ASL, AMemBlocks2, '           (2)', i2, High(AMemBlocks2) );
      Break;
    end; // if i1 > Hight(AMemBlocks1) then // list the rest of AMemBlocks2 and finish

    if i2 > High(AMemBlocks2) then // list the rest of AMemBlocks1 and finish
    begin
      AddBlocks( ASL, AMemBlocks1, '  (1)', i1, High(AMemBlocks1) );
      Break;
    end; // if i2 > High(AMemBlocks2) then // list the rest of AMemBlocks1 and finish

    if SameBlock( @AMemBlocks1[i1], @AMemBlocks2[i2] ) then // same blocks
    begin
      Inc( i1 );
      Inc( i2 );
      Continue;
    end;

    //*** find first same Block

    for j1 := i1 to High(AMemBlocks1) do
    begin
      for j2 := i2 to High(AMemBlocks2) do
      begin
        if SameBlock( @AMemBlocks1[j1], @AMemBlocks2[j2] ) then // found first same Block (j1, j2)
        begin
          Buf1.Clear;
          AddBlocks( Buf1, AMemBlocks1, '  ', i1, j1-1 );

          Buf2.Clear;
          AddBlocks( Buf2, AMemBlocks2, '', i2, j2-1 );

          N_AddColumnToSL( Buf1, Buf2, 3, 0 );
          ASL.AddStrings( Buf1 );
          ASL.Add( '' );

          i1 := j1 + 1;
          i2 := j2 + 1;

          goto ContMainLoop; // i1, i2 are OK, Continue Main Loop
        end; // if SameBlock( @AMemBlocks1[j1], @AMemBlocks2[j2] ) then // found first same Block

        if AMemBlocks1[j1].FMBStart < AMemBlocks2[j2].FMBStart then Break; // to next j1 (just to speed up)
      end; // for j2 := i2 to High(AMemBlocks2) do
    end; // for j1 := i1 to High(AMemBlocks1) do

    // Here: all rest Blocks are different list them and finish

    Buf1.Clear;
    AddBlocks( Buf1, AMemBlocks1, '  ', i1, High(AMemBlocks1) );

    Buf2.Clear;
    AddBlocks( Buf2, AMemBlocks2, '', i2, High(AMemBlocks1) );

    N_AddColumnToSL( Buf1, Buf2, 3, 0 );
    ASL.AddStrings( Buf1 );

    Break;

    ContMainLoop: //************
  end; // while True do // main Loop

  TotalSize1 := 0;
  for i := 0 to High(AMemBlocks1) do // along all MemBlocks1
  with AMemBlocks1[i] do
  begin
    Size := 0.001*FMBSize/1024; // in Kilobytes/1000 (0.001 is exactly one kilobyte)
    TotalSize1 := TotalSize1 + Size;
  end; // for i := 0 to High(AMemBlocks1) do // along all MemBlocks1

  TotalSize2 := 0;
  for i := 0 to High(AMemBlocks2) do // along all MemBlocks2
  with AMemBlocks2[i] do
  begin
    Size := 0.001*FMBSize/1024; // in Kilobytes/1000 (0.001 is exactly one kilobyte)
    TotalSize2 := TotalSize2 + Size;
  end; // for i := 0 to High(AMemBlocks2) do // along all MemBlocks2

  ASL.Add( Format( 'Totaly: Free1=%.3fMb, Free2=%.3fMb, Diff=%.3fMb',
                               [TotalSize1,TotalSize2,TotalSize2-TotalSize1] ));
  ASL.Add( '' );
  Buf1.Free;
  Buf2.Free;
end; // procedure N_FreeMemBlocksDifInfo

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_DelphiHeapInfo
//******************************************************** N_DelphiHeapInfo ***
// Get info about Delphi Heap
//
//     Parameters
// ASL   - given TStrings where to add Info
// AMode - binary flags - what info is needed:
//#F
//    bit6($0040) - Delphi Memory usage (More info)
//    bit7($0080) - Delphi Memory usage (Main info, only Total Allocated, Free, Overhead)
//#/F
//
procedure N_DelphiHeapInfo( ASL: TStrings; AMode: integer );
var
  HeapStatus: THeapStatus;
begin
  if (AMode and $00C0) = 0 then Exit;

  HeapStatus := GetHeapStatus(); // Delphi Heap

  if (AMode and $0040) <> 0 then // show Delphi Memory usage (More info)
  with HeapStatus do
  begin
    ASL.Add( Format( ' Total Addr Space  = %13.0n bytes', [1.0*TotalAddrSpace] ) );
    ASL.Add( Format( ' Total Uncommitted = %13.0n bytes', [1.0*TotalUncommitted] ) );
    ASL.Add( Format( ' Total Committed   = %13.0n bytes', [1.0*TotalCommitted] ) );
    ASL.Add( Format( ' Total Overhead    = %13.0n bytes', [1.0*Overhead] ) );
  end; // show Delphi Memory usage (More info)

  if (AMode and $0080) <> 0 then // show Delphi Memory usage (Main Info)
  with HeapStatus do            // (only Total Allocated and Free)
  begin
    ASL.Add( Format( ' Total Allocated   = %13.0n bytes', [1.0*TotalAllocated] ) );
    ASL.Add( Format( ' Total Free        = %13.0n bytes', [1.0*TotalFree] ) );
  end; // show Delphi Memory usage (Main Info)

end; // procedure N_DelphiHeapInfo

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_PlatformInfo
//********************************************************** N_PlatformInfo ***
// Get Hardware and Software Platform Info to given StringsList
//
//     Parameters
// ASL   - StringsList for resulting Hardware and Software Platform Info
// AMode - binary flags - what info is needed:
//#F
//    bit0($0001) - Windows Version
//    bit1($0002) - Number of CPU and CPU frequency
//    bit2($0004) - several times from Process Start (abs,Ticks,CPUClocks,...)
//    bit3($0008) - not used
//    bit4($0010) - not used
//    bit5($0020) - Windows Memory usage
//    bit6($0040) - Delphi Memory usage (More info)
//    bit7($0080) - Delphi Memory usage (only Total Allocated, Free, Overhead)
//    bit8($0100) - Free Space on Disc Drives
//    bit9($0200) - Monitors and Screen DPI related Info
//#/F
//
// If AMode = 0 then only N_Win98 - N_WinWin7 variables are set. Application 
// will be aborted if not proper Windows version (now Win98) is detected.
//
procedure N_PlatformInfo( ASL: TStrings; AMode: integer );
var
  i, MajorVersion, MinorVersion, BuildNumber, DriveType: integer;
  DPIX, DPIY, SMPMSX, SMPMSY: integer;
  FreeSpaceAvailable, TotalSpace: int64;
  Str, OutFilesDir: string;
  MonitorName: String;
  ScreenHDC: HDC;
  MonitorInfo: TN_MONITORINFO;
  DEVMODE: TDEVMODE;
  WinMemStatus: MEMORYSTATUS;
  VersionInfo: OSVERSIONINFO;
  SystemInfo: TSystemInfo;
  Label NotProperVersion;
begin
  VersionInfo.dwOSVersionInfoSize := Sizeof(VersionInfo);
  GetVersionEx( VersionInfo );

  with VersionInfo do
  begin
    if dwPlatformId = VER_PLATFORM_WIN32s then // (=0) Win32s - error!
      goto NotProperVersion
    else if dwPlatformId = VER_PLATFORM_WIN32_WINDOWS then // (=1) at least Win32 on Windows95
    begin
      MajorVersion := dwBuildNumber shr 24;
      MinorVersion := (dwBuildNumber shr 16) and $FF;
      BuildNumber  := dwBuildNumber and $FFFF;
    end else // (=VER_PLATFORM_WIN32_NT =2) NT Platform
    begin
      MajorVersion := dwMajorVersion;
      MinorVersion := dwMinorVersion;
      BuildNumber  := dwBuildNumber;
    end;
  end; // with VersionInfo do

  N_Win98    := (MajorVersion = 4) and (MinorVersion >= 10); // Windows 98    or ME
  N_Win2K    := MajorVersion >= 5;                           // Windows 2000  or Later
  N_WinXP    := (MajorVersion >= 5) and (MinorVersion >= 1); // Windows XP    or Later
  N_WinVista := MajorVersion >= 6;                           // Windows Vista or Later
  N_WinWin7  := (MajorVersion >= 6) and (MinorVersion >= 1); // Windows 7     or Later

  if ASL = nil then Exit; // all done

  if (AMode and $0001) <> 0 then // show Windows Version
  begin
    Str := '???';

    if N_Win98 then
    begin
      if MinorVersion = 10 then Str := 'Windows 98'
                           else Str := 'Windows ME';
    end;

    if MajorVersion = 5 then
      case MinorVersion of
        0: Str := 'Windows 2000';
        1: Str := 'Windows XP';
        2: Str := 'Windows Server 2003';
      end;

    if MajorVersion = 6 then
      case MinorVersion of
        0: Str := 'Windows Vista (S2008)';
        1: Str := 'Windows 7 (S2008 R2)';
        2: Str := 'Windows 8';
      end;

    ASL.Add( Format( '%s (Ver %d.%d Build %d) %s',
            [Str, MajorVersion, MinorVersion, BuildNumber, VersionInfo.szCSDVersion] ));

  end; // if (AMode and $0001) <> 0 then // show Windows Version

  if (AMode and $0002) <> 0 then // show CPU Number and CPU Frequency
  begin
    GetSystemInfo( SystemInfo );
    ASL.Add( Format( 'CPU Frequency %.1f MHZ, number of CPU=%d',
                    [N_CPUFrequency/1.0e6,SystemInfo.dwNumberOfProcessors] ) );
  end; // if (AMode and $0002) <> 0 then // show CPU Number and CPU Frequency

  if (AMode and $0004) <> 0 then // several times from Process Start (abs,Ticks,CPUClocks,...)
  with N_PlatfInfoTimer do         // all times are in seconds (see N_PlatfInfoTimer)
  begin
    Stop(); // N_PlatfInfoTimer timer was started at Process Start and
            // you can stop it any number of times without starting again
            // because all variables, saved at Start, remain unchanged

    ASL.Add( 'Time from Process Start in seconds:' );
    ASL.Add( Format( '  RealTime    =%.8g,  TicsCounter =%.8g,',
                               [AbsTimeInSeconds, TicsTimeInSeconds] ));
    ASL.Add( Format( '  PerfCounter =%.8g,  CPUClocks   =%.8g,',
                               [PerfCounterInSeconds, CPUClockTimeInSeconds] ));
    ASL.Add( Format( '    UserTime=%g,  KernelTime=%g',
                               [ProcUserTimeInSeconds, ProcKernelTimeInSeconds] ));
  end; // if (AMode and $0004) <> 0 then // several times from Process Start

  if (AMode and $0020) <> 0 then // show Windows Memory usage
  begin
    WinMemStatus.dwLength := Sizeof( WinMemStatus );
    GlobalMemoryStatus( WinMemStatus );

    with WinMemStatus do
    begin
      ASL.Add( Format( '     %d%% - percents of memory in use', [dwMemoryLoad] ));
      ASL.Add( Format( '%8.1n - Megabytes of whole physical memory', [dwTotalPhys/(1024*1024)] ));
      ASL.Add( Format( '%8.1n - Megabytes of free  physical memory', [dwAvailPhys/(1024*1024)] ));
      ASL.Add( Format( '%8.1n - Megabytes of whole Paging file', [dwTotalPageFile/(1024*1024)] ));
      ASL.Add( Format( '%8.1n - Megabytes of free  Paging file', [dwAvailPageFile/(1024*1024)] ));
      ASL.Add( Format( '%8.1n - Megabytes of whole virtual memory', [dwTotalVirtual/(1024*1024)] ));
      ASL.Add( Format( '%8.1n - Megabytes of free  virtual memory', [dwAvailVirtual/(1024*1024)] ));
    end;
  end; // show Windows Memory usage

  //***** Add Info about Delphi Heap ($040 and $080 AMode bits)
  N_DelphiHeapInfo( ASL, AMode );

  if (AMode and $00100) <> 0 then // show Free Space on Disk Drives
  begin
    OutFilesDir := 'A:\';
    for i := Ord('C') to Ord('Z') do
    begin
      OutFilesDir[1] := Chr(i);
//      ASL.Add( Format( 'OutFilesDir %d %s', [i,OutFilesDir] )); // debug
//      lpSectorsPerCluster, lpBytesPerSector, lpNumberOfFreeClusters, lpTotalNumberOfClusters: DWORD;
//      N_b := GetDiskFreeSpace( @OutFilesDir[1], lpSectorsPerCluster, lpBytesPerSector,
//                               lpNumberOfFreeClusters, lpTotalNumberOfClusters );
      DriveType := GetDriveType( @OutFilesDir[1] );

      if DriveType <> 5 then // some times for CDROM drive Windows warning "There is no disk in drive" appears
        if GetDiskFreeSpaceEx( @OutFilesDir[1], FreeSpaceAvailable, TotalSpace, nil ) then
          ASL.Add( Format( 'Space on Disk %s: Available: %s, Total: %s', [OutFilesDir[1],
                            N_DataSizeToString(FreeSpaceAvailable), N_DataSizeToString(TotalSpace)] ) );
    end; // for i := Ord('C') to Ord('Z') do
  end; // if (AMode and $00100) <> 0 then // show Free Space on Disk Drives

  if (AMode and $00200) <> 0 then // Monitors and Screen DPI related Info
  begin
    ScreenHDC := windows.GetDC( 0 ); // windows Desktop handle
    DPIX := windows.GetDeviceCaps( ScreenHDC, LOGPIXELSX ); // Screen horizontal DPI for all monitores
    DPIY := windows.GetDeviceCaps( ScreenHDC, LOGPIXELSY ); // Screen vertical   DPI for all monitores
    windows.ReleaseDC( 0, ScreenHDC );

    // SMPMS - System Metrics Primary Monutor Size (affected by Virtual DPI settings)
    SMPMSX := windows.GetSystemMetrics( SM_CXSCREEN );
    SMPMSY := windows.GetSystemMetrics( SM_CYSCREEN );

    Str := Format( 'Win DPI=(%d,%d), SMPMS=(%d,%d), %d Monitor(s): ',
                          [DPIX,DPIY,SMPMSX,SMPMSY,Screen.MonitorCount] );
    ASL.Add( Str );

    for i := 0 to Screen.MonitorCount-1 do // along all Monitors
    with Screen.Monitors[i] do
    begin
      ZeroMemory( @MonitorInfo, SizeOf(MonitorInfo) );
      MonitorInfo.cbSize := SizeOf(MonitorInfo);
//      N_i := GetMonitorInfoA( Handle, @MonitorInfo ); // does not work - Invalid Monitor Handle
//      N_i1 := MonitorInfo.rcMonitor.Right;

      MonitorName := '\\.\Display' + IntToStr( i+1 );

//      N_b := windows.EnumDisplaySettings( @MonitorName[1], 0, DEVMODE );
//      N_b := windows.EnumDisplaySettings( @MonitorName[1], 1, DEVMODE );
      N_b := windows.EnumDisplaySettings( @MonitorName[1], $FFFFFFFF, DEVMODE ); // // ENUM_CURRENT_SETTINGS is -1?

      ASL.Add( Format( '  %d> P=%s WAR=%d %d %d %d, BR=%d %d %d %d, DS=%d %d', [i+1,N_B2S(Primary),
                 WorkareaRect.Left,WorkareaRect.Top,WorkareaRect.Right,WorkareaRect.Bottom,
                 BoundsRect.Left,BoundsRect.Top,BoundsRect.Right,BoundsRect.Bottom,
                 DEVMODE.dmPelsWidth, DEVMODE.dmPelsHeight ] ) );
    end; // for i := 0 to Screen.MonitorCount-1 do // along all Monitors

  end; // if (AMode and $00200) <> 0 then // show Monitors configuration

  Exit;

  NotProperVersion: //********************************************
  N_MessageDlg( 'You need at least Windows 98! ', mtConfirmation, [mbOK], 0 );
  Application.Terminate;
end; // end of procedure N_PlatformInfo
{$WARN SYMBOL_PLATFORM ON}
{$WARN SYMBOL_DEPRECATED ON}

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_DumpDPIRelatedInfo
//************************************************* N_DumpDPIRelatedInfo ***
// Dump Screen DPI Related Info to Dump1 or Dump2
//
//     Parameters
// AMode - where to dump (=1 to Dump1, =2 to Dump2)
//
procedure N_DumpDPIRelatedInfo( AMode: integer );
begin
  N_SL.Clear;
  N_PlatformInfo( N_SL, $0200 );

  if AMode = 1 then N_Dump1Strings( N_SL, 4 );
  if AMode = 2 then N_Dump2Strings( N_SL, 4 );

  N_SL.Clear;
end; // procedure N_DumpDPIRelatedInfo

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AddStrToFile
//********************************************************** N_AddStrToFile ***
// Add given Ansi string to N_DumpFileName file
//
//     Parameters
// AStr - given Ansi string
//
// Only low level Windows API is used
//
procedure N_AddStrToFile( AStr: AnsiString );
var
  BytesWritten, ResCode: DWORD;
  FH: THandle;
begin
  if Length(N_DumpFileName) = 0 then Exit; // Dump FileName is not specified

  FH := Windows.CreateFileA( @N_DumpFileName[1], GENERIC_WRITE or GENERIC_READ, 0,
            nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, FILE_FLAG_WRITE_THROUGH );

  if FH = INVALID_HANDLE_VALUE then Exit;

  ResCode := Windows.SetFilePointer( FH, 0, nil, FILE_END	);

  if ResCode <> $FFFFFFFF then // File Pointer was Set OK
  begin
    if Length(AStr) > 0 then
      N_b := Windows.WriteFile( FH, AStr[1], Length(AStr), BytesWritten, nil );
    N_b := Windows.WriteFile( FH, N_IntCRLF, 2, BytesWritten, nil );
  end;

  N_b := Windows.CloseHandle( FH );
end; // procedure N_AddStrToFile

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AddStrToFile2
//********************************************************* N_AddStrToFile2 ***
// Add given Ansi string to given file
//
//     Parameters
// AStr   - given Ansi string
// AFName - given Ansi File Name
//
// Only low level Windows API is used
//
procedure N_AddStrToFile2( AStr, AFName: AnsiString );
var
  BytesWritten, ResCode: DWORD;
  FH: THandle;
begin
  FH := Windows.CreateFileA( @AFName[1], GENERIC_WRITE or GENERIC_READ, 0,
            nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, FILE_FLAG_WRITE_THROUGH );

  if FH = INVALID_HANDLE_VALUE then Exit;

  ResCode := Windows.SetFilePointer( FH, 0, nil, FILE_END	);

  if ResCode <> $FFFFFFFF then // File Pointer was Set OK
  begin
    if Length(AStr) > 0 then
      N_b := Windows.WriteFile( FH, AStr[1], Length(AStr), BytesWritten, nil );
    N_b := Windows.WriteFile( FH, N_IntCRLF, 2, BytesWritten, nil );
  end;

  N_b := Windows.CloseHandle( FH );
end; // procedure N_AddStrToFile2

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_AddDateTimeToFile
//************************************************** N_AddDateTimeToFile ***
// Add empty string and current Date and Time to file, using N_AddStrToFile
//
// Only low level Windows API is used
//
procedure N_AddDateTimeToFile();
begin
  N_AddStrToFile( AnsiString( '****** ' + FormatDateTime( 'dd.mm.yyyy hh:nn:ss', Now() ) ) );
end; // procedure N_AddDateTimeToFile

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetDNTLSSize
//******************************************************* N_GetDNTLSSize ***
// Convert given AStrings To DNTLS - Double - Null-Terminated List of Strings
//
//     Parameters
// AStrings - given strings to analize
// Result   - return number of bytes needed for given AStrings as DNTLS
//
function N_GetDNTLSSize( AStrings: TStrings ): integer;
var
  i: integer;
begin
  Result := 2; // size of terminating double zero in chars

  for i := 0 to AStrings.Count-1 do // Calc Size in Chars including terminating zeros
    Result := Result + Length( AStrings[i] ) + 1;

  if SizeOf(Char) = 2 then // Wide Chars
    Result := 2 * Result;

end; // function N_GetDNTLSSize

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_ConvStringsToDNTLS
//************************************************* N_ConvStringsToDNTLS ***
// Convert given AStrings To DNTLS - Double - Null-Terminated List of Strings
//
//     Parameters
// AStrings - given strings to convert
// APDNTLS  - given pointer to resulting DNTLS
//
procedure N_ConvStringsToDNTLS( AStrings: TStrings; APDNTLS: Pointer );
var
  i, nzi, NumBytes: integer;
  CurPtr: TN_BytesPtr;
begin
  nzi := 0;
  CurPtr := TN_BytesPtr(APDNTLS);

  for i := 0 to AStrings.Count-1 do // along all given strings
  begin
    NumBytes := Length( AStrings[i] ) + 1;

    if SizeOf(Char) = 2 then // Wide Chars
      NumBytes := 2* NumBytes;

    if NumBytes > 0 then // AStrings[1] exists
      move( AStrings[i][1], CurPtr^, NumBytes ) // copy AStrings[i] and terminating zero
    else
      move( nzi, CurPtr^, NumBytes );

    Inc( CurPtr, NumBytes );
  end; // for i := 0 to AStrings.Count-1 do // along all given strings

  move( nzi, CurPtr^, 2*SizeOf(Char) ); // terminating double zero
end; // procedure N_ConvStringsToDNTLS

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetClipboardFormats
//************************************************ N_GetClipboardFormats ***
// Get all available Clipboard Formats as string
//
//     Parameters
// APar   - given value
// Result - Return ...
//
function N_GetClipboardFormats(): string;
var
  nf: integer;
  ResultOK: LongBool;
  Label Loop;
begin
  nf := 0;

  ResultOK := Windows.OpenClipboard( 0 );
  if not ResultOK then // Clipboard is locked
  begin
    Result := 'Clipboard is busy';
    Exit;
  end;

  Loop:
  nf := Windows.EnumClipboardFormats( nf );

  if nf > 0 then
  begin
    Result := Result + Format( ' %d (hex %x)', [nf,nf] );
    goto Loop;
  end else
  begin
    ResultOK := Windows.CloseClipboard();
    Assert( ResultOK, 'CloseClipboard (N_GetClipboardFormats) Error' );
  end;
end; // function N_GetClipboardFormats

function DragQueryFileA( AHDROP, AiFile: DWORD; APAStr: PAnsiChar; ASize: DWORD ): DWORD; stdcall; external 'shell32.dll' name 'DragQueryFileA';
function DragQueryFileW( AHDROP, AiFile: DWORD; APAStr: PWideChar; ASize: DWORD ): DWORD; stdcall; external 'shell32.dll' name 'DragQueryFileW';

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_GetFNamesFromClipboard
//********************************************* N_GetFNamesFromClipboard ***
// Get all full file names currently in Clipboard in CF_HDROP format
//
//     Parameters
// AStrings - resulting file names (on output)
// Result   - Return number of files names or < 0 if some errors
//
function N_GetFNamesFromClipboard( AFNames: TStrings ): integer;
var
  i: integer;
  NumFiles, ResCode: DWORD;
  CurFileName: string;
  ResultOK: LongBool;
  HMem: THandle;
  MemPtr: TN_BytesPtr;
begin
  AFNames.Clear;

//  AFNames.Add( 'File1' ); // debug
//  AFNames.Add( 'File2' );
//  N_CopyFNamesToClipboard( AFNames );

  Result := -1;
  ResultOK := Windows.OpenClipboard( 0 );
  if not ResultOK then Exit; // Result = -1,  Clipboard is locked

  HMem := Windows.GetClipboardData( CF_HDROP );

  if HMem <> 0 then // data in CF_HDROP format exist in Clipboard
  begin

    MemPtr := Windows.GlobalLock( HMem );
    if MemPtr = nil then
      raise Exception.Create( 'GlobalLock for *** !' + SysErrorMessage( GetLastError() ) );

//    N_i := PInteger(MemPtr)^;
//    N_i1 := PInteger(MemPtr+4)^;
//    N_i1 := PInteger(MemPtr+8)^;
//    N_i1 := PInteger(MemPtr+12)^;
//    N_i1 := PInteger(MemPtr+16)^;
//    SetLength( N_s, 500 );
//    Move( (MemPtr+N_i)^, N_s[1], 500 );

    SetLength( CurFileName, 2048 );
    NumFiles := DragQueryFileA( HMem, $FFFFFFFF, nil, 0 );

    if NumFiles = 0 then
    begin
      Result := 0; // no Raster in Clipboard
      Exit;
    end;

    for i := 0 to NumFiles-1 do
    begin
      if SizeOf(Char) = 2 then
        ResCode := DragQueryFileW( HMem, i, PWideChar(@CurFileName[1]), Length(CurFileName) )
      else // SizeOf(Char) = 1
        ResCode := DragQueryFileA( HMem, i, PAnsiChar(@CurFileName[1]), Length(CurFileName) );

      if (ResCode > 0) and (ResCode <= DWORD(Length(CurFileName))) then // use CurFileName
      begin
        AFNames.Add( Copy( CurFileName, 1, ResCode ) ); // ResCode is number of chars in CurFileName
        Result := i + 1;
        Continue; // to next file
      end else // some error
      begin
        Result := -2;
        Break;
      end;

    end; // for i := 0 to NumFiles-1 do

  end else // if HMem = 0, no data in CF_HDROP format exist in Clipboard
    Result := 0; // no File Names in Clipboard

  ResultOK := Windows.CloseClipboard();
  if not ResultOK then
    raise Exception.Create( 'CloseClipboard in N_GetClipboardFNames!' + SysErrorMessage( GetLastError() ) );

end; // function N_GetFNamesFromClipboard

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_CopyFNamesToClipboard
//********************************************** N_CopyFNamesToClipboard ***
// Put given file names to Clipboard in CF_HDROP format
//
//     Parameters
// AFNames - given file names
// Result  - Return number of files names or < 0 if some errors
//
// You can retrieve them from Clipboard by N_GetFNamesFromClipboard function
//
function N_CopyFNamesToClipboard( AFNames: TStrings ): integer;
var
  MemSize: Integer;
  ResultOK: LongBool;
  HMem, HMemTmp: THandle;
  MemPtr: TN_BytesPtr;
begin
  MemSize := SizeOf(TN_DROPFILES) + N_GetDNTLSSize( AFNames );
  HMem := Windows.GlobalAlloc( GMEM_MOVEABLE+GMEM_DDESHARE, MemSize );
  MemPtr := Windows.GlobalLock( HMem );

  if MemPtr = nil then
    raise Exception.Create( 'GlobalLock in N_CopyFNamesToClipboard Error ' + SysErrorMessage( GetLastError() ) );

  with TN_PDROPFILES(MemPtr)^ do // fill DROPFILES struct
  begin
    pFiles := 20; // offset of FilesList field
    pt     := Point( 0, 0 ); // drop point (dummy value)
    fNC    := 0; // Nonclient area flag
    if SizeOf(Char) = 2 then fWide := 1  // Wide Chars
                        else fWide := 0; // ANSI Chars

    N_ConvStringsToDNTLS( AFNames, @FilesList ); // Copy AFNames as DNTLS
  end; // with TN_PDROPFILES(MemPtr)^ do // fill DROPFILES struct

  Windows.GlobalUnlock( HMem );

  ResultOK := Windows.OpenClipboard( 0 );
  if not ResultOK then // Clipboard is locked
  begin
    Windows.GlobalFree( HMem );
    N_Dump1Str( 'Clipboard was locked in N_CopyFNamesToClipboard!' );
    Result := -2;
    Exit;
  end;

  Windows.EmptyClipboard();

  HMemTmp := Windows.SetClipboardData( CF_HDROP, HMem );
  if HMemTmp = 0 then
    raise Exception.Create( 'SetClipboardData (CF_HDROP) Error in N_CopyFNamesToClipboard!' + SysErrorMessage( GetLastError() ) );

  ResultOK := Windows.CloseClipboard();
  if not ResultOK then
    raise Exception.Create( 'CloseClipboard (CF_HDROP) Error in N_CopyFNamesToClipboard!' + SysErrorMessage( GetLastError() ) );

  Result := AFNames.Count;
end; // function N_CopyFNamesToClipboard

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_IntInSet
//*********************************************************** N_IntInSet ***
// Check if given integer belongs to given Set Of Integers
//
//     Parameters
// AInt        - given integer value to check
// APSetOfInts - given Set Of Integers
// Result      - Return True if given AInt belongs to given Set Of Integers
//
// Set Of Integers format (TN_PSetOfIntegers = PInteger): SOI[0] - number of 
// intervals in Set Of Integers SOI[1] - flags, not used now SOI[2] - first 
// interval min value SOI[3] - first interval max value ... ... SOI[2*n]   - 
// last interval min value ( n=SOI[0] ) SOI[2*n+1] - last interval max value
//
function N_IntInSet( AInt: integer; APSetOfInts: TN_PSetOfIntegers ): boolean;
var
  i, NumIntervals, MinVal: integer;
  PInt: PInteger;
begin
  PInt := PInteger(APSetOfInts);
  NumIntervals := PInt^;
  Inc( PInt, 2 );
  Result := True;

  for i := 1 to NumIntervals do // along all intevals in Set Of Integers
  begin
    MinVal := PInt^;
    Inc( PInt ); // to MaxVal
    if (AInt >= MinVal) and (AInt <= PInt^) then Exit; // found
    Inc( PInt ); // to next interval
  end; // for i := 1 to NumIntervals do // along all intevals in Set Of Integers

  Result := False; // AInt not in given Set Of Integers
end; // function N_IntInSet

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_WideLatStrToString
//************************************************* N_WideLatStrToString ***
// Pattern Function
//
//     Parameters
// APar   - given value
// Result - Return ...
//
function N_WideLatStrToString( AWideLatStr: WideString ): String;
//var
//  i: integer;
begin
  SetLength( Result, Length(AWideLatStr) );
end; // function N_WideLatStrToString

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_IndexOfWord
//******************************************************** N_IndexOfWord ***
// Get Index of given AVal in AWordArray or -1 if not found
//
//     Parameters
// AWordArray - given Array of Word
// AVal       - given value
// Result     - Return Index of given AVal in AWordArray or -1 if not found
//
function N_IndexOfWord( AWordArray: TN_WordArray; AVal: Word ): integer;
var
  i: integer;
begin

  for i := 0 to High(AWordArray) do
  begin
    if AWordArray[i] = AVal then
    begin
      Result := i;
      Exit;
    end;
  end; // for i := 0 to High(AWordArray) do

  Result := -1; // not found
end; // function N_IndexOfWord

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_IndexOfInteger
//***************************************************** N_IndexOfInteger ***
// Get Index of given AVal in AWordArray or -1 if not found
//
//     Parameters
// AWordArray - given Array of Word
// AVal       - given value
// Result     - Return Index of given AVal in AWordArray or -1 if not found
//
function N_IndexOfInteger( AIArray: TN_IArray; AVal: Integer ): integer;
var
  i: integer;
begin

  for i := 0 to High(AIArray) do
  begin
    if AIArray[i] = AVal then
    begin
      Result := i;
      Exit;
    end;
  end; // for i := 0 to High(AIArray) do

  Result := -1; // not found
end; // function N_IndexOfInteger

//##path N_Delphi\SF\N_Tree\N_Lib0.pas\N_DelphiVersion
//****************************************************** N_DelphiVersion ***
// Return Delphi Version as String
//
// *Delphi_Name  Conditional_Symbol  Compiler_Version (of type double) Delphi 
// XE6	VER270	27.0 Delphi XE5	VER260	26.0 Delphi XE4	VER250	25.0 Delphi 
// XE3	VER240	24.0 Delphi XE2	VER230	23.0 Delphi XE	VER220	22.0 Delphi 
// 2010	VER210	21.0 Delphi 2009	VER200	20.0 Delphi 2007 for NET	VER190	19.0 
// Delphi 2007	VER180 and VER185	18.0 and 18.5 Delphi 2006	VER180	18.0 Delphi 
// 2005	VER170	17.0 Delphi 8	VER160	16.0 Delphi 7	VER150 	15.0 Delphi 
// 6	VER140	14.0 Delphi 5	VER130	-- Delphi 4	VER120	-- Delphi 3	VER110	-- Delphi
// 2	VER90	  -- Delphi 1	VER80
//
function N_DelphiVersion(): String;
begin
  Result := 'Unknown';

  {$IFDEF VER270} // Delphi XE6
  Result := 'Delphi XE6';
  {$ENDIF VER270}

  {$IFDEF VER260} // Delphi XE5
  Result := 'Delphi XE5';
  {$ENDIF VER260}

  {$IFDEF VER230} // Delphi XE2
  Result := 'Delphi XE2';
  {$ENDIF VER230}

  {$IFDEF VER210} // Delphi 2010
  Result := 'Delphi 2010';
  {$ENDIF VER210}

  {$IFDEF VER150} // Delphi 7
  Result := 'Delphi 7';
  {$ENDIF VER150}

end; // function N_DelphiVersion

//************************************************************** N_Encript1 ***
// Encript given ASrcStr by D4W algorithm
//
function  N_Encript1( ASrcStr: AnsiString ): AnsiString;
var
  i: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  for i := 1 to Length(ASrcStr) do
  begin
    N_i1 := Integer(ASrcStr[i]);
    N_i2 := N_i1 * 750;
    N_s := Format( '%d', [N_i2] );
    SL.Add( N_s );
  end;
  Result := N_StringToAnsi(SL.CommaText);
  SL.Free;
end; // function  N_Encript1( ASrcStr: AnsiString ): AnsiString;

//************************************************************** N_Decript1 ***
// Decript given ASrcStr by D4W algorithm
//
function  N_Decript1( ASrcStr: AnsiString ): AnsiString;
var
  i, NumChars: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  SL.CommaText := N_AnsiToString(ASrcStr);
  NumChars := SL.Count;
  SetLength( Result, NumChars );
  for i := 1 to NumChars do
  begin
    N_s := SL[i-1];
    N_i1 := StrToInt( N_s );
    N_i2 := N_i1 div 750;
    Result[i] := AnsiChar( N_i2 )
  end;
  SL.Free;
end; // function  N_Decript1( ASrcStr: AnsiString ): AnsiString;

//*************************************************** N_GetFlushCountersStr ***
// Get Log Channels Flush counters
//
function N_GetFlushCountersStr() : string;
var
  i : Integer;
begin
  for i := 0 to High(N_LogChannels) do
    Result:= Result + format( ' %d=%d', [ i, N_LogChannels[i].LCFlashCounter] );
end; // function N_GetFlushCountersStr

//******************************************************** N_OnAppTerminate ***
// On Application Terminate
//
function N_OnAppTerminate () : Boolean;
begin
  Result := TRUE;
  N_Dump1Str( 'Application.Terminate FlushCounters' + N_GetFlushCountersStr() );
  N_LCExecAction( -1, lcaFlush );
end; // function N_OnAppTerminate

//****************************************************************** N_Func ***
// Pattern Function
//
//     Parameters
// APar   - given value
// Result - Return ...
//
function N_Func( APar: double ): integer;
var
  i: integer;
begin
  i := 0;
  N_i := i;

  Result := Round( APar );
end; // function N_Func

//***************************************************************** N_Proc ***
// Pattern procedure
//
//     Parameters
// APar   - given value
//
procedure N_Proc( APar: double );
var
  i: integer;
begin
  i := 0;
  N_i := i;
end; // procedure N_Proc


Initialization
  N_AddStrToFile( 'N_Lib0 Initialization start' );

  N_DumpGlobObj := TN_DumpGlobObj.Create;

  N_Dump1Str  := N_DumpGlobObj.GODump1Str;
  N_Dump2Str  := N_DumpGlobObj.GODump2Str;
  N_Dump2TStr := N_DumpGlobObj.GODump2TStr;
  N_DumpStr   := N_DumpGlobObj.GODumpStr;

  N_T1  := TN_CPUTimer1.Create;
  N_T1a := TN_CPUTimer1.Create;
  N_T1b := TN_CPUTimer1.Create;
  N_T1c := TN_CPUTimer1.Create;

  N_T2  := TN_CPUTimer2.Create( 20 );
  N_T2a := TN_CPUTimer2.Create( 30 );
  N_T2b := TN_CPUTimer2.Create( 30 );

  {
  N_T2.Items[0].TimerName := 'DrawNewLines1 ';
  N_T2.Items[1].TimerName := 'SetPenBrushAtr';
  N_T2.Items[2].TimerName := '';
  N_T2.Items[3].TimerName := 'UserPolyline  ';
  N_T2.Items[4].TimerName := 'DrawPath      ';
  N_T2.Items[5].TimerName := '';

  N_T2.Items[10].TimerName := 'ClipLine      ';
  N_T2.Items[11].TimerName := 'AffConvCoords ';
  N_T2.Items[12].TimerName := 'WinPolyline   ';

  N_T2a.Items[0].TimerName := '';
  N_T2a.Items[1].TimerName := 'UDFieldsDescr.GetDataFromSTBuf';
  N_T2a.Items[2].TimerName := 'K_GetDataFromSTBuf';
  N_T2a.Items[3].TimerName := 'RArray.GetFromSTBuf (not Empty)';
  N_T2a.Items[4].TimerName := 'parse atributes';
  N_T2a.Items[5].TimerName := 'St.nextToken';
  N_T2a.Items[6].TimerName := 'AttrList.Add';
  N_T2a.Items[7].TimerName := 'hasMoreTokens';
  N_T2a.Items[8].TimerName := 'UDBase.GetFromText';
  N_T2a.Items[9].TimerName := 'UDBase.GetChildsFromText';
  N_T2a.Items[10].TimerName := 'UDBase.LoadTreeFromTextFile';
  N_T2a.Items[11].TimerName := 'SBuf.LoadFromFile';
  N_T2a.Items[12].TimerName := 'K_BuildDirectReferences';
  N_T2a.Items[13].TimerName := 'SLSRLoadFromAnyFile';
  N_T2a.Items[14].TimerName := 'UDBase.GetChildFromText';
  N_T2a.Items[15].TimerName := 'UDBase.GetChildFromText(Tags)';
  N_T2a.Items[16].TimerName := 'UDBase.GetChildFromText(SelfOnly)';
  N_T2a.Items[17].TimerName := 'GetChilds-N*GetChild(1)';
  N_T2a.Items[18].TimerName := 'GetChilds-N*GetChild(2aGetTag)';

  N_T2a.Items[20].TimerName := 'node.GetFieldsFromText';
  N_T2a.Items[21].TimerName := 'GetChilds-N*GetChild(2)';
  N_T2a.Items[22].TimerName := 'GetChilds-N*GetChild(3)';
  N_T2a.Items[23].TimerName := 'STBuf.GetTagAttr(Empty)';
  N_T2a.Items[24].TimerName := 'STBuf.GetTagAttr(NotEmpty)';
  N_T2a.Items[25].TimerName := 'STBuf.GetTag';
  }

  N_CPUFrequency := N_GetCPUFrequency( 100 ); // N_T1 and N_T2 timers are used
  N_PlatfInfoTimer := TN_CPUTimer3.Create;
  N_PlatfInfoTimer.Start();

  N_TimersStack  := TList.Create;

  N_GlobObj := TN_GlobObj.Create;
//  N_Dump1Str  := N_GlobObj.GOEmptyDumpStr;
//  N_Dump2Str  := N_GlobObj.GOEmptyDumpStr;
//  N_Show1Str  := N_GlobObj.GOShow1Str;
//  N_Dump1TStr := N_GlobObj.GOEmptyDumpTStr;
//  N_Dump2TStr := N_GlobObj.GOEmptyDumpTStr;

  N_PBCaller := TN_ProgressBarCaller.Create;
  N_EnablePlainFile    := True;
  N_SkipShiftKeyIsDown := False;
  N_SkipCtrlKeyIsDown  := False;

  N_CFuncs := TN_CompFuncsObj.Create;

//{$IFDEF VER260} // Delphi XE5
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
{$WARN SYMBOL_PLATFORM OFF}
  N_WinFormatSettings := TFormatSettings.Create( GetUserDefaultLCID() );
{$WARN SYMBOL_PLATFORM ON}
{$ELSE}         // Delphi 7 or Delphi 2010
  GetLocaleFormatSettings( GetUserDefaultLCID(), N_WinFormatSettings );
{$IFEND CompilerVersion >= 26.0}

  N_AddStrToFile( 'N_Lib0 Initialization fin' );

Finalization
//  N_DumpGlobObj.Free;

end.
