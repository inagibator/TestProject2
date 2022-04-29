unit N_CMCaptDev9;
// Kodak device

// 2014.03.20 substituted 'K_CMShowMessageDlg' by 'ShowCriticalError' calls by Valery Ovechkin
// 2014.03.20 Fixed external process call ( line 307 ) by Valery Ovechkin
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2015.03.18 CreateSlideFromFile call was modified by Nikita
// 2015.05.14 Change parameters K_CMSlideCreateFromDeviceDIBObj by Alex Kovalev
// 2016.12.12 CreateSlideFromFile call was modified by Kovalev
// 2018.11.07 CDSGetDefaultDevIconInd function added
// 2021.17.08 Kodak 2 released, x64 modifications

interface

uses
  Classes, StdCtrls, Windows, SysUtils, ExtCtrls, Messages,
  Variants, Graphics, Controls, Forms, Dialogs,
  K_CM0, K_CMCaptDevReg,
  N_CM1, K_Types;

type TN_CMCDServObj9 = class ( TK_CMCDServObj )

  CurrentResolution:    String;
  PathDriver:           String;
  PathImages:           String;
  PathXML:              String;
  PSlidesArrayForTimer: TN_UDCMSArray;
  PDevProfile:          TK_PCMDeviceProfile;

  constructor Create              ( const ACDSName: string );
  destructor  Destroy             (); override;

  procedure CreateXML             ();
  function  ConvertGender         ( value: String ): String;
  function  ConvertDOB            ( value: String ): String;
  function  CreateSlideFromFile   ( const APathName, AFileName: String; AScanLevel : Integer ): TK_ScanTreeResult;
  function  CDSGetGroupDevNames   ( AGroupDevNames: TStrings ): Integer; override;
  procedure CDSStartCaptureImages ( APDevProfile: TK_PCMDeviceProfile ); override;
  procedure KodakOnTimer          ( ASender: TObject );
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCDServObj9 = class( TK_CMCDServObj )

var
  KodakServObj:          TK_CMCDServObj;  // ServObj for Kodak
  KodakRegisteredDevice: TN_CMCDServObj9; // Kodak registered device
  KodakTimer:            TTimer;          // Kodak Timer

implementation

uses
  N_Gra2, N_Lib0, N_Lib1, N_Gra0, N_Gra1, N_Gra6, K_CLib0, N_Types,
  N_CMCaptDev0, N_CMMain5F;

//************************************************** TN_CMCDServObj9.Create ***
// Create Capture Kodak Device Service Object
//
//     Parameters
// ACDSName - Capture Kodak Device Service Object Name
//
// Capture Device Service Object Name is stored in CMS Data Base in Device profile
//
constructor TN_CMCDServObj9.Create( const ACDSName: string );
begin
  inherited;
  CurrentResolution := ''; // Default value for Resolution
  PSlidesArrayForTimer := nil;
end; // constructor TN_CMCDServObj9.Create

//************************************************* TN_CMCDServObj6.Destroy ***
// Destroy Capture Kodak Device Service Object
//
destructor TN_CMCDServObj9.Destroy();
begin
  inherited;

end; // destructor TN_CMCDServObj9.Destroy

//*********************************************** TN_CMCDServObj9.CreateXML ***
// Create XML file for Kodak
//
procedure TN_CMCDServObj9.CreateXML ();
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
end; // procedure TN_CMCDServObj9.CreateXML

//*********************************************** TN_CMCDServObj9.CreateXML ***
// Convert gender to "M" or "F"
//
//     Parameters
// value - string like "Male" of "Female"
// Result - "M" or "F"
//
function  TN_CMCDServObj9.ConvertGender ( value: String ): String;
begin
  Result := '';

  if ( value <> '' ) then
    Result := value[1];
end; // function TN_CMCDServObj9.ConvertGender

//********************************************** TN_CMCDServObj9.ConvertDOB ***
// Convert Day of Birth to format "ddmmyyyy"
//
//     Parameters
// value  - string in format "dd.mm.yyyy"
// Result - Day of Birth in format "ddmmyyyy"
//
function  TN_CMCDServObj9.ConvertDOB ( value: String ): String;
begin
  Result := '';

  if ( value <> '' ) then
    Result := Copy( value, 1, 2 ) + Copy( value, 4, 2 ) + Copy( value, 7, 4 );
end; // function TN_CMCDServObj9.ConvertDOB

//************************************* TN_CMCDServObj9.CDSGetGroupDevNames ***
// Get Kodak Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj9.CDSGetGroupDevNames( AGroupDevNames: TStrings ): integer;
begin
  Result := 1; // return device count
  AGroupDevNames.Add( 'CS7600' );
end; // function TN_CMCDServObj9.CDSGetGroupDevNames

//************************************* TN_CMCDServObj9.CreateSlideFromFile ***
// Create slide from image file
//
//    Parameters
// APathName - path to file
// AFileName - file name
// Result    - K_tucOK if success, else K_tucSkipSubTree
//
function TN_CMCDServObj9.CreateSlideFromFile( const APathName, AFileName: String; AScanLevel : Integer ): TK_ScanTreeResult;
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
end; // procedure TN_CMCDServObj9.CreateSlideFromFile

procedure TN_CMCDServObj9.KodakOnTimer( ASender: TObject );
begin
  KodakTimer.Enabled := False;

  if not N_CMV_ProcessExists( PathDriver ) then
  begin

    K_ScanFilesTree        ( PathImages + '\',
                             KodakRegisteredDevice.CreateSlideFromFile,
                             '*.jpg' );

    K_ScanFilesTree        ( PathImages + '\',
                             KodakRegisteredDevice.CreateSlideFromFile,
                             '*.jpeg' );

    K_DeleteFolderFiles    ( PathImages + '\' );
    K_CMSlidesSaveScanned3 ( PDevProfile, PSlidesArrayForTimer );

    Exit;
  end; // if not N_CMV_ProcessExists( PathDriver ) then

  KodakTimer.Enabled := True;
end;

//**************************************** TN_CMCDServObj9.CDSCaptureImages ***
// Capture Images by Duerr and fill ASlidesArray by them
//
//     Parameters
// APDevProfile - pointer to device profile record
//
// Is called from CMResForm.NewOtherOnExecuteHandler
//    CDServObj.CDSCaptureImages( PCMDeviceProfile, CaptSlidesArray );
//
procedure TN_CMCDServObj9.CDSStartCaptureImages( APDevProfile: TK_PCMDeviceProfile );
begin
  PDevProfile := APDevProfile;
  SetLength( PSlidesArrayForTimer, 0 ); // Initialize ASlidesArray

  PathXML := N_CMV_GetWrkDir() + 'Dev_Kodak.xml';

  PathDriver := N_CMV_GetRegistryKey( HKEY_LOCAL_MACHINE,
                                'SOFTWARE\CSH\Stella',
                                'Path' ) +
                                'bin\Stella.exe';

  if PathDriver = 'bin\Stella.exe' then // WOW64
    PathDriver := N_CMV_GetRegistryKey( HKEY_LOCAL_MACHINE,
                                'SOFTWARE\WOW6432Node\CSH\Stella',
                                'Path' ) +
                                'Bin\Stella.exe';

  PathImages := N_CMV_GetRegistryKey( HKEY_LOCAL_MACHINE,
                                'SOFTWARE\CSH\Stella',
                                'ImagesPath' );

  if PathImages = '' then
    PathImages := N_CMV_GetRegistryKey( HKEY_LOCAL_MACHINE,
                                'SOFTWARE\WOW6432Node\CSH\Stella',
                                'ImagesPath' );


  CreateXML(); // Create XML file with settings for Kodak

  N_Dump1Str( 'Kodak Driver Path >> ' + PathDriver );
  N_Dump1Str( 'Kodak Driver Parameter >> ' + PathXML );
  N_Dump1Str( 'Kodak Images Path >> ' + PathImages );

  if not FileExists( PathXML ) then // if XML file not exists
  begin
    K_CMSlidesSaveScanned3( APDevProfile, PSlidesArrayForTimer );
    N_CMV_ShowCriticalError( 'Kodak', 'XML file not exists: "' + PathXML + '"' );
    Exit;
  end; // if not FileExists( PathXML ) then // if XML file not exists

  // if Kodak process does not exists in memory
  if not N_CMV_CreateProcess( '"' + PathDriver + '" "' + PathXML + '"' ) then
  begin
    K_CMSlidesSaveScanned3( APDevProfile, PSlidesArrayForTimer );
    N_CMV_ShowCriticalError( 'Kodak', 'can not start process "' + PathDriver + '"' );
    Exit;
  end; // if not N_CMV_CreateProcess( '"' + PathDriver + '" "' + PathXML + '"' ) then

  KodakTimer.Enabled  := True;
end; // procedure TN_CMCDServObj9.CDSCaptureImages

//********************************* TN_CMCDServObj9.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj9.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 34;
end; // function TN_CMCDServObj9.CDSGetDefaultDevIconInd

//********************************** TN_CMCDServObj9.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj9.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
    Result := 'CR';
end; // function TN_CMCDServObj9.CDSGetDefaultDevDCMMod


Initialization
  // Create and Register Kodak Service Object
  KodakRegisteredDevice := TN_CMCDServObj9.Create( N_CMECD_Kodak_Name );
  KodakServObj          := K_CMCDRegisterDeviceObj( KodakRegisteredDevice );
  KodakServObj.IsGroup         := True;
  KodakServObj.NotModalCapture := True;
  KodakServObj.ShowSettingsDlg := True;
  KodakServObj.CDSCaption      := 'Kodak';
  KodakTimer          := TTimer.Create( Application );
  KodakTimer.Enabled  := False;
  KodakTimer.Interval := 500;
  KodakTimer.OnTimer  := KodakRegisteredDevice.KodakOnTimer;
end.
