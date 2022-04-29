unit N_Tst1;
// high level test procedures

interface
uses Windows, SysUtils, Classes, Graphics, Forms, Types;

var
  N_Gi: integer;

procedure N_CalcEpsilons ();
procedure N_CoordsTest   ();
procedure N_TestPrint1   ();
procedure N_TestPrint2   ();
procedure N_TestPrint3   ();
procedure N_TestPrint4   ();
procedure N_TestDrawCopyRect1 ();
procedure N_TestDrawEllipse1();
procedure N_TestWinTransform1 ();
procedure N_DecPointsTest  ();
procedure N_CoordsConvTest ();
procedure N_TestRectLinesLists ();
procedure N_TestFloatAccuracy  ();
procedure N_Tst1StringMemoryCheck ();
procedure N_Tst1FastTimer         ();
procedure N_CObjectsCreateTest    ();
procedure N_CObjectsLoadSaveTest  ();
procedure N_LibrariesLoadSaveTest ();
procedure N_DeleteInsertArrayElemsTest ();
procedure N_PascalTest1    ();
procedure N_CopyArrayTest1 ();
procedure N_ReallocArraySpeed1 ();
procedure N_TestDBF1           ();
procedure N_TestSortPointers1  ();
procedure N_TestSortPointers2  ();
procedure N_TestStrEdit2       ();
procedure N_Test2DFunc1        ();
procedure N_TstRaramsForm      ();
procedure N_TstCreateOCanv     ();
procedure N_TstCyrToLat        ();
procedure N_TstRectsConvObj    ();
procedure N_TstMatrConvObj     ();
procedure N_TstEditParamsForm1 ();
procedure N_TstMVTATest1       ();
procedure N_TstWordActDoc1     ();
procedure N_TstBrackets        ();
procedure N_TstSpecCharsToHex  ();
function  N_TstStatTest1 ( ASL: TStringList ): integer;
function  N_TstStatTest2 ( ASL: TStringList ): integer;
procedure N_TstCNKInds          ();
procedure N_TstSplitIntegerValue();
procedure N_TstSPLToBinSpeed    ();
procedure N_TstRastr1FrConvFunc ();
procedure N_TstUseDLL           ( AHandle: integer );
//procedure N_TstPanelsForm       ();
procedure N_TstIPCTest1         ();
procedure N_TstPackedInts       ();
procedure N_TstNIRs             ();
procedure N_TstMemAlloc1        ();
procedure N_TstMemAlloc2        ();
procedure N_TstDIBCoords        ();
procedure N_TstConvMemToHex     ();
procedure N_TstAllSpeedTest1    ();
procedure N_TstTimers           ();
procedure N_TstValProc          ();
procedure N_TstCheckDLLFunc     ();
procedure N_TstDatime           ();
procedure N_TstPChars           ();
procedure N_TstCodePages1       ();
procedure N_TstStrMatrSorting   ();
procedure N_TstConvRGBToGray    ();
procedure N_TstShowShapeInfo    ();
procedure N_TstWinGDI_1         ();
procedure N_TstOCanvDraw_1      ();
procedure N_TstOCanvDraw_2      ();
procedure N_TstHexToInt         ();
procedure N_TstBrighHist1       ();
procedure N_TstMaxFreeMem       ();
procedure N_TstDIBToTXT         ();
procedure N_TstAllocmemTime     ();
procedure N_TestImageFile       ( AFileName: String );
procedure N_TstScreenGrabber    ();
procedure N_TstEnumResources    ();



implementation
uses Printers, Dialogs, Controls, ExtCtrls, Messages, Math,
  K_CLib0, K_UDT1, K_Script1, K_SParse1, K_Parse,
  N_Types, N_Lib2, N_GCont, N_Comp1, N_UDCMap,
  N_Lib1, N_Gra0, N_Gra1, N_Gra2, N_Gra3, N_ExpImp1, N_StatFunc,
  N_Lib0, N_Rast1Fr, K_VFunc, K_UDConst, K_UDC, N_2DFunc1,
  N_ME1, N_InfoF, N_Deb1, N_UDat4, // N_CMExtDLL, N_CMSUtilsLib1,
  N_EdStrF, N_EdParF,
  N_RVCTF; //, N_ImpF;


var
  N_TstRastVCTForm: TN_RastVCTForm; // should be global, because it will be set to nil in OnClose

procedure N_CalcEpsilons();
// Calc several Epsilons
begin
  N_f := 1.0; //************ float
  N_p := @N_f;
  PByte(N_p)^ := PByte(N_p)^ + 1;
  N_f1 := N_f - 1.0; // 1.1920928955e-7

  N_d := 1.0; //************ double
  N_p := @N_d;
  PByte(N_p)^ := PByte(N_p)^ + 1;
  N_d1 := N_d - 1.0; // 2.2204460493e-16

  N_ex := 1.0; //************ extended
  N_p := @N_ex;
  PByte(N_p)^ := PByte(N_p)^ + 1;
  N_ex1 := N_ex - 1.0; // 1.0842021725e-19

  N_i := 0;
end;

procedure N_CoordsTest();
// test coords convertion procedures
begin
{
var
  IR1: TRect;
  DR1: TDRect;
begin
  DR1 := N_DRectIAffConv2( DRect(0,0,1,1), Rect(0,0,100,100), Rect(0,0,100,100)  );
  DR1 := N_DRectIAffConv2( DRect(0,0,1,1), Rect(0,0,100,100), Rect(0,0,50,50)  );
  DR1 := N_DRectIAffConv2( DRect(0,0,1,1), Rect(0,0,100,100), Rect(50,50,100,100)  );

  IR1 := N_IRectDAffConv2( Rect(0,0,100,100), DRect(0,0,1,1), DRect(0,0,0.5,0.5)  );
  IR1 := N_IRectDAffConv2( Rect(0,0,100,100), DRect(0,0,1,1), DRect(0.5,0.5,1.0,1.0)  );
  IR1 := N_IRectDAffConv2( Rect(0,0,100,100), DRect(0,0,1,1), DRect(0,0,1,1) );
  IR1 := N_IRectDAffConv2( Rect(0,0,100,100), DRect(0,0,1,1), DRect(0,0,1,1) );
}
end; // procedure N_CoordsTest();

procedure N_TestPrint1();
// Printing test 1:
// drawing imediately on Printer Canvas without RBuf
var
  BMP: TBitMap;
begin
  BMP := TBitMap.Create;
  BMP.Width := 1000;
  BMP.Height := 1000;
  BMP.PixelFormat := pf32bit;
  BMP.Canvas.Brush.Color := $CCCCCC;
  BMP.Canvas.FillRect( Rect(0,0,1000,1000) );
  BMP.Canvas.Brush.Color := $AAAAAA;
  BMP.Canvas.FillRect( Rect(0,0,500,500) );

  Printer.BeginDoc;

  Printer.Canvas.CopyRect( Rect(700,700,1700,1700), BMP.Canvas, Rect(0,0,1000,1000) );

  Printer.Canvas.Brush.Color := $777777;
  Printer.Canvas.FillRect( Rect(0,0,100,100) );
  Printer.Canvas.Brush.Color := $888888;
  Printer.Canvas.FillRect( Rect(100,100,300,300) );
  Printer.Canvas.Brush.Color := $333333;
  Printer.Canvas.FillRect( Rect(300,300,500,500) );
  Printer.Canvas.Brush.Color := $AAAAAA;
  Printer.Canvas.FillRect( Rect(500,500,700,700) );

  Printer.Canvas.CopyRect( Rect(1700,0,2700,1000), BMP.Canvas, Rect(0,0,1000,1000) );

  Printer.EndDoc;
  Exit;

end; // end of procedure N_TestPrint1();

procedure N_TestPrint2();
// Printing test 2:
// printing using RBuf
var
  BMP: TBitMap;
  OCanv: TN_OCanvas;
  DevPagePRect: TRect;
  Coords: TN_DPArray;
  PDC: integer;
  procedure FillPRect( ARect: TRect; Color: integer ); // local
  begin
    OCanv.SetBrushAttribs( Color );
    OCanv.DrawPixFilledRect( ARect );
  end; // procedure FillPRect( ARect: TRect; Color: integer ); // local
begin
  Printer.BeginDoc; //******************************
  PDC := Printer.Handle;

  BMP := TBitMap.Create;
  BMP.Width := 1000;
  BMP.Height := 1000;
  BMP.PixelFormat := pf32bit;
  BMP.Canvas.Brush.Color := $CCCCCC;
  BMP.Canvas.FillRect( Rect(0,0,1000,1000) );
  BMP.Canvas.Brush.Color := $AAAAAA;
  BMP.Canvas.FillRect( Rect(0,0,500,500) );

  OCanv := TN_OCanvas.Create;

//!!  OCanv.ParentFrameType := 1;
  DevPagePRect := Rect( 0, 0, 1001, 1001 );
//!!  OCanv.Prepare( nil, DevPagePRect, pf32bit );
  OCanv.CurLLWPixSize := 1.0;

  SetLength( Coords, 4 );
  Coords[0].X := 0.1;
  Coords[0].Y := 0.1;
  Coords[1].X := 0.5;
  Coords[1].Y := 0.1;
  Coords[2].X := 0.1;
  Coords[2].Y := 0.5;
  Coords[3].X := 0.1;
  Coords[3].Y := 0.1;

  FillPRect( DevPagePRect, $FFFFFF );

  OCanv.SetCoefsAndUCRect( FRect(0,0,1,1), DevPagePRect );
  FillPRect( Rect(0,0,200,200), $666666 );
  FillPRect( Rect(0,0,50,50), $444444 );
  OCanv.DrawUserColorRing( Coords, N_NotAFRect, N_CalcRingDirection(Coords),
                                                           $555555, 0, 20 );
  StartPage( PDC );
//  BitBlt( PDC, 0,0,1000,1000, OCanv.OCanv.MainBitMap.Canvas.Handle, 0, 0, SRCCOPY );
//  Printer.Canvas.CopyRect( Rect(0,0,1000,1000), OCanv.MainBuf.Canvas,
//                                                       Rect(0,0,1000,1000) );
  EndPage( PDC );

  StartPage( PDC );
  FillPRect( DevPagePRect, $FFFFFF );
  FillPRect( Rect(300,0,150,150), $444444 );
//  BitBlt( PDC, 0,0,1000,1000, OCanv.OCanv.MainBitMap.Canvas.Handle, 0, 0, SRCCOPY );
  EndPage( PDC );


//  BitBlt( PDC, 0,0,1000,1000, OCanv.MainBuf.Canvas.Handle, 0, 0, SRCCOPY );
//  NewHandle := CreateSolidBrush( $555555 );
//  OldHandle := SelectObject( PDC, NewHandle );
//  DeleteObject( OldHandle );
//  FillRect( PDC, Rect(0,0,30,30), NewHandle );

  Printer.EndDoc;
end; // end of procedure N_TestPrint2();

procedure N_TestPrint3();
// Printing test 3
var
  BMP: TBitMap;
//  OCanv: TN_OCanvas;
begin
  BMP := TBitMap.Create;
  BMP.Width := 1000;
  BMP.Height := 1000;
  BMP.PixelFormat := pf32bit;
  BMP.Canvas.Brush.Color := $CCCCCC;
  BMP.Canvas.FillRect( Rect(0,0,1000,1000) );
  BMP.Canvas.Brush.Color := $999999;
  BMP.Canvas.FillRect( Rect(0,0,500,500) );

  Printer.BeginDoc;
  Printer.Canvas.Brush.Color := $777777;
  Printer.Canvas.FillRect( Rect(0,0,200,200) );
  Printer.Canvas.CopyRect( Rect(200,200,1200,1200), BMP.Canvas, Rect(0,0,1000,1000) );
  Printer.Canvas.CopyRect( Rect(1200,1200,2200,2200), BMP.Canvas, Rect(0,0,1000,1000) );
  Printer.EndDoc;
  Exit;


//  Printer.Canvas.CopyRect( Rect(700,700,1700,1700), BMP.Canvas, Rect(0,0,1000,1000) );

  Printer.Canvas.Brush.Color := $777777;
  Printer.Canvas.FillRect( Rect(0,0,100,100) );
  Printer.Canvas.Brush.Color := $888888;
  Printer.Canvas.FillRect( Rect(100,100,300,300) );
  Printer.Canvas.Brush.Color := $333333;
  Printer.Canvas.FillRect( Rect(300,300,500,500) );
  Printer.Canvas.Brush.Color := $AAAAAA;
  Printer.Canvas.FillRect( Rect(500,500,700,700) );
//  Printer.NewPage();


//  OCanv := TN_OCanv.Create;
//!!  OCanv.ParentFrameType := 1;
//  OCanv.Prepare( Printer.Canvas, Rect(0,0,1000,1000), pf32bit );
//  OCanv.MainBuf.Canvas.Brush.Color := $DDDDDD;
//  OCanv.MainBuf.Canvas.RoundRect( 700,700,1000,1000, 200,200 );

//  Printer.Canvas.CopyRect( Rect(1200,1200,2200,2200), OCanv.MainBuf.Canvas,
//                                                       Rect(0,0,1000,1000) );

//  OCanv.UpdateDst();

  Printer.EndDoc;

end; // end of procedure N_TestPrint3();

procedure N_TestPrint4();
// Printing test 4 - Margins, Palette and Pattern test
var
  i, j, k, PPW, PPH, Y, CurColor, RS: integer;
//  BaseColor, StepColor: integer;
  DotSize: integer;
  BMP: TBitMap;
  ColorRect: TRect;
begin
  PPW := Printer.PageWidth;
  PPH := Printer.PageHeight;
  Printer.Title := 'Test4';
  RS := 300;

  BMP := TBitMap.Create;
  BMP.Width := RS;
  BMP.Height := RS;
  BMP.PixelFormat := pf32bit;
  BMP.Canvas.Brush.Color := $888888;
  BMP.Canvas.FillRect( Rect(0,0,RS,RS) );

  Printer.BeginDoc;
{
  //***** Rectangles in Page corners
  Printer.Canvas.CopyRect( Rect(0,0,RS,RS), BMP.Canvas, Rect(0,0,RS,RS) );
  Printer.Canvas.CopyRect( Rect(PPW-RS,0,PPW,RS), BMP.Canvas, Rect(0,0,RS,RS) );
  Printer.Canvas.CopyRect( Rect(PPW-RS,PPH-RS,PPW,PPH), BMP.Canvas, Rect(0,0,RS,RS) );
  Printer.Canvas.CopyRect( Rect(0,PPH-RS,RS,PPH), BMP.Canvas, Rect(0,0,RS,RS) );
}

  //***** One Pixel Page Border
  Printer.Canvas.Pen.Color := 0;
  Printer.Canvas.Pen.Width := 1;
  Printer.Canvas.MoveTo(   0,   0 );
  Printer.Canvas.LineTo( PPW-1,   0 );
  Printer.Canvas.LineTo( PPW-1, PPH-1 );
  Printer.Canvas.LineTo(   0, PPH-1 );
  Printer.Canvas.LineTo(   0,   0 );

{
  //***** Colored Rects
  Y := 500;
  BaseColor := 0;
  StepColor := $202020; // Gray
  for i := 1 to 8 do
  begin
    CurColor := BaseColor + i*StepColor - $010101;
    ColorRect := Rect( 100+400*(i-1), Y, 400+400*(i-1), Y+RS );
    Printer.Canvas.Brush.Color := CurColor;
    Printer.Canvas.FillRect( ColorRect );
  end;

  Y := 1000;
  BaseColor := 0;
  StepColor := $000020; // Red
  for i := 1 to 8 do
  begin
    CurColor := BaseColor + i*StepColor - $000001;
    ColorRect := Rect( 100+400*(i-1), Y, 400+400*(i-1), Y+RS );
    Printer.Canvas.Brush.Color := CurColor;
    Printer.Canvas.FillRect( ColorRect );
  end;

  Y := 1500;
  BaseColor := 0;
  StepColor := $002000; // Green
  for i := 1 to 8 do
  begin
    CurColor := BaseColor + i*StepColor - $000100;
    ColorRect := Rect( 100+400*(i-1), Y, 400+400*(i-1), Y+RS );
    Printer.Canvas.Brush.Color := CurColor;
    Printer.Canvas.FillRect( ColorRect );
  end;

  Y := 2000;
  BaseColor := 0;
  StepColor := $202000; // Cyan
  for i := 1 to 8 do
  begin
    CurColor := BaseColor + i*StepColor - $010100;
    ColorRect := Rect( 100+400*(i-1), Y, 400+400*(i-1), Y+RS );
    Printer.Canvas.Brush.Color := CurColor;
    Printer.Canvas.FillRect( ColorRect );
  end;
}

  DotSize := 2; // Gap between dots is 0,1,2, ... ,8-DotSise

 //***** Colored Pattern Rects
  Y := 500;
  CurColor := $000000; //***** Black
  for i := DotSize to 8 do
  begin
    for j := 0 to RS-1 do
    for k := 0 to RS-1 do
    begin
      if (( j mod i ) < DotSize) and (( k mod i ) < DotSize) then
        BMP.Canvas.Pixels[j,k] := CurColor
      else
        BMP.Canvas.Pixels[j,k] := clWhite;
    end;
    ColorRect := Rect( 100+400*(i-1), Y, 400+400*(i-1), Y+RS );
    Printer.Canvas.CopyRect( ColorRect, BMP.Canvas, Rect(0,0,RS,RS) );
  end; // for i := 1 to 8 do

  //***** Colored Pattern Rects
  Y := 1000;
  CurColor := $FF00FF; //***** Magenta
  for i := DotSize to 8 do
  begin
    for j := 0 to RS-1 do
    for k := 0 to RS-1 do
    begin
      if (( j mod i ) < DotSize) and (( k mod i ) < DotSize) then
        BMP.Canvas.Pixels[j,k] := CurColor
      else
        BMP.Canvas.Pixels[j,k] := clWhite;
    end;
    ColorRect := Rect( 100+400*(i-1), Y, 400+400*(i-1), Y+RS );
    Printer.Canvas.CopyRect( ColorRect, BMP.Canvas, Rect(0,0,RS,RS) );
  end; // for i := 1 to 8 do

  //***** Colored Pattern Rects
  Y := 1500;
  CurColor := $FFFF00; //***** Cyan
  for i := DotSize to 8 do
  begin
    for j := 0 to RS-1 do
    for k := 0 to RS-1 do
    begin
      if (( j mod i ) < DotSize) and (( k mod i ) < DotSize) then
        BMP.Canvas.Pixels[j,k] := CurColor
      else
        BMP.Canvas.Pixels[j,k] := clWhite;
    end;
    ColorRect := Rect( 100+400*(i-1), Y, 400+400*(i-1), Y+RS );
    Printer.Canvas.CopyRect( ColorRect, BMP.Canvas, Rect(0,0,RS,RS) );
  end; // for i := 1 to 8 do

  //***** Colored Pattern Rects
  Y := 2000;
  CurColor := $00FFFF; //***** Yellow
  for i := DotSize to 8 do
  begin
    for j := 0 to RS-1 do
    for k := 0 to RS-1 do
    begin
      if (( j mod i ) < DotSize) and (( k mod i ) < DotSize) then
        BMP.Canvas.Pixels[j,k] := CurColor
      else
        BMP.Canvas.Pixels[j,k] := clWhite;
    end;
    ColorRect := Rect( 100+400*(i-1), Y, 400+400*(i-1), Y+RS );
    Printer.Canvas.CopyRect( ColorRect, BMP.Canvas, Rect(0,0,RS,RS) );
  end; // for i := 1 to 8 do

  Printer.EndDoc;
  BMP.Free;
end; // end of procedure N_TestPrint4();

procedure N_TestDrawCopyRect1();
// Draw, Copy, Clip Rects test 1
var
  BMP: TBitMap;
  RgnHandle: HRGN;
begin
  BMP := TBitMap.Create;
  BMP.Width := 300;
  BMP.Height := 300;
  BMP.PixelFormat := pf32bit;
  BMP.Canvas.Brush.Color := $FFFFFF;
  BMP.Canvas.FillRect( Rect(0,0,300,300) );

  BMP.Canvas.Brush.Color := $FF;
  BMP.Canvas.FillRect( Rect(1,1,3,3) ); // red 2x2 rect, bottom right edges excluded!
  BMP.Canvas.CopyRect( Rect(4,1,5,2), BMP.Canvas, Rect(1,1,2,2) ); // 1x1 red rect copied, bottom right edges excluded!

  N_DrawFilledRect( BMP.Canvas.Handle, Rect(7,4,8,5), $FF00 ); // green 2x2 rect, edges included
  N_CopyRect( BMP.Canvas.Handle, Point(3,0), BMP.Canvas.Handle, Rect(7,4,7,4) ); // 1x1 green rect copied

  N_DrawRectBorder( BMP.Canvas.Handle, Rect(1,4,5,9), $CFCF, 2 );
  N_DrawRectBorder( BMP.Canvas.Handle, Rect(1,11,5,16), $AFAF, 1 );

  RgnHandle := CreateRectRgn(12,4,13,5); // 1x1 image mask, bottom right edges excluded!
  SelectClipRgn( BMP.Canvas.Handle, RgnHandle );
  DeleteObject( RgnHandle );
  N_DrawFilledRect( BMP.Canvas.Handle, Rect(12,4,13,5), $CC00CC ); // fucsia 1x1 rect

  BMP.SaveToFile( 'C:\\aaDrawCopyRect1.bmp' );
end; // end of procedure N_TestDrawCopyRect1();

procedure N_TestDrawEllipse1();
// Draw, Clip Ellipse test 1
var
  BMP: TBitMap;
  RgnHandle: HRGN;
begin
  BMP := TBitMap.Create;
  BMP.Width := 300;
  BMP.Height := 300;
  BMP.PixelFormat := pf32bit;
  BMP.Canvas.Brush.Color := $FFFFFF;
  BMP.Canvas.FillRect( Rect(0,0,300,300) );

//  SetGraphicsMode( BMP.Canvas.Handle, GM_ADVANCED );
  SetGraphicsMode( BMP.Canvas.Handle, GM_COMPATIBLE );

  // In GM_COMPATIBLE mode Windows.Ellipse bottom right edges excluded
  // In GM_ADVANCED   mode Windows.Ellipse do not exclude edges
  // given rects coords are line center if Pen.Width >= 3

  BMP.Canvas.Pen.Color := $FF;

  BMP.Canvas.Pen.Width := 1;
  Windows.Ellipse( BMP.Canvas.Handle, 1,1, 3,3 ); // 2x2
  Windows.Ellipse( BMP.Canvas.Handle, 1,4, 2,5 ); // 1x1 - not visible at all in GM_COMPATIBLE
  Windows.Ellipse( BMP.Canvas.Handle, 5,1, 8,4 );   // 3x3 - 3x3 cross or 4x4 rect in GM_ADVANCED
  Windows.Ellipse( BMP.Canvas.Handle, 10,1, 14,5 ); // 4x4 -
  Windows.Ellipse( BMP.Canvas.Handle, 16,1, 21,6 ); // 5x5
  Windows.Ellipse( BMP.Canvas.Handle, 23,1, 29,7 ); // 6x6

  BMP.Canvas.Pen.Width := 2; // very unplesant not simmetrical shapes!
  Windows.Ellipse( BMP.Canvas.Handle, 1,9,  3,11 ); // 2x2
  Windows.Ellipse( BMP.Canvas.Handle, 1,12, 2,13 ); // 1x1
  Windows.Ellipse( BMP.Canvas.Handle, 5,9,  8,12 );  // 3x3
  Windows.Ellipse( BMP.Canvas.Handle, 10,9, 14,13 ); // 4x4
  Windows.Ellipse( BMP.Canvas.Handle, 16,9, 21,14 ); // 5x5
  Windows.Ellipse( BMP.Canvas.Handle, 23,9, 29,15 ); // 6x6

  BMP.Canvas.Pen.Width := 3;
  // inside (1,17, 11,25) rect in GM_COMPATIBLE mode
  // inside (1,17, 12,26) rect in GM_ADVANCED mode
  Windows.Ellipse( BMP.Canvas.Handle, 2,18, 11,25 );

  // In both modes elliptical clip region is two pixels smaller then given rect!

  RgnHandle := Windows.CreateEllipticRgn( 14,17, 17,20 ); // 4x4 mask - not visible at all!
  SelectClipRgn( BMP.Canvas.Handle, RgnHandle );
  DeleteObject( RgnHandle );
  N_DrawFilledRect( BMP.Canvas.Handle, Rect( 13,16, 18,21 ), $CC00CC );

  RgnHandle := Windows.CreateEllipticRgn( 23,17, 27,21 ); // 5x5 mask - 3x3 ellipse (+ sign)
  SelectClipRgn( BMP.Canvas.Handle, RgnHandle );
  DeleteObject( RgnHandle );
  N_DrawFilledRect( BMP.Canvas.Handle, Rect( 22,16, 28,22 ), $CC00CC );

  RgnHandle := Windows.CreateEllipticRgn( 30,17, 35,22 ); // 6x6 mask - 4x4 ellipse
  SelectClipRgn( BMP.Canvas.Handle, RgnHandle );
  DeleteObject( RgnHandle );
  N_DrawFilledRect( BMP.Canvas.Handle, Rect( 29,16, 36,23 ), $CC00CC );

  BMP.SaveToFile( 'C:\\aaDrawEllipse1.bmp' );
end; // end of procedure N_TestDrawCopyRect1();

procedure N_TestWinTransform1();
// windows Transform Test
var
  PixAffCoefs6, NormAffCoefs6: TN_AffCoefs6;
  SrcDIB, ResDIB, TextDIB{, TmpDIB}: TN_DIBObj;
  TwoCoefs: TDPoint;
begin
  N_CreateRastVCTForm( @N_TstRastVCTForm, nil );

  with N_TstRastVCTForm do
  begin
    Left := 20;
    Top  := 120;
    Width  := 500;
    Height := 450;
    Show; // should be called before RFrame.ShowMainBuf()

    RFrame.RFrInitByPaintBox( 0 );
    RFrame.OCanv.ClearSelfbyColor( $CCCCFF );

    SrcDIB := TN_DIBObj.Create( 202, 102, pf32bit, $00FF00 );
    with SrcDIB do
//      DIBOCanv.DrawPixGrid( DIBRect, 50, 2, 4, 50, 2, 2, $CCCCCC, $EEEEEE, 0, 0 );
      DIBOCanv.DrawPixGrid( DIBRect, 50, 2, 4, 50, 2, 2, $00CCCC, $EEEE88, 0, 0 );

    N_StretchRect( RFrame.OCanv.HMDC,    SrcDIB.DIBRect,   // Draw initial Image
                   SrcDIB.DIBOCanv.HMDC, SrcDIB.DIBRect );

    RFrame.ShowMainBuf();
    N_DelayInSeconds( 5.0 );

    N_DrawFilledRect( RFrame.OCanv.HMDC, RFrame.OCanv.CurCRect, $BBEEBB );
    ResDIB := nil;
    SrcDIB.RotateByAngle( 0, -45, $EEAAAA, ResDIB, @PixAffCoefs6, @NormAffCoefs6 );

//    ResDIB.SaveToBMPFormat( 'C:\\aa1.bmp' ); // debug
    //***** ResDIB is OK, Draw it
    N_StretchRect( RFrame.OCanv.HMDC,    ResDIB.DIBRect,   // Draw initial Image
                   ResDIB.DIBOCanv.HMDC, ResDIB.DIBRect );
    RFrame.ShowMainBuf();

    //***** Calc NormAffCoefs6  for Normalized coords transformation
    TwoCoefs := DPoint( 100.0/ResDIB.DIBRect.Right, 100.0/ResDIB.DIBRect.Bottom );
    NormAffCoefs6 := PixAffCoefs6;
    N_CalcAffCoefs6( $12, NormAffCoefs6, @TwoCoefs.X );

    //***** Add "Demo" text over the Slide

    TextDIB := TN_DIBObj.Create( 2000, 2000, pf24bit, 0 );
    N_DebSetNFont( TextDIB.DIBOCanv, 900, 1, 45 );
    TextDIB.DIBOCanv.SetFontAttribs( $1F1F1F ); // $808080
    N_SetFontSmoothing( false );
    TextDIB.DIBOCanv.DrawPixString( Point(-250,1250), 'DEMO' );
    N_SetFontSmoothing( true );
//    TextDIB.SaveToBMPFormat( 'C:\\aa1.bmp' ); // debug
//    N_StretchRect( RFrame.OCanv.HMDC,    ResDIB.DIBRect,   // Draw initial Image
//                   TextDIB.DIBOCanv.HMDC, TextDIB.DIBRect, SRCINVERT ); //
    N_StretchRect( RFrame.OCanv.HMDC,    ResDIB.DIBRect,   // Draw initial Image
                   TextDIB.DIBOCanv.HMDC, TextDIB.DIBRect, SRCPAINT ); //
//    TmpDIB := TN_DIBObj.Create( RFrame.OCanv, ResDIB.DIBRect, pf24bit );
//    TmpDIB.SaveToBMPFormat( 'C:\\aa2.bmp' ); // debug
//    TmpDIB.Free;

    TextDIB.Free;
    SrcDIB.Free;

    RFrame.ShowMainBuf();


  end; // with N_TstRastVCTForm do
end; // end of procedure N_TestWinTransform1

procedure N_DecPointsTest();
// test N_DecNumberOfLinePoints1 and related procedures
var
//  N: integer;
//  Delta: double;
  L1, L2: TN_DPArray;
begin
  SetLength( L1, 6 );
  L1[0] := DPoint( 0, 0 );
  L1[1] := DPoint( 1, 1.01 );
  L1[2] := DPoint( 2, 2 );
  L1[3] := DPoint( 2, 2.01 );
  L1[4] := DPoint( 3, 1 );
  L1[5] := DPoint( 4, 0 );
  N_i := N_DecNumberOfLinePoints1( L1, L2, 0.001 );
  N_i := N_DecNumberOfLinePoints1( L1, L2, 0.1 );
  N_i := N_DecNumberOfLinePoints1( L1, L2, 1.5 );
  N_i := N_DecNumberOfLinePoints1( L1, L2, 1.9 );
  N_i := N_DecNumberOfLinePoints1( L1, L2, 2.1 );
  N_i := N_DecNumberOfLinePoints1( L1, L2, 2.1 );
end; // procedure N_CoordsTest();

procedure N_CoordsConvTest();
// test coords convertion
begin
{
var
  xi: integer;
  xf: double;
  OCanv: TN_OCanvas;
begin
  OCanv := TN_OCanv.Create();
//!!  OCanv.ParentFrameType := -1;
//!!  OCanv.Prepare( nil, Rect(0,0,2,5), pf32bit );
  OCanv.RecalcAffCoefs( $32, aamIncRect, FRect(0,0,1,2), Rect(0,0,2,5) );
  with OCanv.OCanv do
  begin
    xf := 1.0/6;
    N_i := Round( U2P.CX*xf + U2P.SX );
    xi := 2;
    N_d := P2U.CX*xi + P2U.SX;
  end;
}
end; // procedure N_CoordsConvTest

procedure N_TestRectLinesLists();
// test TN_RectLinesLists.AddLineSegment procedure
var
  RLL: TN_RectLinesLists;
begin
  RLL := TN_RectLinesLists.Create( DRect(10, 10, 30, 50), 5, 4 );
  RLL.AddLineSegment( DPoint(12,15), DPoint(20,15), 0, 1 );
  RLL.AddLineSegment( DPoint(16,12), DPoint(16,35), 0, 2 );
  RLL.AddLineSegment( DPoint(24,12), DPoint(28,18), 0, 3 );

  RLL.AddLineSegment( DPoint(13,14), DPoint(19,28), 0, 4 );
  RLL.AddLineSegment( DPoint(19,28), DPoint(13,14), 0, 5 );

  RLL.AddLineSegment( DPoint(12,42), DPoint(20,38), 0, 6 );
  RLL.AddLineSegment( DPoint(20,38), DPoint(12,42), 0, 7 );

  RLL.AddLineSegment( DPoint(25,29), DPoint(23,42), 0, 8 );
  RLL.AddLineSegment( DPoint(23,42), DPoint(25,29), 0, 9 );

  RLL.AddLineSegment( DPoint(27,29), DPoint(29,35), 0, 10 );
  RLL.AddLineSegment( DPoint(29,35), DPoint(27,29), 0, 11 );

  RLL.AddLineSegment( DPoint(12,15), DPoint(20,15), 0, 5 );
end; // end of procedure N_TestRectLinesLists

procedure N_TestFloatAccuracy();
// calc max Eps such, that 1.0 = 1.0 + Eps for different float number types
var
  i: integer;
  Eps:  array [0..100] of double;      //     Results:
//  Eps1: array [0..100] of single;    // Nbits=24, Eps=6.0*10**-8
//  Eps1: array [0..100] of real48;    // Nbits=41, Eps=4.5*10**-13
  Eps1: array [0..100] of real;      // Nbits=53, Eps=1.1*10**-16
//  Eps1: array [0..100] of double;    // Nbits=53, Eps=1.1*10**-16
//  Eps1: array [0..100] of extended;  // Nbits=64, Eps=5.4*10**-20
begin
  Eps[0] := 1.0;
  Eps1[0] := Eps[0] + 1.0;

  for i := 0 to 90 do
  begin
    Eps[i+1]  := Eps[i] / 2.0;
    Eps1[i+1] := Eps[i+1] + 1.0
  end;

  for i := 0 to 90 do
  begin
    if Eps1[i] = 1.0 then Break;
  end;

  ShowMessage( Format( 'NBits=%d,  Eps=%.3e', [i, Eps[i]] ) );
end; // end of procedure N_TestFloatAccuracy

procedure N_Tst1StringMemoryCheck();
// checks memory allocation for strings as record elements
type TR1 = record
  i1: integer;
  s1: string;
end; // type R1 = record
type TR1s = array of TR1;
var
  R1s: TR1s;
begin
  N_IAdd( 'N_Tst1StringMemoryCheck' );
  N_IAdd( '' );

  Setlength( R1s, 3 );
//  N_IAdd( 'Before:    ' + N_DelphiMemoryInfo( 1 ) );
  SetLength( R1s[0].s1, 1000 );
//  N_IAdd( '+s0(1000): ' + N_DelphiMemoryInfo( 1 ) );
  SetLength( R1s[1].s1, 2000 );
//  N_IAdd( '+s1(2000): ' + N_DelphiMemoryInfo( 1 ) );
  SetLength( R1s[2].s1, 3000 );
//  N_IAdd( '+s2(3000): ' + N_DelphiMemoryInfo( 1 ) );
  N_IAdd( '' );

  R1s[0].s1 := '';
//  N_IAdd( 's0 := nil: ' + N_DelphiMemoryInfo( 1 ) );
  SetLength( R1s[0].s1, 1000 );
//  N_IAdd( '+s0(1000): ' + N_DelphiMemoryInfo( 1 ) );
  R1s[0] := R1s[1];
//  N_IAdd( 's0 := s1 : ' + N_DelphiMemoryInfo( 1 ) );
  R1s[2] := R1s[1];
//  N_IAdd( 's2 := s1 : ' + N_DelphiMemoryInfo( 1 ) );
  N_IAdd( '' );

  R1s[2].s1[1] := 'B';
//  N_IAdd( 'Change s2: ' + N_DelphiMemoryInfo( 1 ) );
  SetLength( R1s[0].s1, 1000 );
//  N_IAdd( '+s0(1000): ' + N_DelphiMemoryInfo( 1 ) );
  SetLength( R1s[2].s1, 30000 );
//  N_IAdd( '+s2(30000):' + N_DelphiMemoryInfo( 1 ) );
  N_IAdd( '' );

  Setlength( R1s, 2 );
//  N_IAdd( 'del s2  :  ' + N_DelphiMemoryInfo( 1 ) );
  R1s := nil;
//  N_IAdd( 'del all :  ' + N_DelphiMemoryInfo( 1 ) );

end; // end of procedure N_Tst1StringMemoryCheck

procedure N_Tst1FastTimer();
// TN_CPUTimer1, TN_CPUTimer2 tests (+ N_PlatformInfo, N_DelphiMemoryInfo)
var
  i, j: integer;
  t1a, t1b: TN_CPUTimer1;
  DC1, DC2: Int64;
begin
  N_IAdd( 'N_Tst1FastTimer' );
  N_IAdd( '' );
  N_IAdd( '  Calc several times CPU frequency in HZ' );
  t1a := TN_CPUTimer1.Create();
  t1b := TN_CPUTimer1.Create();
  N_CPUFrequency := N_GetCPUFrequency( 200 );

  N_IAdd( Format( '(050) F=%f,  Eps=%d %d', [N_GetCPUFrequency(50), N_EpsCPUTimer1, N_EpsCPUTimer2] ));
  N_IAdd( Format( '(050) F=%f,  Eps=%d %d', [N_GetCPUFrequency(50), N_EpsCPUTimer1, N_EpsCPUTimer2] ));
  N_IAdd( Format( '(050) F=%f,  Eps=%d %d', [N_GetCPUFrequency(50), N_EpsCPUTimer1, N_EpsCPUTimer2] ));
  N_IAdd( Format( '(050) F=%f,  Eps=%d %d', [N_GetCPUFrequency(50), N_EpsCPUTimer1, N_EpsCPUTimer2] ));
  N_IAdd( '' );
  N_IAdd( Format( '(200) F=%f,  Eps=%d %d', [N_GetCPUFrequency(200), N_EpsCPUTimer1, N_EpsCPUTimer2] ));
  N_IAdd( Format( '(200) F=%f,  Eps=%d %d', [N_GetCPUFrequency(200), N_EpsCPUTimer1, N_EpsCPUTimer2] ));
  N_IAdd( Format( '(200) F=%f,  Eps=%d %d', [N_GetCPUFrequency(200), N_EpsCPUTimer1, N_EpsCPUTimer2] ));
  N_IAdd( Format( '(200) F=%f,  Eps=%d %d', [N_GetCPUFrequency(200), N_EpsCPUTimer1, N_EpsCPUTimer2] ));
  N_IAdd( '' );
  N_IAdd( Format( '(800) F=%f,  Eps=%d %d', [N_GetCPUFrequency(800), N_EpsCPUTimer1, N_EpsCPUTimer2] ));
  N_IAdd( Format( '(800) F=%f,  Eps=%d %d', [N_GetCPUFrequency(800), N_EpsCPUTimer1, N_EpsCPUTimer2] ));
  N_IAdd( Format( '(800) F=%f,  Eps=%d %d', [N_GetCPUFrequency(800), N_EpsCPUTimer1, N_EpsCPUTimer2] ));
  N_IAdd( Format( '(800) F=%f,  Eps=%d %d', [N_GetCPUFrequency(800), N_EpsCPUTimer1, N_EpsCPUTimer2] ));
  N_IAdd( '' );

  t1a.Start;
  t1a.Stop;
  t1a.Show( 't1a empty' );
  N_IAdd( 'DeltaCounter : ' + IntToStr( t1a.DeltaCounter) );

  t1b.Start;
  t1b.Stop;
  t1b.Show( 't1b empty' );
  N_IAdd( 'DeltaCounter : ' + IntToStr( t1b.DeltaCounter) );

  t1a.Start;
  t1a.Stop;
  t1a.Show( 't1a empty' );
  N_IAdd( 'DeltaCounter : ' + IntToStr( t1a.DeltaCounter) );
  N_IAdd( '' );

  t1a.Start;
  t1a.Stop;
  t1a.Show( 't1a empty' );
  N_IAdd( 'DeltaCounter : ' + IntToStr( t1a.DeltaCounter) );
  N_IAdd( '' );

  t1a.Start;
  t1a.Stop;
  DC1 := t1a.DeltaCounter;

  t1a.Start;
  t1a.Stop;
  DC2 := t1a.DeltaCounter;

  t1a.Start;
  t1a.Stop;
  t1a.Show( 't1a(c) empty' );
  N_IAdd( 'DeltaCounter : ' + IntToStr( t1a.DeltaCounter) );
  t1a.DeltaCounter := DC1;
  t1a.Show( 't1a(a) empty' );
  N_IAdd( 'DeltaCounter : ' + IntToStr( t1a.DeltaCounter) );
  t1a.DeltaCounter := DC2;
  t1a.Show( 't1a(b) empty' );
  N_IAdd( 'DeltaCounter : ' + IntToStr( t1a.DeltaCounter) );
  N_IAdd( '' );

  N_T2.Items[0].TimerName := 'T2 Empty +x1 ';

  N_T2.Clear( 1 );
  N_T2.Start(0);
  N_T2.Stop(0);
  N_T2.Show(0);

  N_T2.Clear( 1 );
  N_T2.Start(0);
  N_T2.Stop(0);
  N_T2.Show(0);

  N_T2.Start(0);
  N_T2.Stop(0);
  N_T2.Show(0);

  N_T2.Items[0].TimerName := 'T2 Empty x3';
  N_T2.Clear( 1 );

  N_T2.Start(0);
  N_T2.Stop(0);
    N_i := 123;
  N_T2.Start(0);
  N_T2.Stop(0);
    N_d := N_i;
  N_T2.Start(0);
  N_T2.Stop(0);

  N_T2.Show(0);
  N_T2.Clear( 1 );

  N_T2.Start(0);
  N_T2.Stop(0);
    N_i := 123;
  N_T2.Start(0);
  N_T2.Stop(0);
    N_d := N_i;
  N_T2.Start(0);
  N_T2.Stop(0);

  N_T2.Show(0);
  N_T2.Clear( 1 );

  N_T2.Start(0);
  N_T2.Stop(0);
    N_i := 123;
  N_T2.Start(0);
  N_T2.Stop(0);
    N_d := N_i;
  N_T2.Start(0);
  N_T2.Stop(0);

  N_T2.Show(0);
  N_IAdd( '' );

  t1a.Start;
  t1b.Start;
  t1b.Stop;
  t1a.Stop;
  t1a.Show( 't1 Start-Stop' );

  t1a.Start;
  t1b.Start;
  t1b.Stop;
  t1a.Stop;
  t1a.Show( 't1 Start-Stop' );

  t1a.Start;
  t1b.Start;
  t1b.Stop;
  t1a.Stop;
  t1a.Show( 't1 Start-Stop' );

  N_T2.Clear( 2 );
  t1a.Start;
  N_T2.Start(0);
  N_T2.Stop(0);
  t1a.Stop;
  t1a.Show( 'T2 One Start-Stop' );

  t1a.Start;
  N_T2.Start(1);
  N_T2.Stop(1);
  N_T2.Start(1);
  N_T2.Stop(1);
  t1a.Stop;
  t1a.Show( 'T2 Two Start-Stops' );
  N_IAdd( '' );

  t1a.Start;
  N_i := 123;
  N_d := N_i;
  t1a.Stop;
  t1a.Show( 'two assigments ' );

  t1b.Start;
  N_i := 123;
  N_d := N_i;
  t1b.Stop;
  t1b.Show( 'two assigments ' );

  t1a.Start;
  N_i := 123;
  N_d := N_i;
  t1a.Stop;
  t1a.Show( 'two assigments ' );

  t1a.Start;
  N_d := Time;
  t1a.Stop;
  t1a.Show( 'Time() function' );

  t1a.Start;
  N_d := Time;
  t1a.Stop;
  t1a.Show( 'Time() function' );

  t1a.Start;
  N_i := 123;
  N_d := N_i;
  t1a.Stop;
  t1a.Show( 'two assigments ' );

  t1a.Start;
  N_d := Time;
  t1a.Stop;
  t1a.Show( 'Time() function' );
  N_IAdd( '' );

  with N_T2 do
  begin
    Clear( 3 );
    Items[0].TimerName := 'Whole';
    Items[1].TimerName := 'Part1';
    Items[2].TimerName := 'Part2';

    t1a.Start;
    for i := 1 to 100 do
    begin
      Start(0);

      Start(1);
      for j := 1 to 100 do N_d1 := N_d1 + Sin(j);
      Stop(1);

      Start(2);
      for j := 1 to 50 do N_d1 := N_d1 + Cos(j);
      Stop(2);

      Stop(0);
    end;
    t1a.Stop;
    t1a.Show( 'Test1' );
    Show( 3 );
  end;

//  N_IAdd( '' );
  N_PlatformInfo( N_InfoForm.Memo.Lines, 1 );
  N_IAdd( '' );
//  N_IAdd( N_DelphiMemoryInfo( 1 ) );
//  N_IAdd( '' );

  t1a.Free;
  t1b.Free;
  Exit;
{

  Sleep(10);
  asm
    dw 310Fh // rdtsc
    mov TimerLo1, eax
    mov TimerHi1, edx
  end;

  asm
    dw 310Fh // rdtsc
    mov TimerLo2, eax
    mov TimerHi2, edx
  end;
  N_i1 := TimerLo2 - TimerLo1;

  Sleep(200);
  asm
    dw 310Fh // rdtsc
    sub eax, TimerLo1
    sbb edx, TimerHi1
    mov TimerLo3, eax
    mov TimerHi3, edx
  end;
}
end; // end of procedure N_Tst1FastTimer

procedure N_CObjectsCreateTest();
// create and save as text all just created CObjects in 'aCObj1.txt'
var
  Root: TN_UDBase;
  UP: TN_UDPoints;
  UCR: TN_UCObjRefs;
  ULF: TN_ULines;
  UC: TN_UContours;
begin
  Root := TN_UDBase.Create;
  Root.ObjName := 'Root2';

  UP := TN_UDPoints.Create;
  UP.ObjName := 'UP';
  UP.WComment := 'Comment in UP';
  UP.WEnvRect := N_EFRect;
  UP.WAccuracy := 2;
  SetLength( UP.CCoords, 2 );
  UP.CCoords[0] := DPoint(10,11);
  UP.CCoords[1] := DPoint(12,13);
  UP.Items[1].CFInd := Length(UP.CCoords);
  UP.CalcEnvRects();
  Root.AddOneChild( UP );

  UCR := TN_UCObjRefs.Create;
  UCR.ObjName := 'UCR';
  SetLength( UCR.Items, 3 );
//  UCR.Items[0].CCode := 100;
  UCR.Items[0].CFInd := 0;
//  UCR.Items[1].CCode := 101;
  UCR.Items[1].CFInd := 2;
  UCR.Items[2].CFInd := 5;
  N_FillArray( UCR.CObjInds, 10, 2, 5 );
  Root.AddOneChild( UCR );

  ULF := TN_ULines.Create1( N_FloatCoords );
  ULF.ObjName := 'ULF';
  SetLength( ULF.Items, 3 );
//  ULF.Items[0].CCode := 110;
  ULF.Items[0].CFInd := 0;
//  ULF.Items[1].CCode := 111;
  ULF.Items[1].CFInd := 2;
  ULF.Items[2].CFInd := 5;
  N_FillArray( ULF.LFCoords, FPoint(10,20), FPoint(1,2), 5 );
  ULF.CalcEnvRects();
  Root.AddOneChild( ULF );

  UC := TN_UContours.Create;
  UC.ObjName := 'UC';
  SetLength( UC.Items, 3 );
//  UC.Items[0].CCode := 310;
  UC.Items[0].CFInd := 0;
//  UC.Items[1].CCode := 311;
  UC.Items[1].CFInd := 1;
  UC.Items[2].CFInd := 3;
  SetLength( UC.CRings, 4 );
  UC.CRings[0].RLInd := 0;
  UC.CRings[0].RFlags := 0;
  UC.CRings[1].RLInd := 1;
  UC.CRings[1].RFlags := 1;
  UC.CRings[2].RLInd := 3;
  UC.CRings[2].RFlags := 2;
  UC.CRings[2].RLInd := 5;
  UC.CRings[3].RLInd := 6;
  N_FillArray( UC.LinesInds, 10, 1, 6 );
  Root.AddOneChild( UC );

  N_SaveUObjAsText( Root, 'aCObj1.txt' );
  N_SaveUObjAsBin( Root, 'aCObj1.bin' );

end; // procedure N_CObjectsCreateTest

procedure N_CObjectsLoadSaveTest();
// load from 'aCObj1.txt' and save again in 'aCObj2.txt' DTree with CObjects
var
  Root: TN_UDBase;
begin
//  Root := N_LoadUObjFromAny( 'aCObj1.txt' );
  Root := N_LoadUObjFromAny( 'aCObj1.bin' );
  N_SaveUObjAsText( Root, 'aCObj2.txt' );
end; // procedure N_CObjectsLoadSaveTest

procedure N_LibrariesLoadSaveTest();
// load from 'aLib1.txt' and save again in 'aLib2.txt' DTree with Libraries
var
  Root: TN_UDBase;
begin
  Root := N_LoadUObjFromAny( 'aLib1.txt' );
//  Root := N_LoadUObjFromAny( 'aLib1.bin' );
  N_SaveUObjAsText( Root, 'aLib2.txt' );
end; // procedure N_LibrariesLoadSaveTest

procedure N_DeleteInsertArrayElemsTest();
// N_DeleteArrayElems and N_InsertArrayElems tests
var
  IA1, IA2: TN_IArray;
begin
  N_FillArray( IA1, 100, 1, 20 );
  N_DeleteArrayElems( IA1, 10, 3 );
  N_DeleteArrayElems( IA1, 0, 2 );
  N_FillArray( IA2, 0, 1, 10 );
//  N_InsertArrayElems( IA1, 3, IA2, 1, 2 );
//  N_InsertArrayElems( IA1, -1, IA2, 0, 5 );
  N_i := IA1[1];
end; // procedure N_DeleteInsertArrayElemsTest

procedure Dummy1( PBytes: TN_BytesPtr ); // local
begin
//  N_i1 := PBytes^; // error!
  N_i1 := integer(PBytes^);
  Inc(PBytes);
  N_i1 := Byte(PBytes^);
end; // procedure Dummy1( PBytes: PChar ) // local

procedure N_PascalTest1();
// test passing elements of TN_BArray
var
  i: Integer;
  A1:TN_BArray;
begin
  SetLength( A1, 5 );
  for i := 0 to 4 do A1[i] := i;
  Dummy1( TN_BytesPtr(@A1[1]) );
end; // procedure N_PascalTest1

procedure Tmp1( var B3: TN_BArray );
begin
  B3[3] := 100;
end;

procedure N_CopyArrayTest1();
// test Copy func for dynamic arrays
var
  S: Integer;
  B1, B2: TN_BArray;
begin
  N_IAdd( 'N_CopyArrayTest1' );
  N_IAdd( '' );

  S := 1000000;
  N_T1.Start;
  SetLength( B1, S );
  N_T1.Stop;
  N_T1.Show( 'SetLength' );

  N_T1.Start;
  B2 := Copy( B1, 0, S );
  N_T1.Stop;
  N_T1.Show( 'Copy' );

  B1[3] := 123;
  N_T1.Start;
//  Tmp1( Copy( B1, 3, S-3 ) );
  Tmp1( B1 );
  N_T1.Stop;
  N_T1.Show( 'Copy as Param' );
//  B2[3] := 234;
  N_IAdd( IntToStr( B1[3] ) );

end; // procedure N_CopyArrayTest1

procedure N_ReallocArraySpeed1();
// Realloc Array Speed test
var
  A1, A2:TN_BArray;
begin
  N_IAdd( 'N_ReallocArraySpeed1' );
  N_IAdd( '' );

  N_T2.Clear(20);

  SetLength( A1, 10000 );
  SetLength( A2, 10000 );
  A1[9999] := 101;
  A2[9999] := 102;
  N_T2.Start(3);
  A1 := nil; // clear by nil before SetLength prevents from data moving!
  SetLength( A1, 20000 );
  N_T2.Stop(3);
  N_T2.Start(4);
  A2 := nil;
  SetLength( A2, 30000 );
  N_T2.Stop(4);
  N_T2.Start(5);
  A1 := nil;
  SetLength( A1, 50000 );
  N_T2.Stop(5);

  SetLength( A1, 10000 );
  SetLength( A2, 10000 );
  A1[9999] := 101;
  A2[9999] := 102;
  N_T2.Start(0);
  SetLength( A1, 20000 );
  N_T2.Stop(0);
  N_T2.Start(1);
  SetLength( A2, 30000 );
  N_T2.Stop(1);
  N_T2.Start(2);
  SetLength( A1, 50000 );
  N_T2.Stop(2);

  N_T2.Show(6);
end; // procedure N_ReallocArraySpeed1

procedure N_CheckKeys();
begin

end; // procedure N_CheckKeys

procedure N_TestDBF1();
// Test N_LoadDBFColumns procedure
var
  StrMatr: TN_ASArray;
  ColNames: TN_SArray;
begin
  SetLength( ColNames, 3 );
  ColNames[0] := 'BB1';
  ColNames[1] := 'A1';
  ColNames[2] := 'CCC1';
  StrMatr := nil;
  N_LoadDBFColumns( StrMatr, @ColNames[0], 3, '..\Data\Tmp\adbf4.dbf' );
end; // procedure N_TestDBF1

type TSortElem = packed record // for use in N_TestSortPointers
  Int1: integer;
  Int2: integer;
end; // type TSortElem = packed record
type TPSortElem = ^TSortElem;

procedure N_TestSortPointers1();
// Test N_SortPointers procedure #1
var
  i: integer;
  SortElems: array of TSortElem;
  Ptrs: TN_PArray;

  procedure Show(); // local
  var
    j: integer;
  begin
    for j := 0 to High(SortElems) do
    with TPSortElem(Ptrs[j])^ do
    begin
        N_IAdd( Format( 'i1,2 : %d, %d', [Int1,Int2] ) );
    end;
  end; // procedure Show(); // local

begin
  SetLength( SortElems, 5 );
  SortElems[0].Int1 := 10;
  SortElems[1].Int1 := 11;
  SortElems[1].Int2 := 120;
  SortElems[2].Int1 := 11;
  SortElems[2].Int2 := 110;
  SortElems[3].Int1 := 13;
  SortElems[4].Int1 := 14;

  SetLength( Ptrs, Length(SortElems) );
  for i := 0 to High(SortElems) do
    Ptrs[i] := @SortElems[i];

  N_IAdd( 'Before Sort:' ); Show();

//  N_CFuncs.DecrOrder := True;
  N_CFuncs.NumFields := 2;

  N_SortArrayOfElems ( @SortElems[0], Length(SortElems), SizeOf(SortElems[0]),
//                                                         N_CFuncs.CompOneInt );
                                                         N_CFuncs.CompNInts );
  N_IAdd( '' );
  N_IAdd( 'After Sort:' ); Show();

end; // procedure N_TestSortPointers1

procedure N_TestSortPointers2();
// Test N_SortPointers procedure #2
var
  i: integer;
  SortElems: array of TSortElem;
  Ptrs: TN_PArray;

  procedure Show(); // local
  var
    j: integer;
  begin
    for j := 0 to High(SortElems) do
    with TPSortElem(Ptrs[j])^ do
    begin
        N_IAdd( Format( 'i1,2 : %d, %d', [Int1,Int2] ) );
    end;
  end; // procedure Show(); // local

begin
  SetLength( SortElems, 5 );
  SortElems[0].Int1 := 10;
  SortElems[1].Int1 := 12;
  SortElems[2].Int1 := 11;
  SortElems[3].Int1 := 13;
  SortElems[4].Int1 := 14;

  SetLength( Ptrs, Length(SortElems) );
  for i := 0 to High(SortElems) do
    Ptrs[i] := @SortElems[i];

  N_IAdd( 'Before Sort:' ); Show();

  N_SortPointers( Ptrs, N_SortOrder, N_CompareIntegers );

  N_IAdd( '' ); N_IAdd( 'After Sort:' ); Show();

end; // procedure N_TestSortPointers2

var
  SA1: array [0..1] of string = ( 'SA1Str1', 'SA1Str2' );

procedure N_TestStrEdit2();
// Test N_EditString2
var
  i, n: integer;
  Str: string;
  SA: TN_SArray;
begin
  n := 20;
  SetLength( SA, n );
  for i := 0 to n-1 do
    SA[i] := 'StrPrefix' + IntToStr(i);

//  SA[0] := 'BB1';
//  SA[1] := 'A1';
//  SA[2] := 'CCC1';
  Str := 'Test Str';

  N_EditString( Str, SA, 'Lab name:', 'Form Caption', 250 );
  N_s := Str;

end; // procedure N_TestStrEdit2

procedure N_Test2DFunc1(); //*****************************************
// Test TN_FVMatr
var
  t, v, v1, Norm: double;
  FM1, FM2, FM3: TN_FVMatr;
  SL: TStringlist;
  C: Array [0..3] of double;
begin
  SL  := TStringlist.Create;

  SL.Add( '***** Catmull-Rom coefs test :' );
  t := 0;
  N_CalcCatRomCoefs( t, @C[0] );
  v := 0.5*( 1*C[0] + 2*C[1] + 3*C[2] + 4*C[3] );
  SL.Add( Format( 'v=%f;  t=%f, c=%f, %f, %f, %f', [v,t,C[0],C[1],C[2],C[3]] ));

  t := 0.1;
  N_CalcCatRomCoefs( t, @C[0] );
  v := 0.5*( 1*C[0] + 2*C[1] + 3*C[2] + 4*C[3] );
  SL.Add( Format( 'v=%f;  t=%f, c=%f, %f, %f, %f', [v,t,C[0],C[1],C[2],C[3]] ));

  t := 0.5;
  N_CalcCatRomCoefs( t, @C[0] );
  v := 0.5*( 1*C[0] + 2*C[1] + 3*C[2] + 4*C[3] );
  SL.Add( Format( 'v=%f;  t=%f, c=%f, %f, %f, %f', [v,t,C[0],C[1],C[2],C[3]] ));

  t := 0.9;
  N_CalcCatRomCoefs( t, @C[0] );
  v := 0.5*( 1*C[0] + 2*C[1] + 3*C[2] + 4*C[3] );
  SL.Add( Format( 'v=%f;  t=%f, c=%f, %f, %f, %f', [v,t,C[0],C[1],C[2],C[3]] ));

  t := 1.0;
  N_CalcCatRomCoefs( t, @C[0] );
  v := 0.5*( 1*C[0] + 2*C[1] + 3*C[2] + 4*C[3] );
  SL.Add( Format( 'v=%f;  t=%f, c=%f, %f, %f, %f', [v,t,C[0],C[1],C[2],C[3]] ));

  SL.Add( '' );

  t := 0;
  N_CalcCatRomCoefs( t, @C[0] );
  v := 0.5*( 1*C[0] + 4*C[1] + 9*C[2] + 16*C[3] );
  v1 := abs( v - 2.0*2.0 );
  SL.Add( Format( 'v=%f(%g);  t=%f, c=%f, %f, %f, %f', [v,v1,t,C[0],C[1],C[2],C[3]] ));

  t := 0.1;
  N_CalcCatRomCoefs( t, @C[0] );
  v := 0.5*( 1*C[0] + 4*C[1] + 9*C[2] + 16*C[3] );
  v1 := abs( v - 2.1*2.1 );
  SL.Add( Format( 'v=%f(%g);  t=%f, c=%f, %f, %f, %f', [v,v1,t,C[0],C[1],C[2],C[3]] ));

  t := 0.5;
  N_CalcCatRomCoefs( t, @C[0] );
  v := 0.5*( 1*C[0] + 4*C[1] + 9*C[2] + 16*C[3] );
  v1 := abs( v - 2.5*2.5 );
  SL.Add( Format( 'v=%f(%g);  t=%f, c=%f, %f, %f, %f', [v,v1,t,C[0],C[1],C[2],C[3]] ));

  t := 0.9;
  N_CalcCatRomCoefs( t, @C[0] );
  v := 0.5*( 1*C[0] + 4*C[1] + 9*C[2] + 16*C[3] );
  v1 := abs( v - 2.9*2.9 );
  SL.Add( Format( 'v=%f(%g);  t=%f, c=%f, %f, %f, %f', [v,v1,t,C[0],C[1],C[2],C[3]] ));

  t := 1.0;
  N_CalcCatRomCoefs( t, @C[0] );
  v := 0.5*( 1*C[0] + 4*C[1] + 9*C[2] + 16*C[3] );
  v1 := abs( v - 9 );
  SL.Add( Format( 'v=%f(%g);  t=%f, c=%f, %f, %f, %f', [v,v1,t,C[0],C[1],C[2],C[3]] ));

  SL.Add( '' );
  SL.Add( '' );

  SL.Add( '***** Parabolic func spline interpolation ' );
  SL.Add( 'Src 9x9 Parabolic Func :' );
  FM1 := TN_FVMatr.Create( 9, 9 );
  FM1.AddParab( DPoint(4,4), 1, 2.0, 3.0 );
  FM1.AddToStrings( SL, '%6.3f' );
  SL.Add( '' );

  SL.Add( 'Src 17x25 Parabolic Func :' );
  FM2 := TN_FVMatr.Create( 17, 25 );
  FM2.AddParab( DPoint(8,12), 1, 2.0/4, 3.0/9 );
  FM2.AddToStrings( SL, '%6.3f' );
  SL.Add( '' );

  SL.Add( 'Spline1 Interp. from Src 5x5 Parabolic Func:' );
  FM3 := TN_FVMatr.Create( 17, 25 );
  FM3.Resample( FM1, tdimSpline1 );
  FM3.AddToStrings( SL, '%6.3f' );
  SL.Add( '' );

  SL.Add( 'Residual:' );
  FM3.LinComb( 1, -1, 0, FM2, tdimConst );
  FM3.AddToStrings( SL, '%10.2g' );
  Norm := FM3.SelfNorm( ntLInf );
  SL.Add( Format( 'Dif1(LInf)=%.2g', [Norm] ));
  SL.Add( '' );
  SL.Add( '' );
  FM1.Free;
  FM2.Free;
  FM3.Free;

  SL.Add( '***** Linear func spline interpolation ' );
  SL.Add( '' );

  SL.Add( 'Src 4x4 Lin Func :' );
  FM1 := TN_FVMatr.Create( 4, 4 );
  FM1.AddLin2Func( 1, 2, 3 );
  FM1.AddToStrings( SL, '%.3f' );
  SL.Add( '' );

  SL.Add( 'Src 12x15 Lin Func :' );
  FM2 := TN_FVMatr.Create( 12, 15 );
  FM2.AddLin2Func( 1, 2, 3 );
  FM2.AddToStrings( SL, '%.3f' );
  SL.Add( '' );

  SL.Add( 'Spline1 Interp. from Src 4x4 Lin Func:' );
  FM3 := TN_FVMatr.Create( 12, 15 );
  FM3.Resample( FM1, tdimSpline1 );
  FM3.AddToStrings( SL, '%.3f' );
  SL.Add( '' );

  SL.Add( 'Residual:' );
  FM3.LinComb( 1, -1, 0, FM2, tdimConst );
  FM3.AddToStrings( SL, '%10.2g' );
  Norm := FM3.SelfNorm( ntLInf );
  SL.Add( Format( 'Dif1(LInf)=%.2g', [Norm] ));
  SL.Add( '' );

  SL.Add( 'BiLineal Interp. from Src 4x4 Lin Func:' );
  FM3.Resample( FM1, tdimBiLineal );
  FM3.AddToStrings( SL, '%.3f' );
  SL.Add( '' );

  FM3.LinComb( 1, -1, 0, FM2, tdimConst );
  FM3.AddToStrings( SL, '%10.2g' );
  Norm := FM3.SelfNorm( ntL1 );
  SL.Add( Format( 'Dif1(L1)  =%.2g', [Norm] ));
  Norm := FM3.SelfNorm( ntL2 );
  SL.Add( Format( 'Dif1(L2)  =%.2g', [Norm] ));
  Norm := FM3.SelfNorm( ntLInf );
  SL.Add( Format( 'Dif1(LInf)=%.2g', [Norm] ));
  SL.Add( '' );

  SL.Add( 'TriLineal Interp. from Src 4x4 Lin Func:' );
  FM3.Resample( FM1, tdimTriLineal );
  FM3.AddToStrings( SL, '%.3f' );
  SL.Add( '' );

  FM3.LinComb( 1, -1, 0, FM2, tdimConst );
  Norm := FM3.SelfNorm( ntLInf );
  SL.Add( Format( 'Dif2(ntLInf)=%.2g', [Norm] ));
  SL.Add( '' );

  SL.Add( 'Add exp to Src 4x4 Lin Func:' );
  FM1.Add2DExp( DPoint(1,1), 7, 1, 1, 1 );
  FM1.AddToStrings( SL, '%.3f' );
  SL.Add( '' );

  SL.Add( 'TriLineal Interp. from Src 4x4 Lin Func + Add Exp:' );
  FM2.Resample( FM1, tdimTriLineal ); // tdimConst tdimBiLineal
  FM2.AddToStrings( SL, '%.3f' );
  SL.SaveToFile( 'C:\Delphi_Prj\D\a1.txt' );

  FM1.Free;
  FM2.Free;
  FM3.Free;
  SL.Free;
end; // procedure N_Test2DFunc1

var N_TstStr1: array [0..1] of string = ( ' 123123 ', ' 456456 ' );

procedure N_TstRaramsForm();
// TN_ParamsForm Test
var
  ParForm: TN_EditParamsForm;
  sa: TN_SArray;
begin
  ParForm := N_CreateEditParamsForm( 250 );
  with ParForm do
  begin
    AddCheckBox( 'Check Box 1', True );
    AddCheckBox( 'Check Box 2', False );
    AddLEdit( 'Labeled Edit 1', 150, 'ASDasd' );
    AddFixComboBox( 'Combo Box 1', N_TstStr1, 0 );
    SetLength( sa, 1 );
    sa[0] := ' SArray ';
    AddFixComboBox( 'Combo Box 2', sa, 0 );
    AddCheckBox( 'Check Box 3', False );

    ShowSelfModal();

    N_IAdd( 'Check Box 1: ' + IntToStr( Integer(EPControls[0].CRBool) ) );
    N_IAdd( 'Check Box 2: ' + IntToStr( Integer(EPControls[1].CRBool) ) );
    N_IAdd( 'Lab  Edit 1: ' + EPControls[2].CRStr );
    N_IAdd( 'Combo Box 1: ' + IntToStr( EPControls[3].CRInt ) );
    Release; // Free ParForm
  end; // with ParForm do
end; // procedure N_TstRaramsForm();

procedure N_TstCreateOCanv();
// Memory leakage test while OCanv Create-Destroy
var
  oc: TN_OCanvas;
begin
  oc := TN_OCanvas.Create();
  oc.SetCurCRectSize( 1000, 1000, pf32bit );
  oc.SetCurCRectSize( 1010, 1010, pf32bit );

  oc.Free;
end; // procedure N_TstCreateOCanv();

procedure N_TstCyrToLat();
// N_CyrToLatChars test
begin
  N_IAdd( 'Екатеринбург - ' + N_CyrToLatChars( 'Екатеринбург' ) );
  N_IAdd( 'Поездка в Школу - ' + N_CyrToLatChars( 'Поездка в Школу' ) );
  N_IAdd( 'Каждый Охотник - ' + N_CyrToLatChars( 'Каждый Охотник' ) );
  N_IAdd( 'ЖЕЛАЕТ знать где - ' + N_CyrToLatChars( 'ЖЕЛАЕТ знать где' ) );
  N_IAdd( 'сидит Фазан. !!! - ' + N_CyrToLatChars( 'сидит Фазан. !!!' ) );
  N_IAdd( 'Ямбург, Щетиницы - ' + N_CyrToLatChars( 'Ямбург, Щетиницы' ) );
  N_IAdd( 'Аэро Аеродром единицы УЕ - ' + N_CyrToLatChars( 'Аэро Аеродром единицы УЕ' ) );
  N_IAdd( 'сарай сельдь Щас - ' + N_CyrToLatChars( 'сарай сельдь Щас' ) );
end; // procedure N_TstCyrToLat();

procedure N_TstRectsConvObj();
// TN_RectsConvObj test
var
  RCO: TN_RectsConvObj;

  procedure S( AInd: integer; ADP: TDPoint );
  begin
    N_dp := RCO.NLConvDP( ADP );
    N_IAdd( Format( 'i=%.2d (%.4f %.4f)->(%.4f %.4f)',
                      [AInd, ADP.X, ADP.Y, N_dp.X, N_dp.Y] ));
  end; // procedure S

begin
  N_Show1Str( 'TN_RectsConvObj test' );
  RCO := TN_RectsConvObj.Create;

  with RCO do
  begin
    EnvRect := FRect( 0, 0, 9, 6 );
    SrcRect := FRect( 2, 1, 7, 4 );
    DstRect := FRect( 4, 2, 5, 3 );

    S( 1, DPoint( 0.5, 0.20 ));
    S( 2, DPoint( 0.5, 0.25 ));
    S( 3, DPoint( 0.5, 0.50 ));
    S( 4, DPoint( 0.5, 5.0  ));

    Free;
  end; // with RCO do
end; // procedure N_TstRectsConvObj();

procedure N_TstMatrConvObj();
// TN_MatrConvObj test
var
  MCO: TN_MatrConvObj;
  FPoints: TN_FPArray;

  procedure S( AInd: integer; ADP: TDPoint );
  begin
    N_dp := MCO.NLConvDP( ADP );
    N_IAdd( Format( 'i=%.2d (%.4f %.4f)->(%.4f %.4f)',
                      [AInd, ADP.X, ADP.Y, N_dp.X, N_dp.Y] ));
  end; // procedure S

begin
  N_Show1Str( 'TN_MatrConvObj test' );
  MCO := TN_MatrConvObj.Create;

  with MCO do
  begin
    SetLength( FPoints, 16 );
    SetParams( 4, 4, FRect(0,0,3,3), @FPoints[0] );
    N_i := CheckParams( 0 );
    InitMatr();

    S( 1, DPoint( 0.3, 0.20 ));
    S( 2, DPoint( 1.3, 2.8 ));

    Free;
  end; // with MCO do
end; // procedure N_TstMatrConvObj();

procedure N_TstEditParamsForm1();
// EditParamsForm Test
var
  ParamsForm: TN_EditParamsForm;
begin
  ParamsForm := N_CreateEditParamsForm( 400 );
  with ParamsForm do
  begin
    Caption := 'Choose Archive to Open:';
    AddFileNameFrame( '', N_ArchFilesHistName, N_ArchFilesFilter );
    AddCheckBox( 'Close Word Server', True );

    ShowSelfModal();

    if ModalResult <> mrOK then
    begin
      Release; // Free ParamsForm
      Exit;
    end;

    Release; // Free ParamsForm
  end; // with ParamsForm do
end; // procedure N_TstEditParamsForm1();

procedure N_TstMVTATest1();
// MVTA Tests
var
  SL: TStringList;
  SPLUnit: TK_UDUnit;
  UDPI: TK_UDProgramItem;
begin
  SL := TStringList.Create;
  SL.LoadFromFile( K_ExpandFileName('(##Exe#)Data\MVTATask1.spl') );

  SPLUnit := nil;
  if not K_CompileUnit( SL.Text, SPLUnit, True ) then begin
    SPLUnit.UDDelete;
    Exit;
  end;

  UDPI := TK_UDProgramItem(SPLUnit.DirChildByObjName( 'InitVarValues' ));
  UDPI.CallSPLRoutine( [] );

//  SPLUnit.Delete(); // causes error when processing again or when Closing application
end; // procedure N_TstMVTATest1();

procedure N_TstWordActDoc1();
// Word Active Documnet Actions #1
var
  NGC: TN_GlobCont;
  CurDoc, R1: Variant;
  WS: WideString;
begin
  NGC := TN_GlobCont.Create();
  with NGC do
  begin
    DefWordServer();
    CurDoc := GCWordServer.ActiveDocument;
    R1 := CurDoc.Content;
    N_s := R1.Text;
    N_i := Length(N_s);

// абвгдежз
//    WS := Chr
    N_s := 'ЪЬ';
    WS := N_s;
//    SetLength( WS, 2 );
//    WS[1] := WideChar(1069);
//    WS[1] := WideChar(1069);
//    WS := WideChar(1068) + WideChar(1069);

    R1.Start := 10;
//
//  Remark: Delphi Error:
//          using End property causes error in showing variables in debugger and
//          not finding procedures (by Ctrl + Mouse Click) (in Editor)
//          for all subsequent Pascal code!!!
//

//    R1.End := 10;
    R1.Text := WS;

    R1.Start := 38;
//    R1.End := 39;
    R1.Text := 'Б';

  end; // with NGC do

  NGC.Free;
end; // procedure N_TstWordActDoc1();

procedure N_TstBrackets();
// N_GetBracketsInfo and  N_ExpandBracketsInStr Tests
var
  SrcStr: string;
  ResInfo: TN_BracketsInfo;
begin
  SrcStr := 'abc(#V1#)def';
  N_GetBracketsInfo( SrcStr, ResInfo );
  N_s := N_ExpandBracketsInStr( nil, SrcStr, ResInfo );

  SrcStr := '(#V1#)(#V2#)';
  N_GetBracketsInfo( SrcStr, ResInfo );
  N_s := N_ExpandBracketsInStr( nil, SrcStr, ResInfo );

  SrcStr := '123';
  N_GetBracketsInfo( SrcStr, ResInfo );
  N_s := N_ExpandBracketsInStr( nil, SrcStr, ResInfo );

  SrcStr := '(#V1#)123(#V2#)';
  N_GetBracketsInfo( SrcStr, ResInfo );
  N_s := N_ExpandBracketsInStr( nil, SrcStr, ResInfo );
end; // procedure N_TstBrackets();

procedure N_TstSpecCharsToHex();
// N_ConvSpecCharsToHex Tests
var
  Str1: string;
begin
  Str1 := 'AbcБГж';
  N_s := N_ConvSpecCharsToHex( Str1, 20, 'Win1251' );

  Str1 := 'A bc'#5'БГж12'#$D#$A'34';
  N_s := N_ConvSpecCharsToHex( Str1, 30, 'Win1251' );
end; // procedure N_TstSpecCharsToHex();

function N_TstStatTest1( ASL: TStringList ): integer;
// Stat Test1 (Karasev)
var
  i, NumIntervals: integer;
  XMin, XMax, XMid, XD, M, W, V5, V6, V7, V8: TN_DArray;
begin

//***** From file "Раздаточные материалы.doc"
//  XMin := N_CrDA( [    0,  400,  600,  800, 1000, 1200, 1600, 2000, 0 ] );
//  XMax := N_CrDA( [  400,  600,  800, 1000, 1200, 1600, 2000, 2400, 0 ] );
//  M    := N_CrDA( [ 27.2, 31.5, 26.4, 19.2, 13.3, 15.1,  7.1,  7.3, 0 ] );
//  NumIntervals := 8;

//***** From file "Расчет к самостоятельной работе.xls"
  XMin := N_CrDA( [    0,  500,   750, 1000, 1500, 2000, 3000, 4000, 0 ] );
  XMax := N_CrDA( [  500,  750,  1000, 1500, 2000, 3000, 4000, 5000, 0 ] );
  M    := N_CrDA( [ 43.4, 32.2,  23.0, 25.7, 11.4,  8.0,  2.2,  1.2, 0 ] );
  NumIntervals := 8;

  Result := NumIntervals + 1;
  M[NumIntervals] := N_SFGetSumElems( @M[0], NumIntervals );

  SetLength( XMid, Result );
  SetLength( XD,   Result );
  SetLength( W,    Result );
  SetLength( V5,   Result );
  SetLength( V6,   Result );
  SetLength( V7,   Result );
  SetLength( V8,   Result );

  N_SFAddVElems( @XMax[0], @XMin[0], Result, @XMid[0],  1.0, 0.5 );
  N_SFAddVElems( @XMax[0], @XMin[0], Result, @XD[0],   -1.0, 1.0 );
  N_SFAddVElems(    @M[0],      nil, Result, @W[0],     0.0, 100.0/147.1 );
  W[NumIntervals] := N_SFGetSumElems( @W[0], NumIntervals );

  N_SFDivideVElems( @W[0], @XD[0], Result-1, @V5[0], 1.0 ); V5[NumIntervals] := 123;
  N_SFDivideVElems( @M[0], @XD[0], Result-1, @V6[0], 1.0 ); V6[NumIntervals] := 123;

  N_SFCumSumVElems( @M[0], Result-1, @V7[0], 1.0 ); V7[NumIntervals] := 123;
  N_SFCumSumVElems( @W[0], Result-1, @V8[0], 1.0 ); V8[NumIntervals] := 123;

  for i := 0 to Result-1 do // prepare ASL
  begin
    ASL.Add( Format( '%.3f', [XD[i]] ) );
    ASL.Add( Format( '%.3f', [XMid[i]] ) );
    ASL.Add( Format( '%.3f', [M[i]] ) );
    ASL.Add( Format( '%.3f', [W[i]] ) );
    ASL.Add( Format( '%.3f', [V5[i]] ) );
    ASL.Add( Format( '%.3f', [V6[i]] ) );
    ASL.Add( Format( '%.3f', [V7[i]] ) );
    ASL.Add( Format( '%.3f', [V8[i]] ) );
  end; // for i := 1 to Result do // prepare ASL

end; // procedure N_TstStatTest1

function N_TstStatTest2( ASL: TStringList ): integer;
// Stat Test2 (Karasev)
var
  i, NumIntervals: integer;
  XE, D1, D9: double;
  XMin, XMax, XMid, XD, M, W: TN_DArray;
  V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18: TN_DArray;
begin

//***** From file "Раздаточные материалы.doc"
//  XMin := N_CrDA( [    0,  400,  600,  800, 1000, 1200, 1600, 2000, 0 ] );
//  XMax := N_CrDA( [  400,  600,  800, 1000, 1200, 1600, 2000, 2400, 0 ] );
//  M    := N_CrDA( [ 27.2, 31.5, 26.4, 19.2, 13.3, 15.1,  7.1,  7.3, 0 ] );
//  NumIntervals := 8;

//***** From file "Расчет к самостоятельной работе.xls"
  XMin := N_CrDA( [    0,  500,   750, 1000, 1500, 2000, 3000, 4000, 0 ] );
  XMax := N_CrDA( [  500,  750,  1000, 1500, 2000, 3000, 4000, 5000, 0 ] );
  M    := N_CrDA( [ 43.4, 32.2,  23.0, 25.7, 11.4,  8.0,  2.2,  1.2, 0 ] );
  NumIntervals := 8;

  Result := NumIntervals + 1;
  M[NumIntervals] := N_SFGetSumElems( @M[0], NumIntervals );

  SetLength( XMid, Result );
  SetLength( XD,   Result );
  SetLength( W,    Result );
  SetLength( V5,   Result );
  SetLength( V6,   Result );
  SetLength( V7,   Result );
  SetLength( V8,   Result );
  SetLength( V9,   Result );
  SetLength( V10,  Result );
  SetLength( V11,  Result );
  SetLength( V12,  Result );
  SetLength( V13,  Result );
  SetLength( V14,  Result );
  SetLength( V15,  Result );
  SetLength( V16,  Result );
  SetLength( V17,  Result );
  SetLength( V18,  Result );

  N_SFAddVElems( @XMax[0], @XMin[0], Result, @XMid[0],  1.0, 0.5 );
  N_SFAddVElems( @XMax[0], @XMin[0], Result, @XD[0],   -1.0, 1.0 );
  N_SFAddVElems(    @M[0],      nil, Result, @W[0],     0.0, 100.0/147.1 );
  W[NumIntervals] := N_SFGetSumElems( @W[0], NumIntervals );

  N_SFDivideVElems( @W[0], @XD[0], Result-1, @V5[0], 1.0 ); V5[NumIntervals] := 123;
  N_SFDivideVElems( @M[0], @XD[0], Result-1, @V6[0], 1.0 ); V6[NumIntervals] := 123;

  N_SFCumSumVElems( @M[0], Result-1, @V7[0], 1.0 ); V7[NumIntervals] := 123;
  N_SFCumSumVElems( @W[0], Result-1, @V8[0], 1.0 ); V8[NumIntervals] := 123;

  N_SFMultVElems( @XMid[0], @M[0], Result-1, @V9[0], 1.0 );
  V9[NumIntervals] := N_SFGetSumElems( @V9[0], NumIntervals );

  N_SFMultVElems( @XMid[0], @W[0], Result-1, @V10[0], 1.0 );
  V10[NumIntervals] := N_SFGetSumElems( @V10[0], NumIntervals );

  XE := V10[NumIntervals] / 100;
  N_SFAddVElems( @XMid[0], nil, Result-1, @V11[0], -XE, 1.0 );
  N_SFAbsVElems( @V11[0], Result-1, @V12[0], 1.0 );

  N_SFMultVElems( @V11[0], @V11[0], Result-1, @V11[0], 1.0 );
  N_SFMultVElems( @V11[0], @W[0], Result-1, @V11[0], 1.0/100 );
  V11[NumIntervals] := N_SFGetSumElems( @V11[0], NumIntervals );

  N_SFMultVElems( @V12[0], @W[0], Result-1, @V12[0], 1.0/100 );
  V12[NumIntervals] := N_SFGetSumElems( @V12[0], NumIntervals );

  N_SFAddVElems( @V10[0], nil, Result-1, @V13[0], 0.0, 1.0/V10[NumIntervals] );
  V13[NumIntervals] := N_SFGetSumElems( @V13[0], NumIntervals );

  N_SFCumSumVElems( @V13[0], Result-1, @V14[0], 1.0 ); V14[NumIntervals] := 123;

  N_SFMultVElems( @V8[0], @V14[1], Result-2, @V15[0], 1.0/100 ); // у Олега ACRes=1 ?!
  V15[NumIntervals-1] := 0;
  V15[NumIntervals] := N_SFGetSumElems( @V15[0], NumIntervals );

  N_SFMultVElems( @V8[1], @V14[0], Result-2, @V16[1], 1.0/100 );
  V16[0] := 0;
  V16[NumIntervals] := N_SFGetSumElems( @V16[0], NumIntervals );

  N_SFMultVElems( @V13[0], @V13[0], Result-1, @V17[0], 1.0 );
  V17[NumIntervals] := N_SFGetSumElems( @V17[0], NumIntervals );

  //*** Scalar values:
  // 1) V18[0] (XE)
  // 2) V18[1] (Mode)
  // 3) V18[2] (Median)
  // 4) V18[3] (D9/D1) (Error in Karasev doc file)
  // 5) V18[4] (X10/X1)
  // 6) V11[NumIntervals]
  // 7) V18[5] (sigma)
  // 8) V12[NumIntervals]
  // 9) V18[6]
  // 10) V18[7]
  // 11) V17[NumIntervals]
  // 12) V18[8]

  V18[0] := XE;
  V18[1] := N_SFGetVectorMode( @XMin[0], @XD[0], @V6[0], Result-1 );
  V18[2] := N_SFGetDecCoef( @XMin[0], @XD[0], @W[0], @V8[0], Result-1, 50.0 );

  D1 := N_SFGetDecCoef( @XMin[0], @XD[0], @W[0], @V8[0], Result-1, 10.0 );
  D9 := N_SFGetDecCoef( @XMin[0], @XD[0], @W[0], @V8[0], Result-1, 90.0 );
  V18[3] := D9 / D1;
  V18[4] := ( D9 + XMax[NumIntervals-1]) / ( D1 + 0 );
  V18[5] := Sqrt( V11[NumIntervals] );
  V18[6] := 100 * V18[5] / XE;
  V18[7] := V15[NumIntervals] - V16[NumIntervals];
  V18[8] := ( XE - V18[1] ) / V18[5];


  for i := 0 to Result-1 do // prepare ASL
  begin
    ASL.Add( Format( '%.3f', [V9[i]] ) );
    ASL.Add( Format( '%.3f', [V10[i]] ) );
    ASL.Add( Format( '%.3f', [V11[i]] ) );
    ASL.Add( Format( '%.3f', [V12[i]] ) );
    ASL.Add( Format( '%.3f', [V13[i]] ) );
    ASL.Add( Format( '%.3f', [V14[i]] ) );
    ASL.Add( Format( '%.3f', [V15[i]] ) );
    ASL.Add( Format( '%.3f', [V16[i]] ) );
    ASL.Add( Format( '%.3f', [V17[i]] ) );
    ASL.Add( Format( '%.3f', [V18[i]] ) );
  end; // for i := 1 to Result do // prepare ASL

end; // procedure N_TstStatTest2

procedure N_TstCNKInds();
// N_CalcCNKInds Tests
var
  ResInds: TN_IArray;
  SrcDInds: TN_DArray;
begin
  SetLength( ResInds, 5 );

  SrcDInds := N_CrDA( [0, 0.5, 0.5, 0.2, 0.8 ] );
  N_RoundVector( @SrcDInds[0], 5, @ResInds[0] );
  N_RoundVector( @SrcDInds[0], 5, @ResInds[0] );
  N_RoundVector( @SrcDInds[0], 5, @ResInds[0] );
  N_RoundVector( @SrcDInds[0], 5, @ResInds[0] );

  N_CalcCNKInds( 10, 1, 2, 0, @ResInds[0] );
  N_CalcCNKInds( 10, 1, 2, 1, @ResInds[0] );

  N_CalcCNKInds( 10, 1, 2, 0, @ResInds[0] );
  N_CalcCNKInds( 10, 1, 2, 1, @ResInds[0] );

  N_CalcCNKInds( 10, 2, 3, 0, @ResInds[0] );
  N_CalcCNKInds( 10, 2, 3, 1, @ResInds[0] );
  N_CalcCNKInds( 10, 2, 3, 2, @ResInds[0] );

  N_CalcCNKInds( 10, 2, 3, 0, @ResInds[0] );
  N_CalcCNKInds( 10, 2, 3, 1, @ResInds[0] );
  N_CalcCNKInds( 10, 2, 3, 2, @ResInds[0] );

  N_CalcCNKInds( 10, 2, 3, 0, @ResInds[0] );
  N_CalcCNKInds( 10, 2, 3, 1, @ResInds[0] );
  N_CalcCNKInds( 10, 2, 3, 2, @ResInds[0] );

  N_CalcCNKInds( 5, 4, 3, 0, @ResInds[0] );
  N_CalcCNKInds( 5, 4, 3, 1, @ResInds[0] );
  N_CalcCNKInds( 5, 4, 3, 2, @ResInds[0] );

  N_CalcCNKInds( 5, 5, 2, 0, @ResInds[0] );
  N_CalcCNKInds( 5, 5, 2, 1, @ResInds[0] );

  N_i := 1;
end; // procedure N_TstCNKInds();

procedure N_TstSplitIntegerValue();
// N_SplitIntegerValue Tests
var
  ResInds: TN_IArray;
  SrcDInds: TN_DArray;
begin
  SetLength( ResInds, 2 );

  SrcDInds := N_CrDA( [ 1.0, 1.0 ] );
{
  N_SplitIntegerValue( @SrcDInds[0], 2, 30, @ResInds[0] );
  N_SplitIntegerValue( @SrcDInds[0], 2, 31, @ResInds[0] );
  N_SplitIntegerValue( @SrcDInds[0], 2, 32, @ResInds[0] );

  SrcDInds := N_CrDA( [ 1.0, 2.0 ] );
  N_SplitIntegerValue( @SrcDInds[0], 2, 30, @ResInds[0] );
  N_SplitIntegerValue( @SrcDInds[0], 2, 31, @ResInds[0] );
  N_SplitIntegerValue( @SrcDInds[0], 2, 32, @ResInds[0] );

  SetLength( ResInds, 3 );
  SrcDInds := N_CrDA( [ 1.0, 1.0, 2.0 ] );
  N_SplitIntegerValue( @SrcDInds[0], 3, 30, @ResInds[0] );
  N_SplitIntegerValue( @SrcDInds[0], 3, 31, @ResInds[0] );
  N_SplitIntegerValue( @SrcDInds[0], 3, 32, @ResInds[0] );
  N_SplitIntegerValue( @SrcDInds[0], 3, 33, @ResInds[0] );
  N_SplitIntegerValue( @SrcDInds[0], 3, 34, @ResInds[0] );
  N_SplitIntegerValue( @SrcDInds[0], 3, 35, @ResInds[0] );
}
  N_i := 1;
end; // procedure N_TstSplitIntegerValue();

procedure N_TstSPLToBinSpeed();
// Check Speed of converting Sets from SPL text to bin
var
  RadUnits: TN_RadUnits;
  SShape: TN_StandartShape;
begin
  N_IAdd( 'N_TstSPLToBinSpeed' );
  N_IAdd( '' );

//type TN_RadUnits = ( ruNone, ruPercent, ruLLW, ruUser, rumm );
// type TN_StandartShape SetOf ( sshATriangle="A Triangle", sshVTriangle="V Triangle", ...

  N_s := 'ruPercent';
  RadUnits := ruLLW;
  N_T1.Start();
  N_s2 := K_SPLValueFromString( RadUnits, K_GetTypeCodeSafe( 'TN_RadUnits' ).All, N_s );
  N_T1.SS( 'enum' );

  N_s := '[sshATriangle]';
  SShape := [sshVTriangle];
  N_T1.Start();
  N_s2 := K_SPLValueFromString( SShape, K_GetTypeCodeSafe( 'TN_StandartShape' ).All, N_s );
  N_T1.SS( 'one flag' );

end; // procedure N_TstSPLToBinSpeed();

procedure N_TstRastr1FrConvFunc();
// Create Rastr1BaseForm with Rastr1Fr with Convertion Function
//var
//  i: integer;
//  Rast1BaseForm: TN_Rast1BaseForm;
//  RastForm: TN_RastVCTForm;
begin
  N_CreateRastVCTForm( @N_TstRastVCTForm, nil );
  N_TstRastVCTForm.Show;

end; // procedure N_TstRastr1FrConvFunc

const
  GTAPIB_CONNECT_EXECUTOR = $8001; {//!< Executor}
  GTAPIB_CONNECT_LEVEL1   = $8002; {//!< Level 1}
  GTAPIB_CONNECT_LEVEL2   = $8003; {//!< Level 2}

type
  INT_FUNC = function(): integer; stdcall;
  {$EXTERNALSYM INT_FUNC}
  TINT_FUNC = INT_FUNC;

  HGTBSESSION = integer;

  OnConnect_PROC = procedure( hSession: integer; lpParam: Pointer; nServer, nState: integer);
//  {$EXTERNALSYM OnConnect_PROC}
//  TOnConnect_PROC = OnConnect_PROC;
  TPOnConnect_PROC = ^OnConnect_PROC;

  OnErrorMessage_PROC = procedure( hSession: integer; lpParam: Pointer;
                                   nErrCode, dwOrderID: integer; pszDesc: TN_BytesPtr );
//  {$EXTERNALSYM OnErrorMessage_PROC}
//  TOnErrorMessage_PROC = OnErrorMessage_PROC;
  TPOnErrorMessage_PROC = ^OnErrorMessage_PROC;

  TGTBONCONNECT = Pointer;
  TGTBONORDERCHANGED = Pointer;
  TGTBONACCOUNTCHANGED = Pointer;
  TGTBONERRORMESSAGE = Pointer;
  TGTBONGOTLEVEL1 = Pointer;
  TGTBONGOTPRINT = Pointer;
  TGTBONGOTLEVEL2 = Pointer;
  TGTBONGOTTEXT = Pointer;

  TGTBSessionCallback = packed record
    pfnOnConnect:        TGTBONCONNECT;
    pfnOnOrderChanged:   TGTBONORDERCHANGED;
    pfnOnAccountChanged: TGTBONACCOUNTCHANGED;
    pfnOnErrorMessage:   TGTBONERRORMESSAGE;
    pfnOnGotLevel1:      TGTBONGOTLEVEL1;
    pfnOnGotPrint:       TGTBONGOTPRINT;
    pfnOnGotLevel2:      TGTBONGOTLEVEL2;
    pfnOnGotText:        TGTBONGOTTEXT;
  end; // TGTBSessionCallback = record

  TGTBSessionCallback2 = record
//    Dummy0: integer;
    pfnOnConnect:        TGTBONCONNECT;
    Dummy1: integer;
    pfnOnOrderChanged:   TGTBONORDERCHANGED;
    Dummy2: integer;
    pfnOnAccountChanged: TGTBONACCOUNTCHANGED;
    Dummy3: integer;
    pfnOnErrorMessage:   TGTBONERRORMESSAGE;
    Dummy4: integer;
    pfnOnGotLevel1:      TGTBONGOTLEVEL1;
    Dummy5: integer;
    pfnOnGotPrint:       TGTBONGOTPRINT;
    Dummy6: integer;
    pfnOnGotLevel2:      TGTBONGOTLEVEL2;
    Dummy7: integer;
    pfnOnGotText:        TGTBONGOTTEXT;
    Dummy8: integer;
  end; // TGTBSessionCallback = record

  TGTBSessionCallback3 = record
    Dummy0: integer;
    pfnOnConnect:        OnConnect_PROC;
    Dummy1: integer;
    pfnOnOrderChanged:   TGTBONORDERCHANGED;
    Dummy2: integer;
    pfnOnAccountChanged: TGTBONACCOUNTCHANGED;
    Dummy3: integer;
    pfnOnErrorMessage:   OnErrorMessage_PROC;
    Dummy4: integer;
    pfnOnGotLevel1:      TGTBONGOTLEVEL1;
    Dummy5: integer;
    pfnOnGotPrint:       TGTBONGOTPRINT;
    Dummy6: integer;
    pfnOnGotLevel2:      TGTBONGOTLEVEL2;
    Dummy7: integer;
    pfnOnGotText:        TGTBONGOTTEXT;
    Dummy8: integer;
  end; // TGTBSessionCallback = record

  TPGTBSESSIONCALLBACK = ^TGTBSessionCallback;

  CreateSession_FUNC = function( hParent: HWND;
//                                 CallBackConst: integer;
                                 lpCallBack: Pointer;
                                 lpParam: Pointer): HGTBSESSION; stdcall;
  {$EXTERNALSYM CreateSession_FUNC}
  TCreateSession_FUNC = CreateSession_FUNC;

  SubClassSession_FUNC = function( hParent: HWND;
                                 rcId: integer;
                                 lpCallBack: Pointer;
                                 lpParam: Pointer): HGTBSESSION; stdcall;
  {$EXTERNALSYM SubClassSession_FUNC}
  TSubClassSession_FUNC = SubClassSession_FUNC;

  DeleteSession_FUNC = function( hSession: integer ): integer; stdcall;
  {$EXTERNALSYM DeleteSession_FUNC}
  TDeleteSession_FUNC = DeleteSession_FUNC;

  SetAddress_FUNC = function( hSession, nServerType: integer;
                              pszIPAddress: PChar; nPort: TN_UInt2 ): integer; stdcall;
  {$EXTERNALSYM SetAddress_FUNC}
  TSetAddress_FUNC = SetAddress_FUNC;

  Login_FUNC = function( hSession: integer; pszUserID, pszPassword: TN_BytesPtr ): integer; stdcall;
  {$EXTERNALSYM Login_FUNC}
  TLogin_FUNC = Login_FUNC;


procedure N_GTBOnConnect( hSession: integer; lpParam: Pointer; nServer, nState: integer ); stdcall;
begin
  N_i := nServer;
  N_WarnByMessage( 'N_GTBOnConnect' );
end; // procedure N_GTBOnConnect

procedure N_GTBOnErrorMessage( hSession: integer; lpParam: Pointer;
                               nErrCode, dwOrderID: integer; pszDesc: TN_BytesPtr ); stdcall;
begin
  N_i := nErrCode;
//  N_s := pszDesc;
  N_WarnByMessage( 'N_GTBOnErrorMessage' );
end; // procedure N_GTBOnErrorMessage

procedure N_TstUseDLL( AHandle: integer );
// Using DLL test
var
  HExtDLL: HMODULE;
  DLLFName, IPAdr, UserID, UserPW: string;
  MyhSession: integer;

  Initialize, Uninitialize: TINT_FUNC;
  CreateSession: TCreateSession_FUNC;
//  SubClassSession: TSubClassSession_FUNC;
  DeleteSession: TDeleteSession_FUNC;
  SetAddress: TSetAddress_FUNC;
  DoLogin: TLogin_FUNC;

  SessionCallback: TGTBSessionCallback;
begin
  N_p := Pointer(@N_GTBOnConnect);

  N_GTBOnConnect( 0, nil, 1, 2 );

  DLLFName := K_ExpandFileName( '(##Exe#)..\GTAPI\GTAPIB.dll' );
  HExtDLL  := LoadLibrary( PChar(DLLFName) );

  Initialize := GetProcAddress( HExtDLL, 'gtbInitialize' );
  N_i := 2;
  N_i := Initialize();

  FillChar( SessionCallback, SizeOf(SessionCallback), 0 );
  N_p1 := Pointer(@N_GTBOnConnect);
  N_p2 := Pointer(@N_GTBOnErrorMessage);
  SessionCallback.pfnOnConnect      := @N_GTBOnConnect;
  SessionCallback.pfnOnErrorMessage := @N_GTBOnErrorMessage;

//  SessionCallback.pfnOnConnect( 10, nil, 11, 12 );
//  SessionCallback.pfnOnErrorMessage( 10, nil, 11, 12, 'message' );
//  N_GTBOnConnect( 10, nil, 11, 12 );
//  N_GTBOnErrorMessage( 10, nil, 11, 12, 'message' );

  N_p1 := @SessionCallback;

  CreateSession := GetProcAddress( HExtDLL, 'gtbCreateSession' );
//  MyhSession := 2;
//  MyhSession := CreateSession( AHandle, @SessionCallback.pfnOnConnect, Pointer(AHandle) );
//  MyhSession := CreateSession( AHandle, TN_BytesPtr(@SessionCallback), Pointer(AHandle) );
  MyhSession := CreateSession( AHandle, N_p1, Pointer(AHandle) );
  Application.Processmessages;
//  exit;

//  SubClassSession := GetProcAddress( HExtDLL, 'gtbSubClassSession' );
//  MyhSession := SubClassSession( AHandle, 0, N_p1, Pointer(AHandle) );


  SetAddress := GetProcAddress( HExtDLL, 'gtbSetAddress' );

//  gtbSetAddress(g_hSession, GTAPIB_CONNECT_EXECUTOR, "76.8.64.3", 15805);
//	gtbSetAddress(g_hSession, GTAPIB_CONNECT_LEVEL1	, "69.64.202.157", 16811);
//	gtbSetAddress(g_hSession, GTAPIB_CONNECT_LEVEL2	, "69.64.202.157", 16810);
//	if(gtbLogin(g_hSession, "U_BOGOMOLOV", "1") != 0)

  IPAdr := '76.8.64.3';
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_EXECUTOR, PChar(@IPAdr[1]), 15805 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  IPAdr := '69.64.202.157';
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, PChar(@IPAdr[1]), 16811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, PChar(@IPAdr[1]), 16810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
{
  IPAdr := '76.8.64.3';
  N_i := 2;
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_EXECUTOR, PChar(@IPAdr[1]), 15805 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );

  IPAdr := '69.64.202.157';
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 16811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 26811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 36811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 46811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 56811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );

  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 17811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 27811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 37811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 47811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 57811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );

  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 16811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 26811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 36811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 46811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 56811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );

  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 17811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 27811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 37811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 47811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL1, @IPAdr[1], 57811 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );

  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 16810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 26810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 36810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 46810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 56810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );

  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 17810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 27810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 37810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 47810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 57810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );

  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 18810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 28810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 38810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 48810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 58810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );

  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 19810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 29810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 39810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 49810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
  N_i := SetAddress( MyhSession, GTAPIB_CONNECT_LEVEL2, @IPAdr[1], 59810 ); if N_i <> 0 then N_WarnByMessage( 'GTB Error!' );
}
  UserID := 'U_BOGOMOLOV';
//  UserID := '2';
  UserPW := '1';
  DoLogin := GetProcAddress( HExtDLL, 'gtbLogin' );
  N_p := Pointer(@DoLogin); // to avoid warnings, Pointer(...) is needed for Delphi XE5,6
  N_i := 2;
//  N_i := DoLogin( MyhSession, PChar(@UserID[1]), PChar(@UserPW[1]) );

  DeleteSession := GetProcAddress( HExtDLL, 'gtbDeleteSession' );
  N_i := 2;
  N_i := DeleteSession( MyhSession );

  Uninitialize := GetProcAddress( HExtDLL, 'gtbUninitialize' );
  N_i := 2;
  N_i := Uninitialize();

  FreeLibrary( HExtDLL );


end; // procedure N_TstUseDLL

{
procedure N_TstPanelsForm();
// Doc CMREditForm to PanelsForms
var
  CMMain2F: TN_CMMain2Form;
  CMREd2F: TN_CMREdit2Form;
begin
  CMMain2F := TN_CMMain2Form(N_MainModalForm);
  CMREd2F  := TN_CMREdit2Form(CMMain2F.SlidesVTreeFrame.CMREdit2Form);
  if CMREd2F = nil then Exit;

  if N_PanelsForm = nil then
  begin
    Application.CreateForm( TN_TstPanelsForm, N_PanelsForm );
    N_PanelsForm.Show;
    N_b := CMREd2F.ManualDock( N_PanelsForm.Panel1, nil, alClient );
    N_PanelsForm.IPhase := 1;
    N_PanelsForm.CMREd2F1 := CMREd2F;
    Exit;
  end;

  if N_PanelsForm.IPhase = 1 then
  begin
    N_b := CMREd2F.ManualDock( N_PanelsForm.Panel2, nil, alClient );
    N_PanelsForm.IPhase := 2;
    N_PanelsForm.CMREd2F2 := CMREd2F;

    N_PanelsForm.CMREd2F1.Visible:= False;
    Exit;
  end;

  if N_PanelsForm.IPhase = 2 then
  begin
//    N_PanelsForm.CMREd2F1.Visible := False;
    N_PanelsForm.CMREd2F1.ManualFloat( Rect(10, 10, 220, 220) );

    N_b := N_PanelsForm.CMREd2F2.ManualDock( N_PanelsForm.Panel1, nil, alClient );
    N_b := N_PanelsForm.CMREd2F1.ManualDock( N_PanelsForm.Panel2, nil, alClient );
    N_PanelsForm.IPhase := 3;
    Exit;
  end;

  if N_PanelsForm.IPhase = 3 then
  begin
    N_PanelsForm.CMREd2F1.Visible := True;
    Exit;
  end;

//  N_b := CMREd2F.ManualDock( N_PanelsForm.Panel2, N_PanelsForm.Panel2, alLeft );
  N_b := CMREd2F.ManualDock( N_PanelsForm.Panel1, nil, alClient );
  N_Alert( 'About to Doc2' );
  N_b := CMREd2F.ManualDock( N_PanelsForm.Panel2, nil, alClient );
  Exit;
  N_Alert( 'About to UnDoc' );
  CMREd2F.ManualFloat( Rect(150, 100, 450, 400) );

//  CMMain2F.SlidesVTreeFrame.Align := alRight;
//  N_b := CMREd2F.ManualDock( CMMain2F, nil, alClient );
//  N_b := CMREd2F.ManualDock( CMMain2F.SlidesVTreeFrame, nil, alLeft );
//  CMREd2F.Top := CMREd2F.Top + 20;
//  N_b := CMREd2F.ManualDock( TstPanelsForm.GroupBox1, nil, alClient );
//  Exit;


//  N_Alert( 'About to Release' );
//  TstPanelsForm.Release;
end; // procedure N_TstPanelsForm
}

procedure N_TstIPCTest1();
// Interprocess communication Test1
var
  UniqStr: string;
  HFileMap, HFileMap2: THANDLE; // HMutex,
  MemPtr, MemPtr2, MemPtr3: Pointer; //TN_BytesPtr; // Pointer;
  CurPtr, LocalPtr: PInteger;
  MainHWND, ChildHWND: HWND;
  ParamsForm: TN_EditParamsForm;
begin
  ParamsForm := N_CreateEditParamsForm( 400 );
  with ParamsForm do
  begin
    AddLEdit( 'Ed1', 350, 'asdasd' );
    AddLEdit( 'Ed2', 350, 'asdasd' );

    UniqStr := 'N_TstIPCTest1';
//    HMutex := Windows.OpenMutex( MUTEX_ALL_ACCESS, False, PChar(UniqStr) ); // it works OK
    HFileMap := Windows.OpenFileMapping( FILE_MAP_WRITE, False, PChar(UniqStr) );
    N_i := GetLastError();
    N_s := SysErrorMessage( N_i );

    if HFileMap = 0 then // Main Process
    begin
      Caption := 'Main Process';

//      HMutex := Windows.CreateMutex( nil, False, PChar(UniqStr) ); // it works OK
      HFileMap := Windows.CreateFileMapping( THANDLE($FFFFFFFF), nil,
                                     PAGE_READWRITE, 0, 100,  PChar(UniqStr) );
      N_i := GetLastError();
      N_s := SysErrorMessage( N_i );
      MemPtr := Windows.MapViewOfFile( HFileMap, FILE_MAP_ALL_ACCESS, 0, 0, 100 );
      N_s := SysErrorMessage( GetLastError() );
      EPFUserPtr1 := MemPtr;

      HFileMap2 := Windows.OpenFileMapping( FILE_MAP_WRITE, False, PChar(UniqStr) );
      N_i := HFileMap2;
      N_i := GetLastError();
      N_s := SysErrorMessage( N_i );

      HFileMap2 := Windows.CreateFileMapping( THANDLE($FFFFFFFF), nil,
                                     PAGE_READWRITE, 0, 100,  PChar(UniqStr) );
      N_i := GetLastError(); // N_i = 183 if already exists
      N_s := SysErrorMessage( N_i );
      MemPtr2 := Windows.MapViewOfFile( HFileMap2, FILE_MAP_ALL_ACCESS, 0, 0, 100 );
      N_i := 0;
      N_i := GetLastError();
      N_s := SysErrorMessage( N_i );

      N_i := PInteger(MemPtr2)^;
      PInteger(MemPtr)^ := 123457;
      N_i := PInteger(MemPtr2)^;

      CurPtr := MemPtr;
      CurPtr^ := 123458; Inc( CurPtr );
      CurPtr^ := Handle; // Main ParamsForm Window Handle
      EPFUserPtr1 := MemPtr;

      N_i1 := K_ShellExecute( 'open', Application.ExeName, -1, @N_s, '' );

      ShowSelfModal();
      N_b := Windows.UnmapViewOfFile( MemPtr );
      Assert( N_b, 'Bad UnMap1' );
      N_b := Windows.CloseHandle( HFileMap );
      Assert( N_b, 'Bad CloseHandle1' );
    end else //********** Child Process
    begin
      Caption := 'Child Process';
      MemPtr3 := Windows.MapViewOfFile( HFileMap, FILE_MAP_ALL_ACCESS, 0, 0, 100 );
      Assert( MemPtr3 <> nil, 'Bad MemPtr3' );
      CurPtr := MemPtr3;
      EPFUserPtr1 := MemPtr3;
      N_i := CurPtr^; Inc( CurPtr );
      TLabeledEdit(EPControls[0].CRContr).Text := IntToStr( N_i );

      MainHWND := CurPtr^; Inc( CurPtr );
      CurPtr^ := 123459; Inc( CurPtr );
      ChildHWND := Handle; // Child ParamsForm Window Handle
      CurPtr^ := ChildHWND;

      windows.SendMessage( MainHWND, WM_User+10, ChildHWND, 123 );
      LocalPtr := @N_i;
      N_i := LocalPtr^;

      N_T1.Start();
      N_T1.Stop();
      N_T1.Show( 'zero time' );

      N_T1.Start();
      LocalPtr := Pointer(@MainHWND);
      N_T1.Stop();
      N_T1.Show( 'one local assign' );

      N_T1.Start();
//      LocalPtr := Pointer(@MainHWND); Inc( LocalPtr );
      N_i := LocalPtr^;
      N_T1.Stop();
      N_T1.Show( 'two local assigns' );

      N_T1.Start();
//      CurPtr^ := ChildHWND;
      N_T1.Stop();
      N_T1.Show( 'one global assign' );

      N_T1.Start();
//      CurPtr^ := ChildHWND; Inc( CurPtr );
      N_i := CurPtr^;
      N_T1.Stop();
      N_T1.Show( 'two global assigns' );


      N_T1.Start();
      windows.SendMessage( MainHWND, WM_User+10, ChildHWND, 130 ); // empty call
      N_T1.Stop();
      N_T1.Show( 'empty SendMessage' );

      N_T1.Start();
      windows.SendMessage( MainHWND, WM_User+10, ChildHWND, 126 ); // nested call
      N_T1.Stop();
      N_T1.Show( 'nested SendMessage' );

      N_T1.Start();
      windows.SendMessage( MainHWND, WM_User+10, ChildHWND, 130 ); // empty call
      N_T1.Stop();
      N_T1.Show( 'empty SendMessage' );

      N_T1.Start();
      windows.SendMessage( MainHWND, WM_User+10, ChildHWND, 126 ); // nested call
      N_T1.Stop();
      N_T1.Show( 'nested SendMessage' );

      N_T1.Start();
      windows.SendMessage( MainHWND, WM_User+10, ChildHWND, 130 ); // empty call
      N_T1.Stop();
      N_T1.Show( 'empty SendMessage' );

      N_T1.Start();
      windows.SendMessage( MainHWND, WM_User+10, ChildHWND, 126 ); // nested call
      N_T1.Stop();
      N_T1.Show( 'nested SendMessage' );

      ShowSelfModal();

      N_b := Windows.UnmapViewOfFile( MemPtr3 );
      Assert( N_b, 'Bad UnMap2' );
      N_b := Windows.CloseHandle( HFileMap );
      Assert( N_b, 'Bad CloseHandle2' );
    end;

  end; // with ParamsForm do


end; // procedure N_TstIPCTest1();

procedure N_TstPackedInts();
// just Show Paked Ints ranges
var
  i: integer;
  MaxVal: double;
begin
//  N_PCAdd( 0, '*** N_TstPackedInts ***' );
  N_IAdd( '*** N_TstPackedInts ***' );

  N_IAdd( '' );
  N_IAdd( '3 bits mantissa' );

  for i := 0 to 5 do // along exp field sizes
  begin
    MaxVal := (Power( 2, 3 ) - 1) * Power( 2, Power(2,i)-1 );
    N_IAdd( Format( '  ExpSize=%d, MaxVal=%.2g', [i, MaxVal] ) );
  end; // for i := 0 to 5 do // along exp field sizes

  N_IAdd( '' );
  N_IAdd( '4 bits mantissa' );

  for i := 0 to 5 do // along exp field sizes
  begin
    MaxVal := (Power( 2, 4 ) - 1) * Power( 2, Power(2,i)-1 );
    N_IAdd( Format( '  ExpSize=%d, MaxVal=%.3g', [i, MaxVal] ) );
  end; // for i := 0 to 5 do // along exp field sizes

  N_IAdd( '' );
  N_IAdd( '5 bits mantissa' );

  for i := 0 to 5 do // along exp field sizes
  begin
    MaxVal := (Power( 2, 5 ) - 1) * Power( 2, Power(2,i)-1 );
    N_IAdd( Format( '  ExpSize=%d, MaxVal=%.3g', [i, MaxVal] ) );
  end; // for i := 0 to 5 do // along exp field sizes

  N_IAdd( '' );
  N_IAdd( '6 bits mantissa' );

  for i := 0 to 5 do // along exp field sizes
  begin
    MaxVal := (Power( 2, 6 ) - 1) * Power( 2, Power(2,i)-1 );
    N_IAdd( Format( '  ExpSize=%d, MaxVal=%.4g', [i, MaxVal] ) );
  end; // for i := 0 to 5 do // along exp field sizes

  N_IAdd( '' );
  N_IAdd( '7 bits mantissa' );

  for i := 0 to 5 do // along exp field sizes
  begin
    MaxVal := (Power( 2, 7 ) - 1) * Power( 2, Power(2,i)-1 );
    N_IAdd( Format( '  ExpSize=%d, MaxVal=%.4g', [i, MaxVal] ) );
  end; // for i := 0 to 5 do // along exp field sizes

  N_IAdd( '' );
  N_IAdd( '8 bits mantissa' );

  for i := 0 to 5 do // along exp field sizes
  begin
    MaxVal := (Power( 2, 8 ) - 1) * Power( 2, Power(2,i)-1 );
    N_IAdd( Format( '  ExpSize=%d, MaxVal=%.4g', [i, MaxVal] ) );
  end; // for i := 0 to 5 do // along exp field sizes

end; // procedure N_TstPackedInts

procedure N_TstNIRs();
// Test NIRs (Neighbour Integer Ranges) related procedures
var
  i, MaxInd, NumRanges: integer;
  HistData1, NIRs1, NIRs2, XLAT: TN_IArray;
  GroupedData1: TN_DArray;
begin
  MaxInd := 255;
  SetLength( HistData1, MaxInd+1 );
  for i := 0 to MaxInd do
    HistData1[i] := 100;

  NumRanges := 4;
  N_CalcUniformNIRs( NIRs1, NumRanges, 0, MaxInd );
  N_GroupHistData( HistData1, NIRs1, NumRanges, GroupedData1 );
//  GroupedData1[0] := 0.05*GroupedData1[0];

  N_UpdateNIRsByWCoefs( NIRs1, GroupedData1, NumRanges, NIRs2, 10, 19, 1.5 );
  N_CalcUniformXLAT( XLAT, MaxInd+1 );
  NIRs1[0] := 60;
  N_CalcXLATByTwoNIRs( XLAT, NIRs1, NIRs2, NumRanges );
  N_i := XLAT[MaxInd];
end; // procedure N_TstNIRs

//  MEM_COMMIT   = $01000;
//  MEM_RESERVE  = $02000;
//  MEM_FREE     = $10000;

procedure N_TstMemAlloc1();
// Memory Allocation Test #1
var
  i, ie6: integer;
  Total: int64;
  NextPtr: DWORD;
  Buf: TStringList;
  BA1, BA2: TN_BArray;
  DIB1, DIB2: TN_DIBObj;
  OCanv: TN_OCanvas;
  MemInfo: TMemoryBasicInformation;
  Ptr1: Pointer;
  Label Show;

  function MemFlags( AMemInfo: TMemoryBasicInformation ): string;
  begin
    with AMemInfo do
      Result := Format( 'Base=%.8x, Size=%8.3f, State=%.6x, Protect=%.6x, Type=%.6x',
              [DWORD(BaseAddress), 0.001*RegionSize/1024.0, State, Protect, Type_9] );
  end;

begin
  Buf := TStringList.Create;
  Buf.Add( '  N_TstMemAlloc1' );
  Buf.Add( '' );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( '' );
//  Ptr1 := Pointer(10);
  Total := 0;
  NextPtr := 0;

  for i := 0 to 3500 do
  begin
    N_i2 := Windows.VirtualQuery( Pointer(NextPtr), MemInfo, SizeOf(MemInfo) );
    Buf.Add( MemFlags( MemInfo ) );
    if N_i2 = 0 then Break;
    NextPtr := DWORD(MemInfo.BaseAddress) + MemInfo.RegionSize;
    Total := Total + MemInfo.RegionSize;
  end;

  DIB1 := TN_DIBObj.Create( 10*1000, 250, pf32bit, 0 );
  Ptr1 := DIB1.PRasterBytes;
  N_i2 := Windows.VirtualQuery( Ptr1, MemInfo, SizeOf(MemInfo) );
  Buf.Add( MemFlags( MemInfo ) );

  SetLength( BA1, 1024*1024 );

  DIB1.Free;
  N_i2 := Windows.VirtualQuery( Ptr1, MemInfo, SizeOf(MemInfo) );
  Buf.Add( MemFlags( MemInfo ) );

  Ptr1 := @BA1[0];
  N_i2 := Windows.VirtualQuery( Ptr1, MemInfo, SizeOf(MemInfo) );
  Buf.Add( MemFlags( MemInfo ) );
  SetLength( BA1, 0 );

  N_i2 := Windows.VirtualQuery( Ptr1, MemInfo, SizeOf(MemInfo) );
  Buf.Add( MemFlags( MemInfo ) );

  OCanv := TN_OCanvas.Create();
  OCanv.SetCurCRectSize( 400*1024, 250, pf32bit );
  Ptr1 := OCanv.MPixPtr;
  N_i2 := Windows.VirtualQuery( Ptr1, MemInfo, SizeOf(MemInfo) );
  Buf.Add( MemFlags( MemInfo ) );
  OCanv.ClearSelfByColor( $FF );
  N_i2 := Windows.VirtualQuery( Ptr1, MemInfo, SizeOf(MemInfo) );
  Buf.Add( MemFlags( MemInfo ) );
  OCanv.Free;
  N_i2 := Windows.VirtualQuery( Ptr1, MemInfo, SizeOf(MemInfo) );
  Buf.Add( MemFlags( MemInfo ) );

  N_PlatformInfo( Buf, $FFF );
  goto Show;

  OCanv.SetCurCRectSize( 800*1024, 250, pf32bit );
  OCanv.ClearSelfByColor( $FF );
  N_PlatformInfo( Buf, $FFF );

  OCanv.SetCurCRectSize( 100*1024, 250, pf32bit );
  OCanv.ClearSelfByColor( $FF );
  OCanv.Free;
  goto Show;
  Exit;

  OCanv.SetCurCRectSize( 100*1024, 256, pf32bit );
  OCanv.ClearSelfByColor( $FF );
  OCanv.SetCurCRectSize( 40*1024, 256, pf32bit );
  OCanv.Free;
  Exit;

  Buf.Add( '' );
  Buf.Add( '****** DIB Size = 100e6 bytes' );
  Buf.Add( '' );

  DIB1 := TN_DIBObj.Create( 100*1000, 250, pf32bit, 0 );
  N_PlatformInfo( Buf, $FFF );
  DIB2 := TN_DIBObj.Create( 100*1000, 250, pf32bit, 0 );
  N_PlatformInfo( Buf, $FFF );
  DIB1.Free;
  N_PlatformInfo( Buf, $FFF );
  DIB1 := TN_DIBObj.Create( 100*1000, 250, pf32bit, 0 );
  DIB1.Free;
  DIB2.Free;

  Buf.Add( '' );
  Buf.Add( '****** Array Size = 1e6 bytes' );
  ie6 := 1000000;
  Buf.Add( '' );

  Buf.Add( '' );
  Buf.Add( 'After Array1 allocated:' );
  SetLength( BA1, ie6 );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( '' );
  Buf.Add( 'After Array2 allocated:' );
  SetLength( BA2, ie6 );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( '' );
  Buf.Add( 'After Array1 freed:' );
  SetLength( BA1, 0 );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( '' );
  Buf.Add( 'After Array1 allocated:' );
  SetLength( BA1, ie6 );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( '' );
  Buf.Add( 'After Array1 freed:' );
  SetLength( BA1, 0 );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( '' );
  Buf.Add( 'After Array2 freed:' );
  SetLength( BA2, 0 );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( '' );
  Buf.Add( '****** Array Size = 100e6 bytes' );
  Buf.Add( '' );

  Buf.Add( 'After Array1 of allocated:' );
  SetLength( BA1, 100*ie6 );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( '' );
  Buf.Add( 'After Array2 allocated:' );
  SetLength( BA2, 100*ie6 );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( '' );
  Buf.Add( 'After Array1 freed:' );
  SetLength( BA1, 0 );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( '' );
  Buf.Add( 'After Array1 allocated:' );
  SetLength( BA1, 100*ie6 );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( '' );
  Buf.Add( 'After Array1 freed:' );
  SetLength( BA1, 0 );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( '' );
  Buf.Add( 'After Array2 freed:' );
  SetLength( BA2, 0 );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( '' );
  Buf.Add( '****** DIB Sections' );
  Buf.Add( '' );

  OCanv := TN_OCanvas.Create();
  Buf.Add( 'After OCanv created:' );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( 'After OCanv 1 MB DIB Section created:' );
  OCanv.SetCurCRectSize( 1000, 250, pf32bit );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( 'After OCanv 1 MB DIB Section created:' );
  OCanv.SetCurCRectSize( 1000, 250, pf32bit );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( 'After OCanv 1 MB DIB Section created:' );
  OCanv.SetCurCRectSize( 1000, 250, pf32bit );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( 'After OCanv 300 MB DIB Section created:' );
  OCanv.SetCurCRectSize( 300*1000, 250, pf32bit );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( 'After OCanv 300 MB DIB Section created:' );
  OCanv.SetCurCRectSize( 300*1000, 250, pf32bit );
  N_DelphiHeapInfo( Buf, $0C0 );

  Buf.Add( 'After OCanv 100 MB DIB Section created:' );
  OCanv.SetCurCRectSize( 100*1000, 250, pf32bit );
  N_DelphiHeapInfo( Buf, $0C0 );


  Buf.Add( 'After OCanv freed:' );
  OCanv.Free;
  N_DelphiHeapInfo( Buf, $0C0 );


  Show: //**************************************
  N_GetInfoForm().Show;
  N_InfoForm.Memo.Lines.AddStrings( Buf );
  Buf.Free;
end; // procedure N_TstMemAlloc1();

procedure N_TstMemAlloc2();
// Memory Allocation Test #2
var
  Buf: TStringList;
  TstArray1: TN_BArray;
  MemBlocks1, MemBlocks2: TN_FreeMemBlocks;
  Label Show;
begin
  Buf := TStringList.Create;
  Buf.Add( '  N_TstMemAlloc2' );
  Buf.Add( '' );
  N_DelphiHeapInfo( Buf, $FFF );

  Buf.Add( '' );
  N_WinMemFullInfo( Buf, 0 );

  N_CollectFreeMemBlocks( MemBlocks1 );
  N_FreeMemBlocksInfo( Buf, MemBlocks1, 0 );

  SetLength( TstArray1, 20*1024*1024 );

  N_CollectFreeMemBlocks( MemBlocks2 );
  N_FreeMemBlocksInfo( Buf, MemBlocks2, 0 );

  N_FreeMemBlocksDifInfo( Buf, MemBlocks1, MemBlocks2, 0 );

  TstArray1 := nil;

  N_CollectFreeMemBlocks( MemBlocks2 );
  N_FreeMemBlocksInfo( Buf, MemBlocks2, 0 );

  N_FreeMemBlocksDifInfo( Buf, MemBlocks1, MemBlocks2, 0 );


  Show: //**************************************
  N_GetInfoForm().Show;
  N_InfoForm.Memo.Lines.AddStrings( Buf );
  Buf.Free;
end; // procedure N_TstMemAlloc2();

procedure N_TstDIBCoords();
// DIB Coords Test
var
  BMP: TBitMap;
  RgnHandle: HRGN;
  DIB1, DIB2: TN_DIBObj;
begin
  BMP := TBitMap.Create;
  BMP.Width := 100;
  BMP.Height := 100;
  BMP.PixelFormat := pf32bit;
  BMP.Canvas.Brush.Color := $FFFFFF;
  BMP.Canvas.FillRect( Rect(0,0,100,100) );

  BMP.Canvas.Brush.Color := $FF;
  BMP.Canvas.FillRect( Rect(1,1,3,3) ); // red 2x2 rect, bottom right edges excluded!

  DIB1 := TN_DIBObj.Create( BMP );
  DIB1.DIBOCanv.SetBrushAttribs( $00AA00 );
  DIB1.DIBOCanv.DrawPixRect( Rect(5,1,10,5) );
  DIB1.DIBOCanv.SetBrushAttribs( $FFFF00 );
  DIB1.DIBOCanv.DrawPixRect( Rect(5,94,10,98) );

  DIB2 := TN_DIBObj.Create( DIB1, Rect(4,0,11,6), DIB1.DIBPixFmt, DIB1.DIBExPixFmt );
  DIB2.SaveToBMPFormat('C:\\aaTstDIBCoords2.bmp' );

  N_i := DIB2.DIBInfo.bmi.biHeight;
  DIB1.DIBOCanv.DrawPixDIB( DIB2, Rect(1,12,25,36), DIB2.DIBRect );
  DIB1.DIBOCanv.DrawPixDIB( DIB2, Rect(1,37,25,43), Rect(0,0,7,2) );
  DIB1.SaveToBMPFormat('C:\\aaTstDIBCoords1.bmp' );

  BMP.Free;
  DIB1.Free;
  DIB2.Free;
  Exit;

  BMP.Canvas.CopyRect( Rect(4,1,5,2), BMP.Canvas, Rect(1,1,2,2) ); // 1x1 red rect copied, bottom right edges excluded!

  N_DrawFilledRect( BMP.Canvas.Handle, Rect(7,4,8,5), $FF00 ); // green 2x2 rect, edges included
  N_CopyRect( BMP.Canvas.Handle, Point(3,0), BMP.Canvas.Handle, Rect(7,4,7,4) ); // 1x1 green rect copied

  N_DrawRectBorder( BMP.Canvas.Handle, Rect(1,4,5,9), $CFCF, 2 );
  N_DrawRectBorder( BMP.Canvas.Handle, Rect(1,11,5,16), $AFAF, 1 );

  RgnHandle := CreateRectRgn(12,4,13,5); // 1x1 image mask, bottom right edges excluded!
  SelectClipRgn( BMP.Canvas.Handle, RgnHandle );
  DeleteObject( RgnHandle );
  N_DrawFilledRect( BMP.Canvas.Handle, Rect(12,4,13,5), $CC00CC ); // fucsia 1x1 rect

  BMP.SaveToFile( 'C:\\aaTstDIBCoords1.bmp' );
end; // procedure N_TstDIBCoords

procedure N_TstConvMemToHex();
// N_ConvMemToHex Test
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  N_s := '123';
  N_ConvMemToHex( @N_s[1], Length(N_s), 0, SL );
  N_s := '012345678901234567890123456789';
  N_ConvMemToHex( @N_s[1], Length(N_s), 0, SL );
  N_s := '012345678901234567890123456789012345678901234567890123456789';
  N_s[2] := Char($0D);
  N_s[4] := Char($0A);
  N_s[6] := Char(0);
  N_s[8] := Char($09);
  N_ConvMemToHex( @N_s[1], Length(N_s), $1000, SL );

  N_IAdd( SL.Text );
  SL.Free;
end; // procedure N_TstConvMemToHex();

procedure N_TstAllSpeedTest1();
// Speed Tests set #1
begin
  N_Tst1FastTimer();
  N_CopyArrayTest1();
  N_ReallocArraySpeed1();
  N_TstSPLToBinSpeed();
end; // procedure N_TstAllSpeedTest1

procedure N_TstTimers();
// Test TN_CPUTimer1, TN_CPUTimer2
var
  i: integer;
begin
  N_T1.Start;
  N_DelayByLoop( 0.001 );
  N_T1.SS( '0.001 msec' );

  N_T1.Start;
  N_DelayByLoop( 0.010 );
  N_T1.SS( '0.010 msec' );

  N_T1.Start;
  N_DelayByLoop( 0.100 );
  N_T1.SS( '0.100 msec' );

  N_T1.Start;
  N_DelayByLoop( 1.0 );
  N_T1.SS( '1.000 msec' );

  N_T2.Clear( 1 );
//  N_T2.Items[0].TimerName := 'Same as T1';
  N_T2.Start( 0 );
  N_T1.Start;
  N_DelayByLoop( 10.0 );
  N_T2.Stop( 0 );
  N_T1.SS( '10.00 msec' );
  N_T2.Show( 1 );

  N_T2.Clear( 5 );
  N_T2.Start( 0 );
  N_T1.Start;
  for i := 1 to 10 do
  begin
    N_T2.Start( 1 );
    N_DelayByLoop( 0.1 );
    N_T2.Stop( 1 );

    N_T2.Start( 2 );
    N_DelayByLoop( 0.2 );
    N_T2.Stop( 2 );

    N_T2.Start2( 3 );
    // Zero delay
    N_T2.Stop( 3 );

    N_T2.Start( 4 );
    // Zero delay
    N_T2.Stop( 4 );
  end;
  N_T2.Stop( 0 );
  N_T1.SS( 'Whole: ' );
  N_T2.Show( 5 );
end; // procedure N_TstTimers();

procedure N_TstValProc();
// Test Val Procedure
var
  c, ResCode: integer;
  Str: string;
  PBuf: PChar;
begin
//  Direct3DCreate9(D3D_SDK_VERSION);

  Str := '002 ';
  PBuf := @Str[1];
  N_T1.Start;
  N_i := 0;
  c := 1;
  while True do
  begin
    if (PBuf^ = Char($020)) or (PBuf^ = Char($00)) then Break;
    N_i := c * N_i + Ord(PBuf^) - Ord(Char('0'));
    c := c * 10;
    Inc( PBuf );
  end;
  N_T1.SS( 'ipas    ' );

  Str := '002  240.279  102.4';
  PBuf := @Str[1];
  N_T1.Start;
  Val( PBuf, N_i, ResCode );
  Inc( PBuf, ResCode-1 );
  Val( PBuf, N_d, ResCode );
  Inc( PBuf, ResCode-1 );
  Val( PBuf, N_d, ResCode );
  N_T1.SS( 'i2d     ' );

  Str := '002  240.279  102.4' + StringOfChar( 'a', 1000 ) ;
  PBuf := @Str[1];
  N_T1.Start;
  Val( PBuf, N_i, ResCode );
  Inc( PBuf, ResCode-1 );
  Val( PBuf, N_d, ResCode );
  Inc( PBuf, ResCode-1 );
  Val( PBuf, N_d, ResCode );
  N_T1.SS( 'i2d*    ' );

  Str := '002  240.279  102.4' + StringOfChar( 'a', 100000 ) ;
  PBuf := @Str[1];
  N_T1.Start;
  Val( PBuf, N_i, ResCode );
  Inc( PBuf, ResCode-1 );
  Val( PBuf, N_d, ResCode );
  Inc( PBuf, ResCode-1 );
  Val( PBuf, N_d, ResCode );
  N_T1.SS( 'i2d***  ' );

  Str := '002  240.279  102.4';
  PBuf := @Str[5];
  N_T1.Start;
  Val( PBuf, N_d, ResCode );
  N_T1.SS( 'd6 error' );

  Str := '002  240.279  102.4';
  PBuf := @Str[1];
  N_T1.Start;
  Val( PBuf, N_i, ResCode );
  N_T1.SS( 'Int3a   ' );

  Str := '002 ';
  PBuf := @Str[1];
  N_T1.Start;
  Val( PBuf, N_i, ResCode );
  N_T1.SS( 'Int3b   ' );

  N_T1.Start;
  N_T1.SS( 'Empty   ' );

  Str := '002  240.279  102.4';
  PBuf := @Str[3];
  N_T1.Start;
  Val( PBuf, N_i, ResCode );
  N_T1.SS( 'Int1    ' );

  N_T1.Start;
  N_T1.SS( 'Empty   ' );

  Str := '002  240.279  102.4';
  PBuf := @Str[5];
  N_T1.Start;
  Val( PBuf, N_d, ResCode );
  N_T1.SS( 'd6 error' );

  Str := '002  240.279  102.4';
  PBuf := @Str[15];
  N_T1.Start;
  Val( PBuf, N_d, ResCode );
  N_T1.SS( 'd4 OK   ' );

  Str := '123456789 ';
  PBuf := @Str[1];
  N_T1.Start;
  Val( PBuf, N_i, ResCode );
  N_T1.SS( 'Int9e   ' );

  Str := '123456789';
  PBuf := @Str[1];
  N_T1.Start;
  Val( PBuf, N_i, ResCode );
  N_T1.SS( 'Int9OK  ' );

end; // procedure N_TstValProc();

procedure N_TstCheckDLLFunc();
// Check if DLLName dll has DLLFunc function
var
  ResultOK: LongBool;
  HMem, DLLHandle: THandle;
  ProcOrFunc: TN_Proc;
  DLLName: String;
  DLLEntryName, FileName: AnsiString;
//  WrkFunc: TN_IntFuncIntPAChar;
begin
  DLLName      := 'Proj_CMSUtilsLib.dll';
  DLLEntryName := 'CMSCDIBToFile';
//  DLLName      := 'C:\CMSClient.dll';
//  DLLEntryName := 'CMSCopyMovePatSlides';
//  DLLEntryName := 'CMSStartServer';

  DLLHandle := LoadLibrary( PChar(DLLName) );
  ProcOrFunc := GetProcAddress( DLLHandle, PAnsiChar(DLLEntryName) );
  if not Assigned( ProcOrFunc ) then
  begin
    N_i := 1;
  end;

//  WrkFunc := TN_IntFuncIntPAChar(ProcOrFunc);
  FileName := 'C:\AATmpp.bmp';

  ResultOK := Windows.OpenClipboard( 0 );
  Assert( ResultOK, 'OpenClipboard Error' );

  HMem := Windows.GetClipboardData( CF_DIB );
  Assert( HMem <> 0, 'GetClipboardData (CF_DIB) Error' );

//  N_i := WrkFunc( HMem, @FileName[1] );
//  N_i := CMSCDIBToFile( HMem, @FileName[1] );
  ResultOK := Windows.CloseClipboard();

  N_i := integer(ResultOK);
end; // procedure N_TstCheckDLLFunc

procedure N_TstDatime();
// Test Date Time functions
var
  i, j: integer;
  SystemTime: TSystemTime;
  FileTime: TFileTime;
begin
  N_T1.Start();

  GetLocalTime(SystemTime);
  N_T1.SSS( 'GetLocalTime1' );
  GetLocalTime(SystemTime);
  N_T1.SSS( 'GetLocalTime2' );
  GetLocalTime(SystemTime);
  N_T1.SSS( 'GetLocalTime3' );
  GetLocalTime(SystemTime);
  N_T1.SSS( 'GetLocalTime4' );

  GetSystemTime(SystemTime);
  N_T1.SSS( 'GetSystemTime1' );
  GetSystemTime(SystemTime);
  N_T1.SSS( 'GetSystemTime2' );
  GetSystemTime(SystemTime);
  N_T1.SSS( 'GetSystemTime3' );
  GetSystemTime(SystemTime);
  N_T1.SSS( 'GetSystemTime4' );

  GetSystemTimeAsFileTime(FileTime);
  N_T1.SSS( 'GetSystemTimeAsFileTime1' );
  GetSystemTimeAsFileTime(FileTime);
  N_T1.SSS( 'GetSystemTimeAsFileTime2' );
  GetSystemTimeAsFileTime(FileTime);
  N_T1.SSS( 'GetSystemTimeAsFileTime3' );
  GetSystemTimeAsFileTime(FileTime);
  N_T1.SSS( 'GetSystemTimeAsFileTime4' );

  N_d := Now();
  N_T1.SSS( 'Now1' );

  N_d := Now();
  N_T1.SSS( 'Now2' );

  N_d := Now();
  N_T1.SSS( 'Now3' );

  N_d := Date() + Time();
  N_T1.SSS( 'Date+Time' );

  N_s := K_DateTimeToStr( Date() + Time() );
  N_T1.SSS( 'K_DateTimeToStr 1(def) ' + N_s );

  N_s := K_DateTimeToStr( Date() + Time(), 'hh:nn:ss' );
  N_T1.SSS( 'K_DateTimeToStr 2(hns)' + N_s );

  N_s := K_DateTimeToStr( Date() + Time(), 'hh:nn:ss.zz' );
  N_T1.SSS( 'K_DateTimeToStr 2(hnsz)' + N_s );

  GetLocalTime(SystemTime);
  with SystemTime do
    N_s := Format( '%d.%d.%d-%.2d.%.2d.%.2d.%.3d', [wYear,wMonth,wDay, wHour,wMinute,wSecond,wMilliseconds] );
  N_T1.SSS( 'GetLocalTime Fmt 1' );

  GetLocalTime(SystemTime);
  with SystemTime do
    N_s := Format( '*.%d.%d-%.2d.%.2d.%.2d.%.3d', [wYear,wMonth,wDay, wHour,wMinute,wSecond,wMilliseconds] );
  N_T1.SSS( 'GetLocalTime Fmt 2' );

  GetLocalTime(SystemTime);
  with SystemTime do
    N_s := Format( '%.2d.%.2d.%.2d.%.3d', [wHour,wMinute,wSecond,wMilliseconds] );
  N_T1.SSS( 'GetLocalTime Fmt 3' );

  GetLocalTime(SystemTime);
  with SystemTime do
    N_s := Format( '%.2d.%.2d.%.2d.%.3d', [wHour,wMinute,wSecond,wMilliseconds] );
  N_T1.SSS( 'GetLocalTime Fmt 4' );

  N_IAdd( '' );

  N_Dump1Str( '1' );
  N_T1.SSS( 'Dump1Str 1' );

  N_Dump1Str( '2' );
  N_T1.SSS( 'Dump1Str 2' );

  N_Dump1Str( '3' );
  N_T1.SSS( 'Dump1Str 3' );

  N_Dump1Str( '4' );
  N_T1.SSS( 'Dump1Str 4' );

  N_Dump2Str( '1' );
  N_T1.SSS( 'Dump2Str 1' );

  N_Dump2Str( '2' );
  N_T1.SSS( 'Dump2Str 2' );

  N_IAdd( '' );

  for i := 1 to 3 do
  begin
    for j := 1 to 5000 do
      GetLocalTime(SystemTime);

    with SystemTime do
      N_T1.SSS( Format( 'GetLocalTime 5K %.2d - %d.%d', [i,wSecond,wMilliseconds] ));
  end;

end; // procedure N_TstDatimeFormat

procedure N_TstPChars();
// Test PChars
var
  PC1, PC2: PChar;
  PWC1, PWC2: PWideChar;
  S1: String;
  WS1: WideString;
begin
  S1 := 'abcd';
  PC1 := @S1[1];
  PC2 := @S1[2];
  N_i1 := integer(PC1)-integer(PC2);
  N_i2 := integer(PC1-PC2);

  WS1 := 'abcd';
  PWC1 := @WS1[1];
  PWC2 := @WS1[2];
  N_i1 := integer(PWC1)-integer(PWC2);
  N_i2 := integer(PWC1-PWC2);

end; // procedure N_TstPChars();

procedure N_TstCodePages1();
// Test Code Pages
var
  AnsiCP, OEMCP: UINT;
  S1, S2, S3, S4, S5: string;
  WS1, WS2, WS3, WS4, WS5: WideString;
  AS1: AnsiString;
begin
  N_Dump1Str( '' );
  AS1 := 'Бюя';
  N_Dump1Str( String('Test Code Pages ' + AS1) );
  AnsiCP := GetACP();
  OEMCP  := GetOEMCP();
  N_Dump1Str( Format ( 'AnsiCP=%d, OEMCP=%d', [AnsiCP, OEMCP] ) );

  if SizeOf(Char) = 1 then // Delphi 7
  begin
//    N_i := UserDefaultCodePage;
    WS1 := WideString(AS1);
    N_Dump1Str( Format ( 'WS=%s (%4x %4x %4x), AS=(%2x %2x %2x)',
                                [WS1,integer(WS1[1]),integer(WS1[2]),integer(WS1[3]),
                                   integer(AS1[1]),integer(AS1[2]),integer(AS1[3])] ) );
    SetLength( WS2, 5 ); SetLength( WS3, 5 ); SetLength( WS4, 5 ); SetLength( WS5, 5 );
    N_s := S1; N_s := S2; N_s := S3; N_s := S4; N_s := S5;

    N_i := MultiByteToWideChar( CP_ACP, 0, @AS1[1], Length(AS1), PWideChar(@WS2[1]), Length(WS2) );
    N_Dump1Str( Format ( 'CP_ACP %d %s (%4x %4x %4x)', [N_i,WS2,integer(WS2[1]),integer(WS2[2]),integer(WS2[3])] ) );

    N_i := MultiByteToWideChar( AnsiCP, 0, @AS1[1], Length(AS1), PWideChar(@WS3[1]), Length(WS3) );
    N_Dump1Str( Format ( 'AnsiCP %d %s (%4x %4x %4x)', [N_i,WS3,integer(WS3[1]),integer(WS3[2]),integer(WS3[3])] ) );

    N_i := MultiByteToWideChar( CP_OEMCP, 0, @AS1[1], Length(AS1), PWideChar(@WS4[1]), Length(WS4) );
    N_Dump1Str( Format ( 'CP_OEMCP %d %s (%4x %4x %4x)', [N_i,S4,integer(WS4[1]),integer(WS4[2]),integer(WS4[3])] ) );

    N_i := MultiByteToWideChar( OEMCP, 0, @AS1[1], Length(AS1), PWideChar(@WS5[1]), Length(WS5) );
    N_Dump1Str( Format ( 'OEMCP %d %s (%4x %4x %4x)', [N_i,WS5,integer(WS5[1]),integer(WS5[2]),integer(WS5[3])] ) );
  end else // Dewlphi 2010
  begin
    N_Dump1Str( 'String()' );
//    SetMultiByteConversionCodePage( 1251 );
    S1 := String(AS1);
//    S1 := String(AS1);
    N_Dump1Str( Format ( 'US=%s (%4x %4x %4x), AS=(%2x %2x %2x)',
                                [S1,integer(S1[1]),integer(S1[2]),integer(S1[3]),
                                   integer(AS1[1]),integer(AS1[2]),integer(AS1[3])] ) );
    SetLength( S2, 5 ); SetLength( S3, 5 ); SetLength( S4, 5 ); SetLength( S5, 5 );
    N_s := WS1; N_s := WS2; N_s := WS3; N_s := WS4; N_s := WS5;

    AnsiCP := GetACP();
    OEMCP  := GetOEMCP();
    N_Dump1Str( Format ( 'AnsiCP=%d, OEMCP=%d', [AnsiCP, OEMCP] ) );

    N_i := MultiByteToWideChar( CP_ACP, 0, @AS1[1], Length(AS1), PWideChar(@S2[1]), Length(S2) );
    N_Dump1Str( Format ( 'CP_ACP %d %s (%4x %4x %4x)', [N_i,S2,integer(S2[1]),integer(S2[2]),integer(S2[3])] ) );

    N_i := MultiByteToWideChar( AnsiCP, 0, @AS1[1], Length(AS1), PWideChar(@S3[1]), Length(S3) );
    N_Dump1Str( Format ( 'AnsiCP %d %s (%4x %4x %4x)', [N_i,S3,integer(S3[1]),integer(S3[2]),integer(S3[3])] ) );

    N_i := MultiByteToWideChar( CP_OEMCP, 0, @AS1[1], Length(AS1), PWideChar(@S2[1]), Length(S2) );
    N_Dump1Str( Format ( 'CP_OEMCP %d %s (%4x %4x %4x)', [N_i,S2,integer(S2[1]),integer(S2[2]),integer(S2[3])] ) );

    N_i := MultiByteToWideChar( OEMCP, 0, @AS1[1], Length(AS1), PWideChar(@S3[1]), Length(S3) );
    N_Dump1Str( Format ( 'OEMCP %d %s (%4x %4x %4x)', [N_i,S3,integer(S3[1]),integer(S3[2]),integer(S3[3])] ) );
  end;

end; // procedure N_TstCodePages1();

procedure N_TstStrMatrSorting();
// Test StrMatr Sorting
var
  BaseDir: string;
  SMatr1, SMatr2: TN_ASArray;
  CompFuncsObj: TN_CompFuncsObj;
  PtrsToSMatrRows: TN_PArray;
begin
  SetLength( SMatr1, 5 ); // 5 Rows

  SetLength( SMatr1[0], 3 ); // Row=0, 3 Columns
  SMatr1[0][0] := '3';
  SMatr1[0][1] := '10';
  SMatr1[0][2] := '3 10';

  SetLength( SMatr1[1], 3 ); // Row=1
  SMatr1[1][0] := '3';
  SMatr1[1][1] := '21';
  SMatr1[1][2] := '3 21';

  SetLength( SMatr1[2], 3 ); // Row=2
  SMatr1[2][0] := '2';
  SMatr1[2][1] := '20';
  SMatr1[2][2] := '2 20';

  SetLength( SMatr1[3], 3 ); // Row=3
  SMatr1[3][0] := '1';
  SMatr1[3][1] := '30';
  SMatr1[3][2] := '1 30';

  SetLength( SMatr1[4], 3 ); // Row=4
  SMatr1[4][0] := '2';
  SMatr1[4][1] := '31';
  SMatr1[4][2] := '2 31';

  BaseDir := 'C:\Delphi_prj\1C2\NIVC_Bibl\';
  N_SaveSMatrToFile2( SMatr1, BaseDir + 'SMatr1.csv', smfCSV );

  CompFuncsObj := TN_CompFuncsObj.Create;
  CompFuncsObj.DescOrder := False;
  SetLength( CompFuncsObj.CFOIArray, 2 );
  CompFuncsObj.CFOIArray[0] := 1;
  CompFuncsObj.CFOIArray[1] := 0;

  PtrsToSMatrRows := N_GetPtrsArrayToElems( @SMatr1[0], 5, SizeOf(Pointer) );
  N_CreateStrMatrFromPointers( SMatr2, PtrsToSMatrRows );
  N_SaveSMatrToFile2( SMatr2, BaseDir + 'SMatr2a.csv', smfCSV );

  N_SortPointers( PtrsToSMatrRows, CompFuncsObj.CompSArray );
  N_CreateStrMatrFromPointers( SMatr2, PtrsToSMatrRows );

  N_SaveSMatrToFile2( SMatr2, BaseDir + 'SMatr2b.csv', smfCSV );
  CompFuncsObj.Free;
end; // procedure N_TstStrMatrSorting();

procedure N_TstConvRGBToGray();
// Convert one color chanel (R, G or B) to pf8bit BMP
var
  i, ix, iy, SrcPixColor, DstPixValue: integer;
  SrcFName, DstFName: string;
  SrcDIB, DstDIB: TN_DIBObj;
begin
  SrcFName := '..\TestData\Color.bmp';
  DstFName := '..\TestData\Color_2.bmp';

  SrcDIB := TN_DIBObj.Create( SrcFName );

  DstDIB := TN_DIBObj.Create( SrcDIB.DIBSize.X, SrcDIB.DIBSize.Y, pf8bit );

  for iy := 0 to SrcDIB.DIBSize.Y-1 do
  for ix := 0 to SrcDIB.DIBSize.X-1 do
  begin
    SrcPixColor := SrcDIB.GetPixColor( Point(ix,iy) );
//    DstPixValue := SrcPixColor shr 16; // Red component in BMP
    DstPixValue := SrcPixColor and $0FF; // Blue component in BMP
    if (ix=10) and(iy=10) then
      n_I := 1;
    if DstPixValue = 128 then
      n_I := 1;
    if (DstPixValue >= 100) and (DstPixValue < 255) then DstPixValue := DstPixValue - 68;
    DstDIB.SetPixValue( Point(ix,iy), DstPixValue );
  end;

  //***** Dst Pixels are OK, prepare Dst Palette

  for i := 0 to 255 do
  with DstDIB.DIBInfo do
  begin
    if i <=63 then
      PalEntries[i] := (i*4) + (i*4) shl 8 + (i*4) shl 16
    else if i = 255 then
      PalEntries[i] := $FFFFFF
    else
      PalEntries[i] := $CCCC00 + (i*4);
  end; // for i := 0 to 254 do

  SrcDIB.Free;

  DstDIB.SaveToBMPFormat( DstFName );
  DstDIB.Free;
end; // procedure N_TstConvRGBToGray();

procedure N_TstShowShapeInfo();
// Test
//var
//  i: integer;
begin
//  N_GetImportForm( nil ).ShowModal();
end; // procedure N_TstShowShapeInfo();

procedure N_TstWinGDI_1();
// Test Windows GDI functions #1
var
  BMP: TBitMap;
  BMPHDC: HDC;
begin
  BMP := TBitMap.Create;
  BMP.Width := 300;
  BMP.Height := 300;
  BMP.PixelFormat := pf32bit;
  BMPHDC := BMP.Canvas.Handle;

  N_DrawFilledRect( BMPHDC, Rect(50,100,150,200), $CC00CC ); // fucsia 1x1 rect



  BMP.SaveToFile( 'C:\\aaTstWinGDI_1.bmp' );
end; // procedure N_TstWinGDI_1

procedure N_TstOCanvDraw_1();
// Test OCanv Drawing  #1 Font Smoothing
var
  DIB: TN_DIBObj;
  FilesRoot: string;
begin
  FilesRoot := 'C:\Delphi_prj\DTmp\!CMS_OutFiles\';
  DIB := TN_DIBObj.Create( 2000, 2000, pf24bit, 0 );
  with DIB.DIBOCanv do
  begin
    SetBrushAttribs( N_ClLtGray );
    DrawPixRect( DIB.DIBRect );

    N_SetFontSmoothing( false );
    N_DebSetNFont( DIB.DIBOCanv, 900, 1, 45 );
    DIB.DIBOCanv.SetFontAttribs( N_ClBlack );
    DIB.DIBOCanv.DrawPixString( Point(-250,1250), 'F' );

    N_SetFontSmoothing( true );
    DIB.DIBOCanv.SetFontAttribs( N_ClDkRed );
    DIB.DIBOCanv.DrawPixString( Point(250,1250), 'T' );
  end; // with DIB.DIBOCanv do

  DIB.SaveToBMPFormat( FilesRoot + 'TstOCanvDraw_1.bmp' );
  DIB.Free;
end; // procedure N_TstOCanvDraw_1

procedure N_TstOCanvDraw_2();
// Test OCanv Drawing  #2 Decorative Font for Rus FOM Map
var
  DIB: TN_DIBObj;
  FilesRoot: string;
begin
  N_i := SizeOf(TN_CTransfType);

  FilesRoot := 'C:\Delphi_prj\DTmp\!CMS_OutFiles\';
  DIB := TN_DIBObj.Create( 400, 400, pf24bit, 0 );
  with DIB.DIBOCanv do
  begin
    SetBrushAttribs( N_ClLtGray );
    DrawPixRect( DIB.DIBRect );

    N_SetFontSmoothing( false );

    N_DebSetNFont( DIB.DIBOCanv, 50, 2, 30 );
    DIB.DIBOCanv.SetFontAttribs( N_ClBlack );
    DIB.DIBOCanv.DrawPixString( Point(10,100), 'Demo' );

    Windows.BeginPath( HMDC );
    DIB.DIBOCanv.DrawPixString( Point(10,200), 'Demo' );
    Windows.EndPath( HMDC );

    SetPenAttribs( N_ClGreen, 0.1 );
    StrokePath( HMDC );

    SetPenAttribs( N_ClBlack );
//    DIB.DIBOCanv.DrawPixString( Point(10,200), 'Demo' );
  end; // with DIB.DIBOCanv do

  DIB.SaveToBMPFormat( FilesRoot + 'TstOCanvDraw_2.bmp' );
  DIB.Free;
end; // procedure N_TstOCanvDraw_2

procedure N_TstHexToInt();
// Test N_AnyHexToInt function
begin
  N_i := N_AnyHexToInt( '' );
  N_i := N_AnyHexToInt( 'A' );
  N_i := N_AnyHexToInt( 'M' );
  N_i := N_AnyHexToInt( '$a' );
  N_i := N_AnyHexToInt( ' 0xF' );
  N_i := N_AnyHexToInt( 'FFQ' );
  N_i := N_AnyHexToInt( '0xFQ' );
  N_i := N_AnyHexToInt( '0xQF' );
  N_i := N_AnyHexToInt( '$Fq' );
  N_i := N_AnyHexToInt( '$qF' );
end; // procedure N_TstHexToInt();

procedure N_TstBrighHist1();
// Test BrighHist related data
var
  BHVals: TN_IArray;
  DIB: TN_DIBObj;

  procedure ProcessOneFile( AFName: string ); // local
  begin
    N_SL.Add( AFName );
    DIB := TN_DIBObj.Create( AFName );
    if DIB = nil then Exit;
    DIB.CalcBrighHistNData( BHVals );
    N_BrighHistToText( BHVals, N_SL );
  end; // procedure ProcessOneFile( AFName: string ); // local

begin
  N_SL.Clear;

  ProcessOneFile( K_ExpandFileName( '(#OutFiles#)original_1.bmp' ) );
  ProcessOneFile( K_ExpandFileName( '(#OutFiles#)adjusted_1.bmp' ) );
  ProcessOneFile( K_ExpandFileName( '(#OutFiles#)original_2.bmp' ) );
  ProcessOneFile( K_ExpandFileName( '(#OutFiles#)adjusted_2.bmp' ) );
  ProcessOneFile( K_ExpandFileName( '(#OutFiles#)original_3.bmp' ) );
  ProcessOneFile( K_ExpandFileName( '(#OutFiles#)adjusted_3.bmp' ) );
  ProcessOneFile( K_ExpandFileName( '(#OutFiles#)original_4.bmp' ) );
  ProcessOneFile( K_ExpandFileName( '(#OutFiles#)adjusted_4.bmp' ) );

  N_SL.SaveToFile(  K_ExpandFileName( '(#OutFiles#)HistValues.txt' ) );
end; // procedure N_TstBrighHist1();

procedure N_TstMaxFreeMem();
// Dump Max Free memory,  You should skip all exceptions occured
var
  MaxFree: integer;
begin
  MaxFree := K_FreeSpaceSearchMax( 1300000000, K_FreeSpaceBufCheck );
  N_Dump1Str( format( 'MemFreeSpace >> Maximal Buf Free Space in MB= %n', [1.0*MaxFree/1024/1024] ) );
  MaxFree := K_FreeSpaceSearchMax( 1300000000, N_CheckDIBFreeSpace );
  N_Dump1Str( format( 'MemFreeSpace >> Maximal DIB Free Space in MB= %n', [1.0*MaxFree/1024/1024] ) );
  N_Dump1Str( '' );

  MaxFree := K_FreeSpaceSearchMax( 1300000000, K_FreeSpaceBufCheck );
  N_Dump1Str( format( 'MemFreeSpace >> Maximal Buf Free Space in MB= %n', [1.0*MaxFree/1024/1024] ) );
  MaxFree := K_FreeSpaceSearchMax( 1300000000, N_CheckDIBFreeSpace );
  N_Dump1Str( format( 'MemFreeSpace >> Maximal DIB Free Space in MB= %n', [1.0*MaxFree/1024/1024] ) );
  N_Dump1Str( '' );

  SetLength( N_BA, 300000000 );
  N_Dump1Str( 'SetLength( N_BA, 500000000 );' );

  MaxFree := K_FreeSpaceSearchMax( 1300000000, K_FreeSpaceBufCheck );
  N_Dump1Str( format( 'MemFreeSpace >> Maximal Buf Free Space in MB= %n', [1.0*MaxFree/1024/1024] ) );
  MaxFree := K_FreeSpaceSearchMax( 1300000000, N_CheckDIBFreeSpace );
  N_Dump1Str( format( 'MemFreeSpace >> Maximal DIB Free Space in MB= %n', [1.0*MaxFree/1024/1024] ) );
  N_Dump1Str( '' );

  N_DIB := TN_DIBObj.Create( 300000, 1000, pf8bit );
  N_Dump1Str( 'TN_DIBObj.Create( 300000, 1000, pf8bit );' );

  MaxFree := K_FreeSpaceSearchMax( 1300000000, K_FreeSpaceBufCheck );
  N_Dump1Str( format( 'MemFreeSpace >> Maximal Buf Free Space in MB= %n', [1.0*MaxFree/1024/1024] ) );
  MaxFree := K_FreeSpaceSearchMax( 1300000000, N_CheckDIBFreeSpace );
  N_Dump1Str( format( 'MemFreeSpace >> Maximal DIB Free Space in MB= %n', [1.0*MaxFree/1024/1024] ) );

end; // procedure N_TstMaxFreeMem();

procedure N_TstDIBToTXT();
// Test LoadFromBMPFormat and DIBSelfToTextFile TN_DIBObj methods
var
  DIB1: TN_DIBObj;
  Path: String;

  procedure TestOneFile( AFName: String ); // local
  // test one given bmp file
  var
    PixColor, PixValue, PixGrayValue: integer;
    TmpDIB: TN_DIBObj;
    TxtFName: String;
  begin
    TmpDIB := TN_DIBObj.Create;
    TmpDIB.LoadFromFile( AFName );
    TxtFName := AFName + '.txt';
//    TmpDIB.DIBSelfToTextFile( TxtFName, TxtFName, TmpDIB.DIBRect, 0 );
    TmpDIB.DIBSelfToTextFile( TxtFName, TxtFName, Rect( 0, 0, 2, 2 ), 0 );

    PixColor := TmpDIB.GetPixColor( Point( 1, 0 ) ); // X=1, Y=0
    PixValue := TmpDIB.GetPixValue( Point( 1, 0 ) ); // X=1, Y=0
    PixGrayValue := TmpDIB.GetPixGrayValue( Point( 1, 0 ) ); // X=1, Y=0

    N_s := Format( 'PixColor=%6x, PixValue=%d, PixGrayValue=%d',
                    [PixColor, PixValue, PixGrayValue] );
    N_AddStrToFile2( AnsiString(N_s), AnsiString(TxtFName) );

    TmpDIB.Free;
  end; // procedure TestOneFile( AFName: String ); // local

begin
  Path := K_ExpandFileName( '(#OutFiles#)2x3_Files\' );

  TestOneFile( Path + '2x3Color24bitUpDown.bmp' );
  TestOneFile( Path + '2x3Color8bit.bmp' );
  TestOneFile( Path + '2x3Color24bit.bmp' );
  Exit;

  DIB1 := TN_DIBObj.Create;
  DIB1.LoadFromFile( Path + '2x3Color24bitUpDown.bmp' );
  DIB1.DIBInfo.bmi.biHeight := -DIB1.DIBInfo.bmi.biHeight;
//  DIB1.SaveToBMPFormat( Path + '2x3Color24bitUpDown.bmp' );
  DIB1.Free;

end; // procedure N_TstHexToInt();

procedure N_TstAllocMemTime();
// Test Memory (Arrays and DIBSEctions) Allocation Time
var
  BlockSize: integer;
  HMem: THandle;
begin
  BlockSize := 120*1024*1024;

  N_T1.Start();
  K_FreeSpaceBufCheck( BlockSize );
  N_T1.SSS( ' 120 MB Buf * 1 ' ); // 0.1 sec

  N_T1.Start();
  K_FreeSpaceBufCheck( BlockSize*2 );
  N_T1.SSS( ' 240 MB Buf * 1 ' );

  N_T1.Start();
  K_FreeSpaceBufCheck( BlockSize div 2 );
  N_T1.SSS( ' 60 MB Buf * 1 ' );

  N_T1.Start();
  K_FreeSpaceBufCheck( BlockSize );
  K_FreeSpaceBufCheck( BlockSize );
  N_T1.SSS( ' 120 MB Buf * 2 ' );

  N_T1.Start();
  K_FreeSpaceBufCheck( BlockSize );
  N_T1.SSS( ' 120 MB Buf * 1 ' );

  N_T1.Start();
  N_CheckDIBFreeSpace( BlockSize ); // 0.2 msec
  N_T1.SSS( ' 120 MB DIB * 1 ' );

  N_T1.Start();
  N_CheckDIBFreeSpace( BlockSize );
  N_CheckDIBFreeSpace( BlockSize );
  N_T1.SSS( ' 120 MB DIB * 2 ' );

  N_T1.Start();
  N_CheckDIBFreeSpace( BlockSize );
  N_T1.SSS( ' 120 MB DIB * 1 ' );

  N_T1.Start();
  HMem := Windows.GlobalAlloc( GMEM_MOVEABLE, BlockSize );
  N_p := Windows.GlobalLock( HMem );
  N_T1.SSS( ' 120 MB GlobalAlloc * 1 ' ); // 15 mcsec
  Windows.GlobalFree( HMem );

  N_T1.Start();
  HMem := Windows.GlobalAlloc( GMEM_MOVEABLE, BlockSize );
  N_p := Windows.GlobalLock( HMem );
  ZeroMemory( N_p, BlockSize );
  N_T1.SSS( ' 120 MB GlobalAlloc+Clear * 1 ' ); // 0.1 sec
  Windows.GlobalFree( HMem );

  N_T1.Start();
  HMem := Windows.GlobalAlloc( GMEM_MOVEABLE, BlockSize div 2 );
  N_p := Windows.GlobalLock( HMem );
  ZeroMemory( N_p, BlockSize div 2 );
  N_T1.SSS( ' 60 MB GlobalAlloc+Clear * 1 ' ); // 0
  Windows.GlobalFree( HMem );
{
  23> 15-17:45:01.718 1  120 MB Buf * 1  : 0.103 sec.
  24> 15-17:45:01.968 2  240 MB Buf * 1  : 0.243 sec.
  25> 15-17:45:02.031 3  60 MB Buf * 1  : 71.85 msec.
  26> 15-17:45:02.281 4  120 MB Buf * 2  : 0.246 sec.
  27> 15-17:45:02.406 5  120 MB Buf * 1  : 0.117 sec.
  28> 15-17:45:02.406 6  120 MB DIB * 1  : 0.231 msec.
  29> 15-17:45:02.406 7  120 MB DIB * 2  : 0.270 msec.
  30> 15-17:45:02.406 8  120 MB DIB * 1  : 0.116 msec.
  31> 15-17:45:02.406 9  120 MB GlobalAlloc * 1  : 13.27 mcsec.
  32> 15-17:45:02.515 10  120 MB GlobalAlloc+Clear * 1  : 0.103 sec.
  33> 15-17:45:02.562 11  60 MB GlobalAlloc+Clear * 1  : 46.48 msec.
}
end; // procedure N_TstAllocmemTime

procedure N_TestImageFile( AFileName: String );
// Analize given Image File
var
  MinHistInd, MaxHistInd: Integer;
  TxtFName: String;
  DIB1: TN_DIBObj;
  HistData: TN_IArray;
begin
  DIB1 := nil;
  N_LoadDIBFromFileByImLib( DIB1, AFileName );
  TxtFName := ChangeFileExt( AFileName, '.txt' );

  if DIB1 = nil then
  begin
    N_SaveStringToFile( AFileName, 'Error reading file ' + AFileName );
  end;

  DIB1.CalcBrighHistNData( HistData, nil, @MinHistInd, @MaxHistInd, nil, 16 );
  N_DumpIntegers( @HistData[0], 65535, $41, TxtFName );
  N_AddStrToFile2( AnsiString(Format( 'MinHistInd=%d, MaxHistInd=%d', [MinHistInd,MaxHistInd] )), AnsiString(TxtFName) );
end; // procedure N_TestImageFile

procedure N_TstScreenGrabber();
// Test
var
  ScreenRect: TRect;
  ScreenDIB: TN_DIBObj;
  ScreenHDC: HDC;
begin
  ScreenHDC := windows.GetDC( 0 ); // windows Desktop handle
  ScreenDIB := TN_DIBObj.Create( 1000, 1000, pf24bit );

  N_T1.Start;

  ScreenRect := Rect( 10, 10, 19, 19 );
  N_CopyRect( ScreenDIB.DIBOCanv.HMDC, Point(0,0), ScreenHDC, ScreenRect );
  N_T1.SSS( 'Get 10x10 a1' );
  ScreenRect := Rect( 10, 10, 19, 19 );
  N_CopyRect( ScreenDIB.DIBOCanv.HMDC, Point(0,0), ScreenHDC, ScreenRect );
  N_T1.SSS( 'Get 10x10 a2' );
  ScreenRect := Rect( 10, 10, 19, 19 );
  N_CopyRect( ScreenDIB.DIBOCanv.HMDC, Point(0,0), ScreenHDC, ScreenRect );
  N_T1.SSS( 'Get 10x10 a3' );


  ScreenRect := Rect( 10, 10, 109, 19 );
  N_CopyRect( ScreenDIB.DIBOCanv.HMDC, Point(0,0), ScreenHDC, ScreenRect );
  N_T1.SSS( 'Get 100x10 a' );
  ScreenRect := Rect( 10, 10, 109, 109 );
  N_CopyRect( ScreenDIB.DIBOCanv.HMDC, Point(0,0), ScreenHDC, ScreenRect );
  N_T1.SSS( 'Get 100x100 a' );

  ScreenRect := Rect( 10, 10, 19, 19 );
  N_CopyRect( ScreenDIB.DIBOCanv.HMDC, Point(0,0), ScreenHDC, ScreenRect );
  N_T1.SSS( 'Get 10x10 b' );
  ScreenRect := Rect( 10, 10, 109, 19 );
  N_CopyRect( ScreenDIB.DIBOCanv.HMDC, Point(0,0), ScreenHDC, ScreenRect );
  N_T1.SSS( 'Get 100x10 b' );
  ScreenRect := Rect( 10, 10, 109, 109 );
  N_CopyRect( ScreenDIB.DIBOCanv.HMDC, Point(0,0), ScreenHDC, ScreenRect );
  N_T1.SSS( 'Get 100x100 b' );

  ScreenDIB.Free;
end; // procedure N_TstScreenGrabber

procedure N_TstEnumResources();
// Dump Resources info
var
  Ofs: integer;
  ResFileName: string;
  ResHeader: TN_RESOURCEHEADER;
  FStream: TFileStream;

begin
  ResFileName := 'C:\\Proj_VRE.res';
  N_Dump1Str( '   *** Resources in ' + ResFileName );
  FStream := TFileStream.Create( ResFileName, fmOpenRead );


  N_i := SizeOf(ResHeader);
  FStream.Read( ResHeader, SizeOf(ResHeader) );
  Ofs := ResHeader.DataSize and $7FFFFFFC; // clear last two bits
  if Ofs <> ResHeader.DataSize then // not DWORD aligned
    Ofs := Ofs + 4;

  FStream.Seek( soFromCurrent, Ofs );
  FStream.Read( ResHeader, SizeOf(ResHeader) );

  FStream.Free;
end; // procedure N_TstEnumResources();

procedure N_TstXXX();
// Test
var
  i: integer;
begin
  i := 0;
  N_i := i;
end; // procedure N_TstXXX();

{
procedure SetMultiByteConversionCodePage(CodePage: Integer);
begin
  DefaultSystemCodePage := CodePage;
end;
C:\Program Files\Embarcadero\RAD Studio\7.0\source\Win32\rtl
}

end.

