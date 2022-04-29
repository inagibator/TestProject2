unit N_CMCaptDev11aF;
// Trident device settings dialog
// 2014.01.04 Added USB plug / unplug reaction by Valery Ovechkin
// 2014.01.04 Added integration time combobox by Valery Ovechkin
// 2014.03.20 Fixed USB event listener by Valery Ovechkin
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2014.07.03 Thread Code redesign by Alex Kovalev
// 2015.06.16 Correction Files reading fixed by Valery Ovechkin
// 2015.06.18 Correction Files names fixed by Valery Ovechkin
// 2015.06.19 Correction Mode Profile Parameter added by Valery Ovechkin
// 2015.06.22 Correction Mode ComboBox position fixed by Valery Ovechkin

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, StdCtrls, ExtCtrls, Forms, Dialogs, ShlObj,
  K_CM0, K_CLib0,
  N_Types, N_Lib1, N_BaseF, N_CMCaptDev11F, N_CMCaptDev0;

type TN_CMCaptDev11aForm = class( TN_BaseForm )
    bnCancel: TButton;   // Cancel button
    bnOK:     TButton;

    lbSensor:         TLabel;
    lbSerNumber: TLabel;
    lbDriverVersion: TLabel;
    lbImageDim: TLabel;
    lbImageSize: TLabel;
    lbSerNumberValue: TLabel;
    lbDriverVersionValue: TLabel;
    lbImageDimValue: TLabel;
    lbImageSizeValue: TLabel;
    lbTimeout: TLabel;
    lbGain: TLabel;
    lbThreshold: TLabel;
    cbTimeout: TComboBox;
    cbGain: TComboBox;
    cbThreshold: TComboBox;
    StatusShape: TShape;
    StatusLabel: TLabel;
    TimerCheck: TTimer;
    bnReset: TButton;
    OpenDialog1: TOpenDialog;
    bnLoadCalibrationFiles: TButton;
    cbFilter: TCheckBox;
    lbIntegrTime: TLabel;
    cbIntegrTime: TComboBox;
    lbCorrMode: TLabel;
    cbCorrMode: TComboBox;
    procedure bnOKClick ( Sender: TObject );
    procedure TimerCheckTimer(Sender: TObject);
    procedure bnResetClick(Sender: TObject);
    procedure bnLoadCalibrationFilesClick(Sender: TObject);

    procedure WMDeviceChange( var Msg: TMessage );
    message WM_DEVICECHANGE;
    procedure FormActivate(Sender: TObject); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;

  public
    CMOFPDevProfile: TK_PCMDeviceProfile; // Pointer to Profile
end;


implementation

uses
  N_CMCaptDev11;

{$R *.dfm}

//************************************** TN_CMCaptDev11aForm.WMDeviceChange ***
// USB event
//
//     Parameters
// Msg - Windows message
//
procedure TN_CMCaptDev11aForm.WMDeviceChange( var Msg: TMessage );
begin
  N_CMCDServObj11.USBProc( Msg );
end; // procedure TN_CMCaptDev11aForm.WMDeviceChange

//************************* TN_CMCaptDev11aForm.bnLoadCalibrationFilesClick ***
// Button "Install correction files" click event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev11aForm.bnLoadCalibrationFilesClick(Sender: TObject);
var
  folder, sn, WrkDir, FileName, FileNameForSave: String;
begin
  folder := '';
  sn := N_CMCDServObj11.SerialNum;
  N_Dump1Str( 'Calibration files selection start, Serial Number = ' + sn );

  if ( sn = '' ) then // Empty Serial Number
  begin
    N_Dump1Str( 'Empty Serial Number' );
    Exit;
  end; // if ( sn = '' ) then // Empty Serial Number

  if not N_CMV_GetFolderDialog( Application.Handle, 'Please select correction files', folder ) then // correction folder selection
  begin
    N_Dump1Str( 'Folder did not selected' );
    Exit;
  end; // if not N_CMV_GetFolderDialog( Application.Handle, 'Please select correction files', folder ) then // correction folder selection

  N_Dump1Str( 'correction folder = "' + folder + '"' );

  if ( folder = '' ) then // empty correction folder path
  begin
    N_Dump1Str( 'empty correction folder path' );
    Exit;
  end; // if ( folder = '' ) then // empty correction folder path

  if not DirectoryExists( folder ) then // correction folder existsing
  begin
    N_Dump1Str( 'correction folder do not exist' );
    Exit;
  end; // if not DirectoryExists( folder ) then // correction folder existsing

  bnLoadCalibrationFiles.Enabled := False;
  WrkDir := N_CMV_GetWrkDir();

  FileName        := folder + '\' + sn + '_Offset Image';
  FileNameForSave := WrkDir +       sn + '_Offset Image';

  if not FileExists( FileName ) then // offset correction file existsing
  begin
    N_CMV_ShowCriticalError( 'Trident', 'offset correction file "' + FileName + '" do not exist.' );
    bnLoadCalibrationFiles.Enabled := True;
    Exit;
  end; // if not FileExists( FileName ) then // offset correction file

  if not N_CMV_CopyFile( FileName, FileNameForSave, 'Trident >> offset correction file' ) then // offset correction file copying
  begin
    N_CMV_ShowCriticalError( 'Trident', 'offset correction file "' + FileName + '" can not be copied.' );
    bnLoadCalibrationFiles.Enabled := True;
    Exit;
  end; // if not N_CMV_CopyFile( FileName, FileNameForSave, 'Trident >> offset correction file' ) then // offset correction file copying

  FileName        := folder + '\' + sn + '_Gain Image';
  FileNameForSave := WrkDir +       sn + '_Gain Image';

  if not FileExists( FileName ) then // gain correction file existsing
  begin
    N_CMV_ShowCriticalError( 'Trident', 'gain correction file "' + FileName + '" do not exists.' );
    bnLoadCalibrationFiles.Enabled := True;
    Exit;
  end; // if not FileExists( FileName ) then // gain correction file

  if not N_CMV_CopyFile( FileName, FileNameForSave, 'Trident >> gain correction file' ) then // gain correction file copying
  begin
    N_CMV_ShowCriticalError( 'Trident', 'gain correction file "' + FileName + '" can not be copied.' );
    bnLoadCalibrationFiles.Enabled := True;
    Exit;
  end; // if not N_CMV_CopyFile( FileName, FileNameForSave, 'Trident >> gain correction file' ) then // gain correction file copying

  FileName        := folder + '\' + sn + '_Pixel Map';
  FileNameForSave := WrkDir +       sn + '_Pixel Map';

  if not FileExists( FileName ) then // pixmap correction file existsing
  begin
    N_CMV_ShowCriticalError( 'Trident', 'pixmap correction file "' + FileName + '" do not exists.' );
    bnLoadCalibrationFiles.Enabled := True;
    Exit;
  end; // if not FileExists( FileName ) then // pixmap correction file

  if not N_CMV_CopyFile( FileName, FileNameForSave, 'Trident >> pixmap correction file' ) then // pixmap correction file copying
  begin
    N_CMV_ShowCriticalError( 'Trident', 'pixmap correction file "' + FileName + '" can not be copied.' );
    bnLoadCalibrationFiles.Enabled := True;
    Exit;
  end; // if not N_CMV_CopyFile( FileName, FileNameForSave, 'Trident >> pixmap correction file' ) then // pixmap correction file copying

  bnLoadCalibrationFiles.Enabled := True;
  N_Dump1Str( 'Calibration files selection finish' );
end; // procedure TN_CMCaptDev11aForm.bnLoadCalibrationFilesClick

//******************************************** TN_CMCaptDev11aForm.bnOKClick ***
// Button "OK" click event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev11aForm.bnOKClick( Sender: TObject );
var
  nTimeout, nGain, nThreshold, nIntegrTime: Integer;
begin
  // make profile parameter by form controls states
  nTimeout := cbTimeout.ItemIndex;

  if ( nTimeout < 0 ) then
    nTimeout := 0;

  nGain := cbGain.ItemIndex;

  if ( nGain < 0 ) then
    nGain := 0;

  nThreshold := cbThreshold.ItemIndex;

  if ( nThreshold < 0 ) then
    nThreshold := 0;

  nIntegrTime := cbIntegrTime.ItemIndex;

  if ( nIntegrTime < 0 ) then
    nIntegrTime := 0;

  // set profile parameters from dialog
  CMOFPDevProfile.CMDPStrPar1 :=
  N_CMV_IntToStrNorm( nThreshold, 2 ) +
  N_CMV_IntToStrNorm( nGain,      3 ) +
  N_CMV_IntToStrNorm( nTimeout,   2 ) +
  N_CMV_CheckBoxToStr( cbFilter ) +
  N_CMV_IntToStrNorm( nIntegrTime, 2 ) +
  IntToStr( cbCorrMode.ItemIndex );
  N_Dump1Str( 'Trident >> Setup Button Ok Click' );
end; // procedure TN_CMCaptDev11aForm.bnOKClick

//**************************************** TN_CMCaptDev11aForm.bnResetClick ***
// Button "Reset to default values" click event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev11aForm.bnResetClick( Sender: TObject );
begin
  // Reset parameters to default values
  // Threshold = 50
  // Gain      = 1
  // Timeout   = 600 sec
  // Integration Time = 500 ms
  cbThreshold.ItemIndex  := 5;
  cbGain.ItemIndex       := 0;
  cbTimeout.ItemIndex    := 9;
  cbIntegrTime.ItemIndex := 0;
  N_Dump1Str( 'Trident >> Setup Button Reset Click' );
end; // procedure TN_CMCaptDev11aForm.bnResetClick

//**************************************** TN_CMCaptDev11aForm.FormActivate ***
// Form Activate event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev11aForm.FormActivate( Sender: TObject );
begin
  N_Dump2Str( 'TN_CMCaptDev11aForm.FormActivate start' );
  inherited;
  N_CMV_USBReg( Self.Handle, N_CMCDServObj11.USBHandle );
  N_Dump2Str( 'TN_CMCaptDev11aForm.FormActivate fin' );
end; // procedure TN_CMCaptDev11aForm.FormActivate

//******************************************* TN_CMCaptDev11aForm.FormClose ***
// Form Close event handle
//
//     Parameters
// Sender - sender object
// Action - Close Action
//
procedure TN_CMCaptDev11aForm.FormClose( Sender: TObject;
                                         var Action: TCloseAction);
begin
  N_Dump2Str( 'TN_CMCaptDev11aForm.FormClose start' );
  N_CMV_USBUnreg( N_CMCDServObj11.USBHandle );
  inherited;
  N_Dump2Str( 'TN_CMCaptDev11aForm.FormClose fin' );
end; // procedure TN_CMCaptDev11aForm.FormClose

//************************************* TN_CMCaptDev11aForm.TimerCheckTimer ***
// Timer handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev11aForm.TimerCheckTimer( Sender: TObject );
begin
  N_CMCDServObj11.TridentOnTimer( nil, Self );
end; // procedure TN_CMCaptDev11aForm.TimerCheckTimer

end.
