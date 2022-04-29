unit N_CMCaptDev34bF;
// Settings form for FireCR/MediaScan changed from Valery Ovechkin 26.02.2013 Dev5 dialog

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0, IniFiles, K_CLib0, N_Lib0;

type TN_CMCaptDev34bForm = class( TN_BaseForm )   // Cancel button
  bnOK:     TButton;
  cbAuto:   TCheckBox;
  edIP1:    TEdit;
  lbNick:   TLabel;
  lbPN:     TLabel;
  lbIPAddress: TLabel;
  lbImageCountValue: TLabel;
  lbNickValue: TLabel;
  lbPNValue: TLabel;
  lbIPAddressValue: TLabel;
  cbImageFilter: TCheckBox;
  edIP2:    TEdit;
  edIP3:    TEdit;
  edIP4:    TEdit;
  lbDot1:   TLabel;
  lbDot2:   TLabel;
  lbDot3:   TLabel;
  bnCalibrationDialog: TButton;
  bnControl: TButton;
  ComboBox1: TComboBox;
  bnConnect: TButton;
  Panel1:    TPanel;
  cbFireID:  TCheckBox;
  cbNewSDK:  TCheckBox;

  // ***** events handlers
  procedure bnOKClick          ( Sender: TObject );
  procedure cbAutoClick        ( Sender: TObject );
  procedure FormShow           ( Sender: TObject );
  procedure cbImageFilterClick ( Sender: TObject );
  procedure FormClose          ( Sender: TObject; var Action: TCloseAction ); override;
  procedure bnControlClick     ( Sender: TObject );
  procedure Calibration        ( Sender: TObject );
  procedure ComboBox1Change    ( Sender: TObject );
  procedure bnConnectClick     ( Sender: TObject );
  procedure cbNewSDKClick      ( Sender: TObject );

  public
    CMCDPDevProfile: TK_PCMDeviceProfile;
    CMCDDevCount:        Integer;
    CMCDFromCaptionForm: Boolean;
    CMCDNewAfterOpen:    Boolean;
end;


implementation
{$R *.dfm}

uses
  N_CMCaptDev34S, N_CMMain5F;

//******************************************** TN_CMCaptDev34bForm.bnOKClick ***
// Button "OK" click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev34bForm.bnOKClick( Sender: TObject );
begin
  // ***** writing ini-file
end; // procedure TN_CMCaptDev34bForm.bnOKClick( Sender: TObject );

//************************************** TN_CMCaptDev34bForm.bnConnectClick ***
// Connect to the choosen scanner
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev34bForm.bnConnectClick( Sender: TObject );
begin
  inherited;
  N_CMECDVDC_Disconnect();
  N_CMECDVDC_Connect( @(N_StringToAnsi(lbIPAddressValue.Caption)[1]) );
  N_CMCDServObj34.CDSScannerIP := lbIPAddressValue.Caption;
  N_Dump1Str( 'New scanner IP is = ' + ComboBox1.Text + ', which is = ' +
                                                     lbIPAddressValue.Caption );
end; // procedure TN_CMCaptDev34bForm.bnConnectClick( Sender: TObject );

//************************************** TN_CMCaptDev34bForm.bnControlClick ***
// Control settings menu
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev34bForm.bnControlClick( Sender: TObject );
begin
  inherited;
  if N_CMCDServObj34.CDSSDKOld then // old sdk
  begin
    N_CMECDVDC_ShowScannerControlDialogOld( -1 );
  end
  else
  begin
    N_CMECDVDC_ShowScannerControlDialog( -1 );
  end;
end; // procedure TN_CMCaptDev34bForm.bnControlClick( Sender: TObject );

//***************************************** TN_CMCaptDev34bForm.Calibration ***
// Calibration settings menu
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev34bForm.Calibration( Sender: TObject );
begin
  inherited;
  if N_CMCDServObj34.CDSSDKOld then // old sdk
  begin
    N_CMECDVDC_ShowCalibrationDialogOld( -1 );
  end
  else
  begin
    N_CMECDVDC_ShowCalibrationDialog( -1 );
  end;
end; // procedure TN_CMCaptDev34bForm.Calibration( Sender: TObject );

// procedure TN_CMCaptDev34bForm.bnOKClick

//***************************************** TN_CMCaptDev34bForm.cbAutoClick ***
// CheckBox AutoClick click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev34bForm.cbAutoClick( Sender: TObject );
begin
  inherited;
end; // procedure TN_CMCaptDev34bForm.cbAutoClick(Sender: TObject);

//***************************************** TN_CMCaptDev34bForm.cbAutoClick ***
// CheckBox AutoClick click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev34bForm.cbImageFilterClick( Sender: TObject );
begin
  inherited;
  // is apply image filter
  N_CMCDServObj34.CDSImageFilter := cbImageFilter.Checked;
end; // procedure TN_CMCaptDev34bForm.cbImageFilterClick( Sender: TObject );

//*************************************** TN_CMCaptDev34bForm.cbNewSDKClick ***
// CheckBox New/Old SDK
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev34bForm.cbNewSDKClick( Sender: TObject );
begin
  inherited;
  if cbNewSDK.Checked then
  begin
    if CMCDFromCaptionForm then
      bnConnect.Enabled := True;

    cbFireID.Enabled  := True;
  end
  else
  begin
    ComboBox1.Enabled := False;
    bnConnect.Enabled := False;
    cbFireID.Enabled  := False;
  end;
end; // procedure TN_CMCaptDev34bForm.cbNewSDKClick( Sender: TObject );

//************************************* TN_CMCaptDev34bForm.ComboBox1Change ***
// IP list change
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev34bForm.ComboBox1Change( Sender: TObject );
var
  Params: PN_ScannerIntro;
  Count:  Integer;
begin
  inherited;

  CMCDDevCount := ComboBox1.ItemIndex;

  Count := 0; // index of the sensor
  N_Dump1Str( 'FireCR - Before RequestScannerList( @Count ), Count = 0' );
  Params := N_CMECDVDC_RequestScannerList( @Count ); // scanner parameters
  N_Dump1Str( 'FireCR - After RequestScannerList( @Count ), Count = 0' );

  if CMCDDevCount > 1 then
    Inc( Params, CMCDDevCount-1 );

  // ***** show parameters
  If Assigned( Params ) then
  begin
    N_Dump1Str( 'FireCR - Scanner List is assigned' );

    lbNickValue.Caption := N_AnsiToString( Params.SIHostName );
    N_Dump1Str( 'FireCR - Nick = ' + Params.SIHostName );

    lbPNValue.Caption := N_AnsiToString( Params.SIScannerName );
    N_Dump1Str( 'FireCR - PN = ' + Params.SIScannerName );

    lbIPAddressValue.Caption := Format( '%d.%d.%d.%d',
                                         [ Byte(Params.SIScannerIP.SIUBytes[0]),
                                           Byte(Params.SIScannerIP.SIUBytes[1]),
                                           Byte(Params.SIScannerIP.SIUBytes[2]),
                                           Byte(Params.SIScannerIP.SIUBytes[3])
                                         ]);
    N_Dump1Str( 'FireCR - IPAddress.Bytes = ' +
                                         IntToStr(Params.SIScannerIP.SIUQuad) );

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
end; // procedure TN_CMCaptDev34bForm.ComboBox1Change( Sender: TObject );

//******************************************* TN_CMCaptDev34bForm.FormClose ***
// FormClose event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev34bForm.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin
  inherited;

  if N_CMCDServObj34.CDSSDKOld then // old sdk
  begin

    if CMCDFromCaptionForm then
    if N_CMCDServObj34.CDSInit then
    begin
    end;

  end
  else // new
  begin

    if CMCDFromCaptionForm then
    if N_CMCDServObj34.CDSInit then
    begin
      N_CMECDVDC_CloseScanner();
      N_CMECDVDC_CloseScannerSDK();
    end;

  end; // new

  if cbNewSDK.Checked then
  begin

    if cbFireID.Checked then
      CMCDPDevProfile.CMDPStrPar1 := '1'
    else
      CMCDPDevProfile.CMDPStrPar1 := '0';

  end // if cbNewSDK.Checked then
  else
    CMCDPDevProfile.CMDPStrPar1 := CMCDPDevProfile.CMDPStrPar1[1];

  if CMCDPDevProfile.CMDPStrPar1 = '' then
    CMCDPDevProfile.CMDPStrPar1 := '0';

  if cbNewSDK.Checked then
  begin
   if not CMCDNewAfterOpen then
     Inc( N_CMCDServObj34.CDSSettingsChanges );

    CMCDPDevProfile.CMDPStrPar1 := CMCDPDevProfile.CMDPStrPar1 + '0'
  end // if cbNewSDK.Checked then
  else
  begin
    if CMCDNewAfterOpen then
     Inc( N_CMCDServObj34.CDSSettingsChanges );

    CMCDPDevProfile.CMDPStrPar1 := CMCDPDevProfile.CMDPStrPar1 + '1';
  end; // else

  CMCDPDevProfile.CMDPStrPar1 := CMCDPDevProfile.CMDPStrPar1 +
                                                   N_CMCDServObj34.CDSScannerIP;

  N_Dump1Str( 'After Settings StrPar1 = ' + CMCDPDevProfile.CMDPStrPar1 );

  if N_CMCDServObj34.CDSSettingsChanges >= 1 then // cms reboot needed
  begin
    K_CMShowMessageDlg1( 'In order for any changes to take effect, CMS will be closed after entering Main Menu. ',
                                                            mtWarning, [mbOK] );

    K_CMCloseOnCurUICloseFlag := TRUE;
    K_CMD4WCloseAppByUI := K_CMD4WAppRunByCOMClient;
    K_CMCloseOnFinActionFlag := TRUE;
    //N_CM_MainForm.Close();
  end;

  N_Dump1Str( 'Before Close Settings StrPar1 = ' + CMCDPDevProfile.CMDPStrPar1 );
end; // procedure TN_CMCaptDev34bForm.FormClose

//******************************************** TN_CMCaptDev34bForm.FormShow ***
// FormShow event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev34bForm.FormShow( Sender: TObject );
var
  Params:    PN_ScannerIntro;
  ParamsOld: PN_ScannerIntroOld;
  Count, i, TempInt: Integer;
  TempStr1:  WideString;
begin
  inherited;
  N_Dump1Str( 'FormShow started' );

  try

  N_Dump1Str( 'Before StrPar1 = ' + CMCDPDevProfile.CMDPStrPar1);

  N_Dump1Str( 'FireCR - From Caption Form = ' + BoolToStr(CMCDFromCaptionForm) );
  if CMCDFromCaptionForm then // opened from caption form
  begin
    cbNewSDK.Enabled := False;
    cbFireID.Enabled := False;
  end
  else // opened from settings
  begin
    ComboBox1.Enabled := False;
    bnConnect.Enabled := False;

    lbNickValue.Caption       := 'None';
    lbPNValue.Caption         := 'None';
    lbIPAddressValue.Caption  := 'None';
    lbImageCountValue.Caption := 'None';
  end;

  if Length(CMCDPDevProfile.CMDPStrPar1) > 1 then
  begin

    if CMCDPDevProfile.CMDPStrPar1[2] = '1' then // old sdk
    begin
      cbNewSDK.Checked := False;
      CMCDNewAfterOpen := False; // old after open
    end
    else // new sdk
    begin
      cbNewSDK.Checked := True;
      CMCDNewAfterOpen := True; // new after open

      if CMCDPDevProfile.CMDPStrPar1[1] = '1' then // fire id
        cbFireID.Checked := True
      else
        cbFireID.Checked := False;

    end; // else // new sdk

  end // if CMCDPDevProfile.CMDPStrPar1.Length > 1 then
  else
  begin // old values, set default
    if Length(CMCDPDevProfile.CMDPStrPar1) = 1 then
      CMCDPDevProfile.CMDPStrPar1 := CMCDPDevProfile.CMDPStrPar1 + '1'
    else
      CMCDPDevProfile.CMDPStrPar1 := '01';

    cbNewSDK.Checked := False;
  end;

  N_Dump1Str( '1 After Settings StrPar1 = ' + CMCDPDevProfile.CMDPStrPar1 );

  if cbNewSDK.Checked then
    N_CMCDServObj34.CDSSDKOld := False
  else
    N_CMCDServObj34.CDSSDKOld := True;

  cbImageFilter.Checked := N_CMCDServObj34.CDSImageFilter;

  if K_CMGAModeFlag then
  begin
    bnCalibrationDialog.Enabled := True;
    bnControl.Enabled := True;
  end;

  if CMCDFromCaptionForm then // opened from caption form
  begin
    if not N_CMCDServObj34.CDSInit then // not initialized yet
    begin
      if not N_CMCDServObj34.CDSSDKOld then // new
      begin

        N_Dump1Str( 'New SDK' );
        N_CMCDServObj34.CDSInit := True;
        N_CMCDServObj34.CDSInitDll();

        // ***** setting callback-functions
        N_CMCDServObj34.CDSCallBacks.CBSRFIDNotifyEvent	:= @N_OnRFIDNotify;
      	N_CMCDServObj34.CDSCallBacks.CBSRFIDStatusEvent	:= @N_OnRFIDStatus;
      	N_CMCDServObj34.CDSCallBacks.CBSScannerNotifyEvent := @N_OnScannerNotify;
      	N_CMCDServObj34.CDSCallBacks.CBSScannerStatusEvent := @N_OnScannerStatus;
        N_CMCDServObj34.CDSCallBacks.CBSRFIDScannerList := @N_OnScannerList;
        N_CMCDServObj34.CDSCallBacks.CBSRFIDImageList := @N_OnImageList;

        TempStr1 := '.'; // path to config file
        N_CMECDVDC_OpenScannerSDK( 0, @N_CMCDServObj34.CDSCallBacks, @TempStr1[1] );
        N_CMECDVDC_OpenScanner();

        Count := 0; // index of the sensor
        N_Dump1Str( 'FireCR - Before RequestScannerList( @Count ), Count = 0' );
        N_CMECDVDC_RequestScannerList( @Count ); // scanner parameters
        N_Dump1Str( 'FireCR - After RequestScannerList( @Count )' );
        if Count = 0 then
        begin
          N_Dump1Str( 'FireCR - Scanner List is not assigned' );
        end;
      end
      else // old
      begin

        N_Dump1Str( 'Old SDK' );

        // ***** setting callback-functions
        N_CMCDServObj34.CDSCallBacksOld.CBSRFIDNotifyEvent	:= @N_OnRFIDNotifyOld;
	      N_CMCDServObj34.CDSCallBacksOld.CBSRFIDStatusEvent	:= Nil;
	      N_CMCDServObj34.CDSCallBacksOld.CBSScannerNotifyEvent := @N_OnScannerNotifyOld;
       	N_CMCDServObj34.CDSCallBacksOld.CBSScannerStatusEvent := Nil;

        N_Dump1Str( 'FireCR - Before OpenScannerSDK' );
        N_CMCDServObj34.CDSInit := True;
        N_CMCDServObj34.CDSInitDllOld();

        TempStr1 := '.'; // path to config file
      	TempInt := N_CMECDVDC_OpenScannerSDKOld( 0, @N_CMCDServObj34.CDSCallBacksOld,
                                                                 @TempStr1[1] ); // starting callback
        N_Dump1Str( 'FireCR - After OpenScannerSDK = ' + IntToStr(TempInt) );

        N_CMCDServObj34.CDSPrevProgress := 0; // need for capture image
        N_Dump1Str( 'FireCR - Before OpenScanner' );
        TempInt := N_CMECDVDC_OpenScannerOld();
        N_Dump1Str( 'FireCR - After OpenScanner = ' + IntToStr(TempInt) );
      end;
    end;

    if N_CMCDServObj34.CDSSDKOld then // get settings (old)
    begin

      N_Dump1Str( 'Old SDK' );

      ComboBox1.Enabled := False;
      bnConnect.Enabled   := False;

      Count := 0; // index of the sensor
      N_Dump1Str( 'FireCR - Before RequestScannerList( @Count ), Count = 0' );
      ParamsOld := N_CMECDVDC_RequestScannerListOld( @Count ); // scanner parameters
      N_Dump1Str( 'FireCR - After RequestScannerList( @Count )' );

      // ***** show parameters
      If Assigned( ParamsOld ) then
      begin
        N_Dump1Str( 'FireCR - Scanner List is assigned' );
        lbNickValue.Caption := N_AnsiToString( ParamsOld.SINick );
        N_Dump1Str( 'FireCR - Nick = ' + ParamsOld.SINick );

        lbPNValue.Caption := N_AnsiToString( ParamsOld.SIPN );
        N_Dump1Str( 'FireCR - PN = ' + ParamsOld.SIPN );

        lbIPAddressValue.Caption := Format( '%d.%d.%d.%d',
                                      [ Byte(ParamsOld.SIIPAddress.SIUBytes[0]),
                                        Byte(ParamsOld.SIIPAddress.SIUBytes[1]),
                                        Byte(ParamsOld.SIIPAddress.SIUBytes[2]),
                                         Byte(ParamsOld.SIIPAddress.SIUBytes[3])
                                       ]);
        N_Dump1Str( 'FireCR - IPAddress.Bytes = ' +
                                      IntToStr(ParamsOld.SIIPAddress.SIUQuad) );

        lbImageCountValue.Caption := IntToStr( ParamsOld.SIImageCount );
        N_Dump1Str( 'FireCR - Image count = ' + IntToStr(ParamsOld.SIImageCount) );
      end else // there is no parameters
      begin
        N_Dump1Str( 'FireCR - Scanner List is not assigned' );
        lbNickValue.Caption       := 'None';
        lbPNValue.Caption         := 'None';
        lbIPAddressValue.Caption  := 'None';
        lbImageCountValue.Caption := 'None';
      end;

    end // get settings (old)
    else // new
    begin

      N_Dump1Str( 'New SDK' );
      N_Dump1Str(CMCDPDevProfile.CMDPStrPar1);

      if CMCDPDevProfile.CMDPStrPar1 = '' then
        CMCDPDevProfile.CMDPStrPar1 := '0';

      // ***** setting component's values
      if CMCDPDevProfile.CMDPStrPar1[1] = '1' then
      begin
        cbFireID.Checked := True;
      end
      else
      begin
        cbFireID.Checked := False;
      end;

      Count := 0; // index of the sensor
      N_Dump1Str( 'FireCR - Before RequestScannerList( @Count ), Count = 0' );
      Params := N_CMECDVDC_RequestScannerList( @Count ); // scanner parameters
      N_Dump1Str( 'FireCR - After RequestScannerList( @Count ), Count = ' +
                                                              IntToStr(Count) );

      for i := 0 to Count - 1 do
      begin
        ComboBox1.Items.Add(IntToStr(i+1) + ': ' +
                                          N_AnsiToString(Params.SIScannerName));
        Inc(Params);
      end;

      if ComboBox1.Items.Count <> 0 then
        ComboBox1.ItemIndex := 0;

      Dec(Params); // return to the last

      N_Dump1Str( 'Before scanner IP' );
      if N_CMCDServObj34.CDSScannerIP = '' then
        if Length(CMCDPDevProfile.CMDPStrPar1) > 2 then
        begin
          N_CMCDServObj34.CDSScannerIP := CMCDPDevProfile.CMDPStrPar1;
          Delete( N_CMCDServObj34.CDSScannerIP, 1, 1 );
        end;

        if N_CMCDServObj34.CDSScannerIP <> '' then // setup previous scanner ip
        begin
          i := ComboBox1.Items.IndexOf(N_CMCDServObj34.CDSScannerIP);
          if i <> -1 then
            ComboBox1.ItemIndex := i;
        end;
        N_Dump1Str( 'After scanner IP' );

        // ***** show parameters
        If Assigned( Params ) then
        begin
          N_Dump1Str( 'FireCR - Scanner List is assigned' );

          lbNickValue.Caption := N_AnsiToString( Params.SIHostName );
          N_Dump1Str( 'FireCR - Nick = ' + Params.SIHostName );

          lbPNValue.Caption := N_AnsiToString( Params.SIScannerName );
          N_Dump1Str( 'FireCR - PN = ' + Params.SIScannerName );

          lbIPAddressValue.Caption := Format( '%d.%d.%d.%d',
                                         [ Byte(Params.SIScannerIP.SIUBytes[0]),
                                           Byte(Params.SIScannerIP.SIUBytes[1]),
                                           Byte(Params.SIScannerIP.SIUBytes[2]),
                                           Byte(Params.SIScannerIP.SIUBytes[3])
                                         ]);

          N_Dump1Str( 'FireCR - IPAddress.Bytes = ' +
                                         IntToStr(Params.SIScannerIP.SIUQuad) );

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

      end; // if N_CMCDServObj34.CDSScannerIP = '' then
    end; // new

  except
  on E : Exception do
  begin
    N_Dump1Str( 'Unable to get access to the specified device. ' +
                        E.ClassName+' error raised, with message: '+E.Message );
  end;
  end;

    N_Dump1Str( '2 After Settings StrPar1 = ' + CMCDPDevProfile.CMDPStrPar1 );
end; // procedure TN_CMCaptDev34bForm.FormShow( Sender: TObject );

end.
