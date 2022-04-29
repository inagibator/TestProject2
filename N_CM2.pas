unit N_CM2;
// Types and procedures for CMS Application

interface
uses Windows, Classes, Graphics, Controls, ExtCtrls, Types,
  K_Types, K_UDT1, K_Script1, K_SBuf, K_STBuf, K_CM0,
  N_Types, N_Lib0, N_Lib2, N_Gra2, N_CM1,
  N_CompCL, N_CompBase, N_Comp1, N_Comp2, {N_IPCF,} N_DGrid, N_Rast1Fr;

type TN_CMDSLineParams = packed record // One Text Line drawing Params
  DSLPBeforeYOffset: integer; // Y Offset before Line in Pixels
  DSLPLinePixHeight: integer; // Line Height in Pixels
  DSLPAfterYOffset:  integer; // Y Offset After Line in Pixels
  DSLPXOffset:       integer; // X Offset in Pixels to String HotPoint
  DSLPStrHotPoint:     float; // String to Draw HotPoint value along X Axis in percents
  DSLPFontInd:      integer;  // Font Index in CMDSFonts Array
end; // type TN_CMDSLineParams = packed record // One Text Line drawing Params
type TN_CMDSLPArray = Array of TN_CMDSLineParams;

type TN_CMDrawSlideObj = class( TObject ) // Object for Drawing Slide Thumbnail with texts
  CMDSNumHeaderLines:   integer; // Number of Header Lines
  CMDSNumBodyLines:     integer; // Number of Body Lines
  CMDSNumFooterLines:   integer; // Number of Footer Lines
//  CMDSLParams:    N_CMDSLPArray; // Lines Params
  CMDSFonts:          TN_NFonts; // Used Fonts Array
  CMDSCSelColor:        integer; // Special Selected Color (for selecting Mounts)
  CMDSCSelBordWidth:    integer; // Special Selected Border width
  CMDSCSelTextBGColor:  integer; // Special Selected Text BG Color

  destructor  Destroy ();  override;
  procedure DrawOneThumb1 ( AUDCMSlide: TN_UDCMSlide; AStrings: TStrings;
                            ADGrid: TN_DGridBase; ARect: TRect; AFlags : Byte );
  procedure DrawOneThumb2 ( AUDCMSlide: TN_UDCMSlide; AStrings: TStrings;
                            ADGrid: TN_DGridBase; ARect: TRect; AFlags : Byte );
  procedure DrawOneThumb3 ( AUDCMSlide: TN_UDCMSlide; AStrings: TStrings;
                            ADGrid: TN_DGridBase; ARect: TRect; AFlags : Byte );
  procedure DrawOneThumb4 ( AUDCMSlide: TN_UDCMSlide; AStrings: TStrings;
                            ADGrid: TN_DGridBase; ARect: TRect; AFlags : Byte );
  procedure DrawOneThumb5 ( AUDCMSlide: TN_UDCMSlide; AStrings: TStrings;
                            ADGrid: TN_DGridBase; ARect: TRect; AFlags : Byte );
  procedure DrawOneThumb6 ( AUDCMSlide: TN_UDCMSlide; AStrings: TStrings; ANumStrings: integer;
                            ADGrid: TN_DGridBase; ARect: TRect; AFlags : Byte );
  procedure DrawOneThumb7 ( AUDCMSlide: TN_UDCMSlide; AStrings: TStrings; ANumStrings: integer;
                            ADGrid: TN_DGridBase; ARect: TRect; AFlags : Byte );
  procedure DrawOneThumb8( AUDCMSlide: TN_UDCMSlide;
                           AStrings: TStrings; ANumStrings: integer;
                           ADGrid: TN_DGridBase; ARect: TRect;
                           ARFrame : TN_Rast1Frame;
                           AFlags: Byte );
  procedure DrawOneThumb9( AUDCMSlide: TN_UDCMSlide;
                           AStrings: TStrings; ANumStrings: integer;
                           ADGrid: TN_DGridBase; ARect: TRect;
                           AFlags: Byte );
end; // type TN_CMDrawSlideObj = class( TObject )

procedure N_PrepHorThumbRFrame ( AThumbFrame: TN_Rast1Frame; ANumItems: integer;
                                 var AThumbsDGrid: TN_DGridUniMatr );

var
  N_CM_IDEMode: integer = 0;

implementation
uses math, Forms, SysUtils, Dialogs,
  K_UDConst, K_CLib0, K_Arch, K_Parse,
  N_ClassRef, N_Lib1, N_Gra0, N_Gra1, N_EdRecF,
  N_ME1, N_GCont;

//****************** TN_CMDrawSlideObj class methods  *****************

//*********************************************** TN_CMDrawSlideObj.Destroy ***
// TN_CMDrawSlideObj destructor
//
destructor TN_CMDrawSlideObj.Destroy;
var
  i: integer;
begin
  for i := 0 to High(CMDSFonts) do
    N_b := Windows.DeleteObject( CMDSFonts[i].NFHandle );
end; // // destructor TN_CMDrawSlideObj.Destroy;

//***************************************** TN_CMDrawSlideObj.DrawOneThumb1 ***
// Draw One Thumb in CMS MainForm
//
//     Parameters
// AUDCMSlide - Slide which Thumbnail should be drawn
// AStrings   - StringList with needed Strings to Draw
// ADGrid     - Thumbs Grid
// ARect      - Thumb Rect in current OCanv.Buf coords (not DGrid coords)
// AFlags     - Slide Draw Flags
//
// Shows Slide Text Single Line under the SLide using normal black font
// Used in Delete Slides Dialog and Change Slides Attrs Dialog
//
procedure TN_CMDrawSlideObj.DrawOneThumb1( AUDCMSlide: TN_UDCMSlide; AStrings: TStrings;
                                          ADGrid: TN_DGridBase; ARect: TRect;
                                          AFlags: Byte );
var
//  i: integer;
  CellRect, ImageRect: TRect;
  Thumbnail: TN_UDDIB;
  TextWidth : Integer;
  TextGap : Integer;
  WStr : string;
  TextBGColor : integer;
  TextColor : Integer;

  Label EmptyCell;
begin
  Thumbnail := AUDCMSlide.GetThumbnail();

  if Thumbnail = nil then // a precaution
    goto EmptyCell;


  with ADGrid, DGRFrame, OCanv do
  begin
    // CellRect is Image + Texts Rect in current OCanv.Buf coords (not DGrid coords)
    CellRect  := ARect;

    // ImageRect is Image without Texts Rect in current OCanv.Buf coords (not DGrid coords)
    ImageRect := CellRect;
    Dec( ImageRect.Bottom, DGLAddDySize );
    TextGap := 3;
    N_SetNFont( N_CM_ThumbFrameFont, OCanv );
    with Thumbnail.DIBObj do // Draw Thumbnail
    begin
{
      if (AFlags and N_DGMarkBit) <> 0 then begin
        SetBrushAttribs( DGMarkBordColor );
        SetFontAttribs  ( $FFFFFF );
      end else
        SetFontAttribs ( $0 );
}
      TextColor := 0;
      TextBGColor := N_EmptyColor;
      if (AFlags and N_DGMarkBit) <> 0 then
      begin
        TextBGColor := DGMarkBordColor;
        SetBrushAttribs( DGMarkBordColor );
      end;

      if (AFlags and 2) <> 0 then
        TextBGColor := CMDSCSelTextBGColor;

      if (TextBGColor <> N_EmptyColor) and
         (K_CalcColorGrey8(TextBGColor) < 128 ) then
        TextColor := $FFFFFF; // Use White Text Color

      SetFontAttribs ( TextColor, TextBGColor );
      DrawPixFilledRect( Rect( CellRect.Left, ImageRect.Bottom + 1,
                               CellRect.Right, CellRect.Bottom ) );

      TextWidth := CellRect.Right - CellRect.Left - TextGap - TextGap;
      WStr := K_StrCutByWidth( DIBOCanv.HMDC, AStrings[0], '...', TextWidth );
      DrawUserString( DPoint(  0.5 * (CellRect.Left + CellRect.Right),
                               ImageRect.Bottom ), FPoint( 0, 2 ),
                               FPoint( 0.5, 0 ), WStr );

//      N_IR := DIBRect;
      ImageRect := N_DecRectbyAspect( ImageRect, N_RectAspect( DIBRect ) );
      N_StretchRect( HMDC, ImageRect, DIBOCanv.HMDC, DIBOCanv.CurCRect );
    end;

  end; // with ADGrid.DGRFrame, OCanv do


{
//  FillColor: integer;
//  Str: string;
//  CellSize: TPoint;
//  StrBasePoint: TDPoint;

  RelImageRect := Rect( TFCellBorderWidth, TFCellBorderWidth,
                        CellSize.X - TFCellBorderWidth - 1,
                        CellSize.X - TFCellBorderWidth - 1 );

  FillColor := $FFFFFF;
  if (K_dgdMarked in ADrawFlags) then FillColor := TFCellMarkColor;

  with TFCellOCanv do
  begin
    SetBrushAttribs( FillColor );
    DrawPixFilledRect( RelCellRect ); // Thumb border and Text background

    if (K_dgdSelected in ADrawFlags) then // Draw addidional border for Selected Cell
    begin
      SetBrushAttribs( TFCellSelectColor );
      DrawPixRectBorder( RelCellRect, TFCellSelectWidth );
    end;

    StrBasePoint.X := 0.5*RelCellRect.Right;
    StrBasePoint.Y := RelImageRect.Bottom + 0.5*TFCellTextHeight - 3;

    if CellSize.X >= TFMinTextWidth then // Text should be drawn
    begin
      DrawUserString( StrBasePoint, N_ZFPoint, FPoint( 0.5, 0 ), CurSlide.ObjName );

      StrBasePoint.Y := StrBasePoint.Y + TFCellTextHeight;
//      Str := K_DateTimeToStr( CurSlide.P()^.CMSLastWriteTime, 'dd.mm.yyyy' ); // 'dd.mm.yyyy hh:nn'
      Str := 'Second Row';
      DrawUserString( StrBasePoint, N_ZFPoint, FPoint( 0.5, 0 ), Str );
    end else // draw '...' instead of text
    begin
      StrBasePoint.Y := StrBasePoint.Y - 0.6*TFCellTextHeight;
      DrawUserString( StrBasePoint, N_ZFPoint, FPoint( 0.5, 0 ), '...' );
    end;
  end; // with TFCellOCanv do

  with Thumbnail.DIBObj do // Draw Thumbnail
  begin
    RelImageRect := N_DecRectbyAspect( RelImageRect, N_RectAspect( DIBRect ) );
    N_StretchRect( TFCellOCanv.HMDC, RelImageRect, DIBOCanv.HMDC, DIBOCanv.CurCRect );
  end;

  // Copy Thumbnail with border and texts from TFCellOCanv to DGridFrame ACanvas
  N_CopyRect( ACanvas.Handle, ARect.TopLeft, TFCellOCanv.HMDC, RelCellRect );
  Exit;
}

  EmptyCell: //**************************************
//  ACanvas.Brush.Color := $FFFFFF;
//  ACanvas.FillRect( ARect );

end; // procedure TN_CMDrawSlideObj.DrawOneThumb1

//****************************************** TN_CMDrawSlideObj.DrawOneThumb2 ***
// Draw One Thumb in Slide Properties Form
//
//     Parameters
// AUDCMSlide - Slide which Thumbnail should be drawn
// AStrings   - StringList with needed Strings to Draw
// ADGrid     - Thumbs Grid
// ARect      - Thumb Rect in current OCanv.Buf coords (not DGrid coords)
// AFlags     - Slide Draw Flags
//
// Shows Slide Text in the SLide Center using bold red font
// Used in Set Slides Attrs after Import Dialog and ECache Process Dialog (but bold text is not used)
//
procedure TN_CMDrawSlideObj.DrawOneThumb2( AUDCMSlide: TN_UDCMSlide; AStrings: TStrings;
                                          ADGrid: TN_DGridBase; ARect: TRect;
                                          AFlags : Byte );
var
  dy: integer;
  CellRect, ImageRect: TRect;
  Thumbnail: TN_UDDIB;
  TextWidth : Integer;
  TextGap : Integer;
  WStr : string;

begin
  Thumbnail := AUDCMSlide.GetThumbnail();

  if Thumbnail = nil then // a precaution
    Exit;

  with ADGrid, DGRFrame, OCanv do
  begin
    // CellRect is Image + Texts Rect in current OCanv.Buf coords (not DGrid coords)
    CellRect  := ARect;

    // ImageRect is Image without Texts Rect in current OCanv.Buf coords (not DGrid coords)
    ImageRect := CellRect;
//  Dec( ImageRect.Bottom, DGLAddDySize );
    TextGap := 3;
    N_SetNFont( N_CM_ThumbFramePropFont, OCanv );

    with Thumbnail.DIBObj do // Draw Thumbnail
    begin
      ImageRect := N_DecRectbyAspect( ImageRect, N_RectAspect( DIBRect ) );
      N_StretchRect( HMDC, ImageRect, DIBOCanv.HMDC, DIBOCanv.CurCRect );

      if (AStrings = nil) or (AStrings.Count = 0) or (AStrings[0] = '') then Exit;
      SetFontAttribs ( $1414FF );
//    DrawPixFilledRect( Rect( CellRect.Left, ImageRect.Bottom + 1,
//                             CellRect.Right, CellRect.Bottom ) );

      TextWidth := CellRect.Right - CellRect.Left - TextGap - TextGap;
      WStr := K_StrCutByWidth( DIBOCanv.HMDC, AStrings[0], '...', TextWidth );
      dy := Round( 0.25*(ImageRect.Bottom-ImageRect.Top) );
      DrawUserString( DPoint(  0.5 * (CellRect.Left + CellRect.Right),
                               CellRect.Top ), FPoint( 0, dy ),
                               FPoint( 0.5, 0 ), WStr );
    end; // with Thumbnail.DIBObj do // Draw Thumbnail

  end; // with ADGrid.DGRFrame, OCanv do

end; // procedure TN_CMDrawSlideObj.DrawOneThumb2

//****************************************** TN_CMDrawSlideObj.DrawOneThumb3 ***
// Draw One Thumb in Capture Video Form
//
//     Parameters
// AUDCMSlide - Slide which Thumbnail should be drawn
// AStrings   - StringList with needed Strings to Draw
// ADGrid     - Thumbs Grid
// ARect      - Thumb Rect in current OCanv.Buf coords (not DGrid coords)
// AFlags     - Slide Draw Flags
//
// Used in Video Form
//
procedure TN_CMDrawSlideObj.DrawOneThumb3( AUDCMSlide: TN_UDCMSlide; AStrings: TStrings;
                                          ADGrid: TN_DGridBase; ARect: TRect;
                                          AFlags: Byte );
var
//  i: integer;
  CellRect, ImageRect: TRect;
  Thumbnail: TN_UDDIB;
  TextWidth : Integer;
  TextGap : Integer;
  WStr : string;

begin
  Thumbnail := AUDCMSlide.GetThumbnail();

  if Thumbnail = nil then // a precaution
    Exit;

//  for i := 0 to High(CMDSFonts) do // create Font handles if not yet
//    N_CreateFontHandle( @CMDSFonts, DSLPFontPixHeight );


  with ADGrid, DGRFrame, OCanv do
  begin
    // CellRect is Image + Texts Rect in current OCanv.Buf coords (not DGrid coords)
    CellRect  := ARect;

    // ImageRect is Image without Texts Rect in current OCanv.Buf coords (not DGrid coords)
    ImageRect := CellRect;
//  Dec( ImageRect.Bottom, DGLAddDySize );
    TextGap := 3;
    N_SetNFont( N_CM_ThumbFrameCaptFont, OCanv );

    with Thumbnail.DIBObj do // Draw Thumbnail
    begin
      ImageRect := N_DecRectbyAspect( ImageRect, N_RectAspect( DIBRect ) );
      N_StretchRect( HMDC, ImageRect, DIBOCanv.HMDC, DIBOCanv.CurCRect );

      SetFontAttribs ( $1414FF, 0 );
//    DrawPixFilledRect( Rect( CellRect.Left, ImageRect.Bottom + 1,
//                             CellRect.Right, CellRect.Bottom ) );

      TextWidth := CellRect.Right - CellRect.Left - TextGap - TextGap;
      WStr := K_StrCutByWidth( DIBOCanv.HMDC, ' ' + AStrings[0], '...',
                               TextWidth );
{
      DrawUserString( DPoint(  0.5 * (CellRect.Left + CellRect.Right),
                               CellRect.Top ), FPoint( 0, 40 ),
                               FPoint( 0.5, 0 ), WStr );
}

//      DrawUserString( DPoint(  CellRect.Right,
//                               CellRect.Top ), FPoint( 0, 1 ),
//                               FPoint( 1.1, 0 ), WStr );
      DrawUserString( DPoint(  CellRect.Right,
                               CellRect.Top ), FPoint( 0, 0 ),
                               FPoint( 1, 0 ), WStr );

    end;

  end; // with ADGrid.DGRFrame, OCanv do

end; // procedure TN_CMDrawSlideObj.DrawOneThumb3

//***************************************** TN_CMDrawSlideObj.DrawOneThumb4 ***
// Draw One Thumb with Colored circle in upper left corner
//
//     Parameters
// AUDCMSlide - Slide which Thumbnail should be drawn
// AStrings   - StringList with needed Strings to Draw
// ADGrid     - Thumbs Grid
// ARect      - Thumb Rect in current OCanv.Buf coords (not DGrid coords)
// AFlags     - Slide Draw Flags
//
// Shows Slide Text Two Lines (Date and Teeth Info) under the SLide using normal black font
// Used in Main Thumbnails Frame
//
procedure TN_CMDrawSlideObj.DrawOneThumb4( AUDCMSlide: TN_UDCMSlide; AStrings: TStrings;
                                           ADGrid: TN_DGridBase; ARect: TRect;
                                           AFlags: Byte );
var
//  i: integer;
  CellRect, ImageRect, MarkRect: TRect;
  Thumbnail: TN_UDDIB;
  TextWidth : Integer;
  TextGap : Integer;
  WStr : string;
  Label EmptyCell;
begin
  Thumbnail := AUDCMSlide.GetThumbnail();

  if Thumbnail = nil then // a precaution
    goto EmptyCell;

  with ADGrid, DGRFrame, OCanv do
  begin
    // CellRect is Image + Texts Rect in current OCanv.Buf coords (not DGrid coords)
    CellRect  := ARect;

    // ImageRect is Image without Texts Rect in current OCanv.Buf coords (not DGrid coords)
    ImageRect := CellRect;
    Dec( ImageRect.Bottom, DGLAddDySize );
    TextGap := 3;
    N_SetNFont( N_CM_ThumbFrameFont, OCanv );

    with Thumbnail.DIBObj do // Draw Thumbnail
    begin
      if (AFlags and N_DGMarkBit) <> 0 then begin
        SetBrushAttribs( DGMarkBordColor );
        SetFontAttribs  ( $FFFFFF );
      end else
        SetFontAttribs ( $0 );
      DrawPixFilledRect( Rect( CellRect.Left, ImageRect.Bottom + 1,
                               CellRect.Right, CellRect.Bottom ) );

      TextWidth := CellRect.Right - CellRect.Left - TextGap - TextGap;
      WStr := K_StrCutByWidth( DIBOCanv.HMDC, AStrings[0], '...', TextWidth );
      DrawUserString( DPoint(  0.5 * (CellRect.Left + CellRect.Right),
                               ImageRect.Bottom ), FPoint( 0, 2 ),
                               FPoint( 0.5, 0 ), WStr );
      WStr := K_StrCutByWidth( DIBOCanv.HMDC, AStrings[1], '...', TextWidth );
      DrawUserString( DPoint(  0.5 * (CellRect.Left + CellRect.Right),
                               ImageRect.Bottom ), FPoint( 0, 14 ),
                               FPoint( 0.5, 0 ), WStr );

//      N_IR := DIBRect;
//      ImageRect := N_DecRectbyAspect( ImageRect, N_RectAspect( DIBRect ) );
      N_StretchRect( HMDC, ImageRect, DIBOCanv.HMDC, DIBOCanv.CurCRect );

      if K_CMEnterpriseModeFlag then // Draw Colored mark over the Thumbnail
      begin
        with ImageRect do // MarkRect is in upper left corner of ImageRect
          MarkRect := Rect( Left+4, Top+4, Left+18, Top+18 );

        case AUDCMSlide.CMSlideEdState of
          K_edsFullAccess:  DrawPixEllipse( MarkRect, $00FF00, -1, 0 ); // Green circle
          K_edsSkipChanges: DrawPixEllipse( MarkRect, $00FFFF, -1, 0 ); // Yellow circle
          K_edsSkipOpen:    DrawPixEllipse( MarkRect, $0000FF, -1, 0 ); // Red circle
        end; // case CMSlideEdState of

      end; // if K_CMEnterpriseModeFlag then // Draw Colored mark over the Thumbnail

      if AUDCMSlide.CMSDBStateFlags <> [] then
        DrawPixRectSegments( $0000FF, 3, ImageRect, $020 );

    end; // with Thumbnail.DIBObj do // Draw Thumbnail

  end; // with ADGrid.DGRFrame, OCanv do

  EmptyCell: //**************************************
//  ACanvas.Brush.Color := $FFFFFF;
//  ACanvas.FillRect( ARect );

end; // procedure TN_CMDrawSlideObj.DrawOneThumb4

//***************************************** TN_CMDrawSlideObj.DrawOneThumb5 ***
// Draw One Thumb in CMOther2Form
//
//     Parameters
// AUDCMSlide - Slide which Thumbnail should be drawn
// AStrings   - StringList with needed Strings to Draw
// ADGrid     - Thumbs Grid
// ARect      - Thumb Rect in current OCanv.Buf coords (not DGrid coords)
// AFlags     - Slide Draw Flags
//
// Used in Video Form
//
procedure TN_CMDrawSlideObj.DrawOneThumb5( AUDCMSlide: TN_UDCMSlide; AStrings: TStrings;
                                           ADGrid: TN_DGridBase; ARect: TRect;
                                           AFlags: Byte );
var
  CellRect, ImageRect: TRect;
  Thumbnail: TN_UDDIB;
  TextWidth : Integer;
  TextGap : Integer;
  WStr : string;

begin
  Thumbnail := AUDCMSlide.GetThumbnail();

  if Thumbnail = nil then // a precaution
    Exit;

  with ADGrid, DGRFrame, OCanv do
  begin
    // CellRect is Image + Texts Rect in current OCanv.Buf coords (not DGrid coords)
    CellRect  := ARect;

    // ImageRect is Image without Texts Rect in current OCanv.Buf coords (not DGrid coords)
    ImageRect := CellRect;
    TextGap := 3;
    N_SetNFont( N_CM_ThumbFrameCaptFont, OCanv );

    with Thumbnail.DIBObj do // Draw Thumbnail
    begin
      ImageRect := N_DecRectbyAspect( ImageRect, N_RectAspect( DIBRect ) );
      N_StretchRect( HMDC, ImageRect, DIBOCanv.HMDC, DIBOCanv.CurCRect );

      // Draw Red AStrings[0] on white background in upper left corner
      SetFontAttribs ( $1414FF, $FFFFFF );
      TextWidth := CellRect.Right - CellRect.Left - TextGap - TextGap;
      WStr := K_StrCutByWidth( DIBOCanv.HMDC, ' ' + AStrings[0], '...', TextWidth );
      DrawUserString( DPoint(CellRect.Left,CellRect.Top), FPoint(0,0), FPoint(0,0), WStr );
    end; // with Thumbnail.DIBObj do // Draw Thumbnail

  end; // with ADGrid.DGRFrame, OCanv do

end; // procedure TN_CMDrawSlideObj.DrawOneThumb5

//***************************************** TN_CMDrawSlideObj.DrawOneThumb6 ***
// Draw One Thumb with (if needed) Colored circle in upper left corner
// and with red diagonals cross for deleted slides
//
//     Parameters
// AUDCMSlide  - Slide which Thumbnail should be drawn
// AStrings    - StringList with needed Strings to Draw
// ANumStrings - Number of strings to draw
// ADGrid      - Thumbs Grid
// ARect       - Thumb Rect in current OCanv.Buf coords (not DGrid coords)
// AFlags      - Slide Draw Flags
//
// Shows Slide Text Two Lines (Date and Teeth Info) under the SLide using normal black font
// Used in Main Thumbnails Frame
//
procedure TN_CMDrawSlideObj.DrawOneThumb6( AUDCMSlide: TN_UDCMSlide;
                                           AStrings: TStrings; ANumStrings: integer;
                                           ADGrid: TN_DGridBase; ARect: TRect;
                                           AFlags: Byte );
var
  i: integer;
  CellRect, ImageRect, MarkRect, VisRect: TRect;
  TextWidth : Integer;
  TextGap : Integer;
  WStr : string;
  AffCoefs4: TN_AffCoefs4;
  Thumbnail: TN_UDDIB;
begin
  Thumbnail := AUDCMSlide.GetThumbnail();

  if Thumbnail = nil then Exit; // a precaution

  with ADGrid, DGRFrame, OCanv do
  begin
    // CellRect is Image + Texts Rect in current OCanv.Buf coords (not DGrid coords)
    CellRect  := ARect;

    // ImageRect is Image without Texts Rect in current OCanv.Buf coords (not DGrid coords)
    ImageRect := CellRect;
    Dec( ImageRect.Bottom, DGLAddDySize );
    TextGap := 3;
    N_SetNFont( N_CM_ThumbFrameFont, OCanv );

    with Thumbnail.DIBObj do // Draw Thumbnail
    begin
      if (AFlags and N_DGMarkBit) <> 0 then begin
        SetBrushAttribs( DGMarkBordColor );
        SetFontAttribs  ( $FFFFFF );
      end else
        SetFontAttribs ( $0 );

      DrawPixFilledRect( Rect( CellRect.Left, ImageRect.Bottom + 1,
                               CellRect.Right, CellRect.Bottom ) );

      TextWidth := CellRect.Right - CellRect.Left - TextGap - TextGap;

      for i := 0 to ANumStrings-1 do // draw given number of strings
      begin
        WStr := K_StrCutByWidth( DIBOCanv.HMDC, AStrings[i], '...', TextWidth );
        DrawUserString( DPoint(  0.5 * (CellRect.Left + CellRect.Right),
                 ImageRect.Bottom ), FPoint( 0, i*N_CM_ThumbFrameRowHeight+2 ),
                                                      FPoint( 0.5, 0 ), WStr );
      end; // for i := 0 to ANumStrings-1 do // draw given number of strings

//      Windows.SetStretchBltMode( HMDC, HALFTONE );
//      Windows.SetStretchBltMode( DIBOCanv.HMDC, HALFTONE );

      // force same aspect (is really needed if NumColumns (or NumRows) > 1)
      ImageRect := N_DecRectbyAspect( ImageRect, N_RectAspect( DIBOCanv.CurCRect ) );
//      N_d1 := N_RectAspect( ImageRect ); // debug
//      N_d2 := N_RectAspect( DIBOCanv.CurCRect );

      N_StretchRect( HMDC, ImageRect, DIBOCanv.HMDC, DIBOCanv.CurCRect );

//        DrawPixDIB( Thumbnail.DIBObj, CellRect, Rect(0,0,-1,-1) );
//      Thumbnail.DIBObj.SaveToBMPFormat( N_CreateUniqueFileName( 'C:\aThumb.bmp' ) );

      if AUDCMSlide.CMSRFrame <> nil then
      with AUDCMSlide.CMSRFrame do
      begin
        if RFGetCurRelObjSize() > 1.001 then
        begin
          AffCoefs4 := N_CalcAffCoefs4( RFLogFramePRect, ImageRect );
          VisRect := N_AffConvI2IRect( RFSrcPRect, AffCoefs4 );
          Dec( VisRect.Right );
          Dec( VisRect.Bottom );
          DrawPixRectBorder2( VisRect, 1, $FF );
        end;
      end;

      if K_CMEnterpriseModeFlag then // Draw Colored mark over the Thumbnail
      begin
        with ImageRect do // MarkRect is in upper left corner of ImageRect
          MarkRect := Rect( Left+4, Top+4, Left+18, Top+18 );

        case AUDCMSlide.CMSlideEdState of
          K_edsFullAccess:  DrawPixEllipse( MarkRect, $00FF00, -1, 0 ); // Green circle
          K_edsSkipChanges: DrawPixEllipse( MarkRect, $00FFFF, -1, 0 ); // Yellow circle
          K_edsSkipOpen:    DrawPixEllipse( MarkRect, $0000FF, -1, 0 ); // Red circle
        end; // case CMSlideEdState of

      end; // if K_CMEnterpriseModeFlag then // Draw Colored mark over the Thumbnail

      if AUDCMSlide.CMSDBStateFlags <> [] then
        DrawPixRectSegments( $0000FF, 3, ImageRect, $020 );

    end; // with Thumbnail.DIBObj do // Draw Thumbnail

  end; // with ADGrid.DGRFrame, OCanv do

end; // procedure TN_CMDrawSlideObj.DrawOneThumb6

//***************************************** TN_CMDrawSlideObj.DrawOneThumb7 ***
// Draw One Thumb with variable number of footer text lines
//
//     Parameters
// AUDCMSlide  - Slide which Thumbnail should be drawn
// AStrings    - StringList with needed Strings to Draw
// ANumStrings - Number of strings to draw
// ADGrid      - Thumbs Grid
// ARect       - Thumb Rect in current OCanv.Buf coords (not DGrid coords)
// AFlags      - Slide Draw Flags
//
// Used in Main Thumbnails Frame
//
procedure TN_CMDrawSlideObj.DrawOneThumb7( AUDCMSlide: TN_UDCMSlide;
                                           AStrings: TStrings; ANumStrings: integer;
                                           ADGrid: TN_DGridBase; ARect: TRect;
                                           AFlags: Byte );
var
  i, NumSlidesInStudy: integer;
  CellRect, ImageRect, MarkRect, VisRect, HalfRect, QuoterRect1, QuoterRect2: TRect;
  TextWidth, TextXGap, AllTextRectsHeight: Integer;
  WStr: string;
  AffCoefs4: TN_AffCoefs4;
  Thumbnail, FrontThumb, SideThumb: TN_UDDIB;
  TextBGColor : integer;
  TextColor : Integer;
begin
  Thumbnail := AUDCMSlide.GetThumbnail();

  if Thumbnail = nil then Exit; // a precaution

  with ADGrid, DGRFrame, OCanv do
  begin
    // CellRect is Image + Texts Rect in current OCanv.Buf coords (not DGrid coords)
    CellRect  := ARect;

    // ImageRect is Image without Texts Rect in current OCanv.Buf coords (not DGrid coords)

    ImageRect := CellRect;
//         if AStrings[0][1] = '0' then ANumStrings := 1; // debug
    AllTextRectsHeight := 4 + N_CM_ThumbFrameRowHeight * ANumStrings;
    Dec( ImageRect.Bottom, AllTextRectsHeight );
    TextXGap := 3;
    N_SetNFont( N_CM_ThumbFrameFont, OCanv );

    with Thumbnail.DIBObj do // Draw Thumbnail
    begin
      //***** Fill Background (CellRect) by DGMarkBordColor or by ???

      TextColor := 0;
      TextBGColor := N_EmptyColor;
      if (AFlags and N_DGMarkBit) <> 0 then
      begin
        TextBGColor := DGMarkBordColor;
        SetBrushAttribs( DGMarkBordColor );
      end;

      if (AFlags and 2) <> 0 then
        TextBGColor := CMDSCSelTextBGColor;

      if (TextBGColor <> N_EmptyColor) and
         (K_CalcColorGrey8(TextBGColor) < 128 ) then
        TextColor := $FFFFFF; // Use White Text Color

      SetFontAttribs ( TextColor, TextBGColor );

      DrawPixFilledRect( Rect( CellRect.Left, ImageRect.Bottom + 1,
                               CellRect.Right, CellRect.Bottom ) );

      //***** Draw given Text strings

      TextWidth := CellRect.Right - CellRect.Left - 2*TextXGap;

      for i := 0 to ANumStrings-1 do // draw given number of strings
      begin
//      N_s1:= AStrings[2];
        WStr := K_StrCutByWidth( DIBOCanv.HMDC, AStrings[i], '...', TextWidth );
//      N_s2= AStrings[2];
        DrawUserString( DPoint(  0.5 * (CellRect.Left + CellRect.Right),
                 ImageRect.Bottom ), FPoint( 0, i*N_CM_ThumbFrameRowHeight+2 ),
                                                      FPoint( 0.5, 0 ), WStr );
      end; // for i := 0 to ANumStrings-1 do // draw given number of strings

      //***** Draw Thumb Image

      if K_CMSMainUIShowMode <> 1 then // normal (not Photometry mode)
//      if True then // normal (not Photometry mode)
      begin
        // force same aspect (is really needed if NumColumns (or NumRows) > 1)
        ImageRect := N_DecRectbyAspect( ImageRect, N_RectAspect( DIBOCanv.CurCRect ) );
        N_StretchRect( HMDC, ImageRect, DIBOCanv.HMDC, DIBOCanv.CurCRect );
      end else // Photometry mode
      begin
        NumSlidesInStudy := TN_UDCMStudy(AUDCMSlide).CMSStudyItemsCount; // 2 or 4

        if NumSlidesInStudy = 2 then // two-slides Study
        begin
          HalfRect := ImageRect;
          HalfRect.Right := HalfRect.Left + (HalfRect.Right-HalfRect.Left) div 2;

          FrontThumb := TN_UDCMStudy(AUDCMSlide).GetItemThumbnailByIndex( 0 );
          if FrontThumb <> nil then
          begin
            HalfRect := N_DecRectbyAspect( HalfRect, N_RectAspect( FrontThumb.DIBObj.DIBOCanv.CurCRect ) );
            N_StretchRect( HMDC, HalfRect, FrontThumb.DIBObj.DIBOCanv.HMDC, FrontThumb.DIBObj.DIBOCanv.CurCRect );
          end;

          HalfRect.Left  := HalfRect.Right + 1;
          HalfRect.Right := ImageRect.Right;

          SideThumb  := TN_UDCMStudy(AUDCMSlide).GetItemThumbnailByIndex( 1 );
          if SideThumb <> nil then
          begin
            HalfRect := N_DecRectbyAspect( HalfRect, N_RectAspect( SideThumb.DIBObj.DIBOCanv.CurCRect ) );
            N_StretchRect( HMDC, HalfRect, SideThumb.DIBObj.DIBOCanv.HMDC, SideThumb.DIBObj.DIBOCanv.CurCRect );
          end;
        end else  // four-slides Study
        begin
          // Set QuoterRect1 to upper left ImageRect quoter
          QuoterRect1 := ImageRect;
          QuoterRect1.Right  := QuoterRect1.Left + (QuoterRect1.Right-QuoterRect1.Left) div 2;
          QuoterRect1.Bottom := QuoterRect1.Top  + (QuoterRect1.Bottom-QuoterRect1.Top) div 2;

          FrontThumb := TN_UDCMStudy(AUDCMSlide).GetItemThumbnailByIndex( 0 );
          if FrontThumb <> nil then
          begin
            QuoterRect2 := N_DecRectbyAspect( QuoterRect1, N_RectAspect( FrontThumb.DIBObj.DIBOCanv.CurCRect ) );
            N_StretchRect( HMDC, QuoterRect2, FrontThumb.DIBObj.DIBOCanv.HMDC, FrontThumb.DIBObj.DIBOCanv.CurCRect );
          end;

          // Set QuoterRect1 to upper right ImageRect quoter
          QuoterRect1.Left  := QuoterRect1.Right + 1;
          QuoterRect1.Right := ImageRect.Right;

          SideThumb  := TN_UDCMStudy(AUDCMSlide).GetItemThumbnailByIndex( 1 );
          if SideThumb <> nil then
          begin
            QuoterRect2 := N_DecRectbyAspect( QuoterRect1, N_RectAspect( SideThumb.DIBObj.DIBOCanv.CurCRect ) );
            N_StretchRect( HMDC, QuoterRect2, SideThumb.DIBObj.DIBOCanv.HMDC, SideThumb.DIBObj.DIBOCanv.CurCRect );
          end;

          // Set QuoterRect1 to lower left ImageRect quoter
          QuoterRect1.Right  := QuoterRect1.Left - 1;
          QuoterRect1.Left   := ImageRect.Left;
          QuoterRect1.Top    := QuoterRect1.Bottom + 1;
          QuoterRect1.Bottom := ImageRect.Bottom;

          FrontThumb  := TN_UDCMStudy(AUDCMSlide).GetItemThumbnailByIndex( 2 );
          if FrontThumb <> nil then
          begin
            QuoterRect2 := N_DecRectbyAspect( QuoterRect1, N_RectAspect( SideThumb.DIBObj.DIBOCanv.CurCRect ) );
            N_StretchRect( HMDC, QuoterRect2, FrontThumb.DIBObj.DIBOCanv.HMDC, FrontThumb.DIBObj.DIBOCanv.CurCRect );
          end;

          // Set QuoterRect1 to lower right ImageRect quoter
          QuoterRect1.Left  := QuoterRect1.Right + 1;
          QuoterRect1.Right := ImageRect.Right;

          SideThumb  := TN_UDCMStudy(AUDCMSlide).GetItemThumbnailByIndex( 3 );
          if SideThumb <> nil then
          begin
            QuoterRect2 := N_DecRectbyAspect( QuoterRect1, N_RectAspect( SideThumb.DIBObj.DIBOCanv.CurCRect ) );
            N_StretchRect( HMDC, QuoterRect2, SideThumb.DIBObj.DIBOCanv.HMDC, SideThumb.DIBObj.DIBOCanv.CurCRect );
          end;

        end; // else  // four-slides Study

      end; //  else // Photometry mode

      //***** Draw red Visibility rect if not whole Image is visible

      if AUDCMSlide.CMSRFrame <> nil then
      with AUDCMSlide.CMSRFrame do
      begin
        if RFGetCurRelObjSize() > 1.001 then // Image is magnified
        begin
          AffCoefs4 := N_CalcAffCoefs4( RFLogFramePRect, ImageRect );
          VisRect := N_AffConvI2IRect( RFSrcPRect, AffCoefs4 );
          Dec( VisRect.Right );
          Dec( VisRect.Bottom );
          DrawPixRectBorder2( VisRect, 1, $FF );
        end; // if RFGetCurRelObjSize() > 1.001 then // Image is magnified
      end;

      //***** Draw Colored circle in upper left corner, in enterprise mode only

      if K_CMEnterpriseModeFlag then // Draw Colored mark over the Thumbnail
      begin
        with ImageRect do // MarkRect is in upper left corner of ImageRect
          MarkRect := Rect( Left+4, Top+4, Left+18, Top+18 );

        case AUDCMSlide.CMSlideEdState of
          K_edsFullAccess:  DrawPixEllipse( MarkRect, $00FF00, -1, 0 ); // Green circle
          K_edsSkipChanges: DrawPixEllipse( MarkRect, $00FFFF, -1, 0 ); // Yellow circle
          K_edsSkipOpen:    DrawPixEllipse( MarkRect, $0000FF, -1, 0 ); // Red circle
        end; // case CMSlideEdState of

      end; // if K_CMEnterpriseModeFlag then // Draw Colored mark over the Thumbnail

      //***** Draw red diagonal over some (deleted?) slides

      if AUDCMSlide.CMSDBStateFlags <> [] then
        DrawPixRectSegments( $0000FF, 3, ImageRect, $020 );

      //***** Draw CellRect border (Mark currently active Mount)

//      CMDSCSelBordWidth := 2;   // for debug
//      CMDSCSelColor := $00FF00; // for debug

      if (AFlags and $01) <> 0 then // currently active Mount, mark it
      begin
        DrawPixRectBorder2( CellRect, CMDSCSelBordWidth, CMDSCSelColor );
      end; // if (AFlags and $01) <> 0 then // currently active Mount, mark it

    end; // with Thumbnail.DIBObj do // Draw Thumbnail

  end; // with ADGrid.DGRFrame, OCanv do

end; // procedure TN_CMDrawSlideObj.DrawOneThumb7

//***************************************** TN_CMDrawSlideObj.DrawOneThumb8 ***
// Draw One Thumb with variable number of footer text lines
//
//     Parameters
// AUDCMSlide  - Slide which Thumbnail should be drawn
// AStrings    - StringList with needed Strings to Draw
// ANumStrings - Number of strings to draw
// ADGrid      - Thumbs Grid
// ARect       - Thumb Rect in current OCanv.Buf coords (not DGrid coords)
// ARFrame     - RFrame where Slide is shown to draw zoom state on SLide icon 
// AFlags      - Slide Draw Flags
//
// Used in Main Thumbnails Frame
//
procedure TN_CMDrawSlideObj.DrawOneThumb8( AUDCMSlide: TN_UDCMSlide;
                                           AStrings: TStrings; ANumStrings: integer;
                                           ADGrid: TN_DGridBase; ARect: TRect;
                                           ARFrame : TN_Rast1Frame;
                                           AFlags: Byte );
var
  i: integer;
  CellRect, ImageRect, VisRect: TRect;
  TextWidth, TextXGap, AllTextRectsHeight: Integer;
  WStr: string;
  AffCoefs4: TN_AffCoefs4;
  Thumbnail: TN_UDDIB;
  TextBGColor : integer;
  TextColor : Integer;
begin
  Thumbnail := AUDCMSlide.GetThumbnail();

  if Thumbnail = nil then Exit; // a precaution

  with ADGrid, DGRFrame, OCanv do
  begin
    // CellRect is Image + Texts Rect in current OCanv.Buf coords (not DGrid coords)
    CellRect  := ARect;

    // ImageRect is Image without Texts Rect in current OCanv.Buf coords (not DGrid coords)

    ImageRect := CellRect;
//         if AStrings[0][1] = '0' then ANumStrings := 1; // debug
    AllTextRectsHeight := 4 + N_CM_ThumbFrameRowHeight * ANumStrings;
    Dec( ImageRect.Bottom, AllTextRectsHeight );
    TextXGap := 3;
    N_SetNFont( N_CM_ThumbFrameFont, OCanv );

    with Thumbnail.DIBObj do // Draw Thumbnail
    begin
      //***** Fill Background (CellRect) by DGMarkBordColor or by ???

      TextColor := 0;
      TextBGColor := N_EmptyColor;
      if (AFlags and N_DGMarkBit) <> 0 then
      begin
        TextBGColor := DGMarkBordColor;
        SetBrushAttribs( DGMarkBordColor );
      end;

      if (AFlags and 2) <> 0 then
        TextBGColor := CMDSCSelTextBGColor;

      if (TextBGColor <> N_EmptyColor) and
         (K_CalcColorGrey8(TextBGColor) < 128 ) then
        TextColor := $FFFFFF; // Use White Text Color

      SetFontAttribs ( TextColor, TextBGColor );

      DrawPixFilledRect( Rect( CellRect.Left, ImageRect.Bottom + 1,
                               CellRect.Right, CellRect.Bottom ) );

      //***** Draw given Text strings

      TextWidth := CellRect.Right - CellRect.Left - 2*TextXGap;

      for i := 0 to ANumStrings-1 do // draw given number of strings
      begin
//      N_s1:= AStrings[2];
        if AStrings[i] = '' then Continue;
        WStr := K_StrCutByWidth( DIBOCanv.HMDC, AStrings[i], '...', TextWidth );
//      N_s2= AStrings[2];
        DrawUserString( DPoint(  0.5 * (CellRect.Left + CellRect.Right),
                 ImageRect.Bottom ), FPoint( 0, i*N_CM_ThumbFrameRowHeight+2 ),
                                                      FPoint( 0.5, 0 ), WStr );
      end; // for i := 0 to ANumStrings-1 do // draw given number of strings

      //***** Draw Thumb Image

      // force same aspect (is really needed if NumColumns (or NumRows) > 1)
      ImageRect := N_DecRectbyAspect( ImageRect, N_RectAspect( DIBOCanv.CurCRect ) );
      N_StretchRect( HMDC, ImageRect, DIBOCanv.HMDC, DIBOCanv.CurCRect );

      //***** Draw red Visibility rect if not whole Image is visible

      if ARFrame <> nil then
      with ARFrame do
      begin
        if RFGetCurRelObjSize() > 1.001 then // Image is magnified
        begin
          AffCoefs4 := N_CalcAffCoefs4( RFLogFramePRect, ImageRect );
          VisRect := N_AffConvI2IRect( RFSrcPRect, AffCoefs4 );
          Dec( VisRect.Right );
          Dec( VisRect.Bottom );
          DrawPixRectBorder2( VisRect, 1, $FF );
        end; // if RFGetCurRelObjSize() > 1.001 then // Image is magnified
      end;

      if (AFlags and $01) <> 0 then // currently active Mount, mark it
      begin
        DrawPixRectBorder2( CellRect, CMDSCSelBordWidth, CMDSCSelColor );
      end; // if (AFlags and $01) <> 0 then // currently active Mount, mark it

    end; // with Thumbnail.DIBObj do // Draw Thumbnail

  end; // with ADGrid.DGRFrame, OCanv do

end; // procedure TN_CMDrawSlideObj.DrawOneThumb8

//***************************************** TN_CMDrawSlideObj.DrawOneThumb9 ***
// Draw One Thumb with variable number of footer text lines
//
//     Parameters
// AUDCMSlide  - Slide which Thumbnail should be drawn
// AStrings    - StringList with needed Strings to Draw
// ANumStrings - Number of strings to draw
// ADGrid      - Thumbs Grid
// ARect       - Thumb Rect in current OCanv.Buf coords (not DGrid coords)
// ARFrame     - RFrame where Slide is shown to draw zoom state on SLide icon
// AFlags      - Slide Draw Flags
//
// Used in Main Thumbnails Frame
//
procedure TN_CMDrawSlideObj.DrawOneThumb9( AUDCMSlide: TN_UDCMSlide;
                                           AStrings: TStrings; ANumStrings: integer;
                                           ADGrid: TN_DGridBase; ARect: TRect;
                                           AFlags: Byte );
var
  i: integer;
  CellRect, ImageRect: TRect;
  TextWidth, TextXGap, AllTextRectsHeight: Integer;
  WStr: string;
  Thumbnail: TN_UDDIB;
  TextBGColor : integer;
  TextColor : Integer;
  dy: integer;
begin
  Thumbnail := AUDCMSlide.GetThumbnail();

  if Thumbnail = nil then Exit; // a precaution

  with ADGrid, DGRFrame, OCanv do
  begin
    // CellRect is Image + Texts Rect in current OCanv.Buf coords (not DGrid coords)
    CellRect  := ARect;

    // ImageRect is Image without Texts Rect in current OCanv.Buf coords (not DGrid coords)

    ImageRect := CellRect;
//         if AStrings[0][1] = '0' then ANumStrings := 1; // debug
    AllTextRectsHeight := 4 + N_CM_ThumbFrameRowHeight * (ANumStrings - 1);
    Dec( ImageRect.Bottom, AllTextRectsHeight );
    TextXGap := 3;
    N_SetNFont( N_CM_ThumbFrameFont, OCanv );

    with Thumbnail.DIBObj do // Draw Thumbnail
    begin
      //***** Fill Background (CellRect) by DGMarkBordColor or by ???

      TextColor := 0;
      TextBGColor := N_EmptyColor;
      if (AFlags and N_DGMarkBit) <> 0 then
      begin
        TextBGColor := DGMarkBordColor;
        SetBrushAttribs( DGMarkBordColor );
      end;

      if (AFlags and 2) <> 0 then
        TextBGColor := CMDSCSelTextBGColor;

      if (TextBGColor <> N_EmptyColor) and
         (K_CalcColorGrey8(TextBGColor) < 128 ) then
        TextColor := $FFFFFF; // Use White Text Color

      SetFontAttribs ( TextColor, TextBGColor );

      DrawPixFilledRect( Rect( CellRect.Left, ImageRect.Bottom + 1,
                               CellRect.Right, CellRect.Bottom ) );

      //***** Draw given Text strings

      TextWidth := CellRect.Right - CellRect.Left - 2*TextXGap;

      for i := 1 to ANumStrings-1 do // draw given number of strings
      begin
        if AStrings[i] = '' then Continue;
        WStr := K_StrCutByWidth( DIBOCanv.HMDC, AStrings[i], '...', TextWidth );
        DrawUserString( DPoint(  0.5 * (CellRect.Left + CellRect.Right),
                 ImageRect.Bottom ), FPoint( 0, (i - 1)*N_CM_ThumbFrameRowHeight+2 ),
                                                      FPoint( 0.5, 0 ), WStr );
      end; // for i := 0 to ANumStrings-1 do // draw given number of strings

      //***** Draw Thumb Image

      // force same aspect (is really needed if NumColumns (or NumRows) > 1)
      ImageRect := N_DecRectbyAspect( ImageRect, N_RectAspect( DIBOCanv.CurCRect ) );
      N_StretchRect( HMDC, ImageRect, DIBOCanv.HMDC, DIBOCanv.CurCRect );

      N_SetNFont( N_CM_ThumbFramePropFont, OCanv );
      SetFontAttribs ( $1414FF );

      WStr := K_StrCutByWidth( DIBOCanv.HMDC, AStrings[0], '...', TextWidth );
      dy := Round( 0.25*(ImageRect.Bottom-ImageRect.Top) );
      DrawUserString( DPoint(  0.5 * (CellRect.Left + CellRect.Right),
                               CellRect.Top ), FPoint( 0, dy ),
                               FPoint( 0.5, 0 ), WStr );
    end; // with Thumbnail.DIBObj do // Draw Thumbnail

  end; // with ADGrid.DGRFrame, OCanv do

end; // procedure TN_CMDrawSlideObj.DrawOneThumb9

//**************************************************** N_PrepHorThumbRFrame ***
// Prepare Horizontal ThumbFrame, create and prepare DGrid object
//
//     Parameters
procedure N_PrepHorThumbRFrame( AThumbFrame: TN_Rast1Frame; ANumItems: integer;
                               var AThumbsDGrid: TN_DGridUniMatr );
begin
  if AThumbsDGrid = nil then
    AThumbsDGrid := TN_DGridUniMatr.Create( AThumbFrame );

  with AThumbsDGrid do
  begin
    DGNumItems := ANumItems;
    DGGaps := Point( 10, 10 );

    DGLFixNumCols   := 0;
    DGLFixNumRows   := 1;
    DGSkipSelecting := True;
    DGChangeRCbyAK  := True;

    DGMarkBordColor := $BB0000;
    DGMarkNormWidth := 3;
    DGNormBordColor := $CCCCCC;
  end; // with AThumbsDGrid do
end; //*** end of procedure N_PrepHorThumbRFrame


end.
