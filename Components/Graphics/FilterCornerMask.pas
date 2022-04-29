unit FilterCornerMask;

interface

uses
  Classes, WinApi.Windows, SysUtils, Graphics;

procedure FilterCornerMaskApply(var APicture: TGraphic; AColor: TColor = clBlack);

implementation

uses
  MagicWand;

function cmp(a, b: TColor): Boolean;
var
  ar, ag, ab, br, bg, bb, dr, dg, db: Byte;
begin
  ar := GetRValue(a);
  ag := GetGValue(a);
  ab := GetBValue(a);
  br := GetRValue(b);
  bg := GetGValue(b);
  bb := GetBValue(b);
  dr := Abs(ar - br);
  dg := Abs(ag - bg);
  db := Abs(ab - bb);
  if (dr + dg + db) < 30 then
    Result := true
  else
    Result := false;
end;

procedure FilterCornerMaskApply(var APicture: TGraphic; AColor: TColor = clBlack);
var
  InitColor: TColor;
  FilterRgn: HRGN;
  Brush: TBrush;
  Bitmap: TBitmap;
begin
  if not (APicture is TBitmap) then
    Exit;

  Bitmap := APicture as TBitmap;

  Bitmap.PixelFormat := pf32bit;

  Brush := TBrush.Create;
  try
    InitColor := Bitmap.Canvas.Pixels[2, 2];
    Brush.Color := AColor;

    FilterRgn := MagicWandSelect(Bitmap, Point(2, 2), cmp);

    // FrameRgn(pbPaint.Canvas.Handle,FilterRgn,Brush.Handle,1,1);
    FillRgn(Bitmap.Canvas.Handle, FilterRgn, Brush.Handle);

    if Bitmap.Canvas.Pixels[Bitmap.Width - 2, 2] <> Brush.Color then
    begin
      FilterRgn := MagicWandSelect(Bitmap, Point(Bitmap.Width - 2, 2), cmp);
      FillRgn(Bitmap.Canvas.Handle, FilterRgn, Brush.Handle);
    end;

    if Bitmap.Canvas.Pixels[2, Bitmap.height - 2]  <> Brush.Color  then
    begin
      FilterRgn := MagicWandSelect(Bitmap, Point(2, Bitmap.height - 2), cmp);
      FillRgn(Bitmap.Canvas.Handle, FilterRgn, Brush.Handle);
    end;

    if Bitmap.Canvas.Pixels[Bitmap.Width - 2, Bitmap.height - 2]  <> Brush.Color then
    begin
      FilterRgn := MagicWandSelect(Bitmap, Point(Bitmap.Width - 2, Bitmap.height - 2), cmp);
      FillRgn(Bitmap.Canvas.Handle, FilterRgn, Brush.Handle);
    end;
  finally
    FreeAndNil(Brush);
  end;
end;

end.
