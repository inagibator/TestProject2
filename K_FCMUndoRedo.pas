unit K_FCMUndoRedo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  K_CM0,
  N_BaseF, N_Rast1Fr, N_CompBase;

type
  TK_FormCMUndoRedo = class(TN_BaseForm)
    Label1: TLabel;
    Label2: TLabel;
    NewPanel: TPanel;
    NewRFrame: TN_Rast1Frame;
    OldPanel: TPanel;
    OldRFrame: TN_Rast1Frame;
    BtCancel: TButton;
    BtOK: TButton;
    LbURItems: TLabel;
    LVURItems: TListView;
    procedure LVURItemChange( Sender: TObject; Item: TListItem; Change: TItemChange );
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure LVURItemsDblClick(Sender: TObject);
    procedure LVURItemsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    URCMSUndoBuf : TK_CMSUndoBuf;
  public
    { Public declarations }
    URCurMapRoot : TN_UDCompVis;
    URChangeSlideCurState : TK_CMSlideSaveStateFlags;
    procedure ShowUndoBufList( ACMSUndoBuf : TK_CMSUndoBuf );
  end;

var
  K_FormCMUndoRedo: TK_FormCMUndoRedo;

implementation

uses K_UDC, K_SBuf,
  N_ClassRef, N_CMResF, N_Types, N_CMMain5F,
  K_CML1F;

{$R *.dfm}

{*** TK_FormCMUndoRedo ***}

//***************************************** TK_FormCMUndoRedo.LVURItemChange ***
//  Undo/Redo Items change current events handler
//
procedure TK_FormCMUndoRedo.LVURItemChange( Sender: TObject;
                                            Item: TListItem; Change: TItemChange );
var
  Ind : Integer;
  WChangeSlideCurState : TK_CMSlideSaveStateFlags;

begin

  if (URCurMapRoot = nil) or (LVURItems.ItemIndex < 0) then Exit;
  Ind := URCMSUndoBuf.UBCount - 1 - LVURItems.ItemIndex;

  WChangeSlideCurState := URCMSUndoBuf.UBGetSlideState( Ind );
  URChangeSlideCurState := URChangeSlideCurState + WChangeSlideCurState;

//  FCMSUndoBuf.UBCurInd :=  Ind;
  if WChangeSlideCurState <> [] then
  begin
    with NewRFrame do
    begin
      N_CM_MainForm.CMMFShowHideWaitState( TRUE );
      RVCTFrInit3( URCMSUndoBuf.UDCMSlide.GetMapRoot() );
//      RFrInitByComp( URCMSUndoBuf.UDCMSlide.GetMapRoot );
      RVCTreeRootOwner := false;
      aFitInWindowExecute( nil );
      N_CM_MainForm.CMMFShowHideWaitState( FALSE );
    end;
    K_CMSCheckMemFreeSpaceDlg( K_CML1Form.LLLFinishActionAndRestart.Caption );
//      'Please finish this action and restart CMS.' );
  end;

end; // end of procedure TK_FormCMUndoRedo.LVURItemChange

//***************************************** TK_FormCMUndoRedo.ShowUndoBufList ***
//  Show Undo Buffer State
//
//    Parameters
//  ACMSUndoBuf - CMS UNDO buffer
//
procedure TK_FormCMUndoRedo.ShowUndoBufList( ACMSUndoBuf : TK_CMSUndoBuf );
var
  i : Integer;
begin
  URCMSUndoBuf := ACMSUndoBuf;

  for i := URCMSUndoBuf.UBCount - 1 downto URCMSUndoBuf.UBMinInd do
    LVURItems.AddItem( URCMSUndoBuf.UBCaptions[i], nil );

  if URCMSUndoBuf.UBMinInd > 0 then
     with LVURItems do
       Items[Items.Count - 1].Caption := K_CML1Form.LLLUndoRedo1.Caption; // 'Initial state';

  LVURItems.ItemIndex := URCMSUndoBuf.UBCount - 1 - URCMSUndoBuf.UBCurInd;

// Set Slide MapRoot Component to RFrame with Changed Slide State
  URCurMapRoot := URCMSUndoBuf.UDCMSlide.GetMapRoot();
  with NewRFrame do
  begin
    RFCenterInDst := true;
    RVCTFrInit3( URCurMapRoot );
//    RFrInitByComp( URCurMapRoot );
    RVCTreeRootOwner := false;
    aFitInWindowExecute( nil );
  end;

// Copy Slide MapRoot Component to Show in RFrame with Current Slide State
  with URCurMapRoot.DirChild(K_CMSlideMRIndMapImg) do begin
    ClassFlags := ClassFlags and not K_SkipSelfSaveBit; // Clear Skip Save Flag in SLide MapImage
    K_SaveTreeToMem( URCurMapRoot, N_SerialBuf );       // Serialized to Memory
    ClassFlags := ClassFlags + K_SkipSelfSaveBit;       // Restore Skip Save Flag in SLide MapImage
  end;
  URCurMapRoot := TN_UDCompVis( K_LoadTreeFromMem( N_SerialBuf ) ); // Create MapRoot Copy
  with URCurMapRoot.DirChild(K_CMSlideMRIndMapImg) do
    ClassFlags := ClassFlags + K_SkipSelfSaveBit;       // Restore Skip Save Flag in MapRoot Copy MapImage

// Set Copied Slide MapRoot Component to RFrame with Current Slide State
  with OldRFrame do
  begin
    RFCenterInDst := true;
    RVCTFrInit3( URCurMapRoot );
//    RFrInitByComp( URCurMapRoot );
    RVCTreeRootOwner := false;
    aFitInWindowExecute( nil );
  end;

end; // end of TK_FormCMUndoRedo.ShowUndoBufList

//***************************************** TK_FormCMUndoRedo.FormShow ***
//  Form Show Handler
//
procedure TK_FormCMUndoRedo.FormShow( Sender: TObject );
begin
  inherited;
  NewRFrame.RFDebName := 'URNewRFrame';
  OldRFrame.RFDebName := 'UROldRFrame';
  LVURItems.ItemFocused := LVURItems.Items[LVURItems.ItemIndex];
  LVURItems.SetFocus;

end; // end of TK_FormCMUndoRedo.FormShow

//***************************************** TK_FormCMUndoRedo.FormCloseQuery ***
//  Form Close Query Handler
//
procedure TK_FormCMUndoRedo.FormCloseQuery( Sender: TObject;
                                            var CanClose: Boolean );
begin
  inherited;
  OldRFrame.RFFreeObjects();
  NewRFrame.RFFreeObjects();

end; // end of TK_FormCMUndoRedo.FormCloseQuery

//***************************************** TK_FormCMUndoRedo.LVURItemsDblClick ***
//  Items List DoubleClick Handler
//
procedure TK_FormCMUndoRedo.LVURItemsDblClick(Sender: TObject);
begin
  if LVURItems.ItemIndex < 0 then Exit;
  ModalResult := mrOK;
end; // end of TK_FormCMUndoRedo.LVURItemsDblClick

//***************************************** TK_FormCMUndoRedo.LVURItemsKeyDown ***
//  Items List DoubleClick Handler
//
procedure TK_FormCMUndoRedo.LVURItemsKeyDown( Sender: TObject;
  var Key: Word; Shift: TShiftState );
begin
  if (LVURItems.ItemIndex < 0) or (Key <> VK_RETURN) then Exit;
  ModalResult := mrOK;
end; // end of TK_FormCMUndoRedo.LVURItemsKeyDown

end.
