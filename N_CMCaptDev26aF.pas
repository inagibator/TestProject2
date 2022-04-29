unit N_CMCaptDev26aF;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0, IniFiles, K_CLib0, N_Lib0,
  K_FPathNameFr;

type TN_CMCaptDev26aForm = class( TN_BaseForm )
  bnOK:   TButton;
  cb8bit: TCheckBox;

  // ***** events handlers
  procedure bnOKClick        ( Sender: TObject );
  procedure FormShow         ( Sender: TObject );

  public
    CMOFPDevProfile: TK_PCMDeviceProfile;
end;

implementation
{$R *.dfm}

uses
  N_CMCaptDev26, K_CM1;

//******************************************* TN_CMCaptDev26aForm.bnOKClick ***
// Button "OK" click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev26aForm.bnOKClick( Sender: TObject );
begin
  // creating a final string
  if cb8bit.Checked then
    CMOFPDevProfile.CMDPStrPar1 := '1'
  else
    CMOFPDevProfile.CMDPStrPar1 := '0';
end; // procedure TN_CMCaptDev26aForm.bnOKClick

//******************************************** TN_CMCaptDev26aForm.FormShow ***
// FormShow event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev26aForm.FormShow( Sender: TObject );
begin
  inherited;

  // ***** parsing a string
  if CMOFPDevProfile.CMDPStrPar1 = '1' then
  begin
    cb8bit.Checked := True;
  end;
end; // procedure TN_CMCaptDev26aForm.FormShow( Sender: TObject );

end.
