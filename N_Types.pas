unit N_Types;
// Base Types definitions
//
// Interface section uses only Delphi units
// Implementation section is empty

//    ************* File Content  ******************
// Base NUMERICAL Types, Pointers and Arrays
// Base COORDS Types, Pointers and Arrays

// ... not documented yet ...

// CONSTANTS
// MS Office OLE Servers constants
// Global Variables
// Dummy objects, that can be used to avoid warnings and for debug

{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  {$DEFINE Delphi_GE_XE5}
{$IFEND}


interface
uses
{$IFDEF MSWindows}
  Windows,
{$ELSE}
  zstream,
{$ENDIF}

  Graphics, Classes, Controls, Stdctrls, Comctrls, Forms,
  Menus, ZLib, Dialogs, IniFiles;

const
  {$IFNDEF FPC}
    DirectorySeparator = '\';
  {$ELSE}
    DirectorySeparator = '/';
  {$ENDIF}

{$IFNDEF FPC} // Free Pascal Compiler
  {$IF SizeOf(Char) = 2} // Wide Chars (>= Delphi 2010)
    {$DEFINE CharSize2}
    N_CharSize = 2;
  {$IFEND}
{$ELSE} //
  N_CharSize = 1;
{$ENDIF}

//************* Delphi 7 and Delphi 2010 specific types

{$IFDEF CharSize2} // Wide Chars (>= Delphi 2010) Types and constants
  Type TN_BytesPtr  = PByte;  // Pointer to Bytes
  Type TN_Byte      = Byte;   // TN_BytesPtr^ type
  Type TN_PTwoChars = PDWORD; // Pointer to Two Wide Chars
var
  N_IntCRLF: DWORD = $000A000D;
{$ELSE} //*********** Ansi Chars (Delphi 7) Types and constants
  Type TN_BytesPtr  = PChar; // Pointer to Bytes
  Type TN_Byte      = Char;  // TN_BytesPtr^ type
  Type TN_PTwoChars = PWORD; // Pointer to Two Ansi Chars
var
  N_IntCRLF: WORD = $0A0D;
{$ENDIF}

{$IFDEF CharSize2} // Wide Chars (>= Delphi 2010)
{$ELSE} //*********** Ansi Chars (Delphi 7)
{$ENDIF}

{$IFDEF MSWindows}
{$ELSE}
{$ENDIF}

{$IFDEF N_VRE}
{$ELSE}
{$ENDIF}

//************* Base NUMERICAL Types, Pointers and Arrays ****************

type TN_Int1     = Shortint;   // signed byte (-128..127)
type TN_PInt1    = ^Shortint;  // pointer to signed byte (-128..127)
type TN_I1Array  = array of Shortint; // dynamic Array of signed bytes

type TN_CArray   = array of Char;        // dynamic Array of Char
type TN_C1Array  = array of AnsiChar;    // dynamic Array of AnsiChar
type TN_PAnsiCharArray = array of PAnsiChar; // dynamic Array of Pointers to Ansi Char
type TN_PPAnsiChar = ^PAnsiChar; // Pointer to Pointer to Ansi Char
type TN_PPWChar    = ^PWChar;    // Pointer to Pointer to Wide Char

type TN_UInt1    = Byte;       // unsigned byte (0..255)
type TN_PUInt1   = ^Byte;      // pointer to byte (0..255)
type TN_PByte    = ^Byte;      // pointer to byte (0..255)
type TN_UI1Array = array of Byte;  // dynamic Array of bytes
type TN_BArray   = array of Byte;  // dynamic Array of bytes
type TN_PBArray  = ^TN_BArray;
type TN_APBArray = array of TN_PByte; //  dynamic Array of Pointers to bytes

type TN_Int2     = Smallint;   // small (16bit) int (–32768..32767)
type TN_PInt2    = ^Smallint;  // pointer to small (16bit) int (–32768..32767)
type TN_I2Array  = array of Smallint; // dynamic Array of small (16bit) ints

type TN_UInt2    = Word;     // unsigned small int (0..65535)
type TN_PUInt2   = ^Word;    // pointer to unsigned small int (0..65535)
type TN_UI2Array = array of Word;  // dynamic Array of unsigned small (16bit) ints
type TN_WordArray = array of Word; // dynamic Array of unsigned small (16bit) ints

type TN_IArray   = array of integer;   // dynamic Array of integers
type TN_AIArray  = array of TN_IArray; // dynamic Array of Array of integer
type TN_PIArray  = ^TN_IArray;

type UInt4       = Longword;   // unsigned integer ( 32 bit, 0..4294967295	)
type TN_UInt4    = Longword;   // unsigned integer ( 32 bit, 0..4294967295	)
type TN_PUInt4   = ^Longword;  // pointer to unsigned integer (32 bit)
type TN_UI4Array = array of integer; // dynamic Array of unsigned integers

type TN_Int8     = Int64;  // very long integer (64 bit)
type TN_PInt8    = ^Int64; // pointer to very long integer (64 bit)
type TN_I8Array  = array of Int64; // dynamic Array of very long integer
type TN_I64Array = array of Int64; // dynamic Array of very long integer

type float       = single; // float, 32 bit, 7-8 digits, 1.5*10^–45..3.4*10^38)
type PFloat      = ^float;  // pointer to 32 bit float (same as Delphi PDouble)
type TN_FArray   = array of float;       // dynamic Array of 32 bit floats
type TN_AFArray  = array of TN_FArray;   // dynamic Array of Array of floats
type TN_PFArray  = ^TN_FArray;


type TN_DArray   = array of double;      // dynamic Array of doubles
type TN_PDArray  = array of PDouble;     // dynamic Array of pointers to doubles
type TN_ADArray  = array of TN_DArray;   // dynamic Array of Array of doubles

type TN_PPointer = ^pointer;             // pointer to Pointer
type TN_PArray   = array of pointer;     // dynamic Array of pointers


type TN_PPArray  = array of TN_PPointer; // dynamic Array of pointers to Pointer

type TN_SArray   = array of string;      // dynamic Array of strings
type TN_SLArray  = array of TStringList;
type TN_ASArray  = array of TN_SArray;   // dynamic Array[i,j] of strings

type TN_S1Array  = array of AnsiString;  // dynamic Array of ANSI strings
//type TN_PS1Array = ^AnsiString;          // dynamic Array of ANSI strings

type TN_PSArray  = array of PString;     // dynamic Array of pointers to string
type TN_AObjects = array of TObject ;    // dynamic Array of TObject

type TN_PtrToSArray = ^TN_SArray;        // pointer to dynamic Array of strings

//************* Base COORDS Types, Pointers and Arrays ****************

type PIPoint = ^TPoint;             // pointer to integer coords Point
type TN_IPArray  = array of TPoint; // dynamic Array of integer Point coords

type TFPoint = record  // Float Point coords
    X, Y: float;       //  (float analog of TPoint type)
end; //*** end of type TFPoint = record
type PFPoint = ^TFPoint;            // pointer to float coords Point
type TN_FPArray = array of TFPoint; // dynamic Array of float coords Points
type TN_AFPArray = array of TN_FPArray; // Array of Array of float Point coords

type TDPoint = record  // Double Point coords
    X, Y: double;      //  (double analog of TPoint type)
end; //*** end of type TDPoint = record
type PDPoint = ^TDPoint;            // pointer to double  coords Point
type TN_DPArray = array of TDPoint; // dynamic Array of double  Point coords
type TN_ADPArray = array of TN_DPArray; // Array of Array of double Point coords

type TRectS = record // integer Rect as UpperLeft coords and Sizes
  case Integer of
    0: (Left, Top, Width, Height: integer);
    1: (TopLeft, Size: TPoint);
end; // type TRectS = record // integer Rect as UpperLeft coords and Sizes
type TN_IRSArray  = array of TRectS;  // dynamic Array of integer RectS

type PIRect  = ^TRect;              // pointer to integer coords Rect
type TN_IRArray  = array of TRect;  // dynamic Array of integer Rect  coords
type TN_AIRArray = array of TN_IRArray; // Array of Array of integer Rect coords
type TN_PIRArray = array of PIRect; // Array of Pointers to integer Rects

type TFRect = record  // Float Rectangle coords
  case Integer of     // (float analog of TRect type)
    0: (Left, Top, Right, Bottom: float);
    1: (TopLeft, BottomRight: TFPoint);
end; //*** end of type TFRect = record
type PFRect = ^TFRect;  // pointer to float   coords Rect
type TN_FRArray = array of TFRect;  // dynamic Array of float   Rect  coords

type TDRect = record  // Double Rectangle coords
  case Integer of     // (double analog of TRect type)
    0: (Left, Top, Right, Bottom: double);
    1: (TopLeft, BottomRight: TDPoint);
end; //*** end of type TDRect = record
type PDRect = ^TDRect;  // pointer to double  coords Rect
type TN_DRArray = array of TDRect;  // dynamic Array of double  Rect  coords
type PTStrings  = ^TStrings;  // Pointer to TStrings


//************* Other Types, Pointers and Arrays ****************

type TN_StrIRS = record // One String and one TRectS
  Str: String;
  IRS: TRectS;
end; //*** end of type TN_StrIRS = record
type TN_SIRSArray  = array of TN_StrIRS; // dynamic Array of One String and one TRectS

type TN_StrInt = record SIStr: string; SIInt: integer end;
type TN_UObjType = ( uotReference, uotOneLevelClone, uotSubTreeClone );
type TN_FillBorderMode = ( fbmNotDefined, // not defined
                           fbmNotFill,    // do not fill at all
                           fbmZero,       // fill by Zero
                           fbmConst,      // fill by some Constant
                           fbmRepl1,      // fill by Replicating nearest pixel
                           fbmReplAll,    // fill by Replicating all pixels
                           fbmMirror      // by Mirroring all pixels
                          );

type TN_PSetOfIntegers = PInteger;

//************* Coords Related Types ****************

type TN_AdjustAspectMode = ( aamNoChange, aamIncRect, aamDecRect, aamSwapDec );

type TN_AffCoefs4 = packed record  //***** four affine transform coefs
    CX, SX: double; // Xdst := CX*Xsrc + SX;
    CY, SY: double; // Ydst := CY*Ysrc + SY;
end; //*** end of type TN_AffCoefs4 = record
type TN_PAffCoefs4 = ^TN_AffCoefs4;
type TN_AC4Array = array of TN_AffCoefs4;

type TN_AffCoefs6 = packed record  //***** six affine transform coefs
    CXX, CXY, SX: double; // Xdst := CXX*Xsrc + CXY*Ysrc + SX;
    CYX, CYY, SY: double; // Ydst := CYX*Xsrc + CYY*Ysrc + SY;
end; //*** end of type TN_AffCoefs6 = record
type TN_PAffCoefs6 = ^TN_AffCoefs6;

type TN_AffCoefs8 = packed record  //***** eight projective transform coefs
    CXX, CXY, SX, WX: double; // Xdst := (CXX*Xsrc + CXY*Ysrc + SX)/(WX*Xsrc + WY*Ysrc + 1);
    CYX, CYY, SY, WY: double; // Ydst := (CYX*Xsrc + CYY*Ysrc + SY)/(WX*Xsrc + WY*Ysrc + 1);
end; //*** end of type TN_AffCoefs8 = record
type TN_PAffCoefs8 = ^TN_AffCoefs8;

type TN_3DPReper = packed record //***** Three Double Points Reper
  P1, P2, P3: TDPoint;
end; // type TN_3DPReper = packed record
type TN_P3DPReper = ^TN_3DPReper;

type TN_3PReper = packed record //***** Three (Integer) Points Reper
  P1, P2, P3: TPoint;
end; // type TN_3PReper = packed record
type TN_P3PReper = ^TN_3PReper;

type TN_CTransfType = ( ctfNoTransform, ctfFlipAlongX, ctfFlipAlongY,
                        ctfRotate90CCW, ctfRotate90CW, ctfRotateAnyAngle );

type TN_HVAlign     = ( hvaBeg, hvaCenter, hvaEnd,  hvaJustify,
                        hvaUniform, hvaUniformBeg );

type TN_OLEDocType  = ( odtNotDef, odtWord, odtExcel );

type TN_FormVisFlags = Set Of ( // Form Visiblility Flags used in N_MakeFormVisible
  fvfWhole,   // Whole Form should be visible (be inside Desktop)
  fvfCenter,  // Form should be centered in Desktop

  fvfRectForm,    // Current Main Form Rect (N_MainModalForm Client Rect)
  fvfRectMonitor, // Current Monitor (where is N_MainModalForm) WorkArea Rect
  fvfRectAppWAR,  // N_AppWAR Rect
  fvfMaximize,    // Maximize  in given Rect
  fvfShiftAll,    // minimal Shift in given Rect so that All Form is inside
  fvfShiftPart    // minimal Shift in given Rect so that only part of Form is inside
                  // (absence of fvfShift... flags means that Form should be Centered in given Rect)
);


type TN_RectSizePosFlags = Set Of ( // Rect Size and Position Flags used in ...
//  fvfWhole,   // Whole Form should be visible (be inside Desktop)
//  fvfCenter,  // Form should be centered in Desktop

  rspfMFRect,     // Main Form Rect (N_MainModalForm envelope Rect), N_MainFormRect
  rspfCurMonWAR,  // Current Monitor (where is N_MainModalForm) WorkArea Rect, N_CurMonWAR
  rspfPrimMonWAR, // Primary Monitor WorkArea Rect, N_PrimMonWAR
  rspfAppWAR,     // Application  WorkArea Rect, N_AppWAR
  rspfMaximize,   // Maximize  in given Rect
  rspfCenter,     // Center in given Rect
  rspfShiftAll,   // minimal Shift in given Rect so that All Form is inside it
  rspfShiftPart   // minimal Shift in given Rect so that only part of Form is inside it
);

type TN_BFFlags = Set Of ( // Base Form Flags
  bffOldStyle,     // OldStyle Resize and Alignment
  bffSkipBFResize, // skip TN_BaseForm FormCanResize and FormResize handlers
  bffToDump1,      // Dump several self coords using N_Dump1Str procedure
  bffToDump2,      // Dump several self coords using N_Dump2Str procedure
  bffDumpPos       // Dump self Position coords using N_Dump1Str procedure
); // type TN_BFPFlags = Set Of ( // Base Form Params Flags

type TN_RESOURCEHEADER = packed record // Windows RESOURCEHEADER
  DataSize:    Integer;
  HeaderSize:  Integer;
  TYPE0:       WORD;
  TYPE1:       WORD;
  NAME0:       WORD;
  NAME1:       WORD;
  DataVersion: DWORD;
  MemoryFlags: WORD;
  LanguageId:  WORD;
  Version:     DWORD;
  Characteristics: DWORD;
end; // type TN_RESOURCEHEADER = packed record // Windows RESOURCEHEADER


//************* Some Objects types  ****************

type PObject = ^TObject;
type PForm   = ^TForm;

type TN_AnyClass = Class of TObject;


//************* PROCEDURES and FUNCTIONS types  ****************

type TN_Proc              = procedure(); // procedure with no params
type TN_OneIntProc        = procedure( AInt: integer ); // procedure with one Integer param

type TN_ProcObj           = procedure() of object; // procedure of object with no params
type TN_IntFuncObj        = function (): Integer of object;
type TN_NoParamsProcObj   = procedure() of object; // procedure of object with no params
type TN_OneIntProcObj     = procedure( AInt: integer ) of object;
type TN_OneDoubleProcObj  = procedure( ADbl: double  ) of object;
type TN_OneStrProcObj     = procedure( AStr: string  ) of object;
type TN_OnePtrProcObj     = procedure( APtr: Pointer ) of object;

type TN_OnePtrFuncObj     = function ( APtr: Pointer ): boolean of object;

type TN_TwoIntsProcObj    = procedure( AInt1, AInt2: integer ) of object;
type TN_ThreeIntsProcObj  = procedure( AInt1, AInt2, AInt3: integer ) of object;
type TN_OneIOneSProcObj   = procedure( AInt: integer; AStr: string ) of object;
type TN_COneIOneSProcObj  = procedure( const AInt: integer; const AStr: string ) of object;
//type TN_CIntStr2IntProcObj= procedure( const AInt1: integer; const AStr: string; const AInt2: Integer ) of object;
type TN_AWStrsProcObj     = procedure( AAnsiStr: string; AWideStr: WideString ) of object;
type TN_TwoDoublesProcObj = procedure( ADbl1, ADbl2: double ) of object;
type TN_TwoPtrsProcObj    = procedure( APtr1, APtr2: Pointer ) of object;
type TN_ThreePtrsProcObj  = procedure( APtr1, APtr2, APtr3: Pointer ) of object;
type TN_FourPtrsProcObj   = procedure( APtr1, APtr2, APtr3, APtr4: Pointer ) of object;

type TN_OneDOneIProcObj   = procedure( ADbl: double; AInt: integer ) of object;
type TN_OneITwoDProcObj   = procedure( AInt: integer; ADbl1, ADbl2: double ) of object;
type TN_OneObjProcObj     = procedure( Sender: TObject ) of object;
type TN_TwoFPointsProcObj = procedure( AP1, AP2: TFPoint ) of object;
type TN_BinaryDumpProcObj = function ( AInstStr: string; AMemPtr: Pointer; AMemSize: integer ): Boolean of object;
//type TN_StringDumpProcObj = procedure( AInstStr: string; AString: string ) of object;
//type TN_StringsDumpProcObj= function ( AInstStr: string; AStrings: TStrings ): Boolean of object;

type TN_StrFuncObjInt     = function( AInt: Integer ): String of object;
type TN_BoolFuncObj2Ptr   = function( APtr1, APtr2: Pointer ): Boolean of object;
type TN_FuncDPD           = function( const Arg: double;  PCoefs: PDouble ): double;
type TN_FuncConvDP        = function( const ASrcDP: TDPoint; PParams: Pointer ): TDPoint;
type TN_FuncConvDP3       = function( const ASrcDP: TDPoint; PParams1: Pointer;
                                        PParams2: Pointer = nil; PParams3: Pointer = nil ): TDPoint;
type TN_ConvDPFuncObj     = function( const ASrcDP: TDPoint; PParams: Pointer = nil ): TDPoint of object;
type TN_MessageDlgFunc    = function( AMsg: string; ADlgType: TMsgDlgType; AButtons: TMsgDlgButtons;
                                        AHelpCtx: integer = 0; ACaption: string = '' ): integer;

//***************** stdcall ExtDLL functions types:
// all ExtDLL functions should have TN_cdecl prefix (see below) except ImageLibrary !

type TN_stdcallProcVoid          = procedure ( ); stdcall;
type TN_stdcallProcPAChar        = procedure ( APAChar: PAnsiChar ); stdcall;
type TN_stdcallIntFuncInt        = function ( AInt: Integer ): integer; stdcall;
type TN_stdcallIntFuncIntPtr     = function ( AInt: Integer; APtr: Pointer ): integer; stdcall;
type TN_stdcallIntFuncInt2Ptr    = function ( AInt: Integer; APtr1, APtr2: Pointer ): integer; stdcall;
type TN_stdcallIntFuncInt2PtrInt = function ( AInt: Integer; APtr1, APtr2: Pointer; AInt2: integer ): integer; stdcall;
type TN_stdcallIntFunc2IntPtr    = function ( AInt1, AInt2: Integer; APtr: Pointer ): integer; stdcall;
type TN_stdcallIntFunc2Int2Ptr   = function ( AInt1, AInt2: Integer; APtr1, APtr2: Pointer ): integer; stdcall;
type TN_stdcallIntFuncPAChar     = function ( APAChar: PAnsiChar ): integer; stdcall;
type TN_stdcallIntFuncPAChar2Int = function ( APAChar: PAnsiChar; AInt1, AInt2: Integer ): integer; stdcall;
type TN_stdcallIntFuncPWChar     = function ( APWChar: PWChar ): integer; stdcall;
type TN_stdcallIntFuncPWChar2Int = function ( APWChar: PWChar; AInt1, AInt2: Integer ): integer; stdcall;
type TN_stdcallIntFuncPtrInt     = function ( APtr: Pointer; AInt: Integer ): integer; stdcall;
type TN_stdcallIntFunc2PtrInt    = function ( APtr1, APtr2: Pointer; AInt: Integer ): integer; stdcall;
type TN_stdcallIntFunc5Ptr       = function ( APtr1, APtr2, APtr3, APtr4, APtr5: Pointer ): integer; stdcall;
type TN_stdcallIntFunc2PDblInt   = function ( APDouble1, APDouble2: PDouble; AInt: Integer ): integer; stdcall;

type TN_stdcallProcPtr           = procedure( APtr: Pointer ); stdcall;
type TN_stdcallProcIntPtr        = procedure( Int: Integer; Ptr: Pointer ); stdcall;
type TN_stdcallProc2Ptr          = procedure( Ptr1: Pointer; Ptr2: Pointer ); stdcall;
type TN_stdcallProcPtrIntPtr     = procedure( Ptr1: Pointer; Int: Integer; Ptr2: Pointer ); stdcall;
type TN_stdcallProcConstPtr      = procedure( const APtr: Pointer ); stdcall;
type TN_stdcallPtrFuncInt3Ptr    = function ( AInt: integer; APtr1: Pointer; APtr2: Pointer; APtr3: Pointer ): Pointer; stdcall;
type TN_stdcallBoolFuncPtr       = function ( APtr: Pointer ): Boolean; stdcall;
type TN_stdcallIntFuncPtr        = function ( Ptr: Pointer ): Integer; stdcall;
type TN_stdcallPtrFunc2Ptr       = function ( Ptr1: Pointer; Ptr2: Pointer ):
                                                               Pointer; stdcall;
type TN_stdcallBoolFunc2Ptr      = function ( Ptr1: Pointer; Ptr2: Pointer ): Boolean; stdcall;
type TN_stdcallPtrFuncIntCBP2PtrInt = function ( AInt1: integer; ACBP: TN_stdcallProcPtr; APtr2: Pointer; APtr3: Pointer; AInt2: integer ): Pointer; stdcall;
type TN_stdcallPtrFuncIntCBP2Ptr    = function ( AInt1: integer; ACBP: TN_stdcallProcPtr; APtr2: Pointer; APtr3: Pointer): Pointer; stdcall;
type TN_stdcallInt2FuncVar1         = function ( AInt2_1, AInt2_2, AInt2_3, AInt2_4, AInt2_5: TN_Int2;
                   APChar1: PAnsiChar; AInt: Integer; APChar2: PAnsiChar; APWChar1, APWChar2: PWideChar;
                   APChar3: PAnsiChar; APInt2: TN_PInt2 ): TN_Int2; stdcall;

{ prev types for wrapdcm.dll
//type TN_stdcallProcPtrInt                = procedure( Ptr: Pointer; Int: Integer ); stdcall;
//type TN_stdcallPtrFunc4PWChar            = function ( const APWChar1, APWChar2, APWChar3, APWChar4 : PWideChar ) : Pointer; stdcall;
//type TN_stdcallPtrFuncPWCharBool         = function ( const APWChar1 : PWideChar; ABool : Boolean ) : Pointer; stdcall;
//type TN_stdcallUInt2FuncPtrUIntUInt2     = function ( const APtr: Pointer; AUUnt4 : TN_UInt4; AUInt2 : TN_UInt2 ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2FuncPtrUIntInt2      = function ( const APtr: Pointer; AUUnt4 : TN_UInt4; AInt2 : TN_Int2 ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2FuncPtrUIntPWChar    = function ( const APtr: Pointer; AUUnt4 : TN_UInt4; APWchar : PWideChar ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2Func2PtrUInt         = function ( const APtr1, APtr2: Pointer; AUUnt4 : TN_UInt4 ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2FuncPtrUInt          = function ( const APtr: Pointer; AUUnt4 : TN_UInt4 ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2FuncPtr2PWChar       = function ( const APtr: Pointer; APWChar1, APWChar2 : PWideChar ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2FuncPtrUIntPWChar2Ptr= function ( const APtr: Pointer; AUUnt4 : TN_UInt4; APWChar : PWideChar; APtr1, Aptr2 : Pointer ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2FuncPtrUIntIntUIntPWChar2Ptr = function ( const APtr: Pointer; AUUnt4 : TN_UInt4; AInt : Integer; AUUnt42 : TN_UInt4; APWChar : PWideChar; APtr1, Aptr2 : Pointer ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2FuncPtrUIntPWCharPtr = function ( const APtr: Pointer; AUUnt4 : TN_UInt4; APWchar : PWideChar; APtr1 : Pointer ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2FuncPtr              = function ( const APtr1: Pointer ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2FuncPtrPWCharInt     = function ( const APtr: Pointer; APWchar : PWideChar; AInt : Integer ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2FuncPtrUInt3Ptr      = function ( const APtr: Pointer; AUUnt4 : TN_UInt4; APtr1, Aptr2, APtr3 : Pointer ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2FuncPtrUInt2Ptr      = function ( const APtr: Pointer; AUUnt4 : TN_UInt4; APtr1, Aptr2 : Pointer ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2Func3Ptr             = function ( const APtr, APtr1, Aptr2 : Pointer ) : TN_UInt2; stdcall;

//type TN_stdcallPtrFuncPWChar             = function ( const APWChar: PWideChar ) : Pointer; stdcall;
//type TN_stdcallUIntFuncPtr               = function ( const APtr1: Pointer ) : TN_UInt4; stdcall;
//type TN_stdcallPtrFuncPtrInt             = function ( const APtr1: Pointer; AInt : Integer ) : Pointer; stdcall;
//type TN_stdcallPtrFuncPWCharInt2PWChar   = function ( const APtr1: Pointer; AInt : Integer; const APW1, APW2 : PWideChar ) : Pointer; stdcall;
//type TN_stdcallPtrFuncPWCharInt4PWChar   = function ( const APtr1: Pointer; AInt : Integer; const APW1, APW2, APW3, APW4 : PWideChar ) : Pointer; stdcall;
//type TN_stdcallPtrFuncPWCharInt2PWCharInt= function ( const APtr1: Pointer; AInt : Integer; const APW1, APW2 : PWideChar; AInt1 : Integer ) : Pointer; stdcall;
//type TN_stdcallUInt2FuncPtrInt6PWChar    = function ( const APtr1: Pointer; AInt : Integer; const APW1, APW2, APW3, APW4, APW5, APW6 : PWideChar ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2FuncPtrInt6PWChar4PUint2Ptr=function ( APtr1: Pointer; AInt : Integer; const APW1, APW2, APW3, APW4, APW5, APW6 : PWideChar; APUS1, APUS2, APUS3, APUS4 : TN_PUInt2; APtr2 : Pointer ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2Func2Ptr             = function ( const APtr1, APtr2: Pointer ) : TN_UInt2; stdcall;
//type TN_stdcallUInt2FuncPtr7PWChar       = function ( const APtr1: Pointer; const APW1, APW2, APW3, APW4, APW5, APW6, APW7 : PWideChar ) : TN_UInt2; stdcall;
//type TN_stdcallPtrFunc                   = function ( ) : Pointer; stdcall;
//type TN_stdcallUInt2FuncPWCharUInt22PWChar = function ( APWchar : PWideChar; AUInt2: TN_UInt2; APWChar2, APWChar3 : PWideChar ) : TN_UInt2; stdcall;
}

//***************** cdecl ExtDLL functions types:
// all ExtDLL functions except ImageLibrary should have TN_cdecl prefix!

type TN_cdeclProcVoid             = procedure (); cdecl;
type TN_cdeclByteFuncVoid         = function  (): Byte; cdecl;
type TN_cdeclProc1Byte            = procedure ( AByte: Byte ); cdecl;
type TN_cdeclProc3Byte            = procedure ( AByte1, AByte2, AByte3: Byte ); cdecl;
type TN_cdeclProcInt              = procedure ( AInt: Integer ); cdecl;
type TN_cdeclIntFuncVoid          = function ( ): integer; cdecl;
type TN_cdeclIntFuncInt           = function ( AInt: Integer ): integer; cdecl;
type TN_cdeclIntFuncAStr          = function ( AAnsiStr: AnsiString ): Integer; cdecl;
type TN_cdeclIntFuncPInt2         = function ( APInt2: TN_PInt2 ): integer; cdecl;
type TN_cdeclIntFuncPAChar        = function ( APAChar: PAnsiChar ): integer; cdecl;
type TN_cdeclIntFuncPAChar3Int    = function ( APAChar: PAnsiChar; AInt1, AInt2, AInt3: Integer  ): integer; cdecl;
type TN_cdeclIntFunc2PAChar       = function ( APAChar1, APAChar2: PAnsiChar ): integer; cdecl;
type TN_cdeclIntFunc2Ptr          = function ( APtr1, APtr2: Pointer ): integer; cdecl;
type TN_cdeclIntFunc3Ptr3Int      = function ( APtr1, APtr2, APtr3: Pointer; AInt1, AInt2, AInt3: Integer ): integer; cdecl;
type TN_cdeclIntFunc4Int          = function ( AInt1, AInt2, AInt3, AInt4: Integer ): integer; cdecl;
type TN_cdeclIntFuncPIntInt       = function ( APInt: PInteger; AInt: integer ): integer; cdecl;
type TN_cdeclIntFunc2PAChar1Int   = function ( APAChar1, APAChar2: PAnsiChar; AInt: integer ): integer; cdecl;
type TN_cdeclIntFuncPWChar        = function ( APWChar: PWChar ): integer; cdecl;
type TN_cdeclIntFuncPWCharInt     = function ( APWChar: PWChar; AInt: Integer ): integer; cdecl;
type TN_cdeclDblFuncDbl           = function ( ADbl: Double ): Double; cdecl;
type TN_cdeclIntFuncPPWChar       = function ( APPWChar: TN_PPWChar ): integer; cdecl;
type TN_cdeclIntFuncIntPPWChar    = function ( AInt: Integer; APPWChar: TN_PPWChar ): integer; cdecl;
type TN_cdeclIntFuncIntPAChar     = function ( AInt: Integer; APAChar: PAnsiChar ): integer; cdecl;
type TN_cdeclIntFunc2IntPAChar    = function ( AInt1, AInt2: Integer; APChar: PAnsiChar ): integer; cdecl;
type TN_cdeclIntFuncPCharPInt     = function ( APBuf: TN_BytesPtr; APInt: PInteger ): integer; cdecl;
type TN_cdeclPACharFuncVoid       = function ( ): PAnsiChar; cdecl;
type TN_cdeclPWCharFuncIntPWChar  = function ( AInt: Integer; APWChar: PWChar ): PWChar; cdecl;
type TN_cdeclIntFuncVariant1      = function ( AInt1, AInt2: Integer; APChar: PAnsiChar; APInt: PInteger ): integer; cdecl;
//type TN_cdeclIntFuncVariant2      = function ( APWChar: PWChar; AInt: Integer; APInt: PInteger ): integer; cdecl;

type TN_cdeclInt2FuncVoid         = function ( ): TN_Int2; cdecl;
type TN_cdeclInt2FuncInt2         = function ( AInt2:  TN_Int2 ): TN_Int2; cdecl;
type TN_cdeclInt2FuncPInt2        = function ( APInt2: TN_PInt2 ): TN_Int2; cdecl;
type TN_cdeclInt2FuncPInt2PInt    = function ( APInt2: TN_PInt2; APInt: PInteger ): TN_Int2; cdecl;
type TN_cdeclInt2Func3Int2_6PInt2 = function ( AInt2_1, AInt2_2, AInt2_3: TN_Int2; APInt2_1, APInt2_2, APInt2_3, APInt2_4, APInt2_5, APInt2_6: TN_PInt2 ): TN_Int2; cdecl;
type TN_cdeclInt2FuncPByte6Int2   = function ( APByte: PByte; AInt2_1, AInt2_2, AInt2_3, AInt2_4, AInt2_5, AInt2_6: TN_Int2  ): TN_Int2; cdecl;
type TN_cdeclInt2FuncVariant3     = function ( AInt2:  TN_Int2; APChar: PAnsiChar; APInt2_1, APInt2_2, APInt2_3, APInt2_4, APInt2_5: TN_PInt2 ): TN_Int2; cdecl;
type TN_cdeclInt2FuncVariant4     = function ( APChar: PAnsiChar; APInt2: TN_PInt2; AInt2: TN_Int2 ): TN_Int2; cdecl;
type TN_cdeclDWordFuncVoid        = function (): DWord; cdecl;

type TN_cdeclPtrFuncInt           = function ( AInt: Integer ): Pointer; cdecl;
type TN_cdeclIntFuncPtrInt        = function ( APtr: Pointer; AInt: Integer ): Integer; cdecl;

type TN_cdeclInt64FuncInt         = function ( AInt: Integer ): Int64; cdecl;

type TN_cdeclProcFloat            = procedure ( AFloat: Float ); cdecl;
type TN_cdeclProc2Ptr             = procedure ( APtr1:  Pointer; APtr2: Pointer ); cdecl;
type TN_cdeclProc3WordAnsiChar    = procedure ( AWord1: Word; AWord2: Word; AWord3: Word; AAnsiChar: AnsiChar); cdecl;
type TN_cdeclPtrFuncVoid          = function  (): Pointer; cdecl;
type TN_cdeclPtrFuncPtr           = function  ( APtr: Pointer ): Pointer; cdecl;
type TN_cdeclIntFuncPtr           = function  ( APtr: Pointer ): Integer; cdecl;
type TN_cdeclIntFuncInt2Ptr       = function  ( AInt: Integer; APtr1: Pointer; APtr2: Pointer ): Integer; cdecl;
type TN_cdecl4IntFuncInt          = function  ( AInt1: Integer; AInt2: Integer; AInt3: Integer; AInt4: Integer ): Integer; cdecl;
type TN_cdeclIntFunc2IntPtr       = function  ( AInt1: Integer; AInt2: Integer; APtr: Pointer): Integer; cdecl;
type TN_cdeclIntFuncIntPtr        = function  ( AInt: Integer; APtr: Pointer ): Integer; cdecl;

//***************** cdecl functions and procedures types for wrapdcm.dll
type TN_cdeclGetWindowsDIB        = function ( const APtr: Pointer; WindowWidth: Integer; WindowCenter: Integer; APtr2: Pointer; AUUnt4: TN_UInt4): TN_UInt2; cdecl;
type TN_cdeclGetDIBSize           = function ( const APtr: Pointer): Integer; cdecl;
type TN_cdeclProcPtrInt           = procedure( Ptr: Pointer; Int: Integer ); cdecl;
type TN_cdeclPtrFunc4Ptr          = function ( const APWChar1, APWChar2, APWChar3, APWChar4 : Pointer ) : Pointer; cdecl;
type TN_cdeclUInt2Func3Ptr        = function ( const APtr, APtr1, Aptr2 : Pointer ) : TN_UInt2; cdecl;
type TN_cdeclUInt2FuncPtr         = function ( const APtr1: Pointer ) : TN_UInt2; cdecl;
type TN_cdeclPtrFuncPtrInt        = function ( const APtr1: Pointer; AInt : Integer ) : Pointer; cdecl;
type TN_cdeclUInt2Func2PtrInt     = function ( const APtr, APWchar : Pointer; AInt : Integer ) : TN_UInt2; cdecl;
type TN_cdeclUInt2FuncPtrUIntUInt2= function ( const APtr: Pointer; AUUnt4 : TN_UInt4; AUInt2 : TN_UInt2 ) : TN_UInt2; cdecl;
type TN_cdeclUInt2FuncPtrUIntInt2 = function ( const APtr: Pointer; AUUnt4 : TN_UInt4; AInt2 : TN_Int2 ) : TN_UInt2; cdecl;
type TN_cdeclUInt2FuncPtrUIntPtr  = function ( const APtr: Pointer; AUUnt4 : TN_UInt4; APWchar : Pointer ) : TN_UInt2; cdecl;
type TN_cdeclUInt2Func2PtrUInt    = function ( const APtr1, APtr2: Pointer; AUUnt4 : TN_UInt4 ) : TN_UInt2; cdecl;
type TN_cdeclUInt2FuncPtrUInt     = function ( const APtr: Pointer; AUUnt4 : TN_UInt4 ) : TN_UInt2; cdecl;
type TN_cdeclUInt4FuncPtrUInt     = function ( const APtr: Pointer; AUUnt4 : TN_UInt4 ) : TN_UInt4; cdecl;
type TN_cdeclUInt2FuncPtrUInt3Ptr = function ( const APtr: Pointer; AUUnt4 : TN_UInt4; APWChar, APtr1, Aptr2 : Pointer ) : TN_UInt2; cdecl;
type TN_cdeclUInt2FuncPtrUIntIntUInt3Ptr = function ( const APtr: Pointer; AUUnt4 : TN_UInt4; AInt : Integer; AUUnt42 : TN_UInt4; APWChar, APtr1, Aptr2 : Pointer ) : TN_UInt2; cdecl;
type TN_cdeclUInt2FuncPtrUInt2Ptr = function ( const APtr: Pointer; AUUnt4 : TN_UInt4; APtr1, Aptr2 : Pointer ) : TN_UInt2; cdecl;
type TN_cdeclUIntFuncPtr          = function ( const APtr1: Pointer ) : TN_UInt4; cdecl;
type TN_cdeclPtrFuncPtrInt2PtrInt = function ( const APtr1: Pointer; AInt : Integer; const APW1, APW2 : Pointer; AInt1 : Integer ) : Pointer; cdecl;
type TN_cdeclUInt2FuncPtrInt6Ptr  = function ( const APtr1: Pointer; AInt : Integer; const APW1, APW2, APW3, APW4, APW5, APW6 : Pointer ) : TN_UInt2; cdecl;
type TN_cdeclUInt2FuncPtrInt11Ptr = function ( APtr1: Pointer; AInt : Integer; const APW1, APW2, APW3, APW4, APW5, APW6, APUS1, APUS2, APUS3, APUS4, APtr2 : Pointer ) : TN_UInt2; cdecl;
type TN_cdeclPtrFuncPtrInt2Ptr    = function ( const APtr1: Pointer; AInt : Integer; const APW1, APW2 : Pointer ) : Pointer; cdecl;
type TN_cdeclProcPtr              = procedure( APtr: Pointer ); cdecl;
type TN_cdeclPtrFuncPtrInt4Ptr    = function ( const APtr1: Pointer; AInt : Integer; const APW1, APW2, APW3, APW4 : Pointer ) : Pointer; cdecl;
type TN_cdeclUInt2Func2Ptr        = function ( const APtr1, APtr2: Pointer ) : TN_UInt2; cdecl;
type TN_cdeclUInt2Func8Ptr        = function ( const APtr1, APW1, APW2, APW3, APW4, APW5, APW6, APW7 : Pointer ) : TN_UInt2; cdecl;
type TN_cdeclPtrFunc              = function ( ) : Pointer; cdecl;
type TN_cdeclInt4Func15PtrUInt2Ptr = function ( const APW1, APW2, APW3, APW4, APW5, APW6, APW7, APW8, APW9, APW10, APW11, APW12, APW13, APW14, APW15 : Pointer; AI : TN_UInt4; APV1, APV2 : Pointer ) : Integer; cdecl;
//************* Delphi Event Hadlers Proc of Obj Types *************

//type TN_MouseEventProcObj = procedure( ASender: TObject; AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer ) of object;
type TN_aKeyEventProcObj   = procedure( ASender: TObject; var AKey: Word; AShift: TShiftState ) of object;


//**************************  SETS AND ENUMS  ************************

type TN_ModalModeFlag = ( mmfNotModal, mmfModal );
type TN_VCTSizeType   = ( vstNotGiven, vstmm, vstPix );

type TN_TextEncoding  = ( // Text Encoding modes (*.txt file formats)
  teAuto,    // 0 Auto mode: while decoding try to recognize original mode; while encoding - teANSI for Delphi 7, teUTF8 for Delphi 2010
  teANSI,    // 1 ANSI, one byte per character
  teUTF8,    // 2 Unicode UTF-8 (from one to three bytes per character)
  teUTF16LE, // 3 Unicode UTF-16LE, two bytes per character little-endian (Delphi WideString format)
  teUTF16BE, // 4 Unicode UTF-16BE, two bytes per character big-endian     - now not implemented
  teUTF32LE, // 5 Unicode UTF-32LE, four bytes per character little-endian - now not implemented
  teUTF32BE  // 6 Unicode UTF-32BE, four bytes per character big-endian    - now not implemented
  ); // type TN_TextEncoding  = ( // Text Encoding modes (*.txt file formats)

type TN_RadUnits = ( ruNone, ruPercent, ruLLW, ruUser, rumm );
// rounding Radius Units:
// ruNone    - not given, all Radiuses assumed to be 0
// ruPercent - Percents (100 means half of whole Panel Width or Height)
// ruLLW     - LLW Units
// ruUser    - User Coords Units
// rumm      - millimeters

type TN_DVectorType = ( dvtInteger, dvtFloat, dvtDouble, dvtString, dvtFPoint );
type TN_Orientation = ( orVertical, orHorizontal );
type TN_ExPixFmt    = ( epfBMP, epfGray8, epfGray16, epfColor48, epfColor64, epfAutoAny, epfAutoGray );
// epfBMP      - Windows Bitmap with proper PixFmt
// epfGray8    -  8 bits per pixel Gray  data without palette, PixFmt=pfCustom
// epfGray16   - 16 bits per pixel Gray  data without palette, PixFmt=pfCustom
// epfColor48  - 48 bits per pixel Color data without palette, PixFmt=pfCustom
// epfColor64  - 64 bits per pixel Color data without palette, PixFmt=pfCustom
// epfAutoAny  - used as PrepEmptyDIBObj input value only - set any ExPixFmt by DIBInfo
// epfAutoGray - used as PrepEmptyDIBObj input value only - set epfGray8 or epfGray16 by DIBInfo

type TN_ConcatFlags = Set Of ( // Concatenation Flags used in N_ConcatenateSArray
  cfUseExcelDelim,    // Use Excel Delimiter; "," if Decimal separator is "." or ";" otherwise
  cfQuoteEmptyTokens  // Quote Empty Tokens
  ); // type TN_ConcatFlags = Set Of ( // Concatenation Flags used in N_ConcatenateSArray

type TN_CopyShiftMode = ( // Copy and Shift mode in N_Conv2SMCopyShift procedure
  csmNotDef,      // Not Defined
  csmShiftRight,  // Shift to the Right (decrease NumBits)
  csmShiftLeft,   // Shift to the Left (increase NumBits)
  csmShiftLeftOr, // Shift to the Left and OR with highest Src bits
  csmShiftAuto1   // define Shift Size and mode automaticly, variant #1
    );

//**************************  COMPLEX STRUCTURES  ************************

type TN_RGBColor = packed record // four bytes - RGB Color Components
  Red:       Byte; // Low byte of integer ($0000FF)
  Green:     Byte; //  ($00FF00)
  Blue:  TN_UInt2; // Two high bytes of integer ($FF0000), (only one byte is used)
end; // type TN_RGBColor = packed record
type TN_PRGBColor = ^TN_RGBColor;

type TN_BitMaskDescr = packed record // Bit Mask Description (one Bit per Pixel Mask)
  BMDSize:       TPoint; // Bit Mask X,Y Sizes in pixels, Y can be < 0 as Bitmap Height
  BMDRowLength: integer; // Bit Mask Row Length in bytes
  BMDShift:      TPoint; // Bit Mask origin shift in pixels
  BMDPBits: TN_BytesPtr; // pointer to Bit Mask elements
end; // type TN_BitMaskDescr = packed record
type TN_PBitMaskDescr = ^TN_BitMaskDescr;

{$IFDEF MSWindows}
type TN_LogPalette = packed record //****** Windows LogPalette (my var)
  case Integer of
    0: (Header: TLogPalette; PalColors: Array[1..255] of integer; ); // First Pal Entry is in Header record - Header.palPalEntry
    1: (
         palVersion: Word;    // should be = $300
         palNumEntries: Word; // number of Palette Entries
         palEntries: Array[0..255] of integer; // All Palette entries
       );
end; // type TN_LogPalette = packed record
{$ENDIF}

type TN_CompareFunc = function ( const CompParam: integer; const Ptr1, Ptr2: TN_BytesPtr ): integer;
type TN_CompFuncOfObj = function ( Ptr1, Ptr2: Pointer ): integer of object;
type TN_SameFuncOfObj = function ( Ptr1, Ptr2: Pointer ): boolean of object;
type TN_OnChangeColorProc = procedure ( AColor: integer );

//***************** Drawing attributes ******************************

// TN_ColorSizeAttr   = packed record // just Color and Size in LLW
// TN_NormLineAttr    = packed record // Normal Line Attributes
// TN_PointAttr1      = packed record // Point Attributes #1
// TN_PixRectAttr1    = packed record // Pixel Rect Attributes #1
// TN_SysLineAttr    = packed record // Sys Line (with Vertexes) Attributes

type TN_ColorSizeAttr = packed record //***** just Color and Size in LLW
  Color: integer;
  Size: float;
end; // type TN_ColorSizeAttr = packed record
type TN_CSAArray = array of TN_ColorSizeAttr;
type TN_PColorSizeAttr = ^TN_ColorSizeAttr;

type TN_NormLineAttr = packed record //***** Normal Line Attributes
  Color: integer;
  Size: float;
end; // type TN_NormLineAttr = packed record
type TN_NLAArray = array of TN_NormLineAttr;
type TN_PNormLineAttr = ^TN_NormLineAttr;

type TN_StrPosParams = packed record // String Position Params
  SPPShift:    TFPoint; // String HotPoint X,Y Shift in LLW
  SPPHotPoint: TFPoint; // HotPoint relative Coords in %
  SPPBLAngle:  float;   // String Base Line Angle in dergee
end; // type TN_StrPosParams
type TN_PStrPosParams = ^TN_StrPosParams;

type TN_StandartShape = set of ( sshATriangle, sshVTriangle,
                                 sshRect, sshRomb, sshEllipse,
                                 sshPlus, sshCornerMult, sshEllMult,
                                 sshDummy1 ); // now two bytes!

type TN_PointAttr1 = packed record //***** Point Attributes #1
  SShape: TN_StandartShape;
  SReserved1: Byte;  // for allignment
  SReserved2: Byte;  // for allignment
  SBrushColor: integer;   // not used in cross and rotated cross Sign Shapes
  SPenColor:  integer;    // used for all Sign Shapes
  SPenWidth:  float;      // border and cross lines Width in LLW
  SPenStyle:  integer;    // Pen Style WinGDI flags
  SSizeXY:   TFPoint;     // X,Y sizes in LSU
  SShiftXY:  TFPoint;     // X,Y shifts in LSU
  SHotPoint: TFPoint;     // Hot Point position in Norm. coords,
                          // ( (0,0)-UpperLeft corner, (0.5,0.5)-Center )
end; // type TN_PointAttr1 = packed record
type TN_PPointAttr1 = ^TN_PointAttr1;

type TN_PixRectAttr1 = packed record //***** Pixel Rect Attributes #1
  ModeFlags: integer; // drawing mode flags:
    // bits0-3($00F) - border position:
    //  =0 - inside Rect
    //  =1 - on the Rect edge (inside and outside Rect)
    //  =2 - outside Rect
    // bits3-7($0F0) - fill style:
    //  =$010 - fill by FillColor
    //  =$020 - fill by Bitmap (given by PBMP pointer)
  Border: TN_NormLineAttr; // border attributes
  ABShift: float;           // additional Border in LLW (shift outside if > 0)
  FillColor: integer;       // Fill Color
  FillBMP: TBitmap;         // Fill Bitmap
end; // type TN_PixRectAttr1 = packed record
type TN_PPixRectAttr1 = ^TN_PixRectAttr1;

type TN_SysLineAttr = packed record //***** Sys Line (with Vertexes) Attributes
  AtLASColor: integer;  // Line All Segments Color
  AtLASWidth: float;    // Line All Segments Width (in LLW)
  AtLBSColor: integer;  // Line Beg Segment (first half) Color
  AtLBSWidth: float;    // Line Beg Segment (first half)Width (in LLW)
  AtLAV: TN_PointAttr1; // Line All Vertexes attributes
  AtLBV: TN_PointAttr1; // Line Beg Vertex   attributes
end; // type TN_SysLineAttr = packed record
type TN_PSysLineAttr = ^TN_SysLineAttr;

type TN_GradFillAttr1 = packed record //***** Gradient Fill Rect Attributes #1
  Dummy1: integer;
end; // type TN_GradFillAttr1 = packed record
type TN_PGradFillAttr1 = ^TN_GradFillAttr1;

type TN_OneDashAttr = packed record //***** one Dash Attributes (for Dashed Lines)
  DashSize:       float;   // Dash Size in LLW units
  DashColor:      integer; // Dash Color (N_EmptyColor for gaps)
  DashWidth:      float;   // Dash Width in LLW units
  DashAngleStyle: integer; // Dash AngleStyle
end; // type TN_OneDashAtr = packed record
type TN_DashAttribs = array of TN_OneDashAttr;
type TN_POneDashAttr = ^TN_OneDashAttr;

type TN_DashLineAttr = packed record // Dash Line Attributes
  DashCount: integer;       // number of DashDashAttr records
  DashLoopInd: integer;     // Dash index for looping
  DashHeaderCount: integer; // number of Dashes in Header
  DashOffset:      float;   // Offset (0-1) - part of Header
  DashAttr: TN_OneDashAttr; // first Dash Attributes
end;
type TN_PDashLineAttr = ^TN_DashLineAttr;

type TN_HatchAttr = packed record //***** one Hatched Lines set of Attributes
  LineType: integer;  // =0 - Solid Line, =1 - Dashed Line
  LineStep:   float;  // distance between Lines in LLW units
  LineOffs:   float;  // Base Line offset in LLW units
  LineAngle:  float;  // Line Angle in Grad. (90 - vertical lines)
  case Integer of     // Separate Fields for Simple (0) and Dashed (1) Lines
    0: ( LineWidth:  float;  // Line Width in LLW units
         LineColor: integer; // Line Color
       );
    1: ( BegDashInd: integer; // Beg Dash Attr Index
         NumDashes:  integer; // Number of Dashes
       );
end; // type TN_HatchAttr = packed record
type TN_HatchAttribs = array of TN_HatchAttr; // used in Hatched Lines Library

type TN_PenFlagsFields = packed record // Pen Flags as several Fields for editing in RAFrame
  PFFStyle: byte;
  PFFNotUsed1: byte;
  PFFEndCap: byte;
  PFFLineJoin: byte;
  PFFType: byte;
end; // type TN_PenFlagsFields = packed record

type TN_MinMaxValues = packed record // Min and Max Values
  MMVMinValue: double;
  MMVMaxValue: double;
end; // type TN_MinMaxValues = packed record
type TN_PMinMaxValues = ^TN_MinMaxValues;

type TN_SplineLineFlags = Set Of ( slfDum1 );
type TN_SplineLineType  = ( sltDoNotSpline, sltCatmullRom );

type TN_FillParams = packed record // Fill Path params
  FPColor:   integer; // Fill Color
  FPPattern: integer; // Fill Pattern index
end; // type TN_FillParams

type TN_SplineLineParams = packed record // Params for "Splaining" Polyline
  SLPType:  TN_SplineLineType;   // Spline Type
  SLPFlags: TN_SplineLineFlags;  // Spline Flags
  SLPReserved1: byte; // for alignment
  SLPReserved2: byte; // for alignment
  SLPJoinAngle: float;  // all Join Angles in resulting Line should be less then given
  SLPNumNewInSegm: integer; // Number of New Points in each segment of source Line
end; // type TN_SplineLineParams = packed record
type TN_PSplineLineParams = ^TN_SplineLineParams;

type TN_CompCoordsType = ( cctUser, cctLSU, cctmm, cctPix, cctPercent );
//    Component Coords Type (Coords Units)
// cctUser    - Self User Coords (CompP2U,U2P, just for simplicity)
// cctLSU     - LSU units from UpperLeft corner of Coords Scope
// cctmm      - millimeters from UpperLeft corner of Coords Scope
// cctPix     - pixels from UpperLeft corner of Coords Scope
// cctPercent - percents of Coords Scope

type TN_CoordsConvFlags = Set of ( ccfConvSize,
                                   ccfSelfScope, ccfParentScope, ccfRootScope );
//    Coords Convertion Flags ( used in UDCompVis.ConvToPix )
// ccfConvSize - Convertion of Size (distance, Scope Origin does not matter),
//               if not set - Convertion of Position (pixel Coord, counting Scope Origin)
// ccfSelfScope   - Coords Scope is Self.CompIntPixRect
// ccfParentScope - Coords Scope is DynParent.CompIntPixRect
// ccfRootScope   - Coords Scope is DstPixRect

type TN_FileAttribs = class( TObject ) // used in File search/delete procedures
  public
  FullName: string;
  AttrFlags: integer;
  BSize: integer;
  DTime: TDateTime;
end; // type TN_FileAttribs = class( TObject )

type TK_StringsDataFormat = (K_sdfCSV, K_sdfTab, K_sdfGap1, K_sdfGap3 );
type TN_StrMatrFormat = ( smfCSV, smfTab, smfClip, smfSpace1, smfSpace3 );

type TN_CRGType = ( crgtEnd, crgtColor, crgtX1Y1X2Y2, crgtX1X2 ); // Color Rects Group Type

type TN_TextFileEncoding  = ( tfeANSI, tfeUTF8, tfeUTF16, tfeISO_8955_1, tfeWin1251 );

type TN_File1TypeFlags = set of ( ftfEncryped, ftfHasCRC, ftfWritePlain,
                                  ftfUseBuffer, ftfWriteGZIP );

type TN_File1OpenFlags = set of ( fofForcePlain, fofEnablePlain, fofNotPlain,
                                  fofSkipException, fofForceGZIP );

type TN_File1Params = packed record // Params for using File1 procedures
  F1PFileFlags: TN_File1TypeFlags;  // Flags, saved in File
  F1POpenFlags: TN_File1OpenFlags;  // File Open Flags
  F1PComprLevel: TCompressionLevel; // ZLib Compression level
  F1PReserved1: byte;
  F1PUserSign: string;              // User Signature
  F1PPasWord:  string;              // Password
end; // type TN_File1Params = packed record
type TN_PFile1Params = ^TN_File1Params;

type TN_ExtRastFilePar = packed record // Extended Raster File Params
  ERFResDPI:      TFPoint;  // X,Y Resolutions in DPI
  ERFTranspColor: integer;  // GIF Files Trasparent Color
  ERFQuality:     integer;  // JPEG Files Quality (Compression level) from 1 to 100
  ERFComprLevel:  integer;  // if >= 0 use compressed emz and svgz format for emf and svg
  ERFFile1: TN_File1Params; // Params for using File1 procedures
end; // type TN_ExtRastFilePar = packed record
type TN_PExtRastFilePar = ^TN_ExtRastFilePar;

type TN_MainCExpMode    = ( mcemNotCoords, mcemCoords, mcemGDI );
type TN_GDITargetType   = ( gttMemObj, gttClipBoard, gttFile, gttPrinter );
type TN_GDIFormatType   = ( gftRaster, gftEMF, gftEMFPlus );
type TN_ImageFileFormat = ( imffByFileExt, imffBMP, imffGIF, imffJPEG, imffEMF,
                            imffSVG, imffVML, imffUnknown );


//!!! DIBDataFormat Enum Elements for BMP GIF JPEG TIF PNG should have the same order as GDI+ Image Mime Types enumeration
type TN_UDDIBDataFormat = ( uddfNotDef, uddfBMP, uddfGIF, uddfJPEG, uddfTIF, uddfPNG,
                            uddfDIBSer0, uddfDIBSer1, uddfDIBSer2, uddfDIBSer3 );

type TN_ImageFilePar = packed record // Image (Raster or EMF) File Params
  IFPImFileFmt: TN_ImageFileFormat; // Image File Format
  IFPPixFmt: TPixelFormat;          // Pixel format (1,8,16,24,32 bits per pixel)
  IFPReserved1: byte;   // for alignment
  IFPReserved2: byte;   // for alignment
  IFPSizePix:     TPoint;    // Size in Pixels
  IFPSizemm:      TFPoint;   // Size in millimeters
  IFPResDPI:      TFPoint;   // X,Y Resolutions in DPI
  IFPTranspColor: integer;   // Trasparent Color (for GIF and monochrome Files)
  IFPJPEGQuality: integer;   // JPEG Quality (Compression level) from 1 to 100
  IFPComprLevel:  integer;   // if >= 0 use compressed emz format for emf
  IFPVisPixRect:  TRect;     // Visible Rect, (0,IFPSizePix-1) for whole Image
end; // type TN_ImageFilePar = packed record
type TN_PImageFilePar = ^TN_ImageFilePar;

type TN_TextFilePar = packed record // Text File Params
  TFPRowLength: integer;
  TFPEncoding:  TN_TextFileEncoding;
  TFPStr1:      string; // String Param used while Exporting (now used for HTMLMap)
  TFPHeader:    string; // File Header (with possible $0D0A)
  TFPIntType:  integer; // File integer type
  TFPPatFName:  string; // Pattern File Name
end; // type TN_TextFilePar = packed record
type TN_PTextFilePar = ^TN_TextFilePar;

type TK_RAFGlobalAction = ( K_fgaApplyToAll, K_fgaCancelToAll, K_fgaOKToAll,
                            K_fgaOK, K_fgaNone);
type TK_RAFGlobalActionProc = function ( Sender : TObject; ActionType : TK_RAFGlobalAction ) : Boolean of object;

type TN_NewValueType = ( nvtInteger, nvtFloat, nvtDouble );
type TN_OneValueType = ( ovtNotDef, ovtInteger, ovtFloat, ovtDouble );

type TN_UpdateValsInfo = record
  ApplyToAll: boolean;
  DeltaMode:  boolean;
  ValOffset:  integer;
  ValType: TN_OneValueType;
  ValsPrevData: TDRect;
  NumVals: integer;
end; // type TN_UpdateValsInfo = record
type TN_PUpdateValsInfo = ^TN_UpdateValsInfo;

type TN_FileExtType  = ( fetNotDef, fetPlainText, fetRichText, fetPicture, fetHTML );
type TN_FileExtFlags = set of ( fefText, fefRichText, fefGDIPict, fefInet,
                                fefWord, fefExcel, fefSVG, fefCompressed );

type TN_RAFillNumFuncType = ( fnftDebug, fnftZero, fnftLinear, fnftPower, fnftSinDegree );

type TN_RAFillNumParams = packed record // params for Filling and Updating RArray
                                        // of Numbers (Integer, Float or Double)
  FNRAddMode:   byte; // if <> 0 then Add calculated Value (else - Set)
  FNRFuncType: TN_RAFillNumFuncType; // Fill Function Type
  FNRReserved1: byte; // for alignment
  FNRReserved2: byte;

  FNRBegIndex:  integer; // First Index of RArray to Fill
  FNRNumValues: integer; // Number of elements in RArray to Fill
  FNRBegFunc:   double;  // Minimal Function Value (Beg Value for fnftLinear)
  FNREndFunc:   double;  // Maximal Function Value (End Value for fnftLinear)

  FNRNoiseVal:  double;  // Max Noise(random) Value to add
  FNRShiftVal:  double;  // Const Value to add
  FNRMultCoef:  double;  // Multiplication coef (last operation after all other calculations)
  FNRNumDigits: integer; // Rounding Accuracy (number of decimal digits)

  FNRPowerCoef: double;  // Power Coef. ( =0.01 near MaxValue, =1 - linar, =100 near MinValue) (for fnftPower only)
  FNRBegArg:    double;  // Beg Argument Value (in Degree, for fnftSinDegree only)
  FNREndArg:    double;  // End Argument Value (in Degree, for fnftSinDegree only)
end; // type TN_RAFillNumParams = packed record
type TN_PRAFillNumParams = ^TN_RAFillNumParams;

type TN_RAFillColorsType = ( fctAnyIndependant, fctRangeIndependant,
                             fctRandLinear, fctUniformLinear, fct3DigitNumbers );

type TN_RAFillColParams = packed record // params for Filling RArray of Colors
  FCRFillType: TN_RAFillColorsType; // Filling type
  FCRReserved1: byte; // for alignment
  FCRReserved2: byte;
  FCRReserved3: byte;
  FCRBegIndex: integer;  // First Index of RArray to Fill
  FCRNumValues: integer; // Number of elements in RArray to Fill
  FCRMinColor: integer;  // Minimal Color (not needed for fctAnyIndependant)
  FCRMaxColor: integer;  // Maximal Color (not needed for fctAnyIndependant)
end; // type TN_RAFillColParams = packed record
type TN_PRAFillColParams = ^TN_RAFillColParams;

type TN_2DRAFillNumFuncType  = ( tdnftLinear1, tdnftLinear2, tdnftExp, tdnftParab );
type TN_2DRAFillNumFuncFlags = Set Of ( tdnftClearFirst );

type TN_2DRAFillNumParams = packed record // params for Filling and Updating 2D RArray
                                          // of Numbers (Integer, Float or Double)
  FNRFlags:    TN_2DRAFillNumFuncFlags; // Some Flags
  FNRFuncType: TN_2DRAFillNumFuncType;  // Function Type
  FNRReserved1: byte; // for alignment
  FNRReserved2: byte;
  FNRVX0Y0:      double;  // Value of [0,0]   element (for Linear fill)
  FNRVXMaxY0:    double;  // Value of [Max,0] element (for Linear fill)
  FNRVX0YMax:    double;  // Value of [0,Max] element (for Linear fill)
  FNRExtrCoords: TDPoint; // Extremum Index Coords (for Parabolic and Exponent fill)
  FNRExtrVal:    double;  // Extremum Value (for Parabolic and Exponent fill)
  FNRCXYPar:     TDPoint; // Parabolic CX CY coefs
  FNRInfExpVal:  double;  // Infinum Exponent Value
  FNRSigmaExp:   TDPoint; // Sigma X Y Exponent coefs
  FNRFormat:     string;  // Pascal Format string for filling strings by numbers
end; // type TN_2DRAFillNumParams = packed record
type TN_P2DRAFillNumParams = ^TN_2DRAFillNumParams;

type TN_SclonOneToken = packed record // разные падежи одной лексемы
  STKey1:   string;
  STKey2:   string;
  STGender: string;  // -1 - female, 0 - neutral, 1 - male
  STImenit: string;  // Именительный
  STRodit:  string;  // Родительный
  STDatel:  string;  // Дательный
  STVinit:  string;  // Винительный
  STTvorit: string;  // Творительный
  STPredl:  string;  // Предложный
  STSearchKeys: string; // tokens for searching needed Entry
end; // type TN_SclonOneToken = packed record
type TN_PSclonOneToken = ^TN_SclonOneToken;

type TN_DROPFILES = packed record // Win API DROPFILES struct
  pFiles:  DWORD; // offset of FilesList field (offset from beg of this struct)
  pt:     TPoint; // drop point (coordinates depend on fNC)
  fNC:   integer; // Nonclient area flag. If <> 0, pt specifies the screen coordinates of a pointin a window's nonclient area.
                  // If = 0, pt specifies the client coordinates of a point in the client area.
  fWide: integer; // =0 if file list is AnsiChar, <> 0 if file list is WideCharChar
  FilesList: integer; // is not an Integer!, is a double - null-terminated list of file ANSI or Wide names
end; // type TN_DROPFILES = packed record
type TN_PDROPFILES = ^TN_DROPFILES;


//************* Measured Size types  ****************

type TN_MSizeUnit = ( msuLSU, msumm, msuPix, msuPrc,
                      msuUser, msuSpecial1, msuNotGiven );

var N_MSizeUnitNames: Array [0..6] of string = (
                     'LSU', 'mm', 'Pixels', 'Percents',
                     'User', 'Special1', '??' );

type TN_MScalSize = packed record // Measured Scalar Size (one Size with Mesuare units)
  MSSValue: float;      // Value in given Units
  MSUnit: TN_MSizeUnit; // Size Unit used in MSValue field
  MSReserved1: Byte; // for alignment
  MSReserved2: Byte; // for alignment
  MSReserved3: Byte; // for alignment
end; // type TN_MScalSize = packed record
type TN_PMScalSize = ^TN_MScalSize;

type TN_MPointSize = packed record // Measured Point Size (two Sizes with Mesuare units)
  MSPValue: TFPoint;     // Value in given Units
  MSXUnit: TN_MSizeUnit; // X Size Unit used in MSPValue.X field
  MSYUnit: TN_MSizeUnit; // Y Size Unit used in MSPValue.Y field
  MSReserved1: Byte; // for alignment
  MSReserved2: Byte; // for alignment
end; // type TN_MPointSize = packed record
type TN_PMPointSize = ^TN_MPointSize;

type TN_MRectSize = packed record // Measured Rect Size (four Sizes with Mesuare units)
  MSRValue:     TFRect;       // Value in given Units
  MSLeftUnit:   TN_MSizeUnit; // Left   Size Unit used in MSRValue.Left   field
  MSTopUnit:    TN_MSizeUnit; // Top    Size Unit used in MSRValue.Top    field
  MSRightUnit:  TN_MSizeUnit; // Right  Size Unit used in MSRValue.Right  field
  MSBottomUnit: TN_MSizeUnit; // Bottom Size Unit used in MSRValue.Bottom field
end; // type TN_MRectSize = packed record
type TN_PMRectSize = ^TN_MRectSize;

type TN_RectSizePos = packed record // Rect Size and Position (relative to some base Rect)
  RSPBPPos:   TFPoint;       // Base Point Position in %, relative to some base Rect ( (100,100) means lower right corner )
  RSPBPShift: TN_MPointSize; // Base Point Shift
  RSPHPPos:   TFPoint;       // Hot Point Position in %, relative to resulting Rect ( (100,100) means lower right corner )
  RSPSize:    TN_MPointSize; // resulting Rect Size
end; // type TN_RectSizePos = packed record
type TN_PRectSizePos = ^TN_RectSizePos;

type TN_RelPos = ( rpLefter, rpUpper, rpRighter, rpLower );

type TN_DashUnits = ( duLLW, dumm, duPix, duPenWidth, duLengthPrc );
// duLengthPrc means Percents of whole Line Length, used only in TN_GCont.PrepareMarkers method


type TN_ODFFlags = set of ( odffNotOverlap, odffEqualSizes,
                            odffAlignCenter, odffAlignEnd );

type TN_ODFSParams = packed record // One Dimensional Fixed Size Elems layout Params
  ODFFLags: TN_ODFFlags; // ODFS layout algorithm Flags
  ODFReserved1: Byte; // for alignment
  ODFReserved2: Byte;
  ODFReserved3: Byte;
  ODFLRPaddings: TN_MPointSize; // Beg and End Paddings (Left(Top) and Right(Bottom))
  ODFElemSize:   TN_MScalSize;  // Element Size: =0 means uniform layout,
                                //   ( size in % means % from whole size (usually not used) )
  ODFGapSize:    TN_MScalSize;  // Gap between Elements, size in % means % from Element size
//  ODFBordWidth:  TN_MScalSize;  // Elements Border Width
end; // type TN_ODFSParams = packed record
type TN_PODFSParams = ^TN_ODFSParams;

type TN_StringObj = class( TObject ) // One String as TObject descendant
  public
  StrField: string;
end; // type TN_StringObj = class( TObject )

type TN_MEDebFlags = Set Of ( medfDebInInterface, medfCollectProtocol,
                              medfProtocolToFile, medfAutoViewProtocol,
                              medfInfoWatch, medfTmpFlag1, medfTmpFlag2 );

type TN_GetInfoFlags = Set Of ( gifMinInfo,  gifMediumInfo, gifMaxInfo,
                                gifGetAllRows,
                                gifObjNames, gifOwnerPath,
                                gifFlag1, gifFlag2, GifFlag3 );

type TN_UObjPathType = ( uptAllOwners, uptLastOwners, uptUObjPath, uptRefPath );

type TN_UObjPathFlags = Set Of ( upfUseUObjName, upfOwnersPath, upfUObjRefPath,
                                 upfOneSegmPath );

//***** VBA realated Types, Contsts and Vars

const N_NumIPParams = 5;

type TN_MEWordFlags = Set Of ( mewfUseVBA, mewfUseWin32API,
                               mewfCloseResDoc, mewfWordVisible );
// mewfUseVBA      - VBA macros would be used, otherwise only Pascal would be used
// mewfUseWin32API - in VBA macros Win32API would be used
// mewfCloseResDoc - Close Resulting Document after creating it
// mewfWordVisible - Word should be Visible while creating Resulting Document

type TN_MEWordPSMode = ( psmNotGiven,  psmFile,     psmWinAPIClb,
                         psmDelphiMem, psmPSDocVar, psmPSDocText, psmPSDocClb );

var
  N_DelphiMem: TN_BArray;
  N_PSModeNames: array [0..6] of string = ( 'Not Given', 'File',
                                 'Clipboard by API', 'Delphi Mem', 'PSDoc Var',
                                 'PSDoc Text', 'PSDoc Clb' );

//***** HTML realated Types, Contsts and Vars

type TN_HTMLPortionType = ( hptNotDef, hptTagOpen, hptTagClose, hptTagSingle,
                            hptText, hptEmpty, hptEnd, hptError );

type TN_HTMLStateFlags = Set Of ( hsfLastSpace, hsfDumpMode );

{
type TN_NameValuePair = record
  NVName:  string;
  NVValue: string;
end; // type TN_NameValuePair = record
type TN_NameValuePairs = array of TN_NameValuePair;
}

type TN_HTMLPortion = record
  HPPortionType: TN_HTMLPortionType;
  HPStateFlags: TN_HTMLStateFlags;
  HPText: string;     // Upper Case Tag Name or Text if HPPortionType = hptText
  HPAttribsSL:   TStringList;   // Tag Attributes Name=Value pairs as TStringList
  HPStyleSL:     TStringList;   // Style Attributes Name=Value pairs as TStringList
  HPErrInfoSL:   TStringList;   // Strings with Error description
  HPResCode:     integer;       // Resulting Code: 0-9 - OK, 10-99 - Warning, >=100 severe error
  HPResPos:      integer;       // Resulting (Error or Warning) Position in source HTML text
end; // type TN_HTMLPortion = record
type TN_PHTMLPortion = ^TN_HTMLPortion;
type TN_HTMLPortions = array of TN_HTMLPortion;


//***** Protocol Channels

type TN_LCActionType = ( lcaClearBuf, lcaSetBufSize, lcaFlush, lcaPrepFStream,
                         lcaFree );

type TN_LogChanFlags = Set Of (
  lcfEnable,      // Enable Chanel (otherwise do not write anything)
  lcfShowCounter, // Add Row Counter as prefix to all dumpfile rows
  lcfShowTime,    // Add Time (in dd-hh":"nn":"ss.zzz format) as prefix to all dumpfile rows
  lcfShowHeader,  // Add Header Strings before first string to dump (Start Session, Date, Time)
  lcfFlushMode,   // Flush bufer (to disk) after each string
  lcfAppendMode   // Add strings to existing file, otherwise create new file for each session
    );
type TN_LCStateFlags = Set Of ( lcsfNotEmpty, lcsfWarnInfo, lcsfErrInfo );

type TN_LogChannel = record //********************* One Protocol Channel data
  LCFlags:      TN_LogChanFlags; // Log Channel Flags
  LCStateFlags: TN_LCStateFlags; // Log Channel State Flags
  LCFullFName: string;           // Log Channel Full File Name
  LCFName:     string;           // Log Channel File Name (not expanded)
  LCPrefix:    string;           // All strings prefix
  LCIndent:   integer;           // Number of additional spaces to add before LCPrefix
  LCFStream: TFileStream;        // File Stream for writing to File
  LCCounter:  integer;           // Log Channel string counter
  LCWrapSize: integer;           // Max not wraped String Size
  LCBuf:  TStringList;           // Log Channel Buffer
  LCBufSize:  integer;           // PCBuf Size in strings
  LCShowForm:   TForm;           // Form for showing Log (should be TN_MemoForm)
  LCTimeShift: double;           // Time that is always added to local time in logs
  LCSecondCInd: integer;         // Second Channel Index for copiing all strings
  LCPendingType:  integer;       // LCPendingStr Type
  LCPendingCount: integer;       // Number of calls with LCPendingType
  LCPendingStr:    string;       // Last Pending string which has LCPendingStr Type
  LCSavedBufSize: integer;       // Saved LCBufSize
  LCFlashCounter: integer;       // Flash Counter
end; // type TN_LogChannel = record
type TN_LogChannels = array of TN_LogChannel;

type TN_LogChannelInfo = packed record //*** Log Channel Info for
                                        //    reading from Ini file and for
                                        //    Editing and Saving in user interface
  LCIFlags:  TN_LogChanFlags; // Log Channel Flags
  LCIFName:       string;     // Log Channel File Name (not expanded)
  LCIBufSize:    integer;     // LCBuf Size in strings
  LCISecondCInd: integer;     // Second Channel Index for copiing all strings
end; // type TN_LogChannelInfo = record
type TN_PLogChannelInfo = ^TN_LogChannelInfo;

type TN_BracketInfo = record //********************* One Bracket Info
  BIText: string;    // Text inside Brackets
  BIBegInd: integer; // Open Bracket first char index ( counting from 1 )
  BIEndInd: integer; // Close Bracket last char index ( counting from 1 )
end; // type TN_BracketInfo = record
type TN_BracketsInfo = array of TN_BracketInfo;

type TN_FreeMemBlock = record //*** One Free Memory Block
  FMBStart: DWORD; // Block Start Address
  FMBSize:  DWORD; // Block Size in Bytes
end; // type TN_FreeMemBlock = record //*** One Free Memory Block
type TN_PFreeMemBlock = ^TN_FreeMemBlock;
type TN_FreeMemBlocks = array of TN_FreeMemBlock;

type TN_CellFmtFalgs = Set Of ( // Cell Row or Column format flags
  cffHorAlignCenter, // Horizontal Align Center
  cffHorAlignRight,  // Horizontal Align Right
  cffBold            // Bold Font
  ); // type TN_CellFmtFalgs = Set Of ( // Cell Row or Column format flags

type TN_CellFmtParams = record // Cell Row or Column format params
  CFPFlags: TN_CellFmtFalgs; // Format flags
  CFPWidthCoef: float;       // Width Coef (Width multiplyer), =0 is the same as =1
  CFPMinChars: integer;      // Minimal Column Width in Characters
end; // type TN_CellFmtParams = record ( // Cell Row or Column format params
type TN_CFPArray = Array of TN_CellFmtParams;

//***************************** CONSTANTS ************************

const
{$IFDEF MSWindows}
  N_DirectorySeparator = '\';
{$ELSE}
  N_DirectorySeparator = '/';
{$ENDIF}

  mbYesNo = [mbYes, mbNo];

  //************** Log Channel Indexes
  N_LCIHTMLParser = 0;
  N_LCIVCompExec  = 0;
  N_LinHistAuto   = 0;
  N_CMSPCInd      = 0;

  N_VBAParamsDelimeter   = '%%';

{$IFDEF MSWindows}
  N_GCWSInitialDir       = 'C:\';             // Initial Dir used for passing Params and Log Files
{$ELSE}
  N_GCWSInitialDir       = 'C:/';             // Initial Dir used for passing Params and Log Files
{$ENDIF}

  N_GCWSParamsStrFName   = 'ParamsStr.~txt';  // File Name used for passing Params String
  N_GCWSParStrDocVarName = 'N_ParStrDocVar';  // Doc Variable Name used for passing Params String
  N_GCPSDocName          = 'N_ParStrDoc.doc'; // Doc Name used for passing Params String

  N_BytesInKB = 1024;           // Bytes in one kilobyte
  N_BytesInMB = 1024*1024;      // Bytes in one megabyte
  N_BytesInGB = 1024*1024*1024; // Bytes in one gigabyte
  N_SecondsInDay = 24*3600;     // Seconds in one day

  // N_NotADouble   = 1e+22; // Pascal can not compare exactly !
  N_NotADouble   =  -12345678901234e+4; // "not initialized" flag
  N_NotAFloat    = -144115188075855872; // "not initialized" flag (~2^57)

  N_NotADRectStr = '-12345678901234e+4 0 0 0'; // "not initialized" DRect
  N_NotAnInteger = -1234567890;        // "not initialized" flag
  N_NotAString   = '!NotAString!';     // "not initialized" flag
  N_NotAnIntPoint: TPoint = (X:N_NotAnInteger; Y:N_NotAnInteger);
  N_NotAnIntRect:  TRect  = (Left:N_NotAnInteger; Top:N_NotAnInteger; Right:N_NotAnInteger; Bottom:N_NotAnInteger);

  N_Eps    = 1.0e-14; // 1.0+0.01*N_Eps > 1.0 (2 decimal digits precaution)
  N_FEps   = 1.1920928955e-7;   // 1.0+N_FEps  > 1.0 (float precision)
  N_DEps   = 2.2204460493e-16;  // 1.0+N_DEps  > 1.0 (double precision)
  N_ExEps  = 1.0842021725e-19;  // 1.0+N_ExEps > 1.0 (extended precision)

  N_1MFEps  = 1.0 - 2*N_FEps;
  N_1MDEps  = 1.0 - 2*N_DEps;
  N_1MExEps = 1.0 - 2*N_ExEps;

  N_1PFEps  = 1.0 + 2*N_FEps;
  N_1PDEps  = 1.0 + 2*N_DEps;
  N_1PExEps = 1.0 + 2*N_ExEps;

  N_10FEps  = 10.0 * N_FEps;
  N_10DEps  = 10.0 * N_DEps;
  N_10ExEps = 10.0 * N_ExEps;

  N_100FEps  = 100.0 * N_FEps;
  N_100DEps  = 100.0 * N_DEps;
  N_100ExEps = 100.0 * N_ExEps;

  N_05MEps     = 0.5 - 1.0e-13; // 0.5 Minus Eps
  N_SortOrder  = $010000;   // Sort Order bit in CompareParam for sorting

  N_MinInt2     = -32768;    // Min TN_Int2  ($FFFF8000)
  N_MaxInt2     = $00007FFF; // Max TN_Int2  (32767)
  N_MaxUInt2    = $0000FFFF; // Max TN_UInt2 (65535, Max WORD)
  N_MaxInteger  = $7FFFFFFF; // Max Integer
  N_MaxFloat    = 3.3e38;    // Max Float    (really 3.4e38)
  N_MaxDouble   = 1.6e308;   // Max Double   (really 1.7e308)
  N_MaxExtended = 1.0e4932;  // Max Extended (really 1.1e4932)
  N_10E6D       = 1000000.0; // used for nice Float to String convertion
  N_10EM6D      = 0.000001;  // used for nice Float to String convertion

  N_EmptyColor    = -1;   // Empty (Transparent) Color (do not draw)
  N_CurColor      = -2;   // use Current Color
  N_CurLLWSize    = -2.0; // use Current LLW Size attribute (PenWidth, FontSize)
  N_CurAngleStyle = -1;   // use Current Angle Style
  N_CurFontName   = '-1'; // use Current Font Name
  N_CurFontStyle  = $10;  // use Current Font Style
  N_ClearStyle = 0;       // means psClearPen or bsClearBrush
  N_SolidStyle = 1;       // means psSolidPen or bsSolidBrush
  N_SysAttr    = 0;   // draw Line by SysLine attributes (used in DrawCObj)
  N_HighAttr   = 1;   // highlight Line, Segment, Vertex (used in DrawCObj)
  N_MoveAttr   = 2;   // moving Segment (used in DrawCObj)
  N_ClearAttr  = 3;   // Clear color and size for lines, segments and vertexes
  N_FloatCoords  = 0; // used for checking current coords type (float or double)
  N_DoubleCoords = 1; // used for checking current coords type (float or double)
  N_Pi = 3.1415926535897932385;
  N_PiD1800 = 3.1415926535897932385/1800;
  N_InchInmm = 25.4; // One Inch in millimeters
  N_EndOfArray = '_End_of_Array_'; // used for Text Input/Output
  N_EndOfArraySize = Length(N_EndOfArray);
  N_EmptyArray = '_Empty_Array_';  // used for Text Input/Output
  N_EmptyArraySize = Length(N_EmptyArray);
  N_MaxItemsCount = 20;            // used in N_AddUniqStrToTop
  N_MIEnable  = $00000;   // Menu Item Enable  (used in N_SetMenuItems)
  N_MIDisable = $10000;   // Menu Item Disable (used in N_SetMenuItems)
  N_MIHide    = $20000;   // Menu Item Hide    (used in N_SetMenuItems)

  N_SError          = 'Error!';
  N_SVectEditGName  = 'VectEditGroup';
  N_SMoveCompGName  = 'MoveCompGroup';
  N_SMarkCompGName  = 'MarkCompGroup';
  N_3RectsEdGName   = '3RectsEdGroup';
  N_UserInfoGName   = 'UserInfoGName';
  N_SEmptyString    = '!EmptyString!';

  N_StrCRLF: string = Char($0D)+Char($0A); // same as #$0D#$0A, suitable for both Ansi and Wide Chars
  N_ADEPSignature: integer = $50454441; // 'ADEP' characters ('A' in lowest byte)

  N_VKShift      = 16;
  N_VKControl    = 17;
  N_VKAlt        = 18;
  N_VKPause      = 19;
  N_VKCapsLock   = 20;
  N_VKEscape     = 27;
  N_VKNumLock    = 144;
  N_VKScrollLock = 145;

  N_SizeOfProcOfObj = 8; // Size of two pointers

  N_ZIPoint: TPoint  = (X:0; Y:0);
  N_ZFPoint: TFPoint = (X:0; Y:0);
  N_ZDPoint: TDPoint = (X:0; Y:0);

  N_05FPoint: TFPoint = (X:0.5; Y:0.5);
  N_05DPoint: TDPoint = (X:0.5; Y:0.5);

  N_PZFPoint: PFPoint = @N_ZFPoint;

  N_DPDelimeter1: TDPoint = (X:123456; Y:0);

  N_ZIRect: TRect  = (Left:0; Top:0; Right:0; Bottom:0);
  N_ZFRect: TFRect = (Left:0; Top:0; Right:0; Bottom:0);
  N_ZDRect: TDRect = (Left:0; Top:0; Right:0; Bottom:0);

  N_NoIRect: TFRect = (Left:N_NotAnInteger; Top:N_NotAnInteger; Right:N_NotAnInteger; Bottom:N_NotAnInteger);
  N_NoFRect: TFRect = (Left:N_NotAFloat; Top:N_NotAFloat; Right:N_NotAFloat; Bottom:N_NotAFloat);
  N_NoDRect: TFRect = (Left:N_NotADouble; Top:N_NotADouble; Right:N_NotADouble; Bottom:N_NotADouble);

  N_EIRect:    TRect  = (Left:0; Top:0; Right:1; Bottom:1);         // (0,0,1,1)
  N_I100Rect:  TRect  = (Left:0; Top:0; Right:99; Bottom:99);       // (0,0,99,99)
  N_M1IRect:   TRect  = (Left:0; Top:0; Right:-1; Bottom:-1);       // (0,0,-1,-1)
  N_EFRect:    TFRect = (Left:0.0; Top:0.0; Right:1.0; Bottom:1.0); // (0,0,1,1)
  N_EDRect:    TDRect = (Left:0.0; Top:0.0; Right:1.0; Bottom:1.0); // (0,0,1,1)
  N_NotAFRect: TFRect = (Left:N_NotAFloat; Top:0; Right:0; Bottom:0); // not initialized
  N_NotADRect: TDRect = (Left:N_NotADouble; Top:0; Right:0; Bottom:0); // not initialized
  N_MaxFRect:  TFRect = (Left:-N_MaxFloat; Top:-N_MaxFloat; Right:N_MaxFloat; Bottom:-N_MaxFloat); // max Float Rect
  N_Max9XPRect: TRect = (Left:-13000; Top:-13000; Right:13000; Bottom:13000); // max Pix Rect in Win9x
  N_D100Reper: TN_3DPReper = (P1:(X:0;Y:0);P2:(X:100;Y:0);P3:(X:0;Y:100));

  N_DefAffCoefs4:  TN_AffCoefs4 = (CX:1.0; SX:0.0; CY:1.0;  SY:0.0); // 1 to 1 Convertion
  N_IYAffCoefs4:   TN_AffCoefs4 = (CX:1.0; SX:0.0; CY:-1.0; SY:0.0); // Inverse Y Convertion
  N_DefAffCoefs6:  TN_AffCoefs6 = (CXX:1.0; CXY:0.0; SX:0.0; CYX:0.0; CYY:1.0; SY:0.0);  // 1 to 1 Convertion
  N_DefAffCoefs8:  TN_AffCoefs8 = (CXX:1.0; CXY:0.0; SX:0.0; WX:0.0; CYX:0.0; CYY:1.0; SY:0.0; WY:0.0 ); // 1 to 1 Convertion

  N_DefNFontName:    string = 'DefNFont';    // Default Font Name in N_DefObjectsDir
  N_DefSysLinesName: string = 'DefSysLines'; // Default SysLines Attrs Name in N_DefObjectsDir
  N_ArchFilesHistName: string = 'N_ArchFilesHist'; // Ini file Section Name for Arch Files

  N_CentrDefStrPosParams: TN_StrPosParams = ( SPPHotPoint:(X:50;Y:50));
  N_ZeroDefStrPosParams:  TN_StrPosParams = ();

//  N_MaxArcAngle = 45.0; // approximating (Ellips-Bezier) error is about 0.0004%
  N_MaxArcAngle = 90.0; // approximating (Ellips-Bezier) error is about 0.0004%
  N_MaxGetInfoRows = 200;
  N_PathShortSize  = 25;

  //***************** N_Dump2TStr Typed Strings Types:
  N_TStr_PBPaint   = 01;
  N_TStr_MMove     = 02;
  N_TStr_MWheel    = 03;
  N_TStr_SBChange  = 05;
  N_TStr_TWAINMsg  = 06;

  N_TStr_TimeStamp = 10;

  N_UseBOMFlag: integer = $0100; // Bit4, Use BOM (Byte Order Mark) Flag

  //***************** MS Office OLE Servers constants:

  //****************************** MS Office General
  msoControlButton = $00000001;

  msoButtonIcon           = $00000001;
  msoButtonIconAndCaption = $00000003;

  //****************************** MS Office Word
  wdCollapseEnd   = $00000000;
  wdCollapseStart = $00000001;

  wdAlignRowLeft   = $00000000;
  wdAlignRowCenter = $00000001;
  wdAlignRowRight  = $00000002;

  wdCharacter = $00000001;
  wdWord      = $00000002;
  wdSentence  = $00000003;
  wdParagraph = $00000004;
  wdLine      = $00000005;
  wdStory     = $00000006;
  wdScreen    = $00000007;
  wdSection   = $00000008;
  wdColumn    = $00000009;
  wdRow       = $0000000A;
  wdWindow    = $0000000B;
  wdCell      = $0000000C;
  wdCharacterFormatting = $0000000D;
  wdParagraphFormatting = $0000000E;
  wdTable     = $0000000F;
  wdItem      = $00000010;

  wdMove   = $00000000;
  wdExtend = $00000001;

  wdNormalView  = $00000001;
  wdOutlineView = $00000002; // Doc structure
  wdPrintView   = $00000003; // режим разметки
  wdPageView    = $00000003; // режим разметки, старый вариант для Word97
  wdMasterView  = $00000005;

  wdHeaderFooterPrimary   = $00000001;
  wdHeaderFooterFirstPage = $00000002;
  wdHeaderFooterEvenPages = $00000003;

  wdSectionBreakNextPage = $00000002;
  wdPageBreak = $00000007;

  wdPasteOLEObject = $00000000;
  wdPasteRTF       = $00000001;
  wdPasteText      = $00000002;
  wdPasteMetafilePicture = $00000003;
  wdPasteBitmap    = $00000004;
  wdPasteDeviceIndependentBitmap = $00000005;
  wdPasteHyperlink = $00000007;
  wdPasteShape     = $00000008;
  wdPasteEnhancedMetafile = $00000009;
  wdPasteHTML      = $0000000A;

  wdInLine        = $00000000;
  wdFloatOverText = $00000001;

  wdTextOrientationHorizontal = $00000000;
  wdTextOrientationUpward = $00000002;

  wdDoNotSaveChanges    = $00000000;
  wdSaveChanges         = $FFFFFFFF;
  wdPromptToSaveChanges = $FFFFFFFE;

  wdWord8TableBehavior = $00000000;
  wdWord9TableBehavior = $00000001;

  wdAutoFitFixed   = $00000000;
  wdAutoFitContent = $00000001;
  wdAutoFitWindow  = $00000002;

  wdAlignParagraphLeft        = $00000000;
  wdAlignParagraphCenter      = $00000001;
  wdAlignParagraphRight       = $00000002;
  wdAlignParagraphJustify     = $00000003;
  wdAlignParagraphDistribute  = $00000004;
  wdAlignParagraphJustifyMed  = $00000005;
  wdAlignParagraphJustifyHi   = $00000007;
  wdAlignParagraphJustifyLow  = $00000008;
  wdAlignParagraphThaiJustify = $00000009;

  wdOrientPortrait  = $00000000;
  wdOrientLandscape = $00000001;

  //****************************** MS Office Excel
  xlWorksheet = $FFFFEFB9;

  xlLeft   = $FFFFEFDD;
  xlCenter = $FFFFEFF4;
  xlRight  = $FFFFEFC8;
  xlTop    = $FFFFEFC0;
  xlBottom = $FFFFEFF5;

  //*** end of MS Office OLE Servers constants

  //***************** Shape file (record) types:
  N_ShapeBadFile    = -2; // errors in Shape File
  N_ShapeNoFile     = -1; // no such Shape File
  N_ShapeNull       = 0;  // Null Shape Record
  N_ShapePoint      = 1;  // Point Shape Record and File
  N_ShapePolyLine   = 3;  // PolyLine Shape Record and File
  N_ShapePolygon    = 5;  // Polygon Shape Record and File
  N_ShapeMultiPoint = 8;  // MultiPoint Shape Record and File


  //****************************** missing in DirectShow9
  MEDIASUBTYPE_I420: TGUID = (D1:$30323449;D2:$0000;D3:$0010;D4:($80,$00,$00,$AA,$00,$38,$9B,$71));
  {$EXTERNALSYM MEDIASUBTYPE_I420}
  WMMEDIASUBTYPE_WMV1: TGUID = (D1:$31564D57;D2:$0000;D3:$0010;D4:($80,$00,$00,$AA,$00,$38,$9B,$71));
  {$EXTERNALSYM WMMEDIASUBTYPE_WMV1}
  WMMEDIASUBTYPE_WMV2: TGUID = (D1:$32564D57;D2:$0000;D3:$0010;D4:($80,$00,$00,$AA,$00,$38,$9B,$71));
  {$EXTERNALSYM WMMEDIASUBTYPE_WMV2}
  WMMEDIASUBTYPE_WMV3: TGUID = (D1:$33564D57;D2:$0000;D3:$0010;D4:($80,$00,$00,$AA,$00,$38,$9B,$71));
  {$EXTERNALSYM WMMEDIASUBTYPE_WMV3}

    //******************** Global Variables ******************************
var
  N_WrkClipedLengths: TN_IArray;
  N_WrkClipedFLines:  TN_AFPArray;
  N_WrkClipedDLines:  TN_ADPArray;
  N_WrkFSegm1: TN_FPArray;
  N_WrkDSegm1: TN_DPArray;
  N_Wrk1Ints: TN_IArray;

  N_WinNTGDI: boolean; // if True - not Win98, Arcs can be used in Paths, PolyDraw can be used
  N_nil: Pointer = nil;             // nil as variable
  N_NotDefStr: string = 'Not Defined!';
  N_ApplicationTerminated: boolean; // for checking in OnFormDestoy handlers
  N_TestD1, N_TestD2: double;   // global variables for debugging
  N_TestI1, N_TestI2: integer;  // global variables for debugging
  N_DrawContMode: integer;      // temporary
  N_CPUFrequency: double = 2e8; // CPU frequncy in HZ (not in MHZ!)
  N_EpsCPUTimer1: integer;      // CPU Clocks expenses in TN_CPUTimer1.Stop
  N_EpsCPUTimer2: integer;      // CPU Clocks expenses in TN_CPUTimer2.Stop
  N_EpsPerfCounter: integer;    // QueryPerformanceCounter expenses (in PerformanceCounter units)
  N_PerformanceFrequency: double; // number of Preformance Counter units per second
  N_ProcHandle: THANDLE;        // Self Process Handle
  N_BegOfTimeInterval: double;  // for use in N_StartTime, N_FinTime
  N_InitialFileDir: string;     // Initial File Dir in Open File Dialogs
  N_ExeNameDir: string;         // Exe File Dir (for own system files)
  N_DebugMode: integer = 0;
  N_CurDateTime: double;
  N_LinesPalette: TN_IArray; // for drawing Lines with ditherent colors
  N_OCanvDefPixFmt: TPixelFormat; // default OCanvas Pixel Format
  N_ScreenPixelFormat: TPixelFormat;
  N_RefreshCoords: boolean = False;
  N_TextCoordsType: Array[0..1] of string = ( 'Float', 'Double' );
  N_SysColors: array of TN_IArray; // several Color palettes

  N_16ColorsPal: array [0..15] of integer = // standard 16 Colors Palette
  ( $000000, $800000, $008000, $808000, $000080, $800080, $008080, $909090,
    $505050, $FF8080, $80FF80, $FFFF80, $8080FF, $800080, $80FFFF, $FFFFFF );

  N_ClTransp:  integer = -1;      // Empty (Transparent) Color (do not draw)
  N_ClBlack:   integer = $000000; // Black Color (as variable)
  N_ClRed:     integer = $0000FF; // Red   Color (as variable)
  N_ClGreen:   integer = $00FF00; // Green Color (as variable)
  N_ClBlue:    integer = $FF0000; // Blue  Color (as variable)
  N_ClYellow:  integer = $00FFFF; // Red   Color (as variable)
  N_ClCyan:    integer = $FFFF00; // Red   Color (as variable)
  N_ClMagenta: integer = $FF00FF; // Red   Color (as variable)
  N_ClGray:    integer = $808080; // Gray  Color (as variable)
  N_ClWhite:   integer = $FFFFFF; // White Color (as variable)

  N_ClDkGray:  integer = $505050; // Dark Gray Color (as variable)
  N_ClDkRed:   integer = $000080; // Dark Red Color (as variable)
  N_ClDkGreen: integer = $008000; // Dark Green Color (as variable)
  N_ClDkBlue:  integer = $800000; // Dark Blue Color (as variable)


  N_ClLtGray: integer = $AAAAAA; // Light Gray Color (as variable)
  N_ClLtBlue: integer = $FFAAAA; // Light Blue Color (as variable)

  N_ClGreenGray: integer = $AACCAA; // Green Gray Color (as variable)




  N_ClGrayColor:  integer = $AAAAAA; // Gray  Color (as variable)
  N_ClGreenGrayColor:  integer = $AACCAA; // Green Gray  Color (as variable)

//  N_BlackColor: integer = $000000; // Black Color (as variable)
//  N_GrayColor:  integer = $AAAAAA; // Gray  Color (as variable)
//  N_GreenGrayColor:  integer = $AACCAA; // Green Gray  Color (as variable)
//  N_WhiteColor  : integer = $FFFFFF; // White Color (as variable)

  N_CurrentMenu: TMenu; // Current Menu (used in N_CreateMenuItem)
  N_CurMIHandler: procedure (Sender: TObject) of Object; // crrent MenuItem
                                         // Handler (used in N_CreateMenuItem)
  N_GlobalDebFlags: integer; // Global Debug Control Flags
  N_UniqFilesCounter: integer;

  N_SysLineAttr1: TN_SysLineAttr = (
      AtLASColor: $000088; AtLASWidth: 1;
      AtLBSColor: $0000FF; AtLBSWidth: 1;
      AtLAV: (SShape:[sshRect]; SBrushColor:-1; SPenColor:$000088; SPenWidth:1);
      AtLBV: (SShape:[sshRect]; SBrushColor:-1; SPenColor:$000088; SPenWidth:1); );

  N_PictFilesFilter: string =' All  files (*.*)|*.*| BMP files (*.bmp)|*.BMP|' +
      ' EMF files (*.emf)|*.EMF;*.WMF| JPEG files (*.jpg)|*.jpg| GIF files (*.gif)|*.GIF|';

  N_ArchFilesFilter: string =' Archive files (*.sdt, *.sdb)|*.SDT;*.SDB| All files (*.*)|*.*|';

  N_SavedHDC: ulong; // for debug
  N_SavedPenHandle: ulong; // for debug
  N_OCanvCriticalSection: TRTLCriticalSection;

  N_Bullets:    string = '->*';
  N_NotUsedStr: string = 'NotUsed';  // Possible Video Compressor Name

  N_ErrorStrings: array [0..19] of string =
  ( 'Some Error',       '', '', '', '', '', '', '', '', '', //  0-9
    'Bad DVector Type', '', '', '', '', '', '', '', '', ''  // 10-19
  );

  N_DefImageFilePar: TN_ImageFilePar;
  N_OutSL_Label: string = '<!--OutSL_Label-->';
  N_InfoSL: TStringList; // used as Return Value for some Info collecting functions, it is always exists

  N_IntOne:      integer = 1;
  N_IntAllOnes:  integer = -1; // = $FFFFFFFF
  N_IntAllZeros: integer = 0;

  N_ByteAllOnes:  Byte = $FF;
  N_ByteAllZeros: Byte = 0;

  N_LogChannels: TN_LogChannels; // Logging Chanels

  N_BinaryDumpProcObj: TN_BinaryDumpProcObj;  // Proc of Obj for saving binary Dump to file

  N_Dump1Str:   TN_OneStrProcObj;   // Dump one String to Dump1 channel
  N_Dump2Str:   TN_OneStrProcObj;   // Dump one String to Dump2 channel
  N_Dump1TStr:  TN_OneIOneSProcObj; // Dump one Typed String to Dump1 channel
  N_Dump2TStr:  TN_OneIOneSProcObj; // Dump one Typed String to Dump2 channel
  N_DumpStr:    TN_OneIOneSProcObj; // Dump one String to some channel
  N_Show1Str:   TN_OneStrProcObj;   // Show one String, variant 1
  N_MessageDlg: TN_MessageDlgFunc;

  N_AppShowString: TN_OneStrProcObj; // Show String in Application specific place

//  N_AllMonitorsWAR: TRect = (Left:0;Top:0;Right:799;Bottom:599); // Work Area on all monitors
//  N_WorkAreaRect: TRect = (Left:0;Top:0;Right:799;Bottom:599);   // Work Area allowed to use, obsolete, N_AppWAR should be used

  N_WholeWAR:     TRect; // Whole Work Area Rect (Envelope Rect of all monitors)
  N_PrimMonWAR:   TRect; // Work Area Rect on Primary monitor
  N_CurMonWAR:    TRect; // Work Area Rect on Current monitor
  N_AppWAR:       TRect; // Application Work Area Rect (all App windows should be inside it)
  N_MainUserFormRect: TRect; // used mainly for placing Forms over the Main Form
  N_EnableMainFormMove: boolean; // enable N_ProcessMainFormMove(

  N_NeededCodePage:     integer = 1251; // CodePage, used in N_StringToAnsi, N_AnsiToString procedures (1251-Rus, 1252-Lat)
  N_NeededTextEncoding: integer = $101; // Encoding mode, used in N_StringToBytes, N_BytesToString procedures
                                 //#F
                                 //  bits0-3 - (least byte) TN_TextEncoding Enum
                                 //  bit4    - =1 - use BOM (Byte Order Mark), N_UseBOMFlag const can be used
                                 //#/F

  N_DefBFFlags: TN_BFFlags; // Default Base Form Flags

  N_DefAnsiCharStr: AnsiString = '?';

  N_Dump1LCInd: integer = -1; // Dump1 Logging Chanel Index
  N_Dump2LCInd: integer = -1; // Dump2 Logging Chanel Index

  N_LCIDeb1:    integer = -1; // Logging Chanel Index for Deb1 actions
  N_LCIDeb2:    integer = -1; // Logging Chanel Index for Deb2 actions

  // Test Procedures
  N_TstUseDLLProc:     TN_OneIntProc;
  N_TstIPCTest1Proc:   TN_Proc;
  N_TstPackedIntsProc: TN_Proc;
  N_TstROXTest1Proc:   TN_Proc;
  N_ShowOlg1FormProc:  TN_Proc;


  //*** end of Global Variables

    //*** Dummy objects, that can be used to avoid warnings and for debug

  N_c,    N_c1,    N_c2:     char;
  N_i,    N_i1,    N_i2:     integer;
  N_gi,   N_gi1,   N_gi2:     integer;
  N_u,    N_u1,    N_u2:     ulong;
  N_lb,   N_lb1,   N_lb2:    LongBool;
  N_d,    N_d1,    N_d2:     double;
  N_ex,   N_ex1,   N_ex2:    Extended;
  N_f,    N_f1,    N_f2:     float;
  N_s,    N_s1,    N_s2:     string;
  N_as,   N_as1,   N_as2:    AnsiString;
  N_ws,   N_ws1,   N_ws2:    WideString;
  N_b,    N_b1,    N_b2:     boolean;
  N_p,    N_p1,    N_p2:     Pointer;
  N_pp,   N_pp1,   N_pp2:    PPointer;
  N_o,    N_o1,    N_o2:     TObject;
  N_PC,   N_PC1,   N_PC2:    PChar;
  N_Str,  N_Str1,  N_Str2:   string;
  N_v,    N_v1,    N_v2:     Variant;
  N_ba,   N_ba1,   N_ba2:    TN_BArray;
  N_ia,   N_ia1,   N_ia2:    TN_IArray;
  N_fa,   N_fa1,   N_fa2:    TN_FArray;
  N_da,   N_da1,   N_da2:    TN_DArray;
  N_Form, N_Form1, N_Form2:  TForm;
  N_SL,   N_SL1,   N_SL2:    TStringList;
  N_gdi,  N_gdi1,  N_gdi2:   HGDIObj;
  N_h,    N_h1,    N_h2:     THANDLE;

  N_pb,   N_pb1,   N_pb2:    PByte;

  N_IP, N_IP1, N_IP2:  TPoint;
  N_FP, N_FP1, N_FP2:  TFPoint;
  N_DP, N_DP1, N_DP2:  TDPoint;
  N_IR, N_IR1, N_IR2:  TRect;
  N_FR, N_FR1, N_FR2:  TFRect;
  N_DR, N_DR1, N_DR2:  TDRect;

  N_IPA:  TN_IPArray;
  N_IPA1: TN_IPArray;
  N_FPA:  TN_FPArray;
  N_DPA:  TN_DPArray;
  N_AC4:  TN_AffCoefs4;
  N_AC6:  TN_AffCoefs6;
  //*** end of Dummy objects, that can be used to avoid warnings and for debug

//******************** Windows API ******************************

{$IFDEF MSWindows}
function GetSystemWindowsDirectoryA ( APAStr: PAnsiChar; ASize: DWORD ): DWORD; stdcall; external 'kernel32.dll' name 'GetSystemWindowsDirectoryA';
function GetSystemWindowsDirectoryW ( APWStr: PWideChar; ASize: DWORD ): DWORD; stdcall; external 'kernel32.dll' name 'GetSystemWindowsDirectoryW';
{$ENDIF}

//function acmGetVersion (): DWORD; stdcall; external 'Msacm32.dll' name 'acmGetVersion';


//******************** Application Control Types and Varaibles ******************************
var
  N_AppSkipEvents: Boolean; // Application Skip Events flag - needed to skip events if Application.ProccessMessages is called

  N_TmpTestProc1: TN_Proc; // Temporary testing procedure #1 (can be used to avoid including N_Tst... units in Uses statement)
  N_TmpTestProc2: TN_Proc; // Temporary testing procedure #2 (can be used to avoid including N_Tst... units in Uses statement)

const // Objects Live Mark Value - is used to control memory for Live Objects
  N_ObjLiveMark: Integer = (Byte('&') shl 24) or (Byte('&') shl 16) or (Byte('&') shl 8) or Byte('&');

type
  TN_CheckObjExecProcObj   = function  ( APObj : Pointer; ACheckPar : Integer ) : string of object;
  TN_CheckAllAddProcObj    = procedure ( APObj : Pointer; ACheckProcObj : TN_CheckObjExecProcObj ) of object;
  TN_CheckAllRemoveProcObj = procedure ( APObj : Pointer ) of object;
  TN_CheckAllExecProcObj   = procedure ( const ACheckMark : string ) of object;
  TN_CheckAllDumpProcObj   = procedure ( const ADumpStr   : string ) of object;

var
  N_CheckAllAdd    : TN_CheckAllAddProcObj;    // Add Element to Objects Control List
  N_CheckAllRemove : TN_CheckAllRemoveProcObj; // Remove Element from Objects Control List
  N_CheckAllExec   : TN_CheckAllExecProcObj;   // Execute all List Elements Check
  N_CheckAllDump   : TN_CheckAllDumpProcObj;   // Execute all List Elements Check

  N_DumpFileName : Ansistring = ''; // used in N_AddDateTimeToFile and N_AddStrToFile
//  N_DumpFileName : Ansistring = 'C:\CMSDumpTmp.txt';

  N_CurMemIni:  TMemIniFile; // Memory copy of Ini file
//  N_GlobMemIni: TMemIniFile; // Memory copy of Global Ini file
//  N_UserMemIni: TMemIniFile; // Memory copy of Global Ini file

//  N_e2v_DisarmDevice_empty : TN_IntFuncInt;

const // temporary
//  N_NewBaseForm = False; // New Base Form functionality (Screen DPI related)
  N_NewBaseForm = True; // New Base Form functionality (Screen DPI related)

var
  N_OtherDevices: Boolean = False; // Other devices code is working (set in N_CMResF)

implementation
uses SysUtils;

Initialization

{$IFDEF MSWindows}

{$IFDEF Delphi_GE_XE5} // Delphi >= XE5
  FormatSettings.DecimalSeparator := '.';
{$ELSE}               // Delphi 7 or Delphi 2010
  DecimalSeparator := '.';
{$ENDIF}

{$ENDIF}

end.
