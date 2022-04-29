unit K_FCMTWAIN;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  Twain,
  N_Types, N_Gra2,
  K_CM0;

type TK_FormCMTWAIN = class( TForm )
    Timer: TTimer;

    procedure FormShow      ( Sender: TObject );
    procedure OnTimer       ( Sender: TObject );
    procedure TWAINWndProc  ( var Msg: TMessage );
    procedure TWAINWndProc2 ( var Msg: TMsg; var Handled: Boolean );
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    SavedWindowProc : TWndMethod;
    SavedApplicationMessageEvent : TMessageEvent;
    SavedEventWindow  : TWinControl;
    K_TWGObjShouldBeFree : Boolean;
    ModalMode : Boolean;

    procedure AfterImageTransfer();

  public
//  DriverHWND: THandle;
//  SelfHWND: THandle;
    PCMTwainProfile: TK_PCMTwainProfile;
    UseApplicationHandle : Boolean; // Use Application or Special Window Handle Flag
    UseWindowCode : Integer;
    CaptCount : Integer;
end; // type TN_CMTWAIN4Form = class( TForm )

{
type TK_TWAIN1Tmp = record
  TTA1: Array [0..99] of Byte;
  event: TW_EVENT;
  TTA2: Array [0..99] of Byte;
  AppMsg: TMsg;
  TTA3: Array [0..99] of Byte;
end; // type TK_TWAIN1Tmp = record
}

//*************************  Global Procedures  ***************

function  K_CMInitSlidesFromTWAIN( APCMTwainProfile: TK_PCMTwainProfile ) : Boolean;
function  K_CMGetSlidesFromTWAIN( APCMTwainProfile: TK_PCMTwainProfile ) : TForm;
procedure K_CMGetSlidesFromTWAINModal ( APCMTwainProfile: TK_PCMTwainProfile );


implementation
uses
  N_Lib0, N_Lib1, N_InfoF, N_CMResF, N_CML2F, N_CM1, N_CMMain5F,
  K_CMTWAIN;                 

{$R *.dfm}

//var
//  K_TWAIN1Tmp: TK_TWAIN1Tmp

procedure TK_FormCMTWAIN.FormShow( Sender: TObject );
// to freeze Parent Form (MainForm), Driver Dialog should be called after
// the end of FormShow handler, so it is implemented in OnTimer handler
begin
  N_Dump2Str( 'TK_FormCMTWAIN.FormShow - just enable Timer' );
  case UseWindowCode of
    0: SavedEventWindow := Self;
    1: SavedEventWindow := N_CM_MainForm;
    2: SavedEventWindow := N_CM_MainForm.CMMCurFMainForm;
  end;
  SavedWindowProc := SavedEventWindow.WindowProc;
  SavedApplicationMessageEvent := Application.OnMessage;

  K_TWGlobObj.TWGOnImageTransferedProcObj := AfterImageTransfer;

  Timer.Enabled := True; // just to call N_TWGlobObj4.TWGGetDIBs() once in TN_CMTWAIN4Form.OnTimer
end; // procedure TK_FormCMTWAIN.FormShow

procedure TK_FormCMTWAIN.OnTimer( Sender: TObject );
// Timer was enabled in FormShow to do all TWAIN things:
// - open TWAIN (TWGOpenDSManager, TWGOpenDataSource)
// - call TWGGetDIBs
// - Close TWAIN
// - Close Form (Close Self)
var
  Str: string;

label TWAINError, TWAINCancel;
begin
  N_Dump1Str( 'Start TK_FormCMTWAIN.OnTimer' );
  Timer.Enabled := False; // process OnTimer event only once
//  SelfHWND := Windows.GetActiveWindow();


  with K_TWGlobObj do
  begin
    // Set Handle and Events Procedure
    if UseApplicationHandle then
    begin
      TWGWinHandle := Application.Handle;
      Application.OnMessage := TWAINWndProc2;
    end
    else
    begin

//      TWGWinHandle := Self.Handle; //???
//      WindowProc := TWAINWndProc;
      TWGWinHandle :=  SavedEventWindow.Handle;
      SavedEventWindow.WindowProc := TWAINWndProc;
    end;

    TWGOpenDSManager( @TWGWinHandle );
    N_Dump1Str( 'after TWGOpenDSManager' );

    if TWGRetCode <> 0 then goto TWAINError;

    TWGOpenDataSource( TWGDSName );
    N_Dump1Str( 'after TWGOpenDataSource "' + N_AnsiToString(TWGDSName) + '"' );

    if TWGRetCode <> 0 then
    begin
      // N_CML2Form.LLLNotPluggedIn1_c = 'Capture device "%s"/#is not plugged in.'
      Str := Format( N_CML2Form.LLLNotPluggedIn1.Caption, [N_AnsiToString(TWGDSName)] );
      K_CMShowMessageDlg( Str, mtWarning );
      goto TWAINCancel;
    end; // if TWGRetCode <> 0 then

    TWGInitModes(); // Self Init Twain Object by device capabilities
    if TWGRetCode <> TWRC_SUCCESS then
      goto TWAINCancel;
    // Show Data Source Info
    N_SL.Clear;
    TWGGetBitDepthCaps( N_SL );
    N_Dump2Strings( N_SL, 5 );


    TWGUINotModal := not (fsModal in FormState);

    TWGRetCode := TWGShowDSUI(); // create TWAIN UI (driver dialog), get images and save Slides

    if TWGRetCode = TWRC_CANCEL then
      goto TWAINCancel;


    N_Dump1Str( 'Finish TK_FormCMTWAIN.OnTimer OK' );
//    Self.Close; // Close Self (Invisible modal window)
    Exit;

TWAINError: //****************************
    Str := 'TWAIN Error detected >> '#13#10'"' + TWGErrorStr  + '".';
    K_CMShowMessageDlg( Str, mtWarning );

TWAINCancel: //***************************

    TWGCloseDS(); // Close UI dialog, Data Source Manager and Data Source
//    FreeAndNil( N_TWGlobObj4 );
    Self.Close; // Close Self (Invisible modal window)
    N_Dump1Str( 'TWAIN Canceled' );
  end; // with K_TWGlobObj do

//  TWAINFin : //*********************************
  N_CMResForm.CMRFTwainMode := False;
end; // procedure TK_FormCMTWAIN.OnTimer

//******************************************** TK_FormCMTWAIN.TWAINWndProc ***
// Own Window Proc that is used instead of standart Self.WindowProc
// for handling TWAIN messages
//
//     Parameters
// Msg - Windows Message
//
procedure TK_FormCMTWAIN.TWAINWndProc( var Msg: TMessage );
var
  TWEvent: TW_EVENT;
  FMsg: TMsg;

label  DefWndProc;
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
{
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
}

    ZeroMemory( @FMsg, SizeOf(TMsg) );
    FMsg.hwnd    := TWGWinHandle;
    FMsg.message := Msg.Msg;
    FMsg.WParam := Msg.WParam;
    FMsg.LParam := Msg.LParam;
    TWEvent.pEvent := @FMsg;

//    TWEvent.pEvent := @Msg;
    TWEvent.TWMessage := 0;

    if TWGProcEvent( TWEvent ) then
    begin
      if TWGRetCode <> TWRC_DSEVENT then goto DefWndProc;
//      if TWEvent.TWMessage = 0 then goto DefWndProc;
    end   // if TWProcEvent( TWEvent ) then
    else
    begin // if not TWProcEvent( event ) then
    //***** Close Driver UI dialog, close DS and DSM, close Self
      if TWGErrorStr <> '' then
        K_CMShowMessageDlgByTimer( TWGErrorStr, mtError );
      N_Dump1Str( 'Before TWGCloseDS();' );
      TWGCloseDS(); // Close UI dialog, Data Source Manager and Data Source
      Self.Close; // Close Self (Invisible modal window)
    end; // if not TWProcEvent( TWEvent ) then
  end; // with K_TWGlobObj do

end; // procedure TN_CMTWAIN4Form.TWAINWndProc

//**************************************** TK_FormCMTWAIN.TWAINWndProc2 ***
// Application.OnMessage handler for handling TWAIN messages
//
//     Parameters
// Msg     - Windows Message
// Handled - if meassage was handled
//
procedure TK_FormCMTWAIN.TWAINWndProc2( var Msg: TMsg; var Handled: Boolean );
var
  TWEvent: TW_EVENT;
begin
  if (K_TWGlobObj = nil) or K_CMD4WAppFinState then Exit;// a precaution

  with K_TWGlobObj do
  begin

    // TWAIN messages can occure only if DSM and DS are Opened
    if (not TWGDSMOpened) or (not TWGDSOpened) then Exit;

    TWEvent.pEvent    := @Msg;
    TWEvent.TWMessage := 0;

    if TWGProcEvent( TWEvent ) then
    begin
//      if TWEvent.TWMessage <> 0 then
//        Handled := True;
      Handled := TWGRetCode = TWRC_DSEVENT;
    end
    else
    begin
      if TWGErrorStr <> '' then
        K_CMShowMessageDlgByTimer( TWGErrorStr, mtError );
      N_Dump1Str( 'Before CloseDS();' );
      TWGCloseDS(); // Close UI dialog, Data Source Manager and Data Source
      Self.Close; // Close Self (Invisible modal window)
    end;

  end; // with K_TWGlobObj do
end; // TK_FormCMTWAIN.TWAINWndProc2

//******************************************* TK_FormCMTWAIN.FormCloseQuery ***
// Form Close Query Event Handler
//
procedure TK_FormCMTWAIN.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
begin
  SavedEventWindow.WindowProc := SavedWindowProc;
  Application.OnMessage := SavedApplicationMessageEvent;
  N_CM_MainForm.CMMCurFMainForm.Repaint();
end; // procedure TK_FormCMTWAIN.FormCloseQuery

//************************************************ TK_FormCMTWAIN.FormClose ***
// Form Close Event Handler
//

procedure TK_FormCMTWAIN.FormClose(Sender: TObject; var Action: TCloseAction);
var
  CMTSlides: TN_UDCMSArray; // Capured Slides
  i : Integer;
  j : Integer;

begin
  if K_CMD4WAppFinState or ModalMode then Exit; // Precaution

  N_Dump1Str( 'TK_FormCMTWAIN.Close();' );
  // Get New Slides to Local Array
  SetLength( CMTSlides, CaptCount );
  with K_CMEDAccess do
  begin
    j := CurSlidesList.Count - CaptCount;
    for i := 0 to CaptCount - 1 do
      CMTSlides[i] := TN_UDCMSlide( CurSlidesList[j + i] );
  end;

  if K_TWGObjShouldBeFree then
    FreeAndNil( K_TWGlobObj )
  else
    K_TWGlobObj.TWGUINotModal := FALSE;

  // Show Processing Dialog and Save creating slides
  K_CMSlidesSaveScanned3( TK_PCMDeviceProfile(PCMTwainProfile), CMTSlides );
//
  N_CMResForm.CMRFTwainMode := False;

end; // procedure TK_FormCMTWAIN.FormClose

//*************************************** TK_FormCMTWAIN.AfterImageTransfer ***
// After Image is transfered from TWAIN Data Source procedure of object
//
procedure TK_FormCMTWAIN.AfterImageTransfer;
var
  FSlide : TN_UDCMSlide;
begin
  Inc(CaptCount);

  FSlide := K_CMSlideCreateFromDIBObj( K_TWGlobObj.TWGLastDIBObj,
                                       @PCMTwainProfile.CMAutoImgProcAttrs );
  FSlide.ObjInfo := 'Captured from ' + PCMTwainProfile.CMDPCaption;
  FSlide.ObjAliase := 'Scan ' + IntToStr(CaptCount); // for Show in Thumbnails Frame in Setting Attributes Form

  FSlide.SetAutoCalibrated();
  with FSlide.P()^ do
  begin
    CMSSourceDescr := PCMTwainProfile.CMDPCaption;
    CMSMediaType := PCMTwainProfile.CMDPMTypeID;
  end;

  K_CMEDAccess.EDAAddSlide(FSlide);

  K_TWGlobObj.TWGLastDIBObj := nil;
end; // procedure TK_FormCMTWAIN.AfterImageTransfer


//*************************  Global Procedures  ***************

//************************************************* K_CMInitSlidesFromTWAIN ***
// Acquire Slides from given TWAIN device, mode 4 - 16 bit test
//
//     Parameters
// APCMTwainProfile - Capture (TWAIN) device profile pointer
// Result - Returns TRUE if capture can be continued
//
function K_CMInitSlidesFromTWAIN( APCMTwainProfile: TK_PCMTwainProfile ) : Boolean;
begin
  Result := FALSE;
  if N_CMResForm.CMRFTwainMode then // a precaution - nested call
  begin
    N_Dump1Str( 'Nested call to TwainOnExecuteHandler' );
    N_CMResForm.CMRFTwainMode := False;
    Exit;
  end; // if CMRFTwainMode then // a precaution - nested call

  with  APCMTwainProfile^ do
    if CMDPProductName = '' then // error
    begin
      K_CMShowMessageDlg( 'Device Profile "' + CMDPCaption + '" corrupted!', mtError );
      Exit;
    end; // if TWGDSName = '' then // error

  N_CMResForm.CMRFTwainMode := True;
  Result := TRUE;

end; // function K_CMInitSlidesFromTWAIN

//************************************************* K_CMGetSlidesFromTWAIN ***
// Acquire Slides from given TWAIN device, mode 4 - 16 bit test
//
//     Parameters
// APCMTwainProfile - Capture (TWAIN) device profile pointer
//
function K_CMGetSlidesFromTWAIN( APCMTwainProfile: TK_PCMTwainProfile ) : TForm;
var
  CreateTWGObj : Boolean;
begin
    //***** Create K_TWGlobObj, fill its fields, open DSM and DS

  with  APCMTwainProfile^ do
  begin
    CreateTWGObj := K_TWGlobObj = nil;
    if CreateTWGObj then
      K_TWGlobObj := TK_TWGlobObj.Create;

    with K_TWGlobObj do
    begin
      TWGDSName := N_StringToAnsi(CMDPProductName);

      // Set TWAIN Data Transfere Mode
      TWGDataTransfModeSet := K_twdtmNative;
      if Length(CMDPStrPar1) >= 2 then
      begin
        if CMDPStrPar1[2] = '2' then
          TWGDataTransfModeSet := K_twdtmFile
        else if CMDPStrPar1[2] = '3' then
          TWGDataTransfModeSet := K_twdtmMemory;
      end;
    end; // with K_TWGlobObj do

  //***** Create TK_FormCMTWAIN - not visible Modal form to deactivate
  //      CMSuite MainForm controls while showing TWAIN driver dialog
  //      All acquiring work is implemented in ... K_TWGlobObj.TWGProcEvent;
    Result := TK_FormCMTWAIN.Create(Application);
    with TK_FormCMTWAIN(Result) do
    begin
      K_TWGObjShouldBeFree := CreateTWGObj;
      Left := 0;
      Top  := 0;
      Width  := 1; // Set "Zero" sizes to make Form not visible
      Height := 1;
      BorderStyle := bsNone; // otherwise Zero Width, Height cannot be set!
      BorderIcons := [];
      BorderWidth := 0;
//        Width  := 333;
//        Height := 222;

      // Set CMSuite Events Recieve Method
      PCMTwainProfile := APCMTwainProfile;
//      UseApplicationHandle := (Length(CMDPStrPar1) >= 3) and (CMDPStrPar1[3] = '2');
      if (Length(CMDPStrPar1) >= 3) then
        case CMDPStrPar1[3] of
          '2' : UseApplicationHandle := TRUE;
          '3' : UseWindowCode := 1;
          '4' : UseWindowCode := 2;
        end;

    end; // with TK_FormCMTWAIN.Create(Application) do
  end; // with  PCMTwainProfile^ do
end; // procedure K_CMGetSlidesFromTWAIN

//********************************************* K_CMGetSlidesFromTWAINModal ***
// Acquire Slides from given TWAIN device, mode 4 - 16 bit test
//
//     Parameters
// APCMTwainProfile - Capture (TWAIN) device profile pointer
//
procedure K_CMGetSlidesFromTWAINModal( APCMTwainProfile: TK_PCMTwainProfile );
var
  CreateTWGObj : Boolean;
  CMTSlides: TN_UDCMSArray; // Capured Slides
  i : Integer;
  j : Integer;

//label TWAINFin;
begin
{
  if N_CMResForm.CMRFTwainMode then // a precaution - nested call
  begin
    N_Dump1Str( 'Nested call to TwainOnExecuteHandler' );
    goto TWAINFin;
  end; // if CMRFTwainMode then // a precaution - nested call

  with  APCMTwainProfile^ do
  begin
    if CMDPProductName = '' then // error
    begin
      K_CMShowMessageDlg( 'Device Profile "' + CMDPCaption + '" corrupted!', mtError );
      Exit;
    end; // if TWGDSName = '' then // error

    N_CMResForm.CMRFTwainMode := True;
}
    //***** Create K_TWGlobObj, fill its fields, open DSM and DS

  with  APCMTwainProfile^ do
  begin
    CreateTWGObj := K_TWGlobObj = nil;
    if CreateTWGObj then
      K_TWGlobObj := TK_TWGlobObj.Create;

    with K_TWGlobObj do
    begin
      TWGDSName := N_StringToAnsi(CMDPProductName);

      // Set TWAIN Data Transfere Mode
      TWGDataTransfModeSet := K_twdtmNative;
      if Length(CMDPStrPar1) >= 2 then
      begin
        if CMDPStrPar1[2] = '2' then
          TWGDataTransfModeSet := K_twdtmFile
        else if CMDPStrPar1[2] = '3' then
          TWGDataTransfModeSet := K_twdtmMemory;
      end;

  //***** Create TK_FormCMTWAIN - not visible Modal form to deactivate
  //      CMSuite MainForm controls while showing TWAIN driver dialog
  //      All acquiring work is implemented in ... K_TWGlobObj.TWGProcEvent;
      with TK_FormCMTWAIN.Create(Application) do
      begin
        Left := 0;
        Top  := 0;
        Width  := 1; // Set "Zero" sizes to make Form not visible
        Height := 1;
        BorderStyle := bsNone; // otherwise Zero Width, Height cannot be set!
        BorderIcons := [];
        BorderWidth := 0;
//        Width  := 333;
//        Height := 222;

        // Set CMSuite Events Recieve Method
        PCMTwainProfile := APCMTwainProfile;
//        UseApplicationHandle := (Length(CMDPStrPar1) >= 3) and (CMDPStrPar1[3] = '2');
        if (Length(CMDPStrPar1) >= 3) then
          case CMDPStrPar1[3] of
            '2' : UseApplicationHandle := TRUE;
            '3' : UseWindowCode := 1;
            '4' : UseWindowCode := 2;
          end;
          
        ModalMode := TRUE;

        N_Dump1Str( 'Before TK_FormCMTWAIN.ShowModal()' );
        ShowModal(); // Start Modal Dialog for acquiring Images by TWAIN
        N_Dump1Str( 'After TK_FormCMTWAIN.ShowModal();' );

        if K_CMD4WAppFinState then Exit; // Precaution

        // Get New Slides to Local Array
        SetLength( CMTSlides, CaptCount );
        with K_CMEDAccess do
        begin
          j := CurSlidesList.Count - CaptCount;
          for i := 0 to CaptCount - 1 do
            CMTSlides[i] := TN_UDCMSlide( CurSlidesList[j + i] );
        end;

        Release();
      end; // with TK_FormCMTWAIN.Create(Application) do
    end; // with K_TWGlobObj do

    if CreateTWGObj then
      FreeAndNil( K_TWGlobObj );

    // Show Processing Dialog and Save creating slides
    K_CMSlidesSaveScanned3( TK_PCMDeviceProfile(APCMTwainProfile), CMTSlides );

  end; // with  PCMTwainProfile^ do

//TWAINFin : //*********************************
  N_CMResForm.CMRFTwainMode := False;

end; // procedure K_CMGetSlidesFromTWAINModal


end.

