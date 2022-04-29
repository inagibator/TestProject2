unit N_Gra0;
// low level Graphic (Points, Lines, Rects) coordinates objects types
//
// Interface section uses only N_Types and Delphi units
// Implementation section uses only Delphi units

interface
uses Windows, Classes, SysUtils, Graphics, ZLib, Forms,
     ComCtrls, StdCtrls, ExtCtrls, Contnrs, Controls, Dialogs,
     N_Types;

function  IPoint ( const AFPoint: TFPoint ): TPoint;  overload;
function  IPoint ( const ASize: TSize ):     TPoint;  overload;
function  IPoint ( const ADPoint: TDPoint ): TPoint;  overload;
function  IPoint ( const ARect: TRect ):     TPoint;  overload;
function  FPoint ( const AFX, AFY: float ):  TFPoint; overload;
function  FPoint ( const APoint: TPoint ):   TFPoint; overload;
function  FPoint ( const ADPoint: TDPoint ): TFPoint; overload;
function  DPoint ( const ADX, ADY: double ): TDPoint; overload;
function  DPoint ( const APoint: TPoint ):   TDPoint; overload;
function  DPoint ( const AFPoint: TFPoint ): TDPoint; overload;

function  IRect  ( const ASizeXY: TPoint ): TRect;   overload;
function  IRect  ( const AWidth, AHeight: integer ): TRect; overload;
function  IRect  ( const ATLDP, ARBDP: TDPoint ): TRect; overload;
function  IRect  ( const AFRect: TFRect ): TRect; overload;
function  IRect  ( const ADRect: TDRect ): TRect; overload;
function  IRect  ( const ADLeft, ADTop, ADRight, ADBottom: double ): TRect; overload;
function  IRect1 ( const AFRect: TFRect ): TRect;

function  IRectS ( const AWidth, AHeight: integer ): TRectS;   overload;

function  FRect  ( const ASizeXY: TPoint ): TFRect;  overload;
function  FRect  ( const AFSizeXY: TFPoint ): TFRect; overload;
function  FRect  ( const ADSizeXY: TDPoint ): TFRect; overload;
function  FRect  ( const AWidth, AHeight: integer ): TFRect; overload;
function  FRect  ( const AFLeft, AFTop, AFRight, AFBottom: float ): TFRect; overload;
function  FRect  ( const ARect: TRect ): TFRect;  overload;
function  FRect  ( const ADRect: TDRect ): TFRect; overload;
function  FRect  ( const ATLP, ARBP: TPoint ): TFRect; overload;
function  FRect1 ( const ARect: TRect ): TFRect;

function  DRect  ( const ADLeft, ADTop, ADRight, ADBottom: double ): TDRect; overload;
function  DRect  ( const AFRect: TFRect ): TDRect; overload;

function  N_IRectAnd   ( var ARectRes: TRect; const ARectOp: TRect ): integer;
function  N_IRectOr    ( var ARectRes: TRect; const ARectOp: TRect ): integer;
function  N_IRectFAffConv2 ( const AAffDstIRect: TRect; const AAffSrcFRect, ASrcFRect: TFRect ): TRect;
function  N_IRectIAffConv2 ( const AAffDstIRect: TRect; const AAffSrcFRect, ASrcIRect: TRect ): TRect;
function  N_IRectSubstr  ( var AOutRects: TN_IRArray; const ARect1, ARect2: TRect ): integer;
function  N_IRectOrder   ( const ARect: TRect ): TRect;
function  N_IRectShift   ( const ARect: TRect; ShiftX, ShiftY: integer ): TRect;
function  N_IRectCreate1 ( const ARect: TRect; const ANewWidth, ANewHeight: integer; const ACenter: boolean ): TRect;
function  N_IRectCreate2 ( const ARect: TRect; ANewWidth, ANewHeight: integer; const ACenter: boolean ): TRect;
function  N_IRectToStr   ( const ARect: TRect; AFmt: string = '' ): String;
function  N_IRectsCrossArea ( const ARect1, Arect2: TRect ): double;


implementation
uses
  N_Gra1;

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\IPoint(FPoint)
//********************************************************** IPoint(FPoint) ***
// Convert given Float Point to Integer Point
//
//     Parameters
// AFPoint - given Float Point
// Result  - Returns Integer Point
//
function IPoint( const AFPoint: TFPoint ): TPoint;
begin
  Result.X := Round(AFPoint.X);
  Result.Y := Round(AFPoint.Y);
end; // end of function IPoint(FPoint)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\IPoint(TSize)
//*********************************************************** IPoint(TSize) ***
// Convert given TSize record to Integer Point
//
//     Parameters
// ASize  - given TSize record
// Result - Returns Integer Point
//
function IPoint( const ASize: TSize ): TPoint;
begin
  Result.X := ASize.cx;
  Result.Y := ASize.cy;
end; // end of function IPoint(TSize)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\IPoint(DPoint)
//********************************************************** IPoint(DPoint) ***
// Convert given Double Point to Integer Point
//
//     Parameters
// ADPoint - given Double Point
// Result  - Returns Integer Point
//
function IPoint( const ADPoint: TDPoint ): TPoint;
begin
  Result.X := Round(ADPoint.X);
  Result.Y := Round(ADPoint.Y);
end; // end of function IPoint(DPoint)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\IPoint(Rect)
//************************************************************ IPoint(Rect) ***
// Get given Integer Rectangle sizes
//
//     Parameters
// ARect  - given Integer Rectangle
// Result - Returns Integer Rectangle sizes as Integer Point (X means width, Y 
//          means height)
//
function IPoint( const ARect: TRect ): TPoint;
begin
  with ARect do
  begin
    Result.X := Right - Left + 1;
    Result.Y := Bottom - Top + 1;
  end;
end; // end of function IPoint(IRect)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\FPoint(two_FLoats)
//****************************************************** FPoint(two FLoats) ***
// Convert given Point float coordinates to Float Point
//
//     Parameters
// AFX    - given Point X coordinate
// AFY    - given Point Y coordinate
// Result - Returns Float Point
//
// The function is float analogue of Pascal Point() function
//
function FPoint( const AFX, AFY: float ): TFPoint;
begin
  Result.X := AFX;
  Result.Y := AFY;
end; // end of function FPoint(2f)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\FPoint(Point)
//*********************************************************** FPoint(Point) ***
// Convert Integer Point to Float Point
//
//     Parameters
// APoint - given Integer Point
// Result - Returns Float Point
//
function FPoint( const APoint: TPoint ): TFPoint;
begin
  Result.X := APoint.X;
  Result.Y := APoint.Y;
end; // end of function FPoint(ip)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\FPoint(DPoint)
//********************************************************** FPoint(DPoint) ***
// Convert given Double Point to Float Point
//
//     Parameters
// ADPoint - given Double Point
// Result  - Returns Float Point
//
function FPoint( const ADPoint: TDPoint ): TFPoint;
begin
  Result.X := ADPoint.X;
  Result.Y := ADPoint.Y;
end; // end of function FPoint(dp)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\DPoint(two_Doubles)
//***************************************************** DPoint(two Doubles) ***
// Convert given Point double coordinates to Float Point
//
//     Parameters
// ADX    - given Point double X coordinate
// ADY    - given Point double Y coordinate
// Result - Returns Float Point
//
// The function is double analogue of Pascal Point() function
//
function DPoint( const ADX, ADY: double ): TDPoint;
begin
  Result.X := ADX;
  Result.Y := ADY;
end; // end of function DPoint(2D)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\DPoint(PointI)
//********************************************************** DPoint(PointI) ***
// Convert Integer Point to Double Point
//
//     Parameters
// APoint - given Integer Point
// Result - Returns Double Point
//
function DPoint( const APoint: TPoint ): TDPoint;
begin
  Result.X := APoint.X;
  Result.Y := APoint.Y;
end; // end of function DPoint(1I)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\DPoint(FPoint)
//********************************************************** DPoint(FPoint) ***
// Convert Float Point to Double Point
//
//     Parameters
// AFPoint - given Float Point
// Result  - Returns Double Point
//
function DPoint( const AFPoint: TFPoint ): TDPoint;
begin
  Result.X := AFPoint.X;
  Result.Y := AFPoint.Y;
end; // end of function DPoint(1F)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\IRect(Point_Size)
//******************************************************* IRect(Point Size) ***
// Get Integer Rectangle from given size
//
//     Parameters
// ASizeXY - Integer Point with Rectangle width(X) and height(Y)
// Result  - Returns Integer Rectangle
//
// Resulting Rectangle Top and Left coordinates are zero.
//
function  IRect( const ASizeXY: TPoint ): TRect;
begin
  Result.Left   := 0;
  Result.Top    := 0;
  Result.Right  := ASizeXY.X - 1;
  Result.Bottom := ASizeXY.Y - 1;
end; // end of function IRect(1IP)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\IRect(two_Integers_Size)
//************************************************ IRect(two Integers Size) ***
// Get Integer Rectangle from given width and height
//
//     Parameters
// AWidth  - Rectangle width
// AHeight - Rectangle height
// Result  - Returns Integer Rectangle
//
// Resulting Rectangle Top and Left coordinates are zero.
//
function  IRect( const AWidth, AHeight: integer ): TRect;
begin
  Result.Left   := 0;
  Result.Top    := 0;
  Result.Right  := AWidth - 1;
  Result.Bottom := AHeight - 1;
end; // end of function IRect(2I)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\IRect(two_DPoints)
//****************************************************** IRect(two DPoints) ***
// Get Integer Rectangle from given top left and bottom right corners double 
// coordinates
//
//     Parameters
// ATLDP  - top left corner Double Point
// ARBDP  - bottom right corner Double Point
// Result - Returns Integer Rectangle
//
function  IRect( const ATLDP, ARBDP: TDPoint ): TRect;
begin
  Result.Left   := Round( ATLDP.X );
  Result.Top    := Round( ATLDP.Y );
  Result.Right  := Round( ARBDP.X );
  Result.Bottom := Round( ARBDP.Y );
end; // end of function IRect(2D)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\IRect(FRect)
//************************************************************ IRect(FRect) ***
// Convert given Float Rectangle to Integer Rectangle
//
//     Parameters
// AFRect - given Float Rectangle
// Result - Returns Integer Rectangle
//
function IRect( const AFRect: TFRect ): TRect;
begin
  with AFRect do
  begin
    Result.Left   := Round(Left);
    Result.Top    := Round(Top);
    Result.Right  := Round(Right);
    Result.Bottom := Round(Bottom);
  end;
end; // end of function IRect(1FR)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\IRect(DRect)
//************************************************************ IRect(DRect) ***
// Convert given Double Rectangle to Integer Rectangle
//
//     Parameters
// ADRect - given Double Rectangle
// Result - Returns Integer Rectangle
//
function IRect( const ADRect: TDRect ): TRect;
begin
  with ADRect do
  begin
    Result.Left   := Round(Left);
    Result.Top    := Round(Top);
    Result.Right  := Round(Right);
    Result.Bottom := Round(Bottom);
  end;
end; // end of function IRect(1DR)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\IRect(four_Doubles)
//***************************************************** IRect(four Doubles) ***
// Convert given Rectangle double coordinates to Integer Rectangle
//
//     Parameters
// ADLeft   - given Rectangle left position
// ADTop    - given Rectangle top position
// ADRight  - given Rectangle right position
// ADBottom - given Rectangle bottom position
//
function IRect( const ADLeft, ADTop, ADRight, ADBottom: double ): TRect;
begin
  Result.Left   := Round(ADLeft);
  Result.Top    := Round(ADTop);
  Result.Right  := Round(ADRight);
  Result.Bottom := Round(ADBottom);
end; // end of function IRect(4D)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\IRect1
//****************************************************************** IRect1 ***
// Convert Float Rectangle to Integer Rectangle preserving aspect
//
//     Parameters
// AFRect - given Float Rectangle
// Result - Returns Integer Rectangle with same aspect as source Float Rectangle
//          aspect
//
function IRect1( const AFRect: TFRect ): TRect;
begin
  with AFRect do
  begin
    Result.Left   := Round(Left);
    Result.Top    := Round(Top);
    Result.Right  := Round(Right  - 1);
    Result.Bottom := Round(Bottom - 1);
  end;
end; // end of function IRect1(1FR)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\IRectS(two_Integers_Size)
//*********************************************** IRectS(two Integers Size) ***
// Get Integer Rectangle TRectS from given width and height
//
//     Parameters
// AWidth  - Rectangle width
// AHeight - Rectangle height
// Result  - Returns Integer Rectangle
//
// Resulting Rectangle Top and Left coordinates are zero.
//
function  IRectS( const AWidth, AHeight: integer ): TRectS;
begin
  Result.Left   := 0;
  Result.Top    := 0;
  Result.Size.X := AWidth;
  Result.Size.Y := AHeight;
end; // end of function IRectS(2I)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\FRect(Point_Size)
//******************************************************* FRect(Point Size) ***
// Get Float Rectangle by given integer X,Y sizes
//
//     Parameters
// ASizeXY - Integer Point with Rectangle width and height
// Result  - Returns Float Rectangle
//
// Resulting Rectangle Left and Top coordinates are zero.
//
function FRect( const ASizeXY: TPoint ): TFRect;
begin
  Result.Left   := 0;
  Result.Top    := 0;
  Result.Right  := ASizeXY.X - 1;
  Result.Bottom := ASizeXY.Y - 1;
end; // end of function FRect(1IP)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\FRect(FPoint_Size)
//****************************************************** FRect(FPoint Size) ***
// Get Float Rectangle by size given as Float Point
//
//     Parameters
// AFSizeXY - Float Point with Rectangle width and height
// Result   - Returns Float Rectangle
//
// Resulting Rectangle Top and Left coordinates have value 0.
//
function FRect( const AFSizeXY: TFPoint ): TFRect;
begin
  Result.Left   := 0;
  Result.Top    := 0;
  Result.Right  := AFSizeXY.X;
  Result.Bottom := AFSizeXY.Y;
end; // end of function FRect(1FP)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\FRect(DPoint_Size)
//****************************************************** FRect(DPoint Size) ***
// Get Float Rectangle by size given as Double Point
//
//     Parameters
// ADSizeXY - Double Point with Rectangle width and height
// Result   - Returns Float Rectangle
//
// Resulting Rectangle Top and Left coordinates have value 0.
//
function FRect( const ADSizeXY: TDPoint ): TFRect;
begin
  Result.Left   := 0;
  Result.Top    := 0;
  Result.Right  := ADSizeXY.X;
  Result.Bottom := ADSizeXY.Y;
end; // end of function FRect(1DP)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\FRect(two_Integers_Size)
//************************************************ FRect(two Integers Size) ***
// Get Float Rectangle from given integer width and height
//
//     Parameters
// AWidth  - Rectangle integer width
// AHeight - Rectangle integer height
// Result  - Returns Float Rectangle
//
// Resulting Rectangle Top and Left coordinates have value 0.
//
function  FRect( const AWidth, AHeight: integer ): TFRect;
begin
  Result.Left   := 0;
  Result.Top    := 0;
  Result.Right  := AWidth - 1;
  Result.Bottom := AHeight - 1;
end; // end of function FRect(2I)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\FRect(four_Floats)
//****************************************************** FRect(four Floats) ***
// Convert given Rectangle side float coordinates to Float Rectangle
//
//     Parameters
// AFLeft   - given Rectangle left position
// AFTop    - given Rectangle top position
// AFRight  - given Rectangle right position
// AFBottom - given Rectangle bottom position
//
// The function is float analogue of Pascal Rect() function
//
function FRect( const AFLeft, AFTop, AFRight, AFBottom: float ): TFRect;
begin
  Result.Left   := AFLeft;
  Result.Top    := AFTop;
  Result.Right  := AFRight;
  Result.Bottom := AFBottom;
end; // end of function FRect(4F)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\FRect(Rect)
//************************************************************* FRect(Rect) ***
// Convert Integer Rectangle to Float Rectangle
//
//     Parameters
// ARect  - given Integer Rectangle
// Result - Returns Float Rectangle
//
function FRect( const ARect: TRect ): TFRect;
begin
  with ARect do
  begin
    Result.Left   := Left;
    Result.Top    := Top;
    Result.Right  := Right;
    Result.Bottom := Bottom;
  end;
end; // end of function FRect(1IR)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\FRect(DRect)
//************************************************************ FRect(DRect) ***
// Convert Double Rectangle to Float Rectangle
//
//     Parameters
// ADRect - given Double Rectangle
// Result - Returns Float Rectangle
//
function FRect( const ADRect: TDRect ): TFRect;
begin
  with ADRect do
  begin
    Result.Left   := Left;
    Result.Top    := Top;
    Result.Right  := Right;
    Result.Bottom := Bottom;
  end;
end; // end of function FRect(1DR)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\FRect(two_Points)
//******************************************************* FRect(two Points) ***
// Get Float Rectangle from given top left and bottom right corners integer 
// coordinates
//
//     Parameters
// ATLP   - top left corner Integer Point
// ARBP   - bottom right corner Integer Point
// Result - Returns Float Rectangle
//
function FRect( const ATLP, ARBP: TPoint ): TFRect;
begin
  Result.TopLeft     := FPoint( ATLP );
  Result.BottomRight := FPoint( ARBP );
end; // end of function FRect(2IP)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\FRect1
//****************************************************************** FRect1 ***
// Convert integer Rect to float rect preserving aspect
//
//     Parameters
// ARect  - given Integer Rectangle
// Result - Returns Float Rectangle with same aspect as in source Integer 
//          Rectangle
//
function FRect1( const ARect: TRect ): TFRect;
begin
  with ARect do
  begin
    Result.Left   := Left;
    Result.Top    := Top;
    Result.Right  := Right + 1;
    Result.Bottom := Bottom + 1;
  end;
end; // end of function FRect1(1IR)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\DRect(four_Doubles)
//***************************************************** DRect(four Doubles) ***
// Convert given Rectangle double coordinates to Double Rectangle
//
//     Parameters
// ADLeft   - given Rectangle left position
// ADTop    - given Rectangle top position
// ADRight  - given Rectangle right position
// ADBottom - given Rectangle bottom position
//
// The function is double analogue of Pascal Rect() function
//
function DRect( const ADLeft, ADTop, ADRight, ADBottom: double ): TDRect;
begin
  Result.Left   := ADLeft;
  Result.Top    := ADTop;
  Result.Right  := ADRight;
  Result.Bottom := ADBottom;
end; // end of function DRect(4)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\DRect(FRect)
//************************************************************ DRect(FRect) ***
// Convert Float Rectangle to Double Rectangle
//
//     Parameters
// AFRect - given Float Rectangle
// Result - Returns Double Rectangle
//
function DRect( const AFRect: TFRect ): TDRect;
begin
  with AFRect do
  begin
    Result.Left   := Left;
    Result.Top    := Top;
    Result.Right  := Right;
    Result.Bottom := Bottom;
  end;
end; // end of function DRect(1)

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\N_IRectAnd
//************************************************************** N_IRectAnd ***
// Calculate two Integer Rectangles cross-section
//
//     Parameters
// ARectRes - Integer Rectangle - first operand and resulting Rectangle
// ARectOp  - Integer Rectangle - second operand
// Result   - Returns integer value:
//#F
//  =0 - cross-section is empty
//  =1 - cross-section is NOT empty and RectRes is NOT inside RectOp
//  =2 - cross-section is NOT empty and RectRes is stricly inside RectOp
//#/F
//
// All rectangles should be ordered.
//
function N_IRectAnd( var ARectRes: TRect; const ARectOp: TRect ): integer;
begin
  Result := 2; // preliminary value

  if( ARectRes.Left < ARectOp.Left ) then // check Left
  begin
    Result := 1;
    ARectRes.Left := ARectOp.Left;
  end;

  if( ARectRes.Top < ARectOp.Top ) then // check Top
  begin
    Result := 1;
    ARectRes.Top := ARectOp.Top;
  end;

  if( ARectRes.Right > ARectOp.Right ) then // check Right
  begin
    Result := 1;
    ARectRes.Right := ARectOp.Right;
  end;

  if( ARectRes.Bottom > ARectOp.Bottom ) then // check Bottom
  begin
    Result := 1;
    ARectRes.Bottom := ARectOp.Bottom;
  end;

  if (ARectRes.Left > ARectRes.Right) or    // IF Left > Right OR
     (ARectRes.Top > ARectRes.Bottom) then  //    Top  > Bottom
    Result := 0;                          // --> crossection is empty
end; // end of function N_IRectAnd

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\N_IRectOr
//*************************************************************** N_IRectOr ***
// Calculate two Integer Rectangles envelope Rectangle
//
//     Parameters
// ARectRes - Integer Rectangle - first operand and resulting Rectangle
// ARectOp  - Integer Rectangle - second operand
// Result   - Returns integer value:
//#F
//  =0 - ARectRes remains the same (ARectOp is inside ARectRes)
//  =1 - ARectRes changed
//#/F
//
// All rectangles should be ordered.
//
function N_IRectOr( var ARectRes: TRect; const ARectOp: TRect ): integer;
begin
  Result := 0; // preliminary value

  if ARectRes.Left = N_NotAnInteger then // RectRes not initialized
  begin
    ARectRes := ARectOp;
    Result := 1;
    Exit;
  end;

  if ARectOp.Left = N_NotAnInteger then // RectOp not initialized
  begin
    Result := 0;
    Exit;
  end;

  if( ARectRes.Left > ARectOp.Left ) then // check Left
  begin
    Result := 1;
    ARectRes.Left := ARectOp.Left;
  end;

  if( ARectRes.Top > ARectOp.Top ) then // check Top
  begin
    Result := 1;
    ARectRes.Top := ARectOp.Top;
  end;

  if( ARectRes.Right < ARectOp.Right ) then // check Right
  begin
    Result := 1;
    ARectRes.Right := ARectOp.Right;
  end;

  if( ARectRes.Bottom < ARectOp.Bottom ) then // check Bottom
  begin
    Result := 1;
    ARectRes.Bottom := ARectOp.Bottom;
  end;
end; // end of function N_IRectOr

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\N_IRectFAffConv2
//******************************************************** N_IRectFAffConv2 ***
// Convert given Float Rectangle to Integer Rectangle by Affine Transformation 
// Coefficients defined as some Source Float Rectangle and Destination Integer 
// Rectangle
//
//     Parameters
// AAffDstIRect - Affine Transformation Destination Integer Rectangle
// AAffSrcFRect - Affine Transformation Source Float Rectangle
// ASrcFRect    - Source Float Rectangle
// Result       - Returns Integer Rectangle converted from ASrcFRect
//
function N_IRectFAffConv2( const AAffDstIRect: TRect;
                                  const AAffSrcFRect, ASrcFRect: TFRect ): TRect;
var
  AffCoefs: TN_AffCoefs4;
begin
  AffCoefs := N_CalcAffCoefs4( AAffSrcFRect, N_I2FRect2( AAffDstIRect ) );
  Result := N_AffConvF2IRect( ASrcFRect, AffCoefs );
  Dec(Result.Right);
  Dec(Result.Bottom);
end; // end of function N_IRectFAffConv2

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\N_IRectIAffConv2
//******************************************************** N_IRectIAffConv2 ***
// Convert given Integer Rectangle to Integer Rectangle by Affine Transformation
// Coefficients defined as some Source Integer Rectangle and Destination Integer
// Rectangle
//
//     Parameters
// AAffDstIRect - Affine Transformation Destination Integer Rectangle
// AAffSrcFRect - Affine Transformation Source Integer Rectangle
// ASrcIRect    - Source Integer Rectangle
// Result       - Returns Integer Rectangle converted from ASrcIRect
//
function N_IRectIAffConv2( const AAffDstIRect: TRect;
                                  const AAffSrcFRect, ASrcIRect: TRect ): TRect;
var
  AffCoefs: TN_AffCoefs4;
begin
  AffCoefs := N_CalcAffCoefs4( N_I2FRect2(AAffSrcFRect), N_I2FRect2(AAffDstIRect) );
  Result := N_AffConvI2IRect( ASrcIRect, AffCoefs );
end; // end of function N_IRectIAffConv2

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\N_IRectSubstr
//*********************************************************** N_IRectSubstr ***
// Calculate all Integer Rectangles, that cover all areas in ARect1, that are 
// not belong to ARect2.
//
//     Parameters
// AOutRects - resulting Integer Rectangles array
// ARect1    - minuend Integer Rectangle
// ARect2    - subtrahend Integer Rectangle
// Result    - Returns number of resulting rectangles stored in AOutRects array
//
// Number of resulting Rectangles - from 0 to 4. All rectangles are bottom-right
// edges iNclusive.
//
function N_IRectSubstr( var AOutRects: TN_IRArray;
                                         const ARect1, ARect2: TRect ): integer;
var
  Ind, PosCode: integer;
  RectAnd: TRect;
begin
//    +--------------------------------+
//    |         upper  rect            |
//    |                                |
//    | ******** +-------+ *********** |
//    | lefter   |RectAnd|   righter   |
//    |  rect    |       |    rect     |
//    | ******** +-------+ *********** |
//    |                                |
//    |         bottom  rect           |
//    +--------------------------------+
//
  if Length(AOutRects) < 4 then SetLength( AOutRects, 4 );
  Ind := 0;

  RectAnd := ARect1;
  PosCode := N_IRectAnd( RectAnd, ARect2 );

  if PosCode = 0 then // empty crossection, rezult is one Rect
  begin
    AOutRects[0] := ARect1;
    Result := 0;
    Exit;
  end;

  if ARect1.Left < RectAnd.Left then // add lefter Rect to OutRects
  begin
    AOutRects[Ind] :=
        Rect( ARect1.Left, RectAnd.Top, RectAnd.Left-1, RectAnd.Bottom );
    Inc(Ind);
  end;

  if ARect1.Right > RectAnd.Right then // add righter Rect to OutRects
  begin
    AOutRects[Ind] :=
        Rect( RectAnd.Right+1, RectAnd.Top, ARect1.Right, RectAnd.Bottom );
    Inc(Ind);
  end;

  if ARect1.Top < RectAnd.Top then // add upper Rect to OutRects
  begin
    AOutRects[Ind] :=
        Rect( ARect1.Left, ARect1.Top, ARect1.Right, RectAnd.Top-1 );
    Inc(Ind);
  end;

  if ARect1.Bottom > RectAnd.Bottom then // add bottom Rect to OutRects
  begin
    AOutRects[Ind] :=
        Rect( ARect1.Left, RectAnd.Bottom+1, ARect1.Right, ARect1.Bottom );
    Inc(Ind);
  end;
  Result := Ind; // number of rects in OutRects array
end; //*** end of function N_IRectSubstr

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\N_IRectOrder
//************************************************************ N_IRectOrder ***
// Get Integer Rectangle with ordered coordinates from given Integer Rectangle
//
//     Parameters
// ARect  - source Integer Rectangle
// Result - Returns Integer Rectangle with ordered coordinates
//
function N_IRectOrder( const ARect: TRect ): TRect;
begin
  Result := ARect;
  if ARect.Left > ARect.Right then
  begin
    Result.Left  := ARect.Right;
    Result.Right := ARect.Left;
  end;
  if ARect.Top > ARect.Bottom then
  begin
    Result.Top    := ARect.Bottom;
    Result.Bottom := ARect.Top;
  end;
end; // end of function N_IRectOrder

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\N_IRectShift
//************************************************************ N_IRectShift ***
// Shift coordinates of given Integer Rectangle by given X and Y shifts
//
//     Parameters
// ARect   - source Integer Rectangle
// AShiftX - shift of rectangle X-coordinates
// AShiftY - shift of rectangle Y-coordinates
// Result  - Returns Integer Rectangle with shifted coordinates.
//
function N_IRectShift( const ARect: TRect; ShiftX, ShiftY: integer ): TRect;
begin
  Result.Left   := ARect.Left   + ShiftX;
  Result.Top    := ARect.Top    + ShiftY;
  Result.Right  := ARect.Right  + ShiftX;
  Result.Bottom := ARect.Bottom + ShiftY;
end; // end of function N_IRectShift

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\N_IRectCreate1
//********************************************************** N_IRectCreate1 ***
// Create new Integer Rectangle by given Integer Rectangle, new Rectngle 
// dimensions and centered flag
//
//     Parameters
// ARect      - source Integer Rectangle
// ANewWidth  - News Rectangle Width
// ANewHeight - News Rectangle Height
// ACenter    - center resulting Rectangle (boolean flag)
// Result     - Returns Integer Rectangle with given dimensions and position.
//
// if ACenter is True - new Rectangle center is same as source Rectangle center,
// otherwise new Rectangle Upper Left corner is same as source Rectangle upper 
// Left corner.
//
function N_IRectCreate1( const ARect: TRect;
           const ANewWidth, ANewHeight: integer; const ACenter: boolean ): TRect;

begin
  if ACenter then // new Rect center is same as Base Rect center
  begin
    Result.Left := ARect.Left + ((ARect.Right-ARect.Left+1) - ANewWidth) div 2;
    Result.Top  := ARect.Top  + ((ARect.Bottom-ARect.Top+1) - ANewHeight) div 2;
  end else // New Rect Upper Left corner is same as of Base Rect
  begin
    Result.Left := ARect.Left;
    Result.Top  := ARect.Top;
  end;

  Result.Right  := Result.Left + ANewWidth  - 1;
  Result.Bottom := Result.Top  + ANewHeight - 1;
end; // end of function N_IRectCreate1

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\N_IRectCreate2
//********************************************************** N_IRectCreate2 ***
// Create new Integer Rectangle by given Integer Rectangle, new Rectngle 
// dimensions and centered flag
//
//     Parameters
// ARect      - source Integer Rectangle
// ANewWidth  - New Rectangle Width
// ANewHeight - New Rectangle Height
// ACenter    - center resulting Rectangle (boolean flag)
// Result     - Returns Integer Rectangle with given dimensions and position.
//
// if ACenter is True - new Rectangle center is same as source Rectangle center,
// otherwise new Rectangle Upper Left corner is same as source Rectangle upper 
// Left corner.
//
function N_IRectCreate2( const ARect: TRect;
               ANewWidth, ANewHeight: integer; const ACenter: boolean ): TRect;
var
  DeltaSize: integer;
begin
  if ACenter then // new Rect center is same as Base Rect center
  begin
    DeltaSize := (ARect.Right-ARect.Left+1) - ANewWidth;

    if DeltaSize >= 0 then // ARect Width > ANewWidth
    begin
      Result.Left := ARect.Left + DeltaSize div 2;
      if (DeltaSize and $01) = $01 then Inc( ANewWidth );
    end else
    begin
      Result.Left := ARect.Left - abs(DeltaSize) div 2;
      if (DeltaSize and $01) = $01 then Dec( ANewWidth );
    end;

    DeltaSize := (ARect.Bottom-ARect.Top+1) - ANewHeight;

    if DeltaSize >= 0 then // ARect Height > ANewHeight
    begin
      Result.Top  := ARect.Top  + DeltaSize div 2;
      if (DeltaSize and $01) = $01 then Inc( ANewHeight );
    end else
    begin
      Result.Top  := ARect.Top - abs(DeltaSize) div 2;
      if (DeltaSize and $01) = $01 then Dec( ANewHeight );
    end;
  end else // New Rect Upper Left corner is same as of Base Rect
  begin
    Result.Left := ARect.Left;
    Result.Top  := ARect.Top;
  end;

  Result.Right  := Result.Left + ANewWidth  - 1;
  Result.Bottom := Result.Top  + ANewHeight - 1;
end; // end of function N_IRectCreate2

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\N_IRectToStr
//************************************************************ N_IRectToStr ***
// Convert given Integer Rectangle to text using format string
//
//     Parameters
// ARect  - source Integer Rectangle
// AFmt   - convertion format string
// Result - Returns string with converted ARect value
//
function N_IRectToStr( const ARect: TRect; AFmt: string ): String;
begin
  if ARect.Left = N_NotAnInteger then
    Result := 'NoValue'
  else with ARect do
  begin
    if AFmt = '' then AFmt := '%.d %.d  %.d %.d';
    Result := Format( AFmt, [Left, Top, Right, Bottom] );
  end;
end; // end of function N_IRectToStr

//##path N_Delphi\SF\N_Tree\N_Gra0.pas\N_IRectsCrossArea
//******************************************************* N_IRectsCrossArea ***
// Calc intersection Area of two given ARects
//
//     Parameters
// ARect1, ARect2 - given integer Rectangles
// Result         - Returns
//
function N_IRectsCrossArea( const ARect1, Arect2: TRect ): double;
var
  AndRect: TRect;
begin
  AndRect := ARect1;
  Result := 0;

  if 0 = N_IRectAnd( AndRect, ARect2 ) then Exit; // Empty Intersection

  Result := AndRect.Right - AndRect.Left + 1; // Intersection Width
  Result := Result * (AndRect.Bottom - AndRect.Top + 1);
end; // end of function N_IRectsCrossArea


end.
