unit K_FCMSASelectLoc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, StdCtrls, ActnList, N_Rast1Fr, Buttons,
  K_CM0,
  N_BaseF, N_Types, N_DGrid;

type
  TK_FormCMSASelectLocation = class(TN_BaseForm)
    BtOK: TButton;
    ActionList1: TActionList;
    aAddLocation: TAction;
    aModifyLocation: TAction;
    aDeleteLocation: TAction;
    BtAdd: TButton;
    BtModify: TButton;
    BtDelete: TButton;
    aRestoreLocation: TAction;
    aDeleteLocationForever: TAction;
    CmBLocations: TComboBox;
    BtCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure aAddLocationExecute(Sender: TObject);
    procedure aModifyLocationExecute(Sender: TObject);
    procedure aDeleteLocationExecute(Sender: TObject);
    procedure aRestoreLocationExecute(Sender: TObject);
    procedure aDeleteLocationForeverExecute(Sender: TObject);
    procedure CmBLocationsChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    DelLocSID : string;
    procedure RebuildLocationsListView();
    function  GetLocationData( APCMSALocationDBData : TK_PCMSALocationDBData; ALockOnly : Boolean ) : Boolean;
    procedure DeleteCurLocationInfo();
    procedure SetCurLocationSyncState( );
  public
    { Public declarations }
    LocSID : string;
    SrcLocSID : string;
  end;

var
  K_FormCMSASelectLocation: TK_FormCMSASelectLocation;

function  K_CMSASelectLocationDlg( var ALocSID : string; AShowDelFlag : Boolean ) : Boolean;

implementation

{$R *.dfm}
uses Math,
N_CMMain5F, N_CMResF, N_CM1, N_CM2, N_Comp1, N_Lib0,
K_CLib0, K_Script1, K_VFunc, K_FCMSASetProvData, K_FCMSASetLocData, K_CML1F;

//***************************************************** K_CMSASelectLocationDlg ***
// Set CMS Standalone Patient Data Dialog
//
//     Parameters
// ALocSID - Location ID string
// Result - Returns FALSE if user do not click OK
//
// If source ALocSID value is differed from "", then Location with given ID
// should be highlighted as selected, else no Location should be selected.
// Resulting ALocSID if Result value is TRUE contains Selected Location ID string
//
function  K_CMSASelectLocationDlg( var ALocSID : string; AShowDelFlag : Boolean ) : Boolean;
begin
  with TK_FormCMSASelectLocation.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    LocSID := ALocSID;
    SrcLocSID := ALocSID;
    K_CMEDAccess.EDASAGetLocationsInfo( AShowDelFlag );

    if AShowDelFlag then
    begin
      BtAdd.Action := aRestoreLocation;
      aDeleteLocationForever.Enabled := K_CMGAModeFlag;
      BtModify.Action := aDeleteLocationForever;
      BtDelete.Visible := False;
      BtOK.Visible := False;
      BtCancel.Caption := BtOk.Caption; //'&OK';
    end;

    aAddLocation.Enabled := K_CMStandaloneMode <> K_cmsaLink;
    if not aAddLocation.Enabled then
       aModifyLocation.Caption := K_CML1Form.LLLSADialogs6.Caption; // '&Details';

    N_Dump1Str( 'SelectLocationDlg Start ID=' + ALocSID );
    Result := ShowModal() = mrOK;
    K_CMEDAccess.EDASAGetLocationsInfo( FALSE );
    if Result then
      ALocSID := LocSID;
    N_Dump1Str( 'SelectLocationDlg Fin ID=' + ALocSID );
  end;
end; // function K_CMSASelectLocationDlg

//******************************* TK_FormCMSASelectLocation.FormShow ***
// Form Show Handler
//
procedure TK_FormCMSASelectLocation.FormShow(Sender: TObject);
begin
  inherited;

  aModifyLocation.Enabled := FALSE;
  aDeleteLocation.Enabled := FALSE;
  aRestoreLocation.Enabled := FALSE;
  aDeleteLocationForever.Enabled := FALSE;

  RebuildLocationsListView();
  Constraints.MaxHeight := Height;
  Constraints.MinHeight := Height;

end; // procedure TK_FormCMSASelectLocation.FormShow

//***************************** TK_FormCMSASelectLocation.RebuildLocationsListView ***
// Rebuild Patients View
//
procedure TK_FormCMSASelectLocation.RebuildLocationsListView;
begin
  with CmBLocations do
  begin
    ItemIndex := K_CMSAFillLocationsList( Items, LocSID );
    CmBLocationsChange(nil);
  end;
end; // procedure TK_FormCMSASelectLocation.RebuildLocationsListView;

//***************************** TK_FormCMSASelectLocation.aAddLocationExecute ***
// Add New Patient Action Execute
//
procedure TK_FormCMSASelectLocation.aAddLocationExecute(Sender: TObject);
var
  CMSALocationDBData : TK_CMSALocationDBData;
begin
  N_Dump1Str( 'K_FCMSASelectProv.aAddLocation start' );

  LocSID := '';

  if K_CMEDDBVersion < 33 then
  begin
    if not K_CMSASetLocationNameDlg( CMSALocationDBData.ALName,
      K_CML1Form.LLLSelLoc13.Caption ) then Exit; // 'New Practice'
  end
  else
    if not K_CMSASetLocationDataDlg( LocSID, @CMSALocationDBData ) then Exit; // 'New Practice'


  K_CMEDAccess.EDASASetOneLocationInfo( LocSID, @CMSALocationDBData, FALSE );

  RebuildLocationsListView();
  N_Dump1Str( 'K_FCMSASelectLoc.aAddLocation fin ID=' + LocSID );
end; // procedure TK_FormCMSASelectLocation.aAddLocationExecute

//***************************** TK_FormCMSASelectLocation.aModifyLocationExecute ***
// Modify Selected Patient Action Execute
//
procedure TK_FormCMSASelectLocation.aModifyLocationExecute(Sender: TObject);
var
  CMSALocationDBData : TK_CMSALocationDBData;
  SkipFieldsSet : Boolean;
  WStr : string;
begin

  if LocSID = '' then Exit; // precaution
  N_Dump1Str( 'K_FCMSASelectLoc.aModifyLocation start ID=' + LocSID );
  if not GetLocationData( @CMSALocationDBData, FALSE ) then Exit;

  if CMSALocationDBData.ALIsPMSSync and
     (K_CMStandaloneMode = K_cmsaHybrid) and
     aDeleteLocation.Enabled then
  begin
  // Rebuild Interface if start modify object
  // which was unsynchronized and now is detected as synchronized to PMS
    SetCurLocationSyncState( );
  end;


  // Free Lock if ReadOnly Mode
  if CMSALocationDBData.ALIsLocked and
     ( (K_CMStandaloneMode = K_cmsaLink) or
       ( CMSALocationDBData.ALIsPMSSync and
         (K_CMStandaloneMode = K_cmsaHybrid) ) ) then
  begin
  // Clear Location Lock
    K_CMEDAccess.EDASASetOneLocationInfo( LocSID, nil, TRUE );
    CMSALocationDBData.ALIsLocked := FALSE;
  end;

  if (aModifyLocation.Caption <> K_CML1Form.LLLSADialogs6.Caption) and
     not CMSALocationDBData.ALIsLocked then
    K_CMShowMessageDlg( K_CML1Form.LLLSelLoc1.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//      'Selected practice is now being edited by other user. Press OK to continue.',
                         mtWarning, [mbOK] );

  if K_CMEDDBVersion < 33 then
  begin
    // Change Locked State to Correct Actions after editing
    WStr := K_CML1Form.LLLSelLoc11.Caption; // 'Modify Practice';
    if not CMSALocationDBData.ALIsLocked then
      WStr := K_CML1Form.LLLSelLoc12.Caption;// 'Practice details';

    SkipFieldsSet := not K_CMSASetLocationNameDlg( CMSALocationDBData.ALName, WStr, not CMSALocationDBData.ALIsLocked );
  end
  else
    SkipFieldsSet := not K_CMSASetLocationDataDlg( LocSID, @CMSALocationDBData ); // 'Modify Practice'

  K_CMEDAccess.EDASASetOneLocationInfo( LocSID, @CMSALocationDBData, SkipFieldsSet );

  RebuildLocationsListView();

  N_Dump1Str( 'K_FCMSASelectLoc.aModifyLocation fin ID=' + LocSID );
end; // procedure TK_FormCMSASelectLocation.aModifyLocationExecute

//***************************** TK_FormCMSASelectLocation.aDeleteLocationExecute ***
// Delete Selected Patient Action Execute
//
procedure TK_FormCMSASelectLocation.aDeleteLocationExecute(Sender: TObject);
var
  CMSALocationDBData : TK_CMSALocationDBData;
  DataInd : Integer;
begin
  if LocSID = '' then Exit; // precaution
  N_Dump1Str( 'K_FCMSASelectLoc.aDeleteLocation start ID=' + LocSID );
  if not GetLocationData( @CMSALocationDBData, TRUE ) then Exit;

  if CMSALocationDBData.ALIsPMSSync and
     (K_CMStandaloneMode = K_cmsaHybrid) then
  begin
    K_CMEDAccess.EDASASetOneLocationInfo( LocSID, nil, TRUE );
    SetCurLocationSyncState();
    K_CMShowMessageDlg( K_CML1Form.LLLSelLoc2.Caption,
//      'This practice couldn''t be deleted. It is linked to corresponding Practice Management System object.',
                           mtWarning, [mbOK] );
    Exit;
  end;

  if not CMSALocationDBData.ALIsLocked then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelLoc3.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This practice is now being edited by other user. Press OK to continue.',
                         mtWarning, [mbOK] );
    Exit;
  end;

  DataInd := CmBLocations.ItemIndex + 1;

  with K_CMEDAccess.LocationsInfo.R do
  if mrYes <> K_CMShowMessageDlg(
      format(  K_CML1Form.LLLSelLoc4.Caption +
               #13#10'                        '+
               K_CML1Form.LLLPressYesToProceed.Caption,
//              'Please confirm you wish to delete "%s" Dental Practice'#13#10+
//              '                        Select Yes to proceed.',
              [PString(PME(1,DataInd))^] ),
      mtConfirmation, [mbYes,mbNo] ) then
  begin
    K_CMEDAccess.EDASASetOneLocationInfo( LocSID, @CMSALocationDBData, TRUE );
    Exit;
  end;
  // Set Mark Location as deleted Flag and Unlock
  K_CMEDAccess.EDASASetClearMarkLocatonAsDel( LocSID, '1' );

  // Remove Location from LocationInfo
  DeleteCurLocationInfo();

  N_Dump1Str( 'K_FCMSASelectLoc.aDeleteLocation fin ID=' + DelLocSID );
end; // procedure TK_FormCMSASelectLocation.aDeleteLocationExecute

//***************************** TK_FormCMSASelectLocation.aRestoreLocationExecute ***
// Restore Deleted Patient Action Execute
//
procedure TK_FormCMSASelectLocation.aRestoreLocationExecute(Sender: TObject);
var
  CMSALocationDBData : TK_CMSALocationDBData;
  DelLocFlag : Boolean;
begin
  if LocSID = '' then Exit; // precaution

  N_Dump1Str( 'K_FCMSASelectLoc.aRestoreLocation start ID=' + LocSID );
  DelLocFlag := K_edOK <> K_CMEDAccess.EDASAGetOneLocationInfo( LocSID, @CMSALocationDBData, [K_cmsagiLockOnly] );

  if DelLocFlag then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelLoc5.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This practice has been already deleted by other user. Press OK to continue.',
                       mtWarning, [mbOK] );
  end
  else
  if CMSALocationDBData.ALIsLocked then
    // Clear Mark Location as deleted flag and unlock
    K_CMEDAccess.EDASASetClearMarkLocatonAsDel( LocSID, '0' )
  else
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelLoc6.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This practice is controled by other user now. Press OK to continue.',
                       mtWarning, [mbOK] );
    Exit;
  end;
  // Remove Location from LocationInfo
  DeleteCurLocationInfo();
  N_Dump1Str( 'K_FCMSASelectLoc.aRestoreLocation fin ID=' + DelLocSID );
end; // procedure TK_FormCMSASelectLocation.aRestoreLocationExecute

//***************************** TK_FormCMSASelectLocation.aDeleteLocationForeverExecute ***
// Delete Patient forever Action Execute
//
procedure TK_FormCMSASelectLocation.aDeleteLocationForeverExecute(
  Sender: TObject);
var
  CMSALocationDBData : TK_CMSALocationDBData;
  DataInd : Integer;
  DelLocFlag : Boolean;
begin
  if LocSID = '' then Exit; // precaution

  N_Dump1Str( 'K_FCMSASelectLoc.aDeleteLocationForever start ID=' + LocSID );

  DelLocFlag := K_edOK <> K_CMEDAccess.EDASAGetOneLocationInfo( LocSID, @CMSALocationDBData, [K_cmsagiLockOnly] );

  if DelLocFlag then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelLoc5.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This practice has been already deleted by other user. Press OK to continue.',
                       mtWarning, [mbOK] );
  end
  else
  if CMSALocationDBData.ALIsLocked then
  begin
    if CMSALocationDBData.ALDBFlags = 1 then
    begin
      // Delete Forever
      DataInd := CmBLocations.Itemindex + 1;
      with K_CMEDAccess, LocationsInfo.R do
      begin
        if mrYes <> K_CMShowMessageDlg( format(
              K_CML1Form.LLLSelLoc7.Caption + #13#10 +
              '            ' + K_CML1Form.LLLActProceed1.Caption + ' ' + K_CML1Form.LLLPressYesToProceed.Caption,
//             'Please confirm you wish to permanently delete "%s" Dental Practice'#13#10 +
//             '            This action is irreversible. Select Yes to proceed.',
              [PString(PME(1,DataInd))^] ),
            mtConfirmation, [mbYes,mbNo] ) then
        begin
         // Unlock and Exit
          EDASASetOneLocationInfo( LocSID, @CMSALocationDBData, TRUE );
          Exit;
        end;
        // Delete code should be placed here
        EDASADelLocation( LocSID );
      end;
    end
    else
    begin
      K_CMShowMessageDlg( K_CML1Form.LLLSelLoc8.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//        'This practice has been already restored by other user. Press OK to continue.',
                       mtWarning, [mbOK] );
      // Unlock
      K_CMEDAccess.EDASASetOneLocationInfo( LocSID, @CMSALocationDBData, TRUE );
    end
  end
  else
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelLoc6.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This practice is controled by other user now. Press OK to continue.',
                       mtWarning, [mbOK] );
    Exit;
  end;

  // Remove Location from LocationsInfo
  DeleteCurLocationInfo();
  N_Dump1Str( 'K_FCMSASelectLoc.aDeleteLocationForever fin ID=' + DelLocSID );
//
end; // procedure TK_FormCMSASelectLocation.aDeleteLocationForeverExecute

//***************************** TK_FormCMSASelectLocation.GetLocationData ***
// Get Patients Data
//
function TK_FormCMSASelectLocation.GetLocationData( APCMSALocationDBData : TK_PCMSALocationDBData; ALockOnly : Boolean ) : Boolean;
var
  GIFlags : TK_CMSAGetInfoFlags;
begin
  GIFlags := [];
  if ALockOnly then
    GIFlags := [K_cmsagiLockOnly];

  Result := K_edOK = K_CMEDAccess.EDASAGetOneLocationInfo( LocSID, APCMSALocationDBData, GIFlags );
  Result := Result and (APCMSALocationDBData.ALDBFlags = 0);
  if Result then Exit;
  // Show Warning
  K_CMShowMessageDlg( K_CML1Form.LLLSelLoc5.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//  'This practice has been already deleted by other user. Press OK to continue.',
                       mtWarning, [mbOK] );

  // Remove Location from LocationsInfo
  DeleteCurLocationInfo();

end; // procedure TK_FormCMSASelectLocation.GetLocationData


//***************************** TK_FormCMSASelectLocation.DeleteCurLocationInfo ***
// Delete Current Patient Info
//
procedure TK_FormCMSASelectLocation.DeleteCurLocationInfo();
begin
  // Rebuild Patient View
  DelLocSID := LocSID;
  LocSID := '';

  // Remove Location from LocationsInfo
  with K_CMEDAccess do
    LocationsInfo.R.DeleteRows( CmBLocations.ItemIndex + 1 );


  RebuildLocationsListView();

  with CmBLocations do
    if ItemIndex = -1 then ItemIndex := 0;

  CmBLocationsChange(nil);

end; // procedure TK_FormCMSASelectLocation.DeleteCurLocationInfo


//******************************* TK_FormCMSASelectLocation.CmBLocationsChange ***
// CmBProviders Combobox OnChage Handler
//
procedure TK_FormCMSASelectLocation.CmBLocationsChange(Sender: TObject);
var
  Ind : Integer;
  SkipEditData : Boolean;
begin
  with CmBLocations, K_CMEDAccess, LocationsInfo do
  begin
    Ind := ItemIndex + 1;
    if Ind > 0 then
      LocSID := PString(R.PME(0,Ind))^;
{
    aModifyLocation.Enabled := (ItemIndex <> -1) and                    // Location is selected
                               (K_CMStandaloneMode <> K_cmsaLink) and     // StandaloneMode <> Linked
                               ( (K_CMStandaloneMode <> K_cmsaHybrid) or  // not (Synchronized Location in Hybrid StandaloneMode
                                 (PString(R.PME(2,Ind))^ <> '1') );
    aDeleteLocation.Enabled := aModifyLocation.Enabled and (Items.Count > 1);
    aRestoreLocation.Enabled := aModifyLocation.Enabled;
    aDeleteLocationForever.Enabled := aModifyLocation.Enabled and K_CMGAModeFlag;
}
    aModifyLocation.Enabled := ItemIndex <> -1;
    SkipEditData := (K_CMStandaloneMode = K_cmsaLink) or
                    ((K_CMStandaloneMode = K_cmsaHybrid) and  // not (Synchronized Provider in Hybrid StandaloneMode
                     (PString(R.PME(2,Ind))^ = '1'));
    aModifyLocation.Caption := K_CML1Form.LLLSADialogs7.Caption; // '&Modify';
    if SkipEditData then
      aModifyLocation.Caption := K_CML1Form.LLLSADialogs6.Caption; // '&Details';

    aRestoreLocation.Enabled := aModifyLocation.Enabled and
                                not SkipEditData;
    aDeleteLocation.Enabled := aRestoreLocation.Enabled and
                               (Items.Count > 1);
    aDeleteLocationForever.Enabled := aRestoreLocation.Enabled and
                                      K_CMGAModeFlag;
  end;
end; // procedure TK_FormCMSASelectLocation.CmBLocationsChange

//******************************* TK_FormCMSASelectLocation.FormCloseQuery ***
// FormCloseQuery Handler
//
procedure TK_FormCMSASelectLocation.FormCloseQuery( Sender: TObject;
                                                    var CanClose: Boolean );
var
  CurLocInd : Integer;
begin
  // mrOK and not Show Mark as Deleted
  if ModalResult = mrOK then
  begin
    CanClose := LocSID <> '';
    if not CanClose then
      K_CMShowMessageDlg( K_CML1Form.LLLSelLoc9.Caption,
//      'Dental Practice is not selected. Select Practice before exit.',
                         mtWarning, [mbOK] );
  end
  else
  if BtAdd.Action = aAddLocation then
  begin
    with K_CMEDAccess, LocationsInfo.R do
    begin
      CurLocInd := K_IndexOfStringInRArray( SrcLocSID,
                                            PME( 0, 1),
                                            ARowCount - 1,
                                            ElemSize * AColCount );
      CanClose := CurLocInd >= 0;
    end;

    if not CanClose then
      K_CMShowMessageDlg( K_CML1Form.LLLSelLoc10.Caption,
//      'Current Media Suite Practice was deleted. Select new current Practice.',
                           mtWarning, [mbOK] )
  end;
end; // procedure TK_FormCMSASelectLocation.FormCloseQuery

//******************************* TK_FormCMSASelectLocation.SetCurLocationSyncState ***
// Set Current Location Synchronized State
//
procedure TK_FormCMSASelectLocation.SetCurLocationSyncState;
var
  Ind, FCol : Integer;
begin
  // Set Synchronized State to ProvidersInfo
  with CmBLocations, K_CMEDAccess, LocationsInfo.R do
  begin
    Ind := ItemIndex + 1;
    FCol := EDAArchUDTabFieldIndex( 'LocationSync', LocationsInfo );
    PString(PME(FCol, Ind))^ := '1';
  end;
  // Change Controls View
  CmBLocationsChange(CmBLocations);

end; // procedure TK_FormCMSASelectLocation.SetCurLocationSyncState;

end.
