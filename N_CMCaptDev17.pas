unit N_CMCaptDev17;
// Progeny device

// 29.06.15 - added a support of multiple devices
// 17.08.18 - wrk to tmp
// 05.11.18 - settings interface changed
// 2018.11.07 CDSGetDefaultDevIconInd function added

interface

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev17F,
  N_CML2F;

const
  WM_IMAGECALLBACK = WM_USER + 2;

  N_CMECD_ClearVision = 'ClearVision';
  N_CMECD_VetProVDX   = 'VetPro VDX';
  N_CMECD_VantagePan  = 'Vantage Pan';
  N_CMECD_VisionDX600 = 'VisionDX 600';
  N_CMECD_VisionDX500 = 'VisionDX 500';
  N_CMECD_VetProCR    = 'VetPro CR';

type TN_CMCDServObj17 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr:   string;  // Error message
  CDSErrorInt:   integer; // Error code

  function CDSInitAll(AGroupName, AProductName: string ): Integer;
  function CDSFreeAll(): Integer;

  function CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer; override;
  function StartDriver( FormHandle: Integer ): Boolean;
  procedure SendExtMsg ( Cmd, Param1, Param2, Param3: Integer );
  procedure CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg      ( APDevProfile: TK_PCMDeviceProfile ); override;

  destructor Destroy; override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCD ServObj17 = class( TK_CMCDServObj )

type PDK_WIN32_Image = record
//   public
	// Image Acquisition completion flag. If True, the acquisition is completed.
	ImageCompleted: Boolean;

  // Acquired Image Width in pixels.
	ImageWidth: Cardinal;

	// Acquired Image Height in pixels.
	ImageHeight: Cardinal;

	// Number of Double Words in one line of the Acquired Image.
	ImageLineNumberOfDWords: Cardinal;

	//Number of Bits Per Pixel of the Acquired Image. It should be 16 bits.
	//Please, contact support if more information needed.
	ImageNumberOfBitsPerPixel: Word;

	//Acquired Image Data. The data should not have any header,
  //and should be aligned along a Double Word boundary.
	ImageData: Pointer; //unsigned char*

	//Acquired Image Data Size in bytes. It is equal to Acquired Image Height multiplied by
	//Number of Double Words in one line of the Acquired Image multiplied by four.
	ImageDataSize: Cardinal;
end;

type PPDK_WIN32_Image = ^PDK_WIN32_Image;

var
//image stuff
Image: PDK_WIN32_Image;
Device: Integer;
ProductName, GroupName: string;

var
//  N_CMECD_GetDevices: TN_cdeclIntFuncPtr;
//  N_CMECD_InitializeWin32Library3: TN_cdeclIntPtr2FuncInt;
//  N_CMECD_InitializeWin32Library1: TN_cdeclIntFuncVoid;

  N_CMCDServObj17: TN_CMCDServObj17;
  CMCaptDev17Form: TN_CMCaptDev17Form;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0, N_CMCaptDev17aF;

//************************************************* TN_CMCDServObj17 **********

//********************************************** TN_CMCDServObj3.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj3 Group Name
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj17.CDSInitAll(AGroupName, AProductName: string )
                                                                      : Integer;
begin
  if AProductName = N_CMECD_ClearVision then Device := 1;
  if AProductName = N_CMECD_VetProVDX   then Device := 2;
  if AProductName = N_CMECD_VantagePan  then Device := 3;
  if AProductName = N_CMECD_VisionDX600 then Device := 4;
  if AProductName = N_CMECD_VisionDX500 then Device := 5;
  if AProductName = N_CMECD_VetProCR    then Device := 6;

  CDSErrorStr := '';
  Result := 0;
end; // procedure N_CMCDServObj17.CDSInitAll

//********************************************** TN_CMCDServObj3.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj17.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj3.CDSFreeAll

//**************************************** N_CMCDServObj17.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj17.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
var
  ResCode: Integer;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Progeny >> CDSCaptureImages begin' );

  ProductName := APDevProfile^.CMDPProductName;
  GroupName := APDevProfile^.CMDPGroupName;

  N_Dump1Str( 'CDSCaptureImages before CDSInitAll' );
  ResCode := CDSInitAll( GroupName, ProductName );
  N_Dump1Str( 'CDSCaptureImages After CDSInitAll ' + IntToStr(ResCode) );

  SetLength(ASlidesArray, 0);
  CMCaptDev17Form          := TN_CMCaptDev17Form.Create(Application);
  CMCaptDev17Form.ThisForm := CMCaptDev17Form;

  with CMCaptDev17Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'Progeny >> CDSCaptureImages before ShowModal' );

    ShowModal();
    
    CDSFreeAll();
    N_Dump1Str( 'Progeny >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do

  N_Dump1Str( 'Progeny >> CDSCaptureImages end' );
end; // procedure N_CMCDServObj17.CDSCaptureImages

//******************************************** TN_CMCDServObj13.StartDriver ***
// Start C++ driver
//
//    Parameters
// FormHandle - CMS Capture or Setup Form's handle
// Result     - True if driver started successfully, else False
//
function TN_CMCDServObj17.StartDriver( FormHandle: Integer ): Boolean;
var
  WrkDir, LogDir, CurDir, FileName, cmd: String;
begin
  Result       := False;
  ProgenyHandle := 0;
  WrkDir       := K_ExpandFileName( '(#TmpFiles#)' );
  LogDir       := N_CMV_GetLogDir();
  CurDir       := ExtractFilePath( ParamStr( 0 ) );
  N_Dump1Str( 'Progeny >> Exe directory = "' + CurDir + '"' );
  FileName  := CurDir + 'Progeny\Progeny.exe';

  // wait old driver session closing
  N_CMV_WaitProcess( False, FileName, -1 );

  if not FileExists( FileName ) then // find driver
  begin
    Exit;
  end; // if not FileExists( FileName ) then // find driver

  WrkDir  := StringReplace(WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase]);

  cmd := '"' + WrkDir + '" "' + IntToStr( FormHandle ) + '" "' +
                                                       IntToStr( Device ) + '"';

  // start driver executable file with command line parameters
  Result := N_CMV_CreateProcess( '"' + FileName + '" ' + cmd );

  if not Result then // if driver start fail
  begin
    Exit;
  end; // if not Result then // if driver start fail
end; // function TN_CMCDServObj13.StartDriver

//********************************************* TN_CMCDServObj17.SendExtMsg ***
// Send message to C++ driver
//
//    Parameters
// Cmd - command for driver
// Param1 - 1st parameter
// Param2 - 2nd parameter
// Param3 - 3rd parameter
//
procedure TN_CMCDServObj17.SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
begin
end; // procedure SendExtMsg

//***************************************** TN_CMCDServObj17.CDSSettingsDlg ***
// Show Special Seting Dialog
//
//     Parameters
// APDevProfile - Pointer to Device Profile record
//
procedure TN_CMCDServObj17.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev17aForm;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Progeny >> CDSSettingsDlg begin' );
  Form := TN_CMCaptDev17aForm.Create( application );
  // create setup form
  Form.ThisForm := Form;
  Form.N_CMCDServObj17 := N_CMCDServObj17;
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
  Form.CMOFPDevProfile := APDevProfile; // link form variable to profile

  Form.CMOFPDevProfile := PProfile;

  Form.ShowModal(); // Show setup form
  N_Dump1Str( 'Progeny >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj5.CDSSettingsDlg

//************************************* TN_CMCDServObj3.CDSGetGroupDevNames ***
// Get Progeny Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj17.CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer;
begin
  AGroupDevNames.Add( N_CMECD_ClearVision );
  AGroupDevNames.Add( N_CMECD_VetProVDX );
  AGroupDevNames.Add( N_CMECD_VantagePan );
  AGroupDevNames.Add( N_CMECD_VisionDX600 );
  AGroupDevNames.Add( N_CMECD_VisionDX500 );
  AGroupDevNames.Add( N_CMECD_VetProCR );

  Result := AGroupDevNames.Count;
end; // function TN_CMCDServObj17.CDSGetGroupDevNames

// destructor N_CMCDServObj17.Destroy
//
destructor TN_CMCDServObj17.Destroy();
begin
  //CDSFreeAll();
end; // destructor N_CMCDServObj17.Destroy

//******************************** TN_CMCDServObj17.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj17.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin

  if AProductName = N_CMECD_ClearVision then
    Result := 23
  else if AProductName = N_CMECD_VetProVDX then
    Result := 23
  else if AProductName = N_CMECD_VantagePan then
    Result := 24
  else if AProductName = N_CMECD_VisionDX600 then
    Result := 23
  else if AProductName = N_CMECD_VisionDX500 then
    Result := 23
  else if AProductName = N_CMECD_VetProCR then
    Result := 23;

end; // function TN_CMCDServObj17.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj17.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj17.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin

  if AProductName = N_CMECD_ClearVision then
    Result := 'IO'
  else
    Result := 'IO';

end; // function TN_CMCDServObj17.CDSGetDefaultDevDCMMod


Initialization

// Create and Register Progeny Service Object
N_CMCDServObj17 := TN_CMCDServObj17.Create( N_CMECD_Progeny_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj17 ) do
begin
  CDSCaption := 'Progeny';
  IsGroup := True;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj17 ) do

end.
