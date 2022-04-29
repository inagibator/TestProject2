unit K_CMUtils;

interface

function K_CMDBRecoveryDlg() : boolean;
function K_CMFSRecovery1Dlg() : boolean;
function K_CMFSRecovery2Dlg() : boolean;
procedure K_CMDeleteSlidesDlg();
procedure K_CMFSAnalysisDlg();
procedure K_CMFSClearDlg();
procedure K_CMFSDumpDlg();


implementation


uses
Forms,
K_CM0, K_FCMDBRecovery, K_FCMFSRecovery1, K_FCMDeleteSlides, K_FCMFSAnalysis,
K_FCMFSAnalysis1, K_FCMFSClear, K_FCMFSDump,  K_FCMFSDump1,
N_Types;


//******************************************************* K_CMDBRecoveryDlg ***
// Launch DB Recovety Utility Dialog
//
//     Parameters
// Result - Returns TRUE if DIalog was started
//
function K_CMDBRecoveryDlg() : boolean;
begin
  Result := K_CMSDBRecoveryMode or K_CMAllPatObjCopyMoveResumeAndWait( 0 );
  if not Result then Exit;
  with TK_FormCMDBRecovery.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal;
  end;
end; // function K_CMDBRecoveryDlg

//****************************************************** K_CMFSRecovery1Dlg ***
// Launch File Storage Recovety Utility Dialog
//
//     Parameters
// Result - Returns TRUE if DIalog was started
//
// Analize File Storage contents given by selecting root folder
//
function K_CMFSRecovery1Dlg() : boolean;
begin
  Result := TRUE;
  with TK_FormCMFSRecovery1.Create( Application ) do
  begin
//    B1.Visible := FALSE;
//    B2.Visible := FALSE;
//    B3.Visible := FALSE;
    UseMarkedAsDeletedFlag := TRUE;
    CheckDateFolderFlag := TRUE;
    CheckPatientFolderFlag := FALSE;
    CheckRecoverFilesDuplicateCheckFlag := TRUE;
    CreateAtributeFilesFlag := FALSE;
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal;
  end;
end; // function K_CMFSRecovery1Dlg

//****************************************************** K_CMFSRecovery2Dlg ***
// Copy Files to Files Storage Utility Dialog
//
//     Parameters
// Result - Returns TRUE if DIalog was started
//
// Analize File Storage contents given by selecting root folder
//
function K_CMFSRecovery2Dlg() : boolean;
begin
  Result := TRUE;
  with TK_FormCMFSRecovery1.Create( Application ) do
  begin
    Caption := 'Copy restored files';
    B1.Visible := FALSE;
    B2.Visible := FALSE;
    B3.Visible := FALSE;
    BtStart.OnClick := B3.OnClick;
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal;
  end;
end; // function K_CMFSRecovery2Dlg

//*************************************************** K_CMUTUnloadDBDataDlg ***
// Delete slides by Slides ID List
//
procedure K_CMDeleteSlidesDlg();
begin

  K_FormCMDeleteSlides := TK_FormCMDeleteSlides.Create(Application);
  with K_FormCMDeleteSlides do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal();
    K_FormCMDeleteSlides := nil;
  end;

end; // K_CMDeleteSlidesDlg

//******************************************************* K_CMFSAnalysisDlg ***
// File Storage Analysis
//
procedure K_CMFSAnalysisDlg();
begin
{
  K_FormCMFSAnalysis := TK_FormCMFSAnalysis.Create(Application);
  with K_FormCMFSAnalysis do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal();
    K_FormCMFSAnalysis := nil;
  end;
}
  K_FormCMFSAnalysis1 := TK_FormCMFSAnalysis1.Create(Application);
  with K_FormCMFSAnalysis1 do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal();
    K_FormCMFSAnalysis1 := nil;
  end;

end; // K_CMFSAnalysisDlg

//********************************************************** K_CMFSClearDlg ***
// File Storage Extra files Clear
//
procedure K_CMFSClearDlg();
begin

  K_FormCMFSClear := TK_FormCMFSClear.Create(Application);
  with K_FormCMFSClear do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal();
    K_FormCMFSClear := nil;
  end;

end; // K_CMFSClearDlg

//*********************************************************** K_CMFSDumpDlg ***
// File Storage Extra files Clear
//
procedure K_CMFSDumpDlg();
begin
{
  K_FormCMFSDump:= TK_FormCMFSDump.Create(Application);
  with K_FormCMFSDump do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal();
    K_FormCMFSDump := nil;
  end;
}
  K_FormCMFSDump1 := TK_FormCMFSDump1.Create(Application);
  with K_FormCMFSDump1 do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal();
    K_FormCMFSDump1 := nil;
  end;

end; // procedure K_CMFSDumpDlg


end.
