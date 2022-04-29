unit N_GetUObjF;
// Get UObj from VTree (used in UObjFrame)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls,
  K_UDT1,
  N_Types, N_BaseF;

type TN_GetUObjForm = class( TN_BaseForm )
    VTreeFrame: TN_VTreeFrame;
    procedure FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  public
//    UObjOK: boolean;
    procedure JustCloseSelf( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
                             Button: TMouseButton; Shift: TShiftState );
end; // type TN_GetUObjForm = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

function N_GetUObjPathDlg ( ARootUObj: TN_UDBase; ACurPath: string;
                                      AParentControl: TControl = nil ): string;
function N_CreateGetUObjForm ( AOwner: TN_BaseForm ): TN_GetUObjForm;

implementation
uses
  N_Lib1, N_Lib2;

{$R *.dfm}

//****************  TN_GetUObjForm class handlers  ******************

procedure TN_GetUObjForm.FormKeyDown( Sender: TObject; var Key: Word;
                                                         Shift: TShiftState );
// Close Self with ModalResult mrOK if Enter pressed,
// or with mrCancel if Escape pressed
begin
  if Key = VK_ESCAPE then
  begin
    Close;
    ModalResult := mrCancel; // should be set AFTER calling Close method
  end else if Key = VK_RETURN then
  begin
    if VTreeFrame.VTree.Selected <> nil then
    begin
      Close;
      ModalResult := mrOK; // should be set AFTER calling Close method
    end;
  end;
end;

procedure TN_GetUObjForm.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  Inherited; // Action set to caFree in BaseForm.FormClose handler
end;

procedure TN_GetUObjForm.JustCloseSelf( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
                                        Button: TMouseButton; Shift: TShiftState );
// Just close Self with ModalResult mrOK bu DoublClik
// (used as VTree OnClick handler)
begin
  Close();
  ModalResult := mrOK;
end;

    //*********** Global Procedures  *****************************

//********************************************  N_GetUObjPathDlg  ******
// Get Path to selected UObj in modal dialog, using N_GetUObjForm
//
function N_GetUObjPathDlg( ARootUObj: TN_UDBase; ACurPath: string;
                                            AParentControl: TControl ): string;
var
 GUF: TN_GetUObjForm;

begin
  Result := '';
  GUF := N_CreateGetUObjForm( nil );
  N_PlaceTControl( GUF, AParentControl );

  with GUF.VTreeFrame do
  begin
   VTree := TN_VTree.Create( TreeView, ARootUObj );
   VTree.SetPath( ACurPath );

   if VTree.Selected <> nil then
     VTree.TreeView.TopItem := VTree.Selected.VNTreeNode;

   OnDoubleClickProcObj := GUF.JustCloseSelf;

   GUF.ShowModal;

   if (GUF.ModalResult = mrCancel) or (VTree.Selected = nil) then Exit;

//   Result := ExcludeTrailingPathDelimiter(VTree.Selected.GetSelfVTreePath());
    with VTree do
      Result := GetPathToVNode( Selected );

  end; // with GUF.VTreeFrame do
end; // function N_GetUObjPathDlg

//********************************************  N_CreateGetUObjForm  ******
// Create and return new instance of N_GetUObjForm
//
function N_CreateGetUObjForm( AOwner: TN_BaseForm ): TN_GetUObjForm;
begin
  Result := TN_GetUObjForm.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );
  end;
end; // function N_CreateGetUObjForm

end.
