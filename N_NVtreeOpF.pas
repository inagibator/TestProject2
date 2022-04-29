unit N_NVtreeOpF;
// NVTree Options Form (Options for NVTreeFrame and NVTreeForm)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  N_Types, N_Lib1, N_BaseF, ComCtrls, StdCtrls, N_NVTreeF, CheckLst, ExtCtrls;

type TN_NVtreeOptionsForm = class( TN_BaseForm )
    bnOK: TButton;
    bnCancel: TButton;
    bnApply: TButton;
    PageControl1: TPageControl;
    tsFlags1: TTabSheet;
    cbAutoIncCSCodes: TCheckBox;
    cbUncondDelete: TCheckBox;
    cbSkipAutoRefsToUDVect: TCheckBox;
    cbNewEdWindow: TCheckBox;
    cbAddUObjSysInfo: TCheckBox;
    cbStayOnTop: TCheckBox;
    cbHideFileNameFrame: TCheckBox;
    cbNotUseRefInds: TCheckBox;
    tsGetUObjFrMenu: TTabSheet;
    clbUObjFrMenu: TCheckListBox;
    cbAutoViewReport: TCheckBox;
    cbAliasesInPaths: TCheckBox;
    tsFlags2: TTabSheet;
    cbVeiwFieldsAsTextAll: TCheckBox;
    tsView: TTabSheet;
    rgViewMode: TRadioGroup;

    procedure bnApplyClick  ( Sender: TObject );
    procedure bnCancelClick ( Sender: TObject );
    procedure bnOKClick     ( Sender: TObject );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  public
    NVTreeForm: TN_NVTreeForm;
    procedure FillFormFields   ();
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_NVTreeOptionsForm = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

function N_GetNVTreeOptionsForm( ANVTreeForm: TN_NVTreeForm;
                                  AOwner: TN_BaseForm ): TN_NVtreeOptionsForm;

var
    N_NVtreeOptionsForm: TN_NVtreeOptionsForm;

implementation
uses
  K_UDT1, K_UDConst,
  N_ME1, N_UObjFr;
{$R *.dfm}

//****************  TN_NVTreeOptionsForm class handlers  ******************

procedure TN_NVtreeOptionsForm.bnApplyClick( Sender: TObject );
// Set NVTreeForm, NVTreeForm.NVTreeFrame and some Global Flags by Self Fields
begin
  with NVTreeForm, NVTreeForm.NVTreeFrame do
  begin
    N_MEGlobObj.AutoIncCSCodes := cbAutoIncCSCodes.Checked;
    N_MEGlobObj.NewEdWindow    := cbNewEdWindow.Checked;
    N_MEGlobObj.AddUObjSysInfo := cbAddUObjSysInfo.Checked;
    N_MEGlobObj.NotUseRefInds  := cbNotUseRefInds.Checked;

    if cbUncondDelete.Checked then K_UDOperateFlags := K_UDOperateFlags + [K_udoUNCDeletion]
                              else K_UDOperateFlags := K_UDOperateFlags - [K_udoUNCDeletion];

//    if cbSkipAutoRefsToUDVect.Checked then K_UDGControlFlags := K_UDGControlFlags + [K_gcfRefIndIgnore]
//                                      else K_UDGControlFlags := K_UDGControlFlags - [K_gcfRefIndIgnore];

    FrFormFName.Visible := not cbHideFileNameFrame.Checked;

    if cbStayOnTop.Checked then FormStyle := fsStayOnTop
                           else FormStyle := fsNormal;

    N_MEGlobObj.AutoViewReport := cbAutoViewReport.Checked;
    N_MEGlobObj.AliasesInPaths := cbAliasesInPaths.Checked;

    N_MEGlobObj.VEdFieldsAsTextAll := cbVeiwFieldsAsTextAll.Checked;

    N_FillCLBDesrValues( N_UObjFrMenuDescr, clbUObjFrMenu );
  end; // with NVTreeForm, NVTreeForm.NVTreeFrame do
end; // procedure TN_NVTreeOptionsForm.bnApplyClick

procedure TN_NVtreeOptionsForm.bnCancelClick( Sender: TObject );
// close Self without changing Data
begin
  Close();
end; // procedure TN_NVTreeOptionsForm.bnCancelClick

procedure TN_NVtreeOptionsForm.bnOKClick( Sender: TObject );
// Call bnApplyClick and Close Self
begin
  bnApplyClick( Sender );
  Close();
end; // procedure TN_NVTreeOptionsForm.bnOKClick

procedure TN_NVtreeOptionsForm.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  N_NVTreeOptionsForm := nil;
  Inherited;
end; // procedure TN_NVTreeOptionsForm.FormClose

//****************  TN_NVTreeOptionsForm class public methods  ************

//***********************************  TN_NVTreeOptionsForm.FillFormFields  ******
// Set Self Fields by NVTreeForm, NVTreeForm.NVTreeFrame and some Global Flags
//
procedure TN_NVtreeOptionsForm.FillFormFields();
begin
  with NVTreeForm, NVTreeForm.NVTreeFrame do
  begin
    cbAutoIncCSCodes.Checked := N_MEGlobObj.AutoIncCSCodes;
    cbNewEdWindow.Checked    := N_MEGlobObj.NewEdWindow;
    cbAddUObjSysInfo.Checked := N_MEGlobObj.AddUObjSysInfo;
    cbNotUseRefInds.Checked  := N_MEGlobObj.NotUseRefInds;

    cbUncondDelete.Checked := K_udoUNCDeletion in K_UDOperateFlags;

    cbHideFileNameFrame.Checked := not FrFormFName.Visible;

    cbStayOnTop.Checked := FormStyle = fsStayOnTop;
    cbAutoViewReport.Checked := N_MEGlobObj.AutoViewReport;

    cbVeiwFieldsAsTextAll.Checked := N_MEGlobObj.VEdFieldsAsTextAll;

    N_FillCheckListBox( N_UObjFrMenuDescr, clbUObjFrMenu );

  end; // with NVTreeForm, NVTreeForm.NVTreeFrame do
end; // end of procedure TN_NVTreeOptionsForm.FillFormFields

//***********************************  TN_NVTreeOptionsForm.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_NVtreeOptionsForm.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_NVTreeOptionsForm.CurStateToMemIni

//***********************************  TN_NVTreeOptionsForm.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_NVtreeOptionsForm.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_NVTreeOptionsForm.MemIniToCurState

    //*********** Global Procedures  *****************************

//********************************************  N_GetNVTreeOptionsForm  ******
// Create it if needed and return NVTreeOptionsForm
//
function N_GetNVTreeOptionsForm(  ANVTreeForm: TN_NVTreeForm;
                                   AOwner: TN_BaseForm ): TN_NVTreeOptionsForm;
begin
  if N_NVTreeOptionsForm <> nil then // already opened
  begin
    Result := N_NVTreeOptionsForm;
    Result.SetFocus;
    Exit;
  end;

  N_NVTreeOptionsForm := TN_NVTreeOptionsForm.Create( Application );
  Result := N_NVTreeOptionsForm;
  with Result do
  begin
    BaseFormInit( AOwner );
    NVTreeForm := ANVTreeForm;
    FillFormFields();
  end; // with Result do
end; // end of function N_GetNVTreeOptionsForm

end.
