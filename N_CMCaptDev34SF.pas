unit N_CMCaptDev34SF;
// EzSensor/FireCR capture form changed from Trident

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND}
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F,
  N_CMCaptDev34bF, Buttons, K_FCMDeviceSetupEnter, FilterCornerMask, MagicWand;

type TN_CMCaptDev34Form = class( TN_BaseForm )
  MainPanel:   TPanel;
  RightPanel:  TPanel;
  SlidePanel:  TPanel;
  bnExit:      TButton;
  ThumbsRFrame: TN_Rast1Frame;
  SlideRFrame:  TN_Rast1Frame;
  TimerCheck:  TTimer;
  TimerBuf:    TTimer;
  CtrlsPanelParent: TPanel;
  CtrlsPanel:  TPanel;
  bnSetup:     TButton;
  BitBtnGetImage: TBitBtn;
  cbAutoTake:  TCheckBox;
  ProgressBar: TProgressBar;
  cbRFID:      TCheckBox;
  cbFilterPar: TComboBox;
  Edit1:       TEdit;
  bnSetPatientID: TButton;
  bnGetPatientID: TButton;
  tbRotateImage: TToolBar;
  tbLeft90:    TToolButton;
  tbRight90:   TToolButton;
  tb180:       TToolButton;
  tbFlipHor:   TToolButton;
  bnCapture:   TButton;
  StatusShape: TShape;
  StatusLabel: TLabel;
  lbUID:       TLabel;
  Label1:      TLabel;
  bnOpen:      TButton;
  bnClose:     TButton;
  lbCount:     TLabel;
  TimerScannerCallback: TTimer;
  lbIP:        TLabel;
  TimerReboot: TTimer;
  TimerConnect: TTimer;
    cbMask: TCheckBox;

  //********************  TN_CMCaptDev34Form class handlers  ******************

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
  procedure bnSetupClick     ( Sender: TObject );
  procedure bnExitClick      ( Sender: TObject );
  procedure TimerCheckTimer  ( Sender: TObject );
  procedure cbRFIDClick      ( Sender: TObject );
  //procedure BitBtnGetImageClick ( Sender: TObject );
  procedure bnSetPatientIDClick ( Sender: TObject );
  procedure bnGetPatientIDClick ( Sender: TObject );
  procedure cbFilterParChange   ( Sender: TObject );
  procedure TimerBufTimer       ( Sender: TObject );
  procedure bnOpenClick         ( Sender: TObject );
  procedure bnCloseClick        ( Sender: TObject );
  procedure BitBtnGetImageClick ( Sender: TObject );
  procedure TimerScannerCallbackTimer( Sender: TObject );
  procedure TimerRebootTimer    ( Sender: TObject );
  procedure TimerConnectTimer   ( Sender: TObject );
    procedure cbMaskClick(Sender: TObject);

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

    CMOFSlideInit:    TN_UDCMSlide; // initial state for corner mask

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide (): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
    procedure SaveImageFromBuffer();
end; // type TN_CMCaptDev34Form = class( TN_BaseForm )

var
  N_FlagBuf, N_FlagGot: Boolean; // flags if getting the image from buffer, if the image was captured
  N_NewSlide:     TN_UDCMSlide;
  N_TempProgress: integer;
  N_TempSeconds:  Integer; // time
  N_SlideTime:    TDateTime; // time a slide had taken

implementation

uses
  Math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra3, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F,
  N_CMCaptDev34S, N_CMCaptDev34aF;
{$R *.dfm}

//**********************  TN_CMCaptDev34Form class handlers  ******************

//********************************************* TN_CMCaptDev34Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev34Form.FormShow( Sender: TObject );
begin
  N_Dump1Str( '****************** Start FireCR ******************' );
  N_Dump1Str( 'Start CMOther15Form.FormShow' );

  N_CMCDServObj34.CDSStillProgress := True; // progress = 0

  N_CMCDServObj34.CDSRecover := False;

  //N_CMCDServObj34.CDSInit := True; // will be init through here, for settings

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

  N_CMCDServObj34.CDSUID := 0; // set default UID

  N_Dump1Str( 'FireCR - StrPar1 = ' + CMOFPProfile.CMDPStrPar1 );
  if Length(CMOFPProfile.CMDPStrPar1) > 1 then // latest format used
  begin

    if CMOFPProfile.CMDPStrPar1[2] = '1' then
    begin
      N_CMCDServObj34.CDSSDKOld := True;
    end
    else
    begin
      N_CMCDServObj34.CDSSDKOld := False;
    end;

  end // latest format used
  else
    N_CMCDServObj34.CDSSDKOld := True;

  N_Dump1Str( 'Old SDK used = ' + BoolToStr(N_CMCDServObj34.CDSSDKOld) );

  if N_CMCDServObj34.CDSSettingsChanges < 1 then
    bnOpen.OnClick(Nil);

  N_Dump1Str( 'End CMOther15Form.FormShow' );
end; // procedure TN_CMCaptDev34Form.FormShow

//******************************************** TN_CMCaptDev34Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev34Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin
  Inherited;
  N_Dump1Str( 'Start CMOther15Form.FormClose' );

  bnClose.OnClick(Nil);

  N_CMCDServObj34.CDSScannerAlreadyInit := False;
  N_CMCDServObj34.CDSScannerCallback    := False;

  CMOFSlideInit := Nil;

  N_Dump1Str( 'FireCR - StrPar1 After closing = ' + CMOFPProfile.CMDPStrPar1 );
  N_Dump1Str( '****************** End FireCR ******************' );
end; // TN_CMCaptDev34Form.FormClose

//****************************************** TN_CMCaptDev34Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  N_Dump1Str( 'Start CMOther15Form.FormKeyDown' );
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
  N_Dump1Str( 'End CMOther15Form.FormKeyDown' );
end; // procedure TN_CMCaptDev34Form.FormKeyDown

//******************************************** TN_CMCaptDev34Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  N_Dump1Str( 'Start CMOther15Form.FormKeyUp' );
  Exit;
  N_Dump1Str( 'End CMOther15Form.FormKeyUp' );
end; // procedure TN_CMCaptDev34Form.FormKeyUp

// ************************************ TN_CMCaptDev34Form.SlidePanelResize ***
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.SlidePanelResize( Sender: TObject );
var
  RootComp: TN_UDCompVis;
begin
  N_Dump1Str( 'Start CMOther15Form.SlidePanelResize' );
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
  N_Dump1Str( 'End CMOther15Form.SlidePanelResize' );
end; // procedure TN_CMCaptDev34Form.SlidePanelResize

//********************************** TN_CMCaptDev34Form.BitBtnGetImageClick ***
// Show form in which images from buffer are get
//
//     Parameters
// Sender - Event Sender
//
// BitBtnGetImage button OnClick handler
//
{procedure TN_CMCaptDev34Form.BitBtnGetImageClick( Sender: TObject );
var
  Form: TN_CMCaptDev34aForm;
begin
  N_Dump1Str( 'Start TN_CMCaptDev34Form.BitBtnGetImageClick' );
  inherited;

  Form := TN_CMCaptDev34aForm.Create( Application );
  Form.BaseFormInit( Nil, '', [ rspfMFRect, rspfCenter ], [ rspfAppWAR,
                                                               rspfShiftAll ] );
  Form.Caption := 'Recover Image';
  Form.CMOFParentForm := Self;
  Form.ShowModal();
  N_Dump1Str( 'Finish TN_CMCaptDev34Form.BitBtnGetImageClick' );
end;    }

//**************************************** TN_CMCaptDev34Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev34Form.tbLeft90Click( Sender: TObject );
begin
  N_Dump1Str( 'Start CMOther15Form.tbLeft90Click' );
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
  N_Dump1Str( 'End CMOther15Form.tbLeft90Click' );
end; // procedure TN_CMCaptDev34Form.tbLeft90Click

//*************************************** TN_CMCaptDev34Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev34Form.tbRight90Click( Sender: TObject );
begin
  N_Dump1Str( 'Start CMOther15Form.tbRight90Click' );
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
  N_Dump1Str( 'End CMOther15Form.tbRight90Click' );
end; // TN_CMCaptDev34Form.tbRight90Click

//********************************** TN_CMCaptDev34Form.SaveImageFromBuffer ***
// Create slide for image in buffer
//
procedure TN_CMCaptDev34Form.SaveImageFromBuffer();
var
  i:        Integer;
  RootComp: TN_UDCompVis;
begin
  N_Dump1Str( 'Start CMOther15Form.SaveImageFromBuffer' );
  //if FlagSave then
  //begin
    if N_NewSlide <> Nil then
    begin
      Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number

      N_NewSlide.SetAutoCalibrated();
      N_NewSlide.ObjAliase := IntToStr(CMOFNumCaptured);

      with N_NewSlide.P()^ do
      begin
        CMSSourceDescr := CMOFPProfile^.CMDPCaption;
        N_NewSlide.ObjInfo := 'Captured from ' + CMSSourceDescr;
        CMSMediaType := CMOFPProfile^.CMDPMTypeID;
        N_NewSlide.SetInitDCMAttrs( TK_PCMDCMAttrs(@CMOFPProfile^.CMDPDModality) );
      end; // with NewSlide.P()^ do

      N_Dump1Str( 'Before changing a slide time' );
      N_NewSlide.P()^.CMSDTTaken := N_SlideTime;
      N_Dump1Str( 'After changing a slide time' );

      // Add NewSlide to list of all Slides of current Patient
      K_CMEDAccess.EDAAddSlide( N_NewSlide ); // from now on NewSlide is owned by K_CMEDAccess

      // Add NewSlide to beg of CMOFPNewSlides^ array
      SetLength( CMOFPNewSlides^, CMOFNumCaptured );

      for i := High(CMOFPNewSlides^) downto 1 do // Shift all elems by 1
        CMOFPNewSlides^[i] := CMOFPNewSlides^[i - 1];

      CMOFPNewSlides^[0] := N_NewSlide;
      CMOFSlideInit := N_NewSlide;

      // Add NewSlide to CMOFThumbsDGrid
      Inc(CMOFThumbsDGrid.DGNumItems);
      CMOFThumbsDGrid.DGInitRFrame();
      CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

      // Show NewSlide in SlideRFrame
      RootComp := N_NewSlide.GetMapRoot();
      SlideRFrame.RFrShowComp(RootComp);

      N_NewSlide := Nil; // cleaning
    end;
  //end;
  N_Dump1Str( 'End CMOther15Form.SaveImageFromBuffer' );
end; // procedure TN_CMCaptDev34Form.SaveImageFromBuffer();

//*************************************** TN_CMCaptDev34Form.TimerBufTimer ***
// Timer actions for saving an image from the device buffer
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.TimerBufTimer(Sender: TObject);
//var
  //i:        Integer;
  // RootComp: TN_UDCompVis;
begin
  inherited;
 { if FlagSave then
  begin
    if NewSlide <> Nil then
    begin
      Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number

      NewSlide.SetAutoCalibrated();
      NewSlide.ObjAliase := IntToStr(CMOFNumCaptured);

      with NewSlide.P()^ do
      begin
        CMSSourceDescr := CMOFPProfile^.CMDPCaption;
        NewSlide.ObjInfo := 'Captured from ' + CMSSourceDescr;
        CMSMediaType := CMOFPProfile^.CMDPMTypeID;
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

      //FlagSave := False;
      NewSlide := Nil;
    end;
  end;       }
end; // procedure TN_CMCaptDev34Form.TimerBufTimer(Sender: TObject);

//************************************** TN_CMCaptDev34Form.TimerCheckTimer ***
// Timer main actions
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.TimerCheckTimer( Sender: TObject );
var
  TempStatus, TempRFID, Count, Result: Integer;
  //Params:    PN_ScannerIntro;
  ParamsOld: PN_ScannerIntroOld;
begin
//  N_Dump1Str( 'Start CMOther15Form.TimerCheckTimer' );
  TimerCheck.Enabled := False;
  TempRFID := 0;

  if N_CMCDServObj34.CDSSDKOld then // old sdk
  begin

  // ***** counting the time for Dump
  Inc( N_CMCDServObj34.CDSTimerCount );
  if N_CMCDServObj34.CDSTimerCount > 25 then
  begin
    N_Dump1Str( 'FireCR - Timer - Passed ~5 sec' );
    N_CMCDServObj34.CDSTimerCount := 0;
  end; // if N_CMCDServObj34.CDSTimerCount > 25 then

  // ***** get connection type and set components
  N_CMCDServObj34.CDSScannerConnectionType :=
                                         N_CMECDVDC_GetScannerConnectionTypeOld;

  // ***** dump connection type if it's differ from the last one
  if N_CMCDServObj34.CDSPrevConnectType <>
                                   N_CMCDServObj34.CDSScannerConnectionType then
  begin
    N_Dump1Str( 'FireCR - Timer - Scanner Connection Type = ' +
                           IntToStr(N_CMCDServObj34.CDSScannerConnectionType) );

    N_CMCDServObj34.CDSPrevConnectType :=
                                       N_CMCDServObj34.CDSScannerConnectionType;
  end;

  if N_CMCDServObj34.CDSScannerConnectionType = 2 then // N to N connection
  begin
    //cbRFID.Visible := True;
    lbUID.Visible  := True;
  end else // other connections
  begin
    cbRFID.Visible := False;
    lbUID.Visible  := False;
  end;

  // ***** set RFID Reader checkbox
  TempRFID := N_CMECDVDC_GetRFIDListeningOld();

  // ***** dump RFID Listening if it's differ from the last one
  if N_CMCDServObj34.CDSPrevRFID <> TempRFID then
  begin
    N_Dump1Str( 'FireCR - Timer - RFID Listening = ' + IntToStr(TempRFID) );
    N_CMCDServObj34.CDSPrevRFID := TempRFID;
  end;

  if TempRFID = 1 then
  begin
    //cbRFID.Checked := True;
    LbUID.Visible  := True;
  end else // TempRFID <> 1
  begin
    cbRFID.Checked := False;
    LbUID.Visible  := False;
  end;

  // ***** get and show UID
  if N_CMCDServObj34.CDSUID <> 0 then
    LbUID.Caption := Format('UID: %x', [ N_CMCDServObj34.CDSUID ] )
  else
    LbUID.Caption := 'UID: None';

  Result := K_CMEDAccess.EDADevicePlateUseCountGet( Format('%x', [ N_CMCDServObj34.CDSUID ] ) );
  lbCount.Caption := 'Image Count: ' + IntToStr(Result);
  //Label3.Caption := 'UID: ' + Format('%x', [ N_CMCDServObj34.CDSUID ] );
  //N_Dump1Str( 'Plate UID Image Count = ' + IntToStr(Result) );

  // ***** dump UID if it's differ from the last one
  if N_CMCDServObj34.CDSUID <> N_CMCDServObj34.CDSPrevUID then
  begin
    N_Dump1Str( Format('FireCR - Timer - UID = %x', [N_CMCDServObj34.CDSUID]) );
    N_CMCDServObj34.CDSPrevUID := N_CMCDServObj34.CDSUID;
  end;

  // ***** get and show progress of the action
  N_TempProgress := N_CMECDVDC_GetProgressOld; // get capture progress (0-1000)

  if N_TempProgress = 1000 then
  begin
    N_TempProgress := 0;
    N_CMCDServObj34.CDSStillProgress := True;
  end;

    if N_FlagBuf then
  begin
    ProgressBar.Position := N_TempProgress; // progress to form
  end;

  if N_TempProgress <> 0 then
    N_Dump1Str( 'FireCR - Timer - Progress = ' + IntToStr(N_TempProgress) );

  TempStatus := N_CMECDVDC_GetScannerStatusOld(); // get status

  case TempStatus of
	  0: begin // none
      StatusLabel.Caption := 'Disconnected';
      StatusLabel.Font.Color  := clRed;
      StatusShape.Pen.Color   := clRed;
      StatusShape.Brush.Color := clRed;
      BitBtnGetImage.Enabled  := False;
      bnSetup.Enabled         := False;
    end; // none
	  1: begin // disconnected
      StatusLabel.Caption := 'Disconnected';
      StatusLabel.Font.Color  := clRed;
      StatusShape.Pen.Color   := clRed;
      StatusShape.Brush.Color := clRed;
      BitBtnGetImage.Enabled  := False;
      bnSetup.Enabled         := False;
    end; // disconnected
    2: begin // waiting
      StatusLabel.Caption := 'Waiting';
      StatusLabel.Font.Color  := TColor( $168EF7 );
      StatusShape.Pen.Color   := TColor( $168EF7 );
      StatusShape.Brush.Color := TColor( $168EF7 );
      BitBtnGetImage.Enabled  := False;
      bnSetup.Enabled         := False;
    end; // waiting
    3: begin // connected
      StatusLabel.Caption := 'Connected';
      StatusLabel.Font.Color  := clGreen;
      StatusShape.Pen.Color   := clGreen;
      StatusShape.Brush.Color := clGreen;
      BitBtnGetImage.Enabled  := True;
      bnSetup.Enabled         := True;

      Count := 0; // index of the sensor
      N_Dump1Str( 'FireCR - Before RequestScannerList( @Count ), Count = 0' );
      ParamsOld := N_CMECDVDC_RequestScannerListOld( @Count ); // scanner parameters
      N_Dump1Str( 'FireCR - After RequestScannerList( @Count )' );
      if not Assigned( ParamsOld ) then
        N_Dump1Str( 'FireCR - Scanner List is not assigned' );
      N_Dump1Str( 'FireCR - Scanner List PN: ' + N_AnsiToString(ParamsOld.SIPN) );

    end; // connected
    4: begin // transferring
      StatusLabel.Caption := 'Transferring';
      StatusLabel.Font.Color  := clBlue;
      StatusShape.Pen.Color   := clBlue;
      StatusShape.Brush.Color := clBlue;
      BitBtnGetImage.Enabled  := False;
      bnSetup.Enabled         := False;
    end; // transferring
  end; // case TempStatus of

  if N_CMCDServObj34.CDSPrevStatus <> TempStatus then // so it won't blink
  begin
    StatusLabel.Repaint;
    StatusShape.Repaint;
    N_Dump1Str( 'FireCR - Timer - Scanner Status = ' + IntToStr(TempStatus) );
  end;

  N_CMCDServObj34.CDSPrevStatus := TempStatus; // change previous status

  // ***** the image is get
  if N_CMCDServObj34.CDSFlagCapt = True then
  begin
    N_Dump1Str( 'FlagCapt = True' );
    N_CMCDServObj34.CDSFlagCapt := False;

  //  if not N_CMCDServObj34.CDSSetPatientFlag then // add name just in case
  //  begin
  //    N_Dump1Str( 'FireCR - still not N_CMCDServObj34.CDSSetPatientFlag' );
  //    N_CMCDServObj34.CDSPatientName := N_StringToAnsi(
  //                                                    K_CMGetPatientDetails( -1,
  //                                '(#PatientSurname#) (#PatientFirstName#)' ) );
  //    N_Dump1Str( 'FireCR - Before SetPatientID' );
  //    TempInt := N_CMECDVDC_SetPatientID( @N_CMCDServObj34.CDSPatientName[1],
  //                                     Length(N_CMCDServObj34.CDSPatientName) );
  //    N_Dump1Str( 'FireCR - After SetPatientID = ' + IntToStr(TempInt) );
  //  end;

    N_Dump1Str( 'Before GetImageSize( @Width, @Height )' );
    N_CMECDVDC_GetImageSizeOld( @N_CMCDServObj34.CDSWidth,
                                                   @N_CMCDServObj34.CDSHeight ); // get image size
    N_Dump1Str( 'After GetImageSize( @Width, @Height ), Width = ' +
                              IntToStr(N_CMCDServObj34.CDSWidth) + ', Height = '
                                        + IntToStr(N_CMCDServObj34.CDSHeight) );


    N_Dump1Str( 'Before GetImageBuffer' );
    N_CMCDServObj34.CDSSource := N_CMECDVDC_GetImageBufferOld(); // get buffer
    N_Dump1Str( 'After GetImageBuffer' );
    N_Dump1Str( 'Before CMOFCaptureSlide' );

    CMOFCaptureSlide(); // save slide

    if not N_CMCDServObj34.CDSRecover then
      Result := K_CMEDAccess.EDADevicePlateUseCountInc( Format('%x', [ N_CMCDServObj34.CDSUID ] ) );

    N_Dump1Str( 'New image for UID = ' + Format('%x', [ N_CMCDServObj34.CDSUID ] ) + ' is = ' + IntToStr(Result) );
  end;

  end
  else // the new one
  begin

  // ***** counting the time for Dump
  Inc( N_CMCDServObj34.CDSTimerCount );
  if N_CMCDServObj34.CDSTimerCount > 25 then
  begin
    N_Dump1Str( 'FireCR - Timer - Passed ~5 sec' );
    N_CMCDServObj34.CDSTimerCount := 0;
  end; // if N_CMCDServObj34.CDSTimerCount > 25 then

  // ***** get connection type and set components
  N_CMCDServObj34.CDSScannerConnectionType :=
                                            N_CMECDVDC_GetScannerConnectionType;

  // ***** dump connection type if it's differ from the last one
  if N_CMCDServObj34.CDSPrevConnectType <>
                                   N_CMCDServObj34.CDSScannerConnectionType then
  begin
    N_Dump1Str( 'FireCR - Timer - Scanner Connection Type = ' +
                           IntToStr(N_CMCDServObj34.CDSScannerConnectionType) );

    N_CMCDServObj34.CDSPrevConnectType :=
                                       N_CMCDServObj34.CDSScannerConnectionType;
  end;

  if N_CMCDServObj34.CDSScannerConnectionType = 2 then // N to N connection
  begin
    //cbRFID.Visible := True;
    lbUID.Visible  := True;
  end else // other connections
  begin
    //cbRFID.Visible := False;
    lbUID.Visible  := False;
  end;

  if TempRFID = 1 then
  begin
    //cbRFID.Checked := True;
    //LbUID.Visible  := True;
  end else // TempRFID <> 1
  begin
    //cbRFID.Checked := False;
    //LbUID.Visible  := False;
  end;

  // ***** get and show UID
  if N_CMCDServObj34.CDSUID <> 0 then
    LbUID.Caption := Format('UID: %x', [ N_CMCDServObj34.CDSUID ] )
  else
    LbUID.Caption := 'UID: None';

  Result := K_CMEDAccess.EDADevicePlateUseCountGet( Format('%x', [ N_CMCDServObj34.CDSUID ] ) );
  lbCount.Caption := 'Image Count: ' + IntToStr(Result);
  //Label3.Caption := 'UID: ' + Format('%x', [ N_CMCDServObj34.CDSUID ] );
  //N_Dump1Str( 'Plate UID Image Count = ' + IntToStr(Result) );

  // ***** dump UID if it's differ from the last one
  if N_CMCDServObj34.CDSUID <> N_CMCDServObj34.CDSPrevUID then
  begin
    N_Dump1Str( Format('FireCR - Timer - UID = %x', [N_CMCDServObj34.CDSUID]) );
    N_CMCDServObj34.CDSPrevUID := N_CMCDServObj34.CDSUID;
  end;

  // ***** get and show progress of the action
  N_TempProgress := N_CMECDVDC_GetProgress; // get capture progress (0-1000)

  if N_TempProgress = 1000 then
  begin
    N_TempProgress := 0;
    N_CMCDServObj34.CDSStillProgress := True;
  end;

    if N_FlagBuf then
  begin
    ProgressBar.Position := N_TempProgress; // progress to form
  end;

  if N_TempProgress <> 0 then
    N_Dump1Str( 'FireCR - Timer - Progress = ' + IntToStr(N_TempProgress) );

  TempStatus := N_CMCDServObj34.CDSScannerStatus;//N_CMECDVDC_GetScannerStatus(); // get status

  case TempStatus of
	  0: begin // none
      StatusLabel.Caption := 'Disconnected';
      StatusLabel.Font.Color  := clRed;
      StatusShape.Pen.Color   := clRed;
      StatusShape.Brush.Color := clRed;
      BitBtnGetImage.Enabled  := False;
      bnSetup.Enabled         := False;
    end; // none
	  1: begin // disconnected
      StatusLabel.Caption := 'Disconnected';
      StatusLabel.Font.Color  := clRed;
      StatusShape.Pen.Color   := clRed;
      StatusShape.Brush.Color := clRed;
      BitBtnGetImage.Enabled  := False;
      bnSetup.Enabled         := False;
    end; // disconnected
    2: begin // waiting
      StatusLabel.Caption := 'Waiting';
      StatusLabel.Font.Color  := TColor( $168EF7 );
      StatusShape.Pen.Color   := TColor( $168EF7 );
      StatusShape.Brush.Color := TColor( $168EF7 );
      BitBtnGetImage.Enabled  := False;
      bnSetup.Enabled         := True;//False;
    end; // waiting
    4: begin // connected
      StatusLabel.Caption := 'Connected';
      StatusLabel.Font.Color  := clGreen;
      StatusShape.Pen.Color   := clGreen;
      StatusShape.Brush.Color := clGreen;
      BitBtnGetImage.Enabled  := True;
      bnSetup.Enabled         := True;

      lbIP.Visible := True;
               lbIP.Caption := 'IP: ' + N_CMCDServObj34.CDSScannerIP;

//      Count := 0; // index of the sensor
//      N_Dump1Str( 'FireCR - Before RequestScannerList( @Count ), Count = 0' );
//      Params := N_CMECDVDC_RequestScannerList( @Count ); // scanner parameters
//      N_Dump1Str( 'FireCR - After RequestScannerList( @Count ), Count = 0' );
//      if not Assigned( Params ) then
//        N_Dump1Str( 'FireCR - Scanner List is not assigned' );

    //  N_Dump1Str( 'FireCR - Scanner List PN: ' + N_AnsiToString(Params.SIPN) );

    end; // connected
    5: begin // sleeping
      StatusLabel.Caption := 'Sleeping';
      StatusLabel.Font.Color  := TColor( $168EF7 );
      StatusShape.Pen.Color   := TColor( $168EF7 );
      StatusShape.Brush.Color := TColor( $168EF7 );
      BitBtnGetImage.Enabled  := False;//True;
      bnSetup.Enabled         := True;

      lbIP.Visible := True;
               lbIP.Caption := 'IP: ' + N_CMCDServObj34.CDSScannerIP;
    end; // sleeping

    6: begin // transferring
      StatusLabel.Caption := 'Transferring';
      StatusLabel.Font.Color  := clBlue;
      StatusShape.Pen.Color   := clBlue;
      StatusShape.Brush.Color := clBlue;
      BitBtnGetImage.Enabled  := False;
      bnSetup.Enabled         := False;
    end; // transferring
  end; // case TempStatus of

  if N_CMCDServObj34.CDSPrevStatus <> TempStatus then // so it won't blink
  begin
    StatusLabel.Repaint;
    StatusShape.Repaint;
    N_Dump1Str( 'FireCR - Timer - Scanner Status = ' + IntToStr(TempStatus) );
  end;

  N_CMCDServObj34.CDSPrevStatus := TempStatus; // change previous status

  // ***** the image is get
  if N_CMCDServObj34.CDSFlagCapt = True then
  begin
    N_Dump1Str( 'FlagCapt = True' );
    N_CMCDServObj34.CDSFlagCapt := False;

  //  if not N_CMCDServObj34.CDSSetPatientFlag then // add name just in case
  //  begin
  //    N_Dump1Str( 'FireCR - still not N_CMCDServObj34.CDSSetPatientFlag' );
  //    N_CMCDServObj34.CDSPatientName := N_StringToAnsi(
  //                                                    K_CMGetPatientDetails( -1,
  //                                '(#PatientSurname#) (#PatientFirstName#)' ) );
  //    N_Dump1Str( 'FireCR - Before SetPatientID' );
  //    TempInt := N_CMECDVDC_SetPatientID( @N_CMCDServObj34.CDSPatientName[1],
  //                                     Length(N_CMCDServObj34.CDSPatientName) );
  //    N_Dump1Str( 'FireCR - After SetPatientID = ' + IntToStr(TempInt) );
  //  end;

    N_Dump1Str( 'Before GetImageSize( @Width, @Height )' );
    //N_CMECDVDC_GetImageSize( @N_CMCDServObj34.CDSWidth,
    //                                               @N_CMCDServObj34.CDSHeight ); // get image size
    N_CMCDServObj34.CDSWidth  := N_CMECDVDC_GetImageWidth();
    N_CMCDServObj34.CDSHeight := N_CMECDVDC_GetImageHeight();
    N_Dump1Str( 'After GetImageSize( @Width, @Height ), Width = ' +
                              IntToStr(N_CMCDServObj34.CDSWidth) + ', Height = '
                                        + IntToStr(N_CMCDServObj34.CDSHeight) );


    N_Dump1Str( 'Before GetImageBuffer' );
    N_CMCDServObj34.CDSSource := N_CMECDVDC_GetImageBuffer(); // get buffer
    N_Dump1Str( 'After GetImageBuffer' );
    N_Dump1Str( 'Before CMOFCaptureSlide' );

    CMOFCaptureSlide(); // save slide

    if not N_CMCDServObj34.CDSRecover then
      Result := K_CMEDAccess.EDADevicePlateUseCountInc( Format('%x', [ N_CMCDServObj34.CDSUID ] ) );

    N_Dump1Str( 'New image for UID = ' + Format('%x', [ N_CMCDServObj34.CDSUID ] ) + ' is = ' + IntToStr(Result) );
  end;

  end; // new sdk

  TimerCheck.Enabled := True;
//  N_Dump1Str( 'End CMOther15Form.TimerCheckTimer' );
end;

//************************************ TN_CMCaptDev34Form.TimerConnectTimer ***
// Checking the device status for an autoconnect
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.TimerConnectTimer( Sender: TObject );
begin
  inherited;
  if not N_CMCDServObj34.CDSSDKOld then // new sdk
  if ( StatusLabel.Caption = 'Disconnected' ) or ( StatusLabel.Caption = 'Waiting' ) then
  begin
    N_Dump1Str( 'FireCR - Trying to reboot MediaScan' );
    N_CMCDServObj34.CDSScannerReboot := True;
  end;
end;

//************************************* TN_CMCaptDev34Form.TimerRebootTimer ***
// Checking if scanner reboot needed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.TimerRebootTimer( Sender: TObject );
begin
  inherited;
  if N_CMCDServObj34.CDSScannerReboot then // if true
  begin
    N_CMCDServObj34.CDSScannerReboot := False;

    N_CMCDServObj34.CDSScannerAlreadyInit := False;

    bnClose.OnClick(Nil);
    bnOpen.OnClick(Nil);

  end;

end; // procedure TN_CMCaptDev34Form.TimerRebootTimer( Sender: TObject );

//**************************** TN_CMCaptDev34Form.TimerScannerCallbackTimer ***
// Waiting for the few callback answer, to start
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.TimerScannerCallbackTimer( Sender: TObject );
var
  TempInt, Count: Integer;
  Params:         PN_ScannerIntro;
  IPAnsi:         AnsiString;
begin
  inherited;

  TempInt := 0; // no error

  if N_CMCDServObj34.CDSScannerCallback then // if true, start the algorithm
    if not N_CMCDServObj34.CDSScannerAlreadyInit then // needs initialization
    begin
      if not N_CMCDServObj34.CDSSDKOld then // new sdk
      begin

        N_CMCDServObj34.CDSScannerAlreadyInit := True;

        Count := 0; // index of the sensor
        N_Dump1Str( 'FireCR - Before RequestScannerList( @Count ), Count = 0' );
        Params := N_CMECDVDC_RequestScannerList( @Count ); // scanner parameters
        N_Dump1Str( 'FireCR - After RequestScannerList( @Count ), Count = ' + IntToStr(Count) );
        Count := N_CMCDServObj34.CDSScannerCount;

        N_Dump1Str( 'FireCR - Count = ' + IntToStr(Count) );

        if Count = 0 then
        begin
          N_Dump1Str( 'FireCR - Scanner List is not assigned' );

        end
        else
        begin
          if Count > 1 then
          begin

           if Length(CMOFPProfile.CMDPStrPar1) > 2 then
           begin
             N_CMCDServObj34.CDSScannerIP := CMOFPProfile.CMDPStrPar1;
             Delete( N_CMCDServObj34.CDSScannerIP, 1, 2 );
           end;

            TempInt := 0;
            if N_CMCDServObj34.CDSScannerIP <> '' then
            begin
               IPAnsi := N_StringToAnsi( N_CMCDServObj34.CDSScannerIP );

               if CMOFPProfile.CMDPStrPar1[1] = '0' then // no fire id
                 TempInt := N_CMECDVDC_Connect(@IPAnsi[1]);
            end;

            if ( N_CMCDServObj34.CDSScannerIP = '' ) or (TempInt = 0) then
            begin
              N_CMCDServObj34.CDSScannerIP := Format( '%d.%d.%d.%d',
                                         [ Byte(Params.SIScannerIP.SIUBytes[0]),
                                           Byte(Params.SIScannerIP.SIUBytes[1]),
                                           Byte(Params.SIScannerIP.SIUBytes[2]),
                                           Byte(Params.SIScannerIP.SIUBytes[3])
                                         ]);
             IPAnsi := N_StringToAnsi( N_CMCDServObj34.CDSScannerIP );

             if CMOFPProfile.CMDPStrPar1[1] = '0' then
             begin
               TempInt := N_CMECDVDC_Connect(@IPAnsi[1]);

               N_Dump1Str( 'FireCR - >1 Scanners, After Connect to ' + N_CMCDServObj34.CDSScannerIP + ' = ' + IntToStr(TempInt) );
               lbIP.Visible := True;
               lbIP.Caption := 'IP: ' + N_CMCDServObj34.CDSScannerIP;
             end
             else
               N_Dump1Str( 'FireCR - >1 Scanners, FireID is used' );
           end;
         end;

         if Count = 1 then
         begin

           N_CMCDServObj34.CDSScannerIP := Format( '%d.%d.%d.%d',
                                         [ Byte(Params.SIScannerIP.SIUBytes[0]),
                                           Byte(Params.SIScannerIP.SIUBytes[1]),
                                           Byte(Params.SIScannerIP.SIUBytes[2]),
                                           Byte(Params.SIScannerIP.SIUBytes[3])
                                         ]);
           IPAnsi := N_StringToAnsi( N_CMCDServObj34.CDSScannerIP );

           if CMOFPProfile.CMDPStrPar1[1] = '0' then
           begin
             TempInt := N_CMECDVDC_Connect(@IPAnsi[1]);

             N_Dump1Str( 'FireCR - 1 Scanner, After Connect to ' +
                     N_CMCDServObj34.CDSScannerIP + ' = ' + IntToStr(TempInt) );
             lbIP.Visible := True;
             lbIP.Caption := 'IP: ' + N_CMCDServObj34.CDSScannerIP;
           end
           else
             N_Dump1Str( 'FireCR - 1 Scanner, FireID is used' );

         end;
      end;

      if not N_CMCDServObj34.CDSSDKOld then // new sdk
      begin
        if TempInt <> 0 then
        begin
          N_CMCDServObj34.CDSPatientName := N_StringToAnsi(
          K_CMGetPatientDetails( -1, '(#PatientSurname#) (#PatientFirstName#)' ) );
          N_Dump1Str( 'FireCR - Before SetPatientID' );
          TempInt := N_CMECDVDC_SetPatientID( @N_CMCDServObj34.CDSPatientName[1],
                                       Length(N_CMCDServObj34.CDSPatientName) );
          N_Dump1Str( 'FireCR - After SetPatientID = ' + IntToStr(TempInt) );
          N_CMCDServObj34.CDSSetPatientFlag := True;
        end;

        // ***** for capture
        N_CMCDServObj34.CDSFlagCapt := False;
        N_CMCDServObj34.CDSPrevStatus := -1;

        N_CMCDServObj34.CDSPrevUID := 0; // initial state for UID
        N_Dump1Str( 'Started with PrevUID = 0' );

        N_CMCDServObj34.CDSTimerCount := 0; // initial state of timer count

        // ***** initial states
        N_CMCDServObj34.CDSSetPatientFlag := False;
        N_CMCDServObj34.CDSCalDataFin := False;
        N_CMCDServObj34.CDSPrevConnectType := 0;
        N_Dump1Str( 'Started with CDSPrevConnectType = 0' );
        N_CMCDServObj34.CDSPrevRFID := 0;
        N_Dump1Str( 'Started with CDSPrevRFID = 0' );

        N_FlagBuf := True; // not from buffer

        TimerCheck.Enabled := True;

        N_TempProgress := 0;
        N_TempSeconds := 0;

        cbRFID.Visible := False;

      end; // new
    end; // // needs initialization

    if not N_CMCDServObj34.CDSSDKOld then
      N_CMCDServObj34.CDSInit := True;

  end;
  //TimerScannerCallback.Enabled := False;
end;

// procedure TN_CMCaptDev34Form.TimerCheckTimer

//******************************************* TN_CMCaptDev34Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev34Form.tb180Click( Sender: TObject );
begin
  N_Dump1Str( 'Start CMOther15Form.tb180Click' );
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
  N_Dump1Str( 'End CMOther15Form.tb180Click' );
end; // procedure TN_CMCaptDev34Form.tb180Click

//*************************************** TN_CMCaptDev34Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev34Form.tbFlipHorClick( Sender: TObject );
begin
  N_Dump1Str( 'Start CMOther15Form.tbFlipHorClick' );
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
  N_Dump1Str( 'End CMOther15Form.tbFlipHorClick' );
end; // procedure TN_CMCaptDev34Form.tbFlipHorClick


//**********************  TN_CMCaptDev34Form class public methods  ************

//**************************************** TN_CMCaptDev34Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev34Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  N_Dump1Str( 'Start CMOther15Form.CMOFDrawThumb' );
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
  N_Dump1Str( 'End CMOther15Form.CMOFDrawThumb' );
end; // end of TN_CMCaptDev34Form.CMOFDrawThumb

//************************************* TN_CMCaptDev34Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev34Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
                                  AInd: Integer; AInpSize: TPoint; out AOutSize,
                                        AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide:     TN_UDCMSlide;
  ThumbDIB:  TN_UDDIB;
  ThumbSize: TPoint;
begin
  N_Dump1Str( 'Start CMOther15Form.CMOFGetThumbSize' );
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
  N_Dump1Str( 'End CMOther15Form.CMOFGetThumbSize' );
end; // procedure TN_CMCaptDev34Form.CMOFGetThumbSize

//********************************** TN_CMCaptDev34Form.BitBtnGetImageClick ***
// Show form in which images from buffer are get
//
//     Parameters
// Sender - Event Sender
//
// BitBtnGetImage button OnClick handler
//
procedure TN_CMCaptDev34Form.BitBtnGetImageClick( Sender: TObject );
var
  Form: TN_CMCaptDev34aForm;
begin
  N_Dump1Str( 'Start TN_CMCaptDev34Form.BitBtnGetImageClick' );
  inherited;

  Form := TN_CMCaptDev34aForm.Create( Application );
  Form.BaseFormInit( Nil, '', [ rspfMFRect, rspfCenter ], [ rspfAppWAR,
                                                               rspfShiftAll ] );
  Form.Caption := 'Recover Image';
  Form.CMOFParentForm := Self;

  N_CMCDServObj34.CDSRecover := True; // for counting plate images
  Form.ShowModal();


  N_CMCDServObj34.CDSRecover := False;

  N_Dump1Str( 'Finish TN_CMCaptDev34Form.BitBtnGetImageClick' );
end;

//****************************************** TN_CMCaptDev34Form.bnExitClick ***
// Exit
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.bnExitClick( Sender: TObject );
begin
  inherited;
end; // procedure TN_CMCaptDev34Form.bnExitClick

//***************************************** TN_CMCaptDev34Form.bnSetupClick ***
// Setup form
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.bnSetupClick( Sender: TObject );
var
  Form: TN_CMCaptDev34bForm;
begin
  inherited;
  N_Dump1Str( 'Start TN_CMCaptDev34Form.bnSetupClick' );

  TimerCheck.Enabled := False; // disable timer

  // ***** show device settings
  Form := TN_CMCaptDev34bForm.Create( Application );
  Form.BaseFormInit( Nil, '', [ rspfMFRect, rspfCenter ], [ rspfAppWAR,
    rspfShiftAll ] );
  Form.Caption := 'Setup';
  Form.CMCDPDevProfile := N_CMCDServObj34.CDSProfile;
  Form.CMCDFromCaptionForm := True;
  Form.ShowModal();

  TimerCheck.Enabled := True; // enable timer

  if not N_CMCDServObj34.CDSSDKOld then // new sdk
    N_CMCDServObj34.CDSScannerReboot := True;

  N_Dump1Str( 'Finish TN_CMCaptDev34Form.bnSetupClick' );
end; // procedure TN_CMCaptDev34Form.bnSetupClick( Sender: TObject );

//****************************************** TN_CMCaptDev34Form.bnOpenClick ***
// Open scanner
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.bnOpenClick( Sender: TObject );
var
  TempStr1:   WideString;
  TempStr2:   string;
  TempInt:  Integer;
begin

  try

  TempStr1 := '.'; // path to config file
  TempStr2 := '.';//K_GetDirPath( 'CMSWrkFiles' );

  N_CMCDServObj34.CDSUID := 0; // set default UID

  N_CMCDServObj34.CDSCalDataDir := TempStr2;

  if not N_CMCDServObj34.CDSSDKOld then // new sdk
  begin

    N_Dump1Str( 'New SDK started' );

    if N_CMCDServObj34.CDSDllHandleOld <> 0 then
    begin
      FreeLibrary( N_CMCDServObj34.CDSDllHandleOld );
      N_CMCDServObj34.CDSDllHandleOld := 0;
    end;

    if N_CMCDServObj34.CDSDllHandle = 0 then
      N_CMCDServObj34.CDSInitDll();

    if CMOFPProfile.CMDPStrPar1 = '' then
      CMOFPProfile.CMDPStrPar1 := '0';

    if (CMOFPProfile.CMDPStrPar2 = '') or
      (CMOFPProfile.CMDPStrPar2[1] = '1') then // get initial state for Image Filter CB
      N_CMCDServObj34.CDSImageFilter := True
    else
      N_CMCDServObj34.CDSImageFilter := False;

    N_CMCDServObj34.CDSImageFilterInd := 0;
    if Length(CMOFPProfile.CMDPStrPar2) > 1 then
      N_CMCDServObj34.CDSImageFilterInd := StrToIntDef(
                                               CMOFPProfile.CMDPStrPar2[2], 0 );
    // set Image Filter index
    cbFilterPar.ItemIndex := N_CMCDServObj34.CDSImageFilterInd;

    // ***** set RFID Reader
    if cbRFID.Checked then
    begin
      N_Dump1Str( 'FireCR - Before SetRFIDListening(1)' );
      N_CMECDVDC_SetRFIDListening(1);
      N_Dump1Str( 'FireCR - After SetRFIDListening(1)' )
    end else
    begin
      N_Dump1Str( 'FireCR - Before SetRFIDListening(0)' );
      N_CMECDVDC_SetRFIDListening(0);
      N_Dump1Str( 'FireCR - After SetRFIDListening(0)' );
    end;

    N_CMCDServObj34.CDSScannerCallback := False;

    // ***** setting callback-functions
    N_CMCDServObj34.CDSCallBacks.CBSRFIDNotifyEvent	:= @N_OnRFIDNotify;
   	N_CMCDServObj34.CDSCallBacks.CBSRFIDStatusEvent	:= @N_OnRFIDStatus;
   	N_CMCDServObj34.CDSCallBacks.CBSScannerNotifyEvent := @N_OnScannerNotify;
	  N_CMCDServObj34.CDSCallBacks.CBSScannerStatusEvent := @N_OnScannerStatus;
    N_CMCDServObj34.CDSCallBacks.CBSRFIDScannerList := @N_OnScannerList;
    N_CMCDServObj34.CDSCallBacks.CBSRFIDImageList := @N_OnImageList;

    N_Dump1Str( 'FireCR - Before OpenScannerSDK' );
  	TempInt := N_CMECDVDC_OpenScannerSDK( 0, @N_CMCDServObj34.CDSCallBacks,
                                                                 @TempStr1[1] ); // starting callback
    N_Dump1Str( 'FireCR - After OpenScannerSDK = ' + IntToStr(TempInt) );

    while TempInt = 0 do // failed
    begin
      N_Dump1Str( 'FireCR - Error = ' + IntToStr(N_CMECDVDC_GetErrorCode()) + ', Message = ' + N_AnsiToString( PAnsiChar(N_CMECDVDC_GetErrorMessage())) );
      N_CMECDVDC_CloseScannerSDK();
      Exit;
    end;

    N_CMCDServObj34.CDSPrevProgress := 0; // need for capture image
    N_Dump1Str( 'FireCR - Before OpenScanner' );
    TempInt := N_CMECDVDC_OpenScanner();
    N_Dump1Str( 'FireCR - After OpenScanner = ' + IntToStr(TempInt) );

  end
  else // old
  begin

    N_Dump1Str( 'Old SDK started' );

    if N_CMCDServObj34.CDSDllHandle <> 0 then
    begin
      FreeLibrary( N_CMCDServObj34.CDSDllHandle );
      N_CMCDServObj34.CDSDllHandle := 0;
    end;

    if N_CMCDServObj34.CDSDllHandleOld = 0 then
      N_CMCDServObj34.CDSInitDllOld();

    if CMOFPProfile.CMDPStrPar1 = '' then
      CMOFPProfile.CMDPStrPar1 := '0';

    // ***** setting component's values
    if CMOFPProfile.CMDPStrPar1[1] = '1' then
    begin
      //cbRFID.Checked := True;
    end
    else
    begin
      cbRFID.Checked := False;
    end;

    if (CMOFPProfile.CMDPStrPar2 = '') or (CMOFPProfile.CMDPStrPar2[1] = '1') then // get initial state for Image Filter CB
      N_CMCDServObj34.CDSImageFilter := True
    else
      N_CMCDServObj34.CDSImageFilter := False;

    N_CMCDServObj34.CDSImageFilterInd := 0;
    if Length(CMOFPProfile.CMDPStrPar2) > 1 then
      N_CMCDServObj34.CDSImageFilterInd := StrToIntDef(
                                               CMOFPProfile.CMDPStrPar2[2], 0 );
    // set Image Filter index
    cbFilterPar.ItemIndex := N_CMCDServObj34.CDSImageFilterInd;

    // ***** set RFID Reader
    if cbRFID.Checked then
    begin
      N_Dump1Str( 'FireCR - Before SetRFIDListening(1)' );
      N_CMECDVDC_SetRFIDListeningOld(1);
      N_Dump1Str( 'FireCR - After SetRFIDListening(1)' )
    end else
    begin
      N_Dump1Str( 'FireCR - Before SetRFIDListening(0)' );
      N_CMECDVDC_SetRFIDListeningOld(0);
      N_Dump1Str( 'FireCR - After SetRFIDListening(0)' );
    end;

    // ***** setting callback-functions
    N_CMCDServObj34.CDSCallBacksOld.CBSRFIDNotifyEvent	:= @N_OnRFIDNotifyOld;
   	N_CMCDServObj34.CDSCallBacksOld.CBSRFIDStatusEvent	:= Nil;
  	N_CMCDServObj34.CDSCallBacksOld.CBSScannerNotifyEvent := @N_OnScannerNotifyOld;
  	N_CMCDServObj34.CDSCallBacksOld.CBSScannerStatusEvent := Nil;

    N_Dump1Str( 'FireCR - Before OpenScannerSDK' );
   	TempInt := N_CMECDVDC_OpenScannerSDKOld( 0, @N_CMCDServObj34.CDSCallBacksOld,
                                                                 @TempStr1[1] ); // starting callback
    N_Dump1Str( 'FireCR - After OpenScannerSDK = ' + IntToStr(TempInt) );

    N_CMCDServObj34.CDSPrevProgress := 0; // need for capture image
    N_Dump1Str( 'FireCR - Before OpenScanner' );
    TempInt := N_CMECDVDC_OpenScannerOld();
    N_Dump1Str( 'FireCR - After OpenScanner = ' + IntToStr(TempInt) );

    if TempInt <> 0 then // failed
    begin
      //N_CMCDServObj34.CDSSDKOld := True;

      N_CMCDServObj34.CDSPatientName := N_StringToAnsi(
      K_CMGetPatientDetails( -1, '(#PatientSurname#) (#PatientFirstName#)' ) );
      N_Dump1Str( 'FireCR - Before SetPatientID' );
      TempInt := N_CMECDVDC_SetPatientIDOld( @N_CMCDServObj34.CDSPatientName[1],
                                       Length(N_CMCDServObj34.CDSPatientName) );
      N_Dump1Str( 'FireCR - After SetPatientID = ' + IntToStr(TempInt) );
      N_CMCDServObj34.CDSSetPatientFlag := True;
      //end;

      // ***** for capture
      N_CMCDServObj34.CDSFlagCapt := False;
      N_CMCDServObj34.CDSPrevStatus := -1;

      //N_Dump1Str( 'FireCR - Before RequestImageList' );
      //N_CMCDServObj34.CDSList := N_CMECDVDC_RequestImageList; // list of images from buffer
      //N_Dump1Str( 'FireCR - After RequestImageList' );

      N_CMCDServObj34.CDSPrevUID := 0; // initial state for UID
      N_Dump1Str( 'Started with PrevUID = 0' );

      N_CMCDServObj34.CDSTimerCount := 0; // initial state of timer count

      // ***** initial states
      N_CMCDServObj34.CDSSetPatientFlag := False;
      N_CMCDServObj34.CDSCalDataFin := False;
      N_CMCDServObj34.CDSPrevConnectType := 0;
      N_Dump1Str( 'Started with CDSPrevConnectType = 0' );
      N_CMCDServObj34.CDSPrevRFID := 0;
      N_Dump1Str( 'Started with CDSPrevRFID = 0' );

      N_FlagBuf := True; // not from buffer

      N_CMCDServObj34.CDSInit := True; // true for old sdk

      TimerCheck.Enabled := True;

      N_TempProgress := 0;
      N_TempSeconds := 0;

    end; // failed
  end; // else // old

  except
    on E : Exception do
    begin
     // if StatusLabel.Caption = 'Connected' then
     //     K_CMShowMessageDlg( 'Unable to get access to the specified device. ' +
     //           E.ClassName+' error raised, with message: '+E.Message, mtError )
     // else
     // K_CMShowMessageDlg( E.ClassName+' error raised, with message: '+E.Message,
     //                                                                 mtError );

      N_Dump1Str( E.ClassName+' error raised, with message: '+E.Message );
    end;
  end;

end; // procedure TN_CMCaptDev34Form.bnOpenClick( Sender: TObject );

//***************************************** TN_CMCaptDev34Form.bnCloseClick ***
// Close scanner
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.bnCloseClick( Sender: TObject );
var
  TempInt: Integer;
begin
  inherited;
  N_Dump1Str( 'Start CMOther15Form.FormClose' );
  // TimerCheck.Enabled := False;

  try

  if N_CMCDServObj34.CDSSDKOld then // old sdk
  begin
    TimerCheck.Enabled := False;

    // ***** set values for components
    if cbRFID.Checked then
      CMOFPProfile.CMDPStrPar1 := '0'//'1'
    else
      CMOFPProfile.CMDPStrPar1 := '0';

    CMOFPProfile.CMDPStrPar1 := CMOFPProfile.CMDPStrPar1 + '1'; // old sdk

    if N_CMCDServObj34.CDSImageFilter then
      CMOFPProfile.CMDPStrPar2 := '1'
    else
      CMOFPProfile.CMDPStrPar2 := '0';

    if N_CMCDServObj34.CDSImageFilterInd > 0 then
      CMOFPProfile.CMDPStrPar2 := CMOFPProfile.CMDPStrPar2 +
                                  IntToStr(N_CMCDServObj34.CDSImageFilterInd);


    if StatusLabel.Caption <> 'Disconnected' then
    begin
      N_Dump1Str( 'FireCR - Before CloseScanner' );
      N_CMECDVDC_CloseScannerOld(); // close sensor
      N_Dump1Str( 'FireCR - After CloseScanner' );
    end;

    N_Dump1Str( 'FireCR - Before CloseScannerSDK' );
    N_CMECDVDC_CloseScannerSDKOld(); // close callback
    N_Dump1Str( 'FireCR - After CloseScannerSDK' );

    FreeAndNil( CMOFDrawSlideObj );
    CMOFThumbsDGrid.Free;
    Inherited;

    N_CMCDServObj34.CDSInit := False; // not initialized again
    //N_CMCDServObj34.CDSFreeAll();

  end
  else // the new one
  begin

    // ***** set values for components
    //if cbRFID.Checked then
    //  CMOFPProfile.CMDPStrPar1[1] := '1'
    //else
    //  CMOFPProfile.CMDPStrPar1[1] := '0';

    if CMOFPProfile.CMDPStrPar1 = '' then
      CMOFPProfile.CMDPStrPar1[1] := '0';

    if CMOFPProfile.CMDPStrPar1[1] = '1' then
      CMOFPProfile.CMDPStrPar1 := '1'
    else
      CMOFPProfile.CMDPStrPar1 := '0';


    CMOFPProfile.CMDPStrPar1 := CMOFPProfile.CMDPStrPar1 + '0'; // new sdk
    CMOFPProfile.CMDPStrPar1 := CMOFPProfile.CMDPStrPar1 +
                                                   N_CMCDServObj34.CDSScannerIP;

    if N_CMCDServObj34.CDSImageFilter then
      CMOFPProfile.CMDPStrPar2 := '1'
    else
      CMOFPProfile.CMDPStrPar2 := '0';

    if N_CMCDServObj34.CDSImageFilterInd > 0 then
      CMOFPProfile.CMDPStrPar2 := CMOFPProfile.CMDPStrPar2 +
                                  IntToStr(N_CMCDServObj34.CDSImageFilterInd);


   // if StatusLabel.Caption <> 'Disconnected' then
    //begin

    if CMOFPProfile.CMDPStrPar1[1] = '0' then // no fire id
      N_CMECDVDC_Disconnect();

    N_Dump1Str( 'FireCR - Before CloseScanner' );
    TempInt := N_CMECDVDC_CloseScanner(); // close sensor
    N_Dump1Str( 'FireCR - After CloseScanner = ' + IntToStr(TempInt));
   // end;
    N_Dump1Str( 'FireCR - Before CloseScannerSDK' );
    N_CMECDVDC_CloseScannerSDK(); // close callback
    N_Dump1Str( 'FireCR - After CloseScannerSDK' );

  end; // else // the new one

  N_CMCDServObj34.CDSInit := False;
  N_CMCDServObj34.CDSScannerCallback := False;

  except
    on E : Exception do
    begin
    //  if StatusLabel.Caption = 'Connected' then
    //      K_CMShowMessageDlg( 'Unable to get access to the specified device. ' +
    //            E.ClassName+' error raised, with message: '+E.Message, mtError )
    //  else
    //  K_CMShowMessageDlg( E.ClassName+' error raised, with message: '+E.Message,
    //                                                                  mtError );

      N_Dump1Str( E.ClassName+' error raised, with message: '+E.Message );
    end;
  end;
end; // procedure TN_CMCaptDev34Form.bnCloseClick( Sender: TObject );

//********************************** TN_CMCaptDev34Form.bnSetPatientIDClick ***
// Set a patient ID
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.bnSetPatientIDClick( Sender: TObject );
var
  TempInt: integer;
begin
  N_Dump1Str( 'Start TN_CMCaptDev34Form.bnSetPatientIDClick' );
  inherited;

  if N_CMCDServObj34.CDSSDKOld then // old sdk
  begin
    N_CMCDServObj34.CDSPatientName := N_StringToAnsi(
       K_CMGetPatientDetails( -1, '(#PatientSurname#) (#PatientFirstName#)' ) );
    TempInt := N_CMECDVDC_SetPatientIDOld(
                                             @N_CMCDServObj34.CDSPatientName[1],
                                       Length(N_CMCDServObj34.CDSPatientName) );
    N_Dump1Str( 'N_CMECDVDC_SetPatientID = ' + IntToStr(TempInt) );
    N_Dump1Str( 'Finish TN_CMCaptDev34Form.bnSetPatientIDClick' );
  end
  else // the new one
  begin

    N_CMCDServObj34.CDSPatientName := N_StringToAnsi(
       K_CMGetPatientDetails( -1, '(#PatientSurname#) (#PatientFirstName#)' ) );
    TempInt := N_CMECDVDC_SetPatientID(
                                             @N_CMCDServObj34.CDSPatientName[1],
                                       Length(N_CMCDServObj34.CDSPatientName) );
    N_Dump1Str( 'N_CMECDVDC_SetPatientID = ' + IntToStr(TempInt) );
    N_Dump1Str( 'Finish TN_CMCaptDev34Form.bnSetPatientIDClick' );

  end;
end; // TN_CMCaptDev34Form.bnSetPatientIDClick

//********************************** TN_CMCaptDev34Form.bnGetPatientIDClick ***
// Get a patient ID
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.bnGetPatientIDClick(Sender: TObject);
begin
  N_Dump1Str( 'Start TN_CMCaptDev34Form.bnGetPatientIDClick' );
  inherited;
  N_Dump1Str( 'Finish TN_CMCaptDev34Form.bnGetPatientIDClick' );
end; // TN_CMCaptDev34Form.bnGetPatientIDClick

//************************************ TN_CMCaptDev34Form.cbFilterParChange ***
// Change a filter
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.cbFilterParChange(Sender: TObject);
begin
  N_Dump1Str( 'Start TN_CMCaptDev34Form.cbFilterParChange' );
  inherited;
  N_CMCDServObj34.CDSImageFilterInd := cbFilterPar.ItemIndex;
  N_Dump1Str( 'Finish TN_CMCaptDev34Form.cbFilterParChange' );
end;

procedure TN_CMCaptDev34Form.cbMaskClick(Sender: TObject);
var
  CapturedDIB: TN_DIBObj;
  RootComp:    TN_UDCompVis;
  Bitmap: TBitmap;
  N_NewSlide:     TN_UDCMSlide;
  TmpDir: string;
begin
  inherited;

  if CMOFSlideInit <> Nil then // do nothing from start
  if cbMask.Checked then
  begin

  TmpDir := K_ExpandFileName( '(#TmpFiles#)' );
//  CapturedDIB := CMOFPNewSlides^[0].ExportToDIB([]);


  N_Dump1Str(TmpDir+'\first.bmp');
  CMOFPNewSlides^[0].GetCurrentImage().DIBObj.SaveToBMPFormat(TmpDir+'\first.bmp');

  // applying negate
  //CapturedDIB.XORPixels( $FFFF );
  N_Dump1Str('1');
  //Bitmap := CMOFPNewSlides^[0].GetCurrentImage().DIBObj.CreateBitmap(CMOFPNewSlides^[0].GetCurrentImage().DIBObj.DIBRect);

 // Bitmap := CMOFPNewSlides^[0].GetCurrentImage().DIBObj
  Bitmap := TBitmap.Create();
  //Bitmap.PixelFormat := pf16bit;
//  Bitmap.Handle := CMOFPNewSlides^[0].GetCurrentImage().DIBObj.DIBHandle;
  //bm.SaveToFile( fn ); // save Bitmap to the file specified above
  //bm.Free;             // Close Bitmap handle
  N_Dump1Str('12');

  Bitmap.LoadFromFile(TmpDir+'\first.bmp');

 // if FileExists('d:\work\tempbmp.bmp') then
 //   DeleteFile('d:\work\tempbmp.bmp');

 // Bitmap.SaveToFile('d:\work\tempbmp.bmp');

  N_Dump1Str('2');
  FilterCornerMaskApply(TGraphic(Bitmap));

  Bitmap.SaveToFile(TmpDir+'\masked.bmp');

  N_Dump1Str('3');
  CapturedDIB := TN_DIBObj.Create(Bitmap);


  N_Dump1Str('4');
 // CMOFPNewSlides^[0].Se .GetCurrentImage().DIBObj := CapturedDIB;
  N_Dump1Str('5');
  N_NewSlide := K_CMSlideCreateFromDIBObj( CapturedDIB,
                                          @(CMOFPProfile^.CMAutoImgProcAttrs) );

  // Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number

  N_NewSlide.SetAutoCalibrated();
  N_NewSlide.ObjAliase := IntToStr(CMOFNumCaptured);

  with N_NewSlide.P()^ do
  begin
    CMSSourceDescr := CMOFPProfile^.CMDPCaption;
    N_NewSlide.ObjInfo := 'Captured from ' + CMSSourceDescr;
    CMSMediaType := CMOFPProfile^.CMDPMTypeID;
    N_NewSlide.SetInitDCMAttrs( TK_PCMDCMAttrs(@CMOFPProfile^.CMDPDModality) );
  end; // with NewSlide.P()^ do

   // // Add NewSlide to list of all Slides of current Patient
    K_CMEDAccess.EDAAddSlide( N_NewSlide ); // from now on NewSlide is owned by K_CMEDAccess

   // // Add NewSlide to beg of CMOFPNewSlides^ array
   // SetLength( CMOFPNewSlides^, CMOFNumCaptured );

  //  for i := High(CMOFPNewSlides^) downto 1 do // Shift all elems by 1
   //   CMOFPNewSlides^[i] := CMOFPNewSlides^[i - 1];

  CMOFPNewSlides^[0] := N_NewSlide;

  // Add NewSlide to CMOFThumbsDGrid
  // Inc(CMOFThumbsDGrid.DGNumItems);
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  RootComp := N_NewSlide.GetMapRoot();
  SlideRFrame.RFrShowComp(RootComp);

  N_Dump1Str(Format('Fin TN_CMCaptDev34Form.CMOFCaptureSlide %d',
                                                            [CMOFNumCaptured]));
  N_NewSlide := Nil; // cleaning
  //end;

  end
  else
  begin
//    N_NewSlide := CMOFSlideInit;

  // Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number

//  N_NewSlide.SetAutoCalibrated();
//  N_NewSlide.ObjAliase := IntToStr(CMOFNumCaptured);

//  with N_NewSlide.P()^ do
//  begin
//    CMSSourceDescr := CMOFPProfile^.CMDPCaption;
//    N_NewSlide.ObjInfo := 'Captured from ' + CMSSourceDescr;
//    CMSMediaType := CMOFPProfile^.CMDPMTypeID;
//    N_NewSlide.SetInitDCMAttrs( TK_PCMDCMAttrs(@CMOFPProfile^.CMDPDModality) );
//  end; // with NewSlide.P()^ do

   // // Add NewSlide to list of all Slides of current Patient
//    K_CMEDAccess.EDAAddSlide( N_NewSlide ); // from now on NewSlide is owned by K_CMEDAccess

   // // Add NewSlide to beg of CMOFPNewSlides^ array
   // SetLength( CMOFPNewSlides^, CMOFNumCaptured );

  //  for i := High(CMOFPNewSlides^) downto 1 do // Shift all elems by 1
   //   CMOFPNewSlides^[i] := CMOFPNewSlides^[i - 1];






//  CMOFPNewSlides^[0] := N_NewSlide;






K_CMSlideReplaceByDeviceDIBObj( CMOFPNewSlides^[0], CMOFSlideInit.GetCurrentImage().DIBObj, N_CMCDServObj34.CDSProfile, CMOFNumCaptured, 0 );



  // Add NewSlide to CMOFThumbsDGrid
  // Inc(CMOFThumbsDGrid.DGNumItems);
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  RootComp := CMOFSlideInit.GetMapRoot();
  SlideRFrame.RFrShowComp(RootComp);

  N_Dump1Str(Format('Fin TN_CMCaptDev34Form.CMOFCaptureSlide %d',
                                                            [CMOFNumCaptured]));
  N_NewSlide := Nil; // cleaning
  //end;
  end;

end;

// TN_CMCaptDev34Form.cbFilterParChange

//****************************************** TN_CMCaptDev34Form.cbRFIDClick ***
// Enables RFID Reader or disables it
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev34Form.cbRFIDClick( Sender: TObject );
begin
  inherited;
  N_Dump1Str( 'Start TN_CMCaptDev34Form.cbRFIDClick' );

  if N_CMCDServObj34.CDSInit then
  if N_CMCDServObj34.CDSSDKOld then // old sdk
  begin
    if cbRFID.Checked then
  begin
    N_Dump1Str( 'FireCR - Before SetRFIDListening(1)' );
    N_CMECDVDC_SetRFIDListeningOld(1);
    N_Dump1Str( 'FireCR - After SetRFIDListening(1)' )
  end else
  begin
    N_Dump1Str( 'FireCR - Before SetRFIDListening(0)' );
    N_CMECDVDC_SetRFIDListeningOld(0);
    N_Dump1Str( 'FireCR - After SetRFIDListening(0)' );
  end;
  end
  else // the new one
  begin

  if cbRFID.Checked then
  begin
    N_Dump1Str( 'FireCR - Before SetRFIDListening(1)' );
    N_CMECDVDC_SetRFIDListening(1);
    N_Dump1Str( 'FireCR - After SetRFIDListening(1)' )
  end else
  begin
    N_Dump1Str( 'FireCR - Before SetRFIDListening(0)' );
    N_CMECDVDC_SetRFIDListening(0);
    N_Dump1Str( 'FireCR - After SetRFIDListening(0)' );
  end;

  end;

  N_Dump1Str( 'Finish TN_CMCaptDev34Form.cbRFIDClick' );
end; // procedure TN_CMCaptDev34Form.cbRFIDClick

//************************************* TN_CMCaptDev34Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev34Form.CMOFCaptureSlide(): Integer;
var
  CapturedDIB: TN_DIBObj;
  i:           Integer;
  RootComp:    TN_UDCompVis;
  NDIB:        TN_DIBObj;
  TempSource:  PWord;
  ArraySource: array of Word;
begin
  N_Dump1Str( 'Start TN_CMCaptDev34Form.CMOFCaptureSlide' );
  N_Dump1Str( Format('Start TN_CMCaptDev34Form.CMOFCaptureSlide %d',
                                                           [CMOFNumCaptured]) );

  CapturedDIB := TN_DIBObj.Create();
  CapturedDIB.PrepEmptyDIBObj( N_CMCDServObj34.CDSWidth,
                         N_CMCDServObj34.CDSHeight, pfCustom, -1, epfGray16,
                                                                            16);

  // ***** create array with the pixel's colors
  SetLength(ArraySource, N_CMCDServObj34.CDSHeight*N_CMCDServObj34.CDSWidth);
  for i := 0 to Length(ArraySource) - 1 do
    begin
      TempSource := N_CMCDServObj34.CDSSource;
      Inc( TempSource, i );
      ArraySource[i] := TempSource^;
    end;

  // ***** fill the DIB
  for i := 0 to N_CMCDServObj34.CDSHeight - 1 do // along all pixel rows
  begin
    Move( ArraySource[(N_CMCDServObj34.CDSHeight-1-i)*
                         N_CMCDServObj34.CDSWidth], ( CapturedDIB.PRasterBytes +
     (i*CapturedDIB.RRLineSize) )^, N_CMCDServObj34.CDSWidth*Sizeof(SmallInt) );
  end;

  // applying negate
  CapturedDIB.XORPixels( $FFFF );

  // ***** autocontrast
//    NDIB := Nil;
//    CapturedDIB.CalcMaxContrastDIB( NDIB );
//    CapturedDIB.Free();
//    CapturedDIB := NDIB;

  // ***** image filter
  if N_CMCDServObj34.CDSImageFilter then
  begin
    N_Dump1Str( Format( 'Image Filter Par = %d', [cbFilterPar.ItemIndex] ) );
//      N_CMDIBAdjustLight( CapturedDIB ); // old var
    N_CMDIBAdjustByIntPar( CapturedDIB, cbFilterPar.ItemIndex );
  end else // use autocontrast
  begin
    NDIB := Nil;
    CapturedDIB.CalcMaxContrastDIB( NDIB );
    CapturedDIB.Free();
    CapturedDIB := NDIB;
  end;

  if N_CMCDServObj34.CDSSDKOld then // old sdk
  begin

  // ***** set pixel size
  with CapturedDIB.DIBInfo.bmi do
  begin
    if N_CMECDVDC_GetResolutionOld() = 0 then // if SD
    begin
      biXPelsPerMeter := 15625; // 64 um for pixel
      biYPelsPerMeter := biXPelsPerMeter;
    end
    else // is HD
    begin
      biXPelsPerMeter := Round( 1000000/35 ); // 35 um for pixel
      biYPelsPerMeter := biXPelsPerMeter;
    end;
  end;
  // ***** Here: CapturedDIB is OK

  end
  else
  begin

   // ***** set pixel size
  with CapturedDIB.DIBInfo.bmi do
  begin
    if N_CMECDVDC_GetResolution() = 0 then // if SD
    begin
      biXPelsPerMeter := 15625; // 64 um for pixel
      biYPelsPerMeter := biXPelsPerMeter;
    end
    else // is HD
    begin
      biXPelsPerMeter := Round( 1000000/35 ); // 35 um for pixel
      biYPelsPerMeter := biXPelsPerMeter;
    end;
  end;
  // ***** Here: CapturedDIB is OK

  end;

  N_NewSlide := K_CMSlideCreateFromDIBObj( CapturedDIB,
                                          @(CMOFPProfile^.CMAutoImgProcAttrs) );
  N_FlagGot := True;
  if N_FlagBuf then
  begin
    Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number

    N_NewSlide.SetAutoCalibrated();
    N_NewSlide.ObjAliase := IntToStr(CMOFNumCaptured);

    with N_NewSlide.P()^ do
    begin
      CMSSourceDescr := CMOFPProfile^.CMDPCaption;
      N_NewSlide.ObjInfo := 'Captured from ' + CMSSourceDescr;
      CMSMediaType := CMOFPProfile^.CMDPMTypeID;
      N_NewSlide.SetInitDCMAttrs( TK_PCMDCMAttrs(@CMOFPProfile^.CMDPDModality) );
    end; // with NewSlide.P()^ do

    // Add NewSlide to list of all Slides of current Patient
    K_CMEDAccess.EDAAddSlide( N_NewSlide ); // from now on NewSlide is owned by K_CMEDAccess

    // Add NewSlide to beg of CMOFPNewSlides^ array
    SetLength( CMOFPNewSlides^, CMOFNumCaptured );

    for i := High(CMOFPNewSlides^) downto 1 do // Shift all elems by 1
      CMOFPNewSlides^[i] := CMOFPNewSlides^[i - 1];

    CMOFPNewSlides^[0] := N_NewSlide;
    CMOFSlideInit := N_NewSlide; // initial version for mask

    // Add NewSlide to CMOFThumbsDGrid
    Inc(CMOFThumbsDGrid.DGNumItems);
    CMOFThumbsDGrid.DGInitRFrame();
    CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

    // Show NewSlide in SlideRFrame
    RootComp := N_NewSlide.GetMapRoot();
    SlideRFrame.RFrShowComp(RootComp);

    N_Dump1Str(Format('Fin TN_CMCaptDev34Form.CMOFCaptureSlide %d',
                                                            [CMOFNumCaptured]));
    N_NewSlide := Nil; // cleaning
  end;
  Result := 0;
  N_Dump1Str( 'End TN_CMCaptDev34Form.CMOFCaptureSlide' );
end; // end of TN_CMCaptDev34Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev34Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev34Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev34Form.CurStateToMemIni

//************************************* TN_CMCaptDev34Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev34Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev34Form.MemIniToCurState

end.
