unit N_CMCaptDev35;
// Kodak 2 device

// 19.08.21 - changed from Kodak device, capture form added
// 03.11.21 - resolution added

interface

{$IFNDEF VER150} //***** not Delphi 7

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev35F,
  N_CML2F;

type TN_CMCDServObj35 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr:   string;  // Error message
  CDSErrorInt:   integer; // Error code

  CurrentResolution:    String;
  PathDriver:           String;
  PathImages:           String;
  PathXML:              String;
  //PSlidesArrayForTimer: TN_UDCMSArray;
  PDevProfile:          TK_PCMDeviceProfile;

  constructor Create              ( const ACDSName: string );
  destructor  Destroy             (); override;

  procedure CreateXML             ();
  function  ConvertGender         ( value: String ): String;
  function  ConvertDOB            ( value: String ): String;
  function  CDSGetGroupDevNames   ( AGroupDevNames: TStrings ): Integer; override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;

  function CDSInitAll(AGroupName, AProductName: string ): Integer;
  function CDSFreeAll(): Integer;

  function CDSOpenDev3DViewer( const A3DPathToObj : string ) : Integer; override;

  procedure SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
  procedure CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg      ( APDevProfile: TK_PCMDeviceProfile ); override;
end; // end of type TN_CMCD ServObj32 = class( TK_CMCDServObj )

var
  N_CMCDServObj35: TN_CMCDServObj35;
  CMCaptDev35Form: TN_CMCaptDev35Form;

  KodakServObj:          TK_CMCDServObj;  // ServObj for Kodak
  //N_CMCDServObj35: TN_CMCDServObj35; // Kodak registered device
  KodakTimer:            TTimer;          // Kodak Timer

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0, IniFiles, ShellAPI, IdHTTP, xmldom,
  XMLIntf, msxml, msxmldom, XMLDoc, OleCtrls, SHDocVw, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, MSHTML, TlHelp32;

//************************************************* TN_CMCDServObj35 **********
//************************************************* TN_CMCDServObj35.Create ***
// Create Capture Kodak Device Service Object
//
//     Parameters
// ACDSName - Capture Kodak Device Service Object Name
//
// Capture Device Service Object Name is stored in CMS Data Base in Device profile
//
constructor TN_CMCDServObj35.Create( const ACDSName: string );
begin
  inherited;
  //CurrentResolution := ''; // Default value for Resolution
  //PSlidesArrayForTimer := nil;
end; // constructor TN_CMCDServObj35.Create

//*********************************************** TN_CMCDServObj35.CreateXML ***
// Create XML file for Kodak
//
procedure TN_CMCDServObj35.CreateXML ();
var
  FileHandle: TextFile;
  Str:        String;
  WideStr:    WideString;
  Dest:       AnsiString;
  StrLength, DestSize: Integer;
begin
  Str := '<?xml version="1.0" encoding="utf-8" ?>' + #13#10 +
         '<InputData>' + #13#10 +
         '<Interface_Version>1</Interface_Version>' + #13#10 +
         '<Patient_ID>' +
         K_CMGetPatientDetails( -1, '(#PatientCardNumber#)' ) +
         '</Patient_ID>' + #13#10 +
         '<Patient_FirstName>' +
         K_CMGetPatientDetails( -1, '(#PatientFirstName#)' ) +
         '</Patient_FirstName>' + #13#10 +
         '<Patient_LastName>' +
         K_CMGetPatientDetails( -1, '(#PatientSurname#)' ) +
         '</Patient_LastName>' + #13#10 +
         '<Patient_DOB>' +
         ConvertDOB ( K_CMGetPatientDetails( -1, '(#PatientDOB#)' ) ) +
         '</Patient_DOB>' + #13#10 +
         '<Patient_Gender>' +
         ConvertGender ( K_CMGetPatientDetails( -1, '(#PatientGender#)' ) ) +
         '</Patient_Gender>' + #13#10 +
         '<Study_UID></Study_UID>' + #13#10 +
         '<Accession_Number></Accession_Number>' + #13#10 +
         '<Output_Destination>' + PathImages +
         '</Output_Destination>' + #13#10 +
         '<Output_Type>DUAL</Output_Type>' + #13#10 +
         '<Acquisition_Mode>AG</Acquisition_Mode>' + #13#10 +
         '<Template_Path></Template_Path>' + #13#10 +
         '<UI_Language></UI_Language>' + #13#10 +
         '<Calling_Application_Version>1.0</Calling_Application_Version>' + #13#10 +
         '<Teeth_Numbering_System>EUROPEAN</Teeth_Numbering_System>' + #13#10 +
         '</InputData>' + #13#10;

  StrLength := Length( Str );
  DestSize := StrLength * 3;
  SetLength( Dest, DestSize );

  WideStr := N_StringToWide( Str );
  StrLength := UnicodeToUtf8( @Dest[1], DestSize, @WideStr[1], StrLength );

  if ( StrLength > 0 ) then
    StrLength := StrLength - 1;

  SetLength( Dest, StrLength );

  AssignFile( FileHandle, PathXML );
  ReWrite( FileHandle );
  WriteLn( FileHandle, Dest );
  CloseFile( FileHandle );
end; // procedure TN_CMCDServObj35.CreateXML

//*********************************************** TN_CMCDServObj35.CreateXML ***
// Convert gender to "M" or "F"
//
//     Parameters
// value - string like "Male" of "Female"
// Result - "M" or "F"
//
function  TN_CMCDServObj35.ConvertGender ( value: String ): String;
begin
  Result := '';

  if ( value <> '' ) then
    Result := value[1];
end; // function TN_CMCDServObj35.ConvertGender

//********************************************* TN_CMCDServObj35.ConvertDOB ***
// Convert Day of Birth to format "ddmmyyyy"
//
//     Parameters
// value  - string in format "dd.mm.yyyy"
// Result - Day of Birth in format "ddmmyyyy"
//
function  TN_CMCDServObj35.ConvertDOB ( value: String ): String;
begin
  Result := '';

  if ( value <> '' ) then
    Result := Copy( value, 1, 2 ) + Copy( value, 4, 2 ) + Copy( value, 7, 4 );
end; // function TN_CMCDServObj9.ConvertDOB

//************************************ TN_CMCDServObj35.CDSGetGroupDevNames ***
// Get Kodak Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj35.CDSGetGroupDevNames( AGroupDevNames: TStrings ): integer;
begin
  Result := 1; // return device count
  AGroupDevNames.Add( 'CS7600' );
end; // function TN_CMCDServObj35.CDSGetGroupDevNames

//************************************* TN_CMCDServObj9.CreateSlideFromFile ***
// Create slide from image file
//
//    Parameters
// APathName - path to file
// AFileName - file name
// Result    - K_tucOK if success, else K_tucSkipSubTree
//
{function TN_CMCDServObj9.CreateSlideFromFile( const APathName, AFileName: String; AScanLevel : Integer ): TK_ScanTreeResult;
var
    ResolutionInt: Integer;   // Resolution in pixel per meter
    SlideCount: Integer;   // count of slides
    dib: TN_DIBObj; // DIB Object
    FileName: String;    // Full File Path
begin
  Result := K_tucSkipSubTree;

  if ( AFileName = '' ) then   // if  AFileName  is a directory
    Exit;

  FileName := APathName + AFileName;

  if not FileExists( FileName ) then // if the file not exists
  begin
    N_CMV_ShowCriticalError( 'Kodak', 'internal error. ' +
                             'File ''' + FileName + ''' not exists' );
    Exit;
  end; // if not FileExists( FileName ) then // if the file not exists

  SlideCount := Length( PSlidesArrayForTimer ); // count of slides

  try // try to create dib object
    dib := TN_DIBObj.Create( 100, 100, pfCustom, -1, epfgray8 );

    except on ErrCreate: Exception do // if error while dib created
    begin
      N_CMV_ShowCriticalError( 'Kodak', 'internal error. ' +
                               'DIB not created: ' + ErrCreate.Message );

      try // try to free dib
        dib.Free;

        except on ErrFree: Exception do // if error while dib free
        begin
          N_CMV_ShowCriticalError( 'Kodak', 'internal error. ' +
                                   'DIB not free: ' + ErrFree.Message );
          Exit;
        end; // except on ErrFree: Exception do // if error while dib free

      end; // try // try to free dib

      Exit;
    end; // except on ErrCreate: Exception do // if error while dib created

  end; // try // try to create dib object

  dib.LoadFromFile( FileName );
  CurrentResolution := '19';
  ResolutionInt :=
  Round( 1000000 / StrToFloatDef( K_ReplaceCommaByPoint( CurrentResolution ), -1 ) );

  if ( 0 >= ResolutionInt ) then  // if resolution is not valid
    ResolutionInt := 0;           // set default resolution

  // set DIBObj resolution
  dib.DIBInfo.bmi.biXPelsPerMeter := ResolutionInt;
  dib.DIBInfo.bmi.biYPelsPerMeter := ResolutionInt;
  SetLength( PSlidesArrayForTimer, SlideCount + 1 );   // add slide
  // add image to appropriate slide
  PSlidesArrayForTimer[SlideCount] := K_CMSlideCreateFromDeviceDIBObj( dib, PDevProfile, SlideCount + 1, 0 );
//  PSlidesArrayForTimer[SlideCount].SetAutoCalibrated(); !!! is done inside  K_CMSlideCreateFromDeviceDIBObj
  Result := K_tucOK;
end; // procedure TN_CMCDServObj9.CreateSlideFromFile  }

{procedure TN_CMCDServObj9.KodakOnTimer( ASender: TObject );
begin
  KodakTimer.Enabled := False;

  if not N_CMV_ProcessExists( PathDriver ) then
  begin
 K_ScanFilesTree        ( PathImages + '\',
                             N_CMCDServObj35.CreateSlideFromFile,
                             '*.jpg' );

    K_ScanFilesTree        ( PathImages + '\',
                             N_CMCDServObj35.CreateSlideFromFile,
                             '*.jpeg' );

    K_DeleteFolderFiles    ( PathImages + '\' );
    K_CMSlidesSaveScanned3 ( PDevProfile, PSlidesArrayForTimer );

    Exit;

  end; // if not N_CMV_ProcessExists( PathDriver ) then

  KodakTimer.Enabled := True;
end;   }

//******************************** TN_CMCDServObj35.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj35.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 34;
end; // function TN_CMCDServObj35.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj35.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj35.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
    Result := 'CR';
end; // function TN_CMCDServObj35.CDSGetDefaultDevDCMMod

//************************************* TN_CMCDServObj35.CDSOpenDev3DViewer ***
// Algorithm for opening slides via natives Viewers
//
//     Parameters
// A3DPathToObj - Info saved to this slide
// Result       - return 0 if OK
//
function  TN_CMCDServObj35.CDSOpenDev3DViewer( const A3DPathToObj : string ) :
                                                                        Integer;
begin

end; // function  TN_CMCDServObj35.CDSOpenDev3DViewer

//********************************************* TN_CMCDServObj35.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj32 Group Name
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj35.CDSInitAll(AGroupName, AProductName: string )
                                                                      : Integer;
begin
  //if AProductName = N_CMECD_ClearVision then Device := 1;

  CDSErrorStr := '';
  Result := 0;
end; // procedure N_CMCDServObj32.CDSInitAll

//********************************************** TN_CMCDServObj35.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj35.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    //FreeLibrary( CDSDLLHandle );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj35.CDSFreeAll

//**************************************** N_CMCDServObj32.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj35.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Kodak 2 >> CDSCaptureImages begin' );

  SetLength(ASlidesArray, 0);
  CMCaptDev35Form          := TN_CMCaptDev35Form.Create(Application);
  CMCaptDev35Form.CMOFThisForm := CMCaptDev35Form;

  with CMCaptDev35Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'Kodak 2 >> CDSCaptureImages before ShowModal' );

    ShowModal();
    
    CDSFreeAll();
    N_Dump1Str( 'Kodak 2 >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do

  N_Dump1Str( 'Kodak 2 >> CDSCaptureImages end' );
end; // procedure N_CMCDServObj32.CDSCaptureImages

//********************************************* TN_CMCDServObj35.SendExtMsg ***
// Send message to C++ driver
//
//    Parameters
// Cmd - command for driver
// Param1 - 1st parameter
// Param2 - 2nd parameter
// Param3 - 3rd parameter
//
procedure TN_CMCDServObj35.SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
begin
  // not used
end; // procedure SendExtMsg

//***************************************** TN_CMCDServObj35.CDSSettingsDlg ***
// Show Special Seting Dialog
//
//     Parameters
// APDevProfile - Pointer to Device Profile record
//
procedure TN_CMCDServObj35.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );

begin
  N_Dump1Str( 'Trios >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj35.CDSSettingsDlg

// destructor N_CMCDServObj32.Destroy
//
destructor TN_CMCDServObj35.Destroy();
begin
  //CDSFreeAll();
end; // destructor N_CMCDServObj32.Destroy

Initialization

// Create and Register Service Object
N_CMCDServObj35 := TN_CMCDServObj35.Create( N_CMECD_Kodak2_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj35 ) do
begin
  CDSCaption := 'Kodak 2';
  IsGroup := False;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj32 ) do

{$ELSE} //************** no code in Delphi 7
implementation
{$ENDIF VER150} //****** no code in Delphi 7

end.
