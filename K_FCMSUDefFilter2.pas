unit K_FCMSUDefFilter2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ExtCtrls, K_FrCMTeethChart1, StdCtrls;

type
  TK_FormCMSUDefFilter2 = class(TN_BaseForm)
    K_FrameCMTeethChart11: TK_FrameCMTeethChart1;
    Button2: TButton;
    Button1: TButton;
    Button3: TButton;
    GbMediaTypes: TGroupBox;
    CmBMediaTypes: TComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMSUDefFilter2: TK_FormCMSUDefFilter2;

implementation

{$R *.dfm}

end.
