unit N_CMCaptDev21S;
// Schick2 device (changed from Schick CDR)

// 30.08.16 - finished
// 17.06.16 - functionality added and formatted
// 17.03.17 - error with schick elite fixed (doesn't support filters, crash while trying)
// 15.07.17 - crashed at database version, fixed creating a dibobj
// 16.10.17 - fixed crashing after process, wrong slide adding
// 2018.11.07 CDSGetDefaultDevIconInd function added

interface
uses Windows, Classes, Graphics, Forms,
  K_CM0, K_CMCaptDevReg,
  N_Types, ActiveX;

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

type TN_CMCDServObj21 = class (TK_CMCDServObj)
  CDSDevInd:    integer; // local Device index (synonim of CMDPProductName)
  CDSDllHandle: HMODULE; // DLL Windows Handle
  CDSErrorStr:   string; // Error message
  CDSErrorInt:  integer; // Error code

  CDSDeviceProfile: TK_PCMDeviceProfile;

  function  CDSInitAll ( AProductName: string ): Integer;
  function  CDSFreeAll (): Integer;

  function  CDSGetGroupDevNames ( AGroupDevNames : TStrings ) : Integer; override;
  procedure CDSCaptureImages    ( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ); override;
  function  CDSStartCaptureToStudy  ( APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState; override;
  function  CDSGetDefaultDevIconInd( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
private

  BufSlidesArray: TN_UDCMSArray;
  function  FCapturePrepare( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ) : Integer;
{!!!
  procedure FCaptureDisable();
  procedure FCaptureEnable();
  function  FAutoTakeStateGet() : Boolean; // Device CMS Capture Dlg AutoTake get state (should be set to nil if AutoTake is device built-in or is absent)
  procedure FAutoTakeStateSet( AState : Integer ); // Device CMS Capture Dlg AutoTake set state (should be set to nil if AutoTake is device built-in or is absent)
!!!}
end;

type N_ImageParams = record // info about an image
  IPWidth:    Integer;
  IPHeigth:   Integer;
  IPIHBitmap: Integer; // bitmap handle
end;

var
  N_CMCDServObj21: TN_CMCDServObj21;

//***** Schick CDR functions:
  N_CMECDInitXrayDevice:        TN_cdeclIntFuncInt;
  N_CMECDShowPropertiesDialog:  TN_cdeclIntFuncVoid;
  N_CMECDGetSchickImageStatus:  TN_cdeclIntFuncVoid;
  N_CMECDSetAutoAcquire:        TN_cdeclIntFuncInt;
  N_CMECDAcquireImage:          TN_cdeclIntFuncPtr;
  N_CMECDImportImage:           TN_cdeclIntFuncPtr;
  N_CMECDProcessImage:          TN_cdeclIntFunc2IntPtr;
  N_CMECDMix:                   TN_cdeclIntFuncPtr;
  N_CMECDSetSharp:              TN_cdeclProcFloat;
  N_CMECDOnMaximusMapping:      TN_cdeclIntFuncIntPtr;
  N_CMECDFreeImageOutputData:   TN_cdeclProcVoid;
  N_CMECDEnableSimaulationMode: TN_cdeclIntFunc4Int;
  N_CMECDGetMicronsPerPixel:    TN_cdeclIntFuncVoid;
  N_CMECDClean:    TN_cdeclIntFuncInt;
  N_CMECDClose:    TN_cdeclIntFuncVoid;
//***** End of Schick CDR functions

  N_ImageStruct: N_ImageParams;

implementation

uses SysUtils, Dialogs,
  N_Gra2, N_Lib1, N_CM1, N_CMCaptDev21SF;

var
  CaptForm: TN_CMCaptDev21Form;

//**************************************** TN_CMCDServObj21 **********

//********************************************** TN_CMCDServObj21.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AProductName - Schick CDR Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj21.CDSInitAll( AProductName: string ) : Integer;
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
       if AProductName = N_CMECD_CDR_XRAYName then DeviceIndex :=
                                                                N_CMECD_CDR_XRAY
  else if AProductName = N_CMECD_CDR_CEPHName then DeviceIndex :=
                                                                N_CMECD_CDR_CEPH
  else if AProductName = N_CMECD_CDR_PANOName then DeviceIndex :=
                                                                N_CMECD_CDR_PANO
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
  DllFName := 'SchickCDR2Interface.dll';
  CDSErrorStr := '';
  Result := 0;

  N_Dump2Str( 'Loading DLL ' + DllFName );
  CDSDllHandle := Windows.LoadLibrary( @DllFName[1] );

  if CDSDllHandle = 0 then // some error
  begin
    CDSErrorStr := 'Error Loading ' + DllFName + ': ' + SysErrorMessage(
                                                               GetLastError() );
    Result := 2; // Windows.LoadLibrary failed
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if CDSDllHandle = 0 then // some error

  //***** Load Schick CDR DLL functions

  FuncAnsiName := 'InitXrayDevice';
  N_CMECDInitXrayDevice := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDInitXrayDevice) then ReportError();

  FuncAnsiName := 'ShowPropertiesDialog';
  N_CMECDShowPropertiesDialog := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDShowPropertiesDialog) then ReportError();

  FuncAnsiName := 'GetImageStatus';
  N_CMECDGetSchickImageStatus := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDGetSchickImageStatus) then ReportError();

  FuncAnsiName := 'SetAutoAcquire';
  N_CMECDSetAutoAcquire := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDSetAutoAcquire) then ReportError();

  FuncAnsiName := 'AcquireImage';
  N_CMECDAcquireImage := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDAcquireImage) then ReportError();

  FuncAnsiName := 'ImportImage';
  N_CMECDImportImage := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDImportImage) then ReportError();

  FuncAnsiName := 'ProcessImage';
  N_CMECDProcessImage := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDProcessImage) then ReportError();

  FuncAnsiName := 'SetSharp';
  N_CMECDSetSharp := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDSetSharp) then ReportError();

  FuncAnsiName := 'OnMaximusMapping';
  N_CMECDOnMaximusMapping := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDOnMaximusMapping) then ReportError();

  FuncAnsiName := 'Mix';
  N_CMECDMix := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDMix) then ReportError();

  FuncAnsiName := 'Clean';
  N_CMECDClean := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDClean) then ReportError();

  FuncAnsiName := 'Close';
  N_CMECDClose := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDClose) then ReportError();

  FuncAnsiName := 'GetMicronsPerPixel';
  N_CMECDGetMicronsPerPixel := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDGetMicronsPerPixel) then ReportError();

  if Result <> 0 then // some error while loading DLL Entries
  begin
    K_CMShowMessageDlg( Format( 'Failed to initialise %s Errorcode=%d',
                                           [DllFName, Result] ), mtError );
    CDSFreeAll();
    N_Dump1Str( DllFName + ' Resources freed' );
  end;

end; // procedure TN_CMCDServObj21.CDSInitAll

//********************************************** TN_CMCDServObj21.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj21.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    N_Dump2Str( 'Before SchickCDRInterface.dll FreeLibrary' );
    FreeLibrary( CDSDLLHandle );
    N_Dump2Str( 'After SchickCDRInterface.dll FreeLibrary' );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj21.CDSFreeAll

//************************************* TN_CMCDServObj21.CDSGetGroupDevNames ***
// Get Schick CDR Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj21.CDSGetGroupDevNames( AGroupDevNames: TStrings ) : Integer;
begin
  AGroupDevNames.Add( N_CMECD_CDR_XRAYName );
//  AGroupDevNames.Add( N_CMECD_CDR_CEPHName ); // Karpenkov asked to exclude by e-mail from 24.01.2013
//  AGroupDevNames.Add( N_CMECD_CDR_PANOName );

  Result := AGroupDevNames.Count;
end; // procedure TN_CMCDServObj21.CDSGetGroupDevNames

//**************************************** TN_CMCDServObj21.CDSCaptureImages ***
// Capture Images by Schick CDR and fill ASlidesArray by them
//
//     Parameters
// APDevProfile - pointer to device profile record
// ASlidesArray - captured Slides array
//
// Is called from CMResForm.NewOtherOnExecuteHandler
//    CDServObj.CDSCaptureImages( PCMDeviceProfile, CaptSlidesArray );
//
procedure TN_CMCDServObj21.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                            var ASlidesArray : TN_UDCMSArray );
var
  ResCode: integer;
//  CMCaptDev21Form: TN_CMCaptDev21Form;
begin
  N_Dump1Str( 'Shick 2 >> CDSCaptureImages begin' );
  ResCode := FCapturePrepare( APDevProfile, ASlidesArray );
  if ResCode < 0 then Exit;
  N_Dump1Str( 'Shick 2 >> CDSCaptureImages before ShowModal' );
  CaptForm.ShowModal();
  N_Dump1Str( 'Shick 2 >> CDSCaptureImages end' );
{
  CDSDeviceProfile := APDevProfile;

  SetLength( ASlidesArray, 0 );

  if APDevProfile^.CMDPGroupName <> N_CMECD_Schick33_Name then // a precaution
  begin
    CDSErrorStr := 'Bad TN_CMCDServObj21 Group Name! - ' + APDevProfile^.CMDPGroupName;
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if ResCode <> 0 then // some error

  ResCode := CDSInitAll( APDevProfile^.CMDPProductName );
  CMCaptDev21Form := TN_CMCaptDev21Form.Create( Application );

  with CMCaptDev21Form, APDevProfile^ do
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
}
end; // procedure TN_CMCDServObj21.CDSCaptureImages

//********************************* TN_CMCDServObj21.CDSStartCaptureToStudy ***
// Start Capture to study
//
//     Parameters
// APDevProfile - pointer to device profile record
// AStudyDevCaptAttrs - resulting Device Capture Interface
// Result - Returns Study Capture State code (TK_CMStudyCaptState)
//
function TN_CMCDServObj21.CDSStartCaptureToStudy(  APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState;
begin

  Result := inherited CDSStartCaptureToStudy( APDevProfile, AStudyDevCaptAttrs );

  with AStudyDevCaptAttrs do
  begin
    if FCapturePrepare( APDevProfile, BufSlidesArray ) = 0 then
    begin
      CaptForm.tbRotateImage.Visible := FALSE;
      CMSDCDDlg := CaptForm;
      CMSDCDDlgCPanel := CaptForm.CtrlsPanel;
{!!!
      CMSDCDCaptureDisableProc := FCaptureDisable; // Device CMS Capture Dlg disable procedure of object
      CMSDCDCaptureEnableProc  := FCaptureEnable; // Device CMS Capture Dlg enable  procedure of object
      CMSDCDAutoTakeStateGetFunc := FAutoTakeStateGet; // Device CMS Capture Dlg AutoTake get state (should be set to nil if AutoTake is device built-in)
      CMSDCDAutoTakeStateSetProc := FAutoTakeStateSet; // Device CMS Capture Dlg AutoTake set state (should be set to nil if AutoTake is device built-in)
!!!}
      Result := K_cmscOK;
    end;
  end;
  N_Dump1Str( 'Shick 2 >> CDSStartCaptureToStudy Res=' + IntToStr(Ord(Result)) );


end; // function TN_CMCDServObj21.CDSStartCaptureToStudy

//******************************** TN_CMCDServObj21.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj21.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 39;
end; // function TN_CMCDServObj21.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj21.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj21.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
  Result := 'IO';
end; // function TN_CMCDServObj21.CDSGetDefaultDevDCMMod


//**************************************** TN_CMCDServObj21.FCapturePrepare ***
// Capture Prepare
//
//     Parameters
// APDevProfile - pointer to profile
// ASlidesArray - resulting Slides Array
//
function TN_CMCDServObj21.FCapturePrepare( APDevProfile: TK_PCMDeviceProfile;
                                           var ASlidesArray: TN_UDCMSArray ) : Integer;
begin
  CaptForm := nil;
  CDSDeviceProfile := APDevProfile;

  SetLength( ASlidesArray, 0 );

  Result := -1;
  if APDevProfile^.CMDPGroupName <> N_CMECD_Schick33_Name then // a precaution
  begin
    CDSErrorStr := 'Bad TN_CMCDServObj21 Group Name! - ' + APDevProfile^.CMDPGroupName;
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if ResCode <> 0 then // some error

  Result := CDSInitAll( APDevProfile^.CMDPProductName );
  CaptForm := TN_CMCaptDev21Form.Create( Application );

  with CaptForm, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    CMOFPProfile    := TK_PCMOtherProfile(APDevProfile); // set CMCaptDev4Form.CMOFPProfile field
    Caption         := CMDPCaption;
    CMOFPNewSlides  := @ASlidesArray; // for using in CMCaptDev4Form methods
    CMOFDeviceIndex := CDSDevInd;

    if Result <> 0 then // some Library (not Device itself) initialization error
    begin
      K_CMShowMessageDlg( 'Schick CDR device Library cannot be initialized. Please check that the correct device driver is installed and try to start the capture again. Press OK to continue.', mtError );
      CMOFFatalError := True;

      StatusLabel.Caption := 'Library initialization error';
      StatusLabel.Font.Color  := clBlack;
      StatusShape.Pen.Color   := clBlack;
      StatusShape.Brush.Color := clBlack;
    end; // if Result <> 0 then // some error
  end; // with CaptForm, APDevProfile^ do

end; // procedure TN_CMCDServObj21.FCapturePrepare

{!!!
//**************************************** TN_CMCDServObj21.FCaptureDisable ***
// Capture disable
//
procedure TN_CMCDServObj21.FCaptureDisable;
begin

  if CaptForm.bnCapture.Enabled then
    N_Dump1Str( 'Shick 2 >> UI is disabled' );
  CaptForm.cbAutoTake.Checked := FALSE;
  CaptForm.cbAutoTake.Enabled := FALSE;
  CaptForm.bnCapture.Enabled  := FALSE;
  CaptForm.StatusLabel.Visible := FALSE;

end; // procedure TN_CMCDServObj21.FCaptureDisable

//***************************************** TN_CMCDServObj21.FCaptureEnable ***
// Capture enable
//
procedure TN_CMCDServObj21.FCaptureEnable;
begin

  CaptForm.bnCapture.Enabled  := TRUE;
  CaptForm.cbAutoTake.Enabled := TRUE;
  CaptForm.StatusLabel.Visible := TRUE;
  N_Dump1Str( 'Shick 2 >> UI is enabled' );

end; // procedure TN_CMCDServObj21.FCaptureEnable

//************************************** TN_CMCDServObj21.FAutoTakeStateGet ***
// Capture enable
//
function TN_CMCDServObj21.FAutoTakeStateGet: Boolean;
begin

  Result := CaptForm.cbAutoTake.Checked;

end; // function TN_CMCDServObj21.FAutoTakeStateGet

//************************************** TN_CMCDServObj21.FAutoTakeStateSet ***
// Capture enable
//
procedure TN_CMCDServObj21.FAutoTakeStateSet( AState: Integer );
begin

  CaptForm.cbAutoTake.Checked := AState <> 0;
  N_Dump1Str( 'Shick 2 >> UI AutoTake is restored' );

end; // procedure TN_CMCDServObj21.FAutoTakeStateSet
!!!}

Initialization

// Create and Register Schick CDR Service Object
  N_CMCDServObj21 := TN_CMCDServObj21.Create( N_CMECD_Schick33_Name );
  with K_CMCDRegisterDeviceObj( N_CMCDServObj21 ) do
  begin
    CDSCaption := 'Schick 2';
    IsGroup := TRUE;
  end;

end.
