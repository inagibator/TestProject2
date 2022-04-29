unit N_CMCaptDev21SF;
// Form for capture Images from Schick 2 CDR Devices

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1,
  ComCtrls, ToolWin, ImgList;

type // needs for a status bar actions
  N_MyTrackBar = class( TTrackBar )
  published
    property OnMouseUp;
end;

type TN_CMCaptDev21Form = class( TN_BaseForm )
    MainPanel:    TPanel;
    RightPanel:   TPanel;
    SlidePanel:   TPanel;
    bnExit:       TButton;
    ThumbsRFrame: TN_Rast1Frame;
    SlideRFrame:  TN_Rast1Frame;
    CheckTimer:   TTimer;
    CtrlsPanelParent: TPanel;
    CtrlsPanel: TPanel;
    StatusLabel: TLabel;
    StatusShape: TShape;
    bnSetup: TButton;
    cbRaw: TCheckBox;
    PanelFilter: TPanel;
    lbSharp: TLabel;
    rbModeA: TRadioButton;
    rbModeB: TRadioButton;
    TrackBar1: TTrackBar;
    cbMapping: TComboBox;
    tbRotateImage: TToolBar;
    tbLeft90: TToolButton;
    tbRight90: TToolButton;
    tb180: TToolButton;
    tbFlipHor: TToolButton;
    bnImport: TButton;
    cbAutoTake: TCheckBox;
    bnCapture: TButton;

    //****************  TN_CMCaptDev4Form class handlers  ******************

    procedure FormShow         ( Sender: TObject );
    procedure FormClose        ( Sender: TObject; var Action: TCloseAction );
                                                                       override;
    procedure FormKeyDown      ( Sender: TObject; var Key: Word; Shift:
                                                                  TShiftState );
    procedure FormKeyUp        ( Sender: TObject; var Key: Word; Shift:
                                                                  TShiftState );
    procedure bnSetupClick     ( Sender: TObject );
    procedure SlidePanelResize ( Sender: TObject );
    procedure CheckTimerTimer  ( Sender: TObject );
    procedure bnCaptureClick   ( Sender: TObject );
    procedure cbAutoTakeClick  ( Sender: TObject );
    procedure bnInitXrayDeviceClick ( Sender: TObject );
    procedure tbLeft90Click    ( Sender: TObject );
    procedure tbRight90Click   ( Sender: TObject );
    procedure tb180Click       ( Sender: TObject );
    procedure tbFlipHorClick   ( Sender: TObject );
    procedure bnImportClick     ( Sender: TObject );
    procedure rbModeAClick     ( Sender: TObject );
    procedure rbModeBClick     ( Sender: TObject );
    procedure cbMappingChange  ( Sender: TObject );
    procedure TrackBar1Change  ( Sender: TObject );
  public
    CMOFThumbsDGrid:  TN_DGridArbMatr;   // DGrid for handling Thumbnails in ThumbsRFrame
    CMOFDrawSlideObj: TN_CMDrawSlideObj; // Object with Attributes for Drawing Thumbnails (jn CMOFDrawThumb)
    CMOFPNewSlides:   TN_PUDCMSArray;    // Pointer to Array of New captured Slides
    CMOFAnsiFName:    AnsiString;        // Image (created by driver) Full File Name
    CMOFPProfile:     TK_PCMOtherProfile;// Pointer to Device Profile
    CMOFDeviceIndex:  integer;           // Device Index in ECDevices Array

    CMOFNumCaptured:   integer;          // Number of Captured Slides
    CMOFCurIntStatus:  integer;          // Current Device (Form) Status
    CMOFCurTmpStatus:  integer;          // Current Sensor Status (temporary)
    CMOFNumTEvents:    integer;          // Number of Timer Events passed
    CMOFStartClosing:  integer;          // Saved value of CMOFNumTEvents when start closing scanner
    CMOFOKToCloseForm: boolean;          // Scanner was Closed OK and Form can be Closed
    CMOFAutoTake:      boolean;          // Auto Take mode
    CMOFFatalError:    boolean;          // Fatal error occured, Form should be closed
    CMOFInitError:     boolean;          // Initialization error occured, just wait for closing form by user
    CMOFInitDeviceError: boolean;        // result of N_CMECDInitXrayDevice is not eSUCCESS
    CMOFSavedNumTEvents: integer;        // Saved Number of Timer Events passed simce N_CMECDInitXrayDevice<>eSUCCESS
    CMOFDevID:           integer;        // Device ID for N_CMECDInitXrayDevice

    // variable is not needed as we use replace function, not deleting and then creating one
    // CMOFNewSlide: TN_UDCMSlide;   // image slide
    CMOFRawFilteredFlag: Boolean;        // is raw image was filtered yet
    CMOFInitFlag:        Boolean;        // is initialization completed
    CMOFProcFlag:        Boolean;        // is processing

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const
                                                                 ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                                 AInpSize: TPoint; out AOutSize, AMinSize,
                                                  APrefSize, AMaxSize: TPoint );
    procedure CMOFSetStatus    ( AIntStatus: integer );
    function  CMOFImportSlide  (): integer;
    function  CMOFAcquireSlide (): integer;
    function  CMOFCaptureSlide ( FilterBool: Boolean; Bmp: TBitmap ): integer;

    // for trackbar
    procedure CMOFMouseUp ( Sender: TObject; Button: TMouseButton; Shift:
                                                   TShiftState; X, Y: Integer );

    procedure CMOFFilterImage ( FilterLevel: Integer );

    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMCaptDev4Form = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

const // Form states
  N_CMOF4Disconnected = 0;
  N_CMOF4Ready        = 1;
  N_CMOF4Error        = 2;

implementation
uses math,
 K_CLib0, K_Parse, K_Script1,
 N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev21S,
  N_CML2F;
{$R *.dfm}

//****************  TN_CMCaptDev4Form class handlers  ******************

//********************************************* TN_CMCaptDev21Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev21Form.FormShow( Sender: TObject );
var
  ResCode: Integer;
begin
  N_Dump1Str( 'Schick 2 Start FormShow' );

  //***** initial settings

  CMOFInitFlag      := False;
  CMOFRawFilteredFlag := False;
  rbModeA.Enabled   := False;
  rbModeB.Enabled   := False;
  cbMapping.Enabled := False;
  lbSharp.Enabled   := False;
  TrackBar1.Enabled := False;

  if CMOFPProfile.CMDPStrPar2 = '' then
    CMOFPProfile.CMDPStrPar2 := '02050'; // default

  //***** initial filtering modes
  if CMOFPProfile.CMDPStrPar2[1] = '0' then
  begin
    rbModeA.Checked := True;
    rbModeB.Checked := False;
  end
  else
  begin
    rbModeB.Checked := True;
    rbModeA.Checked := False;
  end;

  cbMapping.ItemIndex := StrToInt( CMOFPProfile.CMDPStrPar2[2] );

  TrackBar1.Position := StrToInt( Copy( CMOFPProfile.CMDPStrPar2, 3, 3) );

  N_MyTrackBar(TrackBar1).OnMouseUp := CMOFMouseUp;

  Caption := Format ( N_CML2Form.LLLOtherFormCaption.Caption,
                                                  [CMOFPProfile^.CMDPCaption] );
  tbRotateImage.Images := N_CM_MainForm.CMMCurBigIcons;
  CMOFDrawSlideObj := TN_CMDrawSlideObj.Create(); // used in jn CMOFDrawThumb for Drawing Thumbnails
  CMOFThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, CMOFGetThumbSize );

  case CMOFDeviceIndex of // set CMOFDevID
    N_CMECD_CDR_XRAY: CMOFDevID := eCDR_XRAY;
    N_CMECD_CDR_CEPH: CMOFDevID := eCDR_CEPH;
    N_CMECD_CDR_PANO: CMOFDevID := eCDR_PANO;
  else
    CMOFDevID := -1; // to avoid worning
    Assert( False, 'Bad CMOFDeviceIndex!' );
  end; // case CMOFDeviceIndex of // set CMOFDevID

  ResCode := N_CMECDInitXrayDevice( CMOFDevID );
  N_Dump1Str( Format( 'bnInitXrayDeviceClick After N_CMECDInitXrayDevice ResCode=%d (DevInd=%d,DsdErr=%d)',
                      [ResCode,CMOFDeviceIndex, N_CMCDServObj21.CDSErrorInt] ));
  if ResCode <> eSUCCESS then // Initialization error
    CMOFSetStatus( -100 );

  //***** cbAutoTake.Checked Design time value is False.

  if CMOFDeviceIndex <> N_CMECD_CDR_XRAY then // N_CMECD_CDR_CEPH or N_CMECD_CDR_PANO
  begin                                       // AutoTake mode is NOT supported
    cbAutoTake.Enabled := False;
  end else // N_CMECD_CDR_XRAY - AutoTake mode is supported
  begin
    cbAutoTake.Checked := True;
    cbAutoTake.Enabled := True;
  end;

  N_Dump1Str( 'AutoTake is ' + BoolToStr(cbAutoTake.Checked) );

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
    RFCenterInDst  := True;
    RFrShowComp( nil );
  end; // with SlideRFrame do

  CMOFInitFlag := True; // initialized

  if N_MemIniToString( 'CMS_UserDeb', 'Schick2Import', '' ) = 'TRUE' then
    bnImport.Visible := TRUE;

  CheckTimer.Enabled := True;
  N_Dump1Str( 'Schick End FormShow' );
end; // procedure TN_CMCaptDev4Form.FormShow

//******************************************** TN_CMCaptDev21Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev21Form.FormClose( Sender: TObject; var Action:
                                                                 TCloseAction );
begin
  CheckTimer.Enabled := False;
  if CMOFNumCaptured <> 0 then
  begin
    // K_CMEDAccess.EDAAddSlide is not needed, since all done in K_CMSlideCreateFromDeviceDIBObj
    // K_CMEDAccess.EDAAddSlide( CMOFNewSlide ); // from now on NewSlide is owned by K_CMEDAccess
    N_CMECDClean(0);
  end;

  N_CMECDClose;

  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  //***** save settings
  if rbModeA.Checked then
    CMOFPProfile.CMDPStrPar2[1] := '0'
  else
    CMOFPProfile.CMDPStrPar2[1] := '1';

  CMOFPProfile.CMDPStrPar2[2] := IntToStr( cbMapping.ItemIndex )[1];

  if TrackBar1.Position = 100 then // 3 digits
  begin
    CMOFPProfile.CMDPStrPar2[3] := IntToStr( TrackBar1.Position )[1];
    CMOFPProfile.CMDPStrPar2[4] := IntToStr( TrackBar1.Position )[2];
    CMOFPProfile.CMDPStrPar2[5] := IntToStr( TrackBar1.Position )[3];
  end
  else
  if TrackBar1.Position = 0 then // 0 digits
  begin
    CMOFPProfile.CMDPStrPar2[3] := '0';
    CMOFPProfile.CMDPStrPar2[4] := '0';
    CMOFPProfile.CMDPStrPar2[5] := '0';
  end
  else
  if TrackBar1.Position < 10 then // 1 digit
  begin
    CMOFPProfile.CMDPStrPar2[3] := '0';
    CMOFPProfile.CMDPStrPar2[4] := '0';
    CMOFPProfile.CMDPStrPar2[5] := IntToStr( TrackBar1.Position )[1];
  end
  else // 2 digits
  begin
    CMOFPProfile.CMDPStrPar2[3] := '0';
    CMOFPProfile.CMDPStrPar2[4] := IntToStr( TrackBar1.Position )[1];
    CMOFPProfile.CMDPStrPar2[5] := IntToStr( TrackBar1.Position )[2];
  end;

  N_CMCDServObj21.CDSFreeAll();

  Inherited;

end; // procedure TN_CMCaptDev21Form.FormClose

//***** not implemented
procedure TN_CMCaptDev21Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// now empty
begin
  if Key = VK_F8 then // Close Self
  begin
  end; // if Key = VK_F9 then

//    CMOFSetStatus( N_CMOF4Scanning );
end; // procedure TN_CMCaptDev21Form.FormKeyDown

procedure TN_CMCaptDev21Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev21Form.FormKeyUp

//***************************************** TN_CMCaptDev21Form.bnSetupClick ***
// settings
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev21Form.bnSetupClick( Sender: TObject );
// Show Setup dialog
var
  ResCode: integer;
begin
  ResCode := N_CMECDShowPropertiesDialog();

  if ResCode <> eSUCCESS then
    N_Dump1Str( Format( 'N_CMECDShowPropertiesDialog Error=(%d)', [ResCode] ) );
end; // procedure TN_CMCaptDev21Form.bnSetupClick

//***** not used, keep for debugging
procedure TN_CMCaptDev21Form.bnImportClick(Sender: TObject);
var
  ResCode: integer;
begin
  N_Dump1Str( 'Start bnImportClick' );

  if cbRaw.Checked then
    CMOFRawFilteredFlag := False;

  ResCode := CMOFImportSlide();

  if ResCode <> 0 then
  begin
    N_Dump1Str( Format( 'bnImportClick error - ResCode=%d', [ResCode] ) );
    Exit;
  end;

  if not cbRaw.Checked then
    CMOFFilterImage( 0 );

  rbModeA.Enabled := True;
  rbModeB.Enabled := True;
  cbMapping.Enabled := True;
  lbSharp.Enabled   := True;
  TrackBar1.Enabled := True;

  if not cbAutoTake.Checked then
    bnCapture.Enabled := True;

  bnExit.Enabled := True;
  Screen.Cursor  := crDefault;

  CMOFProcFlag := False;

  N_Dump1Str( 'Finish bnImportClick' );
end;

//************************************* TN_CMCaptDev21Form.SlidePanelResize ***
// slide panel resizing
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev21Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if CMOFPNewSlides = nil then Exit; // no Slide to Redraw
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw

  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev21Form.SlidePanelResize

//************************************** TN_CMCaptDev21Form.CheckTimerTimer ***
// timer behaviour
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev21Form.CheckTimerTimer( Sender: TObject );
// Check Image Status in all modes and Capture Image if possible in Auto mode
var
  ResCode, Delta: integer;
  Label Fin;
begin
  if not CheckTimer.Enabled then
  begin
    N_Dump1Str( '!!!Schick CheckTimer is disabled' );
    Exit; // precaution
  end;

  ResCode := 101; // not initialized flag
  Delta := 10;
  CheckTimer.Enabled := False; // to prevent events inside CheckTimerTimer

  Inc( CMOFNumTEvents ); // whole number of CheckTimer Events received (for checking timeouts)
  N_Dump1Str( Format( 'Schick CheckTimer Start, CMOFNumTEvents=%d',
                                                           [CMOFNumTEvents] ) );

  if CMOFFatalError then // Fatal error occured, Form should be closed
  begin
    N_Dump1Str( 'Schick CheckTimer Close1 CMOFFatalError' );
    Close();
    N_Dump1Str( 'Schick CheckTimer Close2 CMOFFatalError' );
    Exit;
  end; // if CMOFFatalError then // Fatal error occured, Form should be closed

  if CMOFInitDeviceError then // result of N_CMECDInitXrayDevice is not eSUCCESS
  begin
    N_Dump1Str( Format( 'Schick CheckTimer ReInit, N=%d, N+Delta=%d',
                               [CMOFNumTEvents,(CMOFSavedNumTEvents+Delta)] ) );

    if CMOFNumTEvents < (CMOFSavedNumTEvents + Delta) then // just wait
      goto Fin;

    // Try to reinitialize Device

    N_Dump1Str( Format( 'Schick CheckTimer Before InitXrayDevice, CMOFDevID=%d',
                                                                [CMOFDevID] ) );
    N_Dump1Str( 'Schick CheckTimer After InitXrayDevice' );

    N_Dump1Str( Format( 'Schick N_CMECDInitXrayDevice ResCode=%d (DevInd=%d,DsdErr=%d)',
                       [ResCode,CMOFDeviceIndex,N_CMCDServObj21.CDSErrorInt] ));

    if ResCode <> eSUCCESS then // again Initialization error
    begin
      CMOFSavedNumTEvents := CMOFNumTEvents; // continue waiting
      goto Fin;
    end; // if ResCode <> eSUCCESS then // again Initialization error

    CMOFInitDeviceError := False; // return to normal mode
  end; // if CMOFInitDeviceError then // result of N_CMECDInitXrayDevice is not eSUCCESS

  N_Dump1Str( 'Schick CheckTimer 0' );
  CMOFCurTmpStatus := N_CMECDGetSchickImageStatus(); // >= 21
  N_Dump1Str( Format( 'Schick CheckTimer 1, CMOFCurTmpStatus=%d',
                                                         [CMOFCurTmpStatus] ) );

  if (CMOFCurTmpStatus = AA_NO_HARDWARE)  or   // =  1; // No Sensor attached
     (CMOFCurTmpStatus = AA_NO_FIRMWARE)  or   // =  2; // Firmware not loaded in USB Remote
     (CMOFCurTmpStatus = AA_WRONG_SENSOR) or   // =  3; // Sensor does not support Auto Acquire
     (CMOFCurTmpStatus = AA_BAD_FIRMWARE) then // =  4; // Firmware is corrupt or is an old version that does not support Auto Acquire
  begin
    CMOFSavedNumTEvents := CMOFNumTEvents; // wait for Delta events before trying to reinitialized

    CMOFSetStatus( CMOFCurTmpStatus );
    goto Fin;
  end;

  CMOFSetStatus( CMOFCurTmpStatus );

  if CMOFCurTmpStatus = AA_IMAGE_AVAILABLE then // auto image available
  begin
    ResCode := CMOFAcquireSlide();

    if ResCode = 0 then // image is ok
    begin
      if not cbRaw.Checked then // try to filter even if not supported
        CMOFFilterImage( 0 );

      bnExit.Enabled := True;
      Screen.Cursor  := crDefault;

      CMOFProcFlag := False;
    end;

    if ResCode <> 0 then
    begin
      K_CMShowMessageDlg( 'Acquiring Image Error (Auto)', mtError );
      N_Dump1Str( Format( 'CheckTimerTimer error - ResCode=%d', [ResCode] ) );
    end;
  end; // if CMOFCurStatus = AA_IMAGE_AVAILABLE then

  Fin: //**********
  N_Dump1Str( Format( 'Schick CheckTimer Fin, CMOFNumTEvents=%d',
                                                           [CMOFNumTEvents] ) );
  CheckTimer.Enabled := True;
end; // procedure TN_CMCaptDev21Form.CheckTimerTimer

//*************************************** TN_CMCaptDev21Form.CMOFFilterImage ***
// Filtering captured image
//
//     Parameters
// FilterLevel - how deep does it needs to be changed (3 levels)
//
procedure TN_CMCaptDev21Form.CMOFFilterImage( FilterLevel: Integer );
var
  ModeInt, ResInt: Integer;
  MappingMode:  UInt;
  Bmp:          TBitmap;
  BitmapHandle: HBITMAP;
begin
  inherited;
  N_Dump1Str( 'Start Filter' );

  ResInt := 0;
  CMOFProcFlag := True;
  CMOFSetStatus( CMOFCurTmpStatus );

  rbModeA.Enabled   := False;
  rbModeB.Enabled   := False;
  cbMapping.Enabled := False;
  lbSharp.Enabled   := False;
  TrackBar1.Enabled := False;

  bnCapture.Enabled := False;
  bnExit.Enabled    := False;

  Screen.Cursor := crHourGlass;

  N_Dump1Str( 'Before sharp' );
  N_CMECDSetSharp( TrackBar1.Position/TrackBar1.Max );
  N_Dump1Str( 'After sharp' );

  if FilterLevel = 0 then
  begin // mode a/b changed
    N_Dump1Str( 'Before clean 1' );
    N_CMECDClean(1);
    N_Dump1Str( 'Before clean 2' );

    case cbMapping.ItemIndex of
      0: MappingMode := 32772; // ID_VIEW_ENDODONTIC;
      1: MappingMode := 32773; // ID_VIEW_PERIODONTIC;
      2: MappingMode := 32774; // ID_VIEW_GENERAL;
      3: MappingMode := 32775; // ID_VIEW_CARIES;
      else MappingMode := 32777; // ID_VIEW_HYGIENE;
    end;

    if rbModeA.Checked then
      ModeInt := 0
    else
      ModeInt := 1;

    N_Dump1Str( 'Before process' );
    ResInt := N_CMECDProcessImage( ModeInt, MappingMode, @N_ImageStruct );
    N_Dump1Str( 'After process, ResInt = ' + IntToStr(ResInt) );

  end; // filter 0 (a/b)

  if FilterLevel = 1 then // mapping changed
  begin
    case cbMapping.ItemIndex of
    0: MappingMode := 32772; // ID_VIEW_ENDODONTIC;
    1: MappingMode := 32773; // ID_VIEW_PERIODONTIC;
    2: MappingMode := 32774; // ID_VIEW_GENERAL;
    3: MappingMode := 32775; // ID_VIEW_CARIES;
    else MappingMode := 32777; // ID_VIEW_HYGIENE;
    end;

    N_Dump1Str( 'Before clean 2' );
    N_CMECDClean( 2 );
    N_Dump1Str( 'Before mapping' );
    ResInt := N_CMECDOnMaximusMapping( MappingMode, @N_ImageStruct );
    N_Dump1Str( 'After mapping' );
  end;

  if FilterLevel = 2 then // sharp/smooth changed
  begin
    N_Dump1Str( 'Before mix' );
    ResInt := N_CMECDMix( @N_ImageStruct );
    N_Dump1Str( 'After mix' );
  end;

  N_Dump1Str( 'Bitmap handle = ' + IntToStr(N_ImageStruct.IPIHBitmap) +
                ', width = ' + IntToStr(N_ImageStruct.IPWidth) + ', height = ' +
                                             IntToStr(N_ImageStruct.IPHeigth) );

  //***** creating bitmap using it's handle
  BitmapHandle := HBITMAP( N_ImageStruct.IPIHBitmap );
  Bmp := TBitmap.Create();
  Bmp.Handle := BitmapHandle;
  // in case we need to check the image
  //Bmp.SaveToFile('D:/image.bmp');

  if ResInt <> 27 then // 27 is the result when filtering is not supported (schick elite sensor)
  begin
    CMOFCaptureSlide( True, Bmp );
  end;

  Bmp.Free;

  if ResInt = 27 then // disabling interface
  begin
    rbModeA.Enabled := False;
    rbModeB.Enabled := False;
    cbMapping.Enabled := False;
    lbSharp.Enabled   := False;
    TrackBar1.Enabled := False;

    if not cbAutoTake.Checked then
      bnCapture.Enabled := True;

    bnExit.Enabled := True;
    Screen.Cursor  := crDefault;

    CMOFProcFlag := False;
  end
  else // enabling interface
  begin
    rbModeA.Enabled := True;
    rbModeB.Enabled := True;
    cbMapping.Enabled := True;
    lbSharp.Enabled   := True;
    TrackBar1.Enabled := True;

  if not cbAutoTake.Checked then
    bnCapture.Enabled := True;

    bnExit.Enabled := True;
    Screen.Cursor  := crDefault;

    CMOFProcFlag := False;
  end;

  N_Dump1Str( 'Finish Filter' );
end; // procedure TN_CMCaptDev21Form.CMOFFilterImage

//*************************************** TN_CMCaptDev21Form.bnCaptureClick ***
// Capture Image in not CMOFAutoTake mode
//
//     Parameters
// Sender - Event Sender
//
// bnCapture button OnClick handler
//
procedure TN_CMCaptDev21Form.bnCaptureClick( Sender: TObject );
var
  ResCode: integer;
begin
  N_Dump1Str( 'Start bnCaptureClick' );
  bnCapture.Enabled := False;
  bnExit.Enabled    := False;

  if cbRaw.Checked then
    CMOFRawFilteredFlag := False;

  ResCode := CMOFAcquireSlide();

  if ResCode <> 0 then
  begin
    N_Dump1Str( Format( 'bnCaptureClick error - ResCode=%d', [ResCode] ) );
    Exit;
  end;

  if not cbRaw.Checked then // filter, try even if not supported
    CMOFFilterImage( 0 );

  bnExit.Enabled := True;
  Screen.Cursor  := crDefault;

  CMOFProcFlag := False;

  N_Dump1Str( 'Finish bnCaptureClick' );
end; // procedure TN_CMCaptDev21Form.bnCaptureClick

//************************************** TN_CMCaptDev21Form.cbAutoTakeClick ***
// Toggle CMOFAutoTake mode
//
//     Parameters
// Sender - Event Sender
//
// cbAutoTake Checkbox OnClick handler
//
procedure TN_CMCaptDev21Form.cbAutoTakeClick( Sender: TObject );
var
  ResCode: integer;
begin
  CMOFAutoTake := cbAutoTake.Checked;
  N_Dump1Str( Format( 'cbAutoTakeClick Checked=%s', [N_B2S(CMOFAutoTake)] ) );

  if CMOFAutoTake then // AutoTake mode
  begin
    bnCapture.Enabled  := False;

    ResCode := N_CMECDSetAutoAcquire( 1 );

    if ResCode <> eSUCCESS then
    begin
      bnCapture.Enabled  := True;
      N_Dump1Str( Format( 'SetAutoAcquire( 1 ) error - ResCode=%d',
                                                                  [ResCode] ) );
    end;
  end else // CMOFAutoTake=False, Manual mode
  begin
    bnCapture.Enabled  := True;

    ResCode := N_CMECDSetAutoAcquire( 0 );

    if ResCode <> eSUCCESS then
    begin
      N_Dump1Str( Format( 'SetAutoAcquire( 0 ) error - ResCode=%d',
                                                                  [ResCode] ) );
    end;

  end; // else // CMOFAutoTake=False, Manual mode
end; // procedure TN_CMCaptDev21Form.cbAutoTakeClick

procedure TN_CMCaptDev21Form.bnInitXrayDeviceClick( Sender: TObject );
  // Try to reinitialize Device Manually
var
  ResCode: integer;
begin
  N_Dump1Str( Format(
                    'bnInitXrayDeviceClick Before InitXrayDevice, CMOFDevID=%d',
                                                                [CMOFDevID] ) );
  ResCode := N_CMECDInitXrayDevice( CMOFDevID );
  N_Dump1Str( Format(
  'bnInitXrayDeviceClick After N_CMECDInitXrayDevice ResCode=%d (DevInd=%d,DsdErr=%d)',
                       [ResCode,CMOFDeviceIndex,N_CMCDServObj21.CDSErrorInt] ));
end; // procedure TN_CMCaptDev21Form.bnInitXrayDeviceClick

//***************************************** TN_CMCaptDev21Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree countercloclwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev21Form.tbLeft90Click( Sender: TObject );
begin
  N_Dump1Str('1');
  if CMOFNumCaptured <= 0 then Exit;

  N_Dump1Str('2');
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );

  N_Dump1Str('3');
  CMOFThumbsDGrid.DGInitRFrame();
  N_Dump1Str('4');
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  N_Dump1Str('5');
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
  N_Dump1Str('6');
end; // procedure TN_CMCaptDev21Form.tbLeft90Click

//**************************************** TN_CMCaptDev21Form.tbRight90Click ***
// Rotate last captured Image by 90 degree cloclwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev21Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end;

//***** not implemented
procedure TN_CMCaptDev21Form.TrackBar1Change(Sender: TObject);
begin
  inherited;
end; // procedure TN_CMCaptDev21Form.tbRight90Click

//****************************************** TN_CMCaptDev21Form.CMOFMouseUp ***
// For TrackBar actions
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev21Form.CMOFMouseUp( Sender: TObject; Button: TMouseButton;
                                            Shift: TShiftState; X, Y: Integer );
begin
  if CMOFInitFlag then // if initialized
  begin
    if cbRaw.Checked and not CMOFRawFilteredFlag then
    begin
      CMOFFilterImage( 0 );
      CMOFRawFilteredFlag := True;
    end
    else
      CMOFFilterImage( 2 );
  end;
end; // procedure TN_CMCaptDev21Form.CMOFMouseUp

//******************************************** TN_CMCaptDev21Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev21Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev21Form.tb180Click

//**************************************** TN_CMCaptDev21Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev21Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev21Form.tbFlipHorClick

//****************  TN_CMCaptDev21Form class public methods  ************

//***************************************** TN_CMCaptDev21Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev21Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length(CMOFPNewSlides^)-AInd] );

    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                    CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev21Form.CMOFDrawThumb

//************************************** TN_CMCaptDev21Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev21Form.CMOFGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide :    TN_UDCMSlide;
  ThumbDIB:  TN_UDDIB;
  ThumbSize: TPoint;
begin
  with N_CM_GlobObj, ADGObj do
  begin
    Slide := CMOFPNewSlides^[AInd];
    ThumbDIB := Slide.GetThumbnail();
    ThumbSize := ThumbDIB.DIBObj.DIBSize;

    AOutSize := Point(0,0);
    if AInpSize.X > 0 then // given is AInpSize.X
      AOutSize.Y := Round( AInpSize.X*ThumbSize.Y/ThumbSize.X ) + DGLAddDySize
    else // AInpSize.X = 0, given is AInpSize.Y
      AOutSize.X := Round( (AInpSize.Y-DGLAddDySize)*ThumbSize.X/ThumbSize.Y );

    AMinSize  := Point(10,10);
    APrefSize := ThumbSize;
    AMaxSize  := Point(1000,1000);
  end; // with N_CM_GlobObj. ADGObj do
end; // procedure TN_CMCaptDev21Form.CMOFGetThumbSize

//***************************************** TN_CMCaptDev21Form.CMOFSetStatus ***
// Set and Show current Device (Form) status
//
//     Parameters
// AIntStatus - given Status (one of N_CMOF4xxx constants)
//
procedure TN_CMCaptDev21Form.CMOFSetStatus( AIntStatus: integer );
begin
  CMOFCurIntStatus := AIntStatus;
//  N_Dump1Str( Format( 'Schick CMOFSetStatus AIntStatus=%d', [AIntStatus] ) );

  if CMOFProcFlag then
  begin
    StatusLabel.Caption := 'Processing';
    StatusLabel.Font.Color  := clBlue;
    StatusShape.Pen.Color   := clBlue;
    StatusShape.Brush.Color := clBlue;
  end
  else
  case AIntStatus of

  -100: begin // =-100 - CMOFInitDeviceError=True
    StatusLabel.Caption := 'Device initialization error';
    StatusLabel.Font.Color  := clBlack;
    StatusShape.Pen.Color   := clBlack;
    StatusShape.Brush.Color := clBlack;
  end; // -100: begin // =-100 - CMOFInitDeviceError=True

  AA_NO_AUTO_ACQUIRE: begin // =0
    StatusLabel.Caption := 'Autotake not supported';
    StatusLabel.Font.Color  := clBlack;
    StatusShape.Pen.Color   := clBlack;
    StatusShape.Brush.Color := clBlack;
  end; // AA_NO_AUTO_ACQUIRE: begin // =0

  AA_NO_HARDWARE: begin // =1
    StatusLabel.Caption := 'Device disconnected';
    StatusLabel.Font.Color  := clRed;
    StatusShape.Pen.Color   := clRed;
    StatusShape.Brush.Color := clRed;
  end; // AA_NO_HARDWARE: begin // =1

  AA_NO_FIRMWARE: begin // =2
    StatusLabel.Caption := 'Firmware not loaded';
    StatusLabel.Font.Color  := clRed;
    StatusShape.Pen.Color   := clRed;
    StatusShape.Brush.Color := clRed;
  end; // AA_NO_FIRMWARE: begin // =2

  AA_WRONG_SENSOR: begin // =3
    StatusLabel.Caption := 'Auto acquire not supported';
    StatusLabel.Font.Color  := clRed;
    StatusShape.Pen.Color   := clRed;
    StatusShape.Brush.Color := clRed;
  end; // AA_WRONG_SENSOR: begin // =3

  AA_BAD_FIRMWARE: begin // =4
    StatusLabel.Caption := 'Firmware is corrupted';
    StatusLabel.Font.Color  := clRed;
    StatusShape.Pen.Color   := clRed;
    StatusShape.Brush.Color := clRed;
  end; // AA_BAD_FIRMWARE: begin // =4

  AA_IMAGE_AVAILABLE, // = 5
  AA_NOT_READY: begin // =6
    StatusLabel.Caption := N_CML2Form.LLLOther4Processing.Caption;
    StatusLabel.Font.Color  := clBlue;
    StatusShape.Pen.Color   := clBlue;
    StatusShape.Brush.Color := clBlue;
  end; // AA_IMAGE_AVAILABLE, AA_NOT_READY: begin // =5, 6

  AA_TRIGGERING: begin // = 7
    StatusLabel.Caption := N_CML2Form.LLLOther4Ready.Caption;
    StatusLabel.Caption := 'Sensor ready';
    StatusLabel.Font.Color  := clGreen;
    StatusShape.Pen.Color   := clGreen;
    StatusShape.Brush.Color := clGreen;
  end; // N_CMOF4Unknown: begin

  else begin // all other codes
    StatusLabel.Caption := Format( 'Device error. Error code = %d', [AIntStatus] );
    StatusLabel.Font.Color  := clRed;
    StatusShape.Pen.Color   := clRed;
    StatusShape.Brush.Color := clRed;
  end; // N_CMOF4Manual: begin

  end; // case AIntStatus of

  StatusLabel.Repaint;
  StatusShape.Repaint;
end; // end of TN_CMCaptDev21Form.CMOFSetStatus

//*************************************** TN_CMCaptDev21Form.cbMappingChange ***
// CheckBox Mapping changed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev21Form.cbMappingChange( Sender: TObject );
begin
  if CMOFInitFlag then
  begin
    if cbRaw.Checked and not CMOFRawFilteredFlag then
    begin
      CMOFFilterImage( 0 );
      CMOFRawFilteredFlag := True;
    end
    else
      CMOFFilterImage( 1 );
  end;
end; // procedure TN_CMCaptDev21Form.cbMappingChange

//************************************** TN_CMCaptDev21Form.CMOFCaptureSlide ***
// Capture image
//
//     Parameters
// FilterBool - is raw
// Bmp - image bitmap
// Return 0 if OK
//
function TN_CMCaptDev21Form.CMOFCaptureSlide( FilterBool: Boolean;
                                                        Bmp: TBitmap ): integer;
var
  i:           Integer;
  OnePixSize:  Integer;
  CapturedDIB: TN_DIBObj;
  RootComp:    TN_UDCompVis;
begin
  N_Dump1Str( Format( 'Schick Start CMOFCaptureSlide %d', [CMOFNumCaptured] ) );

  //OnePixSize := -123;
  OnePixSize := N_CMECDGetMicronsPerPixel();
  N_Dump1Str( 'Schick after N_CMECDGetMicronsPerPixel ' + IntToStr(OnePixSize) );

  if OnePixSize <= 0 then // error in image
  begin
    Dec( CMOFNumCaptured ); // return slides num back
    N_Dump1Str( 'OnePixSize <= 0, this image is blocked' );

    rbModeA.Enabled   := False;
    rbModeB.Enabled   := False;
    cbMapping.Enabled := False;
    lbSharp.Enabled   := False;
    TrackBar1.Enabled := False;

    bnCapture.Enabled := False;
    K_CMShowMessageDlg1( 'Received image is not valid', mtError );
    Result := -1;
  end
  else // valid image
  begin

    CapturedDIB := TN_DIBObj.Create(Bmp);

    if CapturedDIB.DIBExPixFmt = epfGray16 then
      CapturedDIB.SetDIBNumBits( 12 );

    CapturedDIB.DIBInfo.bmi.biXPelsPerMeter := 1000000 div OnePixSize;
    CapturedDIB.DIBInfo.bmi.biYPelsPerMeter := CapturedDIB.DIBInfo.bmi.biXPelsPerMeter;

    N_Dump1Str( 'CapturedDIB Handle' + IntToStr(CapturedDIB.DIBHandle) +
                                    ', X = ' + IntToStr(CapturedDIB.DIBSize.X) +
                                   ', Y = ' + IntToStr(CapturedDIB.DIBSize.Y) );

    if not FilterBool then // if only filtering
    begin
      SetLength( CMOFPNewSlides^, CMOFNumCaptured );
      for i := High(CMOFPNewSlides^) downto 1 do // Shift all elems by 1
        CMOFPNewSlides^[i] := CMOFPNewSlides^[i-1];
      CMOFPNewSlides^[0] := K_CMSlideCreateFromDeviceDIBObj( CapturedDIB, TK_PCMDeviceProfile(CMOFPProfile), CMOFNumCaptured, 0 );
      Inc( CMOFThumbsDGrid.DGNumItems );
      N_Dump1Str( Format( 'Schick Fin Capture new Slide %d', [CMOFNumCaptured] ) );
    end
    else // edited image
    begin
      // using replace, not creating another one
      K_CMSlideReplaceByDeviceDIBObj( CMOFPNewSlides^[0], CapturedDIB, TK_PCMDeviceProfile(CMOFPProfile), CMOFNumCaptured, 0 );
      N_Dump1Str( Format( 'Schick Fin Filter Slide %d', [CMOFNumCaptured] ) );
    end;

    // SetAutoCalibrated is not needed, since all done in K_CMSlideCreateFromDeviceDIBObj
    // CMOFNewSlide.SetAutoCalibrated();

    CMOFPNewSlides^[0].ObjAliase := IntToStr( CMOFNumCaptured );

    CMOFThumbsDGrid.DGInitRFrame();
    CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

    // Show NewSlide in SlideRFrame
    RootComp := CMOFPNewSlides^[0].GetMapRoot();
    SlideRFrame.RFrShowComp( RootComp );

    Result := 0;
  end; // else // valid image
end; // end of TN_CMCaptDev21Form.CMOFCaptureSlide


//************************************** TN_CMCaptDev21Form.CMOFImportSlide ***
// Import Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
// not used, only for debug
//
function TN_CMCaptDev21Form.CMOFImportSlide(): integer;
var
  BitmapHandle: HBITMAP;
  Bmp:          TBitmap;
  ResCode:      Integer;
begin
  if CMOFNumCaptured <> 0 then
  begin
  // EDAAddSlide is not needed, all done in K_CMSlideCreateFromDeviceDIBObj and then replaced
  // K_CMEDAccess.EDAAddSlide( CMOFNewSlide ); // from now on NewSlide is owned by K_CMEDAccess

    N_CMECDClean(0);
  end;

  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format( 'Schick Start CMOFImportSlide %d', [CMOFNumCaptured] ) );

  N_CMECDImportImage( @N_ImageStruct );
  N_Dump1Str( 'Schick after N_CMECDImportImage' );

  BitmapHandle := HBITMAP( N_ImageStruct.IPIHBitmap );
  if BitmapHandle = 0 then
  begin
    K_CMShowMessageDlg( 'Import Image Error', mtError );
    Result := 1;
    Exit;
  end;

  Bmp := TBitmap.Create();
  Bmp.Handle := BitmapHandle;
  // in case we need to check the file
  //Bmp.SaveToFile('D:/image.bmp');

  ResCode := CMOFCaptureSlide( False, Bmp );

  Bmp.Free;

  Result := ResCode;
end; // end of TN_CMCaptDev21Form.CMOFImportSlide

//************************************** TN_CMCaptDev21Form.CMOFAcquireSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev21Form.CMOFAcquireSlide(): integer;
var
  BitmapHandle: HBITMAP;
  Bmp:          TBitmap;
  ResCode:      Integer;
begin
  if CMOFNumCaptured <> 0 then
  begin
  // EDAAddSlide is not needed, all done in K_CMSlideCreateFromDeviceDIBObj and then replaced
  // K_CMEDAccess.EDAAddSlide( CMOFNewSlide ); // from now on NewSlide is owned by K_CMEDAccess
    N_CMECDClean(0);
  end;

  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format( 'Schick Start CMOFAcquireSlide %d', [CMOFNumCaptured] ) );

  N_CMECDAcquireImage( @N_ImageStruct );
  N_Dump1Str( 'Schick after N_CMECDAcquireImage' );

  BitmapHandle := HBITMAP( N_ImageStruct.IPIHBitmap );
  Bmp := TBitmap.Create();
  Bmp.Handle := BitmapHandle;
  // in case we need to check the file
  //Bmp.SaveToFile('D:/image.bmp');

  ResCode := CMOFCaptureSlide( False, Bmp );

  Bmp.Free;

  Result := ResCode;
end; // end of TN_CMCaptDev21Form.CMOFAcquireSlide

//************************************** TN_CMCaptDev21Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev21Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev21Form.CurStateToMemIni

//************************************** TN_CMCaptDev21Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev21Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev21Form.MemIniToCurState

//****************************************** TN_CMCaptDev21Form.rbModeAClick ***
// Mode A choosen
//
//     Parameters
// Sender - Sender event
//
procedure TN_CMCaptDev21Form.rbModeAClick( Sender: TObject );
begin
  inherited;
  if CMOFInitFlag then
  begin
    CMOFFilterImage( 0 );

    CMOFRawFilteredFlag := True;
  end;
end; // procedure TN_CMCaptDev21Form.rbModeAClick

//****************************************** TN_CMCaptDev21Form.rbModeAClick ***
// Mode B choosen
//
//     Parameters
// Sender - Sender event
//
procedure TN_CMCaptDev21Form.rbModeBClick( Sender: TObject );
begin
  inherited;
  if CMOFInitFlag then
  begin
    CMOFFilterImage( 0 );

    CMOFRawFilteredFlag := True;
  end;
end; // procedure TN_CMCaptDev21Form.rbModeBClick

end.
