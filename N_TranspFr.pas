unit N_TranspFr;
// Transparent Frame

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type TN_TranspFrame = class( TFrame )
    procedure WMEraseBkgnd ( var m: TWMEraseBkgnd ); message WM_ERASEBKGND;
  public
    TFDrawBacground: boolean;
end; // type TN_TranspFrame = class( TFrame )

implementation

{$R *.dfm}

//********************************************* TN_TranspFrame.WMEraseBkgnd ***
// prevent processing Windows message EraseBkgnd (Erase Background)
//
procedure TN_TranspFrame.WMEraseBkgnd( var m: TWMEraseBkgnd );
begin
  // m.Result=False means disable drawing background
  m.Result := LRESULT(TFDrawBacground);
end; // end of procedure TN_TranspFrame.WMEraseBkgnd


end.
