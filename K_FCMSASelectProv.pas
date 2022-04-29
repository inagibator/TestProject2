unit K_FCMSASelectProv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, StdCtrls, ActnList, N_Rast1Fr, Buttons,
  K_CM0,
  N_BaseF, N_Types, N_DGrid;

type
  TK_FormCMSASelectProvider = class(TN_BaseForm)
    BtOK: TButton;
    ActionList1: TActionList;
    aAddProvider: TAction;
    aModifyProvider: TAction;
    aDeleteProvider: TAction;
    BtAdd: TButton;
    BtModify: TButton;
    BtDelete: TButton;
    aRestoreProvider: TAction;
    aDeleteProviderForever: TAction;
    CmBProviders: TComboBox;
    BtCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure aAddProviderExecute(Sender: TObject);
    procedure aModifyProviderExecute(Sender: TObject);
    procedure aDeleteProviderExecute(Sender: TObject);
    procedure aRestoreProviderExecute(Sender: TObject);
    procedure aDeleteProviderForeverExecute(Sender: TObject);
    procedure CmBProvidersChange(Sender: TObject);
  private
    { Private declarations }
    DelProvSID : string;
    WEBAccountOnly : Boolean;
    procedure RebuildProvidersListView();
    function  GetProviderData( APCMSAProviderDBData : TK_PCMSAProviderDBData; ALockOnly : Boolean ) : Boolean;
    procedure DeleteCurProviderInfo();
    procedure SetCurProviderSyncState( );
  public
    { Public declarations }
    ProvSID : string;
    SrcProvSID : string;
  end;

var
  K_FormCMSASelectProvider: TK_FormCMSASelectProvider;

function  K_CMSASelectProviderDlg( var AProvSID : string; AShowDelFlag : Boolean;
                                   AWEBAccountOnly : Boolean = FALSE ) : Boolean;

implementation

{$R *.dfm}
uses Math,
N_CMMain5F, N_CMResF, N_CM1, N_CM2, N_Comp1, N_Lib0,
K_CLib0, K_Script1, K_VFunc, K_FCMSASetProvData, K_CML1F;

//***************************************************** K_CMSASelectProviderDlg ***
// Set CMS Standalone Patient Data Dialog
//
//     Parameters
// AProvSID - Provider ID string
// AShowDelFlag - Show marked as deleted Providers
// Result - Returns FALSE if user do not click OK
//
// If source AProvSID value is differed from "", then Provider with given ID
// should be highlighted as selected, else no Provider should be selected.
// Resulting AProvSID if Result value is TRUE contains Selected Provider ID string
//
function  K_CMSASelectProviderDlg( var AProvSID : string; AShowDelFlag : Boolean;
                                   AWEBAccountOnly : Boolean = FALSE ) : Boolean;
begin
  with TK_FormCMSASelectProvider.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ProvSID := AProvSID;
    SrcProvSID := AProvSID;
    K_CMEDAccess.EDASAGetProvidersInfo( AShowDelFlag );

    if AShowDelFlag then
    begin
      BtAdd.Action := aRestoreProvider;
      aDeleteProviderForever.Enabled := K_CMGAModeFlag;
      BtModify.Action := aDeleteProviderForever;
      BtDelete.Visible := False;
      BtOK.Visible := False;
      BtCancel.Caption := BtOK.Caption; // '&OK';
    end;

    aAddProvider.Enabled := K_CMStandaloneMode <> K_cmsaLink;
    aModifyProvider.Caption := K_CML1Form.LLLSADialogs7.Caption; // '&Modify';
    if not aAddProvider.Enabled then
       aModifyProvider.Caption := K_CML1Form.LLLSADialogs6.Caption; // '&Details';

    WEBAccountOnly := AWEBAccountOnly;
    aAddProvider.Enabled := not WEBAccountOnly;

    N_Dump1Str( 'SelectProviderDlg Start ID=' + AProvSID );
    Result := ShowModal() = mrOK;
    K_CMEDAccess.EDASAGetProvidersInfo( FALSE );
    if Result then
      AProvSID := ProvSID;
    N_Dump1Str( 'SelectProviderDlg Fin WEB=' + N_B2S(AWEBAccountOnly) );
  end;
end; // function K_CMSASelectProviderDlg

//******************************* TK_FormCMSASelectProvider.FormShow ***
// Form Show Handler
//
procedure TK_FormCMSASelectProvider.FormShow(Sender: TObject);
begin
  inherited;

  aModifyProvider.Enabled := FALSE;
  aDeleteProvider.Enabled := FALSE;
  aRestoreProvider.Enabled := FALSE;
  aDeleteProviderForever.Enabled := FALSE;

  RebuildProvidersListView();

  Constraints.MaxHeight := Height;
  Constraints.MinHeight := Height;
end; // procedure TK_FormCMSASelectProvider.FormShow

//******************************* TK_FormCMSASelectProvider.FormCloseQuery ***
// Form Close Query Handler
//
procedure TK_FormCMSASelectProvider.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  CurProvInd : Integer;
begin
  // mrOK and not Show Mark as Deleted
  if ModalResult = mrOK then
  begin
    CanClose := ProvSID <> '';
    if not CanClose then
      K_CMShowMessageDlg( K_CML1Form.LLLSelProv1.Caption,
//      'Dentist is not selected. Select Dentist before exit.',
                          mtWarning, [mbOK] );
  end
  else
  if BtAdd.Action = aAddProvider then
  begin
    with K_CMEDAccess, ProvidersInfo.R do
    begin
      CurProvInd := K_IndexOfStringInRArray( SrcProvSID,
                                                PME( 0, 1),
                                                ARowCount - 1,
                                                ElemSize * AColCount );
      CanClose := CurProvInd >= 0;
    end;
    if not CanClose then
      K_CMShowMessageDlg( K_CML1Form.LLLSelProv2.Caption,
//      'Current Media Suite Dentist was deleted. Select new current Dentist.',
                           mtWarning, [mbOK] )
  end;
{
  if (ProvSID <> '')        or
     (ModalResult <> mrOK) or
     (BtAdd.Action = aRestoreProvider) then Exit;
  K_CMShowMessageDlg( 'Dentist is not selected. Press OK to continue.',
                       mtWarning, [mbOK] );
  CanClose := FALSE;
}

end; // procedure TK_FormCMSASelectProvider.FormCloseQuery

//***************************** TK_FormCMSASelectProvider.RebuildProvidersListView ***
// Rebuild Patients View
//
procedure TK_FormCMSASelectProvider.RebuildProvidersListView;
begin
  with CmBProviders do
  begin
    ItemIndex := K_CMSAFillProvidersList( Items, ProvSID );
    with CmBProviders do
      if ItemIndex = -1 then ItemIndex := 0;
    CmBProvidersChange(CmBProviders);
  end;
end; // procedure TK_FormCMSASelectProvider.RebuildProvidersListView;

//***************************** TK_FormCMSASelectProvider.aAddProviderExecute ***
// Add New Patient Action Execute
//
procedure TK_FormCMSASelectProvider.aAddProviderExecute(Sender: TObject);
var
  CMSAProviderDBData : TK_CMSAProviderDBData;
begin
  inherited;
  N_Dump1Str( 'K_FCMSASelectProv.aAddProvider start' );
  ZeroMemory( @CMSAProviderDBData, SizeOf(TK_CMSAProviderDBData) );
  CMSAProviderDBData.AUIsPMSSync := FALSE;
  if not K_CMSASetProviderDataDlg( '', @CMSAProviderDBData ) then Exit;

  with K_CMEDAccess, ProvidersInfo.R do
  begin
    if (ARowCount = 2) and
       (PString(PME(0, 1))^ = '1') and
       (PString(PME(1, 1))^ = 'Mediasuite') and
       (PString(PME(2, 1))^ = 'Dentist') and
       (PString(PME(3, 1))^ = 'Dr') then
      ProvSID := '1'
    else
      ProvSID := '';
    EDASASetOneProviderInfo( ProvSID, @CMSAProviderDBData, FALSE );
  end;


  RebuildProvidersListView();

  ActiveControl := BtOK;

  N_Dump1Str( 'K_FCMSASelectProv.aAddProvider fin ID=' + ProvSID );
end; // procedure TK_FormCMSASelectProvider.aAddProviderExecute

//***************************** TK_FormCMSASelectProvider.aModifyProviderExecute ***
// Modify Selected Patient Action Execute
//
procedure TK_FormCMSASelectProvider.aModifyProviderExecute(Sender: TObject);
var
  CMSAProviderDBData : TK_CMSAProviderDBData;
  SkipFieldsSet : Boolean;
  SkipSetDataDlg : Boolean;

begin

  if ProvSID = '' then Exit; // precaution
  N_Dump1Str( 'K_FCMSASelectProv.aModifyProvider start ID=' + ProvSID );
  if not GetProviderData( @CMSAProviderDBData, FALSE ) then Exit;

  if CMSAProviderDBData.AUIsPMSSync and
     (K_CMStandaloneMode = K_cmsaHybrid) and
     aDeleteProvider.Enabled then
  begin
  // Rebuild Interface if start modify object
  // which was unsynchronized and now is detected as synchronized to PMS
    SetCurProviderSyncState( );
  end;


  // Free Lock if ReadOnly Mode
  if CMSAProviderDBData.AUIsLocked and
     not WEBAccountOnly            and
     ( (K_CMStandaloneMode = K_cmsaLink) or
       ( CMSAProviderDBData.AUIsPMSSync and
         (K_CMStandaloneMode = K_cmsaHybrid) ) ) then
  begin
  // Clear Provider Lock
    K_CMEDAccess.EDASASetOneProviderInfo( ProvSID, nil, TRUE );
    CMSAProviderDBData.AUIsLocked := FALSE;
  end;

  SkipSetDataDlg := (aModifyProvider.Caption <> K_CML1Form.LLLSADialogs6.Caption) and
                    not CMSAProviderDBData.AUIsLocked;
  if SkipSetDataDlg then
    K_CMShowMessageDlg( K_CML1Form.LLLSelProv3.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'Selected dentist is now being edited by other user. Press OK to continue.',
                         mtWarning, [mbOK] );

  if not SkipSetDataDlg or not WEBAccountOnly then
    SkipFieldsSet := not K_CMSASetProviderDataDlg( ProvSID, @CMSAProviderDBData, WEBAccountOnly )
  else
    SkipFieldsSet := TRUE;
  // Change Locked State to Correct Actions after editing
  K_CMEDAccess.EDASASetOneProviderInfo( ProvSID, @CMSAProviderDBData, SkipFieldsSet );

  RebuildProvidersListView();

  ActiveControl := BtOK;

  N_Dump1Str( 'K_FCMSASelectProv.aModifyProvider fin SkipSave=' + N_B2S(SkipFieldsSet) );

end; // procedure TK_FormCMSASelectProvider.aModifyProviderExecute

//***************************** TK_FormCMSASelectProvider.aDeleteProviderExecute ***
// Delete Selected Patient Action Execute
//
procedure TK_FormCMSASelectProvider.aDeleteProviderExecute(Sender: TObject);
var
  CMSAProviderDBData : TK_CMSAProviderDBData;
  DataInd : Integer;
begin
  if ProvSID = '' then Exit; // precaution

  N_Dump1Str( 'K_FCMSASelectProv.aDeleteProvider start ID=' + ProvSID );

  if not GetProviderData( @CMSAProviderDBData, TRUE ) then Exit;

  if CMSAProviderDBData.AUIsPMSSync and
     (K_CMStandaloneMode = K_cmsaHybrid) then
  begin
    K_CMEDAccess.EDASASetOneProviderInfo( ProvSID, nil, TRUE );
    SetCurProviderSyncState( );
    K_CMShowMessageDlg( K_CML1Form.LLLSelProv4.Caption,
//    'This dentist couldn''t be deleted. It is linked to corresponding Practice Management System object.',
                           mtWarning, [mbOK] );
    Exit;
  end;

  if not CMSAProviderDBData.AUIsLocked then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelProv3.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This dentist is now being edited by other user. Press OK to continue.',
                         mtWarning, [mbOK] );
    Exit;
  end;


//  DataInd := CmBProviders.ItemIndex + 1;
  with CmBProviders do
    DataInd := Integer(Items.Objects[ItemIndex]);
  with K_CMEDAccess.ProvidersInfo.R do
  begin
    if CMSAProviderDBData.AUPatCount > 0 then
    begin
      K_CMShowMessageDlg( format( K_CML1Form.LLLSelProv5.Caption,
//      '%s %s %s is linked to patient files. Please change the Dentist name for these patients first, then delete.',
                         [PString(PME(3,DataInd))^, PString(PME(1,DataInd))^, PString(PME(2,DataInd))^] ),
                           mtWarning, [mbOK] );
      Exit;
    end;


    if mrYes <> K_CMShowMessageDlg(
        format( K_CML1Form.LLLSelProv6.Caption + #13#10 +
                '                   ' + K_CML1Form.LLLPressYesToProceed.Caption,
//                'Please confirm you wish to delete dentist %s %s %s'#13#10 +
//                '                   Select Yes to proceed.',
                [PString(PME(3,DataInd))^, PString(PME(1,DataInd))^, PString(PME(2,DataInd))^] ),
        mtConfirmation, [mbYes,mbNo] ) then
    begin
      K_CMEDAccess.EDASASetOneProviderInfo( ProvSID, @CMSAProviderDBData, TRUE );
      Exit;
    end;
  end; // with K_CMEDAccess.ProvidersInfo.R do
  // Set Mark Provider as deleted Flag and Unlock
  K_CMEDAccess.EDASASetClearMarkProviderAsDel( ProvSID, '1' );

  // Remove Provider from ProviderInfo
  DeleteCurProviderInfo();

  N_Dump1Str( 'K_FCMSASelectProv.aDeleteProvider fin ID=' + DelProvSID );

end; // procedure TK_FormCMSASelectProvider.aDeleteProviderExecute

//***************************** TK_FormCMSASelectProvider.aRestoreProviderExecute ***
// Restore Deleted Patient Action Execute
//
procedure TK_FormCMSASelectProvider.aRestoreProviderExecute(Sender: TObject);
var
  CMSAProviderDBData : TK_CMSAProviderDBData;
  DelProvFlag : Boolean;
begin
  if ProvSID = '' then Exit; // precaution

  N_Dump1Str( 'K_FCMSASelectProv.aRestoreProvider start ID=' + ProvSID );

  DelProvFlag := K_edOK <> K_CMEDAccess.EDASAGetOneProviderInfo( ProvSID, @CMSAProviderDBData, [K_cmsagiLockOnly] );

  if DelProvFlag then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelProv7.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This dentist has been already deleted by other user. Press OK to continue.',
                       mtWarning, [mbOK] );
  end
  else
  if CMSAProviderDBData.AUIsLocked then
    // Clear Mark Provider as deleted flag and unlock
    K_CMEDAccess.EDASASetClearMarkProviderAsDel( ProvSID, '0' )
  else
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelProv8.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This dentist is controled by other user now. Press OK to continue.',
                       mtWarning, [mbOK] );
    Exit;
  end;
  // Remove Provider from ProviderInfo
  DeleteCurProviderInfo();

  ActiveControl := BtCancel;

  N_Dump1Str( 'K_FCMSASelectProv.aRestoreProvider fin ID=' + DelProvSID );

end; // procedure TK_FormCMSASelectProvider.aRestoreProviderExecute

//***************************** TK_FormCMSASelectProvider.aDeleteProviderForeverExecute ***
// Delete Patient forever Action Execute
//
procedure TK_FormCMSASelectProvider.aDeleteProviderForeverExecute(
  Sender: TObject);
var
  CMSAProviderDBData : TK_CMSAProviderDBData;
  DataInd : Integer;
  DelProvFlag : Boolean;
begin
  if ProvSID = '' then Exit; // precaution

  N_Dump1Str( 'K_FCMSASelectProv.aDeleteProviderForever start ID=' + ProvSID );
  DelProvFlag := K_edOK <> K_CMEDAccess.EDASAGetOneProviderInfo( ProvSID, @CMSAProviderDBData, [K_cmsagiLockOnly] );

  if DelProvFlag then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelProv7.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This dentist has been already deleted by other user. Press OK to continue.',
                       mtWarning, [mbOK] );
  end
  else
  if CMSAProviderDBData.AUIsLocked then
  begin
    if CMSAProviderDBData.AUDBFlags = 1 then
    begin
      // Delete Forever
//      DataInd := CmBProviders.Itemindex + 1;
      with CmBProviders do
        DataInd := Integer(Items.Objects[ItemIndex]);
      with K_CMEDAccess, ProvidersInfo.R do
      begin
        if mrYes <> K_CMShowMessageDlg(
            format( K_CML1Form.LLLSelProv9.Caption + #13#10 +
                    '          ' + K_CML1Form.LLLActProceed1.Caption + ' ' + K_CML1Form.LLLPressYesToProceed.Caption,
//                  'Please confirm you wish to permanently delete dentist %s %s %s'#13#10 +
//                  '          This action is irreversible. Select Yes to proceed.',
                    [PString(PME(3,DataInd))^,
                     PString(PME(1,DataInd))^,
                     PString(PME(2,DataInd))^] ),
            mtConfirmation, [mbYes,mbNo] ) then
        begin
         // Unlock and Exit
          EDASASetOneProviderInfo( ProvSID, @CMSAProviderDBData, TRUE );
          Exit;
        end;
        // Delete code should be placed here
        EDASADelProvider( ProvSID );
      end;
    end
    else
    begin
      K_CMShowMessageDlg( K_CML1Form.LLLSelProv10.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//      'This dentist has been already restored by other user. Press OK to continue.',
                         mtWarning, [mbOK] );
      // Unlock
      K_CMEDAccess.EDASASetOneProviderInfo( ProvSID, @CMSAProviderDBData, TRUE );
    end
  end
  else
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelProv8.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This dentist is controled by other user now. Press OK to continue.',
                       mtWarning, [mbOK] );
    Exit;
  end;

  // Remove Provider from ProvidersInfo
  DeleteCurProviderInfo();

  ActiveControl := BtCancel;

  N_Dump1Str( 'K_FCMSASelectProv.aDeletePatientForever fin ID=' + DelProvSID );
//
end; // procedure TK_FormCMSASelectProvider.aDeleteProviderForeverExecute

//***************************** TK_FormCMSASelectProvider.GetProviderData ***
// Get Patients Data
//
function TK_FormCMSASelectProvider.GetProviderData( APCMSAProviderDBData : TK_PCMSAProviderDBData; ALockOnly : Boolean ) : Boolean;
var
  GIFlags : TK_CMSAGetInfoFlags;
begin
  GIFlags := [];
  if ALockOnly then
    GIFlags := [K_cmsagiLockOnly];

  Result := K_edOK = K_CMEDAccess.EDASAGetOneProviderInfo( ProvSID, APCMSAProviderDBData, GIFlags );
  Result := Result and (APCMSAProviderDBData.AUDBFlags = 0);
  if Result then Exit;
  // Show Warning
  K_CMShowMessageDlg( K_CML1Form.LLLSelProv7.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//  'This dentist has been already deleted by other user. Press OK to continue.',
                       mtWarning, [mbOK] );

  // Remove Provider from ProvidersInfo
  DeleteCurProviderInfo();

end; // procedure TK_FormCMSASelectProvider.GetProviderData


//***************************** TK_FormCMSASelectProvider.DeleteCurProviderInfo ***
// Delete Current Patient Info
//
procedure TK_FormCMSASelectProvider.DeleteCurProviderInfo();
begin
  // Rebuild Patient View
  DelProvSID := ProvSID;
  ProvSID := '';

  // Remove Provider from ProvidersInfo
  with K_CMEDAccess, CmBProviders do
    ProvidersInfo.R.DeleteRows( Integer(Items.Objects[ItemIndex]) );

  RebuildProvidersListView();

  CmBProvidersChange(CmBProviders);

end; // procedure TK_FormCMSASelectProvider.DeleteCurProviderInfo


//******************************* TK_FormCMSASelectProvider.CmBProvidersChange ***
// CmBProviders Combobox OnChage Handler
//
procedure TK_FormCMSASelectProvider.CmBProvidersChange(Sender: TObject);
var
  SkipEditData : Boolean;
  Ind : Integer;
begin
  with CmBProviders, K_CMEDAccess, ProvidersInfo do
  begin
    Ind := 0;
    if ItemIndex >= 0 then
    begin
      Ind := Integer(Items.Objects[ItemIndex]);
      ProvSID := PString(R.PME(0,Ind))^;
    end;

    aModifyProvider.Enabled := ItemIndex <> -1;
    SkipEditData := (K_CMStandaloneMode = K_cmsaLink) or
                    ((K_CMStandaloneMode = K_cmsaHybrid) and  // not (Synchronized Provider in Hybrid StandaloneMode
                     (PString(R.PME(5,Ind))^ = '1'));
    aModifyProvider.Caption := K_CML1Form.LLLSADialogs7.Caption; // '&Modify';
    if SkipEditData then
      aModifyProvider.Caption := K_CML1Form.LLLSADialogs6.Caption; // '&Details';

    aRestoreProvider.Enabled := aModifyProvider.Enabled and
                                not SkipEditData;
    aDeleteProvider.Enabled := aRestoreProvider.Enabled and
                               (Items.Count > 1)        and
                               not WEBAccountOnly;
    aDeleteProviderForever.Enabled := aRestoreProvider.Enabled and
                                      K_CMGAModeFlag;
  end;
end; // procedure TK_FormCMSASelectProvider.CmBProvidersChange

//******************************* TK_FormCMSASelectProvider.SetCurProviderSyncState ***
// Set Current Provider Synchronized to PMS State
//
procedure TK_FormCMSASelectProvider.SetCurProviderSyncState;
var
  Ind : Integer;
begin
  // Set Synchronized State to ProvidersInfo
  with CmBProviders, K_CMEDAccess, ProvidersInfo.R do
  begin
    Ind := Integer(Items.Objects[ItemIndex]);
    PString(PME(5, Ind))^ := '1';
  end;
  // Change Controls View
  CmBProvidersChange(CmBProviders);

end; // procedure TK_FormCMSASelectProvider.SetCurProviderSyncState;

end.
