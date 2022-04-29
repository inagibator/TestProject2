unit N_CMCaptDev5aF;
// Planmeca settings dialog 
// 2014.01.04 Start changes history
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0;

type TN_CMCaptDev5aForm = class( TN_BaseForm )
  // checkboxes
  cbUseDidapiImagePreProcessing: TCheckBox; // Close Vista Easy on exit from Mida Suite
  cbUtilizeDidapiUi:             TCheckBox;
  cbDisableImagePreview:         TCheckBox;

  // buttons
  bnCancel: TButton;   // Cancel button
  bnOK:     TButton;

  // events handlers
  procedure bnOKClick              ( Sender: TObject );
  procedure cbUtilizeDidapiUiClick ( Sender: TObject );
    procedure FormShow(Sender: TObject);

  public
    CMOFPDevProfile: TK_PCMDeviceProfile;
end;


implementation
{$R *.dfm}

//******************************************** TN_CMCaptDev5aForm.bnOKClick ***
// Button "OK" click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev5aForm.bnOKClick( Sender: TObject );
begin
  // set profile parameter for Duerr  device
  // 1st symbol - checkbox "cbUseDidapiImagePreProcessing" state
  // 2nd symbol - checkbox "cbUtilizeDidapiUi" state
  // 3rd symbol - checkbox "cbDisableImagePreview" state
  // for example "100"
  CMOFPDevProfile.CMDPStrPar1 := N_CMV_CheckBoxToStr( cbUseDidapiImagePreProcessing ) +
                                 N_CMV_CheckBoxToStr( cbUtilizeDidapiUi ) +
                                 N_CMV_CheckBoxToStr( cbDisableImagePreview );

end; // procedure TN_CMCaptDev5aForm.bnOKClick

//******************************* TN_CMCaptDev5aForm.cbUtilizeDidapiUiClick ***
// CheckBox "Utilize DIDAPIUI Interface" click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev5aForm.cbUtilizeDidapiUiClick( Sender: TObject );
var
  DidapiUiChecked: Boolean;
begin
  inherited;
  DidapiUiChecked := cbUtilizeDidapiUi.Checked;
  // gray out checkboxes depending on DidapiUi using
  cbUseDidapiImagePreProcessing.Enabled := not DidapiUiChecked;
  cbDisableImagePreview.Enabled := DidapiUiChecked;
end;

//********************************************* TN_CMCaptDev5aForm.FormShow ***
// Form Show
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev5aForm.FormShow(Sender: TObject);
begin
  inherited;
  if CMOFPDevProfile.CMDPProductName = '3' then // intraoral
  begin
    cbUtilizeDidapiUI.Enabled := True;
    if CMOFPDevProfile.CMDPStrPar1 = '' then
      cbUtilizeDidapiUI.Checked := False;
  end;
end;

// procedure TN_CMCaptDev5aForm.cbUtilizeDidapiUiClick

end.
