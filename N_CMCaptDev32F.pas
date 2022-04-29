unit N_CMCaptDev32F;

interface

{$IFNDEF VER150} //***** not Delphi 7

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0, N_CMCaptDev0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, xmldom,
  XMLIntf, msxml, msxmldom, XMLDoc, OleCtrls, SHDocVw, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL;

type TN_CMCaptDev32Form = class( TN_BaseForm )
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
    bnCapture: TButton;
    Button5: TButton;
    TimerCase: TTimer;

    //******************  TN_CMCaptDev32Form class handlers  ******************

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
    procedure FormCloseQuery   ( Sender: TObject; var CanClose: Boolean );
    procedure bnSetupClick     ( Sender: TObject );
    procedure FormCreate       ( Sender: TObject );
    procedure FormPaint        ( Sender: TObject );
    procedure TimerImageTimer  ( Sender: TObject );
    procedure bnStopClick      ( Sender: TObject );
    procedure TimerStatusTimer ( Sender: TObject );
    procedure bnCaptureClick   ( Sender: TObject );
    procedure Button5Click     ( Sender: TObject ); // temporary, needs for the future implementation
    procedure TimerCaseTimer   ( Sender: TObject );

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

    CMOFLogin, CMOFPassword:      string;
    CMOFStatus, CMOFStatusPrev:   Integer;
    CMOFClientIDNum:              string;
    CMOFCaseNum, CMOFCaseNumPrev: string;
    CMOFCaseCreated, CMOFCaseListCreated: Boolean;

    CMOFCaseList: TStringList;

    CMOFThisForm: TN_CMCaptDev32Form;    // Pointer to this form

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide ( Image: string ): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMCaptDev32Form = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

var
  PelsPerInch: integer; // pixels per inch received from a driver

implementation

uses
  Math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev32,
  N_CMCaptDev32aF, TlHelp32, K_CM1, K_CML1F, N_CMResF, ShellAPI, IniFiles,
  ComObj, MSHTML, ActiveX, K_CLib, K_RImage
;
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

//**********************  TN_CMCaptDev32Form class handlers  ******************

//********************************************* TN_CMCaptDev32Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev32Form.FormShow( Sender: TObject );
begin
  N_Dump1Str( 'Trios Start FormShow' );

  Caption := CMOFPProfile^.CMDPCaption + ' X-Ray Capture';
  tbRotateImage.Images := N_CM_MainForm.CMMCurBigIcons;
  CMOFDrawSlideObj := TN_CMDrawSlideObj.Create(); // used in jn CMOFDrawThumb for Drawing Thumbnails
  CMOFThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, CMOFGetThumbSize );

  CMOFStatus := 0; // beginning status

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

  CMOFCaseCreated := False;
  CMOFCaseListCreated := False;
  CMOFCaseList := TStringList.Create(); // empty

  CMOFStatus := 0;

  //***** get login/password
  CMOFLogin := Copy( CMOFPProfile.CMDPStrPar2, 0,
                                  Pos( '/~/',CMOFPProfile.CMDPStrPar2) - 1 );
  CMOFPassword := Copy( CMOFPProfile.CMDPStrPar2,
                                  Pos( '/~/',CMOFPProfile.CMDPStrPar2 ) + 3,
                                  Length(CMOFPProfile.CMDPStrPar2) );

  if CMOFLogin <> '' then
  begin
    bnCapture.OnClick(Nil);
  end;

  N_Dump1Str( 'Trios End FormShow' );
end; // procedure TN_CMCaptDev32Form.FormShow

//******************************************** TN_CMCaptDev32Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev32Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  N_Dump2Str( 'CMOther32Form.FormClose' );
  Inherited;
end; // procedure TN_CMCaptDev32Form.FormClose

//*************************************** TN_CMCaptDev32Form.FormCloseQuery ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// CanClose
//
// OnClose Self handler
//
procedure TN_CMCaptDev32Form.FormCloseQuery(Sender: TObject;
                                                         var CanClose: Boolean);
begin
  inherited;
end; // TN_CMCaptDev32Form.FormCloseQuery

procedure TN_CMCaptDev32Form.FormCreate(Sender: TObject);
begin
  inherited;
end;

//****************************************** TN_CMCaptDev32Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev32Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev32Form.FormKeyDown

//******************************************** TN_CMCaptDev32Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev32Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev32Form.FormKeyUp

procedure TN_CMCaptDev32Form.FormPaint(Sender: TObject);
begin
  inherited;
end;

//************************************* TN_CMCaptDev32Form.SlidePanelResize ***
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev32Form.SlidePanelResize( Sender: TObject );
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev32Form.SlidePanelResize

//**************************************** TN_CMCaptDev32Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev32Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev32Form.tbLeft90Click

//*************************************** TN_CMCaptDev32Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev32Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev32Form.UpDown1Click

//************************************** TN_CMCaptDev32Form.TimerImageTimer ***
// Is CMS 3D enabled check, not using anymore
//
//     Parameters
// Sender - Event Sender
//
//procedure TN_CMCaptDev32Form.Timer3DEnabledTimer( Sender: TObject );
//begin
// inherited;
// if not (N_CMResForm.aMediaImport3D.Visible) then
//  begin
//    Timer3DEnabled.Enabled := False;
//    K_CMShowMessageDlg( '3d import is unaccessible',
//                                              mtInformation, [], FALSE, '', 5 );
    //Close();
//  end;
//end; // procedure TN_CMCaptDev32Form.Timer3DEnabledTimer

//*************************************** TN_CMCaptDev32Form.TimerCaseTimer ***
// Waiting for a case
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev32Form.TimerCaseTimer( Sender: TObject );
var
  mStream:    TStream;
  idHttpTemp: TIdHTTP;

  UserID   :string;
  Password :string;

  IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;

  DOB:       TDateTime;
  DateBirth: string;
  Fmt:       TFormatSettings;

  xml: IXMLDocument;
  LNodeElement, LNodeElementTemp, LNodeElementFinal: IXMLNode;

  RequestStr: string;
  FName :     string;
  RetCode :   Integer;
  ErrStr :    string;
  DIB: TN_DIBObj;

function GetName(): String;
var
  ComputerName: Array [0 .. 256] of char;
  Size: DWORD;
begin
  Size := 256;
  GetComputerName(ComputerName, Size);
  Result := ComputerName;
end;

begin
  inherited;
  CMOFStatus := 3;

  //if not CMOFCaseCreated then // decided to make multiple slides possible
  //begin

    idHttpTemp := TIdHTTP.Create(nil);

    IdSSLIOHandlerSocketOpenSSL1 := TIdSSLIOHandlerSocketOpenSSL.Create(Nil);
    idHttpTemp.IOHandler := IdSSLIOHandlerSocketOpenSSL1;

    N_Dump1Str( 'Login =' + CMOFLogin + ', Pass =' + CMOFPassword );
    UserID   := CMOFLogin;
    Password := CMOFPassword;

    idHttpTemp.Request.ContentType := 'text/xml';
    idHttpTemp.Request.Charset := 'utf-8';

    idHttpTemp.Request.Username := UserID;

    idHttpTemp.Request.BasicAuthentication := True;
    idHttpTemp.Request.Password := Password;
    idHttpTemp.AllowCookies     := true;
    idHttpTemp.HandleRedirects  := True;

    mStream := TMemoryStream.Create();
    try

    N_Dump1Str( 'Before date' );
    fmt.ShortDateFormat := 'dd/mm/yyyy';
    fmt.DateSeparator  := '/';
    fmt.LongTimeFormat := 'hh:nn';
    fmt.TimeSeparator  := ':';

    if K_CMGetPatientDetails( -1, '(#PatientDOB#)' ) <> '' then // if no error in a date
    begin
      DOB := StrToDateTime(K_CMGetPatientDetails( -1, '(#PatientDOB#)' ) +
                                                                ' 00:00', Fmt );
    end
    else
    begin
      DOB := StrToDateTime( '01/01/1980 00:00', Fmt ); // default
    end;
    DateTimeToString( DateBirth, 'yyyy-mm-dd', DOB);

    N_Dump1Str( 'After date' );

    N_Dump1Str('Before request');

    // request itself
    RequestStr := 'https://' + CMOFPProfile.CMDPStrPar1 + //GetName() +
               ':5484/DentalDesktop/WebService/GetCasesInformation?FirstName=' +
              K_CMGetPatientDetails( -1, '(#PatientFirstName#)' )+'&LastName=' +
              K_CMGetPatientDetails( -1, '(#PatientSurname#)' ) + '';


    idHttpTemp.Request.Method := 'Get';
    N_Dump1Str( 'Before Get' );

    //mStream :=  TFileStream.Create(K_ExpandFileName( '(#TmpFiles#)' ) +
    //                                              'trios_answer.xml', fmCreate);

    // first get patient request
    idHttpTemp.Get( RequestStr, mStream );

    // first request will login, so we have to do it all over again
    mStream.Free;
    //mStream :=  TFileStream.Create( K_ExpandFileName( '(#TmpFiles#)' ) +
    //                                              'trios_answer.xml', fmCreate);
    mStream := TMemoryStream.Create();
    idHttpTemp.Get( RequestStr, mStream );

    N_Dump1Str( 'After Get' );

    if ( CMOFCaseListCreated = False ) then // first time
    begin
      CMOFCaseListCreated := True; // stated right away, so if there's exception (no xml), still be counted

      xml := TXMLDocument.Create(Nil);
      N_Dump1Str( 'Before XML load from stream' );
      //xml.LoadFromFile( K_ExpandFileName( '(#TmpFiles#)' ) + 'trios_answer.xml' );
      xml.LoadFromStream(mStream);
      N_Dump1Str( 'Before XML savetofile' );

      // find a specific node
      LNodeElement := xml.ChildNodes.FindNode( 'ArrayOfCaseInfo' );

      LNodeElementTemp := LNodeElement.ChildNodes.FindNode('CaseInfo');
      CMOFCaseNum := LNodeElementTemp.ChildNodes['CaseId'].Text; // case number needed
      //CMOFCaseList.Add( CMOFCaseNum );

      // ***** 'till the end, so we will find the node of the last case
      while ( LNodeElementTemp <> nil ) do // 'till end
      begin
        CMOFCaseList.Add( CMOFCaseNum );
        N_Dump1Str( 'StringList, CaseID found for the first time = ' + CMOFCaseNum );//+ ', Prev - ' + CMOFCaseNumPrev );

        LNodeElementTemp := LNodeElement.ChildNodes.FindSibling(LNodeElementTemp, 1);
        if LNodeElementTemp <> nil then
          LNodeElementFinal := LNodeElementTemp;

        if (LNodeElementFinal <> nil) then
          CMOFCaseNum := LNodeElementFinal.ChildNodes['CaseId'].Text; // case number needed

        {// ***** image number search
        if (LNodeElementFinal <> nil) then
          LNodeElement := LNodeElementFinal.ChildNodes.FindNode('AttachedImages');

        if (LNodeElement <> nil) then
          LNodeElement := LNodeElement.ChildNodes.FindNode('AttachedImageInfo');

        if (LNodeElement <> nil) then
          ImageNum := LNodeElement.ChildNodes['Id'].Text; // image number in the case, not used yet, will be needed in the future
        }

      end; // while cases left
    end
    else // checking cases
    begin

      xml := TXMLDocument.Create(Nil);
      N_Dump1Str( 'Before XML load from stream' );
      //xml.LoadFromFile( K_ExpandFileName( '(#TmpFiles#)' ) + 'trios_answer.xml' );
      xml.LoadFromStream(mStream);
      N_Dump1Str( 'Before XML savetofile' );

      // find a specific node
      LNodeElement := xml.ChildNodes.FindNode( 'ArrayOfCaseInfo' );

      LNodeElementTemp := LNodeElement.ChildNodes.FindNode('CaseInfo');

      CMOFCaseNum := LNodeElementTemp.ChildNodes['CaseId'].Text; // case number needed

      // ***** 'till the end, so we will find the node of the last case
      while ( LNodeElementTemp <> nil ) do //and ( not CMOFCaseCreated ) do // cases are still left
      begin
        if CMOFCaseList.IndexOf( CMOFCaseNum ) = -1 then // found
        begin
          N_Dump1Str( 'New CaseID found = ' + CMOFCaseNum );//+ ', Prev - ' + CMOFCaseNumPrev );
          CMOFStatus := 5;

          CMOFCaseList.Add( CMOFCaseNum );
          N_Dump1Str( 'Case found!' );

          FName := N_MemIniToString( 'CMS_Main','Thumb3ShapeFName', '' );
          DIB := TN_DIBObj.Create();

          RetCode := K_LoadDIBFromVFileByRI( K_RIObj, FName, DIB );
          if RetCode = 0 then N_Dump1Str( 'RetCode = 0' );
          case RetCode of
          1: ErrStr := 'is absent';
          2: ErrStr := 'has not proper format';
          end;

          if (RetCode = 1) or (RetCode = 2) then
            N_Dump1Str( format( ' 3Shape Thumbnail file  "%s"  error >> %s', [FName, ErrStr] ) );

          K_CMDev3DCreateSlide( CMOFPProfile, CMOFCaseNum, DIB, 0, 0, 0, 8 );
          //CMOFCaseCreated := True;
        end; // found

        LNodeElementTemp := LNodeElement.ChildNodes.FindSibling(LNodeElementTemp, 1);
        if LNodeElementTemp <> nil then
          LNodeElementFinal := LNodeElementTemp;

        if (LNodeElementFinal <> nil) then
          CMOFCaseNum := LNodeElementFinal.ChildNodes['CaseId'].Text; // case number needed
        N_Dump1Str( 'Checking at the moment = ' + CMOFCaseNum );
        {// ***** image number search, for future's sake
        if (LNodeElementFinal <> nil) then
          LNodeElement := LNodeElementFinal.ChildNodes.FindNode('AttachedImages');

        if (LNodeElement <> nil) then
          LNodeElement := LNodeElement.ChildNodes.FindNode('AttachedImageInfo');

        if (LNodeElement <> nil) then
          ImageNum := LNodeElement.ChildNodes['Id'].Text; // image number in the case, not used yet, will be needed in the future
        }
        // ***** new case found

      end; // while there's cases left
    end; // checking cases

    except

    on E: Exception do
    begin
      N_Dump1Str( 'Exception cathed, ' + E.Message );
      CMOFStatus := 0;
    end;

    end; // try

    idHttpTemp.Free;
    mStream.Free;
  //end // if not CMOFCaseCreated then
  //else
  //  Close; // not closing after capture anymore
end; // procedure TN_CMCaptDev32Form.TimerCaseTimer

//************************************** TN_CMCaptDev32Form.TimerImageTimer ***
// Waiting for an image
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev32Form.TimerImageTimer( Sender: TObject );
begin
  inherited;
  TimerImage.Enabled := False;

  // not used yet

  TimerImage.Enabled := True;
end; // procedure TN_CMCaptDev32Form.TimerImageTimer(Sender: TObject);

//******************************************* TN_CMCaptDev32Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev32Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev32Form.tb180Click

//*************************************** TN_CMCaptDev32Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev32Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev32Form.tbFlipHorClick


//**********************  TN_CMCaptDev32Form class public methods  ************

//**************************************** TN_CMCaptDev32Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev32Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev32Form.CMOFDrawThumb

//************************************* TN_CMCaptDev32Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev32Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
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
end; // procedure TN_CMCaptDev32Form.CMOFGetThumbSize

//*************************************** TN_CMCaptDev32Form.bnCaptureClick ***
// Capture
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev32Form.bnCaptureClick(Sender: TObject);
var
  mStream:    TStream;
  idHttpTemp: TIdHTTP;
  lReply:   string;
  UserID:   string;
  Password: string;
  IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
  lParamList1: TStringList;
  SS: TStringStream;
  DOB:      TDateTime;
  DateBirth: string;
  Fmt:      TFormatSettings;
  xml:      IXMLDocument;
  LNodeElement: IXMLNode;
  FileName, TempStr, RequestStr: string;
  XmlStr:      TStringList;
  ClientIdNum: string;

function GetName(): String;
var
  ComputerName: Array [0 .. 256] of char;
  Size: DWORD;
begin
  Size := 256;
  GetComputerName(ComputerName, Size);
  Result := ComputerName;
end;

begin
  //***** get login/password
  CMOFLogin := Copy( CMOFPProfile.CMDPStrPar2, 0,
                                  Pos( '/~/',CMOFPProfile.CMDPStrPar2) - 1 );
  CMOFPassword := Copy( CMOFPProfile.CMDPStrPar2,
                                  Pos( '/~/',CMOFPProfile.CMDPStrPar2 ) + 3,
                                  Length(CMOFPProfile.CMDPStrPar2) );
  N_Dump1Str( 'Login =' + CMOFLogin + ', Pass =' + CMOFPassword );

  mStream := TStringStream.Create();
  SS:=TStringStream.Create('');

  idHttpTemp := TIdHTTP.Create(nil);
  try

    IdSSLIOHandlerSocketOpenSSL1 := TIdSSLIOHandlerSocketOpenSSL.Create(Nil);
    idHttpTemp.IOHandler := IdSSLIOHandlerSocketOpenSSL1;

    UserID   := CMOFLogin;
    Password := CMOFPassword;

    idHttpTemp.Request.ContentType := 'text/xml';
    idHttpTemp.Request.Charset := 'utf-8';

    idHttpTemp.Request.BasicAuthentication := True;
    idHttpTemp.Request.Username := UserID;
    idHttpTemp.Request.Password := Password;
    idHttpTemp.AllowCookies     := true;
    idHttpTemp.HandleRedirects  := True;

    RequestStr := 'https://' + CMOFPProfile.CMDPStrPar1 + //GetName() +
                        ':5484/DentalDesktop/WebService/GetAvailableClientList';

    FileName := N_CMV_GetWrkDir();
    SS := TStringStream.Create();
    idHttpTemp.Get( RequestStr, SS );
    SS.Clear;
    idHttpTemp.Get( RequestStr, SS );

    xml := TXMLDocument.Create( Nil );
    TempStr := SS.DataString;
    TempStr  := StringReplace( TempStr, '- ', '  ', [rfReplaceAll, rfIgnoreCase] );

    XmlStr := TStringList.Create();
    XmlStr.Add( TempStr );

    XmlStr.SaveToFile( FileName + '\Trios.xml' );
    xml.LoadFromFile( FileName + '\Trios.xml' );
    N_Dump1Str('Search for a node, ClientID');

    // Find a specific node
    LNodeElement := xml.ChildNodes.FindNode( 'ArrayOfClientInfo' );

    if ( LNodeElement <> nil ) then
    LNodeElement := LNodeElement.ChildNodes.FindNode( 'ClientInfo' );

    if ( LNodeElement <> nil ) then
    ClientIDNum := LNodeElement.ChildNodes['ClientId'].Text;

    N_Dump1Str( 'ClientID is ' + ClientIdNum );

    // ***** xml with patient, to create case
    lParamList1 := TStringList.Create;

    lParamList1.Add('<ProcessPatientRequest>');
    lParamList1.Add('<ClientId>' + ClientIdNum + '</ClientId>');
    lParamList1.Add('<Patient>');

    N_Dump1Str('Before date');

    fmt.ShortDateFormat := 'dd/mm/yyyy';
    fmt.DateSeparator  := '/';
    fmt.LongTimeFormat := 'hh:nn';
    fmt.TimeSeparator  := ':';

    if K_CMGetPatientDetails( -1, '(#PatientDOB#)' ) <> '' then // if no error in a date
    begin
      DOB := StrToDateTime( K_CMGetPatientDetails( -1, '(#PatientDOB#)' ) +
                                                                ' 00:00', Fmt );
    end
    else
    begin
      DOB := StrToDateTime( '01/01/1980 00:00', Fmt ); // default
    end;
    DateTimeToString( DateBirth, 'yyyy-mm-dd', DOB );

    N_Dump1Str('After date');

    lParamList1.Add( '<DateOfBirth>' + DateBirth + 'T00:00:00</DateOfBirth>' );
    lParamList1.Add( '<FirstName>' + K_CMGetPatientDetails( -1, '(#PatientFirstName#)' ) + '</FirstName>' );
    lParamList1.Add( '<LastName>' + K_CMGetPatientDetails( -1, '(#PatientSurname#)' ) + '</LastName>' );
    lParamList1.Add( '<PatientId>' + K_CMGetPatientDetails( -1, '(#PatientCardNumber#)' ) + '</PatientId>' );
    lParamList1.Add( '</Patient>' );
    lParamList1.Add( '<RequestType>CreateCase</RequestType>' );
    lParamList1.Add( '</ProcessPatientRequest>' );
    mStream := TStringStream.Create( lParamList1.Text, TEncoding.UTF8 );

    //try

    N_Dump1Str( 'Before request' );

    // request itself
    RequestStr := 'https://' + CMOFPProfile.CMDPStrPar1 + //GetName() +
                         ':5484/DentalDesktop/WebService/RequestProcessPatient';

    idHttpTemp.Request.Method := 'POST';
    N_Dump1Str( 'Before Post' );

    CMOFStatus := 2;

    // send post request
    lReply := idHttpTemp.Post( RequestStr, mStream );

    TimerCase.Enabled := True;

    N_Dump1Str( 'After Post' );

    except

    on E: Exception do
    begin
      N_Dump1Str( 'Exception cathed, ' + E.Message );
      //K_CMShowMessageDlg( 'Exception: ' + E.Message, mtError );
      CMOFStatus := 0;
      bnStop.OnClick( Nil );
    end; // on E: Exception do
  end;

  idHttpTemp.Free;

  //finally

  mStream.Free;
  FreeAndNil(SS);

  //end; // try, finally
end; // procedure TN_CMCaptDev32Form.bnCaptureClick

//***************************************** TN_CMCaptDev32Form.bnSetupClick ***
// Capture
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev32Form.bnSetupClick( Sender: TObject );
var
  Form: TN_CMCaptDev32aForm; // Settings form
begin
  inherited;
  N_Dump1Str( 'Trios >> CDSSettingsDlg begin' );

  Form := TN_CMCaptDev32aForm.Create( Application );
  // create setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  //Form.CMOFPDevProfile := CMOFPProfile; // link form variable to profile
  Form.Caption := CMOFPProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := N_CMCDServObj32.PProfile;
  Form.ShowModal(); // Show a setup form

  N_Dump1Str( 'Trios >> CDSSettingsDlg end' );
end; // procedure TN_CMCaptDev32Form.bnSetupClick

//****************************************** TN_CMCaptDev32Form.bnStopClick ***
// Capture Stop
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev32Form.bnStopClick( Sender: TObject );
begin
  inherited;
  CMOFStatus := 0;

  CMOFCaseNumPrev := '';

  bnCapture.Visible     := True;
  bnStop.Visible        := False;
  ProgressBar1.Position := 0;
  TimerCase.Enabled     := False;
end; // procedure TN_CMCaptDev32Form.bnStopClick

// temporary
procedure TN_CMCaptDev32Form.Button5Click( Sender: TObject );
var
  i: Integer;
  CapturedDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
  s:string;
  PByteTemp: TBytes;
  function TextFileToString(const FName: TFileName): string;
var
  St: TStringList;
begin
  St:= TStringList.Create;
  try
    St.LoadFromFile(FName);
    Result:= St.Text
  finally
    St.Free
    end
end;
begin


Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
    N_Dump1Str( Format('Slida Start CMOFCaptureSlide %d', [CMOFNumCaptured]));

   CapturedDIB := TN_DIBObj.Create();
  CapturedDIB.PrepEmptyDIBObj( 1276,
                         796, pfCustom, -1, epfGray8, 8);


  s:= TextFileToString('D:\trios');

  PByteTemp := TEncoding.UTF8.GetBytes(s);
  ShowMessage(IntToStr(Length(PByteTemp)));
  for i := 0 to 90000 do//Length(PByteTemp) - 1 do
    Move(PByteTemp[i], (CapturedDIB.PRasterBytes+i)^, sizeof(Byte));
 //  CopyMemory(@s[1], CapturedDIB.PRasterBytes, Length(s)*sizeof(char));
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

    N_Dump1Str(Format('Slida Fin CMOFCaptureSlide %d', [CMOFNumCaptured]));
end; // procedure TN_CMCaptDev32Form.Button5Click

//************************************* TN_CMCaptDev32Form.TimerStatusTimer ***
// Changing status
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev32Form.TimerStatusTimer( Sender: TObject );
begin
  inherited;
  if CMOFStatus <> CMOFStatusPrev then // new status
  begin
    case CMOFStatus of
    0: begin
      StatusLabel.Caption := 'Disconnected';
      StatusLabel.Font.Color  := clRed;
      StatusShape.Pen.Color   := clRed;
      StatusShape.Brush.Color := clRed;
    end;
    1: begin
      StatusLabel.Caption := 'Ready';
      StatusLabel.Font.Color  := clGreen;
      StatusShape.Pen.Color   := clGreen;
      StatusShape.Brush.Color := clGreen;
    end;
    2: begin
      StatusLabel.Caption := 'Sending Request';
      StatusLabel.Font.Color  := clBlue;
      StatusShape.Pen.Color   := clBlue;
      StatusShape.Brush.Color := clBlue;
    end;
    3: begin
      StatusLabel.Caption := 'Waiting for Case';
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
end;// procedure TN_CMCaptDev32Form.TimerStatusTimer

//************************************* TN_CMCaptDev32Form.CMOFCaptureSlide ***
// Importing Image
//
//     Parameters
// Image  - Filename
// Result - 0 if correct
//
function TN_CMCaptDev32Form.CMOFCaptureSlide( Image: string ): Integer;
var
  Slide3D:      TN_UDCMSlide;
  InfoFName:    string;
  CurSlidesNum, ResCode : Integer;
  AddViewsInfo: string;
begin
  if DirectoryExists(Image) then
  begin
    Screen.Cursor := crHourglass;
    CMOFStatus := 6;

    Slide3D := K_CMSlideCreateForImg3DObject();
    Slide3D.CreateThumbnail(); // create TMP  thubmnail
    K_CMEDAccess.EDAAddSlide( Slide3D );

    with Slide3D, P()^ do
    begin
      N_CM_MainForm.CMMSetUIEnabled( FALSE );
      N_CM_MainForm.CMMCurFMainForm.Hide();

      ExcludeTrailingPathDelimiter( Image );

      CMOFStatus := 7;
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
  end;

  Result := 0;
end; // end of TN_CMCaptDev32Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev32Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev32Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev32Form.CurStateToMemIni

//************************************* TN_CMCaptDev32Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev32Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev32Form.MemIniToCurState

{$ELSE} //************** no code in Delphi 7
implementation
{$ENDIF VER150} //****** no code in Delphi 7

end.


