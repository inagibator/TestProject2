unit ViewerTabSheet;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  VCL.ComCtrls;

type
  TViewerTabSheet = class(TTabSheet)
  protected
    FCloseButtonRect: TRect;
    FOnClose: TNotifyEvent;
    procedure DoClose; virtual;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;

    procedure Close;

    property CloseButtonRect: TRect read FCloseButtonRect write FCloseButtonRect;
    property OnClose:TNotifyEvent read FOnClose write FOnClose;
  end;

implementation

{ TViewerHolderTabSheet }

procedure TViewerTabSheet.Close;
begin
  DoClose;
end;

constructor TViewerTabSheet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCloseButtonRect:=Rect(0, 0, 0, 0);
end;

destructor TViewerTabSheet.Destroy;
begin
  inherited;
end;

procedure TViewerTabSheet.DoClose;
begin
  if Assigned(FOnClose) then FOnClose(Self);
end;

end.
