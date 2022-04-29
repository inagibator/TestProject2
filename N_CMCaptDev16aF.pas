unit N_CMCaptDev16aF;
// CSH ( Kodak ) settings dialog
// 2014.05.16 Created by Valery Ovechkin
// 2014.08.22 Fixes and Standartization by Valery Ovechkin

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, K_CLib0,
  N_Types, N_Lib1, N_BaseF, N_CMCaptDev16SF, N_CMCaptDev0;

type TN_CMCaptDev16aForm = class( TN_BaseForm )
    bnCancel: TButton;   // Cancel button
    bnOK:     TButton;

    lbSensor:         TLabel;
    cbRaw: TCheckBox;
    procedure bnOKClick ( Sender: TObject );

  public
    CMOFPDevProfile: TK_PCMDeviceProfile; // Pointer to Profile
end;


implementation

{$R *.dfm}

//******************************************** TN_CMCaptDev16aForm.bnOKClick ***
// Button "OK" click event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev16aForm.bnOKClick( Sender: TObject );
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
end; // procedure TN_CMCaptDev16aForm.bnOKClick

end.
