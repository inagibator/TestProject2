unit N_CMCaptDev33aF;
// CSH 2 ( Kodak ) settings dialog
// 2014.05.16 Created by Valery Ovechkin
// 2014.08.22 Fixes and Standartization by Valery Ovechkin

interface

{$IFNDEF VER150} //***** not Delphi 7

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, K_CLib0,
  N_Types, N_Lib1, N_BaseF, N_CMCaptDev33SF, N_CMCaptDev0;

type TN_CMCaptDev33aForm = class( TN_BaseForm )
    bnCancel: TButton;   // Cancel button
    bnOK:     TButton;

    lbSensor:         TLabel;
    cbRaw: TCheckBox;
    bnConfigure: TButton;
    procedure bnOKClick ( Sender: TObject );
    procedure bnConfigureClick( Sender: TObject );

  public
    CMOFPDevProfile: TK_PCMDeviceProfile; // Pointer to Profile
end;


implementation

uses
  N_CMCaptDev33S, N_Lib0;

{$R *.dfm}

//************************************ TN_CMCaptDev33aForm.bnConfigureClick ***
// Button "OK" click event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev33aForm.bnConfigureClick( Sender: TObject );
var
  XMLDoc: TN_CMV_XML;
  XMLRequestStr, XMLResponseStr: AnsiString;
  PatId, PatName, PatSurname, PatDOB, PatGender: String;
begin
  inherited;
  // Get Patients info from CMS Database
  PatId      := IntToStr(K_CMEDAccess.CurPatID);//K_CMGetPatientDetails( -1, '(#PatientCardNumber#)' );
  PatName    := K_CMGetPatientDetails( -1, '(#PatientFirstName#)' );
  PatSurname := K_CMGetPatientDetails( -1, '(#PatientSurname#)' );
  PatDOB     := K_CMGetPatientDetails( -1, '(#PatientDOB#)' );
  PatGender  := K_CMGetPatientDetails( -1, '(#PatientGender#)' );

  with N_CMCDServObj33 do
  begin

  FillDevPos ( CMOFPDevProfile^.CMDPProductName, CurrentDevice, CurrentLine );

  // ***** set async information command
  XMLHandleRequest := AcquisitionXMLCreate_ext();

  if ( nil = XMLHandleRequest ) then // Empty XML request
  begin
    N_CMV_ShowCriticalError( 'CSH', 'AcquisitionXMLCreate = nil' );
    Exit;
  end; // if ( nil = XMLHandleRequest ) then // Empty XML request

  XMLRequestStr := N_StringToAnsi(
  '<?xml version="1.0" encoding="utf-8" ?>' +
  '<trophy type="acquisition">' +
  '<acquisition command="configure" version="1.0">' +
  '<devices>' +
  '<device id="' + N_CMCDServObj33.Devices[N_CMCDServObj33.CurrentDevice].id + '">' +
  '<lines>' +
  '<line id="' + N_CMCDServObj33.Devices[N_CMCDServObj33.CurrentDevice].Lines[N_CMCDServObj33.CurrentLine].id + '">' +
  '</line>' +
  '</lines>' +
  '</device>' +
  '</devices>' +
  '</acquisition>' +
  '</trophy>' );

  AcquisitionXMLSet_ext( XMLHandleRequest, @XMLRequestStr[1] );
  XMLHandleResponse := Acquisition_ext( XMLHandleRequest );

  XMLResponseStr := AcquisitionXMLGet_ext( XMLHandleResponse );
  XMLDoc := N_CMV_XMLDocLoad( N_AnsiToString( XMLResponseStr ), False );

  N_Dump1Str(N_AnsiToString(XMLResponseStr));
end;
end; // procedure TN_CMCaptDev33aForm.bnConfigureClick( Sender: TObject );

//******************************************** TN_CMCaptDev33aForm.bnOKClick ***
// Button "OK" click event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev33aForm.bnOKClick( Sender: TObject );
var
  sOld, sNew: String;
  sz: Integer;
begin
  // make profile parameter by form controls states
  sOld := CMOFPDevProfile.CMDPStrPar1;
  sz := Length( sOld );
  CMOFPDevProfile.CMDPStrPar1 := N_CMV_CheckBoxToStr( cbRaw );
  sNew := CMOFPDevProfile.CMDPStrPar1;

  if ( 1 < sz ) then
    sNew := sNew + Copy( sOld, 2, sz - 1 );

  CMOFPDevProfile.CMDPStrPar1 := sNew;
end; // procedure TN_CMCaptDev33aForm.bnOKClick

{$ELSE} //************** no code in Delphi 7
implementation
{$ENDIF VER150} //****** no code in Delphi 7

end.
