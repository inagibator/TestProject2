unit N_CMCaptDev29F;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0, N_CMCaptDev0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type TN_CMCaptDev29Form = class( TN_BaseForm )
    MainPanel:  TPanel;
    RightPanel: TPanel;
    SlidePanel: TPanel;
    bnExit:     TButton;
    ThumbsRFrame: TN_Rast1Frame;
    StatusShape: TShape;
    StatusLabel: TLabel;
    SlideRFrame: TN_Rast1Frame;
    tbRotateImage: TToolBar;
    tbLeft90:  TToolButton;
    tbRight90: TToolButton;
    tb180:     TToolButton;
    tbFlipHor: TToolButton;
    bnSetup:   TButton;
    bnCapture: TButton;
    TimerImage: TTimer;
    bnStop:    TButton;
    ProgressBar1: TProgressBar;
    Timer3DEnabled: TTimer;
    TimerStatus:    TTimer;

    //******************  TN_CMCaptDev25Form class handlers  ******************

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
    procedure UpDown1Click     ( Sender: TObject; Button: TUDBtnType );
    procedure TimerImageTimer  ( Sender: TObject );
    procedure FormCloseQuery   ( Sender: TObject; var CanClose: Boolean );
    procedure bnSetupClick     ( Sender: TObject );
    procedure FormCreate       ( Sender: TObject );
    procedure FormPaint        ( Sender: TObject );
    procedure bnCaptureClick   ( Sender: TObject );
    procedure bnStopClick      ( Sender: TObject );
    procedure bnOpenClick      ( Sender: TObject );
    procedure Timer3DEnabledTimer( Sender: TObject );
    procedure TimerStatusTimer ( Sender: TObject );
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

    CMOFMailslotPath, CMOFPDataPath, CMOFTempNewestPath: string;
    CMOFOpened, CMOFExeOpened: Boolean;
    CMOFOrderNumber, CMOFStatus, CMOFStatusPrev, CMOFNumberPar: Integer;

    ThisForm: TN_CMCaptDev29Form;        // Pointer to this form

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide ( Image: string )  : Integer;
    function  CMOFCaptureSlide2D ( Image: string ): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;

end; // type TN_CMCaptDev25Form = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

var
  PelsPerInch: integer; // pixels per inch received from a driver

implementation

uses
  Math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev29,
  N_CMCaptDev29aF, TlHelp32, K_CM1, K_CML1F, N_CMResF, ShellAPI, IniFiles,
  Registry, K_CLib, K_RImage;
{$R *.dfm}

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
    if FindFirst( Folder + '*.bmp', faAnyFile, sr ) = 0 then
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
  finally
    FindClose( sr );
  end;
  if fn = '' then Result := ''
  else Result := fn;
end;
{$WARN SYMBOL_PLATFORM ON}

//************************************************************ DeleteFolder ***
// Deletes folder
//
//     Parameters
// FolderName - folder name
//
// Folder need not be empty. Returns true unless error or user abort
//
function DeleteFolder( FolderName: string ): boolean;
var
  r: TshFileOpStruct;
  i: integer;
begin
  FolderName := FolderName + #0#0;
  Result := false;
  i := GetFileAttributes(PChar(folderName));
  if (i = -1) or (i and FILE_ATTRIBUTE_DIRECTORY <> FILE_ATTRIBUTE_DIRECTORY)
                                                                      then EXIT;

  FillChar( r, sizeof(r), 0 );
  r.wFunc  := FO_DELETE;
  r.pFrom  := pChar(folderName);
  r.fFlags := FOF_SILENT or FOF_NOCONFIRMATION or FOF_ALLOWUNDO;

  Result := (ShFileOperation(r) = 0) and not r.fAnyOperationsAborted;
end;

//**********************  TN_CMCaptDev29Form class handlers  ******************

//********************************************* TN_CMCaptDev29Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev29Form.FormShow( Sender: TObject );
var
  WrkFilesFolder: string;
function ExistClassID(const ClassID :string): Boolean;
var
  Reg: TRegistry;
begin
 try
     Reg := TRegistry.Create;
   try
     Reg.RootKey := HKEY_CLASSES_ROOT;
     Result      := Reg.KeyExists(Format('CLSID\%s',[ClassID]));
   finally
     Reg.Free;
   end;
 except
    Result := False;
 end;
end;
begin
  N_Dump1Str( 'Morita CBCT Start FormShow' );

  Caption := CMOFPProfile^.CMDPCaption + ' X-Ray Capture';
  tbRotateImage.Images := N_CM_MainForm.CMMCurBigIcons;
  CMOFDrawSlideObj := TN_CMDrawSlideObj.Create(); // used in jn CMOFDrawThumb for Drawing Thumbnails
  CMOFThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, CMOFGetThumbSize );

  CMOFStatus := 1; // beginning status

  with CMOFThumbsDGrid do
  begin
    DGEdges := Rect( 2, 2, 2, 2 );
    DGGaps  := Point( 2, 2 );
    DGScrollMargins := Rect( 8, 8, 8, 8 );

    DGLFixNumCols   := 1;
    DGLFixNumRows   := 0;
    DGSkipSelecting := True;
    DGChangeRCbyAK  := True;
    DGCtrlDownMode  := True; // Mark as if Ctrl key is Down (leave previous marking unchanged)
    DGMarkByBorder  := True; // Mark by Drawing Border and filling by DGFillColor

    DGBackColor     := ColorToRGB( clBtnFace );

    DGMarkBordColor := $800000;
    DGNormBordColor := $808080;
    DGMarkNormWidth := 0;

    DGNormBordColor := DGBackColor;
    DGMarkFillColor := DGBackColor; // Rect Border interior Fill Color for Marked Items (used only if DGMarkByBorder=True)
    DGNormFillColor := DGBackColor; // Rect Border interior Fill Color for Unmarked Items (used only if DGMarkByBorder=True)
    DGLAddDySize    := 0; // see DGLItemsAspect
    DGLItemsAspect  := 0.75;
    DGDrawItemProcObj := CMOFDrawThumb;
    ThumbsRFrame.DstBackColor := DGBackColor;
    CMOFThumbsDGrid.DGInitRFrame();
    CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  end; // with CMMFThumbsDGrid do

  with SlideRFrame do
  begin
    RFDebName := 'SlideRFrame';
    RFCenterInDst := True;
    RFrShowComp( Nil );
  end; // with SlideRFrame do
  tbRotateImage.Visible := True;

  //if not FileExists( 'C:\Program Files (x86)\3dx\exe\3dx.exe' ) then
  //begin
  //  K_CMShowMessageDlg( 'i-Dixel is not installed properly', mtError );
  //  N_Dump1Str( 'i-Dixel is not installed properly' );
  //  CMOFExeOpened := False;
  //  Exit;
  //end;

  if not ExistClassID( '{4E0228AE-3E5D-11D1-B0B2-006052024E07}' ) then
  begin
    K_CMShowMessageDlg( 'DixelD.ocx is not registered properly', mtError );
    N_Dump1Str( 'DixelD.ocx is not registered properly' );
    CMOFExeOpened := False;
  end
  else
  begin
    N_Dump1Str( 'DixelD.ocx CLSID is found' );
    CMOFExeOpened := True;

    N_CMCDServObj29.StartDriver( ThisForm.Handle, '0', '0' ); // open i-dixel
  end;

  WrkFilesFolder := K_ExpandFileName( '(#WrkFiles#)' );
  CMOFTempNewestPath := FindNewestFile( WrkFilesFolder + '\Morita' );

  TimerImage.Enabled := True;

  N_Dump1Str( 'Morita CBCT End FormShow' );
end; // procedure TN_CMCaptDev29Form.FormShow

//******************************************** TN_CMCaptDev29Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev29Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  WinExec( 'taskkill /IM MoritaCBCT.exe', SW_HIDE );

  //if CMOFExeOpened then
  //  N_CMCDServObj29.StartDriver(0, '2', ''); // close i-dixel
  N_Dump1Str( 'Form close end' );

  N_Dump2Str( 'CMOther29Form.FormClose' );
  Inherited;
end;

//*************************************** TN_CMCaptDev29Form.FormCloseQuery ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// CanClose
//
// OnClose Self handler
//
procedure TN_CMCaptDev29Form.FormCloseQuery( Sender: TObject;
                                                        var CanClose: Boolean );
begin
  inherited;
end; // TN_CMCaptDev29Form.FormCloseQuery

procedure TN_CMCaptDev29Form.FormCreate(Sender: TObject);
begin
  inherited;
end;

//****************************************** TN_CMCaptDev29Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev29Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev29Form.FormKeyDown

//******************************************** TN_CMCaptDev29Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev29Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev29Form.FormKeyUp

procedure TN_CMCaptDev29Form.FormPaint(Sender: TObject);
begin
  inherited;
end;

//************************************* TN_CMCaptDev29Form.SlidePanelResize ***
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev29Form.SlidePanelResize( Sender: TObject );
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev29Form.SlidePanelResize

//**************************************** TN_CMCaptDev29Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev29Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev29Form.tbLeft90Click

//*************************************** TN_CMCaptDev29Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev29Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev29Form.tbRight90Click

// procedure TN_CMCaptDev29Form.UpDown1Click
procedure TN_CMCaptDev29Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev29Form.UpDown1Click

//******************************************* TN_CMCaptDev29Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev29Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev29Form.tb180Click

//*************************************** TN_CMCaptDev29Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev29Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev29Form.tbFlipHorClick


//**********************  TN_CMCaptDev29Form class public methods  ************

//**************************************** TN_CMCaptDev29Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev29Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev29Form.CMOFDrawThumb

//************************************* TN_CMCaptDev29Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev29Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
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
end; // procedure TN_CMCaptDev29Form.CMOFGetThumbSize

//****************************************** TN_CMCaptDev29Form.bnOpenClick ***
// Open Sidexis
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev29Form.bnOpenClick( Sender: TObject );
begin
  inherited;
end; // procedure TN_CMCaptDev29Form.bnOpenClick

//***************************************** TN_CMCaptDev29Form.bnSetupClick ***
// Setup
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev29Form.bnSetupClick(Sender: TObject);
var
  Form: TN_CMCaptDev29aForm;
begin
  //PProfile := APDevProfile;
  N_Dump1Str( 'Morita CBCT >> CDSSettingsDlg begin' );
  Form := TN_CMCaptDev29aForm.Create( application );

  // create a setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  //Form.CMOFPDevProfile := APDevProfile; // link form variable to profile

  Form.CMOFPDevProfile := N_CMCDServObj29.PProfile;

  Form.ShowModal(); // Show a setup form

  N_Dump1Str( 'Morita CBCT >> CDSSettingsDlg end' );
end; // procedure TN_CMCaptDev29Form.bnSetupClick

//****************************************** TN_CMCaptDev29Form.bnStopClick ***
// Stop waiting for Sidexis
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev29Form.bnStopClick( Sender: TObject );
begin
  inherited;

  CMOFStatus := 1;

  bnCapture.Visible     := True;
  bnStop.Visible        := False;
  ProgressBar1.Position := 0;
  TimerImage.Enabled    := False;
  CMOfOpened            := False;
end; // procedure TN_CMCaptDev29Form.bnStopClick

//*************************************** TN_CMCaptDev29Form.bnCaptureClick ***
// Capture start
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev29Form.bnCaptureClick(Sender: TObject);
function ProcessExists( ExeFileName: string ): Boolean;
var
  ContinueLoop:    BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );
  FProcessEntry32.dwSize := SizeOf( FProcessEntry32 );
  ContinueLoop := Process32First( FSnapshotHandle, FProcessEntry32 );
  Result := False;
  while Integer(ContinueLoop) <> 0 do
  begin
    if ( (UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
            UpperCase(ExeFileName) ) or ( UpperCase(FProcessEntry32.szExeFile) =
                                                  UpperCase(ExeFileName)) ) then
    begin
      Result := True;
    end;
    ContinueLoop := Process32Next( FSnapshotHandle, FProcessEntry32 );
  end;
  CloseHandle( FSnapshotHandle );
end;
begin
  inherited;
end;

//************************************* TN_CMCaptDev29Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Image - image path
// Return 0 if OK
//
function TN_CMCaptDev29Form.CMOFCaptureSlide( Image: string ): Integer;
var
  Slide3D:      TN_UDCMSlide;
  InfoFName:    string;
  CurSlidesNum, ResCode : Integer;
  AddViewsInfo: string;
begin
    Screen.Cursor := crHourglass;
    CMOFStatus := 6;

    Slide3D := K_CMSlideCreateForImg3DObject();
    Slide3D.CreateThumbnail(); // create TMP  thubmnail
    K_CMEDAccess.EDAAddSlide( Slide3D );

    with Slide3D, P()^ do
    begin
      N_CM_MainForm.CMMSetUIEnabled( FALSE );
      N_CM_MainForm.CMMCurFMainForm.Hide();

      ExcludeTrailingPathDelimiter( Image );

      CMOFStatus := 7;
      ResCode := K_CMImg3DCall( CMSDB.MediaFExt, Image );

      if K_CMD4WAppFinState then
      begin
        N_Dump1Str( '3D> !!! CMSuite is terminated' );
        Application.Terminate;
        Result := -1;
        Exit;
      end;

      N_CM_MainForm.CMMCurFMainFormSkipOnShow := TRUE;
      N_CM_MainForm.CMMCurFMainForm.Show();
      N_CM_MainForm.CMMSetUIEnabled( TRUE );

      if ResCode = 0 then
      begin
        // Rebuild Thumbnail
        CMOFStatus := 7;
        CreateThumbnail(); // create TMP  thubmnail

        CMOFStatus := 8;
        K_CMImg3DAttrsInit( P() );

        CMSSourceDescr := ExtractFileName(ExcludeTrailingPathDelimiter(Image));

        N_Dump1Str( 'After extracting filename = ' + CMSSourceDescr );

        CMOFStatus := 9;

        // Rebuild 3D slide ECache
        CMSlideECSFlags := [cmssfAttribsChanged];
        K_CMEDAccess.EDASaveSlideToECache( Slide3D );

        // Save 3D object
        K_CMEDAccess.EDASaveSlidesArray( @Slide3D, 1 );

        // Import and Save 2D views
        InfoFName := TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImg3DPath( Slide3D ) +
                                   K_CMSlideGetImg3DFolderName( Slide3D.ObjName );
        CurSlidesNum := N_CM_MainForm.CMMImg3DViewsImportAndShowProgress( Slide3D.ObjName, InfoFName );
        K_CMEDAccess.EDASetPatientSlidesUpdateFlag();

        N_CM_MainForm.CMMFRebuildVisSlides();
        N_CM_MainForm.CMMFDisableActions( nil );

        AddViewsInfo := K_CML1Form.LLLImg3D1.Caption; // ' 3D object is imported'
        if CurSlidesNum > 0 then
          AddViewsInfo := format( K_CML1Form.LLLImg3D2.Caption,
                                 //  '3D object and %s',
                           [format( K_CML1Form.LLLImg3D3.Caption,
          //                ' %d 3D views are imported'
                                 [CurSlidesNum] )] );
        N_CM_MainForm.CMMFShowStringByTimer( AddViewsInfo );
      end   // if ResCode = 0 then
      else
      begin // if ResCode <> 0 then
        // Remove New Slide
        with TK_CMEDDBAccess(K_CMEDAccess) do
        begin
          CurSlidesList.Delete(K_CMEDAccess.CurSlidesList.Count - 1);
          EDAClearSlideECache( Slide3D );
        end;

        Slide3D.UDDelete();
      end;
    end; // with Slide3D, P()^ do

    Screen.Cursor := crDefault;

  Result := 0;
end; // end of TN_CMCaptDev29Form.CMOFCaptureSlide

//*********************************** TN_CMCaptDev29Form.CMOFCaptureSlide2D ***
// Capture Slide from file and show it, for 2D images
//
//     Parameters
// Image - image path
// Return 0 if OK
//
function TN_CMCaptDev29Form.CMOFCaptureSlide2D( Image: string ): Integer;
var
  i: Integer;
  CapturedDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
begin
  Result := 0;
  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format('Morita CBCT Start CMOFCaptureSlide %d', [CMOFNumCaptured]));

  CapturedDIB := Nil;
  N_LoadDIBFromFileByImLib( CapturedDIB, Image ); // new 8 or 16 bit variant

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
  RootComp := NewSlide.GetMapRoot();
  SlideRFrame.RFrShowComp(RootComp);

  N_Dump1Str(Format('Morita CBCT Fin CMOFCaptureSlide %d', [CMOFNumCaptured]));
end;

//************************************* TN_CMCaptDev29Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev29Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev29Form.CurStateToMemIni

//************************************* TN_CMCaptDev29Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev29Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev29Form.MemIniToCurState

//********************************** TN_CMCaptDev29Form.Timer3DEnabledTimer ***
// Checks if 3d import is available, not used
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev29Form.Timer3DEnabledTimer( Sender: TObject );
begin
  inherited;
//  if not (N_CMResForm.aMediaImport3D.Visible) then
//  begin
//    Timer3DEnabled.Enabled := False;
//    K_CMShowMessageDlg( '3d import is unaccessible',
//                                              mtInformation, [], FALSE, '', 5 );
//    Close();
//  end;
end; // procedure TN_CMCaptDev29Form.Timer3DEnabledTimer

//************************************** TN_CMCaptDev29Form.TimerImageTimer ***
// Wait for 3d info file
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev29Form.TimerImageTimer( Sender: TObject );
var
  Txt: TextFile;
  s, WrkFilesFolder, AllText, UIDFile, ImportFile, FormatString: string;
  searchResult : TSearchRec;
  CapturedDIB:   TN_DIBObj;
  Ini:           TIniFile;
  Modality:      Integer;
begin
  inherited;
  TimerImage.Enabled := False;
  Modality := 0;

  try

    //***** if there's info file
    WrkFilesFolder := K_ExpandFileName( '(#WrkFiles#)' );
    //N_Dump1Str('Waiting for ' + WrkFilesFolder + 'Morita\imageinfo.txt, Mode = '
    //                                               + CMOFPProfile.CMDPStrPar1 );
    if FindFirst( WrkFilesFolder + 'Morita\*.ini', faAnyFile, searchResult ) = 0 then
    begin

    UIDFile := WrkFilesFolder +  'Morita\' + searchResult.Name;
    Ini:=TiniFile.Create(UIDFile);
    FormatString := Ini.ReadString( 'Image', 'ModalityName', '' );
    N_Dump1Str( 'Format found = ' + FormatString );

    if FormatString <> 'CT' then // 2d image through i-dixel
    begin
      Modality := 0; // other image, flag for future

      ImportFile := FindNewestFile( WrkFilesFolder + 'Morita\' );
      if CMOFTempNewestPath <> ImportFile then
      begin
        CMOFTempNewestPath := ImportFile;
        N_Dump1Str( 'Last found .bmp = ' + CMOFTempNewestPath );
        CMOFCaptureSlide2D( WrkFilesFolder + 'Morita\' + ImportFile );
        if FileExists( WrkFilesFolder + 'Morita\' + ImportFile ) then
          DeleteFile( WrkFilesFolder + 'Morita\' + ImportFile );

        // ***** find and delete .ini
        ImportFile := StringReplace( ImportFile, '.bmp', '.ini', [rfReplaceAll,
                                                                 rfIgnoreCase]);
        if FileExists( WrkFilesFolder + 'Morita\' + ImportFile ) then
          DeleteFile( WrkFilesFolder + 'Morita\' + ImportFile )
        else
        begin
          Sleep(500); // wait a little, 'till the .ini file is created
          if FileExists( WrkFilesFolder + 'Morita\' + ImportFile ) then
            DeleteFile( WrkFilesFolder + 'Morita\' + ImportFile );
        end;

        // ***** find and delete .txt
        ImportFile := StringReplace( ImportFile, '.ini', '.txt', [rfReplaceAll,
                                                                 rfIgnoreCase]);
        if FileExists( WrkFilesFolder + 'Morita\' + ImportFile ) then
          DeleteFile( WrkFilesFolder + 'Morita\' + ImportFile )
        else
        begin
          Sleep(500); // wait a little, 'till the .ini file is created
          if FileExists( WrkFilesFolder + 'Morita\' + ImportFile ) then
            DeleteFile( WrkFilesFolder + 'Morita\' + ImportFile );
        end;
      end;
    end // if FormatString = 'BMP' then

    else
    begin
      Modality := 1; // ct, flag for future
      if CMOFPProfile.CMDPStrPar1 = '1' then // only if i-dixel
      begin
        //Modality := 1; // ct, flag for future

        N_CMCaptDev29.N_UID := Ini.ReadString( 'Image', 'UID', '' );
        N_Dump1Str( 'UID = ' + N_CMCaptDev29.N_UID );

        if FindFirst( WrkFilesFolder + 'Morita\*.bmp', faAnyFile, searchResult ) = 0 then
        begin
          N_Dump1Str( 'Thumbnail = ' + searchResult.Name );
          N_CMCaptDev29.N_Thumbnail := WrkFilesFolder + 'Morita\' + searchResult.Name;

          CapturedDIB := Nil;
          N_LoadDIBFromFileByImLib( CapturedDIB, N_Thumbnail ); // new 8 or 16 bit variant

          K_CMDev3DCreateSlide( CMOFPProfile,
                         (N_CMCaptDev29.N_UID)+'/#/'+(CMOFPProfile.CMDPStrPar2),
                                                      CapturedDIB, 0, 0, 0, 8 );
          DeleteFile(N_CMCaptDev29.N_Thumbnail);
          if Length(CMOFPNewSlides^) > 0 then // Move before 2D
            with K_CMEDAccess.CurSlidesList do
              Move( Count - 1, Count - 1 - Length(CMOFPNewSlides^) );
        end;
      end;
    end;
    end;

    if CMOFPProfile.CMDPStrPar1 <> '1' then // cms 3d
    begin

      if Modality = 1 then // even thought setup is for cms 3d, the image is for native viewer
      begin
        if FindFirst( WrkFilesFolder + 'Morita\*.ini', faAnyFile, searchResult ) = 0 then
        begin

          // ***** making a form invisible
          Self.AlphaBlend      := True;
          Self.AlphaBlendValue := 0;

          UIDFile := WrkFilesFolder +  'Morita\' + searchResult.Name;
          DeleteFile(UIDFile);

          FindClose(searchResult);
          //Close();

        end; // if FormatString <> 'BMP' then
      end;

      if FileExists( WrkFilesFolder + 'Morita\imageinfo.txt' ) then
      begin

      // ***** making a form invisible
    Self.AlphaBlend      := True;
    Self.AlphaBlendValue := 0;

    CMOFStatus := 4;
    ProgressBar1.Position := ProgressBar1.Position + 18;

    //***** open info file
    AllText := '';
    AssignFile( Txt, WrkFilesFolder + 'Morita\imageinfo.txt' );
    Reset( Txt );
    while not Eof( Txt ) do
    begin
      Readln( Txt, s ); // get filepath
    end;

    ProgressBar1.Position := ProgressBar1.Position + 15;

    WinExec( 'taskkill /IM MoritaCBCT.exe', SW_HIDE );

    ProgressBar1.Position := ProgressBar1.Position + 15;

    N_Dump1Str( '3d imported = ' + WrkFilesFolder+'Morita\imageinfo.txt, = ' + s );
    ProgressBar1.Position := ProgressBar1.Position + 17;

    if DirectoryExists( s ) then
    begin
      if (N_CMResForm.aMediaImport3D.Visible) then
        CMOFCaptureSlide( s )
      else
      begin
        K_CMShowMessageDlg( '3d import is unaccessible',
                                              mtInformation, [], FALSE, '', 5 );
      end;
    end // if DirectoryExists( s ) then
    else
    begin
      N_Dump1Str( 'No current folder = ' + s );
      K_CMShowMessageDlg( 'No current folder = ' + s, mtError );
    end;

    //***** clean
    Screen.Cursor := crHourglass;
    CMOFStatus := 10;

    CloseFile( Txt );
    DeleteFile( WrkFilesFolder + 'Morita\imageinfo.txt' );
    DeleteFolder( s );
    Screen.Cursor := crDefault;

    if Length(CMOFPNewSlides^) > 0 then // Move before 2D
          with K_CMEDAccess.CurSlidesList do
            Move( Count - 1, Count - 1 - Length(CMOFPNewSlides^) );

    CMOFStatus := 1;
    bnCapture.Visible := True;
    bnStop.Visible    := False;
    Close();
  end
  else // no file
  begin
    //N_Dump1Str( 'No Image Info file after Capture = ' + s );
    //K_CMShowMessageDlg( 'No Info file after Capture = ' + s, mtError );
  end;
  end
  else // native viewer
  begin
    //SetCurrentDir( WrkFilesFolder + 'Morita\' );
    if FindFirst( WrkFilesFolder + 'Morita\*.ini', faAnyFile, searchResult ) = 0 then
    begin

      // ***** making a form invisible
      Self.AlphaBlend      := True;
      Self.AlphaBlendValue := 0;

      UIDFile := WrkFilesFolder +  'Morita\' + searchResult.Name;
      //Ini:=TiniFile.Create(UIDFile);

      //FormatString := Ini.ReadString( 'Image', 'ModalityName', '' );
      //N_Dump1Str( 'Format found = ' + FormatString );

      //if FormatString = 'CT' then // cbct image

      DeleteFile(UIDFile);

      FindClose(searchResult);
      Close();

    end; // if FormatString <> 'BMP' then


  end; //try
  except
    on E: Exception do
    begin
      N_Dump1Str( 'Exception cathed, ' + E.Message );
      K_CMShowMessageDlg( 'Exception: ' + E.Message, mtError );
    end;
  end;
  TimerImage.Enabled := True;
end; // procedure TN_CMCaptDev29Form.TimerImageTimer

//************************************* TN_CMCaptDev29Form.TimerStatusTimer ***
// Changing status
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev29Form.TimerStatusTimer( Sender: TObject );
begin
  inherited;
  if CMOFStatus <> CMOFStatusPrev then // new status
  begin
    case CMOFStatus of
    1: begin
      StatusLabel.Caption := 'Waiting';
      StatusLabel.Font.Color  := TColor( $168EF7 );
      StatusShape.Pen.Color   := TColor( $168EF7 );
      StatusShape.Brush.Color := TColor( $168EF7 );
    end;
    2: begin
      StatusLabel.Caption := 'Starting i-Dixel';
      StatusLabel.Font.Color  := clBlue;
      StatusShape.Pen.Color   := clBlue;
      StatusShape.Brush.Color := clBlue;
    end;
    3: begin
      StatusLabel.Caption := 'Waiting for Image';
      StatusLabel.Font.Color  := clGreen;
      StatusShape.Pen.Color   := clGreen;
      StatusShape.Brush.Color := clGreen;
    end;
    4: begin
      StatusLabel.Caption := 'Reading Image Info';
      StatusLabel.Font.Color  := clBlue;
      StatusShape.Pen.Color   := clBlue;
      StatusShape.Brush.Color := clBlue;
    end;
    5: begin
      StatusLabel.Caption := 'Starting Image Import';
      StatusLabel.Font.Color  := clBlue;
      StatusShape.Pen.Color   := clBlue;
      StatusShape.Brush.Color := clBlue;
    end;
    6: begin
      StatusLabel.Caption := 'Calling CMS 3D Viewer';
      StatusLabel.Font.Color  := clBlue;
      StatusShape.Pen.Color   := clBlue;
      StatusShape.Brush.Color := clBlue;
    end;
    7: begin
      StatusLabel.Caption := 'Creating Thumbnail';
      StatusLabel.Font.Color  := clBlue;
      StatusShape.Pen.Color   := clBlue;
      StatusShape.Brush.Color := clBlue;
    end;
    8: begin
      StatusLabel.Caption := 'Import Attributes';
      StatusLabel.Font.Color  := clBlue;
      StatusShape.Pen.Color   := clBlue;
      StatusShape.Brush.Color := clBlue;
    end;
    9: begin
      StatusLabel.Caption := 'Saving Image';
      StatusLabel.Font.Color  := clBlue;
      StatusShape.Pen.Color   := clBlue;
      StatusShape.Brush.Color := clBlue;
    end;
    10: begin
      StatusLabel.Caption := 'Deleting Temporary Files';
      StatusLabel.Font.Color  := clBlue;
      StatusShape.Pen.Color   := clBlue;
      StatusShape.Brush.Color := clBlue;
    end;

    end;

    CMOFStatusPrev := CMOFStatus; // so do not change to a same one
  end;
end;// procedure TN_CMCaptDev29Form.TimerStatusTimer

end.


