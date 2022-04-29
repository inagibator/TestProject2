unit N_CMCaptDev18aF;
// Settings form for PaloDEx changed from Valery Ovechkin 26.02.2013 Dev5 dialog

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0, IniFiles, K_CLib0, N_Lib0;

type TN_CMCaptDev18aForm = class( TN_BaseForm )
  bnOK:        TButton;
  RadioGroup1: TRadioGroup;

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
procedure TN_CMCaptDev18aForm.bnOKClick( Sender: TObject );
begin
end; // procedure TN_CMCaptDev18aForm.bnOKClick

//******************************************** TN_CMCaptDev18aForm.FormShow ***
// FormShow event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev18aForm.FormShow( Sender: TObject );
begin
  inherited;
  // set previous at a beginning (actual mode will be more by 1)
  RadioGroup1.ItemIndex := StrToIntDef( CMOFPDevProfile.CMDPStrPar2, 1 ) - 1;
end; // procedure TN_CMCaptDev18aForm.FormShow( Sender: TObject );

//************************************ TN_CMCaptDev18aForm.RadioGroup1Click ***
// Chosed a device mode event
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev18aForm.RadioGroup1Click( Sender: TObject );
begin
  inherited;
  // save chosed mode (actual mode will be more by 1 then a chosed index)
  CMOFPDevProfile.CMDPStrPar2 := IntToStr( RadioGroup1.ItemIndex + 1 );
end; // procedure TN_CMCaptDev18aForm.RadioGroup1Click

end.
