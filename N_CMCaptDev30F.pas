unit N_CMCaptDev30F;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0, N_CMCaptDev0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type TN_CMCaptDev30Form = class( TN_BaseForm )
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
    RadioGroup1: TRadioGroup;
    TimerWindow: TTimer;

    //******************  TN_CMCaptDev30Form class handlers  ******************

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
    procedure TimerWindowTimer ( Sender: TObject );
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

    CMOFThisForm: TN_CMCaptDev30Form;        // Pointer to this form

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide ( Image: string ): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
    function  CMOFCaptureSlide2D( Image: string ): Integer;

end; // type TN_CMCaptDev30Form = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

var
  PelsPerInch: integer; // pixels per inch received from a driver

implementation

uses
  Math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev30,
  N_CMCaptDev30aF, TlHelp32, K_CM1, K_CML1F, N_CMResF, ShellAPI, IniFiles,
  K_CLib, K_RImage;
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

//*********************************************************** ProcessExists ***
// Search if the process is active by ExeName
//
//     Parameters
// ExeFileName - exe name
// Result      - if success
//
function ProcessExists( ExeFileName: string ): Boolean;
var
  ContinueLoop:    BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );
  FProcessEntry32.dwSize := SizeOf( FProcessEntry32 );
  ContinueLoop := Process32First( FSnapshotHandle, FProcessEntry32 );
  Result := False;
  while Integer(ContinueLoop) <> 0 do
  begin
    if ( (UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
              UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
                                                  UpperCase(ExeFileName)) ) then
    begin
      Result := True;
    end;
    ContinueLoop := Process32Next( FSnapshotHandle, FProcessEntry32 );
  end;
  CloseHandle( FSnapshotHandle );
end; // function ProcessExists( ExeFileName: string ): Boolean;

//**********************  TN_CMCaptDev30Form class handlers  ******************

//************************************* TN_CMCaptDev30Form.CMOFCaptureSlide ***
// Importing Image
//
//     Parameters
// Image  - Filename
// Result - 0 if correct
//
function TN_CMCaptDev30Form.CMOFCaptureSlide2D( Image: string ): Integer;
var
  i: Integer;
  CapturedDIB, NDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
begin
  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format('Vatech Start CMOFCaptureSlide %d', [CMOFNumCaptured]));

  CapturedDIB := Nil;
  N_LoadDIBFromFileByImLib( CapturedDIB, Image ); // new 8 or 16 bit variant

  //CapturedDIB.SaveToBMPFormat('c:\image.bmp');

  //NDIB := TN_DIBObj.Create( CapturedDIB, 0, pfCustom, -1, epfGray8 );
  //CapturedDIB.CalcGrayDIB( NDIB );
  //CapturedDIB.Free;
  //CapturedDIB := NDIB;

  // autocontrast
  NDIB := Nil;
  CapturedDIB.CalcMaxContrastDIB( NDIB );
  CapturedDIB.Free();
  CapturedDIB := NDIB;

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

  N_Dump1Str(Format('Vatech Fin CMOFCaptureSlide %d', [CMOFNumCaptured]));
  Result := 0;
end; // end of TN_CMCaptDev30Form.CMOFCaptureSlide

//********************************************* TN_CMCaptDev30Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev30Form.FormShow( Sender: TObject );
begin
  N_Dump1Str( 'Vatech Start FormShow' );
  //bnSetup.Enabled := False;

  Caption := CMOFPProfile^.CMDPCaption + ' X-Ray Capture';
  tbRotateImage.Images := N_CM_MainForm.CMMCurBigIcons;
  CMOFDrawSlideObj := TN_CMDrawSlideObj.Create(); // used in jn CMOFDrawThumb for Drawing Thumbnails
  CMOFThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, CMOFGetThumbSize );

  CMOFStatus := 1; // beginning status

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

  if CMOFPProfile.CMDPStrPar2 <> '' then
    RadioGroup1.ItemIndex := StrToInt( CMOFPProfile.CMDPStrPar2[1] )
  else
  begin
    RadioGroup1.ItemIndex := 0;
    CMOFPProfile.CMDPStrPar2 := '01';
  end;

  if Length(CMOFPProfile.CMDPStrPar2) = 1 then // old version to the new one
    CMOFPProfile.CMDPStrPar2 := CMOFPProfile.CMDPStrPar2 + '1';

  bnCapture.OnClick( Nil ); // start

  N_Dump1Str( 'Vatech End FormShow' );
end; // procedure TN_CMCaptDev30Form.FormShow

//******************************************** TN_CMCaptDev30Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev30Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
var
  TmpStr: string;
begin
  if CMOFPProfile.CMDPStrPar2 <> '' then
  begin
    TmpStr := IntToStr( RadioGroup1.ItemIndex );
    CMOFPProfile.CMDPStrPar2[1] := TmpStr[1];//IntToStr( RadioGroup1.ItemIndex );
  end;

  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  N_Dump2Str( 'CMOther25Form.FormClose' );
  Inherited;
end;

//*************************************** TN_CMCaptDev30Form.FormCloseQuery ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// CanClose
//
// OnClose Self handler
//
procedure TN_CMCaptDev30Form.FormCloseQuery(Sender: TObject;
                                                         var CanClose: Boolean);
begin
  inherited;
end; // TN_CMCaptDev30Form.FormCloseQuery

procedure TN_CMCaptDev30Form.FormCreate(Sender: TObject);
begin
  inherited;

end;

//****************************************** TN_CMCaptDev30Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev30Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev30Form.FormKeyDown

//******************************************** TN_CMCaptDev30Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev30Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev30Form.FormKeyUp

procedure TN_CMCaptDev30Form.FormPaint(Sender: TObject);
begin
  inherited;
end;

//************************************* TN_CMCaptDev30Form.SlidePanelResize ***
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev30Form.SlidePanelResize( Sender: TObject );
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev30Form.SlidePanelResize

//**************************************** TN_CMCaptDev30Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev30Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev30Form.tbLeft90Click

//*************************************** TN_CMCaptDev30Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev30Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev30Form.UpDown1Click

//************************************** TN_CMCaptDev30Form.TimerImageTimer ***
// Waiting for an image
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev30Form.TimerImageTimer(Sender: TObject);
var
  WrkDir, FileName, TmpStr: string;
  IniFile:          TIniFile;

  Count: Integer;

// ***** variables that may be used in the future
//  f:           TextFile;
//  Dir, BinDir: string;
//  TempInt: Integer;
//  sr:          TSearchRec;
//  FName :   string;
//  RetCode : Integer;
//  ErrStr :  string;
//  DIB:      TN_DIBObj;

//*************************************************************** IsInteger ***
// Look if there's an integer value in a string
//
//    Parameters
// S      - String
// Result - True if there's an integerF value
//
function IsInteger( const S: String ): Boolean;
var
  X: Double;
  E: Integer;
begin
  Val(S, X, E);
  Result := (E = 0) and (Trunc(X) = X);
end; // function IsInteger( const S: String ): Boolean;

//************************************************************* GetFileName ***
// Parse ini for Modality
//
//     Parameters
// Result - Modality string
//
function GetModality(): string;
begin
  IniFile := TIniFile.Create( TmpStr );
  Result := IniFile.ReadString ( 'IMAGE_INFO', 'Modality', '' );

  IniFile.Free;
end;

//************************************************************* GetFileName ***
// Parse ini for Filename
//
//     Parameters
// Result - Filename
//
function GetFileName(): string;
begin
  IniFile := TIniFile.Create( TmpStr );
  Result := IniFile.ReadString ( 'IMAGE_INFO', 'SavePath', '' );

  IniFile.Free;
end;

//************************************************************* GetFileName ***
// Parse ini for Filename 2D
//
//     Parameters
// Result - Filename
//
function GetFileName2D(): string;
begin
  IniFile := TIniFile.Create( TmpStr );
  Result := IniFile.ReadString ( 'IMAGE_INFO', 'SavePath', '' );
  Result := Result + IniFile.ReadString ( 'IMAGE_INFO', 'SaveName', '' );

  IniFile.Free;
end;

begin
  inherited;

  ProgressBar1.Position := ProgressBar1.Position + 10;
  WrkDir := K_ExpandFIleName( '(#TmpFiles#)' );
  WrkDir := StringReplace(WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase]);

  CMOFStatus := 3;

  if CMOFPProfile.CMDPStrPar2 <> '' then
  begin
    TmpStr := CMOFPProfile.CMDPStrPar2;
    Delete( TmpStr, 1, 1 );

    if TmpStr <> '' then // new version
    if IsInteger(TmpStr[1]) then
      Delete( TmpStr, 1, 1 );
  end;

  if TmpStr = '' then
    TmpStr := WrkDir + 'Vatech/Output.ini';

  N_Dump1Str( 'Output.ini used = ' + TmpStr );
  if FileExists( TmpStr ) then
  begin

    if (GetModality() = 'Pano') or (GetModality() = 'Ceph') then
    begin
      TimerImage.Enabled := False; // stop
      ProgressBar1.Position := ProgressBar1.Position + 20;

      CMOFStatus := 4;
      FileName := GetFileName2D();
      N_Dump1Str( 'Filename is = ' + FileName );
      if FileName = '' then // maybe, problem reading
      begin
        Count := 0;
        while True do
        begin
          FileName := GetFileName();
          Inc( Count );
          Sleep( 100 );
          if Count > 5 then
          begin
            K_CMShowMessageDlg( 'Unable to read XML Info',
                                              mtInformation, [], FALSE, '', 5 );
            N_Dump1Str( 'Unable to read XML Info' );
            Break;
          end;

          if FileName <> '' then // all fine
            Break;

        end;

      end;

      ProgressBar1.Position := ProgressBar1.Position + 25;

      CMOFStatus := 5;

      //CopyFile(@N_StringToWide(FileName)[1], @N_StringToWide(WrkDir + 'Vatech/temp')[1], false);
      CMOFCaptureSlide2D( FileName );//WrkDir + 'Vatech/temp' );

      //***** clean
      Screen.Cursor := crHourglass;
      CMOFStatus := 10;
      //if CMOFPProfile.CMDPStrPar2[1] = '0' then // cms 3d
      //  DeleteFolder( WrkDir + 'Vatech' );
      Screen.Cursor := crDefault;

      CMOFStatus := 1;
      bnCapture.Visible := True;
      bnStop.Visible    := False;
      DeleteFile(TmpStr);
      Close();
    end
    else
    begin

      TimerImage.Enabled := False; // stop
      ProgressBar1.Position := ProgressBar1.Position + 20;

      CMOFStatus := 4;
      FileName := GetFileName();
      N_Dump1Str( 'Filename is = ' + FileName );
      if FileName = '' then // maybe, problem reading
      begin
        Count := 0;
        while True do
        begin
          FileName := GetFileName();
          Inc( Count );
          Sleep( 100 );
          if Count > 5 then
          begin
            K_CMShowMessageDlg( 'Unable to read XML Info',
                                              mtInformation, [], FALSE, '', 5 );
            N_Dump1Str( 'Unable to read XML Info' );
            Break;
          end;

          if FileName <> '' then // all fine
            Break;

        end;

      end;

      ProgressBar1.Position := ProgressBar1.Position + 25;

      CMOFStatus := 5;

    // ***** may be used later
    {  if False then // cms 3d // always native
      begin
        if not (N_CMResForm.aMediaImport3D.Visible) then
        begin
          K_CMShowMessageDlg( '3d import is unaccessible',
                                              mtInformation, [], FALSE, '', 5 );
  //    Close();
        end
        else
          CMOFCaptureSlide( FileName );
      end
      else
      begin // ez3d-i
        N_Dump1Str( 'Starting import for 3D native' );

        FName := N_MemIniToString( 'CMS_Main','ThumbVatechFName', '' );
        DIB := TN_DIBObj.Create();

        RetCode := K_LoadDIBFromVFileByRI( K_RIObj, FName, DIB );
        if RetCode = 0 then N_Dump1Str( 'RetCode = 0' );
        case RetCode of
        1: ErrStr := 'is absent';
        2: ErrStr := 'has not proper format';
        end;

        if (RetCode = 1) or (RetCode = 2) then
          N_Dump1Str( format( ' 3Shape Thumbnail file  "%s"  error >> %s', [FName, ErrStr] ) );

        N_Dump1Str( 'Before ceating Slide' );
        K_CMDev3DCreateSlide( CMOFPProfile, FileName, DIB, 0, 0, 0, 8 );

        if False then // need to open right away, always
        begin
          Dir := K_ExpandFileName( '(#TmpFiles#)' );
          Dir := StringReplace( Dir, '\', '/', [rfReplaceAll, rfIgnoreCase] );
          CreateDir(Dir + 'Vatech');
          Dir := Dir + 'Vatech/open.xml';

          BinDir := K_ExpandFileName( '(#TmpFiles#)' );
          BinDir := StringReplace( Dir, 'TmpFiles', 'BinFiles', [rfReplaceAll, rfIgnoreCase] );

          AssignFile (f, Dir);
          Rewrite (f);
          WriteLn (f, '<?xml version="1.0" encoding="UTF-8"?>' );
          WriteLn (f, '<E3Protocol version="2.0" locale="en_US">');

           if IsInteger(K_CMGetPatientDetails( -1, '(#PatientID#)' )) then
           begin
             TempInt := StrToInt(K_CMGetPatientDetails( -1, '(#PatientID#)' ));
             TempInt := TempInt + 100;
             TempInt := TempInt * (-1);
             WriteLn (f, '<Param id="Chart No" value="' + IntToStr(TempInt) + '"/>');
          end
          else
            WriteLn (f, '<Param id="Chart No" value="' +
                          K_CMGetPatientDetails( -1, '(#PatientID#)' ) + '"/>');

          WriteLn (f, '<Caller id="EEEP_0000"/>');
          WriteLn (f, '<Files>' );

          // ***** stating all the files in dir
          if FindFirst(FileName + '*.dcm', faAnyFile, sr) = 0 then
          begin
          repeat
            WriteLn (f, '<File path="' + FileName + sr.Name + '"/>');//TmpDir + 'Vatech\Test\' + sr.Name + '"/>');
          until FindNext(sr) <> 0;
          FindClose(sr);

          end;

          WriteLn (f, '</Files>');
          WriteLn (f, '<Output path="C:\yourOutputspath\" />');
          WriteLn (f, '</E3Protocol>' );
          CloseFile (f);

      //ShellExecute(0, 'open', @N_StringToWide('C:\Program Files\vatech\Ez3D-i\bin\Ez3D-i64.exe')[1],
      //                              @N_StringToWide(WrkDir)[1], nil, SW_SHOWNORMAL);
          N_Dump1Str( 'Command string is ' + '"' + 'C:\Program Files\vatech\Ez3D-i\bin\Ez3D-i64.exe' + '" /param:"' + Dir + '"');
          WinExec( @(N_StringToAnsi('"' + 'C:\Program Files\vatech\Ez3D-i\bin\Ez3D-i64.exe' + '" /param:"' + Dir + '"')[1]), SW_SHOWNORMAL);
        end; // if open right away


      end;}

      //***** clean
      Screen.Cursor := crHourglass;
      CMOFStatus := 10;

      if False then // cms 3d
        DeleteFolder( WrkDir + 'Vatech' );

      Screen.Cursor := crDefault;

      CMOFStatus := 1;
      bnCapture.Visible := True;
      bnStop.Visible    := False;
      Close();
    end; // else, it's cbct
  end;
end; // procedure TN_CMCaptDev30Form.TimerImageTimer(Sender: TObject);

procedure TN_CMCaptDev30Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev30Form.UpDown1Click

//******************************************* TN_CMCaptDev30Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev30Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev30Form.tb180Click

//*************************************** TN_CMCaptDev30Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev30Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev30Form.tbFlipHorClick


//**********************  TN_CMCaptDev30Form class public methods  ************

//**************************************** TN_CMCaptDev30Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev30Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev30Form.CMOFDrawThumb

//************************************* TN_CMCaptDev30Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev30Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
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
end; // procedure TN_CMCaptDev30Form.CMOFGetThumbSize

//*************************************** TN_CMCaptDev30Form.bnCaptureClick ***
// Capture
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev30Form.bnCaptureClick(Sender: TObject);
var
  WrkDir:    string;
  DriverRes: Boolean;
begin
  inherited;
  bnStop.Visible    := True;
  bnCapture.Visible := False;
  DriverRes         := False;

  ProgressBar1.Position := 0;

  WrkDir := K_ExpandFileName( '(#TmpFiles#)' );
  N_Dump1Str( 'WrkDir = ' + WrkDir );
  WrkDir := StringReplace( WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase] );
  ProgressBar1.Position := ProgressBar1.Position + 15;

  if DirectoryExists( WrkDir + 'Vatech' ) then
    DeleteFolder( WrkDir + 'Vatech' );

  ProgressBar1.Position := ProgressBar1.Position + 20;

  TimerImage.Enabled := True;
  CMOFStatus := 2;

  if CMOFPProfile.CMDPStrPar1 <> '' then
  begin
    if RadioGroup1.ItemIndex = 0 then
      DriverRes := N_CMCDServObj30.StartDriver( CMOFPProfile.CMDPStrPar1, True, 0 );
    if RadioGroup1.ItemIndex = 1 then
      DriverRes := N_CMCDServObj30.StartDriver( CMOFPProfile.CMDPStrPar1, True, 1 );

  end
  else
  begin
    K_CMShowMessageDlg( 'Vatech settings should be filled',
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

  if (ProcessExists(extractfilename(CMOFPProfile.CMDPStrPar1))) and
                                        (CMOFPProfile.CMDPStrPar2[2] = '1') then // hide the window
  begin
    // ***** making a form invisible
    Self.AlphaBlend      := True;
    Self.AlphaBlendValue := 0;

    TimerWindow.Enabled := True;
  end;
end; //***************************************** TN_CMCaptDev30Form.bnCaptureClick ***

//***************************************** TN_CMCaptDev30Form.bnSetupClick ***
// Capture
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev30Form.bnSetupClick(Sender: TObject);
var
  Form: TN_CMCaptDev30aForm; // Settings form
begin
  inherited;
  N_Dump1Str( 'Vatech >> CDSSettingsDlg begin' );

  Form := TN_CMCaptDev30aForm.Create( Application );
  // create setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  //Form.CMOFPDevProfile := CMOFPProfile; // link form variable to profile
  Form.Caption := CMOFPProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := N_CMCDServObj30.PProfile;
  Form.ShowModal(); // Show a setup form

  N_Dump1Str( 'Vatech >> CDSSettingsDlg end' );
end; // procedure TN_CMCaptDev30Form.bnSetupClick

//************************************* TN_CMCaptDev30Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Image - image path
// Return 0 if OK
//
procedure TN_CMCaptDev30Form.bnStopClick(Sender: TObject);
begin
  inherited;
  CMOFStatus := 1;

  bnCapture.Visible     := True;
  bnStop.Visible        := False;
  ProgressBar1.Position := 0;
  TimerImage.Enabled    := False;
end; // procedure TN_CMCaptDev30Form.bnStopClick(Sender: TObject);

//************************************* TN_CMCaptDev30Form.TimerStatusTimer ***
// Changing status
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev30Form.TimerStatusTimer( Sender: TObject );
begin
  inherited;
  if CMOFStatus <> CMOFStatusPrev then // new status
  begin
    case CMOFStatus of
    1: begin
      StatusLabel.Caption := 'Waiting';
      StatusLabel.Font.Color  := TColor( $168EF7 );
      StatusShape.Pen.Color   := TColor( $168EF7 );
      StatusShape.Brush.Color := TColor( $168EF7 );
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
end; // procedure TN_CMCaptDev30Form.TimerStatusTimer

//************************************* TN_CMCaptDev19Form.TimerWindowTimer ***
// Check if native viewer is open
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev30Form.TimerWindowTimer(Sender: TObject);
begin
  inherited;

  if not ProcessExists(extractfilename(CMOFPProfile.CMDPStrPar1)) then // close
  begin
    N_Dump1Str('Process stopped');
    Close();

  end;
end; // procedure TN_CMCaptDev30Form.TimerWindowTimer

//************************************* TN_CMCaptDev30Form.CMOFCaptureSlide ***
// Importing Image
//
//     Parameters
// Image  - Filename
// Result - 0 if correct
//
function TN_CMCaptDev30Form.CMOFCaptureSlide( Image: string ): Integer;
var
  i: Integer;
  CapturedDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
begin
  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format('Vatech Start CMOFCaptureSlide %d', [CMOFNumCaptured]));

  CapturedDIB := Nil;
  N_LoadDIBFromFileByImLib( CapturedDIB, Image ); // new 8 or 16 bit variant

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

  N_Dump1Str(Format('Vatech Fin CMOFCaptureSlide %d', [CMOFNumCaptured]));
  Result := 0;
end; // end of TN_CMCaptDev30Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev30Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev30Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev30Form.CurStateToMemIni

//************************************* TN_CMCaptDev30Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev30Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev30Form.MemIniToCurState

end.

