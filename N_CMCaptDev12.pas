unit N_CMCaptDev12;
// EzSensor(MediaRay+) device

// 2016.08.22 - implemented a native log
// 2018.11.07 - CDSGetDefaultDevIconInd function added

interface

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev12F, N_CML2F;

const
 // acquisition flags tVDACQ_CallBackRec.rFlags
  N_VDACQ_FBright      = 1;      // acquire bright frame (dark otherwise)
  N_VDACQ_FTestPat     = 2;      // acquire test pattern  (TFT only)
  N_VDACQ_FRecentFrame = 4;      // retrieve recent frame (TFT only)
  //#define cVDACQ_FBrightIgn   (1<<31) // ignore state of the bit 'Bright' for machine control (affects some TFT only)
  // acquisition event types tVDACQ_CallBackRec.rType
  N_VDACQ_ETTrace      = 0;      // various information messages (mainly from acquistion thread<s>)
  N_VDACQ_ETTraceT     = 1;      // time-stamp and the information message
  N_VDACQ_ETErr        = 2;      // an error from the library's acquisition code
  N_VDACQ_ETLastErr    = 3;      // an error from Windows API, described by 'GetLastError'
  N_VDACQ_ETWSAErr     = 4;      // an error from Windows ocket
  // acquisition events tVDACQ_CallBackRec.rEvent
  N_VDACQ_EAbort       = 1;      // application invokes VDACQ_Abort
  N_VDACQ_EClose       = 2;      // application invokes VDACQ_Close
  N_VDACQ_ECapture     = 20;     // a message from the library's acquisition thread<s>
  N_VDACQ_ECapturePerc = 21;     // acquisition thread<s> tells percentage of completeness
  N_VDACQ_ECaptureRecv = 22;     // acquisition thread<s> informs about new received data
  N_VDACQ_EIdle        = 23;     // acquisition thread tells that it have had idle time-slice

  // calibration flags
  N_VDC_FCalOffs    = 1;        // apply offset/dark calibration
  N_VDC_FCalGain    = 2;        // apply gain/bright calibration
  N_VDC_FBadPixMap  = 4;        // request application of bad pixels map
  N_VDC_FDespeckle  = 8;        // apply despeckle
  N_VDC_FOptDist    = 16;       // apply optical distortion correction
  N_VDC_FAuxLnRecal = 32;       // apply auxiliary lines re-calibration
  N_VDC_FTempDirIP = (1 Shl 31);  // save temporary images in default image direcotory
  // calibration event types
  N_VDC_ETTrace    = 0;        // information message from calibration code
  N_VDC_ETTraceT   = 1;        // time-stamp and information message
  N_VDC_ETErr      = 2;        // an error from the library's calibration code
  // calibration events
  N_VDC_EAbort     = 1;        // application invokes VDC_Abort
  N_VDC_EClose     = 2;        // application invokes VDC_Close
  N_VDC_ECalib     = 20;       // a message from the library's calibration code
  N_VDC_ECalibPerc = 21;       // calibration code tells percentage of completeness

  // img process flags
  N_VDIP_FDespeckle = 1;       // apply despeckle
  N_VDIP_F3PCurve   = 2;       // apply 3-points curve
  N_VDIP_FUSMask    = 4;       // apply all unsharpen filters
  // img process event types
  N_VDIP_ETTrace    = 0;       // information message from 'enhancement' code
  N_VDIP_ETTraceT   = 1;       // time-stamp and information message
  N_VDIP_ETErr      = 2;       // an error from the library's 'enhancement' code
  // img process events
  N_VDIP_EAbort     = 1;       // application invokes VDIP_Abort
  N_VDIP_EClose     = 2;       // application invokes VDIP_Close
  N_VDIP_EEnh       = 20;      // information message from 'enhancement' code
  N_VDIP_EEnhPerc   = 21;      // 'enhancement' code tells percentage of completeness

  N_VDEnu_IOraSt_Legacy      = 1;          // legacy EzSensor (without serial ID)
  N_VDEnu_IOraSt_MultiSensor = 2;     // new EzSensor with serial ID

  N_VDEnu_IOraErr_NotInst  = -1;       // driver isn't installed
  N_VDEnu_IOraErr_MultConn = -2;      // simultaneous connection (it might be not an error at all)
  N_VDEnu_IOraErr_NoConn   = -3;        // no one detector is connected
  N_VDEnu_IOraErr_UnsupPID = -4;      // unsupported PID
  N_VDEnu_IOraErr_Busy     = -5;          // device is busy by another application
  N_VDEnu_IOraErr_DetBrdConn   = -6;    // detector is not connected (while board is connected to PC)
  N_VDEnu_IOraErr_SerialID     = -7;      // wrong format of serial ID in detector's memory
  N_VDEnu_IOraErr_DevInterface = -20; // 'DeviceInterfaceDetail' fault
  N_VDEnu_IOraErr_WrongDevPath = -21; // substring PID is abcent
  N_VDEnu_IOraErr_IORequest    = -22;    // 'DeviceIoControl' fault
  N_VDEnu_IOraErr_SerialIDRead = -23; // can't read serial ID from connected detector

type TN_VDEnu_IOra = record
  rPID:    integer;           // USB PID (usually it should be displayed as 4-digits hex number)
  rStatus: integer;           // cVDEnu_IOraSt_xxxx or cVDEnu_IOraErr_xxxx
  rSerialId: array [0..31] of AnsiChar;  // proprietary serial ID from detector's memory
  rCfgName:  array [0..191] of AnsiChar;  // suggested path of configuration file
  rDLLName:  array [0..191] of AnsiChar;  // suggested path of detector's library
  rCalDir:   array [0..191] of AnsiChar;   // suggested calibration directory
end; // type TN_VDEnu_IOra = record

type UnionCapture = record
  case Byte of
  0: (rCaptureRows:   integer;);   // # of received rows
  1: (rCaptureFrames: integer;);   // # of received frames (when framegrabber is used)
end; // type UnionCapture = record

type TN_VDACQ_CallBackRec = record
  rFlags:  integer;            // combination of cVDACQ_Fxxxx
  rType:   integer;            // cVDACQ_ETxxx
  rEvent:  integer;            // cVDACQ_Exxx
  rSocket: integer;            // 0:no socket relation; otherwise socket's ID>0
  rMsg: array[0..255] of AnsiChar;         // message text
  rFrameWidth:  integer;       // full frame width
  rFrameHeight: integer;       // full frame height
  rFrameBuffer: PSmallInt;     // user supplied frame buffer "AFrameBuffer"

  rCaptureRowsFrames: UnionCapture; // union

  rCapturePercent:   integer; // percentage for a gauge; >100 indicates success completion
  rUserCallBackProc: Pointer; // user supplied "ACallBackProc"
  rUserParam:        Pointer; // user supplied "AUserParam"
  rAborted:          integer; // 1:VDACQ_Abort called; -1:internally detected error
  rPacketData:       Pointer; // pointer to received packet; not documented  here
  rFGControl:        integer; // framegrabber's control flags
end; // type TN_VDACQ_CallBackRec = record

type TN_VDC_CallBackRec = record
  rFlags: Integer;           // combination of cVDC_Fxxxx
  rType:  Integer;           // cVDC_ETxxx
  rEvent: Integer;           // cVDC_Exxx
  rMsg: array[0..255] of AnsiChar; // message text
  rFrameWidth:   Integer;    // full frame width
  rFrameHeight:  Integer;    // full frame height
  rStoredWidth:  Integer;    // stored image width
  rStoredHeight: Integer;    // stored image height
  rCalibPercent: integer;    // completion (in percents)
  rFrameBuffer:  PSmallInt;  // received frame data
  rImageBuffer:  PSmallInt;  // cut image data (might be nil)
  rUserCallBackProc: Pointer; // user supplied ACallBackProc
  rUserParam:   Pointer;     // user supplied AUserParam
  rAborted:     Integer;     // 1:VDC_Abort called; -1:internally detected error
end; // type TN_VDC_CallBackRec = record

type TN_VDIP_CallBackRec = record
  rFlags: Integer;             // combination of cVDC_Fxxxx
  rType:  Integer;             // cVDC_ETxxx
  rEvent: Integer;             // cVDC_Exxx
  rMsg: array[0..255] of AnsiChar; // message (trace, wrn, err)
  rStoredWidth:  Integer;      // stored image width
  rStoredHeight: Integer;      // stored image height
  rEnhPercent:   Integer;      // processed data in %
  rModeNumber:   Integer;      // img process mode
  rImageBuffer:  PSmallInt;    // image buffer
  rUserCallBackProc: Pointer;  // user supplied "ACallBackProc"
  rUserParam:    Pointer;      // user supplied "AUserParam"
  rAborted:      Integer;      // 1: set by VDIP_Abort; -1:internally
end; // type TN_VDIP_CallBackRec = record

type PN_VDC_CallBackRec   = ^TN_VDC_CallBackRec;
type PN_VDACQ_CallBackRec = ^TN_VDACQ_CallBackRec;
type PN_VDIP_CallBackRec  = ^TN_VDIP_CallBackRec;
type PN_VDEnu_IOra = ^TN_VDEnu_IOra;

type TN_CVAIORA_AcqSDlg = record // parent cWnd
  m_nCurState:  Integer; // stage
  m_nHasErrors: Integer; // non-zero if an error happened

  rACQ_CallBackRec: PN_VDACQ_CallBackRec;
  rC_CallBackRec:   PN_VDC_CallBackRec;
  rIP_CallBackRec:  PN_VDIP_CallBackRec;
  On_ACQ_CallBack:  TN_stdcallProcPtr;
  On_C_CallBack:    TN_stdcallProcPtr;
  On_IP_CallBack:   TN_stdcallProcPtr;
end; // type TN_CVAIORA_AcqSDlg = record

type PN_CVAIORA_AcqSDlg = ^TN_CVAIORA_AcqSDlg;

procedure N_CallBackProc_Acquisition( AR: Pointer ); stdcall;
procedure N_CallBackProc_Calibration( AR: Pointer ); stdcall;
procedure N_CallBackProc_ImgProcess ( AR: Pointer ); stdcall;

type TN_CMCDServObj12 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr:   string;  // Error message
  CDSErrorInt:   integer; // Error code

  function CDSInitAll(): Integer;
  function CDSFreeAll(): Integer;

  procedure CDSCaptureImages ( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;

  destructor Destroy; override;
end; // end of type TN_CMCDServObj11 = class( TK_CMCDServObj )

var
  N_CMECDVDC_SetCalibrationDirectory: TN_stdcallBoolFuncPtr;
  N_CMECDVDC_Process:                 TN_stdcallPtrFuncIntCBP2Ptr;
  N_CMECDVDC_GetCalibrationDirectory: TN_stdcallProcPtr;
  N_CMECDVDACQ_StartFrame:            TN_stdcallBoolFuncPtr;
  N_CMECDVDACQ_Close:                 TN_stdcallProcPtr;
  N_CMECDVDIP_Close:                  TN_stdcallProcPtr;
  N_CMECDVDC_Close:                   TN_stdcallProcPtr;
  N_CMECDVDACQ_Connect:               TN_stdcallPtrFuncIntCBP2PtrInt;
  N_CMECDVD_IniProfSetSection:        TN_stdcallProcConstPtr;
  N_CMECDVD_IniProfGetStr:            TN_stdcallPtrFunc2Ptr;
  N_CMECDVDACQ_GetFrameDim:           TN_stdcallProc2Ptr;
  N_CMECDVDC_GetImageDim:             TN_stdcallBoolFunc2Ptr;
  N_CMECDVDEIOra_EnumConnected:       TN_stdcallIntFuncIntPtr;
  N_CMECDVDEIOra_GetErrMsgText:       TN_stdcallProcIntPtr;
  N_CMECDVDEIOra_Prepare:             TN_stdcallIntFuncPtr;
  N_CMEDVDC_CutImage:                 TN_stdcallPtrFunc2Ptr;
  N_CMEDVDIP_Process:                 TN_stdcallPtrFuncIntCBP2PtrInt;
  N_CMEDVD_LogOpen:                   TN_stdcallProcPtrIntPtr;
  N_CMEDVD_LogMsg:                    TN_stdcallProcPtr;
  N_CMEDVD_LogClose:                  TN_stdcallProcVoid;

  N_CMCDServObj12: TN_CMCDServObj12;

  // ***** AcqApp parameters from example program
  N_FrameWidth:  Integer;  // frame width
	N_FrameHeight: Integer;  // frame height
	N_ImgWidth:    Integer;  // image width
	N_ImgHeight:   Integer;  // image height
	N_VReset:      Integer;  // initialization parameter
	N_IPMode:      Integer;  // image processing mode
	N_BMPCropLeft:   Integer;  // crop columns at left
	N_BMPCropTop:    Integer;  // crop rows at top
	N_BMPCropRight:  Integer;  // crop columns at right
	N_BMPCropBottom: Integer;  // crop rows at bottom
  N_DarkFrame: Boolean;  // acquire dark frame
	N_Canceled:  Boolean;   // if user explicitly cancels acquisition

var
  N_AcqSDlg: TN_CVAIORA_AcqSDlg;

  // ***** flags for CMS interface
  N_FlagAcq:   Boolean; // acquisition flag
  N_FlagCalib: Boolean; // calibration flag
  N_FlagProc:  Boolean; // process flag
  N_FlagAcqCallback:   Boolean; // acquisition callback flag
  N_FlagCalibCallback: Boolean; // calibration callback flag
  N_FlagProcCallback:  Boolean; // process callback flag
  N_FlagCapture:       Boolean; // capture flag
  N_FlagCaptureCall:   Boolean; // capture call flag
  N_FlagDevice:        Boolean; // is device connected/disconnected
  N_FlagRaw:    Boolean; // is raw needed
  N_PrevStatus: Integer; // previous status of device
  N_FlagError:  Boolean; // is error
  N_LastErrMsg: array [0..255] of AnsiChar;

  N_fPxlsize:      float;  // size of the pixel
  //N_ErrorMessage:  string; // device error message

  N_HomeDir: array[0..259] of AnsiChar; // home directory
	N_SaveDir: array[0..259] of AnsiChar; // save directory
	N_IPModes: array[0..259] of AnsiChar; // image processing modes

  N_FrameBufPtr: array of SmallInt; // acquired frame data
	N_ImgBufPtr:   array of SmallInt; // acquired image data

procedure N_StartAcquisition();
procedure N_StopAcquisition();
procedure N_StartCalibration();
procedure N_StopCalibration();
procedure N_StartProcess();
procedure N_StopProcess();
procedure On_ACQ_CallBack( AR: Pointer ); stdcall;
procedure On_C_CallBack  ( AR: Pointer ); stdcall;
procedure On_IP_CallBack ( AR: Pointer ); stdcall;

var
  CMCaptDev12Form: TN_CMCaptDev12Form;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0;

//****************************************************** N_StartAcquisition ***
// Start acquisition of image
//
procedure N_StartAcquisition();
var
  TempInt:   Integer;
begin
  N_AcqSDlg.rACQ_CallBackRec := Nil; // not in an example algorythm

  // parameter for N_CMECDVDACQ_Connect
  if N_DarkFrame then
    TempInt := 0
  else
    TempInt := N_VDACQ_FBright;

  N_Dump1Str( 'Before N_CMECDVDACQ_Connect' );
  // starting acquisition
  N_AcqSDlg.rACQ_CallBackRec := PN_VDACQ_CallBackRec( N_CMECDVDACQ_Connect(
                 TempInt, N_CallBackProc_Acquisition, @N_AcqSDlg, N_FrameBufPtr,
                                                                    N_VReset ));

  N_Dump1Str( 'After N_CMECDVDACQ_Connect' );

  if ( N_AcqSDlg.rACQ_CallBackRec <> Nil ) then
  begin
    N_Dump1Str( 'rFlags = ' + IntToStr(N_AcqSDlg.rACQ_CallBackRec.rFlags) );
    N_Dump1Str( 'rType  = ' + IntToStr(N_AcqSDlg.rACQ_CallBackRec.rType) );
    N_Dump1Str( 'rEvent = ' + IntToStr(N_AcqSDlg.rACQ_CallBackRec.rEvent) );
    N_Dump1Str( 'rSocket = ' + IntToStr(N_AcqSDlg.rACQ_CallBackRec.rSocket) );
    N_Dump1Str( 'rMsg = ' + N_AnsiToString( AnsiString(
                                        @N_AcqSDlg.rACQ_CallBackRec.rMsg[0] )));
    N_Dump1Str( 'rCapturePercent = ' + IntToStr(
                                  N_AcqSDlg.rACQ_CallBackRec.rCapturePercent) );
    N_Dump1Str( 'Frame Width = ' + IntToStr(
                       N_AcqSDlg.rACQ_CallBackRec.rFrameWidth) + ', Height = ' +
                            IntToStr(N_AcqSDlg.rACQ_CallBackRec.rFrameHeight) );
  end;

  if ( N_AcqSDlg.rACQ_CallBackRec = Nil ) then // acquisition start failed
  begin
    N_Dump1Str('Error with acquisition by MediaRay+');

    K_CMShowMessageDlg( 'There is a problem with the USB connection. Please unplug your sensor, check your USB port, and plug the sensor back.', mtError );
    CMCaptDev12Form.Close;
  end
	else // OK
  begin
    N_Dump1Str( 'Before N_CMECDVDACQ_StartFrame' );
	 	N_CMECDVDACQ_StartFrame( N_AcqSDlg.rACQ_CallBackRec ); // creating the frame
    N_Dump1Str( 'After N_CMECDVDACQ_StartFrame' );
  end;
end; // procedure N_StartAcquisition();

//******************************************************* N_StopAcquisition ***
// Stop calibration of image
//
procedure N_StopAcquisition();
begin
  N_FlagAcqCallback := True; // so callback won't starts again for this acquisition

  N_Dump1Str('Before N_CMECDVDACQ_Close');
  N_CMECDVDACQ_Close( N_AcqSDlg.rACQ_CallBackRec ); // close acquisition

  if ( N_AcqSDlg.m_nHasErrors <> 0 ) then // is any errors?
  begin
	  N_Dump1Str( 'Error with acquisition by MediaRay+' );
    N_FlagError := True; // error flag
    N_Dump1Str( 'FlagError = True' );
	 	Exit;
	end
  else
	begin
    N_FlagCalibCallback := True; // flag to start calibration callback
    N_Dump1Str( 'Calibration Callback = True' );
  end;
end; // procedure N_StopAcquisition();

//****************************************************** N_StartCalibration ***
// Start calibration of image after acquisition
//
procedure N_StartCalibration();
var
  qCalibFlags: integer;
begin
  N_AcqSDlg.rC_CallBackRec := Nil; // not in an example algorythm

  // calibration flag, binary summing
  qCalibFlags := N_VDC_FCalOffs or N_VDC_FCalGain or N_VDC_FBadPixMap
                                                           or N_VDC_FTempDirIP;
  if (N_IPMode >= 500) and (N_IPMode < 600) then // if image processing parameter...
  begin
	 		qCalibFlags := qCalibFlags or N_VDC_FDespeckle;
  end;

  N_Dump1Str('m_nIPMode = ' + IntToStr(N_IPMode));

  // start calibration
  N_AcqSDlg.rC_CallBackRec := PN_VDC_CallBackRec( N_CMECDVDC_Process(
          qCalibFlags, N_CallBackProc_Calibration, @N_AcqSDlg, N_FrameBufPtr ));

  // fails to start
  if ( N_AcqSDlg.rACQ_CallBackRec = Nil ) then
  begin
		Inc( N_AcqSDlg.m_nHasErrors ); // increment error count
    N_LastErrMsg := 'Can''t start calibration. Refer LOG\\VACAL00.log.';
    Exit;
  end;
end; // procedure N_StartCalibration();

//****************************************************** N_StopCalibration ***
// Stop calibration of image
//
procedure N_StopCalibration();
begin
  N_FlagCalibCallback := True; // so callback won't starts again for this calib

  N_CMECDVDC_Close( N_AcqSDlg.rC_CallBackRec ); // close calibration
		if ( N_AcqSDlg.m_nHasErrors <> 0 ) then
		begin
      N_FlagError := True; // error flag
      Exit;
    end
		else
		begin
			N_CMEDVDC_CutImage(N_FrameBufPtr, N_ImgBufPtr); // cuts frame for image size

      if not(N_FlagRaw) then // is needed for process?
        N_FlagProcCallback := True // start process
      else
        N_FlagCaptureCall := True; // start saving file
    end;
end; // procedure N_StopCalibration();

//********************************************************** N_StartProcess ***
// Start processing of image after calibration
//
procedure N_StartProcess();
begin
  N_AcqSDlg.rIP_CallBackRec := Nil; // not in an example algorythm

  N_Dump1Str( 'm_nIPMode = ' + IntToStr(N_IPMode) );
  if Assigned( N_ImgBufPtr ) then N_Dump1Str( 'm_ImgBufPtr is assigned' );

  // start process
  N_AcqSDlg.rIP_CallBackRec := PN_VDIP_CallBackRec( N_CMEDVDIP_Process(
                       (N_VDIP_FDespeckle or N_VDIP_F3PCurve or N_VDIP_FUSMask),
                N_CallBackProc_ImgProcess, @N_AcqSDlg, N_ImgBufPtr, N_IPMode ));

  // fails to start
  if ( N_AcqSDlg.rIP_CallBackRec = Nil ) then
  begin
		Inc( N_AcqSDlg.m_nHasErrors ); // increment error count
    N_LastErrMsg := 'Can''t start image process. Refer LOG\\EU00.log.';
    Exit;
  end;
end; // procedure N_StartProcess();

//*********************************************************** N_StopProcess ***
// Stop processing of image
//
procedure N_StopProcess();
begin
  N_FlagProcCallback := True; // so callback won't starts again for this process

  N_CMECDVDIP_Close( N_AcqSDlg.rIP_CallBackRec ); // close process

	if ( N_AcqSDlg.m_nHasErrors = 0 ) then // all the 3 steps ended correctly
	begin
    N_FlagCaptureCall := True; // callback funcs are closed, starting saving
	end
  else
    N_FlagError := True; // error flag

  N_Dump1Str( 'Finish StopProcess' );
	Exit;
end; // procedure N_StopProcess();

//********************************************************* On_ACQ_CallBack ***
// Callback function for acquisition
//
//     Parameters
// AR - acquisition callback record
//
procedure On_ACQ_CallBack( AR: Pointer ); stdcall;
var
  i: integer;
begin

	case PN_VDIP_CallBackRec(AR).rType of

	// errors
	N_VDACQ_ETErr:
  begin

    N_Dump1Str( 'Error 2 cVDACQ_ETErr, AR.rType = ' +
                                     IntToStr(PN_VDACQ_CallBackRec(AR).rType) );
		PN_VDACQ_CallBackRec(AR).rUserCallBackProc := Nil; // prevent further calls
		Inc( N_AcqSDlg.m_nHasErrors ); // inc error count

    N_Dump1Str( N_AnsiToString(
                               AnsiString(@PN_VDACQ_CallBackRec(AR).rMsg[0])) );

    for i := 0 to Length(N_LastErrMsg) - 1 do
      N_LastErrMsg[i] := PN_VDACQ_CallBackRec(AR).rMsg[i];

    if ( not( N_Canceled) ) and ( N_AcqSDlg.rACQ_CallBackRec <> Nil ) // cancel is not implemented in the interface
    then
      N_FlagAcqCallback := False; // it is OK to close acquisition

    N_Dump1Str( 'FlagAcqCallback = '+ BoolToStr(N_FlagAcqCallback) );
  end; // N_VDACQ_ETErr:

	N_VDACQ_ETLastErr:
  begin

    N_Dump1Str('Error 3 ETLastErr');
		PN_VDACQ_CallBackRec(AR).rUserCallBackProc := Nil; // prevent further calls
		Inc( N_AcqSDlg.m_nHasErrors ); // inc error count

    N_Dump1Str( N_AnsiToString(
                               AnsiString(@PN_VDACQ_CallBackRec(AR).rMsg[0])) );

    for i := 0 to Length(N_LastErrMsg) - 1 do
      N_LastErrMsg[i] := PN_VDACQ_CallBackRec(AR).rMsg[i];

    if ( not( N_Canceled) ) and ( N_AcqSDlg.rACQ_CallBackRec <> Nil ) // cancel is not implemented in the interface
    then
      N_FlagAcqCallback := False; // it is OK to close acquisition

    N_Dump1Str( 'FlagAcqCallback = '+ BoolToStr(N_FlagAcqCallback) );
  end; // N_VDACQ_ETLastErr:

	N_VDACQ_ETWSAErr:
  begin

    N_Dump1Str( 'Error 4 cVDACQ_ETWSAErr' );
		PN_VDACQ_CallBackRec(AR).rUserCallBackProc := Nil; // prevent further calls
		Inc( N_AcqSDlg.m_nHasErrors ); // inc error count

    N_Dump1Str( N_AnsiToString(
                               AnsiString(@PN_VDACQ_CallBackRec(AR).rMsg[0])) );

  for i := 0 to Length(N_LastErrMsg) - 1 do
      N_LastErrMsg[i] := PN_VDACQ_CallBackRec(AR).rMsg[i];

    if ( not( N_Canceled) ) and ( N_AcqSDlg.rACQ_CallBackRec <> Nil ) // cancel is not implemented in the interface
    then
      N_FlagAcqCallback := False; // it is OK to close acquisition

    N_Dump1Str( 'FlagAcqCallback = '+ BoolToStr(N_FlagAcqCallback) );
  end; // N_VDACQ_ETWSAErr:

	// ***** general messages
	N_VDACQ_ETTrace:
  begin

    case PN_VDACQ_CallBackRec(AR).rEvent of

		N_VDACQ_ECaptureRecv:
    begin
			N_AcqSDlg.m_nCurState := 2; // Stage "Read"
    end; // N_VDACQ_ECaptureRecv:

		N_VDACQ_ECapturePerc:
    begin

			if ( PN_VDACQ_CallBackRec(AR).rCapturePercent = 0 ) then // 0 percents
			begin
				N_AcqSDlg.m_nCurState := 1; // Stage "Wait"
        N_Dump1Str( 'Percent = '+ IntToStr(PN_VDACQ_CallBackRec(AR).rCapturePercent) );
      end // if ( AR.rCapturePercent = 0 )
			else
      begin
				if ( PN_VDACQ_CallBackRec(AR).rCapturePercent > 100 ) then  // success complete
        begin
					PN_VDACQ_CallBackRec(AR).rUserCallBackProc := Nil; // prevent further calls
					if ( not( N_Canceled) ) then // cancel is not implemented in the interface
            N_FlagAcqCallback := False; // OK to close acquisition

          N_Dump1Str( 'Percent = '+
                           IntToStr(PN_VDACQ_CallBackRec(AR).rCapturePercent) ); // close acquisition
        end; // if ( AR.rCapturePercent > 100 )
      end; // else
    end; // N_VDACQ_ECapturePerc:
    end; // switch rEvent
  end; // N_VDACQ_ETTrace:

	N_VDACQ_ETTraceT:
  begin

		case PN_VDACQ_CallBackRec(AR).rEvent of
		N_VDACQ_ECaptureRecv:
    begin
			N_AcqSDlg.m_nCurState := 2; // Stage "Read"
    end; // N_VDACQ_ECaptureRecv:

		N_VDACQ_ECapturePerc:
    begin
			if ( PN_VDACQ_CallBackRec(AR).rCapturePercent = 0 ) then // 0 percents
			begin
				N_AcqSDlg.m_nCurState := 1; // Stage "Wait"
        N_Dump1Str( 'Percent = '+ IntToStr(PN_VDACQ_CallBackRec(AR).rCapturePercent) );
      end // N_VDACQ_ECapturePerc:
			else
      begin
				if ( PN_VDACQ_CallBackRec(AR).rCapturePercent > 100 ) then  // success complete
        begin
					PN_VDACQ_CallBackRec(AR).rUserCallBackProc := Nil; // prevent further calls
					if ( not( N_Canceled) ) then // cancel is not implemented in the interface
            N_FlagAcqCallback := False; // OK to close acquisition

          N_Dump1Str( 'Percent = '+
                           IntToStr(PN_VDACQ_CallBackRec(AR).rCapturePercent) ); // close acquisition
        end; // if ( AR.rCapturePercent > 100 )
      end; // else
    end; // N_VDACQ_ECapturePerc:
    end; // switch rEvent
  end; // N_VDACQ_ETTraceT:
  end; // switch rType
end; // procedure On_ACQ_CallBack

//*********************************************************** On_C_CallBack ***
// Callback function for calibration
//
//     Parameters
// AR - calibration callback record
//
procedure On_C_CallBack( AR: Pointer ); stdcall;
var
  i: integer;
begin

//  N_Dump1Str( 'Calib AR.rType = ' + IntToStr(PN_VDC_CallBackRec(AR).rType) );
//  N_Dump1Str( 'Calib AR.rEvent = ' + IntToStr(PN_VDC_CallBackRec(AR).rEvent) );

  case PN_VDC_CallBackRec(AR).rType of

    // errors
	  N_VDC_ETErr:
    begin

		  PN_VDC_CallBackRec(AR).rUserCallBackProc := Nil; // prevent further calls
		  Inc( N_AcqSDlg.m_nHasErrors ); // inc error count
      N_Dump1Str( N_AnsiToString(
                               AnsiString(@PN_VDACQ_CallBackRec(AR).rMsg[0])) );

      for i := 0 to Length(N_LastErrMsg) - 1 do
        N_LastErrMsg[i] := PN_VDACQ_CallBackRec(AR).rMsg[i];

	   	if ( not( N_Canceled) ) and ( N_AcqSDlg.rACQ_CallBackRec <> Nil )
                                                                            then
      // cancel is not implemented in the interface
      begin
        N_FlagCalibCallback := False; // OK to stop calib
        N_Dump1Str( 'Calibration Callback - False' );
      end;
    end; // N_VDC_ETErr:

    // general messages
	  N_VDC_ETTrace: begin

		  case PN_VDC_CallBackRec(AR).rEvent of

		    N_VDC_ECalibPerc:

        begin
		  	  if ( PN_VDC_CallBackRec(AR).rCalibPercent = 0 ) then // 0 percents
		     	begin
		    		N_AcqSDlg.m_nCurState := 3; // Stage "Process"
            N_Dump1Str( 'Percent = 0' );
          end // if ( AR.rCalibPercent = 0 )
	   	  	else
		    	begin
		    		if (PN_VDC_CallBackRec(AR).rCalibPercent > 100) then // success complete
		    		begin
		  	  		PN_VDC_CallBackRec(AR).rUserCallBackProc := Nil; // prevent further calls
		  	  		if ( not( N_Canceled )) then // cancel is not implemented in the interface
                N_FlagCalibCallback := False; // OK to stop calib
                N_Dump1Str('Calibration Callback - False, Percent > 100');
            end; // (AR.rCalibPercent > 100)
          end; // else
        end; // N_VDC_ECalibPerc:
      end; // switch rEvent
    end; // N_VDC_ETTrace: begin

    N_VDC_ETTraceT:
    begin

      case PN_VDC_CallBackRec(AR).rEvent of

		    N_VDC_ECalibPerc:
        begin
		  	  if ( PN_VDC_CallBackRec(AR).rCalibPercent = 0 ) then // 0 percents
		     	begin
		    		N_AcqSDlg.m_nCurState := 3; // Stage "Process"
            N_Dump1Str( 'Percent = 0' );
          end //  if ( AR.rCalibPercent = 0 )
	   	  	else
		    	begin
		    		if ( PN_VDC_CallBackRec(AR).rCalibPercent > 100 ) then // success complete
		    		begin
		  	  		PN_VDC_CallBackRec(AR).rUserCallBackProc := Nil; // prevent further calls
		  	  		if ( not( N_Canceled )) then // cancel is not implemented in the interface
                N_FlagCalibCallback := False; // close calibration
                N_Dump1Str('Calibration Callback - False, Percent > 100');
            end; // if ( AR.rCalibPercent > 100 )
          end; // else
        end; // N_VDC_ECalibPerc:
      end; // switch rEvent
    end; // N_VDC_ETTraceT:
  end; // switch rType
end; // procedure On_C_CallBack

//********************************************************** On_IP_CallBack ***
// Callback function for process
//
//     Parameters
// AR - process callback record
//
procedure On_IP_CallBack( AR: Pointer ); stdcall;
var
  i: integer;
begin
  case PN_VDIP_CallBackRec(AR).rType of

   	// errors
	  N_VDIP_ETErr:
    begin

      PN_VDIP_CallBackRec(AR).rUserCallBackProc := Nil; // prevent further calls
	   	Inc( N_AcqSDlg.m_nHasErrors ); // inc error count
      N_Dump1Str( N_AnsiToString(
                               AnsiString(@PN_VDACQ_CallBackRec(AR).rMsg[0])) );

      for i := 0 to Length(N_LastErrMsg) - 1 do
        N_LastErrMsg[i] := PN_VDACQ_CallBackRec(AR).rMsg[i];

      if ( not( N_Canceled) ) and ( N_AcqSDlg.rIP_CallBackRec <> Nil )
                                                                            then
      // cancel is not implemented in the interface
      begin
        N_FlagProcCallback := False; // close process
        N_Dump1Str('Process Callback - False');
      end;
    end; // N_VDIP_ETErr:

   	// general messages
	  N_VDIP_ETTrace:
    begin

      case PN_VDIP_CallBackRec(AR).rEvent of

		    N_VDIP_EEnhPerc:
        begin

			    if ( PN_VDIP_CallBackRec(AR).rEnhPercent > 100 ) then // success complete
          begin
				    PN_VDIP_CallBackRec(AR).rUserCallBackProc := Nil; // prevent further calls
				    if ( not( N_Canceled )) then // close image process
              N_FlagProcCallback := False; // close process
          end; // if ( AR.rEnhPercent > 100 )
        end; // N_VDIP_EEnhPerc:
      end; // switch rEvent
    end; //N_VDIP_ETTrace:

	  N_VDIP_ETTraceT:
    begin

		  case PN_VDIP_CallBackRec(AR).rEvent of

		    N_VDIP_EEnhPerc:
        begin

			    if ( PN_VDIP_CallBackRec(AR).rEnhPercent > 100 ) then // success complete
          begin
				    PN_VDIP_CallBackRec(AR).rUserCallBackProc := Nil; // prevent further calls
				    if ( not( N_Canceled )) then // close image process
              N_FlagProcCallback := False; // close process flag
          end; // if ( AR.rEnhPercent > 100 )
        end; //N_VDIP_EEnhPerc:
      end; // switch rEvent
    end; // N_VDIP_ETTraceT:
  end; // switch rType
end; // procedure On_IP_CallBack

//********************************************** N_CallBackProc_Acquisition ***
// Starting callback function for acquisition
//
//     Parameters
// AR - acquisition callback record
//
// Goes as an actual parameter for acquisition function
//
procedure N_CallBackProc_Acquisition( AR: Pointer ); stdcall;
begin
  PN_CVAIORA_AcqSDlg( PN_VDACQ_CallBackRec(AR)^.rUserParam ).On_ACQ_CallBack(AR);
end; // procedure N_CallBackProc_Acquisition

//********************************************** N_CallBackProc_Calibration ***
// Starting callback function for calibration
//
//     Parameters
// AR - calibration callback record
//
// Goes as an actual parameter for calibration function
//
procedure N_CallBackProc_Calibration( AR: Pointer ); stdcall;
begin
  PN_CVAIORA_AcqSDlg( PN_VDC_CallBackRec(AR)^.rUserParam ).On_C_CallBack(AR);
end; // procedure N_CallBackProc_Calibration

//*********************************************** N_CallBackProc_ImgProcess ***
// Starting callback function for process
//
//     Parameters
// AR - process callback record
//
// Goes as an actual parameter for process function
//
procedure N_CallBackProc_ImgProcess( AR: Pointer ); stdcall;
begin
  PN_CVAIORA_AcqSDlg( PN_VDIP_CallBackRec(AR)^.rUserParam ).On_IP_CallBack(AR);
end; // procedure N_CallBackProc_ImgProcess

//************************************************* TN_CMCDServObj12 **********

//********************************************** TN_CMCDServObj3.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj3 Group Name
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj12.CDSInitAll() : Integer;
var
  FuncAnsiName: AnsiString;
  DllFName: string;  // DLL File Name

  procedure ReportError(); // local
  // Report that FuncAnsiName function was not loaded
  begin
    CDSErrorStr := String(FuncAnsiName) + ' not loaded';
    N_Dump1Str( CDSErrorStr );
    Result := 2;
  end; // procedure ReportError(); // local

begin
  N_Dump1Str( 'Start CMCDServObj12.CDSInitAll' );

  if CDSDllHandle <> 0 then // CDSDevInd already initialized
  begin
    CDSFreeAll();
  end; // if CDSDllHandle <> 0 then // CDSDevInd already initialized

  DllFName := 'C:\EzSensor\EzsensorEnu.dll';

  if not FileExists( DllFName ) then
  begin
    CDSErrorStr := DllFName + ' is absent.';
    Result := 10; // dll is absent
    K_CMShowMessageDlg( 'Media Ray Plus is not installed on this PC.' + #13#10 +
                        'Please install the Media Ray Plus CD and start the capture again.' + #13#10 +
                        'Press OK to continue', mtError );
    Exit;
  end;

  CDSErrorStr := '';
  Result := 0;

  N_Dump1Str( 'Before Windows.LoadLibrary ' + DllFName );
  CDSDllHandle := Windows.LoadLibrary( @DllFName[1] );
  N_Dump1Str( Format( 'After Windows.LoadLibrary %s, CDSDllHandle=%X : %s',
                [DllFName, CDSDllHandle, SysErrorMessage( GetLastError() )] ) );


  if CDSDllHandle = 0 then // some error
  begin
    CDSErrorStr := 'Error Loading ' + DllFName;
    Result := 2; // Windows.LoadLibrary failed
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if CDSDllHandle = 0 then // some error

  //***** Load EzSensor DLL functions

  FuncAnsiName := 'VDEIOra_EnumConnected';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDEIOra_EnumConnected := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDEIOra_EnumConnected) then ReportError();

  FuncAnsiName := 'VDEIOra_GetErrMsgText';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDEIOra_GetErrMsgText := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDEIOra_GetErrMsgText) then ReportError();

  FuncAnsiName := 'VDEIOra_Prepare';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDEIOra_Prepare := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDEIOra_Prepare) then ReportError();

  // ***** standart funcs
  DllFName := 'C:\EzSensor\EzSensor.dll';
  CDSErrorStr := '';
  Result := 0;
  //ShowMessage('DLL: '+DllFName);

  N_Dump1Str( 'Before Windows.LoadLibrary ' + DllFName );
  CDSDllHandle := Windows.LoadLibrary( @DllFName[1] );
  N_Dump1Str( Format( 'After Windows.LoadLibrary %s, CDSDllHandle=%X',
                                                    [DllFName,CDSDllHandle] ) );

  if CDSDllHandle = 0 then // some error
  begin
    CDSErrorStr := 'Error Loading ' + DllFName + ': ' +
                                              SysErrorMessage( GetLastError() );
    Result := 2; // Windows.LoadLibrary failed
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if CDSDllHandle = 0 then // some error

  //***** Load EzSensor DLL functions

  FuncAnsiName := 'VDC_SetCalibrationDirectory';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_SetCalibrationDirectory := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_SetCalibrationDirectory) then ReportError();

  FuncAnsiName := 'VDC_Process';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_Process := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_Process) then ReportError();

  FuncAnsiName := 'VDC_GetCalibrationDirectory';
  N_CMECDVDC_GetCalibrationDirectory := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetCalibrationDirectory) then ReportError();

  FuncAnsiName := 'VDACQ_StartFrame';
  N_CMECDVDACQ_StartFrame := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDACQ_StartFrame) then ReportError();

  FuncAnsiName := 'VDACQ_Close';
  N_CMECDVDACQ_Close := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDACQ_Close) then ReportError();

  FuncAnsiName := 'VDIP_Close';
  N_CMECDVDIP_Close := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDIP_Close) then ReportError();

  FuncAnsiName := 'VDC_Close';
  N_CMECDVDC_Close := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_Close) then ReportError();

  FuncAnsiName := 'VDACQ_Connect';
  N_CMECDVDACQ_Connect := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDACQ_Connect) then ReportError();

  FuncAnsiName := 'VD_IniProfSetSection';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVD_IniProfSetSection := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVD_IniProfSetSection) then ReportError();

  FuncAnsiName := 'VD_IniProfGetStr';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVD_IniProfGetStr := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVD_IniProfGetStr) then ReportError();

  FuncAnsiName := 'VDACQ_GetFrameDim';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDACQ_GetFrameDim := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDACQ_GetFrameDim) then ReportError();

  FuncAnsiName := 'VDC_GetImageDim';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetImageDim := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetImageDim) then ReportError();

  FuncAnsiName := 'VDC_CutImage';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMEDVDC_CutImage := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMEDVDC_CutImage) then ReportError();

  FuncAnsiName := 'VDIP_Process';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMEDVDIP_Process := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMEDVDIP_Process) then ReportError();

  FuncAnsiName := 'VD_LogOpen';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMEDVD_LogOpen := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMEDVD_LogOpen) then ReportError();

  FuncAnsiName := 'VD_LogMsg';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMEDVD_LogMsg := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMEDVD_LogMsg) then ReportError();

  FuncAnsiName := 'VD_LogClose';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMEDVD_LogClose := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMEDVD_LogClose) then ReportError();

  if Result <> 0 then // some error while loading DLL Entries
  begin
    K_CMShowMessageDlg( Format( 'Failed to initialise %s Errorcode=%d',
                                           [DllFName, Result] ), mtError );
    CDSFreeAll();
    N_Dump1Str( DllFName + ' Resources freed' );
  end;

  N_Dump1Str( 'MediaRay+ >> CDSInitAll end' );
end; // procedure N_CMCDServObj12.CDSInitAll

//********************************************** TN_CMCDServObj3.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj12.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    N_Dump2Str( 'After EzSensor.dll FreeLibrary' );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj3.CDSFreeAll

//**************************************** N_CMCDServObj12.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj12.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'MediaRay+ >> CDSCaptureImages begin' );
  if CDSInitAll() > 0 then // no device driver installed
    Exit;

  SetLength(ASlidesArray, 0);
  CMCaptDev12Form          := TN_CMCaptDev12Form.Create(application);
  CMCaptDev12Form.ThisForm := CMCaptDev12Form;

  with CMCaptDev12Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'MediaRay+ >> CDSCaptureImages before ShowModal' );

    ShowModal();

    CDSFreeAll();
    N_Dump1Str( 'MediaRay+ >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do

  N_Dump1Str( 'MediaRay+ >> CDSCaptureImages end' );
end; // procedure N_CMCDServObj12.CDSCaptureImages

//******************************** TN_CMCDServObj12.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj12.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 37;
end; // function TN_CMCDServObj12.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj12.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj12.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
    Result := 'IO';
end; // function TN_CMCDServObj12.CDSGetDefaultDevDCMMod

// destructor N_CMCDServObj12.Destroy
//
destructor TN_CMCDServObj12.Destroy();
begin
  //CDSFreeAll();
end; // destructor N_CMCDServObj12.Destroy

Initialization

// Create and Register MediaRay+ Service Object
N_CMCDServObj12 := TN_CMCDServObj12.Create( N_CMECD_MediaRayPlus_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj12 ) do
begin
  CDSCaption := 'MediaRay+';
  IsGroup := False;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj12 ) do

end.
