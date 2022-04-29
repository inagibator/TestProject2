unit N_ImLib;
// Load and Save Raster Images using ImageLibrary.dll

interface
uses Windows, Classes, Graphics, Controls, SysUtils, Forms, Types,
     N_Types, N_Gra2, N_Lib0, K_RImage, K_Types;

// type TN_ILFileImageInfo        = packed record // info about one Image in File (filled by ILReadFileImageInfo)
// type TN_ILWriteImageProperties = packed record // needed write attributes
// type TN_ImageLibrary = class( TObject ) // Object for using ImageLibrary.dll
// type TN_RIILState    = (
// type TN_RIImLib      = class( TK_RasterImage )

type TN_ILFileImageInfo = packed record // info about one Image in File (filled by ILReadFileImageInfo)
  ILSelfSize          : Integer; // Self Size = SizeOf(TN_ILFileImageInfo) = 24
  ILContainerFormat   : Integer; // File format, N_ILFmt(BMP,PNG,JPG,TIF) constants
  ILCompressionFormat : Integer; // image Compression Format, N_ILCompr(None,PNG,JPEG,3) constantces
  ILColorFormat       : Integer; // Color Format, N_ILColorFmt(RGB,Pal,Gray)) constants
  ILSamplesPerPixel   : Integer; // Number of Samples Per Pixel (=3 for RGB, =1 for Grayscale)
  ILBitsPerSample     : Integer; // Number of Bits Per Sample (=8, for pf24bit, =16 for epfGray16)
end; // type TN_ILFileImageInfo = packed record
type TN_PILFileImageInfo = ^TN_ILFileImageInfo;

type TN_ILWriteImageProperties = packed record // needed write attributes
                       // for all subsequent Images (used in ILSetFileImageInfo)
  ILSelfSize          : Integer; // Self Size = SizeOf(TN_ILWriteImageProperties) = 12
  ILCompressionFormat : Integer; // image Compression Format, N_ILCompr(None,PNG,JPEG,3) constantces
  ILQuality           : Integer; // JPEG Quality (1..100)
end; // type TN_ILWriteImageProperties = packed record
type TN_PILWriteImageProperties = ^TN_ILWriteImageProperties;

type TN_ImageLibrary = class( TObject ) // Object for using ImageLibrary.dll
  ILDllHandle: THandle; // ImageLibrary.dll Handle (nil if not loaded)
  ILErrorStr:   string; // Error message
  ILErrorInt:  integer; // Error code

  //***** ImageLibrary.dll functions:
  //      AFName - File Name
  //      AFH    - File Handle
  //      AImInd - Image Index (for several images in TIFF files)
  //      AFmt   - File format as Integer (1..4 - BMP, PNG, JPEG, TIFF)
  //      AOverwrite - do not overwrite existing file if = 0
  ILOpenFileA:         TN_stdcallIntFuncPAChar;     // ( AFName: PAnsiChar )
  ILOpenFileW:         TN_stdcallIntFuncPWChar;     // ( AFName: PWideChar )
  ILOpenMemory:        TN_stdcallIntFuncPtrInt;     // ( APBuf: PByte; ABufSize: integer )
  ILGetImagesCount:    TN_stdcallIntFuncInt;        // ( AFH: integer )
  ILReadDIBInfo:       TN_stdcallIntFunc2IntPtr;    // ( AFH, AImInd: integer; APDIBInfo: TN_PDIBInfo )
  ILReadPixels:        TN_stdcallIntFunc2Int2Ptr;   // ( AFH, AImInd: integer; APBuf: PByte; APBufSize: PInteger )
  ILCreateFileA:       TN_stdcallIntFuncPAChar2Int; // ( AFName: PAnsiChar; AFmt, AOverwrite: integer )
  ILCreateFileW:       TN_stdcallIntFuncPWChar2Int; // ( AFName: PWideChar; AFmt, AOverwrite: integer )
  ILCreateImageBuffer: TN_stdcallIntFuncInt;        // ( AFmt: integer )
  ILWriteImage:        TN_stdcallIntFuncInt2Ptr;    // ( AFH: integer; APDIBInfo: TN_PDIBInfo; APBuf: PByte )
  ILGetImageBufferPtr: TN_stdcallIntFuncIntPtr;     // ( AFH: integer; APPBuf: PPByte )
  ILClose:             TN_stdcallIntFuncInt;        // ( AFH: integer )
  ILReadFileImageInfo: TN_stdcallIntFunc2IntPtr;    // ( AFH, AImInd: integer; APFileImageInfo: TN_PILFileImageInfo )
  ILSetFileImageInfo:  TN_stdcallIntFuncIntPtr;     // ( AFH: integer; APWriteImageProperties: TN_PILWriteImageProperties )
  ILSetLogFileName:    TN_stdcallProcPAChar;        // ( AFName: PAnsiChar )
  ILSetRotateParams:   TN_stdcallIntFunc2PDblInt;   // ( PForwAC6, PBackAC6: PAffCoefs6; AMode: Integer );
  ILRotateRect:        TN_stdcallIntFunc5Ptr;       // ( APSrcDIBInfo: TN_PDIBInfo; APSrcBuf: PByte; APSrcRect: PRect; APDstDIBInfo: TN_PDIBInfo; APDstBuf: PByte );

  //***** ImageLibrary.dll DICOM Export/Import functions:
  //
  ILDCMStartExport:      TK_stdcallIntFuncPtrIntPtrInt; // ( APExportPath : PWideChar; AExportMode : Integer; APPatInfo : TK_PCMDCMDPatientIn; APatCount : Integer ) : Integer;
  ILDCMAddImage:         TK_stdcallIntFuncPtr4Int2Ptr;  // ( AFName: PWideChar; APatInd, AStudyInd, ASeriesInd, AInstanceInd : Integer; APDIBInfo: TN_PDIBInfo; APBuf: PByte ) : Integer;
  ILDCMFinExport:        TK_stdcallIntFunc;             // ( ) : Integer;
  ILDCMStartImport:      TK_stdcallIntFunc3Ptr;         // ( APPImportFiles : ^PWideChar; APPPatInfo : TK_PPCMDCMDPatientIn; APPatCount : PInteger ) : Integer;
  ILDCMGetDIBInfo:       TK_stdcallIntFunc4IntPtr;      // ( APatInd, AStudyInd, ASeriesInd, AInstanceInd : Integer; APDIBInfo: TN_PDIBInfo ) : Integer;
  ILDCMGetPixels:        TK_stdcallIntFunc4Int2Ptr;     // ( APatInd, AStudyInd, ASeriesInd, AInstanceInd : Integer; APBuf: PByte; APBufSize: PInteger ) : Integer;
  ILDCMFinImport:        TK_stdcallIntFunc;             // ( ) : Integer;
  ILDCMSelectInstance:   TK_stdcallIntFunc4Int;         // ( APatInd, AStudyInd, ASeriesInd, AInstanceInd ) : Integer;
  ILDCMSelGetDIBInfo:    TK_stdcallIntFuncPtr;          // ( APDIBInfo: TN_PDIBInfo ) : Integer;
  ILDCMSelGetPixels:     TK_stdcallIntFunc2Ptr;         // ( APBuf: PByte; APBufSize: PInteger ) : Integer;
  ILDCMSelGetDICOMAttr:  TN_stdcallIntFunc2IntPtr;      // ( AGroup, AElement : Integer; APPAttrValue : ^PWideChar ) : Integer;
  ILDCMSelGetNamedAttr:  TK_stdcallIntFunc2Ptr;         // ( AttrName : PWideChar; PPAttrValue : ^PWideChar ) : Integer;

  //***** ImageLibrary.dll DICOM Query\Retrieve functions:
  //
  ILDCMStartQR:          TK_stdcallIntFunc2PtrIntPtr;   // ( APDCMServerName, APDCMServerIP : PAnsiChar; ADCMServerPort : Integer; APAEName : PAnsiChar ) : Integer;
  ILDCMFinishQR:         TK_stdcallIntFunc;             // ( ) : Integer;
  ILDCMQuery:            TK_stdcallIntFunc3Ptr;         // ( APQueryParams : TK_PCMDCMQParams; APPPatInfo : TK_PPCMDCMQPatientOut; APPatCount : PInteger ) : Integer;
  ILDCMRetrieve:         TK_stdcallIntFuncPtrInt2Ptr;   // ( APQResInds : PInteger; AQResIndsCount : Integer; APPPatInfo : TK_PPCMDCMDPatientIn; APPatCount : PInteger ) : Integer;

  constructor Create ();
  destructor  Destroy; override;

  function ILInitAll    (): Integer;
  function ILFreeAll    (): Integer;
  function ILOpenFile   ( AFName: string ): integer;
  function ILOpenStream ( AStream: TStream ): integer;
  function ILCreateFile ( AFName: string; AILFmt: Integer; AOverwrite: Integer = 1 ): integer;
end; // type TN_ImageLibrary = class( TObject ) // Object for using  ImageLibrary.dll

type TN_RIILState = (
  riilNoAct,              // no Activity
  riilReadFileStart,      // Read Data from File is started
  riilReadMemoryStart,    // Read Data from Memory is started
  riilWriteFileStart,     // Write Data to File is started
  riilWriteMemoryStart ); // Write Data to Memory is started

type TN_RIImLib = class( TK_RasterImage ) // Implementation of TK_RasterImage based on ImageLibrary.dll
  RIILHandle:        Integer;           // Encoding/Decoding Instance Handle
  RIILPEncodingInfo: TK_PRIFileEncInfo; // Write Image Attributes
  RIILNativeError:   Integer;           // ImageLibrary native error code

  constructor Create     (); override;
  destructor  Destroy    (); override;

  function  RIOpenFile   ( const AFileName: string ): TK_RIResult; override;
  function  RIOpenStream ( AStream: TStream ): TK_RIResult; override;
  function  RIOpenMemory ( APBuf: Pointer; ABufSize: Integer ): TK_RIResult; override;
  function  RIGetImageCount (): Integer; override;
  function  RIGetDIB        ( AImgInd: Integer; var ADIBObj: TN_DIBObj ): TK_RIResult; override;

  function  RICreateFile    ( const AFileName: string; APEncodingInfo: TK_PRIFileEncInfo ): TK_RIResult; override;
  function  RICreateStream  ( AStream: TStream; APEncodingInfo: TK_PRIFileEncInfo ): TK_RIResult; override;
  function  RICreateEncodeBuffer( APEncodingInfo: TK_PRIFileEncInfo ): TK_RIResult; override;
  function  RIAddDIBPixels      ( APDIBInfo: TN_PDIBInfo; APPixels: Pointer ): TK_RIResult; override;
  function  RIGetEncodeBuffer   ( out APBuf: Pointer; out ABufSize: Integer ): TK_RIResult; override;

  function  RIObjectReady (): Boolean; override;
  function  RIClose (): TK_RIResult; override;
  function  RIClear (): TK_RIResult; override;
  function  RIGetLastNativeErrorCode (): Integer; override;  // Get Last Native Error Code

  private
  RIILStreamBuf: TN_BArray;
  RIILState:     TN_RIILState;
  RIILStream:    TStream;
  RIILErrorCode: Integer;

  function  RIILFormatFromRIType ( ARICurEncType: TK_RIFileEncType ): Integer;
  function  RITypeFromILFormat   ( AILFormat: Integer ): TK_RIFileEncType;
  procedure RIFillWriteImageProperties ( APWriteImageProperties: TN_PILWriteImageProperties );
end; // type TN_RIImLib

const // Constants used in ImageLibrary.dll
  N_ILFmtBMP  = 1; // BMP format
  N_ILFmtPNG  = 2; // PNG format
  N_ILFmtJPG  = 3; // JPG format
  N_ILFmtTIF  = 4; // TIFF format
  N_ILFmtDCM  = 5; // DICOM format
  N_ILFmtJPL1 = 6; // Lossles JPG Lossless-1 format
  N_ILFmtJPL2 = 7; // Lossles JPG-LS format for greyscal only

  N_ILComprNone = 0; // no Compression
  N_ILComprPNG  = 1; // PNG Compression
  N_ILComprJPEG = 2; // JPEG Compression
  N_ILCompr3    = 3; // Other Compression

  N_ILColorFmtRGB  = 0; // RGB Color Format
  N_ILColorFmtPal  = 1; // Paletted Color Format
  N_ILColorFmtGray = 2; // Grayscale Color Format

  N_ILNearest      = 0; // Nearest (fastest) Rotate mode (used in ILSetRotateParams)
  N_ILBiLinear     = 1; // BiLinear Rotate mode (used in ILSetRotateParams)
  N_ILBiCubic      = 2; // BiCubic (best quality) Rotate mode (used in ILSetRotateParams)

var
  N_ImageLib: TN_ImageLibrary;

implementation
uses Dialogs,
  K_CLib0,
  N_Lib1;

//********************* TN_ImageLibrary class methods  **********************

//************************************************** TN_ImageLibrary.Create ***
//
constructor TN_ImageLibrary.Create();
begin
//  ILInitAll();
end; // constructor TN_ImageLibrary.Create();

//************************************************* TN_ImageLibrary.Destroy ***
//
destructor TN_ImageLibrary.Destroy;
begin
//  ILFreeAll();
  Inherited;
end; //*** end of destructor TN_ImageLibrary.Destroy

//*********************************************** TN_ImageLibrary.ILInitAll ***
// Load all ImageLibrary.dll entries
//
function TN_ImageLibrary.ILInitAll(): integer;
var
  Str: String;
  FuncAnsiName, LogAnsiFName: AnsiString;
  DllFName: string;  // DLL File Name
  DCMVerOld1 : Boolean;
  DCMVerBeforeRes : Integer;

  procedure ReportError(); // local
  // Report that FuncAnsiName function was not loaded
  begin
    ILErrorStr := String(FuncAnsiName) + ' not loaded';
    N_Dump1Str( ILErrorStr );
    Result := 3; // some entries were not loaded
  end; // procedure ReportError(); // local

begin
  Result := 0;
  if ILDllHandle <> 0 then // ImageLibrary.dll already initialized
    Exit;

  DllFName := 'ImageLibrary.dll';
  ILErrorStr := '';

//  N_Dump1Str( 'Before Windows.LoadLibrary ' + DllFName );
  ILDllHandle := Windows.LoadLibrary( @DllFName[1] );
  N_Dump1Str( Format( 'After Windows.LoadLibrary %s, ILDllHandle=%X', [DllFName,ILDllHandle] ) );

  if ILDllHandle = 0 then // some error
  begin
    ILErrorStr := 'Error Loading ' + DllFName + ': ' + SysErrorMessage( GetLastError() );
    Result := 2; // Windows.LoadLibrary failed
//    K_CMShowMessageDlg( ILErrorStr, mtError );
    N_Dump1Str( ILErrorStr );
    Exit;
  end; // if ILDllHandle = 0 then // some error

  //***** Load ImageLibrary.dll functions

  FuncAnsiName := 'OpenFileA';
//  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  ILOpenFileA := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILOpenFileA) then ReportError();

  FuncAnsiName := 'OpenFileW';
//  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  ILOpenFileW := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILOpenFileW) then ReportError();

  FuncAnsiName := 'OpenMemory';
//  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  ILOpenMemory := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILOpenMemory) then ReportError();

  FuncAnsiName := 'GetImagesCount';
//  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  ILGetImagesCount := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILGetImagesCount) then ReportError();

  FuncAnsiName := 'ReadDIBInfo';
//  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  ILReadDIBInfo := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILReadDIBInfo) then ReportError();

  FuncAnsiName := 'ReadPixels';
//  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  ILReadPixels := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILReadPixels) then ReportError();

  FuncAnsiName := 'CreateFileA';
//  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  ILCreateFileA := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILCreateFileA) then ReportError();

  FuncAnsiName := 'CreateFileW';
//  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  ILCreateFileW := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILCreateFileW) then ReportError();

  FuncAnsiName := 'CreateImageBuffer';
//  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  ILCreateImageBuffer := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILCreateImageBuffer) then ReportError();

  FuncAnsiName := 'WriteImage';
//  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  ILWriteImage := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILWriteImage) then ReportError();

  FuncAnsiName := 'GetImageBufferPtr';
//  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  ILGetImageBufferPtr := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILGetImageBufferPtr) then ReportError();

  FuncAnsiName := 'Close';
//  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  ILClose := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILClose) then ReportError();

  FuncAnsiName := 'ReadFileImageInfo';
  ILReadFileImageInfo := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILReadFileImageInfo) then ReportError();

  FuncAnsiName := 'SetFileImageInfo';
  ILSetFileImageInfo := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILSetFileImageInfo) then ReportError();

  FuncAnsiName := 'SetLogFileName';
  ILSetLogFileName := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILSetLogFileName) then ReportError();

  FuncAnsiName := 'SetRotateParams';
  ILSetRotateParams := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILSetRotateParams) then ReportError();

  FuncAnsiName := 'RotateRect';
  ILRotateRect := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILRotateRect) then ReportError();
{DICOM routines}
  FuncAnsiName := 'DCMStartExport';
  ILDCMStartExport := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMStartExport) then ReportError();

  FuncAnsiName := 'DCMAddImage';
  ILDCMAddImage := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMAddImage) then ReportError();

  FuncAnsiName := 'DCMFinExport';
  ILDCMFinExport := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMFinExport) then ReportError();

  FuncAnsiName := 'DCMStartImport';
  ILDCMStartImport := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMStartImport) then ReportError();

  FuncAnsiName := 'DCMGetDIBInfo';
  ILDCMGetDIBInfo := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMGetDIBInfo) then ReportError();

  FuncAnsiName := 'DCMGetPixels';
  ILDCMGetPixels := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMGetPixels) then ReportError();

  FuncAnsiName := 'DCMFinImport';
  ILDCMFinImport := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMFinImport) then ReportError();

  DCMVerBeforeRes := Result;
  Result := 0;
  DCMVerOld1 := FALSE;
  FuncAnsiName := 'DCMSelectInstance';
  ILDCMSelectInstance := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMSelectInstance) then
  begin
    ReportError();
    DCMVerOld1 := TRUE;
    Result := 0;
  end;

  FuncAnsiName := 'DCMSelGetDIBInfo';
  ILDCMSelGetDIBInfo := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMSelGetDIBInfo) then
  begin
    ReportError();
    if DCMVerOld1 then
      Result := 0;
  end
  else
    DCMVerOld1 := FALSE;

  FuncAnsiName := 'DCMSelGetPixels';
  ILDCMSelGetPixels := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMSelGetPixels) then
  begin
    ReportError();
    if DCMVerOld1 then
      Result := 0;
  end
  else
    DCMVerOld1 := FALSE;

  FuncAnsiName := 'DCMSelGetDICOMAttr';
  ILDCMSelGetDICOMAttr := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMSelGetDICOMAttr) then
  begin
    ReportError();
    if DCMVerOld1 then
      Result := 0;
  end
  else
    DCMVerOld1 := FALSE;

  FuncAnsiName := 'DCMSelGetNamedAttr';
  ILDCMSelGetNamedAttr := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMSelGetNamedAttr) then
  begin
    ReportError();
    if DCMVerOld1 then
      Result := 0;
  end
  else
    DCMVerOld1 := FALSE;

  if (DCMVerOld1) or (Result = 0) then
    Result := DCMVerBeforeRes;

{DICOM Query\Retrieve routines}
  DCMVerBeforeRes := Result;
  Result := 0;
  DCMVerOld1 := FALSE;
  FuncAnsiName := 'DCMStartQR';
  ILDCMStartQR := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMSelectInstance) then
  begin
    ReportError();
    DCMVerOld1 := TRUE;
    Result := 0;
  end;

  FuncAnsiName := 'DCMFinishQR';
  ILDCMFinishQR := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMSelGetNamedAttr) then
  begin
    ReportError();
    if DCMVerOld1 then
      Result := 0;
  end
  else
    DCMVerOld1 := FALSE;

  FuncAnsiName := 'DCMQuery';
  ILDCMQuery := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMSelGetNamedAttr) then
  begin
    ReportError();
    if DCMVerOld1 then
      Result := 0;
  end
  else
    DCMVerOld1 := FALSE;

  FuncAnsiName := 'DCMRetrieve';
  ILDCMRetrieve := GetProcAddress( ILDllHandle, @FuncAnsiName[1] );
  if not Assigned(ILDCMSelGetNamedAttr) then
  begin
    ReportError();
    if DCMVerOld1 then
      Result := 0;
  end
  else
    DCMVerOld1 := FALSE;

  if (DCMVerOld1) or (Result = 0) then
    Result := DCMVerBeforeRes;

{}

  if Assigned(ILSetLogFileName) then // Set LogFileName if needed
  begin
    if N_MemIniToBool( 'CMS_UserDeb', 'ImageLibraryLog', FALSE ) then // Log is needed
    begin
      LogAnsiFName := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) + 'ImageLib.txt' );
      ILSetLogFileName( @LogAnsiFName[1] );
    end; // if N_MemIniToBool( 'CMS_UserDeb', 'ImageLibraryLog', FALSE ) then // Log is needed
  end; // if Assigned(ILSetLogFileName) then // Set LogFileName if needed

  if Result <> 0 then // some error while loading DLL Entries
  begin
    Str := Format( 'Failed to initialise %s Errorcode=%d', [DllFName, Result] );
//    K_CMShowMessageDlg( Str, mtError );
    N_Dump1Str( Str );

    ILFreeAll();
    N_Dump1Str( DllFName + ' Resources freed' );
  end;

  N_Dump1Str( 'Finish TN_ImageLibrary.ILInitAll' );
end; //*** end of function TN_ImageLibrary.ILInitAll

//*********************************************** TN_ImageLibrary.ILFreeAll ***
// Free ImageLibrary.dll
//
function TN_ImageLibrary.ILFreeAll(): integer;
begin
  if ILDLLHandle <> 0 then
  begin
    FreeLibrary( ILDLLHandle );
    ILDLLHandle := 0;
  end; // if ILDLLHandle <> 0 then

  Result := 0; // freed OK
end; //*** end of function TN_ImageLibrary.ILFreeAll

//********************************************** TN_ImageLibrary.ILOpenFile ***
// Open File for reading images
//
//     Parameters
// AFName - File Name to open for reading
// Result - Opened File Handle (if > 0) or error code (if < 0)
//
function TN_ImageLibrary.ILOpenFile( AFName: string ): integer;
begin
  if ILDLLHandle = 0 then // not initialized yet
  begin
    if ILInitAll() = 0 then // initialization error
    begin
      Result := -100;
      Exit;
    end;
  end; // if ILDLLHandle = 0 then // not initialized yet

  if Length( AFName ) = 0 then
  begin
    Result := -101;
    Exit;
  end;

{$IF SizeOf(Char) = 2} // Wide Chars (>= Delphi 2010) Types and constants
  Result := ILOpenFileW( @AFName[1] );
{$ELSE} //*************** Ansi Chars (Delphi 7) Types and constants
  Result := ILOpenFileA( @AFName[1] );
{$IFEND}

end; //*** end of function TN_ImageLibrary.ILOpenFile

//******************************************** TN_ImageLibrary.ILOpenStream ***
// Open AStream for reading images
//
//     Parameters
// AStream - Stream to open for reading
// Result  - Opened Stream Handle (if > 0) or error code (if < 0)
//
function TN_ImageLibrary.ILOpenStream( AStream: TStream ): integer;
begin
  if ILDLLHandle = 0 then // not initialized yet
  begin
    if ILInitAll() = 0 then // initialization error
    begin
      Result := -102;
      Exit;
    end;
  end; // if ILDLLHandle = 0 then // not initialized yet

  Result := 0;
end; //*** end of function TN_ImageLibrary.ILOpenStream

//******************************************** TN_ImageLibrary.ILCreateFile ***
// Create File for writing images
//
//     Parameters
// AFName     - File Name to Create for writung
// AILFmt     - Given needed File format
// AOverwrite - <>0 - overwrite existng file (=0 - do not overwrite)
// Result     - Createed File Handle (if > 0) or error code (if < 0)
//
function TN_ImageLibrary.ILCreateFile( AFName: string; AILFmt: Integer;
                                       AOverwrite: integer = 1 ): integer;
begin
  if ILDLLHandle = 0 then // not initialized yet
  begin
    if ILInitAll() = 0 then // initialization error
    begin
      Result := -103;
      Exit;
    end;
  end; // if ILDLLHandle = 0 then // not initialized yet

  if Length( AFName ) = 0 then
  begin
    Result := -104;
    Exit;
  end;

{$IF SizeOf(Char) = 2} // Wide Chars (>= Delphi 2010) Types and constants
  Result := ILCreateFileW( @AFName[1], AILFmt, AOverwrite );
{$ELSE} //*************** Ansi Chars (Delphi 7) Types and constants
  Result := ILCreateFileA( @AFName[1], AILFmt, AOverwrite );
{$IFEND}

end; //*** end of function TN_ImageLibrary.ILCreateFile


//********************* TN_RIImLib class methods  **********************

//******************************************************* TN_RIImLib.Create ***
//
constructor TN_RIImLib.Create;
begin
  inherited;
  // ILInitAll should be called after Path to folder with DLL files is OK,
  // so TN_RIImLib Constructor shuld be call also after folder with DLL files is OK
  RIILNativeError := N_ImageLib.ILInitAll();
end; // constructor TN_RIImLib.Create

//****************************************************** TN_RIImLib.Destroy ***
//
destructor TN_RIImLib.Destroy;
begin
  // call to N_ImageLib.ILFreeAll() is only in Finalization section
  inherited;
end; // destructor TN_RIImLib.Destroy

//*************************************************** TN_RIImLib.RIOpenFile ***
// Open File with encoded Raster Image instance (Start reading from File)
//
//    Parameters
// AFileName - given file name with encoded Raster Image
// Result    - Returns resulting code
//
function TN_RIImLib.RIOpenFile( const AFileName: string ): TK_RIResult;
begin
  Result := rirFails;
  RIILErrorCode   := 0;
  RIILNativeError := 1000;
  if N_ImageLib.ILDllHandle = 0 then Exit;

  RIILHandle := N_ImageLib.ILOpenFile( AFileName );

  if RIILHandle <= 0 then // error
  begin
    RIILNativeError := 2000 + RIILHandle;
    RIILErrorCode := RIILHandle;
    RIILState := riilNoAct;
    RIILHandle := 0;
    Result := rirFails;
  end else // all OK
  begin
    RIILState := riilReadFileStart;
    RICurEncType := RITypeFromILFormat( -1 );
    RIILNativeError := 0;
    Result := rirOK;
  end;
end; // function TN_RIImLib.RIOpenFile

//************************************************* TN_RIImLib.RIOpenStream ***
// Open Stream with encoded Raster Image instance (Start reading from Stream)
//
//    Parameters
// AStream - given Stream object
// Result  - Returns resulting code
//
function TN_RIImLib.RIOpenStream( AStream: TStream ): TK_RIResult;
var
  AStreamSize: Integer;
begin
  Result := rirFails;
  RIILErrorCode   := 0;
  RIILNativeError := 1100;
  if N_ImageLib.ILDllHandle = 0 then Exit;

  if AStream is TCustomMemoryStream then
    Result := RIOpenMemory( TCustomMemoryStream(AStream).Memory, AStream.Seek( 0, soEnd ) )
  else
  begin
    AStreamSize := AStream.Seek( 0, soEnd );
    if AStreamSize = 0 then
    begin
      RIILStreamBuf := nil;
      Result := rirFails;
      RIILNativeError := 5000;
      Exit;
    end;

    try
      SetLength( RIILStreamBuf, AStreamSize );
    except
      RIILStreamBuf := nil;
      Result := rirOutOfMemory;
      RIILNativeError := 5001;
      Exit;
    end;

    AStream.Seek( 0, soBeginning );
    AStream.Read( RIILStreamBuf[0], AStreamSize );

    Result := RIOpenMemory( @RIILStreamBuf[0], AStreamSize );

  end;

  if Result <> rirOK then // error, RIILNativeError was already set by RIOpenMemory
  begin
    RIILErrorCode := Integer(Result);
    RIILStreamBuf := nil;
  end else // all OK
  begin
    RIILNativeError := 0;
    Exit; // all done OK
  end;

end; // function TN_RIImLib.RIOpenStream

//************************************************* TN_RIImLib.RIOpenMemory ***
// Open Memory with encoded Raster Image instance (Start reading from Memory)
//
//    Parameters
// APBuf    - given pointer to Memory Bufer for writing image
// ABufSize - given Memory Bufer Size
// Result   - Returns resulting code
//
function TN_RIImLib.RIOpenMemory( APBuf: Pointer; ABufSize: Integer ): TK_RIResult;
begin
  Result := rirFails;
  RIILErrorCode   := 0;
  RIILNativeError := 1200;
  if N_ImageLib.ILDllHandle = 0 then Exit;

  RIILHandle := N_ImageLib.ILOpenMemory( APBuf, ABufSize );

  if RIILHandle <= 0 then // error
  begin
    RIILNativeError := 2100 + RIILHandle;
    RIILErrorCode := RIILHandle;
    RIILHandle := 0;
    RIILState := riilNoAct;
    Result := rirFails;
  end else // all OK
  begin
    RIILState := riilReadMemoryStart;
    RICurEncType := RITypeFromILFormat( -1 );
    RIILNativeError := 0;
    Result := rirOK;
  end;
end; // function TN_RIImLib.RIOpenMemory

//********************************************** TN_RIImLib.RIGetImageCount ***
// Get Raster Image instance Frames counter
//
//    Parameters
// Result - Raster Image Frames counter
//
function TN_RIImLib.RIGetImageCount(): Integer;
begin
  Result := 0;
  RIILErrorCode   := 0;
  RIILNativeError := 1300;
  if (N_ImageLib.ILDllHandle = 0) or (RIILHandle = 0) then Exit;

  if (RIILState <> riilReadFileStart) and
     (RIILState <> riilReadMemoryStart) then Exit;

  Result := N_ImageLib.ILGetImagesCount( RIILHandle );

  if Result < 0 then // error
  begin
    RIILNativeError := 2200 + Result;
    RIILErrorCode   := Result;
  end else // all OK
  begin
    RIILNativeError := 0;
  end;
end; // function TN_RIImLib.RIGetImageCount

//***************************************************** TN_RIImLib.RIGetDIB ***
// Get DIB Object from serialized Raster Image instance
//
//    Parameters
// AImgInd - given Raster Image Frame Index
// ADIBObj - Resulting DIB
// Result  - Returns resulting code
//
// 1) If ADIBObj = nil then new DIB object will be created
// 2) Paletted (Color8) Images are converted to Color24 images
// 3) Too big images are reduced
// 4) Temporary, too big 16 bit images are converted to Gray8
//
function TN_RIImLib.RIGetDIB( AImgInd: Integer; var ADIBObj: TN_DIBObj ): TK_RIResult;
var
  DIBInfo: TN_DIBInfo;
  NeededSize: TPoint;
  BufSize, OriginalPelsPerMeter: Integer;
  WDIBObj: TN_DIBObj;
  XLAT: TN_IArray;
  HMem: THandle;
begin
  Result          := rirFails;
  RIILErrorCode   := 0;
  RIILNativeError := 1400;
  RILastImageSize := Point( 0, 0 );
  if (N_ImageLib.ILDllHandle = 0) or (RIILHandle = 0) then Exit;

  RIILNativeError := 2300;
  if (RIILState <> riilReadFileStart) and
     (RIILState <> riilReadMemoryStart) then Exit;

  ZeroMemory( @DIBInfo, SizeOf(DIBInfo) );
  DIBInfo.bmi.biSize := SizeOf(DIBInfo.bmi);

  RIILErrorCode := N_ImageLib.ILReadDIBInfo( RIILHandle, AImgInd, @DIBInfo );
  RIILNativeError := 3000 + RIILErrorCode;

  if RIILErrorCode < 0 then Exit;

  with DIBInfo.bmi do
  begin
    RILastImageSize := Point( biWidth, abs(biHeight) );

    if (biWidth <= 0) or (biHeight <= 0) then // bad Width or Height
    begin
      N_SL.Clear;
      N_DIBInfoToStrings( @DIBInfo, 'RIGetDIB', N_SL );
      N_Dump1Strings( N_SL );

      RIILNativeError := 3500;
      Exit;
    end;
  end;

  //***** DIBInfo is OK, create WDIBObj and read pixels to it
  WDIBObj := TN_DIBObj.Create();
  try
    WDIBObj.PrepEmptyDIBObj( @DIBInfo, -1, epfAutoAny, 16 );
  except
    Result := rirOutOfMemory;
    RIILNativeError := 4000;
    WDIBObj.Free;
    Exit;
  end; // except

  BufSize := WDIBObj.DIBSize.Y * WDIBObj.RRLineSize;

  // Check if there is enough memory for N_ImageLib.ILReadPixels
  HMem := Windows.GlobalAlloc( GMEM_MOVEABLE, BufSize );
  if HMem = 0 then // not enough memory
  begin
    N_Dump1Str( format( 'TN_RIImLib.RIGetDIB check memory alloc fails %d fails', [BufSize] ) );
{
    Result := rirOutOfMemory;
    RIILNativeError := 6000;
    WDIBObj.Free;
    Exit;
{}
  end
  else // all OK
    Windows.GlobalFree( HMem );

  RIILErrorCode := N_ImageLib.ILReadPixels( RIILHandle, AImgInd, WDIBObj.PRasterBytes, @BufSize );

  if RIILErrorCode < 0 then // error
  begin
    RIILNativeError := 6100 + RIILErrorCode;
    WDIBObj.Free;
    Exit;
  end;

  //***** Convert WDIBObj to pf24bit ADIBObj if it is paletted

  if (WDIBObj.DIBPixFmt = pf8bit) and (WDIBObj.DIBExPixFmt = epfBMP) then // conv WDIBObj to pf24bit ADIBObj
  begin
    SetLength( XLAT, 256 );
    move( WDIBObj.DIBInfo.PalEntries[0], XLAT[0], 256*SizeOf(Integer) );
    WDIBObj.CalcXLATDIB( ADIBObj, 0, @XLAT[0], 3, pf24bit, epfBMP );
    WDIBObj.Free;
  end else // WDIBObj is OK, return it
  begin
    if Assigned(ADIBObj) then
      ADIBObj.Free;
    ADIBObj := WDIBObj;
  end;

  //***** Here: ADIBObj is OK and is not Paletted, reduce it if needed
  //            RILastImageSize is OK here

  NeededSize := RIGetDIBMaxSize( RILastImageSize );

  OriginalPelsPerMeter := ADIBObj.DIBInfo.bmi.biXPelsPerMeter; // Original resolution

  if (NeededSize.X < RILastImageSize.X) or (NeededSize.Y < RILastImageSize.Y) then // Resample
  begin
    if ADIBObj.DIBExPixFmt = epfGray16 then // temporary convert to pf24bit for drawing
    begin
      WDIBObj := TN_DIBObj.Create();
      try
        WDIBObj.PrepEmptyDIBObj( ADIBObj.DIBSize.X, ADIBObj.DIBSize.Y, pf24bit );
      except
        Result := rirOutOfMemory;
        RIILNativeError := 7000;
        WDIBObj.Free;
        Exit;
      end; // except

      WDIBObj.CopyRectAuto( Point(0,0), ADIBObj, ADIBObj.DIBRect );
      ADIBObj.Free;
      ADIBObj := WDIBObj;
    end; // if ADIBObj.DIBExPixFmt = epfGray16 then // temporary convert to pf24bit for drawing

    // Reduce ADIBObj Size to NeededSize by drawing (by N_StretchRect)

    WDIBObj := TN_DIBObj.Create();
    try
      WDIBObj.PrepEmptyDIBObj( NeededSize.X, NeededSize.Y, pf24bit );
    except
      Result := rirOutOfMemory;
      RIILNativeError := 8000;
      WDIBObj.Free;
      ADIBObj.Free;
      Exit;
    end; // except

    N_StretchRect( WDIBObj.DIBOCanv.HMDC, WDIBObj.DIBRect, ADIBObj.DIBOCanv.HMDC, ADIBObj.DIBRect );
    ADIBObj.Free;
    ADIBObj := WDIBObj;

    //****  Set final resolution to ADIBObj

    ADIBObj.DIBInfo.bmi.biXPelsPerMeter :=
      Round( 1.0 * OriginalPelsPerMeter * NeededSize.X / RILastImageSize.X );

    ADIBObj.DIBInfo.bmi.biYPelsPerMeter :=
      Round( 1.0 * OriginalPelsPerMeter * NeededSize.Y / RILastImageSize.Y );

  end; // if (NeededSize.X < RILastImageSize.X) or (NeededSize.Y < RILastImageSize.Y) then // Resample

  RIILErrorCode   := 0;
  RIILNativeError := 0;
  Result := rirOK;
end; // function TN_RIImLib.RIGetDIB

//************************************************* TN_RIImLib.RICreateFile ***
// Create File for Raster Image Encoding instance (Start writing to File)
//
//    Parameters
// AFileName    - given File Name for Raster Image
// APCodingInfo - given Pointer to Raster Image Encoding Attributes
// Result       - Returns resulting code
//
function TN_RIImLib.RICreateFile( const AFileName: string;
                                  APEncodingInfo: TK_PRIFileEncInfo ): TK_RIResult;
var
  IMLibFormat: Integer;
begin
  Result := rirFails;
  RIILErrorCode   := 0;
  RIILNativeError := 1500;
  RIILPEncodingInfo := APEncodingInfo;
  RICurEncType := RIILPEncodingInfo.RIFileEncType;

  if RICurEncType = rietNotDef then
    RICurEncType := RIEncTypeByFileExt( AFileName );

  if RICurEncType = rietNotDef then Exit; // error, unkown File Extension

  IMLibFormat := RIILFormatFromRIType( RICurEncType );

  if IMLibFormat <= 0 then // a precaution, bad RICurEncType
  begin
    RIILNativeError := 2400;
    Exit;
  end;

  RIILState := riilWriteFileStart;
  RIILHandle := N_ImageLib.ILCreateFile( AFileName, IMLibFormat );

  if RIILHandle < 0 then // error
  begin
    RIILNativeError := 3100 + RIILHandle;
    RIILErrorCode := RIILHandle;
    RIILHandle := 0;
    Result := rirFails;
  end else // all OK
  begin
    RIImgByFileEncInfo( RIILPEncodingInfo ); // set image format for subsequent writing
    RIILNativeError := 0;
    Result := rirOK;
  end;
end; // function TN_RIImLib.RICreateFile

//*********************************************** TN_RIImLib.RICreateStream ***
// Create Stream for Raster Image Encoding instance (Start writing to Stream)
//
//    Parameters
// AStream      - given Stream object
// APCodingInfo - given Pointer to Raster Image Encoding Attributes
// Result       -  Returns resulting code
//
function TN_RIImLib.RICreateStream( AStream: TStream;
                                    APEncodingInfo: TK_PRIFileEncInfo ): TK_RIResult;
begin
  Result := RICreateEncodeBuffer( APEncodingInfo );

  if Result <> rirOK then
  begin
    RIILErrorCode := Integer(Result);
    RIILNativeError := 1600 + Integer(Result);
    Exit;
  end else // all OK
  begin
    RIILStream := AStream;
    RIILErrorCode := 0;
    RIILNativeError := 0;
  end;
end; // function TN_RIImLib.RICreateStream

//***************************************** TN_RIImLib.RICreateEncodeBuffer ***
// Create Memory Buffer for Raster Image Encoding instance (Start writing to Memory)
//
//    Parameters
// APEncodingInfo - given Pointer to Raster Image Encoding Attributes
// Result         - Returns resulting code
//
function TN_RIImLib.RICreateEncodeBuffer( APEncodingInfo: TK_PRIFileEncInfo ): TK_RIResult;
var
  IMLibFormat: Integer;
begin
  Result := rirFails;
  RIILErrorCode := 0;
  RIILNativeError := 1700;
  RIILPEncodingInfo := APEncodingInfo;
  RICurEncType := RIILPEncodingInfo^.RIFileEncType;

  if RICurEncType = rietNotDef then Exit; // error, unkown File Format

  IMLibFormat := RIILFormatFromRIType( RICurEncType );

  if IMLibFormat <= 0 then // a precaution, bad RICurEncType
  begin
    RIILNativeError := 2600 + IMLibFormat;
    Exit;
  end;

  RIILState := riilWriteMemoryStart;
  RIILHandle := N_ImageLib.ILCreateImageBuffer( IMLibFormat );

  if RIILHandle < 0 then // error
  begin
    RIILErrorCode := RIILHandle;
    RIILNativeError := 3200 + RIILHandle;
    RIILHandle := 0;
    Result := rirFails;
  end else // all OK
  begin
    RIImgByFileEncInfo( RIILPEncodingInfo ); // set image format for subsequent writing
    RIILNativeError := 0;
    Result := rirOK;
  end;
end; // function TN_RIImLib.RICreateEncodeBuffer

//*********************************************** TN_RIImLib.RIAddDIBPixels ***
// Add DIB Pixels (add Image) to serialized Raster Image instance
//
//    Parameters
// APDIBInfo - pointer to DIBInfo with Pixels structure description
// APPixels  - pointer to DIB Pixels
// Result    -  Returns resulting code
//
function TN_RIImLib.RIAddDIBPixels( APDIBInfo: TN_PDIBInfo; APPixels: Pointer ): TK_RIResult;
var
  ILWriteImageProperties: TN_ILWriteImageProperties;
begin
  Result := rirFails;
  RIILErrorCode := 0;
  RIILNativeError := 1800;

  if (N_ImageLib.ILDllHandle = 0) or
     (RIILHandle = 0)             or
     ((RIILState <> riilWriteMemoryStart) and
      (RIILState <> riilWriteFileStart)) then Exit;

  RIFillWriteImageProperties( @ILWriteImageProperties );
  N_ImageLib.ILSetFileImageInfo( RIILHandle, @ILWriteImageProperties );

  RIILErrorCode := N_ImageLib.ILWriteImage( RIILHandle, APDIBInfo, APPixels );
//  N_p := @(APDIBInfo^);

  if RIILErrorCode < 0 then // error
  begin
    RIILNativeError := 2700 + RIILErrorCode;
    Result := rirFails;
  end else // all OK
  begin
    RIILNativeError := 0;
    Result := rirOK;
  end;
end; // function TN_RIImLib.RIAddDIBPixels

//******************************************** TN_RIImLib.RIGetEncodeBuffer ***
// Get Buffer with resulting Encoding Data (Size and Pointer)
//
//    Parameters
// APBuf    - Raster Image encoding buffer resulting pointer (on output)
// ABufSize - Raster Image encoding buffer resulting size (on output)
// Result   -  Returns resulting code
//
function TN_RIImLib.RIGetEncodeBuffer( out APBuf: Pointer;
                                       out ABufSize: Integer ): TK_RIResult;
begin
  Result := rirFails;
  RIILErrorCode := 0;
  RIILNativeError := 1900;

  if (N_ImageLib.ILDllHandle = 0) or
     (RIILHandle = 0)             or
     (RIILState <> riilWriteMemoryStart) then Exit;

  ABufSize := N_ImageLib.ILGetImageBufferPtr( RIILHandle, Pointer(@APBuf) );

  if ABufSize < 0 then // error
  begin
    RIILErrorCode := ABufSize;
    RIILNativeError := 2800 + ABufSize;
    Result := rirFails;
  end else
  begin
    RIILErrorCode := 0;
    RIILNativeError := 0;
    Result := rirOK;
  end;
end; // function TN_RIImLib.RIGetEncodeBuffer

//************************************************ TN_RIImLib.RIObjectReady ***
// Check if object is ready to work after contructor
//
//    Parameters
// Result -  Returns TRUE if object is ready to work
//
function TN_RIImLib.RIObjectReady(): Boolean;
begin
  Result := N_ImageLib.ILDllHandle <> 0;
end; // function TN_RIImLib.RIObjectReady

//****************************************************** TN_RIImLib.RIClear ***
// Clear All Raster Image resources
//
//    Parameters
// Result -  Returns resulting code
//
function TN_RIImLib.RIClear: TK_RIResult;
begin
  Result := inherited RIClear();

  RIILStreamBuf := nil;
  RIILStream := nil;
  RIILState := riilNoAct;
  FillChar( RIImgEncInfo, 0, SizeOf(RIImgEncInfo) );
end; // function TN_RIImLib.RIClear

//****************************************************** TN_RIImLib.RIClose ***
// Finish serialized Raster Image saving (Finish writing Image)
//
//    Parameters
// Result - Returns resulting code
//
function TN_RIImLib.RIClose: TK_RIResult;
var
  BufSize: Integer;
  BufPtr: Pointer;
begin
  Result := rirFails;
  RIILErrorCode := 0;
  RIILNativeError := 900;

  if (N_ImageLib.ILDllHandle = 0) or (RIILHandle = 0) then Exit;

  RIILNativeError := 0;

  if RIILStream <> nil then // implement writing to Stream by writing to Memory
  begin
    Result := RIGetEncodeBuffer( BufPtr, BufSize );

    if Result = rirOK then
    begin
      RIILStream.Seek( 0, soBeginning );
      RIILStream.Write( BufPtr^, BufSize );
    end else // error
    begin
      RIILNativeError := 2900 + Integer(Result);
    end;
  end; // if RIILStream <> nil then // implement writing to Stream by writing to Memory

  if RIILNativeError <> 0 then // RIGetEncodeBuffer error
  begin
    N_ImageLib.ILClose( RIILHandle );
    RIClear();
    Exit;
  end;

  RIILErrorCode := N_ImageLib.ILClose( RIILHandle );

  if RIILErrorCode < 0 then // error
  begin
    RIILNativeError := 3400 + RIILErrorCode;
    Result := rirFails;
  end else // all OK
  begin
    RIILNativeError := 0;
    RIILErrorCode := 0;
    Result := rirOK;
  end;

  RIILHandle := 0;
  RIClear();
end; // function TN_RIImLib.RIClose

//************************************* TN_RIImLib.RIGetLastNativeErrorCode ***
// Get Last Native Error Code
//
//    Parameters
// Result -  Returns Last Native Error Code
//
function TN_RIImLib.RIGetLastNativeErrorCode: Integer;
begin
  Result := RIILNativeError;
end; // function TN_RIImLib.RIGetLastNativeErrorCode


//***************************************** TN_RIImLib.RIILFormatFromRIType ***
// Get Image Library Container Format from Raster Image Encoding Format
//
//    Parameters
// ARICurEncType - Raster Image Encoding Format
// Result        - Returns Image Library Container Format
//
function TN_RIImLib.RIILFormatFromRIType( ARICurEncType: TK_RIFileEncType ): Integer;
begin
  Result := 0;

  case ARICurEncType of
    rietBMP: Result := N_ILFmtBMP;  // BMP
    rietPNG: Result := N_ILFmtPNG;  // PNG
    rietJPG: Result := N_ILFmtJPG;  // JPG
    rietTIF: Result := N_ILFmtTIF;  // TIF
    rietJPL1:Result := N_ILFmtJPL1; // JPG lossless 1
    rietJPL2:Result := N_ILFmtJPL2; // JPG lossless 1
    rietNotDef, // on RICreateFile means that input Encoder Type should be defined by FileName Extension
    rietGIF: Result := 0;  // GIF
  end;

end; // function TN_RIImLib.RIILFormatFromRIType

//******************************************* TN_RIImLib.RITypeFromILFormat ***
// Get Raster Image Encoding Format from Image Library Container Format
//
//    Parameters
// AILFormat - Image Library Container Format or -1 if FileImageInfo should be used
// Result    - Returns Raster Image Encoding Format
//
function TN_RIImLib.RITypeFromILFormat( AILFormat: Integer ): TK_RIFileEncType;
var
  RIILFileImageInfo: TN_ILFileImageInfo;
begin
  Result := rietNotDef;

  if AILFormat < 0 then
  begin
    if RIILHandle <= 0 then Exit;

    RIILFileImageInfo.ILSelfSize := SizeOf(RIILFileImageInfo);
    N_ImageLib.ILReadFileImageInfo( RIILHandle, 0, @RIILFileImageInfo );
    AILFormat := RIILFileImageInfo.ILContainerFormat;
  end;

  case AILFormat of
    N_ILFmtBMP: Result := rietBMP;  // BMP
    N_ILFmtPNG: Result := rietPNG;  // PNG
    N_ILFmtJPG: Result := rietJPG;  // JPG
    N_ILFmtTIF: Result := rietTIF;  // TIF
    N_ILFmtJPL1:Result := rietJPL1; // JPG lossless 1
    N_ILFmtJPL2:Result := rietJPL2; // JPG lossless 2 for greyscale only
  end;

end; // function TN_RIImLib.RITypeFromILFormat

//*********************************** TN_RIImLib.RIFillWriteImageProperties ***
// Fill WriteImageProperties structure
//
//    Parameters
// APWriteImageProperties - given pointer to Image Library WriteImageProperties structure
// Result                 - Returns Raster Image Encoding Format
//
procedure TN_RIImLib.RIFillWriteImageProperties( APWriteImageProperties: TN_PILWriteImageProperties);
begin
  with APWriteImageProperties^ do
  begin
    ILSelfSize := SizeOf(TN_ILWriteImageProperties);
    ILQuality := RIImgEncInfo.RIIComprQuality;

    case RIImgEncInfo.RIIComprType of
      rictNoCompr: ILCompressionFormat := N_ILComprNone;  // no compression
      rictJPG    : ILCompressionFormat := N_ILComprJPEG;  // JPG
      rictPNG    : ILCompressionFormat := N_ILComprPNG;   // PNG
    else
      ILCompressionFormat := N_ILCompr3; // used in TIFF
    end;
  end;
end; // procedure TN_RIImLib.RIFillWriteImageProperties


Initialization
  N_ImageLib := TN_ImageLibrary.Create;
  // N_ImageLib.ILInitAll should be called after Path to folder with DLL files is ready

Finalization
  N_ImageLib.ILFreeAll();
  FreeAndNil( N_ImageLib );

end.

