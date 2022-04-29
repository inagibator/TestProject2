unit N_CMCaptDev22F;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F,
  N_CMCaptDev22aF;

type N_ImageInfo = record // for importing images from the driver
  IIPPtr1: HGLOBAL; // bmi
  IIPPtr2: HGLOBAL; // pixels
end;

type TN_CMCaptDev22Form = class( TN_BaseForm )
    MainPanel:  TPanel;
    RightPanel: TPanel;
    SlidePanel: TPanel;
    bnExit:     TButton;
    ThumbsRFrame: TN_Rast1Frame;
    StatusShape: TShape;
    StatusLabel: TLabel;
    SlideRFrame: TN_Rast1Frame;
    bnCapture:   TButton;
    tbRotateImage: TToolBar;
    tbLeft90:    TToolButton;
    tbRight90:   TToolButton;
    tb180:       TToolButton;
    tbFlipHor:   TToolButton;
    cbAutoTake:  TCheckBox;
    bnSetup:     TButton;
    TimerCheck:  TTimer;

    //******************  TN_CMCaptDev22Form class handlers  ******************

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

    CMOFPhbmi, CMOFPhmpPixel: Pointer;
    CMOFInfo:         N_ImageInfo;

    ThisForm: TN_CMCaptDev22Form; // Pointer to this form

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide (): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;

end; // type TN_CMCaptDev22Form = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

implementation

uses
  Math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev22;
{$R *.dfm}

//**********************  TN_CMCaptDev22Form class handlers  ******************

//********************************************* TN_CMCaptDev22Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev22Form.FormShow( Sender: TObject );
var
  PathName, PatName, PatSurname, PatN, PatDOB, Doc: PAnsiChar;
  PatDay, PatMonth, PatYear: Integer;
  Initialized: Integer;
begin
  N_Dump1Str( 'Sirona Start FormShow' );

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

  //***** sidexis lookup
  if N_CMCDServObj22.PProfile.CMDPStrPar2 <> '' then
  begin
    if DirectoryExists(N_CMCDServObj22.PProfile.CMDPStrPar2) then
      //Res :=
      N_CMECD_SetNewPath(
                      @N_StringToAnsi(N_CMCDServObj22.PProfile.CMDPStrPar2)[1] )
    else
      begin
        K_CMShowMessageDlg( 'No Sidexis in the specified folder', mtError );
        Exit;
      end;
  end
  else
  begin
    PathName := 'C:\Sidexis\';
    if DirectoryExists( N_AnsiToString(PathName) ) then
      //Res :=
      N_CMECD_SetNewPath(PathName)
      else
      begin
        K_CMShowMessageDlg( 'No Sidexis in the default folder', mtError );
        Exit;
      end;
  end; // sidexis lookup

  StatusLabel.Caption := 'Initializing';
  //ClientName := 'a';
  //Initialized := 0;

  Initialized := N_CMECD_Initialize();

  if Initialized <> 0 then
    StatusLabel.Caption := 'Ready'
  else
  begin
    StatusLabel.Caption := 'Error initializing';
    K_CMShowMessageDlg( 'No Sidexis in the specified folder', mtError );
    Exit;
  end;

  PatName := @N_StringToAnsi(K_CMGetPatientDetails( -1,
                                                   '(#PatientFirstName#)' ))[1];
  PatSurname := @N_StringToAnsi(K_CMGetPatientDetails( -1,
                                                     '(#PatientSurname#)' ))[1];
  PatN := @N_StringToAnsi(K_CMGetPatientDetails( -1,
                                                  '(#PatientCardNumber#)' ))[1];
  PatDOB := @N_StringToAnsi(K_CMGetPatientDetails( -1, '(#PatientDOB#)' ))[1];

  PatDay := 1;
  PatMonth := 1;
  PatYear := 2000;

  if ( 10 = Length( PatDOB ) ) then
  begin
    PatDay   := StrToIntDef( Copy( N_AnsiToString(PatDOB), 1, 2 ), 1 );
    PatMonth := StrToIntDef( Copy( N_AnsiToString(PatDOB), 4, 2 ), 1 );
    PatYear  := StrToIntDef( Copy( N_AnsiToString(PatDOB), 7, 4 ), 1 );
  end; // if ( 10 = Length( PatDOB ) ) then

  //Res :=
  N_CMECD_SetPatient(PatName, PatSurname, PatN, PatYear, PatMonth,
                                                                        PatDay);

  Doc := @N_StringToAnsi(K_CMGetProviderDetails( -1,
                                                    '(#ProviderSurname#)' ))[1];
  //Res :=
  N_CMECD_SetDoc(Doc);
  N_Dump1Str( 'Sirona End FormShow' );
end; // procedure TN_CMCaptDev22Form.FormShow

//******************************************** TN_CMCaptDev22Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev22Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin
  TimerCheck.Enabled := False;

  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  N_Dump2Str( 'CMOther22Form.FormClose' );
  Inherited;
end; // TN_CMCaptDev22Form.FormClose

//****************************************** TN_CMCaptDev22Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev22Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev22Form.FormKeyDown

//******************************************** TN_CMCaptDev22Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev22Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev22Form.FormKeyUp

// procedure TN_CMCaptDev12Form.cbAutoTakeClick - not implemented in the interface
procedure TN_CMCaptDev22Form.cbAutoTakeClick( Sender: TObject );
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

end; // procedure TN_CMCaptDev22Form.cbAutoTakeClick

//************************************* TN_CMCaptDev22Form.SlidePanelResize ***
// resizing event for a slidepanel
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev22Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev22Form.SlidePanelResize

//*************************************** TN_CMCaptDev22Form.bnCaptureClick ***
// Capture Image in not CMOFAutoTake mode
//
//     Parameters
// Sender - Event Sender
//
// bnCapture button OnClick handler
//
procedure TN_CMCaptDev22Form.bnCaptureClick( Sender: TObject );
var
  Result: Integer;
begin
//N_CMECD_Initialize();
  N_Dump1Str( 'Before acquire' );
  //Result :=
  N_CMECD_SetType( CMOFDeviceIndex ); // device type
  Result := N_CMECD_Acquire( ThisForm.Handle, @CMOFInfo );
  N_Dump1Str( 'After acquire' );

  if Result = 1 then // true
  begin

    CMOFPhbmi     := GlobalLock( HGLOBAL(CMOFInfo.IIPPtr1) ); // get pointer for a memory
    CMOFPhmpPixel := GlobalLock( HGLOBAL(CMOFInfo.IIPPtr2) ); // get pointer

    CMOFCaptureSlide();
  end;
end; // procedure TN_CMCaptDev22Form.bnCaptureClick

//***************************************** TN_CMCaptDev22Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev22Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev22Form.tbLeft90Click

//**************************************** TN_CMCaptDev12Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev22Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev22Form.tbRight90Click

//************************************** TN_CMCaptDev12Form.TimerCheckTimer ***
// Timer actions
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev22Form.TimerCheckTimer( Sender: TObject );
begin
  TimerCheck.Enabled := False;
  TimerCheck.Enabled := True;
end; // procedure TN_CMCaptDev22Form.TimerCheckTimer

// procedure TN_CMCaptDev12Form.UpDown1Click
procedure TN_CMCaptDev22Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev22Form.UpDown1Click

//******************************************* TN_CMCaptDev12Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev22Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev22Form.tb180Click

//*************************************** TN_CMCaptDev12Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev22Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev22Form.tbFlipHorClick


//**********************  TN_CMCaptDev22Form class public methods  ************

//**************************************** TN_CMCaptDev22Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev22Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev22Form.CMOFDrawThumb

//************************************* TN_CMCaptDev22Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev22Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
                                  AInd: Integer; AInpSize: TPoint; out AOutSize,
                                        AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide:     TN_UDCMSlide;
  ThumbDIB:  TN_UDDIB;
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
end; // procedure TN_CMCaptDev22Form.CMOFGetThumbSize

//****************************************** TN_CMCaptDev22Form.bnExitClick ***
// Exit
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev22Form.bnExitClick( Sender: TObject );
//var
  //Res: Integer;
begin
//  Res := N_CMECD_Uninitialize();
  inherited;
end; // procedure TN_CMCaptDev22Form.bnExitClick

//***************************************** TN_CMCaptDev22Form.bnSetupClick ***
// Setup form
//
//     Parameters
// Sender - Event Sender
//
// Not implemented in the interface
//
procedure TN_CMCaptDev22Form.bnSetupClick( Sender: TObject );
var
  Form: TN_CMCaptDev22aForm; // Settings form
begin
  inherited;
  N_Dump1Str( 'Sirona >> CDSSettingsDlg begin' );

  Form := TN_CMCaptDev22aForm.Create( Application );
  // create setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  //Form.CMOFPDevProfile := CMOFPProfile; // link form variable to profile
  Form.Caption := CMOFPProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := N_CMCDServObj22.PProfile;
  Form.ShowModal(); // Show a setup form

  N_Dump1Str( 'Sirona >> CDSSettingsDlg end' );
end; // procedure TN_CMCaptDev22Form.bnSetupClick

//************************************* TN_CMCaptDev22Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev22Form.CMOFCaptureSlide(): Integer;
var
  CapturedDIB: TN_DIBObj;
  i:        Integer;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
  //Res:      Boolean;
begin
  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format('Sirona Start CMOFCaptureSlide %d', [CMOFNumCaptured]) );

  CapturedDIB := TN_DIBObj.Create();
  CapturedDIB.PrepEmptyDIBObj(PBITMAPINFO(CMOFPhbmi).bmiHeader.biWidth,
              PBITMAPINFO(CMOFPhbmi).bmiHeader.biHeight, pfCustom, -1, epfGray8,
                                   PBITMAPINFO(CMOFPhbmi).bmiHeader.biBitCount);
  N_Dump1Str( 'After prep' );
  Move( CMOFPhmpPixel^, CapturedDIB.PRasterBytes^, PBITMAPINFO(CMOFPhbmi).bmiHeader.biSizeImage);//BITMAPINFO(phbmi^).bmiHeader.biSize );

  N_Dump1Str('After move');

  //Res :=
  GlobalUnlock( HGLOBAL(CMOFInfo.IIPPtr1) ); // end with the pointer
  //Res :=
  GlobalUnlock( HGLOBAL(CMOFInfo.IIPPtr2) ); // end...

  //i :=
  GlobalFree( HGLOBAL(CMOFInfo.IIPPtr1) ); // clean
  //i :=
  GlobalFree( HGLOBAL(CMOFInfo.IIPPtr2) ); //...
  // ***** Here: CapturedDIB is OK

  NewSlide := K_CMSlideCreateFromDIBObj( CapturedDIB,
                                          @(CMOFPProfile^.CMAutoImgProcAttrs) );
    //NewSlide.SetAutoCalibrated();
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

  N_Dump1Str( Format('Sirona Fin CMOFCaptureSlide %d', [CMOFNumCaptured]) );
  Result := 0;
end; // end of TN_CMCaptDev22Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev22Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev22Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev22Form.CurStateToMemIni

//************************************* TN_CMCaptDev22Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev22Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev22Form.MemIniToCurState

end.


