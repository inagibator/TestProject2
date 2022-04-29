unit N_CMCaptDev35F;

interface

{$IFNDEF VER150} //***** not Delphi 7

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0, N_CMCaptDev0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, xmldom,
  XMLIntf, msxml, msxmldom, XMLDoc, OleCtrls, SHDocVw, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL;

type TN_CMCaptDev35Form = class( TN_BaseForm )
    tbRotateImage: TToolBar;
    tbLeft90:  TToolButton;
    tbRight90: TToolButton;
    tb180:     TToolButton;
    tbFlipHor: TToolButton;
    TimerSidexis: TTimer;
    TimerImage:   TTimer;
    bnStop:       TButton;
    TimerStatus:  TTimer;
    bnCapture: TButton;
    TimerCase: TTimer;
    Timer1: TTimer;
    bnClose: TButton;
    PnSlides: TPanel;
    ThumbsRFrame: TN_Rast1Frame;
    StatusBar1: TStatusBar;
    Label1: TLabel;
    TimerClose: TTimer;

    //******************  TN_CMCaptDev35Form class handlers  ******************

    procedure FormShow         ( Sender: TObject );
    procedure FormClose        ( Sender: TObject; var Action: TCloseAction );
                                                                       override;
    procedure FormKeyDown      ( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
    procedure FormKeyUp        ( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
    procedure SlidePanelResize ( Sender: TObject );
    procedure tbLeft90Click    ( Sender: TObject );
    procedure tbRight90Click   ( Sender: TObject );
    procedure tb180Click       ( Sender: TObject );
    procedure tbFlipHorClick   ( Sender: TObject );
    procedure FormCloseQuery   ( Sender: TObject; var CanClose: Boolean );
    procedure bnSetupClick     ( Sender: TObject );
    procedure FormCreate       ( Sender: TObject );
    procedure FormPaint        ( Sender: TObject );
    procedure TimerImageTimer  ( Sender: TObject );
    procedure bnStopClick      ( Sender: TObject );
    procedure TimerStatusTimer ( Sender: TObject );
    procedure bnCaptureClick   ( Sender: TObject );
    procedure Timer1Timer(Sender: TObject);
    procedure bnCloseClick(Sender: TObject);
    procedure TimerCloseTimer(Sender: TObject);
    procedure TimerOpenTimer(Sender: TObject);

  public
    CMOFThumbsDGrid:  TN_DGridArbMatr;   // DGrid for handling Thumbnails in ThumbsRFrame
    CMOFDrawSlideObj: TN_CMDrawSlideObj; // Object with Attributes for Drawing Thumbnails (jn CMOFDrawThumb)
    CMOFPNewSlides:   TN_PUDCMSArray;    // Pointer to Array of New captured Slides
    CMOFAnsiFName:    AnsiString;        // Image (created by driver) Full File Name
    CMOFPProfile:     TK_PCMOtherProfile;// Pointer to Device Profile
    CMOFDeviceIndex:  Integer;           // Device Index in ECDevices Array
    CMOFNumCaptured:  Integer;           // Number of Captured Slides
    CMOFNumTEvents:   Integer;           // Number of Timer Events passed
    CMOFIsGrabbing:   Boolean;           // True if inside (init_grabbing - finish_grabbing)

    CMOFSavedFiles: TStringList;

    CMOFCloseThreshold: Integer;
    CMOFDriverOpened: Boolean;
    //CMOFDriverStatus: Integer;

    CMOFThisForm: TN_CMCaptDev35Form;    // Pointer to this form

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide ( Image: string ): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMCaptDev35Form = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

var
  PelsPerInch: integer; // pixels per inch received from a driver

implementation

uses
  Math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev35,
  TlHelp32, K_CM1, K_CML1F, N_CMResF, ShellAPI, IniFiles,
  ComObj, MSHTML, ActiveX, K_CLib, K_RImage
;
{$R *.dfm}


function processExists(exeFileName: string): Boolean;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  Result := False;
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
    begin
      Result := True;
    end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;


//**************************************************************** KillTask ***
// Closes an app by exe name
//
//     Parameters
// ExeFileName - exe name
// Result      - if success
//
function KillTask( ExeFileName: string ): integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );
  FProcessEntry32.dwSize := Sizeof( FProcessEntry32 );
  ContinueLoop := Process32First( FSnapshotHandle, FProcessEntry32 );
  while integer( ContinueLoop ) <> 0 do
  begin
  if (StrIComp(PChar(ExtractFileName(FProcessEntry32.szExeFile)),
                PChar(ExeFileName)) = 0) or (StrIComp(FProcessEntry32.szExeFile,
                                                  PChar(ExeFileName)) = 0)  then
    Result := Integer( TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0),
                                           FProcessEntry32.th32ProcessID), 0) );
    ContinueLoop := Process32Next( FSnapshotHandle, FProcessEntry32 );
  end;
  CloseHandle( FSnapshotHandle );
end; // function KillTask( ExeFileName: string )

//**********************  TN_CMCaptDev35Form class handlers  ******************

//********************************************* TN_CMCaptDev35Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev35Form.FormShow( Sender: TObject );
var
  DCMColsNum, ASCount: Integer;
begin
  N_Dump1Str( 'Kodak Start FormShow' );

  // ***** making a form invisible
    Self.AlphaBlend      := True;
    Self.AlphaBlendValue := 0;

  Caption := CMOFPProfile^.CMDPCaption + ' X-Ray Capture';
  tbRotateImage.Images := N_CM_MainForm.CMMCurBigIcons;
  CMOFDrawSlideObj := TN_CMDrawSlideObj.Create(); // used in jn CMOFDrawThumb for Drawing Thumbnails
  CMOFThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, CMOFGetThumbSize );

  with CMOFThumbsDGrid do
  begin
    DGEdges := Rect( 2, 2, 2, 2 );
    DGGaps  := Point( 2, 2 );
    DGScrollMargins := Rect( 8, 8, 8, 8 );

    DGLFixNumCols   := 3;
    DGLFixNumRows   := 0;
    DGSkipSelecting := True;
    DGChangeRCbyAK  := True;
    //DGCtrlDownMode  := True; // Mark as if Ctrl key is Down (leave previous marking unchanged)
    DGMarkByBorder  := True; // Mark by Drawing Border and filling by DGFillColor

    DGBackColor     := ColorToRGB( clBtnFace );

    DGMarkBordColor := $800000;
    DGNormBordColor := $808080;
    DGMarkNormWidth := 0;

    DGNormBordColor := DGBackColor;
    DGMarkFillColor := DGBackColor; // Rect Border interior Fill Color for Marked Items (used only if DGMarkByBorder=True)
    DGNormFillColor := DGBackColor; // Rect Border interior Fill Color for Unmarked Items (used only if DGMarkByBorder=True)

    //DGLAddDySize    := 0; // see DGLItemsAspect
    //DGLItemsAspect  := 0.75;
    DGLAddDySize    := 14; // see DGLItemsAspect

    DGDrawItemProcObj := CMOFDrawThumb;

   // DGInitRFrame();

    ThumbsRFrame.DstBackColor := DGBackColor;
    CMOFThumbsDGrid.DGInitRFrame();
    CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  end; // with CMMFThumbsDGrid do

  //with SlideRFrame do
  //begin
  //  RFDebName := 'SlideRFrame';
  //  RFCenterInDst := True;
  //  RFrShowComp( Nil );
  //end; // with SlideRFrame do
  //tbRotateImage.Visible := True;

  CMOFSavedFiles := TStringList.Create;

  with N_CMCDServObj35 do
  begin

 // PDevProfile := CMOFPProfile;
 // SetLength( PSlidesArrayForTimer, 0 ); // Initialize ASlidesArray

  PathXML := N_CMV_GetWrkDir() + 'Dev_Kodak.xml';

  PathDriver := N_CMV_GetRegistryKey( HKEY_LOCAL_MACHINE,
                                'SOFTWARE\CSH\Stella',
                                'Path' ) +
                                'bin\Stella.exe';

  if PathDriver = 'bin\Stella.exe' then // WOW64
    PathDriver := N_CMV_GetRegistryKey( HKEY_LOCAL_MACHINE,
                                'SOFTWARE\WOW6432Node\CSH\Stella',
                                'Path' ) +
                                'Bin\Stella.exe';

  PathImages := N_CMV_GetRegistryKey( HKEY_LOCAL_MACHINE,
                                'SOFTWARE\CSH\Stella',
                                'ImagesPath' );

  if PathImages = '' then
    PathImages := N_CMV_GetRegistryKey( HKEY_LOCAL_MACHINE,
                                'SOFTWARE\WOW6432Node\CSH\Stella',
                                'ImagesPath' );

  PathImages := K_ExpandFileName( '(#TmpFiles#)' );
  CreateXML(); // Create XML file with settings for Kodak

  N_Dump1Str( 'Kodak Driver Path >> ' + PathDriver );
  N_Dump1Str( 'Kodak Driver Parameter >> ' + PathXML );
  N_Dump1Str( 'Kodak Images Path >> ' + PathImages );

 if not FileExists( PathXML ) then // if XML file not exists
  begin
   // K_CMSlidesSaveScanned3( PDevProfile, PSlidesArrayForTimer );
    N_CMV_ShowCriticalError( 'Kodak', 'XML file not exists: "' + PathXML + '"' );
    Exit;
  end; // if not FileExists( PathXML ) then // if XML file not exists

  //while processExists(N_CMCDServObj35.PathDriver) do//N_CMV_ProcessExists(N_CMCDServObj35.PathDriver) do
   // KillTask(N_CMCDServObj35.PathDriver);

  if processExists(ExtractFileName(N_CMCDServObj35.PathDriver)) then
  begin
    K_CMShowMessageDlg( 'Another instance of the driver is already open', mtError );
  end;

 if not N_CMV_CreateProcess( '"' + PathDriver + '" "' + PathXML + '"' ) then
  begin
   // K_CMSlidesSaveScanned3( PDevProfile, PSlidesArrayForTimer );
    N_CMV_ShowCriticalError( 'Kodak', 'can not start process "' + PathDriver + '"' );
    Exit;
  end; // if not N_CMV_CreateProcess( '"' + PathDriver + '" "' + PathXML + '"' ) then

 // if not N_CMV_ProcessExists( N_CMCDServObj35.PathDriver ) then
  while not processExists(ExtractFileName(N_CMCDServObj35.PathDriver)) do
  begin
    Sleep(200);
  end;

  CMOFDriverOpened := True;

  end;

 // N_Dump1Str( 'Before delete files from ' + N_CMCDServObj35.PathImages + '\' );
  //RemoveDirectory(@N_StringToWide(N_CMCDServObj35.PathImages + '\')[1]);
  //CreateDir(N_CMCDServObj35.PathImages + '\');

  CMOFCloseThreshold := 5;

  Timer1.Enabled := True;

  N_Dump1Str( 'Trios End FormShow' );
end; // procedure TN_CMCaptDev35Form.FormShow

//******************************************** TN_CMCaptDev35Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev35Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin

  N_Dump1Str('OnClose started');
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  CMOFSavedFiles.Free;

  CMOFDriverOpened := False;
  N_CMCDServObj35.PathDriver := '';
  //RemoveDirectory(@N_StringToWide(N_CMCDServObj35.PathImages + '\')[1]);
  //CreateDir(N_CMCDServObj35.PathImages + '\');

  N_Dump2Str( 'CMOther35Form.FormClose' );
  Inherited;
end; // procedure TN_CMCaptDev35Form.FormClose

//*************************************** TN_CMCaptDev35Form.FormCloseQuery ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// CanClose
//
// OnClose Self handler
//
procedure TN_CMCaptDev35Form.FormCloseQuery(Sender: TObject;
                                                         var CanClose: Boolean);
begin
  inherited;
end; // TN_CMCaptDev35Form.FormCloseQuery

procedure TN_CMCaptDev35Form.FormCreate(Sender: TObject);
begin
  inherited;
end;

//****************************************** TN_CMCaptDev35Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev35Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev35Form.FormKeyDown

//******************************************** TN_CMCaptDev35Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev35Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev35Form.FormKeyUp

procedure TN_CMCaptDev35Form.FormPaint(Sender: TObject);
begin
  inherited;
end;

//************************************* TN_CMCaptDev35Form.SlidePanelResize ***
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev35Form.SlidePanelResize( Sender: TObject );
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  //SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev35Form.SlidePanelResize

//**************************************** TN_CMCaptDev35Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev35Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  //SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev35Form.tbLeft90Click

//*************************************** TN_CMCaptDev35Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev35Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  //SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev35Form.UpDown1Click

//************************************** TN_CMCaptDev35Form.TimerImageTimer ***
// Is CMS 3D enabled check, not using anymore
//
//     Parameters
// Sender - Event Sender
//
//procedure TN_CMCaptDev35Form.Timer3DEnabledTimer( Sender: TObject );
//begin
// inherited;
// if not (N_CMResForm.aMediaImport3D.Visible) then
//  begin
//    Timer3DEnabled.Enabled := False;
//    K_CMShowMessageDlg( '3d import is unaccessible',
//                                              mtInformation, [], FALSE, '', 5 );
    //Close();
//  end;
//end; // procedure TN_CMCaptDev35Form.Timer3DEnabledTimer

//*************************************** TN_CMCaptDev35Form.TimerCaseTimer ***
// Waiting for a case
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev35Form.Timer1Timer(Sender: TObject);
var
  i, j: Integer;
  CapturedDIB, NDIB: TN_DIBObj;
  //NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
  Filename: string;
//********************************************************** FindNewestFile ***
// Search for a newest file in a folder, as .bmp
//
//     Parameters
// Folder - folder name
//
{$WARN SYMBOL_PLATFORM OFF}
function FindNewestFile( Folder: string ): string;
var
  sr: TSearchRec;
  fn: string;
  st: TSystemTime;
  dt,ft: TDateTime;
begin
  fn := '';
  dt := 0;
  try
    if FindFirst( Folder + '*.jpg', faAnyFile, sr ) = 0 then
    begin
    repeat
      if sr.Attr = faDirectory then Continue;
      FileTimeToSystemTime( sr.FindData.ftCreationTime, st );
      ft := SystemTimeToDateTime( st );
      if ft > dt then
      begin
        dt := ft;
        fn := sr.Name;
      end;
    until ( FindNext(sr) <> 0 );
    end
    else
      if FindFirst( Folder + '*.jpeg', faAnyFile, sr ) = 0 then
      begin
      repeat
        if sr.Attr = faDirectory then Continue;
        FileTimeToSystemTime( sr.FindData.ftCreationTime, st );
        ft := SystemTimeToDateTime( st );
        if ft > dt then
        begin
          dt := ft;
          fn := sr.Name;
        end;
      until ( FindNext(sr) <> 0 );
      end;

  finally
    FindClose( sr );
  end;
  if fn = '' then Result := ''
  else Result := fn;
end;
begin
  Timer1.Enabled := False;
  inherited;

  N_Dump1Str('Timer started');

  if CMOFDriverOpened then
  if N_CMCDServObj35.PathDriver <> '' then
  if N_CMCDServObj35.PathDriver <> 'bin\Stella.exe' then
  if N_CMCDServObj35.PathDriver <> 'Bin\Stella.exe' then
  if not processExists(ExtractFileName(N_CMCDServObj35.PathDriver)) then//N_CMV_ProcessExists( N_CMCDServObj35.PathDriver ) then
  begin
 { K_ScanFilesTree        ( N_CMCDServObj35.PathImages + '\',
                             N_CMCDServObj35.CreateSlideFromFile,
                             '*.jpg' );

  K_ScanFilesTree        ( N_CMCDServObj35.PathImages + '\',
                             N_CMCDServObj35.CreateSlideFromFile,
                             '*.jpeg' );

  K_DeleteFolderFiles    ( N_CMCDServObj35.PathImages + '\' );
  //K_CMSlidesSaveScanned3 ( CMOFPDevProfile, N_CMCDServObj35.PSlidesArrayForTimer );
                                                  }
  // ***** making a form visible
    Self.AlphaBlend      := False;
    Self.AlphaBlendValue := 255;
    TimerClose.Enabled := True;

  Filename := FindNewestFile(N_CMCDServObj35.PathImages + '\');
  if ( Filename <> '' ) and ( CMOFSavedFiles.IndexOf(Filename) = -1 )then
  begin
    N_Dump1Str('File found = '+N_CMCDServObj35.PathImages + Filename);

    if FileExists(N_CMCDServObj35.PathImages + Filename) then
    begin
      CMOFCaptureSlide( N_CMCDServObj35.PathImages + Filename );
      N_Dump1Str('Slide saved');

      DeleteFile(N_CMCDServObj35.PathImages + Filename);
    end;

    CMOFSavedFiles.Add( FileName );
    //DeleteFile(N_CMCDServObj35.PathImages + '\' + Filename);
  end;

  N_Dump1Str('After importing slides');

  end;

  Timer1.Enabled := True;
end; // procedure TN_CMCaptDev35Form.TimerCaseTimer

//************************************** TN_CMCaptDev35Form.TimerCloseTimer ***
// Waiting for a close
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev35Form.TimerCloseTimer(Sender: TObject);
begin
  inherited;

  StatusBar1.Panels[0].text := 'This window will be closed automatically in '+ IntToStr(CMOFCloseThreshold)+'...';
  Dec(CMOFCloseThreshold);

  if CMOFCloseThreshold = 0 then
    Close();
end; // procedure TN_CMCaptDev35Form.TimerCloseTimer

//************************************** TN_CMCaptDev35Form.TimerImageTimer ***
// Waiting for an image
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev35Form.TimerImageTimer( Sender: TObject );
begin
  inherited;
  TimerImage.Enabled := False;

  // not used yet

  TimerImage.Enabled := True;
end; procedure TN_CMCaptDev35Form.TimerOpenTimer(Sender: TObject);
begin
  inherited;


end;

// procedure TN_CMCaptDev35Form.TimerImageTimer(Sender: TObject);

//******************************************* TN_CMCaptDev35Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev35Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  //SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev35Form.tb180Click

//*************************************** TN_CMCaptDev35Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev35Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  //SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev35Form.tbFlipHorClick


//**********************  TN_CMCaptDev35Form class public methods  ************

//**************************************** TN_CMCaptDev35Form.CMOFDrawThumb ***
// Draw one Thumbnail (used as TN_DGridBase.DGDrawItemProcObj)
//
//     Parameters
// ADGObj  - DGrid Objects that handles Thumbnails DGrid
// AInd    - given Thumbnail one dimensional Index
// ARect   - Item Rectangle in DGRFrame Buf Pixel coords ( (0,0) means upper
//   left Buf pixel and may be not equal to upper left Grid pixel )
//
// Is used as value of CMOFThumbsDGrid.DGDrawItemProcObj field
//
procedure TN_CMCaptDev35Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
var
  WStr : string;
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb1( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev35Form.CMOFDrawThumb

//************************************* TN_CMCaptDev35Form.CMOFGetThumbSize ***
// Get Thumbnail Size (used as TN_DGridBase.DGGetItemSizeProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - given Thumbnail Index
// AInpSize  - given Size on input, only one fileld (X or Y) should be <> 0
// AOutSize  - resulting Size on output, if AInpSize.X <> 0 then OutSize.Y <> 0,
//                                       if AInpSize.Y <> 0 then OutSize.X <> 0
// AMinSize  - (on output) Minimal Size
// APrefSize - (on output) Preferable Size
// AMaxSize  - (on output) Maximal Size
//
//  Is used as value of CMOFThumbsDGrid.DGGetItemSizeProcObj field
//
procedure TN_CMCaptDev35Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
                                  AInd: Integer; AInpSize: TPoint; out AOutSize,
                                        AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide: TN_UDCMSlide;
  ThumbDIB: TN_UDDIB;
  ThumbSize: TPoint;
begin
  with N_CM_GlobObj, ADGObj do
  begin
    Slide     := CMOFPNewSlides^[AInd];
    ThumbDIB  := Slide.GetThumbnail();
    ThumbSize := ThumbDIB.DIBObj.DIBSize;
    AOutSize  := Point( 0,0 );
    if AInpSize.X > 0 then // given is AInpSize.X
      AOutSize.Y := Round( AInpSize.X * ThumbSize.Y / ThumbSize.X )
                                                                  + DGLAddDySize
    else // AInpSize.X = 0, given is AInpSize.Y
      AOutSize.X := Round( ( AInpSize.Y - DGLAddDySize ) *
                                                    ThumbSize.X / ThumbSize.Y );
    AMinSize  := Point( 10, 10 );
    APrefSize := ThumbSize;
    AMaxSize  := Point( 1000, 1000 );
  end; // with N_CM_GlobObj. ADGObj do
end; // procedure TN_CMCaptDev35Form.CMOFGetThumbSize

//*************************************** TN_CMCaptDev35Form.bnCaptureClick ***
// Capture
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev35Form.bnCaptureClick(Sender: TObject);
begin
end; // procedure TN_CMCaptDev35Form.bnCaptureClick

//***************************************** TN_CMCaptDev35Form.bnSetupClick ***
// Capture
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev35Form.bnCloseClick(Sender: TObject);
begin
  inherited;
  Close();
end;

procedure TN_CMCaptDev35Form.bnSetupClick( Sender: TObject );
begin
end; // procedure TN_CMCaptDev35Form.bnSetupClick

//****************************************** TN_CMCaptDev35Form.bnStopClick ***
// Capture Stop
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev35Form.bnStopClick( Sender: TObject );
begin
  inherited;
end; // procedure TN_CMCaptDev35Form.bnStopClick

//************************************* TN_CMCaptDev35Form.TimerStatusTimer ***
// Changing status
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev35Form.TimerStatusTimer( Sender: TObject );
begin
  inherited;

end;// procedure TN_CMCaptDev35Form.TimerStatusTimer

//************************************* TN_CMCaptDev35Form.CMOFCaptureSlide ***
// Importing Image
//
//     Parameters
// Image  - Filename
// Result - 0 if correct
//
function TN_CMCaptDev35Form.CMOFCaptureSlide( Image: string ): Integer;
var
  i: Integer;
  CapturedDIB, NDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
  ResolutionInt: Integer;   // Resolution in pixel per meter
  CurrentResolution: string;
begin
  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format('Kodak Start CMOFCaptureSlide %d', [CMOFNumCaptured]));

  CapturedDIB := Nil;
  N_LoadDIBFromFileByImLib( CapturedDIB, Image ); // new 8 or 16 bit variant

  //CapturedDIB.SaveToBMPFormat('c:\image.bmp');

  //NDIB := TN_DIBObj.Create( CapturedDIB, 0, pfCustom, -1, epfGray8 );
  //CapturedDIB.CalcGrayDIB( NDIB );
  //CapturedDIB.Free;
  //CapturedDIB := NDIB;

  // autocontrast
  //NDIB := Nil;
  //CapturedDIB.CalcMaxContrastDIB( NDIB );
  //CapturedDIB.Free();
  //CapturedDIB := NDIB;

  CurrentResolution := '19';
  ResolutionInt :=
  Round( 1000000 / StrToFloatDef( K_ReplaceCommaByPoint( CurrentResolution ), -1 ) );

  if ( 0 >= ResolutionInt ) then  // if resolution is not valid
    ResolutionInt := 0;           // set default resolution

  // set DIBObj resolution
  CapturedDIB.DIBInfo.bmi.biXPelsPerMeter := ResolutionInt;
  CapturedDIB.DIBInfo.bmi.biYPelsPerMeter := ResolutionInt;

  // ***** Here: CapturedDIB is OK
  NewSlide := K_CMSlideCreateFromDIBObj( CapturedDIB,
                                          @(CMOFPProfile^.CMAutoImgProcAttrs) );
  NewSlide.SetAutoCalibrated();
  NewSlide.ObjAliase := IntToStr(CMOFNumCaptured);

  with NewSlide.P()^ do
  begin
    CMSSourceDescr := CMOFPProfile^.CMDPCaption;
    NewSlide.ObjInfo := 'Captured from ' + CMSSourceDescr;
    CMSMediaType := CMOFPProfile^.CMDPMTypeID;
    NewSlide.SetInitDCMAttrs( TK_PCMDCMAttrs(@CMOFPProfile^.CMDPDModality) );
  end; // with NewSlide.P()^ do

  // Add NewSlide to list of all Slides of current Patient
  K_CMEDAccess.EDAAddSlide( NewSlide ); // from now on NewSlide is owned by K_CMEDAccess

  // Add NewSlide to beg of CMOFPNewSlides^ array
  SetLength( CMOFPNewSlides^, CMOFNumCaptured );

  for i := High(CMOFPNewSlides^) downto 1 do // Shift all elems by 1
    CMOFPNewSlides^[i] := CMOFPNewSlides^[i - 1];

  CMOFPNewSlides^[0] := NewSlide;

  // Add NewSlide to CMOFThumbsDGrid
  Inc(CMOFThumbsDGrid.DGNumItems);
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  //RootComp := NewSlide.GetMapRoot();
  //SlideRFrame.RFrShowComp(RootComp);

  N_Dump1Str(Format('Kodak Fin CMOFCaptureSlide %d', [CMOFNumCaptured]));
  Result := 0;
end; // end of TN_CMCaptDev35Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev35Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev35Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev35Form.CurStateToMemIni

//************************************* TN_CMCaptDev35Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev35Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev35Form.MemIniToCurState

{$ELSE} //************** no code in Delphi 7
implementation
{$ENDIF VER150} //****** no code in Delphi 7

end.


