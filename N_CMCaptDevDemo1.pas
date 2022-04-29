unit N_CMCaptDevDemo1;
// TN_CMCDServObjDemo (Demo1 Device with Capturing Form) implementation

interface
uses Windows, Classes, Forms, Graphics, StdCtrls, ExtCtrls,
     K_CM0, K_CMCaptDevReg,
     N_Types;


type TN_CMCDServObjDemo = class( TK_CMCDServObj )
  CDSDevInd:    integer; // local Device index (synonim of CMDPProductName)
  CDSDllHandle: THandle; // DLL Windows Handle
  CDSErrorStr:   string; // Error message
  CDSErrorInt:  integer; // Error code

  PProfile: TK_PCMDeviceProfile; // Pointer to Device Profile


  // Show Device status on form
//  procedure show_device_status( frm : TN_CMCaptDevDemo1Form; comment : AnsiString );

  function  CDSGetGroupDevNames     ( AGroupDevNames: TStrings ): Integer; override;
  function  CDSGetDevProfileCaption ( ADevName : string ): string; override;
  function  CDSGetDevCaption        ( ADevName : string ): string; override;
  procedure CDSCaptureImages        ( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg          ( APDevProfile: TK_PCMDeviceProfile ); override;
end; // end of type TN_CMCDServObjDemo = class( TK_CMCDServObj )

var
  N_CMCDServObjDemo: TN_CMCDServObjDemo;

implementation

uses SysUtils, Dialogs,
  K_CLib0,
  N_Gra2, N_Lib1, N_CM1, N_Lib0, N_CMCaptDevDemo1F;

//**************************************** TN_CMCDServObjDemo **********

{
// procedure TN_CMCDServObjDemo.show_device_status
// Show Device status on form
//
//    Parameters
// frm - E2V Capture form pointer
// comment - comment, e.g step name, function name etc.
procedure TN_CMCDServObjDemo.show_device_status( frm : TN_CMCaptDevDemo1Form;
                                              comment : AnsiString );
begin
var
  error_text : String;
  error_text_array : array[0..89] of ansichar;
  error_code : Integer;
  label_color : TColor;
  label_text : String;
  dump_text  : String;
begin
  // Initialize variables
  error_text := '';
  label_color := $000000;
  label_text  := 'Unknown error';
  dump_text   := '';

  if ( device_status = eDeviceError ) then  // any E2V Error
  begin
    // Disable controls
    frm.cbAutoTake.Enabled := False;
    frm.bnCapture.Enabled := False;

    error_text := 'Unknown E2V error';
    // get e2v error code
    error_code := N_CMCDServObjDemo.e2v_GetLastError();
    // if this code <> 0 and error text has obtained
    if (0 <> error_code) then
      if (1 = N_CMCDServObjDemo.e2v_GetLastErrorText( error_text_array, 90 )) then
        error_text := 'Error code = ' + IntToStr( error_code ) +
        ' "' + String( strpas( error_text_array ) ) + '"';

      label_text := error_text;  // text for E2V form indicator
      // text for dump
      dump_text := 'ERROR : code = ' + IntToStr( error_code ) +
                   '; text = ' + error_text;

  end
  else if ( device_status = eDeviceNotFound ) then  // not any device found
  begin
    label_color := $0000D0;
    label_text := 'Device not found or disconnected';
    dump_text  := 'Device not found';
  end
  else if ( device_status = eDeviceFound ) then     // found at least 1 E2V device
  begin
    label_color := $0000D0;
    label_text := 'Device found...';
    dump_text  := 'Device found';
  end
  else if ( device_status = eDeviceOpened ) then    // device opened
  begin
    label_color := $0090FF;
    label_text := 'Please press button "Capture"';
    dump_text  := 'Device opened';
  end
  else if ( device_status = eDeviceArmed ) then     // device armed
  begin
    label_color := $009000;
    label_text := 'Ready to take X-Ray';
    dump_text  := 'Device armed';
  end
  else if ( device_status = eDeviceTakesXray ) then  // device takes X-Ray
  begin
    label_color := $900000;
    label_text := 'Processing...';
    dump_text  := 'Device process XRay';
  end;

  N_Dump1Str( 'E2V >> ' + dump_text + '; step = ' + String(comment) );

  // Set indicator Shape and Lable
  frm.StatusShape.Brush.Color := label_color;
  frm.StatusLabel.Font.Color  := label_color;
  frm.StatusLabel.Caption     := label_text;

  application.ProcessMessages;
end; // procedure TN_CMCDServObjDemo.show_device_status
}

//********************************** TN_CMCDServObjDemo.CDSGetGroupDevNames ***
// Get E2V Device Name
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObjDemo.CDSGetGroupDevNames( AGroupDevNames: TStrings ) : Integer;
begin
  AGroupDevNames.Add( 'DummyName' );
  Result := AGroupDevNames.Count;
end; // procedure TN_CMCDServObjDemo.CDSGetGroupDevNames

//************************************* TN_CMCDServObjDemo.CDSGetDevCaption ***
// Get Capture Device Caption by Name
//
//     Parameters
// ADevName - given Device Name
// Result   - Returns Device Caption
//
function  TN_CMCDServObjDemo.CDSGetDevCaption( ADevName: string ): string;
begin
  Result := 'Demo Sensor'; // ADevName is not used because group has only one device
end; // procedure TN_CMCDServObjDemo.CDSGetDevCaption

//****************************** TN_CMCDServObjDemo.CDSGetDevProfileCaption ***
// Get Capture Device Profile Caption by Name
//
//     Parameters
// ADevName - given Device Name
// Result   - Returns Device Caption
//
function  TN_CMCDServObjDemo.CDSGetDevProfileCaption( ADevName: string ) : string;
begin
  Result := 'Demo Sensor'; // ADevName is not used because group has only one device
end; // procedure TN_CMCDServObjDemo.CDSGetDevProfileCaption

//*************************** procedure TN_CMCDServObjDemo.CDSCaptureImages ***
// Capture Images by Demo Device and fill ASlidesArray by them
//
//     Parameters
// APDevProfile - pointer to device profile record
// ASlidesArray - captured Slides array
//
// Is called from CMResForm.NewOtherOnExecuteHandler
//    CDServObj.CDSCaptureImages( PCMDeviceProfile, CaptSlidesArray );
//
procedure TN_CMCDServObjDemo.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                               var ASlidesArray : TN_UDCMSArray );
var
  CMCaptDevDemo1Form: TN_CMCaptDevDemo1Form;
begin
  PProfile := APDevProfile;

  SetLength( ASlidesArray, 0 );
  CMCaptDevDemo1Form := TN_CMCaptDevDemo1Form.Create( Application );

  with CMCaptDevDemo1Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    CMOFPProfile    := TK_PCMOtherProfile( APDevProfile ); // set CMCaptDevDemo1Form.CMOFPProfile field
    CMOFDeviceIndex := CDSDevInd;
    Caption         := CMDPCaption;
    CMOFPNewSlides  := @ASlidesArray; // for using in CMCaptDevDemo1Form methods
    ShowModal();
  end; // with CMCaptDevDemo1Form, APDevProfile^ do

end; // procedure TN_CMCDServObjDemo.CDSCaptureImages

// procedure TN_CMCDServObjDemo.CDSSettingsDlg
procedure TN_CMCDServObjDemo.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
begin

end; // procedure TN_CMCDServObjDemo.CDSSettingsDlg


Initialization

  // Create and Register Demo Device Service Object
  N_CMCDServObjDemo := TN_CMCDServObjDemo.Create( N_CMECD_Demo1Dev_Name );
  N_CMCDServObjDemo.CDSDllHandle := 0;
  N_CMCDServObjDemo.PProfile := nil;
  with K_CMCDRegisterDeviceObj( N_CMCDServObjDemo ) do
  begin
    CDSCaption := 'Demo1';
    IsGroup := True;
    ShowSettingsDlg := True;
  end;
end.
