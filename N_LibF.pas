unit N_LibF;
// just the place for event handlers, and ActionLists,
// common to several Forms

interface

uses // should not use any own units
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  N_Types;

type TN_LibForm = class( TForm ) // dummy Form, just the place for event handlers
  private
  public
    procedure SetDestroyAfterClose( Sender: TObject; var Action: TCloseAction );
end; // TN_LibForm = class( TForm )

var                         // N_LibForm handlers can be used whithout
  N_LibForm: TN_LibForm;    // creating N_LibForm object

implementation
uses StdCtrls,
     N_Lib1, N_Gra0, N_Gra1;

procedure TN_LibForm.SetDestroyAfterClose( Sender: TObject;
                                              var Action: TCloseAction );
// set "Destroy Form" flag (OnClose event handler)
begin
  Action := caFree;
end; // end of procedure TN_LibForm.SetDestroyAfterClose

//************************* Global functions ***************

end.
