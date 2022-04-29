unit K_CMRFA;
//K_ CMS FRA Actions

interface

uses Windows, Classes, Controls, Types,
  N_Lib0, N_Types, N_Comp1, N_CompBase,
  N_Rast1Fr, N_Comp2, N_SGComp,
  K_CM0, K_CLib0, K_UDT1;

//*************************************************** TK_CMEAddVObj1RFA ***
// Create New Vector Object Raster Frame Action
//
type TK_CMEAddVObj1RFA = class( TN_RFrameAction )
  AddMode        : Integer;
  // 0 - simple Line,
  // 1 - measure Line,
  // 2 - TextBox,
  // 4 - ArrowLine
  // 5 - RectangleLine
  // 6 - EllipseLine
  // 7 - Dot+Text
  LineComp       : TN_UDPolyline;
  ELineComp      : TN_UDPolyline;
  VObjCompRoot   : TN_UDCompVis;
  TextComp       : TN_UDParaBox;
  ShowLengthComp : TN_UDParaBox;
  PrevFPoint     : TFPoint;
  SavedCursorPos : TPoint;
  CurPointInd    : integer;
  CreateVObjFlag : Boolean;
  DragSegmentMode: Boolean;
//  LineLength     : Double;
  LineCalibrateFlag : Boolean;
  PolyLineCalibrateFlag : Boolean;
  AllMLineLength  : Double;
  CurSegmLength   : Double;
  STimer          : TN_CPUTimer1;
  CTAUseMode      : Integer;
  CTASectName     : string;
  SaveCTAAttrsFlag: Boolean;

  procedure Execute (); override;
end; // type TK_CMEAddVObj1RFA = class( TN_RFrameAction )

//*************************************************** TK_CMEAddVObj2RFA ***
// Create New Vector Object Raster Frame Action
//
type TK_CMEAddVObj2RFA = class( TN_RFrameAction )
  AddMode        : Integer;
  // 0 - Normal Angle,
  // 1 - Free Angle,
  // 2 - continue Free Angle creation
  ArcComp        : TN_UDArc;
  LineComp       : TN_UDPolyline;
  LineComp1      : TN_UDPolyline;
  LineComp2      : TN_UDPolyline;
  LineComp3      : TN_UDPolyline;
  VObjCompRoot   : TN_UDCompVis;
  TextComp       : TN_UDParaBox;
  PrevFPoint     : TFPoint;
  SavedCursorPos : TPoint;
  CurPointInd    : integer;
  CreateVObjFlag : Boolean;
  DragSegmentMode: Boolean;
  LineLength     : Double;
  TextBasePoint  : TFPoint;
  STimer         : TN_CPUTimer1;
  MouseDownCMKShift: TShiftState;

  procedure Execute (); override;
end; // type TK_CMEAddVObj2RFA = class( TN_RFrameAction )

//*************************************************** TK_CMEMoveVObjRFA ***
// Move Vector Object Raster Frame Action
//
type TK_CMEMoveVObjRFA = class( TN_RFrameAction )
  SavedCursorFPoint: TFPoint;
  SavedCursorPos  : TPoint;
  SavedFPixPoint  : TFPoint;
  SavedFFPoint    : TFPoint;
  SavedFPoint     : TFPoint;
  LineComp        : TN_UDPolyline;
  LineComp1       : TN_UDPolyline;
  LineComp2       : TN_UDPolyline;
  LineComp3       : TN_UDPolyline;
  MovedComp       : TN_UDCompVis;

  PrevTextComp    : TN_UDParaBox;
  NextTextComp    : TN_UDParaBox;
  AllTextComp     : TN_UDParaBox;
  PrevFPoint      : TFPoint;
  NextFPoint      : TFPoint;
  CompPixRect     : TRect;
  CompFRect       : TFRect;
  PrevSegmLength,
  NextSegmLength  : Double;

  TextComp        : TN_UDParaBox;
  ArcComp         : TN_UDArc;
  TextBasePoint   : TFPoint;
  MeasureRoot     : TN_UDBase;

  MoveObjMode     : Boolean;
  MovePointMode   : Boolean;
  SelectedVertInd : Integer;
  LineLength      : Double;

  MoveMode        : Integer; //  0 - Polyline
                             //  1 - Normal Angle
                             //  2 - Free Angle
                             //  3 - Rect or Ellipse
                             //  4 - Arrow
                             //  5 - Rectangle Line
                             //  6 - Ellipse Line
                             //  7 - Dot
  CreateVObjMode  : Integer; // -2 - ???
                             // -1 - creation was done
                             //  0 - creation is not needed
                             //  1 - Rectangle Creation Mode
                             //  2 - Ellipse Creation Mode
                             //  3 - Arrow Creation Mode
                             //  4 - Ellipse FlashLight Creation Mode
                             //  5 - Rectangle FlashLight Creation Mode
                             //  6 - Rectangle Line Creation Mode

/////////////////////////////////////////
// Image Scroll Mode Control
//
  ImageScrollMode      : Boolean; // Image Scroll Mode is Started

/////////////////////////////////////////
// Change Image BriCo Attrs
//
  BriCoModeStart       : Boolean; // BriCo Change or Pan Mode Start Flag
  BriCoCursorStartPos  : TPoint;
  BriCoMode            : Boolean; // BriCo Change Mode is Started
  BriCoLSF             : TK_LineSegmFunc;
  BriCoVCAttrs         : TK_CMSImgViewConvData;
  BriCoBriPosIni       : Integer;
  BriCoCoPosIni        : Integer;


  AfterFlashLightCreationMode : Boolean;
  VObjPatName : string;
  DragSegmentMode : Boolean;

  SkipNextMouseDown : Boolean;

  PCDIBRect: TN_PCDIBRect;
  PrevScaleFactor : Float;

  procedure BriCoRedraw( ASlide : TN_UDCMSlide; ARFrame : TN_Rast1Frame;
                         APImgViewConvData: TK_PCMSImgViewConvData );
  procedure BriCoMouseMoveRedraw();
  procedure Execute (); override;
end; // type TK_CMEMoveVObjRFA = class( TN_RFrameAction )


//*************************************************** TK_CMEIsodensityRFA ***
// Get Current Image Color for Isodensity Effect Raster Frame Action
//
type TK_CMEIsodensityRFA = class( TN_RFrameAction )
  SkipNextMouseDown : Boolean;
  LastCMKShift: TShiftState;  // Current Mouse and Keyboard Shift State

  procedure Execute (); override;
end; // type TK_CMEIsodensityRFA = class( TN_RFrameAction )

//**************************************************** TK_CMERubberRectRFA ***
// Get Current Image Color for Isodensity Effect Raster Frame Action
//
type TK_CMERubberRectRFA = class( TN_RubberRectRFA )
  procedure Execute (); override;
end; // type TK_CMERubberRectRFA = class( TN_RubberRectRFA )

//*************************************************** TK_CMEFlashLightModeRFA ***
// Flash Light Raster Frame Action
//
type TK_CMEFlashLightModeRFA = class( TN_RFrameAction ) // CMFlashLightRFrame Action
  CMEFLComp: TN_UDCompVis;
  WCursor : TCursor;

  procedure MouseMoveRedraw();
  procedure HideFlashlight( ARedrawFlag : Boolean );
  procedure Execute      (); override;
end; // type TK_CMEFlashLightModeRFA = class( TN_RFrameAction )

var
K_CMAddDotCapt : string;

implementation


uses SysUtils, Dialogs, Math, Forms,
   N_Gra0, N_Gra1, N_Lib1, N_CM1, N_CMREd3Fr, N_CMMain5F, N_CMResF, N_CompCL,
   N_ClassRef, N_BrigHist2F,
   K_Types, K_VFunc, K_Script1, K_FCMSCalibrate, K_FCMSTextAttrs, K_FCMSIsodensity,
   K_FCMSFlashlightModeAttrs, K_CML1F;

{ *** TK_CMEAddVObj1RFA *** }

//*********************************************** TK_CMEAddVObj1RFA.Execute ***
// Simple or Measure Line, TextBox, Arrow, Rectangle, Ellipse, Dot+Text Creation Action execute
//
procedure TK_CMEAddVObj1RFA.Execute;
var
  VObjPatName: string;
  PCurFPoint: PFPoint;
  NewFPoint: TFPoint;
  ShiftPixPoint: TPoint;
  ACapt: string;
  // AObjActType : TK_CMSlideHistEdVOAct;
  AObjType: TK_CMSlideHistVObjType;
  AObjAct : Byte;
  MouseInsideImage: Boolean;
  LargeMouseShift: Boolean;
  LCBuf: TPoint;
  FinFreeHandSegment: Boolean;
  EscapeClickEventFlag : Boolean;
  EmptyTextFlag : Boolean;
  EditTextResult : Boolean;
  EditTextAttrsFlag : Boolean;
  CTASourceSectName : string;
  SlidePixHeight  : Integer;
  SlidePixWidth   : Integer;
  WCursor : TCursor;
  NP : TK_NotifyProc;

  procedure AddToLog(AStr: string; AShowCBuf: Boolean = false);
  begin
    if not(cmpfVObjMain in N_CM_LogFlags) then
      Exit;
    if AShowCBuf then
      AStr := AStr + format(' X,Y=%d,%d', [LCBuf.X, LCBuf.Y]);
    if not ActEnabled then
      AStr := AStr + ' ActDisabled';

    N_Dump2Str(ActGroup.RFrame.Parent.Name + '.' + ActName + ': ' + AStr);
  end; // procedure AddToLog

  procedure FinishPolylineCreation();
  label RemoveLine;
  var
    InterimTextsDisplayMode : Integer;
    SetDisplayModeFlag : Boolean;
  begin
    // Set Fin Creation Mode
    CreateVObjFlag := false;
    FreeAndNil(STimer);

    with ActGroup, RFrame, TN_CMREdit3Frame(Parent) do
    begin
      // Finish Current Line Creation
      if CurPointInd = 1 then
      begin
        // Empty Line - Remove Current Object
RemoveLine :
        ChangeSelectedVObj(0);
        with VObjCompRoot.Owner do
          RemoveDirEntry(DirHigh); // Remove Empty Line
        RedrawAllAndShow();
        N_CM_MainForm.CMMFShowString('');
        VObjCompRoot := nil;
        AddToLog('Remove Empty Line Object');
      end   // if CurPointInd = 1 then
      else
      begin // if CurPointInd <> 1 then
        // Finish Current Line Creation
        AObjAct := Ord(K_shVOActAdd);

        if (AddMode <> 5) and (AddMode <> 6) then
        // Remove Last Point
          with LineComp.PSP.CPolyline.CPCoords do
            DeleteElems(CurPointInd);

        if AddMode = 4 then
        begin // Arrow
          ACapt := N_CMResForm.aObjArrowLine.Caption;
          AObjType := K_shVOTypeArrow;
        end // if AddMode = 4 then
        else
        begin // if AddMode <> 4 then // not Arrow
          if AddMode = 1 then
          begin // Measure Line
            // Measure Line Processing
            if ShowLengthComp <> nil then
              VObjCompRoot.DeleteOneChild(ShowLengthComp);
            if CurPointInd = 2 then
              // Single Segment Line
              with VObjCompRoot do
                RemoveDirEntry(DirHigh) // Remove Last TextBox
            else
              begin
                // MultiSegment Line
                // Set Line Length Text Box Position
                with TextComp.PSP^, CCompBase,
                  TN_POneTextBlock(CParaBox.CPBTextBlocks.P())^,
                  CCoords.BPCoords do
                begin
                  X := PrevFPoint.X;
                  Y := PrevFPoint.Y;
                  CBSkipSelf := 0;
                  // Build Segment Lehth Text
                  // with TN_CMREdit3Frame(ActGroup.RFrame.Parent).EdSlide do
                  // OTBMText := '= ' + DistMM2UnitsText( LineLength );
                end;
              end;
            // Rebuld Line Texts
            EdSlide.RebuildMLineTexts(VObjCompRoot);

            with VObjCompRoot do
              K_CMSVObjTextPosRebuild(RFrame, TN_UDCompVis(DirChild(DirHigh)),
                [cmtpfSkipStartRedraw, cmtpfSkipFinalShow]);

            ACapt := N_CMResForm.aObjPolylineM.Caption;
            AObjType := K_shVOTypeMeasureLine;
          end // if AddMode = 1 then // Measure Line
          else if AddMode = 0 then
          begin // PolyLine
            ACapt := N_CMResForm.aObjPolyline.Caption;
            AObjType := K_shVOTypePolyLine;
          end
          else if AddMode = 5 then
          begin // RectangleLine
            ACapt := N_CMResForm.aObjRectangleLine.Caption;
            AObjType := K_shVOTypeRect;
          end
          else if AddMode = 6 then
          begin // EllipseLine
            ACapt := N_CMResForm.aObjEllipseLine.Caption;
            AObjType := K_shVOTypeEllipse;
          end
          else
          begin // FreeHandLine
            ACapt := N_CMResForm.aObjFreeHand.Caption;
            AObjType := K_shVOTypeFreeHand;
          end;


          if LineCalibrateFlag and
             ((CurPointInd = 2) or PolyLineCalibrateFlag) then
          begin
  //          LineCalibrateFlag := false;
            N_Dump1Str( 'Start Calibrate Dlg' );
            if not K_CMSlideCalibrateDlg(VObjCompRoot, PolyLineCalibrateFlag ) then
              goto RemoveLine;
            if PolyLineCalibrateFlag then
              ACapt := N_CMResForm.aObjCalibrateN.Caption
            else
              ACapt := N_CMResForm.aObjCalibrate1.Caption;
            AObjAct := Ord(K_shVOActCalibrate);
            ImgClibrated.Visible := TRUE;
  {
          CMMFFinishVObjEditing( aObjCalibrate.Caption,
              K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAVOObject),
                        Ord(K_shVOActCalibrate),
                        Ord( K_shVOTypeMeasureLine ) ) );
  }
          end; // if LineCalibrateFlag and ((CurPointInd = 2) or PoyLineCalibrateFlag) then


          // Check MLine Texts Display Mode
          if not LineCalibrateFlag then
          begin
            InterimTextsDisplayMode := K_CMGetMLineInterimTextsDisplayMode( VObjCompRoot );
            if InterimTextsDisplayMode >= -1 then
            begin
              SetDisplayModeFlag := FALSE;
              N_CM_MainForm.CMMSetMUFRectByActiveFrame();
              if InterimTextsDisplayMode >= 0 then
                 SetDisplayModeFlag := mrYes =
                   K_CMShowMessageDlg( K_CML1Form.LLLObjEdit1.Caption,
//                     'Display interim measurements?',
                                       mtConfirmation, [], TRUE);
              N_CM_MainForm.CMMRestoreMUFRect();
              K_CMSetMLineInterimTextsDisplayMode( VObjCompRoot, SetDisplayModeFlag );
            end; // if InterimTextsDisplayMode >= -1 then
          end; // if not LineCalibrateFlag then
        end; // // if AddMode <> 4 then // not Arrow

        N_CM_MainForm.CMMFFinishVObjEditing(ACapt,
          K_CMEDAccess.EDABuildHistActionCode(K_shATChange,
            Ord(K_shCAVOObject), AObjAct, Ord(AObjType)));
//            Ord(K_shCAVOObject), Ord(K_shVOActAdd), Ord(AObjType)));
        AddToLog('Finish ' + LineComp.ObjName + ' Creation');
      end; // if CurPointInd <> 1 then

      N_CM_MainForm.CMMFDisableActions(nil);

      if (AddMode = 6) and (VObjCompRoot <> nil) then
      // Clear EllipseLine Selection for SearchList correction
        ChangeSelectedVObj( 0 );

      if (EdViewEditMode <> cmrfemPoint) and
         (RFrame.Parent = N_CM_MainForm.CMMFActiveEdFrame) then
        N_CMResForm.aEditPointExecute(nil)
      else
      begin
        N_SetMouseCursorType(RFrame, crDefault);
        RebuildVObjsSearchList(); // After Finish Lines Creation (if skiped aEditPointExecute)
      end;

      if (AddMode = 6) and (VObjCompRoot <> nil) then
      // Rebuild EllipseLine Selection - for SearchList correction
        ChangeSelectedVObj( 1, VObjCompRoot );

      LineCalibrateFlag := FALSE;
      PolyLineCalibrateFlag := FALSE;
    end; // with ActGroup, RFrame, TN_CMREdit3Frame(Parent) do
  end; // procedure FinishPolylineCreation();

begin

  inherited;

  with ActGroup, RFrame, TN_CMREdit3Frame(Parent) do
  begin
    if EdViewEditMode <> cmrfemCreateVObj1 then
    begin
      // Close Self Activity
      N_Dump2Str(RFrame.Parent.Name + '.' + ActName + ': Self Disabled');
      Self.ActEnabled := false;
      if CreateVObjFlag then
        FinishPolylineCreation();
      // RebuildVObjsSearchList( ); // After Finish Lines Creation
      Exit;
    end;


    // Str := Format( 'X,Y = %d, %d', [CCBuf.X,CCBuf.Y] );

    LCBuf := CCBuf;
    with CCBuf, RFLogFramePRect do
      MouseInsideImage := (X >= 0) and (X <= Right) and (Y >= 0) and
        (Y <= Bottom);
    EscapeClickEventFlag := (CHType = htKeyDown) and (CKey.CharCode = VK_Escape);

    WCursor := crDefault;
    if MouseInsideImage then
      case AddMode of
        0:
          WCursor := crCreateNormLine;    // Simple Line
        1:
          WCursor := crCreateMeasureLine; // Measure Line
        2:
          WCursor := crCreateText;        // TextBox
        3:
          WCursor := crCreateFreeHand;    // Free Hand
        4:
          WCursor := crCreateArrow;       // Arrow Line
        5:
          WCursor := crCreateRect;        // Rectangle Line
        6:
          WCursor := crCreateEllipse;     // Ellipse Line
        7:
          WCursor := crCreateDot;         // Dot
      end;

    if (WCursor <> crDefault) and
        not CreateVObjFlag    and
        EscapeClickEventFlag then
    begin
      // Skip Creation Mode
      N_CMResForm.aEditPointExecute(nil);
      N_CM_MainForm.CMMFShowString( '' );
      Exit;
    end;

    if RFrame.Cursor <> WCursor then
      N_SetMouseCursorType(RFrame, WCursor);

    if (WCursor = crDefault) and CreateVObjFlag then
    begin
      // Out of Image in Creation Mode
      CreateVObjFlag := not
        (((CHType = htMouseDown) and (ssLeft in CMKShift) and
            (ssDouble in CMKShift)) or EscapeClickEventFlag);
      if not CreateVObjFlag then
      begin
        // EdMoveVObjRFA.SkipNextMouseDown := (CHType = htMouseDown);
        K_CMSPCAddVObjEvent('OutOf Img??? or Escape', Self);

        FinishPolylineCreation();
        Exit; // Out of Image
      end;
    end;

    if not CreateVObjFlag then
    begin
      // Try to Create Line Measurement
      CreateVObjFlag := (CHType = htMouseDown) and
                        (CMButton = mbLeft)    and
                        MouseInsideImage;
      if CreateVObjFlag then
      begin
        // Start create Line(Annot/Measure)|Text
        AllMLineLength := 0;
        CurSegmLength := 0;
        K_CMSPCAddVObjEvent('Start Obj', Self);
        case AddMode of
          0:
            VObjPatName := 'Line'; // Simple Line
          1:
            VObjPatName := 'MLine'; // Measure Line
          2:
            VObjPatName := 'Text'; // TextBox
          3:
            VObjPatName := 'HLine'; // FreeHand Line
          4:
            VObjPatName := 'ArrowL'; // Arrow Line
          5:
            VObjPatName := 'RectL'; // Rectangle Line
          6:
            VObjPatName := 'EllipseL'; // Ellipse Line
          7: begin
            VObjPatName := 'Dot'; // Dot
//            if K_CMAddDotCapt <> '' then
//              VObjPatName := 'DoF'; // Dot
          end;
        end;
        VObjCompRoot := EdSlide.AddNewMeasurement(VObjPatName);

        ChangeSelectedVObj(1, VObjCompRoot);
        AddToLog('Create ' + VObjPatName, TRUE);

        SavedCursorPos := CCBuf;
        PrevFPoint := N_AffConvF2FPoint( FPoint(SavedCursorPos),
                                         EdSlide.GetMapRoot.CompP2U );
        with EdSlide.P.CMSDB do
        begin
          SlidePixHeight := PixHeight;
          SlidePixWidth := PixWidth;
        end;

        if AddMode = 2 then
        begin
          // TexBox Creation
          CreateVObjFlag := false;
          VObjCompRoot.PSP.CCoords.BPCoords := PrevFPoint;

          EditTextAttrsFlag := TRUE;
          SaveCTAAttrsFlag := FALSE;
          CTASourceSectName := CTASectName;
          if (CTAUseMode and 1) = 1 then
            CTASourceSectName := 'G' + CTASectName;
          if (CTAUseMode > 0) and (CTAUseMode < 100) then
          begin
            SaveCTAAttrsFlag := K_CMVobjTextAttrsFromMemIni( CTASourceSectName, VObjCompRoot, SlidePixHeight );
            EditTextAttrsFlag := FALSE;
          end;

// to hide FontRSize functionality
          K_CMVobjSetFontSizeAuto( VObjCompRoot, SlidePixHeight );

          EditTextAttrsFlag := EditTextAttrsFlag or (ssShift in CMKShift); // actual for CTA

          K_CMSVObjTextPosRebuild(RFrame, VObjCompRoot, [cmtpfVertCenter,cmtpfHorCenter]);

          EditTextResult := FALSE;
          EmptyTextFlag  := FALSE;
          if EditTextAttrsFlag then
          begin
            EditTextResult := K_CMSlideTextAttrsDlg(RFrame, EmptyTextFlag, FALSE, VObjCompRoot);
            if not EditTextResult or EmptyTextFlag then
            begin
              AddToLog('Remove ' + VObjCompRoot.ObjName + ' by user');
              DeleteVObjSelected(false);
//              if EmptyTextFlag and (CTAUseMode = 2)then
//                N_CurMemIni.EraseSection( CTASection ); // Remove Self Created Text Annotation
            end
            else
            begin // if EditTextResult and not EmptyTextFlag then
            // New Text Attributes are set
              K_CMSVObjTextPosRebuild(RFrame, VObjCompRoot,
                [cmtpfSkipStartRedraw, cmtpfSkipFinalShow]);

              if CTAUseMode > 0 then
              begin
                SaveCTAAttrsFlag := FALSE;
                if K_CMVobjCTAAttrsToMemIni( CTASectName, CTASourceSectName, VObjCompRoot, FALSE ) then
                   N_CM_MainForm.CMMUpdateUIByCTA();
              end;
            end;
          end; // if EditTextAttrsFlag then

          if SaveCTAAttrsFlag and
             (CTAUseMode > 0) and
             K_CMVobjCTAAttrsToMemIni( CTASectName, CTASourceSectName, VObjCompRoot, FALSE ) then
            N_CM_MainForm.CMMUpdateUIByCTA();

          // New Text Attributes are set or CTA is used without changing
          if (EditTextResult and not EmptyTextFlag) or (CTAUseMode > 0) then
          begin // Text Annotation is created
            N_CM_MainForm.CMMFFinishVObjEditing( N_CMResForm.aObjTextBox.Caption,
              K_CMEDAccess.EDABuildHistActionCode( K_shATChange,
                Ord(K_shCAVOObject), Ord(K_shVOActAdd), Ord(K_shVOTypeText) ) );

            AddToLog( 'Finish ' + VObjCompRoot.ObjName + ' Creation' );
          end;

          CTAUseMode := 0; // Clear CTA UseMode

          N_CMResForm.aEditPointExecute(nil);
        end    // if AddMode = 2 then
        else
        begin  // if AddMode <> 2 then
          // Lines Creation
          if STimer = nil then
            STimer := TN_CPUTimer1.Create;
          STimer.Start;
          DragSegmentMode := TRUE;
          K_CMSVObjSetDefaultAttrs(VObjCompRoot);

          LineComp := TN_UDPolyline(VObjCompRoot.DirChild(1));
          TextComp := TN_UDParaBox(VObjCompRoot.DirChild(2));

          if AddMode = 6 then
          begin
            ELineComp := LineComp;
            LineComp := TN_UDPolyline(TextComp);
            TextComp := nil;
          end
          else
          if AddMode = 4 then
          begin
            LineComp := TN_UDPolyline(TextComp);
            TextComp := nil;
          end
          else
          begin // if AddMode = 0 or 1 or 3 or 5 or 7
            if TextComp <> nil then
              K_CMVobjSetFontSizeAuto( TextComp, EdSlide.P()^.CMSDB.PixHeight );
//              EdSlide.SetTextFontAttrs(TextComp);

            if AddMode = 1 then
            begin
              ShowLengthComp := TN_UDParaBox(K_CMSAddCloneChild( VObjCompRoot,
                                                   TextComp, false, EdSlide ));
            end
          end; // if AddMode = 0 or 1 or 3 or 5

          PrevFPoint.X := PrevFPoint.X + 100;
          PrevFPoint.Y := PrevFPoint.Y + 100;
          NewFPoint := PrevFPoint;
          with LineComp.PSP.CPolyline.CPCoords do
          begin
            PFPoint(P(0))^ := PrevFPoint;
            PFPoint(P(1))^ := NewFPoint;
          end;

          if AddMode = 7 then
          begin // Dot annotation
            CreateVObjFlag := false;
//            with TextComp.PSP^, CCompBase, CCoords, CParaBox,
//                 TN_PNFont(K_GetPVRArray(TN_POneTextBlock(CPBTextBlocks.P()).OTBNFont).P())^ do
            begin
              // Set Font Attrs
              K_CMVobjSetFontSizeAuto( TextComp, SlidePixHeight );


              if K_CMAddDotCapt = '' then
                EditTextResult := K_CMSlideTextAttrsDlg(RFrame, EmptyTextFlag, FALSE,
                                                        TextComp, VObjCompRoot)
              else
              with TN_POneTextBlock(TextComp.PSP.CParaBox.CPBTextBlocks.P())^ do
              begin
                EditTextResult := TRUE;
                EmptyTextFlag := FALSE;
                OTBMText := K_CMAddDotCapt;
              end;

              if not EditTextResult or EmptyTextFlag then
              begin
                AddToLog('Remove ' + VObjCompRoot.ObjName + ' by user');
                DeleteVObjSelected(false);
              end
              else
              begin // Text Annotation is created
                // Set Text Rect Base Point to BottomLeft corner
                K_CMVobjInitDotTextPos( TextComp, PrevFPoint.X, PrevFPoint.Y,
                                        SlidePixWidth, SlidePixHeight );
                N_CM_MainForm.CMMFFinishVObjEditing( N_CMResForm.aObjDot.Caption,
                  K_CMEDAccess.EDABuildHistActionCode( K_shATChange,
                    Ord(K_shCAVOObject), Ord(K_shVOActAdd), Ord(K_shVOTypeDot) ) );

                AddToLog( 'Finish ' + VObjCompRoot.ObjName + ' Creation' );
              end;
            end; // with TextComp.PSP^, CCoords, CParaBox ... do
            K_CMAddDotCapt := '';
            N_CMResForm.aEditPointExecute(nil);
          end  // end Dot annotation
          else
          begin // if (AddMode <> 2) and (AddMode <> 7)
            // Lines And other stretched annontations
            // Start First Segment Edit
            CurPointInd := 1;
            ACapt := K_CML1Form.LLLObjEdit14.Caption; //'Mouse Double Click or Escape to finish Polyline creation';
            if (AddMode = 5) or (AddMode = 6) then
            begin
              if AddMode = 6 then
                ACapt := K_CML1Form.LLLObjEdit15.Caption  //'Mouse Up/Click to finish Elipse creation'
              else
                ACapt := K_CML1Form.LLLObjEdit16.Caption; //'Mouse Up/Click to finish Rectangle creation';
              CurPointInd := 2;
              with LineComp.PSP.CPolyline.CPCoords do
              begin
                PFPoint(P(2))^ := NewFPoint;
                PFPoint(P(3))^ := NewFPoint;
                PFPoint(P(4))^ := NewFPoint;
              end;
            end // if (AddMode = 5) or (AddMode = 6) then
            else
            if AddMode = 4 then
              ACapt := K_CML1Form.LLLObjEdit17.Caption
  //              'Mouse Up/Click to finish Arrow Line creation'
            else
            if AddMode = 3 then
              ACapt := K_CML1Form.LLLObjEdit18.Caption
  //              'Mouse Up/Click or Escape to finish Free Hand Line creation'
            else if LineCalibrateFlag then
              ACapt := K_CML1Form.LLLObjEdit19.Caption;
  //              'Mouse Double Click or Escape/Del to finish calibration';
            N_CM_MainForm.CMMFShowString(ACapt);
            RedrawAllAndShow();
          end;
        end; // if AddMode <> 2 then
      end; // if CreateVObjMode then
    end
    else
    begin // Creation Mode
      // Line Measurement Creation Mode
      K_CMSPCAddVObjEvent('Continue ', Self);
      if (CHType <> htMouseUp) and (CHType <> htMouseMove) then
      begin
        // Check Finish PolylineLine Cretaion Event - not MouseUP and MouseMove events
        CreateVObjFlag := not
          (((CHType = htMouseDown) and (ssLeft in CMKShift) and
              (ssDouble in CMKShift)) or EscapeClickEventFlag);
        if not CreateVObjFlag then
        begin
          // EdMoveVObjRFA.SkipNextMouseDown := (CHType = htMouseDown);
          if EscapeClickEventFlag and
             ((AddMode = 5) or (AddMode = 6)) then
            CurPointInd := 1;

          FinishPolylineCreation();
          Exit;
        end;
      end;

      LargeMouseShift := (Abs(SavedCursorPos.X - CCBuf.X) > 4) or
                         (Abs(SavedCursorPos.Y - CCBuf.Y) > 4);
      if (CHType = htMouseUp) then
        DragSegmentMode := (STimer.CurSeconds > 0.4);
      if (((CHType = htMouseUp) and DragSegmentMode) or
          ((CHType = htMouseDown) and not DragSegmentMode)) and
        (LargeMouseShift or (AddMode = 3) or (AddMode = 5)) then
      begin

        if (AddMode = 3) or (AddMode = 5) or (AddMode = 6) then
        begin
          // Finish FreeHand Line Current Segment
          FinishPolylineCreation();
          Exit;
        end;

        // Finish PolyLine Current Segment
        AddToLog('Finish Segment', TRUE);
        SavedCursorPos := CCBuf;

        // Get Last Point Position
        PCurFPoint := LineComp.PSP.CPolyline.CPCoords.P(CurPointInd);
        NewFPoint := PCurFPoint^;
        DragSegmentMode := not DragSegmentMode;

        STimer.Start;
        if AddMode = 1 then
        begin
          // Measure Needed Processing
          // Calñulate Last Segment Length
          // Add New Text Box
          TextComp := TN_UDParaBox(K_CMSAddCloneChild(VObjCompRoot, TextComp,
              false, EdSlide));
          TextComp.PSP.CCompBase.CBSkipSelf := 1;
          AllMLineLength := AllMLineLength + CurSegmLength;
        end; // if MeasureLineFlag

        // Prepare Next Segment Add Context
        PrevFPoint := NewFPoint;

        // Add New Point
        with LineComp.PSP.CPolyline.CPCoords do
        begin
          InsertElems();
          Inc(CurPointInd);
          PFPoint(P(CurPointInd))^ := NewFPoint;
        end;

        // if LineCalibrateFlag   and
        // (CurPointInd = 2) and
        // CreateVObjMode {to prevent Finish if Cancel} then begin

        if (AddMode = 4) or
           ( LineCalibrateFlag        and
             not PolyLineCalibrateFlag and
             (CurPointInd = 2) ) then
        begin
          // Calibration or Arrow
          FinishPolylineCreation();
          Exit;
        end
        else
          RedrawAllAndShow();
      end
      else if CHType = htMouseMove then
      begin
        // Move Segment End Point
        with LineComp do
        begin
          ShiftPixPoint := CCBuf;
          with ShiftPixPoint, RFLogFramePRect do
            if not MouseInsideImage then
            begin
              X := Max(0, X);
              X := Min(Right, X);
              Y := Max(0, Y);
              Y := Min(Bottom, Y);
            end;

          PCurFPoint := PFPoint(PISP()^.CPCoords.P(CurPointInd));
          NewFPoint := N_AffConvF2FPoint(FPoint(ShiftPixPoint),
            UDPFromBufPixCoefs4);
          FinFreeHandSegment := (AddMode = 3) and
            (PInt64(PCurFPoint)^ <> PInt64(@NewFPoint)^);
          PCurFPoint^ := NewFPoint;

          if FinFreeHandSegment then
            // FreeHand Line NewSegment
            with LineComp.PSP.CPolyline.CPCoords do
            begin
              InsertElems();
              Inc(CurPointInd);
              PFPoint(P(CurPointInd))^ := NewFPoint;
            end
          else
          if (AddMode = 5) or (AddMode = 6) then
          begin
          // Rebuild Rectangle
            K_CMSVObjRectRebuildByPoint( LineComp, PCurFPoint, 2 );
            if AddMode = 6 then
              K_CMSVObjEllipseRebuildByOuterRect( ELineComp, LineComp );
          end;

          if AddMode = 4 then
          begin
          // Rebuild Arrow Line
            LargeMouseShift := (Abs(SavedCursorPos.X - CCBuf.X) > 4) or
                               (Abs(SavedCursorPos.Y - CCBuf.Y) > 4);
            if LargeMouseShift then
            begin
              K_CMSVObjArrowTipLineRebuild( LineComp, K_CMArrowLineTipSize * RFVectorScale );
            end;
          end;

          if AddMode = 1 then
          begin
            CurSegmLength := EdSlide.CalcMMDistance(PrevFPoint, NewFPoint);
            // Set Segment TextBox Attributes
{
// !!! Temporary opened code before next not production build
            with TextComp.PSP^, CCompBase,
              TN_POneTextBlock(CParaBox.CPBTextBlocks.P())^,
              CCoords.BPCoords do
            begin
              X := (PrevFPoint.X + NewFPoint.X) / 2;
              Y := (PrevFPoint.Y + NewFPoint.Y) / 2;
              {
                if ( (Abs(SavedCursorPos.X - CCBuf.X) > 4) or
                (Abs(SavedCursorPos.Y - CCBuf.Y) > 4) ) then
              }
//              if LargeMouseShift then
//              begin
//                CBSkipSelf := 0;
//              end;
              // else
              // CBSkipSelf := 1;
              // Build Segment Lehth Text
//              OTBMText := EdSlide.DistMM2UnitsText(CurSegmLength);
//            end;
//            K_CMSVObjTextPosRebuild(RFrame, TextComp, [cmtpfSkipFinalShow]);
// !!! End of temporary opened code before next not production build
//}

            with TextComp.PSP^,
              CCoords.BPCoords do
            begin
              X := (PrevFPoint.X + NewFPoint.X) / 2;
              Y := (PrevFPoint.Y + NewFPoint.Y) / 2;
            end;

            with ShowLengthComp.PSP^, CCompBase,
              TN_POneTextBlock(CParaBox.CPBTextBlocks.P())^,
              CCoords.BPCoords do
            begin
              X := NewFPoint.X;
              Y := NewFPoint.Y;
              OTBMText := '= ' + EdSlide.DistMM2UnitsText(AllMLineLength + CurSegmLength);
              if LargeMouseShift then
                CBSkipSelf := 0;
            end;
            K_CMSVObjTextPosRebuild(RFrame, ShowLengthComp, [cmtpfSkipFinalShow]);
          end; // if AddMode = 1 then

          // Redraw All and Show with and without K_CMRedrawObject
          if K_CMSkipMouseMoveRedraw > 0 then
          begin
            NP := RedrawAllAndShow;
            with K_CMRedrawObject do
            begin
              if not Assigned(OnRedrawProcObj) or
                 (TMethod(NP).Code <> TMethod(OnRedrawProcObj).Code) then
//                 not CompareMem( @OnRedrawProcObj, @NP, SizeOf(TNotifyEvent) ) then
                InitRedraw( RedrawAllAndShow );

              // Value of TK_NotifyProc RedrawAllAndShow is the same for different instances of TK_CMEAddVObj1RFA
              // (Different Instances TK_CMEAddVObj1RFA are because of each instance of TN_CMREdit3Frame has own instance of TK_CMEAddVObj1RFA)
              //
              // Need to set OnRedrawProcObj each time because assignment of K_CMRedrawObject.OnRedrawProcObj leads to
              // to call RedrawAllAndShow of needed instance of TK_CMEAddVObj1RFA in K_CMRedrawObject.Redraw()
              // K_CMRedrawObject.InitRedraw was not used because it reset K_CMRedrawObject redraw context
              OnRedrawProcObj := RedrawAllAndShow;

              if not MouseUpCheck() then
                OnCheckDirectRedraw := MouseUpCheck
              else
                OnCheckDirectRedraw := SkipDirectRedraw;

              Redraw();
            end;
          end // if K_CMSkipMouseMoveRedraw > 0 then
          else
            RedrawAllAndShow();
        end; // with LineComp do
      end; // if CHType = htMouseMove then
    end; // end of Line Measurement Creation Mode

    // N_CM_MainForm.CMMFShowString( Str );

  end; // with TN_SGComp(ActGroup), OneSR, ActGroup.RFrame do

end;

{ *** end of TK_CMEAddVObj1RFA *** }

{ *** TK_CMEAddVObj2RFA *** }

//*********************************************** TK_CMEAddVObj2RFA.Execute ***
// Normal or Free Angle Creation Action execute
//
procedure TK_CMEAddVObj2RFA.Execute;
var
  VObjPatName: string;
  PCurFPoint: PFPoint;
  NewFPoint: TFPoint;
  WCursor: TCursor;
  FinCreation: Boolean;
  ACapt: string;
  LCBuf: TPoint;
  LargeMouseShift: Boolean;
  MouseInsideImage: Boolean;
  AObjType: TK_CMSlideHistVObjType;
  NP : TK_NotifyProc;

label FinAngleCreation, RemoveAngle;

  procedure AddToLog(AStr: string; AShowCBuf: Boolean = false);
  begin
    if not(cmpfVObjMain in N_CM_LogFlags) then
      Exit;
    if AShowCBuf then
      AStr := AStr + format(' X,Y=%d,%d', [LCBuf.X, LCBuf.Y]);
    if not ActEnabled then
      AStr := AStr + ' ActDisabled';
    N_Dump2Str(ActGroup.RFrame.Parent.Name + '.' + ActName + ': ' + AStr);
  end;

begin

  inherited;

  with ActGroup, RFrame, TN_CMREdit3Frame(Parent) do
  begin
    if EdViewEditMode <> cmrfemCreateVObj2 then
    begin
      // Close Self Activity
      N_Dump2Str(RFrame.Parent.Name + '.' + ActName + ': Self Disabled');
      Self.ActEnabled := false;
      if CreateVObjFlag or (AddMode = 2) then
      begin
        CreateVObjFlag := false;
        AddMode := 0;
        goto RemoveAngle;
      end;
      Exit;
    end;

    LCBuf := CCBuf;
    with CCBuf, RFLogFramePRect do
      MouseInsideImage := (X >= 0) and (X <= Right) and
                          (Y >= 0) and (Y <= Bottom);
    WCursor := crDefault;
    if MouseInsideImage then
      case AddMode of
        0:
          WCursor := crCreateNormAngle; // Normal Angle
        1:
          WCursor := crCreateFreeAngle; // Free Angle First Segment
        2:
          WCursor := crCreateFreeAngle; // Free Angle Last Segment
      end;

    if (WCursor <> crDefault) and
        not CreateVObjFlag    and
        ((CHType = htKeyDown) and
         (CKey.CharCode = VK_Escape)) then
    begin
      // Skip Creation Mode
      N_CMResForm.aEditPointExecute(nil);
      N_CM_MainForm.CMMFShowString( '' );
      Exit;
    end;

    if RFrame.Cursor <> WCursor then
      N_SetMouseCursorType(RFrame, WCursor);

    if WCursor = crDefault then
      Exit; // Out of Image
    if CHType = htMouseDown then
      MouseDownCMKShift := CMKShift;

    if (CHType <> htMouseUp) and (CHType <> htMouseMove) and
      (CreateVObjFlag or (AddMode = 2)) then
    begin
      // Check Object Creation Event - not MouseUP and MouseMove events
      FinCreation := not((CHType = htKeyDown) and
                    ((CKey.CharCode = VK_Escape) or
                     (CKey.CharCode = VK_Delete)));
      if not FinCreation then
      begin
        K_CMSPCAddVObjEvent('RemoveObj', Self);
RemoveAngle:
        FreeAndNil(STimer);
        CreateVObjFlag := false;
        AddMode := 0;
        if (EdVObjSelected <> nil) and (VObjCompRoot = EdVObjSelected) then
        begin // Current Creating Angle VObj is not delete by Delete Action
          ChangeSelectedVObj(0, VObjCompRoot);
          with VObjCompRoot.Owner do
            RemoveDirEntry(DirHigh);
          RedrawAllAndShow();
          AddToLog('Remove just created');
        end
        else
          AddToLog('Just created was already removed ');
        N_CMResForm.aEditPointExecute(nil);
        Exit;
      end;
    end;

    if not CreateVObjFlag then
    begin
      // Try to Create Line Measurement

      CreateVObjFlag := (CHType = htMouseDown) and MouseInsideImage;

      if CreateVObjFlag then
      begin
        // Create Angle Mode
        K_CMSPCAddVObjEvent('Start Obj', Self);
        if STimer = nil then
          STimer := TN_CPUTimer1.Create;
        STimer.Start;
        if AddMode <> 2 then
        begin
          // Not Start Angel Mode
          case AddMode of
            0:
              VObjPatName := 'NAngle'; // Normal Angle
            1:
              VObjPatName := 'FAngle'; // Free Angle
          end;
          VObjCompRoot := EdSlide.AddNewMeasurement(VObjPatName);
          ChangeSelectedVObj(1, VObjCompRoot);
          AddToLog('Create ' + VObjPatName, TRUE);
        end;

        SavedCursorPos := CCBuf;
        PrevFPoint := N_AffConvF2FPoint(FPoint(SavedCursorPos),
          EdSlide.GetMapRoot.CompP2U);
        PrevFPoint.X := PrevFPoint.X + 100;
        PrevFPoint.Y := PrevFPoint.Y + 100;
        NewFPoint := PrevFPoint;
        if AddMode = 0 then
        begin // Normal Angle Lines Creation
          DragSegmentMode := TRUE;
          K_CMSVObjSetDefaultAttrs(VObjCompRoot);

          LineLength := 0;
          // !! Old          ArcComp  := TN_UDArc(VObjCompRoot.DirChild(0));
          // !! Old          LineComp := TN_UDPolyline(VObjCompRoot.DirChild(1));
          // !! Old          TextComp := TN_UDParaBox(VObjCompRoot.DirChild(2));
          ArcComp := TN_UDArc(VObjCompRoot.DirChild(1));
          LineComp := TN_UDPolyline(VObjCompRoot.DirChild(2));
          TextComp := TN_UDParaBox(VObjCompRoot.DirChild(3));
          K_CMVobjSetFontSizeAuto( TextComp, EdSlide.P()^.CMSDB.PixHeight );
//          EdSlide.SetTextFontAttrs(TextComp);

        with LineComp.PSP.CPolyline.CPCoords do
          begin
            PFPoint(P(0))^ := NewFPoint;
            PFPoint(P(1))^ := PrevFPoint;
            PFPoint(P(2))^ := PrevFPoint;
          end;
          // Start First Segment Edit
          CurPointInd := 0;
        end   // Normal Angle Lines Creation
        else if AddMode = 1 then
        begin // Free Angle First Segment Creation
          DragSegmentMode := TRUE;
          K_CMSVObjSetDefaultAttrs(VObjCompRoot);

          LineLength := 0;
          // !! Old          ArcComp  := TN_UDArc(VObjCompRoot.DirChild(0));
          // !! Old          LineComp1 := TN_UDPolyline(VObjCompRoot.DirChild(1));
          // !! Old          LineComp2 := TN_UDPolyline(VObjCompRoot.DirChild(2));
          // !! Old          LineComp3 := TN_UDPolyline(VObjCompRoot.DirChild(3));
          // !! Old          TextComp := TN_UDParaBox(VObjCompRoot.DirChild(4));
          ArcComp := TN_UDArc(VObjCompRoot.DirChild(1));
          LineComp1 := TN_UDPolyline(VObjCompRoot.DirChild(2));
          LineComp2 := TN_UDPolyline(VObjCompRoot.DirChild(3));
          LineComp3 := TN_UDPolyline(VObjCompRoot.DirChild(4));
          TextComp := TN_UDParaBox(VObjCompRoot.DirChild(5));
          K_CMVobjSetFontSizeAuto( TextComp, EdSlide.P()^.CMSDB.PixHeight );
//           EdSlide.SetTextFontAttrs(TextComp);
          LineComp := LineComp2;
          with LineComp.PSP.CPolyline.CPCoords do
          begin
            PFPoint(P(0))^ := PrevFPoint;
            PFPoint(P(1))^ := NewFPoint;
          end;
          with LineComp3.PSP.CPolyline.CPCoords do
          begin
            // Because LineComp3 is visible
            PFPoint(P(0))^ := PrevFPoint;
            PFPoint(P(1))^ := NewFPoint;
          end;
          // Start Start Free Angle First Segment Edit
          CurPointInd := 1;
        end   // Free Angle First Segment Creation
        else
        begin // Free Angle Second Segment Creation
          LineComp := LineComp3;
          with LineComp.PSP.CPolyline.CPCoords do
          begin
            PFPoint(P(0))^ := PrevFPoint;
            PFPoint(P(1))^ := NewFPoint;
          end;
          K_CMSVObjFAngleRebuild(LineComp1, LineComp2, LineComp3, ArcComp,
            TextComp, nil);
          // Start Free Angle Second Segment Edit
          CurPointInd := 1;
          AddToLog('Create FAngle 2-d' + VObjPatName, TRUE);
        end;  // Free Angle Second Segment Creation

        if (AddMode <= 1) and (EdSlide.CMSScaleFontFactor > 1) then
          // Angle Creation Scale Arc Radius if needed
          with ArcComp.PSP.CCoords do
          begin
            SRSize.X := SRSize.X * EdSlide.CMSScaleFontFactor;
            SRSize.Y := SRSize.X;
            BPShift.X := BPShift.X * EdSlide.CMSScaleFontFactor;
            BPShift.Y := BPShift.X;
          end;

        N_CM_MainForm.CMMFShowStringByTimer( K_CML1Form.LLLObjEdit20.Caption
//           'Press Escape to finish Angle creation'
           );
        RedrawAllAndShow();
      end;
    end
    else
    begin
      // Line Measurement Creation Mode
      K_CMSPCAddVObjEvent('Continue ', Self);
      LargeMouseShift := (Abs(SavedCursorPos.X - CCBuf.X) > 4) or
        (Abs(SavedCursorPos.Y - CCBuf.Y) > 4);
      if (CHType = htMouseUp) then
        DragSegmentMode := (STimer.CurSeconds > 0.4);

      if ( ((CHType = htMouseUp)   and DragSegmentMode     and not (ssRight in MouseDownCMKShift))
                                    or
           ((CHType = htMouseDown) and not DragSegmentMode and not (ssRight in CMKShift)))
        and LargeMouseShift then
      begin

        AddToLog('Finish Segment', TRUE);
        SavedCursorPos := CCBuf;
        // Get Last Point Position
        PCurFPoint := LineComp.PSP.CPolyline.CPCoords.P(CurPointInd);
        NewFPoint := PCurFPoint^;
        DragSegmentMode := not DragSegmentMode;
        STimer.Start;

        // Prepare Next Segment Edit Context
        PrevFPoint := NewFPoint;

        if AddMode = 0 then
        begin
          if CurPointInd = 0 then
          begin
            // Start Next Angle Segment Edit
            CurPointInd := 2;
            with LineComp.PSP.CPolyline.CPCoords do
              PFPoint(P(CurPointInd))^ := NewFPoint;

            K_CMSVObjNAngleRebuild(LineComp, ArcComp, TextComp, nil);

            RedrawAllAndShow();
          end
          else
          begin
            // Finish Angle Creation
            ACapt := N_CMResForm.aObjAngleNorm.Caption;
FinAngleCreation :
            FreeAndNil( STimer );
            N_CM_MainForm.CMMFDisableActions(nil);
            if AddMode = 0 then
              AObjType := K_shVOTypeAngle
            else
              AObjType := K_shVOTypeFreeAngle;
            N_CM_MainForm.CMMFFinishVObjEditing( K_CML1Form.LLLObjEdit22.Caption,
              // 'Add Angle',
              K_CMEDAccess.EDABuildHistActionCode(K_shATChange,
                Ord(K_shCAVOObject), Ord(K_shVOActAdd), Ord(AObjType)));
            CreateVObjFlag := false;
            AddMode := 0;
//            EdMoveVObjRFA.SkipNextMouseDown := TRUE;
            if EdViewEditMode <> cmrfemPoint then
              N_CMResForm.aEditPointExecute(nil);
            RedrawAllAndShow();
          end;
        end
        else
        begin
          if AddMode = 1 then
          begin
            // First Segment Finish
            AddMode := 2;
            CreateVObjFlag := false;
            N_CM_MainForm.CMMFShowStringByTimer( K_CML1Form.LLLObjEdit21.Caption
//              'Put Free Angle Last Segment Start Vertex or press Escape to finish Angle creation'
                                                );
            RedrawAllAndShow();
          end
          else
          begin
            // Second Segment Finish
            ACapt := N_CMResForm.aObjAngleFree.Caption;
            goto FinAngleCreation;
          end;
        end
      end
      else if CHType = htMouseMove then
      begin
        // Move Segment End Point
        with LineComp do
        begin
          NewFPoint := N_AffConvF2FPoint(FPoint(CCBuf), UDPFromBufPixCoefs4);
          PCurFPoint := PFPoint(PISP()^.CPCoords.P(CurPointInd));
          PCurFPoint^ := NewFPoint;
          if (AddMode = 0) or (AddMode = 2) then
          begin
            // RedrawAll without MapImage for proper Angle calc
            // if K_CMSkipMouseMoveRedraw > 0 then
            begin
              with EdSlide.GetMapImage().PSP.CCompBase do
              begin
                CBSkipSelf := 100;
                RedrawAll();
                CBSkipSelf := 0;
              end;
            end; // if K_CMSkipMouseMoveRedraw > 0 then

            if (AddMode = 0) and (CurPointInd = 2) then
            // Normal Angle Last Segment Edit
              K_CMSVObjNAngleRebuild(LineComp, ArcComp, TextComp, nil)
            else if AddMode = 2 then // Free Angle Last Segment Edit
              K_CMSVObjFAngleRebuild(LineComp1, LineComp2, LineComp3, ArcComp,
                TextComp, nil);
          end; // if (AddMode = 0) or (AddMode = 2) then

          // Redraw All and Show with and without K_CMRedrawObject
          if K_CMSkipMouseMoveRedraw > 0 then
          begin
            NP := RedrawAllAndShow;
            with K_CMRedrawObject do
            begin
              if not Assigned(OnRedrawProcObj) or
                 (TMethod(NP).Code <> TMethod(OnRedrawProcObj).Code) then
//                 not CompareMem( @OnRedrawProcObj, @NP, SizeOf(TNotifyEvent) ) then
                InitRedraw( RedrawAllAndShow );

              // Value of TK_NotifyProc RedrawAllAndShow is the same for different instances of TK_CMEAddVObj2RFA
              // (Different Instances TK_CMEAddVObj2RFA are because of each instance of TN_CMREdit3Frame has own instance of TK_CMEAddVObj1RFA)
              //
              // Need to set OnRedrawProcObj each time because assignment of K_CMRedrawObject.OnRedrawProcObj leads to
              // to call RedrawAllAndShow of needed instance of TK_CMEAddVObj2RFA in K_CMRedrawObject.Redraw()
              // K_CMRedrawObject.InitRedraw was not used because it reset K_CMRedrawObject redraw context
              OnRedrawProcObj := RedrawAllAndShow;

              if not MouseUpCheck() then
                OnCheckDirectRedraw := MouseUpCheck
              else
                OnCheckDirectRedraw := SkipDirectRedraw;

              Redraw();
            end;
          end // if K_CMSkipMouseMoveRedraw > 0 then
          else
            RedrawAllAndShow();
        end; // with LineComp do
      end; // if CHType = htMouseMove
    end; // end of Line Measurement Creation Mode

    // N_CM_MainForm.CMMFShowString( Str );

  end; // with TN_SGComp(ActGroup), OneSR, ActGroup.RFrame do

end; // procedure TK_CMEAddVObj2RFA.Execute

{ *** end of TK_CMEAddVObj2RFA *** }

{ *** TK_CMEMoveVObjRFA *** }

//******************************************* TK_CMEMoveVObjRFA.BriCoRedraw ***
// BriCoGam redraw action routine
//
procedure TK_CMEMoveVObjRFA.BriCoRedraw( ASlide : TN_UDCMSlide; ARFrame : TN_Rast1Frame;
                       APImgViewConvData: TK_PCMSImgViewConvData );
begin
//    if ASlide.CMSShowWaitStateFlag then
//      N_CM_MainForm.CMMFShowHideWaitState( TRUE );

  ASlide.RebuildMapImageByDIB( nil, APImgViewConvData );

  ARFrame.RedrawAllAndShow();

  // Histogram Redraw if needed
  if (N_BrigHist2Form <> nil) and
     (TN_CMREdit3Frame(ARFrame.Parent) = N_CM_MainForm.CMMFActiveEdFrame) then
    N_BrigHist2Form.SetXLattoConv( K_GetPIArray0(ASlide.CMSXLatBCGHist) );

//    if ASlide.CMSShowWaitStateFlag then
//      N_CM_MainForm.CMMFShowHideWaitState( FALSE );
end; // procedure TK_CMEMoveVObjRFA.BriCoRedraw

//********************************** TK_CMEMoveVObjRFA.BriCoMouseMoveRedraw ***
// BriCoGam MouseMove redraw routine
//
procedure TK_CMEMoveVObjRFA.BriCoMouseMoveRedraw;
begin
  with TN_SGComp(ActGroup), OneSR, RFrame, TN_CMREdit3Frame(Parent) do
    BriCoRedraw( EdSlide, RFrame, @BriCoVCAttrs );
end; // procedure TK_CMEMoveVObjRFA.BriCoMouseMoveRedraw

//*********************************************** TK_CMEMoveVObjRFA.Execute ***
// Move annotation or BriCoGam change Action execute
//
procedure TK_CMEMoveVObjRFA.Execute;
var
  // Str: string;
  PMeasureRootSelected: PByte;
  PCurFPoint: PFPoint;
  NewFPoint, NewFPixPoint, WFPoint: TFPoint;
  NearestComp: TN_UDCompVis;
  NearestCompSRType: TN_SRType;

  NearestCompRoot: TN_UDCompVis;
  WCursor: TCursor;
  NVerts, CTInd: Integer;
  PixShiftX, PixShiftY: Integer;

  DLength: Double;
  CurVObjMinSize: Double;
  DX, DY: Float;
  CurSlide: TN_UDCMSlide;
  i: Integer;
  FinCreateText: string;
  LCBuf: TPoint;
  MouseInsideImage: Boolean;
  InsideGapX, InsideGapY: Integer;
  OutsideShiftFlag: Boolean;
  CurCompP2U: TN_AffCoefs4;
  VObjAction: TK_CMSlideHistVObjAct;
  HighlightMeasureRoot: Boolean;
  ASender: TObject;
  FinDumpText: string;
  FinActText: string;
  FinActHistCode: Integer;
  CurColor : Integer;

  BriCoBriPos          : Integer;
  BriCoCoPos           : Integer;

  FRFAMouseAction : TN_RFAMouseAction;

  PFScale : PFLoat;
  FScale : FLoat;
  NP : TK_NotifyProc;


  procedure AddToLog(AStr: string; AShowCBuf: Boolean = false);
  begin
    if not(cmpfVObjMain in N_CM_LogFlags) then
      Exit;

    if AShowCBuf then
      AStr := AStr + format(' X,Y=%d,%d', [LCBuf.X, LCBuf.Y]);

    if not ActEnabled then
      AStr := AStr + ' ActDisabled';

    N_Dump2Str(ActGroup.RFrame.Parent.Name + '.' + ActName + ': ' + AStr);
  end;

  procedure SetTextVal(UDText: TN_UDParaBox; NVal: Double; Pref: string);
  begin
    with UDText.PSP^, TN_POneTextBlock(CParaBox.CPBTextBlocks.P())^,
      CCoords.BPCoords do
    begin
      X := X + DX;
      Y := Y + DY;
      // Build Segment Lehth Text
      OTBMText := Pref + ' ' + CurSlide.DistMM2UnitsText(NVal) + ' ';
    end;
    K_CMSVObjTextPosRebuild(ActGroup.RFrame, UDText, [cmtpfSkipFinalShow]);
  end;

  procedure SetSegmText(UDText: TN_UDParaBox; const FP1: TFPoint;
    var Val: Double);
  begin
    DLength := Val;
    Val := CurSlide.CalcMMDistance(FP1, NewFPoint);
    DLength := Val - DLength;
    LineLength := LineLength + DLength;
    SetTextVal(UDText, Val, '');
  end;

  procedure StartRectTypeObjPointEdit;
  begin
    with NearestCompRoot, PSP.CCoords do
    begin
      MoveMode := 3;
      SelectedVertInd := SelectedVertInd and 3;
      PrevFPoint := BPCoords;
      case SelectedVertInd of
        1:
          PrevFPoint.X := PrevFPoint.X + SRSize.X;
        2:
          begin
            PrevFPoint.X := PrevFPoint.X + SRSize.X;
            PrevFPoint.Y := PrevFPoint.Y + SRSize.Y;
          end;
        3:
          PrevFPoint.Y := PrevFPoint.Y + SRSize.Y;
      end;
      SavedFPixPoint := N_AffConvF2FPoint(PrevFPoint,
        TN_UDCompVis(Owner).CompU2P);
    end;
  end;
{
  procedure TimeToProt( AStr : string );
  // Add Time to Protocol
  var
  Buf: String;
  begin
  N_T1.SS( AStr, Buf );
  N_AppShowString( Buf );
  N_Dump2Str( Buf );
  N_T1.Start();
  end; // procedure TimeToProt( AStr : string );



  // N_RectSize   ( const ARect: TRect )
  procedure CalcFlashlightSrcRect( AFlashLightRootComp : TN_UDCompVis;
  RFScale : Float; APixSize : TPoint );
  var
  FScale : Float;
  begin
  with AFlashLightRootComp, PSP.CCoords, PCDIBRect^, CDRSrcUDDIB.DIBObj.DIBRect do begin
  //      N_IAdd( format( '%f', [RFScale] ) );
  CDRSrcRect.Left := Round( Right  * (BPCoords.X + SRSize.X / 2) / 100 );
  CDRSrcRect.Top  := Round( Bottom * (BPCoords.Y + SRSize.Y / 2) / 100 );
  if PInteger(N_GetUserParPtr( R, 'SkipScaleFlag' ).UPValue.P)^ = 0 then
  FScale := PFloat(N_GetUserParPtr( R, 'ScaleFactor' ).UPValue.P)^
  else
  FScale := 1;
  FScale := FScale * RFScale;
  CDRSrcRect := N_RectMake( CDRSrcRect.TopLeft,
  Point( Round(APixSize.X / FScale), Round(APixSize.Y / FScale) ), N_05DPoint );
  end;
  end; // CalcFlashlightSrcRect;
}

  procedure CalcObjPixAttrs();
  var
    LInd : Integer;
    CompPixRect1 : TRect;
  begin
    with TN_UDPolyline(NearestComp) do
      if NearestCompSRType = srtPolyline then
      begin
        CompPixRect := IRect(N_CalcFLineEnvRect(@UDPBufPixCoords[0],
            Length(UDPBufPixCoords)));
        if (MovedComp.ObjName[1] = 'F') then
        begin
          if NearestComp.ObjName = 'Polyline1' then
            LInd := 4
          else
            LInd := 3;
          with TN_UDPolyline(MovedComp.DirChild(LInd)) do
            CompPixRect1 := IRect(N_CalcFLineEnvRect(@UDPBufPixCoords[0],
                                  Length(UDPBufPixCoords)));
          N_IRectOr( CompPixRect, CompPixRect1 );
        end;
      end
      else
      if (MovedComp.ObjName[1] = 'E') or
        ((MovedComp.ObjName[1] = 'Z') and (MovedComp.ObjName[2] = 'E')) then
        // !! Old        with TN_UDPolyLine( MovedComp.DirChild(1) ) do
        with TN_UDPolyline(MovedComp.DirChild(2)) do
          CompPixRect := IRect(N_CalcFLineEnvRect(@UDPBufPixCoords[0],
              Length(UDPBufPixCoords)))
      else
        CompPixRect := CompOuterPixRect;
    CompFRect := N_AffConvI2FRect1(CompPixRect, TN_UDCompVis(MovedComp.Owner).CompP2U)
    {
      with MovedComp do begin
      SavedFPixPoint := N_AffConvF2FPoint( SavedFPoint, TN_UDCompVis(Owner).CompU2P );
      WFPoint := N_AffConvF2FPoint( SavedCursorFPoint, TN_UDCompVis(Owner).CompU2P );
      end;
    }
    // SavedCursorPos.X := Round(WFPoint.X);
    // SavedCursorPos.Y := Round(WFPoint.Y);
  end;

begin

  inherited;

  with TN_SGComp(ActGroup), OneSR, RFrame, TN_CMREdit3Frame(Parent) do
  begin
{ // debug
if (CHType = htMouseDown) then
begin
N_i  := N_PointInRect(CCBuf, RFLogFramePRect);
N_i1 := Ord(SRType);
end;
}
    if (MeasureRoot <> nil) and (CHType = htMouseUp) then
    begin
      if N_CM_MainForm.MeasureTextTimer.Enabled then
        N_CM_MainForm.MeasureTextTimer.Enabled := false
      else
      begin
        // PByte( N_GetUserParPtr( TN_UDCompVis(MeasureRoot).R,
        // 'Selected' ).UPValue.P)^ := 0;
        PByte(K_CMGetVObjPAttr(MeasureRoot, 'Selected').UPValue.P)^ := 0;
        RedrawAllAndShow();
      end;
      MeasureRoot := nil;
    end;

//if CHType = htMouseDown then  // debug code - to check event
//CHType := htMouseDown;

    if EdViewEditMode <> cmrfemPoint then
    begin
      // Close Self Activity
      N_Dump2Str(RFrame.Parent.Name + '.' + ActName + ': Self Disabled');
      Self.ActEnabled := false;
      // Clear Selected
      if ChangeSelectedVObj(0) then
        RedrawAllAndShow();
      CreateVObjMode := 0;
      Exit;
    end;

//    if N_CM_MainForm.(uicsAllActsDisabled in CMMUICurStateFlags) or not
//      (cmsfIsLocked in EdSlide.P.CMSRFlags) then
    if (uicsAllActsDisabled in N_CM_MainForm.CMMUICurStateFlags) or
      (cmsfSkipSlideEdit in EdSlide.P.CMSRFlags) then
      Exit; // Exit if Disabled Actions Mode

    if (CHType = htKeyDown) and (MovedComp <> nil) and (MovedComp.ObjName[1] = 'Z') then
    begin
      PFScale := PFloat(K_CMGetVObjPAttr(MovedComp, 'ScaleFactor').UPValue.P);
      FScale := PFScale^;
      case CKey.CharCode of
        $BD,$6D: begin // '-'
          FScale := Max( FScale - 0.5, 1 );
        end;
        $BB,$6B: begin // '+'
          FScale := Min( FScale + 0.5, 10 );
        end;
      end;
      if FScale <> PFScale^ then
      begin
        PFScale^ := FScale;
        K_CMSFlashlightCalcSrcRect( MovedComp, RFrame.RFVectorScale,
                                    N_RectSize( MovedComp.CompOuterPixRect ) );
        N_CM_MainForm.CMMFFinishVObjEditing( N_CMResForm.aObjChangeAttrs.Caption,
               K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAVOObject),
                    Ord(K_shVOActEdAttrs),
                    Ord( K_CMEDAccess.EDAGetVObjHistType( MovedComp ) ) ) );
        Exit;
      end;
    end;


    LCBuf := CCBuf;
    with CCBuf, RFLogFramePRect do
      MouseInsideImage := (X >= 0) and (X <= Right) and (Y >= 0) and
        (Y <= Bottom);

    if (CreateVObjMode > 0) and MouseInsideImage then
    begin
      // Start VObj "like Rectangle" Creation
      WCursor := RFrame.Cursor;
      if (CHType = htMouseMove) then
      begin
        case CreateVObjMode of
          1,6:
            WCursor := crCreateRect; // Rectangle
          2:
            WCursor := crCreateEllipse; // Ellipse
          3:
            WCursor := crCreateArrow; // Arrow
          4: // WCursor := crZoomCursor;    // Ellipse FlashLight

            begin // Ellipse FlashLight
              CreateVObjMode := -1;
              AfterFlashLightCreationMode := TRUE;
              NearestCompRoot := EdSlide.AddNewMeasurement('ZEllipse', TRUE);
              AddToLog('Create ZEllipse', TRUE);

              // K_CMSVObjSetDefaultAttrs( NearestCompRoot );
              MovedComp := NearestCompRoot;
              EdSlide.PrepROIView([K_roiDoneAll]);
              SavedCursorPos := CCBuf;
              WCursor := crMoveVObjCursor;
              MoveObjMode := TRUE;
              MovePointMode := false;
              with MovedComp, PSP.CCoords do
              begin
                PixShiftX := K_CMFlashlightIni.CMFLPixSize shr 1;
                CurCompP2U := EdSlide.GetMapRoot.CompP2U;
                SavedFPixPoint := FPoint(CCBuf.X - PixShiftX,
                  CCBuf.Y - PixShiftX);
                BPCoords := N_AffConvF2FPoint(SavedFPixPoint, CurCompP2U);
                SavedFPoint := BPCoords;
                WFPoint := N_AffConvF2FPoint(FPoint(CCBuf.X + PixShiftX,
                    CCBuf.Y + PixShiftX), CurCompP2U);
                SRSize := FPoint(WFPoint.X - BPCoords.X,
                  WFPoint.Y - BPCoords.Y);

                K_CMSetFlashLightAttrs( MovedComp, @K_CMFlashlightIni );
                K_CMSFlashlightCalcSrcRect(MovedComp, RFVectorScale,
                  Point(K_CMFlashlightIni.CMFLPixSize, K_CMFlashlightIni.CMFLPixSize));
                RedrawAllAndShow();
                // !! Old              NearestComp := TN_UDCompVis( DirChild(1) );
                NearestComp := TN_UDCompVis(DirChild(2));
                NearestCompSRType := srtArc;
                SavedCursorFPoint := N_AffConvI2FPoint(CCBuf, CurCompP2U);
                CalcObjPixAttrs();
                PrevScaleFactor := RFVectorScale;
              end;
            end;
          // 5: WCursor := crZoomCursor;    // Rectangle FlashLight
        end;
      end // if (CHType = htMouseMove) then
      else if (CHType = htMouseDown) then
      begin
        K_CMSPCAddVObjEvent('Start Obj', Self);
        case CreateVObjMode of
          1: begin
            VObjPatName := 'Rect'; // Rectangle
            FinCreateText := N_CMResForm.aObjRectangleOld.Caption
          end;
          2: begin
            VObjPatName := 'Ellipse'; // Ellipse
            FinCreateText := N_CMResForm.aObjEllipseOld.Caption
          end;
          3: begin
            VObjPatName := 'Arrow'; // Arrow
            FinCreateText := N_CMResForm.aObjArrowOld.Caption;
          end;
          // 4: VObjPatName := 'ZEllipse';  // Ellipse FlashLight
          // 5: VObjPatName := 'ZRect';     // Rectangle FlashLight
        end;

        AddToLog('Create ' + VObjPatName, TRUE);

        NearestCompRoot := EdSlide.AddNewMeasurement(VObjPatName);

        // NearestCompRoot := EDSlide.AddNewMeasurement( VObjPatName, VObjPatName[1] = 'Z' );
        K_CMSVObjSetDefaultAttrs(NearestCompRoot);
        RebuildVObjsSearchList();
        ChangeSelectedVObj(1, NearestCompRoot);
        SavedCursorPos := CCBuf;
        with NearestCompRoot, PSP.CCoords do
        begin
          CurCompP2U := EdSlide.GetMapRoot.CompP2U;
          BPCoords := N_AffConvF2FPoint( FPoint(SavedCursorPos), CurCompP2U );
          SavedCursorFPoint := BPCoords;
          MovedComp := TN_UDCompVis(NearestCompRoot.DirChild(1));
          SelectedVertInd := 2;
          StartRectTypeObjPointEdit();

          CurVobjMinSize := K_CMRectTypeVObjMinSize;
          if RFVectorScale > 1 then
            CurVobjMinSize := K_CMRectTypeVObjMinSize * RFVectorScale;

          SRSize := FPoint( CurVobjMinSize * CurCompP2U.CX, CurVobjMinSize * CurCompP2U.CY );

          CreateVObjMode := 0;
          MoveMode := 0;
          WCursor := crDefault;
          AddToLog('Finish ' + FinCreateText + ' Creation');
          N_CM_MainForm.CMMFFinishVObjEditing(N_CMResForm.aObjArrowOld.Caption,
              K_CMEDAccess.EDABuildHistActionCode(K_shATChange,
                Ord(K_shCAVOObject), Ord(K_shVOActAdd),
                Ord(K_CMEDAccess.EDAGetVObjHistType(MovedComp.Owner))));
        end; // with NearestCompRoot, PSP.CCoords do

        RedrawAllAndShow();
      end; // else if (CHType = htMouseDown) then
      if RFrame.Cursor <> WCursor then
        N_SetMouseCursorType(RFrame, WCursor);
      Exit;
    end; // if (CreateVObjMode > 0) and MouseInsideImage then

    if SkipNextMouseDown and (CHType = htMouseDown) then
    begin
      SkipNextMouseDown := false;
      Exit;
    end;

    if (CHType = htMouseDown) and
       (ssLeft in CMKShift)   and
       (ssDouble in CMKShift) then
    begin
      // Object Double Click
      K_CMSPCAddVObjEvent('Dbl Click', Self);

      if EdVObjSelected <> nil then
        N_CMResForm.aObjChangeAttrsExecute(N_CMResForm.aObjChangeAttrs)
      else
      begin
{ !!! This Code is Moved to FrameOnDoubleClick handler }
        if K_CMSFullScreenForm = nil then
        begin
          AddToLog('Full Screen');
          N_CMResForm.aEditFullScreenExecute( N_CMResForm.aEditFullScreen );
//        aFullScreenExecute(nil);
//          N_CM_MainForm.CMMCurFMainForm.SetFocus();
//          RedrawAllAndShow(); // Return Search Context
        end
        else
          N_CMResForm.aEditFullScreenCloseExecute(N_CMResForm.aEditFullScreenClose);
//          K_CMSFullScreenForm.Close;
{}
      end;
      Exit;
    end; // if (CHType = htMouseDown) and ...


    // ??    with EdRubberRectRFA do
    // ??      if ActEnabled and (RRFlags <> 0) then Exit;

    if not MoveObjMode and not MovePointMode then
    begin
    // Finish FullScreen mode
      if (K_CMSFullScreenForm <> nil) and
         (CHType = htKeyDown)         and
         ( (CKey.CharCode = VK_Escape) or
           ((CKey.CharCode = Ord('F')) and N_KeyIsDown(VK_CONTROL)) ) then
      begin
//        K_CMSFullScreenForm.Close;
        N_CMResForm.aEditFullScreenCloseExecute(N_CMResForm.aEditFullScreenClose);
        Exit;
      end;

      if (N_BrigHist2Form <> nil)  and
         (TN_SGComp(ActGroup).RFrame.Parent = N_CM_MainForm.CMMFActiveEdFrame) and
         (CHType = htMouseMove)    and
         not (ssLeft in CMKShift)  and
         not (ssRight in CMKShift) and
         not (ssMiddle in CMKShift)  then
      begin
        CurColor := EdSlide.GetCurImgPixColorByMapImgCursorPos( CCBuf, nil );
        if not (cmsfGreyScale in EdSlide.P.CMSDB.SFlags) then
          CurColor := Round( 0.114*(CurColor and $FF) +           // Blue
                             0.587*((CurColor shr 8) and $FF) +   // Green
                             0.299*((CurColor shr 16) and $FF) ); // Red;
        if (Length(EdSlide.CMSXLatBCGColor) <> 0) then
          CurColor := EdSlide.CMSXLatBCGColor[CurColor];
        N_BrigHist2Form.SetCurBrightness( CurColor );
      end;

      // Try to Select New Object
      NearestCompRoot := nil;
      if (N_PointInRect(CCBuf, RFLogFramePRect) = 0)       and
        ((CHType = htMouseDown) or (CHType = htMouseMove)) and
        (SRType <> srtNone) then
      begin
        N_Dump2Str( format( 'Search ListObj(%d %d) Found SCompsLength=%d SRType=%d Ind=%d', [Integer(EdVObjsGroup), Integer(ActGroup), Length(SComps), Ord(SRType), SRCompInd] ) );
        NearestComp := SComps[SRCompInd].SComp; // founded Component
        NearestCompSRType := SRType;
        NearestCompRoot := NearestComp; // founded Component
        if (SRType = srtPolyline) or (SRType = srtArc) or (SRType = srtDIBRect) then // Select Annot/Measure Root
          NearestCompRoot := TN_UDCompVis(NearestCompRoot.Owner);
      end;

      WCursor := RFrame.Cursor;
      if NearestCompRoot <> nil then
      begin
      // Event near VObj
        if CHType = htMouseMove then
        begin
          // Select Cursor Type
          WCursor := crMoveVObjCursor;
          if (SRType = srtPolyline) and (VertInd >= 0) and
             (NearestCompRoot.ObjName[1] <> 'D') then
            WCursor := crMovePointCursor
          else if SRType = srtParaBox then
            WCursor := crMoveTextCursor;
        end
        else if CHType = htMouseDown then
        begin
          K_CMSPCAddVObjEvent('Found Obj', Self);
          DragSegmentMode := TRUE;

          // Prepare Measure Root Object
          // !! Old          MeasureRoot := NearestCompRoot.Owner.DirChild(0);
          MeasureRoot := NearestCompRoot.Owner.DirChild(1);
          HighlightMeasureRoot := FALSE;
          if (NearestCompRoot is TN_UDParaBox) and
             ((MeasureRoot is TN_UDPolyline) or
               (MeasureRoot is TN_UDArc)) then
          begin
            MeasureRoot := NearestCompRoot.Owner; // Some Measure Text
            PMeasureRootSelected := PByte(K_CMGetVObjPAttr(MeasureRoot,
                'Selected').UPValue.P);
            N_CM_MainForm.MeasureTextTimer.Interval := 500;
            N_CM_MainForm.MeasureTextTimer.Enabled := TRUE;
            BriCoModeStart := FALSE; // Clear BriCoOrScrollModeStart
            if PMeasureRootSelected^ <> 0 then
              HighlightMeasureRoot := TRUE;
            {
              if PMeasureRootSelected^ = 0 then
              N_CM_MainForm.MeasureTextTimer.Interval := 500;
              N_CM_MainForm.MeasureTextTimer.Enabled := TRUE
              else begin
              MeasureRoot := nil; // Already Selected
              end;
            }
          end
          else
            MeasureRoot := nil;

          if not ChangeSelectedVObj(1, NearestCompRoot)
             and not HighlightMeasureRoot then
          begin
            RedrawAllAndShow();
          end;

          // Set Move Mode - MouseDown on Selected Object
          MovedComp := NearestCompRoot;

          MoveObjMode := (SRType <> srtPolyline) or (VertInd < 0) or (NearestCompRoot.ObjName[1] = 'D');
          // CursorType NE Point Cursor

          SavedCursorPos := CCBuf;
          SavedCursorFPoint := N_AffConvI2FPoint(CCBuf, EdSlide.GetMapRoot.CompP2U);
          PrevScaleFactor := RFVectorScale;

          if MoveObjMode then
          begin
            with MovedComp do
            begin
              SavedFPoint := PSP.CCoords.BPCoords;
              SavedFPixPoint := N_AffConvF2FPoint(SavedFPoint,
                                                  TN_UDCompVis(Owner).CompU2P);
            end;
            CalcObjPixAttrs();
            PrevScaleFactor := RFVectorScale;

            if MovedComp.ObjName[1] = 'Z' then
              // !! Old              PCDIBRect := @TN_UDDIBRect(MovedComp.DirChild(0)).PSP.CDIBRect;
              PCDIBRect := @TN_UDDIBRect(MovedComp.DirChild(1)).PSP.CDIBRect;
          end;

          // Move Selected Point Mode
          MovePointMode := not MoveObjMode;
          if MovePointMode then
          begin
            MoveMode := 0;
            WCursor := crCross;
            AllTextComp := nil;
            PrevTextComp := nil;
            NextTextComp := nil;
            SelectedVertInd := VertInd;
            MovedComp := SComps[SRCompInd].SComp;
            with TN_UDPolyline(MovedComp), PISP.CPCoords do
            begin
              SavedFPoint := PFPoint(P(SelectedVertInd))^;
              SavedFPixPoint := UDPBufPixCoords[VertInd];
              SavedFFPoint := N_AffConvF2FPoint(SavedFPixPoint,
                EdSlide.GetMapRoot.CompP2U);

              with TN_UDBase(NearestCompRoot) do
              begin
                if (ObjName[1] = 'E')    and
                   (Length(ObjName) > 7) and
                   (ObjName[8] = 'L') then
                begin
                  MoveMode := 6;
                end
                else
                if (ObjName[1] = 'R')    and
                   (Length(ObjName) > 4) and
                   (ObjName[5] = 'L') then
                begin
                  MoveMode := 5;
                end
                else
                if (ObjName[1] = 'A')    and
                   (Length(ObjName) > 5) and
                   (ObjName[6] = 'L') then
                begin
                  MoveMode := 4;
                end
                else
                if ObjName[1] = 'M' then
                begin
                  // Prepare MeasurLine Text Components to Change
                  LineLength := EdSlide.CalcMMLineLength
                    (TN_UDPolyline(MovedComp));
                  NVerts := ALength;
                  AllTextComp := TN_UDParaBox(DirChild(DirHigh));
                  if NVerts <= 2 then // Single Segment
                    AllTextComp := nil;

                  NewFPoint := PFPoint(P(SelectedVertInd))^;
                  // previous Point and Segment Attrs
                  CTInd := VertInd - 1;
                  if CTInd >= 0 then
                  begin
                    // !! Old                    PrevTextComp := TN_UDParaBox(DirChild(VertInd));
                    PrevTextComp := TN_UDParaBox(DirChild(VertInd + 1));
                    PrevFPoint := PFPoint(P(CTInd))^;
                    PrevSegmLength := EdSlide.CalcMMDistance(PrevFPoint,
                      NewFPoint);
                  end; // if CTInd >= 0

                  // Next Point and Segment Attrs
                  CTInd := VertInd + 1;
                  if CTInd < NVerts then
                  begin
                    // !! Old                    NextTextComp := TN_UDParaBox(DirChild(CTInd));
                    NextTextComp := TN_UDParaBox(DirChild(CTInd + 1));
                    NextFPoint := PFPoint(P(CTInd))^;
                    NextSegmLength := EdSlide.CalcMMDistance(NextFPoint,
                      NewFPoint);
                  end; // if CTInd < NVerts
                end // if MovedComp.Owner.ObjName[1] = 'M'
                else if ObjName[1] = 'N' then
                begin
                  MoveMode := 1;
                  // !! Old                  ArcComp  := TN_UDArc(DirChild(0));
                  // !! Old                  LineComp := TN_UDPolyline(DirChild(1));
                  // !! Old                  TextComp := TN_UDParaBox(DirChild(2));
                  ArcComp := TN_UDArc(DirChild(1));
                  LineComp := TN_UDPolyline(DirChild(2));
                  TextComp := TN_UDParaBox(DirChild(3));
                  TextBasePoint := K_CMSVObjNAngleRebuild(LineComp, ArcComp,
                    TextComp, Pointer(1));
                end
                else if ObjName[1] = 'F' then
                begin
                  MoveMode := 2;
                  // !! Old                  ArcComp   := TN_UDArc(DirChild(0));
                  // !! Old                  LineComp1 := TN_UDPolyline(DirChild(1));
                  // !! Old                  LineComp2 := TN_UDPolyline(DirChild(2));
                  // !! Old                  LineComp3 := TN_UDPolyline(DirChild(3));
                  // !! Old                  TextComp  := TN_UDParaBox(DirChild(4));
                  ArcComp := TN_UDArc(DirChild(1));
                  LineComp1 := TN_UDPolyline(DirChild(2));
                  LineComp2 := TN_UDPolyline(DirChild(3));
                  LineComp3 := TN_UDPolyline(DirChild(4));
                  TextComp := TN_UDParaBox(DirChild(5));
                  TextBasePoint := K_CMSVObjFAngleRebuild(LineComp1, LineComp2,
                    LineComp3, ArcComp, TextComp, Pointer(1));
                end
                else if ((ObjName[1] = 'R') and
                         ((Length(ObjName) = 4) or (ObjName[5] <> 'L'))) or
                        ((ObjName[1] = 'E') and
                         ((Length(ObjName) = 7) or (ObjName[8] <> 'L'))) or
                        ((ObjName[1] = 'A') and
                         ((Length(ObjName) = 5) or (ObjName[6] <> 'L'))) or
                        (ObjName[1] = 'Z') then // FlashLight
                  StartRectTypeObjPointEdit();
              end; // TN_UDBase(NearestComp)
            end; // with TN_UDPolyline(MovedComp)
          end; // if MovePointMode then
        end; // if CHType = htMouseDown
      end // if NearestComp <> nil
      else
      begin
        // Event far from VObj
        WCursor := crDefault;
        if CHType = htMouseDown then
        begin
        // Mouse Down Far From VObj
          if ChangeSelectedVObj(0) then
          begin
            K_CMSPCAddVObjEvent('Lose Obj ', Self);
            RedrawAllAndShow();
          end;

{!!! Skip Coords scroll  in ViewZoomMode
          if K_CMSZoomForm <> nil then
          begin
            ImageScrollMode := TRUE;
            Screen.Cursor := crSizeAll;
            N_SetMouseCursorType( RFrame, crSizeAll );

            RFrActionFlags := RFrActionFlags + [rfafScrollCoords];
            FRFAMouseAction := TN_RFAMouseAction(RFGetActionByClass( N_ActMouseAction ));
            FRFAMouseAction.StartScrollMode();
          end;
}
          if not BriCoModeStart  and
             not BriCoMode       and
             not ImageScrollMode and
            (ssLeft in CMKShift) and
            N_CMResForm.aToolsBriCoGam.Enabled and
            not N_CM_MainForm.MeasureTextTimer.Enabled then
          begin
          // Start BriCo Edit Mode
            BriCoModeStart := TRUE;
            BriCoCursorStartPos := CCBuf;
            N_CM_MainForm.MeasureTextTimer.Interval := 250;
            N_CM_MainForm.MeasureTextTimer.Enabled := TRUE;
          end
          else
          begin
            BriCoModeStart := FALSE;
            BriCoMode      := FALSE;
          end;
        end
        else
        if ImageScrollMode then
        begin
        // Continue Image Scroll Mode
          if CHType = htMouseUp then
          begin
          // Finish Image Scroll Mode
            ImageScrollMode := FALSE;
            RFrActionFlags := RFrActionFlags - [rfafScrollCoords];
            WCursor := crDefault;
          end;
        end
        else
        if BriCoMode then
        begin
        // Continue BriCo Edit Mode
          if BriCoLSF = nil then
          begin
            BriCoLSF := TK_LineSegmFunc.Create( [0, -100,  100, -60,  250, -20,  750, 20,  900, 60,  1000, 100 ] );
            EdSlide.GetImgViewConvData( @BriCoVCAttrs );
            with BriCoVCAttrs do
            begin
              BriCoBriPosIni := Round( BriCoLSF.Func2Arg( VCBriFactor ) );
              BriCoCoPosIni  := Round( BriCoLSF.Func2Arg( VCCoFactor ) );
            end;
          end; // if BriCoLSF = nil then

          if (CHType = htMouseMove) and (ssLeft in CMKShift) then
          begin
          // Change Image BriCo
          // ...
            BriCoBriPos := Min( 1000,
                     Max( BriCoBriPosIni + CCBuf.X - BriCoCursorStartPos.X, 0 ) );
            BriCoCoPos := Min( 1000,
                     Max( BriCoCoPosIni  + BriCoCursorStartPos.Y - CCBuf.Y, 0 ) );
            begin
              with BriCoVCAttrs do
              begin
                VCBriFactor := Round( BriCoLSF.Arg2Func( BriCoBriPos ) );
                VCCoFactor  := Round( BriCoLSF.Arg2Func( BriCoCoPos ) );
              end;
//              BriCoRedraw( EdSlide, RFrame, @BriCoVCAttrs );

              if K_CMSkipMouseMoveRedraw > 0 then
              begin
                NP := BriCoMouseMoveRedraw;
                with K_CMRedrawObject do
                begin
                  if not Assigned(OnRedrawProcObj) or
                     (TMethod(NP).Code <> TMethod(OnRedrawProcObj).Code) then
//                     not CompareMem( @OnRedrawProcObj, @NP, SizeOf(TNotifyEvent) ) then
                    InitRedraw( BriCoMouseMoveRedraw );

                  // Value of TK_NotifyProc BriCoMouseMoveRedraw is the same for different instances of TK_CMEMoveVObjRFA
                  // (Different Instances TK_CMEMoveVObjRFA are because of each instance of TN_CMREdit3Frame has own instance of TK_CMEMoveVObjRFA)
                  //
                  // Need to set OnRedrawProcObj each time because assignment of K_CMRedrawObject.OnRedrawProcObj leads to
                  // to call BriCoMouseMoveRedraw of needed instance of TK_CMEMoveVObjRFA in K_CMRedrawObject.Redraw()
                  // K_CMRedrawObject.InitRedraw was not used because it reset K_CMRedrawObject redraw context
                  OnRedrawProcObj := BriCoMouseMoveRedraw;
                  if not MouseUpCheck() then
                    OnCheckDirectRedraw := MouseUpCheck
                  else
                    OnCheckDirectRedraw := SkipDirectRedraw;

                  Redraw();
                end;
              end // if K_CMSkipMouseMoveRedraw > 0 then
              else
                BriCoMouseMoveRedraw();
//              BriCoMouseMoveRedraw();
            end;
          end
          else
          if CHType = htMouseUp then
          begin
          // Finish BriCo Edit Mode
            if Abs( BriCoCursorStartPos.X - CCBuf.X) +
               Abs( BriCoCursorStartPos.Y - CCBuf.Y) < 6 then
            begin
             // Too Small Step - Return to Source Values
              BriCoRedraw( EdSlide, RFrame, nil );
            end else begin
              with BriCoVCAttrs, EdSlide.GetPMapRootAttrs()^ do begin
                MRCoFactor := VCCoFactor;
                MRBriFactor := VCBriFactor;
              end;
              N_CM_MainForm.CMMFFinishImageEditing( K_CML1Form.LLLTools9.Caption,
//                   'Brightness / Contrast',
                   [cmssfMapRootChanged],
                   K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                                Ord(K_shImgActBriCoGam) ) );
            end;
            BriCoMode := FALSE;
            FreeAndNil(BriCoLSF);
            WCursor := crDefault;
          end;
        end
        else
        if BriCoModeStart       and
           (CHType = htMouseUp) and
           N_CM_MainForm.MeasureTextTimer.Enabled then
        begin // Clear Start Timer
          BriCoModeStart := FALSE;
          N_CM_MainForm.MeasureTextTimer.Enabled := false;
        end;

        if ssLeft in CMKShift then
        begin
          if BriCoMode then
            WCursor := crChangeBriCo
          else
          if ImageScrollMode then
            WCursor := crSizeAll
        end;
        Screen.Cursor := WCursor;
        // Str := '';
      end; // if NearestComp = nil

      if RFrame.Cursor <> WCursor then
        N_SetMouseCursorType(RFrame, WCursor);
    end // if not MoveObjMode and not MovePointMode
    else if MoveObjMode then
    begin
      K_CMSPCAddVObjEvent('Move Obj ', Self);
      if CHType = htMouseMove then
      begin
        // Move Current Obj
        if PrevScaleFactor <> RFVectorScale then
        begin
          with TN_UDCompVis(MovedComp.Owner) do
          begin
            SavedFPixPoint := N_AffConvF2FPoint(SavedFPoint, CompU2P);
            SavedCursorPos := N_AffConvF2IPoint(SavedCursorFPoint, CompU2P);
            CompPixRect := N_AffConvF2IRect(CompFRect, CompU2P);
          end;
          PrevScaleFactor := RFVectorScale;
        end;

        with MovedComp do
        begin
          // Check VObject Rectangle Shift
          PixShiftX := CCBuf.X - SavedCursorPos.X;
          PixShiftY := CCBuf.Y - SavedCursorPos.Y;
          OutsideShiftFlag := false;
          InsideGapX := 0; // to skip delphi warning
          InsideGapY := 0; // to skip delphi warning
          if ObjName[1] = 'T' then
          begin
            OutsideShiftFlag := TRUE;
            InsideGapX := 25;
            InsideGapY := 15;
          end
          else if ObjName[1] = 'Z' then
          begin
            OutsideShiftFlag := TRUE;
            with CompPixRect do
            begin
              InsideGapX := Round((Right - Left) / 2);
              InsideGapY := Round((Bottom - Top) / 2);
            end;
          end;
          K_CMSVObjCheckShift(RFLogFramePRect, CompPixRect, PixShiftX,
            PixShiftY, OutsideShiftFlag, InsideGapX, InsideGapY);

          // Shift To New Position
          NewFPixPoint.X := SavedFPixPoint.X + PixShiftX;
          NewFPixPoint.Y := SavedFPixPoint.Y + PixShiftY;
          PSP.CCoords.BPCoords := N_AffConvF2FPoint(NewFPixPoint,
            TN_UDCompVis(Owner).CompP2U);
          if ObjName[1] = 'M' then
            // Mearsure Line
            // !! Old            for i := 1 to MovedComp.DirHigh do
            for i := 2 to MovedComp.DirHigh do
              K_CMSVObjTextPosRebuild(RFrame, TN_UDCompVis(DirChild(i)),
                [cmtpfSkipStartRedraw, cmtpfSkipFinalShow])
          else if ObjName[2] = 'A' then
              // Angle
              K_CMSVObjTextPosRebuild(RFrame, TN_UDCompVis(DirChild(DirHigh)),
                [cmtpfSkipStartRedraw, cmtpfSkipFinalShow])
          else if (ObjName[1] = 'Z') then
          begin
            // FlashLight
            K_CMSFlashlightCalcSrcRect(MovedComp, RFVectorScale,
              N_RectSize(TN_UDCompVis(MovedComp).CompOuterPixRect));
            // CalcFlashlightSrcRect( MovedComp, RFVectorScale,  N_RectSize( TN_UDCompVis(MovedComp).CompOuterPixRect ) );
          end;

          // Redraw All and Show with and without K_CMRedrawObject
          if K_CMSkipMouseMoveRedraw > 0 then
          begin
            NP := RedrawAllAndShow;
            with K_CMRedrawObject do
            begin
              if not Assigned(OnRedrawProcObj) or
                 (TMethod(NP).Code <> TMethod(OnRedrawProcObj).Code) then
//                 not CompareMem( @OnRedrawProcObj, @NP, SizeOf(TNotifyEvent) ) then
                InitRedraw( RedrawAllAndShow );

              // Value of TK_NotifyProc RedrawAllAndShow is the same for different instances of TK_CMEMoveVObjRFA
              // (Different Instances TK_CMEMoveVObjRFA are because of each instance of TN_CMREdit3Frame has own instance of TK_CMEMoveVObjRFA)
              //
              // Need to set OnRedrawProcObj each time because assignment of K_CMRedrawObject.OnRedrawProcObj leads to
              // to call RedrawAllAndShow of needed instance of TK_CMEMoveVObjRFA in K_CMRedrawObject.Redraw()
              // K_CMRedrawObject.InitRedraw was not used because it reset K_CMRedrawObject redraw context
              OnRedrawProcObj := RedrawAllAndShow;
              if not MouseUpCheck() then
                OnCheckDirectRedraw := MouseUpCheck
              else
                OnCheckDirectRedraw := SkipDirectRedraw;

              Redraw();
            end;
          end // if K_CMSkipMouseMoveRedraw > 0 then
          else
            RedrawAllAndShow();
        end // with MovedComp do
      end // if MoveObjMode then
      else if CHType = htMouseUp then
      begin
        MoveObjMode := false;
        if ((Abs(SavedCursorPos.X - CCBuf.X) > 4) or
            (Abs(SavedCursorPos.Y - CCBuf.Y) > 4)) then
        begin

          if AfterFlashLightCreationMode then
          begin               // 'Add'
            FinActText := K_CML1Form.LLLObjEdit23.Caption + ' ' +
               N_CMResForm.aObjFLZEllipse.Caption;
            FinDumpText := 'Finish ' + N_CMResForm.aObjFLZEllipse.Caption +
              ' Creation';
            FinActHistCode := K_CMEDAccess.EDABuildHistActionCode(K_shATChange,
              Ord(K_shCAVOObject), Ord(K_shVOActAdd),
              Ord(K_shVOTypeFlashlight));
          end
          else
          begin
            FinActText := K_CML1Form.LLLObjEdit24.Caption; // 'Move Annotation';
            FinDumpText := 'Annotation ' + MovedComp.ObjName + ' moved';
            FinActHistCode := K_CMEDAccess.EDABuildHistActionCode(K_shATChange,
              Ord(K_shCAVOObject), Ord(K_shVOActMove),
              Ord(K_CMEDAccess.EDAGetVObjHistType(MovedComp)));
          end;
          AddToLog(FinDumpText);
          N_CM_MainForm.CMMFFinishVObjEditing(FinActText, FinActHistCode);
          // if MovedComp.ObjName[1] = 'Z' then begin
          if AfterFlashLightCreationMode then
          begin
            AfterFlashLightCreationMode := false;
            CreateVObjMode := 0; // ??
            RebuildVObjsSearchList();
            ChangeSelectedVObj(1, MovedComp);
            RedrawAllAndShow();
          end;
        end
        else // Undo Obj Move
          with MovedComp do
            PSP.CCoords.BPCoords := SavedFPoint;
      end // if CHType = htMouseUp then
      else if (CHType = htKeyDown) and
              (CKey.CharCode = VK_Escape) and
              (MovedComp.ObjName[1] = 'Z') then
      begin
        // Delete just created Flashlight
        AddToLog('Remove just created');
        CreateVObjMode := 0;
        MoveObjMode := false;
        ChangeSelectedVObj(0, MovedComp);
        with MovedComp.Owner do
          RemoveDirEntry(IndexOfDEField(MovedComp));
        RedrawAllAndShow();
      end
    end // if MoveObjMode
    else if MovePointMode then
      with TN_UDPolyline(MovedComp) do
      begin
        K_CMSPCAddVObjEvent('MovePoint', Self);

        CurSlide := EdSlide;
//??        CurSlide := nil;
        if CHType = htMouseMove then
        begin
{}
          if PrevScaleFactor <> RFVectorScale then
          begin
            CurCompP2U := EdSlide.GetMapRoot.CompU2P;
            SavedFPixPoint := N_AffConvF2FPoint(SavedFFPoint, CurCompP2U);
            SavedCursorPos := N_AffConvF2IPoint(SavedCursorFPoint, CurCompP2U);
            PrevScaleFactor := RFVectorScale;
          end;
          CurVobjMinSize := K_CMRectTypeVObjMinSize * RFVectorScale;

          // Move Current Obj Point
          DragSegmentMode := ssLeft in CMKShift;
          with NewFPixPoint, RFLogFramePRect do
          begin
            X := SavedFPixPoint.X + CCBuf.X - SavedCursorPos.X;
            Y := SavedFPixPoint.Y + CCBuf.Y - SavedCursorPos.Y;
            if (X < 0) or (X >= Right) or (Y < 0) or (Y >= Bottom) then
            begin
              X := Max(0, X);
              X := Min(Right, X);
              Y := Max(0, Y);
              Y := Min(Bottom, Y);
            end;

            if MoveMode = 3 then
            begin
              // Rect or Ellipse or Arrow or Flashlight
              // Correct by Min Size
              case SelectedVertInd of
                0:
                  begin

//                    DX := CompOuterPixRect.Right - K_CMRectTypeVObjMinSize;
                    DX := CompOuterPixRect.Right - CurVobjMinSize;
                    if X > DX then
                      X := DX;
//                    DY := CompOuterPixRect.Bottom - K_CMRectTypeVObjMinSize;
                    DY := CompOuterPixRect.Bottom - CurVobjMinSize;
                    if Y > DY then
                      Y := DY;
                  end;
                1:
                  begin
//                    DX := CompOuterPixRect.Left + K_CMRectTypeVObjMinSize;
                    DX := CompOuterPixRect.Left + CurVobjMinSize;
                    if X < DX then
                      X := DX;
//                    DY := CompOuterPixRect.Bottom - K_CMRectTypeVObjMinSize;
                    DY := CompOuterPixRect.Bottom - CurVobjMinSize;
                    if Y > DY then
                      Y := DY;
                  end;
                2:
                  begin
//                    DX := CompOuterPixRect.Left + K_CMRectTypeVObjMinSize;
                    DX := CompOuterPixRect.Left + CurVobjMinSize;
                    if X < DX then
                      X := DX;
//                    DY := CompOuterPixRect.Top + K_CMRectTypeVObjMinSize;
                    DY := CompOuterPixRect.Top + CurVobjMinSize;
                    if Y < DY then
                      Y := DY;
                  end;
                3:
                  begin
//                    DX := CompOuterPixRect.Right - K_CMRectTypeVObjMinSize;
                    DX := CompOuterPixRect.Right - CurVobjMinSize;
                    if X > DX then
                      X := DX;
//                    DY := CompOuterPixRect.Top + K_CMRectTypeVObjMinSize;
                    DY := CompOuterPixRect.Top + CurVobjMinSize;
                    if Y < DY then
                      Y := DY;
                  end;
              end; // case SelectedVertInd of
            end; // if MoveMode = 3 then
          end; // with NewFPixPoint, RFLogFramePRect do

          if MoveMode <> 3 then
          begin
            // Line, Mline, NAngle, FAngle
            NewFPoint := N_AffConvF2FPoint(NewFPixPoint, UDPFromBufPixCoefs4);
            PCurFPoint := PFPoint(PISP()^.CPCoords.P(SelectedVertInd));
            WFPoint := PCurFPoint^;
            PCurFPoint^ := NewFPoint;
//              N_IAdd( format( 'CX,CY==%d,%d SCX,SCY==%d,%d SPX,SPY=%f,%f NPX,NPY=%f,%f UX,UY=%f,%f ',
//              [CCBuf.X, CCBuf.Y, SavedCursorPos.X, SavedCursorPos.Y,
//              SavedFPixPoint.X, SavedFPixPoint.Y, NewFPixPoint.X, NewFPixPoint.Y,
//              NewFPoint.X, NewFPoint.Y] ))

             if (MoveMode = 5) or (MoveMode = 6) then
             begin
               K_CMSVObjRectRebuildByPoint( TN_UDPolyline(MovedComp), PCurFPoint, SelectedVertInd );
               if MoveMode = 6 then
                 K_CMSVObjEllipseRebuildByOuterRect( TN_UDPolyline(MovedComp.Owner.DirChild(1)), TN_UDPolyline(MovedComp) );
             end
             else
             if MoveMode = 4 then
             begin
               K_CMSVObjArrowTipLineRebuild( TN_UDPolyLine(MovedComp), K_CMArrowLineTipSize * RFVectorScale );
             end;
          end   // if MoveMode <> 3 then
          else
          begin if MoveMode = 3 then
            // Rect or Ellipse or Arrow or Flashlight
            if not (Owner is TN_UDCompVis) then
              DX := NewFPoint.X - PrevFPoint.X; //!!!! Special Code to Find Error

            with TN_UDCompVis(Owner), PSP.CCoords do
            begin
              // NewFPoint := N_AffConvF2FPoint( NewFPixPoint, TN_UDCompVis(Owner).CompP2U );
              NewFPoint := N_AffConvF2FPoint(NewFPixPoint, CompP2U);
              DX := NewFPoint.X - PrevFPoint.X;
              DY := NewFPoint.Y - PrevFPoint.Y;
              PrevFPoint := NewFPoint;
              case SelectedVertInd of
                0:
                  begin
                    BPCoords := NewFPoint;
                    SRSize.X := SRSize.X - DX;
                    SRSize.Y := SRSize.Y - DY;
                  end;
                1:
                  begin
                    BPCoords.Y := NewFPoint.Y;
                    SRSize.X := SRSize.X + DX;
                    SRSize.Y := SRSize.Y - DY;
                  end;
                2:
                  begin
                    SRSize.X := SRSize.X + DX;
                    SRSize.Y := SRSize.Y + DY;
                  end;
                3:
                  begin
                    BPCoords.X := NewFPoint.X;
                    SRSize.X := SRSize.X - DX;
                    SRSize.Y := SRSize.Y + DY;
                  end;
              end; // case SelectedVertInd of

              if (ObjName[1] = 'Z') then
              begin
                // FlashLight
                // !! Old                PCDIBRect := @TN_UDDIBRect(DirChild(0)).PSP.CDIBRect;
                PCDIBRect := @TN_UDDIBRect(DirChild(1)).PSP.CDIBRect;
                K_CMSFlashlightCalcSrcRect(TN_UDCompVis(MovedComp.Owner),
                  RFVectorScale, N_RectSize(CompOuterPixRect));
              end;
            end; // with TN_UDCompVis(Owner), PSP.CCoords do
          end; // if MoveMode = 3 then

          if MoveMode = 0 then
          begin
            // Polyline Mode

            DX := (NewFPoint.X - WFPoint.X) / 2;
            DY := (NewFPoint.Y - WFPoint.Y) / 2;

            if PrevTextComp <> nil then
              SetSegmText(PrevTextComp, PrevFPoint, PrevSegmLength);

            if NextTextComp <> nil then
              SetSegmText(NextTextComp, NextFPoint, NextSegmLength);

            if AllTextComp <> nil then
            begin
              if NextTextComp = nil then
              begin
                // Move All Length Text
                DX := DX + DX;
                DY := DY + DY;
              end
              else
              begin
                // not Move All Length Text
                DX := 0;
                DY := 0;
              end;
              SetTextVal(AllTextComp, LineLength, '=');
            end;

            if (MovedComp.Owner.ObjName[1] = 'M') and
              (PISP()^.CPCoords.ALength <= 3) then
              // Recalc all Segment texts if number of segments is less then <= 2
              EdSlide.RebuildMLineTexts(MovedComp.Owner);

          end // if MoveMode = 0 then
          else if (MoveMode = 1) or (MoveMode = 2) then
          begin
            // RedrawAll without MapImage for proper Angle calc
            //if K_CMSkipMouseMoveRedraw > 0 then
            begin
              with EdSlide.GetMapImage().PSP.CCompBase do
              begin
                CBSkipSelf := 100;
                RedrawAll();
                CBSkipSelf := 0;
              end;
            end; // if K_CMSkipMouseMoveRedraw > 0 then

            if MoveMode = 1 then
              TextBasePoint := K_CMSVObjNAngleRebuild(LineComp, ArcComp,
                TextComp, @TextBasePoint)
            else if MoveMode = 2 then
            begin
              TextBasePoint := K_CMSVObjFAngleRebuild(LineComp1, LineComp2,
                LineComp3, ArcComp, TextComp, @TextBasePoint);
            end;
          end;

          // Redraw All and Show with and without K_CMRedrawObject
          if K_CMSkipMouseMoveRedraw > 0 then
          begin
            NP := RedrawAllAndShow;
            with K_CMRedrawObject do
            begin
            if not Assigned(OnRedrawProcObj) or
               (TMethod(NP).Code <> TMethod(OnRedrawProcObj).Code) then
//               not CompareMem( @OnRedrawProcObj, @NP, SizeOf(TNotifyEvent) ) then
              InitRedraw( RedrawAllAndShow );

              // Value of TK_NotifyProc RedrawAllAndShow is the same for different instances of TK_CMEMoveVObjRFA
              // (Different Instances TK_CMEMoveVObjRFA are because of each instance of TN_CMREdit3Frame has own instance of TK_CMEMoveVObjRFA)
              //
              // Need to set OnRedrawProcObj each time because assignment of K_CMRedrawObject.OnRedrawProcObj leads to
              // to call RedrawAllAndShow of needed instance of TK_CMEMoveVObjRFA in K_CMRedrawObject.Redraw()
              // K_CMRedrawObject.InitRedraw was not used because it reset K_CMRedrawObject redraw context
              OnRedrawProcObj := RedrawAllAndShow;
              if not MouseUpCheck() then
                OnCheckDirectRedraw := MouseUpCheck
              else
                OnCheckDirectRedraw := SkipDirectRedraw;

              Redraw();
            end;
          end // if K_CMSkipMouseMoveRedraw > 0 then
          else
            RedrawAllAndShow();

        end // if CHType = htMouseMove then
        else if CreateVObjMode = 0 then
        begin
          // Check finish pure Vertex move
          if CHType = htMouseUp then
          begin
            FinCreateText := K_CML1Form.LLLObjEdit25.Caption; // 'Move Annotation Vertex';
            VObjAction := K_ShVOActMoveVertex;
            if MovedComp.Owner.ObjName[1] = 'Z' then
              TN_UDBase(MovedComp):= MovedComp.Owner;
            if MoveMode = 3 then
            begin
              VObjAction := K_ShVOActResize;
              FinCreateText := K_CML1Form.LLLObjEdit26.Caption; // 'Resize Annotation'
//              FinCreateText := format( K_CML1Form.LLLObjEdit26.Caption,
//                         'Resize %s Annotation',
//                         [MovedComp.ObjName] );
            end;

            MovePointMode := false;
            AddToLog(FinCreateText);
            N_CM_MainForm.CMMFFinishVObjEditing(FinCreateText,
              K_CMEDAccess.EDABuildHistActionCode(K_shATChange,
                Ord(K_shCAVOObject), Ord(VObjAction),
                Ord(K_CMEDAccess.EDAGetVObjHistType(MovedComp))));
          end
        end
        else
        begin
          // Check finish Vertex move after VObj creation

          if (CreateVObjMode = -1)                  and
             (CHType = htMouseUp)                   and
             (Abs(SavedCursorPos.X - CCBuf.X) <= 4) and
             (Abs(SavedCursorPos.Y - CCBuf.Y) <= 4) then
            Exit // Ignore MouseUp near Start Point
          else
            CreateVObjMode := -2;

          if (CHType = htKeyDown) and (CKey.CharCode = VK_Escape) then
          begin
            // Delete just created VObj
            AddToLog('Remove just created');
            CreateVObjMode := 0;
            MovePointMode := false;
            ChangeSelectedVObj(0, TN_UDCompVis(MovedComp.Owner));
            with MovedComp.Owner.Owner do
              RemoveDirEntry(DirHigh);
            RebuildVObjsSearchList();
            RedrawAllAndShow();
            Exit;
          end
          else if ((CHType = htMouseUp) and DragSegmentMode) or
                  ((CHType = htMouseDown) and not DragSegmentMode) then
          begin
            // Finish Rect-Ellipse-Arror creation
            CreateVObjMode := 0;
            MovePointMode := false;
            with MovedComp.Owner do
              if ObjName[1] = 'R' then
                FinCreateText := N_CMResForm.aObjRectangleOld.Caption
              else if ObjName[1] = 'E' then
                FinCreateText := N_CMResForm.aObjEllipseOld.Caption
              else if ObjName[1] = 'A' then
                FinCreateText := N_CMResForm.aObjArrowOld.Caption;
            // else if ObjName[1] = 'Z' then
            // FinCreateText := N_CMResForm.aObjFLZEllipse.Caption;
            AddToLog('Finish ' + FinCreateText + ' Creation');
            N_CM_MainForm.CMMFFinishVObjEditing(FinCreateText,
              K_CMEDAccess.EDABuildHistActionCode(K_shATChange,
                Ord(K_shCAVOObject), Ord(K_shVOActAdd),
                Ord(K_CMEDAccess.EDAGetVObjHistType(MovedComp.Owner))));
          end;
        end;
      end; // if MovePointMode

    // AddProt( '*** VOj event fin ' );
    // N_CM_MainForm.CMMFShowString( Str );
  end; // with TN_SGComp(ActGroup), OneSR, ActGroup.RFrame do

end; // procedure TK_CMEMoveVObjRFA.Execute

{ *** end of TK_CMEMoveVObjRFA *** }

{ *** TK_CMEIsodensityRFA *** }

//********************************************* TK_CMEIsodensityRFA.Execute ***
// Isodensity select color Action
//
procedure TK_CMEIsodensityRFA.Execute;
var
  WCursor: TCursor;
  ColorStr: string;
  CurColor: Integer;
  PixMapImageCoords: TPoint;
//  PixCurImageCoords: TPoint;

begin

  inherited;

  with TN_SGComp(ActGroup), OneSR, RFrame, TN_CMREdit3Frame(Parent) do
  begin
    if EdViewEditMode <> cmrfemIsodensity then
    begin
      // Close Self Activity
      N_Dump2Str(RFrame.Parent.Name + '.' + ActName + ': Self Disabled');

      if RFrame.Cursor = crGetColor then
        N_SetMouseCursorType(RFrame, crDefault);

      Self.ActEnabled := false;
      // Clear Selected
      N_CM_MainForm.CMMFShowString('');
      SetFrameDefaultViewEditMode(); // !!! 2011-10-26
{ !!! 2011-10-26
      if (EdViewEditMode <> cmrfemPoint) and
        (RFrame.Parent = N_CM_MainForm.CMMFActiveEdFrame) then
        N_CMResForm.aEditPointExecute(nil)
      else
        N_SetMouseCursorType(RFrame, crDefault);
}
      Exit;
    end;

//N_i := Byte(CMKShift);
//N_Dump2Str(ActGroup.RFrame.Parent.Name + '.' + ActName + ' Type1= ' + format( ' %d %d ', [ Ord(CHType), N_i ] ) );
    if SkipNextMouseDown and (CHType = htMouseDown) then
    begin
      SkipNextMouseDown := false;
      Exit;
    end;

    WCursor := crDefault;
    with CCBuf, RFLogFramePRect do
      if (X >= 0) and (X <= Right) and (Y >= 0) and (Y <= Bottom) then
        WCursor := crGetColor; // Test Color Cursor
    if RFrame.Cursor <> WCursor then
      N_SetMouseCursorType(RFrame, WCursor);

//N_Dump2Str(ActGroup.RFrame.Parent.Name + '.' + ActName + ' Type2= ' + format( ' %d %d ', [ Ord(CHType), N_i ] ) );
    ColorStr := '';
    if WCursor = crGetColor then
    begin
{
      with EdSlide, GetMapImage() do
      begin
        PixMapImageCoords := BufToDIBCoords(CCBuf);
        PixCurImageCoords := N_FlipRotateCoords(PixMapImageCoords,
          N_BackwardFlags[GetPMapRootAttrs()^.MRFlipRotateAttrs],
          DIBObj.DIBRect);
        CurColor := GetCurrentImage().DIBObj.GetPixValue(PixCurImageCoords);
      end;
}
      CurColor := EdSlide.GetCurImgPixColorByMapImgCursorPos( CCBuf, @PixMapImageCoords );

{}
//N_Dump2Str(ActGroup.RFrame.Parent.Name + '.' + ActName + ' Type3= ' + format( ' %d %d ', [ Ord(CHType), N_i ] )  );
      if CHType = htMouseDown then
      begin
        if ssLeft in CMKShift then
        begin
          K_FormCMSIsodensity.SetImgColor(CurColor);
//N_Dump2Str(ActGroup.RFrame.Parent.Name + '.' + ActName + ' Type4= ' + format( ' %d %d ', [ Ord(CHType), N_i ] )  );
        end;
      end;
{}
{
      if CHType = htMouseUp then
      begin
        if ssLeft in LastCMKShift then
        begin
          K_FormCMSIsodensity.SetImgColor(CurColor);
//N_Dump2Str(ActGroup.RFrame.Parent.Name + '.' + ActName + ' Type4= ' + format( ' %d %d ', [ Ord(CHType), N_i ] )  );
        end;
      end;
{}

      if (cmsfGreyScale in EdSlide.P.CMSDB.SFlags) and (Length(EdSlide.CMSXLatBCGColor) <> 0) then
        CurColor := EdSlide.CMSXLatBCGColor[CurColor];

      ColorStr := format('X,Y: %5d,%5d; I: %3d', [PixMapImageCoords.X,
                                                  PixMapImageCoords.Y, CurColor]);
      if (N_BrigHist2Form <> nil) and
         (TN_SGComp(ActGroup).RFrame.Parent = N_CM_MainForm.CMMFActiveEdFrame) then
        N_BrigHist2Form.SetCurBrightness( CurColor );

    end; // if WCursor = crGetColor  then begin

    LastCMKShift := CMKShift;

    N_CM_MainForm.CMMFShowString(ColorStr);

  end; // with TN_SGComp(ActGroup), OneSR, ActGroup.RFrame do

end; // procedure TK_CMEIsodensityRFA.Execute

{ *** end of TK_CMEIsodensityRFA *** }

{ *** TK_CMERubberRectRFA *** }

//********************************************* TK_CMERubberRectRFA.Execute ***
// Show Rubber Rectangle Action
//
procedure TK_CMERubberRectRFA.Execute;
var
  NP : TK_NotifyProc;
begin

  with TN_SGComp(ActGroup), OneSR, RFrame, TN_CMREdit3Frame(Parent) do
  begin
    if EdViewEditMode <> cmrfemCropImage then
    begin
      N_Dump2Str(RFrame.Parent.Name + '.' + ActName + ': Self Disabled');
      N_Dump1Str(RFrame.Parent.Name + ': Crop Image canceled');
      EdRubberRectRFA.ActEnabled := false;
      RFrame.RedrawAllAndShow();

      with N_CMResForm do
      begin
        aEditPointExecute(nil);
      end;
      Exit;
    end; // if EdViewEditMode <> cmrfemCropImage then
  end; // with TN_SGComp(ActGroup), OneSR, RFrame, TN_CMREdit3Frame(Parent) do

  // Init Redraw All and Show with K_CMRedrawObject
  if K_CMSkipMouseMoveRedraw > 0 then
  begin
    NP := MouseMoveRedraw;
    with K_CMRedrawObject do
    begin
      if not Assigned(OnRedrawProcObj) or
         (TMethod(NP).Code <> TMethod(OnRedrawProcObj).Code) then
//         not CompareMem( @OnRedrawProcObj, @NP, SizeOf(TNotifyEvent) ) then
      begin
        InitRedraw( MouseMoveRedraw );
        RROnMouseMoveRedrawProcObj := Redraw;
      end;

      // Value of TK_NotifyProc MouseMoveRedraw is the same for different instances of TK_CMERubberRectRFA
      // (Different Instances TK_CMERubberRectRFA are because of each instance of TN_CMREdit3Frame has own instance of TK_CMERubberRectRFA)
      //
      // Need to set OnRedrawProcObj each time because assignment of K_CMRedrawObject.OnRedrawProcObj leads to
      // to call MouseMoveRedraw of needed instance of TK_CMERubberRectRFA in K_CMRedrawObject.Redraw()
      // K_CMRedrawObject.InitRedraw was not used because it reset K_CMRedrawObject redraw context
      OnRedrawProcObj := MouseMoveRedraw;
    end; // with K_CMRedrawObject do

  end; // if K_CMSkipMouseMoveRedraw > 0 then

  inherited;

end; // procedure TK_CMERubberRectRFA.Execute

{ *** end of TK_CMERubberRectRFA *** }

{ *** TK_CMEFlashLightModeRFA *** }

//********************************* TK_CMEFlashLightModeRFA.MouseMoveRedraw ***
// FlashLight MouseMove Redraw routine
//
procedure TK_CMEFlashLightModeRFA.MouseMoveRedraw;
begin
  with Self.ActGroup, RFrame, TN_CMREdit3Frame(Parent) do
  begin
    if WCursor = crNone then
      RFrame.Cursor := crHandPoint
    else
      RFrame.Cursor := WCursor;
    RFrame.RedrawAllAndShow();
  end;
end; // procedure TK_CMEFlashLightModeRFA.MouseMoveRedraw

//*************************************** TN_CMFlashLightRFA.HideFlashlight ***
// Hide FlashLight Component
//
procedure TK_CMEFlashLightModeRFA.HideFlashlight( ARedrawFlag : Boolean );
begin
  with ActGroup, RFrame do
  begin
    if CMEFLComp <> nil then
    begin // Clear Flashlight component reference
//      if RVCTreeRoot.ObjLiveMark = N_ObjLiveMark then
      CMEFLComp.PSP.CCompBase.CBSkipSelf := 1;
      CMEFLComp := nil;
      RFrame.Cursor := crDefault;
      if ARedrawFlag then RedrawAllAndShow();
    end;
  end; // with ActGroup, RFrame do
end; // procedure TK_CMEFlashLightModeRFA.HideFlashlight

//********************************************** TN_CMFlashLightRFA.Execute ***
// Move FlashLight Component
//
procedure TK_CMEFlashLightModeRFA.Execute;
var
  UDMapRoot : TN_UDCompVis;
  UDLibCompPat : TN_UDBase;
  PixShiftX : Integer;
  ZoomPixPoint : TPoint;
//  WCursor : TCursor;
  PrevCursor : TCursor;
  CursorPos : TPoint;
  UDCurImg : TN_UDDIB;
  NP : TK_NotifyProc;

begin
  inherited;

  with ActGroup, RFrame, TN_CMREdit3Frame(Parent) do
  begin
  // Hide Flashlight in previous Ed3Frame
    if (N_CM_MainForm.CMMFlashlightLastEd3Frame <> nil) and
       (N_CM_MainForm.CMMFlashlightLastEd3Frame <> RFrame.Parent) then
    begin
       N_CM_MainForm.CMMFlashlightLastEd3Frame.EdFlashLightModeRFA.HideFlashlight( TRUE );
       N_CM_MainForm.CMMFlashlightLastEd3Frame := nil;
    end;

  // Disable Flashlight Mode RFA action if Ed3Frame Mode is changed
    if EdViewEditMode <> cmrfemFlashLight then
    begin
      // Close Self Activity
      N_Dump2Str(RFrame.Parent.Name + '.' + ActName + ': Self Disabled');
      Self.ActEnabled := false;
      if CMEFLComp <> nil then HideFlashlight( FALSE );
      Exit;
    end;
    if EdSlide = nil then Exit; // precaution

    if (CHType = htMouseDown) and
       (ssLeft in CMKShift)   and
       (ssDouble in CMKShift) then
    begin
      // Object Double Click
      K_CMSPCAddVObjEvent('Dbl Click', Self);

      if K_CMSFullScreenForm = nil then
      begin
        N_CMResForm.aEditFullScreenExecute( N_CMResForm.aEditFullScreen );
      end else
        N_CMResForm.aEditFullScreenCloseExecute(N_CMResForm.aEditFullScreenClose);
      Exit;
    end;

    UDCurImg  := EdSlide.GetCurrentImage();
    UDMapRoot := EdSlide.GetMapRoot();
    // Rebuild Flashlight Vis Component Reference
    if CMEFLComp = nil then
    begin
      with UDMapRoot do
      begin
        CMEFLComp := TN_UDCompVis( DirChild( DirHigh() ) );
        if (CMEFLComp <> nil) and (CMEFLComp.ObjName <> 'ZEllipse') then
        begin
          // Create Flashlight VisComponent
          UDLibCompPat := K_CMEDAccess.ArchMLibRoot.DirChildByObjName('ZEllipse');
          Assert(UDLibCompPat <> nil,
             'Flashlight Pattern Object is absent');

          CMEFLComp := TN_UDCompVis( K_CMSAddCloneChild(UDMapRoot, UDLibCompPat, FALSE ) );
          CMEFLComp.ClassFlags := CMEFLComp.ClassFlags + K_SkipSelfSaveBit;

//          K_CMSetFlashLightAttrs( CMEFLComp, @K_CMFlashlightModeIni );
//        end
//        else
//          PFloat(K_CMGetVObjPAttr(CMEFLComp, 'ScaleFactor').UPValue.P)^ := K_CMFlashlightModeIni.CMFLScaleFactor;
        end;
        K_CMSetFlashLightAttrs( CMEFLComp, @K_CMFlashlightModeIni );

        CMEFLComp.PSP.CCompBase.CBSkipSelf := 0;
      end;
    end
    else
      PFloat(K_CMGetVObjPAttr(CMEFLComp, 'ScaleFactor').UPValue.P)^ := K_CMFlashlightModeIni.CMFLScaleFactor;

    // Build XLAT by Pseudocolors
    with TN_UDDIBRect(CMEFLComp.DirChild(1)).PISP^ do
    begin
      if CDRXLATClrz = nil then
        CDRXLATClrz := K_RCreateByTypeCode(Ord(nptInt), 256);
      CDRXLATClrz.ASetLength( 256 );
      K_CMColorizeBuildColors( CDRXLATClrz.P, 256, K_CMColorizePalIndex, TRUE);
    end;

    // Link Flashlight to Slide MapImage
    with TN_UDDIBRect(CMEFLComp.DirChild(1)).PISP^ do
    begin
      K_SetUDRefField( TN_UDBase(CDRSrcUDDIB), EdSlide.GetMapImage(), TRUE );
      CDRFlags := CDRFlags - [uddrfGreyDIB,uddrfColorize,uddrfEmboss,uddrfIsodensity];
      with EdSlide, P()^, UDCurImg.DIBObj do
      begin
        if (DIBExPixFmt = epfGray8) or (DIBExPixFmt = epfGray16) then
          Include( CDRFlags, uddrfGreyDIB );
        if cmsfShowColorize in CMSDB.SFlags then
          Include( CDRFlags, uddrfColorize );
        if cmsfShowIsodensity in CMSDB.SFlags then
          Include( CDRFlags, uddrfIsodensity );
        if cmsfShowEmboss in CMSDB.SFlags then
          Include( CDRFlags, uddrfEmboss );
      end;
    end;

    // Show Flashlight Border if needed
    with K_CMGetVObjPAttr( CMEFLComp, 'MainColor' ).UPValue do
      if (K_CMFlashlightModeIni.CMFLScaleFactor = 1) and
         (K_CMFlashlightModeIni.CMFLMode = uddrmNoEffect) then
        PInteger(P)^ := 0
      else
        PInteger(P)^ := -1;

    // Rebuild Flashlight Size, Position and Viewed MapImage Area
    with CMEFLComp.PCCS()^ do
    begin
      SRSize.X := UDMapRoot.CompP2U.CX * K_CMFlashlightModeIni.CMFLPixSize;
      SRSize.Y := UDMapRoot.CompP2U.CY * K_CMFlashlightModeIni.CMFLPixSize;
      ZoomPixPoint := CCBuf;
      PrevCursor := RFrame.Cursor;
      WCursor := crNone;
      if ZoomPixPoint.X < RFLogFramePRect.Left then
      begin
        ZoomPixPoint.X := RFLogFramePRect.Left;
        WCursor := crDefault;
      end else
      if ZoomPixPoint.X  > RFLogFramePRect.Right then
      begin
        ZoomPixPoint.X := RFLogFramePRect.Right;
        WCursor := crDefault;
      end;
      if ZoomPixPoint.Y < RFLogFramePRect.Top then
      begin
        ZoomPixPoint.Y := RFLogFramePRect.Top;
        WCursor := crDefault;
      end else
      if ZoomPixPoint.Y  > RFLogFramePRect.Bottom then
      begin
        ZoomPixPoint.Y := RFLogFramePRect.Bottom;
        WCursor := crDefault;
      end;

      PixShiftX := K_CMFlashlightModeIni.CMFLPixSize shr 1;
      BPCoords := N_AffConvF2FPoint( FPoint(ZoomPixPoint.X - PixShiftX, ZoomPixPoint.Y - PixShiftX), UDMapRoot.CompP2U );

      K_CMSFlashlightCalcSrcRect( CMEFLComp, RFVectorScale,
                  Point(K_CMFlashlightModeIni.CMFLPixSize, K_CMFlashlightModeIni.CMFLPixSize));
      if WCursor = crDefault then
//        BPCoords := N_AffConvF2FPoint( FPoint(CCBuf.X - PixShiftX, CCBuf.Y - PixShiftX), UDMapRoot.CompP2U );
        HideFlashlight( FALSE );

      if (PrevCursor <> crDefault) or (WCursor <> crDefault) then
      begin // Redraw is needed
{
        MouseMoveRedraw();
//        RFrame.Cursor := WCursor;
//        RedrawAllAndShow();
}
        if (K_CMSkipMouseMoveRedraw = 0) or (WCursor = crDefault) then
        begin // Direct Redraw
          RFrame.Cursor := WCursor;
          RedrawAllAndShow();
        end   // if (K_CMSkipMouseMoveRedraw = 0)  or  (WCursor = crDefault) then
        else
        begin // if (K_CMSkipMouseMoveRedraw <> 0) and (WCursor <> crDefault) then
          //  Redraw by K_CMRedrawObject
          NP := MouseMoveRedraw;
          with K_CMRedrawObject do
          begin
            if not Assigned(OnRedrawProcObj) or
               (TMethod(NP).Code <> TMethod(OnRedrawProcObj).Code) then
//               not CompareMem( @OnRedrawProcObj, @NP, SizeOf(TNotifyEvent) ) then
              InitRedraw( MouseMoveRedraw, SkipDirectRedraw );

            // Value of TK_NotifyProc MouseMoveRedraw is the same for different instances of TK_CMEFlashLightModeRFA
            // (Different Instances TK_CMEFlashLightModeRFA are because of each instance of TN_CMREdit3Frame has own instance of TK_CMEFlashLightModeRFA)
            //
            // Need to set OnRedrawProcObj each time because assignment of K_CMRedrawObject.OnRedrawProcObj leads to
            // to call MouseMoveRedraw of needed instance of TK_CMEFlashLightModeRFA in K_CMRedrawObject.Redraw()
            // K_CMRedrawObject.InitRedraw was not used because it reset K_CMRedrawObject redraw context
            OnRedrawProcObj := MouseMoveRedraw;

            Redraw();
          end; // with K_CMRedrawObject do

          if WCursor = crNone then
            RFrame.Cursor := crHandPoint
          else
            RFrame.Cursor := WCursor;

        end // if (K_CMSkipMouseMoveRedraw <> 0) and (WCursor <> crDefault) then
      end; // if (PrevCursor <> crDefault) or (WCursor <> crDefault) then
    end; // with CMEFLComp.PCCS()^ do

    N_CM_MainForm.CMMFlashlightLastEd3Frame := TN_CMREdit3Frame(RFrame.Parent);

    if (CHType = htMouseDown) and (ssRight in CMKShift) then
    begin
      Windows.GetCursorPos( CursorPos );
      K_CMSFlashlightModeAttrsDlg( @K_CMFlashlightModeIni, CMEFLComp );
      Windows.SetCursorPos( CursorPos.X, CursorPos.Y );
    end; // if (CHType = htMouseDown) and (ssRight in CMKShift) then

  end; // with ActGroup.RFrame do
end; // procedure TK_CMEFlashLightModeRFA.Execute

{*** end of TK_CMEFlashLightModeRFA ***}

Initialization

N_RFAClassRefs[K_ActCMEAddVObj1]   := TK_CMEAddVObj1RFA;
N_RFAClassRefs[K_ActCMEAddVObj2]   := TK_CMEAddVObj2RFA;
N_RFAClassRefs[K_ActCMEMoveVObj]   := TK_CMEMoveVObjRFA;
N_RFAClassRefs[K_ActCMEIsodensity] := TK_CMEIsodensityRFA;
N_RFAClassRefs[K_ActCMERubberRect] := TK_CMERubberRectRFA;
N_RFAClassRefs[K_ActCMEFlashLightMode] := TK_CMEFlashLightModeRFA;

end.
