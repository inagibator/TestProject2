unit K_FCMTwainTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ExtCtrls, StdCtrls, ComCtrls,
  Twain,
  N_Types,
  K_FPathNameFr;

type
  TK_FormCMTwainTest = class(TN_BaseForm)
    CmBDevices: TComboBox;
    Label1: TLabel;
    RGDataTransferMode: TRadioGroup;
    RGCMSMode: TRadioGroup;
    BtRun: TButton;
    BtClose: TButton;
    StatusBar: TStatusBar;
    Timer: TTimer;
    procedure FormShow(Sender: TObject);
    procedure BtRunClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CmBDevicesChange(Sender: TObject);
    procedure TWAINWndProc( var Msg: TMessage );
    procedure TWAINWndProc2( var Msg: TMsg; var Handled: Boolean );
    procedure RGDataTransferModeClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure BtCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FreeTWGlobObj : Boolean;
    SavedWindowProc : TWndMethod;
    SavedMessageEvent : TMessageEvent;
    ImageCounter : Integer;
    ModalForm : TForm;
    CurWH : THandle;
    MainFormFlag : Boolean;


    procedure ClearRunContext();
    procedure PrepareTWAINDSM( AHandle : THandle = 0 );
    procedure PrepareTWAINDS();
    procedure AfterImageTransfer();

  public
    { Public declarations }
    procedure OnUHException    ( Sender: TObject; E: Exception );
  end;

var
  K_FormCMTwainTest: TK_FormCMTwainTest;

implementation

{$R *.dfm}

uses K_CLib0, K_CM0, K_CMTWAIN, K_UDC,
N_Lib0, N_CML2F;

type TK_TWAIN1Tmp = record
  TTA1: Array [0..99] of Byte;
  event: TW_EVENT;
  TTA2: Array [0..99] of Byte;
  AppMsg: TMsg;
  TTA3: Array [0..99] of Byte;
end; // type TK_TWAIN1Tmp = record

var K_TWAIN1Tmp : TK_TWAIN1Tmp;


//********************************************* TK_FormCMTwainTest.FormShow ***
// Form Show Event Handler
//
procedure TK_FormCMTwainTest.FormShow(Sender: TObject);
begin
  N_Dump1Str( 'TK_FormCMTwainTest.FormShow start' );

  MainFormFlag := Application.MainForm = self;

  if K_CMSReservedSpaceHMem <> 0 then
  begin
    N_Dump2Str( '!!!MemFreeSpace reserved free' );
    Windows.GlobalFree( K_CMSReservedSpaceHMem );
    K_CMSReservedSpaceHMem := 0;
  end;

  SavedWindowProc := WindowProc;
  SavedMessageEvent := Application.OnMessage;

  FreeTWGlobObj := K_TWGlobObj = nil;
  if FreeTWGlobObj then
    K_TWGlobObj := TK_TWGlobObj.Create();

  if not K_CMBuildTwainDevicesList( CmBDevices.Items ) then
    StatusBar.SimpleText := 'TWAIN errors';

  if CmBDevices.Items.Count > 0 then
    CmBDevices.ItemIndex := 0;

  BtRun.Enabled := CmBDevices.ItemIndex >= 0;

  if BtRun.Enabled then CmBDevicesChange(Sender);
  N_Dump1Str( 'TK_FormCMTwainTest.FormShow fin' );

end; // TK_FormCMTwainTest.FormShow

//******************************************* TK_FormCMTwainTest.BtRunClick ***
// BtRun Click Event Handler
//
procedure TK_FormCMTwainTest.BtRunClick(Sender: TObject);
begin
  Timer.Enabled := TRUE; // Activate DS Interface Run

  if RGCMSMode.ItemIndex = 0 then
  begin // Mode 1
    CurWH := Self.Handle;
    WindowProc := TWAINWndProc;
  end
  else
  begin // Mode 2
    CurWH := Application.Handle;
    Application.OnMessage := TWAINWndProc2;
    // Additional Modal Form is needed if Aplication is window which is recieving TWAIN events
    ModalForm := TForm.Create( Application );
    ModalForm.BorderIcons := [];
    ModalForm.BorderStyle := bsNone;
    ModalForm.BorderWidth := 0;
    ModalForm.Left := 0;
    ModalForm.Top := 0;
    ModalForm.Width := 1;
    ModalForm.Height := 1;
    ModalForm.ShowModal();
  end;
end; // TK_FormCMTwainTest.BtRunClick

//*************************************** TK_FormCMTwainTest.FormCloseQuery ***
// Form Close Query Event Handler
//
procedure TK_FormCMTwainTest.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  N_Dump1Str( 'TK_FormCMTwainTest.FormCloseQuery start' );
  ClearRunContext();
  if FreeTWGlobObj then
    FreeAndNil(K_TWGlobObj);
  inherited;
end; // TK_FormCMTwainTest.FormCloseQuer

//************************************* TK_FormCMTwainTest.CmBDevicesChange ***
// CmBDevices Change Event Handler
//
procedure TK_FormCMTwainTest.CmBDevicesChange(Sender: TObject);
var
  Str : string;
  ModeInd : Integer;
begin
  N_Dump2Str( 'TK_FormCMTwainTest.CmBDevicesChange start >>' + CmBDevices.Text );
  PrepareTWAINDSM();
  if K_TWGlobObj.TWGRetCode <> TWRC_SUCCESS then
  begin
    Str := 'TWAIN Error detected >> '#13#10'"' + K_TWGlobObj.TWGErrorStr  + '".';
    K_CMShowMessageDlg( Str, mtWarning );
    Exit;
  end;

  K_TWGlobObj.TWGDSName := N_StringToAnsi(CmBDevices.Text);

  K_TWGlobObj.TWGDSOpened := FALSE;
  PrepareTWAINDS();
  if K_TWGlobObj.TWGRetCode = TWRC_SUCCESS then
    K_TWGlobObj.TWGInitModes()
  else
  begin
    Str := Format( 'Capture device "%s" is not plugged in.', [CmBDevices.Text] );
    K_CMShowMessageDlg( Str, mtWarning );
    StatusBar.SimpleText := Str;
  end;

//K_TWGlobObj.TWGDSTransfModeNative := FALSE;
{
  if not K_TWGlobObj.TWGDSTransfModeNative then
  begin
    RGDataTransferMode.Enabled := FALSE;
    RGCMSMode.Enabled := FALSE;
    BtRun.Enabled := FALSE;
    N_Dump2Str( 'TK_FormCMTwainTest.CmBDevicesChange start' );
  end
  else
}
  begin
    RGDataTransferMode.Enabled := TRUE;
    RGCMSMode.Enabled := TRUE;

    ModeInd := RGDataTransferMode.Items.IndexOf('disk file');
    if not K_TWGlobObj.TWGDSTransfModeFile and (ModeInd >= 0) then
      RGDataTransferMode.Items.Delete(ModeInd)
    else
    if K_TWGlobObj.TWGDSTransfModeFile and (ModeInd < 0) then
      RGDataTransferMode.Items.Add('disk file');

    ModeInd := RGDataTransferMode.Items.IndexOf('memory buffer');
    if not K_TWGlobObj.TWGDSTransfModeMem and (ModeInd >= 0) then
      RGDataTransferMode.Items.Delete(ModeInd)
    else
    if K_TWGlobObj.TWGDSTransfModeMem and (ModeInd < 0) then
      RGDataTransferMode.Items.Add('memory buffer');

    if RGDataTransferMode.ItemIndex >= RGDataTransferMode.Items.Count then
      RGDataTransferMode.ItemIndex := RGDataTransferMode.Items.Count - 1;

    if RGDataTransferMode.ItemIndex < 0 then
      RGDataTransferMode.ItemIndex := 0;

    RGDataTransferModeClick(Sender);

    BtRun.Enabled := TRUE;
  end;
  
end; // TK_FormCMTwainTest.CmBDevicesChange


//******************************************** TK_FormCMTwainTest.TWAINWndProc ***
// Own Window Proc that is used instead of standart Self.WindowProc
// for handling TWAIN messages
//
//     Parameters
// Msg - Windows Message
//
procedure TK_FormCMTwainTest.TWAINWndProc( var Msg: TMessage );
label DefWndProc;
begin
  if (K_TWGlobObj = nil) or K_CMD4WAppFinState then // a precaution
  begin
// Defaut WndProcessing
DefWndProc: // ************
    WndProc( Msg ); // original messages handler/ Is really needed!!!
    Exit;
  end;

  with K_TWGlobObj do
  begin
    // TWAIN messages can occure only if DSM and DS are Opened
    if (not TWGDSMOpened) or (not TWGDSOpened) then goto DefWndProc;

    ZeroMemory( @K_TWAIN1Tmp, SizeOf(K_TWAIN1Tmp) );
    with K_TWAIN1Tmp do
    begin
      event.pEvent := @AppMsg;
      event.TWMessage := 0;

      ZeroMemory( @AppMsg, SizeOf(AppMsg) );
      AppMsg.hwnd    := TWGWinHandle;
      AppMsg.message := Msg.Msg;
      AppMsg.WParam := Msg.WParam;
      AppMsg.LParam := Msg.LParam;
    end;

    if TWGProcEvent( K_TWAIN1Tmp.event ) then
    begin
      if K_TWAIN1Tmp.event.TWMessage = 0 then goto DefWndProc;
    end   // if TWProcEvent( K_TWAIN1Tmp.event ) then
    else
    begin // if not TWProcEvent( K_TWAIN1Tmp.event ) then
    //***** Close Driver UI dialog, close DS and DSM, close Self
      N_Dump1Str( 'Before CloseDS();' );
      TWGCloseDS(); // Close UI dialog, Data Source Manager and Data Source
      StatusBar.SimpleText := 'Device is closed';
      BtRun.Enabled := TRUE;
      ClearRunContext();
    end; // if not TWProcEvent( K_TWAIN1Tmp.event ) then
  end; // with K_TWGlobObj do
end; // procedure TK_FormCMTwainTest.TWAINWndProc

//**************************************** TK_FormCMTwainTest.TWAINWndProc2 ***
// Application.OnMessage handler for handling TWAIN messages
//
//     Parameters
// Msg     - Windows Message
// Handled - if meassage was handled
//
procedure TK_FormCMTwainTest.TWAINWndProc2( var Msg: TMsg; var Handled: Boolean );
var
  TWEvent: TW_EVENT;
//  ProcEventRetCode: TW_UINT16;
//  ProcEventResult : Boolean;
begin
  if K_TWGlobObj = nil then Exit; // a precaution

  with K_TWGlobObj do
  begin

  // TWAIN messages can occure only if DSM and DS are Opened
  if (not TWGDSMOpened) or (not TWGDSOpened) then Exit;

  TWEvent.pEvent    := @Msg;
  TWEvent.TWMessage := 0;
{
  if Msg.message = $201 then // is OK
  begin
    N_Dump1Str( Format( 'TWAINWndProc2: HWND=%x Msg:%x %x %x, MC=%d',
                       [Msg.hwnd, Msg.message,Msg.wParam,Msg.lParam,TWGMessageCounter] ));
    Exit;
  end;
}

  // all messages should be immediatly sent back to Data Source
//  if ((Msg.message=$F)   and (Msg.wParam=0)   and (Msg.lParam=0)) or
//     (Msg.message=$200) or (Msg.message=$201) or (Msg.message=$202) or (Msg.message=$C3C5) or
//     ((Msg.message=$113) and (Msg.wParam=$64) and (Msg.lParam=0))   then

//  if (Msg.message=$F) or (Msg.message=$113) or (Msg.message=$C3C5) then

    if TWGProcEvent( TWEvent ) then
    begin
      if TWEvent.TWMessage <> 0 then
        Handled := True;
    end
    else
    begin
      N_Dump1Str( 'Before CloseDS();' );
      TWGCloseDS(); // Close UI dialog, Data Source Manager and Data Source
      StatusBar.SimpleText := 'Device is closed';
      BtRun.Enabled := TRUE;
      ClearRunContext();
    end;

  end; // with K_TWGlobObj do
end; // TK_FormCMTwainTest.TWAINWndProc2

procedure TK_FormCMTwainTest.ClearRunContext();
begin
  WindowProc := SavedWindowProc;
  Application.OnMessage := SavedMessageEvent;
  if ModalForm = nil then Exit;
  ModalForm.Close();
  ModalForm.Release();
  ModalForm := nil;
end; // procedure TK_FormCMTwainTest.ClearRunContext

procedure TK_FormCMTwainTest.PrepareTWAINDSM( AHandle : THandle = 0 );
begin
  K_TWGlobObj.TWGRetCode := 0;
  N_Dump1Str( format( 'PrepareTWAINDSM start >> Open=%s, NH=%x, CH=%x',
              [N_B2S(K_TWGlobObj.TWGDSMOpened),AHandle,K_TWGlobObj.TWGWinHandle] ) );
  if K_TWGlobObj.TWGDSMOpened and
     ((AHandle = 0) or
      (AHandle = K_TWGlobObj.TWGWinHandle)) then Exit;

  if K_TWGlobObj.TWGDSMOpened then K_TWGlobObj.TWGCloseDS();

  K_TWGlobObj.TWGOpenDSManager( @AHandle );
  N_Dump1Str( format( 'PrepareTWAINDSM after TWGOpenDSManager >> RC=%d CH=%x',
              [K_TWGlobObj.TWGRetCode,K_TWGlobObj.TWGWinHandle] ) );

end; // TK_FormCMTwainTest.PrepareTWAINDSM

procedure TK_FormCMTwainTest.PrepareTWAINDS();
begin
  K_TWGlobObj.TWGRetCode := 0;
  if K_TWGlobObj.TWGDSOpened then Exit;
  K_TWGlobObj.TWGOpenDataSource( );
  N_Dump1Str( format( 'PrepareTWAINDS after TWGOpenDataSource >> N="%s" RC=%d',
                      [N_AnsiToString(K_TWGlobObj.TWGDSName),K_TWGlobObj.TWGRetCode] ) );
end; // TK_FormCMTwainTest.PrepareTWAINDS

procedure TK_FormCMTwainTest.RGDataTransferModeClick(Sender: TObject);
begin
  if RGDataTransferMode.ItemIndex = 0 then
    K_TWGlobObj.TWGDataTransfModeSet := K_twdtmNative
  else
  begin
    if RGDataTransferMode.Items.IndexOf('disk file') = RGDataTransferMode.ItemIndex then
      K_TWGlobObj.TWGDataTransfModeSet := K_twdtmFile
    else
      K_TWGlobObj.TWGDataTransfModeSet := K_twdtmMemory;
  end;
end; // procedure TK_FormCMTwainTest.RGDataTransferModeClick

procedure TK_FormCMTwainTest.AfterImageTransfer;
begin
  if K_TWGlobObj.TWGRetCode <> TWRC_XFERDONE then
  begin
    StatusBar.SimpleText := format( 'ERROR: %s', [K_TWGlobObj.TWGErrorStr] );
    N_Dump1Str( 'Image Transfer Error' );
  end
  else
  begin
    Inc(ImageCounter);
    StatusBar.SimpleText := format( ' %d images are transfered', [ImageCounter] );
    K_TWGlobObj.TWGLastDIBObj.SaveToBMPFormat( K_ExpandFileName(
        format( '(#TmpFiles#)TWAIN_%s_%d.bmp', [K_TWGlobObj.TWGDSName,ImageCounter] ) ) );
    N_Dump2str( 'Image Transfer success >> ' + StatusBar.SimpleText );
  end;

end; // procedure TK_FormCMTwainTest.AfterImageTransfer

procedure TK_FormCMTwainTest.TimerTimer(Sender: TObject);
var
  Str : string;

label
  TWAINError, TWAINCancel, RunContextClear;

begin
  Timer.Enabled := FALSE;
  N_Dump1Str( 'TK_FormCMTwainTest.TimerTimer start' );
  K_TWGlobObj.TWGOnImageTransferedProcObj := AfterImageTransfer;
  ImageCounter := 0;
////////////////////////////
  PrepareTWAINDSM( CurWH );
  if K_TWGlobObj.TWGRetCode <> 0 then goto TWAINError;

  PrepareTWAINDS();
  if K_TWGlobObj.TWGRetCode <> 0 then
  begin
    Str := Format( 'Capture device "%s" is not plugged in.', [CmBDevices.Text] );
    K_CMShowMessageDlg( Str, mtWarning );
    StatusBar.SimpleText := Str;
    goto TWAINCancel;
  end; // if TWGRetCode <> 0 then

//??? 2017-09-04 BtRun.Enabled := TWRC_SUCCESS = K_TWGlobObj.TWGShowDSUI();
  BtRun.Enabled := TWRC_SUCCESS <> K_TWGlobObj.TWGShowDSUI();
//  BtRun.Enabled := K_TWGlobObj.TWGShowDSUI();
  if BtRun.Enabled then goto RunContextClear; // Device UI show errors

  Str := Format( 'Capture device "%s" UI is opend.', [CmBDevices.Text] );
  StatusBar.SimpleText := Str;
  N_Dump1Str( 'TK_FormCMTwainTest.TimerTimer >> ' + Str );

  Exit; // Device is started

  TWAINError: //****************************
  Str := 'TWAIN Error detected >> '#13#10'"' + K_TWGlobObj.TWGErrorStr  + '".';
  K_CMShowMessageDlg( Str, mtWarning );

  TWAINCancel: //***************************
  K_TWGlobObj.TWGCloseDS(); // Close UI dialog, Data Source Manager and Data Source

RunContextClear : //*********************************
  ClearRunContext();

end; // procedure TK_FormCMTwainTest.TimerTimer(Sender: TObject);


procedure TK_FormCMTwainTest.OnUHException(Sender: TObject; E: Exception);
var
  hTaskBar: THandle;
begin
  try
    // Show TaskBar if Exception raised while TaskBar  is hide
    hTaskbar := FindWindow( 'Shell_TrayWnd', nil );
    if hTaskbar <> 0 then
    begin
      EnableWindow( HTaskBar, TRUE );        // Enabled TaskBar
      ShowWindow( hTaskBar, SW_SHOWNORMAL ); // Show TaskBar
    end;

    K_CMShowMessageDlg( ' Media Suite TWAIN is terminated by exception:' +
         #13#10 + E.Message, mtError, [], false,
        'Media Suite TWAIN' );
    N_Dump1Str( 'Application CMTwainTest.UHException FlushCounters' + N_GetFlushCountersStr() );
    N_LCExecAction( -1, lcaFlush );

    K_CMEDAccess.Free;
  finally
    ExitProcess( 10 );
  end;
end; // procedure TK_FormCMTwainTest.OnUHException

procedure TK_FormCMTwainTest.BtCloseClick(Sender: TObject);
begin
  if fsModal in FormState then Exit;
  Close();
end;

procedure TK_FormCMTwainTest.FormDestroy(Sender: TObject);
begin
  if MainFormFlag then
    K_SaveMemIniToFile( N_CurMemIni );

  inherited;

end;

end.
