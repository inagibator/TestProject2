unit N_CMCaptDev19aF;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0, IniFiles, K_CLib0, N_Lib0,
  K_FPathNameFr, N_FNameFr;

type TN_CMCaptDev19aForm = class( TN_BaseForm )
  bnOK:          TButton;
  FileNameFrame: TN_FileNameFrame;
    RadioGroup1: TRadioGroup;
    cbOpenAfter: TCheckBox;
    ThumbnailFrame: TN_FileNameFrame;

  // ***** events handlers
  procedure bnOKClick ( Sender: TObject );
  procedure FormShow  ( Sender: TObject );
    procedure RadioGroup1Click(Sender: TObject);

  public
    CMOFPDevProfile: TK_PCMDeviceProfile;
end;

implementation
{$R *.dfm}

uses
  N_CMCaptDev19, K_CM1;

//******************************************* TN_CMCaptDev19aForm.bnOKClick ***
// Button "OK" click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev19aForm.bnOKClick( Sender: TObject );
begin
  // creating a final string
  CMOFPDevProfile.CMDPStrPar1 := FileNameFrame.mbFileName.Text;
  CMOFPDevProfile.CMDPStrPar2 := '1';//IntToStr(RadioGroup1.ItemIndex); // only Ez3D-i now
  if cbOpenAfter.Checked = True then
    CMOFPDevProfile.CMDPStrPar2 := CMOFPDevProfile.CMDPStrPar2 + '1'
  else
    CMOFPDevProfile.CMDPStrPar2 := CMOFPDevProfile.CMDPStrPar2 + '0';

  CMOFPDevProfile.CMDPStrPar2 := CMOFPDevProfile.CMDPStrPar2 + ThumbnailFrame.mbFileName.Text;
end; // procedure TN_CMCaptDev19aForm.bnOKClick

//******************************************** TN_CMCaptDev19aForm.FormShow ***
// FormShow event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev19aForm.FormShow( Sender: TObject );
var
  TmpStr: string;
begin
  inherited;
  FileNameFrame.mbFileName.Text := CMOFPDevProfile.CMDPStrPar1;

  if Length(CMOFPDevProfile.CMDPStrPar2) < 2 then
     CMOFPDevProfile.CMDPStrPar2 := '11';

   RadioGroup1.ItemIndex := 1; //StrToInt(CMOFPDevProfile.CMDPStrPar2[1]); // only Ez3D-i now
   if StrToInt(CMOFPDevProfile.CMDPStrPar2[2]) = 1 then
     cbOpenAfter.Checked := True
   else
     cbOpenAfter.Checked := False;

   TmpStr := CMOFPDevProfile.CMDPStrPar2;
   Delete( TmpStr, 1, 1 );
   Delete( TmpStr, 1, 1 );
   ThumbnailFrame.mbFileName.Text := TmpStr;
end;

procedure TN_CMCaptDev19aForm.RadioGroup1Click(Sender: TObject);
begin
  inherited;
  if RadioGroup1.ItemIndex = 1 then
    cbOpenAfter.Enabled := True
  else
    cbOpenAfter.Enabled := False;
end;

// procedure TN_CMCaptDev19aForm.FormShow( Sender: TObject );

end.
