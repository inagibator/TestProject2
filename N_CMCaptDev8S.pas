unit N_CMCaptDev8S;
// Gendex device

// 2014.03.20 substituted 'K_CMShowMessageDlg' by 'ShowCriticalError' calls by Valery Ovechkin
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2014.07.02 Error code for 'N_LoadDIBFromFileByImLib' check added ( line 474 ) by Valery Ovechkin
// 2014.09.15 Fixed File exceptions processing ( like i/o 32, etc. ) by Valery Ovechkin
// 2014.09.15 Standartizing ( All functions parameters name starts from 'A' ) by Valery Ovechkin
// 2014.09.30 Resolution converting fixed ( dpi to pixel / meter ) by Valery Ovechkin
// 2014.10.10 Line 519 - 64 bit crash fixed by Valery Ovechkin
// 2018.11.07 CDSGetDefaultDevIconInd function added

interface
uses
  Windows, Classes, Forms, Graphics, StdCtrls, ExtCtrls,
  K_CM0, K_CMCaptDevReg,
  N_Types, N_CompBase, N_CMCaptDev0, N_CMCaptDev8SF;

type T_GENDEX = record // Pair   id - name
  id: String;
  name: String;
end;

type TN_CMCDServObj8 = class( TK_CMCDServObj )
  devList:      Array of T_GENDEX; // devices list
  CDSDllHandle: THandle;           // DLL handle
  First:        Boolean;           // Auxilliary var for Capture timer
  Images:       TN_SArray;         // images files names list
  ImageReady:   Boolean;           // image ready flag

  // External functions
  AboutBox_ext:          TN_cdeclProcVoid;
  StartAcquisition_ext:  TN_cdeclProcVoid;
  StopAcqusition_ext:    TN_cdeclProcVoid;
  StartCarousel_ext:     TN_cdeclProcVoid;
  StopCarousel_ext:      TN_cdeclProcVoid;
  DisplayProperties_ext: TN_cdeclProcVoid;
  Commit_ext:            TN_cdeclProcVoid;
  FreeResources_ext:     TN_cdeclProcVoid;
  CloseLogFile_ext:      TN_cdeclProcVoid;

  Select_ext:      TN_CMV_cdeclProcInt2;
  SetScanArea_ext: TN_CMV_cdeclProcInt2;
  SetScanRes_ext:  TN_CMV_cdeclProcInt2;
  StartDevice_ext: TN_cdeclProcInt;
  StopDevice_ext:  TN_cdeclProcInt;

  SetHighResolution_ext: TN_cdeclProcInt;

  CreateGxPictureInstance_ext: TN_CMV_cdeclIntFuncPInt;

  GetBitsPerPixel_ext:  TN_cdeclInt2FuncVoid;
  GetPosition_ext:      TN_cdeclInt2FuncVoid;
  GetImageWidth_ext:    TN_cdeclInt2FuncVoid;
  GetImageHeight_ext:   TN_cdeclInt2FuncVoid;
  GetExposure_ms_ext:   TN_cdeclInt2FuncVoid;
  GetExposure_mA_ext:   TN_cdeclInt2FuncVoid;
  GetExposure_kV_ext:   TN_cdeclInt2FuncVoid;
  GetExposure_Doze_ext: TN_cdeclInt2FuncVoid;
  GetState_ext:         TN_cdeclInt2FuncVoid;
  GetMaxHistogram_ext:  TN_cdeclInt2FuncVoid;
  GetMinHistogram_ext:  TN_cdeclInt2FuncVoid;
  GetScanRes_ext:       TN_cdeclInt2FuncVoid;
  GetCount_ext:         TN_cdeclInt2FuncVoid;

  GetHDI_ext:               TN_cdeclIntFuncVoid;
  GetHighResolution_ext:    TN_cdeclIntFuncVoid;
  GetCommited_ext:          TN_cdeclIntFuncVoid;
  GetDenOptixAutoStart_ext: TN_cdeclIntFuncVoid;
  GetDeviceID_ext:          TN_CMV_cdeclIntFuncInt2;
  SetDenOptixAutoStart_ext: TN_cdeclIntFuncInt;
  IsInstalled_ext:          TN_cdeclIntFuncPWChar;
  IsAcquire_ext:            TN_cdeclIntFuncPWChar;
  OpenLogFile_ext:          TN_cdeclIntFuncPAChar3Int;

  GetOldestEventDataFromEventsQueue_ext: TN_CMV_cdeclIntFunc2PWChar6PInt;

  GetResolution_ext:    TN_CMV_cdeclDblFuncVoid;
  GetMagnification_ext: TN_CMV_cdeclDblFuncVoid;
  GetPixelSize_ext:     TN_CMV_cdeclDblFuncVoid;
  GetModality_ext:      TN_CMV_cdeclPWCharFuncVoid;
  GetSerialNumber_ext:  TN_CMV_cdeclPWCharFuncVoid;
  GetProjection_ext:    TN_CMV_cdeclPWCharFuncVoid;
  GetDeviceName_ext:    TN_CMV_cdeclPWCharFuncInt2;

  PSlidesArrayForTimer: TN_UDCMSArray;
  PDevProfile:          TK_PCMDeviceProfile;

  function  LoadFuncs           (): Boolean;
  function  CDSInitAll          (): Boolean;
  procedure CDSFreeAll          ();
  function  CDSGetGroupDevNames ( AGroupDevNames: TStrings ): integer; override;
  function  CDSGetDevCaption    ( ADevName: String ): String; override;
  procedure CDSCaptureImages    ( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ); override;
  function  CDSStartCaptureToStudy( APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState; override;
  function  ConvertGendexCode   ( ANumber: Integer ): Integer;
  procedure GendexOnTimer       ( AFrm: TN_CMCaptDev8Form );
  procedure CDSSettingsDlg      ( APDevProfile: TK_PCMDeviceProfile ); override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;

private
  BufSlidesArray: TN_UDCMSArray;
  procedure FCapturePrepare( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray );

end; // end of type TN_CMCDServObj8 = class( TK_CMCDServObj )

var
  N_CMCDServObj8: TN_CMCDServObj8;

implementation

uses
  SysUtils, Dialogs, StrUtils,
  K_CLib0,
  N_Gra2, N_Lib1, N_CM1, N_Lib0, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2,
  N_CMCaptDev8aF;

var CaptForm : TN_CMCaptDev8Form;


//**************************************** TN_CMCDServObj8 **********

//*********************************************** TN_CMCDServObj8.LoadFuncs ***
// Load external functions from DLL
//
//     Parameters
// Result - True if success ( all needed functions loaded )
//
function TN_CMCDServObj8.LoadFuncs(): Boolean;
var
  dllName: String;
begin
  Result := False;
  if ( CDSDllHandle <> 0 ) then // check DLL loaded
    exit;

  // DLL name
  dllName := 'GendexInterface.dll';

  CDSDllHandle := LoadLibrary( @dllName[1] );

  if ( CDSDllHandle = 0 ) then // check DLL loaded
    exit;

  // Load all function from DLL
  Result :=
  N_CMV_LoadFunc( CDSDllHandle, @GetOldestEventDataFromEventsQueue_ext, 'GetOldestEventDataFromEventsQueue' ) and
  N_CMV_LoadFunc( CDSDllHandle, @AboutBox_ext,                'AboutBox'                ) and
  N_CMV_LoadFunc( CDSDllHandle, @StartAcquisition_ext,        'StartAcquisition'        ) and
  N_CMV_LoadFunc( CDSDllHandle, @StopAcqusition_ext,          'StopAcqusition'          ) and
  N_CMV_LoadFunc( CDSDllHandle, @StartCarousel_ext,           'StartCarousel'           ) and
  N_CMV_LoadFunc( CDSDllHandle, @StopCarousel_ext,            'StopCarousel'            ) and
  N_CMV_LoadFunc( CDSDllHandle, @DisplayProperties_ext,       'DisplayProperties'       ) and
  N_CMV_LoadFunc( CDSDllHandle, @Commit_ext,                  'Commit'                  ) and
  N_CMV_LoadFunc( CDSDllHandle, @FreeResources_ext,           'FreeResources'           ) and
  N_CMV_LoadFunc( CDSDllHandle, @CloseLogFile_ext,            'CloseLogFile'            ) and
  N_CMV_LoadFunc( CDSDllHandle, @Select_ext,                  'Select'                  ) and
  N_CMV_LoadFunc( CDSDllHandle, @SetScanArea_ext,             'SetScanArea'             ) and
  N_CMV_LoadFunc( CDSDllHandle, @SetScanRes_ext,              'SetScanRes'              ) and
  N_CMV_LoadFunc( CDSDllHandle, @StartDevice_ext,             'StartDevice'             ) and
  N_CMV_LoadFunc( CDSDllHandle, @StopDevice_ext,              'StopDevice'              ) and
  N_CMV_LoadFunc( CDSDllHandle, @SetHighResolution_ext,       'SetHighResolution'       ) and
  N_CMV_LoadFunc( CDSDllHandle, @CreateGxPictureInstance_ext, 'CreateGxPictureInstance' ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetBitsPerPixel_ext,         'GetBitsPerPixel'         ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetPosition_ext,             'GetPosition'             ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetImageWidth_ext,           'GetImageWidth'           ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetImageHeight_ext,          'GetImageHeight'          ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetExposure_ms_ext,          'GetExposure_ms'          ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetExposure_mA_ext,          'GetExposure_mA'          ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetExposure_kV_ext,          'GetExposure_kV'          ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetExposure_Doze_ext,        'GetExposure_Doze'        ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetState_ext,                'GetState'                ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetMaxHistogram_ext,         'GetMaxHistogram'         ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetMinHistogram_ext,         'GetMinHistogram'         ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetScanRes_ext,              'GetScanRes'              ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetCount_ext,                'GetCount'                ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetHDI_ext,                  'GetHDI'                  ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetHighResolution_ext,       'GetHighResolution'       ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetCommited_ext,             'GetCommited'             ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetDenOptixAutoStart_ext,    'GetDenOptixAutoStart'    ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetDeviceID_ext,             'GetDeviceID'             ) and
  N_CMV_LoadFunc( CDSDllHandle, @SetDenOptixAutoStart_ext,    'SetDenOptixAutoStart'    ) and
  N_CMV_LoadFunc( CDSDllHandle, @IsInstalled_ext,             'IsInstalled'             ) and
  N_CMV_LoadFunc( CDSDllHandle, @IsAcquire_ext,               'IsAcquire'               ) and
  N_CMV_LoadFunc( CDSDllHandle, @OpenLogFile_ext,             'OpenLogFile'             ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetResolution_ext,           'GetResolution'           ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetMagnification_ext,        'GetMagnification'        ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetPixelSize_ext,            'GetPixelSize'            ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetModality_ext,             'GetModality'             ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetSerialNumber_ext,         'GetSerialNumber'         ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetProjection_ext,           'GetProjection'           ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetDeviceName_ext,           'GetDeviceName'           );
end; // function TN_CMCDServObj8.LoadFuncs

//********************************************** TN_CMCDServObj8.CDSInitAll ***
// Initialize Gendex environment
//
//     Parameters
// Result - True if success
//
function TN_CMCDServObj8.CDSInitAll(): Boolean;
var
  lg, cnt, LogMaxSize, LogMaxDays, LogDetails: Integer;
  LogFullNameA: AnsiString;
  ind:      TN_Int2;
  pName:    PWideChar;
begin
  CDSFreeAll();
  Result := False;

  if ( CDSDllHandle <> 0 ) then
    Exit;

  cnt := 0;
  SetLength( devList, cnt );

  if not LoadFuncs then
  begin
    N_CMV_ShowCriticalError( 'Gendex', 'some functions not loaded from DLL' );
    exit;
  end; // if not LoadFuncs then

  lg := 0;
  LogFullNameA := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) + 'Gendex.txt' );
//  N_d := N_d/0;
  LogMaxSize := N_MemIniToInt( 'CMS_UserMain', 'LogMaxSize', 1024 );
  LogMaxDays := N_MemIniToInt( 'CMS_UserMain', 'LogMaxDays', 200 );
  LogDetails := N_MemIniToInt( 'CMS_UserMain', 'LogDetails', 2 );

  OpenLogFile_ext( @LogFullNameA[1], LogMaxSize, LogMaxDays, LogDetails );

  if ( 0 = CreateGxPictureInstance_ext( @lg ) ) then
  begin
    N_CMV_ShowCriticalError( 'Gendex', 'CreateGxPictureInstance = False' );
    CDSFreeAll();
    exit;
  end; // if ( 0 = CreateGxPictureInstance_ext( @lg ) ) then

  cnt := GetCount_ext();
  SetLength( devList, cnt );

  for ind := 0 to cnt - 1 do
  begin
    devList[ind].id := IntToStr( GetDeviceID_ext( ind + 1 ) );
    pName := GetDeviceName_ext( ind + 1 );
    devList[ind].name := N_WideToString( N_CreateWideString( pName ) );
  end; // for ind := 0 to cnt - 1 do

  Result := True;

end; // function TN_CMCDServObj8.CDSInitAll

//********************************************** TN_CMCDServObj8.CDSFreeAll ***
// Initialize Gendex environment
//
procedure TN_CMCDServObj8.CDSFreeAll();
begin

  if ( CDSDllHandle = 0 ) then
    exit;

  FreeResources_ext();// Free Resources
  FreeLibrary( CDSDllHandle ); // Free Library
  CDSDllHandle := 0;           // Set default DLL handle value
end; // function TN_CMCDServObj8.CDSFreeAll

//**************************************** TN_CMCDServObj8.CDSGetDevCaption ***
// define device caption by id
//
//     Parameters
// ADevName - device name
// Result - device caption
//
function  TN_CMCDServObj8.CDSGetDevCaption( ADevName: String ): String;
var
  i, devCount: Integer;
begin
  Result := '';
  devCount := Length( devList );

  for i := 0 to devCount - 1 do
  begin

    if ( ADevName = devList[i].id ) then
    begin
      Result := devList[i].name;
      Exit;
    end; // if ( ADevName = devList[i].id ) then

  end; // for i := 0 to devCount - 1 do

end; // function TN_CMCDServObj8.CDSGetDevCaption


//************************************* TN_CMCDServObj8.CDSGetGroupDevNames ***
// Get Gendex Device Name
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj8.CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer;
var
  i: Integer;
begin
  Result := 0; // return device count

  if not CDSInitAll() then
    exit;

  Result := Length( devList );

  for i := 0 to Result - 1 do
    AGroupDevNames.Add( devList[i].id );

  CDSFreeAll();
end; // function TN_CMCDServObj8.CDSGetGroupDevNames

//**************************************** TN_CMCDServObj8.CDSCaptureImages ***
// Capture images
//
//     Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj8.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                            var ASlidesArray: TN_UDCMSArray );
{
var
  id: Integer;
  idStr: String;
}
begin

  N_Dump1Str( 'Gendex >> CDSCaptureImages begin' );
  FCapturePrepare(  APDevProfile, ASlidesArray );
  N_Dump1Str( 'Gendex >> CDSCaptureImages before ShowModal' );
  CaptForm.ShowModal();
  N_Dump1Str( 'Gendex >> CDSCaptureImages end' );

{
  First := True; // Initial value
  SetLength( ASlidesArray, 0 ); // Clear Slides Array
  // Create capture form
  CaptForm := TN_CMCaptDev8Form.Create( Application );

  with CaptForm, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    CMOFPProfile    := TK_PCMOtherProfile( APDevProfile ); // set CMCaptDev8Form.CMOFPProfile field
    Caption         := CMDPCaption;
    CMOFPNewSlides  := @ASlidesArray; // for using in CMCaptDev8Form methods
    CMOFNumCaptured := 0;
    id := StrToIntDef( APDevProfile^.CMDPProductName, 0 ); // id = ProductName
    idStr := IntToStr( id );                               // id as string
    // capture button must be shown only for these ids

    bnCapture.Visible := N_CMV_CheckStrParam( N_MemIniToString( 'CMS_UserDeb',
                                              'GendexShowCaptureButton',
                                              '1,9' ), idStr );
    // rotate arrows must be shown for any ids, except these
    tbRotateImage.Visible := not N_CMV_CheckStrParam( N_MemIniToString( 'CMS_UserDeb',
                                                      'GendexHideImageRotate',
                                                      '4,9,12,13' ), idStr );
    StatusLabel.font.Color  := clGreen;
    StatusShape.Brush.Color := clGreen;
    StatusLabel.Caption     := 'Ready to take X-Rays';
    ShowModal(); // show capture form
  end; // with CaptForm, APDevProfile^ do

  CDSFreeAll();
}
end; // procedure TN_CMCDServObj8.CDSCaptureImages

//********************************** TN_CMCDServObj8.CDSStartCaptureToStudy ***
// Start Capture to study
//
//     Parameters
// APDevProfile - pointer to device profile record
// AStudyDevCaptAttrs - resulting Device Capture Interface
// Result - Returns Study Capture State code (TK_CMStudyCaptState)
//
function TN_CMCDServObj8.CDSStartCaptureToStudy(  APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState;
begin
  Result := inherited CDSStartCaptureToStudy( APDevProfile, AStudyDevCaptAttrs );

  if N_CMV_CheckStrParam( '7,8,10', APDevProfile^.CMDPProductName ) then
  begin
    FCapturePrepare( APDevProfile, BufSlidesArray );
    CaptForm.tbRotateImage.Visible := FALSE; 
    with AStudyDevCaptAttrs do
    begin
      CMSDCDDlg := CaptForm;
      CMSDCDDlgCPanel := CaptForm.CtrlsPanel;
    end;
    Result := K_cmscOK;
  end;

  N_Dump1Str( 'Gendex >> CDSStartCaptureToStudy Res=' + IntToStr(Ord(Result)) );

end; // function TN_CMCDServObj8.CDSStartCaptureToStudy

//*************************************** TN_CMCDServObj8.ConvertGendexCode ***
// Temporary - convert Gendex codes from Sergey's system to Valery's
//
//     Parameters
// ANumber - code in Sergey's system
// Result  - code in Valery's system
//
function TN_CMCDServObj8.ConvertGendexCode( ANumber: Integer ): Integer;
begin
  Result := 0;

  if ( 1 = ANumber ) then
    result := 8
  else if ( 2 = ANumber ) then
    result := 6
  else if ( 3 = ANumber ) then
    result := 5
  else if ( 4 = ANumber ) then
    result := 3
  else if ( 5 = ANumber ) then
    result := 4
  else if ( 6 = ANumber ) then
    result := 7
  else if ( 7 = ANumber ) then
    result := 1
  else if ( 8 = ANumber ) then
    result := 2;

end; // function TN_CMCDServObj8.ConvertGendexCode

//******************************************* TN_CMCDServObj8.GendexOnTimer ***
// Gendex timer handle
//
//     Parameters
// AFrm - capture form
//
procedure TN_CMCDServObj8.GendexOnTimer( AFrm: TN_CMCaptDev8Form );
var
  id, i, n, n1, n2, n3, n4, n5, n6, sz, eventType, ResCode, meter, inch: Integer;
  w1, w2:                    String;    // if WideString - Carousel may fail while dragging!!!
  dib:                       TN_DIBObj; // DIB Object
  FileName, FileNameForSave: String;    // Full File Path
  ResolutionInt: Integer;      // Resolution in pixel per meter
  NewSlide: TN_UDCMSlide; // Slide
  RootComp: TN_UDCompVis;
  FilePrefixes, FilePostfixes: TN_SArray;
begin
  AFrm.timer_check.Enabled := False;
  meter := 10000;
  inch  := 254;

  if First then // first timer event - select device
  begin
    AFrm.CMOFNumCaptured := 0;

    if not CDSInitAll() then
    begin
      AFrm.timer_check.Enabled := True;
      exit;
    end; // if not CDSInitAll() then

    // id = ProductName
    id := StrToIntDef(  AFrm.CMOFPProfile.CMDPProductName, -1 );

    if ( 0 > id ) then
    begin
      N_CMV_ShowCriticalError( 'Gendex', 'id < 0' );
      AFrm.timer_check.Enabled := True;
      exit;
    end; // if ( 0 > id ) then

    // select device by id
    Select_ext( id );
    First := False;
  end
  // not first timer event - check image
  else
  begin
  // prepare strings for external call
    sz := 261;
    SetLength( w1, sz );
    SetLength( w2, sz );

    for i := 1 to sz do
    begin
      w1[i] := #0;
      w2[i] := #0;
    end; // for i := 1 to sz do

    n1 := 0; n2 := n1; n3 := n2; n4 := n3; n5 := n4; n6 := n5; N_i := n6; // to awoid warning
{$IFNDEF VER150} // Delphi 7
    n := GetOldestEventDataFromEventsQueue_ext( @w1[1], @w2[1],
                                                @n1, @n2, @n3, @n4, @n5, @n6 );
{$ELSE}
    n := 0;                                            
{$ENDIF}

    eventType := ConvertGendexCode( n ); // convert event code to Valery's

    if ( eventType = 1 ) then // Processing
    begin
      AFrm.StatusLabel.font.Color := clBlue;
      AFrm.StatusShape.Brush.Color := clBlue;
      AFrm.StatusLabel.Caption := 'Processing';
    end; // if ( eventType = 1 ) then // Processing

    if ( eventType = 2 ) then // Idle
    begin
      AFrm.StatusLabel.font.Color := clGreen;
      AFrm.StatusShape.Brush.Color := clGreen;
      AFrm.StatusLabel.Caption := 'Ready to take X-Rays';
    end; // if ( eventType = 2 ) then // Idle

    if ( eventType= 6 ) then  // Error
    begin
      AFrm.StatusLabel.font.Color  := clBlack;
      AFrm.StatusShape.Brush.Color := clBlack;
      AFrm.StatusLabel.Caption     := 'Device disconnected. Error ' +
                                     N_WideToString( w1 );
    end; // if ( eventType= 6 ) then  // Error

    if ( eventType = 8 ) then // Image Ready
    begin
      FileName := N_CMV_TrimNullsRight( N_WideToString( w1 ) ); // define image file path ( '*.tif' )
      dib := nil;
      ResCode := N_LoadDIBFromFileByImLib( dib, FileName ); // new 8 or 16 bit variant

      if ( ResCode <> 0 ) then
      begin
        N_CMV_ShowCriticalError( 'Gendex', 'N_LoadDIBFromFileByImLib = ' + IntToStr( ResCode ) );
        Exit;
      end; // if ( ResCode <> 0 ) then

      if ( dib = nil ) then
      begin
        N_CMV_ShowCriticalError( 'Gendex', 'dib = nil' );
        Exit;
      end; // if ( dib = nil ) then

      // save tiff file to wrkdir
      if N_MemIniToBool( 'CMS_UserDeb', 'SaveImage', False ) then
      begin
        SetLength( FilePrefixes, 1 );
        FilePrefixes[0] := N_CMV_GetWrkDir() + 'gendex_';
        SetLength( FilePostfixes, 1 );
        FilePostfixes[0] := '.tif';
        FileNameForSave := FilePrefixes[0] + N_CMV_GetNewNum( FilePrefixes, FilePostfixes, 6 ) + FilePostfixes[0];

        if not CopyFile( @FileName[1], @FileNameForSave[1], False ) then
        begin
          N_Dump1Str( 'Trident >> File not saved on disk' ) ;
        end;

      end; // if N_MemIniToBool( 'CMS_UserDeb', 'SaveImage', False ) then

      DeleteFile( FileName );

      if ( dib = nil ) then // dib not loaded from tif file
      begin
        N_CMV_ShowCriticalError( 'Gendex', 'File "' + FileName + '" has wrong tif format' );
        AFrm.timer_check.Enabled := True;
        Exit;
      end; //if ( dib = nil ) then // dib not loaded from tif file

      ResolutionInt := Round( GetResolution_ext() ); // Get resolution
      N_Dump1Str( 'Resolution, dpi: ' + IntToStr( ResolutionInt ) ) ;
      ResolutionInt := ( ResolutionInt * meter ) div inch;
      N_Dump1Str( 'Resolution, PixPerMeter: ' + IntToStr( ResolutionInt ) ) ;
      // set DIBObj resolution
      dib.DIBInfo.bmi.biXPelsPerMeter := ResolutionInt;
      dib.DIBInfo.bmi.biYPelsPerMeter := ResolutionInt;

      // Create slide
      NewSlide := K_CMSlideCreateFromDIBObj( dib, @( AFrm.CMOFPProfile^.CMAutoImgProcAttrs ) );
      NewSlide.SetAutoCalibrated();
      NewSlide.ObjAliase := IntToStr( AFrm.CMOFNumCaptured );

      with NewSlide.P()^ do
      begin
        CMSSourceDescr   := AFrm.CMOFPProfile^.CMDPCaption;
        NewSlide.ObjInfo := 'Captured from ' + CMSSourceDescr;
        CMSMediaType     := AFrm.CMOFPProfile^.CMDPMTypeID;
        NewSlide.SetInitDCMAttrs( TK_PCMDCMAttrs(@AFrm.CMOFPProfile^.CMDPDModality) );
      end;

      Inc( AFrm.CMOFNumCaptured );

      K_CMEDAccess.EDAAddSlide( NewSlide ); // from now on NewSlide is owned by K_CMEDAccess
      // Add NewSlide to beg of CMOFPNewSlides^ array
      SetLength( AFrm.CMOFPNewSlides^, AFrm.CMOFNumCaptured );

      for i := High( AFrm.CMOFPNewSlides^ ) downto 1 do // Shift all elems by 1
        AFrm.CMOFPNewSlides^[i] := AFrm.CMOFPNewSlides^[i - 1];

      AFrm.CMOFPNewSlides^[0] := NewSlide;
      // Add NewSlide to CMOFThumbsDGrid
      Inc( AFrm.CMOFThumbsDGrid.DGNumItems );
      AFrm.CMOFThumbsDGrid.DGInitRFrame();
      AFrm.CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
      // Show NewSlide in SlideRFrame
      RootComp := NewSlide.GetMapRoot();
      AFrm.SlideRFrame.RFrShowComp( RootComp );
      // Set indicator to idle
      AFrm.StatusLabel.font.Color := clGreen;
      AFrm.StatusShape.Brush.Color := clGreen;
      AFrm.StatusLabel.Caption := 'Ready to take X-Rays';
    end; // if ( eventType = 8 ) then // Image Ready

  end;

  AFrm.timer_check.Enabled := True;
end;

//****************************************** TN_CMCDServObj8.CDSSettingsDlg ***
// Settings dialog handle
//
//     Parameters
// APDevProfile - Profile
//
procedure TN_CMCDServObj8.CDSSettingsDlg ( APDevProfile: TK_PCMDeviceProfile );
var
  id: Integer;
begin
  First := True;

  // Try to initialize Gendex if is not initialized yet
  if ( 0 = CDSDllHandle ) then
    if not CDSInitAll() then
      Exit;

  // id = ProductName
  id := StrToIntDef( APDevProfile.CMDPProductName, -1 );

  if ( 0 > id ) then // if wrong id
  begin
    N_CMV_ShowCriticalError( 'Gendex', 'id < 0' );
    Exit;
  end; // if ( 0 > id ) then // if wrong id

  Select_ext( id );        // select device
  DisplayProperties_ext(); // show native Gendex properties dialog
end; // procedure TN_CMCDServObj8.CDSSettingsDlg

//********************************* TN_CMCDServObj8.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj8.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  if AProductName = 'QuadSpeed DenOptix' then
    Result := 28
  else
    Result := 23;
end; // function TN_CMCDServObj8.CDSGetDefaultDevIconInd

//********************************** TN_CMCDServObj8.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj8.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
  Result := 'DX';
end; // function TN_CMCDServObj8.CDSGetDefaultDevDCMMod

//***************************************** TN_CMCDServObj8.FCapturePrepare ***
// Capture Prepare
//
//     Parameters
// APDevProfile - pointer to profile
// ASlidesArray - resulting Slides Array
//
procedure TN_CMCDServObj8.FCapturePrepare(  APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray );
begin
  First := True; // Initial value
  SetLength( ASlidesArray, 0 ); // Clear Slides Array
  // Create capture form
  CaptForm := TN_CMCaptDev8Form.Create( Application );

  with CaptForm, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    CMOFPProfile    := TK_PCMOtherProfile( APDevProfile ); // set CMCaptDev8Form.CMOFPProfile field
    Caption         := CMDPCaption;
    CMOFPNewSlides  := @ASlidesArray; // for using in CMCaptDev8Form methods
    CMOFNumCaptured := 0;

    // capture button must be shown only for these ids
    bnCapture.Visible := N_CMV_CheckStrParam( N_MemIniToString( 'CMS_UserDeb',
                                              'GendexShowCaptureButton',
                                              '1,9' ), APDevProfile^.CMDPProductName );

    // rotate arrows must be shown for any ids, except these
    tbRotateImage.Visible := not N_CMV_CheckStrParam( N_MemIniToString( 'CMS_UserDeb',
                                                      'GendexHideImageRotate',
                                                      '4,9,12,13' ), APDevProfile^.CMDPProductName );
    StatusLabel.font.Color  := clGreen;
    StatusShape.Brush.Color := clGreen;
    StatusLabel.Caption     := 'Ready to take X-Rays';
  end; // with CaptForm, APDevProfile^ do
end; // procedure TN_CMCDServObj8.FCapturePrepare

Initialization
  // Create and Register GendexService Object
  N_CMCDServObj8 := TN_CMCDServObj8.Create( N_CMECD_Gendex_Name );
  N_CMCDServObj8.CDSDllHandle := 0;
  N_CMCDServObj8.First := True;

  with K_CMCDRegisterDeviceObj( N_CMCDServObj8 ) do
  begin
    CDSCaption := 'Gendex';
    IsGroup := True;
    ShowSettingsDlg := True;
  end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj8 ) do

end.
