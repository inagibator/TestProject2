unit N_CMCaptDev32aF;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0, IniFiles, K_CLib0, N_Lib0,
  K_FPathNameFr, N_FNameFr;

type TN_CMCaptDev32aForm = class( TN_BaseForm )
  bnOK:          TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    edLogin: TEdit;
    edPassword: TEdit;
    lbPCUser: TLabel;
    edUser: TEdit;

  // ***** events handlers
  procedure bnOKClick ( Sender: TObject );
  procedure FormShow  ( Sender: TObject );

  public
    CMOFPDevProfile: TK_PCMDeviceProfile;
end;

implementation
{$R *.dfm}

uses
  N_CMCaptDev32, K_CM1;

//******************************************* TN_CMCaptDev32aForm.bnOKClick ***
// Button "OK" click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev32aForm.bnOKClick( Sender: TObject );
begin
  // creating a final string
  CMOFPDevProfile.CMDPStrPar1 := edUser.Text;
  CMOFPDevProfile.CMDPStrPar2 := edLogin.Text + '/~/' + edPassword.Text;
end; // procedure TN_CMCaptDev32aForm.bnOKClick

//******************************************** TN_CMCaptDev32aForm.FormShow ***
// FormShow event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev32aForm.FormShow( Sender: TObject );
begin
  inherited;
  edUser.Text := CMOFPDevProfile.CMDPStrPar1;

  edLogin.Text := Copy( CMOFPDevProfile.CMDPStrPar2, 0,
                                  Pos( '/~/',CMOFPDevProfile.CMDPStrPar2) - 1 );
   edPassword.Text := Copy( CMOFPDevProfile.CMDPStrPar2,
                                  Pos( '/~/',CMOFPDevProfile.CMDPStrPar2 ) + 3,
                                  Length(CMOFPDevProfile.CMDPStrPar2) );
end; // procedure TN_CMCaptDev32aForm.FormShow( Sender: TObject );

end.
