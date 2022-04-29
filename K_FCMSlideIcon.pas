unit K_FCMSlideIcon;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  K_CM0,
  N_BaseF, N_Rast1Fr, N_DGrid, N_CM2;

type
  TK_FormCMSlideIcon = class(TN_BaseForm)
    Image: TImage;
    SlideImage: TImage;
    LbHead: TLabel;
    BtOK: TButton;
    BtCancel: TButton;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMSlideIcon: TK_FormCMSlideIcon;

function  K_CMSlideIconDlg( ASlide : TN_UDCMSlide;
                             const ADlgWinCapt, ADlgText : string;
                             ADlgType: TMsgDlgType = mtConfirmation;
                             AMDButtons: TMsgDlgButtons = [] ) : Boolean;
//1                             ADlgType: TMsgDlgType; AButCapts : array of const ) : Boolean;

implementation

{$R *.dfm}

uses Math,
  K_CLib0,
  N_Types, N_CM1, N_Comp1, N_Gra0, N_Gra1, N_Gra2;

var
  IconIDs: array[TMsgDlgType] of PChar = (IDI_EXCLAMATION, IDI_HAND,
    IDI_ASTERISK, IDI_QUESTION, nil);

//********************************************* K_CMSlideIconDlg ***
// Given Slide action confirmation dialog
//
//     Parameters
// ASlide - given slide
// AMDlgWinCapt - Dalog Window Caption
// AMDlgText    - Dalog text
// AMDButtons  - set of Message Dialog buttons
// AMDResult   - Message Dialog OK result corresponding to AMDButtons
// Result - Returns TRUE if user confirms given object action
//
function  K_CMSlideIconDlg( ASlide : TN_UDCMSlide;
                             const ADlgWinCapt, ADlgText : string;
                             ADlgType: TMsgDlgType = mtConfirmation;
                             AMDButtons: TMsgDlgButtons = [] ) : Boolean;
var
  S : Integer;
  DIBObj : TN_DIBObj;
  ImgRect : TRect;
  k : Double;
  W, H : Integer;
  ButCount : Integer;
  SA : TN_SArray;

begin

  with TK_FormCMSlideIcon.Create( Application ) do begin
//    BaseFormInit( nil, '', [fvfCenter] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
// LoadFromStream(Stream: TStream);
    Caption := ADlgWinCapt;
    if IconIDs[ADlgType] <> nil then
      Image.Picture.Icon.Handle := LoadIcon(0, IconIDs[ADlgType]);

    DIBObj := ASlide.GetThumbnail().DIBObj;
    W := SlideImage.Width;
    H := SlideImage.Width;
    k := DIBObj.DIBSize.X / DIBObj.DIBSize.Y;
    if k > 1 then
      H := Round( W / k )
    else
      W := Round( W * k );

    S := SlideImage.Width shr 1;
    ImgRect := IRect( W, H );
    SlideImage.Left := SlideImage.Left + S - (W shr 1);
    SlideImage.Top  := SlideImage.Top  + S - (H shr 1);

    SlideImage.Width := W;
    SlideImage.Height := H;

    with DIBObj do
      N_StretchRect( SlideImage.Canvas.Handle, ImgRect,
                     DIBOCanv.HMDC, DIBRect ); //

    LbHead.Caption := ADlgText;

    FormStyle := fsStayOnTop;

    if AMDButtons = [] then
    begin
      if ADlgType = mtConfirmation then
        AMDButtons := [mbYes,mbNo]
      else
        AMDButtons := [mbOK];
    end;
    SA := K_CMGetMessageDlgTexts(AMDButtons);

    ButCount := Min( 1, High( SA ) );

    case ButCount of
      1: begin
       BtOK.Caption := SA[0];
       BtCancel.Caption := SA[1];
    end;
      0: BtCancel.Caption := SA[0];
     -1: BtCancel.Caption := 'OK';
    end;
{
    case ButCount of
       1: begin
        BtOK.Caption := K_GetStringFromVarRec( @AButCapts[0], 'Yes' );
        BtCancel.Caption := K_GetStringFromVarRec( @AButCapts[1], 'No' );
      end;
       0: BtCancel.Caption := K_GetStringFromVarRec( @AButCapts[0], 'OK' );
      -1: BtCancel.Caption := 'OK';
    end;
}
    if ButCount < 1 then
    begin
      BtCancel.ModalResult := mrOK;
      BtOK.Visible := FALSE;
    end;

    Result := ShowModal = mrOK;
  end;

end;

procedure TK_FormCMSlideIcon.FormShow(Sender: TObject);
begin
  if BtOK.Visible then
    BtOK.SetFocus()
  else
    BtCancel.SetFocus();
end;

end.
