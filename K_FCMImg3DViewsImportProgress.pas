unit K_FCMImg3DViewsImportProgress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ExtCtrls, ComCtrls;

type
  TK_FormCMImg3DViewsImportProgress = class(TN_BaseForm)
    StatusBar: TStatusBar;
    PBProgress: TProgressBar;
  private
    { Private declarations }
  public
    { Public declarations }
    IMaxCount : Integer;
    ICurCount : Integer;
    procedure Img3DViewsShowProgress( AFName : string );
  end;

var
  K_FormCMImg3DViewsImportProgress: TK_FormCMImg3DViewsImportProgress;

implementation

{$R *.dfm}

procedure TK_FormCMImg3DViewsImportProgress.Img3DViewsShowProgress( AFName : string );
begin
  Inc( ICurCount );
  PBProgress.Position := Round( ICurCount / IMaxCount * (PBProgress.Max - PBProgress.Min) );
  StatusBar.Panels[0].Text := format( ' %d of %d', [ICurCount, IMaxCount] );
  StatusBar.Panels[1].Text := ' ' + ExtractFileName( AFName );
  StatusBar.Refresh();
end;

end.
