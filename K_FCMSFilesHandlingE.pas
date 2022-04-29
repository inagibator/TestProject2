unit K_FCMSFilesHandlingE;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ActnList, StdCtrls, ExtCtrls,
  N_Types, K_Types;

type
  TK_FormCMSFilesHandlingE = class(TN_BaseForm)

    BtClose: TButton;

    ActionList1: TActionList;
      ChangeImgRoot: TAction;
      ChangeMediaServRoot: TAction;
      ChangeMediaClientRoot: TAction;
    Bevel1: TBevel;
    Timer1: TTimer;
    BtCancel: TButton;
    Bevel2: TBevel;
    ChBHeadLocationFlag: TCheckBox;
    GBImgLocation: TGroupBox;
    LEdImgFPath: TLabeledEdit;
    BtChangeImgServer: TButton;
    LEdImgEFPath: TLabeledEdit;
    GBServerMediaLocation: TGroupBox;
    LEdServMediaFPath: TLabeledEdit;
    BtChangeMediaServer: TButton;
    LEdServMediaEFPath: TLabeledEdit;
    GBScanLocation: TGroupBox;
    LEdScanDataPath: TLabeledEdit;
    BtChangeScanDataPath: TButton;
    LEdScanDataPathOld: TLabeledEdit;
    ChBCMScanAutoChange: TCheckBox;
    ChBCMScanClient: TCheckBox;
    ChBCMScanClientAuto: TCheckBox;
    ChBCMScanClientRedirect: TCheckBox;
    ChangeImg3DRoot: TAction;
    GBImg3DLocation: TGroupBox;
    LEdImg3DFPath: TLabeledEdit;
    BtChangeImg3DServer: TButton;

    procedure ChangeImgRootExecute(Sender: TObject);
    procedure ChangeImg3DRootExecute(Sender: TObject);
    procedure ChangeMediaServRootExecute(Sender: TObject);
    procedure ChangeMediaClientRootExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure ChBCMScanAutoChangeClick(Sender: TObject);
    procedure ChBCMScanClientClick(Sender: TObject);
    procedure ChBCMScanClientAutoClick(Sender: TObject);
    procedure LEdScanDataPathChange(Sender: TObject);
//    procedure RGMediaLocationClick(Sender: TObject);
  private
    { Private declarations }
    RepActionMes : string;
    NewScanDataPathCheckDlg : TForm;
    function GetBrokenAction() : TAction;
    function ScanClientFolder( const APathName, AFileName: string; AScanLevel : Integer ) : TK_ScanTreeResult;
    procedure OnNewScanDataPathCheckDlgClose();
  public
    { Public declarations }
  end;

var
  K_FormCMSFilesHandlingE: TK_FormCMSFilesHandlingE;

implementation

{$R *.dfm}

uses K_CLib0, K_CM0, K_CM1, K_FCMSFPathChange, K_CML1F;

const
 K_FilesStoringModeToRadioInd : array [0..2] of Integer = (1, 0, 2);

procedure TK_FormCMSFilesHandlingE.FormShow(Sender: TObject);
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin

    ChBHeadLocationFlag.Checked := (CurLocEFlags and 1) <> 0;
    ChBHeadLocationFlag.Enabled := not ChBHeadLocationFlag.Checked and
                                   K_CMEnterpriseModeFlag and K_CMGAModeFlag;

    LEdImgFPath.Text     := SlidesImgRootFolder;
    LEdImgEFPath.Text    := SlidesImgRootEFolder;
//    ChBImgDAFlag.Checked := SlidesImgRootFDA;

    LEdServMediaFPath.Text  := SlidesMediaRootFolder;
    LEdServMediaEFPath.Text := SlidesMediaRootEFolder;
//    ChBMediaDAFlag.Checked  := SlidesMediaRootFDA;
//    ChBMediiaSplitFlag.Checked := SlidesMediaFSplit;

//    LEdClientMediaPath.Text := SlidesClientMediaRootFolder;

//    RGMediaLocation.ItemIndex := K_FilesStoringModeToRadioInd[K_CMMediaFilesStoringMode];
//    RGMediaLocationClick(Sender);

    LEdImg3DFPath.Text := SlidesImg3DRootFolder;

    ////////////////////////////////
    // Set Scan Data Path  controls
    //
    LEdScanDataPath.Text := K_CMScanDataPath;
    LEdScanDataPathOld.Text := K_CMScanDataPathOld;
    if not K_CMScanDataPathOnClientPC and
       ( ExtractFilePath( ExcludeTrailingPathDelimiter(SlidesImgRootFolder) ) =
         ExtractFilePath( ExcludeTrailingPathDelimiter(K_CMScanDataPath) ) ) then
      ChBCMScanAutoChange.Checked := TRUE
    else
      ChBCMScanAutoChangeClick(nil);

    ChBCMScanClient.Checked := K_CMScanDataPathOnClientPC;
    if not ChBCMScanClient.Checked then ChBCMScanClientClick( nil );

    ChBCMScanClientAuto.Checked := K_CMScanDataPathOnClientPCAuto;

    ChBCMScanClientRedirect.Enabled := FALSE;

    if LEdScanDataPathOld.Text <> '' then
    begin
      K_CMEDAccess.TmpStrings.Clear;
      K_ScanFilesTree( K_CMScanDataPathOld, ScanClientFolder, '*.*' );
      if K_CMEDAccess.TmpStrings.Count = 0 then
      begin
        K_DeleteFile( K_CMScanDataPathOld + K_CMScanPathRedirectFileName );
        LEdScanDataPathOld.Text := '';
      end; // if K_CMEDAccess.TmpStrings.Count = 0 then
    end; // if LEdScanDataPathOld.Text <> '' then
    //
    // Set Scan Data Path  controls
    ////////////////////////////////

    Timer1.Enabled := TRUE;
  end;

end;

procedure TK_FormCMSFilesHandlingE.ChangeImgRootExecute(Sender: TObject);
var
  CRA : TAction;
begin

  CRA := GetBrokenAction();
  if (CRA <> nil) and (CRA <> ChangeImgRoot) then begin
    K_CMShowMessageDlg( RepActionMes, mtWarning );
    CRA.OnExecute( Sender );
    Exit;
  end;

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    with SlidesCRFC do begin
      MediaFCopy := FALSE;
      Img3DFCopy := FALSE;
      MovingFSDDescr := 0;
    end;

    with TK_FormCMSFPathChange.Create( Application ) do
    begin
//      BaseFormInit( nil );
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
      Caption := K_CML1Form.LLLPathChange34.Caption; //'Change Image Files Folder';
      ShowModal;
    end;

    LEdImgFPath.Text := SlidesImgRootFolder;
//    ChBImgDAFlag.Checked := SlidesImgRootFDA;
  end;

end;

procedure TK_FormCMSFilesHandlingE.ChangeImg3DRootExecute( Sender: TObject );
var
  CRA : TAction;
begin

  CRA := GetBrokenAction();
  if (CRA <> nil) and (CRA <> ChangeImg3DRoot) then
  begin
    K_CMShowMessageDlg( RepActionMes, mtWarning );
    CRA.OnExecute( Sender );
    Exit;
  end;

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    with SlidesCRFC do
    begin
      MediaFCopy := FALSE;
      Img3DFCopy := TRUE;
      MovingFSDDescr := 0;
    end;

    with TK_FormCMSFPathChange.Create( Application ) do
    begin
//      BaseFormInit( nil );
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
      Caption := 'Change 3D Image Files Folder';
      ShowModal;
    end;
//!!!
    LEdImg3DFPath.Text := SlidesImg3DRootFolder;

  end;
end; // procedure TK_FormCMSFilesHandlingE.ChangeImg3DRootExecute

procedure TK_FormCMSFilesHandlingE.ChangeMediaServRootExecute(Sender: TObject);
var
  CRA : TAction;
begin

  CRA := GetBrokenAction();
  if (CRA <> nil) and (CRA <> ChangeMediaServRoot) then begin
    K_CMShowMessageDlg( RepActionMes, mtWarning );
    CRA.OnExecute( Sender );
    Exit;
  end;

  with TK_CMEDDBAccess(K_CMEDAccess) do begin
    with SlidesCRFC do begin
      MediaFCopy := TRUE;
      Img3DFCopy := FALSE;
      MovingFSDDescr := 0;
    end;

    with TK_FormCMSFPathChange.Create( Application ) do
    begin
//      BaseFormInit( nil );
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
      Caption := K_CML1Form.LLLPathChange35.Caption; //'Change Video Files Folder';
      ShowModal;
    end;

    LEdServMediaFPath.Text := SlidesMediaRootFolder;
//    ChBMediaDAFlag.Checked := SlidesMediaRootFDA;
  end;
end;

procedure TK_FormCMSFilesHandlingE.ChangeMediaClientRootExecute(
  Sender: TObject);
var
  CRA : TAction;
begin
  CRA := GetBrokenAction();
  if (CRA <> nil) and (CRA <> ChangeMediaClientRoot) then begin
    K_CMShowMessageDlg( RepActionMes, mtWarning );
    CRA.OnExecute( Sender );
    Exit;
  end;


  with TK_CMEDDBAccess(K_CMEDAccess) do begin
    with SlidesCRFC do begin
      MediaFCopy := TRUE;
      Img3DFCopy := FALSE;
      MovingFSDDescr := 3;
    end;

    with TK_FormCMSFPathChange.Create( Application ) do
    begin
//      BaseFormInit( nil );
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
      Caption := 'Change Video Files Client Folder';
      ShowModal;
    end;

//    LEdClientMediaPath.Text := SlidesClientMediaRootFolder;
  end;

end;

procedure TK_FormCMSFilesHandlingE.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
//  MediaFilesStoringMode : Integer;
//  AppFilesHandling : Integer;
  MesStr : string;
  FSSettingsCode : Integer;
  ScanDataPathWasChanged : Boolean;
  ScanDataPathClientWasChanged : Boolean;
  ScanDataPathClientAutoWasChanged : Boolean;
  SavedCursor : TCursor;
begin
//  AppFSSettingsCode := K_CMEDAccess.EDACheckFSSettings( );
//  MediaFilesStoringMode := K_CMMediaFilesStoringMode;
//  K_CMMediaFilesStoringMode := K_FilesStoringModeToRadioInd[RGMediaLocation.ItemIndex];
//  FSSettingsCode := K_CMEDAccess.EDACheckFSSettings( );
//  K_CMMediaFilesStoringMode := MediaFilesStoringMode;
//  CanClose := (FSSettingsCode = 0) or (AppFSSettingsCode <> 0);
  FSSettingsCode := K_CMEDAccess.EDACheckFSSettings( );
  CanClose := (FSSettingsCode = 0);
  if not CanClose then begin
    MesStr := '';

    if (FSSettingsCode and 4) <> 0 then
      MesStr := K_CML1Form.LLLPathChange31.Caption; //'Image Files Root Folder is undefined!';

    if (FSSettingsCode and 1) <> 0 then
    begin
      if MesStr <> '' then
        MesStr := MesStr + #13#10;
      MesStr := MesStr + K_CML1Form.LLLPathChange32.Caption; //'Video Files Client Root Folder is undefined!';
    end;

    if (FSSettingsCode and 2) <> 0 then begin
      if MesStr <> '' then
        MesStr := MesStr + #13#10;
      MesStr := MesStr + K_CML1Form.LLLPathChange33.Caption; //'Video Files Root Folder is undefined!';
    end;

    K_CMShowMessageDlg( MesStr, mtWarning );

    Exit;
  end;

  if LEdScanDataPath.Text <> '' then
    LEdScanDataPath.Text := IncludeTrailingPathDelimiter( LEdScanDataPath.Text );

//  ScanDataPathWasChanged := not SameText(K_CMScanDataPath, LEdScanDataPath.Text);
  ScanDataPathWasChanged := not TK_CMEDDBAccess(K_CMEDAccess).EDACheckFoldersEquality1( K_CMScanDataPath, TRUE,
                                   LEdScanDataPath.Text, TRUE );
  ScanDataPathClientWasChanged := (K_CMScanDataPathOnClientPC <> ChBCMScanClient.Checked);
  ScanDataPathClientAutoWasChanged := (K_CMScanDataPathOnClientPCAuto <> ChBCMScanClientAuto.Checked);

  if ModalResult <> mrOK then
  begin
    if ScanDataPathWasChanged       or
       ScanDataPathClientWasChanged or
       ScanDataPathClientAutoWasChanged then
    begin
      if mrYes <> K_CMShowMessageDlg( //sysout
        'Client Capture Files Folder was changed. Are you sure you want to skip the changes?',
        mtConfirmation ) then CanClose := FALSE;
    end;
    Exit;
  end; // if ModalResult <> mrOK then
//  K_CMMediaFilesStoringMode := K_FilesStoringModeToRadioInd[RGMediaLocation.ItemIndex];
  K_CMScanDataPathOnClientPC     := ChBCMScanClient.Checked;
  K_CMScanDataPathOnClientPCAuto := ChBCMScanClientAuto.Checked;

  // Prep Set Scan Data Path Results
  if ScanDataPathWasChanged or
     K_CMScanDataPathOnClientPCAuto or
     ScanDataPathClientWasChanged then
  begin

    // Show Wait Message - “Media Suite is checking the Exchange folder. Please wait.”
    // and change cursor to Hourglass
    NewScanDataPathCheckDlg := K_CMShowSoftMessageDlg(
           'Media Suite is checking the Exchange folder. Please wait.',
           mtInformation, 40, OnNewScanDataPathCheckDlgClose );
    NewScanDataPathCheckDlg.Repaint();
    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;

    //Check new path
    CanClose := K_CMScanSetNewDataPath( LEdScanDataPath.Text,
                                        ChBCMScanClientRedirect.Enabled and
                                        ChBCMScanClientRedirect.Checked,
                                        ScanDataPathWasChanged );
    // Hide Wait Message and return cursor
    if NewScanDataPathCheckDlg <> nil then
      NewScanDataPathCheckDlg.Close();
    Screen.Cursor := SavedCursor;

    if not CanClose then
    begin
      K_CMShowMessageDlg( //sysout
        format('Data exchange folder'#13#10'%s'#13#10'couldn''t be used. Set another folder please.',
        [LEdScanDataPath.Text]), mtWarning );
      CanClose := FALSE;
      Exit;
    end;
  end
  else
    K_CMScanDataPathOld := LEdScanDataPathOld.Text;

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    SlidesImgRootEFolder := LEdImgEFPath.Text;
    SlidesMediaRootEFolder := LEdServMediaEFPath.Text;
    if ChBHeadLocationFlag.Checked and ((CurLocEFlags and 1) = 0) then
    // HeadOffice Flag Was Set
      CurLocEFlags := CurLocEFlags or 1;
    EDASetFilesEnterpriseContext();

//    K_CMMediaFilesStoringMode := K_FilesStoringModeToRadioInd[RGMediaLocation.ItemIndex];
    EDASaveContextsData(
         [K_cmssSkipSlides, K_cmssSkipInstanceBinInfo,
          K_cmssSkipGlobalInfo, K_cmssSkipPatientInfo,
          K_cmssSkipProviderInfo, K_cmssSkipLocationInfo,
          K_cmssSkipExtIniInfo] );
  end;

end; // procedure TK_FormCMSFilesHandlingE.FormCloseQuery

function TK_FormCMSFilesHandlingE.GetBrokenAction() : TAction;
begin
  with K_CMEDAccess.SlidesCRFC do begin
    Result := nil;
    if RootFolder <> '' then begin
      if Img3DFCopy then
      begin
        Result := ChangeImg3DRoot;
        RepActionMes := '3D Image Files Root Folder changing should be continued';
      end
      else
      if not MediaFCopy then begin
        Result := ChangeImgRoot;
        RepActionMes := K_CML1Form.LLLPathChange28.Caption;
//        'Image Files Root Folder changing should be continued';
      end else if MovingFSDDescr = 0 then begin
        Result := ChangeMediaServRoot;
        RepActionMes := K_CML1Form.LLLPathChange29.Caption;
//        'Video Files Root Folder changing should be continued';
      end else begin
        Result := ChangeMediaClientRoot;
        RepActionMes := K_CML1Form.LLLPathChange30.Caption;
//        'Video Files Client Root Folder changing should be continued';
      end;
    end;
  end;
end; // function TK_FormCMSFilesHandlingE.GetBrokenAction

procedure TK_FormCMSFilesHandlingE.Timer1Timer(Sender: TObject);
var
  CRA : TAction;
begin
  Timer1.Enabled := FALSE;
  CRA := GetBrokenAction();
  if CRA <> nil then
    CRA.OnExecute(Sender);
end; // procedure TK_FormCMSFilesHandlingE.Timer1Timer
{
procedure TK_FormCMSFilesHandlingE.RGMediaLocationClick(Sender: TObject);
begin
//  LEdServMediaFPath.Enabled   := (RGMediaLocation.ItemIndex <> 1);
//  BtChangeMediaServer.Enabled := LEdServMediaFPath.Enabled;
//  LEdServMediaEFPath.Enabled  := LEdServMediaFPath.Enabled;

//  LEdClientMediaPath.Enabled  := (RGMediaLocation.ItemIndex <> 0);
//  BtChangeMediaClient.Enabled := LEdClientMediaPath.Enabled;

end;
}
procedure TK_FormCMSFilesHandlingE.ChBCMScanAutoChangeClick(Sender: TObject);
var
  BasePath, ScanFolderName  : string;
begin
  LEdScanDataPath.ReadOnly := ChBCMScanAutoChange.Checked or not K_CMGAModeFlag;
  if LEdScanDataPath.ReadOnly then
    LEdScanDataPath.Color := clBtnFace
  else
    LEdScanDataPath.Color := $00A2FFFF;
  BtChangeScanDataPath.Enabled := not LEdScanDataPath.ReadOnly;

  ChBCMScanAutoChange.Enabled := K_CMGAModeFlag;
  if ChBCMScanAutoChange.Checked  then
  begin
    ScanFolderName := LEdScanDataPath.Text;
    if LEdScanDataPath.Text <> '' then
      ScanFolderName := ExtractFileName(ExcludeTrailingPathDelimiter(LEdScanDataPath.Text))
    else
      ScanFolderName := 'ClientScanData';
    BasePath := LEdImgFPath.Text;
    if BasePath = '' then
      BasePath := LEdServMediaFPath.Text;
    if BasePath <> '' then
      LEdScanDataPath.Text :=
           ExtractFilePath( ExcludeTrailingPathDelimiter(BasePath) ) +
                            ScanFolderName + '\'
    else
      LEdScanDataPath.Text := '';
  end;

  ChBCMScanClient.Enabled := K_CMGAModeFlag and not ChBCMScanAutoChange.Checked;

end; // procedure TK_FormCMSFilesHandlingE.ChBCMScanAutoChangeClick

procedure TK_FormCMSFilesHandlingE.ChBCMScanClientClick(Sender: TObject);
begin
  ChBCMScanAutoChange.Enabled := K_CMGAModeFlag and not ChBCMScanClient.Checked;
  ChBCMScanClientAuto.Enabled := K_CMGAModeFlag and ChBCMScanClient.Checked;

  if not ChBCMScanClient.Checked then
    ChBCMScanClientAuto.Checked := FALSE;

  // Proper ChBCMScanClientRedirect set
  LEdScanDataPathChange(Sender);
  if not ChBCMScanClientRedirect.Enabled then
    ChBCMScanClientRedirect.Checked := FALSE;

end; // procedure TK_FormCMSFilesHandling.ChBCMScanClientClick

procedure TK_FormCMSFilesHandlingE.ChBCMScanClientAutoClick( Sender: TObject);
begin
  LEdScanDataPath.ReadOnly := ChBCMScanClientAuto.Checked or not K_CMGAModeFlag;
  if LEdScanDataPath.ReadOnly then
    LEdScanDataPath.Color := clBtnFace
  else
    LEdScanDataPath.Color := $00A2FFFF;
  BtChangeScanDataPath.Enabled := not LEdScanDataPath.ReadOnly;
  if ChBCMScanClientAuto.Checked then
    LEdScanDataPath.Text := '';
end; // procedure TK_FormCMSFilesHandling.ChBCMScanClientAutoClick

procedure TK_FormCMSFilesHandlingE.LEdScanDataPathChange(Sender: TObject);
begin
  ChBCMScanClientRedirect.Enabled :=  K_CMGAModeFlag               and
                                      not ChBCMScanClient.Checked  and
                                      (LEdScanDataPath.Text <> '') and
                                      (K_CMScanDataPath <> '')     and
         not SameText(K_CMScanDataPath, IncludeTrailingPathDelimiter( LEdScanDataPath.Text ) );
end; // TK_FormCMSFilesHandlingE.LEdScanDataPathChange

//******************************* TK_FormCMSFilesHandlingE.ScanClientFolder ***
// Select Scan Client Folders subtree function
//
//     Parameters
// APathName - testing path
// AFileName - testing file name
//
function TK_FormCMSFilesHandlingE.ScanClientFolder( const APathName, AFileName: string; AScanLevel : Integer ) : TK_ScanTreeResult;
begin
  Result := K_tucSkipSubTree;
  if AFileName = '' then
    K_CMEDAccess.TmpStrings.Add(APathName);
end; // end of TK_FormCMSFilesHandlingE.ScanClientFolder

//***************** TK_FormCMSFilesHandlingE.OnNewScanDataPathCheckDlgClose ***
// New ScanDataPathCheck Dlg OnClose handler
//
procedure TK_FormCMSFilesHandlingE.OnNewScanDataPathCheckDlgClose;
begin
  NewScanDataPathCheckDlg := nil;
end; // TK_FormCMSFilesHandlingE.OnNewScanDataPathCheckDlgClose

end.
