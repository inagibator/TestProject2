unit N_CMCaptDev13aF;
// Apixia device settings dialog
// 2014.02.21 created by Valery Ovechkin
// 2014.03.20 Fixed USB event listener by Valery Ovechkin
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2014.09.15 Fixed File exceptions processing ( like i/o 32, etc. ) by Valery Ovechkin
// 2014.09.15 Standartizing ( All functions parameters name starts from 'A' ) by Valery Ovechkin

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, StdCtrls, ExtCtrls, Forms, Dialogs, ShlObj,
  K_CM0, K_CLib0,
  N_Types, N_Lib1, N_BaseF, N_CMCaptDev13F, N_CMCaptDev0;

type TN_CMCaptDev13aForm = class( TN_BaseForm )
    bnCancel: TButton;   // Cancel button
    bnOK:     TButton;
    StatusShape:    TShape;
    StatusLabel:    TLabel;
    lbHorOffset:    TLabel;
    lbWidth:        TLabel;
    lbHeight:       TLabel;
    lbWidthValue:   TLabel;
    lbHeightValue:  TLabel;
    lbWidthAdjust:  TLabel;
    lbHeightAdjust: TLabel;
    cbHorOffset: TComboBox;
    cbWidth:     TComboBox;
    cbHeight:    TComboBox;
    procedure bnOKClick ( Sender: TObject );
    procedure ApixiaOnCommand      ( var AMsg: TMessage ); message PSP_MSG_COMMAND;
    procedure ApixiaOnDeviceChange ( var AMsg: TMessage ); message WM_DEVICECHANGE;
    procedure FormActivate         ( Sender: TObject ); override;
    procedure FormClose            ( Sender: TObject; var Action: TCloseAction ); override;

  public
    CMOFPDevProfile: TK_PCMDeviceProfile; // Pointer to Profile
    ThisForm:        TN_CMCaptDev13aForm; // Pointer to this form
end;

const
  // message types
  PSP_MSG_COMMAND  = WM_USER + 89; // Message from Apixia driver ( reply )

implementation

uses
  N_CMCaptDev13;

{$R *.dfm}

//******************************************** TN_CMCaptDev13aForm.bnOKClick ***
// Button "OK" click event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev13aForm.bnOKClick( Sender: TObject );
var
  nOffset, nWidth, nHeight: Integer;
begin
  // make profile parameter by form controls states
  nOffset := cbHorOffset.ItemIndex;

  if ( 0 > nOffset ) then
    nOffset := 0;

  nWidth := cbWidth.ItemIndex;

  if ( 0 > nWidth ) then
    nWidth := 0;

  nHeight := cbHeight.ItemIndex;

  if ( 0 > nHeight ) then
    nHeight := 0;

  // set profile parameters from dialog
  CMOFPDevProfile.CMDPStrPar1 :=
  N_CMV_IntToStrNorm( nOffset, 2 ) +
  N_CMV_IntToStrNorm( nWidth,  2 ) +
  N_CMV_IntToStrNorm( nHeight, 2 );

  N_Dump1Str( 'Apixia >> Setup Button Ok Click' );
end; // procedure TN_CMCaptDev13aForm.bnOKClick

//**************************************** TN_CMCaptDev13aForm.FormActivate ***
// form activate event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev13aForm.FormActivate( Sender: TObject );
begin
  inherited;
  N_CMCDServObj13.ShowStatus( nil, ThisForm );
  N_CMV_USBReg( ThisForm.Handle, N_CMCDServObj13.USBHandle );
  N_CMCDServObj13.StartDriver( ThisForm.Handle );
  N_CMCDServObj13.ShowStatus( nil, ThisForm );
end;

procedure TN_CMCaptDev13aForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  N_CMV_USBUnreg( N_CMCDServObj13.USBHandle );
  inherited;
end;

// procedure TN_CMCaptDev13aForm.FormActivate

//************************************* TN_CMCaptDev13aForm.ApixiaOnCommand ***
// Windows message from Apixia driver ( reply )
//
//     Parameters
// AMsg - incoming Windows message
//
procedure TN_CMCaptDev13aForm.ApixiaOnCommand( var AMsg: TMessage );
var
  WP, LP: Integer;
begin
  WP := Integer( AMsg.WParam );
  LP := Integer( AMsg.LParam );
  N_CMCDServObj13.SetStatus( WP, LP );
  N_CMCDServObj13.ShowStatus( nil, ThisForm );

  N_Dump1Str( 'Apixia >> ExtMessage( Setup ): WP = ' + IntToStr( WP ) +
              ', LP = ' + IntToStr( LP ) );

  if ( N_CMCDServObj13.DevStatus = tsGoodHandle) then
    N_CMCDServObj13.SendExtMsg( PSP_OPEN, 0, 0, 0 ) // try open
  else if ( N_CMCDServObj13.DevStatus = tsOpened ) then
  begin
    lbWidthValue.Caption  := IntToStr( WP );
    lbHeightValue.Caption := IntToStr( LP );
  end;

end; // procedure TN_CMCaptDev13aForm.ApixiaOnCommand

//******************************** TN_CMCaptDev13aForm.ApixiaOnDeviceChange ***
// Windows message from Apixia driver
//
//     Parameters
// AMsg - incoming Windows message
//
procedure TN_CMCaptDev13aForm.ApixiaOnDeviceChange( var AMsg: TMessage );
begin
  N_CMCDServObj13.ProcessUSB( AMsg, nil, ThisForm );
end; // procedure TN_CMCaptDev13aForm.ApixiaOnDeviceChange

end.
