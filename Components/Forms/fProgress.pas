unit fProgress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, N_BaseF, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.StdCtrls;

type
  TProgress = class(TN_BaseForm)
    lblStage: TLabel;
    pbProgress: TProgressBar;
    lblSubstage: TLabel;
  private
    { Private declarations }
  public
    procedure StepIt(AStage: string = ''; ASubStage: string = '');
  end;

var
  Progress: TProgress;

procedure ShowProgress(AOwner: TForm; AStage: string; AMin, AMax: integer; ASubstage: string = '');

implementation


{$R *.dfm}

procedure ShowProgress(AOwner: TForm; AStage: string; AMin, AMax: integer; ASubstage: string = '');
begin
  if Assigned(Progress) then
    FreeAndNil(Progress);

  Progress := TProgress.Create(AOwner);

  Progress.lblStage.Caption := AStage;
  Progress.pbProgress.Min := AMin;
  Progress.pbProgress.Max := AMax;
  Progress.pbProgress.Position := 1;
  Progress.lblSubstage.Caption := ASubstage;

  if not Assigned(AOwner) then
  begin
    Progress.Left := (Screen.WorkAreaWidth div 2) - (Progress.Width div 2);
    Progress.Top := (Screen.WorkAreaHeight div 2) - (Progress.Height div 2);
  end
  else
  begin
    Progress.Left := (AOwner.Width div 2) - (Progress.Width div 2) + AOwner.Left;
    Progress.Top := (AOwner.Height div 2) - (Progress.Height div 2) + AOwner.Top;
  end;

  Progress.Show;
end;

{ TProgress }

procedure TProgress.StepIt(AStage, ASubStage: string);
begin
  pbProgress.StepBy(1);
  pbProgress.StepBy(-1);
  pbProgress.StepBy(1);

  if not AStage.IsEmpty then
    lblStage.Caption := AStage;

  lblSubstage.Caption := ASubStage;
  lblSubstage.Visible := True;

  Application.ProcessMessages;
end;

end.
