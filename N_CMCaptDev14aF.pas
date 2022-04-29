unit N_CMCaptDev14aF;
// Hamamatsu device settings dialog
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2014.07.03 Thread Code redesign by Alex Kovalev

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, StdCtrls, ExtCtrls, Forms, Dialogs, ShlObj,
  K_CM0, K_CLib0,
  N_Types, N_Lib1, N_BaseF, N_CMCaptDev14F, N_CMCaptDev0;

type TN_CMCaptDev14aForm = class( TN_BaseForm )
    bnCancel: TButton;   // Cancel button
    bnOK:     TButton;
    StatusShape:    TShape;
    StatusLabel:    TLabel;
    lbSNName: TLabel;
    lbSNValue: TLabel;
    cbAC: TCheckBox;
    lbIntTime: TLabel;
    cbIntTime: TComboBox;
    cbFilter: TCheckBox;
    procedure bnOKClick ( Sender: TObject );
    procedure cbACClick(Sender: TObject);
    procedure FormActivate(Sender: TObject); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure OnDeviceChange( var Msg: TMessage ); message WM_DEVICECHANGE;

  public
    CMOFPDevProfile: TK_PCMDeviceProfile; // Pointer to Profile
end;

implementation

uses
  N_CMCaptDev14;

{$R *.dfm}

//******************************************** TN_CMCaptDev14aForm.bnOKClick ***
// Button "OK" click event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev14aForm.bnOKClick( Sender: TObject );
begin
  // set profile parameters from dialog
  CMOFPDevProfile.CMDPStrPar1 := N_CMCDServObj14.SetupFormToProfile( Self );
  N_Dump1Str( 'Hamamatsu >> Setup Button Ok Click' );
end; // procedure TN_CMCaptDev14aForm.bnOKClick

//******************************************* TN_CMCaptDev14aForm.cbACClick ***
// Checkbox "AC" click event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev14aForm.cbACClick( Sender: TObject );
begin
  inherited;
  cbIntTime.Enabled := cbAC.Checked;
end; // procedure TN_CMCaptDev14aForm.cbACClick

//**************************************** TN_CMCaptDev14aForm.FormActivate ***
// Checkbox "AC" click event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev14aForm.FormActivate( Sender: TObject );
begin
  N_Dump2Str( 'TN_CMCaptDev14aForm.FormActivate start' );
  inherited;
  N_CMV_USBReg( Self.Handle, N_CMCDServObj14.USBHandle );
  N_Dump2Str( 'TN_CMCaptDev14aForm.FormActivate fin' );
end; // procedure TN_CMCaptDev14aForm.FormActivate

//******************************************* TN_CMCaptDev14aForm.FormClose ***
// Checkbox "AC" click event handle
//
//     Parameters
// Sender - sender object
// Action - Close Action
//
procedure TN_CMCaptDev14aForm.FormClose( Sender: TObject;
                                         var Action: TCloseAction );
begin
  N_Dump2Str( 'TN_CMCaptDev14aForm.FormClose start' );
  N_CMV_USBUnreg( N_CMCDServObj14.USBHandle );
  inherited;
  N_Dump2Str( 'TN_CMCaptDev14aForm.FormClose fin' );
end; // procedure TN_CMCaptDev14aForm.FormClose

//************************************** TN_CMCaptDev14aForm.OnDeviceChange ***
// Windows message from Hamamatsu driver
//
//     Parameters
// Msg - incoming Windows message
//
procedure TN_CMCaptDev14aForm.OnDeviceChange( var Msg: TMessage );
begin
  N_CMCDServObj14.ProcessUSB( Msg, nil, Self );
end; // procedure TN_CMCaptDev14aForm.OnDeviceChange

end.
