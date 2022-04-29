unit N_PMTDiagrF;
// Show Photometry Diagram

interface

uses
  Forms, jpeg, StdCtrls, Classes, ExtCtrls, Controls;

type TN_PMTDiagrForm = class( TForm ) // Form to show Help Image
    Image: TImage;

//    procedure FormShow ( Sender: TObject );
  private
    { Private declarations }
  public
    { Public declarations }
//    procedure ShowImage( AFName : string );
end; // type TN_PMTDiagrForm = class( TForm ) // Form to show Help Image

var
  N_PMTDiagrForm: TN_PMTDiagrForm;

procedure N_ShowPMTDiagram();

implementation

{$R *.dfm}

uses
  Graphics, SysUtils,
  K_UDT2, K_CLib0, K_CLib,
  N_Lib1, N_Lib2, N_Gra2, N_Types, N_PMTMain5F, N_PMTVizF;

//***************************************************** N_ShowPMTDiagram ***
// Create and show PMTDiagrForm
//
procedure N_ShowPMTDiagram();
var
  FileName, FileName2: String;
begin
  if not Assigned(N_PMTDiagrForm) then // Create N_PMTDiagrForm
  begin
    N_PMTDiagrForm := TN_PMTDiagrForm.Create( Application );

    with N_PMTDiagrForm do
    begin
      Width  := 500;
      Height := 500;
      Left   := 200;
      Top    := 200;

      Show();
    end; // with N_PMTDiagrForm do
  end; // if not Assigned(N_PMTDiagrForm) then // Create N_PMTDiagrForm

  FileName := N_MemIniToString( 'PMTImages', 'PMT_Diagr', '' );
  FileName2 := K_ExpandFileName( FileName );
  N_Dump2Str( 'PMT DiagrFNames: "' + FileName + '", "' + FileName2 + '"' );
  K_LoadTImage( N_PMTDiagrForm.Image, FileName2 );

  N_PMTDiagrForm.Repaint();

  with N_PMTMain5Form do
  begin


  end; // with N_PMTMain5Form do

end; // procedure N_CreatePMTDiagrForm();

end.
