unit K_Gra0;

interface

uses Windows, Classes, GDIPAPI, GDIPOBJ, Types,
  Graphics, {Graphics have to be after GDIPAPI in uses}
  N_Types, N_Lib0, N_Gra2,
  K_RImage;

type TK_GPImgMimeType = (  // GDI+ Image Mime Types enumeration
  K_gpiBMP,   // BMP
  K_gpiGIF,   // GIF
  K_gpiJPG,   // JPEG
  K_gpiTIF,   // TIFF
  K_gpiPNG,   // PNG
  K_gpiUndef  // Undefined Image Mime Type
);

//***************************************************** TK_GPDIBCodecsWrapper ***
// Device Independent Bitmap GDI+ Codecs Wrapper class
//
type TK_GPDIBCodecsWrapper = class

  GPB : TGPBitmap;
// Load Image Resulting Attributes
  GPImageFormat : TGUID;
  GPFramesCount : Integer;
  GPFrameSize   : TPoint;
  GPFramePixFmt : Integer;
  GPDimsCount   : Integer;
  GPDimGUID     : TGuid;
  GPResolution  : TFPoint;
// Save Image Attributes
  GPEncMT : TK_GPImgMimeType;
  GPEncClsID    : TGUID;
  GPEncQuality : Integer;
  GPEncValue   : TEncoderValue;
//  GPResUnits    : Integer;
  GPEncPars : TEncoderParameters;
  GPPEncPars : PEncoderParameters;

//##/*
  destructor Destroy(); override;
//##*/
  function  GPGetBitmapAttrs( ): TStatus;
  function  GPLoadFromFile( AFileName : string ) : TStatus;
  function  GPLoadFromStream( AStream: TStream ): TStatus;
  function  GPGetFrameToDIBObj( var ADIBObj : TN_DIBObj; AFrameInd : Integer = 0; AMaxPixelsSize : Integer = 0 ) : TStatus;
  function  GPMimeTypeByFileName( const AFileName : string ) : TK_GPImgMimeType;
  function  GPEncoderByMimeType( AMimeType : TK_GPImgMimeType ) : TStatus;
  function  GPEncoderByFileName( const AFileName : string ) : TStatus;
  procedure GPPrepareDIBObjEncoding( ADIBObj : TN_DIBObj );
  function  GPSaveDIBObjToFile( ADIBObj : TN_DIBObj; const AFileName : string ) : TStatus;
  function  GPSaveDIBObjToStream( ADIBObj : TN_DIBObj; AStream : TStream; AMimeType : TK_GPImgMimeType ) : TStatus;
end;


//************************************************************* TK_SMPixComb ***
// Calculate Linear Combination of 2 pixel values method container
// for Convert SubMatr Elements by N_Conv3SMProcObj
//
type TK_SMPixComb = class
  SMPSrcVMin1 : Integer;
  SMPSrcVMax1 : Integer;
  SMPSrcVMin2 : Integer;
  SMPSrcVMax2 : Integer;
  SMPSrcVMin3 : Integer;
  SMPSrcVMax3 : Integer;
  SMPSrcDMin : Integer;
  SMPSrcDMax : Integer;
  SMPixFormat : Integer;
  SMAlfa, SMBeta : Double;
  procedure SMComb1( APtr1, APtr2, APtrR: Pointer );
end;

type TK_RIGDIP = class (TK_RasterImage)
  RIGPResCode   : TStatus;
  RIGPFileName  : string;
  RIGPStream    : TStream;
  RIPCodingInfo : TK_PRIFileEncInfo;

  destructor Destroy        (); override;
  function  RIOpenFile      ( const AFileName : string ) : TK_RIResult; override;
  function  RIOpenStream    ( AStream : TStream ) : TK_RIResult; override;
  function  RIGetImageCount () : Integer; override;
  function  RIGetDIB        ( AImgInd: Integer; var ADIBObj : TN_DIBObj ) : TK_RIResult; override;

  function  RICreateFile    ( const AFileName : string; APCodingInfo : TK_PRIFileEncInfo ) : TK_RIResult; override;
  function  RICreateStream  ( AStream : TStream; APCodingInfo : TK_PRIFileEncInfo ) : TK_RIResult; override;
  function  RIAddDIBPixels  ( APDIBInfo : TN_PDIBInfo; APPixels: Pointer ) : TK_RIResult; override;
  function  RIAddDIB ( ADIBObj : TN_DIBObj ) : TK_RIResult; override;
  function  RIClear  () : TK_RIResult; override;

  function  RIGetLastNativeErrorCode (): Integer; override;
private

//********* GDI+ parameters
  GPB : TGPBitmap;

// Load Image Resulting Attributes
  GPFramesCount : Integer;
  GPDimGUID     : TGuid;

// Save Image Attributes
  GPEncClsID    : TGUID;
  GPEncPars     : TEncoderParameters;
  GPPEncPars    : PEncoderParameters;

  function  RIGPGetBitmapAttrs        ( ): TStatus;
  procedure RIGPPrepareDIBObjEncoding ( APDIBInfo : TN_PDIBInfo; APPixels: Pointer );
  function  RIGPEncoderByType () : TStatus;

end; // type TK_RIGDIP


implementation

uses SysUtils,
K_CLib0;


{*** TK_GPDIBCodecsWrapper ***}

//******************************************** TK_GPDIBCodecsWrapper.Destoy ***
//
destructor TK_GPDIBCodecsWrapper.Destroy;
begin
  GPB.Free;
end; // end of TK_GPDIBCodecsWrapper.Destroy

//******************************************** TK_GPDIBCodecsWrapper.GPLoadFromFile ***
// Get Attributes from early loaded GDI+ Bitmap (from file or streaam)
//
//    Parameters
// Result -  Returns GDI+ resulting code
//
function TK_GPDIBCodecsWrapper.GPGetBitmapAttrs( ): TStatus;
var
  PropBuffer : TN_BArray;
  PropSize : Integer;
  PProperty : PPropertyItem;

  procedure GetProperty( PropertyID : LongWord );
  begin
    PropSize := GPB.GetPropertyItemSize( PropertyID );
    if PropSize = 0 then Exit;
    if PropSize > Length(PropBuffer) then
      SetLength( PropBuffer, PropSize );
    PProperty := PPropertyItem(@PropBuffer[0]);
    GPB.GetPropertyItem( PropertyID, PropSize, PProperty );
  end;

begin
  Result := GPB.GetLastStatus();
  if Result <> Ok then Exit;

  Result := GPB.GetRawFormat( GPImageFormat );
  if Result <> Ok then Exit;

  GPDimsCount := GPB.GetFrameDimensionsCount();
  Result := GPB.GetLastStatus();
  if Result <> Ok then Exit;

  GPFramesCount := 1;
  if GPDimsCount = 0 then Exit;

  GPEncMT := K_gpiUndef;

  if CompareMem(@GPImageFormat, @ImageFormatTIFF, SizeOf(TGUID) ) then
  begin
    GPDimGUID := FrameDimensionPage;
    GPEncMT := K_gpiTIF;
  end else if CompareMem(@GPImageFormat, @ImageFormatGIF, SizeOf(TGUID) )  then
  begin
    GPDimGUID := FrameDimensionTime;
    GPEncMT := K_gpiGIF;
  end else
  begin
    GPDimsCount := 0; // Error prevention
    if CompareMem(@GPImageFormat, @ImageFormatPNG, SizeOf(TGUID) )  then
      GPEncMT := K_gpiPNG
    else
    if CompareMem(@GPImageFormat, @ImageFormatJPEG, SizeOf(TGUID) )  then
      GPEncMT := K_gpiJPG
    else
    if CompareMem(@GPImageFormat, @ImageFormatBMP, SizeOf(TGUID) )  then
      GPEncMT := K_gpiBMP
  end;

  GPFramesCount := GPB.GetFrameCount( GPDimGUID );
//  Result := GPB.GetLastStatus(); // Result <> Ok for *.PNG

  GPResolution.X := GPB.GetHorizontalResolution();
  GPResolution.Y := GPB.GetVerticalResolution();
end; // end of TK_GPDIBCodecsWrapper.GPGetBitmapAttrs

//******************************************** TK_GPDIBCodecsWrapper.GPLoadFromFile ***
// Load GDI+ Bitmap from given file
//
//    Parameters
// AFileName - given file name
// Result -  Returns GDI+ resulting code
//
function TK_GPDIBCodecsWrapper.GPLoadFromFile( AFileName: string ): TStatus;
begin
  GPB.Free;
  GPB := TGPBitmap.Create(AFileName);
  Result := GPGetBitmapAttrs();
end; // end of TK_GPDIBCodecsWrapper.GPLoadFromFile

//******************************************** TK_GPDIBCodecsWrapper.GPLoadFromStream ***
// Load GDI+ Bitmap from given Stream
//
//    Parameters
// AStream - given Stream
// Result -  Returns GDI+ resulting code
//
function TK_GPDIBCodecsWrapper.GPLoadFromStream( AStream: TStream ): TStatus;
var
  TA : TStreamAdapter;
begin
  FreeAndNil( GPB );
  TA := TStreamAdapter.Create( AStream );
  try
  // Needed to skip exception while loading from PNG
    GPB := TGPBitmap.Create(TA);
    Result := GPGetBitmapAttrs();
  except
    Result := Win32Error;
    FreeAndNil( GPB );
//    TA.Free; // This alwaise raise Exception
  end;
end; // end of TK_GPDIBCodecsWrapper.GPLoadFromStream

//********************************** TK_GPDIBCodecsWrapper.GPGetFrameToDIBObj ***
// Get given frame to given DIB Object
//
//    Parameters
// ADIBObj - DIB object for frame bitmap
// AFrameInd - GDI+ Image frame index
// AMaxPixelsSize - resulting pixels maximal size, if > 0 then resulting
//                  pixels size will be less or equal to given pixels size
// Result -  Returns GDI+ resulting code
//
function TK_GPDIBCodecsWrapper.GPGetFrameToDIBObj( var ADIBObj: TN_DIBObj;
              AFrameInd: Integer = 0; AMaxPixelsSize : Integer = 0 ): TStatus;
var
  GPGraphics : TGPGraphics;
  PalBuf: TN_BArray;
  PPal : PColorPalette;
  ResFMT : Integer;
  RRWidth, RRHeight, RRSize : Integer;
  Aspect, RNWidth : Double;
begin
  Result := Ok;

  if GPFramesCount >= 0 then
    Result := GPB.SelectActiveFrame( GPDimGUID, AFrameInd );
  if Result <> Ok then Exit;
  if ADIBObj = nil then begin
    Result := InvalidParameter;
    Exit;
  end;


  GPFrameSize.X := GPB.GetWidth();
//  Result := GPB.GetLastStatus(); // Result <> Ok for *.PNG
//  if Result <> Ok then Exit;

  GPFrameSize.Y := GPB.GetHeight();
//  Result := GPB.GetLastStatus(); // Result <> Ok for *.PNG
//  if Result <> Ok then Exit;

  GPFramePixFmt := GPB.GetPixelFormat();
//  Result := GPB.GetLastStatus(); // Result <> Ok for *.PNG
//  if Result <> Ok then Exit;

  with ADIBObj do begin
    RRWidth  := GPFrameSize.X;
    RRHeight := GPFrameSize.Y;
    if AMaxPixelsSize > 0 then begin
    // Use Image size Constraints
      // Calc Pixel Size
      RRSize := RRWidth * RRHeight;
      if AMaxPixelsSize < RRSize then begin
      // Image Size Reduction
        Aspect := RRHeight / RRWidth;
        RNWidth := sqrt( AMaxPixelsSize / Aspect );
        RRHeight := Round( RNWidth * Aspect );
        RRWidth := Round( RNWidth );
{
        RNWidth := Round( RRWidth * sqrt( AMaxPixelsSize/RRSize) );
        RRHeight := Round( RNWidth * RRHeight / RRWidth );
        RRWidth := RNWidth;
}
      end;
    end;

    PrepEmptyDIBObj ( RRWidth, RRHeight, DIBPixFmt,
                      DIBOCanv.ConBrushColor );
    DIBInfo.bmi.biXPelsPerMeter := Round( GPResolution.X * 100 /2.54 );
    DIBInfo.bmi.biYPelsPerMeter := Round( GPResolution.Y * 100 /2.54 );
//    ResFMT := K_ConvPasToGPPixFmt(DIBPixFmt);
    ResFMT := 0; // PixelFormatUndefined
    case DIBPixFmt of
    pf1bit : ResFMT := PixelFormat1bppIndexed;
    pf4bit : ResFMT := PixelFormat4bppIndexed;
    pf8bit : ResFMT := PixelFormat8bppIndexed;
    pf15bit: ResFMT := PixelFormat16bppRGB555;
    pf16bit: ResFMT := PixelFormat16bppRGB565;
    pf24bit: ResFMT := PixelFormat24bppRGB;
    pf32bit: ResFMT := PixelFormat32bppRGB;
    end;

    if (ResFMT and PixelFormatIndexed) <> 0 then begin
      SetLength( PalBuf, GPB.GetPaletteSize() );
      PPal := PColorPalette(@PalBuf[0]);
      GPB.GetPalette( PPal, Length(PalBuf) );
      if PPal.Count > 0 then begin
        Move( PPal.Entries[0], DIBInfo.PalEntries[0], PPal.Count * SizeOf(ARGB) );
        DIBInfo.bmi.biClrUsed := PPal.Count;
        Windows.SetDIBColorTable( DIBOCanv.HMDC, 0, 256, DIBInfo.PalEntries[0] );
      end;
    end;

    GPGraphics := TGPGraphics.Create(DIBOCanv.HMDC);
//    GPGraphics.DrawImage( GPB, 0, 0, GPFrameSize.X, GPFrameSize.Y );
    GPGraphics.DrawImage( GPB, 0, 0, RRWidth, RRHeight );
    GPGraphics.Free;
  end;

/////////////////////
// Deb Code 2
//
//ADIBObj.SaveToBMPFormat( K_ExpandFileName( '(#WrkFiles#)ResGPDIB.bmp' ) );
//
/////////////////////
end; // end of TK_GPDIBCodecsWrapper.GPGetFrameToDIBObj

//******************************************** TK_GPDIBCodecsWrapper.GPMimeTypeByFileName ***
// Get image Mime Type by given file name
//
//    Parameters
// AFileName - file name for image saving
// Result -  Returns Mime Type Enumeration
//
function  TK_GPDIBCodecsWrapper.GPMimeTypeByFileName( const AFileName : string ) : TK_GPImgMimeType;
var
  FExt : string;
begin
  FExt := UpperCase( Copy( ExtractFileExt( AFileName ), 2, 2 ) );
  Result := K_gpiUndef;
  if      FExt = 'BM' then Result := K_gpiBMP
  else if FExt = 'JP' then Result := K_gpiJPG
  else if FExt = 'GI' then Result := K_gpiGIF
  else if FExt = 'TI' then Result := K_gpiTIF
  else if FExt = 'PN' then Result := K_gpiPNG;
end; // end of TK_GPDIBCodecsWrapper.GPMimeTypeByFileName

//******************************************** TK_GPDIBCodecsWrapper.GPEncoderByMimeType ***
// Get saving image file Encoder attributes by GDI+ MimeType
//
//    Parameters
// AMimeType - GDI+ MimeType
// Result -  Returns GDI+ resulting code
//
function  TK_GPDIBCodecsWrapper.GPEncoderByMimeType( AMimeType : TK_GPImgMimeType ) : TStatus;
var
  NumEncoders, BuffSize : UInt;
  EncInfo : TN_BArray;
  PICI : PImageCodecInfo;
  i : Integer;
const
  K_GPMimeTypeStrings: array [0..Ord(K_gpiPNG)] of string =
    ( 'image/bmp', 'image/gif', 'image/jpeg', 'image/tiff', 'image/png' );
begin

  if AMimeType = K_gpiUndef then begin
    Result := InvalidParameter;
    Exit;
  end;
  GPEncMT := AMimeType;

  Result := GetImageEncodersSize( NumEncoders, BuffSize );
  if (BuffSize = 0) or (Result <> Ok) then Exit;

  SetLength( EncInfo, BuffSize );
  PICI := PImageCodecInfo(@EncInfo[0]);

  Result := GetImageEncoders( NumEncoders, BuffSize, PICI );
  if (Result <> Ok) then Exit;

  for i := 0 to NumEncoders - 1 do begin
    if PICI.MimeType = K_GPMimeTypeStrings[Ord(GPEncMT)] then begin
      GPEncClsID := PICI.Clsid;
      Exit;  // Success
    end;
    Inc(PICI);
  end;
  Result := InvalidParameter;
end; // end of TK_GPDIBCodecsWrapper.GPEncoderByMimeType

//******************************************** TK_GPDIBCodecsWrapper.GPEncoderByFileName ***
// Get saving image file Encoder attributes by file name
//
//    Parameters
// AFileName - file name for image saving
// Result -  Returns GDI+ resulting code
//
function  TK_GPDIBCodecsWrapper.GPEncoderByFileName( const AFileName : string ) : TStatus;
begin
  Result := GPEncoderByMimeType( GPMimeTypeByFileName( AFileName ) );
end; // end of TK_GPDIBCodecsWrapper.GPEncoderByFileName

//******************************************** TK_GPDIBCodecsWrapper.GPPrepareDIBObjEncoding ***
// Prepare DIB Object saving to file or stream using GDI+
//
//    Parameters
// ADIBObj - DIB object for bitmap creation
// Result -  Returns GDI+ resulting code
//
procedure TK_GPDIBCodecsWrapper.GPPrepareDIBObjEncoding( ADIBObj : TN_DIBObj );
begin
  with ADIBObj, DIBInfo.bmi do begin
    GPB.Free;
    GPB := TGPBitmap.Create( PBitmapInfo(@DIBInfo)^, PRasterBytes );
    GPB.SetResolution( 25.4 * biXPelsPerMeter / 1000,
                       25.4 * biYPelsPerMeter / 1000 );
  end;

  GPEncPars.Count := 1;
  GPEncPars.Parameter[0].Type_ := EncoderParameterValueTypeLong;
  GPEncPars.Parameter[0].NumberOfValues := 1;
  GPPEncPars := nil;
  if GPEncMT = K_gpiJPG then
  begin
    GPEncPars.Parameter[0].Guid := EncoderQuality;
    GPEncPars.Parameter[0].Value := @GPEncQuality;
    GPPEncPars := @GPEncPars;
  end else if GPEncMT = K_gpiTIF then
  begin
    if (Ord(GPEncValue) >= Ord(EncoderValueCompressionLZW)) and
       (Ord(GPEncValue) <= Ord(EncoderValueCompressionNone)) then
    begin
      GPEncPars.Parameter[0].Guid := EncoderCompression;
      GPEncPars.Parameter[0].Value := @GPEncValue;
      GPPEncPars := @GPEncPars;
    end;
  end;
end; // end of TK_GPDIBCodecsWrapper.GPPrepareDIBObjEncoding

//******************************************** TK_GPDIBCodecsWrapper.GPSaveDIBObjToFile ***
// Save DIB Object to file with given name using GDI+
//
//    Parameters
// ADIBObj - DIB object for bitmap creation
// AFileName - file name for image saving
// Result -  Returns GDI+ resulting code
//
function  TK_GPDIBCodecsWrapper.GPSaveDIBObjToFile( ADIBObj : TN_DIBObj; const AFileName : string ) : TStatus;
//var
//  EncPars : TEncoderParameters;
//  PEncPars : PEncoderParameters;
begin
  Result :=  GPEncoderByFileName( AFileName );
  if Result <> Ok then Exit;

  GPPrepareDIBObjEncoding( ADIBObj );
{
  with ADIBObj, DIBInfo.bmi do begin
    GPB.Free;
    GPB := TGPBitmap.Create( PBitmapInfo(@DIBInfo)^, PRasterBytes );
    GPB.SetResolution( 25.4 * biXPelsPerMeter / 1000,
                       25.4 * biYPelsPerMeter / 1000 );
  end;

  EncPars.Count := 1;
  EncPars.Parameter[0].Type_ := EncoderParameterValueTypeLong;
  EncPars.Parameter[0].NumberOfValues := 1;
  PEncPars := nil;
  if GPEncMT = K_gpiJPG then begin
    EncPars.Parameter[0].Guid := EncoderQuality;
    EncPars.Parameter[0].Value := @GPEncQuality;
    PEncPars := @EncPars;
  end else if GPEncMT = K_gpiTIF then begin
    if (Ord(GPEncValue) >= Ord(EncoderValueCompressionLZW)) and
       (Ord(GPEncValue) <= Ord(EncoderValueCompressionNone)) then begin
      EncPars.Parameter[0].Guid := EncoderCompression;
      EncPars.Parameter[0].Value := @GPEncValue;
      PEncPars := @EncPars;
    end;
  end;
  Result := GPB.Save( AFileName, GPEncClsID, PEncPars );
}
  Result := GPB.Save( AFileName, GPEncClsID, GPPEncPars );
end; // end of TK_GPDIBCodecsWrapper.GPSaveDIBObjToFile

//******************************************** TK_GPDIBCodecsWrapper.GPSaveDIBObjToStream ***
// Save DIB Object to stream using GDI+
//
//    Parameters
// ADIBObj - DIB object for bitmap creation
// AStream - stream to save
// AMimeType - GDI+ MimeType enumeration
// Result -  Returns GDI+ resulting code
//
function  TK_GPDIBCodecsWrapper.GPSaveDIBObjToStream( ADIBObj : TN_DIBObj; AStream : TStream; AMimeType : TK_GPImgMimeType ) : TStatus;
var
//  EncPars : TEncoderParameters;
//  PEncPars : PEncoderParameters;
  TA : TStreamAdapter;
begin
  Result := GPEncoderByMimeType( AMimeType );
  if Result <> Ok then Exit;
  GPPrepareDIBObjEncoding( ADIBObj );
  TA := TStreamAdapter.Create( AStream );
  Result := GPB.Save( TA, GPEncClsID, GPPEncPars );
end; // end of TK_GPDIBCodecsWrapper.GPSaveDIBObjToFile

{*** end of TK_GPDIBCodecsWrapper ***}

{*** TK_SMPixComb ***}

procedure TK_SMPixComb.SMComb1( APtr1, APtr2, APtrR: Pointer );
var
  Delta : Integer;
  Itmp : Integer;

  procedure SetByteValue( BPtr1, BPtr2, BPtrR : PByte; VMin, VMax : Byte );
  begin
    if ( BPtr1^ >= VMin) and
       ( BPtr1^ <= VMax) then
    begin
      Delta := BPtr2^ - BPtr1^;
      if ( (Delta >= 0) and
           (Delta >= SMPSrcDMin) and
           (Delta <= SMPSrcDMax) ) or
         ( (Delta < 0) and
           (-Delta >= SMPSrcDMin) and
           (-Delta <= SMPSrcDMax) ) then
      begin
        Itmp := Round( BPtr1^ * SMBeta +
                                BPtr2^ * SMAlfa );
        if Itmp < 0   then itmp := 0;
        if Itmp > 255 then itmp := 255;
        BPtrR^ := Itmp;
        Exit;
      end;
    end;
    BPtrR^ := BPtr1^;
  end;

begin
  case SMPixFormat of
  0: begin
    SetByteValue( APtr1, APtr2, APtrR, SMPSrcVMin1, SMPSrcVMax1 );
  end; // 0 : begin

  1: begin
    if ( PWord(APtr1)^ >= SMPSrcVMin1) and
       ( PWord(APtr1)^ <= SMPSrcVMax1) then
    begin
      Delta := PWord(APtr2)^ - PWord(APtr1)^;
      if ( (Delta >= 0) and
           (Delta >= SMPSrcDMin) and
           (Delta <= SMPSrcDMax) ) or
         ( (Delta < 0) and
           (-Delta >= SMPSrcDMin) and
           (-Delta <= SMPSrcDMax) ) then
      begin
        Itmp := Round( PWord(APtr1)^ * SMBeta +
                                PWord(APtr2)^ * SMAlfa );
        if Itmp < 0   then itmp := 0;
        if Itmp > 256*256-1 then itmp := 256*256-1;
        PWord(APtrR)^ := Itmp;
        Exit;
      end;
    end;
    PWord(APtrR)^ := PWord(APtr1)^;
  end; // 1 : begin

  2,3: begin
    SetByteValue( PByte(TN_BytesPtr(APtr1) + 0),
                  PByte(TN_BytesPtr(APtr2) + 0),
                  PByte(TN_BytesPtr(APtrR) + 0), SMPSrcVMin1, SMPSrcVMax1 );
    SetByteValue( PByte(TN_BytesPtr(APtr1) + 1),
                  PByte(TN_BytesPtr(APtr2) + 1),
                  PByte(TN_BytesPtr(APtrR) + 1), SMPSrcVMin2, SMPSrcVMax2 );
    SetByteValue( PByte(TN_BytesPtr(APtr1) + 2),
                  PByte(TN_BytesPtr(APtr2) + 2),
                  PByte(TN_BytesPtr(APtrR) + 2), SMPSrcVMin3, SMPSrcVMax3 );
  end; // 0 : begin

  end; // case SMPixFormat of

end;

{*** end of TK_SMPixComb ***}

{*** TK_RIGDIP ***}

//******************************************************* TK_RIGDIP.Destroy ***
//
destructor TK_RIGDIP.Destroy;
begin
  inherited;
end; // destructor TK_RIGDIP.Destroy

//**************************************************** TK_RIGDIP.RIOpenFile ***
// Open File with encoded Raster Image instance
//
//    Parameters
// AFileName - file name with encoded Raster Image
// Result    -  Returns resulting code
//
function TK_RIGDIP.RIOpenFile( const AFileName: string ): TK_RIResult;
begin
  GPB.Free;
  GPB := TGPBitmap.Create(AFileName);
  RIGPResCode := RIGPGetBitmapAttrs();
  Result := rirOK;
  if RIGPResCode <> Ok then
    Result := rirFails;
end; // function TK_RIGDIP.RIOpenFile

//************************************************** TK_RIGDIP.RIOpenStream ***
// Open Stream with encoded Raster Image instance
//
//    Parameters
// AFileName - stream with encoded Raster Image
// Result    - Returns resulting code
//
function TK_RIGDIP.RIOpenStream( AStream: TStream ): TK_RIResult;
var
  TA : TStreamAdapter;
begin
  FreeAndNil( GPB );
  TA := TStreamAdapter.Create( AStream );
  try
  // Needed to skip exception while loading from PNG
    GPB := TGPBitmap.Create(TA);
    RIGPResCode := RIGPGetBitmapAttrs();
  except
    RIGPResCode := Win32Error;
    FreeAndNil( GPB );
//    TA.Free; // This alwaise raise Exception
  end;
  Result := rirOK;
  if RIGPResCode = Ok then Exit;
  Result := rirFails;
end; // function TK_RIGDIP.RIOpenStream

//*********************************************** TK_RIGDIP.RIGetImageCount ***
// Get Raster Image instance Frames counter
//
//    Parameters
// Result -  Raster Image Frames counter
//
function TK_RIGDIP.RIGetImageCount: Integer;
begin
  Result := GPFramesCount;
end; // function TK_RIGDIP.RIGetImageCount

//****************************************************** TK_RIGDIP.RIGetDIB ***
// Get DIB Object from serialized Raster Image instance
//
//    Parameters
// AImgInd - Raster Image Frame Index
// ADIBObj - Resulting DIB
// Result -  Returns resulting code
//
// If ADIBObj = nil then new DIB object will be created, use given else
//
function TK_RIGDIP.RIGetDIB( AImgInd: Integer;
                             var ADIBObj: TN_DIBObj ): TK_RIResult;
var
  PalBuf: TN_BArray;
  PPal : PColorPalette;
  PixFmt: TPixelFormat;
  ExPixFmt: TN_ExPixFmt;
  RRSize : TPoint;
  i : Integer;
  PPalItem : TN_BytesPtr;
  GPFramePixFmt : Integer;
  DIBisCreated : Boolean;
  AGPGraphics : TGPGraphics;
//  MemCheckBuf: TN_BArray;
begin
  Result := rirFails;
  RILastImageSize := Point(0,0);
  if GPFramesCount <= AImgInd then Exit;

  RIGPResCode := GPB.SelectActiveFrame( GPDimGUID, AImgInd );
  if RIGPResCode <> Ok then Exit;

  RILastImageSize.X := GPB.GetWidth();
//  Result := GPB.GetLastStatus(); // Result <> Ok for *.PNG
//  if Result <> Ok then Exit;

  RILastImageSize.Y := GPB.GetHeight();
//  Result := GPB.GetLastStatus(); // Result <> Ok for *.PNG
//  if Result <> Ok then Exit;
  RRSize := RIGetDIBMaxSize( RILastImageSize );

  GPFramePixFmt := GPB.GetPixelFormat();
//  Result := GPB.GetLastStatus(); // Result <> Ok for *.PNG
//  if Result <> Ok then Exit;


  ExPixFmt := epfBMP;
  PixFmt := pf24bit;

  // Prepare Resulting DIB Attributes
  case GPFramePixFmt of
    PixelFormat1bppIndexed,
    PixelFormat4bppIndexed,
    PixelFormat8bppIndexed:
    begin
    // PixelFormatIndexed - Check Palette if Grey
      PixFmt := pfCustom;
      ExPixFmt := epfGray8;
      // Get Palette
      SetLength( PalBuf, GPB.GetPaletteSize() );
      PPal := PColorPalette(@PalBuf[0]);
      GPB.GetPalette( PPal, Length(PalBuf) );
      // Check Palette if Grey
      for i := 0 to High(PalBuf) do
      begin
        PPalItem := TN_BytesPtr(@PalBuf[i]);
        if (PPalItem^ = (PPalItem + 1)^) and
           (PPalItem^ = (PPalItem + 2)^) then Continue;
        // Color Palette - Use Color DIB
        PixFmt := pf24bit;
        ExPixFmt := epfBMP;
        break;
      end;
    end;
  end;

  // Prepare Resulting DIB
  DIBisCreated := ADIBObj = nil;
  Result := rirOK;
  try
    if DIBisCreated then
      ADIBObj := TN_DIBObj.Create();
    ADIBObj.PrepEmptyDIBObj( RRSize.X, RRSize.Y, PixFmt, -1, ExPixFmt );
  except
    on E: Exception do begin
      N_Dump1Str( 'TK_RIGDIP.RIGetDIB error >> ' + E.Message );
      Result := rirOutOfMemory;
    end;
  end;


  // Draw GDI+ Image to Resulting DIB
  AGPGraphics := nil;
  if Result = rirOK then
    with ADIBObj do
    begin

      DIBInfo.bmi.biXPelsPerMeter := Round( GPB.GetHorizontalResolution() * 100 /2.54 * RRSize.X / RILastImageSize.X );
      DIBInfo.bmi.biYPelsPerMeter := Round( GPB.GetVerticalResolution() * 100 /2.54 * RRSize.Y / RILastImageSize.Y );

      AGPGraphics := TGPGraphics.Create(DIBOCanv.HMDC);
      RIGPResCode := AGPGraphics.DrawImage( GPB, 0, 0, RRSize.X, RRSize.Y );
      if RIGPResCode <> Ok then
      begin
        if RIGPResCode = OutOfMemory then
          Result := rirOutOfMemory
        else
          Result := rirFails;
        N_Dump1Str( 'TK_RIGDIP.RIGetDIB DrawImage error code=' + IntToSTr(Integer(RIGPResCode)) );
      end;
    end;

  AGPGraphics.Free;

  if (Result <> rirOK) and DIBisCreated then
    FreeAndNil( ADIBObj );

end; // function TK_RIGDIP.RIGetDIB

//************************************************** TK_RIGDIP.RICreateFile ***
// Create File for Raster Image Encoding instance
//
//    Parameters
// AFileName    - file name for Raster Image
// APCodingInfo - pointer to Raster Image Encoding Attributes
// Result -  Returns resulting code
//
function TK_RIGDIP.RICreateFile( const AFileName: string;
                                 APCodingInfo: TK_PRIFileEncInfo): TK_RIResult;
begin
  RIGPFileName := AFileName;
  RIGPStream := nil;
  RIPCodingInfo := APCodingInfo;
  RICurEncType := RIPCodingInfo.RIFileEncType;
  if RICurEncType = rietNotDef then RICurEncType := RIEncTypeByFileExt(AFileName);
  RIGPResCode := RIGPEncoderByType();
  Result := rirOK;
  if RIGPResCode <> Ok then
    Result := rirFails;
end; // function TK_RIGDIP.RICreateFile

//************************************************ TK_RIGDIP.RICreateStream ***
// Create Stream for Raster Image Encoding instance
//
//    Parameters
// AStream    - stream object
// APCodingInfo - pointer to Raster Image Encoding Attributes
// Result -  Returns resulting code
//
function TK_RIGDIP.RICreateStream( AStream: TStream;
                                   APCodingInfo: TK_PRIFileEncInfo): TK_RIResult;
begin
  RIGPFileName := '';
  RIGPStream := AStream;
  RIPCodingInfo := APCodingInfo;
  RICurEncType := RIPCodingInfo.RIFileEncType;
  Result := rirOK;
  RIGPResCode := RIGPEncoderByType();
  if RIGPResCode <> Ok then
    Result := rirFails;
end; // function TK_RIGDIP.RICreateStream

//************************************************ TK_RIGDIP.RIAddDIBPixels ***
// Add DIB Pixels to serialized Raster Image instance
//
//    Parameters
// APDIBInfo - pointer to DIBInfo with Pixels structure description
// APPixels  - pointer to DIB Pixels
// Result -  Returns resulting code
//
function TK_RIGDIP.RIAddDIBPixels( APDIBInfo: TN_PDIBInfo; APPixels: Pointer ): TK_RIResult;
var
  TA : TStreamAdapter;
begin

  RIGPPrepareDIBObjEncoding( APDIBInfo, APPixels );
  Result := rirOK;
  if RIGPFileName <> '' then
  begin
    RIGPResCode := GPB.Save( RIGPFileName, GPEncClsID, GPPEncPars );
  end
  else
  if RIGPStream <> nil then
  begin
    TA := TStreamAdapter.Create( RIGPStream );
    RIGPResCode := GPB.Save( TA, GPEncClsID, GPPEncPars );
  end
  else
    Result := rirFails;

  if Result <> rirOK then Exit;
  if RIGPResCode <> Ok then
    Result := rirFails;
end; // function TK_RIGDIP.RIAddDIBPixels

//****************************************************** TK_RIGDIP.RIAddDIB ***
// Add DIB Object to serialized Raster Image instance
//
//    Parameters
// ADIBObj - given DIB object to save
// Result -  Returns resulting code
//
function TK_RIGDIP.RIAddDIB( ADIBObj: TN_DIBObj ): TK_RIResult;
var
  TMPDIBObj : TN_DIBObj;
begin
  if ADIBObj.DIBExPixFmt <> epfGray16 then
    Result := inherited RIAddDIB( ADIBObj )
  else
  begin
  // GDI+ can encode only Gray8 DIBs
//    TMPDIBObj := N_CreateGray8DIBFromGray16( ADIBObj );
    TMPDIBObj := TN_DIBObj.Create( ADIBObj , ADIBObj.DIBRect, pfCustom, epfGray8 );
    Result := RIAddDIBPixels( @TMPDIBObj.DIBInfo, TMPDIBObj.PRasterBytes );
    TMPDIBObj.Free;
  end;
end; // function TK_RIGDIP.RIAddDIB

//******************************************************* TK_RIGDIP.RIClear ***
// Clear Raster Image resources
//
//    Parameters
// Result -  Returns resulting code
//
function TK_RIGDIP.RIClear: TK_RIResult;
begin
  Result := inherited RIClear();
  RIGPStream := nil;
  RIGPFileName := '';
  GPFramesCount := 0;
  FreeAndNil( GPB );
end; // function TK_RIGDIP.RIClear

//************************************** TK_RIGDIP.RIGetLastNativeErrorCode ***
// Get Last Native Error Code
//
//    Parameters
// Result -  Returns Last Native Error Code
//
function TK_RIGDIP.RIGetLastNativeErrorCode: Integer;
begin
  Result := Integer(RIGPResCode);
end; // function TK_RIGDIP.RIGetLastNativeErrorCode

//******************************************** TK_RIGDIP.RIGPGetBitmapAttrs ***
// Get Attributes from early loaded GDI+ Bitmap (from file or streaam)
//
//    Parameters
// Result -  Returns GDI+ resulting code
//
function TK_RIGDIP.RIGPGetBitmapAttrs( ): TStatus;
var
  PropBuffer : TN_BArray;
  PropSize : Integer;
  PProperty : PPropertyItem;
  GPDimsCount   : Integer;
  GPImageFormat : TGUID;

  procedure GetProperty( PropertyID : LongWord );
  begin
    PropSize := GPB.GetPropertyItemSize( PropertyID );
    if PropSize = 0 then Exit;
    if PropSize > Length(PropBuffer) then
      SetLength( PropBuffer, PropSize );
    PProperty := PPropertyItem(@PropBuffer[0]);
    GPB.GetPropertyItem( PropertyID, PropSize, PProperty );
  end;

begin
  GPFramesCount := 0;
  RICurEncType := rietNotDef;
  Result := GPB.GetLastStatus();
  if Result <> Ok then Exit;

  Result := GPB.GetRawFormat( GPImageFormat );
  if Result <> Ok then Exit;

  GPDimsCount := GPB.GetFrameDimensionsCount();
  Result := GPB.GetLastStatus();
  if Result <> Ok then Exit;

  if CompareMem(@GPImageFormat, @ImageFormatTIFF, SizeOf(TGUID) ) then
  begin
    GPDimGUID := FrameDimensionPage;
    RICurEncType := rietTIF;
  end else if CompareMem(@GPImageFormat, @ImageFormatGIF, SizeOf(TGUID) )  then
  begin
    GPDimGUID := FrameDimensionTime;
    RICurEncType := rietGIF;
  end else
  begin
    if CompareMem(@GPImageFormat, @ImageFormatPNG, SizeOf(TGUID) )  then
      RICurEncType := rietPNG
    else
    if CompareMem(@GPImageFormat, @ImageFormatJPEG, SizeOf(TGUID) )  then
      RICurEncType := rietJPG
    else
    if CompareMem(@GPImageFormat, @ImageFormatBMP, SizeOf(TGUID) )  then
      RICurEncType := rietBMP
  end;

  GPFramesCount := 1;
  if (GPDimsCount = 0) or
     ((RICurEncType <> rietGIF) and (RICurEncType <> rietTIF)) then Exit;

  GPFramesCount := GPB.GetFrameCount( GPDimGUID );

end; // end of TK_RIGDIP.RIGPGetBitmapAttrs

//************************************* TK_RIGDIP.RIGPPrepareDIBObjEncoding ***
// Prepare DIB Object saving to file or stream using GDI+
//
//    Parameters
// ADIBObj - DIB object for bitmap creation
// APCodingInfo - pointer to Raster Image Coding Info structure
// Result -  Returns GDI+ resulting code
//
procedure TK_RIGDIP.RIGPPrepareDIBObjEncoding( APDIBInfo : TN_PDIBInfo; APPixels: Pointer );
begin
  GPB.Free;
  GPB := TGPBitmap.Create( PBitmapInfo(APDIBInfo)^, APPixels );
  with APDIBInfo.bmi do
    GPB.SetResolution( 25.4 * biXPelsPerMeter / 1000,
                       25.4 * biYPelsPerMeter / 1000 );
end; // end of TK_RIGDIP.RIGPPrepareDIBObjEncoding

//********************************************* TK_RIGDIP.RIGPEncoderByType ***
// Get serializing Raster Image Encoder attributes by Container Type
//
//    Parameters
// Result -  Returns GDI+ resulting code
//
function  TK_RIGDIP.RIGPEncoderByType( ) : TStatus;
var
  NumEncoders, BuffSize : UInt;
  EncInfo : TN_BArray;
  PICI : PImageCodecInfo;
  i : Integer;
  MimeTypeString : string;
begin
  if RICurEncType = rietNotDef then
  begin
    Result := InvalidParameter;
    Exit;
  end;

  Result := GetImageEncodersSize( NumEncoders, BuffSize );
  if (BuffSize = 0) or (Result <> Ok) then Exit;

  SetLength( EncInfo, BuffSize );
  PICI := PImageCodecInfo(@EncInfo[0]);

  Result := GetImageEncoders( NumEncoders, BuffSize, PICI );
  if (Result <> Ok) then Exit;

  MimeTypeString := '';
  case RICurEncType of
    rietBMP: MimeTypeString := 'image/bmp';
    rietJPG: MimeTypeString := 'image/jpeg';
    rietGIF: MimeTypeString := 'image/gif';
    rietPNG: MimeTypeString := 'image/png';
    rietTIF: MimeTypeString := 'image/tiff';
  end;

  Result := InvalidParameter;
  for i := 0 to NumEncoders - 1 do
  begin
    if PICI.MimeType = MimeTypeString then
    begin
      GPEncClsID := PICI.Clsid;
      Result := Ok;
      break;  // Success
    end;
    Inc(PICI);
  end;
  if Result <> Ok then Exit;

  GPEncPars.Count := 1;
  GPEncPars.Parameter[0].Type_ := EncoderParameterValueTypeLong;
  GPEncPars.Parameter[0].NumberOfValues := 1;
  GPPEncPars := nil;
  if RICurEncType = rietJPG then
  begin
    GPEncPars.Parameter[0].Guid := EncoderQuality;
    GPEncPars.Parameter[0].Value := @RIPCodingInfo.RIFComprQuality;
    GPPEncPars := @GPEncPars;
  end else if RICurEncType = rietTIF then
  begin
    if (Ord(RIPCodingInfo.RIFComprQuality) >= Ord(EncoderValueCompressionLZW)) and
       (Ord(RIPCodingInfo.RIFComprQuality) <= Ord(EncoderValueCompressionNone)) then
    begin
      GPEncPars.Parameter[0].Guid := EncoderCompression;
      GPEncPars.Parameter[0].Value := @RIPCodingInfo.RIFComprQuality;
      GPPEncPars := @GPEncPars;
    end;
  end;
end; // end of TK_RIGDIP.RIGPEncoderByType

{*** end of TK_RIGDIP ***}

end.
