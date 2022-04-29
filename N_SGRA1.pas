unit N_SGRA1;
// Internal SPL Graphic functions

interface
uses K_Script1;

{
//****************** Global procedures **********************

procedure N_ExprDrawRect         ( GlobCont: TK_CSPLCont );
procedure N_ExprDrawRoundRect    ( GlobCont: TK_CSPLCont );
procedure N_ExprSetFont          ( GlobCont: TK_CSPLCont );
procedure N_ExprDrawString       ( GlobCont: TK_CSPLCont );
procedure N_ExprDrawEllipse      ( GlobCont: TK_CSPLCont );
procedure N_ExprDrawstraightArrow ( GlobCont: TK_CSPLCont );
procedure N_ExprDrawPolyline     ( GlobCont: TK_CSPLCont );
procedure N_ExprDrawDashLine     ( GlobCont: TK_CSPLCont );
procedure N_ExprDrawPolygon      ( GlobCont: TK_CSPLCont );
procedure N_ExprDrawRaster       ( GlobCont: TK_CSPLCont );
procedure N_ExprSetRBuf          ( GlobCont: TK_CSPLCont );
}

implementation
uses Windows, Classes, Graphics,
     N_Types, N_Lib1, N_Gra0, N_Gra1, N_Rast1Fr, N_RVCTF;
{
//********************************************** N_ExprDrawRect ***
// procedure DrawRect( Rect:DblRect;
//                     BrushColor:Color=$FFFFFF; PenWidth:Float=3;
//                     PenColor:Color=$000000 );
//
procedure N_ExprDrawRect( GlobCont: TK_CSPLCont );
type  Params = packed record
  RectCoords:  TDRect;
  DType1 : TK_ExprExtType;
  FillColor:   integer;
  DType2 : TK_ExprExtType;
  BorderWidth: float;
  DType3 : TK_ExprExtType;
  BorderColor: integer;
  DType4 : TK_ExprExtType;
end;
var
  PP : ^Params;
//  SavedNWP: boolean;
begin
  PP := GlobCont.GetPointerToExprStackRecord( SizeOf(Params) );
  N_p := PP;

  with GlobCont.OCanvas, PP^ do
  begin
//    SavedNWP := NativeWidePen; // now RoundRect can de drawn only in
//    NativeWidePen := True;     //       NativeWidePen mode
    SetBrushAttribs( FillColor );
    SetPenAttribs( BorderColor, BorderWidth );
    DrawUserRect( FRect(RectCoords) );
//    NativeWidePen := SavedNWP; // restore
  end;

end; //*** end of  procedure N_ExprDrawRect

//********************************************** N_ExprDrawRoundRect ***
// procedure DrawRoundRect( Rect:DblRect=;
//                       BrushColor:Color=$FFFFFF; PenWidth:Float=3;
//                       PenColor:Color=$000000;  Round:FloatPoint="0 0" );
//
procedure N_ExprDrawRoundRect( GlobCont: TK_CSPLCont );
type  Params = packed record
  RectCoords:  TDRect;
  DType1 : TK_ExprExtType;
  FillColor:   integer;
  DType2 : TK_ExprExtType;
  BorderWidth: float;
  DType3 : TK_ExprExtType;
  BorderColor: integer;
  DType4 : TK_ExprExtType;
  RoundSizeXY: TFPoint;
  DType5 : TK_ExprExtType;
end;
var
  PP: ^Params;
//  SavedNWP: boolean;
begin
  PP := GlobCont.GetPointerToExprStackRecord( SizeOf(Params) );

  with GlobCont.OCanvas, PP^ do
  begin
//    SavedNWP := NativeWidePen; // now RoundRect can de drawn only in
//    NativeWidePen := True;     //       NativeWidePen mode
    SetBrushAttribs( FillColor );
    SetPenAttribs( BorderColor, BorderWidth );
    if (RoundSizeXY.X = 0) and (RoundSizeXY.Y = 0) then
      DrawUserRect( FRect(RectCoords) )
    else
      DrawUserRoundRect( FRect(RectCoords), RoundSizeXY );
//    NativeWidePen := SavedNWP; // restore
  end;

end; //*** procedure N_ExprDrawRoundRect

//************************************** N_ExprSetFont ***
// procedure SetFont( FontName:String='-1';
//                    FontSize:float=-1;
//                    FontStyle:Hex=0 );
//
procedure N_ExprSetFont( GlobCont: TK_CSPLCont );
type  Params = packed record
  FontName: string;
  DType1 : TK_ExprExtType;
  FontSize: float;
  DType2 : TK_ExprExtType;
  FontStyle: integer;
  DType3 : TK_ExprExtType;
end;
var
  PP: ^Params;
begin
  PP := GlobCont.GetPointerToExprStackRecord( SizeOf(Params) );
  with GlobCont.OCanvas, PP^ do
  begin
//!!    SetFontAttribs( FontName, FontSize, FontStyle, $000000 );
    K_FreeTypedData( FontName, Ord(nptString) );
  end;
end; //*** end of procedure N_ExprSetFont

//************************************** N_ExprDrawString ***
// procedure DrawString( BPCoords:DblPoint;
//                       BPType:Hex=0;        BPOfs:FloatPoint = "0 0";
//                       TextColor:Color=$0;  AString:String );
//
procedure N_ExprDrawString( GlobCont: TK_CSPLCont );
type  Params = packed record
  PBPCoords: TDPoint;
  DType1 : TK_ExprExtType;
  BPType : integer;
  DType2 : TK_ExprExtType;
  BPOfs  : TFPoint;
  DType3 : TK_ExprExtType;
  StringColor: integer;
  DType4 : TK_ExprExtType;
  BackColor: integer;
  DType5 : TK_ExprExtType;
  DrawStr: string;
  DType6 : TK_ExprExtType;
end;
var
  PP: ^Params;
begin
  PP := GlobCont.GetPointerToExprStackRecord( SizeOf(Params) );
  with GlobCont.OCanvas, PP^ do
  begin
//!!    SetFontAttribs( N_CurFontName, N_CurLLWSize, N_CurFontStyle,
//                                                 StringColor, BackColor );
    DrawUserString( PBPCoords, BPOfs, N_ZFPoint, DrawStr );
    K_FreeTypedData( DrawStr, Ord(nptString) );
  end;
end; //*** end of procedure N_ExprDrawString

//************************************** N_ExprDrawEllipse ***
// function DrawEllipse( Rect:^DblRect;
//                       BrushColor:Color=$FFFFFF; PenWidth:Float=3;
//                       PenColor:Color=$000000 );
//
procedure N_ExprDrawEllipse( GlobCont: TK_CSPLCont );
type  Params = packed record
  PRect:        TDRect;
  DType1 : TK_ExprExtType;
  FillColor:   integer;
  DType2 : TK_ExprExtType;
  BorderWidth: float;
  DType3 : TK_ExprExtType;
  BorderColor: integer;
  DType4 : TK_ExprExtType;
end;
var
  PP : ^Params;
begin
  PP := GlobCont.GetPointerToExprStackRecord( SizeOf(Params) );
  with GlobCont.OCanvas do
  begin
    SetPenAttribs( PP.BorderColor, PP.BorderWidth );
    SetBrushAttribs( PP.FillColor );
    DrawUserRectEllipse( FRect(PP.PRect) );
  end;
end; //*** end of procedure N_ExprDrawEllipse

//************************************** N_ExprDrawstraightArrow ***
// function DrawstraightArrow( PP1:^DblPoint="0 0";
//                            PP2:^DblPoint="0 0";
//                            L1:float=10; L2:float=15;
//                            W1:float=5;  W2:float=11;
//                            BrushColor:Color=$00BBFF );
//
procedure N_ExprDrawstraightArrow( GlobCont: TK_CSPLCont );
type  Params = packed record
  PP1: TDPoint;
  DType1 : TK_ExprExtType;
  PP2: TDPoint;
  DType2 : TK_ExprExtType;
  L1: float;
  DType3 : TK_ExprExtType;
  L2: float;
  DType4 : TK_ExprExtType;
  W1: float;
  DType5 : TK_ExprExtType;
  W2: float;
  DType6 : TK_ExprExtType;
  Color: integer;
  DType7 : TK_ExprExtType;
end;
var
  PP: ^Params;
begin
  PP := GlobCont.GetPointerToExprStackRecord( SizeOf(Params) );
  with GlobCont.OCanvas do
  begin
    SetPenAttribs( PP.Color, 1 );
    SetBrushAttribs( PP.Color );
    DrawUserStraightArrow( PP.PP1, PP.PP2, 0, PP.L1, PP.L2, PP.W1, PP.W2 );
  end;
end; //*** end of procedure N_ExprDrawstraightArrow

//************************************** N_ExprDrawPolyline ***
// function DrawPolyline( Coords:ArrayOf DblPoint;
//                        PenWidth:float; PenColor:Color=$00BBFF );
//
procedure N_ExprDrawPolyline( GlobCont: TK_CSPLCont );
type  Params = packed record
  PCoords: TK_RArray;
  DType1 : TK_ExprExtType;
  PenWidth: float;
  DType2 : TK_ExprExtType;
  PenColor: integer;
  DType3 : TK_ExprExtType;
end;
var
  PP: ^Params;
  NumElements: integer;
  WCoords : TN_DPArray;
begin
  PP := GlobCont.GetPointerToExprStackRecord( SizeOf(Params) );
  with GlobCont.OCanvas do
  begin
    SetPenAttribs( PP.PenColor, PP.PenWidth );

    NumElements := PP.PCoords.ALength;
    SetLength( WCoords, NumElements );
    move( PP.PCoords.P^, WCoords[0],
                                NumElements*Sizeof(TDPoint) );
    DrawUserPolyline1( WCoords );
  end;
end; //*** end of procedure N_ExprDrawPolyline

//************************************** N_ExprDrawDashLine ***
// function DrawPolyline( Coords:ArrayOf DblPoint;
//                        PenWidth:float; PenColor:Color=$00BBFF );
//
procedure N_ExprDrawDashLine( GlobCont: TK_CSPLCont );
type  Params = packed record
  PCoords: TK_RArray;
  DType1 : TK_ExprExtType;
  DashAttribs: TK_RArray;
  DType2 : TK_ExprExtType;
  LoopInd: integer;
  DType3 : TK_ExprExtType;
end;
var
  PP: ^Params;
  WCoords : TN_DPArray;
  NumElements: integer;
  TempDashAttribs: TN_DashAttribs;
begin
  PP := GlobCont.GetPointerToExprStackRecord( SizeOf(Params) );
  with GlobCont.OCanvas, PP^ do
  begin

    NumElements := DashAttribs.ALength;
    SetLength( TempDashAttribs, NumElements );
    move( DashAttribs.P^, TempDashAttribs[0],
                                NumElements*Sizeof(TempDashAttribs[0]) );

    NumElements := PCoords.ALength;
    SetLength( WCoords, NumElements );
    move( PCoords.P^, WCoords[0],
                                NumElements*Sizeof(TDPoint) );
    DrawDashedPolyline ( WCoords, TempDashAttribs, LoopInd );
  end;
end; //*** end of procedure N_ExprDrawDashLine

//************************************** N_ExprDrawPolygon ***
// function DrawPolygone( Coords:ArrayOf DblPoint;
//                        BrushColor:Color = $00BBFF;
//                        PenWidth:float; PenColor:Color=$00BBFF );
//
procedure N_ExprDrawPolygon( GlobCont: TK_CSPLCont );
type  Params = packed record
  PCoords: TK_RArray;
  DType1 : TK_ExprExtType;
  BrushColor: Integer;
  DType2 : TK_ExprExtType;
  PenWidth: float;
  DType3 : TK_ExprExtType;
  PenColor: integer;
  DType4 : TK_ExprExtType;
end;
var
  PP: ^Params;
  WCoords : TN_DPArray;
  NumElements: integer;
begin
  PP := GlobCont.GetPointerToExprStackRecord( SizeOf(Params) );
  with GlobCont.OCanvas, PP^ do
  begin

    NumElements := PP.PCoords.ALength;
    SetLength( WCoords, NumElements );
    move( PCoords.P^, WCoords[0],
                                NumElements*Sizeof(TDPoint) );

    DrawUserColorRing( WCoords, N_NotAFRect,
             N_CalcRingDirection ( WCoords ), BrushColor,
                                                  PenColor, PenWidth );
  end;
end; //*** end of procedure N_ExprDrawPolygon

//************************************** N_ExprDrawRaster ***
// procedure DrawRaster( Name: String; BPUser: DblPoint="0 0";
//                       BPOfs: FloatPoint="0 0";  SizeXY: FloatPoint="0 0";
//                       SrcRect: IntRect;         TranspColor: Color );
//
procedure N_ExprDrawRaster( GlobCont: TK_CSPLCont );
type  Params = packed record
  Name: string;
  DType1: TK_ExprExtType;
  BPUser     : TDPoint;
  DType2: TK_ExprExtType;
  BPOfs      : TFPoint;
  DType3: TK_ExprExtType;
  SizeXY     : TFPoint;
  DType4: TK_ExprExtType;
  SrcRect    : TRect;
  DType5: TK_ExprExtType;
  TranspColor: integer;
  DType6: TK_ExprExtType;
  end;
var
  PP:    ^Params;
  BitMap: TBitmap;
begin
  PP := GlobCont.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
  begin
    BitMap := TBitmap.Create;
    BitMap.LoadFromFile( Name );
    if TranspColor <> N_EmptyColor then
      with BitMap do
      begin
        Transparent := True;
        TransparentColor := TranspColor;
      end;
    GlobCont.OCanvas.DrawUserBMP( BitMap, BPUser, BPOfs, SizeXY, SrcRect );
    BitMap.Free;
    K_FreeTypedData( Name, Ord(nptString) );
  end;
end; //*** end of procedure N_ExprDrawRaster

//************************************** N_ExprSetRBuf ***
// procedure SetRBuf( FrameRect: IntRect;   RBufSize: IntPoint;
//                    UserCoords: DblRect;  ResizeFlags: Int );
//
// if DrawCont = nil in Global Context (was not created yet),
//       3Form with FRname and RBuf were created
//
// FrameRect.Left, Top = -1 means current X,Y position
// FrameRect.Right, Bottom = -1 means current X,Y size
// FrameRect.Right, Bottom = -2 means RBuf X,Y size
// RBufSize.X,Y = -1 means current X,Y size
// RBufSize.X,Y = -2 means current Frame X,Y size
// UserCoords.Left = UserCoords.Right means same User coords
// ResizeFlags = -1 means current Frame Resize Flags
//
procedure N_ExprSetRBuf( GlobCont: TK_CSPLCont );
begin

type  Params = packed record
  FrameRect: TRect;
  DType1 : TK_ExprExtType;
  RBufSize: TPoint;
  DType2 : TK_ExprExtType;
  UserCoords: TDRect;
  DType3 : TK_ExprExtType;
  AResizeFlags: integer;
  DType4 : TK_ExprExtType;
  end;
var
  NeededWidth, NeededHeight: integer;
  PP : ^Params;
  RBuf: TN_RBuf;
begin
  PP := GlobCont.GetPointerToExprStackRecord( SizeOf(Params) );
  with PP^ do
  begin
    Assert( GlobCont.Rbuf <> nil, 'No RBuf' );
    RBuf := TN_RBuf(GlobCont.RBuf);

    with TN_Rast1Frame(RBuf.ParentFrame) do
    begin
      if (RBufSize.X <> -1) or //************************** change RBuf Size
         (RBufSize.Y <> -1) then
      begin
        NeededWidth  := GlobCont.OCanvas.CWidth;
        NeededHeight := GlobCont.OCanvas.CHeight;

        if RBufSize.X <> -1 then NeededWidth := RBufSize.X;
        if RBufSize.Y <> -1 then NeededHeight := RBufSize.Y;

        RBuf.SelfMaxPRect := Rect( 0, 0, NeededWidth-1, NeededHeight-1 );
      end; // if (RBufSize.X <> -1) or    // change RBuf Size


      if FrameRect.Left <> -1 then K_GetOwnerForm( Owner ).Left := FrameRect.Left;
      if FrameRect.Top  <> -1 then K_GetOwnerForm( Owner ).Top  := FrameRect.Top;

      if (FrameRect.Right <> -1) or //******************** change Frame Size
         (FrameRect.Bottom <> -1) then
      begin
        if (FrameRect.Right  = -2) then
          NeededWidth := GlobCont.OCanvas.CWidth
        else if (FrameRect.Right  = -1) then
          NeededWidth := PaintBox.Width
        else
        begin
          if FrameRect.Left = -1 then
            NeededWidth := FrameRect.Right
          else
            NeededWidth := FrameRect.Right - FrameRect.Left + 1;
        end;

        if (FrameRect.Bottom  = -2) then
          NeededHeight := GlobCont.OCanvas.CHeight
        else if (FrameRect.Bottom  = -1) then
          NeededHeight := PaintBox.Height
        else
        begin
          if FrameRect.Top = -1 then
            NeededHeight := FrameRect.Bottom
          else
            NeededHeight := FrameRect.Bottom - FrameRect.Top + 1;
        end;

        RBufIsNotReady := True;
        ResizeSelf( NeededWidth, NeededHeight );
        RBufIsNotReady := False;
      end; // if (FrameRect.Right <> -1) or    // change Frame Size

      RecalcPRects();

      if (UserCoords.Left  = 0) and  //****************** change User Coords
         (UserCoords.Right = 0 ) then
      begin
        if UserCoords.Bottom = 1 then RBuf.SetUserCoordsSameToPixel();
      end else
      begin
        RBuf.RecalcAffCoefs( $32, aamNoChange, FRect(UserCoords), RBuf.SelfMaxPRect );
        RBuf.FullURect := FRect(UserCoords);
      end;

      if AResizeFlags <> -1 then
        ResizeFlags := AResizeFlags;
    end; // with TN_Rast1Frame(RBuf.ParentFrame) do
  end; // with PP^ do
end; //*** end of procedure N_ExprSetRBuf

Initialization
//**************** My indexes are 100 - 149  **************************

//*** 100 - 109 - reserved by my
  K_ExprNFuncNames[110] := 'DrawRect';
  K_ExprNFuncRefs [110] := N_ExprDrawRect;

  K_ExprNFuncNames[111] := 'DrawRoundRect';
  K_ExprNFuncRefs [111] := N_ExprDrawRoundRect;

  K_ExprNFuncNames[112] := 'SetFont';
  K_ExprNFuncRefs [112] := N_ExprSetFont;

  K_ExprNFuncNames[113] := 'DrawString';
  K_ExprNFuncRefs [113] := N_ExprDrawString;

  K_ExprNFuncNames[114] := 'DrawEllipse';
  K_ExprNFuncRefs [114] := N_ExprDrawEllipse;

  K_ExprNFuncNames[115] := 'DrawstraightArrow';
  K_ExprNFuncRefs [115] := N_ExprDrawstraightArrow;

  K_ExprNFuncNames[116] := 'DrawPolyline';
  K_ExprNFuncRefs [116] := N_ExprDrawPolyline;

  K_ExprNFuncNames[117] := 'DrawDashLine';
  K_ExprNFuncRefs [117] := N_ExprDrawDashLine;

  K_ExprNFuncNames[118] := 'DrawPolygon';
  K_ExprNFuncRefs [118] := N_ExprDrawPolygon;

  K_ExprNFuncNames[119] := 'DrawRaster';
  K_ExprNFuncRefs [119] := N_ExprDrawRaster;

  K_ExprNFuncNames[120] := 'SetRbuf';
  K_ExprNFuncRefs [120] := N_ExprSetRbuf;
}

end.


