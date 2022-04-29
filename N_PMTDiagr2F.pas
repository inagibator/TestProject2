unit N_PMTDiagr2F;
// Show Photometry Diagram using Rast1Frame

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ComCtrls, ToolWin, ExtCtrls,
  N_Rast1Fr;

type TN_PMTDiagr2Form = class(  TN_BaseForm  ) // Form to show Diagram
    RFrame1: TN_Rast1Frame;
end; // type TN_PMTDiagr2Form = class( TForm )

//var
//  N_PMTDiagr2Form: TN_PMTDiagr2Form;

procedure N_ShowPMTDiagram2();

implementation

{$R *.dfm}

uses
  K_Script1, K_UDT2, K_CLib0, K_CLib,
  N_CMMain5F,
  N_Lib0, N_Lib1, N_Lib2, N_Gra2, N_Types, N_PMTMain5F;


//******************************************************* N_ShowPMTDiagram2 ***
// Create and show PMTDiagr2Form 700x536 (Aspect = 0.7661016949152542)
//
procedure N_ShowPMTDiagram2();
var
  i, RadInPix, YBegText, TextHeight, CurY, DeltaY: Integer;
  Origin: TPoint;
  CircleRect, DiagrRect: TRect;
  BVal, CVal, TVal, PenWidthInLLW: Double;
  FourRFramesStudy: Boolean;
  FileName, FileName2: String;
  Polyline: TN_IPArray;
  DIB: TN_DIBObj;
  NFont: TK_RArray;
  Diagr2Form: TN_PMTDiagr2Form;

  function CalcPoint( AIP1, AIP2: TPoint; APercents: Double ): TPoint; // local
  // Calculate Point between AIP1 (20%) and AIP2(100%)
  begin
    Origin.X := Round( AIP2.X + (AIP1.X - AIP2.X)*100.0/80.0 ); // 0% point
    Origin.Y := Round( AIP2.Y + (AIP1.Y - AIP2.Y)*100.0/80.0 );

    Result.X := Round( Origin.X + (AIP2.X - Origin.X)*APercents/100.0 );
    Result.Y := Round( Origin.Y + (AIP2.Y - Origin.Y)*APercents/100.0 );
  end; // function CalcPoint( AIP1, AIP2: TPoint; APercents: Double ): TPoint // local

begin
  Diagr2Form := TN_PMTDiagr2Form.Create( Application );
  Diagr2Form.BaseFormInit( nil, '', [fvfCenter] );

  FileName  := N_MemIniToString( 'PMTImages', 'PMT_Diagr', '' );
  FileName2 := K_ExpandFileName( FileName );
  N_Dump2Str( 'PMT DiagrFNames: "' + FileName + '", "' + FileName2 + '"' );

  DIB := TN_DIBObj.Create( FileName2 ); // Create DIBObj from Virtual file (2065x1582)
  FourRFramesStudy := N_CM_MainForm.CMMFActiveEdFrameSlideStudy.CMSStudyItemsCount = 4;

  with Diagr2Form.RFrame1 do
  begin
    YBegText := DIB.DIBSize.Y; // Diagramm bottom
    TextHeight := 400;
    OCanv.SetCurCRectSize( DIB.DIBSize.X, YBegText + TextHeight, pfDevice ); // Init MainBuf

    RFDstPRect := PaintBox.ClientRect; // where to show MainBuf
    RFSrcPRect := OCanv.CurCRect;      // what to show

    OCanv.SetPenAttribs( $FFFFFF, 0.1 ); // draw whitw background
    OCanv.SetBrushAttribs( $FFFFFF );
    OCanv.DrawPixFilledRect( OCanv.CurCRect );

    DiagrRect := DIB.DIBRect;
    OCanv.DrawPixDIB( DIB, DiagrRect, DIB.DIBRect );

    with N_PMTMain5Form do
    if FourRFramesStudy then
    begin
      BVal := PMTResDiagr_B2;
      CVal := PMTResDiagr_C2;
      TVal := PMTResDiagr_T2;
    end else // Two Frames Study
    begin
      BVal := PMTResDiagr_B;
      CVal := PMTResDiagr_C;
      TVal := PMTResDiagr_T;
    end;

//      BVal := 20; // for debug
//      CVal := 20;
//      TVal := 20;

    SetLength( Polyline, 4 );
    Origin := Point( 1029, 915 );

//                                     100%                 20%
    Polyline[0] := CalcPoint( Point( 1029,  759), Point( 1029,  319 ), BVal ); // B
    Polyline[1] := CalcPoint( Point( 1200, 1005), Point( 1655, 1222 ), CVal ); // C
    Polyline[2] := CalcPoint( Point(  859, 1005), Point(  403, 1222 ), TVal ); // T
    Polyline[3] := Polyline[0]; // B

    PenWidthInLLW := 14 / OCanv.CurLLWPixSize; // Convert 14 pix to LLW units
    OCanv.SetPenAttribs( $00FFFF, PenWidthInLLW ); // Yellow line
    OCanv.DrawPixPolyline ( Polyline, 4 );

    OCanv.SetPenAttribs( $CC0099, 0.1 ); // dark Magenta Circle
    OCanv.SetBrushAttribs( $CC0099 );
    RadInPix := 31; // Radius = 31 pixels

    for i := 0 to 3 do // along all three B,C,T points, draw dark Magenta Circle
    begin
      CircleRect.Left   := Polyline[i].X - RadInPix;
      CircleRect.Top    := Polyline[i].Y - RadInPix;
      CircleRect.Right  := Polyline[i].X + RadInPix;
      CircleRect.Bottom := Polyline[i].Y + RadInPix;
      OCanv.DrawPixEllipse( CircleRect );
    end; // for i := 0 to 3 do // along all three B,C,T points

    // Draw text strings below the diagram

    NFont := K_RCreateByTypeName( 'TN_NFont', 1 );
    with TN_PNFont(NFont.P())^ do
    begin
      NFLLWHeight := 44;
      NFFaceName := 'Courier New';
//      NFFaceName := 'Arial';
    end; // with TN_PNFont(NFont.P())^ do
    N_SetNFont( NFont, OCanv, 0 );
    OCanv.SetFontAttribs( $000000 );

    CurY := YBegText + 20;
    DeltaY := 43;
    OCanv.DrawPixString( Point(900,CurY), 'Заключение.' );
    CurY := CurY + 70;

    OCanv.DrawPixString( Point(5, CurY), '* Отклонение показателей эстетики лица ' +
                   'от нормы в  вертикальном  направлении' );
    CurY := CurY + DeltaY;
    OCanv.DrawPixString( Point(60, CurY), Format( 'составляет - %2.1f%%', [BVal] ) );
    CurY := CurY + DeltaY + 17;

    OCanv.DrawPixString( Point(5, CurY), '* Отклонение показателей эстетики лица ' +
                   'от нормы в  сагиттальном  направлении' );
    CurY := CurY + DeltaY;
    OCanv.DrawPixString( Point(60, CurY), Format( 'составляет - %2.1f%%', [CVal] ) );
    CurY := CurY + DeltaY + 17;

    OCanv.DrawPixString( Point(5, CurY), '* Отклонение показателей эстетики лица ' +
                   'от нормы в трансверсальном направлении' );
    CurY := CurY + DeltaY;
    OCanv.DrawPixString( Point(60, CurY), Format( 'составляет - %2.1f%%', [TVal] ) );

    NFont.Free;
    SkipOnPaint := False;
    Diagr2Form.Show;

    //***** Create png image file with resulting diagram
    FileName := N_PMTMain5Form.PMTCalcFName();
    DIB.CreateSelfOCanv();
    DIB.Free;
    DIB :=TN_DIBObj.Create( OCanv.CCRSize.X, OCanv.CCRSize.Y, pf24bit );
    N_StretchRect( DIB.DIBOCanv.HMDC, DIB.DIBRect, OCanv.HMDC, RFSrcPRect );
    N_i := N_SaveDIBToFileByImLib( DIB, FileName + '.png' );
    DIB.Free;

  end; // with Result.RFrame1 do

end; // procedure N_ShowPMTDiagram2();

end.
