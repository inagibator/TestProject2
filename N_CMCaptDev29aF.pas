unit N_CMCaptDev29aF;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0, IniFiles, K_CLib0, N_Lib0,
  K_FPathNameFr;

type TN_CMCaptDev29aForm = class( TN_BaseForm )
  bnOK:        TButton;
  RadioGroup1: TRadioGroup;
  GroupBox1:   TGroupBox;
  edLogin:     TEdit;
  edPassword:  TEdit;
  Label1:      TLabel;
  Label2:      TLabel;

  // ***** events handlers
  procedure bnOKClick        ( Sender: TObject );
  procedure RadioGroup1Click ( Sender: TObject );
  procedure FormShow         ( Sender: TObject );

  public
    CMOFPDevProfile: TK_PCMDeviceProfile;
end;

implementation
{$R *.dfm}

uses
  N_CMCaptDev25, K_CM1;

//******************************************* TN_CMCaptDev29aForm.bnOKClick ***
// Button "OK" click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev29aForm.bnOKClick( Sender: TObject );
begin
  // creating a final string
  CMOFPDevProfile.CMDPStrPar1 := IntToStr(RadioGroup1.ItemIndex);
  CMOFPDevProfile.CMDPStrPar2 := edLogin.Text + '/~/' + edPassword.Text;

end; // procedure TN_CMCaptDev29aForm.bnOKClick

//******************************************** TN_CMCaptDev29aForm.FormShow ***
// FormShow event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev29aForm.FormShow( Sender: TObject );
begin
  inherited;

   if CMOFPDevProfile.CMDPStrPar1 = '' then
     CMOFPDevProfile.CMDPStrPar1 := '0';

   RadioGroup1.ItemIndex := StrToInt(CMOFPDevProfile.CMDPStrPar1);

   edLogin.Text := Copy( CMOFPDevProfile.CMDPStrPar2, 0,
                                  Pos( '/~/',CMOFPDevProfile.CMDPStrPar2) - 1 );
   edPassword.Text := Copy( CMOFPDevProfile.CMDPStrPar2,
                                  Pos( '/~/',CMOFPDevProfile.CMDPStrPar2 ) + 3,
                                  Length(CMOFPDevProfile.CMDPStrPar2) );

end; // procedure TN_CMCaptDev29aForm.FormShow( Sender: TObject );

//************************************ TN_CMCaptDev29aForm.RadioGroup1Click ***
// Chosed a device mode event
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev29aForm.RadioGroup1Click( Sender: TObject );
begin
  inherited;
  // save chosed mode (actual mode will be more by 1 then a chosed index)
end; // procedure TN_CMCaptDev29aForm.RadioGroup1Click

end.
