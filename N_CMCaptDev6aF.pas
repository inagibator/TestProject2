unit N_CMCaptDev6aF;
// Duerr settings dialog
// 2014.01.04 Start changes history
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0;

type TN_CMCaptDev6aForm = class( TN_BaseForm )
  cbDeviceMode:  TComboBox;
  cbCloseonexit: TCheckBox; // Close Vista Easy on exit from Mida Suite

  bnCancel: TButton;   // Cancel button
  bnOK:     TButton;
  Label1:   TLabel;

  cbAutoclosePrescan:    TCheckBox;
  cbActivateView:        TCheckBox;
  cbDonotDisplayPatinfo: TCheckBox; // Do not display patient details on a scanner

  procedure bnOKClick ( Sender: TObject );

  public
    CMOFPDevProfile: TK_PCMDeviceProfile;
end;

implementation
{$R *.dfm}

//******************************************** TN_CMCaptDev6aForm.bnOKClick ***
// Button "OK" click event handler
//
//     Parameters
//  Sender - Sender object
//
procedure TN_CMCaptDev6aForm.bnOKClick( Sender: TObject );
begin
  // set profile parameter for Duerr  device
  // 1st symbol - checkbox "cbCloseonexit" state
  // 2nd symbol - checkbox "cbAutoclosePrescan" state
  // 3rd symbol - checkbox "cbActivateView" state
  // 4th symbol - checkbox "cbDonotDisplayPatinfo" state
  // the rest   - combobox cbDeviceMode state
  // for example "10015"
  CMOFPDevProfile.CMDPStrPar1 := N_CMV_CheckBoxToStr( cbCloseonexit ) +
                                 N_CMV_CheckBoxToStr( cbAutoclosePrescan ) +
                                 N_CMV_CheckBoxToStr( cbActivateView ) +
                                 N_CMV_CheckBoxToStr( cbDonotDisplayPatinfo ) +
                                 N_CMV_ComboBoxToStr( cbDeviceMode );

end; // procedure TN_CMCaptDev6aForm.bnOKClick


end.
