unit N_TstC1;
// Tests, based upon TN_UDAction Component

interface
uses Windows, SysUtils, Classes, Graphics, Contnrs, Types,
     N_Types, N_Gra0, N_Gra1, N_Lib0, N_Lib2, N_Comp1, N_Rast1Fr;

type TN_Tst1RFA = class( TN_RFrameAction ) // Edit 3 Rects RFrame Action
  Itmp: integer;

  procedure SetActParams (); override;
  procedure Execute      (); override;
  procedure RedrawAction (); override;
end; // type TN_Tst1RFA = class( TN_RFrameAction )

procedure N_UDATestDummy1        ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestDummy2        ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestDummy3        ( APParams: TN_PCAction; AP1, AP2: Pointer );

procedure N_UDATestCreateFont1   ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestCreateFont2   ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestPatternBrush1 ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestWinRotateCoords1( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestCalcStrPixRect( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestLowLevelDraw1 ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestOneBezierSegm ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATest1DPWIFunc     ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestConvProcs1    ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestXYNLConvPWI   ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestTimers1       ( APParams: TN_PCAction; AP1, AP2: Pointer );

procedure N_UDATestWordDeb1      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestWordDeb2      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestWordDeb3      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestWordDeb4      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestWordDeb5      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestWordDeb6      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestWordDeb7      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestWordRunMacros ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestWordSpeedTests1( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestCreateWordDoc ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestCreateMVTADoc ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestShowFileAsText( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActionRWProcMem1     ( APParams: TN_PCAction; AP1, AP2: Pointer );

procedure N_UDATestMemTextFragms ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestStrPos        ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestValue2Str     ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestTmp1          ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestStringList    ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestPrepRoot      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestDrawUserRects ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestAddSearchGroup( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestPChar         ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestTWAIN1        ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestMapTools      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDATestScreenCapture ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDACreateActListBMP  ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDAConvActListBMP    ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDACreateGrayScaleBMP( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_UDACreateSharpTestBMP( APParams: TN_PCAction; AP1, AP2: Pointer );

procedure N_UDAConvPixelsToText  ( APParams: TN_PCAction; AP1, AP2: Pointer );

procedure N_UDATestXXX           ( APParams: TN_PCAction; AP1, AP2: Pointer );

implementation
uses math, Forms, Clipbrd, Variants, StrUtils, IniFiles, Controls, imglist, StdCtrls,
  K_CLib0, K_UDT1, K_Script1, K_Parse, K_UDT2, // K_CM0,
  N_Lib1, N_Gra2, N_Gra3, N_CompBase, N_CompCL, N_GCont, N_InfoF, N_2DFunc1,
  N_Comp3, N_ME1, N_BaseF, N_ClassRef, N_SGComp, N_UDat4, N_UDCMap,
  N_MapTools;

//****************  TN_Tst1RFA class methods  *****************

//************************************************* TN_Tst1RFA.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_Tst1RFA.SetActParams();
begin
  ActName := 'Tst1';

  inherited;
end; // procedure TN_Tst1RFA.SetActParams();

//****************************************************** TN_Tst1RFA.Execute ***
// Show Info about object
//
procedure TN_Tst1RFA.Execute();
var
  Str: string;
begin
  inherited;
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
  begin
    N_i := Length(SComps);
    N_s := SComps[0].SComp.ObjName;

    if SRType =  srtNone     then Exit;
    if CHType <> htMouseMove then Exit;
    if CurMLCObj = nil       then Exit;

    Str := Format( 'ObjName: %s, ItemInd=%d', [CurMLCObj.ObjName, ItemInd] );
    ShowString( 1, Str );
  end; // with ActGroup, ActGroup.RFrame do
end; // procedure TN_Tst1RFA.Execute

//************************************************* TN_Tst1RFA.RedrawAction ***
// Redraw Temporary Action objects
// (should be called from RFrame.RedrawAll )
//
procedure TN_Tst1RFA.RedrawAction();
begin
  with N_ActiveRFrame do
  begin

  end; // with N_ActiveRFrame do
end; // procedure TN_Tst1RFA.RedrawAction

procedure N_UDATestDummy1( APParams: TN_PCAction; AP1, AP2: Pointer );
// Dummy1 Test
//
// (for using in TN_UDAction under Action Name 'TestDummy1' )
begin
  with APParams^ do
  begin
    N_IAdd( 'N_UDATestDummy1' );
    N_IAdd( CAStr1 );
    N_IAdd( CAStr2 );
  end; // with APParams^ do
end; // procedure N_UDATestDummy1

procedure N_UDATestDummy2( APParams: TN_PCAction; AP1, AP2: Pointer );
// Dummy2 Test
//
// (for using in TN_UDAction under Action Name 'TestDummy2' )
begin
  with APParams^ do
  begin
    N_IAdd( 'N_UDATestDummy2' );
    N_T1a.Start();


    N_T1a.SS( 'TestDummy2' );
  end; // with APParams^ do
end; // procedure N_UDATestDummy2

procedure N_UDATestDummy3( APParams: TN_PCAction; AP1, AP2: Pointer );
// Dummy3 Test
//
// (for using in TN_UDAction under Action Name 'TestDummy3' )
begin
  with APParams^ do
  begin
    N_IAdd( '' );
    N_IAdd( 'N_UDATestDummy3' );
    N_T1a.Start();

//    for i := 0 to CEInt1-1 do
//      N_ActionProcs.IndexOfName( 'TestDummy2' );

    N_T1a.SS( 'TestDummy3a' );

//    N_T1a.Stop();
//    N_T1a.Show( 'TestDummy3b' );
  end; // with APParams^ do
end; // procedure N_UDATestDummy3

procedure N_UDATestCreateFont1( APParams: TN_PCAction; AP1, AP2: Pointer );
// TestCreateFont1
//
// (for using in TN_UDAction under Action Name 'TestCreateFont1' )
var
//  i: integer;
  PNFont1, PNFont2: TN_PNFont;
  HF: HFont;
  StrPosParams: TN_StrPosParams;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  with APParams^, UDActionComp do
  begin
    N_IAdd( '' );
    N_IAdd( 'N_UDATestCreateFont1' );

//    for i := 0 to CEInt1-1 do
//    N_T1a.Start();
//    N_T1a.SS( '...' );

    PNFont1 := N_GetPVArrayData( CAUDBase1 );
    PNFont2 := N_GetPVArrayData( CAUDBase2 );

    N_T1a.Start();
    N_CreateFontHandle( PNFont1, 1 );
    N_T1a.SS( 'CreateFont' );

    N_CreateFontHandle( PNFont2, 1 );
    HF := GetStockObject( SYSTEM_FONT );

    N_T1a.Start();
    SelectObject( NGCont.DstOCanv.HMDC, PNFont1^.NFHandle );
    N_T1a.SS( 'SelectObject' );

    FillChar( StrPosParams, Sizeof(StrPosParams), 0 );
    N_T1a.Start();
    NGCont.GDrawString( 'ab', FPoint( 10, 10), @StrPosParams );
    SelectObject( NGCont.DstOCanv.HMDC, PNFont2^.NFHandle );
    DeleteObject( PNFont1^.NFHandle );

    NGCont.GDrawString( 'ef', FPoint( 80, 10), @StrPosParams ); // ghijklmn
    SelectObject( NGCont.DstOCanv.HMDC, HF );
    DeleteObject( PNFont2^.NFHandle );

//    NGCont.GDrawString( 'cd', FPoint( 50, 10), @StrPosParams );

    N_T1a.SS( 'GDrawString' );


//    N_T1a.Stop();
//    N_T1a.Show( 'TestDummy3b' );
  end; // with APParams^ do
end; // procedure N_UDATestCreateFont1

procedure N_UDATestCreateFont2( APParams: TN_PCAction; AP1, AP2: Pointer );
// TestCreateFont2
//
// (for using in TN_UDAction under Action Name 'TestCreateFont1' )
var
  i, NumTimes: integer;
  PNFont: TN_PNFont;
  Fonts: TN_NFonts;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  with APParams^, UDActionComp do
  begin
    N_IAdd( '' );
    N_IAdd( 'N_UDATestCreateFont2' );

//    N_T1a.Start();
//    N_T1a.SS( '...' );

    PNFont := N_GetPVArrayData( CAUDBase1 );
    NumTimes := CAIRect.Left;
    SetLength( Fonts, NumTimes );

    N_T1a.Start();
    for i := 0 to NumTimes-1 do
    begin
//      move( PNFont^, Fonts[i], SizeOf(TN_NFont);
      Fonts[i] := PNFont^;
      Fonts[i].NFLLWHeight := Fonts[i].NFLLWHeight + (i mod 100);
//      N_CreateFontHandle( PNFont, 1 );
      N_CreateFontHandle( @Fonts[i], 1 );
//      N_u1 := PNFont^.NFHandle;
//      N_u2 := SelectObject( NGCont.DstOCanv.HMDC, PNFont^.NFHandle );
      N_u2 := SelectObject( NGCont.DstOCanv.HMDC, Fonts[i].NFHandle );
//      if i < 10 then N_IAdd( Format( 'h1=%x, h2=%x', [N_u1, N_u2] ) );
//      DeleteObject( PNFont^.NFHandle );
//      PNFont^.NFHandle := 0;
    end;
    N_T1a.SS( 'Create ' + IntToStr(NumTimes) + ' handles' );

  end; // with APParams^ do
end; // procedure N_UDATestCreateFont2

type TmpPackedDIB = packed record //
  bmi: TBitmapInfoHeader;
  Pixels: Array [0..8] of integer; // 3x3 32bits per pixel raster
end; //type TmpPackedDIB = packed record //

procedure N_UDATestPatternBrush1( APParams: TN_PCAction; AP1, AP2: Pointer );
// Pattern Brush Test #1
//
// (for using in TN_UDAction under Action Name 'PatternBrush1' )
var
  PackedDIB: TmpPackedDIB;
  UDPict: TN_UDPicture;
  LogBrush: TLogBrush;
  HBr1: HBrush;
  Rect1: TRect;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  with APParams^, UDActionComp.NGCont.DstOCanv do
  begin
    N_IAdd( '' );
    N_IAdd( 'N_UDATestPatternBrush1' );

    //***** Hatched Brush

    with LogBrush do
    begin
      lbStyle := BS_HATCHED;
      lbColor := $0000FF;
      lbHatch := HS_DIAGCROSS;
    end;
    HBr1 := Windows.CreateBrushIndirect( LogBrush );

    Rect1 := Rect( 10, 10, 100, 50 );
    Windows.FillRect( HMDC, Rect1, HBr1 );
    Windows.DeleteObject( HBr1 );

    //***** Brush from manualy created Packed DIB
    //     (Packed DIB is TBitmapInfoHeader followed by raster pixels)

    FillChar( PackedDIB, Sizeof(PackedDIB), 0 );
    with PackedDIB, PackedDIB.bmi do //
    begin
      biSize   := Sizeof(PackedDIB.bmi);
      biWidth  := 3;
      biHeight := 3;
      biPlanes := 1;
      biCompression := BI_RGB;
      biClrUsed := 0;
      biSizeImage := 36; // 4x3x3
      biBitCount := 32;

      Pixels[0] := $FFFFFF;
      Pixels[1] := $000000;
      Pixels[2] := $FFFF00; // yellow

      Pixels[3] := $0000FF; // blue
      Pixels[4] := $00FF00;
      Pixels[5] := $FF0000; // red

      Pixels[6] := $0000FF;
      Pixels[7] := $00FF00;
      Pixels[8] := $FF0000;
    end; // with PackedDIB, PackedDIB.bmi do //

    with LogBrush do
    begin
      lbStyle := BS_DIBPATTERNPT; // pointer to packed DIB
      lbColor := DIB_RGB_COLORS;
      lbHatch := LongInt(@PackedDIB);
    end;

    HBr1 := Windows.CreateBrushIndirect( LogBrush );

    Rect1 := Rect( 111, 11, 200, 50 );
    Windows.FillRect( HMDC, Rect1, HBr1 );
    Windows.DeleteObject( HBr1 );

    //***** Brush from UDPicture (not fully implemented)

    if CAUDBase1 is TN_UDPicture then
    begin
      UDPict := TN_UDPicture( CAUDBase1 );
      UDPict.LoadFromFile();

      with UDPict.PIDP()^.PictRaster do
      begin
        N_i := RWidth;
        N_i1 := PInteger(@RasterBA[0])^;
        N_i2 := PInteger(@RasterBA[4])^;

        with LogBrush do
        begin
          lbStyle := BS_HATCHED; // temporary UDPict is not used
          lbColor := $00FF00;
          lbHatch := HS_CROSS;
        end;
      end; // with UDPict.PIDP()^.PictRaster do

      HBr1 := Windows.CreateBrushIndirect( LogBrush );

      Rect1 := Rect( 10, 60, 100, 100 );
      Windows.FillRect( HMDC, Rect1, HBr1 );
      Windows.DeleteObject( HBr1 );
    end; // if CAUDBase1 is TN_UDPicture then

  end; // with APParams^ do
end; // procedure N_UDATestPatternBrush1

procedure N_UDATestWinRotateCoords1( APParams: TN_PCAction; AP1, AP2: Pointer );
// Rotate Coords using Windows Transformation Test #1
//
// (for using in TN_UDAction under Action Name 'WinRotateCoords1' )
var
  HBr1: HBrush;
  Rect1: TRect;
  UDActionComp: TN_UDAction;
  XForm: TXForm;
begin
  UDActionComp := TN_UDAction(AP1^);
  with APParams^, UDActionComp, UDActionComp.NGCont.DstOCanv do
  begin
    N_IAdd( '' );
    N_IAdd( 'N_UDATestWinRotateCoords1' );

    HBr1 := Windows.GetStockObject( GRAY_BRUSH );
    Rect1 := Rect( 10, 10, 100, 50 );
//x' = x * eM11 + y * eM21 + eDx,
//y' = x * eM12 + y * eM22 + eDy,

    with XForm do
    begin
      eM11 := 0;
      eM21 := 1;
      eM12 := -1;
      eM22 := 0;
      eDx := 100;
      eDy := 150;
    end;

    Windows.SetGraphicsMode( HMDC, GM_ADVANCED );
    if (CAFlags1 and $01) <> 0 then Windows.SetWorldTransform( HMDC, XForm );

    Windows.FillRect( HMDC, Rect1, HBr1 );
    NGCont.GDrawString( 'Txtat 20 60', FPoint( 20, 60), nil );
    SetPClipRect( Rect( 10, 10, CAIRect.Left, CAIRect.Right ) );


    Windows.ModifyWorldTransform( HMDC, XForm, MWT_IDENTITY );
    NGCont.GDrawString( 'Txtat 10 20', FPoint( 10, 20), nil );

//    Windows.DeleteObject( HBr1 );

  end; // with APParams^ do
end; // procedure N_UDATestWinRotateCoords1

procedure N_UDATestCalcStrPixRect( APParams: TN_PCAction; AP1, AP2: Pointer );
// OCanv.CalcStrPixRect method Test #1
//
// (for using in TN_UDAction under Action Name 'CalcStrPixRect' )
var
  StrFRect: TFRect;
  StrBP, BasePoint: TFPoint;
  StrPosParams: TN_StrPosParams;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  with APParams^, UDActionComp, UDActionComp.NGCont.DstOCanv do
  begin
    N_IAdd( '' );
    N_IAdd( 'N_UDATestCalcStrPixRect' );

    StrPosParams.SPPHotPoint := CAFRect.TopLeft;
    StrPosParams.SPPShift    := CAFRect.BottomRight; // FPoint( CADPoint1 );
    StrPosParams.SPPBLAngle  := CAIRect.Left;

    N_SetNFont( CAUDBase1, NGCont.DstOCanv, StrPosParams.SPPBLAngle );

    BasePoint := FPoint( 100, 100 );
    StrFRect := CalcStrPixRect( CAStr1, BasePoint, @StrPosParams, @StrBP );

    SetBrushAttribs( $CCCCCC );
    DrawPixFilledRect( IRect(StrFRect) );
    SetFontAttribs( $990000 );

    NGCont.GDrawString( CAStr1, BasePoint, @StrPosParams );

    StrPosParams := N_CentrDefStrPosParams;
    SetFontAttribs( $99FF99 );
    N_SetNFont( nil, NGCont.DstOCanv );
    NGCont.GDrawString( '*', BasePoint, @StrPosParams );

  end; // with APParams^ do
end; // procedure N_UDATestCalcStrPixRect

procedure N_UDATestLowLevelDraw1( APParams: TN_PCAction; AP1, AP2: Pointer );
// Low Level Draw Test #1 in Advanced and Compatible modes:
// Rect Coords, small Lines, ClipRect, Dashes
//
// Conclusions:
// - Lower Right pixel is excluded in:
//   - Windows.FillRect and Windows.SelectClipRgn in both Advanced and Compatible modes
//   - Windows.Rectangle and Windows.RoundRect only in Compatible mode
//
// (for using in TN_UDAction under Action Name 'LowLevelDraw1' )
var
  BaseY: integer;
  RectStr: string;
  UDActionComp: TN_UDAction;

  procedure DrawTestRect( AX1, AY1, AX2, AY2: integer );
  // Draw Rect with three nexted Rects with different borders color (Green, Black, Blue)
  begin
    with UDActionComp.NGCont.DstOCanv do
    begin
      SetBrushAttribs( $FF );
      SetPenAttribs( $00FF00, 1 );
      DrawPixRect( Rect( AX1, AY1, AX2, AY2 ) );
      SetPenAttribs( $000000, 1 );
      DrawPixRect( Rect( AX1+1, AY1+1, AX2-1, AY2-1 ) );
      SetPenAttribs( $FF0000, 1 );
      DrawPixRect( Rect( AX1+2, AY1+2, AX2-2, AY2-2 ) );
    end; // with UDActionComp.NGCont.DstOCanv do
  end; // procedure DrawTestRect - local

  procedure DrawFragm( AX, AY, ASX, ASY, ATestNum, AFillColor: integer );
  // Draw Envelope Rect and call procedure with given AProcNum
  var
    i: integer;
    Hbr: LongWord;
    Line: TN_IPArray;
  begin
    with APParams^, UDActionComp.NGCont, UDActionComp.NGCont.DstOCanv do
    begin
      SetPenAttribs( 0, 1 );
      SetBrushAttribs( AFillColor );
      Windows.Rectangle( HMDC, AX, AY, AX+ASX+ConOnePix, AY+ASY+ConOnePix );
      N_DebDrawString( DstOCanv, Point( AX+10, AY ), RectStr, 0, 10 );

      case ATestNum of

      0: begin //********************* Test variant #0
        //***** Windows native GDI functions: Rectangle, RoundRect, FillRect
        SetBrushAttribs( $FF );
        Windows.Rectangle( HMDC, AX+5,  AY+14, AX+8,  AY+17 ); // 4x4 rect
        Windows.RoundRect( HMDC, AX+15, AY+14, AX+18, AY+17, 0, 0 ); // 4x4 rect
        Hbr := GetCurrentObject( HMDC, OBJ_BRUSH );
        Windows.FillRect( HMDC, Rect( AX+25, AY+14, AX+28, AY+17 ), Hbr ); // 4x4 rect

        //***** OCanv functions
        DrawPixRect( Rect( AX+5, AY+20, AX+8, AY+23 ) );
        DrawPixRoundRect( Rect( AX+15, AY+20, AX+18, AY+23 ), Point(0,0), $FF, 0, 1 );
        DrawPixFilledRect( Rect( AX+25, AY+20, AX+28, AY+23 ) );

        //***** local TestRect function
        DrawTestRect( AX+31, AY+14, AX+40, AY+23 );

        //***** Small Lines
        SetLength( Line, 3 );
        Line[0] := Point( AX+45, AY+14 ); Line[1] := Point( AX+47, AY+14 );
        Windows.Polyline( HMDC, (@Line[0])^, 2 );
        Line[0] := Point( AX+45, AY+20 ); Line[1] := Point( AX+47, AY+20 );
        DrawPixPolyline( Line, 2 );

        //***** OCanv RoundRect with wide borders
        DrawPixRoundRect( Rect( AX+5,  AY+26, AX+14, AY+35 ), Point(0,0), $FF, 0, 1 ); // 10x10
        DrawPixRoundRect( Rect( AX+18, AY+26, AX+27, AY+35 ), Point(0,0), $FF, 0, 2 ); // 10x10
        DrawPixRoundRect( Rect( AX+31, AY+26, AX+40, AY+35 ), Point(0,0), $FF, 0, 3 ); // 10x10
        DrawPixRoundRect( Rect( AX+44, AY+26, AX+53, AY+35 ), Point(0,0), $FF, 0, 4 ); // 10x10
        DrawPixRoundRect( Rect( AX+57, AY+26, AX+66, AY+35 ), Point(0,0), $FF,-1, 0 ); // 10x10

        //***** SetPClipRect test
        for i := 0 to 3 do
        begin // i=0 - NoClip, i=1 - Clip by EnvRect, i=2 Clip by EnvRect-1, i=3 Clip by EnvRect-2
          if i >= 1 then
            SetPClipRect( Rect( AX+5+i*10+i-1, AY+38+i-1, AX+12+i*10-i+1, AY+45-i+1 ) );
          DrawTestRect( AX+5+i*10, AY+38, AX+12+i*10, AY+45 );
        end; // for i := 0 to 3 do
        RemovePClipRect();

        //***** N_CopyRect test
        N_CopyRect( HMDC, Point( AX+46, AY+39 ), HMDC, Rect( AX+6, AY+39, AX+11, AY+44 ) );

        //***** Dashed Lines test

        //      In ExtCreatePen Dashes are one pixel bigger, Gaps are one pixel smaller
        //      (in both compatible and advanced modes)
        //        e.g 0, 2 means one pixel dash and one pixel gap
        //        e.g 1, 3 means two pixels dash and two pixels gap

        Line[0] := Point( AX+5, AY+47 ); Line[1] := Point( AX+65, AY+47 );
        SetPenAttribs( $FF00FF, 1, 0, PFloat(CAFPArray.P()), 2*CAFPArray.ALength() );
        Windows.Polyline( HMDC, (@Line[0])^, 2 );

        Line[0] := Point( AX+5, AY+50 ); Line[1] := Point( AX+65, AY+50 );
        SetPenAttribs( $FF00FF, 3, 0, PFloat(CAFPArray.P()), 2*CAFPArray.ALength() );
        Windows.Polyline( HMDC, (@Line[0])^, 2 );
      end; // 0: begin //  Test variant #0

      1: begin //********************* Test variant #1
        //*****

      end; // 1: begin //  Test variant #1

      end; // case ATestNum of
    end; // with APParams^, UDActionComp.NGCont.DstOCanv, ABasePoint do

  end; // procedure DrawFragm - local

begin
  UDActionComp := TN_UDAction(AP1^);
  with APParams^, UDActionComp, UDActionComp.NGCont.DstOCanv do
  begin
    BaseY := 2;

    AdvancedMode( False );
    RectStr := 'Compatible';
    DrawFragm( 2, BaseY, 70, 54, 0, $AAEEFF );
    Inc( BaseY, 55 );

    AdvancedMode( True );
    RectStr := 'Advanced';
    DrawFragm( 2, BaseY, 70, 54, 0, $EEFFAA );
//    Inc( BaseY, 55 );

  end; // with APParams^ do
end; // procedure N_UDATestLowLevelDraw1

procedure N_UDATestOneBezierSegm( APParams: TN_PCAction; AP1, AP2: Pointer );
// Draw One Bezier Segment, four points are in CADPArray1
//
// (for using in TN_UDAction under Action Name 'OneBezierSegm' )
var
  i, NumPoints: integer;
  DC: TN_DPArray;
  ContAttr: TK_RArray;
  SCoords: TN_ShapeCoords;
  UDActionComp: TN_UDAction;

  function PDP( AInd: integer ): PDPoint; // local
  begin
    Result := PDPoint(APParams^.CADPArray.P(AInd));
  end; // function PDP

begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.NGCont do
  begin
    SCoords := TN_ShapeCoords.Create;
    SCoords.AddUserSepSegm( PDP(0)^, PDP(1)^, @DstOCanv.U2P );
    SCoords.AddUserSepSegm( PDP(2)^, PDP(3)^, @DstOCanv.U2P );

    ContAttr := nil;
    N_FillContAttr1( ContAttr, -1, $FF0000, 2 );
    DrawShape( SCoords, ContAttr, N_ZFPoint );

    NumPoints := 100;
    SetLength( DC, NumPoints );
    for i := 0 to NumPoints-1 do
    begin
      DC[i] := N_GetBezierPoint( PDP(0),  i*1.0/(NumPoints-1) );
    end;

    SCoords.Clear;
    SCoords.AddUserPolyLine( PDPoint(@DC[0]), NumPoints, @DstOCanv.U2P );
    N_FillContAttr1( ContAttr, -1, $FF00, 1 );
    DrawShape( SCoords, ContAttr, N_ZFPoint );

    SCoords.Free;
//
  end; // with APParams^ do
end; // procedure N_UDATestOneBezierSegm

procedure N_UDATest1DPWIFunc( APParams: TN_PCAction; AP1, AP2: Pointer );
// Draw curve calculated by N_1DPWIFunc and polyline in N_1DPWIFunc Coefs
// N_1DPWIFunc Coefs are given in CADPArray1
//
// (for using in TN_UDAction under Action Name '1DPWIFunc' )
var
  i, NumPoints: integer;
  PData: PDouble;
  PCur: TN_BytesPtr;
  DC: TN_DPArray;
  ContAttr: TK_RArray;
  SCoords: TN_ShapeCoords;
  UDActionComp: TN_UDAction;

  function PDP( AInd: integer ): PDouble; // local
  // Return pointer to AInd Double in CADPArray1
  begin
    Result := PDouble(APParams^.CADPArray.P(AInd));
  end; // function PDP

begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.NGCont do
  begin
    PData := PDP(0);
    N_dp := PDPoint(PData)^;
    PCur := TN_BytesPtr(PData);
    NumPoints := N_1DPWIFuncCheck( PData );
    if NumPoints = -1 then
    begin
      GCShowResponse( '1DPWIFunc Error!' );
      Exit;
    end;

    N_SL.Clear;
    N_AddNumRArray( CADPArray, 1, N_SL );
    N_IAdd( N_SL );

    SetLength( DC, NumPoints );
    move( (PCur+32)^, DC[0], NumPoints*16 );

    SCoords := TN_ShapeCoords.Create;
    SCoords.AddUserPolyLine( PDPoint(@DC[0]), NumPoints, @DstOCanv.U2P );

    ContAttr := nil;
    N_FillContAttr1( ContAttr, -1, $FF0000, 3 );
    DrawShape( SCoords, ContAttr, N_ZFPoint );

    NumPoints := 100;
    SetLength( DC, NumPoints );
    for i := 0 to NumPoints-1 do
    begin
      DC[i].X := i*10.0/(NumPoints-1); // arg in (0,10)
      DC[i].Y := N_1DPWIFunc( DC[i].X, PDP(0) );
    end;

    SCoords.Clear;
    SCoords.AddUserPolyLine( PDPoint(@DC[0]), NumPoints, @DstOCanv.U2P );
    N_FillContAttr1( ContAttr, -1, $FF00, 1 );
    DrawShape( SCoords, ContAttr, N_ZFPoint );

    SCoords.Free;
    GCShowResponse( '1DPWIFunc finished OK' );
  end; // with APParams^ do
end; // procedure N_UDATest1DPWIFunc

procedure N_UDATestConvProcs1( APParams: TN_PCAction; AP1, AP2: Pointer );
// Convertion Funcs and Procs test #1
//
// (for using in TN_UDAction under Action Name 'ConvProcs1' )
var
  i: integer;
  Res: double;
  ResP: TDPoint;
  Args, Par1, Par2, XCoefs: TN_DArray;
  ArgPoints: TN_DPArray;
  UDActionComp: TN_UDAction;
begin
  Args := nil; // to avoid warning
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin
    //***** N_YNLConvPower test:
    XCoefs := N_CrDA( [0, 10, 0.5] );
    Par1 := N_CrDA( [1,2, 1,2, 0, 1] );
    Par2 := N_CrDA( [1,2, 2,4, 0, 1] );

    ArgPoints := N_CrDPA( [0,1.1, 0,1.9, 1,1.2, 1,1.8, 10,0, 10,1, 10,2, 10,3] );
    for i := 0 to High(ArgPoints) do
    begin
      if i = 5 then
        N_i := 1;
      ResP := N_XYNLConvPower( ArgPoints[i], @XCoefs[0], N_1DNLConvPower, 6, @Par1[0], @Par2[0] );
      N_IAdd( Format( '%d) Func(%g,%g)= %g, %g', [i, ArgPoints[i].X,ArgPoints[i].Y, ResP.X,ResP.Y] ));
    end; // for i := 0 to High(Args) do
    Exit;

    //***** N_1DNLConvPower test:

    Par1 := N_CrDA( [10,11, 1,2, 0, 0.5] );
    Args := N_CrDA( [5, 10, 10.1, 10.9, 11, 12] );

    for i := 0 to High(Args) do
    begin
      Res := N_1DNLConvPower( Args[i], @Par1[0] );
      N_IAdd( Format( 'Func(%g)=%g', [Args[i], Res] ));
    end; // for i := 0 to High(Args) do

  end; // with APParams^ do
end; // procedure N_UDATestConvProcs1

procedure N_UDATestXYNLConvPWI( APParams: TN_PCAction; AP1, AP2: Pointer );
// Convertion methods of TN_XYNLConvPWIObj test
//
// (for using in TN_UDAction under Action Name 'XYNLConvPWI' )
var
  i: integer;
  ResP: TDPoint;
  Params: TN_DArray;
  ArgPoints: TN_DPArray;
  XYPWIConvObj: TN_XYPWIConvObj;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin
    Params := N_CrDA( [0, 10, 0.5] ); // not implemented!
    ArgPoints := N_CrDPA( [0,1.1, 0,1.9, 1,1.2, 1,1.8, 10,0, 10,1, 10,2, 10,3] );
    XYPWIConvObj := TN_XYPWIConvObj.Create();
    XYPWIConvObj.NLConvPrep( @Params[0] );

    for i := 0 to High(ArgPoints) do
    begin
      if i = 5 then
        N_i := 1;
      ResP := XYPWIConvObj.NLConvDP( ArgPoints[i] );
      N_IAdd( Format( '%d) Func(%g,%g)= %g, %g', [i, ArgPoints[i].X,ArgPoints[i].Y, ResP.X,ResP.Y] ));
    end; // for i := 0 to High(Args) do

    XYPWIConvObj.Free;
  end; // with APParams^ do
end; // procedure N_UDATestXYNLConvPWI

procedure N_UDATestTimers1( APParams: TN_PCAction; AP1, AP2: Pointer );
// Timers1 Test
//
// (for using in TN_UDAction under Action Name 'TestTimers1' )
var
  T3: TN_CPUTimer3;
begin
  with APParams^, TN_UDAction(AP1^) do
  begin
    N_IAdd( ' *** N_UDATestTimers1' );

    //***** CAStr1 = '1' - Create Timer in UDActObj2, Start and Exit
    if CAStr1 = '1' then
    begin
      UDActObj2 := TN_CPUTimer3.Create();
      N_IAdd( 'CAStr=1 - Start' );
      TN_CPUTimer3(UDActObj2).Start();
      Exit;
    end;

    //***** CAStr1 = '2' - Stop Timer, show collected times and Start again
    if CAStr1 = '2' then
    begin
      TN_CPUTimer3(UDActObj2).SS( 'CAStr=2' );
      TN_CPUTimer3(UDActObj2).Start();
      Exit;
    end;

    //***** CAStr1 = '3' - Stop Timer in UDActObj2, show, Clear UDActObj2 and Exit
    if CAStr1 = '2' then
    begin
      TN_CPUTimer3(UDActObj2).SS( 'CAStr=3' );
      FreeAndNil( UDActObj2 );
      Exit;
    end;

    T3 := TN_CPUTimer3.Create();

    //***** Measure TN_CPUTimer1 and TN_CPUTimer3 Start/Stop expenses

    N_T1.Start();
    N_T1.SS( 'T1 Zero   SS' );

    N_T1.Start();
    N_T1.Stop();
    N_T1.Show( 'T1 Zero Stop' );

    T3.Start();
    T3.SS( 'T3 Zero  SS' );

    T3.Start();
    T3.Stop;
    T3.Show( 'T3 Zero Stop' );
    N_IAdd( '' );

    //***** Measure several small intervals to check TN_CPUTimer1 and N_DelayByLoop granularity
    //      N_DelayByLoop( 0 ) - min value - about 1 mcsec.

    N_T1.Start();
    N_DelayByLoop( 3.0e-4 );
    N_T1.SS( 'T1 Loop 3.e-7' );

    N_T1.Start();
    N_DelayByLoop( 6.0e-4 );
    N_T1.SS( 'T1 Loop 6.e-7' );

    N_T1.Start();
    N_DelayByLoop( 1.0e-3 );
    N_T1.SS( 'T1 Loop 1.0e-6' );

    N_T1.Start();
    N_DelayByLoop( 2.0e-3 );
    N_T1.SS( 'T1 Loop 2.e-6' );

    N_T1.Start();
    N_DelayByLoop( 3.0e-3 );
    N_T1.SS( 'T1 Loop 3.e-6' );

    N_T1.Start();
    N_DelayByLoop( 1.0e-2 );
    N_T1.SS( 'T1 Loop 1.0e-5' );

    N_T1.Start();
    N_DelayByLoop( 1.0e-1 );
    N_T1.SS( 'T1 Loop 1.0e-4' );

    N_T1.Start();
    N_DelayByLoop( 1 );
    N_T1.SS( 'T1 Loop 1.0e-3' );

    N_T1.Start();
    N_DelayByLoop( 10 );
    N_T1.SS( 'T1 Loop 1.0e-2' );

    N_T1.Start();
    N_DelayByLoop( 100 );
    N_T1.SS( 'T1 Loop 1.0e-1' );
    N_IAdd( '' );

    //***** Measure several small intervals to check TN_CPUTimer3 granularity

    T3.Start();
    N_DelayByLoop( 5 );
    T3.SS( 'Loop  5 msec' );

    T3.Start();
    N_DelayByLoop( 10 );
    T3.SS( 'Loop 10 msec' );

    T3.Start();
    N_DelayByLoop( 20 );
    T3.SS( 'Loop 20 msec' );

    T3.Start();
    N_DelayByLoop( 30 );
    T3.SS( 'Loop 30 msec' );

    T3.Start();
    N_DelayByLoop( 40 );
    T3.SS( 'Loop 40 msec' );
    N_IAdd( '' );

//    Exit; // debug

    //***** Measure several big intervals (>= 1 sec.) to check other processes influence

    T3.Start();
    Sleep( 1000 );
    T3.SS( 'Sleep 1.00' );

    T3.Start();
    N_DelayByLoop( 1000 );
    T3.SS( 'Loop 1.00' );

    T3.Start();
    Sleep( 1000 );
    N_DelayByLoop( 1000 );
    T3.SS( 'Sleep+Loop 2.0' );

    T3.ShowTimeFmt := '%9.6f';
    T3.Start();
    Sleep( 5000 );
    T3.SS( 'Sleep 5.00' );

    T3.Start();
    N_DelayByLoop( 5000 );
    T3.SS( 'Loop 5.00' );

    T3.Start();
    Sleep( 500 );
    N_DelayByLoop( 500 );
    Sleep( 500 );
    N_DelayByLoop( 500 );
    T3.SS( 'Sleep+Loop 2.0' );

    T3.Free;
  end; // with APParams^ do
end; // procedure N_UDATestTimers1

//**************************************************** N_UDATestWordDeb1
// Word Action Debug 1:
//   same basic OLE operations
// (for using in TN_UDAction under Action Name "WordDeb1")
//
procedure N_UDATestWordDeb1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, NumNotes: integer;
  FName, MacroStr: string;
  Doc, Ftn, FParent: Variant;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.NGCont do
  begin

    DefWordServer();
    GCWordServer.Visible := True;
    FName := K_ExpandFileName( CAFName1 );
    Doc := GCWordServer.Documents.Add( Template:=FName );
    Doc.Range.InsertAfter( K_DateTimeToStr( Date+Time ) );
    FName := K_ExpandFileName( CAFName2 );
    CloseWordDocSafe( FName );
    Doc.SaveAs( Filename := FName );

    NumNotes := Doc.Footnotes.Count;
    for i := 1 to NumNotes do // along all Notes
    begin
      Ftn := Doc.Footnotes.Item(i);
      FParent := Ftn.Parent;
      N_s := FParent.Name;
      MacroStr := Doc.Footnotes.Item(i).Range.Text;
    end;

  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_UDATestWordDeb1

//**************************************************** N_UDATestWordDeb2
// Word Action Debug 2:
//   Using Macros in separarte file tests
// (for using in TN_UDAction under Action Name "WordDeb2")
//
procedure N_UDATestWordDeb2( APParams: TN_PCAction; AP1, AP2: Pointer );
var
//  i, NumNotes: integer;
  FName: string;
  Doc : Variant;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.NGCont do
  begin

    DefWordServer();
    GCWordServer.Visible := True;

    FName := K_ExpandFileName( CAFName1 );
    Doc := GCWordServer.Documents.Add( Template:=FName );
    N_i := GCWordServer.Templates.Count;

    GCWordServer.Run( 'Alert1' );
    GCWordServer.Run( 'AlertWLib1' );

{
    FName := K_ExpandFileName( CAFName2 );
//    GCWordServer.AddIns.Add( 'C:\Delphi_prj\DTmp\Test\WLib1.dot' );
//    N_i := GCWordServer.Templates.Count;
    N_i := GCWordServer.AddIns.Count;
    GCWordServer.AddIns.Add( 'C:\Delphi_prj\DTmp\Test\WLib2.dot' );
    N_i1 := GCWordServer.AddIns.Count;
    N_i2 := GCWordServer.Templates.Count;

    GCWordServer.Documents.Open( FName, True );
    N_i := GCWordServer.Templates.Count;
    GCWordServer.Run( 'WLib1.dot.NewMacros.Alert_Macro1' );

    Doc.AttachedTemplate := 'C:\Delphi_prj\DTmp\Test\WLib1.dot';
    N_i := GCWordServer.Templates.Count;

    Doc.AttachedTemplate := 'C:\Delphi_prj\DTmp\Test\WLib2.dot';
    N_i := GCWordServer.Templates.Count;
    GCWordServer.Run( 'Project.NewMacros.Alert2' );
}

  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_UDATestWordDeb2

//**************************************************** N_UDATestWordDeb3
// Word Action Debug 3:
//   Not used
// (for using in TN_UDAction under Action Name "WordDeb3")
//
procedure N_UDATestWordDeb3( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  MainComp: TN_UDCompBase;
  UDActionComp: TN_UDAction;
  NewGCont: TN_GlobCont;
  WS: WideString;
  B1: Array [0..19] of Byte;
begin

  StringToWideChar( 'аб '+Char(1)+' АБ', PWideChar(@B1[0]), 18 );
  WS := '12 аб АБ';
  N_i := integer(WS[1]);
  N_i := integer(WS[4]);
  Exit;

  UDActionComp := TN_UDAction(AP1^);
  with APParams^, UDActionComp do
  begin
    NewGCont := TN_GlobCont.CreateByGCont( NGCont ); // GCont for Master Document

    MainComp := TN_UDCompBase(CAUDBase1); // Root Word Component
    MainComp.DynParent := nil;

    with NewGCont do
    begin
      PrepForExport( MainComp );

      ExecuteComp( MainComp, [cifRootComp] );
      FinishExport();
      Free;
    end; // with NewGCont do

  end; // with APParams^, UDActionComp do
end; //*** end of procedure N_UDATestWordDeb3

//**************************************************** N_UDATestWordDeb4
// Word Action Debug 4:
//   Simple Document without pics and Oglav.
// (for using in TN_UDAction under Action Name "WordDeb4")
//
procedure N_UDATestWordDeb4( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  ia, iq, ira, iru, NumAnswers, NumQuestions, NumRazdels, NumRubrics: integer;
  MapLevel, QuestLevel, RazdLevel, RubrLevel, iruMax: integer;
  SubDocName, SubDocBaseName, BookmarkName: string;
  CreateSubDocs: boolean;
  UDActionComp: TN_UDAction;
  NewGCont1, NewGCont2, CurGCont: TN_GlobCont;
  CompsRoot: TN_UDBase;
  MainComp, RazdComp, RubrComp, RubRazdComp, QuestComp: TN_UDCompBase;
  MapComp: TN_UDCompVis;
  PExpParams: TN_PExpParams;
begin
  NewGCont2 := nil; // to avoid warning
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp do
  begin
    NewGCont1 := TN_GlobCont.CreateByGCont( NGCont ); // GCont for Master Document

    //*** get Params from APParams^
    CompsRoot := CAUDBase1;
    N_s := CompsRoot.ObjName; // debug
    NumAnswers   := CAIRect.Left;   // level 4
    NumQuestions := CAIRect.Top;    // level 3
    NumRubrics   := CAIRect.Right;  // level 2
    NumRazdels   := CAIRect.Bottom; // level 1
    CreateSubDocs := False;

    with CompsRoot do
    begin
      MainComp  := TN_UDCompBase(DirChildByObjName( 'WRoot' )); // Root Word Component
      MainComp.DynParent := nil;

      RazdComp    := TN_UDCompBase(DirChildByObjName( 'WRazd'    )); // Razdel Title
      RubRazdComp := TN_UDCompBase(DirChildByObjName( 'WRubRazd' )); // Rubrica without Razdel Title
      RubrComp    := TN_UDCompBase(DirChildByObjName( 'WRubr'    )); // Rubrica Title

      PExpParams := RubrComp.GetPExpParams();
      SubDocBaseName := ChangeFileExt( K_ExpandFileName(PExpParams^.EPMainFName), '' );

      QuestComp := TN_UDCompBase(DirChildByObjName( 'WQuest' )); // Question Title
      MapComp   := TN_UDCompVis(DirChildByObjName(  'WMap'   )); // Map Component
    end; // with CompsRoot do

    with NewGCont1 do
    begin
      N_IAdd( '' );
      N_IAdd( 'Begin ActionWordDeb4 ' + N_IrectToStr(CAIRect) );
      PrepForExport( MainComp );

      ExecuteComp( MainComp, [cifRootComp] );
      GCWordServer.Run( 'RemoveBookmarks' ); // debug
      GCShowResponse( 'Root Executed' );
      RazdLevel := 1;

      for ira := 1 to NumRazdels do // along Razdels (Titul + list of Rubrics)
      begin
        if ira = 2 then // Razdel #2 is without Rubrics
        begin
          GCSetStrVar( 'LeftHeader',  Format( 'Left_%d', [ira] ) );
          GCSetStrVar( 'RightHeader', Format( 'Right_%d', [ira] ) );
          RubRazdComp.SetSUserParInt( 'TOCLevel', RazdLevel );
          RubRazdComp.SetSUserParStr( 'ShortName', Format( 'RubRazdel %d Short Name', [ira] ) );
          RubRazdComp.SetSUserParStr( 'FullName',  Format( 'RubRazdel %d Full Name', [ira] ) );
          ExecuteComp( RubRazdComp ); // Rubric without Razdel Titul
          iruMax := 1;
        end else // Rubrics in Razdel
        begin
          RazdComp.SetSUserParInt( 'TOCLevel', RazdLevel );
          RazdComp.SetSUserParStr( 'ShortName', Format( 'Razdel %d Short Name', [ira] ) );
          RazdComp.SetSUserParStr( 'FullName',  Format( 'Razdel %d Full Name', [ira] ) );
          ExecuteComp( RazdComp ); // Razdel Titul
          iruMax := NumRubrics;
        end;

        RubrLevel := 2;

        for iru := 1 to iruMax do // along Rubrics (Titul + list of Questions)
        begin

          if CreateSubDocs then
          begin
            //*** Each Rubric is a Standalone SubDocument, prepare NewGCont2 for it
            NewGCont2 := TN_GlobCont.CreateByGCont( NewGCont1 ); // GCont for SubDocument
            CurGCont := NewGCont2;
          end else
            CurGCont := NewGCont1;

          with CurGCont do // NewGCont1 or NewGCont2
          begin

          if ira <> 2 then // Rubrics in Razdel
          begin
            GCSetStrVar( 'LeftHeader',  Format( 'Left_%d_%d', [ira,iru] ) );
            GCSetStrVar( 'RightHeader', Format( 'Right_%d_%d', [ira,iru] ) );
            RubrComp.SetSUserParInt( 'TOCLevel', RubrLevel );
            RubrComp.SetSUserParStr( 'ShortName', Format( 'Rubric %d Short Name', [iru] ) );
            RubrComp.SetSUserParStr( 'FullName',  Format( 'Rubric %d Full Name', [iru] ) );

            if CreateSubDocs then
            begin
              SubDocName := SubDocBaseName + Format( '_%.2d_%.2d.doc', [ira,iru] );
              PExpParams^.EPMainFName := SubDocName;

              PrepForExport( RubrComp );
              ExecuteComp( RubrComp, [cifRootComp] );
            end else
              ExecuteComp( RubrComp );

            QuestLevel := 3;
          end else // if ira <> 2 then // Rubrics in Razdel
            QuestLevel := 2;

          for iq := 1 to NumQuestions do // along Questions (Titul + list of Answers(Maps))
          begin
            QuestComp.SetSUserParInt( 'TOCLevel', QuestLevel );
            QuestComp.SetSUserParStr( 'ShortName', Format( 'Question %d Short Name', [iq] ) );
            QuestComp.SetSUserParStr( 'FullName',  Format( 'Question %d Full Name', [iq] ) );
            ExecuteComp( QuestComp ); // Question Titul
            MapLevel := QuestLevel + 1;

            for ia := 1 to NumAnswers do // along Map pages, one page for each Answer
            begin
              MapComp.SetSUserParInt( 'TOCLevel', MapLevel );
              MapComp.SetSUserParStr( 'ShortName', Format( 'Map %d Short Name', [ia] ) );
              ExecuteComp( MapComp ); // Map page (one Answer)
              GCShowResponse( Format( 'ira,iru,iq,ia: %.2d %.2d %.2d %.2d ', [ira,iru,iq,ia] ) );
            end; // for ia := 1 to NumAnswers do // Map pages, one page for each Answer

          end; // for iq := 1 to NumNumQuestions do // Questions (Titul + list of Answers(Maps))

        if CreateSubDocs then
        begin
          //*** Finish Creating Subdocument (Rubric) and insert it into Master(Root) Document
          NewGCont2.FinishExport(); // finish creating file SubDocName
          NewGCont1.GCUpdateSelf( NewGCont2 );
          NewGCont2.Free;
        end; // if CreateSubDocs then

        end; // with CurGCont do

        if CreateSubDocs then
        begin
          BookmarkName := GCGetStrVar( 'RazdOgl' );
          WordInsNearBookmark( wibwhereEnd1, wibWhatSubDoc, BookmarkName, SubDocName );
        end; // if CreateSubDocs then

        end; // for iru := 1 to NumRubrics do // Rubrics (Titul + list of Questions)

      end; // for ira := 1 to NumRazdels do // Razdels (Titul + list of Rubrics)

      GCShowResponse( 'Finishing ...' );
      FinishExport();
      Free;
      Clipboard.AsText := ''; // to avoid asking about Clipboard while closing Word
      GCShowResponse( 'Finished' );
    end; // with NewGCont1 do
  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_UDATestWordDeb4

//******************************************************** N_UDATestWordDeb5 ***
// Word Action Debug 5:
// Create multilevel document with simple razdels and Historgams
// (for using in TN_UDAction under Action Name "WordDeb5")
//
procedure N_UDATestWordDeb5( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i1, i2, NumRazdLev1, NumGroups: integer;
  UDActionComp: TN_UDAction;
  NewGCont1: TN_GlobCont;
  MainComp, RazdLev1Comp, GroupComp: TN_UDCompBase; // RazdLev2Comp,
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp do
  begin
    NewGCont1 := TN_GlobCont.CreateByGCont( NGCont ); // GCont for Master Document

    //*** get Params from APParams^
    NumRazdLev1 := CAIRect.Top; // Number of Razdels at Level 1 // IPoint1.X
    NumGroups   := CAIRect.Left; // Number of Groups            // IPoint1.Y

    MainComp     := TN_PUDCompBase(CAUDBaseArray.P(0))^;
    RazdLev1Comp := TN_PUDCompBase(CAUDBaseArray.P(1))^;
//    RazdLev2Comp := TN_PUDCompBase(CAUDBaseArray.P(2))^;
    GroupComp    := TN_PUDCompBase(CAUDBaseArray.P(2))^;

    with NewGCont1 do
    begin
      N_IAdd( '' );
      N_IAdd( 'Begin Action "WordDeb5" ' + N_IPointToStr(CAIRect.TopLeft) );
      PrepForExport( MainComp );

      ExecuteComp( MainComp, [cifRootComp] );
      GCShowResponse( 'Root Executed' );

      for i1 := 1 to NumRazdLev1 do // along Razdels at Level 1
      begin
        RazdLev1Comp.SetSUserParStr( 'ShortName', Format( 'Level1_Short_Name_%d', [i1] ) );
        RazdLev1Comp.SetSUserParStr( 'FullName', Format( 'Level1_Full_Name_%d', [i1] ) );
        RazdLev1Comp.SetSUserParStr( 'NumPref', Format( '%d.', [i1] ) );
        ExecuteComp( RazdLev1Comp );

        for i2 := 1 to NumGroups do // along Groups (at last Level)
        begin
          GroupComp.SetSUserParStr( 'ShortName', Format( 'Level2_Short_Name_%d', [i2] ) );
          GroupComp.SetSUserParStr( 'FullName', Format( 'Level2_Full_Name_%d', [i2] ) );
          GroupComp.SetSUserParStr( 'NumPref', Format( '%d.%d.', [i1,i2] ) );
          ExecuteComp( GroupComp );

          // Execute LinHist and Table Components
          ExecuteComp( TN_UDCompBase(CAUDBase1) );
          ExecuteComp( TN_UDCompBase(CAUDBase2) );
          ExecuteComp( TN_UDCompBase(CAUDBase3) );

          N_IAdd( Format( 'WordDeb5: i1=%d, i2=%d', [i1,i2] ) );

        end; // for i2 := 1 to NumGroups do // along Groups (at last Level)
      end; // for i1 := 1 to NumRazdLev1 do // along Razdels at Level 1

      GCShowResponse( 'Finishing ...' );
      FinishExport();
      Clipboard.AsText := ''; // to avoid asking about Clipboard while closing Word
      GCShowResponse( 'Finished' );
    end; // with NewGCont1 do

    NGCont.GCUpdateSelf( NewGCont1 );
    NewGCont1.Free;
  end; // with APParams^, UDActionComp do
end; //*** end of procedure N_UDATestWordDeb5

//******************************************************* N_UDATestWordDeb6 ***
// Word Action Debug 6:
//   Temporary debug code

// (for using in TN_UDAction under Action Name "WordDeb6")
//
procedure N_UDATestWordDeb6( APParams: TN_PCAction; AP1, AP2: Pointer );
var
//  FName: string;
  UDActionComp: TN_UDAction;
//  WDoc: variant;
  R: variant;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin
//  GCWordServer.Run( 'Alert1' );
    R := GCWordServer.ActiveDocument.Content;
    R.Collapse( wdCollapseEnd );
    R.Text := 'Deb6 a!';
    R.Copy;
//    GCWordServer.ActiveDocument.Saved := True;

  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_UDATestWordDeb6

//******************************************************* N_UDATestWordDeb7 ***
// Word Action Debug 7:
//   Create new Document with one WordFragm and one Picture, added from Clipboard
//
// (for using in TN_UDAction under Action Name "WordDeb7")
//
procedure N_UDATestWordDeb7( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  UDActionComp: TN_UDAction;
  CurGCont: TN_GlobCont;
  RootComp, WordFragm, PictComp: TN_UDCompBase;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp do
  begin
    //*** Get Params
    RootComp  := TN_UDCompBase(CAUDBase1);
    WordFragm := TN_UDCompBase(CAUDBase2);
    PictComp  := TN_UDCompBase(CAUDBase3);

    //*** Start creating document
    CurGCont := TN_GlobCont.Create();
    RootComp.DynParent := nil; // root component
    CurGCont.PrepForExport( RootComp );
    CurGCont.ExecuteComp( RootComp, [cifRootComp] );

    CurGCont.ExecuteComp( WordFragm ); // not needed

    PictComp.ExecInNewGCont();     // Create Clipboard content
//    CurGCont.WordPasteClipBoard();

    CurGCont.FinishExport();
    Clipboard.AsText := ''; // to avoid asking about Clipboard while closing Word
    CurGCont.GCShowResponse( 'Created OK' );
    CurGCont.Free;
  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_UDATestWordDeb7

//************************************************** N_UDATestWordRunMacros ***
//  Run Macros from different files
//  (should be called inside UDWordFragm SubTree)
//
// (for using in TN_UDAction under Action Name "WordRunMacros")
//
procedure N_UDATestWordRunMacros( APParams: TN_PCAction; AP1, AP2: Pointer );
var
//  FName: string;
//  Doc : Variant;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.NGCont do
  begin
    N_T1.Start();
    GCWordServer.Run( 'N_TestEmptyMacro' );
    N_T1.SS( 'N_TestEmptyMacro #1' );

    N_T1.Start();
    GCWordServer.Run( 'N_TestEmptyMacro' );
    N_T1.SS( 'N_TestEmptyMacro #2' );

    N_T1.Start();
    GCWordServer.Run( 'N_TestOneOpMacro' );
    N_T1.SS( 'N_TestOneOpMacro' );

    N_T1.Start();
    GCWordServer.Run( 'N_TestGetDocName' );
    N_T1.SS( 'N_TestGetDocName' );

    Clipboard.AsText := '12345678901234567890';
    N_T1.Start();
    GCWordServer.Run( 'N_TestClipboardStr' );
    N_T1.SS( 'Clipboard 20 ' + Clipboard.AsText );

    Clipboard.AsText := '123 ' + StringOfChar( '1', 10000 );
    N_T1.Start();
    GCWordServer.Run( 'N_TestClipboardStr' );
    N_s := Clipboard.AsText;
    N_T1.SS( Format( 'Clipboard 10K Size=%d, Pref=%s', [Length(N_s), LeftStr(N_s, 20)] ) );

    Clipboard.AsText := '456 ' + StringOfChar( '2', 20000 );
    N_T1.Start();
    GCWordServer.Run( 'N_TestClipboardStr' );
    N_T1.SS( 'Clipboard 20K ' + LeftStr(Clipboard.AsText, 20) );

    Clipboard.AsText := '789' + StringOfChar( '3', 57000 );
//    Clipboard.AsText := '789' + StringOfChar( '3', 17000 );
    N_T1.Start();
    GCWordServer.Run( 'N_TestClipboardStr' );
    N_T1.SS( 'Clipboard ???K' );

    N_T1.Start();
    GCWordServer.Run( 'N_TestSleep500' );
    N_T1.SS( 'Sleep 500 msec.' );

  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_UDATestWordRunMacros

//************************************************ N_UDATestWordSpeedTests1 ***
//  Word Speed Tests set #1
//  (should be called inside UDWordFragm SubTree because of using GCWordServer)
//
// (for using in TN_UDAction under Action Name "WordSpeedTests1")
//
procedure N_UDATestWordSpeedTests1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, i1, RealMode: integer;
  SrcBuf, ResBuf: string;
  Range: variant;
  SavedMode: TN_MEWordPSMode;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.NGCont do
  begin
    N_IAdd( '' );
    N_IAdd( GetWSInfo( 2, '***** WordSpeedTests1 Action ******' ) );
//    Exit;

    N_T1.Start();
      GCWordServer.Run( 'N_TestEmptyMacro' );
    N_T1.SS( 'N_TestEmptyMacro #1' );

    N_T1.Start();
      GCWordServer.Run( 'N_TestCallEmptyMacro' );
    N_T1.SS( 'N_TestCallEmptyMacro' );

    N_T1.Start();
      GCWordServer.Run( 'N_Test1e5Calls' );
    N_T1.SS( 'N_Test1e5Calls' );

    N_T1.Start();
      GCWordServer.Run( 'N_Test1e5InStr' );
    N_T1.SS( 'N_Test1e5InStr' );

    N_T1.Start();
      GCWordServer.Run( 'N_TestEmptyMacro' );
    N_T1.SS( 'N_TestEmptyMacro #2' );

    N_T1.Start();
      GCWordServer.Run( 'N_TestOneOpMacro' );
    N_T1.SS( 'N_TestOneOpMacro' );

    N_T1.Start();
      GCWordServer.Run( 'N_Test1e6OpMacro' );
    N_T1.SS( 'N_Test1e6OpMacro' );

    N_T1.Start();
      for i := 1 to 10000 do
      begin
        for i1 := 1 to 100 do
          N_d := N_d + N_d1;
      end; // for i := 1 to 10000 do
    N_T1.SS( '1e6 Op Pascal' );


    if mewfUseVBA in GCWSVBAFlags then // because of use VBA N_GCMainDoc variable
    begin
      N_T1.Start();
        GCWordServer.Run( 'N_TestGetDocName' );
      N_T1.SS( 'N_TestGetDocName' );
    end;

    N_T1.Start();
      GCWordServer.Run( 'N_TestEmptyMacro' );
    N_T1.SS( 'N_TestEmptyMacro #3' );

    N_T1.Start();
      N_s := GCWSMainDoc.Name;
    N_T1.SS( 'Get DocName in Pascal' );

    if mewfUseVBA in GCWSVBAFlags then // because of use VBA N_GCMainDoc variable
    begin
      N_T1.Start();
        GCWordServer.Run( 'N_TestCopyDoc' );
      N_T1.SS( 'Copy Doc in VBA (N_TestCopyDoc)' );
    end;

    N_T1.Start();
      Range := GCWSMainDoc.Content;
      Range.MoveEnd( wdCharacter, -1 );
      Range.Copy;
    N_T1.SS( 'Copy Doc in Pascal' );
    Range := Unassigned();

    if mewfUseVBA in GCWSVBAFlags then
    begin
      N_IAdd( '' );
      N_IAdd( '   N_TestParamsStr in all ParStr modes for several Data Sizes:' );
      SavedMode := GCWSPSMode;

      for i := 1 to 6 do // along all variants of passing params
      begin
        N_IAdd( '' );

        if ((i=1) or (i=3) or (i=4)) and
           not (mewfUseWin32API in GCWSVBAFlags) then Continue; // skip

        if i = 5 then
          N_i := 1;

        SetWordPSMode( TN_MEWordPSMode(i) );
        N_IAdd( N_PSModeNames[i] );

        SrcBuf := '0';
        N_T1.Start();
          SetWordParamsStr( SrcBuf );
          RealMode := integer(GCWSPSMode);
          GCWordServer.Run( 'N_TestParamsStr' );
          ResBuf := GetWordParamsStr();
        N_T1.Stop();
        N_T1.Show( Format( 'Mode=%d,   1 byte  Size=%d, %s...', [RealMode, Length(ResBuf), LeftStr(ResBuf, 20)] ) );

        SrcBuf := '012ЖW56789';
        N_T1.Start();
          SetWordParamsStr( SrcBuf );
          RealMode := integer(GCWSPSMode);
          GCWordServer.Run( 'N_TestParamsStr' );
          ResBuf := GetWordParamsStr();
        N_T1.Stop();
        N_T1.Show( Format( 'Mode=%d,  10 bytes Size=%d, %s...', [RealMode, Length(ResBuf), LeftStr(ResBuf, 20)] ) );

        SrcBuf := '1Жд ' + StringOfChar( '1', 196 );
        N_T1.Start();
          SetWordParamsStr( SrcBuf );
          RealMode := integer(GCWSPSMode);
          GCWordServer.Run( 'N_TestParamsStr' );
          ResBuf := GetWordParamsStr();
        N_T1.Stop();
        N_T1.Show( Format( 'Mode=%d, 200 bytes Size=%d, %s...', [RealMode, Length(ResBuf), LeftStr(ResBuf, 20)] ) );

        SrcBuf := '234 ' + StringOfChar( '2', 1996 );
        N_T1.Start();
          SetWordParamsStr( SrcBuf );
          RealMode := integer(GCWSPSMode);
          GCWordServer.Run( 'N_TestParamsStr' );
          ResBuf := GetWordParamsStr();
        N_T1.Stop();
        N_T1.Show( Format( 'Mode=%d,   2 Kb    Size=%d, %s...', [RealMode, Length(ResBuf), LeftStr(ResBuf, 20)] ) );

        SrcBuf := '345 ' + StringOfChar( '3', 19996 );
        N_T1.Start();
          SetWordParamsStr( SrcBuf );
          RealMode := integer(GCWSPSMode);
          GCWordServer.Run( 'N_TestParamsStr' );
          ResBuf := GetWordParamsStr();
        N_T1.Stop();
        N_T1.Show( Format( 'Mode=%d,  20 Kb    Size=%d, %s...', [RealMode, Length(ResBuf), LeftStr(ResBuf, 20)] ) );

        if (GCWSPSMode <> psmPSDocVar)   and    // Word Document variables should be < 64 Kb!
           (GCWSPSMode <> psmDelphiMem)  then // N_DephiMem is now 64008 bytes long
        begin
          SrcBuf := '456 ' + StringOfChar( '4', 199996 );
          N_T1.Start();
            SetWordParamsStr( SrcBuf );
            RealMode := integer(GCWSPSMode);
            GCWordServer.Run( 'N_TestParamsStr' );
            ResBuf := GetWordParamsStr();
          N_T1.Stop();
          N_T1.Show( Format( 'Mode=%d, 200 Kb    Size=%d, %s...', [RealMode, Length(ResBuf), LeftStr(ResBuf, 20)] ) );
        end;

      end; // for i := 0 to 6 do // along all variants of passing params

      SetWordPSMode( SavedMode ); // restore
    end; // if mewfUseVBA in GCWSVBAFlags then

    if mewfUseWin32API in GCWSVBAFlags then
    begin
      N_IAdd( '' );
      N_IAdd( '   N_TestClipboardStr for several Data Sizes:' );

      Clipboard.AsText := '12345678901234567890';
      N_T1.Start();
        GCWordServer.Run( 'N_TestClipboardStr' );
      N_T1.SS( '20 Bytes ' + Clipboard.AsText );

      Clipboard.AsText := '123 ' + StringOfChar( '1', 10000 );
      N_T1.Start();
        GCWordServer.Run( 'N_TestClipboardStr' );
      N_s := Clipboard.AsText;
      N_T1.SS( Format( ' 10 Kb Size=%d, Pref=%s', [Length(N_s), LeftStr(N_s, 20)] ) );

      Clipboard.AsText := '456 ' + StringOfChar( '2', 20000 );
      N_T1.Start();
        GCWordServer.Run( 'N_TestClipboardStr' );
      N_s := Clipboard.AsText;
      N_T1.SS( Format( ' 20 Kb Size=%d, Pref=%s', [Length(N_s), LeftStr(N_s, 20)] ) );

      Clipboard.AsText := '789 ' + StringOfChar( '3', 200000 );
      N_T1.Start();
        GCWordServer.Run( 'N_TestClipboardStr' );
      N_s := Clipboard.AsText;
      N_T1.SS( Format( '200 Kb Size=%d, Pref=%s', [Length(N_s), LeftStr(N_s, 20)] ) );

      N_T1.Start();
        GCWordServer.Run( 'N_TestSleep100' );
      N_T1.SS( 'Sleep 100 msec.' );
    end; // if mewfUseWin32API in GCWSVBAFlags then

    N_IAdd( 'End of WordTests1 Action' );
    N_IAdd( '' );
  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_UDATestWordSpeedTests1

//************************************************** N_UDATestCreateWordDoc ***
//  Create WordDoc using TN_WordDoc class
//
// CAUDBase1     - Root WordFragm
// CAUDBaseArray - Components to execute (WordFragms or pictures in Clipboard)
//
// (for using in TN_UDAction under Action Name "CreateWordDoc")
//
procedure N_UDATestCreateWordDoc( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i: integer;
  CurComp: TN_UDBase;
  WordDoc: TN_WordDoc;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin
    WordDoc := TN_WordDoc.Create();
    WordDoc.StartCreating( CAUDBase1, '(#OutFiles#)Test1.doc', [] );
    for i := 0 to CAUDBaseArray.AHigh() do
    begin
      CurComp := TN_PUDBase(CAUDBaseArray.P(i))^;
      WordDoc.AddComponent( CurComp );
    end; // for i := 0 to CAUDBaseArray.AHigh() do

    WordDoc.FinishCreating;
    WordDoc.Free;
  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_UDATestCreateWordDoc

//************************************************** N_UDATestCreateMVTADoc ***
//  Create MVTA Doc
//
// CAUDBase1  - Root WordFragm
// CAUDBase2  - Variant Header WordFragm
// CAStrArray - Array of Names Tasks
// CAIRect.Left - how many times process Array of Names Tasks
//
// (for using in TN_UDAction under Action Name "CreateMVTADoc")
//
procedure N_UDATestCreateMVTADoc( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, j, NRepeat: integer;
  TaskName: string;
  WordDoc: TN_WordDoc;
  ActionParent: TN_UDBase;
  TaskWordFragm: TN_UDWordFragm;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  N_T1.Start;

  with APParams^, UDActionComp.NGCont do
  begin
    WordDoc := TN_WordDoc.Create();
//    WordDoc.WDGCont.GCVarInfoProc := TK_MVGetVarInfoProc(1); // debug!
    WordDoc.StartCreating( CAUDBase1, '(#OutFiles#)ResTest1.doc', [] );
    WordDoc.AddComponent( CAUDBase2 );
    ActionParent := UDActionComp.Owner;
    TaskWordFragm := TN_UDWordFragm(ActionParent.DirChildByObjName( 'TaskWordFragm' ));
//    TaskWordFragm := TN_UDWordFragm(N_GetUObj( ActionParent, 'TaskWordFragm' ));

    if TaskWordFragm = nil then // Create TaskWordFragm (one for all tasks)
    begin
      TaskWordFragm := TN_UDWordFragm(K_CreateUDByRTypeName( 'TN_RWordFragm', 1, N_UDWordFragmCI ));
      TaskWordFragm.ObjName := 'TaskWordFragm';
      ActionParent.AddOneChildV( TaskWordFragm );
    end; // if TaskWordFragm = nil then // Create TaskWordFragm

    NRepeat := Max( 1, CAIRect.Left );
    for j := 1 to NRepeat do
    begin
      for i := 0 to CAStrArray.AHigh() do
      begin
        TaskName := PString(CAStrArray.P(i))^;
        if TaskName[1] = '!' then Continue; // commented Name

        with TaskWordFragm.PSP()^.CWordFragm do
        begin
          WFDocFName := '(#ArchSections#)' + TaskName + '.doc';
          WFFlags := WFFlags + [wffExpandTables];
        end;

        WordDoc.AddComponent( TaskWordFragm );
      end; // for i := 0 to CAUDBaseArray.AHigh() do
    end; // for j := 1 to NRepeat do

    WordDoc.FinishCreating;
    WordDoc.Free;
  end; // with APParams^, UDActionComp.NGCont do

  N_T1.SS( 'CreateMVTADoc' );
end; //*** end of procedure N_UDATestCreateMVTADoc

//************************************************* N_UDATestShowFileAsText ***
//  Show given File in ASCII HEX form
//
//
// (for using in TN_UDAction under Action Name "ShowFileAsText")
//
procedure N_UDATestShowFileAsText( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  RowSize: integer;
  FullFName, FileExt, SrcStr, ResStr: string;
  APForm: TN_PBaseForm;
  SL: TStrings;
  Doc: Variant;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin

    FullFName := K_ExpandFileName( CAFName1 );
    if FullFName = '' then Exit;
    if not FileExists( FullFName ) then Exit;

    FileExt := UpperCase( ExtractFileExt( FullFName ) );

    if FileExt = '.DOC' then // Show WordDoc.Text property
    begin
      DefWordServer();
      GCWordServer.Visible := True;
      Doc := GCWordServer.Documents.Add( Template:=FullFName );
      SrcStr := Doc.Content.Text;

      Doc.Saved := True;
      Doc.Close;
      Doc := Unassigned();

      if GCWSWasCreated then
        GCWordServer.Quit;

      GCWordServer  := Unassigned();

    end else // Show File in ASCII HEX form
    begin
      SrcStr := 'Not implemented';

    end;

    RowSize := CAIRect.Left;
    if RowSize = 0 then RowSize := 60;
    ResStr := N_ConvSpecCharsToHex( SrcStr, RowSize, 'Win1251' );

    APForm := nil;
    N_GetTextEditorForm( APForm, nil, SL );
    SL.Clear();
    SL.Text := ResStr;

//    N_EditText( ResStr, nil );

  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_UDATestShowFileAsText

//**************************************************** N_ActionRWProcMem1
// Debug Action Read/Write Process Memory
// (for using in TN_UDAction under Action Name "RWProcMem1")
//
procedure N_ActionRWProcMem1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  InpInt, MidInt, OutInt: integer;
  SelfProcId, ProcHandle: DWORD;
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  NumRed: Size_t;
{$ELSE}         // Delphi 7 or Delphi 2010
  NumRed: DWORD;
{$IFEND CompilerVersion >= 26.0}
//  Ptr1: Pointer;
  UDActionComp: TN_UDAction;
begin
//  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^ do
  begin
    SelfProcId := GetCurrentProcessId();
    N_IAdd( 'SelfProcId: ' + IntToHex( SelfProcId, 8 ) );
    N_i := PROCESS_ALL_ACCESS;
    ProcHandle := OpenProcess( PROCESS_ALL_ACCESS, False, SelfProcId );
    N_IAdd( 'ProcHandle: ' + IntToHex( ProcHandle, 8 ) );
    N_Gi := 112233;
    N_IAdd( 'N_Gi Adr: ' + IntToHex( integer(@N_Gi), 8 ) );

    InpInt := $70F1F2F3;
    OutInt := $7FFFFFFF;
    NumRed := 0;
    MidInt := 0;
    // Read from InpInt into MidInt two bytes (InpInt in another (ProcHandle) AdrSpace)
//    Ptr1 := @InpInt;
//    N_b := ReadProcessMemory( ProcHandle, Ptr1, @MidInt, 2, NumRed );
    N_b := ReadProcessMemory( ProcHandle, @InpInt, @MidInt, 2, NumRed );
    N_IAdd( 'ReadProcessMemory: ' + IntToHex( Integer(N_b), 8 ) );
    N_IAdd( 'MidInt: ' + IntToHex( MidInt, 8 ) ); // should be $0000F2F3

    Inc( MidInt );
    NumRed := 0;

    // Write from MidInt into OutInt two bytes (OutInt in another (ProcHandle) AdrSpace)
    N_b := WriteProcessMemory( ProcHandle, @OutInt, @MidInt, 2, NumRed );
    N_IAdd( 'WriteProcessMemory: ' + IntToHex( Integer(N_b), 8 ) );
    N_IAdd( 'OutInt: ' + IntToHex( OutInt, 8 ) ); // should be $7FFFF2F4

    N_IAdd( '' );
    N_b := CloseHandle( ProcHandle );
    N_IAdd( 'CloseHandle: ' + IntToHex( Integer(N_b), 8 ) );
  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActionRWProcMem1

//************************************************** N_UDATestMemTextFragms ***
//  TN_MemTextFragms object test
//
// (for using in TN_UDAction under Action Name "MemTextFragms")
//
procedure N_UDATestMemTextFragms( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  MemTextFragms: TN_MemTextFragms;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin
    MemTextFragms := TN_MemTextFragms.CreateFromVFile( '(#OtherFiles#)N_Tree\HelpComps1.txt' );

    MemTextFragms.AddFromVFile( '(##Exe#)Proj_VRE.ini' );
    MemTextFragms.AddFromVFile( '(#OtherFiles#)N_Tree\HelpComps1.txt' ); // add same file again
    MemTextFragms.AddFragm( 'NewTestFragment', '123'#$D#$A'456' ); // add two rows Fragment

//    MemTextFragms.MTFIsWinIni := False; // set "own format" flag
    MemTextFragms.MTFIsWinIni := True; // set "Win ini file format" flag
    MemTextFragms.SaveToVFile( 'c:\aa3.txt', MemTextFragms.MTCreateParams );
    MemTextFragms.Free();
  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_UDATestMemTextFragms

procedure N_UDATestStrPos( APParams: TN_PCAction; AP1, AP2: Pointer );
// StrPos variants Time Test
//
// (for using in TN_UDAction under Action Name 'TestStrPos' )
var
  i: integer;
  SubStr: string;
begin
  with APParams^ do
  begin
    N_IAdd( 'N_UDATestStrPos' );
    N_IAdd( '' );
    N_i := 2;

    for i := 1 to Length(CAStr1) do
    begin
      SubStr := Copy( CAStr1, 1, i );
      N_IAdd( 'Substr Length = ' + IntToStr(i) + ', Str Length = ' + IntToStr(Length(CAStr2)) );

      N_T1.Start();
      N_i1 := Pos( SubStr, CAStr2 );
      N_T1.SS( 'Pos   ' + IntToStr(N_i1) );

      N_T1.Start();
      N_i1 := PosEx( SubStr, CAStr2, N_i );
      N_T1.SS( 'PosEx ' + IntToStr(N_i1) );

      N_T1.Start();
      N_i1 := N_StrPos( SubStr, CAStr2, N_i );
      N_T1.SS( 'N_StrPos ' + IntToStr(N_i1) );

      N_IAdd( '' );
    end; // for i := 1 to Length(CAStr1) do
  end; // with APParams^ do
end; // procedure N_UDATestStrPos

procedure N_UDATestValue2Str( APParams: TN_PCAction; AP1, AP2: Pointer );
// Value to String convertion tests and Strings handling statements
//
// (for using in TN_UDAction under Action Name 'TestValue2Str' )
var
  i, RetCode: integer;
  b1: byte;
  Str3, Str1, Str2: string;
  SStr: Shortstring;
  PBuf: PChar;
begin
  with APParams^ do
  begin
    N_IAdd( 'N_UDATestValue2Str' );
    N_IAdd( '' );

    {
    F1: TextFile;

    AssignFile(F1, 'C:\aa.txt');
    Reset(F1);
    Read(F1, N_d1, N_d2);
    CloseFile(F1);
    }

    //***** Several examples of using Val procedure (for Viewing in debugger)

    Str1 := '257';
    Val( Str1, b1, RetCode ); // no error
    N_i := b1; // to avoid warning

    Str1 := '12.3';
    Val( Str1, N_d, RetCode ); // RetCode=0
    Val( Str1, N_i, RetCode ); // RetCode=3

    Str1 := '1234,5';
    PBuf := @Str1[1];
    N_s := ' ';
    N_s[1] := N_WinFormatSettings.DecimalSeparator;
    N_d := StrToFloat( PBuf, N_WinFormatSettings );

    Str1 := ' 1234,6 ';
    PBuf := @Str1[1];
    N_d := StrToFloat( PBuf, N_WinFormatSettings );

    Str1 := ' 1234,7  ';
    PBuf := @Str1[1];
    N_d := StrToFloat( PBuf, N_WinFormatSettings );

    Str1 := '1234.5 ';
    Val( Str1, N_d, RetCode );    // N_d = 12345
    Val( Str1[1], N_d, RetCode ); // N_d = 1, RetCode=0
    Val( Str1[2], N_d, RetCode ); // N_d = 2, RetCode=0
    PBuf := @Str1[1];
    Val( PBuf^, N_d, RetCode );   // N_d = 1, RetCode=0
    Val( PBuf, N_d, RetCode );    // N_d = 12345
    Str1[3] := Char(0);
    Val( PBuf, N_d, RetCode );    // N_d = 12, RetCode=0

    Str1 := 'N';
    Val( Str1, N_d, RetCode );
    Str1 := '   ';
    Val( Str1, N_d, RetCode ); // RetCode=4
    Str1 := ' 22 ';
    Val( Str1, N_d, RetCode ); // RetCode=4
    Str1 := #$D#$A'55Z';
    Val( Str1, N_d, RetCode ); // RetCode=1
    Str1 := '23 ';
    Val( Str1, N_d, RetCode );
    Str1 := ' N';
    Val( Str1, N_d, RetCode );
    Str1 := '25N 456';
    Val( Str1, N_d, RetCode );
    Str1 := '';
    Val( Str1, N_d, RetCode );

    N_d  := 12.34;
    N_d2 := 10.34;

    Str( N_d, SStr );
    Str1 := String(SStr);
    Str( N_d:7, SStr );
    Str1 := String(SStr);
    N_i := 2;
    Str( N_d:7:N_i, SStr );
    Str1 := String(SStr);
    Str( N_d:0:N_i, SStr );
    Str1 := String(SStr);

    Str( N_d:7:2, SStr );
    Str1 := String(SStr);
    Str( N_d:7:3, SStr );
    Str1 := String(SStr);
    Str( N_d:7:4, SStr );
    Str1 := String(SStr);
    Str( N_d:7:5, SStr );
    Str1 := String(SStr);
    Str( N_d:7:6, SStr );
    Str1 := String(SStr);
    Str( N_d:4:2, SStr );
    Str1 := String(SStr);
    Str( N_d:5:2, SStr );
    Str1 := String(SStr);
    Str( N_d:6:2, SStr );
    Str1 := String(SStr);
    Str( N_d:10:2, SStr );
    Str1 := String(SStr);
    N_i := 2;
    Str( N_d:10:N_i, SStr );
    Str1 := String(SStr);
    Str( N_d:N_i:N_i, SStr );
    Str1 := String(SStr);

    //******************************* Time Tests

    N_T1.Start();
    Str1 := Format( '%7.2f', [N_d] );
    N_T1.SS( 'Format 1 Double(1)' );

    N_T1.Start();
    Str1 := Format( '%7.2f', [N_d] );
    N_T1.SS( 'Format 1 Double(2)' );

    N_T1.Start();
    Str( N_d:7:2, SStr );
    Str1 := String(SStr);
    N_T1.SS( 'Str 1 Double(1)' );

    N_T1.Start();
    Str( N_d:7:2, SStr );
    Str1 := String(SStr);
    N_T1.SS( 'Str 1 Double(2)' );

    N_T1.Start();
    Str1 := Format( '%7.2f %7.2f', [N_d,N_d2] );
    N_T1.SS( 'Format 2 Double(1)' );

    N_T1.Start();
    Str( N_d:7:2, SStr );
    Str1 := String(SStr);
    Str( N_d2:7:2, SStr );
    Str2 := String(SStr);
    Str1 := Str1 + ' ' + Str2;
    N_T1.SS( 'Str 2 Double(1)' );

    N_T1.Start();
    Str1 := Format( '%7.2f %7.2f', [N_d,N_d2] );
    N_T1.SS( 'Format 2 Double(2)' );

    N_T1.Start();
    Str( N_d:7:2, SStr );
    Str1 := String(SStr);
    Str( N_d2:7:2, SStr );
    Str2 := String(SStr);
    Str1 := Str1 + ' ' + Str2;
    N_T1.SS( 'Str 2 Double(2)' );

    N_T1.Start();
    Str1 := Format( '%7.2f %7.2f %7.2f', [N_d,N_d2,N_d] );
    N_T1.SS( 'Format 3 Double(1)' );

    N_T1.Start();
    Str1 := Format( '%7.2f %7.2f %7.2f %7.2f', [N_d,N_d2,N_d,N_d2] );
    N_T1.SS( 'Format 4 Double(1)' );

    N_T1.Start();
    Str1 := Format( '%7.2f %7.2f %7.2f %7.2f %7.2f', [N_d,N_d2,N_d,N_d2,N_d] );
    N_T1.SS( 'Format 5 Double(1)' );

    N_i := 12;
    N_T1.Start();
    Str1 := Format( '%d', [N_i] );
    N_T1.SS( 'Format 1 Int2d(1)' );
    N_i := 13;
    N_T1.Start();
    Str1 := Format( '%d', [N_i] );
    N_T1.SS( 'Format 1 Int2d(2)' );

    N_i := 123456;
    N_T1.Start();
    Str1 := Format( '%d', [N_i] );
    N_T1.SS( 'Format 1 Int6d(1)' );
    N_i := 123457;
    N_T1.Start();
    Str1 := Format( '%d', [N_i] );
    N_T1.SS( 'Format 1 Int6d(2)' );

    N_i := 12;
    N_T1.Start();
    Str1 := Format( '%d %d', [N_i,N_i] );
    N_T1.SS( 'Format 2 Int2d' );

    N_i := 12;
    N_T1.Start();
    Str1 := Format( '%d %d %d', [N_i,N_i,N_i] );
    N_T1.SS( 'Format 3 Int2d' );

    N_i := 123456;
    N_T1.Start();
    Str1 := Format( '%d %d %d', [N_i,N_i,N_i] );
    N_T1.SS( 'Format 3 Int6d' );

    N_i := 123456;
    N_T1.Start();
    Str1 := Format( '%d %d %d %d', [N_i,N_i,N_i,N_i] );
    N_T1.SS( 'Format 4 Int6d' );

    N_d := 12.34;
    N_d2 := 12.35;
    N_T1.Start();
    N_i := Round(N_d*10);
    N_T1.SS( 'Round * 10' );

    N_T1.Start();
    N_i  := Round(N_d*10);
    N_i2 := Round(N_d2*10);
    N_T1.SS( '2*Round * 10' );

    N_T1.Start();
    N_i  := Round(N_d*10);
    N_i1 := Round(N_d2*10);
    N_i2 := Round(N_d*10);
    N_T1.SS( '3*Round * 10' );

    N_d := 12.34;
    N_T1.Start();
    N_i := Round(N_d*100);
    N_T1.SS( 'Round * 100' );

    N_T1.Start();
    Str( N_d:7:2, SStr );
    Str1 := String(SStr);
    Str( N_d2:7:2, SStr );
    Str2 := String(SStr);
    Str( N_d:7:2, SStr );
    Str1 := String(SStr);
    Str( N_d2:7:2, SStr );
    Str2 := String(SStr);
    N_T1.SS( '4*Str Double(1)' );

    N_IAdd( '' );

    //***** N_ScanDouble and Val
    Str3 := CAStr1;
    Str1 := N_ScanToken( Str3 );
    Str2 := N_ScanToken( Str3 );
    Str3 := CAStr1;

    N_T1.Start();
    N_d := N_ScanDouble( Str3 );
    N_T1.SS( 'ScanDouble 1' );
    N_T1.Start();
    N_d := N_ScanDouble( Str3 );
    N_T1.SS( 'ScanDouble 2' );

    Str1 := '77';
    Str2 := '1237';
    N_T1.Start();
    Val( Str1, N_i, RetCode );
    N_T1.SS( 'Val(int2) 1' );
    N_T1.Start();
    Val( Str2, N_i, RetCode );
    N_T1.SS( 'Val(int4) 2' );

    N_T1.Start();
    N_i := StrToInt(Str1);
    N_T1.SS( 'StrToInt 1' );

    Str1 := '77.1';
    Str2 := '12377.1';
    N_T1.Start();
    Val( Str1, N_d, RetCode );
    N_T1.SS( 'Val(dbl3) 1' );
    N_T1.Start();
    Val( Str2, N_d, RetCode );
    N_T1.SS( 'Val(dbl6) 2' );

    N_IAdd( '' );

    //***** Timer expenses (accuracy)
    N_T1.Start();
    N_T1.SS( 'Empty SS 1' );
    N_T1.Start();
    N_T1.SSS( 'Empty SS 2' );
    N_T1.SS( 'Empty SSS' );
    N_IAdd( '' );

    //***** Strings handling
    SetLength( Str1, 10 );
    N_T1.Start();
    SetLength( Str1, 3 );
    N_T1.SS( 'SetLength 3' );
    N_T1.Start();
    SetLength( Str1, 10 );
    N_T1.SS( 'SetLength 10' );
    N_T1.Start();
    SetLength( Str1, 10 );
    N_T1.SS( 'SetLength 10' );
    N_T1.Start();
    SetLength( Str1, 3 );
    N_T1.SS( 'SetLength 3' );
    N_T1.Start();
    SetLength( Str1, 3 );
    N_T1.SS( 'SetLength 3' );

    N_IAdd( '' );

    N_T1.Start();
    Str1 := DupeString( ' %.3f', 10 );
    N_T1.SS( 'DupeString 5*10' );
    N_T1.Start();
    Str1 := DupeString( ' %.3f', 10 );
    N_T1.SS( 'DupeString 5*10' );
    N_T1.Start();
    Str1 := DupeString( ' %.3f', 10 ) + '!!';
    N_T1.SS( 'DupeString 5*10 + 2' );
    N_T1.Start();
    Str1 := DupeString( ' %.3f', 10 ) + '!!';
    N_T1.SS( 'DupeString 5*10 + 2' );
    SetLength( Str1, 52 );
    N_T1.Start();
    Str1 := DupeString( ' %.3f', 10 ) + '!!';
    N_T1.SS( 'DupeString 5*10 + 2 (b)' );
    N_T1.Start();
    Str1 := 'aa' + DupeString( ' %.3f', 10 ) + 'zz';
    N_T1.SS( '2 + DupeString 5*10 + 2' );
    N_T1.Start();
    Str1 := DupeString( ' %.3f', 20 );
    N_T1.SS( 'DupeString 5*20' );

    N_IAdd( '' );

    Str1 := '123456789012';
    N_T1.Start();
    Str1 := 'abcd';
    N_T1.SS( 'Assign Str 12->4' );
    N_T1.Start();
    Str1 := 'abcdqwer';
    N_T1.SS( 'Assign Str 4->8' );
    N_T1.Start();
    Str1 := 'ABcdqweR';
    N_T1.SS( 'Assign Str 8->8' );

    Str1 := '123456789012';
    N_T1.Start();
    Str1 := 'abcd';
    N_T1.SS( 'Assign Str 12->4' );
    N_T1.Start();
    Str1 := 'abcdqwer';
    N_T1.SS( 'Assign Str 4->8' );
    N_T1.Start();
    Str1 := 'ABcdqweR';
    N_T1.SS( 'Assign Str 8->8' );

    Str1 := '0123456789012345678901234567890123456789';
    N_T1.Start();
    Str1 := 'abcd';
    N_T1.SS( 'Assign Str 40->4' );
    N_T1.Start();
    Str1 := '_12345678901234567890123456789012345678_';
    N_T1.SS( 'Assign Str 4->40' );
    N_T1.Start();
    Str1 := 'a12345678901234567890123456789012345678z';
    N_T1.SS( 'Assign Str 40->40' );

    Str1 := '123456789012';
    SetLength( Str2, 10 );
    N_b := AnsiStartsStr( 'AA', Str1 );

    Str1 := 'a12345678901234567890123456789012345678 z';
    N_T1.Start();
    i := 1;
    while i <= 40 do
    begin
      if Str1[i] = ' ' then
      begin
        Str1[i] := Char( 0 );
        Break;
      end;
      Inc( i );
    end;
    N_T1.SS( 'while(40) 1' );

    Str1 := 'a12345678901234567890123456789012345678 z';
    PBuf := @Str1[1];
    N_T1.Start();
    while PBuf^ > ' ' do Inc(PBuf);
    N_T1.SS( 'while(40) 2' );

    N_IAdd( '' );
  end; // with APParams^ do
end; // procedure N_UDATestValue2Str

procedure N_UDATestTmp1( APParams: TN_PCAction; AP1, AP2: Pointer );
// Temporary Test #1
//
// (for using in TN_UDAction under Action Name 'TestTmp1' )
var
  i, BufSize, ComprSize, InpSize, OutSize: integer;
  a, b, c, d, F, F0, X, X0, FP0, FX0, FPX0: double;
  InpStr, OutStr, FName: string;
  GMS: TN_GivenMemStream;
  Buf: TN_BArray;
  ResSL: TStringList;
  Fl1, Fl2: TN_MEWordFlags;
begin
  with APParams^ do
  begin
    N_IAdd( 'N_UDATestTmp1' );
    N_IAdd( '' );

    N_i := 1234567890;
    N_BytesToMemIni( 'aa1', 'aa2', @N_i,  4 );
    N_MemIniToBytes( 'aa1', 'aa2', @N_i1, 4 );

    N_i := 12345;
    N_BytesToMemIni( 'aa1', 'aa2', @N_i,  4 );
    N_MemIniToBytes( 'aa1', 'aa2', @N_i1, 4 );

    Fl1 := [];
    N_SPLValToMemIni( 'aa1', 'aa2', Fl1, N_SPLTC_MEWordFlags );
    Fl2 := [mewfUseVBA, mewfUseWin32API];
    N_MemIniToSPLVal( 'aa1', 'aa2', Fl2, N_SPLTC_MEWordFlags );

    Fl1 := [mewfUseVBA, mewfUseWin32API];
    N_SPLValToMemIni( 'aa1', 'aa2', Fl1, N_SPLTC_MEWordFlags );
    Fl2 := [];
    N_MemIniToSPLVal( 'aa1', 'aa2', Fl2, N_SPLTC_MEWordFlags );

    Exit;

  FName := K_ExpandFileName( CAFName1 );

  InpSize := 3*CAIRect.Left;
  InpStr := DupeString( 'asd', CAIRect.Left );

  BufSize := InpSize + 10000;
  SetLength( Buf, BufSize );

  ComprSize := N_CompressMem( @InpStr[1], InpSize, @Buf[0], BufSize, 2 );

  OutSize := N_GetUncompressedSize( @Buf[0], BufSize );
  SetLength( OutStr, OutSize );
  N_i := N_DecompressMem( @Buf[0], ComprSize, @OutStr[1], OutSize );

  Exit;

  GMS := TN_GivenMemStream.Create( @Buf[0], BufSize );
  N_i := 127;
  GMS.Seek( 2, soFromBeginning );
  GMS.Write( N_i, 4 );
  GMS.Write( N_i, 4 );
  GMS.Seek( 6, soFromBeginning );
  GMS.Read( N_i1, 4 );

  GMS.Free;
  Exit;




    F0  := 1;
    X0  := 10;
    FP0 := 0.1;
    FX0 := 4;
    FPX0 := 0.2;

//    a := (2*F0  - 2*FX0 + FP0*X0 + FPX0*X0) / (X0*X0*X0);
//    b := (3*FX0 - 3*F0  - 3*FP0*X0  + FP0*X0 - FPX0*X0) / (X0*X0);

    a := ( 2*(F0 - FX0) + X0*(FP0 + FPX0) ) / (X0*X0*X0);
    b := ( 3*(FX0 - F0) - X0*( 2*FP0  + FPX0) ) / (X0*X0);
    c := FP0;
    d := F0;

    for i := 0 to 11 do
    begin
      X := i* 1.0;
      F := d + X*(c + X*(b + a*X));
      N_IAdd( Format( 'x=%.2f, f=%.3f', [X,F] ) );
    end;

    Exit;

    N_s := '123456123456';
    N_ReplaceEQSSubstr( N_s, '23',  'ab' );
    N_s := '123456123456';
    N_ReplaceEQSSubstr( N_s, '123', 'abc' );
    N_s := '123456123456';
    N_ReplaceEQSSubstr( N_s, '6',   'a' );

    ResSL := TStringList.Create();
    InpStr := CAStr1;
    N_ReplaceEQSSubstr( InpStr, N_StrCRLF, '  ' ); // prepare Input String
    ResSL.Text := N_SplitString2( InpStr, CAIRect.Left );

    for i := 0 to ResSL.Count-1 do
      N_IAdd( Format( '%.03d: %s', [i,ResSL[i]] ) );

    ResSL.Free;
    Exit;

    N_s := '123456';
    N_ReplaceHTMLBR( N_s, 'asdf' );

    N_s := '123456';
    N_ReplaceHTMLBR( N_s, 'asdf' );
    N_s := '12<br>3456';
    N_ReplaceHTMLBR( N_s, 'Asdf' );
    N_s := '1234<BR>56';
    N_ReplaceHTMLBR( N_s, 'asdF' );
    N_s := '<Br>123<bR>456<BR>';
    N_ReplaceHTMLBR( N_s, 'asdf' );
    N_s := '123456<bR>';
    N_ReplaceHTMLBR( N_s, 'asdf' );
  end; // with APParams^ do
end; // procedure N_UDATestTmp1

procedure N_UDATestStringList( APParams: TN_PCAction; AP1, AP2: Pointer );
// StringList variants Time Test
//
// (for using in TN_UDAction under Action Name 'TestStringList' )
var
  SL1: TStringList;
  HSL1: THashedStringList;
begin
  with APParams^ do
  begin
    N_IAdd( 'N_UDATestStringList' );
    N_IAdd( '' );
    HSL1 := THashedStringList.Create();
    HSL1.Add( 'Name1=Value1' );
    HSL1.Add( 'Name2=Value22' );
    HSL1.Add( 'Name3=Value3333' );
    HSL1.Add( 'Name4=Value4444' );
    HSL1.Add( 'BName1=Value1' );
{
    HSL1.Add( 'BName2=Value22' );
    HSL1.Add( 'BName3=Value3333' );
    HSL1.Add( 'BName4=Value4444' );
    HSL1.Add( 'AName1=Value1' );
    HSL1.Add( 'AName2=Value22' );
    HSL1.Add( 'AName3=Value3333' );
    HSL1.Add( 'AName4=Value4444' );
}
    SL1 := TStringList.Create();
    SL1.Add( 'Name1=Value1' );
    SL1.Add( 'Name2=Value22' );
    SL1.Add( 'Name3=Value3333' );
    SL1.Add( 'Name4=Value4444' );
    SL1.Add( 'BName1=Value1' );
{
    SL1.Add( 'BName2=Value22' );
    SL1.Add( 'BName3=Value3333' );
    SL1.Add( 'BName4=Value4444' );
    SL1.Add( 'AName1=Value1' );
    SL1.Add( 'AName2=Value22' );
    SL1.Add( 'AName3=Value3333' );
    SL1.Add( 'AName4=Value4444' );
}
    N_IAdd( 'SL is NOT sorted' );

    N_T1.Start();
    N_i1 := HSL1.IndexOfName( 'Name3' );
    N_s := HSL1.ValueFromIndex[N_i1];
    N_T1.SS( 'HSL:Name3 1' );

    N_T1.Start();
    N_i1 := HSL1.IndexOfName( 'Name3' );
    N_s := HSL1.ValueFromIndex[N_i1];
    N_T1.SS( 'HSL:Name3 2' );

    N_T1.Start();
    N_i1 := HSL1.IndexOfName( 'BName1' );
    N_s := HSL1.ValueFromIndex[N_i1];
    N_T1.SS( 'HSL:BName1' );

    N_T1.Start();
    N_s := HSL1.Values[ 'Name3' ];
    N_T1.SS( 'HSL:Name3' );

    N_T1.Start();
    N_s := SL1.Values[ 'Name3' ];
    N_T1.SS( 'SL:Name3' );

    N_T1.Start();
    N_s := SL1.Values[ 'BName1' ];
    N_T1.SS( 'SL:BName1' );

    N_T1.Start();
    N_i1 := HSL1.IndexOfName( 'BName1' );
    N_s := HSL1.ValueFromIndex[N_i1];
    N_T1.SS( 'HSL:BName1' );

    N_T1.Start();
    N_s := SL1.Values[ 'BName1' ];
    N_T1.SS( 'SL:BName1' );

    N_T1.Start();
    N_i1 := HSL1.IndexOfName( 'BName1' );
    N_s := HSL1.ValueFromIndex[N_i1];
    N_T1.SS( 'HSL:BName1' );

    N_T1.Start();
    N_s := SL1.Values[ 'BName1' ];
    N_T1.SS( 'SL:BName1' );

    SL1.Sort(); //*************************** Sort SL1
    N_IAdd( 'Now SL is SORTED' );

    N_T1.Start();
    N_s := SL1.Values[ 'Name3' ];
    N_T1.SS( 'SL:Name3 1' );

    N_T1.Start();
    N_s := SL1.Values[ 'Name3' ];
    N_T1.SS( 'SL:Name3 2' );

    N_T1.Start();
    SL1.Find( 'Name3', N_i );
    N_s := SL1.ValueFromIndex[ N_i ];
    N_T1.SS( 'SL:Name3 Find' );

    N_T1.Start();
    SL1.Find( 'BName1', N_i );
    N_s := SL1.ValueFromIndex[ N_i ];
    N_T1.SS( 'SL:BName1 Find' );

    N_T1.Start();
    N_s := SL1.Values[ 'BName1' ];
    N_T1.SS( 'SL:BName1' );

    N_T1.Start();
    N_i1 := HSL1.IndexOfName( 'BName1' );
    N_s := HSL1.ValueFromIndex[N_i1];
    N_T1.SS( 'HSL:BName1' );

      N_T1.Start();
    N_s := SL1.Values[ 'BName1' ];
    N_T1.SS( 'SL:BName1' );

    HSL1.Free;
    SL1.Free;
  end; // with APParams^ do
end; // procedure N_UDATestStringList

procedure N_UDATestPrepRoot( APParams: TN_PCAction; AP1, AP2: Pointer );
// PrepRoot Test:
// Change Self mm Size by two values, given in CAParStr2
//
// (for using in TN_UDAction under Action Name 'TestDrawUserRects - TestPrepRoot' )
var
  SizeXmm, SizeYmm: double;
  Str: string;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^ do
  begin
//    N_IAdd( 'N_UDATestPrepRoot' );

    Str := CAParStr2;
    if Str = '' then Str := '100 100'; // a precaution
    SizeXmm := N_ScanDouble( Str );
    SizeYmm := N_ScanDouble( Str );

    with UDActionComp.PDP()^.CCoords do
    begin
      SRSize := FPoint( SizeXmm, SizeYmm );
      CompUCoords := FRect( 0, 0, SizeXmm, SizeYmm );
    end; // with UDActionComp.PSP()^.CCoords do

  end; // with APParams^ do
end; // procedure N_UDATestPrepRoot

procedure N_UDATestDrawUserRects( APParams: TN_PCAction; AP1, AP2: Pointer );
// Draw UserRects for PrepRoot Test:
// Draw Rects in User coords (they same as mm)
//
// (for using in TN_UDAction under Action Name 'TestDrawUserRects' )
var
  ix, iy, NX, NY: integer;
  Str: string;
  Sizemm: TFPoint;
  UBase: TDPoint;
  URect: TFRect;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.NGCont.DstOCanv do
  begin
//    N_IAdd( 'N_UDATestDrawUserRects' );
//    N_IAdd( '' );

    // calc NX, NY - number of fully "visible" rects
    Sizemm := UDActionComp.PDP()^.CCoords.SRSize;
    NX := Round(Floor( Sizemm.X/35 )); // 5mm Gap + 30mm width
    NY := Round(Floor( Sizemm.Y/20 )); // 5mm Gap + 15mm height

    for ix := 0 to NX-1 do
    for iy := 0 to NY-1 do
    begin
      SetPenAttribs( 0 );
      SetBrushAttribs( $CC00CC );
      N_SetNFont( CAFont, UDActionComp.NGCont.DstOCanv );
      SetFontAttribs( $00AA00, $FFFFFF );

      UBase := DPoint( 5 + ix*35, 5 + iy*20 );
      URect := FRect( UBase.X, UBase.Y, UBase.X+30, UBase.Y+15 );
      DrawUserRect( URect );

      Str := Format( 'X=%d, Y=%d', [ix,iy] );
      DrawUserString( UBase, FPoint(2,2), N_ZFPoint, Str );
    end; // for ix, iy ... do

  end; // with APParams^ do
end; // procedure N_UDATestDrawUserRects

procedure N_UDATestAddSearchGroup( APParams: TN_PCAction; AP1, AP2: Pointer );
// Add Search Group to current Rast1Frame:
//
// (for using in TN_UDAction under Action Name 'AddSearchGroup' )
var
  i: integer;
  SGC: TN_SGMLayers;
  Tst1RFA: TN_Tst1RFA;
begin
  if N_ActiveRFrame = nil then Exit;

  N_RFAClassRefs[N_ActTst1RFA] := TN_Tst1RFA;

  with APParams^ do
  begin
    SGC := TN_SGMLayers.Create( N_ActiveRFrame );
    N_ActiveRFrame.RFSGroups.Add( SGC );

    SGC.GName := 'TstSGC';
    SGC.PixSearchSize  := 0;
    SGC.UserSearchSize := 2;
    SetLength( SGC.SComps, CAUDBaseArray.ALength() );

    for i := 0 to High(SGC.SComps) do
    with SGC.SComps[i] do
    begin
      SComp := TN_PUDCompVis(CAUDBaseArray.P(i))^;
      SFlags := $7;
    end;

    Tst1RFA := TN_Tst1RFA(SGC.SetAction( N_ActTst1RFA, $200, -1, 0 ));
    Tst1RFA.Itmp := 20;
  end; // with APParams^ do
end; // procedure N_UDATestAddSearchGroup

procedure N_StrCmpTest1(); // not global, used only in N_UDATestPChar
var
  Str1: string;
begin
  Str1 := 'qwertyuioplkjhgfdsazxcvbnmqwertyuioplkjhgfdsazxcvbnmqwertyuioplkjhgfdsazxcvbnm';
  N_i := Strlicomp( @Str1[1], @N_s2[1], 2 );
end; // procedure N_StrCmpTest1();

procedure N_StrCmpTest2(); // not global, used only in N_UDATestPChar
begin
  N_i := Strlicomp( @N_s1[1], @N_s2[1], 2 );
end; // procedure N_StrCmpTest2();

procedure N_StrCmpTest3(); // not global, used only in N_UDATestPChar
const Str1: string = 'qwertyuioplkjhgfdsazxcvbnmqwertyuioplkjhgfdsazxcvbnmqwertyuioplkjhgfdsazxcvbnm';
begin
  N_i := Strlicomp( @Str1[1], @N_s2[1], 2 );
end; // procedure N_StrCmpTest3();

procedure N_StrCmpTest4(); // not global, used only in N_UDATestPChar
const Str1: string = 'qwertyuioplkjhgfdsazxcvbnmqwertyuioplkjhgfdsazxcvbnmqwertyuioplkjhgfdsazxcvbnm';
begin
//  N_i := Strlicomp( Pointer(Str1), Pointer(N_s2), 2 ); // error in Delphi 2010
end; // procedure N_StrCmpTest4();

procedure N_StrCmpTest5(); // not global, used only in N_UDATestPChar
begin
//  N_i := Strlicomp( Pointer(N_s1), Pointer(N_s2), 2 ); // error in Delphi 2010
end; // procedure N_StrCmpTest5();

procedure N_UDATestPChar( APParams: TN_PCAction; AP1, AP2: Pointer );
// PChar assignment Test:
//
// (for using in TN_UDAction under Action Name TestPChar )
var
  i, NTimes: integer;
  PChar1, PChar2: PChar;
  P1, P2: pointer;
  Str1, Str2: string;
begin
  N_s1 := 'qwertyuioplkjhgfdsazxcvbnmqwertyuioplkjhgfdsazxcvbnmqwertyuioplkjhgfdsazxcvbnm';
  N_s2 := '12';
  NTimes := 1;

  N_IAdd( '' );
  N_IAdd( '    N_StrCmpTest1' );
  N_T1.Start();
  for i := 1 to NTimes do
  begin
    N_StrCmpTest1();
  end;
  N_T1.SS( 'N_StrCmpTest1' );

  N_IAdd( '    N_StrCmpTest2' );
  N_T1.Start();
  for i := 1 to NTimes do
  begin
    N_StrCmpTest2();
  end;
  N_T1.SS( 'N_StrCmpTest2' );

  N_IAdd( '    N_StrCmpTest3' );
  N_T1.Start();
  for i := 1 to NTimes do
  begin
    N_StrCmpTest3();
  end;
  N_T1.SS( 'N_StrCmpTest3' );

  N_IAdd( '    N_StrCmpTest4' );
  N_T1.Start();
  for i := 1 to NTimes do
  begin
    N_StrCmpTest4();
  end;
  N_T1.SS( 'N_StrCmpTest4' );

  N_IAdd( '    N_StrCmpTest5' );
  N_T1.Start();
  for i := 1 to NTimes do
  begin
    N_StrCmpTest5();
  end;
  N_T1.SS( 'N_StrCmpTest5' );

  N_IAdd( '' );
  N_IAdd( '    N_StrCmpTest1' );
  N_T1.Start();
  for i := 1 to NTimes do
  begin
    N_StrCmpTest1();
  end;
  N_T1.SS( 'N_StrCmpTest1' );

  N_IAdd( '    N_StrCmpTest2' );
  N_T1.Start();
  for i := 1 to NTimes do
  begin
    N_StrCmpTest2();
  end;
  N_T1.SS( 'N_StrCmpTest2' );

  N_IAdd( '    N_StrCmpTest3' );
  N_T1.Start();
  for i := 1 to NTimes do
  begin
    N_StrCmpTest3();
  end;
  N_T1.SS( 'N_StrCmpTest3' );

  N_IAdd( '    N_StrCmpTest4' );
  N_T1.Start();
  for i := 1 to NTimes do
  begin
    N_StrCmpTest4();
  end;
  N_T1.SS( 'N_StrCmpTest4' );

  N_IAdd( '    N_StrCmpTest5' );
  N_T1.Start();
  for i := 1 to NTimes do
  begin
    N_StrCmpTest5();
  end;
  N_T1.SS( 'N_StrCmpTest5' );

  Exit;


  Str1 := 'asd';
  SetLength( Str1, 10000000 );
  N_i := integer(Str1[1]);

  // PChar1 points to Str1 itself, not to it's copy
  PChar1 := @(Str1[1]);
  N_i1 := integer(PChar1^);
  Str1[1] := 'b';
  N_i1 := integer(Str1[1]);
  N_i1 := integer(PChar1^);

  // PChar(Str1) is the same as @(Str1[1])
  N_i := integer(PChar1);
  PChar2 := PChar(Str1); // casting with PChar causes internal call to _LStrToPChar
  N_i1 := integer(PChar2);

  // casting with Pointer causes no internal call
  P1 := Pointer(Str1); // no internal call
  PChar2 := P1;        // no internal call
  N_i  := integer(P1);
  N_i1 := integer(PChar2);

  Str2 := '';
  P2 := Pointer(Str2); // P2 = nil
//  PChar2 := P2;
//  PChar2 := PChar(P2);
  N_i := integer(P2);  // N_i = 0
  // N_i := integer(PChar2^); // error! (reading nil pointer)

  PChar2 := PChar(Str2);
  N_i2 := integer(PChar2);  // N_i2 <> 0
  N_i1 := integer(PChar2^); // N_i1 = 0

  i := 0;
//  PChar1 := Pointer(@i);

  //***** Execution time test

  N_IAdd( '    Pass 1 x 100' ); //*** Pass 1 x 100
  N_T1.Start();
  for i := 1 to 100 do
  begin
    Str1[1] := char(i);
    PChar1 := Pointer(@i);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( 'Pointer(@i)' );

  N_T1.Start();
  for i := 1 to 100 do
  begin
    Str1[1] := char(i);
    PChar1 := @(Str1[1]);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( '@(Str1[1])' );

  N_T1.Start();
  for i := 1 to 100 do
  begin
    Str1[1] := char(i);
    PChar1 := PChar(Str1);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( 'PChar(Str1)' );

  N_T1.Start();
  for i := 1 to 100 do
  begin
    Str1[1] := char(i);
    PChar1 := Pointer(Str1);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( 'Pointer(Str1)' );

  N_IAdd( '    Pass 2 x 100' ); //*** Pass 2 x 100
  N_T1.Start();
  for i := 1 to 100 do
  begin
    Str1[1] := char(i);
    PChar1 := Pointer(@i);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( 'Pointer(@i)' );

  N_T1.Start();
  for i := 1 to 100 do
  begin
    Str1[1] := char(i);
    PChar1 := @(Str1[1]);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( '@(Str1[1])' );

  N_T1.Start();
  for i := 1 to 100 do
  begin
    Str1[1] := char(i);
    PChar1 := PChar(Str1);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( 'PChar(Str1)' );

  N_T1.Start();
  for i := 1 to 100 do
  begin
    Str1[1] := char(i);
    PChar1 := Pointer(Str1);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( 'Pointer(Str1)' );


  N_IAdd( '    Pass 3 x 200' ); //*** Pass 3 x 200
  N_T1.Start();
  for i := 1 to 200 do
  begin
    Str1[1] := char(i);
    PChar1 := Pointer(@i);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( 'Pointer(@i)' );

  N_T1.Start();
  for i := 1 to 200 do
  begin
    Str1[1] := char(i);
    PChar1 := @(Str1[1]);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( '@(Str1[1])' );

  N_T1.Start();
  for i := 1 to 200 do
  begin
    Str1[1] := char(i);
    PChar1 := PChar(Str1);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( 'PChar(Str1)' );

  N_T1.Start();
  for i := 1 to 200 do
  begin
    Str1[1] := char(i);
    PChar1 := Pointer(Str1);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( 'Pointer(Str1)' );


  N_IAdd( '    Pass 4 x 200' ); //*** Pass 4 x 200
  N_T1.Start();
  for i := 1 to 200 do
  begin
    Str1[1] := char(i);
    PChar1 := Pointer(@i);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( 'Pointer(@i)' );

  N_T1.Start();
  for i := 1 to 200 do
  begin
    Str1[1] := char(i);
    PChar1 := @(Str1[1]);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( '@(Str1[1])' );

  N_T1.Start();
  for i := 1 to 200 do
  begin
    Str1[1] := char(i);
    PChar1 := PChar(Str1);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( 'PChar(Str1)' );

  N_T1.Start();
  for i := 1 to 200 do
  begin
    Str1[1] := char(i);
    PChar1 := Pointer(Str1);
    if integer(PChar1^) <> i then // error
      N_WarnByMessage( 'Error!' );
  end;
  N_T1.SS( 'Pointer(Str1)' );

end; // procedure N_UDATestPChar

procedure N_UDATestTWAIN1( APParams: TN_PCAction; AP1, AP2: Pointer );
// TWAIN1 Test:
//
// (for using in TN_UDAction under Action Name TWAIN1 )
begin
// working project is D:\Downloads\TWAIN\twain19\Demos\TwainExample.dpr
end; // procedure N_UDATestTWAIN1

procedure N_UDATestMapTools( APParams: TN_PCAction; AP1, AP2: Pointer );
// MapTools Test: test N_CreateRasterByComp procedure
//  CAUDBase1       - Comp to execute
//  CAUDBase2       - CObjRoot for creating HTML Map
//  CAFRect         - Needed User Rect
//  CAIRect.TopLeft - APixSize
//  CAIRect.Right   - CDimInd for getting Codes for CObj Items
//  CAFName1        - resulting Raster FileName
//
// (for using in TN_UDAction under Action Name TestMapTools )
var
  MT: TN_MapToolsObj;
  TmpP: TPoint;
begin
  with APParams^ do
  begin
    MT := TN_MapToolsObj.Create;
    MT.AddCObjItemRefs( CAUDBase2.DirChild( 0 ), CAIRect.Right );
    MT.AddCObjItemRefs( CAUDBase2.DirChild( 1 ), CAIRect.Right );
    MT.CreateU2PCoefs( CAFRect, CAIRect.TopLeft );
    MT.CreateRasterMap( TN_UDCompVis(CAUDBase1), CAFName1 );

    N_SL.Clear;
    N_SL.Add( MT.CreateHTMLMapItem( 46, 0, 2 ) ); // Дмитров
    N_SL.Add( MT.CreateHTMLMapItem( 44, 0, 2 ) ); // Волоколамск
    N_SL.Add( MT.CreateHTMLMapItem( 61, 0, 2 ) ); // Коломна
    N_SL.Add( MT.CreateHTMLMapItem( 53, 0, 2 ) ); // Зарайск

    TmpP := N_AffConvD2IPoint( DPoint(2.01,-32.59), MT.MTU2P );
    with TmpP do N_SL.Add( Format( '%d, %d', [X,Y] ));

    TmpP := N_AffConvD2IPoint( DPoint(36.19,-0.01), MT.MTU2P );
    with TmpP do N_SL.Add( Format( '%d, %d', [X,Y] ));

    N_SL.Add( N_RectToStr(MT.MTMapPixRect) );
    N_SL.Add( N_RectToStr(MT.MTMapUCoords) );

{
SHAPE=CIRCLE COORDS="94,52,2"
SHAPE=CIRCLE COORDS="35,72,2"
SHAPE=CIRCLE COORDS="139,134,2"
SHAPE=CIRCLE COORDS="143,156,2"

SHAPE=CIRCLE COORDS="94,47,5"
SHAPE=CIRCLE COORDS="35,69,10"
SHAPE=CIRCLE COORDS="139,138,10"
SHAPE=CIRCLE COORDS="143,162,10"

<AREA SHAPE=CIRCLE COORDS="94,47,5" Title="Дмитров" Alt="Дмитров"  HREF=46 >
<AREA SHAPE=CIRCLE COORDS="35,69,5" Title="Волоколамск" Alt="Волоколамск"  HREF=44 >
<AREA SHAPE=CIRCLE COORDS="139,138,5" Title="Коломна" Alt="Коломна"  HREF=61 >
<AREA SHAPE=CIRCLE COORDS="143,162,5" Title="Зарайск" Alt="Зарайск"  HREF=53 >

<AREA SHAPE=CIRCLE COORDS="108,87,5" Title="Балашиха" Alt="Балашиха"  HREF=41 >
<AREA SHAPE=CIRCLE COORDS="99,104,5" Title="Видное" Alt="Видное"  HREF=43 >
<AREA SHAPE=CIRCLE COORDS="35,69,5" Title="Волоколамск" Alt="Волоколамск"  HREF=44 >
<AREA SHAPE=CIRCLE COORDS="136,121,5" Title="Воскресенск" Alt="Воскресенск"  HREF=45 >
<AREA SHAPE=CIRCLE COORDS="101,113,5" Title="Домодедово" Alt="Домодедово"  HREF=48 >
<AREA SHAPE=CIRCLE COORDS="148,117,5" Title="Егорьевск" Alt="Егорьевск"  HREF=50 >
<AREA SHAPE=CIRCLE COORDS="143,162,5" Title="Зарайск" Alt="Зарайск"  HREF=53 >
<AREA SHAPE=CIRCLE COORDS="68,79,5" Title="Истра" Alt="Истра"  HREF=56 >
<AREA SHAPE=CIRCLE COORDS="116,156,5" Title="Кашира" Alt="Кашира"  HREF=58 >
<AREA SHAPE=CIRCLE COORDS="63,47,5" Title="Клин" Alt="Клин"  HREF=60 >
<AREA SHAPE=CIRCLE COORDS="139,138,5" Title="Коломна" Alt="Коломна"  HREF=61 >
<AREA SHAPE=CIRCLE COORDS="85,85,5" Title="Красногорск" Alt="Красногорск"  HREF=63 >
<AREA SHAPE=CIRCLE COORDS="106,96,5" Title="Люберцы" Alt="Люберцы"  HREF=66 >
<AREA SHAPE=CIRCLE COORDS="37,107,5" Title="Можайск" Alt="Можайск"  HREF=67 >
<AREA SHAPE=CIRCLE COORDS="100,78,5" Title="Мытищи" Alt="Мытищи"  HREF=68 >
<AREA SHAPE=CIRCLE COORDS="63,117,5" Title="Наро-Фоминск" Alt="Наро-Фоминск"  HREF=69 >
<AREA SHAPE=CIRCLE COORDS="126,83,5" Title="Ногинск" Alt="Ногинск"  HREF=70 >
<AREA SHAPE=CIRCLE COORDS="83,96,5" Title="Одинцово" Alt="Одинцово"  HREF=71 >
<AREA SHAPE=CIRCLE COORDS="132,155,5" Title="Озеры" Alt="Озеры"  HREF=72 >
<AREA SHAPE=CIRCLE COORDS="145,85,5" Title="Орехово-Зуево" Alt="Орехово-Зуево"  HREF=73 >
<AREA SHAPE=CIRCLE COORDS="135,88,5" Title="Павловский Посад" Alt="Павловский Посад"  HREF=74 >
<AREA SHAPE=CIRCLE COORDS="93,113,5" Title="Подольск" Alt="Подольск"  HREF=75 >
<AREA SHAPE=CIRCLE COORDS="105,71,5" Title="Пушкино" Alt="Пушкино"  HREF=77 >
<AREA SHAPE=CIRCLE COORDS="118,104,5" Title="Раменское" Alt="Раменское"  HREF=79 >
<AREA SHAPE=CIRCLE COORDS="115,50,5" Title="Сергиев Посад" Alt="Сергиев Посад"  HREF=81 >
<AREA SHAPE=CIRCLE COORDS="88,150,5" Title="Серпухов" Alt="Серпухов"  HREF=82 >
<AREA SHAPE=CIRCLE COORDS="73,58,5" Title="Солнечногорск" Alt="Солнечногорск"  HREF=83 >
<AREA SHAPE=CIRCLE COORDS="113,152,5" Title="Ступино" Alt="Ступино"  HREF=84 >
<AREA SHAPE=CIRCLE COORDS="89,79,5" Title="Химки" Alt="Химки"  HREF=87 >
<AREA SHAPE=CIRCLE COORDS="90,135,5" Title="Чехов" Alt="Чехов"  HREF=88 >
<AREA SHAPE=CIRCLE COORDS="166,102,5" Title="Шатура" Alt="Шатура"  HREF=89 >
<AREA SHAPE=CIRCLE COORDS="110,79,5" Title="Щелково" Alt="Щелково"  HREF=90 >
<AREA SHAPE=CIRCLE COORDS="24,53,5" Title="Лотошино" Alt="Лотошино"  HREF=99 >
<AREA SHAPE=CIRCLE COORDS="148,147,5" Title="Луховицы" Alt="Луховицы"  HREF=100 >
<AREA SHAPE=CIRCLE COORDS="43,93,5" Title="Руза" Alt="Руза"  HREF=101 >
<AREA SHAPE=CIRCLE COORDS="137,182,5" Title="Серебрянные пруды" Alt="Серебрянные пруды"  HREF=102 >
<AREA SHAPE=CIRCLE COORDS="93,19,5" Title="Талдом" Alt="Талдом"  HREF=103 >
<AREA SHAPE=CIRCLE COORDS="20,68,5" Title="Шаховская" Alt="Шаховская"  HREF=104 >
}
    // Use same File Name as for Picture but with TXT extension
    N_SL.SaveToFile( ChangeFileExt( K_ExpandFileName(CAFName1), '.txt' ) );
    MT.Free;

//    N_CreateRasterByComp( TN_UDCompVis(CAUDBase1), CAIRect.TopLeft,
//                                                   CAFRect, CAFName1 );
  end; // with APParams^ do
end; // procedure N_UDATestMapTools

procedure N_UDATestScreenCapture( APParams: TN_PCAction; AP1, AP2: Pointer );
// ScreenCapture Test:
//
// (for using in TN_UDAction under Action Name ScreenCapture )
var
  SHDC: HDC;
begin
  if N_ActiveRFRame = nil then Exit;

  with APParams^, N_ActiveRFRame do
  begin
    SHDC := windows.GetDC( 0 );

    N_T1.Start();
    windows.BitBlt( OCanv.HMDC, 0, 0, 10, 10, SHDC, 0, 0, SRCCOPY );
    N_T1.SS( ' 10x10  rect copy' );

    N_T1.Start();
    windows.BitBlt( OCanv.HMDC, 0, 0, 10, 20, SHDC, 0, 0, SRCCOPY );
    N_T1.SS( ' 10x20  rect copy' );

    N_T1.Start();
    windows.BitBlt( OCanv.HMDC, 0, 0, 20, 10, SHDC, 0, 0, SRCCOPY );
    N_T1.SS( ' 20x10  rect copy' );

    N_T1.Start();
    windows.BitBlt( OCanv.HMDC, 0, 0, 10, 100, SHDC, 0, 0, SRCCOPY );
    N_T1.SS( ' 10x100 rect copy' );

    N_T1.Start();
    windows.BitBlt( OCanv.HMDC, 0, 0, 100, 10, SHDC, 0, 0, SRCCOPY );
    N_T1.SS( '100x10  rect copy' );

    N_T1.Start();
    windows.BitBlt( OCanv.HMDC, 0, 0, 20, 100, SHDC, 0, 0, SRCCOPY );
    N_T1.SS( ' 20x100 rect copy' );

    N_T1.Start();
    windows.BitBlt( OCanv.HMDC, 0, 0, 100, 100, SHDC, 0, 0, SRCCOPY );
    N_T1.SS( '100x100 rect copy' );

    N_T1.Start();
    windows.BitBlt( OCanv.HMDC, 0, 0, 200, 100, SHDC, 0, 0, SRCCOPY );
    N_T1.SS( '200x100 rect copy' );

    N_T1.Start();
    windows.BitBlt( OCanv.HMDC, 0, 0, 100, 200, SHDC, 0, 0, SRCCOPY );
    N_T1.SS( '100x200 rect copy' );

    N_T1.Start();
    windows.BitBlt( OCanv.HMDC, 0, 0, 200, 200, SHDC, 0, 0, SRCCOPY );
    N_T1.SS( '200x200 rect copy' );

    N_T1.Start();
    windows.BitBlt( OCanv.HMDC, 0, 0, 400, 400, SHDC, 0, 0, SRCCOPY );
    N_T1.SS( '400x400 rect copy' );

    ShowMainBuf();
  end; // with APParams^ do
end; // procedure N_UDATestScreenCapture

procedure N_MarkActListBMP( ADIBObj: TN_DIBObj; AFlags: integer;
                            APixX, APixY, ANumX, ANumY: integer ); //*** local
// Draw Point Marks on given ActListBMP
// AFlags:
//   - bit0 = 1 - skip drawing numbers
//   - bit1 = 1 - skip drawing all black Points in Icon corners
var
  ind, ix, iy, x, y: integer;
  Str: string;
  OnePixRect: Trect;
  UDNFont: TN_UDNFont;
begin
  UDNFont := TN_UDNFont.Create2( APixY/1.4, 'Arial' );
  N_SetNFont( UDNFont, ADIBObj.DIBOCanv );

  for ix := 0 to ANumX-1 do
  for iy := 0 to ANumY-1 do
  with ADIBObj.DIBOCanv do
  begin
    x := APixX*ix;
    y := APixY*iy;
    SetBrushAttribs( 0 );

    if (AFlags and $01) = 0 then // draw two digit Ican index
    begin
      ind := (ix + iy*ANumX) mod 100;
      Str := Format( '%0.2d', [ind] );
      DrawPixString( Point( x+2, y), Str );
    end; // if (AFlags and $01) = 0 then // draw two digit Ican index

    if (AFlags and $02) = 0 then // draw black Points in Icon corners
    begin
      OnePixRect := Rect( x, y, x, y ); // upper left
      DrawPixFilledRect( OnePixRect );
      OnePixRect := N_RectShift( OnePixRect, 1, 1 );
      DrawPixFilledRect( OnePixRect );

      OnePixRect := N_RectShift( OnePixRect, APixX-3, 0 ); // upper right
      DrawPixFilledRect( OnePixRect );
      OnePixRect := N_RectShift( OnePixRect, 1, -1 );
      DrawPixFilledRect( OnePixRect );

      OnePixRect := N_RectShift( OnePixRect, 0, APixY-1 ); // lower right
      DrawPixFilledRect( OnePixRect );
      OnePixRect := N_RectShift( OnePixRect, -1, -1 );
      DrawPixFilledRect( OnePixRect );

      OnePixRect := N_RectShift( OnePixRect, -APixX+3, 0 ); // lower left (only one)
      DrawPixFilledRect( OnePixRect );
    end; // if (AFlags and $02) = 0 then // draw black Points in Icon corners

  end; // with DIBObj.DIBOCanv do, for ix := 0 to ANumX-1 do, for iy := 0 to ANumY-1 do

end; // procedure N_MarkActListBMP

procedure N_UDACreateActListBMP( APParams: TN_PCAction; AP1, AP2: Pointer );
// Create ActionList BMP:
// CAFName1 - resulting BMP file
// CAIRect  - (LTRB) - PixX, PixY, NumX, NumY
// CAColor1 - background (transparent) Color
// CAFlags1 - how to mark empty Icons:
//   - bit0 = 1 - skip drawing numbers
//   - bit1 = 1 - skip drawing black Points in Icon corners
//
// (for using in TN_UDAction under Action Name CreateActListBMP )
var
  PixX, PixY, NumX, NumY: integer;
  DIBObj: TN_DIBObj;
begin
  with APParams^ do
  begin
    PixX := CAIRect.Left;
    PixY := CAIRect.Top;
    NumX := CAIRect.Right;
    NumY := CAIRect.Bottom;

    DIBObj := TN_DIBObj.Create( PixX*NumX, PixY*NumY, pf24bit, CAColor1 );
    N_MarkActListBMP( DIBObj, CAFlags1, PixX, PixY, NumX, NumY );
    DIBObj.SaveToBMPFormat( K_ExpandFileName( CAFName1 ) );
    DIBObj.Free;
  end; // with APParams^ do
end; // procedure N_UDACreateActListBMP

procedure N_UDAConvActListBMP( APParams: TN_PCAction; AP1, AP2: Pointer );
// Convert ActionList BMP:
// CAFName1  - source BMP file, resulting BMP file is CAFName1_1
// CAIRect   - (LTRB) - resulting BMP file params: RPixX, RPixY, RNumX, RNumY
// CAFRect   - (LTRB) - source BMP file params:    SPixX, SPixY, SNumX, SNumY
// CAColor1  - background (transparent) Color
// CAParStr1 - SrcIconInd DstIconInd NumIcons
// CAFlags1 - how to mark empty Icons:
//   - bit0 = 1 - skip drawing numbers
//   - bit1 = 1 - skip drawing all black Points in Icon corners
//   - bit4 = 1 - use HALFTONE StretchBltMode, otherwise use COLORONCOLOR
//
// (for using in TN_UDAction under Action Name ConvActListBMP )
var
  i, ind, ix, iy, x, y, SIconInd, RIconInd, NumIcons: integer;
  SPixX, SPixY, SNumX, SNumY, RPixX, RPixY, RNumX, RNumY: integer;
  Str, SFName, RFName: string;
  SRect, RRect: Trect;
  SDIBObj, RDIBObj: TN_DIBObj;
begin
  with APParams^ do
  begin

    RPixX := CAIRect.Left;
    RPixY := CAIRect.Top;
    RNumX := CAIRect.Right;
    RNumY := CAIRect.Bottom;

    SPixX := Round(CAFRect.Left);
    SPixY := Round(CAFRect.Top);
    SNumX := Round(CAFRect.Right);
    SNumY := Round(CAFRect.Bottom);

    SFName := K_ExpandFileName( CAFName1 );
    RFName := ChangeFileExt( SFName, '' );
    RFName := ChangeFileExt( RFName + '_1', '.bmp' );

    Str := CAParStr1;
    SIconInd := N_ScanInteger( Str );
    RIconInd := N_ScanInteger( Str );
    NumIcons := N_ScanInteger( Str );

    if NumIcons = N_NotAnInteger then Exit; // a precaution

    SDIBObj := TN_DIBObj.Create( SFName ); // load Src BMP

    //***** Create or load resulting BMP

    if not FileExists( RFName ) then // Create resulting BMP
    begin
      RDIBObj := TN_DIBObj.Create( RPixX*RNumX, RPixY*RNumY, pf24bit, CAColor1 );
      N_MarkActListBMP( RDIBObj, CAFlags1, RPixX, RPixY, RNumX, RNumY );
    end else //************************ Load resulting BMP
    begin
      RDIBObj := TN_DIBObj.Create( RFName );
    end; // end else // load resulting BMP

    RDIBObj.DIBOCanv.SetBrushAttribs( CAColor1 ); // for filling lower left pixel

    if (CAFlags1 and $010) = 0 then
      Windows.SetStretchBltMode( RDIBObj.DIBOCanv.HMDC, COLORONCOLOR )
    else
      Windows.SetStretchBltMode( RDIBObj.DIBOCanv.HMDC, HALFTONE );

    for i := 0 to NumIcons-1 do // along all Icons to convert
    begin
      //***** Calc Src Rect

      ind := i + SIconInd;
      if ind >= SNumX*SNumY-1 then Continue; // out of Source BMP

      ix := ind mod SNumX;
      iy := ind div SNumX;

      x := SPixX*ix;
      y := SPixY*iy;

      SRect := Rect( x, y, x+SPixX-1, y+SPixY-1 );

      //***** Calc resulting Rect

      ind := i + RIconInd;
      if ind >= RNumX*RNumY-1 then Continue; // out of resulting BMP

      ix := ind mod RNumX;
      iy := ind div RNumX;

      x := RPixX*ix;
      y := RPixY*iy;

      RRect := Rect( x, y, x+RPixX-1, y+RPixY-1 );

      N_StretchRect( RDIBObj.DIBOCanv.HMDC, RRect, SDIBObj.DIBOCanv.HMDC, SRect );

      // fill lower left pixel by transparent color
      RDIBObj.DIBOCanv.DrawPixFilledRect( Rect( RRect.Left, RRect.Bottom, RRect.Left, RRect.Bottom ));
    end; // for i := 0 to NumIcons-1 do // along all Icons to convert

    RDIBObj.SaveToBMPFormat( RFName );

    SDIBObj.Free;
    RDIBObj.Free;
  end; // with APParams^ do
end; // procedure N_UDAConvActListBMP

procedure N_UDACreateGrayScaleBMP( APParams: TN_PCAction; AP1, AP2: Pointer );
// Create GrayScale BMP:
// CAFName1 - resulting BMP file
// CAIRect  - (LTRB) - PixX, PixY
// CAFlags1 - how to mark empty Icons:
//   - bit0 = 1 - skip drawing numbers
//
// (for using in TN_UDAction under Action Name CreateGrayScaleBMP )
var
  PixX, PixY, NumX, NumY: integer;
  ind, ix, iy, x, y: integer;
  Str: string;
  PixRect: Trect;
  UDNFont: TN_UDNFont;
  DIBObj: TN_DIBObj;
begin
  with APParams^ do
  begin
    PixX := CAIRect.Left;
    PixY := CAIRect.Top;
    NumX := 16;
    NumY := 16;

    DIBObj := TN_DIBObj.Create( PixX*NumX, PixY*NumY, pf24bit );

    UDNFont := TN_UDNFont.Create2( PixY/1.4, 'Arial' );
    N_SetNFont( UDNFont, DIBObj.DIBOCanv );

    for ix := 0 to NumX-1 do
    for iy := 0 to NumY-1 do
    with DIBObj.DIBOCanv do
    begin
      x := PixX*ix;
      y := PixY*iy;

      ind := ix + iy*NumX; // Rect Index and Color Value
      SetBrushAttribs( ind or (ind shl 8) or (ind shl 16) );
      PixRect := Rect( x, y, x+PixX-1, y+PixY-1 );
      DrawPixFilledRect( PixRect );

      if ind < 128 then
        SetFontAttribs( $FFFFFF )
      else
        SetFontAttribs( 0 );

      Str := Format( '%0.2X', [ind] );
      DrawPixString( Point( x+2, y ), Str );
    end; // with DIBObj.DIBOCanv do, for iy ..., for ix ...

    DIBObj.SaveToBMPFormat( K_ExpandFileName( CAFName1 ) );
    DIBObj.Free;
  end; // with APParams^ do
end; // procedure N_UDACreateGrayScaleBMP

procedure N_UDACreateSharpTestBMP( APParams: TN_PCAction; AP1, AP2: Pointer );
// Create GrayScale BMP for testing Sharpen algorithms:
// CAFName1 - resulting BMP file
// CAIRect  -
// CAFlags1 - how to mark empty Icons:
//   - bit0 = 1 - skip drawing numbers
//
// (for using in TN_UDAction under Action Name CreateSharpTestBMP )
var
  PixX, PixY, CurX, CurY, SizeX, SizeY: integer;
  PixRect: TRect;
  DIBObj, GrayDIBObj: TN_DIBObj;
  Label Fin;

  procedure DrawFigures( AColor: integer );
  begin
    with DIBObj.DIBOCanv do
    begin
      PixRect := Rect( CurX, CurY, CurX+SizeX-1, CurY+SizeY-1 );
      SetBrushAttribs( AColor );
      DrawPixFilledRect( PixRect );

      //*** 1-pix Line
      CurX := CurX + SizeX + 10;
      PixRect := Rect( CurX, CurY, CurX, CurY+SizeY-1 );
      DrawPixFilledRect( PixRect );

      //*** 3-pix Line
      CurX := CurX + 11;
      PixRect := Rect( CurX, CurY, CurX+2, CurY+SizeY-1 );
      DrawPixFilledRect( PixRect );
      CurX := CurX + 13;
    end; // with DIBObj.DIBOCanv do
  end; // procedure DrawFigures - local

begin
  with APParams^ do
  begin
    PixX := 300;
    PixY := 150;

//    DIBObj := TN_DIBObj.Create( PixX, PixY, pfCustom, 128, epfGray8 );
    DIBObj := TN_DIBObj.Create( PixX, PixY, pf24bit, $848484 );

    CurX := 10;
    CurY := 10;
    SizeX := 20;
    SizeY := 100;

    DrawFigures( $000000 );
    DrawFigures( $828282 );
    DrawFigures( $FFFFFF );
    DrawFigures( $868686 );

    Fin:
    GrayDIBObj := TN_DIBObj.Create( PixX, PixY, pfCustom, -1, epfGray8 );
    DIBObj.CalcGrayDIB( GrayDIBObj );
    GrayDIBObj.SaveToBMPFormat( K_ExpandFileName( CAFName1 ) );
    GrayDIBObj.Free;
    DIBObj.Free;
  end; // with APParams^ do
end; // procedure N_UDACreateSharpTestBMP

procedure N_UDAConvPixelsToText( APParams: TN_PCAction; AP1, AP2: Pointer );
// Convert Rect of Pixels in given file to Text:
// CAFName1 - source picture file
// CAFName2 - Resulting Text file or empty for showing in InfoForm
// CAIRect  - Rect of Pixels to convert
// CAFlags1 - format flags (now 0 - decimal, 1 - hex)
//
// (for using in TN_UDAction under Action Name ConvPixelsToText )
var
  DIBObj: TN_DIBObj;
  SL: TStringList;
begin
  with APParams^ do
  begin
    DIBObj := TN_DIBObj.Create( K_ExpandFileName( CAFName1 ) );
    SL := TStringList.Create;
    DIBObj.RectToStrings( CAIRect, CAFlags1, CAFName1, SL, nil );

    if CAFName2 = '' then
    begin
      with N_GetInfoForm() do
      begin
        Memo.Lines.AddStrings( SL );
        Memo.WordWrap := False;
        Memo.ScrollBars := ssBoth;
        Show();
      end;
    end else
      SL.SaveToFile( K_ExpandFileName( CAFName2 ) );

    SL.Free;
    DIBObj.Free;
  end; // with APParams^ do
end; // procedure N_UDAConvPixelsToText

procedure N_UDATestXXX( APParams: TN_PCAction; AP1, AP2: Pointer );
// XXX Test:
//
// (for using in TN_UDAction under Action Name TestXXX )
begin
  with APParams^ do
  begin

  end; // with APParams^ do
end; // procedure N_UDATestXXX


Initialization
  N_RegActionProc( 'TestDummy1',       N_UDATestDummy1 );
  N_RegActionProc( 'TestDummy2',       N_UDATestDummy2 );
  N_RegActionProc( 'TestDummy3',       N_UDATestDummy3 );
  N_RegActionProc( 'TestCreateFont1',  N_UDATestCreateFont1 );
  N_RegActionProc( 'TestCreateFont2',  N_UDATestCreateFont2 );
  N_RegActionProc( 'PatternBrush1',    N_UDATestPatternBrush1 );
  N_RegActionProc( 'WinRotateCoords1', N_UDATestWinRotateCoords1 );
  N_RegActionProc( 'CalcStrPixRect',   N_UDATestCalcStrPixRect );
  N_RegActionProc( 'LowLevelDraw1',    N_UDATestLowLevelDraw1 );
  N_RegActionProc( 'OneBezierSegm',    N_UDATestOneBezierSegm );
  N_RegActionProc( '1DPWIFunc',        N_UDATest1DPWIFunc );
  N_RegActionProc( 'ConvProcs1',       N_UDATestConvProcs1 );
  N_RegActionProc( 'XYNLConvPWI',      N_UDATestXYNLConvPWI );
  N_RegActionProc( 'TestTimers1',      N_UDATestTimers1 );
  N_RegActionProc( 'WordDeb1',         N_UDATestWordDeb1 );     // некоторые базовые OLE функции
  N_RegActionProc( 'WordDeb2',         N_UDATestWordDeb2 );     // API на Паскале создание сложного документа
  N_RegActionProc( 'WordDeb3',         N_UDATestWordDeb3 );     // тест использования вложенных документов
  N_RegActionProc( 'WordDeb4',         N_UDATestWordDeb4 );     // генерация сложного многоуровневого документа
  N_RegActionProc( 'WordDeb5',         N_UDATestWordDeb5 );     // генерация многоуровневого документа c простыми разделами и гистограммами
  N_RegActionProc( 'WordDeb6',         N_UDATestWordDeb6 );     // построение оглавлений
  N_RegActionProc( 'WordDeb7',         N_UDATestWordDeb7 );     // создание документа с картинкой из буфера обмена
  N_RegActionProc( 'WordRunMacros',    N_UDATestWordRunMacros ); // Run Macros from several files
  N_RegActionProc( 'WordSpeedTests1',  N_UDATestWordSpeedTests1 ); // Word Speed Tests set #1
  N_RegActionProc( 'CreateWordDoc',    N_UDATestCreateWordDoc );   // Create Word Doc using TN_WordDoc class
  N_RegActionProc( 'CreateMVTADoc',    N_UDATestCreateMVTADoc );   // Create MVTA Doc
  N_RegActionProc( 'ShowFileAsText',   N_UDATestShowFileAsText );  // Show given File in ASCII HEX form
  N_RegActionProc( 'RWProcMem1',       N_ActionRWProcMem1 );       // Read/Write Process Memory

  N_RegActionProc( 'MemTextFragms',    N_UDATestMemTextFragms ); // MemTextFragms test
  N_RegActionProc( 'TestStrPos',       N_UDATestStrPos );        // StrPos Time Test
  N_RegActionProc( 'TestValue2Str',    N_UDATestValue2Str );     // StrPos Time Test
  N_RegActionProc( 'TestTmp1',         N_UDATestTmp1 );          // Temporary Test
  N_RegActionProc( 'TestStringList',   N_UDATestStringList );    // StringList Time Test
  N_RegActionProc( 'TestPrepRoot',     N_UDATestPrepRoot );      // Prep Root Size Test
  N_RegActionProc( 'TestDrawUserRects',N_UDATestDrawUserRects ); // Draw Rects for Prep Root Size Test

  N_RegActionProc( 'AddSearchGroup',   N_UDATestAddSearchGroup ); // Add Search Group Test
  N_RegActionProc( 'TestPChar',        N_UDATestPChar );          // PChar assignment Test
  N_RegActionProc( 'TestTWAIN1',       N_UDATestTWAIN1 );         // TWAIN1 Test
  N_RegActionProc( 'TestMapTools',     N_UDATestMapTools );       // MapTools Test
  N_RegActionProc( 'ScreenCapture',    N_UDATestScreenCapture );  // ScreenCapture Test
  N_RegActionProc( 'CreateActListBMP', N_UDACreateActListBMP );   // Create ActionList BMP
  N_RegActionProc( 'ConvActListBMP',   N_UDAConvActListBMP );     // Convert ActionList BMP

  N_RegActionProc( 'CreateGrayScaleBMP',  N_UDACreateGrayScaleBMP );  // Create GrayScale BMP
  N_RegActionProc( 'CreateSharpTestBMP',  N_UDACreateSharpTestBMP );  // Create Sharp Test BMP
  N_RegActionProc( 'ConvPixelsToText',    N_UDAConvPixelsToText );    // Convert Pixels to Text

  N_RegActionProc( 'TestXXX',          N_UDATestXXX );       // XXX Test

end.
