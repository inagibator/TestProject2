unit N_CM1;
// Types and procedures for CMS Application

interface
uses Windows, Classes, Graphics, Controls, ExtCtrls, ComCtrls, Menus, ActnList,
  K_Types, K_UDT1, K_Script1, K_SBuf, K_STBuf, K_CM0,
  N_Types, N_Lib0, N_Lib2, N_Gra2,
  N_CompCL, N_CompBase, N_Comp1, N_Comp2, N_DGrid, N_Rast1Fr;

const
  N_CMSReleaseDate = '24/04/2022'; // Build 4.053.00 for Delphi 7, 2010 and XE5

  N_CMSkipImgDEMOLabel = False;
//  N_CMSkipImgDEMOLabel = True;
  K_CMSNF_SharpenTestMode = False;
//  K_CMSNF_SharpenTestMode = True;
  K_CMSNF_NoiseTestMode = False;
//  K_CMSNF_NoiseTestMode = True;
//  N_CMTWAIN_DebugMode = False;
  N_CMTWAIN_DebugMode = False;

type TN_CMLogFlags = Set Of ( // CMS Log Info collecting Flags
  cmpfEnable,     // Enable Collecting Log Info

  cmpfCompInfo,   // Collect info about Computer if not yet
  cmpfMenuAll,    // Collect info about starting and finishing of all Menu Actions

  cmpfVideoMain,  // Collect info about Main Video Actions
  cmpfVideoAll,   // Collect info about All Video Actions
  cmpfVideoStat,  // Collect Video Statistics (Variants of Video Settings) in special Database

  cmpfTWAINMain,  // Collect info about Main TWAIN Actions
  cmpfTWAINAll,   // Collect info about All TWAIN Actions

  cmpfOtherMain,  // Collect info about Main Other Actions
  cmpfOtherAll,   // Collect info about All Other Actions

  cmpfBinDumps,   // Collect binary Dumps of some Memory Blocks

  cmpfDatabase,   // Collect info about working with Database (Sybase)
  cmpfDatabaseAll,// Collect detailed info about working with Database (Sybase)
  cmpfDatabaseFull,// Collect full detailed info about working with Database (Sybase) - for CMS Client Activity Timestamp monitoring

  cmpfCOMServer,  // Collect info about working with COM

  cmpfVObjEvents, // Collect info about Vector Objects RFA Events
  cmpfVObjMain    // Collect info about Vector Objects Creating and Editing
); // type TN_CMLogFlags = Set Of ( // CMS Log Info collecting Flags

type TN_CMVideoStatRecord = packed record // CMS Video Statistics Record type
  CMSRCompName:   string; // Computer Name
  CMSRDeviceName: string; // Video or TWAIN device Name
  CMSRImageSize:  string; // Image Size in Pixels as string
  CMSROperation:  string; // Operation Name (N_CMS_Operations[i])
  CMSRVideoCodec: string; // Video Codec Name
  CMSRVideoCMST:  string; // Video Capture Media SubType format
  CMSRIsWorking:  string; // '?', 'OK?' or 'Failed' strings
  CMSRComments:   string; // Any comments (may be several text lines)
  CMSRDateTime:   string; // Date ans Time of adding to Statistics Table
end; // type TN_CMVideoStatRecord = packed record // CMS Video Statistics Record type
type TN_PCMVideoStatRecord = ^TN_CMVideoStatRecord;

type TN_CMButDevOneDLL = packed record // CMS Button's Device info for one DLL
  CMBDUserName:  string;  // Buttons Device User Name to show in UI Combobox
  CMBDDllFName:  string;  // Buttons Device DLL File Name
  CMBDDllHandle: HMODULE; // DLL Windows Handle
end; // type TN_CMVideoDevButtonsDLL
type TN_CMButDevDLLs = Array Of TN_CMButDevOneDLL;

type TN_CMGlobObj = class( TObject ) // Global Object for CM Project
    constructor Create ();
    destructor  Destroy; override;
  public
    CMStringsToDraw:  TStringList; // Strings to Draw (near Thumbnail or Slide while Printing)
    CMGOUsePedal:     boolean;     // Foot Pedal (CMGOPedalGetState function) should be used
    CMGOPedalReverse: boolean;     // Reverse Foot Pedal Keys

  procedure TwainOnClickHandler ( ASender: TObject );

  function  CMGOPedalLoad       (): integer;
  procedure CMGOPedalUnLoad     ();
  function  CMGOPedalGetState   ( out ACurState, APrevState: integer ): integer;
  procedure CMMaxVSWarning      ( APRast1Frame: Pointer; AMaxValue: float );
  procedure CMGOShow1Str        ( AStr: String );
end; // type TN_CMGlobObj = class( TObject )


    //*********** Global Procedures  *****************************

procedure N_CMMemIniToCurState  ();
procedure N_InitCMSArchGCont    ( UDArchive : TN_UDBase = nil );
procedure N_InitCMSArchive      ( UDArchive: TN_UDBase );
procedure N_InitOnceAfterIniReady ();
procedure N_CMSCreateDumpFiles  ( AFlags: integer );
procedure N_CMSAddCurState      ( AStrings: TStrings; AIndent: integer );

function  N_CMCreateCalibratedSlide ( var ADIBObj: TN_DIBObj; APProfile: TK_PCMOtherProfile;
                                              ASlideDPI: float ): TN_UDCMSlide;
function  N_CMSBuildInfo        (): string;
function  N_CMECDConvProfile    ( APDevProfile: TK_PCMDeviceProfile ) : Boolean;
procedure N_TestFlashLight      ( AEnable: boolean );
procedure N_CMSetNeededCurrentDir ();


    //*********** Global consts  *****************************
const
//  N_CMSDump1LCInd: integer = 0; // CMS Dump1 Log Channel Index
//  N_CMSDump2LCInd: integer = 2; // CMS Dump2 Log Channel Index

  //***** The following Service Object Device Names should not be changed!
  N_CMECD_TestDev1_Name     = 'TestDev1_Name';   // Test Device #1 Service Object (Device Group) Name
  N_CMECD_Demo1Dev_Name     = 'Demo1Dev_Name';   // Demo1 Device Service Object (Device Group) Name
  N_CMECD_Demo2Dev_Name     = 'Demo2Dev_Name';   // Demo2 Device Service Object (Device Group) Name
  N_CMECD_SOREDEX_Name      = 'SOREDEX_Name';    // CaptDev3  SOREDEX Service Object (Device Group) Name
  N_CMECD_Kavo_Name         = 'Kavo_Name';       // CaptDev3  Kavo Service Object (Device Group) Name
  N_CMECD_Instrum_Name      = 'Instrum_Name';    // CaptDev3  Instrumentarium Service Object (Device Group) Name
  N_CMECD_Schick_CDR_Name   = 'Schick_CDR_Name'; // CaptDev4  Schick_CDR Service Object (Device Group) Name
  N_CMECD_Planmeca_Name     = 'Planmeca_Name';   // CaptDev5  Planmeca Service Object (Device Group) Name
  N_CMECD_Duerr_Name        = 'Duerr_Name';      // CaptDev6  Duerr Service Object (Device Group) Name
  N_CMECD_E2V_Name          = 'E2V_Name';        // CaptDev7  E2V (MediaRay) Service Object (Device Group) Name
  N_CMECD_Gendex_Name       = 'Gendex_Name';     // CaptDev8  Gendex Service Object (Device Group) Name
  N_CMECD_E2VNik_Name       = 'E2VNik_Name';     //           E2V Nik Service Object (Device Group) Name
  N_CMECD_Kodak_Name        = 'Kodak_Name';      // CaptDev9  Kodak Service Object (Device Group) Name
  N_CMECD_Capt10_Name       = 'Capt10_Name';       // CaptDev10 Service Object (Device Group) Name
  N_CMECD_Trident_Name      = 'Trident_Name';      // CaptDev11 Trident Service Object (Device Group) Name
  N_CMECD_MediaRayPlus_Name = 'MediaRayPlus_Name'; // CaptDev12 MediaRayPlus Service Object (Device Group) Name
  N_CMECD_Apixia_Name       = 'Apixia_Name';       // CaptDev13 Apixia Service Object (Device Group) Name
  N_CMECD_Hamamatsu_Name    = 'Hamamatsu_Name';    // CaptDev14 Hamamatsu Service Object (Device Group) Name
  N_CMECD_MediaScan_Name    = 'MediaScan_Name';    // CaptDev15 MediaScan (FireCR) Object (Device Group) Name
  N_CMECD_CSH_Name          = 'CSH_Name';          // CaptDev16 CSH (Care Stream Health, Kodak) Object (Device Group) Name
  N_CMECD_Progeny_Name      = 'Progeny_Name';      // CaptDev17 Progeny Service Object (Device Group) Name
  N_CMECD_PaloDEx_Name      = 'PaloDEx_Name';      // CaptDev18 PaloDex Service Object (Device Group) Name
  N_CMECD_VatechCBCT_Name   = 'VatechCBCT_Name';   // CaptDev19 RayScan CBCT Service Object (Device Group) Name
  N_CMECD_MediaRayPlus2_Name= 'MediaRayPlus2_Name';// CaptDev20 MediaRayPlus2 Service Object (Device Group) Name
  N_CMECD_Schick33_Name     = 'Schick2_Name';      // CaptDev21 Schick 2 Service Object (Device Group) Name
  N_CMECD_Sirona_Name       = 'Sirona_Name';       // CaptDev22 Sirona Service Object (Device Group) Name
  N_CMECD_Owandy_Name       = 'Owandy_Name';       // CaptDev23 Owandy Service Object (Device Group) Name
  N_CMECD_Acteon_Name       = 'Acteon_Name';       // CaptDev24 Acteon Service Object (Device Group) Name
  N_CMECD_SlidaCBCT_Name    = 'SlidaCBCT_Name';    // CaptDev25 RayScan CBCT Service Object (Device Group) Name
  N_CMECD_Morita_Name       = 'Morita_Name';       // CaptDev26 Morita 2D Service Object (Device Group) Name
  N_CMECD_RayScan_Name      = 'RayScan_Name';      // CaptDev27 RayScan 2D Service Object (Device Group) Name
  N_CMECD_RayScanCBCT_Name  = 'RayScanCBCT_Name';  // CaptDev28 RayScan CBCT Service Object (Device Group) Name
  N_CMECD_MoritaCBCT_Name   = 'MoritaCBCT_Name';   // CaptDev29 Morita CBCT Service Object (Device Group) Name
  N_CMECD_Vatech_Name       = 'Vatech_Name';       // CaptDev30 Vatech 2D Service Object (Device Group) Name
  N_CMECD_Slida_Name        = 'Slida_Name';        // CaptDev31 Slida  2D Service Object (Device Group) Name
  N_CMECD_Trios_Name        = 'Trios_Name';        // CaptDev32 Trios Service Object (Device Group) Name
  N_CMECD_CSH2_Name         = 'CSH2_Name';         // CaptDev33 CSH 2 (Care Stream Health, Kodak) Object (Device Group) Name
  N_CMECD_MediaScan2_Name   = 'MediaScan2_Name';   // CaptDev34 MediaScan 2 (FireCR) Object (Device Group) Name
  N_CMECD_Kodak2_Name       = 'Kodak2_Name';       // CaptDev35 Kodak 2 Object (Device Group) Name


  N_CMFullStayOnTopList =
    N_CMECD_Schick_CDR_Name + N_CMECD_E2V_Name +
    N_CMECD_Trident_Name + N_CMECD_MediaRayPlus_Name +
    N_CMECD_Apixia_Name + N_CMECD_Hamamatsu_Name +
    N_CMECD_MediaScan_Name;

  N_CMSVideoComprSectName: string = 'CMS_VideoCompr'; // Ini file Section Name with Video Compressor Names

    //*********** Global Vars  *****************************
var
  // Capture Device Service Objects Order List
  K_CMCaptDevsOrderArray : array [0..28] of string = ( // N_CMECD_Demo1Dev_Name,
                                                      N_CMECD_Apixia_Name,
                                                      N_CMECD_CSH_Name,
                                                      N_CMECD_Duerr_Name,
                                                      N_CMECD_Gendex_Name,
                                                      N_CMECD_Hamamatsu_Name,
                                                      N_CMECD_Instrum_Name,
                                                      N_CMECD_Kavo_Name,
                                                      N_CMECD_Kodak_Name,
                                                      N_CMECD_E2V_Name, // MediaRay
                                                      N_CMECD_MediaRayPlus_Name,
                                                      N_CMECD_MediaRayPlus2_Name,
                                                      N_CMECD_MediaScan_Name,
                                                      N_CMECD_Planmeca_Name,
                                                      N_CMECD_Progeny_Name,
                                                      N_CMECD_Schick_CDR_Name,
                                                      N_CMECD_Schick33_Name,
                                                      N_CMECD_SOREDEX_Name,
                                                      N_CMECD_Trident_Name,
                                                      N_CMECD_PaloDEx_Name,
                                                      N_CMECD_Sirona_Name,
                                                      N_CMECD_Owandy_Name,
                                                      N_CMECD_Acteon_Name,
                                                      N_CMECD_Slida_Name,
                                                      N_CMECD_Vatech_Name,
                                                      N_CMECD_Morita_Name,
                                                      N_CMECD_RayScan_Name,
                                                      N_CMECD_CSH2_Name,
                                                      N_CMECD_MediaScan2_Name,
                                                      N_CMECD_Kodak2_Name );

  // Capture Device Service Objects Order List
  K_CMCaptDevsOrderArray3D : array [0..3] of string = ( // N_CMECD_Demo1Dev_Name,
                                                      N_CMECD_SlidaCBCT_Name,
                                                      N_CMECD_MoritaCBCT_Name,
                                                      N_CMECD_RayScanCBCT_Name,
                                                      N_CMECD_VatechCBCT_Name );
//                                                      N_CMECD_Trios_Name );

  N_CM_GlobObj: TN_CMGlobObj; // Global Object for CM Project

  N_CM_ThumbFrameFont:      TN_UDNFont; // Font used in ThumbFrame
  N_CM_ThumbFrameRowHeight:    integer; // One Row Height (used in TN_CMDrawSlideObj.DrawOneThumb6)
  N_CM_ThumbFramePropFont:  TN_UDNFont; // Font used in ThumbFrame in Slide Properties Form
  N_CM_ThumbFrameCaptFont:  TN_UDNFont; // Font used in ThumbFrame in Capture Video Form
  N_CM_VideoStat:          TK_UDRArray; // CMS Video Statistics Table

  N_CM_SlideMarkColor: integer = $6A240A;    // Slide mark color in ThumbFrame and EditFrame

  N_CMDIBURect: TFRect = ( Left:0; Top:0; Right:100; Bottom:100 );

  N_CM_CompName:     string; // Computer Name, used in Statistics, change later to Location

  N_CM_LogFlags: TN_CMLogFlags;

  N_SPLTC_CMLogFlags: integer; // N_CM_ProtFlags SPL Type

  N_CMVerNumber:    integer;
  N_CMBuildNumber:  integer;
  N_CMBuildSNumber: integer;
  N_CMSVersion:     string; // CMS exe file version for saving to Log Channel and in CMAbout Form
  N_CM_RegSavedLog: string; // Region Settings String for log, that was collected before init logs


  N_CMS_Operations: Array [0..2] of string = //
    ( 'Still Image', 'Record Video', 'TWAIN' );

  N_CMLCIAllTwain: integer = -1; // Logging Chanel Index for All TWAIN Messages
  N_CMLCIAllVideo: integer = -1; // Logging Chanel Index for All Video actions

  N_CMOriginalCurrentDir: String;


implementation
uses math, Forms, SysUtils, Dialogs, StrUtils,
  K_UDC, K_UDConst, K_CLib0, K_Arch, K_Parse, K_UDT2, K_CLib,
  N_ClassRef, N_Gra0, N_Gra1, N_Lib1, N_EdRecF, N_Video, N_CMVideo2F,
  N_ME1, N_GCont, N_CMResF, N_CMMain5F, N_CML1F, N_CMCaptDev3S,
  N_CMFPedalSF;


//****************** TN_CMGlobObj class methods  **********************

//***************************************************** TN_CMGlobObj.Create ***
//
constructor TN_CMGlobObj.Create;
var
  i: integer;
begin
  CMStringsToDraw := TStringList.Create();

  for i := 1 to 5 do
    CMStringsToDraw.Add('');
end; //*** end of Constructor TN_CMGlobObj.Create

//**************************************************** TN_CMGlobObj.Destroy ***
//
destructor TN_CMGlobObj.Destroy;
begin
  CMStringsToDraw.Free;
  Inherited;
end; //*** end of destructor TN_CMGlobObj.Destroy

//**************************************** TN_CMGlobObj.TwainOnClickHandler ***
// Twain OnClick Handler
//
//     Parameters
// ASender - Event Sender (MenuItem of ToolButton)
//
// OnClick handler for all MenuItems and Buttons, associated with TWAIN
// Capturing devices
//
// ASender.Tag contains needed device Profile index in CMTwainProfiles Array
//
procedure TN_CMGlobObj.TwainOnClickHandler( ASender: TObject );
var
  DevInd: integer;
begin
  DevInd := -1;

  if ASender is TMenuItem then
    DevInd := TMenuItem(ASender).Tag
  else if ASender is TToolButton then
    DevInd := TToolButton(ASender).Tag
  else if ASender is TAction then
    DevInd := TAction(ASender).Tag;

  N_CM_MainForm.CMMFShowStringByTimer( 'TWAIN ' + IntToStr( DevInd ) );
end; // procedure TN_CMGlobObj.TwainOnClickHandler

//******************************************** TN_CMGlobObj.CMGOPedalLoad() ***
// Load needed Foot Pedal DLL
//
//     Parameters
// Result - Returns 0 if OK
//
// Foot Pedal Index (in N_CMFootPedalDLLs array) is in MemIni [CMS_Main].FootPedalIndex
//
function TN_CMGlobObj.CMGOPedalLoad(): integer;
begin
  Result := 0;
end; // function TN_CMGlobObj.CMGOPedalLoad

//******************************************** TN_CMGlobObj.CMGOPedalLoad() ***
// Unload needed Foot Pedal DLL
//
// Foot Pedal Index (in N_CMFootPedalDLLs array) is in MemIni [CMS_Main].FootPedalIndex
//
procedure TN_CMGlobObj.CMGOPedalUnLoad();
begin

end; // procedure TN_CMGlobObj.CMGOPedalUnLoad

//****************************************** TN_CMGlobObj.CMGOPedalGetState ***
// Load needed Foot Pedal DLL
//
//     Parameters
// ACurState  - Current Foot Pedal Keys state
// APrevState - Previous (ACurState in previous call) Foot Pedal Keys state
// Result     - Returns 0 if OK
//
function TN_CMGlobObj.CMGOPedalGetState( out ACurState, APrevState: integer ): integer;
begin
  Result := 0;

end; // function TN_CMGlobObj.CMGOPedalGetState

//********************************************* TN_CMGlobObj.CMMaxVSWarning ***
// Show warning about too big RFVectorScale
//
//     Parameters
// APRast1Frame - Pointer to Rast1Frame
// AMaxValue    - max possible RFVectorScale (defined by RFMaxBufSizeMB)
//
// Can be used as TN_Rast1Frame.RFOnMaxVSProcObj
// Note that APRast1Frame^.RFVectorScale contains current RFVectorScale,
// that cannot be realised, because of too bit OCanv BufSize
//
procedure TN_CMGlobObj.CMMaxVSWarning( APRast1Frame: Pointer; AMaxValue: float );
begin
  // N_CML1Form.LLLNotEnoughMem1 = 'There is not enough memory to zoom this image. Press OK to continue.'
  K_CMShowMessageDlg( N_CML1Form.LLLNotEnoughMem1.Caption, mtWarning );
end; //*** end of procedure TN_CMGlobObj.CMMaxVSWarning

//************************************************* TN_CMGlobObj.CMGOShow1Str ***
// Show given String in Main Form StatusBar
//
//     Parameters
// AStr - string to show
//
// Can be used as N_Show1Str
//
procedure TN_CMGlobObj.CMGOShow1Str( AStr: String );
begin
  N_CM_MainForm.CMMFShowString( AStr );
  N_CM_MainForm.Update;
end; //*** end of procedure TN_CMGlobObj.CMGOShow1Str


    //*********** Global Procedures  *****************************

//**************************************************** N_CMMemIniToCurState ***
// Initialize needed globals form MemIni
//
procedure N_CMMemIniToCurState();
begin
  N_CMLCIAllTwain := N_MemIniToInt( 'Dump', 'AllTwain', -1 );
  N_CMLCIAllVideo := N_MemIniToInt( 'Dump', 'AllVideo', -1 );
  N_LCIDeb1     := N_MemIniToInt( 'Dump', 'Deb1',     -1 );
  N_LCIDeb2     := N_MemIniToInt( 'Dump', 'Deb2',     N_Dump1LCInd );
end; // procedure N_CMMemIniToCurState()

//****************************************************** N_InitCMSArchGCont ***
// CMS Project Archive Initialization procedure, called from K_InitArchiveGCont
// (is assigned to K_InitAppArchProc variable in Proj_CMS)
//
procedure N_InitCMSArchGCont( UDArchive : TN_UDBase = nil );
var
  DllFName, PatchFlagFName: string; // Taras Patch DLL File Name
  DllHandle: HMODULE; // DLL Windows Handle
  FuncAnsiName: AnsiString;
  PatchInit: TN_stdcallProcVoid;
begin
//*** create new archive if needed
  if UDArchive = nil then UDArchive := K_CurArchive;

  N_RFMaxVectorScale :=  50.0; // Default value for TN_Rast1Frame.RFMaxVectorScale
  N_RFMinRelObjSize  :=   0.3; // Default value for TN_Rast1Frame.RFMinRelObjSize
  N_RFMaxRelObjSize  :=   8.0; // Default value for TN_Rast1Frame.RFMaxRelObjSize
  N_RFMaxBufSizeMB   := 400.0; // Default value for TN_Rast1Frame.RFMaxBufSizeMB

  N_InitVREArchive( UDArchive ); // VRE specific initialization
  N_InitCMSArchive( UDArchive ); // CMS specific initialization

//0  K_CMEDAccessInit1();
//1  K_CMEDAccessInit11();

//0  if K_CMSAppStartContext.CMASState = K_cmasStop then Exit; // Stop Initialization if some Errors are detected


  PatchFlagFName := K_ExpandFileName( '(##Exe#)' + '!SetWindowPosErrorOccured.txt' );

  if FileExists( PatchFlagFName ) then // use Taras Patch
  begin
    N_Dump2Str( 'File !SetWindowPosErrorOccured.txt exists!' );

    DllFName := 'injector.dll';
    DllHandle := Windows.LoadLibrary( @DllFName[1] );

    if DllHandle = 0 then Exit; // a precaution

    N_Dump2Str( 'injector.dll Loaded' );

    FuncAnsiName := 'Init';
    PatchInit := GetProcAddress( DllHandle, @FuncAnsiName[1] );

    if Assigned( PatchInit ) then
    begin
      PatchInit();
      N_Dump2Str( 'Taras Patch done!' );
    end;

  end; // if FileExists( PatchFlagFName ) then // use Taras Patch

end; //*** end of procedure N_InitCMSArchGCont

//******************************************************** N_InitCMSArchive ***
// Initialize Archive by CMS specific objects (is called from N_InitCMSArchGCont)
// (create needed UDBase and global objects, set needed global variables)
//
procedure N_InitCMSArchive( UDArchive: TN_UDBase );
var
  SysObjects: TN_UDBase;  // several System Obects (Fonts, ... )
begin
  //***** Create standard Archive UObjects and set global pointers to them:

  N_Dump1Str( 'N_InitCMSArchive 1' );

  //*** Objects for System Setting
  SysObjects := K_UDCursorForceDir( 'CA:\ME\SysObjects' );
  N_CM_ThumbFrameFont := TN_UDNFont(SysObjects.DirChildByObjName( 'ThumbFrameFont' ));
  if N_CM_ThumbFrameFont = nil then
  begin
    N_CM_ThumbFrameFont := TN_UDNFont.Create2( 10, 'Verdana' );
    N_CM_ThumbFrameFont.ObjName := 'ThumbFrameFont';
    SysObjects.AddOneChild( N_CM_ThumbFrameFont );
  end; // if N_CM_ThumbFrameFont = nil then
  N_CM_ThumbFrameRowHeight := 12; // Should be > Font Height

//  N_Dump1Str( 'N_InitCMSArchive 201' );

  N_CM_ThumbFramePropFont := TN_UDNFont(SysObjects.DirChildByObjName( 'ThumbFramePropFont' ));
//  N_Dump1Str( 'N_InitCMSArchive 202' );

  if N_CM_ThumbFramePropFont = nil then
  begin
//    N_Dump1Str( 'N_InitCMSArchive 21' );
    N_CM_ThumbFramePropFont := TN_UDNFont.Create2( 13, 'Arial Black' );
//    N_Dump1Str( 'N_InitCMSArchive 22' );
    TN_PNFont(N_CM_ThumbFramePropFont.PDE(0)).NFBold := 255;
//    N_Dump1Str( 'N_InitCMSArchive 23' );
    N_CM_ThumbFramePropFont.ObjName := 'ThumbFramePropFont';
//    N_Dump1Str( 'N_InitCMSArchive 24' );
    SysObjects.AddOneChild( N_CM_ThumbFramePropFont );
//    N_Dump1Str( 'N_InitCMSArchive 25' );
  end; // if N_CM_ThumbFramePropFont = nil then

//  N_Dump1Str( 'N_InitCMSArchive 3' );

  N_CM_ThumbFrameCaptFont := TN_UDNFont(SysObjects.DirChildByObjName( 'ThumbFrameCaptFont' ));
  if N_CM_ThumbFrameCaptFont = nil then
  begin
    N_CM_ThumbFrameCaptFont := TN_UDNFont.Create2( 13, 'Arial' );
//    TN_PNFont(N_CM_ThumbFrameCaptFont.PDE(0)).NFBold := 255;
    N_CM_ThumbFrameCaptFont.ObjName := 'ThumbFrameCaptFont';
    SysObjects.AddOneChild( N_CM_ThumbFrameCaptFont );
  end; // if N_CM_ThumbFrameCaptFont = nil then

  N_FPCBObj := TN_FPCBObj.Create;
//  N_CMSInitDentalUnit(); // for debug

//  N_Dump1Str( 'N_InitCMSArchive 4' );
end; // procedure N_InitCMSArchive

//************************************************* N_InitOnceAfterIniReady ***
// Initialize all needed objects and variables.
// This procedure should be call only once and after N_MemIni is fully ready.
//
procedure N_InitOnceAfterIniReady();
begin

end; // procedure N_InitOnceAfterIniReady

//**************************************************** N_CMSCreateDumpFiles ***
// Create Dump Files in (#LogFiles#)
//
//     Parameters
// AFlags - what files to create flags (bit0=1 - Move Dump file)
//          (bit1=1 - Create Screenshot)
//
//#F
// 1. Create Dump Files subdir - YYYY_MM_DD-HH_MM_SS subdir in (#LogFiles#) dir
// 2. Save Dump2 strings into this subdir
// 3. Save current CMS State into this subdir
// 4. Save Screenshot into this subdir
//#/F
//
procedure N_CMSCreateDumpFiles( AFlags: integer );
var
  DateTimePref, LogFilesDir, FName, CurName, NewName, FNamePrefix: string;
  SL: TStringList;
begin
  LogFilesDir := K_ExpandFileName( '(#CMSLogFiles#)' );
  DateTimePref := N_GetDateTimeStr1( N_LogChannels[N_Dump1LCInd].LCTimeShift + Now() );
  CreateDir( LogFilesDir + DateTimePref );
  N_Dump1Str( DateTimePref + ' Folder with dump files created' );
  FNamePrefix := LogFilesDir + DateTimePref + '\' + DateTimePref;

  N_Dump2Str( '?????' );

  try //***** Flush and Copy (or Move) Dump2 file
    N_Dump1Str( 'Application N_CMSCreateDumpFile FlushCounters' + N_GetFlushCountersStr() );
    N_LCExecAction( -1, lcaFlush );
    CurName := N_LogChannels[N_Dump2LCInd].LCFullFName;
    NewName := FNamePrefix + '_ErrLog.txt';

    if (AFlags and $01) <> 0 then //  Move (call while terminating after exception)
    begin
      RenameFile( CurName, NewName );
      N_LogChannels[N_Dump2LCInd].LCFullFName := NewName; // set NewName as current for Dump2
    end
    else //******************  Copy (while creating control point)
      K_CopyFile( CurName, NewName );
  finally
  end;

  if (AFlags and $02) <> 0 then //  Create Screenshot
  try //***** Create Screenshot
    FName := FNamePrefix + '_ScreenShot.png';
    N_CreateScreenShot( FName );
  finally
  end;

  try //***** Create CMS State description
    SL := TStringList.Create;
    SL.Add( '***** CMS State Dump:' );
    SL.Add( N_CMSBuildInfo() );
    SL.Add( '' );
    N_CMSAddCurState( SL, 0 );
    SL.Add( '' );
    K_CMSAddCurState( SL, 0 );
    SL.Add( '***** End of CMS State Dump *****' );

    FName := FNamePrefix + '_CMS_State.txt';
    N_SaveStringsToAnsiFile( FName, SL );
  finally
  end;
end; // procedure N_CMSCreateDumpFiles

//******************************************************** N_CMSAddCurState ***
// Add to given strings CMS current state params
//
//     Parameters
// AStrings - given strings
// AIndent  - number of spaces to add before all strings
//
procedure N_CMSAddCurState( AStrings: TStrings; AIndent: integer );
var
  i: integer;
  Prefix: string;
begin
  AStrings.Add( '' );
  Prefix := DupeString( ' ', AIndent+2 );
  AStrings.Add( Prefix + '******************** Computer info:' );
  N_PlatformInfo( AStrings, $0363 );
  AStrings.Add( Prefix + '******************** End of Computer info' );
  AStrings.Add( '' );

  AStrings.Add( '' );
  AStrings.Add( Prefix + '******************** Ed3Frames info:' );
  with N_CM_MainForm do
  begin
    for i := 0 to CMMFNumVisEdFrames-1 do
    begin
      AStrings.Add( '    Ed3Frame ' + IntToStr(i) + ':' );
      CMMFEdFrames[i].Ed3FrAddCurState( AStrings, AIndent+2 );
      AStrings.Add( '' );
    end; // for i := 0 to CMMFNumEdFrames-1 do
  end; // with N_CM_MainForm do
  AStrings.Add( Prefix + '******************** End of Ed3Frames info' );
  AStrings.Add( '' );

  if N_CMVideo2Form <> nil then
    N_CMVideo2Form.V2FAddCurState( AStrings, AIndent+2 );

  AStrings.Add( '' );
  AStrings.Add( '  ******************** N_CurMemIni:' );
  N_CurMemIni.GetStrings( AStrings );
  AStrings.Add( '  ******************** End of N_CurMemIni' );
  AStrings.Add( '' );
end; // procedure N_CMSAddCurState

//*********************************************** N_CMCreateCalibratedSlide ***
// Create Calibrated Slide by given ASlideDPI using K_CMSlideCreateFromDIBObj
//
//     Parameters
// ADIBObj   - given Device Independent Bitmap Object for slide creation
// APProfile - pointer to Device Profile
// Result    - Returns created TN_UDCMSlide object
//
function N_CMCreateCalibratedSlide( var ADIBObj: TN_DIBObj; APProfile: TK_PCMOtherProfile;
                                              ASlideDPI: float ): TN_UDCMSlide;
var
  SavedDPI: float;
begin
  SavedDPI := APProfile^.CMAutoImgProcAttrs.CMAIPResolution;

  if SavedDPI = 0 then // DPI is not given in Device profile, use ASlideDPI
    APProfile^.CMAutoImgProcAttrs.CMAIPResolution := ASlideDPI;

  Result := K_CMSlideCreateFromDIBObj( ADIBObj, @(APProfile^.CMAutoImgProcAttrs) );

  if SavedDPI = 0 then // resore DPI in Profile field
    APProfile^.CMAutoImgProcAttrs.CMAIPResolution := 0;

end; // function N_CMCreateCalibratedSlide

//********************************************************** N_CMSBuildInfo ***
// Return String with CMS Build Info
//
function N_CMSBuildInfo(): string;
begin
  Result := 'CMS Build ' + N_CMSVersion + ' from ' + N_CMSReleaseDate;

  if K_CMDemoModeFlag then
    Result := Result  + ' (Demo)'
  else if N_MemIniToBool( 'CMS_Main', 'UseExtDB', False ) then
    Result := Result  + ' (Full)'       // Full mode with Database
  else
    Result := Result  + ' (Full,NoDB)'; // Full mode without Database

  if K_CMDebVersionModeFlag then
    Result := Result  + ' [DEB]';

  Result := Result  + ' CompName="' + N_CM_CompName + '"';

  Result := Result  + N_StrCRLF + '                      Language: ' +
            K_GetCurLangText2( 'FileInfo', 'FileInfo', 'Default English, no language file' );

  Result := Result  + N_StrCRLF + '                        Region: ' + N_CM_RegSavedLog;

end; //*** end of function N_CMSBuildInfo

//****************************************************** N_CMECDConvProfile ***
// Convert old Capture Device Profile to new
//
//     Parameters
// APDevProfile - pointer to device profile record
// Result       - Return True if converted, False if not
//
function N_CMECDConvProfile( APDevProfile: TK_PCMDeviceProfile ) : Boolean;
var
  ECDInd: integer;
begin
  Result := False; // Not converted

  with APDevProfile^ do
  begin
    N_Dump1Str( 'N_CMECDConvProfile, CMDPDLLInd=' + IntToStr(CMDPDLLInd) );

    ECDInd := CMDPDLLInd;

    if (ECDInd >= N_CMECD_DigoraOpt) and
       (ECDInd <= N_CMECD_CranexNov) then // some SOREDEX Device
    begin
           if ECDInd = N_CMECD_DigoraOpt then CMDPProductName := N_CMECD_DigoraOptName
      else if ECDInd = N_CMECD_CranexD   then CMDPProductName := N_CMECD_CranexDName
      else if ECDInd = N_CMECD_CranexNov then CMDPProductName := N_CMECD_CranexNovName
      else Exit; // wrong Device Index

      CMDPGroupName := N_CMECD_SOREDEX_Name;
      Result := True; // converted
      Exit;
    end; // some SOREDEX Device

  end; // with APDevProfile^ do

end; // function N_CMECDConvProfile

procedure N_TestFlashLight( AEnable: boolean );
// Enable or Disable FlashLightMode in all EdFRames
var
  i: integer;
  TmpMapRoot, TmpComp: TN_UDCompVis;
begin
  N_Dump1Str( Format( 'FL Enable %s', [N_B2S(AEnable)] ));

  with N_CM_MainForm do
  begin

  for i := 0 to High(CMMFEdFrames) do // along all EdFrames
  begin
    if CMMFEdFrames[i] = nil then Continue;
//    if CMMFEdFrames[i].EdSlide = nil then Continue;

    with CMMFEdFrames[i] do
    begin
      if AEnable then
      begin
        N_s := EdFlashLightRFA.ActName;
        N_b := EdFlashLightRFA.ActEnabled;
        EdFlashLightRFA.ActEnabled := True;

        if EdSlide <> nil then
        begin
          TmpMapRoot := EdSlide.GetMapRoot();
          TmpComp := TN_UDCompVis(TmpMapRoot.DirChild( 3 ));
          if TmpComp <> nil then
            EdFlashLightRFA.CMFLComp := TmpComp;

        end; // if EdSlide <> nil then

      end else
      begin
        N_s := EdFlashLightRFA.ActName;
        N_b := EdFlashLightRFA.ActEnabled;
        EdFlashLightRFA.ActEnabled := False;
        RFrame.FinAnimation();
      end;
    end; // with CMMFEdFrames[i] do,

  end; // for i := 0 to High(CMMFEdFrames) do // along all EdFrames
  end; // with N_CM_MainForm do
end; // procedure N_TestFlashLight();

procedure N_CMSetNeededCurrentDir();
var
  BufSize: Integer;
  BufStr, BinFilesDir: String;
begin
  BufSize := GetCurrentDirectory( 0, nil ); // including terminating zero
  SetLength( BufStr, BufSize );
  GetCurrentDirectory( BufSize, @BufStr[1] );
  N_CMOriginalCurrentDir := MidStr( BufStr, 1, BufSize-1 ) + '\';
  BinFilesDir := ExtractFilePath( ParamStr( 0 ) );

  if N_CMOriginalCurrentDir <> BinFilesDir then
  begin
    SetCurrentDirectory( @BinFilesDir[1] );
    N_Dump1Str( Format( 'NewCurDir=%s,  PrevCurDir=%s', [BinFilesDir,N_CMOriginalCurrentDir] ) );
  end;

end; // procedure N_CMSetNeededCurrentDir


Initialization

  N_CMSVersion := 'ProductVersion';
  K_GetAppVersionInfo( @N_CMSVersion, @N_CMSVersion, 1 );
//  N_CMSVersion := '03.043.50';

  N_i := 1;
  if N_CMSVersion[3] = '.' then N_i := 2;
  N_CMVerNumber := StrToIntDef( copy( N_CMSVersion, 1, N_i ), 1 );
  N_CMSVersion := copy( N_CMSVersion, N_i+2, 100 );

  N_i1 := Length(N_CMSVersion);
  N_i := 4;
  if (N_i1 >= 2) and (N_CMSVersion[2] = '.') then N_i := 1
  else
  if (N_i1 >= 4) and (N_CMSVersion[4] = '.') then N_i := 3
  else
  if (N_i1 >= 3) and (N_CMSVersion[3] = '.') then N_i := 2;
  N_CMBuildNumber := StrToIntDef( copy( N_CMSVersion, 1, N_i ), 0 );
  N_CMSVersion := copy( N_CMSVersion, N_i+2, 100 );

  N_i1 := Length(N_CMSVersion);
  N_CMBuildSNumber := 0;
  if (N_i1 = 1) then
    N_CMBuildSNumber := StrToIntDef( N_CMSVersion, 0 )
  else if (N_i1 > 1) then
  begin
    if N_CMSVersion[2] = '.' then
      N_CMBuildSNumber := StrToIntDef( copy( N_CMSVersion, 1, 1 ), 0 )
    else
      N_CMBuildSNumber := StrToIntDef( copy( N_CMSVersion, 1, 2 ), 0 );
  end;

  N_CMSVersion := Format( '%.2d.%.3d.%.2d', [N_CMVerNumber, N_CMBuildNumber, N_CMBuildSNumber] );
  K_CMSSBuildNum := format( '%d%.3d', [N_CMVerNumber, N_CMBuildNumber] );

Finalization
  N_CM_GlobObj.Free;

end.

//  3.066 - {60EBC816-8068-4EAF-9C29-37CC081C79FC}
//  3.068 - {B3148250-12CF-41A9-A998-62598CA76887}
// 3.069-078 - {798A0532-68E8-4864-8F84-17616E756F27}
//  3.079 - {4E012B5E-93CC-4032-B511-DC0D5CA5BA78}
//  3.080 - {673F7299-1114-4A91-A8FD-BD7A93953928}
//  3.081 - {60C14E07-9816-4D97-8B1F-42FF9B4FAB7B}
//  3.082 - {3AA1E20D-CC46-4E69-98AD-B3E2A2B6FC65}
//  3.083 - {F5270540-F39B-42AC-AB19-6828E794DADA}
//  3.084 - {DCA79867-9FB8-4948-A5D4-54BD75549282}
//  3.085 - {9C226D88-A56D-44B5-BC81-6D36A019C66C}
//  3.086 - {7CEF82BE-14AA-408A-87A6-F24EC1113573}
//  3.087 - {F77BD1BD-7559-40B1-B547-4CD1002DA298}
//  3.088 - {C3E6C7AD-0EA7-4772-9DA6-D72320353FB6}
//  3.089 - {FB28147C-CB2D-4A51-9534-627D30485750}
//  3.090 - {6A6129A6-6ED0-4B42-810D-25DE4E5EF09C}
//  3.091 - {CF7D636C-7A24-48D3-B3CD-C1BC82EC278D}
//  3.092 - {5D510F69-0980-42E7-A01E-80103644B9D9}
//  3.093 - {7D4BCC2B-58A8-4EEF-A1C8-46FDE8674E17}
//  3.094 - {958E8E55-7B24-4ED9-894C-4CA392D03EF0}
//  3.095 - {EE9D472D-3DA0-4B15-9A17-0A7657CCF386}
//  3.096 - {17C9A77E-AF27-409D-A195-4AD3DF24AD9F}
//  3.097 - {E35B9A62-EAC7-4B84-9224-86CC98E6C1F8}
//  3.098 - {06F79C71-BFBF-453B-909B-30275D06FD31}
//  3.099 - {F5DDC651-8234-45A5-A863-4D76E5D4C128}
//  3.100 - {E3B2A2C1-9C39-4CBA-8B1B-EDF8FAF086B0}
//  3.101 - {D5DA30C7-1239-459B-9BD8-46967519D6F1}
//  3.102 - {8C3A94FF-D421-4358-8FB5-085EFA733A60}
//  3.103 - {7123080B-03C7-4E2F-951F-1E6B44573D1F}
//  3.104 - {6FC255BF-D4D2-49C7-B01B-0A0B85D0AECC}
//  3.105 - {CF959ACA-0B4F-4B26-914C-CA8AE96F1731}
//  3.106 - {643E2358-0DBC-4CE9-8DC1-B23092A67086}
//  3.107 - {D75745E4-D472-41DC-9709-756FBFBCF479}
//  3.108 - {D65CC022-115C-4451-9E68-1D5627DD258E}
//  3.109 - {1320BF4C-430D-4EA1-8D46-2CCEC27CD3D5}
//  3.110 - {9DF8366A-963D-4DDF-BC2F-B3EC37B2BDCF}
//  3.111 - {47BA3270-F586-465D-8E99-9A8528F11DAA}
//  3.112 - {DE5118EF-D8EE-4026-84BC-B0E92BBE46B5}
//  3.113 - {DE5118EF-D8EE-4026-84BC-B0E92BBE46B5} (same)
//  3.114 - {DE5118EF-D8EE-4026-84BC-B0E92BBE46B5} (same)
//  3.115 - {DE5118EF-D8EE-4026-84BC-B0E92BBE46B5} (same)
//  3.116 - {DE5118EF-D8EE-4026-84BC-B0E92BBE46B5} (same)
//  3.117 - {DE5118EF-D8EE-4026-84BC-B0E92BBE46B5} (same)
//  3.118 - {C4F71DB4-4908-4C72-AF3D-8A6289718800} K_CMSCom
//          {72F1F4B2-F41B-4FE9-92B1-AF0E810FCF1B} ID4WCMServer
//          {DE5118EF-D8EE-4026-84BC-B0E92BBE46B5} D4WCMServer
//  3.119 - {DE5118EF-D8EE-4026-84BC-B0E92BBE46B5} (same)
//  3.120 - {8A236E30-84A1-443F-925A-D2AF66FF14AE}
//  3.121 - {8A236E30-84A1-443F-925A-D2AF66FF14AE} (same)
//  3.122 - {8A236E30-84A1-443F-925A-D2AF66FF14AE} (same)
//  3.123 - {8A236E30-84A1-443F-925A-D2AF66FF14AE} (same)
//  3.124 - {C4F71DB4-4908-4C72-AF3D-8A6289718800} K_CMSCom
//          {72F1F4B2-F41B-4FE9-92B1-AF0E810FCF1B} ID4WCMServer
//          {8A236E30-84A1-443F-925A-D2AF66FF14AE} D4WCMServer
//  3.125 - (same)
//  3.126 - (same)
//  3.127 - (same)
//  4.001 - {C4F71DB4-4908-4C72-AF3D-8A6289718800} K_CMSCom
//          {72F1F4B2-F41B-4FE9-92B1-AF0E810FCF1B} ID4WCMServer
//          {E9A7FD23-EF0E-42DA-8BB7-2B3B8FCB008C} D4WCMServer
//  4.002 - {5A1613E3-9002-4EA5-929D-E7EDAD3D5B12} K_CMSCom
//          {A1B13E5F-B992-46A0-B36D-0AD02F294B81} ID4WCMServer
//          {76E50575-9EB0-42C8-A484-2F88C39F945B} D4WCMServer
//  4.003 - Same GUIDs
//  4.017 - {4DEC0052-06A1-430A-96B9-68E2DA23AAF9} K_CMSCom
//          {970813BC-D46A-4560-ADEB-9608EA012BC9} ID4WCMServer
//          {BBCD22CE-AED7-4759-B3B3-10C1B1BA1B3E} D4WCMServer
//  4.018 - 4.026.10 Same
//  4.027 - {58C5F729-8174-402E-B4C6-638B413ACFBF} K_CMSCom
//          {9D9DCFB7-42EE-4E14-BB79-6E3F0DA21BB2} ID4WCMServer
//          {DD119968-8A03-46BB-9A81-1D23484DD4BB} D4WCMServer
//  4.028 -
// {4C6704AA-188A-4170-8B6D-D11582FC6A70}
// {42A2212A-E8C6-4080-8767-E9A0176F4DD8}
// {F3AE95ED-3841-4E5F-A35A-25CB78B90324}
//  4.029 -
// {3FD4DDD4-1D99-4324-9904-27F2A8D36741}
// {0DAA0336-71A2-41FF-87C6-E495558B0B56}
// {36082E33-991F-4235-A3DF-98DDDF630B9A}
//  4.030 -
// {2BCC311D-7577-4B8B-97B3-656208CC7306}
// {EB62B440-FEFD-4075-822D-9915BED4C894}
// {609DDA86-4910-4CFC-BC52-126836548BB2}
//  4.031 -
// {986558B9-D191-45D2-ABDE-360F1846DFCE}
// {3E078B19-D1A5-457B-93C0-771F677DE6D7}
// {74390CED-FBE8-4EED-9A5D-8FEEE5B44FF4}
//  4.032 -
// {670B344E-BD5F-4BBF-AB78-BE9165D278A0}
// {3D28A7C9-76F0-4A52-BF39-4FD8B9B31FFB}
// {18956A82-E8BA-45CA-A7C0-5260107758FE}
//  4.033 -
// {60878344-251C-4E3A-92D3-6865B4CB3866}
// {8CCE1505-09A2-4563-808B-F7CB1E88BA8D}
// {1915C754-6441-4779-9423-8E8AF14A964A}
//  4.034 -
// {9D7C62E9-2552-4FC8-9CA0-1C1B622EF088}
// {D7222AE8-F495-496C-9413-4D2DC14EC646}
// {70374741-4DC6-40EC-B179-5E0D5EF16102}
//  4.035 -
// {68A2912B-C756-40A8-8ECD-B3BCB557C3A2}
// {05183FAC-CE26-464B-A931-17DFCFB0845E}
// {C57EDE0F-6DE0-4272-932C-BFBADCB30226}
//  4.036 -
// {D5CA81A4-5E29-46E7-A5BD-D0564411947E}
// {11CFE05A-6D7A-4AC9-B8EC-EBC36E8C90D5}
// {B98C0150-8B2C-42C4-AEE0-3962EB67D901}
//  4.037 -
// {19C99D65-D3AA-496B-AC65-99299ACF151B}
// {102BF6AF-16A9-4F48-9C00-2EEE9F6F3232}
// {CBBE0EE2-05AA-40AE-AD7E-A1004431DE97}
//  4.039 -
// {5236070E-16C8-4505-A542-D5573827F36B}
// {4FB4B573-141F-4E9B-B5F4-7639F5773206}
// {F96F7323-80D9-4F55-BA09-73C885DADC49}
//  4.040 -
// {32AFED7F-A746-4674-ADE6-83CF668E25A3}
// {2D5B8010-E664-4E64-BDFE-478FED63A916}
// {89DA84A1-7D65-4260-B954-47232FA6D86D}
//  4.041 -
// {8B1CAFDB-7583-4DCD-97EB-B6C52D5BFEC9}
// {C1E8BD50-008E-4271-9FB5-F90AB027370B}
// {A83DC93D-614E-40B5-A11D-9A545409C572}
//  4.042 -
// {DB3DB6B6-D656-43AC-9F2C-10448DD10B3E}
// {A7FAA5FD-88A2-4142-A01D-A8857AFACFA8}
// {A9E92ED5-1971-4488-9D88-AB235C61E91B}
//  4.043 -
// {4742398A-3575-4C70-B495-BCA9A20E1417}
// {281CF1E8-07A0-4AF1-9554-E91A76CBBBF0}
// {7C8D958F-4D18-48F7-A890-5532AF53ABAC}
//  4.044 -
// {8045D4EA-2496-47E8-883E-63934B778AB2}
// {A57D72BF-DEFF-41E7-AF72-18B5D938F930}
// {88B76F65-B46A-4B5D-A14B-4E24D3C0F172}
//  4.045 -
// {D05E280C-E6EB-4EA5-AF0E-608C2FBE826F}
// {E55F27ED-8C79-4ED0-88F4-58B09880C0E7}
// {40901A91-E4B9-406A-B48D-CF7A9499496F}
//  4.046 -
// {C22D103A-EFDE-4705-BE74-D9427F1FD77D}
// {2BCE4BEE-126E-4FCD-A91A-1AFA3C914755}
// {9A257483-2784-4DA6-B3C1-47E8560A1255}
//  4.047 -
// {C824A75E-4002-4094-94A1-495E7FE0BA5B}
// {CE4B2FC8-6606-4B7B-B661-B4D02303EC25}
// {C0A95559-A496-4768-8964-644B349DB6CF}
//  4.048 -
// {88FC4B29-E357-468B-B847-F7BFA34CE71A}
// {57D666D2-1D81-490C-8D42-E6CBE08CEA09}
// {4C5C01D4-1EF8-4BCC-8D24-335BA2340C0A}
//  4.049 -
// {86BA3C26-1276-46D0-9CEE-16A79DB6695C}
// {038F9430-21B6-44F3-9659-5768029A4F74}
// {02B797F5-03E3-4222-834E-B4941FB656CD}
//  4.050 - *
// {6E6DD83C-EFF2-4CBF-BFCC-D6E277434E8C}
// {12998578-3B74-4D84-8156-11652FD8BE1E}
// {9457F334-B4CC-4282-965D-99D1A5B9DD13}
//  4.051 -
// {E4DC0D15-FB3C-4B28-9075-BCCD590244B1}
// {E16B4558-B644-40BB-9FD3-1631AC932B89}
// {28D5F4BB-BA71-4E1A-8C3B-09122B27B8A5}
//  4.052 -
// {B4E41DFD-4CD5-486B-AC5C-95488A6C3CD7}
// {2BB6472C-B608-406B-9E83-51E81009749E}
// {9617DCCB-0E4C-44FE-B47E-578802303D17}
//  4.053 -
// {3D1CC550-1469-444B-8EAE-7A8F0DAE1F62}
// {5AEF870E-1F9F-4FE6-B342-E4BD0536D149}
// {CE130BA0-B2E9-44D6-B326-13E2FCF1BBC9}
//  4.054 -
// {B5689574-7C55-4D51-81F3-EBE622921EFF}
// {426D8C46-772E-4350-8482-C026FE883CD4}
// {91AC394F-00BB-4984-8938-F8CCCDB66936}




