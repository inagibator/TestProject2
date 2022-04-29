unit K_FCMSFilesHandling;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ActnList, StdCtrls, ExtCtrls,
  N_Types,
  K_Types;

type
  TK_FormCMSFilesHandling = class(TN_BaseForm)

    BtClose: TButton;

    ActionList1: TActionList;
      ChangeImgRoot: TAction;
      ChangeMediaServRoot: TAction;
      ChangeImg3DRoot: TAction;
    Timer1: TTimer;
    BtCancel: TButton;
    GBImgLocation: TGroupBox;
    LEdImgFPath: TLabeledEdit;
    BtChangeImgServer: TButton;
    GBVideoLocation: TGroupBox;
    LEdServMediaFPath: TLabeledEdit;
    BtChangeMediaServer: TButton;
    GBScanLocation: TGroupBox;
    LEdScanDataPath: TLabeledEdit;
    BtChangeScanDataPath: TButton;
    LEdScanDataPathOld: TLabeledEdit;
    ChBCMScanAutoChange: TCheckBox;
    ChBCMScanClient: TCheckBox;
    ChBCMScanClientAuto: TCheckBox;
    ChBCMScanClientRedirect: TCheckBox;
    GBImg3DLocation: TGroupBox;
    LEdImg3DFPath: TLabeledEdit;
    BtChangeImg3DServer: TButton;
    ChBServerMigration: TCheckBox;

    procedure ChangeImgRootExecute(Sender: TObject);
    procedure ChangeImg3DRootExecute(Sender: TObject);
    procedure ChangeMediaServRootExecute(Sender: TObject);
//    procedure ChangeMediaClientRootExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure ChBCMScanAutoChangeClick(Sender: TObject);
    procedure BtChangeScanDataPathClick(Sender: TObject);
    procedure ChBCMScanClientClick(Sender: TObject);
    procedure ChBCMScanClientAutoClick(Sender: TObject);
    procedure LEdScanDataPathChange(Sender: TObject);
    procedure ChBServerMigrationClick(Sender: TObject);
  private
    { Private declarations }
    RepActionMes : string;
    NewScanDataPathCheckDlg : TForm;
    PrevImgRootFolder, PrevMediaRootFolder, PrevImg3DRootFolder : string;
    RebuildAppViewContext : Boolean;
    function GetBrokenAction() : TAction;
    function ScanClientFolder( const APathName, AFileName: string; AScanLevel : Integer ) : TK_ScanTreeResult;
    procedure OnNewScanDataPathCheckDlgClose();
  public
    { Public declarations }
  end;

var
  K_FormCMSFilesHandling: TK_FormCMSFilesHandling;

implementation

{$R *.dfm}

uses K_CLib0, K_UDT2, K_CM0, K_CM1, K_FCMSFPathChange1, K_CML1F,
N_CMMain5F;

const
 K_FilesStoringModeToRadioInd : array [0..2] of Integer = (1, 0, 2);

procedure K_CMRebuildAppViewContext();
begin
  N_CM_MainForm.CMMUICurStateFlags := [];

  K_CMEDAccess.CurLocID := -1;
  K_CMEDAccess.CurProvID := -1;
  K_CMEDAccess.CurPatID := -1;
  N_CM_MainForm.CMMCurFMainForm.OnShow( nil );
end;

procedure TK_FormCMSFilesHandling.FormShow(Sender: TObject);
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin

    LEdImgFPath.Text  := SlidesImgRootFolder;
    PrevImgRootFolder := SlidesImgRootFolder;
//    ChBImgDAFlag.Checked := SlidesImgRootFDA;

    LEdServMediaFPath.Text := SlidesMediaRootFolder;
    PrevMediaRootFolder    := SlidesMediaRootFolder;

    LEdImg3DFPath.Text  := SlidesImg3DRootFolder;
    PrevImg3DRootFolder := SlidesImg3DRootFolder;

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
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do

end; // procedure TK_FormCMSFilesHandling.FormShow

procedure TK_FormCMSFilesHandling.ChangeImgRootExecute(Sender: TObject);
var
  CRA : TAction;
begin

  CRA := GetBrokenAction();
  if (CRA <> nil) and (CRA <> ChangeImgRoot) then
  begin
    K_CMShowMessageDlg( RepActionMes, mtWarning );
    CRA.OnExecute( Sender );
    RebuildAppViewContext := TRUE;
    Exit;
  end;

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    with SlidesCRFC do
    begin
      if ChangePathStage = 0 then
      begin
        MediaFCopy := FALSE;
        Img3DFCopy := FALSE;
        MovingFSDDescr := 0;
        if ChBServerMigration.Checked then
          ChangePathStage := 1
      end
      else
        ChBServerMigration.Checked := TRUE;
    end;
{
    with TK_FormCMSFPathChange.Create( Application ) do
    begin
//      BaseFormInit( nil );
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
      Caption := K_CML1Form.LLLPathChange34.Caption;
//      'Change Image Files Folder';
      ShowModal;
    end;
}
    with TK_FormCMSFPathChange1.Create( Application ) do
    begin
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
      Caption := K_CML1Form.LLLPathChange34.Caption;
//      'Change Image Files Folder';
      ShowModal;
    end;

    LEdImgFPath.Text := SlidesImgRootFolder;

//    ChBImgDAFlag.Checked := SlidesImgRootFDA;

    if ChBServerMigration.Checked then
    begin // Set All Root Folders fields if server migration mode
      LEdServMediaFPath.Text := SlidesMediaRootFolder;
      LEdImg3DFPath.Text := SlidesImg3DRootFolder;
    end;

    ChBCMScanAutoChangeClick(Sender);
  end;

end; // procedure TK_FormCMSFilesHandling.ChangeImgRootExecute

procedure TK_FormCMSFilesHandling.ChangeImg3DRootExecute( Sender: TObject );
var
  CRA : TAction;
begin

  CRA := GetBrokenAction();
  if (CRA <> nil) and (CRA <> ChangeImg3DRoot) then
  begin
    K_CMShowMessageDlg( RepActionMes, mtWarning );
    CRA.OnExecute( Sender );
    RebuildAppViewContext := TRUE;
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
{
    with TK_FormCMSFPathChange.Create( Application ) do
    begin
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
      Caption := 'Change 3D Image Files Folder';
      ShowModal;
    end;
}
    with TK_FormCMSFPathChange1.Create( Application ) do
    begin
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
      Caption := 'Change 3D Image Files Folder';
      ShowModal;
    end;
//!!!
    LEdImg3DFPath.Text := SlidesImg3DRootFolder;

  end;
end; // procedure TK_FormCMSFilesHandling.ChangeImg3DRootExecute

procedure TK_FormCMSFilesHandling.ChangeMediaServRootExecute( Sender: TObject );
var
  CRA : TAction;
begin

  CRA := GetBrokenAction();
  if (CRA <> nil) and (CRA <> ChangeMediaServRoot) then
  begin
    K_CMShowMessageDlg( RepActionMes, mtWarning );
    CRA.OnExecute( Sender );
    RebuildAppViewContext := TRUE;
    Exit;
  end;

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    with SlidesCRFC do
    begin
      MediaFCopy := TRUE;
      Img3DFCopy := FALSE;
      MovingFSDDescr := 0;
    end;
{
    with TK_FormCMSFPathChange.Create( Application ) do
    begin
      BaseFormInit( nil, '', [crspfMFRet,rspfCenter], [rspfMFRect,rspfCenter] );
      Caption := K_CML1Form.LLLPathChange35.Caption;
//      'Change Video Files Folder';
      ShowModal;
    end;
}
    with TK_FormCMSFPathChange1.Create( Application ) do
    begin
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
      Caption := K_CML1Form.LLLPathChange35.Caption;
//      'Change Video Files Folder';
      ShowModal;
    end;

    LEdServMediaFPath.Text := SlidesMediaRootFolder;
//    ChBMediaDAFlag.Checked := SlidesMediaRootFDA;
//    ChBMediiaSplitFlag.Checked := SlidesMediaFSplit;
  end;
end; // procedure TK_FormCMSFilesHandling.ChangeMediaServRootExecute
{
procedure TK_FormCMSFilesHandling.ChangeMediaClientRootExecute( Sender: TObject );
var
  CRA : TAction;
begin
  CRA := GetBrokenAction();
  if (CRA <> nil) and (CRA <> ChangeMediaClientRoot) then
  begin
    K_CMShowMessageDlg( RepActionMes, mtWarning );
    CRA.OnExecute( Sender );
    Exit;
  end;


  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    with SlidesCRFC do
    begin
      MediaFCopy := TRUE;
      Img3DFCopy := FALSE;
      MovingFSDDescr := 3;
    end;

    with TK_FormCMSFPathChange.Create( Application ) do
    begin
//      BaseFormInit( nil );
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
      Caption := 'Change Video Files Client Folder';
      ShowModal;
    end;

//    LEdClientMediaPath.Text := SlidesClientMediaRootFolder;
  end;

end; // procedure TK_FormCMSFilesHandling.ChangeMediaClientRootExecute
}
procedure TK_FormCMSFilesHandling.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
var
  MesStr : string;
  FSSettingsCode : Integer;
  ScanDataPathWasChanged : Boolean;
  ScanDataPathClientWasChanged : Boolean;
  ScanDataPathClientAutoWasChanged : Boolean;
  ImgPathWasChanged : Boolean;
  MediaPathWasChanged : Boolean;
  Img3DPathWasChanged : Boolean;

  SavedCursor : TCursor;
//  AppFSSettingsCode : Integer;
//  MediaFilesStoringMode : Integer;
begin
//  AppFSSettingsCode := K_CMEDAccess.EDACheckFSSettings( );
//  MediaFilesStoringMode := K_CMMediaFilesStoringMode;
//  K_CMMediaFilesStoringMode := K_FilesStoringModeToRadioInd[RGMediaLocation.ItemIndex];
//  FSSettingsCode := K_CMEDAccess.EDACheckFSSettings( );
//  K_CMMediaFilesStoringMode := MediaFilesStoringMode;
//  CanClose := (FSSettingsCode = 0) or (AppFSSettingsCode <> 0);
  FSSettingsCode := K_CMEDAccess.EDACheckFSSettings( );

  CanClose := (FSSettingsCode = 0);
  if not CanClose then
  begin
    MesStr := '';
    if (FSSettingsCode and 4) <> 0 then
      MesStr := K_CML1Form.LLLPathChange31.Caption; // 'Image Files Root Folder is undefined!';

    if (FSSettingsCode and 1) <> 0 then
    begin
      if MesStr <> '' then
        MesStr := MesStr + #13#10;
      MesStr := MesStr + K_CML1Form.LLLPathChange32.Caption; // 'Video Files Client Root Folder is undefined!';
    end;

    if (FSSettingsCode and 2) <> 0 then
    begin
      if MesStr <> '' then
        MesStr := MesStr + #13#10;
      MesStr := MesStr + K_CML1Form.LLLPathChange33.Caption; // 'Video Files Root Folder is undefined!';
    end;

    if (FSSettingsCode and 8) <> 0 then
    begin
      if MesStr <> '' then
        MesStr := MesStr + #13#10;
      MesStr := MesStr + K_CML1Form.LLLPathChange40.Caption; // '3D Image Files Root Folder is undefined!';
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
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      MesStr := '';
      ImgPathWasChanged := SlidesImgRootFolder <> PrevImgRootFolder;
      if ImgPathWasChanged then
        MesStr := ' Image files folder was changed.';
      MediaPathWasChanged := SlidesMediaRootFolder <> PrevMediaRootFolder;
      if MediaPathWasChanged then
        MesStr := MesStr + ' Video files folder was changed.';
      Img3DPathWasChanged := SlidesMediaRootFolder <> PrevMediaRootFolder;
      if Img3DPathWasChanged then
        MesStr := MesStr + ' 3D Image files folder was changed.';

      if ScanDataPathWasChanged       or
         ScanDataPathClientWasChanged or
         ScanDataPathClientAutoWasChanged then
        MesStr := MesStr + ' Data exchange folder was changed.';
      if MesStr <> '' then
      begin
        if mrYes <> K_CMShowMessageDlg( //sysout
          MesStr + ' Are you sure you want to skip the changes?',
          mtConfirmation ) then CanClose := FALSE;
      end;

      if CanClose and
         ( ImgPathWasChanged or
           MediaPathWasChanged or
           Img3DPathWasChanged ) then
      begin
        SlidesImgRootFolder   := PrevImgRootFolder;
        SlidesMediaRootFolder := PrevMediaRootFolder;
        SlidesImg3DRootFolder := PrevImg3DRootFolder;
        EDASaveCurFilePathsInfoToDB();
      end;
    end; // with TK_CMEDDBAccess(K_CMEDAccess) do

    if RebuildAppViewContext then
      K_CMRebuildAppViewContext();

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
                                        not ChBCMScanClientRedirect.Enabled or
                                        not ChBCMScanClientRedirect.Checked,
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
//      CanClose := FALSE;
      Exit;
    end;
  end
  else
    K_CMScanDataPathOld := LEdScanDataPathOld.Text;

  if RebuildAppViewContext or
     ((uicsAllActsDisabled in N_CM_MainForm.CMMUICurStateFlags) and
      (uicsServActsEnable in N_CM_MainForm.CMMUICurStateFlags) ) then
    K_CMRebuildAppViewContext();

  K_CMEDAccess.EDASaveContextsData(
       [K_cmssSkipSlides, K_cmssSkipInstanceBinInfo,
        K_cmssSkipGlobalInfo, K_cmssSkipPatientInfo,
        K_cmssSkipProviderInfo, K_cmssSkipLocationInfo,
        K_cmssSkipExtIniInfo] );

end; // procedure TK_FormCMSFilesHandling.FormCloseQuery

function TK_FormCMSFilesHandling.GetBrokenAction() : TAction;
begin
  with K_CMEDAccess.SlidesCRFC do
  begin
    RepActionMes := '';
    Result := nil;
    if RootFolder <> '' then
    begin
      if MediaFCopy and (ChangePathStage = 0) then
      begin
        if MovingFSDDescr = 0 then
        begin
          Result := ChangeMediaServRoot;
          RepActionMes := K_CML1Form.LLLPathChange29.Caption;
  //        'Video Files Root Folder changing should be continued';
        end   // if MovingFSDDescr = 0 then
{
        else
        begin // if MovingFSDDescr <> 0 then
          Result := ChangeMediaClientRoot;
          RepActionMes := K_CML1Form.LLLPathChange30.Caption;
  //        'Video Files Client Root Folder changing should be continued';
        end; // if MovingFSDDescr <> 0 then
}
      end
      else
      if Img3DFCopy and (ChangePathStage = 0) then
      begin
        Result := ChangeImg3DRoot;
        RepActionMes := '3D Image Files Root Folder changing should be continued';
      end
      else
      begin
        Result := ChangeImgRoot;
        RepActionMes := K_CML1Form.LLLPathChange28.Caption;
//        'Image Files Root Folder changing should be continued';
      end
    end; // if RootFolder <> '' then
  end; // with K_CMEDAccess.SlidesCRFC do
end; // function TK_FormCMSFilesHandling.GetBrokenAction

procedure TK_FormCMSFilesHandling.Timer1Timer(Sender: TObject);
var
  CRA : TAction;
begin
  Timer1.Enabled := FALSE;
  CRA := GetBrokenAction();
  if CRA = nil then Exit;
  CRA.OnExecute(Sender);
  RebuildAppViewContext := TRUE;
end; // procedure TK_FormCMSFilesHandling.Timer1Timer

procedure TK_FormCMSFilesHandling.ChBCMScanAutoChangeClick(Sender: TObject);
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

end; // procedure TK_FormCMSFilesHandling.ChBCMScanAutoChangeClick

procedure TK_FormCMSFilesHandling.ChBCMScanClientClick(Sender: TObject);
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

procedure TK_FormCMSFilesHandling.ChBCMScanClientAutoClick( Sender: TObject);
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

procedure TK_FormCMSFilesHandling.BtChangeScanDataPathClick( Sender: TObject);
var
  NewPath : string;
begin
  NewPath := LEdScanDataPath.Text;
  if K_SelectFolder( 'Select Client Capture Files Folder', '', NewPath ) then
  begin
    LEdScanDataPath.Text := IncludeTrailingPathDelimiter(NewPath);
  end;
end; // procedure TK_FormCMSFilesHandling.BtChangeScanDataPathClick

procedure TK_FormCMSFilesHandling.LEdScanDataPathChange(Sender: TObject);
begin
  ChBCMScanClientRedirect.Enabled :=  K_CMGAModeFlag               and
                                      not ChBCMScanClient.Checked  and
                                      (LEdScanDataPath.Text <> '') and
                                      (K_CMScanDataPath <> '')     and
         not SameText(K_CMScanDataPath, IncludeTrailingPathDelimiter( LEdScanDataPath.Text ) );
end; // TK_FormCMSFilesHandling.LEdScanDataPathChange

//******************************** TK_FormCMSFilesHandling.ScanClientFolder ***
// Select Scan Client Folders subtree function
//
//     Parameters
// APathName - testing path
// AFileName - testing file name
//
function TK_FormCMSFilesHandling.ScanClientFolder( const APathName, AFileName: string; AScanLevel : Integer ) : TK_ScanTreeResult;
begin
  Result := K_tucSkipSubTree;
  if AFileName = '' then
    K_CMEDAccess.TmpStrings.Add(APathName);
end; // end of TK_FormCMSFilesHandling.ScanClientFolder

//****************** TK_FormCMSFilesHandling.OnNewScanDataPathCheckDlgClose ***
// New ScanDataPathCheck Dlg OnClose handler
//
procedure TK_FormCMSFilesHandling.OnNewScanDataPathCheckDlgClose;
begin
  NewScanDataPathCheckDlg := nil;
end; // TK_FormCMSFilesHandling.OnNewScanDataPathCheckDlgClose


procedure TK_FormCMSFilesHandling.ChBServerMigrationClick(Sender: TObject);
begin
   ChangeMediaServRoot.Enabled := not ChBServerMigration.Checked;
   ChangeImg3DRoot.Enabled := not ChBServerMigration.Checked;
end;

end.
