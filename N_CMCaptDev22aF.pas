unit N_CMCaptDev22aF;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0, IniFiles, K_CLib0, N_Lib0,
  K_FPathNameFr;

type TN_CMCaptDev22aForm = class( TN_BaseForm )
  bnOK:        TButton;
    SrcPathNameFrame: TK_FPathNameFrame;

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
  N_CMCaptDev18;

//******************************************* TN_CMCaptDev18aForm.bnOKClick ***
// Button "OK" click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev22aForm.bnOKClick( Sender: TObject );
begin

CMOFPDevProfile.CMDPStrPar2 := SrcPathNameFrame.mbPathName.Text;
end; // procedure TN_CMCaptDev18aForm.bnOKClick

//******************************************** TN_CMCaptDev18aForm.FormShow ***
// FormShow event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev22aForm.FormShow( Sender: TObject );
begin
  inherited;
   SrcPathNameFrame.mbPathName.Text := CMOFPDevProfile.CMDPStrPar2;
  // set previous at a beginning (actual mode will be more by 1)
end; // procedure TN_CMCaptDev18aForm.FormShow( Sender: TObject );

//************************************ TN_CMCaptDev18aForm.RadioGroup1Click ***
// Chosed a device mode event
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev22aForm.RadioGroup1Click( Sender: TObject );
begin
  inherited;
  // save chosed mode (actual mode will be more by 1 then a chosed index)
end; // procedure TN_CMCaptDev18aForm.RadioGroup1Click

end.
