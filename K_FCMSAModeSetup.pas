unit K_FCMSAModeSetup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_Types, N_BaseF;

type
  TK_FormCMSAModeSetup = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    RBHybrid: TRadioButton;
    RBLink: TRadioButton;
    RBIndependent: TRadioButton;
    procedure RBLinkClick(Sender: TObject);
  private
    { Private declarations }
//    NewMode : Integer;
    NewMode : TN_Int1;
  public
    { Public declarations }
  end;

var
  K_FormCMSAModeSetup: TK_FormCMSAModeSetup;

function K_CMSAModeSetup(  ) : Boolean;

implementation

uses
//Math,
  K_CM0, K_CML1F;
//  N_Lib0, N_Lib1, N_Comp1, N_CompCL, N_CM1;

{$R *.dfm}

function K_CMSAModeSetup(  ) : Boolean;
var
  ResValue : TN_Int1;
begin
  with TK_FormCMSAModeSetup.Create(Application) do begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );

    Result := FALSE; // to prevent warning

    // Get Remote CLient Device Context Type
    N_Dump2Str( 'Start Standalone Mode Setup' );
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      try
        with CurBlobDSet do
        begin
          ExtDataErrorCode := K_eeDBSelect;
          Connection := LANDBConnection;
          SQL.Text := 'select ' + K_CMENDBGTFSAFlags +
            ' from ' + K_CMENDBGlobAttrsTable;
          Filtered := false;
          Open;
          Byte(K_CMStandaloneMode) := (FieldList.Fields[0].AsInteger) and 3;

          case K_CMStandaloneMode of
          K_cmsaIndependent : RBIndependent.Checked := TRUE;
          K_cmsaHybrid      : RBHybrid.Checked := TRUE;
          K_cmsaLink        : RBLink.Checked := TRUE;
          else
            K_CMShowMessageDlg( //sysout
            'Wrong Stand alone mode', mtWarning );
            Close;
            Exit;
          end;

          NewMode := Ord(K_CMStandaloneMode);
          Result := ShowModal() = mrOK;
          ResValue := NewMode;
          if Result and
             (NewMode <> Ord(K_CMStandaloneMode)) and
             (mrYes = K_CMShowMessageDlg( K_CML1Form.LLLSAModeSetup.Caption + ' ' + K_CML1Form.LLLPressYesToProceed.Caption,
//             'Please confirm you wish to change the CMS alone mode. Press Yes to proceed',
                                  mtConfirmation )) then
          begin
            TN_Int1(K_CMStandaloneMode) := ResValue;
            Edit;
            FieldList.Fields[0].AsInteger := (FieldList.Fields[0].AsInteger and not 3) or Ord(K_CMStandaloneMode);
            UpdateBatch;
            N_Dump1Str( 'Set New Standalone mode = ' + IntToStr(Ord(K_CMStandaloneMode)) );
          end
          else
          begin
            N_Dump2Str( 'Cancel Standalone Mode Setup' );
            Result := FALSE;
          end;
          Close;
        end;
      except
        on E: Exception do
        begin
          ExtDataErrorString := 'Standalone Mode Setup ' + E.Message;
          EDAShowErrMessage(TRUE);
        end;
      end;
    end;
  end;
end;

procedure TK_FormCMSAModeSetup.RBLinkClick(Sender: TObject);
begin

  if RBIndependent.Checked then
  begin
    RBHybrid.Checked := FALSE;
    RBLink.Checked := FALSE;
    NewMode := Ord(K_cmsaIndependent);
  end
  else
  if RBHybrid.Checked then
  begin
    RBIndependent.Checked := FALSE;
    RBLink.Checked := FALSE;
    NewMode := Ord(K_cmsaHybrid);
  end
  else
  if RBLink.Checked then
  begin
    RBIndependent.Checked := FALSE;
    RBHybrid.Checked := FALSE;
    NewMode := Ord(K_cmsaLink);
  end;
end;

end.
