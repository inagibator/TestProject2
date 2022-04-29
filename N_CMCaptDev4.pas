unit N_CMCaptDev4;

// Schick Device

// 2018.11.07 CDSGetDefaultDevIconInd function added

interface
uses Windows, Classes, Graphics, Forms,
  K_CM0, K_CMCaptDevReg,
  N_Types;

const
  // Schick CDR Devices Names
  N_CMECD_CDR_XRAYName = 'CDR Intraoral';
  N_CMECD_CDR_CEPHName = 'CDR Ceph';
  N_CMECD_CDR_PANOName = 'CDR Pan';

  // Schick CDR Devices Inds
  N_CMECD_CDR_XRAY    = 6; // N_CMECD_CDR_XRAYName
  N_CMECD_CDR_CEPH    = 7; // N_CMECD_CDR_CEPHName
  N_CMECD_CDR_PANO    = 8; // N_CMECD_CDR_PANOName

//***** Schick CDR Constants
	eCDR_XRAY                  =  0;
	eCDR_CEPH                  =  1;
	eCDR_PANO                  =  2;

	eSUCCESS                   =  0;
	eEXCEPTION                 = 21;
	eLPDISPATCH_IS_NULL        = 22;
	eINVALID_INPUT_PARAMETERS  = 23;
	eIMAGE_DATA_ACCESS_FAILURE = 24;
	eMEMORY_ALLOCATION_ERROR   = 25;
	eCREATE_DISPATCH_ERROR     = 26;
	eWRONG_DEVICE_TYPE         = 27;
	eSAVE_TO_FILE_ERROR        = 28;

	AA_NO_AUTO_ACQUIRE =  0; // Not implemented or supported
	AA_NO_HARDWARE     =  1; // No Sensor attached
	AA_NO_FIRMWARE     =  2; // Firmware not loaded in USB Remote
	AA_WRONG_SENSOR    =  3; // Sensor does not support Auto Acquire
	AA_BAD_FIRMWARE    =  4; // Firmware is corrupt or is an old version that does not support Auto Acquire
	AA_IMAGE_AVAILABLE =  5; // Image is available in Remote
	AA_NOT_READY       =  6; // Remote Module is preparing for a trigger -- not ready to take an image
	AA_TRIGGERING      =  7; // Remote Module is waiting for a trigger
	AA_PARAMS_SET      =  8; // Returned immediately after setting parameters (not used)
	AA_READY           =  9; // Not used
	AA_PROCESSING      = 10; // Trigger occurred and Remote Module is accumulating an image
	AA_NOT_INITIALIZED = 11; //
//***** End of Schick CDR Constants

type TN_CMCDServObj4 = class (TK_CMCDServObj)
  CDSDevInd:    integer; // local Device index (synonim of CMDPProductName)
  CDSDllHandle: HMODULE; // DLL Windows Handle
  CDSErrorStr:   string; // Error message
  CDSErrorInt:  integer; // Error code

  function  CDSInitAll ( AProductName: string ): Integer;
  function  CDSFreeAll (): Integer;

  function  CDSGetGroupDevNames ( AGroupDevNames : TStrings ) : Integer; override;
  procedure CDSCaptureImages    ( APDevProfile: TK_PCMDeviceProfile;
                                  var ASlidesArray : TN_UDCMSArray ); override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCD ServObj3 = class( TK_CMCDServObj )

var
  N_CMCDServObj4: TN_CMCDServObj4;

//***** Schick CDR functions:
  N_CMECDInitXrayDevice:        TN_cdeclIntFuncInt;
  N_CMECDShowPropertiesDialog:  TN_cdeclIntFuncVoid;
  N_CMECDGetSchickImageStatus:  TN_cdeclIntFuncVoid;
  N_CMECDSetAutoAcquire:        TN_cdeclIntFuncInt;
  N_CMECDAcquireImage:          TN_cdeclIntFunc2Ptr; // AcquireImage( BITMAPINFO** ppBitmapInfo, BYTE** ppImageArray )
  N_CMECDFreeImageOutputData:   TN_cdeclProcVoid;
  N_CMECDOpenSchickLogFile:     TN_cdeclIntFuncPAChar3Int;
  N_CMECDCloseSchickLogFile:    TN_cdeclProcVoid;
  N_CMECDEnableSimaulationMode: TN_cdeclIntFunc4Int;
  N_CMECDThrowException:        TN_cdeclProc3Byte;
  N_CMECDCall_FreeImageOutputData_InDestructor: TN_cdeclProc1Byte;
  N_CMECDGetMicronsPerPixel:    TN_cdeclIntFuncPInt2;
  N_CMECDGetMicronsPerPixelCal: TN_cdeclIntFuncPInt2;
//***** End of Schick CDR functions

implementation

uses SysUtils, Dialogs,
  N_Gra2, N_Lib1, N_CM1, N_CMCaptDev4F;

//**************************************** TN_CMCDServObj4 **********

//********************************************** TN_CMCDServObj4.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AProductName - Schick CDR Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj4.CDSInitAll( AProductName: string ) : Integer;
var
  DeviceIndex: integer;
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
       if AProductName = N_CMECD_CDR_XRAYName then DeviceIndex := N_CMECD_CDR_XRAY
  else if AProductName = N_CMECD_CDR_CEPHName then DeviceIndex := N_CMECD_CDR_CEPH
  else if AProductName = N_CMECD_CDR_PANOName then DeviceIndex := N_CMECD_CDR_PANO
  else
  begin
    Result := 1; // wrong Device Name
    Exit;
  end;

  if CDSDllHandle <> 0 then // CDSDevInd already initialized
  begin
    if CDSDevInd = DeviceIndex then
    begin
      Result := 0; // All done
      Exit;
    end else // reinitialize
    begin
      CDSFreeAll();
    end; // else // reinitialize
  end; // if CDSDllHandle <> 0 then // CDSDevInd already initialized

  CDSDevInd := DeviceIndex;
  DllFName := 'SchickCDRInterface.dll';
  CDSErrorStr := '';
  Result := 0;

  N_Dump2Str( 'Loading DLL ' + DllFName );
  CDSDllHandle := Windows.LoadLibrary( @DllFName[1] );

  if CDSDllHandle = 0 then // some error
  begin
    CDSErrorStr := 'Error Loading ' + DllFName + ': ' + SysErrorMessage( GetLastError() );
    Result := 2; // Windows.LoadLibrary failed
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if CDSDllHandle = 0 then // some error

  //***** Load Schick CDR DLL functions

  FuncAnsiName := 'InitXrayDevice';
  N_CMECDInitXrayDevice := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDInitXrayDevice) then ReportError();

  FuncAnsiName := 'ShowPropertiesDialog';
  N_CMECDShowPropertiesDialog := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDShowPropertiesDialog) then ReportError();

  FuncAnsiName := 'GetImageStatus';
  N_CMECDGetSchickImageStatus := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDGetSchickImageStatus) then ReportError();

  FuncAnsiName := 'SetAutoAcquire';
  N_CMECDSetAutoAcquire := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDSetAutoAcquire) then ReportError();

  FuncAnsiName := 'AcquireImage';
  N_CMECDAcquireImage := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDAcquireImage) then ReportError();

  FuncAnsiName := 'FreeImageOutputData';
  N_CMECDFreeImageOutputData := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDFreeImageOutputData) then ReportError();

  FuncAnsiName := 'OpenLogFile';
  N_CMECDOpenSchickLogFile := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDOpenSchickLogFile) then ReportError();

  FuncAnsiName := 'CloseLogFile';
  N_CMECDCloseSchickLogFile := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDCloseSchickLogFile) then ReportError();

  FuncAnsiName := 'EnableSimaulationMode';
  N_CMECDEnableSimaulationMode := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDEnableSimaulationMode) then ReportError();

  FuncAnsiName := 'ThrowException';
  N_CMECDThrowException := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDThrowException) then ReportError();

  FuncAnsiName := 'Call_FreeImageOutputData_InDestructor';
  N_CMECDCall_FreeImageOutputData_InDestructor := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDCall_FreeImageOutputData_InDestructor) then ReportError();

  FuncAnsiName := 'GetMicronsPerPixel';
  N_CMECDGetMicronsPerPixel := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDGetMicronsPerPixel) then ReportError();

  FuncAnsiName := 'GetMicronsPerPixelCal';
  N_CMECDGetMicronsPerPixelCal := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDGetMicronsPerPixelCal) then ReportError();

  if Result <> 0 then // some error while loading DLL Entries
  begin
    K_CMShowMessageDlg( Format( 'Failed to initialise %s Errorcode=%d',
                                           [DllFName, Result] ), mtError );
    CDSFreeAll();
    N_Dump1Str( DllFName + ' Resources freed' );
  end;

end; // procedure TN_CMCDServObj4.CDSInitAll

//********************************************** TN_CMCDServObj4.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj4.CDSFreeAll(): Integer;
var
  BytePar: Byte;
begin
  if CDSDLLHandle <> 0 then
  begin
    BytePar := N_MemIniToInt( 'CMS_UserDeb', 'SchickCDRCallFreeImageOutputData', 1);
    N_CMECDCall_FreeImageOutputData_InDestructor( BytePar );
    N_Dump2Str( Format( 'SchickCDRCallFreeImageOutputData=%d', [BytePar] ) );

    N_Dump2Str( 'Before SchickCDRInterface.dll FreeLibrary' );
    FreeLibrary( CDSDLLHandle );
    N_Dump2Str( 'After SchickCDRInterface.dll FreeLibrary' );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj4.CDSFreeAll

//************************************* TN_CMCDServObj4.CDSGetGroupDevNames ***
// Get Schick CDR Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj4.CDSGetGroupDevNames( AGroupDevNames: TStrings ) : Integer;
begin
  AGroupDevNames.Add( N_CMECD_CDR_XRAYName );
//  AGroupDevNames.Add( N_CMECD_CDR_CEPHName ); // Karpenkov asked to exclude by e-mail from 24.01.2013
//  AGroupDevNames.Add( N_CMECD_CDR_PANOName );

  Result := AGroupDevNames.Count;
end; // procedure TN_CMCDServObj4.CDSGetGroupDevNames

//**************************************** TN_CMCDServObj4.CDSCaptureImages ***
// Capture Images by Schick CDR and fill ASlidesArray by them
//
//     Parameters
// APDevProfile - pointer to device profile record
// ASlidesArray - captured Slides array
//
// Is called from CMResForm.NewOtherOnExecuteHandler
//    CDServObj.CDSCaptureImages( PCMDeviceProfile, CaptSlidesArray );
//
procedure TN_CMCDServObj4.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                            var ASlidesArray : TN_UDCMSArray );
var
  ResCode: integer;
  CMCaptDev4Form: TN_CMCaptDev4Form;
begin
  SetLength( ASlidesArray, 0 );

  if APDevProfile^.CMDPGroupName <> N_CMECD_Schick_CDR_Name then // a precaution
  begin
    CDSErrorStr := 'Bad TN_CMCDServObj4 Group Name! - ' + APDevProfile^.CMDPGroupName;
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if ResCode <> 0 then // some error

  ResCode := CDSInitAll( APDevProfile^.CMDPProductName );
  CMCaptDev4Form := TN_CMCaptDev4Form.Create( Application );

  with CMCaptDev4Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    CMOFPProfile    := TK_PCMOtherProfile(APDevProfile); // set CMCaptDev4Form.CMOFPProfile field
    Caption         := CMDPCaption;
    CMOFPNewSlides  := @ASlidesArray; // for using in CMCaptDev4Form methods
    CMOFDeviceIndex := CDSDevInd;

    if ResCode <> 0 then // some Library (not Device itself) initialization error
    begin
      K_CMShowMessageDlg( 'Schick CDR device Library cannot be initialized. Please check that the correct device driver is installed and try to start the capture again. Press OK to continue.', mtError );
      CMOFFatalError := True;

      StatusLabel.Caption := 'Library initialization error';
      StatusLabel.Font.Color  := clBlack;
      StatusShape.Pen.Color   := clBlack;
      StatusShape.Brush.Color := clBlack;
    end; // if ResCode <> 0 then // some error

    ShowModal();
  end; // with CMCaptDev4Form, APDevProfile^ do

  CDSFreeAll();
end; // procedure TN_CMCDServObj4.CDSCaptureImages

//********************************* TN_CMCDServObj4.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj4.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 26;
end; // function TN_CMCDServObj4.CDSGetDefaultDevIconInd

//********************************** TN_CMCDServObj4.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj4.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
    Result := 'IO';
end; // function TN_CMCDServObj4.CDSGetDefaultDevDCMMod



Initialization

// Create and Register Schick CDR Service Object
  N_CMCDServObj4 := TN_CMCDServObj4.Create( N_CMECD_Schick_CDR_Name );
  with K_CMCDRegisterDeviceObj( N_CMCDServObj4 ) do
  begin
    CDSCaption := 'Schick';
    IsGroup := TRUE;
  end;

end.
