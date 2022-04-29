unit K_FCDRelShow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ComCtrls, StdCtrls,
  N_BaseF, N_Types,
  K_FrRaEdit, K_FrCDRel, K_CSpace, K_Script1, ExtCtrls;

type
  TK_FormCDRelShow = class(TN_BaseForm)
    FrameCDRel: TK_FrameCDRel;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    IniCaption : string;
  public
    { Public declarations }
    OnGlobalAction : TK_RAFGlobalActionProc;
    procedure ShowRACDRel( RACDRel : TK_RArray; ACaption : string = '' );
    procedure ShowUDCDRel( UDCDRel : TK_UDCSDim; ACaption : string = '' );
  end;

function K_GetFormCDRelShow( AOwner: TN_BaseForm ) : TK_FormCDRelShow;

implementation

uses K_UDT1;

{$R *.dfm}

//***********************************  K_GetFormCDRelShow
// Create Code Dimention Indexes Editor Form
//
function K_GetFormCDRelShow( AOwner: TN_BaseForm ) : TK_FormCDRelShow;
begin
  Result := TK_FormCDRelShow.Create( Application );
  Result.BaseFormInit( AOwner );
end; //*** end of K_GetFormCDRelShow

{*** TK_FormCDRelShow ***}

//***********************************  TK_FormCDRelShow.FormCreate
// FormCreate Handler
//
procedure TK_FormCDRelShow.FormCreate(Sender: TObject);
begin
  inherited;
  IniCaption := Caption;

end; //*** end of TK_FormCDRelShow.FormCreate

//***********************************  TK_FormCDRelShow.ShowRACDRel
// Show CDim Relation RArray
//
procedure TK_FormCDRelShow.ShowRACDRel( RACDRel: TK_RArray; ACaption : string = '' );
var
  PUDCDims : TN_PUDBase;
  UDCDimsCount : Integer;

begin
  if ACaption <> '' then
    Caption := ACaption + ' - ' + IniCaption;
//  FrameCDRel.ReadOnlyMode := true;

  UDCDimsCOunt := K_GetRACDRelPUDCDims( RACDRel, PUDCDims );

  with RACDRel do
    FrameCDRel.ShowRACDRel( PUDCDims, UDCDimsCount, P, ARowCount, K_GetRACDRelUDCSDim(RACDRel) );
end; //*** end of TK_FormCDRelShow.ShowRACDRel

//***********************************  TK_FormCDRelShow.ShowUDCDRel
// Show CDim Relation UDObj
//
procedure TK_FormCDRelShow.ShowUDCDRel( UDCDRel: TK_UDCSDim; ACaption: string );
begin
  ShowRACDRel( UDCDRel.R, ACaption );
end; //*** end of TK_FormCDRelShow.ShowUDCDRel

{*** end of TK_FormCDRelShow ***}

procedure TK_FormCDRelShow.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
begin
  inherited;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaNone );

end;

end.
