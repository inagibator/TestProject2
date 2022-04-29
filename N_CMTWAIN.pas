unit N_CMTWAIN;
// Low level Global TWAIN object for all CMS TWAIN modes

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  Twain,
  N_Types, N_Gra2,
  K_CM0;


type TN_TWGlobObj = class( TObject ) // my TWAIN Global object for TWAIN mode #1
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
//  TWGTWAINModalForm: TN_CMTWAIN4Form;
  TWGDSName:  AnsiString;  // TWAIN Driver Name (TW_IDENTITY.ProductName)
  TWGWinHandle: THandle;   // Window Handle for processing TWAIN messages

  constructor Create ();
  destructor Destroy (); override;

  procedure CloseDS           ();
  procedure TWGHandleMessage1_NotUsed ( var Msg: TMsg; var Handled: Boolean );
  function  TWGFix32ToDouble  ( AFix32Value: TW_FIX32 ): Double;
  procedure TWGCall           ( pDest: pTW_IDENTITY; DG: TW_UINT32; DAT: TW_UINT16;
                                          MSG: TW_UINT16; pData: TW_MEMREF ); overload;
  procedure TWGCall           ( DG: TW_UINT32; DAT: TW_UINT16;
                                          MSG: TW_UINT16; pData: TW_MEMREF ); overload;
  procedure TWGOpenDSManager  ( APWinHandle: TW_MEMREF );
  procedure TWGOpenDataSource ( ADSName: AnsiString );
  procedure TWGGetDataSources ( ADSNames: TStrings );
  procedure TWGNativeTransfer ();
  procedure TWGGetDIBs        ();
  procedure TWGStartDialog    ();

  procedure TmpInit      ( APtr: Pointer );
  function  TWGGetCaps   ( var AAvCaps: TN_IArray; AGivenCap: Word; APTWCap: PTWCapability = nil ): Word;
  function  TWGGetCurCap ( AGivenCap: Word; var ACurCap: Integer ): Word;
  function  TWGSetCurCap ( AGivenCap: Word; ANewCurCap: Word ): Word;
  procedure TWGGetBitDepthCaps ( AStrings: TStrings );
end; // type TN_TWGlobObj = class( TObject ) // my TWAIN Global object

const
  TWRC_NoDLL      =  $8001; // failed to load TWAIN_32.DLL
  TWRC_NoDSMEntry =  $8002; // failed to get DSM_Entry in TWAIN_32.DLL

  N_TWAIN_DLL_Name: String     = 'TWAIN_32.DLL';
  N_DSM_Entry_Name: AnsiString = 'DSM_Entry';

var
  N_TWGlobObj: TN_TWGlobObj;

implementation

uses
  N_Lib0, N_Lib1, N_InfoF, N_CMResF, N_CMVideo2F, N_CML2F, N_CM1, N_CMTWAIN4F;

//*********************** TN_TWGlobObj Class methods

//**************************************************** TN_TWGlobObj.Create ***
// Create Self
//
//     Parameters
// AProcObj - Procedure of object that should be called after all Images are Acquired
//
//constructor TN_TWGlobObj.Create( AProcObj: TN_NoParamsProcObj );
constructor TN_TWGlobObj.Create( );
begin
//  Application.OnMessage := TWGHandleMessage1;
//  TWGOnImagesReadyProcObj := AProcObj;
end; // constructor TN_TWGlobObj.Create;

//*************************************************** TN_TWGlobObj.Destroy ***
// Close all TWAIN Objects and Destroy Self
//
destructor TN_TWGlobObj.Destroy;
begin
{
//  Application.OnMessage := nil;
  CloseDS();

  if TWGDLLHandle <> 0 then // Unload TWAIN_32.DLL
  begin
    FreeLibrary( TWGDLLHandle );

    TWGDLLHandle := 0;
    TWGDSMEntry := nil;
  end; // if TWGDLLHandle <> 0 then // Unload TWAIN_32.DLL
}
  inherited;
end; // destructor TN_TWGlobObj.Destroy;

//*************************************************** TN_TWGlobObj.CloseDS ***
// Close UI dialog, Data Source Manager and Data Source
//
procedure TN_TWGlobObj.CloseDS();
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
        twUI.ShowUI := TW_BOOL(TWON_DONTCARE8); (*!!!!*)

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
end; // procedure TN_TWGlobObj.CloseDS;

//********************************* TN_TWGlobObj.TWGHandleMessage1_NotUsed ***
// Handle TWAIN Messages (old variant, not used now!!!)
//
//     Parameters
// Msg     - message to handle
// Handled - should be set to True if Msg was handled (initial value is False)
//
// Is used as Application All Messages Handler while working with TWAIN
//
procedure TN_TWGlobObj.TWGHandleMessage1_NotUsed( var Msg: TMsg; var Handled: Boolean );
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
end; // procedure TN_TWGlobObj.TWGHandleMessage1_NotUsed

//****************************************** TN_TWGlobObj.TWGFix32ToDouble ***
// Just convert given TW_FIX32 value to double
//
//     Parameters
// AFix32Value - given TW_FIX32 value
// Result      - Return converted double value
//
function TN_TWGlobObj.TWGFix32ToDouble( AFix32Value: TW_FIX32 ): Double;
begin
  with AFix32Value do
    Result := Whole + 1.0*Frac/(N_MaxUInt2 + 1);
end; // function TN_TWGlobObj.TWGFix32ToDouble

//************************************************* TN_TWGlobObj.TWGCall(5) ***
// Just Call DSM_Entry with pDest parametr
//
procedure TN_TWGlobObj.TWGCall( pDest: pTW_IDENTITY; DG: TW_UINT32; DAT: TW_UINT16;
                                MSG: TW_UINT16; pData: TW_MEMREF );
begin
  TWGRetCode := TWGDSMEntry( @TWGAppID, pDest, DG, DAT, MSG, pData );
end; // procedure TN_TWGlobObj.TWGCall

//************************************************* TN_TWGlobObj.TWGCall(4) ***
// Just Call DSM_Entry without pDest parametr
//
procedure TN_TWGlobObj.TWGCall( DG: TW_UINT32; DAT: TW_UINT16;
                                MSG: TW_UINT16; pData: TW_MEMREF );
begin
  TWGRetCode := TWGDSMEntry( @TWGAppID, @TWGDSID, DG, DAT, MSG, pData );
end; // procedure TN_TWGlobObj.TWGCall

//****************************************** TN_TWGlobObj.TWGOpenDSManager ***
// Open TWAIN Data Source Manager
//
//     Parameters
//
// APWinHandle - Pointer to Windows Handle, that will process all messages
//
procedure TN_TWGlobObj.TWGOpenDSManager( APWinHandle: TW_MEMREF );
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

end; // procedure TN_TWGlobObj.TWGOpenDSManager

//***************************************** TN_TWGlobObj.TWGGetDataSources ***
// Get all currently available TWAIN Data Sources Names
//
//     Parameters
// ADSNames - on output, resulting list of TWAIN Data Sources Names
//
// As TWAIN Data Source Name TW_IDENTITY.ProductName field is used.
//
// Should be called after TWGOpenDSManager call.
//
procedure TN_TWGlobObj.TWGGetDataSources( ADSNames: TStrings );
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

end; // procedure TN_TWGlobObj.TWGGetDataSources

//***************************************** TN_TWGlobObj.TWGOpenDataSource ***
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
procedure TN_TWGlobObj.TWGOpenDataSource( ADSName: AnsiString );
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
end; // procedure TN_TWGlobObj.TWGOpenDataSource

//***************************************** TN_TWGlobObj.TWGNativeTransfer ***
// Get one Image in Native Transfer mode
//
// Should be called in event loop after MSG_XFERREADY message received
// after call TWGRetCode should be checked. TWGRetCode <> TWRC_SUCCESS means error
//
procedure TN_TWGlobObj.TWGNativeTransfer();
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
end; // procedure TN_TWGlobObj.TWGNativeTransfer

//************************************************ TN_TWGlobObj.TWGGetDIBs ***
// Start acquiring Images by TWAIN
//
// Start acquiring one or several Images from current Data Source in TWGDSID using
// TWAIN Data Source User interface.
// Acquired (resulting) images will be in TWGDIBs array of TN_DIBObject.
// TWGNumDibs is number of Acquired Images in TWGDIBs Array
//
// As TWAIN Source Name TW_IDENTITY.ProductName field is used.
//
procedure TN_TWGlobObj.TWGGetDIBs();
var
  i, NumItems: Integer;
  PUINT16: PTW_UINT16;
  UINT16Array: TN_UI2Array;
  twUI: TW_USERINTERFACE;
  twCAP: TW_CAPABILITY;
  PEnum: PTWEnumeration;
begin
  Assert( TWGDSMOpened, 'DSM not opened!' ); // a precaution
  Assert( TWGDSOpened,  'DS not opened!' );  // a precaution
  TWGErrorStr := '';

  TWGCall( nil, DG_CONTROL, DAT_STATUS, MSG_GET, @TWGSTATUS );
  N_Dump1Str( Format( 'Before ShowUI Scanner status=%d', [TWGSTATUS.ConditionCode] ) );

  //******************* 16 bit tests

  //***** Get available transfer modes
  N_Dump1Str( '  Get available transfer modes' );

  twCAP.Cap        := ICAP_XFERMECH;
  twCAP.ConType    := TWON_DONTCARE16;
  twCAP.hContainer := 0;

  TWGCall( @TWGDSID, DG_CONTROL, DAT_CAPABILITY, MSG_GET, @twCAP );
  if TWGRetCode <> TWRC_SUCCESS then // some Error
    N_Dump1Str( Format( '   1) TWGRetCode=%d', [TWGRetCode] ) );

  if twCAP.ConType <> TWON_ENUMERATION then // a precaution
    N_Dump1Str( Format( '   2) twCAP.ConType=%d', [Integer(twCAP.ConType)] ) );

  PEnum := GlobalLock( twCAP.hContainer );

  if PEnum = nil then
    N_Dump1Str( '   3) PEnum = nil' );

  NumItems := PEnum^.NumItems;

  if PEnum^.ItemType <> TWTY_UINT16 then // a precaution
    N_Dump1Str( Format( '   4) PEnum^.ItemType=%d', [Integer(PEnum^.ItemType)] ) );

  SetLength( UINT16Array, NumItems );
  PUINT16 := PTW_UINT16(@PEnum^.ItemList[0]);

  for i := 0 to High(UINT16Array) do
  begin
    UINT16Array[i] := PUINT16^; Inc( PUINT16 );
  end;

//  N_i := N_IndexOfWord( UINT16Array, TWSX_FILE );

  N_i1 := PEnum^.CurrentIndex;
  N_i2 := PEnum^.DefaultIndex;
  GlobalUnlock( twCAP.hContainer );
  GlobalFree( twCAP.hContainer );

  //***** Get available File Formats
  N_Dump1Str( '  Get available File Formats' );

  twCAP.Cap        := ICAP_IMAGEFILEFORMAT;
  twCAP.ConType    := TWON_DONTCARE16;
  twCAP.hContainer := 0;

  TWGCall( @TWGDSID, DG_CONTROL, DAT_CAPABILITY, MSG_GET, @twCAP );
  if TWGRetCode <> TWRC_SUCCESS then // some Error
    N_Dump1Str( Format( '   1) TWGRetCode=%d', [TWGRetCode] ) );

  if twCAP.ConType <> TWON_ENUMERATION then // a precaution
    N_Dump1Str( Format( '   2) twCAP.ConType=%d', [Integer(twCAP.ConType)] ) );

  PEnum := GlobalLock( twCAP.hContainer );

  if PEnum = nil then
    N_Dump1Str( '   3) PEnum = nil' );

  NumItems := PEnum^.NumItems;

  if PEnum^.ItemType <> TWTY_UINT16 then // a precaution
    N_Dump1Str( Format( '   4) PEnum^.ItemType=%d', [Integer(PEnum^.ItemType)] ) );

  SetLength( UINT16Array, NumItems );
  PUINT16 := PTW_UINT16(@PEnum^.ItemList[0]);

  for i := 0 to High(UINT16Array) do
  begin
    UINT16Array[i] := PUINT16^; Inc( PUINT16 );
  end;

//  N_i1 := N_IndexOfWord( UINT16Array, TWFF_TIFF );
//  N_i2 := N_IndexOfWord( UINT16Array, TWFF_PNG );
//  N_i2 := N_IndexOfWord( UINT16Array, TWFF_BMP );

  GlobalUnlock( twCAP.hContainer );
  GlobalFree( twCAP.hContainer );






  //***** Show User Interface

  FillChar( twUI, SizeOf(twUI), 0 );

  twUI.hParent := TWGWinHandle;
//  twUI.hParent := 0;
//  twUI.ShowUI  := WordBool(0);
  twUI.ShowUI  := True;
  twUI.ModalUI := True;

  N_s := N_BytesToHexString( @twUI, SizeOf(twUI) );
  N_Dump2Str( Format( 'Check twUI handles %x %s', [TWGWinHandle,N_s] ) );

  TWGCall( @TWGDSID, DG_CONTROL, DAT_USERINTERFACE, MSG_ENABLEDS, @twUI );
  N_Dump1Str( Format( 'After ShowUI TWGRetCode=%d', [TWGRetCode] ) );

  if TWGRetCode <> TWRC_SUCCESS then // some Error
  begin
    TWGErrorStr := 'TWAIN Error while Enabling Data Source';
    TWGDSEnabled := False;
    N_Dump1Str( TWGErrorStr );
    N_Dump1Str( Format( '   TWGRetCode=%d', [TWGRetCode] ) );

    //***** Close close DS and DSM, close Self (TWGTWAINModalForm)

    N_Dump1Str( 'Before CloseDS();' );
    CloseDS(); // Close UI dialog (is it OK here?), Data Source Manager and Data Source

    N_Dump1Str( 'Before TWGTWAINModalForm.Close' );
//    TWGTWAINModalForm.Close; // Close Self (Invisible modal window
    N_Dump1Str( 'After TWGTWAINModalForm.Close' );

    Exit;
  end; // if TWGRetCode <> TWRC_TWRC_SUCCESS then // some Error

  TWGDSEnabled := True; // is used in error checking and in destructor

  //***** Now Applications should wait for messages from Data Source
  //      these messages are processed by TWGHandleMessage1
  //      All other actions are called from TWGHandleMessage1

end; // procedure TN_TWGlobObj.TWGGetDIBs

//******************************************** TN_TWGlobObj.TWGStartDialog ***
// Start Modal Dialog for acquiring Images by TWAIN
//
procedure TN_TWGlobObj.TWGStartDialog();
begin
  //***** Create TWGTWAINModalForm - not visible Modal form to deactivate
  //      MainForm controls while showing TWAIN driver dialog
  //      All acquiring work is implemented in TWGTWAINModalForm.OnTimer event handler

//  Application.CreateForm( TN_CMTWAIN4Form, TWGTWAINModalForm );
//  TWGTWAINModalFormOpened := True;
  TWGWinHandle := TWGWinHandle;
{
  with TWGTWAINModalForm do
  begin
//    WindowProc := OwnWndProc;

    BorderStyle := bsNone; // otherwise Zero size cannot be set
    Left := 0; // Set Zero sizes to make Form not visible
    Top  := 0;
    Width := 300;
    Height := 200;

    ShowModal();
  end; // with TWGTWAINModalForm do
}
end; // procedure TN_TWGlobObj.TWGStartDialog

//**************************************************** TN_TWGlobObj.TmpInit ***
// Tmp Self initialization, APtr is @N_TWGlobObj4
//
procedure TN_TWGlobObj.TmpInit( APtr: Pointer );
var
  PTWG: TN_PTWGlobObj4;
begin
  PTWG := TN_PTWGlobObj4(APtr);

  Self.TWGDLLHandle := PTWG^.TWGDLLHandle;
  Self.TWGDSMEntry  := PTWG^.TWGDSMEntry;
  Self.TWGDSName    := PTWG^.TWGDSName;
  Self.TWGWinHandle := PTWG^.TWGWinHandle;

  move( PTWG^.TWGAppID, Self.TWGAppID, SizeOf(TW_IDENTITY) );
  move( PTWG^.TWGDSID,  Self.TWGDSID,  SizeOf(TW_IDENTITY) );
end; // procedure TN_TWGlobObj.TmpInit

//************************************************* TN_TWGlobObj.TWGGetCaps ***
// Get list of Capabilities available on AGivenCap Capability
//
//     Parameters
// AAvCaps   - list of resulting Capalities (on output)
// AGivenCap - given Capability
// APTWCap   - pointer to TW_CAPABILITY record to be used or nil
// Result    - DSMEntry( ... MSG_GET, @twCAP ) TWAIN Return code (TWRC_xxx)
//
function TN_TWGlobObj.TWGGetCaps( var AAvCaps: TN_IArray; AGivenCap: Word;
                                           APTWCap: PTWCapability = nil ): Word;
var
  i: Integer;
  NumItems, CurrentIndex: Word;
  TmptwCAP: TW_CAPABILITY;
  PUINT16: PTW_UINT16;
  PCap: PTWCapability;
  PEnum: PTWEnumeration;

  Label FreeAndExit, UnlockFreeAndExit;
begin
  AAvCaps := nil;

  if APTWCap = nil then // not given
    PCap := @TmptwCAP
  else // given use it
    PCap := APTWCap;

  PCap^.Cap        := AGivenCap;
  PCap^.ConType    := TWON_DONTCARE16;
  PCap^.hContainer := 0;

  TWGCall( DG_CONTROL, DAT_CAPABILITY, MSG_GET, PCAP );
  Result := TWGRetCode;

  if TWGRetCode <> TWRC_SUCCESS then // some Error
  begin
    N_Dump1Str( Format( 'TWGGetCaps Error=1 TWGRetCode=%d', [TWGRetCode] ) );
    goto FreeAndExit;
  end;

  if PCAP^.ConType <> TWON_ENUMERATION then // a precaution
  begin
    N_Dump1Str( Format( 'TWGGetCaps Error=2 TWGRetCode=%d', [TWGRetCode] ) );
    goto FreeAndExit;
  end;

  PEnum := GlobalLock( PCap^.hContainer );

  if PEnum = nil then
  begin
    N_Dump1Str( Format( 'TWGGetCaps Error=3 PEnum=nil', [TWGRetCode] ) );
    goto UnlockFreeAndExit;
  end;

  NumItems := PEnum^.NumItems;

  if PEnum^.ItemType <> TWTY_UINT16 then // a precaution
  begin
    N_Dump1Str( Format( 'TWGGetCaps Error=4 ItemType=%d', [PEnum^.ItemType] ) );
    goto UnlockFreeAndExit;
  end;

  if NumItems = 0 then // a precaution
  begin
    N_Dump1Str( 'TWGGetCaps Error=5 NumItems = 0' );
    goto UnlockFreeAndExit;
  end;

  SetLength( AAvCaps, NumItems+1 ); // NumItems is always >= 1
  PUINT16 := PTW_UINT16(@PEnum^.ItemList[0]);

  for i := 1 to High(AAvCaps) do
  begin
    AAvCaps[i] := PUINT16^;
    Inc( PUINT16 );
  end;

  CurrentIndex := PEnum^.CurrentIndex;

  if CurrentIndex < High(AAvCaps) then
    AAvCaps[0] := AAvCaps[CurrentIndex+1]
  else
    AAvCaps[0] := -1;

  UnlockFreeAndExit: //*****************
  GlobalUnlock( PCap^.hContainer );

  FreeAndExit: //***********************
  GlobalFree( PCap^.hContainer );
end; // procedure TN_TWGlobObj.TWGGetCaps

//*********************************************** TN_TWGlobObj.TWGGetCurCap ***
// Get current value of AGivenCap Capability
//
//     Parameters
// AGivenCap - given Capability
// ACurCap   - resulting current Capability of AGivenCap (on output)
// Result    - DSMEntry( ... MSG_GET, @twCAP ) TWAIN Return code (TWRC_xxx)
//
function TN_TWGlobObj.TWGGetCurCap( AGivenCap: Word; var ACurCap: Integer ): Word;
var
  twCAP: TW_CAPABILITY;
  AvCaps: TN_IArray;
begin
  Result := TWGGetCaps( AvCaps, AGivenCap, @twCAP );

  if High(AvCaps) > 0 then
    ACurCap := AvCaps[0]
  else
    ACurCap := -1;
end; // procedure TN_TWGlobObj.TWGGetCurCap

//*********************************************** TN_TWGlobObj.TWGSetCurCap ***
// Set current value of AGivenCap Capability
//
//     Parameters
// AGivenCap  - given Capability
// ANewCurCap - given New current value of Capability of AGivenCap
// Result     - DSMEntry( ... MSG_SET, @twCAP ) TWAIN Return code (TWRC_xxx)
//
function TN_TWGlobObj.TWGSetCurCap( AGivenCap: Word; ANewCurCap: Word ): Word;
var
  POneVal: PTWOneValue;
  twCAP: TW_CAPABILITY;
begin
  twCAP.Cap        := AGivenCap;
  twCAP.ConType    := TWON_ONEVALUE;
  twCAP.hContainer := Windows.GlobalAlloc( GHND, SizeOf(TW_ONEVALUE) ); // GHND = GMEM_MOVEABLE + GMEM_ZEROINIT	

  POneVal := PTWOneValue(Windows.GlobalLock( twCAP.hContainer ));

  POneVal^.ItemType := TWTY_UINT16;
  POneVal^.Item     := ANewCurCap;

  GlobalUnlock( twCAP.hContainer );

  TWGCall( @TWGDSID, DG_CONTROL, DAT_CAPABILITY, MSG_SET, @twCAP );
  Result := TWGRetCode;

  GlobalFree( twCAP.hContainer );
end; // procedure TN_TWGlobObj.TWGSetCurCap

//***************************************** TN_TWGlobObj.TWGGetBitDepthCaps ***
// Add BitDepth related Capabilities to given AStrings
//
//     Parameters
// AStrings - given AStrings with all needed Capabilities
//
procedure TN_TWGlobObj.TWGGetBitDepthCaps( AStrings: TStrings );
var
  iFFmt, iPixType, CurCap: integer;
  FFmtArray, PixTypeArray, BitDepthsArray: TN_IArray;
begin
  AStrings.Add( 'BitDepth related TWAIN Capabilities' );

  AStrings.Add( '' );
  AStrings.Add( '    Native transfer mode:' );
  TWGSetCurCap( ICAP_XFERMECH, TWSX_NATIVE );
  TWGGetCaps( PixTypeArray, ICAP_PIXELTYPE );

  if PixTypeArray <> nil then AStrings.Add( 'Supported Pixel Types: ' +
                N_ConvIntsToStr( @PixTypeArray[1], High(PixTypeArray), ', '  ) +
                '  ( 0-BW, 1-Gray, 2-RGB )' );

  for iPixType := 1 to High(PixTypeArray) do // along all supported Pixel Types
  begin
    TWGSetCurCap( ICAP_PIXELTYPE, PixTypeArray[iPixType] );
    TWGGetCaps( BitDepthsArray, ICAP_BITDEPTH );

    if BitDepthsArray <> nil then AStrings.Add( 'PixType=' +
                IntToStr(PixTypeArray[iPixType]) + ' Supported Bit Depths: ' +
                N_ConvIntsToStr( @BitDepthsArray[1], High(BitDepthsArray), ', ' ) );
  end; // for iPixTypes := 1 to High(PixTypeArray) do // along all supported Pixel Types

  AStrings.Add( '' );
  AStrings.Add( '    File transfer mode:' );
  TWGSetCurCap( ICAP_XFERMECH, TWSX_FILE );
  TWGGetCurCap( ICAP_XFERMECH, CurCap );

  if CurCap <> TWSX_FILE then
    AStrings.Add( '    File transfer mode not supported!' )
  else // File transfer mode
  begin
    TWGGetCaps( FFmtArray, ICAP_IMAGEFILEFORMAT );
    if FFmtArray <> nil then AStrings.Add( 'Supported File Formats: ' +
                N_ConvIntsToStr( @FFmtArray[1], High(FFmtArray), ', '  ) +
                '  ( 0-TIFF, 1-PICT, 2-BMP, 4-JPEG, 6-TIFFMULTI, 7-PNG )' );

    for iFFmt := 1 to High(FFmtArray) do // along all supported File Formats
    begin
      TWGSetCurCap( ICAP_IMAGEFILEFORMAT, FFmtArray[iFFmt] );

      TWGGetCaps( PixTypeArray, ICAP_PIXELTYPE );

      if PixTypeArray <> nil then AStrings.Add( 'FileFmt=' +
               IntToStr(FFmtArray[iFFmt]) + ' Supported Pixel Types: ' +
               N_ConvIntsToStr( @PixTypeArray[1], High(PixTypeArray), ', '  ) +
               '  ( 0-BW, 1-Gray, 2-RGB )' );

      for iPixType := 1 to High(PixTypeArray) do // along all supported Pixel Types
      begin
        TWGSetCurCap( ICAP_PIXELTYPE, PixTypeArray[iPixType] );
        TWGGetCaps( BitDepthsArray, ICAP_BITDEPTH );

        if BitDepthsArray <> nil then AStrings.Add( 'FileFmt=' +
            IntToStr(FFmtArray[iFFmt]) + ' PixType=' +
            IntToStr(PixTypeArray[iPixType]) + ' Supported Bit Depths: ' +
            N_ConvIntsToStr( @BitDepthsArray[1], High(BitDepthsArray), ', ' ) );
      end; // for iPixTypes := 1 to High(PixTypeArray) do // along all supported Pixel Types

    end; // for iFFmt := 1 to High(FFmtArray) do // along all supported File Formats

  end; // else // File transfer mode

  AStrings.Add( '' );
end; // procedure TN_TWGlobObj.TWGGetBitDepthCaps


end.
