unit N_CMCaptDev8aF;
// Gendex settings dialog
// 2014.01.04 Start changes history
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0,
  N_BaseF;

type TN_CMCaptDev8aForm = class( TN_BaseForm )
    bnCancel:  TButton;
    bnOK:      TButton;
    cbFilter:  TCheckBox;
    cbBinning: TCheckBox;
    lbGain:    TLabel;
    cbGain:    TComboBox;

    gbSensorInfo: TGroupBox;

    l1ModelName:    TLabel;
    l1SensorType:   TLabel;
    l1SerialNumber: TLabel;
    l1USBLinkSpeed: TLabel;
    l2ModelName:    TLabel;
    l2SensorType:   TLabel;
    l2SerialNumber: TLabel;
    l2USBLinkSpeed: TLabel;
    lTrigger:       TLabel;
    edtrigger:      TEdit;

    procedure FormShow  ( Sender: TObject );

  public
    CMOFPDevProfile: TK_PCMDeviceProfile; // Pointer to Device Profile
end; // type TN_CMCaptDev8aForm = class( TN_BaseForm )


implementation

uses
  StrUtils,
  N_Types, N_Lib1, N_Lib0, N_CMCaptDev8S;
{$R *.dfm}

//********************************************* TN_CMCaptDev8aForm.FormShow ***
// Set Self fields by CMDPStrPar1 in Device Profile
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev8aForm.FormShow( Sender: TObject );
begin

end; // procedure TN_CMCaptDev8aForm.FormShow

end.
