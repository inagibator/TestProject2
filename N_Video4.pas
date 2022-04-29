unit N_Video4;
// ***** Video processing Tools

// 19.08 - also for N_CMVideo3F - added GrabSample without using SampleGrabber
// 29.06.15 - deleted GetVideoThumb
// 04.08.15 - deleted some function that are in the N_Video.pas
// 31.05.17 - finished closing after disconnect, default size is bigger
// 15.07.17 - remembering the state on shared screens (form init)
// 04.08.17 - slow start after windows 10 update
// 13.08.17 - sirona activation code added, crashed without it
// 22.08.17 - local operations to ini for a video recording (LocalRecord in ini), form coords logs cleaned
// 25.09.18 - still pin button added
// 19.11.18 - first fire from samplegrabber callback after any graph stop is treated
// 06.04.21 - wmv added
// 14.04.21 - delphi 7 support added
// 20.05.21 - exception catched (incomplete jpeg)
// 05.07.21 - video format added
// 11.10.21 - video format initial settings
// 03.11.21 - messages replaced
// 15.12.21 - 'ES' modality forced for an every slide

interface

uses
  Windows, Classes, Graphics, SysUtils, ActiveX, Dialogs,
  DirectShow9, Types,
  N_Types, N_Gra0, N_Gra2,
  Messages, K_CM0, MMSystem, ExtCtrls, Controls
  {$IFNDEF VER150} //***** not Delphi 7
  , WMF9
  {$ENDIF VER150} //****** no code in Delphi 7
  ;

const
  N_WDM_2860_Capture = '352 240 352 480 480 480 720 480'; // Unable resolutions for WDM

  // ***** for EVR
  N_CLSID_EnhancedVideoRenderer: TGUID =
                                       '{FA10746C-9B63-4B6C-BC49-FC300EA5F256}';
  N_SID_IMFGetService =                '{FA993888-4383-415A-A930-DD472A8CF6F7}';
  N_SID_IMFVideoDisplayControl =       '{A490B1E4-AB84-4D31-A1B2-181E03B1077A}';
  N_IID_IMFVideoDisplayControl: TGUID = N_SID_IMFVideoDisplayControl;
  N_MR_Video_Render_Service:   TGUID = '{1092A86c-AB1A-459A-A336-831FBC4D11FF}';

type N_GrabberChild = class( TInterfacedObject, ISampleGrabberCB ) // for still pin button
  public
    function  SampleCB( SampleTime: Double; pSample: IMediaSample )
                                                             : HResult; stdcall;
    function  BufferCB( SampleTime: Double; pBuffer: PByte; BufferLen: longint )
                                                             : HResult; stdcall;
  end;

type
  N_IMFGetService = interface ( IUnknown )
  [N_SID_IMFGetService]
    function GetService ( const GuidService: TGUID; const IID: TIID;
                                              out PpvObject ): HResult; stdcall;
  end;

type
  N_PMFVideoNormalizedRect = ^N_TMFVideoNormalizedRect;
  N_TMFVideoNormalizedRect = record
    MFVNRLeft:   float;
    MFVNRTop:    float;
    MFVNRRight:  float;
    MFVNRBottom: float;
end;

type
  IMFVideoDisplayControl = interface ( IUnknown )
  [N_SID_IMFVideoDisplayControl]
    function IMFVDCGetNativeVideoSize ( out pszVideo: TSIZE;
                                      out pszARVideo: TSIZE ): HResult; stdcall;
    function IMFVDCGetIdealVideoSize  ( out pszMin: TSIZE; out pszMax: TSIZE ):
                                                               HResult; stdcall;
    function IMFVDCSetVideoPosition   ( pnrcSource: N_PMFVideoNormalizedRect;
                                             prcDest: PRECT ): HResult; stdcall;
    function IMFVDCGetVideoPosition   ( out pnrcSource:
               N_TMFVideoNormalizedRect; out prcDest: TRECT ): HResult; stdcall;
    function IMFVDCSetAspectRatioMode ( dwAspectRatioMode: DWORD ): HResult;
                                                                        stdcall;
    function IMFVDCGetAspectRatioMode ( out pdwAspectRatioMode: DWORD ):
                                                               HResult; stdcall;
    function IMFVDCSetVideoWindow     ( hwndVideo: HWND ):     HResult; stdcall;
    function IMFVDCGetVideoWindow     ( out phwndVideo: HWND ): HResult;
                                                                        stdcall;
    function IMFVDCRepaintVideo:                               HResult; stdcall;
    function IMFVDCGetCurrentImage    ( pfBih: PBITMAPINFOHEADER; out lpDib;
                      out pcbDib: DWORD; pTimeStamp: PInt64 ): HResult; stdcall;
    function IMFVDCSetBorderColor     ( Clr: COLORREF ):       HResult; stdcall;
    function IMFVDCGetBorderColor     ( out pClr: COLORREF ):  HResult; stdcall;
    function IMFVDCSetRenderingPrefs  ( dwRenderFlags: DWORD ):
                                                               HResult; stdcall; // a combination of MFVideoRenderPrefs
    function IMFVDCGetRenderingPrefs  ( out pdwRenderFlags: DWORD ):
                                                               HResult; stdcall;
    function IMFVDCSetFullscreen      ( fFullscreen: Boolean ):
                                                               HResult; stdcall;
    function IMFVDCGetFullscreen      ( out pfFullscreen: Boolean ):
                                                               HResult; stdcall;
  end;

type
  TN_BaseFilterInfo = packed record // Info about IBaseFilter
    BFIFilter: IBaseFilter; // Filter IBaseFilter Interface
    BFIName:        string; // Filter Name
    BFIVendorStr:   string; // Venodor info string
  end;
  // type TN_BaseFilterInfo = packed record // Info about IBaseFilter
type
  TN_PBaseFilterInfo = ^TN_BaseFilterInfo;

type
  TN_VFThumbParams = packed record // Video File Thumbnail Params
    VFTPThumbSize:        integer; // max X,Y Thumbnail Size in Pixels
    VFTPMainBordWidth:    float; // Main (Gray) border width in Percents of VFTPThumbSize
    VFTPBlackBordWidth:   float; // Black border width around Image in Percents of VFTPThumbSize
    VFTPWhiteWholesWidth: float; // White Wholes (inside MainBorder) width in Percents of VFTPThumbSize
  end;
  // type TN_VFThumbParams = packed record // Video File Thumbnail Params
type
  TN_PVFThumbParams = ^TN_VFThumbParams;

// ***** information about slides that were taked at a previous session (when waiting for a disconnected device)
type
  TN_SlidesInfo = packed record
    SIASlides: TN_UDCMSArray; // array of slides
    SINumVideos: Integer;     // number of videos
    SINumStills: Integer;     // number of pictures
end;

type
  TN_ControlStreamFlags = Set Of ( csfPreview, csfCapture, csfStart, csfStop );

type
  TN_VideoCapsFlags = Set Of ( vcfDeb1, vcfSizesList );

type
  TN_VideoCaptObj4 = class ( TObject ) // ***
    // ***** should be set on input:
    VCOVCaptDevName:      string;  // Video Capturing Device Name
    VCOVComprFiltName:    string;  // Video Compressor Filter Name
    VCOVComprSectionName: string;  // MemIni Section Name with preferred VideoCompressor Names
    VCOWindowHandle:      THandle; // Windows WinHandle where Video Priview should be
    VCOMaxWindowRect:     TRect;   // Max Preview Rect in VCOWindowHandle
    VCOFileName:          string;  // avi File Name for resulting Video
    VCOMinFileSize:       int64;   // Minimal Video File initial Size in bytes

    VCOFlip: Boolean;

    // ***** DirectShow Intefaces:
    VCOIGraphBuilder:     IGraphBuilder;
    VCOICaptGraphBuilder: ICaptureGraphBuilder2;
    VCOIMux:              IBaseFilter;
    VCOISink:             IFileSinkFilter;

    VCOIMediaControl:     IMediaControl;
    VCOIMediaSeeking:     IMediaSeeking;
    VCOIStreamConfig:     IAMStreamConfig;
    VCOIVideoWindow:      IVideoWindow;
    VCOIVideoProcAmp:     IAMVideoProcAmp;
    VCOISampleGrabber:    ISampleGrabber;

    VCOIGrabberChild:     N_GrabberChild; // still pin button

    VCOVideoMoniker:      IMoniker;
    VCOAudioMoniker:      IMoniker;
    VCOIVideoCompression: IAMVideoCompression;
    VCODialogs:           IAMVfwCaptureDialogs;
    VCOIConfigAviMux:     IConfigAviMux;

    // Needed for VMR filter
    VCOVmrFilterConfig7:  IVMRFilterConfig;
    VCOVmrMixerControl7:  IVMRMixerControl;
    VCOVmrFilterConfig9:  IVMRFilterConfig9;
    VCOVmrMixerControl9:  IVMRMixerControl9;
    VCOWindowlessControl: IUnknown;
    VCOVmrFilter:         IBaseFilter; // VMR filter
    // needed for evr
    VCOEVR:               IBaseFilter; // EVR filter
    VCODisplayControl:    IMFVideoDisplayControl;

    VCOFlipRect7:         NormalizedRect;         // Rect used for VMR7
    VCOFlipRect9:         VMR9NormalizedRect;     // Rect used for VMR9
    VCOFlipRectEVR:       N_TMFVideoNormalizedRect; // Rect used for EVR
    VCOIVideoControl:     IAMVideoControl;
    VCOUnableResolutions: TStringList; // for disabling resolutions

    // ***** DirectShow Filters:
    VCOIVideoCaptFilter:  IBaseFilter;
    VCOIAudioCaptFilter:  IBaseFilter;
    VCOIVideoComprFilter: IBaseFilter;
    VCOIAudioComprFilter: IBaseFilter;
    VCOISampleGrabFilter: IBaseFilter;
    VCOInfTee:            IBaseFilter; // Infinite Tee filter - to handle

    VCOStillPin: IPin; // still pin
    VCOSampleGrabberFlag: Boolean; // do we use SampleGrabber or not

    // Old drivers problems
    VCONullRendererFilter: IBaseFilter;

    // ***** Other fields:
    VCORecordGraph:   Boolean; // RecordGrapth for Recording Videos
    VCOGrabGraph:     Boolean; // GrabGraph for Grabbing Samples
    VCONowRecording:  Boolean; // writing to avi file Stream is now working (not stopped)
    VCOCurWindowRect: TRect;   // Current Preview Rect in VCOWindowHandle (can be any size, streching is always used)

    VCOCoRes:           HResult; // COM result code (Error code)
    VCOIError:          integer; // Own Integer Error code
    VCOSError:          string;  // VCOCoRes or VCOIError description as String
    VCOGraphState:      TFilterState; // 0-Stopped, 1-Paused, 2-Running
    VCONeededVideoCMST: TGUID; // Needed Video Capture Media SubType format or NilGUID if any format is OK
    VCOCurVideoCMST:    TGUID; // Current Video Capture Media SubType format
    VCOStrings:         TStringList;

    VCOCaptPin:         integer; // Capture Pin type 0-PIN_CATEGORY_CAPTURE, 1-PIN_CATEGORY_CAPTURE
    VCOFVFWStatus:      Boolean;

    VCOCCAvail:         Boolean; // Closed Captioning Available
    VCOCapCC:           Boolean; // Do We Need To Render Closed Captioning Pin?
    VCOWachFriendlyName:   WideString; // Device (Filter) Name
    VCOCapAudioIsRelevant: Boolean;    // Is Audio Caption Relevant?
    VCOCapAudio:        Boolean; // Do We Need Audio Caption?
    VCOPreviewFaked:    Boolean; // Is Preview Faked?
    VCOUseFrameRate:    Boolean; // Do We Need To Use the Frame Rate from VCOFrameRate?
    VCOFrameRate:       Double;
    VCOIMasterStream:   integer; // Holds master stream (None, Audio or Video)

    VCOSupportCrossbarInfo: boolean; // Needed to activate / deactivate buttons (Crossbar button)

    VCOError: Boolean; // error while initializing

    VCOFormatList: TStringList; // video formats

    Config: IConfigAsfWriter;
    BUFFER_WINDOW: Integer;// = 30000;  // 1 second
    MAX_KEY_FRAME_SPACING: Integer;// = 80000000; // 1 seconds
    Width, Height, BitrateNum: Integer;
    AvgTimePerFrame: Integer;
    SaveFileName: string;

    constructor Create  ();
    constructor Create3 ( AWindowHandle: THandle; AMaxWindowRect: TRect;
                                   ABaseFileName: string; AMinFileSize: int64 );
    destructor Destroy  (); override;

    procedure VCOGetErrorDescr  ( ACoRes: HResult );
    function  VCOCheckRes       ( AIError: integer ): Boolean;
    procedure VCODumpString     ( AStr: string );
    procedure VCOPrepVideoFiles ();
    function  VCOGetGraphState  (): integer;
    procedure VCOEnumVideoCaps  ( AVideoCaps: TStrings );
    function  VCOGetNextFilter  ( ACurFilter: IBaseFilter; ADirection: PGUID;
                                       APBFI: TN_PBaseFilterInfo ): IBaseFilter;
    function  VCOGetCrossbarFilter     (): IBaseFilter;
    function  VCOGetCrossbarFilterInfo (): Boolean;
    procedure VCOEnumVideoSizes        ( AVideoSizes: TStrings; AFormats: TStrings );
    procedure VCOEnumFilters2          ( AStrings: TStrings );
    procedure VCOEnumFilterPins        ( AStrings: TStrings;
                                                         AFilter: IBaseFilter );
    procedure VCOSetVideoSize          ( AInpSizeStr: string; FormatGUIDString: string;
                                                         out ANewSize: TPoint );
    procedure VCOClearGraph            ();
    procedure VCOPrepInterfaces2       (); // added for Mode 2
    procedure VCOPrepVideoWindow       ();
    {$IFNDEF VER150} //***** not Delphi 7
    procedure VCOPrepRecordGraph2      (); // added for Mode 2
    {$ENDIF VER150} //****** no code in Delphi 7
    procedure VCOPrepGrabGraph2        (); // added for Mode 3 (not 2!)
    procedure VCOStartRecording        ();
    function  VCOStopRecording         (): string;
    function  VCOGrabSample            (): TN_DIBObj; // with SampleGrabber
    function  VCOGrabSample2           (): TN_DIBObj; // without SampleGrabber
    procedure VCOShowFilterDialog      ( AIFilter: IBaseFilter;
                                                       AWindowHandle: THandle );
    procedure VCOShowStreamDialog      ( AWindowHandle: THandle );
    procedure VCOControlStream         ( AFlags: TN_ControlStreamFlags );
    property  VCOVFWStatus: Boolean read VCOFVFWStatus write VCOFVFWStatus;
    // added for Mode 2
    procedure VCOSetPreviewWindowSize;  // for Windowed
    procedure VCOSetPreviewWindowSize2; // for Windowless
    procedure VCOSetPreviewWindowSize3; // for EVR

    procedure VCOSetPreviewWindowSizeNull2;
    procedure VCOSetPreviewWindowSizeNull3;

    function  VCOGetVFWStatus:   Boolean;
    function  VCOMakeBuilder:    Boolean;
    function  VCOMakeGraph:      Boolean;
    procedure VCOFreeCapFilters;
    procedure VCONukeDownStream ( F: IBaseFilter );
    function  VCOGetFileParams( FileName: string; out Dimentions: string; out Duration: Integer ): TN_DIBObj;
  end; // type TN_VideoCaptObj4 = class( TObject )

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

procedure N_DSFreeMediaType    ( APMediaType: PAMMediaType );
procedure N_DSDeleteMediaType  ( APMediaType: PAMMediaType );
function  N_GetDSErrorDescr    ( ACoRes: HResult ): string;

function  N_DSEnumFilters      ( const clsidDeviceClass: TGUID;
                                                               ADevName: String;
                  ADevNamesList: TStrings; out AErrCode: integer ): IBaseFilter;
function  N_DSGetAnyFilter     ( const clsidDeviceClass: TGUID;
                                    ASectionName: string; out AErrCode: integer;
                                         out AFilterName: string ): IBaseFilter;
procedure N_DSEnumVideoSizes2  ( ADevName: string; AResList: TStrings );
// for Mode 2
procedure N_DSEnumVideoCaps2   ( ADevName: string; AResList: TStrings );
// for Mode 2
function N_GetGUIDName         ( const AGUID: TGUID ): string;

// To Add and Remove Graph
function AddGraphToRot      ( Graph: IFilterGraph; out ID: integer ): HResult;
function RemoveGraphFromRot ( ID: integer ): HResult;

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
  N_StillPinPressed:  Boolean;

implementation

uses Math, Variants,
  DirectDraw,
  K_CLib0, K_Parse,
  N_Lib0, N_Lib1, N_Lib2, N_Gra1, N_CMVideo4F, JPEG;

// *********************** N_GrabberChild Class methods

// ************************************************* N_GrabberChild.SampleCB ***
// Standart sample grabber callback returning sample
//
function N_GrabberChild.SampleCB(SampleTime: Double; pSample: IMediaSample):
                                                                        HResult;
begin
  N_Dump1Str('Callback sample pressed');
  N_StillPinPressed := True;
  Result := 0;
end; // function N_GrabberChild.SampleCB

// ************************************************* N_GrabberChild.SampleCB ***
// Standart sample grabber callback returning buffer
//
function N_GrabberChild.BufferCB(SampleTime: Double; pBuffer: PByte;
                                                   BufferLen: longint): HResult;
begin
  N_Dump1Str('Callback buffer pressed');
  N_StillPinPressed := True;
  Result := 0;
end; // function N_GrabberChild.SampleCB

// *********************** TN_VideoCaptObj Class methods

// ************************************************* TN_VideoCaptObj4.Create ***
// Create Self
//
constructor TN_VideoCaptObj4.Create();
begin
  VCOStrings := TStringList.Create;
  VCOMinFileSize := 10 * 1024 * 1024;
 // VCOFileNameInd := 1; // first capturing will be to VCOFileNames[0]
end; // constructor TN_VideoCaptObj4.Create;

// ************************************************ TN_VideoCaptObj4.Create3 ***
// Create Self by given Params
//
// Parameters
// AWindowHandle  - Windows Window Handle where to show Video
// AMaxWindowRect - Max allowed Rect coords in given Window where to show Video
// ABaseFileName  - Base File name for Video Recording
// AMinFileSize   - Minimal File Size before recording (in bytes)
//
constructor TN_VideoCaptObj4.Create3( AWindowHandle: THandle;
            AMaxWindowRect: TRect; ABaseFileName: string; AMinFileSize: int64 );
begin
  Create();

  VCOWindowHandle  := AWindowHandle;
  VCOMaxWindowRect := AMaxWindowRect;
  VCOCurWindowRect := AMaxWindowRect;
  VCOMinFileSize   := AMinFileSize;

  VCOFileName := K_ExpandFileName( ABaseFileName );
end; // constructor TN_VideoCaptObj4.Create3;

// ************************************************ TN_VideoCaptObj4.Destroy ***
// Close all TWAIN Objects and Destroy Self
//
destructor TN_VideoCaptObj4.Destroy;
begin
  VCOClearGraph();
  VCOStrings.Free;

  inherited;
end; // destructor TN_VideoCaptObj4.Destroy;

// *************************************** TN_VideoCaptObj4.VCOGetErrorDescr ***
// Clear Video Capturing Graph Filters and other objects
//
// Parameters
// Result - Return 0 for Stopped, 1 for Paused, 2 for Running or -1 if error
//
procedure TN_VideoCaptObj4.VCOGetErrorDescr( ACoRes: HResult );
begin
  VCOSError := N_GetDSErrorDescr( ACoRes );
end; // procedure TN_VideoCaptObj4.VCOGetErrorDescr

// ******************************************** TN_VideoCaptObj4.VCOCheckRes ***
// Check COM result in VCOCoRes
//
// Parameters
// AIError - given Error Number to assign to VCOIError if Failed
// Result  - Return True if failed or False if OK
//
function TN_VideoCaptObj4.VCOCheckRes( AIError: integer ): Boolean;
begin
  Result := FAILED(VCOCoRes);

  if Result then // failed
  begin
    VCOIError := AIError;
    VCOGetErrorDescr( VCOCoRes );
    VCODumpString(Format( 'VCO Error=%d, %s', [VCOIError, VCOSError]) );
  end
  else // OK
  begin
    VCOIError := 0;
    VCOSError := '';
  end;
end; // function TN_VideoCaptObj4.VCOCheckRes

// ****************************************** TN_VideoCaptObj4.VCODumpString ***
// Check COM result in VCOCoRes
//
// Parameters
// AIError - given Error Number to assign to VCOIError if Failed
// Result  - Return True if failed or False if OK
//
procedure TN_VideoCaptObj4.VCODumpString( AStr: string );
begin
  N_Dump2Str( 'VCO: ' + AStr );
end; // procedure TN_VideoCaptObj4.VCODumpString

// ************************************** TN_VideoCaptObj4.VCOPrepVideoFiles ***
// Prepare two Files for Video Capturing
//
// VCOICaptGraphBuilder Interface is used and should be already OK.
// Errors in range 53 - 55 are checked
//
procedure TN_VideoCaptObj4.VCOPrepVideoFiles();
//var
  //WFileName: WideString;
begin
  VCOIError := 53;
  VCOSError := 'VCOICaptGraphBuilder = nil';
  if VCOICaptGraphBuilder = nil then
    Exit;

  if N_GetFileSize(VCOFileName) < VCOMinFileSize then
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
end; // procedure TN_VideoCaptObj4.VCOPrepVideoFiles

// **************************************** TN_VideoCaptObj4.VCOGetGraphState ***
// Get current Graph state in VCOGraphState variable and return it as integer
//
// Parameters
// Result - Return current Graph state as integer
//
function TN_VideoCaptObj4.VCOGetGraphState(): integer;
begin
  Result := -1;
  if VCOIMediaControl <> nil then
  begin
    VCOIMediaControl.GetState( 100, VCOGraphState ); // 100 is timeout in ms
    Result := integer( VCOGraphState );
  end;
end; // function TN_VideoCaptObj4.VCOGetGraphState

// *************************************** TN_VideoCaptObj4.VCOEnumVideoCaps ***
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
procedure TN_VideoCaptObj4.VCOEnumVideoCaps( AVideoCaps: TStrings );
var
  i, NumCaps, CapsSize, CurWidth, CurHeight: integer;
  Str: string;
  CurFramesPerSec: Double;
  VSCC: TVideoStreamConfigCaps;
  // CoRes: HResult;
  PMediaType: PAMMediaType;
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
        N_Dump1Str(IntToStr(i)+' TimePerFrame: '+IntToStr(AvgTimePerFrame));
        CurFramesPerSec := 1.0E7 / AvgTimePerFrame;
        N_Dump1Str(IntToStr(i)+' FramesPerSec: '+FloatToStr(CurFramesPerSec));
        CurWidth := bmiHeader.biWidth;
        N_Dump1Str(IntToStr(i)+' Width: '+IntToStr(bmiHeader.biWidth));
        CurHeight := abs( bmiHeader.biHeight );
        N_Dump1Str(IntToStr(i)+' Height: '+IntToStr(abs( bmiHeader.biHeight )));
      end; // with PVideoInfoHeader(pbFormat)^ do

      Str := Format('%02d) ', [i]);

      if IsEqualGUID( MajorType, MEDIATYPE_Video ) then
        Str := Str + 'Video, '
      else
        Str := Str + Format( 'MT=%s ', [GUIDToString(majortype)] );

      Str := Str + N_GetGUIDName( SubType ) + ', ';
      Str := Str + N_GetGUIDName( FormatType ) + ', ';

      Str := Str + Format( 'FPS=%.1f, %d x %d, ', [CurFramesPerSec, CurWidth,
                                                                   CurHeight] );
      AVideoCaps.Add( Str );
      N_Dump1Str('Format '+IntToStr(i)+': '+Str);

      N_DSDeleteMediaType( PMediaType ); // delete MediaType record allocated by DirectShow
    end; // with PMediaType^ do
  end; // for i := -1 to NumCaps-1 do // along current mode and all capabilities

end; // procedure TN_VideoCaptObj4.VCOEnumVideoCaps

// ************************************** TN_VideoCaptObj4.VCOEnumVideoSizes ***
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
procedure TN_VideoCaptObj4.VCOEnumVideoSizes( AVideoSizes: TStrings; AFormats: TStrings );
var
  i, NumCaps, CapsSize: integer;
  WrkSL: TStringList;
  VSCC: TVideoStreamConfigCaps;
  PMediaType: PAMMediaType;

  WrkIndex, WrkWidth, WrkHeight: integer;
  WrkString, NameString: string;

function GetFormatNameByGUID(GUID: TGUID): string;
begin

  if GUIDToString(GUID) =	'{47504A4D-0000-0010-8000-00AA00389B71}' then Result := 'MJPG' else // often used, so first

  if GUIDToString(GUID) =	'{30323449-0000-0010-8000-00AA00389B71}' then Result := 'I420' else
  if GUIDToString(GUID) =	'{56555949-0000-0010-8000-00AA00389B71}' then Result := 'IYUV' else
  if GUIDToString(GUID) =	'{e436eb78-524f-11ce-9f53-0020af0ba770}' then Result := 'RGB1' else
  if GUIDToString(GUID) =	'{e436eb7d-524f-11ce-9f53-0020af0ba770}' then Result := 'RGB24' else
  if GUIDToString(GUID) =	'{e436eb7e-524f-11ce-9f53-0020af0ba770}' then Result := 'RGB32' else
  if GUIDToString(GUID) =	'{e436eb79-524f-11ce-9f53-0020af0ba770}' then Result := 'RGB4' else
  if GUIDToString(GUID) =	'{e436eb7c-524f-11ce-9f53-0020af0ba770}' then Result := 'RGB555' else
  if GUIDToString(GUID) =	'{e436eb7b-524f-11ce-9f53-0020af0ba770}' then Result := 'RGB565' else
  if GUIDToString(GUID) =	'{e436eb7a-524f-11ce-9f53-0020af0ba770}' then Result := 'RGB8' else
  if GUIDToString(GUID) =	'{59565955-0000-0010-8000-00AA00389B71}' then Result := 'UYVY' else
  if GUIDToString(GUID) =	'{1d4a45f2-e5f6-4b44-8388-f0ae5c0e0c37}' then Result := 'VIDEOIMAGE' else
  if GUIDToString(GUID) =	'{32595559-0000-0010-8000-00AA00389B71}' then Result := 'YUY2' else
  if GUIDToString(GUID) =	'{31313259-0000-0010-8000-00AA00389B71}' then Result := 'YV12' else
  if GUIDToString(GUID) =	'{39555659-0000-0010-8000-00AA00389B71}' then Result := 'YVU9' else
  if GUIDToString(GUID) =	'{55595659-0000-0010-8000-00AA00389B71}' then Result := 'YVYU' else
  if GUIDToString(GUID) =	'{e06d80e3-db46-11cf-b4d1-00805f6cbbea}' then Result := 'WM MPEG2 Video' else
  if GUIDToString(GUID) =	'{5C8510F2-DEBE-4ca7-BBA5-F07A104F8DFF}' then Result := 'WM Script' else
  if GUIDToString(GUID) =	'{05589f80-c356-11ce-bf01-00aa0055595a}' then Result := 'WM VideoInfo' else
  if GUIDToString(GUID) =	'{05589f81-c356-11ce-bf01-00aa0055595a}' then Result := 'WM WaveFormatEx' else
  if GUIDToString(GUID) =	'{a1e6b13-8359-4050-b398-388e965bf00c}' then Result := 'WM WebStream' else
  if GUIDToString(GUID) =	'{00000130-0000-0010-8000-00AA00389B71}' then Result := 'WM ACELPnet' else
  if GUIDToString(GUID) =	'{00000000-0000-0010-8000-00AA00389B71}' then Result := 'WM Base' else
  if GUIDToString(GUID) =	'{00000009-0000-0010-8000-00AA00389B71}' then Result := 'WM DRM' else
  if GUIDToString(GUID) =	'{00000055-0000-0010-8000-00AA00389B71}' then Result := 'WM MP3' else
  if GUIDToString(GUID) =	'{3334504D-0000-0010-8000-00AA00389B71}' then Result := 'WM MP43' else
  if GUIDToString(GUID) =	'{5334504D-0000-0010-8000-00AA00389B71}' then Result := 'WM MP4S' else
  if GUIDToString(GUID) =	'{3253344D-0000-0010-8000-00AA00389B71}' then Result := 'WM M4S2' else
  if GUIDToString(GUID) =	'{32323450-0000-0010-8000-00AA00389B71}' then Result := 'WM P422' else
  if GUIDToString(GUID) =	'{e06d8026-db46-11cf-b4d1-00805f6cbbea}' then Result := 'WM MPEG2 VIDEO' else
  if GUIDToString(GUID) =	'{3153534D-0000-0010-8000-00AA00389B71}' then Result := 'WM MSS1' else
  if GUIDToString(GUID) =	'{3253534D-0000-0010-8000-00AA00389B71}' then Result := 'WM MSS2' else
  if GUIDToString(GUID) =	'{00000001-0000-0010-8000-00AA00389B71}' then Result := 'WM PCM' else
  if GUIDToString(GUID) =	'{776257d4-c627-41cb-8f81-7ac7ff1c40cc}' then Result := 'WM WebStream' else
  if GUIDToString(GUID) =	'{00000163-0000-0010-8000-00AA00389B71}' then Result := 'WM WMAudio Lossless' else
  if GUIDToString(GUID) =	'{00000161-0000-0010-8000-00AA00389B71}' then Result := 'WM WMAudioV2' else
  if GUIDToString(GUID) =	'{00000161-0000-0010-8000-00AA00389B71}' then Result := 'WM WMAudioV7' else
  if GUIDToString(GUID) =	'{00000161-0000-0010-8000-00AA00389B71}' then Result := 'WM WMAudioV8' else
  if GUIDToString(GUID) =	'{00000162-0000-0010-8000-00AA00389B71}' then Result := 'WM WMAudioV9' else
  if GUIDToString(GUID) =	'{0000000A-0000-0010-8000-00AA00389B71}' then Result := 'WM WMSP1' else
  if GUIDToString(GUID) =	'{31564D57-0000-0010-8000-00AA00389B71}' then Result := 'WM WMV1' else
  if GUIDToString(GUID) =	'{32564D57-0000-0010-8000-00AA00389B71}' then Result := 'WM WMV2' else
  if GUIDToString(GUID) =	'{33564D57-0000-0010-8000-00AA00389B71}' then Result := 'WM WMV3' else
  if GUIDToString(GUID) =	'{41564D57-0000-0010-8000-00AA00389B71}' then Result := 'WM WMVA' else
  if GUIDToString(GUID) =	'{50564D57-0000-0010-8000-00AA00389B71}' then Result := 'WM WMVP' else
  if GUIDToString(GUID) =	'{32505657-0000-0010-8000-00AA00389B71}' then Result := 'WM WVMP2' else
  if GUIDToString(GUID) =	'{73647561-0000-0010-8000-00AA00389B71}' then Result := 'WM Audio' else
  if GUIDToString(GUID) =	'{D9E47579-930E-4427-ADFC-AD80F290E470}' then Result := 'WM File Transfer' else
  if GUIDToString(GUID) =	'{34A50FD8-8AA5-4386-81FE-A0EFE0488E31}' then Result := 'WM Image' else
  if GUIDToString(GUID) =	'{73636d64-0000-0010-8000-00AA00389B71}' then Result := 'WM Script' else
  if GUIDToString(GUID) =	'{9BBA1EA7-5AB2-4829-BA57-0940209BCF3E}' then Result := 'WM Text' else
  if GUIDToString(GUID) =	'{73646976-0000-0010-8000-00AA00389B71}' then Result := 'WM Video' else
  if GUIDToString(GUID) =	'{82f38a70-c29f-11d1-97ad-00a0c95ea850}' then Result := 'WM Two Strings' else

  // more
  if GUIDToString(GUID) =	'{15B9B7CA-A7C0-448C-A68D-4D45A4137E38}' then Result := 'Dirac' else
  if GUIDToString(GUID) =	'{A29DA00F-A22B-40EA-98DE-2F7FECADA5DE}' then Result := 'Dirac' else
  if GUIDToString(GUID) =	'{43564548-0000-0010-8000-00AA00389B71}' then Result := 'H.265' else
  if GUIDToString(GUID) =	'{34363248-0000-0010-8000-00AA00389B71}' then Result := 'H.264' else
  if GUIDToString(GUID) =	'{31435657-0000-0010-8000-00AA00389B71}' then Result := 'WVC1' else
  if GUIDToString(GUID) =	'{31564D57-0000-0010-8000-00AA00389B71}' then Result := 'WMV1' else
  if GUIDToString(GUID) =	'{32564D57-0000-0010-8000-00AA00389B71}' then Result := 'WMV2' else
  if GUIDToString(GUID) =	'{33564D57-0000-0010-8000-00AA00389B71}' then Result := 'WMV3' else

  if GUIDToString(GUID) =	'{33363248-0000-0010-8000-00AA00389B71}' then Result := 'H.263' else
  if GUIDToString(GUID) =	'{5334504D-0000-0010-8000-00AA00389B71}' then Result := 'MPEG4' else
  if GUIDToString(GUID) =	'{3447504D-0000-0010-8000-00AA00389B71}' then Result := 'MPEG4' else
  if GUIDToString(GUID) =	'{E06D8026-DB46-11CF-B4D1-00805F6CBBEA}' then Result := 'MPEG2'

  else Result := GUIDToString(GUID);

end;

  label StopEnum;
begin

  AVideoSizes.Clear;
  AFormats.Clear;

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

    VCOFormatList := TStringList.Create();

   // for i := 0 to NumCaps - 1 do // along all capabilities
    while True do//VCOCoRes <> S_FALSE do
    begin
      VCOCoRes := VCOIStreamConfig.GetStreamCaps( i, PMediaType, VSCC );
      if ( VCOCoRes = S_OK ) then
      begin


      N_Dump1Str(IntToStr(i)+' Subtype: '+GUIDToString(PMediaType^.subtype));

      if VCOFormatList.IndexOf(GUIDToString(PMediaType^.subtype)) < 0 then
      begin
        VCOFormatList.Add(GUIDToString(PMediaType^.subtype));
        AFormats.Add(GetFormatNameByGUID(PMediaType^.subtype));
      end;

      with PMediaType^ do

      with PVideoInfoHeader(pbFormat)^ do
      begin
        N_Dump1Str(IntToStr(i)+' TimePerFrame: '+IntToStr(AvgTimePerFrame));
        //CurFramesPerSec := 1.0E7 / AvgTimePerFrame;
        //N_Dump1Str('FramesPerSec '+IntToStr(i)+': '+FloatToStr(CurFramesPerSec));
        //CurWidth := bmiHeader.biWidth;
        N_Dump1Str(IntToStr(i)+' Width: '+IntToStr(bmiHeader.biWidth));
        //CurHeight := abs( bmiHeader.biHeight );
        N_Dump1Str(IntToStr(i)+' Height: '+IntToStr(abs( bmiHeader.biHeight )));


      end;

      // get i-th Capability
      //if VCOCheckRes(78) then
     //   Exit;
      Inc(i);

      // ***** Add checking pbFormat type (may be VideoInfoHeader2!?)

      with PMediaType^, PVideoInfoHeader(pbFormat)^.bmiHeader do
      begin
          if ( biWidth > 0 ) and ( abs(biHeight)  > 0 ) then

            if ( IsEqualGUID(VCONeededVideoCMST, NilGUID ) or // any subtype is OK
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
      with PVideoInfoHeader( pbFormat )^.bmiHeader do
      begin
        WrkSL.Add( Format('%4d x %d', [biWidth, abs(biHeight)]) );
      end;
    N_Dump2Str(
      '            VFW Test: Inside Null NumCaps section of VCOEnumVideoSizes');

  end;

StopEnum:
  N_Dump2Str('            VFW Test: Inside VCOEnumVideoSizes, NumCaps=' +
      IntToStr(NumCaps) );

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
  N_Dump1Str('Adding list of unable resolutions for WDM');
  if NameString = 'WDM_2860_Capture' then
  begin
    N_Dump1Str( 'NameString is okay' );
    WrkString := N_WDM_2860_Capture;
    WrkHeight := 0;

    while WrkHeight <> N_NotAnInteger do // if there are some unable resolutions
    begin
      WrkHeight := N_ScanInteger( WrkString );
      WrkWidth := N_ScanInteger( WrkString );
      VCOUnableResolutions.Add( Format( ' %d x %d', [WrkHeight, WrkWidth]) );
      N_Dump1Str( Format( ' %d x %d', [WrkHeight, WrkWidth]) );
    end;

    //***** disabling resolutions
    for i := 0 to VCOUnableResolutions.Count - 1 do
    begin
      WrkIndex := WrkSL.IndexOf( VCOUnableResolutions[i] );
      if WrkIndex <> -1 then
      begin
        N_Dump1Str( 'Delete resolution: ' + WrkSL[WrkIndex] );
        WrkSL.Delete( WrkIndex );
      end;
    end;
  end;

  FreeAndNil( VCOUnableResolutions );

  AVideoSizes.AddStrings( WrkSL );
  VCODumpString( AVideoSizes.Text );
  WrkSL.Free;
end; // procedure TN_VideoCaptObj4.VCOEnumVideoSizes

// *************************************** TN_VideoCaptObj4.VCOGetNextFilter ***
// Get Next Filter
//
// Parameters
// ACurFilter - start Filter, from where to search
// ADirection - search direction (UpStream or DownStream) or nil for getting info about ACurFilter
// APBFI      - pointer to IBaseFilter Info record
// Result     - Return next IBaseFilter or nil if not found
//
function TN_VideoCaptObj4.VCOGetNextFilter( ACurFilter: IBaseFilter;
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

    if FAILED( VCOCoRes ) then
      Result := nil;
  end;

  ZeroMemory( APBFI, SizeOf(TN_PBaseFilterInfo) );

  if Result <> nil then // fill APBFI^ record
    with APBFI^ do
    begin
      BFIFilter := Result;

      VCOCoRes := Result.QueryFilterInfo(FilterInfo);
      if Succeeded(VCOCoRes) then
        BFIName := FilterInfo.achName; // Filter Name

      VCOCoRes := Result.QueryVendorInfo( PVendorStr );
      if Succeeded(VCOCoRes) then
      begin
        BFIVendorStr := PVendorStr^;
        CoTaskMemFree( PVendorStr ); // free memory allocated in QueryVendorInfo
      end;

    end; // if Result <> nil then // fill APBFI^ record
end; // function TN_VideoCaptObj4.VCOGetNextFilter

// *********************************** TN_VideoCaptObj4.VCOGetCrossbarFilter ***
// Get Crossbar Filter or nil if absent
//
// Parameters
// ACurFilter - start Filter, from where to search
// ADirection - search direction (UpStream or DownStream) or nil for getting info about ACurFilter
// APBFI      - pointer to IBaseFilter Info record
// Result     - Return Crossbar Filter IBaseFilter or nil if not found
//
function TN_VideoCaptObj4.VCOGetCrossbarFilter(): IBaseFilter;
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
end; // function TN_VideoCaptObj4.VCOGetCrossbarFilter

// ******************************* TN_VideoCaptObj4.VCOGetCrossbarFilterInfo ***
// Get Crossbar Filter Info (If Available)
//
function TN_VideoCaptObj4.VCOGetCrossbarFilterInfo(): Boolean;
var
  AMCrossbarInterface: IAMCrossbar;
begin
  VCOCoRes := VCOICaptGraphBuilder.FindInterface( @LOOK_UPSTREAM_ONLY, nil,
                    VCOIVideoCaptFilter, IID_IAMCrossbar, AMCrossbarInterface );
  if FAILED(VCOCoRes) or ( AMCrossbarInterface = nil ) then
    Result := False
  else
    Result := True;
end; // function TN_VideoCaptObj4.VCOGetCrossbarFilterInfo(): Boolean;

// **************************************** TN_VideoCaptObj4.VCOEnumFilters2 ***
// Enumerate all Filters in current Graph
// Improved version. Enumerates all filters in all branches of the graph.
//
// Parameters
// AStrings - TStrings where to collect info about Filters
//
procedure TN_VideoCaptObj4.VCOEnumFilters2( AStrings: TStrings );
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

begin // ************************** main body of TN_VideoCaptObj4.VCOEnumFilters2

  VCOIGraphBuilder.EnumFilters( FilterEnumerator );
  FilterEnumerator.Reset;

  while S_OK = FilterEnumerator.Next( 1, CurFilter, @NumberOfFiltersReceived )
                                                                              do
  begin
    MyFilterInfo := FillFilterInfo(CurFilter);
    OutFilterInfo;
  end;
end; // procedure TN_VideoCaptObj4.VCOEnumFilters2

// ************************************** TN_VideoCaptObj4.VCOEnumFilterPins ***
// Enumerate all Pins of given AFilter
//
// Parameters
// AStings - TStrings where to collect info about Pins
// AFilter - given Filter
//
procedure TN_VideoCaptObj4.VCOEnumFilterPins( AStrings: TStrings;
                                                         AFilter: IBaseFilter );
var
  PinsEnumerator:   IEnumPins;
  Pin, ExternalPin: IPin;
  NumberOfPins, Count:      Cardinal;
  PinInfo, ExternalPinInfo: TPinInfo;
  ExternalFilterInfo:       TFilterInfo;
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
      AStrings.Add('    -Pin number ' + IntToStr(Count) );
      AStrings.Add('         -PinAchName: ' + PinInfo.achName );

      Case PinInfo.dir of
        PINDIR_INPUT:
          AStrings.Add('         -PinDirection: IN');
        PINDIR_OUTPUT:
          AStrings.Add('         -PinDirection: OUT');
      else
        AStrings.Add('         -PinDirection: Other (' + IntToStr
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
      Inc(Count);
    end; // while NumberOfPins<>0 do
  except
    // ShowMessage(AStrings.Text);
  end; // try .. except
end; // procedure TN_VideoCaptObj4.VCOEnumFilterPins

// **************************************** TN_VideoCaptObj4.VCOSetVideoSize ***
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
procedure TN_VideoCaptObj4.VCOSetVideoSize( AInpSizeStr: string; FormatGUIDString: string;
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
    GivenSize.X := N_ScanInteger(Str);
    N_ScanToken(Str);
    GivenSize.Y := N_ScanInteger(Str);
  end
  else // AInpSizeStr = '', just get current Size and return it in ANewSize
  begin
    VCOCoRes := VCOIStreamConfig.GetFormat( PMediaType );
    if VCOCheckRes(71) then
      Exit;

    with PMediaType^ do
    begin
      with PVideoInfoHeader( pbFormat )^ do
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

  if FormatGUIDString <> '' then
  for i := 0 to NumCaps - 1 do // along all Stream capabilities
  begin
    VCOCoRes := VCOIStreamConfig.GetStreamCaps( i, PMediaType, VSCC );
    // get i-th Capability
    if VCOCheckRes(73) then
      Exit;

    with PMediaType^, PVideoInfoHeader(pbFormat)^.bmiHeader do
    begin

      if ( IsEqualGUID(VCONeededVideoCMST, NilGUID ) or // any subtype is OK
       IsEqualGUID( VCONeededVideoCMST, subtype) ) and ( biWidth = GivenSize.X )
        and ( abs(biHeight) = GivenSize.Y ) and (subtype = StringToGUID(FormatGUIDString)) then // GivenSize found,
      begin // set it and Exit

        N_Dump1Str('SubType Applied = '+GUIDToString(subtype));
        VCOCurVideoCMST := subtype; // Current Video Capture Media SubType format
        VCOGetGraphState();

        Width := GivenSize.X;
        Height := GivenSize.Y;
        N_Dump1Str('Width '+ IntToStr(Width)+', Height '+IntToStr(Height));

        if VCOGraphState = State_Running then
        begin
          N_i := VCOIMediaControl.Stop();
          N_i := VCOIStreamConfig.SetFormat(PMediaType^);
          if VCORecordGraph then // "record to to file" mode, stop writing Stream if needed
            VCOControlStream( [csfCapture, csfStop] );
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
end; // procedure TN_VideoCaptObj4.VCOSetVideoSize

// ****************************************** TN_VideoCaptObj4.VCOClearGraph ***
// Clear all Video Capturing Graph Filters and other objects
//
procedure TN_VideoCaptObj4.VCOClearGraph();
begin
  VCOIVideoProcAmp  := nil;
  VCOIStreamConfig  := nil;
  VCOISampleGrabber := nil;

  VCOIAudioComprFilter  := nil;
  VCOIVideoComprFilter  := nil;
  //VCOIAudioCaptFilter := nil;
  //VCOIVideoCaptFilter := nil;
  VCOISampleGrabFilter  := nil;
  VCONullRendererFilter := nil;
  VCOInfTee             := nil;

  //VCOIVideoWindow := nil;
  VCOIMediaControl := nil;
  VCOISink         := nil;
  VCOIMux          := nil;
  VCOICaptGraphBuilder := nil;
  VCOIGraphBuilder := nil;

  VCOIConfigAviMux := Nil;
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
end; // procedure TN_VideoCaptObj4.VCOClearGraph

// ***************************************** TN_VideoCaptObj4.VCOMakeBuilder ***
// Needed to make Builder
//
function TN_VideoCaptObj4.VCOMakeBuilder: Boolean;
begin
  Result := True;
  // we have one already
  if Assigned(VCOICaptGraphBuilder) then
    Exit;

  VCOCoRes := CoCreateInstance( CLSID_CaptureGraphBuilder2, Nil, CLSCTX_INPROC,
                              IID_ICaptureGraphBuilder2, VCOICaptGraphBuilder );

  Result := VCOCoRes = NOERROR;
end; // function TN_VideoCaptObj4.VCOMakeBuilder : Boolean;

function TN_VideoCaptObj4.VCOGetFileParams( FileName: string; out Dimentions: string; out Duration: Integer ): TN_DIBObj;
var
  BitmapPtr:    PBitmap;
  TimeInd, TimeStop, TimeOffset: Int64;
  ThumbSize:    TPoint;
  VMRPanel:     TPanel;
  WindowHandle: HWND;
begin
  Result := Nil;

  VCOPrepInterfaces2(); // VCO Interfaces are needed for VCOEnumVideoSizes and CMVFSetNewSize

  VCOClearGraph();
  VCOFreeCapFilters();

  // we have one already
  if Assigned(VCOIGraphBuilder) then
    Exit;

  VCOCoRes := CoCreateInstance( CLSID_FilterGraph, Nil, CLSCTX_INPROC,
                                          IID_IGraphBuilder, VCOIGraphBuilder );

  VCOIMediaControl := nil;
  VCOCoRes := VCOIGraphBuilder.QueryInterface( IID_IMediaControl,
                                                             VCOIMediaControl ); // to run graph


  VCOCoRes := VCOIGraphBuilder.QueryInterface( IID_IMediaSeeking,
                                                             VCOIMediaSeeking ); // to move stream

  VMRPanel := TPanel.Create( Nil );
  VMRPanel.Parent := FindControl(GetForegroundWindow());
  VMRPanel.Left   := 0;
  VMRPanel.Top    := 0;
  VMRPanel.Width  := 1;
  VMRPanel.Height := 1;
  VMRPanel.Visible := False;

  WindowHandle := VMRPanel.Handle;
  if WindowHandle > 0 then // WindowHandle is given
  begin
    // Window to control image
    VCOIVideoWindow := nil;
    VCOIGraphBuilder.QueryInterface( IID_IVideoWindow, VCOIVideoWindow );
    if VCOIVideoWindow <> nil then
    begin
      // Set window style
      VCOIVideoWindow.put_WindowStyle( WS_CHILD );
      if VCOIVideoWindow.put_Owner( WindowHandle ) <> S_OK then
        VCODumpString( 'Something wrong in VCOIVideoWindow.put_Owner.' +
            #13#10 + 'WindowHandle=' + inttostr(WindowHandle) );

      // Set window location
      VCOSetPreviewWindowSize;
      // Show window
      if VCOIVideoWindow.put_Visible(True) <> S_OK then
        VCODumpString( 'Something wrong in VCOIVideoWindow.put_Visible.' );
    end // if VCOIVideoWindow <> nil then
    else
      VCODumpString( 'VCOIVideoWindow seems to be nil!' );
  end;

  // Set VMR9 filter
  VCOVmrMixerControl9 := Nil;

  VCOCoRes := CoCreateInstance( CLSID_VideoMixingRenderer9, nil,
                          CLSCTX_INPROC_SERVER, IID_IBaseFilter, VCOVmrFilter );
  if Succeeded(VCOCoRes) then
  begin
    VCOCoRes := VCOIGraphBuilder.AddFilter( VCOVmrFilter,
                                                    'Video Mixing Renderer 9' );
    N_Dump1Str( 'VCOCoRes while AddFilter(VCOVmrFilter 9, = ' +
                                                           IntToStr(VCOCoRes) );
    if Succeeded(VCOCoRes) then
    begin
      VCOCoRes := VCOVmrFilter.QueryInterface( IID_IVMRFilterConfig9,
                                                          VCOVmrFilterConfig9 );
      if Succeeded(VCOCoRes) then
      begin
        // We need to set the number of streams to be able to use the mixer and this must before setting window mode
        VCOVmrFilterConfig9.SetNumberOfStreams(1);
        // Set flip if needed
        VCOCoRes := VCOVmrFilterConfig9.QueryInterface( IID_IVMRMixerControl9,
                                                          VCOVmrMixerControl9 );
        if Succeeded(VCOCoRes) then
        begin
          VCOFlipRect9.Left   := 0;
          VCOFlipRect9.Top    := 0;
          VCOFlipRect9.Right  := 1;
          VCOFlipRect9.Bottom := 1;
          // Note: Using -1 instead of swapping does not work correctly
          if VCOFlip then
          begin
            VCOFlipRect9.Left  := 1;
            VCOFlipRect9.Right := 0;
          end;
        end;
        VCOVmrMixerControl9.SetOutputRect( 0, @VCOFlipRect9 );
      end;

      // Set windowless
      VCOCoRes := VCOVmrFilterConfig9.SetRenderingMode( VMRMode_Windowless );
      if Succeeded(VCOCoRes) then
      begin
        VCOCoRes := VCOVmrFilter.QueryInterface( IID_IVMRWindowlessControl9,
                                                         VCOWindowlessControl );
        if Succeeded(VCOCoRes) then
        begin
          IVMRWindowlessControl9(VCOWindowlessControl).SetVideoClippingWindow
                                                            ( WindowHandle ); // Set handle of the window for video
          IVMRWindowlessControl9(VCOWindowlessControl).SetVideoPosition
                                                     ( Nil, Nil);//@VCOCurWindowRect ); // Set rectangle for video
        end
        else
        begin
          K_CMShowMessageDlg( 'Unable to get IVMRWindowlessControl', mtError );
          Exit;
        end;
      end;

    end;
  end;


  VCOCoRes := VCOIGraphBuilder.RenderFile( @N_StringToWide(FileName)[1], Nil );
  N_Dump1Str( 'Render file = '+IntToStr(VCOCoRes) );

  if (SUCCEEDED(VCOCoRes)) then
  begin

    // Run the graph.
    VCOCoRes := VCOIMediaControl.Run();
    N_Dump1Str( 'MediaControl run = '+IntToStr(VCOCoRes) );
  end;

  VCOIMediaControl.GetState(100, VCOGraphState);
  while VCOGraphState <> State_Running do
  begin
    Sleep(200);
    VCOIMediaControl.GetState(100, VCOGraphState);
  end;

  VCOIMediaSeeking.SetTimeFormat(TIME_FORMAT_MEDIA_TIME); // Reference time (100-nanosecond units)
  VCOIMediaSeeking.GetAvailable(TimeInd, TimeStop);
  N_Dump1Str( 'Time earliest = '+IntToStr(TimeInd)+', Time end = '+IntToStr(TimeStop) );
  Duration := TimeStop; // set out duration
  TimeOffset := Round(TimeStop/3);
  TimeInd := TimeInd + TimeOffset;
  VCOCORes:= VCOIMediaSeeking.SetPositions( TimeInd, AM_SEEKING_AbsolutePositioning, TimeStop, AM_SEEKING_AbsolutePositioning );
  N_Dump1Str( 'Position set to ' + IntToStr(VCOCoRes) );

  IVMRWindowlessControl(VCOWindowlessControl).GetCurrentImage( BitmapPtr );
  if BitmapPtr <> Nil then
  begin
    N_Dump1Str( 'Bitmap received' );
    Result := TN_DIBObj.Create();
    Result.LoadFromMemBMP( BitmapPtr );

    ThumbSize := Result.DIBSize;

    Dimentions := Format( '%4d x %d', [ ThumbSize.X, ThumbSize.Y ] );
  end;

  VCOIMediaControl.Stop();

  VMRPanel.Free;
end; // function TN_VideoCaptObj4.VCOGetFileParams( out Dimentions: string; out Duration: Integer ): TN_DIBObj;

// ******************************************* TN_VideoCaptObj4.VCOMakeGraph ***
// Needed to make Graph
//
function TN_VideoCaptObj4.VCOMakeGraph: Boolean;
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
procedure DeleteMediaType( pmt: PAMMediaType );
begin
  if ( pmt^.cbFormat <> 0 ) then
  begin
    CoTaskMemFree( pmt^.pbFormat );
    // Strictly unnecessary but tidier
    pmt^.cbFormat := 0;
    pmt^.pbFormat := nil;
  end;
  if ( pmt^.pUnk <> nil ) then
    pmt^.pUnk := nil;
end;// procedure DeleteMediaType(pmt: PAMMediaType);

// ************************************** TN_VideoCaptObj4.VCOFreeCapFilters ***
// Needed to Free Caption Filters
//
procedure TN_VideoCaptObj4.VCOFreeCapFilters;
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
end; // procedure TN_VideoCaptObj4.VCOFreeCapFilters;

// **************************************** TN_VideoCaptObj4.VCOGetVFWStatus ***
// Needed to get V4W status
//
function TN_VideoCaptObj4.VCOGetVFWStatus: Boolean;
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
end; // function TN_VideoCaptObj4.VCOGetVFWStatus: boolean;

// ******************************** TN_VideoCaptObj4.VCOSetPreviewWindowSize ***
// Defining window size
//
// Used to have Resizable variable to enter the Full Screen Mode
//
// ******************************** TN_VideoCaptObj4.VCOSetPreviewWindowSize ***
// Defining window size
//
// Used to have Resizable variable to enter the Full Screen Mode
//
procedure TN_VideoCaptObj4.VCOSetPreviewWindowSize;
begin
  // if Resizable then
  // begin
   if VCOIVideoWindow.SetWindowPosition( VCOCurWindowRect.Left,
    VCOCurWindowRect.Top,
    VCOCurWindowRect.Right  - VCOCurWindowRect.Left + 1,
    VCOCurWindowRect.Bottom - VCOCurWindowRect.Top + 1 ) <> S_OK then
    VCODumpString( 'Something wrong in VCOIVideoWindow.SetWindowPosition.' );
end; // procedure TN_VideoCaptObj4.VCOSetPreviewWindowSize;

// ******************************* TN_VideoCaptObj4.VCOSetPreviewWindowSize2 ***
// Defining window size for windowless mode
//
procedure TN_VideoCaptObj4.VCOSetPreviewWindowSize2;
begin
  IVMRWindowlessControl(VCOWindowlessControl).SetVideoPosition( Nil,
                                                            @VCOCurWindowRect );
end; // procedure TN_VideoCaptObj4.VCOSetPreviewWindowSize2;

procedure TN_VideoCaptObj4.VCOSetPreviewWindowSizeNull2;
var
  a: TRect;
begin
  a.Left   := 0;
  a.Top    := 0;
  a.Right  := 0;
  a.Bottom := 0;
  IVMRWindowlessControl(VCOWindowlessControl).SetVideoPosition( Nil, @a );
end; // procedure TN_VideoCaptObj4.VCOSetPreviewWindowSize2;

// ******************************* TN_VideoCaptObj4.VCOSetPreviewWindowSize3 ***
// Defining window size for EVR
//
procedure TN_VideoCaptObj4.VCOSetPreviewWindowSize3;
begin
  VCODisplayControl.IMFVDCSetVideoPosition( Nil, @VCOCurWindowRect );
end; // procedure TN_VideoCaptObj4.VCOSetPreviewWindowSize2;

procedure TN_VideoCaptObj4.VCOSetPreviewWindowSizeNull3;
var
  a: TRect;
begin
  a.Left   := 0;
  a.Top    := 0;
  a.Right  := 0;
  a.Bottom := 0;
  VCODisplayControl.IMFVDCSetVideoPosition( Nil, @a );
 // VCODisplayControl.IMFVDCSetVideoWindow(0);
end; // procedure TN_VideoCaptObj4.VCOSetPreviewWindowSize2;

// ************************************* TN_VideoCaptObj4.VCOPrepVideoWindow ***
// Prepare and Show VideoWindow
//
procedure TN_VideoCaptObj4.VCOPrepVideoWindow();
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
      if VCOIVideoWindow.put_Visible(True) <> S_OK then
        VCODumpString( 'Something wrong in VCOIVideoWindow.put_Visible.' );
    end // if VCOIVideoWindow <> nil then
    else
      VCODumpString( 'VCOIVideoWindow seems to be nil!' );
  end; // if VCOWindowHandle > 0 then // VCOWindowHandle is given

  // ***** No errors were checked
  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj4.VCOPrepVideoWindow

// ************************************ TN_VideoCaptObj4.VCOPrepRecordGraph2 ***
// Prepare and Run Video Capturing Graph for Recording Videos for Mode 2
//
{$IFNDEF VER150} //***** not Delphi 7
procedure TN_VideoCaptObj4.VCOPrepRecordGraph2();
var
  WrkString:    string;
  IH:           WMVIDEOINFOHEADER;

  const
  PROFILE_NAME = 'WMV AutoProfile';
var
  profileManager: IWMProfileManager;
  profile:        IWMProfile;
  stream:         IWMStreamConfig;
  mediaProps:     IWMMediaProps;
  vmediaProps:    IWMVideoMediaProps;
  pmt:            PWMMediaType;
  msize:          Cardinal;
  vih:            PVideoInfoHeader;
  videoBitRate: Cardinal; //, audioBitRate: Cardinal;
function MAKEFOURCC(ch0, ch1, ch2, ch3: Char) : DWORD;
begin
 Result := DWORD(byte(ch0) shl 0) or
              DWORD(byte(ch1) shl 8) or
              DWORD(byte(ch2) shl 16) or
              DWORD(byte(ch3) shl 24);
end;

Label SetupCaptureFail;
begin
  VCOIVideoComprFilter := nil;

  if VCOIVideoComprFilter <> nil then // nil means using uncompressed Video
  begin
  end; // if VCOIVideoComprFilter <> nil then

  VCORecordGraph := True;
  VCOGrabGraph   := False;

  if VCOICaptGraphBuilder = nil then
    VCOPrepInterfaces2();

  if VCOIError <> 0 then
    Exit;

  VCOIMux  := nil;
  VCOISink := nil;

  VCOFileName := StringReplace( VCOFileName, 'avi', 'wmv', [rfReplaceAll, rfIgnoreCase] );
  N_Dump1Str( 'Video temp filename = ' + VCOFileName );
  VCOCoRes := VCOICaptGraphBuilder.SetOutputFileName
       ( MEDIASUBTYPE_Asf, @N_StringToWide(SaveFileName)[1], VCOIMux, VCOISink );
  N_Dump1Str( 'VCOCoRes while SetOutputFileName (MEDIASUBTYPE_Avi,' +
                                                           IntToStr(VCOCoRes) );

  if VCOCheckRes(23) then
    Exit;

  // Now tell the AVIMUX to write out AVI files that old apps can read properly.
  // If we don't, most apps won't be able to tell where the keyframes are,
  // slowing down editing considerably
  // Doing this will cause one seek (over the area the index will go) when
  // you capture past 1 Gig, but that's no big deal.
  // NOTE: This is on by default, so it's not necessary to turn it on

  // Also, set the proper MASTER STREAM


  // Setup the Video Info Header
	FillChar(IH, 0, sizeof(IH));
	IH.rcSource.left := 0;
	IH.rcSource.top := 0;
	IH.rcSource.right := Width;
	IH.rcSource.bottom := Height;
	IH.rcTarget.left := 0;
	IH.rcTarget.top := 0;
	IH.rcTarget.right := Width;
	IH.rcTarget.bottom := Height;
	IH.dwBitRate := Width*Height*BitrateNum;
	IH.AvgTimePerFrame := AvgTimePerFrame; // (1/29.97) in 100-ns units // time per frame
  IH.bmiHeader.biSize := sizeof(BITMAPINFOHEADER);
	IH.bmiHeader.biWidth := Width;
	IH.bmiHeader.biHeight := Height;
	IH.bmiHeader.biPlanes := 1;
  IH.bmiHeader.biBitCount := 32;
	IH.bmiHeader.biCompression := MAKEFOURCC('W','M','V','1'); // wmv1 is faster
	IH.bmiHeader.biSizeImage := 0;
	IH.bmiHeader.biXPelsPerMeter := 0;
 	IH.bmiHeader.biYPelsPerMeter := 0;
  IH.bmiHeader.biClrUsed := 0;
 	IH.bmiHeader.biClrImportant := 0;

  videoBitRate := Width*Height*BitrateNum; // kbits // vid quality
  // create the profile
  WMCreateProfileManager(profileManager);
  profileManager.CreateEmptyProfile(WMT_VER_9_0, profile);
  profile.SetName(StringToOleStr(PROFILE_NAME));
  profile.SetDescription(StringToOleStr(PROFILE_NAME));
  profile.CreateNewStream(WMMEDIATYPE_Video, stream);
  stream.SetStreamName(StringToOleStr('Video'));
  stream.SetBitrate(videoBitRate);
  stream.SetBufferWindow(BUFFER_WINDOW);

  // config video media type
  stream.QueryInterface(IID_IWMMediaProps, mediaProps);
  mediaProps.GetMediaType(nil, msize);
  GetMem(pmt, msize);
  mediaProps.GetMediaType(pmt, msize);
  with pmt^ do
  begin
    majortype := WMMEDIATYPE_Video;
    subtype := WMMEDIASUBTYPE_WMV1; //WMMEDIASUBTYPE_WMV3;
    bFixedSizeSamples := False;
    bTemporalCompression := True;
    pUnk := nil;
    vih := PVideoInfoHeader(pbFormat);
    // copy video info header (the same as with the original - copy: rcSource, rcTarget, AvgTimePerFrame, biWidth, biHeight)

    CopyMemory(vih, @IH, SizeOf(TVideoInfoHeader));
    // set bit rate at the same value
    vih.dwBitRate := videoBitRate;
    // set new compression ('WMV3')
    vih.bmiHeader.biCompression := MAKEFOURCC('W', 'M', 'V', '1'); // wmv1 is faster
  end;
  mediaProps.SetMediaType(pmt);
  FreeMem(pmt, msize);

  // set media props
  stream.QueryInterface(IID_IWMVideoMediaProps, vmediaProps);
  vmediaProps.SetQuality(75); // quality
  vmediaProps.SetMaxKeyFrameSpacing(MAX_KEY_FRAME_SPACING);

  // add video stream
  profile.AddStream(stream);

  // add audio stream (if needed)
  if True then // has Audio // removed
  begin
  {  profile.CreateNewStream(WMMEDIATYPE_Audio, stream);
    stream.SetStreamName(StringToOleStr('Audio'));
    audioBitRate := 32000*2*16;//audioInfo.nSamplesPerSec * audioInfo.nChannels * audioInfo.wBitsPerSample;
    stream.SetBitrate(audioBitRate);
    stream.SetBufferWindow(BUFFER_WINDOW); // auto
    // config video media type
    stream.QueryInterface(IID_IWMMediaProps, mediaProps);
    mediaProps.GetMediaType(nil, msize);
    GetMem(pmt, msize);
    hr := mediaProps.GetMediaType(pmt, msize);
    with pmt^ do
    begin
      // uncompressed audio
      majortype := WMMEDIATYPE_Audio;
     // subtype := WMMEDIASUBTYPE_PCM;
      formattype := WMFORMAT_WaveFormatEx;
      cbFormat := sizeof(TWaveFormatEx);
      bFixedSizeSamples := True;
      bTemporalCompression := False;
      lSampleSize := 16;//2*16{audioInfo.nChannels * audioInfo.wBitsPerSample }{div 8;
      pUnk := nil;
      wfe := PWaveFormatEx(pbFormat);
      // copy video info header (the same as with the original)
      //CopyMemory(wfe, audioInfo, SizeOf(TWaveFormatEx));
    end;
    mediaProps.SetMediaType(pmt);
    FreeMem(pmt, msize);
    // add video stream
    profile.AddStream(stream);         }
  end;

  VCOCoRes := VCOIMux.QueryInterface(IID_IConfigAsfWriter, Config);
  Config.ConfigureFilterUsingProfile(profile);
  N_Dump1Str( 'VCOCoRes while VCOIMux.QueryInterface( IID_IConfigAsfWriter,' +
                                                           IntToStr(VCOCoRes) );

  // Render the video capture and preview pins - even if the capture filter only
  // has a capture pin (and no preview pin) this should work... because the
  // capture graph builder will use a smart tee filter to provide both capture
  // and preview.  We don't have to worry.  It will just work.

  // NOTE that we try to render the interleaved pin before the video pin, because
  // if BOTH exist, it's a DV filter and the only way to get the audio is to use
  // the interleaved pin.  Using the Video pin on a DV filter is only useful if
  // you don't want the audio.

  VCOCoRes := VCOICaptGraphBuilder.RenderStream
           ( @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, VCOIVideoCaptFilter,
                                                Nil, VCOIMux ); // no compression filter needed
    N_Dump1Str(
         'VCOCoRes while RenderStream(@PIN_CATEGORY_CAPTURE, Capt Compr Mux 1' +
                                                           IntToStr(VCOCoRes) );
  if VCOCoRes <> NOERROR then
  begin
    VCOCoRes := VCOICaptGraphBuilder.RenderStream
                 ( @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, VCOIVideoCaptFilter,
                                                Nil, VCOIMux); // no compression filter needed
      N_Dump1Str(
         'VCOCoRes while RenderStream(@PIN_CATEGORY_CAPTURE, Capt Compr Mux 2' +
                                                           IntToStr(VCOCoRes) );
    if VCOCoRes <> NOERROR then
    begin
      K_CMShowMessageDlg( 'Cannot render video capture stream', mtError );
      goto SetupCaptureFail;
    end;
  end;

  WrkString := N_CMVideo4Form.CMVFPProfile^.CMDPStrPar2[6]; // set renderer

  if WrkString = '0' then
  begin
  // Set VMR filter
  VCOVmrMixerControl7 := nil;

  VCOCoRes := CoCreateInstance( CLSID_VideoMixingRenderer, nil,
                          CLSCTX_INPROC_SERVER, IID_IBaseFilter, VCOVmrFilter );
  if Succeeded(VCOCoRes) then
  begin
    VCOCoRes := VCOIGraphBuilder.AddFilter( VCOVmrFilter,
                                                    'Video Mixing Renderer 7' );
    N_Dump1Str( 'VCOCoRes while AddFilter(VCOVmrFilter 7, = ' +
                                                           IntToStr(VCOCoRes) );
    if Succeeded(VCOCoRes) then
    begin
      VCOCoRes := VCOVmrFilter.QueryInterface( IID_IVMRFilterConfig,
                                                          VCOVmrFilterConfig7 );
      if Succeeded(VCOCoRes) then
      begin
        // We need to set the number of streams to be able to use the mixer and this must before setting window mode
        VCOVmrFilterConfig7.SetNumberOfStreams(1);
        // Set flip if needed
        VCOCoRes := VCOVmrFilterConfig7.QueryInterface( IID_IVMRMixerControl,
                                                          VCOVmrMixerControl7 );
        if Succeeded(VCOCoRes) then
        begin
          VCOFlipRect7.Left   := 0;
          VCOFlipRect7.Top    := 0;
          VCOFlipRect7.Right  := 1;
          VCOFlipRect7.Bottom := 1;
          // Note: Using -1 instead of swapping does not work correctly
          if VCOFlip then
          begin
            VCOFlipRect7.Left  := 1;
            VCOFlipRect7.Right := 0;
          end;
        end;
        VCOVmrMixerControl7.SetOutputRect( 0, VCOFlipRect7 );
      end;

      // Set windowless
      VCOCoRes := VCOVmrFilterConfig7.SetRenderingMode( VMRMode_Windowless );
      if Succeeded(VCOCoRes) then
      begin
        VCOCoRes := VCOVmrFilter.QueryInterface( IID_IVMRWindowlessControl,
                                                         VCOWindowlessControl );
        if Succeeded(VCOCoRes) then
        begin
          IVMRWindowlessControl( VCOWindowlessControl).SetVideoClippingWindow
                                                              (VCOWindowHandle); // Set handle of the window for video
          IVMRWindowlessControl( VCOWindowlessControl).SetVideoPosition
                                                     ( Nil, @VCOCurWindowRect ); // Set rectangle for video
        end
        else
        begin
          K_CMShowMessageDlg( 'Unable to get IVMRWindowlessControl', mtError );
          Exit;
        end;
      end;

      VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_PREVIEW, Nil,
                                       VCOIVideoCaptFilter, Nil, VCOVmrFilter );
      if not( Succeeded(VCOCoRes) ) then
        Exit;
    end;
  end;
  end;

  if WrkString = '1' then
  begin
  // Set VMR9 filter
  VCOVmrMixerControl9 := nil;

  VCOCoRes := CoCreateInstance( CLSID_VideoMixingRenderer9, nil,
                          CLSCTX_INPROC_SERVER, IID_IBaseFilter, VCOVmrFilter );
  if Succeeded(VCOCoRes) then
  begin
    VCOCoRes := VCOIGraphBuilder.AddFilter( VCOVmrFilter,
                                                    'Video Mixing Renderer 9' );
                     N_Dump1Str( 'VCOCoRes while AddFilter(VCOVmrFilter 9, = ' +
                                                           IntToStr(VCOCoRes) );
    if Succeeded(VCOCoRes) then
    begin
      VCOCoRes := VCOVmrFilter.QueryInterface( IID_IVMRFilterConfig9,
                                                          VCOVmrFilterConfig9 );
      if Succeeded(VCOCoRes) then
      begin
        // We need to set the number of streams to be able to use the mixer and this must before setting window mode
        VCOVmrFilterConfig9.SetNumberOfStreams(1);
        // Set flip if needed
        VCOCoRes := VCOVmrFilterConfig9.QueryInterface( IID_IVMRMixerControl9,
                                                          VCOVmrMixerControl9 );
        if Succeeded(VCOCoRes) then
        begin
          VCOFlipRect9.Left   := 0;
          VCOFlipRect9.Top    := 0;
          VCOFlipRect9.Right  := 1;
          VCOFlipRect9.Bottom := 1;
          // Note: Using -1 instead of swapping does not work correctly
          if VCOFlip then
          begin
            VCOFlipRect9.Left  := 1;
            VCOFlipRect9.Right := 0;
          end;
        end;
        VCOVmrMixerControl9.SetOutputRect( 0, @VCOFlipRect9 );
      end;

      // Set windowless
      VCOCoRes := VCOVmrFilterConfig9.SetRenderingMode( VMRMode_Windowless );
      if Succeeded(VCOCoRes) then
      begin
        VCOCoRes := VCOVmrFilter.QueryInterface( IID_IVMRWindowlessControl9,
                                                         VCOWindowlessControl );
        if Succeeded(VCOCoRes) then
        begin
          IVMRWindowlessControl9( VCOWindowlessControl ).SetVideoClippingWindow
                                                            ( VCOWindowHandle ); // Set handle of the window for video
          IVMRWindowlessControl9( VCOWindowlessControl ).SetVideoPosition
                                                     ( Nil, @VCOCurWindowRect ); // Set rectangle for video
        end
        else
        begin
          K_CMShowMessageDlg( 'Unable to get IVMRWindowlessControl', mtError );
          Exit;
        end;
      end;

      // render vmr
      VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_PREVIEW,
                     @MEDIATYPE_Video, VCOIVideoCaptFilter, Nil, VCOVmrFilter );
      if not( Succeeded(VCOCoRes) ) then
        Exit;
    end;
  end;
  end;

  if WrkString = '2' then
  begin
  // set evr filter
    VCOCoRes := CoCreateInstance( N_CLSID_EnhancedVideoRenderer, nil,
                                       CLSCTX_INPROC, IID_IBaseFilter, VCOEVR );
    if not Succeeded( VCOCoRes ) then
    begin
      N_Dump1Str( 'Could not create the Enhanced Video Renderer: ' +
                                                           IntToStr(VCOCoRes) );
      Exit;
    end;
    VCOCoRes := VCOIGraphBuilder.AddFilter( VCOEVR, 'EVR' );
    N_Dump1Str( 'VCOCoRes while AddFilter(VCOEVR, = '+ IntToStr(VCOCoRes) );
    if not Succeeded( VCOCoRes ) then
    begin
      K_CMShowMessageDlg( 'Could not add Enhanced Video Renderer: ' +
                                                           IntToStr(VCOCoRes), mtError );
      Exit;
    end;
   ( VCOEVR as N_IMFGetService ).GetService( N_MR_Video_Render_Service,
                              N_IID_IMFVideoDisplayControl, VCODisplayControl );

    VCOFlipRectEVR.MFVNRLeft   := 0;
    VCOFlipRectEVR.MFVNRTop    := 0;
    VCOFlipRectEVR.MFVNRRight  := 1;
    VCOFlipRectEVR.MFVNRBottom := 1;
    if VCOFlip then // flip
    begin;
      //VCOCoRes := VCOIVideoControl.SetMode(IPinTemp, VideoControlFlag_Trigger);
      VCOFlipRectEVR.MFVNRLeft  := 1;
      VCOFlipRectEVR.MFVNRRight := 0;
    end;

    //FDisplayControl.SetAspectRatioMode(MFVideoARMode_None);
    VCODisplayControl.IMFVDCSetVideoWindow  ( VCOWindowHandle );
    VCODisplayControl.IMFVDCSetVideoPosition( Nil, @VCOCurWindowRect );

    VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_PREVIEW,
                           @MEDIATYPE_Video, VCOIVideoCaptFilter, Nil, VCOEVR );
      if not( Succeeded(VCOCoRes) ) then
      begin
        N_Dump1Str( 'Could not render stream: ' + IntToStr(VCOCoRes) );
        Exit;
      end;
  end;

  // Render the audio capture pin?

  if True then //VCOCapAudio then // removed
  begin
  {  VCOCoRes := VCOICaptGraphBuilder.RenderStream
      ( @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Audio, VCOIAudioCaptFilter, Nil,
                                                                      VCOIMux );
    if VCOCoRes <> NOERROR then
    begin
      ShowMessage( 'Cannot render audio capture stream' );
      goto SetupCaptureFail;
    end;  }
  end;

  VCOStillPin := Nil;

  if not Assigned( VCOIVideoCaptFilter ) then
  begin
  K_CMShowMessageDlg( 'Not assigned VCOIVideoCaptFilter', mtError );
  N_Dump1Str ( 'Not assigned VCOIVideoCaptFilter' );
  end;

  VCOCoRes := VCOICaptGraphBuilder.FindPin( VCOIVideoCaptFilter, PINDIR_OUTPUT,
                              @PIN_CATEGORY_STILL, Nil, False, 9, VCOStillPin );

  if not( Succeeded(VCOCoRes) ) then
  begin
    VCOSampleGrabberFlag := False;  // not using sg
    N_Dump1Str( 'VCOSampleGrabberFlag := False' );
  end else
  begin
    VCOSampleGrabberFlag := True; // using sg (with still)
    N_Dump1Str( 'VCOSampleGrabberFlag := True' );
  end;

  if VCOSampleGrabberFlag then
  begin

  if Assigned( VCOStillPin ) then
  begin
    N_Dump1Str( 'IPinTemp is assigned' );

    if Assigned( VCOIVideoControl ) then
      N_Dump1Str( 'VCOIVideoControl2 is assigned' )
    else
      N_Dump1Str( 'VCOIVideoControl2 is not assigned' );
  end else
    N_Dump1Str( 'VCOStillPin is not assigned' );

  // Create Sample Grabber Filter
  VCOISampleGrabFilter  := Nil;
  VCONullRendererFilter := Nil;

  VCOCoRes := CoCreateInstance( CLSID_SampleGrabber, Nil, CLSCTX_INPROC_SERVER,
    IID_IBaseFilter, VCOISampleGrabFilter );

  if VCOCheckRes(30) then
    Exit;
  // get ISampleGrabber Interface
  VCOISampleGrabber := Nil;
  VCOCoRes := VCOISampleGrabFilter.QueryInterface( IID_ISampleGrabber,
                                                            VCOISampleGrabber );
  if VCOCheckRes(31) or (VCOISampleGrabber = Nil) then
    Exit;

  // add VCOISampleGrabFilter to Filter Graph
  VCOCoRes := VCOIGraphBuilder.AddFilter( VCOISampleGrabFilter,
                                                             'Sample Grabber' );
  N_Dump1Str('VCOCoRes while AddFilter( VCOISampleGrabFilter, = '+ IntToStr(VCOCoRes));
  if VCOCheckRes(32) then
    Exit;

  // Get and Add Null Renderer Filter (to discard frames which passed SampleGrabber)
  VCOCoRes := CoCreateInstance( CLSID_NullRenderer, Nil, CLSCTX_INPROC_SERVER,
                                       IID_IBaseFilter, VCONullRendererFilter );
  if VCOCheckRes(555) then
    Exit;

  VCOCoRes := VCOIGraphBuilder.AddFilter( VCONullRendererFilter,
                                                              'Null Renderer' );
  N_Dump1Str( 'VCOCoRes while AddFilter( VCONullRendererFilter, = ' +
                                                           IntToStr(VCOCoRes) );
  if VCOCheckRes(556) then
    Exit;

  VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_STILL,
                    @MEDIATYPE_Video, VCOIVideoCaptFilter, VCOISampleGrabFilter,
                                                        VCONullRendererFilter );
  // Set buffering (not callback) mode for ISampleGrabber
  VCOCoRes := VCOISampleGrabber.SetBufferSamples( True );

  if VCOCheckRes(34) then
    Exit;

  // Do not stop Graph on grbbing first Sample
  VCOCoRes := VCOISampleGrabber.SetOneShot( False );

  if VCOCheckRes(35) then
    Exit;

  end;

  VCOCoRes := VCOIMediaControl.Run();
  N_Dump1Str( 'VCOCoRes = '+IntToStr(VCOCoRes) );

{$IFDEF REGISTER_FILTERGRAPH}
  VCOCoRes := AddGraphToRot( VCOIGraphBuilder, g_dwGraphRegister );
  if FAILED(VCOCoRes) then
  begin
    K_CMShowMessageDlg( Format('Failed to register filter graph with ROT!  hr=0x%x',
                                                                  [VCOCoRes]), mtError );
    g_dwGraphRegister := 0;
  end;
{$ENDIF}

  VCOPrepVideoWindow(); // no errors checked inside

  // *** Do not start Capture Stream when Graph would Run
  VCOControlStream( [csfCapture, csfStop] );
  if VCOIError > 0 then
    Exit;

  N_CMVideo4Form.CMVFTimerCount := 0;
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
end; // procedure TN_VideoCaptObj4.VCOPrepRecordGraph2
{$ENDIF VER150} //****** no code in Delphi 7

// *************************************** TN_VideoCaptObj4.VCONukeDownStream ***
// Destroy stream
//
// Parameter:
// pf - action Filter.
//
procedure TN_VideoCaptObj4.VCONukeDownStream( F: IBaseFilter );
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
end; // procedure TN_VideoCaptObj4.VCONukeDownStream( pf: IBaseFilter );

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
  wsz := Format( 'FilterGraph %p pid %x', [Pointer(Graph),
                                                       GetCurrentProcessId()] );
  Result := CreateItemMoniker( '!', StringToOleStr(wsz), Moniker );
  if ( Result <> S_OK ) then
    Exit;
  Result  := ROT.Register( 0, Graph, Moniker, ID );
  Moniker := nil;
end;// function AddGraphToRot( Graph: IFilterGraph; out ID: integer ): HResult;

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
  ROT    := nil;
end; // function RemoveGraphFromRot( ID: integer ): HRESULT;

// ************************************** TN_VideoCaptObj4.VCOStartRecording ***
// Start Recording Video
//
procedure TN_VideoCaptObj4.VCOStartRecording();
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
end; // procedure TN_VideoCaptObj4.VCOStartRecording

// *************************************** TN_VideoCaptObj4.VCOStopRecording ***
// Stop Recording Video
//
// Parameters
// Result - Return Recorded File Name
//
function TN_VideoCaptObj4.VCOStopRecording(): string;
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
end; // function TN_VideoCaptObj4.VCOStopRecording

// ******************************************************** EncodeYUV2ToRGB ***
// Stop Recording Video
//
// Parameters
// PBytesTemp - Bytes Array
// PDIB - DIB Info
//
function EncodeYUV2ToRGB( PBytesTemp: PByte; PDIB: TN_PDIBInfo ): TN_DIBObj;
var
  TempPtr:  PByte;
  YUV2:     TN_BArray;
  RGB:      TN_BArray;
  i, j:     integer;
  TempReal: Real;
begin
  // ***** 2 arrays: 2 bytes for pixel (yuv2) and 3 bytes per pixel (rgb)
  SetLength( YUV2,  PDIB.bmi.biHeight*PDIB.bmi.biWidth * 2 );
  SetLength( RGB, PDIB.bmi.biHeight*PDIB.bmi.biWidth * 3 );

  // ***** get yuv2 (2 bytes per pixel)
  for i:=0 to Length( YUV2 ) - 1 do
  begin
    TempPtr := PBytesTemp;
    Inc( TempPtr, i );

    YUV2[i] := TempPtr^;
  end;
  j := 0;

  // ***** convert yuv2 pixels to rgb
  for i:= 0 to Length( YUV2 ) - 5 do
  begin
    if (i mod 4) = 0 then begin // every 4 bytes (cause there are 4 bytes per 2 pixels in yuv2 )
    // ***** 1st pixel
    // B
    TempReal := YUV2[i] + 2.03211 * ( YUV2[i+1] - 128 );
    if ( TempReal > 0 ) and ( TempReal < 255 ) then
      RGB[j] := Round( TempReal )
    else
      RGB[j] := 0;
    Inc( j );
    // G
    TempReal := YUV2[i] - 0.39465 * ( YUV2[i+3]-128 ) - 0.58060 *
                                                              ( YUV2[i+1]-128 );
    if ( TempReal > 0 ) and ( TempReal < 255 ) then
      RGB[j] := Round( TempReal )
    else
      RGB[j] := 0;
    Inc(j);
    // R
    TempReal := YUV2[i] + 1.13983 * ( YUV2[i+3]-128 );
    if ( TempReal > 0 ) and ( TempReal < 255 ) then
      RGB[j]:= Round( TempReal )
    else
      RGB[j]:= 0;
    Inc(j);

    // ***** 2nd pixel
    // B
    TempReal := YUV2[i+2] + 2.03211 * ( YUV2[i+1]-128 );
    if ( TempReal > 0 ) and ( TempReal < 255 ) then
      RGB[j]:= Round( TempReal )
    else
      RGB[j]:= 0;
    Inc(j);
    // G
    TempReal := YUV2[i+2] - 0.39465 * (YUV2[i+3]-128) - 0.58060 *
                                                              ( YUV2[i+1]-128 );
    if ( TempReal > 0 ) and ( TempReal < 255 ) then
      RGB[j]:= Round( TempReal )
    else
      RGB[j]:= 0;
    Inc(j);
    // R
    TempReal := YUV2[i+2] + 1.13983 * ( YUV2[i+3]-128 );
    if ( TempReal > 0 ) and ( TempReal < 255 ) then
      RGB[j]:= Round( TempReal )
    else
      RGB[j]:= 0;
    Inc(j);

    end;
  end;

  // ***** create dib
  Result := TN_DIBObj.Create();
  Result.PrepEmptyDIBObj( PDIB );

  // set pixels
  for i := 0 to Result.DIBInfo.bmi.biHeight - 1 do // along all pixel rows
  begin
    Move( RGB[(Result.DIBInfo.bmi.biHeight-1-i)*3 * Result.DIBInfo.bmi.biWidth],
                               ( Result.PRasterBytes + (i*Result.RRLineSize) )^,
                                                 Result.DIBInfo.bmi.biWidth*3 );
  end;
end; // function EncodeYUV2ToRGB

// ****************************************** TN_VideoCaptObj4.VCOGrabSample ***
// Grab current Sample
//
// Parameters
// Result - Return Grabbed Sample as DIB Object
//
function TN_VideoCaptObj4.VCOGrabSample(): TN_DIBObj;
var
  BitsBufSize: integer;
  PDIB:        TN_PDIBInfo;
  MediaType:   TAMMediaType;
  TempBytes:   array of Byte;
  Jpeg:        TJPEGImage;
  Stream:      TMemoryStream;
  Bmp:         TBitmap;
begin
  Result := Nil;
  VCOIError := 60;
  VCOSError := 'VCOISampleGrabber = Nil';
  if VCOISampleGrabber = nil then
    Exit; // a precaution

  // *** Get DIB Info and create empty DIB obj using it
  ZeroMemory( @MediaType, SizeOf(TAMMediaType) );

  VCOCoRes := VCOISampleGrabber.GetConnectedMediaType( MediaType );
  if VCOCheckRes(61) then
    Exit;

  PDIB := TN_PDIBInfo( @(PVideoInfoHeader(MediaType.pbFormat)^.bmiHeader) );
  if Assigned( N_BinaryDumpProcObj ) then
  begin // Save DIBInfo dump for debug
    N_BinaryDumpProcObj( 'VCOGrab1', PDIB, PDIB^.bmi.biSize );
  end;

  Result := TN_DIBObj.Create();
  Result.PrepEmptyDIBObj( PDIB );

  // *** Get DIB Content (Sample bits) in

  BitsBufSize := PDIB.bmi.biSizeImage;
  N_Dump1Str( 'bmi - biSizeImage = '+ IntToStr(PDIB.bmi.biSizeImage) );
  N_Dump1Str( 'bmi - biWidth = '    + IntToStr(PDIB.bmi.biWidth) );
  N_Dump1Str( 'bmi - biHeight = '   + IntToStr(PDIB.bmi.biHeight) );
  N_Dump1Str( 'bmi - biBitCount = ' + IntToStr(PDIB.bmi.biBitCount) );
  N_Dump1Str( 'bmi - biSize = '     + IntToStr(PDIB.bmi.biSize) );

  N_Dump1Str( 'Compression = '+IntToStr(PDIB.bmi.biCompression));

  // *** Get BufSize for Sample content for debug
  N_i := 0;
  VCOCoRes := VCOISampleGrabber.GetCurrentBuffer( N_i, Nil );
  N_Dump1Str( 'VCOISampleGrabber.GetCurrentBuffer 1 = ' + IntToStr(N_i) +
                                           'VCOCoRes = ' + IntToStr(VCOCoRes) );
  if (N_i <= 0) or VCOCheckRes(62) then
    Exit;

  N_Dump1Str( 'GUID: '+GUIDToString(MediaType.SubType) );
  if IsEqualGUID( MediaType.SubType, MEDIASUBTYPE_YUY2 ) then // if yuv2
  begin
    SetLength( TempBytes, PDIB.bmi.biSizeImage );
    N_i := VCOISampleGrabber.GetCurrentBuffer( BitsBufSize, TempBytes );
    N_Dump1Str( 'VCOISampleGrabber.GetCurrentBuffer 2 = '+IntToStr(N_i) );
    Result := EncodeYUV2ToRGB( @TempBytes[0], PDIB ); // decode to rgb
    N_Dump1Str( 'Image is decoded from YUY2 to RGB' );
  end
  else
  if IsEqualGUID( MediaType.SubType, MEDIASUBTYPE_MJPG ) then // if jpg
  begin

    try // catching exception for when the image is incomplete (scanner plugged off)

    Jpeg := TJPEGImage.Create();
    Stream := TMemoryStream.Create();
    N_i := VCOISampleGrabber.GetCurrentBuffer( BitsBufSize, Result.PRasterBytes);

    // Load data to stream
    Stream.Write( Result.PRasterBytes^, BitsBufSize );
    // Move to stream beginning
    Stream.Position := 0;

    N_Dump1Str( 'Before assign' );
    Jpeg.LoadFromStream( Stream ); // creating jpeg from buffer

    Bmp := TBitmap.Create();
    Bmp.Assign( Jpeg ); // cast bmp from jpeg
    Result := TN_DIBObj.Create(Bmp);

    N_Dump1Str( 'VCOISampleGrabber.GetCurrentBuffer 2 = '+IntToStr(N_i) );

    except
    on E : Exception do
    begin
      N_Dump1Str( 'Unable to save JPEG file. ' +
                        E.ClassName+' error raised, with message: '+E.Message );
    end;
    end;

  end
  else
  begin // rgb
    N_i := VCOISampleGrabber.GetCurrentBuffer( BitsBufSize,
                                                          Result.PRasterBytes );
    N_Dump1Str( 'VCOISampleGrabber.GetCurrentBuffer 2 = '+IntToStr(N_i) );
  end;

  if Assigned( N_BinaryDumpProcObj ) then
  begin // Save RasterBytes dump for debug
    N_BinaryDumpProcObj( 'VCOGrab2', Result.PRasterBytes,
                                                        PDIB^.bmi.biSizeImage );
  end;

  // added for mirror
  if VCOFlip then
  begin
    Result.FlipHorizontal;
  end;

  // ***** All Objects Ctreated OK
  VCOIError := 0;
  VCOSError := '';
end; // function TN_VideoCaptObj4.VCOGrabSample

// ***************************************** TN_VideoCaptObj4.VCOGrabSample2 ***
// Grab current Sample (without using SampleGrabber filter)
//
// Parameters
// Result - Return Grabbed Sample as DIB Object
//
function TN_VideoCaptObj4.VCOGrabSample2(): TN_DIBObj;
var
  BitmapPtr: PBitmap;
  WrkString: string;
  TempBufSize: Cardinal;
  Temp:      LONGLONG;
  BMInfo:    BITMAPINFOHEADER;
  BytePtr:   TN_BytesPtr;
  i:         integer;
  PtrTemp, PtrTemp2: TN_BytesPtr;
  TempRect:  TRect;
begin
  Result := Nil;

  WrkString := N_CMVideo4Form.CMVFPProfile^.CMDPStrPar2[6]; // get renderer

  if ( WrkString = '0' ) or ( WrkString = '1' ) then // vmrs
  begin
    IVMRWindowlessControl(VCOWindowlessControl).GetCurrentImage( BitmapPtr );
    if BitmapPtr <> Nil then
    begin
      Result := TN_DIBObj.Create();
      Result.LoadFromMemBMP( BitmapPtr );
    end;
  end;

  if (WrkString = '2') then
  begin
   BMInfo.biSize := sizeof( BITMAPINFOHEADER );

   Result := TN_DIBObj.Create();

   // ***** set proper size (full size of an image)
   TempRect := VCOCurWindowRect;
   TempRect.Right  := TempRect.Left + N_CMVideo4F.N_CMVideo4Form.XWidth;
   TempRect.Bottom := TempRect.Top  + N_CMVideo4F.N_CMVideo4Form.YHeight;

   VCODisplayControl.IMFVDCSetVideoPosition(@VCOFlipRectEVR, @TempRect); // set this size for a moment

   // get an image (buffer) from the screen
   VCOCoRes := VCODisplayControl.IMFVDCGetCurrentImage( @BMInfo, BytePtr,
                                                           TempBufSize, @Temp );

   if BytePtr <> Nil then
   begin

     // set the previous preview size
     VCODisplayControl.IMFVDCSetVideoPosition( @VCOFlipRectEVR,
                                                            @VCOCurWindowRect );

     Result.PrepEmptyDIBObj( TN_PDIBInfo(@BMInfo) );

     // pass the image (buffer)
     for i := 0 to TempBufSize - 1 do // along all pixel rows
     begin
       PtrTemp := Result.PRasterBytes;
       PtrTemp2 := BytePtr;
       Inc(PtrTemp, i);
       Inc(PtrTemp2, i);

       Move( PtrTemp2^, PtrTemp^, Sizeof(Byte) );
     end;

     CoTaskMemFree(BytePtr);
   end;

  end;

  // ***** All Objects Ctreated OK
  VCOIError := 0;
  VCOSError := '';
end; // function TN_VideoCaptObj4.VCOGrabSample2

// ************************************ TN_VideoCaptObj4.VCOShowFilterDialog ***
// Show given Filter Properties Dialog, provided by installed Driver
//
// Parameters
// AIFilter      - given Filter (or Pin)
// AWindowHandle - any Windows Window Handle (Dialog Owner?)
//
procedure TN_VideoCaptObj4.VCOShowFilterDialog( AIFilter: IBaseFilter;
                                                       AWindowHandle: THandle );
var
  WindowCaption: WideString;
  PropertyPages: ISpecifyPropertyPages;
  Pages:         CAUUID;
  FilterInfo:    TFilterInfo;
  PFilterUnk:    IUnknown;
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
  AIFilter.QueryInterface( IUnknown, PFilterUnk );

  // Get properties array
  PropertyPages.GetPages( Pages );
  PropertyPages := nil;

  // Show modal form
  WindowCaption := VCOVCaptDevName + ' (2)';
  // 'Properties' token will be added!
  OleCreatePropertyFrame( AWindowHandle, 0, 0, PWideChar(WindowCaption), 1,
                           @pfilterUnk, Pages.cElems, Pages.pElems, 0, 0, nil );

  // Clean
  PFilterUnk := nil;
  FilterInfo.pGraph := nil;

  CoTaskMemFree( Pages.pElems );
  VCOIError := 0;
end; // procedure TN_VideoCaptObj4.VCOShowFilterDialog

// ************************************ TN_VideoCaptObj4.VCOShowStreamDialog ***
// Show StreamConfig Properties Dialog, provided by installed Driver
//
// Parameters
// AWindowHandle - any Windows Window Handle (Dialog Owner?)
//
procedure TN_VideoCaptObj4.VCOShowStreamDialog( AWindowHandle: THandle );
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
      CoRes := StreamConfig.QueryInterface( ISpecifyPropertyPages,
                                                                PropertyPages );

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
        CoTaskMemFree( Pages.pElems );
      end; // if SUCCEEDED(CoRes) then // Interface PropertyPages found
    end; // if SUCCEEDED(CoRes) then // Interface StreamConfig found

  finally
    // Run graph
    VCOIMediaControl.Run;
  end;

  VCOIError := 0;
end; // procedure TN_VideoCaptObj4.VCOShowStreamDialog

// *************************************** TN_VideoCaptObj4.VCOControlStream ***
// Control Capture or Preview Stream
//
// Parameters
// AFlags - Control Stream Flags (csfPreview, csfCapture, csfStart, csfStop)
//
procedure TN_VideoCaptObj4.VCOControlStream( AFlags: TN_ControlStreamFlags );
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
  N_Dump1Str( 'ControlStream( pCategory, = ' + IntToStr(VCOCoRes) +
                     ', Start = ' + IntToStr(tStart) + 'Stop'+IntToStr(tStop) );
  if VCOCheckRes(50) then
    Exit;
     // Sleep(2500);
  VCOIError := 0;
  VCOSError := '';
end; // procedure TN_VideoCaptObj4.VCOControlStream


// *************************  Global Procedures  ***************

// ******************************************************* N_DSFreeMediaType ***
// Free Objects in given AMMediaType record, created inside DirectShow
//
// Parameters
// APMediaType - Pointer to given AMMediaType record
//
procedure N_DSFreeMediaType( APMediaType: PAMMediaType );
begin
  CoTaskMemFree(APMediaType^.pbFormat);

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
  CoTaskMemFree    ( APMediaType );
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
  hr:            HResult;
  DeviceNameObj: OleVariant;
  pMoniker:      IMoniker;
  pFilter:       IBaseFilter;
  PropertyName:  IPropertyBag;
  pDevEnum:      ICreateDevEnum;
  pEnum:         IEnumMoniker;
  pbc:           IBindCtx;
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
  N_Dump1Str( 'Error in N_DSEnumFilters, HResult = ' + IntToStr(hr) );
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
  AvailableNames, NeededNames: TStringList;

  PinsEnumerator:   IEnumPins;
  Pin: IPin;
  hr: HResult;
  TempInt: Integer;
Label Fin;
begin
  AvailableNames := TStringList.Create;
  NeededNames := TStringList.Create;

  Result := nil;
  N_DSEnumFilters( CLSID_VideoCompressorCategory, '', AvailableNames, AErrCode );//clsidDeviceClass, '', AvailableNames, AErrCode );
  AFilterName := N_NotUsedStr;
  if AErrCode > 0 then
    Exit;

   {
  N_MemIniToStrings( ASectionName, NeededNames ); // retrive NeededNames

  for i := 0 to NeededNames.Count - 1 do // along all NeededNames
  begin
   if AvailableNames.IndexOf( NeededNames[i] ) >= 0 then
  end;

  WrkString := N_CMVideo4Form.CMVFPProfile^.CMDPStrPar2[7]; // get a compression filter

  for i := 0 to NeededNames.Count - 1 do // along all NeededNames
  begin
    if NeededNames[i] = N_NotUsedStr then
      goto Fin; // needed Result is nil

    if (AvailableNames.IndexOf( NeededNames[i] ) >= 0 ) and (WrkString = IntToStr(i)) then
    // NeededNames[i] is available
    begin
      Result := N_DSEnumFilters(clsidDeviceClass, NeededNames[i], nil,
        AErrCode);
      if (AErrCode > 0) or (Result = nil) then
        Continue; // a precaution

      AFilterName := AvailableNames[i];//NeededNames[i];
      goto Fin;
    end;
  end; // for i := 0 to NeededNames.Count-1 do // along all NeededNames
  }

  N_Dump2Str( 'Compression filter at the moment: ' + AFilterName );
    goto Fin;
  // ***** Here: all Needed Names are not available!

  Result := Nil;

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
  VCO: TN_VideoCaptObj4;
begin
  VCO := TN_VideoCaptObj4.Create;

  VCO.VCOVCaptDevName := ADevName;

  VCO.VCOPrepInterfaces2();

  if VCO.VCOIError = 0 then
    VCO.VCOEnumVideoSizes( AResList, Nil )
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
  VCO: TN_VideoCaptObj4;
begin
  VCO := TN_VideoCaptObj4.Create;

  VCO.VCOVCaptDevName := ADevName;
  VCO.VCOPrepInterfaces2();

  if VCO.VCOIError = 0 then
    VCO.VCOEnumVideoCaps( AResList )
  else
  begin
    AResList.Clear;
    AResList.Add(Format( 'VCO Error %d, %s', [VCO.VCOIError, VCO.VCOSError]) );
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
  else if IsEqualGUID(AGUID, MEDIASUBTYPE_ARGB32) then
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

// ****************************************************** VCOPrepInterfaces2 ***
//
// VCOPrepInterfaces for Mode 2
//
procedure TN_VideoCaptObj4.VCOPrepInterfaces2();
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
    K_CMShowMessageDlg( 'Error Creating Device Enumerator', mtError );
    Exit;
  end;

  // Search for needed device
  VCOCoRes := CreateDevEnum.CreateClassEnumerator
                                      ( CLSID_VideoInputDeviceCategory, Em, 0 );
  if ( VCOCoRes <> NOERROR ) then
  begin
    K_CMShowMessageDlg( 'Sorry, you have no video capture hardware', mtError );
    Exit;
  end;
  if Assigned( Em ) then
    Em.Reset
  else
    Exit;
  while ( Em.Next(1, M, @Fetched) = S_OK ) do
  begin
    VCOCoRes := M.BindToStorage( Nil, Nil, IPropertyBag, Bag );
    if ( Succeeded(VCOCoRes) ) then
    begin
      VCOCoRes := Bag.Read( 'FriendlyName', Name, Nil );
      if ( VCOCoRes = NOERROR ) then
      begin
        if ( Name = VCOVCaptDevName ) then
          VCOVideoMoniker := M;
      end;
      Bag := Nil;
    end;
    M := Nil;
  end;
  Em := Nil;

  if True then //VCOCapAudio then // removed
  begin
  {
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
  }
  end;

  // do we want closed Captioning?
  VCOCapCC := False;

  // do we want to use entered frame rate?
  VCOUseFrameRate := True;
  UnitsPerFrame := 666667; // 15fps
  VCOFrameRate := 10000000. / UnitsPerFrame;
  VCOFrameRate := ( VCOFrameRate * 100 ) / 100.;

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
    K_CMShowMessageDlg( 'Cannot instantiate filtergraph', mtError );
    goto InitCapFiltersFail;
  End;

  VCOCoRes := VCOICaptGraphBuilder.SetFiltergraph( VCOIGraphBuilder );
  if VCOCoRes <> NOERROR then
  Begin
    K_CMShowMessageDlg( 'Cannot give graph to builder', mtError );
    goto InitCapFiltersFail;
  End;
  GetMem( Temp, SizeOf(WideChar) * Succ(Length(VCOWachFriendlyName)) );
  StringToWideChar( VCOWachFriendlyName, Temp, Succ(Length(VCOWachFriendlyName))
                                                                              );
  // Temp := gcap.wachFriendlyName;
  VCOCoRes := VCOIGraphBuilder.AddFilter( VCOIVideoCaptFilter, Temp );
  N_Dump1Str( 'VCOCoRes while AddFilter(VCOIVideoCaptFilter, = ' +
                                                           IntToStr(VCOCoRes) );
  if VCOCoRes <> NOERROR then
  begin
    K_CMShowMessageDlg( Format('Error %x: Cannot add vidcap to filtergraph',
                                                         [VCOCoRes]), mtError );
    goto InitCapFiltersFail;
  end;

  // ***** get VCOIMediaControl Interface for controlling media streams
  VCOIMediaControl := nil;
  VCOCoRes := VCOIGraphBuilder.QueryInterface( IID_IMediaControl,
                                                             VCOIMediaControl );

  if VCOCheckRes(15) then
    Exit; // Errors 13, 14 not used now

  VCOIVideoControl := Nil;
  VCOCoRes := VCOIVideoCaptFilter.QueryInterface( IID_IAMVideoControl,
                                                             VCOIVideoControl );
  if Succeeded(VCOCoRes) then
    N_Dump1Str(
          'QueryInterface(IID_IAMVideoControl, VCOIVideoControl) is succeeded' )
  else
    N_Dump1Str(
     'QueryInterface(IID_IAMVideoControl, VCOIVideoControl) is not succeeded' );

  // ***** get VCOIStreamConfig Interface to get/set Video Format anVCOIVideoControld Size
  VCOIStreamConfig := nil;
  N_Dump2Str( 'VCOCaptPin=' + inttostr(VCOCaptPin) );

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
      K_CMShowMessageDlg( Format( 'Error %x: Cannot find VCapture:IAMStreamConfig',
                                                         [VCOCoRes]), mtError );
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

  if True then //VCOCapAudio then // removed
  begin
  {
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
    N_Dump1Str('VCOCoRes while AddFilter(VCOIAudioCaptFilter, = ' +
                                                           IntToStr(VCOCoRes) );
    if VCOCoRes <> NOERROR then
    begin
      ShowMessage( Format( 'Error %x: Cannot add audcap to filtergraph',
                                                                  [VCOCoRes]) );
      goto InitCapFiltersFail;
    end;
  }
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
end; // procedure TN_VideoCaptObj4.VCOPrepInterfaces2

// ******************************************************* VCOPrepGrabGraph2 ***
//
// VCOPrepGrabGraph for Mode 3
//
procedure TN_VideoCaptObj4.VCOPrepGrabGraph2();
var
  WrkString: string;
begin
  WrkString := N_CMVideo4Form.CMVFPProfile^.CMDPStrPar2[6]; // get renderer

  if WrkString = '0' then
  begin
  // Set VMR filter
  VCOVmrMixerControl7 := nil;

  VCOCoRes := CoCreateInstance( CLSID_VideoMixingRenderer, nil,
                          CLSCTX_INPROC_SERVER, IID_IBaseFilter, VCOVmrFilter );
  if Succeeded(VCOCoRes) then
  begin
    VCOCoRes := VCOIGraphBuilder.AddFilter( VCOVmrFilter,
                                                    'Video Mixing Renderer 7' );
    N_Dump1Str( 'VCOCoRes while AddFilter(VCOVmrFilter 7, = ' +
                                                           IntToStr(VCOCoRes) );
    if Succeeded(VCOCoRes) then
    begin
      VCOCoRes := VCOVmrFilter.QueryInterface( IID_IVMRFilterConfig,
                                                          VCOVmrFilterConfig7 );
      if Succeeded(VCOCoRes) then
      begin
        // We need to set the number of streams to be able to use the mixer and this must before setting window mode
        VCOVmrFilterConfig7.SetNumberOfStreams(3);
        // Set flip if needed
        VCOCoRes := VCOVmrFilterConfig7.QueryInterface( IID_IVMRMixerControl,
                                                          VCOVmrMixerControl7 );
        if Succeeded(VCOCoRes) then
        begin
          VCOFlipRect7.Left  := 0;
          VCOFlipRect7.Top    := 0;
          VCOFlipRect7.Right  := 1;
          VCOFlipRect7.Bottom := 1;
          // Note: Using -1 instead of swapping does not work correctly
          if VCOFlip then
          begin
            VCOFlipRect7.Left  := 1;
            VCOFlipRect7.Right := 0;
          end;
        end;
        VCOVmrMixerControl7.SetOutputRect( 0, VCOFlipRect7 );
      end;

      // Set windowless
      VCOCoRes := VCOVmrFilterConfig7.SetRenderingMode( VMRMode_Windowless );
      if Succeeded(VCOCoRes) then
      begin
        VCOCoRes := VCOVmrFilter.QueryInterface( IID_IVMRWindowlessControl,
                                                         VCOWindowlessControl );
        if Succeeded(VCOCoRes) then
        begin
          IVMRWindowlessControl(VCOWindowlessControl).SetVideoClippingWindow
                                                            ( VCOWindowHandle ); // Set handle of the window for video
          IVMRWindowlessControl(VCOWindowlessControl).SetVideoPosition
                                                     ( Nil, @VCOCurWindowRect ); // Set rectangle for video
        end
        else
        begin
          K_CMShowMessageDlg( 'Unable to get IVMRWindowlessControl', mtError );
          Exit;
        end;
      end;

      VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_PREVIEW, Nil,
                                       VCOIVideoCaptFilter, Nil, VCOVmrFilter );
      if not( Succeeded(VCOCoRes) ) then
        Exit;
    end;
  end;
  end;

  if WrkString = '1' then
  begin
  // Set VMR9 filter
  VCOVmrMixerControl9 := Nil;

  VCOCoRes := CoCreateInstance( CLSID_VideoMixingRenderer9, nil,
                          CLSCTX_INPROC_SERVER, IID_IBaseFilter, VCOVmrFilter );
  if Succeeded(VCOCoRes) then
  begin
    VCOCoRes := VCOIGraphBuilder.AddFilter( VCOVmrFilter,
                                                    'Video Mixing Renderer 9' );
    N_Dump1Str( 'VCOCoRes while AddFilter(VCOVmrFilter 9, = ' +
                                                           IntToStr(VCOCoRes) );
    if Succeeded(VCOCoRes) then
    begin
      VCOCoRes := VCOVmrFilter.QueryInterface( IID_IVMRFilterConfig9,
                                                          VCOVmrFilterConfig9 );
      if Succeeded(VCOCoRes) then
      begin
        // We need to set the number of streams to be able to use the mixer and this must before setting window mode
        VCOVmrFilterConfig9.SetNumberOfStreams(1);
        // Set flip if needed
        VCOCoRes := VCOVmrFilterConfig9.QueryInterface( IID_IVMRMixerControl9,
                                                          VCOVmrMixerControl9 );
        if Succeeded(VCOCoRes) then
        begin
          VCOFlipRect9.Left   := 0;
          VCOFlipRect9.Top    := 0;
          VCOFlipRect9.Right  := 1;
          VCOFlipRect9.Bottom := 1;
          // Note: Using -1 instead of swapping does not work correctly
          if VCOFlip then
          begin
            VCOFlipRect9.Left  := 1;
            VCOFlipRect9.Right := 0;
          end;
        end;
        VCOVmrMixerControl9.SetOutputRect( 0, @VCOFlipRect9 );
      end;

      // Set windowless
      VCOCoRes := VCOVmrFilterConfig9.SetRenderingMode( VMRMode_Windowless );
      if Succeeded(VCOCoRes) then
      begin
        VCOCoRes := VCOVmrFilter.QueryInterface( IID_IVMRWindowlessControl9,
                                                         VCOWindowlessControl );
        if Succeeded(VCOCoRes) then
        begin
          IVMRWindowlessControl9(VCOWindowlessControl).SetVideoClippingWindow
                                                            ( VCOWindowHandle ); // Set handle of the window for video
          IVMRWindowlessControl9(VCOWindowlessControl).SetVideoPosition
                                                     ( Nil, @VCOCurWindowRect ); // Set rectangle for video
        end
        else
        begin
          K_CMShowMessageDlg( 'Unable to get IVMRWindowlessControl', mtError );
          Exit;
        end;
      end;

      // render vmr
      VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_PREVIEW,
                     @MEDIATYPE_Video, VCOIVideoCaptFilter, Nil, VCOVmrFilter );
      if not( Succeeded(VCOCoRes) ) then
        Exit;
    end;
  end;
  end;

  if WrkString = '2' then
  begin
  // ***** set evr

    VCOCoRes := CoCreateInstance( N_CLSID_EnhancedVideoRenderer, Nil,
                                       CLSCTX_INPROC, IID_IBaseFilter, VCOEVR );
    if not Succeeded(VCOCoRes) then
    begin
      N_Dump1Str( 'Could not create the Enhanced Video Renderer : ' +
                                                           IntToStr(VCOCoRes) );
      Exit;
    end;
    VCOCoRes := VCOIGraphBuilder.AddFilter( VCOEVR, 'EVR' );
    N_Dump1Str( 'VCOCoRes while AddFilter(VCOEVR, = ' + IntToStr(VCOCoRes) );
    if not Succeeded(VCOCoRes) then
    begin
      N_Dump1Str( 'Could not add Enhanced Video Renderer: ' +
                                                           IntToStr(VCOCoRes) );
      Exit;
    end;
    ( VCOEVR as N_IMFGetService ).GetService( N_MR_Video_Render_Service,
                              N_IID_IMFVideoDisplayControl, VCODisplayControl );

    VCOFlipRectEVR.MFVNRLeft   := 0;
    VCOFlipRectEVR.MFVNRTop    := 0;
    VCOFlipRectEVR.MFVNRRight  := 1;
    VCOFlipRectEVR.MFVNRBottom := 1;
    if VCOFlip then // flip
    begin;
      //VCOCoRes := VCOIVideoControl.SetMode(IPinTemp, VideoControlFlag_Trigger);
       VCOFlipRectEVR.MFVNRLeft  := 1;
       VCOFlipRectEVR.MFVNRRight := 0;
     end;

    //FDisplayControl.SetAspectRatioMode(MFVideoARMode_None);
    VCODisplayControl.IMFVDCSetVideoWindow  ( VCOWindowHandle );
    VCODisplayControl.IMFVDCSetVideoPosition( Nil, @VCOCurWindowRect );

    VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_PREVIEW,
                           @MEDIATYPE_Video, VCOIVideoCaptFilter, Nil, VCOEVR );
    if not( Succeeded(VCOCoRes) ) then
    begin
      K_CMShowMessageDlg( 'Could not render stream: ' + IntToStr(VCOCoRes), mtError );
      Exit;
    end;
  end;

  if N_CMVideo4Form.CMVFPProfile^.CMDPStrPar2[4] = '1' then // if there is still pin
  begin

    VCOStillPin := Nil;

    if not Assigned( VCOIVideoCaptFilter ) then
    begin
      N_Dump1Str( 'Not assigned VCOIVideoCaptFilter' );
    end;

    VCOCoRes := VCOICaptGraphBuilder.FindPin( VCOIVideoCaptFilter,
               PINDIR_OUTPUT, @PIN_CATEGORY_STILL, Nil, False, 0, VCOStillPin );

    if not( Succeeded(VCOCoRes) ) then
    begin
      VCOSampleGrabberFlag := False; // not using sg
      N_Dump1Str( 'VCOSampleGrabberFlag := False' );
    end else
    begin
      VCOSampleGrabberFlag := True; // using sg with still pin
      N_Dump1Str( 'VCOSampleGrabberFlag := True' );
    end;

  end
  else
  begin
    VCOSampleGrabberFlag := False; // not using sg
  end;

  if VCOSampleGrabberFlag then
  begin

    if Assigned( VCOStillPin ) then
    begin
      N_Dump1Str( 'IPinTemp is assigned' );

      if Assigned( VCOIVideoControl ) then
        N_Dump1Str( 'VCOIVideoControl2 is assigned' )
      else
        N_Dump1Str( 'VCOIVideoControl2 is not assigned' );

    end else
      N_Dump1Str( 'IPinTemp is not assigned' );

    // Create Sample Grabber Filter
    VCOISampleGrabFilter  := Nil;
    VCONullRendererFilter := Nil;

    VCOCoRes := CoCreateInstance( CLSID_SampleGrabber, NIL,
                  CLSCTX_INPROC_SERVER, IID_IBaseFilter, VCOISampleGrabFilter );

    if VCOCheckRes(30) then
      Exit;
    // get ISampleGrabber Interface
    VCOISampleGrabber := Nil;
    VCOCoRes := VCOISampleGrabFilter.QueryInterface( IID_ISampleGrabber,
                                                            VCOISampleGrabber );

    if VCOCheckRes(31) or (VCOISampleGrabber = nil) then
      Exit;

    // add VCOISampleGrabFilter to Filter Graph
    VCOCoRes := VCOIGraphBuilder.AddFilter( VCOISampleGrabFilter,
                                                             'Sample Grabber' );
    N_Dump1Str( 'VCOCoRes while AddFilter(VCOISampleGrabFilter, = ' +
                                                           IntToStr(VCOCoRes) );

    if VCOCheckRes(32) then
      Exit;

    // Get and Add Null Renderer Filter (to discard frames which passed SampleGrabber)
    VCOCoRes := CoCreateInstance( CLSID_NullRenderer, NIL, CLSCTX_INPROC_SERVER,
                                       IID_IBaseFilter, VCONullRendererFilter );
    if VCOCheckRes(555) then
      Exit;
    VCOCoRes := VCOIGraphBuilder.AddFilter( VCONullRendererFilter,
                                                              'Null Renderer' );
    N_Dump1Str( 'VCOCoRes while AddFilter(VCONullRendererFilter, = ' +
                                                           IntToStr(VCOCoRes) );

    if VCOCheckRes(556) then
      Exit;

    VCOCoRes := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_STILL,
                    @MEDIATYPE_Video, VCOIVideoCaptFilter, VCOISampleGrabFilter,
                                                        VCONullRendererFilter );

    // Set buffering (not callback) mode for ISampleGrabber
    VCOCoRes := VCOISampleGrabber.SetBufferSamples( True );

    if VCOCheckRes(34) then
      Exit;

    // Do not stop Graph on grbbing first Sample
    VCOCoRes := VCOISampleGrabber.SetOneShot( False );

    if VCOCheckRes(35) then
      Exit;

    VCOIGrabberChild := N_GrabberChild.Create(); // creating an object with our callbacks

    VCOCoRes := VCOISampleGrabber.SetCallback( (VCOIGrabberChild), 1 );
    N_Dump1Str( 'Set callback = ' + IntToStr(VCOCoRes) );

  end;

  VCOCoRes := VCOIMediaControl.Run();
  N_Dump1Str( 'VCOCoRes = '+IntToStr(VCOCoRes) );

  if VCOCheckRes(37) then
  begin
    VCODumpString( 'Something wrong in IMediaControl.Run' );
    Exit;
  end;

  if N_CMVideo4Form.CMVFPProfile^.CMDPStrPar2[4] = '1' then // still pin
  if Assigned( VCOStillPin ) then // found
  if VCOIVideoControl <> Nil then // set up
  begin

    VCOCoRes := VCOIVideoControl.SetMode( VCOStillPin, VideoControlFlag_Trigger );
    if Succeeded(VCOCoRes) then
    begin
      N_Dump1Str( 'SetMode is succeeded' );
    end
    else
      N_Dump1Str( 'SetMode is not succeeded, VCOCoRes = ' + IntToStr(VCOCoRes));

  end;

  VCOIVideoProcAmp := nil;
  VCOCoRes := VCOIVideoCaptFilter.QueryInterface( IID_IAMVideoProcAmp, VCOIVideoProcAmp );

	if (FAILED(VCOCoRes)) then
	begin
    N_Dump1Str( 'VCOIVideoProcAmp failed' );
		// The device does not support IAMVideoProcAmp
	end
	else
	begin
		{long Min, Max, Step, Default, Flags, Val;

		// Get the range and default values
		hr = pProcAmp->GetRange(VideoProcAmp_Brightness, &Min, &Max, &Step, &Default, &Flags);
		hr = pProcAmp->GetRange(VideoProcAmp_BacklightCompensation, &Min, &Max, &Step, &Default, &Flags);
		hr = pProcAmp->GetRange(VideoProcAmp_Contrast, &Min, &Max, &Step, &Default, &Flags);
		hr = pProcAmp->GetRange(VideoProcAmp_Saturation, &Min, &Max, &Step, &Default, &Flags);
		hr = pProcAmp->GetRange(VideoProcAmp_Sharpness, &Min, &Max, &Step, &Default, &Flags);
		hr = pProcAmp->GetRange(VideoProcAmp_WhiteBalance, &Min, &Max, &Step, &Default, &Flags);
		if (SUCCEEDED(hr))
		{
			hr = pProcAmp->Set(VideoProcAmp_Brightness, 142, VideoProcAmp_Flags_Manual);
			hr = pProcAmp->Set(VideoProcAmp_BacklightCompensation, 0, VideoProcAmp_Flags_Manual);
			hr = pProcAmp->Set(VideoProcAmp_Contrast, 4, VideoProcAmp_Flags_Manual);
			hr = pProcAmp->Set(VideoProcAmp_Saturation, 100, VideoProcAmp_Flags_Manual);
			hr = pProcAmp->Set(VideoProcAmp_Sharpness, 0, VideoProcAmp_Flags_Manual);
			hr = pProcAmp->Set(VideoProcAmp_WhiteBalance, 2800, VideoProcAmp_Flags_Manual);
		}
	end;

  VCORecordGraph := False;
  VCOGrabGraph   := True;
{$IFDEF REGISTER_FILTERGRAPH}
  VCOCoRes := AddGraphToRot( VCOIGraphBuilder, g_dwGraphRegister );
  if ( Failed(VCOCoRes) ) then
  begin
    K_CMShowMessageDlg( Format('Failed to register filter graph with ROT!  hr=0x%x',
                                                               [hr]), mtError );
    g_dwGraphRegister := 0;
  end;
{$ENDIF}

  // ***** GrabGraph Created OK and now in Run state
  VCOIError := 0;
  VCOSError := '';
  // Form2.ShowModal;
end; // procedure TN_VideoCaptObj4.VCOPrepGrabGraph2
end.
