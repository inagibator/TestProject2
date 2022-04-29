unit N_CMCaptDev24F;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F;

type TN_CMCaptDev24Form = class( TN_BaseForm )
    MainPanel:  TPanel;
    RightPanel: TPanel;
    SlidePanel: TPanel;
    bnExit:     TButton;
    ThumbsRFrame: TN_Rast1Frame;
    StatusShape:  TShape;
    StatusLabel:  TLabel;
    SlideRFrame:  TN_Rast1Frame;
    bnCapture:  TButton;
    tbRotateImage: TToolBar;
    tbLeft90:   TToolButton;
    tbRight90:  TToolButton;
    tb180:      TToolButton;
    tbFlipHor:  TToolButton;
    cbAutoTake: TCheckBox;
    bnSetup:    TButton;
    TimerCheck: TTimer;
    LbSerialText: TLabel;
    LbSerialID: TLabel;
    lbExpoLevel: TLabel;
    lbExpoLevelPrev: TLabel;

    //******************  TN_CMCaptDev23Form class handlers  ******************

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

    CMOFLastState: Integer;              // last device state
    CMOF16Bit: Boolean;

    ThisForm: TN_CMCaptDev24Form;        // Pointer to this form

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide ( DIBDir: string; Pix: Integer ): Integer;
    function  CMOFCaptureSlide16Bit ( DIBDir: string; Pix, Height, Width: Integer ): Integer; // capturing tiff 16 bit image
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;

end; // type TN_CMCaptDev23Form = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

const // Form states
  N_CMOF4Unknown   = 0;
  N_CMOF4Manual    = 1;
  N_CMOF4Auto      = 2;

implementation

uses
  Math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev24,
  N_CMCaptDev0, IniFiles;
{$R *.dfm}

//**********************  TN_CMCaptDev23Form class handlers  ******************

//********************************************* TN_CMCaptDev23Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev24Form.FormShow( Sender: TObject );
var
  WrkDir, LogDir, CurDir, FileName, PatientName, DoctorName: String;
  Res: Boolean;
procedure DeleteDirectory(const Name: string);
var
  F: TSearchRec;
begin
  if FindFirst(Name + '\*', faAnyFile, F) = 0 then begin
    try
      repeat
        if (F.Attr and faDirectory <> 0) then begin
          if (F.Name <> '.') and (F.Name <> '..') then begin
            DeleteDirectory(Name + '\' + F.Name);
          end;
        end else begin
          DeleteFile(Name + '\' + F.Name);
        end;
      until FindNext(F) <> 0;
    finally
      FindClose(F);
    end;
    RemoveDir(Name);
  end;
end;
begin
  N_Dump1Str( 'Acteon Start FormShow' );

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

  WrkDir       := K_ExpandFileName( '(#TmpFiles#)' ) + 'Acteon\';
  LogDir       := N_CMV_GetLogDir();
  CurDir       := ExtractFilePath( ParamStr( 0 ) );
  N_Dump1Str( 'Acteon >> Exe directory = "' + CurDir + '", WrkDir = ' + WrkDir );

  DeleteDirectory(WrkDir);
  //CreateDir(WrkDir);

  if CMOFDeviceIndex = 0 then
    FileName  := CurDir + 'MAP2W.exe'
  else
    FileName  := CurDir + 'MAS2W.exe';

  // wait old driver session closing
  N_CMV_WaitProcess( False, FileName, -1 );

  if not FileExists( FileName ) then // find driver
  begin
    Exit;
  end; // if not FileExists( FileName ) then // find driver

  //WrkDir  := StringReplace(WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase]);

  //cmd := '"' + WrkDir + '" "' + IntToStr( FormHandle ) + '" "' +
  //                                                     IntToStr( Device ) + '"';

  PatientName := K_CMGetPatientDetails( -1, '(#PatientSurname#) (#PatientFirstName#)' );
  DoctorName := K_CMGetProviderDetails( -1, '(#ProviderSurname#)' );
  // start driver executable file with command line parameters
  Res := N_CMV_CreateProcess( '"' + FileName + '" /image_path "' + WrkDir + '"'
  + ' /doctor "' + DoctorName + '"' + ' /patient "' + PatientName + '"' );//'" ' + cmd );

  if not Res then // if driver start fail
  begin
    Exit;
  end; // if not Result then // if driver start fail

  //N_CMECD_SensorOpen;
  //lbExpoLevel.Caption := IntToStr(N_CMECD_SensorGetExpoLevel) + '%';

  if CMOFPProfile.CMDPStrPar2 = '1' then // 16bit checked
  begin
    CMOF16Bit := True;
    //N_CMECD_SensorSet16BitMode(1);
  end
  else // 16bit unchecked
  begin
    CMOF16Bit := False;
    //N_CMECD_SensorSet16BitMode(0);
  end;

  N_Dump1Str( 'Acteon End FormShow' );
end; // procedure TN_CMCaptDev23Form.FormShow

//******************************************** TN_CMCaptDev23Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev24Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin
  TimerCheck.Enabled := False;

  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;


  if CMOFDeviceIndex = 0 then
    WinExec( 'taskkill /IM MAP2W.exe', SW_HIDE )
  else
    WinExec( 'taskkill /IM MAS2W.exe', SW_HIDE );

  N_Dump2Str( 'CMOther23Form.FormClose' );
  Inherited;
end; // TN_CMCaptDev23Form.FormClose

//****************************************** TN_CMCaptDev23Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev24Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev23Form.FormKeyDown

//******************************************** TN_CMCaptDev23Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev24Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev23Form.FormKeyUp

// procedure TN_CMCaptDev23Form.cbAutoTakeClick - not implemented in the interface
procedure TN_CMCaptDev24Form.cbAutoTakeClick( Sender: TObject );
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

end; // procedure TN_CMCaptDev23Form.cbAutoTakeClick

// procedure TN_CMCaptDev23Form.SlidePanelResize
procedure TN_CMCaptDev24Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev23Form.SlidePanelResize

//*************************************** TN_CMCaptDev23Form.bnCaptureClick ***
// Capture Image in not CMOFAutoTake mode
//
//     Parameters
// Sender - Event Sender
//
// bnCapture button OnClick handler
//
procedure TN_CMCaptDev24Form.bnCaptureClick( Sender: TObject );
begin
end; // procedure TN_CMCaptDev23Form.bnCaptureClick

//***************************************** TN_CMCaptDev23Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev24Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev23Form.tbLeft90Click

//**************************************** TN_CMCaptDev23Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev24Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev23Form.tbRight90Click

//************************************** TN_CMCaptDev23Form.TimerCheckTimer ***
// Timer actions
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev24Form.TimerCheckTimer( Sender: TObject );
var
  WrkDir, ImgDir, ImgRawDir: string;
  ExpInt, Pix, Height, Width: Integer;
  Ini: TIniFile;

  searchResult : TSearchRec;
begin
  TimerCheck.Enabled := False;
  inherited;
  WrkDir := K_ExpandFileName( '(#TmpFiles#)' ) + 'Acteon\';
  if DirectoryExists(WrkDir) then
  begin
    SetCurrentDir(WrkDir);

    if FindFirst('*.NFO', faAnyFile, searchResult) = 0 then
    //if FileExists(WrkDir + '*.NFO') then
      begin
        Ini:=TiniFile.Create(WrkDir + searchResult.Name);
        ImgDir := Ini.ReadString( 'ACQUISITION', 'File8', '' );
        ImgRawDir := Ini.ReadString( 'ACQUISITION', 'File16', '' );
        Pix := Ini.ReadInteger( 'ACQUISITION', 'PixelWidth', 0 );
        Height := Ini.ReadInteger( 'ACQUISITION', 'Height', 0 );
        Width := Ini.ReadInteger( 'ACQUISITION', 'Width', 0 );
        ExpInt := Ini.ReadInteger( 'ACQUISITION', 'Exposition', 0 );
        LbExpoLevel.Caption := IntToStr(ExpInt);
        lbExpoLevel.Visible := True;
        lbExpoLevelPrev.Visible := True;

        if not CMOF16Bit then
          CMOFCaptureSlide(ImgDir, Pix)
        else
        begin
          Screen.Cursor := crHourglass;
          CMOFCaptureSlide16Bit(ImgRawDir, Pix, Height, Width);
          Screen.Cursor := crArrow;
        end;

        N_Dump1Str( 'Before Deleting 1' );
        DeleteFile(WrkDir + searchResult.Name);

        N_Dump1Str( 'Before Deleting 2' );
        DeleteFile(ImgDir);

        N_Dump1Str( 'Before Deleting 3' );
        DeleteFile(ImgRawDir);
      end;
  end;
  TimerCheck.Enabled := True;
end; // procedure TN_CMCaptDev23Form.TimerCheckTimer

// procedure TN_CMCaptDev23Form.UpDown1Click
procedure TN_CMCaptDev24Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev23Form.UpDown1Click

//******************************************* TN_CMCaptDev23Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev24Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev23Form.tb180Click

//*************************************** TN_CMCaptDev23Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev24Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev23Form.tbFlipHorClick


//**********************  TN_CMCaptDev23Form class public methods  ************

//**************************************** TN_CMCaptDev23Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev24Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev23Form.CMOFDrawThumb

//************************************* TN_CMCaptDev23Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev24Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
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
end; // procedure TN_CMCaptDev23Form.CMOFGetThumbSize

//****************************************** TN_CMCaptDev23Form.bnExitClick ***
// Exit
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev24Form.bnExitClick( Sender: TObject );
begin
  inherited;

  Close();

  //N_CMECD_SensorClose;
end; // procedure TN_CMCaptDev23Form.bnExitClick

//***************************************** TN_CMCaptDev23Form.bnSetupClick ***
// Setup form
//
//     Parameters
// Sender - Event Sender
//
// Not implemented in the interface
//
procedure TN_CMCaptDev24Form.bnSetupClick( Sender: TObject );
begin
  inherited;
  TimerCheck.Enabled := False; // disable timer
  //N_CMECD_SensorShowConfigDialog();// show device settings
  TimerCheck.Enabled := True; // enable timer
end; // procedure TN_CMCaptDev23Form.bnSetupClick

//************************************* TN_CMCaptDev23Form.CMOFCaptureSlide ***
// Capture Slide and show it
//
//     Parameters
// DIBPointer - image pointer
// Return 0 if OK
//
function TN_CMCaptDev24Form.CMOFCaptureSlide( DIBDir: string; Pix: Integer ): Integer;
var
  CapturedDIB: TN_DIBObj;
  i:           Integer;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
begin
  i := 0;
  repeat
  begin
     Sleep(100);
     Inc(i);
     if i > 50 then
     begin
       N_Dump1Str('Image took too long to be saved');
       Result := 0;
       Exit;
     end;
  end
   until FileExists(DIBDir);

  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format('Acteon Start CMOFCaptureSlide %d', [CMOFNumCaptured]) );

  N_Dump1Str( 'DIB Directory = ' + DIBDir );

  CapturedDIB := TN_DIBObj.Create( DIBDir );

  N_Dump1Str( 'Pix = ' + IntToStr(Pix) );
  if Pix = 0 then
    Pix := 25; // default

  with CapturedDIB.DIBInfo.bmi do
  begin
    biXPelsPerMeter := Round( 1000000/Pix );
    biYPelsPerMeter := biXPelsPerMeter;
  end;

  N_Dump1Str( 'Before creating a NewSlide' );
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

  N_Dump1Str( 'Before adding a NewSlide' );
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

  N_Dump1Str( Format('Acteon Fin CMOFCaptureSlide %d', [CMOFNumCaptured]) );
  Result := 0;
end; // end of TN_CMCaptDev23Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev23Form.CMOFCaptureSlide ***
// Capture 16bit Slide and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev24Form.CMOFCaptureSlide16Bit( DIBDir: string; Pix, Height, Width: Integer ): Integer;
var
  CapturedDIB, NDIB: TN_DIBObj;
  i:        Integer;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
  myFile : File of Word;
  WordTemp: Word;
  PointerTemp: PWord;
begin
  i := 0;
  repeat
  begin
     Sleep(100);
     Inc(i);
     if i > 50 then
     begin
       N_Dump1Str('Image took too long to be saved');
       Result := 0;
       Exit;
     end;
  end
   until FileExists(DIBDir);

  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format('Acteon Start CMOFCaptureSlide %d', [CMOFNumCaptured]) );

  N_Dump1Str( '16bit - DIB Directory = ' + DIBDir );

  N_Dump1Str( 'Before CapturedDIB := Nil;' );
  CapturedDIB := Nil;
  //N_LoadDIBFromFileByImLib( CapturedDIB, N_CMV_GetWrkDir() +
  //                                     'SiUCOM/a' ); // new 16bit variant
  N_Dump1Str( 'CapturedDIB := TN_DIBObj.Create();' );
  CapturedDIB := TN_DIBObj.Create();
  N_Dump1Str( 'Prepare empty DIB' );
  CapturedDIB.PrepEmptyDIBObj( Width, Height, pfCustom, -1,
                                                                 epfGray16, 16);

     N_Dump1Str( 'Before AssignFile' );
     AssignFile(myFile, DIBDir);
     N_Dump1Str( 'Before Reset' );
     Reset(myFile);

   N_Dump1Str( 'Before Pointer' );
   PointerTemp := Pointer(CapturedDIB.PRasterBytes);

  // Показ содержимого файла
  while not Eof(myFile) do
  begin
    Read(myFile, WordTemp);
    //ShowMessage(IntToStr(myWord));
    Move( WordTemp, PointerTemp^, Sizeof(Word) );
    Inc(PointerTemp);
  end;

  N_Dump1Str( 'Before CloseFile' );
  // Закрываем файл в последний раз
  CloseFile(myFile);

  // autocontrast
  NDIB := Nil;
  CapturedDIB.FlipAndRotate(2);
  //CapturedDIB.FlipAndRotate(1);
  CapturedDIB.CalcMaxContrastDIB( NDIB );
  CapturedDIB.Free();
  CapturedDIB := NDIB;

  N_Dump1Str( 'Pix = ' + IntToStr(Pix) );
  if Pix = 0 then
    Pix := 25; // default

  with CapturedDIB.DIBInfo.bmi do
  begin
    biXPelsPerMeter := Round( 1000000/Pix );
    biYPelsPerMeter := biXPelsPerMeter;
  end;

  N_Dump1Str('Before NewSlide');
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

  N_Dump1Str( Format('Acteon Fin CMOFCaptureSlide %d', [CMOFNumCaptured]) );
  Result := 0;
end;

//************************************* TN_CMCaptDev23Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev24Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev23Form.CurStateToMemIni

//************************************* TN_CMCaptDev23Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev24Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev23Form.MemIniToCurState

end.


