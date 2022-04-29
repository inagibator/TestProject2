unit K_FMVTSImpUnRegs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  K_FMVBase, K_FrRaEdit;

type
  TK_FormMVTSImpUnRegs = class(TK_FormMVBase)
    procedure FormCreate( Sender: TObject );
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure CellCheckDisable( var Disable : TK_RAFDisabled; ACol, ARow : Integer );
  public
    { Public declarations }
  end;

var
  K_FormMVTSImpUnRegs: TK_FormMVTSImpUnRegs;

implementation

uses K_Script1;

{$R *.dfm}

{*** TK_FormMVTSImpUnRegs ***}

procedure TK_FormMVTSImpUnRegs.CellCheckDisable( var Disable: TK_RAFDisabled;
                                                 ACol, ARow: Integer );
begin

  with TK_PRArray(PData)^ do begin
    Disable := K_rfdEnabled;

    if (ARow >= 0) and
       ((PByte(P(ARow))^ and $F0) <> 0) then
      Disable := K_rfdRowDisabled;
//      Disable := K_rfdCellDisabled;
  end;

end;

procedure TK_FormMVTSImpUnRegs.FormCreate( Sender: TObject );
begin
  inherited;
  FrameRAEdit.OnCellCheckDisable := CellCheckDisable;
end;

{*** end of TK_FormMVTSImpUnReg ***}

procedure TK_FormMVTSImpUnRegs.FormShow(Sender: TObject);
begin
  inherited;
  FrameRAEdit.CDescr.ModeFlags := FrameRAEdit.CDescr.ModeFlags - [K_ramShowLRowNumbers]; 
end;

end.
