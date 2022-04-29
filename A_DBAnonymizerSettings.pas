unit A_DBAnonymizerSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TDBAnonymizerSettings = class(TForm)
    cbPatients: TCheckBox;
    cbProviders: TCheckBox;
    cbLocations: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DBAnonymizerSettings: TDBAnonymizerSettings;

implementation

{$R *.dfm}

end.
