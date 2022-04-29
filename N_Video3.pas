unit N_Video3;
// ***** Video processing Tools

// 29.06.15 - deleted GetVideoThumb
// 04.08.15 - deleted some function that are in the N_Video.pas
// 15.07.17 - remembering the state on shared screens (form init)
// 04.08.17 - slow start after windows 10 update, remembering the form position
// 22.08.17 - local operations to ini for a video recording (LocalRecord in ini)

interface

uses
  Windows, Classes, Graphics, SysUtils, ActiveX, Dialogs,
  DirectShow9, Types,
  N_Types, N_Gra0, N_Gra2,
  Messages, K_CM0;

const
  N_WDM_2860_Capture = '352 240 352 480 480 480 720 480'; // Unable resolutions for WDM

type
  TN_BaseFilterInfo = packed record // Info about IBaseFilter
    BFIFilter: IBaseFilter; // Filter IBaseFilter Interface
    BFIName: string; // Filter Name
    BFIVendorStr: string; // Venodor info string
  end;
  // type TN_BaseFilterInfo = packed record // Info about IBaseFilter
type
  TN_PBaseFilterInfo = ^TN_BaseFilterInfo;

type
  TN_SlidesInfo = packed record
    SIASlides:   TN_UDCMSArray;
    SINumVideos: Integer;
    SINumStills: Integer;
end;

type
  TN_VFThumbParams = packed record // Video File Thumbnail Params
    VFTPThumbSize:      integer; // max X,Y Thumbnail Size in Pixels
    VFTPMainBordWidth:    float; // Main (Gray) border width in Percents of VFTPThumbSize
    VFTPBlackBordWidth:   float; // Black border width around Image in Percents of VFTPThumbSize
    VFTPWhiteWholesWidth: float; // White Wholes (inside MainBorder) width in Percents of VFTPThumbSize
  end;
  // type TN_VFThumbParams = packed record // Video File Thumbnail Params
type
  TN_PVFThumbParams = ^TN_VFThumbParams;

type
  TN_ControlStreamFlags = Set Of ( csfPreview, csfCapture, csfStart, csfStop );

type
  TN_VideoCapsFlags = Set Of (vcfDeb1, vcfSizesList);

type
  TN_VideoCaptObj3 = class(TObject) // ***
    // ***** should be set on input:
    VCOVCaptDevName: string; // Video Capturing Device Name
    VCOVComprFiltName: string; // Video Compressor Filter Name
    VCOVComprSectionName: string; // MemIni Section Name with preferred VideoCompressor Names
    VCOWindowHandle: THandle; // Windows WinHandle where Video Priview should be
    VCOMaxWindowRect: TRect; // Max Preview Rect in VCOWindowHandle
    VCOFileName: string;//s: Array [0 .. 1] of string; // two avi File Names for resulting Video
    VCOMinFileSize: int64; // Minimal Video File initial Size in bytes

    // ***** DirectShow Intefaces:
    VCOIGraphBuilder: IGraphBuilder;
    VCOICaptGraphBuilder: ICaptureGraphBuilder2;
    VCOIMux: IBaseFilter;
    VCOISink: IFileSinkFilter;
    VCOIMediaControl: IMediaControl;
    VCOIStreamConfig: IAMStreamConfig;
    VCOIVideoWindow: IVideoWindow;
    VCOIVideoProcAmp: IAMVideoProcAmp;
    VCOISampleGrabber: ISampleGrabber;

    VCOVideoMoniker: IMoniker;
    VCOAudioMoniker: IMoniker;
    VCOIVideoCompression: IAMVideoCompression;
    VCODialogs: IAMVfwCaptureDialogs;
    VCOIConfigAviMux: IConfigAviMux;
    // Needed for VMR filter
    VCOVmrFilterConfig7: IVMRFilterConfig;
    VCOVmrMixerControl7: IVMRMixerControl;
    //VCOWindowlessControl: IVMRWindowlessControl;

    // ***** DirectShow Filters:
    VCOIVideoCaptFilter: IBaseFilter;
    VCOIAudioCaptFilter: IBaseFilter;
    VCOIVideoComprFilter: IBaseFilter;
    VCOIAudioComprFilter: IBaseFilter;
    VCOISampleGrabFilter: IBaseFilter;
    VCOInfTee: IBaseFilter; // Infinite Tee filter - to handle
    // Old drivers problems
    VCONullRendererFilter: IBaseFilter;

    VCOVmrFilter: IBaseFilter; // VMR filter

    // ***** Other fields:
    //VCOFileNameInd: integer; // Index in VCOFileNames for NEXT recording (next FileName)
    VCORecordGraph:   Boolean; // RecordGrapth for Recording Videos
    VCOGrabGraph:     Boolean; // GrabGraph for Grabbing Samples
    VCONowRecording:  Boolean; // writing to avi file Stream is now working (not stopped)
    VCOCurWindowRect: TRect;   // Current Preview Rect in VCOWindowHandle (can be any size, streching is always used)

    VCOCoRes:         HResult; // COM result code (Error code)
    VCOIError:        integer; // Own Integer Error code
    VCOSError:        string;  // VCOCoRes or VCOIError description as String
    VCOGraphState:    TFilterState; // 0-Stopped, 1-Paused, 2-Running
    VCONeededVideoCMST: TGUID; // Needed Video Capture Media SubType format or NilGUID if any format is OK
    VCOCurVideoCMST:  TGUID;   // Current Video Capture Media SubType format
    VCOStrings:       TStringList;

    VCOCaptPin:       integer; // Capture Pin type 0-PIN_CATEGORY_CAPTURE, 1-PIN_CATEGORY_CAPTURE
    VCOFVFWStatus:    Boolean;

    VCOCCAvail:       Boolean; // Closed Captioning Available
    VCOCapCC:         Boolean; // Do We Need To Render Closed Captioning Pin?
    VCOWachFriendlyName: WideString; // Device (Filter) Name
    VCOCapAudioIsRelevant: Boolean; // Is Audio Caption Relevant?
    VCOCapAudio:      Boolean; // Do We Need Audio Caption?
    VCOPreviewFaked:  Boolean; // Is Preview Faked?
    VCOUseFrameRate:  Boolean; // Do We Need To Use the Frame Rate from VCOFrameRate?
    VCOFrameRate:     Double;
    VCOIMasterStream: integer; // Holds master stream (None, Audio or Video)

    VCOUnableResolutions: TStringList; // for disabling resolutions

    VCOError:         Boolean; // error while initializing

    constructor Create  ();
    constructor Create3 ( AWindowHandle: THandle; AMaxWindowRect: TRect;
                                   ABaseFileName: string; AMinFileSize: int64 );
    destructor Destroy  (); override;

    procedure VCOGetErrorDescr ( ACoRes: HResult );
    function  VCOCheckRes      ( AIError: integer ): Boolean;
    procedure VCODumpString    ( AStr: string );
    procedure VCOPrepVideoFiles();
    function  VCOGetGraphState (): integer;
    procedure VCOEnumVideoCaps ( AVideoCaps: TStrings );
    function  VCOGetNextFilter ( ACurFilter: IBaseFilter; ADirection: PGUID;
                                       APBFI: TN_PBaseFilterInfo ): IBaseFilter;
    function  VCOGetCrossbarFilter    (): IBaseFilter;
    function  VCOGetCrossbarFilterInfo(): Boolean;
    procedure VCOEnumVideoSizes       ( AVideoSizes: TStrings );
    procedure VCOEnumFilters2         ( AStrings: TStrings );
    procedure VCOEnumFilterPins   ( AStrings: TStrings; AFilter: IBaseFilter );
    procedure VCOSetVideoSize     ( AInpSizeStr: string; out ANewSize: TPoint );
    procedure VCOClearGraph       ();
    procedure VCOPrepInterfaces2  (); // added for Mode 2
    procedure VCOPrepVideoWindow  ();
    procedure VCOPrepRecordGraph2 (); // added for Mode 2
    procedure VCOPrepGrabGraph3   (); // added for Mode 2
    procedure VCOStartRecording   ();
    function  VCOStopRecording    (): string;
    function  VCOGrabSample       (): TN_DIBObj;
    procedure VCOShowFilterDialog ( AIFilter: IBaseFilter;
                                                       AWindowHandle: THandle );
    procedure VCOShowStreamDialog ( AWindowHandle: THandle );
    procedure VCOControlStream    ( AFlags: TN_ControlStreamFlags );
    property  VCOVFWStatus: Boolean read VCOFVFWStatus write VCOFVFWStatus;
    // added for Mode 2
    procedure VCOSetPreviewWindowSize;  // for Windowed
    function  VCOGetVFWStatus: Boolean;
    function  VCOMakeBuilder:  Boolean;
    function  VCOMakeGraph:    Boolean;
    procedure VCOFreeCapFilters;
    procedure VCONukeDownStream ( F: IBaseFilter );
  end; // type TN_VideoCaptObj = class( TObject )

  // *** VCOIError ranges list:
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

  // *************************  Global Procedures  ***************

procedure N_DSFreeMediaType   ( APMediaType: PAMMediaType );
procedure N_DSDeleteMediaType ( APMediaType: PAMMediaType );
function  N_GetDSErrorDescr   ( ACoRes: HResult ): string;

function N_DSEnumFilters      ( const clsidDeviceClass: TGUID; ADevName: String;
                  ADevNamesList: TStrings; out AErrCode: integer ): IBaseFilter;
function N_DSGetAnyFilter     ( const clsidDeviceClass: TGUID;
                                    ASectionName: string; out AErrCode: integer;
                                         out AFilterName: string ): IBaseFilter;
procedure N_DSEnumVideoSizes2 ( ADevName: string; AResList: TStrings );
// for Mode 2
procedure N_DSEnumVideoCaps2  ( ADevName: string; AResList: TStrings );
// for Mode 2
function  N_GetGUIDName       ( const AGUID: TGUID ): string;

// To Add and Remove Graph
function AddGraphToRot     ( Graph: IFilterGraph; out ID: integer ): HResult;
function RemoveGraphFromRot( ID: integer ): HResult;

const
  N_MAXLONGLONG = $7FFFFFFFFFFFFFFF;

var
  N_DSErrorString: string;
  N_GraphStates: Array [0 .. 2] of string = (
    'Stopped',
    'Paused',
    'Running'
  );
  N_LogDevNamesList: TStringList; // List of already logged devices

implementation

uses Math, Variants,
  DirectDraw,
  K_CLib0, K_Parse,
  N_Lib0, N_Lib1, N_Lib2, N_Gra1;

// *********************** TN_VideoCaptObj Class methods

// ************************************************** TN_VideoCaptObj.Create ***
// Create Self
//
constructor TN_VideoCaptObj3.Create();
begin
  VCOStrings := TStringList.Create;
  VCOMinFileSize := 10 * 1024 * 1024;
 // VCOFileNameInd := 1; // first capturing will be to VCOFileNames[0]
end; // constructor TN_VideoCaptObj.Create;

// ************************************************* TN_VideoCaptObj.Create3 ***
// Create Self by given Params
//
// Parameters
// AWindowHandle  - Windows Window Handle where to show Video
// AMaxWindowRect - Max allowed Rect coords in given Window where to show Video
// ABaseFileName  - Base File name for Video Recording
// AMinFileSize   - Minimal File Size before recording (in bytes)
//
constructor TN_VideoCaptObj3.Create3( AWindowHandle: THandle;
            AMaxWindowRect: TRect; ABaseFileName: string; AMinFileSize: int64 );
begin
  Create();

  VCOWindowHandle  := AWindowHandle;
  VCOMaxWindowRect := AMaxWindowRect;
  VCOCurWindowRect := AMaxWindowRect;
  VCOMinFileSize   := AMinFileSize;

  VCOFileName := K_ExpandFileName( ABaseFileName );
end; // constructor TN_VideoCaptObj3.Create3;

// ************************************************ TN_VideoCaptObj3.Destroy ***
// Close all TWAIN Objects and Destroy Self
//
destructor TN_VideoCaptObj3.Destroy;
begin
  VCOClearGraph();
  VCOStrings.Free;

  inherited;
end; // destructor TN_VideoCaptObj3.Destroy;

// *************************************** TN_VideoCaptObj3.VCOGetErrorDescr ***
// Clear Video Capturing Graph Filters and other objects
//
// Parameters
// Result - Return 0 for Stopped, 1 for Paused, 2 for Running or -1 if error
//
procedure TN_VideoCaptObj3.VCOGetErrorDescr( ACoRes: HResult );
begin
  VCOSError := N_GetDSErrorDescr( ACoRes );
end; // procedure TN_VideoCaptObj3.VCOGetErrorDescr

// ******************************************** TN_VideoCaptObj3.VCOCheckRes ***
// Check COM result in VCOCoRes
//
// Parameters
// AIError - given Error Number to assign to VCOIError if Failed
// Result  - Return True if failed or False if OK
//
function TN_VideoCaptObj3.VCOCheckRes( AIError: integer ): Boolean;
begin
  Result := FAILED(VCOCoRes);

  if Result then // failed
  begin
    VCOIError := AIError;
    VCOGetErrorDescr( VCOCoRes );
    VCODumpString( Format('VCO Error=%d, %s', [VCOIError, VCOSError]) );
  end
  else // OK
  begin
    VCOIError := 0;
    VCOSError := '';
  end;
end; // function TN_VideoCaptObj3.VCOCheckRes

// ****************************************** TN_VideoCaptObj3.VCODumpString ***
// Check COM result in VCOCoRes
//
// Parameters
// AIError - given Error Number to assign to VCOIError if Failed
// Result  - Return True if failed or False if OK
//
procedure TN_VideoCaptObj3.VCODumpString( AStr: string );
begin
  N_Dump2Str( 'VCO: ' + AStr );
end; // procedure TN_VideoCaptObj3.VCODumpString

// ************************************** TN_VideoCaptObj3.VCOPrepVideoFiles ***
// Prepare two Files for Video Capturing
//
// VCOICaptGraphBuilder Interface is used and should be already OK.
// Errors in range 53 - 55 are checked
//
procedure TN_VideoCaptObj3.VCOPrepVideoFiles();
begin
  VCOIError := 53;
  VCOSError := 'VCOICaptGraphBuilder = nil';
  if VCOICaptGraphBuilder = nil then
    Exit;

  if N_GetFileSize( VCOFileName ) < VCOMinFileSize then
  // Prepare VCOFileNames[0]
  begin
    VCOCoRes := VCOICaptGraphBuilder.AllocCapFile(
                              @N_StringToWide(VCOFileName)[1], VCOMinFileSize );
    if VCOCheckRes(54) then
      Exit;
  end; // if N_GetFileSize( VCOFileNames[0] ) < VCOMinFileSize then

  // ***** Video Fileas were prepared OK if it was needed
  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj3.VCOPrepVideoFiles

// **************************************** TN_VideoCaptObj3.VCOGetGraphState ***
// Get current Graph state in VCOGraphState variable and return it as integer
//
// Parameters
// Result - Return current Graph state as integer
//
function TN_VideoCaptObj3.VCOGetGraphState(): integer;
begin
  Result := -1;
  if VCOIMediaControl <> nil then
  begin
    VCOIMediaControl.GetState( 100, VCOGraphState ); // 100 is timeout in ms
    Result := integer( VCOGraphState );
  end;
end; // function TN_VideoCaptObj3.VCOGetGraphState

// *************************************** TN_VideoCaptObj3.VCOEnumVideoCaps ***
// Enumerate Video Capturing Capabilities of current VCOIVideoCaptFilter
//
// Parameters
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
procedure TN_VideoCaptObj3.VCOEnumVideoCaps( AVideoCaps: TStrings );
var
  i, NumCaps, CapsSize, CurWidth, CurHeight: integer;
  Str:             string;
  CurFramesPerSec: Double;
  VSCC:            TVideoStreamConfigCaps;
  PMediaType:      PAMMediaType;
Label Fin;
begin
  AVideoCaps.Clear;
  if VCOIStreamConfig = nil then
    Exit; // a precaution

  VCOCoRes := VCOIStreamConfig.GetNumberOfCapabilities( NumCaps, CapsSize );
  if VCOCheckRes(90) then
    Exit;

  VCOGetGraphState();
  Str := Format( '* VideoCaps of %s (%s) from %s', [VCOVCaptDevName,
                          N_GraphStates[integer(VCOGraphState)], K_DateTimeToStr
                                             (SysUtils.Date + SysUtils.Time)] );
  AVideoCaps.Add( Str );

  VCOCoRes := VCOIStreamConfig.GetNumberOfCapabilities( NumCaps, CapsSize );
  if VCOCheckRes(91) then
    Exit;

  for i := -1 to NumCaps - 1 do // along current mode and all capabilities
  begin
    if i = -1 then // get current PMediaType
      VCOCoRes := VCOIStreamConfig.GetFormat( PMediaType )
    else // i >= 0, get i-th Capability
      VCOCoRes := VCOIStreamConfig.GetStreamCaps( i, PMediaType, VSCC );
    // get i-th Capability

    if VCOCheckRes(92) then
      Exit;

    with PMediaType^ do
    begin
      with PVideoInfoHeader(pbFormat)^ do
      begin
        CurFramesPerSec := 1.0E7 / AvgTimePerFrame;
        CurWidth := bmiHeader.biWidth;
        CurHeight := abs(bmiHeader.biHeight);
      end; // with PVideoInfoHeader(pbFormat)^ do

      Str := Format('%02d) ', [i]);

      if IsEqualGUID( MajorType, MEDIATYPE_Video ) then
        Str := Str + 'Video, '
      else
        Str := Str + Format( 'MT=%s ', [GUIDToString(MajorType)] );

      Str := Str + N_GetGUIDName( SubType ) + ', ';
      Str := Str + N_GetGUIDName( FormatType ) + ', ';

      Str := Str + Format( 'FPS=%.1f, %d x %d, ', [CurFramesPerSec, CurWidth,
                                                                   CurHeight] );
      AVideoCaps.Add( Str );

      N_DSDeleteMediaType( PMediaType ); // delete MediaType record allocated by DirectShow
    end; // with PMediaType^ do
  end; // for i := -1 to NumCaps-1 do // along current mode and all capabilities

end; // procedure TN_VideoCaptObj3.VCOEnumVideoCaps

// ************************************** TN_VideoCaptObj3.VCOEnumVideoSizes ***
// Enumerate Video Capturing Sizes of current VCOIVideoCaptFilter
//
// Parameters
// AVideoSizes - TStringList with resulting Video Capturing Sizes
//
// VCOIStreamConfig Interface is used and should be already OK.
//
// Video Capturing Sizes are collected and ordered in AVideoSizes as strings
// in 'Width x Height' ('%4d x %d') fromat (%4d is used for ease of ordering)
// Errors in range 77 - 78 are checked
//
procedure TN_VideoCaptObj3.VCOEnumVideoSizes( AVideoSizes: TStrings );
var
  i, NumCaps, CapsSize: integer;
  WrkSL:                TStringList;
  VSCC:                 TVideoStreamConfigCaps;
  PMediaType:           PAMMediaType;

  WrkIndex, WrkWidth, WrkHeight: integer;
  WrkString, NameString: string;

  label StopEnum;
begin
  AVideoSizes.Clear;
  if VCOIStreamConfig = nil then
    Exit; // a precaution

  VCOCoRes := VCOIStreamConfig.GetNumberOfCapabilities( NumCaps, CapsSize );
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

            if (IsEqualGUID(VCONeededVideoCMST, NilGUID) or // any subtype is OK
                                  IsEqualGUID(VCONeededVideoCMST, SubType)) then
            WrkSL.Add( Format('%4d x %d', [biWidth, abs(biHeight)]) );

      end;

      N_DSDeleteMediaType( PMediaType ); // delete MediaType record allocated by DirectShow

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
     '            VFW Test: Inside Null NumCaps section of VCOEnumVideoSizes' );

  end;

StopEnum:
  N_Dump2Str('            VFW Test: Inside VCOEnumVideoSizes, NumCaps=' +
      inttostr(NumCaps));

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
  if NameString = 'WDM_2860_Capture' then
  begin
    WrkString := N_WDM_2860_Capture;
    WrkHeight := 0;

    while WrkHeight <> N_NotAnInteger do // if there are some unable resolutions
    begin
      WrkHeight := N_ScanInteger( WrkString );
      WrkWidth := N_ScanInteger( WrkString );
      VCOUnableResolutions.Add( Format( ' %d x %d', [WrkHeight, WrkWidth]) );
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
end; // procedure TN_VideoCaptObj3.VCOEnumVideoSizes

// *************************************** TN_VideoCaptObj3.VCOGetNextFilter ***
// Get Next Filter
//
// Parameters
// ACurFilter - start Filter, from where to search
// ADirection - search direction (UpStream or DownStream) or nil for getting info about ACurFilter
// APBFI      - pointer to IBaseFilter Info record
// Result     - Return next IBaseFilter or nil if not found
//
function TN_VideoCaptObj3.VCOGetNextFilter( ACurFilter: IBaseFilter;
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
    VCOCoRes := VCOICaptGraphBuilder.FindInterface( ADirection, nil, ACurFilter,
                                                      IID_IBaseFilter, Result );

    if FAILED(VCOCoRes) then
      Result := nil;
  end;

  ZeroMemory( APBFI, SizeOf(TN_PBaseFilterInfo) );

  if Result <> nil then // fill APBFI^ record
    with APBFI^ do
    begin
      BFIFilter := Result;

      VCOCoRes := Result.QueryFilterInfo( FilterInfo );
      if Succeeded(VCOCoRes) then
        BFIName := FilterInfo.achName; // Filter Name

      VCOCoRes := Result.QueryVendorInfo( PVendorStr );
      if Succeeded(VCOCoRes) then
      begin
        BFIVendorStr := PVendorStr^;
        CoTaskMemFree( PVendorStr ); // free memory allocated in QueryVendorInfo
      end;

    end; // if Result <> nil then // fill APBFI^ record
end; // function TN_VideoCaptObj3.VCOGetNextFilter

// *********************************** TN_VideoCaptObj3.VCOGetCrossbarFilter ***
// Get Crossbar Filter or nil if absent
//
// Parameters
// ACurFilter - start Filter, from where to search
// ADirection - search direction (UpStream or DownStream) or nil for getting info about ACurFilter
// APBFI      - pointer to IBaseFilter Info record
// Result     - Return Crossbar Filter IBaseFilter or nil if not found
//
function TN_VideoCaptObj3.VCOGetCrossbarFilter(): IBaseFilter;
var
  AMCrossbarInterface: IAMCrossbar;
begin
  Result := nil;

  VCOCoRes := VCOICaptGraphBuilder.FindInterface( @LOOK_UPSTREAM_ONLY, nil,
                    VCOIVideoCaptFilter, IID_IAMCrossbar, AMCrossbarInterface );
  if FAILED(VCOCoRes) or (AMCrossbarInterface = nil) then
    Exit;

  // Crossbar exists. Get its IBaseFilter interface.

  VCOCoRes := AMCrossbarInterface.QueryInterface( IID_IBaseFilter, Result );

  if Succeeded(VCOCoRes) then
    Exit;

  Result := nil;
end; // function TN_VideoCaptObj3.VCOGetCrossbarFilter

// ******************************* TN_VideoCaptObj3.VCOGetCrossbarFilterInfo ***
// Get Crossbar Filter Info (If Available)
//
function TN_VideoCaptObj3.VCOGetCrossbarFilterInfo(): Boolean;
var
  AMCrossbarInterface: IAMCrossbar;
begin
  VCOCoRes := VCOICaptGraphBuilder.FindInterface( @LOOK_UPSTREAM_ONLY, nil,
                    VCOIVideoCaptFilter, IID_IAMCrossbar, AMCrossbarInterface );
  if FAILED(VCOCoRes) or ( AMCrossbarInterface = nil ) then
    Result := False
  else
    Result := True;
end; // function TN_VideoCaptObj3.VCOGetCrossbarFilterInfo(): Boolean;

// **************************************** TN_VideoCaptObj3.VCOEnumFilters2 ***
// Enumerate all Filters in current Graph
// Improved version. Enumerates all filters in all branches of the graph.
//
// Parameters
// AStrings - TStrings where to collect info about Filters
//
procedure TN_VideoCaptObj3.VCOEnumFilters2( AStrings: TStrings );
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

    VCOEnumFilterPins(AStrings, CurFilter);
  end; // procedure OutFilterInfo(); // local

  function FillFilterInfo( AFilter: IBaseFilter ): TN_BaseFilterInfo; // local
  // Return Info about Filter in a TN_BaseFilterInfo formatted record
  var
    FilterInfo: TFilterInfo;
    PVendorStr: PWideChar;
  begin
    with Result do
    begin
      BFIFilter := AFilter;
      VCOCoRes := AFilter.QueryFilterInfo( FilterInfo );

      if Succeeded(VCOCoRes) then
        BFIName := FilterInfo.achName; // Filter Name

      VCOCoRes := AFilter.QueryVendorInfo( PVendorStr );
      if Succeeded(VCOCoRes) then
      begin
        BFIVendorStr := PVendorStr^;
        CoTaskMemFree( PVendorStr ); // free memory allocated in QueryVendorInfo
      end;
    end; // with Result do
  end; // function FillFilterInfo // local

begin // ************************** main body of TN_VideoCaptObj3.VCOEnumFilters2

  VCOIGraphBuilder.EnumFilters( FilterEnumerator );
  FilterEnumerator.Reset;

  while S_OK = FilterEnumerator.Next( 1, CurFilter, @NumberOfFiltersReceived )
                                                                              do
  begin
    MyFilterInfo := FillFilterInfo( CurFilter );
    OutFilterInfo;
  end;
end; // procedure TN_VideoCaptObj3.VCOEnumFilters2

// ************************************** TN_VideoCaptObj3.VCOEnumFilterPins ***
// Enumerate all Pins of given AFilter
//
// Parameters
// AStings - TStrings where to collect info about Pins
// AFilter - given Filter
//
procedure TN_VideoCaptObj3.VCOEnumFilterPins( AStrings: TStrings;
                                                         AFilter: IBaseFilter );
var
  PinsEnumerator:      IEnumPins;
  Pin, ExternalPin:    IPin;
  NumberOfPins, Count: Cardinal;
  PinInfo, ExternalPinInfo: TPinInfo;
  ExternalFilterInfo:  TFilterInfo;
begin
  if AFilter = nil then
    Exit;

  try
    AFilter.EnumPins( PinsEnumerator );
    PinsEnumerator.Reset;
    PinsEnumerator.Next( 1, Pin, @NumberOfPins );
    Count := 1;
    while NumberOfPins <> 0 do
    begin
      Pin.QueryPinInfo(PinInfo); // Ask for a PinInformation
      AStrings.Add( '    -Pin number ' + inttostr(Count) );
      AStrings.Add( '         -PinAchName: ' + PinInfo.achName );

      Case PinInfo.dir of
        PINDIR_INPUT:
          AStrings.Add( '         -PinDirection: IN' );
        PINDIR_OUTPUT:
          AStrings.Add( '         -PinDirection: OUT' );
      else
        AStrings.Add('         -PinDirection: Other ( ' + inttostr
                                                     (Ord(PinInfo.dir)) + ')' );
      end; // Case PinInfo.dir of

      // PinInfo.pFilter := nil;
      ExternalPin := nil;
      // Check the connection of the pin
      Pin.ConnectedTo( ExternalPin );

      if ExternalPin <> nil then
      begin
        // If connected, then we need to know, where to exactly
        ExternalPin.QueryPinInfo( ExternalPinInfo );
        ExternalPinInfo.pFilter.QueryFilterInfo( ExternalFilterInfo );
        AStrings.Add( '         -ConnectedTo: ' + ExternalFilterInfo.achName );
      end
      else // ExternalPin = nil
        AStrings.Add( '         -Not connected' );
      // CoTaskMemFree(@ExternalFilterInfo);
      ExternalPinInfo.pFilter := nil;
      PinsEnumerator.Next( 1, Pin, @NumberOfPins );
      Inc( Count );
    end; // while NumberOfPins<>0 do
  except
    // ShowMessage(AStrings.Text);
  end; // try .. except
end; // procedure TN_VideoCaptObj3.VCOEnumFilterPins

// **************************************** TN_VideoCaptObj3.VCOSetVideoSize ***
// Set given Video Capturing Size for current VCOIVideoCaptFilter
//
// Parameters
// AInpSizeStr - given new size as string (Width x Height) or '' if Size should not be changed
// ANewSize    - resulting Size (on output) for any given AInpSizeStr,
// ANewSize.X = -1 if error
//
// VCOIStreamConfig Interface is used and should be already OK.
// Because Stream should be temporary stopped VCORecordGraph is used and should be already OK
// Errors in range 70 - 75 are checked
//
procedure TN_VideoCaptObj3.VCOSetVideoSize( AInpSizeStr: string;
                                                         out ANewSize: TPoint );
var
  i, NumCaps, CapsSize: integer;
  Str:        string;
  GivenSize:  TPoint;
  VSCC:       TVideoStreamConfigCaps;
  PMediaType: PAMMediaType;
begin
  if VCOIError <> 0 then
    Exit; // a precaution

  ANewSize.X := -1; // error flag
  VCOIError := 70;
  VCOSError := 'VCOIStreamConfig = nil';
  if VCOIStreamConfig = nil then
    Exit; // a precaution

  // *** Find Capability with GivenSize and set it
  VCOCoRes := VCOIStreamConfig.GetNumberOfCapabilities( NumCaps, CapsSize );
  if VCOCheckRes(72) then
    Exit;
  if NumCaps = 0 then
    AInpSizeStr := ''; // for VFW interface
  if AInpSizeStr <> '' then // get Size from AInpSizeStr
  begin
    Str := AInpSizeStr;
    GivenSize.X := N_ScanInteger( Str );
    N_ScanToken( Str );
    GivenSize.Y := N_ScanInteger( Str );
  end
  else // AInpSizeStr = '', just get current Size and return it in ANewSize
  begin
    VCOCoRes := VCOIStreamConfig.GetFormat(PMediaType);
    if VCOCheckRes(71) then
      Exit;

    with PMediaType^ do
    begin
      with PVideoInfoHeader(pbFormat)^ do
      begin
        ANewSize.X := bmiHeader.biWidth;
        ANewSize.Y := abs( bmiHeader.biHeight );
      end; // with PVideoInfoHeader(pbFormat)^ do
    end; // with PMediaType^ do

    N_DSDeleteMediaType( PMediaType ); // delete MediaType record allocated by DirectShow
    VCOIError := 0;
    VCOSError := '';
    Exit; // all done for AInpSizeStr = ''
  end; // else // AInpSizeStr = '', just get current Size and return it in ANewSize

  VCODumpString( Format('VCO NumCaps=%d, GivenSize=%d,%d', [NumCaps,
                                                   GivenSize.X, GivenSize.Y]) );

  for i := 0 to NumCaps - 1 do // along all Stream capabilities
  begin
    VCOCoRes := VCOIStreamConfig.GetStreamCaps(i, PMediaType, VSCC);
    // get i-th Capability
    if VCOCheckRes(73) then
      Exit;

    with PMediaType^, PVideoInfoHeader(pbFormat)^.bmiHeader do
    begin

      if ( IsEqualGUID(VCONeededVideoCMST, NilGUID) or // any subtype is OK
        IsEqualGUID(VCONeededVideoCMST, subtype) ) and ( biWidth = GivenSize.X )
        and ( abs(biHeight) = GivenSize.Y ) then // GivenSize found,
      begin // set it and Exit
        VCOCurVideoCMST := subtype; // Current Video Capture Media SubType format
        VCOGetGraphState();

        if VCOGraphState = State_Running then
        begin
          N_i := VCOIMediaControl.Stop();
          N_i := VCOIStreamConfig.SetFormat( PMediaType^ );
          if VCORecordGraph then // "record to to file" mode, stop writing Stream if needed
            VCOControlStream([csfCapture, csfStop]);
          VCOCoRes := VCOIMediaControl.Run();
          VCOGetGraphState();
        end
        else
          VCOCoRes := VCOIStreamConfig.SetFormat( PMediaType^ );

        N_DSDeleteMediaType( PMediaType ); // delete MediaType record allocated by DirectShow before possible Exit
        if VCOCheckRes(74) then
          Exit; // Exit only after Deleting PMediaType!

        ANewSize := GivenSize;
        VCOIError := 0;
        VCOSError := '';
        Exit;
      end; // if IsEqualGUID(subtype, MEDIASUBTYPE_RGB24) and ...
    end; // with PMediaType^, PVideoInfoHeader(pbFormat)^.bmiHeader do

    N_DSDeleteMediaType( PMediaType ); // delete MediaType record allocated by DirectShow
  end; // for i := 0 to NumCaps-1 do // along all capabilities

  VCOIError := 75; // needed size was not found in available Capabilities!
  VCOSError := 'Needed Size not found';
end; // procedure TN_VideoCaptObj3.VCOSetVideoSize

// ****************************************** TN_VideoCaptObj3.VCOClearGraph ***
// Clear all Video Capturing Graph Filters and other objects
//
procedure TN_VideoCaptObj3.VCOClearGraph();
begin
  VCOIVideoProcAmp      := nil;
  VCOIStreamConfig      := nil;
  VCOISampleGrabber     := nil;

  VCOIAudioComprFilter  := nil;
  VCOIVideoComprFilter  := nil;
  //VCOIAudioCaptFilter := nil;
  //VCOIVideoCaptFilter := nil;
  VCOISampleGrabFilter  := nil;
  VCONullRendererFilter := nil;
  VCOInfTee := nil;

  //VCOIVideoWindow := nil;
  VCOIMediaControl      := nil;
  VCOISink              := nil;
  VCOIMux               := nil;
  VCOICaptGraphBuilder  := nil;
  VCOIGraphBuilder      := nil;

  VCOIConfigAviMux      := Nil;
  if Assigned( VCOIVideoWindow ) then
  begin
    // stop drawing in our window, or we may get wierd repaint effects
    VCOIVideoWindow.put_Owner( 0 );
    VCOIVideoWindow.put_Visible( False );
    VCOIVideoWindow := Nil;
  end;

  // destroy the graph downstream of our capture filters
  if Assigned(VCOIVideoCaptFilter) then
    VCONukeDownStream( VCOIVideoCaptFilter );

  if Assigned(VCOIAudioCaptFilter) then
    VCONukeDownStream( VCOIAudioCaptFilter );

{$IFDEF REGISTER_FILTERGRAPH}
  // Remove filter graph from the running object table
  if g_dwGraphRegister <> 0 then
  begin
    RemoveGraphFromRot( g_dwGraphRegister );
    g_dwGraphRegister := 0;
  end;
{$ENDIF}
  VCOPreviewFaked := False;

  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj3.VCOClearGraph

// ***************************************** TN_VideoCaptObj3.VCOMakeBuilder ***
// Needed to make Builder
//
function TN_VideoCaptObj3.VCOMakeBuilder: Boolean;
begin
  Result := True;
  // we have one already
  if Assigned(VCOICaptGraphBuilder) then
    Exit;

  VCOCoRes := CoCreateInstance( CLSID_CaptureGraphBuilder2, Nil, CLSCTX_INPROC,
                              IID_ICaptureGraphBuilder2, VCOICaptGraphBuilder );

  Result := VCOCoRes = NOERROR;
end; // function TN_VideoCaptObj3.VCOMakeBuilder : Boolean;

// ******************************************* TN_VideoCaptObj3.VCOMakeGraph ***
// Needed to make Graph
//
function TN_VideoCaptObj3.VCOMakeGraph: Boolean;
begin
  Result := True;
  // we have one already
  if Assigned(VCOIGraphBuilder) then
    Exit;

  VCOCoRes := CoCreateInstance( CLSID_FilterGraph, Nil, CLSCTX_INPROC,
                                          IID_IGraphBuilder, VCOIGraphBuilder );

  Result := VCOCoRes = NOERROR;
end;

// ********************************************************* DeleteMediaType ***
// Needed to delete Media Type
// Parameter:
// pmt - Media Type to Delete.
//
procedure DeleteMediaType(pmt: PAMMediaType);
begin
  if ( pmt^.cbFormat <> 0 ) then
  begin
    CoTaskMemFree(pmt^.pbFormat);
    // Strictly unnecessary but tidier
    pmt^.cbFormat := 0;
    pmt^.pbFormat := nil;
  end;
  if ( pmt^.pUnk <> nil ) then
    pmt^.pUnk := nil;
end;// procedure DeleteMediaType(pmt: PAMMediaType);

// ************************************** TN_VideoCaptObj3.VCOFreeCapFilters ***
// Needed to Free Caption Filters
//
procedure TN_VideoCaptObj3.VCOFreeCapFilters;
begin
  if Assigned(VCOIGraphBuilder) then
    VCOIGraphBuilder := Nil;

  If Assigned(VCOICaptGraphBuilder) then
    VCOICaptGraphBuilder := Nil;

  if Assigned(VCOIVideoCaptFilter) then
    VCOIVideoCaptFilter := Nil;

  if Assigned(VCOVmrFilter) then
    VCOVmrFilter := Nil;

  if Assigned(VCOIAudioCaptFilter) then
    VCOIAudioCaptFilter := Nil;

  if Assigned(VCOIStreamConfig) then
    VCOIStreamConfig := Nil;

  if Assigned(VCOIVideoCompression) then
    VCOIVideoCompression := Nil;

  if Assigned(VCODialogs) then
    VCODialogs := Nil;
end; // procedure TN_VideoCaptObj3.VCOFreeCapFilters;

// **************************************** TN_VideoCaptObj3.VCOGetVFWStatus ***
// Needed to get V4W status
//
function TN_VideoCaptObj3.VCOGetVFWStatus: Boolean;
var
  NumCaps, CapsSize: integer;
  Temp: HResult;
begin
  if VCOIStreamConfig <> nil then
  begin
    Temp := VCOIStreamConfig.GetNumberOfCapabilities( NumCaps, CapsSize );
    if FAILED(Temp) or ( NumCaps = 0 ) then
      Result := False
    else
      Result := True;
  end
  else
  begin
    VCODumpString( 'VCOIStreamConfig is missed.' );
    Result := False;
  end;
end; // function TN_VideoCaptObj3.VCOGetVFWStatus: boolean;

// ******************************** TN_VideoCaptObj3.VCOSetPreviewWindowSize ***
// Defining window size
//
// Used to have Resizable variable to enter the Full Screen Mode
//
// ******************************** TN_VideoCaptObj3.VCOSetPreviewWindowSize ***
// Defining window size
//
// Used to have Resizable variable to enter the Full Screen Mode
//
procedure TN_VideoCaptObj3.VCOSetPreviewWindowSize;
begin
  // if Resizable then
  // begin
   if VCOIVideoWindow.SetWindowPosition( VCOCurWindowRect.Left,
                                         VCOCurWindowRect.Top,
                            VCOCurWindowRect.Right  - VCOCurWindowRect.Left + 1,
                  VCOCurWindowRect.Bottom - VCOCurWindowRect.Top + 1)<>S_OK then
     VCODumpString('Something wrong in VCOIVideoWindow.SetWindowPosition.');
end; // procedure TN_VideoCaptObj3.VCOSetPreviewWindowSize;

// ************************************* TN_VideoCaptObj3.VCOPrepVideoWindow ***
// Prepare and Show VideoWindow
//
procedure TN_VideoCaptObj3.VCOPrepVideoWindow();
begin
  if VCOWindowHandle > 0 then // VCOWindowHandle is given
  begin
    // Window to control image
    VCOIVideoWindow := nil;
    VCOIGraphBuilder.QueryInterface( IID_IVideoWindow, VCOIVideoWindow );
    if VCOIVideoWindow <> nil then
    begin
      // Set window style
      VCOIVideoWindow.put_WindowStyle( WS_CHILD );
      if VCOIVideoWindow.put_Owner( VCOWindowHandle ) <> S_OK then
        VCODumpString( 'Something wrong in VCOIVideoWindow.put_Owner.' +
                      #13#10 + 'VCOWindowHandle=' + inttostr(VCOWindowHandle) );

      // Set window location
      VCOSetPreviewWindowSize;
      // Show window
      if VCOIVideoWindow.put_Visible( True ) <> S_OK then
        VCODumpString( 'Something wrong in VCOIVideoWindow.put_Visible.' );
    end // if VCOIVideoWindow <> nil then
    else
      VCODumpString( 'VCOIVideoWindow seems to be nil!' );
  end; // if VCOWindowHandle > 0 then // VCOWindowHandle is given

  // ***** No errors were checked
  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj3.VCOPrepVideoWindow

// ************************************ TN_VideoCaptObj3.VCOPrepRecordGraph2 ***
// Prepare and Run Video Capturing Graph for Recording Videos for Mode 2
//
procedure TN_VideoCaptObj3.VCOPrepRecordGraph2();
//var
//  WFileName: WideString;
Label SetupCaptureFail;
begin
  VCORecordGraph := True;
  VCOGrabGraph := False;

  if VCOICaptGraphBuilder = nil then
    VCOPrepInterfaces2();

  if VCOIError <> 0 then
    Exit;

  VCOIMux := nil;
  VCOISink := nil;

  VCOCoRes := VCOICaptGraphBuilder.SetOutputFileName
       ( MEDIASUBTYPE_Avi, @N_StringToWide(VCOFileName)[1], VCOIMux, VCOISink );

  if VCOCheckRes(23) then
    Exit;

  // Now tell the AVIMUX to write out AVI files that old apps can read properly.
  // If we don't, most apps won't be able to tell where the keyframes are,
  // slowing down editing considerably
  // Doing this will cause one seek (over the area the index will go) when
  // you capture past 1 Gig, but that's no big deal.
  // NOTE: This is on by default, so it's not necessary to turn it on

  // Also, set the proper MASTER STREAM

  VCOCoRes := VCOIMux.QueryInterface( IID_IConfigAviMux, VCOIConfigAviMux );
  if ( VCOCoRes = NOERROR ) and ( Assigned(VCOIConfigAviMux) ) then
  begin
    VCOIConfigAviMux.SetOutputCompatibilityIndex( True );
    if VCOCapAudio then
    begin
      VCOCoRes := VCOIConfigAviMux.SetMasterStream( VCOIMasterStream );
      if VCOCoRes <> NOERROR then
        ShowMessage( 'SetMasterStream failed!' );
    end;
  end;

  // Render the video capture and preview pins - even if the capture filter only
  // has a capture pin (and no preview pin) this should work... because the
  // capture graph builder will use a smart tee filter to provide both capture
  // and preview.  We don't have to worry.  It will just work.

  // NOTE that we try to render the interleaved pin before the video pin, because
  // if BOTH exist, it's a DV filter and the only way to get the audio is to use
  // the interleaved pin.  Using the Video pin on a DV filter is only useful if
  // you don't want the audio.

  VCOCoRes := VCOICaptGraphBuilder.RenderStream
      ( @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, VCOIVideoCaptFilter, Nil,
                                                                      VCOIMux );
  if VCOCoRes <> NOERROR then
  begin
    VCOCoRes := VCOICaptGraphBuilder.RenderStream
            ( @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, VCOIVideoCaptFilter, Nil,
                                                                      VCOIMux );
    if VCOCoRes <> NOERROR then
    begin
      ShowMessage( 'Cannot render video capture stream' );
      goto SetupCaptureFail;
    end;
  end;

  VCOCoRes := VCOICaptGraphBuilder.RenderStream
      ( @PIN_CATEGORY_PREVIEW, @MEDIATYPE_Interleaved, VCOIVideoCaptFilter, Nil,
                                                                          nil );
  if VCOCoRes = VFW_S_NOPREVIEWPIN then
  begin
    // preview was faked up for us using the (only) capture pin
    VCOPreviewFaked := True;
  end
  else if VCOCoRes <> S_OK then
  begin
    // maybe it's DV?
    VCOCoRes := VCOICaptGraphBuilder.RenderStream
     ( @PIN_CATEGORY_PREVIEW, @MEDIATYPE_Video, VCOIVideoCaptFilter, Nil, Nil );
    if VCOCoRes = VFW_S_NOPREVIEWPIN then
    begin
      // preview was faked up for us using the (only) capture pin
      VCOPreviewFaked := True;
    end
    else if VCOCoRes <> S_OK then
    begin
      ShowMessage('This graph cannot preview!');
    end;
  end;

  // Render the closed captioning pin? It could be a CC or a VBI category pin,
  // depending on the capture driver

  if VCOCapCC then
  begin
    VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_CC, Nil,
                                                VCOIVideoCaptFilter, Nil, Nil );
    if VCOCoRes <> NOERROR then
    begin
      VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_VBI, Nil,
                                                VCOIVideoCaptFilter, Nil, Nil );

      if VCOCoRes <> NOERROR then
      begin
        ShowMessage('Cannot render closed captioning');
        // so what? goto SetupCaptureFail;
      end;
    end;
  end;
{$IFDEF REGISTER_FILTERGRAPH}
  VCOCoRes := AddGraphToRot( VCOIGraphBuilder, g_dwGraphRegister );
  if FAILED(VCOCoRes) then
  begin
    ShowMessage( Format('Failed to register filter graph with ROT!  hr=0x%x',
                                                                  [VCOCoRes]) );
    g_dwGraphRegister := 0;
  end;
{$ENDIF}

  VCOPrepVideoWindow(); // no errors checked inside

  // *** Do not start Capture Stream when Graph would Run
  VCOControlStream( [csfCapture, csfStop] );
  if VCOIError > 0 then
    Exit;

  // *** Run Graph, Capture Stream would not Start
  VCOCoRes := VCOIMediaControl.Run();
  if VCOCheckRes(25) then
    Exit;

  // ***** RecordGraph Created OK and now in Run state
  VCOIError := 0;
  VCOSError := '';

  Exit;

SetupCaptureFail:
  VCOClearGraph;
end; // procedure TN_VideoCaptObj3.VCOPrepRecordGraph2

// *************************************** TN_VideoCaptObj3.VCONukeDownStream ***
// Destroy stream
//
// Parameter:
// pf - action Filter.
//
procedure TN_VideoCaptObj3.VCONukeDownStream( F: IBaseFilter );
var
  PP, PTo: IPin;
  U: Cardinal;
  Pins: IEnumPins;
  PinInfo: TPinInfo;
begin
  Pins := Nil;
  VCOCoRes := F.EnumPins( Pins );

  Pins.Reset;
  while ( VCOCoRes = NOERROR ) do
  begin
    VCOCoRes := Pins.Next( 1, PP, @U );
    if ( VCOCoRes = S_OK ) and ( Assigned(PP) ) then
    begin
      PP.ConnectedTo( PTo );
      if Assigned( PTo ) then
      begin
        VCOCoRes := PTo.QueryPinInfo( PinInfo );
        if VCOCoRes = NOERROR then
        begin
          if PinInfo.Dir = PINDIR_INPUT then
          begin
            VCONukeDownStream( PinInfo.PFilter );
            VCOIGraphBuilder.Disconnect( PTo );
            VCOIGraphBuilder.Disconnect( PP );
            VCOIGraphBuilder.RemoveFilter( PinInfo.PFilter );
          end;
          PinInfo.pFilter := Nil;
        end;
        PTo := Nil;
      end;
      PP := Nil;
    end;
  end;
  if Assigned( Pins ) then
    Pins := Nil;
end; // procedure TN_VideoCaptObj3.VCONukeDownStream( pf: IBaseFilter );

// *********************************************************** AddGraphToRot ***
//
// Adding graph to IRunningObjectTable
//
// Parameters:
// in: Graph - Graph name;
// out: ID <> 0.
//
function AddGraphToRot( Graph: IFilterGraph; out ID: integer ): HResult;
var
  Moniker: IMoniker;
  ROT: IRunningObjectTable;
  wsz: String;
begin
  Result := GetRunningObjectTable( 0, ROT );
  if (Result <> S_OK) then
    Exit;
  wsz := Format( 'FilterGraph %p pid %x',
                                      [Pointer(Graph), GetCurrentProcessId()] );
  Result := CreateItemMoniker( '!', StringToOleStr(wsz), Moniker );
  if ( Result <> S_OK ) then
    Exit;
  Result := ROT.Register( 0, Graph, Moniker, ID );
  Moniker := nil;
end;// function AddGraphToRot(Graph: IFilterGraph; out ID: integer): HResult;

// ****************************************************** RemoveGraphFromRot ***
// Removes graph from IRunningObjectTable
//
// Parameter:
// - Numeric ID <> 0 (from AddGraphToRot).
//
function RemoveGraphFromRot( ID: integer ): HResult;
var
  ROT: IRunningObjectTable;
begin
  Result := GetRunningObjectTable( 0, ROT );
  if ( Result <> S_OK ) then
    Exit;
  Result := ROT.Revoke( ID );
  ROT := nil;
end; // function RemoveGraphFromRot(ID: integer): HRESULT;

// ************************************** TN_VideoCaptObj3.VCOStartRecording ***
// Start Recording Video
//
procedure TN_VideoCaptObj3.VCOStartRecording();
//var
//  WFileName: string;
begin
  VCOIError := 80;
  VCOSError := 'Not a RecordGraph!';
  if not VCORecordGraph then
    Exit; // a precaution

  VCOControlStream( [csfCapture, csfStart] ); // Start Capture Stream
  if VCOIError <> 0 then
    Exit;

  // ***** Recording Started OK
  VCONowRecording := True;
  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj3.VCOStartRecording

// *************************************** TN_VideoCaptObj3.VCOStopRecording ***
// Stop Recording Video
//
// Parameters
// Result - Return Recorded File Name
//
function TN_VideoCaptObj3.VCOStopRecording(): string;
var
  WFileName: WideString;
begin
  Result := '';

  VCOIError := 83;
  VCOSError := 'Not a RecordGraph!';
  if not VCORecordGraph then
    Exit; // a precaution

  VCOIError := 84;
  VCOSError := 'Now not Recording!';
  if not VCONowRecording then
    Exit; // a precaution

  // *** Do not start Capture Stream when Graph would Run
  VCOControlStream( [csfCapture, csfStop] );
  if VCOIError <> 0 then
    Exit;

  // ***** Resulting avi File is OK
  Result := WFileName;
  VCONowRecording := False;
  VCOIError := 0;
  VCOSError := '';
end; // function TN_VideoCaptObj3.VCOStopRecording

// ****************************************** TN_VideoCaptObj3.VCOGrabSample ***
// Grab current Sample
//
// Parameters
// Result - Return Grabbed Sample as DIB Object
//
function TN_VideoCaptObj3.VCOGrabSample(): TN_DIBObj;
var
  BitsBufSize: integer;
  PDIB: TN_PDIBInfo;
  MediaType: TAMMediaType;
begin
  Result := nil;
  VCOIError := 60;
  VCOSError := 'VCOISampleGrabber = nil';
  if VCOISampleGrabber = nil then
    Exit; // a precaution

  // *** Get DIB Info and create empty DIB obj using it
  ZeroMemory( @MediaType, SizeOf(TAMMediaType) );

  VCOCoRes := VCOISampleGrabber.GetConnectedMediaType( MediaType );
  if VCOCheckRes(61) then
    Exit;

  PDIB := TN_PDIBInfo( @(PVideoInfoHeader(MediaType.pbFormat)^.bmiHeader) );

  if Assigned(N_BinaryDumpProcObj) then
  begin // Save DIBInfo dump for debug
    N_BinaryDumpProcObj( 'VCOGrab1', PDIB, PDIB^.bmi.biSize );
  end;

  Result := TN_DIBObj.Create();
  Result.PrepEmptyDIBObj( PDIB );

  // *** Get DIB Content (Sample bits) in

  BitsBufSize := Result.DIBInfo.bmi.biSizeImage;

  // *** Get BufSize for Sample content for debug
  N_i := 0;
  VCOCoRes := VCOISampleGrabber.GetCurrentBuffer( N_i, nil );
  if ( N_i <= 0 ) or VCOCheckRes(62) then
    Exit;

  N_i := VCOISampleGrabber.GetCurrentBuffer( BitsBufSize, Result.PRasterBytes );

  if Assigned(N_BinaryDumpProcObj) then
  begin // Save RasterBytes dump for debug
    N_BinaryDumpProcObj( 'VCOGrab2', Result.PRasterBytes,
                                                        PDIB^.bmi.biSizeImage );
  end;

  // ***** All Objects Ctreated OK
  VCOIError := 0;
  VCOSError := '';
end; // function TN_VideoCaptObj3.VCOGrabSample

// ************************************ TN_VideoCaptObj3.VCOShowFilterDialog ***
// Show given Filter Properties Dialog, provided by installed Driver
//
// Parameters
// AIFilter      - given Filter (or Pin)
// AWindowHandle - any Windows Window Handle (Dialog Owner?)
//
procedure TN_VideoCaptObj3.VCOShowFilterDialog( AIFilter: IBaseFilter;
                                                       AWindowHandle: THandle );
var
  // CoRes: HResult;
  WindowCaption: WideString;
  PropertyPages: ISpecifyPropertyPages;
  Pages:         CAUUID;
  FilterInfo:    TFilterInfo;
  pfilterUnk:    IUnknown;
begin
  VCOIError := 40;
  if AIFilter = nil then
    Exit;

  // Get properties
  VCOCoRes := AIFilter.QueryInterface( ISpecifyPropertyPages, PropertyPages );

  VCOIError := 41;
  if FAILED(VCOCoRes) then
    Exit;

  // *** PropertyPages Interface exists

  // Get Filter info
  AIFilter.QueryFilterInfo( FilterInfo );
  AIFilter.QueryInterface( IUnknown, pfilterUnk );

  // Get properties array
  PropertyPages.GetPages( Pages );
  PropertyPages := nil;

  // Show modal form
  WindowCaption := VCOVCaptDevName + ' (2)';
  // 'Properties' token will be added!
  OleCreatePropertyFrame( AWindowHandle, 0, 0, PWideChar(WindowCaption), 1,
                           @pfilterUnk, Pages.cElems, Pages.pElems, 0, 0, nil );

  // Clean
  pfilterUnk := nil;
  FilterInfo.pGraph := nil;

  CoTaskMemFree( Pages.pElems );
  VCOIError := 0;
end; // procedure TN_VideoCaptObj3.VCOShowFilterDialog

// ************************************ TN_VideoCaptObj3.VCOShowStreamDialog ***
// Show StreamConfig Properties Dialog, provided by installed Driver
//
// Parameters
// AWindowHandle - any Windows Window Handle (Dialog Owner?)
//
procedure TN_VideoCaptObj3.VCOShowStreamDialog( AWindowHandle: THandle );
var
  CoRes:         HResult;
  WindowCaption: WideString;
  StreamConfig:  IAMStreamConfig;
  PropertyPages: ISpecifyPropertyPages;
  Pages:         CAUUID;
begin
  VCOIError := 44;
  if VCOIVideoCaptFilter = nil then
    Exit;

  VCOIMediaControl.Stop(); // Stop graph
  if VCOCheckRes( 190 ) then
    Exit;

  try
    // Find media format
    CoRes := VCOICaptGraphBuilder.FindInterface
                 ( @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, VCOIVideoCaptFilter,
                                            IID_IAMStreamConfig, StreamConfig );

    if Succeeded(CoRes) then // Interface StreamConfig found
    begin
      // Find properties
      CoRes := StreamConfig.QueryInterface
                                       ( ISpecifyPropertyPages, PropertyPages );

      if Succeeded(CoRes) then // Interface PropertyPages found
      begin
        // Properties array
        PropertyPages.GetPages( Pages );
        PropertyPages := nil;

        // Show modal form
        WindowCaption := VCOVCaptDevName + ' (1)';
        // 'Properties' token will be added!
        OleCreatePropertyFrame( AWindowHandle, 0, 0, PWideChar(WindowCaption),
                      1, @StreamConfig, Pages.cElems, Pages.pElems, 0, 0, nil );

        // Clean
        StreamConfig := nil;
        CoTaskMemFree (Pages.pElems );
      end; // if SUCCEEDED(CoRes) then // Interface PropertyPages found
    end; // if SUCCEEDED(CoRes) then // Interface StreamConfig found

  finally
    // Run graph
    VCOIMediaControl.Run;
  end;

  VCOIError := 0;
end; // procedure TN_VideoCaptObj3.VCOShowStreamDialog

// *************************************** TN_VideoCaptObj3.VCOControlStream ***
// Control Capture or Preview Stream
//
// Parameters
// AFlags - Control Stream Flags (csfPreview, csfCapture, csfStart, csfStop)
//
procedure TN_VideoCaptObj3.VCOControlStream( AFlags: TN_ControlStreamFlags );
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
    tStop := N_MAXLONGLONG;
  end
  else // csfStop
  begin
    tStart := N_MAXLONGLONG;
    tStop := 0;
  end;

  VCOCoRes := VCOICaptGraphBuilder.ControlStream( pCategory, @MEDIATYPE_Video,
                               VCOIVideoCaptFilter, @tStart, @tStop, 123, 124 );
  if VCOCheckRes(50) then
    Exit;
  {end;  }
     // Sleep(2500);
  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj3.VCOControlStream


// *************************  Global Procedures  ***************

// ******************************************************* N_DSFreeMediaType ***
// Free Objects in given AMMediaType record, created inside DirectShow
//
// Parameters
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

// ***************************************************** N_DSDeleteMediaType ***
// Delete given AMMediaType record, created inside DirectShow
//
// Parameters
// APMediaType - Pointer to given AMMediaType record
//
procedure N_DSDeleteMediaType( APMediaType: PAMMediaType );
begin
  N_DSFreeMediaType( APMediaType );
  CoTaskMemFree( APMediaType );
end; // procedure N_DSDeleteMediaType

// ******************************************************* N_GetDSErrorDescr ***
// Convert given ACoRes into string
//
// Parameters
// ACoRes - given HResult
// Result - Return string with description of given ACoRes
//
function N_GetDSErrorDescr( ACoRes: HResult ): string;
var
  IRes: integer;
begin
  SetLength( Result, 200 );
  IRes := AMGetErrorTextW( ACoRes, PWideChar(@Result[1]), Length(Result) );
  if IRes = 0 then // error in AMGetErrorText
    Result := Format( 'Unknown DirectShow Error! CoRes=%X', [ACoRes] )
  else
    SetLength( Result, IRes );
end; // function N_GetDSErrorDescr

// ********************************************************* N_DSEnumFilters ***
// Enumerate or find needed DirectShow Filter
//
// Parameters
// clsidDeviceClass - needed Filters (Devices) Class
// DevName          - Filter (Device) Name or '' if not needed
// DevList          - Filters (Devices) Names List if given or nil
// AErrCode         - own integer Error code (1,2) or 0 if OK
// Result           - Return Found Filter (device) or
// nil if (DevName = '') and (DevList <> nil)
//
// If (DevName <> '') and (DevList = nil)  - find and return needed Filter (Device)
// If (DevName = '')  and (DevList <> nil) - collect Filter Frendly Names in DevList
// If (DevName = '')  and (DevList = nil)  - return first available Filter (Device)
//
function N_DSEnumFilters( const clsidDeviceClass: TGUID; ADevName: string;
                  ADevNamesList: TStrings; out AErrCode: integer ): IBaseFilter;
var
  hr:           HResult;
  DeviceNameObj: OleVariant;
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

    pMoniker := nil;
    pFilter  := nil;
    PropertyName := nil;
    pDevEnum := nil;
    pEnum    := nil;
  end; // procedure FreeObjects(); // local

begin
  FreeObjects();
  Result := nil;
  AErrCode := 0;
  if ADevNamesList <> nil then
    ADevNamesList.Clear;

  // Find devices
  hr := CoCreateInstance( CLSID_SystemDeviceEnum, nil, CLSCTX_INPROC_SERVER,
                                                 IID_ICreateDevEnum, pDevEnum );
  AErrCode := 1; // CoCreateInstance(CLSID_SystemDeviceEnum, ... failed
  if FAILED(hr) then
    goto SomeError;

  // Find devices categories
  hr := pDevEnum.CreateClassEnumerator( clsidDeviceClass, pEnum, 0 );
  AErrCode := 2; // CreateClassEnumerator(clsidDeviceClass, ... failed
  if FAILED(hr) then
    goto SomeError;

  AErrCode := 0;

  if pEnum = nil then // no needed devices
  begin
    FreeObjects();
    Exit;
  end; // if pEnum = nil then // no needed devices

  while (S_OK = pEnum.Next( 1, pMoniker, Nil )) do // Цикл по устройствам
  begin
    // If devices names needed
    if ADevNamesList <> nil then
    begin
      // Get properties
      hr := pMoniker.BindToStorage( Nil, Nil, IPropertyBag, PropertyName );
      if FAILED(hr) then
        Continue;

      // Get property
      hr := PropertyName.Read( 'FriendlyName', DeviceNameObj, Nil );
      if FAILED(hr) then
        Continue;

      // Add device name to list
      ADevNamesList.Add( DeviceNameObj );
    end
    else // ADevNamesList = nil
    begin
      if ADevName <> '' then // ADevName is given
      begin
        // Get properties
        hr := pMoniker.BindToStorage( Nil, Nil, IPropertyBag, PropertyName );
        if FAILED(hr) then
          Continue;

        // Get property
        hr := PropertyName.Read( 'FriendlyName', DeviceNameObj, Nil );
        if FAILED(hr) then
          Continue;

        // Find the match name
        if ( DeviceNameObj <> ADevName ) then
          Continue;
      end; // if ADevName <> '' then // ADevName is given

      // ***** not needed Nil may be used instead of pbc
      pbc := nil;
      hr := CreateBindCtx( 0, pbc );
      N_s := N_GetDSErrorDescr(hr);
      hr := pMoniker.BindToObject( pbc, Nil, IID_IBaseFilter, pFilter );

      // hr := pMoniker.BindToObject( nil, nil, IID_IBaseFilter, pFilter );

      if Succeeded(hr) then // pFilter is OK
      begin
        // Interface as a result
        Result := pFilter;
        FreeObjects();
        Exit;
      end; // if SUCCEEDED(hr) then // pFilter is OK
    end; // else // DevList = nil
  end; // while (S_OK = pEnum.Next(1, pMoniker, nil)) do

  FreeObjects();
  Exit;

SomeError : // ****************
  N_DSErrorString := N_GetDSErrorDescr(hr);
  FreeObjects();
end; // function N_DSEnumFilters

// ******************************************************** N_DSGetAnyFilter ***
// Get needed DirectShow Filter using Filter Names in MemIni file
//
// Parameters
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
  NeededNames := TStringList.Create;

  Result := nil;
  N_DSEnumFilters( clsidDeviceClass, '', AvailableNames, AErrCode );
  AFilterName := N_NotUsedStr;
  if AErrCode > 0 then
    Exit;

  N_MemIniToStrings( ASectionName, NeededNames ); // retrive NeededNames

  for i := 0 to NeededNames.Count - 1 do // along all NeededNames
  begin
    if NeededNames[i] = N_NotUsedStr then
      goto Fin; // needed Result is nil

    if AvailableNames.IndexOf( NeededNames[i] ) >= 0 then
    // NeededNames[i] is available
    begin
      Result := N_DSEnumFilters( clsidDeviceClass, NeededNames[i], nil,
                                                                     AErrCode );
      if ( AErrCode > 0 ) or ( Result = nil ) then
        Continue; // a precaution

      AFilterName := NeededNames[i];
      N_Dump2Str( 'Compression filter at the moment: ' + AFilterName );
      goto Fin;
    end;
  end; // for i := 0 to NeededNames.Count-1 do // along all NeededNames

  // ***** Here: all Needed Names are not available!

  Result := nil;
  AErrCode := 5;

Fin : // ***********************
  NeededNames.Free;
  AvailableNames.Free;
end; // function N_DSGetAnyFilter

// ***************************************************** N_DSEnumVideoSizes2 ***
// N_DSEnumVideoSizes with VCO.VCOPrepInterfaces2();
//
// Parameters
// ADevName - given Video Capturing Device Name (retrieved by N_DSEnumFilters)
// AResList - TStrings with ordered resulting Video Capturing Sizes
//
// Video Capturing Sizes are collected and ordered in AVideoSizes as strings
// in 'Width x Height' ('%4d x %d') format
//
procedure N_DSEnumVideoSizes2( ADevName: string; AResList: TStrings );
var
  VCO: TN_VideoCaptObj3;
begin
  VCO := TN_VideoCaptObj3.Create;

  VCO.VCOVCaptDevName := ADevName;

  VCO.VCOPrepInterfaces2();

  if VCO.VCOIError = 0 then
    VCO.VCOEnumVideoSizes( AResList )
  else
    AResList.Clear;

  VCO.Free;
end; // procedure N_DSEnumVideoSizes2

// ****************************************************** N_DSEnumVideoCaps2 ***
// N_DSEnumVideoCaps with VCO.VCOPrepInterfaces2();
//
// Parameters
// ADevName - given Video Capturing Device Name (retrieved by N_DSEnumFilters)
// AResList - TStrings with resulting Video Capturing Capabilities
//
// Video Capturing Sizes are collected and ordered in AVideoSizes as strings
// in 'Width x Height' ('%d x %d') fromat
//
procedure N_DSEnumVideoCaps2( ADevName: string; AResList: TStrings );
var
  VCO: TN_VideoCaptObj3;
begin
  VCO := TN_VideoCaptObj3.Create;

  VCO.VCOVCaptDevName := ADevName;
  VCO.VCOPrepInterfaces2();

  if VCO.VCOIError = 0 then
    VCO.VCOEnumVideoCaps( AResList )
  else
  begin
    AResList.Clear;
    AResList.Add( Format('VCO Error %d, %s', [VCO.VCOIError, VCO.VCOSError]) );
  end;

  VCO.Free;
end; // procedure N_DSEnumVideoCaps2

// ****************************************************** N_DSEnumVideoSizes ***
// Enumerate Video Capturing Sizes for given ADevName
//
// Parameters
// ADevName - given Video Capturing Device Name (retrieved by N_DSEnumFilters)
// AResList - TStrings with ordered resulting Video Capturing Sizes
//
// Video Capturing Sizes are collected and ordered in AVideoSizes as strings
// in 'Width x Height' ('%4d x %d') format
//
function N_GetGUIDName( const AGUID: TGUID ): string;
begin
  if IsEqualGUID(AGUID, FORMAT_None) then
    Result := 'FORMAT_None'
  else if IsEqualGUID(AGUID, FORMAT_VideoInfo) then
    Result := 'FORMAT_VideoInfo'
  else if IsEqualGUID(AGUID, FORMAT_VideoInfo2) then
    Result := 'FORMAT_VideoInfo2'
  else if IsEqualGUID(AGUID, FORMAT_WaveFormatEx) then
    Result := 'FORMAT_WaveFormatEx'
  else if IsEqualGUID(AGUID, FORMAT_MPEGVideo) then
    Result := 'FORMAT_MPEGVideo'
  else if IsEqualGUID(AGUID, FORMAT_MPEGStreams) then
    Result := 'FORMAT_MPEGStreams'
  else if IsEqualGUID(AGUID, FORMAT_DvInfo) then
    Result := 'FORMAT_DvInfo'

  else if IsEqualGUID(AGUID, MEDIASUBTYPE_RGB8) then
    Result := 'MEDIASUBTYPE_RGB8'
  else if IsEqualGUID(AGUID, MEDIASUBTYPE_RGB24) then
    Result := 'MEDIASUBTYPE_RGB24'
  else if IsEqualGUID(AGUID, MEDIASUBTYPE_RGB32) then
    Result := 'MEDIASUBTYPE_RGB32'
  else if IsEqualGUID(AGUID, MEDIASUBTYPE_ARGB32) then
    Result := 'MEDIASUBTYPE_ARGB32'
  else if IsEqualGUID(AGUID, MEDIASUBTYPE_YUY2) then
    Result := 'MEDIASUBTYPE_YUY2'
  else if IsEqualGUID(AGUID, MEDIASUBTYPE_Y41P) then
    Result := 'MEDIASUBTYPE_Y41P'
  else if IsEqualGUID(AGUID, MEDIASUBTYPE_I420) then
    Result := 'MEDIASUBTYPE_I420'
  else if IsEqualGUID(AGUID, MEDIASUBTYPE_PCM) then
    Result := 'MEDIASUBTYPE_PCM'
  else if IsEqualGUID(AGUID, WMMEDIASUBTYPE_WMV1) then
    Result := 'WMMEDIASUBTYPE_WMV1'
  else if IsEqualGUID(AGUID, WMMEDIASUBTYPE_WMV2) then
    Result := 'WMMEDIASUBTYPE_WMV2'
  else if IsEqualGUID(AGUID, WMMEDIASUBTYPE_WMV3) then
    Result := 'WMMEDIASUBTYPE_WMV3'

  else if IsEqualGUID(AGUID, MEDIATYPE_Video) then
    Result := 'MEDIATYPE_Video'
  else if IsEqualGUID(AGUID, MEDIATYPE_Audio) then
    Result := 'MEDIATYPE_Audio'
  else if IsEqualGUID(AGUID, MEDIATYPE_Midi) then
    Result := 'MEDIATYPE_Midi'
  else if IsEqualGUID(AGUID, MEDIATYPE_Stream) then
    Result := 'MEDIATYPE_Stream'
  else if IsEqualGUID(AGUID, MEDIATYPE_File) then
    Result := 'MEDIATYPE_File'

  else // Unknown GUID
    Result := GUIDToString(AGUID);
end; // function N_GetGUIDName

// ****************************************************** VCOPrepInterfaces2 ***
//
// VCOPrepInterfaces for Mode 2
//
procedure TN_VideoCaptObj3.VCOPrepInterfaces2();
var
  UnitsPerFrame: integer;
  Bag:           IPropertyBag;
  Name:          OleVariant;
  F:             Boolean;
  Temp:          PWideChar;
  Pin:           IPin;
  CreateDevEnum: ICreateDevEnum;
  Em:            IEnumMoniker;
  Fetched:       LongInt;
  M:             IMoniker;
Label InitCapFiltersFail, SkipAudio;
begin // Create device enumerator
  VCOCoRes := CoCreateInstance( CLSID_SystemDeviceEnum, Nil,
                      CLSCTX_INPROC_SERVER, IID_ICreateDevEnum, CreateDevEnum );
  if ( VCOCoRes <> NOERROR ) then
  begin
    ShowMessage( 'Error Creating Device Enumerator' );
    Exit;
  end;

  // Search for needed device
  VCOCoRes := CreateDevEnum.CreateClassEnumerator
                                      ( CLSID_VideoInputDeviceCategory, Em, 0 );
  if ( VCOCoRes <> NOERROR ) then
  begin
    ShowMessage( 'Sorry, you have no video capture hardware' );
    Exit;
  end;
  if Assigned(Em) then
    Em.Reset
  else
    Exit;
  while ( Em.Next(1, M, @Fetched) = S_OK ) do
  begin
    VCOCoRes := M.BindToStorage( Nil, Nil, IPropertyBag, Bag );
    if (Succeeded(VCOCoRes)) then
    begin
      VCOCoRes := Bag.Read( 'FriendlyName', Name, Nil );
      if (VCOCoRes = NOERROR) then
      begin
        if ( Name = VCOVCaptDevName ) then
          VCOVideoMoniker := M;
      end;
      Bag := Nil;
    end;
    M := Nil;
  end;
  Em := Nil;

  if VCOCapAudio then
  begin

    VCOCoRes := CreateDevEnum.CreateClassEnumerator
                                      ( CLSID_AudioInputDeviceCategory, Em, 0 );
    if ( VCOCoRes <> NOERROR ) then
      Exit;

    // Now for audio device
    Em.Reset;
    while ( Em.Next(1, M, @Fetched) = S_OK ) do
    begin
      Bag := Nil;
      VCOCoRes := M.BindToStorage( Nil, Nil, IPropertyBag, Bag );
      if ( Succeeded(VCOCoRes) ) then
      begin
        VCOCoRes := Bag.Read( 'FriendlyName', Name, Nil );
        if ( VCOCoRes = NOERROR ) then
        begin
          VCOAudioMoniker := M;
        end;
        Bag := Nil;
      end;
      M := Nil;
    end;
    Em := Nil;

  end;

  // do we want closed Captioning?
  VCOCapCC := False;

  // do we want to use entered frame rate?
  VCOUseFrameRate := True;
  UnitsPerFrame := 666667; // 15fps
  VCOFrameRate := 10000000. / UnitsPerFrame;
  VCOFrameRate := (VCOFrameRate * 100) / 100.;

  // reasonable default
  if VCOFrameRate <= 0. then
    VCOFrameRate := 15.0;

  // ***** Create VCOIGraphBuilder - Object for constructing Filter Graph
  VCOIGraphBuilder := nil;
  VCOCoRes := CoCreateInstance( CLSID_FilterGraph, nil, CLSCTX_INPROC_SERVER,
                                          IID_IGraphBuilder, VCOIGraphBuilder );

  if VCOCheckRes(1) then
    Exit; // This error means that DirectShow is not installed

  // ***** Create VCOICaptGraphBuilder - Object for constructing Capturing Filter Graph
  VCOICaptGraphBuilder := nil;
  VCOCoRes := CoCreateInstance( CLSID_CaptureGraphBuilder2, nil,
        CLSCTX_INPROC_SERVER, IID_ICaptureGraphBuilder2, VCOICaptGraphBuilder );

  if VCOCheckRes(2) then
    Exit;

  // Find first filter from the device
  VCOIVideoCaptFilter := Nil;
  if ( VCOVideoMoniker <> Nil ) then
  Begin
    VCOWachFriendlyName := '';
    VCOCoRes := VCOVideoMoniker.BindToStorage( Nil, Nil, IPropertyBag, Bag );
    if Succeeded(VCOCoRes) then
    Begin
      VCOCoRes := Bag.Read( 'FriendlyName', Name, Nil );
      if VCOCoRes = NOERROR then
      Begin
        VCOWachFriendlyName := Name;
      End;
      Bag := Nil;
    End;
    VCOCoRes := VCOVideoMoniker.BindToObject( Nil, Nil, IID_IBaseFilter,
                                                          VCOIVideoCaptFilter );
    if VCOCoRes <> NOERROR then
      Exit;
  End;

  // Create graph and set first filter from the device
  f := VCOMakeGraph;
  if Not f then
  Begin
    ShowMessage( 'Cannot instantiate filtergraph' );
    goto InitCapFiltersFail;
  End;

  VCOCoRes := VCOICaptGraphBuilder.SetFiltergraph( VCOIGraphBuilder );
  if VCOCoRes <> NOERROR then
  Begin
    ShowMessage('Cannot give graph to builder');
    goto InitCapFiltersFail;
  End;
  GetMem( Temp, SizeOf(WideChar) * Succ(Length(VCOWachFriendlyName)) );
  StringToWideChar( VCOWachFriendlyName, Temp, Succ(Length(VCOWachFriendlyName))
                                                                              );
  // Temp := gcap.wachFriendlyName;
  VCOCoRes := VCOIGraphBuilder.AddFilter( VCOIVideoCaptFilter, Temp );
  if VCOCoRes <> NOERROR then
  Begin
    ShowMessage( Format('Error %x: Cannot add vidcap to filtergraph',
                                                                  [VCOCoRes]) );
    goto InitCapFiltersFail;
  End;

  // ***** get VCOIMediaControl Interface for controlling media streams
  VCOIMediaControl := nil;
  VCOCoRes := VCOIGraphBuilder.QueryInterface(IID_IMediaControl,
    VCOIMediaControl);

  if VCOCheckRes(15) then
    Exit; // Errors 13, 14 not used now

  // ***** get VCOIStreamConfig Interface to get/set Video Format and Size
  VCOIStreamConfig := nil;
  N_Dump2Str( 'VCOCaptPin=' + IntToStr(VCOCaptPin) );

  VCOCoRes := VCOICaptGraphBuilder.FindInterface
           ( @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, VCOIVideoCaptFilter,
                                IID_IAMVideoCompression, VCOIVideoCompression );
  if VCOCoRes <> S_OK then
    VCOICaptGraphBuilder.FindInterface( @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video,
           VCOIVideoCaptFilter, IID_IAMVideoCompression, VCOIVideoCompression );

  // !!! What if this interface isn't supported?
  // we use this interface to set the frame rate and get the capture size
  VCOCoRes := VCOICaptGraphBuilder.FindInterface
           ( @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, VCOIVideoCaptFilter,
                                        IID_IAMStreamConfig, VCOIStreamConfig );
  if VCOCoRes <> NOERROR then
  begin
    VCOCoRes := VCOICaptGraphBuilder.FindInterface
                 ( @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, VCOIVideoCaptFilter,
                                        IID_IAMStreamConfig, VCOIStreamConfig );
    if VCOCoRes <> NOERROR then // this means we can't set frame rate (non-DV only)
      ShowMessage( Format('Error %x: Cannot find VCapture:IAMStreamConfig',
                                                                  [VCOCoRes]) );
  end;

  VCOCapAudioIsRelevant := True;

  // we use this interface to bring up the 3 dialogs
  // NOTE:  Only the VfW capture filter supports this.  This app only brings
  // up dialogs for legacy VfW capture drivers, since only those have dialogs
  VCOICaptGraphBuilder.FindInterface( @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video,
                    VCOIVideoCaptFilter, IID_IAMVfwCaptureDialogs, VCODialogs );

  // there's no point making an audio capture filter
  if Not VCOCapAudioIsRelevant then
    goto SkipAudio;

  // create the audio capture filter, even if we are not capturing audio right
  // now, so we have all the filters around all the time.

  //
  // We want an audio capture filter and some interfaces
  //

  if VCOCapAudio then
  begin

    if VCOAudioMoniker = Nil then
    Begin
      // there are no audio capture devices. We'll only allow video capture
      VCOCapAudio := False;
      goto SkipAudio;
    End;

    VCOIAudioCaptFilter := Nil;

    VCOAudioMoniker.BindToObject( Nil, Nil, IID_IBaseFilter,
                                                          VCOIAudioCaptFilter );

    if VCOIAudioCaptFilter = Nil then
    begin
      // there are no audio capture devices. We'll only allow video capture
      VCOCapAudio := False;
      ShowMessage( 'Cannot create audio capture filter' );
      goto SkipAudio;
    end;

    //
    // put the audio capture filter in the graph
    //

    // We'll need this in the graph to get audio property pages
    VCOCoRes := VCOIGraphBuilder.AddFilter( VCOIAudioCaptFilter, Nil );
    if VCOCoRes <> NOERROR then
    begin
      ShowMessage( Format('Error %x: Cannot add audcap to filtergraph',
                                                                  [VCOCoRes]) );
      goto InitCapFiltersFail;
    end;

  end;

    Exit;

SkipAudio :

  // Can this filter do closed captioning?
  VCOCoRes := VCOICaptGraphBuilder.FindPin( VCOIVideoCaptFilter, PINDIR_OUTPUT,
                                        @PIN_CATEGORY_VBI, Nil, False, 0, Pin );

  if VCOCoRes <> S_OK then
    VCOCoRes := VCOICaptGraphBuilder.FindPin
          ( VCOIVideoCaptFilter, PINDIR_OUTPUT, @PIN_CATEGORY_CC, Nil, False, 0,
                                                                          Pin );

  if VCOCoRes = S_OK then
  begin
    Pin := Nil;
    VCOCCAvail := True;
  end
  else
    VCOCapCC := False; // can't capture it, then

  Exit;

  InitCapFiltersFail:

  VCOFreeCapFilters;

  // ***** get VCOIVideoProcAmp Interface, may not work
  VCOIVideoProcAmp := nil;
  // VCOCoRes := VCOIVideoCaptFilter.QueryInterface( IID_IAMVideoProcAmp, VCOIVideoProcAmp );
  // we dont check the result here, the reason: fail is normal on old drivers
  VCOCoRes := S_OK;

  // ***** All Objects Created OK
  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj3.VCOPrepInterfaces2

// ******************************************************* VCOPrepGrabGraph3 ***
//
// VCOPrepGrabGraph for Mode 2
//
procedure TN_VideoCaptObj3.VCOPrepGrabGraph3();
var
  MediaType: TAMMediaType;
begin
  // Create Sample Grabber Filter
  VCOISampleGrabFilter := Nil;
  VCONullRendererFilter := Nil;

  VCOCoRes := CoCreateInstance( CLSID_SampleGrabber, Nil, CLSCTX_INPROC_SERVER,
                                        IID_IBaseFilter, VCOISampleGrabFilter );
  if VCOCheckRes(30) then
    Exit;
  // get ISampleGrabber Interface
  VCOISampleGrabber := nil;
  VCOCoRes := VCOISampleGrabFilter.QueryInterface( IID_ISampleGrabber,
                                                            VCOISampleGrabber );

  if VCOCheckRes(31) or ( VCOISampleGrabber = Nil ) then
    Exit;

  // add VCOISampleGrabFilter to Filter Graph
  VCOCoRes := VCOIGraphBuilder.AddFilter
                                     ( VCOISampleGrabFilter, 'Sample Grabber' );

  if VCOCheckRes(32) then
    Exit;

  // Get and Add Null Renderer Filter (to discard frames which passed SampleGrabber)
  VCOCoRes := CoCreateInstance( CLSID_NullRenderer, NIL, CLSCTX_INPROC_SERVER,
                                       IID_IBaseFilter, VCONullRendererFilter );
  if VCOCheckRes(555) then
    Exit;
  VCOCoRes := VCOIGraphBuilder.AddFilter
                                     ( VCONullRendererFilter, 'Null Renderer' );

  if VCOCheckRes(556) then
    Exit;

  // *** Set Data Format for VCOISampleGrabber

  ZeroMemory( @MediaType, SizeOf(TAMMediaType) );

  with MediaType do
  begin
    MajorType  := MEDIATYPE_Video;
    SubType    := MEDIASUBTYPE_RGB24;
    FormatType := FORMAT_VideoInfo;
  end; // with MediaType do

  VCOCoRes := VCOISampleGrabber.SetMediaType( MediaType );

  if VCOCheckRes(33) then
    Exit;

  // Set buffering (not callback) mode for ISampleGrabber
  VCOCoRes := VCOISampleGrabber.SetBufferSamples( True );

  if VCOCheckRes(34) then
    Exit;

  // Do not stop Graph on grbbing first Sample
  VCOCoRes := VCOISampleGrabber.SetOneShot( False );

  if VCOCheckRes(35) then
    Exit;

  VCOCoRes := VCOICaptGraphBuilder.RenderStream
                 ( @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, VCOIVideoCaptFilter,
                                  VCOISampleGrabFilter, VCONullRendererFilter );
  if VCOCheckRes(558) then
    Exit;

  VCORecordGraph := False;
  VCOGrabGraph   := True;

  VCOCoRes := VCOICaptGraphBuilder.RenderStream
      ( @PIN_CATEGORY_PREVIEW, @MEDIATYPE_Interleaved, VCOIVideoCaptFilter, Nil,
                                                                          nil );
  if VCOCoRes = VFW_S_NOPREVIEWPIN then
  begin
    // preview was faked up for us using the (only) capture pin
    VCOPreviewFaked := True;
  end
  else if VCOCoRes <> S_OK then
  begin
    // maybe it's DV?
    VCOCoRes := VCOICaptGraphBuilder.RenderStream
     ( @PIN_CATEGORY_PREVIEW, @MEDIATYPE_Video, VCOIVideoCaptFilter, Nil, Nil );
    if VCOCoRes = VFW_S_NOPREVIEWPIN then
    begin
      // preview was faked up for us using the (only) capture pin
      VCOPreviewFaked := True;
    end
    else if VCOCoRes <> S_OK then
    begin
      ShowMessage( 'This graph cannot preview!' );
    end;
  end;

  // Render the closed captioning pin? It could be a CC or a VBI category pin,
  // depending on the capture driver

  if VCOCapCC then
  begin
    VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_CC, Nil,
                                                VCOIVideoCaptFilter, Nil, Nil );
    if VCOCoRes <> NOERROR then
    begin
      VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_VBI, Nil,
                                                VCOIVideoCaptFilter, Nil, Nil );

      if VCOCoRes <> NOERROR then
      begin
        ShowMessage( 'Cannot render closed captioning' );
        // so what? goto SetupCaptureFail;
      end;
    end;
  end;
{$IFDEF REGISTER_FILTERGRAPH}
  hr := AddGraphToRot( VCOIGraphBuilder, g_dwGraphRegister );
  if ( FAILED(hr) ) then
  begin
    ShowMessage( Format('Failed to register filter graph with ROT!  hr=0x%x',
                                                                        [hr]) );
    g_dwGraphRegister := 0;
  end;
{$ENDIF}
  VCOPrepVideoWindow(); // no errors checked inside

  VCOCoRes := VCOIMediaControl.Run();

  if VCOCheckRes(37) then
  begin
    VCODumpString( 'Something wrong in IMediaControl.Run' );
    Exit;
  end;
  // ***** GrabGraph Created OK and now in Run state
  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj3.VCOPrepGrabGraph3
end.
