unit N_ButtonsF;
// Form with RAFrame Actions, ButtonsList ImageList and other Delphi objects,
// that should always exist  (is created by Delphi).
//
// For using ButtonsList and IconsList in other Forms and Frames,
// N_ButtonsF unit should be included in Implementation Section Uses statetment

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ActnList, ExtDlgs;

type TN_ButtonsForm = class( TForm )
  ButtonsList: TImageList; // Icon Images for Buttons
  IconsList:   TImageList; // Icon Images for VTree Nodes
  RAFEditorsActionList: TActionList; // Actions for Ext. Editors, assigned in Form Descriptions:

  TK_RAFColorDialogEditor: TAction; //**************** TK Actions
  TK_RAFSArrayEditor:      TAction;
  TK_RAFUDEditor:          TAction;
  TK_RAFUDRefEditor:       TAction;
  TK_RAFUDRefEditor1:      TAction;
  TK_RAFUDRAEditor:        TAction;
  TK_RAFUDRARefEditor:     TAction;
  TK_RAFFNameEditor:       TAction;
  TK_RAFFNameEditor1:      TAction;
  TK_RAFFNameCmBEditor:    TAction;
  TK_RAFExtCmBEditor:      TAction;
  TK_RAFUDCSProjEditor1:   TAction;
  TK_RAFVArrayEditor:      TAction;
  TK_RAFCDItemEditor:      TAction;

  TN_RAFRAEditEditor:      TAction; //**************** TN Actions
  TN_RAFColorVEditor:      TAction;
  TN_RAFUDRefEditor:       TAction;
  TN_RAFUserParamEditor:   TAction;
  TN_RAFPA2SPEditor:       TAction;
  TN_RAFPenStyleEditor:    TAction;
  TN_RAFMSScalEditor:      TAction;
  TN_RAFMSPointEditor:     TAction;
  TN_RAFMSRectEditor:      TAction;
  TN_RAFScalVEditor:       TAction;
  TN_RAFPointVEditor:      TAction;
  TN_RAFRectVEditor:       TAction;
  TN_RAFRAEd2DEditor:      TAction;
  TN_RAFWinNFontEditor:    TAction;
  TN_RAFCharCodesEditor:   TAction;

  CommonActions: TActionList;
  aProtocolShow: TAction;
  aProtocolEdit: TAction;
    CommonOpenPictureDialog: TOpenPictureDialog;
    CommonSavePictureDialog: TSavePictureDialog;

    //********* Common Actions
  procedure aProtocolShowExecute ( Sender: TObject );
  procedure aProtocolEditExecute ( Sender: TObject );
end; // type TN_ButtonsForm = class( TForm )

var
  N_ButtonsForm: TN_ButtonsForm; // is needed, because it creates by Delphi!
  N_VRProtChanWinInd: integer;

implementation
uses
  K_CLib0,
  N_MemoF;
{$R *.dfm}

//************************************* TN_ButtonsForm.aProtocolShowExecute ***
// Show Protocol Window
//
//     Parameters
// Sender - Event Sender
//
// OnExecute CommonActions.aProtocolView Action handler
//
procedure TN_ButtonsForm.aProtocolShowExecute( Sender: TObject );
begin
  N_ShowLogChanForm( N_VRProtChanWinInd, nil );
//  K_ShowMessage( 'from aProtocolShowExecute' );
end; // procedure TN_ButtonsForm.aProtocolShowExecute

//************************************* TN_ButtonsForm.aProtocolEditExecute ***
// View, Edit Protocol in modal Window
//
//     Parameters
// Sender - Event Sender
//
// OnExecute CommonActions.aProtocolEdit Action handler
//
procedure TN_ButtonsForm.aProtocolEditExecute( Sender: TObject );
begin
  K_ShowMessage( 'from aProtocolEditExecute' );
end; // procedure TN_ButtonsForm.aProtocolEditExecute

end.
