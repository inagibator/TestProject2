unit K_FCMImgProfileProcAttrs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  K_FCMImgFilterProcAttrs, K_CM0,
  N_Types;

type
  TK_FormCMImgProfileProcAttrs = class(TK_FormCMImgFilterProcAttrs)
    ChBLoadFilter: TCheckBox;
    CmBFilters: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure CmBFiltersChange(Sender: TObject);
    procedure ChBLoadFilterClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMImgProfileProcAttrs: TK_FormCMImgProfileProcAttrs;

function K_CMImgProfileProcAttrsDlg( APAutoImgProcAttrs : TK_PCMAutoImgProcAttrs; const ACaption : string ) : Boolean;

implementation

uses K_CML1F;

{$R *.dfm}

//**************************************************** K_CMImgFilterProcAttrsDlg ***
// Change Image Filter Processing Attributes Dialog
//
//     Parameters
// APAutoImgProcAttrs - Pointer to Auto Image Processing Parameters
// APAutoImgProcAttrsIni - Pointer to Auto Image Processing Parameters to Initialize value by reset button
// Result - Return TRUE if Auto Image Processing attributes were changed
//
function K_CMImgProfileProcAttrsDlg( APAutoImgProcAttrs : TK_PCMAutoImgProcAttrs; const ACaption : string ) : Boolean;
//var
//  WasChanged : Boolean;
begin
  K_FormCMImgProfileProcAttrs := TK_FormCMImgProfileProcAttrs.Create(Application);
  with K_FormCMImgProfileProcAttrs do
  begin
    if ACaption <> '' then
      Caption := ACaption;
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    K_CMInitAutoImgProcAttrs( APAutoImgProcAttrs );
    PAutoImgProcAttrs := APAutoImgProcAttrs;
    Result := ShowModal() = mrOK;
    LSFGamma.Free;
    LSFGamma1.Free;
    if Result then
    begin
      SetAttrsByControlsState();
      with AutoImgProcAttrs do
        if (CMAIBriLLFactor = 0) and (CMAIBriULFactor = 100) then
          CMAIBriULFactor := 0;

      Result := not CompareMem( PAutoImgProcAttrs, @AutoImgProcAttrs, SizeOf(TK_CMAutoImgProcAttrs) );

      // Set Modified Attributes Flag if Current State differs from Ini State
      Exclude( AutoImgProcAttrs.CMAIPFlags, K_aipfModified );
      if not CompareMem( @AutoImgProcAttrs, @AutoImgProcAttrsIni, SizeOf(TK_CMAutoImgProcAttrs) ) then
        Include( AutoImgProcAttrs.CMAIPFlags, K_aipfModified );

      PAutoImgProcAttrs^ := AutoImgProcAttrs;

    end;
 end;
 K_FormCMImgProfileProcAttrs := nil;

end; // function K_CMImgFilterProcAttrsDlg

procedure TK_FormCMImgProfileProcAttrs.FormShow(Sender: TObject);

var i : Integer;

begin
  inherited;
  for i := 0 to K_CMEDAccess.UFiltersProfiles.AHigh do
    with TK_PCMUFilterProfile(K_CMEDAccess.UFiltersProfiles.PDE(i))^ do
      if K_CMGetUIHintByAutoImgProcAttrs( @CMUFPAutoImgProcAttrs ) <> '' then
        CmBFilters.Items.AddObject( format(
           K_CML1Form.LLLImgFilterProc3.Caption + ' %d', [i+1] ), TObject(i) );
//        CmBFilters.Items.AddObject( format( 'Filter %d', [i+1] ), TObject(i) );

        //K_CML1Form.LLLImgFilterProc3.Caption

  for i := 0 to K_CMEDAccess.GFiltersProfiles.AHigh do
    with TK_PCMUFilterProfile(K_CMEDAccess.GFiltersProfiles.PDE(i))^ do
      if K_CMGetUIHintByAutoImgProcAttrs( @CMUFPAutoImgProcAttrs ) <> '' then
        CmBFilters.Items.AddObject( format(
           K_CML1Form.LLLImgFilterProc3.Caption +' %1x', [i+10] ), TObject(i + 4) );
//        CmBFilters.Items.AddObject( format( 'Filter %1x', [i+10] ), TObject(i + 4) );
  CmBFilters.ItemIndex := 0;
end;

procedure TK_FormCMImgProfileProcAttrs.CmBFiltersChange(Sender: TObject);
var
  Ind : Integer;
begin
//  PnAll.Enabled := not ChBLoadFilter.Checked or (CmBFilters.ItemIndex <= 0);

  GBFilters.Enabled := not ChBLoadFilter.Checked or (CmBFilters.ItemIndex <= 0);
  GBBriCoGam.Enabled := GBFilters.Enabled;
  GBFlipRotate.Enabled := GBFilters.Enabled;

  if GBFilters.Enabled then Exit;

  Ind := Integer(CmBFilters.Items.Objects[CmBFilters.ItemIndex]);
  if Ind < K_CMEDAccess.UFiltersProfiles.ALength then
    AutoImgProcAttrs := TK_PCMUFilterProfile(K_CMEDAccess.UFiltersProfiles.PDE(Ind)).CMUFPAutoImgProcAttrs
  else
    AutoImgProcAttrs := TK_PCMUFilterProfile(K_CMEDAccess.GFiltersProfiles.PDE(Ind - 4)).CMUFPAutoImgProcAttrs;

  InitControlsByData( @AutoImgProcAttrs );

end;

procedure TK_FormCMImgProfileProcAttrs.ChBLoadFilterClick(Sender: TObject);
begin
//  PnAll.Enabled := not ChBLoadFilter.Checked or (CmBFilters.ItemIndex <= 0);

  GBFilters.Enabled := not ChBLoadFilter.Checked or (CmBFilters.ItemIndex <= 0);
  GBBriCoGam.Enabled := GBFilters.Enabled;
  GBFlipRotate.Enabled := GBFilters.Enabled;

  if ChBLoadFilter.Checked then CmBFiltersChange(Sender);
end;

end.
