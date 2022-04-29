unit N_CMCaptDev28aF;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0, IniFiles, K_CLib0, N_Lib0,
  K_FPathNameFr, N_FNameFr;

type TN_CMCaptDev28aForm = class( TN_BaseForm )
  bnOK:          TButton;
  FileNameFrame: TN_FileNameFrame;

  // ***** events handlers
  procedure bnOKClick ( Sender: TObject );
  procedure FormShow  ( Sender: TObject );

  public
    CMOFPDevProfile: TK_PCMDeviceProfile;
end;

implementation
{$R *.dfm}

uses
  N_CMCaptDev28, K_CM1;

//******************************************* TN_CMCaptDev28aForm.bnOKClick ***
// Button "OK" click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev28aForm.bnOKClick( Sender: TObject );
begin
  // creating a final string
  CMOFPDevProfile.CMDPStrPar1 := FileNameFrame.mbFileName.Text;
end; // procedure TN_CMCaptDev28aForm.bnOKClick

//******************************************** TN_CMCaptDev28aForm.FormShow ***
// FormShow event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev28aForm.FormShow( Sender: TObject );
begin
  inherited;
  FileNameFrame.mbFileName.Text := CMOFPDevProfile.CMDPStrPar1;
end; // procedure TN_CMCaptDev28aForm.FormShow( Sender: TObject );

end.
