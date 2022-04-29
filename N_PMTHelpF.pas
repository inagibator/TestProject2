unit N_PMTHelpF;
// Show Photometry Point Help Image

interface

uses
  Forms, jpeg, StdCtrls, Classes, ExtCtrls, Controls;

type TN_PMTHelpForm = class( TForm ) // Form to show Help Image
    Image: TImage;

//    procedure FormShow ( Sender: TObject );
  private
    { Private declarations }
  public
    { Public declarations }
//    procedure ShowImage( AFName : string );
end; // type TN_PMTHelpForm = class( TForm ) // Form to show Help Image

var
  N_PMTHelpForm: TN_PMTHelpForm;

procedure N_ShowPMTHelpImage();

implementation

{$R *.dfm}

uses
  Graphics, SysUtils,
  K_UDT2, K_CLib0, K_CLib,
  N_Lib1, N_Lib2, N_Gra2, N_Types, N_PMTMain5F, N_PMTVizF;

//****************************************************** N_ShowPMTHelpImage ***
// Create PMTHelpForm if not yet and show HelpImage using
// PMTCurRFrameInd and PMTCurVizardInd
//
procedure N_ShowPMTHelpImage();
var
  CenterY: Integer;
  FileName, FileName2, PointNameInIniFile: String;
begin
  if not Assigned(N_PMTHelpForm) then // Create N_PMTHelpForm
  begin
    N_PMTHelpForm := TN_PMTHelpForm.Create( Application );

    with N_PMTHelpForm do
    begin
      Width  := 320;
      Height := 480;

      if N_PMTMain5Form.PMTCurRFrameInd = 0 then // Front Point
      begin
        Left := N_PMTVizForm.Left + N_PMTVizForm.Width + 2;
      end else // PMTCurRFrameInd = 1 - Side Point
      begin
        Left := N_PMTVizForm.Left - Width - 2;
      end; // else // PMTCurRFrameInd = 1 - Side Point

      CenterY := N_PMTVizForm.Top + N_PMTVizForm.Height div 2;
      Top := CenterY - Height div 2;

      Show();
    end; // with N_PMTHelpForm do
  end; // if not Assigned(N_PMTHelpForm) then // Create N_PMTHelpForm

  with N_PMTMain5Form do
  begin
    if PMTCurRFrameInd = 0 then // Front Point
    begin
      PointNameInIniFile := 'PMTF_' + PMTFrontPNames[PMTCurVizardInd];
      N_PMTHelpForm.Caption := 'Front Point  ' + PMTFrontPNames[PMTCurVizardInd];
    end else // PMTCurRFrameInd = 1 - Side Point
    begin
      PointNameInIniFile := 'PMTS_' + PMTSidePNames[PMTCurVizardInd];
      N_PMTHelpForm.Caption := 'Side Point  ' + PMTSidePNames[PMTCurVizardInd];
    end;
  end; // with N_PMTMain5Form do

  FileName := N_MemIniToString( 'PMTImages', PointNameInIniFile, '' );
  FileName2 := K_ExpandFileName( FileName );
  N_Dump2Str( 'PMT HelpFNames: "' + FileName + '", "' + FileName2 + '"' );
  K_LoadTImage( N_PMTHelpForm.Image, FileName2 );

  N_PMTHelpForm.Repaint();
end; // procedure N_CreatePMTHelpForm();

{
//**************************************** N_CreatePMTHelpForm ***
// Create PMTHelpForm in N_PMTHelpForm if not yet (with empty Image)
//
procedure N_CreatePMTHelpForm();
begin
  if not Assigned(N_PMTHelpForm) then // Create N_PMTHelpForm
  begin
    N_PMTHelpForm := TN_PMTHelpForm.Create( Application );

    with N_PMTHelpForm do
    begin
      DoubleBuffered := TRUE;

      Left := 100;
      Top  := 200;
      Width  := 200;
      Height := 200;

      Show();
//      Refresh();

    end; // with N_PMTHelpForm do

  end; // if not Assigned(N_PMTHelpForm) then // Create N_PMTHelpForm

end; // procedure N_CreatePMTHelpForm();

procedure K_SplashScreenShow( AImageFName: String );
begin
  if AImageFName <> '' then
  begin
    N_PMTHelpForm := TN_PMTHelpForm.Create( Application );
    N_PMTHelpForm.DoubleBuffered := TRUE;
    N_PMTHelpForm.Caption := AImageFName;
    N_PMTHelpForm.Show();
    N_PMTHelpForm.Refresh();
  end;
end; // procedure K_SplashScreenShow

procedure K_SplashScreenHide();
begin
  if N_PMTHelpForm <> nil then
    N_PMTHelpForm.Close;
  N_PMTHelpForm := nil;
end; // procedure K_SplashScreenHide

procedure TN_PMTHelpForm.FormShow(Sender: TObject);
begin
  if Caption = '' then Exit;
  ShowImage( Caption );
end; // procedure TN_PMTHelpForm.FormShow

procedure TN_PMTHelpForm.ShowImage( AFName : string );
begin
//    VColor := K_LoadTImage( Image, 'C:\Delphi_prj_new\DTMP\CMS Test Data\Test.png' );
//    VColor := N_LoadTImage( Image, K_ExpandFileName(AFName), FALSE );
  K_LoadTImage( Image, K_ExpandFileName(AFName) );

//  ClientHeight := Image.Picture.Height;
//  if ClientHeight = 0 then ClientHeight := 200;
//  ClientWidth := Image.Picture.Width;
//  if ClientWidth = 0 then ClientWidth := 200;
end; // procedure TN_PMTHelpForm.ShowImage

}
end.
