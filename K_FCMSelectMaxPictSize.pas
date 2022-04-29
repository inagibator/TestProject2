unit K_FCMSelectMaxPictSize;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ExtCtrls, StdCtrls;

type
  TK_FormCMSelectMaxPictSize = class(TN_BaseForm)
    BtOK: TButton;
    BtCancel: TButton;
    RGSizes: TRadioGroup;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMSelectMaxPictSize: TK_FormCMSelectMaxPictSize;

function K_CMSelectMaxPictSizeDlg( var AInd : Integer ) : Boolean;

implementation

{$R *.dfm}

uses N_Types;

function K_CMSelectMaxPictSizeDlg( var AInd : Integer ) : Boolean;
begin
  with TK_FormCMSelectMaxPictSize.Create(Application) do begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    RGSizes.ItemIndex := AInd;
    Result := ShowModal() = mrOK;
    if Result then
    begin
      AInd := RGSizes.ItemIndex;
      N_Dump1Str( 'Select Attached Files Size Ind=' + IntToStr(AInd) );
    end
    else
      N_Dump1Str( 'Cancel Attached Files Size Selection' );
  end;
end;

end.
