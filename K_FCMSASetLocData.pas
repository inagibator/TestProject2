unit K_FCMSASetLocData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_BaseF, 
  K_CM0;

type
  TK_FormCMSASetLocationData = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    LbETitle: TLabeledEdit;
    LbERefN: TLabeledEdit;
    procedure LbERefNChange(Sender: TObject);
  private
    { Private declarations }
    LocSID : string;
    IRefN : Integer;
    ReadOnly : Boolean;
  public
    { Public declarations }
  end;

var
  K_FormCMSASetLocationData: TK_FormCMSASetLocationData;

function  K_CMSASetLocationDataDlg( const ALocID : string;
                    APCMSALocationDBData : TK_PCMSALocationDBData ) : Boolean;

implementation

uses K_CML1F,
N_Types;

{$R *.dfm}

//************************************************ K_CMSASetProviderDataDlg ***
// Set CMS Standalone Location Data Dialog
//
//     Parameters
// APatID - Patient Code string
// APCMSAPatientDBData - Provider Data
// Result - Returns FALSE if user do not click OK
//
function  K_CMSASetLocationDataDlg( const ALocID : string;
                    APCMSALocationDBData : TK_PCMSALocationDBData ) : Boolean;
begin

  with TK_FormCMSASetLocationData.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    LocSID := ALocID;
    if LocSID = '' then
    begin
      Caption := K_CML1Form.LLLSelLoc13.Caption; // 'New Practice'
      ReadOnly := FALSE;
    end
    else
    begin
      Caption := K_CML1Form.LLLSelLoc11.Caption; // 'Practice Dentist';
      if APCMSALocationDBData.ALIsPMSSync then
        Caption := K_CML1Form.LLLSelLoc12.Caption; // 'Practice details';
      ReadOnly := not APCMSALocationDBData.ALIsLocked or
                  (K_CMStandaloneMode = K_cmsaLink)   or
                  (APCMSALocationDBData.ALIsPMSSync and
                  (K_CMStandaloneMode = K_cmsaHybrid));
    end;
    LbETitle.Text := APCMSALocationDBData.ALName;
    LbETitle.Enabled := not ReadOnly;

//    IRefN := APCMSALocationDBData.ALCustRefN;
//    if IRefN <> 0 then
//      LbERefN.Text := IntToStr(APCMSALocationDBData.ALCustRefN);
    LbERefN.Text := APCMSALocationDBData.ALCustRefN;
    LbERefN.Enabled := not ReadOnly;

    Result := ShowModal() = mrOK;
    if not Result then Exit;

    APCMSALocationDBData.ALName     := LbETitle.Text;
//    APCMSALocationDBData.ALCustRefN := IRefN;
    APCMSALocationDBData.ALCustRefN := LbERefN.Text;

  end; // with TK_FormCMSASetLocationData.Create( Application ) do
end; // function  K_CMSASetLocationDataDlg

//******************************** TK_FormCMSASetLocationData.LbERefNChange ***
// LbERefN onChange Handler
//
procedure TK_FormCMSASetLocationData.LbERefNChange(Sender: TObject);
var
  NewVal : Integer;
begin
  NewVal := 0;
  if LbERefN.Text <> '' then
    NewVal := StrToIntDef( LbERefN.Text, IRefN );

  if NewVal = 0 then
    LbERefN.Text := ''
  else
    LbERefN.Text := IntToStr( NewVal );

  LbERefN.SelStart := Length(LbERefN.Text);

  IRefN := NewVal;

  LbERefN.Modified := FALSE;

end; // procedure TK_FormCMSASetLocationData.LbERefNChange

end.
