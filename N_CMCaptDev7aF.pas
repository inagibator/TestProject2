unit N_CMCaptDev7aF;
// E2V (Mediaray) settings dialog
// 2014.01.04 Start changes history
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, K_CLib0,
  N_Types, N_Lib1, N_BaseF, N_CMCaptDev7SF, N_CMCaptDev0;

type TN_CMCaptDev7aForm = class( TN_BaseForm )
    bnCancel: TButton;   // Cancel button
    bnOK:     TButton;
    cbVirtual: TCheckBox;
    cbFilter:  TCheckBox;
    cbBinning: TCheckBox;
    lbTime: TLabel;
    eTime:  TEdit;
    lbGain: TLabel;
    cbGain: TComboBox;

    lbSensor:         TLabel;
    lbModelName:      TLabel;
    lbSensType:       TLabel;
    lbSerialNumber:   TLabel;
    lbUSBSpeed:       TLabel;
    lbModelNameValue: TLabel;
    lbSensTypeValue:  TLabel;

    lbSerialNumberValue: TLabel;
    lbUSBSpeedValue:     TLabel;
    lbTrigger:           TLabel;

    cbTrigger: TComboBox;
    bnLoadCorrectionFile: TButton;
    OpenDialogForCorrection: TOpenDialog;
    procedure bnOKClick ( Sender: TObject );
    procedure bnLoadCorrectionFileClick(Sender: TObject);

  public
    CMOFPDevProfile: TK_PCMDeviceProfile; // Pointer to Profile
end;


implementation

{$R *.dfm}

//************************* TN_CMCaptDev11aForm.bnLoadCalibrationFileClick ***
// Button "Install correction files" click event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev7aForm.bnLoadCorrectionFileClick(Sender: TObject);
var
  WrkDir, FileNameOrig, FileNameDest: String;
begin

  if ( lbSerialNumberValue.Caption = '' ) then
    Exit;

  bnLoadCorrectionFile.Enabled := False;
  WrkDir := N_CMV_GetWrkDir();

  if OpenDialogForCorrection.Execute() then
  begin
    FileNameOrig := OpenDialogForCorrection.FileName;
    FileNameDest := WrkDir + lbSerialNumberValue.Caption + '.cal';
    N_CMV_CopyFile( FileNameOrig, FileNameDest, 'E2V >> calibration file' );
  end; // if OpenDialogForCorrection.Execute() then

  bnLoadCorrectionFile.Enabled := True;
end; // procedure TN_CMCaptDev7aForm.bnLoadCorrectionFileClick

//******************************************** TN_CMCaptDev7aForm.bnOKClick ***
// Button "OK" click event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev7aForm.bnOKClick( Sender: TObject );
begin
  // make profile parameter by form controls states
  CMOFPDevProfile.CMDPStrPar1 := N_CMV_CheckBoxToStr( cbVirtual ) +
                                 N_CMV_CheckBoxToStr( cbBinning ) +
                                 N_CMV_CheckBoxToStr( cbFilter ) +
                                 N_CMV_ComboBoxToStr( cbGain ) +
                                 N_CMV_ComboBoxToStr( cbTrigger, True ) +
                                 IntToStr( StrToIntDef( eTime.Text, 5 ) );


end; // procedure TN_CMCaptDev7aForm.bnOKClick

end.
