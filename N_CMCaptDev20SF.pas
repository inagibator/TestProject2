unit N_CMCaptDev20SF;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F,
  IniFiles;

type TN_CMCaptDev20Form = class( TN_BaseForm )
    TimerCheck: TTimer;
    CtrlsPanelParent: TPanel;
    CtrlsPanel: TPanel;
    MainPanel: TPanel;
    RightPanel: TPanel;
    ThumbsRFrame: TN_Rast1Frame;
    SlidePanel: TPanel;
    SlideRFrame: TN_Rast1Frame;
    bnCapture: TButton;
    bnSetup: TButton;
    cbAutoTake: TCheckBox;
    cbRawImage: TCheckBox;
    CmBIPPMode: TComboBox;
    cmbNew: TComboBox;
    LbSerialID: TLabel;
    LbSerialText: TLabel;
    StatusLabel: TLabel;
    StatusShape: TShape;
    tbRotateImage: TToolBar;
    tbLeft90: TToolButton;
    tbRight90: TToolButton;
    tb180: TToolButton;
    tbFlipHor: TToolButton;
    bnExit: TButton;

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
    procedure cmbNewChange     ( Sender: TObject );
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

    CMOFSensorTypeNew: Boolean;

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide (): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;

end; // type TN_CMCaptDev20Form = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

const // Form states
  N_CMOF4Unknown   = 0;
  N_CMOF4Manual    = 1;
  N_CMOF4Auto      = 2;

var
  ExtLogFlag: Boolean;

implementation

uses
  Math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev20S;
{$R *.dfm}

//**********************  TN_CMCaptDev20Form class handlers  ******************

//********************************************* TN_CMCaptDev20Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev20Form.FormShow( Sender: TObject );
var
  TempStr1, TempStr2: AnsiString;
begin
  N_Dump1Str( 'MediaRay+ 2 Start FormShow' );

  if not N_ShowForm then // show form without a device
  begin
    N_LastErrMsg := '';
    TempStr2 := 'Cntrs';
    N_CMEDVD_LogOpen( Nil, 15, PAnsiChar(@TempStr2[1]) );

    TempStr1 := '== End-user acquisition by CMS Dev20 program log ==';
    N_CMEDVD_LogMsg( PAnsiChar(@TempStr1[1]) );
  end; // show form without a device

  N_Dump1Str( 'CMDPStrPar1 before changing = ' + CMOFPProfile.CMDPStrPar1 +
                                ', CMDPStrPar2 = ' + CMOFPProfile.CMDPStrPar2 );

  // in case there is a malfunction from the older versions (while updated)
  CMOFPProfile.CMDPStrPar2 := StringReplace( CMOFPProfile.CMDPStrPar2, '/', '0',
                                                  [rfReplaceAll, rfIgnoreCase]);

  N_Dump1Str( 'CMDPStrPar1 after changing = ' + CMOFPProfile.CMDPStrPar1 +
                                ', CMDPStrPar2 = ' + CMOFPProfile.CMDPStrPar2 );

  if (CMOFPProfile.CMDPStrPar1 = '') then // if any
    CMOFPProfile.CMDPStrPar1 := '00';

  if (CMOFPProfile.CMDPStrPar2 = '') then // if any
    CMOFPProfile.CMDPStrPar2 := '03';

  if Length(CMOFPProfile.CMDPStrPar1) < 2 then
  begin
    CMOFPProfile.CMDPStrPar1 := CMOFPProfile.CMDPStrPar1 + '0';
  end;

  if Length(CMOFPProfile.CMDPStrPar2) < 2 then
  begin
    CMOFPProfile.CMDPStrPar2 := CMOFPProfile.CMDPStrPar2 + '3';
  end;

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
//  N_AcqSDlg.On_ACQ_CallBack := N_CMCaptDev20S.On_ACQ_CallBack;
//  N_AcqSDlg.On_C_CallBack   := N_CMCaptDev20S.On_C_CallBack;
//  N_AcqSDlg.On_IP_CallBack  := N_CMCaptDev20S.On_IP_CallBack;
  N_AcqSDlg.On_ACQ_CallBack := On_ACQ_CallBack;
  N_AcqSDlg.On_C_CallBack   := On_C_CallBack;
  N_AcqSDlg.On_IP_CallBack  := On_IP_CallBack;

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
//  tbRotateImage.Visible := True; // not needed because it leeds to error in capture direct into study mode
  TimerCheck.Enabled := True;

  if not N_ShowForm then // show form without a device
  begin
    bnCaptureClick( Nil ); // start capture (press capture button)
  end;

  N_Dump1Str( 'MediaRay+ 2 End FormShow' );
end; // procedure TN_CMCaptDev20Form.FormShow

//******************************************** TN_CMCaptDev20Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev20Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
var
  TempStr1: AnsiString;
begin
  TimerCheck.Enabled := False;

  if not N_ShowForm then // show form without a device
  begin
    N_CMECDVDACQ_Close( N_AcqSDlg.rACQ_CallBackRec ); // close acquisition when exit
  end;

  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  if not N_ShowForm then // show form without a device
  begin
    if N_LastErrMsg <> '' then
    begin
      TempStr1 := AnsiString( Format( 'Error displayed: %s', [N_LastErrMsg] ) );
      N_CMEDVD_LogMsg( PAnsiChar(@TempStr1[1]) );
      N_LastErrMsg := '';
    end;
    N_CMEDVD_LogClose;
  end; // show form without a device

  // ***** remember component's values
  if CMOFSensorTypeNew then
  begin
    CMOFPProfile.CMDPStrPar2[2] := chr(cmbNew.ItemIndex+ord('0'));// IntToStr( cmbNew.ItemIndex )[1];

    if cbRawImage.Checked then
    CMOFPProfile.CMDPStrPar1[2] := '1'
  else
    CMOFPProfile.CMDPStrPar1[2] := '2';
  end
  else
  begin
    CMOFPProfile.CMDPStrPar2[1] := chr(CmBIPPMode.ItemIndex+ord('0'));//IntToStr( CmBIPPMode.ItemIndex )[1];

    if cbRawImage.Checked then
    CMOFPProfile.CMDPStrPar1[1] := '1'
  else
    CMOFPProfile.CMDPStrPar1[1] := '2';
  end;

  N_Dump2Str( 'MediaRay+ 2 FormClose' );
  N_CMCDServObj20.CDSFreeAll;

  Inherited;
end; // TN_CMCaptDev20Form.FormClose

//****************************************** TN_CMCaptDev20Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev20Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev20Form.FormKeyDown

//******************************************** TN_CMCaptDev20Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev20Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev20Form.FormKeyUp

// procedure TN_CMCaptDev20Form.cbAutoTakeClick - not implemented in the interface
procedure TN_CMCaptDev20Form.cbAutoTakeClick( Sender: TObject );
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

end; // procedure TN_CMCaptDev20Form.cbAutoTakeClick

// procedure TN_CMCaptDev20Form.SlidePanelResize
procedure TN_CMCaptDev20Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev20Form.SlidePanelResize

//*************************************** TN_CMCaptDev20Form.bnCaptureClick ***
// Capture Image in not CMOFAutoTake mode
//
//     Parameters
// Sender - Event Sender
//
// bnCapture button OnClick handler
//
procedure TN_CMCaptDev20Form.bnCaptureClick( Sender: TObject );
var
  qEnuDetectors: array[0..1] of TN_VDEnu_IOra;
  qRes:          integer;
  pCurDetector:  PN_VDEnu_IOra;
  pDetector:     TN_VDEnu_IOra;
  TempStr1, TempStr2: AnsiString;
  TempStr3:      string;
  i, j, TempInt, TempPix: Integer;
  TempStr5:      AnsiString;
  TempStr6:      string;

  IPModes: array of Integer;

  Ini: TIniFile;
  FilterName: string;
  SkipFlag: Boolean;
begin
  N_Dump1Str('Start TN_CMCaptDev20Form.bnCaptureClick');
  // ***** set directories
  TempStr1 := 'C:\EzSensor\';
  TempStr2 := 'C:\EzSensor\\BACKUP\';
  TempStr3 := 'C:\EzSensor\\BACKUP\';

  Move( TempStr1[1], N_HomeDir[1], (Length(TempStr1)+1)*SizeOf(char) );
  Move( TempStr2[1], N_SaveDir[1], (Length(TempStr2)+1)*SizeOf(char) );

  if N_LastErrMsg <> '' then
  begin
    TempStr1 := AnsiString( Format( 'Error displayed: %s', [N_LastErrMsg] ) );
    N_CMEDVD_LogMsg( PAnsiChar(@TempStr1[1]) );
    N_LastErrMsg := '';
  end;

	CreateDirectory( @TempStr3[1], Nil );

  // set detector's pointer
  pCurDetector := @pDetector;

  N_Dump1Str('Before EnumConnected');
  // get connected devices
  qRes := N_CMECDVDEIOra_EnumConnected( 2, @qEnuDetectors[0] );
  N_Dump1Str( 'qRes after EnumConnected = ' + IntToStr(qRes) );

  // get needed device (first and only)
  pDetector := qEnuDetectors[0];
  N_Dump1Str( 'rStatus = ' + IntToStr(pDetector.rStatus) );

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

    N_CMECDVDEIOra_GetErrMsgText( qRes, @N_LastErrMsg[0] );

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
  N_CMCDServObj20.CDSFreeAll;
  N_CMCDServObj20.CDSInitAll;

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

  TempStr1 := AnsiString( Format('SaveDir: %s',[N_SaveDir]) );
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

  TempStr1 := 'IPReIndex';
  TempStr2 := 'None';

  TempStr5 := PAnsiChar(N_CMECDVD_IniProfGetStr( @TempStr1[1], @TempStr2[1] ));
  N_Dump1Str( 'm_szIPModes = ' + N_AnsiToString( AnsiString(@TempStr5[1])) );

  TempStr6 := N_AnsiToString(TempStr5);
  N_Dump1Str( 'Copied m_szIPModes = ' + TempStr6 );

  for i := 0 to 7 do // scan needed position with needed mapping index
  begin
    TempInt := N_ScanInteger( TempStr6 );

    SkipFlag := False;
    if Length(IPModes) <> 0 then
      for j := 0 to Length(IPModes) - 1 do
      begin
        if TempInt = IPModes[j] then
        begin
          SkipFlag := True;
        end;
      end;

      if (not SkipFlag) and (TempInt <> -1234567890) then
      begin
        SetLength(IPModes, Length(IPModes)+1);
        IPModes[Length(IPModes)-1] := TempInt;
      end;
  end;

  // previous code for pix size, not working correctly for some cases
  // get pixel size
  //TempStr1 := 'DICOMPixSpacing';
  //TempStr2 := '0';

  //TempStr5 := PAnsiChar( N_CMECDVD_IniProfGetStr( @TempStr1[1], @TempStr2[1] ));
  //TempStr6 := N_AnsiToString( TempStr5 );
  //TempInt := Pos( '\', TempStr6 ); // get string in the format "...\...", so, need to get number before "\"
  //N_fPxlsize := StrToFloat( Copy(TempStr6, 0, TempInt-1) );
  //N_Dump1Str( 'fPxlsize = ' + FloatToStr(N_fPxlsize) );

  // ***** pixel size
  TempStr1 := 'PixPitch';
  TempInt := 1; // any number, not used
  //N_fPxlsize
  TempPix := N_CMEDVD_IntParam( @TempStr1[1], TempInt );
  N_fPxlsize := (TempPix shr 16)/10.; // as documentation, result in um
  N_Dump1Str( 'fPxlsize = ' + FloatToStr(N_fPxlsize) + 'um' );

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
                                          AnsiString(@pDetector.rIniName[0])) );
  N_Dump1Str( 'DLLName  = ' + N_AnsiToString(
                                          AnsiString(@pDetector.rDllName[0])) );

  LbSerialID.Caption := N_AnsiToString(AnsiString( @(pDetector.rSerialId[0])) );

  if AnsiString(@(pDetector.rSerialId[0])) <> '' then
  begin
    TempStr1 := 'SerialID=' + AnsiString(@(pDetector.rSerialId[0]) );
    N_CMEDVD_LogMsg( PAnsiChar(@TempStr1[1]) );
  end;

  if ( N_AnsiToString(AnsiString( @(pDetector.rSerialId[0])) )[1] = 'S' ) or
  ( N_AnsiToString(AnsiString( @(pDetector.rSerialId[0])) )[1] = 'H' ) or
  ( N_AnsiToString(AnsiString( @(pDetector.rSerialId[0])) )[1] = 'B' ) then
  begin

    N_Dump1Str( 'S, H, B, CMOFPProfile.CMDPStrPar2 = ' + CMOFPProfile.CMDPStrPar2 );
    N_Dump1Str( 'S, H, B, CMOFPProfile.CMDPStrPar1 = ' + CMOFPProfile.CMDPStrPar1 );

    cmbNew.ItemIndex := StrToInt(CMOFPProfile.CMDPStrPar2[2]);

    // ***** setting component's values
  if CMOFPProfile.CMDPStrPar1[2] = '1' then
  begin
    cbRawImage.Checked := True;
    CmBIPPMode.Enabled := False;
    cmbNew.Enabled := False;
    N_FlagRaw := True; // without process flag
  end
  else
  begin
    cbRawImage.Checked := False;
    N_FlagRaw := False; // without process flag
  end;

    N_Dump1Str( 'N_AnsiToString(AnsiString( @(pDetector.rSerialId[0])) )[1] = ''S''' );
    CMBIPPMode.Visible := False;
    cmbNew.Visible := True;
    CMOFSensorTypeNew := True; // new type
  end
  else
  begin
    N_Dump1Str( 'not N_AnsiToString(AnsiString( @(pDetector.rSerialId[0])) )[1] = ''S''' );

    Ini:=TiniFile.Create('C:/EzSensor/EzSensor.ini');

    CMOFSensorTypeNew := False; // old type

    CMBIPPMode.Items.Clear;
    for i := 0 to Length(IPModes) - 1 do
    begin
      FilterName := Ini.ReadString( 'IP'+IntToStr(IPModes[i]), 'Caption', '' );
      N_Dump1Str( 'FilterName = ' + FilterName );

      if FilterName = 'EzP_HC' then
        FilterName := 'High Contrast';
      if FilterName = 'EzP_MC' then
        FilterName := 'Medium Contrast';
      if FilterName = 'EzP_N_NC' then
        FilterName := 'Normal';
      if FilterName = 'EzP_LC' then
        FilterName := 'Low Contrast';
      if FilterName = 'Periodental' then
        FilterName := 'Perio';

      CMBIPPMode.Items.Add( FilterName );
    end;

    N_Dump1Str( 'CMOFPProfile.CMDPStrPar2 = ' + CMOFPProfile.CMDPStrPar2 );
    N_Dump1Str('Before');

    CmBIPPMode.ItemIndex := StrToInt( CMOFPProfile.CMDPStrPar2[1] );

    // ***** setting component's values
    if CMOFPProfile.CMDPStrPar1[1] = '1' then
    begin
      cbRawImage.Checked := True;
      CmBIPPMode.Enabled := False;
      cmbNew.Enabled := False;
      N_FlagRaw := True; // without process flag
    end
    else
    begin
      cbRawImage.Checked := False;
      N_FlagRaw := False; // without process flag
    end;

    Ini.Destroy;

    CMBIPPMode.Visible := True;
    cmbNew.Visible := False;
  end;

  if CMBIPPMode.Visible = True then
  begin
    N_IPMode := IPModes[CMBIPPMode.ItemIndex];
    N_Dump1Str( 'IP chosen = ' + IntToStr(N_IPMode) );

    for i := 0 to 6 do
    N_Dump1Str( 'IPMode = ' + IntToStr(IPModes[i]) );
  end;

  // ***** new filters
  if cmbNew.Visible = True then
  case cmbNew.ItemIndex of
  0:
  begin
    N_IPMode := 701;
    N_Dump1Str('701');
  end;
  1:
  begin
    N_IPMode := 702;
    N_Dump1Str('702');
  end;
  2:
  begin
    N_IPMode := 703;
    N_Dump1Str('703');
  end;
  3:
  begin
    N_IPMode := 704;
    N_Dump1Str('704');
  end;
  4:
  begin
    N_IPMode := 705;
    N_Dump1Str('705');
  end;
  5:
  begin
    N_IPMode := 706;
    N_Dump1Str('706');
  end;
  6:
  begin
    N_IPMode := 707;
    N_Dump1Str('707');
  end;

  end;

  N_Dump1Str( 'm_nIPMode = ' +IntToStr(N_IPMode) );

  if AnsiString(@(pDetector.rCalDir[0])) <> '' then
  begin
    TempStr1 := 'CalDir=' + AnsiString(@(pDetector.rCalDir[0]) );
    N_CMEDVD_LogMsg( PAnsiChar(@TempStr1[1]) );
  end;

  if AnsiString(@(pDetector.rIniName[0])) <> '' then
  begin
    TempStr1 := 'IniName=' + AnsiString(pDetector.rIniName);
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

  // should check for mistake for nSel
  N_FlagAcq := True; // start acquisition
  N_Dump1Str( 'FlagAcq = '+ BoolToStr(N_FlagAcq) );
end; // procedure TN_CMCaptDev20Form.bnCaptureClick

//***************************************** TN_CMCaptDev20Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev20Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev20Form.tbLeft90Click

//**************************************** TN_CMCaptDev20Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev20Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev20Form.tbRight90Click

//************************************** TN_CMCaptDev20Form.TimerCheckTimer ***
// Timer actions
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev20Form.TimerCheckTimer( Sender: TObject );
begin
  TimerCheck.Enabled := False;

  if N_FlagError = True then // if error
  begin
    if N_LastErrMsg <> 'Control board is not connected' then
      N_Dump1Str('Error = ' + N_LastErrMsg);

    if (N_LastErrMsg <> '') and (N_LastErrMsg <>
                                          'Control board is not connected') then
      K_CMShowMessageDlg(N_AnsiToString(N_LastErrMsg), mtError); // show error message

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
    //cbRawImage.Enabled    := True;
    bnExit.Enabled        := True;
    if not( N_FlagRaw ) then
    begin
      if CMOFSensorTypeNew then
        cmbNew.Enabled := True
      else
        CmBIPPMode.Enabled  := True;
    end;

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
      cmbNew.Enabled := False;
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
        cmbNew.Enabled := True;
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

  TimerCheck.Enabled := True;
end; // procedure TN_CMCaptDev20Form.TimerCheckTimer

// procedure TN_CMCaptDev20Form.UpDown1Click
procedure TN_CMCaptDev20Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev20Form.UpDown1Click

//******************************************* TN_CMCaptDev20Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev20Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev20Form.tb180Click

//*************************************** TN_CMCaptDev20Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev20Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev20Form.tbFlipHorClick


//**********************  TN_CMCaptDev20Form class public methods  ************

//**************************************** TN_CMCaptDev20Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev20Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev20Form.CMOFDrawThumb

//************************************* TN_CMCaptDev20Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev20Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
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
end; // procedure TN_CMCaptDev20Form.CMOFGetThumbSize

//************************************* TN_CMCaptDev20Form.CmBIPPModeChange ***
// Get processing mode
//
//     Parameters
// Sender - Event Sender
//
// CmBIPPMode OnChange handler
//
procedure TN_CMCaptDev20Form.CmBIPPModeChange( Sender: TObject );
var
  TempStr5: AnsiString;
  TempStr6: string;
  TempStr1, TempStr2: AnsiString;
  i, j, TempInt: integer;
  SkipFlag: Boolean;

  IPModes: array of Integer;
begin
  TempStr1 := 'IPReIndex';
  TempStr2 := 'None';

  TempStr5 := PAnsiChar(N_CMECDVD_IniProfGetStr( @TempStr1[1], @TempStr2[1] ));
  N_Dump1Str( 'm_szIPModes = ' + N_AnsiToString( AnsiString(@TempStr5[1])) );

  TempStr6 := N_AnsiToString(TempStr5);
  N_Dump1Str( 'Copied m_szIPModes = ' + TempStr6 );

  for i := 0 to 7 do // scan needed position with needed mapping index
  begin
    TempInt := N_ScanInteger( TempStr6 );

    SkipFlag := False;
    if Length(IPModes) <> 0 then
      for j := 0 to Length(IPModes) - 1 do
      begin
        if TempInt = IPModes[j] then
        begin
          SkipFlag := True;
        end;
      end;

      if (not SkipFlag) and (TempInt <> -1234567890) then
      begin
        SetLength(IPModes, Length(IPModes)+1);
        IPModes[Length(IPModes)-1] := TempInt;
      end;
  end;

  for i := 0 to 6 do
    N_Dump1Str( 'IPMode = ' + IntToStr(IPModes[i]) );

  if CMBIPPMode.Visible = True then
  begin
    N_IPMode := IPModes[CMBIPPMode.ItemIndex];
    N_Dump1Str( 'IP chosen = ' + IntToStr(N_IPMode) );
  end;

  N_Dump1Str( 'm_nIPMode = ' +IntToStr(N_IPMode) );
end; // procedure TN_CMCaptDev20Form.CmBIPPModeChange( Sender: TObject );

//***************************************** TN_CMCaptDev20Form.cmbNewChange ***
// Get processing mode (new sensor)
//
//     Parameters
// Sender - Event Sender
//
// cmbNewChange OnChange handler
//
procedure TN_CMCaptDev20Form.cmbNewChange( Sender: TObject );
begin
  inherited;

  // ***** new filters
  N_Dump1Str( 'ItemIndex = ' + IntToStr(cmbNew.ItemIndex) );
  case cmbNew.ItemIndex of
  0:
  begin
    N_IPMode := 701;
    N_Dump1Str('701');
  end;
  1:
  begin
    N_IPMode := 702;
    N_Dump1Str('702');
  end;
  2:
  begin
    N_IPMode := 703;
    N_Dump1Str('703');
  end;
  3:
  begin
    N_IPMode := 704;
    N_Dump1Str('704');
  end;
  4:
  begin
    N_IPMode := 705;
    N_Dump1Str('705');
  end;
  5:
  begin
    N_IPMode := 706;
    N_Dump1Str('706');
  end;
  6:
  begin
    N_IPMode := 707;
    N_Dump1Str('707');
  end;

  end;

  N_Dump1Str( 'm_nIPMode = ' +IntToStr(N_IPMode) );
end; // procedure TN_CMCaptDev20Form.cmbNewChange( Sender: TObject );

//****************************************** TN_CMCaptDev20Form.bnExitClick ***
// Exit
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev20Form.bnExitClick( Sender: TObject );
begin
  inherited;
end; // procedure TN_CMCaptDev20Form.bnExitClick

//***************************************** TN_CMCaptDev20Form.bnSetupClick ***
// Setup form
//
//     Parameters
// Sender - Event Sender
//
// Not implemented in the interface
//
procedure TN_CMCaptDev20Form.bnSetupClick( Sender: TObject );
begin
  inherited;
  TimerCheck.Enabled := False; // disable timer
  // show device settings
  TimerCheck.Enabled := True; // enable timer
end; // procedure TN_CMCaptDev20Form.bnSetupClick

//************************************** TN_CMCaptDev20Form.cbRawImageClick ***
// Enables CmBIPPMode or disables it
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev20Form.cbRawImageClick( Sender: TObject );
begin
  inherited;
  N_FlagRaw := cbRawImage.Checked;
  if N_FlagRaw then
    begin
      if CMOFSensorTypeNew then
        cmbNew.Enabled := False
      else
        CmBIPPMode.Enabled  := False;
    end
  else
  begin
    begin
      if CMOFSensorTypeNew then
        cmbNew.Enabled := True
      else
        CmBIPPMode.Enabled  := True;
    end;
  end;
end; // procedure TN_CMCaptDev20Form.cbRawImageClick

//************************************* TN_CMCaptDev20Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev20Form.CMOFCaptureSlide(): Integer;
var
  CapturedDIB: TN_DIBObj;
  i: Integer;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
  NDIB    : TN_DIBObj;
begin
  N_FlagCaptureCall := False; // so it won't starts again this time

  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format('MediaRay+ 2 Start CMOFCaptureSlide %d', [CMOFNumCaptured]) );

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
  // negate is raw (without a processing stage, there are negated images)
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
      biXPelsPerMeter := Round( 1000000 / N_fPxlsize ); // pixels per meter, from um
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

  N_Dump1Str( Format('MediaRay+ 2 Fin CMOFCaptureSlide %d', [CMOFNumCaptured]) );
  Result := 0;
end; // end of TN_CMCaptDev20Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev20Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev20Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev20Form.CurStateToMemIni

//************************************* TN_CMCaptDev20Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev20Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev20Form.MemIniToCurState

end.


