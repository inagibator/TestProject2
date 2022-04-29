unit N_CMCaptDev19F;

interface

{$IFNDEF VER150} //***** not Delphi 7

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0, N_CMCaptDev0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IOUtils;

type TN_CMCaptDev19Form = class( TN_BaseForm )
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
    Timer3DEnabled: TTimer;
    bnTest: TButton;
    TimerWindow: TTimer;

    //******************  TN_CMCaptDev19Form class handlers  ******************

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
    procedure Timer3DEnabledTimer( Sender: TObject );
    procedure TimerWindowTimer   ( Sender: TObject );
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
    CMOFThumbnail: string;

    CMOFThisForm: TN_CMCaptDev19Form;        // Pointer to this form

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide  ( Image: string ): Integer;
    function  CMOFCaptureSlide2D( Image: string ): Integer;
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;

end; // type TN_CMCaptDev19Form = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

var
  PelsPerInch: integer; // pixels per inch received from a driver

implementation

uses
  Math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev19,
  N_CMCaptDev19aF, TlHelp32, K_CM1, K_CML1F, N_CMResF, ShellAPI, IniFiles,
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

//**********************  TN_CMCaptDev19Form class handlers  ******************

//********************************************* TN_CMCaptDev19Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev19Form.FormShow( Sender: TObject );
var
  TmpStr: string;
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

  TmpStr := CMOFPProfile.CMDPStrPar2;
  Delete( TmpStr, 1, 1 );
  Delete( TmpStr, 1, 1 );
  CMOFThumbnail := TmpStr;

  //if CMOFPProfile.CMDPStrPar1 <> '' then
  //begin
  //  bnCapture.OnClick( Nil );
  //end;

  if Length(CMOFPProfile.CMDPStrPar2) < 2 then
  if CMOFPProfile.CMDPStrPar2 = '' then
     CMOFPProfile.CMDPStrPar2 := '11'
  else
     CMOFPProfile.CMDPStrPar2 := CMOFPProfile.CMDPStrPar2 + '1';

  bnCapture.OnClick( Nil ); // start

  N_Dump1Str( 'Vatech End FormShow' );
end; // procedure TN_CMCaptDev19Form.FormShow

//******************************************** TN_CMCaptDev19Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev19Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  N_Dump2Str( 'CMOther19Form.FormClose' );
  Inherited;
end;

//*************************************** TN_CMCaptDev19Form.FormCloseQuery ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// CanClose
//
// OnClose Self handler
//
procedure TN_CMCaptDev19Form.FormCloseQuery(Sender: TObject;
                                                         var CanClose: Boolean);
begin
  inherited;
end; // TN_CMCaptDev19Form.FormCloseQuery

procedure TN_CMCaptDev19Form.FormCreate(Sender: TObject);
begin
  inherited;

end;

//****************************************** TN_CMCaptDev19Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev19Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev19Form.FormKeyDown

//******************************************** TN_CMCaptDev19Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev19Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev19Form.FormKeyUp

procedure TN_CMCaptDev19Form.FormPaint(Sender: TObject);
begin
  inherited;
end;

//************************************* TN_CMCaptDev19Form.SlidePanelResize ***
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev19Form.SlidePanelResize( Sender: TObject );
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev19Form.SlidePanelResize

//**************************************** TN_CMCaptDev19Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev19Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev19Form.tbLeft90Click

//*************************************** TN_CMCaptDev19Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev19Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev19Form.tbRight90Click

//********************************** TN_CMCaptDev19Form.Timer3DEnabledTimer ***
// Check for 3D
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev19Form.Timer3DEnabledTimer(Sender: TObject);
begin
  inherited;
//  if not (N_CMResForm.aMediaImport3D.Visible) then
//  begin
//    Timer3DEnabled.Enabled := False;
//    K_CMShowMessageDlg( '3d import is unaccessible',
//                                              mtInformation, [], FALSE, '', 5 );
//    Close();
//  end;
end;

//************************************** TN_CMCaptDev19Form.TimerImageTimer ***
// Waiting for an image, bot used anymore
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev19Form.TimerImageTimer(Sender: TObject);
var
  WrkDir, FileName, TmpStr, TmpPath: string;
  IniFile: TIniFile;

  f:           TextFile;
  Dir, BinDir: string;
  Count:       Integer;
  sr:          TSearchRec;

  FName:   string;
  RetCode: Integer;
  ErrStr:  string;
  DIB:     TN_DIBObj;

  Slide3D:   TN_UDCMSlide;
  FPathName: string;

//*************************************************************** IsInteger ***
// Look if there's an integer value in a string
//
//    Parameters
// S      - String
// Result - True if there's an integer value
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
  IniFile := TIniFile.Create( WrkDir + 'Vatech\Output.ini' );
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
  IniFile := TIniFile.Create( WrkDir + 'Vatech\Output.ini' );
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
  IniFile := TIniFile.Create( WrkDir + 'Vatech\Output.ini' );
  Result := IniFile.ReadString ( 'IMAGE_INFO', 'SavePath', '' );
  Result := Result + IniFile.ReadString ( 'IMAGE_INFO', 'SaveName', '' );

  IniFile.Free;
end;

procedure CopyFilesToPath(aFiles: array of string; DestPath: string);
var
  InFile, OutFile: string;
begin
  for InFile in aFiles do
  begin
    OutFile := TPath.Combine( DestPath, TPath.GetFileName( InFile ) );
    TFile.Copy( InFile, OutFile, True);
  end;
end;

function CopyDir( const fromDir, toDir: string ): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_COPY;
    fFlags := FOF_FILESONLY;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

function GetDeepestDir(const aFilename:string):string;
begin
  Result := extractFileName(ExtractFileDir(afilename));
end;

function CopyFolderFiles( const SPath, DPath : string;
          const CopyPat : string= '*.*'; CopyFileFlags : TK_CopyFileFlags = [] ) : Boolean;
var
  F: TSearchRec;
  SName, DName : string;
begin
  Result := TRUE;

  if FindFirst( SPath + '*.*', faAnyFile, F ) = 0 then
    repeat
      if F.Name[1] = '.' then continue;
      SName := SPath+F.Name;
      DName := DPath+F.Name;
      if (F.Attr and faDirectory) <> 0 then
        Result := Result and K_CopyFolderFiles( IncludeTrailingPathDelimiter( SName ),
                                        IncludeTrailingPathDelimiter( DName ),
                                        CopyPat, CopyFileFlags )
      else
      if (CopyPat = '*.*') or
         K_CheckTextPattern( F.Name, CopyPat, TRUE ) then
        Result := Result and (K_CopyFile( SName, DName, CopyFileFlags ) = 0);
    until FindNext( F ) <> 0;
  FindClose( F );
end; //*** end of K_CopyFolderFiles

begin
  inherited;
  TimerImage.Enabled  := False;

  ProgressBar1.Position := ProgressBar1.Position + 10;
  WrkDir := K_ExpandFIleName( '(#TmpFiles#)' );
  WrkDir := StringReplace(WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase]);

  CMOFStatus := 3;

  if FileExists( WrkDir + 'Vatech/Output.ini' ) then
  begin
  TimerWindow.Enabled := False; // stop auto closing

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
      DeleteFile(WrkDir + 'Vatech/Output.ini');
      N_Dump1Str( 'Before closing' );
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

      if CMOFPProfile.CMDPStrPar2[1] = '0' then // cms 3d
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
        FName := N_MemIniToString( 'CMS_Main','ThumbVatechFName', '' );

        // ***** thumbnail search
        DIB := TN_DIBObj.Create();

        if FileExists( CMOFThumbnail ) then //FileName + '\TEMP\Thumbnail.bmp' ) then // replacing with an actual thumbnail
        begin
          N_Dump1Str( 'Thumbnail found = ' + CMOFThumbnail );//FileName + '\TEMP\Thumbnail.bmp' );
          FName := CMOFThumbnail;//FPathName+'\TEMP\Thumbnail.bmp';
        end;

        RetCode := K_LoadDIBFromVFileByRI( K_RIObj, FName, DIB );
        if RetCode = 0 then N_Dump1Str( 'RetCode = 0' );
        case RetCode of
        1: ErrStr := 'is absent';
        2: ErrStr := 'has not proper format';
        end;

        if (RetCode = 1) or (RetCode = 2) then
          N_Dump1Str( format( ' 3Shape Thumbnail file  "%s"  error >> %s', [FName, ErrStr] ) );

        K_CMDev3DCreateSlide( CMOFPProfile, '', DIB, 0, 0, 0, 8 );

        // object access
        with K_CMEDAccess do
        Slide3D := TN_UDCMSlide( CurSlidesList[CurSlidesList.Count - 1] );

        // get the filename
        FPathName := TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImg3DPath( Slide3D ) +
        K_CMSlideGetImg3DFolderName( Slide3D.ObjName );

        //FPathName := 'C:\CMS\WrkFiles\Test\New\';
        //N_Dump1Str( 'Creating directory for 3d slide = ' + FPathName );
        //System.IOUtils.TDirectory.CreateDirectory(FPathName);
        //N_Dump1Str( 'Then copying from = ' + FileName );

        //K_CopyFolderFiles( FileName, FPathName );

        TmpStr := ExtractFileName(ExcludeTrailingPathDelimiter(FileName)); // get folder name
        TmpPath := StringReplace(FPathName, TmpStr+'\', '', [rfReplaceAll, rfIgnoreCase]); // delete folder name from path
        N_Dump1Str('zzzzzzz '+TmpStr+' ffffffffffffff '+TmpPath);
        CopyDir(FileName, TmpPath);
        //MoveFile(@N_StringToWide(TmpPath + TmpStr)[1], @N_StringToWide(FPathName)[1]);
        RenameFile(TmpPath + TmpStr, FPathName);

        DeleteFile(WrkDir + 'Vatech/Output.ini');

        N_Dump1Str( 'Check = ' + FileName + ', '+FPathName );

        if CMOFPProfile.CMDPStrPar2[2] = '1' then // need to open right away
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

           //if IsInteger(K_CMGetPatientDetails( -1, '(#PatientID#)' )) then
           //begin
           //  TempInt := StrToInt(K_CMGetPatientDetails( -1, '(#PatientID#)' ));
           //  TempInt := TempInt + 100;
           //  TempInt := TempInt * (-1);
           //  WriteLn (f, '<Param id="Chart No" value="' + IntToStr(TempInt) + '"/>');
          //end
          //else
            WriteLn (f, '<Param id="Chart No" value="' +
                                       IntToStr(K_CMEDAccess.CurPatID) + '"/>');

          WriteLn (f, '<Caller id="EEEP_0000"/>');
          WriteLn (f, '<Files>' );

          // ***** stating all the files in dir
          if FindFirst(FPathName + '*.dcm', faAnyFile, sr) = 0 then
          begin
          repeat
            WriteLn (f, '<File path="' + FPathName + sr.Name + '"/>');//TmpDir + 'Vatech\Test\' + sr.Name + '"/>');
          until FindNext(sr) <> 0;
          FindClose(sr);

          end;

          WriteLn (f, '</Files>');
          WriteLn (f, '<Output path="C:\yourOutputspath\" />');
          WriteLn (f, '</E3Protocol>' );
          CloseFile (f);

          N_Dump1Str( 'Command string is ' + '"' + 'C:\Program Files\vatech\Ez3D-i\bin\Ez3D-i64.exe' + '" /param:"' + Dir + '"');
          WinExec( @(N_StringToAnsi('"' + 'C:\Program Files\vatech\Ez3D-i\bin\Ez3D-i64.exe' + '" /param:"' + Dir + '"')[1]), SW_SHOWNORMAL);
        end; // if open right away

      end;

      //***** clean
      Screen.Cursor := crHourglass;
      CMOFStatus := 10;

      if CMOFPProfile.CMDPStrPar2[1] = '0' then // cms 3d
        DeleteFolder( WrkDir + 'Vatech' );

      Screen.Cursor := crDefault;

      CMOFStatus := 1;
      bnCapture.Visible := True;
      bnStop.Visible    := False;
      Close();
    end; // else, it's cbct
  end; // if FileExists( WrkDir + 'Vatech/Output.ini' ) then

  TimerWindow.Enabled := True;
  TimerImage.Enabled  := True;
end; // procedure TN_CMCaptDev19Form.TimerImageTimer(Sender: TObject);

procedure TN_CMCaptDev19Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev19Form.UpDown1Click

//******************************************* TN_CMCaptDev19Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev19Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev19Form.tb180Click

//*************************************** TN_CMCaptDev19Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev19Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev19Form.tbFlipHorClick


//**********************  TN_CMCaptDev19Form class public methods  ************

//**************************************** TN_CMCaptDev19Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev19Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev19Form.CMOFDrawThumb

//************************************* TN_CMCaptDev19Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev19Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
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
end; // procedure TN_CMCaptDev19Form.CMOFGetThumbSize

//*************************************** TN_CMCaptDev19Form.bnCaptureClick ***
// Capture
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev19Form.bnCaptureClick(Sender: TObject);
var
  WrkDir:    string;
  DriverRes: Boolean;
begin
  inherited;
  bnStop.Visible    := True;
  bnCapture.Visible := False;

  ProgressBar1.Position := 0;

  WrkDir := K_ExpandFIleName( '(#TmpFiles#)' );
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
    DriverRes := N_CMCDServObj19.StartDriver( CMOFPProfile.CMDPStrPar1, True );

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

  if (ProcessExists(extractfilename(CMOFPProfile.CMDPStrPar1)))
                                    and (CMOFPProfile.CMDPStrPar2[1] = '1') then // hide the window, for native viewer
  begin
    // ***** making a form invisible
    Self.AlphaBlend      := True;
    Self.AlphaBlendValue := 0;

    TimerWindow.Enabled := True;
  end;
end; //***************************************** TN_CMCaptDev19Form.bnCaptureClick ***

//***************************************** TN_CMCaptDev19Form.bnSetupClick ***
// Capture
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev19Form.bnSetupClick(Sender: TObject);
var
  Form: TN_CMCaptDev19aForm; // Settings form
begin
  inherited;
  N_Dump1Str( 'Vatech >> CDSSettingsDlg begin' );

  Form := TN_CMCaptDev19aForm.Create( Application );
  // create setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  //Form.CMOFPDevProfile := CMOFPProfile; // link form variable to profile
  Form.Caption := CMOFPProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := N_CMCDServObj19.PProfile;
  Form.ShowModal(); // Show a setup form

  N_Dump1Str( 'Vatech >> CDSSettingsDlg end' );
end; // procedure TN_CMCaptDev19Form.bnSetupClick

//************************************* TN_CMCaptDev19Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Image - image path
// Return 0 if OK
//
procedure TN_CMCaptDev19Form.bnStopClick(Sender: TObject);
begin
  inherited;
  CMOFStatus := 1;

  bnCapture.Visible     := True;
  bnStop.Visible        := False;
  ProgressBar1.Position := 0;
  TimerImage.Enabled    := False;
end; // procedure TN_CMCaptDev19Form.bnStopClick(Sender: TObject);

//************************************* TN_CMCaptDev19Form.TimerStatusTimer ***
// Changing status
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev19Form.TimerStatusTimer( Sender: TObject );
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
end; // procedure TN_CMCaptDev19Form.TimerStatusTimer

//************************************* TN_CMCaptDev19Form.TimerWindowTimer ***
// Check if native viewer is open
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev19Form.TimerWindowTimer( Sender: TObject );
begin
  inherited;

  if not ProcessExists(extractfilename(CMOFPProfile.CMDPStrPar1)) then // close
  begin
    Close();

  end;

end; // procedure TN_CMCaptDev19Form.TimerWindowTimer

//************************************* TN_CMCaptDev19Form.CMOFCaptureSlide ***
// Importing Image
//
//     Parameters
// Image  - Filename
// Result - 0 if correct
//
function TN_CMCaptDev19Form.CMOFCaptureSlide2D( Image: string ): Integer;
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
end; // end of TN_CMCaptDev19Form.CMOFCaptureSlide2D

//************************************* TN_CMCaptDev19Form.CMOFCaptureSlide ***
// Importing Image
//
//     Parameters
// Image  - Filename
// Result - 0 if correct
//
function TN_CMCaptDev19Form.CMOFCaptureSlide( Image: string ): Integer;
var
  Slide3D:      TN_UDCMSlide;
  InfoFName:    string;
  CurSlidesNum, ResCode : Integer;
  AddViewsInfo: string;
begin
  Screen.Cursor := crHourglass;

  Slide3D := K_CMSlideCreateForImg3DObject();
  Slide3D.CreateThumbnail(); // create TMP  thubmnail
  K_CMEDAccess.EDAAddSlide( Slide3D );

  with Slide3D, P()^ do
  begin
    N_CM_MainForm.CMMSetUIEnabled( FALSE );
    N_CM_MainForm.CMMCurFMainForm.Hide();

    ExcludeTrailingPathDelimiter( Image );

    CMOFStatus := 6;
    // ***** making a form invisible
    Self.AlphaBlend      := True;
    Self.AlphaBlendValue := 0;

    ResCode := K_CMImg3DCall( CMSDB.MediaFExt, Image );

    if K_CMD4WAppFinState then
    begin
      N_Dump1Str( '3D> !!! CMSuite is terminated' );
      Application.Terminate;
      Result := -1;
      Exit;
    end;

    N_CM_MainForm.CMMCurFMainFormSkipOnShow := TRUE;
    N_CM_MainForm.CMMCurFMainForm.Show();
    N_CM_MainForm.CMMSetUIEnabled( TRUE );

    if ResCode = 0 then
    begin
      // Rebuild Thumbnail
      CMOFStatus := 7;
      CreateThumbnail(); // create TMP  thubmnail

      CMOFStatus := 8;
      K_CMImg3DAttrsInit( P() );

      CMSSourceDescr := ExtractFileName(ExcludeTrailingPathDelimiter(Image));

      N_Dump1Str( 'After extracting filename = ' + CMSSourceDescr );

      CMOFStatus := 9;

      // Rebuild 3D slide ECache
      CMSlideECSFlags := [cmssfAttribsChanged];
      K_CMEDAccess.EDASaveSlideToECache( Slide3D );

      // Save 3D object
      K_CMEDAccess.EDASaveSlidesArray( @Slide3D, 1 );

      // Import and Save 2D views
      InfoFName := TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImg3DPath( Slide3D ) +
                                 K_CMSlideGetImg3DFolderName( Slide3D.ObjName );
      CurSlidesNum := N_CM_MainForm.CMMImg3DViewsImportAndShowProgress( Slide3D.ObjName, InfoFName );
      K_CMEDAccess.EDASetPatientSlidesUpdateFlag();

      N_CM_MainForm.CMMFRebuildVisSlides();
      N_CM_MainForm.CMMFDisableActions( nil );

      AddViewsInfo := K_CML1Form.LLLImg3D1.Caption; // ' 3D object is imported'
      if CurSlidesNum > 0 then
        AddViewsInfo := format( K_CML1Form.LLLImg3D2.Caption,
                                 //  '3D object and %s',
                         [format( K_CML1Form.LLLImg3D3.Caption,
          //                ' %d 3D views are imported'
                                 [CurSlidesNum] )] );
      N_CM_MainForm.CMMFShowStringByTimer( AddViewsInfo );
    end   // if ResCode = 0 then
    else
    begin // if ResCode <> 0 then
      // Remove New Slide
      with TK_CMEDDBAccess(K_CMEDAccess) do
      begin
        CurSlidesList.Delete(K_CMEDAccess.CurSlidesList.Count - 1);
        EDAClearSlideECache( Slide3D );
      end;

      Slide3D.UDDelete();
    end;
  end; // with Slide3D, P()^ do

  Screen.Cursor := crDefault;
  Result := 0;
end; // end of TN_CMCaptDev19Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev19Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev19Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev19Form.CurStateToMemIni

//************************************* TN_CMCaptDev19Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev19Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev19Form.MemIniToCurState

{$ELSE} //************** no code in Delphi 7
implementation
{$ENDIF VER150} //****** no code in Delphi 7

end.


