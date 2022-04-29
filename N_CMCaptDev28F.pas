unit N_CMCaptDev28F;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0, N_CMCaptDev0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, xmldom,
  XMLIntf, msxmldom, XMLDoc;

type TN_CMCaptDev28Form = class( TN_BaseForm )
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
    TimerImage:   TTimer;
    ProgressBar1: TProgressBar;
    bnStop:       TButton;
    TimerStatus:  TTimer;
    bnCapture:    TButton;
    Timer3DEnabled: TTimer;

    //******************  TN_CMCaptDev28Form class handlers  ******************

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
    procedure TimerImageTimer  ( Sender: TObject );
    procedure bnStopClick      ( Sender: TObject );
    procedure TimerStatusTimer ( Sender: TObject );
    procedure bnCaptureClick   ( Sender: TObject );
    procedure Timer3DEnabledTimer(Sender: TObject);
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

    CMOFThisForm: TN_CMCaptDev28Form;        // Pointer to this form

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide ( Image: string ): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMCaptDev28Form = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

var
  PelsPerInch: integer; // pixels per inch received from a driver

implementation

uses
  Math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev28,
  N_CMCaptDev28aF, TlHelp32, K_CM1, K_CML1F, N_CMResF, ShellAPI, IniFiles,
  ComObj, ActiveX;
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

//**********************  TN_CMCaptDev28Form class handlers  ******************

//********************************************* TN_CMCaptDev28Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev28Form.FormShow( Sender: TObject );
begin
  N_Dump1Str( 'RayScan Start FormShow' );
  //bnSetup.Enabled := False;

  Caption := CMOFPProfile^.CMDPCaption + ' X-Ray Capture';
  tbRotateImage.Images := N_CM_MainForm.CMMCurBigIcons;
  CMOFDrawSlideObj := TN_CMDrawSlideObj.Create(); // used in jn CMOFDrawThumb for Drawing Thumbnails
  CMOFThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, CMOFGetThumbSize );

  DeleteFile( 'C:\Ray\ImageOutput.xml' );

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

  CMOFStatusPrev := -1;
  CMOFStatus := 0;

  if CMOFPProfile.CMDPStrPar1 <> '' then // start right away
    bnCapture.OnClick( Nil );

  N_Dump1Str( 'RayScan End FormShow' );
end; // procedure TN_CMCaptDev28Form.FormShow

//******************************************** TN_CMCaptDev28Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev28Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  N_Dump2Str( 'CMOther25Form.FormClose' );
  Inherited;
end;

//*************************************** TN_CMCaptDev28Form.FormCloseQuery ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// CanClose
//
// OnClose Self handler
//
procedure TN_CMCaptDev28Form.FormCloseQuery(Sender: TObject;
                                                         var CanClose: Boolean);
begin
  inherited;
end; // TN_CMCaptDev28Form.FormCloseQuery

procedure TN_CMCaptDev28Form.FormCreate(Sender: TObject);
begin
  inherited;
end;

//****************************************** TN_CMCaptDev28Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev28Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev28Form.FormKeyDown

//******************************************** TN_CMCaptDev28Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev28Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev28Form.FormKeyUp

procedure TN_CMCaptDev28Form.FormPaint(Sender: TObject);
begin
  inherited;
end;

//************************************* TN_CMCaptDev28Form.SlidePanelResize ***
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev28Form.SlidePanelResize( Sender: TObject );
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev28Form.SlidePanelResize

//**************************************** TN_CMCaptDev28Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev28Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev28Form.tbLeft90Click

//*************************************** TN_CMCaptDev28Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev28Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev28Form.UpDown1Click

//************************************** TN_CMCaptDev28Form.TimerImageTimer ***
// Checking for CMS 3D
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev28Form.Timer3DEnabledTimer(Sender: TObject);
begin
  inherited;
  if not (N_CMResForm.aMediaImport3D.Visible) then
  begin
    Timer3DEnabled.Enabled := False;
    K_CMShowMessageDlg( '3d import is unaccessible',
                                              mtInformation, [], FALSE, '', 5 );
    Close();
  end;
end; // procedure TN_CMCaptDev28Form.Timer3DEnabledTimer

//************************************** TN_CMCaptDev28Form.TimerImageTimer ***
// Waiting for an image
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev28Form.TimerImageTimer(Sender: TObject);
var
  WrkDir, FileName: string;

//************************************************************* GetFileName ***
// Parse ini for Filename
//
//     Parameters
// Result - Filename
//
function GetFileName(): string;
const
  CAttrName = 'value';
  HTAB = #9;
var
  LDocument:    IXMLDocument;
  LNodeElement: IXMLNode;
  LAttrValue, WrkDir: string;
begin
  LDocument := TXMLDocument.Create(nil);

  WrkDir := K_ExpandFileName( '(#TmpFiles#)' );
  WrkDir := StringReplace( WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase] );
  // not needed the real WrkDir
  WrkDir := 'C:\Ray\ImageOutput.xml';

  LDocument.LoadFromFile(WrkDir); { File should exist. }

  // Find a specific node
  LNodeElement := LDocument.ChildNodes.FindNode('RAYSCAN');

  if (LNodeElement <> nil) then
  LNodeElement := LNodeElement.ChildNodes.FindNode('ImageInfo');

  if (LNodeElement <> nil) then
  LNodeElement := LNodeElement.ChildNodes.FindNode('ImageList');

  if (LNodeElement <> nil) then
  LNodeElement := LNodeElement.ChildNodes.FindNode('ImagePath');

  if (LNodeElement <> nil) then
  begin
    // Get a specific attribute
    if (LNodeElement.HasAttribute(CAttrName)) then
    begin
      LAttrValue := LNodeElement.Attributes[CAttrName];
    end;
  end;

  Result := ExtractFilePath(LAttrValue);
end;
begin
  inherited;
  TimerImage.Enabled := False;

  WrkDir := K_ExpandFileName( '(#TmpFiles#)' );
  WrkDir := StringReplace( WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase] );

  CMOFStatus := 3;

  if FileExists( 'C:\Ray\ImageOutput.xml' ) then // there's output
  begin
    // ***** making a form invisible
    Self.AlphaBlend      := True;
    Self.AlphaBlendValue := 0;

    ProgressBar1.Position := ProgressBar1.Position + 20;
    ProgressBar1.Position := ProgressBar1.Position + 10;

    CMOFStatus := 4;
    FileName := GetFileName(); // image path
    ProgressBar1.Position := ProgressBar1.Position + 25;

    CMOFStatus := 5;
    CMOFCaptureSlide( FileName );

    //***** clean
    Screen.Cursor := crHourglass;
    CMOFStatus := 10;

    DeleteFile( 'C:\Ray\ImageOutput.xml' );
    WinExec( 'taskkill /IM RAYSCAN.exe', SW_HIDE );
    Screen.Cursor := crDefault;

    //bnStop.OnClick(Nil);
    //Exit();
    Close();
  end;
  TimerImage.Enabled := True;
end; // procedure TN_CMCaptDev28Form.TimerImageTimer(Sender: TObject);

procedure TN_CMCaptDev28Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev28Form.UpDown1Click

//******************************************* TN_CMCaptDev28Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev28Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev28Form.tb180Click

//*************************************** TN_CMCaptDev28Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev28Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev28Form.tbFlipHorClick


//**********************  TN_CMCaptDev28Form class public methods  ************

//**************************************** TN_CMCaptDev28Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev28Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev28Form.CMOFDrawThumb

//************************************* TN_CMCaptDev28Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev28Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
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
end; // procedure TN_CMCaptDev28Form.CMOFGetThumbSize

//*************************************** TN_CMCaptDev28Form.bnCaptureClick ***
// Capture
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev28Form.bnCaptureClick(Sender: TObject);
var
  WrkDir:    string;
  DriverRes: Boolean;
begin
  inherited;
  bnStop.Visible    := True;
  bnCapture.Visible := False;

  ProgressBar1.Position := 0;
  CMOFStatus := 1; // beginning status

  WrkDir := K_ExpandFileName( '(#TmpFiles#)' );
  N_Dump1Str( 'WrkDir = ' + WrkDir );
  WrkDir := StringReplace( WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase] );
  ProgressBar1.Position := ProgressBar1.Position + 15;

  ProgressBar1.Position := ProgressBar1.Position + 20;

  TimerImage.Enabled := True;
  CMOFStatus := 2;

  if CMOFPProfile.CMDPStrPar1 <> '' then
  begin
    DriverRes := N_CMCDServObj28.StartDriver( CMOFPProfile.CMDPStrPar1, True );

  end
  else
  begin
    K_CMShowMessageDlg( 'RayScan settings should be filled',
                                              mtInformation, [], FALSE, '', 5 );
    bnStopClick(Nil);
    Exit;
  end;

  if DriverRes = False then
  begin
    K_CMShowMessageDlg( 'Capture file is not valid',
                                              mtError, [], FALSE, '', 5 );
    bnStopClick(Nil);
    Exit;
  end;
  ProgressBar1.Position := ProgressBar1.Position + 10;
end; //***************************************** TN_CMCaptDev28Form.bnCaptureClick ***

//***************************************** TN_CMCaptDev28Form.bnSetupClick ***
// Capture
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev28Form.bnSetupClick(Sender: TObject);
var
  Form: TN_CMCaptDev28aForm; // Settings form
begin
  inherited;
  N_Dump1Str( 'RayScan CBCT >> CDSSettingsDlg begin' );

  Form := TN_CMCaptDev28aForm.Create( Application );
  // create setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  //Form.CMOFPDevProfile := CMOFPProfile; // link form variable to profile
  Form.Caption := CMOFPProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := N_CMCDServObj28.PProfile;
  Form.ShowModal(); // Show a setup form

  N_Dump1Str( 'RayScan CBCT >> CDSSettingsDlg end' );
end; // procedure TN_CMCaptDev28Form.bnSetupClick

//************************************* TN_CMCaptDev28Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Image - image path
// Return 0 if OK
//
procedure TN_CMCaptDev28Form.bnStopClick(Sender: TObject);
begin
  inherited;
  CMOFStatus := 0;

  bnCapture.Visible     := True;
  bnStop.Visible        := False;
  ProgressBar1.Position := 0;
  TimerImage.Enabled    := False;
end; // procedure TN_CMCaptDev28Form.bnStopClick(Sender: TObject);

//************************************* TN_CMCaptDev28Form.TimerStatusTimer ***
// Changing status
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev28Form.TimerStatusTimer( Sender: TObject );
begin
  inherited;
  if CMOFStatus <> CMOFStatusPrev then // new status
  begin
    case CMOFStatus of
    0: begin
      StatusLabel.Caption := 'Waiting';
      StatusLabel.Font.Color  := TColor( $168EF7 );
      StatusShape.Pen.Color   := TColor( $168EF7 );
      StatusShape.Brush.Color := TColor( $168EF7 );
    end;
    1: begin
      StatusLabel.Caption := 'Ready';
      StatusLabel.Font.Color  := clGreen;
      StatusShape.Pen.Color   := clGreen;
      StatusShape.Brush.Color := clGreen;
    end;
    2: begin
      StatusLabel.Caption := 'Creating Ini File';
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
end;// procedure TN_CMCaptDev28Form.TimerStatusTimer

//************************************* TN_CMCaptDev28Form.CMOFCaptureSlide ***
// Importing Image
//
//     Parameters
// Image  - Filename
// Result - 0 if correct
//
function TN_CMCaptDev28Form.CMOFCaptureSlide( Image: string ): Integer;
var
  Slide3D:      TN_UDCMSlide;
  InfoFName:    string;
  CurSlidesNum, ResCode : Integer;
  AddViewsInfo: string;
begin
  if DirectoryExists(Image) then
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
  end;

  Result := 0;
end; // end of TN_CMCaptDev28Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev28Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev28Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev28Form.CurStateToMemIni

//************************************* TN_CMCaptDev28Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev28Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev28Form.MemIniToCurState

end.


