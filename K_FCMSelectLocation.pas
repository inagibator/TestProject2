unit K_FCMSelectLocation;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls;

type
  TK_FormCMSelectLoc = class(TN_BaseForm)
    LbComments: TLabel;
    BtCancel: TButton;
    BtOK: TButton;
    LbLoc: TLabel;
    CmBLocList: TComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMSelectLoc: TK_FormCMSelectLoc;

  function  K_CMEMSelectLocationDlg( ) : Integer;

implementation

{$R *.dfm}

uses DateUtils,
  N_Types, N_Lib1,
  K_CM0;

function  K_CMEMSelectLocationDlg( ) : Integer;
begin

  with TK_FormCMSelectLoc.Create(Application) do
  begin
//    BaseFormInit ( nil, '', [fvfCenter] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    Result := -1;
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      if EDAEMGetLocCaptsList( CmBLocList.Items ) <> K_edOK then Exit;
      CmBLocList.ItemIndex := CmBLocList.Items.IndexOfObject( TObject(CurLocID) )
    end;

    if ShowModal <> mrOK then Exit;
    // Return selected Location ID
    with CmBLocList do
      if ItemIndex <> -1 then
        Result := Integer(Items.Objects[ItemIndex]);

  end;


end;

end.
