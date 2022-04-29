unit N_CMCaptDev12F;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F;

type TN_CMCaptDev12Form = class( TN_BaseForm )
    MainPanel: TPanel;
    RightPanel: TPanel;
    SlidePanel: TPanel;
    bnExit: TButton;
    ThumbsRFrame: TN_Rast1Frame;
    StatusShape: TShape;
    StatusLabel: TLabel;
    SlideRFrame: TN_Rast1Frame;
    bnCapture: TButton;
    tbRotateImage: TToolBar;
    tbLeft90: TToolButton;
    tbRight90: TToolButton;
    tb180: TToolButton;
    tbFlipHor: TToolButton;
    cbAutoTake: TCheckBox;
    bnSetup: TButton;
    TimerCheck: TTimer;
    CmBIPPMode: TComboBox;
    cbRawImage: TCheckBox;
    LbSerialText: TLabel;
    LbSerialID: TLabel;

    //******************  TN_CMCaptDev12Form class handlers  ******************

    procedure FormShow         ( Sender: TObject );
    procedure FormClose        ( Sender: TObject; var Action: TCloseAction );
                                                                       override;
    procedure FormKeyDown      ( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
    procedure FormKeyUp        ( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
    procedure SlidePanelResize ( Sender: TObject );
    procedure bnCaptureClick   ( Sender: TObject );
    procedure tbLeft90Click    ( Sender: TObject );
    procedure tbRight90Click   ( Sender: TObject );
    procedure tb180Click       ( Sender: TObject );
    procedure tbFlipHorClick   ( Sender: TObject );
    procedure cbAutoTakeClick  ( Sender: TObject);
    procedure UpDown1Click     ( Sender: TObject; Button: TUDBtnType );
    procedure bnSetupClick     ( Sender: TObject );
    procedure bnExitClick      ( Sender: TObject );
    procedure TimerCheckTimer  ( Sender: TObject );
    procedure CmBIPPModeChange ( Sender: TObject );
    procedure cbRawImageClick  ( Sender: TObject );
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

    ThisForm: TN_CMCaptDev12Form;        // Pointer to this form

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide (): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;

end; // type TN_CMCaptDev12Form = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

const // Form states
  N_CMOF4Unknown   = 0;
  N_CMOF4Manual    = 1;
  N_CMOF4Auto      = 2;

var
  N_Sel: Integer; // for CmBIPPMode's index
  ExtLogFlag: Boolean;

implementation

uses
  Math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev12;
{$R *.dfm}

//**********************  TN_CMCaptDev12Form class handlers  ******************

//********************************************* TN_CMCaptDev12Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev12Form.FormShow( Sender: TObject );
var
  TempStr1, TempStr2: AnsiString;
begin
  N_Dump1Str( 'MediaRay+ Start FormShow' );

  N_LastErrMsg := '';

  //TempStr1 := 'C:\EzSensor\';
  //TempStr2 := 'EU';
  //N_CMEDVD_LogOpen( PAnsiChar(@TempStr1[1]), 10, PAnsiChar(@TempStr2[1]) );
  TempStr2 := 'Cntrs';
  N_CMEDVD_LogOpen( Nil, 15, PAnsiChar(@TempStr2[1]) );

  TempStr1 := '== End-user acquisition by CMS Dev12 program log ==';
  N_CMEDVD_LogMsg( PAnsiChar(@TempStr1[1]) );

  // ***** setting component's values
  if CMOFPProfile.CMDPStrPar1 = '1' then
  begin
    cbRawImage.Checked := True;
    CmBIPPMode.Enabled := False;
    N_FlagRaw := True; // without process flag
  end
  else
  begin
    cbRawImage.Checked := False;
    N_FlagRaw := False; // without process flag
  end;
  if not(CMOFPProfile.CMDPStrPar2 = '') then
    CmBIPPMode.ItemIndex := StrToInt(CMOFPProfile.CMDPStrPar2)
  else
    CmBIPPMode.ItemIndex := 0;

  // ***** setting flags and values
  N_AcqSDlg.m_nCurState  := 0; // stage
  N_AcqSDlg.m_nHasErrors := 0; // non-zero if an error happened
  N_Canceled          := False; // not implemented in the interface
  N_FlagAcqCallback   := True;
  N_FlagCalibCallback := True;
  N_FlagProcCallback  := True;
  N_FlagCaptureCall   := False;
  N_FlagError         := False;
  N_fPxlsize          := 0;
  N_FlagAcq           := False;
  N_FlagCalib         := False;
  N_FlagProc          := False;
  N_FlagCapture       := False;
  //N_ErrorMessage      := '';
  N_PrevStatus        := -1;
  N_DarkFrame         := False;

  // ***** setting callback functions
  N_AcqSDlg.On_ACQ_CallBack := N_CMCaptDev12.On_ACQ_CallBack;
  N_AcqSDlg.On_C_CallBack   := N_CMCaptDev12.On_C_CallBack;
  N_AcqSDlg.On_IP_CallBack  := N_CMCaptDev12.On_IP_CallBack;

  N_Dump1Str( 'FlagAcq = '+ BoolToStr(N_FlagAcq) );

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
  TimerCheck.Enabled := True;

  bnCaptureClick( Nil ); // start capture (press capture button)

  N_Dump1Str( 'MediaRay+ End FormShow' );
end; // procedure TN_CMCaptDev12Form.FormShow

//******************************************** TN_CMCaptDev12Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev12Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
var
  TempStr1: AnsiString;
begin
  TimerCheck.Enabled := False;

  N_CMECDVDACQ_Close( N_AcqSDlg.rACQ_CallBackRec ); // close acquisition when exit

  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  if N_LastErrMsg <> '' then
  begin
//    TempStr1 := Format('Error displayed: %s',[AnsiString(@(N_LastErrMsg[0]))] );
    TempStr1 := AnsiString( Format( 'Error displayed: %s', [N_LastErrMsg] ) );
    N_CMEDVD_LogMsg( PAnsiChar(@TempStr1[1]) );
    N_LastErrMsg := '';
  end;
  N_CMEDVD_LogClose;

  // ***** remember component's values
  if cbRawImage.Checked then
    CMOFPProfile.CMDPStrPar1 := '1'
  else
    CMOFPProfile.CMDPStrPar1 := '2';
  CMOFPProfile.CMDPStrPar2 := IntToStr( CmBIPPMode.ItemIndex );

  N_Dump2Str( 'CMOther11Form.FormClose' );
  Inherited;
end; // TN_CMCaptDev12Form.FormClose

//****************************************** TN_CMCaptDev12Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev12Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev12Form.FormKeyDown

//******************************************** TN_CMCaptDev12Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev12Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev12Form.FormKeyUp

// procedure TN_CMCaptDev12Form.cbAutoTakeClick - not implemented in the interface
procedure TN_CMCaptDev12Form.cbAutoTakeClick( Sender: TObject );
begin
  inherited;

  if cbAutoTake.Checked then
  begin
    // nothing
  end
  else
  begin
    // nothing
  end;

end; // procedure TN_CMCaptDev12Form.cbAutoTakeClick

// procedure TN_CMCaptDev12Form.SlidePanelResize
procedure TN_CMCaptDev12Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev12Form.SlidePanelResize

//*************************************** TN_CMCaptDev12Form.bnCaptureClick ***
// Capture Image in not CMOFAutoTake mode
//
//     Parameters
// Sender - Event Sender
//
// bnCapture button OnClick handler
//
procedure TN_CMCaptDev12Form.bnCaptureClick( Sender: TObject );
var
  qEnuDetectors: array[0..1] of TN_VDEnu_IOra;
  qRes:          Integer;
  pCurDetector:  PN_VDEnu_IOra;
  pDetector:     TN_VDEnu_IOra;
  TempStr1, TempStr2: AnsiString;
  TempStr3:      string;
  i, TempInt:    Integer;
  TempStr5:      AnsiString;
  TempStr6:      string;
begin
  // ***** set directories
  TempStr1 := 'C:\EzSensor\';
  TempStr2 := 'C:\EzSensor\\BACKUP\';
  TempStr3 := 'C:\EzSensor\\BACKUP\';

  Move( TempStr1[1], N_HomeDir[1], (Length(TempStr1)+1)*SizeOf(char) );
  Move( TempStr2[1], N_SaveDir[1], (Length(TempStr2)+1)*SizeOf(char) );
//  StrPCopy( N_HomeDir, TempStr1 );
//  StrPCopy( N_SaveDir, TempStr2 );

  if N_LastErrMsg <> '' then
  begin
//    TempStr1 := Format('Error displayed: %s',[AnsiString(@(N_LastErrMsg[0]))] );
    TempStr1 := AnsiString( Format( 'Error displayed: %s', [N_LastErrMsg] ) );
    N_CMEDVD_LogMsg( PAnsiChar(@TempStr1[1]) );
    N_LastErrMsg := '';
  end;

	CreateDirectory( @TempStr3[1], Nil );

  // set detector's pointer
  pCurDetector := @pDetector;

  // get connected devices
  qRes := N_CMECDVDEIOra_EnumConnected( 2, @qEnuDetectors[0] );
  N_Dump1Str('qRes after EnumConnected = '+IntToStr(qRes));

  // get needed device (first and only)
  pDetector := qEnuDetectors[0];
  N_Dump1Str('rStatus = '+IntToStr(pDetector.rStatus));

  // reject acquisition when two or more detectors are plugged in (to prevent ambiguity)
  if ( qRes > 1 ) then
	begin
		qRes := N_VDEnu_IOraErr_MultConn;
	end;

  // reject acquisition if status of used detector is not OK
  if (qRes >= 0) and (pCurDetector.rStatus <= 0) then
  begin
    N_Dump1Str( 'Device is already used' );
	  qRes := pCurDetector.rStatus;
    N_FlagError := True; // error flag
  end;

  N_Dump1Str('qRes 2 = '+IntTosTr(qRes));

  // none devices
	if (qRes <= 0) then
  begin
    N_FlagError := True; // error flag
    LbSerialID.Caption := 'None';
    N_AcqSDlg.m_nCurState := -1; // disconnected state

    N_CMECDVDEIOra_GetErrMsgText(qRes, @N_LastErrMsg[0]);

    Exit;
  end
	else // prepare and patch configurations data as required
  begin
		if (N_CMECDVDEIOra_Prepare( pCurDetector ) <= 0) then
		  qRes := 0;

    N_Dump1Str( 'qRes after N_CMECDVDEIOra_Prepare = ' + IntTosTr(qRes) );
  end;

  N_FlagError := False; // error flag, no error
  N_Dump1Str('FlagError = False');

  // ***** reinitialization of the libraries
  N_CMCDServObj12.CDSFreeAll;
  N_CMCDServObj12.CDSInitAll;

  if qRes < 0 then
    if N_LastErrMsg = '' then
    begin
      TempStr1 := N_StringToAnsi( Format('Initialization error code %d',
                                                                      [qRes]) );
      for i := 0 to Length(TempStr1) - 1 do
        N_LastErrMsg[i] := TempStr1[i+1];
    end;

  // set calib directory (get it from enumerator above, the name is the same as the device serial)
  if (pDetector.rCalDir <> Nil) then // existence of this directory is already checked generally
  begin
			N_CMECDVDC_SetCalibrationDirectory(@pDetector.rCalDir[0]);
	end;

  TempStr1 := 'C:\EzSensor\';
  TempStr2 := 'EU';
  N_CMEDVD_LogOpen( PAnsiChar(@TempStr1[1]), 10, PAnsiChar(@TempStr2[1]) );

  TempStr1 := '== End-user acquisition program log ==';
  N_CMEDVD_LogMsg( PAnsiChar(@TempStr1[1]) );

  TempStr1 := AnsiString( Format('Home: %s',[N_HomeDir]) );
  N_CMEDVD_LogMsg( PAnsiChar(@TempStr1[1]) );

  TempStr1 := AnsiString( Format('SaveDir: %s',[N_SaveDir] ) );
  N_CMEDVD_LogMsg( PAnsiChar(@TempStr1[1]) );

	// get ini informations
  TempStr1 := 'Capture Application';
	N_CMECDVD_IniProfSetSection( @TempStr1[1] );

	// cropping bitmaps
  TempStr1 := 'BMPCropLeft';
  TempStr2 := '0';

	TempStr5 := PAnsiChar( N_CMECDVD_IniProfGetStr( @TempStr1[1], @TempStr2[1] ));
  N_BMPCropLeft := StrToInt( N_AnsiToString(TempStr5) );
  N_Dump1Str( 'm_nBMPCropLeft = ' + IntToStr( N_BMPCropLeft ) );

  TempStr1 := 'BMPCropTop';

  TempStr5 := PAnsiChar( N_CMECDVD_IniProfGetStr( @TempStr1[1], @TempStr2[1] ));
  N_BMPCropTop := StrToInt( N_AnsiToString(TempStr5) );
  N_Dump1Str( 'm_nBMPCropTop = ' + IntToStr(N_BMPCropTop) );

  TempStr1 := 'BMPCropRight';

  TempStr5 := PAnsiChar(N_CMECDVD_IniProfGetStr( @TempStr1[1], @TempStr2[1] ));
  N_BMPCropRight := StrToInt(N_AnsiToString(TempStr5));
  N_Dump1Str( 'm_nBMPCropRight = ' + IntToStr(N_BMPCropRight) );

  TempStr1 := 'BMPCropBottom';

  TempStr5 := PAnsiChar(N_CMECDVD_IniProfGetStr( @TempStr1[1], @TempStr2[1] ));
  N_BMPCropBottom := StrToInt( N_AnsiToString(TempStr5) );
  N_Dump1Str('m_nBMPCropBottom = ' + IntToStr(N_BMPCropBottom) );

  // image post-processing mode.
	N_Sel := CmBIPPMode.ItemIndex + 1; // default just in case (not needed, it is already set in form show)
  if N_Sel = 0 then
    N_Sel := 1;

	// IP mapping index (get it from ini, number is the same as the position of CmBIPPMode)
  FillChar( N_IPModes, 0, sizeof(AnsiChar)*MAX_PATH );

  TempStr1 := 'IPReIndex';
  TempStr2 := 'None';

  TempStr5 := PAnsiChar(N_CMECDVD_IniProfGetStr( @TempStr1[1], @TempStr2[1] ));
  Move( TempStr5[1], N_IPModes[1], (Length(TempStr5)+1)*SizeOf(char) );
//  StrPCopy( N_IPModes, TempStr5 );
  N_Dump1Str( 'm_szIPModes = ' + N_AnsiToString( AnsiString(@N_IPModes[0])) );

  TempStr6 := N_AnsiToString(TempStr5);
  N_Dump1Str( 'Copied m_szIPModes = ' + TempStr6 );

  for i := 0 to N_Sel - 1 do // scan needed position with needed mapping index
   N_IPMode := N_ScanInteger( TempStr6 );

  N_Dump1Str('m_nIPMode = ' +IntToStr(N_IPMode) );

  // get pixel size
  TempStr1 := 'DICOMPixSpacing';
  TempStr2 := '0';

  TempStr5 := PAnsiChar( N_CMECDVD_IniProfGetStr( @TempStr1[1], @TempStr2[1] ));
  TempStr6 := N_AnsiToString( TempStr5 );
  TempInt := Pos( '\', TempStr6 ); // get string in the format "...\...", so, need to get number before "\"
  N_fPxlsize := StrToFloat( Copy(TempStr6, 0, TempInt-1) );
  N_Dump1Str( 'fPxlsize = ' + FloatToStr(N_fPxlsize) );

	// get frame's and image's dimension, allocate buffers
	N_CMECDVDACQ_GetFrameDim(@N_FrameWidth, @N_FrameHeight);
	N_CMECDVDC_GetImageDim(@N_ImgWidth, @N_ImgHeight);

  N_Dump1Str( 'Frame Width = ' + IntToStr(N_FrameWidth) + ', Height = ' +
                                                      IntToStr(N_FrameHeight) );
  N_Dump1Str( 'Image Width = ' + IntToStr(N_ImgWidth) + ', Height = ' +
                                                        IntToStr(N_ImgHeight) );
  N_Dump1Str( 'PID      = ' + IntToStr(pDetector.rPID) );
  N_Dump1Str( 'SerialID = ' + N_AnsiToString(
                                       AnsiString(@(pDetector.rSerialId[0])) ));
  N_Dump1Str( 'CalDir   = ' + N_AnsiToString(
                                           AnsiString(@pDetector.rCalDir[0])) );
  N_Dump1Str( 'CfgName  = ' + N_AnsiToString(
                                          AnsiString(@pDetector.rCfgName[0])) );
  N_Dump1Str( 'DLLName  = ' + N_AnsiToString(
                                          AnsiString(@pDetector.rDllName[0])) );

  LbSerialID.Caption := N_AnsiToString(AnsiString( @(pDetector.rSerialId[0])) );

  if AnsiString(@(pDetector.rSerialId[0])) <> '' then
  begin
    TempStr1 := 'SerialID=' + AnsiString(@(pDetector.rSerialId[0]) );
    N_CMEDVD_LogMsg( PAnsiChar(@TempStr1[1]) );
  end;

  if AnsiString(@(pDetector.rCalDir[0])) <> '' then
  begin
    TempStr1 := 'CalDir=' + AnsiString(@(pDetector.rCalDir[0]) );
    N_CMEDVD_LogMsg( PAnsiChar(@TempStr1[1]) );
  end;

  if AnsiString(@(pDetector.rCfgName[0])) <> '' then
  begin
    TempStr1 := 'CfgName=' + AnsiString(@(pDetector.rCfgName[0]) );
    N_CMEDVD_LogMsg( PAnsiChar(@TempStr1[1]) );
  end;

  if ( N_FrameBufPtr <> Nil ) then // delete m_FrameBufPtr;
    N_FrameBufPtr := Nil;

	if ( N_ImgBufPtr <> Nil ) then // delete m_ImgBufPtr;
    N_ImgBufPtr := Nil;

  // set frame and image length
  SetLength( N_FrameBufPtr, N_FrameWidth*N_FrameHeight );
  SetLength( N_ImgBufPtr, N_ImgWidth*N_ImgHeight );

  N_AcqSDlg.m_nCurState := 0; // set state

  N_FlagAcq := True; // start acquisition
  N_Dump1Str( 'FlagAcq = '+ BoolToStr(N_FlagAcq) );
end; // procedure TN_CMCaptDev12Form.bnCaptureClick

//***************************************** TN_CMCaptDev12Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev12Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev12Form.tbLeft90Click

//**************************************** TN_CMCaptDev12Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev12Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev12Form.tbRight90Click

//************************************** TN_CMCaptDev12Form.TimerCheckTimer ***
// Timer actions
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev12Form.TimerCheckTimer( Sender: TObject );
begin
  TimerCheck.Enabled := False;
//  N_Dump1Str( 'Start TimerCheckTimer, FlagAcq = ' + BoolToStr(N_FlagAcq) +
//                          ', m_nCurState = ' + IntToStr(N_AcqSDlg.m_nCurState) +
//                         ', FlagAcqCallback = ' + BoolToStr(N_FlagAcqCallback) +
//                    ', FlagCalibCallback = ' + BoolToStr(N_FlagCalibCallback) );

  if N_FlagError = True then // if error
  begin
    if N_LastErrMsg <> 'Control board is not connected' then
      N_Dump1Str('Error = ' + N_LastErrMsg);

    if (N_LastErrMsg <> '') and (N_LastErrMsg <>
                                          'Control board is not connected') then
      K_CMShowMessageDlg( String(N_LastErrMsg), mtError); // show error message

    // ***** start acquisition again
    //N_ErrorMessage        := '';
    N_AcqSDlg.m_nCurState := 0;
    N_Canceled            := False;
    N_FlagAcqCallback     := True;
    N_FlagCalibCallback   := True;
    N_FlagProcCallback    := True;
    N_FlagCaptureCall     := False;
    N_FlagAcq             := False;
    N_FlagCalib           := False;
    N_FlagProc            := False;
    N_FlagCapture         := False;
    N_DarkFrame           := False;
    cbRawImage.Enabled    := True;
    bnExit.Enabled        := True;
    if not( N_FlagRaw ) then
      CmBIPPMode.Enabled  := True;

    N_Dump1Str('Error occured, start again');
    bnCaptureClick( Nil ); // start new capture (press capture button)
  end;

  if N_PrevStatus <> N_AcqSDlg.m_nCurState then // change status' label and shape when it is changed
  begin
    case N_AcqSDlg.m_nCurState of
      -1: begin // no device
        StatusLabel.Caption := N_CML2Form.LLLOther3Disconnected.Caption;
        StatusLabel.Font.Color  := clRed;
        StatusShape.Pen.Color   := clRed;
        StatusShape.Brush.Color := clRed;
      end;
	    0: begin // init
        StatusLabel.Caption := 'Device Initialization';
        StatusLabel.Font.Color  := TColor( $168EF7 ); // orange color
        StatusShape.Pen.Color   := TColor( $168EF7 );
        StatusShape.Brush.Color := TColor( $168EF7 );
      end;
	    1: begin// wait
        StatusLabel.Caption := N_CML2Form.LLLOther3Ready.Caption;
        StatusLabel.Font.Color  := clGreen;
        StatusShape.Pen.Color   := clGreen;
        StatusShape.Brush.Color := clGreen;
      end;
      2: begin // read
        StatusLabel.Caption := 'Capturing image';
        StatusLabel.Font.Color  := clBlue;
        StatusShape.Pen.Color   := clBlue;
        StatusShape.Brush.Color := clBlue;
      end;
      else begin // process
        StatusLabel.Caption := 'Optimizing captured image';
        StatusLabel.Font.Color  := clBlue;
        StatusShape.Pen.Color   := clBlue;
        StatusShape.Brush.Color := clBlue;
      end;
    end;

  StatusLabel.Repaint;
  StatusShape.Repaint;
  end;

  N_PrevStatus := N_AcqSDlg.m_nCurState; // change previous status

  if ( N_FlagAcqCallback = False ) then // stop acq, when acq-callback is finished
    begin
      // ***** set components
      CmBIPPMode.Enabled := False;
      cbRawImage.Enabled := False;
      bnExit.Enabled     := False;

      N_Dump1Str('Stop Acquisition');
      N_StopAcquisition();
      N_FlagCalib := True; // start calib flag
    end;

  if ( N_FlagAcq = True ) then // start acq
  begin
    N_AcqSDlg.m_nHasErrors := 0;

    N_Dump1Str('Start Acquisition');
    N_FlagAcq := False; // so it won't starts again this time
    N_StartAcquisition();
  end;

  if ( N_FlagCalib = True ) then // start calib when it is needed
    if ( N_FlagCalibCallback = True ) then // start calib when acq-callback is finished
    begin
      N_Dump1Str('Start Calibration');
      N_FlagCalib := False; // so it won't starts again this time
      N_StartCalibration();
    end;

  if not(N_FlagRaw) then // if needed process
  begin

    if ( N_FlagCalibCallback = False ) then // stop calib when calib-callback is finished
    begin
      N_Dump1Str('Stop Calibration');
      N_StopCalibration();
      N_FlagProc := True; // start proc
    end;

    if ( N_FlagProcCallback = False ) then // stop proc when proc-callback is finished
    begin
      N_Dump1Str('Stop Process');
      N_StopProcess();
      N_FlagCapture := True; // start capture
    end;

    if ( N_FlagProc = True ) then // start proc when it is needed
      if ( N_FlagProcCallback = True ) then // start proc when calib-callback is finished
      begin
        N_Dump1Str('Start Process');
        N_FlagProc := False; // so it won't starts again this time
        N_StartProcess();
      end;

    if ( N_FlagCapture = True ) then // start capture when it is needed
      if ( N_FlagCaptureCall = True ) then // start capture when proc-callback is finished
      begin
        N_Dump1Str('Start Capture');
        N_FlagCapture := False; // so it won't starts again this time
        CMOFCaptureSlide();
        N_FlagAcq := True; // so acq could start next time

        // set component's values
        CmBIPPMode.Enabled := True;
        cbRawImage.Enabled := True;
        bnExit.Enabled     := True;
      end;
  end // if not(N_FlagRaw) then
  else
  begin
   if ( N_FlagCalibCallback = False ) then // stop calib when calib-callback is finished
    begin
      N_Dump1Str('Stop Calibration');
      N_StopCalibration();
      N_FlagCapture := True; // start capture
    end;

    if ( N_FlagCapture = True ) then // start capture when it is needed
      if ( N_FlagCaptureCall = True ) then // start capture when calib-callback is finished
      begin
        N_Dump1Str('Start Capture');
        N_FlagCapture := False; // so it won't starts again this time
        CMOFCaptureSlide();
        N_FlagAcq := True; // so acq could start next time

        // set component's values
        cbRawImage.Enabled := True;
        bnExit.Enabled := True;
      end;
  end; // else

//  N_Dump1Str( 'Finish TimerCheckTimer, Flag = ' + BoolToStr(N_FlagAcq) );
  TimerCheck.Enabled := True;
end; // procedure TN_CMCaptDev12Form.TimerCheckTimer

// procedure TN_CMCaptDev12Form.UpDown1Click
procedure TN_CMCaptDev12Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev12Form.UpDown1Click

//******************************************* TN_CMCaptDev12Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev12Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev12Form.tb180Click

//*************************************** TN_CMCaptDev12Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev12Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev12Form.tbFlipHorClick


//**********************  TN_CMCaptDev12Form class public methods  ************

//**************************************** TN_CMCaptDev12Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev12Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev12Form.CMOFDrawThumb

//************************************* TN_CMCaptDev12Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev12Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
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
end;

//************************************* TN_CMCaptDev12Form.CmBIPPModeChange ***
// Get processing mode
//
//     Parameters
// Sender - Event Sender
//
// CmBIPPMode OnChange handler
//
procedure TN_CMCaptDev12Form.CmBIPPModeChange(Sender: TObject);
var
  TempStr5: AnsiString;
  TempStr6: string;
  TempStr1, TempStr2: AnsiString;
  i: integer;
begin
  // image post-processing mode.
	N_Sel := CmBIPPMode.ItemIndex + 1;
  if N_Sel = 0 then // default just in case (not needed, it is already set in form show)
    N_Sel := 1;

  // IP mapping index
  FillChar( N_IPModes, 0, sizeof(AnsiChar)*MAX_PATH );

  TempStr1 := 'IPReIndex';
  TempStr2 := 'None';

  TempStr5 := PAnsiChar(N_CMECDVD_IniProfGetStr( @TempStr1[1], @TempStr2[1] ));
  Move( TempStr5[1], N_IPModes[1], (Length(TempStr5)+1)*SizeOf(char) );
//  StrPCopy( N_IPModes, TempStr5 );

  TempStr6 := N_AnsiToString( TempStr5 );

  for i := 0 to N_Sel - 1 do
    N_IPMode := N_ScanInteger( TempStr6 );

  //TempStr5 := Copy( m_nIPMode, 0, Length(m_nIPMode) );
  N_Dump1Str('m_nIPMode = ' + IntToStr(N_IPMode) );
end; // TN_CMCaptDev12Form.CmBIPPModeChange

// procedure TN_CMCaptDev12Form.CMOFGetThumbSize

//****************************************** TN_CMCaptDev12Form.bnExitClick ***
// Exit
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev12Form.bnExitClick( Sender: TObject );
begin
  inherited;
end; // procedure TN_CMCaptDev12Form.bnExitClick

//***************************************** TN_CMCaptDev12Form.bnSetupClick ***
// Setup form
//
//     Parameters
// Sender - Event Sender
//
// Not implemented in the interface
//
procedure TN_CMCaptDev12Form.bnSetupClick( Sender: TObject );
begin
  inherited;
  TimerCheck.Enabled := False; // disable timer
  // show device settings
  TimerCheck.Enabled := True; // enable timer
end; // procedure TN_CMCaptDev12Form.bnSetupClick

//************************************** TN_CMCaptDev12Form.cbRawImageClick ***
// Enables CmBIPPMode or disables it
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev12Form.cbRawImageClick( Sender: TObject );
begin
  inherited;
  N_FlagRaw := cbRawImage.Checked;
  if N_FlagRaw then
    CmBIPPMode.Enabled := False
  else
    CmBIPPMode.Enabled := True;
end; // procedure TN_CMCaptDev12Form.cbRawImageClick

//************************************* TN_CMCaptDev12Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev12Form.CMOFCaptureSlide(): Integer;
var
  CapturedDIB: TN_DIBObj;
  i: Integer;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
  NDIB : TN_DIBObj;
begin
  N_FlagCaptureCall := False; // so it won't starts again this time

  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format('MediaRay+ Start CMOFCaptureSlide %d', [CMOFNumCaptured]) );

  CapturedDIB := TN_DIBObj.Create();
  CapturedDIB.PrepEmptyDIBObj( N_ImgWidth, N_ImgHeight, pfCustom, -1,
                                                                 epfGray16, 16);


  for i := 0 to N_ImgHeight - 1 do // along all pixel rows
  begin
    Move( N_ImgBufPtr[(N_ImgHeight - 1 - i) * N_ImgWidth],
                     ( CapturedDIB.PRasterBytes + (i*CapturedDIB.RRLineSize) )^,
                                               N_ImgWidth*Sizeof(SmallInt) );
  end;

  // ***** applying normalization
  // negate is raw (without processing stage there are negated image)
  if N_FlagRaw then
    CapturedDIB.XORPixels( $FFFF );

  // autocontrast
  NDIB := Nil;
  CapturedDIB.CalcMaxContrastDIB( NDIB );
  CapturedDIB.Free();
  CapturedDIB := NDIB;

  // set bmi calculated with pixel size (got from the ini-file in the code above)
  with CapturedDIB.DIBInfo.bmi do
  begin
    if N_fPxlsize = 0.0 then
    begin
      biXPelsPerMeter := 50000; // default
      biYPelsPerMeter := biXPelsPerMeter;
    end
    else
    begin
      biXPelsPerMeter := Round( 1000 / N_fPxlsize ); // pixels per meter
      biYPelsPerMeter := biXPelsPerMeter;
    end;

    N_Dump1Str( 'biXPelsPerMeter = ' + IntToStr(biXPelsPerMeter) +
                             'biYPelsPerMeter = ' + IntToStr(biYPelsPerMeter) );
  end;
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

  N_Dump1Str(Format('MediaRay+ Fin CMOFCaptureSlide %d', [CMOFNumCaptured]));
  Result := 0;
end; // end of TN_CMCaptDev12Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev12Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev12Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev12Form.CurStateToMemIni

//************************************* TN_CMCaptDev12Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev12Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev12Form.MemIniToCurState

end.


