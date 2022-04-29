unit N_PixMesFr;
// Pixel Measurement Frame for measuring distance and picking Color in other Applications Windows

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  N_Types;

type TN_PixMesFrame = class( TFrame )
    edCurColor: TEdit; // Frame for measuring distance and picking Color

    procedure edCurColorMouseDown ( Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
    procedure edCurColorMouseMove ( Sender: TObject; Shift: TShiftState; X, Y: Integer );
    procedure edCurColorMouseUp   ( Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
  public
    PrevMouseUp: TPoint;  // Previous MouseUp point Screen coords
    DragMode: boolean;    // is True while dragging
    SavedCursor: TCursor; // used while dragging
    OnMouseUpProcObj: TN_ThreeIntsProcObj; // Proc of Obj, called On MouseUp event
end; // type TN_PixMesFrame = class( TFrame )

implementation

{$R *.dfm}

procedure TN_PixMesFrame.edCurColorMouseDown( Sender: TObject;
                      Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
// begin dragging - choosing color by pixel under cursor while dragging
begin
  DragMode := True;
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHandPoint;
end; // procedure TN_PixMesFrame.edCurColorMouseDown

procedure TN_PixMesFrame.edCurColorMouseMove( Sender: TObject;
                                          Shift: TShiftState; X, Y: Integer );
// set current color by color of any screen pixel that is under cursor (while dragging)
// (you can DRAG cursor out of self windows with getting MouseMove events!)
var
  ScreenHDC: HDC;
begin
  if not DragMode then Exit;

  ScreenHDC := windows.GetDC( 0 );
  with Mouse.CursorPos do
    edCurColor.Color := windows.GetPixel( ScreenHDC, X, Y );
end; // procedure TN_PixMesFrame.edCurColorMouseMove

procedure TN_PixMesFrame.edCurColorMouseUp( Sender: TObject;
                      Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
// finish dragging (color was already set in OnMouseMove handler)
var
  ScreenHDC: HDC;
begin
  if not DragMode then Exit;

  ScreenHDC := windows.GetDC( 0 );
  with Mouse.CursorPos do
    edCurColor.Color := windows.GetPixel( ScreenHDC, X, Y );
  DragMode := False;
  Screen.Cursor := SavedCursor;

  if Assigned( OnMouseUpProcObj ) then
  begin
    ScreenHDC := windows.GetDC( 0 );

    with Mouse.CursorPos do
      OnMouseUpProcObj( X,Y, windows.GetPixel( ScreenHDC, X, Y ) );
  end;
end; // procedure TN_PixMesFrame.edCurColorMouseUp


end.
