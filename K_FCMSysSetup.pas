unit K_FCMSysSetup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, StdCtrls, ActnList, Buttons,
  N_BaseF, N_Types, Mask;

type
  TK_FormCMSysSetup = class(TN_BaseForm)
    BtCancel: TButton;
    GBGeneral: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    GBDB: TGroupBox;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    GBSA: TGroupBox;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button6: TButton;
    Button7: TButton;
    CheckBox1: TCheckBox;
    Button14: TButton;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Button15: TButton;
    Button16: TButton;
    BtAutoRefreshSet: TButton;
    BtWEBAccounts: TButton;
    Button17: TButton;
    BtIUApplication: TButton;
    Button18: TButton;
    GBPrintTemplates: TGroupBox;
    Button19: TButton;
    Button21: TButton;
    Button20: TButton;
    Button22: TButton;
    Button23: TButton;
    procedure FormShow(Sender: TObject);
    procedure BtAutoRefreshSetClick(Sender: TObject);
    procedure BtWEBAccountsClick(Sender: TObject);
    procedure BtIUApplicationClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMSysSetup: TK_FormCMSysSetup;

procedure  K_CMSASysSetup( );

implementation

{$R *.dfm}
uses
N_CMMain5F, N_CMResF, N_Lib1,
K_CLib0, K_CM0, K_CM1, K_FCMAutoRefreshLag, K_FCMSASelectProv, K_CMDCM;

//********************************************************** K_CMSASysSetup ***
// Set CMS System Setup
//
procedure  K_CMSASysSetup( );
var
  XrayCaptStreamLineMode : Boolean;
  Skip16bitMode : Boolean;
  RImageType : Integer;
  AutoRefreshLag : Integer;
  DICOMMenuVisFlag : Boolean;
  DelObjsKeepMonths : Integer;
  KeepLogsMonths : Double;
  ScanDataPath, ScanDataPathOld : string;
  ScanDataPathOnClientPC: Boolean;     // CMScan Exchange Folder is on a Client PC Flag
  ScanDataPathOnClientPCAuto: Boolean; // CMScan Auto detect Client PC Exchange Folder Flag
  IUAppPath : string;
  DCMQRServerName : string;
  DCMQRServerIP : string;
  DCMQRServerPort : string;
  DCMStoreServerName : string;
  DCMStoreServerIP : string;
  DCMStoreServerPort : string;
  DCMSCommServerName : string;
  DCMSCommServerIP : string;
  DCMSCommServerPort : string;
  DCMMWLServerName : string;
  DCMMWLServerIP : string;
  DCMMWLServerPort : string;
  DCMAETSCUCMSuite : string;
  DCMAETSCUStoreSCP : string;
//  PrevDCMSetStoreMode : Integer;
  DCMSettingsChange : Boolean;
  PrevDCMAutoStore : Boolean;
  PrevDCMStoreCommitment : Boolean;

  SaveFlags: TK_CMEDSaveStateFlags;
begin
// !!! is needed because of auto call to N_CMResForm.aServXRAYStreamLineExecute during form creation
  K_CMEDAccess.EDAGAGlobalToCurState();
  K_CMEDAccess.EDANotGAGlobalToCurState();
  if K_CMGAModeFlag then
    K_CMEDAccess.EDALocationToCurState(); // Get DCMQR settings

  N_CMResForm.aServXRAYStreamLine.AutoCheck := FALSE;
  N_CMResForm.aServUseGDIPlus.AutoCheck := FALSE;
  N_CMResForm.aServUse16BitImages.AutoCheck := FALSE;
  with TK_FormCMSysSetup.Create( Application ) do
  begin
// !!! is needed because of auto call to N_CMResForm.aServXRAYStreamLineExecute during form creation
    N_CMResForm.aServXRAYStreamLine.AutoCheck := TRUE;
    N_CMResForm.aServUseGDIPlus.AutoCheck := TRUE;
    N_CMResForm.aServUse16BitImages.AutoCheck := TRUE;
    N_CMResForm.aServUseGDIPlus.Checked := K_CMSRImageType = 0;
    if N_CMResForm.aServUseGDIPlus.Checked then // precaution
      K_CMSSkip16bitMode := TRUE;
    N_CMResForm.aServUse16BitImages.Checked := not K_CMSSkip16bitMode;
    N_CMResForm.aServUse16BitImages.Enabled := K_CMGAModeFlag and
                                               not N_CMResForm.aServUseGDIPlus.Checked;
    N_CMResForm.aServUseGDIPlus.Enabled := K_CMGAModeFlag and
                                           not N_CMResForm.aServUse16BitImages.Checked;

    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    XrayCaptStreamLineMode := K_CMXrayCaptStreamLineMode;
    Skip16bitMode := K_CMSSkip16bitMode;
    RImageType := K_CMSRImageType;
    // DelObjsHandling
    DelObjsKeepMonths := N_MemIniToInt( 'CMS_Main', 'DelObjsKeepMonths', 6 );
    KeepLogsMonths := K_CMRemoveOldDumpMonths();
    // Special Settings
    DICOMMenuVisFlag := K_CMGUIDICOMMenuVisFlag;


    AutoRefreshLag := K_CMPatSlidesAutoRefreshLag;
    BtAutoRefreshSet.Enabled := K_CMEDAccess is TK_CMEDDBAccess;

    ScanDataPath := K_CMScanDataPath;
    ScanDataPathOld := K_CMScanDataPathOld;
    ScanDataPathOnClientPC := K_CMScanDataPathOnClientPC;
    ScanDataPathOnClientPCAuto := K_CMScanDataPathOnClientPCAuto;

    IUAppPath := K_CMIUCheckUpdatesPath;

//    PrevDCMSetStoreMode := K_CMDCMSettingsStoreMode;
    DCMQRServerName   := N_MemIniToString( 'CMS_DCMQRSettings', 'Name', ''  );
    DCMQRServerIP     := N_MemIniToString( 'CMS_DCMQRSettings', 'IP', ''  );
    DCMQRServerPort   := N_MemIniToString( 'CMS_DCMQRSettings', 'Port', ''  );

    // Get DICOM Store Server Attributes from MemIni
    DCMStoreServerName := N_MemIniToString( 'CMS_DCMStoreSettings', 'Name', ''  );
    DCMStoreServerIP   := N_MemIniToString( 'CMS_DCMStoreSettings', 'IP', ''  );
    DCMStoreServerPort := N_MemIniToString( 'CMS_DCMStoreSettings', 'Port', ''  );

    // Get DICOM StoreCommitment Server Attributes from MemIni
    DCMSCommServerName := N_MemIniToString( 'CMS_DCMSCommSettings', 'Name', ''  );
    DCMSCommServerIP   := N_MemIniToString( 'CMS_DCMSCommSettings', 'IP', ''  );
    DCMSCommServerPort := N_MemIniToString( 'CMS_DCMSCommSettings', 'Port', ''  );

    // Get DICOM MWL Server Attributes from MemIni
    DCMMWLServerName := N_MemIniToString( 'CMS_DCMMWLSettings', 'Name', ''  );
    DCMMWLServerIP   := N_MemIniToString( 'CMS_DCMMWLSettings', 'IP', ''  );
    DCMMWLServerPort := N_MemIniToString( 'CMS_DCMMWLSettings', 'Port', ''  );

    // Get DICOM AetScu Attributes from MemIni
    DCMAETSCUCMSuite  := N_MemIniToString( 'CMS_DCMAetScu', 'CMSuite', ''  );
    DCMAETSCUStoreSCP := N_MemIniToString( 'CMS_DCMAetScu', 'StoreSCP', ''  );

    PrevDCMAutoStore := K_CMDCMStoreAutoFlag;
    PrevDCMStoreCommitment := K_CMDCMStoreCommitmentFlag;

    ShowModal();

    if K_CMD4WAppFinState then Exit;

    DCMSettingsChange := (DCMQRServerName <> N_MemIniToString( 'CMS_DCMQRSettings', 'Name', '' )) or
                         (DCMQRServerIP   <> N_MemIniToString( 'CMS_DCMQRSettings', 'IP', ''  ))  or
                         (DCMQRServerPort <> N_MemIniToString( 'CMS_DCMQRSettings', 'Port', '' )) or

                         (DCMStoreServerName <> N_MemIniToString( 'CMS_DCMStoreSettings', 'Name', '' )) or
                         (DCMStoreServerIP   <> N_MemIniToString( 'CMS_DCMStoreSettings', 'IP', ''  ))  or
                         (DCMStoreServerPort <> N_MemIniToString( 'CMS_DCMStoreSettings', 'Port', '' )) or

                         (DCMSCommServerName <> N_MemIniToString( 'CMS_DCMSCommSettings', 'Name', '' )) or
                         (DCMSCommServerIP   <> N_MemIniToString( 'CMS_DCMSCommSettings', 'IP', ''  ))  or
                         (DCMSCommServerPort <> N_MemIniToString( 'CMS_DCMSCommSettings', 'Port', '' )) or

                         (DCMMWLServerName <> N_MemIniToString( 'CMS_DCMMWLSettings', 'Name', '' )) or
                         (DCMMWLServerIP   <> N_MemIniToString( 'CMS_DCMMWLSettings', 'IP', ''  ))  or
                         (DCMMWLServerPort <> N_MemIniToString( 'CMS_DCMMWLSettings', 'Port', '' )) or

                         (DCMAETSCUStoreSCP <> N_MemIniToString( 'CMS_DCMAetScu', 'StoreSCP', '' )) or
                         (DCMAETSCUCMSuite <> N_MemIniToString( 'CMS_DCMAetScu', 'CMSuite', '' ));

    SaveFlags := [K_cmssSkipSlides];
    if (ScanDataPath <> K_CMScanDataPath)              or
       (ScanDataPathOld <> K_CMScanDataPathOld)        or
       (ScanDataPathOnClientPC <> K_CMScanDataPathOnClientPC) or
       (ScanDataPathOnClientPCAuto <> K_CMScanDataPathOnClientPCAuto) or
       (AutoRefreshLag <> K_CMPatSlidesAutoRefreshLag) or
       (DelObjsKeepMonths <> N_MemIniToInt( 'CMS_Main', 'DelObjsKeepMonths', DelObjsKeepMonths )) or
       (KeepLogsMonths <> K_CMRemoveOldDumpMonths() ) or
       (IUAppPath <> K_CMIUCheckUpdatesPath) or
{
       ((K_CMDCMSettingsStoreMode = 1) and
        ((PrevDCMSetStoreMode <> K_CMDCMSettingsStoreMode) or DCMSettingsChange)) or
}
       DCMSettingsChange or
       (PrevDCMAutoStore <> K_CMDCMStoreAutoFlag) or
       (PrevDCMStoreCommitment <> K_CMDCMStoreCommitmentFlag) then
      SaveFlags := SaveFlags + [K_cmssSaveGlobal2Info];

    if (XrayCaptStreamLineMode <> K_CMXrayCaptStreamLineMode) or
       (Skip16bitMode <> K_CMSSkip16bitMode)         or
       (RImageType <> K_CMSRImageType)               or
       (DICOMMenuVisFlag <> K_CMGUIDICOMMenuVisFlag) or
        DCMSettingsChange                             or
//       (PrevDCMSetStoreMode <> K_CMDCMSettingsStoreMode) or
       (K_cmssSaveGlobal2Info in SaveFlags) then
      K_CMEDAccess.EDASaveContextsData( SaveFlags );// Save Contexts

    if (Skip16bitMode <> K_CMSSkip16bitMode) or
       (RImageType <> K_CMSRImageType) then
      K_CMScanRebuildCommonInfoFile();
      
//    if IUAppPath <> K_CMIUCheckUpdatesPath then
      N_CM_MainForm.CMMFDisableActions( nil );
  end;
end; // function K_CMSASysSetup

procedure TK_FormCMSysSetup.FormShow(Sender: TObject);
begin
  GBSA.Visible :=
    N_CMResForm.aServSAModeSetup.Visible  and
    N_CMResForm.aServImportPPL.Visible    and
    N_CMResForm.aServExportPPL.Visible;
  GBSA.Enabled :=
    N_CMResForm.aServSAModeSetup.Enabled  or
    N_CMResForm.aServImportPPL.Enabled    or
    N_CMResForm.aServExportPPL.Enabled;
  BtWEBAccounts.Visible := (K_CMEDAccess is TK_CMEDDBAccess) and
                           K_CMGAModeFlag                    and
                           (K_CMEDDBVersion >= 31)           and
                           not (limdCMWEB in K_CMSLiRegModDisable);
  BtIUApplication.Visible := (K_CMEDAccess is TK_CMEDDBAccess);
/////////////////////////////////////////////////////

  GBDB.Visible := (K_CMEDAccess is TK_CMEDDBAccess);
  BtAutoRefreshSet.Visible := (K_CMEDAccess is TK_CMEDDBAccess);

end;

procedure TK_FormCMSysSetup.BtAutoRefreshSetClick(Sender: TObject);
begin
  K_CMGetAutoRefreshLagDlg( K_CMPatSlidesAutoRefreshLag );
end;

procedure TK_FormCMSysSetup.BtWEBAccountsClick(Sender: TObject);
var
  ProvSID : string;
begin
  ProvSID := IntToStr(K_CMEDAccess.CurProvID );
  K_CMSASelectProviderDlg( ProvSID, FALSE, TRUE );
end;

procedure TK_FormCMSysSetup.BtIUApplicationClick(Sender: TObject);
var
  OpenDialog : TOpenDialog;
  IUAppPath : string;
begin
  IUAppPath := K_CMIUCheckUpdatesPath;
  OpenDialog := TOpenDialog.Create(Application);

  OpenDialog.FileName := ExtractFileName(K_CMIUCheckUpdatesPath);
  OpenDialog.InitialDir := ExtractFilePath(K_CMIUCheckUpdatesPath);
  if not DirectoryExists( OpenDialog.InitialDir ) then
  begin // Set Default IU EXE-file name and path
    OpenDialog.InitialDir := K_ExpandFileName('(#BasePath#)');
    OpenDialog.FileName := 'IU\IU.exe';
  end;

  OpenDialog.Filter := 'Internet upgrade application (*.exe)|*.exe';

  OpenDialog.Options := OpenDialog.Options + [ofEnableSizing];

  OpenDialog.Title := 'Internet upgrade application';

  if OpenDialog.Execute and (OpenDialog.FileName <> '') then
    K_CMIUCheckUpdatesPath := OpenDialog.FileName;

  OpenDialog.Free;
  if (K_CMIUCheckUpdatesPath <> '') and (IUAppPath <> K_CMIUCheckUpdatesPath) then
    K_CMShowSoftMessageDlg( 'Internet upgrade application:'#13#10 + K_CMIUCheckUpdatesPath, mtInformation, 5 );//
end;

end.
