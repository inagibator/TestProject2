unit N_CMCaptDev15bF;
// Settings form for FireCR/MediaScan changed from Valery Ovechkin 26.02.2013 Dev5 dialog

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0, IniFiles, K_CLib0, N_Lib0;

type TN_CMCaptDev15bForm = class( TN_BaseForm )   // Cancel button
  bnOK:     TButton;
  cbAuto: TCheckBox;
  edIP1: TEdit;
  lbNick: TLabel;
  lbPN: TLabel;
  lbIPAddress: TLabel;
  lbImageCountValue: TLabel;
  lbNickValue: TLabel;
  lbPNValue: TLabel;
  lbIPAddressValue: TLabel;
  cbImageFilter: TCheckBox;
  edIP2: TEdit;
  edIP3: TEdit;
  edIP4: TEdit;
  lbDot1: TLabel;
  lbDot2: TLabel;
  lbDot3: TLabel;
  bnCalibrationDialog: TButton;
  bnControl: TButton;

  // ***** events handlers
  procedure bnOKClick          ( Sender: TObject );
  procedure cbAutoClick        ( Sender: TObject );
  procedure FormShow           ( Sender: TObject );
  procedure cbImageFilterClick ( Sender: TObject );
  procedure FormClose          ( Sender: TObject; var Action: TCloseAction ); override;
  procedure bnControlClick     ( Sender: TObject );
  procedure Calibration        ( Sender: TObject );

  public
    CMOFPDevProfile: TK_PCMDeviceProfile;
end;


implementation
{$R *.dfm}

uses
  N_CMCaptDev15S;

//******************************************** TN_CMCaptDev15bForm.bnOKClick ***
// Button "OK" click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev15bForm.bnOKClick( Sender: TObject );
begin
  // ***** writing ini-file
  { var
  Ini: TMemIniFile;
  TempStr: string;

  if not( cbAuto.Checked ) then
  begin
    TempStr := K_GetDirPath( 'CMSWrkFiles' );
    TempStr := TempStr + '!CaptDevInfo\FireCR.ini'; // path to config file
    Ini := TMemIniFile.Create( TempStr );
    Ini.WriteString( 'NETWORK', 'HOST', edIP1.Text + '.' + edIP2.Text + '.' +
                                                edIP3.Text + '.' + edIP4.Text );
    Ini.UpdateFile;
    Ini.Destroy;
  end
  else
  begin
    TempStr := K_GetDirPath( 'CMSWrkFiles' );
    TempStr := TempStr + '!CaptDevInfo\FireCR.ini'; // path to config file
    Ini := TMemIniFile.Create( TempStr );
    Ini.WriteString( 'NETWORK', 'HOST', '0.0.0.0' );
    Ini.UpdateFile;
    Ini.Destroy;
  end;  }
end;

procedure TN_CMCaptDev15bForm.bnControlClick(Sender: TObject);
begin
  inherited;
  N_CMECDVDC_ShowScannerControlDialog(-1);
end;

procedure TN_CMCaptDev15bForm.Calibration(Sender: TObject);
begin
  inherited;
  N_CMECDVDC_ShowCalibrationDialog(-1);
end;

// procedure TN_CMCaptDev15bForm.bnOKClick

//***************************************** TN_CMCaptDev15bForm.cbAutoClick ***
// CheckBox AutoClick click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev15bForm.cbAutoClick( Sender: TObject );
begin
  inherited;

  // ***** setting components
 { if cbAuto.Checked then
  begin
    edIP1.Enabled := False;
    edIP2.Enabled := False;
    edIP3.Enabled := False;
    edIP4.Enabled := False;
  end
  else
  begin
    edIP1.Enabled := True;
    edIP2.Enabled := True;
    edIP3.Enabled := True;
    edIP4.Enabled := True;
  end; }
end; // procedure TN_CMCaptDev15bForm.cbAutoClick(Sender: TObject);

//***************************************** TN_CMCaptDev15bForm.cbAutoClick ***
// CheckBox AutoClick click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev15bForm.cbImageFilterClick( Sender: TObject );
begin
  inherited;
  // is apply image filter
  N_CMCDServObj15.CDSImageFilter := cbImageFilter.Checked;
end; // procedure TN_CMCaptDev15bForm.cbImageFilterClick(Sender: TObject);

//******************************************** TN_CMCaptDev15bForm.FormShow ***
// FormShow event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev15bForm.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin
  inherited;
  if not N_CMCDServObj15.CDSInit then
  begin
    N_CMECDVDC_CloseScanner();
    N_CMECDVDC_CloseScannerSDK();
    N_CMCDServObj15.CDSFreeAll();

  end;
end;

procedure TN_CMCaptDev15bForm.FormShow( Sender: TObject );
var
  Params:  PN_ScannerIntro;
  Count:   Integer;
  TempStr1: WideString;
begin
  inherited;

  // ***** setting components
  {TempStr: string;
  Ini:     TMemIniFile;

  if N_CMCDServObj15.CDSScannerConnectionType = 2 then
  begin
    cbAuto.Enabled := True;
    edIP1.Enabled := True;
    edIP2.Enabled := True;
    edIP3.Enabled := True;
    edIP4.Enabled := True;
  end else
  begin
    cbAuto.Enabled := False;
    edIP1.Enabled := False;
    edIP2.Enabled := False;
    edIP3.Enabled := False;
    edIP4.Enabled := False;
  end; }
  cbImageFilter.Checked := N_CMCDServObj15.CDSImageFilter;

  {TempStr := K_GetDirPath( 'CMSWrkFiles' );
  TempStr := TempStr + '!CaptDevInfo\FireCR.ini'; // path to config file
  Ini := TMemIniFile.Create( TempStr );
  //Ini.WriteString( 'NETWORK', 'HOST', edIP.Text );
  TempStr := Ini.ReadString( 'NETWORK', 'HOST', '' );
  Ini.Destroy;

  // replacing dots with spaces
  TempStr := StringReplace(TempStr, '.', ' ', [rfReplaceAll, rfIgnoreCase]);

  // ***** parse IP
  edIP1.Text := IntToStr( N_ScanInteger(TempStr) );
  edIP2.Text := IntToStr( N_ScanInteger(TempStr) );
  edIP3.Text := IntToStr( N_ScanInteger(TempStr) );
  edIP4.Text := IntToStr( N_ScanInteger(TempStr) );

  // ***** checking the parameters
  if ( StrToInt(edIP1.Text) = N_NotAnInteger ) or
             ( StrToInt(edIP2.Text) = N_NotAnInteger ) or ( StrToInt(edIP3.Text)
              = N_NotAnInteger ) or ( StrToInt(edIP4.Text) = N_NotAnInteger ) or
               ( StrToInt(edIP1.Text) < 0 ) or ( StrToInt(edIP1.Text) > 255 ) or
               ( StrToInt(edIP2.Text) < 0 ) or ( StrToInt(edIP2.Text) > 255 ) or
               ( StrToInt(edIP3.Text) < 0 ) or ( StrToInt(edIP3.Text) > 255 ) or
             ( StrToInt(edIP4.Text) < 0 ) or ( StrToInt(edIP4.Text) > 255 ) then
  begin
    edIP1.Text := '0';
    edIP2.Text := '0';
    edIP3.Text := '0';
    edIP4.Text := '0';
  end;

  // ***** setting the parameters
  if edIP1.Text + '.' + edIP2.Text + '.' + edIP3.Text + '.' + edIP4.Text <>
                                                                  '0.0.0.0' then
  begin
    cbAuto.Checked := False;
  end;

  if cbAuto.Checked then
  begin
    edIP1.Enabled := False;
    edIP2.Enabled := False;
    edIP3.Enabled := False;
    edIP4.Enabled := False;
  end
  else
  begin
    edIP1.Enabled := True;
    edIP2.Enabled := True;
    edIP3.Enabled := True;
    edIP4.Enabled := True;
  end; }

  if K_CMGAModeFlag then
  begin
    bnCalibrationDialog.Enabled := True;
    bnControl.Enabled := True;
  end;

  if not N_CMCDServObj15.CDSInit then
  begin
    if N_CMCDServObj15.CDSInitAll() = 2 then // library error
      Exit;

    TempStr1 := '.'; // path to config file
    N_CMECDVDC_OpenScannerSDK( 0, @N_CMCDServObj15.CDSCallBacks, @TempStr1[1] );
    N_CMECDVDC_OpenScanner();
  end;



  Count := 0; // index of the sensor
  N_Dump1Str( 'FireCR - Before RequestScannerList( @Count ), Count = 0' );
  Params := N_CMECDVDC_RequestScannerList( @Count ); // scanner parameters
  N_Dump1Str( 'FireCR - After RequestScannerList( @Count ), Count = 0' );

  // ***** show parameters
  If Assigned( Params ) then
  begin
    N_Dump1Str( 'FireCR - Scanner List is assigned' );
    lbNickValue.Caption := N_AnsiToString( Params.SINick );
    N_Dump1Str( 'FireCR - Nick = ' + Params.SINick );

    lbPNValue.Caption := N_AnsiToString( Params.SIPN );
    N_Dump1Str( 'FireCR - PN = ' + Params.SIPN );

    lbIPAddressValue.Caption := Format( '%d.%d.%d.%d',
                                         [ Byte(Params.SIIPAddress.SIUBytes[0]),
                                           Byte(Params.SIIPAddress.SIUBytes[1]),
                                           Byte(Params.SIIPAddress.SIUBytes[2]),
                                           Byte(Params.SIIPAddress.SIUBytes[3])
                                         ]);
    N_Dump1Str( 'FireCR - IPAddress.Bytes = ' +
                                         IntToStr(Params.SIIPAddress.SIUQuad) );

    lbImageCountValue.Caption := IntToStr( Params.SIImageCount );
    N_Dump1Str( 'FireCR - Image count = ' + IntToStr(Params.SIImageCount) );
  end else // there is no parameters
  begin
    N_Dump1Str( 'FireCR - Scanner List is not assigned' );
    lbNickValue.Caption       := 'None';
    lbPNValue.Caption         := 'None';
    lbIPAddressValue.Caption  := 'None';
    lbImageCountValue.Caption := 'None';
  end;

end; // procedure TN_CMCaptDev15bForm.FormShow( Sender: TObject );

end.
