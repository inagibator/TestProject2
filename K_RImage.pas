unit K_RImage;

interface

uses Classes, Windows,
N_Lib0, N_Gra2;

//*********************************************************** TK_RasterImage ***
// Object for Raster Image file or memory encoding/decoding
//
type TK_RIResult = ( // Raster Image Functions Result Code
  rirOK,            // OK Result
  rirFails,         // Method Fails
  rirOutOfMemory,   // Method Fails because of memory lack
  rirNotImplemented // Method not Implemented
);

type TK_RIFileEncType = ( // Raster Image File Encoding Type
  rietNotDef,// on RICreateFile means that input Encoder Type should be defined by FileName Extension
  rietBMP,  // BMP
  rietGIF,  // GIF
  rietJPG,  // JPG
  rietTIF,  // TIF
  rietPNG,  // PNG
  rietDCM,  // DICOM
  rietJPL1, // JPG lossless 1
  rietJPL2  // JPG lossless 2 for greate scale only
);

type TK_RIComprType = ( // Raster Image Frame Encoder Type
  rictDefByFileEncType,  // Defined by file Compresion Type
  rictNoCompr, // No compression
  rictPNG,   // PNG
  rictJPG,   // JPG
  rictOther1 // Other1
);

type TK_RIFileEncInfo =  record // Raster Image File Encoding Info
  RIFileEncType   : TK_RIFileEncType;
  RIFComprType    : TK_RIComprType; // Compresson Type
  RIFComprQuality : Integer; // Compresson Quality (used in JPEG)
//  RIFTranspColor  : Integer; // Transparent Color (used in PNG and GIF)
//  RIFColorFormat  : Integer; // Color Model RGB, CMYK ...
end;
type TK_PRIFileEncInfo = ^TK_RIFileEncInfo;

type TK_RIImgEncInfo =  record // Raster Image Encoding Info
  RIIComprType    : TK_RIComprType; // Compresson Type
  RIIComprQuality : Integer; // Compresson Quality (used in JPEG)
end;
type TK_PRIImgEncInfo = ^TK_RIImgEncInfo;

type TK_RasterImage = class( TObject )
  RIMaxPixelsCount : Integer;
  RIMaxPixelSize   : TPoint;
  RILastImageSize  : TPoint;
  RIImgEncInfo     : TK_RIImgEncInfo;
  RICurEncType     : TK_RIFileEncType; // Current Encoding Type
  constructor Create     (); virtual;
  destructor Destroy     (); override;
  function  RIObjectReady( ) : Boolean; virtual; // Check if object is ready to work after constructor
  function  RIOpenFile   ( const AFileName : string ) : TK_RIResult; virtual; // Open given Ffile for RI decoding
  function  RIOpenStream ( AStream : TStream ) : TK_RIResult; virtual; // Open given Stream for RI decoding
  function  RIOpenMemory ( APBuf : Pointer; ABufSize : Integer  ) : TK_RIResult; virtual; // Open Memory Buffer for RI decoding
  function  RIGetImageCount () : Integer; virtual; abstract; // Returns number of images in decoded instance (file, stream or memory)
  function  RIGetDIB        ( AImgInd: Integer; var ADIBObj : TN_DIBObj ) : TK_RIResult; virtual; abstract; // Get DIBObj by decoded instance Image Index

  function  RICreateFile    ( const AFileName : string; APFileEncInfo : TK_PRIFileEncInfo ) : TK_RIResult; virtual; // Set File for RI encoding
  function  RICreateStream  ( AStream : TStream; APFileEncInfo : TK_PRIFileEncInfo ) : TK_RIResult; virtual; // Set Stream for RI encoding
  function  RICreateEncodeBuffer ( APFileEncInfo : TK_PRIFileEncInfo ) : TK_RIResult; virtual; // Set file for RI encoding
  function  RIAddDIBPixels       ( APDIBInfo : TN_PDIBInfo; APPixels: Pointer ) : TK_RIResult; virtual; abstract; // Add DIB Pixels to encoding instance
  function  RIAddDIB             ( ADIBObj : TN_DIBObj ) : TK_RIResult; virtual; // Add DIBObj to encoding instance
  function  RIGetEncodeBuffer    ( out APBuf : Pointer; out ABufSize : Integer ) : TK_RIResult; virtual; // Get Pointer Size of resulting Memory Buffer
  function  RIClose () : TK_RIResult; virtual; // Close current Encoding Instance
  function  RIClear () : TK_RIResult; virtual; // Clear current Resources

  function  RISaveDIBToFile   ( ADIBObj : TN_DIBObj; const AFileName : string; APFileEncInfo : TK_PRIFileEncInfo ) : TK_RIResult; virtual; // Save Given DIB to Given File
  function  RISaveDIBToStream ( ADIBObj : TN_DIBObj; AStream : TStream; APFileEncInfo : TK_PRIFileEncInfo ) : TK_RIResult; virtual; // Save Given DIB to Given Stream
  function  RIGetLastNativeErrorCode () : Integer; virtual;  // Get Last Native Error Code
  function  RIGetDIBMaxSize          ( ASize : TPoint ) : TPoint;
  procedure RIClearFileEncInfo       ( APFileEncInfo : TK_PRIFileEncInfo );
  function  RIEncTypeByFileExt       ( const AFileName : string ) : TK_RIFileEncType; // Get File Encoding type by file name extension
  procedure RIImgByFileEncInfo       ( APFileEncInfo : TK_PRIFileEncInfo );
end;

var
  K_RIObj : TK_RasterImage;

implementation

uses SysUtils,
  K_CLib0,
  N_Types, N_Gra1;

{*** TK_RasterImage ***}

//*************************************************** TK_RasterImage.Create ***
// Raster Image constructor
//
constructor TK_RasterImage.Create;
begin
  inherited;
end; // constructor TK_RasterImage

//************************************************** TK_RasterImage.Destroy ***
// Raster Image destructor
//
destructor TK_RasterImage.Destroy;
begin
  RIClose();
  inherited;
end; // destructor TK_RasterImage.Destroy

//*********************************************** TK_RasterImage.RIOpenFile ***
// Check if object is ready to work after contructor
//
//    Parameters
// Result    -  Returns TRUE if object is ready to work
//
function TK_RasterImage.RIObjectReady( ) : Boolean;
begin
  Result := TRUE;
end; // function TK_RasterImage.RIObjectReady

//*********************************************** TK_RasterImage.RIOpenFile ***
// Open File with encoded Raster Image
//
//    Parameters
// AFileName - file name with encoded Raster Image
// Result    -  Returns resulting code
//
function TK_RasterImage.RIOpenFile( const AFileName: string ): TK_RIResult;
begin
  Result := rirNotImplemented;
end; // function TK_RasterImage.RIOpenFile

//********************************************* TK_RasterImage.RIOpenStream ***
// Open Stream with encoded Raster Image
//
//    Parameters
// AStream - stream with encoded Raster Image
// Result  - Returns resulting code
//
function TK_RasterImage.RIOpenStream( AStream: TStream ): TK_RIResult;
begin
  Result := rirNotImplemented;
end; // function TK_RasterImage.RIOpenStream

//********************************************* TK_RasterImage.RIOpenMemory ***
// Open Memory Buffer with encoded Raster Image
//
//    Parameters
// APBuf  - pointer to memory buffer with encoded Raster Image
// ABufSize - buffer with encoded Raster Image size
// Result - Returns resulting code
//
function TK_RasterImage.RIOpenMemory( APBuf: Pointer;
                                 ABufSize: Integer): TK_RIResult;
begin
  Result := rirNotImplemented;
end; // function TK_RasterImage.RIOpenMemory

//********************************************* TK_RasterImage.RICreateFile ***
// Create File for Raster Image Encoding
//
//    Parameters
// AFileName    - file name for Raster Image
// APFileEncInfo - pointer to Raster Image Encoding Attributes
// Result -  Returns resulting code
//
function TK_RasterImage.RICreateFile( const AFileName: string;
                                 APFileEncInfo : TK_PRIFileEncInfo): TK_RIResult;
begin
  Result := rirNotImplemented;
end; // function TK_RasterImage.RICreateFile

//******************************************* TK_RasterImage.RICreateStream ***
// Create Stream for Raster Image Encoding
//
//    Parameters
// AStream    - stream object
// APFileEncInfo - pointer to Raster Image Encoding Attributes
// Result -  Returns resulting code
//
function TK_RasterImage.RICreateStream( AStream: TStream;
                                   APFileEncInfo : TK_PRIFileEncInfo): TK_RIResult;
begin
  Result := rirNotImplemented;
end; // function TK_RasterImage.RICreateStream

//************************************* TK_RasterImage.RICreateEncodeBuffer ***
// Create Buffer for Raster Image Encoding
//
//    Parameters
// APFileEncInfo - pointer to Raster Image Encoding Attributes
// Result -  Returns resulting code
//
function TK_RasterImage.RICreateEncodeBuffer( APFileEncInfo : TK_PRIFileEncInfo ): TK_RIResult;
begin
  Result := rirNotImplemented;
end; // function TK_RasterImage.RICreateEncodeBuffer

//************************************************* TK_RasterImage.RIAddDIB ***
// Add DIB Object to serialized Raster Image
//
//    Parameters
// ADIBObj - given DIB object to save
// Result -  Returns resulting code
//
function TK_RasterImage.RIAddDIB( ADIBObj: TN_DIBObj ): TK_RIResult;
begin
  Result := RIAddDIBPixels( @ADIBObj.DIBInfo, ADIBObj.PRasterBytes );
end; // function TK_RasterImage.RIAddDIB

//**************************************** TK_RasterImage.RIGetEncodeBuffer ***
// Get DIB Object from serialized Raster Image Frame
//
//    Parameters
// APBuf - pointer to Encoding buffer with serialized Raster Image
// ABufSize - Encoding buffer resulting size in bytes
// Result -  Returns resulting code
//
// Is actual if Raster Image was serialized to memory buffer created by
// RICreateEncodeBuffer.
//
function TK_RasterImage.RIGetEncodeBuffer( out APBuf: Pointer;
                                      out ABufSize : Integer ): TK_RIResult;
begin
  Result := rirNotImplemented;
end; // function TK_RasterImage.RIGetEncodeBuffer

//************************************************** TK_RasterImage.RIClose ***
// Finish serialized Raster Image saving
//
//    Parameters
// Result -  Returns resulting code
//
function TK_RasterImage.RIClose: TK_RIResult;
begin
  Result := RIClear();
end; // function TK_RasterImage.RIClose

//************************************************** TK_RasterImage.RIClear ***
// Clear Raster Image resources
//
//    Parameters
// Result -  Returns resulting code
//
function TK_RasterImage.RIClear: TK_RIResult;
begin
  RICurEncType := rietNotDef;
  Result := rirOK;
end; // function TK_RasterImage.RIClear

//********************************************* TK_RasterImage.RICreateFile ***
// Save given DIB to given File
//
//    Parameters
// ADIBObj - given DIB object to save
// AFileName    - file name for Raster Image
// APFileEncInfo - pointer to Raster Image Encoding Attributes
// Result -  Returns resulting code
//
function TK_RasterImage.RISaveDIBToFile( ADIBObj: TN_DIBObj;
                                         const AFileName: string;
                                         APFileEncInfo : TK_PRIFileEncInfo ): TK_RIResult;
begin
  Result := RICreateFile( AFileName, APFileEncInfo );
  if Result <> rirOK then Exit;
  Result := RIAddDIB( ADIBObj );
  if Result <> rirOK then Exit;
  Result := RIClose();
end;

//******************************************* TK_RasterImage.RICreateStream ***
// Save given DIB to given Stream
//
//    Parameters
// ADIBObj - given DIB object to save
// AStream    - stream object
// APFileEncInfo - pointer to Raster Image Encoding Attributes
// Result -  Returns resulting code
//
function TK_RasterImage.RISaveDIBToStream( ADIBObj: TN_DIBObj; AStream : TStream;
                                           APFileEncInfo : TK_PRIFileEncInfo ): TK_RIResult;
begin
  Result := RICreateStream( AStream, APFileEncInfo );
  if Result <> rirOK then Exit;
  Result := RIAddDIB( ADIBObj );
  if Result <> rirOK then Exit;
  Result := RIClose();
end;

//********************************* TK_RasterImage.RIGetLastNativeErrorCode ***
// Get Last Native Error Code
//
//    Parameters
// Result -  Returns Last Native Error Code
//
function TK_RasterImage.RIGetLastNativeErrorCode: Integer;
begin
  Result := 0;
end; // function TK_RasterImage.RIGetLastNativeErrorCode

//****************************************** TK_RasterImage.RIGetDIBMaxSize ***
// Get Raster Image Maximal Size by given Size and Maximal Pixels Count
//
//    Parameters
// ASize - given width and height as TPoint
// Result -  Returns Maximal Width and Height
//
function TK_RasterImage.RIGetDIBMaxSize( ASize : TPoint ) : TPoint;
//var
//  RRSize : Integer;
//  Aspect, RNWidth : Double;
begin
  Result := ASize;
  if RIMaxPixelsCount <> 0 then
  begin
    Result := N_AdjustSizeByMaxArea( Result, RIMaxPixelsCount );
{
  // Calc Maximal Pixel Size
    RRSize := Result.X * Result.Y;
    if RIMaxPixelsCount < RRSize then
    begin
    // Calc Needed Size
      Aspect := Result.Y / Result.X;
      RNWidth := sqrt( RIMaxPixelsCount / Aspect );
      Result.Y := Round( RNWidth * Aspect ) - 1;
      Result.X := Round( RNWidth ) - 1;
    end;
}
  end
  else
  if (RIMaxPixelSize.X <> 0) and (RIMaxPixelSize.Y <> 0) and
     ((RIMaxPixelSize.X < Result.X) or (RIMaxPixelSize.Y < Result.Y))  then
    Result := N_AdjustSizeByAspect( aamDecRect, RIMaxPixelSize, Result.Y / Result.X );
end; // function TK_RasterImage.RIGetDIBMaxSize

//****************************************** TK_RasterImage.RIGetDIBMaxSize ***
// Clear Raster Image Coding Info
//
//    Parameters
// APFileEncInfo - pointer to Raster Image Encoding Info to clear
//
procedure TK_RasterImage.RIClearFileEncInfo( APFileEncInfo : TK_PRIFileEncInfo );
begin
  FillChar( APFileEncInfo^, SizeOf(TK_RIFileEncInfo), 0 );
  APFileEncInfo^.RIFComprQuality := 100;
end; // procedure TK_RasterImage.RIClearFileEncInfo

//*************************************** TK_RasterImage.RIEncTypeByFileExt ***
// Get Raster Image Encoder Type Enum
//
//    Parameters
// AFileName - file  name
// Result -  Returns Raster Image Encoder Type Enum
//
function TK_RasterImage.RIEncTypeByFileExt( const AFileName: string): TK_RIFileEncType;
var
  FExt : string;
begin
  Result := rietNotDef;
  FExt := UpperCase( Copy( ExtractFileExt( AFileName ), 2, 2 ) );
  if      FExt = 'BM' then Result := rietBMP
  else if FExt = 'JP' then Result := rietJPG
  else if FExt = 'GI' then Result := rietGIF
  else if FExt = 'TI' then Result := rietTIF
  else if FExt = 'PN' then Result := rietPNG
  else if FExt = 'DC' then Result := rietDCM
  else if FExt = 'DI' then Result := rietDCM;

end; // function TK_RasterImage.RIEncTypeByFileExt


//****************************************** TK_RasterImage.RIGetDIBMaxSize ***
// Set Image Encoding Info by file Encoding Info
//
//    Parameters
// APFileEncInfo - pointer to Raster Image Encoding Info to clear
//
procedure TK_RasterImage.RIImgByFileEncInfo( APFileEncInfo: TK_PRIFileEncInfo );
begin
  RIImgEncInfo.RIIComprType := APFileEncInfo.RIFComprType;
  if RIImgEncInfo.RIIComprType = rictDefByFileEncType then
    case RICurEncType of
    rietBMP: RIImgEncInfo.RIIComprType := rictNoCompr; // BMP
    rietJPG: RIImgEncInfo.RIIComprType := rictJPG;     // JPG
    rietTIF: RIImgEncInfo.RIIComprType := rictOther1;  // TIF
    rietPNG: RIImgEncInfo.RIIComprType := rictPNG;     // PNG
//    rietJPL1:RIImgEncInfo.RIIComprType := rictJPG;   // JPG lossless 1
//    rietJPL2:RIImgEncInfo.RIIComprType := rictJPG;   // JPG lossless 2 for greate scale only
    end;
  RIImgEncInfo.RIIComprQuality := APFileEncInfo.RIFComprQuality;
end; // procedure TK_RasterImage.RIImgByFileEncInfo

end.
