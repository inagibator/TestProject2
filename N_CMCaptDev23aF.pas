unit N_CMCaptDev23aF;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0, IniFiles, K_CLib0, N_Lib0,
  K_FPathNameFr;

type TN_CMCaptDev23aForm = class( TN_BaseForm )
  bnOK:        TButton;
    chb16BitMode: TCheckBox;

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
  N_CMCaptDev23S;

//******************************************* TN_CMCaptDev18aForm.bnOKClick ***
// Button "OK" click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev23aForm.bnOKClick( Sender: TObject );
begin
  if chb16BitMode.Checked = True then
    CMOFPDevProfile.CMDPStrPar2 := '1'
  else
    CMOFPDevProfile.CMDPStrPar2 := '0';
end; // procedure TN_CMCaptDev18aForm.bnOKClick

//******************************************** TN_CMCaptDev18aForm.FormShow ***
// FormShow event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev23aForm.FormShow( Sender: TObject );
begin
  inherited;
  if CMOFPDevProfile.CMDPStrPar2 = '1' then
    chb16BitMode.Checked := True
  else
    chb16BitMode.Checked := False;
  // set previous at a beginning (actual mode will be more by 1)
end; // procedure TN_CMCaptDev18aForm.FormShow( Sender: TObject );

//************************************ TN_CMCaptDev18aForm.RadioGroup1Click ***
// Chosed a device mode event
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev23aForm.RadioGroup1Click( Sender: TObject );
begin
  inherited;
  // save chosed mode (actual mode will be more by 1 then a chosed index)
end; // procedure TN_CMCaptDev18aForm.RadioGroup1Click

end.
