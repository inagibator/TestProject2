unit N_Act1;
// Several Actions, called from TN_UDAction Component:
//
// Coords Objects and Map utilities
// Components Creation
// UObjects related Actions
// Word Documents creation
// Excel Documents creation
//
// (see comments at end of file)

interface
uses
  Windows, Classes, Graphics, StdCtrls,
  N_Lib2, N_Comp1;

//*************** Coords Objects and Map utilities
procedure N_ActULinesAction1    ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActULinesAction2    ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActCreateUDPoints   ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActCreateULines     ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActCObjAction1      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActCObjAction2      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActExportCObj       ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActChangeCObjCodes  ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActChangeMLUObj     ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActFillVisVector    ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActConvCoords1      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActNonLinConv1      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActSnapULines       ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActJavaToSVG1       ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActJavaToULines     ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActContCenterPoints ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActCreateTextBlocks ( APParams: TN_PCAction; AP1, AP2: Pointer );

//**************** Any UObjects related Actions
procedure N_ActSysActions1  ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActSysActions2  ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActReplaceRefs  ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActVFileCodec   ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActDebAction_1  ( APParams: TN_PCAction; AP1, AP2: Pointer );

//**************** Components Creation
procedure N_ActLayoutComps      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActCreateLinHist_1  ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActCreateLinHist_2  ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActSetMCLHUP        ( APParams: TN_PCAction; AP1, AP2: Pointer );

//**************** Word Documents creation
procedure N_ActGetWordIcons     ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActWordDebActive1   ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActWordCreateTable1 ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActWordActions      ( APParams: TN_PCAction; AP1, AP2: Pointer );

//**************** Excel Documents creation
procedure N_ActGetExcelIcons ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActExcelDeb1     ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActExcelDeb2     ( APParams: TN_PCAction; AP1, AP2: Pointer );

//**************** Other Actions
procedure N_ActCreateGif      ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActFileActions    ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActListParaBoxes  ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActCompsToPas1    ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActToggleSkipSelf ( APParams: TN_PCAction; AP1, AP2: Pointer );
procedure N_ActUpdateAttrs1   ( APParams: TN_PCAction; AP1, AP2: Pointer );

//**************** Not Actions
function  N_CreateMatrConvObj ( AUDActionComp: TN_UDAction ): integer;

var
  N_ActChanInd: integer = 0; // Protocol Channel Index used in Actions

implementation
uses Math, Controls, SysUtils, Dialogs, StrUtils, Contnrs, Forms,
     Variants, ComObj, ActiveX, Clipbrd,
     K_CLib0, K_UDConst, K_VFunc, K_Script1, K_UDT1, K_UDT2,
     K_DCSpace, K_Arch, K_Parse,
     N_Types, N_Lib1, N_Gra0, N_Gra1, N_Lib0, N_Deb1, N_InfoF, N_ClassRef, N_ME1,
     N_Rast1Fr, N_Gra2, N_Gra3, N_Gra4, N_UDCMap, N_NVTreeFr,
     N_BaseF, N_GCont, N_CompBase, N_UDat4, N_RVCTF, N_CompCL, N_Comp2,
     N_MsgDialF, N_EdStrF, N_2DFunc1, N_EdParF, N_NLConvF;


//*************** Coords Objects and Map utilities

//****************************************************** N_ActULinesAction1 ***
// Several Actions with Ulines # 1 (see comments inside)
//
// (for using in TN_UDAction under Action Name 'ULinesAction1' )
//
procedure N_ActULinesAction1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, MaxInd, Flags, NChanel, DstCoordsType: integer;
  MinDist, MaxDist, Coef, Percents: double;
  Str, SrcName, DstName, MLName, MsgStr: string;
  DataRoot, CObjectsRoot, MapRoot, UObj: TN_UDBase;
  SrcULines, DstULines: TN_ULines;
  Maplayer: TN_UDMapLayer;
  UDActionComp: TN_UDAction;
  SL: TStringList;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
  begin
    //***** Get Params
    MLName := '';

    DataRoot  := CAUDBase1;   // Data and CoordsObjects Root
    MapRoot   := CAUDBase2;   // Map Root
    SrcName   := CAStr1;      // SrcULines Name in CObjectsRoot (not used in Add list of Ulines)
    DstName   := CAStr2;      // SrcULines Name in CObjectsRoot

    Str := CAParStr1;
    NChanel   := N_ScanInteger( Str ); // CAIPoint1.X; // Protocol Chanel
    MinDist   := N_ScanDouble( Str ); // CADPoint1.X;
    MaxDist   := N_ScanDouble( Str ); // CADPoint1.Y;
    Coef      := N_ScanDouble( Str ); // CADouble1;

    Flags     := CAFlags1;
    // bits $00000F - Protocol bits (0 - nothing, 1 - summary)
    // bits $0000F0 - Sub Action Flags, depend upon Main Action
    // bits $000F00 - Main Action To Perform (SrcULines remains the same, DstULines changes):
    //                =1 - Add list of Ulines to DstULines
    //                =2 - Copy with possible Coords Type changing (SrcULines to DstUlines)
    //                =3 - Snap To Grid (SrcULines to DstUlines)
    //                =4 - Remove Small Segments or Lines (SrcULines to DstUlines)
                   //      (not yet, take code from N_ActSnapULines)
    //                =5 - Remove Exactly Same Segments
    //                =6 - Remove Near Lines (not exactly the Same)
    //                =7 - Smooth by Removing Points:
    //                     CADPoint1 is (MinDist,MaxDist), CADouble1 is Coef
    //                =8 - Not used now
    //                =9 - Not used now
    //                =A - Not used now

    case Flags and $0F00 of // Action specific initial settings

      $0100: begin
               MsgStr := 'Add Ulines';
               MLName := 'ML' + DstName;
             end;

      $0200: begin
               MsgStr := 'Copy Coords';
               MLName := 'ML' + DstName;
             end;

      $0300: begin
               MsgStr := 'Snap To Grid';
             end;

      $0400: begin
               MsgStr := 'Remove Small Segms';
             end;

      $0500: begin
               MsgStr := 'Remove Same Segms';
             end;

      $0600: begin
               MsgStr := 'Remove Near Lines';
             end;

      $0700: begin
               MsgStr := 'Smooth by Removing Points';
             end;

      $0800: begin
               MsgStr := 'Not used now';
             end;

      $0900: begin
               MsgStr := 'Not used now';
             end;

      $0A00: begin
               MsgStr := 'Not used now';
             end;

    end; // case Flags and $0F00 of // Action specific initial settings

    if DataRoot = nil then
    begin
      N_CurShowStr( 'No DataRoot' );
      Exit;
    end;

    CObjectsRoot := DataRoot.DirChildByObjName( 'CObjects' );
    if CObjectsRoot = nil then
    begin
      if (Flags and $0F00) = $0100 then // Add List of ULines, Create CObjectsRoot
      begin
        CObjectsRoot := TN_UDBase.Create();
        N_AddUChild( DataRoot, CObjectsRoot, 'CObjects' );
      end else // all other
      begin
        if CAUDBase3 <> nil then
          CObjectsRoot := CAUDBase3
        else
        begin
          N_CurShowStr( 'No CObjects Dir' );
          Exit;
        end;  
      end;
    end; // if CObjectsRoot = nil then

    if (Flags and $0F00) = $0100 then // Add List of ULines
    begin
      if CAUDBaseArray.ALength() = 0 then
        UObj := CAUDBase3
      else
        UObj := TN_PUDBase(CAUDBaseArray.P(0))^;

      SrcName := UObj.ObjName;
    end else // all other
      UObj := CObjectsRoot.DirChildByObjName( SrcName );

    if not (UObj is TN_ULines) then
    begin
      N_CurShowStr( 'Bad ' + SrcName );
      Exit;
    end;
    SrcULines := TN_ULines(UObj);

    UObj := CObjectsRoot.DirChildByObjName( DstName );
    if (UObj <> nil) and not (UObj is TN_ULines) then
    begin
      N_CurShowStr( 'Bad ' + DstName );
      Exit;
    end;
    DstULines := TN_ULines(UObj);

    DstCoordsType := N_DoubleCoords;
    if (Flags and $0F00) <= $0200 then // Add or Copy Coords Action
    begin
      case (Flags and $0F0) of
        $000: DstCoordsType := SrcULines.WLCType;
        $010: DstCoordsType := N_FloatCoords;
        $020: DstCoordsType := N_DoubleCoords;
        $030: if DstULines <> nil then DstCoordsType := DstULines.WLCType;
      end;
    end else // all other Actions (not Add or Copy Coords)
    begin
      DstCoordsType := SrcULines.WLCType;
    end;

    if (DstName <> '') and (DstULines = nil) then // Create new DstULines
    begin
      DstULines := TN_ULines.Create1( DstCoordsType );
      N_AddUChild( CObjectsRoot, DstULines, DstName );
    end;
    Str := K_DateTimeToStr( Date+Time, 'dd.mm.yyyy(hh:nn:ss)' );
    DstULines.WComment := 'Created at ' + Str + ' from: ' + SrcName + ' ';

    if MLName <> '' then // Map Layer should be created
    begin

      MapLayer := TN_UDMapLayer(MapRoot.DirChildByObjName( MLName ));
      if MapLayer = nil then
      begin
        MapLayer := TN_UDMapLayer(K_CreateUDByRTypeName( 'TN_RMapLayer', 1, N_UDMapLayerCI ));
        N_AddUChild( MapRoot, MapLayer, MLName );
      end;

      with MapLayer.InitMLParams( mltLines1 )^ do
      begin
        MLPenColor   := CAColor1;
        MLPenWidth   := CAIRect.Left; // CAInt2;
        MLBrushColor := N_EmptyColor;
        K_SetUDRefField( TN_UDBase(MLCObj), DstULines ); // later may be changed
      end;

    end; // if MLName <> '' then // Map Layer should be created

    SL := TStringList.Create;

    if (Flags and $0F) > 0 then // Add Protocol Header and begin message
    begin
      SL.Add( '' );
      SL.Add( '      ' + MsgStr );
//      if SrcULines <> nil then SL.Add( ' Src ULines is ' + SrcULines.GetRefPath() );
//      if DstULines <> nil then SL.Add( ' Dst ULines is ' + DstULines.GetRefPath() );
      if SrcULines <> nil then SL.Add( ' Src ULines is ' + K_GetPathToUObj( SrcULines ) );
      if DstULines <> nil then SL.Add( ' Dst ULines is ' + K_GetPathToUObj( DstULines ) );

      N_CurShowStr( MsgStr );
    end; // if (Flags and $0F) > 0 then // Add Protocol Header and begin message


    //*********************  Action Main Code  ********************

    if (Flags and $0F00) = $0100 then // Add Ulines
    begin
      if (Flags and $01000) = $0000 then // Clear DstULines first
          DstULines.InitItems( 1000, 10000 );

      MaxInd := CAUDBaseArray.AHigh();

      if MaxInd = -1 then // CAUDBaseArray is empty use CAUDBase3 instead
      begin

        if CAUDBase3 is TN_ULines then
          DstULines.AddULItems( TN_ULines(CAUDBase3), 0, -1 );

      end else // CAUDBaseArray is not empty
      begin

        for i := 0 to CAUDBaseArray.AHigh() do
        begin
          UObj := TN_PUDBase(CAUDBaseArray.P(i))^;

          if UObj is TN_ULines then
          begin
            DstULines.AddULItems( TN_ULines(UObj), 0, -1 );
            if i > 0 then
            DstULines.WComment := DstULines.WComment + '+ ' + UObj.ObjName;
          end;
        end; // for i := 0 to CAUDBaseArray.AHigh() do

      end; // else // CAUDBaseArray is not empty

      DstULines.CalcEnvRects();
      SL.Add( DstULines.WComment );
    end //*****  $0100 Add Ulines

    else if (Flags and $0F00) = $0200 then // Copy with possible Coords Type changing
    begin                                  // (SrcULines to DstUlines)
      DstULines.WLCType := DstCoordsType;
      DstULines.CopyCoords( SrcULines );
    end  //***** $0200 Copy Coords

    else if (Flags and $0F00) = $0300 then // Snap To Grid (SrcULines to DstUlines)
    begin                                      // (SrcULines to DstUlines)
      DstULines.WLCType := DstCoordsType;
      DstULines.CopyCoords( SrcULines );
    end //***** $0300 Snap To Grid

    else if (Flags and $0F00) = $0400 then // Remove Small Segments or Lines
    begin                                      //  (SrcULines to DstUlines)
      // take code from N_ActSnapULines
    end //***** $0400 Remove Small Segments or Lines

    else if (Flags and $0F00) = $0500 then // Remove Exactly Same Segments
    begin                                  //  (SrcULines to DstUlines)
      N_RemoveSameFragments( SrcULines, DstULines, SL, Flags and $0F );
    end //***** $0500 Remove Exactly Same Segments

    else if (Flags and $0F00) = $0600 then // Remove Near Lines (not exactly the Same)
    begin
      N_RemoveNearLines( SrcULines, DstULines, MinDist, SL, Flags and $0F );
    end //***** $0600 Remove Near Lines

    else if (Flags and $0F00) = $0700 then // Smooth by removing Points
    begin
      Percents := N_SmoothByRemovingPoints( SrcULines, DstULines,
                                MinDist, MaxDist, Coef, SL, Flags and $0FF );
      N_CurShowStr( Format( ' %.1f%s Points Remain', [Percents, '%'] ) );
    end //***** $0700 Smooth by removing Points

    else if (Flags and $0F00) = $0800 then // Not used now
    begin

    end //*****

    else if (Flags and $0F00) = $0900 then // Not used now
    begin

    end //*****

    else if (Flags and $0F00) = $0A00 then // Not used now
    begin

    end; //*****

    if (Flags and $0F000) = $01000 then // View DstULines
    begin
      N_ViewCObjLayer( DstULines, nil, GCOwnerForm );
    end; if (Flags and $0F000) = $01000 then // View DstULines

    if (Flags and $0F) > 0 then
    begin
      if SL.Count > 0 then N_AddStr( NChanel, SL.Text );
    end;

  end; // with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
end; //*** end of procedure N_ActULinesAction1


//****************************************************** N_ActULinesAction2 ***
// Several Actions with Ulines # 2 (see comments inside)
//
// (for using in TN_UDAction under Action Name "ULinesAction2)
//
procedure N_ActULinesAction2( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  Flags, NChanel, DstCoordsType, ResCode, NumXY, NumPases: integer;
  Str: string;
  IncCoef: double;
  SrcName, DstName, MLName, MsgStr: string;
  DataRoot, CObjectsRoot, MapRoot, UObj: TN_UDBase;
  SrcULines, DstULines: TN_ULines;
  Maplayer: TN_UDMapLayer;
  UDActionComp: TN_UDAction;
  SL: TStringList;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
  begin
    //***** Get Params
    MLName := '';

    DataRoot  := CAUDBase1; // Data and CoordsObjects Root
    MapRoot   := CAUDBase2; // Map Root
    SrcName   := CAStr1;
    DstName   := CAStr2;

    Str := CAParStr1;
    NChanel   := N_ScanInteger( Str ); // CAIPoint1.X; // Protocol Chanel
    NumPases  := N_ScanInteger( Str ); // CAIPoint1.Y;
    NumXY     := N_ScanInteger( Str ); // CAIPoint1.Y;
    IncCoef   := N_ScanDouble( Str ); // CADPoint1.X;

    Flags     := CAFlags1;
    // bits $00000F - Protocol bits (0 - nothing, 1 - summary)
    // bits $000F0 - Sub Action Flags, depend upon Main Action
    // bits $000F00 - Main Action To Perform (SrcULines remains the same, DstULines changes):
    //                =1 - Check Segments Crossings
    //                =2 - (Not Yet) Correct Crossings #1 (only after Check Crossings)
    //                =3 - (Not Yet) Correct Crossings #2 (only after Check Crossings)
    //                =4 - Check Node's Line Codes
    //                =5 - Combine Adjasent Lines with same codes

    case Flags and $0F00 of // Action specific initial settings

      $0100: begin
               MsgStr := 'Check Segments Crossings';
               MLName := 'ML' + DstName;
             end;

      $0200: begin
               MsgStr := '(Not Yet) Correct Crossings #1';
             end;

      $0300: begin
               MsgStr := '(Not Yet) Correct Crossings #2';
             end;

      $0400: begin
               MsgStr := 'Check Node Lines Codes';
             end;

      $0500: begin
               MsgStr := 'Combine Adjasent Lines';
             end;

      $0600: begin
               MsgStr := 'Not Yet';
             end;

      $0700: begin
               MsgStr := 'Not Yet';
             end;

      $0800: begin
               MsgStr := 'Not Yet';
             end;

      $0900: begin
               MsgStr := 'Not Yet';
             end;

    end; //  case Flags and $0F00 of // Action specific initial settings

    CObjectsRoot := DataRoot.DirChildByObjName( 'CObjects' );
    if CObjectsRoot = nil then
    begin
      N_CurShowStr( 'No Coords Objects' );
      Exit;
    end;

    UObj := CObjectsRoot.DirChildByObjName( SrcName );
    if not (UObj is TN_ULines) then
    begin
      N_CurShowStr( 'Bad ' + SrcName );
      Exit;
    end;
    SrcULines := TN_ULines(UObj);

    UObj := CObjectsRoot.DirChildByObjName( DstName );
    if (UObj <> nil) and not (UObj is TN_ULines) then
    begin
      N_CurShowStr( 'Bad ' + DstName );
      Exit;
    end;
    DstULines := TN_ULines(UObj);

    DstCoordsType := SrcULines.WLCType;

    if (DstName <> '') and (DstULines = nil) then // Create new DstULines
    begin
      DstULines := TN_ULines.Create1( DstCoordsType );
      N_AddUChild( CObjectsRoot, DstULines, DstName );
    end;

    if MLName <> '' then // Map Layer should be created
    begin

      MapLayer := TN_UDMapLayer(MapRoot.DirChildByObjName( MLName ));
      if MapLayer = nil then
      begin
        MapLayer := TN_UDMapLayer(K_CreateUDByRTypeName( 'TN_RMapLayer', 1, N_UDMapLayerCI ));
        N_AddUChild( MapRoot, MapLayer, MLName );
      end;

      with MapLayer.InitMLParams( mltLines1 )^ do
      begin
        MLPenColor   := CAColor1;
        MLPenWidth   := CAIRect.Left; // ;

        if ((Flags and $0F00) = $0100) and // Check Segments Crossings or Touchings
           (MLPenWidth = 0) then MLPenWidth := 3; // set most likely value
           
        MLBrushColor := N_EmptyColor;
        K_SetUDRefField( TN_UDBase(MLCObj), DstULines ); // later may be changed
      end;

    end; // if MLName <> '' then // Map Layer should be created

    SL := TStringList.Create;

    if (Flags and $0F) > 0 then // Add Protocol Header and begin message
    begin
      SL.Add( '' );
      SL.Add( '      ' + MsgStr );
//      if SrcULines <> nil then SL.Add( ' Src ULines is ' + SrcULines.GetRefPath() );
//      if DstULines <> nil then SL.Add( ' Dst ULines is ' + DstULines.GetRefPath() );
      if SrcULines <> nil then SL.Add( ' Src ULines is ' + K_GetPathToUObj( SrcULines ) );
      if DstULines <> nil then SL.Add( ' Dst ULines is ' + K_GetPathToUObj( DstULines ) );

      N_CurShowStr( MsgStr );
    end; // if (Flags and $0F) > 0 then // Add Protocol Header and begin message


    //*********************  Action Main Code  ********************

    if (Flags and $0F00) = $0100 then // Check Segments Crossings or Touchings
    begin
      with UDActionComp do
      begin
        DstULines.InitItems( 10 );
        UDActObj1.Free; // a precaution
        TN_StructSegms(UDActObj1) := N_CheckSegmentsCrossings( SrcULines, DstULines,
                                          NumXY, IncCoef, SL, Flags and $0FF );
        N_CurShowStr( Format( ' %d Crossings found',
                                    [TN_StructSegms(UDActObj1).NumCrossed] ) );
      end; // with UDActionComp do
    end // ***** $0100 Check Segments Crossings or Touchings

    else if (Flags and $0F00) = $0200 then // (Not Yet) Correct Crossings #1
    begin

    end //***** $0200 (Not Yet) Correct Crossings #1

    else if (Flags and $0F00) = $0300 then // (Not Yet) Correct Crossings #2
    begin

    end //***** $0300 (Not Yet) Correct Crossings #2

    else if (Flags and $0F00) = $0400 then // Check Node's Line Codes
    begin
      ResCode := N_CheckLinesCodes( SrcULines, SL, Flags and $0F );
      N_CurShowStr( Format( '%s: %d Errors', [MsgStr, ResCode] ) );
    end //***** $0400 Check Node's Line Codes

    else if (Flags and $0F00) = $0500 then // Combine Adjasent Lines with same codes
    begin
      DstULines.CopyContent( SrcULines );
      ResCode := N_CombineLines( DstULines, NumPases, SL, Flags and $0F );
      N_CurShowStr( Format( '%s: Total - %d Lines Combined', [MsgStr, ResCode] ) );
    end //***** $0500 Combine Adjasent Lines with same codes

    else if (Flags and $0F00) = $0600 then // Not yet
    begin
    end //***** $0600 Not yet

    else if (Flags and $0F00) = $0700 then // Not yet
    begin

    end //***** $0700 Not yet

    else if (Flags and $0F00) = $0800 then // Not yet
    begin

    end //***** $0800 Not yet

    else if (Flags and $0F00) = $0900 then // Not yet
    begin

    end //***** $0900 Not yet

    else if (Flags and $0F00) = $0A00 then //
    begin

    end; //***** $0A00

    if (Flags and $0F) > 0 then // Add To Protocol
    begin
      if SL.Count > 0 then N_AddStr( NChanel, SL.Text );
    end; // if (Flags and $0F) > 0 then // Add To Protocol

  end; // with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
end; //*** end of procedure N_ActULinesAction2

//******************************************************* N_ActCreateUDPoints ***
// Create UDPoints in several modes:
// - Create GridNodes and Points or Labels MapLayer
//
// (for using in TN_UDAction under Action Name "CreateUDPoints")
//
procedure N_ActCreateUDPoints( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  ix, iy, ind, Flags, NChanel, Accuracy: integer;
  Str, DstName, MLName, MsgStr, Fmt: string;
  GridStep, GridOrigin: TDPoint;
  DataRoot, CObjectsRoot, MapRoot, UObj: TN_UDBase;
  DstUDPoints: TN_UDPoints;
  Maplayer: TN_UDMapLayer;
  EnvRect: TFRect;
  NXNY: TPoint;
  Labels: TK_RArray;
  UDActionComp: TN_UDAction;
  SL: TStringList;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
  begin
    //***** Get Params
    MLName := '';

    DataRoot   := CAUDBase1;   // Data Root (with 'CoordsObjects" or 'CObjects' child)
    MapRoot    := CAUDBase2;   // Map Root (where to create MapLayer for viewing)
    DstName    := CAStr1;      // Name of Resulting UDPoints and MapLayer

    Str := CAParStr1;
    NChanel    := N_ScanInteger( Str ); // CAIPoint1.X; // Protocol Chanel
    Accuracy   := N_ScanInteger( Str ); // CAIPoint1.Y + 5; // ULines Coords Accuracy
    GridStep   := N_ScanDPoint( Str ); // CADPoint1; // X,Y Step between Points
    GridOrigin := N_ScanDPoint( Str ); // CADPoint2; // X,Y Grid Origin (usually (0,0))
                             // CAColor1 - PenColor, CAColor2 - BrushColor, CADPoint2 - ShiftXY
    EnvRect    := CAFRect;   // All Points Envelode Rect
    Flags      := CAFlags1;
    // bits $00000F - Protocol bits (0 - nothing, 1 - summary)
    // bits $0000F0 - Sub Action Flags1, depend upon Main Action
    // bits $000F00 - Main Action To Perform (SrcULines remains the same, DstUDPoints changes):
    // bits $00F000 - Sub Action Flags2, depend upon Main Action
    //
    // bits $000F00 - Main Action To Perform:
    //       =$0100 - Add Grid Lines,
    //                bit  $0000010 : =0 - Clear DstUDPoints
    //                                =1 - Add to DstUDPoints
    //                bit  $0000020 : =1 - Create Points MapLayer
    //                bit  $0000040 : =1 - Create LabelsС MapLayer with Point Coords (CAStr2 - format)
    //                bit  $0000080 : =1 - Create LabelslI MapLayer with Point Inds
    //       =$0200 - Not Yet
    //                   ...
    //       =$0900 - Not Yet

    case Flags and $0F00 of // Action specific initial settings

      $0100: begin
               MsgStr := 'Add Grid Nodes';
               MLName := 'ML' + DstName;
             end;

      $0200: begin
               MsgStr := 'Not Yet';
             end;

      $0300: begin
               MsgStr := 'Not Yet';
             end;

      $0400: begin
               MsgStr := 'Not Yet';
             end;

      $0500: begin
               MsgStr := 'Not Yet';
             end;

      $0600: begin
               MsgStr := 'Not Yet';
             end;

      $0700: begin
               MsgStr := 'Not Yet';
             end;

      $0800: begin
               MsgStr := 'Not Yet';
             end;

      $0900: begin
               MsgStr := 'Not Yet';
             end;

    end; //  case Flags and $0F00 of // Action specific initial settings

    CObjectsRoot := DataRoot.DirChildByObjName( 'CObjects' );
    if CObjectsRoot = nil then
    begin
      CObjectsRoot := DataRoot.DirChildByObjName( 'CoordsObjects' );
      if CObjectsRoot = nil then
      begin
        N_CurShowStr( 'No Coords Objects' );
        Exit;
      end;
    end;

    UObj := CObjectsRoot.DirChildByObjName( DstName );
    if (UObj <> nil) and not (UObj is TN_UDPoints) then
    begin
      N_CurShowStr( 'Bad ' + DstName );
      Exit;
    end;
    DstUDPoints := TN_UDPoints(UObj);

    if (DstName <> '') and (DstUDPoints = nil) then // Create new DstUDPoints
    begin
      DstUDPoints := TN_UDPoints.Create();
      DstUDPoints.WAccuracy := Accuracy;
      N_AddUChild( CObjectsRoot, DstUDPoints, DstName );
    end;

    if (Flags and $0020) <> 0 then // Create Points MapLayer
    begin
      MLName := 'ML' + DstName + '(Points)';

      MapLayer := TN_UDMapLayer(MapRoot.DirChildByObjName( MLName ));
      if MapLayer = nil then
      begin
        MapLayer := TN_UDMapLayer(K_CreateUDByRTypeName( 'TN_RMapLayer', 1, N_UDMapLayerCI ));
        N_AddUChild( MapRoot, MapLayer, MLName );
      end;

      with MapLayer.InitMLParams( mltPoints1 )^ do
      begin
        MLPenColor   := CAColor1;
        MLPenWidth   := 1;
        MLBrushColor := CAColor2;
        K_SetUDRefField( TN_UDBase(MLCObj), DstUDPoints );
      end;
    end; // if (Flags and $0020) <> 0 then // Create Points MapLayer

    SL := TStringList.Create;

    if (Flags and $0F) > 0 then // Add Protocol Header and begin message
    begin
      SL.Add( '' );
      SL.Add( '      ' + MsgStr );
      N_CurShowStr( MsgStr );
    end; // if (Flags and $0F) > 0 then // Add Protocol Header and begin message


    //*********************  Action Main Code  ********************

    if (Flags and $0F00) = $0100 then //********************* Add Grid Points
    begin
      if (Flags and $0010) = 0 then // Clear DstUDPoints
        DstUDPoints.InitItems( 100, 100 );

      DstUDPoints.AddGridNodes( EnvRect, GridOrigin, GridStep, @NXNY );
      DstUDPoints.CalcEnvRects();

      if (Flags and $00C0) <> 0 then // Create Labels MapLayer with Points Coords or Indexes
      begin
        if (Flags and $0040) <> 0 then // Labels with Points Coords
          MLName := 'ML' + DstName + '(LabelsC)'
        else //************************** Labels with Indexes
          MLName := 'ML' + DstName + '(LabelsI)';

        MapLayer := TN_UDMapLayer(MapRoot.DirChildByObjName( MLName ));
        if MapLayer = nil then
        begin
          MapLayer := TN_UDMapLayer(K_CreateUDByRTypeName( 'TN_RMapLayer', 1, N_UDMapLayerCI ));
          N_AddUChild( MapRoot, MapLayer, MLName );
        end;

        //***** Create Labels RArray with Points Coords or Indexes

        Labels := K_RCreateByTypeCode( Ord(nptString), NXNY.X*NXNY.Y );

        for ix := 0 to NXNY.X-1 do
        for iy := 0 to NXNY.Y-1 do
        begin
          ind := ix + iy*NXNY.X;

          if (Flags and $0040) <> 0 then // Labels with Points Coords
          begin
            Fmt := CAStr2;
            if Fmt = '' then Fmt := '%.1f, %.1f';

            with DstUDPoints.CCoords[ind] do
              PString(Labels.P(ind))^ := Format( Fmt, [X,Y] );

          end else //********************** Labels with Indexes
            PString(Labels.P(ind))^ := Format( '%d,%d', [ix,iy] );

        end; // for iy, ix

        with MapLayer.InitMLParams( mltHorLabels )^ do // Set Maplayer fields
        begin
          MLTextColor := CAColor1;
          MLHotPoint := N_ZFPoint;
          MLShiftXY  := FPoint( 2, 2 );
          K_SetUDRefField( TN_UDBase(MLCObj), DstUDPoints );
          K_SetVArrayField( MLVArray1, Labels );
          K_SetVArrayField( MLVAux1, N_CreateRArrayNFont( 9, 'Verdana' ) );
        end; // with MapLayer.InitMLParams( mltHorLabels )^ do // Set Maplayer fields

      end; // if (Flags and $00C0) <> 0 then // Create Labels MapLayer

    end // ***** $0100 Add Grid Lines

    else if (Flags and $0F00) = $0200 then //************** Not yet
    begin
    end //***** $0200 Not yet

    else if (Flags and $0F00) = $0300 then //************** Not yet
    begin
    end //***** Not yet

    else if (Flags and $0F00) = $0400 then //************** Not yet
    begin
    end //***** Not yet

    else if (Flags and $0F00) = $0500 then //************** Not yet
    begin
    end //***** Not yet

    else if (Flags and $0F00) = $0600 then //************** Not yet
    begin
    end //***** Not yet

    else if (Flags and $0F00) = $0700 then //************** Not yet
    begin
    end //***** Not yet

    else if (Flags and $0F00) = $0800 then //************** Not yet
    begin
    end //***** Not yet

    else if (Flags and $0F00) = $0900 then //************** Not yet
    begin
    end; //***** Not yet

    //*********************  End of Action Main Code  ********************


    if (Flags and $0F) > 0 then // Add To Protocol
    begin
      if DstUDPoints <> nil then N_AddStr( NChanel, '    Resulting CObj is ' + DstName );
      if SL.Count > 0 then N_AddStr( NChanel, SL.Text );
    end; // if (Flags and $0F) > 0 then // Add To Protocol

  end; // with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
end; //*** end of procedure N_ActCreateUDPoints


//******************************************************* N_ActCreateULines ***
// Create ULines in several modes:
// - Create GridLines (Grid Segments, Hor or Vert Lines)
//
// (for using in TN_UDAction under Action Name "CreateULines")
//
procedure N_ActCreateULines( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  Flags, NChanel, DstCoordsType, Accuracy: integer;
  Str, DstName, MLName, MsgStr: string;
  GridStep, GridOrigin: TDPoint;
  DataRoot, CObjectsRoot, MapRoot, UObj: TN_UDBase;
  DstULines: TN_ULines;
  Maplayer: TN_UDMapLayer;
  EnvRect: TFRect;
  UDActionComp: TN_UDAction;
  SL: TStringList;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
  begin
    //***** Get Params
    MLName := '';

    DataRoot   := CAUDBase1;   // Data Root (with 'CoordsObjects" or 'CObjects' child)
    MapRoot    := CAUDBase2;   // Map Root (where to create MapLayer for viewing)
    DstName    := CAStr1;      // Name of Resulting ULines and MapLayer

    Str := CAParStr1;
    NChanel    := N_ScanInteger( Str ); // CAIPoint1.X; // Protocol Chanel
    Accuracy   := N_ScanInteger( Str ); // CAIPoint1.Y + 5; // ULines Coords Accuracy
    GridStep   := N_ScanDPoint( Str ); // CADPoint1; // X,Y Step between Points
    GridOrigin := N_ScanDPoint( Str ); // CADPoint2; // X,Y Grid Origin (usually (0,0))

    EnvRect    := CAFRect;   // All Lines Envelode Rect

    Flags      := CAFlags1;
    // bits $00000F - Protocol bits (0 - nothing, 1 - summary)
    // bits $0000F0 - Sub Action Flags1, depend upon Main Action
    // bits $000F00 - Main Action To Perform (SrcULines remains the same, DstULines changes):
    // bits $00F000 - Sub Action Flags2, depend upon Main Action
    //
    // bits $000F00 - Main Action To Perform:
    //       =$0100 - Add Grid Lines,
    //                bit  $0000010 : =0 - Clear DstULines
    //                                =1 - Add to DstULines
    //                bit  $0000020 : =0 - Float  Coords (if New DstULine)
    //                                =1 - Double Coords (if New DstULine)
    //                bits $000F000 : =0 - not used
    //                                =1 - Grid Segments (with CAFRect Width or Height length)
    //                                =2 - Grid Horizontal Lines
    //                                =3 - Grid Vertical Lines
    //       =$0200 - Not Yet
    //                   ...
    //       =$0900 - Not Yet

    case Flags and $0F00 of // Action specific initial settings

      $0100: begin
               MsgStr := 'Add Grid Lines';
               MLName := 'ML' + DstName;
             end;

      $0200: begin
               MsgStr := 'Not Yet';
             end;

      $0300: begin
               MsgStr := 'Not Yet';
             end;

      $0400: begin
               MsgStr := 'Not Yet';
             end;

      $0500: begin
               MsgStr := 'Not Yet';
             end;

      $0600: begin
               MsgStr := 'Not Yet';
             end;

      $0700: begin
               MsgStr := 'Not Yet';
             end;

      $0800: begin
               MsgStr := 'Not Yet';
             end;

      $0900: begin
               MsgStr := 'Not Yet';
             end;

    end; //  case Flags and $0F00 of // Action specific initial settings

    CObjectsRoot := DataRoot.DirChildByObjName( 'CObjects' );
    if CObjectsRoot = nil then
    begin
      CObjectsRoot := DataRoot.DirChildByObjName( 'CoordsObjects' );
      if CObjectsRoot = nil then
      begin
        N_CurShowStr( 'No Coords Objects' );
        Exit;
      end;
    end;

    UObj := CObjectsRoot.DirChildByObjName( DstName );
    if (UObj <> nil) and not (UObj is TN_ULines) then
    begin
      N_CurShowStr( 'Bad ' + DstName );
      Exit;
    end;
    DstULines := TN_ULines(UObj);
    if DstULines <> nil then
      DstCoordsType := DstULines.WLCType
    else
    begin
      if (Flags and $020) <> 0 then
        DstCoordsType := N_DoubleCoords
      else
        DstCoordsType := N_FloatCoords;
    end;

    if (DstName <> '') and (DstULines = nil) then // Create new DstULines
    begin
      DstULines := TN_ULines.Create1( DstCoordsType );
      DstULines.WAccuracy := Accuracy;
      N_AddUChild( CObjectsRoot, DstULines, DstName );
    end;

    if MLName <> '' then // Map Layer should be created
    begin

      MapLayer := TN_UDMapLayer(MapRoot.DirChildByObjName( MLName ));
      if MapLayer = nil then
      begin
        MapLayer := TN_UDMapLayer(K_CreateUDByRTypeName( 'TN_RMapLayer', 1, N_UDMapLayerCI ));
        N_AddUChild( MapRoot, MapLayer, MLName );
      end;

      with MapLayer.InitMLParams( mltLines1 )^ do
      begin
        MLPenColor   := CAColor1;
        MLPenWidth   := CAIRect.Left+1;
        MLBrushColor := N_EmptyColor;
        K_SetUDRefField( TN_UDBase(MLCObj), DstULines ); // later may be changed
      end;

    end; // if MLName <> '' then // Map Layer should be created

    SL := TStringList.Create;

    if (Flags and $0F) > 0 then // Add Protocol Header and begin message
    begin
      SL.Add( '' );
      SL.Add( '      ' + MsgStr );
      N_CurShowStr( MsgStr );
    end; // if (Flags and $0F) > 0 then // Add Protocol Header and begin message


    //*********************  Action Main Code  ********************

    if (Flags and $0F00) = $0100 then //********************* Add Grid Lines
    begin
      if (Flags and $0010) = 0 then // Clear DstULines
        DstULines.InitItems( 20 );

      case (Flags and $0F000) of // Grid Lines Type
        $01000: DstULines.AddGridSegments( EnvRect, GridOrigin, GridStep );
        $02000: DstULines.AddHorLines( EnvRect, GridOrigin, GridStep );
        $03000: DstULines.AddVertLines( EnvRect, GridOrigin, GridStep );
      end; // case (Flags and $0F000) of // Grid Lines Type

      DstULines.CalcEnvRects();
    end // ***** $0100 Add Grid Lines

    else if (Flags and $0F00) = $0200 then //************** Not yet
    begin
    end //***** $0200 Not yet

    else if (Flags and $0F00) = $0300 then //************** Not yet
    begin
    end //***** Not yet

    else if (Flags and $0F00) = $0400 then //************** Not yet
    begin
    end //***** Not yet

    else if (Flags and $0F00) = $0500 then //************** Not yet
    begin
    end //***** Not yet

    else if (Flags and $0F00) = $0600 then //************** Not yet
    begin
    end //***** Not yet

    else if (Flags and $0F00) = $0700 then //************** Not yet
    begin
    end //***** Not yet

    else if (Flags and $0F00) = $0800 then //************** Not yet
    begin
    end //***** Not yet

    else if (Flags and $0F00) = $0900 then //************** Not yet
    begin
    end; //***** Not yet

    //*********************  End of Action Main Code  ********************


    if (Flags and $0F) > 0 then // Add To Protocol
    begin
      if DstULines <> nil then N_AddStr( NChanel, '    Resulting CObj is ' + DstName );
      if SL.Count > 0 then N_AddStr( NChanel, SL.Text );
    end; // if (Flags and $0F) > 0 then // Add To Protocol

  end; // with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
end; //*** end of procedure N_ActCreateULines

//******************************************************** N_ActCObjAction1 ***
// Several Actions (see comments inside) Set #1
//
// Action acts with two (Src and Dst) CObj
// Each CObj is TN_UCObjLayer or descendant
// or is Map (MapLayers and MapLayers Parents)
// CObj could by of any TN_UCObjLayer descendant type, MapLayer or MapLayer Parent
// (Actions with ULines only are in ULinesAction 1,2)
//
// (for using in TN_UDAction under Action Name "CObjAction1")
//
procedure N_ActCObjAction1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, Flags, OuterCode, NChanel, CDim1, Code1, CDim2, Code2: integer;
  NumCurChanged, NumAllChanged, GeoProjFlags: integer;
  Str, SrcName, DstName, MsgStr, MLName: string;
  DataRoot, CObjectsRoot, MapRoot, DstRoot, TmpUObj, CurCObj: TN_UDBase;
  MapLayer: TN_UDMapLayer;
  UConts: TN_UContours;
  AffCoefs6: TN_AffCoefs6;
  GeoProjPar: TN_GeoProjPar;
  SrcCObj, DstCObj: TN_UDBase;
  UDActionComp: TN_UDAction;
  SavedCursor: TCursor;
  SL: TStringList;
begin
  MapLayer := nil; // to avoid warning
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
  begin
    //***** Get Params
    MLName := '';
    OuterCode := -1;

    //***** Used Params:

    DataRoot  := CAUDBase1; // Data and CoordsObjects Root
    MapRoot   := CAUDBase2; // Map Root
    DstRoot   := CAUDBase3; // Destination Root (for Copy Map Action)
    SrcName   := CAStr1;
    DstName   := CAStr2;

    Str := CAParStr1;
    NChanel   := N_ScanInteger( Str );
    CDim1     := N_ScanInteger( Str );
    CDim2     := N_ScanInteger( Str );
    GeoProjFlags := N_ScanInteger( Str );

    Flags := CAFlags1;
    // bits $00000F - Protocol bits (0 - nothing, 1 - summary)
    // bits $0000F0 - Sub Action Flags, depend upon Main Action
    // bits $000F00 - Main Action To Perform (SrcULines remains the same, DstULines changes):
    //                =0 - nothing
    //                =1 - Move Codes from one CDim to another
    //                =2 - XOR given Code1(in given CDim) in All Items,
    //                     posess another given Code2
    //                =3 - Assemble Contours (Src - ULines, Dst - UConts)
    //                =4 - Copy Map (copy to given DstRoot DataRoot and MapRoot SubTries)
    //                =5 - AffConv Map (all CObjects in DstRoot.DataRoot.CObjectsRoot)
    //                =6 - GeoProj Map (all CObjects in DstRoot.DataRoot.CObjectsRoot)
    //                =7 - not yet

    case Flags and $0F00 of // Action specific initial settings
      $0000: begin
               MsgStr := 'Empty';
             end;

      $0100: begin
               MsgStr := 'Move CObj Codes';
             end;

      $0200: begin
               MsgStr := 'XOR CObj Codes';
             end;

      $0300: begin
               MsgStr := 'Assemble Contours';
               MLName := 'ML' + DstName;
             end;

      $0400: begin
               MsgStr := 'Copy Map';
             end;

      $0500: begin
               MsgStr := 'AffConv Map';
             end;

      $0600: begin
               MsgStr := 'GeoProj Map';
             end;

      $0700: begin
               MsgStr := 'not yet';
             end;

    end; // case Flags and $0F00 of

    CObjectsRoot := DataRoot.DirChildByObjName( 'CObjects' );
    if CObjectsRoot = nil then // 'CObjects' dir is absent, try 'CoordsObjects'
    begin
      CObjectsRoot := DataRoot.DirChildByObjName( 'CoordsObjects' );
      if CObjectsRoot = nil then  // 'CoordsObjects' dir is also absent, use DataRoot
        CObjectsRoot := DataRoot;
    end; // if CObjectsRoot = nil then // 'CObjects' dir is absent, try 'CoordsObjects'

    if (MLName <> '') and (MapRoot <> nil) then // MapLayer Name is given, locate or create MapLayer component in MapRoot
    begin
      MapLayer := TN_UDMapLayer(MapRoot.DirChildByObjName( MLName ));
      if MapLayer = nil then // MapLayer Component is absent, create it
      begin
        MapLayer := TN_UDMapLayer(K_CreateUDByRTypeName( 'TN_RMapLayer', 1, N_UDMapLayerCI ));
        N_AddUChild( MapRoot, MapLayer, MLName );
      end;
    end; // if MLName <> '' then // MapLayer Name is given, locate or create MapLayer component

    SrcCObj := CObjectsRoot.DirChildByObjName( SrcName );
    DstCObj := CObjectsRoot.DirChildByObjName( DstName );

    if ((Flags and $0F00) = $0100) or
       ((Flags and $0F00) = $0200) then // Create DstCObj of same type as SrcCObj
    begin
      if not (SrcCObj is TN_UCObjLayer) then
      begin
        N_CurShowStr( 'No SrcCObj' );
        Exit;
      end;

      DstCObj := N_ClassRefArray[SrcCObj.CI()].Create;
      N_AddUChild( CObjectsRoot, DstCObj, DstName );
      DstCObj.CopyFields( SrcCObj );
    end; // if ... then // Create DstCObj of same type as SrcCObj

    SL := TStringList.Create;

    if (Flags and $0F) > 0 then // Add Protocol Header and begin message
    begin
      SL.Add( '' );
      SL.Add( '      ' + MsgStr );
      if SrcCObj <> nil then SL.Add( '  Src CObj is ' + K_GetPathToUObj( SrcCObj ) );
      if DstCObj <> nil then SL.Add( '  Dst CObj is ' + K_GetPathToUObj( DstCObj ) );

      N_CurShowStr( MsgStr + '...' );
    end; // if (Flags and $0F) > 0 then // Add Protocol Header and begin message

    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;
//    if not (cbfSkipResponse in TN_UDCompBase(GCRootComp).PDP()^.CCompBase.CBFlags1) then


    //*********************  Action Main Code  ********************


    if (Flags and $0F00) = $0100 then //***** Move CObj Codes
    begin
      N_MoveCObjCodes( TN_UCObjLayer(DstCObj),  CDim1, CDim2, SL, Flags and $0F );
    end //***** $0100 Move CObj Codes


    else if (Flags and $0F00) = $0200 then //***** XOR CObj Codes
    begin
      NumAllChanged := 0;

      for i := 0 to CAStrArray.AHigh() do // along all Codes pairs
      begin            // CAStrArray contains pairs of Codes in CDim1: Code1 Code2
                       // Code1 - "enveloping" polygon code
                       // Code2 - "internal" polygon code, to substract from Code1 polygon
        Str := PString(CAStrArray.P(i))^;
        Code1 := N_ScanInteger( Str );
        Code2 := N_ScanInteger( Str );
        NumCurChanged := N_XORCObjCodes( TN_UCObjLayer(DstCObj),
                                     CDim1, Code2, Code1, SL, Flags and $0F );
        Inc( NumAllChanged, NumCurChanged );
      end; // for i := 0 to CAStrArray.AHigh() do // along all Codes pairs

      Str := Format( '%d Items XORed', [NumAllChanged] );
      SL.Add( '      ' + Str );
      N_CurShowStr( Str );
    end //***** $0200 XOR CObj Codes


    else if (Flags and $0F00) = $0300 then //***** Assemble Contours
    begin
      UConts := TN_UContours(CObjectsRoot.DirChildByObjName( DstName ));

      if UConts = nil then
      begin
        UConts := TN_UContours.Create();
        N_AddUChild( CObjectsRoot, UConts, DstName );
      end;

      if not (SrcCObj is TN_ULines) then
      begin
        N_CurShowStr( 'SrcCObj is not ULines' );
        Exit;
      end;

      N_UDlinesToUDContours2( OuterCode, CDim1, TN_ULines(SrcCObj), UConts );

      with UConts do
      begin
        SetSelfULines( TN_ULines(SrcCObj) );
        CalcEnvRects();
        WComment := 'Contours from ' + SrcCObj.ObjName;
        WCDimNames := Copy( TN_ULines(SrcCObj).WCDimNames );
        WItemsCSName := TN_ULines(SrcCObj).WItemsCSName;
      end; // with UConts do

      if MapLayer <> nil then
      with MapLayer.InitMLParams( mltConts1 )^ do
      begin
        MLPenColor   := CAColor1;
        MLPenWidth   := CAIRect.Left;
        MLBrushColor := CAColor2;
        MLColorMode  := $022; // fill Conts by different colors
        K_SetUDRefField( TN_UDBase(MLCObj), UConts );
      end; // with MapLayer.InitMLParams( mltConts1 )^ do

      Str := IntToStr( UConts.WNumItems ) + ' Contours Assembled';
      SL.Add( Str );
      N_CurShowStr( Str );

    end //***** $0300 Assemble Contours


    else if (Flags and $0F00) = $0400 then //***** Copy Map
    begin
      if DstRoot = nil then
      begin
        N_CurShowStr( 'No DstRoot' );
        Exit;
      end;

      //***** Copy DataRoot SubTree to DstRoot

      Str := DataRoot.ObjName;
      TmpUObj := DstRoot.DirChildByObjName( Str );
      if TmpUObj <> nil then // Delete existed DataRoot in DstRoot (if any)
        DstRoot.DeleteOneChild( TmpUObj );

      TmpUObj := N_CreateSubTreeClone( DataRoot );
      DstRoot.AddOneChildV( TmpUObj );

      CObjectsRoot := TmpUObj.DirChildByObjName( 'CObjects' ); // New CObjects Root
      if CObjectsRoot = nil then
      begin
        N_CurShowStr( 'No CObjectsRoot' );
        Exit;
      end;

      //***** Copy MapRoot SubTree to DstRoot and Update MLCObj

      Str := MapRoot.ObjName;
      TmpUObj := DstRoot.DirChildByObjName( Str );
      if TmpUObj <> nil then // Delete existed MapRoot in DstRoot (if any)
        DstRoot.DeleteOneChild( TmpUObj );

      TmpUObj := N_CreateSubTreeClone( MapRoot );
      DstRoot.AddOneChildV( TmpUObj );

      MapRoot := TmpUObj; // New created MapRoot in DstRoot

      for i := 0 to MapRoot.DirHigh() do // along all MapLayers
      begin
        TmpUObj := MapRoot.DirChild( i );
        if not (TmpUObj is TN_UDMapLayer) then Continue; // skip if not Map Layer

        with TN_UDMapLayer(TmpUObj).PISP()^ do
        begin
          if MLCObj = nil then Continue;
          Str := MLCObj.ObjName;
          CurCObj := CObjectsRoot.DirChildByObjName( Str );
          K_SetUDRefField( TN_UDBase(MLCObj), CurCObj ); // Update MLCObj
        end; // with TN_UDMapLayer(TmpUObj) do

      end; // for i := 0 to MapRoot.DirHigh() do // along all MapLayers

      Str := '  Data,Map SubTrees copied to ' +  DstRoot.ObjName;
      SL.Add( Str );
      N_CurShowStr( Str );
    end //***** Copy Map


    else if (Flags and $0F00) = $0500 then //***** AffConv Map (all CObjects in DstRoot.CObjectsRoot)
    begin
      TmpUObj := DstRoot.DirChildByObjName( DataRoot.ObjName ); // New Data Root
      CObjectsRoot := TmpUObj.DirChildByObjName( 'CObjects' ); // New CObjects Root

      if CObjectsRoot = nil then
      begin
        N_CurShowStr( 'No CObjectsRoot' );
        Exit;
      end;

      Str := CAStr3; // given Coefs as string (CXX CXY SX CYX CYY SY)
      if Str = '' then Str := N_MEGlobObj.MEAffCoefsStr;
      if Str = '' then // Coefs are not given
      begin
        N_CurShowStr( 'No Aff Coefs' );
        Exit;
      end;

      MsgStr := '  Map AffConverted';
      SL.Add( MsgStr + ' Coefs: ' + Str );

      AffCoefs6 := N_ScanAffCoefs6( Str );
      if AffCoefs6.CXX = N_NotADouble then
      begin
        N_CurShowStr( 'Bad Aff Coefs' );
        Exit;
      end;

      for i := 0 to CObjectsRoot.DirHigh() do // along all CObjects in CObjectsRoot
      begin
        CurCObj := CObjectsRoot.DirChild( i );
        if not (CurCObj is TN_UCObjLayer) then Continue;
        if CurCObj is TN_UContours then Continue; // skip Contours

        TN_UCObjLayer(CurCObj).AffConvSelf( AffCoefs6 );
      end; // for i := 0 to CObjectsRoot.DirHigh() do // along all CObjects in CObjectsRoot

      N_CurShowStr( MsgStr );
    end //***** $0500 AffConv Map


    else if (Flags and $0F00) = $0600 then //***** GeoProj Map (all CObjects in DstRoot.CObjectsRoot)
    begin
      // DataRoot (CAUDBase1) is used only as DataRoot.ObjName
      TmpUObj := DstRoot.DirChildByObjName( DataRoot.ObjName ); // New Data Root
      CObjectsRoot := TmpUObj.DirChildByObjName( 'CObjects' );  // New CObjects Root

      if CObjectsRoot = nil then
      begin
        N_CurShowStr( 'No CObjectsRoot' );
        Exit;
      end;

      //*** GeoProj Coefs as string: Scale, BS,B1,B2,BN, LW,L0,LE, GPType

      Str := CAStr3; // given GeoProj Coefs as string
      if Str = '' then // Coefs are not given
      begin
        N_CurShowStr( 'No GeoProj Coefs' );
        Exit;
      end;

      MsgStr := '  Map GeoProjected';
      SL.Add( MsgStr + ' Coefs: ' + Str );

      GeoProjPar := TN_GeoProjPar.Create;

      with GeoProjPar do
      begin
        Scale := N_ScanDouble( Str );

        BS := N_ScanDouble( Str ); // ( 0 < BS < B1 < B2 < BN )
        B1 := N_ScanDouble( Str );
        B2 := N_ScanDouble( Str );
        BN := N_ScanDouble( Str );

        LW := N_ScanDouble( Str ); // (LW<L0<LE)
        L0 := N_ScanDouble( Str );
        LE := N_ScanDouble( Str );

        GPType := N_ScanInteger( Str ); // 1, 2, 3
    // =1 - normal conical 1 (нормальная коническая равнопромежуточная)
    // =2 - normal conical 2 (нормальная коническая равноугольная)
    // =3 - normal cilindrycal Mercator (нормальная цилиндрическая Меркатора)

        if GPType = N_NotAnInteger then
        begin
          N_CurShowStr( 'Bad GeoProj Par' );
          Exit;
        end;

        Alfa := N_NotADouble; // set "coefs are not calculated flag"
      end; // with GeoProjPar do

      for i := 0 to CObjectsRoot.DirHigh() do // along all CObjects in CObjectsRoot
      begin
        CurCObj := CObjectsRoot.DirChild( i );
        if not (CurCObj is TN_UCObjLayer) then Continue;
        if CurCObj is TN_UContours then Continue; // skip Contours

        if i = 2 then
          N_i := 1;
        TN_UCObjLayer(CurCObj).GeoProjSelf( GeoProjPar, GeoProjFlags );
      end; // for i := 0 to CObjectsRoot.DirHigh() do // along all CObjects in CObjectsRoot

      N_CurShowStr( MsgStr );
    end //***** $0600 GeoProj Map


    else if (Flags and $0F00) = $0700 then //***** not yet
    begin

    end; //***** $0700 not yet

    Screen.Cursor := SavedCursor;

    if (Flags and $0F) > 0 then
    begin
      if SL.Count > 0 then N_AddStr( NChanel, SL.Text );
    end;

  end; // with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
end; //*** end of procedure N_ActCObjAction1

//******************************************************** N_ActCObjAction2 ***
// Several Actions (see comments inside) Set #2
//
// Action acts with two (Src and Dst) CObj
// Each CObj is TN_UCObjLayer or descendant
// or is Map (MapLayers and MapLayers Parents)
// CObj could by of any TN_UCObjLayer descendant type, MapLayer or MapLayer Parent
// (Actions with ULines only are in ULinesAction 1,2)
//
// (for using in TN_UDAction under Action Name "CObjAction2")
//
procedure N_ActCObjAction2( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  Flags: integer;
  DstCObjRoot: TN_UDBase; // SrcCObj2,
  UDActionComp: TN_UDAction;
  DstName, StrParams: string;
  SrcCObj1, DstCObj: TN_UCObjLayer;
  AffCoefs6: TN_AffCoefs6;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
  begin
    if CAUDBase1 <> nil then
      Assert( CAUDBase1 is TN_UCObjLayer, 'CAUDBase1 is not TN_UCObjLayer!' );

    //***** Used Params:
    SrcCObj1    := TN_UCObjLayer(CAUDBase1); // Source CObj1, may be nill if DstCObj exists
//                 CAUDBase2 can be used as DstCObj
    DstCObjRoot := CAUDBase3; // Dst CObj Parent
    DstName     := CAParStr1;
    StrParams   := CAParStr2;

    Flags := CAFlags1;
    // bits $00000F - Protocol bits (0 - nothing, 1 - summary)
    // bits $0000F0 - Sub Action Flags, depend upon Main Action
    //                =0 - copy SrcCObj to DstCObj before action
    //                =1 - init DstCObj before action
    // bits $000F00 - Main Action To Perform:
    //                =0 - copy SrcCObj to DstCObj
    //                =1 - AffConv6
    //                =2 - not yet

    if DstCObjRoot = nil then // DstCObjRoot is not given, use CAUDBase2 as DstCObj
    begin
      Assert( CAUDBase2 is TN_UCObjLayer, 'CAUDBase2 is not TN_UCObjLayer!' );
      DstCObj := TN_UCObjLayer( CAUDBase2 );
    end else // DstCObjRoot <> nil, try to find DstCObj by DstName or create it
    begin
      DstCObj := N_PrepSameCObj( SrcCObj1, DstCObjRoot, DstName );
    end;

    Assert( DstCObj <> nil, 'DstCObj is nil!' );


    if (Flags and $0F00) = $0100 then // AffConv6
    begin
      N_CalcAffCoefs6( StrParams, AffCoefs6 );

      if (Flags and $0F0) = $010 then // init DstCObj
        DstCObj.InitItems( 100 );

      DstCObj.AffConvSelf( AffCoefs6 );
    end; // if (Flags and $0F00) = $0100 then // AffConv6

  end; // with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
end; // procedure N_ActCObjAction2

//********************************************************* N_ActExportCObj ***
// Export Marked CObjects to file
// temporary export only Items EnvRects with Code and Code Name (Tab delimitated)
//
// (for using in TN_UDAction under Action Name "ExportCObj")
//
procedure N_ActExportCObj( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, j, CDimInd, ItemCode: integer;
  Str, CodeName, EnvRectStr: string;
  CurCObj: TN_UDBase;
  ResSL: TStringList;
begin
  with APParams^ do
  begin
    if N_ActiveVTreeFrame = nil then
    begin
      N_CurShowStr( 'No ActiveVTreeFrame!' );
      Exit;
    end;

    ResSL := TStringList.Create();

    for i := 0 to CAUDBaseArray.AHigh do // along given CObjects
    begin
      CurCObj := TN_PUDBase(CAUDBaseArray.P( i ))^;
      if not (CurCObj is TN_UCObjLayer) then Continue; // Skip all but CObjects

      Str := CAParStr1;
      CDimInd := N_ScanInteger( Str );
      ResSL.Add( Format( 'Envelope Rect and Code in CDimInd=%d of %s Items:',
                                               [CDimInd, CurCObj.ObjName] ) );
      ResSL.Add( ' Ind  Code    XMin     YMin       XMax     YMax    Name' );

      with TN_UCObjLayer(CurCObj) do
      begin
        WItemsCSObj := GetCS();
        N_ud := WItemsCSObj;
        N_i := WNumItems;
        CalcEnvRects();

        for j := 0 to WNumItems-1 do // along Items in CurMarked CObj
        begin
          ItemCode := GetItemFirstCode( j, CDimInd );
          CodeName := N_CSIntCodeName( ItemCode, WItemsCSObj );

          EnvRectStr := N_RectToStr( Items[j].EnvRect, '%8.5g'#$9'%8.5g '#$9'  %8.5g'#$9'%8.5g' );

          ResSL.Add( Format( '%3d'#$9'%5d'#$9' %s '#$9' %s',
                              [j,ItemCode,EnvRectStr,Codename] ) );

        end; // for j := 0 to WNumItems-1 do // along Items in CurMarked CObj

      end; // with TN_UCObjLayer(CurCObj) do

      ResSL.Add( '' );

    end; // for i := 0 to CAUDBaseArray.AHigh do // along given CObjects

    N_AddToTextFile( K_ExpandFileName(CAFName1), ResSL.Text );
    ResSL.Free;
  end; // with APParams^ do
end; // procedure N_ActExportCObj

//**************************************************** N_ActChangeCObjCodes ***
// Change CObjects codes
//
//     Parameters
// APParams - Pointer to UDAction Individual Dynamic Params
// AP1      - TN_UDAction object (not used),
// AP2      - not used
//
// Change CObjCodes of UDLines CObject, that is used by given UDContours CObject
// (for using in TN_UDAction under Action Name "ChangeCObjCodes")
//
// CAFlags1:
// bits $0000F - Operation Code:
//               =0 - nothing
//               =1 - Clear all Codes
//               =2 -  OR operation (add New Code)
//               =3 - XOR operation (XOR New Code)
// bit  $00010 - what is New Code (that should be ORed or XORed):
//               =0 - New Code is Countour's Code
//               =1 - New Code is given in CAIRect.Right
//
// CAParams1    - Contour's Codes to process (any number of ranges in N_ScanIntPairs format)
// CAUDBase1    - given UDContours CObject whose ULines should be changed
//
// CAIRect.Left   - Contours CDimInd
// CAIRect.Top    - Lines CDimInd
// CAIRect.Right  - given new Code
//
//
procedure N_ActChangeCObjCodes( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, j, k, NumRanges, ContsCDim, LinesCDim, ContCode, NewCode, FRInd: integer;
  NumRings, NumAllCodesInts, CDimOffset, CDimNumCodes, LineInd: integer;
  Str: string;
  CodeRanges, WrkAllCodes: TN_IArray;
  UConts: TN_UContours;
  ULines: TN_ULines;
begin
  with APParams^ do
  begin
    N_LCAdd( N_ActChanInd, 'Start ChangeCObjCodes Action' );

    UConts := nil;
    if CAUDBase1 is TN_UContours then UConts := TN_UContours(CAUDBase1);

    if UConts <> nil then
      N_LCAdd( N_ActChanInd, '  UContours=' + K_GetPathToUObj( UConts ) )
    else
    begin
      N_LCAdd( N_ActChanInd, '  UContours are not given!' );
      Exit;
    end;

    ULines := UConts.GetSelfULines();

    Str := CAParStr1;
    NumRanges := N_ScanIntPairs( Str, CodeRanges );

    ContsCDim := CAIRect.Left;
    LinesCDim := CAIRect.Top;
    NewCode   := CAIRect.Right;

    N_LCAdd( N_ActChanInd, Format( 'Flags=$%x, ContCodes=%s', [CAFlags1,CAParStr1] ) );
    N_LCAdd( N_ActChanInd, Format( 'ConCDim=%d, LinCDim=%d, NewCode=%d',
                                      [ContsCDim,LinesCDim,NewCode] ) );

    for i := 0 to UConts.WNumItems-1 do // along all Contours, i - Item index
    begin
      ContCode := UConts.GetItemFirstCode( i, ContsCDim );
      if not N_IsIntInRange( ContCode, NumRanges, CodeRanges ) then Continue; // Skip not needed Contour

      //***** Here: ContCode belongs to given Range and should be processed

      if (CAFlags1 and $010) = 0 then // Use ContCode instead of given NewCode
        NewCode := ContCode;

      //***** FRInd is First Ring Index in UConts.CRings array,
      //      NumRings - number of Rings in Contour (number od subsequent elems in CRings)

      UConts.GetItemInds( i, FRInd, NumRings );
      if NumRings = 0 then Continue; // Skip empty (with no Rings) contours
//      N_PCAdd( N_ActChanInd, Format( 'i=%d', [i] ) ); // debug

      for j := FRInd to FRInd+NumRings-1 do // along all Rings in i-th Contour
      begin

        //****** UConts.CRings[j].RLInd is first j-th Ring Line Index in UConts.LinesInds array
        //       UConts.CRings[j+1].RLInd is first (j+1)-th Ring Line Index (First Line for Next Ring)

        for k := UConts.CRings[j].RLInd to UConts.CRings[j+1].RLInd-1 do // along all Lines in j-th Ring
        begin
          LineInd := UConts.LinesInds[k]; // Border Line Index in ULines CObj for k-th ring alem

          //***** WrkAllCodes - int array, one code per element,
          //                    high byte is CDim Index, three low bytes are Code
          //      NumAllCodesInts - Nnmber of elements (CDim+Code) in WrkAllCodes

          ULines.GetItemAllCodes( LineInd, WrkAllCodes, NumAllCodesInts );

          if (CAFlags1 and $0F) = 1 then // Clear all Codes
          begin
            // Get CDimOffset and CDimNumCodes for given LinesCDim
            N_GetCDimCObjCodes( @WrkAllCodes[0], NumAllCodesInts, LinesCDim,
                                                     CDimOffset, CDimNumCodes );

            // Replace founded CDimOffset and CDimNumCodes by nothing
            N_ReplaceArrayElems( WrkAllCodes, CDimOffset, CDimNumCodes,
                                                      NumAllCodesInts, nil, 0 );
            //*** N_ReplaceArrayElems does not change NumAllCodesInts on output,
            //    it should be calculated manually
            NumAllCodesInts := NumAllCodesInts - CDimNumCodes;
          end else if (CAFlags1 and $0F) = 2 then // OR operation (add New Code)
          begin
            N_AddOrderedInts( WrkAllCodes, NumAllCodesInts, @NewCode, 1, 0 );
          end else if (CAFlags1 and $0F) = 3 then // XOR operation (XOR New Code)
          begin
            N_AddOrderedInts( WrkAllCodes, NumAllCodesInts, @NewCode, 1, 1 );
          end;

          //*** Resulting WrkAllCodes and NumAllCodesInts are OK, save them to ULines

          ULines.SetItemAllCodes( LineInd, @WrkAllCodes[0], NumAllCodesInts );
        end; // for k := ... do // along all Lines in j-th Ring

      end; // for j := FRInd to FRInd+NumRings-1 do // along all Rings in i-th Contour

    end; // for i := 0 to UConts.WNumItems-1 do // along all Contours

  end; // with APParams^ do
end; // procedure N_ActChangeCObjCodes

//******************************************************* N_ActChangeMLUObj ***
// Change Marked MapLayer UObjects (MLCObj, MLDVecti, MLAuxi, MLVArrayi, MLVAuxi)
// (and Ulines child of UContours)
// to UObjects with same ObjNames in two given Dirs:
//    CAUDBase1 - new CObjects Root
//    CAUDBase2 - new Data UObjects Root (All other UObjects except CObj)
//    CAFlags1  - bit4($010) =0 - copy CObj content, =1 - use current content
//                bit5($020) =0 - copy UObj content, =1 - use current content
//
// (for using in TN_UDAction under Action Name "ChangeMLUObj")
//
procedure N_ActChangeMLUObj( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, j, NumChanged: integer;
  CurName: string;
  IsCObj: boolean;
  PMLUObjects: TN_PUDArray;
  CurMarked, SrcUObj, DstUObj, CurDstDir, PrevConts: TN_UDBase;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning
  PMLUObjects := nil; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin

    if N_ActiveVTreeFrame = nil then
    begin
      N_CurShowStr( 'No ActiveVTreeFrame!' );
      Exit;
    end;

    NumChanged := 0;

    with N_ActiveVTreeFrame.VTree.MarkedVNodesList do
    for i := 0 to Count-1 do // along marked Map Layers
    begin
      CurMarked := TN_VNode(Items[i]).VNUDObj;
      if not (CurMarked is TN_UDMapLayer) then Continue; // Skip not Map Layers

      PMLUObjects := TN_UDMapLayer(CurMarked).CreateAPUDRefs();
      PrevConts := nil;

      for j := 0 to High(PMLUObjects) do // along CurMarked UDBase Fields
      begin
        if (j = 1) and (PrevConts <> nil) then
          SrcUObj := TN_UDBase(PMLUObjects[j]) // UDBase itself, not pointer to it (may be nil)
        else
          SrcUObj := PMLUObjects[j]^;

        if SrcUObj = nil then // can be only if (j = 1) and (PrevConts <> nil)
        begin
          PrevConts := nil;
          Continue; // skip zero UCont's child
        end;

        CurName := SrcUObj.ObjName;

        IsCObj := SrcUObj is TN_UCObjLayer;

        if IsCObj then CurDstDir := CAUDBase1
                  else CurDstDir := CAUDBase2;

        if CurDstDir = nil then Continue; // a precaution
        DstUObj := CurDstDir.DirChildByObjName( CurName );
//        DstUObj := N_GetUObjByName( CurDstDir, CurName );

        if DstUObj = nil then // no appropriate UObj in CurDstDir, create it
        begin
          DstUObj := SrcUObj.Clone();
          CurDstDir.AddOneChildV( DstUObj );
        end else //*********** DstUObj exists, update it if needed
        begin
          if DstUObj.CI() <> SrcUObj.CI() then Continue; // a precaution

          if IsCObj then // SrcUObj and DstUObj are of TN_UCObjLayer type
          begin          // use bit $010
            if (CAFlags1 and $010) = 0 then
              DstUObj.CopyFields( SrcUObj );
          end else //****** SrcUObj and DstUObj are NOT of TN_UCObjLayer type
          begin    //       use bit $020
            if (CAFlags1 and $020) = 0 then
              DstUObj.CopyFields( SrcUObj );
          end;
        end; // else // DstUObj exists, update it if needed

        //***** DstUObj is OK, set it

        if (j = 0) and (DstUObj is TN_UContours) then
          PrevConts := DstUObj;

        if (j = 1) and (PrevConts <> nil) then
        begin
          PrevConts.PutDirChildSafe( N_CObjLinesChildInd, DstUObj );
          PrevConts.RebuildVNodes();
          PrevConts := nil;
        end else
          K_SetUDRefField( PMLUObjects[j]^, DstUObj );

        Inc( NumChanged );
      end; // for j := 0 to High(PMLUObjects) do // along CurMarked UDBase Fields

      PMLUObjects := nil;
    end; // for i := 0 to Count-1 do, with ... do // along marked Map Layers
  end; // with APParams^, UDActionComp.NGCont do

  N_CurShowStr( IntToStr(NumChanged) + ' UObjects changed' );
end; //*** end of procedure N_ActChangeMLUObj

//****************************************************** N_ActFillVisVector ***
// Fill given Visibility UDVector by given CSProjection
//
//     Parameters
// APParams - Pointer to UDAction Individual Dynamic Params
// AP1      - TN_UDAction object (not used),
// AP2      - not used
//
// Set "Is Visible" (<>0) flag if appropriate CObj UDLines element has CS codes
// that are projected to different Dst element (make visible only lines between
// different regions subsets, given in CSProjection. e.g. Federal Okruga borders)
// (for using in TN_UDAction under Action Name "FillVisVector")
//
// CAFlags1:  - not used:
// CAUDBase1  - given UDLines CObject
// CAUDBase2  - given CSProjection, to check UDLines Items codes
// CAUDBase3  - given Visibility UDVector or UDRArray of bytes to fill (is parallel to UDLines Items)
// CAParStr1  - UDLines CDimInd (to get Item codes) (one integer)
//
procedure N_ActFillVisVector( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, IRes, LinesCDim, CDimOffset, CDimNumCodes, NumAllCodesInts: integer;
  Str: string;
  PVisByte: TN_PByte;
  WrkAllCodes: TN_IArray;
  ULines: TN_ULines;
  VisVector: TK_UDRArray; // UDRArray of bytes or TK_UDVector of bytes;
  DCSProj: TK_UDVector;
begin
  with APParams^ do
  begin
    N_LCAdd( N_ActChanInd, 'Start FillVisVector Action' );

    ULines := nil;
    if CAUDBase1 is TN_ULines then ULines := TN_ULines(CAUDBase1);

    if ULines <> nil then
      N_LCAdd( N_ActChanInd, '  ULines=' + K_GetPathToUObj( ULines ) )
    else
    begin
      N_LCAdd( N_ActChanInd, '  UDLines in CAUDBase1 are not given!' );
      Exit;
    end;

    DCSProj := nil;
    if CAUDBase2 is TK_UDVector then DCSProj := TK_UDVector(CAUDBase2);

    if DCSProj <> nil then
    begin
      if DCSProj.IsDCSProjection() then
        N_LCAdd( N_ActChanInd, '  DCSProj=' + K_GetPathToUObj( DCSProj ) )
      else
        DCSProj := nil;
    end;

    if DCSProj = nil then
    begin
      N_LCAdd( N_ActChanInd, '  DCSProj in CAUDBase2 is not given!' );
      Exit;
    end;

    VisVector := nil;
    if CAUDBase3 is TK_UDRArray then VisVector := TK_UDRArray(CAUDBase3);

    if VisVector <> nil then
      N_LCAdd( N_ActChanInd, '  VisVector=' + K_GetPathToUObj( VisVector ) )
    else
    begin
      N_LCAdd( N_ActChanInd, '  VisVector in CAUDBase3 is not given!' );
      Exit;
    end;

    Str := CAParStr1;
    LinesCDim := N_ScanInteger( Str ); // UDLines CDimInd (to get Item codes) (one integer)

    N_LCAdd( N_ActChanInd, Format( 'Flags=$%x, CDimInd=%d', [CAFlags1,LinesCDim] ) );
    SetLength( WrkAllCodes, 2 );

    for i := 0 to ULines.WNumItems-1 do // along all ULines, i - Item index
    begin
      ULines.GetItemAllCodes( i, WrkAllCodes, NumAllCodesInts );
      N_GetCDimCObjCodes( @WrkAllCodes[0], NumAllCodesInts, LinesCDim,
                                                     CDimOffset, CDimNumCodes );
      N_LCAdd( N_ActChanInd, Format( 'i=%d nc=%d,  c1,c2=%d,%d',
               [i,CDimNumCodes,WrkAllCodes[CDimOffset],WrkAllCodes[CDimOffset+1]] ) );

      IRes := K_IfSameProjDst( @WrkAllCodes[CDimOffset], CDimNumCodes, DCSProj );
      PVisByte := TN_PByte(VisVector.PDE(i));

      if IRes = 1 then PVisByte^ := 1
                  else PVisByte^ := 0;
    end; // for i := 0 to ULines.WNumItems-1 do // along all ULines, i - Item index

  end; // with APParams^ do
end; // procedure N_ActFillVisVector

//******************************************************** N_ActConvCoords1 ***
// Convert all CObjects in given CObjDir:
// $000 - remain the same (can be used to copy Src CObjects Content to Dst CObjects Content)
// $100 - AffCoefs6 convertion by givem coefs (using TN_AffConvObj)
// $200 - Nonlinear X,Y Convertion by TN_XYNLConvPWIObj
// $300 - GeoProj Convertion
// $400 - Matr Convertion
// $500 - Open dialog Form for editing Matr Convertion params
// $600 - Shift Coords so that MapRoot.CompUCoords.TopLeft = (0,0)
// $700 - Prepare AffConvObj by two Rects ($700) ( Src in CAParStr1, Dst in CAFRect)
// $800 - Clone Src CObjects to Dst CObjects if not exists and create MapLayers if not yet
// $900 - Delete all Items in all CObjects in DstCObjDir (to reduce CObject size)
//
// (for using in TN_UDAction under Action Name "ConvCoords1")
//
procedure N_ActConvCoords1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, Flags, NChanel, ErrRes: integer;
  ScaleCoef: float;
  Str: string;
  SrcCObjDir, DstCObjDir, UDData, CurUObj: TN_UDBase;
  AffCoefs4: TN_AffCoefs4;
  AffCoefs6: TN_AffCoefs6;
  UDActionComp: TN_UDAction;
  SavedCursor: TCursor;
  SL: TStringList;
  AffConvObj: TN_AffConvObj;
  XYPWIConvObj: TN_XYPWIConvObj;
  GeoProjObj: TN_GeoProjObj;
  DstMapRoot: TN_UDBase;
  PAuxPar: Pointer;
  ConvDPFunc: TN_ConvDPFuncObj;
  TmpFRect: TFRect;
  Label Fin;

  function PrepMatrConvObj(): integer; // local
  // prepare TN_MatrConvObj in UDActObj1 field and STATIC! CAFPArray field
  begin
    Result := N_CreateMatrConvObj( UDActionComp );

    if Result <> 0 then // Error
    begin
      N_CurShowStr( Format( 'MatrConv Error = %d', [Result] ) );
    end else // if Result = 0, no errors
    with TN_MatrConvObj(UDActionComp.UDActObj1) do
    begin
      ConvDPFunc := NLConvDP;
      SL.Add( Format( 'MatrConv: MNX=%d, MNY=%d', [MNX,MNY] ) );
    end;
  end; // function PrepMatrConvObj - local

begin //*********************************** body of N_ActConvCoords1
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.NGCont do
  begin
    //***** Get Params
    SrcCObjDir := CAUDBase1; // Source CObjects Dir
    DstCObjDir := CAUDBase2; // Destination CObjects Dir
    DstMapRoot := CAUDBase3; // Dst MapRoot (where to change UserCoords Rect)
//    UDData     := nil; // UDRArray of doubles with TN_XYPWIConvObj convertion params
    UDData     := CAUDBase4; // UDRArray of doubles with TN_XYPWIConvObj convertion params

    Str := CAParStr2; // MapEnvRect ScaleCoef
    ScaleCoef := N_ScanFloat( Str );
    if ScaleCoef = N_NotAFloat then ScaleCoef := 1.05;

    Str := CAParStr4;
    NChanel := N_ScanInteger( Str ); // CAIRect.Bottom; // Protocol Chanel
    if NChanel = N_NotAnInteger then NChanel := 0;

    Flags      := CAFlags1;
    // bits $00000F - Protocol bits (0 - nothing, 1 - summary)
    // bits $0000F0 - Sub Action Flags, depend upon Main Action
    //                =1 - do not initialize coords by SrcCObj
    // bits $000F00 - Main Action To Perform:
    //                =0 - just copy Src CObjects Content to Dst CObjects Content
    //                     (all needed Dst CObjects should already exist in Dst Dir)
    //                =1 - AffCoefs6 convertion given in CAStr1
    //                =2 - Convertion by TN_XYPWIConvObj
    //                =3 - GeoProj Convertion
    //                =4 - Matr Convertion
    //                =5 - Open dialog Form for editing Matr Convertion params
    //                =6 - Shift Coords so that MapRoot.CompUCoords.TopLeft = (0,0)
    //                =7 - AffCoefs4 convertion by two rects: Src in CAParStr1, Dst in CAFRect
    //                     if (Flags and $020) <> 0 then // convert only inside Src Rect
    //                =8 - Clone Src CObjects to Dst CObjects if not yet and create MapLayers if not yet
    //                =9 - Delete all Items in all CObjects in DstCObjDir (to reduce CObject size)
    // bit $0001000 =1- Do not Redraw N_ActiveRFrame after convertion

    SL := TStringList.Create; // where to collect protocol

    if (Flags and $0F00) = $0500 then // Open dialog Form for editing Matr Convertion params
    begin
      ErrRes := PrepMatrConvObj();

      if ErrRes > 0 then // Error
      begin
        N_CurShowStr( Format( 'PrepMatr Error = %d', [ErrRes] ) );
//        Exit;
      end; // if ErrRes > 0 then // Error

      N_CreateNLConvForm( nil, UDActionComp );
      N_CurShowStr( '3Rects Editor Started' );
      Exit;
    end; // if (Flags and $0F00) = $0500 then // Open dialog Form for editing Matr Convertion params

    if (Flags and $0F00) = $0900 then // Delete all Items in all CObjects in DstCObjDir
    begin
      if DstCObjDir = nil then Exit;

      for i := 0 to DstCObjDir.DirHigh() do // along UObjects in DstCObjDir
      begin
        CurUObj := DstCObjDir.DirChild( i );
        if not (CurUObj is TN_UCObjLayer) then Continue;

        TN_UCObjLayer(CurUObj).InitItems( 0 );
      end; // for i := 0 to DstCObjDir.DirHigh() do // along UObjects in DstCObjDir

      Exit;
    end; // if (Flags and $0F00) = $0900 then // Delete all Items in all CObjects in DstCObjDir

    //***** Here: all other cases except $0500 and $0900

    if SrcCObjDir = nil then
    begin
      N_CurShowStr( 'No SrcCObjDir' );
      Exit;
    end;

    if DstCObjDir = nil then
    begin
      N_CurShowStr( 'No DstCObjDir' );
      Exit;
    end;

    if (Flags and $0F) > 0 then // Add Protocol Header and begin message
    begin
      SL.Add( '' );
      SL.Add( ' Convert CObj from ' + SrcCObjDir.ObjName + ' to ' + DstCObjDir.ObjName );
      N_CurShowStr( 'Begin Converting...' );
    end; // if (Flags and $0F) > 0 then // Add Protocol Header and begin message

    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;
    PAuxPar    := nil; // ConvDPFunc second parameter (not used now)
    ConvDPFunc := nil; // to avoid warning


    //********************** Prepare needed Convertion Object ************

    if (Flags and $0F00) = $0000 then // just copy Src CObjects Content to Dst CObjects Content
    begin                             // ConvDPFunc should remains nil)
      Flags := Flags and (not $010);  // clear "skip initialization" flag
    end; // if (Flags and $0F00) = $0000 then // just copy Src CObjects Content to Dst CObjects Content

    AffConvObj   := nil;
    XYPWIConvObj := nil;
    GeoProjObj   := nil;

    //*****  Prepare AffConvObj ($100)

    if (Flags and $0F00) = $0100 then // AffCoefs6 convertion from CAStr1,
    begin                             // Create AffConvObj
      Str := CAStr1; // Old var, now CAParStr1 is used

      if Str = '' then Str := CAParStr1;

      if Str = '' then Str := N_MEGlobObj.MEAffCoefsStr; // old var/ may be not needed

      if Str = '' then // Coefs are not given
      begin
        N_CurShowStr( 'No Aff Coefs' );
        Exit;
      end;
      // given Coefs as string (CXX CXY SX CYX CYY SY)

      SL.Add( ' Coefs: ' + Str );

      if Str[1] = '$' then // use N_CalcAffCoefs6( AParamsStr: string; var AffCoefs6: TN_AffCoefs6 );
        N_CalcAffCoefs6( Str, AffCoefs6 )
      else // given Coefs as string (CXX CXY SX CYX CYY SY)
        AffCoefs6 := N_ScanAffCoefs6( Str );

      if AffCoefs6.CXX = N_NotADouble then
      begin
        N_CurShowStr( 'Bad Aff Coefs' );
        Exit;
      end;

      AffConvObj := TN_AffConvObj.Create;
      AffConvObj.PAffCoefs6 := @AffCoefs6;
      ConvDPFunc := AffConvObj.AffConvDP;
    end; // if (Flags and $0F00) = $0100 then // AffCoefs6 convertion from Str1

    //*****  Prepare XYPWIConvObj ($200)

    if (Flags and $0F00) = $0200 then // Convertion by TN_XYPWIConvObj,
    begin                             // Create TN_XYPWIConvObj
      if not (UDData is TK_UDRArray) then
      begin
        N_CurShowStr( 'Bad UDData' );
        Exit;
      end;

      XYPWIConvObj := TN_XYPWIConvObj.Create();
      ErrRes := XYPWIConvObj.NLConvPrep( PDouble(TK_UDRArray(UDData).R.P()) );

      if ErrRes > 0 then // Error
      begin
        N_CurShowStr( Format( 'Convertion Error = %d', [ErrRes] ) );
        Exit;
      end; // if ErrRes > 0 then // Error

      ConvDPFunc := XYPWIConvObj.NLConvDP;
    end; // if (Flags and $0F00) = $0200 then // Convertion by TN_XYPWIConvObj,

    //*****  Prepare GeoProjObj ($300)

    if (Flags and $0F00) = $0300 then // GeoProj convertion from CAStr1
    begin
      GeoProjObj := TN_GeoProjObj.Create;
      Str := CAStr1; // given Coefs as string (Scale BS B1 B2 BN  LW L0 LE GPType)
      if Str = '' then Str := CAParStr1;

      if Str = '' then
      begin
        with CAFRect do
          Str := CAParStr3 + Format( '  %f %f %f  1', [Left,Top,Right] );
//        Str := CAParStr2 + Format( '  %f %f %f  1', [Left,Top,Right] );
      end;

      Str := Str + ' $060'; // add ConvMode - from (L,-B) to (X,Y)
      GeoProjObj.SetCoefsByStr( Str );
      GeoProjObj.GeoProjConvPrep( nil );
      ConvDPFunc := GeoProjObj.GeoProjConvDP;
      SL.Add( ' Coefs: ' + Str );
    end; // if (Flags and $0F00) = $0300 then // GeoProj convertion from CAStr1

    //*****  Prepare MatrConvObj ($400)

    if (Flags and $0F00) = $0400 then // Matr Convertion by CAParStr1(NX,NY), CAFRect, CAFPoints
    begin
      ErrRes := PrepMatrConvObj();

      if ErrRes > 0 then // Error
      begin
        N_CurShowStr( Format( 'PrepMatr Error = %d', [ErrRes] ) );
        Exit;
      end; // if ErrRes > 0 then // Error
    end; // if (Flags and $0F00) = $0400 then // Matr Convertion

    //*****  Prepare Shift AffConvObj ($600)

    if (Flags and $0F00) = $0600 then // Shift AffConvObj ( shift
    begin                             //   MapRoot.CompUCoords.TopLeft -> (0,0) )
      if not (DstMapRoot is TN_UDCompVis) then // error
      begin
        N_CurShowStr( 'Bad MapRoot!' );
        Exit;
      end;

      TmpFRect := TN_UDCompVis(DstMapRoot).PCCS()^.CompUCoords;

      AffCoefs4 := N_DefAffCoefs4;

      AffCoefs4.SX := -TmpFRect.Left;
      AffCoefs4.SY := -TmpFRect.Top;

      with AffCoefs4 do
        SL.Add( Format( ' Shift by: %.3f  %.3f', [SX, SY] ) );

      AffConvObj := TN_AffConvObj.Create;
      AffConvObj.PAffCoefs4 := @AffCoefs4;
      ConvDPFunc := AffConvObj.AffConvDP;
    end; // if (Flags and $0F00) = $0600 then // Shift AffConvObj

    //*****  Prepare AffConvObj by two Rects ($700) ( Src in CAParStr1, Dst in CAFRect)

    if (Flags and $0F00) = $0700 then // AffCoefs4 convertion by two Rects (CAParStr1 -> CAFRect)
    begin
      Str := CAParStr1; // SrcRect
      SL.Add( ' Src Rect: ' + Str );
      TmpFRect := N_ScanFRect( Str );
      SL.Add( ' Dst Rect: ' + N_RectToStr( CAFRect ) );

      AffCoefs4 := N_CalcAffCoefs4( TmpFRect, CAFRect );

      if AffCoefs4.CX = N_NotADouble then
      begin
        N_CurShowStr( 'Bad Aff Coefs' );
        Exit;
      end;

      AffConvObj := TN_AffConvObj.Create;

      if (Flags and $020) <> 0 then // convert only inside SrcRect
      begin
        AffConvObj.GivenRect  := TmpFRect;
        AffConvObj.InsideGivenRect := True; // convert only inside GivenRect
      end; // if (Flags and $020) <> 0 then // convert only inside SrcRect

      AffConvObj.PAffCoefs4 := @AffCoefs4;
      ConvDPFunc := AffConvObj.AffConvDP;
    end; // if (Flags and $0F00) = $0700 then // AffCoefs4 convertion by two Rects

    //                =8 - copy Src CObjects to Dst CObjects if not yet and create MapLayer if not yet

    //*****  Clone Src CObjects to Dst CObjects if not yet and create MapLayer if not yet

    if (Flags and $0F00) = $0800 then // Clone CObjects to Dst and create MapLayers if needed
    begin
      N_PrepareMap1( SrcCObjDir, DstCObjDir, DstMapRoot );
      N_CalcMapEnvRect( TN_UDCompVis(DstMapRoot), ScaleCoef );
      ErrRes := 0;
      goto Fin; // all done
    end; // if (Flags and $0F00) = $0800 then // Clone CObjects to Dst and create MapLayers if needed


    ErrRes := 0;
    Str := '';

    //***** Convert DstCObjects by prepared Func of Object ConvDPFunc and PAuxPar

    if (Flags and $010) <> 0 then // do not initialize by SrcCObjects
      SrcCObjDir := nil; // SrcCObjDir=nil in N_ConvUObjects means that initialization
                         // of Dst CObjects by CObjects before convertion is not needed

    N_ConvUObjects( SrcCObjDir, DstCObjDir, DstMapRoot, ConvDPFunc, PAuxPar, ScaleCoef, @Str );
//    N_ConvUObjects( SrcCObjDir, DstCObjDir, nil, ConvDPFunc, PAuxPar, ScaleCoef, @Str );
    SL.Add( Str );

    Fin: //*************************************

    if ErrRes = 0 then
      N_CurShowStr( 'Converted OK' );

    FreeAndNil( AffConvObj );
    FreeAndNil( XYPWIConvObj );
    FreeAndNil( GeoProjObj );
    FreeAndNil( UDActionComp.UDActObj1 ); // TN_MatrConvObj

    Screen.Cursor := SavedCursor;

    if (Flags and $0F) > 0 then
    begin
      SL.Add( ' CObjNames: ' + Str );
      N_AddStr( NChanel, SL.Text );
    end;

    if ((Flags and $01000) = 0) and
        (N_ActiveRFrame <> nil)   then
      N_ActiveRFrame.RedrawAllAndShow();

    SL.Free;
  end; // with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
end; //*** end of procedure N_ActConvCoords1

//******************************************************** N_ActNonLinConv1 ***
// Non Linear Convertion #1
//    SrcCObjDir := CAUDBase1; // Source CObjects Dir
//    DstCObjDir := CAUDBase2; // Destination CObjects Dir
//                  CAUDBase3; // not used
//    DstMapRoot := CAUDBase4; // Dst MapRoot (where to change UCoords Rect)
//    Needed Data UDRArrays should be UDAction Children
//
// (for using in TN_UDAction under Action Name "NonLinConv1")
//
procedure N_ActNonLinConv1( APParams: TN_PCAction; AP1, AP2: Pointer );
begin
  N_CreateNLConvForm( nil, TN_UDAction(AP1^) );
  N_CurShowStr( '3Rects Editor Started' );
end; //*** end of procedure N_ActNonLinConv1

//****************************************************** N_ActSnapULines ***
//
//   Obsolete, code should be moved to N_ActULinesActions1
//
// Snap ULines to given Grid and remove small segments and small lines
//
// (for using in TN_UDAction under Action Name "SnapULines")
//
procedure N_ActSnapULines( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, j, k, NumParts, NewItemInd, NewPartInd, DstInd: integer;
  Flags, DstCoordsType, NChanel, ItemBCodesSize: integer;
  NumRemovedPoints, NumRemovedParts, NumRemovedItems: integer;
  NumOnePointLines, NumZeroSegments: integer;
  SrcName, DstName, Str: string;
  MinSegmSize, SegmSize: double;
  SnapSize, PrevPoint: TDPoint;
  DataRoot, CObjectsRoot: TN_UDBase;
  SrcULines, DstULines, TmpULines: TN_ULines;
  UDActionComp: TN_UDAction;
  SrcPartDCoords, DstPartDCoords: TN_DPArray;
  ItemBCodes: TN_IArray;
  SL: TStringList;
  Label DstUlinesReady;
begin //************************************ body of N_ActSnapULines
  SL := nil;          // to avoid warning
  SegmSize := 0;      // to avoid warning
  DstCoordsType := 0; // to avoid warning

  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
  begin
    //***** Get Params
    DataRoot  := CAUDBase1; // Data and CoordsObjects Root
    SrcName   := CAStr1;
    DstName   := CAStr2;
    NChanel   := CAIRect.Bottom; // Protocol Chanel
    Flags     := CAFlags1;
    // bits $00000F - Protocol bits (0 - nothing)
    //
    // bit  $000010 - <>0 - Snap to Grid with
    // bit  $000020 - <>0 - Remove small segments
    // bit  $000040 - <>0 - Remove small lines
    //
    // bits $000F00 - DstULines Coords Type:
    //                =0 - same type as SrcULines
    //                =1 - Float coords
    //                =2 - Double coords

    SnapSize := DPoint( CAFRect.Left, CAFRect.Left ); // DPoint( CADPoint1.X, CADPoint1.X );
    MinSegmSize := CAFRect.Top; // CADPoint1.Y;

    CObjectsRoot := DataRoot.DirChildByObjName( 'CObjects' );
    if CObjectsRoot = nil then
    begin
      N_CurShowStr( 'SnapULines: No CoordsObjects Dir!' );
      Exit;
    end;

    SrcULines := TN_ULines(CObjectsRoot.DirChildByObjName( SrcName ));
    if SrcULines = nil then
    begin
      N_CurShowStr( 'SnapULines: No SrcULines!' );
      Exit;
    end;

    case (Flags and $0F00) of
      0: DstCoordsType := SrcULines.WLCType;
      1: DstCoordsType := N_FloatCoords;
      2: DstCoordsType := N_DoubleCoords;
    end;

    if SrcName <> DstName then // Src and Dst Ulines are not the same
    begin
      DstULines := TN_ULines(CObjectsRoot.DirChildByObjName( DstName ));
      if DstULines = nil then // Create new DstULines with given DstName
      begin
        DstULines := TN_ULines.Create1( DstCoordsType );
        N_AddUChild( CObjectsRoot, DstULines, DstName );
      end else // DstULines already exists, change its CoordsType if needed
      begin
        if (Flags and $0F00) = $0300 then
          DstCoordsType := DstULines.WLCType;

        DstULines.WLCType := DstCoordsType;
      end;
    end else // Src and Dst Ulines are the same, create temporary DstULines
    begin
      DstULines := TN_ULines.Create1( DstCoordsType );
    end;

    DstULines.InitItems( SrcULines.WNumItems, SrcULines.WNumItems*100 );
    DstULines.CopyCoords( SrcULines );

    //*** Now DstULines has Coords of needed type

    if (Flags and $010) <> 0 then // Snap to Grid
      DstULines.SnapToGrid( N_ZDPoint, SnapSize );

    if (Flags and $0F) > 0 then // Show collected statistics
    begin
      SL := TStringList.Create();
      SL.Add( '' );
      SL.Add( 'SnapULines Statistics:' );
    end;

    NumRemovedPoints := 0;
    NumRemovedParts  := 0;
    NumRemovedItems  := 0;
    NumZeroSegments  := 0;
    NumOnePointLines := 0;

    if (Flags and $020) = 0 then // do not skip any Points (do only Snapping to Grid)
      goto DstUlinesReady;

    SrcPartDCoords := nil;
    TmpULines := TN_ULines.Create2( DstULines );
    TmpULines.CopyFields( DstULines );
    DstULines.InitItems( TmpULines.WNumItems, TmpULines.WNumItems*100 );

    for i := 0 to TmpULines.WNumItems-1 do
    begin
      NumParts := TmpULines.GetNumParts( i );
      if NumParts = 0 then Continue; // skip empty items

      TmpULines.GetItemAllCodes( i, ItemBCodes, ItemBCodesSize );
      NewItemInd := -1;
      NewPartInd := -1;

      for j := 0 to NumParts-1 do // along i-th Item parts
      begin
        TmpULines.GetPartDCoords( i, j, SrcPartDCoords );

        if Length(SrcPartDCoords) <= 1 then
        begin
          if (Flags and $040) = 0 then // do not skip current (one point) Part
          begin
            NewPartInd := -1;
            DstULines.SetPartDCoords( NewItemInd, NewPartInd, SrcPartDCoords );
          end else
            Inc( NumRemovedParts );

          Inc( NumOnePointLines );

          if (Flags and $0F) > 1 then
            SL.Add( Format( 'OnePointLine: Item=%d Part=%d', [i,j] ) );

          Continue; // to next Part
        end; // if Length(PartDCoords) <= 1 then

        SetLength( DstPartDCoords, Length(SrcPartDCoords) );
        DstPartDCoords[0] := SrcPartDCoords[0];
        PrevPoint := SrcPartDCoords[0];
        DstInd := 1;

        for k := 1 to High(SrcPartDCoords) do // along SrcPartDCoords points
        begin
          SegmSize := N_P2PDistance( PrevPoint, SrcPartDCoords[k] );

          if SegmSize > MinSegmSize then // add cur Point to DstPartDCoords
          begin
            DstPartDCoords[DstInd] := SrcPartDCoords[k];
            PrevPoint := DstPartDCoords[DstInd];
            Inc( DstInd );
          end else // skip Cur Point
          begin
            Inc( NumRemovedPoints );
            if SegmSize = 0 then Inc( NumZeroSegments );

            if (Flags and $0F) > 1 then
              SL.Add( Format( 'Small Segm: ItemI=%d PartI=%d PointI=%d (%.4g)',
                                               [i,j,k,SegmSize] ) );
          end; // else // skip Cur Point

        end; // for k := 1 to High(PartDCoords) do // along SrcPartDCoords points

        if DstInd = 1 then // Whole Part is <= MinSegmSize
        begin
          if (Flags and $040) = 0 then // do not skip current small Part
          begin
            SetLength( DstPartDCoords, 2 );
            DstPartDCoords[1] := SrcPartDCoords[High(SrcPartDCoords)];
            NewPartInd := -1;
            DstULines.SetPartDCoords( NewItemInd, NewPartInd, DstPartDCoords );
          end else // skip current small Part
          begin
            Inc( NumRemovedParts );

            if ((Flags and $0F) > 1) and (NumParts > 1) then
              SL.Add( Format( 'Small Part: ItemI=%d PartI=%d (%.4g)',
                                               [i,j,SegmSize] ) );
          end; // else // skip current small Part
        end else // DstInd > 1, add DstPartDCoords as new Part
        begin
          SetLength( DstPartDCoords, DstInd );
          DstPartDCoords[DstInd-1] := SrcPartDCoords[High(SrcPartDCoords)]; // preserve last point
//          N_ADS( 'ItemInd', NewItemInd, NewPartInd );
          NewPartInd := -1;
          DstULines.SetPartDCoords( NewItemInd, NewPartInd, DstPartDCoords );
        end;

      end; // for j := 0 to NumParts-1 do // along i-th Item parts

      if NewPartInd = -1 then // Item was skiped
      begin
        Inc( NumRemovedItems );

        if (Flags and $0F) > 1 then
          SL.Add( Format( 'Small Item: ItemI = %d (%.4g)',
                                         [i,SegmSize] ) );
      end else // Item was not skipped, copy Codes from TmpULines to DstULines
        DstULines.SetItemAllCodes( NewItemInd, TmpULines, i );

    end; // for i := 0 to WNumItems-1 do

    TmpULines.Free;

    DstUlinesReady: //*******************************

    DstULines.CalcEnvRects();

    Str := K_DateTimeToStr( Date+Time, 'dd.mm.yyyy(hh:nn:ss)' );
    Str := 'Created at ' + Str + ' from: ' + SrcULines.ObjName;
    DstULines.ObjInfo := Str;

    if SrcName = DstName then // Src and Dst Ulines are the same
    begin
      SrcULines.MoveFields( DstULines );
      DstULines.Free;
    end;

    if (Flags and $0F) > 0 then // Show colleacted statistics
    begin
      SL.Add( Format( '  MinSegmSize = %.5g,  SnapDist = %.5g', [MinSegmSize, SnapSize.X] ) );
      SL.Add( Format( '  NumOnePointLines = %d', [NumOnePointLines] ) );
      SL.Add( Format( '  NumRemovedPoints = %.4d,  NumZeroSegments = %d', [NumRemovedPoints, NumZeroSegments] ) );
      SL.Add( Format( '  NumRemovedParts  = %d,     NumRemovedItems = %d', [NumRemovedParts, NumRemovedItems] ) );
      N_AddStr( NChanel, SL.Text );
      SL.Free;
    end;

  end; // with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
end; //*** end of procedure N_ActSnapULines


//****************************************************** N_ActJavaToSVG1 ***
// Create SVG text file from Java to code and replace "+$0D$0A" by Space
// ( Java code in CAFName1,  SVG file Name in CAFName2 )
// (for using in TN_UDAction under Action Name "JavaToSVG1")
//
procedure N_ActJavaToSVG1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  UDActionComp: TN_UDAction;
  i, j, DFlag, LineInd, RegInd, Ind, L, NumLines: integer;
  Str, BufStr, InpStr, IndsStr, RegName, FName1, FName2: string;
  SL1, SL2: TStringlist;
  SkipFirstChar, Lines, Regions: boolean;
  RegInds: TN_IArray;
  Borders: TN_AFPArray;
  RegCenters, RegCoords, Coords1, Coords2: TN_FPArray;
  RegNames: TN_SArray;
  PLastPoint: TFPoint; // Prev line Last Point

  function CoordsToPath( AId, AC1, AC2, ACoords, AC3: string ): string; // local
  // convert ACoords to path string
  var
    S1: string;
  begin
    S1 := N_ScanToken( ACoords );
    S1 := S1 + ' ' + N_ScanToken( ACoords ); // first point
    Result := '    <path id="' + AId + '" d="' + AC1 + S1 + AC2 + ACoords + AC3 + '"/>';
  end; // local

  procedure SplitString( AStr: string; ASize: integer; ASL: TStrings ); // local
  // Split given AStr at Space if needed and add resulting strings to ASL
  var
    Ind: integer;
  begin
    if Length( AStr) <= ASize then
    begin
      ASL.Add( Astr );
      Exit;
    end;

    Ind := PosEx( ' ', AStr, ASize );

    if Ind = 0 then
    begin
      ASL.Add( Astr );
      Exit;
    end;

    ASL.Add( Copy( Astr, 1, Ind-1 ) );

    SplitString( Copy( Astr, Ind, Length(AStr) ), ASize, ASL );
  end; // local

begin
  Coords1 := nil; // to avoid warning
  Coords2 := nil; // to avoid warning

  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp do
  begin
    N_s := ObjName; // debug
    SL1 := TStringlist.Create();
    SL2 := TStringlist.Create();

    FName1 := K_ExpandFileName( CAFName1 );
    FName2 := K_ExpandFileName( CAFName2 );

    SL1.LoadFromFile( FName1 );

    i := 0;
    BufStr := '';
    SkipFirstChar := False;

    while True do // main loop along SL1 strings - join broken strings
    begin
      if i >= SL1.Count then Break;

      InpStr := SL1[i];
      L := Length(InpStr);

      if (L <= 2) or (InpStr[L-1] <> '"') or (InpStr[L] <> '+') then // do not change
      begin
        if SkipFirstChar then
          SL2.Add( BufStr + Copy( InpStr, 2, Length(InpStr)-1 ) )
        else
          SL2.Add( BufStr + InpStr );

        BufStr := '';
        SkipFirstChar := False;
      end else
      begin
        if SkipFirstChar then
          BufStr := BufStr + Copy( InpStr, 2, L-3 )
        else
          BufStr := BufStr + Copy( InpStr, 1, L-2 );

        SkipFirstChar := True;
      end;

      Inc( i );
    end; // while True do // mail loop along SL1 strings

    Sl1.Clear;
    Lines := False;
    Regions := False;
    SetLength( Borders, 106 );
    SetLength( RegNames, 25 );
    SetLength( RegCenters, 25 );
    LineInd := 0;

    for i := 0 to SL2.Count-1 do // second, java -> SVG convertion loop
    begin
      Str := SL2[i];
      if Str = 'Lines' then Lines := True;
      if Str = 'Lines' then SL1.Add( '***Lines' );
      if Str = 'Regions' then Regions := True;
      if Str = 'Regions' then SL1.Add( '***Regions' );
      if Str = 'End' then Lines := False;
      if Str = 'End' then Regions := False;

      if (Length(Str) >= 2) and (Str[1] = '/') and (Str[2] = '/') then Continue; // skip comment

      Str := StringReplace( Str, '");', '', [] ); // OK for all strings
      Ind := Pos( '"iline', Str );

      if Lines then // collect regions borders coords
      begin
        Assert( LineInd <= 105, 'Err!' );
        if Ind = 0 then Continue;

        Str := Copy( Str, Ind+6, Length(Str) ); // Coords only

        SetLength( Borders[LineInd], 2000 );
        j := 0;

        while True do // Conv Str to Borders[LineInd]
        begin
          Assert( j<2000, 'Err!' );
          Borders[LineInd,j] := N_ScanFPoint( Str );

          if Borders[LineInd,j].X = N_NotAFloat then // end of Str
          begin
            SetLength( Borders[LineInd], j );
            Break;
          end;

          if j > 0 then // conv relative coords to absolute
          begin
            Borders[LineInd,j].X := Borders[LineInd,j].X + Borders[LineInd,j-1].X;
            Borders[LineInd,j].Y := Borders[LineInd,j].Y + Borders[LineInd,j-1].Y;
          end;

          Inc( j );
        end; // while True do // Conv Str to Borders[LineInd]

        Inc( LineInd );
        Continue;
      end; // if Lines then // collect regions borders coords

      if Regions then // create region path
      begin
        Ind := Pos( '"lpoly lines', Str );
        if Ind = 0 then Continue;

        Str := Copy( Str, Ind+12, Length(Str) ); // Lines Inds, Id and Prompt

        Ind := Pos( 'id=', Str );
        IndsStr := Copy( Str, 1, Ind ); // Lines Inds only
        Str := Copy( Str, Ind+3, 100 ); // Id and Prompt

        RegInd := N_ScanInteger( Str ); // Id
        Assert( (RegInd >= 0) and (RegInd <= 24), 'Err!' );

        Ind := Pos( '%', Str );
        RegName := Copy( Str, Ind+1, 100 );
        RegNames[RegInd] := RegName;

        SetLength( RegInds, 100 );
        j := 0;

        while True do // loop along Lines Inds (create RegInds)
        begin
          RegInds[j] := N_ScanInteger( IndsStr );

          if RegInds[j] = N_NotAnInteger then
          begin
            SetLength( RegInds, j );
            Break;
          end; // if RegInds[j] = N_NotAnInteger then

          Inc( j );
        end; // while True do // along Lines Inds

        NumLines := Length(RegInds);
        RegCoords := nil;

        for j := 0 to NumLines-1 do // loop along Lines Inds (create RegCoords)
        begin
          LineInd := RegInds[j];
          Coords1 := Borders[LineInd];

          if j = 0 then // first Border Line
          begin
            if NumLines <= 2 then
              DFlag := 0
            else // NumLines > 2
          begin
            Coords2 := Borders[RegInds[j+1]];
              if ( (Coords2[0].X = Coords1[0].X) and
                   (Coords2[0].Y = Coords1[0].Y) ) or
                 ( (Coords2[High(Coords2)].X = Coords1[0].X) and
                   (Coords2[High(Coords2)].Y = Coords1[0].Y) ) then
                DFlag := 1
              else
                DFlag := 0;
            end;
          end else //****************** not first Line
            if (Coords1[0].X <> PLastPoint.X) or
               (Coords1[0].Y <> PLastPoint.Y)  then DFlag := 1
                                               else DFlag := 0;
          if DFlag = 0 then
            PLastPoint := Coords1[High(Coords1)]
          else
            PLastPoint := Coords1[0];

          N_AddFcoordsToFCoords( RegCoords, Coords1, DFlag );

        end; // for j := 0 to NumLines-1 do // loop along Lines Inds (create RegCoords)

        //***** RegCoords are OK, create Path string

        RegCenters[RegInd] := N_CalcPolylineCenter( PFPoint(@RegCoords[0]), Length(RegCoords) );

        Str := '';
        for j := 0 to High(RegCoords) do
          Str := Str + Format( '%.0f %.0f ', [RegCoords[j].X,RegCoords[j].Y] );

        Str := CoordsToPath( RegName, 'M ', ' L ', Str, 'z' );
        SplitString( Str, 500, SL1 );
        Continue;
      end; // if Lines then // collect regions borders coords

      //***** Convert separate Lines and Polygons

      if Ind >= 1 then
        Str := CoordsToPath( '', 'M ', ' l ', Copy( Str, Ind+6, Length(Str) ), '' );

      Ind := Pos( '"ipoly', Str );
      if Ind >= 1 then
        Str := CoordsToPath( '', 'M ', ' l ', Copy( Str, Ind+6, Length(Str) ), '' );

      SplitString( Str, 500, SL1 );
    end; // for i := 0 to SL1.Count-1 do // second, convertion loop

    for i := 0 to 24 do // Create Reg Names
    begin
      SL1.Add( Format( ' Name=%s %f, %f', [RegNames[i],RegCenters[i].X,RegCenters[i].Y] ) );

    end; // for i := 0 to 24 do // Create Reg Names

    SL1.SaveToFile( FName2 );
    SL1.SaveToFile( FName2 + '1' );

    SL1.Free;
    SL2.Free;
  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActJavaToSVG1

//****************************************************** N_ActJavaToULines ***
// Create SVG text file from Java code and replace "+$0D$0A" by Space
// ( Java code in CAFName1,  SVG file Name in CAFName2 )
// (for using in TN_UDAction under Action Name "JavaToULines")
//
procedure N_ActJavaToULines( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  UDActionComp: TN_UDAction;
  i, j, LineInd, Ind, L: integer;
  ItemInd, PartInd, RegCode: integer;
  Str, BufStr, InpStr, IndsStr, FName1: string;
  SL1, SL2: TStringlist;
  SkipFirstChar, Lines, Regions: boolean;
  DCoords: TN_DPArray;
  ULines: TN_ULines;

begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp do
  begin
    N_s := ObjName; // debug
    SL1 := TStringlist.Create();
    SL2 := TStringlist.Create();

    FName1 := K_ExpandFileName( CAFName1 ); // Src Java code
    ULines := TN_ULines( CAUDBase1 ); // resulting ULines
    ULines.InitItems( 110, 10000 );

    SL1.LoadFromFile( FName1 );

    i := 0;
    BufStr := '';
    SkipFirstChar := False;

    while True do // first loop along SL1 strings - join broken strings
    begin         // put resulting strings in SL2
      if i >= SL1.Count then Break;

      InpStr := SL1[i];
      L := Length(InpStr);

      if (L <= 2) or (InpStr[L-1] <> '"') or (InpStr[L] <> '+') then // do not change
      begin
        if SkipFirstChar then
          SL2.Add( BufStr + Copy( InpStr, 2, Length(InpStr)-1 ) )
        else
          SL2.Add( BufStr + InpStr );

        BufStr := '';
        SkipFirstChar := False;
      end else
      begin
        if SkipFirstChar then
          BufStr := BufStr + Copy( InpStr, 2, L-3 )
        else
          BufStr := BufStr + Copy( InpStr, 1, L-2 );

        SkipFirstChar := True;
      end;

      Inc( i );
    end; // while True do // first loop along SL1 strings - join broken strings

    Sl1.Clear;
    Lines := False;
    Regions := False;
    LineInd := 0;

    for i := 0 to SL2.Count-1 do // second loop, java -> SVG convertion loop
    begin
      Str := SL2[i];
      if Str = 'Lines' then Lines := True;
      if Str = 'Regions' then Regions := True;
      if Str = 'End' then Lines := False;
      if Str = 'End' then Regions := False;

      if (Length(Str) >= 2) and (Str[1] = '/') and (Str[2] = '/') then Continue; // skip comment

      Str := StringReplace( Str, '");', '', [] ); // OK for all strings
      Ind := Pos( '"iline', Str );

      if Lines then // collect regions borders coords
      begin
        Assert( LineInd <= 105, 'Err!' );
        if Ind = 0 then Continue;

        Str := Copy( Str, Ind+6, Length(Str) ); // Coords only
        SetLength( DCoords, 2000 );
        j := 0;

        while True do // Conv Str to Borders[LineInd]
        begin
          Assert( j<2000, 'Err!' );
          DCoords[j] := N_ScanDPoint( Str );

          if DCoords[j].X = N_NotADouble then // end of Str
          begin
            SetLength( DCoords, j );
            Break;
          end;

          if j > 0 then // conv relative coords to absolute
          begin
            DCoords[j].X := DCoords[j-1].X + DCoords[j].X;
            DCoords[j].Y := DCoords[j-1].Y + DCoords[j].Y;
          end;

          Inc( j );
        end; // while True do // Conv Str to Borders[LineInd]

        ItemInd := LineInd;
        PartInd := -1;
        ULines.SetPartDCoords( ItemInd, PartInd, DCoords, j );

        Inc( LineInd );
        Continue;
      end; // if Lines then // collect regions borders coords

      if Regions then // Add RegCodes to Lines
      begin
        Ind := Pos( '"lpoly lines', Str );
        if Ind = 0 then Continue;

        Str := Copy( Str, Ind+12, Length(Str) ); // Lines Inds, Id and Prompt

        Ind := Pos( 'id=', Str );
        IndsStr := Copy( Str, 1, Ind ); // Lines Inds only
        Str := Copy( Str, Ind+3, 100 ); // Id and Prompt

        RegCode := N_ScanInteger( Str ); // Id value
        Assert( (RegCode >= 1) and (RegCode <= 26), 'Err!' );

        while True do // loop along Lines Inds that belongs to region with RegCode
        begin
          LineInd := N_ScanInteger( IndsStr );

          if LineInd = N_NotAnInteger then Break; // end of LineInds

          ULines.AddXORItemCode( LineInd, @RegCode, 1, 0 );
        end; // while True do // loop along Lines Inds that belongs to region with RegCode

      end; // if Regions then // Add RegCodes to Lines

    end; // for i := 0 to SL1.Count-1 do // second, convertion loop

    SL1.Free;
    SL2.Free;
  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActJavaToULines

//*******************************(((***************** N_ActContCenterPoints ***
// Fill given UDPoints CObj by centers of given Contours
//
// (for using in TN_UDAction under Action Name "ContCenterPoints")
//
procedure N_ActContCenterPoints( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, CDimInd, Code: integer;
  Conts: TN_UContours;
  CenterPoints: TN_UDPoints;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin
    Conts        := TN_UContours(CAUDBase1); // given Contours
    CenterPoints := TN_UDPoints(CAUDBase2);  // Resulting Points with Conts Centers
    CDimInd      := CAIRect.Left; // CAIPoint1.X; // Conts CDimInd for getting Codes for Points

    if not (CAUDBase1 is TN_UContours) then
    begin
      N_CurShowStr( CAUDBase1.ObjName + 'is not TN_UContours!' );
      Exit;
    end;

    if not (CAUDBase2 is TN_UDPoints) then
    begin
      N_CurShowStr( CAUDBase2.ObjName + 'is not TN_UDPoints!' );
      Exit;
    end;

    CenterPoints.InitItems( Conts.WNumItems, Conts.WNumItems );
    Conts.CalcEnvRects();

    for i := 0 to Conts.WNumItems-1 do // along all Contours
    with Conts.Items[i] do
    begin
      if (CFInd and N_EmptyItemBit) <> 0 then Continue; // skip empty Items

      Code := Conts.GetItemFirstCode( i, CDimInd );
      CenterPoints.AddOnePointItem ( Conts.GetItemCenter( i ), Code );
    end; // for i := 0 to Conts.WNumItems-1 do // along all Contours

    CenterPoints.WItemsCSName := Conts.WItemsCSName;
    N_CurShowStr( 'Center Points "' + CenterPoints.ObjName + '" Created OK' );
  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActContCenterPoints

//*************************************************** N_ActCreateTextBlocks ***
// Create TextBlocks (TN_UDParaBox) with centers over given UDPoints
//
// (for using in TN_UDAction under Action Name "CreateTextBlocks")
//
procedure N_ActCreateTextBlocks( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, Code, Flags: integer;
  TextBlocksRoot: TN_UDBase;
  PatternParaBox, CurParaBox: TN_UDParaBox;
  CenterPoints: TN_UDPoints;
  CurCenter: TDPoint;
  SParams: TK_RArray;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin
    TextBlocksRoot := CAUDBase1;               // where to cretae new TextBlocks
    PatternParaBox := TN_UDParaBox(CAUDBase2); // Pattern TN_UDParaBox
    CenterPoints   := TN_UDPoints(CAUDBase3);  // given Points with TextBlocks Centers Coords
    Flags          := CAFlags1;
    N_i := Flags;

    if not (CAUDBase2 is TN_UDParaBox) then
    begin
      N_CurShowStr( CAUDBase2.ObjName + 'is not TN_UDParaBox!' );
      Exit;
    end;

    if not (CAUDBase3 is TN_UDPoints) then
    begin
      N_CurShowStr( CAUDBase3.ObjName + 'is not TN_UDPoints!' );
      Exit;
    end;

//    if Flags
    TextBlocksRoot.ClearChilds();

    for i := 0 to CenterPoints.WNumItems-1 do // along all given Points
    begin
      Code := CenterPoints.GetCCode( i );
      CurParaBox := TN_UDParaBox(N_CreateSubTreeClone( PatternParaBox ));
      CurParaBox.ObjName := CurParaBox.ObjName + '_' + IntToStr( Code );

      //***** Set #Codes in SPSrcField field

      SParams := CurParaBox.PSP()^.CSetParams;

      if SParams.ALength() >= 1 then // SParams[0] exist
        TN_POneSetParam(SParams.P(0))^.SPSrcField := '#' + IntToStr( Code );

      //***** Set Point Coords to CCoords.BPCoords field
      CurCenter := CenterPoints.GetPointCoords( i, 0 );
      CurParaBox.PSP()^.CCoords.BPCoords := FPoint( CurCenter );

      TextBlocksRoot.AddOneChildV( CurParaBox );
    end; // for i := 0 to CenterPoints.WNumItems-1 do // along all given Points

    N_CurShowStr( IntToStr( CenterPoints.WNumItems ) + ' TextBlocks Created' );

  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActCreateTextBlocks


//**************** Any UObjects related Actions

//***************************************************** N_ActSysActions1 ***
// Perform several "System" Actions, given in CAStr1 and CAFlags1:
//
// Action Name (CAStr1 - Before, CAStr2 - After):
//   ClearUObj  - Clear UDBase Children in two given Dirs(CAUDBase1,2) + Flag actions
//   ViewUObj   - View given UObj(CAUDBase4 or CAUDBase3) + Flag actions
//   ''     - (emty string) - only Flag actions
//
// Not implemeneted Actions:
//   ClearFiles - Clear Files in two given Dirs + Flag actions
//   ViewFile   - View given File + Flag actions
//   SaveUObj   - Save given UObj to given File
//   LoadUObj   - Load given File inside or before given UObj
//
// Actions in CAFlags1 (Protocol Chanel in CAIPoint1.X):
//   bit0 ($001) - Add CurTime to Protokol (in BeforeAction only)
//   bit1 ($002) - Add String in CAStr3 to Protokol in BeforeAction
//   bit2 ($004) - Add String in CAStr3 to Protokol in AfterAction
//   bit4 ($010) - Start Timer in Before Action and Stop in After Action
//                 (Info String in CAStr3)
//
// (for using in TN_UDAction under Action Name "SysActions1")
//
procedure N_ActSysActions1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  UDActionComp: TN_UDAction;
  NChanel: integer;
  Str: string;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp, UDActionComp.NGCont do
  begin
    //************ Actions, given by name in CAStr1:

    NChanel := CAIRect.Bottom; // IPoint1.X;

    if (UpperCase(Trim(CAStr1)) = 'CLEARUOBJ') and (UDActionProcType=aptBefore) then
    begin  // Clear UDBase Children in BeforeAction method
      CAUDBase1.ClearChilds();
      CAUDBase2.ClearChilds();
    end else if (UpperCase(Trim(CAStr2)) = 'CLEARUOBJ') and (UDActionProcType=aptAfter) then
    begin  // Clear UDBase Children in AfterAction method
      CAUDBase1.ClearChilds();
      CAUDBase2.ClearChilds();
    end else if (UpperCase(Trim(CAStr1)) = 'VIEWUOBJ') and (UDActionProcType=aptBefore) then
    begin  // View given UObj in BeforeAction method
      N_ViewUObjAsMap( CAUDBase3, nil, nil );
    end else if (UpperCase(Trim(CAStr2)) = 'VIEWUOBJ') and (UDActionProcType=aptAfter) then
    begin  // View given UObj in AfterAction method
      N_ViewUObjAsMap( CAUDBase3, nil, nil );
    end;

    //************  Actions, given by CAFlags1:

    if ((CAFlags1 and $01) <> 0) and (UDActionProcType=aptBefore) then // Add CurTime to Protokol
      N_AddStr( NChanel, '##CurTime' );                                // in BeforeAction

    if ((CAFlags1 and $02) <> 0) and (UDActionProcType=aptBefore) then // Add CAStr3 to Protokol
      N_AddStr( NChanel, CAStr3 + ' (Before)' );                       // in BeforeAction

    if ((CAFlags1 and $04) <> 0) and (UDActionProcType=aptAfter) then // Add CAStr3 to Protokol
      N_AddStr( NChanel, CAStr3 + ' (After)' );                       // in After Action

    if (CAFlags1 and $010) <> 0 then // Start/Stop Timer in UDActObj1
    begin
      if (UDActionProcType=aptBefore) then // Called from BeforeAction method
      begin
        UDActObj1.Free; // a precaution
        UDActObj1 := TN_CPUTimer1.Create;
        TN_CPUTimer1(UDActObj1).Start();
      end else //**************** Called from AfterAction method
      begin
        if UDActObj1 is TN_CPUTimer1 then // a precaution
        begin
          TN_CPUTimer1(UDActObj1).SS( CAStr3, Str );
          N_AddStr( NChanel, Str );
          FreeAndNil( UDActObj1 );
        end;
      end;
    end; // if (CAFlags1 and $010) <> 0 then // Start/Stop Timer in UDActObj1

  end; // with APParams^, UDActionComp, UDActionComp.NGCont do
end; //*** end of procedure N_ActSysActions1

//***************************************************** N_ActSysActions2 ***
// Perform several "System" Actions #2 not implemented
//
// (for using in TN_UDAction under Action Name "SysActions2")
//
procedure N_ActSysActions2( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp, UDActionComp.NGCont do
  begin
    N_ShowInfoDlg( 'Temporary SysActions2' );

  end; // with APParams^, UDActionComp, UDActionComp.NGCont do
end; //*** end of procedure N_ActSysActions2

//***************************************************** N_ActReplaceRefs ***
// Replace all References in given SubTreeToChange
//   from PrevSubTree to NewSubTree
//
// (for using in TN_UDAction under Action Name "ReplaceRefs")
//
procedure N_ActReplaceRefs( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  SubTreeToChange, PrevSubTree, NewSubTree: TN_UDBase;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp do
  begin
    SubTreeToChange := GetDUserParUDBase( 'SubTreeToChange' );
    PrevSubTree     := GetDUserParUDBase( 'PrevSubTree' );
    NewSubTree      := GetDUserParUDBase( 'NewSubTree' );

    if SubTreeToChange = nil then SubTreeToChange := CAUDBase1;
    if PrevSubTree     = nil then PrevSubTree := CAUDBase2;
    if NewSubTree      = nil then NewSubTree := CAUDBase3;

    K_ReplaceRefsInSubTree( SubTreeToChange, PrevSubTree, NewSubTree );

    N_CurShowStr( 'Refs Replaced in ' + SubTreeToChange.ObjName );
  end; // with APParams^, UDActionComp do
end; //*** end of procedure N_ActReplaceRefs

//***************************************************** N_ActVFileCodec ***
// Encode or Decode two given VFiles
// (for using in TN_UDAction under Action Name "VFileCodec")
//
procedure N_ActVFileCodec( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  DataSize, ComprSize: integer;
  UDActionComp: TN_UDAction;
  VF1Name, VF2Name, VF3Name: string;
  VFile: TK_VFile;
  DFCreateParams: TK_DFCreateParams;
  ABuf1, ABuf2: TN_BArray;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin

  VF1Name := K_ExpandFileName( CAFName1 ); // Source File
  VF2Name := K_ExpandFileName( CAFName2 ); // Resulting File
  VF3Name := K_ExpandFileName( CAFName3 ); // Plain File, converted from Resulting File
                                           // only if (CAFlags1 and $0F00) = $0100

  // CAIRect.Left field - Create mode:
  //   =0-CreatePlain, =1-CreateProtected, =2-XOREncryption

  N_CurShowStr( 'Converting ...' );

  K_VFAssignByPath( VFile, VF1Name );
  DataSize := K_VFOpen( VFile );
  if DataSize = -1 then
  begin
    N_CurShowStr( 'Open Error for ' + VF1Name );
    Exit;
  end;

  SetLength( ABuf1, DataSize );
  if not K_VFReadAll( VFile, ABuf1 ) then
  begin
    N_CurShowStr( 'Read Error for ' + VF1Name );
    Exit;
  end;

  //***** ABuf1 is OK, Compress if needed

  SetLength( ABuf2, DataSize+10000 );
  ComprSize := N_CompressMem( @ABuf1[0], DataSize, @ABuf2[0], DataSize+10000,
                                                   (CAFlags1 and $0F0) shr 4 );

  case CAIRect.Left of
    1: DFCreateParams := K_DFCreateProtected;
    2: DFCreateParams := K_DFCreateEncryptedSrc;
    else
      DFCreateParams := K_DFCreatePlain;
  end;

  K_VFAssignByPath( VFile, VF2Name, @DFCreateParams );
  K_VFWriteAll( VFile, Pointer(ABuf2), ComprSize );

  if ((CAFlags1 and $0F00) = $0100) and
     (VF3Name <> '')  then // convert any VF2Name to Plain VF3Name
  begin
    N_DecompressMem( @ABuf2[0], ComprSize, @ABuf1[0], DataSize );
    K_VFAssignByPath( VFile, VF3Name, @K_DFCreatePlain );
    K_VFWriteAll( VFile, Pointer(ABuf1), DataSize );

  {
   if K_VFCopyFile( VF2Name, VF3Name, K_DFCreatePlain ) <> K_vfcrOK then
    begin
      N_CurShowStr( 'Error converting to ' + VF3Name );
      Exit;
    end;
  }

  end; // if (CAFlags1 and $0F00) = $0100 then // convert any VF2Name to Plain VF3Name

  N_CurShowStr( VF2Name + ' Created from ' + VF1Name );
  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActVFileCodec

//****************************************************** N_ActDebAction_1 ***
// Temporary Debug Action #1
// (for using in TN_UDAction under Action Name "DebAction1")
//
procedure N_ActDebAction_1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin
//    N_ShowInfoDlg( 'Temporary Debug Action #1' );
    N_FillRectOnWinDesktop( Rect( 10,10, 100,50), $FF );
  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActDebAction_1


//**************** Components Creation

//***************************************************** N_ActLayoutComps ***
// Layout Components:
//
// (for using in TN_UDAction under Action Name "LayoutComps")
//
procedure N_ActLayoutComps( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  UDActionComp: TN_UDAction;
  i, NumComps: integer;
  CompWidth: double;
  CompsRoot, CurComp: TN_UDBase;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp, UDActionComp.NGCont do
  begin
    //************ Actions, given by name in CAStr1:

    CompsRoot := CAUDBase1;
    NumComps := CompsRoot.DirLength();

    if NumComps = 0 then Exit;

    if NumComps = 1 then
    begin
      CurComp := CompsRoot.DirChild( 0 );
      if not (CurComp is TN_UDCompVis) then Exit;

      with TN_UDCompVis(CurComp).PCCS()^ do
      begin
        BPCoords.X := CAFRect.Left;
        BPXCoordsType := cbpPercent;

        LRCoords.X := 100 - CAFRect.Right;
        LRXCoordsType := cbpPercent;
        SRSizeXType := cstNotGiven;
      end; // with TN_UDCompVis(CurComp).PCCS do

      Exit; // all done
    end else //***************** NumComps >= 2
    begin
      CompWidth := (100 - CAFRect.Left - CAFRect.Right -
                          CAFRect.Top*(NumComps-1)) / NumComps;

      for i := 0 to NumComps-1 do // Layout child Comps
      begin
        CurComp := CompsRoot.DirChild( i );
        if not (CurComp is TN_UDCompVis) then Continue; // skip not Visual Comp

        with TN_UDCompVis(CurComp).PCCS()^ do
        begin
          BPCoords.X := CAFRect.Left + i*(CompWidth+CAFRect.Top);
          BPXCoordsType := cbpPercent;

          LRCoords.X := BPCoords.X + CompWidth;
          LRXCoordsType := cbpPercent;
          SRSizeXType := cstNotGiven;
        end; // with TN_UDCompVis(CurComp).PCCS do
      end; // for i := 0 to NumComps-1 do // Layout child Comps

    end; // else //***************** NumComps >= 2
  end; // with APParams^, UDActionComp, UDActionComp.NGCont do
end; //*** end of procedure N_ActLayoutComps

//************************************************* N_ActCreateLinHist_1 ***
// Create Stacked LinHist with MultiColumn Values
// ( two columns of LHRow(Nums,Names), several syncro Values columns, one
//   Stacked LinHist and two CrossRef. columns CRRow(Nums,Names) )
//
//   Self User Params:
// UPComp - Component with User Params for creating MultiColumn LinHist
//                  (the same for LinHist types)
// AllHistsPanel  - Root Panel where all LinHists should be created
//
//   Predefined names used:
// 'PatLinHist'  - Panel Component ObjName (UPComp Child)
//                 used as Pattern LinHist SubTree
// 'LHRowNames'  - TextMarks Component ObjName (UPComp Child)
//                 used as RowNames
// 'FuncTics'    - AxisTics Component ObjName (PatLinHist Child)
//                 used for drawing given FuncTics
// 'FuncTics_20' - AxisTics Component ObjName (PatLinHist Child)
//                 used for drawing FuncTics with Step=20 (Small Step)
// 'FuncTics_40' - AxisTics Component ObjName (PatLinHist Child)
//                 used for drawing FuncTics with Step=40 (Large Step)
// 'TicsMarks'   - TextMarks Component ObjName (PatLinHist Child)
//                 used for drawing Axis Tics text Marks
// 'ColumnName'  - ParaBox Component ObjName (PatLinHist Child)
//                 used as Column (LinHist) Name
// '2DLinHist'   - 2DLinHist Component ObjName (PatLinHist Child)
//
// (for using in TN_UDAction under Action Name "CreateLinHist_1")
//
procedure N_ActCreateLinHist_1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  UDActionComp: TN_UDAction;
  i, j, NumCols, NumRows, NumWidths, NX, NY: integer;
  CompWidth, TicValue, SumRelWidths: double;
  CurComp: TN_UDBase;
  UPComp, AllHistsPanel: TN_UDCompBase;
  FuncsMin, FuncsMax, RelWidths, Values, RowNames, ColNames: TK_RArray;
  FuncTics, Colors: TK_RArray;
  PatLinHistRoot, CurLinHistRoot: TN_UDPanel;
  LeftMostLinHist: TN_UD2DLinHist;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp, UDActionComp.NGCont do
  begin
    //***** Get UPComp
    CurComp := UDActionComp.GetDUserParUDBase( 'UPComp' );
    if not (CurComp is TN_UDCompBase) then Exit;
    UPComp := TN_UDCompBase(CurComp);

    //***** Get AllHistsPanel
    CurComp := UDActionComp.GetDUserParUDBase( 'AllHistsPanel' );
    if not (CurComp is TN_UDPanel) then Exit;
    AllHistsPanel := TN_UDPanel(CurComp);

    //***** Get PatLinHistRoot
    CurComp := UPComp.DirChildByObjName( 'PatLinHist' );
    if not (CurComp is TN_UDPanel) then Exit;
    PatLinHistRoot := TN_UDPanel(CurComp);

    AllHistsPanel.ClearChilds( 0 ); // delete All Children

    //***** Get Values, NumCols, NumRows
    Values := UPComp.GetDUserParRArray( 'Values' );
    Values.ALength( NumCols, NumRows );
    if (NumCols = 0) or (NumRows = 0) then Exit;

    //***** Get RelWidths and calc SumRelWidths
    RelWidths := UPComp.GetDUserParRArray( 'RelWidths' );
    SumRelWidths := 0;
    NumWidths := RelWidths.Alength();
    if NumWidths >= 1 then
    begin
      for i := 0 to NumCols-1 do
        SumRelWidths := SumRelWidths + PDouble(RelWidths.P(i mod NumWidths))^;
    end; // if NumWidths >= 1 then

    LeftMostLinHist := nil;

    for i := 0 to NumCols-1 do // Create and Layout child LinHist Components
    begin
      //***** Create new LinHist SubTrees

      CurLinHistRoot := TN_UDPanel(N_CreateSubTreeClone( PatLinHistRoot ));
      CurLinHistRoot.ObjName := CurLinHistRoot.ObjName + IntToStr( i+1 );
      CurLinHistRoot.PSP()^.CCompBase.CBSkipSelf := 0; // Clear "SkipSelf" flag
      AllHistsPanel.AddOneChildV( CurLinHistRoot );

      //***** Set FuncTics ATBaseZ field

      CurComp := CurLinHistRoot.DirChildByObjName( 'FuncTics' );
      if CurComp is TN_UDAxisTics then
      with TN_UDAxisTics(CurComp).PISP()^ do
      begin
        FuncTics := UPComp.GetDUserParRArray( 'FuncTics' );

        TicValue := N_NotADouble;
        if (FuncTics <> nil) and ( FuncTics.ALength() >= (i+1) ) then
          TicValue := PDouble(FuncTics.P(i))^;

        if TicValue <> N_NotADouble then
          ATBaseZ := TicValue;
      end; // with TN_UDAxisTics(CurComp) do, if CurComp is TN_UDAxisTics then

      //***** Set TicsMarks TMBaseComp field

      CurComp := CurLinHistRoot.DirChildByObjName( 'TicsMarks' );
      if CurComp is TN_UDTextMarks then
      with TN_UDTextMarks(CurComp).PISP()^ do
      begin
        if NumCols <= 3 then // use small step for Axis Tics text Marks
        begin
          K_SetUDRefField( TN_UDBase(TMBaseComp),
                           CurLinHistRoot.DirChildByObjName( 'FuncTics_20' ) );
        end else
        begin
          K_SetUDRefField( TN_UDBase(TMBaseComp),
                           CurLinHistRoot.DirChildByObjName( 'FuncTics_40' ) );
        end;
      end; // with TN_UDTextMarks(CurComp).PISP()^ do, if CurComp is TN_UDTextMarks then

      //***** Set Column Name

      CurComp := CurLinHistRoot.DirChildByObjName( 'ColumnName' );
      if CurComp is TN_UDParaBox then
      with TN_UDParaBox(CurComp).PISP()^ do
      begin
        ColNames := UPComp.GetDUserParRArray( 'ColNames' );
        if (ColNames <> nil) and ( ColNames.ALength() >= (i+1) ) then
          TN_POneTextBlock(CPBTextBlocks.P(0))^.OTBMText := PString(ColNames.P(i))^;
      end; // with TN_UDParaBox(CurComp).PISP()^ do, if CurComp is TN_UDParaBox then

      //***** Set CurLinHist LHValues, LHFillColor, FuncsMin and FuncsMax fields

      CurComp := CurLinHistRoot.DirChildByObjName( '2DLinHist' );
      if CurComp is TN_UD2DLinHist then
      with TN_UD2DLinHist(CurComp).PSP()^ do
      begin
        if i = 0 then // used for setting LHRowNames.TMBaseComp field
          LeftMostLinHist := TN_UD2DLinHist(CurComp);

        C2DLinHist.LHValues.ASetLength( NumRows );
        for j := 0 to NumRows-1 do // fill Cur Column Values
        begin
          PDouble(C2DLinHist.LHValues.P(j))^ := PDouble(Values.P(i+NumCols*j))^;
        end; // for j := 0 to NumRows-1 do // fill Cur Column Values

        Colors := UPComp.GetDUserParRArray( 'Colors' );
        if Colors <> nil then
        begin
          Colors.ALength( NX, NY );

          if NX = 1 then // Colors are Column Colors
          begin
            C2DLinHist.LHFillColors.ASetLength( 1 );
            if NY > i then // Colors.P(i) exists
              PInteger(C2DLinHist.LHFillColors.P())^ := PInteger(Colors.P(i))^;
          end else //  Colors are individual for all values
          begin
            C2DLinHist.LHFillColors.ASetLength( NumRows );
            for j := 0 to NumRows-1 do // fill Cur Column Colors
            begin
              if NY > j then // Colors.P(i+NumCols*j) exists
                PDouble(C2DLinHist.LHFillColors.P(j))^ := PDouble(Colors.P(i+NumCols*j))^;
            end; // for j := 0 to NumRows-1 do // fill Cur Column Colors
          end;

        end; // if Colors <> nil then

        FuncsMin := UPComp.GetDUserParRArray( 'FuncsMin' );
        if (FuncsMin <> nil) and ( FuncsMin.ALength() >= (i+1) ) then
          C2DSpace.TDSFuncMin := PDouble(FuncsMin.P(i))^;

        FuncsMax := UPComp.GetDUserParRArray( 'FuncsMax' );
        if (FuncsMax <> nil) and ( FuncsMax.ALength() >= (i+1) ) then
          C2DSpace.TDSFuncMax := PDouble(FuncsMax.P(i))^;
      end; // with TN_UD2DLinHist(CurComp).PSP()^ do

      //***** Layout all LinHists (Pattern and just created)

      if NumWidths >= 1 then
        CompWidth := 100 * PDouble(RelWidths.P(i mod NumWidths))^ / SumRelWidths
      else
        CompWidth := 100 / NumCols;

      with CurLinHistRoot.PCCS()^ do
      begin
        BPCoords.X := i*CompWidth;
        BPXCoordsType := cbpPercent;

        LRCoords.X := BPCoords.X + CompWidth;
        LRXCoordsType := cbpPercent;
        SRSizeXType := cstNotGiven;
      end; // with CurLinHistRoot.PCCS do

    end; // for i := 0 to NumCols-1 do // Create and Layout child LinHist Components

    //***** Set Row Names (LinHist Groups Names)

    CurComp := UPComp.DirChildByObjName( 'LHRowNames' );
    if CurComp is TN_UDTextMarks then
    with TN_UDTextMarks(CurComp).PIDP()^ do
    begin
      TMBaseComp := LeftMostLinHist;
      RowNames := UPComp.GetDUserParRArray( 'RowNames' );
      K_RFreeAndCopy( TMStrings, RowNames, [K_mdfCopyRArray] );
    end; // with TN_UDTextMarks(CurComp).PISP()^ do

    AllHistsPanel.InitSubTree( [] ); // create dynamic Params

  end; // with APParams^, UDActionComp, UDActionComp.NGCont do
end; //*** end of procedure N_ActCreateLinHist_1

//************************************************* N_ActCreateLinHist_2 ***
// Create MultiColumn LinHist
// (one column of RowNames and several syncro LinHist columns)
//
//   Self User Params:
// LHRootComp     - Root Component with PatLinHist, AllHistsPanel and LHRowNames
//                  children (may be the same as UPComp)
// UPComp - Component with User Params for creating MultiColumn LinHist:
//   Values	   - MCLinHist Value Matrix (One Column for each LinHist Values vector)
//   Colors    - Columns Colors (syncro with Values columns) if Colors.NX = 1 or
//               Individual LinHist Elements Colors (synchro with Values)
//   ValStyles - Individual LinHist Elements Text Values (ints, synchro with Values)
//   RowNames	 - Rows Names (syncro with Values rows)
//   ColNames	 - Columns Names (syncro with Values columns)
//   FuncTics	 - Func Tic values (syncro with Values columns), where Tics should be drawn
//   FuncsMin	 - function Range minimum Values (syncro with Values columns)
//   FuncsMax	 - function Range maximum  Values (syncro with Values columns)
//   RelWidths - Columns (LinHists) relative widths (syncro with Values columns)
//
//   Predefined names used:
// 'PatLinHist'    - Panel Component ObjName (LHRootComp Child)
//                   used as Pattern LinHist SubTree for one LinHist
// 'AllHistsPanel' - Panel Component ObjName (LHRootComp Child)
//                   used as Root Panel where all LinHists should be created
// 'LHRowNames'    - TextMarks Component ObjName (LHRootComp Child)
//                   used as RowNames
// 'FuncTics'    - AxisTics Component ObjName (PatLinHist Child)
//                 used for drawing given FuncTics
// 'FuncTics_20' - AxisTics Component ObjName (PatLinHist Child)
//                 used for drawing FuncTics with Step=20 (Small Step)
// 'FuncTics_40' - AxisTics Component ObjName (PatLinHist Child)
//                 used for drawing FuncTics with Step=40 (Large Step)
// 'TicsMarks'   - TextMarks Component ObjName (PatLinHist Child)
//                 used for drawing Axis Tics text Marks
// 'ColumnName'  - ParaBox Component ObjName (PatLinHist Child)
//                 used as Column (LinHist) Name
// '2DLinHist'   - 2DLinHist Component ObjName (PatLinHist Child)
//
// (for using in TN_UDAction under Action Name "CreateLinHist_2")
//
procedure N_ActCreateLinHist_2( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  UDActionComp: TN_UDAction;
  i, j, NumCols, NumRows, NumWidths, NX, NY: integer;
  CompWidth, TicValue, SumRelWidths: double;
  CurComp: TN_UDBase;
  UPComp, LHRootComp, AllHistsPanel: TN_UDCompBase;
  FuncsMin, FuncsMax, RelWidths, Values, RowNames, ColNames: TK_RArray;
  FuncTics, Colors: TK_RArray;
  PatLinHistRoot, CurLinHistRoot: TN_UDPanel;
  LeftMostLinHist: TN_UD2DLinHist;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp, UDActionComp.NGCont do
  begin
    //***** Get UPComp
    CurComp := UDActionComp.GetDUserParUDBase( 'UPComp' );
    if not (CurComp is TN_UDCompBase) then Exit;
    UPComp := TN_UDCompBase(CurComp);

    //***** Get LHRootComp
    CurComp := UDActionComp.GetDUserParUDBase( 'LHRootComp' );
    if not (CurComp is TN_UDCompBase) then Exit;
    LHRootComp := TN_UDCompBase(CurComp);

    //***** Get AllHistsPanel
    CurComp := LHRootComp.DirChildByObjName( 'AllHistsPanel' );
    if not (CurComp is TN_UDPanel) then Exit;
    AllHistsPanel := TN_UDPanel(CurComp);

    //***** Get PatLinHistRoot
    CurComp := LHRootComp.DirChildByObjName( 'PatLinHist' );
    if not (CurComp is TN_UDPanel) then Exit;
    PatLinHistRoot := TN_UDPanel(CurComp);

    AllHistsPanel.ClearChilds( 0 ); // delete All Children

    //***** Get Values, NumCols, NumRows
    Values := UPComp.GetDUserParRArray( 'Values' );
    Values.ALength( NumCols, NumRows );
    if (NumCols = 0) or (NumRows = 0) then Exit;

    //***** Get RelWidths and calc SumRelWidths
    RelWidths := UPComp.GetDUserParRArray( 'RelWidths' );
    SumRelWidths := 0;
    NumWidths := RelWidths.Alength();
    if NumWidths >= 1 then
    begin
      for i := 0 to NumCols-1 do
        SumRelWidths := SumRelWidths + PDouble(RelWidths.P(i mod NumWidths))^;
    end; // if NumWidths >= 1 then

    LeftMostLinHist := nil;

    for i := 0 to NumCols-1 do // Create and Layout child LinHist Components
    begin
      //***** Create new LinHist SubTrees

      CurLinHistRoot := TN_UDPanel(N_CreateSubTreeClone( PatLinHistRoot ));
      CurLinHistRoot.ObjName := CurLinHistRoot.ObjName + IntToStr( i+1 );
      CurLinHistRoot.PSP()^.CCompBase.CBSkipSelf := 0; // Clear "SkipSelf" flag
      AllHistsPanel.AddOneChildV( CurLinHistRoot );

      //***** Set FuncTics ATBaseZ field

      CurComp := CurLinHistRoot.DirChildByObjName( 'FuncTics' );
      if CurComp is TN_UDAxisTics then
      with TN_UDAxisTics(CurComp).PISP()^ do
      begin
        FuncTics := UPComp.GetDUserParRArray( 'FuncTics' );

        TicValue := N_NotADouble;
        if (FuncTics <> nil) and ( FuncTics.ALength() >= (i+1) ) then
          TicValue := PDouble(FuncTics.P(i))^;

        if TicValue <> N_NotADouble then
          ATBaseZ := TicValue;
      end; // with TN_UDAxisTics(CurComp) do, if CurComp is TN_UDAxisTics then

      //***** Set TicsMarks TMBaseComp field

      CurComp := CurLinHistRoot.DirChildByObjName( 'TicsMarks' );
      if CurComp is TN_UDTextMarks then
      with TN_UDTextMarks(CurComp).PISP()^ do
      begin
        if NumCols <= 3 then // use small step for Axis Tics text Marks
        begin
          K_SetUDRefField( TN_UDBase(TMBaseComp),
                           CurLinHistRoot.DirChildByObjName( 'FuncTics_20' ) );
        end else
        begin
          K_SetUDRefField( TN_UDBase(TMBaseComp),
                           CurLinHistRoot.DirChildByObjName( 'FuncTics_40' ) );
        end;
      end; // with TN_UDTextMarks(CurComp).PISP()^ do, if CurComp is TN_UDTextMarks then

      //***** Set Column Name

      CurComp := CurLinHistRoot.DirChildByObjName( 'ColumnName' );
      if CurComp is TN_UDParaBox then
      with TN_UDParaBox(CurComp).PISP()^ do
      begin
        ColNames := UPComp.GetDUserParRArray( 'ColNames' );
        if (ColNames <> nil) and ( ColNames.ALength() >= (i+1) ) then
          TN_POneTextBlock(CPBTextBlocks.P(0))^.OTBMText := PString(ColNames.P(i))^;
      end; // with TN_UDParaBox(CurComp).PISP()^ do, if CurComp is TN_UDParaBox then

      //***** Set CurLinHist LHValues, LHFillColor, FuncsMin and FuncsMax fields

      CurComp := CurLinHistRoot.DirChildByObjName( '2DLinHist' );
      if CurComp is TN_UD2DLinHist then
      with TN_UD2DLinHist(CurComp).PSP()^ do
      begin
        if i = 0 then // used for setting LHRowNames.TMBaseComp field
          LeftMostLinHist := TN_UD2DLinHist(CurComp);

        C2DLinHist.LHValues.ASetLength( NumRows );
        for j := 0 to NumRows-1 do // fill Cur Column Values
        begin
          PDouble(C2DLinHist.LHValues.P(j))^ := PDouble(Values.P(i+NumCols*j))^;
        end; // for j := 0 to NumRows-1 do // fill Cur Column Values

        Colors := UPComp.GetDUserParRArray( 'Colors' );
        if Colors <> nil then
        begin
          Colors.ALength( NX, NY );

          if NX = 1 then // Colors are Column Colors
          begin
            C2DLinHist.LHFillColors.ASetLength( 1 );
            if NY > i then // Colors.P(i) exists
              PInteger(C2DLinHist.LHFillColors.P())^ := PInteger(Colors.P(i))^;
          end else //  Colors are individual for all values
          begin
            C2DLinHist.LHFillColors.ASetLength( NumRows );
            for j := 0 to NumRows-1 do // fill Cur Column Colors
            begin
              if NY > j then // Colors.P(i+NumCols*j) exists
                PDouble(C2DLinHist.LHFillColors.P(j))^ := PDouble(Colors.P(i+NumCols*j))^;
            end; // for j := 0 to NumRows-1 do // fill Cur Column Colors
          end;

        end; // if Colors <> nil then

        FuncsMin := UPComp.GetDUserParRArray( 'FuncsMin' );
        if (FuncsMin <> nil) and ( FuncsMin.ALength() >= (i+1) ) then
          C2DSpace.TDSFuncMin := PDouble(FuncsMin.P(i))^;

        FuncsMax := UPComp.GetDUserParRArray( 'FuncsMax' );
        if (FuncsMax <> nil) and ( FuncsMax.ALength() >= (i+1) ) then
          C2DSpace.TDSFuncMax := PDouble(FuncsMax.P(i))^;
      end; // with TN_UD2DLinHist(CurComp).PSP()^ do

      //***** Layout all LinHists (Pattern and just created)

      if NumWidths >= 1 then
        CompWidth := 100 * PDouble(RelWidths.P(i mod NumWidths))^ / SumRelWidths
      else
        CompWidth := 100 / NumCols;

      with CurLinHistRoot.PCCS()^ do
      begin
        BPCoords.X := i*CompWidth;
        BPXCoordsType := cbpPercent;

        LRCoords.X := BPCoords.X + CompWidth;
        LRXCoordsType := cbpPercent;
        SRSizeXType := cstNotGiven;
      end; // with CurLinHistRoot.PCCS do

    end; // for i := 0 to NumCols-1 do // Create and Layout child LinHist Components

    //***** Set Row Names (LinHist Groups Names)

    CurComp := LHRootComp.DirChildByObjName( 'LHRowNames' );
    if CurComp is TN_UDTextMarks then
    with TN_UDTextMarks(CurComp).PIDP()^ do
    begin
      TMBaseComp := LeftMostLinHist;
      RowNames := UPComp.GetDUserParRArray( 'RowNames' );
      K_RFreeAndCopy( TMStrings, RowNames, [K_mdfCopyRArray] );
    end; // with TN_UDTextMarks(CurComp).PISP()^ do

    AllHistsPanel.InitSubTree( [] ); // create dynamic Params

  end; // with APParams^, UDActionComp, UDActionComp.NGCont do
end; //*** end of procedure N_ActCreateLinHist_2

//******************************************************* N_ActSetMCLHUP ***
// Set MultiColumn LinHist User Params
//
//  Self User Params:
// MCLinHist   - MCLinHist Root with UserParams to set
// NX          - Number of Values Matrix Columns
// NY          - Number of Values Matrix Rows
// PatRowNames - Pattern Rows Names (any Length, syncro with Values rows)
// PatColNames - Pattern Columns Names (any Length, syncro with Values columns)
//
//   MultiColumn LinHist User Params (only *Fields are set):
// *Values	   - MCLinHist Value Matrix (One Column for each LinHist Values vector)
//  Colors     - Columns Colors (syncro with Values columns) if Colors.NX = 1 or
//               Individual LinHist Elements Colors (synchro with Values)
//  ValStyles  - Individual LinHist Elements Text Values (ints, synchro with Values)
// *RowNames	 - Rows Names (syncro with Values rows)
// *ColNames	 - Columns Names (syncro with Values columns)
//  FuncTics	 - Func Tic values (syncro with Values columns), where Tics should be drawn
//  FuncsMin	 - function Range minimum Values (syncro with Values columns)
//  FuncsMax	 - function Range maximum  Values (syncro with Values columns)
//  RelWidths  - Columns (LinHists) relative widths (syncro with Values columns)
//
// (for using in TN_UDAction under Action Name "SetMCLHUP")
//
procedure N_ActSetMCLHUP( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  UDActionComp: TN_UDAction;
  ix, iy, NumCols, NumRows: integer;
  Values, RowNames, ColNames, PatRowNames, PatColNames: TK_RArray;
  CurComp: TN_UDBase;
  MCLinHist: TN_UDCompBase;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp, UDActionComp.NGCont do
  begin
    //***** Set MCLinHist component with User Params to set
    CurComp := GetDUserParUDBase( 'MCLinHist' );
    if CurComp is TN_UDCompBase then
      MCLinHist := TN_UDCompBase(CurComp)
    else
      Exit;

    //***** Set Values matrix
    NumCols := Round(GetDUserParDbl( 'NX' ));
    NumRows := Round(GetDUserParDbl( 'NY' ));
    if (NumCols <= 0) or (NumRows <= 0) then Exit;

    Values := MCLinHist.GetSUserParRArray( 'Values' );
    if Values <> nil then
    begin
      Values.ASetLength( NumCols, NumRows );

      for ix := 0 to NumCols-1 do
      for iy := 0 to NumRows-1 do
      begin
      // CADPoint1.X + Random*(CADPoint1.Y-CADPoint1.X);
        PDouble(Values.P(ix+iy*NumCols))^ := CAFRect.Left + Random*(CAFRect.Top-CAFRect.Left);
      end;
    end; // if Values <> nil then

    //***** Set RowNames if needed
    RowNames := MCLinHist.GetSUserParRArray( 'RowNames' );
    if RowNames <> nil then
    begin
      RowNames.ASetLength( NumRows );
      PatRowNames := GetDUserParRArray( 'PatRowNames' );
      N_FillStringsArray( PString(RowNames.P()), NumRows,
                          PString(PatRowNames.P()), PatRowNames.ALength() );
    end; // if RowNames <> nil then

    //***** Set ColNames if needed
    ColNames := MCLinHist.GetSUserParRArray( 'ColNames' );
    if ColNames <> nil then
    begin
      ColNames.ASetLength( NumCols );
      PatColNames := GetDUserParRArray( 'PatColNames' );
      N_FillStringsArray( PString(ColNames.P()), NumCols,
                          PString(PatColNames.P()), PatColNames.ALength() );
    end; // if ColNames <> nil then
  end; // with APParams^, UDActionComp, UDActionComp.NGCont do
end; //*** end of procedure N_ActSetMCLHUP


//**************** Word Documents creation

//**************************************************** N_ActGetWordIcons
// Create Word Command Bar with Icons with ID from CAInt1 to CAInt2,
// CAStr1 is added to CommandBar Caption
// (for using in TN_UDAction under Action Name "WordIcons")
//
procedure N_ActGetWordIcons( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i: integer;
  CBCaption: string;
  Panel, Button: Variant;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
  begin
    DefWordServer();
    GCWordServer.Visible := False; // to speed up Icons creation
    CBCaption := Format( 'Word Icons from %d  to %d (%s)',
                                        [1,100,CAStr1] );
    Panel := GCWordServer.CommandBars.Add( CBCaption );
    Panel.Visible := True;

    for i := 1 to 100 do
    begin
      Button := Panel.Controls.Add( Type:=msoControlButton, ID:=1 );
//      Button.Style := msoButtonIconAndCaption;
      Button.Style := msoButtonIcon;
      Button.Caption := IntToStr( i ); // used in Hint
      Button.FaceId := i;
    end;

    GCWordServer.Visible := True;
  end; // with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
end; //*** end of procedure N_ActGetWordIcons

//**************************************************** N_ActWordDebActive1
// Word Action Operations with currently Active Document 1:
//   Move, Collapse Range, Paste Text, Paste SubDocument
// (for using in TN_UDAction under Action Name "WordDebActive1")
//
procedure N_ActWordDebActive1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  UDActionComp: TN_UDAction;
  Str, FName1, FName2: string;
//  BM: Variant;
  Label GetCommand;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.NGCont do
  begin
    FName1 := K_ExpandFileName( CAFName1 );
    FName2 := K_ExpandFileName( CAFName2 );

    DefWordServer();
    GCWordServer.Visible := True;
    GCWSMainDoc := GCWordServer.ActiveDocument;
    GCShowResponseProc( GCWSMainDoc.Name );
    Str := 't1';

    GetCommand: //*******************

    if not N_EditString( Str, 'Enter Command:' ) then // all done
    begin
      GCWSMainDoc := Unassigned();
      GCWordServer := Unassigned();
      GCShowResponseProc( 'Finished OK' );
      Exit;
    end;

    if Str = 'ml' then // Move Left by 1 and Select
    begin
      GCWSMainDocIP := GCWordServer.Selection.Range;
      GCWSMainDocIP.Move( wdCharacter, -1 );
      GCWSMainDocIP.Select;
    end else if Str = '1' then // Move Left by 1 and Insert Clipboard
    begin
      GCWSMainDocIP := GCWordServer.Selection.Range;
      GCWSMainDocIP.Move( wdCharacter, -1 );
      GCWSMainDocIP.Paste;
      GCWSMainDocIP.Select;
    end else if Str = 'm' then // Run Macro
    begin
      GCWSMainDoc := GCWordServer.Documents.Add();
      GCWSMainDoc.Activate;
      N_s := GCWordServer.ActiveDocument.Name;
      GCWordServer.Run( 'Normal.Module1.TestMacro2' );
      GCWordServer.Run( 'Normal.Module1.TestMacro3' );
    end else if Str = 't1' then // Temporary code #1
    begin
      WordInsNearBookmark( wibwhereEnd1, wibWhatSubDoc, 'a1', FName1 );
      WordInsNearBookmark( wibwhereEnd1, wibWhatSubDoc, 'a1', FName2 );
    end else if Str = 't-1' then // Temporary code #2
    begin
      GCWSMainDocIP := GCWordServer.Selection.Range;
      GCWSMainDocIP.Move( wdCharacter, 1 );
      GCWSMainDocIP.Paste;
      GCWSMainDocIP.Select;
    end else if Str = '**' then // code Pattern
    begin

    end;

    goto GetCommand;
  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActWordDebActive1

//*************************************************** N_ActWordCreateTable1 ***
// Create Table1 (for FOM Atlas) at the end of GCWSMainDoc
//
// Create Table's Tab-delimited content using User Params of Component in CAUDBase1
// (matrix ValTexts and two vectors LHRowNames and LHColNames)
// Copy it to Clipboard and and call VBA procedure in CAStr1 or
// do the same actions in Pascal
//
// (for using in TN_UDAction under Action Name "WordCreateTable1")
//
procedure N_ActWordCreateTable1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  ix, iy, MNX, MNY, TNX, TNY: integer;
  ParamsStr, VBAMacroName, FontSizeStr: string;
  FontSize: float;
  PortretTable: boolean;
  UserParamComp: TN_UDCompBase;
  OneRowSL, MatrSL: TStringList;
  ValTexts, LHRowNames, LHColNames: TK_RArray;

  Range, TblNew: variant;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin
    if not (CAUDBase1 is TN_UDCompBase) then Exit;

    UserParamComp := TN_UDCompBase(CAUDBase1); // Component with needed UserParams

    VBAMacroName  := CAStr1;      // VBA Macro that creates Word Table
    FontSize      := 0; // CADPoint1.X; // Table Font Size as String
    if FontSize = 0 then FontSize := 10; // a precaution
    PortretTable := (CAFlags1 and $0100) = 0;

    with UserParamComp do
    begin
      ValTexts := GetDUserParRArray( 'ValTexts', Ord(nptString) );
      if ValTexts = nil then Exit;

      LHRowNames := GetDUserParRArray( 'LHRowNames', Ord(nptString) );
      if LHRowNames = nil then Exit;

      LHColNames := GetDUserParRArray( 'LHColNames', Ord(nptString) );
      if LHColNames = nil then Exit;
    end; // with UserParamComp do

    ValTexts.ALength( MNX, MNY ); // Set Source Matrix NX,NY

    // Dst Portret Table is of (MNX+1),(MNY+1) size, Landscape Tabe - (MNY+1),(MNX+1) size
    TNX := MNX+1; // Table NX
    TNY := MNY+1; // Table NY

    if not PortretTable then
    begin
      TNX := MNY+1; // Table NX
      TNY := MNX+1; // Table NY
    end;

    if TNX > 63 then // Word max value, Update TNX, MNX, MNY
    begin
      TNX := 63;
      if PortretTable then MNX := TNX - 1
                      else MNY := TNX - 1
    end; // if TNX > 63 then // Word max value, Update TNX, MNX, MNY

    if mewfUseVBA in GCWSVBAFlags then // Create and Add Table in VBA, prepare Params String
    begin
      FontSizeStr := Format( '%.1f', [FontSize] );
      FontSizeStr := N_ReplacePointByDecSep( FontSizeStr );
      ParamsStr := IntToStr( TNX ) + '%%' + IntToStr( TNY ) + '%%' + FontSizeStr;
      SetWordParamsStr( ParamsStr );
    end;

    OneRowSL := TStringList.Create; // OneRowSL.Text is Tab delimited content of one Matr Row
    MatrSL   := TStringList.Create; // MatrSL.Text is final Clipboard content
    OneRowSL.Capacity := max( TNX, TNY );
    OneRowSL.Add( '' ); // upper Left Table Cell

    if PortretTable then //***** Portret Table
    begin
      for ix := 1 to MNX do // prepare Table Columns Names (first Table Row) (Question (Vector) Names)
        OneRowSL.Add( PString(LHColNames.PS(ix-1))^ );

      MatrSL.Add( N_JoinStrings( OneRowSL, #$9 ) );

      for iy := 1 to MNY do // add other Table Rows
      begin
        OneRowSL.Clear;
        OneRowSL.Add( PString(LHRowNames.PS(iy-1))^ ); // iy-th Table RowName (Region Name)

        for ix := 1 to MNX do // prepare iy-th Row Values
          OneRowSL.Add( PString(ValTexts.PME( ix-1, iy-1 ))^ );

        MatrSL.Add( N_JoinStrings( OneRowSL, #$9 ) );
      end; // for iy := 1 to MNY do // add other Rows
    end else //***************** Landscape Table
    begin
      for ix := 1 to MNY do // prepare Table Columns Names (first Table Row) - Region Names
        OneRowSL.Add( PString(LHRowNames.PS(ix-1))^ );

      MatrSL.Add( N_JoinStrings( OneRowSL, #$9 ) );

      for iy := 1 to MNX do // add other Table Rows
      begin
        OneRowSL.Clear;
        OneRowSL.Add( PString(LHColNames.PS(iy-1))^ ); // iy-th Table RowName (Question (Vector) Names)

        for ix := 1 to MNY do // prepare iy-th Row Values
          OneRowSL.Add( PString(ValTexts.PME( iy-1, ix-1 ))^ );

        MatrSL.Add( N_JoinStrings( OneRowSL, #$9 ) );
      end; // for iy := 1 to MNX do // add other Rows
    end; // else // Landscape Table

    OneRowSL.Free;
    K_PutTextToClipboard( MatrSL.Text ); // save as Unicode Text
    MatrSL.Free;

    if mewfUseVBA in GCWSVBAFlags then // Create and Add Table in VBA
      RunWordMacro( VBAMacroName )
    else //****************************** Create and Add Table in Pascal
    begin
      Range := GCWSMainDoc.Content;
      Range.InsertParagraphAfter;
      Range.Collapse( Direction:=wdCollapseEnd );
      Range.MoveStart( wdCharacter, 1 );

      TblNew := GCWSMainDoc.Tables.Add( Range, TNY, TNX );
      TblNew.Select;
      GCWordServer.Selection.Paste;
      TblNew.Range.Font.Size := FontSize;
      TblNew.Range.Font.Name := 'Arial';
      TblNew.Rows.Alignment := wdAlignRowCenter;
      TblNew.Rows.AllowBreakAcrossPages := False;
      TblNew.Borders.Enable := True;
      TblNew.Rows.Item(1).Range.Orientation := wdTextOrientationUpward;
      TblNew.Rows.Item(1).Range.Font.Bold := True;
      TblNew.Columns.Item(1).Select;
      GCWordServer.Selection.Font.Bold := True;
      TblNew.Columns.AutoFit;
    end; // else // Create and Add Table in Pascal

  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActWordCreateTable1

//***************************************************** N_ActWordActions ***
// Perform several Word related Actions
// (should be called from UDWordFragm Subtree):
//  Flags1 = $100 - add Clipboard to GCWSMainDoc
//         = $200 - Print GCWSMainDoc (CAStr1 - PrinterName, CAIPoint1.X - NumCopies
//         = $300 - Run Macro in CAStr1
//         = $400 - Show info about Word Server
//
// (for using in TN_UDAction under Action Name "WordActions")
//
procedure N_ActWordActions( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  Str: string;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.NGCont do
  begin
    if (CAFlags1 and $0F00) = $0100 then // add Clipboard to GCWSMainDoc
    begin
//      WordPasteClipBoard();
      GCWSMainDocIP.Paste; // Paste Clipboard
      GCWSMainDocIP.Collapse( Direction := wdCollapseEnd );
      GCWSMainDocIP.InsertBreak( Type := wdPageBreak );

    end; // if (CAFlags1 and $0F00) = $0100 then // add Clipboard to GCWSMainDoc

    if (CAFlags1 and $0F00) = $0200 then // Print GCWSMainDoc
    begin
      GCWordServer.ActivePrinter := CAStr1;
      GCWordServer.PrintOut( Copies:=CAIRect.Left ); // CAIPoint1.X
    end; // if (CAFlags1 and $0F00) = $0200 then // Print GCWSMainDoc

    if (CAFlags1 and $0F00) = $0300 then // Run Macro in CAStr1
    begin
      RunWordMacro( CAStr1 );
    end; // if (CAFlags1 and $0F00) = $0300 then // Run Macro in CAStr1

    if (CAFlags1 and $0F00) = $0400 then // Show info about Word Server
    begin
      N_IAdd( '' );
      N_IAdd( GetWSInfo( 2, 'Info about MS Word Server:' ) );

      with N_MEGlobObj do
      begin
        if mewfUseVBA in MEWordFlags then
        begin
          if mewfUseWin32API in MEWordFlags then
            Str := 'Use VBA and Win32API'
          else
            Str := 'Use VBA without Win32API';
        end else
          Str := 'Do NOT Use VBA';

        Str := 'Prefered mode: ' + Str + ', PSM: ' + N_PSModeNames[integer(MEWordPSMode)];
        N_IAdd( Str );
      end; // with N_MEGlobObj do
      N_IAdd( '' );
    end; // if (CAFlags1 and $0F00) = $0400 then // Show info about Word Server

  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActWordActions


//**************** Excel Documents creation

//**************************************************** N_ActGetExcelIcons
// Create Excel Command Bar with Icons with ID from CAInt1 to CAInt2,
// CAStr1 is added to CommandBar Caption
// (for using in TN_UDAction under Action Name "ExcelIcons")
//
procedure N_ActGetExcelIcons( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i: integer;
  CBCaption: string;
  Panel, Button: Variant;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.NGCont do
  begin
    DefExcelServer();
    GCExcelServer.Visible := False; // to speed up Icons creation
    CBCaption := Format( 'Excel Icons from %d  to %d (%s)',
                                          [1,100,CAStr1] );
    Panel := GCExcelServer.CommandBars.Add( CBCaption );
    Panel.Visible := True;

    for i := 1 to 100 do
    begin
      Button := Panel.Controls.Add( Type:=msoControlButton, ID:=1 );
//      Button.Style := msoButtonIconAndCaption;
      Button.Style := msoButtonIcon;
      Button.Caption := IntToStr( i ); // used in Hint
      Button.FaceId := i;
    end;

    GCExcelServer.Visible := True;
  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActGetExcelIcons

//**************************************************** N_ActExcelDeb1
// Excel Action Debug 1
// (for using in TN_UDAction under Action Name "ExcelDeb1")
//
procedure N_ActExcelDeb1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin

  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActExcelDeb1

//**************************************************** N_ActExcelDeb2
// Excel Action Debug 2
// (for using in TN_UDAction under Action Name "ExcelDeb2")
//
procedure N_ActExcelDeb2( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin

  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActExcelDeb2


//**************** Other Actions

//**************************************************** N_ActCreateGif
// Create GIF file with Transp color
// (for using in TN_UDAction under Action Name "CreateGif")
//
procedure N_ActCreateGif( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  FName: string;
  TmpBMP: TBitmap;
  ImageParams: TN_ImageFilePar;
  RObj: TN_RasterObj;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin
    FName := K_ExpandFileName( CAFName1 );
//    RObj := TN_RasterObj.Create( rtBArray, FName, CAColor1 );
    RObj := TN_RasterObj.Create( rtBArray, FName );
    RObj.SaveRObjToFile( ChangeFileExt( FName, 'b.gif' ), N_FullIRect );
    RObj.Free;
    Exit;

    TmpBMP := N_CreateBMPObjFromFile( FName );
    TmpBMP.SaveToFile( ChangeFileExt( FName, 'a.bmp' ) );
    Exit;

    ImageParams := N_DefImageFilePar;
    ImageParams.IFPTranspColor := CAColor1;
    N_SaveBMPObjToFile( TmpBMP, ChangeFileExt( FName, '.gif' ), @ImageParams );
  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActCreateGif

//**************************************************** N_ActFileActions
// Several file Actions, given in CCAFlags1:
//
//   $1XX - Create File DirContent.txt with file names
//          bit0($101) =1 - skip File Size
//          bit1($102) =1 - Size in bytes, =0 - Rounded size
//          bit2($104) =1 - skip File Date+time
//          bit3($108) =1 - not used
//          bit4($110) =1 - skip File Extention (just to decrease FName size)
//      CAStr1 = File Name pattern (*.* for all files) to include
//
// (for using in TN_UDAction under Action Name "FileActions")
//
procedure N_ActFileActions( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, MaxSize: integer;
  DirName, Spaces: string;
  FAObjList: TObjectList;
  FASL: TStringList;
  UDActionComp: TN_UDAction;
begin
  UDActionComp := TN_UDAction(AP1^);
  N_p := @UDActionComp; // to avoid warning

  with APParams^, UDActionComp.NGCont do
  begin
    if (CAFlags1 and $100) <> 0 then // Create File DirContent.txt with file names
    begin
      DirName := ExtractFileDir( K_ExpandFileName( CAFName1 ) ) + '\';
      FAObjList := N_CreateFilesList( DirName + CAStr1 );
      FASL := TStringList.Create;
      MaxSize := 0;

      for i := 0 to FAObjList.Count-1 do // first loop, collect File Names
      with TN_FileAttribs(FAObjList[i]) do
      begin
        N_s := ExtractFileName( FullName );

        if (CAFlags1 and $010) = $010 then // skip extention
          N_s := ChangeFileExt( N_s, '' );

        FASL.Add( N_s );
        if Length(N_s) > MaxSize then MaxSize := Length(N_s);
      end; // first loop, collect File Names

      Spaces := DupeString( ' ', MaxSize+2 );

      for i := 0 to FASL.Count-1 do // second loop, format and add needed attributes
      with TN_FileAttribs(FAObjList[i]) do
      begin
        // add spaces to make all strings same length
        N_s := FASL[i] + Spaces;
        SetLength( N_s, MaxSize );
        FASL[i] := N_s;

        if (CAFlags1 and $01) <> $01 then // add Size
        begin
          if (CAFlags1 and $02) = $02 then // add precize Size in bytes
            N_s := Format( ' %11.0n', [1.0*BSize] )
          else //**************************** add rounded Size
          begin
            if BSize >= 1.0e6 then
              N_s := Format( '%4d MB', [Round(BSize/1.0e6)] )
            else if BSize >= 1.0e3 then
              N_s := Format( '%4d KB', [Round(BSize/1.0e3)] )
            else if BSize > 0 then
              N_s := Format( '%4d  B', [BSize] )
            else // BSize = 0 means Directory
              N_s := ' DIR   ';
          end;

          FASL[i] := FASL[i] + N_s;
        end; // if (CAFlags1 and $01) <> $01 then // add Size

        if (CAFlags1 and $4) <> $4 then // add Date
        begin
          N_s := K_DateTimeToStr( DTime, 'dd.mm.yyyy(hh:nn:ss)' );
          FASL[i] := FASL[i] + '  ' + N_s;
        end; // if (CAFlags1 and $4) <> $4 then // add Date

        if (CAFlags1 and $05) = $05 then // add hyphen ' -'
          FASL[i] := FASL[i] + ' -';

      end; // for i := 0 to FASL.Count-1 do // second loop, format and add needed attributes

      FASL.SaveToFile( DirName + 'DirContent.txt' );

      FASL.Free;
      FAObjList.Free;
    end;  // $1XX - Create File DirContent.txt with file names

  end; // with APParams^, UDActionComp.NGCont do
end; //*** end of procedure N_ActFileActions

//****************************************************** N_ActListParaBoxes ***
// List all ParaBoxes in given dir in the form of Pascal calls to
//   CreateParaBoxU( AX, AY: double; AText: string ): TN_UDParaBox;
// and put resulting strings to Clipboard
//
// (for using in TN_UDAction under Action Name "ListParaBoxes")
//
procedure N_ActListParaBoxes( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, Code: integer;
  Str, BPUCoordsStr, ParaBoxText, LastPart, CodeStr: string;
  CompCenterUC: TDPoint;
  SetParams: TK_RArray;
  UDBaseDir, CurUObj: TN_UDBase;
  CurParaBox: TN_UDParaBox;
begin
  with APParams^ do
  begin
    UDBaseDir := N_GetUObjByPath( CAUDBase1, CAParStr1 );
    N_SL.Clear;

    for i := 0 to UDBaseDir.DirHigh() do // along UObjects in UDBaseDir
//    for i := 0 to 7 do
    begin
      CurUObj := UDBaseDir.DirChild( i );
      if not (CurUObj is TN_UDParaBox) then Continue;

      CurParaBox := TN_UDParaBox(CurUObj);
      Str := '    CreateParaBoxU( ';

      with CurParaBox.PCCS()^ do
      begin
        //***** Prepare ParaBox Coords

        if BPXCoordsType = cbpUser then // use BPCoords
          CompCenterUC := DPoint( BPCoords )
        else // convert from CompOuterPixRect (почему-то убегает вверх)
          CompCenterUC := N_RectCenter( N_AffConvI2FRect1( CurParaBox.CompOuterPixRect, CurParaBox.CompP2U ) );

        with CompCenterUC do
          BPUCoordsStr := Format( '%f, %f, ''', [X,Y] );

        Str := Str + BPUCoordsStr; // CreateParaBoxU( -13599647.00, -3023236.38,

        //***** Prepare ParaBox Font - not implemented


        //***** Prepare ParaBox Text

        with CurParaBox.PISP()^ do
          ParaBoxText := TN_POneTextBlock(CPBTextBlocks.P(0))^.OTBMText;

        Str := Str + ParaBoxText;

        //***** Prepare LastPart - add SetSelfAngle if needed

        case PixTransfType of
          ctfNoTransform:    LastPart := ''' );';
          ctfRotate90CCW:    LastPart := ''' ).SetSelfAngle( ctfRotate90CCW );';
          ctfRotateAnyAngle: LastPart := Format( ''' ).SetSelfAngle( ctfRotateAnyAngle, %f );', [CCRotateAngle] );
        end; // case PixTransfType of
      end; // with CurParaBox.PCCS()^ do

      Str := Str + LastPart;

      SetParams := CurParaBox.PSP()^.CSetParams;
      if SetParams.ALength() = 1 then
      begin
        CodeStr := TN_POneSetParam(SetParams.P(0))^.SPSrcField;
        if CodeStr <> '' then
        begin
          if CodeStr[1] = '#' then
          begin
            CodeStr := MidStr( CodeStr, 2, 99 );
            Code := N_ScanInteger( CodeStr );

            if (Code <> 0) and (Code <> N_NotAnInteger) then
              Str := Str + Format( ' SetCode( %d );', [Code] );

          end; // if CodeStr[1] = '#' then
        end; // if CodeStr <> '' then
      end; // if SetParams.ALength() = 1 then

      N_SL.Add( Str );
    end; // for i := 0 to UDBaseDir.DirHigh() do // along UObjects in UDBaseDir

    K_PutTextToClipboard( N_SL.Text );

  end; // with APParams^ do
end; //*** end of procedure N_ActListParaBoxes

//******************************************************** N_ActCompsToPas1 ***
// Convert nedded Components to Pascal code, that generate these Components (Var #1)
//   CreateParaBoxU( AX, AY: double; AText: string ): TN_UDParaBox;
// and put resulting strings to Clipboard
//
// Resulting Pacal code is in Windows Clipboard
// (for using in TN_UDAction under Action Name "CompsToPas1")
//
procedure N_ActCompsToPas1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i, Ind, ItemInd, PartInd, NewInd, Code, Code2, CDimInd: integer;
  Str, BPUCoordsStr, ParaBoxText, LastPart, CodeStr, CoordsStr: string;
  CompCenterUC: TDPoint;
  DCoords: TN_DPArray;
  SetParams: TK_RArray;
  UDBaseDir, CurUObj, ULines: TN_UDBase;
  CurParaBox: TN_UDParaBox;
begin
  with APParams^ do
  begin
    // Convert all UDParaBoxes in CAUDBase1\CAParStr1 dir to calls like:
    // CreateParaBoxU( -127.00, -397.00, 'Пермская обл.' ); SetCode( 78 );

    UDBaseDir := N_GetUObjByPath( CAUDBase1, CAParStr1 );
    N_SL.Clear;

    if UDBaseDir <> nil then // CAUDBase1 exists
    for i := 0 to UDBaseDir.DirHigh() do // along UObjects in UDBaseDir
//    for i := 0 to 7 do
    begin
      CurUObj := UDBaseDir.DirChild( i );
      if not (CurUObj is TN_UDParaBox) then Continue;

      CurParaBox := TN_UDParaBox(CurUObj);
      Str := '    CreateParaBoxU( ';

      with CurParaBox.PCCS()^ do
      begin
        //***** Prepare ParaBox Coords

        if BPXCoordsType = cbpUser then // use BPCoords
          CompCenterUC := DPoint( BPCoords )
        else // convert from CompOuterPixRect (почему-то убегает вверх)
          CompCenterUC := N_RectCenter( N_AffConvI2FRect1( CurParaBox.CompOuterPixRect, CurParaBox.CompP2U ) );

        with CompCenterUC do
          BPUCoordsStr := Format( '%f, %f, ''', [X,Y] );

        Str := Str + BPUCoordsStr; // CreateParaBoxU( -13599647.00, -3023236.38,

        //***** Prepare ParaBox Font - not implemented


        //***** Prepare ParaBox Text

        SetParams := CurParaBox.PSP()^.CSetParams;
        if SetParams.ALength() = 2 then  // Old Rus Map
        begin
          with CurParaBox.PIDP()^ do
            ParaBoxText := TN_POneTextBlock(CPBTextBlocks.P(0))^.OTBMText;

          ParaBoxText := StringReplace( ParaBoxText, N_StrCRLF, '<br>', [rfReplaceAll] );
        end else // Fed Okrugs Maps and new Rus Map
        begin
          with CurParaBox.PISP()^ do
            ParaBoxText := TN_POneTextBlock(CPBTextBlocks.P(0))^.OTBMText;
        end;

        Str := Str + ParaBoxText;

        //***** Prepare LastPart - add SetSelfAngle if needed

        case PixTransfType of
          ctfNoTransform:    LastPart := ''' );';
          ctfRotate90CCW:    LastPart := ''' ).SetSelfAngle( ctfRotate90CCW );';
          ctfRotateAnyAngle: LastPart := Format( ''' ).SetSelfAngle( ctfRotateAnyAngle, %f );', [CCRotateAngle] );
        end; // case PixTransfType of
      end; // with CurParaBox.PCCS()^ do

      Str := Str + LastPart;

      SetParams := CurParaBox.PSP()^.CSetParams;
      if SetParams.ALength() >= 1 then
      begin
        if SetParams.ALength() = 1 then Ind := 0  // Fed Okrugs Maps and new Rus Map
                                   else Ind := 1; // Old Rus Map

        CodeStr := TN_POneSetParam(SetParams.P(Ind))^.SPSrcField;
        if CodeStr <> '' then
        begin
          if CodeStr[1] = '#' then
          begin
            CodeStr := MidStr( CodeStr, 2, 99 );
            Code := N_ScanInteger( CodeStr );

            if (Code <> 0) and (Code <> N_NotAnInteger) then
              Str := Str + Format( ' SetCode( %d );', [Code] );

          end; // if CodeStr[1] = '#' then
        end; // if CodeStr <> '' then
      end; // if SetParams.ALength() = 1 then

      N_SL.Add( Str );
    end; // for i := 0 to UDBaseDir.DirHigh() do // along UObjects in UDBaseDir

    N_SL.Add( '' );

    // All UDParaBoxes from CAUDBase1\CAParStr1 dir are converted (if needed),
    // Convert all ULines in CAUDBase1\CAParStr2 to calls like:
    //   RegLineCoords := N_CrDPA( [x1, y1, , xn, yn] );
    //   CurULines.AddSimpleItem( RegLineCoords ); // Усть-Ордынский<br>Бурятский авт. окр.
    //   CurULines.SetItemTwoCodes( 2, CDimInd, 83, -1 );

    ULines := N_GetUObjByPath( CAUDBase1, CAParStr2 );
    CDimInd := 0;
    PartInd := 0;
    NewInd  := 0;

    if ULines is TN_ULines then // ULines exists
    with TN_ULines(ULines) do
    for ItemInd := 0 to WNumItems-1 do // along ULines Itmes
    begin
      GetPartDCoords( ItemInd, PartInd, DCoords );
      if Length( DCoords ) <= 1 then Continue; // skip "empty" lines

      CoordsStr := N_DPArrayToStr( DCoords, ' %7.3f,%7.3f,' );
      CoordsStr[Length(CoordsStr)] := ']'; // replace last ',' by ']'
      Str := '    RegLineCoords := N_CrDPA( [';
      Str := Str + CoordsStr + ' );';
      N_SL.Add( Str ); // Str="RegLineCoords := N_CrDPA( [ 363.506,316.749, 363.506,356.561, 380.836,356.561] );"


      GetItemTwoCodes( ItemInd, CDimInd, Code, Code2 );
      if Code <> -1 then
      begin
        Str := Format( '    CurULines.AddSimpleItem( RegLineCoords, -1, %d ); // Ind=%d', [Code,NewInd] );

//            CurULines.SetItemTwoCodes( %d, CDimInd, %d, %d );',
//                                                       [ItemInd, Code, Code2] );
        N_SL.Add( Str );
      end else
      begin
        Str := Format( '    CurULines.AddSimpleItem( RegLineCoords, -1, -1 ); // Ind=%d', [NewInd] );
        N_SL.Add( Str );
      end;
//        N_SL.Add( '    CurULines.AddSimpleItem( RegLineCoords ); //' );

      Inc( NewInd );
    end; // for ItemInd := 0 to WNumItems-1 do // along ULines Itmes

    K_PutTextToClipboard( N_SL.Text );

  end; // with APParams^ do
end; //*** end of procedure N_ActCompsToPas1

//***************************************************** N_ActToggleSkipSelf ***
// Toggle SkipSelf Flag for some components in CAUDBase1 dir
//
// (for using in TN_UDAction under Action Name "ToggleSkipSelf")
//
procedure N_ActToggleSkipSelf( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  i: integer;
  Pref: string;
  UDBaseDir, CurUObj: TN_UDBase;
begin
  with APParams^ do
  begin
    UDBaseDir := N_GetUObjByPath( CAUDBase1, CAParStr1 );
    Pref := 'ML' + MidStr( CAUDBase1.ObjName, 7, 99 );

    for i := 0 to UDBaseDir.DirHigh() do // along UObjects in UDBaseDir
    begin
      CurUObj := UDBaseDir.DirChild( i );
      if not (CurUObj is TN_UDCompBase) then Continue;

      //***** Skip some Components
      if CurUObj.ObjName = 'RotateCObjects'   then Continue;
      if CurUObj.ObjName = Pref+'NewAllFill'  then Continue;
      if CurUObj.ObjName = Pref+'OldOnlyFill' then Continue;
      if CurUObj.ObjName = 'MLReki'           then Continue;
      if CurUObj.ObjName = Pref+'Goroda1'     then Continue;
      if CurUObj.ObjName = 'MLAllNames'       then Continue;
      if CurUObj.ObjName = 'MLRegNamesLines'  then Continue;

      //***** Toggle CBSkipSelf flag for all other MapLayers
      with TN_UDCompBase(CurUObj).PSP()^ do
        CCompBase.CBSkipSelf := CCompBase.CBSkipSelf xor $01; // Toggle bit0
    end; // for i := 0 to UDBaseDir.DirHigh() do // along UObjects in UDBaseDir
  end; // with APParams^ do
end; //*** end of procedure N_ActToggleSkipSelf

//******************************************************* N_ActUpdateAttrs1 ***
// Update Attributes of some MapLayers in CAUDBase1 dir, var #1
//
// (for using in TN_UDAction under Action Name "UpdateAttrs1")
//
procedure N_ActUpdateAttrs1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  Flags: integer;
  UDBaseDir, CurUObj: TN_UDBase;

  procedure SetSkipSelf( AObjName: string; AValue: integer ); // local
  // Set CBSkipSelf field to given AValue
  begin
    CurUObj := N_GetUObjByPath( UDBaseDir, AObjName );
    with TN_UDCompBase(CurUObj).PSP()^ do
      CCompBase.CBSkipSelf := AValue;
  end; // procedure SetSkipSelf // local

begin
  with APParams^ do
  begin
    Flags     := CAFlags1;
    UDBaseDir := N_GetUObjByPath( CAUDBase1, CAParStr1 );

    if (Flags and $01) = 0 then // set normal params
    begin
      with TN_UDCompVis(UDBaseDir).PCCS()^ do // Map Resolution in DPI
        SrcResDPI := 600;

      // Make Visible
      SetSkipSelf( 'MapLayers\MLFRegsOldAllFill',  0 );
      SetSkipSelf( 'MapLayers\MLFRegsNewOnlyFill', 0 );
      SetSkipSelf( 'MapLayers\MLFOkrBordersOld',   0 );
      SetSkipSelf( 'MapLayers\MLFOkrBordersNew',   0 );

      CurUObj := N_GetUObjByPath( UDBaseDir, 'MapLayers\MLFRegsOldAllStroke' );
      with TN_UDMaplayer(CurUObj).PISP()^ do
        MLPenWidth := 0.5;

      CurUObj := N_GetUObjByPath( UDBaseDir, 'MapLayers\MLFRegsNewOnlyStroke' );
      with TN_UDMaplayer(CurUObj).PISP()^ do
        MLPenWidth := 0.5;

      CurUObj := N_GetUObjByPath( UDBaseDir, 'MapLayers\MLFReki' );
      with TN_UDMaplayer(CurUObj).PISP()^ do
        MLPenWidth := 0.5;

      CurUObj := N_GetUObjByPath( UDBaseDir, 'MapLayers\MLFOzera' );
      with TN_UDMaplayer(CurUObj).PISP()^ do
        MLPenWidth := 0.3;

    end else // set "Fast Drawing" params to fasten RegNames moving
    begin
      with TN_UDCompVis(UDBaseDir).PCCS()^ do // Map Resolution in DPI
        SrcResDPI := 80;

      // Make NOT Visible
      SetSkipSelf( 'MapLayers\MLFRegsOldAllFill',  1 );
      SetSkipSelf( 'MapLayers\MLFRegsNewOnlyFill', 1 );
      SetSkipSelf( 'MapLayers\MLFOkrBordersOld',   1 );
      SetSkipSelf( 'MapLayers\MLFOkrBordersNew',   1 );

      CurUObj := N_GetUObjByPath( UDBaseDir, 'MapLayers\MLFRegsOldAllStroke' );
      with TN_UDMaplayer(CurUObj).PISP()^ do
        MLPenWidth := 0;

      CurUObj := N_GetUObjByPath( UDBaseDir, 'MapLayers\MLFRegsNewOnlyStroke' );
      with TN_UDMaplayer(CurUObj).PISP()^ do
        MLPenWidth := 0;

      CurUObj := N_GetUObjByPath( UDBaseDir, 'MapLayers\MLFReki' );
      with TN_UDMaplayer(CurUObj).PISP()^ do
        MLPenWidth := 0;

      CurUObj := N_GetUObjByPath( UDBaseDir, 'MapLayers\MLFOzera' );
      with TN_UDMaplayer(CurUObj).PISP()^ do
        MLPenWidth := 0;

    end;

  end; // with APParams^ do

{
      CurUObj := N_GetUObjByPath( UDBaseDir, 'MapLayers\MLFRegsOldAllStroke' );
      with TN_UDMaplayer(CurUObj).PISP()^ do
      begin
        MLPenWidth := 0.5;
      end;
}
end; //*** end of procedure N_ActUpdateAttrs1


//**************** Not Actions

//***************************************************** N_CreateMatrConvObj ***
// Create TN_MatrConvObj in UDActionComp.UDActObj1 field and STATIC! CAFPArray field
// using CAIPoint1 and CAFrect as params
//
function N_CreateMatrConvObj( AUDActionComp: TN_UDAction ): integer;
//
var
  NX, NY: integer;
  Str: string;
begin
  with AUDActionComp do
  begin

  UDActObj1.Free;
  UDActObj1 := TN_MatrConvObj.Create;

  with PISP()^, TN_MatrConvObj(UDActObj1) do
  begin
    Str := CAParStr1;
    NX := N_ScanInteger( Str );
    NY := N_ScanInteger( Str );
    Result := SetParams( NX, NY, CAFrect, CAFPArray.P() );
    if Result <> 0 then Exit;

    if CAFPArray = nil then // Create CAFPArray and initialize Matr Values
    begin
      CAFPArray := K_RCreateByTypeCode( Ord(nptFPoint) );
      CAFPArray.ASetLength( MNX, MNY );
      PMatr := PFPoint(CAFPArray.P());
      InitMatr();
    end else // CAFPArray <> nil, check it's dimensions
    begin
      CAFPArray.ALength( NX, NY );
      if (NX <> MNX) or (NY <> MNY) then
      begin
        Result := 10;
        Exit;
      end;

      Result := CheckParams( 1 ); // Check Matr Values
      if Result <> 0 then Exit;
    end; // else // CAFPArray <> nil, check it's dimensions

    Result := 0; // OK flag
  end; // with PISP()^, TN_MatrConvObj(UDActObj1) do

  end // with UDActionComp do
end; // function N_CreateMatrConvObj


end.




