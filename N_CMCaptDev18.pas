unit N_CMCaptDev18;
// PaloDEx device

// 25.04.16 - 1st version is finished
// 22.08.16 - change error while loading dll message (shortened)
// 17.08.18 - wrk to tmp
// 05.11.18 - settings interface changed
// 2018.11.07 CDSGetDefaultDevIconInd function added

interface

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev18F, N_CML2F;

const
  N_NCI_API_VERSION = 2; // API version of this header file give this in nci_configuration api_version

  N_NCI_PATIENT_ID_MAX_LENGTH =     64; // maximum length of patient_id
  N_NCI_PATIENT_NAME_MAX_LENGTH =  256; // maximum length of patient_name
  N_NCI_APPLICATION_ID_MAX_LENGTH = 32; // maximum length of application_id
  N_NCI_WORKSTATION_ID_MAX_LENGTH = 32; // maximum length of workstation_id
  N_NCI_USER_ID_MAX_LENGTH =        32; // maximum length of user_id
  N_NCI_VOLUME_PATH_MAX_LENGTH =   512; // maximum length of volume_path
  N_NCI_IMAGE_PATH_MAX_LENGTH =    512; // maximum length of image_path
  N_NCI_IMAGE_ID_MAX_LENGTH =       32; // maximum length of image_id
  N_NCI_GUARD_ZONE_LENGTH =         32; // size of padding between strings fields in struct
  N_NCI_BINARY_PATH_MAX_LENGTH =   512; // maximum length of binary_path

  N_CMECD_InstrumentariumDental = 'Instrumentarium Dental';
  N_CMECD_SOREDEX               = 'SOREDEX';
  N_CMECD_KaVo                  = 'KaVo';

type N_NCI_Configuration = packed record
  NCICAPI_Version: integer;               // requested API major version, must be NCI_API_VERSION
  NCICReserved1: array [0..0] of integer; // reserved must be 0's
  NCICStruct_Size: integer;               // set to sizeof(nci_configuration)
  NCICReserved2: array [0..4] of integer; // reserved must be 0's

  NCICMode:  integer;         // mode of operation (default: nci_mode_normal)
  NCICBrand: integer;         // brand selection, mandatory in NCI_OpenS (default: nci_brand_undefined)
  NCICImage_Format:  integer; // image export format (default: nci_format_tiff)
  NCICVolume_Format: integer; // volume export format (default: nci_format_tiff)

  NCICDisable_3D:             integer; // disable 3D image capture (default: nci_choice_false)
  NCICDisable_Multilayer_Pan: integer; // disable multi-layer panoramic (default: nci_choice_false)
  NCICParent_HWND:            UInt64;  // handle of parent window (default: undefined)
  NCICLanguage_ISO639_1:            array [0..2] of AnsiChar; // language of user interface as defined in ISO639-1 standard (default: undefined), fallbacks OS language, English
  NCICLanguage_Region_ISO3166_1_a2: array [0..2] of AnsiChar; // region of user interface as defined in ISO 3166-1 alpha-2 (default: undefined)

  // use of pointer avoided here.. are fixed lengths ok?
  NCICImage_Path:     array [0..N_NCI_IMAGE_PATH_MAX_LENGTH-1]     of AnsiChar; // image storage path, can't be left empty in NCI_OpenS, checked that is writable and warning in GUI if storage space is low
  NCICGuard1:         array [0..N_NCI_GUARD_ZONE_LENGTH-1]         of AnsiChar; // used to detect memory access problems must be 0's
  NCICVolume_Path:    array [0..N_NCI_VOLUME_PATH_MAX_LENGTH-1]    of AnsiChar; // volume storage path, will be the same as image_path if left empty in NCI_OpenS
  NCICGuard2:         array [0..N_NCI_GUARD_ZONE_LENGTH-1]         of AnsiChar; // used to detect memory access problems must be 0's
  NCICApplication_ID: array [0..N_NCI_APPLICATION_ID_MAX_LENGTH-1] of AnsiChar; // application identifier used for device list and image storage use only letters [a-z_], mandatory in NCI_OpenS
  NCICGuard3:         array [0..N_NCI_GUARD_ZONE_LENGTH-1]         of AnsiChar; // used to detect memory access problems must be 0's
  NCICWorkstation_ID: array [0..N_NCI_WORKSTATION_ID_MAX_LENGTH-1] of AnsiChar; // workstation identifier used in some devices GUI's (default: hostname without domain)
  NCICGuard4:         array [0..N_NCI_GUARD_ZONE_LENGTH-1]         of AnsiChar; // used to detect memory access problems must be 0's
  NCICUser_ID:        array [0..N_NCI_USER_ID_MAX_LENGTH-1]        of AnsiChar; // user identifier used for user preferred image post-processing (default: undefined)
  NCICGuard5:         array [0..N_NCI_GUARD_ZONE_LENGTH-1]         of AnsiChar; // used to detect memory access problems must be 0's
  NCICPatient_ID:     array [0..N_NCI_PATIENT_ID_MAX_LENGTH-1]     of AnsiChar; // unique patient identifier, mandatory for image capture (default: undefined)
  NCICGuard6:         array [0..N_NCI_GUARD_ZONE_LENGTH-1]         of AnsiChar; // used to detect memory access problems must be 0's
  NCICPatient_Name:   array [0..N_NCI_PATIENT_NAME_MAX_LENGTH-1]   of AnsiChar; // name of patient that can be shown in some device GUI's (default: undefined)
  NCICGuard7:         array [0..N_NCI_GUARD_ZONE_LENGTH-1]         of AnsiChar; // used to detect memory access problems must be 0's

  NCICBinary_Path:    array [0..N_NCI_BINARY_PATH_MAX_LENGTH-1]    of AnsiChar; // DO NOT USE! Path to nci gui binary (for NCI internal use only)
  NCICGuard8:         array [0..N_NCI_GUARD_ZONE_LENGTH-1]         of AnsiChar; // used to detect memory access problems, must be 0's
end;

type N_NCI_Event_Data = packed record
  NCIEDTrigger_Event: integer; // triggering event
  NCIEDGui_State:     integer; // state of user interface
  NCIEDDevice_State:  integer; // highest state of devices
  NCIEDImage_State:   integer; // state of image

  // absolute path to image file, available when image_state>nci_image_none
  //
  // note image is uniquely identified with image_id and image_index
  //
  NCIEDImage_Filename: array [0..N_NCI_IMAGE_PATH_MAX_LENGTH-1] of AnsiChar;

  ///! identifier of image series, available when image_state>nci_image_none
  NCIEDImage_ID: array [0..N_NCI_IMAGE_ID_MAX_LENGTH-1] of AnsiChar;

  ///! index of image in series (1..image_count), available when image_state>nci_image_none
  NCIEDImage_Index: integer;

  ///! count of images in series, available when image_state>nci_image_none
  NCIEDImage_Count: integer;

  ///! patient identifier provided by application, available when image_state>nci_image_none
  NCIEDPatient_ID: array [0..N_NCI_PATIENT_ID_MAX_LENGTH-1] of AnsiChar;

  // future api expansions append data here
end;

type PN_NCI_Event_Data = ^N_NCI_Event_Data;

type TN_CMCDServObj18 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr:   string;  // Error message
  CDSErrorInt:   integer; // Error code

  CDSDeviceNum: integer;

  function CDSInitAll( AGroupName, AProductName: string ): Integer;
  function CDSFreeAll(): Integer;

  function  CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer;  override;
  procedure CDSCaptureImages   ( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg     ( APDevProfile: TK_PCMDeviceProfile );  override;

  destructor Destroy; override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCDServObj11 = class( TK_CMCDServObj )

var
  N_CMECDNCI_OpenS: TN_cdeclIntFuncPtr;
  N_CMECDNCI_ShowS: TN_cdeclIntFuncInt;
  N_CMECDNCI_GetEventS: TN_cdeclIntFuncPtrInt;
  N_CMECDNCI_DiscardS: TN_cdeclIntFuncPtr;
  N_CMECDNCI_CloseS: TN_cdeclIntFuncInt;

  N_ProductName, N_GroupName: string;

  N_CMCDServObj18: TN_CMCDServObj18;
  N_App_NCI: N_NCI_Configuration;
  N_CMCaptDev18Form: TN_CMCaptDev18Form;

  function N_ProcessEvent ( Data: PN_NCI_Event_Data ): integer;
  function N_HandleEvent  (): integer;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0, N_CMCaptDev18aF;

//********************************************************** N_ProcessEvent ***
// Process retrieved event in HandleEvent
//
//     Parameters
// Result - return 0 if OK, 1 if window is closed
//
function N_ProcessEvent( Data: PN_NCI_Event_Data ): integer;
begin
  Result := 0;
  N_Dump1Str( 'Trigger Event = '+IntToStr(Data.NCIEDTrigger_Event) );

  if ( Data.NCIEDTrigger_Event = 3 ) then
  begin
    Inc( N_CMCaptDev18Form.CMOFImageCount );
    // New image received. Application is responsible for taking care of the
    // TIFF file copy/move/rename/show/delete etc.
    N_Dump1Str( 'Image file: ' + Data.NCIEDImage_Filename );

    N_CMCaptDev18Form.SaveImage( N_AnsiToString(Data.NCIEDImage_Filename) );
    DeleteFile( N_AnsiToString(Data.NCIEDImage_Filename) );

    // discard, when all images with same image_id are received
    // i.e., discard only when last index is received
    if ( Data.NCIEDImage_Index >= Data.NCIEDImage_Count ) then
    begin
      N_Dump1Str( 'Calling NCI_DiscardS() with id: ' + Data.NCIEDImage_ID );
      if ( N_CMECDNCI_DiscardS( @(Data.NCIEDImage_ID[0]) ) < 0 ) then
      begin
        // Get and print error message if not ok
        //reportNCIError("NCI_DiscardS()");
        N_Dump1Str( 'Error with NCI_DiscardS' );
      end;
      // Discarding will close API connection in normal mode and we will
      // receive nci_event_closed. But in template mode, we would need to
      // close the connection.
    end;
  end;

  // connection to NCI has been closed
  if ( Data.NCIEDTrigger_Event = 4 ) then
    Result := 1;
end; // function N_ProcessEvent

//*********************************************************** N_HandleEvent ***
// Handle retrieved event, process it if necessary
//
//     Parameters
// Result - return 0 if OK, 1 if window is closed
//
function N_HandleEvent(): integer;
var
  Event_Data: N_NCI_Event_Data;
  Wait_Time_ms, RetVal: integer;
begin
  Result := 0;

  // retrieve a new event from the event queue
  Wait_Time_ms := 100;

  RetVal := N_CMECDNCI_GetEventS( @Event_Data, Wait_Time_ms );

  N_CMCaptDev18Form.CMOFStatus := Event_Data.NCIEDDevice_State;

  if ( RetVal = -5 ) then
  begin
    // there is no event waiting, return k_continue
  end
  else if ( RetVal >= 0 ) then
    // handle the event that was just retrieved
    Result := N_ProcessEvent( @Event_Data )
  else
  begin
    // call failed, get and print error message
    Result := 1;
    //reportNCIError("NCI_GetEventS()");
  end;
end; // function N_HandleEvent()

//************************************************* TN_CMCDServObj18 **********

//********************************************* TN_CMCDServObj18.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj18 Group Name (SOREDEX, Kavo, Instrum)
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj18.CDSInitAll( AGroupName, AProductName: string )
                                                                      : Integer;
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
  N_Dump1Str( 'Start CMCDServObj18.CDSInitAll' );

  if AProductName = N_CMECD_InstrumentariumDental then CDSDeviceNum := 1;
  if AProductName = N_CMECD_SOREDEX               then CDSDeviceNum := 2;
  if AProductName = N_CMECD_KaVo                  then CDSDeviceNum := 3;

  CDSErrorStr := '';
  Result := 0;

  if CDSDllHandle <> 0 then // CDSDevInd already initialized
  begin
    CDSFreeAll();
  end; // if CDSDllHandle <> 0 then // CDSDevInd already initialized

  DllFName := 'ncihl-sdk.dll';

  CDSErrorStr := '';
  Result := 0;

  N_Dump1Str( 'Before Windows.LoadLibrary ' + DllFName );
  CDSDllHandle := Windows.LoadLibrary( @DllFName[1] );
  N_Dump1Str( Format( 'After Windows.LoadLibrary %s, CDSDllHandle=%X',
                                                    [DllFName,CDSDllHandle] ) );

  if CDSDllHandle = 0 then // some error
  begin
    CDSErrorStr := 'Error Loading ' + DllFName;
    Result := 2; // Windows.LoadLibrary failed
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if CDSDllHandle = 0 then // some error

  //***** Load EzSensor DLL functions

  FuncAnsiName := 'NCI_OpenS';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDNCI_OpenS := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDNCI_OpenS) then ReportError();

  FuncAnsiName := 'NCI_ShowS';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDNCI_ShowS := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDNCI_ShowS) then ReportError();

  FuncAnsiName := 'NCI_GetEventS';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDNCI_GetEventS := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDNCI_GetEventS) then ReportError();

  FuncAnsiName := 'NCI_DiscardS';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDNCI_DiscardS := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDNCI_DiscardS) then ReportError();

  FuncAnsiName := 'NCI_CloseS';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDNCI_CloseS := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDNCI_CloseS) then ReportError();

  if Result <> 0 then // some error while loading DLL Entries
  begin
    K_CMShowMessageDlg( Format( 'Failed to initialise %s Errorcode=%d',
                                           [DllFName, Result] ), mtError );
    CDSFreeAll();
    N_Dump1Str( DllFName + ' Resources freed' );
  end;

  N_Dump1Str( 'PaloDEx >> CDSInitAll end' );
end; // procedure N_CMCDServObj18.CDSInitAll

//********************************************** TN_CMCDServObj3.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj18.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    N_Dump2Str( 'After FreeLibrary' );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj3.CDSFreeAll

//***************************************** TN_CMCDServObj14.CDSSettingsDlg ***
// call settings dialog
//
//    Parameters
// APDevProfile - pointer to profile
//
procedure TN_CMCDServObj18.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev18aForm; // Settings form
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'PaloDEx >> CDSSettingsDlg begin' );

  Form := TN_CMCaptDev18aForm.Create( Application );
  // create setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  Form.CMOFPDevProfile := APDevProfile; // link form variable to profile
  Form.Caption := APDevProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := PProfile;
  Form.ShowModal(); // Show a setup form

  N_Dump1Str( 'PaloDEx >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj14.CDSSettingsDlg

//************************************ TN_CMCDServObj17.CDSGetGroupDevNames ***
// Get PaloDex Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj18.CDSGetGroupDevNames( AGroupDevNames: TStrings )
                                                                      : Integer;
begin
  AGroupDevNames.Add( N_CMECD_InstrumentariumDental );
  AGroupDevNames.Add( N_CMECD_SOREDEX );
  AGroupDevNames.Add( N_CMECD_KaVo );

  Result := AGroupDevNames.Count;
end; // function TN_CMCDServObj17.CDSGetGroupDevNames


//**************************************** N_CMCDServObj18.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj18.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                              var ASlidesArray: TN_UDCMSArray );
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'PaloDEx >> CDSCaptureImages begin' );

  N_ProductName := APDevProfile^.CMDPProductName;
  N_GroupName   := APDevProfile^.CMDPGroupName;

  if CDSInitAll( N_GroupName, N_ProductName ) > 0 then // no device driver installed
    Exit;

  SetLength( ASlidesArray, 0 );
  N_CMCaptDev18Form          := TN_CMCaptDev18Form.Create(application);
  N_CMCaptDev18Form.CMOFThisForm := N_CMCaptDev18Form;

  with N_CMCaptDev18Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'PaloDEx >> CDSCaptureImages before ShowModal' );

    CMOFDeviceIndex := CDSDeviceNum;

    ShowModal();

    CDSFreeAll();
    N_Dump1Str( 'PaloDEx >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do

  N_Dump1Str( 'PaloDEx >> CDSCaptureImages end' );
end; // procedure N_CMCDServObj18.CDSCaptureImages

// destructor N_CMCDServObj18.Destroy
//
destructor TN_CMCDServObj18.Destroy();
begin
  //CDSFreeAll();
end; // destructor N_CMCDServObj18.Destroy

//******************************** TN_CMCDServObj18.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj18.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin

  if AProductName = N_CMECD_InstrumentariumDental then
    Result := 27
  else if AProductName = N_CMECD_SOREDEX then
    Result := 43
  else if AProductName = N_CMECD_KaVo then
    Result := 43;

end; // function TN_CMCDServObj18.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj18.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj18.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin

  if AProductName = N_CMECD_InstrumentariumDental then
    Result := 'DX'
  else if AProductName = N_CMECD_SOREDEX then
    Result := 'DX'
  else if AProductName = N_CMECD_KaVo then
    Result := 'DX';

end; // function TN_CMCDServObj18.CDSGetDefaultDevDCMMod

Initialization

// Create and Register Service Object
N_CMCDServObj18 := TN_CMCDServObj18.Create( N_CMECD_PaloDEx_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj18 ) do
begin
  CDSCaption := 'PaloDEx';
  IsGroup := True;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj18 ) do

end.
