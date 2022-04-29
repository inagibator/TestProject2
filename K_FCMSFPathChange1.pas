unit K_FCMSFPathChange1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls, ActnList;

type
  TK_FormCMSFPathChange1 = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    BtApply: TButton;

    ActionList1: TActionList;
    SetPath: TAction;
      ApplyPath: TAction;

    Timer1: TTimer;

    GBCurLocation: TGroupBox;
      LEdCurFPath: TLabeledEdit;
      LbCurFilesAttrs: TLabel;

    GBNewLocation: TGroupBox;
      LEdNewPath: TLabeledEdit;
    BtPathSelect_1: TButton;
    LbNewFilesAttrs: TLabel;

    procedure FormShow(Sender: TObject);
    procedure SetPathExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure ApplyPathExecute(Sender: TObject);
//    procedure ChBNewSplitFlagClick(Sender: TObject);
    procedure BtPathSelect_1Click(Sender: TObject);
  private
    { Private declarations }
    CurFilesPath  : string;
    CurFilesCount : Integer;
    CurFilesSize  : Int64;
    SaveCursor : TCursor;
    CurDAFlag : Boolean;
    OtherInstancesLaunchFlag : Boolean;
    FChangePathStage: Integer; // Current Change files path Stage if Server Migration Mode


    function  GetAutoVideoRootFolder() : string;
    function  GetAuto3DImgRootFolder() : string;
    procedure PrepChangePathContext();
    function  SetChangePathContext( ASkipPrepSlidesMovingContext : Boolean ) : Boolean;
    procedure DisableControls();
    function  DoApplyPath() : Boolean;
    procedure ClearCurCMSContext();
    procedure SetProperCaption();
  public
    { Public declarations }
  end;

var
  K_FormCMSFPathChange1: TK_FormCMSFPathChange1;

implementation

{$R *.dfm}
{$WARN UNIT_PLATFORM	 OFF}
uses FileCtrl,
     N_CMMain5F, N_Types,
     K_CM0, K_CLib0, K_CML1F;
{$WARN UNIT_PLATFORM	 ON}

//************************************ TK_FormCMSFPathChange1.FormShow ***
// Self initialization
//
//     Parameters
// Sender    - Event Sender
//
// OnShow Self handler
//
procedure TK_FormCMSFPathChange1.FormShow(Sender: TObject);
begin
//
  PrepChangePathContext();
  K_FormCMSFPathChange1 := Self;
  SaveCursor := Screen.Cursor;
  with TK_CMEDDBAccess(K_CMEDAccess).SlidesCRFC do
    FChangePathStage := ChangePathStage;
  SetProperCaption();
end; // procedure TK_FormCMSFPathChange1.FormShow

//************************************ TK_FormCMSFPathChange1.FormCloseQuery ***
// Form Close Query event handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMSFPathChange1.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
      if (SlidesCRFC.RootFolder <> '') then
      begin
        CanClose := mrYes = K_CMShowMessageDlg( K_CML1Form.LLLPathChange1.Caption,
//            '              Are you sure you want to break the operation?'#13#10 +
//            '(Working with Images and Video will be impossible until this operation is properly finished)',
            mtConfirmation );
        if CanClose then
        begin // Precaution
          EDAClearFilesMovingInfo();
          EDAClearSlidesCRFC();
        end;
      end; // if (SlidesCRFC.RootFolder <> '') then
    if not CanClose then Exit;
  end;
  K_FormCMSFPathChange1 := nil;

  ClearCurCMSContext();
end; // procedure TK_FormCMSFPathChange1.FormCloseQuery

//*********************************** TK_FormCMSFPathChange1.SetPathExecute ***
// Set Files Path Action
//
//     Parameters
// Sender    - Event Sender
//
// MoveFiles Action handler
//
procedure TK_FormCMSFPathChange1.SetPathExecute(Sender: TObject);
begin
//
  if LEdNewPath.Text = '' then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLPathChange2.Caption,
//                        'New folder is not set!',
                        mtWarning );
    Exit;
  end;

  with TK_CMEDDBAccess(K_CMEDAccess), SlidesCRFC do
  begin

    if (FChangePathStage = 0) and SameText( IncludeTrailingPathDelimiter(LEdNewPath.Text), CurFilesPath ) then
    begin
      K_CMShowMessageDlg( K_CML1Form.LLLPathChange3.Caption,
//                          'New folder is the same as current folder!',
                           mtWarning );
      Exit;
    end;

    if not SetChangePathContext( TRUE ) then Exit;

    EDASetFilesPathInfo( );
    if FChangePathStage > 0 then
    begin
      Inc(FChangePathStage);
      if FChangePathStage = 2 then
      begin
        // Apply Video Files
        MediaFCopy := TRUE;
        Img3DFCopy := FALSE;
        MovingFSDDescr := 0;
        ChangePathStage := FChangePathStage;

        SetProperCaption();
        PrepChangePathContext();
        LEdNewPath.Text := GetAutoVideoRootFolder();
        if not SetChangePathContext( TRUE ) then Exit;
        EDASetFilesPathInfo( );
        Inc(FChangePathStage);
      end;

      if FChangePathStage = 3 then
      begin
        // Apply 3D Image Files
        MediaFCopy := FALSE;
        Img3DFCopy := TRUE;
        ChangePathStage := 3;
        MovingFSDDescr := 0;
        ChangePathStage := FChangePathStage;

        SetProperCaption();
        PrepChangePathContext();
        LEdNewPath.Text := GetAuto3DImgRootFolder();
        if not SetChangePathContext( TRUE ) then Exit; // Check Folder Errors
        EDASetFilesPathInfo( );
      end;
      FChangePathStage := 0;
    end;
    Close();
  end; // with TK_CMEDDBAccess(K_CMEDAccess), SlidesCRFC do
end; // procedure TK_FormCMSFPathChange1.SetPathExecute


//************************************ TK_FormCMSFPathChange1.ApplyPathExecute ***
// Apply Files New Location Path Action
//
//     Parameters
// Sender    - Event Sender
//
// CancelMoving Action handler
//
procedure TK_FormCMSFPathChange1.ApplyPathExecute(Sender: TObject);
begin
  if LEdNewPath.Text = '' then begin
    K_CMShowMessageDlg( K_CML1Form.LLLPathChange2.Caption,
//                        'New folder is not set!',
                        mtWarning );
    Exit;
  end;

  with TK_CMEDDBAccess(K_CMEDAccess) do begin


    if (FChangePathStage = 0) and SameText( IncludeTrailingPathDelimiter(LEdNewPath.Text), CurFilesPath ) then
    begin
      if mrYes <> K_CMShowMessageDlg( K_CML1Form.LLLPathChange3.Caption + #13#10 +
                                      '                   ' + K_CML1Form.LLLProceed.Caption,
//                      'New folder is the same as current folder!'#13#10 +
//                                      '                   Continue?',
                                      mtConfirmation ) then
        Exit;

    end;
  end;
  Timer1.Enabled := TRUE;

end; // procedure TK_FormCMSFPathChange1.ApplyPathExecute

//************************************ TK_FormCMSFPathChange1.Timer1Timer ***
// Timer event handler
//
//     Parameters
// Sender    - Event Sender
//
// OnTimer handler
//
procedure TK_FormCMSFPathChange1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := FALSE;
  if not DoApplyPath() then Exit;

  with TK_CMEDDBAccess(K_CMEDAccess), SlidesCRFC do
  begin
    if FChangePathStage > 0 then
    begin
      Inc(FChangePathStage);
      if FChangePathStage = 2 then
      begin
        // Apply Video Files
        MediaFCopy := TRUE;
        Img3DFCopy := FALSE;
        MovingFSDDescr := 0;
        ChangePathStage := FChangePathStage;

        SetProperCaption();
        PrepChangePathContext();
        LEdNewPath.Text := GetAutoVideoRootFolder();

        if not DoApplyPath() then Exit;
        Inc(FChangePathStage);
      end;

      if FChangePathStage = 3 then
      begin
        // Apply 3D Image Files
        MediaFCopy := FALSE;
        Img3DFCopy := TRUE;
        MovingFSDDescr := 0;
        ChangePathStage := FChangePathStage;

        SetProperCaption();
        PrepChangePathContext();
        LEdNewPath.Text := GetAuto3DImgRootFolder();
        if not DoApplyPath() then Exit;
      end;
      FChangePathStage := 0;
    end;
    Close();
  end; //  with TK_CMEDDBAccess(K_CMEDAccess), SlidesCRFC do
end; // procedure TK_FormCMSFPathChange1.Timer1Timer

function TK_FormCMSFPathChange1.GetAutoVideoRootFolder() : string;
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
   Result := ExtractFilePath( ExcludeTrailingPathDelimiter(SlidesImgRootFolder)) + K_VideoFolder;
end; // function TK_FormCMSFPathChange1.GetAutoVideoRootFolder

function TK_FormCMSFPathChange1.GetAuto3DImgRootFolder() : string;
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
    Result := ExtractFilePath( ExcludeTrailingPathDelimiter(SlidesImgRootFolder)) + K_Img3DFolder;
end; // function TK_FormCMSFPathChange1.GetAuto3DImgRootFolder() : string;

//**************************** TK_FormCMSFPathChange1.PrepChangePathContext ***
// Prepare Change Path Context
//
procedure TK_FormCMSFPathChange1.PrepChangePathContext();
begin
//
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    if EDAGetSlidesFilesInfo( CurFilesPath, CurFilesCount, CurFilesSize, CurDAFlag ) <> K_edOK then Exit;
//    if CurFilesCount = 0 then BtOK.Caption := 'Change &path';
    LEdCurFPath.Text := CurFilesPath;
    LbCurFilesAttrs.Caption := format( K_CML1Form.LLLPathChange36.Caption,
//      'Total number of files: %3d        Whole size: %.1f MB',
                 [CurFilesCount, CurFilesSize/1024/1024] );

    if SlidesCRFC.RootFolder = '' then
      LEdNewPath.Text := CurFilesPath
    else
      LEdNewPath.Text := SlidesCRFC.RootFolder;
      
    LbNewFilesAttrs.Caption := '';
    DisableControls();
  end;
end; // procedure TK_FormCMSFPathChange1.PrepChangePathContext

//***************************** TK_FormCMSFPathChange1.SetChangePathContext ***
// Set Change Path Context
//
function TK_FormCMSFPathChange1.SetChangePathContext( ASkipPrepSlidesMovingContext : Boolean ) : Boolean;
begin
//
 OtherInstancesLaunchFlag := FALSE;
 with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    Result := FALSE;
    N_Dump2Str( format( 'DB>> SetChangePathContext start new %s',
                        [LEdNewPath.Text] ) );

    if K_edFails = EDAPrepSetFilesPathInfo1( LEdNewPath.Text, ASkipPrepSlidesMovingContext ) then
    begin

      if ExtDataErrorString = '*' then
        K_CMShowMessageDlg( K_CML1Form.LLLPathChange15.Caption,
//           'Couldn''t create new folder!',
                            mtWarning )
      else if ExtDataErrorString = '' then
        K_CMShowMessageDlg( K_CML1Form.LLLPathChange16.Caption,
//           'New folder is absent!',
                            mtWarning )
      else
      begin
        K_CMShowMessageDlg( K_CML1Form.LLLPathChange17.Caption + #13#10 +
//                     '     The setting of a new folder is not possible.'#13#10 +
//                     'Other Media Suite instances are launched on the computers:'#13#10 +
                            ExtDataErrorString,
                            mtWarning );
        EDAClearFilesMovingInfo();
        OtherInstancesLaunchFlag := TRUE;
      end;
      Exit;
    end;
  end;
  Result := TRUE;
end; // procedure TK_FormCMSFPathChange1.SetChangePathContext

//************************************ TK_FormCMSFPathChange1.DisableControls ***
// Disable Controls
//
procedure TK_FormCMSFPathChange1.DisableControls();
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
//    ApplyPath.Enabled := not SameText(LEdNewPath.Text, CurFilesPath);
//    SetPath.Enabled := ApplyPath.Enabled;           // Files are absent
    ApplyPath.Enabled := TRUE;
    SetPath.Enabled := TRUE;           
  end;
end; // procedure TK_FormCMSFPathChange1.DisableControls

//************************************** TK_FormCMSFPathChange1.DoApplyPath ***
// Image Files Path Apply
//
function TK_FormCMSFPathChange1.DoApplyPath() : Boolean;
var
  Mes : string;
  ErrCount : Integer;
  OKtoAll : Boolean;
  Res : word;
  WImg3DFCopy     : Boolean; // 3D Img Files Move to New Root Folder Flag
  WMediaFCopy     : Boolean; // Media Files Move to New Root Folder Flag
  WMovingFSDDescr : Integer; // Moving Files Source and Destination description
//  LastProcessMessages : TDateTime;
begin
  Result := FALSE;
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    N_Dump1Str( format( 'DB>> FormCMSFPathChange1.DoApplyPath start new %s',
                        [LEdNewPath.Text] ) );

    if not SetChangePathContext( FALSE ) then Exit;

    if (FChangePathStage = 0) and SlidesCRFC.SameFolder then
    begin // Not check files
      Result := TRUE;
      CurSlidesDSet.Close();
      Exit;
    end;

  ///////////////////////////////////
  // Check Files at new location Loop
  //
    OKtoAll := FALSE;
    Mes := '';
    ErrCount := 0;
    Screen.Cursor := crHourglass;
    while TRUE do
    begin
      case EDACheckNextSlideFiles() of
        K_edOK: begin
          LbNewFilesAttrs.Caption := format( K_CML1Form.LLLPathChange18.Caption,
//                'Total number of checked files: %3d',
                [SlidesCRFC.CopiedFNum] );
          LbNewFilesAttrs.Update();
        end; // K_edOK: begin
        K_edFails: begin
          if ExtDataErrorString = '' then
            break
          else
          begin
            Inc(ErrCount);
            if not OKtoAll then
            begin
              Res := K_CMShowMessageDlg( format( K_CML1Form.LLLPathChange19.Caption,
//                       'File "%s" is not found!'#13#10 +
//                       'Continue files checking?',
                       [ExtDataErrorString] ), mtConfirmation, [mbYes, mbNo, mbYesToAll] );
              if Res = mrYesToAll then
                OKtoAll := TRUE
              else if mrYes <> Res then
              begin
                if SlidesCRFC.SameFolder then
                  Mes := K_CML1Form.LLLPathChange20.Caption
//                  'Some files are not found in current folder.'
                else
                  Mes := K_CML1Form.LLLPathChange21.Caption;
//                    'Some files are not found in new folder.';
                break;
              end;
            end // if not OKtoAll then
            else
              N_Dump1Str( format( 'DB>> FormCMSFPathChange1.DoApplyPath file not found %s',
                        [ExtDataErrorString] ) );

          end;
        end; // K_edFails: begin
      end; // case EDACheckNextSlideFiles() of
      Continue;
    end; // while TRUE do
  //
  // Check Files at new location Loop
  ///////////////////////////////////

    Screen.Cursor := SaveCursor;
    if (Mes = '') and (ErrCount > 0) then
    begin
      if SlidesCRFC.SameFolder then
        Mes := format( K_CML1Form.LLLPathChange22.Caption,
//            '%d files are not found in current folder.',
                       [ErrCount] )
      else
      begin
        Mes := format( K_CML1Form.LLLPathChange23.Caption,
//            '%d files are not found in new folder.',
                       [ErrCount] );
        if mrYes = K_CMShowMessageDlg( Mes + #13#10 + K_CML1Form.LLLPathChange24.Caption,
//               'Are you sure you want to change folder?',
                     mtConfirmation ) then
          Mes := '';
      end;
    end;

    if Mes <> '' then
    begin
      if not SlidesCRFC.SameFolder  then
        Mes := Mes + ' ' + K_CML1Form.LLLPathChange25.Caption; // ' New folder is not set.';
      K_CMShowMessageDlg( Mes, mtWarning );
      with SlidesCRFC do
      begin
        WMediaFCopy := MediaFCopy;
        WMovingFSDDescr := MovingFSDDescr;
        WImg3DFCopy := Img3DFCopy;
        EDAClearFilesMovingInfo();
        MediaFCopy := WMediaFCopy;
        MovingFSDDescr := WMovingFSDDescr;
        Img3DFCopy := WImg3DFCopy;
      end;
    end
    else
    begin
    // Apply Files Path
      Result := TRUE;
      EDASetFilesPathInfo( );
      if SlidesCRFC.SameFolder then
        Mes := K_CML1Form.LLLPathChange26.Caption // 'Files were checked.'
      else
        Mes := K_CML1Form.LLLPathChange27.Caption; // 'New folder is set.';
      K_CMShowMessageDlg( Mes, mtInformation );
    end;
    CurSlidesDSet.Close;
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do
end; // procedure TK_FormCMSFPathChange1.DoApplyPath

//************************************ TK_FormCMSFPathChange1.ClearCurCMSContext ***
// Clear current CMS Show/Edit context
//
// Should be used if dialog is closed and Image Files moving process is not finished
//
procedure TK_FormCMSFPathChange1.ClearCurCMSContext();
begin
//
  with TK_CMEDDBAccess(K_CMEDAccess) do begin
    if (SlidesCRFC.RootFolder = '') then Exit;
    N_CM_MainForm.CMMFFreeEdFrObjects();
    EDASaveSlidesList( nil );  // Save Slides
    EDAClearCurSlidesSet(); // Clear All Opend
    N_CM_MainForm.CMMFRebuildVisSlides();
    N_CM_MainForm.CMMFDisableActions( nil );
  end;
end; // procedure TK_FormCMSFPathChange1.ClearCurCMSContext

procedure TK_FormCMSFPathChange1.BtPathSelect_1Click(Sender: TObject);
var
  RPath : string;
begin
  RPath := LEdNewPath.Text;
//  if SelectDirectory( 'Select Folder', '', RPath ) then
  if K_SelectFolder( 'Select Folder', '', RPath ) then
  begin
    LEdNewPath.Text := IncludeTrailingPathDelimiter(RPath);
    DisableControls();
  end;
end; // procedure TK_FormCMSFPathChange1.BtPathSelect_1Click

procedure TK_FormCMSFPathChange1.SetProperCaption;
begin
  with TK_CMEDDBAccess(K_CMEDAccess).SlidesCRFC do
  begin
    if MediaFCopy then
      Caption := K_CML1Form.LLLPathChange35.Caption
      //      'Change Video Files Folder';
    else
    if Img3DFCopy then
      Caption := 'Change 3D Image Files Folder'
    else
      Caption := K_CML1Form.LLLPathChange34.Caption;
      //      'Change Image Files Folder';
  end;
end; // procedure TK_FormCMSFPathChange1.SetProperCaption

end.
