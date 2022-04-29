unit N_CMVideoResF;
// Interface for waiting for a video device to connect

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0, IniFiles, K_CLib0, N_Lib0,
  N_Video4, DirectShow9, N_CMVideoProfileF;

type TN_CMVideoResForm = class( TN_BaseForm )   // Cancel button
  bnOK:     TButton;
    TimerCheck: TTimer;
    Label1: TLabel;
    Label2: TLabel;

  // ***** events handlers
  procedure bnOKClick         ( Sender: TObject );
  procedure cbAutoClick       ( Sender: TObject );
  procedure cbImageFilterClick( Sender: TObject );
    procedure TimerCheckTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);

  public
    CMOFPDevProfile: TK_PCMDeviceProfile;
    DeviceName: string;
end;


implementation
{$R *.dfm}

uses
  N_CMResF;

//********************************************* TN_CMVideoResForm.bnOKClick ***
// Button "OK" click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMVideoResForm.bnOKClick( Sender: TObject );
begin
end; // procedure TN_CMVideoResForm.bnOKClick

//******************************************* TN_CMVideoResForm.cbAutoClick ***
// CheckBox AutoClick click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMVideoResForm.cbAutoClick( Sender: TObject );
begin
  inherited;
end; // procedure TN_CMVideoResForm.cbAutoClick(Sender: TObject);

//***************************************** TN_CMCaptDev15bForm.cbAutoClick ***
// CheckBox AutoClick click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMVideoResForm.cbImageFilterClick( Sender: TObject );
begin
  inherited;
  // is apply image filter
end; // procedure TN_CMVideoResForm.cbImageFilterClick(Sender: TObject);

//********************************************** TN_CMVideoResForm.FormShow ***
// FormShow event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMVideoResForm.FormShow(Sender: TObject);
var
  c: TBitmap;
begin
  inherited;
  c := TBitmap.Create; // bitmap needs to count a font width
  try // counting and widening a form to fill it with a text
    c.Canvas.Font.Assign(self.Font);

    Width := c.Canvas.TextWidth(Label1.Caption) + 70;
    bnOK.Left := Round(Width/2) - 58;

    Width := c.Canvas.TextWidth(Label2.Caption) + 70;
    if Width > bnOK.Left + 58 then
       bnOK.Left := Round(Width/2) - 58;
  finally
    c.Free;
  end;
end; // procedure TN_CMVideoResForm.FormShow(Sender: TObject);

//*************************************** TN_CMVideoResForm.TimerCheckTimer ***
// Timer that waits for devices
//
//     Parameters
// Sender - sender object
//
procedure TN_CMVideoResForm.TimerCheckTimer(Sender: TObject);
var
  Devices: TStringList;
  IError: Integer;
begin
  inherited;
  Devices := TStringList.Create();

  N_Dump1Str( 'DeviceName = ' + DeviceName );

  // get available devices
  N_DSEnumFilters( CLSID_VideoInputDeviceCategory, '', Devices, IError );

  if Devices.IndexOf(DeviceName) <> -1 then // if the device is found (connected)
  begin
    ModalResult := mrYes; // modal result for N_CMResF
    N_Dump1Str( 'ModalResult := mrYes;' );
    //Close;
  end;
end;
end.
