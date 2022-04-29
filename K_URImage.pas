unit K_URImage;

interface

uses Classes, Types,
  K_RImage,
  N_Gra2, N_Lib0;

type TK_URI = class (TK_RasterImage)
  URIMain : TK_RasterImage;
  URIAux  : TK_RasterImage;
  URICur  : TK_RasterImage;
  constructor Create     (); override;
  destructor Destroy     (); override;
  function  RIObjectReady( ) : Boolean; override; // Check if object is ready to work after constructor
  function  RIOpenFile   ( const AFileName : string ) : TK_RIResult; override; // Open given Ffile for RI decoding
  function  RIOpenStream ( AStream : TStream ) : TK_RIResult; override; // Open given Stream for RI decoding
  function  RIOpenMemory ( APBuf : Pointer; ABufSize : Integer  ) : TK_RIResult; override; // Open Memory Buffer for RI decoding
  function  RIGetImageCount () : Integer; override; // Returns number of images in decoded instance (file, stream or memory)
  function  RIGetDIB        ( AImgInd: Integer; var ADIBObj : TN_DIBObj ) : TK_RIResult; override; // Get DIBObj by decoded instance Image Index

  function  RICreateFile    ( const AFileName : string; APFileEncInfo : TK_PRIFileEncInfo ) : TK_RIResult; override; // Set File for RI encoding
  function  RICreateStream  ( AStream : TStream; APFileEncInfo : TK_PRIFileEncInfo ) : TK_RIResult; override; // Set Stream for RI encoding
  function  RICreateEncodeBuffer ( APFileEncInfo : TK_PRIFileEncInfo ) : TK_RIResult; override;  // Set file for RI encoding
  function  RIAddDIBPixels       ( APDIBInfo : TN_PDIBInfo; APPixels: Pointer ) : TK_RIResult; override; // Add DIB Pixels to encoding instance
  function  RIAddDIB             ( ADIBObj : TN_DIBObj ) : TK_RIResult; override; // Add DIBObj to encoding instance
  function  RIGetEncodeBuffer    ( out APBuf : Pointer; out ABufSize : Integer ) : TK_RIResult; override; // Get Pointer Size of resulting Memory Buffer
  function  RIClose () : TK_RIResult; override; // Close current Encoding Instance
  function  RIClear () : TK_RIResult; override; // Clear current Resources

  function  RISaveDIBToFile   ( ADIBObj : TN_DIBObj; const AFileName : string; APFileEncInfo : TK_PRIFileEncInfo ) : TK_RIResult; override; // Save Given DIB to Given File
  function  RISaveDIBToStream ( ADIBObj : TN_DIBObj; AStream : TStream; APFileEncInfo : TK_PRIFileEncInfo ) : TK_RIResult; override; // Save Given DIB to Given Stream
  function  RIGetLastNativeErrorCode () : Integer; override; // Get Last Native Error Code
    private
  URIOpenFile : string;
  URIOpenStream : TStream;
  URIOpenMem : Pointer;
  URIOpenMemSize : Integer;
  URIAuxIsOpenedFlag : Boolean;
  URIAuxOpenErrorFlag : Boolean;
end; // type TK_RIGDIP

implementation

uses SysUtils, K_Gra0, N_ImLib, N_Types;

{ TK_URI }

//********************************************************** TK_URI.Create ***
// Raster Image constructor
//
constructor TK_URI.Create;
begin
  inherited;
  URIAux := TK_RIGDIP.Create;
  URIMain := TN_RIImLib.Create;
  URICur := URIMain;
end; // constructor TK_URI

//********************************************************* TK_URI.Destroy ***
// Raster Image destructor
//
destructor TK_URI.Destroy;
begin
  URIAux.Free();
  URIMain.Free();
  URICur := nil;
  inherited;
end; // destructor TK_URI.Destroy

//******************************************************** TK_URI.RIAddDIB ***
// Add DIB Object to serialized Raster Image
//
//    Parameters
// ADIBObj - given DIB object to save
// Result -  Returns resulting code
//
function TK_URI.RIAddDIB( ADIBObj: TN_DIBObj ): TK_RIResult;
begin
  Result := URICur.RIAddDIB(ADIBObj);
end; // function TK_URI.RIAddDIB

function TK_URI.RIAddDIBPixels( APDIBInfo: TN_PDIBInfo; APPixels: Pointer ): TK_RIResult;
begin
  Result := URICur.RIAddDIBPixels( APDIBInfo, APPixels );
end;

//********************************************************* TK_URI.RIClear ***
// Clear Raster Image resources
//
//    Parameters
// Result -  Returns resulting code
//
function TK_URI.RIClear: TK_RIResult;
begin
  Result := inherited RIClear();
  if URICur = nil then Exit; // needed for correct destroy
  Result := URICur.RIClear();
end; // function TK_URI.RIClear

//********************************************************* TK_URI.RIClose ***
// Finish serialized Raster Image saving
//
//    Parameters
// Result -  Returns resulting code
//
function TK_URI.RIClose: TK_RIResult;
begin
  Result := rirOK;
  if URICur = nil then Exit; // neede for proper destroy
  RIClear();
  Result := URICur.RIClose();
  if URIAuxIsOpenedFlag then
    URIAux.RIClose();

  // Clear Internal Contex
  URIOpenFile := '';
  URIOpenStream := nil;
  URIOpenMem := nil;
  URIOpenMemSize := 0;
  URIAuxIsOpenedFlag := FALSE;
  URIAuxOpenErrorFlag := FALSE;


  if URICur = URIMain then Exit;
  URICur := URIMain;
  URICur.RIClose();
  N_Dump1Str( 'TK_URI.RIClose Return to ' + URICur.ClassName );
end; // function TK_URI.RIClose

//******************************************** TK_URI.RICreateEncodeBuffer ***
// Create Buffer for Raster Image Encoding
//
//    Parameters
// APFileEncInfo - pointer to Raster Image Encoding Attributes
// Result -  Returns resulting code
//
function TK_URI.RICreateEncodeBuffer( APFileEncInfo: TK_PRIFileEncInfo ): TK_RIResult;
begin
  Result := URICur.RICreateEncodeBuffer( APFileEncInfo );
  RICurEncType := URICur.RICurEncType;
end; // function TK_URI.RICreateEncodeBuffer

//**************************************************** TK_URI.RICreateFile ***
// Create File for Raster Image Encoding
//
//    Parameters
// AFileName    - file name for Raster Image
// APFileEncInfo - pointer to Raster Image Encoding Attributes
// Result -  Returns resulting code
//
function TK_URI.RICreateFile( const AFileName: string; APFileEncInfo: TK_PRIFileEncInfo ): TK_RIResult;
begin
  Result := URICur.RICreateFile( AFileName, APFileEncInfo );
  RICurEncType := URICur.RICurEncType;
end; // function TK_URI.RICreateFile

//************************************************** TK_URI.RICreateStream ***
// Create Stream for Raster Image Encoding
//
//    Parameters
// AStream    - stream object
// APFileEncInfo - pointer to Raster Image Encoding Attributes
// Result -  Returns resulting code
//
function TK_URI.RICreateStream( AStream: TStream; APFileEncInfo: TK_PRIFileEncInfo ): TK_RIResult;
begin
  Result := URICur.RICreateStream( AStream, APFileEncInfo );
  RICurEncType := URICur.RICurEncType;
end; // function TK_URI.RICreateStream

//******************************************************** TK_URI.RIGetDIB ***
// Get DIB Object from serialized Raster Image instance
//
//    Parameters
// AImgInd - Raster Image Frame Index
// ADIBObj - Resulting DIB
// Result -  Returns resulting code
//
// If ADIBObj = nil then new DIB object will be created, use given else
//
function TK_URI.RIGetDIB( AImgInd: Integer; var ADIBObj: TN_DIBObj ): TK_RIResult;
var
  AUXResult : TK_RIResult;
begin
  URICur.RIMaxPixelsCount := RIMaxPixelsCount;
  URICur.RIMaxPixelSize := RIMaxPixelSize;
  Result := URICur.RIGetDIB( AImgInd, ADIBObj );
  RILastImageSize := URICur.RILastImageSize;
  if (Result <> rirOK)          and
     (Result <> rirOutOfMemory) and
     (URICur <> URIAux)         and
     not URIAuxOpenErrorFlag then
  begin
  // Try to Get DIB by AUX RI
    if not URIAuxIsOpenedFlag  then
    begin
    //  Open AUX RI
      N_Dump1Str( format( 'TK_URI.RIGetDIB open by AUX %s', [URIAux.ClassName] ) );
      if URIOpenFile <> '' then
        AUXResult := URIAux.RIOpenFile( URIOpenFile )
      else if URIOpenStream <> nil then
        AUXResult := URIAux.RIOpenStream( URIOpenStream )
      else
        AUXResult := URIAux.RIOpenMemory( URIOpenMem, URIOpenMemSize );
    end
    else
      AUXResult := rirOK;

    if AUXResult = rirOK then
    begin
    // Get DIB by AUX RI
      N_Dump1Str( format( 'TK_URI.RIGetDIB get by AUX I=%d', [AImgInd] ) );
      URIAux.RIMaxPixelsCount := RIMaxPixelsCount;
      URIAux.RIMaxPixelSize := RIMaxPixelSize;
      Result := URIAux.RIGetDIB( AImgInd, ADIBObj );
      URIAux.RIMaxPixelsCount := 0;
      URIAux.RIMaxPixelSize := Point(0,0);
      URIAuxIsOpenedFlag := TRUE;
    end
    else
    begin
      URIAuxOpenErrorFlag := TRUE;
      N_Dump1Str( 'TK_URI.RIGetDIB open error' );
    end;
  end;
  URICur.RIMaxPixelsCount := 0;
  URICur.RIMaxPixelSize := Point(0,0);
end; // function TK_URI.RIGetDIB

//*********************************************** TK_URI.RIGetEncodeBuffer ***
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
function TK_URI.RIGetEncodeBuffer( out APBuf: Pointer; out ABufSize: Integer ): TK_RIResult;
begin
  Result := URICur.RIGetEncodeBuffer( APBuf, ABufSize );
end; // function TK_URI.RIGetEncodeBuffer

//************************************************* TK_URI.RIGetImageCount ***
// Get Raster Image instance Frames counter
//
//    Parameters
// Result -  Raster Image Frames counter
//
function TK_URI.RIGetImageCount: Integer;
begin
  Result := URICur.RIGetImageCount( );
end; // function TK_URI.RIGetImageCount

//**************************************** TK_URI.RIGetLastNativeErrorCode ***
// Get Last Native Error Code
//
//    Parameters
// Result -  Returns Last Native Error Code
//
function TK_URI.RIGetLastNativeErrorCode: Integer;
begin
  Result := URICur.RIGetLastNativeErrorCode( );
end; // function TK_URI.RIGetLastNativeErrorCode

//****************************************************** TK_URI.RIOpenFile ***
// Check if object is ready to work after contructor
//
//    Parameters
// Result    -  Returns TRUE if object is ready to work
//
function TK_URI.RIObjectReady: Boolean;
begin
  Result := URICur.RIObjectReady( );
end; // function TK_URI.RIObjectReady

//****************************************************** TK_URI.RIOpenFile ***
// Open File with encoded Raster Image
//
//    Parameters
// AFileName - file name with encoded Raster Image
// Result    -  Returns resulting code
//
function TK_URI.RIOpenFile( const AFileName: string ): TK_RIResult;
begin
  RIClose();
  URIOpenFile := AFileName;
  Result := URICur.RIOpenFile( AFileName );
  RICurEncType := URICur.RICurEncType;
  if Result <> rirFails then Exit;
  URICur := URIAux;
  Result := URICur.RIOpenFile( AFileName );
  N_Dump1Str( format( 'TK_URI.RIOpenFile "%s" fails, switch to %s', [AFileName,URICur.ClassName] ) );
end; // function TK_URI.RIOpenFile

//**************************************************** TK_URI.RIOpenMemory ***
// Open Memory Buffer with encoded Raster Image
//
//    Parameters
// APBuf  - pointer to memory buffer with encoded Raster Image
// ABufSize - buffer with encoded Raster Image size
// Result - Returns resulting code
//
function TK_URI.RIOpenMemory( APBuf: Pointer; ABufSize: Integer ): TK_RIResult;
begin
  RIClose();
  URIOpenMem := APBuf;
  URIOpenMemSize := ABufSize;
  Result := URICur.RIOpenMemory( APBuf, ABufSize );
  RICurEncType := URICur.RICurEncType;
  if Result <> rirFails then Exit;
  URICur := URIAux;
  Result := URICur.RIOpenMemory( APBuf, ABufSize );
  N_Dump1Str( format( 'TK_URI.RIOpenMemory fails, switch to %s', [URICur.ClassName] ) );
end; // function TK_URI.RIOpenMemory

//**************************************************** TK_URI.RIOpenStream ***
// Open Stream with encoded Raster Image
//
//    Parameters
// AStream - stream with encoded Raster Image
// Result  - Returns resulting code
//
function TK_URI.RIOpenStream( AStream: TStream ): TK_RIResult;
begin
  RIClose();
  URIOpenStream := AStream;
  Result := URICur.RIOpenStream( AStream );
  RICurEncType := URICur.RICurEncType;
  if Result <> rirFails then Exit;
  URICur := URIAux;
  Result := URICur.RIOpenStream( AStream );
  N_Dump1Str( format( 'TK_URI.RIOpenStream fails, switch to %s', [URICur.ClassName] ) );
end; // function TK_URI.RIOpenStream

//**************************************************** TK_URI.RICreateFile ***
// Save given DIB to given File
//
//    Parameters
// ADIBObj - given DIB object to save
// AFileName    - file name for Raster Image
// APFileEncInfo - pointer to Raster Image Encoding Attributes
// Result -  Returns resulting code
//
function TK_URI.RISaveDIBToFile( ADIBObj: TN_DIBObj; const AFileName: string;
                                  APFileEncInfo: TK_PRIFileEncInfo ): TK_RIResult;
begin
  Result := URICur.RISaveDIBToFile( ADIBObj, AFileName, APFileEncInfo );
  RICurEncType := URICur.RICurEncType;
end; // function TK_URI.RISaveDIBToFile

//************************************************** TK_URI.RICreateStream ***
// Save given DIB to given Stream
//
//    Parameters
// ADIBObj - given DIB object to save
// AStream    - stream object
// APFileEncInfo - pointer to Raster Image Encoding Attributes
// Result -  Returns resulting code
//
function TK_URI.RISaveDIBToStream( ADIBObj: TN_DIBObj; AStream: TStream;
                                    APFileEncInfo: TK_PRIFileEncInfo ): TK_RIResult;
begin
  Result := URICur.RISaveDIBToStream( ADIBObj, AStream, APFileEncInfo );
  RICurEncType := URICur.RICurEncType;
end; // function TK_URI.RISaveDIBToStream

end.
