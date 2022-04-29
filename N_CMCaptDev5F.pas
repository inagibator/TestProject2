unit N_CMCaptDev5F;
// Form for capture Images from Planmeca Devices
// 2014.01.04 Added nil check for XE5 by Valery Ovechkin, line 238
// 2014.03.20 substituted 'K_CMShowMessageDlg' by 'ShowCriticalError' calls by Valery Ovechkin
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin

interface
{$IFNDEF VER150} //***** not Delphi 7

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1,
  Pipes;

type
  TN_CMCaptDev5Form = class(TN_BaseForm)
    MainPanel:     TPanel;
    RightPanel:    TPanel;
    SlidePanel:    TPanel;
    bnExit:        TButton;
    ThumbsRFrame:  TN_Rast1Frame;
    StatusShape:   TShape;
    StatusLabel:   TLabel;
    SlideRFrame:   TN_Rast1Frame;
    CheckTimer:    TTimer;
    tbRotateImage: TToolBar;
    tbLeft90:      TToolButton;
    tbRight90:     TToolButton;
    tb180:         TToolButton;
    tbFlipHor:     TToolButton;
    ProgressBar1:  TProgressBar;
    CheckBox1:     TCheckBox;
    TimerImage:    TTimer;
    StatusTimer:   TTimer;
    bnCapture:     TButton;
    cbCalibration: TCheckBox;
    RadioGroup1:   TRadioGroup; // Other Capturing Form

    // ****************  TN_CMCaptDev5Form class handlers  ******************

    procedure FormShow         ( Sender: TObject );
    procedure FormClose        ( Sender: TObject; var Action: TCloseAction ); override;
    procedure FormKeyDown      ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormKeyUp        ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure SlidePanelResize ( Sender: TObject );
    procedure InitGrab         ();
    procedure CheckTimerTimer  ( Sender: TObject );
    procedure tbLeft90Click    ( Sender: TObject );
    procedure tbRight90Click   ( Sender: TObject );
    procedure tb180Click       ( Sender: TObject );
    procedure tbFlipHorClick   ( Sender: TObject );
    procedure cb1Click         ( Sender: TObject );
    procedure bnCaptureClick   ( Sender: TObject );
    procedure TimerImageTimer  ( Sender: TObject );
    procedure StatusTimerTimer ( Sender: TObject );
    procedure cbCalibrationClick(Sender: TObject);
  public
    CMOFThumbsDGrid:  TN_DGridArbMatr; // DGrid for handling Thumbnails in ThumbsRFrame
    CMOFDrawSlideObj: TN_CMDrawSlideObj; // Object with Attributes for Drawing Thumbnails (jn CMOFDrawThumb)
    CMOFPNewSlides:   TN_PUDCMSArray; // Pointer to Array of New captured Slides
    CMOFAnsiFName:    AnsiString; // Image (created by driver) Full File Name
    CMOFPProfile:     TK_PCMOtherProfile; // Pointer to Device Profile
    CMOFDeviceIndex:  Integer; // Device Index in ECDevices Array

    // added for intraoral
    CMOFStatus, CMOFStatusPrev: Integer;

    CMOFNumCaptured:  Integer; // Number of Captured Slides
    CMOFCurIntStatus: Integer; // Current Device (Form) Status
    CMOFCurTmpStatus: Integer; // Current Sensor Status (temporary)
    CMOFNumTEvents:   Integer; // Number of Timer Events passed
    CMOFIsGrabbing:   Boolean; // True if inside (init_grabbing - finish_grabbing)

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer;const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer; AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure CMOFSetStatus    ( AIntStatus: integer);
    function  CMOFCaptureSlide (): integer;
    function  CMOFCaptureSlide2D( Image: string ): Integer; // intraoral

    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
  end; // type TN_CMCaptDev5Form = class( TN_BaseForm )


  // *********** Global Procedures  *****************************

const // Form states
  N_CMOF4Unknown = 0;
  N_CMOF4Manual = 1;
  N_CMOF4Auto = 2;

  // N_CMOF4Ready        = 1;
  // N_CMOF4Disconnected = 2;
  // N_CMOF4Scanning     = 3;
  // N_CMOF4Error        = 4;
  // N_CMOF4Closing      = 5;

var
  FServer: TPipeServer;

implementation

uses
  math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev5,
  N_CMCaptDev0, TlHelp32;


{$R *.dfm}
// ****************  TN_CMCaptDev5Form class handlers  ******************

// ********************************************* TN_CMCaptDev5Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//

procedure TN_CMCaptDev5Form.FormShow(Sender: TObject);
begin
  N_Dump1Str('Planmeca Start FormShow');
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

  // ***** initial states
  if CMOFPProfile.CMDPStrPar2 = '' then
    CMOFPProfile.CMDPStrPar2 := '00';

  RadioGroup1.ItemIndex := StrToInt(CMOFPProfile.CMDPStrPar2[1]);

  CMOFPProfile.CMDPStrPar2[2] := '1';
  if CMOFPProfile.CMDPStrPar2[2] = '0' then
    cbCalibration.Checked := False
  else
    cbCalibration.Checked := True;

  CMOFStatus := 0;
  bnCapture.OnClick( Nil ); // start

  N_Dump1Str('Planmeca End FormShow');
end; // procedure TN_CMCaptDev5Form.FormShow

// ******************************************** TN_CMCaptDev5Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev5Form.FormClose( Sender: TObject; var Action: TCloseAction );
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
begin
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  if cbCalibration.Checked = False then
    CMOFPProfile.CMDPStrPar2 := IntToStr(RadioGroup1.ItemIndex) + '0'
  else
    CMOFPProfile.CMDPStrPar2 := IntToStr(RadioGroup1.ItemIndex) + '1';

  KillTask( 'Planmeca.exe' );
  Inherited;
  N_Dump2Str( 'CMOther5Form.FormClose' );
end; // procedure TN_CMCaptDev5Form.FormClose

// ****************************************** TN_CMCaptDev5Form.FormKeyDown ***
// Perform needed Actions on Key Down
//
//     Parameters
// Sender - Event Sender
// Key    - Key Pressed
// Shift  - State of Buttons "Shift", "Control", "Alt"
//
procedure TN_CMCaptDev5Form.FormKeyDown( Sender: TObject; var Key: Word;
                                         Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
 {
  if Key = VK_F8 then // Close Self
  begin
 //   Close;
    Exit;
  end; // if Key = VK_F9 then

  // CMOFSetStatus( N_CMOF4Scanning );
  }
end; // procedure TN_CMCaptDev5Form.FormKeyDown

// ******************************************** TN_CMCaptDev5Form.FormKeyUp ***
// Perform needed Actions on Key Up
//
//     Parameters
// Sender - Event Sender
// Key    - Key Pressed
// Shift  - State of Buttons "Shift", "Control", "Alt"
//
procedure TN_CMCaptDev5Form.FormKeyUp( Sender: TObject; var Key: Word;
                                       Shift: TShiftState);
// If F9 is Up - Create new test Slide
begin
{
  Exit;
  }
end; // procedure TN_CMCaptDev5Form.FormKeyUp

// ***************************************** TN_CMCaptDev5Form.bnSetupClick ***
// Perform needed Actions on Button "Setup" click
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev5Form.bnCaptureClick(Sender: TObject);
begin
  bnCapture.Enabled := False;
  with N_CMCDServObj5 do
  begin
    if cbCalibration.Checked = False then
      StartDriver(IntToStr(RadioGroup1.ItemIndex)+'0')
    else
      StartDriver(IntToStr(RadioGroup1.ItemIndex)+'1');

    //CMOFStatus := 0;
    TimerImage.Enabled := True;
  end;
end;
// procedure TN_CMCaptDev5Form.bnSetupClick

// ************************************* TN_CMCaptDev5Form.SlidePanelResize ***
// Perform needed Actions on Slide Panel Resize
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev5Form.SlidePanelResize(Sender: TObject);
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end;

//************************************** TN_CMCaptDev5Form.TimerStatusTimer ***
// Changing status
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev5Form.StatusTimerTimer( Sender: TObject );

// read named pipes
function ReadPipeData(): string;
var
  Pipe, numBytesRead: Cardinal;
  buffer: array[0..127] of WideChar;
begin

  // Open the named pipe, previusly created by server application
  Pipe := CreateFile(
  '\\.\pipe\CMSPlanmecaPipe', // Our pipe name
  GENERIC_READ,
  FILE_SHARE_READ or FILE_SHARE_WRITE,
  nil,
  OPEN_EXISTING,
  FILE_ATTRIBUTE_NORMAL,
  0
  );

  if ( Pipe = INVALID_HANDLE_VALUE ) then
  begin
    N_Dump1Str( 'Failed to open pipe (server must be running first)' );
    Result := '101'; // error
  end;

  // Read the named pipe
  ReadFile( Pipe, buffer, 128*sizeof(WideChar), numBytesRead, nil );

  if numBytesRead <> 0 then
  begin
    N_Dump1Str( 'Read: ' + buffer + ', number of bytes ' +
                                                       IntToStr(numBytesRead) );
    SetString( Result, buffer, 1 );
  end
  else
    Result := '101'; // empty

  // Close the pipe handle
  CloseHandle( Pipe );
end;

begin
  inherited;

  CMOFStatus := StrToInt( ReadPipeData() );
  if CMOFStatus <> 101 then

  if CMOFStatus > 5 then
  begin
    N_Dump1Str( 'Orientation received = ' + IntToStr(CMOFStatus) );
  end;

  if CMOFStatus <> CMOFStatusPrev then // new status
  begin
    case CMOFStatus of
    1: begin
      StatusLabel.Caption := 'Ready';
      StatusLabel.Font.Color  := clGreen;
      StatusShape.Pen.Color   := clGreen;
      StatusShape.Brush.Color := clGreen;
    end;
    0: begin
      StatusLabel.Caption := 'Waiting';
      StatusLabel.Font.Color  := TColor( $168EF7 );
      StatusShape.Pen.Color   := TColor( $168EF7 );
      StatusShape.Brush.Color := TColor( $168EF7 );
    end;
    2: begin
      StatusLabel.Caption := 'Processing';
      StatusLabel.Font.Color  := clBlue;
      StatusShape.Pen.Color   := clBlue;
      StatusShape.Brush.Color := clBlue;
    end;
    3: begin
      StatusLabel.Caption := 'Error';
      StatusLabel.Font.Color  := clRed;
      StatusShape.Pen.Color   := clRed;
      StatusShape.Brush.Color := clRed;
    end;

    end;

    CMOFStatusPrev := CMOFStatus; // so do not change to a same one
  end;
end; // procedure TN_CMCaptDev5Form.StatusTimerTimer( Sender: TObject );

// procedure TN_CMCaptDev5Form.SlidePanelResize

// ********************************************* TN_CMCaptDev5Form.InitGrab ***
// Initialize image grabbing
//
procedure TN_CMCaptDev5Form.InitGrab();
begin
end; // procedure TN_CMCaptDev5Form.InitGrab

// ********************************************* TN_CMCaptDev5Form.cb1Click ***
// Perform needed Actions on cb1 Click
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev5Form.cb1Click(Sender: TObject);
begin
{  inherited;
  InitGrab; }
end; procedure TN_CMCaptDev5Form.cbCalibrationClick(Sender: TObject);
begin
  inherited;

end;

// procedure TN_CMCaptDev5Form.cb1Click

// ************************************** TN_CMCaptDev5Form.CheckTimerTimer ***
// CheckTimer event handler
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev5Form.CheckTimerTimer(Sender: TObject);
begin
end; // procedure TN_CMCaptDev5Form.CheckTimerTimer

// **************************************** TN_CMCaptDev5Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev5Form.tbLeft90Click(Sender: TObject);
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev5Form.tbLeft90Click

// *************************************** TN_CMCaptDev5Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev5Form.tbRight90Click(Sender: TObject);
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev5Form.tbRight90Click

//************************************ TN_CMCaptDev5Form.CMOFCaptureSlide2D ***
// Capture Slide from file and show it, for 2D images
//
//     Parameters
// Image - image path
// Return 0 if OK
//
function TN_CMCaptDev5Form.CMOFCaptureSlide2D( Image: string ): Integer;
var
  i: Integer;
  CapturedDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
begin
  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format('Planmeca Start CMOFCaptureSlide %d', [CMOFNumCaptured]));

  CapturedDIB := Nil;
  N_LoadDIBFromFileByImLib( CapturedDIB, Image ); // new 8 or 16 bit variant

  // autocontrast
  //NDIB := Nil;
  //CapturedDIB.CalcMaxContrastDIB( NDIB );
  //CapturedDIB.Free();
  //CapturedDIB := NDIB;

  // negate
  //CapturedDIB.XORPixels( $FFFF );

  // flip vertical
  CapturedDIB.FlipVertical();
  // rotate 180
  CapturedDIB.Rotate180();

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

  N_Dump1Str( Format('Planmeca Fin CMOFCaptureSlide %d', [CMOFNumCaptured]) );
  Result := 0;
end;

// ************************************** TN_CMCaptDev5Form.TimerImageTimer ***
// Checking for intraoral images
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev5Form.TimerImageTimer( Sender: TObject );
var
  WrkFilesFolder: string;
  searchResult :  TSearchRec;
begin
  inherited;
  TimerImage.Enabled := False;

  WrkFilesFolder := K_ExpandFileName( '(#TmpFiles#)' );
  if FindFirst( WrkFilesFolder + 'Planmeca\*.tif', faAnyFile, searchResult ) = 0 then
  begin
    //CMOFStatus := 2;

    TimerImage.Enabled := False; // image found
    N_Dump1Str( 'Image path - ' + WrkFilesFolder + 'Planmeca\' +
                                                            searchResult.Name );
    CMOFCaptureSlide2D( WrkFilesFolder + 'Planmeca\' + searchResult.Name );
    if FileExists( WrkFilesFolder + 'Planmeca\' + searchResult.Name ) then
      DeleteFile( WrkFilesFolder + 'Planmeca\' + searchResult.Name );

    //CMOFStatus := 1;
    bnCapture.Enabled := True;
    bnCapture.OnClick(Nil); // auto capture
    Exit;
  end;

  TimerImage.Enabled := True;
end; // procedure TN_CMCaptDev5Form.TimerImageTimer

// ******************************************* TN_CMCaptDev5Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev5Form.tb180Click(Sender: TObject);
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev5Form.tb180Click

// *************************************** TN_CMCaptDev5Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev5Form.tbFlipHorClick(Sender: TObject);
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev5Form.tbFlipHorClick


// ****************  TN_CMCaptDev5Form class public methods  ************

// **************************************** TN_CMCaptDev5Form.CMOFDrawThumb ***
// Draw one Thumbnail (used as TN_DGridBase.DGDrawItemProcObj)
//
//     Parameters
// ADGObj  - DGrid Objects that handles Thumbnails DGrid
// AInd    - given Thumbnail one dimensional Index
// ARect   - Item Rectangle in DGRFrame Buf Pixel coords ( (0,0) means upper
// left Buf pixel and may be not equal to upper left Grid pixel )
//
// Is used as value of CMOFThumbsDGrid.DGDrawItemProcObj field
//
procedure TN_CMCaptDev5Form.CMOFDrawThumb(ADGObj: TN_DGridBase; AInd: integer;
  const ARect: TRect);
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev5Form.CMOFDrawThumb

// ************************************* TN_CMCaptDev5Form.CMOFGetThumbSize ***
// Get Thumbnail Size (used as TN_DGridBase.DGGetItemSizeProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - given Thumbnail Index
// AInpSize  - given Size on input, only one fileld (X or Y) should be <> 0
// AOutSize  - resulting Size on output, if AInpSize.X <> 0 then OutSize.Y <> 0,
// if AInpSize.Y <> 0 then OutSize.X <> 0
// AMinSize  - (on output) Minimal Size
// APrefSize - (on output) Preferable Size
// AMaxSize  - (on output) Maximal Size
//
// Is used as value of CMOFThumbsDGrid.DGGetItemSizeProcObj field
//
procedure TN_CMCaptDev5Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
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
end; // procedure TN_CMCaptDev5Form.CMOFGetThumbSize

// **************************************** TN_CMCaptDev5Form.CMOFSetStatus ***
// Set and Show current Device (Form) status
//
//     Parameters
// AIntStatus - given Status (one of N_CMOF4xxx constants)
//
procedure TN_CMCaptDev5Form.CMOFSetStatus( AIntStatus: Integer );
begin
end; // end of TN_CMCaptDev5Form.CMOFSetStatus

// ************************************* TN_CMCaptDev5Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev5Form.CMOFCaptureSlide(): Integer;
begin
  Result := 0;
end; // end of TN_CMCaptDev5Form.CMOFCaptureSlide

// ************************************* TN_CMCaptDev5Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev5Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev5Form.CurStateToMemIni

// ************************************* TN_CMCaptDev5Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev5Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev5Form.MemIniToCurState

{$ELSE} //************** no code in Delphi 7
implementation
{$ENDIF VER150} //****** no code in Delphi 7

end.
