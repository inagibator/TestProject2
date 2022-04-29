unit N_CMCaptDev5;
// Planmeca device

// 2014.01.04 Added opportunity to capture 16 bit pictures edited in native DidapiUi Interface by Valery Ovechkin, lines 609, 642
// 2014.03.20 substituted 'K_CMShowMessageDlg' by 'ShowCriticalError' calls by Valery Ovechkin
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2014.04.28 Uncommented 'K_CMSlidesSaveScanned3' ( line 681 ) by Valery Ovechkin
// 2014.07.21 Used more detailed capture with patient details by Valery Ovechkin
// 2014.07.24 Code refactoring by Valery Ovechkin
// 2014.10.07 Commented 'K_CMSlidesSaveScanned3' and set resulting ASlidesArray for CDSCaptureImages (by Alex Kovalev)
// 2014.12.02 Crash fixed ( if Patients DOB is empty in StandAlone ), lines 630 - 640 by Valery Ovechkin
// 2014.12.19 DidapiUi error fixed, lines 560, 659 - 663 by Valery Ovechkin
// 2014.12.22 Warning AnsiToString fixed by Valery Ovechkin
// 2015.06.30 Planmeca Panoramic unreasonable failure fixed, just additional log string, line  by Valery Ovechkin
// 2018.11.07 CDSGetDefaultDevIconInd function added
// 2019.07.11 DIDAPI (async) support added
// 2020.09.01 minor fixes (open driver and statuses)
// 2020.11.18 fixed statuses, named pipes implemented
// 2020.01.10 tested final
// 2021.03.11 fixed device ind

interface
{$IFNDEF VER150} //***** not Delphi 7
uses
  Windows, Classes, Forms, Graphics,
  K_CM0, K_CMCaptDevReg,
  N_Types, N_CMCaptDev0, N_CMCaptDev5aF, N_CMCaptDev5dF;

const
  // Planmeca Devices Names
  N_CMECD_PM_INTRAName = 'Planmeca Intraoral';
  N_CMECD_PM_CEPHName  = 'Planmeca Cephalometric';
  N_CMECD_PM_PANName   = 'Planmeca Panoramic';

  // Planmeca Devices Inds
  N_CMECD_PM_INTRA    =  9; // N_CMECD_PM_INTRAName
  N_CMECD_PM_CEPH     = 10; // N_CMECD_PM_CEPHName
  N_CMECD_PM_PAN      = 11; // N_CMECD_PM_PANName

//***** Planmeca Constants
//         Result codes
  DIDAPI_OK                      = 1;
  DIDAPI_DEV_NOT_PRESENT         = 2;

//         Device codes
  DIDAPI_XRAY_PAN                = 1;
  DIDAPI_XRAY_CEPH               = 2;
  DIDAPI_XRAY_INTRA              = 3;
  DIDAPI_XRAY_NONE               = 100;

//         File types
 DIDAPI_RAW                      = 1;
 DIDAPI_RAW8B                    = 2;
 DIDAPI_TIFF                     = 3;
 DIDAPI_TIFF16B                  = 4;
 DIDAPI_JPEG_8					         = 7;
 DIDAPI_JPEG_12					         = 8;

//         Scan codes
 DIDAPI_FM_LEFT                  = 1;
 DIDAPI_FM_RIGHT                 = 2;
 DIDAPI_FM_TOP                   = 3;
 DIDAPI_FM_BOTTOM                = 4;
//***** End of Planmeca Constants

type TN_CMCDServObj5 = class( TK_CMCDServObj )
  CDSDllHandle:       HMODULE; // DLL Windows Handle
  CDSDllHandleUi:     HMODULE; // DLL Windows Handle for DIDAPIUI.dll
  CDSErrorStr:        String;  // Error message
  CDSErrorInt:        Integer; // Error code
  PSlidesArrayForDui: TN_UDCMSArray; // slides array only for DIDAPI UI

  PProfile:           TK_PCMDeviceProfile; // CMS Profile Pointer

  // Device settings
  UseDidapiUi: Boolean; // using DidapiUi
  UseDidapiPreProcessing: Boolean; // using Didapi Image PreProcessing
  DidapiUiDisablePreview: Boolean; // do not show preview for DidapiUi
  Devices:                array of TV_Dev;
  DevIndexes:             array of Integer;

  // Planmeca External Functions
  N_CMECDDIDAPI_initialize_ext:        TN_cdeclInt2FuncPInt2PInt;
  N_CMECDDIDAPI_inquire_devices_ext:   TN_cdeclInt2FuncVariant3;
  N_CMECDDIDAPI_select_device_ext:     TN_cdeclInt2FuncInt2;
  N_CMECDDIDAPI_inquire_image_ext:     TN_cdeclInt2Func3Int2_6PInt2;
  N_CMECDDIDAPI_init_grabbing_ext:     TN_cdeclInt2FuncInt2;
  N_CMECDDIDAPI_finish_grabbing_ext:   TN_cdeclInt2FuncVoid;
  N_CMECDDIDAPI_get_device_status_ext: TN_cdeclInt2FuncPInt2;
  N_CMECDDIDAPI_save_image_ext:        TN_cdeclInt2FuncVariant4;
  N_CMECDDIDAPI_get_image_ext:         TN_cdeclInt2FuncPByte6Int2;
  N_CMECDDIDAPI_patient_selected_ext:  TN_cdeclInt2FuncInt2;
  N_CMECDDIDAPI_exit_ext:              TN_cdeclProcVoid;
  N_CMECDOpenPMLogFile:                TN_cdeclIntFuncPAChar3Int;
  N_CMECDClosePMLogFile:               TN_cdeclProcVoid;
  N_CMECDDIDAPICapture_ext:            TN_stdcallInt2FuncVar1;
  // auxilliary function
  procedure FillDevIndexes      ( ADevType: Integer );
  function  GetDevTypeStr       ( ADevType: Integer ): String;
  function  CDSInitAll          (): Integer;
  function  CDSFreeAll          (): Integer;
  function  GetPixelSize        ( AFilePath: String ): Integer;
  function  GetCorrectedParam   ( AParam: String ): String;
  procedure ProfileToVars       ( APDevProfile: TK_PCMDeviceProfile );
  procedure ProfileToForm       ( AFrm: TN_CMCaptDev5aForm );
  // base fucntions
  function  CDSGetDevCaption    ( ADevName: String ): String; override;
  function  CDSGetGroupDevNames ( AGroupDevNames: TStrings ): Integer; override;
  procedure CDSCaptureImages    ( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg      ( APDevProfile: TK_PCMDeviceProfile ); override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;

  function  StartDriver( Params: string ): Boolean;
end; // end of type TN_CMCDServObj5 = class( TK_CMCDServObj )

var
  N_CMCDServObj5: TN_CMCDServObj5;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0,
  N_Gra2, N_Lib0, N_Lib1, N_CM1, N_CMCaptDev5F;

//************************************************** TN_CMCDServObj5 **********

//********************************************* TN_CMCDServObj5.StartDriver ***
// Start C++ driver
//
//    Parameters
// FormHandle - CMS Capture or Setup Form's handle
// Result     - True if driver started successfully, else False
//
function TN_CMCDServObj5.StartDriver( Params: string ): Boolean;
var
  WrkDir, LogDir, CurDir, FileName, cmd: String;
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
begin
  Result       := False;
  WrkDir       := K_ExpandFileName( '(#TmpFiles#)' );
  N_Dump1Str( 'WrkFiles are = ' + WrkDir );
  LogDir       := N_CMV_GetLogDir();
  CurDir       := ExtractFilePath( ParamStr( 0 ) );
  N_Dump1Str( 'Planmeca >> Exe directory = "' + CurDir + '"' );
  FileName  := CurDir + 'Planmeca.exe';

  // wait old driver session closing
  //N_CMV_WaitProcess( False, FileName, -1 );

  if not FileExists( FileName ) then // find driver
  begin
    Exit;
  end; // if not FileExists( FileName ) then // find driver

  cmd := '';

  ZeroMemory(@StartInfo, SizeOf(TStartupInfo));
  ZeroMemory(@ProcInfo, SizeOf(TProcessInformation));

  StartInfo.cb := SizeOf(TStartupInfo);
  StartInfo.dwFlags := STARTF_USESTDHANDLES;
  if True then
  begin
    StartInfo.dwFlags := STARTF_USESHOWWINDOW or StartInfo.dwFlags;
    StartInfo.wShowWindow := SW_SHOWMINNOACTIVE;
  end;

  Result := CreateProcess(PChar(FileName), @N_StringToWide(PProfile.CMDPStrPar2)[1],
            nil, nil, False, 0, nil, nil, StartInfo, ProcInfo); // Xe5 ok

//  Result := CreateProcess(PChar(FileName), PProfile.CMDPStrPar2[1],
//            nil, nil, False, 0, nil, nil, StartInfo, ProcInfo); // Delphi7 tmp

end; // function TN_CMCDServObj5.StartDriver

//****************************************** TN_CMCDServObj5.FillDevIndexes ***
// Fill devices list for certain device type
//
//     Parameters
// ADevType - device type - INTRA, CEPH or PAN
//
procedure TN_CMCDServObj5.FillDevIndexes( ADevType: Integer );
var
  i, DevCnt, NeedCnt: Integer;
begin
  DevCnt := Length( devices ); // count all devices
  NeedCnt := 0;
  SetLength( DevIndexes, NeedCnt ); // Initialize array

  for i := 0 to DevCnt - 1 do       // for each device
  begin
    if ( ADevType = Devices[i].DevType ) then // if needed type
    begin
      Inc( needCnt );
      SetLength( DevIndexes, NeedCnt ); // add device to array
      devIndexes[NeedCnt - 1] := i;
    end;
  end; // for i := 0 to DevCnt - 1 do       // for each device

end; // procedure TN_CMCDServObj5.fillDevIndexes

//******************************************* TN_CMCDServObj5.GetDevTypeStr ***
// Get device group name by device type
//
//     Parameters
// ADevType - device type - INTRA, CEPH or PAN
// Result - device caption
//
function TN_CMCDServObj5.GetDevTypeStr( ADevType: Integer ): String;
begin
  Result := '';

  if ( ADevType = DIDAPI_XRAY_INTRA ) then
    Result := N_CMECD_PM_INTRAName
  else if ( ADevType = DIDAPI_XRAY_CEPH ) then
    Result := N_CMECD_PM_CEPHName
  else if ( ADevType = DIDAPI_XRAY_PAN ) then
    Result := N_CMECD_PM_PANName;
end; // procedure TN_CMCDServObj5.GetDevTypeStr

//********************************************** TN_CMCDServObj5.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AProductName - Planmeca Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj5.CDSInitAll(): Integer;
var
  FuncAnsiName: AnsiString;
  DllFName:     String;  // DLL File Name
  DllFNameUi:   String;  // DLL File Name for DIDAPIUI
  DevCount, ResCode:     Integer;
  PlanmecaVerNum: TN_Int2;
  devNumber, devType, HWrevision, SWrevision, maxMode, maxProg: TN_Int2;
  TypeIDStrA: AnsiString;
  TypeIDStrS: String;

  procedure ReportError(); // local
  // Report that FuncAnsiName function was not loaded
  begin
    CDSErrorStr := N_AnsiToString( FuncAnsiName ) + ' not loaded';
    N_Dump1Str( CDSErrorStr );
    Result := 2;
  end; // procedure ReportError(); // local

begin
  Result := 0;
  if CDSDLLHandle <> 0 then
     Exit;

  DevCount := 0;

  SetLength( Devices, DevCount );

  DllFName := 'PlanmecaInterface.dll';
  DllFNameUi := 'DIDAPIUI.dll';
  CDSErrorStr := '';

  N_Dump2Str( 'Loading DLL ' + DllFName );
  CDSDllHandle := Windows.LoadLibrary( @DllFName[1] );

  CDSDllHandleUi := Windows.LoadLibrary( @DllFNameUi[1] );

  if CDSDllHandle = 0 then // some error
  begin
    CDSErrorStr := 'Error Loading ' + DllFName + ': ' + SysErrorMessage( GetLastError() );
    Result := 2; // Windows.LoadLibrary failed
    N_CMV_ShowCriticalError( 'Planmeca', CDSErrorStr );
    Exit;
  end; // if CDSDllHandle = 0 then // some error

  if CDSDllHandleUi = 0 then // some error while DIDAPIUI.dll calles
  begin
    CDSErrorStr := 'Error Loading ' + DllFNameUi + ': ' + SysErrorMessage( GetLastError() );
    Result := 2; // Windows.LoadLibrary failed
    N_CMV_ShowCriticalError( 'Planmeca', CDSErrorStr );
    Exit;
  end; // if CDSDllHandleUi = 0 then // some error

  //***** Load Planmeca DLL functions

  FuncAnsiName := 'DIDAPI_initialize_ext';
  N_CMECDDIDAPI_initialize_ext := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDDIDAPI_initialize_ext) then ReportError();

  FuncAnsiName := 'DIDAPI_inquire_devices_ext';
  N_CMECDDIDAPI_inquire_devices_ext := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDDIDAPI_inquire_devices_ext) then ReportError();

  FuncAnsiName := 'DIDAPI_select_device_ext';
  N_CMECDDIDAPI_select_device_ext := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDDIDAPI_select_device_ext) then ReportError();

  FuncAnsiName := 'DIDAPI_inquire_image_ext';
  N_CMECDDIDAPI_inquire_image_ext := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDDIDAPI_inquire_image_ext) then ReportError();

  FuncAnsiName := 'DIDAPI_init_grabbing_ext';
  N_CMECDDIDAPI_init_grabbing_ext := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDDIDAPI_init_grabbing_ext) then ReportError();

  FuncAnsiName := 'DIDAPI_finish_grabbing_ext';
  N_CMECDDIDAPI_finish_grabbing_ext := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDDIDAPI_finish_grabbing_ext) then ReportError();

  FuncAnsiName := 'DIDAPI_get_device_status_ext';
  N_CMECDDIDAPI_get_device_status_ext := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDDIDAPI_get_device_status_ext) then ReportError();

  FuncAnsiName := 'DIDAPI_save_image_ext';
  N_CMECDDIDAPI_save_image_ext := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDDIDAPI_save_image_ext) then ReportError();

  FuncAnsiName := 'DIDAPI_get_image_ext';
  N_CMECDDIDAPI_get_image_ext := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDDIDAPI_get_image_ext) then ReportError();

  FuncAnsiName := 'DIDAPI_patient_selected_ext';
  N_CMECDDIDAPI_patient_selected_ext := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDDIDAPI_patient_selected_ext) then ReportError();

  FuncAnsiName := 'DIDAPI_exit_ext';
  N_CMECDDIDAPI_exit_ext := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDDIDAPI_exit_ext) then ReportError();

  FuncAnsiName := 'OpenLogFile';
  N_CMECDOpenPMLogFile := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDOpenPMLogFile) then ReportError();

  FuncAnsiName := 'CloseLogFile';
  N_CMECDClosePMLogFile := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDClosePMLogFile) then ReportError();

  FuncAnsiName := 'DUI_capture_image_Ex2';
  N_CMECDDIDAPICapture_ext := GetProcAddress( CDSDllHandleUi, @FuncAnsiName[1] );

  if ( nil = Pointer( @N_CMECDDIDAPICapture_ext ) ) then
  begin
    N_CMV_ShowCriticalError( 'Planmeca', 'function DUI_capture_image_Ex2 not found in DLL' );
    Exit;
  end;

  if not Assigned(N_CMECDClosePMLogFile) then ReportError();

  if Result <> 0 then // some error while loading DLL Entries
  begin
    N_CMV_ShowCriticalError( 'Planmeca', Format( 'Failed to initialise %s Errorcode=%d',
                                   [DllFName, Result] ) );
    CDSFreeAll();
    N_Dump1Str( DllFName + ' Resources freed' );
  end;

  // ***** DIDAPI UI
  if UseDidapiUi then // if not intraoral and not didapi
  begin

  N_Dump1Str( 'DidapiIu code is working' );

  PlanmecaVerNum := -1;
  CDSErrorInt := 0;
  ResCode := N_CMECDDIDAPI_initialize_ext( @PlanmecaVerNum, @CDSErrorInt );

  if (ResCode <> DIDAPI_OK) or (CDSErrorInt <> 0) then // some error
  begin
    N_Dump1Str( Format( 'DIDAPI_initialize Error (%d, %d)', [ResCode, CDSErrorInt]) );
    N_CMV_ShowCriticalError( 'Planmeca', 'Device cannot be initialized!' );
    CDSFreeAll();
    Exit;
  end;

  devNumber := -1;

  // count devices
  while ( ResCode <> DIDAPI_DEV_NOT_PRESENT ) do
  begin
    SetLength( TypeIDStrA, 32 );
    Inc( devNumber ); // count of devices
    // inquire device
    ResCode := N_CMECDDIDAPI_inquire_devices_ext( devNumber, @TypeIDStrA[1],
                       @devType, @HWrevision, @SWrevision, @maxMode, @maxProg );

    // Correct device label by trimming nulls characters
    TypeIDStrS := N_CMV_TrimNullsRight( N_AnsiToString( TypeIDStrA ) );

    if ResCode = DIDAPI_OK then // success inquire
    begin
      N_Dump1Str( Format( 'DIDAPI_inquire_device OK: %s, %d, %d, %d, %d, %d, %d',
                    [TypeIDStrS, devType, devNumber, HWrevision, SWrevision, maxMode, maxProg] ) );

      Inc( DevCount );
      SetLength( Devices, DevCount );
      Devices[DevCount - 1].DevIndex := devNumber;
      Devices[DevCount - 1].DevName := TypeIDStrS;
      Devices[DevCount - 1].DevType := devType;
    end
    else // fail inquire
    begin
      if ( ResCode <> DIDAPI_DEV_NOT_PRESENT ) then
      begin
        N_CMV_ShowCriticalError( 'Planmeca', 'while device enumeration: ResCode = ' + IntToStr( ResCode ) );
        exit;
      end;
    end; // if ResCode = DIDAPI_OK then // success inquire

  end; // while ( ResCode <> DIDAPI_DEV_NOT_PRESENT ) do

  end; // if UseDidapiUi then // if not intraoral and not didapi

end; // procedure TN_CMCDServObj5.CDSInitAll

//********************************************** TN_CMCDServObj5.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj5.CDSFreeAll(): Integer;
var
  ResCode: TN_Int2;
begin
  Result := 0;
  N_Dump1Str( 'Start TN_CMCDServObj5.CDSFreeAll' );

  if UseDidapiUi then // if not intraoral and not didapi
  begin

  N_Dump1Str('DidapiIu code is working');

  if CDSDLLHandle <> 0 then
  begin
    // select patient
    ResCode := N_CMECDDIDAPI_patient_selected_ext( 0 );
    N_Dump1Str( 'N_CMECDDIDAPI_patient_selected_ext( 0 ) = ' + IntToStr( ResCode ) );

    // unselect patient
    ResCode := N_CMECDDIDAPI_select_device_ext( -1 );
    N_Dump1Str( 'select_device_ext(-1) = ' + IntToStr( ResCode ) );

    try N_CMECDDIDAPI_exit_ext();
    except on e: Exception do
    begin
      N_CMV_ShowCriticalError( 'Planmeca', 'exit_ext exception = ' + e.Message );
      exit;
    end;
    end;

    // Free 2 dll - PlanmecaInterface and didapiui
    N_Dump1Str( 'Before PlanmecaInterface.dll FreeLibrary' );
    N_b := FreeLibrary( CDSDLLHandle );

    if not N_b then
      N_Dump1Str( ' From CDSFreeAll: ' + SysErrorMessage( GetLastError() ) );

    N_b := FreeLibrary( CDSDLLHandleUi );

    if not N_b then
      N_Dump1Str( ' From CDSFreeAll: ' + SysErrorMessage( GetLastError() ) );

    N_Dump1Str( 'After PlanmecaInterface.dll FreeLibrary' );

    CDSDLLHandle   := 0;
    CDSDLLHandleUi := 0;
  end; // if CDSDLLHandle <> 0 then

  end; // if not intraoral and not didapi

  N_Dump1Str( 'Finish TN_CMCDServObj5.CDSFreeAll' );
  Result := 0; // freed OK
end; // procedure TN_CMCDServObj5.CDSFreeAll

//**************************************** TN_CMCDServObj5.CDSGetDevCaption ***
// Get device caption by type
//
//     Parameters
// ADevName - device name in system
// Result - device caption
//
function TN_CMCDServObj5.CDSGetDevCaption( ADevName: String ): String;
begin
  //Result := 'Unknown';

  //if ( ADevName = '1' ) then
  //  Result := N_CMECD_PM_PANName
  //else if ( ADevName = '2' ) then
  //  Result := N_CMECD_PM_CEPHName
  //else if ( ADevName = '3' ) then
  //  Result := N_CMECD_PM_INTRAName;

  Result := ADevName;
end; // function  TN_CMCDServObj5.CDSGetDevCaption

//******************************************** TN_CMCDServObj5.GetPixelSize ***
// Get pixel size from file
//
//     Parameters
// AFilePath - file path
// Result - pixel size in micrometers
//
function TN_CMCDServObj5.GetPixelSize( AFilePath: String ): Integer;
var
  fileStr: String;
  separatorPosition, fileStrLength: Integer;
begin
  Result := -1; // Default value
  if not FileExists( AFilePath ) then
    Exit;

  // Read file
  fileStr := N_ReadTextFile( AFilePath );
  separatorPosition := Pos( #13#10 + 'PIXELSIZE=', fileStr );
  fileStrLength := Length( fileStr );

  if ( separatorPosition <= 0 ) then
    Exit;

  // if section 'PIXELSIZE' found
  fileStr := Copy( fileStr, separatorPosition + 12, fileStrLength );
  separatorPosition := Pos( #13#10, fileStr );

  if ( separatorPosition <= 0 ) then
    Exit;

   Result := StrToIntDef( Copy( fileStr, 1, separatorPosition - 1 ), -1 );
end; // function  TN_CMCDServObj5.GetPixelSize

//*************************************** TN_CMCDServObj5.GetCorrectedParam ***
// Correct profile parameter, if it is empty - set itt o '110'
//
//     Parameters
// AParam - profile parameter string
// Result - corrected profile parameter string
//
function TN_CMCDServObj5.GetCorrectedParam ( AParam: String ): String;
var
  ParamLength: Integer;
begin
  Result := AParam;
  ParamLength := Length( AParam ); // length of parameter in characters

  // make default  parameters string if it is empty
  if ( 3 > ParamLength ) then
    Result := '110';
end; // function  TN_CMCDServObj5.GetCorrectedParam

//******************************************* TN_CMCDServObj5.ProfileToVars ***
// Set Device Settings variables from profile
//
//     Parameters
// APDevProfile- profile
//
procedure TN_CMCDServObj5.ProfileToVars( APDevProfile: TK_PCMDeviceProfile );
var
  param: String;
begin
  // profile special parameter
  if (APDevProfile.CMDPStrPar1 = '') and (APDevProfile.CMDPProductName = '3') then // intraoral first time
    APDevProfile.CMDPStrPar1 := '100';

  param := GetCorrectedParam( APDevProfile.CMDPStrPar1 ); // profile special parameter

  UseDidapiUi            := ( '1' = Copy( param, 2, 1 ) ); // using DidapiUi
  UseDidapiPreProcessing := ( '1' = Copy( param, 1, 1 ) ); // using Didapi Image PreProcessing
  DidapiUiDisablePreview := ( '1' = Copy( param, 3, 1 ) ); // do not show preview for DidapiUi
end; // procedure  TN_CMCDServObj5.ProfileToVars

//******************************************* TN_CMCDServObj5.ProfileToForm ***
// Set device settings form controls from Device Settings variables
//
//     Parameters
// AFrm - device settings form
//
procedure TN_CMCDServObj5.ProfileToForm( AFrm: TN_CMCaptDev5aForm );
var
  param: String;
begin
  // profile special parameter
  param :=  GetCorrectedParam( AFrm.CMOFPDevProfile.CMDPStrPar1 );

  // set form elements values
  AFrm.cbUseDidapiImagePreProcessing.Checked := ( '1' = Copy( param, 1, 1 ) );
  AFrm.cbUtilizeDidapiUi.Checked             := ( '1' = Copy( param, 2, 1 ) );
  AFrm.cbDisableImagePreview.Checked         := ( '1' = Copy( param, 3, 1 ) );

  //AFrm.cbUtilizeDidapiUi.Enabled := False; // temporary - disable old capture method
end; // procedure TN_CMCDServObj5.ProfileToForm

//************************************* TN_CMCDServObj5.CDSGetGroupDevNames ***
// Get Planmeca Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj5.CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer;
begin
  Result := 3;
  AGroupDevNames.Add( N_CMECD_PM_INTRAName );
  AGroupDevNames.Add( N_CMECD_PM_CEPHName );
  AGroupDevNames.Add( N_CMECD_PM_PANName );
end; // procedure TN_CMCDServObj5.CDSGetGroupDevNames

//**************************************** TN_CMCDServObj5.CDSCaptureImages ***
// Capture Images by Planmeca and fill ASlidesArray by them
//
//     Parameters
// APDevProfile - pointer to device profile record
// ASlidesArray - captured Slides array
//
// Is called from CMResForm.NewOtherOnExecuteHandler
//    CDServObj.CDSCaptureImages( PCMDeviceProfile, CaptSlidesArray );
//
procedure TN_CMCDServObj5.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                            var ASlidesArray: TN_UDCMSArray );
var
  i, NeedDevCount, devIndex, ResCode: Integer;
  devType, HWrevision, SWrevision, maxMode, maxProg, uiResCode: TN_Int2;
  LogMaxSize, LogMaxDays, LogDetails: Integer;
  LogFullNameA: AnsiString;
  TypeIDStrA: AnsiString;
  TypeIDStrS: String;
  CMCaptDev5Form: TN_CMCaptDev5Form;
  // file names
  filePrefix:  String;
  tifFile:     String;
  tifFileRaw:  String;
  PatIdA, PatDOBA: AnsiString;
  PatIdS, PatDOBS: String;
  PatName, PatSurname : WideString;
  tifFileAnsi: AnsiString;

  uiParam: Array of TN_Int2; // Exposition parameters
  DidapiUiPreviewParam: TN_Int2; // disable preview for DidapiUi

  PixelSize:  Integer;         // Pixel size
  Resolution: Integer;         // Resolution in pixel per meter
  SlideCount: Integer;         // count of slides
  dib:        TN_DIBObj;       // DIB Object
  devList:    array of TV_Dev; // devices list
  tm, tmv:    Int64;         // Timeout counter and value

  param: string;
begin
  PProfile := APDevProfile;

  // ***** DIDAPI UI
  param := GetCorrectedParam( APDevProfile.CMDPStrPar1 ); // profile special parameter
  UseDidapiUi := ( '1' = Copy( param, 2, 1 ) ); // using Didapi Image PreProcessing
  if UseDidapiUi then // if not intraoral and not didapi
  begin

  N_Dump1Str('DidapiIu code is working');


  ResCode := CDSInitAll(); // Initialize Didapi
  ProfileToVars( APDevProfile ); // Read Didapi and DidapiUi parameters from profile

  devType := -1;

  if APDevProfile^.CMDPProductName = N_CMECD_PM_INTRAName then
    devType := 3;
  if APDevProfile^.CMDPProductName = N_CMECD_PM_CEPHName then
    devType := 2;
  if APDevProfile^.CMDPProductName = N_CMECD_PM_PANName then
    devType := 1;

  // define device type
  //devType := StrToIntDef( APDevProfile^.CMDPProductName, -1 );

  // if device not found
  if ( ( devType < 0 ) or ( devType > 3 ) ) then
  begin
    N_CMV_ShowCriticalError( 'Planmeca', 'Device not found ' );
    CDSFreeAll();
    exit;
  end;

  fillDevIndexes( devType ); // fill device indexes list for needed type
  NeedDevCount := Length( devIndexes ); // count above devices

  // if devices of this type not found
  if ( NeedDevCount <= 0 ) then
  begin
    N_CMV_ShowCriticalError( 'Planmeca', 'Device of this type not found ' );
    CDSFreeAll();
    Exit;
  end; // if ( NeedDevCount <= 0 ) then

  devIndex := 0;

  // if there > 1 devices of this type
  if ( NeedDevCount > 1 ) then
  begin

    SetLength( devList, NeedDevCount );

    for i := 0 to NeedDevCount - 1 do
    begin
      devList[i].DevIndex := devices[devIndexes[i]].DevIndex;
      devList[i].DevType := devices[devIndexes[i]].DevType;
      devList[i].DevName := devices[devIndexes[i]].DevName;
    end; // for i := 0 to NeedDevCount - 1 do

  end; // if ( NeedDevCount > 1 ) then

  // If ising DidapiUi - now only this method works good
  if UseDidapiUi then
  begin
    // set file pathes
    filePrefix  := N_CMV_GetWrkDir();
    filePrefix  := filePrefix + 'Dev_didapiui';
    tifFile     := filePrefix + '.tif';
    tifFileRaw  := filePrefix + '_raw.tif';
    tifFileAnsi := N_StringToAnsi( tifFile );

    SetLength( uiParam, 30 );
    // disable preview parameter
    DidapiUiPreviewParam := 1;

    if DidapiUiDisablePreview then
      DidapiUiPreviewParam := 0;

    // Patient data
    PatIdS     := K_CMGetPatientDetails( -1, '(#PatientCardNumber#)' );
    PatName    := N_StringToWide( K_CMGetPatientDetails( -1, '(#PatientFirstName#)' ) );
    PatSurname := N_StringToWide( K_CMGetPatientDetails( -1, '(#PatientSurname#)' ) );
    PatDOBS    := K_CMGetPatientDetails( -1, '(#PatientDOB#)' );

    // Correct empty Patients data - substitute by ' '

    if ( PatIdS = '' ) then
      PatIdS := ' ';

    if ( PatName = '' ) then
      PatName := ' ';

    if ( PatSurname = '' ) then
      PatSurname := ' ';

    if ( PatDOBS = '' ) then
      PatDOBS := ' ';

    // Convert String parameters to Ansi
    PatIdA  := N_StringToAnsi( PatIdS );
    PatDOBA := N_StringToAnsi( PatDOBS );

    // Dump Patients Data
    N_Dump1Str( 'Planmeca: PatId = "' + PatIdS );
    N_Dump1Str( 'Planmeca: PatName = "' + PatName );
    N_Dump1Str( 'Planmeca: PatSurname = "' + PatSurname );
    N_Dump1Str( 'Planmeca: PatDOB = "' + PatDOBS );

    // call DidapiUi DLL function
    uiResCode :=
    N_CMECDDIDAPICapture_ext(
      DidapiUiPreviewParam, devType, 16, 4, 0, @tifFileAnsi[1], 0,
      @PatIdA[1], @PatName[1], @PatSurname[1], @PatDOBA[1],
      @uiParam[1] );
    // Additional log call to prevent Planmeca Panoramic unreasonable failure
    N_Dump1Str( 'Planmeca: N_CMECDDIDAPICapture_ext = ' + IntToStr( uiResCode ) );
    tmv := N_MemIniToInt( 'CMS_UserMain', 'PlanmecaTimeout', 0 ); // timeout, ms
    tm := GetTickCount(); // initialize timer for timeout checking

    while ( tmv >= ( GetTickCount() - tm ) ) do // wait timeout
      Application.ProcessMessages;

    // if error while DidapiUi call
    if ( uiResCode <> DIDAPI_OK ) then
    begin
      if ( uiResCode <> -1 ) then
        N_CMV_ShowCriticalError( 'Planmeca', 'DIDAPIUI code = ' + IntToStr( uiResCode ) );
      CDSFreeAll();
      Exit;
    end;

    // if TIF file do not appeare after return from DidapiUi call
    if not FileExists( tifFile ) then
    begin
      N_CMV_ShowCriticalError( 'Planmeca', 'DIDAPIUI file not exists: ' + tifFile );
      CDSFreeAll();
      exit;
    end;

    SetLength( PSlidesArrayForDui, 0 ); // Initialize ASlidesArray
    // convert BMP to slide
    SlideCount := Length( PSlidesArrayForDui ); // count of slides
    dib := nil;
    N_LoadDIBFromFileByImLib( dib, tifFile ); // new 8 or 16 bit variant

    if ( dib = nil ) then // dib not loaded from tif file
    begin
      N_CMV_ShowCriticalError( 'Planmeca', 'File "' + tifFileRaw + '" has wrong tif format' );
      Exit;
    end; //if ( dib = nil ) then // dib not loaded from tif file

    if dib.DIBExPixFmt = epfGray16 then
      dib.SetDIBNumBits( 12 );

    // define image resolution
    PixelSize := GetPixelSize( filePrefix + '_raw_tif.txt' );
    Resolution := -1;
    if ( PixelSize > 0 )then
      Resolution := Round( 1000000 / PixelSize );

    // if resolution not defined
    if ( Resolution <= 0 ) then
    begin
      N_CMV_ShowCriticalError( 'Planmeca', 'image resolution not defined' );
      CDSFreeAll();
      Exit;
    end; // if ( Resolution <= 0 ) then

    // set DIBObj resolution
    dib.DIBInfo.bmi.biXPelsPerMeter := Resolution;
    dib.DIBInfo.bmi.biYPelsPerMeter := Resolution;
    SetLength( PSlidesArrayForDui, SlideCount + 1 );   // add slide
    // add image to appropriate slide
    PSlidesArrayForDui[SlideCount] :=
    K_CMSlideCreateFromDeviceDIBObj( dib, APDevProfile, SlideCount + 1, 0 );
    PSlidesArrayForDui[SlideCount].SetAutoCalibrated();

    // save slide
/////////////////////////////////////////////
// 2014-10-07 !!! this code shouldn't be changed
//    K_CMSlidesSaveScanned3( APDevProfile, PSlidesArrayForDui ); // !!! K_CMSlidesSaveScanned3 shouldn't be used here
    ASlidesArray := copy( PSlidesArrayForDui );                   // !!! ASlidesArray is resulting slides array for CDSCaptureImages
// 2014-10-07 !!!
/////////////////////////////////////////////
    // UnInitialize Didapi
    CDSFreeAll();
    // Delete images files
    K_DeleteFile( tifFile );
    K_DeleteFile( tifFileRaw );
    K_DeleteFile( filePrefix + '_tif.txt' );
    K_DeleteFile( filePrefix + '_raw_tif.txt' );
    exit; // finish didapiui capture
  end;

  // Usual Capturing by Didapi ( without Didapi Ui ) - now it does not work on real devices
  SetLength( ASlidesArray, 0 );

  if APDevProfile^.CMDPGroupName <> N_CMECD_Planmeca_Name then // a precaution
  begin
    CDSErrorStr := 'Bad TN_CMCDServObj5 Group Name! - ' + APDevProfile^.CMDPGroupName;
    N_CMV_ShowCriticalError( 'Planmeca', CDSErrorStr );
    Exit;
  end; // if ResCode <> 0 then // some error

  //ResCode := CDSInitAll();

  if ResCode <> 0 then // some error
  begin
    N_CMV_ShowCriticalError( 'Planmeca', 'Device library cannot be initialized' );
    Exit;
  end; // if ResCode <> 0 then // some error

//  LogDirS := K_GetDirPath( 'CMSLogFiles' );
//  LogNameS := 'Planmeca.txt';
//  LogDirA := N_StringToAnsi( LogDirS );
//  LogNameA := N_StringToAnsi( LogNameS );
//  ResCode := N_CMECDOpenPMLogFile( @LogDirA[1], @LogNameA[1], 1 );
//  if ResCode = 0 then
//    N_Dump1Str( 'Planmeca OpenLogFile Error - ' + LogDirS + LogNameS );

  LogFullNameA := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) + 'Dev_Planmeca.txt' );
  LogMaxSize := N_MemIniToInt( 'CMS_UserMain', 'LogMaxSize', 1024 );
  LogMaxDays := N_MemIniToInt( 'CMS_UserMain', 'LogMaxDays', 200 );
  LogDetails := N_MemIniToInt( 'CMS_UserMain', 'LogDetails', 2 );

  N_CMECDOpenPMLogFile( @LogFullNameA[1], LogMaxSize, LogMaxDays, LogDetails );

  CDSErrorInt := 0;

  SetLength( TypeIDStrA, 32 );

  i := devList[devIndex].DevIndex;
  N_Dump1Str( 'Planmeca >> number = ' + inttostr(i));
  ResCode := N_CMECDDIDAPI_inquire_devices_ext( i, @TypeIDStrA[1],
                       @devType, @HWrevision, @SWrevision, @maxMode, @maxProg );

  TypeIDStrS := N_AnsiToString( TypeIDStrA );
  N_Dump1Str( 'Planmeca >>dev type = ' + IntToStr( devType ) );
  N_Dump1Str( 'Planmeca >>dev name = ' + TypeIDStrS );
  N_Dump1Str( 'Planmeca >>inquire = ' + IntToStr( ResCode ) );

  if ResCode = DIDAPI_OK then
  begin
    ResCode := N_CMECDDIDAPI_select_device_ext( i );
    N_Dump1Str( 'Planmeca >>select = ' + IntToStr(rescode));

    if ResCode = DIDAPI_OK then
    begin
      N_Dump1Str( Format( 'DIDAPI_select_device OK: %s, %d, %d, %d, %d, %d',
                          [TypeIDStrS, devType, HWrevision, SWrevision, maxMode, maxProg]  ) );

    end
    else // N_CMECDDIDAPI_select_device_ext failed
    begin
      N_CMV_ShowCriticalError( 'Planmeca', 'select_device = ' + IntToStr( ResCode ) );
      N_Dump1Str( Format( 'N_CMECDDIDAPI_select_device_ext failed (%d, %d)', [i,devType]) );
      CDSFreeAll();
      Exit;
    end; // else // N_CMECDDIDAPI_select_device_ext failed

  end
  else // ResCode <> DIDAPI_OK - no more devices
  begin
    N_CMV_ShowCriticalError( 'Planmeca', 'Device is not available: ' + APDevProfile^.CMDPProductName );
    CDSFreeAll();
    Exit;
  end; // if ResCode = DIDAPI_OK then

  // Here: needed device selected OK

  N_CMECDDIDAPI_patient_selected_ext( 1 );

  end // if not intraoral
  else
  begin
    SetLength(ASlidesArray, 0);
  end;

  CMCaptDev5Form := TN_CMCaptDev5Form.Create( Application );

  with CMCaptDev5Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    CMOFPProfile    := TK_PCMOtherProfile(APDevProfile); // set CMCaptDev5Form.CMOFPProfile field
    Caption         := CMDPCaption;
    CMOFPNewSlides  := @ASlidesArray; // for using in CMCaptDev5Form methods

    ShowModal();
  end; // with CMCaptDev5Form, APDevProfile^ do

  CDSFreeAll();

end; // procedure TN_CMCDServObj5.CDSCaptureImages

//****************************************** TN_CMCDServObj5.CDSSettingsDlg ***
// Show Special Seting Dialog
//
//     Parameters
// APDevProfile - Pointer to Device Profile record
//
procedure TN_CMCDServObj5.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  frm: TN_CMCaptDev5aForm;
begin
  frm := TN_CMCaptDev5aForm.Create( Application );
  frm.BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
  frm.CMOFPDevProfile := APDevProfile;
  ProfileToForm( frm );
  frm.Caption := APDevProfile.CMDPCaption;
  frm.ShowModal();
end; // procedure TN_CMCDServObj5.CDSSettingsDlg

//********************************* TN_CMCDServObj5.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj5.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin

  if AProductName = N_CMECD_PM_INTRAName then
    Result := 18
  else if AProductName = N_CMECD_PM_CEPHName then
    Result := 27
  else if AProductName = N_CMECD_PM_PANName then
    Result := 24;
end; // function TN_CMCDServObj5.CDSGetDefaultDevIconInd

//********************************** TN_CMCDServObj5.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj5.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin

  if AProductName = N_CMECD_PM_INTRAName then
    Result := 'PX'
  else if AProductName = N_CMECD_PM_CEPHName then
    Result := 'DX'
  else if AProductName = N_CMECD_PM_PANName then
    Result := 'IO';
end; // function TN_CMCDServObj5.CDSGetDefaultDevDCMMod


Initialization

  // Create and Register Planmeca Service Object
  N_CMCDServObj5 := TN_CMCDServObj5.Create( N_CMECD_Planmeca_Name );

  with K_CMCDRegisterDeviceObj( N_CMCDServObj5 ) do
  begin
    CDSCaption      := 'Planmeca';
    ShowSettingsDlg := True;
    IsGroup         := True;
  end;

  N_CMCDServObj5.CDSDLLHandle   := 0;
  N_CMCDServObj5.CDSDLLHandleUi := 0;
  N_CMCDServObj5.UseDidapiUi            := True;
  N_CMCDServObj5.UseDidapiPreProcessing := True;
  N_CMCDServObj5.DidapiUiDisablePreview := False;
  
{$ELSE} //************** no code in Delphi 7
implementation
{$ENDIF VER150} //****** no code in Delphi 7

end.
