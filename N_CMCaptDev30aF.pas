unit N_CMCaptDev30aF;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0, IniFiles, K_CLib0, N_Lib0,
  K_FPathNameFr, N_FNameFr;

type TN_CMCaptDev30aForm = class( TN_BaseForm )
  bnOK:          TButton;
  FileNameFrame:   TN_FileNameFrame;
  OutputNameFrame: TN_FileNameFrame;
  cbDisable:     TCheckBox;

  // ***** events handlers
  procedure bnOKClick ( Sender: TObject );
  procedure FormShow  ( Sender: TObject );

  public
    CMOFPDevProfile: TK_PCMDeviceProfile;
end;

implementation
{$R *.dfm}

uses
  N_CMCaptDev30, K_CM1;

//*************************************************************** IsInteger ***
// Look if there's an integer value in a string
//
//    Parameters
// S      - String
// Result - True if there's an integer value
//
function IsInteger( const S: String ): Boolean;
var
  X: Double;
  E: Integer;
begin
  Val(S, X, E);
  Result := (E = 0) and (Trunc(X) = X);
end; // function IsInteger( const S: String ): Boolean;

//******************************************* TN_CMCaptDev30aForm.bnOKClick ***
// Button "OK" click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev30aForm.bnOKClick( Sender: TObject );
begin
  // creating a final string
  CMOFPDevProfile.CMDPStrPar1 := FileNameFrame.mbFileName.Text;
  if CMOFPDevProfile.CMDPStrPar2 <> '' then
  begin
    CMOFPDevProfile.CMDPStrPar2 := CMOFPDevProfile.CMDPStrPar2[1];

    if cbDisable.Checked then
      CMOFPDevProfile.CMDPStrPar2 := CMOFPDevProfile.CMDPStrPar2 + '1'
    else
      CMOFPDevProfile.CMDPStrPar2 := CMOFPDevProfile.CMDPStrPar2 + '0';

    CMOFPDevProfile.CMDPStrPar2 := CMOFPDevProfile.CMDPStrPar2 +
                                                OutputNameFrame.mbFileName.Text;
  end
  else
  begin
    CMOFPDevProfile.CMDPStrPar2 := '0'; // empty, so first
    CMOFPDevProfile.CMDPStrPar2 := CMOFPDevProfile.CMDPStrPar2 + '1'; // disable default as true
    CMOFPDevProfile.CMDPStrPar2 := CMOFPDevProfile.CMDPStrPar2 +
                                                OutputNameFrame.mbFileName.Text;
  end;

end; // procedure TN_CMCaptDev30aForm.bnOKClick

//******************************************** TN_CMCaptDev30aForm.FormShow ***
// FormShow event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev30aForm.FormShow( Sender: TObject );
var
  WrkDir, TmpStr: string;
begin
  inherited;
  FileNameFrame.mbFileName.Text := CMOFPDevProfile.CMDPStrPar1;

  if CMOFPDevProfile.CMDPStrPar2 <> '' then
  begin
    TmpStr := CMOFPDevProfile.CMDPStrPar2;
    Delete( TmpStr, 1, 1 );

    if TmpStr <> '' then // new version
    if IsInteger(TmpStr[1]) then
    begin

    if TmpStr[1] = '1' then
      cbDisable.Checked := True
    else
      cbDisable.Checked := False;

      Delete( TmpStr, 1, 1 );

    end
    else // old version
      cbDisable.Checked := True; // default for old version

    OutputNameFrame.mbFileName.Text := TmpStr;
  end;

  if OutputNameFrame.mbFileName.Text = '' then
  begin
    WrkDir := K_ExpandFIleName( '(#TmpFiles#)' );
    WrkDir := StringReplace(WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase]);
    OutputNameFrame.mbFileName.Text := WrkDir + 'Vatech/Output.ini';
  end;
end; // procedure TN_CMCaptDev30aForm.FormShow( Sender: TObject );

end.
