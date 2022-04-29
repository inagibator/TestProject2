unit K_CMTWAIN;
// Low level Global TWAIN object for all CMS TWAIN modes

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  Twain,
  N_Types, N_Gra2;

type TK_TWDTMode  = (K_twdtmUnassigned, K_twdtmNative, K_twdtmFile, K_twdtmMemory);
type TK_TWGlobObj = class( TObject ) // my TWAIN Global object for TWAIN mode #1
  TWGOnImageTransferedProcObj: TN_NoParamsProcObj;
  TWGDSMOpened:   boolean; // Data Source Manager is currently Opened
  TWGDSOpened:    boolean; // Data Source is currently Opened
  TWGDSEnabled:   boolean; // Data Source is currently Enabled
  TWGAcquiredOK:  boolean; // Some Images are Acquired and Capturing process should be finished
  TWGOpCanceled:  boolean; // No Images are Acquired and Capturing process should be finished
  TWGDLLHandle:   HMODULE; // TWAIN_32.DLL Handle
  TWGRetCode:   TW_UINT16; // TWAIN and Own Return Code (TWGRetCode=0 means OK, but TWGOpCanceled may be True)
  TWGErrorStr:     string; // Error description string (for User Interface) if TWGRetCode <> 0

  TWGDSMEntry: TDSMEntryProc; // DSM_Entry procedure in TWAIN_32.DLL

  TWGDSTransfModeCur:     LongWord; // Source support Current data transfer
  TWGDSTransfModeDefault: LongWord; // Source support Default data transfer
  TWGDSTransfModeNative: boolean; // Source support Native data transfer
  TWGDSTransfModeFile:   boolean; // Source support File data transfer
  TWGDSTransfModeMem:    boolean; // Source support Buffered Memory data transfer
  TWGDSTransfModeMemFile:boolean; // Source support Buffered Memory File data transfer

//  TWGDSTransfFileFormat:        LongWord; // Used File Format
  TWGDSTransfFileFormatCur:     LongWord; // Source support Current File Format
  TWGDSTransfFileFormatDefault: LongWord; // Source support Default File Format
  TWGDSTransfFileFormatBMP:boolean; // Source support BMP File Format
  TWGDSTransfFileFormatPNG:boolean; // Source support PNG File Format
  TWGDSTransfFileFormatTIF:boolean; // Source support TIF File Format
  TWGDSTransfFileFormatJPG:boolean; // Source support JPEG File Format

  TWGAppID:   TW_IDENTITY; // Application IDENTITY
  TWGDSID:    TW_IDENTITY; // Data Source IDENTITY
  TWGSTATUS:  TW_STATUS;   //

//  TWGDIBs: TN_DIBObjArray; // Acquired Images as Array of TN_DIBObject
//  TWGNumDibs:     integer; // Number of Acquired Images in TWGDIBs Array
  TWGMessageCounter: integer;
//  TWGTWAINModalForm: TN_CMTWAIN4Form;
  TWGDSName:  AnsiString;  // TWAIN Driver Name (TW_IDENTITY.ProductName)
  TWGWinHandle: THandle;   // Window Handle for processing TWAIN messages
  TWGLastDIBObj: TN_DIBObj;
  TWGDataTransfModeSet : TK_TWDTMode;
  TWGDataTransfModeUse : TK_TWDTMode;

  TWGXYResolution: TDPoint; // X,Y Resolution in DPI get from TWAIN Data Source

  TWGUINotModal : Boolean; // TWAIN UI modal flag

  constructor Create ( AProcObj: TN_NoParamsProcObj = nil );
  destructor Destroy (); override;

  procedure TWGCloseDS           ();
  procedure TWGCall           ( pDest: pTW_IDENTITY; DG: TW_UINT32; DAT: TW_UINT16;
                                          MSG: TW_UINT16; pData: TW_MEMREF ); overload;
  procedure TWGCall           ( DG: TW_UINT32; DAT: TW_UINT16;
                                          MSG: TW_UINT16; pData: TW_MEMREF ); overload;
  procedure TWGOpenDSManager  ( APWinHandle: TW_MEMREF = nil );
  procedure TWGOpenDataSource ( ADSName: AnsiString = '' );
  procedure TWGGetDataSources ( ADSNames: TStrings );
  procedure TWGGetImageInfo( APImageInfo : PTWImageInfo  );
  procedure TWGNativeTransfer ();
  procedure TWGFileTransfer   ();
  procedure TWGMemTransfer    ();
  procedure TWGInitModes      ();
  function  TWGShowDSUI() : TW_UINT16;

  function  TWGParseCaps( var AAvCaps: TN_IArray; APTWCap: PTWCapability;
                          out ACurInd, ADefInd : Integer ): Boolean;
  function  TWGGetCaps   ( var AAvCaps: TN_IArray; AGivenCap: Word;
                           APCurVal : PInteger = nil ): Word;
  function  TWGGetCurCap ( AGivenCap: Word; var ACurCap: Integer ): Word;
  function  TWGSetCurCap ( AGivenCap: Word; ANewCurCap: Word ): Word;
  procedure TWGGetBitDepthCaps ( AStrings: TStrings );
  function  TWGProcEvent(var AEvent : TW_EVENT ) : Boolean;
end; // type TK_TWGlobObj = class( TObject ) // my TWAIN Global object

const
  TWRC_NoDLL      =  $8001; // failed to load TWAIN_32.DLL
  TWRC_NoDSMEntry =  $8002; // failed to get DSM_Entry in TWAIN_32.DLL

  N_TWAIN_DLL_Name: String     = 'TWAIN_32.DLL';
  N_DSM_Entry_Name: AnsiString = 'DSM_Entry';

var
  K_TWGlobObj: TK_TWGlobObj;

implementation

uses
  N_Lib0, N_Lib1, N_InfoF, N_CMResF,
  K_CLib0, K_CM0;

//****************************************** TK_TWGlobObj.TWGFix32ToDouble ***
// Just convert given TW_FIX32 value to double
//
//     Parameters
// AFix32Value - given TW_FIX32 value
// Result      - Return converted double value
//
function K_TWGFix32ToDouble( AFix32Value: TW_FIX32 ): Double;
begin
  with AFix32Value do
    Result := Whole + 1.0*Frac/(N_MaxUInt2 + 1);
end; // function TK_TWGlobObj.TWGFix32ToDouble



//************************************************ K_CMCreateTWAINBufferDIB ***
// Create buffer DIB for TWAIN image transfer WIA memory buffer
//
//     Parameters
// APTWAINImageInfo - pointer to TWAIN image info data
// Result - Returns proper created DIB object or resulting code 1, 2, 3
//          if unknown TWAI pixel format
//
function K_CMCreateTWAINBufferDIB( APTWAINImageInfo : pTW_IMAGEINFO ) : TN_DIBObj;
var
  FPixFmt: TPixelFormat;
  FExPixFmt: TN_ExPixFmt;
  NumBits  : Integer;

begin
// Result := nil;
  with APTWAINImageInfo^ do
  begin
    NumBits  := 0;
    if PixelType = TWPT_PALETTE then
    begin
      FPixFmt := pf24bit;
      FExPixFmt := epfBMP;
    end
    else
    if (SamplesPerPixel = 1) and (PixelType <> TWPT_PALETTE) then
    begin
      FPixFmt := pfCustom;
      if BitsPerPixel = 8 then
        FExPixFmt := epfGray8
      else
      if BitsPerPixel = 16 then
      begin
        FExPixFmt := epfGray16;
        NumBits   := BitsPerSample[0];
      end
      else
      begin
        Result := TN_DIBObj(1);
        Exit;
      end;
    end
    else
    if (SamplesPerPixel = 3) and (PixelType = TWPT_RGB) then
    begin
      if BitsPerPixel = 24 then
      begin
        FPixFmt := pf24bit;
        FExPixFmt := epfBMP;
      end
      else
      begin
        FPixFmt := pfCustom;
        if BitsPerPixel = 48 then
          FExPixFmt := epfColor48
        else
        begin
          Result := TN_DIBObj(2);
          Exit;
        end;
      end
    end
    else
    if SamplesPerPixel = 4 then
    begin
      if BitsPerPixel = 32 then
      begin
        FPixFmt := pf32bit;
        FExPixFmt := epfBMP;
      end
      else
      begin
        FPixFmt := pfCustom;
        if BitsPerPixel = 64 then
          FExPixFmt := epfColor64
        else
        begin
          Result := TN_DIBObj(2);
          Exit;
        end;
      end
    end
    else
    begin
      Result := TN_DIBObj(2);
      Exit;
    end;

    Result := TN_DIBObj.Create( ImageWidth, ImageLength, FPixFmt, -1,
                                        FExPixFmt, NumBits );
  end;

end; // function K_CMCreateTWAINBufferDIB

//************************************** K_CMCopyPixelsFromTWAINBufferToDIB ***
// Move pixels from TWAIN memory buffer to given DIB
//
//     Parameters
// ADIB             - resulting DIB
// APTWAINImageInfo - pointer to TWAIN image info data
// APTWAINGetMem    - pointer to image pixel portion memory buffer info
// APPalette        - pointer to TW_PALETTE8 data
// Result - Returns 0 if OK, 1 if pixel size in DIB does not match pixel size in memory buffer
//
function K_CMCopyPixelsFromTWAINBufferToDIB( ADIB : TN_DIBObj;
                                             APTWAINImageInfo : pTW_IMAGEINFO;
                                             APTWAINGetMem : pTW_IMAGEMEMXFER;
                                             APPalette : pTW_PALETTE8 ) : Integer;

var
  BytesInPix: integer;
  PElem, PSrc, PRed, PBlue: TN_BytesPtr;
  i, MoveCount, NextBufRowShift : Integer;
  BufWidthEQImgWidth : Boolean;
  BB : Byte;
  WW : Word;
  PRed2, PBlue2: TN_PUInt2;

  procedure SwapRedBlueRowSamples();
  var j : Integer;
  begin
    PRed  := PElem;
    PBlue := PElem + 2;
    for j := 0 to APTWAINImageInfo.ImageWidth - 1 do
    begin
      BB := Byte(PRed^);
      PRed^ := PBlue^;
      Byte(PBlue^) := BB;
      PRed  := PRed + BytesInPix;
      PBlue := PBlue + BytesInPix;
    end;
  end;

  procedure SwapRedBlueRowSamples2();
  var j : Integer;
  begin
    PRed2  := TN_PUInt2(PElem);
    PBlue2 := TN_PUInt2(PElem + 4);
    for j := 0 to APTWAINImageInfo.ImageWidth - 1 do
    begin
      WW := Word(PRed2^);
      PRed2^ := PBlue2^;
      Word(PBlue2^) := WW;
      PRed2  := TN_PUInt2(TN_BytesPtr(PRed2) + BytesInPix);
      PBlue2 := TN_PUInt2(TN_BytesPtr(PBlue2) + BytesInPix);
    end;
  end;

begin
  Result := 1;
  with ADIB do
  begin
    BytesInPix := GetElemSizeInBytes();
    if (BytesInPix shl 3) <> APTWAINImageInfo.BitsPerPixel then Exit; // wrong pixel size

    if APTWAINImageInfo.PixelType = TWPT_PALETTE then
    begin
    //  Prepapre Palette
    end;

    MoveCount := Integer(APTWAINGetMem.Columns)* BytesInPix;
    BufWidthEQImgWidth := Integer(APTWAINGetMem.Columns) = APTWAINImageInfo.ImageWidth;
    NextBufRowShift := MoveCount;
    if BufWidthEQImgWidth then
      NextBufRowShift := APTWAINGetMem.BytesPerRow;

    PSrc := APTWAINGetMem.Memory.TheMem;
    if DIBInfo.bmi.biHeight > 0 then  // Bottom Up Matrix
    begin
      PElem := PRasterBytes +
               (DIBSize.Y - Integer(APTWAINGetMem.YOffset) - 1)*RRLineSize +
               Integer(APTWAINGetMem.XOffset)*BytesInPix;

      for i := 0 to APTWAINGetMem.Rows - 1 do
      begin
        if APPalette <> nil then
        begin
        end
        else
        begin
          move ( PSrc^, PElem^, MoveCount );
          if (APTWAINImageInfo.SamplesPerPixel = 3) then
          begin
            if (APTWAINImageInfo.BitsPerPixel = 24) then
              SwapRedBlueRowSamples();
            if (APTWAINImageInfo.BitsPerPixel = 48) then
              SwapRedBlueRowSamples2();
          end;
        end;
        PElem := PElem - RRLineSize;
        PSrc  := PSrc + NextBufRowShift;
      end;
    end
    else // Top Down Matrix
    begin
      PElem := PRasterBytes +
               Integer(APTWAINGetMem.YOffset)*RRLineSize +
               Integer(APTWAINGetMem.XOffset)*BytesInPix;
      if BufWidthEQImgWidth and
         ((APTWAINImageInfo.SamplesPerPixel <> 3) or
          (APTWAINImageInfo.BitsPerPixel <> 24)) then
        Move( PSrc^,  PElem^, APTWAINGetMem.BytesWritten )
      else
        for i := 0 to APTWAINGetMem.Rows - 1 do
        begin
          if APPalette <> nil then
          begin
          end
          else
          begin
            move ( PSrc^, PElem^, MoveCount );
            if (APTWAINImageInfo.SamplesPerPixel = 3) then
            begin
              if (APTWAINImageInfo.BitsPerPixel = 24) then
                SwapRedBlueRowSamples();
              if (APTWAINImageInfo.BitsPerPixel = 48) then
                SwapRedBlueRowSamples2();
            end;
          end;
          PElem := PElem + RRLineSize;
          PSrc  := PSrc  + NextBufRowShift;
        end;
    end;
  end;

  Result := 0;

end; // function K_CMCopyPixelsFromTWAINBufferToDIB


//*********************** TK_TWGlobObj Class methods

//**************************************************** TK_TWGlobObj.Create ***
// Create Self
//
//     Parameters
// AProcObj - Procedure of object that should be called after all Images are Acquired
//
constructor TK_TWGlobObj.Create( AProcObj: TN_NoParamsProcObj = nil);
//constructor TK_TWGlobObj.Create( );
begin
//  Application.OnMessage := TWGHandleMessage1;
  TWGOnImageTransferedProcObj := AProcObj;
//  TWGDSTransfFileFormat := TWFF_BMP;
  TWGDSTransfFileFormatCur := TWFF_BMP;
end; // constructor TK_TWGlobObj.Create;

//*************************************************** TK_TWGlobObj.Destroy ***
// Close all TWAIN Objects and Destroy Self
//
destructor TK_TWGlobObj.Destroy;
begin

//  Application.OnMessage := nil;
  TWGCloseDS();

  if TWGDLLHandle <> 0 then // Unload TWAIN_32.DLL
  begin
    FreeLibrary( TWGDLLHandle );

    TWGDLLHandle := 0;
    TWGDSMEntry := nil;
  end; // if TWGDLLHandle <> 0 then // Unload TWAIN_32.DLL

  inherited;
end; // destructor TK_TWGlobObj.Destroy;

//************************************************* TK_TWGlobObj.TWGCloseDS ***
// Close UI dialog, Data Source Manager and Data Source
//
procedure TK_TWGlobObj.TWGCloseDS();
var
  twUI: TW_USERINTERFACE;
begin

  N_Dump1Str( format( 'TWGCloseDS start DSMOpened=%s DSOpened=%s DSEnabled=%s',
              [N_B2S(TWGDSMOpened), N_B2S(TWGDSOpened), N_B2S(TWGDSEnabled)] ) );
  if TWGDSMOpened then // Close Data Source Manager
  begin

    if TWGDSOpened then // Close Data Source
    begin

      if TWGDSEnabled then // Disable Data Source
      begin
//        twUI.hParent := Application.Handle;
{
        twUI.hParent := TWGWinHandle;
        twUI.ShowUI := TW_BOOL(TWON_DONTCARE8); (*!!!!*)
}
        FillChar( twUI, SizeOf(twUI), 0 );

//        twUI.hParent := TWGWinHandle;
//        twUI.ShowUI  := True;
//        twUI.ModalUI := True;

//        twUI.hParent := TWGWinHandle;
//        twUI.ShowUI  := TW_BOOL(TWON_DONTCARE8); (*!!!!*)
//        twUI.ModalUI := False;

        TWGCall( @TWGDSID, DG_CONTROL, DAT_USERINTERFACE, MSG_DISABLEDS, @twUI );

        if TWGRetCode <> TWRC_SUCCESS then
          N_Dump1Str( Format( 'TWGCloseDS >> Disable DS UI Error %d', [TWGRetCode] ));

        TWGDSEnabled := False;
      end; // if TWGDSEnabled then // Disable Data Source

      TWGCall( nil, DG_CONTROL, DAT_IDENTITY, MSG_CLOSEDS, @TWGDSID );

      if TWGRetCode <> TWRC_SUCCESS then
        N_Dump1Str( Format( 'TWGCloseDS >> Close DS Error %d', [TWGRetCode] ));

      TWGDSOpened := False;
    end; // if TWGDSOpened then // Close Data Source

    TWGCall( nil, DG_CONTROL, DAT_PARENT, MSG_CLOSEDSM, @TWGWinHandle );

    if TWGRetCode <> TWRC_SUCCESS then
      N_Dump1Str( Format( 'TWGCloseDS >> Close DSM Error %d', [TWGRetCode] ));

    TWGDSMOpened := False;
  end; // if TWGDSMOpened then // Close Data Source Manager

  FreeAndNil(TWGLastDIBObj); // Free Last Captured DIB

end; // procedure TK_TWGlobObj.TWGCloseDS;

//************************************************* TK_TWGlobObj.TWGCall(5) ***
// Just Call DSM_Entry with pDest parametr
//
procedure TK_TWGlobObj.TWGCall( pDest: pTW_IDENTITY; DG: TW_UINT32; DAT: TW_UINT16;
                                MSG: TW_UINT16; pData: TW_MEMREF );
begin
  TWGRetCode := TWGDSMEntry( @TWGAppID, pDest, DG, DAT, MSG, pData );
  N_Dump2Str( format( 'TWGCall %x %x %x RC %d', [DG, DAT, MSG, TWGRetCode] ) );
end; // procedure TK_TWGlobObj.TWGCall

//************************************************* TK_TWGlobObj.TWGCall(4) ***
// Just Call DSM_Entry without pDest parametr
//
procedure TK_TWGlobObj.TWGCall( DG: TW_UINT32; DAT: TW_UINT16;
                                MSG: TW_UINT16; pData: TW_MEMREF );
begin
  TWGRetCode := TWGDSMEntry( @TWGAppID, @TWGDSID, DG, DAT, MSG, pData );
end; // procedure TK_TWGlobObj.TWGCall

//****************************************** TK_TWGlobObj.TWGOpenDSManager ***
// Open TWAIN Data Source Manager
//
//     Parameters
//
// APWinHandle - Pointer to Windows Handle, that will process all messages
//
procedure TK_TWGlobObj.TWGOpenDSManager( APWinHandle: TW_MEMREF = nil );
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

//  if (APWinHandle = nil) or (PInteger(APWinHandle)^ = 0) then
//    APWinHandle := @TWGWinHandle;
  if (APWinHandle <> nil) and (PInteger(APWinHandle)^ <> 0) then
    TWGWinHandle := PLongWord(APWinHandle)^;
  APWinHandle := @TWGWinHandle;

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

end; // procedure TK_TWGlobObj.TWGOpenDSManager

//***************************************** TK_TWGlobObj.TWGGetDataSources ***
// Get all currently available TWAIN Data Sources Names
//
//     Parameters
// ADSNames - on output, resulting list of TWAIN Data Sources Names
//
// As TWAIN Data Source Name TW_IDENTITY.ProductName field is used.
//
// Should be called after TWGOpenDSManager call.
//
procedure TK_TWGlobObj.TWGGetDataSources( ADSNames: TStrings );
var
 WS : string;
begin
  Assert( TWGDSMOpened,    'DSM not opened!' ); // a precaution
  Assert( not TWGDSOpened, 'DS is opened!' );   // a precaution

  TWGErrorStr := '';
  ADSNames.Clear();

  N_Dump2Str( 'TWGGetDataSources start' );
  TWGCall( nil, DG_CONTROL, DAT_IDENTITY, MSG_GETFIRST, @TWGDSID );

  while True do // loop along all available Data Sources
  begin
    if TWGRetCode = TWRC_ENDOFLIST then // no more Data Sources
    begin
      TWGRetCode := TWRC_SUCCESS;
      N_Dump2Str( 'TWGGetDataSources fin' );
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

    WS := N_AnsiToString( TWGDSID.ProductName );
    N_Dump2Str( 'TWGGetDataSources add >>' + WS );
    ADSNames.Add( WS );

    TWGCall( nil, DG_CONTROL, DAT_IDENTITY, MSG_GETNEXT, @TWGDSID );
  end; // while True do // loop along all available Data Sources

end; // procedure TK_TWGlobObj.TWGGetDataSources

//***************************************** TK_TWGlobObj.TWGOpenDataSource ***
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
procedure TK_TWGlobObj.TWGOpenDataSource( ADSName: AnsiString = '' );
begin
  Assert( TWGDSMOpened,    'DSM not opened!' ); // a precaution
  Assert( not TWGDSOpened, 'DS is opened!' );   // a precaution
  if ADSName = '' then
    ADSName := TWGDSName;

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
end; // procedure TK_TWGlobObj.TWGOpenDataSource

//***************************************** TK_TWGlobObj.TWGNativeTransfer ***
// Get Image Info
//
procedure TK_TWGlobObj.TWGGetImageInfo( APImageInfo : PTWImageInfo  );
begin
  // Get Image resolution in DPI in XYResolution
  ZeroMemory( APImageInfo, SizeOf(TW_IMAGEINFO) );
  TWGXYResolution.X := 0;
  TWGCall( @TWGDSID, DG_IMAGE, DAT_IMAGEINFO, MSG_GET, APImageInfo );

  if TWGRetCode <> TWRC_SUCCESS then
  begin
    TWGErrorStr := 'TWAIN get image info error!';
    N_Dump1Str( Format( 'TWGGetImageInfo >> DG_IMAGE, DAT_IMAGEINFO, MSG_GET failed. TWGRetCode=%d', [TWGRetCode] ));
    Exit;
  end
  else // TWGRetCode = TWRC_SUCCESS continue working
  begin
    with APImageInfo^ do
    begin
      TWGXYResolution.X := K_TWGFix32ToDouble( XResolution );
      TWGXYResolution.Y := K_TWGFix32ToDouble( YResolution );
      N_Dump1Str( Format( 'TWAIN >> WxH=%dx%d DPI(X,Y)=%f,%f PixType=%d  Bits/P=%d Samples/P=%d Bits/S=%s Compr=%d',
                         [ImageWidth, ImageWidth, TWGXYResolution.X, TWGXYResolution.Y, PixelType, BitsPerPixel, SamplesPerPixel,
                          N_ConvSmallIntsToStr(@BitsPerSample[0],SamplesPerPixel,','),Compression] ));
    end;
  end;
end; // procedure TK_TWGlobObj.TWGGetImageInfo

//***************************************** TK_TWGlobObj.TWGNativeTransfer ***
// Get one Image in Native Transfer mode
//
// Should be called in event loop after MSG_XFERREADY message received
// after call TWGRetCode should be checked. TWGRetCode <> TWRC_SUCCESS means error
//
procedure TK_TWGlobObj.TWGNativeTransfer();
var
 hDIB: TW_UINT32;
 MemPtr: Pointer;
 TWImageInfo: TW_IMAGEINFO;
begin

  // Get Image resolution in DPI in XYResolution
  TWGGetImageInfo( @TWImageInfo );
  if TWGRetCode <> TWRC_SUCCESS then Exit;

  // get acquired Image handle
  TWGCall( @TWGDSID, DG_IMAGE, DAT_IMAGENATIVEXFER, MSG_GET, @hDIB );
  N_Dump1Str( Format( 'TWAIN NativeTransfer 3: TWGRetCode=%d', [TWGRetCode] ) );

  if TWGRetCode <> TWRC_XFERDONE then
    N_Dump1Str( Format( 'TWAIN NativeTransfer 4: TWGRetCode=%d', [TWGRetCode] ) );

  case TWGRetCode of

    TWRC_XFERDONE: // hDIB is ready, create TN_DIBObj from it
      begin
        TWGLastDIBObj.Free;
        TWGLastDIBObj := TN_DIBObj.Create();
        MemPtr := GlobalLock( hDIB );
        TWGLastDIBObj.LoadFromMemBMP( MemPtr );

        if TWGXYResolution.X <> 0 then
          with TWGLastDIBObj.DIBInfo.bmi do
          begin
            biXPelsPerMeter := Round( TWGXYResolution.X * 1000 / N_InchInmm );
            biYPelsPerMeter := Round( TWGXYResolution.Y * 1000 / N_InchInmm );
          end;

        with TWGLastDIBObj,DIBInfo.bmi do
          N_Dump1Str( Format( 'TWAIN NativeTransfer >> Pels/M(X,Y)=%d,%d PixFMT=%d PixEFMT=%d WxH=%dx%d',
                               [biXPelsPerMeter, biYPelsPerMeter, Ord(DIBPixFmt), Ord(DIBExPixFmt),
                                biWidth,biHeight] ));

        GlobalUnlock( hDIB );
        GlobalFree( hDIB );

        TWGErrorStr := '';
      end; // TWRC_XFERDONE: // hDIB is ready, create TN_DIBObj from it

    TWRC_CANCEL: // ??
    begin
      TWGErrorStr := 'TWAIN Image Transfer Cancelled!';
      N_Dump1Str( Format( 'TWAIN NativeTransfer >> TWRC_CANCEL >> %s', [TWGErrorStr] ));
    end; // TWRC_CANCEL: // ??

    TWRC_FAILURE: // ???
    begin
      TWGErrorStr := 'TWAIN Image Transfer Failure!';
      N_Dump1Str( Format( 'TWAIN NativeTransfer >> TWRC_FAILURE >> %s', [TWGErrorStr] ));
    end; // TWRC_FAILURE: // ???

  end; // case TWGRetCode of
end; // procedure TK_TWGlobObj.TWGNativeTransfer

//******************************************** TK_TWGlobObj.TWGFileTransfer ***
// Get one Image in File Transfer mode
//
// Should be called in event loop after MSG_XFERREADY message received
// after call TWGRetCode should be checked. TWGRetCode <> TWRC_SUCCESS means error
//
procedure TK_TWGlobObj.TWGFileTransfer();
var
 TWSETUPFILEXFER : TW_SETUPFILEXFER;
 FileName : string;
 DefFileName : string;
 LoadResCode : Integer;
begin

{ // try to fix CanoScan LiDE 700F
  ZeroMemory( @TWSETUPFILEXFER, SizeOf(TWSETUPFILEXFER) );
  DefFileName := '';

  TWGCall( @TWGDSID, DG_CONTROL, DAT_SETUPFILEXFER, MSG_GETDEFAULT, @TWSETUPFILEXFER );
//  TWGCall( @TWGDSID, DG_CONTROL, DAT_SETUPFILEXFER, MSG_GETCURRENT, @TWSETUPFILEXFER );
//  TWGCall( @TWGDSID, DG_CONTROL, DAT_SETUPFILEXFER, MSG_GET, @TWSETUPFILEXFER );
  if TWGRetCode <> TWRC_SUCCESS then // some Error
  begin
    TWGErrorStr := 'TWAIN Image File Get Default Setup Failure!';
    N_Dump1Str( Format( 'TWAIN FileTransfer >> DAT_SETUPFILEXFER MSG_GETDEFAULT TWGRetCode=%d', [TWGRetCode] ) );
  end
  else
  begin
    DefFileName := N_AnsiToString( PAnsiChar(@TWSETUPFILEXFER.FileName[0]) );
    if DefFileName[1] <> '\' then
      DefFileName := GetCurrentDir() + DefFileName
    else
      DefFileName := 'C:' + DefFileName;
    DefFileName := DefFileName;
  end;
{}
{}
  ZeroMemory( @TWSETUPFILEXFER, SizeOf(TWSETUPFILEXFER) );
  TWSETUPFILEXFER.Format := TWGDSTransfFileFormatCur;

  FileName := K_ExpandFileName( '(#TmpFiles#)TWAINResult.dat' );
  Move( N_StringToAnsi( FileName )[1], TWSETUPFILEXFER.FileName[0], Length(FileName) );

  TWGCall( @TWGDSID, DG_CONTROL, DAT_SETUPFILEXFER, MSG_SET, @TWSETUPFILEXFER );

  if TWGRetCode <> TWRC_SUCCESS then // some Error
  begin
    TWGErrorStr := 'TWAIN Image File Setup Failure!';
    N_Dump1Str( Format( 'TWAIN FileTransfer >> DAT_SETUPFILEXFER TWGRetCode=%d', [TWGRetCode] ) );
    if DefFileName = '' then
      Exit
    else
      FileName := DefFileName;
  end;
{}
  // get acquired Image to file
  TWGCall( @TWGDSID, DG_IMAGE, DAT_IMAGEFILEXFER, MSG_GET, nil );

  if TWGRetCode <> TWRC_XFERDONE then
    N_Dump1Str( Format( 'TWAIN FileTransfer >> DAT_IMAGEFILEXFER TWGRetCode=%d', [TWGRetCode] ) );

  case TWGRetCode of
    TWRC_XFERDONE:
    begin
      FreeAndNil(TWGLastDIBObj);
      LoadResCode := N_LoadDIBFromFile( TWGLastDIBObj, FileName );
      if LoadResCode <> 0 then
      begin
        TWGErrorStr := 'TWAIN Image File Load Error!';
        N_Dump1Str( Format( 'TWAIN FileTransfer >> Image Load Error=%d', [LoadResCode] ) );
      end
      else
      with TWGLastDIBObj,DIBInfo.bmi do
        N_Dump1Str( Format( 'TWAIN FileTransfer >> Pels/M(X,Y)=%d,%d PixFMT=%d PixEFMT=%d WxH=%dx%d',
                             [biXPelsPerMeter, biYPelsPerMeter, Ord(DIBPixFmt), Ord(DIBExPixFmt),
                              biWidth,biHeight] ));
      if DefFileName = FileName then
        K_DeleteFile( FileName );
    end;

    TWRC_CANCEL: // ??
    begin
      TWGErrorStr := 'TWAIN Image File Transfer Cancelled!';
      N_Dump1Str( Format( 'TWAIN FileTransfer >> TWRC_CANCEL >> %s', [TWGErrorStr] ) );
    end; // TWRC_CANCEL: // ??

    TWRC_FAILURE: // ???
    begin
      TWGErrorStr := 'TWAIN Image File Transfer Failure!';
      N_Dump1Str( Format( 'TWAIN FileTransfer >> TWRC_FAILURE >> %s', [TWGErrorStr] ));
    end; // TWRC_FAILURE: // ???

  end; // case TWGRetCode of
end; // procedure TK_TWGlobObj.TWGFileTransfer

//********************************************* TK_TWGlobObj.TWGMemTransfer ***
// Get one Image in Memory Transfer mode
//
// Should be called in event loop after MSG_XFERREADY message received
// after call TWGRetCode should be checked. TWGRetCode <> TWRC_SUCCESS means error
//
procedure TK_TWGlobObj.TWGMemTransfer();
var
  TWImageInfo: TW_IMAGEINFO;
  TWSETUPMEMXFER :TW_SETUPMEMXFER;
  TWIMAGEMEMXFER : TW_IMAGEMEMXFER;
  HMem: THandle;
  FailurInfo : string;
  BufCount : Integer;
  TWPalette8 : TW_Palette8;
  PPalette : pTW_PALETTE8;
//  FPixFmt: TPixelFormat;
//  FExPixFmt: TN_ExPixFmt;
begin
//  HMem := Windows.GlobalAlloc( GMEM_MOVEABLE, ABufSize );


  ZeroMemory( @TWSETUPMEMXFER, SizeOf(TWSETUPMEMXFER) );
  TWGCall( @TWGDSID, DG_CONTROL, DAT_SETUPMEMXFER, MSG_GET, @TWSETUPMEMXFER );

  if TWGRetCode <> TWRC_SUCCESS then // some Error
  begin
    TWGErrorStr := 'TWAIN Image Memory Setup error!';
    N_Dump1Str( Format( 'TWAIN MemTransfer >> DAT_SETUPMEMXFER TWGRetCode=%d', [TWGRetCode] ) );
    Exit;
  end;

  TWGGetImageInfo( @TWImageInfo );
  if TWGRetCode <> TWRC_SUCCESS then Exit;

  PPalette := nil;
  if TWImageInfo.PixelType = TWPT_PALETTE then
  begin
    ZeroMemory( @TWPalette8, SizeOf(TW_Palette8) );
    PPalette := @TWPalette8;
    TWGCall( @TWGDSID, DG_IMAGE, DAT_PALETTE8, MSG_GET, PPalette );
    if TWGRetCode <> TWRC_SUCCESS then
    begin
      N_Dump1Str( Format( 'TWAIN MemTransfer >> DAT_PALETTE8 TWGRetCode=%d', [TWGRetCode] ) );
      TWGErrorStr := 'TWAIN Image palette get error!';
      Exit;
    end
    else
    if TWPalette8.PaletteType <> TWPA_RGB then
    begin
      N_Dump1Str( Format( 'TWAIN MemTransfer >> DAT_PALETTE8 PaletteType=%d', [TWPalette8.PaletteType] ) );
      TWGErrorStr := 'TWAIN Image wrong palette type!';
      Exit;
    end;
  end;

  TWIMAGEMEMXFER.Memory.Length := TWSETUPMEMXFER.Preferred;
  HMem := Windows.GlobalAlloc( GMEM_MOVEABLE, TWIMAGEMEMXFER.Memory.Length );
  if (HMem = 0) and
     (TWSETUPMEMXFER.MinBufSize < TWSETUPMEMXFER.Preferred) then // not enough memory
  begin
    TWIMAGEMEMXFER.Memory.Length := TWSETUPMEMXFER.MinBufSize;
    HMem := Windows.GlobalAlloc( GMEM_MOVEABLE, TWIMAGEMEMXFER.Memory.Length );
  end;

  if HMem = 0 then // not enough memory
  begin
    TWGRetCode := TWRC_FAILURE;
    TWGErrorStr := 'TWAIN not enough memory!';
    N_Dump1Str( Format( 'TWAIN MemTransfer >> not enough memory %d', [TWIMAGEMEMXFER.Memory.Length] ));
    Exit;
  end;
//  TWIMAGEMEMXFER.Memory.TheMem := Pointer(HMem);
//  TWIMAGEMEMXFER.Memory.Flags := TWMF_APPOWNS or TWMF_HANDLE;
  TWIMAGEMEMXFER.Memory.TheMem := GlobalLock( HMem );
  TWIMAGEMEMXFER.Memory.Flags := TWMF_APPOWNS or TWMF_POINTER;

  TWGLastDIBObj.Free;
  TWGLastDIBObj := K_CMCreateTWAINBufferDIB( @TWImageInfo );
  if Integer(TWGLastDIBObj) < 10 then
  begin
    N_Dump1Str( Format( 'TWAIN MemTransfer >> Unknown Image format Err=%d', [Integer(TWGLastDIBObj)] ));
    TWGErrorStr := 'TWAIN unknown Image format';
    TWGLastDIBObj := nil;
    Exit;
  end;

  with TWGLastDIBObj.DIBInfo.bmi do
  begin
    biXPelsPerMeter := Round( TWGXYResolution.X * 1000 / N_InchInmm );
    biYPelsPerMeter := Round( TWGXYResolution.Y * 1000 / N_InchInmm );
  end;

  with TWGLastDIBObj,DIBInfo.bmi do
    N_Dump1Str( Format( 'TWAIN MemTransfer >> Pels/M(X,Y)=%d,%d PixFMT=%d PixEFMT=%d WxH=%dx%d NumBits=%d',
                         [biXPelsPerMeter, biYPelsPerMeter, Ord(DIBPixFmt), Ord(DIBExPixFmt),
                          biWidth, biHeight, DIBNumBits] ));

  BufCount := 0;
  repeat
    TWIMAGEMEMXFER.Compression  := TWON_DONTCARE16;
    TWIMAGEMEMXFER.BytesPerRow  := TWON_DONTCARE32;
    TWIMAGEMEMXFER.Columns      := TWON_DONTCARE32;
    TWIMAGEMEMXFER.Rows         := TWON_DONTCARE32;
    TWIMAGEMEMXFER.XOffset      := TWON_DONTCARE32;
    TWIMAGEMEMXFER.YOffset      := TWON_DONTCARE32;
    TWIMAGEMEMXFER.BytesWritten := TWON_DONTCARE32;

    TWGCall( @TWGDSID, DG_IMAGE, DAT_IMAGEMEMXFER, MSG_GET, @TWIMAGEMEMXFER );
    if ((TWGRetCode = TWRC_SUCCESS) or (TWGRetCode = TWRC_XFERDONE)) and
       (TWIMAGEMEMXFER.BytesWritten > 0) then
    begin
      if K_CMCopyPixelsFromTWAINBufferToDIB( TWGLastDIBObj, @TWImageInfo,
                                             @TWIMAGEMEMXFER, PPalette ) = 1 then
      begin
        TWGRetCode := TWRC_FAILURE;
        FailurInfo := 'TWAIN couldn'' copy pixels from Image memory buffer!';
        break;
      end;
      Inc(BufCount);
    end;
  until TWGRetCode <> TWRC_SUCCESS;

  N_Dump2Str( Format( 'TWAIN MemTransfer >> fin BufCont=%dx', [BufCount] ));

  GlobalUnlock( HMem );
  GlobalFree( HMem );

  case TWGRetCode of

    TWRC_XFERDONE: // hDIB is ready, create TN_DIBObj from it
    begin
      TWGErrorStr := '';
    end; // TWRC_XFERDONE: // hDIB is ready, create TN_DIBObj from it

    TWRC_CANCEL: // ??
    begin
      TWGErrorStr := 'TWAIN Image Transfer Cancelled!';
      N_Dump1Str( Format( 'TWAIN MemTransfer >> TWRC_CANCEL >> %s', [TWGErrorStr] ));
    end; // TWRC_CANCEL: // ??

    TWRC_FAILURE: // ???
    begin
      if FailurInfo <> '' then
        TWGErrorStr := FailurInfo
      else
        TWGErrorStr := 'TWAIN Image Transfer Failure!';
      N_Dump1Str( Format( 'TWAIN MemTransfer >> TWRC_FAILURE >> %s', [TWGErrorStr] ));
    end; // TWRC_FAILURE: // ???
  end; // case TWGRetCode of
end; // procedure TK_TWGlobObj.TWGMemTransfer

//*********************************************** TK_TWGlobObj.TWGInitModes ***
// Init Transfere Mode
//
//
procedure TK_TWGlobObj.TWGInitModes();
var
  i: Integer;
  twCAP: TW_CAPABILITY;
  FCaps : TN_IArray;
  FCurInd, FDefInd : Integer;
begin

  Assert( TWGDSMOpened, 'DSM not opened!' ); // a precaution
  Assert( TWGDSOpened,  'DS not opened!' );  // a precaution
  TWGErrorStr := '';

  //***** Get available transfer modes
  N_Dump2Str( 'TWGInitModes >> Get available transfer modes start' );

  TWGDSTransfModeNative := FALSE;
  TWGDSTransfModeFile := FALSE;
  TWGDSTransfModeMem := FALSE;
  TWGDSTransfModeMemFile := FALSE;
  TWGDSTransfFileFormatBMP:= FALSE;
  TWGDSTransfFileFormatPNG:= FALSE;
  TWGDSTransfFileFormatTIF:= FALSE;
  TWGDSTransfFileFormatJPG:= FALSE;

  twCAP.Cap        := ICAP_XFERMECH;
  twCAP.ConType    := TWON_DONTCARE16;
  twCAP.hContainer := 0;

  TWGCall( @TWGDSID, DG_CONTROL, DAT_CAPABILITY, MSG_GET, @twCAP );
  if TWGRetCode <> TWRC_SUCCESS then // some Error
  begin
    N_Dump1Str( Format( 'TWGInitModes >> ICAP_XFERMECH TWGRetCode=%d', [TWGRetCode] ) );
    Exit;
  end;

  if TWGParseCaps( FCaps, @twCAP, FCurInd, FDefInd ) then
  begin
    for i := 0 to High(FCaps) do
    begin
      case FCaps[i] of
      TWSX_NATIVE : TWGDSTransfModeNative  := TRUE;
      TWSX_FILE   : TWGDSTransfModeFile    := TRUE;
      TWSX_MEMORY : TWGDSTransfModeMem     := TRUE;
      TWSX_MEMFILE: TWGDSTransfModeMemFile := TRUE;
      end;
    end; // for i := 0 to NumItems - 1 do

    if FCurInd >= 0 then
      TWGDSTransfModeCur := FCaps[FCurInd];
    if FDefInd >= 0 then
      TWGDSTransfModeDefault := FCaps[FDefInd];
  end; // if TWGParseCaps( ...

  GlobalFree( twCAP.hContainer );

  //***** Get available File Formats

  N_Dump1Str( format( 'TWGInitModes >> Transfer modes Native=%s File=%s Memory=%s',
              [N_B2S(TWGDSTransfModeNative),
               N_B2S(TWGDSTransfModeFile),
               N_B2S(TWGDSTransfModeMem)] ) );

  if not TWGDSTransfModeFile then Exit;

  N_Dump2Str( 'TWGInitModes >> Get available File Formats start' );

  twCAP.Cap        := ICAP_IMAGEFILEFORMAT;
  twCAP.ConType    := TWON_DONTCARE16;
  twCAP.hContainer := 0;

  TWGCall( @TWGDSID, DG_CONTROL, DAT_CAPABILITY, MSG_GET, @twCAP );
  if TWGRetCode <> TWRC_SUCCESS then // some Error
  begin
    N_Dump1Str( Format( 'TWGInitModes >> ICAP_IMAGEFILEFORMAT TWGRetCode=%d', [TWGRetCode] ) );
    Exit;
  end;

  if TWGParseCaps( FCaps, @twCAP, FCurInd, FDefInd ) then
  begin
    for i := 0 to High(FCaps) do
    begin
      case FCaps[i] of
      TWFF_BMP : TWGDSTransfFileFormatBMP := TRUE;
      TWFF_PNG : TWGDSTransfFileFormatPNG := TRUE;
      TWFF_TIFF: TWGDSTransfFileFormatTIF := TRUE;
      TWFF_JFIF: TWGDSTransfFileFormatJPG := TRUE;
      end;
    end; // for i := 0 to NumItems - 1 do

    if FCurInd >= 0 then
      TWGDSTransfFileFormatCur := FCaps[FCurInd];
    if FDefInd >= 0 then
      TWGDSTransfFileFormatDefault := FCaps[FDefInd];
  end; // if TWGParseCaps( ...
  GlobalFree( twCAP.hContainer );

  N_Dump1Str( format( 'TWGInitModes >> File formats BMP=%s PNG=%s TIF=%s JPG=%s',
              [N_B2S(TWGDSTransfFileFormatBMP),
               N_B2S(TWGDSTransfFileFormatPNG),
               N_B2S(TWGDSTransfFileFormatTIF),
               N_B2S(TWGDSTransfFileFormatJPG)] ) );

  // Correct FileTransfer Mode and Format
  TWGDSTransfModeFile := TWGDSTransfFileFormatBMP or
                         TWGDSTransfFileFormatPNG or
                         TWGDSTransfFileFormatTIF or
                         TWGDSTransfFileFormatJPG;
  if not TWGDSTransfModeFile then Exit;

  if (TWGDSTransfFileFormatCur <> TWFF_BMP)  and
     (TWGDSTransfFileFormatCur <> TWFF_PNG)  and
     (TWGDSTransfFileFormatCur <> TWFF_TIFF) and
     (TWGDSTransfFileFormatCur <> TWFF_JFIF) then
  begin
    if TWGDSTransfFileFormatTIF then
      TWGDSTransfFileFormatCur := TWFF_TIFF
    else
    if TWGDSTransfFileFormatPNG then
      TWGDSTransfFileFormatCur := TWFF_PNG
    else
    if TWGDSTransfFileFormatBMP then
      TWGDSTransfFileFormatCur := TWFF_BMP
    else
    if TWGDSTransfFileFormatJPG then
      TWGDSTransfFileFormatCur := TWFF_JFIF;
  end;

end; // procedure TK_TWGlobObj.TWGInitModes

//************************************************ TK_TWGlobObj.TWGShowDSUI ***
// Start acquiring Images by TWAIN
//
// Start acquiring one or several Images from current Data Source in TWGDSID using
// TWAIN Data Source User interface.
// Acquired (resulting) images will be in TWGDIBs array of TN_DIBObject.
// TWGNumDibs is number of Acquired Images in TWGDIBs Array
//
// As TWAIN Source Name TW_IDENTITY.ProductName field is used.
//
function TK_TWGlobObj.TWGShowDSUI() : TW_UINT16;
var
  twUI: TW_USERINTERFACE;
begin
  Assert( TWGDSMOpened, 'DSM not opened!' ); // a precaution
  Assert( TWGDSOpened,  'DS not opened!' );  // a precaution
  TWGErrorStr := '';

  TWGCall( nil, DG_CONTROL, DAT_STATUS, MSG_GET, @TWGSTATUS );
  N_Dump1Str( Format( 'TWShowDSUI >> Before ShowUI Scanner status=%d', [TWGSTATUS.ConditionCode] ) );

  //***** Show User Interface

  FillChar( twUI, SizeOf(twUI), 0 );

  twUI.hParent := TWGWinHandle;
  twUI.ShowUI  := True;
  twUI.ModalUI := not TWGUINotModal;

  TWGCall( @TWGDSID, DG_CONTROL, DAT_USERINTERFACE, MSG_ENABLEDS, @twUI );
  N_Dump1Str( 'TWShowDSUI >> After ShowUI' );
  Result := TWGRetCode;
  if TWGRetCode <> TWRC_SUCCESS then // some Error
  begin
    TWGDSEnabled := False;
    TWGErrorStr := 'TWAIN Error while show user interface';
    N_Dump1Str( Format( 'TWShowDSUI >> TWGRetCode=%d >> %s', [TWGRetCode,TWGErrorStr] ) );

    //***** Close close DS and DSM
    TWGCloseDS(); // Close Data Source Manager and Data Source
  end // if TWGRetCode <> TWRC_TWRC_SUCCESS then // some Error
  else
    TWGDSEnabled := True; // is used in error checking and in destructor

  //***** Now Applications should wait for messages from Data Source
  //      these messages are processed by TWGHandleMessage1
  //      All other actions are called from TWGHandleMessage1

end; // procedure TK_TWGlobObj.TWShowGDSUI

//*********************************************** TK_TWGlobObj.TWGParseCaps ***
// Parse list of Capabilities
//
//     Parameters
// AAvCaps   - list of resulting Capalities (on output)
// APTWCap   - pointer to TW_CAPABILITY record get by TWGCall( DG_CONTROL, DAT_CAPABILITY, MSG_GET, APTWCap )
// ACurInd   - index of current Value
// ADefInd   - index of default Value
// Result    - Returns TRUE if parsing was success
//
function TK_TWGlobObj.TWGParseCaps( var AAvCaps: TN_IArray; APTWCap: PTWCapability;
                                    out ACurInd, ADefInd : Integer ): Boolean;
var
  i: Integer;
  NumItems: Word;
  PEnum: PTWEnumeration;
  POneValue: PTWOneValue;
  PItem : Pointer;

label UnlockFreeAndExit;

  function GetItemValue( ItemType : Integer; var PItem : Pointer ) : Integer;
  begin
    Result := -1;
    case ItemType of
    TWTY_INT8, TWTY_UINT8: begin
      Result := TN_PByte(PItem)^;
      Inc(TN_PByte(PItem));
    end;
    TWTY_INT16, TWTY_UINT16: begin
      Result := TN_PUInt2(PItem)^;
      Inc(TN_PUInt2(PItem));
    end;
    TWTY_INT32, TWTY_UINT32: begin
      Result := TN_PUInt4(PItem)^;
      Inc(TN_PUInt4(PItem));
    end;
    end;
  end;

begin
  AAvCaps := nil;
  Result := FALSE;
  ACurInd := -1;
  ADefInd := -1;
  AAvCaps := nil;
  case APTWCap^.ConType of
    TWON_ONEVALUE: begin
      POneValue := GlobalLock( APTWCap^.hContainer );
      if POneValue = nil then
      begin
        N_Dump1Str( 'TWGParseCaps Error=3 POneValue=nil' );
        goto UnlockFreeAndExit;
      end;
//    ItemType  : TW_UINT16;
//    Item      : TW_UINT32;
{
      if POneValue^.ItemType <> TWTY_UINT16 then // a precaution
      begin
        N_Dump1Str( Format( 'TWGParseCaps Error=4 OneValue ItemType=%d', [POneValue^.ItemType] ) );
        goto UnlockFreeAndExit;
      end;
}
      SetLength( AAvCaps, 1 );
      AAvCaps[0] := POneValue^.Item;
      ACurInd := 0;
      ADefInd := 0;
      Result := TRUE;
    end;

    TWON_ENUMERATION: begin
      PEnum := GlobalLock( APTWCap^.hContainer );

      if PEnum = nil then
      begin
        N_Dump1Str( 'TWGParseCaps Error=3 PEnum=nil' );
        goto UnlockFreeAndExit;
      end;

      NumItems := PEnum^.NumItems;
{
      if PEnum^.ItemType <> TWTY_UINT16 then // a precaution
      begin
        N_Dump1Str( Format( 'TWGParseCaps Error=4 Enum ItemType=%d', [PEnum^.ItemType] ) );
        goto UnlockFreeAndExit;
      end;
}
      if NumItems = 0 then // a precaution
      begin
        N_Dump1Str( 'TWGParseCaps Error=5 NumItems = 0' );
        goto UnlockFreeAndExit;
      end;

      SetLength( AAvCaps, NumItems ); // NumItems is always >= 1
      PItem := @PEnum^.ItemList[0];

      for i := 0 to High(AAvCaps) do
        AAvCaps[i] := GetItemValue( PEnum^.ItemType, PItem );

      ACurInd := PEnum^.CurrentIndex;
      ADefInd := PEnum^.DefaultIndex;

      Result := TRUE;

    end;
  else
    N_Dump1Str( Format( 'TWGParseCaps Error=2 ContainerType=%d', [APTWCap^.ConType] ) );
    Exit;
  end;

UnlockFreeAndExit: //*****************
  GlobalUnlock( APTWCap^.hContainer );

end; // procedure TK_TWGlobObj.TWGParseCaps


//************************************************* TK_TWGlobObj.TWGGetCaps ***
// Get list of Capabilities available on AGivenCap Capability
//
//     Parameters
// AAvCaps   - list of resulting Capalities (on output)
// AGivenCap - given Capability
// APCurVal  - pointer to Current Value
// Result    - DSMEntry( ... MSG_GET, @twCAP ) TWAIN Return code (TWRC_xxx)
//
function TK_TWGlobObj.TWGGetCaps( var AAvCaps: TN_IArray; AGivenCap: Word;
                                  APCurVal : PInteger = nil ): Word;
var
  TmptwCAP: TW_CAPABILITY;
  PCap: PTWCapability;
   FCurInd, FDefInd : Integer;
begin
  AAvCaps := nil;

  PCap := @TmptwCAP;

  PCap^.Cap        := AGivenCap;
  PCap^.ConType    := TWON_DONTCARE16;
  PCap^.hContainer := 0;

  TWGCall( DG_CONTROL, DAT_CAPABILITY, MSG_GET, PCAP );
  Result := TWGRetCode;

  if TWGRetCode <> TWRC_SUCCESS then // some Error
    N_Dump1Str( Format( 'TWGGetCaps Error=1 TWGRetCode=%d', [TWGRetCode] ) )
  else
  begin
    if TWGParseCaps( AAvCaps, PCap, FCurInd, FDefInd ) then
    begin
      if APCurVal <> nil then
      if FCurInd >= 0 then
        APCurVal^ := AAvCaps[FCurInd]
      else
        APCurVal^ := -1;
    end;
  end;
  GlobalFree( PCap^.hContainer );

end; // procedure TK_TWGlobObj.TWGGetCaps

//*********************************************** TK_TWGlobObj.TWGGetCurCap ***
// Get current value of AGivenCap Capability
//
//     Parameters
// AGivenCap - given Capability
// ACurCap   - resulting current Capability of AGivenCap (on output)
// Result    - DSMEntry( ... MSG_GET, @twCAP ) TWAIN Return code (TWRC_xxx)
//
function TK_TWGlobObj.TWGGetCurCap( AGivenCap: Word; var ACurCap: Integer ): Word;
var
  AvCaps: TN_IArray;
begin
  Result := TWGGetCaps( AvCaps, AGivenCap, @ACurCap );
end; // procedure TK_TWGlobObj.TWGGetCurCap

//*********************************************** TK_TWGlobObj.TWGSetCurCap ***
// Set current value of AGivenCap Capability
//
//     Parameters
// AGivenCap  - given Capability
// ANewCurCap - given New current value of Capability of AGivenCap
// Result     - DSMEntry( ... MSG_SET, @twCAP ) TWAIN Return code (TWRC_xxx)
//
function TK_TWGlobObj.TWGSetCurCap( AGivenCap: Word; ANewCurCap: Word ): Word;
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
end; // procedure TK_TWGlobObj.TWGSetCurCap

//***************************************** TK_TWGlobObj.TWGGetBitDepthCaps ***
// Add BitDepth related Capabilities to given AStrings
//
//     Parameters
// AStrings - given AStrings with all needed Capabilities
//
procedure TK_TWGlobObj.TWGGetBitDepthCaps( AStrings: TStrings );
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
                N_ConvIntsToStr( @PixTypeArray[0], Length(PixTypeArray), ', '  ) +
                '  ( 0-BW, 1-Gray, 2-RGB )' );

  for iPixType := 0 to High(PixTypeArray) do // along all supported Pixel Types
  begin
    TWGSetCurCap( ICAP_PIXELTYPE, PixTypeArray[iPixType] );
    TWGGetCaps( BitDepthsArray, ICAP_BITDEPTH );

    if BitDepthsArray <> nil then AStrings.Add( 'PixType=' +
                IntToStr(PixTypeArray[iPixType]) + ' Supported Bit Depths: ' +
                N_ConvIntsToStr( @BitDepthsArray[0], Length(BitDepthsArray), ', ' ) );
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
                N_ConvIntsToStr( @FFmtArray[0], Length(FFmtArray), ', '  ) +
                '  ( 0-TIFF, 1-PICT, 2-BMP, 4-JPEG, 6-TIFFMULTI, 7-PNG )' );

    for iFFmt := 0 to High(FFmtArray) do // along all supported File Formats
    begin
      TWGSetCurCap( ICAP_IMAGEFILEFORMAT, FFmtArray[iFFmt] );

      TWGGetCaps( PixTypeArray, ICAP_PIXELTYPE );

      if PixTypeArray <> nil then AStrings.Add( 'FileFmt=' +
               IntToStr(FFmtArray[iFFmt]) + ' Supported Pixel Types: ' +
               N_ConvIntsToStr( @PixTypeArray[0], Length(PixTypeArray), ', '  ) +
               '  ( 0-BW, 1-Gray, 2-RGB )' );

      for iPixType := 0 to High(PixTypeArray) do // along all supported Pixel Types
      begin
        TWGSetCurCap( ICAP_PIXELTYPE, PixTypeArray[iPixType] );
        TWGGetCaps( BitDepthsArray, ICAP_BITDEPTH );

        if BitDepthsArray <> nil then AStrings.Add( 'FileFmt=' +
            IntToStr(FFmtArray[iFFmt]) + ' PixType=' +
            IntToStr(PixTypeArray[iPixType]) + ' Supported Bit Depths: ' +
            N_ConvIntsToStr( @BitDepthsArray[0], Length(BitDepthsArray), ', ' ) );
      end; // for iPixTypes := 1 to High(PixTypeArray) do // along all supported Pixel Types

    end; // for iFFmt := 1 to High(FFmtArray) do // along all supported File Formats

  end; // else // File transfer mode

  AStrings.Add( '' );
  AStrings.Add( '    Memory transfer mode:' );
  TWGSetCurCap( ICAP_XFERMECH, TWSX_MEMORY );
  TWGGetCurCap( ICAP_XFERMECH, CurCap );

  if CurCap <> TWSX_MEMORY then
    AStrings.Add( '    Memory transfer mode not supported!' )
  else // Memoty transfer mode
  begin
    TWGGetCaps( PixTypeArray, ICAP_PIXELTYPE );

    if PixTypeArray <> nil then AStrings.Add( 'Supported Pixel Types: ' +
                  N_ConvIntsToStr( @PixTypeArray[0], Length(PixTypeArray), ', '  ) +
                  '  ( 0-BW, 1-Gray, 2-RGB )' );

    for iPixType := 1 to High(PixTypeArray) do // along all supported Pixel Types
    begin
      TWGSetCurCap( ICAP_PIXELTYPE, PixTypeArray[iPixType] );
      TWGGetCaps( BitDepthsArray, ICAP_BITDEPTH );

      if BitDepthsArray <> nil then AStrings.Add( 'PixType=' +
                  IntToStr(PixTypeArray[iPixType]) + ' Supported Bit Depths: ' +
                  N_ConvIntsToStr( @BitDepthsArray[0], Length(BitDepthsArray), ', ' ) );
    end; // for iPixTypes := 1 to High(PixTypeArray) do // along all supported Pixel Types
  end;

  AStrings.Add( '' );
end; // procedure TK_TWGlobObj.TWGGetBitDepthCaps


//***************************************** TK_TWGlobObj.TWGGetBitDepthCaps ***
// Prpcess TWAIN Event
//
//     Parameters
// AEvent - TWAIN Event structure
// Result - Returns FALSE if Close Source Interface is needed
//
function TK_TWGlobObj.TWGProcEvent( var AEvent: TW_EVENT ) : Boolean;
var
  pending: TW_PENDINGXFERS;
  TransfModeSelect : Boolean;
//  AppMsg: TMsg;
begin
  Result := TRUE;
  Inc( TWGMessageCounter ); // for dump only

//  if N_CMTWAIN_DebugMode then // Use Dump1
//    N_Dump1Str( Format( 'TN_CMTWAIN1Form.TWAINWndProc: Msg:%x %x %x, MC=%d wh=%x, %x',
//       [Msg.Msg,Msg.wParam,Msg.lParam, TWGMessageCounter,TWGWinHandle,Handle] ))
//  else // Use Dump2
  with pMsg(AEvent.pEvent)^ do
  begin
//    if hwnd = TWGWinHandle then // is OK
     N_Dump2Str( Format( 'TWGProcEvent >> Msg:%x %x %x, MC=%d HWND=%x twh=%x',
       [message,wParam,lParam, TWGMessageCounter,hwnd,TWGWinHandle] ));

//    if message = $201 then Exit; // Skip Event $201 !!!
  end;

  // all messages should be immediatly sent back to Data Source
  TWGCall( @TWGDSID, DG_CONTROL, DAT_EVENT, MSG_PROCESSEVENT, @AEvent );
{
  if N_CMTWAIN_DebugMode then // Use Dump1
    N_Dump1Str( Format( 'TWGProcEvent >> after MSG_PROCESSEVENT TWGRetCode=%d TWMessage=%d DSEvent=%s',
                [TWGRetCode, AEvent.TWMessage, N_B2S(TWGRetCode=TWRC_DSEVENT)] ))
  else // Use Dump2
}  
    N_Dump2Str( Format( 'TWGProcEvent >> after MSG_PROCESSEVENT TWGRetCode=%d TWMessage=%d DSEvent=%s',
                [TWGRetCode, AEvent.TWMessage, N_B2S(TWGRetCode=TWRC_DSEVENT)] ));

  if AEvent.TWMessage = 0 then // not TWAIN message
    Exit;

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

  case AEvent.TWMessage of

    MSG_XFERREADY: // =$101, One or more Images are ready for transfering
    begin
      if not TWGDSTransfModeNative and
         not TWGDSTransfModeFile   and
         not TWGDSTransfModeMem then
      begin // precaution
        TWGErrorStr := 'TWAIN driver has no available data transfere modes';
        N_Dump1Str( 'TWGProcEvent >> MSG_XFERREADY >> no available data transfere modes' );
        Result := FALSE;
        Exit;
      end;


      if (TWGDataTransfModeUse = K_twdtmUnassigned) then
      begin
      // Select real Data Transfer Mode
        TWGDataTransfModeUse := TWGDataTransfModeSet;
        TransfModeSelect := FALSE;
        while not TransfModeSelect do
        begin
          case TWGDataTransfModeUse of
            K_twdtmNative : begin
              TransfModeSelect := TWGDSTransfModeNative;
              if not TransfModeSelect then
                TWGDataTransfModeUse := K_twdtmFile;
            end;
            K_twdtmFile   : begin
              TransfModeSelect := TWGDSTransfModeFile;
              if not TransfModeSelect then
                TWGDataTransfModeUse := K_twdtmMemory;
            end;
            K_twdtmMemory : begin
              TransfModeSelect := TWGDSTransfModeMem;
              if not TransfModeSelect then
                TWGDataTransfModeUse := K_twdtmNative;
            end;
          end; // case TWGCurDataTransfereMode of
        end; // while not TransfModeSelect do
      end; // if TWGDataTransfModeUse = K_twdtmUnassigned then

      N_Dump1Str( format( 'TWGProcEvent >> MSG_XFERREADY >> TransfereMode=%d >> %d',
                          [Ord(TWGDataTransfModeSet), Ord(TWGDataTransfModeUse)] ) );

      repeat
        N_Dump2Str( 'TWGProcEvent >> MSG_XFERREADY: // =$101' );
        TWGErrorStr := '';
        case TWGDataTransfModeUse of
          K_twdtmNative : TWGNativeTransfer();// Acquire one Image WIA Native mode
          K_twdtmFile   : TWGFileTransfer(); // Acquire one Image WIA File mode
          K_twdtmMemory : TWGMemTransfer(); // Acquire one Image WIA Memory Buffer mode
        end;


        if TWGRetCode <> TWRC_XFERDONE then // error in TWAIN Transfer
        begin
          N_Dump2Str( Format( 'TWGProcEvent >> Error in Image Tansfere, TWGRetCode=%d', [TWGRetCode] ));

          // cancel (abort) all pending Images
          TWGCall( @TWGDSID, DG_CONTROL, DAT_PENDINGXFERS, MSG_RESET, @pending );
          if TWGRetCode <> TWRC_SUCCESS then // in Reset All Pending Images
            N_Dump1Str( Format( 'TWGProcEvent >> Error in Reset All Pending Images, TWGRetCode=%d', [TWGRetCode] ));

          TWGAcquiredOK := False; // not really needed
          Result := FALSE;
          Exit;
        end; // if TWGRetCode <> TWRC_SUCCESS then // error in TWGNativeTransfer

        if Assigned(TWGOnImageTransferedProcObj) then
          TWGOnImageTransferedProcObj();

//        SavedCount := pending.Count;
        // Check for Pending Transfers
        TWGCall( @TWGDSID, DG_CONTROL, DAT_PENDINGXFERS, MSG_ENDXFER, @pending );

        if TWGRetCode <> TWRC_SUCCESS then // error in getting pending.count
        begin
          N_Dump1Str( Format( 'TWGProcEvent >> Error in getting pending.count, TWGRetCode=%d', [TWGRetCode] ));

          // cancel (abort) all pending Images
          TWGCall( @TWGDSID, DG_CONTROL, DAT_PENDINGXFERS, MSG_RESET, @pending );
          if TWGRetCode <> TWRC_SUCCESS then // in Reset All Pending Images
            N_Dump1Str( Format( 'TWGProcEvent >> Error in Reset All Pending Images, TWGRetCode=%d', [TWGRetCode] ));
          TWGAcquiredOK := False; // not really needed
          Result := FALSE;
          Exit;
        end; // if TWGRetCode <> TWRC_SUCCESS then // error in getting pending.count

        //***** here: pending.count is OK, continue loop if pending.count <> 0
        N_Dump1Str( Format( 'TWGProcEvent >> MSG_XFERREADY pending.count=%d', [pending.count] ));

      until pending.Count = 0; // loop along all pending Images

      //***** Here: after   While pending.Count <> 0 do   loop:
      //            all images ready images are processed (saved to TWGDIBs Array)
      //            wait for possible more images

      N_Dump1Str( 'TWGProcEvent >> MSG_XFERREADY Fin' );
      TWGCall( nil, DG_CONTROL, DAT_STATUS, MSG_GET, @TWGSTATUS );
//      TWGCall( nil, DG_CONTROL, DAT_STATUS, MSG_GET, @TWGSTATUS );
//      TWGCall( nil, DG_CONTROL, DAT_STATUS, MSG_GET, @TWGSTATUS );
//      TimerSys.Enabled := True;
      Exit; // TWAIN Ready Transfer Message processed

    end; // MSG_XFERREADY: // One or more Images are ready for transfering

    MSG_CLOSEDSREQ: // =$102, Acquiring was closed by user, close TWAIN
    begin
      N_Dump1Str( 'TWGProcEvent >> MSG_CLOSEDSREQ: // =$104' );
      TWGAcquiredOK := True; // not really needed
      Result := FALSE;
      Exit;
    end; // MSG_CLOSEDSOK, MSG_CLOSEDSREQ:

    MSG_CLOSEDSOK: // =$103, should not occure, just a precaution
    begin
      N_Dump1Str( 'TWGProcEvent >> MSG_CLOSEDSOK: // =$103' );
      Exit;
    end;

    MSG_DEVICEEVENT: // =$104 Device event just ignore it
    begin
      N_Dump1Str( 'TWGProcEvent >> MSG_DEVICEEVENT: // =$104' );
      Exit;
    end;

  end; // case event.TWMessage of

  N_Dump1Str( 'Unknown TWAIN Message!' );
  Exit;

end; // procedure TK_TWGlobObj.TWGProcEvent

end.
