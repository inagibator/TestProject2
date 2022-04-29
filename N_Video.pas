unit N_Video;
//***** Video processing Tools

// 20.07.15 - new algorythm for creating a video icon while import (N_GetVideoFileInfoFromSampleGrabber)

// 21.07.15 - added function N_GetVideoFileInfo that is a main function for
// getting video information and chooses an algorythm to do it

// 03.08.15 - error with getting a video information is fixed

interface
uses
  Windows, Classes, Graphics, SysUtils, ActiveX, Dialogs,
  DirectShow9, Types,
  N_Types, N_Gra2;

const
  N_WDM_2860_Capture = '352 240 352 480 480 480 720 480'; // Unable resolutions for WDM

type TN_BaseFilterInfo = packed record // Info about IBaseFilter
  BFIFilter: IBaseFilter;    // Filter IBaseFilter Interface
  BFIName:   string;         // Filter Name
//  BFIInPinsCount:  integer;  // Filter Input Pins Counter
//  BFIOutPinsCount: integer;  // Filter Output Pins Counter
  BFIVendorStr: string;     // Venodor info string
end; // type TN_BaseFilterInfo = packed record // Info about IBaseFilter
type TN_PBaseFilterInfo = ^TN_BaseFilterInfo;

type TN_VideoFileInfo = packed record // Info about Video File
  VFINumStreams:  integer; // Number of Streams in File
  VFIFrameWidth:  integer; // Frame Width in Pixels
  VFIFrameHeight: integer; // Frame Height in Pixels
  VFIFileSize:      int64; // Video File Size in bytes
  VFIDuration:      float; // Duration in seconds
  VFIFramesRate:    float; // Frames Rate in Frames per second

  VFIMediaFormat:          string; // Video Stream Known Format GUID Name or GUID as String
  VFIStreamsInfo:       TN_SArray; // For all Streams three strings per stream:
  VFIFixedSizeSamples:    integer; // AMMediaType.bFixedSizeSamples field
  VFITemporalCompression: integer; // AMMediaType.bTemporalCompression field
  VFIBitRate:             integer; // VideoInfoHeader.dwBitRate field
  VFIVideoStreamInd:      integer; // used Video Stream index (first Video Stream available)

  VFICoRes:  HResult; // COM result code (Error code)
  VFIIError: integer; // Own Integer Error code, 0 if OK
  VFISError: string;  // VFICoRes or VFIIError description as String

//  VFISError:   string;   // Error string or '' if everything is OK
  VFINumDIBs:   integer;   // Number of DIBs in VFIDIBsArray
  VFIFirstDIBTime: float;  // Time in seconds of First DIB
  VFIDIBTimeStep:  float;  // Time in seconds between subsecuent DIBs
  VFIDIBsArray: TN_DIBObjArray; // Array of resulting DIBs
end; // type TN_VideoFileInfo = packed record // Info about Video File
type TN_PVideoFileInfo = ^TN_VideoFileInfo;

type TN_VFThumbParams = packed record // Video File Thumbnail Params
  VFTPThumbSize:        integer; // max X,Y Thumbnail Size in Pixels
  VFTPMainBordWidth:    float;   // Main (Gray) border width in Percents of VFTPThumbSize
  VFTPBlackBordWidth:   float;   // Black border width around Image in Percents of VFTPThumbSize
  VFTPWhiteWholesWidth: float;   // White Wholes (inside MainBorder) width in Percents of VFTPThumbSize
end; // type TN_VFThumbParams = packed record // Video File Thumbnail Params
type TN_PVFThumbParams = ^TN_VFThumbParams;

type TN_ControlStreamFlags = Set Of ( csfPreview, csfCapture, csfStart, csfStop );
type TN_VideoCapsFlags = Set Of ( vcfDeb1, vcfSizesList );

type TN_VideoCaptObj = class( TObject ) //***
    //***** should be set on input:
  VCOVCaptDevName:      string; // Video Capturing Device Name
  VCOVComprFiltName:    string; // Video Compressor Filter Name
  VCOVComprSectionName: string; // MemIni Section Name with preferred VideoCompressor Names
  VCOWindowHandle:  THandle; // Windows WinHandle where Video Priview should be
  VCOMaxWindowRect:   TRect; // Max Preview Rect in VCOWindowHandle
  VCOFileNames: Array [0..1] of string; // two avi File Names for resulting Video
  VCOMinFileSize:     int64;  // Minimal Video File initial Size in bytes

    //***** DirectShow Intefaces:
  VCOIGraphBuilder:      IGraphBuilder;
  VCOICaptGraphBuilder:  ICaptureGraphBuilder2;
  VCOIMux:               IBaseFilter;
  VCOISink:              IFileSinkFilter;
  VCOIMediaControl:      IMediaControl;
  VCOIStreamConfig:      IAMStreamConfig;
  VCOIVideoWindow:       IVideoWindow;
  VCOIVideoProcAmp:      IAMVideoProcAmp;
  VCOISampleGrabber:     ISampleGrabber;

    //***** DirectShow Filters:
  VCOIVideoCaptFilter:   IBaseFilter;
  VCOIAudioCaptFilter:   IBaseFilter;
  VCOIVideoComprFilter:  IBaseFilter;
  VCOIAudioComprFilter:  IBaseFilter;
  VCOISampleGrabFilter:  IBaseFilter;
  VCONullRendererFilter: IBaseFilter;

    //***** Other fields:
  VCOFileNameInd:  integer; // Index in VCOFileNames for NEXT recording (next FileName)
  VCORecordGraph:  boolean; // RecordGrapth for Recording Videos
  VCOGrabGraph:    boolean; // GrabGraph for Grabbing Samples
  VCONowRecording: boolean; // writing to avi file Stream is now working (not stopped)
  VCOCurWindowRect: TRect; // Current Preview Rect in VCOWindowHandle (can be any size, streching is always used)

  VCOCoRes:        HResult; // COM result code (Error code)
  VCOIError:       integer; // Own Integer Error code
  VCOSError:       string;  // VCOCoRes or VCOIError description as String
  VCOGraphState:   TFilterState; // 0-Stopped, 1-Paused, 2-Running
//  VCOVideoMediaSubtype: TGUID; // Video format or NilGUID if any format is OK
  VCONeededVideoCMST: TGUID; // Needed Video Capture Media SubType format or NilGUID if any format is OK
  VCOCurVideoCMST:    TGUID; // Current Video Capture Media SubType format
  VCOStrings:      TStringList;
  VCOUnableResolutions: TStringList; // for disabling resolutions

  VCOCaptPin: integer;  // Capture Pin type 0-PIN_CATEGORY_CAPTURE, 1-PIN_CATEGORY_CAPTURE

  constructor Create  ();
  constructor Create3 ( AWindowHandle: THandle; AMaxWindowRect: TRect;
                        ABaseFileName: string; AMinFileSize: int64 );
  destructor Destroy  (); override;

  procedure VCOGetErrorDescr    ( ACoRes: HResult );
  function  VCOCheckRes         ( AIError: integer ): boolean;
  procedure VCODumpString       ( AStr: string );
  procedure VCOPrepVideoFiles   ();
  function  VCOGetGraphState    (): integer;
  procedure VCOEnumVideoCaps    ( AVideoCaps: TStrings );
  function  VCOGetNextFilter    ( ACurFilter: IBaseFilter; ADirection: PGUID; APBFI: TN_PBaseFilterInfo ): IBaseFilter;
  function  VCOGetCrossbarFilter (): IBaseFilter;
  procedure VCOEnumVideoSizes   ( AVideoSizes: TStrings );
  procedure VCOEnumFilters      ( AStings: TStrings );
  procedure VCOEnumFilters2     ( AStrings: TStrings );
  procedure VCOEnumFilterPins   ( AStrings: TStrings; AFilter: IBaseFilter );
  procedure VCOSetVideoSize     ( AInpSizeStr: string; out ANewSize: TPoint );
  procedure VCOClearGraph       ();
  procedure VCOPrepInterfaces   ();
  procedure VCOConstructGraph   (); // obsolete!
  procedure VCOPrepVideoWindow  ();
  procedure VCOPrepRecordGraph  ();
  procedure VCOPrepGrabGraph    ();
  procedure VCOStartRecording   ();
  function  VCOStopRecording    (): string;
  function  VCOGrabSample       (): TN_DIBObj;
  procedure VCOShowFilterDialog ( AIFilter: IBaseFilter; AWindowHandle: THandle );
  procedure VCOShowStreamDialog ( AWindowHandle: THandle );
  procedure VCOControlStream    ( AFlags: TN_ControlStreamFlags );
end; // type TN_VideoCaptObj = class( TObject )

//*** VCOIError ranges list:
// 01 - 19 - VCOPrepInterfaces
// 20 - 29 - VCOPrepRecordGraph
// 30 - 39 - VCOPrepGrabGraph
// 40 - 43 - VCOShowFilterDialog
// 44 - 48 - VCOShowStreamDialog
// 50 - 52 - VCOControlStream
// 53 - 56 - VCOPrepVideoFiles
// 60 - 69 - VCOGrabSample
// 70 - 76 - VCOSetVideoSize
// 77 - 79 - VCOEnumVideoSizes
// 80 - 82 - VCOStartRecording
// 83 - 89 - VCOStopRecording
// 90 - 94 - VCOEnumVideoCaps

//*************************  Global Procedures  ***************

procedure N_DSFreeMediaType   ( APMediaType: PAMMediaType );
procedure N_DSDeleteMediaType ( APMediaType: PAMMediaType );
function  N_GetDSErrorDescr   ( ACoRes: HResult ): string;

function  N_DSEnumFilters  ( const clsidDeviceClass: TGUID; ADevName: String;
                             ADevNamesList: TStrings; out AErrCode: integer ): IBaseFilter;
function  N_DSGetAnyFilter ( const clsidDeviceClass: TGUID; ASectionName: string;
                             out AErrCode: integer; out AFilterName: string ): IBaseFilter;
function  N_GetVideoFileInfo  ( AFName: string; APVFInfo: TN_PVideoFileInfo ): integer;
function  N_GetVideoFileInfoFromMediaDet     ( AFName: string;
                                         APVFInfo: TN_PVideoFileInfo ): integer;
function  N_GetVideoFileInfoFromSampleGrabber( AFName: string;
                                         APVFInfo: TN_PVideoFileInfo ): integer;
function  N_AddVideoFileDescr ( APVFInfo: TN_PVideoFileInfo; AResStrings: TStrings ): integer; overload;
function  N_AddVideoFileDescr ( AFName: string; AResStrings: TStrings ): integer; overload;
function  N_GetVideoFileThumb ( AFName: string; APVFThumbPar: TN_PVFThumbParams ): TN_DIBObj;
procedure N_DSEnumVideoSizes  ( ADevName: string; AResList: TStrings );
procedure N_DSEnumVideoCaps   ( ADevName: string; AResList: TStrings );
function  N_GetGUIDName       ( const AGUID: TGUID ): string;

const
  MAXLONGLONG = $7FFFFFFFFFFFFFFF;

var
  N_DSErrorString: string;
  N_GraphStates: Array [0..2] of string = ( 'Stopped', 'Paused', 'Running' );
  N_LogDevNamesList: TStringList; // List of already logged devices 

implementation
uses math, variants,
  DirectDraw,
  K_CLib0, K_Parse,
  N_Lib0, N_Lib1, N_Lib2, N_Gra0, N_Gra1; //, N_CM1;

//*********************** TN_VideoCaptObj Class methods

//************************************************** TN_VideoCaptObj.Create ***
// Create Self
//
constructor TN_VideoCaptObj.Create();
begin
  VCOStrings := TStringList.Create;
  VCOMinFileSize := 10*1024*1024;
  VCOFileNameInd := 1; // first capturing will be to VCOFileNames[0]
end; // constructor TN_VideoCaptObj.Create;

//************************************************* TN_VideoCaptObj.Create3 ***
// Create Self by given Params
//
//     Parameters
// AWindowHandle  - Windows Window Handle where to show Video
// AMaxWindowRect - Max allowed Rect coords in given Window where to show Video
// ABaseFileName  - Base File name for Video Recording
// AMinFileSize   - Minimal File Size before recording (in bytes)
//
constructor TN_VideoCaptObj.Create3( AWindowHandle: THandle;
            AMaxWindowRect: TRect; ABaseFileName: string; AMinFileSize: int64 );
var
  FName: string;
begin
  Create();

  VCOWindowHandle  := AWindowHandle;
  VCOMaxWindowRect := AMaxWindowRect;
  VCOCurWindowRect := AMaxWindowRect;
  VCOMinFileSize   := AMinFileSize;

  FName := K_ExpandFileName( ABaseFileName );
  VCOFileNames[0]  := ChangeFileExt( FName, '_0.avi' );
  VCOFileNames[1]  := ChangeFileExt( FName, '_1.avi' );
end; // constructor TN_VideoCaptObj.Create3;

//************************************************* TN_VideoCaptObj.Destroy ***
// Close all TWAIN Objects and Destroy Self
//
destructor TN_VideoCaptObj.Destroy;
begin
  VCOClearGraph();
  VCOStrings.Free;

  inherited;
end; // destructor TN_VideoCaptObj.Destroy;

//**************************************** TN_VideoCaptObj.VCOGetErrorDescr ***
// Clear Video Capturing Graph Filters and other objects
//
//     Parameters
// Result - Return 0 for Stopped, 1 for Paused, 2 for Running or -1 if error
//
procedure TN_VideoCaptObj.VCOGetErrorDescr( ACoRes: HResult );
begin
  VCOSError := N_GetDSErrorDescr( ACoRes );
end; // procedure TN_VideoCaptObj.VCOGetErrorDescr

//********************************************* TN_VideoCaptObj.VCOCheckRes ***
// Check COM result in VCOCoRes
//
//     Parameters
// AIError - given Error Number to assign to VCOIError if Failed
// Result  - Return True if failed or False if OK
//
function TN_VideoCaptObj.VCOCheckRes( AIError: integer ): boolean;
begin
  Result := FAILED( VCOCoRes );

  if Result then // failed
  begin
    VCOIError := AIError;
    VCOGetErrorDescr( VCOCoRes );
    VCODumpString( Format( 'VCO Error=%d, %s', [VCOIError, VCOSError]) );
  end else // OK
  begin
    VCOIError := 0;
    VCOSError := '';
  end;
end; // function TN_VideoCaptObj.VCOCheckRes

//******************************************* TN_VideoCaptObj.VCODumpString ***
// Check COM result in VCOCoRes
//
//     Parameters
// AIError - given Error Number to assign to VCOIError if Failed
// Result  - Return True if failed or False if OK
//
procedure TN_VideoCaptObj.VCODumpString( AStr: string );
begin
  N_Dump2Str( 'VCO: ' + AStr );
end; // procedure TN_VideoCaptObj.VCODumpString

//*************************************** TN_VideoCaptObj.VCOPrepVideoFiles ***
// Prepare two Files for Video Capturing
//
// VCOICaptGraphBuilder Interface is used and should be already OK.
// Errors in range 53 - 55 are checked
//
procedure TN_VideoCaptObj.VCOPrepVideoFiles();
var
  WFileName: WideString;
begin
  VCOIError := 53;
  VCOSError := 'VCOICaptGraphBuilder = nil';
  if VCOICaptGraphBuilder = nil then Exit;

  if N_GetFileSize( VCOFileNames[0] ) < VCOMinFileSize then // Prepare VCOFileNames[0]
  begin
    WFileName := VCOFileNames[0];
    VCOCoRes  := VCOICaptGraphBuilder.AllocCapFile( PWideChar(WFileName), VCOMinFileSize );
    if VCOCheckRes( 54 ) then Exit;
  end; // if N_GetFileSize( VCOFileNames[0] ) < VCOMinFileSize then

  if N_GetFileSize( VCOFileNames[1] ) < VCOMinFileSize then // Prepare VCOFileNames[1]
  begin
    WFileName := VCOFileNames[1];
    VCOCoRes := VCOICaptGraphBuilder.AllocCapFile( PWideChar(WFileName), VCOMinFileSize );
    if VCOCheckRes( 55 ) then Exit;
  end; // if N_GetFileSize( VCOFileNames[1] ) < VCOMinFileSize then

  //***** Video Fileas were prepared OK if it was needed
  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj.VCOPrepVideoFiles

//**************************************** TN_VideoCaptObj.VCOGetGraphState ***
// Get current Graph state in VCOGraphState variable and return it as integer
//
//     Parameters
// Result - Return current Graph state as integer
//
function TN_VideoCaptObj.VCOGetGraphState(): integer;
begin
  Result := -1;
  if VCOIMediaControl <> nil then
  begin
    VCOIMediaControl.GetState( 100, VCOGraphState ); // 100 is timeout in ms
    Result := integer(VCOGraphState);
  end;
end; // function TN_VideoCaptObj.VCOGetGraphState

//**************************************** TN_VideoCaptObj.VCOEnumVideoCaps ***
// Enumerate Video Capturing Capabilities of current VCOIVideoCaptFilter
//
//     Parameters
// AVideoCaps - TStringList with resulting Video Capturing Capabilities
//
// VCOIStreamConfig Interface is used and should be already OK.
// Mainly for showing to User, procedure result is not used in Pascal Code
//
// The following field are collected:
// - current Graph State and Mediatype
// - Media majortype and subtype
// - Video Info Format Type
// - Frames per second
// - Frame Size
//
procedure TN_VideoCaptObj.VCOEnumVideoCaps( AVideoCaps: TStrings );
var
  i, NumCaps, CapsSize, CurWidth, CurHeight: integer;
  Str: string;
  CurFramesPerSec: double;
  VSCC: TVideoStreamConfigCaps;
//  CoRes: HResult;
  PMediaType: PAMMediaType;
  Label Fin;
begin
  AVideoCaps.Clear;
  if VCOIStreamConfig = nil then Exit; // a precaution

  VCOCoRes := VCOIStreamConfig.GetNumberOfCapabilities( NumCaps, CapsSize );
  if VCOCheckRes( 90 ) then Exit;

  VCOGetGraphState();
  Str := Format( '* VideoCaps of %s (%s) from %s', [ VCOVCaptDevName,
                              N_GraphStates[integer(VCOGraphState)],
                              K_DateTimeToStr(SysUtils.Date + SysUtils.Time) ] );
  AVideoCaps.Add( Str );

  VCOCoRes := VCOIStreamConfig.GetNumberOfCapabilities( NumCaps, CapsSize );
  if VCOCheckRes( 91 ) then Exit;

  for i := -1 to NumCaps-1 do // along current mode and all capabilities
  begin
    if i = -1 then // get current PMediaType
      VCOCoRes := VCOIStreamConfig.GetFormat( PMediaType )
    else // i >= 0, get i-th Capability
      VCOCoRes := VCOIStreamConfig.GetStreamCaps( i, PMediaType, VSCC ); // get i-th Capability

    if VCOCheckRes( 92 ) then Exit;

    with PMediaType^ do
    begin
      with PVideoInfoHeader(pbFormat)^ do
      begin
        CurFramesPerSec := 1.0e7/AvgTimePerFrame;
        CurWidth  := bmiHeader.biWidth;
        CurHeight := abs(bmiHeader.biHeight);
      end; // with PVideoInfoHeader(pbFormat)^ do

      Str := Format( '%02d) ', [i] );

      if IsEqualGUID( MajorType,  MEDIATYPE_Video ) then Str := Str + 'Video, '
      else Str := Str + Format( 'MT=%s ', [GUIDToString(MajorType)] );

      Str := Str + N_GetGUIDName( SubType ) + ', ';
//      if      IsEqualGUID(subtype, MEDIASUBTYPE_RGB24)  then Str := Str + 'RGB24, '
//      else if IsEqualGUID(subtype, MEDIASUBTYPE_RGB32)  then Str := Str + 'RGB32, '
//      else if IsEqualGUID(subtype, MEDIASUBTYPE_ARGB32) then Str := Str + 'ARGB32, '
//      else if IsEqualGUID(subtype, MEDIASUBTYPE_YUY2)   then Str := Str + 'YUY2, '
//      else Str := Str + Format( 'ST=%s ', [GUIDToString(subtype)] );

      Str := Str + N_GetGUIDName( FormatType ) + ', ';
//      if IsEqualGUID(formattype, FORMAT_VideoInfo)   then Str := Str + 'FT=VI, '
//      else Str := Str + Format( 'FT=%s ', [GUIDToString(formattype)] );

      Str := Str + Format( 'FPS=%.1f, %d x %d, ',
                                         [CurFramesPerSec,CurWidth,CurHeight] );
      AVideoCaps.Add( Str );

      N_DSDeleteMediaType( PMediaType ); // delete MediaType record allocated by DirectShow
    end; // with PMediaType^ do
  end; // for i := -1 to NumCaps-1 do // along current mode and all capabilities

end; // procedure TN_VideoCaptObj.VCOEnumVideoCaps

//*************************************** TN_VideoCaptObj.VCOEnumVideoSizes ***
// Enumerate Video Capturing Sizes of current VCOIVideoCaptFilter
//
//     Parameters
// AVideoSizes - TStringList with resulting Video Capturing Sizes
//
// VCOIStreamConfig Interface is used and should be already OK.
//
// Video Capturing Sizes are collected and ordered in AVideoSizes as strings
// in 'Width x Height' ('%4d x %d') fromat (%4d is used for ease of ordering)
// Errors in range 77 - 78 are checked
//
procedure TN_VideoCaptObj.VCOEnumVideoSizes(AVideoSizes: TStrings);
var
  i, NumCaps, CapsSize: integer;
  WrkSL: TStringList;
  VSCC: TVideoStreamConfigCaps;
  PMediaType: PAMMediaType;

  WrkIndex, WrkWidth, WrkHeight: integer;
  WrkString, NameString: string;

  label StopEnum;
begin
  AVideoSizes.Clear;
  if VCOIStreamConfig = nil then
    Exit; // a precaution

  VCOCoRes := VCOIStreamConfig.GetNumberOfCapabilities(NumCaps, CapsSize);
  if VCOCheckRes(77) then
    Exit;

  WrkSL := TStringList.Create;
  WrkSL.Sorted := True;
  WrkSL.Duplicates := dupIgnore; // ignore duplicated Strings (a precaution)

  if NumCaps > 0 then
  begin
    i := 0;
   // for i := 0 to NumCaps - 1 do // along all capabilities
    while True do//VCOCoRes <> S_FALSE do
    begin
      VCOCoRes := VCOIStreamConfig.GetStreamCaps( i, PMediaType, VSCC );
      if ( VCOCoRes = S_OK ) then
      begin
      // get i-th Capability
      //if VCOCheckRes(78) then
     //   Exit;
      Inc(i);

      // ***** Add checking pbFormat type (may be VideoInfoHeader2!?)

      with PMediaType^, PVideoInfoHeader(pbFormat)^.bmiHeader do
      begin
          if ( biWidth > 0 ) and ( abs(biHeight)  > 0 ) then

            if ( IsEqualGUID(VCONeededVideoCMST, NilGUID) or // any subtype is OK
                                 IsEqualGUID(VCONeededVideoCMST, subtype) ) then
            WrkSL.Add( Format('%4d x %d', [biWidth, abs(biHeight)]) );

      end;

      N_DSDeleteMediaType(PMediaType); // delete MediaType record allocated by DirectShow

      end
      else
        goto StopEnum;
    end; // for i := 0 to NumCaps-1 do // along all capabilities
  end
  else
  begin
    VCOCoRes := VCOIStreamConfig.GetFormat( PMediaType );
    with PMediaType^ do
      with PVideoInfoHeader(pbFormat)^.bmiHeader do
      begin
        WrkSL.Add( Format('%4d x %d', [biWidth, abs(biHeight)]) );
      end;
    N_Dump2Str(
      '            VFW Test: Inside Null NumCaps section of VCOEnumVideoSizes');

  end;

StopEnum:
  N_Dump2Str('            VFW Test: Inside VCOEnumVideoSizes, NumCaps=' +
                                                             IntToStr(NumCaps));

  NameString := StringReplace( VCOVCaptDevName, ' ', '_', [rfReplaceAll] );
  NameString := StringReplace( NameString, '-', '_', [rfReplaceAll] );
  VCOUnableResolutions := TStringList.Create; // create list of unable resolutions
  WrkString := N_MemIniToString( 'CMS_UserDeb', NameString, '' ); // reading from string of resolutions from ini

  //***** adding list of unable resolutions from ini-file
  WrkHeight := 0;

  if WrkString <> '' then
  begin
    while WrkHeight <> N_NotAnInteger do // if there are some unable resolutions
    begin
      WrkHeight := N_ScanInteger( WrkString );
      WrkWidth := N_ScanInteger( WrkString );
      VCOUnableResolutions.Add( Format( ' %d x %d', [WrkHeight, WrkWidth]) );
    end;

    for i := 0 to VCOUnableResolutions.Count - 1 do
    begin
      WrkIndex := WrkSL.IndexOf( VCOUnableResolutions[i] );
      if WrkIndex <> -1 then
      begin
        N_Dump1Str( 'Delete resolution: '+WrkSL[WrkIndex] );
        WrkSL.Delete( WrkIndex );
      end;
    end;
  end;

  //***** adding list of unable resolutions for WDM
  N_Dump1Str( 'Adding list of unable resolutions for WDM' );
  if NameString = 'WDM_2860_Capture' then
  begin
    N_Dump1Str( 'NameString is okay' );
    WrkString := N_WDM_2860_Capture;
    WrkHeight := 0;

    while WrkHeight <> N_NotAnInteger do // if there are some unable resolutions
    begin
      WrkHeight := N_ScanInteger( WrkString );
      WrkWidth := N_ScanInteger( WrkString );
      VCOUnableResolutions.Add( Format(' %d x %d', [WrkHeight, WrkWidth]) );
      N_Dump1Str( Format( ' %d x %d', [WrkHeight, WrkWidth]) );
    end;

    //***** disabling resolutions
    for i := 0 to VCOUnableResolutions.Count - 1 do
    begin
      WrkIndex := WrkSL.IndexOf( VCOUnableResolutions[i] );
      if WrkIndex <> -1 then
      begin
        N_Dump1Str( 'Delete resolution: '+WrkSL[WrkIndex] );
        WrkSL.Delete( WrkIndex );
      end;
    end;
  end;

  FreeAndNil( VCOUnableResolutions );

  AVideoSizes.AddStrings( WrkSL );
  VCODumpString( AVideoSizes.Text );
  WrkSL.Free;
end; // procedure TN_VideoCaptObj4.VCOEnumVideoSizes

//**************************************** TN_VideoCaptObj.VCOGetNextFilter ***
// Get Next Filter
//
//     Parameters
// ACurFilter - start Filter, from where to search
// ADirection - search direction (UpStream or DownStream) or nil for getting info about ACurFilter
// APBFI      - pointer to IBaseFilter Info record
// Result     - Return next IBaseFilter or nil if not found
//
function TN_VideoCaptObj.VCOGetNextFilter( ACurFilter: IBaseFilter;
                    ADirection: PGUID; APBFI: TN_PBaseFilterInfo ): IBaseFilter;
var
  FilterInfo: TFilterInfo;
  PVendorStr: PWideChar;
begin
  Result := nil;

  if ADirection = nil then // get info about ACurFilter
    Result := ACurFilter
  else
  begin
    VCOCoRes := VCOICaptGraphBuilder.FindInterface( ADirection, nil,
                                          ACurFilter, IID_IBaseFilter, Result );

    if Failed( VCOCoRes ) then Result := nil;
  end;

  ZeroMemory( APBFI, SizeOf(TN_PBaseFilterInfo) );

  if Result <> nil then // fill APBFI^ record
  with APBFI^ do
  begin
    BFIFilter := Result;

    VCOCoRes := Result.QueryFilterInfo( FilterInfo );
    if Succeeded( VCOCoRes ) then
      BFIName := FilterInfo.achName; // Filter Name

    VCOCoRes := Result.QueryVendorInfo( PVendorStr );
    if Succeeded( VCOCoRes ) then
    begin
      BFIVendorStr := PVendorStr^;
      CoTaskMemFree( PVendorStr ); // free memory allocated in QueryVendorInfo
    end;

  end; // if Result <> nil then // fill APBFI^ record
end; // function TN_VideoCaptObj.VCOGetNextFilter

//************************************ TN_VideoCaptObj.VCOGetCrossbarFilter ***
// Get Crossbar Filter or nil if absent
//
//     Parameters
// ACurFilter - start Filter, from where to search
// ADirection - search direction (UpStream or DownStream) or nil for getting info about ACurFilter
// APBFI      - pointer to IBaseFilter Info record
// Result     - Return Crossbar Filter IBaseFilter or nil if not found
//
function TN_VideoCaptObj.VCOGetCrossbarFilter(): IBaseFilter;
var
  AMCrossbarInterface: IAMCrossbar;
begin
  Result := nil;

  VCOCoRes := VCOICaptGraphBuilder.FindInterface( @LOOK_UPSTREAM_ONLY, nil,
                    VCOIVideoCaptFilter, IID_IAMCrossbar, AMCrossbarInterface );

  if Failed( VCOCoRes ) or ( AMCrossbarInterface = nil ) then Exit;

  // Crossbar exists. Get its IBaseFilter interface.

  VCOCoRes := AMCrossbarInterface.QueryInterface( IID_IBaseFilter, Result );

  if Succeeded( VCOCoRes ) then Exit;

  Result := nil;
end; // function TN_VideoCaptObj.VCOGetCrossbarFilter

//****************************************** TN_VideoCaptObj.VCOEnumFilters ***
// Enumerate all Filters in current Graph
//
//     Parameters
// AStings - TStrings where to collect info about Filters
//
//
procedure TN_VideoCaptObj.VCOEnumFilters( AStings: TStrings );
var
  i: integer;
  CurFilter: IBaseFilter;
  MyFilterInfo: TN_BaseFilterInfo;
begin
  CurFilter := VCOGetNextFilter( VCOIVideoCaptFilter, nil, @MyFilterInfo );

  if CurFilter <> nil then
    with MyFilterInfo do
      AStings.Add( 'VideoCaptFilter:' + BFIName + ', Vendor:' + BFIVendorStr )
  else
    AStings.Add( 'no info about VCOIVideoCaptFilter' );

  CurFilter := VCOIVideoCaptFilter;
  i := 0;

  while True do //***** Look Upstream from VCOIVideoCaptFilter
  begin
    CurFilter := VCOGetNextFilter( CurFilter, @LOOK_UPSTREAM_ONLY,
                                                                @MyFilterInfo );
    if CurFilter = nil then Break; // no more UPSTREAM Filters
    Dec ( i );

    if CurFilter <> nil then
      with MyFilterInfo do
        AStings.Add( IntToStr(i) + ' Up Filter :' + BFIName + ', Vendor:' +
                                                                 BFIVendorStr );
  end; // while True do //***** Look Upstream from VCOIVideoCaptFilter

  CurFilter := VCOIVideoCaptFilter;
  i := 0;

  while True do //***** Look Upstream from VCOIVideoCaptFilter
  begin
    CurFilter := VCOGetNextFilter( CurFilter, @LOOK_DOWNSTREAM_ONLY,
                                                                @MyFilterInfo );
    if CurFilter = nil then Break; // no more DOWNSTREAM Filters
    Inc ( i );

    if CurFilter <> nil then
      with MyFilterInfo do
        AStings.Add( IntToStr(i) + ' Down Filter :' + BFIName + ', Vendor:'
                                                               + BFIVendorStr );
  end; // while True do //***** Look Upstream from VCOIVideoCaptFilter

end; // procedure TN_VideoCaptObj.VCOEnumFilters

//***************************************** TN_VideoCaptObj.VCOEnumFilters2 ***
// Enumerate all Filters in current Graph
// Improved version. Enumerates all filters in all branches of the graph.
//
//     Parameters
// AStrings - TStrings where to collect info about Filters
//
procedure TN_VideoCaptObj.VCOEnumFilters2( AStrings: TStrings );
var
  NumberOfFiltersReceived: Cardinal;
  CurFilter: IBaseFilter;
  FilterEnumerator: IEnumFilters;
  MyFilterInfo: TN_BaseFilterInfo;

  procedure OutFilterInfo(); // local
  // Coolect Info about the Filter and his pins to AStrings
  begin
    with MyFilterInfo do
      AStrings.Add( 'Filter: ' + BFIName + ', Vendor: "' + BFIVendorStr + '"' );

    VCOEnumFilterPins( AStrings, CurFilter );
  end; // procedure OutFilterInfo(); // local

  function FillFilterInfo( aFilter: IBaseFilter ): TN_BaseFilterInfo; // local
  // Return Info about Filter in a TN_BaseFilterInfo formatted record
  var
    FilterInfo: TFilterInfo;
    PVendorStr: PWideChar;
  begin
    with Result do
    begin
      BFIFilter := aFilter;
      VCOCoRes := aFilter.QueryFilterInfo( FilterInfo );

      if Succeeded( VCOCoRes ) then
        BFIName := FilterInfo.achName; // Filter Name

      VCOCoRes := aFilter.QueryVendorInfo( PVendorStr );
      if Succeeded( VCOCoRes ) then
      begin
        BFIVendorStr := PVendorStr^;
        CoTaskMemFree( PVendorStr ); // free memory allocated in QueryVendorInfo
      end;
    end; // with Result do
  end; // function FillFilterInfo // local

begin //************************** main body of TN_VideoCaptObj.VCOEnumFilters2

  VCOIGraphBuilder.EnumFilters( FilterEnumerator );
  FilterEnumerator.Reset;

  while S_OK=FilterEnumerator.Next(1, CurFilter, @NumberOfFiltersReceived) do
  begin
    MyFilterInfo := FillFilterInfo( CurFilter );
    OutFilterInfo;
  end;
end; // procedure TN_VideoCaptObj.VCOEnumFilters2

//*************************************** TN_VideoCaptObj.VCOEnumFilterPins ***
// Enumerate all Pins of given AFilter
//
//     Parameters
// AStings - TStrings where to collect info about Pins
// AFilter - given Filter
//
procedure TN_VideoCaptObj.VCOEnumFilterPins( AStrings: TStrings; AFilter: IBaseFilter );
var
  PinsEnumerator: IEnumPins;
  Pin, ExternalPin: IPin;
  NumberOfPins, Count: Cardinal;
  PinInfo, ExternalPinInfo: TPinInfo;
  ExternalFilterInfo: TFilterInfo;
begin
  if AFilter = nil then Exit;

  try
    AFilter.EnumPins( PinsEnumerator );
    PinsEnumerator.Reset;
    PinsEnumerator.Next( 1, Pin, @NumberOfPins );
    Count := 1;
    while NumberOfPins <> 0 do begin
      Pin.QueryPinInfo( PinInfo );  // Ask for a PinInformation
      AStrings.Add( '    -Pin number '+ IntToStr(Count) );
      AStrings.Add( '         -PinAchName: '+PinInfo.achName );

      Case PinInfo.dir of
        PINDIR_INPUT:  AStrings.Add( '         -PinDirection: IN' );
        PINDIR_OUTPUT: AStrings.Add( '         -PinDirection: OUT' );
        else           AStrings.Add( '         -PinDirection: Other ('+ IntToStr(Ord(PinInfo.dir))+')' );
      end; // Case PinInfo.dir of

      PinInfo.pFilter := nil;
      ExternalPin := nil;
      //Check the connection of the pin
      Pin.ConnectedTo( ExternalPin );

      if ExternalPin <> nil then
      begin
        //If connected, then we need to know, where to exactly
        ExternalPin.QueryPinInfo(ExternalPinInfo);
        ExternalPinInfo.pFilter.QueryFilterInfo(ExternalFilterInfo);
        AStrings.Add('         -ConnectedTo: '+ ExternalFilterInfo.achName);
      end else // ExternalPin = nil
        AStrings.Add('         -Not connected');

      CoTaskMemFree( @ExternalFilterInfo );
      ExternalPinInfo.pFilter := nil;
      PinsEnumerator.Next( 1, Pin, @NumberOfPins );
      inc( Count );
    end; //while NumberOfPins<>0 do
  except
    ShowMessage( AStrings.Text );
  end; //try .. except
end; // procedure TN_VideoCaptObj.VCOEnumFilterPins

//***************************************** TN_VideoCaptObj.VCOSetVideoSize ***
// Set given Video Capturing Size for current VCOIVideoCaptFilter
//
//     Parameters
// AInpSizeStr - given new size as string (Width x Height) or '' if Size should not be changed
// ANewSize    - resulting Size (on output) for any given AInpSizeStr,
//               ANewSize.X = -1 if error
//
// VCOIStreamConfig Interface is used and should be already OK.
// Because Stream should be temporary stopped VCORecordGraph is used and should be already OK
// Errors in range 70 - 75 are checked
//
procedure TN_VideoCaptObj.VCOSetVideoSize( AInpSizeStr: string; out ANewSize: TPoint );
var
  i, NumCaps, CapsSize: integer;
  Str: string;
  GivenSize: TPoint;
  VSCC: TVideoStreamConfigCaps;
  PMediaType: PAMMediaType;
begin
  if VCOIError <> 0 then Exit; // a precaution

  ANewSize.X := -1; // error flag
  VCOIError := 70;
  VCOSError := 'VCOIStreamConfig = nil';
  if VCOIStreamConfig = nil then Exit; // a precaution

{ // for VFW
  VCOCoRes := VCOIStreamConfig.GetNumberOfCapabilities( NumCaps, CapsSize );
  if VCOCheckRes( 72 ) then Exit;
  if NumCaps = 0 then AInpSizeStr := '';
}

  if AInpSizeStr <> '' then // get Size from AInpSizeStr
  begin
    Str := AInpSizeStr;
    GivenSize.X := N_ScanInteger( Str );
    N_ScanToken( Str );
    GivenSize.Y := N_ScanInteger( Str );
  end else // AInpSizeStr = '', just get current Size and return it in ANewSize
  begin
    VCOCoRes := VCOIStreamConfig.GetFormat( PMediaType );
    if VCOCheckRes( 71 ) then Exit;

    with PMediaType^ do
    begin
      with PVideoInfoHeader(pbFormat)^ do
      begin
        ANewSize.X := bmiHeader.biWidth;
        ANewSize.Y := abs(bmiHeader.biHeight);
      end; // with PVideoInfoHeader(pbFormat)^ do
    end; // with PMediaType^ do

    N_DSDeleteMediaType( PMediaType ); // delete MediaType record allocated by DirectShow
    VCOIError := 0;
    VCOSError := '';
    Exit; // all done for AInpSizeStr = ''
  end; // else // AInpSizeStr = '', just get current Size and return it in ANewSize

  //*** Find Capability with GivenSize and set it

  VCOCoRes := VCOIStreamConfig.GetNumberOfCapabilities( NumCaps, CapsSize );
  if VCOCheckRes( 72 ) then Exit;

  VCODumpString( Format('VCO NumCaps=%d, GivenSize=%d,%d',
                                           [NumCaps,GivenSize.X,GivenSize.Y]) );

  for i := 0 to NumCaps-1 do // along all Stream capabilities
  begin
    VCOCoRes := VCOIStreamConfig.GetStreamCaps( i, PMediaType, VSCC ); // get i-th Capability
    if VCOCheckRes( 73 ) then Exit;

    with PMediaType^, PVideoInfoHeader(pbFormat)^.bmiHeader do
    begin
//      VCODumpString( Format( 'VCO CapsInd=%d, GivenSize=%d,%d', [i,biWidth,biHeight] ));

      if ( IsEqualGUID(VCONeededVideoCMST, NilGUID) or    // any subtype is OK
                                  IsEqualGUID(VCONeededVideoCMST, subtype) ) and
                 (biWidth = GivenSize.X) and (abs(biHeight) = GivenSize.Y ) then // GivenSize found,
      begin                                                             // set it and Exit
        VCOCurVideoCMST := SubType; // Current Video Capture Media SubType format
        VCOGetGraphState();

        if VCOGraphState = State_Running then
        begin
          N_i := VCOIMediaControl.Stop();
          N_i := VCOIStreamConfig.SetFormat( PMediaType^ );

          if VCORecordGraph then // "record to to file" mode, stop writing Stream if needed
            VCOControlStream( [csfCapture,csfStop] );
          VCOCoRes := VCOIMediaControl.Run();
          VCOGetGraphState();
        end else
          VCOCoRes := VCOIStreamConfig.SetFormat( PMediaType^ );

        N_DSDeleteMediaType( PMediaType ); // delete MediaType record allocated by DirectShow before possible Exit
        if VCOCheckRes( 74 ) then Exit; // Exit only after Deleting PMediaType!

        ANewSize := GivenSize;
        VCOIError := 0;
        VCOSError := '';
        Exit;
      end;  // if IsEqualGUID(subtype, MEDIASUBTYPE_RGB24) and ...
    end; // with PMediaType^, PVideoInfoHeader(pbFormat)^.bmiHeader do

    N_DSDeleteMediaType( PMediaType ); // delete MediaType record allocated by DirectShow
  end; // for i := 0 to NumCaps-1 do // along all capabilities

  VCOIError := 75; // needed size was not found in available Capabilities!
  VCOSError := 'Needed Size not found';
end; // procedure TN_VideoCaptObj.VCOSetVideoSize

//******************************************* TN_VideoCaptObj.VCOClearGraph ***
// Clear all Video Capturing Graph Filters and other objects
//
procedure TN_VideoCaptObj.VCOClearGraph();
begin
  VCOIVideoProcAmp      := nil;
  VCOIStreamConfig      := nil;
  VCOISampleGrabber     := nil;

  VCOIAudioComprFilter  := nil;
  VCOIVideoComprFilter  := nil;
  VCOIAudioCaptFilter   := nil;
  VCOIVideoCaptFilter   := nil;
  VCOISampleGrabFilter  := nil;

  VCOIVideoWindow       := nil;
  VCOIMediaControl      := nil;
  VCOISink              := nil;
  VCOIMux               := nil;
  VCOICaptGraphBuilder  := nil;
  VCOIGraphBuilder      := nil;

  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj.VCOClearGraph

//*************************************** TN_VideoCaptObj.VCOPrepInterfaces ***
// Prepare Interfaces, common for Recording Video and Grabbing Samples
//
// Prepare following objects (number in () is VCOIError):
//  (1) VCOIGraphBuilder
//  (2) VCOICaptGraphBuilder
//  (4) VCOIVideoCaptFilter
//  (6) VCOIVideoComprFilter
//
// (15) VCOIMediaControl
// (16) VCOIStreamConfig
// (17) VCOIVideoProcAmp
//
// VCOVCaptDevName is used for preparing VCOIVideoCaptFilter and should be already set
// VCOVComprSectionName is used for preparing VCOIVideoComprFilter and should be in Ini file
// Errors in range 01 - 17 are checked
//
procedure TN_VideoCaptObj.VCOPrepInterfaces();
var
  ErrCode: integer;
//  wrkIMoniker: IMoniker;
begin
  //***** Create VCOIGraphBuilder - Object for constructing Filter Graph
  VCOIGraphBuilder := nil;
  VCOCoRes := CoCreateInstance( CLSID_FilterGraph, nil, CLSCTX_INPROC_SERVER,
                                IID_IGraphBuilder, VCOIGraphBuilder );
  if VCOCheckRes( 1 ) then Exit; // This error means that DirectShow is not installed

  //***** Create VCOICaptGraphBuilder - Object for constructing Capturing Filter Graph
  VCOICaptGraphBuilder := nil;
  VCOCoRes := CoCreateInstance( CLSID_CaptureGraphBuilder2, nil, CLSCTX_INPROC_SERVER,
                              IID_ICaptureGraphBuilder2, VCOICaptGraphBuilder );
  if VCOCheckRes( 2 ) then Exit;

  //***** Initialize the Capture Graph Builder
  //      ( Specify GraphBuilder objetct for using in VCOICaptGraphBuilder )
  VCOCoRes := VCOICaptGraphBuilder.SetFiltergraph( VCOIGraphBuilder );
  if VCOCheckRes( 3 ) then Exit;

  //***** get needed VideoCapt Filter by VCOVCaptDevName (any Filter if VCOVCaptDevName = '')
  VCOIVideoCaptFilter := nil;
  VCOIVideoCaptFilter := N_DSEnumFilters( CLSID_VideoInputDeviceCategory,
                                          VCOVCaptDevName, nil, ErrCode );
  VCOIError := 4;
  if (VCOIVideoCaptFilter = nil) or (ErrCode <> 0) then Exit;

  //***** Add VideoCaptFilter to Filter Graph
  VCOCoRes := VCOIGraphBuilder.AddFilter( VCOIVideoCaptFilter,
                                                         'VideoCaptureFilter' );
  if VCOCheckRes( 5 ) then Exit;

  //***** get needed VideoCompressor Filter using Names in VCOVComprSectionName
  //      VCOIVideoComprFilter can be nil, it means using uncompressed Video
  VCOIVideoComprFilter := nil;
  VCOIVideoComprFilter := N_DSGetAnyFilter( CLSID_VideoCompressorCategory,
                                            VCOVComprSectionName, ErrCode, VCOVComprFiltName );
  if VCOIVideoComprFilter <> nil then // nil means using uncompressed Video
  begin
    VCOCoRes := VCOIGraphBuilder.AddFilter( VCOIVideoComprFilter,
                                                           'VideoComprFilter' );
    if VCOCheckRes( 6 ) then Exit;
  end; // if VCOIVideoComprFilter <> nil then

  //***** get VCOIMediaControl Interface for controlling media streams
  VCOIMediaControl := nil;
  VCOCoRes := VCOIGraphBuilder.QueryInterface( IID_IMediaControl,
                                                             VCOIMediaControl );
  if VCOCheckRes( 15 ) then Exit; // Errors 13, 14 not used now

  //***** get VCOIStreamConfig Interface to get/set Video Format and Size
  VCOIStreamConfig := nil;
//  N_Dump2Str( 'VCOCaptPin=' + IntToStr( VCOCaptPin ) );

  if VCOCaptPin = 1 then
    VCOCoRes := VCOICaptGraphBuilder.FindInterface( @PIN_CATEGORY_CAPTURE,
                                          @MEDIATYPE_Video, VCOIVideoCaptFilter,
                                         IID_IAMStreamConfig, VCOIStreamConfig )
  else
  begin
    VCOCoRes := VCOICaptGraphBuilder.FindInterface( @PIN_CATEGORY_PREVIEW,
                                          @MEDIATYPE_Video, VCOIVideoCaptFilter,
                                        IID_IAMStreamConfig, VCOIStreamConfig );
    if FAILED( VCOCoRes ) then
    begin
      VCOCoRes := VCOICaptGraphBuilder.FindInterface( @PIN_CATEGORY_CAPTURE,
                                          @MEDIATYPE_Video, VCOIVideoCaptFilter,
                                        IID_IAMStreamConfig, VCOIStreamConfig );
      N_Dump2Str( 'No PIN_CATEGORY_PREVIEW' );
    end;
  end;

  if VCOCheckRes( 16 ) then Exit;

  //***** get VCOIVideoProcAmp Interface to get/set Brightness, Contrast and so on
  VCOIVideoProcAmp := nil;
  VCOCoRes := VCOIVideoCaptFilter.QueryInterface( IID_IAMVideoProcAmp,
                                                             VCOIVideoProcAmp );
  if VCOCheckRes( 17 ) then Exit;

  //***** All Objects Ctreated OK
  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj.VCOPrepInterfaces

//*************************************** TN_VideoCaptObj.VCOConstructGraph ***
// Obsolete!, use VCOPrepRecordGraph or VCOPrepGrabGraph
//
// Finish Constructing Video Capturing Graph and
// run it with stopped Capture Stream.
//
// The following errors are checked (number in () is VCOIError):
// (20) VCOICaptGraphBuilder = nil
// (21) VCOICaptGraphBuilder.RenderStream
//
// (23) VCOICaptGraphBuilder.SetOutputFileName
// (24) VCOICaptGraphBuilder.RenderStream
// (25) VCOIMediaControl.Run
//
procedure TN_VideoCaptObj.VCOConstructGraph();
var
  WFileName: WideString;
begin
  VCOIError := 20;
  if VCOICaptGraphBuilder = nil then Exit;

{ // *** temporary excluded
  // Получение устройтва захвата звука
  VCOIAudioCaptFilter := EnumerateDevices(CLSID_AudioInputDeviceCategory,
    AudioCaptDeviceName, nil, TRUE);

  // Получение устройтва сжатия звука
  if AudioComprDeviceName <> '' then
  begin
    VCOIAudioComprFilter := EnumerateDevices(CLSID_AudioComprorCategory,
      AudioComprDeviceName, nil, TRUE);
  end;

  // Добавляем фильтр захвата звука в граф
  if VCOIAudioCaptFilter <> nil then
  begin
    VCOGraphBuilder.AddFilter(FAudioCaptFilter, 'AudioCaptureFilter');
  end;

  // Добавляем фильтр сжатия звука в граф
  if VCOAudioComprFilter <> nil then
  begin
    VCOGraphBuilder.AddFilter(FAudioComprFilter, 'AudioComprFilter');
  end;
} // *** temporary excluded


  //***** Create Graph for Preview Stream

  VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_PREVIEW,
                              @MEDIATYPE_Video, VCOIVideoCaptFilter, nil, nil );
  if VCOCheckRes( 21 ) then Exit;

  if VCOWindowHandle > 0 then // VCOWindowHandle is given
  begin
    // Запрашиваем интерфейс управления окном вывода изображения
    VCOIVideoWindow := nil;
    VCOIGraphBuilder.QueryInterface( IID_IVideoWindow, VCOIVideoWindow );

    if VCOIVideoWindow <> nil then
    begin
      // Устанавливаем стиль видео окна
      VCOIVideoWindow.put_WindowStyle( WS_CHILD or WS_CLIPSIBLINGS );

      // Устанавливаем родительское окно для вывода изображения
      VCOIVideoWindow.put_Owner( VCOWindowHandle );

      // Устанавливаем положение окна
      VCOIVideoWindow.SetWindowPosition( VCOCurWindowRect.Left,
                                         VCOCurWindowRect.Top,
                            VCOCurWindowRect.Right  - VCOCurWindowRect.Left + 1,
                           VCOCurWindowRect.Bottom - VCOCurWindowRect.Top + 1 );

      // Показываем окно вывода изображения
      VCOIVideoWindow.put_Visible( TRUE );
    end; // if VCOIVideoWindow <> nil then

{
    // ... выводим звук
    if VCOAudioCaptFilter <> nil then
    begin
      CoRes := VCOCaptGraphBuilder.RenderStream(@PIN_CATEGORY_PREVIEW, @MEDIATYPE_Audio,
        VCOAudioCaptFilter, nil, nil);
      if FAILED(CoRes) then Exit;
    end;
}
  end; // if VCOWindowHandle > 0 then // VCOWindowHandle is given

  if VCORecordGraph then // "record to to file" mode, add needed filters
  begin
    // Задаем файл для записи данных из графа

    WFileName := VCOFileNames[VCOFileNameInd];
    VCOFileNameInd := VCOFileNameInd xor 1;
    VCOIMux  := nil;
    VCOISink := nil;
    VCOCoRes := VCOICaptGraphBuilder.SetOutputFileName( MEDIASUBTYPE_Avi,
                                      PWideChar(WFileName), VCOIMux, VCOISink );
    if VCOCheckRes( 23 ) then Exit;

    //***** Create Graph for Capture Stream
    VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_CAPTURE,
         @MEDIATYPE_Video, VCOIVideoCaptFilter, VCOIVideoComprFilter, VCOIMux );

    if VCOCheckRes( 24 ) then Exit;
{
  pConfigMux: IConfigAviMux;

    // Устанавливаем режим захвата звука
    if VCOAudioCaptFilter <> nil then
    begin
      CoRes := VCOCaptGraphBuilder.RenderStream(@PIN_CATEGORY_CAPTURE, @MEDIATYPE_Audio,
       VCOAudioCaptFilter, VCOAudioComprFilter, VCOMux);
      if FAILED(CoRes) then Exit;

      // При захвате видео со звуком устанавливаем звуковой поток в
      // качестве основного для синхронизации с другими потоками в файле
      if VCOVideoCaptFilter <> nil then
      begin
        pConfigMux := nil;
        CoRes := VCOMux.QueryInterface(IID_IConfigAviMux, pConfigMux);
        if (SUCCEEDED(CoRes)) then
        begin
          pConfigMux.SetMasterStream(1);
          pConfigMux := nil;
        end;
      end;
    end;
}
  end; // if VCORecordGraph then // if "record to to file" mode

  if VCORecordGraph then // "record to to file" mode, stop writing Stream if needed
    VCOControlStream( [csfCapture,csfStop] ); // Stop Capture Stream

  if VCOIError > 0 then Exit;

  // Запускаем граф
  VCOCoRes := VCOIMediaControl.Run();
  if VCOCheckRes( 25 ) then Exit;

  VCOIError := 0;
end; // procedure TN_VideoCaptObj.VCOConstructGraph

//************************************** TN_VideoCaptObj.VCOPrepVideoWindow ***
// Prepapre and Show VideoWindow
//
procedure TN_VideoCaptObj.VCOPrepVideoWindow();
begin
  if VCOWindowHandle > 0 then // VCOWindowHandle is given
  begin
    // Запрашиваем интерфейс управления окном вывода изображения
    VCOIVideoWindow := nil;
    VCOIGraphBuilder.QueryInterface( IID_IVideoWindow, VCOIVideoWindow );

    if VCOIVideoWindow <> nil then
    begin
      // Устанавливаем стиль видео окна
      VCOIVideoWindow.put_WindowStyle( WS_CHILD or WS_CLIPSIBLINGS );

      // Устанавливаем родительское окно для вывода изображения
      VCOIVideoWindow.put_Owner( VCOWindowHandle );

      // Устанавливаем положение окна
      VCOIVideoWindow.SetWindowPosition( VCOCurWindowRect.Left,
                                         VCOCurWindowRect.Top,
                            VCOCurWindowRect.Right  - VCOCurWindowRect.Left + 1,
                           VCOCurWindowRect.Bottom - VCOCurWindowRect.Top + 1 );
                                         
//      VCOIVideoWindow.SetWindowPosition( VCOCurWindowRect.Left,
//                                         VCOCurWindowRect.Top, 500, 200 );


      // Показываем окно вывода изображения
      VCOIVideoWindow.put_Visible( TRUE );
    end; // if VCOIVideoWindow <> nil then
  end; // if VCOWindowHandle > 0 then // VCOWindowHandle is given

  //***** No errors were checked
  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj.VCOPrepVideoWindow

//************************************** TN_VideoCaptObj.VCOPrepRecordGraph ***
// Prepapre and Run Video Capturing Graph for Recording Videos
//
procedure TN_VideoCaptObj.VCOPrepRecordGraph();
var
  WFileName: WideString;
begin
  VCORecordGraph := True;
  VCOGrabGraph   := False;

  if VCOICaptGraphBuilder = nil then
    VCOPrepInterfaces();

  if VCOIError <> 0 then Exit;

  //***** Create Preview Stream Graph fragment
  VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_PREVIEW,
                              @MEDIATYPE_Video, VCOIVideoCaptFilter, nil, nil );
  if VCOCheckRes( 21 ) then Exit;

  VCOPrepVideoWindow(); // no errors checked inside

  // Set File Name for next recording
  WFileName := VCOFileNames[VCOFileNameInd];
  VCOFileNameInd := VCOFileNameInd xor 1;
  VCOIMux  := nil;
  VCOISink := nil;
  VCOCoRes := VCOICaptGraphBuilder.SetOutputFileName( MEDIASUBTYPE_Avi,
                                      PWideChar(WFileName), VCOIMux, VCOISink );
  if VCOCheckRes( 23 ) then Exit;

  //***** Create Capture Stream Graph fragment
  VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_CAPTURE,
         @MEDIATYPE_Video, VCOIVideoCaptFilter, VCOIVideoComprFilter, VCOIMux );
  if VCOCheckRes( 24 ) then Exit;

  //*** Do not start Capture Stream when Graph would Run
  VCOControlStream( [csfCapture,csfStop] );
  if VCOIError > 0 then Exit;

  //*** Run Graph, Capture Stream would not Start
  VCOCoRes := VCOIMediaControl.Run();

  //***** RecordGraph Created OK and now in Run state
  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj.VCOPrepRecordGraph

//**************************************** TN_VideoCaptObj.VCOPrepGrabGraph ***
// Prepapre and Run Video Capturing Graph for Grabbing Samples
//
// (30) VCOISampleGrabFilter
// (31) VCOISampleGrabber
// (32) add VCOISampleGrabFilter to Graph
// (33) VCOISampleGrabber.SetMediaType
// (34) VCOISampleGrabber.SetBufferSamples
// (35) VCOISampleGrabber.SetOneShot
// (37) VCOIMediaControl.Run
//
// Additions by Mihail:
// (555) Asking for a Null Renderer
// (556) Addition of the Null Renderer to the Graph
// (557) Build of Preview Branch inside the Graph
// (558) Build of Capture Branch inside the Graph
//
procedure TN_VideoCaptObj.VCOPrepGrabGraph();
var
  MediaType: TAMMediaType;
begin
  VCORecordGraph := False;
  VCOGrabGraph   := True;

  // Create Sample Grabber Filter
  VCOISampleGrabFilter := nil;
  VCONullRendererFilter := nil;
  VCOCoRes := CoCreateInstance( CLSID_SampleGrabber, NIL, CLSCTX_INPROC_SERVER,
                                        IID_IBaseFilter, VCOISampleGrabFilter );
  if VCOCheckRes( 30 ) then Exit;
  // get ISampleGrabber Interface
  VCOISampleGrabber := nil;
  VCOCoRes := VCOISampleGrabFilter.QueryInterface( IID_ISampleGrabber,
                                                            VCOISampleGrabber );
  if VCOCheckRes( 31 ) or (VCOISampleGrabber = nil) then Exit;

  // add VCOISampleGrabFilter to Filter Graph
  VCOCoRes := VCOIGraphBuilder.AddFilter( VCOISampleGrabFilter,
                                                             'Sample Grabber' );
  if VCOCheckRes( 32 ) then Exit;

  // Get and Add Null Renderer Filter (to discard frames which passed SampleGrabber)
  VCOCoRes := CoCreateInstance( CLSID_NullRenderer, NIL, CLSCTX_INPROC_SERVER,
                                IID_IBaseFilter, VCONullRendererFilter );
  if VCOCheckRes( 555 ) then Exit;
  VCOCoRes := VCOIGraphBuilder.AddFilter( VCONullRendererFilter,
                                                              'Null Renderer' );
  if VCOCheckRes( 556 ) then Exit;


  //*** Set Data Format for VCOISampleGrabber

  ZeroMemory( @MediaType, sizeof(TAMMediaType) );

  with MediaType do
  begin
    majortype  := MEDIATYPE_Video;
    subtype    := MEDIASUBTYPE_RGB24;
    formattype := FORMAT_VideoInfo;
  end; // with MediaType do

  VCOCoRes := VCOISampleGrabber.SetMediaType( MediaType );
  if VCOCheckRes( 33 ) then Exit;

  // Set buffering (not callback) mode for ISampleGrabber
  VCOCoRes := VCOISampleGrabber.SetBufferSamples( TRUE );
  if VCOCheckRes( 34 ) then Exit;

  // Do not stop Graph on grbbing first Sample
  VCOCoRes := VCOISampleGrabber.SetOneShot( FALSE );
  if VCOCheckRes( 35 ) then Exit;

  //***** Create Structure of the Graph
  //      Smart Tee inserted by Intellegent Connect automatically if needed
  //      Preview branch - connected to the Default Video Renderer (last parameter is nil)

  VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_PREVIEW,
                              @MEDIATYPE_Video, VCOIVideoCaptFilter, nil, nil );
  if VCOCheckRes( 557 ) then Exit;
  // Capture branch - connected to the Null Video Renderer
  VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_CAPTURE,
                    @MEDIATYPE_Video, VCOIVideoCaptFilter, VCOISampleGrabFilter,
                                                        VCONullRendererFilter );
  if VCOCheckRes( 558 ) then Exit;

  VCOPrepVideoWindow(); // no errors checked inside

  //*** Run Graph
  VCOCoRes := VCOIMediaControl.Run();

  //***** GrabGraph Created OK and now in Run state
  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj.VCOPrepGrabGraph

//*************************************** TN_VideoCaptObj.VCOStartRecording ***
// Start Recording Video
//
procedure TN_VideoCaptObj.VCOStartRecording();
begin
  VCOIError := 80;
  VCOSError := 'Not a RecordGraph!';
  if not VCORecordGraph then Exit; // a precaution

  VCOControlStream( [csfCapture,csfStart] ); // Start Capture Stream
  if VCOIError <> 0 then Exit;

  //***** Recording Started OK
  VCONowRecording := True;
  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj.VCOStartRecording

//**************************************** TN_VideoCaptObj.VCOStopRecording ***
// Stop Recording Video
//
//     Parameters
// Result - Return Recorded File Name
//
function TN_VideoCaptObj.VCOStopRecording(): string;
var
  WFileName: WideString;
begin
  Result := '';

  VCOIError := 83;
  VCOSError := 'Not a RecordGraph!';
  if not VCORecordGraph then Exit; // a precaution

  VCOIError := 84;
  VCOSError := 'Now not Recording!';
  if not VCONowRecording then Exit; // a precaution

  VCOCoRes := VCOIMediaControl.Stop(); // stop Graph to be able to change FileName
  if VCOCheckRes( 85 ) then Exit;

  WFileName := VCOFileNames[VCOFileNameInd]; // just recorded File
  VCOFileNameInd := VCOFileNameInd xor 1; // Name for next recording
  VCOCoRes := VCOISink.SetFileName( PWideChar(WFileName), nil ); // change current File
  if VCOCheckRes( 86 ) then Exit;

  //*** Do not start Capture Stream when Graph would Run
  VCOControlStream( [csfCapture,csfStop] );
  if VCOIError <> 0 then Exit;

  //*** Run Graph again to see video preview, Capture Stream would not Start
  VCOCoRes := VCOIMediaControl.Run(); // Run Graph again to see video preview
  if VCOCheckRes( 87 ) then Exit;

  //***** Resulting avi File is OK
  Result := WFileName;
  VCONowRecording := False;
  VCOIError := 0;
  VCOSError := '';
end; // function TN_VideoCaptObj.VCOStopRecording

//******************************************* TN_VideoCaptObj.VCOGrabSample ***
// Grab current Sample
//
//     Parameters
// Result - Return Grabbed Sample as DIB Object
//
function TN_VideoCaptObj.VCOGrabSample(): TN_DIBObj;
var
  BitsBufSize: integer;
  PDIB: TN_PDIBInfo;
  MediaType: TAMMediaType;
begin
  Result := nil;
  VCOIError := 60;
  VCOSError := 'VCOISampleGrabber = nil';
  if VCOISampleGrabber = nil then Exit; // a precaution

  //*** Get DIB Info and create empty DIB obj using it

  ZeroMemory( @MediaType, sizeof(TAMMediaType) );
  VCOCoRes := VCOISampleGrabber.GetConnectedMediaType( MediaType );
  if VCOCheckRes( 61 ) then Exit;

  PDIB := TN_PDIBInfo( @(PVideoInfoHeader(MediaType.pbFormat)^.bmiHeader) );

  if Assigned(N_BinaryDumpProcObj) then // Save DIBInfo dump for debug
    N_BinaryDumpProcObj( 'VCOGrab1', PDIB, PDIB^.bmi.biSize );

  Result := TN_DIBObj.Create();
  Result.PrepEmptyDIBObj( PDIB );

  //*** Get DIB Content (Sample bits) in

  BitsBufSize := Result.DIBInfo.bmi.biSizeImage;

  //*** Get BufSize for Sample content for debug
  N_i := 0;
  VCOCoRes := VCOISampleGrabber.GetCurrentBuffer( N_i, nil );
  if (N_i <= 0) or VCOCheckRes( 62 ) then Exit;

  N_i := VCOISampleGrabber.GetCurrentBuffer( BitsBufSize, Result.PRasterBytes );

  if Assigned(N_BinaryDumpProcObj) then // Save RasterBytes dump for debug
    N_BinaryDumpProcObj( 'VCOGrab2', Result.PRasterBytes,
                                                        PDIB^.bmi.biSizeImage );

  //***** All Objects Ctreated OK
  VCOIError := 0;
  VCOSError := '';
end; // function TN_VideoCaptObj.VCOGrabSample

//************************************* TN_VideoCaptObj.VCOShowFilterDialog ***
// Show given Filter Properties Dialog, provided by installed Driver
//
//     Parameters
// AIFilter      - given Filter (or Pin)
// AWindowHandle - any Windows Window Handle (Dialog Owner?)
//
procedure TN_VideoCaptObj.VCOShowFilterDialog( AIFilter: IBaseFilter;
                                                       AWindowHandle: THandle );
var
  CoRes: HResult;
  WindowCaption: WideString;
  PropertyPages: ISpecifyPropertyPages;
  Pages: CAUUID;
  FilterInfo: TFilterInfo;
  pfilterUnk: IUnknown;
begin
  VCOIError := 40;
  if AIFilter = nil then Exit;

  // Пытаемся найти интерфейс управления страницами свойств фильтра
  CoRes := AIFilter.QueryInterface( ISpecifyPropertyPages, PropertyPages );

  VCOIError := 41;
  if FAILED(CoRes) then Exit;

  //*** PropertyPages Interface exists
  // Получение имени фильтра и указателя на интерфейс IUnknown

  AIFilter.QueryFilterInfo( FilterInfo );
  AIFilter.QueryInterface( IUnknown, pfilterUnk );

  // Получаем массив страниц свойств
  PropertyPages.GetPages( Pages );
  PropertyPages := nil;

  // Отображаем страницу свойств в виде модального диалога
  WindowCaption := VCOVCaptDevName + ' (2)'; // 'Properties' token will be added!
  OleCreatePropertyFrame( AWindowHandle, 0, 0, PWideChar(WindowCaption), 1,
                           @pfilterUnk, Pages.cElems, Pages.pElems, 0, 0, nil );

  // Освобождаем память
  pfilterUnk := nil;
  FilterInfo.pGraph := nil;

  CoTaskMemFree( Pages.pElems );
  VCOIError := 0;
end; // procedure TN_VideoCaptObj.VCOShowFilterDialog

//************************************* TN_VideoCaptObj.VCOShowStreamDialog ***
// Show StreamConfig Properties Dialog, provided by installed Driver
//
//     Parameters
// AWindowHandle - any Windows Window Handle (Dialog Owner?)
//
procedure TN_VideoCaptObj.VCOShowStreamDialog( AWindowHandle: THandle );
var
  CoRes: HResult;
  WindowCaption: WideString;
  StreamConfig: IAMStreamConfig;
  PropertyPages: ISpecifyPropertyPages;
  Pages: CAUUID;
begin
  VCOIError := 44;
  if VCOIVideoCaptFilter = nil then Exit;

  VCOIMediaControl.Stop(); // Останавливаем работу графа

  try
    // Ищем интерфейс управления форматом данных выходного потока
    CoRes := VCOICaptGraphBuilder.FindInterface( @PIN_CATEGORY_CAPTURE,
      @MEDIATYPE_Video, VCOIVideoCaptFilter, IID_IAMStreamConfig,
                                                                 StreamConfig );

    if SUCCEEDED(CoRes) then // Interface StreamConfig found
    begin
      // ... пытаемся найти интерфейс управления страницами свойств ...
      CoRes := StreamConfig.QueryInterface( ISpecifyPropertyPages,
                                                                PropertyPages );

      // ... и, если он найден, то ...
      if SUCCEEDED(CoRes) then // Interface PropertyPages found
      begin
        // ... получаем массив страниц свойств
        PropertyPages.GetPages( Pages );
        PropertyPages := nil;

        // Отображаем страницу свойств в виде модального диалога
        WindowCaption := VCOVCaptDevName + ' (1)'; // 'Properties' token will be added!
        OleCreatePropertyFrame( AWindowHandle, 0, 0, PWideChar(WindowCaption),
                      1, @StreamConfig, Pages.cElems, Pages.pElems, 0, 0, nil );

        // Освобождаем память
        StreamConfig := nil;
        CoTaskMemFree( Pages.pElems );
      end; // if SUCCEEDED(CoRes) then // Interface PropertyPages found
    end; // if SUCCEEDED(CoRes) then // Interface StreamConfig found

  finally
    // Восстанавливаем работу графа
    VCOIMediaControl.Run;
  end;

  VCOIError := 0;
end; // procedure TN_VideoCaptObj.VCOShowStreamDialog

//**************************************** TN_VideoCaptObj.VCOControlStream ***
// Control Capture or Preview Stream
//
//     Parameters
// AFlags - Control Stream Flags (csfPreview, csfCapture, csfStart, csfStop)
//
procedure TN_VideoCaptObj.VCOControlStream( AFlags: TN_ControlStreamFlags );
var
 pCategory: PGUID;
 tStart, tStop: TReferenceTime;
begin
  if csfPreview in AFlags then
    pCategory := @PIN_CATEGORY_PREVIEW
  else if csfCapture in AFlags then
    pCategory := @PIN_CATEGORY_CAPTURE
  else
    pCategory := nil;

  if csfStart in AFlags then
  begin
    tStart := 0;
    tStop  := MAXLONGLONG;
  end else // csfStop
  begin
    tStart := MAXLONGLONG;
    tStop  := 0;
  end;

  VCOCoRes := VCOICaptGraphBuilder.ControlStream( pCategory, @MEDIATYPE_Video,
                               VCOIVideoCaptFilter, @tStart, @tStop, 123, 124 );
  if VCOCheckRes( 50 ) then Exit;

  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj.VCOControlStream


//*************************  Global Procedures  ***************

//******************************************************* N_DSFreeMediaType ***
// Free Objects in given AMMediaType record, created inside DirectShow
//
//     Parameters
// APMediaType - Pointer to given AMMediaType record
//
procedure N_DSFreeMediaType( APMediaType: PAMMediaType );
begin
  CoTaskMemFree( APMediaType^.pbFormat );

  if APMediaType^.pUnk <> nil then
  begin
    APMediaType^.pUnk._Release();
    APMediaType^.pUnk := nil;
  end;
end; // procedure N_DSFreeMediaType

//***************************************************** N_DSDeleteMediaType ***
// Delete given AMMediaType record, created inside DirectShow
//
//     Parameters
// APMediaType - Pointer to given AMMediaType record
//
procedure N_DSDeleteMediaType( APMediaType: PAMMediaType );
begin
  N_DSFreeMediaType( APMediaType );
  CoTaskMemFree( APMediaType );
end; // procedure N_DSDeleteMediaType

//******************************************************* N_GetDSErrorDescr ***
// Convert given ACoRes into string
//
//     Parameters
// ACoRes - given HResult
// Result - Return string with description of given ACoRes
//
function N_GetDSErrorDescr( ACoRes: HResult ): string;
var
  IRes: integer;
begin
  SetLength( Result, 200 );
  IRes := AMGetErrorText( ACoRes, PChar(Result), Length(Result) );
  if IRes = 0 then // error in AMGetErrorText
    Result := Format( 'Unknown DirectShow Error! CoRes=%X', [ACoRes] )
  else
    SetLength( Result, IRes );
end; // function N_GetDSErrorDescr

//********************************************************* N_DSEnumFilters ***
// Enumerate or find needed DirectShow Filter
//
//     Parameters
// clsidDeviceClass - needed Filters (Devices) Class
// DevName          - Filter (Device) Name or '' if not needed
// DevList          - Filters (Devices) Names List if given or nil
// AErrCode         - own integer Error code (1,2) or 0 if OK
// Result           - Return Found Filter (device) or
//                    nil if (DevName = '') and (DevList <> nil)
//
// If (DevName <> '') and (DevList = nil)  - find and return needed Filter (Device)
// If (DevName = '')  and (DevList <> nil) - collect Filter Frendly Names in DevList
// If (DevName = '')  and (DevList = nil)  - return first available Filter (Device)
//
function N_DSEnumFilters( const clsidDeviceClass: TGUID; ADevName: string;
                  ADevNamesList: TStrings; out AErrCode: integer ): IBaseFilter;
var
  hr:           HResult;
  DeviceNameObj:  OleVariant;
  pMoniker:     IMoniker;
  pFilter:      IBaseFilter;
  PropertyName: IPropertyBag;
  pDevEnum:     ICreateDevEnum;
  pEnum:        IEnumMoniker;
      pbc:          IBindCtx;
  Label SomeError;

  procedure FreeObjects(); // local
  // free all temporary objects
  begin
    DeviceNameObj := UnAssigned();

    pMoniker     := nil;
    pFilter      := nil;
    PropertyName := nil;
    pDevEnum     := nil;
    pEnum        := nil;
  end; // procedure FreeObjects(); // local

begin
  FreeObjects();
  Result   := nil;
  AErrCode := 0;
  if ADevNamesList <> nil then ADevNamesList.Clear;

  // Создаем объект для перечисления устройств
  hr := CoCreateInstance( CLSID_SystemDeviceEnum, nil, CLSCTX_INPROC_SERVER,
                                                 IID_ICreateDevEnum, pDevEnum );
  AErrCode := 1; // CoCreateInstance(CLSID_SystemDeviceEnum, ... failed
  if FAILED(hr) then goto SomeError;

  // Создаем перечислитель для указанной категории устройств
  hr := pDevEnum.CreateClassEnumerator( clsidDeviceClass, pEnum, 0 );
  AErrCode := 2; // CreateClassEnumerator(clsidDeviceClass, ... failed
  if FAILED(hr) then goto SomeError;

  AErrCode := 0;

  if pEnum = nil then // no needed devices
  begin
    FreeObjects();
    Exit;
  end; // if pEnum = nil then // no needed devices

  while (S_OK = pEnum.Next(1, pMoniker, nil)) do // Цикл по устройствам
  begin
    // Если нам нужен список устройств, то ...
    if ADevNamesList <> nil then
    begin
      // ... получаем интерфейс хранилища, которое содержит объект,
      // идентифицируемый моникером
      hr := pMoniker.BindToStorage( nil, nil, IPropertyBag, PropertyName );
      if FAILED(hr) then Continue;

      // Читаем значение свойства
      hr := PropertyName.Read( 'FriendlyName', DeviceNameObj, nil );
      if FAILED(hr) then Continue;

      // Добавляем название устройства в наш список
      ADevNamesList.Add( DeviceNameObj );
    end else // ADevNamesList = nil
    begin
      // Если указано имя устройства, то ...
      if ADevName <> '' then // ADevName is given
      begin
        // ... получаем интерфейс хранилища, которое содержит объект,
        // идентифицируемый моникером
        hr := pMoniker.BindToStorage( nil, nil, IPropertyBag, PropertyName );
        if FAILED(hr) then Continue;

        // Читаем значение свойства
        hr := PropertyName.Read( 'FriendlyName', DeviceNameObj, nil );
        if FAILED(hr) then Continue;

        // Продолжаем поиск, если не совпадают имена устройств
        if (DeviceNameObj <> ADevName) then Continue;
      end; // if ADevName <> '' then // ADevName is given

      // Используя моникер связываемся с объектом, который он
      // идентифицирует, и получаем нужный нам интерфейс

 //***** not needed Nil may be used instead of pbc
      pbc := nil;
      hr := CreateBindCtx( 0, pbc );
      N_s := N_GetDSErrorDescr( hr );
      hr := pMoniker.BindToObject( pbc, nil, IID_IBaseFilter, pFilter );

//      hr := pMoniker.BindToObject( nil, nil, IID_IBaseFilter, pFilter );

      if SUCCEEDED(hr) then // pFilter is OK
      begin
        // Результат - полученный интерфейс
        Result := pFilter;
        FreeObjects();
        Exit;
      end; // if SUCCEEDED(hr) then // pFilter is OK
    end; // else // DevList = nil
  end; // while (S_OK = pEnum.Next(1, pMoniker, nil)) do

  FreeObjects();
  Exit;

  SomeError: //****************
  N_DSErrorString := N_GetDSErrorDescr( hr );
  FreeObjects();
end; // function N_DSEnumFilters

//******************************************************** N_DSGetAnyFilter ***
// Get needed DirectShow Filter using Filter Names in MemIni file
//
//     Parameters
// clsidDeviceClass - needed Filters (Devices) Class
// ASectionName     - MemIni Section Name with needed Filters (Devices) Names
// AErrCode         - own integer Error code (1-5) or 0 if OK
// Result           - Return Found Filter (device) or nil if not found
//
// Needed Filters (Devices) Names in MemIni Section are Value Parts of
// Section elements with unique Name Parts (Name Part can be any token)
// First availible Filter is returned
//
function N_DSGetAnyFilter( const clsidDeviceClass: TGUID; ASectionName: string;
                           out AErrCode: integer; out AFilterName: string ): IBaseFilter;
var
  i: integer;
  AvailableNames, NeededNames: TStringList;
  Label Fin;
begin
  AvailableNames := TStringList.Create;
  NeededNames    := TStringList.Create;

  Result := nil;
  N_DSEnumFilters( clsidDeviceClass, '', AvailableNames, AErrCode );
  AFilterName := N_NotUsedStr;
  if AErrCode > 0 then Exit;

  N_MemIniToStrings( ASectionName, NeededNames ); // retrive NeededNames

  for i := 0 to NeededNames.Count-1 do // along all NeededNames
  begin
    if NeededNames[i] = N_NotUsedStr then goto Fin; // needed Result is nil

    if AvailableNames.IndexOf( NeededNames[i] ) >= 0 then // NeededNames[i] is available
    begin
      Result := N_DSEnumFilters( clsidDeviceClass, NeededNames[i], nil, AErrCode );
      if (AErrCode > 0) or (Result = nil) then Continue; // a precaution

      AFilterName := NeededNames[i];
      N_Dump2Str('Compression filter at the moment: ' + AFilterName);
      goto Fin;
    end;
  end; // for i := 0 to NeededNames.Count-1 do // along all NeededNames

  //***** Here: all Needed Names are not available!

  Result := nil;
  AErrCode := 5;

  Fin: //***********************
  NeededNames.Free;
  AvailableNames.Free;
end; // function N_DSGetAnyFilter

//****************************************** N_GetVideoFileInfoFromMediaDet ***
// main function that gets Info about video file with given AFName into given
// APVFInfo record, chooses which method is to use
//
//     Parameters
// AFName     - given video File Name
// APVFInfo   - pointer to TN_VideoFileInfo record with input and output params
//              (on output it contains collected Info)
// Result     - Return 0 if OK or > 0 if error
//
function N_GetVideoFileInfo( AFName: string;
                                         APVFInfo: TN_PVideoFileInfo ): integer;
var
  WrkString: string;
begin
  WrkString := N_MemIniToString( 'CMS_UserDeb', 'VideoInfoMode', '0' ); // get info using imediadet or samplegrabber
    if WrkString = '1' then // grabber first
    begin
      Result := N_GetVideoFileInfoFromSampleGrabber( AFName, APVFInfo );
      if Result > 0 then
        Result := N_GetVideoFileInfoFromMediaDet( AFName, APVFInfo );
    end
    else // mediadet first
    begin
      Result := N_GetVideoFileInfoFromMediaDet( AFName, APVFInfo );
      if Result > 0 then
        Result := N_GetVideoFileInfoFromSampleGrabber( AFName, APVFInfo );
    end;

  N_Dump1Str('Result after GetInfo = ' + IntToStr(Result));
  if Result <> 0 then
  begin
    N_Dump1Str( format( 'VideoFileInfo ErrCode=%d %s ErrCode=%d ErrInfo=%s',
                   [Result, AFName, APVFInfo.VFIIError, APVFInfo.VFISError] ) );
    // Exit; // not just exit anymore

    //K_CMShowMessageDlg1(
    //format( 'File %s has some problems with retrieving an information about it',
    //                                                    [AFName] ), mtWarning );
    APVFInfo.VFIFrameWidth := 0;
    APVFInfo.VFIFrameHeight := 0;
    APVFInfo.VFIFileSize := 0;
    APVFInfo.VFIDuration := 0;
    Result := 0;
  end;
end; // function N_GetVideoFileInfo

//****************************************** N_GetVideoFileInfoFromMediaDet ***
// Get Info about video file with given AFName into given APVFInfo record using MediaDet
//
//     Parameters
// AFName     - given video File Name
// APVFInfo   - pointer to TN_VideoFileInfo record with input and output params
//              (on output it contains collected Info)
// Result     - Return 0 if OK or > 0 if error
//
function N_GetVideoFileInfoFromMediaDet( AFName: string;
                                         APVFInfo: TN_PVideoFileInfo ): integer;
var
  i, BufSize: integer;
  VLengthSec, DIBTime: double;
  FName: string;
  major_type: TGUID;
  MediaType: TAMMediaType;
  wIMediaDet: IMediaDet;
  Buf: TN_BArray;
  Label Found, Fin;
begin
  Result := 1; // APVFInfo not given
  if APVFInfo = nil then Exit; // a precaution

  with APVFInfo^ do
  begin

  FName := K_ExpandFileName( AFName );
  if not FileExists( FName ) then
  begin
    Result := 2; // File not found
    VFISError := 'File not found "' + AFName + '"';
    goto Fin;
  end;

  VFIFramesRate  := 0;
  VFIFrameWidth  := 0;
  VFIFrameHeight := 0;
  VFIBitRate     := 0;

  VFIFileSize := N_GetFileSize( FName );

  //***** Create wIMediaDet Interface
  VFICoRes := CoCreateInstance( CLSID_MediaDet, nil, CLSCTX_INPROC_SERVER,
                                                    IID_IMediaDet, wIMediaDet );
  Result := 3;
  VFISError := N_GetDSErrorDescr( VFICoRes );
  if FAILED(VFICoRes) then goto Fin;

  VFICoRes := wIMediaDet.put_Filename( FName ); // set File to examine
  Result := 4;
  VFISError := N_GetDSErrorDescr( VFICoRes );
  if FAILED(VFICoRes) then goto Fin;

  //***** Find video stream (first available)

  VFICoRes := wIMediaDet.get_OutputStreams( VFINumStreams );
  Result := 5;
  VFISError := N_GetDSErrorDescr( VFICoRes );
  if FAILED(VFICoRes) then goto Fin;

  SetLength( VFIStreamsInfo, 3*VFINumStreams );

  for i := 0 to VFINumStreams-1 do // along all streams in File, show general info
  begin
    VFICoRes := wIMediaDet.put_CurrentStream( i );
    Result := 6;
    VFISError := N_GetDSErrorDescr( VFICoRes );
    if FAILED(VFICoRes) then goto Fin;

    VFICoRes := wIMediaDet.get_StreamMediaType( MediaType );
    Result := 7;
    VFISError := N_GetDSErrorDescr( VFICoRes );
    if FAILED(VFICoRes) then
    begin
      N_DSFreeMediaType( @MediaType ); // clear MediaType member objects
      goto Fin;
    end;

    //***** Сollect only general info about i-th stream.
    //      may be it should be should be extended?

    VFIStreamsInfo[3*i+0] := N_GetGUIDName( MediaType.majortype );
    VFIStreamsInfo[3*i+1] := N_GetGUIDName( MediaType.subtype );
    VFIStreamsInfo[3*i+2] := N_GetGUIDName( MediaType.formattype );

    N_DSFreeMediaType( @MediaType ); // clear MediaType member objects
  end; // for i := 0 to NumStreams-1 do // along all streams in File, show general info

  VFIVideoStreamInd := -1; // as if not found

  for i := 0 to VFINumStreams-1 do // along all streams in File, look for first VideoStream
  begin
    N_i := wIMediaDet.put_CurrentStream( i );
    major_type.D1 := 0; // to be sure that major_type is set by get_StreamType
    N_i := wIMediaDet.get_StreamType( major_type );

    if IsEqualGUID( major_type, MEDIATYPE_Video ) then // video stream Found
    begin
      VFIVideoStreamInd := i;
      goto Found;
    end;
  end; // for i := 0 to NumStreams-1 do // along all streams in File, look for first VideoStream

  Result := 8;
  VFISError := 'No video stream found!';
  goto Fin;

  Found: //****** Here: current Stream is VideoStream, analize it
  VFICoRes := wIMediaDet.get_StreamLength( VLengthSec ); // Video duration in Seconds
  Result := 10;
  VFISError := N_GetDSErrorDescr( VFICoRes );
  if FAILED(VFICoRes) then goto Fin;
  VFIDuration := VLengthSec;

  VFICoRes := wIMediaDet.get_StreamMediaType( MediaType );
  Result := 11;
  VFISError := N_GetDSErrorDescr( VFICoRes );
  if FAILED(VFICoRes) then goto Fin;

  VFIFixedSizeSamples    := integer(MediaType.bFixedSizeSamples);
  VFITemporalCompression := integer(MediaType.bTemporalCompression);

  if IsEqualGUID( MediaType.formattype, FORMAT_None ) then
  begin
    VFIMediaFormat := 'FORMAT_None';
  end else if IsEqualGUID( MediaType.formattype, FORMAT_VideoInfo ) then
  begin
    VFIMediaFormat := 'FORMAT_VideoInfo';

    // Remark: for cool.avi and some *.wmv files MediaType.cbFormat = 1112 or 1128, why?
    //         ( sizeof(VIDEOINFOHEADER)=88, sizeof(VIDEOINFOHEADER2)=112 )
    // so, i use ">=" instead of "=" in next statement (and it works!)

    if MediaType.cbFormat >= sizeof(VIDEOINFOHEADER) then
    with PVideoInfoHeader(MediaType.pbFormat)^ do
    begin
      if AvgTimePerFrame = 0 then
        VFIFramesRate := 0
      else // AvgTimePerFrame > 0
        VFIFramesRate  := 1.0e7 / AvgTimePerFrame; // Frames per Second

      VFIFrameWidth  := bmiHeader.biWidth;
      VFIFrameHeight := abs(bmiHeader.biHeight);
      VFIBitRate     := Integer(dwBitRate); //???
    end;
  end else if IsEqualGUID( MediaType.formattype, FORMAT_VideoInfo2 ) then
  begin
    VFIMediaFormat := 'FORMAT_VideoInfo2';
    if MediaType.cbFormat >= sizeof(VIDEOINFOHEADER2) then
    with PVideoInfoHeader2(MediaType.pbFormat)^ do
    begin
      if AvgTimePerFrame = 0 then
        VFIFramesRate := 0
      else // AvgTimePerFrame > 0
        VFIFramesRate  := 1.0e7 / AvgTimePerFrame; // Frames per Second

      VFIFrameWidth  := bmiHeader.biWidth;
      VFIFrameHeight := abs(bmiHeader.biHeight);
      VFIBitRate     := Integer(dwBitRate); //???
    end;
  end else if IsEqualGUID( MediaType.formattype, FORMAT_WaveFormatEx ) then
  begin
    VFIMediaFormat := 'FORMAT_WaveFormatEx';
    // for Audio data only
  end else if IsEqualGUID( MediaType.formattype, FORMAT_MPEGVideo ) then
  begin
    VFIMediaFormat := 'FORMAT_MPEGVideo';
    if MediaType.cbFormat = sizeof(MPEG1VIDEOINFO) then
    with PMPEG1VIDEOINFO(MediaType.pbFormat)^.hdr do
    begin
      if AvgTimePerFrame = 0 then
        VFIFramesRate := 0
      else // AvgTimePerFrame > 0
        VFIFramesRate  := 1.0e7 / AvgTimePerFrame; // Frames per Second

      VFIFrameWidth  := bmiHeader.biWidth;
      VFIFrameHeight := abs(bmiHeader.biHeight);
      VFIBitRate     := dwBitRate;
    end;
  end else if IsEqualGUID( MediaType.formattype, FORMAT_MPEGStreams ) then
  begin
    VFIMediaFormat := 'FORMAT_MPEGStreams';
  end else if IsEqualGUID( MediaType.formattype, FORMAT_DvInfo ) then
  begin
    VFIMediaFormat := 'FORMAT_DvInfo';
    // Digital Video Stream
  end else // Unknown Format
  begin
    VFIMediaFormat := GUIDToString( MediaType.formattype );
  end;

  N_DSFreeMediaType( @MediaType ); // clear MediaType member objects

  SetLength( VFIDIBsArray, VFINumDIBs );

  for i := 0 to VFINumDIBs-1 do // along all resulting DIBs
  begin
    DIBTime := VFIFirstDIBTime + i*VFIDIBTimeStep;

    //*** get BufSize and prepare Buf buffer

    BufSize := 0;
    VFICoRes := wIMediaDet.GetBitmapBits( DIBTime, @BufSize, nil,
                                                VFIFrameWidth, VFIFrameHeight );
    Result := 13;
    VFISError := N_GetDSErrorDescr( VFICoRes );
    if FAILED(VFICoRes) or (BufSize <= 0) then goto Fin;

    if Length( Buf ) < BufSize then SetLength( Buf, BufSize );

    VFICoRes := wIMediaDet.GetBitmapBits( DIBTime, @BufSize, @Buf[0],
                                                VFIFrameWidth, VFIFrameHeight );
    Result := 14;
    VFISError := N_GetDSErrorDescr( VFICoRes );
    if FAILED(VFICoRes) then goto Fin;

    //***** Buf contains BITMAPINFOHEADER structure followed by the DIB bits

    VFIDIBsArray[i] := TN_DIBObj.Create();
    VFIDIBsArray[i].LoadFromMemBMP( @Buf[0] );
//    VFIDIBsArray[i].SaveToBMPFormat( 'C:\\ztmp.bmp' ); // debug
  end; // for i := 0 to VFINumDIBs-1 do // along all resulting DIBs

  Result := 0;

  Fin: //*************************
  VFIIError := Result;
  wIMediaDet := nil;
  end; // with APVFInfo^ do
end; // function N_GetVideoFileInfoFromMediaDet

//******************************************* N_AddVideoFileDescr(APVFInfo) ***
// Add video file description to given AResStrings using given APVFInfo
//
//     Parameters
// APVFInfo    - pointer to TN_VideoFileInfo record which description is needed
// AResStrings - Resulting Strings with added APVFInfo^ description
// Result      - Return 0 if OK or > 0 if error
//
function N_AddVideoFileDescr( APVFInfo: TN_PVideoFileInfo; AResStrings:
                                                            TStrings ): integer;
var
  i: integer;
begin
  Result := 1;
  if APVFInfo = nil then Exit; // a precaution

  with APVFInfo^, AResStrings do
  begin
    if VFIIError > 0 then
      Add( Format( '  Error # %d, %s', [VFIIError, VFISError] ) );

    Add( Format( '  NumStreams=%d, FrameSize=%dx%d, FileSize=%s',
                      [VFINumStreams, VFIFrameWidth, VFIFrameHeight,
                                            N_DataSizeToString(VFIFileSize)] ));
    Add( Format( '  Duration=%s, FPS=%.1f, BitRate=%.1f KBytes/sec. ',
                      [N_SecondsToString(VFIDuration), VFIFramesRate,
                                                           VFIBitRate/1024.] ));
    Add( Format( '  FixedSize=%d, Temp.Compr.=%d, StreamInd=%d',
                      [VFIFixedSizeSamples, VFITemporalCompression,
                                                          VFIVideoStreamInd] ));

    for i := 0 to VFINumStreams-1 do // along all streams, add only general
    begin                            // (not full!) Stream Info

      Add( Format( '     Stream %d general Info:', [i] ) );

      Add( 'Major  Type - ' + VFIStreamsInfo[3*i+0] );
      Add( 'Sub    Type - ' + VFIStreamsInfo[3*i+1] );
      Add( 'Format Type - ' + VFIStreamsInfo[3*i+2] );
    end; // for i := 0 to VFINumStreams-1 do // along all streams, add only general

    Add( '' );
  end; // with APVFInfo^, AResStrings do

end; // function N_AddVideoFileDescr(APVFInfo)

//********************************************* N_AddVideoFileDescr(AFName) ***
// Add video file description to given AResStrings using given AFName
//
//     Parameters
// AFName      - given video File Name
// AResStrings - Resulting Strings with added APVFInfo^ description
// Result      - Return 0 if OK or > 0 if error
//
function N_AddVideoFileDescr( AFName: string; AResStrings: TStrings ): integer;
var
  VFInfo: TN_VideoFileInfo;
begin
  AResStrings.Add( '***** Info about file ' );
  AResStrings.Add( ' ' + AFName );

  FillChar( VFInfo, SizeOf(VFInfo), 0 );
  N_GetVideoFileInfo( AFName, @VFInfo );
  Result := N_AddVideoFileDescr( @VFInfo, AResStrings );
end; // function N_AddVideoFileDescr(AFName)

//************************************* N_GetVideoFileInfoFromSampleGrabber ***
// Get Info about video file with given AFName into given APVFInfo record using
// SampleGrabber
//
//     Parameters
// AFName     - given video File Name
// APVFInfo   - pointer to TN_VideoFileInfo record with input and output params
//              (on output it contains collected Info)
// Result     - Return 0 if OK or > 0 if error
//
function N_GetVideoFileInfoFromSampleGrabber( AFName: string;
                                         APVFInfo: TN_PVideoFileInfo ): integer;
var
  MediaType:   _AMMediaType;
  BitsBufSize, Sec: integer;
  PDIB:        TN_PDIBInfo;
  SampleGrabFilter: IBaseFilter;
  SampleGrabber:    ISampleGrabber;
  Res:    HResult;
  CaptGraphBuilder: ICaptureGraphBuilder2;
  GraphBuilder:     IGraphBuilder;
  MediaControl:     IMediaControl;
  VideoWindow:      IVideoWindow;
  MediaPosition:    IMediaPosition;
  DIBObj:      TN_DIBObj;
  FName, SError: string;
  VLengthSec:  double;
  Label Found, Fin;
begin
  Result := 1; // APVFInfo not given
  if APVFInfo = nil then Exit; // a precaution

  with APVFInfo^ do
  begin

  FName := K_ExpandFileName( AFName );
  if not FileExists( FName ) then
  begin
    Result := 2; // File not found
    VFISError := 'File not found "' + AFName + '"';
    goto Fin;
  end;

  VFIFramesRate  := 0;
  VFIFrameWidth  := 0;
  VFIFrameHeight := 0;
  VFIBitRate     := 0;

  VFIFileSize := N_GetFileSize( FName );
  end;

  CoInitialize( Nil );

   // ***** Create VCOIGraphBuilder - Object for constructing Filter Graph
  GraphBuilder := nil;
  Res := CoCreateInstance(CLSID_FilterGraph, nil, CLSCTX_INPROC_SERVER,
                                               IID_IGraphBuilder, GraphBuilder);
  SError := N_GetDSErrorDescr( Res );
    if FAILED(Res) then goto Fin;

  // ***** Create VCOICaptGraphBuilder - Object for constructing Capturing Filter Graph
  CaptGraphBuilder := nil;
  Res := CoCreateInstance(CLSID_CaptureGraphBuilder2, nil,
         CLSCTX_INPROC_SERVER, IID_ICaptureGraphBuilder2, CaptGraphBuilder);

  N_Dump1Str('Creating CaptureGraphBuilder2 = '+IntToStr(Res));

  SError := N_GetDSErrorDescr( Res );
    if FAILED(Res) then goto Fin;

  Res := GraphBuilder.QueryInterface(IID_IMediaControl, MediaControl);

  N_Dump1Str( 'Creating MediaControl = '+IntToStr(Res) );
  SError := N_GetDSErrorDescr( Res );
    if FAILED(Res) then goto Fin;

  // Create Sample Grabber Filter
  SampleGrabFilter  := Nil;
  Res := CoCreateInstance( CLSID_SampleGrabber, NIL, CLSCTX_INPROC_SERVER,
                                            IID_IBaseFilter, SampleGrabFilter );

  N_Dump1Str( 'Creating SampleGrabber = '+IntToStr(Res) );
  SError := N_GetDSErrorDescr( Res );
    if FAILED(Res) then goto Fin;

  // get ISampleGrabber Interface
  SampleGrabber := Nil;
  Res := SampleGrabFilter.QueryInterface( IID_ISampleGrabber, SampleGrabber );

  N_Dump1Str( 'Creating SampleGrabber parameters = '+IntToStr(Res) );
  SError := N_GetDSErrorDescr( Res );
    if FAILED(Res) then goto Fin;

  MediaType.majortype  := MEDIATYPE_Video;
  MediaType.subtype    := MEDIASUBTYPE_RGB24;
  MediaType.formattype := FORMAT_VideoInfo;
  SampleGrabber.SetMediaType( MediaType );

  SampleGrabber.SetOneShot( true );
  SampleGrabber.SetBufferSamples( true );

  // add VCOISampleGrabFilter to Filter Graph
  Res := GraphBuilder.AddFilter( SampleGrabFilter, 'Sample Grabber' );

  N_Dump1Str( 'Adding SampleGrabFilter = '+IntToStr(Res) );
  SError := N_GetDSErrorDescr( Res );
    if FAILED(Res) then goto Fin;

  Res := MediaControl.RenderFile( AFName );

  N_Dump1Str( 'VCOIMediaControl.RenderFile = '+IntToStr(Res) );
  SError := N_GetDSErrorDescr( Res );
    if FAILED(Res) then goto Fin;

  VideoWindow := Nil;
  GraphBuilder.QueryInterface( IID_IVideoWindow, VideoWindow );

  Res := VideoWindow.put_Visible( False );
  if not Succeeded( Res ) then
    goto Fin;

  VideoWindow.put_AutoShow( False );

  MediaControl.Run();

  // *** Get DIB Info and create empty DIB obj using it
  //ZeroMemory(@MediaType, SizeOf(TAMMediaType));

  Res := SampleGrabber.GetConnectedMediaType( MediaType );

  N_Dump1Str('VCOISampleGrabber.GetConnectedMediaType with no parameters = '
                                                               + IntToStr(Res));
  SError := N_GetDSErrorDescr( Res );
    if FAILED(Res) then goto Fin;

  PDIB := TN_PDIBInfo( @(PVideoInfoHeader(MediaType.pbFormat)^.bmiHeader) );

  DIBObj := TN_DIBObj.Create();
  DIBObj.PrepEmptyDIBObj(PDIB);
  BitsBufSize := PDIB.bmi.biSizeImage; // buffer size

  // *** Get BufSize for Sample content for debug
  N_i := 0;

  Sec := 0; // seconds waiting = 0
  SampleGrabber.GetCurrentBuffer( N_i, nil );

  while (N_i = 0) and (Sec <> 50) do // trying to get image for 5 seconds
  begin
    SampleGrabber.GetCurrentBuffer( N_i, nil );
    Sleep( 100 );
    Inc( Sec );
  end;

  N_Dump1Str( 'GUID: ' + GUIDToString(MediaType.SubType) );

  N_i := SampleGrabber.GetCurrentBuffer( BitsBufSize, DIBObj.PRasterBytes );
  N_Dump1Str( 'VCOISampleGrabber.GetCurrentBuffer actual = ' + IntToStr(N_i) );

  MediaControl.Stop();

  with APVFInfo^ do
  begin

  VFINumStreams := 1; // not needed

  //SetLength( VFIStreamsInfo, 3*VFINumStreams );
  VFIStreamsInfo := Nil; // not needed

  VFIVideoStreamInd := -1; // as if not found

  Res := GraphBuilder.QueryInterface( IID_IMediaPosition, MediaPosition );
  if not Succeeded( Res ) then
    goto Fin;

  MediaPosition.get_Duration( VLengthSec );
  VFIDuration := VLengthSec;

  VFIFixedSizeSamples    := integer( MediaType.bFixedSizeSamples );
  VFITemporalCompression := integer( MediaType.bTemporalCompression );

  if IsEqualGUID( MediaType.formattype, FORMAT_None ) then
  begin
    VFIMediaFormat := 'FORMAT_None';
  end else if IsEqualGUID( MediaType.formattype, FORMAT_VideoInfo ) then
  begin
    VFIMediaFormat := 'FORMAT_VideoInfo';

    // Remark: for cool.avi and some *.wmv files MediaType.cbFormat = 1112 or 1128, why?
    //         ( sizeof(VIDEOINFOHEADER)=88, sizeof(VIDEOINFOHEADER2)=112 )
    // so, i use ">=" instead of "=" in next statement (and it works!)

    if MediaType.cbFormat >= sizeof(VIDEOINFOHEADER) then
    with PVideoInfoHeader(MediaType.pbFormat)^ do
    begin
      if AvgTimePerFrame = 0 then
        VFIFramesRate := 0
      else // AvgTimePerFrame > 0
        VFIFramesRate  := 1.0e7 / AvgTimePerFrame; // Frames per Second

      VFIFrameWidth  := bmiHeader.biWidth;
      VFIFrameHeight := abs(bmiHeader.biHeight);
      VFIBitRate     := Integer(dwBitRate); //???
    end;
  end else if IsEqualGUID( MediaType.formattype, FORMAT_VideoInfo2 ) then
  begin
    VFIMediaFormat := 'FORMAT_VideoInfo2';
    if MediaType.cbFormat >= sizeof(VIDEOINFOHEADER2) then
    with PVideoInfoHeader2(MediaType.pbFormat)^ do
    begin
      if AvgTimePerFrame = 0 then
        VFIFramesRate := 0
      else // AvgTimePerFrame > 0
        VFIFramesRate  := 1.0e7 / AvgTimePerFrame; // Frames per Second

      VFIFrameWidth  := bmiHeader.biWidth;
      VFIFrameHeight := abs(bmiHeader.biHeight);
      VFIBitRate     := Integer(dwBitRate); //???
    end;
  end else if IsEqualGUID( MediaType.formattype, FORMAT_WaveFormatEx ) then
  begin
    VFIMediaFormat := 'FORMAT_WaveFormatEx';
    // for Audio data only
  end else if IsEqualGUID( MediaType.formattype, FORMAT_MPEGVideo ) then
  begin
    VFIMediaFormat := 'FORMAT_MPEGVideo';
    if MediaType.cbFormat = sizeof(MPEG1VIDEOINFO) then
    with PMPEG1VIDEOINFO(MediaType.pbFormat)^.hdr do
    begin
      if AvgTimePerFrame = 0 then
        VFIFramesRate := 0
      else // AvgTimePerFrame > 0
        VFIFramesRate  := 1.0e7 / AvgTimePerFrame; // Frames per Second

      VFIFrameWidth  := bmiHeader.biWidth;
      VFIFrameHeight := abs(bmiHeader.biHeight);
      VFIBitRate     := dwBitRate;
    end;
  end else if IsEqualGUID( MediaType.formattype, FORMAT_MPEGStreams ) then
  begin
    VFIMediaFormat := 'FORMAT_MPEGStreams';
  end else if IsEqualGUID( MediaType.formattype, FORMAT_DvInfo ) then
  begin
    VFIMediaFormat := 'FORMAT_DvInfo';
    // Digital Video Stream
  end else // Unknown Format
  begin
    VFIMediaFormat := GUIDToString( MediaType.formattype );
  end;

  N_DSFreeMediaType( @MediaType ); // clear MediaType member objects

  SetLength( VFIDIBsArray, VFINumDIBs );

  if VFIDIBsArray <> Nil then
    VFIDIBsArray[0] := DIBObj;

  Result := 0;

  Fin: //*************************
  N_Dump1Str('Beginning of Fin');
  APVFInfo^.VFIIError := Result;
  end; // with APVFInfo^ do

  if MediaControl <> Nil then
  begin
    MediaControl.Stop();
    N_Dump1Str('After MediaControl.Stop();');
  end;

  SampleGrabber     := nil;
  SampleGrabFilter  := nil;
  VideoWindow       := nil;
  MediaControl      := nil;
  CaptGraphBuilder  := nil;
  GraphBuilder      := nil;
  MediaPosition     := Nil;
  CoUninitialize();
  N_Dump1Str('Ending of Fin');
end; // N_GetVideoFileInfoFromSampleGrabber

//***************************************************** N_GetVideoFileThumb ***
// Get DIB with given video file Thumbnail
//
//     Parameters
// AFName       - given video File Name
// APVFThumbPar - pointer to TN_VideoFileThumb record with input params
// Result       - Return created DIB object
//
function N_GetVideoFileThumb( AFName: string; APVFThumbPar: TN_PVFThumbParams )
                                                                    : TN_DIBObj;
var
  iRes, GrayColor: integer;
  MainBordWidth, BlackBordWidth, WhiteWholesWidth: integer;
  DIBExists: boolean;
  Aspect: double;
  ThumbSize: TPoint;
  ThumbRect, TmpRect, WhiteRect, ImageRect: TRect;
//  DumpSL: TStringList;
  VFInfo: TN_VideoFileInfo;
  WrkString: string;

  procedure DrawWhiteRects( AMode: integer ); // local
  // Draw Horizontal Row of small White Rects (film wholes) in TmpRect
  // AMode=0 - Upper Row, AMode=1 - Lower Row
  var
    i: integer;
  begin
    with Result, VFInfo, APVFThumbPar^ do
    begin

    if AMode = 0 then // Upper Row
      WhiteRect.Top := TmpRect.Top + MainBordWidth - WhiteWholesWidth - 1
    else //************* Lower Row
      WhiteRect.Top := TmpRect.Top + 1;

    WhiteRect.Bottom := WhiteRect.Top + WhiteWholesWidth - 1;
    WhiteRect.Left   := WhiteWholesWidth div 2;
    WhiteRect.Right  := WhiteRect.Left + WhiteWholesWidth - 1;

    for i := 0 to ThumbSize.X do // along White Rects, much more then needed
    begin
//      DIBOCanv.SetBrushAttribs( $FFFFFF );
//      DIBOCanv.DrawPixFilledRect( WhiteRect );
      DIBOCanv.DrawPixRoundRect ( WhiteRect, Point(2,2), $FFFFFF, $FFFFFF, 1 );

      Inc( WhiteRect.Left,  2*WhiteWholesWidth );
      Inc( WhiteRect.Right, 2*WhiteWholesWidth );

      if WhiteRect.Left > TmpRect.Right then Break; // all done
    end; // for i := 0 to ThumbSize.X do // along White Rects, much more then needed

    end; // with Result, VFInfo, APVFThumbPar^ do
  end; // procedure DrawWhiteRects(); // local

begin
  Result := nil;
  FillChar( VFInfo, SizeOf(VFInfo), 0 );
  VFInfo.VFINumDIBs := 1;

  WrkString := N_MemIniToString( 'CMS_UserDeb', 'VideoInfoMode', '0' ); // // get info using imediadet or samplegrabber
    if WrkString = '1' then
    begin
      iRes := N_GetVideoFileInfoFromSampleGrabber( AFName, @VFInfo );
      if iRes > 0 then
        iRes := N_GetVideoFileInfo( AFName, @VFInfo );
    end
    else
    begin
      iRes := N_GetVideoFileInfo( AFName, @VFInfo );
      if iRes > 0 then
        iRes := N_GetVideoFileInfoFromSampleGrabber( AFName, @VFInfo );
    end;

  //***** Resulting TN_DIBObj will be created even in case of error (iRes > 0)

  if iRes > 0 then // error while getting Video File Info
  begin
    N_Dump1Str( Format('VFThumb: Error %d while creating Thumbnail form file',
                                                                      [iRes]) );
    N_Dump1Str( 'VFThumb ' + AFName );
  end; // if iRes > 0 then // error while getting Video File Info

{ // replace N_StringsDumpProcObj by N_Dump2Strings!
  if Assigned( N_StringsDumpProcObj ) then
  begin
    if N_StringsDumpProcObj( 'VFThumb', nil ) then // check if dumping is needed
    begin
      DumpSL := TStringList.Create;
      N_AddVideoFileDescr( @VFInfo, DumpSL );
      N_StringsDumpProcObj( 'VFThumb', DumpSL );
      DumpSL.Free;
    end; // if N_StringsDumpProcObj( 'VFThumb', nil ) then // check if dump is needed
  end; // if Assigned( N_StringsDumpProcObj ) then
}

  GrayColor := $BBBBBB;

  with Result, VFInfo, APVFThumbPar^ do
  begin
    ThumbSize.X := max( 32, VFTPThumbSize );

    MainBordWidth    := Round( 0.01*VFTPThumbSize*VFTPMainBordWidth );
    BlackBordWidth   := Round( 0.01*VFTPThumbSize*VFTPBlackBordWidth );
    WhiteWholesWidth := Round( 0.01*VFTPThumbSize*VFTPWhiteWholesWidth );

    if (VFIFrameWidth > 0) and (VFIFrameHeight > 0) then
      Aspect := VFIFrameHeight / VFIFrameWidth
    else
      Aspect := 0.666;

    ThumbSize.Y := Round( (ThumbSize.X - 2*BlackBordWidth) * Aspect ) +
                                             2*BlackBordWidth + 2*MainBordWidth;

    Result := TN_DIBObj.Create( ThumbSize.X, ThumbSize.Y, pf24bit, 0 );
    ThumbRect := IRect( ThumbSize );

    //***** Draw Upper Horizontal Gray border
    TmpRect := ThumbRect;
    TmpRect.Bottom := MainBordWidth - 1;
    DIBOCanv.SetBrushAttribs( GrayColor );
    DIBOCanv.DrawPixFilledRect( TmpRect );
    DrawWhiteRects( 0 );

    //***** Draw Lower Horizontal Gray border
    TmpRect := ThumbRect;
    TmpRect.Top  := ThumbRect.Bottom - MainBordWidth + 1;
    DIBOCanv.SetBrushAttribs( GrayColor );
    DIBOCanv.DrawPixFilledRect( TmpRect );
    DrawWhiteRects( 1 );

    ImageRect.Left   := BlackBordWidth;
    ImageRect.Top    := MainBordWidth + BlackBordWidth;
    ImageRect.Right  := ThumbRect.Right  - BlackBordWidth;
    ImageRect.Bottom := ThumbRect.Bottom - MainBordWidth - BlackBordWidth;

    DIBExists := False;
    if Length(VFInfo.VFIDIBsArray) >= 1 then
      if VFInfo.VFIDIBsArray[0] <> nil then
        DIBExists := True;

    if DIBExists then
      DIBOCanv.DrawPixDIB( VFInfo.VFIDIBsArray[0], ImageRect, Rect(0,0,-1,-1) )
    else // Image from Video file was not captured, just draw '???' string on Thumb background
    begin
      DIBOCanv.SetBrushAttribs( $EEEEEE ); // light grey background
      DIBOCanv.DrawPixFilledRect( ImageRect );
//      N_SetNFont( N_CM_ThumbFramePropFont, DIBOCanv );
      DIBOCanv.DrawPixString( Point( 20, MainBordWidth+10 ), '???' );
    end;

//    VFInfo.VFIDIBsArray[0].SaveToBMPFormat( 'C:\\b1.bmp' ); // debug
//    Result.SaveToBMPFormat( 'C:\\b3.bmp' ); // debug

    if DIBExists then  VFInfo.VFIDIBsArray[0].Free;
  end; // with Result, VFInfo, APVFThumbPar^ do
end; // function N_GetVideoFileThumb

//****************************************************** N_DSEnumVideoSizes ***
// Enumerate Video Capturing Sizes for given ADevName
//
//     Parameters
// ADevName - given Video Capturing Device Name (retrieved by N_DSEnumFilters)
// AResList - TStrings with ordered resulting Video Capturing Sizes
//
// Video Capturing Sizes are collected and ordered in AVideoSizes as strings
// in 'Width x Height' ('%4d x %d') format
//
procedure N_DSEnumVideoSizes( ADevName: string; AResList: TStrings );
var
  VCO: TN_VideoCaptObj;
begin
  VCO := TN_VideoCaptObj.Create;

  VCO.VCOVCaptDevName := ADevName;
  VCO.VCOPrepInterfaces();

  if VCO.VCOIError = 0 then
    VCO.VCOEnumVideoSizes( AResList )
  else
    AResList.Clear;

  VCO.Free;
end; // procedure N_DSEnumVideoSizes

//******************************************************* N_DSEnumVideoCaps ***
// Enumerate Video Capturing Capabilities for given ADevName
//
//     Parameters
// ADevName - given Video Capturing Device Name (retrieved by N_DSEnumFilters)
// AResList - TStrings with resulting Video Capturing Capabilities
//
// Video Capturing Sizes are collected and ordered in AVideoSizes as strings
// in 'Width x Height' ('%d x %d') fromat
//
procedure N_DSEnumVideoCaps( ADevName: string; AResList: TStrings );
var
  VCO: TN_VideoCaptObj;
begin
  VCO := TN_VideoCaptObj.Create;

  VCO.VCOVCaptDevName := ADevName;
  VCO.VCOPrepInterfaces();

  if VCO.VCOIError = 0 then
    VCO.VCOEnumVideoCaps( AResList )
  else
  begin
    AResList.Clear;
    AResList.Add( Format('VCO Error %d, %s', [VCO.VCOIError, VCO.VCOSError]) );
  end;

  VCO.Free;
end; // procedure N_DSEnumVideoCaps

//****************************************************** N_DSEnumVideoSizes ***
// Enumerate Video Capturing Sizes for given ADevName
//
//     Parameters
// ADevName - given Video Capturing Device Name (retrieved by N_DSEnumFilters)
// AResList - TStrings with ordered resulting Video Capturing Sizes
//
// Video Capturing Sizes are collected and ordered in AVideoSizes as strings
// in 'Width x Height' ('%4d x %d') format
//
function N_GetGUIDName( const AGUID: TGUID ): string;
begin
  if IsEqualGUID( AGUID, FORMAT_None ) then
    Result := 'FORMAT_None'
  else if IsEqualGUID( AGUID, FORMAT_VideoInfo ) then
    Result := 'FORMAT_VideoInfo'
  else if IsEqualGUID( AGUID, FORMAT_VideoInfo2 ) then
    Result := 'FORMAT_VideoInfo2'
  else if IsEqualGUID( AGUID, FORMAT_WaveFormatEx ) then
    Result := 'FORMAT_WaveFormatEx'
  else if IsEqualGUID( AGUID, FORMAT_MPEGVideo ) then
    Result := 'FORMAT_MPEGVideo'
  else if IsEqualGUID( AGUID, FORMAT_MPEGStreams ) then
    Result := 'FORMAT_MPEGStreams'
  else if IsEqualGUID( AGUID, FORMAT_DvInfo ) then
    Result := 'FORMAT_DvInfo'

  else if IsEqualGUID( AGUID, MEDIASUBTYPE_RGB8 ) then
    Result := 'MEDIASUBTYPE_RGB8'
  else if IsEqualGUID( AGUID, MEDIASUBTYPE_RGB24 ) then
    Result := 'MEDIASUBTYPE_RGB24'
  else if IsEqualGUID( AGUID, MEDIASUBTYPE_RGB32 ) then
    Result := 'MEDIASUBTYPE_RGB32'
  else if IsEqualGUID( AGUID, MEDIASUBTYPE_ARGB32 ) then
    Result := 'MEDIASUBTYPE_ARGB32'
  else if IsEqualGUID( AGUID, MEDIASUBTYPE_YUY2 ) then
    Result := 'MEDIASUBTYPE_YUY2'
  else if IsEqualGUID( AGUID, MEDIASUBTYPE_Y41P ) then
    Result := 'MEDIASUBTYPE_Y41P'
  else if IsEqualGUID( AGUID, MEDIASUBTYPE_I420 ) then
    Result := 'MEDIASUBTYPE_I420'
  else if IsEqualGUID( AGUID, MEDIASUBTYPE_PCM ) then
    Result := 'MEDIASUBTYPE_PCM'
  else if IsEqualGUID( AGUID, WMMEDIASUBTYPE_WMV1 ) then
    Result := 'WMMEDIASUBTYPE_WMV1'
  else if IsEqualGUID( AGUID, WMMEDIASUBTYPE_WMV2 ) then
    Result := 'WMMEDIASUBTYPE_WMV2'
  else if IsEqualGUID( AGUID, WMMEDIASUBTYPE_WMV3 ) then
    Result := 'WMMEDIASUBTYPE_WMV3'

  else if IsEqualGUID( AGUID, MEDIATYPE_Video ) then
    Result := 'MEDIATYPE_Video'
  else if IsEqualGUID( AGUID, MEDIATYPE_Audio ) then
    Result := 'MEDIATYPE_Audio'
  else if IsEqualGUID( AGUID, MEDIATYPE_Midi ) then
    Result := 'MEDIATYPE_Midi'
  else if IsEqualGUID( AGUID, MEDIATYPE_Stream ) then
    Result := 'MEDIATYPE_Stream'
  else if IsEqualGUID( AGUID, MEDIATYPE_File ) then
    Result := 'MEDIATYPE_File'


  else // Unknown GUID
    Result := GUIDToString( AGUID );
end; // function N_GetGUIDName

end.
