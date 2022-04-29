unit N_CMCaptDev26F;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0, N_CMCaptDev0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

const
  WM_MORITA_COMMAND = WM_USER + 3;
  WM_MORITA_HANDLE  = WM_USER + 4;

type TN_CMCaptDev26Form = class( TN_BaseForm )
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
    TimerSidexis: TTimer;
    TimerImage: TTimer;
    TimerStatus: TTimer;

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
    procedure FormCloseQuery   ( Sender: TObject; var CanClose: Boolean );
    procedure bnSetupClick     ( Sender: TObject );
    procedure FormCreate       ( Sender: TObject );
    procedure FormPaint        ( Sender: TObject );
    procedure OnCommand( var Msg: TMessage ); message WM_MORITA_COMMAND;
    procedure OnHandle ( var Msg: TMessage ); message WM_MORITA_HANDLE;
    procedure TimerImageTimer  ( Sender: TObject );
    procedure TimerStatusTimer(Sender: TObject);
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
    CMOFStatus, CMOFStatusPrev: Integer;

    CMOFMoritaHandle: LongInt;

    CMOFThisForm: TN_CMCaptDev26Form;        // Pointer to this form

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
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev26,
  N_CMCaptDev26aF, TlHelp32, K_CM1, K_CML1F, N_CMResF, ShellAPI, Registry;
{$R *.dfm}

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

//**********************  TN_CMCaptDev26Form class handlers  ******************

//********************************************* TN_CMCaptDev26Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev26Form.FormShow( Sender: TObject );
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
  N_Dump1Str( 'Morita Start FormShow' );

  Caption := CMOFPProfile^.CMDPCaption + ' X-Ray Capture';
  tbRotateImage.Images := N_CM_MainForm.CMMCurBigIcons;
  CMOFDrawSlideObj := TN_CMDrawSlideObj.Create(); // used in jn CMOFDrawThumb for Drawing Thumbnails
  CMOFThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, CMOFGetThumbSize );


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

  KillTask('Morita.exe');

  if not ExistClassID( '{4E0228AE-3E5D-11D1-B0B2-006052024E07}' ) then
  begin
    K_CMShowMessageDlg( 'DixelD.ocx is not registered properly', mtError );
    N_Dump1Str( 'DixelD.ocx is not registered properly' );
  end
  else
  begin
    N_Dump1Str( 'DixelD.ocx CLSID is found' );

    if CMOFPProfile.CMDPStrPar1 = '1' then
      N_CMCDServObj26.StartDriver( CMOFThisForm.Handle, True )
    else
      N_CMCDServObj26.StartDriver( CMOFThisForm.Handle, False );
  end;

//  if CMOFPProfile.CMDPStrPar1 = '1' then
//    N_CMCDServObj26.StartDriver( CMOFThisForm.Handle, True )
//  else
//    N_CMCDServObj26.StartDriver( CMOFThisForm.Handle, False );

  //CMOFOpened := False;

  N_Dump1Str( 'Morita End FormShow' );
end; // procedure TN_CMCaptDev26Form.FormShow

//******************************************** TN_CMCaptDev26Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev26Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
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
end; // function DeleteFolder
var
  WrkDir: string;
begin
  PostMessage( HWND(CMOFMoritaHandle), WM_MORITA_COMMAND, 2, 0 );

  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  WrkDir := N_CMV_GetWrkDir();
  WrkDir := StringReplace( WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase] );

  if DirectoryExists( WrkDir + 'Morita' ) then
    DeleteFolder( WrkDir + 'Morita' );

  N_Dump2Str( 'CMOther26Form.FormClose' );
  Inherited;
end;

//*************************************** TN_CMCaptDev26Form.FormCloseQuery ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// CanClose
//
// OnClose Self handler
//
procedure TN_CMCaptDev26Form.FormCloseQuery(Sender: TObject;
                                                         var CanClose: Boolean);
begin
  inherited;
end; // TN_CMCaptDev26Form.FormCloseQuery

procedure TN_CMCaptDev26Form.FormCreate(Sender: TObject);
begin
  inherited;

end;

//****************************************** TN_CMCaptDev26Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev26Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev26Form.FormKeyDown

//******************************************** TN_CMCaptDev26Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev26Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev26Form.FormKeyUp

procedure TN_CMCaptDev26Form.FormPaint(Sender: TObject);
begin
  inherited;
end;

//************************************* TN_CMCaptDev26Form.SlidePanelResize ***
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev26Form.SlidePanelResize( Sender: TObject );
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev26Form.SlidePanelResize

//**************************************** TN_CMCaptDev26Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev26Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev26Form.tbLeft90Click

//*************************************** TN_CMCaptDev26Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev26Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev26Form.tbRight90Click

//************************************** TN_CMCaptDev26Form.TimerImageTimer ***
// Waiting for an image
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev26Form.TimerImageTimer( Sender: TObject );
var
  WrkDir: string;
begin
  inherited;
  WrkDir := N_CMV_GetWrkDir();
  WrkDir := StringReplace( WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase] );

  if CMOFPProfile.CMDPStrPar1 = '1' then // 8bit
  begin
    if FileExists( WrkDir+'Morita/Morita_temp.bmp' ) then
    begin
      CMOFStatus := 2; // processing
      CMOFCaptureSlide( WrkDir+'Morita/Morita_temp.bmp' );
      CMOFStatus := 1; // processing ended
    end;
    DeleteFile( WrkDir+'Morita/Morita_temp.bmp' );
  end
  else // 16 bit
  begin
    if FileExists( WrkDir + 'Morita/Morita_temp.tif' ) then
    begin
      CMOFStatus := 2; // processing
      CMOFCaptureSlide( WrkDir + 'Morita/Morita_temp.tif' );
      CMOFStatus := 1; // processing ended
    end;
    DeleteFile( WrkDir + 'Morita/Morita_temp.tif' );
  end;
end; // procedure TN_CMCaptDev26Form.TimerImageTimer(Sender: TObject);

//************************************* TN_CMCaptDev26Form.TimerStatusTimer ***
// Changing status
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev26Form.TimerStatusTimer( Sender: TObject );
begin
  inherited;
  if CMOFStatus <> CMOFStatusPrev then // new status
  begin
    case CMOFStatus of
    1: begin
      StatusLabel.Caption := 'Connected';
      StatusLabel.Font.Color  := clGreen;
      StatusShape.Pen.Color   := clGreen;
      StatusShape.Brush.Color := clGreen;
    end;
    2: begin
      StatusLabel.Caption := 'Processing';
      StatusLabel.Font.Color  := clBlue;
      StatusShape.Pen.Color   := clBlue;
      StatusShape.Brush.Color := clBlue;
    end;

    end;

    CMOFStatusPrev := CMOFStatus; // so do not change to a same one
  end;

end; // procedure TN_CMCaptDev26Form.TimerStatusTimer

// procedure TN_CMCaptDev26Form.UpDown1Click
procedure TN_CMCaptDev26Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev26Form.UpDown1Click

//******************************************* TN_CMCaptDev26Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev26Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev26Form.tb180Click

//*************************************** TN_CMCaptDev26Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev26Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev26Form.tbFlipHorClick


//**********************  TN_CMCaptDev26Form class public methods  ************

//**************************************** TN_CMCaptDev26Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev26Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev26Form.CMOFDrawThumb

//************************************* TN_CMCaptDev26Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev26Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
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
end; // procedure TN_CMCaptDev26Form.CMOFGetThumbSize

//***************************************** TN_CMCaptDev26Form.bnSetupClick ***
// Setup
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev26Form.bnSetupClick(Sender: TObject);
begin
  PostMessage( HWND(CMOFMoritaHandle), WM_MORITA_COMMAND, 1, 0 );
end; // procedure TN_CMCaptDev26Form.bnSetupClick

//************************************* TN_CMCaptDev26Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Image - image path
// Return 0 if OK
//
function TN_CMCaptDev26Form.CMOFCaptureSlide( Image: string ): Integer;
var
  i: Integer;
  CapturedDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
begin
    Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
    N_Dump1Str( Format('Morita Start CMOFCaptureSlide %d', [CMOFNumCaptured]));

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

    N_Dump1Str(Format('Morita Fin CMOFCaptureSlide %d', [CMOFNumCaptured]));
  Result := 0;
end; // end of TN_CMCaptDev26Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev26Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev26Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev26Form.CurStateToMemIni

//************************************* TN_CMCaptDev26Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev26Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev26Form.MemIniToCurState

//******************************************* TN_CMCaptDev26aForm.OnCommand ***
// Windows message
//
//     Parameters
// Msg - incoming Windows message
//
procedure TN_CMCaptDev26Form.OnCommand( var Msg: TMessage );
//var
//  WP, LP: Integer;
begin
end; // procedure TN_CMCaptDev26Form.OnCommand( var Msg: TMessage );

//********************************************* TN_CMCaptDev26Form.OnHandle ***
// Receiving a driver's window handle
//
//     Parameters
// Msg - message received
//
procedure TN_CMCaptDev26Form.OnHandle( var Msg: TMessage );
var
  WP{, LP}: Integer;
begin
N_Dump1Str('Morita, OnHandle started');
  WP := Integer( Msg.WParam );

  if WP <> 0 then
    CMOFStatus := 1; // connected

  //LP := Integer( Msg.LParam );
  CMOFMoritaHandle := WP;
  N_Dump1Str('Morita, OnHandle ended');
end; // procedure TN_CMCaptDev17Form.OnHandle( var Msg: TMessage );

end.


