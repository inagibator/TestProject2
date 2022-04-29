unit N_MapTools;
// Different Map Tools

interface
uses Windows, Classes,
  K_UDT1, K_DCSpace, K_CSpace,
  N_Types, N_Lib1, N_UDat4, N_CompBase;

type TN_CObjItemRef = record // Reference to one CObj Item
  CIRCObj: TN_UCObjLayer;
  CIRItemInd: integer;
end; // type TN_CObjItemRef = record // Reference to one CObj Item
type TN_CObjItemRefs = Array of TN_CObjItemRef;

type TN_MapToolsObj = class( TObject )
  MTMapPixSize: TPoint; // Map Raster Pixel X,Y Size
  MTMapPixRect: TRect;  // Map Raster Pixel Rect ( IRect(MTMapPixSize) )
  MTMapUCoords: TFRect; // Needed Map Envelope Rect in User Coords
  MTU2P: TN_AffCoefs4;  // User to Pixel Coords affine convertion coords
  MTCObjItemRefs: TN_CObjItemRefs; // array of references to CObj Items
  MTCS: TK_UDDCSpace;              // Map Codes Space

  procedure AddCObjItemRefs    ( ACObj: TN_UDBase; ACDimInd: integer );
  procedure CreateU2PCoefs     ( AURect: TFRect; AMapPixSize: TPoint );
  procedure CreateRasterMap    ( AComp: TN_UDCompVis; AFileName: string );
  function  CreateHTMLMapItem  ( ACode, APartInd, ASize: integer ): string;
end; // type TN_MapToolsObj = class( TObject );


implementation
uses SysUtils,
  N_Gra0, N_Gra1, N_CompCL, N_GCont, N_ME1;

//****************************************** TN_MapToolsObj.AddCObjItemRefs ***
// Add to MTCObjItemRefs array new elements from given ACObj
// MTCObjItemRefs[Code] is reference to CObj Item with Code in given ACDimInd
//
procedure TN_MapToolsObj.AddCObjItemRefs( ACObj: TN_UDBase; ACDimInd: integer );
var
  j, k, CurCode, CurLeng: integer;
begin
  if not (ACObj is TN_UCObjLayer) then Exit; // skip if not proper type

  with TN_UCObjLayer(ACObj) do
  begin

    for j := 0 to WNumItems-1 do // along all Items of ACObj
    begin
      CurCode := GetItemFirstCode( j, ACDimInd );
      if CurCode = -1 then Continue; // Item has no code

      CurLeng := Length( MTCObjItemRefs );
      if CurCode >= CurLeng then // increase MTCObjItemRefs
      begin
        SetLength( MTCObjItemRefs, N_NewLength(CurCode+1) );

        for k := CurLeng to High(MTCObjItemRefs) do // clear newlly created items
        with MTCObjItemRefs[k] do
        begin
          CIRCObj    := nil;
          CIRItemInd := -1;
        end; // for k := CurLeng to High(MTCObjItemRefs) do // clear newlly created items
      end; // if CurCode > CurLeng then // increase MTCObjItemRefs

      with MTCObjItemRefs[CurCode] do
      begin
        CIRCObj    := TN_UCObjLayer(ACObj);
        CIRItemInd := j;
      end; // with MTCObjItemRefs[CurCode] do

    end; // for j := 0 to WNumItems-1 do // along all Items of ACObj
  end; // with TN_UCObjLayer(CurCObj) do
end; // procedure TN_MapToolsObj.AddCObjItemRefs

//******************************************* TN_MapToolsObj.CreateU2PCoefs ***
// CReate MTMapUCoords and MTU2P by given AURect and AMapPixSize
//
procedure TN_MapToolsObj.CreateU2PCoefs( AURect: TFRect; AMapPixSize: TPoint );
var
  HalfPixSizeX, HalfPixSizeY, NeededAspect: double;
  MapPixRect: TRect;
  TmpURect, DPRect: TDRect;
begin
  MTMapPixSize := AMapPixSize;
  MTMapPixRect := IRect( MTMapPixSize );

  NeededAspect := AMapPixSize.Y / AMapPixSize.X;
  MTMapUCoords := N_IncRectByAspect( AURect, NeededAspect );

  HalfPixSizeX := 0.45 * (AURect.Right - AURect.Left) / AMapPixSize.X;
  HalfPixSizeY := 0.45 * (AURect.Bottom - AURect.Top) / AMapPixSize.Y;

  MapPixRect := IRect( AMapPixSize );

  with MTMapUCoords do
    TmpURect := DRect( Left+HalfPixSizeX,  Top+HalfPixSizeY,
                       Right-HalfPixSizeX, Bottom-HalfPixSizeY );

  DPRect := DRect( MapPixRect.Left, MapPixRect.Top, MapPixRect.Right, MapPixRect.Bottom );

  MTU2P := N_CalcAffCoefs4( TmpURect, DPRect );
end; // procedure TN_MapToolsObj.CreateU2PCoefs

//****************************************** TN_MapToolsObj.CreateRasterMap ***
// CReate MTMapUCoords and MTU2P by given AURect and AMapPixSize
// (MTMapPixSize and MTMapUCoords should be already OK)
//
procedure TN_MapToolsObj.CreateRasterMap( AComp: TN_UDCompVis; AFileName: string );
var
  ExpParams: TN_ExpParams;
  SavedCCoords: TN_CompCoords;
begin

  //***** Prepare Root AComp Coords
  SavedCCoords := AComp.PCCS^; // save for restoring after Execute
  with AComp.PCCS^ do
  begin
    SRSize       := FPoint( MTMapPixSize );
    SRSizeAspect := 0;
    CompUCoords  := MTMapUCoords;
    SRSizeXType  := cstPixel;
    SRSizeYType  := cstPixel;
    UCoordsType  := cutGivenAnyAsp;
  end; // with AComp.PCCS^ do

  //***** Prepare Export Params
  FillChar( ExpParams, Sizeof(ExpParams), 0 );
  with ExpParams do
  begin
    EPMainFName := AFileName;
    EPImageFPar.IFPJPEGQuality := 100;
  end; // with ExpParams do

  N_MEGlobObj.NVGlobCont.ExecuteRootComp( AComp, [], nil, nil, @ExpParams );

  AComp.PCCS^ := SavedCCoords; // restore AComp coords
end; // procedure TN_MapToolsObj.CreateRasterMap

//**************************************** TN_MapToolsObj.CreateHTMLMapItem ***
// CReate String with HTML Map Item Pixel Coords by given Item Code
// using info in MTCObjItemRefs[ACode], ASize is Pix Circle Size
// ( MTCObjItemRefs array and MTU2P should be already OK )
//
function TN_MapToolsObj.CreateHTMLMapItem( ACode, APartInd, ASize: integer ): string;
var
  i, FirstInd, NumInds, FRInd, NumRings, NumPixPoints: integer;
  CurPixPoint: TPoint;
  PixPoints: TN_IPArray;
begin
  Result := '';
  if (ACode < 0) or (ACode > High(MTCObjItemRefs)) then Exit; // a precaution

  with MTCObjItemRefs[ACode] do
  begin
    if CIRCObj is TN_UDPoints then // Points Layer
    with TN_UDPoints(CIRCObj) do
    begin
      GetItemInds( CIRItemInd, FirstInd, NumInds ); // NumInds - Points group size (usually=1)
      if (APartInd < 0) or (APartInd >= NumInds) then Exit;

      CurPixPoint := N_AffConvD2IPoint( CCoords[FirstInd+APartInd], MTU2P );
      if APartInd = 0 then // check visibility only once
        if 0 <> N_PointInRect( CurPixPoint, MTMapPixRect ) then Exit; // Point is not visible (out of Map Rect)

      with CurPixPoint do
        Result := Format( 'SHAPE=CIRCLE COORDS="%d,%d,%d"', [X, Y, ASize] );
    end else if CIRCObj is TN_UContours then // Contours Layer
    with TN_UContours(CIRCObj) do
    begin
      GetItemInds( CIRItemInd, FRInd, NumRings );
      if NumRings = 0 then Exit; // contour is empty
      if (APartInd < 0) or (APartInd >= NumRings) then Exit;

      if APartInd = 0 then // check visibility only once
        if 0 = N_FRectAnd( Items[CIRItemInd].EnvRect, MTMapUCoords ) then Exit; // Contour is not visible (out of Map Rect)

//      ContUserEnvRect := Items[CIRItemInd].EnvRect;
//      if 0 = N_FRectAnd( ContUserEnvRect, MTMapUCoords ) then Exit; // Contour is not visible (out of Map Rect)

      with CRings[FRInd+APartInd] do // APartInd is Ring index
      begin
        Result := 'SHAPE=POLY    COORDS="';

        if RFCoords <> nil then // float Ring coords, use RFCoords array
        begin
          NumPixPoints := Length(RFCoords);
          SetLength( PixPoints, NumPixPoints );
          NumPixPoints := N_ConvFLineToILine2( MTU2P, NumPixPoints,
                                               @RFCoords[0], @PixPoints[0] );
        end else // double Ring coords, use RDCoords array
        begin
          NumPixPoints := Length(RDCoords);
          SetLength( PixPoints, NumPixPoints );
          NumPixPoints := N_ConvDLineToILine2( MTU2P, NumPixPoints,
                                               @RDCoords[0], @PixPoints[0] );
        end;

        for i := 0 to NumPixPoints-1 do
        with PixPoints[i] do
          Result := Result + Format( '%d,%d,', [X,Y] );

        Result[Length(Result)] := '"'; // replace last ',' by '"'
      end; // with CRings[FRInd] do

    end else
      Exit; //a precaution

  end; // with MTCObjItemRefs[ACode] do

end; // function TN_MapToolsObj.CreateHTMLMapItem

end.
