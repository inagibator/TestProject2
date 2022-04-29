unit N_SGComp;
// classes and procedures for searching in components

// TN_SGComp = class( TN_SGBase ) //***** Search Group for Components

interface
uses Windows, Classes, Types, 
  K_UDT1, K_Script1,
  N_Types, N_Gra0, N_Gra1, N_Rast1Fr, N_CompBase;

type TN_SRType = ( srtNone, srtPoint, srtLine, srtContour, srtBorder, srtPixRect,
                   srtPolyline, srtArc, srtParaBox, srtPanel, srtDIBRect );

type TN_SearchComp = record //
  SFlags: integer;      // Search Flags
  SComp: TN_UDCompVis;  // Search Component
  SCReadOnly: boolean;  // True if Component should not be changed
  SCUserTag : Integer;  // User defined Info
end; // type TN_SearchComp = record
type TN_SearchComps = array of TN_SearchComp;

type TN_SearchResult = record //
  SRCompInd: integer; // Search Result Component
  SRType: TN_SRType;
  ObjPtr:  Pointer;   // Ptr to current CObj
  ItemInd: integer;
  PartInd: integer;
  VertInd: integer;
  SegmInd: integer;
  case TN_SRType of
  srtPoint:  ( a2: integer );
  srtLine:   ( PrevSegmInd: integer );
end; // type TN_SearchResult = record
type TN_SearchResults = array of TN_SearchResult;

type TN_SGComp = class( TN_SGBase ) //***** Search Group for Components
    public
  SComps: TN_SearchComps;  // Search Components
  SGFlags: integer;        // SearchGroup Flags:
    // bit0($01) = 1 - do not stop on fist founded comp, collect array of OneSR
    // bit1($02) = 1 - search in UDPolyline and UDArc even if cursor is out of component
    // bit2($04) = 1 - redraw RFA actions without using seach components context (see TN_Rast1Frame.RedrawAllSGroupsActions)
  CurSCompInd: integer;    // Current Component Index
  CurSComp: TN_UDCompVis;  // Current Component (= SComps[CurSCompInd].SComp)
  CurSFlags: integer;      // Search Flags (= SComps[CurSCompInd].SFlags),
                           // implemented in TN_SGComp and in TN_SGMLayers classes:
    // for searching Points:
    //    bit0($01) =1 - check BasePoint
    //    bit1($02) =1 - check sign (Label) PixRect (created while Drawing)
    //    bit2($04) =1 - check circle around BasePoint (=0 - check Rect), used only if bit0=1
    //
    // for searching Lines:
    //    bits(0,1)($03):
    //              =0 check any, SegmInd and VertInd are not needed on output
    //              =1 check only Line Segments
    //              =2 check only Line Vertexes
    //              =3 check and return both SegmInd and VertInd
    //    bit2($04) =0 - check if CursorURect is only over the Line
    //              =1 - check if CursorUPoint is over the Line or inside closed Line
    //
    // for searching Contours - not used
    //
    // for searching Panels:
    //    bits(0,1)($03):
    //              =0 check Panel Rectangle inner space
    //              =1 check only Panel Rectangle Borders
    //
    // for searching Arcs:
    //    bits(0,1)($03):
    //              =0 check Arc inner space
    //              =1 check only Arc Border
    //

  OneSR:  TN_SearchResult;   // One Search Result
  PrevSR: TN_SearchResults;  // Previous Search Results
  NPrevSR: integer;          // Number of elements in PrevSR
  CurSR:  TN_SearchResults;  // Current Search Results
  NCurSR: integer;           // Number of elements in CurSR
  ResultInd: integer;        // index of needed search result in multiselect case
                             // (it will be placed in OneSR)
  RealNCurSR: integer;       // Real Number of elements in CurSR
                             // (NCurSR may be set to 1 if ResultInd >= 0)

  PixSearchSize:  integer;   // Pixel Search Size (Sixe of Rect or Circle around Cursor)
  UserSearchSize:   float;   // User  Search Size (Sixe of Rect or Circle around Cursor)
  CursorPRect:      TRect;   // Cursor Pixel Rect (Rect with CursorPPoint center)
  CursorUPoint:   TDPoint;   // Cursor User Point (for Current Component)
  CursorURect:     TFRect;   // Cursor User Rect (for Current Component)
  RedrawLLWPixSize: float;   // LLWPixSize used in RFrame.RedrawAllSGroupsActions
  SavedStrings: TStringList; // Strings, saved by pressing 'C' in TN_RFAShowCObjInfo.Execute()

  constructor Create         ( ARFrame: TN_Rast1Frame );
  destructor  Destroy        (); override;
  function  SearchInAllComps (): boolean; override;
  function  SearchInCurComp  (): boolean; virtual;
  procedure AddOneSR         ();
end; // type TN_SGComp = class( TN_SGBase )

type TN_RubberRectRFA = class( TN_RFrameAction ) // Rubber Rect RFrame Action
    RRFlags: integer;   // "Cursor position relative to Rect" Flags (see N_CursorNearRect)
    RRSavedCC: TPoint;  // Saved Cursor CCBuf coords at MouseDown
    RRSavedRect: TRect; // Saved RubberRect Pixel coords at MouseDown

    RRCurUserRect: TFRect;  // Current RubberRect User Coords
    RRCurPixRect:  TRect;   // Current RubberRect Pixel Coords
    RRIsResizeble: boolean; // RubberRect can be resized (otherwise only shifted)

    RRMinPixSize: TPoint; // Minimal Pixel Size of Rubber Rect

    RRSkipSelfDraw: boolean; // Skip Self Rubber Rectangle Dashed Drawing

    RRConP2UComp:  TN_UDCompVis;

    RROnEventProcObj:  TN_OneObjProcObj; // OnEvent external handler
    RROnChangeProcObj: TN_OneObjProcObj; // OnRubberRectChange external handler
    RROnOKProcObj:     TN_OneObjProcObj; // OnOK(Enter of DblClick inside) external handler
    RROnCancelProcObj: TN_OneObjProcObj; // OnCancel(Escape of Click outside) external handler
    RROnRedrawProcObj: TN_OneObjProcObj; // OnOnRedraw external handler
    RROnMouseMoveRedrawProcObj : procedure () of object;

  procedure SetActParams (); override;
  procedure Execute      (); override;
  procedure RedrawAction (); override;
  procedure MouseMoveRedraw ();
end; // type TN_RubberRectRFA = class( TN_RFrameAction )

type TN_RubberSegmRFAState = ( rsrfaBeforeP1, rsrfaDrawSegm,
                               rsrfaFinished, rsrfaCanceled );
// rsrfaBeforeP1 - before Point1 was choosen
// rsrfaDrawSegm - Point1 is OK, Point2 - not, Draw Segm from P1 to cursor
// rsrfaFinished - both Point1 and Point2 are OK
// rsrfaCanceled - Action was Canceled by pressing Escape

type TN_RubberSegmRFA = class( TN_RFrameAction ) // Rubber Segment RFrame Action
    RSUPoint1: TDPoint; // User coords of Point 1
    RSUPoint2: TDPoint; // User coords of Point 2
    RSState: TN_RubberSegmRFAState; // Action State, See comments after Type

    RSOnMouseMoveProcObj: TN_OneObjProcObj; // OnMouseMove external handler
    RSOnMouseDownProcObj: TN_OneObjProcObj; // OnMouseDown external handler
    RSOnRedrawProcObj:    TN_OneObjProcObj; // OnOnRedraw external handler

  procedure SetActParams (); override;
  procedure Execute      (); override;
  procedure RedrawAction (); override;
end; // type TN_RubberSegmRFA = class( TN_RFrameAction )

type TN_EditCompsRFA = class( TN_RFrameAction ) // Move or Resize Components by Cursor
      //***** These fields should be set before using Self.Execute method
  ECNumComps:    integer;  // Number of Components to Edit ( ECComps, ECBaseRects size)
  ECComps:  TN_UDCVArray;  // Array of Visual Components to Edit
  ECCurRects: TN_IRArray;  // Current Components IntPixRects
  ECParent: TN_UDCompVis;  // Parent componet for all ECComps (for Deleting Comp)
  ECNewPixRect:    TRect;  // New (Changed) Component OuterPixRect
  ECOnlyShift:   boolean;  // Only Shift Coords (move component preserving size)

  ECOnDblClickProcObj:     TN_OneObjProcObj; // On Double Click external handler
  ECOnRightClickProcObj:   TN_OneObjProcObj; // On Right Click external handler
  ECOnCoordsChangeProcObj: TN_OneObjProcObj; // On Coords Change external handler

  ECBase: TPoint;          // saved Cursor CCBuf coords at MouseDown
  ECBaseRects: TN_IRArray; // saved all Rects coords at MouseDown
  ECRectInd: integer;      // Rect Ind near to Cursor at MouseDown
  ECPosFlags: integer;     // Cursor position (relative to Rects) Flags at MouseDown
  ECSavedLFPRect:  TRect;  // Saved RFrame.RFLogFramePRect (used in ECSetCompPixRects)
  ECSavedSrcPRect: TRect;  // Saved RFrame.RFSrcPRect (used in ECSetCompPixRects)

  procedure SetActParams      (); override;
  procedure Execute           (); override;
  procedure ECSetCompPixRects ();
  procedure ECSetCompBPCLRCU  ( AEditCompsRFA: TObject );
  procedure ECSetCompBPShift  ( AEditCompsRFA: TObject );
end; // type TN_EditCompsRFA = class( TN_RFrameAction )



implementation
uses SysUtils, Controls, Forms,
  N_InfoF, N_Lib0, N_Lib1, N_Gra2, N_AlignF, N_NVTreeFr, N_CompCL,
  N_Comp1, N_Comp2;

//********** TN_SGComp class methods  **************

//******************************************************** TN_SGComp.Create ***
//
constructor TN_SGComp.Create( ARFrame: TN_Rast1Frame );
begin
  Inherited;
  PixSearchSize := 9;
  SetLength( CurSR, 1 );
  ResultInd := -1; // highlight all search results
  RedrawLLWPixSize := 1;
  SavedStrings := TStringList.Create;
end; // end_of constructor TN_SGComp.Create

//******************************************************* TN_SGComp.Destroy ***
//
destructor TN_SGComp.Destroy();
begin
  SavedStrings.Free;
  inherited;
end; // end_of destructor TN_SGComp.Destroy

//********************************************** TN_SGComp.SearchInAllComps ***
// Search in All Components from SComps array
//
function TN_SGComp.SearchInAllComps(): boolean;
var
  i, CurPixSearchSize: integer;
  CurRes: boolean;
  VisRect: Trect;
begin
//  Result := False;

  //***** copy CurSR array to PrevSR, clear CurSR and OneSR
  if Length(PrevSR) < Length(CurSR) then SetLength( PrevSR, Length(CurSR) );
  move( CurSR[0], PrevSR[0], NCurSR*Sizeof(CurSR[0]) );
  NPrevSR := NCurSR;
  NCurSR := 0;
  FillChar( OneSR, Sizeof(OneSR), 0 ); // empty OneSR (OneSR.SRType = srtNone)

  //***** set Search Point and Search Rect in OCanv Pixel Coords
  CursorPPoint := RFrame.CCBuf; // current Cursor Pos in OCanv pixels
//  N_IAdd( Format( 'CursorPPoint x,y=(%d, %d)', [CursorPPoint.X,CursorPPoint.Y] ));

  for i := High(SComps) downto 0 do
  begin
    CurSCompInd := i;
    CurSComp := SComps[i].SComp;
    if CurSComp = nil then Continue;
    N_s := CurSComp.ObjName;

//    if 0 <> N_PointInRect( CursorPPoint, CurSComp.CompIntPixRect ) then
    if 0 <> N_PointInRect( CursorPPoint, CurSComp.CompOuterPixRect ) then
    begin
      //***** Here: CursorPPoint is stricly outside of component

      if ((SGFlags and $02) = 0) or
         not ((CurSComp is TN_UDPolyline) or
              (CurSComp is TN_UDArc)      or
              (CurSComp is TN_UDPanel)) then
        Continue; // skip searching inside component
    end;

    //***** Here: Cursor is inside CurSComp

    // set Search Point in Component User Coords
    CursorUPoint := N_AffConvI2DPoint( CursorPPoint, CurSComp.CompP2U );

    // set Search Rect in Pixel and Component User Coords
    if PixSearchSize = 0 then // Searh Size is given in User units
      CurPixSearchSize := Round(UserSearchSize * CurSComp.CompU2P.CX)
    else
      CurPixSearchSize := PixSearchSize;

    CursorPRect  := N_RectMake( CursorPPoint,
                    Point(CurPixSearchSize, CurPixSearchSize), N_05DPoint );

    CursorURect  := N_AffConvI2FRect2( CursorPRect, CurSComp.CompP2U );

    // set OCanv coefs for correct drawing in CurSComp coords
    RFrame.OCanv.P2U := CurSComp.CompP2U;
    RFrame.OCanv.U2P := CurSComp.CompU2P;
    VisRect := CurSComp.CompIntPixRect;
    N_IRectAnd( VisRect, RFrame.OCanv.CurCRect );
    RFrame.OCanv.SetUClipRect( VisRect );

    CurSFlags := SComps[i].SFlags;
    CurRes := SearchInCurComp(); // search for Objects in current Component

    if CurRes and ((SGFlags and $01) = 0) then // Stop after first found obj
      Break;

  end; // for i := High(SComps) downto 0 do

  if NCurSR <= 1 then ResultInd := -1; // set initial value
  RealNCurSR := NCurSR; // used in

  if (ResultInd >= 0) and (ResultInd < NCurSR) then // set OneSR by ResultInd
  begin
    OneSR := CurSR[ResultInd];
    NCurSR := 1;
  end;

  if NPrevSR <> NCurSR then
    Result := True
  else
    Result := not CompareMem( @PrevSR[0], @CurSR[0], Sizeof(CurSR[0])*NCurSR );

  SRChanged := Result;
end; // function TN_SGComp.SearchInAllComps

//*********************************************** TN_SGComp.SearchInCurComp ***
// Search Inside Current Component CurSComp
// Return True and set OneSR if near line in UDPolyline or UDArc components
// or inside UDParaBox component
//
function TN_SGComp.SearchInCurComp(): boolean;
var
  DD : Double;
  AA1, BB1 : Double;
  XB1, YA1 : Double;
  AA, BB : Double;
  XB, YA : Double;
  RR : Integer;

  procedure CheckEllipse;
  begin
    DD := PixSearchSize / 2;
    if (CurSFlags and 1) = 0 then DD := 0;
    with CurSComp.CompIntPixRect, CursorPPoint do
    begin
      BB := ( Abs(Bottom  - Top) + 1 ) / 2  + DD;
      XB := (X - (Right + Left) / 2);
      XB1 := XB;
      XB := XB * BB;
      AA := ( Abs(Right - Left) + 1 ) / 2 + DD;
      YA := (Y - (Bottom + Top) / 2);
      YA1 := YA;
      YA := YA * AA;
      Result := ((XB*XB + YA*YA) <= AA * AA * BB * BB);
      if (DD <> 0) and (BB > PixSearchSize ) and (AA > PixSearchSize ) then
      begin
      // Search near Ellipse border
        AA1 := AA - PixSearchSize;
        YA1 := YA1 * AA1;
        BB1 := BB - PixSearchSize;
        XB1 := XB1 * BB1;
        Result := Result and ((XB1*XB1 + YA1*YA1) >= AA1 * AA1 * BB1 * BB1);
      end;
    end;
  end;

  procedure CheckInPixRect;
  begin
    RR := N_IPointNearIRect( CursorPPoint, CurSComp.CompIntPixRect,
                             Round(PixSearchSize / 2) );

    if (CurSFlags and 1) = 0 then
      Result := (RR and $F0) < $20
    else
      Result := (RR and $F) <> 0;
  end;

begin
//  N_IAdd( CurSComp.ObjName ); // debug
//  N_IAdd( 'User x,y = ' + Format( '%.3f %.3f', [CursorUPoint.X, CursorUPoint.Y]) );

  Result := False;

  if CurSComp is TN_UDPolyline then // Polyline Component
  with TN_UDPolyline(CurSComp) do
  begin
    Result := N_RectOverLine( UDPBufPixCoords, 0, Length(UDPBufPixCoords),
           FRect(CursorPRect), CurSFlags and $3, OneSR.SegmInd, OneSR.VertInd );
    if Result then OneSR.SRType := srtPolyline;
  end else if CurSComp is TN_UDArc then // Arc Component
  begin
    // Implemented only for Ellipse!!!
    CheckEllipse();
{
    DD := PixSearchSize / 2;
    if (CurSFlags and 1) = 0 then DD := 0;
    with CurSComp.CompIntPixRect, CursorPPoint do
    begin
      BB := ( Abs(Bottom  - Top) + 1 ) / 2  + DD;
      XB := (X - (Right + Left) / 2);
      XB1 := XB;
      XB := XB * BB;
      AA := ( Abs(Right - Left) + 1 ) / 2 + DD;
      YA := (Y - (Bottom + Top) / 2);
      YA1 := YA;
      YA := YA * AA;
      Result := ((XB*XB + YA*YA) <= AA * AA * BB * BB);
      if (DD <> 0) and (BB > PixSearchSize ) and (AA > PixSearchSize ) then
      begin
      // Search near Ellipse border
        AA1 := AA - PixSearchSize;
        YA1 := YA1 * AA1;
        BB1 := BB - PixSearchSize;
        XB1 := XB1 * BB1;
        Result := Result and ((XB1*XB1 + YA1*YA1) >= AA1 * AA1 * BB1 * BB1);
      end;
    end;
}
    if Result then OneSR.SRType := srtArc;
  end else if CurSComp is TN_UDParaBox then // Text Blocks Component
  begin
    OneSR.SRType := srtParaBox;
    Result := True;
  end else if CurSComp is TN_UDPanel then  // Rectangle Panel Component
  begin
{
    RR := N_IPointNearIRect( CursorPPoint, CurSComp.CompIntPixRect,
                             Round(PixSearchSize / 2) );

    if (CurSFlags and 1) = 0 then
      Result := (RR and $F0) < $20
    else
      Result := (RR and $F) <> 0;

}
    CheckInPixRect();
    if Result then
      OneSR.SRType := srtPanel;

  end else if CurSComp is TN_UDDibRect then  // DIB Rectangle Panel Component
  begin
    if uddrfEllipseMask in TN_UDDIBRect(CurSComp).PSP.CDIBRect.CDRFlags then
      CheckEllipse()
    else
      CheckInPixRect();

    if Result then
      OneSR.SRType := srtDIBRect;
  end;


  if Result then
  with OneSR do
  begin
    SRCompInd := CurSCompInd;
    AddOneSR();
  end; // with OneSR do, if Result then

end; // function TN_SGComp.SearchInCurComp

//**************************************** TN_SGComp.AddOneSR ***
// Add One Search Result to CurSR array
//
procedure TN_SGComp.AddOneSR();
begin
  if High(CurSR) < NCurSR then
    SetLength( CurSR, N_NewLength(NCurSR) );
  move( OneSR, CurSR[NCurSR], Sizeof(CurSR[0]) );
  Inc(NCurSR);
end; // procedure TN_SGComp.AddOneSR


//****************  TN_RubberRectRFA class methods  *****************

//******************************************* TN_RubberRectRFA.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RubberRectRFA.SetActParams();
begin
  ActName := 'RubberRect';

  inherited;
end; // procedure TN_RubberRectRFA.SetActParams();

//************************************************ TN_RubberRectRFA.Execute ***
// Move or resize Self Rubber Rect
//
procedure TN_RubberRectRFA.Execute();
var
  dx, dy: integer;
  NewRect, TmpRectP: TRect;
  TmpMouseActionRFA: TN_RFAMouseAction;
  PU2P : TN_PAffCoefs4;
  PP2U : TN_PAffCoefs4;

  Label FinishAction, CancelAction;

  function ChangeRect( const AInpRect: TRect; AFlags: integer ): TRect; // local
  // Change given AInpRect by given AFlags and dx, dy
  // Return changed Rect
  begin
    if AFlags = $10 then // move Whole AInpRect (Shift AInpRect)
      Result := N_RectShift( AInpRect, dx, dy )
    else // move one, two or all sides
    begin
      Result := AInpRect;

      if (AFlags and $01) <> 0 then // move Top side or Top+Bottom
      begin
        Inc( Result.Top, dy );
        if Result.Bottom - Result.Top < RRMinPixSize.Y then
        begin
          Result.Top := Result.Bottom - RRMinPixSize.Y;
          dy := Result.Top - AInpRect.Top;
        end;
      end;

      if (AFlags and $02) <> 0 then // move Right side or Right+Left
      begin
        Inc( Result.Right, dx );
//        Result.Right := AInpRect.Right + dx;
        if Result.Right - Result.Left < RRMinPixSize.X then
        begin
          Result.Right := Result.Left + RRMinPixSize.X;
          dy := Result.Right - AInpRect.Right;
        end;
      end;

      if (AFlags and $04) <> 0 then // move Bottom side or Top+Bottom
      begin
        Inc( Result.Bottom, dy );
        if Result.Bottom - Result.Top < RRMinPixSize.Y then
        begin
          Result.Bottom := Result.Top + RRMinPixSize.Y;
          dy := Result.Bottom - AInpRect.Bottom;
        end;
      end;

      if (AFlags and $08) <> 0 then // move Left side or Right+Left
      begin
        Inc( Result.Left, dx );
        if Result.Right - Result.Left < RRMinPixSize.X then
        begin
          Result.Left := Result.Right - RRMinPixSize.X;
          dy := Result.Left - AInpRect.Left;
        end;
      end;
    end; // else // move one two or all sides
  end; // function ChangeRect - local

begin //************************************ body of TN_RubberRectRFA.Execute
  inherited;

  with ActGroup, ActGroup.RFrame do
  begin
//  if CHType = htMouseMove then // debug
//    ShowString( $3, Format( 'XY= %d, %d', [CCBuf.X, CCBuf.Y] ) );

    if not ActEnabled then
    begin
      if (CHType = htMouseMove) and not (ssLeft in CMKShift) and
                                    not (ssRight in CMKShift) then
        Screen.Cursor := crDefault; // precation

      Exit;
    end; // if not ActEnabled then


    if Assigned(RROnEventProcObj) then
      RROnEventProcObj( Self );


    TmpMouseActionRFA := TN_RFAMouseAction(RFMouseAction);

    if (CHType = htKeyDown) and (CKey.CharCode = VK_RETURN) then // Finish action
    begin
    FinishAction: //*********************

      TmpMouseActionRFA.RFADisable := False;
      N_SetCursorType( 0 );

      if Assigned(RROnOKProcObj) then
        RROnOKProcObj( Self );

      Exit;
    end; // if (CHType = htKeyDown) and (CKey.CharCode = VK_RETURN) then // Finish action

    if (CHType = htKeyDown) and (CKey.CharCode = VK_ESCAPE) then // Cancel action
    begin
    CancelAction: //*********************

      TmpMouseActionRFA.RFADisable := False;
      N_SetCursorType( 0 );

      if Assigned(RROnCancelProcObj) then
        RROnCancelProcObj( Self );

      Exit;
    end; // if (CHType = htKeyDown) and (CKey.CharCode = VK_ESCAPE) then // Cancel action

    if RRConP2UComp <> nil then
      PU2P := @RRConP2UComp.CompU2P
    else
      PU2P := @OCanv.U2P;

    if CHType = htMouseDown then // LeftClick, set RRSavedCC and RRSavedRect
    begin
      RRSavedCC := CCBuf;
      RRSavedRect := N_AffConvF2IRect( RRCurUserRect, PU2P^ );

      Exit;
    end; // if CHType = htMouseDown then

    if (CHType = htMouseMove) and not (ssLeft in CMKShift) then // move with
    begin                     // buttons Up, set RRFlags and Windows Cursor type
      TmpRectP := N_AffConvF2IRect( RRCurUserRect, PU2P^ );
      RRFlags  := N_CursorNearRect( TmpRectP, CCBuf, 2 );
      N_SetCursorType( RRFlags );
      TmpMouseActionRFA.RFADisable := (RRFlags and $10) <> 0;
      Exit;
    end; // move with buttons Up

  //***** Drag (change Rects coords)

    if (CHType = htMouseMove) and (ssLeft in CMKShift) then //***** Drag (change RRect coords)
    begin
      if RRFlags = 0 then Exit; // nothing to change

      dx := CCBuf.X - RRSavedCC.X; // X,Y shift values relative to RRSavedCC
      dy := CCBuf.Y - RRSavedCC.Y;

      if (dx = 0) and (dy = 0) then Exit; // no change, exit to avoid extra redrawing

      NewRect := ChangeRect( RRSavedRect, RRFlags );
      if RRConP2UComp <> nil then
        PP2U := @RRConP2UComp.CompP2U
      else
        PP2U := @OCanv.P2U;
      RRCurUserRect := N_AffConvI2FRect1( NewRect, PP2U^ );

      //***** Rect is changed, check if it is correct and update if needed
      with RRCurUserRect do // Rect should have size >= 0.1%
      begin
        if (Right - Left) < 0.001 then Right := Left + 0.001;
        if (Bottom - Top) < 0.001 then Bottom := Top + 0.001;
      end;

    //***** Src and Dst rects should be inside MaxRect
      RRCurUserRect := N_RectAdjustByMaxRect( RRCurUserRect, ActMaxURect );

      if Assigned(RROnChangeProcObj) then RROnChangeProcObj( Self );
    //***** Show RubberRect
{ !!!// needed for special redaw algorithm this - code is moved to MouseMoveRedraw
      Redraw();       // Update MainBuf (Draw Main Content)
      RedrawAction(); // Draw RubberRect
      ShowMainBuf();  // Update PaintBox
}
      if Assigned(RROnMouseMoveRedrawProcObj) then
        RROnMouseMoveRedrawProcObj()
      else
        MouseMoveRedraw;
      Exit;
    end; // if (CHType = htMouseMove) and (ssLeft in CMKShift) then // Drug (change RRect coords)

    if (CHType = htDblClick) then // DblClick, Finish or Cancel Action
    begin
//    N_SetCursorType( RRFlags );
      if RRFlags = 0 then goto CancelAction
                    else goto FinishAction;
    end; // if (CHType = htDblClick) then // DblClick, Convert Matr, CObjects and Redraw

  end; // with ActGroup, ActGroup.RFrame, RFAAlignForm do
end; // procedure TN_RubberRectRFA.Execute

//******************************************* TN_RubberRectRFA.RedrawAction ***
// Redraw Temporary Action objects
// ( is called from RFrame.RedrawAll and from Self.Execute
//   after Redraw and before ShowMainBuf )
//
procedure TN_RubberRectRFA.RedrawAction();
var
  PU2P : TN_PAffCoefs4;
begin
//  if not ActEnabled or RRSkipSelfDraw then Exit;
  if not ActEnabled then Exit;

  if Assigned(RROnRedrawProcObj) then
    RROnRedrawProcObj( Self )
  else
  with ActGroup.RFrame do
  begin
    if RRConP2UComp <> nil then
      PU2P := @RRConP2UComp.CompU2P
    else
      PU2P := @OCanv.U2P;
    RRCurPixRect := N_AffConvF2IRect( RRCurUserRect, PU2P^ );
    OCanv.DrawDashedRect( RRCurPixRect, 3, $000000, $FFFFFF );
  end; // with ActGroup.RFrame do
end; // procedure TN_RubberRectRFA.RedrawAction

//******************************************* TN_RubberRectRFA.RedrawAction ***
// Self MouseMove Redraw routine
//
procedure TN_RubberRectRFA.MouseMoveRedraw;
begin
  with ActGroup, ActGroup.RFrame do
  begin
    Redraw();       // Update MainBuf (Draw Main Content)
    RedrawAction(); // Draw RubberRect
    ShowMainBuf();  // Update PaintBox
  end;
end; // procedure TN_RubberRectRFA.MouseMoveRedraw

//****************  TN_RubberSegmRFA class methods  *****************

//******************************************* TN_RubberSegmRFA.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RubberSegmRFA.SetActParams();
begin
  ActName := 'RubberSegm';

  inherited;
end; // procedure TN_RubberSegmRFA.SetActParams();

//************************************************ TN_RubberSegmRFA.Execute ***
// Set RSUPoint1 and RSUPoint2 by MouseDown
//
procedure TN_RubberSegmRFA.Execute();
begin //************************************ body of TN_RubberSegmRFA.Execute
  inherited;
  if not ActEnabled then Exit;
  if (RSState = rsrfaFinished) or (RSState = rsrfaCanceled) then Exit; // a precaution

  if Assigned(RSOnMouseMoveProcObj) then
    RSOnMouseMoveProcObj( Self );

  with ActGroup, ActGroup.RFrame do
  begin
//  if CHType = htMouseMove then // debug
//    ShowString( $3, Format( 'XY= %d, %d', [CCBuf.X, CCBuf.Y] ) );

  if (CHType = htKeyDown) and (CKey.CharCode = VK_ESCAPE) then // Cancel action
  begin
    RSState := rsrfaCanceled;

    if Assigned(RSOnMouseDownProcObj) then
      RSOnMouseDownProcObj( Self );

    Exit;
  end; // if (CHType = htKeyDown) and (CKey.CharCode = VK_ESCAPE) then // Cancel action

  if CHType = htMouseDown then // LeftClick, set RSUPoint1 or RSUPoint2
  begin
    if RSState = rsrfaBeforeP1 then
    begin
      RSUPoint1 := N_AffConvD2DPoint( CCBufD, OCanv.P2U );
      RSState   := rsrfaDrawSegm;
    end else if RSState = rsrfaDrawSegm then
    begin
      RSUPoint2 := N_AffConvD2DPoint( CCBufD, OCanv.P2U );
      RSState   := rsrfaFinished;
    end;

    if Assigned(RSOnMouseDownProcObj) then
      RSOnMouseDownProcObj( Self );

    Exit;
  end; // if CHType = htMouseDown then // LeftClick, set RSUPoint1 or RSUPoint2

  end; // with ActGroup, ActGroup.RFrame, RFAAlignForm do

end; // procedure TN_RubberSegmRFA.Execute

//******************************************* TN_RubberSegmRFA.RedrawAction ***
// Redraw Temporary Action objects
// ( is called from RFrame.RedrawAll and from Self.Execute
//   after Redraw and before ShowMainBuf )
//
procedure TN_RubberSegmRFA.RedrawAction();
begin
  if not ActEnabled then Exit;

  if Assigned(RSOnRedrawProcObj) then
    RSOnRedrawProcObj( Self );
end; // procedure TN_RubberSegmRFA.RedrawAction


//****************  TN_EditCompsRFA class methods  *****************

//******************************************** TN_EditCompsRFA.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_EditCompsRFA.SetActParams();
begin
  ActName := 'EditComps';
  inherited;
end; // procedure TN_EditCompsRFA.SetActParams();

//************************************************* TN_EditCompsRFA.Execute ***
// Move or resize given Array of Visual Components
//
procedure TN_EditCompsRFA.Execute();
var
  i, dx, dy: integer;
  MoveCorner: boolean;
  BaseRect: TRect;
//  NewURect: TFRect;
  Label OnDblClickAction;
begin
  inherited;
  if not ActEnabled then Exit;

  ECSetCompPixRects();

  with ActGroup, ActGroup.RFrame do
  begin

  if CHType = htKeyDown then // OnDblClick action
  begin
    if (CKey.CharCode <> VK_ESCAPE) and
       (CKey.CharCode <> VK_RETURN) then Exit;

    if CKey.CharCode = VK_ESCAPE then
      ECPosFlags := 0;

    OnDblClickAction: //*********************

    if Assigned(ECOnDblClickProcObj) then
      ECOnDblClickProcObj( Self );

    Exit;
  end; // if CHType = htKeyDown then // OnDblClick action


  if CHType = htMouseDown then // Left or Right Click, set ECBase and ECBaseRects
  begin
    ECBase := CCBuf;

    for i := 0 to ECNumComps-1 do // Set ECBaseRects by Components
      ECBaseRects[i] := ECCurRects[i];

    if ssRight in CMKShift then // Right Click, set ECRectInd and call ECOnRightClickProcObj
    begin
      ECRectInd := N_IPointNearIRects( 0, ECCurRects, CCBuf, 3, ECPosFlags );
      if Assigned(ECOnRightClickProcObj) then
        ECOnRightClickProcObj( Self );

    end; // if (ssRight in CMKShift then // Right Click, just set ECRectInd

    Exit;
  end; // if CHType = htMouseDown then // LeftClick, set ECBase and ECBaseRects


  if (CHType = htMouseMove) and not (ssLeft in CMKShift) then // move with
  begin        // buttons Up, set ECPosFlags, ECRectInd and Windows Cursor type
    ECRectInd := N_IPointNearIRects( 0, ECCurRects, CCBuf, 3, ECPosFlags );

    if ECOnlyShift then
      ECPosFlags := ECPosFlags and $F0; // clear all flags except $10

    N_SetCursorType( ECPosFlags );
    Exit;
  end; // move with buttons Up


  if (CHType = htMouseMove) and (ssLeft in CMKShift) then // change coords
  begin                           // using ECRectInd, ECPosFlags (set at last MoseMove) and
                                  // and ECBase, ECBaseRects (set at last MoseDown)
    if ECRectInd = -1 then Exit; // no Comp was choosen, nothing to change

    dx := CCBuf.X - ECBase.X; // X,Y shift values relative to ECBase
    dy := CCBuf.Y - ECBase.Y;

    if (dx = 0) and (dy = 0) then Exit; // to avoid extra redrawing

    if N_KeyIsDown( VK_Shift ) and    // shift is allowed only along one Axis AND
          (ECPosFlags = $10)       then  //                Move, not resize mode
    begin
      if Abs(dx) > Abs(dy) then dy := 0
                           else dx := 0;
    end; // if N_KeyIsDown( VK_Shift ) ...

    // local vars BaseRect and ECNewPixRect are used just to reduce code size
    BaseRect := ECBaseRects[ECRectInd];
    ECNewPixRect  := BaseRect;

    //*******************  Move/Resize one or all Components

    if ECPosFlags = $10 then // move Whole Rect
      ECNewPixRect := N_RectShift( BaseRect, dx, dy )
    else // move one or two sides (corner)
    begin
      if (ECPosFlags and $01) <> 0 then // move Top side
        ECNewPixRect.Top := BaseRect.Top + dy;

      if (ECPosFlags and $02) <> 0 then // move Right side
        ECNewPixRect.Right := BaseRect.Right + dx;

      if (ECPosFlags and $04) <> 0 then // move Bottom side
        ECNewPixRect.Bottom := BaseRect.Bottom + dy;

      if (ECPosFlags and $08) <> 0 then // move Left side
        ECNewPixRect.Left := BaseRect.Left + dx;


      MoveCorner := (ECPosFlags = $13) or (ECPosFlags = $16) or
                    (ECPosFlags = $19) or (ECPosFlags = $1C);

      if MoveCorner and N_KeyIsDown( VK_Control ) then // preserve ECNewPixRect Aspect
      begin
        N_AdjustIRect( ECNewPixRect, Rect(0,0,2000,2000), 1, N_RectAspect( BaseRect ) );

        //***** preserve coords of opposite corner

        if (ECPosFlags and $01) <> 0 then // preserve Bottom side
          ECNewPixRect := N_RectShift( ECNewPixRect, 0, BaseRect.Bottom - ECNewPixRect.Bottom );

        if (ECPosFlags and $02) <> 0 then // preserve Left side
          ECNewPixRect := N_RectShift( ECNewPixRect, BaseRect.Left - ECNewPixRect.Left, 0 );

        if (ECPosFlags and $04) <> 0 then // preserve Top side
          ECNewPixRect := N_RectShift( ECNewPixRect, 0, BaseRect.Top - ECNewPixRect.Top );

        if (ECPosFlags and $08) <> 0 then // preserve Right side
          ECNewPixRect := N_RectShift( ECNewPixRect, BaseRect.Right - ECNewPixRect.Right, 0 );

      end; // if MoveCorner and N_KeyIsDown( VK_Control ) then // preserve ECNewPixRect Aspect

    end; // else // move one or two sides (corner)

    if Assigned(ECOnCoordsChangeProcObj) then
      ECOnCoordsChangeProcObj( Self );

    ECCurRects[ECRectInd] := ECNewPixRect; // update changed PixRect by ECNewPixRect

{
    NewURect := N_AffConvI2FRect1( ECNewPixRect, OCanv.P2U );
    NewURect := N_RectAdjustByMaxRect( NewURect, ActMaxURect ); // move inside ECMaxURect

    with ECComps[ECRectInd].PCCS()^ do // Update changed Component coords
    begin
      BPCoords := NewURect.TopLeft;
      LRCoords := NewURect.BottomRight;
    end;
}
    RedrawAllAndShow();
  end; // change coords ( move or resize Component(s) )

  if (CHType = htDblClick) then // DblClickAction
    goto OnDblClickAction;

  end; // with ActGroup, ActGroup.RFrame do

end; // procedure TN_EditCompsRFA.Execute

//*************************************** TN_EditCompsRFA.ECSetCompPixRects ***
// Recalculate ECCurRects if any RFrame Coords have been changed
//
procedure TN_EditCompsRFA.ECSetCompPixRects();
var
  i: integer;
begin
  with ActGroup.RFrame do
  begin
//    if N_Same( RFLogFramePRect, ECSavedLFPRect ) and
//       N_Same( RFSrcPRect, ECSavedSrcPRect ) then Exit; // ECCurRects are OK

    for i := 0 to ECNumComps-1 do // along all Object Components
      ECCurRects[i] := ECComps[i].CompOuterPixRect;

    ECSavedLFPRect  := RFLogFramePRect;
    ECSavedSrcPRect := RFSrcPRect;
  end; // with ActGroup.RFrame do

end; // procedure TN_EditCompsRFA.ECSetCompPixRects();

//**************************************** TN_EditCompsRFA.ECSetCompBPCLRCU ***
// Set Component Static BPCoords and LRCoords in User Coords Units
// (may be used as ECOnCoordsChangeProcObj)
//
procedure TN_EditCompsRFA.ECSetCompBPCLRCU( AEditCompsRFA: TObject );
var
  NewURect: TFRect;
begin
  if not (AEditCompsRFA is TN_EditCompsRFA) then Exit; // a precaution

  with TN_EditCompsRFA(AEditCompsRFA), ECComps[ECRectInd].PCCS()^, ActGroup.RFrame do
  begin
    NewURect := N_AffConvI2FRect1( ECNewPixRect, OCanv.P2U );
    NewURect := N_RectAdjustByMaxRect( NewURect, ActMaxURect ); // move inside ECMaxURect

    BPXCoordsType := cbpUser;
    BPYCoordsType := cbpUser;
    BPCoords := NewURect.TopLeft;

    LRXCoordsType := cbpUser;
    LRYCoordsType := cbpUser;
    LRCoords := NewURect.BottomRight;
  end; // with TN_EditCompsRFA(AEditCompsRFA), ECComps[ECRectInd].PCCS()^, ActGroup.RFrame do

end; // procedure TN_EditCompsRFA.ECSetCompBPCLRCU();

//**************************************** TN_EditCompsRFA.ECSetCompBPShift ***
// Update Component Static BPShift
// (may be used as ECOnCoordsChangeProcObj)
//
procedure TN_EditCompsRFA.ECSetCompBPShift( AEditCompsRFA: TObject );
var
  PixShift: TPoint;
  PrevPixRect: TRect;
begin
  if not (AEditCompsRFA is TN_EditCompsRFA) then Exit; // a precaution

  with TN_EditCompsRFA(AEditCompsRFA), ECComps[ECRectInd], PCCS()^, ActGroup.RFrame do
  begin
    PrevPixRect := ECCurRects[ECRectInd];

    PixShift.X := ECNewPixRect.Left - PrevPixRect.Left;
    PixShift.Y := ECNewPixRect.Top  - PrevPixRect.Top;

    BPShift.X := BPShift.X + PixShift.X / OCanv.CurLSUPixSize;
    BPShift.Y := BPShift.Y + PixShift.Y / OCanv.CurLSUPixSize;
  end; // with TN_EditCompsRFA(AEditCompsRFA), ECComps[ECRectInd].PCCS()^, ActGroup.RFrame do

end; // procedure TN_EditCompsRFA.ECSetCompBPShift


end.
