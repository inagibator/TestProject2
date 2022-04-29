unit N_CMTWAIN3;
// TWAIN Mode #3 (from 3.004 CMS Build)
//
// Based on TwainInterface.dll coded by Petronevich

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Twain,
  K_CM0,
  N_Types, N_Gra2;

type TN_CMTWAIN3Obj = class ( TObject ) // global vars and procs for TWAIN mode 3
  CMTDllHandle:  HMODULE; // DLL Windows Handle
  CMTErrorStr:    string; // Error message
  CMTErrorInt:   integer; // Error code
  CMTFNamePath:   string; // File Names Path (with trailing '\')
  CMTFNamePrefix: string; // File Names Prefix (e.g. 'TWAIN3Image')
  CMTTimer:       TTimer; // Timer for checking end of Accuire Images Process
  CMTSlides: TN_UDCMSArray; // Capured Slides
  CMTPTwainProfile: TK_PCMTwainProfile; // Pointer to TWAIN Device Profile
  CMTDebMode:     Boolean;  // Debug mode (detailed dumping mode)
  CMTManualClose: Boolean;  // Create Slides and close all by pressing Alt+Shift+S

  function  CMTInitAll (): Integer;
  function  CMTFreeAll (): Integer;
  procedure CMTTimerOnTimer ( ASender: TObject );
  procedure CMTCaptureAndFreeSelf ();
end; // type TN_CMTWAIN3Obj = class ( TObject )

var
  N_CMTWAIN3Obj: TN_CMTWAIN3Obj;

//***** TwainInterface.dll functions:
  N_CMTStartOrFindTwainServer:    TN_cdeclIntFuncVoid;
  N_CMTConnectToTwainServer:      TN_cdeclIntFuncVoid;
  N_CMTShowTwainDataSourcesList:  TN_cdeclIntFuncVoid;
  N_CMTSetImagesStorage:          TN_cdeclIntFuncPAChar;
  N_CMTSetTwainDataSourceName:    TN_cdeclIntFuncPAChar;
{$DEFINE TWAIN3_TRANSFER_MODE}
{$IFDEF TWAIN3_TRANSFER_MODE}
  N_CMTAcquireImage:              TN_cdeclIntFuncInt;
{$ELSE}
  N_CMTAcquireImage:              TN_cdeclIntFuncVoid;
{$ENDIF}
  N_CMTGetAcquireStatus:          TN_cdeclIntFuncVoid;
  N_CMTGetImagesCount:            TN_cdeclIntFuncVoid;
  N_CMTGetImagesFailedCount:      TN_cdeclIntFuncVoid;
  N_CMTDisconnectFromTwainServer: TN_cdeclIntFuncVoid;
  N_CMTStopTwainServer:           TN_cdeclIntFuncVoid;
  N_CMTIsDataSourceClosed:        TN_cdeclIntFuncVoid;
  N_CMTOpenLogFile:               TN_cdeclIntFuncPAChar3Int;


//*************************  Global Procedures  ***************

function  N_CMGetSlidesFromTWAIN3 ( APCMTwainProfile : TK_PCMTwainProfile ): integer;


const
  TWRC_NoDLL      =  $8001; // failed to load TWAIN_32.DLL
  TWRC_NoDSMEntry =  $8002; // failed to get DSM_Entry in TWAIN_32.DLL

  N_TWAIN_DLL_Name: String     = 'TWAIN_32.DLL';
  N_DSM_Entry_Name: AnsiString = 'DSM_Entry';


implementation
uses
  K_CLib0,
  N_Lib0, N_Lib1, N_InfoF, N_CMMain5F, N_CMResF, N_CML2F;

//*************************  TN_CMTWAIN3Obj methods  ***************

//*********************************************** TN_CMTWAIN3Obj.CMTInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// Result       - return 0 if OK
//
function TN_CMTWAIN3Obj.CMTInitAll() : Integer;
var
  FuncAnsiName: AnsiString;
  DllFName: string;  // DLL File Name

  procedure ReportError(); // local
  // Report that FuncAnsiName function was not loaded
  begin
    CMTErrorStr := String(FuncAnsiName) + ' not loaded';
    N_Dump1Str( CMTErrorStr );
    Result := 2;
  end; // procedure ReportError(); // local

begin
  if CMTDllHandle <> 0 then // TwainInterface.dll already initialized
  begin
    Result := 0; // All done
    Exit;
  end; // if CMTDllHandle <> 0 then // TwainInterface.dll already initialized

  DllFName := 'TwainInterface.dll';
  CMTErrorStr := '';
  Result := 0;

  N_Dump2Str( 'Loading DLL ' + DllFName );
  CMTDllHandle := Windows.LoadLibrary( @DllFName[1] );

  if CMTDllHandle = 0 then // some error
  begin
    // N_CML2Form.LLLErrorLoading1 = 'Error Loading'
    CMTErrorStr := N_CML2Form.LLLErrorLoading1.Caption + ' ' + DllFName + ': ' + SysErrorMessage( GetLastError() );
    Result := 2; // Windows.LoadLibrary failed
    K_CMShowMessageDlg( CMTErrorStr, mtError );
    Exit;
  end; // if CMTDllHandle = 0 then // some error

  //***** Load Schick TwainInterface.dll functions

  FuncAnsiName := 'StartOrFindTwainServer';
  N_CMTStartOrFindTwainServer := GetProcAddress( CMTDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMTStartOrFindTwainServer) then ReportError();

  FuncAnsiName := 'ConnectToTwainServer';
  N_CMTConnectToTwainServer := GetProcAddress( CMTDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMTConnectToTwainServer) then ReportError();

  FuncAnsiName := 'ShowTwainDataSourcesList';
  N_CMTShowTwainDataSourcesList := GetProcAddress( CMTDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMTShowTwainDataSourcesList) then ReportError();

  FuncAnsiName := 'SetImagesStorage';
  N_CMTSetImagesStorage := GetProcAddress( CMTDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMTSetImagesStorage) then ReportError();

  FuncAnsiName := 'SetTwainDataSourceName';
  N_CMTSetTwainDataSourceName := GetProcAddress( CMTDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMTSetTwainDataSourceName) then ReportError();

  FuncAnsiName := 'GetAcquireStatus';
  N_CMTGetAcquireStatus := GetProcAddress( CMTDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMTGetAcquireStatus) then ReportError();

  FuncAnsiName := 'AcquireImage';
  N_CMTAcquireImage := GetProcAddress( CMTDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMTAcquireImage) then ReportError();

  FuncAnsiName := 'GetImagesCount';
  N_CMTGetImagesCount := GetProcAddress( CMTDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMTGetImagesCount) then ReportError();

  FuncAnsiName := 'GetImagesFailedCount';
  N_CMTGetImagesFailedCount := GetProcAddress( CMTDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMTGetImagesFailedCount) then ReportError();

  FuncAnsiName := 'DisconnectFromTwainServer';
  N_CMTDisconnectFromTwainServer := GetProcAddress( CMTDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMTDisconnectFromTwainServer) then ReportError();

  FuncAnsiName := 'StopTwainServer';
  N_CMTStopTwainServer := GetProcAddress( CMTDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMTStopTwainServer) then ReportError();

  FuncAnsiName := 'IsDataSourceClosed';
  N_CMTIsDataSourceClosed := GetProcAddress( CMTDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMTIsDataSourceClosed) then ReportError();

  FuncAnsiName := 'OpenLogFile';
  N_CMTOpenLogFile := GetProcAddress( CMTDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMTOpenLogFile) then ReportError();

  if Result <> 0 then // some error while loading DLL Entries
  begin
    K_CMShowMessageDlg( Format( 'Failed to initialise %s Errorcode=%d',
                                           [DllFName, Result] ), mtError );
    CMTFreeAll();
    N_Dump1Str( DllFName + ' Resources freed' );
  end;

end; // procedure TN_CMTWAIN3Obj.CMTInitAll

//*********************************************** TN_CMTWAIN3Obj.CMTFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMTWAIN3Obj.CMTFreeAll(): Integer;
begin
  FreeAndNil( CMTTimer );

  if CMTDLLHandle <> 0 then
  begin
    N_Dump2Str( 'Before TwainInterface.dll FreeLibrary' );
    FreeLibrary( CMTDLLHandle );
    N_Dump2Str( 'After TwainInterface.dll FreeLibrary' );
    CMTDLLHandle := 0;
  end; // if CMTDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMTWAIN3Obj.CMTFreeAll

//****************************************** TN_CMTWAIN3Obj.CMTTimerOnTimer ***
// TWAIN #3 mode Timer event handler for checking TwainSvr.exe state
//
//     Parameters
// ASender - Timer Object
//
procedure TN_CMTWAIN3Obj.CMTTimerOnTimer( ASender: TObject );
var
  i, TwainSvrState, MaxNumSlides, AcquireStatus: integer;
  CurFName: string;
  CurDIB: TN_DIBObj;
  ResCode : Integer;
begin
  CMTTimer.Enabled := False;

  if K_CMD4WAppFinState then // CMS was closed by pressing cross sys button
  begin
    N_i := 22;
    Exit; // nothing to do
  end;

  AcquireStatus := N_CMTGetAcquireStatus();
  TwainSvrState := N_CMTIsDataSourceClosed();
  if CMTDebMode then N_Dump1Str( Format( 'OnTimer: TwainSvrState=%d', [TwainSvrState] ) );

  if (TwainSvrState <> 0) or CMTManualClose or (AcquireStatus <> 0) then // import all captured images (if any) and finish capturing action)
  begin
    if TwainSvrState = 0 then
      K_CMShowMessageDlg( Format( 'TWAIN Mode 3 Error #6 (AcquireStatus=%d)',
                                                   [AcquireStatus] ), mtError );
    MaxNumSlides := 100;
    SetLength( CMTSlides, MaxNumSlides );

    for i := 0 to MaxNumSlides-1 do // along all captured Imges (may be none)
    begin
      CurFName := CMTFNamePath + CMTFNamePrefix + Format( '%.3d.bmp', [i] );

      if FileExists( CurFName ) then // convert CurFName to Slide
      begin
        CurDIB := nil;
//      N_TestLoadDIB( CurDIB, CurFName, 0, 1 ); // load from File using ImageLibrary
        ResCode := N_LoadDIBFromFile( CurDIB, CurFName );
        if ResCode <> 0 then
          N_Dump1Str( format('OnTimer: File Error=%d >> %s', [ResCode, CurFName]) );

        CMTSlides[i] := K_CMSlideCreateFromDeviceDIBObj( CurDIB,
                                  TK_PCMDeviceProfile(CMTPTwainProfile), i + 1, 0 );
        // now CurDIB is owned by Slide in CMTSlides[i]
      end else // all captured files are processed
      begin
        SetLength( CMTSlides, i ); // i-real number of slides
        Break;
      end;
    end; // for i := 0 to MaxNumSlides-1 do // along all captured Imges

    if CMTDebMode then N_Dump1Str( Format( 'OnTimer: Num Captured=%d', [Length(CMTSlides)] ) );
    K_CMSlidesSaveScanned3( TK_PCMDeviceProfile(CMTPTwainProfile), CMTSlides );

    N_i1 := N_CMTDisconnectFromTwainServer();
    N_i2 := N_CMTStopTwainServer();
    if CMTDebMode then N_Dump1Str( Format( 'OnTimer: DisconnectFromTwainServer=%d StopTwainServer=%d', [N_i1, N_i2] ) );

    CMTFreeAll();
    FreeAndNil( Self );
    N_CMResForm.CMRFTwainMode := False;

    N_Dump1Str( 'OnTimer: All done' );
    Exit; // all done
  end; // if TwainSvrState <> 0 then // import all captured images and finish

  CMTTimer.Enabled := True;
end; // TN_CMTWAIN3Obj.CMTTimerOnTimer

//************************************ TN_CMTWAIN3Obj.CMTCaptureAndFreeSelf ***
// Convert captured bmp files to slides and free Self
//
//     Parameters
// ASender - Timer Object
//
procedure TN_CMTWAIN3Obj.CMTCaptureAndFreeSelf();
begin
  CMTTimer.Enabled := False;

  if K_CMD4WAppFinState then // CMS was closed by pressing cross
  begin
    Exit;
  end;

//  if not ProcessExists( PathDriver ) then
  begin
//    K_CMSlidesSaveScanned3 ( PDevProfile, PSlidesArrayForTimer );
//    Exit;
  end;

  CMTTimer.Enabled := True;
end; // TN_CMTWAIN3Obj.CMTCaptureAndFreeSelf


//*************************  Global Procedures  ***************

//************************************************* N_CMGetSlidesFromTWAIN3 ***
// Acquire Slides from given TWAIN device
// (var 3 - use TwainInterface.dll coded by Petronevich)
//
//     Parameters
// ATWAINProfileInd - Capture (TWAIN) device profile index
// Result           - Return 0 if not modal capturing was succesfully started or 1 if error
//
function N_CMGetSlidesFromTWAIN3( APCMTwainProfile : TK_PCMTwainProfile ): integer;
var
  ResCode, LogMaxSize, LogMaxDays, LogDetails: integer;
  AnsiFName, AnsiDSName, LogFullNameA: AnsiString;

const
    TW_APP_NATIVE = 110;
    TW_APP_FILE   = 111;
    TW_APP_BUFFER = 112;

  Label Fin;
begin
  Assert( not N_CMResForm.CMRFTwainMode, 'N_CMGetSlidesFromTWAIN3: Nested call to TwainOnExecuteHandler ' );
  N_CMResForm.CMRFTwainMode := True;

  N_CMTWAIN3Obj := TN_CMTWAIN3Obj.Create;
  with  N_CMTWAIN3Obj do
  begin
    CMTDebMode := True; // temporary for debug

    //*** Get TWAIN device profile
//    K_CMCaptProfileInd := ATWAINProfileInd;
//    CMTPTwainProfile := K_CMEDAccess.TwainProfiles.PDE(K_CMCaptProfileInd);
    CMTPTwainProfile := APCMTwainProfile;
    Assert( CMTPTwainProfile <> nil, 'N_CMGetSlidesFromTWAIN3: Wrong TWAIN Profile index' );

    if CMTDebMode then N_Dump1Str( ' Before CMTInitAll' );
    ResCode := CMTInitAll();
    if ResCode <> 0 then
      goto Fin;

    LogFullNameA := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) + 'TWAIN_3.txt' );
    LogMaxSize := N_MemIniToInt( 'CMS_UserMain', 'LogMaxSize', 1024 );
    LogMaxDays := N_MemIniToInt( 'CMS_UserMain', 'LogMaxDays', 200 );
    LogDetails := N_MemIniToInt( 'CMS_UserMain', 'LogDetails', 2 );
    ResCode := N_CMTOpenLogFile( @LogFullNameA[1], LogMaxSize, LogMaxDays, LogDetails );

    if ResCode = 0 then
      N_Dump1Str( 'N_CMECDOpenSchickLogFile Error - ' + String(LogFullNameA) );

    ResCode := N_CMTStartOrFindTwainServer();
    if CMTDebMode then N_Dump1Str( ' After StartOrFindTwainServer' );
    if ResCode <> 0 then // N_CMTStartOrFindTwainServer error
    begin
      K_CMShowMessageDlg( Format( 'TWAIN Mode 3 Error #1 (ErrCode=%d %s)',
                               [ResCode, SysErrorMessage(ResCode)] ), mtError );
      goto Fin;
    end; // if ResCode <> 0 then // N_CMTStartOrFindTwainServer error

    ResCode := N_CMTConnectToTwainServer();
    if CMTDebMode then N_Dump1Str( ' After ConnectToTwainServer' );
    if ResCode <> 0 then // N_CMTConnectToTwainServer error
    begin
      K_CMShowMessageDlg( Format( 'TWAIN Mode 3 Error #2 (ErrCode=%d %s)',
                               [ResCode, SysErrorMessage(ResCode)] ), mtError );
      goto Fin;
    end; // if ResCode <> 0 then // N_CMTConnectToTwainServer error

    CMTFNamePath := K_GetDirPath( 'CMSWrkFiles' );
    K_ForceDirPath( CMTFNamePath );
    CMTFNamePrefix := 'TWAIN3Image';
    AnsiFName := AnsiString( CMTFNamePath + CMTFNamePrefix + '000.bmp' );
    ResCode := N_CMTSetImagesStorage( @AnsiFName[1] );

    if CMTDebMode then N_Dump1Str( ' After SetImagesStorage' );

    if ResCode <> 0 then // N_CMTSetImagesStorage error
    begin
      K_CMShowMessageDlg( Format( 'TWAIN Mode 3 Error #3 (ErrCode=%d %s)',
                               [ResCode, SysErrorMessage(ResCode)] ), mtError );
      goto Fin;
    end; // if ResCode <> 0 then // N_CMTSetImagesStorage error

    AnsiDSName := N_StringToAnsi(CMTPTwainProfile^.CMDPProductName);
    ResCode := N_CMTSetTwainDataSourceName( @AnsiDSName[1] );
    if CMTDebMode then N_Dump1Str( ' After SetTwainDataSourceName' );
    if ResCode <> 0 then // N_CMTSetTwainDataSourceName error
    begin
      K_CMShowMessageDlg( Format( 'TWAIN Mode 3 Error #4 (ErrCode=%d %s)',
                               [ResCode, SysErrorMessage(ResCode)] ), mtError );
      goto Fin;
    end; // if ResCode <> 0 then // N_CMTSetTwainDataSourceName error

{$IFDEF TWAIN3_TRANSFER_MODE}
    N_i := TW_APP_NATIVE;
    if Length(CMTPTwainProfile^.CMDPStrPar1) >= 2 then
    begin
      if CMTPTwainProfile^.CMDPStrPar1[2] = '2' then
        N_i := TW_APP_FILE
      else if CMTPTwainProfile^.CMDPStrPar1[2] = '3' then
        N_i := TW_APP_BUFFER;
    end;
    ResCode := N_CMTAcquireImage( N_i );
{$ELSE}
    ResCode := N_CMTAcquireImage();
{$ENDIF}
    if CMTDebMode then N_Dump1Str( ' After AcquireImage' );
    if ResCode <> 0 then // N_CMTAcquireImage error
    begin
      K_CMShowMessageDlg( Format( 'TWAIN Mode 3 Error #5 (ErrCode=%d %s)',
                               [ResCode, SysErrorMessage(ResCode)] ), mtError );
      goto Fin;
    end; // if ResCode <> 0 then // N_CMTAcquireImage error

    // TwainSvr.exe was succesfully started and connected to
    // all other processing is in CMTTimerOnTimer

    CMTTimer          := TTimer.Create( Application );
    CMTTimer.Interval := 500;
    CMTTimer.OnTimer  := CMTTimerOnTimer;
    CMTTimer.Enabled  := True;

    K_DeleteFolderFiles( CMTFNamePath, CMTFNamePrefix + '*.bmp' ); // delete files from previous session

    Result := 0; // "all Initialized OK" flag
    if CMTDebMode then N_Dump1Str( ' N_CMGetSlidesFromTWAIN3 Finished OK' );
    Exit; // all other processing is in CMTTimerOnTimer,
  end; // with  PCMTwainProfile^ do

  Fin : //*********************************
  Result := ResCode;
  N_CMResForm.CMRFTwainMode := False;
  FreeAndNil( N_CMTWAIN3Obj );
  N_Dump1Str( ' N_CMGetSlidesFromTWAIN3 Cancelled' );
end; // procedure N_CMGetSlidesFromTWAIN3

end.
