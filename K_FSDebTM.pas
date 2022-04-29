unit K_FSDebTM;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ValEdit, StdCtrls, Mask, ComCtrls;

type
  TK_FormDebParams = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label2: TLabel;
    EdFileName: TEdit;
    Button1: TButton;
    ChBShowDumpInStatusBar: TCheckBox;
    Button2: TButton;
    Button3: TButton;
    OpenDialog1: TOpenDialog;
    TabSheet2: TTabSheet;
    MaskEditDWinWidth: TMaskEdit;
    Label3: TLabel;
    Label4: TLabel;
    MaskEditDWinHeight: TMaskEdit;
    ChBShowDWindow: TCheckBox;
    Button4: TButton;
    Button5: TButton;
    ChBDumpInitSection: TCheckBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    MEWWinCapacity: TMaskEdit;
    MEWWinLeft: TMaskEdit;
    MEWWinTop: TMaskEdit;
    MEWWinWidth: TMaskEdit;
    MEWWinHeight: TMaskEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ChBShowDWindowClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormDebParams: TK_FormDebParams;

implementation

{$R *.dfm}

procedure TK_FormDebParams.Button1Click(Sender: TObject);
begin
  OpenDialog1.FileName := EdFileName.Text;
  if OpenDialog1.Execute then
    EdFileName.Text := OpenDialog1.FileName;
end;

procedure TK_FormDebParams.FormShow(Sender: TObject);
begin
  MaskEditDWinWidth.Enabled := ChBShowDWindow.Checked;
  MaskEditDWinHeight.Enabled := ChBShowDWindow.Checked;
end;

procedure TK_FormDebParams.ChBShowDWindowClick(Sender: TObject);
begin
  MaskEditDWinWidth.Enabled := ChBShowDWindow.Checked;
  MaskEditDWinHeight.Enabled := ChBShowDWindow.Checked;
end;

end.
