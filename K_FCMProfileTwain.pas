unit K_FCMProfileTwain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  K_FCMProfileDevice;

type
  TK_FormCMProfileTwain = class(TK_FormCMProfileDevice)
    bnSpecial: TButton;
    procedure bnSpecialClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMProfileTwain: TK_FormCMProfileTwain;

implementation

uses Types,
  K_CM0, K_FSFList, N_Types{, N_Lib1}, N_BaseF, K_CML1F, K_FCMTwainASettings;
{$R *.dfm}

procedure TK_FormCMProfileTwain.bnSpecialClick(Sender: TObject);
var
//  IMode : Integer;
  CurProductName, CurTWAINMode :  string;
begin
//  inherited;
//  if K_CMDesignModeFlag then
    with PEPCMDeviceProfile^ do
    begin
      CurProductName := CmBDevices.Text;
      CurTWAINMode := CMDPStrPar1;
      K_CMDeviceProfileAutoTWAINMode( CurTWAINMode, CurProductName );
      if K_CMProfileTwainASettingsDlg( CurTWAINMode ) then
        CMDPStrPar1 := CurTWAINMode;
    end;
{
  else
    with TK_FormSelectFromList.Create(Application) do
    begin
      Caption := K_CML1Form.LLLDevProfile4.Caption;//'TWAIN mode';
      SelectListBox.Color := $00A2FFFF;
      SetItemsList( nil );
      CurListBox.Items.Clear();
      CurListBox.Items.Add( 'Mode 1' );
      CurListBox.Items.Add( 'Mode 2' );
      CurListBox.Items.Add( 'Mode 3' );

      BFIniSize := Point( 100, 150 );
      BaseFormInit( nil, 'TWAINModeForm', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

      CurProductName := CmBDevices.Text;
      with PEPCMDeviceProfile^  do
      begin
        CurTWAINMode := CMDPStrPar1;
        K_CMDeviceProfileAutoTWAINMode( CurTWAINMode, CurProductName );
        IMode := 0; // TWAIN mode 1
        if CurTWAINMode = '2' then // TWAIN mode 2
          IMode := 1
        else if CurTWAINMode = '3' then // TWAIN mode 3
          IMode := 2;
        if not SelectElement( IMode ) then Exit;
        case IMode of
        0 : CMDPStrPar1 := '1';
        1 : CMDPStrPar1 := '2';
        2 : CMDPStrPar1 := '3';
        end;
      end;
    end;
}
end;

end.
