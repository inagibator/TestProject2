unit N_CMCaptDev5dF;
// Temporary form to show ambigouos Planmeca devices
// 2014.01.04 Start changes history
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0;

type TV_Dev = record
  DevIndex, DevType: Integer;
  DevName: String;
end;

type TN_CMCaptDev5dForm = class( TN_BaseForm )
  bnCancel: TButton;
  bnOK: TButton;
  lbDevices: TListBox;
  lbNote: TLabel;
  procedure fillLisbBox ( devType: Integer );
  procedure selectDevice();
  procedure bnOKClick   ( Sender: TObject );

  public
    CMOFPDevProfile: TK_PCMDeviceProfile;
    devType: Integer;
    devList: array of TV_DEV;
end;


implementation
{$R *.dfm}

//****************************************** TN_CMCaptDev5dForm.fillLisbBox ***
// Fill listbox with ambiguous Planmeca devices for current type
//
//    Parameters
// devType - device type
//
procedure TN_CMCaptDev5dForm.fillLisbBox( devType: Integer );
var
  i, arrLength: Integer;
begin
  arrLength := Length( devList );
  lbDevices.Clear;

  for i := 0 to arrLength - 1 do
  begin
    lbDevices.Items.Add( devList[i].DevName );
  end;

  lbDevices.ItemIndex := 0;
end; // procedure TN_CMCaptDev5dForm.fillLisbBox

//***************************************** TN_CMCaptDev5dForm.selectDevice ***
// Apply users device selection to profile
//
procedure TN_CMCaptDev5dForm.selectDevice();
var
  devNumber, paramLength: Integer;
  param, paramSettings: String;
begin
  devNumber := lbDevices.ItemIndex; // users selection
  param := CMOFPDevProfile^.CMDPStrPar1; // old profile string
  paramLength := Length( param );
  paramSettings := '000';

  if ( paramLength >= 3 ) then
    paramSettings := Copy( param, 1, 3 );

  param := paramSettings; // new profile string

  if ( devNumber >= 0 ) then // if device selected
    param := param + IntToStr( devNumber );

  CMOFPDevProfile^.CMDPStrPar1 := param; // apply selection to profile
end; // procedure TN_CMCaptDev5dForm.selectDevice

//******************************************** TN_CMCaptDev5dForm.bnOKClick ***
// Button "OK" click event handler
//
//    Parameters
// Sender - sender object
//
procedure TN_CMCaptDev5dForm.bnOKClick( Sender: TObject );
begin
  selectDevice; // apply device selection
end; // procedure TN_CMCaptDev5dForm.bnOKClick

end.
