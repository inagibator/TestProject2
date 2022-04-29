unit K_FCMImportReverse;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  K_CM0,
  N_BaseF, N_Types;

type
  TK_FormCMImportReverse = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    Label2: TLabel;
    LbIDate: TLabel;
    Label5: TLabel;
    LbITime: TLabel;
    Bevel3: TBevel;
    Label3: TLabel;
    LbICount: TLabel;
    Bevel2: TBevel;
    Bevel1: TBevel;
    LbRemovedCount: TLabel;
    procedure FormShow(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
  private
    { Private declarations }
//    ImportID : Integer;
//    ImportCount : Integer;
    SlidesID : TN_IArray;
    CMIState : TK_CMImportState;
  public
    { Public declarations }
  end;

var
  K_FormCMImportReverse: TK_FormCMImportReverse;

  function  K_CMReverseImportDlg( ) : Boolean;

implementation

{$R *.dfm}
uses Math,
  N_CM1, N_CMMain5F, K_FCMSIsodensity, K_CLib0, K_CML1F;

function  K_CMReverseImportDlg( ) : Boolean;
begin

  with TK_FormCMImportReverse.Create(Application) do
  begin
//    BaseFormInit ( nil, '', [fvfCenter] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );

    Result := FALSE;
    K_CMEDAccess.EDAGetLastImportHistory1( @CMIState, @SlidesID );
    if CMIState.CMIDBID = -1 then begin
      K_CMShowMessageDlg( K_CML1Form.LLLNothingToDo.Caption,
//         'Nothing to do!',
                          mtInformation );
      Exit;
    end;
    Result := ShowModal = mrOK;
  end;


end;

procedure TK_FormCMImportReverse.FormShow(Sender: TObject);
begin
//
  LbIDate.Caption := K_DateTimeToStr( CMIState.CMIDate, 'dd"/"mm"/"yyyy' );
  LbITime.Caption := K_DateTimeToStr( CMIState.CMIDate, 'hh":"nn AM/PM' );
  LbICount.Caption := IntToStr( CMIState.CMIImpCount );
  LbRemovedCount.Caption := '';
end;

{}
procedure TK_FormCMImportReverse.BtOKClick(Sender: TObject);
const
  DelStep = 10;
var
  IDInd, k, n : Integer;
  Slides : TN_UDCMSArray;
  CCount, SelfDelCount, WereDelCount, WereUsedCount, CurUsedCount, SkipMediaCount : Integer;
  SavedCursor : TCursor;
  WStr, Str1 : string;
begin
  if mrYes <> K_CMShowMessageDlg( format( K_CML1Form.LLLDBImportRev1.Caption,
                                  [CMIState.CMIImpCount] ) + #13#10 +
                                  K_CML1Form.LLLActProceed1.Caption + ' ' + K_CML1Form.LLLProceed.Caption,
//        'Do you confirm that you really want'#13#10 +
//        'to remove %d imported objects?',
//        'This action is irreversible. Proceed?',
                     mtConfirmation, [], TRUE, K_CML1Form.LLLDelConfirm.Caption  ) then
//                                             'Objects deletion confirmation'
    ModalResult := mrCancel
  else begin
  // Remove Slides Loop
  // Prepare slides list
    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;
    BtCancel.Enabled := FALSE;
    BtOK.Enabled     := FALSE;

    // Disable CMS UI
    N_CM_MainForm.CMMSetUIEnabled( FALSE );
{
    Include( N_CM_MainForm.CMMUICurStateFlags, uicsAllActsDisabled);
    N_CM_MainForm.CMMFDisableActions( Self );
    N_AppSkipEvents := TRUE;
    K_CMD4WSkipCloseUI := TRUE;
}
    N_Dump1Str( 'Reverse import after conversion Slides Count=' + IntToStr(CMIState.CMIImpCount) );
    with K_CMEDAccess do begin
      CCount         := 0;
      IDInd          := 0;
      WereDelCount   := 0;
      CurUsedCount   := 0;
      SelfDelCount   := 0;
      WereUsedCount   := 0;
      SkipMediaCount := 0;
      GUISilentFlag  := TRUE;
      SkipEDADataCheckInDelProc := TRUE;
      LbICount.Caption := IntToStr( CMIState.CMIImpCount );
      LbICount.Refresh();
      K_CMSCreateDeleteMode := 1;
      while IDInd < CMIState.CMIImpCount do
      begin
        k := Min( CMIState.CMIImpCount - IDInd, DelStep );
        K_CMEDAccess.EDAGetUDCMSlidesByID( @SlidesID[IDInd], k, Slides );
        n := Length(Slides);
        WereDelCount := WereDelCount + k - n;
        if n > 0 then
        begin
          N_CM_MainForm.CMMFShowString( '' );
          CurUsedCount := CurUsedCount + K_CMSlidesDelete( @Slides[0], n, FALSE, TRUE );
          N_CM_MainForm.CMMFShowString( '' );
          WereDelCount := WereDelCount + LockResDelCount;
          SelfDelCount := SelfDelCount + LockResCount - LockResDelCount;
          WereUsedCount := WereUsedCount + LockResDelUsedByOtherCount;
          SkipMediaCount := SkipMediaCount + LockResMediaCreatedOnOtherCount;
          Inc( CCount, n );
        end;
        LbRemovedCount.Caption := format( K_CML1Form.LLLDBImportRev3.Caption,
//                                 '%5d deleted',
                                        [SelfDelCount + WereDelCount] );
        LbICount.Refresh();
        Inc(IDInd, k);
        Application.ProcessMessages();
      end;
      K_CMSCreateDeleteMode := 0;
      LbRemovedCount.Caption := format( K_CML1Form.LLLDBImportRev3.Caption,
//                                 '%5d deleted',
                                        [SelfDelCount + WereDelCount] );
      GUISilentFlag := FALSE;

      WStr := '';
      if WereUsedCount > 0 then
        WStr := format( K_CML1Form.LLLSlidesDel1.Caption,
//        WStr := format( K_CML1Form.LLLDBImportRev4.Caption, // text is duplicated
//          ' %d Media object(s) have been used by other CMS user(s)',
                        [WereUsedCount] );

      if SkipMediaCount > 0 then
      begin
        if WStr <> '' then
          WStr :=  WStr + #13#10;
        WStr := WStr + format( K_CML1Form.LLLDBImportRev5.Caption,
//          ' %d Media object(s) were created on other computers',
                               [SkipMediaCount] );
      end;

      if WStr <> '' then
        WStr := #13#10 + WStr;

      Str1 := '';
      if WereDelCount > 0 then
        Str1 := format( K_CML1Form.LLLDBImportRev6.Caption + #13#10,
//        ' %d Media object(s) of %d were already deleted'#13#10,
                        [WereDelCount, CMIState.CMIImpCount] );
      WStr := Str1 + format( K_CML1Form.LLLDBImportRev7.Caption,
//            ' %d Media object(s) of %d were deleted by import reverse',
                          [SelfDelCount, CMIState.CMIImpCount] )  + WStr;

      N_Dump1Str( 'Reverse import after conversion >> '#13#10 + WStr );
      if SelfDelCount = CCount then
        K_CMEDAccess.EDADeleteImportHistory( CMIState.CMIDBID )
      else
      begin
      // Some Slides were not removed
        K_CMShowMessageDlg( WStr, mtInformation );
      end;
    end; // with K_CMEDAccess do

    if CurUsedCount > 0 then
    begin
    // Update Current Context
      with N_CM_MainForm do
      begin
        CMMFRebuildVisSlides();
//        CMMFDisableActions( nil );
        CMMFShowStringByTimer( format( K_CML1Form.LLLDBImportRev8.Caption,
//            ' %d object(s) deleted',
                               [CurUsedCount] ) );
      end;
      K_FormCMSIsodensity.InitIsodensityMode();
    end;
    K_CMEDAccess.LockResCount := 0; // Clear LockResCount to prevent AMSC Error
    K_CMEDAccess.SkipEDADataCheckInDelProc := FALSE;
    ModalResult := mrOK;

    Screen.Cursor := SavedCursor;

    // Enable CMS UI
    N_CM_MainForm.CMMSetUIEnabled( TRUE );
{
    K_CMD4WSkipCloseUI := FALSE;
    N_AppSkipEvents := FALSE;
    Exclude( N_CM_MainForm.CMMUICurStateFlags, uicsAllActsDisabled);
    N_CM_MainForm.CMMFDisableActions( Self );
}
    K_CMEDAccess.LockResCount := 0; // Clear LockResCount to prevent AMSC Error
  end
end; // procedure TK_FormCMImportReverse.BtOKClick
{}
end.
