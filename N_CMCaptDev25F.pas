unit N_CMCaptDev25F;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0, N_CMCaptDev0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type TN_CMCaptDev25Form = class( TN_BaseForm )
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
    RadioGroup1: TRadioGroup;
    TimerImage: TTimer;
    rgSidexis:  TRadioGroup;
    bnStop:    TButton;
    bnOpen:    TButton;
    pnSidexis: TPanel;
    TimerSidexis: TTimer;
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
    procedure TimerSidexisTimer( Sender: TObject );
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

    CMOFMailslotPath, CMOFMailslotName, CMOFPDataPath, CMOFTempNewestPath: string;
    CMOFOpened: Boolean;
    CMOFOrderNumber, CMOFStatus, CMOFStatusPrev, CMOFNumberPar: Integer;

    ThisForm: TN_CMCaptDev25Form;        // Pointer to this form

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide ( Image: string ): Integer;
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
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev25,
  N_CMCaptDev25aF, TlHelp32, K_CM1, K_CML1F, N_CMResF, ShellAPI;
{$R *.dfm}

//********************************************************** FindNewestFile ***
// Search for a newest file in a folder
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
    if FindFirst( Folder + '*.*', faAnyFile, sr ) = 0 then
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

//**********************  TN_CMCaptDev25Form class handlers  ******************

//********************************************* TN_CMCaptDev25Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev25Form.FormShow( Sender: TObject );
begin
  N_Dump1Str( 'Slida Start FormShow' );
  //bnSetup.Enabled := False;

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

  // ***** parsing a string
  if CMOFPProfile.CMDPStrPar1 <> '' then
  begin
    CMOFMailslotPath := Copy( CMOFPProfile.CMDPStrPar1, 0,
                                      Pos('/~/',CMOFPProfile.CMDPStrPar1) - 1 );
    CMOFMailslotName := ExtractFileName( CMOFMailslotPath );
    //CMOFMailslotPath := ExtractFilePath( CMOFMailslotPath );
    CMOFPDataPath := Copy( CMOFPProfile.CMDPStrPar1,
                                      Pos('/~/',CMOFPProfile.CMDPStrPar1) + 3,
                                      Pos('/#/',CMOFPProfile.CMDPStrPar1) -
                                      Pos('/~/',CMOFPProfile.CMDPStrPar1) - 3 );
    CMOFNumberPar := StrToInt( Copy( CMOFPProfile.CMDPStrPar1,
                                      Pos('/#/',CMOFPProfile.CMDPStrPar1) + 3,
                                            Length(CMOFPProfile.CMDPStrPar1)) );
  end;

  if CMOFPProfile.CMDPStrPar2 <> '' then
  begin
    RadioGroup1.ItemIndex := StrToInt( CMOFPProfile.CMDPStrPar2[1] );
    rgSidexis.ItemIndex   := StrToInt( CMOFPProfile.CMDPStrPar2[2] );
  end
  else
  begin
  end;

  //***** shared order number
  K_CMLoadUserStrings();
  CMOFOrderNumber := StrToIntDef( K_CMGetUserString( 'SlidaOrderNumber' ), 0 );
  if CMOFOrderNumber < 2  then
    CMOFOrderNumber := 2; // starting point

  K_CMSetUserString( 'SlidaOrderNumber', IntToStr(CMOFOrderNumber) );

  N_Dump1Str( 'Order Number after opening = ' + IntToStr(CMOFOrderNumber) );

  CMOFOpened := False;

  if ( CMOFMailslotPath <> '' ) and ( CMOFMailslotName <> '' ) and
                                                    ( CMOFPDataPath <> '' ) then
  begin
    bnOpen.OnClick( Nil );
    bnCapture.OnClick( Nil );
  end;

  N_Dump1Str( 'Slida End FormShow' );
end; // procedure TN_CMCaptDev25Form.FormShow

//******************************************** TN_CMCaptDev25Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev25Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  WinExec( 'taskkill /IM SLIDA.exe', SW_HIDE );

 // CMOFPProfile.CMDPStrPar1 := CMOFMailslotPath + CMOFMailslotName + '/~/' +
 //                               CMOFPDataPath + '/#/' + IntToStr(CMOFNumberPar);

  CMOFPProfile.CMDPStrPar2 := IntToStr(RadioGroup1.ItemIndex) +
             IntToStr(rgSidexis.ItemIndex);// + IntToStr(CMOFOrderNumber div 1000)+
          //IntToStr(CMOFOrderNumber div 100) + IntToStr(CMOFOrderNumber div 10) +
          //                                     IntToStr(CMOFOrderNumber mod 10);

  N_Dump1Str( 'Order Number before closing = ' + IntToStr(CMOFOrderNumber) );
  K_CMSetUserString( 'SlidaOrderNumber', IntToStr(CMOFOrderNumber) );
  K_CMSaveUserStrings();

  N_Dump2Str( 'CMOther25Form.FormClose' );
  Inherited;
end;

//*************************************** TN_CMCaptDev25Form.FormCloseQuery ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// CanClose
//
// OnClose Self handler
//
procedure TN_CMCaptDev25Form.FormCloseQuery(Sender: TObject;
                                                         var CanClose: Boolean);
begin
  inherited;
end; // TN_CMCaptDev25Form.FormCloseQuery

procedure TN_CMCaptDev25Form.FormCreate(Sender: TObject);
begin
  inherited;

end;

//****************************************** TN_CMCaptDev25Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev25Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev25Form.FormKeyDown

//******************************************** TN_CMCaptDev25Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev25Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev25Form.FormKeyUp

procedure TN_CMCaptDev25Form.FormPaint(Sender: TObject);
begin
  inherited;
end;

//************************************* TN_CMCaptDev25Form.SlidePanelResize ***
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev25Form.SlidePanelResize( Sender: TObject );
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev25Form.SlidePanelResize

//**************************************** TN_CMCaptDev25Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev25Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev25Form.tbLeft90Click

//*************************************** TN_CMCaptDev25Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev25Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev25Form.tbRight90Click

// procedure TN_CMCaptDev25Form.UpDown1Click
procedure TN_CMCaptDev25Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev25Form.UpDown1Click

//******************************************* TN_CMCaptDev25Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev25Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev25Form.tb180Click

//*************************************** TN_CMCaptDev25Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev25Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev25Form.tbFlipHorClick


//**********************  TN_CMCaptDev25Form class public methods  ************

//**************************************** TN_CMCaptDev25Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev25Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev25Form.CMOFDrawThumb

//************************************* TN_CMCaptDev25Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev25Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
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
end; // procedure TN_CMCaptDev25Form.CMOFGetThumbSize

//****************************************** TN_CMCaptDev25Form.bnOpenClick ***
// Open Sidexis
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev25Form.bnOpenClick( Sender: TObject );
begin
  inherited;
  if rgSidexis.ItemIndex = 1 then
    WinExec( 'C:\Program Files\Sirona\SIDEXIS4\Sidexis4.exe', SW_NORMAL ) // should've change if using other path, also in SLIDA.exe, take it from there
  else
    WinExec( 'C:\SIDEXIS\Sidexis.exe', SW_NORMAL );
end; // procedure TN_CMCaptDev25Form.bnOpenClick

//***************************************** TN_CMCaptDev25Form.bnSetupClick ***
// Setup
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev25Form.bnSetupClick(Sender: TObject);
var
  Form: TN_CMCaptDev25aForm;
begin
  //PProfile := APDevProfile;
  N_Dump1Str( 'Slida >> CDSSettingsDlg begin' );
  Form := TN_CMCaptDev25aForm.Create( application );

  // create a setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  //Form.CMOFPDevProfile := APDevProfile; // link form variable to profile

  Form.CMOFPDevProfile := N_CMCDServObj25.PProfile;

  Form.ShowModal(); // Show a setup form

  if CMOFPProfile.CMDPStrPar1 <> '' then
  begin
    CMOFMailslotPath := Copy( CMOFPProfile.CMDPStrPar1, 0,
                                      Pos('/~/',CMOFPProfile.CMDPStrPar1) - 1 );
    CMOFPDataPath := Copy( CMOFPProfile.CMDPStrPar1,
                                      Pos('/~/',CMOFPProfile.CMDPStrPar1) + 3,
                                      Pos('/#/',CMOFPProfile.CMDPStrPar1) -
                                      Pos('/~/',CMOFPProfile.CMDPStrPar1) - 3 );
    CMOFNumberPar := StrToInt( Copy( CMOFPProfile.CMDPStrPar1,
                                      Pos('/#/',CMOFPProfile.CMDPStrPar1) + 3,
                                            Length(CMOFPProfile.CMDPStrPar1)) );
  end;

  //***** set new order number
  K_CMLoadUserStrings();
  CMOFOrderNumber := StrToIntDef( K_CMGetUserString( 'SlidaOrderNumber' ), 0 );
  if CMOFOrderNumber < 2  then
    CMOFOrderNumber := 2; // starting point

  K_CMSetUserString( 'SlidaOrderNumber', IntToStr(CMOFOrderNumber) );

  N_Dump1Str( 'Order Number after changing = ' + IntToStr(CMOFOrderNumber) );

  N_Dump1Str( 'Slida >> CDSSettingsDlg end' );
end; // procedure TN_CMCaptDev25Form.bnSetupClick

//****************************************** TN_CMCaptDev25Form.bnStopClick ***
// Stop waiting for Sidexis
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev25Form.bnStopClick( Sender: TObject );
begin
  inherited;

  CMOFStatus := 1;

  bnCapture.Visible     := True;
  bnStop.Visible        := False;
  ProgressBar1.Position := 0;
  TimerImage.Enabled    := False;
  CMOfOpened            := False;
end; // procedure TN_CMCaptDev25Form.bnStopClick

//*************************************** TN_CMCaptDev25Form.bnCaptureClick ***
// Capture start
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev25Form.bnCaptureClick(Sender: TObject);
var
  WrkFilesFolder: string;

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

  CMOFStatus := 2;

  bnCapture.Visible := False;
  bnStop.Visible    := True;
  ProgressBar1.Position := 0;

  WrkFilesFolder := CMOFPDataPath;//K_ExpandFileName( '(#TmpFiles#)' );

  ProgressBar1.Position := ProgressBar1.Position + 2;
  if not DirectoryExists( WrkFilesFolder + 'ImportedCBCT' ) then
    CreateDir( WrkFilesFolder + 'ImportedCBCT' );

  ProgressBar1.Position := ProgressBar1.Position + 9;
  WinExec( 'taskkill /IM SLIDA.exe', SW_HIDE );

  ProgressBar1.Position := ProgressBar1.Position + 5;
  CMOFTempNewestPath := FindNewestFile(CMOFPDataPath);

  ProgressBar1.Position := ProgressBar1.Position + 9;
  if (CMOFMailslotPath = '') or (CMOFMailslotName = '') or
                                                       (CMOFPDataPath = '') then
  begin
    K_CMShowMessageDlg( 'Slida settings should be filled',
                                              mtInformation, [], FALSE, '', 5 );
    bnStopClick(Nil);
    Exit;
  end;

  Inc( CMOFOrderNumber );
  N_Dump1Str( 'Order Number increased = ' + IntToStr(CMOFOrderNumber) );
  if CMOFOrderNumber = 10000 then // start again
    CMOFOrderNumber := 2;

  N_CMCDServObj25.StartDriver( ThisForm.Handle );

  ProgressBar1.Position := ProgressBar1.Position + 10;
  CMOFStatus := 3;

  while True do
  begin
    if not ProcessExists('SLIDA.exe') then
    begin
      TimerSidexis.Enabled := True; // waiting for sidexis
      Exit;
    end;
  end;
end;

//************************************* TN_CMCaptDev25Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Image - image path
// Return 0 if OK
//
function TN_CMCaptDev25Form.CMOFCaptureSlide( Image: string ): Integer;
var
  i: Integer;
  CapturedDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;

  Slide3D:      TN_UDCMSlide;
  InfoFName:    string;
  CurSlidesNum, ResCode : Integer;
  AddViewsInfo: string;
begin
  if RadioGroup1.ItemIndex <> 2 then // not 3d
  begin
    Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
    N_Dump1Str( Format('Slida Start CMOFCaptureSlide %d', [CMOFNumCaptured]));

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

    N_Dump1Str(Format('Slida Fin CMOFCaptureSlide %d', [CMOFNumCaptured]));
  end
  else // 3d
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

      // ***** making a form invisible
      Self.AlphaBlend      := True;
      Self.AlphaBlendValue := 0;

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
  end;

  Result := 0;
end; // end of TN_CMCaptDev25Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev25Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev25Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev25Form.CurStateToMemIni

//************************************* TN_CMCaptDev25Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev25Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev25Form.MemIniToCurState

//********************************** TN_CMCaptDev25Form.Timer3DEnabledTimer ***
// Checks if 3d import is available
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev25Form.Timer3DEnabledTimer( Sender: TObject );
begin
  inherited;
if not (N_CMResForm.aMediaImport3D.Visible) then
  begin
    Timer3DEnabled.Enabled := False;
    K_CMShowMessageDlg( '3d import is unaccessible',
                                              mtInformation, [], FALSE, '', 5 );
    Close();
  end;
end; // procedure TN_CMCaptDev25Form.Timer3DEnabledTimer

//************************************** TN_CMCaptDev25Form.TimerImageTimer ***
// Wait for 3d info file
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev25Form.TimerImageTimer( Sender: TObject );
var
  ImportFile: string;
  Txt:      TextFile;
  s, WrkFilesFolder, AllText: string;
  StrArray: TN_SArray;
  i:        integer;
begin
  inherited;
  TimerImage.Enabled := False;

  try

  if RadioGroup1.ItemIndex = 2 then // if 3d
  begin
    WrkFilesFolder := CMOFPDataPath;//K_ExpandFileName( '(#TmpFiles#)' );

      N_Dump1Str( 'Wrk folder = ' + CMOFPDataPath );
      if FileExists( WrkFilesFolder+'ImportedCBCT\sidexis.sdx' ) then
      begin

        CMOFStatus := 4;
        ProgressBar1.Position := ProgressBar1.Position + 18;

        //***** open info file
        AllText := '';
        AssignFile( Txt, WrkFilesFolder+'ImportedCBCT\sidexis.sdx' );
        Reset( Txt );
        while not Eof( Txt ) do
        begin
          Readln( Txt, s );
        end;

        ProgressBar1.Position := ProgressBar1.Position + 15;

        for i := 1 to Length(s) do
        begin
          if s[i] = #0 then s[i] := ' ';

        end;

        N_ScanSArray( s, StrArray ); // into an array

        for i := 0 to Length(StrArray) - 1 do
        begin
          N_Dump1Str( 'Parsed line: '+IntToStr(i+1)+' - '+StrArray[i] );
        end;

        //***** check info in the last line, search for a path to an image
        ProgressBar1.Position := ProgressBar1.Position + 15;
        N_Dump1Str( '3d imported = ' + WrkFilesFolder + 'ImportedCBCT\' +
                                              StrArray[CMOFNumberPar-1] + '\' );
        ProgressBar1.Position := ProgressBar1.Position + 17;

        if DirectoryExists( WrkFilesFolder + 'ImportedCBCT\' +
                                           StrArray[CMOFNumberPar-1] + '\') then
          CMOFCaptureSlide( WrkFilesFolder + 'ImportedCBCT\' +
                                               StrArray[CMOFNumberPar-1] + '\' )
        else
        begin
          N_Dump1Str('No current folder = ' + WrkFilesFolder + 'ImportedCBCT\' +
                                               StrArray[CMOFNumberPar-1] + '\');
          //K_CMShowMessageDlgByTimer( 'No current folder = ' + WrkFilesFolder +
          //                    'ImportedCBCT\' + StrArray[CMOFNumberPar-1] + '\',
          //                                                            mtError );
        end;

        //***** clean
        Screen.Cursor := crHourglass;
        CMOFStatus := 10;

        CloseFile( Txt );
        DeleteFile( WrkFilesFolder+'ImportedCBCT\sidexis.sdx' );
        DeleteFolder( WrkFilesFolder + 'ImportedCBCT\' +
                                              StrArray[CMOFNumberPar-1] + '\' );
        Screen.Cursor := crDefault;

        CMOFStatus := 1;
        bnCapture.Visible := True;
        bnStop.Visible    := False;
        Close();
      end
      else // no mailslot
      begin
        N_Dump1Str( 'No mailslot file after closing Sidexis = ' + WrkFilesFolder
                          + 'ImportedCBCT\' + StrArray[CMOFNumberPar-1] + '\' );
        //K_CMShowMessageDlg( 'No mailslot file after closing Sidexis = ' +
        //     WrkFilesFolder + 'ImportedCBCT\' + StrArray[CMOFNumberPar-1] + '\',
        //                                                              mtError );
      end;
  end
  else // not 3d
  begin
    ImportFile := FindNewestFile( CMOFPDataPath );
    if CMOFTempNewestPath <> ImportFile then
    begin
      CMOFCaptureSlide( CMOFPDataPath+ImportFile );
      bnCapture.Visible  := True;
      bnStop.Visible     := False;
      TimerImage.Enabled := False;
    end;
  end;
  except
    on E: Exception do
    begin
      N_Dump1Str( 'Exception cathed, ' + E.Message );
      //K_CMShowMessageDlg( 'Exception: ' + E.Message, mtError );
    end;
  end;
end; // procedure TN_CMCaptDev25Form.TimerImageTimer

//************************************ TN_CMCaptDev25Form.TimerSidexisTimer ***
// Wait for Sidexis while it opens
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev25Form.TimerSidexisTimer( Sender: TObject );
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
              UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
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
  if rgSidexis.ItemIndex = 1 then // sidexis 4
  begin
    if ProcessExists( 'Sidexis4.exe' ) then
       begin
         CMOFOpened := True;
       end;
       if (CMOFOpened) and (not ProcessExists('Sidexis4.exe')) then
       begin
         CMOFOpened           := False;
         TimerSidexis.Enabled := False;
         TimerImage.Enabled   := True;
       end;
  end
  else
  begin
    if ProcessExists( 'Sidexis.exe' ) then
       begin
         CMOFOpened := True;
       end;
       if (CMOFOpened) and (not ProcessExists('Sidexis.exe')) then
       begin
         CMOFOpened           := False;
         TimerSidexis.Enabled := False;
         TimerImage.Enabled   := True;
       end;
  end;
end;// procedure TN_CMCaptDev25Form.TimerSidexisTimer

//************************************* TN_CMCaptDev25Form.TimerStatusTimer ***
// Changing status
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev25Form.TimerStatusTimer( Sender: TObject );
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
      StatusLabel.Caption := 'Creating Mailslot';
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
end;// procedure TN_CMCaptDev25Form.TimerStatusTimer

end.


