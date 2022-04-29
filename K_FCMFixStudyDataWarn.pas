unit K_FCMFixStudyDataWarn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls;

type
  TK_FormCMFixStudyDataWarn = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    Image: TImage;
    Memo1: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMFixStudyDataWarn: TK_FormCMFixStudyDataWarn;

  function  K_CMFixStudyDataWarnDlg( ) : Boolean;

implementation

{$R *.dfm}

uses
  N_Types, N_Lib0;

function K_CMFixStudyDataWarnDlg( ) : Boolean;
begin
  with TK_FormCMFixStudyDataWarn.Create(Application) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );

    Image.Picture.Icon.Handle := LoadIcon(0, IDI_WARNING);

    Result := ShowModal = mrOK;
    N_Dump1Str( 'K_CMFixStudyDataWarnDlg Result=' + N_B2S(Result) );

    if not Result then Exit;
  end; // with TK_FormCMAltShiftMEnter.Create(Application) do
end; // function K_CMFixStudyDataWarnDlg

end.
