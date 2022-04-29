unit K_FCMProfileOther2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  K_FCMProfileOther1, K_CMCaptDevReg;

type
  TK_FormCMProfileOther2 = class(TK_FormCMProfileOther1)
    procedure FormShow          ( Sender: TObject );
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMProfileOther2: TK_FormCMProfileOther2;

implementation

{$R *.dfm}

uses
N_Types, N_Lib0,
K_CM0;

{ TK_FormCMProfileOther2 }

procedure TK_FormCMProfileOther2.FormShow(Sender: TObject);
begin
//
  //*** Prepare CmBDevices.Items
  if K_CMCaptDevCaptsOrdered3DList = nil then
  begin
    N_CurMemIni.ReadSectionValues( 'RegionDevCapts', K_CMEDAccess.TmpStrings );
    if K_CMEDAccess.TmpStrings.Count > 0 then
      K_CMCDRenameRegistered( K_CMEDAccess.TmpStrings );
    K_CMCaptDevCaptsOrdered3DList := TStringList.Create;
    K_CMCDGetRegCaptions3D( K_CMCaptDevCaptsOrdered3DList );
    K_CMCaptDevCaptsOrdered3DList.Sort;
  end;

  CmBDevices.Items.Clear;
  CmBDevices.Items.AddStrings( K_CMCaptDevCaptsOrdered3DList );
  SkipInheritedFormShow := TRUE;

  inherited;

end;

end.
