unit N_CMCaptDev18F;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F;

type TN_CMCaptDev18Form = class( TN_BaseForm )
  MainPanel:     TPanel;
  RightPanel:    TPanel;
  SlidePanel:    TPanel;
  bnExit:        TButton;
  ThumbsRFrame:  TN_Rast1Frame;
  StatusShape:   TShape;
  StatusLabel:   TLabel;
  SlideRFrame:   TN_Rast1Frame;
  bnCapture:     TButton;
  tbRotateImage: TToolBar;
  tbLeft90:      TToolButton;
  tbRight90:     TToolButton;
  tb180:         TToolButton;
  tbFlipHor:     TToolButton;
  TimerCheck:    TTimer;

  //******************  TN_CMCaptDev18Form class handlers  ******************

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
  procedure bnExitClick      ( Sender: TObject );
  procedure TimerCheckTimer  ( Sender: TObject );
  function  SaveImage        ( Path: string ): Integer;
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

  CMOFImageCount: Integer; // number of images retrieved
  CMOFStatus, CMOFStatusPrev: Integer; // a status and a previous one to check for changing of it

  CMOFThisForm: TN_CMCaptDev18Form; // pointer to this form

  procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
  procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
  function  CMOFCaptureSlide (): Integer;
  procedure CurStateToMemIni (); override;
  procedure MemIniToCurState (); override;
end; // type TN_CMCaptDev18Form = class( TN_BaseForm )

implementation

uses
{$IF SizeOf(Char) = 2}
  AnsiStrings,
{$IFEND}
  Math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev18;
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
procedure TN_CMCaptDev18Form.FormShow( Sender: TObject );
var
  ImageDir: string;
  RetVal:   integer;
begin
  N_Dump1Str( 'PaloDEx Start FormShow' );

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

  CMOFImageCount := 0;

  ImageDir := K_ExpandFileName( '(#TmpFiles#)/Pictures' ); // in wrkfiles, deleted after use
  if not DirectoryExists(ImageDir) then // if not exists then create
    CreateDir(ImageDir);

  FillChar( N_App_NCI, SizeOf(N_NCI_Configuration), 0 ); // must

  N_App_NCI.NCICAPI_Version := N_NCI_API_VERSION;
  N_App_NCI.NCICStruct_Size := sizeof( N_NCI_Configuration );

{$IF SizeOf(Char) = 2}
  System.AnsiStrings.StrPLCopy( N_App_NCI.NCICApplication_ID, 'cmsuite',
                                           High(N_App_NCI.NCICApplication_ID) );

  System.AnsiStrings.StrPLCopy( N_App_NCI.NCICPatient_ID, N_StringToAnsi(K_CMGetPatientDetails( -1,
                   '(#PatientCardNumber#)' )), High(N_App_NCI.NCICPatient_ID) );
  System.AnsiStrings.StrPLCopy( N_App_NCI.NCICPatient_Name, N_StringToAnsi(K_CMGetPatientDetails(
                               -1, '(#PatientSurname#) (#PatientFirstName#)' )),
                                             High(N_App_NCI.NCICPatient_Name) );
{$ELSE}
  StrPLCopy( N_App_NCI.NCICApplication_ID, 'cmsuite',
                                           High(N_App_NCI.NCICApplication_ID) );

  StrPLCopy( N_App_NCI.NCICPatient_ID, N_StringToAnsi(K_CMGetPatientDetails( -1,
                   '(#PatientCardNumber#)' )), High(N_App_NCI.NCICPatient_ID) );
  StrPLCopy( N_App_NCI.NCICPatient_Name, N_StringToAnsi(K_CMGetPatientDetails(
                               -1, '(#PatientSurname#) (#PatientFirstName#)' )),
                                             High(N_App_NCI.NCICPatient_Name) );
{$IFEND}

  // NCI_Brand enum
  // nci_brand_undefined              = 0,
  // nci_brand_instrumentariumdental  = 1, // Instrumentarium Dental
  // nci_brand_soredex                = 2, // SOREDEX
  // nci_brand_kavo                   = 3, // KaVo
  N_App_NCI.NCICBrand := CMOFDeviceIndex; // retrieved from profile settings

  N_App_NCI.NCICMode := StrToIntDef( N_CMCDServObj18.PProfile.CMDPStrPar2, 1 ); // retrieved from profile settings

  if N_App_NCI.NCICMode = 1 then // invisible form when mode 1
    CMOFThisForm.AlphaBlendValue := 0;

  N_App_NCI.NCICDisable_Multilayer_Pan := -1; // nci_choice_false;
  N_App_NCI.NCICDisable_3D             := -1; // nci_choice_false;

  // image storage path must be an absolute path, at the moment it is /wrkfiles
{$IF SizeOf(Char) = 2}
  System.AnsiStrings.StrPLCopy( N_App_NCI.NCICImage_Path, N_StringToAnsi(ImageDir),
                                               High(N_App_NCI.NCICImage_Path) );
{$ELSE}
  StrPLCopy( N_App_NCI.NCICImage_Path, N_StringToAnsi(ImageDir),
                                               High(N_App_NCI.NCICImage_Path) );
{$IFEND}


  N_App_NCI.NCICImage_Format := 1; // nci_format_tiff;
  // volume storage path can be left empty in NCI_OpenS, in that case API will
  // fill it with image_path
  N_App_NCI.NCICVolume_Format := 1; // nci_format_tiff;

{$IF SizeOf(Char) = 2}
  System.AnsiStrings.StrPLCopy( N_App_NCI.NCICLanguage_ISO639_1, 'en',
                                        High(N_App_NCI.NCICLanguage_ISO639_1) );
{$ELSE}
  StrPLCopy( N_App_NCI.NCICLanguage_ISO639_1, 'en',
                                        High(N_App_NCI.NCICLanguage_ISO639_1) );
{$IFEND}

  RetVal := N_CMECDNCI_OpenS(@N_App_NCI);
  // it is possible to get an error with NCI_GetLastErrorS(&err_msg)
  if RetVal < 0 then
    K_CMShowMessageDlg( 'An error while opening the device''s interface',
                                                                      mtError );
  N_Dump1Str( 'OpenS = ' + IntToStr(RetVal) );

  RetVal := N_CMECDNCI_ShowS( 0 );

  // it is possible to get an error with NCI_GetLastErrorS(&err_msg)
  if RetVal < 0 then
    K_CMShowMessageDlg( 'An error while showing the device''s interface',
                                                                      mtError );
  N_Dump1Str( 'ShowS = ' + IntToStr(RetVal) );

  TimerCheck.Enabled := True; // start checking

  N_Dump1Str( 'PaloDEx End FormShow' );
end; // procedure TN_CMCaptDev18Form.FormShow

//******************************************** TN_CMCaptDev18Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev18Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
var
  RetVal: integer;
begin
  RetVal := N_CMECDNCI_CloseS( 0 ); // close a device

  // it is possible to get an error with NCI_GetLastErrorS(&err_msg)
  if RetVal < 0 then
      K_CMShowMessageDlg( 'An error while closing the device''s interface',
                                                                      mtError );
  N_Dump1Str( 'CloseS = ' + IntToStr(RetVal) );

  RemoveDir( K_ExpandFileName('(#TmpFiles#)/Pictures') ); // clear folders
  SetForegroundWindow( CMOFThisForm.Handle ); // set cms to a foreground

  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  N_Dump2Str( 'CMOther18Form.FormClose' );
  Inherited;
end; // TN_CMCaptDev18Form.FormClose

//****************************************** TN_CMCaptDev18Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev18Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev18Form.FormKeyDown

//******************************************** TN_CMCaptDev18Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev18Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev18Form.FormKeyUp

// procedure TN_CMCaptDev18Form.SlidePanelResize
procedure TN_CMCaptDev18Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev18Form.SlidePanelResize

//***************************************** TN_CMCaptDev18Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev18Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev18Form.tbLeft90Click

//**************************************** TN_CMCaptDev18Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev18Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev18Form.tbRight90Click

//************************************** TN_CMCaptDev18Form.TimerCheckTimer ***
// Timer actions
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev18Form.TimerCheckTimer( Sender: TObject );
begin
  TimerCheck.Enabled := False;
  if not (N_HandleEvent() = 0) then // nci window is closed when in mode 1
  begin
    Close;
  end;

  if CMOFStatus <> CMOFStatusPrev then // new status
  begin

    case CMOFStatus of
    1: begin // disconnected
      StatusLabel.Caption := 'Not available';
      StatusLabel.Font.Color  := clRed;
      StatusShape.Pen.Color   := clRed;
      StatusShape.Brush.Color := clRed;
    end; // disconnected
    2: begin // blocked
      StatusLabel.Caption := 'Blocked';
      StatusLabel.Font.Color  := clRed;
      StatusShape.Pen.Color   := clRed;
      StatusShape.Brush.Color := clRed;
    end; // blocked
    3: begin // connected
      StatusLabel.Caption := 'Connected';
      StatusLabel.Font.Color  := clGreen;
      StatusShape.Pen.Color   := clGreen;
      StatusShape.Brush.Color := clGreen;
    end; // connected
    4: begin // capturing
      StatusLabel.Caption := 'Processing';
      StatusLabel.Font.Color  := clBlue;
      StatusShape.Pen.Color   := clBlue;
      StatusShape.Brush.Color := clBlue;
    end; // capturing
    end;

    CMOFStatusPrev := CMOFStatus; // so do not change to a same one
  end;

  TimerCheck.Enabled := True;
end; // procedure TN_CMCaptDev18Form.TimerCheckTimer

// procedure TN_CMCaptDev18Form.UpDown1Click
procedure TN_CMCaptDev18Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev18Form.UpDown1Click

//******************************************* TN_CMCaptDev18Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev18Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev18Form.tb180Click

//*************************************** TN_CMCaptDev18Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev18Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev18Form.tbFlipHorClick


//**********************  TN_CMCaptDev18Form class public methods  ************

//**************************************** TN_CMCaptDev18Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev18Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev18Form.CMOFDrawThumb

//************************************* TN_CMCaptDev18Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev18Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
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

//****************************************** TN_CMCaptDev18Form.bnExitClick ***
// Exit
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev18Form.bnExitClick( Sender: TObject );
begin
  inherited;
end; // procedure TN_CMCaptDev18Form.bnExitClick

function TN_CMCaptDev18Form.SaveImage(Path: string): Integer;
var
  i:        Integer;
  RootComp: TN_UDCompVis;
  NewSlide: TN_UDCMSlide;
  CapturedDIB: TN_DIBObj;
begin
  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format('PaloDex Start CMOFCaptureSlide %d', [CMOFNumCaptured]));

  //CapturedDIB := TN_DIBObj.Create(Path);
  CapturedDIB:= Nil;
  N_LoadDIBFromFileByImLib( CapturedDIB, Path ); // new 8 or 16 bit variant

  // set bmi calculated with pixel size
  with CapturedDIB.DIBInfo.bmi do
  begin
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

  // Show NewSlide in SlideRFrame
  RootComp := NewSlide.GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );

  // Add NewSlide to CMOFThumbsDGrid
  Inc(CMOFThumbsDGrid.DGNumItems);
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  N_Dump1Str(Format('PaloDex Fin CMOFCaptureSlide %d', [CMOFNumCaptured]));
  Result := 0;
end;

//************************************* TN_CMCaptDev18Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev18Form.CMOFCaptureSlide(): Integer;
begin
  Result := 0;
end; // end of TN_CMCaptDev18Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev18Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev18Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev18Form.CurStateToMemIni

//************************************* TN_CMCaptDev18Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev18Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev18Form.MemIniToCurState

end.


