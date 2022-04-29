unit N_CMCaptDev15SF;
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
  N_CMCaptDev15bF, Buttons, K_FCMDeviceSetupEnter;

type TN_CMCaptDev15Form = class( TN_BaseForm )
  MainPanel: TPanel;
  RightPanel: TPanel;
  SlidePanel: TPanel;
  bnExit: TButton;
  ThumbsRFrame: TN_Rast1Frame;
  SlideRFrame: TN_Rast1Frame;
  TimerCheck: TTimer;
  TimerBuf: TTimer;
    CtrlsPanelParent: TPanel;
    CtrlsPanel: TPanel;
    bnSetup: TButton;
    BitBtnGetImage: TBitBtn;
    cbAutoTake: TCheckBox;
    ProgressBar: TProgressBar;
    cbRFID: TCheckBox;
    cbFilterPar: TComboBox;
    Edit1: TEdit;
    bnSetPatientID: TButton;
    bnGetPatientID: TButton;
    tbRotateImage: TToolBar;
    tbLeft90: TToolButton;
    tbRight90: TToolButton;
    tb180: TToolButton;
    tbFlipHor: TToolButton;
    bnCapture: TButton;
    StatusShape: TShape;
    StatusLabel: TLabel;
    lbUID: TLabel;
    Label1: TLabel;

  //********************  TN_CMCaptDev15Form class handlers  ******************

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
  procedure Button1Click(Sender: TObject);
  procedure Button2Click(Sender: TObject);
  procedure BitBtnGetImageClick(Sender: TObject);

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

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide (): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
    procedure SaveImageFromBuffer();
end; // type TN_CMCaptDev15Form = class( TN_BaseForm )

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
  N_CMCaptDev15S, N_CMCaptDev15aF;
{$R *.dfm}

//**********************  TN_CMCaptDev15Form class handlers  ******************

//********************************************* TN_CMCaptDev15Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev15Form.FormShow( Sender: TObject );
var
  TempStr1: WideString;
  TempStr2: string;
  TempInt:  Integer;
begin
  N_Dump1Str( '****************** Start FireCR ******************' );
  N_Dump1Str( 'Start CMOther15Form.FormShow' );

  N_CMCDServObj15.CDSInit := True; // will be init through here, for settings

  // ***** setting component's values
  if CMOFPProfile.CMDPStrPar1 = '1' then
  begin
    cbRFID.Checked := True;
  end
  else
  begin
    cbRFID.Checked := False;
  end;

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

  if (CMOFPProfile.CMDPStrPar2 = '') or
     (CMOFPProfile.CMDPStrPar2[1] = '1') then // get initial state for Image Filter CB
    N_CMCDServObj15.CDSImageFilter := True
  else
    N_CMCDServObj15.CDSImageFilter := False;

  N_CMCDServObj15.CDSImageFilterInd := 0;
  if Length(CMOFPProfile.CMDPStrPar2) > 1 then
    N_CMCDServObj15.CDSImageFilterInd := StrToIntDef(
                                               CMOFPProfile.CMDPStrPar2[2], 0 );
  // set Image Filter index
  cbFilterPar.ItemIndex := N_CMCDServObj15.CDSImageFilterInd;

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
//  tbRotateImage.Visible := True; // !!!  not needed because is already visible
  TimerCheck.Enabled := True;

  N_CMCDServObj15.CDSUID := 0; // set default UID

  // ***** setting callback-functions
  N_CMCDServObj15.CDSCallBacks.CBSRFIDNotifyEvent	:= @N_OnRFIDNotify;
	N_CMCDServObj15.CDSCallBacks.CBSRFIDStatusEvent	:= Nil;
	N_CMCDServObj15.CDSCallBacks.CBSScannerNotifyEvent := @N_OnScannerNotify;
	N_CMCDServObj15.CDSCallBacks.CBSScannerStatusEvent := Nil;

  TempStr1 := '.'; // path to config file
  TempStr2 := '.';//K_GetDirPath( 'CMSWrkFiles' );
  //CreateDir( TempStr2 );
  //TempStr2 := TempStr2 + '!CaptDevInfo'; // path to config file
  //CreateDir( TempStr2 );
  //TempStr1 := N_StringToWide( TempStr2 );

  N_CMCDServObj15.CDSCalDataDir := TempStr2;

  N_Dump1Str( 'FireCR - Before OpenScannerSDK' );
	TempInt := N_CMECDVDC_OpenScannerSDK( 0, @N_CMCDServObj15.CDSCallBacks,
                                                                 @TempStr1[1] ); // starting callback
  N_Dump1Str( 'FireCR - After OpenScannerSDK = ' + IntToStr(TempInt) );

  N_CMCDServObj15.CDSPrevProgress := 0; // need for capture image
  N_Dump1Str( 'FireCR - Before OpenScanner' );
  TempInt := N_CMECDVDC_OpenScanner();
  N_Dump1Str( 'FireCR - After OpenScanner = ' + IntToStr(TempInt) );

  if TempInt <> 0 then
  begin
    N_CMCDServObj15.CDSPatientName := N_StringToAnsi(
       K_CMGetPatientDetails( -1, '(#PatientSurname#) (#PatientFirstName#)' ) );
    N_Dump1Str( 'FireCR - Before SetPatientID' );
    TempInt := N_CMECDVDC_SetPatientID( @N_CMCDServObj15.CDSPatientName[1],
                                       Length(N_CMCDServObj15.CDSPatientName) );
    N_Dump1Str( 'FireCR - After SetPatientID = ' + IntToStr(TempInt) );
    N_CMCDServObj15.CDSSetPatientFlag := True;
  end;

  // ***** for capture
  N_CMCDServObj15.CDSFlagCapt := False;
  N_CMCDServObj15.CDSPrevStatus := -1;

  //N_Dump1Str( 'FireCR - Before RequestImageList' );
  //N_CMCDServObj15.CDSList := N_CMECDVDC_RequestImageList; // list of images from buffer
  //N_Dump1Str( 'FireCR - After RequestImageList' );

  N_CMCDServObj15.CDSPrevUID := 0; // initial state for UID
  N_Dump1Str( 'Started with PrevUID = 0' );

  N_CMCDServObj15.CDSTimerCount := 0; // initial state of timer count

  // ***** initial states
  N_CMCDServObj15.CDSSetPatientFlag := False;
  N_CMCDServObj15.CDSCalDataFin := False;
  N_CMCDServObj15.CDSPrevConnectType := 0;
  N_Dump1Str( 'Started with CDSPrevConnectType = 0' );
  N_CMCDServObj15.CDSPrevRFID := 0;
  N_Dump1Str( 'Started with CDSPrevRFID = 0' );

  N_FlagBuf := True; // not from buffer

  N_TempProgress := 0;
  N_TempSeconds := 0;
  N_Dump1Str( 'End CMOther15Form.FormShow' );
end; // procedure TN_CMCaptDev15Form.FormShow

//******************************************** TN_CMCaptDev15Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev15Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin
  N_Dump1Str( 'Start CMOther15Form.FormClose' );
  TimerCheck.Enabled := False;

  // ***** set values for components
  if cbRFID.Checked then
    CMOFPProfile.CMDPStrPar1 := '1'
  else
    CMOFPProfile.CMDPStrPar1 := '0';

  if N_CMCDServObj15.CDSImageFilter then
    CMOFPProfile.CMDPStrPar2 := '1'
  else
    CMOFPProfile.CMDPStrPar2 := '0';

  if N_CMCDServObj15.CDSImageFilterInd > 0 then
    CMOFPProfile.CMDPStrPar2 := CMOFPProfile.CMDPStrPar2 +
                                  IntToStr(N_CMCDServObj15.CDSImageFilterInd);


  if StatusLabel.Caption <> 'Disconnected' then
  begin

  N_Dump1Str( 'FireCR - Before CloseScanner' );
  N_CMECDVDC_CloseScanner(); // close sensor
  N_Dump1Str( 'FireCR - After CloseScanner' );
  end;
  N_Dump1Str( 'FireCR - Before CloseScannerSDK' );
  N_CMECDVDC_CloseScannerSDK(); // close callback
  N_Dump1Str( 'FireCR - After CloseScannerSDK' );



  FreeAndNil( CMOFDrawSlideObj );
  CMOFThumbsDGrid.Free;
  Inherited;

  N_CMCDServObj15.CDSInit := False; // not initialized again
  N_CMCDServObj15.CDSFreeAll();

  N_Dump1Str( 'End CMOther15Form.FormClose' );
  N_Dump1Str( '****************** End FireCR ******************' );
end; // TN_CMCaptDev15Form.FormClose

//****************************************** TN_CMCaptDev15Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev15Form.FormKeyDown( Sender: TObject; var Key: Word;
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
end; // procedure TN_CMCaptDev15Form.FormKeyDown

//******************************************** TN_CMCaptDev15Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev15Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  N_Dump1Str( 'Start CMOther15Form.FormKeyUp' );
  Exit;
  N_Dump1Str( 'End CMOther15Form.FormKeyUp' );
end; // procedure TN_CMCaptDev15Form.FormKeyUp

// ************************************ TN_CMCaptDev15Form.SlidePanelResize ***
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev15Form.SlidePanelResize( Sender: TObject );
var
  RootComp: TN_UDCompVis;
begin
  N_Dump1Str( 'Start CMOther15Form.SlidePanelResize' );
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
  N_Dump1Str( 'End CMOther15Form.SlidePanelResize' );
end; // procedure TN_CMCaptDev15Form.SlidePanelResize

//********************************** TN_CMCaptDev15Form.BitBtnGetImageClick ***
// Show form in which images from buffer are get
//
//     Parameters
// Sender - Event Sender
//
// BitBtnGetImage button OnClick handler
//
{procedure TN_CMCaptDev15Form.BitBtnGetImageClick( Sender: TObject );
var
  Form: TN_CMCaptDev15aForm;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15Form.BitBtnGetImageClick' );
  inherited;

  Form := TN_CMCaptDev15aForm.Create( Application );
  Form.BaseFormInit( Nil, '', [ rspfMFRect, rspfCenter ], [ rspfAppWAR,
                                                               rspfShiftAll ] );
  Form.Caption := 'Recover Image';
  Form.CMOFParentForm := Self;
  Form.ShowModal();
  N_Dump1Str( 'Finish TN_CMCaptDev15Form.BitBtnGetImageClick' );
end;    }

//**************************************** TN_CMCaptDev15Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev15Form.tbLeft90Click( Sender: TObject );
begin
  N_Dump1Str( 'Start CMOther15Form.tbLeft90Click' );
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
  N_Dump1Str( 'End CMOther15Form.tbLeft90Click' );
end; // procedure TN_CMCaptDev15Form.tbLeft90Click

//*************************************** TN_CMCaptDev15Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev15Form.tbRight90Click( Sender: TObject );
begin
  N_Dump1Str( 'Start CMOther15Form.tbRight90Click' );
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
  N_Dump1Str( 'End CMOther15Form.tbRight90Click' );
end; // TN_CMCaptDev15Form.tbRight90Click

procedure TN_CMCaptDev15Form.SaveImageFromBuffer();
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

      // Add NewSlide to CMOFThumbsDGrid
      Inc(CMOFThumbsDGrid.DGNumItems);
      CMOFThumbsDGrid.DGInitRFrame();
      CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

      // Show NewSlide in SlideRFrame
      RootComp := N_NewSlide.GetMapRoot();
      SlideRFrame.RFrShowComp(RootComp);

      N_NewSlide := Nil; // cleaning

      //FlagSave := False;
    end;
  //end;
  N_Dump1Str( 'End CMOther15Form.SaveImageFromBuffer' );
end;

//*************************************** TN_CMCaptDev15Form.TimerBufTimer ***
// Timer actions for saving an image from the device buffer
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev15Form.TimerBufTimer(Sender: TObject);
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
end; // procedure TN_CMCaptDev15Form.TimerBufTimer(Sender: TObject);

//************************************** TN_CMCaptDev15Form.TimerCheckTimer ***
// Timer main actions
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev15Form.TimerCheckTimer( Sender: TObject );
var
  TempStatus, TempRFID, Count: Integer;
  Params:   PN_ScannerIntro;
  //IsFile: Boolean;
  //F: TSearchRec;
begin
  TimerCheck.Enabled := False;

  // ***** counting the time for Dump
  Inc( N_CMCDServObj15.CDSTimerCount );
  if N_CMCDServObj15.CDSTimerCount > 25 then
  begin
    N_Dump1Str( 'FireCR - Timer - Passed ~5 sec' );
    N_CMCDServObj15.CDSTimerCount := 0;
  end; // if N_CMCDServObj15.CDSTimerCount > 25 then

  // ***** get connection type and set components
  N_CMCDServObj15.CDSScannerConnectionType :=
                                            N_CMECDVDC_GetScannerConnectionType;

  // ***** dump connection type if it's differ from the last one
  if N_CMCDServObj15.CDSPrevConnectType <>
                                   N_CMCDServObj15.CDSScannerConnectionType then
  begin
    N_Dump1Str( 'FireCR - Timer - Scanner Connection Type = ' +
                           IntToStr(N_CMCDServObj15.CDSScannerConnectionType) );

    N_CMCDServObj15.CDSPrevConnectType :=
                                       N_CMCDServObj15.CDSScannerConnectionType;
  end;

  if N_CMCDServObj15.CDSScannerConnectionType = 2 then // N to N connection
  begin
    cbRFID.Visible := True;
    lbUID.Visible  := True;
  end else // other connections
  begin
    cbRFID.Visible := False;
    lbUID.Visible  := False;
  end;

  // ***** set RFID Reader checkbox
  TempRFID := N_CMECDVDC_GetRFIDListening();

  // ***** dump RFID Listening if it's differ from the last one
  if N_CMCDServObj15.CDSPrevRFID <> TempRFID then
  begin
    N_Dump1Str( 'FireCR - Timer - RFID Listening = ' + IntToStr(TempRFID) );
    N_CMCDServObj15.CDSPrevRFID := TempRFID;
  end;

  if TempRFID = 1 then
  begin
    cbRFID.Checked := True;
    LbUID.Visible  := True;
  end else // TempRFID <> 1
  begin
    cbRFID.Checked := False;
    LbUID.Visible  := False;
  end;

  // ***** get and show UID
  if N_CMCDServObj15.CDSUID <> 0 then
    LbUID.Caption := Format('UID: %x', [ N_CMCDServObj15.CDSUID ] )
  else
    LbUID.Caption := 'UID: None';

  // ***** dump UID if it's differ from the last one
  if N_CMCDServObj15.CDSUID <> N_CMCDServObj15.CDSPrevUID then
  begin
    N_Dump1Str( Format('FireCR - Timer - UID = %x', [N_CMCDServObj15.CDSUID]) );
    N_CMCDServObj15.CDSPrevUID := N_CMCDServObj15.CDSUID;
  end;

  // ***** get and show progress of the action
  N_TempProgress := N_CMECDVDC_GetProgress; // get capture progress (0-1000)

  if N_TempProgress = 1000 then
    N_TempProgress := 0;

    if N_FlagBuf then
  begin
    ProgressBar.Position := N_TempProgress; // progress to form
  end;

  if N_TempProgress <> 0 then
    N_Dump1Str( 'FireCR - Timer - Progress = ' + IntToStr(N_TempProgress) );

  TempStatus := N_CMECDVDC_GetScannerStatus(); // get status

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
      Params := N_CMECDVDC_RequestScannerList( @Count ); // scanner parameters
      N_Dump1Str( 'FireCR - After RequestScannerList( @Count ), Count = 0' );
      if not Assigned( Params ) then
        N_Dump1Str( 'FireCR - Scanner List is not assigned' );
      N_Dump1Str( 'FireCR - Scanner List PN: ' + N_AnsiToString(Params.SIPN) );

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

  if N_CMCDServObj15.CDSPrevStatus <> TempStatus then // so it won't blink
  begin
    StatusLabel.Repaint;
    StatusShape.Repaint;
    N_Dump1Str( 'FireCR - Timer - Scanner Status = ' + IntToStr(TempStatus) );
  end;

  N_CMCDServObj15.CDSPrevStatus := TempStatus; // change previous status

  // ***** the image is get
  if N_CMCDServObj15.CDSFlagCapt = True then
  begin
    N_Dump1Str( 'FlagCapt = True' );
    N_CMCDServObj15.CDSFlagCapt := False;

  //  if not N_CMCDServObj15.CDSSetPatientFlag then // add name just in case
  //  begin
  //    N_Dump1Str( 'FireCR - still not N_CMCDServObj15.CDSSetPatientFlag' );
  //    N_CMCDServObj15.CDSPatientName := N_StringToAnsi(
  //                                                    K_CMGetPatientDetails( -1,
  //                                '(#PatientSurname#) (#PatientFirstName#)' ) );
  //    N_Dump1Str( 'FireCR - Before SetPatientID' );
  //    TempInt := N_CMECDVDC_SetPatientID( @N_CMCDServObj15.CDSPatientName[1],
  //                                     Length(N_CMCDServObj15.CDSPatientName) );
  //    N_Dump1Str( 'FireCR - After SetPatientID = ' + IntToStr(TempInt) );
  //  end;

    N_Dump1Str( 'Before GetImageSize( @Width, @Height )' );
    N_CMECDVDC_GetImageSize( @N_CMCDServObj15.CDSWidth,
                                                   @N_CMCDServObj15.CDSHeight ); // get image size
    N_Dump1Str( 'After GetImageSize( @Width, @Height ), Width = ' +
                              IntToStr(N_CMCDServObj15.CDSWidth) + ', Height = '
                                        + IntToStr(N_CMCDServObj15.CDSHeight) );


    N_Dump1Str( 'Before GetImageBuffer' );
    N_CMCDServObj15.CDSSource := N_CMECDVDC_GetImageBuffer(); // get buffer
    N_Dump1Str( 'After GetImageBuffer' );
    N_Dump1Str( 'Before CMOFCaptureSlide' );

    CMOFCaptureSlide(); // save slide
  end;

  TimerCheck.Enabled := True;
end; // procedure TN_CMCaptDev15Form.TimerCheckTimer

//******************************************* TN_CMCaptDev15Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev15Form.tb180Click( Sender: TObject );
begin
  N_Dump1Str( 'Start CMOther15Form.tb180Click' );
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
  N_Dump1Str( 'End CMOther15Form.tb180Click' );
end; // procedure TN_CMCaptDev15Form.tb180Click

//*************************************** TN_CMCaptDev15Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev15Form.tbFlipHorClick( Sender: TObject );
begin
  N_Dump1Str( 'Start CMOther15Form.tbFlipHorClick' );
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
  N_Dump1Str( 'End CMOther15Form.tbFlipHorClick' );
end; // procedure TN_CMCaptDev15Form.tbFlipHorClick


//**********************  TN_CMCaptDev15Form class public methods  ************

//**************************************** TN_CMCaptDev15Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev15Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  N_Dump1Str( 'Start CMOther15Form.CMOFDrawThumb' );
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
  N_Dump1Str( 'End CMOther15Form.CMOFDrawThumb' );
end; // end of TN_CMCaptDev15Form.CMOFDrawThumb

//************************************* TN_CMCaptDev15Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev15Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
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
end; // procedure TN_CMCaptDev15Form.CMOFGetThumbSize

//********************************** TN_CMCaptDev15Form.BitBtnGetImageClick ***
// Show form in which images from buffer are get
//
//     Parameters
// Sender - Event Sender
//
// BitBtnGetImage button OnClick handler
//
procedure TN_CMCaptDev15Form.BitBtnGetImageClick( Sender: TObject );
var
  Form: TN_CMCaptDev15aForm;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15Form.BitBtnGetImageClick' );
  inherited;

  Form := TN_CMCaptDev15aForm.Create( Application );
  Form.BaseFormInit( Nil, '', [ rspfMFRect, rspfCenter ], [ rspfAppWAR,
                                                               rspfShiftAll ] );
  Form.Caption := 'Recover Image';
  Form.CMOFParentForm := Self;
  Form.ShowModal();
  N_Dump1Str( 'Finish TN_CMCaptDev15Form.BitBtnGetImageClick' );
end;

//****************************************** TN_CMCaptDev15Form.bnExitClick ***
// Exit
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev15Form.bnExitClick( Sender: TObject );
begin
  inherited;
end; // procedure TN_CMCaptDev15Form.bnExitClick

//***************************************** TN_CMCaptDev15Form.bnSetupClick ***
// Setup form
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev15Form.bnSetupClick( Sender: TObject );
var
  Form: TN_CMCaptDev15bForm;
begin
  inherited;
  N_Dump1Str( 'Start TN_CMCaptDev15Form.bnSetupClick' );

  TimerCheck.Enabled := False; // disable timer

  // ***** show device settings
  Form := TN_CMCaptDev15bForm.Create( Application );
  Form.BaseFormInit( Nil, '', [ rspfMFRect, rspfCenter ], [ rspfAppWAR,
    rspfShiftAll ] );
  Form.Caption := 'Setup';
  Form.ShowModal();

  {var
  TempStr2: string;
  TempStr1: WideString;
  TempInt: Integer;

  N_CMECDVDC_CloseScanner(); // close sensor
  N_CMECDVDC_CloseScannerSDK(); // close callback
  N_Dump1Str( 'N_CMECDVDC_CloseScanner(), N_CMECDVDC_CloseScannerSDK()' );

  // set path to ini-file (config file)
  TempStr2 := K_GetDirPath( 'CMSWrkFiles' );
  CreateDir( TempStr2 );
  TempStr2 := TempStr2 + '!CaptDevInfo'; // path to config file
  CreateDir( TempStr2 );
  TempStr1 := N_StringToWide( TempStr2 );

	TempInt := N_CMECDVDC_OpenScannerSDK( 0, @N_CMCDServObj15.CDSCallBacks, @TempStr1[1] ); // starting callback
  N_Dump1Str( 'N_CMECDVDC_OpenScannerSDK() = ' + IntToStr(TempInt) );

  N_CMCDServObj15.CDSPrevProgress := 0; // need for capture image
  TempInt := N_CMECDVDC_OpenScanner();
  N_Dump1Str( 'N_CMECDVDC_OpenScanner() = ' + IntToStr(TempInt) );  }

  {// ***** set RFID Reader
  if cbRFID.Checked then
    N_CMECDVDC_SetRFIDListening(1)
  else
    N_CMECDVDC_SetRFIDListening(0); }

  TimerCheck.Enabled := True; // enable timer

  N_Dump1Str( 'Finish TN_CMCaptDev15Form.bnSetupClick' );
end;

procedure TN_CMCaptDev15Form.Button1Click(Sender: TObject);
var
  Form: TN_CMCaptDev15aForm;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15Form.BitBtnGetImageClick' );
  inherited;

  Form := TN_CMCaptDev15aForm.Create( Application );
  Form.BaseFormInit( Nil, '', [ rspfMFRect, rspfCenter ], [ rspfAppWAR,
                                                               rspfShiftAll ] );
  Form.Caption := 'Recover Image';
  Form.CMOFParentForm := Self;
  Form.ShowModal();
  N_Dump1Str( 'Finish TN_CMCaptDev15Form.BitBtnGetImageClick' );
end;

procedure TN_CMCaptDev15Form.Button2Click(Sender: TObject);
begin
  inherited;
  bnSetup.Enabled := True;
end;

// procedure TN_CMCaptDev15Form.bnSetupClick

//********************************** TN_CMCaptDev15Form.bnSetPatientIDClick ***
// Set a patient ID
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev15Form.bnSetPatientIDClick( Sender: TObject );
var
  TempInt: integer;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15Form.bnSetPatientIDClick' );
  inherited;

  N_CMCDServObj15.CDSPatientName := N_StringToAnsi(
       K_CMGetPatientDetails( -1, '(#PatientSurname#) (#PatientFirstName#)' ) );
  TempInt := N_CMECDVDC_SetPatientID(
   @N_CMCDServObj15.CDSPatientName[1], Length(N_CMCDServObj15.CDSPatientName) );
  N_Dump1Str( 'N_CMECDVDC_SetPatientID = ' + IntToStr(TempInt) );
  N_Dump1Str( 'Finish TN_CMCaptDev15Form.bnSetPatientIDClick' );
end; // TN_CMCaptDev15Form.bnSetPatientIDClick

//********************************** TN_CMCaptDev15Form.bnGetPatientIDClick ***
// Get a patient ID
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev15Form.bnGetPatientIDClick(Sender: TObject);
var
  TempAnsi: PAnsiChar;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15Form.bnGetPatientIDClick' );
  inherited;
  TempAnsi := N_CMECDVDC_GetPatientID(StrToInt(Edit1.Text));
  ShowMessage(N_AnsiToString(AnsiString(TempAnsi)));
  N_Dump1Str( 'After GetPatientID, Name = ' + N_AnsiToString(
                                                        AnsiString(TempAnsi) ));
  N_Dump1Str( 'Finish TN_CMCaptDev15Form.bnGetPatientIDClick' );
end; // TN_CMCaptDev15Form.bnGetPatientIDClick

//************************************ TN_CMCaptDev15Form.cbFilterParChange ***
// Change a filter
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev15Form.cbFilterParChange(Sender: TObject);
begin
  N_Dump1Str( 'Start TN_CMCaptDev15Form.cbFilterParChange' );
  inherited;
  N_CMCDServObj15.CDSImageFilterInd := cbFilterPar.ItemIndex;
  N_Dump1Str( 'Finish TN_CMCaptDev15Form.cbFilterParChange' );
end; // TN_CMCaptDev15Form.cbFilterParChange

//****************************************** TN_CMCaptDev15Form.cbRFIDClick ***
// Enables RFID Reader or disables it
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev15Form.cbRFIDClick( Sender: TObject );
begin
  inherited;
  N_Dump1Str( 'Start TN_CMCaptDev15Form.cbRFIDClick' );

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

  N_Dump1Str( 'Finish TN_CMCaptDev15Form.cbRFIDClick' );
end; // procedure TN_CMCaptDev15Form.cbRFIDClick

//************************************* TN_CMCaptDev15Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev15Form.CMOFCaptureSlide(): Integer;
var
  CapturedDIB: TN_DIBObj;
  i:           Integer;
  RootComp:    TN_UDCompVis;
  NDIB:        TN_DIBObj;
  TempSource:  PWord;
  ArraySource: array of Word;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15Form.CMOFCaptureSlide' );
  N_Dump1Str( Format('Start TN_CMCaptDev15Form.CMOFCaptureSlide %d',
                                                           [CMOFNumCaptured]) );

  CapturedDIB := TN_DIBObj.Create();
  CapturedDIB.PrepEmptyDIBObj( N_CMCDServObj15.CDSWidth,
                         N_CMCDServObj15.CDSHeight, pfCustom, -1, epfGray16,
                                                                            16);

  // ***** create array with the pixel's colors
  SetLength(ArraySource, N_CMCDServObj15.CDSHeight*N_CMCDServObj15.CDSWidth);
  for i := 0 to Length(ArraySource) - 1 do
    begin
      TempSource := N_CMCDServObj15.CDSSource;
      Inc( TempSource, i );
      ArraySource[i] := TempSource^;
    end;

  // ***** fill the DIB
  for i := 0 to N_CMCDServObj15.CDSHeight - 1 do // along all pixel rows
  begin
    Move( ArraySource[(N_CMCDServObj15.CDSHeight-1-i)*
                         N_CMCDServObj15.CDSWidth], ( CapturedDIB.PRasterBytes +
     (i*CapturedDIB.RRLineSize) )^, N_CMCDServObj15.CDSWidth*Sizeof(SmallInt) );
  end;

  // applying negate
  CapturedDIB.XORPixels( $FFFF );

  // ***** autocontrast
//    NDIB := Nil;
//    CapturedDIB.CalcMaxContrastDIB( NDIB );
//    CapturedDIB.Free();
//    CapturedDIB := NDIB;

  // ***** image filter
  if N_CMCDServObj15.CDSImageFilter then
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

    // Add NewSlide to CMOFThumbsDGrid
    Inc(CMOFThumbsDGrid.DGNumItems);
    CMOFThumbsDGrid.DGInitRFrame();
    CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

    // Show NewSlide in SlideRFrame
    RootComp := N_NewSlide.GetMapRoot();
    SlideRFrame.RFrShowComp(RootComp);

    N_Dump1Str(Format('Fin TN_CMCaptDev15Form.CMOFCaptureSlide %d',
                                                            [CMOFNumCaptured]));
    N_NewSlide := Nil; // cleaning
  end;
  Result := 0;
  N_Dump1Str( 'End TN_CMCaptDev15Form.CMOFCaptureSlide' );
end; // end of TN_CMCaptDev15Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev15Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev15Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev15Form.CurStateToMemIni

//************************************* TN_CMCaptDev15Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev15Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev15Form.MemIniToCurState

end.
