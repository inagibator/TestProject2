unit N_PMTHelp2F;
// Show Photometry Params Help Image

interface

uses
  Forms, jpeg, StdCtrls, Classes, ExtCtrls, Controls;

type TN_PMTHelp2Form = class( TForm ) // Form to show Help Image
    Image: TImage;
    Label1: TLabel;
    Label2: TLabel;

end; // type TN_PMTHelp2Form = class( TForm ) // Form to show Help Image

var
  N_PMTHelp2Form: TN_PMTHelp2Form;

procedure N_ShowPMTHelp2Image ( AParInd: integer );

implementation

{$R *.dfm}

uses
  Graphics, SysUtils,
  K_UDT2, K_CLib0, K_CLib,
  N_Lib1, N_Lib2, N_Gra2, N_Types, N_PMTMain5F, N_PMTVizF;

//***************************************************** N_ShowPMTHelp2Image ***
// Create PMTHelp2Form if not yet and show HelpImage using given AParInd
//
// AParInd - Given Parametr Index (same as in PMTResults and PMTResNames Arrays)
//
// Фас:
//     n–sn/sn–gn    0 = F1 (PMT_F1.png)
//     sn-st/st-gn   1 = F2
//  /_ st-st/n-sn    2 = F3
//  /_ sn-n-gn       3 = F4
//  Профиль:
//  /_ n/sn/pg       4 = S1
//  /_ Po/n/sn       5 = S2
//  /_ Po/n/sm       6 = S4
//  /_ Po/n/pg       7 = S3
//  /_ ta-tp/sn-n    8 = S5
//     Po-n/Po-sn    9 = S6
//     Po-n/Po-sto   10 = S6
//     Po-n/Po-pg    11 = S6
//     Po-n/PLV-sn   12 = S7
//     Po-n/PLV-sto  13 = S7
//     Po-n/PLV-pg   14 = S7
//  Фас-Профиль:
//  Po(R)-Po(L)/Po-n 15 = FS1
//
procedure N_ShowPMTHelp2Image( AParInd: integer );
var
  CenterY: Integer;
  ParName, FileName, FileName2, HelpFNameInIniFile: String;
begin
  if not Assigned(N_PMTHelp2Form) then // Create N_PMTHelp2Form
  begin
    N_PMTHelp2Form := TN_PMTHelp2Form.Create( Application );

    with N_PMTHelp2Form do
    begin
      Width  := 260;
      Height := 510;

      if N_PMTMain5Form.PMTCurRFrameInd = 0 then // Front Point
      begin
        Left := 200;
      end else // PMTCurRFrameInd = 1 - Side Point
      begin
        Left := 200;
      end; // else // PMTCurRFrameInd = 1 - Side Point

      CenterY := 450;
      Top := CenterY - Height div 2;

//      Image.Left := 20;
//      Image.Top  := 30;
//      Image.Width := Width;
      Image.Height := Height - 50;

//      Label1.Top := Height - 75;

      Show();
    end; // with N_PMTHelp2Form do
  end else // if not Assigned(N_PMTHelp2Form) then // Create N_PMTHelp2Form
    N_PMTHelp2Form.Show();

  // Load needed Help Image

  HelpFNameInIniFile := 'PMTH_' + N_PMTMain5Form.PMTHelpNames[AParInd];
  FileName := N_MemIniToString( 'PMTImages', HelpFNameInIniFile, '' );
  N_Dump2Str( 'PMT HelpFName: "' + FileName );
  FileName2 := K_ExpandFileName( FileName );
  K_LoadTImage( N_PMTHelp2Form.Image, FileName2 );

  ParName := N_PMTMain5Form.PMTResNames[AParInd];

  if ParName[1] = '/' then // Is Angle
    N_PMTHelp2Form.Label1.Caption := 'Угловой параметр:'
  else // Not an Angle
    N_PMTHelp2Form.Label1.Caption := 'Индексный показатель:';

  N_PMTHelp2Form.Label2.Caption := ParName;

//  if ParName[1] = '\' then // Is Angle
//    ParName := 'Угловой параметр:  ' + ParName
//  else // Not an Angle
//    ParName := 'Индексный показатель:  ' + ParName;


  N_PMTHelp2Form.Repaint();
  
end; // procedure N_CreatePMTHelp2Form();

end.
