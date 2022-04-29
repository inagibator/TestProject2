unit N_MapEdFr;
// Map Layers Editor Frame

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_Rast1Fr, ExtCtrls, Menus, ActnList, StdCtrls;

type TN_MapEdFrame = class( TN_Rast1Frame ) //***** Map Layers Editor Frame
    MapEdFrameActList: TActionList;
    aDebDeb1: TAction;
    procedure aDebDeb1Execute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
end; // type TN_MapEdFrame = class( TN_Rast1Frame )



implementation
uses math, clipbrd,
  N_Gra2, N_Lib0, N_Lib2, N_ButtonsF;

{$R *.dfm}

procedure TN_MapEdFrame.aDebDeb1Execute( Sender: TObject );
// Deb 1
begin
  N_WarnByMessage( 'from aDebDeb1Execute' );

end; // procedure TN_MapEdFrame.aDebDeb1Execute

end.
