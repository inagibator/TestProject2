unit N_BrigHistFr;
// Frame based on TN_Rast1Frame for drawing Brightness Histogramm

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, ToolWin, ImgList, ActnList, ExtCtrls, StdCtrls, Types,
  K_UDT1, K_Script1,
  N_Types, N_BaseF, N_Gra0, N_Gra1, N_Gra2, N_Rast1Fr, N_CM1, N_Lib2;

type TN_YAxisUnits = ( yauNone, yauAbsNumbers, yauPercents );

type TN_BrigHistFrame = class( TFrame )
    RFrame: TN_Rast1Frame;

    procedure RFrameResize ( Sender: TObject );
  public
    BHFSrcDIB: TN_DIBObj;       // Source DIBObj for getting Brightness values (any type DIB)
    SrcHist8Values:  TN_IArray; // Source DIBObj (BHFSrcDIB) Hist 8 Values, always 8 bit (256 elements)

    MaxSrcHist8Value:  integer; // Max value in SrcHist8Values array
    XLATHist8Values: TN_IArray; // SrcHist8Values converted by given PXLAT
    OrderedXHValues: TN_IArray; // Ordered XLATHist8Values
    MaxXLATHistValue: integer;  // Max Value in XLATHist8Values array
    VisXLATHistValue: integer;  // Max Visible Value (max visible Y Value)
    BHFPXLAT8toConv: PInteger;  // 256 elems XLAT Table for converting SrcHist8Values to XLATHist8Values, always (0,255)->(0,255)
    BHFPXLAT8toDraw: PInteger;  // 256 elems XLAT Table which should be Drawn, always (0,255)->(0,255)

    HistPolygon:    TN_IPArray; // Histogramm Polygon
    HistPolygonSize:   integer; // number of points in Histogramm Polygon
    BRangePolygon:  TN_IPArray; // Brightness range Polygon (part of Histogramm)
    BRangePolygonSize: integer; // number of points in BRangePolygon Polygon
    XLATPolygon:    TN_IPArray; // Polygon for drawing given XLAT (by BHFPXLAT8toDraw)
    XLATPolygonSize:   integer; // number of points in XLATPolygon Polygon

    DxLeft:     integer; // Left  gap between RFrame border and HistRect
    DxRight:    integer; // Right gap between RFrame border and HistRect
    DyBottom:   integer; // Bottom gap between RFrame border and GradientRect
    DyGrad:     integer; // GradientRect Height
    DyGradHist: integer; // Y gap between GradientRect and HistRect
    DyTop:      integer; // Top gap between RFrame border and HistRect

    DyTicks:    integer; // X axis Ticks height
    DyLabels:   integer; // Gap between GradientRect and X axis Labels (X-values)
    DxTicks:    integer; // Y axis Ticks width
    DxLabels:   integer; // Gap between HistRect.Left and Y axis Labels (Y-values)

    BRDWidths: TN_DArray; // Double Array of Brightness Rects Width
    BRWidths:  TN_IArray; // integer Array of Brightness Rects Width
    BRLefts:   TN_IArray; // Array of Brightness Rects Left
    HistWidth:   integer; // Histogramm Rect Width
    HistHeight:  integer; // Histogramm Rect Height
    HistRect:      TRect; // Histogramm Rect
    GradTop:     integer; // Gradient Rect Top
    GradBot:     integer; // Gradient Rect Bottom

    CurBri:      integer; // Current brightness in (0,65535)
    CurMinBri:   integer; // Current Min brightness interval in (0,65535)
    CurMaxBri:   integer; // Current Max brightness interval in (0,65535)

    CurBri8:     integer; // Current brightness converted to Gray8 in (0,255)
    CurMinBri8:  integer; // Current Min brightness interval converted to Gray8
    CurMaxBri8:  integer; // Current Max brightness interval converted to Gray8

    BackColor:        integer; // Histogramm Background Color
    HistColor:        integer; // Histogramm Main Color
    RangeMainColor:   integer; // Range Main Color
    RangeBackColor:   integer; // Range Background Color
    CurBriColor:      integer; // Curent Brightness Color
    XLATPolygonColor: integer; // XLATPolygon Color
    LabelsNFont:   TN_UDNFont; // all X and Y axis Labels Font
    YLabelsLefter:    boolean; // Y axis Labels should be Lefter than Y Axis (out of Hist Rect)
    YAxisUnits: TN_YAxisUnits; // Y Axis Units: Absolute Numbers or Percents


    procedure BHFDrawXAxisTics    ();
    procedure PrepXLATHist8Values ();
    function  HToPix              ( AHistValue: integer ): integer;
    procedure CalcPolygons        ( AMaxVisBrightness: integer );
    procedure RedrawRFrame        ();

    procedure BHFrameSetDIBObj( ADIBObj: TN_DIBObj );

//    procedure SetDIBObjAndXlat    ( ADIBObj: TN_DIBObj; APXLAT: PInteger );
//    procedure SetDIBObj           ( ADIBObj: TN_DIBObj );
//    procedure SetXLAT             ( APXLAT: PInteger );
//    procedure SetXLATtoDraw       ( APXLATtoDraw: PInteger  );
//    procedure SetBriRange         ( AMinBri, AMaxBri: integer );
//    procedure SetCurBrightness    ( ABrightness: integer );
//    procedure SetMaxVisBrightness ( AMaxVisBrightness: integer );
end; // type TN_BrigHistFrame = class( TFrame )

implementation
uses N_Lib0, N_Lib1, N_Gra3;
{$R *.dfm}


    //************************** TN_BrigHistFrame Handlers ***********

procedure TN_BrigHistFrame.RFrameResize( Sender: TObject );
// TN_BrigHistFrame.RFrame instance Resize
var
  i, Curi, Curi8, CurX, NCoef, DX, DY: integer;
  TmpRect: TRect;
  Str: string;
begin
  if Length(BRDWidths) <> 256 then //***** Frame is not initialized yet
    Exit;

  //***** Draw all Self elems that do not depend upon BHFSrcDIB pixels values

  GradBot := RFrame.Height - DyBottom - 1;
  GradTop := GradBot - DyGrad + 1;

  HistHeight := GradTop - DyGradHist;
  HistWidth  := RFrame.Width - DxLeft - DxRight;
  HistRect := Rect( DxLeft, DyTop, DxLeft+HistWidth-1, DyTop+HistHeight-1 );

  with RFrame do //***** Prepare OCanv Bufer for drawing gradient rect
  begin
    OCanv.SetCurCRectSize( Width, Height, pfDevice );
    RFRasterScale := 1;
    RecalcPRects();
    OCanv.DrawPixFilledRect2( Rect(0,0,RFrame.Width-1,RFrame.Height-1), BackColor ); // Clear RFrame
  end;

  for i := 0 to 255 do BRDWidths[i] := HistWidth / 256.0; // prep Double Brigh Rects widths

  N_RoundVector( @BRDWidths[0], 256, @BRWidths[0] ); // Calc BRWidths

  BRLefts[0] := HistRect.Left;
  for i := 1 to 255 do BRLefts[i] := BRLefts[i-1] + BRWidths[i-1];

  for i := 0 to 255 do // Draw Gradient
  begin
    TmpRect := Rect( BRLefts[i], GradTop, BRLefts[i]+BRWidths[i]-1, GradBot );
    RFrame.OCanv.DrawPixFilledRect2( TmpRect, i + (i shl 8) + (i shl 16) ); // Draw i-th gray Rect
  end; // for i := 0 to 255 do // Draw Gradient

  if BHFSrcDIB <> nil then
    NCoef := $1 shl (BHFSrcDIB.DIBNumBits - 8)
  else
    NCoef := 1;

  for i := 0 to 5 do // Draw X axis Ticks and Labels
  begin
    Curi8 := i * 50; // in (0,255) range
    if i = 5 then Curi8 := 255;
    CurX := BRLefts[Curi8] + BRWidths[Curi8] div 2;

//    N_Dump1Str( IntToStr( BRLefts[255] ) ); // debug

    TmpRect := Rect( CurX, GradBot+1, CurX, GradBot+1+DyTicks );
    RFrame.OCanv.DrawPixFilledRect2( TmpRect, $000000 ); // Draw i-th Tick

    Curi := i * 50 * NCoef; // in (0,65535) range
    if i = 5 then Curi := (256*NCoef) - 1;

    Str := IntToStr( Curi );

    with RFrame.OCanv do // Draw i-th Label
    begin
      if i = 0 then // DxLeft Left aligned
      begin
        DrawPixString( Point( DxLeft,  GradBot+DyLabels ), Str );
      end else if i = 5 then // CurX Right Aligned
      begin
        GetStringSize( Str, DX, DY );
        DrawPixString( Point( CurX-DX, GradBot+DyLabels ), Str );
      end else // i = 1,2,3,4 - CurX Centered
      begin
        if BRLefts[255] < 310 then // too small Self width for all labels
          if (i = 2) or (i = 4) then // skip drawing labels 2 and 4
            Continue;
            
        GetStringSize( Str, DX, DY );
        DrawPixString( Point( CurX - (DX div 2), GradBot+DyLabels ), Str );
      end;
    end; // with RFrame.OCanv do // Draw i-th Label

  end; // for i := 0 to 5 do // Draw X axis Ticks and Labels

  CalcPolygons( VisXLATHistValue );
  RedrawRFrame();
end; // procedure TN_BrigHistFrame.RFrameResize



    //************************** TN_BrigHistFrame Methods ***********

//*************************************** TN_BrigHistFrame.BHFDrawXAxisTics ***
// Draw X Axis Tics
//
procedure TN_BrigHistFrame.BHFDrawXAxisTics();
begin
  if BHFSrcDIB = nil then Exit;

end; // procedure TN_BrigHistFrame.BHFDrawXAxisTics

//************************************* TN_BrigHistFrame.PrepXLATHist8Values ***
// Prepare XLAT HistValues: XLATHist8Values, OrderedXHValues
//
// SrcHist8Values should be already calculated
//
procedure TN_BrigHistFrame.PrepXLATHist8Values();
begin
  if BHFSrcDIB = nil then Exit;

  N_ConvHist8ByXLAT( SrcHist8Values, BHFPXLAT8toConv, XLATHist8Values, nil, nil, @MaxXLATHistValue );

  SetLength( OrderedXHValues, 256 );
  move( XLATHist8Values[0], OrderedXHValues[0], 256*SizeOf(Integer) );

  N_SortElements( TN_BytesPtr(@OrderedXHValues[0]), 256, SizeOf(Integer), 0, N_CompareIntegers );
end; // procedure TN_BrigHistFrame.PrepXLATHist8Values

//************************************************* TN_BrigHistFrame.HToPix ***
// Convert given Histogramm value to Y Pixel coord inside HistRect
//
//                AHistValue=0 converts to HistRect.Bottom,
// AHistValue=VisXLATHistValue converts to HistRect.Top
//
function TN_BrigHistFrame.HToPix( AHistValue: integer ): integer;
begin
//  N_Dump1Str( Format( 'MaxXLATHistValue=%d', [MaxXLATHistValue] ));
  Result := HistRect.Top + Round( 1.0*(VisXLATHistValue-AHistValue) *
                           (HistRect.Bottom-HistRect.Top) / VisXLATHistValue );
end; // function TN_BrigHistFrame.HToPix

//******************************************* TN_BrigHistFrame.CalcPolygons ***
// Set Max Visible Brightness (set needed Y scale) and
// calc all Polygons
//
//     Parameters
// AMaxVisBrightness - given Max Visible Brightness
//
// OrderedXHValues should be already calulated
// AMaxVisBrightness = 0  means using max value (OrderedXHValues[255], show whole range)
// AMaxVisBrightness = -1 means auto scaling (cut out not needed max values)
//
procedure TN_BrigHistFrame.CalcPolygons( AMaxVisBrightness: integer );
var
  i, StartInd, ip, ZeroVal, PrevVal, CurVal, NextVal: integer;
  GapCoef, SaveCoef: double;
  Label DoCalcPolygons;

  function GetYValue( AInd: integer; AMode: integer ): integer; // local
  var
    PCurValue: PInteger;
  begin
    if Amode = 0 then // use Histogramm Value
    begin
      Result := HToPix( XLATHist8Values[AInd] );
    end else // use XLAT Value
    begin
      PCurValue := BHFPXLAT8toDraw;
      Inc( PCurValue, AInd );
      Result := HistRect.Top + 1 + Round( 1.0*(255-PCurValue^) *
                           (HistRect.Bottom-HistRect.Top-2) / 255 );
    end;
  end; // function GetYValue // local

  procedure CalcOnePolygon( var APolygon: TN_IPArray; AMinBri, AMaxBri: integer;
                            out ANumPoints: integer; AMode: integer ); // local
  var
    j: integer;
  begin
    if Amode = 0 then // prepare Histogramm Polygon
    begin
      if (BHFSrcDIB = nil) or (AMinBri = -1) then // not given
      begin
        ANumPoints := 0;
        Exit;
      end; // if (BHFSrcDIB = nil) or (AMinBri = -1) then // not given
    end else // prepare XLATtoDraw Polygon
    begin
      if BHFPXLAT8toDraw = nil then // not given
      begin
        ANumPoints := 0;
        Exit;
      end; // if (BHFSrcDIB = nil) or (AMinBri = -1) then // not given
    end;

    if Length(APolygon) < 4*256+1 then SetLength( APolygon, 4*256+1 ); // max possible Size

    //***** First (leftmoust) Rect

    if Amode = 0 then ZeroVal := HistRect.Bottom      // prepare Histogramm Polygon
                 else ZeroVal := HistRect.Bottom + 1; // prepare XLATtoDraw Polygon

    APolygon[0].X := BRLefts[AMinBri]; // Initial (lower left) point
    APolygon[0].Y := ZeroVal;

//    CurVal  := HToPix( XLATHist8Values[AMinBri] );
    CurVal  := GetYValue( AMinBri, AMode );

    APolygon[1].X := APolygon[0].X; // same X
    APolygon[1].Y := CurVal;

    if AMinBri = AMaxBri then // Range = 1
    begin
      APolygon[2].X := APolygon[1].X + BRWidths[AMinBri] - 1;
      APolygon[2].Y := APolygon[1].Y;                         // same Y

      APolygon[3].X := APolygon[2].X; // same X
      APolygon[3].Y := APolygon[0].Y;

      APolygon[4].X := APolygon[0].X; // Initial (lower left) polygon point
      APolygon[4].Y := APolygon[0].Y;

      ANumPoints := 5;
      Exit; // all done
    end; // if AMinBri = AMaxBri then // Range = 1

    //***** Here AMinBri < 255 (AMinBri+1 <=255)

//    NextVal := HToPix( XLATHist8Values[AMinBri+1] );
    NextVal := GetYValue( AMinBri+1, AMode );
    ip := 2; // free index

    if CurVal >= NextVal then // Next Rect is higher
    begin
      APolygon[ip].X := BRLefts[AMinBri] + BRWidths[AMinBri]; // in next Rect
      APolygon[ip].Y := APolygon[ip-1].Y; // same Y

      Inc( ip, 1 );
    end else // Next Rect is lower
    begin
      APolygon[ip].X := BRLefts[AMinBri] + BRWidths[AMinBri] - 1; // in cur Rect
      APolygon[ip].Y := APolygon[ip-1].Y; // same Y

      APolygon[ip+1].X := APolygon[ip].X; // same X
      APolygon[ip+1].Y := NextVal;        // next Rect Y

      Inc( ip, 2 );
    end; // else // Next Rect is lower

//if (AMinBri >= 254) or (AMaxBri >= 256) then
//AMinBri := AMinBri + 0;
    for j := AMinBri+1 to AMaxBri-1 do // along all rects except first and last
    begin
      PrevVal := CurVal;  // j-1 (previous)rect
      CurVal  := NextVal; // j-th (current) rect
//      NextVal := HToPix( XLATHist8Values[j+1] ); // j+1 (next) rect (j+1 always <= AMaxBri)
      NextVal := GetYValue( j+1, AMode ); // j+1 (next) rect (j+1 always <= AMaxBri)

      if PrevVal >= CurVal then // Cur Rect is higher than Prev Rect
      begin
        APolygon[ip].X := APolygon[ip-1].X;  // same X
        APolygon[ip].Y := CurVal;

        Inc( ip, 1 );
      end; // if PrevVal >= CurVal then // Cur Rect is higher than Prev Rect

      if CurVal >= NextVal then // Next Rect is higher
      begin
        APolygon[ip].X := BRLefts[j] + BRWidths[j]; // in next Rect
        APolygon[ip].Y := APolygon[ip-1].Y; // same Y

        Inc( ip, 1 );
      end else // Next Rect is lower
      begin
        APolygon[ip].X := BRLefts[j] + BRWidths[j] - 1; // in cur Rect
        APolygon[ip].Y := APolygon[ip-1].Y; // same Y

        APolygon[ip+1].X := APolygon[ip].X; // same X
        APolygon[ip+1].Y := NextVal;        // next Rect Y

        Inc( ip, 2 );
      end; // else // Next Rect is lower

    end; // for j := AMinBri+1 to AMaxBri-1 do // along all rects except first and last

    //***** Last (rightmoust) Rect

    PrevVal := CurVal;  // AMaxBri-1 (previous)rect
    CurVal  := NextVal; // AMaxBri-th (current and last) rect

    if PrevVal >= CurVal then // Last (Cur) Rect is higher
    begin
      APolygon[ip].X := APolygon[ip-1].X;  // same X
      APolygon[ip].Y := CurVal;

      Inc( ip, 1 );
    end; // if PrevVal >= CurVal then // Last (Cur) Rect is higher

    APolygon[ip].X := BRLefts[AMaxBri] + BRWidths[AMaxBri] - 1; // last X
    APolygon[ip].Y := CurVal; // same Y

    APolygon[ip+1].X := APolygon[ip].X; // last X
    APolygon[ip+1].Y := APolygon[0].Y;  // Y = 0

    APolygon[ip+2].X := APolygon[0].X; // initial (lower left) Polygon point
    APolygon[ip+2].Y := APolygon[0].Y;

    Inc( ip, 3 );
    ANumPoints := ip;
  end; // procedure CalcOnePolygon

begin //*********************************** main body of CalcPolygons
  if BHFSrcDIB = nil then Exit;

  if AMaxVisBrightness >= 1 then // manual scale, set VisXLATHistValue to explicitly given value
  begin
    VisXLATHistValue := AMaxVisBrightness;
    goto DoCalcPolygons;
  end;

  if AMaxVisBrightness = 0 then // show whole range, set VisXLATHistValue to max value
  begin
    VisXLATHistValue := OrderedXHValues[255];
    goto DoCalcPolygons;
  end;

  //***** Here: use Auto Scaling

  VisXLATHistValue := OrderedXHValues[255]; // for some special cases
  StartInd := 243; // only last 12 (12=255-243) values could be cut
  GapCoef  := 1.3;
  SaveCoef := 3.0;

  if OrderedXHValues[StartInd] = 0 then // most pixels are black, use whole range
    goto DoCalcPolygons;

  if (1.0*OrderedXHValues[255] / OrderedXHValues[StartInd]) <= SaveCoef then // no big difference, use whole range
    goto DoCalcPolygons;

  //***** Cut all values after first Gap

  for i := StartInd+1 to 255 do
  begin
//    if (OrderedXHValues[i] = XLATHist8Values[0]) or // always skip black and white colors
//       (OrderedXHValues[i] = XLATHist8Values[255]) then
//      Continue; // cut i-th value because it is black or white

    if (1.0*OrderedXHValues[i] / OrderedXHValues[StartInd]) > GapCoef then
    begin
      VisXLATHistValue := OrderedXHValues[i-1]; // cut all valuse for [i,...,255] inds
      goto DoCalcPolygons;
    end;
  end; // for i := StartInd+1 to 255 do

  DoCalcPolygons: //********************************************************
  // VisXLATHistValue is OK,
  // Calculate all three Polygons (HistPolygon, BRangePolygon, XLATPolygon)

  CalcOnePolygon( HistPolygon, 0, 255, HistPolygonSize, 0 );

  if (CurMinBri <> -1) and (CurMaxBri <> -1) then // Bri Range was given
    CalcOnePolygon( BRangePolygon, CurMinBri8, CurMaxBri8, BRangePolygonSize, 0 );

  if BHFPXLAT8toDraw <> nil then
    CalcOnePolygon( XLATPolygon, 0, 255, XLATPolygonSize, 1 );
end; // procedure TN_BrigHistFrame.CalcPolygons

//******************************************* TN_BrigHistFrame.RedrawRFrame ***
// Redraw all RFrame content (except gradient rect):
// Histogramm, Brightness Range, XLATtoDraw, current Brightness
//
procedure TN_BrigHistFrame.RedrawRFrame();
var
  i, CurY, CurX, CurPixY: integer;
  CurDY: double;
  RangeRect, HorzRect, VertRect, TmpRect: TRect;
  BasePointPos: TFPoint;
  Str: String;
begin
  N_ir := HistRect;
  N_i  := RFrame.Height;

  with RFrame.OCanv do
  begin
    TmpRect := HistRect;
    TmpRect.Left := 0;
    TmpRect.Top  := 0;
    DrawPixFilledRect2( TmpRect, BackColor ); // Histogramm Background and dyTop upper pixels

    if YAxisUnits <> yauNone then // Draw Y axis line
    begin
      TmpRect := Rect( HistRect.Left-1, DyTop, HistRect.Left-1, DyTop+GradTop-DyGradHist-1 );
      RFrame.OCanv.DrawPixFilledRect2( TmpRect, $000000 );
    end;

    if CurMinBri >= 0 then // Brightness Range was given, Draw Range Background
    begin
      RangeRect := Rect( BRLefts[CurMinBri8], HistRect.Top,
                         BRLefts[CurMaxBri8]+BRWidths[CurMaxBri8]-1, HistRect.Bottom );
      DrawPixFilledRect2( RangeRect, RangeBackColor ); // Range Background
    end; // if CurMinBri >= 0 then // Brightness Range was given, Draw Range Background

    if BHFSrcDIB <> nil then
    begin
      // Draw Main HistPolygon
      SetPenAttribs( HistColor, 0 );
      SetBrushAttribs( HistColor );
      DrawPixPolygon( HistPolygon, HistPolygonSize );

      if CurMinBri >= 0 then // Brightness Range was given, Draw RangePolygon
      begin
        SetPenAttribs( RangeMainColor, 0 );
        SetBrushAttribs( RangeMainColor );
        DrawPixPolygon( BRangePolygon, BRangePolygonSize );
      end; // if CurMinBri >= 0 then // Brightness Range was given, Draw Range

      if XLATPolygonSize > 3 then // XLATto Draw was given, Draw it (Draw XLATPolygon)
      begin
        SetPenAttribs( XLATPolygonColor, 0 );
        SetBrushAttribs( -1 );
        DrawPixPolyline( XLATPolygon, XLATPolygonSize-2 );
      end; // if XLATPolygonSize > 3 then // XLATto Draw was given, Draw it (Draw XLATPolygon)

    end; // if BHFSrcDIBObj <> nil then

    if YAxisUnits <> yauNone then // Draw tics on Y axis (Abs number of pixels or Percents)
    begin
      for i := 0 to 5 do // Draw Y axis Ticks and Labels
      begin
        CurPixY := HistRect.Bottom - i * HistHeight div 5;
        if i = 5 then CurPixY := HistRect.Top;

        TmpRect := Rect( HistRect.Left, CurPixY, HistRect.Left+DxTicks-1, CurPixY );
        RFrame.OCanv.DrawPixFilledRect2( TmpRect, $000000 ); // Draw i-th Tick

        if YAxisUnits = yauAbsNumbers then // Y units are Absolute number of pixels
        begin
          CurY := i * VisXLATHistValue div 5;
          if i = 5 then CurY := VisXLATHistValue;
          Str := IntToStr( CurY );
        end else // YAxisUnits =  yauPercents, Y units are Percents of MaxXLATHistValue
        begin
//          CurY := i*20;
          CurDY := 20.0*i*VisXLATHistValue/MaxXLATHistValue;
          Str := Format( '%.4f', [CurDY] );
        end;

        if YLabelsLefter then BasePointPos := FPoint( 1, 0 )
                         else BasePointPos := FPoint( 0, 0 );

        if i = 0 then
          RFrame.OCanv.DrawPixString2( Point( HistRect.Left+DxLabels, CurPixY-15 ), BasePointPos, Str )  // 0%
        else if i = 5 then
          RFrame.OCanv.DrawPixString2( Point( HistRect.Left+DxLabels, CurPixY-3  ), BasePointPos, Str )  // 20-80%
        else // i = 1,2,3,4
          RFrame.OCanv.DrawPixString2( Point( HistRect.Left+DxLabels, CurPixY-8  ), BasePointPos, Str ); // 100%

      end; // for i := 0 to 5 do // Draw Y axis Ticks and Labels
    end; // if YAxisUnits <> yauNone then // Draw tics on Y axis (Abs number of pixels or Percents)

    if (CurBri >= 0) and (BHFSrcDIB <> nil) then // Current Brightness (CurBri) was given, Draw it
    begin
//      if (CurBri < 0) or (CurBri > High(XLATHist8Values)) then // debug
//        CurBri := CurBri + 0;

      CurY := HToPix( XLATHist8Values[CurBri8] );
      HorzRect := Rect( HistRect.Left, CurY, HistRect.Right, CurY );
      DrawPixFilledRect2( HorzRect, CurBriColor ); // Horizontal CurBri line

      CurX := BRLefts[CurBri8] + (BRWidths[CurBri8] div 2 );
      VertRect := Rect( CurX, HistRect.Top, CurX, HistRect.Bottom );
      DrawPixFilledRect2( VertRect, CurBriColor ); // Vertical CurBri line
    end; // if (CurBri >= 0) and (BHFSrcDIB <> nil) then // Current Brightness (CurBri) was given, Draw it

  end; // with RFrame.OCanv do

  RFrame.ShowMainBuf();
end; // procedure TN_BrigHistFrame.RedrawRFrame

//*************************************** TN_BrigHistFrame.BHFrameSetDIBObj ***
// Set DIBObj and prepare SrcHist8Values, OrderedXHValues (do not draw anything)
//
procedure TN_BrigHistFrame.BHFrameSetDIBObj( ADIBObj: TN_DIBObj );
begin
  BHFSrcDIB := ADIBObj; // Source DIBObj for getting Brightness values
  CurBri    := -1;
  CurMinBri := -1;
  CurMaxBri := -1;

  if BHFSrcDIB = nil then Exit;

  BHFSrcDIB.CalcBrighHistNData( SrcHist8Values, nil, nil, nil, @MaxSrcHist8Value, 8 ); // Calc SrcHist8Values
  PrepXLATHist8Values();
end; // procedure TN_BrigHistFrame.BHFrameSetDIBObj

{
//*************************************** TN_BrigHistFrame.SetDIBObjAndXlat ***
// Set DIBObj, XLat and redraw all
//
procedure TN_BrigHistFrame.SetDIBObjAndXlat( ADIBObj: TN_DIBObj; APXLAT: PInteger );
begin
  BHFSrcDIB := ADIBObj; // Source DIBObj for getting Brightness values

  BHFPXLAT8toConv := APXLAT;
  CurBri    := -1;
  CurMinBri := -1;
  CurMaxBri := -1;

  if BHFSrcDIB = nil then Exit;

  BHFSrcDIB.CalcBrighHistData( SrcHist8Values, nil, nil, nil, @MaxSrcHist8Value );
  N_ConvHist8ByXLAT( SrcHist8Values, BHFPXLAT8toConv, XLATHist8Values, nil, nil, @MaxXLATHistValue );
  OrderXLATHist8Values();

  CalcPolygons(); // Calc HistPolygon and BRangePolygon Polygons from XLATHist8Values array
  RedrawRFrame();
end; // procedure TN_BrigHistFrame.SetDIBObjAndXlat

//************************************************ TN_BrigHistFrame.SetXLAT ***
// Set XLAT table to convert caculated Historgramm and redraw all
//
procedure TN_BrigHistFrame.SetXLAT( APXLAT: PInteger );
begin
  BHFPXLAT8toConv := APXLAT;

  CurBri    := -1;
  CurMinBri := -1;
  CurMaxBri := -1;

  if BHFSrcDIB = nil then Exit;

//  if N_KeyIsDown( VK_SHIFT ) then
//    N_i := 1;

  N_ConvHist8ByXLAT( SrcHist8Values, BHFPXLAT8toConv, XLATHist8Values, nil, nil, @MaxXLATHistValue );
  OrderXLATHist8Values();

  CalcPolygons(); // Calc HistPolygon and BRangePolygon Polygons from XLATHist8Values array
  RedrawRFrame();
end; // procedure TN_BrigHistFrame.SetXLAT

//****************************************** TN_BrigHistFrame.SetXLATtoDraw ***
// Set XLAT table to Draw and redraw all
//
procedure TN_BrigHistFrame.SetXLATtoDraw( APXLATtoDraw: PInteger );
begin
  BHFPXLAT8toDraw := APXLATtoDraw;

  if BHFSrcDIB = nil then Exit;

  CalcPolygons(); // Calc HistPolygon and BRangePolygon Polygons from XLATHist8Values array
  RedrawRFrame();
end; // procedure TN_BrigHistFrame.SetXLATtoDraw

//******************************************** TN_BrigHistFrame.SetBriRange ***
// Set new Brightenss range and redraw all
//
procedure TN_BrigHistFrame.SetBriRange( AMinBri, AMaxBri: integer );
begin
  CurMinBri := AMinBri; // Min brightness interval
  CurMaxBri := AMaxBri; // Max brightness interval
  if BHFSrcDIB = nil then Exit;

  CalcPolygons(); // Calc HistPolygon and BRangePolygon Polygons from XLATHist8Values array
  RedrawRFrame();
end; // procedure TN_BrigHistFrame.SetBriRange

//*************************************** TN_BrigHistFrame.SetCurBrightness ***
// Set current Brightenss and redraw all
//
procedure TN_BrigHistFrame.SetCurBrightness( ABrightness: integer );
begin
  CurBri := ABrightness;
  if BHFSrcDIB = nil then Exit;

  RedrawRFrame();
end; // procedure TN_BrigHistFrame.SetCurBrightness

//************************************ TN_BrigHistFrame.SetMaxVisBrightness ***
// Set Max Visible Brightness (set needed Y scale) and redraw all
//
//     Parameters
// AMaxVisBrightness - given Max Visible Brightness
//
// OrderedXHValues should be already calulated
// AMaxVisBrightness = 0  means using max value (OrderedXHValues[255], show whole range)
// AMaxVisBrightness = -1 means auto scaling (cut out not needed max values)
//
procedure TN_BrigHistFrame.SetMaxVisBrightness( AMaxVisBrightness: integer );
var
  i, StartInd: integer;
  GapCoef, SaveCoef: double;
begin
  if BHFSrcDIB = nil then Exit;

  if AMaxVisBrightness >= 1 then // manual scale
  begin
    VisXLATHistValue := AMaxVisBrightness;
    RedrawRFrame();
    Exit;
  end;

  if AMaxVisBrightness = 0 then // show whole range
  begin
    VisXLATHistValue := OrderedXHValues[255];
    RedrawRFrame();
    Exit;
  end;

  //***** Here: use Auto Scaling

  VisXLATHistValue := OrderedXHValues[255]; // for some special cases
  StartInd := 243; // only last 12=255-243 values could be cut
  GapCoef  := 1.3;
  SaveCoef := 3.0;

  if OrderedXHValues[StartInd] = 0 then // most pixels are black, show whole range
  begin
    RedrawRFrame();
    Exit;
  end;

  if (1.0*OrderedXHValues[255] / OrderedXHValues[StartInd]) <= SaveCoef then // no big difference, show whole range
  begin
    RedrawRFrame();
    Exit;
  end;

  // Cut all values after first Gap

  for i := StartInd+1 to 255 do
  begin
    if (1.0*OrderedXHValues[i] / OrderedXHValues[StartInd]) > GapCoef then
    begin
      VisXLATHistValue := OrderedXHValues[i]; // cut all valuse for (i,255) inds
      Break; // VisXLATHistValue is OK
    end;
  end; // for i := StartInd+1 to 255 do

  RedrawRFrame();
end; // procedure TN_BrigHistFrame.SetMaxVisBrightness
}


end.
