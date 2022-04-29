unit K_FCMAltShiftMEnter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls;

type
  TK_FormCMAltShiftMEnter = class(TN_BaseForm)
    LbConfirmation: TLabel;
    BtCancel: TButton;
    BtOK: TButton;
    Image: TImage;
    LbPassword: TLabel;
    EdPassword: TEdit;
    procedure FormShow(Sender: TObject);
    procedure EdPasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMAltShiftMEnter: TK_FormCMAltShiftMEnter;

  function  K_CMAltShiftMConfirmDlg( ) : Boolean;
  function  K_CMSpecialSettingsConfirmDlg( ) : Boolean;

implementation

{$R *.dfm}

uses DateUtils,
  N_Types, N_Lib1,
  K_CLib0, K_CM0, K_CML1F;

function K_CMAltShiftMConfirmDlg( ) : Boolean;
begin
  with TK_FormCMAltShiftMEnter.Create(Application) do
  begin
//    BaseFormInit ( nil, '', [fvfCenter] );
    N_Dump2Str( '!!! Start AltShiftMConfirmDlg' );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );

    Image.Picture.Icon.Handle := LoadIcon(0, IDI_EXCLAMATION);

    Result := ShowModal = mrOK;

    if not Result then Exit;
    Result := K_CMDesignModeFlag or 
              ( EdPassword.Text = K_DateTimeToStr( Date(), 'ddmmyy' ) );
    if not Result then
    begin
      N_Dump1Str( '!!! Wrong AltShiftM password >> ' + EdPassword.Text );
      K_CMShowMessageDlg( K_CML1Form.LLLWrongPassword.Caption,
//          ' Wrong password ',
                          mtWarning, [], TRUE  );
    end;
  end; // with TK_FormCMAltShiftMEnter.Create(Application) do
end; // function K_CMAltShiftMConfirmDlg

function  K_CMSpecialSettingsConfirmDlg( ) : Boolean;
var
  PSW : string;
//  WPSW: string;
begin

  with TK_FormCMAltShiftMEnter.Create(Application) do
  begin
//    BaseFormInit ( nil, '', [fvfCenter] );
    N_Dump2Str( '!!! Start SpecialSettingsConfirmDlg' );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    Caption := 'Special settings confirmation';

    Image.Picture.Icon.Handle := LoadIcon(0, IDI_EXCLAMATION);

    Result := ShowModal = mrOK;

    if not Result then Exit;

    if K_CMDesignModeFlag then Exit;

    Result := 'DICOM' = Copy(EdPassword.Text, 1, 5 );
    if Result then
    begin
      PSW := Copy(EdPassword.Text, 6, Length(EdPassword.Text) ); // Entered Password
      Result := SameText( PSW, IntToStr( DayOfTheMonth(Date()) * 3 - 2 ) ); // 1-st Enter - Only Master Password should be used
{
      WPSW := N_MemIniToString('CMS_Main', 'EGAPassword', '');   // Saved Password
      Result := WPSW <> '';
      if Result then
        Result := SameText( PSW, WPSW );
      if not Result then
        Result := SameText( PSW, IntToStr( DayOfTheMonth(Date()) * 3 - 2 ) ); // 1-st Enter - Only Master Password should be used
}
    end;

    if not Result then
    begin
      N_Dump1Str( '!!! Wrong SpecialSettingsConfirm password >> ' + EdPassword.Text );
      K_CMShowMessageDlg( K_CML1Form.LLLWrongPassword.Caption,
//          ' Wrong password ',
                          mtWarning, [], TRUE  );
    end;

  end;


end;

procedure TK_FormCMAltShiftMEnter.FormShow(Sender: TObject);
begin
  EdPassword.SelectAll;
  EdPassword.SetFocus;
end;

procedure TK_FormCMAltShiftMEnter.EdPasswordKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;
  ModalResult := mrOK;
end;

end.
