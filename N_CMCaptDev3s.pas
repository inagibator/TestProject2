unit N_CMCaptDev3s;

//    Implements three Device Groups:
// Soredex         device
// Kavo            device
// Instrumentarium device

// 2018.11.07 CDSGetDefaultDevIconInd function added

interface
uses Windows, Classes, Forms, Controls,
  K_CM0, K_CMCaptDevReg,
  N_Types;

// Captering process for all devices uses only N_CMCDServObj3A object,
// N_CMCDServObj3B and N_CMCDServObj3C objects are needed only for Capture Setup Interface
//   (for Kavo and Instrumentarium groups to be listed in menu among all groups)

const
  // DSD Devices Groups Inds
  N_CMECD_SORE = 0; // N_CMCDServObj3A SOREDEX         'Digora Optime', 'Cranex D', 'Cranex Novus', 'Cranex Novus E', 'PSPIX Scanner' devices
  N_CMECD_Kavo = 1; // N_CMCDServObj3B Kavo            'Scan eXam', 'Pan eXam' devices
  N_CMECD_Inst = 2; // N_CMCDServObj3C Instrumentarium 'Express (TM)', 'Orthopantomograph (R) OP30' devices

  // DSD Devices Names
  N_CMECD_DigoraOptName    = 'Digora Optime';  // (N_CMCDServObj3A SOREDEX)
  N_CMECD_CranexDName      = 'Cranex D';       // (N_CMCDServObj3A SOREDEX)
  N_CMECD_CranexNovName    = 'Cranex Novus';   // (N_CMCDServObj3A SOREDEX)
  N_CMECD_CranexNovEName   = 'Cranex Novus E'; // (N_CMCDServObj3A SOREDEX)
  N_CMECD_ScaneXamName     = 'Scan eXam';      // (N_CMCDServObj3B Kavo)
  N_CMECD_ScaneXamOneName  = 'Scan eXam One';  // (N_CMCDServObj3B Kavo)
  N_CMECD_PaneXamName      = 'Pan eXam';       // (N_CMCDServObj3B Kavo)
  N_CMECD_ExpressName      = 'Express (TM)';   // (N_CMCDServObj3C Instrumentarium)
  N_CMECD_ExpressOrigoName = 'Express (TM) Origo';   // (N_CMCDServObj3C Instrumentarium)
  N_CMECD_OrthopanName     = 'Orthopantomograph (R) OP30'; // (N_CMCDServObj3C Instrumentarium)
  N_CMECD_PSPIXName        = 'PSPIX Scanner';  // (N_CMCDServObj3A SOREDEX)

  // DSD Devices Inds
  N_CMECD_DigoraOpt    = 3;  // N_CMECD_DigoraOptName  (is DigoraOpt)
  N_CMECD_CranexD      = 4;  // N_CMECD_CranexDName    (like CranexNov)
  N_CMECD_CranexNov    = 5;  // N_CMECD_CranexNovName  (is CranexNov)
  N_CMECD_CranexNovE   = 6;  // N_CMECD_CranexNovEName (like CranexNov)
  N_CMECD_ScaneXam     = 7;  // N_CMECD_ScaneXamName   (like DigoraOpt)
  N_CMECD_PaneXam      = 8;  // N_CMECD_PaneXamName    (like CranexNov)
  N_CMECD_Express      = 9;  // N_CMECD_ExpressName    (like DigoraOpt)
  N_CMECD_Orthopan     = 10; // N_CMECD_OrthopanName   (like CranexNov)
  N_CMECD_PSPIX        = 11; // N_CMECD_PSPIXName      (like CranexNov)
  N_CMECD_ExpressOrigo = 12; // N_CMECD_ExpressOrigoName (like DigoraOpt)
  N_CMECD_ScaneXamOne  = 13; // N_CMECD_ScaneXamOneName  (like DigoraOpt)

  //***** DSD Constants
  SoS_OK              = 1;

  SoS_BADPARM         = 2;
  SoS_SYSTEMERROR     = 3;
  SoS_ALREADYOPENED   = 4;
  SoS_INVALIDPATH     = 5;

  SoS_NOTOPEN         = 6;
  SoS_INIT            = 7;
  SoS_DISCONNECTED    = 8;
  SoS_CONNECTED       = 9;
  SoS_SETUP          = 10;
  SoS_IMAGEREADOUT   = 11;
  SoS_PLATEINSERTED  = 12;

  SoS_SCANNERERROR   = 13;
  SoS_CANCELLED      = 14;
  SoS_NOTSUPPORTED   = 15;
  SoS_IODRIVERERROR  = 16;
  SoS_17             = 17;

  SoS_IMAGEPENDING   = 18;
  SoS_PLATEEJECT     = 19;
  SoS_NOIPADDRESS	   = 20;
  SoS_SCAN_STARTED	 = 30;

  SO_DIGORAPCT        = 2;
  SO_CRANEXPDC        = 3;
  SO_DIGORAOPTIME     = 4;
  SO_EXPRESS          = 4;
  SO_SCANEXAM         = 4;
  SO_PSPIX            = 4;
  SO_CRANEXD          = 5;
  SO_SOPIX            = 6;
  SO_CRANEXTT			    = 7;
  SO_DIGORATOTO		    = 8;
  SO_OP30				      = 9;
  SO_PANEXAM		      = 9;
  SO_NOVUSE           = 11;
  SO_DIGORAPT         = 34;

  SO_ORIG_COPY        = $00000001;

  SO_BRIGHTNESSOFFSET = $00000001;
  SO_CALIB            = $00000001;
  SO_FORCEDREADOUT    = $00000002;

  SO_IMAGE_ANY        = 0;
  SO_IMAGE_INTRA      = 1;
  SO_IMAGE_PAN        = 2;
  SO_IMAGE_CEPH       = 3;
  SO_IMAGE_TOMO       = 4;

  SO_IMAGE_RAW        = 1;
  SO_IMAGE_DIB        = 2;
  SO_IMAGE_DCM        = 3;

  SO_READPLATE        = $00002000;
  SO_READPENDINGIMAGE = $00001000;             
  SO_ACTIVATEGUI      = $00010000;

  SO_SDXOPTIME	    = $00000001;
  SO_IDEXPRESS	    = $00000002;
  SO_IDEXPRESSORIGO = $00000082;

  SO_KAVOSCANEXAM	   = $00000020;
  SO_KAVOPANEXAM	   = $00000020;
  SO_KAVOSCANEXAMONE = $000000A0;
//***** End of DSD Constants

type TN_CMCDServObj3 = class (TK_CMCDServObj)
  CDSDevInd:    integer; // local Device index (synonim of CMDPProductName)
  CDSDllHandle: HMODULE; // DLL Windows Handle
  CDSErrorStr:   string; // Error message
  CDSErrorInt:  integer; // Error code
  CDSGroupInd:  integer; // Group Index: N_CMECD_SORE, N_CMECD_Kavo or N_CMECD_Inst

  function  CDSInitAll ( AGroupName, AProductName: string ): Integer;
  function  CDSFreeAll (): Integer;

  function  CDSGetGroupDevNames ( AGroupDevNames : TStrings ) : Integer; override;
  procedure CDSClearRegistry    ();
  procedure FCapturePrepare( APDevProfile: TK_PCMDeviceProfile; out ACMCaptDev3Form: TForm );
  procedure CDSCaptureImages    ( APDevProfile: TK_PCMDeviceProfile;
                                  var ASlidesArray : TN_UDCMSArray ); override;
  function  CDSStartCaptureToStudy  ( APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs) : TK_CMStudyCaptState; override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCD ServObj3 = class( TK_CMCDServObj )

var
  N_CMCDServObj3A: TN_CMCDServObj3; // Main: 'Digora Optime', 'Cranex D', 'Cranex Novus', 'PSPIX Scanner' devices
  N_CMCDServObj3B: TN_CMCDServObj3; // Kavo: 'Scan eXam', 'Pan eXam' devices
  N_CMCDServObj3C: TN_CMCDServObj3; // Inst: 'Express(TM)', 'Orthopantomograph(R)OP30' devices

  //***** SOREDEX (DSD) functions:
  N_CMECDOpenScanner:         TN_cdeclIntFuncVariant1;
  N_CMECDCloseScanner:        TN_cdeclIntFuncVoid;
  N_CMECDActivateSetup:       TN_cdeclIntFuncVoid;
  N_CMECDActivateScan:        TN_cdeclIntFuncInt;
  N_CMECDGetScannerVersion:   TN_cdeclIntFuncVoid;
  N_CMECDGetScannerStatus:    TN_cdeclIntFuncVoid;
  N_CMECDGetScannerStatusEx:  TN_cdeclIntFuncVoid;
  N_CMECDGetScannerLabel:     TN_cdeclPACharFuncVoid;
  N_CMECDSetImageFormat:      TN_cdeclIntFuncInt;
  N_CMECDGetImageFormat:      TN_cdeclIntFuncVoid;
  N_CMECDSetImageStore:       TN_cdeclIntFuncPAChar;
  N_CMECDGetImageStore:       TN_cdeclPACharFuncVoid;
  N_CMECDGetDSDImageStatus:   TN_cdeclIntFuncVoid; // Not needed, see N_CMECDGetScannerStatusEx
  N_CMECDDiscardImage:        TN_cdeclIntFuncVoid;
  N_CMECDFreeResources:       TN_cdeclProcVoid;
  N_CMECDOpenDSDLogFile:      TN_cdeclIntFuncPAChar3Int;
//  N_CMECDCloseDSDLogFile:     TN_cdeclProcVoid;
  N_CMECDSetPatientName:      TN_cdeclIntFuncPAChar;
  N_CMECDGetDSDPixelSize:     TN_cdeclIntFuncVoid;
  N_CMECDGetDSDImageSize:     TN_cdeclIntFuncVoid;

implementation

uses SysUtils, Dialogs,
  K_CLib0,
  N_Lib1, N_Gra2, N_CM1, N_CMCaptDev3sF;

//**************************************** TN_CMCDServObj3 **********

//********************************************** TN_CMCDServObj3.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj3 Group Name (SOREDEX, Kavo, Instrum)
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj3.CDSInitAll( AGroupName, AProductName: string ) : Integer;
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
  N_Dump1Str( 'Start CMCDServObj3.CDSInitAll' );
  DeviceIndex := -2;

  if AGroupName = N_CMECD_SOREDEX_Name then
  begin
         if AProductName = N_CMECD_DigoraOptName  then DeviceIndex := N_CMECD_DigoraOpt
    else if AProductName = N_CMECD_CranexDName    then DeviceIndex := N_CMECD_CranexD
    else if AProductName = N_CMECD_CranexNovName  then DeviceIndex := N_CMECD_CranexNov
    else if AProductName = N_CMECD_CranexNovEName then DeviceIndex := N_CMECD_CranexNovE
    else if AProductName = N_CMECD_PSPIXName      then DeviceIndex := N_CMECD_PSPIX
    else
    begin
      Result := 1; // wrong Device Name
      Exit;
    end;
  end else if AGroupName = N_CMECD_Kavo_Name then
  begin
         if AProductName = N_CMECD_ScaneXamName then DeviceIndex := N_CMECD_ScaneXam
    else if AProductName = N_CMECD_PaneXamName  then DeviceIndex := N_CMECD_PaneXam
    else
    begin
      Result := 1; // wrong Device Name
      Exit;
    end;
  end else if AGroupName = N_CMECD_Instrum_Name then
  begin
         if AProductName = N_CMECD_ExpressName      then DeviceIndex := N_CMECD_Express
    else if AProductName = N_CMECD_ExpressOrigoName then DeviceIndex := N_CMECD_ExpressOrigo
    else if AProductName = N_CMECD_OrthopanName     then DeviceIndex := N_CMECD_Orthopan
    else
    begin
      Result := 1; // wrong Device Name
      Exit;
    end;
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
  DllFName := 'SoredexDSD.dll';
  CDSErrorStr := '';
  Result := 0;

  N_Dump1Str( 'Before Windows.LoadLibrary ' + DllFName );
  CDSDllHandle := Windows.LoadLibrary( @DllFName[1] );
  N_Dump1Str( Format( 'After Windows.LoadLibrary %s, CDSDllHandle=%X', [DllFName,CDSDllHandle] ) );

  if CDSDllHandle = 0 then // some error
  begin
    CDSErrorStr := 'Error Loading ' + DllFName + ': ' + SysErrorMessage( GetLastError() );
    Result := 2; // Windows.LoadLibrary failed
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if CDSDllHandle = 0 then // some error

  //***** Load SOREDEX DLL functions

  FuncAnsiName := 'OpenScanner';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDOpenScanner := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDOpenScanner) then ReportError();

  FuncAnsiName := 'CloseScanner';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDCloseScanner := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDCloseScanner) then ReportError();

  FuncAnsiName := 'ActivateSetup';
  N_CMECDActivateSetup := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDActivateSetup) then ReportError();

  FuncAnsiName := 'ActivateScan';
  N_CMECDActivateScan := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDActivateScan) then ReportError();

  FuncAnsiName := 'GetScannerVersion';
  N_CMECDGetScannerVersion := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDGetScannerVersion) then ReportError();

  FuncAnsiName := 'GetScannerStatus';
  N_CMECDGetScannerStatus := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDGetScannerStatus) then ReportError();

  FuncAnsiName := 'GetScannerStatusExtended';
  N_CMECDGetScannerStatusEx := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDGetScannerStatusEx) then ReportError();

  FuncAnsiName := 'GetScannerLabel';
  N_CMECDGetScannerLabel := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDGetScannerLabel) then ReportError();

  FuncAnsiName := 'SetImageFormat';
  N_CMECDSetImageFormat := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDSetImageFormat) then ReportError();

  FuncAnsiName := 'GetImageFormat';
  N_CMECDGetImageFormat := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDGetImageFormat) then ReportError();

  FuncAnsiName := 'SetImageStore';
  N_CMECDSetImageStore := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDSetImageStore) then ReportError();

  FuncAnsiName := 'GetImageStore';
  N_CMECDGetImageStore := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDGetImageStore) then ReportError();

  FuncAnsiName := 'GetImageStatus';
  N_CMECDGetDSDImageStatus := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDGetDSDImageStatus) then ReportError();

  FuncAnsiName :=  'DiscardImage';
  N_CMECDDiscardImage := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDDiscardImage) then ReportError();

  FuncAnsiName := 'FreeResources';
  N_CMECDFreeResources := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDFreeResources) then ReportError();

  FuncAnsiName := 'OpenLogFile';
  N_CMECDOpenDSDLogFile := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDOpenDSDLogFile) then ReportError();

//  FuncAnsiName := 'CloseLogFile';
//  N_CMECDCloseDSDLogFile := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
//  if not Assigned(N_CMECDCloseDSDLogFile) then ReportError();

  FuncAnsiName := 'SetPatientName';
  N_CMECDSetPatientName := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDSetPatientName) then ReportError();

  FuncAnsiName := 'GetPixelSize';
  N_Dump1Str( IntToStr(Result) + ' Last, GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDGetDSDPixelSize := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDGetDSDPixelSize) then ReportError();

  FuncAnsiName := 'GetImageSize';
  N_Dump1Str( IntToStr(Result) + ' Last, GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDGetDSDImageSize := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDGetDSDImageSize) then ReportError();

  if Result <> 0 then // some error while loading DLL Entries
  begin
    K_CMShowMessageDlg( Format( 'Failed to initialise %s Errorcode=%d',
                                           [DllFName, Result] ), mtError );
    CDSFreeAll();
    N_Dump1Str( DllFName + ' Resources freed' );
  end;

  N_Dump1Str( 'Finish CMCDServObj3.CDSInitAll' );
end; // procedure TN_CMCDServObj3.CDSInitAll

//********************************************** TN_CMCDServObj3.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj3.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    N_CMECDDiscardImage();
    N_Dump2Str( 'Before N_CMECDFreeResources' );
    N_CMECDFreeResources();

    N_Dump2Str( 'Before SoredexDSD.dll FreeLibrary' );
    FreeLibrary( CDSDLLHandle );
    N_Dump2Str( 'After SoredexDSD.dll FreeLibrary' );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj3.CDSFreeAll

//************************************* TN_CMCDServObj3.CDSGetGroupDevNames ***
// Get SOREDEX Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj3.CDSGetGroupDevNames( AGroupDevNames: TStrings ) : Integer;
begin
  if CDSGroupInd = N_CMECD_SORE then
  begin
    AGroupDevNames.Add( N_CMECD_DigoraOptName );
    AGroupDevNames.Add( N_CMECD_CranexDName );
    AGroupDevNames.Add( N_CMECD_CranexNovName );
    AGroupDevNames.Add( N_CMECD_CranexNovEName );
    AGroupDevNames.Add( N_CMECD_PSPIXName );
  end else if CDSGroupInd = N_CMECD_Kavo then
  begin
    AGroupDevNames.Add( N_CMECD_ScaneXamName );
    AGroupDevNames.Add( N_CMECD_ScaneXamOneName );
    AGroupDevNames.Add( N_CMECD_PaneXamName );
  end else if CDSGroupInd = N_CMECD_Inst then
  begin
    AGroupDevNames.Add( N_CMECD_ExpressName );
    AGroupDevNames.Add( N_CMECD_ExpressOrigoName );
    AGroupDevNames.Add( N_CMECD_OrthopanName );
  end;

  Result := AGroupDevNames.Count;
end; // procedure TN_CMCDServObj3.CDSGetGroupDevNames

//**************************************** TN_CMCDServObj3.CDSClearRegistry ***
// Clear two Soredes related flags in Registry.
//
// For Win32 clear:
//   HKEY_LOCAL_MACHINE\SOFTWARE\Soredex\Dsd\Uid\UAFlag
//   HKEY_LOCAL_MACHINE\SOFTWARE\Soredex\Dsd\Ctt\UAFlag
// For Win64 clear:
//   HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Soredex\Dsd\Uid\UAFlag
//   HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Soredex\Dsd\Ctt\UAFlag
//
procedure TN_CMCDServObj3.CDSClearRegistry();
var
  ResCode: integer;
  HK1, HK2: HKey;
  ValSize, FlagValue: DWORD;
  Label CheckUid, CloseAndExit;
begin
  N_Dump1Str( '  Start CDSClearRegistry' );

  ResCode := RegOpenKeyExA( HKEY_LOCAL_MACHINE, 'SOFTWARE', 0, KEY_ALL_ACCESS, HK1 );
  if ResCode <> ERROR_SUCCESS then
  begin
    N_Dump1Str( '  RegOpenKeyExA 1 error (SOFTWARE)' );
    Exit;
  end;

{
  if K_IsWin64Bit() then // Win64
  begin
    HK2 := HK1;
    ResCode := RegOpenKeyExA( HK2, 'Wow6432Node', 0, KEY_ALL_ACCESS, HK1 );
    if ResCode <> ERROR_SUCCESS then
    begin
      N_Dump1Str( '  RegOpenKeyExA 2 error (Wow6432Node)' );
      RegCloseKey( HK2 );
      Exit;
    end;
  end; // if K_IsWin64Bit() then // Win64
}

  ResCode := RegOpenKeyExA( HK1, 'Soredex', 0, KEY_ALL_ACCESS, HK2 );
  if ResCode <> ERROR_SUCCESS then
  begin
    N_Dump1Str( '  RegOpenKeyExA 3 error (Soredex)' );
    RegCloseKey( HK1 );
    Exit;
  end;

  ResCode := RegOpenKeyExA( HK2, 'Dsd', 0, KEY_ALL_ACCESS, HK1 );
  if ResCode <> ERROR_SUCCESS then
  begin
    N_Dump1Str( '  RegOpenKeyExA 4 error (Dsd)' );
    goto CloseAndExit;
  end;

  ResCode := RegOpenKeyExA( HK1, 'Ctt', 0, KEY_ALL_ACCESS, HK2 );
  if ResCode <> ERROR_SUCCESS then
  begin
    N_Dump1Str( '  RegOpenKeyExA 5 error (Ctt)' );
    goto CheckUid;
  end;

  ValSize := 4;
  ResCode := RegQueryValueExA( HK2, 'UAFlag', nil, nil, PByte(@FlagValue), PDWORD(@ValSize) );
  if (ResCode = ERROR_SUCCESS) and (FlagValue <> 0) then // Clear Ctt\UAFlag
  begin
    N_Dump1Str( '  Clear Ctt\UAFlag' );
    FlagValue := 0;
    ResCode := RegSetValueExA( HK2, 'UAFlag', 0, REG_DWORD, PByte(@FlagValue), ValSize );
    if ResCode <> ERROR_SUCCESS then
    begin
      N_Dump1Str( '  RegSetValueExA 6 error' );
    end;
  end; // if (ResCode = ERROR_SUCCESS) and (FlagValue <> 0) then // Clear Ctt\UAFlag


  CheckUid: //*********************************

  ResCode := RegOpenKeyExA( HK1, 'Uid', 0, KEY_ALL_ACCESS, HK2 );
  if ResCode <> ERROR_SUCCESS then
  begin
    N_Dump1Str( '  RegOpenKeyExA 7 error (Uid)' );
    goto CloseAndExit;
  end;

  ValSize := 4;
  ResCode := RegQueryValueExA( HK2, 'UAFlag', nil, nil, PByte(@FlagValue), PDWORD(@ValSize) );
  if (ResCode = ERROR_SUCCESS) and (FlagValue <> 0) then // Clear Uid\UAFlag
  begin
    N_Dump1Str( '  Clear Uid\UAFlag' );
    FlagValue := 0;
    ResCode := RegSetValueExA( HK2, 'UAFlag', 0, REG_DWORD, PByte(@FlagValue), ValSize );
    if ResCode <> ERROR_SUCCESS then
    begin
      N_Dump1Str( '  RegSetValueExA 8 error' );
      Exit;
    end;
  end; // if (ResCode = ERROR_SUCCESS) and (FlagValue <> 0) then // Clear Uid\UAFlag

  CloseAndExit : // *********************

  ResCode := RegCloseKey( HK2 );
  if ResCode <> ERROR_SUCCESS then
    N_Dump1Str( '  RegCloseKey( HK2 ) error' );

  ResCode := RegCloseKey( HK1 );
  if ResCode <> ERROR_SUCCESS then
    N_Dump1Str( '  RegCloseKey( HK1) error' );
end; // procedure TN_CMCDServObj3.CDSClearRegistry

//***************************************** TN_CMCDServObj3.FCapturePrepare ***
// Capture prepare for ordinary capture images and capture to opened study
//
//     Parameters
// APDevProfile - pointer to device profile record
//
procedure TN_CMCDServObj3.FCapturePrepare( APDevProfile: TK_PCMDeviceProfile; out ACMCaptDev3Form: TForm );
var
  ResCode: integer;
  CaptForm: TN_CMCaptDev3Form;
begin
  ACMCaptDev3Form := nil;
  if not ( (APDevProfile^.CMDPGroupName = N_CMECD_SOREDEX_Name) or
           (APDevProfile^.CMDPGroupName = N_CMECD_Kavo_Name)    or
           (APDevProfile^.CMDPGroupName = N_CMECD_Instrum_Name) )  then // a precaution
  begin
    CDSErrorStr := 'Bad TN_CMCDServObj3 Group Name! - ' + APDevProfile^.CMDPGroupName;
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if ResCode <> 0 then // some error

  if N_MemIniToBool( 'CMS_UserDeb', 'DSDUAFLAG', FALSE ) then
    CDSClearRegistry();

  N_Dump1Str( 'FCapturePrepare before CDSInitAll' );
  ResCode := CDSInitAll( APDevProfile^.CMDPGroupName, APDevProfile^.CMDPProductName );
  N_Dump1Str( 'FCapturePrepare After CDSInitAll ' + IntToStr(ResCode) );

  if ResCode <> 0 then // some error
  begin
    K_CMShowMessageDlg( 'Device library cannot be initialized', mtError );
    Exit;
  end; // if ResCode <> 0 then // some error

  CaptForm := TN_CMCaptDev3Form.Create( Application );
  with CaptForm, APDevProfile^ do
  begin
//    BFFlags := BFFlags + [bffToDump1,bffDumpPos];
    N_Dump1Str( 'FCapturePrepare before BaseFormInit' );

    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    CMOFPProfile    := TK_PCMOtherProfile(APDevProfile); // set CMCaptDev3Form.CMOFPProfile field
    CMOFDeviceIndex := CDSDevInd;
    Caption         := CMDPCaption;
  end; // with CMCaptDev3Form, APDevProfile^ do
  ACMCaptDev3Form := CaptForm;

end; // function TN_CMCDServObj3.FCapturePrepare

//**************************************** TN_CMCDServObj3.CDSCaptureImages ***
// Capture Images by SOREDEX and fill ASlidesArray by them
//
//     Parameters
// APDevProfile - pointer to device profile record
// ASlidesArray - captured Slides array
//
// Is called from CMResForm.NewOtherOnExecuteHandler
//    CDServObj.CDSCaptureImages( PCMDeviceProfile, CaptSlidesArray );
//
procedure TN_CMCDServObj3.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                            var ASlidesArray: TN_UDCMSArray );
var
  CaptForm: TN_CMCaptDev3Form;
begin
  N_Dump1Str( 'Start TN_CMCDServObj3.CDSCaptureImages' );
  SetLength( ASlidesArray, 0 );

  FCapturePrepare(APDevProfile, TForm(CaptForm));
  if CaptForm = nil then Exit;

  with CaptForm, APDevProfile^ do
  begin
//    BFFlags := BFFlags + [bffToDump1,bffDumpPos];
    CMOFPNewSlides  := @ASlidesArray; // for using in CMCaptDev3Form methods

    N_Dump1Str( 'CDSCaptureImages before ShowModal' );
    ShowModal();
  end; // with CMCaptDev3Form, APDevProfile^ do

  CDSFreeAll();

end; // procedure TN_CMCDServObj3.CDSCaptureImages

//********************************** TN_CMCDServObj3.CDSStartCaptureToStudy ***
// Start Capture to study
//
//     Parameters
// APDevProfile - pointer to device profile record
// AStudyDevCaptAttrs - resulting Device Capture Interface
// Result - Returns Study Capture State code (TK_CMStudyCaptState)
//
function TN_CMCDServObj3.CDSStartCaptureToStudy(  APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState;
{
var
  CaptForm: TN_CMCaptDev3Form;
}
begin
  Result := inherited CDSStartCaptureToStudy( APDevProfile, AStudyDevCaptAttrs );
{
  FCapturePrepare(APDevProfile, TForm(CaptForm));
  if CaptForm = nil then Exit;

  Result := K_cmscOK;
  with AStudyDevCaptAttrs do
  begin
    CMSDCDDlg := CaptForm;
    CMSDCDDlgCPanel := CaptForm.CtrlsPanel;
  end;
}
end; // function TN_CMCDServObj3.CDSStartCaptureToStudy

//********************************* TN_CMCDServObj3.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj3.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  if CDSName = N_CMECD_SOREDEX_Name then
  begin

  if AProductName = N_CMECD_DigoraOptName then
    Result := 20
  else if AProductName = N_CMECD_CranexDName then
    Result := 12
  else if AProductName = N_CMECD_CranexNovName then
    Result := 12
  else if AProductName = N_CMECD_CranexNovEName then
    Result := 12
  else if AProductName = N_CMECD_PSPIXName then
    Result := 21;

  end
  else if CDSName = N_CMECD_Kavo_Name then
  begin

  if AProductName = N_CMECD_ScaneXamName then
    Result := 43
  else if AProductName = N_CMECD_ScaneXamOneName then
    Result := 43
  else if AProductName = N_CMECD_PaneXamName then
    Result := 24;

  end
  else if CDSName = N_CMECD_Instrum_Name then
  begin

  if AProductName = N_CMECD_ExpressName then
    Result := 43
  else if AProductName = N_CMECD_ExpressOrigoName then
    Result := 43
  else if AProductName = N_CMECD_OrthopanName then
    Result := 24;

  end
  else
    Result := 0;

end; // function TN_CMCDServObj3.CDSGetDefaultDevIconInd

//********************************** TN_CMCDServObj3.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj3.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin

  if CDSName = N_CMECD_SOREDEX_Name then
  begin

  if AProductName = N_CMECD_DigoraOptName then
    Result := 'DX'
  else if AProductName = N_CMECD_CranexDName then
    Result := 'DX'
  else if AProductName = N_CMECD_CranexNovName then
    Result := 'PX'
  else if AProductName = N_CMECD_CranexNovEName then
    Result := 'PX'
  else if AProductName = N_CMECD_PSPIXName then
    Result := 'IO';

  end
  else if CDSName = N_CMECD_Kavo_Name then
  begin

  if AProductName = N_CMECD_ScaneXamName then
    Result := 'IO'
  else if AProductName = N_CMECD_ScaneXamOneName then
    Result := 'IO'
  else if AProductName = N_CMECD_PaneXamName then
    Result := 'DX';

  end
  else if CDSName = N_CMECD_Instrum_Name then
  begin

  if AProductName = N_CMECD_ExpressName then
    Result := 'IO'
  else if AProductName = N_CMECD_ExpressOrigoName then
    Result := 'IO'
  else if AProductName = N_CMECD_OrthopanName then
    Result := 'PX';

  end;

end; // function TN_CMCDServObj3.CDSGetDefaultDevDCMMod



Initialization

// Create and Register three SOREDEX Service Objects

  N_CMCDServObj3A := TN_CMCDServObj3.Create( N_CMECD_SOREDEX_Name );
  N_CMCDServObj3A.CDSGroupInd := N_CMECD_SORE;
  with K_CMCDRegisterDeviceObj( N_CMCDServObj3A ) do
  begin
    CDSCaption := 'Soredex';
    IsGroup    := TRUE;
  end;

  N_CMCDServObj3B := TN_CMCDServObj3.Create( N_CMECD_Kavo_Name );
  N_CMCDServObj3B.CDSGroupInd := N_CMECD_Kavo;
  with K_CMCDRegisterDeviceObj( N_CMCDServObj3B ) do
  begin
    CDSCaption := 'Kavo';
    IsGroup    := TRUE;
  end;

  N_CMCDServObj3C := TN_CMCDServObj3.Create( N_CMECD_Instrum_Name );
  N_CMCDServObj3C.CDSGroupInd := N_CMECD_Inst;
  with K_CMCDRegisterDeviceObj( N_CMCDServObj3C ) do
  begin
    CDSCaption := 'Instrumentarium';
    IsGroup    := TRUE;
  end;

end.
