unit K_FCMReports1;

{$R-}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls, ComCtrls;

type
  TK_FormCMReports1 = class(TN_BaseForm)
    GBDates: TGroupBox;
    LbFrom: TLabel;
    LbTo: TLabel;
    DTPFrom: TDateTimePicker;
    DTPTo: TDateTimePicker;
    GBActions: TGroupBox;
    ChBAllActs: TCheckBox;
    ChBObjCreate: TCheckBox;
    ChBModify: TCheckBox;
    ChBDelete: TCheckBox;
    ChBExport: TCheckBox;
    ChBPrint: TCheckBox;
    ChBEmail: TCheckBox;
    ChBCurPat: TCheckBox;
    CmBProviders: TComboBox;
    LbProviders: TLabel;
    LbLocations: TLabel;
    CmBLocations: TComboBox;
    LbEdSlideID: TLabeledEdit;
    BtRun: TButton;
    BtExit: TButton;
    GBSActions: TGroupBox;
    ChBImportAC: TCheckBox;
    ChBUndoImportAC: TCheckBox;
    ChBCMSSettings: TCheckBox;
    ChBCaptureDevice: TCheckBox;
    ChBAdvancedFilter: TCheckBox;
    ChBArchRest: TCheckBox;
    cbRadiologyLog: TCheckBox;
    procedure BtRunClick(Sender: TObject);
    procedure ChBAllActsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbRadiologyLogClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
  end;

var
  K_FormCMReports1: TK_FormCMReports1;

procedure K_CMReportsDlg( );

implementation

{$R *.dfm}
uses DB,
  N_Types, N_Lib1,
  K_CLib0, K_CM0, K_FCMReportShow, K_Script1, K_FEText, K_CML1F;

{ TK_FormCMReports }

procedure  K_CMReportsDlg( );
begin

  if not K_CMDemoModeFlag then
  begin
// This code is not actual now because D4W put to link only single provider info
//    if not K_CMD4WAppRunByClient then
//      K_CMEDAccess.EDASAGetProvidersInfo(FALSE);
    K_CMEDAccess.EDASAGetProvidersInfo(FALSE);
    K_CMEDAccess.EDASAGetLocationsInfo(FALSE);
  end;

  with TK_FormCMReports1.Create(Application) do
  begin
//    BaseFormInit ( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    ShowModal;
  end;

end;

//********************************************** TK_FormCMReports1.FormShow ***
// FormShow Handler
//
procedure TK_FormCMReports1.FormShow(Sender: TObject);
var
  ObjsInfo : TK_RArray;
  InfoList : TStrings;
  i, ObjID, CurInd : Integer;

begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    InfoList :=  CmBProviders.Items;
    InfoList.Clear;
    InfoList.AddObject( 'All', TObject(-1) );
    if ProvidersInfo <> nil then
    begin
      ObjsInfo := ProvidersInfo.R;
      for i := 1 to ObjsInfo.ARowCount - 1 do
      begin
        ObjID := StrToIntDef( PString(ObjsInfo.PME(0, i))^, -1 );
        if (ObjID < 0) and (ObjID > -100) then Continue; // precaution
        InfoList.AddObject( K_CMGetProviderDetails( ObjID ), TObject(ObjID) );
      end;
    end;
    CmBProviders.ItemIndex := 0;

    InfoList := CmBLocations.Items;
    InfoList.Clear;
    InfoList.AddObject( 'All', TObject(-1) );
    CurInd := 0;
    if LocationsInfo <> nil then
    begin
      ObjsInfo := LocationsInfo.R;
      for i := 1 to ObjsInfo.ARowCount - 1 do
      begin
        ObjID := StrToIntDef( PString(ObjsInfo.PME(0, i))^, -1 );
        if (ObjID < 0) and (ObjID > -100) then Continue; // precaution
        if ObjID = CurLocID then
          CurInd := i;
        InfoList.AddObject( K_CMGetLocationDetails( ObjID ), TObject(ObjID) );
      end;
    end;
    CmBLocations.ItemIndex := CurInd;
  end;

end; // TK_FormCMReports1.FormShow

//******************************************** TK_FormCMReports1.BtRunClick ***
// BtFailures Click Handler
//
//  Resulting Strings Matrix according to Params is prepared
//  And Dialog with Rusulting Data is shown
//
procedure TK_FormCMReports1.BtRunClick(Sender: TObject);
var
  ReportDetailes : string;
  RepAtttrs : TK_CMHistRepAtttrs;
begin

  if K_CMEDDBVersion < 13 then
  begin
    K_CMShowMessageDlg( //sysout
        ' Is not implemented now ', mtInformation );
    Exit;
  end;

  RepAtttrs.HRFlags := [];
  RepAtttrs.HRStartTS := Int(DTPFrom.DateTime);
  RepAtttrs.HRFinTS := Int(DTPTO.DateTime + 1) - 1/(24*3600*1000);
  if ChBAllActs.Checked then
    Include( RepAtttrs.HRFlags, K_srfAllSlideActs );
  if ChBObjCreate.Checked then
    Include( RepAtttrs.HRFlags, K_srfSlideCreate );
  if ChBDelete.Checked then
    Include( RepAtttrs.HRFlags, K_srfSlideDelete );
  if ChBModify.Checked then
    Include( RepAtttrs.HRFlags, K_srfSlideModify );
  if ChBExport.Checked then
    Include( RepAtttrs.HRFlags, K_srfSlideExport );
  if ChBPrint.Checked then
    Include( RepAtttrs.HRFlags, K_srfSlidePrint );
  if ChBEmail.Checked then
    Include( RepAtttrs.HRFlags, K_srfSlideEmail );
  if ChBArchRest.Checked then
    Include( RepAtttrs.HRFlags, K_srfSlideArchRest );
  if ChBImportAC.Checked then
    Include( RepAtttrs.HRFlags, K_srfSAImportAC );
  if ChBUndoImportAC.Checked then
    Include( RepAtttrs.HRFlags, K_srfSAUndoImportAC );
  if ChBCMSSettings.Checked then
    Include( RepAtttrs.HRFlags, K_srfSACMSSetup );
  if ChBCaptureDevice.Checked then
    Include( RepAtttrs.HRFlags, K_srfSACaptDevSetup );
  if ChBAdvancedFilter.Checked then
    Include( RepAtttrs.HRFlags, K_srfSAAFilterSetup );
  if cbRadiologyLog.Checked then
    Include(RepAtttrs.HRFlags, A_srfRadiologyLog);

  RepAtttrs.HRPatID := '';
  if ChBCurPat.Checked then
    RepAtttrs.HRPatID := IntToStr(K_CMEDAccess.CurPatID);

  RepAtttrs.HRProvID := '';
  if CmBProviders.ItemIndex > 0 then
    with CmBProviders do
      RepAtttrs.HRProvID := IntToStr(Integer(Items.Objects[ItemIndex]));

  RepAtttrs.HRLocID := '';
  if CmBLocations.ItemIndex > 0 then
    with CmBLocations do
      RepAtttrs.HRLocID := IntToStr(Integer(Items.Objects[ItemIndex]));

  RepAtttrs.HRSlideID := '';
  if (LbEdSlideID.Text <> '') and
     (StrToIntDef( LbEdSlideID.Text, -1 ) > 0) then
    RepAtttrs.HRSlideID := LbEdSlideID.Text;

  with TK_FormCMReportShow.Create(Application) do
  begin
//    BaseFormInit ( nil, 'K_FormCMReportShow' );
    BaseFormInit( nil, 'K_FormCMReportShow', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    K_CMHistReportCreate( ReportDataSMatr, RepAtttrs );
//    ReportDetailes := format( K_CML1Form.LLLReport6.Caption,
//    // 'Report from %s to %s'
//          [K_DateTimeToStr( RepAtttrs.HRStartTS, 'yyyy-mm-dd hh:nn:ss AM/PM' ),
//           K_DateTimeToStr( RepAtttrs.HRFinTS, 'yyyy-mm-dd hh:nn:ss AM/PM' )] );
{
         'Report from ' +
         K_DateTimeToStr( RepAtttrs.HRStartTS, 'yyyy-mm-dd hh:nn:ss AM/PM' ) +
         ' to ' + K_DateTimeToStr( RepAtttrs.HRFinTS, 'yyyy-mm-dd hh:nn:ss AM/PM' );
}
    PrepareRAFrameByDataSMatr( ReportDetailes );
    FrRAEdit.RAFCArray[0].TextPos := Ord(K_ppCenter);
    FrRAEdit.RAFCArray[1].TextPos := Ord(K_ppCenter);
    FrRAEdit.RAFCArray[3].TextPos := Ord(K_ppDownRight);
    FrRAEdit.RAFCArray[8].TextPos := Ord(K_ppDownRight);

    ShowModal;
  end;
end; // TK_FormCMReports1.BtRunClick

//************************************** TK_FormCMReports1.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormCMReports1.CurStateToMemIni;
begin
  inherited;
  N_BoolToMemIni( BFSelfName, 'ActAll', ChBAllActs.Checked );
  N_BoolToMemIni( BFSelfName, 'ActCreateObj', ChBObjCreate.Checked );
  N_BoolToMemIni( BFSelfName, 'ActModify', ChBModify.Checked );
  N_BoolToMemIni( BFSelfName, 'ActDelete', ChBDelete.Checked );
  N_BoolToMemIni( BFSelfName, 'ActExport', ChBExport.Checked );
  N_BoolToMemIni( BFSelfName, 'ActExport', ChBExport.Checked );
  N_BoolToMemIni( BFSelfName, 'ActEmail', ChBEmail.Checked );
  N_BoolToMemIni( BFSelfName, 'ActArchRest', ChBArchRest.Checked );
  N_BoolToMemIni( BFSelfName, 'ActCaptDevSetup', ChBCaptureDevice.Checked );
  N_BoolToMemIni( BFSelfName, 'ActCMSSetUp', ChBCMSSettings.Checked );
  N_BoolToMemIni( BFSelfName, 'ActImpAC', ChBImportAC.Checked );
  N_BoolToMemIni( BFSelfName, 'ActUndoImpAC', ChBUndoImportAC.Checked );

  N_BoolToMemIni( BFSelfName, 'CurPat', ChBCurPat.Checked );
  N_DblToMemIni( BFSelfName, 'DTPFrom', '%g', DTPFrom.DateTime );
  N_DblToMemIni( BFSelfName, 'DTPTo', '%g', DTPTo.DateTime );
end; // TK_FormCMReports1.CurStateToMemIni

//************************************** TK_FormCMReports1.MemIniToCurState ***
// Load Self Size and Position from N_Forms section, BFSelfName string
//
procedure TK_FormCMReports1.MemIniToCurState;
begin
  inherited;
  ChBAllActs.Checked := N_MemIniToBool( BFSelfName, 'ActAll', TRUE );
  ChBObjCreate.Checked := N_MemIniToBool( BFSelfName, 'ActCreateObj', FALSE );
  ChBModify.Checked := N_MemIniToBool( BFSelfName, 'ActModify', FALSE );
  ChBDelete.Checked := N_MemIniToBool( BFSelfName, 'ActDelete', FALSE );
  ChBExport.Checked := N_MemIniToBool( BFSelfName, 'ActExport', FALSE );
  ChBPrint.Checked := N_MemIniToBool( BFSelfName, 'ActPrint', FALSE );
  ChBEmail.Checked := N_MemIniToBool( BFSelfName, 'ActEmail', FALSE );
  ChBArchRest.Checked := N_MemIniToBool( BFSelfName, 'ActArchRest', FALSE );
  ChBCaptureDevice.Checked := N_MemIniToBool( BFSelfName, 'ActCaptDevSetup', FALSE );
  ChBCMSSettings.Checked   := N_MemIniToBool( BFSelfName, 'ActCMSSetUp', FALSE );
  ChBImportAC.Checked      := N_MemIniToBool( BFSelfName, 'ActImpAC', FALSE );
  ChBUndoImportAC.Checked  := N_MemIniToBool( BFSelfName, 'ActUndoImpAC', FALSE );
  ChBCurPat.Checked := N_MemIniToBool( BFSelfName, 'CurPat', TRUE );
  DTPFrom.DateTime := N_MemIniToDbl( BFSelfName, 'DTPFrom', Now() - 0.5 );
  DTPTo.DateTime :=   N_MemIniToDbl( BFSelfName, 'DTPTo', Now() + 0.5 );
end; // TK_FormCMReports1.MemIniToCurState


//*************************************** TK_FormCMReports1.ChBAllActsClick ***
// ChBAllActs Click Handler
//
procedure TK_FormCMReports1.cbRadiologyLogClick(Sender: TObject);
begin
  inherited;

  LbEdSlideID.Enabled := not cbRadiologyLog.Checked;

  ChBImportAC.Enabled := not cbRadiologyLog.Checked;
  ChBUndoImportAC.Enabled := not cbRadiologyLog.Checked;
  ChBCMSSettings.Enabled := not cbRadiologyLog.Checked;
  ChBCaptureDevice.Enabled := not cbRadiologyLog.Checked;
  ChBAdvancedFilter.Enabled := not cbRadiologyLog.Checked;
  CmBProviders.Enabled := not cbRadiologyLog.Checked;
  CmBLocations.Enabled := not cbRadiologyLog.Checked;

  ChBAllActs.Enabled := not cbRadiologyLog.Checked;
  ChBObjCreate.Enabled := not cbRadiologyLog.Checked;
  ChBModify.Enabled := not cbRadiologyLog.Checked;
  ChBDelete.Enabled := not cbRadiologyLog.Checked;
  ChBExport.Enabled := not cbRadiologyLog.Checked;
  ChBPrint.Enabled := not cbRadiologyLog.Checked;
  ChBEmail.Enabled := not cbRadiologyLog.Checked;
  ChBArchRest.Enabled := not cbRadiologyLog.Checked;
end;

procedure TK_FormCMReports1.ChBAllActsClick(Sender: TObject);
begin
  ChBObjCreate.Enabled := not ChBAllActs.Checked;
  ChBModify.Enabled := not ChBAllActs.Checked;
  ChBDelete.Enabled := not ChBAllActs.Checked;
  ChBExport.Enabled := not ChBAllActs.Checked;
  ChBPrint.Enabled := not ChBAllActs.Checked;
  ChBEmail.Enabled := not ChBAllActs.Checked;
  ChBArchRest.Enabled := not ChBAllActs.Checked;
end; // TK_FormCMReports1.ChBAllActsClick

end.
