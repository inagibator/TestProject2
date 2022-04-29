unit N_CMTWAIN1F;
// TWAIN Mode #1 (from 2.801 CMS Build)
//
// 1) Not visible Modal Form is created before showing
//    TWAIN Driver User Interface window to prevent any actions with
//    MainForm while TWAIN Driver window is active
//    ("Not visible" means one pixel size in upper left screen corner)
// 2) In mode #1 TWAIN messages are processed by this "not visible" special form
//    (in mode #2 TWAIN messages are processed by Application window)
// 3) TWAIN Mode #1 is implemented as TN_TWGlobObj1 class

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  Twain,
  N_Types, N_Gra2,
  K_CM0;

type TN_CMTWAIN1Form = class( TForm )
    Timer: TTimer;
    TimerSys: TTimer;
    Edit1: TEdit;

    procedure FormShow      ( Sender: TObject );
    procedure OnTimerOld    ( Sender: TObject );
    procedure OnTimer       ( Sender: TObject );
    procedure TimerSysTimer ( Sender: TObject );
    procedure TWAINWndProc  ( var Msg: TMessage );

  public
    InsideOnTimer2: Boolean;
    TimerSysCounter: integer;
    DriverHWND: THandle;
    SelfHWND: THandle;
end; // type TN_CMTWAIN1Form = class( TForm )

type TN_TWGlobObj1 = class( TObject ) // my TWAIN Global object for TWAIN mode #1
  TWGOnImagesReadyProcObj: TN_NoParamsProcObj;
  TWGDSMOpened:   boolean; // Data Source Manager is currently Opened
  TWGDSOpened:    boolean; // Data Source is currently Opened
  TWGDSEnabled:   boolean; // Data Source is currently Enabled
  TWGAcquiredOK:  boolean; // Some Images are Acquired and Capturing process should be finished
  TWGOpCanceled:  boolean; // No Images are Acquired and Capturing process should be finished
  TWGDLLHandle:   HMODULE; // TWAIN_32.DLL Handle
  TWGRetCode:   TW_UINT16; // TWAIN and Own Return Code (TWGRetCode=0 means OK, but TWGOpCanceled may be True)
  TWGErrorStr:     string; // Error description string (for User Interface) if TWGRetCode <> 0

  TWGDSMEntry: TDSMEntryProc; // DSM_Entry procedure in TWAIN_32.DLL

  TWGAppID:   TW_IDENTITY; // Application IDENTITY
  TWGDSID:    TW_IDENTITY; // Data Source IDENTITY
  TWGSTATUS:  TW_STATUS;   //

  TWGDIBs: TN_DIBObjArray; // Acquired Images as Array of TN_DIBObject
  TWGNumDibs:     integer; // Number of Acquired Images in TWGDIBs Array
  TWGMessageCounter: integer;
  TWGTWAINModalForm: TN_CMTWAIN1Form;
  TWGDSName:  AnsiString;  // TWAIN Driver Name (TW_IDENTITY.ProductName)
  TWGWinHandle: THandle;   // Window Handle for processing TWAIN messages

  constructor Create ();
  destructor Destroy (); override;

  procedure CloseDS           ();
  procedure TWGHandleMessage1_NotUsed ( var Msg: TMsg; var Handled: Boolean );
  function  TWGFix32ToDouble  ( AFix32Value: TW_FIX32 ): Double;
  procedure TWGCall           ( pDest: pTW_IDENTITY; DG: TW_UINT32; DAT: TW_UINT16;
                                                  MSG: TW_UINT16; pData: TW_MEMREF );
  procedure TWGOpenDSManager    ( APWinHandle: TW_MEMREF );
  procedure TWGOpenDataSource   ( ADSName: AnsiString );
  procedure TWGGetDataSources   ( ADSNames: TStrings );
  procedure TWGNativeTransfer   ();
  procedure TWGGetDIBs          ();
  procedure TWGStartDialog      ();
end; // type TN_TWGlobObj1 = class( TObject ) // my TWAIN Global object


type TN_TWAIN1Tmp = record
  TTA1: Array [0..99] of Byte;
  event: TW_EVENT;
  TTA2: Array [0..99] of Byte;
  AppMsg: TMsg;
  TTA3: Array [0..99] of Byte;
end; // type TN_TWAIN1Tmp = record


//*************************  Global Procedures  ***************

procedure N_CMGetSlidesFromTWAIN1 ( APCMTwainProfile: TK_PCMTwainProfile );

const
  TWRC_NoDLL      =  $8001; // failed to load TWAIN_32.DLL
  TWRC_NoDSMEntry =  $8002; // failed to get DSM_Entry in TWAIN_32.DLL

  N_TWAIN_DLL_Name: String     = 'TWAIN_32.DLL';
  N_DSM_Entry_Name: AnsiString = 'DSM_Entry';

var
  N_TWGlobObj1: TN_TWGlobObj1;

implementation
uses

  N_Lib0, N_Lib1, N_InfoF, N_CMTWAIN, {N_CMMain5F,}
  N_CMResF, N_CMVideo2F, N_CML2F, N_CM1;

{$R *.dfm}

var
  N_TWAIN1Tmp: TN_TWAIN1Tmp;

procedure TN_CMTWAIN1Form.FormShow( Sender: TObject );
// to freeze Parent Form (MainForm), Driver Dialog should be called after
// the end of FormShow handler, so it is implemented in OnTimer handler
// TN_CMTWAIN1Form.OnTimer2 (TN_CMTWAIN1Form.OnTimer is not used now)
begin
  //  N_TWGlobObj1.TWGGetDIBs(); // does not work!
  N_Dump2Str( 'TN_CMTWAIN1Form.FormShow - just enable Timer' );

  Timer.Enabled := True; // just to call N_TWGlobObj1.TWGGetDIBs() once in TN_CMTWAIN1Form.OnTimer2
end; // procedure TN_CMTWAIN1Form.FormShow

procedure TN_CMTWAIN1Form.OnTimerOld( Sender: TObject );
// Old variant, now not used
begin
  N_Dump1Str( 'TN_CMTWAIN1Form.OnTimer' );
  Timer.Enabled := False;
  N_i1 := N_TWGlobObj1.TWGWinHandle; // N_TWGlobObj1.TWGTWAINModalForm.Handle
  N_i2 := Handle;
  Assert( N_i1 = N_i2, 'Bad win handle!' );

  N_TWGlobObj1.TWGGetDIBs(); // create TWAIN driver dialog, get images and save Slides
end; // procedure TN_CMTWAIN1Form.OnTimerOld

procedure TN_CMTWAIN1Form.OnTimer( Sender: TObject );
// Timer was enabled in FormShow to do all TWAIN things:
// - open TWAIN (TWGOpenDSManager, TWGOpenDataSource)
// - call TWGGetDIBs
// - Close TWAIN
// - Close Form (Close Self)
var
  Str: string;
  label TWAINError, TWAINCancel;
begin
  N_Dump1Str( 'Start TN_CMTWAIN1Form.OnTimer' );
  Timer.Enabled := False; // process OnTimer event only once
  SelfHWND := Windows.GetActiveWindow();

  if InsideOnTimer2 then // a precaution
  begin
    N_Dump1Str( 'Error: Second call to OnTimer2' );
    Exit;
  end;

  InsideOnTimer2 := True;

  //***** Create TWGTWAINModalForm - not visible Modal form to deactivate
  //      MainForm controls while showing TWAIN driver dialog
  //      All acquiring work is implemented in ... TN_CMTWAIN1Form.TWAINWndProc;

  with N_TWGlobObj1, TWGTWAINModalForm do
  begin
    WindowProc := TN_CMTWAIN1Form(TWGTWAINModalForm).TWAINWndProc;

    TWGWinHandle := TWGTWAINModalForm.Handle; //???
    TWGOpenDSManager( @TWGWinHandle );
    N_Dump1Str( 'after TWGOpenDSManager' );

    if TWGRetCode <> 0 then goto TWAINError;

//    TWGDSName := AnsiString(CMDPProductName);
    TWGOpenDataSource( TWGDSName );
    N_Dump1Str( 'after TWGOpenDataSource "' + N_AnsiToString(TWGDSName) + '"' );

    if TWGRetCode <> 0 then
    begin
      // N_CML2Form.LLLNotPluggedIn1_c = 'Capture device "%s"/#is not plugged in.'
      Str := Format( N_CML2Form.LLLNotPluggedIn1.Caption, [N_AnsiToString(TWGDSName)] );
      K_CMShowMessageDlg( Str, mtWarning );
      goto TWAINCancel;
    end; // if TWGRetCode <> 0 then

    N_TWGlobObj1.TWGGetDIBs(); // create TWAIN UI (driver dialog), get images and save Slides
    N_Dump1Str( 'after TWGGetDIBs' );

    if TWGRetCode = TWRC_CANCEL then
      goto TWAINCancel;

    N_Dump1Str( 'Finish TN_CMTWAIN1Form.OnTimer OK' );
    Exit;

    TWAINError: //****************************
    Str := 'TWAIN Error detected >> '#13#10'"' + TWGErrorStr  + '".';
    K_CMShowMessageDlg( Str, mtWarning );

    TWAINCancel: //***************************
    N_Dump1Str( Str );
    CloseDS(); // Close UI dialog, Data Source Manager and Data Source
//    FreeAndNil( N_TWGlobObj1 );
    TWGTWAINModalForm.Close; // Close Self (Invisible modal window
    N_Dump1Str( 'TWAIN Canceled' );
  end; // with N_TWGlobObj1, TWGTWAINModalForm do
  N_CMResForm.CMRFTwainMode := False;

//  TWAINFin : //*********************************
  N_CMResForm.CMRFTwainMode := False;
end; // procedure TN_CMTWAIN1Form.OnTimer

procedure TN_CMTWAIN1Form.TimerSysTimer( Sender: TObject );
// Timer only for Canon driver - activate driver Dialog periodicaly,
// otherwise TWAINWndProc did not receive (or driver did not send) needed messages
begin
  Inc( TimerSysCounter );
//  Exit;

  if TimerSysCounter = 1 then
    DriverHWND := Windows.GetActiveWindow();

  Windows.SetActiveWindow( SelfHWND );
  Windows.SetActiveWindow( DriverHWND );
  N_Dump1Str( 'TimerSysTimer' );
  Exit;

//  Windows.SendMessage( N_h1, WM_SETFOCUS, 0, 0 );
//  Windows.SendMessage( N_h1, WM_ACTIVATE, 0, 0 );
//  Windows.SendMessage( N_h1, WM_KEYDOWN, VK_SHIFT, 0 );
//  Windows.SendMessage( N_h1, WM_KEYDOWN, VK_SPACE, 1 );
//  Exit;

//  N_h2 := Windows.SetFocus( N_h1 );

//  Windows.SetActiveWindow( N_CM_MainForm.CMMCurFMainForm.Handle );
//  Windows.SetActiveWindow( N_h1 );
//  Exit;

  if (TimerSysCounter and $01) <> 0 then
  begin
    Windows.SetActiveWindow( DriverHWND );
//    Windows.SetFocus( DriverHWND );
//    Windows.SendMessage( DriverHWND, WM_SETFOCUS, 0, 0 );
//    N_ip := Mouse.CursorPos;
//    Mouse.CursorPos := Point(0,0);
//    TimerSys.Interval := 5;
  end else
  begin
    Windows.SetActiveWindow( SelfHWND );
//    Windows.SetFocus( SelfHWND );
//    Windows.SendMessage( SelfHWND, WM_KEYDOWN, Integer(Char('0')), 1 );
//    Windows.SendMessage( SelfHWND, WM_KEYUP, Integer(Char('0')), 1 );

//    Windows.SendMessage( SelfHWND, WM_SETFOCUS, 0, 0 );
//    Mouse.CursorPos := N_ip;
//    TimerSys.Interval := 400;
  end;

//  Application.ProcessMessages;
//  Sleep( 1000 );
//  Application.ProcessMessages;
//  Mouse.CursorPos := N_ip;

//  Screen.Cursor.Position := Point(0,0);
  with N_TWGlobObj1 do
  begin
//    TWGCall( nil, DG_CONTROL, DAT_STATUS, MSG_GET, @TWGSTATUS );
//    N_Dump1Str( Format( 'TimerSysTimer Scanner status=%d', [TWGSTATUS.ConditionCode] ) );
  end;
end; // procedure TN_CMTWAIN1Form.TimerSysTimer

//******************************************** TN_CMTWAIN1Form.TWAINWndProc ***
// Own Window Proc that is used instead of standart Self.WindowProc
// for handling TWAIN messages
//
//     Parameters
// Msg - Windows Message
//
procedure TN_CMTWAIN1Form.TWAINWndProc( var Msg: TMessage );
var
//  event: TW_EVENT;
  pending: TW_PENDINGXFERS;
//  AppMsg: TMsg;
  Label CloseTWAIN;
begin
  if (N_TWGlobObj1 = nil) or K_CMD4WAppFinState then // a precaution
  begin
    WndProc( Msg ); // original messages handler/ Is really needed!!!
    Exit;
  end;

  with N_TWGlobObj1 do
  begin

  // TWAIN messages can occure only if DSM and DS are Opened
  if (not TWGDSMOpened) or (not TWGDSOpened) then
  begin
    WndProc( Msg ); // original messages handler
    Exit;
  end;

  ZeroMemory( @N_TWAIN1Tmp, SizeOf(N_TWAIN1Tmp) );
  with N_TWAIN1Tmp do
  begin
    event.pEvent := @AppMsg;
    event.TWMessage := 0;

    ZeroMemory( @AppMsg, SizeOf(AppMsg) );
    AppMsg.hwnd    := TWGWinHandle;
    AppMsg.message := Msg.Msg;
    AppMsg.WParam := Msg.WParam;
    AppMsg.LParam := Msg.LParam;
  end;

  Inc( TWGMessageCounter ); // for dump only

  if N_CMTWAIN_DebugMode then // Use Dump1
    N_Dump1Str( Format( 'TN_CMTWAIN1Form.TWAINWndProc: Msg:%x %x %x, MC=%d wh=%x, %x',
       [Msg.Msg,Msg.wParam,Msg.lParam, TWGMessageCounter,TWGWinHandle,Handle] ))
  else // Use Dump2
    N_Dump2Str( Format( 'TN_CMTWAIN1Form.TWAINWndProc: Msg:%x %x %x, MC=%d wh=%x, %x',
       [Msg.Msg,Msg.wParam,Msg.lParam, TWGMessageCounter,TWGWinHandle,Handle] ));

  // all messages should be immediatly sent back to Data Source
  TWGCall( @TWGDSID, DG_CONTROL, DAT_EVENT, MSG_PROCESSEVENT, @N_TWAIN1Tmp.event );

  if N_CMTWAIN_DebugMode then // Use Dump1
    N_Dump1Str( Format( 'After TWGCall, TWGRetCode=%d, TWMessage=%d', [TWGRetCode, N_TWAIN1Tmp.event.TWMessage] ))
  else // Use Dump2
    N_Dump2Str( Format( 'After TWGCall, TWGRetCode=%d, TWMessage=%d', [TWGRetCode, N_TWAIN1Tmp.event.TWMessage] ));

  if N_TWAIN1Tmp.event.TWMessage = 0 then // not TWAIN message
  begin
//    N_Dump1Str( 'Before1 WndProc' );
//    N_Dump1Str( 'Before2 WndProc' );
    WndProc( Msg ); // original messages handler
//    N_Dump1Str( 'After1 WndProc' );
//    N_Dump1Str( 'After2 WndProc' );
    Exit;
  end;

  //***** Here: event.TWMessage <> 0 process TWAIN message
{
  Generic messages may be used with any of several DATs:
  MSG_GET               = $0001;  Get one or more values
  MSG_GETCURRENT        = $0002;  Get current value
  MSG_GETDEFAULT        = $0003;  Get default (e.g. power up) value
  MSG_GETFIRST          = $0004;  Get first of a series of items, e.g. DSs
  MSG_GETNEXT           = $0005;  Iterate through a series of items.
  MSG_SET               = $0006;  Set one or more values
  MSG_RESET             = $0007;  Set current value to default value
  MSG_QUERYSUPPORT      = $0008;  Get supported operations on the cap.

    Possible event.TWMessage values:
  Messages used with DAT_NULL:
  MSG_XFERREADY         = $0101;  The data source has data ready
  MSG_CLOSEDSREQ        = $0102;  Request for Application. to close DS
  MSG_CLOSEDSOK         = $0103;  Tell the Application. to save the state.
  MSG_DEVICEEVENT       = $0104;  Some event has taken place

 Messages used with a pointer to a DAT_STATUS structure:
  MSG_CHECKSTATUS      = $0201;  Get status information

 Messages used with a pointer to DAT_PARENT data:
  MSG_OPENDSM          = $0301;  Open the DSM
  MSG_CLOSEDSM         = $0302;  Close the DSM

 Messages used with a pointer to a DAT_IDENTITY structure:
  MSG_OPENDS           = $0401;  Open a data source
  MSG_CLOSEDS          = $0402;  Close a data source
  MSG_USERSELECT       = $0403;  Put up a dialog of all DS

 Messages used with a pointer to a DAT_USERINTERFACE structure:
  MSG_DISABLEDS        = $0501;  Disable data transfer in the DS
  MSG_ENABLEDS         = $0502;  Enable data transfer in the DS
  MSG_ENABLEDSUIONLY   = $0503;  Enable for saving DS state only.

 Messages used with a pointer to a DAT_EVENT structure:
  MSG_PROCESSEVENT     = $0601;

 Messages used with a pointer to a DAT_PENDINGXFERS structure:
  MSG_ENDXFER          = $0701;
  MSG_STOPFEEDER       = $0702;

 Messages used with a pointer to a DAT_FILESYSTEM structure:
  MSG_CHANGEDIRECTORY  = $0801;
  MSG_CREATEDIRECTORY  = $0802;
  MSG_DELETE           = $0803;
  MSG_FORMATMEDIA      = $0804;
  MSG_GETCLOSE         = $0805;
  MSG_GETFIRSTFILE     = $0806;
  MSG_GETINFO          = $0807;
  MSG_GETNEXTFILE      = $0808;
  MSG_RENAME           = $0809;
  MSG_COPY             = $080A;
  MSG_AUTOMATICCAPTUREDIRECTORY = $080B;

 Messages used with a pointer to a DAT_PASSTHRU structure:
  MSG_PASSTHRU     = $0901;


  TWRC_SUCCESS      =  0;
  TWRC_FAILURE      =  1;  Application may get TW_STATUS for info on failure
  TWRC_CHECKSTATUS  =  2;  "tried hard": ; get status
  TWRC_CANCEL       =  3;
  TWRC_DSEVENT      =  4;
  TWRC_NOTDSEVENT   =  5;
  TWRC_XFERDONE     =  6;
  TWRC_ENDOFLIST    =  7;  After MSG_GETNEXT if nothing left
  TWRC_INFONOTSUPPORTED =  8;
  TWRC_DATANOTAVAILABLE =  9;
}

  case N_TWAIN1Tmp.event.TWMessage of

    MSG_XFERREADY: // =$101, One or more Images are ready for transfering
    begin
      pending.Count := 12345; // just to start the following while loop (pending.Count is of TW_UINT16 type)

      while pending.Count <> 0 do // loop along all pending Images
      begin
        N_Dump1Str( Format( 'TWAIN MSG_XFERREADY 1, pending.count=%d', [pending.count] ));

        TWGNativeTransfer(); // Acquire one Image and add it to TWGDIBs Array

        if TWGRetCode <> TWRC_XFERDONE then // error in TWGNativeTransfer
        begin
          N_Dump1Str( Format( 'TWAIN Error in TWGNativeTransfer, TWGRetCode=%d', [TWGRetCode] ));

          // cancel (abort) all pending Images
          TWGCall( @TWGDSID, DG_CONTROL, DAT_PENDINGXFERS, MSG_RESET, @pending );
          TWGAcquiredOK := False; // not really needed
          goto CloseTWAIN;
        end; // if TWGRetCode <> TWRC_SUCCESS then // error in TWGNativeTransfer

//        SavedCount := pending.Count;
        // Check for Pending Transfers
        TWGCall( @TWGDSID, DG_CONTROL, DAT_PENDINGXFERS, MSG_ENDXFER, @pending );

        if TWGRetCode <> TWRC_SUCCESS then // error in getting pending.count
        begin
          N_Dump1Str( Format( 'TWAIN Error in getting pending.count, TWGRetCode=%d', [TWGRetCode] ));

          // cancel (abort) all pending Images
          TWGCall( @TWGDSID, DG_CONTROL, DAT_PENDINGXFERS, MSG_RESET, @pending );
          TWGAcquiredOK := False; // not really needed
          goto CloseTWAIN;
        end; // if TWGRetCode <> TWRC_SUCCESS then // error in getting pending.count

        //***** here: pending.count is OK, continue loop if pending.count <> 0
      end; // while pending.Count <> 0 do // loop along all pending Images

      //***** Here: after   While pending.Count <> 0 do   loop:
      //            all images ready images are processed (saved to TWGDIBs Array)
      //            wait for possible more images

      N_Dump1Str( 'TWAIN MSG_XFERREADY Fin' );
      TWGCall( nil, DG_CONTROL, DAT_STATUS, MSG_GET, @TWGSTATUS );
//      TWGCall( nil, DG_CONTROL, DAT_STATUS, MSG_GET, @TWGSTATUS );
//      TWGCall( nil, DG_CONTROL, DAT_STATUS, MSG_GET, @TWGSTATUS );
//      TimerSys.Enabled := True;
      Exit; // TWAIN Message processed

    end; // MSG_XFERREADY: // One or more Images are ready for transfering

    MSG_CLOSEDSREQ: // =$102, Acquiring was closed by user, close TWAIN
    begin
      TWGAcquiredOK := True; // not really needed
      goto CloseTWAIN;
    end; // MSG_CLOSEDSOK, MSG_CLOSEDSREQ:

    MSG_CLOSEDSOK: // =$103, should not occure, just a precaution
    begin
      N_Dump1Str( 'MSG_CLOSEDSOK: // =$103' );
      Exit;
    end;

    MSG_DEVICEEVENT: // =$104 Device event just ignore it
    begin
      N_Dump1Str( 'MSG_DEVICEEVENT: // =$104' );
      Exit;
    end;

  end; // case event.TWMessage of

  N_Dump1Str( 'Unknown TWAIN Message!' );
  Exit;

  CloseTWAIN: //***** Close Driver UI dialog, close DS and DSM, close Self

  TWGTWAINModalForm.TimerSys.Enabled := False; // is really needed, because TimerSys is not destroyed after FormClose!!!

  N_Dump1Str( 'Before CloseDS();' );
  CloseDS(); // Close UI dialog, Data Source Manager and Data Source

  N_Dump1Str( 'Before TWGTWAINModalForm.Close' );
  TWGTWAINModalForm.Close; // Close Self (Invisible modal window
  N_Dump1Str( 'After TWGTWAINModalForm.Close' );

  end; // with N_TWGlobObj1 do
end; // procedure TN_CMTWAIN1Form.TWAINWndProc


//*********************** TN_TWGlobObj1 Class methods

//**************************************************** TN_TWGlobObj1.Create ***
// Create Self
//
//     Parameters
// AProcObj - Procedure of object that should be called after all Images are Acquired
//
//constructor TN_TWGlobObj1.Create( AProcObj: TN_NoParamsProcObj );
constructor TN_TWGlobObj1.Create( );
begin
//  Application.OnMessage := TWGHandleMessage1;
//  TWGOnImagesReadyProcObj := AProcObj;
end; // constructor TN_TWGlobObj1.Create;

//*************************************************** TN_TWGlobObj1.Destroy ***
// Close all TWAIN Objects and Destroy Self
//
destructor TN_TWGlobObj1.Destroy;
begin
//  Application.OnMessage := nil;
  CloseDS();

  if TWGDLLHandle <> 0 then // Unload TWAIN_32.DLL
  begin
    FreeLibrary( TWGDLLHandle );

    TWGDLLHandle := 0;
    TWGDSMEntry := nil;
  end; // if TWGDLLHandle <> 0 then // Unload TWAIN_32.DLL

  inherited;
end; // destructor TN_TWGlobObj1.Destroy;

//*************************************************** TN_TWGlobObj1.CloseDS ***
// Close UI dialog, Data Source Manager and Data Source
//
procedure TN_TWGlobObj1.CloseDS();
var
  twUI: TW_USERINTERFACE;
begin
  if TWGDSMOpened then // Close Data Source Manager
  begin

    if TWGDSOpened then // Close Data Source
    begin

      if TWGDSEnabled then // Disable Data Source
      begin
//        twUI.hParent := Application.Handle;
        twUI.hParent := TWGWinHandle;
        twUI.ShowUI  := TW_BOOL(TWON_DONTCARE8); (*!!!!*)
        twUI.ModalUI := False;
                     
        TWGCall( @TWGDSID, DG_CONTROL, DAT_USERINTERFACE, MSG_DISABLEDS, @twUI );

        if TWGRetCode <> 0 then
          N_Dump1Str( Format( 'TWGCloseDS: Disable DS (UI) Error %d', [TWGRetCode] ));

        TWGDSEnabled := False;
      end; // if TWGDSEnabled then // Disable Data Source

      TWGCall( nil, DG_CONTROL, DAT_IDENTITY, MSG_CLOSEDS, @TWGDSID );

      if TWGRetCode <> 0 then
        N_Dump1Str( Format( 'TWGCloseDS: Close DS Error %d', [TWGRetCode] ));

      TWGDSOpened := False;
    end; // if TWGDSOpened then // Close Data Source

    TWGCall( nil, DG_CONTROL, DAT_PARENT, MSG_CLOSEDSM, @TWGWinHandle );

    if TWGRetCode <> 0 then
      N_Dump1Str( Format( 'TWGCloseDS: Close DSM Error %d', [TWGRetCode] ));

    TWGDSMOpened := False;
  end; // if TWGDSMOpened then // Close Data Source Manager
end; // procedure TN_TWGlobObj1.CloseDS;

//********************************* TN_TWGlobObj1.TWGHandleMessage1_NotUsed ***
// Handle TWAIN Messages (old variant, not used now!!!)
//
//     Parameters
// Msg     - message to handle
// Handled - should be set to True if Msg was handled (initial value is False)
//
// Is used as Application All Messages Handler while working with TWAIN
//
procedure TN_TWGlobObj1.TWGHandleMessage1_NotUsed( var Msg: TMsg; var Handled: Boolean );
// Handle TWAIN messages (Application's OnMessage handler (for all messages))
var
  event: TW_EVENT;
  pending: TW_PENDINGXFERS;
begin
  // TWAIN messages can occure only if DSM and DS are Opened
  if (not TWGDSMOpened) or (not TWGDSOpened) then Exit;

  event.pEvent := @Msg;
  event.TWMessage := 0;

//  N_IAdd( Format( 'App Msg:%x %x %x', [Msg.message,Msg.wParam,Msg.lParam] ));
//  if Assigned( N_StringDumpProcObj ) then // log all messages (for debug)
//    N_StringDumpProcObj( 'TWGHandler10', Format( 'Msg:%x %x %x',
//                                               [Msg.message,Msg.wParam,Msg.lParam] ) );

  Inc( TWGMessageCounter );
  // all messages should be immediatly sent back to Data Source
  TWGCall( @TWGDSID, DG_CONTROL, DAT_EVENT, MSG_PROCESSEVENT, @event );

  if Msg.hwnd = TWGWinHandle then
      N_Dump2Str( Format( 'App NT: TWGRetCode=%d, TWM=%x, Msg:%x %x %x, MC=%d',
           [TWGRetCode,event.TWMessage,Msg.message,Msg.wParam,Msg.lParam,TWGMessageCounter] ));

//  if (TWGRetCode <> TWRC_NOTDSEVENT) OR (event.TWMessage <> 0) then // Logg all TWAIN messages (TWRC_NOTDSEVENT = 5)
  if event.TWMessage <> 0 then // Logg all TWAIN messages
  begin
      N_Dump2Str( Format( 'TWAIN Handler20: TWGRetCode=%d, TWM=%x, Msg:%x %x %x, MC=%d',
              [TWGRetCode,event.TWMessage,Msg.message,Msg.wParam,Msg.lParam,TWGMessageCounter] ));
  end;

{
  Generic messages may be used with any of several DATs:
  MSG_GET               = $0001;  Get one or more values
  MSG_GETCURRENT        = $0002;  Get current value
  MSG_GETDEFAULT        = $0003;  Get default (e.g. power up) value
  MSG_GETFIRST          = $0004;  Get first of a series of items, e.g. DSs
  MSG_GETNEXT           = $0005;  Iterate through a series of items.
  MSG_SET               = $0006;  Set one or more values
  MSG_RESET             = $0007;  Set current value to default value
  MSG_QUERYSUPPORT      = $0008;  Get supported operations on the cap.

  Messages used with DAT_NULL:
  MSG_XFERREADY         = $0101;  The data source has data ready
  MSG_CLOSEDSREQ        = $0102;  Request for Application. to close DS
  MSG_CLOSEDSOK         = $0103;  Tell the Application. to save the state.
  MSG_DEVICEEVENT       = $0104;  Some event has taken place

 Messages used with a pointer to a DAT_STATUS structure:
  MSG_CHECKSTATUS      = $0201;  Get status information

 Messages used with a pointer to DAT_PARENT data:
  MSG_OPENDSM          = $0301;  Open the DSM
  MSG_CLOSEDSM         = $0302;  Close the DSM

 Messages used with a pointer to a DAT_IDENTITY structure:
  MSG_OPENDS           = $0401;  Open a data source
  MSG_CLOSEDS          = $0402;  Close a data source
  MSG_USERSELECT       = $0403;  Put up a dialog of all DS

 Messages used with a pointer to a DAT_USERINTERFACE structure:
  MSG_DISABLEDS        = $0501;  Disable data transfer in the DS
  MSG_ENABLEDS         = $0502;  Enable data transfer in the DS
  MSG_ENABLEDSUIONLY   = $0503;  Enable for saving DS state only.

 Messages used with a pointer to a DAT_EVENT structure:
  MSG_PROCESSEVENT     = $0601;

 Messages used with a pointer to a DAT_PENDINGXFERS structure:
  MSG_ENDXFER          = $0701;
  MSG_STOPFEEDER       = $0702;

 Messages used with a pointer to a DAT_FILESYSTEM structure:
  MSG_CHANGEDIRECTORY  = $0801;
  MSG_CREATEDIRECTORY  = $0802;
  MSG_DELETE           = $0803;
  MSG_FORMATMEDIA      = $0804;
  MSG_GETCLOSE         = $0805;
  MSG_GETFIRSTFILE     = $0806;
  MSG_GETINFO          = $0807;
  MSG_GETNEXTFILE      = $0808;
  MSG_RENAME           = $0809;
  MSG_COPY             = $080A;
  MSG_AUTOMATICCAPTUREDIRECTORY = $080B;

 Messages used with a pointer to a DAT_PASSTHRU structure:
  MSG_PASSTHRU     = $0901;


  TWRC_SUCCESS      =  0;
  TWRC_FAILURE      =  1;  Application may get TW_STATUS for info on failure
  TWRC_CHECKSTATUS  =  2;  "tried hard": ; get status
  TWRC_CANCEL       =  3;
  TWRC_DSEVENT      =  4;
  TWRC_NOTDSEVENT   =  5;
  TWRC_XFERDONE     =  6;
  TWRC_ENDOFLIST    =  7;  After MSG_GETNEXT if nothing left
  TWRC_INFONOTSUPPORTED =  8;
  TWRC_DATANOTAVAILABLE =  9;
}


  case event.TWMessage of
    MSG_XFERREADY: // =$101, One or more Images are ready for transfering
    begin
      pending.Count := 12345; // just to start the following while loop (pending.Count is of TW_UINT16 type)

      while pending.Count <> 0 do // loop along all pending Images
      begin
        N_Dump2Str( Format( 'TWAIN Handler30: Before TWGNativeTransfer, pending.count=%d', [pending.count] ));

        TWGNativeTransfer(); // Acquire one Image and add it to TWGDIBs Array

        if TWGRetCode <> TWRC_XFERDONE then // error in TWGNativeTransfer
        begin
          N_Dump1Str( Format( 'TWAIN Handler40: Error in TWGNativeTransfer, TWGRetCode=%d', [TWGRetCode] ));

          // cancel (abort) all pending Images
          TWGCall( @TWGDSID, DG_CONTROL, DAT_PENDINGXFERS, MSG_RESET, @pending );
          TWGAcquiredOK := False; // not really needed
          if Assigned(TWGOnImagesReadyProcObj) then TWGOnImagesReadyProcObj(); // process previously got Images
          Break; // finish getting pending Images loop
        end; // if TWGRetCode <> TWRC_SUCCESS then // error in TWGNativeTransfer

//        SavedCount := pending.Count;
        // Check for Pending Transfers
        TWGCall( @TWGDSID, DG_CONTROL, DAT_PENDINGXFERS, MSG_ENDXFER, @pending );

        if TWGRetCode <> TWRC_SUCCESS then // error in getting pending.count
        begin
          N_Dump1Str( Format( 'TWAIN Handler50: Error in getting pending.count, TWGRetCode=%d', [TWGRetCode] ));

          // cancel (abort) all pending Images
          TWGCall( @TWGDSID, DG_CONTROL, DAT_PENDINGXFERS, MSG_RESET, @pending );
          TWGAcquiredOK := False; // not really needed
          if Assigned(TWGOnImagesReadyProcObj) then TWGOnImagesReadyProcObj(); // process previously got Images
          Break; // finish getting pending Images loop
        end; // if TWGRetCode <> TWRC_SUCCESS then // error in getting pending.count

        //***** here: pending.count is OK, continue loop if pending.count <> 0
      end; // while pending.Count <> 0 do // loop along all pending Images

    end; // MSG_XFERREADY: // One or more Images are ready for transfering

    MSG_CLOSEDSOK,  // =$103, should not occure, just a precaution
    MSG_CLOSEDSREQ: // =$102
    begin
      TWGAcquiredOK := True; // not really needed

      // Process all acquired Images by TWGOnImagesReadyProcObj=N_CMResForm.SaveAcquiredImages method

      if Assigned(TWGOnImagesReadyProcObj) then TWGOnImagesReadyProcObj();
    end; // MSG_CLOSEDSOK, MSG_CLOSEDSREQ:

  end; // case event.TWMessage of

//  Handled := not (TWGRetCode = TWRC_NOTDSEVENT);
//  Handled := True;
end; // procedure TN_TWGlobObj1.TWGHandleMessage1_NotUsed

//****************************************** TN_TWGlobObj1.TWGFix32ToDouble ***
// Just convert given TW_FIX32 value to double
//
//     Parameters
// AFix32Value - given TW_FIX32 value
// Result      - Return converted double value
//
function TN_TWGlobObj1.TWGFix32ToDouble( AFix32Value: TW_FIX32 ): Double;
begin
  with AFix32Value do
    Result := Whole + 1.0*Frac/(N_MaxUInt2 + 1);
end; // function TN_TWGlobObj1.TWGFix32ToDouble

//*************************************************** TN_TWGlobObj1.TWGCall ***
// Just Call DSM_Entry
//
//     Parameters
// pDest - Pointer to Destination IDENTITY
// DG    - Data Group (DG_CONTROL, DG_IMAGE, DG_AUDIO)
// DAT   - Data Argument Type (DAT_xxxx)
// MSG   - Message ID (MSG_xxxx), really is Action Id
// pData - Pointer to needed Data (to some TW_xxxx record)
//
// Short form to call TWGDSMEntry
//
// Parameter pData Refers to the TW_xxxx structure or variable that will be used
// during the operation. Its type is specified by the DAT_xxxx.
// This parameter should always be typecast to TW_MEMREF when it is being referenced.
//
procedure TN_TWGlobObj1.TWGCall( pDest: pTW_IDENTITY; DG: TW_UINT32; DAT: TW_UINT16;
                                MSG: TW_UINT16; pData: TW_MEMREF );
begin
  TWGRetCode := TWGDSMEntry( @TWGAppID, pDest, DG, DAT, MSG, pData );
end; // procedure TN_TWGlobObj1.TWGCall

//****************************************** TN_TWGlobObj1.TWGOpenDSManager ***
// Open TWAIN Data Source Manager
//
//     Parameters
//
// APWinHandle - Pointer to Windows Handle, that will process all messages
//
procedure TN_TWGlobObj1.TWGOpenDSManager( APWinHandle: TW_MEMREF );
begin
  TWGDSMOpened := False;

  if TWGDLLHandle = 0 then // TWAIN_32.DLL is not loaded yet, load it
  begin
    TWGDLLHandle := LoadLibrary( PChar(N_TWAIN_DLL_Name) ); // N_TWAIN_DLL_Name is a String

    if TWGDLLHandle = 0 then // failed to load TWAIN_32.DLL
    begin
      TWGRetCode  := TWRC_NoDLL;
      TWGErrorStr := 'failed to load TWAIN_32.DLL';
      Exit;
    end; // if TWGDLLHandle = 0 then // failed to load TWAIN_32.DLL

    TWGDSMEntry  := GetProcAddress( TWGDLLHandle, PAnsiChar(N_DSM_Entry_Name) ); // N_DSM_Entry_Name is an AnsiString

    if not Assigned(TWGDSMEntry) then // failed to get DSM_Entry in TWAIN_32.DLL
    begin
      TWGRetCode  := TWRC_NoDSMEntry;
      TWGErrorStr := 'failed to get DSM_Entry in TWAIN_32.DLL';
      Exit;
    end; // if not Assigned(TWGDSMEntry) then // failed to get DSM_Entry in TWAIN_32.DLL

  end; // if TWGDLLHandle = 0 then // TWAIN_32.DLL is not loaded yet

  with TWGAppID do // Prepare Application IDENTITY
  begin
    Id := 0;  // init to 0, but Source Manager will assign real value

    Version.MajorNum := 1;
    Version.MinorNum := 0;
    Version.Language := TWLG_USA;
//    Version.Country  := TWCY_RUSSIA;
    Version.Country  := TWCY_AUSTRALIA;
    Version.Info     := AnsiString('Version 2.0');

    ProtocolMajor := 1; // TWON_PROTOCOLMAJOR;
    ProtocolMinor := 7; // TWON_PROTOCOLMINOR;
    SupportedGroups := DG_IMAGE or DG_CONTROL;

    ProductName   := AnsiString('CMS');
    ProductFamily := AnsiString('CMS');
    Manufacturer  := AnsiString('Centaursoftware');
  end; // with TWGAppID do // Prepare Application IDENTITY

  //*** Open Data Source Manager

//  TWGCall( nil, DG_CONTROL, DAT_PARENT, MSG_OPENDSM, @Application.Handle );
//  TWGCall( nil, DG_CONTROL, DAT_PARENT, MSG_OPENDSM, @TWGWinHandle );
  TWGCall( nil, DG_CONTROL, DAT_PARENT, MSG_OPENDSM, APWinHandle );

  if TWGRetCode = TWRC_SUCCESS then // Data Source Manager is Opened OK
  begin
    TWGErrorStr := '';
    TWGDSMOpened := True;
  end else // Data Source Manager is not Opened
  begin
    TWGErrorStr := 'failed to Open TWAIN DSM';
  end;

end; // procedure TN_TWGlobObj1.TWGOpenDSManager

//***************************************** TN_TWGlobObj1.TWGGetDataSources ***
// Get all currently available TWAIN Data Sources Names
//
//     Parameters
// ADSNames - on output, resulting list of TWAIN Data Sources Names
//
// As TWAIN Data Source Name TW_IDENTITY.ProductName field is used.
//
// Should be called after TWGOpenDSManager call.
//
procedure TN_TWGlobObj1.TWGGetDataSources( ADSNames: TStrings );
begin
  Assert( TWGDSMOpened,    'DSM not opened!' ); // a precaution
  Assert( not TWGDSOpened, 'DS is opened!' );   // a precaution

  TWGErrorStr := '';
  ADSNames.Clear();

  TWGCall( nil, DG_CONTROL, DAT_IDENTITY, MSG_GETFIRST, @TWGDSID );

  while True do // loop along all available Data Sources
  begin
    if TWGRetCode = TWRC_ENDOFLIST then // no more Data Sources
    begin
      TWGRetCode := TWRC_SUCCESS;
      Exit;
    end; // if TWGRetCode = TWRC_ENDOFLIST then // no more Data Sources

    if TWGRetCode <> TWRC_SUCCESS then // some Error
    begin
      TWGCall( nil, DG_CONTROL, DAT_STATUS, MSG_GET, @TWGSTATUS );
      TWGErrorStr := 'TWAIN Error (Data Sources Names) ' +
                                           IntToStr(TWGSTATUS.ConditionCode);
      N_Dump1Str( TWGErrorStr );
      Exit;
    end; // if TWGRetCode <> TWRC_TWRC_SUCCESS then // some Error

    ADSNames.Add( N_AnsiToString( TWGDSID.ProductName ) );

    TWGCall( nil, DG_CONTROL, DAT_IDENTITY, MSG_GETNEXT, @TWGDSID );
  end; // while True do // loop along all available Data Sources

end; // procedure TN_TWGlobObj1.TWGGetDataSources

//***************************************** TN_TWGlobObj1.TWGOpenDataSource ***
// Open TWAIN Data Source
//
//     Parameters
// ADSName - given TWAIN Data Source Name or '' for using TWAIN Dialogue
//
// Open TWAIN Data Source by given Name string or by TWAIN Dialogue.
//
// As TWAIN Data Source Name TW_IDENTITY.ProductName field is used.
// If ADSName = '' - use TWAIN provided Dialogue to Select needed Data Source.
// Opened Data Source TW_IDENTITY is in TWGDSID record.
//
// Should be called after TWGOpenDSManager call.
//
procedure TN_TWGlobObj1.TWGOpenDataSource( ADSName: AnsiString );
begin
  Assert( TWGDSMOpened,    'DSM not opened!' ); // a precaution
  Assert( not TWGDSOpened, 'DS is opened!' );   // a precaution

  if ADSName = '' then // Use TWAIN provided Dialogue
  begin
    TWGCall( nil, DG_CONTROL, DAT_IDENTITY, MSG_USERSELECT, @TWGDSID );

    if TWGRetCode <> TWRC_SUCCESS then // some Error
    begin
      TWGErrorStr := 'TWAIN Error while Selecting Data Source';
      Exit;
    end; // if TWGRetCode <> TWRC_TWRC_SUCCESS then // some Error

  end else //************ Search needed Data Source by Name string
  begin
    TWGCall( nil, DG_CONTROL, DAT_IDENTITY, MSG_GETFIRST, @TWGDSID );

    while True do // loop along all available Data Sources
    begin
      if TWGRetCode <> TWRC_SUCCESS then // some Error
      begin
        TWGErrorStr := 'TWAIN Error while searching Data Source!';
        Exit;
      end; // if TWGRetCode <> TWRC_TWRC_SUCCESS then // some Error

      if TWGDSID.ProductName = ADSName then Break; // Found, TWGDSID is OK

      TWGCall( nil, DG_CONTROL, DAT_IDENTITY, MSG_GETNEXT, @TWGDSID );
    end; // while True do // loop along all available Data Sources

  end; // else //************ Search needed Data Source by Name string

  //***** Data Source found, Open it

  TWGErrorStr := '';
  TWGCall( nil, DG_CONTROL, DAT_IDENTITY, MSG_OPENDS, @TWGDSID );

  if TWGRetCode = TWRC_SUCCESS then // Data Source is Opened OK
  begin
    TWGDSOpened := True;
  end else // Data Source not Opened
  begin
    TWGErrorStr := 'Error Opening TWAIN DS!';
  end;
end; // procedure TN_TWGlobObj1.TWGOpenDataSource

//***************************************** TN_TWGlobObj1.TWGNativeTransfer ***
// Get one Image in Native Transfer mode
//
// Should be called in event loop after MSG_XFERREADY message received
// after call TWGRetCode should be checked. TWGRetCode <> TWRC_SUCCESS means error
//
procedure TN_TWGlobObj1.TWGNativeTransfer();
var
 hDIB: TW_UINT32;
 MemPtr: Pointer;
 NewDIBObj: TN_DIBObj;
 TWImageInfo: TW_IMAGEINFO;
 XYResolution: TDPoint; // X,Y Resolution in DPI get from TWAIN Data Source
begin
  // Get Image resolution in DPI in XYResolution
  ZeroMemory( @TWImageInfo, SizeOf(TWImageInfo) );
  XYResolution.X := 0;
  TWGCall( @TWGDSID, DG_IMAGE, DAT_IMAGEINFO, MSG_GET, @TWImageInfo );

  if TWGRetCode <> TWRC_SUCCESS then
  begin
    N_Dump1Str( Format( 'TWAIN Handler: DG_IMAGE, DAT_IMAGEINFO, MSG_GET failed. TWGRetCode=%d', [TWGRetCode] ));
    Exit;
  end else // TWGRetCode = TWRC_SUCCESS continue working
  begin
    with TWImageInfo do
    begin
      XYResolution.X := TWGFix32ToDouble( XResolution );
      XYResolution.Y := TWGFix32ToDouble( YResolution );
      N_Dump2Str( Format( 'TWAIN Handler: TWAIN IMAGEINFO: DPI(X,Y)=%f,%f NS=%d  PixBits=%d',
                             [XYResolution.X,XYResolution.Y,SamplesPerPixel,BitsPerPixel] ));
    end;
  end;

  // get acquired Image handle
  TWGCall( @TWGDSID, DG_IMAGE, DAT_IMAGENATIVEXFER, MSG_GET, @hDIB );
  N_Dump1Str( Format( 'TWAIN NativeTransfer 3: TWGRetCode=%d', [TWGRetCode] ) );

  if TWGRetCode <> TWRC_XFERDONE then
    N_Dump1Str( Format( 'TWAIN NativeTransfer 4: TWGRetCode=%d', [TWGRetCode] ) );

  case TWGRetCode of

    TWRC_XFERDONE: // hDIB is ready, create TN_DIBObj from it
      begin
        NewDIBObj := TN_DIBObj.Create();
        MemPtr := GlobalLock( hDIB );
        NewDIBObj.LoadFromMemBMP( MemPtr );

        if XYResolution.X <> 0 then
          with NewDIBObj.DIBInfo.bmi do
          begin
            biXPelsPerMeter := Round( XYResolution.X * 1000 / N_InchInmm );
            biYPelsPerMeter := Round( XYResolution.Y * 1000 / N_InchInmm );
          end;

        GlobalUnlock( hDIB );
        GlobalFree( hDIB );

        if High(TWGDIBs) < TWGNumDibs then
          SetLength( TWGDIBs, N_NewLength( TWGNumDibs+1 ) );

        TWGDIBs[TWGNumDibs] := NewDIBObj;
        Inc( TWGNumDibs );
        TWGErrorStr := '';
      end; // TWRC_XFERDONE: // hDIB is ready, create TN_DIBObj from it

    TWRC_CANCEL: // ??
    begin
      TWGErrorStr := 'TWAIN Image Transfer Cancelled!';
    end; // TWRC_CANCEL: // ??

    TWRC_FAILURE: // ???
    begin
      TWGErrorStr := 'TWAIN Image Transfer Failure!';
    end; // TWRC_FAILURE: // ???

  end; // case TWGRetCode of
end; // procedure TN_TWGlobObj1.TWGNativeTransfer

//************************************************ TN_TWGlobObj1.TWGGetDIBs ***
// Start acquiring Images by TWAIN
//
// Start acquiring one or several Images from current Data Source in TWGDSID using
// TWAIN Data Source User interface.
// Acquired (resulting) images will be in TWGDIBs array of TN_DIBObject.
// TWGNumDibs is number of Acquired Images in TWGDIBs Array
//
// As TWAIN Source Name TW_IDENTITY.ProductName field is used.
//
procedure TN_TWGlobObj1.TWGGetDIBs();
var
  twUI: TW_USERINTERFACE;
  TTWG: TN_TWGlobObj;
begin
  Assert( TWGDSMOpened, 'DSM not opened!' ); // a precaution
  Assert( TWGDSOpened,  'DS not opened!' );  // a precaution
  TWGErrorStr := '';

  TTWG := TN_TWGlobObj.Create; // temporary
  TTWG.TmpInit( @Self );
  N_SL.Clear;
  TTWG.TWGGetBitDepthCaps( N_SL );
  N_Dump1Strings( N_SL, 5 );
  TTWG.Free();

  //***** Enable Data Source

  FillChar( twUI, SizeOf(twUI), 0 );

  twUI.hParent := TWGWinHandle;
//  twUI.hParent := 0;
//  twUI.ShowUI  := WordBool(0);
  twUI.ShowUI  := True;
  twUI.ModalUI := True;

  N_s := N_BytesToHexString( @twUI, SizeOf(twUI) );
  N_Dump2Str( Format( 'Check twUI handles %x %s', [TWGWinHandle,N_s] ) );

  TWGCall( nil, DG_CONTROL, DAT_STATUS, MSG_GET, @TWGSTATUS );
  N_Dump1Str( Format( 'Before ShowUI Scanner status=%d', [TWGSTATUS.ConditionCode] ) );

  TWGCall( @TWGDSID, DG_CONTROL, DAT_USERINTERFACE, MSG_ENABLEDS, @twUI );
  N_Dump1Str( Format( 'After ShowUI TWGRetCode=%d', [TWGRetCode] ) );

  if TWGRetCode <> TWRC_SUCCESS then // some Error
  begin
    TWGErrorStr := 'TWAIN Error while Enabling Data Source';
    TWGDSEnabled := False;
    N_Dump1Str( TWGErrorStr );
    N_Dump1Str( Format( '   TWGRetCode=%d', [TWGRetCode] ) );

    //***** Close close DS and DSM, close Self (TWGTWAINModalForm)

    TWGTWAINModalForm.TimerSys.Enabled := False; // is really needed, because TimerSys is not destroyed after FormClose!!!

    
    N_Dump1Str( 'Before CloseDS();' );
    CloseDS(); // Close UI dialog (is it OK here?), Data Source Manager and Data Source

    N_Dump1Str( 'Before TWGTWAINModalForm.Close' );
    TWGTWAINModalForm.Close; // Close Self (Invisible modal window
    N_Dump1Str( 'After TWGTWAINModalForm.Close' );

    Exit;
  end; // if TWGRetCode <> TWRC_TWRC_SUCCESS then // some Error

  TWGDSEnabled := True; // is used in error checking and in destructor

  //***** Now Applications should wait for messages from Data Source
  //      these messages are processed by TWGHandleMessage1
  //      All other actions are called from TWGHandleMessage1

//  TmpForm: TForm;
//  Application.CreateForm( TForm, TWGTWAINModalForm );
//  TWGTWAINModalForm.ShowModal();

end; // procedure TN_TWGlobObj1.TWGGetDIBs

//******************************************** TN_TWGlobObj1.TWGStartDialog ***
// Start Modal Dialog for acquiring Images by TWAIN
//
procedure TN_TWGlobObj1.TWGStartDialog();
begin
  //***** Create TWGTWAINModalForm - not visible Modal form to deactivate
  //      MainForm controls while showing TWAIN driver dialog
  //      All acquiring work is implemented in TWGTWAINModalForm.OnTimer event handler

  Application.CreateForm( TN_CMTWAIN1Form, TWGTWAINModalForm );
//  TWGTWAINModalFormOpened := True;
  TWGWinHandle := TWGWinHandle;

  with TWGTWAINModalForm do
  begin
//    WindowProc := OwnWndProc;

    BorderStyle := bsNone; // otherwise Zero size cannot be set
    Left := 0; // Set Zero sizes to make Form not visible
    Top  := 0;
    Width := 0;
    Height := 0;

    ShowModal();
  end; // with TWGTWAINModalForm do

end; // procedure TN_TWGlobObj1.TWGStartDialog


//*************************  Global Procedures  ***************

//************************************************* N_CMGetSlidesFromTWAIN1 ***
// Acquire Slides from given TWAIN device (var 2 - init TWAIN in OnTimer2 handler)
//
//     Parameters
// ATWAINProfileInd - Capture (TWAIN) device profile index
//
procedure N_CMGetSlidesFromTWAIN1( APCMTwainProfile: TK_PCMTwainProfile );
var
//  NumSlides: integer;
  SysTimerInterval, FoundInd: integer;
  TmpStr: string;
//  PCMTwainProfile : TK_PCMTwainProfile;
  Label TWAINFin;
begin
  if N_CMResForm.CMRFTwainMode then // a precaution - nested call
  begin
    N_Dump1Str( 'Nested call to TwainOnExecuteHandler' );
    goto TWAINFin;
  end; // if CMRFTwainMode then // a precaution - nested call

  N_CMResForm.CMRFTwainMode := True;

  //*** Get TWAIN device profile
//  K_CMCaptProfileInd := ATWAINProfileInd;
//  PCMTwainProfile := K_CMEDAccess.TwainProfiles.PDE(K_CMCaptProfileInd);
//  Assert( PCMTwainProfile <> nil, 'Wrong TWAIN Profile index' );

  with  APCMTwainProfile^ do
  begin
    //*** Create N_TWGlobObj1, fill its fields, open DSM and DS
    if N_TWGlobObj1 = nil then
      N_TWGlobObj1 := TN_TWGlobObj1.Create;

    with N_TWGlobObj1 do
    begin
      TWGDSName := N_StringToAnsi(CMDPProductName);
      if TWGDSName = '' then // error
      begin
//        TWGDSName := N_AnsiToString(CMDPCaption); //??
        K_CMShowMessageDlg( 'Device Profile "' + CMDPCaption + '" corrupted!', mtError );
        N_CMResForm.CMRFTwainMode := False;
        Exit;
      end; // if TWGDSName = '' then // error

//      N_h1 := Windows.GetActiveWindow();
//      N_h2 := N_CM_MainForm.CMMCurFMainForm.Handle;

      Application.CreateForm( TN_CMTWAIN1Form, TWGTWAINModalForm );

      with TWGTWAINModalForm do
      begin
        Left := 0;
        Top  := 0;

        BorderStyle := bsNone; // otherwise Zero Width, Height cannot be set!
        Width  := 1; // Set "Zero" sizes to make Form not visible
        Height := 1;
//        Width  := 200;
//        Height := 110;

        TmpStr := UpperCase( N_AnsiToString(TWGDSName) );
//        FoundInd := Pos( 'CANOSCAN ', TmpStr );
        FoundInd := 0; // temporary

        if FoundInd >= 1 then // Canon driver, TimerSys could be needed
        begin
          SysTimerInterval := N_MemIniToInt( 'CMS_UserDeb', 'TWAINInterval', 4000 );
//          SysTimerInterval := 4000;

          if SysTimerInterval > 0 then
          with TWGTWAINModalForm do
          begin
            TimerSys.Interval := SysTimerInterval;
            TimerSys.Enabled := True;
          end; // with ... , if SysTimerInterval > 0 then,

        end; // if FoundInd >= 1 then // Canon driver, TimerSys could be needed

{
        if SizeOf(Char) = 2 then // Delphi 2010, temporary
        begin
          Width := 450;
          Height := 100;
          Caption := 'Close this window to close TWAIN!';
        end else // Delphi 7
        begin
          BorderStyle := bsNone; // otherwise Zero Width, Height cannot be set!
          Width  := 0; // Set Zero sizes to make Form not visible
          Height := 0;
        end;
}
      end; // with TWGTWAINModalForm do

      N_Dump1Str( 'Just Before TWGTWAINModalForm.ShowModal();' );

      TWGTWAINModalForm.ShowModal(); // Start Modal Dialog for acquiring Images by TWAIN

      N_Dump1Str( 'Just After TWGTWAINModalForm.ShowModal();' );

      if K_CMD4WAppFinState then Exit; // Precaution

      SetLength( TWGDIBs, TWGNumDibs );
      K_CMScanSlidesSaveFromDIBArray( APCMTwainProfile, TWGDIBs );

{
      N_CM_MainForm.CMMCurFMainForm.Refresh();

      //***** Here: UI Dialog, DS and DSM are closed,
      //            all acquired images are in TWGDIBs array,
      //            process acquired images and close TWAIN

      K_CMSlidesSaveScanned1( APCMTwainProfile );

      NumSlides := K_CMSlidesSaveScanned1();
      if not K_CMD4WAppFinState then
      with N_CM_MainForm do
      begin
        if NumSlides > 0 then
          CMMFRebuildVisSlides();

        N_CM_MainForm.CMMFShowStringByTimer( Format(
                               ' %d media object(s) acquired', [NumSlides] ) );
      end; // with N_CM_MainForm do
}
      TWGTWAINModalForm.Release();
    end; // with N_TWGlobObj1 do

    FreeAndNil( N_TWGlobObj1 );
  end; // with  PCMTwainProfile^ do

  TWAINFin : //*********************************
  N_CMResForm.CMRFTwainMode := False;
end; // procedure N_CMGetSlidesFromTWAIN1


end.

