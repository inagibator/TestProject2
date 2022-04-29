unit N_PMTVizF;
// Photometry Vizard Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  N_Types, N_Lib1, N_BaseF, Grids, ExtCtrls;

type TN_PMTVizForm = class( TForm )
    StringGrid: TStringGrid; // Photometry Vizard Form

  procedure FormClose( Sender: TObject; var Action: TCloseAction );
  public
end; // type TN_PMTVizForm = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

var
  N_PMTVizForm: TN_PMTVizForm;

implementation

uses N_CMMain5F, N_PMTMain5F, N_CMResF, N_PMTHelpF;
{$R *.dfm}

//****************  TN_PMTVizForm class handlers  ******************

//*********************************************** TN_PMTVizForm.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_PMTVizForm.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  N_PMTMain5Form.PMTTimer.Enabled := False;
  N_CMResForm.aEditPointExecute( nil );
  Action := caFree;

  if N_PMTHelpForm <> nil then
    N_PMTHelpForm.Close;

  N_PMTHelpForm := nil;
  N_CM_MainForm.CMMFShowStringByTimer( '' ); // Clear Statusbar

end; // procedure TN_PMTVizForm.FormClose



end.
